#!/usr/bin/env python3
"""
程序化生成 Echo 技能图标（T085 [候选] 第三个声波能力：护盾反弹）。
风格：Voxglass — 棱镜折射 + 反弹箭头 + 玻璃护盾。
与 Pulse（圆环扩散）、Bind（向内螺旋）、Cut（锋利斩）形成视觉对比：
Echo 强调"球形护盾 + 双向反射"，色板集中在 Glass Cyan / Pale Resonance
冷色系（与 Bind 的暗紫涡旋区分），反弹箭头用 Amber Voice 暖色点缀。
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


def draw_echo_icon(size: int = 32) -> Image.Image:
    """生成 Echo 护盾反弹图标。

    视觉组成（从外到内）：
    1. 背景深海军蓝圆盘（与 Pulse/Bind/Cut 一致）
    2. 圆盘外圈：Glass Cyan 细环（区别于 Pulse 的双色 / Bind 的暗紫 / Cut 的暗紫）
    3. 棱镜折射：Pale Resonance 十字 + X（4-8 方向）
    4. 护盾球体：Glass Cyan 大圆 + Pale Resonance 高光
    5. 反弹箭头：左右双向 Coral Pulse 箭头（表示"反弹"语义）
    6. 中心高光：Amber Voice 暖点（区别于 Pulse 的青/珊瑚双色）
    """
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 1. 背景深海军蓝圆盘
    bg_r = 15
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=(*INK_NAVY, 230))

    # 2. 圆盘外圈：Glass Cyan 细环
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], outline=(*GLASS_CYAN, 220), width=1)

    # 3. 棱镜折射 — 4 方向射线（北/东/南/西），从中心延伸到外圈
    # 用 Pale Resonance 表示光的折射
    ray_inner = 5
    ray_outer = 13
    for angle_deg in [0, 45, 90, 135, 180, 225, 270, 315]:
        a = math.radians(angle_deg)
        x1 = cx + int(ray_inner * math.cos(a))
        y1 = cy + int(ray_inner * math.sin(a))
        x2 = cx + int(ray_outer * math.cos(a))
        y2 = cy + int(ray_outer * math.sin(a))
        # 主光线
        draw.line([(x1, y1), (x2, y2)], fill=(*PALE_RESONANCE, 180), width=1)

    # 4. 护盾球体 — Glass Cyan 大圆，半透明（让中心点和棱镜能透出来）
    shield_r = 9
    draw.ellipse(
        [cx - shield_r, cy - shield_r, cx + shield_r, cy + shield_r],
        fill=(*GLASS_CYAN, 90),
        outline=(*GLASS_CYAN, 240),
        width=1,
    )

    # 护盾内部高光（左上 → 营造玻璃球面反射）
    hi_r = 4
    hi_cx = cx - 3
    hi_cy = cy - 3
    draw.ellipse(
        [hi_cx - hi_r, hi_cy - hi_r, hi_cx + hi_r, hi_cy + hi_r],
        fill=(*PALE_RESONANCE, 140),
    )
    # 高光小点
    draw.ellipse(
        [hi_cx - 1, hi_cy - 1, hi_cx + 1, hi_cy + 1],
        fill=(*WARM_PARCHMENT, 220),
    )

    # 5. 反弹箭头 — 左右双向 Coral Pulse（表达"反弹"语义）
    # 左箭头：从 (cx-7, cy) 指向 (cx-3, cy)，头部 V 形
    arrow_y = cy
    # 左箭头主体
    draw.line([(cx - 7, arrow_y), (cx - 3, arrow_y)], fill=(*CORAL_PULSE, 240), width=1)
    # 左箭头 V 头
    draw.line([(cx - 4, arrow_y - 1), (cx - 3, arrow_y)], fill=(*CORAL_PULSE, 240), width=1)
    draw.line([(cx - 4, arrow_y + 1), (cx - 3, arrow_y)], fill=(*CORAL_PULSE, 240), width=1)
    # 右箭头主体
    draw.line([(cx + 3, arrow_y), (cx + 7, arrow_y)], fill=(*CORAL_PULSE, 240), width=1)
    # 右箭头 V 头
    draw.line([(cx + 4, arrow_y - 1), (cx + 3, arrow_y)], fill=(*CORAL_PULSE, 240), width=1)
    draw.line([(cx + 4, arrow_y + 1), (cx + 3, arrow_y)], fill=(*CORAL_PULSE, 240), width=1)

    # 6. 中心暖点 — Amber Voice（与其他三动词图标区分色板归属）
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*AMBER_VOICE, 255))

    return img


if __name__ == "__main__":
    import os
    out_dir = "/workspace/assets/ui/echo_icon"
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_echo_icon(32)
    icon.save(f"{out_dir}/echo_icon.png")

    icon_64 = draw_echo_icon(64)
    icon_64.save(f"{out_dir}/echo_icon_64x64.png")

    print(f"Echo icon generated:")
    print(f"  - {out_dir}/echo_icon.png (32x32)")
    print(f"  - {out_dir}/echo_icon_64x64.png (64x64)")
