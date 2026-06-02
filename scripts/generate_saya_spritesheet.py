"""
生成 Saya 正式版 spritesheet（右朝向 + 左朝向翻转临时版）
T017 产出：替代 A019 占位 spritesheet
"""
import sys
from pathlib import Path
from PIL import Image

_self_dir = Path(__file__).resolve().parent
if str(_self_dir) not in sys.path:
    sys.path.insert(0, str(_self_dir.parent))

from scripts.pipeline import run_asset_pipeline
from scripts.animation import generate_shimmer_frames, create_action_frames
from scripts.spritesheet import create_animation_strip
from scripts.postprocess import flip_horizontal

# ═══════════════════════════════════════════════════════════════
# 配置
# ═══════════════════════════════════════════════════════════════

SEED_RIGHT = 1026
OUTPUT_DIR = Path("assets/sprites")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# 动画规格（与 STYLE_GUIDE 一致）
# idle: 8帧, run: 8帧, jump: 2帧, fall: 2帧 = 20帧
# cell 尺寸: 48x64（游戏内尺寸），但生成用更大画布保证质量
CELL_W, CELL_H = 48, 64

# 生成用的画布尺寸（放大后缩放到 CELL）
CANVAS_SIZE = 256  # 生成 256x256 基准帧，然后缩放到 48x64

# Subject 描述（继承 STYLE_GUIDE 核心 prompt）
SAYA_SUBJECT = (
    "Saya, anime heroine voice-mender, short dark hair with one long cyan strand, "
    "amber throat resonance shard, practical archive short coat, "
    "cracked glass half-cape on left shoulder, sound-wave scarf, "
    "compact glass sound-box gauntlet on anatomical left forearm, "
    "right-facing side view pose, neutral stance, pixel art sprite, "
    "deep ink navy and muted teal palette, glass cyan edge highlights, "
    "sparse amber waveform glow, crisp readable silhouette, "
    "no background, isolated character"
)

NEGATIVE = (
    "blurry, low quality, jpeg artifacts, ugly, deformed, extra fingers, extra limbs, "
    "bad anatomy, disfigured, cropped, cut off, watermark, text, signature, logo, "
    "complex background, cluttered, grainy, noisy, oversaturated, overexposed, underexposed, "
    "smooth, anti-aliased, photorealistic, gradient, soft edges, "
    "fan art, school uniform, maid outfit, idol costume, cleavage focus, "
    "cute mascot style, generic fantasy armor, oversized weapon, "
    "saturated rainbow palette, muddy unreadable silhouettes, "
    "excessive particles hiding gameplay, readable fake text, "
    "browser-game UI, glossy generic AI anime poster look"
)


def resize_to_cell(img: Image.Image) -> Image.Image:
    """将图像缩放到 48x64，使用 NEAREST 保持像素风。"""
    return img.resize((CELL_W, CELL_H), Image.NEAREST)


def remove_gray_bg(img: Image.Image) -> Image.Image:
    """移除 _add_bg 添加的灰色背景（近似 #323232）。"""
    data = img.convert("RGBA").getdata()
    new_data = []
    gray_threshold = 60
    for r, g, b, a in data:
        if r < gray_threshold and g < gray_threshold and b < gray_threshold:
            new_data.append((0, 0, 0, 0))
        else:
            new_data.append((r, g, b, a))
    img.putdata(new_data)
    return img


def main():
    print("=" * 60)
    print("T017: 生成 Saya 正式版 Spritesheet")
    print("=" * 60)

    # ── 1. 生成右朝向基准帧 ──
    print("\n[1/5] 生成右朝向基准帧...")
    result = run_asset_pipeline(
        "character",
        "pixel-art",
        SAYA_SUBJECT,
        seed=SEED_RIGHT,
        output_dir="output/saya_right",
        canvas=CANVAS_SIZE,
        gen_size=(1024, 1024),
        exports=[64, 128, 256],
        outline=1,
        flip=False,  # 我们手动控制翻转
        negative=NEGATIVE,
        no_proxy=True,
    )

    print(f"    状态: {result['status']}, seed: {result.get('seed', '?')}")
    if result['status'] not in ('PASSED', 'UNCERTIFIED'):
        print(f"    失败: {result.get('error', 'Unknown')}")
        return 1

    base_path = result['files']['main']
    base_img = Image.open(base_path).convert("RGBA")
    print(f"    基准帧: {base_path} ({base_img.size})")

    # ── 2. 生成 Idle 帧 (Shimmer + breathe) ──
    print("\n[2/5] 生成 Idle 动画帧 (8帧)...")
    idle_shimmer = generate_shimmer_frames(base_img, num_frames=8, intensity="subtle")
    idle_frames = create_action_frames(idle_shimmer, action="idle")
    idle_frames = [remove_gray_bg(f) for f in idle_frames]
    idle_frames = [resize_to_cell(f) for f in idle_frames]
    print(f"    Idle 帧: {len(idle_frames)} 帧")

    # ── 3. 生成 Run 帧 (Shimmer + walk) ──
    print("\n[3/5] 生成 Run 动画帧 (8帧)...")
    run_shimmer = generate_shimmer_frames(base_img, num_frames=8, intensity="subtle")
    run_frames = create_action_frames(run_shimmer, action="walk")
    run_frames = [remove_gray_bg(f) for f in run_frames]
    run_frames = [resize_to_cell(f) for f in run_frames]
    print(f"    Run 帧: {len(run_frames)} 帧")

    # ── 4. 生成 Jump/Fall 帧 (基于 Shimmer，手动做简单变换) ──
    print("\n[4/5] 生成 Jump/Fall 帧 (各2帧)...")
    jump_shimmer = generate_shimmer_frames(base_img, num_frames=4, intensity="subtle")
    jump_frames = create_action_frames(jump_shimmer, action="jump")
    jump_frames = [remove_gray_bg(f) for f in jump_frames]
    jump_frames = [resize_to_cell(f) for f in jump_frames]
    # 取前2帧作为 jump，后2帧作为 fall
    jump_final = jump_frames[:2]
    fall_final = jump_frames[2:4]
    print(f"    Jump 帧: {len(jump_final)} 帧, Fall 帧: {len(fall_final)} 帧")

    # ── 5. 打包 Spritesheet ──
    print("\n[5/5] 打包 Spritesheet...")

    # 右朝向：按 idle(8) + run(8) + jump(2) + fall(2) = 20 帧水平排列
    all_right = idle_frames + run_frames + jump_final + fall_final
    right_strip, right_meta = create_animation_strip(all_right, direction="horizontal", pad=0)
    right_path = OUTPUT_DIR / "saya_spritesheet_right.png"
    right_strip.save(right_path, "PNG", optimize=True)
    print(f"    右朝向: {right_path} ({right_strip.size})")

    # 左朝向：水平翻转（临时方案，正式左朝向需单独绘制）
    left_strip = flip_horizontal(right_strip)
    left_path = OUTPUT_DIR / "saya_spritesheet_left.png"
    left_strip.save(left_path, "PNG", optimize=True)
    print(f"    左朝向(翻转临时版): {left_path} ({left_strip.size})")

    # 保存元数据
    meta = {
        "cell_width": CELL_W,
        "cell_height": CELL_H,
        "animations": {
            "idle": {"start": 0, "frames": 8},
            "run": {"start": 8, "frames": 8},
            "jump": {"start": 16, "frames": 2},
            "fall": {"start": 18, "frames": 2},
        },
        "total_frames": len(all_right),
        "seed_right": SEED_RIGHT,
        "notes": "左朝向为右朝向水平翻转临时版，正式左朝向需单独生成（seed 1027）",
    }
    import json
    meta_path = OUTPUT_DIR / "saya_spritesheet_meta.json"
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2, ensure_ascii=False)
    print(f"    元数据: {meta_path}")

    print("\n" + "=" * 60)
    print("T017 完成!")
    print("=" * 60)
    return 0


if __name__ == "__main__":
    sys.exit(main())
