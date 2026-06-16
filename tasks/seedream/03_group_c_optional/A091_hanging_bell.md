# A091 — Hanging Bell 悬挂铃铛精致版

| 项 | 值 |
|----|----|
| Asset ID | A091 |
| 任务编号 | T199 |
| Seed | 2203 |
| 风格 | anime |
| 类型 | item |
| 生成尺寸 | 512×512 |
| 画布 | 256 |
| 导出尺寸 | 32 / 64 / 128 / 256 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ✅ |
| Retry Seed | 2560 → 2570 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, sharp silhouette.

Decorative hanging bell — cracked glass bell with muted violet corrosion edges, hanging from an ink-navy metal chain. Amber-voice glow inside, amber core visible through the cracks. Subtle pale-resonance cyan highlights along glass edges. Isolated on pure white background, centered, single item, no shadows.

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
/workspace/assets/props/decorative/hanging_bell_v2.png
```

## ASSET_REGISTRY 目标行

```
| A091 | Hanging Bell 悬挂铃铛精致版 | Decorative Prop | Voxglass Seedream prop | doubao-seedream-5-0-260128 | 2203 | cracked glass bell with muted violet corrosion edges, hanging from ink-navy metal chain, amber core | PASSED/PENDING | assets/props/decorative/hanging_bell_v2.png | 装饰物件升级；与 A090 wave totem 形成共鸣祭坛的视觉元素配对 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="item", style="anime", subject, seed=2203, output_dir="/workspace/assets/props/decorative/hanging_bell_v2", ...)`
- [ ] ROADMAP T199 → - [x]
- [ ] 台账 + changelog + iter count
