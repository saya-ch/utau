#!/usr/bin/env python3
"""
程序化生成 Pulse 技能图标。
风格：Voxglass — 声波圆环、玻璃裂纹、琥珀核心。
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
WARM_PARCHMENT = (230, 213, 184)


def draw_pulse_icon(size: int = 32) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 外环：玻璃青色圆环
    outer_r = 14
    inner_r = 11
    draw.ellipse([cx - outer_r, cy - outer_r, cx + outer_r, cy + outer_r], fill=(*GLASS_CYAN, 180))
    draw.ellipse([cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r], fill=(0, 0, 0, 0))

    # 内环：更亮的细环
    mid_r = 9
    draw.ellipse([cx - mid_r, cy - mid_r, cx + mid_r, cy + mid_r], outline=(*PALE_RESONANCE, 200), width=1)

    # 中心：琥珀核心 + 珊瑚脉冲点
    core_r = 4
    draw.ellipse([cx - core_r, cy - core_r, cx + core_r, cy + core_r], fill=(*AMBER_VOICE, 255))
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(*CORAL_PULSE, 255))
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(255, 255, 255, 255))

    # 波形弧线（从中心向外扩散的声波感）
    for i in range(4):
        angle_start = i * 90 + 20
        angle_end = angle_start + 50
        arc_r = 12
        # 手动绘制弧形上的点
        pts = []
        for a in range(angle_start, angle_end + 1, 5):
            rad = math.radians(a)
            px = cx + arc_r * math.cos(rad)
            py = cy + arc_r * math.sin(rad)
            pts.append((px, py))
        if len(pts) > 1:
            for j in range(len(pts) - 1):
                draw.line([pts[j], pts[j + 1]], fill=(*WARM_PARCHMENT, 160), width=1)

    # 四角小裂纹装饰
    cracks = [
        [(cx - 10, cy - 10), (cx - 7, cy - 8), (cx - 8, cy - 5)],
        [(cx + 10, cy - 10), (cx + 7, cy - 8), (cx + 8, cy - 5)],
        [(cx - 10, cy + 10), (cx - 7, cy + 8), (cx - 8, cy + 5)],
        [(cx + 10, cy + 10), (cx + 7, cy + 8), (cx + 8, cy + 5)],
    ]
    for crack in cracks:
        for j in range(len(crack) - 1):
            draw.line([crack[j], crack[j + 1]], fill=(*GLASS_CYAN, 140), width=1)

    return img


if __name__ == "__main__":
    out_dir = "/workspace/assets/sprites"
    import os
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_pulse_icon(32)
    icon.save(f"{out_dir}/pulse_icon.png")

    print(f"Pulse icon generated:")
    print(f"  - {out_dir}/pulse_icon.png (32x32)")
