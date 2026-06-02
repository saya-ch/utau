#!/usr/bin/env python3
"""
程序化绘制 InkWarden 精英敌人精灵
风格：Voxglass pixel art — 深墨蓝、玻璃板甲、琥珀独眼、玻璃青色护盾光环
尺寸：64x96 游戏内尺寸，128x192 画布
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

def draw_ink_warden(size_w: int = 64, size_h: int = 96, scale: int = 1) -> Image.Image:
    """绘制 InkWarden 基础帧。"""
    img = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size_w // 2, size_h // 2 + 8  # 偏下，因为体型高大

    body_color = COLORS["ink_navy"]
    edge_color = COLORS["muted_violet"]
    highlight = COLORS["glass_cyan"]
    armor_color = COLORS["archive_blue"]

    # === 下半身：厚重腿部 ===
    # 左腿
    draw.rectangle([cx - 14, cy + 16, cx - 4, cy + 36], fill=body_color, outline=edge_color)
    # 右腿
    draw.rectangle([cx + 4, cy + 16, cx + 14, cy + 36], fill=body_color, outline=edge_color)
    # 膝盖护甲
    draw.rectangle([cx - 15, cy + 20, cx - 3, cy + 26], fill=armor_color, outline=highlight)
    draw.rectangle([cx + 3, cy + 20, cx + 15, cy + 26], fill=armor_color, outline=highlight)

    # === 躯干：宽大上身 ===
    draw.rectangle([cx - 18, cy - 12, cx + 18, cy + 18], fill=body_color, outline=edge_color)
    # 胸甲：裂纹玻璃板
    draw.rectangle([cx - 14, cy - 8, cx + 14, cy + 10], fill=armor_color, outline=highlight)
    # 胸甲裂纹
    draw.line([cx - 10, cy - 4, cx - 2, cy + 4], fill=highlight, width=1)
    draw.line([cx + 2, cy - 6, cx + 8, cy + 2], fill=highlight, width=1)

    # === 左臂：巨大弯刀臂 ===
    # 上臂
    draw.rectangle([cx - 26, cy - 8, cx - 18, cy + 8], fill=body_color, outline=edge_color)
    # 刀刃（向下弯曲）
    blade_points = [
        (cx - 26, cy + 8),
        (cx - 22, cy + 32),
        (cx - 18, cy + 36),
        (cx - 14, cy + 32),
        (cx - 18, cy + 8),
    ]
    draw.polygon(blade_points, fill=COLORS["deep_teal"], outline=highlight)
    # 刀刃高光
    draw.line([cx - 22, cy + 10, cx - 20, cy + 28], fill=COLORS["pale_resonance"], width=1)

    # === 右臂：较小，带护甲 ===
    draw.rectangle([cx + 18, cy - 6, cx + 26, cy + 10], fill=body_color, outline=edge_color)
    draw.rectangle([cx + 17, cy - 4, cx + 27, cy + 6], fill=armor_color, outline=highlight)

    # === 头部：玻璃面罩 + 独眼 ===
    # 头盔主体
    draw.ellipse([cx - 12, cy - 28, cx + 12, cy - 4], fill=body_color, outline=edge_color)
    # 玻璃面罩（覆盖面部）
    draw.ellipse([cx - 10, cy - 26, cx + 10, cy - 8], fill=(*COLORS["archive_blue"][:3], 180), outline=highlight)
    # 面罩裂纹
    draw.line([cx - 6, cy - 20, cx + 2, cy - 14], fill=highlight, width=1)
    draw.line([cx - 2, cy - 22, cx + 4, cy - 10], fill=highlight, width=1)

    # 眼睛：单只强烈琥珀色发光眼（面罩后方）
    eye_cx, eye_cy = cx - 2, cy - 16
    # 外圈微光
    draw.ellipse([eye_cx - 5, eye_cy - 5, eye_cx + 5, eye_cy + 5], fill=(*COLORS["coral_pulse"][:3], 100))
    # 核心
    draw.ellipse([eye_cx - 3, eye_cy - 3, eye_cx + 3, eye_cy + 3], fill=COLORS["amber_voice"])
    # 高光点
    draw.ellipse([eye_cx - 1, eye_cy - 1, eye_cx, eye_cy], fill=COLORS["warm_parchment"])

    # === 肩部护甲 ===
    draw.ellipse([cx - 22, cy - 14, cx - 10, cy - 2], fill=armor_color, outline=highlight)
    draw.ellipse([cx + 10, cy - 14, cx + 22, cy - 2], fill=armor_color, outline=highlight)

    # === 玻璃青色护盾光环（身体周围）===
    shield_radius_x, shield_radius_y = 28, 40
    # 画椭圆光环（不填充，只描边）
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        sx = cx + int(shield_radius_x * math.cos(rad))
        sy = cy + 4 + int(shield_radius_y * math.sin(rad))
        # 小光点
        draw.ellipse([sx - 1, sy - 1, sx + 1, sy + 1], fill=(*highlight[:3], 160))
    # 护盾弧线
    draw.arc([cx - shield_radius_x, cy + 4 - shield_radius_y,
              cx + shield_radius_x, cy + 4 + shield_radius_y],
             start=30, end=150, fill=(*highlight[:3], 140), width=1)
    draw.arc([cx - shield_radius_x, cy + 4 - shield_radius_y,
              cx + shield_radius_x, cy + 4 + shield_radius_y],
             start=210, end=330, fill=(*highlight[:3], 140), width=1)

    # === 1px 黑色描边增强可读性 ===
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

    if scale > 1:
        composite = composite.resize((size_w * scale, size_h * scale), Image.NEAREST)

    return composite

def draw_ink_warden_shield_broken(size_w: int = 64, size_h: int = 96, scale: int = 1) -> Image.Image:
    """绘制护盾破碎后的 InkWarden（护盾光环消失，颜色稍暗淡）。"""
    img = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size_w // 2, size_h // 2 + 8

    body_color = COLORS["ink_navy"]
    edge_color = COLORS["muted_violet"]
    armor_color = COLORS["archive_blue"]

    # 下半身
    draw.rectangle([cx - 14, cy + 16, cx - 4, cy + 36], fill=body_color, outline=edge_color)
    draw.rectangle([cx + 4, cy + 16, cx + 14, cy + 36], fill=body_color, outline=edge_color)
    draw.rectangle([cx - 15, cy + 20, cx - 3, cy + 26], fill=armor_color, outline=edge_color)
    draw.rectangle([cx + 3, cy + 20, cx + 15, cy + 26], fill=armor_color, outline=edge_color)

    # 躯干
    draw.rectangle([cx - 18, cy - 12, cx + 18, cy + 18], fill=body_color, outline=edge_color)
    draw.rectangle([cx - 14, cy - 8, cx + 14, cy + 10], fill=armor_color, outline=edge_color)
    # 更多裂纹（破损状态）
    draw.line([cx - 10, cy - 4, cx - 2, cy + 4], fill=COLORS["muted_violet"], width=1)
    draw.line([cx + 2, cy - 6, cx + 8, cy + 2], fill=COLORS["muted_violet"], width=1)
    draw.line([cx - 6, cy + 0, cx + 4, cy + 6], fill=COLORS["muted_violet"], width=1)

    # 左臂弯刀
    blade_points = [
        (cx - 26, cy + 8),
        (cx - 22, cy + 32),
        (cx - 18, cy + 36),
        (cx - 14, cy + 32),
        (cx - 18, cy + 8),
    ]
    draw.polygon(blade_points, fill=COLORS["deep_teal"], outline=edge_color)

    # 右臂
    draw.rectangle([cx + 18, cy - 6, cx + 26, cy + 10], fill=body_color, outline=edge_color)
    draw.rectangle([cx + 17, cy - 4, cx + 27, cy + 6], fill=armor_color, outline=edge_color)

    # 头部（面罩更暗）
    draw.ellipse([cx - 12, cy - 28, cx + 12, cy - 4], fill=body_color, outline=edge_color)
    draw.ellipse([cx - 10, cy - 26, cx + 10, cy - 8], fill=(*COLORS["archive_blue"][:3], 120), outline=edge_color)
    draw.line([cx - 6, cy - 20, cx + 2, cy - 14], fill=COLORS["muted_violet"], width=1)
    draw.line([cx - 2, cy - 22, cx + 4, cy - 10], fill=COLORS["muted_violet"], width=1)

    # 眼睛（暗淡一些）
    eye_cx, eye_cy = cx - 2, cy - 16
    draw.ellipse([eye_cx - 5, eye_cy - 5, eye_cx + 5, eye_cy + 5], fill=(*COLORS["coral_pulse"][:3], 60))
    draw.ellipse([eye_cx - 3, eye_cy - 3, eye_cx + 3, eye_cy + 3], fill=COLORS["amber_voice"])
    draw.ellipse([eye_cx - 1, eye_cy - 1, eye_cx, eye_cy], fill=COLORS["warm_parchment"])

    # 肩部
    draw.ellipse([cx - 22, cy - 14, cx - 10, cy - 2], fill=armor_color, outline=edge_color)
    draw.ellipse([cx + 10, cy - 14, cx + 22, cy - 2], fill=armor_color, outline=edge_color)

    # 无护盾光环

    # 1px 黑色描边
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

    if scale > 1:
        composite = composite.resize((size_w * scale, size_h * scale), Image.NEAREST)

    return composite

def draw_ink_warden_frames(num_frames: int = 4, size_w: int = 64, size_h: int = 96) -> list[Image.Image]:
    """生成 Shimmer 呼吸动画帧。"""
    frames = []
    base = draw_ink_warden(size_w, size_h, 1)
    for i in range(num_frames):
        frame = base.copy()
        from PIL import ImageEnhance
        brightness = 1.0 + 0.02 * math.sin(i * math.pi * 2.0 / num_frames)
        enhancer = ImageEnhance.Brightness(frame)
        frame = enhancer.enhance(brightness)
        # 护盾光环轻微缩放
        frames.append(frame)
    return frames

def create_spritesheet(frames: list[Image.Image], size_w: int = 64, size_h: int = 96) -> Image.Image:
    """水平拼接为 spritesheet。"""
    sheet = Image.new("RGBA", (size_w * len(frames), size_h), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * size_w, 0))
    return sheet

if __name__ == "__main__":
    out_dir = "assets/enemies/ink_warden"
    os.makedirs(out_dir, exist_ok=True)

    # 基础帧（带护盾）
    base = draw_ink_warden(64, 96, 1)
    base.save(os.path.join(out_dir, "ink_warden.png"))

    # 2x 放大版
    base_2x = draw_ink_warden(64, 96, 2)
    base_2x.save(os.path.join(out_dir, "ink_warden_128x192.png"))

    # 护盾破碎版
    broken = draw_ink_warden_shield_broken(64, 96, 1)
    broken.save(os.path.join(out_dir, "ink_warden_shield_broken.png"))

    # 动画帧 + spritesheet
    frames = draw_ink_warden_frames(4, 64, 96)
    sheet = create_spritesheet(frames, 64, 96)
    sheet.save(os.path.join(out_dir, "ink_warden_spritesheet.png"))

    print(f"InkWarden assets saved to {out_dir}/")
    print(f"  ink_warden.png — 64x96 base frame with shield")
    print(f"  ink_warden_128x192.png — 128x192 2x")
    print(f"  ink_warden_shield_broken.png — 64x96 shield broken variant")
    print(f"  ink_warden_spritesheet.png — 256x96, 4 frames")
