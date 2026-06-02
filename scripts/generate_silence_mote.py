#!/usr/bin/env python3
"""
程序化生成 Silence Mote 敌人精灵图。
风格：Voxglass — 墨团、撕裂布料、触须边缘、负形剪影、单暖色核心眼。
尺寸：32x32（符合 STYLE_GUIDE 小敌人规格）
"""

import math
import random
from PIL import Image, ImageDraw, ImageFilter

# 色板（来自 STYLE_GUIDE.md）
ABYSS_BLACK = (5, 7, 13)
INK_NAVY = (8, 20, 38)
MUTED_VIOLET = (101, 80, 106)
DEEP_TEAL = (29, 101, 112)
GLASS_CYAN = (105, 199, 206)
AMBER_VOICE = (242, 182, 110)
CORAL_PULSE = (232, 109, 90)

def draw_silence_mote(size: int = 32, seed: int = 1022) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 主体：不规则墨团，用多个重叠椭圆模拟
    body_color = INK_NAVY
    shadow_color = MUTED_VIOLET

    # 底层暗晕
    for _ in range(8):
        rx = rng.randint(6, 10)
        ry = rng.randint(5, 9)
        ox = rng.randint(-4, 4)
        oy = rng.randint(-3, 3)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*ABYSS_BLACK, 180)
        )

    # 中层主体
    for _ in range(6):
        rx = rng.randint(5, 8)
        ry = rng.randint(4, 7)
        ox = rng.randint(-3, 3)
        oy = rng.randint(-2, 2)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*body_color, 220)
        )

    # 撕裂边缘 / 触须：用细长三角形和短线条
    num_tendrils = rng.randint(5, 8)
    for i in range(num_tendrils):
        angle = (2 * math.pi * i / num_tendrils) + rng.uniform(-0.3, 0.3)
        length = rng.randint(6, 12)
        width = rng.randint(1, 3)
        # 触须起点（从主体边缘向外）
        start_r = rng.randint(4, 7)
        sx = cx + math.cos(angle) * start_r
        sy = cy + math.sin(angle) * start_r
        ex = cx + math.cos(angle) * (start_r + length)
        ey = cy + math.sin(angle) * (start_r + length)
        # 画触须为细线+小点
        draw.line([(sx, sy), (ex, ey)], fill=(*body_color, 200), width=width)
        # 末端小墨点
        draw.ellipse([ex-2, ey-2, ex+2, ey+2], fill=(*shadow_color, 160))

    # 核心眼：暖色单点，略微发光
    eye_radius = 2
    # 外晕
    draw.ellipse(
        [cx - eye_radius - 1, cy - eye_radius - 1, cx + eye_radius + 1, cy + eye_radius + 1],
        fill=(*CORAL_PULSE, 120)
    )
    # 核心
    draw.ellipse(
        [cx - eye_radius, cy - eye_radius, cx + eye_radius, cy + eye_radius],
        fill=(*AMBER_VOICE, 255)
    )
    # 高光点
    draw.ellipse([cx - 1, cy - 1, cx, cy], fill=(255, 255, 255, 200))

    # 轻微噪点增加像素质感
    pixels = img.load()
    for y in range(size):
        for x in range(size):
            r, g, b, a = pixels[x, y]
            if a > 0 and rng.random() < 0.05:
                noise = rng.randint(-8, 8)
                pixels[x, y] = (
                    max(0, min(255, r + noise)),
                    max(0, min(255, g + noise)),
                    max(0, min(255, b + noise)),
                    a
                )

    return img


def draw_silence_mote_purified(size: int = 32, seed: int = 1022) -> Image.Image:
    """净化版本：暖色调、向上飘散、半透明"""
    rng = random.Random(seed)
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 暖色主体
    for _ in range(6):
        rx = rng.randint(5, 8)
        ry = rng.randint(4, 7)
        ox = rng.randint(-3, 3)
        oy = rng.randint(-2, 2)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*AMBER_VOICE, 140)
        )

    # 飘散触须
    num_tendrils = rng.randint(5, 8)
    for i in range(num_tendrils):
        angle = (2 * math.pi * i / num_tendrils) + rng.uniform(-0.3, 0.3)
        length = rng.randint(6, 12)
        sx = cx + math.cos(angle) * 4
        sy = cy + math.sin(angle) * 4
        ex = cx + math.cos(angle) * (4 + length)
        ey = cy + math.sin(angle) * (4 + length)
        draw.line([(sx, sy), (ex, ey)], fill=(*CORAL_PULSE, 120), width=1)

    # 核心变为纯白微光
    draw.ellipse([cx-3, cy-3, cx+3, cy+3], fill=(255, 255, 255, 180))
    draw.ellipse([cx-1, cy-1, cx+1, cy+1], fill=(255, 255, 255, 255))

    return img


def draw_silence_mote_warning(size: int = 32, seed: int = 1022) -> Image.Image:
    """警告版本：珊瑚色闪烁"""
    rng = random.Random(seed)
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 珊瑚色主体
    for _ in range(6):
        rx = rng.randint(5, 8)
        ry = rng.randint(4, 7)
        ox = rng.randint(-3, 3)
        oy = rng.randint(-2, 2)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*CORAL_PULSE, 200)
        )

    num_tendrils = rng.randint(5, 8)
    for i in range(num_tendrils):
        angle = (2 * math.pi * i / num_tendrils) + rng.uniform(-0.3, 0.3)
        length = rng.randint(6, 12)
        sx = cx + math.cos(angle) * 4
        sy = cy + math.sin(angle) * 4
        ex = cx + math.cos(angle) * (4 + length)
        ey = cy + math.sin(angle) * (4 + length)
        draw.line([(sx, sy), (ex, ey)], fill=(*CORAL_PULSE, 180), width=2)

    # 核心眼更亮
    draw.ellipse([cx-3, cy-3, cx+3, cy+3], fill=(*AMBER_VOICE, 255))
    draw.ellipse([cx-1, cy-1, cx+1, cy+1], fill=(255, 255, 255, 255))

    return img


def create_spritesheet(frames: list, cell_size: int = 32) -> Image.Image:
    """将多帧拼成横向 spritesheet"""
    total_w = cell_size * len(frames)
    sheet = Image.new("RGBA", (total_w, cell_size), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * cell_size, 0))
    return sheet


if __name__ == "__main__":
    out_dir = "/workspace/assets/sprites"
    import os
    os.makedirs(out_dir, exist_ok=True)

    # 生成三种状态
    normal = draw_silence_mote(32, seed=1022)
    warning = draw_silence_mote_warning(32, seed=1022)
    purified = draw_silence_mote_purified(32, seed=1022)

    # 保存单帧
    normal.save(f"{out_dir}/silence_mote_normal.png")
    warning.save(f"{out_dir}/silence_mote_warning.png")
    purified.save(f"{out_dir}/silence_mote_purified.png")

    # 拼成 spritesheet（3 帧：正常 / 警告 / 净化）
    sheet = create_spritesheet([normal, warning, purified], 32)
    sheet.save(f"{out_dir}/silence_mote_spritesheet.png")

    print(f"Silence Mote sprites generated:")
    print(f"  - {out_dir}/silence_mote_normal.png")
    print(f"  - {out_dir}/silence_mote_warning.png")
    print(f"  - {out_dir}/silence_mote_purified.png")
    print(f"  - {out_dir}/silence_mote_spritesheet.png (96x32)")
