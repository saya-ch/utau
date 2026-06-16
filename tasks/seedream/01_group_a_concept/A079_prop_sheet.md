# A079 — 声匣道具三态 v2（破损 / 修复 / 共鸣）

| 项 | 值 |
|----|----|
| Asset ID | A079 |
| 任务编号 | T187 |
| Seed | 2005 |
| 参考旧素材 | A013 voice_archive_props_sheet.png + A023 voice_bell_broken + A024 voice_bell_repaired |
| 风格 | concept |
| 类型 | capsule |
| 生成尺寸 | 1024×1024 |
| 画布 | 不裁剪 |
| 导出尺寸 | 原始 + 512 |
| 底色 | 画面内自然色（深 navy 背景 + 琥珀光反射） |
| 抠图 | ❌ |
| 描边 | ❌ |
| flip | ❌ |
| Retry Seed | 2480 → 2490 |

## subject

```
digital concept art, cinematic composition, moody atmospheric lighting, highly detailed, professional game art quality. A prop design reference sheet with three states of a glass bell (声匣):

Left panel: BROKEN state — cracked glass bell, deep muted violet edges indicating corrosion, jagged cracks, dimmed amber core inside, broken hanging chain.

Center panel: REPAIRED state — same glass bell, fewer cracks, thin golden repair seams (kintsugi style), brighter amber core, intact chain with subtle amber glow.

Right panel: RESONANCE state — same bell fully resonating, amber core glowing intensely, circular sound waves radiating outward in pale-resonance cyan, cracks filled with warm waveform light, most visually energetic of the three.

Deep ink navy background with faint cyan water reflections, consistent composition so three states are easy to compare.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (1024, 1024),
    "canvas": None,
    "exports": [512],
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "clean three-panel prop design sheet, consistent bell silhouette across panels, moody atmospheric background, professional game concept art, no text, no watermark, no logo",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no text overlay, no frame",
}
```

## 输出目录

```
/workspace/assets/concepts/voice_archive_props_sheet_v2.png
```

## ASSET_REGISTRY 目标行

```
| A079 | 声匣三态 v2（破损/修复/共鸣） | Prop/Concept Sheet | Voxglass Seedream prop concept | doubao-seedream-5-0-260128 | 2005 | glass bell three states: broken (cracked, dim amber) / repaired (golden seams, brighter amber) / resonance (strong amber + waveform cyan glow) | PASSED/PENDING | assets/concepts/voice_archive_props_sheet_v2.png | 继承 A013 语义；三种状态在同一张 sheet 上对比；琥珀核心的亮度是唯一的视觉差异；冷色背景 + 暖色光 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="capsule", style="concept", subject, seed=2005, output_dir="/workspace/assets/concepts/voice_archive_props_sheet_v2", ...)`
- [ ] 视觉检查：三只玻璃钟的轮廓一致（同一钟不同状态），核心亮度区分破损<修复<共鸣
- [ ] ROADMAP T187 → - [x]
- [ ] 台账 + changelog + iter count
