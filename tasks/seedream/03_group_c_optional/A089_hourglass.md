# A089 — Hourglass 沙漏精致版（装饰物件）

| 项 | 值 |
|----|----|
| Asset ID | A089 |
| 任务编号 | T197 |
| Seed | 2201 |
| 风格 | anime |
| 类型 | item（装饰物件） |
| 生成尺寸 | 512×512 |
| 画布 | 256，fill 90% |
| 导出尺寸 | 32 / 64 / 128 / 256 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ✅ |
| Retry Seed | 2520 → 2530 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, sharp silhouette.

Decorative hourglass / sand timer — glass body with ink-navy frame, sand inside glowing with amber-voice light (golden sand resonating), subtle glass-cyan highlights along the glass edges. Symmetric composition, hourglass standing upright. Isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal.

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
    "tech_suffix": "isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal, clean prop silhouette for 2D platformer decoration",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed",
}
```

## 输出目录

```
/workspace/assets/props/decorative/hourglass_v2.png
```

## ASSET_REGISTRY 目标行

```
| A089 | Hourglass 沙漏精致版 | Decorative Prop | Voxglass Seedream prop | doubao-seedream-5-0-260128 | 2201 | decorative hourglass with amber glowing sand inside glass body, ink-navy frame, symmetric upright composition | PASSED/PENDING | assets/props/decorative/hourglass_v2.png | 升级装饰物件版本；供未来关卡扩展使用；白底抠图 + 1px black 描边；多尺寸导出 32/64/128/256 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="item", style="anime", subject, seed=2201, output_dir="/workspace/assets/props/decorative/hourglass_v2", ...)`
- [ ] 对比 A055 原程序化版本：更精细玻璃光泽、更暖的沙光
- [ ] ROADMAP T197 → - [x]
- [ ] 台账 + changelog + iter count
