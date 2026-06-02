"""
游戏角色动画 — PIL Shimmer + 程序化动作叠加。

核心原理：
  1. Shimmer: 对 1 张基准帧做 PIL 像素级微处理
     （亮度振荡/像素抖动/色相偏移）→ 循环播放=呼吸闪烁感
     零 API 调用，100% 角色一致
  2. 程序化: 对每张 Shimmer 帧做整图变换（位移/缩放/旋转）
     产生 walk/attack/jump 等动作
  3. 叠加效果: 角色在运动中持续闪烁颤动 = 「不安定的生命感」
"""

from __future__ import annotations

import math
import os
import random
import numpy as np
from PIL import Image, ImageFilter, ImageEnhance


# ═══════════════════════════════════════════════════════════════
# Shimmer 帧生成 — PIL 像素处理，零API，100%角色一致
# ═══════════════════════════════════════════════════════════════

def generate_shimmer_frames(
    base_frame: Image.Image,
    num_frames: int = 4,
    intensity: str = "subtle",
    *,
    brightness: float | None = None,   # 亮度振幅 (0.0~1.0)，如 0.02 = ±2%
    jitter: int | None = None,          # 像素抖动范围 (px)，如 2 = 0~2px
    hue_shift: float | None = None,    # 色相偏移 (°)，如 5 = ±5°
    noise: float | None = None,        # 噪点强度 (σ)，如 8 = 高斯σ=8
) -> list[Image.Image]:
    """
    对 1 张基准帧做 PIL 像素级微处理，产生 Shimmer 闪烁帧。
    零 API 调用，100% 角色一致。

    两种用法:

    1) 预设:
       intensity = "subtle" | "moderate" | "wild"

    2) 自定义原始参数（传入即覆盖预设）:
       brightness=0.07, jitter=5, hue_shift=12, noise=20

    每帧处理参数略有不同 → 循环播放产生颤动/闪烁效果。
    """
    configs = {
        "subtle":  {"brightness": 0.02, "jitter": 1, "hue_shift": 0,  "noise": 3},
        "moderate": {"brightness": 0.05, "jitter": 2, "hue_shift": 3,  "noise": 6},
        "wild":     {"brightness": 0.10, "jitter": 3, "hue_shift": 8,  "noise": 12},
    }
    cfg = configs.get(intensity, configs["subtle"])
    # 自定义参数覆盖预设
    if brightness is not None:
        cfg["brightness"] = brightness
    if jitter is not None:
        cfg["jitter"] = jitter
    if hue_shift is not None:
        cfg["hue_shift"] = hue_shift
    if noise is not None:
        cfg["noise"] = noise

    frames = []
    for i in range(num_frames):
        frame = base_frame.copy()

        # 相位：每帧在周期中不同位置
        phase = i / max(num_frames, 1) * 2 * math.pi

        # 1. 亮度振荡（正弦波）
        b = 1.0 + cfg["brightness"] * math.sin(phase)
        frame = ImageEnhance.Brightness(frame).enhance(b)

        # 2. 像素抖动（随机微位移）
        j = cfg["jitter"]
        if j > 0:
            dx = random.randint(-j, j)
            dy = random.randint(-j, j)
            if dx != 0 or dy != 0:
                frame = _shift_pixels(frame, dx, dy)

        # 3. 色相偏移
        h = cfg["hue_shift"]
        if h > 0:
            hue_angle = h * math.sin(phase * 1.7)  # 1.7 = 非整数周期避免重复
            frame = _shift_hue(frame, hue_angle)

        # 4. 微噪点
        n = cfg["noise"]
        if n > 0:
            frame = _add_noise(frame, intensity=n)

        frames.append(frame)

    return frames


def _shift_pixels(img, dx, dy):
    """像素微位移（边缘透明填充）。"""
    data = np.array(img)
    shifted = np.zeros_like(data)
    if dy >= 0 and dx >= 0:
        shifted[dy:, dx:] = data[:data.shape[0]-dy, :data.shape[1]-dx]
    elif dy >= 0 and dx < 0:
        shifted[dy:, :dx] = data[:data.shape[0]-dy, -dx:]
    elif dy < 0 and dx >= 0:
        shifted[:dy, dx:] = data[-dy:, :data.shape[1]-dx]
    else:
        shifted[:dy, :dx] = data[-dy:, -dx:]
    return Image.fromarray(shifted, img.mode)


def _shift_hue(img, degrees):
    """色相旋转（保持alpha）。"""
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    r, g, b, a = img.split()
    rgb = Image.merge("RGB", (r, g, b))
    # 用 HSV 做色相旋转
    from colorsys import rgb_to_hsv, hsv_to_rgb
    data = np.array(rgb, dtype=float) / 255.0
    for y in range(data.shape[0]):
        for x in range(data.shape[1]):
            r_, g_, b_ = data[y, x]
            h, s, v = rgb_to_hsv(r_, g_, b_)
            h = (h + degrees / 360.0) % 1.0
            r_, g_, b_ = hsv_to_rgb(h, s, v)
            data[y, x] = [r_, g_, b_]
    data = (data * 255).astype(np.uint8)
    rgb = Image.fromarray(data, "RGB")
    return Image.merge("RGBA", (*rgb.split(), a))


def _add_noise(img, intensity=5):
    """添加微量高斯噪点（保持alpha）。"""
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    data = np.array(img, dtype=np.int16)
    noise = np.random.normal(0, intensity, (data.shape[0], data.shape[1], 3)).astype(np.int16)
    data[:, :, :3] = np.clip(data[:, :, :3] + noise, 0, 255)
    return Image.fromarray(data.astype(np.uint8), "RGBA")


# ═══════════════════════════════════════════════════════════════
# 程序化动作 — 叠加在 Shimmer 帧上
# ═══════════════════════════════════════════════════════════════

def create_action_frames(
    shimmer_frames: list[Image.Image],
    action: str = "walk",
    *,
    custom_fn: callable | None = None,  # 自定义动作函数 (frames, n) → list[Image]
) -> list[Image.Image]:
    """
    对 Shimmer 帧列表施加程序化动作变换。

    两种用法:

    1) 预设: action = "walk" | "attack" | "jump" | "float" | "hurt" | "death" | "idle"

    2) 自定义: custom_fn = 你的函数
       函数签名: (frames: list[Image], n: int) → list[Image]
       例:
           def my_teleport(frames, n):
               result = []
               for i, f in enumerate(frames):
                   alpha = int(255 * abs(math.sin(i/n * math.pi)))
                   # ... 自定义变换
                   result.append(f)
               return result
           create_action_frames(shimmer_frames, custom_fn=my_teleport)

    每帧: 整图位移/缩放/旋转 → 保持 Shimmer 微变体 + 程序化运动
    """
    if custom_fn is not None:
        return custom_fn(shimmer_frames, len(shimmer_frames))

    actions = {
        "walk":   _walk,
        "attack": _attack,
        "jump":   _jump,
        "float":  _float,
        "hurt":   _hurt,
        "death":  _death,
        "idle":   _breathe,
    }
    if action not in actions:
        raise ValueError(f"未知动作: {action}，可选 {list(actions.keys())}")
    return actions[action](shimmer_frames)


def _add_bg(img):
    bg = Image.new("RGBA", img.size, (50, 50, 50, 255))
    bg.paste(img, (0, 0), img)
    return bg.convert("RGB")


def _transform(img, dx=0, dy=0, sx=1.0, sy=1.0, angle=0.0):
    """整图变换。"""
    w, h = img.size
    nw, nh = max(1, int(w * sx)), max(1, int(h * sy))
    if sx != 1.0 or sy != 1.0:
        img = img.resize((nw, nh), Image.LANCZOS)
    if angle != 0.0:
        img = img.rotate(angle, Image.BILINEAR, expand=True, fillcolor=(0,0,0,0))
    canvas = Image.new("RGBA", (w, h), (0,0,0,0))
    px = (w - img.width) // 2 + dx
    py = (h - img.height) // 2 + dy
    canvas.paste(img, (px, py), img if img.mode == "RGBA" else None)
    return canvas


def _walk(frames, n=None):
    n = n or len(frames)
    result = []
    for i in range(len(frames)):
        phase = i / max(n, len(frames)) * 2 * math.pi
        dy = int(5 * math.sin(phase * 2))
        dx = int(3 * math.sin(phase))
        angle = 2 * math.sin(phase * 2)
        sy = 1.0 - 0.03 * math.cos(phase * 2)
        result.append(_add_bg(_transform(frames[i], dx, dy, 1.0, sy, angle)))
    return result


def _attack(frames, n=None):
    n = n or len(frames)
    result = []
    for i in range(len(frames)):
        p = i / max(n-1, 1)
        if p < 0.4:     dx = int(-5 * p / 0.4)
        elif p < 0.6:   dx = int(-5 + 18 * (p-0.4)/0.2)
        else:           dx = int(13 * (1 - (p-0.6)/0.4))
        sx = 1.0 + 0.1 * (1 if p < 0.6 else -1) * min(p/0.6, 1)
        result.append(_add_bg(_transform(frames[i], dx, 0, sx, 1.0, 0)))
    return result


def _jump(frames, n=None):
    n = n or len(frames)
    result = []
    for i in range(len(frames)):
        p = i / max(n-1, 1)
        if p < 0.2:       dy, sy = int(-3*p/0.2), 1.0-0.15*p/0.2
        elif p < 0.5:     dy, sy = int(-3+22*(p-0.2)/0.3), 0.85+0.3*(p-0.2)/0.3
        elif p < 0.8:     dy, sy = 19, 1.15-0.15*(p-0.5)/0.3
        else:             dy, sy = int(19-19*(p-0.8)/0.2), 1.0+0.15*(p-0.8)/0.2
        result.append(_add_bg(_transform(frames[i], 0, dy, 1.0, sy, 0)))
    return result


def _float(frames, n=None):
    n = n or len(frames)
    result = []
    for i in range(len(frames)):
        p = i / max(n, len(frames)) * 2 * math.pi
        dy = int(8 * math.sin(p))
        sy = 1.0 + 0.03 * math.cos(p)
        result.append(_add_bg(_transform(frames[i], 0, dy, 1.0, sy, 0)))
    return result


def _hurt(frames, n=None):
    result = []
    for i in range(len(frames)):
        dx = int(8 * math.sin(i * math.pi))
        angle = 3 * math.sin(i * math.pi * 2)
        result.append(_add_bg(_transform(frames[i], dx, 0, 1.0, 1.0, angle)))
    return result


def _death(frames, n=None):
    n = n or len(frames)
    result = []
    for i in range(len(frames)):
        p = i / max(n-1, 1)
        dy = int(35 * p)
        angle = 15 * p
        alpha = int(255 * (1 - p))
        img = _transform(frames[i], 0, dy, 1.0, 1.0, angle)
        data = np.array(img)
        data[:,:,3] = np.minimum(data[:,:,3], alpha)
        img = Image.fromarray(data, "RGBA")
        result.append(_add_bg(img))
    return result


def _breathe(frames, n=None):
    result = []
    for i in range(len(frames)):
        p = i / max(len(frames), 1) * 2 * math.pi
        sy = 1.0 + 0.02 * math.sin(p)
        dy = int(2 * math.sin(p))
        result.append(_add_bg(_transform(frames[i], 0, dy, 1.0, sy, 0)))
    return result
