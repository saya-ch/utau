#!/usr/bin/env python3
"""
程序化生成 Hub NPC 头像与对话 UI 素材。
风格：Voxglass pixel art — 深墨蓝底、玻璃青色描边、琥珀/珊瑚色点缀。
尺寸：48x48 头像（对话框 portrait），32x32 游戏内 NPC 精灵占位。
"""

import math
from PIL import Image, ImageDraw

# 色板
INK_NAVY = (8, 20, 38)
ARCHIVE_BLUE = (18, 51, 74)
DEEP_TEAL = (29, 101, 112)
GLASS_CYAN = (105, 199, 206)
PALE_RESONANCE = (183, 231, 221)
MUTED_VIOLET = (101, 80, 106)
CORAL_PULSE = (232, 109, 90)
AMBER_VOICE = (242, 182, 110)
WARM_PARCHMENT = (230, 213, 184)


def _lerp_color(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def _draw_rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    x1, y1, x2, y2 = xy
    r = radius
    draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=fill, outline=outline, width=width)


def draw_archivist_portrait(size: int = 48) -> Image.Image:
    """档案管理员：老学者，白发束髻，持灯笼，深海军蓝长袍。"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 背景圆形
    bg_r = size // 2 - 1
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=INK_NAVY, outline=GLASS_CYAN, width=1)

    # 长袍轮廓（梯形）
    robe_top = cy - 4
    robe_bottom = cy + bg_r - 2
    draw.polygon([
        (cx - 10, robe_top), (cx + 10, robe_top),
        (cx + 14, robe_bottom), (cx - 14, robe_bottom)
    ], fill=ARCHIVE_BLUE, outline=DEEP_TEAL, width=1)

    # 头部
    head_r = 8
    draw.ellipse([cx - head_r, robe_top - head_r * 2 + 2, cx + head_r, robe_top + 2], fill=WARM_PARCHMENT, outline=MUTED_VIOLET, width=1)

    # 白发束髻
    bun_r = 4
    draw.ellipse([cx - bun_r, robe_top - head_r * 2 - 2, cx + bun_r, robe_top - head_r + 2], fill=PALE_RESONANCE, outline=MUTED_VIOLET, width=1)

    # 眼镜
    draw.ellipse([cx - 5, robe_top - 10, cx - 1, robe_top - 6], outline=GLASS_CYAN, width=1)
    draw.ellipse([cx + 1, robe_top - 10, cx + 5, robe_top - 6], outline=GLASS_CYAN, width=1)
    draw.line([(cx - 1, robe_top - 8), (cx + 1, robe_top - 8)], fill=GLASS_CYAN, width=1)

    # 灯笼（右手）
    lantern_x = cx + 12
    lantern_y = robe_top + 6
    draw.line([(cx + 8, robe_top), (lantern_x, lantern_y - 6)], fill=MUTED_VIOLET, width=1)
    draw.rectangle([lantern_x - 3, lantern_y - 4, lantern_x + 3, lantern_y + 4], fill=INK_NAVY, outline=GLASS_CYAN, width=1)
    draw.ellipse([lantern_x - 2, lantern_y - 2, lantern_x + 2, lantern_y + 2], fill=AMBER_VOICE)

    return img


def draw_tuner_portrait(size: int = 48) -> Image.Image:
    """调音自动机：机械人偶，单眼齿轮，玻璃管装置，冷青色光。"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    bg_r = size // 2 - 1
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r], fill=INK_NAVY, outline=GLASS_CYAN, width=1)

    # 机械身体（圆角矩形）
    body_w, body_h = 18, 22
    draw.rounded_rectangle([cx - body_w // 2, cy - 2, cx + body_w // 2, cy + body_h - 2], radius=4, fill=ARCHIVE_BLUE, outline=GLASS_CYAN, width=1)

    # 头部（圆角方形）
    head_s = 14
    draw.rounded_rectangle([cx - head_s // 2, cy - head_s - 4, cx + head_s // 2, cy - 4], radius=3, fill=DEEP_TEAL, outline=GLASS_CYAN, width=1)

    # 单眼齿轮
    gear_r = 4
    draw.ellipse([cx - gear_r, cy - head_s, cx + gear_r, cy - head_s + gear_r * 2], fill=INK_NAVY, outline=AMBER_VOICE, width=1)
    draw.ellipse([cx - 1, cy - head_s + 2, cx + 1, cy - head_s + 4], fill=AMBER_VOICE)

    # 玻璃管（左侧）
    tube_x = cx - 10
    draw.rectangle([tube_x - 2, cy - 6, tube_x + 2, cy + 8], fill=(*GLASS_CYAN, 60), outline=GLASS_CYAN, width=1)
    draw.ellipse([tube_x - 1, cy + 4, tube_x + 1, cy + 8], fill=AMBER_VOICE)

    # 天线
    draw.line([(cx, cy - head_s - 4), (cx, cy - head_s - 10)], fill=MUTED_VIOLET, width=1)
    draw.ellipse([cx - 1, cy - head_s - 12, cx + 1, cy - head_s - 10], fill=GLASS_CYAN)

    return img


def draw_dialogue_frame(size=(480, 70)) -> Image.Image:
    """对话框底图：细线黄铜边、深色玻璃底。"""
    w, h = size
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 主背景
    _draw_rounded_rect(draw, [2, 2, w - 2, h - 2], 4, (*INK_NAVY, 220), (*GLASS_CYAN, 120), 1)

    # 顶部细线装饰
    draw.line([(8, 6), (w - 8, 6)], fill=(*AMBER_VOICE, 80), width=1)

    # 左侧 portrait 区域框
    _draw_rounded_rect(draw, [8, 10, 56, h - 10], 2, (*ARCHIVE_BLUE, 100), (*GLASS_CYAN, 60), 1)

    return img


def draw_npc_sprite_placeholder(size: int = 32) -> Image.Image:
    """游戏内 NPC 占位精灵：32x32，带 1px 黑色描边。"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 身体
    body_h = 18
    draw.ellipse([cx - 6, cy - body_h // 2, cx + 6, cy + body_h // 2], fill=ARCHIVE_BLUE, outline=(0, 0, 0, 255), width=1)

    # 头
    draw.ellipse([cx - 5, cy - body_h // 2 - 8, cx + 5, cy - body_h // 2 + 2], fill=WARM_PARCHMENT, outline=(0, 0, 0, 255), width=1)

    # 眼睛
    draw.ellipse([cx - 3, cy - body_h // 2 - 5, cx - 1, cy - body_h // 2 - 3], fill=INK_NAVY)
    draw.ellipse([cx + 1, cy - body_h // 2 - 5, cx + 3, cy - body_h // 2 - 3], fill=INK_NAVY)

    return img


if __name__ == "__main__":
    import os
    out_dir = "/workspace/assets/ui/npc"
    os.makedirs(out_dir, exist_ok=True)

    archivist = draw_archivist_portrait(48)
    archivist.save(f"{out_dir}/archivist_portrait.png")

    tuner = draw_tuner_portrait(48)
    tuner.save(f"{out_dir}/tuner_portrait.png")

    dialogue_frame = draw_dialogue_frame((480, 70))
    dialogue_frame.save(f"{out_dir}/dialogue_frame.png")

    npc_sprite = draw_npc_sprite_placeholder(32)
    npc_sprite.save(f"{out_dir}/npc_sprite_placeholder.png")

    print(f"NPC assets generated in {out_dir}:")
    print(f"  - archivist_portrait.png (48x48)")
    print(f"  - tuner_portrait.png (48x48)")
    print(f"  - dialogue_frame.png (480x70)")
    print(f"  - npc_sprite_placeholder.png (32x32)")
