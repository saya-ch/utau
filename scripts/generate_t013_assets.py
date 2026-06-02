"""
T013 素材生成脚本
生成：
1. Silence Mote 敌人 spritesheet (idle + float 动画, 32x32)
2. Voice Bell 修复前后状态 (道具, 32x32)
3. Pulse 技能图标 (icon, 32x32)

风格：Voxglass pixel-art
Seed 继承：最大 seed = 1021 → 新 seed 从 1022 开始
"""

import sys, json
from pathlib import Path

_self_dir = Path(__file__).resolve().parent
if str(_self_dir) not in sys.path:
    sys.path.insert(0, str(_self_dir.parent))

from scripts.pipeline import run_asset_pipeline

# STYLE_GUIDE 核心 prompt 继承
VOXGLASS_BASE = (
    "high-quality pixel-art, Steam indie quality, flooded underground voice archive, "
    "cracked glass bells, living silence, crisp sprite-ready silhouettes, "
    "deep ink navy and muted teal, glass cyan edge highlights, sparse amber coral waveform glow, "
    "melancholic but hopeful mood"
)

NEGATIVE = (
    "No photorealism, no 3D render, no fan art, no school uniform, no maid outfit, "
    "no idol costume, no cleavage focus, no cute mascot style, no generic fantasy armor, "
    "no oversized weapon, no saturated rainbow palette, no muddy unreadable silhouettes, "
    "no excessive particles hiding gameplay, no readable fake text, no logo, no watermark, "
    "no browser-game UI, no glossy generic AI anime poster look"
)

OUTPUT_BASE = Path("/workspace/assets")

results = []

# ── 1. Silence Mote 敌人 spritesheet ──
print("[T013-1] Generating Silence Mote enemy spritesheet...")
result_mote = run_asset_pipeline(
    "monster",
    "pixel-art",
    (
        "silence mote enemy, small floating ink blob creature, 32x32 pixel sprite, "
        "torn fabric edges, tentacle-like wisps, single warm amber core eye, "
        "negative silhouette shape, deep ink navy body with muted violet corrosion edges, "
        "sparse glass cyan edge highlights, coral pulse warning glow when agitated, "
        "crisp readable silhouette for 2D platformer gameplay"
    ),
    animation="float",
    num_frames=6,
    seed=1022,
    output_dir=str(OUTPUT_BASE / "enemies" / "silence_mote"),
    canvas=64,
    gen_size=(1024, 1024),
    exports=[32, 64],
    negative=NEGATIVE,
)
results.append(("A022", "Silence Mote Spritesheet", "Enemy/Spritesheet", result_mote))
print(f"  Status: {result_mote['status']} | Seed: {result_mote.get('seed', 'N/A')}")
if result_mote['status'] == "PASSED":
    print(f"  Files: {json.dumps(result_mote.get('files', {}), indent=2)}")

# ── 2. Voice Bell 修复前（破损） ──
print("\n[T013-2a] Generating Voice Bell (broken state)...")
result_bell_broken = run_asset_pipeline(
    "item",
    "pixel-art",
    (
        "cracked glass voice bell, broken state, hanging bell-shaped glass vessel, "
        "deep fractures across surface, dim muted violet interior, "
        "glass cyan edge barely glowing, ink navy and muted teal palette, "
        "small 32x32 pixel game prop, crisp silhouette, isolated on white"
    ),
    seed=1023,
    output_dir=str(OUTPUT_BASE / "props" / "voice_bell_broken"),
    canvas=64,
    gen_size=(512, 512),
    exports=[32, 64],
    negative=NEGATIVE,
)
results.append(("A023", "Voice Bell Broken", "Prop/Item", result_bell_broken))
print(f"  Status: {result_bell_broken['status']} | Seed: {result_bell_broken.get('seed', 'N/A')}")

# ── 3. Voice Bell 修复后（完好） ──
print("\n[T013-2b] Generating Voice Bell (repaired state)...")
result_bell_repaired = run_asset_pipeline(
    "item",
    "pixel-art",
    (
        "repaired glass voice bell, intact bell-shaped glass vessel, "
        "warm amber voice glow from within, glass cyan edges brightly lit, "
        "subtle waveform pattern inside, floating resonance particles, "
        "amber voice and pale resonance palette, small 32x32 pixel game prop, "
        "crisp silhouette, isolated on white"
    ),
    seed=1024,
    output_dir=str(OUTPUT_BASE / "props" / "voice_bell_repaired"),
    canvas=64,
    gen_size=(512, 512),
    exports=[32, 64],
    negative=NEGATIVE,
)
results.append(("A024", "Voice Bell Repaired", "Prop/Item", result_bell_repaired))
print(f"  Status: {result_bell_repaired['status']} | Seed: {result_bell_repaired.get('seed', 'N/A')}")

# ── 4. Pulse 技能图标 ──
print("\n[T013-3] Generating Pulse ability icon...")
result_pulse_icon = run_asset_pipeline(
    "skill-icon",
    "pixel-art",
    (
        "Pulse ability icon, sound wave ripple ring, concentric circles expanding outward, "
        "coral pulse and amber voice center glow, glass cyan outer ring, "
        "deep ink navy background disc, 32x32 pixel UI icon, "
        "clean readable silhouette, game interface ready"
    ),
    seed=1025,
    output_dir=str(OUTPUT_BASE / "ui" / "pulse_icon"),
    canvas=64,
    gen_size=(512, 512),
    exports=[32, 64],
    negative=NEGATIVE,
)
results.append(("A025", "Pulse Ability Icon", "UI/Icon", result_pulse_icon))
print(f"  Status: {result_pulse_icon['status']} | Seed: {result_pulse_icon.get('seed', 'N/A')}")

# ── 汇总 ──
print("\n" + "="*60)
print("T013 素材生成汇总")
print("="*60)
for id_, name, type_, r in results:
    status = r['status']
    seed = r.get('seed', 'N/A')
    files = r.get('files', {})
    main_file = files.get('main', 'N/A')
    print(f"{id_} | {name} | {type_} | {status} | seed={seed}")
    if 'animation' in files:
        print(f"  └─ animation: {files['animation'].get('strip', 'N/A')}")
    print(f"  └─ main: {main_file}")

print("\n生成完成。请检查各素材的 L2 评价报告（*_report.json）。")
