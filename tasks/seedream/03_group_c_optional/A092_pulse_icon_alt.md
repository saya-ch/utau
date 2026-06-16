# A092 — 备选技能图标 - Pulse（圆环变体

| 项 | 值 |
|----|----|
| Asset ID | A092 |
| 任务编号 | T200 |
| Seed | 2204 |
| 风格 | ui / anime |
| 类型 | skill-icon |
| 生成尺寸 | 512×512 |
| 画布 | 128 |
| 导出尺寸 | 32 / 64 / 128 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ❌（图标固定朝向） |
| Retry Seed | 2580 → 2590 |

## 设计意图

与现有程序化 Pulse 图标（更几何圆环）的变体——风格上做**不同圆环风格**进行 A/B 对比：
- **A 版**：更厚重玻璃圆形轮廓 + 琥珀/珊瑚辉光（当前版本）
- **B 版（本素材）**：更细的玻璃-青色圆环，内部是玻璃青色波形，主题色 glass-cyan + coral pulse 双色，形成玻璃罩感，更轻盈的"玻璃盾 + 声波反射"

## subject

```
game UI element, flat design, clean edges, readable at small sizes, pixel crisp lines, no anti-aliasing, isolated presentation.

Pulse verb skill icon — a thin glass-cyan ring (#69C7CE) with subtle glass shield reflection, an inner coral-pulse (#E86D5A) sonic ring forming a double concentric circle, a vertical arrow pointing upward for direction of pulse. Isolated on pure white background, centered, single icon, clean edges, readable at small sizes. Clean high contrast for background removal.

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
/workspace/assets/ui/skill_icons/pulse_icon_alt.png
```

## ASSET_REGISTRY 目标行

```
| A092 | Pulse 图标变体 | Skill Icon Alt | Voxglass Seedream UI icon | doubao-seedream-5-0-260128 | 2204 | glass-cyan ring + coral pulse ring + vertical arrow upward pulse direction, glass shield aesthetic, thinner than A025 original | PASSED/PENDING | assets/ui/skill_icons/pulse_icon_alt.png | 备选图标 A/B 测试素材；白底抠图 + 1px black 描边；对比 A025（原程序化生成）；多尺寸 32/64/128 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="skill-icon", style="ui", subject, seed=2204, output_dir="/workspace/assets/ui/skill_icons/pulse_icon_alt", ...)`
- [ ] 与原图标风格对比，选更优者供未来替换
- [ ] ROADMAP T200 → - [x]
- [ ] 台账 + changelog + iter count
