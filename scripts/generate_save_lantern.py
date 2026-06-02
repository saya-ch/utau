#!/usr/bin/env python3
"""
程序化生成 Save Lantern（存档灯笼）精灵图。
风格：Voxglass — 玻璃钟罩灯笼、共鸣核心、激活前后状态变化。
尺寸：24x32（符合 STYLE_GUIDE 可交互物规格）
"""

import math
import random
from PIL import Image, ImageDraw

# Voxglass 色板
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


def draw_save_lantern_dim(size: tuple = (24, 32), seed: int = 1029) -> Image.Image:
    """未激活状态：暗淡、微光、沉睡"""
    rng = random.Random(seed)
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = w // 2, h // 2 + 2

    # 灯笼挂钩
    draw.arc([cx - 2, 0, cx + 2, 6], 0, 180, fill=(*MUTED_VIOLET, 160), width=1)
    draw.line([(cx, 3), (cx, 6)], fill=(*MUTED_VIOLET, 160), width=1)

    # 灯笼主体：玻璃钟罩形状
    lantern_top = 7
    lantern_bottom = h - 3
    lantern_w = w - 6

    # 玻璃底色（暗淡紫）
    for y in range(lantern_top, lantern_bottom):
        alpha = int(40 + 30 * math.sin((y - lantern_top) / (lantern_bottom - lantern_top) * math.pi))
        draw.line([(cx - lantern_w // 2, y), (cx + lantern_w // 2, y)], fill=(*MUTED_VIOLET, alpha))

    # 钟罩轮廓
    draw.arc([cx - lantern_w // 2, lantern_top - 3, cx + lantern_w // 2, lantern_top + 3], 0, 180, fill=(*MUTED_VIOLET, 120), width=1)
    draw.line([(cx - lantern_w // 2, lantern_top), (cx - lantern_w // 2, lantern_bottom)], fill=(*MUTED_VIOLET, 100), width=1)
    draw.line([(cx + lantern_w // 2, lantern_top), (cx + lantern_w // 2, lantern_bottom)], fill=(*MUTED_VIOLET, 100), width=1)
    draw.line([(cx - lantern_w // 2, lantern_bottom), (cx + lantern_w // 2, lantern_bottom)], fill=(*MUTED_VIOLET, 100), width=1)

    # 底座
    draw.line([(cx - lantern_w // 2 - 1, lantern_bottom), (cx + lantern_w // 2 + 1, lantern_bottom)], fill=(*MUTED_VIOLET, 140), width=2)

    # 暗淡核心（几乎熄灭）
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(*MUTED_VIOLET, 100))
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*ABYSS_BLACK, 150))

    # 1px 黑色描边（游戏可读性）
    img = _add_black_outline(img)
    return img


def draw_save_lantern_lit(size: tuple = (24, 32), seed: int = 1029) -> Image.Image:
    """激活状态：暖琥珀光、波形环绕、明亮"""
    rng = random.Random(seed)
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = w // 2, h // 2 + 2

    # 灯笼挂钩
    draw.arc([cx - 2, 0, cx + 2, 6], 0, 180, fill=(*AMBER_VOICE, 200), width=1)
    draw.line([(cx, 3), (cx, 6)], fill=(*AMBER_VOICE, 200), width=1)

    # 灯笼主体：玻璃钟罩形状
    lantern_top = 7
    lantern_bottom = h - 3
    lantern_w = w - 6

    # 玻璃底色（暖色透光）
    for y in range(lantern_top, lantern_bottom):
        alpha = int(80 + 50 * math.sin((y - lantern_top) / (lantern_bottom - lantern_top) * math.pi))
        draw.line([(cx - lantern_w // 2, y), (cx + lantern_w // 2, y)], fill=(*AMBER_VOICE, alpha // 2))

    # 钟罩轮廓（亮青色 + 琥珀）
    draw.arc([cx - lantern_w // 2, lantern_top - 3, cx + lantern_w // 2, lantern_top + 3], 0, 180, fill=(*GLASS_CYAN, 200), width=1)
    draw.line([(cx - lantern_w // 2, lantern_top), (cx - lantern_w // 2, lantern_bottom)], fill=(*GLASS_CYAN, 180), width=1)
    draw.line([(cx + lantern_w // 2, lantern_top), (cx + lantern_w // 2, lantern_bottom)], fill=(*GLASS_CYAN, 180), width=1)
    draw.line([(cx - lantern_w // 2, lantern_bottom), (cx + lantern_w // 2, lantern_bottom)], fill=(*GLASS_CYAN, 180), width=1)

    # 底座
    draw.line([(cx - lantern_w // 2 - 1, lantern_bottom), (cx + lantern_w // 2 + 1, lantern_bottom)], fill=(*AMBER_VOICE, 200), width=2)

    # 共鸣波形线（环绕灯笼）
    for i in range(2):
        wave_y = lantern_top + 4 + i * 6
        wave_pts = []
        for x in range(cx - lantern_w // 2 + 1, cx + lantern_w // 2):
            wy = wave_y + int(1.2 * math.sin((x + i * 3) * 0.7))
            wave_pts.append((x, wy))
        if len(wave_pts) > 1:
            for j in range(len(wave_pts) - 1):
                draw.line([wave_pts[j], wave_pts[j + 1]], fill=(*WARM_PARCHMENT, 200), width=1)

    # 明亮核心（琥珀色火焰）
    # 外层光晕
    draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=(*AMBER_VOICE, 120))
    # 中层
    draw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=(*WARM_PARCHMENT, 200))
    # 内层
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(255, 240, 200, 255))
    # 中心亮点
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(255, 255, 255, 255))

    # 1px 黑色描边
    img = _add_black_outline(img)
    return img


def _add_black_outline(img: Image.Image) -> Image.Image:
    """为精灵添加 1px 黑色描边，增强深背景可读性"""
    w, h = img.size
    outlined = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    # 原图居中
    outlined.paste(img, (1, 1), img)

    # 创建描边层
    stroke = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    stroke_draw = ImageDraw.Draw(stroke)

    # 遍历原图非透明像素，在周围画黑色
    pixels = img.load()
    stroke_pixels = stroke.load()

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a > 30:
                for dy in [-1, 0, 1]:
                    for dx in [-1, 0, 1]:
                        if dx == 0 and dy == 0:
                            continue
                        sx, sy = x + 1 + dx, y + 1 + dy
                        sr, sg, sb, sa = stroke_pixels[sx, sy]
                        if sa < 255:
                            stroke_pixels[sx, sy] = (0, 0, 0, 255)

    # 合并：描边在下，原图在上
    result = Image.alpha_composite(stroke, outlined)
    return result


def create_shimmer_frames(base_img: Image.Image, num_frames: int = 4) -> list:
    """生成呼吸闪烁动画帧"""
    frames = []
    for i in range(num_frames):
        frame = base_img.copy()
        # 亮度微变模拟呼吸
        brightness = 1.0 + 0.08 * math.sin(i / num_frames * 2 * math.pi)
        # 调整 alpha 来模拟亮度
        pixels = frame.load()
        for y in range(frame.height):
            for x in range(frame.width):
                r, g, b, a = pixels[x, y]
                if a > 0:
                    new_a = min(255, int(a * brightness))
                    pixels[x, y] = (r, g, b, new_a)
        frames.append(frame)
    return frames


def create_spritesheet(frames: list, cell_size: tuple = (26, 34)) -> Image.Image:
    """将动画帧打包为水平 spritesheet（含描边后的尺寸）"""
    total_w = cell_size[0] * len(frames)
    sheet = Image.new("RGBA", (total_w, cell_size[1]), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        # 居中放置
        x_offset = i * cell_size[0] + (cell_size[0] - frame.width) // 2
        y_offset = (cell_size[1] - frame.height) // 2
        sheet.paste(frame, (x_offset, y_offset), frame)
    return sheet


if __name__ == "__main__":
    out_dir = "/workspace/assets/sprites"
    import os
    os.makedirs(out_dir, exist_ok=True)

    # 生成 dim 和 lit 状态
    dim = draw_save_lantern_dim((24, 32), seed=1029)
    lit = draw_save_lantern_lit((24, 32), seed=1029)

    dim.save(f"{out_dir}/save_lantern_dim.png")
    lit.save(f"{out_dir}/save_lantern_lit.png")

    # 生成 lit 状态的 shimmer 动画帧
    lit_frames = create_shimmer_frames(lit, num_frames=4)
    for i, f in enumerate(lit_frames):
        f.save(f"{out_dir}/save_lantern_lit_{i}.png")

    # 打包 spritesheet：dim + 4帧 lit shimmer
    all_frames = [dim] + lit_frames
    sheet = create_spritesheet(all_frames, cell_size=(28, 36))
    sheet.save(f"{out_dir}/save_lantern_spritesheet.png")

    print(f"Save Lantern sprites generated:")
    print(f"  - {out_dir}/save_lantern_dim.png")
    print(f"  - {out_dir}/save_lantern_lit.png")
    print(f"  - {out_dir}/save_lantern_lit_[0-3].png")
    print(f"  - {out_dir}/save_lantern_spritesheet.png (140x36)")
