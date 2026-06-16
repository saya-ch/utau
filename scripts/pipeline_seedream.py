#!/usr/bin/env python3
"""
Seedream 素材生成管线 — 将 byted-seedream-image-generate 接入 pipeline

核心能力：
1. 使用 Seedream 5.0 (doubao-seedream-5-0-260128) 作为主生成后端
2. 支持 Seedream 4.5 / 4.0 作为降级备选
3. 复用 postprocess.py 的抠图/裁剪/描边/多尺寸导出
4. 复用 pipeline.py 的 L2 视觉评估 (evaluate_asset)
5. 统一管理 seed（从 2000 开始，与旧系统 1001-1999 隔离）

与 pipeline.py 的差异：
- pipeline.py 走 Pollinations (flux-*) API，免费但风格偏差大
- pipeline_seedream.py 走 Seedream API（需 ARK_API_KEY），风格更统一、细节更精
- prompt 格式：英文 subject + 继承 STYLE_GUIDE 色板常量
- 尺寸策略：先生成 1024x1024 / 2048x2048 高清图，再下采样到游戏尺寸
- 底色策略：默认 "isolated on white background" 方便 rembg 抠图；
  若素材本身需要透明底，则用 "white background"；
  场景/背景类素材不需要抠图，直接用。

用法：
    from scripts.pipeline_seedream import run_seedream_pipeline
    result = run_seedream_pipeline(
        "monster", "pixel-art",
        "silence mote enemy, small floating ink blob...",
        seed=2001,
        output_dir="/workspace/assets/enemies/silence_mote",
        version="5.0",
    )
"""

import json
import os
import sys
import time
import random
import re
from pathlib import Path
from typing import Optional

from PIL import Image

_self_dir = Path(__file__).resolve().parent
if str(_self_dir) not in sys.path:
    sys.path.insert(0, str(_self_dir.parent))

# ── 复用 postprocess（抠图/裁剪/描边/校验/多尺寸导出） ──
from scripts.postprocess import (
    remove_background, trim_to_content, fit_to_canvas,
    add_outline, flip_horizontal, validate_asset, multi_size_export,
)

# ── 复用 animation + spritesheet（如果需要动画） ──
try:
    from scripts.animation import generate_shimmer_frames, create_action_frames
    from scripts.spritesheet import create_animation_strip, export_texture_atlas
    _ANIM_AVAILABLE = True
except Exception:
    _ANIM_AVAILABLE = False

# ── 复用 vision_eval 做 L2 视觉评估 ──
try:
    from scripts.vision_eval import evaluate_asset
    _VISION_AVAILABLE = True
except Exception:
    _VISION_AVAILABLE = False


# ═══════════════════════════════════════════════════════════════
#  Seedream 风格表（与 pipeline.py _STYLE 对应，但用 Seedream 关键词）
# ═══════════════════════════════════════════════════════════════

_STYLE = {
    "pixel-art":  ("pixel art style, 16-bit retro game sprite, chunky pixel outline, "
                   "limited color palette, no anti-aliasing, crisp pixel edges, "
                   "readable silhouette for 2D platformer gameplay"),
    "anime":      ("anime style illustration, cel-shaded, clean lineart, flat shading, "
                   "screen tone highlights, sharp silhouette"),
    "concept":    ("digital concept art, cinematic composition, moody atmospheric lighting, "
                   "highly detailed, professional game art quality"),
    "ui":         ("game UI element, flat design, clean edges, readable at small sizes, "
                   "pixel crisp lines, no anti-aliasing, isolated presentation"),
    "background": ("game environment background, wide landscape, atmospheric depth, "
                   "parallax-ready composition, no foreground characters, no UI"),
}

# ═══════════════════════════════════════════════════════════════
#  Seedream 类型配置表（与 pipeline.py _TYPE_CFG 对齐）
# ═══════════════════════════════════════════════════════════════

_TYPE_CFG = {
    # 角色/敌人/NPC：白底→抠图→下采样→描边
    "character":   {"anchor": "bottom-center", "fill": 0.85, "outline": 2, "flip": True,
                    "gen": (1024, 1024), "canvas": 512, "exports": [64, 128, 256, 512]},
    "monster":     {"anchor": "bottom-center", "fill": 0.80, "outline": 2, "flip": True,
                    "gen": (1024, 1024), "canvas": 512, "exports": [64, 128, 256, 512]},
    "npc":         {"anchor": "bottom-center", "fill": 0.85, "outline": 1, "flip": True,
                    "gen": (512, 512),   "canvas": 256, "exports": [64, 128, 256]},

    # 道具/图标/技能：白底→抠图→下采样→细描边
    "item":        {"anchor": "center",        "fill": 0.90, "outline": 1, "flip": True,
                    "gen": (512, 512),   "canvas": 256, "exports": [32, 64, 128, 256]},
    "icon":        {"anchor": "center",        "fill": 0.95, "outline": 1, "flip": False,
                    "gen": (512, 512),   "canvas": 128, "exports": [32, 64, 128]},
    "skill-icon":  {"anchor": "center",        "fill": 0.95, "outline": 1, "flip": False,
                    "gen": (512, 512),   "canvas": 128, "exports": [32, 64, 128]},
    "achievement": {"anchor": "center",        "fill": 0.95, "outline": 1, "flip": False,
                    "gen": (256, 256),   "canvas": 64,  "exports": [16, 32, 64]},

    # 场景/背景：不抠图，直接用
    "background":  {"anchor": None,            "fill": None, "outline": 0, "flip": False,
                    "gen": (1920, 1080), "canvas": None, "exports": [480, 960, 1920]},
    "tileset":     {"anchor": None,            "fill": None, "outline": 0, "flip": False,
                    "gen": (1024, 1024), "canvas": None, "exports": [128, 256, 512]},
    "capsule":     {"anchor": None,            "fill": None, "outline": 0, "flip": False,
                    "gen": (1200, 630),  "canvas": None, "exports": None},

    # 特效：黑底方便抠图
    "effect":      {"anchor": "center",        "fill": 0.90, "outline": 0, "flip": False,
                    "gen": (512, 512),   "canvas": 256, "exports": [64, 128, 256]},

    # 肖像：半长像
    "portrait":    {"anchor": "center",        "fill": 0.90, "outline": 0, "flip": False,
                    "gen": (1024, 1536), "canvas": (512, 768), "exports": [128, 256, 512]},
}

# ═══════════════════════════════════════════════════════════════
#  负提示词：Seedream 5.0 会理解
# ═══════════════════════════════════════════════════════════════

_NEGATIVE_BASE = (
    "no text, no watermark, no logo, no signature, no lettering, "
    "no blurry, no low quality, no jpeg artifacts, no grainy, no noisy, "
    "no photorealistic, no 3D render, no oversaturated, no overexposed"
)

_NEGATIVE_EXTRA = {
    "pixel-art":  "no smooth edges, no anti-aliasing, no gradient, no soft blurry lines",
    "anime":      "no realistic, no photorealistic, no 3D, no rough sketch, no messy lines",
    "concept":    "no watermark, no text overlay, no frame",
    "ui":         "no 3D, no bevel, no drop shadow, no glossy, no metallic reflection",
    "background": "no foreground character, no UI overlay, no text",
}

# ═══════════════════════════════════════════════════════════════
#  技术后缀（确保抠图+尺寸）
# ═══════════════════════════════════════════════════════════════

_TECH_SUFFIX = {
    "character":  "isolated on white background, full body, centered, clean silhouette, "
                   "high contrast between subject and background for easy background removal",
    "monster":    "isolated on white background, full body, centered, clean silhouette, "
                   "high contrast for background removal",
    "npc":        "isolated on white background, full body, centered, clean presentation, "
                   "high contrast for background removal",
    "item":       "isolated on pure white background, centered, single item, no shadows, "
                   "high contrast for easy background removal",
    "icon":       "isolated on pure white background, centered, single icon, clean edges, "
                   "readable at very small size, high contrast for easy background removal",
    "skill-icon": "isolated on pure white background, centered, single icon, clean edges, "
                   "readable at small size, high contrast for easy background removal",
    "achievement": "isolated on pure white background, centered, simple icon, clean edges, "
                    "readable at tiny size (16x16), high contrast for background removal",
    "background":  "no text, no watermark, no foreground character, no UI, atmospheric depth, "
                    "wide landscape composition, parallax-ready",
    "tileset":     "seamless tileable game environment texture, top-down view, grid-aligned, "
                    "repeatable with no visible seams, clean edges",
    "capsule":     "Steam store capsule-ready composition, clean composition, "
                    "no text, no watermark, no logo",
    "effect":      "isolated on pure black background, centered burst, animation-ready, "
                   "high contrast for alpha channel extraction",
    "portrait":    "headshot or upper body portrait, clean background, centered composition, "
                   "expressive face, high contrast",
}

# ═══════════════════════════════════════════════════════════════
#  Seedream API 封装（简化版，对应 scripts/seedream_image_generate.py）
# ═══════════════════════════════════════════════════════════════

_MODELS = {
    "4.0": "doubao-seedream-4-0-250828",
    "4.5": "doubao-seedream-4-5-251128",
    "5.0": "doubao-seedream-5-0-260128",
}

def _get_api_key() -> str:
    """获取 ARK API key。环境变量优先级：ARK_API_KEY > MODEL_IMAGE_API_KEY > MODEL_AGENT_API_KEY"""
    return (
        os.getenv("ARK_API_KEY")
        or os.getenv("MODEL_IMAGE_API_KEY")
        or os.getenv("MODEL_AGENT_API_KEY")
        or ""
    )

def _get_api_base() -> str:
    base = (
        os.getenv("ARK_BASE_URL")
        or os.getenv("MODEL_IMAGE_API_BASE")
        or "https://ark.cn-beijing.volces.com/api/v3"
    )
    return base.rstrip("/").replace("/api/coding/v3", "/api/v3")


def generate_image_seedream(
    prompt: str,
    width: int = 1024,
    height: int = 1024,
    version: str = "5.0",
    negative_prompt: str = "",
    timeout: int = 120,
    save_path: str = "output.png",
    seed: Optional[int] = None,
) -> str:
    """
    使用 Seedream API 生成单张图片。

    注意：Seedream 目前通过 httpx 直接请求 Ark Images API。
    返回保存的 PNG 路径。

    失败策略：
    - 若 API key 缺失 → 返回空字符串，由上层决定是否降级到 Pollinations
    - 若网络超时 → 重试 1 次，仍失败返回空字符串
    """
    api_key = _get_api_key()
    if not api_key:
        print(f"  [seedream] 跳过: ARK_API_KEY 未配置")
        return ""

    model = _MODELS.get(version, _MODELS["5.0"])

    # Seedream 的 size 参数是 "WxH" 字符串；也支持预设如 "1024x1024"
    size_str = f"{width}x{height}"

    body = {
        "model": model,
        "prompt": prompt,
        "size": size_str,
        "response_format": "url",
        "watermark": False,
    }
    if negative_prompt:
        # Seedream 部分版本支持 negative_prompt；若不支持也会被忽略，无报错
        body["negative_prompt"] = negative_prompt
    if seed is not None and seed > 0:
        body["seed"] = seed

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }

    import httpx

    last_err = None
    for attempt in range(2):
        try:
            response = httpx.post(
                f"{_get_api_base()}/images/generations",
                headers=headers,
                json=body,
                timeout=float(timeout),
            )
            if response.status_code != 200:
                last_err = f"HTTP {response.status_code}: {response.text[:300]}"
                time.sleep(3 + attempt * 2)
                continue

            data = response.json()
            # Seedream 标准返回：{"data": [{"url": "..."}]}
            url = None
            for item in data.get("data", []):
                url = item.get("url") or item.get("b64_json")
                if url:
                    break
            if not url:
                last_err = f"API 返回无图像: {json.dumps(data, ensure_ascii=False)[:200]}"
                time.sleep(2)
                continue

            # 下载图像（b64_json 或 url）
            if url.startswith("data:"):
                import base64
                raw = base64.b64decode(url.split(",", 1)[1])
            else:
                img_response = httpx.get(url, timeout=float(timeout))
                if img_response.status_code != 200:
                    last_err = f"图像下载失败: HTTP {img_response.status_code}"
                    time.sleep(2)
                    continue
                raw = img_response.content

            Path(save_path).parent.mkdir(parents=True, exist_ok=True)
            with open(save_path, "wb") as f:
                f.write(raw)

            # 验证可打开
            Image.open(save_path).convert("RGBA")
            return save_path

        except Exception as e:
            last_err = str(e)
            time.sleep(3 + attempt * 2)
            continue

    print(f"  [seedream] 生成失败: {last_err}")
    return ""


# ═══════════════════════════════════════════════════════════════
#  主公开 API
# ═══════════════════════════════════════════════════════════════

def run_seedream_pipeline(
    asset_type: str,
    style: str,
    subject: str,
    *,
    animation: Optional[str] = None,
    num_frames: int = 8,
    seed: Optional[int] = None,
    output_dir: str = "output",
    version: str = "5.0",
    fallback_to_pollinations: bool = True,
    **overrides,
) -> dict:
    """
    使用 Seedream 生成单张素材。流程：

        subject（英文描述）
          → 组合 prompt (style_base + subject + tech_suffix)
          → Seedream API 生成高清图
          → postprocess.remove_background (rembg 抠图)
          → trim_to_content
          → fit_to_canvas
          → add_outline
          → validate_asset (L1)
          → evaluate_asset (L2, 可选)
          → multi_size_export
          → [可选] shimmer animation frames + spritesheet

    参数：
        asset_type:  如 "character" / "monster" / "item" / "skill-icon" /
                    "background" / "capsule" / "achievement" / "effect" / "portrait"
        style:       "pixel-art" / "anime" / "concept" / "ui" / "background"
        subject:     画面内容自然语言描述（英文）

    可覆盖的内部参数（与 pipeline.py 兼容）：
        model, style_base, gen_size, canvas, exports, anchor, fill_ratio,
        outline, flip, tech_suffix, negative, intensity (shimmer),
        prompt_extra (追加到 prompt 末尾的自定义关键词)

    返回：
        dict: {name, type, style, status, seed, steps, files: {...}}
    """
    if seed is None:
        seed = random.randint(2000, 99999)

    style_base = _STYLE.get(style)
    if style_base is None:
        raise ValueError(f"未知风格: {style}。可选: {list(_STYLE.keys())}")

    cfg = _TYPE_CFG.get(asset_type)
    if cfg is None:
        raise ValueError(f"未知素材类型: {asset_type}。可选: {list(_TYPE_CFG.keys())}")

    # ── 内部参数 overrides 解析 ──
    model = overrides.pop("model", _MODELS.get(version, _MODELS["5.0"]))
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
    prompt_extra = overrides.pop("prompt_extra", "")

    # ── Prompt 组合 ──
    tech = overrides.pop("tech_suffix", _TECH_SUFFIX.get(asset_type, _TECH_SUFFIX["item"]))
    prompt = f"{style_base}, {subject}, {tech}"
    if prompt_extra:
        prompt = f"{prompt}, {prompt_extra}"
    negative = overrides.pop("negative", _NEGATIVE_BASE)
    style_neg = _NEGATIVE_EXTRA.get(style, "")
    if style_neg:
        negative = f"{negative}, {style_neg}"

    # ── 文件管理 ──
    name = re.sub(r'[^a-z0-9]+', '_', subject.lower().strip())[:40]
    root = Path(output_dir)
    raw_dir, export_dir, anim_dir = root / "raw", root / "exports", root / "animation"
    for d in [raw_dir, export_dir, anim_dir]:
        d.mkdir(parents=True, exist_ok=True)

    report = {
        "name": name, "type": asset_type, "style": style,
        "backend": "seedream", "model": model, "version": version,
        "status": "PENDING", "steps": [], "prompt": prompt, "negative_prompt": negative,
    }
    current_seed = seed

    # ═══════════════════════════════════
    #  L0: 生成 + 后处理（含重试3次）
    # ═══════════════════════════════════

    img = None
    for attempt in range(3):
        raw_path = raw_dir / f"{name}_s{current_seed}.png"
        if attempt > 0:
            time.sleep(8 + attempt * 4)

        # Seedream 生成
        generated_path = generate_image_seedream(
            prompt=prompt, negative_prompt=negative,
            width=gen_size[0], height=gen_size[1],
            version=version, seed=current_seed, timeout=120,
            save_path=str(raw_path),
        )

        # 若 Seedream 失败且允许降级，走 Pollinations 作为 fallback
        if not generated_path and fallback_to_pollinations:
            print(f"  [seedream] 降级到 Pollinations")
            try:
                from scripts.pollinations import generate_image_pollinations
                # 映射 style → Pollinations model
                pmodel_map = {
                    "pixel-art": "flux-anime", "anime": "flux-anime",
                    "concept": "flux-pro", "ui": "flux-pro",
                    "background": "flux-pro",
                }
                pmodel = pmodel_map.get(style, "flux-anime")
                generate_image_pollinations(
                    prompt=prompt, negative_prompt=negative,
                    width=gen_size[0], height=gen_size[1],
                    model=pmodel, seed=current_seed,
                    quality="hd", enhance=False, no_proxy=True,
                    save_path=str(raw_path),
                )
                report["backend"] = "pollinations-fallback"
            except Exception as e:
                err = str(e)
                report["steps"].append({"stage": "gen-fallback", "seed": current_seed,
                                         "attempt": attempt + 1, "error": err[:200]})
                if attempt < 2:
                    current_seed += 1
                    continue
                report["status"] = "BLOCKED"
                report["error"] = f"All backends failed: {err[:200]}"
                return _finish(report, root, name)
        elif not generated_path:
            err = "Seedream failed and fallback disabled"
            report["steps"].append({"stage": "gen", "seed": current_seed,
                                     "attempt": attempt + 1, "error": err})
            if attempt < 2:
                current_seed += 1
                continue
            report["status"] = "BLOCKED"
            report["error"] = err
            return _finish(report, root, name)

        # ── 后处理流程 ──
        try:
            img = Image.open(raw_path).convert("RGBA")
        except Exception as e:
            report["steps"].append({"stage": "open", "seed": current_seed,
                                     "attempt": attempt + 1, "error": str(e)[:200]})
            if attempt < 2:
                current_seed += 1
                continue
            report["status"] = "BLOCKED"
            report["error"] = f"Cannot open image: {e}"
            return _finish(report, root, name)

        # 抠图（background/tileset/capsule 不抠）
        if asset_type not in ("background", "tileset", "capsule"):
            try:
                img = remove_background(img, method="rembg")
            except Exception:
                # rembg 不可用时回退到 chroma key
                try:
                    img = remove_background(img, method="auto")
                except Exception as e2:
                    report["steps"].append({"stage": "rembg", "error": str(e2)[:200]})

        if fill is not None:
            img = trim_to_content(img, padding=8)
            if canvas:
                cw, ch = (canvas, canvas) if isinstance(canvas, int) else canvas
                img = fit_to_canvas(img, canvas_size=(cw, ch), anchor=anchor, fill_ratio=fill)
        if outline_w > 0:
            img = add_outline(img, width=outline_w)

        # L1 质检
        v = validate_asset(img)
        report["steps"].append({"stage": "L1", "seed": current_seed,
                                 "attempt": attempt + 1, **v})
        if v["ok"]:
            break
        current_seed += 1
    else:
        report["status"] = "BLOCKED"
        report["error"] = "L1 failed after 3 attempts"
        return _finish(report, root, name)

    # ═══════════════════════════════════
    #  L2: 视觉评估（2次机会）
    # ═══════════════════════════════════

    if _VISION_AVAILABLE:
        for l2a in range(2):
            vision = evaluate_asset(img, asset_type=asset_type, expectation=subject)
            report["steps"].append({
                "stage": "L2", "attempt": l2a + 1,
                "model": vision.get("model_used", "?"),
                "scores": vision.get("scores", {}),
                "total": vision.get("total", 0),
                "threshold": vision.get("threshold", 14),
                "pass": vision.get("pass", False),
                "verdict": vision.get("verdict", ""),
                "issues": vision.get("issues", []),
            })

            if vision.get("pass") and vision.get("verdict", "KEEP") == "KEEP":
                break

            if l2a < 1:
                # 重试：换 seed，用相同 prompt
                current_seed += 100
                retry_path = raw_dir / f"{name}_s{current_seed}.png"
                try:
                    p = generate_image_seedream(
                        prompt=prompt, negative_prompt=negative,
                        width=gen_size[0], height=gen_size[1],
                        version=version, seed=current_seed,
                        save_path=str(retry_path),
                    )
                    if not p and fallback_to_pollinations:
                        from scripts.pollinations import generate_image_pollinations
                        pmodel_map = {"pixel-art": "flux-anime", "anime": "flux-anime",
                                      "concept": "flux-pro", "ui": "flux-pro",
                                      "background": "flux-pro"}
                        generate_image_pollinations(
                            prompt=prompt, negative_prompt=negative,
                            width=gen_size[0], height=gen_size[1],
                            model=pmodel_map.get(style, "flux-anime"),
                            seed=current_seed, no_proxy=True,
                            save_path=str(retry_path),
                        )
                    img = Image.open(retry_path).convert("RGBA")
                    if asset_type not in ("background", "tileset", "capsule"):
                        img = remove_background(img, method="rembg")
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
            report["status"] = "REJECTED"
            report["l2"] = vision
            return _finish(report, root, name)
        report["l2"] = vision
    else:
        report["l2"] = {"skip_reason": "vision_eval unavailable"}

    report["status"] = "PASSED"
    report["seed"] = current_seed

    # ── 保存主图 ──
    final = export_dir / f"{name}.png"
    img.save(final, "PNG", optimize=True)
    files = {"main": str(final)}

    if do_flip:
        fp = export_dir / f"{name}_flip.png"
        flip_horizontal(img).save(fp, "PNG", optimize=True)
        files["flip"] = str(fp)

    # ── 动画（shimmer / custom） ──
    if animation and _ANIM_AVAILABLE:
        if shimmer_intensity:
            intensity = shimmer_intensity
        elif animation in ("idle", "walk"):
            intensity = "subtle"
        else:
            intensity = "moderate"
        try:
            shimmer = generate_shimmer_frames(img, num_frames=num_frames, intensity=intensity)
            action_frames = create_action_frames(shimmer, action=animation)
            for i, f in enumerate(action_frames):
                f.save(anim_dir / f"{name}_{animation}_{i:02d}.png", "PNG", optimize=True)
            atlas = export_texture_atlas(action_frames, anim_dir,
                                          name=f"{name}_{animation}_atlas",
                                          cols=min(4, num_frames), pad=2)
            strip, _ = create_animation_strip(action_frames, direction="horizontal", pad=2)
            strip.save(anim_dir / f"{name}_{animation}_strip.png", "PNG", optimize=True)
            # GIF 预览
            _save_gif(action_frames, anim_dir / f"{name}_{animation}_preview.gif")
            files["animation"] = {
                "frames": len(action_frames),
                "atlas": atlas.get("atlas"),
                "strip": str(anim_dir / f"{name}_{animation}_strip.png"),
                "gif": str(anim_dir / f"{name}_{animation}_preview.gif"),
            }
        except Exception as e:
            report["animation_error"] = str(e)

    # ── 多尺寸导出 ──
    if exports:
        rf = Image.NEAREST if is_pixel else Image.LANCZOS
        multi_size_export(img, name, export_dir, sizes=exports, resample=rf)
        if do_flip:
            try:
                flipped = Image.open(export_dir / f"{name}_flip.png")
                multi_size_export(flipped, f"{name}_flip", export_dir, sizes=exports, resample=rf)
            except Exception:
                pass
        files["exports"] = {s: str(export_dir / f"{name}_{s}x{s}.png") for s in exports}

    return _finish(report, root, name, files)


def _save_gif(frames, path, duration=100):
    """将帧序列保存为 GIF 预览"""
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
    rp = root / f"{name}_seedream_report.json"
    with open(rp, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False, default=str)
    report["report"] = str(rp)
    return report


# ═══════════════════════════════════════════════════════════════
#  便捷函数：根据素材 ID 生成标准 prompt
# ═══════════════════════════════════════════════════════════════

VOXGLASS_COLOR_HEX = (
    "ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, "
    "glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, "
    "coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8"
)

def voxglass_prompt(asset_type: str, subject_en: str) -> str:
    """
    生成标准 Voxglass 风格 prompt（英文，供 Seedream 输入）。
    用法：直接作为 run_seedream_pipeline 的 subject 参数传入。
    """
    return (
        f"Voxglass style — melancholic resonance, flooded underground voice archive, "
        f"cracked glass bells, living silence, warm waveform light. Color palette: "
        f"{VOXGLASS_COLOR_HEX}. Cold colors dominate 75%, warm accents 10%. "
        f"Subject: {subject_en}. Crisp readable silhouette, game-ready 2D asset."
    )
