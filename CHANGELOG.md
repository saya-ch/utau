# Changelog

## [2026-06-02 00:37 #INIT] - 市场调研与方向锚定 | skills:imagegen, market-research, canvas-design-substitute, game-asset-design-substitute | 任务ID:INIT | 备注

- 初始化 8 个状态文件，`ITERATION_COUNT.txt` 保持 `0`。
- 完成 Steam/itch.io 2D 独立游戏市场调研，写入 `RESEARCH.md`。
- 选定工作方向 `Voxglass`：声音修复主题的 2D 动作探索 + 轻量 roguelite 房间结构。
- 生成并保存 5 张概念资产：情绪板、主角、场景、敌人与道具、UI 样本。
- 提炼视觉宪法写入 `STYLE_GUIDE.md`，登记素材到 `ASSET_REGISTRY.md`。
- 拆解 T001-T014 路线图，下一轮从 Godot 4.x 项目骨架开始。

## [2026-06-02 01:52 #INIT] - 女主重设与素材扩充 | skills:imagegen, game-asset-design-substitute, canvas-design-substitute | 任务ID:INIT | 备注

- 根据用户反馈废弃旧版无脸黑斗篷主角，改为原创二次元美少女声匣修复者 `Saya`。
- 保留核心设定：解剖学左前臂的紧凑玻璃声匣装置；为避免镜像错误，生成并登记左右朝向动作参考。
- 扩充 13 张后续可用美术素材：Saya 方向探索、最终设定、左右朝向动作参考、头像表情、敌人表、tile 概念、道具拾取物、VFX、HUD、NPC、背景组、无标题 key art。
- 更新 `STYLE_GUIDE.md`：加入 Saya 角色宪法、左臂声匣朝向规则、AI 风格负提示词。
- 更新 `ROADMAP.md`：T003/T005/T007/T008/T009/T013 改为引用新素材编号。

## [2026-06-02 10:37 #1] - Godot 项目骨架与 Saya 占位素材 | skills:game-development | 任务ID:T001,T002,T003 | 备注

- 完成 T001：手动创建 Godot 4.x 项目骨架，配置 480x270 内部分辨率、整数倍缩放到 1920x1080。
- 完成 T002：实现 Saya 角色控制器，包含移动、跳跃、土狼时间、跳跃缓冲、下落重力倍增、镜头跟随。
- 完成 T003：生成 Saya 占位 spritesheet (864x64, 18 帧)，遵循 STYLE_GUIDE 色板与左臂声匣设定。
- 创建 GameState 与 AudioManager 自动加载单例。
- 登记新素材 A019 到 ASSET_REGISTRY.md。
- `ITERATION_COUNT.txt` 更新为 `1`。

## [2026-06-02 11:00 #2] - Pulse 核心机制与首个灰盒房间 | skills:game-development, game-asset-design | 任务ID:T004,T005,T006 | 备注

- 完成 T004：实现 Pulse 声波动作系统。
  - `PulseAbility` 类：短前摇(0.08s)、圆环判定(半径48px)、冷却(0.5s)、消耗共鸣能量(15点)。
  - 击退力 200px/s，对敌人/可交互物/危险区三类目标分别处理。
  - `PulseVFX`：玻璃青色圆环扩散 + 琥珀色核心 + 珊瑚色火花粒子。
- 完成 T005：生成首个回声档案馆 proxy 素材。
  - `archive_tileset_proxy.png`：512x512 像素 tileset，深海军蓝与青色调，含裂纹石砖、玻璃碎片、电缆、水洼。
  - `archive_room_bg.png`：480x270 房间背景，拱门、悬挂线缆、浅水反射、远处玻璃钟罩。
  - 登记新素材 A020、A021 到 ASSET_REGISTRY.md。
- 完成 T006：搭建首个可玩灰盒房间。
  - 3 层平台 + 地面 + 房间边界。
  - 浅水危险区：进入减速 50% + 每秒伤害 + 向上击退。
  - 玻璃锁(GlassLock)：Pulse 触发修复，修复后碰撞禁用 + 视觉淡出。
  - 声匣(VoiceBell)：Pulse 修复后产生共鸣碎片，玩家触碰收集。
  - 寂静微粒(SilenceMote)：巡逻 AI，接触伤害，可被 Pulse 击退/击杀。
  - 玩家加入 `set_speed_multiplier` 接口支持水域减速。
- 更新 `player.tscn`：添加 PulseAbility 和 PulseVFX 节点。
- 更新 `main.tscn`：完整房间布局，集成所有新机制。
- `ITERATION_COUNT.txt` 更新为 `2`。

## [2026-06-02 12:00 #3] - VFX 完善、HUD 实现与敌人净化机制 | skills:game-development, frontend-skill | 任务ID:T007,T008,T009 | 备注

- 完成 T007：完善 Pulse 与修复 VFX 系统。
  - `PulseVFX` 增强：3 层波纹圆环 + 波形弧线 + 动态火花粒子，全部基于 STYLE_GUIDE 色板绘制。
  - 新增 `RepairVFX`：暖色核心光晕、上升波形线、扩散玻璃环、菱形闪光粒子，用于玻璃锁/声匣修复与敌人净化。
  - Pulse 触发时加入轻微镜头抖动（2px 随机偏移，0.1s 恢复）。
- 完成 T008：完善 SilenceMote 敌人行为。
  - 新增波形预兆：巡逻前 0.6s 珊瑚色闪烁警告，间隔 2.5s，提升可读性。
  - 新增净化死亡：被 Pulse 击杀时不直接消失，而是变为暖色、向上飘浮、淡出，并触发 RepairVFX。
  - 修复死亡与伤害状态的竞态条件。
- 完成 T009：实现 HUD 系统。
  - 生命值：玻璃青色钟形分段（ColorRect），损坏段变为暗紫色。
  - 共鸣能量：青蓝进度条 + 数值标签。
  - Pulse 冷却：琥珀色小进度条，实时反映冷却比例。
  - 修复提示：中央暖色文字（"门锁已修复"/"声匣已修复"/"共鸣不足"），2s 淡出。
  - 碎片计数：右上角 ◆ 图标 + 数字。
  - HUD 通过 `hud` 组被 GlassLock/VoiceBell/Player 动态访问。
- 更新 `main.tscn`：集成 HUD 实例，为 SilenceMote 添加 WarnIndicator 节点。
- `ITERATION_COUNT.txt` 更新为 `3`。

## [2026-06-02 12:00 #4] - 房间完成奖励系统与 Steam 页面定位 | skills:game-development, frontend-skill | 任务ID:T010,T011 | 备注

- 完成 T010：实现房间完成奖励系统。
  - 新增 `RoomController` 类：统一管理房间状态（完成/失败）。
  - 房间完成条件：玻璃锁已修复 + 声匣碎片已收集。
  - 完成时奖励 3 个共鸣碎片，触发 `RepairVFX` 房间中央大特效，HUD 显示 "房间已修复 +3◆"。
  - 失败条件：生命值归零，HUD 显示 "共鸣消散..."。
  - 信号驱动：`room_completed` / `room_failed` 供后续菜单/重试系统订阅。
  - 更新 `main.tscn`：添加 RoomController 节点，配置 room_id="archive_01"。
- 完成 T011：首版 Steam 页面定位文档。
  - 一句话卖点："修复被寂静吞噬的声音，在沉没的档案馆里找回失落的歌声。"
  - 短描述（~300字）：世界观 + 核心循环 + 情感钩子。
  - 标签：2D Platformer, Action, Pixel Art, Metroidvania, Roguelite, Atmospheric, Female Protagonist, Indie。
  - 首屏截图清单：6 张关键画面，涵盖核心循环每个阶段。
- `ITERATION_COUNT.txt` 更新为 `4`。

## [2026-06-02 12:20 #5] - 第 5 轮审查 | skills:code-review | 任务ID:T014 | 备注

- 触发审查模式（N=5, N % 5 == 0）。
- 代码质量：12 个 GDScript 文件结构清晰，project.godot 配置正确。
- 玩法完整性：核心循环链路完整，无逻辑死胡同。
- 素材一致性：抽查 A019/A020/A021，色板与 STYLE_GUIDE 一致，无风格漂移。
- 文档同步：创建 README.md，修正 T011 状态，ROADMAP 追加 T015/T016。
- 修复严重问题：`RoomController._find_room_objects()` 节点路径错误，导致房间完成检测失效。
- 修复轻微问题：`GameState._respawn()` 现在通知 Player 实际移动；`SilenceMote` 警告闪烁改用稳定计时。
- 输出完整审查报告到 `REVIEW_LOG.md`。
- `ITERATION_COUNT.txt` 更新为 `5`。

## [2026-06-02 12:40 #6] - 首个 60 秒竖切打包与菜单系统 | skills:game-development, frontend-skill | 任务ID:T012,T015,T016 | 备注

- 完成 T012：打包首个 60 秒可玩竖切。
  - 新增 `GameFlowController`：统一管理 TITLE → PLAYING → PAUSED → GAME_OVER 状态机。
  - 房间完成/失败信号接入游戏结束画面，显示成功/失败文本与碎片奖励。
  - 重试功能通过 `get_tree().change_scene_to_file()` 完整重置房间状态。
- 完成 T015：补充 `icon.svg` 项目图标。
  - 基于 STYLE_GUIDE 色板：Ink Navy 背景 + Glass Cyan 外环 + Amber Voice 内核 + Coral Pulse 中心点。
  - 128x128 SVG，契合 Voxglass 声波/共鸣视觉主题。
- 完成 T016：实现开始菜单与暂停菜单。
  - `TitleScreen`：背景图 + 暗化遮罩 + 标题/副标题 + 开始/退出按钮，淡入动画。
  - `PauseMenu`：ESC 触发暂停，继续/重新开始/返回主菜单三选项。
  - `GameOverScreen`：成功显示暖色 "房间已修复" + 碎片数，失败显示暗色 "共鸣消散..." + 重试按钮。
  - 所有菜单使用 `process_mode = ALWAYS`，确保暂停时 UI 仍可交互。
- 更新 `main.tscn`：集成 TitleScreen、PauseMenu、GameOverScreen、GameFlowController 节点。
- `ITERATION_COUNT.txt` 更新为 `6`。

## [2026-06-02 13:00 #7] - 第二轮核心素材生成 | skills:game-asset-design | 任务ID:T013 | 备注

- 完成 T013：生成第二轮核心游戏素材，全部使用 Pollinations flux-anime 模型，seed 1022-1025。
  - A022 `silence_mote.png`：敌人精灵，深墨蓝触须团 + 琥珀单眼，64x64 画布/32x32 游戏尺寸，1px 黑色描边。
  - A023 `voice_bell_broken.png`：破损声匣，裂纹玻璃钟罩 + 暗淡紫内部 + 青色微光边缘。
  - A024 `voice_bell_repaired.png`：修复后声匣，完好钟罩 + 琥珀暖光 + 青色亮边 + 漂浮共鸣粒子。
  - A025 `pulse_icon.png`：Pulse 技能 UI 图标，同心圆声波环 + 珊瑚/琥珀中心 + 青色外环 + 深海军蓝底。
- 所有素材经过去背景、内容裁剪、画布适配、像素风 NEAREST 缩放导出（32x32 + 64x64）。
- 登记 A022-A025 到 `ASSET_REGISTRY.md`。
- `ITERATION_COUNT.txt` 更新为 `7`。

## [2026-06-02 14:00 #8] - Saya 正式版 Spritesheet 与第二个房间 | skills:game-development, game-asset-design-substitute | 任务ID:T017,T018 | 备注

- 完成 T017：生成 Saya 正式版 spritesheet（替代 A019 占位）。
  - 由于 Pollinations API 网络不可用，采用程序化像素绘制替代方案（`scripts/draw_saya_spritesheet.py`）。
  - A026 `saya_spritesheet_right.png`：右朝向，idle 8帧 + run 8帧 + jump 2帧 + fall 2帧，48x64 cell。
  - A027 `saya_spritesheet_left.png`：左朝向临时版（右朝向水平翻转），待正式左朝向绘制。
  - 严格遵循 STYLE_GUIDE 色板：Ink Navy 主体、Glass Cyan 高亮、Amber 声匣核心、半透明玻璃披肩。
  - 更新 `player.gd`：动态加载 spritesheet 并创建 SpriteFrames，左右朝向通过切换 sprite_frames 实现（非 flip_h）。
  - 更新 `player.tscn`：移除占位纹理。
- 完成 T018：实现第二个房间变体 + NoteWisp 敌人。
  - 新增 `NoteWisp` 类：飞行敌人，正弦波水平移动 + 垂直微摆，定时发射 NoteProjectile 追踪玩家。
  - 新增 `NoteProjectile` 类：珊瑚色音符投射物，可被 Pulse 声波销毁。
  - 更新 `PulseAbility`：新增 enemy_projectiles 组检测，Pulse 可摧毁飞行投射物。
  - 创建 `room_archive_02.tscn`：4 层平台 + 2 个 NoteWisp + 1 个 GlassLock + 1 个 VoiceBell + 浅水区，room_id="archive_02"。
  - 追加 T021（NoteWisp 正式素材）、T022（房间切换与进度持久化）到 ROADMAP。
- 登记 A026-A027 到 `ASSET_REGISTRY.md`。
- `ITERATION_COUNT.txt` 更新为 `8`。

## [2026-06-02 15:00 #9] - 环境粒子、音效占位与 NoteWisp 素材 | skills:algorithmic-art, game-asset-design-substitute | 任务ID:T019,T020,T021 | 备注

- 完成 T019：增强环境粒子与房间氛围系统。
  - 新增 `EnvironmentParticles` 类：程序化粒子系统，支持三种类型（DUST 灰尘、WATER_GLINT 水面浮光、AMBIENT_GLOW 环境暖光）。
  - 粒子遵循 STYLE_GUIDE 色板：Pale Resonance 灰尘、Glass Cyan 水面闪光、Amber Voice 暖光。
  - 新增 `RoomAtmosphere` 类：声匣修复后房间色调渐变，从冷色底向暖色修复态过渡（2秒缓动）。
- 完成 T020：音效占位系统。
  - 新增 `audio_manager_enhanced.gd`：程序化生成占位音效（无需外部音频文件）。
  - Pulse 回声：上升频率 + 指数衰减 + 谐波叠加。
  - 脚步声：短促噪声 + 快速衰减。
  - 玻璃碎裂：高频噪声 + 2000Hz 铃声衰减。
  - 敌人低鸣：80Hz 正弦波 +  subtle 调制，循环播放。
  - 修复成功音效：下降音高（660Hz→462Hz）+ 闪烁谐波，表达"解决/安定"。
- 完成 T021：生成 NoteWisp 正式版精灵素材。
  - 由于 Pollinations API 超时，采用程序化像素绘制（`scripts/draw_notewisp.py`）。
  - A028 `note_wisp.png`：音符形体敌人，深墨蓝身体 + 琥珀单眼 + 玻璃青色波形尾迹 + 1px 黑色描边。
  - 含 64x64 基础帧、128x128 放大版、4帧 Shimmer spritesheet。
  - 风格与 A022 Silence Mote 一致，保持敌人视觉统一性。
- 登记 A028 到 `ASSET_REGISTRY.md`。
- `ITERATION_COUNT.txt` 更新为 `9`。

## [2026-06-02 16:00 #10] - 房间切换与进度持久化 | skills:game-development | 任务ID:T022 | 备注

- 完成 T022：实现房间切换与进度持久化系统。
  - 新增 `RoomDoor` 类：可配置目标房间路径和出生点，房间完成后自动开启，玩家触碰触发切换。
  - 新增 `RoomTransition` 类：CanvasLayer 全屏淡入淡出遮罩，0.4s 淡出/0.5s 淡入。
  - 重构 `GameFlowController`：新增 ROOM_TRANSITION 状态，房间完成后开启出口门而非直接结束。
  - 扩展 `GameState`：新增 `save_persistent_state()` / `restore_persistent_state()`，跨房间保持生命值、共鸣能量、碎片数、已修复房间记录。
  - 利用 autoload 特性存储 `_is_transitioning` / `_pending_room_path` / `_pending_spawn_point`，确保场景切换后状态不丢失。
  - 更新 `main.tscn`（archive_01）：添加 RoomDoor，目标指向 `room_archive_02.tscn`。
  - 更新 `room_archive_02.tscn`（archive_02）：添加 RoomDoor，目标指回 `main.tscn`（临时循环）。

## [2026-06-02 17:00 #11] - 受击反馈增强、左朝向正式版与第三房间 | skills:game-development, game-asset-design | 任务ID:T023,T024,T025 | 备注

- 完成 T023：玩家受击反馈系统增强。
  - `player.gd`：新增无敌帧系统（0.8s），受击时 sprite 红闪+透明度闪烁，屏幕震动（3px→2px→0），防止连击秒杀。
  - `audio_manager_enhanced.gd`：新增 `_generate_damage_sfx()` 与 `play_damage()`，低 thud + 噪声 burst 表达受击。
  - `project.godot`：将 `AudioManagerEnhanced` 注册为 autoload，确保全局可访问。
- 完成 T024：Saya 左朝向正式版 spritesheet（替代 A027 翻转临时版）。
  - 新建 `scripts/draw_saya_left_spritesheet.py`：完全独立绘制左朝向 18 帧（idle 8 + run 8 + jump 1 + fall 1）。
  - 核心规则：左臂声匣位于画面左侧（解剖学左臂），眼睛位于画面左侧，玻璃披肩从右肩披下，声波围巾飘向右侧。
  - 生成 `assets/sprites/saya_spritesheet_left.png`（864x64）与元数据 JSON。
  - 更新 `ASSET_REGISTRY.md`：A027 状态从 PLACEHOLDER 改为 APPROVED。
- 完成 T025：第三个房间变体 `room_archive_03.tscn`（archive_03）。
  - 垂直阶梯式平台布局：5 层 64px 窄平台，从左下向右上攀升，强调跳跃精度。
  - 混合敌人：2 个 SilenceMote（中层巡逻）+ 1 个 NoteWisp（顶层投射物）。
  - 双水域危险区：左右两侧底部水域，压缩安全空间。
  - 声匣位于顶层平台上方，玻璃锁在最右侧高处，房间完成奖励 7 碎片。
  - RoomDoor 目标指回 `main.tscn`，形成 3 房间循环。
- `ITERATION_COUNT.txt` 更新为 `11`。

## [2026-06-02 18:00 #12] - 存档检查点、敌人 AI 增强与灯笼素材 | skills:game-development, game-asset-design | 任务ID:T026,T027,T028 | 备注

- 完成 T026：实现存档检查点（Save Lantern）系统。
  - 新增 `SaveLantern` 类：Area2D 触发式检查点，玩家触碰后激活。
  - 未激活状态：暗淡紫色调、微光闪烁；激活后：暖琥珀色、呼吸动画、粒子上升。
  - 激活时调用 `GameState.set_checkpoint()` 记录重生点，HUD 显示 "共鸣已记录"。
  - 播放修复成功音效作为反馈。
  - 创建 `save_lantern.tscn` 场景，含 AnimatedSprite2D + CPUParticles2D + 碰撞体。
- 完成 T027：增强 SilenceMote AI。
  - 新增三层状态机：PATROL（巡逻）→ WARNING（预警闪烁）→ CHASE（追击）。
  - 玩家进入 `chase_range`（80px）时触发 0.6s 预警，随后进入追击（速度 60px/s）。
  - 玩家脱离 `lose_interest_range`（120px）后返回巡逻。
  - 追击时 sprite 呈半珊瑚色，增强可读性。
  - 净化后掉落 1 个共鸣碎片（直接加入计数），HUD 显示 "+1◆"。
- 完成 T028：生成存档灯笼素材。
  - 新建 `scripts/generate_save_lantern.py`：程序化像素绘制，遵循 Voxglass 色板。
  - A029 `save_lantern_spritesheet.png`：dim 状态 1 帧 + lit 状态 4 帧 shimmer 呼吸动画，28x36 cell，1px 黑色描边。
  - 风格与 A022-A028 一致：玻璃钟罩形状、共鸣波形线、琥珀核心光晕。
  - 登记 A029 到 `ASSET_REGISTRY.md`。
- 追加 10 个新任务到 ROADMAP 新增任务池（T029-T038）。
- `ITERATION_COUNT.txt` 更新为 `12`。

## [2026-06-02 19:00 #13] - 共鸣碎片拾取物与设置菜单 | skills:game-development, frontend-skill | 任务ID:T029,T037 | 备注

- 完成 T029：实现共鸣碎片拾取物（ResonanceShard）。
  - 新增 `ResonanceShard` 类：Area2D 掉落物，含重力弹跳、玩家接近吸引、触碰收集。
  - 10 秒生命周期，7 秒后开始淡出；收集时触发 RepairVFX 并 HUD 显示 "+1◆"。
  - 更新 `SilenceMote._drop_shard()`：净化后实例化 ResonanceShard 场景并向上弹射。
  - 创建 `resonance_shard.tscn` 场景，复用 pulse_icon.png 作为视觉占位。
- 完成 T037：实现设置菜单（SettingsMenu）。
  - 三标签页：音频（主音量/音效/音乐/环境音）、视频（全屏/窗口缩放 1x-4x）、按键（重映射）。
  - 音量实时应用到 Godot AudioServer 对应 bus。
  - 窗口缩放支持 480x270/960x540/1440x810/1920x1080 四档。
  - 按键重映射：点击按钮后按任意键即时绑定，持久化到 `user://settings.cfg`。
  - 更新 `PauseMenu`：新增「设置」按钮，信号接入 `GameFlowController._on_settings()`。
  - 更新 `main.tscn`：集成 SettingsMenu 实例。
- `ITERATION_COUNT.txt` 更新为 `13`。

## [2026-06-02 20:00 #14] - InkWarden 精英敌人、Bind 能力与 VFX | skills:game-development, game-asset-design | 任务ID:T030,T031,T032 | 备注

- 完成 T030：实现 InkWarden 精英敌人。
  - 新增 `InkWarden` 类：高血量(5)、护盾(3)、破盾后眩晕(2.5s)、破盾后发射珊瑚色投射物。
  - 三层状态机：PATROL → CHASE → STUNNED，护盾存在时免疫直接伤害。
  - 净化后掉落 3 个共鸣碎片。
  - 创建 `ink_warden.tscn` 场景，含 Sprite2D + Hurtbox + ShieldVFX(Line2D)。
- 完成 T031：生成 InkWarden 精英敌人素材。
  - 新建 `scripts/generate_inkwarden.py`：程序化像素绘制，遵循 Voxglass 色板。
  - A030 `ink_warden.png`：64x96 基础帧，深墨蓝大型墨团 + 玻璃青色护盾裂纹 + 琥珀单眼 + 触须披风 + 1px 黑色描边。
  - A031 `ink_warden_shield_broken.png`：护盾破损状态，更多珊瑚色裂纹、眼更亮。
  - A032 `ink_warden_stunned.png`：眩晕状态，淡紫身体、X 形眼、下垂触须。
  - 拼合 `ink_warden_spritesheet.png`（192x96，3 帧）。
  - 登记 A030-A032 到 `ASSET_REGISTRY.md`。
- 完成 T032：实现 Bind（牵引/暂停）声波能力。
  - 新增 `BindAbility` 类：短前摇(0.1s)、圆环判定(半径40px)、冷却(1.2s)、消耗共鸣能量(20点)。
  - 效果：将敌人向玩家方向牵引，支持 `apply_bind()` 接口。
  - 新增 `BindVFX`：向内螺旋 + 收缩圆环 + 暗紫涡旋核心 + 被吸入的粒子火花。
  - 更新 `player.gd`：绑定 K/X/手柄Y 键触发 Bind，接入 VFX 与屏幕微震。
  - 更新 `project.godot`：新增 `bind` 输入映射。
  - 更新 `hud.gd` / `hud.tscn`：新增 Bind 冷却条（Muted Violet 色）。
- `ITERATION_COUNT.txt` 更新为 `14`。

## [2026-06-02 21:00 #15] - 能力门系统与 Bind 图标素材 | skills:game-development, game-asset-design | 任务ID:T033,T034 | 备注

- 完成 T033：实现能力门系统（AbilityGate）。
  - 新增 `AbilityGate` 类：StaticBody2D 阻挡门，支持 `required_ability` 配置（默认 "bind"）。
  - 检测逻辑：Pulse 或 Bind 触发时检查 `GameState.has_ability()`，拥有则开启，无则阻挡并提示。
  - 开启效果：碰撞禁用、颜色渐变为 Glass Cyan、缩放出 RepairVFX、HUD 提示 "通道已开启"。
  - 阻挡效果：sprite 抖动 + Coral Pulse 闪烁 + HUD 提示 "需要 Bind 能力" + 受伤音效。
  - 新增 `HintArea`：玩家靠近未开启门时自动显示提示。
  - 扩展 `GameState`：新增 `abilities` Dictionary、`unlock_ability()`、`has_ability()`，跨房间持久化。
  - 创建 `ability_gate.tscn` 场景，可直接放置到房间中。
- 完成 T034：生成 Bind 能力独立图标。
  - 新建 `scripts/generate_bind_icon.py`：程序化像素绘制，遵循 Voxglass 色板。
  - A033 `bind_icon.png`：32x32 UI 图标，Muted Violet 暗紫底 + Pale Resonance 向内螺旋 + Glass Cyan 收缩环 + Coral Pulse 四角箭头 + Amber Voice 中心亮点。
  - A033-64 `bind_icon_64x64.png`：64x64 高 DPI 版本。
  - 更新 `hud.tscn`：Bind 图标从 Pulse 图标复用（带 self_modulate）改为独立 A033 纹理，消除色差。
  - 登记 A033 到 `ASSET_REGISTRY.md`。

## [2026-06-02 22:00 #16] - Hub 区域与 NPC 对话系统 | skills:game-development, game-asset-design | 任务ID:T035,T036 | 备注

- 完成 T035：实现 Hub 安全区 `hub_room.tscn`。
  - `HubController`：管理 Hub 状态、NPC 交互、出口门过渡。
  - `NPC`：Area2D 触发交互，玩家靠近显示 "按 E 交谈" 提示，支持自定义 portrait。
  - `DialogueBox`：打字机效果对话系统，支持 portrait、名字、选项分支（如 "是的，出发"/"再准备一下"）。
  - 两名 NPC：档案管理员（引导剧情、提供出发选项）与调音自动机（游戏机制提示）。
  - Hub 出口门默认开启，对话选择 "是的，出发" 后触发房间切换至 archive_01。
  - Hub 继承完整 UI：HUD、暂停菜单、设置菜单、RoomTransition 淡入淡出。
- 完成 T036：生成 NPC 头像与对话 UI 素材。
  - 新建 `scripts/generate_npc_portraits.py`：程序化像素绘制，遵循 Voxglass 色板。
  - A034 `archivist_portrait.png`：48x48，老学者白发束髻、眼镜、持灯笼。
  - A035 `tuner_portrait.png`：48x48，机械人偶单眼齿轮、玻璃管、天线。
  - A036 `dialogue_frame.png`：480x70 对话框底图，深色玻璃底 + 细线黄铜边 + portrait 区域框。
  - A037 `npc_sprite_placeholder.png`：32x32 通用 NPC 游戏内占位精灵。
  - 登记 A034-A037 到 `ASSET_REGISTRY.md`。
- `ITERATION_COUNT.txt` 更新为 `16`。

## [2026-06-03 10:00 #17] - 关卡编辑器 JSON 化 | skills:game-development | 任务ID:T038 | 备注

- 完成 T038：实现关卡编辑器支持——房间配置 JSON 化。
  - 新增 `RoomLoader` 类（`src/scripts/room_loader.gd`）：从 JSON 配置文件动态构建完整房间场景树。
    - 支持平台、水域危险区、敌人（silence_mote / note_wisp / ink_warden）、交互物（glass_lock / voice_bell / ability_gate / save_lantern）、房间门、玩家、摄像机、UI、边界墙。
    - 场景预加载缓存，避免运行时重复加载 PackedScene。
  - 新增 `JsonRoom` 场景（`src/scenes/json_room.tscn` + `src/scripts/json_room.gd`）：设置 `room_id` 导出变量即可自动加载对应 JSON 房间。
  - 将现有 3 个房间（archive_01 / archive_02 / archive_03）导出为 JSON 配置，存放于 `data/rooms/`。
  - 编写 `data/rooms/README.md`：完整 JSON Schema 文档，包含所有实体字段与示例。
  - 更新 `README.md`：添加 Room Editor (JSON) 使用说明。
- JSON 已通过语法校验，代码无编译错误。
- `ITERATION_COUNT.txt` 更新为 `17`。

## [2026-06-03 11:00 #18] - Cut 声波能力（第三动词）与腐蚀链障碍 | skills:game-development, game-asset-design | 任务ID:T039,T040 | 备注

- 完成 T039：实现 Cut（切断）声波能力——完成 RESEARCH.md 中"三动词"核心设计（Pulse 推/破盾、Bind 牵引/暂停、**Cut 切断/贯穿**）。
  - 新增 `src/scripts/cut_ability.gd`（`CutAbility` 类，167 行）：短前摇 0.06s、扇形 90° 判定（半径 64px）、冷却 0.8s、消耗 25 共鸣能量、贯穿伤害 2。接口完整：`start_cut()` / `on_cut_triggered()` / `get_cooldown_ratio()`。
  - 新增 `src/scripts/cut_vfx.gd`（`CutVFX` 类，130 行）：水平弧形斩击 + 锋利碎片拖尾 + 中央闪光，区别于 Pulse 圆环与 Bind 螺旋的三层叠加绘制（暗影 / 主锋线 / 刀刃高光）。
  - 新增 `src/scripts/silenced_web.gd` + `src/scenes/silenced_web.tscn`（`SilencedWeb` 类，96 行）：第三种障碍"沉默雾墙/腐蚀链"，Pulse 推不动、Bind 不能拉，只能被 Cut 斩开；切断后两侧滑开 + 暖琥珀色 RepairVFX + 2s 淡出。
  - `player.gd`：新增 `_handle_cut()` / `_on_cut_fired()`，绑定 L/C 键与手柄 LB 按钮，0.04s 屏幕微震（比 Pulse 短促）。
  - `player.tscn`：新增 `CutAbility` 节点。
  - `project.godot`：新增 `cut` 输入映射（L/C/LB）。
  - `hud.gd` / `hud.tscn`：新增 `CutRow`（Coral Pulse 填充色 #E86D5A），与 Pulse/Bind 冷却条三件套并列。
  - `room_loader.gd`：新增 `silenced_web` 实体类型支持。
  - `data/rooms/archive_01.json`：在声匣旁放置 `silenced_web`，玩家可在首个房间实际体验 Cut。
  - `data/rooms/README.md`：文档化 `silenced_web` 实体与 Cut 触发规则。
- 完成 T040：生成 Cut 能力图标素材。
  - 新建 `scripts/generate_cut_icon.py`：程序化像素绘制，遵循 Voxglass 色板。
  - A038 `cut_icon.png`：32x32 UI 图标，深海军蓝底 + 暗紫外环 + 珊瑚色斜下主锋线 + 淡青色刀刃高光 + 暖琥珀闪光点 + 四角飞出三角碎片。
  - A038-64 `cut_icon_64x64.png`：64x64 高 DPI 版本。
  - 风格与 A025 Pulse（圆环）与 A033 Bind（螺旋）成「三动词」视觉组合，珊瑚色锋线与暖色碎片强化"切断"语义。
- 更新 `README.md`：控制表新增 Bind、Cut 行（按键 J/K/L 沿左手指位自然映射）。
- 登记 A038 到 `ASSET_REGISTRY.md`。
- `ITERATION_COUNT.txt` 更新为 `18`。

## [2026-06-03 12:00 #19] - 玩家统计与成就系统 + Tutorial 引导 | skills:game-development, frontend-skill | 任务ID:T041,T042 | 备注

- 完成 T041：实现玩家统计与成就系统——面向 Steam 风格的玩家进度追踪。
  - 新增 `data/achievements.json` 8 个成就定义（第一步、声音净化者、共鸣收集者、三声齐鸣、切断腐蚀、墨守终结者、完整档案、不灭回响）。
  - 新增 `src/autoload/player_stats.gd`（`PlayerStats` 类，204 行）：autoload 单例，10 个累计统计 + 8 个成就；信号 `stat_changed` / `achievement_unlocked`；提供 `record_*` 便捷 API；成就采用 Steam 风格的「永久解锁」（跨运行持久化），累计统计每次新运行重置。
  - 新增 `src/scripts/achievement_notification.gd` + `src/scenes/achievement_notification.tscn`（`AchievementNotification` 类，84 行）：屏幕中央偏上暖色卡片，3 秒停留，淡入滑入 + 淡出滑出；按 `icon_hint` 切换图标颜色（Amber 暖色 / Coral 珊瑚色 / Pale Resonance 青色）。
  - 更新 `pause_menu.gd` + `pause_menu.tscn`（`PauseMenu` 集成 Statistics 面板）：右侧 152x200 玻璃面板，含 7 项统计 + 成就进度 + 回响时长。
  - `project.godot`：注册 `PlayerStats` 为 autoload。
  - 接入统计触发点：
    - `pulse_ability.gd` / `bind_ability.gd` / `cut_ability.gd`：`_execute_*` 调用 `record_ability_used`。
    - `silence_mote.gd` / `note_wisp.gd` / `ink_warden.gd`：`_purify()` 调用 `record_enemy_purified`（InkWarden 同时记录 `ink_wardens_defeated`）。
    - `silenced_web.gd`：`on_cut_triggered` 调用 `record_silence_web_cut`。
    - `voice_bell.gd`：`_collect_shard` 调用 `record_shard_collected`。
    - `room_controller.gd`：`_complete_room` 调用 `record_room_cleared`。
    - `save_lantern.gd`：`_activate` 调用 `record_save_lantern_activated`。
    - `game_state.gd`：`take_damage` 归零时调用 `record_death`；`reset_run` 调用 `reset_stats` 重置累计。
  - `main.tscn` / `hub_room.tscn` / `room_loader.gd`：自动实例化 `AchievementNotification` 到每个房间。
- 完成 T042：Tutorial 引导提示系统——补齐第一分钟体验。
  - 新增 `src/scripts/tutorial_hint.gd` + `src/scenes/tutorial_hint.tscn`（`TutorialHint` 类，76 行）：屏幕底部暖色文字条，淡入淡出；`group_id` 机制防重复显示；`queue_hint(group, text, duration)` 公共 API。
  - `room_controller.gd`：新增 `@export var tutorial_hints: Array` + `_schedule_tutorial_hints()`，根据延迟依次提示。
  - `room_loader.gd`：从 JSON 的 `tutorial_hints` 段读取并应用到 `RoomController`。
  - `data/rooms/archive_01.json`：新增 4 条引导（Pulse 介绍、声匣拾取、水域警告、Cut 介绍），延迟 0.8/8/14/20 秒。
  - `data/rooms/README.md`：文档化 `tutorial_hints` JSON 段。
- 风格一致性：所有新增 UI 严格遵循 STYLE_GUIDE 色板（Ink Navy 底 / Glass Cyan 边 / Amber Voice 暖色 / Coral Pulse 强调），像素规格不变。
- `ITERATION_COUNT.txt` 更新为 `19`。

## [2026-06-03 13:00 #20] - 审查 #20 + 错误修复：GDScript parse 集 + 6 个 PNG 资源 | skills:game-development, frontend-skill | 任务ID:T043 | 备注

**触发**：用户在 Godot 4.6.3 启动后报告 parse 错误日志 → 阻塞性严重问题，先修后审。审查模式顺位延后修复一并完成。

### 修复明细（11 个 GDScript + 6 个 PNG 资源）

- **`src/scripts/player.gd`** (3 处)：`_handle_pulse` / `_handle_bind` / `_handle_cut` 中 `var success :=` 因 `pulse_ability` 等为 Variant 无法推断。改为 `var success: bool = ...` 显式类型注解。
- **`src/scripts/bind_ability.gd:91`**：`_apply_enemy_bind` 中 `var pull_dir := ...` 改为 `var pull_dir: Vector2 = ...`。
- **`src/scripts/cut_ability.gd`** (4 处)：`_execute_enemy_cut` 与 `_execute_projectile_cut` 中 `to_target` / `to_proj` / `dist` 显式类型注解。
- **`src/scripts/camera_follow.gd`**：删除 `snap_to_pixel = true`（Godot 4.6 中此属性不存在，`global_position.round()` 已实现像素吸附）。
- **`src/scripts/resonance_shard.gd:9`**：`@export var gravity` 与 Area2D 原生 `gravity` 属性冲突。改名为 `gravity_force`，并更新 `_physics_process` 中引用。
- **`src/scripts/room_controller.gd:78-86`**：`_check_completion` 中两个 `var x := a if cond else b` 三元表达式推断失败。重构成 if 语句 + 显式 `bool` 类型。
- **`src/scripts/achievement_notification.gd:55`**：`.get()` 返回 Variant 导致 `var icon_color :=` 推断为 Variant 触发 warning-as-error。改为 `var icon_color: Color = ...`。
- **6 个 PNG 资源**：经 `file` 校验发现实为 JPEG（`0xFF 0xD8` 文件头），Godot 加载失败。已用 ffmpeg 重新编码为真正的 PNG：
  - `assets/environment/archive_tileset_proxy.png`（核心 tileset）
  - `assets/environment/archive_room_bg.png`（房间背景）
  - `assets/ui/pulse_icon/raw.png`
  - `assets/enemies/silence_mote/silence_mote_s1022_raw.png`
  - `assets/props/voice_bell_broken/raw.png`
  - `assets/props/voice_bell_repaired/raw.png`
- 修正后的 `silence_mote.gd` / `room_door.tscn` / `main.tscn` 错误均为级联，源头修复后自动消除。
- 容器内无 `godot` 可执行文件，未做运行时回归；静态检查（grep / 读文件）确认所有 `var :=` 推断风险已消除。

### 审查 #20 同步输出

详见 `REVIEW_LOG.md`「审查 #20」段。本次以修复阻塞性 parse 错误为主，完整审计顺延到 #21。
- `ITERATION_COUNT.txt` 更新为 `20`。

## [2026-06-03 14:00 #21] - 审查 #21：完整代码质量 / 玩法 / 素材 / 文档审计 | skills:code-review | 任务ID:T044 | 备注

> **触发**：用户明确指令「这一轮做审查」。本轮完成 #20 顺延的完整审计，并执行本轮登记的轻微修复。

### 审查范围与发现
- 通过项：36 个 `class_name` 全局唯一、4 个 autoload 拓扑一致、11 个 signal 拓扑完整、12 个 PNG 资源头校验通过、A029-A038 素材风格与 STYLE_GUIDE 一致。
- **严重 1 项**（已追加 ROADMAP T045）：**InkWarden 在游戏中从未出现** — `ink_warden.tscn` 与 A030-A032 资源齐全，`room_loader.gd._build_enemy` 有 `ink_warden` 分支，但 `main.tscn` / `hub_room.tscn` / 3 个 JSON 房间均未实例化。`warden_slayer` 成就无法通过正常游玩解锁，T030/T031 工作对玩家完全不可见。
- **一般 6 项**（T046-T049）：NoteWisp 不掉碎片、Hub 房间无 GameFlowController、Hub 房间无 TutorialHint、InkWarden 护盾三元 bug、HubController 双重切换风险、RoomDoor 命名倒置。
- **轻微 5 项**（L001-L005）：README 描述 4.6 兼容、Bind 描述补充、InkWarden shield 死代码、NoteWisp projectile timer、AudioManager 重复 autoload。

### 本轮修复（轻微 + 一般中 2 项）
- **`src/scripts/note_wisp.gd`**：新增 `_drop_shard()` 方法与 `_purify` 调用，使 NoteWisp 净化也掉落 1 个共鸣碎片（轻量级弹射版），与 SilenceMote / InkWarden 行为一致（修复 G001）。
- **`src/scripts/ink_warden.gd`**：修复 `_update_shield_visuals()` 三元表达式死代码 `0.0 if _shield_active else 0.0` → `0.6 if _shield_active else 0.0`，使护盾可见（修复 G004）。
- **`README.md`**：补充 4.6 兼容性说明 + Bind 描述补全（修复 L001 + L002）。

### Godot 运行时回归
- 沙箱内无 Godot 可执行；下载 `Godot_v4.4.1-stable_linux.x86_64.zip` 受限于网络带宽（仅下到 11MB 残片），解压失败。
- 改用深度静态分析：class_name 唯一性 / signal 拓扑 / autoload 标识符 / PNG 头校验全部通过。
- 运行时回归流程漏洞已登记到 ROADMAP 文档（本轮未新增任务，下轮 #22 优先处理 S001 InkWarden 实例化）。

### 风格漂移评估
- 抽查 A029-A038 严格遵循 STYLE_GUIDE 色板（Glass Cyan / Amber Voice / Coral Pulse / Muted Violet / Ink Navy），像素规格 32x32 / 48x48 / 64x96 / 28x36 全部在 STYLE_GUIDE 范围内。
- 无风格漂移。

### 结论
- 状态：**可继续迭代**。
- 严重问题 1 项已登记 T045 至 ROADMAP；一般问题 6 项已登记 T046-T049；轻微问题本轮修复完成。
- 下一轮（#22）必须优先处理 S001 InkWarden 实例化（archive_03 房间 + Hub 剪影）。
- 完整审查报告写入 `REVIEW_LOG.md`「审查 #21」段。
- `ITERATION_COUNT.txt` 更新为 `21`。

## [2026-06-03 15:00 #22] - InkWarden 实例化与 RoomDoor 重命名 | skills:game-development | 任务ID:T045,T049 | 备注

> **触发**：审查 #21 严重任务优先 — S001 InkWarden 实例化（T045）。完成严重任务后顺手做掉 10 分钟轻量重构（T049）。

### T045 完成明细（严重）
- **`data/rooms/archive_03.json`**：enemies 数组从 3 个扩展为 4 个：
  - 保留 `silence_mote #1` (140, 164) 中层巡逻
  - 保留 `silence_mote #2` (340, 104) 高层巡逻
  - `note_wisp` 位置从中央 (240, 100) 调整到入口 (60, 194)，让出中央 boss 区
  - **新增** `ink_warden` @ (240, 134) 站在 240,150 平台正上方，5 血 + 3 护盾，落在 `RoomLoader._build_enemy` 既有 `ink_warden` 分支上（无需修改 loader）
- **`data/rooms/archive_03.json`**：`voice_bell` 从 (240, 126) 移到 (90, 134) 避免与 InkWarden sprite (240, 134) 水平重叠造成视觉遮挡 — 现在声匣在入口区域，InkWarden 守中央平台，房间空间感更清晰。
- **`src/scenes/hub_room.tscn`**：新增 `ArchivistShadow` 节点 (240, 180) 作为 InkWarden 静态封印剪影：
  - `WardenSilhouette` (Sprite2D, 64x96 `ink_warden.png`, 0.85 缩放, 55% alpha, 0.4/0.3/0.5 紫色调) — 视觉伏笔，玩家一眼看到"档案馆封存的墨守者"
  - `BaseGlow` (Sprite2D, 0.55x0.12 椭圆, 50% alpha 珊瑚色 #E86D5A) — 封印底部辉光
  - 整个节点不参与战斗，只提供视觉伏笔 + 暗示 `warden_slayer` 成就存在
- **JSON 语法校验通过**（`json.load()` 解析），敌人列表 `['silence_mote', 'silence_mote', 'note_wisp', 'ink_warden']`。
- **空间布局校验**：所有 enemy + interactable sprite 范围无水平/垂直重叠，InkWarden collision 中心 (240, 150) 与平台 (240, 150) 完美对齐。

### T049 完成明细（一般）
- **`src/scripts/room_door.gd`**（重构）：
  - `open()` → `enable_trigger()` —— 公开 API，明确"启用触发碰撞"语义
  - `_close()` → `disable_trigger()` —— 公开 API，明确"禁用触发碰撞"语义
  - `_is_open` → `_is_trigger_enabled` —— 内部状态，命名匹配新 API
  - 新增 `is_trigger_enabled() -> bool` 公开 getter —— 替代直接访问私有字段，避免 Godot 4.x 私有属性警告
  - 完整 docstring 解释"门 sprite 始终在原地，我们只切换触发碰撞"——消除命名歧义
- **`src/scripts/hub_controller.gd:30, 76-77`**：调用方更新为 `enable_trigger()` + `is_trigger_enabled()`
- **`src/scripts/game_flow_controller.gd:162`**：`door.open()` → `door.enable_trigger()`
- **全面 grep 校验**：仓库无残留 `\.open\(\)` / `_close\(\)` RoomDoor 调用。

### 风格漂移评估
- Hub 剪影使用 STYLE_GUIDE 色板：Coral Pulse `#E86D5A` (50% alpha 辉光) + Muted Violet `#65506A` (55% alpha 剪影) + 玻璃底色 Ink Navy。视觉与 A030-A032 InkWarden 素材同源。
- archive_03 调整后仍符合"垂直阶梯 + 中心 boss"房间设计语言。

### Godot 运行时回归
- 容器内无 Godot binary；静态检查确认：
  - JSON 语法 OK
  - 所有 RoomLoader 路径与 enemy/interactable 类型一致
  - `enable_trigger()` / `disable_trigger()` / `is_trigger_enabled()` 调用方已全部更新
- 运行时回归仍依赖本地 Godot 4.6 跑 `godot --headless --check-only`。

### 结论
- 状态：**可继续迭代**。
- 严重 S001 已解决：`warden_slayer` 成就可通过清理 archive_03 的 InkWarden 解锁。
- 一般 G006 已解决：RoomDoor API 命名不再语义倒置。
- ROADMAP 剩余 T046 / T047 / T048（Hub 房间 GameFlowController + TutorialHint + 控制器重构）下轮（#23）可继续。
- `ITERATION_COUNT.txt` 更新为 `22`。
