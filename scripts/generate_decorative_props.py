#!/usr/bin/env python3
"""
程序化生成 Voxglass 装饰物件集合（T090）。
6 个小物件，氛围装饰用，无碰撞，挂在平台/墙边/角落做视觉密度。
色板严格遵循 STYLE_GUIDE.md。

物件清单：
  1. hourglass        12x16  沙漏 — 边墙小桌或石台
  2. wave_totem       12x24  声波图腾 — 走廊中轴立柱
  3. hanging_bell     8x10   悬挂小铃铛 — 拱门梁下
  4. crystal_cluster  16x12  水晶簇 — 地面角落
  5. standing_lantern 8x20   立式灯柱 — 走廊转角
  6. sound_pillar     8x24   声波刻度柱 — 存档点附近
"""

import math
import os

from PIL import Image, ImageDraw

# === Voxglass 风格色板（与 STYLE_GUIDE.md 一致） ===
INK_NAVY        = (8, 20, 38)
ARCHIVE_BLUE    = (18, 51, 74)
DEEP_TEAL       = (29, 101, 112)
GLASS_CYAN      = (105, 199, 206)
PALE_RESONANCE  = (183, 231, 221)
MUTED_VIOLET    = (101, 80, 106)
CORAL_PULSE     = (232, 109, 90)
AMBER_VOICE     = (242, 182, 110)
WARM_PARCHMENT  = (230, 213, 184)
ABYSS_BLACK     = (5, 7, 13)

OUTLINE = INK_NAVY  # 1px 描边色

OUTPUT_DIR = "/workspace/assets/props/decorative"
os.makedirs(OUTPUT_DIR, exist_ok=True)


def _new_canvas(w: int, h: int) -> Image.Image:
    """新建透明画布。"""
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def _add_outline(img: Image.Image, color=OUTLINE) -> Image.Image:
    """在 alpha 边缘外侧加 1px 描边。简单实现：扫描所有非透明像素，
    把它们的 4 邻透明像素置为 outline color。"""
    px = img.load()
    w, h = img.size
    out = img.copy()
    opx = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 30:
                # 给 4 邻透明像素打 outline
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        na = opx[nx, ny][3]
                        if na < 30:
                            opx[nx, ny] = (*color, 255)
    return out


# === 1. Hourglass 沙漏 ===
def draw_hourglass() -> Image.Image:
    w, h = 12, 16
    img = _new_canvas(w, h)
    d = ImageDraw.Draw(img)

    # 上下顶/底木盖（深档案蓝）
    d.rectangle([2, 0, 9, 2], fill=(*ARCHIVE_BLUE, 255))
    d.rectangle([2, 14, 9, 16], fill=(*ARCHIVE_BLUE, 255))
    # 木盖顶边
    d.rectangle([2, 0, 9, 1], fill=(*DEEP_TEAL, 255))
    d.rectangle([2, 15, 9, 16], fill=(*DEEP_TEAL, 255))

    # 玻璃壳（玻璃青色细边）
    # 左玻璃
    d.line([(3, 2), (5, 8)], fill=(*GLASS_CYAN, 255), width=1)
    d.line([(3, 14), (5, 8)], fill=(*GLASS_CYAN, 255), width=1)
    # 右玻璃
    d.line([(8, 2), (6, 8)], fill=(*GLASS_CYAN, 255), width=1)
    d.line([(8, 14), (6, 8)], fill=(*GLASS_CYAN, 255), width=1)
    # 玻璃中线
    d.line([(5, 8), (6, 8)], fill=(*GLASS_CYAN, 255), width=1)

    # 上半沙：暖琥珀填充三角形
    for y in range(2, 8):
        # 沙水平宽度从 4 (y=2) 缩到 0 (y=8)
        ww = 4 - (y - 2)
        if ww <= 0:
            break
        d.line([(6 - ww, y), (5 + ww, y)], fill=(*AMBER_VOICE, 220), width=1)

    # 下半沙堆：梯形，从 1 像素渐宽到 4 像素
    for y in range(8, 14):
        ww = (y - 8) + 1
        if ww > 4:
            ww = 4
        d.line([(6 - ww, y), (5 + ww, y)], fill=(*AMBER_VOICE, 220), width=1)

    # 沙流：中央细流（珊瑚色脉冲点）
    d.line([(5, 8), (6, 8)], fill=(*CORAL_PULSE, 255), width=1)
    d.line([(5, 9), (6, 9)], fill=(*CORAL_PULSE, 180), width=1)

    img = _add_outline(img, OUTLINE)
    return img


# === 2. Wave Totem 声波图腾 ===
def draw_wave_totem() -> Image.Image:
    w, h = 12, 24
    img = _new_canvas(w, h)
    d = ImageDraw.Draw(img)

    # 基座
    d.rectangle([1, 21, 10, 23], fill=(*ARCHIVE_BLUE, 255))
    d.rectangle([2, 20, 9, 22], fill=(*DEEP_TEAL, 255))

    # 柱身：青蓝色梯形（底宽 6，顶宽 4）
    for y in range(6, 20):
        ww = 3 + (20 - y) // 5
        d.line([(6 - ww, y), (5 + ww, y)], fill=(*ARCHIVE_BLUE, 240), width=1)

    # 柱身高光（左侧细线）
    d.line([(4, 7), (4, 19)], fill=(*PALE_RESONANCE, 80), width=1)

    # 顶部水晶头：菱形
    cx, cy = 6, 4
    # 外菱
    d.polygon([(cx, 0), (cx + 4, cy), (cx, 8), (cx - 4, cy)], fill=(*MUTED_VIOLET, 200))
    # 内菱（更亮）
    d.polygon([(cx, 2), (cx + 2, cy), (cx, 6), (cx - 2, cy)], fill=(*GLASS_CYAN, 200))
    # 核心点
    d.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*AMBER_VOICE, 255))

    # 顶部波形环（柱头上方）
    for r in [5, 6]:
        # 用 4 个点模拟环
        for ang in [0, 90, 180, 270]:
            rad = math.radians(ang)
            px = cx + r * math.cos(rad)
            py = (cy - 1) + r * math.sin(rad) * 0.4
            d.ellipse([px - 0.5, py - 0.5, px + 0.5, py + 0.5], fill=(*GLASS_CYAN, 180))

    img = _add_outline(img, OUTLINE)
    return img


# === 3. Hanging Bell 悬挂小铃铛 ===
def draw_hanging_bell() -> Image.Image:
    w, h = 8, 10
    img = _new_canvas(w, h)
    d = ImageDraw.Draw(img)

    # 顶部挂钩（横线 + 圆环）
    d.line([(3, 0), (4, 0)], fill=(*PALE_RESONANCE, 255), width=1)
    d.line([(3, 1), (4, 1)], fill=(*GLASS_CYAN, 200), width=1)
    # 吊绳
    d.line([(3, 1), (3, 2)], fill=(*MUTED_VIOLET, 200), width=1)
    d.line([(4, 1), (4, 2)], fill=(*MUTED_VIOLET, 200), width=1)

    # 铃身（梯形钟）
    d.polygon([(2, 3), (5, 3), (6, 7), (1, 7)], fill=(*ARCHIVE_BLUE, 255))
    # 铃身边缘高光
    d.line([(2, 3), (1, 7)], fill=(*GLASS_CYAN, 220), width=1)
    d.line([(5, 3), (6, 7)], fill=(*GLASS_CYAN, 200), width=1)
    # 铃口（细横线）
    d.line([(1, 7), (6, 7)], fill=(*DEEP_TEAL, 255), width=1)
    d.line([(1, 8), (6, 8)], fill=(*ABYSS_BLACK, 200), width=1)

    # 铃内光点
    d.ellipse([3, 5, 4, 6], fill=(*AMBER_VOICE, 220))

    # 底部铃舌
    d.ellipse([3, 8, 4, 9], fill=(*CORAL_PULSE, 220))

    img = _add_outline(img, OUTLINE)
    return img


# === 4. Crystal Cluster 水晶簇 ===
def draw_crystal_cluster() -> Image.Image:
    w, h = 16, 12
    img = _new_canvas(w, h)
    d = ImageDraw.Draw(img)

    # 底座（岩石层）
    d.rectangle([1, 10, 14, 11], fill=(*ARCHIVE_BLUE, 255))
    d.rectangle([1, 10, 14, 10], fill=(*DEEP_TEAL, 220))

    # 三个菱形水晶（左低中高）
    crystals = [
        # (cx, top, bottom, half_w, color, hi)
        (3,  4, 10, 2, MUTED_VIOLET, GLASS_CYAN),       # 左
        (7,  1, 10, 3, GLASS_CYAN, PALE_RESONANCE),      # 中（最高）
        (12, 5, 10, 2, ARCHIVE_BLUE, GLASS_CYAN),        # 右
    ]
    for cx, top, bot, hw, col, hi in crystals:
        # 菱形
        d.polygon([(cx, top), (cx + hw, (top + bot) // 2),
                   (cx, bot), (cx - hw, (top + bot) // 2)], fill=(*col, 240))
        # 左侧高光
        d.line([(cx, top), (cx - hw, (top + bot) // 2)], fill=(*hi, 220), width=1)
        # 中央高光条
        d.line([(cx, top), (cx, bot)], fill=(*hi, 120), width=1)
        # 底部反光
        d.line([(cx, bot - 1), (cx, bot)], fill=(*WARM_PARCHMENT, 100), width=1)

    # 中央水晶核心
    d.ellipse([6, 4, 8, 6], fill=(*AMBER_VOICE, 255))

    img = _add_outline(img, OUTLINE)
    return img


# === 5. Standing Lantern 立式灯柱 ===
def draw_standing_lantern() -> Image.Image:
    w, h = 8, 20
    img = _new_canvas(w, h)
    d = ImageDraw.Draw(img)

    # 底座
    d.rectangle([1, 18, 6, 19], fill=(*ARCHIVE_BLUE, 255))
    d.rectangle([1, 17, 6, 18], fill=(*DEEP_TEAL, 255))
    # 柱身
    d.line([(3, 5), (3, 17)], fill=(*ARCHIVE_BLUE, 255), width=1)
    d.line([(4, 5), (4, 17)], fill=(*ARCHIVE_BLUE, 255), width=1)
    # 柱身高光
    d.line([(3, 6), (3, 16)], fill=(*GLASS_CYAN, 120), width=1)
    # 柱身中段装饰环
    d.line([(2, 11), (5, 11)], fill=(*MUTED_VIOLET, 200), width=1)
    d.line([(2, 12), (5, 12)], fill=(*DEEP_TEAL, 220), width=1)

    # 灯头
    d.rectangle([2, 1, 5, 5], fill=(*ARCHIVE_BLUE, 255))
    # 灯内玻璃
    d.rectangle([3, 2, 4, 4], fill=(*AMBER_VOICE, 255))
    # 灯芯
    d.line([(3, 3), (4, 3)], fill=(*WARM_PARCHMENT, 255), width=1)
    # 灯顶
    d.polygon([(2, 1), (5, 1), (4, 0), (3, 0)], fill=(*DEEP_TEAL, 255))
    # 灯顶挂钩
    d.line([(3, 0), (4, 0)], fill=(*MUTED_VIOLET, 200), width=1)

    # 灯外辉光（青色光晕）
    d.line([(1, 2), (1, 4)], fill=(*GLASS_CYAN, 100), width=1)
    d.line([(6, 2), (6, 4)], fill=(*GLASS_CYAN, 100), width=1)

    img = _add_outline(img, OUTLINE)
    return img


# === 6. Sound Pillar 声波刻度柱 ===
def draw_sound_pillar() -> Image.Image:
    w, h = 8, 24
    img = _new_canvas(w, h)
    d = ImageDraw.Draw(img)

    # 底座
    d.rectangle([1, 22, 6, 23], fill=(*ARCHIVE_BLUE, 255))
    d.rectangle([1, 21, 6, 22], fill=(*DEEP_TEAL, 255))

    # 柱身（细长矩形）
    d.rectangle([2, 4, 5, 21], fill=(*ARCHIVE_BLUE, 255))
    d.rectangle([3, 4, 4, 21], fill=(*DEEP_TEAL, 220))

    # 波形刻度（5 个琥珀色横线，由下到上变短）
    for i, y in enumerate([18, 14, 10, 7, 4]):
        # 第 i 个刻度从右到左逐渐变短
        ww = 3 - i // 2
        if ww < 1:
            ww = 1
        d.line([(5 - ww, y), (5, y)], fill=(*AMBER_VOICE, 220), width=1)

    # 顶部尖锥
    d.polygon([(2, 4), (5, 4), (3, 0), (4, 0)], fill=(*MUTED_VIOLET, 220))
    # 顶部辉光
    d.line([(2, 1), (2, 3)], fill=(*GLASS_CYAN, 200), width=1)
    d.line([(5, 1), (5, 3)], fill=(*GLASS_CYAN, 200), width=1)
    d.ellipse([3, 0, 4, 1], fill=(*PALE_RESONANCE, 255))

    img = _add_outline(img, OUTLINE)
    return img


# === 4x NEAREST 放大导出（与项目内 sprite 一致） ===
def save_with_extras(img: Image.Image, name: str, out_dir: str) -> None:
    base = os.path.join(out_dir, f"{name}.png")
    img.save(base)
    # 4x 放大版（编辑器和 HUD 调试视图用）
    big = img.resize((img.width * 4, img.height * 4), Image.NEAREST)
    big_path = os.path.join(out_dir, f"{name}_4x.png")
    big.save(big_path)
    print(f"  - {base} ({img.width}x{img.height})")
    print(f"  - {big_path} ({big.width}x{big.height})")


# === 主流程 ===
def main() -> None:
    props = [
        ("hourglass",        draw_hourglass),
        ("wave_totem",       draw_wave_totem),
        ("hanging_bell",     draw_hanging_bell),
        ("crystal_cluster",  draw_crystal_cluster),
        ("standing_lantern", draw_standing_lantern),
        ("sound_pillar",     draw_sound_pillar),
    ]
    print(f"Generating {len(props)} decorative props to {OUTPUT_DIR}:")
    for name, fn in props:
        img = fn()
        save_with_extras(img, name, OUTPUT_DIR)
    print("Done.")


if __name__ == "__main__":
    main()
