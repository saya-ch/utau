#!/usr/bin/env python3
"""
程序化绘制 InkWarden 精英敌人精灵
风格：Voxglass pixel art — 深墨蓝、大型墨团、护盾裂纹、单眼、触须披风
尺寸：64x96（符合 STYLE_GUIDE 精英敌人规格）
"""

from PIL import Image, ImageDraw
import math
import random
import os

# Voxglass 色板
COLORS = {
    "abyss": (5, 7, 13),
    "ink_navy": (8, 20, 38),
    "archive_blue": (18, 51, 74),
    "deep_teal": (29, 101, 112),
    "glass_cyan": (105, 199, 206),
    "pale_resonance": (183, 231, 221),
    "muted_violet": (101, 80, 106),
    "coral_pulse": (232, 109, 90),
    "amber_voice": (242, 182, 110),
    "warm_parchment": (230, 213, 184),
}


def draw_inkwarden(size_w: int = 64, size_h: int = 96, seed: int = 1030) -> Image.Image:
    """绘制 InkWarden 基础帧。"""
    rng = random.Random(seed)
    img = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size_w // 2, size_h // 2 + 8

    body_color = COLORS["ink_navy"]
    shadow_color = COLORS["muted_violet"]
    highlight = COLORS["glass_cyan"]

    # 底层暗晕（比 SilenceMote 更大）
    for _ in range(12):
        rx = rng.randint(10, 18)
        ry = rng.randint(12, 22)
        ox = rng.randint(-8, 8)
        oy = rng.randint(-10, 10)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*COLORS["abyss"], 180)
        )

    # 中层主体
    for _ in range(10):
        rx = rng.randint(8, 14)
        ry = rng.randint(10, 18)
        ox = rng.randint(-6, 6)
        oy = rng.randint(-8, 8)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*body_color, 230)
        )

    # 撕裂边缘 / 触须披风（更长更粗）
    num_tendrils = rng.randint(8, 12)
    for i in range(num_tendrils):
        angle = (2 * math.pi * i / num_tendrils) + rng.uniform(-0.3, 0.3)
        length = rng.randint(16, 28)
        width = rng.randint(2, 4)
        start_r = rng.randint(10, 16)
        sx = cx + math.cos(angle) * start_r
        sy = cy + math.sin(angle) * start_r
        ex = cx + math.cos(angle) * (start_r + length)
        ey = cy + math.sin(angle) * (start_r + length)
        draw.line([(sx, sy), (ex, ey)], fill=(*body_color, 200), width=width)
        # 末端墨点
        draw.ellipse([ex-3, ey-3, ex+3, ey+3], fill=(*shadow_color, 160))

    # 护盾裂纹（玻璃青色线条，覆盖在身体上）
    for _ in range(5):
        sx = cx + rng.randint(-12, 12)
        sy = cy + rng.randint(-18, 10)
        points = [(sx, sy)]
        for _ in range(3):
            points.append((points[-1][0] + rng.randint(-6, 6), points[-1][1] + rng.randint(-6, 6)))
        for i in range(len(points) - 1):
            draw.line([points[i], points[i+1]], fill=highlight, width=1)

    # 核心眼：大型琥珀色发光眼（精英敌人更大更亮）
    eye_cx, eye_cy = cx + rng.randint(-2, 2), cy - 8
    # 外晕
    draw.ellipse([eye_cx - 6, eye_cy - 6, eye_cx + 6, eye_cy + 6], fill=(*COLORS["coral_pulse"][:3], 100))
    # 核心
    draw.ellipse([eye_cx - 3, eye_cy - 3, eye_cx + 3, eye_cy + 3], fill=COLORS["amber_voice"])
    # 高光点
    draw.ellipse([eye_cx - 1, eye_cy - 1, eye_cx, eye_cy], fill=COLORS["warm_parchment"])

    # 玻璃青色边缘高光（顶部和肩部）
    draw.arc([cx - 14, cy - 24, cx + 10, cy + 4], start=200, end=340, fill=highlight, width=1)

    # 1px 黑色描边增强可读性
    outline = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    outline_draw = ImageDraw.Draw(outline)
    for y in range(size_h):
        for x in range(size_w):
            r, g, b, a = img.getpixel((x, y))
            if a > 128:
                for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < size_w and 0 <= ny < size_h:
                        nr, ng, nb, na = outline.getpixel((nx, ny))
                        if na < 128:
                            outline_draw.point((nx, ny), fill=(0, 0, 0, 255))

    composite = Image.alpha_composite(outline, img)
    return composite


def draw_inkwarden_shield_broken(size_w: int = 64, size_h: int = 96, seed: int = 1030) -> Image.Image:
    """护盾破损状态：裂纹更多、颜色偏珊瑚、眼更亮。"""
    base = draw_inkwarden(size_w, size_h, seed).copy()
    draw = ImageDraw.Draw(base)
    cx, cy = size_w // 2, size_h // 2 + 8

    # 增加珊瑚色裂纹
    rng = random.Random(seed + 1)
    for _ in range(8):
        sx = cx + rng.randint(-14, 14)
        sy = cy + rng.randint(-20, 12)
        points = [(sx, sy)]
        for _ in range(4):
            points.append((points[-1][0] + rng.randint(-8, 8), points[-1][1] + rng.randint(-8, 8)))
        for i in range(len(points) - 1):
            draw.line([points[i], points[i+1]], fill=COLORS["coral_pulse"], width=2)

    # 眼更亮更大
    eye_cx, eye_cy = cx, cy - 8
    draw.ellipse([eye_cx - 8, eye_cy - 8, eye_cx + 8, eye_cy + 8], fill=(*COLORS["coral_pulse"][:3], 140))
    draw.ellipse([eye_cx - 4, eye_cy - 4, eye_cx + 4, eye_cy + 4], fill=COLORS["amber_voice"])
    draw.ellipse([eye_cx - 2, eye_cy - 2, eye_cx, eye_cy], fill=COLORS["warm_parchment"])

    return base


def draw_inkwarden_stunned(size_w: int = 64, size_h: int = 96, seed: int = 1030) -> Image.Image:
    """眩晕状态：身体变淡紫、眼呈 X 形、触须下垂。"""
    rng = random.Random(seed)
    img = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size_w // 2, size_h // 2 + 12  # 略低，表示下沉

    body_color = COLORS["muted_violet"]

    # 主体（更淡）
    for _ in range(8):
        rx = rng.randint(8, 14)
        ry = rng.randint(10, 18)
        ox = rng.randint(-6, 6)
        oy = rng.randint(-4, 4)
        draw.ellipse(
            [cx - rx + ox, cy - ry + oy, cx + rx + ox, cy + ry + oy],
            fill=(*body_color, 180)
        )

    # 下垂触须
    num_tendrils = 8
    for i in range(num_tendrils):
        angle = (2 * math.pi * i / num_tendrils) + rng.uniform(-0.3, 0.3)
        length = rng.randint(10, 18)
        start_r = rng.randint(8, 12)
        sx = cx + math.cos(angle) * start_r
        sy = cy + math.sin(angle) * start_r
        # 下垂：y 增加更多
        ex = sx + rng.randint(-4, 4)
        ey = sy + length
        draw.line([(sx, sy), (ex, ey)], fill=(*body_color, 150), width=2)

    # X 形眼（眩晕）
    eye_cx, eye_cy = cx, cy - 8
    draw.line([(eye_cx-4, eye_cy-4), (eye_cx+4, eye_cy+4)], fill=COLORS["glass_cyan"], width=2)
    draw.line([(eye_cx+4, eye_cy-4), (eye_cx-4, eye_cy+4)], fill=COLORS["glass_cyan"], width=2)

    # 描边
    outline = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    outline_draw = ImageDraw.Draw(outline)
    for y in range(size_h):
        for x in range(size_w):
            r, g, b, a = img.getpixel((x, y))
            if a > 128:
                for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < size_w and 0 <= ny < size_h:
                        nr, ng, nb, na = outline.getpixel((nx, ny))
                        if na < 128:
                            outline_draw.point((nx, ny), fill=(0, 0, 0, 255))

    return Image.alpha_composite(outline, img)


def create_spritesheet(frames, cell_w: int = 64, cell_h: int = 96) -> Image.Image:
    """水平拼接为 spritesheet。"""
    sheet = Image.new("RGBA", (cell_w * len(frames), cell_h), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * cell_w, 0))
    return sheet


if __name__ == "__main__":
    out_dir = "assets/enemies/ink_warden"
    os.makedirs(out_dir, exist_ok=True)

    # 三种状态
    normal = draw_inkwarden(64, 96, seed=1030)
    shield_broken = draw_inkwarden_shield_broken(64, 96, seed=1030)
    stunned = draw_inkwarden_stunned(64, 96, seed=1030)

    # 保存单帧
    normal.save(os.path.join(out_dir, "ink_warden.png"))
    shield_broken.save(os.path.join(out_dir, "ink_warden_shield_broken.png"))
    stunned.save(os.path.join(out_dir, "ink_warden_stunned.png"))

    # 拼成 spritesheet（3 帧：正常 / 破盾 / 眩晕）
    sheet = create_spritesheet([normal, shield_broken, stunned], 64, 96)
    sheet.save(os.path.join(out_dir, "ink_warden_spritesheet.png"))

    print(f"InkWarden assets saved to {out_dir}/")
    print(f"  ink_warden.png — 64x96 base frame")
    print(f"  ink_warden_shield_broken.png — 64x96 shield broken")
    print(f"  ink_warden_stunned.png — 64x96 stunned")
    print(f"  ink_warden_spritesheet.png — 192x96, 3 frames")
