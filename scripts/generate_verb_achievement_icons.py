#!/usr/bin/env python3
"""
T246 (#163) — 5 verb 旧成就 PNG 路径补全 (Echo + Wave)。

延续 T245 (#162) Whisper 6 verb icon 落地的双路径模式:
- 成就通知主路径: `res://assets/ui/achievements/<icon_hint>/`
- 5 verb 视觉组 verb family 路径: `res://assets/ui/<icon_hint>/`

T245 (#162) 已经为 sextuple_voice=whisper_icon 落地了双路径
(achievements/whisper_icon + ui/whisper_icon). 本轮 (#163) 补全 5 verb
旧成就的 PNG 路径:
- quadruple_voice=echo_icon → assets/ui/achievements/echo_icon/ 路径
- quintuple_voice=wave_icon → assets/ui/achievements/wave_icon/ 路径

落地策略:
1. 复用现有 `scripts/generate_echo_icon.py` / `generate_wave_icon.py`
   的 `draw_echo_icon(32)` / `draw_wave_icon(32)` 函数 (T085/T103
   已有, 像素级 deterministic) — 不重新画, 不破坏风格
2. 一次性生成 4 PNG (echo_icon + echo_icon_32x32 + wave_icon +
   wave_icon_32x32) + 4 .import 文件 (与 T245 1:1 模式)
3. .import 文件用与 whisper_icon 相同的 Godot 4.6.3 texture import
   配置 (compress/mode=0 = VRAM uncompressed for UI)
4. 0 行为变化: 仅 PNG 资源补全, 通知卡在 5 verb 旧成就解锁时
   从 "fallback 颜色 cell" 升级到 "真实 verb icon PNG cell"
"""

import os
import sys
import math
import hashlib
from PIL import Image

# 添加 scripts 目录到 path 以导入现有 generator
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

# 复用 T085 / T103 已有 generators (像素级 deterministic, draw_echo_icon / draw_wave_icon 都在)
from generate_echo_icon import draw_echo_icon  # type: ignore
from generate_wave_icon import draw_wave_icon  # type: ignore


# Godot 4.6.3 texture import 配置 (与 T245 whisper_icon 1:1 一致)
GODOT_IMPORT_PARAMS = """compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1"""


def make_godot_import(uid: str, source_path: str, dest_path: str) -> str:
    """生成 Godot 4.6.3 texture import 文件内容 (与 whisper_icon 1:1 一致)."""
    return f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://{uid}"
path="res://{dest_path}"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://{source_path}"
dest_files=["res://{dest_path}"]

[params]

{GODOT_IMPORT_PARAMS}
"""


def make_uid(seed_str: str) -> str:
    """基于 seed 字符串生成 13 字符 Godot UID (与 whisper_icon UID 格式一致).
    Whisper: 'b9wspr2x1u4a1' (13 chars), 'c2ktmq5w7v3n8', 'd4qhmxn5j8w2r'
    """
    h = hashlib.md5(seed_str.encode()).hexdigest()
    # Godot UID 格式: 'uid://' + 13 字符 base32-like
    return h[:13]


def main() -> None:
    # T246 (#163) — 5 verb 旧成就 PNG 路径补全
    # 落地 4 PNG + 4 .import, 与 T245 whisper_icon 1:1 模式
    targets = [
        # (verb_name, draw_fn, output_dir, base_filename)
        ("echo_icon", draw_echo_icon, "assets/ui/achievements/echo_icon", "echo_icon"),
        ("wave_icon", draw_wave_icon, "assets/ui/achievements/wave_icon", "wave_icon"),
    ]

    for verb_name, draw_fn, out_dir, base in targets:
        os.makedirs(out_dir, exist_ok=True)

        # 1. 生成 32x32 主 PNG (achievement notification 20x20 cell 用)
        icon_32 = draw_fn(32)
        png_path = f"{out_dir}/{base}.png"
        icon_32.save(png_path)

        # 2. 生成 32x32 显式 _32x32 子分辨率 (与 8 个旧成就 amber_dot/... 模式 1:1)
        png_32x32_path = f"{out_dir}/{base}_32x32.png"
        icon_32.save(png_32x32_path)

        # 3. 生成 .import 文件 (主 PNG)
        main_uid = make_uid(f"{verb_name}_main")
        import_main = make_godot_import(
            uid=main_uid,
            source_path=f"{png_path}",
            dest_path=f".godot/imported/{base}.png-{hashlib.md5(verb_name.encode()).hexdigest()}.ctex",
        )
        with open(f"{png_path}.import", "w") as f:
            f.write(import_main)

        # 4. 生成 .import 文件 (_32x32 显式子分辨率)
        sub_uid = make_uid(f"{verb_name}_sub32")
        import_sub = make_godot_import(
            uid=sub_uid,
            source_path=f"{png_32x32_path}",
            dest_path=f".godot/imported/{base}_32x32.png-{hashlib.md5((verb_name + '_32').encode()).hexdigest()}.ctex",
        )
        with open(f"{png_32x32_path}.import", "w") as f:
            f.write(import_sub)

        print(f"{verb_name} icon (achievements) generated:")
        print(f"  - {png_path} (32x32 base)")
        print(f"  - {png_32x32_path} (32x32 显式 _32x32 子分辨率)")
        print(f"  - {png_path}.import (uid://{main_uid})")
        print(f"  - {png_32x32_path}.import (uid://{sub_uid})")

    print("\nT246 #163 — 5 verb 旧成就 PNG 路径补全 (Echo + Wave) 100% 落地")
    print("4 PNG + 4 .import, 与 T245 whisper_icon 1:1 模式")
    print("quadruple_voice / quintuple_voice 通知卡 fallback 颜色 → 真实 PNG 资源 升级")


if __name__ == "__main__":
    main()
