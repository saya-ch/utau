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
