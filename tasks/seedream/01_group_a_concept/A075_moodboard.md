# A075 — Voxglass 情绪板 v2（Moodboard / Concept Art）

| 项 | 值 |
|----|----|
| Asset ID | A075 |
| 任务编号 | T183 |
| Seed | 2001 |
| 参考旧素材 | A001 voxglass_moodboard.png |
| 风格 | concept |
| 类型 | capsule（不抠图，概念参考） |
| 生成尺寸 | 2048×2048 |
| 画布 | 2048（原始，不裁剪） |
| 导出尺寸 | 原始 + 1024 |
| 底色 | 画面内自然底色 — deep ink navy / archive blue 环境光 |
| 抠图 | ❌ 不抠，保留完整氛围 |
| 描边 | ❌ 0 |
| flip | ❌ |
| Retry Seed | 2400（第 1 次被拒）→ 2410（第 2 次） |

## subject（英文主体描述，直接传入 run_seedream_pipeline）

```
digital concept art, cinematic composition, moodboard collage of a flooded underground voice archive — cracked glass bells hanging from stone arches, warm amber waveform light rippling across dark cyan water, deep ink navy atmosphere, one panel showing glass texture study, another panel showing light study, third panel showing prop study, fourth panel showing silhouette study, melancholic but hopeful mood, sparse highlights, professional game concept art quality.

Voxglass style — melancholic resonance, flooded underground voice archive, cracked glass bells, living silence, warm waveform light.

Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. Cold colors dominate 75%, warm accents 10%.
```

## overrides（传入 pipeline_seedream）

```python
{
    "gen_size": (2048, 2048),
    "canvas": None,
    "exports": [1024],
    "outline": 0,
    "flip": False,
    "anchor": None,
    "fill_ratio": None,
    "tech_suffix": "cinematic composition, moody atmospheric lighting, highly detailed, professional game art quality, no text, no watermark, no logo",
    "negative": "no text, no watermark, no logo, no signature, no lettering, no blurry, no low quality, no jpeg artifacts, no photorealistic, no 3D render, no oversaturated, no overexposed, no watermark, no text overlay, no frame",
}
```

## 输出目录

```
/workspace/assets/concepts/voxglass_moodboard_v2.png
（raw: /workspace/assets/concepts/raw/voxglass_moodboard_v2_s2001.png）
```

## ASSET_REGISTRY 目标行（执行后填入）

```
| A075 | Voxglass moodboard v2 | Moodboard/Concept | Voxglass Seedream concept | doubao-seedream-5-0-260128 | 2001 | flooded underground voice archive atmosphere study, 4-panel moodboard | PASSED/PENDING | assets/concepts/voxglass_moodboard_v2.png | 继承 A001 语义，Seedream 5.0 重绘；色板严格 #081426/#F2B66E 约束；不抠图，2048 原始尺寸 |
```

## 执行检查清单

- [ ] 调用 `run_seedream_pipeline(asset_type="capsule", style="concept", subject=↑subject, seed=2001, output_dir="/workspace/assets/concepts/voxglass_moodboard_v2", version="5.0", fallback_to_pollinations=True, **overrides)`
- [ ] result.status == "PASSED"
- [ ] 输出文件可打开，无黑块，无明显文字/水印
- [ ] ASSET_REGISTRY 追加一行
- [ ] ROADMAP T183 → - [x]
- [ ] CHANGELOG 追加本轮
- [ ] ITERATION_COUNT 递增
