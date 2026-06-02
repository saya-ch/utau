"""
T013 素材生成 - 单文件版，直接调用 pollinations API
"""
import sys, json, time
from pathlib import Path
from PIL import Image
from io import BytesIO
import requests
from urllib.parse import quote

# 直接内联 API 调用，避免 import 问题
def gen_image(prompt, negative, width, height, model, seed, save_path, timeout=120):
    params = {
        "width": width, "height": height, "model": model,
        "quality": "hd", "seed": seed, "enhance": "false", "safe": "false",
    }
    if negative:
        params["negative_prompt"] = negative
    url = f"https://image.pollinations.ai/prompt/{quote(prompt)}"
    resp = requests.get(url, params=params, proxies={"http": None, "https": None}, timeout=timeout)
    if resp.status_code == 200:
        img = Image.open(BytesIO(resp.content))
        img.save(save_path)
        return img
    raise Exception(f"HTTP {resp.status_code}: {resp.text[:200]}")

# 简单去背景 + 居中
import numpy as np

def remove_bg(img):
    try:
        from rembg import remove, new_session
        sess = new_session("u2net")
        return remove(img.convert("RGB"), session=sess,
                      alpha_matting=True,
                      alpha_matting_foreground_threshold=240,
                      alpha_matting_background_threshold=10,
                      alpha_matting_erode_size=4).convert("RGBA")
    except Exception:
        # chroma fallback
        img = img.convert("RGBA")
        data = np.array(img, dtype=np.float32)
        h, w = data.shape[:2]
        edges = np.concatenate([
            data[0:3, :, :3].reshape(-1, 3), data[h-3:h, :, :3].reshape(-1, 3),
            data[:, 0:3, :3].reshape(-1, 3), data[:, w-3:w, :3].reshape(-1, 3),
        ])
        bg = np.median(edges, axis=0)
        diff = np.sqrt(np.sum((data[:, :, :3] - bg) ** 2, axis=2))
        alpha = np.clip(diff / 50 * 255, 0, 255).astype(np.uint8)
        from PIL import ImageFilter
        a_img = Image.fromarray(alpha, 'L').filter(ImageFilter.GaussianBlur(radius=1))
        data[:, :, 3] = np.array(a_img)
        return Image.fromarray(data.astype(np.uint8), 'RGBA')

def trim(img):
    if img.mode != "RGBA": img = img.convert("RGBA")
    alpha = np.array(img.split()[-1])
    ys, xs = np.where(alpha > 30)
    if len(ys) == 0: return img
    p = 8
    y1, y2 = max(0, ys.min()-p), min(img.height, ys.max()+p)
    x1, x2 = max(0, xs.min()-p), min(img.width, xs.max()+p)
    return img.crop((x1, y1, x2, y2))

def fit_canvas(img, size=64, anchor="center", fill=0.9):
    img = trim(img)
    scale = min(size * fill / img.width, size * fill / img.height, 1.0)
    nw, nh = max(1, int(img.width * scale)), max(1, int(img.height * scale))
    img = img.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    if anchor == "center":
        x, y = (size - nw) // 2, (size - nh) // 2
    elif anchor == "bottom-center":
        x = (size - nw) // 2; y = size - nh - 2
    else:
        x, y = (size - nw) // 2, 2
    canvas.paste(img, (x, y), img)
    return canvas

def add_outline(img, color=(0,0,0,255), width=1):
    if img.mode != "RGBA": img = img.convert("RGBA")
    alpha = np.array(img.split()[-1])
    mask = alpha > 30
    dilated = mask.copy()
    for _ in range(width):
        d = dilated
        dilated = d | np.roll(d, 1, 0) | np.roll(d, -1, 0) | np.roll(d, 1, 1) | np.roll(d, -1, 1)
    outline = dilated & (~mask)
    result = np.array(img)
    result[outline] = color
    return Image.fromarray(result, 'RGBA')

def validate(img):
    data = np.array(img.convert("RGBA"))
    alpha = data[:, :, 3]
    visible = alpha > 30
    ratio = float(np.mean(visible))
    issues = []
    if ratio < 0.01: issues.append("全透明")
    if ratio > 0.98: issues.append("未去背景")
    if np.any(visible):
        ys, xs = np.where(visible)
        offset = float(np.sqrt(((xs.mean()-img.width/2)/img.width)**2 + ((ys.mean()-img.height/2)/img.height)**2))
    else:
        offset = 0.0
    if offset > 0.3: issues.append(f"偏移{offset:.1%}")
    return {"ok": len(issues)==0, "issues": issues, "ratio": ratio, "offset": offset}

# ── 配置 ──
NEGATIVE = (
    "blurry, low quality, jpeg artifacts, ugly, deformed, extra fingers, extra limbs, "
    "bad anatomy, disfigured, cropped, cut off, watermark, text, signature, logo, "
    "complex background, cluttered, grainy, noisy, oversaturated, overexposed, underexposed, "
    "photorealistic, 3D render, smooth, anti-aliased, gradient, soft edges"
)

STYLE_BASE = "pixel art, 16-bit, crisp pixels, no anti-aliasing, chunky outlines, limited color palette"

OUTPUT = Path("/workspace/assets")

assets = [
    {
        "id": "A022", "name": "silence_mote", "type": "monster",
        "subject": (
            "silence mote enemy, small floating ink blob creature, 32x32 pixel sprite, "
            "torn fabric edges, tentacle-like wisps, single warm amber core eye, "
            "negative silhouette shape, deep ink navy body with muted violet corrosion edges, "
            "sparse glass cyan edge highlights, coral pulse warning glow when agitated, "
            "crisp readable silhouette for 2D platformer gameplay"
        ),
        "seed": 1022, "gen": (1024, 1024), "canvas": 64, "anchor": "bottom-center", "fill": 0.85,
        "outline": 1, "outdir": OUTPUT / "enemies" / "silence_mote",
    },
    {
        "id": "A023", "name": "voice_bell_broken", "type": "item",
        "subject": (
            "cracked glass voice bell, broken state, hanging bell-shaped glass vessel, "
            "deep fractures across surface, dim muted violet interior, "
            "glass cyan edge barely glowing, ink navy and muted teal palette, "
            "small 32x32 pixel game prop, crisp silhouette, isolated on white"
        ),
        "seed": 1023, "gen": (512, 512), "canvas": 64, "anchor": "center", "fill": 0.9,
        "outline": 1, "outdir": OUTPUT / "props" / "voice_bell_broken",
    },
    {
        "id": "A024", "name": "voice_bell_repaired", "type": "item",
        "subject": (
            "repaired glass voice bell, intact bell-shaped glass vessel, "
            "warm amber voice glow from within, glass cyan edges brightly lit, "
            "subtle waveform pattern inside, floating resonance particles, "
            "amber voice and pale resonance palette, small 32x32 pixel game prop, "
            "crisp silhouette, isolated on white"
        ),
        "seed": 1024, "gen": (512, 512), "canvas": 64, "anchor": "center", "fill": 0.9,
        "outline": 1, "outdir": OUTPUT / "props" / "voice_bell_repaired",
    },
    {
        "id": "A025", "name": "pulse_icon", "type": "skill-icon",
        "subject": (
            "Pulse ability icon, sound wave ripple ring, concentric circles expanding outward, "
            "coral pulse and amber voice center glow, glass cyan outer ring, "
            "deep ink navy background disc, 32x32 pixel UI icon, "
            "clean readable silhouette, game interface ready"
        ),
        "seed": 1025, "gen": (512, 512), "canvas": 64, "anchor": "center", "fill": 0.95,
        "outline": 0, "outdir": OUTPUT / "ui" / "pulse_icon",
    },
]

reports = []

for a in assets:
    print(f"\n[{a['id']}] {a['name']} ...")
    outdir = a["outdir"]
    outdir.mkdir(parents=True, exist_ok=True)

    seed = a["seed"]
    status = "PENDING"
    final_img = None
    error = None

    for attempt in range(3):
        raw_path = outdir / f"{a['name']}_s{seed}.png"
        try:
            print(f"  Attempt {attempt+1}, seed={seed} ...")
            prompt = f"{STYLE_BASE}, {a['subject']}, white background, game sprite, centered, isolated"
            img = gen_image(prompt, NEGATIVE, a["gen"][0], a["gen"][1], "flux-anime", seed, str(raw_path), timeout=120)

            # 后处理
            if a["type"] not in ("background", "tileset"):
                img = remove_bg(img)
            img = fit_canvas(img, size=a["canvas"], anchor=a["anchor"], fill=a["fill"])
            if a["outline"] > 0:
                img = add_outline(img, width=a["outline"])

            v = validate(img)
            print(f"  L1: ok={v['ok']}, ratio={v['ratio']:.2%}, offset={v['offset']:.2%}, issues={v['issues']}")

            if v["ok"]:
                final_img = img
                status = "PASSED"
                break
            else:
                seed += 1
        except Exception as e:
            print(f"  Error: {e}")
            error = str(e)[:200]
            seed += 1
            time.sleep(5)
    else:
        status = "BLOCKED"
        if error is None:
            error = "L1 failed after 3 attempts"

    # 保存
    if final_img:
        final_path = outdir / f"{a['name']}.png"
        final_img.save(final_path, "PNG", optimize=True)
        # 多尺寸导出
        for sz in [32, 64]:
            final_img.resize((sz, sz), Image.NEAREST).save(outdir / f"{a['name']}_{sz}x{sz}.png", "PNG", optimize=True)
        print(f"  Saved: {final_path}")
    else:
        final_path = None

    reports.append({
        "id": a["id"], "name": a["name"], "type": a["type"],
        "status": status, "seed": seed, "path": str(final_path) if final_path else None,
        "error": error,
    })

    # 间隔避免限流
    time.sleep(2)

# 汇总
print("\n" + "="*60)
print("T013 素材生成汇总")
print("="*60)
for r in reports:
    print(f"{r['id']} | {r['name']} | {r['type']} | {r['status']} | seed={r['seed']}")
    if r['path']:
        print(f"  └─ {r['path']}")
    if r['error']:
        print(f"  └─ ERROR: {r['error']}")

# 写报告
with open(OUTPUT / "t013_report.json", "w") as f:
    json.dump(reports, f, indent=2)
print(f"\n报告已保存: {OUTPUT / 't013_report.json'}")
