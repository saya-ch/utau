#!/usr/bin/env python3
"""
Voxglass 营销截图 mockup 生成器 (T083)

由于沙箱无 Xvfb / GL context，Godot 4.6.3 无法在 --headless 模式下
渲染到 framebuffer。capture_screenshot.gd 工具在桌面环境 / 真机可用，
但本迭代需要立即交付 Steam 商店截图，故使用本脚本基于既有资产
(archive_room_bg + key art + 各类 sprite) 程序化合成 6 张截图。

构图:
- 480x270 内部分辨率背景 → 1920x1080 整数倍缩放
- 按 JSON room 配置放置 enemies / interactables / hazards
- 顶部 + 底部 UI overlay (HUD 简化版)
- 标题/标签文字标注

输出:
- docs/screenshots/01_title_screen.png
- docs/screenshots/02_hub_room.png
- docs/screenshots/03_archive_01_pulse.png
- docs/screenshots/04_archive_03_boss.png
- docs/screenshots/05_archive_04_double_boss.png
- docs/screenshots/06_shop_merchant.png
"""
from __future__ import annotations
import json
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path("/workspace")
OUT = ROOT / "docs" / "screenshots"
OUT.mkdir(parents=True, exist_ok=True)

# ── Style Guide 调色板 ──
PAL = {
    "abyss":    (5,   7,  13),   # #05070D
    "ink":      (8,  20,  38),   # #081426
    "archive":  (18, 51,  74),   # #12334A
    "teal":     (29,101,112),    # #1D6570
    "cyan":     (105,199,206),   # #69C7CE
    "pale":     (183,231,221),   # #B7E7DD
    "violet":   (101, 80,106),   # #65506A
    "coral":    (232,109, 90),   # #E86D5A
    "amber":    (242,182,110),   # #F2B66E
    "parch":    (230,213,184),   # #E6D5B8
}

# 内部分辨率 480x270
INTERNAL_W, INTERNAL_H = 480, 270
# 截图输出 1920x1080 (整数倍缩放 4x)
SCALE = 4
OUT_W, OUT_H = INTERNAL_W * SCALE, INTERNAL_H * SCALE  # 1920 x 1080

# ── 字体（沙箱内可用字体） ──
def find_font(size: int) -> ImageFont.ImageFont:
    """寻找系统可用字体。优先 sans / mono。"""
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
    return ImageFont.load_default()

def find_mono(size: int) -> ImageFont.ImageFont:
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
    return find_font(size)

# ── 像素艺术资源加载（不缩放，保持 1x） ──
def load_sprite(path: str, size: tuple[int, int] | None = None) -> Image.Image:
    img = Image.open(ROOT / path).convert("RGBA")
    if size:
        img = img.resize(size, Image.NEAREST)
    return img

# ── 基础绘制工具 ──
def base_canvas(bg_path: str | None = "assets/environment/archive_room_bg.png") -> Image.Image:
    """480x270 内部画布。背景用 archive_room_bg，缩放 fill。"""
    canvas = Image.new("RGBA", (INTERNAL_W, INTERNAL_H), PAL["abyss"] + (255,))
    if bg_path:
        bg = load_sprite(bg_path)
        # bg is 480x270 已经在项目内部分辨率
        canvas.alpha_composite(bg)
    return canvas

def gradient_vignette(canvas: Image.Image, top_alpha: int = 90, bottom_alpha: int = 90) -> Image.Image:
    """顶部 + 底部渐变暗角，模拟 in-game UI 区域。"""
    w, h = canvas.size
    grad = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grad)
    # 顶部 30px 渐变
    for y in range(30):
        a = int(top_alpha * (1 - y / 30))
        gd.rectangle((0, y, w, y), fill=(0, 0, 0, a))
    # 底部 30px 渐变
    for y in range(30):
        a = int(bottom_alpha * (1 - y / 30))
        gd.rectangle((0, h - 1 - y, w, h - 1 - y), fill=(0, 0, 0, a))
    canvas.alpha_composite(grad)
    return canvas

def upscale_nearest(img: Image.Image, factor: int = SCALE) -> Image.Image:
    return img.resize((img.width * factor, img.height * factor), Image.NEAREST)

def draw_text_with_outline(draw, xy, text, font, fill, outline=PAL["abyss"], outline_w=2):
    """带描边的文字绘制"""
    x, y = xy
    for dx in range(-outline_w, outline_w + 1):
        for dy in range(-outline_w, outline_w + 1):
            if dx == 0 and dy == 0:
                continue
            draw.text((x + dx, y + dy), text, font=font, fill=outline)
    draw.text(xy, text, font=font, fill=fill)

# ── HUD 元素 ──
def draw_hud(canvas: Image.Image, *, hp: int = 4, max_hp: int = 4,
             resonance: float = 0.75, shards: int = 0, room: str = "archive_01") -> Image.Image:
    """简化版 HUD: 顶部 HP 铃铛 + 共鸣能量 + 碎片。"""
    d = ImageDraw.Draw(canvas)
    # 顶部 18px HUD 区域
    # HP 铃铛：4 段玻璃青色段
    for i in range(max_hp):
        x = 8 + i * 14
        col = PAL["cyan"] if i < hp else PAL["violet"]
        d.rectangle((x, 4, x + 10, 14), fill=col)
        d.rectangle((x, 4, x + 10, 14), outline=PAL["abyss"])
    # 共鸣能量条
    bar_x, bar_y, bar_w, bar_h = 72, 6, 80, 6
    d.rectangle((bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1),
                outline=PAL["pale"])
    fill_w = int(bar_w * resonance)
    d.rectangle((bar_x, bar_y, bar_x + fill_w, bar_y + bar_h), fill=PAL["cyan"])
    # 标签
    f = find_mono(8)
    draw_text_with_outline(d, (bar_x, bar_y - 9), "RESONANCE", f, PAL["pale"], outline_w=1)
    # 右上角碎片
    f2 = find_mono(8)
    txt = f"◆ {shards}"
    draw_text_with_outline(d, (INTERNAL_W - 36, 4), txt, f2, PAL["amber"], outline_w=1)
    # 房间名
    f3 = find_mono(6)
    draw_text_with_outline(d, (INTERNAL_W // 2 - len(room) * 3, 4),
                           room.upper(), f3, PAL["parch"], outline_w=1)
    return canvas

# ── 实体绘制 ──
def draw_saya(canvas: Image.Image, x: int, y: int, facing_right: bool = True) -> None:
    """放置 Saya 角色 (使用 saya_spritesheet_right/left 第一帧 ~48x64)"""
    path = "assets/sprites/saya_spritesheet_right.png" if facing_right else "assets/sprites/saya_spritesheet_left.png"
    sprite = load_sprite(path)
    # spritesheet is 864x64 = 18 帧，每帧 48x64
    # 取第一帧 idle
    frame = sprite.crop((0, 0, 48, 64))
    canvas.alpha_composite(frame, (x - 24, y - 64))

def draw_silence_mote(canvas: Image.Image, x: int, y: int) -> None:
    sprite = load_sprite("assets/enemies/silence_mote/silence_mote.png")
    # 64x64 画布，sprite 居中
    s = sprite.copy()
    if s.size != (48, 48):
        s = s.resize((48, 48), Image.NEAREST)
    canvas.alpha_composite(s, (x - 24, y - 24))

def draw_ink_warden(canvas: Image.Image, x: int, y: int, *, shielded: bool = True) -> None:
    sprite = load_sprite("assets/enemies/ink_warden/ink_warden.png" if shielded
                         else "assets/enemies/ink_warden/ink_warden_shield_broken.png")
    s = sprite.copy()
    if s.size != (96, 96):
        s = s.resize((96, 96), Image.NEAREST)
    canvas.alpha_composite(s, (x - 48, y - 96))

def draw_note_wisp(canvas: Image.Image, x: int, y: int) -> None:
    sprite = load_sprite("assets/enemies/note_wisp/note_wisp.png")
    s = sprite.copy()
    if s.size != (40, 40):
        s = s.resize((40, 40), Image.NEAREST)
    canvas.alpha_composite(s, (x - 20, y - 20))

def draw_voice_bell(canvas: Image.Image, x: int, y: int, repaired: bool = False) -> None:
    path = ("assets/props/voice_bell_repaired/voice_bell_repaired.png"
            if repaired else "assets/props/voice_bell_broken/voice_bell_broken.png")
    sprite = load_sprite(path)
    s = sprite.copy()
    if s.size != (32, 48):
        s = s.resize((32, 48), Image.NEAREST)
    canvas.alpha_composite(s, (x - 16, y - 48))

def draw_glass_lock(canvas: Image.Image, x: int, y: int, repaired: bool = False) -> None:
    """玻璃锁 — 简单用矩形+发光示意"""
    d = ImageDraw.Draw(canvas)
    col = PAL["amber"] if repaired else PAL["violet"]
    # 锁主体 16x40
    d.rectangle((x - 8, y - 40, x + 8, y), fill=col, outline=PAL["cyan"])
    # 玻璃门框
    d.rectangle((x - 12, y - 50, x + 12, y - 40), outline=PAL["cyan"], width=1)

def draw_hazard_water(canvas: Image.Image, x: int, y: int, w: int = 100) -> None:
    d = ImageDraw.Draw(canvas)
    d.rectangle((x - w // 2, y - 6, x + w // 2, y + 6), fill=PAL["teal"])
    # 玻璃青色波纹
    for i in range(3):
        offset = (i - 1) * 8
        d.line((x - w // 2 + 4, y - 3 + offset, x + w // 2 - 4, y - 3 + offset),
               fill=PAL["cyan"], width=1)

def draw_platform(canvas: Image.Image, x: int, y: int, w: int = 80) -> None:
    d = ImageDraw.Draw(canvas)
    d.rectangle((x - w // 2, y - 4, x + w // 2, y + 4), fill=PAL["archive"], outline=PAL["teal"])

def draw_door(canvas: Image.Image, x: int, y: int, *, open_: bool = True, label: str = "") -> None:
    d = ImageDraw.Draw(canvas)
    col = PAL["amber"] if open_ else PAL["violet"]
    d.rectangle((x - 12, y - 40, x + 12, y), fill=col, outline=PAL["cyan"], width=1)
    if label:
        f = find_mono(5)
        draw_text_with_outline(d, (x - len(label) * 3, y - 50), label, f,
                               PAL["pale"], outline_w=1)

def draw_silenced_web(canvas: Image.Image, x: int, y: int) -> None:
    """墨色丝网（Cut 目标）— 简单 4 角辐射线"""
    d = ImageDraw.Draw(canvas)
    for dx, dy in [(-12, -8), (12, -8), (-12, 8), (12, 8)]:
        d.line((x, y, x + dx, y + dy), fill=PAL["violet"], width=2)
    d.line((x - 12, y, x + 12, y), fill=PAL["violet"], width=1)
    d.line((x, y - 8, x, y + 8), fill=PAL["violet"], width=1)

def draw_pulse_ring(canvas: Image.Image, x: int, y: int, radius: int = 32) -> None:
    """Pulse 圆环 VFX — 半透明青蓝圆"""
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    d.ellipse((x - radius, y - radius, x + radius, y + radius),
              outline=PAL["cyan"], width=2)
    d.ellipse((x - radius * 0.7, y - radius * 0.7, x + radius * 0.7, y + radius * 0.7),
              outline=PAL["amber"], width=1)
    canvas.alpha_composite(overlay)

# ── 截图生成 ──
def save_full(canvas: Image.Image, name: str) -> Path:
    final = upscale_nearest(canvas, SCALE)
    out = OUT / name
    final.convert("RGB").save(out, "PNG", optimize=True)
    print(f"  ✓ {name}  {final.size[0]}x{final.size[1]}")
    return out


# ════════════════════════════════════════════════════════════
#  01 — Title Screen
# ════════════════════════════════════════════════════════════
def gen_title_screen() -> None:
    print("[01] title_screen")
    c = base_canvas()
    # 全屏暗化
    overlay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rectangle((0, 0, INTERNAL_W, INTERNAL_H), fill=(2, 12, 20, 200))
    c.alpha_composite(overlay)
    # 标题
    f_title = find_font(48)
    f_sub = find_mono(12)
    f_btn = find_mono(10)
    d = ImageDraw.Draw(c)
    title = "VOXGLASS"
    # 居中粗体
    bbox = d.textbbox((0, 0), title, font=f_title)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = (INTERNAL_W - tw) // 2
    ty = 80
    draw_text_with_outline(d, (tx, ty), title, f_title, PAL["amber"], outline_w=3)
    # 副标题
    sub = "修复被寂静吞噬的声音"
    bbox = d.textbbox((0, 0), sub, font=f_sub)
    sw = bbox[2] - bbox[0]
    draw_text_with_outline(d, ((INTERNAL_W - sw) // 2, ty + th + 8),
                           sub, f_sub, PAL["pale"], outline_w=1)
    # 按钮
    btns = ["开始", "继续修复", "致谢", "退出"]
    btn_y = 180
    for i, b in enumerate(btns):
        y = btn_y + i * 18
        # 高亮第一个
        col = PAL["amber"] if i == 0 else PAL["pale"]
        d.rectangle((INTERNAL_W // 2 - 60, y - 4, INTERNAL_W // 2 + 60, y + 12),
                    outline=col, width=1)
        bbox = d.textbbox((0, 0), b, font=f_btn)
        bw = bbox[2] - bbox[0]
        draw_text_with_outline(d, ((INTERNAL_W - bw) // 2, y),
                               b, f_btn, col, outline_w=1)
    # 角标
    f_ver = find_mono(6)
    draw_text_with_outline(d, (8, INTERNAL_H - 12),
                           "v0.43  |  ALPHA  |  Godot 4.6.3", f_ver, PAL["violet"], outline_w=1)
    save_full(c, "01_title_screen.png")


# ════════════════════════════════════════════════════════════
#  02 — Hub Room
# ════════════════════════════════════════════════════════════
def gen_hub() -> None:
    print("[02] hub_room")
    c = base_canvas()
    # 平台
    draw_platform(c, 80, 200, 120)
    draw_platform(c, 400, 200, 120)
    draw_platform(c, 240, 230, 80)  # 中央 NPC 平台
    # 4 扇门（Hub → archive_01/02/03/04）
    doors = [
        (60,  200, "01", "回响厅"),
        (180, 200, "02", "水廊"),
        (300, 200, "03", "高阶档案"),
        (420, 200, "04", "共鸣祭坛"),
    ]
    for x, y, num, label in doors:
        draw_door(c, x, y, open_=True)
        f = find_mono(5)
        d = ImageDraw.Draw(c)
        draw_text_with_outline(d, (x - 8, y - 50), num, f, PAL["amber"], outline_w=1)
        draw_text_with_outline(d, (x - 16, y + 4), label, f, PAL["pale"], outline_w=1)
    # 中央墨守者剪影 (ArchivistShadow)
    silhouette = load_sprite("assets/enemies/ink_warden/ink_warden.png")
    s = silhouette.copy()
    s.thumbnail((48, 64), Image.NEAREST)
    # 透明化 + 紫色
    pixels = s.load()
    for y in range(s.height):
        for x in range(s.width):
            p = pixels[x, y]
            if p[3] > 0:
                pixels[x, y] = (PAL["violet"][0], PAL["violet"][1], PAL["violet"][2], int(p[3] * 0.55))
    c.alpha_composite(s, (240 - 24, 130))
    # 底光
    overlay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.ellipse((220, 192, 260, 208), fill=(PAL["coral"][0], PAL["coral"][1], PAL["coral"][2], 100))
    c.alpha_composite(overlay)
    # HUD
    draw_hud(c, hp=4, max_hp=4, resonance=0.85, shards=12, room="hub")
    # 中央文字
    f = find_mono(7)
    d = ImageDraw.Draw(c)
    draw_text_with_outline(d, (200, 175), "墨守者剪影", f, PAL["pale"], outline_w=1)
    save_full(c, "02_hub_room.png")


# ════════════════════════════════════════════════════════════
#  03 — Archive 01 (Pulse 战斗)
# ════════════════════════════════════════════════════════════
def gen_archive_01_pulse() -> None:
    print("[03] archive_01_pulse")
    c = base_canvas()
    # 按 archive_01.json 布局
    # platforms
    for x, y, w in [(120, 200, 80), (280, 170, 80), (400, 140, 80)]:
        draw_platform(c, x, y, w)
    # hazards
    draw_hazard_water(c, 200, 240, 120)
    # enemies
    draw_silence_mote(c, 320, 160)
    # interactables
    draw_glass_lock(c, 440, 116)
    draw_voice_bell(c, 280, 146)
    draw_silenced_web(c, 380, 200)
    # Saya (朝向右，正在释放 Pulse)
    draw_saya(c, 240, 200, facing_right=True)
    # Pulse 圆环 (Saya 朝向 direction)
    draw_pulse_ring(c, 270, 200, radius=36)
    # HUD
    draw_hud(c, hp=3, max_hp=4, resonance=0.65, shards=2, room="archive_01")
    # 提示标签
    f = find_mono(6)
    d = ImageDraw.Draw(c)
    draw_text_with_outline(d, (8, INTERNAL_H - 10),
                           "按 [J] 释放 Pulse 声波 — 推开敌人、修复玻璃锁与声匣",
                           f, PAL["pale"], outline_w=1)
    save_full(c, "03_archive_01_pulse.png")


# ════════════════════════════════════════════════════════════
#  04 — Archive 03 (Boss 战)
# ════════════════════════════════════════════════════════════
def gen_archive_03_boss() -> None:
    print("[04] archive_03_boss")
    c = base_canvas()
    # 按 archive_03.json 阶梯布局
    for x, y, w in [(60, 210, 64), (140, 180, 64), (240, 150, 64), (340, 120, 64), (440, 90, 64)]:
        draw_platform(c, x, y, w)
    # 危险水域
    draw_hazard_water(c, 120, 240, 100)
    draw_hazard_water(c, 380, 240, 100)
    # 阶梯 enemies
    draw_silence_mote(c, 140, 164)
    draw_silence_mote(c, 340, 104)
    draw_note_wisp(c, 60, 194)
    # Boss (中央 InkWarden)
    draw_ink_warden(c, 240, 134, shielded=True)
    # Saya (左下，朝向 Boss)
    draw_saya(c, 100, 200, facing_right=True)
    # Pulse 正在击破护盾
    draw_pulse_ring(c, 240, 134, radius=60)
    # HUD
    draw_hud(c, hp=2, max_hp=4, resonance=0.50, shards=5, room="archive_03")
    # 标签
    f = find_mono(6)
    d = ImageDraw.Draw(c)
    draw_text_with_outline(d, (8, INTERNAL_H - 10),
                           "Pulse 击破 InkWarden 护盾后立即集火",
                           f, PAL["coral"], outline_w=1)
    # 危险标签
    draw_text_with_outline(d, (208, 78), "INK WARDEN", f, PAL["coral"], outline_w=1)
    save_full(c, "04_archive_03_boss.png")


# ════════════════════════════════════════════════════════════
#  05 — Archive 04 (双 Boss)
# ════════════════════════════════════════════════════════════
def gen_archive_04_double_boss() -> None:
    print("[05] archive_04_double_boss")
    c = base_canvas()
    # archive_04 平台
    for x, y, w in [(80, 200, 80), (200, 160, 80), (320, 160, 80), (440, 200, 80), (240, 100, 120)]:
        draw_platform(c, x, y, w)
    # 双水域
    draw_hazard_water(c, 40, 240, 120)
    draw_hazard_water(c, 320, 240, 120)
    # 双 InkWarden
    draw_ink_warden(c, 200, 144, shielded=True)
    draw_ink_warden(c, 320, 144, shielded=True)
    # 中央 silence_mote
    draw_silence_mote(c, 240, 80)
    # Saya (左侧，正在冲刺)
    draw_saya(c, 80, 200, facing_right=True)
    # Pulse VFX 双发
    draw_pulse_ring(c, 200, 144, radius=48)
    draw_pulse_ring(c, 320, 144, radius=48)
    # 中央平台声匣 (双修复目标)
    draw_voice_bell(c, 200, 136, repaired=True)
    draw_voice_bell(c, 320, 136, repaired=True)
    draw_glass_lock(c, 180, 76)
    # HUD
    draw_hud(c, hp=2, max_hp=4, resonance=0.40, shards=8, room="archive_04")
    # 标签
    f = find_mono(6)
    d = ImageDraw.Draw(c)
    draw_text_with_outline(d, (8, INTERNAL_H - 10),
                           "共鸣祭坛 — 两位墨守者同时出现",
                           f, PAL["coral"], outline_w=1)
    # 危险标签 (双 Boss)
    draw_text_with_outline(d, (175, 50), "DOUBLE WARDEN", f, PAL["coral"], outline_w=1)
    save_full(c, "05_archive_04_double_boss.png")


# ════════════════════════════════════════════════════════════
#  06 — Shop / Merchant
# ════════════════════════════════════════════════════════════
def gen_shop_merchant() -> None:
    print("[06] shop_merchant")
    c = base_canvas()
    # 底部暗化 (Shop UI 在底部)
    overlay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rectangle((0, 140, INTERNAL_W, INTERNAL_H), fill=(2, 12, 20, 200))
    c.alpha_composite(overlay)
    # Hub 背景淡淡保留
    # 平台 (中央 NPC 站位)
    draw_platform(c, 240, 230, 80)
    # SilentMerchant 精灵
    npc = load_sprite("assets/ui/npc/silent_merchant_sprite_64.png")
    s = npc.copy()
    if s.size != (48, 64):
        s = s.resize((48, 64), Image.NEAREST)
    c.alpha_composite(s, (240 - 24, 230 - 64))
    # 名字标签
    f = find_mono(6)
    d = ImageDraw.Draw(c)
    draw_text_with_outline(d, (210, 158), "无声商贩", f, PAL["amber"], outline_w=1)
    # Shop UI Panel
    panel_x, panel_y, panel_w, panel_h = 20, 175, INTERNAL_W - 40, 80
    d.rectangle((panel_x, panel_y, panel_x + panel_w, panel_y + panel_h),
                outline=PAL["cyan"], width=1, fill=(2, 12, 20, 220))
    # 标题
    f_title = find_mono(8)
    draw_text_with_outline(d, (panel_x + 6, panel_y + 4), "— 共鸣商店 —", f_title, PAL["amber"], outline_w=1)
    draw_text_with_outline(d, (panel_x + panel_w - 60, panel_y + 4),
                           "◆ 24", f_title, PAL["amber"], outline_w=1)
    # 商品列表
    items = [
        ("heart_crystal",    "心之晶",  "HP+1",       8),
        ("resonance_chime",  "共鸣铃",  "RES+25",    10),
        ("pulse_focus",      "聚焦器",  "PULSE +20%", 12),
        ("echo_charm",       "回响符",  "击杀回响",   15),
        ("silence_breaker",  "破寂者",  "护盾一击破", 20),
    ]
    f_item = find_mono(5)
    f_price = find_mono(5)
    for i, (id_, name, eff, price) in enumerate(items):
        y = panel_y + 16 + i * 11
        # 已购标记
        marker = "✓" if i < 1 else " "
        txt = f"{marker} {name:<10}  {eff:<10}"
        draw_text_with_outline(d, (panel_x + 6, y), txt, f_item, PAL["pale"], outline_w=1)
        price_col = PAL["violet"] if i < 1 else PAL["amber"]
        draw_text_with_outline(d, (panel_x + panel_w - 50, y),
                               f"◆ {price}", f_price, price_col, outline_w=1)
    # HUD
    draw_hud(c, hp=3, max_hp=4, resonance=0.75, shards=24, room="hub:shop")
    save_full(c, "06_shop_merchant.png")


# ════════════════════════════════════════════════════════════
#  Main
# ════════════════════════════════════════════════════════════
def main() -> None:
    print(f"Voxglass 营销截图合成 → {OUT}")
    print(f"  Scale: {SCALE}x → {OUT_W}x{OUT_H} PNGs")
    print()
    gen_title_screen()
    gen_hub()
    gen_archive_01_pulse()
    gen_archive_03_boss()
    gen_archive_04_double_boss()
    gen_shop_merchant()
    print()
    print(f"Done. {len(list(OUT.glob('*.png')))} PNGs in {OUT}")
    for p in sorted(OUT.glob("*.png")):
        sz = p.stat().st_size
        print(f"  {p.name:36s}  {sz/1024:6.1f} KB")

if __name__ == "__main__":
    main()
