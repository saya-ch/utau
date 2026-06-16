# Prompt 模板与合成顺序

> 所有 Axxx 任务文件应按以下顺序合成 Prompt：

```
[1] 风格基座（_STYLE[style]）
[2] 主体英文描述（subject，最自由的部分）
[3] Voxglass 世界观约束（固定句，强制）
[4] Voxglass 色板约束（固定句，强制）
[5] 比例约束（冷 75% / 暖 10%）
[6] 技术后缀（_TECH_SUFFIX[asset_type]）

负提示词：_NEGATIVE_BASE + _NEGATIVE_EXTRA[style]
```

## 固定句（不可修改，确保风格一致）

**Voxglass 世界观句**
```
Voxglass style — melancholic resonance, flooded underground voice archive,
cracked glass bells, living silence, warm waveform light.
```

**Voxglass 色板句**
```
Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570,
glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A,
coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8.
Cold colors dominate 75%, warm accents 10%.
```

## 风格基座速查

| key | 内容 |
|-----|------|
| pixel-art | pixel art style, 16-bit retro game sprite, chunky pixel outline, limited color palette, no anti-aliasing, crisp pixel edges, readable silhouette for 2D platformer gameplay |
| anime | anime style illustration, cel-shaded, clean lineart, flat shading, screen tone highlights, sharp silhouette |
| concept | digital concept art, cinematic composition, moody atmospheric lighting, highly detailed, professional game art quality |
| ui | game UI element, flat design, clean edges, readable at small sizes, pixel crisp lines, no anti-aliasing, isolated presentation |
| background | game environment background, wide landscape, atmospheric depth, parallax-ready composition, no foreground characters, no UI |

## 技术后缀速查

| asset_type | 内容 |
|-----------|------|
| character/monster | isolated on white background, full body, centered, clean silhouette, high contrast between subject and background for easy background removal |
| npc | isolated on white background, upper body portrait, centered, clean presentation, high contrast for background removal |
| item/prop | isolated on pure white background, centered, single item, no shadows, high contrast for easy background removal |
| skill-icon | isolated on pure white background, centered, single icon, clean edges, readable at small sizes, high contrast for easy background removal |
| achievement | isolated on pure white background, centered, simple icon, clean edges, readable at tiny sizes (16x16), high contrast for background removal |
| background | no text, no watermark, no foreground character, no UI, atmospheric depth, wide landscape composition, parallax-ready |
| tileset | seamless tileable game environment texture, top-down view, grid-aligned, repeatable with no visible seams, clean edges |
| capsule | Steam store capsule-ready composition, clean composition, no text, no watermark, no logo |
| effect | isolated on pure black background, centered burst, animation-ready, high contrast for alpha channel extraction |
| portrait | headshot or upper body portrait, clean background, centered composition, expressive face, high contrast |

## 负提示词速查

**_NEGATIVE_BASE（全类型通用）**
```
no text, no watermark, no logo, no signature, no lettering,
no blurry, no low quality, no jpeg artifacts, no grainy, no noisy,
no photorealistic, no 3D render, no oversaturated, no overexposed
```

**_NEGATIVE_EXTRA[style]（按风格补充）**
| key | 补充 |
|-----|-----|
| pixel-art | no smooth edges, no anti-aliasing, no gradient, no soft blurry lines |
| anime | no realistic, no photorealistic, no 3D, no rough sketch, no messy lines |
| concept | no watermark, no text overlay, no frame |
| ui | no 3D, no bevel, no drop shadow, no glossy, no metallic reflection |
| background | no foreground character, no UI overlay, no text |

## 完整示例（A075 moodboard 示例）

```python
subject = (
    "anime style illustration, cel-shaded, clean lineart, "
    "moodboard collage of a flooded underground voice archive, "
    "broken glass bells hanging from cracked stone arches, "
    "warm amber waveform light rippling across dark cyan water, "
    "deep ink navy background, one cracked glass texture study, "
    "multiple panel composition showing atmosphere, light study and prop study, silhouette study, "
    "Voxglass style — melancholic resonance, flooded underground voice archive, "
    "cracked glass bells, living silence, warm waveform light. "
    "Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570, "
    "glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A, "
    "coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8. "
    "Cold colors dominate 75%, warm accents 10%. "
    "cinematic composition, moody atmospheric lighting, highly detailed, "
    "professional game art quality, game concept art, "
    "isolated on white background, centered, high contrast for background removal"
)
```
