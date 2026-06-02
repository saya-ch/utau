"""
Spritesheet 打包 + 纹理图集 JSON 导出。
"""

import json
import math
import warnings
from pathlib import Path
from typing import Optional

from PIL import Image


def _normalize(frame, size):
    fw, fh = size
    if frame.size == (fw, fh):
        return frame
    c = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    c.paste(frame, ((fw-frame.width)//2, (fh-frame.height)//2),
            frame if frame.mode == "RGBA" else None)
    return c


def create_spritesheet(
    frames: list[Image.Image],
    cols: int = 0, rows: int = 0,
    frame_size: Optional[tuple] = None,
    pad: int = 1,
    bg_color=(0, 0, 0, 0),
) -> tuple[Image.Image, dict]:
    """网格打包为 Spritesheet。返回 (图像, 元数据)。"""
    if not frames:
        raise ValueError("frames 为空")
    fw, fh = frame_size or (max(f.width for f in frames), max(f.height for f in frames))
    n = len(frames)
    if not cols and not rows:
        cols = math.ceil(math.sqrt(n))
    cols = cols or math.ceil(n / rows)
    rows = rows or math.ceil(n / cols)

    if n > cols * rows:
        warnings.warn(f"帧数 {n} > 网格容量 {cols}x{rows}")

    sw = cols * (fw + pad) - pad
    sh = rows * (fh + pad) - pad
    sheet = Image.new("RGBA", (sw, sh), bg_color)
    meta = {"cols": cols, "rows": rows, "frame_width": fw, "frame_height": fh,
            "pad": pad, "total_frames": n, "frames": []}

    for i, f in enumerate(frames):
        r, c = divmod(i, cols)
        if r >= rows:
            break
        x, y = c * (fw + pad), r * (fh + pad)
        f = _normalize(f, (fw, fh))
        sheet.paste(f, (x, y), f if f.mode == "RGBA" else None)
        meta["frames"].append({"index": i, "name": f"frame_{i:04d}",
                                "x": x, "y": y, "width": fw, "height": fh})
    return sheet, meta


def create_animation_strip(
    frames: list[Image.Image],
    direction: str = "horizontal",
    frame_size: Optional[tuple] = None,
    pad: int = 0,
) -> tuple[Image.Image, dict]:
    """水平/垂直动画条带。"""
    if not frames:
        raise ValueError("frames 为空")
    fw, fh = frame_size or (max(f.width for f in frames), max(f.height for f in frames))
    n = len(frames)

    if direction == "horizontal":
        sw, sh = n * (fw + pad) - pad, fh
    else:
        sw, sh = fw, n * (fh + pad) - pad

    strip = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    meta = {"direction": direction, "frame_width": fw, "frame_height": fh,
            "pad": pad, "total_frames": n, "frames": []}

    for i, f in enumerate(frames):
        x = i * (fw + pad) if direction == "horizontal" else 0
        y = 0 if direction == "horizontal" else i * (fh + pad)
        f = _normalize(f, (fw, fh))
        strip.paste(f, (x, y), f if f.mode == "RGBA" else None)
        meta["frames"].append({"index": i, "name": f"frame_{i:04d}",
                                "x": x, "y": y, "width": fw, "height": fh})
    return strip, meta


def export_texture_atlas(
    frames: list[Image.Image],
    output_dir: str | Path,
    name: str = "atlas",
    cols: int = 0, rows: int = 0, pad: int = 1,
) -> dict:
    """导出纹理图集 PNG + JSON 元数据。"""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    sheet, meta = create_spritesheet(frames, cols=cols, rows=rows, pad=pad)
    sheet.save(output_dir / f"{name}.png", "PNG", optimize=True)
    meta.update({"atlas_name": f"{name}.png",
                 "atlas_size": {"width": sheet.width, "height": sheet.height}})
    with open(output_dir / f"{name}.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2, ensure_ascii=False)
    return {"atlas": str(output_dir / f"{name}.png"),
            "meta": str(output_dir / f"{name}.json"), "frames": meta}
