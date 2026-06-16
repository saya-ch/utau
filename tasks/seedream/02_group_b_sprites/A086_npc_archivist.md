# A086 — Archivist (档案管理员) 头像 v2

| 项 | 值 |
|----|----|
| Asset ID | A086 |
| 任务编号 | T194 |
| Seed | 2104 |
| 参考旧素材 | A034 (原 NPC 档案管理员) |
| 风格 | anime |
| 类型 | npc portrait（圆形框友好构图） |
| 生成尺寸 | 1024×1536（竖版半身像） |
| 画布 | 512×768 |
| 导出尺寸 | 128 / 256 / 512 |
| 底色 | **白底 pure white**（抠图后可在对话 UI 中叠加圆形遮罩） |
| 抠图 | ✅ rembg u2net |
| 描边 | 0（对话 UI 负责加圆形框） |
| flip | ❌（NPC 固定朝向） |
| Retry Seed | 2460 → 2470 |

## subject

```
anime style illustration, cel-shaded, clean lineart, flat shading, screen tone highlights, sharp silhouette.

Elderly archivist scholar — round glasses, kind and wise expression, white/gray hair tied in a bun, warm parchment-colored scholar robes with ink-navy outer coat, holding a small amber glowing lantern near the chest. Upper body portrait. Isolated on white background. Centered composition with head at top-center and shoulders reaching near middle, clear round-friendly composition (subject sits perfectly inside a circle). Calm melancholic expression.

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
/workspace/assets/ui/npc/archivist_portrait_v2.png
```

## ASSET_REGISTRY 目标行

```
| A086 | Archivist 头像 v2 | NPC/Portrait | Voxglass Seedream NPC portrait | doubao-seedream-5-0-260128 | 2104 | elderly archivist scholar with round glasses + white hair bun + amber glow, round-friendly centered composition, upper body portrait | PASSED/PENDING | assets/ui/npc/archivist_portrait_v2.png | 替换 A034；白底抠图 + 圆形构图；对话 UI 负责加圆形框，素材本身无描边；下采样到 128/256/512；二次元美少女风格保持冷色 75% 暖色 10% （amber 仅作点缀 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="npc", style="anime", subject, seed=2104, output_dir="/workspace/assets/ui/npc/archivist_portrait_v2", ...)`
- [ ] 圆形构图检查：主体在中心圆形范围内，肩膀/头发不超圈
- [ ] ROADMAP T194 → - [x]
- [ ] 台账 + changelog + iter count
