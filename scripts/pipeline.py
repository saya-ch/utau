"""
素材管线 — Agent 负责创作描述，管线处理机械工作。

用法:
    run_asset_pipeline("character", "pixel-art",
        "a dark elf assassin, silver hair, dual-wielding curved daggers...")
"""

import json, time, sys, random
from pathlib import Path
from PIL import Image

_self_dir = Path(__file__).resolve().parent
if str(_self_dir) not in sys.path:
    sys.path.insert(0, str(_self_dir.parent))

from scripts.pollinations import generate_image_pollinations
from scripts.postprocess import (
    remove_background, trim_to_content, fit_to_canvas,
    add_outline, flip_horizontal, validate_asset, multi_size_export,
)
from scripts.vision_eval import evaluate_asset
from scripts.animation import generate_shimmer_frames, create_action_frames
from scripts.spritesheet import create_animation_strip, export_texture_atlas

# ═══════════════════════════════════════════════════════════════
#  内部数据 — Agent 不需要关心
# ═══════════════════════════════════════════════════════════════

_STYLE = {
    "pixel-art":  ("flux-anime",  "pixel art, 16-bit, crisp pixels, no anti-aliasing, chunky outlines, limited color palette"),
    "anime":      ("flux-anime",  "anime style, cel shading, clean lineart, vibrant flat colors, screen tone shading"),
    "chibi":      ("flux-anime",  "chibi, super deformed, big head tiny body, kawaii, cute, chubby cheeks"),
    "realistic":  ("flux-realism","photorealistic, PBR materials, detailed texture, natural lighting, 8K"),
    "low-poly":   ("flux-3d",     "low poly 3D render, flat shading, geometric facets, toy-like proportions"),
    "isometric":  ("flux-3d",     "isometric view, 30-degree angle, tileable, clean edges, diorama style"),
    "hand-drawn": ("flux-pro",    "hand-drawn illustration, ink lines, watercolor texture, sketchy edges"),
    "cartoon":    ("flux-pro",    "cartoon style, bold outlines, exaggerated proportions, vibrant"),
    "gothic-dark":("flux-pro",    "gothic dark fantasy, moody atmosphere, chiaroscuro lighting, desaturated"),
    "cyberpunk":  ("flux-pro",    "cyberpunk, neon lights, high tech low life, rain-slicked surfaces"),
    "vector-flat":("flux-pro",    "flat vector art, minimalist, clean geometric shapes, solid colors, no gradients"),
    "painterly":  ("flux-pro",    "digital painting, visible brush strokes, atmospheric depth, soft edges"),
}

_TECH_SUFFIX = {
    "character":  "white background, game character sprite, front view, centered, full body, T-pose or neutral stance, no cropping",
    "monster":    "white background, game character sprite, front view, centered, full body, neutral stance, no cropping",
    "npc":        "white background, game character sprite, front view, centered, full body, neutral stance, no cropping",
    "item":       "white background, game item, centered, isolated, clean presentation, no shadows",
    "weapon":     "white background, game item, centered, isolated, clean presentation, no shadows",
    "armor":      "white background, game item, centered, isolated, clean presentation, no shadows",
    "icon":       "white background, game UI icon, centered, isolated, clean edges, readable at small size",
    "skill-icon": "white background, game UI icon, centered, isolated, clean edges, readable at small size",
    "ui-element": "game UI element, clean edges, centered, game interface ready",
    "dialog-box": "game UI element, clean edges, game interface ready",
    "background": "game background, wide landscape, parallax-ready, no UI, no characters, atmospheric depth",
    "tileset":    "seamless tileable texture, game tileset, top-down view, grid aligned, repeatable, no seams",
    "tile-single":"seamless tileable, game tile, top-down view, isolated, 64x64 grid aligned, repeatable, no seams",
    "effect":     "game visual effect sprite, black background, centered burst, animation-ready, clean alpha",
    "particle":   "game particle sprite, black background, centered, small, clean alpha, for particle system",
    "card":       "game card frame, fantasy card art, ornate border, centered composition, card game layout",
    "portrait":   "game character portrait, headshot, upper body, centered, expressive, clean background",
    "logo":       "game logo, typography, centered, clean edges, transparent-ready background, bold",
}

_TYPE_CFG = {
    "character":   {"anchor": "bottom-center", "fill": 0.85, "outline": 2, "flip": True,
                    "gen": (1024, 1024), "canvas": 512, "exports": [64, 128, 256, 512]},
    "monster":     {"anchor": "bottom-center", "fill": 0.80, "outline": 2, "flip": True,
                    "gen": (1024, 1024), "canvas": 512, "exports": [64, 128, 256, 512]},
    "npc":         {"anchor": "bottom-center", "fill": 0.85, "outline": 1, "flip": True,
                    "gen": (512, 512),   "canvas": 256, "exports": [64, 128, 256]},
    "item":        {"anchor": "center",        "fill": 0.90, "outline": 1, "flip": True,
                    "gen": (512, 512),   "canvas": 256, "exports": [32, 64, 128, 256]},
    "weapon":      {"anchor": "center",        "fill": 0.90, "outline": 1, "flip": True,
                    "gen": (1024, 512),  "canvas": (512, 256), "exports": [64, 128, 256, 512]},
    "armor":       {"anchor": "center",        "fill": 0.85, "outline": 1, "flip": False,
                    "gen": (512, 1024),  "canvas": (256, 512), "exports": [64, 128, 256]},
    "icon":        {"anchor": "center",        "fill": 0.95, "outline": 1, "flip": False,
                    "gen": (256, 256),   "canvas": 128, "exports": [32, 64, 128]},
    "skill-icon":  {"anchor": "center",        "fill": 0.95, "outline": 1, "flip": False,
                    "gen": (256, 256),   "canvas": 128, "exports": [32, 64, 128]},
    "ui-element":  {"anchor": "center",        "fill": None,  "outline": 0, "flip": False,
                    "gen": None,  "canvas": None, "exports": None},
    "dialog-box":  {"anchor": None,            "fill": None,  "outline": 0, "flip": False,
                    "gen": None,  "canvas": None, "exports": None},
    "background":  {"anchor": None,            "fill": None,  "outline": 0, "flip": False,
                    "gen": (1920, 1080), "canvas": None, "exports": [960, 1920]},
    "tileset":     {"anchor": None,            "fill": None,  "outline": 0, "flip": False,
                    "gen": (512, 512), "canvas": None, "exports": [256, 512]},
    "tile-single": {"anchor": "center",        "fill": 0.95, "outline": 0, "flip": False,
                    "gen": (128, 128), "canvas": 64, "exports": [32, 64]},
    "effect":      {"anchor": "center",        "fill": 0.90, "outline": 0, "flip": False,
                    "gen": (512, 512), "canvas": 256, "exports": [64, 128, 256]},
    "particle":    {"anchor": "center",        "fill": 0.90, "outline": 0, "flip": False,
                    "gen": (256, 256), "canvas": 128, "exports": [32, 64, 128]},
    "card":        {"anchor": "center",        "fill": 0.90, "outline": 2, "flip": False,
                    "gen": (750, 1050), "canvas": (750, 1050), "exports": [375, 750]},
    "portrait":    {"anchor": "center",        "fill": 0.90, "outline": 0, "flip": False,
                    "gen": (1024, 1536), "canvas": (512, 768), "exports": [256, 512]},
    "logo":        {"anchor": "center",        "fill": 0.85, "outline": 0, "flip": True,
                    "gen": (1024, 512), "canvas": (512, 256), "exports": [128, 256, 512]},
}

_NEGATIVE = (
    "blurry, low quality, jpeg artifacts, ugly, deformed, extra fingers, extra limbs, "
    "bad anatomy, disfigured, cropped, cut off, watermark, text, signature, logo, "
    "complex background, cluttered, grainy, noisy, oversaturated, overexposed, underexposed"
)


# ═══════════════════════════════════════════════════════════════
#  公开 API
# ═══════════════════════════════════════════════════════════════

def run_asset_pipeline(
    asset_type: str,
    style: str,
    subject: str,
    *,
    animation: str | None = None,
    num_frames: int = 8,
    seed: int | None = None,
    output_dir: str | Path = "output",
    no_proxy: bool = True,
    **overrides,  # 覆盖任意内部参数
) -> dict:
    """
    Agent 负责创作 subject，管线处理其余一切。

    subject 就是你对画面的完整描述（英文），自然语言，没有格式限制。
    光照、色调、氛围——直接写进 subject 里，不需要单独参数。

    例:
        run_asset_pipeline("character", "pixel-art",
            "a dark elf assassin in black leather, silver hair, dual daggers with purple poison,
             red glowing eyes, crouched and ready to strike, dim torchlight casting long shadows")

    想覆盖内部参数？直接传:
        run_asset_pipeline("item", "anime", "flaming sword",
            canvas=512, outline=3, fill_ratio=0.95, gen_size=(1024,1024))

    可覆盖: gen_size, canvas, exports, anchor, fill_ratio, outline, flip, style_base,
            negative, tech_suffix, intensity (shimmer), model (覆盖风格默认模型)
    """
    if seed is None:
        seed = random.randint(1, 99999)

    s = _STYLE.get(style)
    if not s:
        raise ValueError(f"未知风格: {style}。可选: {list(_STYLE.keys())}")
    model, style_base = s

    cfg = _TYPE_CFG.get(asset_type)
    if not cfg:
        raise ValueError(f"未知素材类型: {asset_type}。可选: {list(_TYPE_CFG.keys())}")

    # ── 所有内部参数均可通过 overrides 覆盖 ──
    model = overrides.pop("model", model)
    style_base = overrides.pop("style_base", style_base)
    gen_size = overrides.pop("gen_size", cfg["gen"])
    canvas = overrides.pop("canvas", cfg["canvas"])
    exports = overrides.pop("exports", cfg["exports"])
    anchor = overrides.pop("anchor", cfg["anchor"])
    fill = overrides.pop("fill_ratio", cfg["fill"]) if "fill_ratio" in overrides else cfg["fill"]
    outline_w_raw = overrides.pop("outline", None)
    if outline_w_raw is not None:
        outline_w = outline_w_raw
    elif style == "pixel-art":
        outline_w = 1
    else:
        outline_w = cfg["outline"]
    do_flip = overrides.pop("flip", cfg["flip"])
    is_pixel = (style == "pixel-art")
    shimmer_intensity = overrides.pop("intensity", None)

    # ── 组合 prompt：风格基座 + Agent 的创作 + 技术后缀 ──
    tech = overrides.pop("tech_suffix", _TECH_SUFFIX.get(asset_type, _TECH_SUFFIX["character"]))
    prompt = f"{style_base}, {subject}, {tech}"
    negative = overrides.pop("negative", _NEGATIVE)
    if style == "pixel-art":
        negative += ", smooth, anti-aliased, photorealistic, gradient, soft edges"
    elif style in ("anime", "chibi"):
        negative += ", realistic, photorealistic, 3D, painterly, rough sketch, messy lines"
    elif style == "realistic":
        negative += ", cartoon, anime, pixel art, stylized, illustration, painting"

    # ── 文件名 ──
    import re
    name = re.sub(r'[^a-z0-9]+', '_', subject.lower().strip())[:40]

    root = Path(output_dir) / name
    raw_dir, export_dir, anim_dir = root / "raw", root / "exports", root / "animation"
    for d in [raw_dir, export_dir, anim_dir]:
        d.mkdir(parents=True, exist_ok=True)

    report = {"name": name, "type": asset_type, "style": style, "status": "PENDING", "steps": []}
    current_seed = seed

    # ── 可覆盖的透传参数 ──
    pollinations_kw = {"quality": "hd", "enhance": False, "timeout": 120, "safe": False}
    for k in list(pollinations_kw.keys()):
        if k in overrides:
            pollinations_kw[k] = overrides.pop(k)
    postprocess_kw = {"rembg_method": "rembg"}
    for k in list(postprocess_kw.keys()):
        if k in overrides:
            postprocess_kw[k] = overrides.pop(k)
    spritesheet_kw = {"cols": None, "pad": 2}
    for k in list(spritesheet_kw.keys()):
        if k in overrides:
            spritesheet_kw[k] = overrides.pop(k)
    # 动画参数透传
    shimmer_kw = {}
    for k in ("brightness", "jitter", "hue_shift", "noise"):
        if k in overrides:
            shimmer_kw[k] = overrides.pop(k)
    custom_action_fn = overrides.pop("custom_action_fn", None)

    # ═══════════════════════════════════════
    #  生成 + 后处理 + L1（含重试）
    # ═══════════════════════════════════════
    for attempt in range(3):
        raw = raw_dir / f"{name}_s{current_seed}.png"
        if attempt > 0:
            time.sleep(8 + attempt * 4)

        try:
            generate_image_pollinations(
                prompt=prompt, negative_prompt=negative,
                width=gen_size[0], height=gen_size[1],
                model=model, seed=current_seed, no_proxy=no_proxy,
                save_path=str(raw),
                **pollinations_kw,
            )
        except Exception as e:
            err = str(e)
            report["steps"].append({"stage": "gen", "seed": current_seed, "attempt": attempt+1, "error": err[:200]})
            if "Queue full" in err or "x402" in err:
                current_seed += 1; time.sleep(15); continue
            if attempt < 2:
                current_seed += 1; continue
            report["status"] = "BLOCKED"
            report["error"] = f"Generation failed: {err[:200]}"
            return _finish(report, root, name)

        img = Image.open(raw).convert("RGBA")
        if asset_type not in ("background", "tileset"):
            img = remove_background(img, method=postprocess_kw["rembg_method"])
        if fill is not None:
            img = trim_to_content(img, padding=8)
            if canvas:
                cw, ch = (canvas, canvas) if isinstance(canvas, int) else canvas
                img = fit_to_canvas(img, canvas_size=(cw, ch), anchor=anchor, fill_ratio=fill)
        if outline_w > 0:
            img = add_outline(img, width=outline_w)

        v = validate_asset(img)
        report["steps"].append({"stage": "L1", "seed": current_seed, "attempt": attempt+1, **v})
        if v["ok"]:
            break
        current_seed += 1
    else:
        report["status"] = "BLOCKED"
        report["error"] = "L1 failed after 3 attempts"
        return _finish(report, root, name)

    # ═══════════════════════════════════════
    #  L2 — Agent 的预期 vs 实际
    # ═══════════════════════════════════════
    for l2a in range(2):
        vision = evaluate_asset(img, asset_type=asset_type, expectation=subject)
        report["steps"].append({
            "stage": "L2", "attempt": l2a+1,
            "model": vision.get("model_used", "?"),
            "scores": vision.get("scores", {}),
            "total": vision.get("total", 0),
            "threshold": vision.get("threshold", 14),
            "pass": vision.get("pass", False),
            "verdict": vision.get("verdict", ""),
            "description": vision.get("description", ""),
            "issues": vision.get("issues", []),
            "suggestions": vision.get("suggestions", ""),
        })

        if vision.get("pass") and vision.get("verdict", "KEEP") == "KEEP":
            break

        if l2a < 1:
            current_seed += 100
            retry_raw = raw_dir / f"{name}_s{current_seed}.png"
            try:
                generate_image_pollinations(
                    prompt=prompt.replace(style, f"{style} {style}"),
                    negative_prompt=negative,
                    width=gen_size[0], height=gen_size[1],
                    model=model, seed=current_seed, no_proxy=no_proxy,
                    save_path=str(retry_raw),
                    **pollinations_kw,
                )
                img = Image.open(retry_raw).convert("RGBA")
                if asset_type not in ("background", "tileset"):
                    img = remove_background(img, method=postprocess_kw["rembg_method"])
                if fill is not None:
                    img = trim_to_content(img, padding=8)
                    if canvas:
                        cw, ch = (canvas, canvas) if isinstance(canvas, int) else canvas
                        img = fit_to_canvas(img, canvas_size=(cw, ch), anchor=anchor, fill_ratio=fill)
                if outline_w > 0:
                    img = add_outline(img, width=outline_w)
                if not validate_asset(img)["ok"]:
                    continue
            except Exception:
                continue
    else:
        report["status"] = "UNCERTIFIED" if vision.get("error") else "REJECTED"
        report["l2"] = vision
        return _finish(report, root, name)

    report["status"] = "PASSED"
    report["l2"] = vision
    report["seed"] = current_seed

    # ── 保存 ──
    final = export_dir / f"{name}.png"
    img.save(final, "PNG", optimize=True)
    files = {"main": str(final)}

    if do_flip:
        fp = export_dir / f"{name}_flip.png"
        flip_horizontal(img).save(fp, "PNG", optimize=True)
        files["flip"] = str(fp)

    # ── 动画 ──
    if animation:
        if shimmer_intensity:
            intensity = shimmer_intensity
        elif animation in ("idle", "walk"):
            intensity = "subtle"
        else:
            intensity = "moderate"
        shimmer = generate_shimmer_frames(img, num_frames=num_frames,
                                          intensity=intensity, **shimmer_kw)
        action_frames = create_action_frames(shimmer, action=animation,
                                              custom_fn=custom_action_fn)
        for i, f in enumerate(action_frames):
            f.save(anim_dir / f"{name}_{animation}_{i:02d}.png", "PNG", optimize=True)
        _cols = spritesheet_kw.get("cols") or min(4, num_frames)
        _pad = spritesheet_kw.get("pad")
        atlas = export_texture_atlas(action_frames, anim_dir, name=f"{name}_{animation}_atlas",
                                     cols=_cols, pad=_pad)
        strip, _ = create_animation_strip(action_frames, direction="horizontal", pad=_pad)
        strip.save(anim_dir / f"{name}_{animation}_strip.png", "PNG", optimize=True)
        # GIF 预览
        gif_path = anim_dir / f"{name}_{animation}_preview.gif"
        _save_gif(action_frames, gif_path)
        files["animation"] = {"frames": len(action_frames), "atlas": atlas.get("atlas"),
                              "strip": str(anim_dir / f"{name}_{animation}_strip.png"),
                              "gif": str(gif_path)}

    # ── 多尺寸 ──
    if exports:
        rf = Image.NEAREST if is_pixel else Image.LANCZOS
        multi_size_export(img, name, export_dir, sizes=exports, resample=rf)
        if do_flip:
            flipped = Image.open(export_dir / f"{name}_flip.png")
            multi_size_export(flipped, f"{name}_flip", export_dir, sizes=exports, resample=rf)
        files["exports"] = {s: str(export_dir / f"{name}_{s}x{s}.png") for s in exports}

    return _finish(report, root, name, files)


def _save_gif(frames, path, duration=100):
    """将帧序列保存为 GIF 预览。"""
    if not frames:
        return
    gif_frames = []
    for f in frames:
        bg = Image.new("RGBA", f.size, (255, 255, 255, 255))
        bg.paste(f.convert("RGBA"), (0, 0), f.convert("RGBA"))
        gif_frames.append(bg.convert("P", palette=Image.ADAPTIVE))
    gif_frames[0].save(path, save_all=True, append_images=gif_frames[1:],
                       duration=duration, loop=0)


def _finish(report, root, name, files=None):
    report["files"] = files or {}
    rp = root / f"{name}_report.json"
    with open(rp, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False, default=str)
    report["report"] = str(rp)
    return report
