#!/usr/bin/env python3
"""
程序化生成 Steam capsule 三联图（Voxglass 风格）

三档比例：
- capsule_main    616 x 353   Steam header capsule（商店主胶囊）
- capsule_small   460 x 215   Steam small capsule（小胶囊 / 库存页）
- capsule_feature 1200 x 630  Steam feature graphic（商店首页大图）

色板严格遵循 STYLE_GUIDE.md：
- Abyss Black #05070D / Ink Navy #081426 / Archive Blue #12334A
- Deep Teal #1D6570 / Glass Cyan #69C7CE / Pale Resonance #B7E7DD
- Muted Violet #65506A / Coral Pulse #E86D5A / Amber Voice #F2B66E
- Warm Parchment #E6D5B8

构图统一语义：
- 远景：洪水档案馆（拱门 / 悬挂线缆 / 玻璃钟罩 / 浅水反射）
- 中景：Saya 剪影侧身站立，短深发 + 青色发束 + 琥珀喉口 + 玻璃披肩 + 声波围巾 + 左前臂声匣
- 前景：Pulse 圆环扩散（珊瑚 + 琥珀 + 玻璃青），玻璃裂纹亮起
- 底色：深水冷色（Ink Navy / Archive Blue 渐变），暖色 10% 集中在 Saya + Pulse + 裂纹
"""

import math
import os
from PIL import Image, ImageDraw, ImageFilter

# STYLE_GUIDE 色板
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


def _vgradient(size_w, size_h, top, bottom):
    """垂直渐变（深水冷色背景）"""
    img = Image.new("RGBA", (size_w, size_h), (0, 0, 0, 0))
    px = img.load()
    for y in range(size_h):
        t = y / max(1, size_h - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        a = int(top[3] * (1 - t) + bottom[3] * t) if len(top) > 3 else 255
        for x in range(size_w):
            px[x, y] = (r, g, b, a)
    return img


def _draw_horizontal_glow(draw, cx, cy, radius, color, alpha_falloff=2.0):
    """在中心点画一个柔和的水平光晕（模拟水面反射）"""
    for i in range(radius, 0, -2):
        t = i / radius
        a = int(255 * (1 - t) ** alpha_falloff)
        rgba = (*color, a)
        draw.ellipse([cx - i, cy - i // 3, cx + i, cy + i // 3], fill=rgba)


def _draw_vertical_glow(draw, cx, cy, radius, color, alpha_falloff=2.0):
    """垂直光晕（暖色声波核心）"""
    for i in range(radius, 0, -1):
        t = i / radius
        a = int(255 * (1 - t) ** alpha_falloff)
        rgba = (*color, a)
        draw.ellipse([cx - i, cy - i, cx + i, cy + i], fill=rgba)


def _draw_pulse_rings(draw, cx, cy, max_r, color_set, count=4):
    """Pulse 圆环 — 多层从中心扩散"""
    for i in range(count):
        t = i / max(1, count - 1)
        r = int(max_r * (0.2 + 0.8 * t))
        col = color_set[i % len(color_set)]
        a = int(220 * (1 - t * 0.6))
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            outline=(*col, a), width=2
        )


def _draw_archive_arch(draw, x, y, w, h, color, alpha=180, thickness=2):
    """档案馆拱门（拱形 + 两侧立柱）"""
    # 立柱
    for off in [0, w]:
        draw.line([(x + off, y), (x + off, y + h)], fill=(*color, alpha), width=thickness)
    # 拱顶
    for i in range(w // 2 + 1):
        # 拱形 (x, y+h-w/2) + 半径 w/2
        a = math.pi - (math.pi * i / (w // 2))
        ax = x + w // 2 + int((w // 2) * math.cos(a))
        ay = y + h - w // 2 + int((w // 2) * math.sin(a))
        if i > 0:
            prev_a = math.pi - (math.pi * (i - 1) / (w // 2))
            prev_ax = x + w // 2 + int((w // 2) * math.cos(prev_a))
            prev_ay = y + h - w // 2 + int((w // 2) * math.sin(prev_a))
            draw.line([(prev_ax, prev_ay), (ax, ay)], fill=(*color, alpha), width=thickness)


def _draw_hanging_cable(draw, x1, y1, x2, y2, color, alpha=140, thickness=1):
    """悬挂线缆（轻微曲线）"""
    cx = (x1 + x2) // 2
    cy = min(y1, y2) + abs(y2 - y1) // 2 + 4
    draw.line([(x1, y1), (cx, cy), (x2, y2)], fill=(*color, alpha), width=thickness)


def _draw_glass_bell(draw, cx, cy, r, glass_color, glow_color, alpha=200):
    """玻璃钟罩（远景剪影 + 内核高亮）"""
    # 主体钟形
    draw.polygon(
        [
            (cx - r, cy + r),
            (cx - r + 1, cy - r // 2),
            (cx - r // 2, cy - r),
            (cx + r // 2, cy - r),
            (cx + r - 1, cy - r // 2),
            (cx + r, cy + r),
        ],
        outline=(*glass_color, alpha), width=1
    )
    # 底部托
    draw.line([(cx - r - 1, cy + r), (cx + r + 1, cy + r)], fill=(*glass_color, alpha), width=1)
    # 内部暖色光
    _draw_vertical_glow(draw, cx, cy, r // 2, glow_color, alpha_falloff=2.0)


def _draw_saya_silhouette(draw, cx, cy, scale, mirror=False):
    """Saya 剪影（程序化）— 二次元美少女声匣修复者
    关键识别点：
    - 短深色头发 + 一缕长青色发束
    - 喉口琥珀共鸣晶体
    - 实用档案馆短外套
    - 裂纹玻璃半披肩（声波围巾）
    - 解剖学左前臂的紧凑玻璃声匣装置
    """
    s = scale
    color_main = INK_NAVY
    color_outline = GLASS_CYAN
    color_accent = AMBER_VOICE
    color_hair_cyan = GLASS_CYAN
    color_scarf = PALE_RESONANCE

    # 朝向方向（决定左/右臂）
    arm_dir = -1 if mirror else 1  # -1 = 左（解剖学左在画面右侧）

    # ----- 头部 -----
    head_w = int(12 * s)
    head_h = int(14 * s)
    head_x = cx - head_w // 2
    head_y = cy - int(50 * s)
    # 头发主体（短深色）
    draw.ellipse(
        [head_x, head_y, head_x + head_w, head_y + head_h],
        fill=(*color_main, 255), outline=(*color_outline, 200), width=1
    )
    # 后发尖（短）
    draw.polygon(
        [
            (head_x, head_y + head_h - 2),
            (head_x - int(2 * s), head_y + head_h + int(2 * s)),
            (head_x + int(1 * s), head_y + head_h),
        ],
        fill=(*color_main, 255), outline=(*color_outline, 200)
    )
    # 长青色发束（关键识别）
    cyan_strand_x = head_x + head_w + int(1 * s)
    cyan_strand_y_start = head_y + int(3 * s)
    cyan_strand_y_end = head_y + head_h + int(10 * s)
    draw.line(
        [(cyan_strand_x, cyan_strand_y_start), (cyan_strand_x + int(1 * s), cyan_strand_y_end)],
        fill=(*color_hair_cyan, 230), width=2
    )
    # 脸部（暖色小块）
    face_cx = cx
    face_cy = head_y + int(7 * s)
    draw.ellipse(
        [face_cx - int(3 * s), face_cy - int(3 * s), face_cx + int(3 * s), face_cy + int(3 * s)],
        fill=(*WARM_PARCHMENT, 200)
    )
    # 眼睛（小亮点）
    eye_y = face_cy - int(1 * s)
    if not mirror:
        # 右朝向：眼在面部右
        draw.ellipse([face_cx + int(1 * s), eye_y, face_cx + int(2 * s), eye_y + int(1 * s)], fill=(*INK_NAVY, 255))
    else:
        # 左朝向：眼在面部左
        draw.ellipse([face_cx - int(2 * s), eye_y, face_cx - int(1 * s), eye_y + int(1 * s)], fill=(*INK_NAVY, 255))

    # 喉口琥珀共鸣晶体
    throat_y = head_y + head_h + int(2 * s)
    draw.ellipse(
        [cx - int(1 * s), throat_y, cx + int(1 * s), throat_y + int(2 * s)],
        fill=(*color_accent, 240)
    )

    # ----- 躯干（短外套） -----
    body_top = head_y + head_h + int(3 * s)
    body_bottom = body_top + int(20 * s)
    body_w = int(14 * s)
    body_x = cx - body_w // 2
    draw.rectangle(
        [body_x, body_top, body_x + body_w, body_bottom],
        fill=(*color_main, 255), outline=(*color_outline, 200), width=1
    )
    # 裂纹玻璃半披肩（左/右肩上的浅色三角）
    cape_pts = [
        (body_x - int(1 * s), body_top),
        (body_x - int(1 * s), body_top + int(10 * s)),
        (body_x + int(4 * s), body_top + int(2 * s)),
    ]
    draw.polygon(cape_pts, fill=(*color_scarf, 180), outline=(*color_outline, 200))
    # 披肩裂纹
    crack_y = body_top + int(4 * s)
    draw.line(
        [(body_x + int(1 * s), crack_y), (body_x + int(2 * s), crack_y + int(2 * s))],
        fill=(*AMBER_VOICE, 200), width=1
    )
    draw.line(
        [(body_x + int(1 * s), crack_y + int(2 * s)), (body_x + int(2 * s), crack_y + int(4 * s))],
        fill=(*AMBER_VOICE, 180), width=1
    )

    # 声波围巾（绕颈）
    scarf_y = body_top - int(1 * s)
    draw.line(
        [(body_x - int(1 * s), scarf_y), (body_x + body_w + int(1 * s), scarf_y)],
        fill=(*color_scarf, 200), width=2
    )
    # 围巾尾端
    scarf_tail_y = scarf_y + int(2 * s)
    draw.line(
        [(body_x + body_w - int(2 * s), scarf_y), (body_x + body_w + int(2 * s), scarf_tail_y)],
        fill=(*color_scarf, 180), width=1
    )

    # ----- 手臂（关键：左前臂声匣） -----
    arm_y_top = body_top + int(3 * s)
    arm_y_bot = body_top + int(15 * s)

    # 解剖学左前臂 = 在画面右侧（mirror=False）OR 画面左侧（mirror=True）
    gauntlet_x = cx + arm_dir * int(7 * s)
    gauntlet_x_far = cx + arm_dir * int(10 * s)

    # 手臂线
    if arm_dir == 1:
        # 右手在画面右侧
        draw.line(
            [(body_x + body_w, arm_y_top), (gauntlet_x, arm_y_top + int(2 * s))],
            fill=(*color_main, 255), width=2
        )
        # 声匣（紧凑玻璃装置在手腕/前臂）
        draw.rectangle(
            [gauntlet_x - int(2 * s), arm_y_top + int(1 * s), gauntlet_x_far, arm_y_top + int(5 * s)],
            fill=(*color_accent, 220), outline=(*color_outline, 230), width=1
        )
        # 声匣中心高亮
        _draw_vertical_glow(draw, gauntlet_x, arm_y_top + int(3 * s), int(2 * s), GLASS_CYAN, alpha_falloff=1.5)
        # 另一只手臂（背景，简化）
        draw.line(
            [(body_x, arm_y_top), (body_x - int(3 * s), arm_y_top + int(8 * s))],
            fill=(*color_main, 200), width=2
        )
    else:
        # 左手在画面左侧
        draw.line(
            [(body_x, arm_y_top), (gauntlet_x, arm_y_top + int(2 * s))],
            fill=(*color_main, 255), width=2
        )
        draw.rectangle(
            [gauntlet_x_far, arm_y_top + int(1 * s), gauntlet_x + int(2 * s), arm_y_top + int(5 * s)],
            fill=(*color_accent, 220), outline=(*color_outline, 230), width=1
        )
        _draw_vertical_glow(draw, gauntlet_x, arm_y_top + int(3 * s), int(2 * s), GLASS_CYAN, alpha_falloff=1.5)
        draw.line(
            [(body_x + body_w, arm_y_top), (body_x + body_w + int(3 * s), arm_y_top + int(8 * s))],
            fill=(*color_main, 200), width=2
        )

    # ----- 腿部（简化为下半身柱） -----
    leg_top = body_bottom
    leg_bot = leg_top + int(15 * s)
    leg_w = int(3 * s)
    # 左腿
    draw.rectangle(
        [cx - int(5 * s), leg_top, cx - int(5 * s) + leg_w, leg_bot],
        fill=(*color_main, 255), outline=(*color_outline, 200)
    )
    # 右腿
    draw.rectangle(
        [cx + int(2 * s), leg_top, cx + int(2 * s) + leg_w, leg_bot],
        fill=(*color_main, 255), outline=(*color_outline, 200)
    )


def _draw_waveform_scarves(draw, x1, x2, y, color, alpha=180, thickness=2):
    """波形声波线（强调『声波围巾』/『共振』概念）"""
    pts = []
    for x in range(x1, x2, 4):
        dy = int(2 * math.sin((x - x1) / 12.0))
        pts.append((x, y + dy))
    for i in range(len(pts) - 1):
        draw.line([pts[i], pts[i + 1]], fill=(*color, alpha), width=thickness)


def _draw_water_reflection(draw, x1, x2, y, color, alpha=120):
    """水面水平线（远景浅水）"""
    for i in range(3):
        draw.line(
            [(x1, y + i * 2), (x2, y + i * 2)],
            fill=(*color, alpha - i * 30), width=1
        )


def _add_subtle_noise(img, intensity=8):
    """添加轻微噪点（避免纯色平涂的「AI 平滑感」）"""
    import random
    random.seed(20260604)
    px = img.load()
    w, h = img.size
    for _ in range(w * h // 80):
        x = random.randint(0, w - 1)
        y = random.randint(0, h - 1)
        r, g, b, a = px[x, y]
        d = random.randint(-intensity, intensity)
        px[x, y] = (
            max(0, min(255, r + d)),
            max(0, min(255, g + d)),
            max(0, min(255, b + d)),
            a,
        )
    return img


def make_capsule_main(w=616, h=353):
    """Steam header capsule — 主胶囊（横版，主视觉）"""
    img = _vgradient(w, h, (5, 7, 13, 255), (18, 51, 74, 255))
    draw = ImageDraw.Draw(img, "RGBA")

    # 远景：洪水档案馆（多个拱门 + 玻璃钟罩）
    # 拱门 1（最远，左）
    _draw_archive_arch(draw, 50, 200, 80, 110, GLASS_CYAN, alpha=80, thickness=1)
    # 拱门 2（中）
    _draw_archive_arch(draw, 230, 180, 100, 130, GLASS_CYAN, alpha=100, thickness=1)
    # 拱门 3（右远）
    _draw_archive_arch(draw, 450, 200, 90, 110, GLASS_CYAN, alpha=80, thickness=1)

    # 玻璃钟罩（散布）
    _draw_glass_bell(draw, 110, 170, 18, GLASS_CYAN, AMBER_VOICE, alpha=160)
    _draw_glass_bell(draw, 380, 175, 16, GLASS_CYAN, AMBER_VOICE, alpha=160)
    _draw_glass_bell(draw, 530, 195, 14, GLASS_CYAN, AMBER_VOICE, alpha=140)

    # 悬挂线缆
    _draw_hanging_cable(draw, 80, 0, 110, 165, MUTED_VIOLET, alpha=120)
    _draw_hanging_cable(draw, 280, 0, 290, 175, MUTED_VIOLET, alpha=120)
    _draw_hanging_cable(draw, 470, 0, 470, 195, MUTED_VIOLET, alpha=120)
    _draw_hanging_cable(draw, 200, 0, 220, 175, MUTED_VIOLET, alpha=100)
    _draw_hanging_cable(draw, 360, 0, 380, 170, MUTED_VIOLET, alpha=100)

    # 浅水反射（底部 1/3）
    _draw_water_reflection(draw, 0, w, 280, GLASS_CYAN, alpha=80)
    _draw_water_reflection(draw, 0, w, 290, GLASS_CYAN, alpha=60)
    _draw_water_reflection(draw, 0, w, 300, GLASS_CYAN, alpha=40)

    # 中景：Saya 剪影（居中偏左）
    saya_cx, saya_cy = 200, 220
    _draw_saya_silhouette(draw, saya_cx, saya_cy, 1.0, mirror=False)

    # 前景：Pulse 圆环（在 Saya 声匣位置向外扩散）
    pulse_cx = saya_cx + 7  # 声匣位置
    pulse_cy = saya_cy - 32
    _draw_pulse_rings(
        draw, pulse_cx, pulse_cy, 90,
        [CORAL_PULSE, AMBER_VOICE, GLASS_CYAN, PALE_RESONANCE], count=4
    )
    # Pulse 内核
    _draw_vertical_glow(draw, pulse_cx, pulse_cy, 14, AMBER_VOICE, alpha_falloff=1.5)
    _draw_vertical_glow(draw, pulse_cx, pulse_cy, 6, WARM_PARCHMENT, alpha_falloff=1.0)

    # 波形声波围巾（远处）
    _draw_waveform_scarves(draw, 350, 540, 90, GLASS_CYAN, alpha=140, thickness=1)
    _draw_waveform_scarves(draw, 360, 530, 110, PALE_RESONANCE, alpha=120, thickness=1)
    _draw_waveform_scarves(draw, 370, 520, 130, AMBER_VOICE, alpha=130, thickness=1)

    # 装饰：右侧悬挂玻璃钟罩发光（核心视觉）
    _draw_vertical_glow(draw, 430, 250, 60, AMBER_VOICE, alpha_falloff=2.5)
    _draw_vertical_glow(draw, 430, 250, 30, WARM_PARCHMENT, alpha_falloff=2.0)

    # 标题文字位置留白（不画字，留给 Steam 上传工具合成）

    img = _add_subtle_noise(img, intensity=6)
    return img


def make_capsule_small(w=460, h=215):
    """Steam small capsule — 小胶囊（紧凑版）"""
    img = _vgradient(w, h, (5, 7, 13, 255), (18, 51, 74, 255))
    draw = ImageDraw.Draw(img, "RGBA")

    # 远景：2 个拱门 + 1 个钟罩（简化）
    _draw_archive_arch(draw, 320, 110, 70, 80, GLASS_CYAN, alpha=100, thickness=1)
    _draw_glass_bell(draw, 380, 130, 14, GLASS_CYAN, AMBER_VOICE, alpha=160)

    # 悬挂线缆
    _draw_hanging_cable(draw, 340, 0, 350, 120, MUTED_VIOLET, alpha=100)
    _draw_hanging_cable(draw, 410, 0, 410, 130, MUTED_VIOLET, alpha=100)

    # 浅水
    _draw_water_reflection(draw, 0, w, 170, GLASS_CYAN, alpha=60)

    # Saya 剪影（左侧，较小）
    saya_cx, saya_cy = 130, 130
    _draw_saya_silhouette(draw, saya_cx, saya_cy, 0.7, mirror=False)

    # Pulse 圆环（紧凑）
    pulse_cx = saya_cx + 5
    pulse_cy = saya_cy - 22
    _draw_pulse_rings(
        draw, pulse_cx, pulse_cy, 55,
        [CORAL_PULSE, AMBER_VOICE, GLASS_CYAN, PALE_RESONANCE], count=3
    )
    _draw_vertical_glow(draw, pulse_cx, pulse_cy, 10, AMBER_VOICE, alpha_falloff=1.5)
    _draw_vertical_glow(draw, pulse_cx, pulse_cy, 4, WARM_PARCHMENT, alpha_falloff=1.0)

    # 波形线（远）
    _draw_waveform_scarves(draw, 220, 380, 60, GLASS_CYAN, alpha=120, thickness=1)
    _draw_waveform_scarves(draw, 230, 370, 80, PALE_RESONANCE, alpha=100, thickness=1)

    # 中央装饰
    _draw_vertical_glow(draw, 320, 140, 30, AMBER_VOICE, alpha_falloff=2.5)

    img = _add_subtle_noise(img, intensity=5)
    return img


def make_capsule_feature(w=1200, h=630):
    """Steam feature graphic — 商店首页大图（横版大尺寸，多元素）"""
    img = _vgradient(w, h, (5, 7, 13, 255), (18, 51, 74, 255))
    draw = ImageDraw.Draw(img, "RGBA")

    # ===== 远景层 =====
    # 多重拱门
    _draw_archive_arch(draw, 80, 350, 140, 200, GLASS_CYAN, alpha=80, thickness=1)
    _draw_archive_arch(draw, 280, 320, 180, 230, GLASS_CYAN, alpha=100, thickness=2)
    _draw_archive_arch(draw, 520, 350, 160, 200, GLASS_CYAN, alpha=80, thickness=1)
    _draw_archive_arch(draw, 760, 320, 180, 230, GLASS_CYAN, alpha=100, thickness=2)
    _draw_archive_arch(draw, 1000, 350, 160, 200, GLASS_CYAN, alpha=80, thickness=1)

    # 玻璃钟罩（散布）
    for cx, cy, r in [
        (170, 330, 24),
        (440, 300, 28),
        (700, 320, 26),
        (920, 300, 24),
        (1100, 330, 20),
    ]:
        _draw_glass_bell(draw, cx, cy, r, GLASS_CYAN, AMBER_VOICE, alpha=140)

    # 悬挂线缆
    for x1, y1, x2, y2 in [
        (150, 0, 170, 320), (350, 0, 370, 305),
        (550, 0, 570, 320), (780, 0, 800, 305),
        (950, 0, 970, 320), (1080, 0, 1100, 330),
    ]:
        _draw_hanging_cable(draw, x1, y1, x2, y2, MUTED_VIOLET, alpha=120)

    # 浅水反射（底部 1/3）
    for y_off in range(0, 60, 4):
        _draw_water_reflection(draw, 0, w, 480 + y_off, GLASS_CYAN, alpha=max(20, 70 - y_off))

    # ===== 中景层 =====
    # Saya 主剪影（中央，较大）
    saya_cx, saya_cy = 600, 380
    _draw_saya_silhouette(draw, saya_cx, saya_cy, 1.4, mirror=False)

    # 远景 Saya 剪影（左/右，较小，营造「修复远征」叙事）
    _draw_saya_silhouette(draw, 180, 390, 0.6, mirror=False)
    _draw_saya_silhouette(draw, 1020, 390, 0.6, mirror=True)

    # ===== 前景层 =====
    # Pulse 大圆环（中央 Saya 声匣位置）
    pulse_cx = saya_cx + 10
    pulse_cy = saya_cy - 45
    _draw_pulse_rings(
        draw, pulse_cx, pulse_cy, 200,
        [CORAL_PULSE, AMBER_VOICE, GLASS_CYAN, PALE_RESONANCE, CORAL_PULSE], count=5
    )
    _draw_vertical_glow(draw, pulse_cx, pulse_cy, 30, AMBER_VOICE, alpha_falloff=1.5)
    _draw_vertical_glow(draw, pulse_cx, pulse_cy, 14, WARM_PARCHMENT, alpha_falloff=1.0)

    # 波形声波扩散（多组，远景）
    for y_off, color, alpha in [
        (60, GLASS_CYAN, 120),
        (90, PALE_RESONANCE, 110),
        (120, AMBER_VOICE, 130),
        (150, GLASS_CYAN, 100),
    ]:
        _draw_waveform_scarves(draw, 100, 1100, y_off, color, alpha=alpha, thickness=1)

    # 远处 Pulse 圆环（远景 Saya 处，弱化）
    for cx_off, cy_off in [(180, 410), (1020, 410)]:
        _draw_pulse_rings(
            draw, cx_off, cy_off, 30,
            [CORAL_PULSE, AMBER_VOICE], count=2
        )

    # 中央暖色光团（背景锚点）
    _draw_vertical_glow(draw, 600, 200, 120, AMBER_VOICE, alpha_falloff=3.0)
    _draw_vertical_glow(draw, 600, 200, 60, WARM_PARCHMENT, alpha_falloff=2.5)

    # 玻璃裂纹亮起（中央 Saya 脚下，暗示「修复中」）
    for cx, cy, r in [
        (520, 460, 30), (570, 470, 35), (620, 465, 30),
        (670, 470, 35), (560, 480, 25), (640, 480, 25),
    ]:
        for i in range(r, 0, -2):
            t = i / r
            a = int(180 * (1 - t) ** 2.0)
            draw.ellipse(
                [cx - i, cy - i // 2, cx + i, cy + i // 2],
                outline=(*AMBER_VOICE, a), width=1
            )

    img = _add_subtle_noise(img, intensity=6)
    return img


if __name__ == "__main__":
    base = "/workspace/assets/marketing"
    os.makedirs(base, exist_ok=True)

    print("Generating Voxglass Steam capsule triptych:")

    # 1. Header capsule (616x353)
    img = make_capsule_main(616, 353)
    path_main = os.path.join(base, "voxglass_capsule_main_616x353.png")
    img.save(path_main)
    print(f"  - capsule_main    616x353  -> {path_main}")

    # 2. Small capsule (460x215)
    img = make_capsule_small(460, 215)
    path_small = os.path.join(base, "voxglass_capsule_small_460x215.png")
    img.save(path_small)
    print(f"  - capsule_small   460x215  -> {path_small}")

    # 3. Feature graphic (1200x630)
    img = make_capsule_feature(1200, 630)
    path_feature = os.path.join(base, "voxglass_capsule_feature_1200x630.png")
    img.save(path_feature)
    print(f"  - capsule_feature 1200x630 -> {path_feature}")

    print("\nAll 3 capsule triptych generated.")
