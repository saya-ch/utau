# A081 — Steam Feature Capsule 升级版（1200×630）

| 项 | 值 |
|----|----|
| Asset ID | A081 |
| 任务编号 | T189 |
| Seed | 2007 |
| 参考旧素材 | A049 voxglass_capsule_feature_1200x630.png |
| 风格 | concept |
| 类型 | capsule |
| 生成尺寸 | 1200×630（Steam feature capsule 官方尺寸） |
| 画布 | 不裁剪，保持官方比例 |
| 导出尺寸 | 原始 1200×630（唯一尺寸） |
| 底色 | 画面内自然底色 — deep ink navy / archive blue 环境 |
| 抠图 | ❌ |
| 描边 | ❌ |
| flip | ❌ |
| Retry Seed | 2520 → 2530 |

## subject

```
digital concept art, cinematic composition, moody atmospheric lighting, highly detailed, professional game art quality, Steam store feature capsule art.

Saya heroine standing in flooded underground voice archive — tall stone arches rising behind, broken glass bells hanging, shallow dark cyan water reflecting warm amber light, a massive cracked glass bell in the background glowing amber, Saya at center looking slightly up, her left forearm glass gauntlet emitting waveform light. Title and logo area left intentionally empty at bottom for later overlay.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (1200, 630),
    "canvas": None,
    "exports": None,
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "Steam store capsule-ready composition, horizontal wide frame, cinematic, dramatic lighting, negative space at bottom for title overlay, no text, no watermark, no logo",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed",
}
```

## 输出目录

```
/workspace/assets/marketing/voxglass_capsule_feature_1200x630_v2.png
```

## ASSET_REGISTRY 目标行

```
| A081 | Steam Feature Capsule v2 | Marketing/Capsule | Voxglass Seedream capsule concept | doubao-seedream-5-0-260128 | 2007 | Steam feature capsule 1200x630, Saya in flooded voice archive with massive cracked glass bell background, cinematic lighting, empty bottom area for title | PASSED/PENDING | assets/marketing/voxglass_capsule_feature_1200x630_v2.png | 继承 A049 语义；底部留空便于后续叠加文字；严格冷色 75% 主导 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="capsule", style="concept", subject, seed=2007, output_dir="/workspace/assets/marketing/voxglass_capsule_feature_1200x630_v2", ...)`
- [ ] 视觉检查：画面无文字/Logo，底部有负空间可叠加标题，主角清晰
- [ ] ROADMAP T189 → - [x]
- [ ] 台账 + changelog + iter count
