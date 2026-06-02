# Review Log

## 审查 #5 — 2026-06-02T15:00+08:00

### 通过项
- **代码结构**：12 个 GDScript 文件全部有 class_name 或明确注释，职责分离清晰（Player/Pulse/HUD/VFX/Enemy/Room 各负其责）。
- **构建配置**：project.godot 配置正确，480x270 内部分辨率 + integer 拉伸，canvas 纹理 filter 为 Nearest，符合像素规格。
- **核心循环可玩**：进入房间 → Pulse 击退/净化 SilenceMote → 修复 GlassLock → 收集 VoiceBell 碎片 → 房间完成，逻辑链路完整。
- **素材风格一致**：抽查 A019（占位 spritesheet）、A020（tileset proxy）、A021（房间背景），色板与 STYLE_GUIDE 的 Hex 值匹配，无漂移。
- **ASSET_REGISTRY 完整**：21 条记录，状态清晰，REJECTED 项（A002）有明确原因且未重复使用。
- **CHANGELOG ↔ ROADMAP 同步**：#1~#4 迭代记录完整，任务 ID 对应正确。

### 发现问题
- [严重] `RoomController._find_room_objects()` 使用 `get_node_or_null("GlassLock")` 等，但目标节点是兄弟节点而非子节点，导致 `_glass_lock` / `_voice_bell` / `_silence_mote` 始终为 null。房间完成检测（`_check_completion`）依赖这些引用，虽通过 `if _glass_lock else true` 兜底不会崩溃，但逻辑实际上被跳过，房间完成条件无法真正验证。→ **已修复**：改为 `get_parent().get_node_or_null(...)`。
- [一般] 缺少 `README.md`，新协作者无法快速了解项目结构和运行方式。→ **已创建**。
- [一般] `ROADMAP.md` 中 T011 状态为 `- [ ]`，但 `CHANGELOG.md` #4 已标记完成。→ **已同步修正**。
- [一般] `project.godot` 引用了 `res://icon.svg`，但仓库中无此文件，Godot 编辑器打开时可能报错。→ 追加到 ROADMAP 后续处理。
- [轻微] `GameState._respawn()` 仅重置数值，未通知 Player 实际移动，死亡后玩家停留在原地。→ **已修复**：通过 `SceneTree` 查找 player 组节点并调用 `respawn_at()`。
- [轻微] `SilenceMote._update_warning_visuals()` 使用 `sin(timer * 15) > 0` 判断闪烁，timer 接近 0 时频率不稳定。→ **已修复**：改用基于进度比例的离散闪烁（`int(flash_progress * 10) % 2`）。
- [轻微] `player.gd` 第 119 行使用 `flip_h` 处理左右朝向，注释已标记 TODO，但长期不处理会导致左臂声匣在左朝向时错位到右臂。→ 已知技术债务，依赖 T003 正式 spritesheet（A008/A009）。

### 风格漂移评估
- A019 占位 spritesheet：Ink Navy 主体 + Glass Cyan 高亮 + Amber 声匣核心，与 STYLE_GUIDE 色板一致。
- A020 tileset proxy：Deep Teal/Archive Blue 为主，玻璃碎片带 Cyan 边缘，比例正确。
- A021 房间背景：拱门、悬挂线缆、浅水反射、远处玻璃钟罩，氛围与 A003 概念图一致。
- **结论**：无风格漂移。

## 审查 #10 — 2026-06-02T17:00+08:00

### 通过项
- **代码结构**：22 个 GDScript 文件全部有 class_name 或明确注释，职责分离清晰（Player/Pulse/HUD/VFX/Enemy/Room/Audio/Particles/Atmosphere/Flow/Door/Transition 各负其责）。
- **构建配置**：project.godot 配置正确，480x270 内部分辨率 + integer 拉伸，canvas 纹理 filter 为 Nearest，符合像素规格；icon.svg 已存在。
- **核心循环可玩**：房间 1（archive_01）与房间 2（archive_02）均可完整游玩，进入 → Pulse 击退/净化敌人 → 修复 GlassLock → 收集 VoiceBell 碎片 → 房间完成 → 开启 RoomDoor → 切换房间，逻辑链路完整。
- **素材风格一致**：抽查 A022（silence mote）、A023/A024（voice bell 破损/修复）、A025（pulse icon）、A026/A027（Saya spritesheet）、A028（note wisp），色板与 STYLE_GUIDE 的 Hex 值匹配，无漂移。
- **ASSET_REGISTRY 完整**：28 条记录，状态清晰，REJECTED 项（A002）有明确原因且未重复使用；PLACEHOLDER 项（A019 已废弃、A027 临时翻转）有备注说明。
- **CHANGELOG ↔ ROADMAP 同步**：#1~#10 迭代记录完整，任务 ID 对应正确；T001-T022 全部完成。
- **房间切换与持久化**：GameState 跨房间保存/恢复生命值、共鸣能量、碎片数、已修复房间记录，RoomTransition 提供淡入淡出遮罩，体验连贯。
- **音效占位系统**：AudioManagerEnhanced 程序化生成 5 种占位音效（Pulse/脚步/玻璃碎裂/敌人低鸣/修复成功），无需外部音频文件即可运行。

### 发现问题
- [严重] `audio_manager_enhanced.gd` 中 5 个音效生成函数使用全局 `randf_range()`，在 Godot 4.x 中线程不安全，可能导致音频数据竞争或崩溃。→ **已修复**：全部改用局部 `RandomNumberGenerator` 实例。
- [严重] `note_wisp.gd` 使用 `NoteProjectile.new()` 直接实例化非纯代码类（含 `@onready var _sprite: Sprite2D = $Sprite2D`），运行时 `_sprite` 为 null，导致投射物无视觉反馈且可能崩溃。→ **已修复**：创建 `note_projectile.tscn` 场景文件，NoteWisp 优先通过 PackedScene 实例化，并增加零向量防护。
- [一般] `player.gd` 屏幕抖动使用全局 `randf_range()`，虽非音频线程但仍存在潜在问题。→ **已修复**：改用局部 `RandomNumberGenerator`。
- [一般] `game_flow_controller.gd` 的 `_reset_game()` 在场景重载前操作已失效的节点引用（_room_controller.reset_room()、_player.respawn_at()），这些操作在场景树即将被销毁时无意义且可能引发错误。→ **已修复**：移除重载前冗余节点操作，直接执行场景重载。
- [一般] `game_flow_controller.gd` 中 RoomDoor 的 `player_entered` 信号在场景切换时可能残留旧回调连接，导致跨房间触发错误。→ **已修复**：在 `_notification(NOTIFICATION_PREDELETE)` 中主动断开信号连接。
- [轻微] `environment_particles.gd` 中 `Time.get_time_dict_from_system()["second"]` 返回 `int`，与 `float` 类型的 `flash_speed`/`pulse_speed` 相乘时 Godot 4.x 可能发出类型警告。→ **已修复**：显式 `float()` 转换。
- [轻微] `note_projectile.gd` 使用 `area_entered` 信号检测 Pulse 命中，但 Pulse 使用 `intersect_shape` 物理查询而非 Area2D 重叠，导致投射物无法被 Pulse 正确销毁。→ **已修复**：移除 `area_entered` 信号，改为 `destroy_by_pulse()` 公共方法，由 `PulseAbility` 直接调用。
- [轻微] `ROADMAP.md` 所有任务已完成，进入「新增任务模式」。需根据当前竖切状态规划下一阶段任务（如：第三个房间、Boss 原型、能力升级系统、Steam 页面截图素材等）。

### 风格漂移评估
- A022 silence mote：Ink Navy 主体 + Muted Violet 腐蚀边缘 + Glass Cyan 高亮 + Amber 单眼，与 STYLE_GUIDE 一致。
- A023/A024 voice bell：破损状态暗淡紫内部 + 修复后 Amber Voice 暖光，色板正确。
- A026 Saya spritesheet：Ink Navy 头发 + Cyan 发束 + Amber 喉口/声匣核心 + 玻璃披肩，与 A007 最终设定一致。
- A028 note wisp：深墨蓝身体 + 琥珀单眼 + 玻璃青色波形尾迹，与 A022 敌人视觉语言统一。
- **结论**：无风格漂移。

### 结论
- 状态：**可继续迭代**
- 2 个严重问题、4 个一般问题、3 个轻微问题全部在本次审查中修复。建议下一轮进入「新增任务模式」，规划竖切扩展内容（新房间/新机制/营销素材）。
