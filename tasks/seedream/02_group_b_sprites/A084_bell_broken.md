# A084 — Voice Bell 破损态 v2（白底抠图）

| 项 | 值 |
|----|----|
| Asset ID | A084 |
| 任务编号 | T192 |
| Seed | 2102 |
| 参考旧素材 | A023 voice_bell_broken.png |
| 风格 | anime |
| 类型 | item |
| 生成尺寸 | 512×512 |
| 画布 | 256（fit-to-center，fill 90%） |
| 导出尺寸 | 32 / 64 / 128 / 256 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black（item 标准描边） |
| flip | ✅（装饰性对称物品，允许镜像） |
| Retry Seed | 2420 → 2430 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, sharp silhouette.

Broken glass bell item / prop — heavily cracked, muted violet corrosion edges, hanging chain broken at top, dimmed amber core inside barely glowing, glass shards missing in several places giving a jagged edge. Deep ink navy glass body, muted violet #65506A edges indicating corrosion, amber-voice #F2B66E inner core dimmed and fractured. Isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal. Clean prop silhouette for 2D platformer.

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
/workspace/assets/props/voice_bell_broken_v2/
```

## ASSET_REGISTRY 目标行

```
| A084 | Voice Bell - Broken v2 | Prop/Item | Voxglass Seedream item sprite | doubao-seedream-5-0-260128 | 2102 | broken glass bell with muted violet corrosion edges, dimmed amber core, cracked body, broken chain | PASSED/PENDING | assets/props/voice_bell_broken_v2/ | 替换 A023；白底抠图 + 1px black 描边 + 下采样；与 A085 (repaired) 保持相同轮廓以便玩家识别"同一物品的不同状态" |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="item", style="anime", subject, seed=2102, output_dir="/workspace/assets/props/voice_bell_broken_v2", ...)`
- [ ] 对比 A085：轮廓一致，核心亮度更低（破损态 < 修复态）
- [ ] 边缘 1px 描边干净，32 像素仍可辨识钟形
- [ ] ROADMAP T192 → - [x]
- [ ] 台账 + changelog + iter count
