# A078 — 寂静生物群概念 v2（Mote / Wisp / Warden 三态）

| 项 | 值 |
|----|----|
| Asset ID | A078 |
| 任务编号 | T186 |
| Seed | 2004 |
| 参考旧素材 | A004 silence_enemy_sheet.png + A011 note_wisp.png + ink_warden.png |
| 风格 | concept |
| 类型 | capsule（不抠图，敌人设计参考 sheet） |
| 生成尺寸 | 2048×2048 |
| 画布 | 不裁剪 |
| 导出尺寸 | 原始 + 1024 |
| 底色 | 画面内自然色 — deep ink navy 背景 |
| 抠图 | ❌ |
| 描边 | ❌ 0 |
| flip | ❌ |
| Retry Seed | 2460 → 2470 |

## subject

```
digital concept art, cinematic composition, moody atmospheric lighting, highly detailed, professional game art quality. Enemy design reference sheet — 3 creature designs in one composition, labeled in 3 panels:

Panel 1 (left): Silence Mote — small dark ink blob, floating menacingly, one tiny amber eye, wispy tendrils, negative-space silhouette, amorphous drifting shape.

Panel 2 (center-top): Note Wisp — fragile floating glass orb with musical note inside, pale resonance cyan glow, paper-mache wings, shy glowing form, smaller and friendlier than Mote.

Panel 3 (right): Ink Warden — tall humanoid shadow guardian, robed form, glowing amber chest core, crown-like shattered glass halo, larger and imposing, heavy negative-space silhouette with visible crack-lines.

Deep ink-navy #081426 background, amber-voice #F2B66E accent glows only on eyes/crowns/orbs, glass-cyan #69C7CE edge highlights.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (2048, 2048),
    "canvas": None,
    "exports": [1024],
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "enemy creature design reference sheet, three creature panels, clean silhouettes, professional game concept art, moody atmospheric background, no text labels in image, no frame",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no text overlay, no frame",
}
```

## 输出目录

```
/workspace/assets/concepts/silence_enemy_sheet_v2.png
```

## ASSET_REGISTRY 目标行

```
| A078 | 寂静生物群概念 v2 | Enemy/Concept Sheet | Voxglass Seedream enemy concept | doubao-seedream-5-0-260128 | 2004 | Silence Mote + Note Wisp + Ink Warden 3-creature design sheet, negative-space silhouettes, amber glows | PASSED/PENDING | assets/concepts/silence_enemy_sheet_v2.png | 继承 A004/A011 语义；3 只敌人在单张 sheet 上，便于统一风格；不抠图；冷色主体 + 暖色仅作点缀（眼睛/皇冠/核心） |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="capsule", style="concept", subject, seed=2004, output_dir="/workspace/assets/concepts/silence_enemy_sheet_v2", ...)`
- [ ] 视觉检查：画面内无文字标签，但设计上有明显的 3 只敌人分区
- [ ] ROADMAP T186 → - [x]
- [ ] 台账 + changelog + iter count 更新
