#!/usr/bin/env python3
"""
程序化生成 Voice Bell（声匣）精灵图。
风格：Voxglass — 玻璃钟罩、裂纹、共鸣波形、修复前后状态变化。
尺寸：16x24（符合 STYLE_GUIDE 可交互物规格）
"""

import math
import random
from PIL import Image, ImageDraw

# 色板
ABYSS_BLACK = (5, 7, 13)
INK_NAVY = (8, 20, 38)
ARCHIVE_BLUE = (18, 51, 74)
DEEP_TEAL = (29, 101, 112)
GLASS_CYAN = (105, 199, 206)
PALE_RESONANCE = (183, 231, 221)
MUTED_VIOLET = (101, 80, 106)
CORAL_PULSE = (232, 109, 90)
AMBER_VOICE = (242, 182, 110)
WARM_PARCHMENT = (230, 213, 184)


def draw_voice_bell_broken(size: tuple = (16, 24), seed: int = 1023) -> Image.Image:
    """破损状态：暗淡、有裂纹、微光闪烁"""
    rng = random.Random(seed)
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = w // 2, h // 2

    # 钟罩外形：上圆下方
    bell_top = cy - h // 3
    bell_bottom = cy + h // 3
    bell_w = w - 2

    # 玻璃底色（暗淡）
    for y in range(bell_top, bell_bottom):
        alpha = int(60 + 40 * math.sin((y - bell_top) / (bell_bottom - bell_top) * math.pi))
        draw.line([(cx - bell_w // 2, y), (cx + bell_w // 2, y)], fill=(*ARCHIVE_BLUE, alpha))

    # 钟罩轮廓
    draw.arc([cx - bell_w // 2, bell_top - 4, cx + bell_w // 2, bell_top + 4], 0, 180, fill=(*GLASS_CYAN, 120), width=1)
    draw.line([(cx - bell_w // 2, bell_top), (cx - bell_w // 2, bell_bottom)], fill=(*GLASS_CYAN, 100), width=1)
    draw.line([(cx + bell_w // 2, bell_top), (cx + bell_w // 2, bell_bottom)], fill=(*GLASS_CYAN, 100), width=1)
    draw.line([(cx - bell_w // 2, bell_bottom), (cx + bell_w // 2, bell_bottom)], fill=(*GLASS_CYAN, 100), width=1)

    # 裂纹
    num_cracks = rng.randint(2, 4)
    for _ in range(num_cracks):
        sx = cx + rng.randint(-bell_w // 3, bell_w // 3)
        sy = bell_top + rng.randint(2, (bell_bottom - bell_top) // 2)
        ex = sx + rng.randint(-3, 3)
        ey = sy + rng.randint(3, 8)
        draw.line([(sx, sy), (ex, ey)], fill=(*PALE_RESONANCE, 160), width=1)
        # 裂纹分支
        if rng.random() < 0.5:
            bx = ex + rng.randint(-2, 2)
            by = ey + rng.randint(1, 3)
            draw.line([(ex, ey), (bx, by)], fill=(*PALE_RESONANCE, 120), width=1)

    # 暗淡核心
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(*MUTED_VIOLET, 180))
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*ABYSS_BLACK, 200))

    return img


def draw_voice_bell_repaired(size: tuple = (16, 24), seed: int = 1023) -> Image.Image:
    """修复后状态：暖色发光、波形环绕、明亮"""
    rng = random.Random(seed)
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = w // 2, h // 2

    bell_top = cy - h // 3
    bell_bottom = cy + h // 3
    bell_w = w - 2

    # 玻璃底色（暖色透光）
    for y in range(bell_top, bell_bottom):
        alpha = int(100 + 60 * math.sin((y - bell_top) / (bell_bottom - bell_top) * math.pi))
        draw.line([(cx - bell_w // 2, y), (cx + bell_w // 2, y)], fill=(*AMBER_VOICE, alpha // 2))

    # 钟罩轮廓（更亮）
    draw.arc([cx - bell_w // 2, bell_top - 4, cx + bell_w // 2, bell_top + 4], 0, 180, fill=(*AMBER_VOICE, 200), width=1)
    draw.line([(cx - bell_w // 2, bell_top), (cx - bell_w // 2, bell_bottom)], fill=(*AMBER_VOICE, 180), width=1)
    draw.line([(cx + bell_w // 2, bell_top), (cx + bell_w // 2, bell_bottom)], fill=(*AMBER_VOICE, 180), width=1)
    draw.line([(cx - bell_w // 2, bell_bottom), (cx + bell_w // 2, bell_bottom)], fill=(*AMBER_VOICE, 180), width=1)

    # 共鸣波形线（环绕钟罩）
    for i in range(3):
        wave_y = bell_top + 3 + i * 5
        wave_pts = []
        for x in range(cx - bell_w // 2 + 1, cx + bell_w // 2):
            wy = wave_y + int(1.5 * math.sin((x + i * 2) * 0.8))
            wave_pts.append((x, wy))
        if len(wave_pts) > 1:
            for j in range(len(wave_pts) - 1):
                draw.line([wave_pts[j], wave_pts[j + 1]], fill=(*WARM_PARCHMENT, 200), width=1)

    # 明亮核心
    draw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=(*AMBER_VOICE, 200))
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(*WARM_PARCHMENT, 255))
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(255, 255, 255, 255))

    return img


def create_spritesheet(frames: list, cell_size: tuple = (16, 24)) -> Image.Image:
    total_w = cell_size[0] * len(frames)
    sheet = Image.new("RGBA", (total_w, cell_size[1]), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * cell_size[0], 0))
    return sheet


if __name__ == "__main__":
    out_dir = "/workspace/assets/sprites"
    import os
    os.makedirs(out_dir, exist_ok=True)

    broken = draw_voice_bell_broken((16, 24), seed=1023)
    repaired = draw_voice_bell_repaired((16, 24), seed=1023)

    broken.save(f"{out_dir}/voice_bell_broken.png")
    repaired.save(f"{out_dir}/voice_bell_repaired.png")

    sheet = create_spritesheet([broken, repaired], (16, 24))
    sheet.save(f"{out_dir}/voice_bell_spritesheet.png")

    print(f"Voice Bell sprites generated:")
    print(f"  - {out_dir}/voice_bell_broken.png")
    print(f"  - {out_dir}/voice_bell_repaired.png")
    print(f"  - {out_dir}/voice_bell_spritesheet.png (32x24)")
