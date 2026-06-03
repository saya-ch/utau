#!/usr/bin/env python3
"""
程序化生成 8 个成就图标（Voxglass 风格）
对应 data/achievements.json 中的 icon_hint 字段：
- amber_dot       → first_steps       (第一步)
- coral_pulse     → voice_purifier    (声音净化者)
- amber_shard     → resonance_collector (共鸣收集者)
- three_circles   → triple_voice      (三声齐鸣)
- coral_slash     → first_cut         (切断腐蚀)
- coral_eye       → warden_slayer     (墨守终结者)
- amber_bell      → full_archive      (完整档案)
- amber_lantern   → persistent_resonance (不灭回响)

风格：Voxglass — 16x16 像素艺术，色板严格遵循 STYLE_GUIDE.md
输出：assets/ui/achievements/<hint>/<hint>.png (16x16 + 32x32 双导出)
"""

import math
import os
from PIL import Image, ImageDraw

# STYLE_GUIDE 色板
INK_NAVY = (8, 20, 38)
ARCHIVE_BLUE = (18, 51, 74)
GLASS_CYAN = (105, 199, 206)
PALE_RESONANCE = (183, 231, 221)
MUTED_VIOLET = (101, 80, 106)
CORAL_PULSE = (232, 109, 90)
AMBER_VOICE = (242, 182, 110)
WARM_PARCHMENT = (230, 213, 184)


def _new_canvas(size: int) -> tuple:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    return img, draw


def _draw_outer_ring(draw, cx, cy, r, color, width=1):
    """绘制 1px 玻璃青色外圈（图标统一外壳）"""
    draw.ellipse(
        [cx - r, cy - r, cx + r, cy + r],
        outline=color, width=width
    )


def draw_amber_dot(size: int = 16) -> Image.Image:
    """first_steps: 起步点 — 中央琥珀色实心圆 + 青色外环"""
    img, draw = _new_canvas(size)
    cx, cy = size // 2, size // 2
    # 外环
    _draw_outer_ring(draw, cx, cy, 7, (*GLASS_CYAN, 220))
    # 内部填充（暗）
    draw.ellipse([cx - 6, cy - 6, cx + 6, cy + 6], fill=(*ARCHIVE_BLUE, 220))
    # 中央琥珀点
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(*AMBER_VOICE, 255))
    # 白色高光
    draw.ellipse([cx - 1, cy - 1, cx, cy], fill=(255, 255, 255, 255))
    return img


def draw_coral_pulse(size: int = 16) -> Image.Image:
    """voice_purifier: 声波脉冲 — 珊瑚色同心环"""
    img, draw = _new_canvas(size)
    cx, cy = size // 2, size // 2
    # 外环（玻璃青）
    _draw_outer_ring(draw, cx, cy, 7, (*GLASS_CYAN, 200))
    # 中环（珊瑚色，断开 4 段表示波）
    for i in range(4):
        a0 = i * 90 + 10
        a1 = a0 + 70
        pts = []
        for a in range(a0, a1 + 1, 6):
            rad = math.radians(a)
            pts.append((cx + 5 * math.cos(rad), cy + 5 * math.sin(rad)))
        for j in range(len(pts) - 1):
            draw.line([pts[j], pts[j + 1]], fill=(*CORAL_PULSE, 230), width=1)
    # 中心点
    draw.ellipse([cx - 1, cy - 1, cx + 2, cy + 2], fill=(*CORAL_PULSE, 255))
    return img


def draw_amber_shard(size: int = 16) -> Image.Image:
    """resonance_collector: 共鸣碎片 — 菱形碎片"""
    img, draw = _new_canvas(size)
    cx, cy = size // 2, size // 2
    # 菱形主体
    pts = [(cx, cy - 6), (cx + 4, cy), (cx, cy + 6), (cx - 4, cy)]
    draw.polygon(pts, fill=(*AMBER_VOICE, 240), outline=(*WARM_PARCHMENT, 200))
    # 内部高亮（顶部三角）
    hi = [(cx, cy - 6), (cx + 1, cy - 1), (cx - 1, cy - 1)]
    draw.polygon(hi, fill=(*WARM_PARCHMENT, 220))
    # 底部暗线
    lo = [(cx, cy + 6), (cx + 1, cy + 2), (cx - 1, cy + 2)]
    draw.polygon(lo, fill=(*MUTED_VIOLET, 200))
    return img


def draw_three_circles(size: int = 16) -> Image.Image:
    """triple_voice: 三声齐鸣 — 三个并列小圆"""
    img, draw = _new_canvas(size)
    cy = size // 2
    # 三个小圆：Pulse (青) / Bind (紫) / Cut (珊瑚)
    for i, col in enumerate([GLASS_CYAN, MUTED_VIOLET, CORAL_PULSE]):
        cx = 3 + i * 5
        draw.ellipse([cx - 2, cy - 2, cx + 3, cy + 3], fill=(*col, 255), outline=(*PALE_RESONANCE, 200))
    return img


def draw_coral_slash(size: int = 16) -> Image.Image:
    """first_cut: 斩击 — 珊瑚色斜线 + 末端散点"""
    img, draw = _new_canvas(size)
    # 主斜线（左下 → 右上）
    draw.line([(3, 13), (13, 3)], fill=(*CORAL_PULSE, 255), width=2)
    # 末端小碎点
    for px, py in [(2, 12), (4, 14), (12, 2), (14, 4)]:
        draw.ellipse([px, py, px + 1, py + 1], fill=(*AMBER_VOICE, 230))
    # 主体白色高光线
    draw.line([(5, 11), (11, 5)], fill=(255, 255, 255, 200), width=1)
    return img


def draw_coral_eye(size: int = 16) -> Image.Image:
    """warden_slayer: 墨守终结者 — 杏仁眼 + 珊瑚核心"""
    img, draw = _new_canvas(size)
    cx, cy = size // 2, size // 2
    # 眼白
    draw.ellipse([cx - 6, cy - 3, cx + 6, cy + 4], fill=(*PALE_RESONANCE, 200), outline=(*MUTED_VIOLET, 220))
    # 虹膜
    draw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=(*CORAL_PULSE, 255))
    # 瞳孔（深）
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 2], fill=(*INK_NAVY, 255))
    # 白色高光
    draw.ellipse([cx - 1, cy - 1, cx, cy], fill=(255, 255, 255, 255))
    return img


def draw_amber_bell(size: int = 16) -> Image.Image:
    """full_archive: 完整档案 — 玻璃钟罩"""
    img, draw = _new_canvas(size)
    cx, cy = size // 2, size // 2
    # 钟罩主体（梯形 + 圆顶）
    # 圆顶
    draw.ellipse([cx - 5, cy - 6, cx + 5, cy + 1], fill=(*GLASS_CYAN, 200), outline=(*AMBER_VOICE, 230))
    # 底缘
    draw.rectangle([cx - 6, cy, cx + 6, cy + 2], fill=(*AMBER_VOICE, 240))
    # 内部波形（修复后的暖色光）
    for off in [-2, 0, 2]:
        draw.line([(cx - 3, cy - 2 + off), (cx + 3, cy - 2 + off)], fill=(*AMBER_VOICE, 220), width=1)
    # 顶部挂环
    draw.ellipse([cx - 1, cy - 7, cx + 1, cy - 5], outline=(*AMBER_VOICE, 230))
    return img


def draw_amber_lantern(size: int = 16) -> Image.Image:
    """persistent_resonance: 不灭回响 — 存档灯笼（与 A029 同语，但 16x16）"""
    img, draw = _new_canvas(size)
    cx, cy = size // 2, size // 2
    # 灯笼罩
    draw.rectangle([cx - 4, cy - 4, cx + 4, cy + 4], fill=(*AMBER_VOICE, 230), outline=(*WARM_PARCHMENT, 220))
    # 顶部盖
    draw.rectangle([cx - 5, cy - 5, cx + 5, cy - 4], fill=(*MUTED_VIOLET, 230))
    # 底部托
    draw.rectangle([cx - 3, cy + 4, cx + 3, cy + 5], fill=(*MUTED_VIOLET, 230))
    # 内部波形（青色）
    for off in [-2, 0, 2]:
        draw.line([(cx - 2, cy - 1 + off), (cx + 2, cy - 1 + off)], fill=(*GLASS_CYAN, 230), width=1)
    # 提环
    draw.line([(cx, cy - 5), (cx, cy - 7)], fill=(*WARM_PARCHMENT, 220), width=1)
    return img


ICON_DRAWERS = {
    "amber_dot": draw_amber_dot,
    "coral_pulse": draw_coral_pulse,
    "amber_shard": draw_amber_shard,
    "three_circles": draw_three_circles,
    "coral_slash": draw_coral_slash,
    "coral_eye": draw_coral_eye,
    "amber_bell": draw_amber_bell,
    "amber_lantern": draw_amber_lantern,
}


if __name__ == "__main__":
    base = "/workspace/assets/ui/achievements"
    os.makedirs(base, exist_ok=True)

    print("Generating Voxglass achievement icons:")
    for hint, drawer in ICON_DRAWERS.items():
        folder = os.path.join(base, hint)
        os.makedirs(folder, exist_ok=True)
        # 16x16 (in-game size)
        img16 = drawer(16)
        path16 = os.path.join(folder, f"{hint}.png")
        img16.save(path16)
        # 32x32 (notification size)
        img32 = drawer(32)
        path32 = os.path.join(folder, f"{hint}_32x32.png")
        img32.save(path32)
        print(f"  - {hint}: 16x16 → {path16}")
        print(f"           32x32 → {path32}")

    print("\nAll 8 achievement icons generated.")
