# 抠图策略与底色生成

> 决定"素材生成时使用什么底色"和"后续是否进行抠图"。
> 这是影响 Seedream 生成质量的最关键决策之一——错误的底色会导致
> rembg 抠图失败或边缘锯齿。

## 原则

1. **需要抠图 → 用白底**（white background），确保主体与背景高对比
2. **不需要抠图 → 让画面内自然渐变色承载底色**
3. **特效类 → 用黑底**（便于 alpha 提取，且叠加时黑底=透明）
4. **A075 作为 moodboard/概念图 → 不抠图**，是为了保留完整氛围
5. **B 组 NPC / 敌人 / 道具 → 全部抠图**（游戏内精灵要求透明底）

## 详细表

| 类型 | 生成尺寸 | prompt 中的底色句 | 是否抠图 | 抠图方法 | 是否加描边 |
|------|---------|-------------------|---------|---------|-----------|
| moodboard / concept-art (不抠) | 2048×2048 | "cinematic composition, atmospheric lighting inside the image, no text, no watermark" | ❌ | — | ❌ |
| character sprite | 1024² | "isolated on white background, full body, centered, clean silhouette, high contrast for background removal" | ✅ | rembg u2net → alpha refine | 2px Ink Navy |
| enemy / monster sprite | 1024² | "isolated on white background, full body, centered, clean silhouette" | ✅ | rembg u2net → alpha refine | 2px Ink Navy |
| NPC portrait (圆形框) | 1024×1536 | "isolated on white background, upper body portrait, centered" | ✅ | rembg u2net（游戏内叠加圆形 mask） | 0px（圆形框由 Godot 负责） |
| item / prop | 512² | "isolated on pure white background, centered, single item, no shadows" | ✅ | rembg u2net → alpha refine | 1px black |
| skill-icon | 512² | "isolated on pure white background, centered, single icon, clean edges" | ✅ | rembg u2net → alpha refine | 1px black |
| achievement icon | 256² | "isolated on pure white background, centered, simple icon, clean edges" | ✅ | rembg u2net → alpha refine | 1px black |
| environment background | 1920×1080 | "atmospheric depth, wide landscape composition, no foreground characters, no UI, parallax-ready" | ❌ | — | 0 |
| tileset proxy | 1024² | "seamless tileable game environment texture, top-down view, grid-aligned, repeatable with no visible seams" | ❌ | — | 0 |
| Steam capsule | 1200×630 / 616×353 | "Steam store capsule-ready composition, clean composition, no text, no watermark, no logo" | ❌ | — | 0 |
| VFX / effect reference | 512² | "isolated on pure black background, centered burst, animation-ready, high contrast for alpha channel extraction" | ✅ | rembg u2net + black → alpha | 0 |

## Axxx 任务速查

```
A组 — 概念设定 / 胶囊
├── A075 moodboard          ❌ 不抠, 2048², 保留完整氛围
├── A076 saya concept       ❌ 不抠, 2048×1536, 全身+特写参考
├── A077 archive scene      ❌ 不抠, 2048×1152, 大厅视角
├── A078 enemy sheet        ❌ 不抠, 2048², 敌人设计参考
├── A079 prop sheet         ❌ 不抠, 1024², 道具三态参考
├── A080 HUD UI kit         ❌ 不抠, 1920×1080, UI 套件参考
├── A081 Steam feature cap  ❌ 不抠, 1200×630, 商店大图
└── A082 Steam main cap     ❌ 不抠, 616×353, 商店主胶囊

B组 — 游戏内精灵升级（全部白底，✅ rembg 抠图）
├── A083 silence mote v2    ✅ 1024² → 抠图 → 32/64/128/256/512
├── A084 voice bell - broken ✅ 512² → 抠图 → 32/64/128/256
├── A085 voice bell - repaired ✅ 512² → 抠图 → 32/64/128/256
├── A086 archivist portrait ✅ 1024×1536 → 抠图 → 128/256/512
├── A087 tuner portrait     ✅ 1024×1536 → 抠图 → 128/256/512
└── A088 silent merchant    ✅ 1024×1536 → 抠图 → 128/256/512

C组 — 装饰 / 备选图标（全部白底，✅ rembg 抠图）
├── A089 hourglass          ✅ 512²
├── A090 wave totem         ✅ 512²
├── A091 hanging bell       ✅ 512²
├── A092 pulse icon alt     ✅ 512²
├── A093 echo icon alt      ✅ 512²
└── A094 achievement alt    ✅ 256²
```

## pipeline_seedream.py 内的自动选择

```python
# A组（概念/胶囊不抠）：asset_type ∈ {"background","tileset","capsule"} → 自动跳过抠图
# B组（游戏内精灵）：asset_type ∈ {"character","monster","item","npc","skill-icon","achievement","effect"}
#   → 自动 rembg u2net 抠图 + trim + fit + outline + 多尺寸导出
# C组（装饰/备选）同 B组
```
