#!/usr/bin/env python3
"""
程序化绘制 NoteWisp 敌人精灵
风格：Voxglass pixel art — 深墨蓝、琥珀眼、音符形体、波形尾迹
"""

from PIL import Image, ImageDraw
import math
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

def draw_notewisp(size: int = 64, scale: int = 1) -> Image.Image:
    """绘制 NoteWisp 基础帧。"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # 身体：音符形状（椭圆 + 旗）
    body_color = COLORS["ink_navy"]
    edge_color = COLORS["muted_violet"]
    highlight = COLORS["glass_cyan"]

    # 音符头（椭圆）
    head_rx, head_ry = 10, 8
    head_cx, head_cy = cx - 4, cy + 4
    draw.ellipse(
        [head_cx - head_rx, head_cy - head_ry, head_cx + head_rx, head_cy + head_ry],
        fill=body_color, outline=edge_color, width=1
    )

    # 音符杆
    stem_x = head_cx + head_rx - 2
    draw.rectangle([stem_x, head_cy - head_ry - 14, stem_x + 2, head_cy + head_ry - 2], fill=body_color, outline=edge_color)

    # 音符旗（波形旗）
    flag_points = []
    for i in range(8):
        fx = stem_x + 2 + i * 2
        fy = head_cy - head_ry - 14 + int(math.sin(i * 0.8) * 3)
        flag_points.append((fx, fy))
    flag_points.append((stem_x + 2, head_cy - head_ry - 10))
    if len(flag_points) >= 3:
        draw.polygon(flag_points, fill=body_color, outline=edge_color)

    # 波形尾迹（左侧飘出）
    tail_points = []
    for i in range(12):
        tx = head_cx - head_rx - 2 - i * 2
        ty = head_cy + int(math.sin(i * 0.6 + 1.0) * 5) - 2
        tail_points.append((tx, ty))
    for i in range(len(tail_points) - 1):
        alpha = int(255 * (1.0 - i / 12.0) * 0.6)
        tail_col = (*highlight[:3], alpha)
        # 用椭圆模拟线段
        draw.ellipse([tail_points[i][0]-1, tail_points[i][1]-1, tail_points[i][0]+1, tail_points[i][1]+1], fill=tail_col)

    # 眼睛：单只琥珀色发光眼
    eye_cx, eye_cy = head_cx - 2, head_cy - 1
    # 外圈微光
    draw.ellipse([eye_cx - 4, eye_cy - 4, eye_cx + 4, eye_cy + 4], fill=(*COLORS["coral_pulse"][:3], 80))
    # 核心
    draw.ellipse([eye_cx - 2, eye_cy - 2, eye_cx + 2, eye_cy + 2], fill=COLORS["amber_voice"])
    # 高光点
    draw.ellipse([eye_cx - 1, eye_cy - 1, eye_cx, eye_cy], fill=COLORS["warm_parchment"])

    # 玻璃青色边缘高光（顶部边缘）
    draw.arc([head_cx - head_rx, head_cy - head_ry - 2, head_cx + head_rx - 4, head_cy + head_ry], start=200, end=340, fill=highlight, width=1)

    # 描边：1px 黑色外轮廓增强可读性
    outline = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    outline_draw = ImageDraw.Draw(outline)
    # 提取不透明像素做外扩
    for y in range(size):
        for x in range(size):
            r, g, b, a = img.getpixel((x, y))
            if a > 128:
                for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < size and 0 <= ny < size:
                        nr, ng, nb, na = outline.getpixel((nx, ny))
                        if na < 128:
                            outline_draw.point((nx, ny), fill=(0, 0, 0, 255))

    # 合并：描边在下，内容在上
    composite = Image.alpha_composite(outline, img)

    if scale > 1:
        composite = composite.resize((size * scale, size * scale), Image.NEAREST)

    return composite

def draw_notewisp_frames(num_frames: int = 4, size: int = 64) -> list[Image.Image]:
    """生成 Shimmer 动画帧。"""
    frames = []
    base = draw_notewisp(size, 1)
    for i in range(num_frames):
        frame = base.copy()
        # 轻微亮度波动
        from PIL import ImageEnhance
        brightness = 1.0 + 0.03 * math.sin(i * math.pi * 2.0 / num_frames)
        enhancer = ImageEnhance.Brightness(frame)
        frame = enhancer.enhance(brightness)
        # 轻微垂直位移
        offset_y = int(math.sin(i * math.pi * 2.0 / num_frames) * 1)
        if offset_y != 0:
            shifted = Image.new("RGBA", (size, size), (0, 0, 0, 0))
            shifted.paste(frame, (0, offset_y))
            frame = shifted
        frames.append(frame)
    return frames

def create_spritesheet(frames: list[Image.Image], size: int = 64) -> Image.Image:
    """水平拼接为 spritesheet。"""
    sheet = Image.new("RGBA", (size * len(frames), size), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * size, 0))
    return sheet

if __name__ == "__main__":
    out_dir = "assets/enemies/note_wisp"
    os.makedirs(out_dir, exist_ok=True)

    # 基础帧
    base = draw_notewisp(64, 1)
    base.save(os.path.join(out_dir, "note_wisp.png"))

    # 放大版
    base_2x = draw_notewisp(64, 2)
    base_2x.save(os.path.join(out_dir, "note_wisp_128x128.png"))

    # 动画帧 + spritesheet
    frames = draw_notewisp_frames(4, 64)
    sheet = create_spritesheet(frames, 64)
    sheet.save(os.path.join(out_dir, "note_wisp_spritesheet.png"))

    print(f"NoteWisp assets saved to {out_dir}/")
    print(f"  note_wisp.png — 64x64 base frame")
    print(f"  note_wisp_128x128.png — 128x128 2x")
    print(f"  note_wisp_spritesheet.png — 256x64, 4 frames")
