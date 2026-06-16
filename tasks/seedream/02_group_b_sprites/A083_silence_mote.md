# A083 — Silence Mote 敌人精灵 v2（漂浮态，白底抠图）

| 项 | 值 |
|----|----|
| Asset ID | A083 |
| 任务编号 | T191 |
| Seed | 2101 |
| 参考旧素材 | A022 silence_mote.png + silence_mote_spritesheet.png |
| 风格 | anime（二次元手绘） |
| 类型 | monster |
| 生成尺寸 | 1024×1024（高清后下采样到 32/64/128/256/512） |
| 画布 | 512（fit-to-center，内容占比 80%） |
| 导出尺寸 | 32 / 64 / 128 / 256 / 512 |
| 底色 | **白底 pure white**（isolated on white background） |
| 抠图 | ✅ rembg u2net → alpha refine |
| 描边 | ✅ 2px Ink Navy (#081426) |
| flip | ✅ 生成左右镜像版本 |
| Retry Seed | 2400 → 2410 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, screen tone highlights, sharp silhouette.

Silence Mote — a small floating dark ink blob enemy, round amorphous shape with wispy tendrils drifting outward, one glowing amber eye at center, negative-space silhouette design. Deep muted violet (#65506A) shadow edges, ink navy body, one single warm amber-voice #F2B66E eye glowing at center. Isolated on pure white background for easy background removal. Clean readable silhouette suitable for 2D platformer gameplay.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (1024, 1024),
    "canvas": 512,
    "exports": [32, 64, 128, 256, 512],
    "outline": 2,          # 2px ink-navy 描边
    "anchor": "center",
    "fill_ratio": 0.80,     # 主体占画布 80%
    "flip": True,           # 同时生成左右镜像
    "tech_suffix": "isolated on pure white background, centered, single enemy creature, clean readable silhouette, high contrast for easy background removal, suitable for 2D platformer gameplay",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no jpeg artifacts, no photorealistic, no 3D render, no oversaturated, no overexposed, no realistic, no rough sketch, no messy lines",
}
```

## 输出目录

```
/workspace/assets/enemies/silence_mote_v2/
├── raw/silence_mote_v2_s2101.png          (Seedream 原始图)
├── exports/silence_mote_v2.png             (主图 512×512)
├── exports/silence_mote_v2_flip.png        (镜像)
├── exports/silence_mote_v2_32x32.png       (游戏内实际尺寸)
├── exports/silence_mote_v2_64x64.png
├── exports/silence_mote_v2_128x128.png
├── exports/silence_mote_v2_256x256.png
└── exports/silence_mote_v2_512x512.png
```

## ASSET_REGISTRY 目标行

```
| A083 | Silence Mote v2 | Enemy/Sprite | Voxglass Seedream enemy sprite | doubao-seedream-5-0-260128 | 2101 | small floating ink blob enemy, one amber eye, muted violet tendrils, isolated white background, ready for background removal | PASSED/PENDING | assets/enemies/silence_mote_v2/ | 替换 A022；白底 → rembg 抠图 → 2px Ink Navy 描边 → 下采样到 32/64/128/256/512；同时生成 flip 镜像；色板严格冷 75% 暖 10% |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="monster", style="anime", subject, seed=2101, output_dir="/workspace/assets/enemies/silence_mote_v2", version="5.0", fallback_to_pollinations=True, **overrides)`
- [ ] 抠图结果检查：边缘干净，无明显白边或锯齿
- [ ] 描边检查：2px #081426 描边，轮廓在深色背景下可读
- [ ] 多尺寸检查：32 像素仍可辨识（琥珀眼睛 + 轮廓）
- [ ] ROADMAP T191 → - [x]
- [ ] 台账 + changelog + iter count
