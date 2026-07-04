#!/usr/bin/env python3
"""
程序化生成 Whisper (静默场 / Sextuple Voice) 技能图标（T245 #162 第一半）。
第六个声波能力：静默场（constant 球 0.15s + 半径 50px + debuff 贴身）。
风格：Voxglass — Muted Mauve constant 球 + 2px 描边 + 球心亮点。
与 Pulse（圆环）/ Bind（向内螺旋）/ Cut（锋利斩）/ Echo（玻璃护盾）/
Wave（圆环扩散）形成视觉对比：
Whisper 强调"原地 constant 球 = 静默场"，色板集中在 Muted Mauve
（6 verb 唯一冷紫调，区别于 Wave 的 Pale Resonance 冷青白）。
尺寸：32x32（achievement notification 用）+ 64x64（HUD 与大厅缩略用）
"""

import math
from PIL import Image, ImageDraw

# 色板（与 STYLE_GUIDE.md 一致）
INK_NAVY = (8, 20, 38)
ARCHIVE_BLUE = (18, 51, 74)
GLASS_CYAN = (105, 199, 206)
PALE_RESONANCE = (183, 231, 221)
CORAL_PULSE = (232, 109, 90)
AMBER_VOICE = (242, 182, 110)
MUTED_VIOLET = (101, 80, 106)
MUTED_MAUVE = (200, 164, 216)   # #C8A4D8 — 6 verb Whisper 唯一冷紫调
WARM_PARCHMENT = (230, 213, 184)
DEEP_TEAL = (29, 101, 112)


def draw_whisper_icon(size: int = 32) -> Image.Image:
    """生成 Whisper 静默场 constant 球图标。

    视觉组成（从外到内）：
    1. 背景深海军蓝圆盘（与 5 verb 一致）
    2. 圆盘外圈：Glass Cyan 细环（6 verb 视觉组 6 个图标共享）
    3. constant 球外层：Muted Mauve 2px 描边 (与 whisper_vfx.gd SPHERE_RING 同款)
    4. constant 球内层：Muted Mauve 半透明柔光 (与 whisper_vfx.gd OUTER_FILL 同款)
    5. 球心亮点：Muted Mauve core dot (与 whisper_vfx.gd CORE_DOT 同款, 0.20×R)
    6. 边缘 Glass Cyan inner ring (与 Wave inner ring 镜像, 表"光在场" 静默感)
    """
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 1. 背景深海军蓝圆盘（与 5 verb 一致）
    bg_r = 15 * size // 32
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=(*INK_NAVY, 230))

    # 2. 圆盘外圈：Glass Cyan 细环（6 verb 视觉组共用）
    draw.ellipse(
        [cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r],
        outline=(*GLASS_CYAN, 220),
        width=1,
    )

    # 3. constant 球外层：Muted Mauve 2px 描边（与 whisper_vfx.gd SPHERE_RING 同款）
    sphere_r = 11 * size // 32
    draw.ellipse(
        [cx - sphere_r, cy - sphere_r, cx + sphere_r, cy + sphere_r],
        outline=(*MUTED_MAUVE, 230),
        width=2,
    )

    # 4. constant 球内层：Muted Mauve 半透明柔光（与 whisper_vfx.gd OUTER_FILL 同款）
    # 球内柔光 alpha=0.18 是 Whisper VFX 静态基线，图标用 0.32 略提亮（背景深，对比足）
    fill_r = sphere_r - 1
    draw.ellipse(
        [cx - fill_r, cy - fill_r, cx + fill_r, cy + fill_r],
        fill=(*MUTED_MAUVE, 80),
    )

    # 5. 球心亮点：Muted Mauve core dot（0.20×R, 与 whisper_vfx.gd CORE_DOT 同款）
    core_r = max(2, sphere_r // 5)
    draw.ellipse(
        [cx - core_r, cy - core_r, cx + core_r, cy + core_r],
        fill=(*MUTED_MAUVE, 255),
    )

    # 6. 中心暖白小点（与 5 verb 中心 "光在场" 钩子保持一致：
    #    Pulse 暖珊瑚 / Bind 暖琥珀 / Cut 暖琥珀 / Echo 暖琥珀 / Wave 暖琥珀
    #    / Whisper 暖白 = "debuff 贴身" 用 cold 之外的"光"作锚)
    # 暖白小点 alpha=200 微透，不抢主色
    hot_r = 1
    if size >= 32:
        draw.ellipse([cx - hot_r, cy - hot_r, cx + hot_r, cy + hot_r], fill=(255, 250, 240, 200))

    return img


if __name__ == "__main__":
    import os
    # 落地 1: res://assets/ui/achievements/whisper_icon/（成就通知路径）
    ach_dir = "/workspace/assets/ui/achievements/whisper_icon"
    os.makedirs(ach_dir, exist_ok=True)
    icon_32 = draw_whisper_icon(32)
    icon_32.save(f"{ach_dir}/whisper_icon.png")
    # 32x32 双导出（与 8 个旧成就 amber_dot/amber_shard/... 模式 1:1）
    icon_32.save(f"{ach_dir}/whisper_icon_32x32.png")
    print(f"Whisper icon (achievements) generated:")
    print(f"  - {ach_dir}/whisper_icon.png (32x32 base)")
    print(f"  - {ach_dir}/whisper_icon_32x32.png (32x32 显式 _32x32 子分辨率)")

    # 落地 2: res://assets/ui/whisper_icon/（5 verb 视觉组路径，HUB HUD 用）
    verb_dir = "/workspace/assets/ui/whisper_icon"
    os.makedirs(verb_dir, exist_ok=True)
    icon_32b = draw_whisper_icon(32)
    icon_32b.save(f"{verb_dir}/whisper_icon.png")
    icon_64 = draw_whisper_icon(64)
    icon_64.save(f"{verb_dir}/whisper_icon_64x64.png")
    print(f"Whisper icon (verb family) generated:")
    print(f"  - {verb_dir}/whisper_icon.png (32x32 base)")
    print(f"  - {verb_dir}/whisper_icon_64x64.png (64x64)")
