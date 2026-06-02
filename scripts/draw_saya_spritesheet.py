"""
程序化绘制 Saya 像素 spritesheet（T017 替代方案）
完全本地生成，不依赖外部 API。
遵循 STYLE_GUIDE 色板与角色设定。
"""
from PIL import Image
from pathlib import Path

# ═══════════════════════════════════════════════════════════════
# 色板（来自 STYLE_GUIDE）
# ═══════════════════════════════════════════════════════════════
C_ABYSS      = (0x05, 0x07, 0x0D)       # 最深背景
C_INK_NAVY   = (0x08, 0x14, 0x26)       # 主背景/角色阴影
C_ARCHIVE_BL = (0x12, 0x33, 0x4A)       # 石墙
C_DEEP_TEAL  = (0x1D, 0x65, 0x70)       # 水光/暗部
C_GLASS_CYAN = (0x69, 0xC7, 0xCE)       # 玻璃边缘
C_PALE_RES   = (0xB7, 0xE7, 0xDD)       # 高亮裂纹
C_MUTED_VIO  = (0x65, 0x50, 0x6A)       # 阴影层次
C_CORAL_PUL  = (0xE8, 0x6D, 0x5A)       # 攻击波峰
C_AMBER_VOI  = (0xF2, 0xB6, 0x6E)       # 修复成功
C_WARM_PAR   = (0xE6, 0xD5, 0xB8)       # 文字高亮

# 角色专用色
C_SKIN       = (0xD4, 0xA5, 0x8C)
C_SKIN_SHADOW= (0xA8, 0x7A, 0x64)
C_HAIR_DARK  = C_INK_NAVY
C_HAIR_CYAN  = C_GLASS_CYAN
C_COAT       = C_ARCHIVE_BL
C_COAT_LIGHT = C_DEEP_TEAL
C_CAPE       = (0x4A, 0x6E, 0x7A, 0xCC) # 半透明玻璃披肩
C_SCARF      = (0x5A, 0x8A, 0x92)
C_GAUNTLET   = (0x3A, 0x5A, 0x62, 0xDD)
C_GAUNTLET_GLOW = C_AMBER_VOI
C_THROAT     = C_AMBER_VOI
C_EYE_WHITE  = C_PALE_RES
C_EYE_PUPIL  = C_INK_NAVY

# 画布
CELL_W, CELL_H = 48, 64

def new_frame():
    """创建透明帧。"""
    return Image.new("RGBA", (CELL_W, CELL_H), (0,0,0,0))

def put_pixel(img, x, y, color):
    """绘制单个像素。"""
    if 0 <= x < CELL_W and 0 <= y < CELL_H:
        if len(color) == 4:
            img.putpixel((x, y), color)
        else:
            img.putpixel((x, y), color + (255,))

def draw_rect(img, x, y, w, h, color):
    """绘制矩形。"""
    for dy in range(h):
        for dx in range(w):
            put_pixel(img, x+dx, y+dy, color)

def blend_color(c1, c2, t):
    """混合两种颜色。"""
    return tuple(int(c1[i] * (1-t) + c2[i] * t) for i in range(3))

# ═══════════════════════════════════════════════════════════════
# Saya 右朝向绘制函数
# ═══════════════════════════════════════════════════════════════

def draw_saya_right_idle(frame_idx: int) -> Image.Image:
    """
    绘制 Saya 右朝向 idle 帧。
    frame_idx: 0-7，用于呼吸动画偏移。
    """
    img = new_frame()
    # 呼吸偏移
    breathe = 0 if frame_idx < 4 else 1
    by = breathe  # body y offset

    # --- 后发（深色，在头部后方）---
    draw_rect(img, 18, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 16, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 26, 8+by, 4, 6, C_HAIR_DARK)

    # --- 青色长束（左侧后方）---
    draw_rect(img, 14, 10+by, 3, 10, C_HAIR_CYAN)
    draw_rect(img, 13, 14+by, 2, 8, C_HAIR_CYAN)

    # --- 身体/外套 ---
    # 躯干
    draw_rect(img, 19, 16+by, 10, 14, C_COAT)
    draw_rect(img, 20, 14+by, 8, 2, C_COAT_LIGHT)  # 领口
    # 外套细节
    draw_rect(img, 21, 18+by, 2, 10, C_COAT_LIGHT)
    draw_rect(img, 25, 18+by, 2, 10, C_COAT_LIGHT)

    # --- 腿部 ---
    # 左腿
    draw_rect(img, 20, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 20, 42+by, 4, 4, C_COAT_LIGHT)   # 靴口
    draw_rect(img, 20, 46+by, 4, 6, C_DEEP_TEAL)    # 靴子
    # 右腿
    draw_rect(img, 26, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 26, 42+by, 4, 4, C_COAT_LIGHT)
    draw_rect(img, 26, 46+by, 4, 6, C_DEEP_TEAL)

    # --- 头部 ---
    # 脸
    draw_rect(img, 20, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 20, 14+by, 8, 2, C_SKIN_SHADOW)  # 下巴阴影
    # 眼睛（右朝向：眼睛在右侧）
    draw_rect(img, 24, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 25, 10+by, 2, 2, C_EYE_PUPIL)
    # 嘴
    put_pixel(img, 23, 13+by, C_SKIN_SHADOW)

    # --- 前发 ---
    draw_rect(img, 20, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 22, 5+by, 4, 2, C_HAIR_DARK)
    # 刘海
    draw_rect(img, 20, 8+by, 2, 3, C_HAIR_DARK)
    draw_rect(img, 26, 8+by, 2, 3, C_HAIR_DARK)

    # --- 喉口琥珀共鸣晶体 ---
    put_pixel(img, 22, 15+by, C_THROAT)
    put_pixel(img, 23, 15+by, C_THROAT)

    # --- 左臂（解剖学左侧，画面左侧）---
    # 上臂
    draw_rect(img, 16, 18+by, 3, 8, C_COAT)
    # 前臂（露出皮肤）
    draw_rect(img, 15, 24+by, 3, 4, C_SKIN)
    # 声匣装置（左前臂）
    draw_rect(img, 13, 26+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 14, 27+by, C_GAUNTLET_GLOW)  # 核心发光
    put_pixel(img, 15, 27+by, C_GAUNTLET_GLOW)
    # 玻璃边缘高光
    put_pixel(img, 13, 26+by, C_GLASS_CYAN)
    put_pixel(img, 13, 30+by, C_GLASS_CYAN)

    # --- 右臂（画面右侧）---
    draw_rect(img, 30, 18+by, 3, 8, C_COAT)
    draw_rect(img, 31, 24+by, 3, 4, C_SKIN)

    # --- 玻璃披肩（左肩后方）---
    # 半透明效果：用带 alpha 的颜色
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 14+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)
    # 披肩裂纹（青色高亮）
    put_pixel(img, 16, 16+by, C_GLASS_CYAN)
    put_pixel(img, 17, 18+by, C_GLASS_CYAN)
    put_pixel(img, 15, 20+by, C_GLASS_CYAN)

    # --- 声波围巾 ---
    # 围巾从脖子绕到身后
    draw_rect(img, 18, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 28, 15+by, 2, 2, C_SCARF)
    # 飘动部分（随 frame 变化）
    scarf_wave = frame_idx % 4
    if scarf_wave < 2:
        draw_rect(img, 29, 17+by, 3, 2, C_SCARF)
        draw_rect(img, 30, 19+by, 2, 2, C_SCARF)
    else:
        draw_rect(img, 28, 17+by, 3, 2, C_SCARF)
        draw_rect(img, 29, 19+by, 2, 2, C_SCARF)

    # --- 边缘光（青色轮廓，提升深背景可读性）---
    # 头部边缘
    put_pixel(img, 19, 9+by, C_GLASS_CYAN)
    put_pixel(img, 29, 9+by, C_GLASS_CYAN)
    # 声匣边缘
    put_pixel(img, 12, 27+by, C_GLASS_CYAN)
    put_pixel(img, 12, 29+by, C_GLASS_CYAN)

    return img


def draw_saya_right_run(frame_idx: int) -> Image.Image:
    """绘制 Saya 右朝向 run 帧。"""
    img = new_frame()
    # Run 动画：身体上下弹跳，腿部交替
    bounce = 1 if frame_idx % 2 == 0 else 0
    leg_phase = frame_idx % 4  # 0,1,2,3
    by = bounce

    # --- 后发 ---
    draw_rect(img, 18, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 16, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 26, 8+by, 4, 6, C_HAIR_DARK)
    # 青色长束（跑动时飘起）
    draw_rect(img, 13, 8+by, 3, 8, C_HAIR_CYAN)
    draw_rect(img, 12, 10+by, 2, 6, C_HAIR_CYAN)

    # --- 身体（跑动时前倾）---
    draw_rect(img, 20, 16+by, 10, 14, C_COAT)
    draw_rect(img, 21, 14+by, 8, 2, C_COAT_LIGHT)
    draw_rect(img, 22, 18+by, 2, 10, C_COAT_LIGHT)
    draw_rect(img, 26, 18+by, 2, 10, C_COAT_LIGHT)

    # --- 腿部（交替）---
    if leg_phase in (0, 1):
        # 左腿前伸
        draw_rect(img, 20, 30+by, 4, 10, C_INK_NAVY)
        draw_rect(img, 22, 40+by, 3, 4, C_INK_NAVY)
        draw_rect(img, 22, 44+by, 3, 4, C_DEEP_TEAL)
        # 右腿后蹬
        draw_rect(img, 26, 30+by, 4, 8, C_INK_NAVY)
        draw_rect(img, 25, 36+by, 3, 6, C_INK_NAVY)
        draw_rect(img, 24, 42+by, 3, 4, C_DEEP_TEAL)
    else:
        # 右腿前伸
        draw_rect(img, 26, 30+by, 4, 10, C_INK_NAVY)
        draw_rect(img, 27, 40+by, 3, 4, C_INK_NAVY)
        draw_rect(img, 27, 44+by, 3, 4, C_DEEP_TEAL)
        # 左腿后蹬
        draw_rect(img, 20, 30+by, 4, 8, C_INK_NAVY)
        draw_rect(img, 19, 36+by, 3, 6, C_INK_NAVY)
        draw_rect(img, 18, 42+by, 3, 4, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 21, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 21, 14+by, 8, 2, C_SKIN_SHADOW)
    # 眼睛
    draw_rect(img, 25, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 26, 10+by, 2, 2, C_EYE_PUPIL)
    put_pixel(img, 24, 13+by, C_SKIN_SHADOW)

    # --- 前发 ---
    draw_rect(img, 21, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 23, 5+by, 4, 2, C_HAIR_DARK)
    draw_rect(img, 21, 8+by, 2, 3, C_HAIR_DARK)
    draw_rect(img, 27, 8+by, 2, 3, C_HAIR_DARK)

    # --- 喉口晶体 ---
    put_pixel(img, 23, 15+by, C_THROAT)
    put_pixel(img, 24, 15+by, C_THROAT)

    # --- 左臂（声匣）---
    draw_rect(img, 17, 18+by, 3, 8, C_COAT)
    draw_rect(img, 16, 24+by, 3, 4, C_SKIN)
    draw_rect(img, 14, 26+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 15, 27+by, C_GAUNTLET_GLOW)
    put_pixel(img, 16, 27+by, C_GAUNTLET_GLOW)
    put_pixel(img, 14, 26+by, C_GLASS_CYAN)
    put_pixel(img, 14, 30+by, C_GLASS_CYAN)

    # --- 右臂 ---
    draw_rect(img, 31, 18+by, 3, 8, C_COAT)
    draw_rect(img, 32, 24+by, 3, 4, C_SKIN)

    # --- 玻璃披肩 ---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 15+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)
    put_pixel(img, 17, 16+by, C_GLASS_CYAN)
    put_pixel(img, 18, 18+by, C_GLASS_CYAN)

    # --- 声波围巾（跑动时飘向后方）---
    draw_rect(img, 19, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 29, 15+by, 2, 2, C_SCARF)
    # 飘动
    if leg_phase < 2:
        draw_rect(img, 30, 17+by, 4, 2, C_SCARF)
        draw_rect(img, 31, 19+by, 3, 2, C_SCARF)
    else:
        draw_rect(img, 29, 17+by, 4, 2, C_SCARF)
        draw_rect(img, 30, 19+by, 3, 2, C_SCARF)

    # --- 边缘光 ---
    put_pixel(img, 20, 9+by, C_GLASS_CYAN)
    put_pixel(img, 30, 9+by, C_GLASS_CYAN)
    put_pixel(img, 13, 27+by, C_GLASS_CYAN)

    return img


def draw_saya_right_jump() -> Image.Image:
    """绘制 Saya 右朝向 jump 帧（上升）。"""
    img = new_frame()
    by = -2  # 身体略高

    # --- 后发 ---
    draw_rect(img, 18, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 16, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 26, 8+by, 4, 6, C_HAIR_DARK)
    # 青色长束（跳起时向上飘）
    draw_rect(img, 14, 6+by, 3, 10, C_HAIR_CYAN)
    draw_rect(img, 13, 4+by, 2, 8, C_HAIR_CYAN)

    # --- 身体 ---
    draw_rect(img, 19, 16+by, 10, 14, C_COAT)
    draw_rect(img, 20, 14+by, 8, 2, C_COAT_LIGHT)

    # --- 腿部（跳起时弯曲）---
    draw_rect(img, 20, 30+by, 4, 8, C_INK_NAVY)
    draw_rect(img, 22, 36+by, 5, 4, C_INK_NAVY)  # 膝盖抬起
    draw_rect(img, 25, 38+by, 3, 4, C_DEEP_TEAL)
    draw_rect(img, 26, 30+by, 4, 8, C_INK_NAVY)
    draw_rect(img, 27, 34+by, 4, 4, C_INK_NAVY)
    draw_rect(img, 28, 38+by, 3, 4, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 20, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 25, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 26, 10+by, 2, 2, C_EYE_PUPIL)

    # --- 前发 ---
    draw_rect(img, 20, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 22, 5+by, 4, 2, C_HAIR_DARK)

    # --- 喉口晶体 ---
    put_pixel(img, 22, 15+by, C_THROAT)
    put_pixel(img, 23, 15+by, C_THROAT)

    # --- 左臂（声匣，跳起时举起）---
    draw_rect(img, 16, 16+by, 3, 8, C_COAT)
    draw_rect(img, 15, 14+by, 3, 4, C_SKIN)
    draw_rect(img, 13, 12+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 14, 13+by, C_GAUNTLET_GLOW)
    put_pixel(img, 15, 13+by, C_GAUNTLET_GLOW)
    put_pixel(img, 13, 12+by, C_GLASS_CYAN)

    # --- 右臂 ---
    draw_rect(img, 30, 16+by, 3, 8, C_COAT)
    draw_rect(img, 31, 14+by, 3, 4, C_SKIN)

    # --- 玻璃披肩 ---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 14+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)

    # --- 声波围巾（跳起时向后飘）---
    draw_rect(img, 18, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 28, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 30, 16+by, 4, 2, C_SCARF)
    draw_rect(img, 31, 18+by, 3, 2, C_SCARF)

    return img


def draw_saya_right_fall() -> Image.Image:
    """绘制 Saya 右朝向 fall 帧（下落）。"""
    img = new_frame()
    by = 1  # 身体略低

    # --- 后发 ---
    draw_rect(img, 18, 6+by, 10, 8, C_HAIR_DARK)
    draw_rect(img, 16, 8+by, 4, 6, C_HAIR_DARK)
    draw_rect(img, 26, 8+by, 4, 6, C_HAIR_DARK)
    # 青色长束（下落时向上飘）
    draw_rect(img, 14, 4+by, 3, 10, C_HAIR_CYAN)

    # --- 身体 ---
    draw_rect(img, 19, 16+by, 10, 14, C_COAT)
    draw_rect(img, 20, 14+by, 8, 2, C_COAT_LIGHT)

    # --- 腿部（下落时伸直）---
    draw_rect(img, 20, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 20, 44+by, 4, 4, C_DEEP_TEAL)
    draw_rect(img, 26, 30+by, 4, 14, C_INK_NAVY)
    draw_rect(img, 26, 44+by, 4, 4, C_DEEP_TEAL)

    # --- 头部 ---
    draw_rect(img, 20, 8+by, 8, 8, C_SKIN)
    draw_rect(img, 25, 10+by, 3, 2, C_EYE_WHITE)
    draw_rect(img, 26, 10+by, 2, 2, C_EYE_PUPIL)

    # --- 前发 ---
    draw_rect(img, 20, 6+by, 8, 3, C_HAIR_DARK)
    draw_rect(img, 22, 5+by, 4, 2, C_HAIR_DARK)

    # --- 喉口晶体 ---
    put_pixel(img, 22, 15+by, C_THROAT)
    put_pixel(img, 23, 15+by, C_THROAT)

    # --- 左臂（声匣，下落时自然下垂）---
    draw_rect(img, 16, 18+by, 3, 8, C_COAT)
    draw_rect(img, 15, 24+by, 3, 6, C_SKIN)
    draw_rect(img, 13, 28+by, 4, 5, C_GAUNTLET)
    put_pixel(img, 14, 29+by, C_GAUNTLET_GLOW)
    put_pixel(img, 15, 29+by, C_GAUNTLET_GLOW)

    # --- 右臂 ---
    draw_rect(img, 30, 18+by, 3, 8, C_COAT)
    draw_rect(img, 31, 24+by, 3, 6, C_SKIN)

    # --- 玻璃披肩 ---
    for dy in range(10):
        for dx in range(6):
            if (dx+dy) % 3 == 0:
                px = 14+dx
                py = 14+by+dy
                if 0 <= px < CELL_W and 0 <= py < CELL_H:
                    img.putpixel((px, py), C_CAPE)

    # --- 声波围巾（下落时向上飘）---
    draw_rect(img, 18, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 28, 15+by, 2, 2, C_SCARF)
    draw_rect(img, 27, 13+by, 3, 2, C_SCARF)
    draw_rect(img, 26, 11+by, 2, 2, C_SCARF)

    return img


def flip_horizontal(img: Image.Image) -> Image.Image:
    """水平翻转图像。"""
    return img.transpose(Image.FLIP_LEFT_RIGHT)


def main():
    print("=" * 60)
    print("T017: 程序化绘制 Saya Spritesheet")
    print("=" * 60)

    output_dir = Path("assets/sprites")
    output_dir.mkdir(parents=True, exist_ok=True)

    # --- 生成右朝向帧 ---
    print("\n生成右朝向帧...")
    right_frames = []
    for i in range(8):
        right_frames.append(draw_saya_right_idle(i))
    for i in range(8):
        right_frames.append(draw_saya_right_run(i))
    right_frames.append(draw_saya_right_jump())
    right_frames.append(draw_saya_right_fall())
    print(f"  右朝向: {len(right_frames)} 帧")

    # --- 生成左朝向帧（翻转）---
    print("生成左朝向帧（翻转）...")
    left_frames = [flip_horizontal(f) for f in right_frames]
    print(f"  左朝向: {len(left_frames)} 帧")

    # --- 打包 Spritesheet ---
    print("\n打包 Spritesheet...")

    # 右朝向
    right_w = CELL_W * len(right_frames)
    right_sheet = Image.new("RGBA", (right_w, CELL_H), (0,0,0,0))
    for i, f in enumerate(right_frames):
        right_sheet.paste(f, (i * CELL_W, 0))
    right_path = output_dir / "saya_spritesheet_right.png"
    right_sheet.save(right_path, "PNG", optimize=True)
    print(f"  右朝向: {right_path} ({right_sheet.size})")

    # 左朝向
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
        "total_frames": len(right_frames),
        "method": "procedural_pixel_art",
        "notes": "左朝向为右朝向水平翻转；正式左朝向需单独绘制以精确控制左臂声匣位置",
    }
    meta_path = output_dir / "saya_spritesheet_meta.json"
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2, ensure_ascii=False)
    print(f"  元数据: {meta_path}")

    print("\n" + "=" * 60)
    print("T017 完成!")
    print("=" * 60)


if __name__ == "__main__":
    main()
