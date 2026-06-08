#!/usr/bin/env python3
"""
程序化生成 Wave (Resonance Wave) 技能图标（T103 #74 第二半）。
第五个声波能力：群体波（短前摇 0.10s + 0.40s 扩散 + 0.30s 消散）。
风格：Voxglass — 圆环扩散波 + 8 棱镜光线 + 中心暖点。
与 Pulse（圆环扩散）/ Bind（向内螺旋）/ Cut（锋利斩）/ Echo（玻璃护盾）形成视觉对比：
Wave 强调"光波从中心向外扩散"，色板集中在 Pale Resonance 冷色（5 verb 最浅最冷=光波感）。
尺寸：32x32 / 64x64（符合 STYLE_GUIDE 图标规格）
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
WARM_PARCHMENT = (230, 213, 184)
DEEP_TEAL = (29, 101, 112)


def draw_wave_icon(size: int = 32) -> Image.Image:
    """生成 Wave 群体波扩散图标。

    视觉组成（从外到内）：
    1. 背景深海军蓝圆盘（与 Pulse/Bind/Cut/Echo 一致）
    2. 圆盘外圈：Glass Cyan 细环（5 动词视觉组 5 个图标共享）
    3. 内层 Pale Resonance 圆环 — 表达"扩散波"的中间波峰
    4. 8 方向棱镜光线 — 表达"光波从中心向四周辐射"
    5. 中心 Amber Voice 暖点 — 区别于 Pulse(Coral)/Bind(Violet)/Cut(Coral)/Echo(Cyan) 的中心色
    6. 半透明 Pale Resonance 内圆 — 表达"声波在场"
    """
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 1. 背景深海军蓝圆盘
    bg_r = 15
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=(*INK_NAVY, 230))

    # 2. 圆盘外圈：Glass Cyan 细环（5 动词视觉组共用）
    draw.ellipse(
        [cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r],
        outline=(*GLASS_CYAN, 220),
        width=1,
    )

    # 3. 内层 Pale Resonance 圆环 — "扩散波"中间波峰
    mid_r = 10
    draw.ellipse(
        [cx - mid_r, cy - mid_r, cx + mid_r, cy + mid_r],
        outline=(*PALE_RESONANCE, 240),
        width=1,
    )

    # 4. 8 方向棱镜光线（从中心向外辐射）
    ray_inner = 4
    ray_outer = 13
    for angle_deg in [0, 45, 90, 135, 180, 225, 270, 315]:
        a = math.radians(angle_deg)
        x1 = cx + int(ray_inner * math.cos(a))
        y1 = cy + int(ray_inner * math.sin(a))
        x2 = cx + int(ray_outer * math.cos(a))
        y2 = cy + int(ray_outer * math.sin(a))
        # 主光线：Pale Resonance 半透明
        draw.line(
            [(x1, y1), (x2, y2)], fill=(*PALE_RESONANCE, 200), width=1
        )

    # 5. 半透明 Pale Resonance 内圆 — 声波在场
    inner_r = 3
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        fill=(*PALE_RESONANCE, 90),
    )

    # 6. 中心 Amber Voice 暖点 — 与 Pulse(Coral)/Bind(Violet)/Cut(Coral)/Echo(Cyan) 区分
    # 5 动词主色：Pulse=Coral Bind=Violet Cut=Amber Echo=Cyan Wave=Pale
    # Wave 中心点选 Amber Voice 暖色作为"光从中心发出"的语义钩
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*AMBER_VOICE, 255))

    return img


if __name__ == "__main__":
    import os
    out_dir = "/workspace/assets/ui/wave_icon"
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_wave_icon(32)
    icon.save(f"{out_dir}/wave_icon.png")

    icon_64 = draw_wave_icon(64)
    icon_64.save(f"{out_dir}/wave_icon_64x64.png")

    print(f"Wave icon generated:")
    print(f"  - {out_dir}/wave_icon.png (32x32)")
    print(f"  - {out_dir}/wave_icon_64x64.png (64x64)")
