# A094 — 备选成就图标 - 合集（设计探索）

| 项 | 值 |
|----|----|
| Asset ID | A094 |
| 任务编号 | T202 |
| Seed | 2206 |
| 风格 | ui / anime |
| 类型 | achievement |
| 生成尺寸 | 256×256（成就图标通常更小） |
| 画布 | 64 |
| 导出尺寸 | 16 / 32 / 64 |
| 底色 | **白底 pure white** |
| 抠图 | ✅ rembg u2net |
| 描边 | ✅ 1px black |
| flip | ❌ |
| Retry Seed | 2620 → 2630 |

## 设计意图

对比 A039-A046 的 9 个程序化成就图标——本素材做一个"成就合集探索版"：
- 3 个小图标在 1 个画面内，形成"成就徽章组"的参考素材
- 3 个小图标：Bell（修复声匣）、Silence Mote（净化敌人）、Waveform（共鸣）

## subject

```
game UI element, flat design, clean edges, readable at small sizes, pixel crisp lines, no anti-aliasing, isolated presentation.

Achievement icon set — a reference exploration: three small circular badge designs in one reference layout, each badge a tiny round icon with:
(1) a cracked-glass bell with amber glow (bell repair badge),
(2) a small dark ink blob with amber eye (silence mote badge),
(3) a concentric waveform ring pattern (resonance ring badge).
All badges fit inside one reference image at 3 positions (left/center/right). Cold colors dominate, warm accents for eyes/cores. Isolated on pure white background, centered, clean edges, readable at tiny sizes (16x16).

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (256, 256),
    "canvas": 64,
    "exports": [16, 32, 64],
    "outline": 1,
    "anchor": "center",
    "fill_ratio": 0.95,
    "flip": False,
    "tech_suffix": "isolated on pure white background, centered, simple icon set, clean edges, readable at tiny sizes (16x16), high contrast for background removal. Three badge icons in one image as a design exploration.","negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed",
}
```

## 输出目录

```
/workspace/assets/ui/achievements/achievement_icon_set_v2.png
```

## ASSET_REGISTRY 目标行

```
| A094 | 成就图标合集探索版 | Achievement/Exploration | Voxglass Seedream UI icon set | doubao-seedream-5-0-260128 | 2206 | three small circular badge designs in one layout: glass bell badge + silence mote badge + waveform ring badge, cold dominant with warm accents | PASSED/PENDING | assets/ui/achievements/achievement_icon_set_v2.png | 成就图标探索素材；白底抠图 + 1px black 描边；16/32/64 三尺寸导出；与 A039-A046 做风格对比供未来扩展 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="achievement", style="ui", subject, seed=2206, output_dir="/workspace/assets/ui/achievements/achievement_icon_set_v2", ...)`
- [ ] 16x16 尺寸下仍可辨识三个小图标轮廓
- [ ] ROADMAP T202 → - [x]
- [ ] 台账 + changelog + iter count

---

**C 组至此 6 张素材规划完毕（A089–A094）。

完整的 Seedream 素材换血工程规划阶段全部规划文件总数：8 (A 组) + 6 (B 组) + 6 (C 组) + 4 (spec) + 1 (README) = 25 个任务规划文件。总计 20 个素材 + 4 个 spec。
