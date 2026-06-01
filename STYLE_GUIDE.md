# Style Guide

## Voxglass Visual Constitution

### 风格关键词

Melancholic resonance, flooded archive, cracked glass bells, living silence, warm waveform light, anime heroine with production-readable pixel silhouettes, compact Steam-quality 2D.

中文准则：**深水冷色承载孤独，暖色声波表达修复；主角要有二次元美少女辨识度，但所有服装、道具和动作必须服务可玩性；轮廓优先，细节服从可读性。**

### 色板

| 用途 | Hex | 说明 |
| --- | --- | --- |
| Abyss Black | `#05070D` | 最深背景、寂静核心 |
| Ink Navy | `#081426` | 主背景、角色阴影 |
| Archive Blue | `#12334A` | 石墙、远景 |
| Deep Teal | `#1D6570` | 水光、暗部环境光 |
| Glass Cyan | `#69C7CE` | 玻璃边缘、可交互提示 |
| Pale Resonance | `#B7E7DD` | 高亮裂纹、眼睛、可读轮廓 |
| Muted Violet | `#65506A` | 阴影层次、腐蚀边缘 |
| Coral Pulse | `#E86D5A` | 攻击波峰、危险预兆 |
| Amber Voice | `#F2B66E` | 修复成功、奖励、核心 UI |
| Warm Parchment | `#E6D5B8` | 少量文字或图标高亮 |

使用比例：冷色 75%，中性色 15%，暖色 10%。暖色只用于反馈、目标、危险预兆和奖励，不用于大面积背景。

### 光照

- 主光：低强度青蓝环境光，从水面/玻璃后方透出。
- 强反馈：橙珊瑚色声波脉冲，瞬时高亮，避免常亮。
- 轮廓：主角和敌人必须有 1-2px 青色边缘光或暖色核心，保证深背景可读。
- 禁止：大面积纯黑吞轮廓、无来源泛光、彩虹霓虹、厚重体积光遮挡平台。

### 形状语言

- 主角：Saya，二次元美少女声匣修复者。短深色头发、一缕长青色发束、喉口琥珀共鸣晶体、实用档案馆短外套、裂纹玻璃半披肩、声波围巾、解剖学左前臂的紧凑玻璃声匣装置。不得回到无脸黑斗篷主角。
- 朝向规则：左臂声匣是设定核心，不可改成双臂或中轴设备。正式动画需要左/右朝向分别绘制或手工修正，禁止直接镜像导致声匣换到解剖学右臂。参考 `assets/character/saya_sprite_ref_facing_right.png` 与 `assets/character/saya_sprite_ref_facing_left.png`。
- 敌人：墨团、撕裂布料、触须状边缘，主体是负形剪影；眼/核心只保留一个暖色点。
- 场景：拱门、台阶、悬挂线缆、玻璃钟罩、裂纹、浅水反射。
- 可交互物：都应带有波形、同心圆或裂纹发光，避免靠文字解释。
- UI：细线黄铜边、深色玻璃底、声波图标；不要厚重奇幻边框。

### 像素规格

- 目标内部分辨率：`480x270`，整数倍缩放到 `1920x1080`。
- 瓦片：`16x16` 基础 tile，平台厚度至少 2 tile。
- 主角：`48x64` gameplay sprite，碰撞盒约 `20x42`，玻璃披肩、声波围巾、声匣外凸部分不参与碰撞。
- 小敌人：`32x32` 至 `48x32`；精英敌人 `64x96`；Boss 暂不做。
- 图标：`32x32`，HUD 线宽 1px/2px，状态条高度 6-8px。
- 动画基准：idle 6-8 帧，run 8 帧，jump/fall 2+2 帧，Pulse 6 帧。

### 通用负提示词

No photorealism, no 3D render, no fan art, no school uniform, no maid outfit, no idol costume, no cleavage focus, no cute mascot style, no generic fantasy armor, no oversized weapon, no saturated rainbow palette, no muddy unreadable silhouettes, no excessive particles hiding gameplay, no readable fake text, no logo, no watermark, no browser-game UI, no glossy generic AI anime poster look.

### 参考路径

- Mood board: `assets/concepts/voxglass_moodboard.png`
- Protagonist design options: `assets/concepts/saya_design_options.png`
- Protagonist final concept: `assets/character/saya_final_concept.png`
- Protagonist right-facing sprite reference: `assets/character/saya_sprite_ref_facing_right.png`
- Protagonist left-facing sprite reference: `assets/character/saya_sprite_ref_facing_left.png`
- Protagonist portrait expressions: `assets/character/saya_portrait_expressions.png`
- Environment concept: `assets/concepts/echo_archive_environment_concept.png`
- Enemy sheet: `assets/enemies/silence_enemy_sheet.png`
- Tile concept: `assets/environment/archive_tileset_concept.png`
- Prop sheet: `assets/props/voice_archive_props_sheet.png`
- VFX sheet: `assets/vfx/resonance_vfx_sheet.png`
- UI kit: `assets/ui/voxglass_ui_hud_kit.png`
- Key art: `assets/marketing/voxglass_key_art_no_title.png`

### 资产生成继承 Prompt 核心

Use high-quality pixel-art, Steam indie quality, flooded underground voice archive, cracked glass bells, living silence, crisp sprite-ready silhouettes, deep ink navy and muted teal, glass cyan edge highlights, sparse amber/coral waveform glow, melancholic but hopeful mood. Saya must remain an original anime heroine with short dark hair, one long cyan strand, amber throat shard, cracked-glass half-cape, sound-wave scarf, and compact sound-box gauntlet on her anatomical left forearm. Keep gameplay collision surfaces readable. Avoid text, logos, watermarks, photorealism, 3D render, visual clutter, fan art, school uniform, maid outfit, idol costume, and glossy generic AI anime poster aesthetics.
