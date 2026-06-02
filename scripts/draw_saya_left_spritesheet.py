#!/usr/bin/env python3
"""
程序化绘制 Saya 左朝向正式版 spritesheet（T024）
完全本地生成，不依赖外部 API。
遵循 STYLE_GUIDE 色板与角色设定。
核心规则：左臂声匣保持在画面左侧（解剖学左臂）。
"""
from PIL import Image
from pathlib import Path

# ═══════════════════════════════════════════════════════════════
# 色板（来自 STYLE_GUIDE）
# ═══════════════════════════════════════════════════════════════
C_ABYSS      = (0x05, 0x07, 0x0D)
C_INK_NAVY   = (0x08, 0x14, 0x26)
C_ARCHIVE_BL = (0x12, 0x33, 0x4A)
C_DEEP_TEAL  = (0x1D, 0x65, 0x70)
C_GLASS_CYAN = (0x69, 0xC7, 0xCE)
C_PALE_RES   = (0xB7, 0xE7, 0xDD)
C_MUTED_VIO  = (0x65, 0x50, 0x6A)
C_CORAL_PUL  = (0xE8, 0x6D, 0x5A)
C_AMBER_VOI  = (0xF2, 0xB6, 0x6E)
C_WARM_PAR   = (0xE6, 0xD5, 0xB8)

# 角色专用色
C_SKIN       = (0xD4, 0xA5, 0x8C)
C_SKIN_SHADOW= (0xA8, 0x7A, 0x64)
C_HAIR_DARK  = C_INK_NAVY
C_HAIR_CYAN  = C_GLASS_CYAN
C_COAT       = C_ARCHIVE_BL
C_COAT_LIGHT = C_DEEP_TEAL
C_CAPE       = (0x4A, 0x6E, 0x7A, 0xCC)
C_SCARF      = (0x5A, 0x8A, 0x92)
C_GAUNTLET   = (0x3A, 0x5A, 0x62, 0xDD)
C_GAUNTLET_GLOW = C_AMBER_VOI
C_THROAT     = C_AMBER_VOI
C_EYE_WHITE  = C_PALE_RES
C_EYE_PUPIL  = C_INK_NAVY

CELL_W, CELL_H = 48, 64

def new_frame():
    return Image.new("RGBA", (CELL_W, CELL_H), (0,0,0,0))

def put_pixel(img, x, y, color):
    if 0 <= x < CELL_W and 0 <= y < CELL_H:
        if len(color) == 4:
            img.putpixel((x, y), color)
        else:
            img.putpixel((x, y), color + (255,))

def draw_rect(img, x, y, w, h, color):
    for dy in range(h):
        for dx in range(w):
            put_pixel(img, x+dx, y+dy, color)

# ═══════════════════════════════════════════════════════════════
# Saya 左朝向绘制函数
# 关键：左臂声匣在画面左侧（解剖学左侧），眼睛在画面左侧
# ═══════════════════════════════════════════════════════════════

def draw_saya_left_idle(frame_idx: int) -> Image.Image:
    """绘制 Saya 左朝向 idle 帧。"""
    img = new_frame()
    breathe = 0 if frame_idx < 4 else 1
    by = breathe

    # --- 后发 ---
    draw_rect(img, 20, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 18, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 28, 8+by, 4, 6, C_HAIR_DARK)

    # --- 青色长束（右侧后方，左朝向时从右侧飘出）---
    draw_rect(img, 31, 10+by, 3, 10, C_HAIR_CYAN)
    draw_rect(img, 33, 14+by, 2, 8, C_HAIR_CYAN)

    # --- 身体/外套 ---
    draw_rect(img, 19, 16+by, 10, 14, C_COAT)
    draw_rect(img, 20, 14+by, 8, 2, C_COAT_LIGHT)
    draw_rect(img, 21, 18+by, 2, 10, C_COAT_LIGHT)
    draw_rect(img, 25, 18+by, 2, 10, C_COAT_LIGHT)

    # --- 腿部 ---
    draw_rect(img, 20, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 20, 42+by, 4, 4, C_COAT_LIGHT)
    draw_rect(img, 20, 46+by, 4, 6, C_DEEP_TEAL)
    draw_rect(img, 26, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 26, 42+by, 4, 4, C_COAT_LIGHT)
    draw_rect(img, 26, 46+by, 4, 6, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 20, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 20, 14+by, 8, 2, C_SKIN_SHADOW)
    # 眼睛（左朝向：眼睛在画面左侧）
    draw_rect(img, 21, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 21, 10+by, 2, 2, C_EYE_PUPIL)
    put_pixel(img, 24, 13+by, C_SKIN_SHADOW)

    # --- 前发 ---
    draw_rect(img, 20, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 22, 5+by, 4, 2, C_HAIR_DARK)
    draw_rect(img, 20, 8+by, 2, 3, C_HAIR_DARK)
    draw_rect(img, 26, 8+by, 2, 3, C_HAIR_DARK)

    # --- 喉口琥珀共鸣晶体 ---
    put_pixel(img, 23, 15+by, C_THROAT)
    put_pixel(img, 24, 15+by, C_THROAT)

    # --- 左臂（解剖学左侧，画面左侧）---
    draw_rect(img, 29, 18+by, 3, 8, C_COAT)
    draw_rect(img, 30, 24+by, 3, 4, C_SKIN)
    # 声匣装置（左前臂，画面左侧）
    draw_rect(img, 31, 26+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 32, 27+by, C_GAUNTLET_GLOW)
    put_pixel(img, 33, 27+by, C_GAUNTLET_GLOW)
    put_pixel(img, 34, 26+by, C_GLASS_CYAN)
    put_pixel(img, 34, 30+by, C_GLASS_CYAN)

    # --- 右臂（画面右侧）---
    draw_rect(img, 15, 18+by, 3, 8, C_COAT)
    draw_rect(img, 14, 24+by, 3, 4, C_SKIN)

    # --- 玻璃披肩（右肩后方，左朝向时从右肩披下）---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 28+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)
    put_pixel(img, 31, 16+by, C_GLASS_CYAN)
    put_pixel(img, 30, 18+by, C_GLASS_CYAN)
    put_pixel(img, 32, 20+by, C_GLASS_CYAN)

    # --- 声波围巾 ---
    draw_rect(img, 18, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 28, 15+by, 2, 2, C_SCARF)
    scarf_wave = frame_idx % 4
    if scarf_wave < 2:
        draw_rect(img, 16, 17+by, 3, 2, C_SCARF)
        draw_rect(img, 16, 19+by, 2, 2, C_SCARF)
    else:
        draw_rect(img, 17, 17+by, 3, 2, C_SCARF)
        draw_rect(img, 17, 19+by, 2, 2, C_SCARF)

    # --- 边缘光 ---
    put_pixel(img, 19, 9+by, C_GLASS_CYAN)
    put_pixel(img, 29, 9+by, C_GLASS_CYAN)
    put_pixel(img, 35, 27+by, C_GLASS_CYAN)
    put_pixel(img, 35, 29+by, C_GLASS_CYAN)

    return img


def draw_saya_left_run(frame_idx: int) -> Image.Image:
    """绘制 Saya 左朝向 run 帧。"""
    img = new_frame()
    bounce = 1 if frame_idx % 2 == 0 else 0
    leg_phase = frame_idx % 4
    by = bounce

    # --- 后发 ---
    draw_rect(img, 20, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 18, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 28, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 32, 8+by, 3, 8, C_HAIR_CYAN)
    draw_rect(img, 34, 10+by, 2, 6, C_HAIR_CYAN)

    # --- 身体 ---
    draw_rect(img, 18, 16+by, 10, 14, C_COAT)
    draw_rect(img, 19, 14+by, 8, 2, C_COAT_LIGHT)
    draw_rect(img, 20, 18+by, 2, 10, C_COAT_LIGHT)
    draw_rect(img, 24, 18+by, 2, 10, C_COAT_LIGHT)

    # --- 腿部（交替）---
    if leg_phase in (0, 1):
        # 右腿前伸
        draw_rect(img, 24, 30+by, 4, 10, C_INK_NAVY)
        draw_rect(img, 23, 40+by, 3, 4, C_INK_NAVY)
        draw_rect(img, 23, 44+by, 3, 4, C_DEEP_TEAL)
        # 左腿后蹬
        draw_rect(img, 18, 30+by, 4, 8, C_INK_NAVY)
        draw_rect(img, 20, 36+by, 3, 6, C_INK_NAVY)
        draw_rect(img, 21, 42+by, 3, 4, C_DEEP_TEAL)
    else:
        # 左腿前伸
        draw_rect(img, 18, 30+by, 4, 10, C_INK_NAVY)
        draw_rect(img, 18, 40+by, 3, 4, C_INK_NAVY)
        draw_rect(img, 18, 44+by, 3, 4, C_DEEP_TEAL)
        # 右腿后蹬
        draw_rect(img, 24, 30+by, 4, 8, C_INK_NAVY)
        draw_rect(img, 22, 36+by, 3, 6, C_INK_NAVY)
        draw_rect(img, 21, 42+by, 3, 4, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 19, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 19, 14+by, 8, 2, C_SKIN_SHADOW)
    draw_rect(img, 20, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 20, 10+by, 2, 2, C_EYE_PUPIL)
    put_pixel(img, 23, 13+by, C_SKIN_SHADOW)

    # --- 前发 ---
    draw_rect(img, 19, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 21, 5+by, 4, 2, C_HAIR_DARK)
    draw_rect(img, 19, 8+by, 2, 3, C_HAIR_DARK)
    draw_rect(img, 25, 8+by, 2, 3, C_HAIR_DARK)

    # --- 喉口晶体 ---
    put_pixel(img, 21, 15+by, C_THROAT)
    put_pixel(img, 22, 15+by, C_THROAT)

    # --- 左臂（声匣，画面左侧）---
    draw_rect(img, 28, 18+by, 3, 8, C_COAT)
    draw_rect(img, 29, 24+by, 3, 4, C_SKIN)
    draw_rect(img, 30, 26+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 31, 27+by, C_GAUNTLET_GLOW)
    put_pixel(img, 32, 27+by, C_GAUNTLET_GLOW)
    put_pixel(img, 33, 26+by, C_GLASS_CYAN)
    put_pixel(img, 33, 30+by, C_GLASS_CYAN)

    # --- 右臂 ---
    draw_rect(img, 14, 18+by, 3, 8, C_COAT)
    draw_rect(img, 13, 24+by, 3, 4, C_SKIN)

    # --- 玻璃披肩 ---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 27+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)
    put_pixel(img, 30, 16+by, C_GLASS_CYAN)
    put_pixel(img, 29, 18+by, C_GLASS_CYAN)

    # --- 声波围巾 ---
    draw_rect(img, 17, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 27, 15+by, 2, 2, C_SCARF)
    if leg_phase < 2:
        draw_rect(img, 14, 17+by, 4, 2, C_SCARF)
        draw_rect(img, 14, 19+by, 3, 2, C_SCARF)
    else:
        draw_rect(img, 15, 17+by, 4, 2, C_SCARF)
        draw_rect(img, 15, 19+by, 3, 2, C_SCARF)

    # --- 边缘光 ---
    put_pixel(img, 18, 9+by, C_GLASS_CYAN)
    put_pixel(img, 28, 9+by, C_GLASS_CYAN)
    put_pixel(img, 34, 27+by, C_GLASS_CYAN)

    return img


def draw_saya_left_jump() -> Image.Image:
    """绘制 Saya 左朝向 jump 帧。"""
    img = new_frame()
    by = -2

    # --- 后发 ---
    draw_rect(img, 20, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 18, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 28, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 31, 6+by, 3, 10, C_HAIR_CYAN)
    draw_rect(img, 33, 4+by, 2, 8, C_HAIR_CYAN)

    # --- 身体 ---
    draw_rect(img, 19, 16+by, 10, 14, C_COAT)
    draw_rect(img, 20, 14+by, 8, 2, C_COAT_LIGHT)

    # --- 腿部 ---
    draw_rect(img, 24, 30+by, 4, 8, C_INK_NAVY)
    draw_rect(img, 21, 36+by, 5, 4, C_INK_NAVY)
    draw_rect(img, 20, 38+by, 3, 4, C_DEEP_TEAL)
    draw_rect(img, 18, 30+by, 4, 8, C_INK_NAVY)
    draw_rect(img, 17, 34+by, 4, 4, C_INK_NAVY)
    draw_rect(img, 17, 38+by, 3, 4, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 20, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 21, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 21, 10+by, 2, 2, C_EYE_PUPIL)

    # --- 前发 ---
    draw_rect(img, 20, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 22, 5+by, 4, 2, C_HAIR_DARK)

    # --- 喉口晶体 ---
    put_pixel(img, 23, 15+by, C_THROAT)
    put_pixel(img, 24, 15+by, C_THROAT)

    # --- 左臂（声匣，跳起时举起，画面左侧）---
    draw_rect(img, 29, 16+by, 3, 8, C_COAT)
    draw_rect(img, 30, 14+by, 3, 4, C_SKIN)
    draw_rect(img, 31, 12+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 32, 13+by, C_GAUNTLET_GLOW)
    put_pixel(img, 33, 13+by, C_GAUNTLET_GLOW)
    put_pixel(img, 34, 12+by, C_GLASS_CYAN)

    # --- 右臂 ---
    draw_rect(img, 15, 16+by, 3, 8, C_COAT)
    draw_rect(img, 14, 14+by, 3, 4, C_SKIN)

    # --- 玻璃披肩 ---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 28+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)

    # --- 声波围巾 ---
    draw_rect(img, 18, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 28, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 14, 16+by, 4, 2, C_SCARF)
    draw_rect(img, 14, 18+by, 3, 2, C_SCARF)

    return img


def draw_saya_left_fall() -> Image.Image:
    """绘制 Saya 左朝向 fall 帧。"""
    img = new_frame()
    by = 1

    # --- 后发 ---
    draw_rect(img, 20, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 18, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 28, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 31, 4+by, 3, 10, C_HAIR_CYAN)

    # --- 身体 ---
    draw_rect(img, 19, 16+by, 10, 14, C_COAT)
    draw_rect(img, 20, 14+by, 8, 2, C_COAT_LIGHT)

    # --- 腿部 ---
    draw_rect(img, 24, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 24, 44+by, 4, 4, C_DEEP_TEAL)
    draw_rect(img, 18, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 18, 44+by, 4, 4, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 20, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 21, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 21, 10+by, 2, 2, C_EYE_PUPIL)

    # --- 前发 ---
    draw_rect(img, 20, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 22, 5+by, 4, 2, C_HAIR_DARK)

    # --- 喉口晶体 ---
    put_pixel(img, 23, 15+by, C_THROAT)
    put_pixel(img, 24, 15+by, C_THROAT)

    # --- 左臂（声匣，下落时自然下垂，画面左侧）---
    draw_rect(img, 29, 18+by, 3, 8, C_COAT)
    draw_rect(img, 30, 24+by, 3, 6, C_SKIN)
    draw_rect(img, 31, 28+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 32, 29+by, C_GAUNTLET_GLOW)
    put_pixel(img, 33, 29+by, C_GAUNTLET_GLOW)

    # --- 右臂 ---
    draw_rect(img, 15, 18+by, 3, 8, C_COAT)
    draw_rect(img, 14, 24+by, 3, 6, C_SKIN)

    # --- 玻璃披肩 ---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 28+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)

    # --- 声波围巾 ---
    draw_rect(img, 18, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 28, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 19, 13+by, 3, 2, C_SCARF)
    draw_rect(img, 20, 11+by, 2, 2, C_SCARF)

    return img


def main():
    print("=" * 60)
    print("T024: 程序化绘制 Saya 左朝向正式版 Spritesheet")
    print("=" * 60)

    output_dir = Path("assets/sprites")
    output_dir.mkdir(parents=True, exist_ok=True)

    # --- 生成左朝向帧 ---
    print("\n生成左朝向帧...")
    left_frames = []
    for i in range(8):
        left_frames.append(draw_saya_left_idle(i))
    for i in range(8):
        left_frames.append(draw_saya_left_run(i))
    left_frames.append(draw_saya_left_jump())
    left_frames.append(draw_saya_left_fall())
    print(f"  左朝向: {len(left_frames)} 帧")

    # --- 打包 Spritesheet ---
    print("\n打包 Spritesheet...")
    left_w = CELL_W * len(left_frames)
    left_sheet = Image.new("RGBA", (left_w, CELL_H), (0,0,0,0))
    for i, f in enumerate(left_frames):
        left_sheet.paste(f, (i * CELL_W, 0))
    left_path = output_dir / "saya_spritesheet_left.png"
    left_sheet.save(left_path, "PNG", optimize=True)
    print(f"  左朝向: {left_path} ({left_sheet.size})")

    # 保存元数据
    import json
    meta = {
        "cell_width": CELL_W,
        "cell_height": CELL_H,
        "animations": {
            "idle": {"start": 0, "frames": 8},
            "run": {"start": 8, "frames": 8},
            "jump": {"start": 16, "frames": 2},
            "fall": {"start": 18, "frames": 2},
        },
        "total_frames": len(left_frames),
        "method": "procedural_pixel_art",
        "notes": "左朝向正式版：左臂声匣位于画面左侧，眼睛位于画面左侧，非翻转",
    }
    meta_path = output_dir / "saya_spritesheet_left_meta.json"
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2, ensure_ascii=False)
    print(f"  元数据: {meta_path}")

    print("\n" + "=" * 60)
    print("T024 完成!")
    print("=" * 60)


if __name__ == "__main__":
    main()
