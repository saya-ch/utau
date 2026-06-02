#!/usr/bin/env python3
"""
程序化生成 Bind 技能图标。
风格：Voxglass — 向内螺旋、牵引、暗紫涡旋、玻璃裂纹。
尺寸：32x32（符合 STYLE_GUIDE 图标规格）
"""

import math
from PIL import Image, ImageDraw

# 色板
INK_NAVY = (8, 20, 38)
GLASS_CYAN = (105, 199, 206)
PALE_RESONANCE = (183, 231, 221)
CORAL_PULSE = (232, 109, 90)
AMBER_VOICE = (242, 182, 110)
MUTED_VIOLET = (101, 80, 106)
WARM_PARCHMENT = (230, 213, 184)


def draw_bind_icon(size: int = 32) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 背景暗紫圆盘
    bg_r = 15
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=(*MUTED_VIOLET, 160))

    # 向内螺旋线（2.5圈）
    spiral_segments = 64
    spiral_turns = 2.5
    spiral_pts = []
    for i in range(spiral_segments + 1):
        t = i / spiral_segments
        angle = t * spiral_turns * 2 * math.pi
        r = bg_r * 0.85 * (1.0 - t * 0.8)
        px = cx + r * math.cos(angle)
        py = cy + r * math.sin(angle)
        spiral_pts.append((px, py))

    for j in range(len(spiral_pts) - 1):
        alpha = int(200 * (1.0 - j / len(spiral_pts)))
        draw.line([spiral_pts[j], spiral_pts[j + 1]], fill=(*PALE_RESONANCE, alpha), width=2)

    # 同心收缩环（3个）
    for i in range(3):
        ring_r = 12 - i * 4
        if ring_r <= 0:
            continue
        alpha = 180 - i * 50
        draw.ellipse([cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r], outline=(*GLASS_CYAN, alpha), width=1)

    # 中心暗紫涡旋核
    core_r = 4
    draw.ellipse([cx - core_r, cy - core_r, cx + core_r, cy + core_r], fill=(*MUTED_VIOLET, 220))
    # 核内小亮点
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*AMBER_VOICE, 255))

    # 四角向内箭头装饰
    arrow_len = 4
    arrows = [
        # 左上
        [(cx - 10, cy - 10), (cx - 10 + arrow_len, cy - 10), (cx - 10, cy - 10 + arrow_len)],
        # 右上
        [(cx + 10, cy - 10), (cx + 10 - arrow_len, cy - 10), (cx + 10, cy - 10 + arrow_len)],
        # 左下
        [(cx - 10, cy + 10), (cx - 10 + arrow_len, cy + 10), (cx - 10, cy + 10 - arrow_len)],
        # 右下
        [(cx + 10, cy + 10), (cx + 10 - arrow_len, cy + 10), (cx + 10, cy + 10 - arrow_len)],
    ]
    for arrow in arrows:
        draw.line([arrow[0], arrow[1]], fill=(*CORAL_PULSE, 180), width=1)
        draw.line([arrow[0], arrow[2]], fill=(*CORAL_PULSE, 180), width=1)

    return img


if __name__ == "__main__":
    out_dir = "/workspace/assets/ui/bind_icon"
    import os
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_bind_icon(32)
    icon.save(f"{out_dir}/bind_icon.png")

    # 同时生成 64x64 版本用于高 DPI
    icon_64 = draw_bind_icon(64)
    icon_64.save(f"{out_dir}/bind_icon_64x64.png")

    print(f"Bind icon generated:")
    print(f"  - {out_dir}/bind_icon.png (32x32)")
    print(f"  - {out_dir}/bind_icon_64x64.png (64x64)")
