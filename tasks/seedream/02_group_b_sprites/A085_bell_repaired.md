# A085 — Voice Bell 修复态 v2（白底抠图）

| 项 | 值 |
|----|----|
| Asset ID | A085 |
| 任务编号 | T193 |
| Seed | 2103 |
| 参考旧素材 | A024 voice_bell_repaired.png |
| 风格 | anime |
| 类型 | item |
| 生成尺寸 | 512×512 |
| 画布 | 256 |
| 导出尺寸 | 32 / 64 / 128 / 256 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ✅ |
| Retry Seed | 2440 → 2450 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, sharp silhouette.

Repaired glass bell item / prop — fewer cracks, thin golden kintsugi-style repair seams visible along major crack lines, brighter glowing amber core inside, intact hanging chain at top. Subtle pale-resonance cyan glow around edges. Deep ink navy glass body, thin warm-parchment gold repair lines, bright amber-voice #F2B66E inner core glowing clearly. Isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal.

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
    "tech_suffix": "isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal, clean prop silhouette for 2D platformer",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no realistic, no rough sketch, no messy lines",
}
```

## 输出目录

```
/workspace/assets/props/voice_bell_repaired_v2/
```

## ASSET_REGISTRY 目标行

```
| A085 | Voice Bell - Repaired v2 | Prop/Item | Voxglass Seedream item sprite | doubao-seedream-5-0-260128 | 2103 | repaired glass bell with fewer cracks, thin golden kintsugi-style repair seams, bright glowing amber core inside, intact chain | PASSED/PENDING | assets/props/voice_bell_repaired_v2/ | 替换 A024；与 A084 保持相同轮廓；琥珀核心亮度 > A084 的亮度，金色修补缝是视觉区分度；1px black 描边，多尺寸导出 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="item", style="anime", subject, seed=2103, output_dir="/workspace/assets/props/voice_bell_repaired_v2", ...)`
- [ ] 对比 A084：钟的轮廓一致，核心明显更亮，金修补缝线
- [ ] ROADMAP T193 → - [x]
- [ ] 台账 + changelog + iter count
