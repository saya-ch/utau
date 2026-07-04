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

### 4 Verb 命中色查表常量（`ScreenShake.VERB_HIT_*_COLOR`）

F009 (#94) — 4 verb（Pulse / Bind / Cut / Echo）命中反馈使用 **唯一色常量**，
定义在 `src/autoload/screen_shake.gd` 的 `ScreenShake.VERB_HIT_*_COLOR` 4 元组。
第 5 verb（Wave / ResonanceWave）使用独立 ring 系统，**不**参与此查表（其
色域 Pale Resonance 已在色板表中，与"4 verb 命中"语义不同 —— 4 verb 是"谁
命中我"的语义，Wave 是"我自己蓄力"的语义）。

F013.E (#159) — 第六 verb（Whisper / WhisperAbility）同样使用独立 sphere
系统（constant 球不扩散），也**不**参与此查表。Whisper 的色域 Muted Mauve
#C8A4D8 在色板表里，与 Wave 的"我自己蓄力"语义不同 —— Whisper 是"debuff
贴身"（"自己按下静默场"的语义）。5+1 verb 屏幕闪 6 段在 player.gd
_on_<verb>_fired 内分别硬编码（与 5 verb 同模式），但 BBCode + HUD 6 verb
色块共用 #C8A4D8 一致性约束。

| 动词 | 常量名 | Hex | 色板名 | 用途 |
| --- | --- | --- | --- | --- |
| Pulse  | `ScreenShake.VERB_HIT_PULSE_COLOR` | `#E86D5A` | Coral Pulse     | 4 verb 命中色 1：Pulse 命中瞬间屏幕 flash |
| Bind   | `ScreenShake.VERB_HIT_BIND_COLOR`  | `#65506A` | Muted Violet    | 4 verb 命中色 2：Bind 命中瞬间屏幕 flash |
| Cut    | `ScreenShake.VERB_HIT_CUT_COLOR`   | `#F2B66E` | Amber Voice     | 4 verb 命中色 3：Cut 命中瞬间屏幕 flash |
| Echo   | `ScreenShake.VERB_HIT_ECHO_COLOR`  | `#69C7CE` | Glass Cyan      | 4 verb 命中色 4：Echo 命中瞬间屏幕 flash |
| Wave   | (无 ScreenShake 常量)             | `#B7E6DC` | Pale Resonance  | 5 verb 独立 ring 系统 + Pale Resonance 屏幕闪 0.12s/0.15 (player.gd 硬编码, 5 verb 一致性约束外) |
| Whisper | (无 ScreenShake 常量)             | `#C8A4D8` | Muted Mauve     | 6 verb 独立 sphere 系统 + Muted Mauve 屏幕闪 0.10s/0.20 (player.gd 硬编码, 6 verb 一致性约束外) |

调用契约（`player.gd` `_on_*_hit` 5 个 handler 之一）：

```gdscript
ScreenShake.flash_color(ScreenShake.VERB_HIT_PULSE_COLOR, 0.10, 0.18)
```

其中第二个参数是 flash 强度（color overlay alpha），第三个是 duration（秒）。
**所有 4 verb 命中调用必须经此查表**，禁止在 hit handler 内直接 `Color("#...")`
硬编码（一致性约束 T170 #88 锚定）。Wave 命中时**不**调用此查表 —— Wave
hit 的视觉反馈是 `resonance_wave_vfx.gd.add_hit_flash()` 的 0.4s 玻璃白闪
（与 `PLAYER_HIT_FLASH_WHITE` 不同，是 verb-specific 反馈）。

未来 6th verb 接入时：必须在 `ScreenShake` 加 `VERB_HIT_<NAME>_COLOR` 常量 +
在 `STYLE_GUIDE.md` 本节加入一行，并在 `player.gd` 5 个 `_on_*_hit` 之外
新增一个 `_on_<name>_hit` handler。这是 **4 verb 命中色查表** 的宪法修订
流程（任何代码直接硬编码 `#E86D5A` 等 4 元组 hex 即视为违反）。

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
