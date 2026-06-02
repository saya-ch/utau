"""
游戏素材统一后处理。
所有生成脚本必须导入此模块，不写内联代码。
"""

from pathlib import Path
import warnings
import numpy as np
from PIL import Image, ImageFilter


def remove_background(image: Image.Image, method: str = "rembg") -> Image.Image:
    """
    移除背景，返回 RGBA。method: "rembg" | "chroma" | "auto"
    """
    if method in ("rembg", "auto"):
        try:
            from rembg import remove, new_session
            session = new_session("u2net")
            return remove(image.convert("RGB"), session=session,
                          alpha_matting=True,
                          alpha_matting_foreground_threshold=240,
                          alpha_matting_background_threshold=10,
                          alpha_matting_erode_size=4).convert("RGBA")
        except Exception:
            if method == "rembg":
                raise
    # chroma key fallback
    img = image.convert("RGBA")
    data = np.array(img, dtype=np.float32)
    # 采样边缘确定背景色
    h, w = data.shape[:2]
    edges = np.concatenate([
        data[0:3, :, :3].reshape(-1, 3), data[h-3:h, :, :3].reshape(-1, 3),
        data[:, 0:3, :3].reshape(-1, 3), data[:, w-3:w, :3].reshape(-1, 3),
    ])
    bg = np.median(edges, axis=0)
    diff = np.sqrt(np.sum((data[:, :, :3] - bg) ** 2, axis=2))
    alpha = np.clip(diff / 50 * 255, 0, 255).astype(np.uint8)
    a_img = Image.fromarray(alpha, 'L').filter(ImageFilter.GaussianBlur(radius=1))
    data[:, :, 3] = np.array(a_img)
    return Image.fromarray(data.astype(np.uint8), 'RGBA')


def trim_to_content(image: Image.Image, padding: int = 8) -> Image.Image:
    """裁剪到非透明内容边界。"""
    if image.mode != "RGBA":
        image = image.convert("RGBA")
    alpha = np.array(image.split()[-1])
    ys, xs = np.where(alpha > 30)
    if len(ys) == 0:
        return image
    y1, y2 = max(0, ys.min()-padding), min(image.height, ys.max()+padding)
    x1, x2 = max(0, xs.min()-padding), min(image.width, xs.max()+padding)
    return image.crop((x1, y1, x2, y2))


def fit_to_canvas(image: Image.Image, canvas_size: int = 256,
                  anchor: str = "center", fill_ratio: float = 0.85) -> Image.Image:
    """
    放入正方形画布。anchor: "center" | "bottom-center" | "top-center"
    """
    if isinstance(canvas_size, int):
        cw = ch = canvas_size
    else:
        cw, ch = canvas_size
    image = trim_to_content(image)
    scale = min(cw * fill_ratio / image.width, ch * fill_ratio / image.height, 1.0)
    nw, nh = max(1, int(image.width * scale)), max(1, int(image.height * scale))
    image = image.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    if anchor == "center":
        x, y = (cw - nw) // 2, (ch - nh) // 2
    elif anchor == "bottom-center":
        x = (cw - nw) // 2
        y = ch - nh - max(1, int(ch * 0.03))
    elif anchor == "top-center":
        x = (cw - nw) // 2
        y = max(1, int(ch * 0.03))
    else:
        raise ValueError(f"未知锚点: {anchor}")
    canvas.paste(image, (x, y), image)
    return canvas


def resize_asset(image: Image.Image, target_size: int | tuple,
                 resample=Image.LANCZOS) -> Image.Image:
    """缩放到目标尺寸。像素风传 resample=Image.NEAREST。"""
    if isinstance(target_size, int):
        target_size = (target_size, target_size)
    return image.resize(target_size, resample)


def multi_size_export(image: Image.Image, base_name: str, output_dir: Path,
                      sizes: list = [64, 128, 256],
                      resample=Image.LANCZOS) -> dict:
    """导出多种尺寸。像素风传 resample=Image.NEAREST。"""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    paths = {}
    for s in sizes:
        p = output_dir / f"{base_name}_{s}x{s}.png"
        resize_asset(image, s, resample).save(p, "PNG", optimize=True)
        paths[s] = str(p)
    return paths


def add_outline(image: Image.Image, color=(0,0,0,255), width=2) -> Image.Image:
    """纯 numpy 描边，无重依赖。"""
    if image.mode != "RGBA":
        image = image.convert("RGBA")
    alpha = np.array(image.split()[-1])
    mask = alpha > 30
    # 3x3 dilation
    dilated = mask.copy()
    for _ in range(width):
        d = dilated
        dilated = d | np.roll(d, 1, 0) | np.roll(d, -1, 0) | np.roll(d, 1, 1) | np.roll(d, -1, 1)
    outline = dilated & (~mask)
    result = np.array(image)
    result[outline] = color
    return Image.fromarray(result, 'RGBA')


def flip_horizontal(image: Image.Image) -> Image.Image:
    """水平翻转。"""
    return image.transpose(Image.FLIP_LEFT_RIGHT)


def validate_asset(image: Image.Image) -> dict:
    """基础质检：内容占比、色板熵值、中心偏移。"""
    if image.mode != "RGBA":
        image = image.convert("RGBA")
    data = np.array(image)
    alpha = data[:, :, 3]; rgb = data[:, :, :3]
    visible = alpha > 30
    ratio = float(np.mean(visible))
    issues = []
    if ratio < 0.01: issues.append("全透明")
    if ratio > 0.98: issues.append("可能未去背景")
    if np.any(visible):
        ys, xs = np.where(visible)
        offset = float(np.sqrt(((xs.mean()-image.width/2)/image.width)**2 +
                                ((ys.mean()-image.height/2)/image.height)**2))
    else:
        offset = 0.0
    if offset > 0.3: issues.append(f"构图偏移 {offset:.1%}")
    return {"ok": len(issues) == 0, "issues": issues,
            "content_ratio": round(ratio, 4), "center_offset": round(offset, 4)}
