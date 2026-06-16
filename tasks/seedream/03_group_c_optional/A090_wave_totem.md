# A090 — Wave Totem 声波图腾精致版

| 项 | 值 |
|----|----|
| Asset ID | A090 |
| 任务编号 | T198 |
| Seed | 2202 |
| 参考旧素材 | A056 wave_totem |
| 风格 | anime |
| 类型 | item |
| 生成尺寸 | 512×512 |
| 画布 | 256 |
| 导出尺寸 | 32 / 64 / 128 / 256 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ✅ |
| Retry Seed | 2540 → 2550 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, sharp silhouette.

Decorative wave totem / sound resonance stone pillar — tall vertical stone pillar (archive-blue #12334A), engraved with horizontal waveform patterns, topped with a glowing amber-voice orb that emits concentric circular rings of pale-resonance cyan light. Ancient stone look, submerged-archive aesthetic. Isolated on pure white background, centered, single item, no shadows.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (512, 512),
    "canvas": 256,
    "exports": [32, 64, 128, 256],
    "outline": 1,
    "anchor": "center",
    "fill_ratio": 0.90,
    "flip": True,
    "tech_suffix": "isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal, clean decorative prop silhouette",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed",
}
```

## 输出目录

```
/workspace/assets/props/decorative/wave_totem_v2.png
```

## ASSET_REGISTRY 目标行

```
| A090 | Wave Totem 声波图腾精致版 | Decorative Prop | Voxglass Seedream prop | doubao-seedream-5-0-260128 | 2202 | vertical stone pillar totem, engraved waveform patterns, glowing amber orb at top emitting pale-resonance cyan rings | PASSED/PENDING | assets/props/decorative/wave_totem_v2.png | 装饰物件升级；与对称的 wave totem 做共鸣祭坛布局 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="item", style="anime", subject, seed=2202, output_dir="/workspace/assets/props/decorative/wave_totem_v2", ...)`
- [ ] ROADMAP T198 → - [x]
- [ ] 台账 + changelog + iter count
