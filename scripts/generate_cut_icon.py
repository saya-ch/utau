#!/usr/bin/env python3
"""
程序化生成 Cut 技能图标。
风格：Voxglass — 水平斩击、锋利刀刃、珊瑚色锋线、切断感。
与 Pulse（圆环扩散）和 Bind（向内螺旋）形成视觉对比。
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


def draw_cut_icon(size: int = 32) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 背景深海军蓝圆盘
    bg_r = 15
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=(*INK_NAVY, 220))

    # 圆盘外圈：暗紫色细环，区别于 Pulse 图标
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], outline=(*MUTED_VIOLET, 180), width=1)

    # 主斩击：水平斜向下划线（贯穿圆盘），珊瑚色
    slash_y_top = cy - 8
    slash_y_bot = cy + 8
    slash_x_offset = 3  # 微微斜下
    slash_start = (cx - 11, slash_y_top - slash_x_offset)
    slash_end = (cx + 11, slash_y_bot - slash_x_offset)
    # 阴影（深色外缘）
    draw.line([slash_start, slash_end], fill=(*INK_NAVY, 200), width=4)
    # 主锋线（珊瑚色，锋利感）
    draw.line([slash_start, slash_end], fill=(*CORAL_PULSE, 240), width=2)
    # 刀刃高光（淡青色，最细 1px）
    mid_x1 = cx - 6
    mid_y1 = cy - 4 - 1
    mid_x2 = cx + 6
    mid_y2 = cy + 4 - 1
    draw.line([(mid_x1, mid_y1), (mid_x2, mid_y2)], fill=(*PALE_RESONANCE, 220), width=1)

    # 闪光点：斩击线两端和中央
    for px, py in [(cx - 10, cy - 7), (cx + 10, cy + 5), (cx, cy - 1)]:
        # 外层晕（暖琥珀）
        draw.ellipse([px - 2, py - 2, px + 2, py + 2], fill=(*AMBER_VOICE, 80))
        # 中心亮点（白热）
        draw.ellipse([px - 1, py - 1, px + 1, py + 1], fill=(*WARM_PARCHMENT, 255))

    # 上方第二斩击线：更短、更亮，表示连续切断
    sec_start = (cx - 8, cy - 12)
    sec_end = (cx + 6, cy - 6)
    draw.line([sec_start, sec_end], fill=(*PALE_RESONANCE, 180), width=1)

    # 下方第三斩击线：更短
    third_start = (cx - 6, cy + 6)
    third_end = (cx + 9, cy + 12)
    draw.line([third_start, third_end], fill=(*PALE_RESONANCE, 150), width=1)

    # 碎片装饰：四颗飞出的小三角形碎片
    fragments = [
        (cx - 13, cy - 3, 1),   # 左飞
        (cx + 13, cy - 5, -1),  # 右飞
        (cx - 5, cy - 14, 0),   # 上飞
        (cx + 4, cy + 14, 0),   # 下飞
    ]
    for fx, fy, fdir in fragments:
        size_frag = 2
        # 三角碎片
        if fdir == 0:
            # 上下方向
            points = [(fx, fy - size_frag), (fx - size_frag, fy + size_frag), (fx + size_frag, fy + size_frag)]
        elif fdir == 1:
            # 左
            points = [(fx - size_frag, fy), (fx + size_frag, fy - size_frag), (fx + size_frag, fy + size_frag)]
        else:
            # 右
            points = [(fx + size_frag, fy), (fx - size_frag, fy - size_frag), (fx - size_frag, fy + size_frag)]
        draw.polygon(points, fill=(*CORAL_PULSE, 200))
        # 描边
        draw.polygon(points, outline=(*PALE_RESONANCE, 220))

    return img


if __name__ == "__main__":
    out_dir = "/workspace/assets/ui/cut_icon"
    import os
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_cut_icon(32)
    icon.save(f"{out_dir}/cut_icon.png")

    # 同时生成 64x64 版本用于高 DPI
    icon_64 = draw_cut_icon(64)
    icon_64.save(f"{out_dir}/cut_icon_64x64.png")

    print(f"Cut icon generated:")
    print(f"  - {out_dir}/cut_icon.png (32x32)")
    print(f"  - {out_dir}/cut_icon_64x64.png (64x64)")
