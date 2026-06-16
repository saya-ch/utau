# A076 — Saya 主角设定 v2（全身 + 声匣特写）

| 项 | 值 |
|----|----|
| Asset ID | A076 |
| 任务编号 | T184 |
| Seed | 2002 |
| 参考旧素材 | A007 saya_final_concept.png + STYLE_GUIDE 形状语言 |
| 风格 | anime（二次元手绘） |
| 类型 | character（不抠图，概念参考，保留完整画面） |
| 生成尺寸 | 2048×1536（竖版全身图） |
| 画布 | 原始（不裁剪） |
| 导出尺寸 | 2048 + 1024 + 512 |
| 底色 | 画面内自然环境色（回声档案馆内景） |
| 抠图 | ❌ 不抠，保留完整氛围 |
| 描边 | ❌ 0 |
| flip | ❌（左臂声匣设定不能镜像） |
| Retry Seed | 2420 → 2430 |

## 形状语言强制约束（来自 STYLE_GUIDE.md）

- 短发深色，一缕长青色发束（glass-cyan）
- 喉部琥珀共鸣碎片（amber-voice）
- 档案馆短外套（ink-navy / archive-blue）
- 裂纹玻璃半披肩（cracked glass half-cape）
- 声波围巾（sound-wave scarf，warm parchment 细纹理）
- **解剖学左臂**的紧凑玻璃声匣装置（compact sound-box gauntlet — 左臂唯一，不能镜像）
- 站立姿态：3/4 视角，面向观众略偏右，声匣在视觉左侧（确保不与旧设定镜像冲突）
- 附加：右下角色声匣装置特写（inset close-up，同一画面内嵌 panel）

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, screen tone highlights, sharp silhouette.

Full-body standing portrait of Saya, an original anime heroine — short dark hair with one long cyan strand, amber throat shard glowing, short ink-navy archive coat, cracked-glass half-cape over shoulders, sound-wave scarf, compact glass sound-box gauntlet on her anatomical LEFT forearm (visible on the viewer's right side). Three-quarter perspective, calm melancholic expression, eyes reflect pale-resonance cyan light.

Inset bottom-right panel: close-up of the glass sound-box gauntlet showing internal amber waveform light and cracked glass details.

Scene background: flooded underground voice archive, cracked stone arches, hanging broken glass bells, shallow cyan water with ripples of warm amber light.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (2048, 1536),
    "canvas": None,
    "exports": [1024, 512],
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "cinematic character concept illustration, clean lineart, readable silhouette, inset close-up panel for gauntlet detail, no text, no watermark, professional game character sheet quality",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no school uniform, no maid outfit, no idol costume, no cleavage focus, no cute mascot style, no realistic, no rough sketch, no messy lines",
}
```

## 输出目录

```
/workspace/assets/character/saya_concept_v2.png
```

## ASSET_REGISTRY 目标行

```
| A076 | Saya 主角设定 v2 | Character/Concept | Voxglass Seedream anime character | doubao-seedream-5-0-260128 | 2002 | Saya heroine full-body + left-forearm gauntlet close-up, melancholic resonance tone | PASSED/PENDING | assets/character/saya_concept_v2.png | 继承 A007 形状语言，声匣在解剖学左臂（不能镜像）；二次元美少女辨识度，不回到无脸斗篷；色板严格冷75%暖10%；不抠图，2048×1536 竖版；右下角内嵌声匣特写 panel |
```

## 执行检查清单

- [ ] 调用 `run_seedream_pipeline(asset_type="character", style="anime", subject, seed=2002, output_dir="/workspace/assets/character/saya_concept_v2", version="5.0", fallback_to_pollinations=True, **overrides)`
- [ ] 视觉检查：声匣确实在左臂（观众视角的右侧），没有被镜像
- [ ] 色板检查：冷色主导，暖色仅用于声匣高光/喉部碎片
- [ ] ASSET_REGISTRY 追加
- [ ] ROADMAP T184 → - [x]
- [ ] CHANGELOG 追加
- [ ] ITERATION_COUNT 递增
