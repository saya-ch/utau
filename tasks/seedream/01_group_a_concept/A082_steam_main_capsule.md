# A082 — Steam Main Capsule 升级版（616×353）

| 项 | 值 |
|----|----|
| Asset ID | A082 |
| 任务编号 | T190 |
| Seed | 2008 |
| 参考旧素材 | A047 voxglass_capsule_main_616x353.png |
| 风格 | concept |
| 类型 | capsule |
| 生成尺寸 | 616×353（Steam main capsule 官方尺寸） |
| 画布 | 不裁剪 |
| 导出尺寸 | 原始（唯一尺寸） |
| 底色 | 画面内自然色 |
| 抠图 | ❌ |
| 描边 | ❌ |
| flip | ❌ |
| Retry Seed | 2540 → 2550 |

## subject

```
digital concept art, cinematic composition, moody atmospheric lighting, highly detailed, professional game art quality, Steam store main capsule art.

Close-up composition: Saya upper body / shoulders visible at left-center, gazing toward a bright resonating glass bell on right, deep ink-navy background, warm amber waveform light from the bell filling the scene with cold teal water reflections. Minimal composition, clear focal point. Empty negative space at top for title overlay, empty space at bottom for tagline overlay.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides

```python
{
    "gen_size": (616, 353),
    "canvas": None,
    "exports": None,
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "Steam store capsule-ready composition, horizontal wide frame, cinematic close-up, negative space at top and bottom for text overlay, no text, no watermark, no logo, no signature, no lettering",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no photorealistic, no 3D render, no oversaturated, no overexposed",
}
```

## 输出目录

```
/workspace/assets/marketing/voxglass_capsule_main_616x353_v2.png
```

## ASSET_REGISTRY 目标行

```
| A082 | Steam Main Capsule v2 | Marketing/Capsule | Voxglass Seedream capsule concept | doubao-seedream-5-0-260128 | 2008 | Steam main capsule 616x353, Saya close-up + resonating glass bell, cinematic minimal composition, amber waveform light from bell | PASSED/PENDING | assets/marketing/voxglass_capsule_main_616x353_v2.png | 继承 A047 语义；上下留空白便于后续叠加文字/标语；冷色主导，琥珀波形光为唯一强调点 |
```

## 执行检查清单

- [ ] `run_seedream_pipeline(asset_type="capsule", style="concept", subject, seed=2008, output_dir="/workspace/assets/marketing/voxglass_capsule_main_616x353_v2", ...)`
- [ ] 视觉检查：画面无文字/Logo，上下有明显留白
- [ ] ROADMAP T190 → - [x]
- [ ] 台账 + changelog + iter count

---

**A 组至此 8 张素材全部规划完毕（A075–A082）。**
