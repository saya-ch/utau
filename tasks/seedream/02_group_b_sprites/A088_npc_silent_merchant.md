# A088 — Silent Merchant (寂静商人) 头像 v2

| 项 | 值 |
|----|----|
| Asset ID | A088 |
| 任务编号 | T196 |
| Seed | 2106 |
| 参考旧素材 | A051 silent_merchant_portrait.png |
| 风格 | anime |
| 类型 | npc portrait |
| 生成尺寸 | 1024×1536 |
| 画布 | 512×768 |
| 导出尺寸 | 128 / 256 / 512 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | 0 |
| flip | ❌ |
| Retry Seed | 2500 → 2510 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, screen tone highlights, sharp silhouette.

Mysterious silent merchant — young woman with long ink-black hair with subtle amber highlights, half hidden behind hooded cloak, neutral mysterious expression, hood edged in warm parchment gold trim, amber-voice glow emanating faintly from within the cloak near her hands. Upper body portrait, round-friendly centered composition. Isolated on white background.

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
/workspace/assets/ui/npc/silent_merchant_portrait_v2.png
```

## ASSET_REGISTRY 目标行

```
| A088 | Silent Merchant 头像 v2 | NPC/Portrait | Voxglass Seedream NPC portrait | doubao-seedream-5-0-260128 | 2106 | mysterious hooded young woman merchant, long ink-black hair, amber glow from within cloak, neutral mysterious expression, round-friendly centered upper body portrait | PASSED/PENDING | assets/ui/npc/silent_merchant_portrait_v2.png | 替换 A051；二次元美少女风格；与 A086/A087 组成统一风格的 NPC 三人组；白底抠图 + 多尺寸导出；风格保持冷色 75% 主导 + 暖色 10% 点缀 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="npc", style="anime", subject, seed=2106, output_dir="/workspace/assets/ui/npc/silent_merchant_portrait_v2", ...)`
- [ ] 三张 NPC 头像风格一致（同 anime 渲染、同色系）
- [ ] ROADMAP T196 → - [x]
- [ ] 台账 + changelog + iter count

---

**B 组至此 6 张素材全部规划完毕（A083–A088）。**
