# A087 — Tuner (调音师) 头像 v2

| 项 | 值 |
|----|----|
| Asset ID | A087 |
| 任务编号 | T195 |
| Seed | 2105 |
| 参考旧素材 | A035 |
| 风格 | anime |
| 类型 | npc portrait |
| 生成尺寸 | 1024×1536 |
| 画布 | 512×768 |
| 导出尺寸 | 128 / 256 / 512 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | 0 |
| flip | ❌ |
| Retry Seed | 2480 → 2490 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, screen tone highlights, sharp silhouette.

Young woman tuner / sound technician — long braided dark hair with thin glass-cyan ribbon, focused expression, ink-navy technician coat with pale-resonance piping, holding a tuning fork device emitting small amber glow, round-friendly centered composition (head at top-center, shoulders reaching middle). Upper body portrait. Isolated on white background.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (1024, 1536),
    "canvas": (512, 768),
    "exports": [128, 256, 512],
    "outline": 0,
    "anchor": "center",
    "fill_ratio": 0.85,
    "flip": False,
    "tech_suffix": "isolated on white background, upper body portrait, centered, clean presentation, high contrast for background removal, round-friendly composition for NPC dialogue UI",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no realistic, no rough sketch, no messy lines",
}
```

## 输出目录

```
/workspace/assets/ui/npc/tuner_portrait_v2.png
```

## ASSET_REGISTRY 目标行

```
| A087 | Tuner 头像 v2 | NPC/Portrait | Voxglass Seedream NPC portrait | doubao-seedream-5-0-260128 | 2105 | young woman sound technician with long braided dark hair + cyan ribbon + ink-navy coat + tuning fork device emitting amber glow | PASSED/PENDING | assets/ui/npc/tuner_portrait_v2.png | 替换 A035；二次元美少女风格；圆形友好构图；白底抠图；与 Archivist / Silent Merchant 形成三张 NPC 头像风格统一；色板对齐 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="npc", style="anime", subject, seed=2105, output_dir="/workspace/assets/ui/npc/tuner_portrait_v2", ...)`
- [ ] 与 A086/A088 整体风格一致（同样的 anime 渲染方式、同样的冷色主导）
- [ ] ROADMAP T195 → - [x]
- [ ] 台账 + changelog + iter count
