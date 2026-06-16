# A093 — 备选技能图标 - Echo（护盾变体）

| 项 | 值 |
|----|----|
| Asset ID | A093 |
| 任务编号 | T201 |
| Seed | 2205 |
| 风格 | ui / anime |
| 类型 | skill-icon |
| 生成尺寸 | 512×512 |
| 画布 | 128 |
| 导出尺寸 | 32 / 64 / 128 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ❌ |
| Retry Seed | 2600 → 2610 |

## subject

```
game UI element, flat design, clean edges, readable at small sizes, pixel crisp lines, no anti-aliasing, isolated presentation.

Echo verb skill icon — stylized glass shield / hemisphere shape in glass-cyan (#69C7CE) with pale-resonance highlight, two small coral-pulse arrows bouncing off inner shield surface (echo reflection), a small amber core at center representing the echo source. Isolated on pure white background, centered, single icon, clean edges, readable at small sizes.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (512, 512),
    "canvas": 128,
    "exports": [32, 64, 128],
    "outline": 1,
    "anchor": "center",
    "fill_ratio": 0.95,
    "flip": False,
    "tech_suffix": "isolated on pure white background, centered, single icon, clean edges, readable at small sizes, high contrast for easy background removal",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed, no bevel, no drop shadow, no glossy, no metallic reflection",
}
```

## 输出目录

```
/workspace/assets/ui/skill_icons/echo_icon_alt.png
```

## ASSET_REGISTRY 目标行

```
| A093 | Echo 图标变体 | Skill Icon Alt | Voxglass Seedream UI icon | doubao-seedream-5-0-260128 | 2205 | stylized glass hemisphere shield in glass-cyan, pale-resonance highlight + coral-pulse bouncing arrows + amber core at center | PASSED/PENDING | assets/ui/skill_icons/echo_icon_alt.png | 备选技能图标；与 A061 (Echo) 原图标做 A/B 对比；白底抠图 + 1px black 描边；多尺寸 32/64/128 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="skill-icon", style="ui", subject, seed=2205, output_dir="/workspace/assets/ui/skill_icons/echo_icon_alt", ...)`
- [ ] 视觉对比：原 A061 程序化版本 vs 本版本的渲染差异
- [ ] ROADMAP T201 → - [x]
- [ ] 台账 + changelog + iter count
