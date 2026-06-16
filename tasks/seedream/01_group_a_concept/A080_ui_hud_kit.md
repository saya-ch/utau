# A080 — 共鸣 HUD / UI 套件 v2（横版布局）

| 项 | 值 |
|----|----|
| Asset ID | A080 |
| 任务编号 | T188 |
| Seed | 2006 |
| 参考旧素材 | A015 voxglass_ui_hud_kit.png + STYLE_GUIDE UI 形状语言 |
| 风格 | ui |
| 类型 | background（不抠图，横版 UI 参考图） |
| 生成尺寸 | 1920×1080 |
| 画布 | 不裁剪 |
| 导出尺寸 | 原始 + 960 |
| 底色 | 画面内自然色（ink navy 游戏内背景） |
| 抠图 | ❌ |
| 描边 | ❌ |
| flip | ❌ |
| Retry Seed | 2500 → 2510 |

## subject

```
game UI element, flat design, clean edges, readable at small sizes, pixel crisp lines, no anti-aliasing, isolated presentation. Horizontal UI/HUD kit composition showing a full game interface:

- Top-left: player health bar (thin amber bar, warm amber-voice #F2B66E color)
- Top-right: resonance energy gauge (glass-cyan #69C7CE bar with pale-resonance highlight)
- Bottom-left: 5 verb action icons in a row (Pulse / Bind / Cut / Echo / Resonance Wave) — each small round icon with cold color variants
- Bottom-center: central target/lock indicator
- Bottom-right: bell repair status indicator
- Center: one small amber waveform pop-up notification

The overall color palette is strictly cold-dominant (ink-navy #081426 background with archive-blue #12334A panels), with amber-voice #F2B66E accents used ONLY for progress bars, not as fill colors. Thin brass outline style, dark glass backgrounds, waveform icons. No text, no readable fake words.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (1920, 1080),
    "canvas": None,
    "exports": [960],
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "horizontal HUD layout composition, flat design, clean edges, pixel crisp lines, thin brass outlines, dark glass panel backgrounds, no text, no readable fake text, no watermark, no logo, professional game UI kit reference",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no bevel, no drop shadow, no glossy, no metallic reflection",
}
```

## 输出目录

```
/workspace/assets/ui/voxglass_ui_hud_kit_v2.png
```

## ASSET_REGISTRY 目标行

```
| A080 | 共鸣 HUD/UI 套件 v2 | UI/Concept | Voxglass Seedream UI concept | doubao-seedream-5-0-260128 | 2006 | horizontal HUD layout showing 5 verb action icons + health/energy bars + bell repair indicator, thin brass outline, dark glass panel backgrounds, amber accents | PASSED/PENDING | assets/ui/voxglass_ui_hud_kit_v2.png | 继承 A015 语义；冷色背景 + 暖色仅有强调条；不抠图；为 B/C 组图标提供风格参考 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="background", style="ui", subject, seed=2006, output_dir="/workspace/assets/ui/voxglass_ui_hud_kit_v2", ...)`
- [ ] 视觉检查：画面无任何文字/Logo，5 动词图标可辨识
- [ ] ROADMAP T188 → - [x]
- [ ] 台账 + changelog + iter count
