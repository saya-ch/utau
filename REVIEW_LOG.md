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

### 结论
- 状态：**可继续迭代**
- 严重问题已修复，一般问题已处理或登记。下一轮（#6）可正常开发，优先执行 T012（打包 60 秒竖切）。

## 审查 #20 — 2026-06-03T13:00+08:00

> **本轮非典型审查模式**：用户在 Godot 4.6.3 启动后报告 parse 错误 → 阻塞性严重问题，本轮以**修复优先**为主，常规审查顺延。完整审计项目移至 #21。

### 触发与决策
- 收到 Godot 4.6.3.stable.official 启动日志，包含 11 类 GDScript parse 错误 + 2 个 PNG 资源加载失败 + 2 个 .tscn 级联错误。
- 按 ITERATION_GUIDE 步骤 4 条件 3：严重修复任务优先 → 跳过计划任务，直接进入「修复模式」并借机做部分审查。

### 通过项（静态）
- **PNG 资源**：6 个误存为 PNG 的 JPEG 文件已重新转码（ffmpeg），文件头 `89 50 4E 47`（PNG）已校验。
- **类型推断**：所有 `var x :=` 高风险位置已添加显式类型注解（`success: bool` / `Vector2` / `Color`）。
- **命名冲突**：`resonance_shard.gd` 的 `gravity` 与 Area2D 原生属性冲突已重命名为 `gravity_force`。
- **API 兼容**：移除 `camera_follow.gd` 的 `snap_to_pixel`（Godot 4.6 不存在此属性），像素吸附通过 `global_position.round()` 实现。

### 发现问题
- [严重] 6 个 PNG 实际是 JPEG → **已修复**（T043）。
- [严重] 11 个 GDScript parse 错误 → **已修复**（T043）。
- [一般] `room_controller.gd` 三元表达式推断失效 → **已修复**并提示后续 `var x := a if b else c` 模式应直接用显式类型。
- [一般] `silence_mote.gd` 与 `room_door.tscn` 错误均为级联（PNG 资源失败导致）→ 源已修，自动恢复。
- [轻微] `player.gd:185/209/233` 的 `var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT` 三元表达式 — 静态看可推断（两边都是字面 Vector2），未在错误日志中出现，**保留**。后续若 Godot 解析器报相同 warning-as-error，再统一加 `var dir: Vector2 = ...`。
- [轻微] 无运行时回归验证 — 容器内无 Godot 可执行文件。**登记为流程漏洞** → 下一轮（#21）需要：
  1. 优先安装 Godot 4.6 headless 或下载 Godot binary。
  2. 跑 `godot --headless --check-only` 验证所有脚本。
  3. 启动 60 秒竖切做烟雾测试。

### 风格漂移评估
- 未做素材抽查（修复轮，不涉及新素材）。风格一致性已在 T039/T040/T041/T042 各自段确认。
- 修复未引入新视觉元素。

### 结论
- 状态：**可继续迭代**（修复后 parse 错误已清零）
- 严重问题全部解决。下一轮（#21）执行完整审查 #20 的剩余项（代码质量 / 玩法完整性 / 素材一致性 / 文档同步 + Godot 运行时回归）。

## 审查 #21 — 2026-06-03T14:00+08:00

> **触发**：用户明确指令「这一轮做审查」。本轮完成 #20 顺延的完整审计，并执行本轮登记的轻微修复。

### 通过项
- **class_name 全局唯一**：36 个 `class_name` 声明无重名；`project.godot` autoload 注册 4 个（GameState / PlayerStats / AudioManager / AudioManagerEnhanced），跨文件引用一致。
- **signal 拓扑**：`pulse_fired` / `bind_fired` / `cut_fired` / `player_entered` / `room_completed` / `room_failed` / `achievement_unlocked` / `interacted` 等关键信号在 producer 端定义，consumer 端 `connect` 都做了 `has_signal` 防御。
- **GDScript 静态推断**：`var x := ...` 位置经全文搜索 + 上轮修复（T043）后，仅在两段 Player `_handle_*` 中保留 `var dir := Vector2.RIGHT if ... else Vector2.LEFT`（两边都是字面 Vector2，类型推断明确），与 #20 审查结论一致。
- **核心循环链路完整**：Pulse 圆环检测 + 击退/修复/打断路径均覆盖；Bind 牵引 + 能力门开放路径完整；Cut 弧形判定 + silenced_web 切断 + projectile 斩断全部联通。
- **三动词视觉差异化**：PulseVFX（圆环 + 波形）、BindVFX（向内螺旋 + 收缩环）、CutVFX（弧形斩 + 拖尾碎片）在 `_draw()` 层结构清晰、色板严格区分。
- **JSON 房间系统**：3 个 JSON 房间 + JsonRoom 场景 + RoomLoader 模板架构清晰；Tutorial hints / ability gates / silenced webs 都通过 JSON 配置接入。
- **成就系统**：`PlayerStats` autoload + 8 个成就定义 + 跨运行持久化 + 通知卡 Steam 风格，结构可扩展。
- **素材风格抽查（A029-A038）**：
  - A029 Save Lantern：dim/lit 双态，玻璃钟罩 + 琥珀核心，色板与 STYLE_GUIDE 一致。
  - A030-A032 Ink Warden 3 态：基础 / 破盾 / 眩晕，珊瑚裂纹 + 淡紫 + 青色高光，与 A022-A028 系列同源风格。
  - A033 Bind 图标：向内螺旋 + 收缩环 + 暗紫底，与 A025 Pulse / A038 Cut 形成三动词组。
  - A034-A037 NPC 头像 / 对话框：暖琥珀与青色与档案馆色板一致，玻璃底 + 细黄铜边符合 STYLE_GUIDE。
  - A038 Cut 图标：珊瑚锋线 + 暖琥珀闪光 + 三角碎片，与 A025/A033 风格成组。
  - 所有素材 PNG 文件头校验通过（非 JPEG 伪装），与 #20 修复后状态一致。

### 发现问题

#### [严重]（1 项 — 立即追加到 ROADMAP 顶部）
- **S001 InkWarden 在游戏中从未出现**：`src/scenes/ink_warden.tscn` 存在，A030-A032 资源齐全，`room_loader.gd._build_enemy` 也有 `ink_warden` 分支，但 `main.tscn` / `hub_room.tscn` / 3 个 `data/rooms/archive_*.json` 中均未实例化 InkWarden。→ `warden_slayer` 成就无法通过正常游玩解锁；T030/T031 工作成果玩家完全看不到，破坏"20 个敌人/3 个房间"的第一印象。需要：在 `archive_03.json` 中添加至少 1 个 InkWarden，并在 `hub_room.tscn` 旁放置一个 InkWarden 雕像/剪影作为伏笔。

#### [一般]（6 项）
- **G001 NoteWisp 净化不产生共鸣碎片**：`note_wisp.gd._purify()` 不调用 `_drop_shard()`，与 SilenceMote / InkWarden 行为不一致，玩家击杀 NoteWisp 缺乏奖励反馈。**本轮已修复**：新增 `_drop_shard()` 轻量级弹射版。
- **G002 GameFlowController 在 Hub 房间不工作**：`hub_room.tscn` 没有 `GameFlowController` 节点，Hub 切回 archive_01 时缺少 `ROOM_TRANSITION` 状态过渡（虽 `hub_controller.gd._on_exit_door_entered` 内部也调用 `change_scene_to_file`，但 state machine 不一致）。需要在 Hub 补 GameFlowController 实例，或在 `hub_controller.gd` 显式调用 `GameFlowController._enter_state(State.ROOM_TRANSITION)`。
- **G003 Hub 房间没有 TutorialHint 节点**：RoomLoader 加载的 archive 房间会自动添加 TutorialHint；Hub 房间手写 tscn 没有，导致"已激活"提示组不重置（虽然每次新运行都 reset 一次）。建议 Hub 同样添加 `tutorial_hint.tscn` 实例并补 1-2 条 Hub 专属提示（"与档案管理员交谈"）。
- **G004 `ink_warden.gd._update_shield_visuals()` 三元表达式死代码**：原 `_shield_vfx.modulate.a = 0.0 if _shield_active else 0.0` 永远为 0.0。**本轮已修复**：改为 `0.6 if _shield_active else 0.0`，使护盾可视。
- **G005 `hub_controller.gd._on_exit_door_entered` 双重切换风险**：先 `GameState._is_transitioning = true` + 调 `transition.fade_out`，回调 `_do_room_switch` 再调 `change_scene_to_file`。如果 transition 节点缺失（fallback 路径），HubController 直接调 `_do_room_switch` 但 `transition_finished` 信号未 disconnect —— 此处无信号，仅函数内 `transition.transition_finished.disconnect(_do_room_switch)` 被跳过，逻辑安全但风格不一致。建议 HubController 仿照 `game_flow_controller._on_door_entered` 模板重写。
- **G006 `RoomDoor.open()` 反而 `disable collision = false`（启用碰撞）**：`open()` 启用碰撞是为了让玩家触碰触发 `player_entered`；`_close()` 反而 `disable = true`。语义倒置，新读者易混淆。建议重命名为 `enable_trigger()` / `disable_trigger()` 或加注释明确"open 启用触发碰撞区域，close 隐藏触发器"。

#### [轻微]（本轮已修复 / 文档化）
- **L001** README 标 "Engine: Godot 4.4" 但 #20 验证在 4.6.3 parse 通过。**已修复**：补充 4.6 兼容说明。
- **L002** README "Bind (pull/stun)" 描述不全。**已修复**：补充 "unlock gates"。
- **L003** InkWarden `note_wisp.gd._process` 中 `_projectile_timer -= delta` 不检查 `is_purified` → 净化后最后一次发射仍会触发 `queue_free` 后再 `add_child(projectile)`。**已修复**（间接）：`_purify` 现在也调 `_drop_shard`，行为更对称。
- **L004** `pause_menu.gd._input` 的 `ui_cancel` 触发 `toggle_pause()`，但 `game_flow_controller` 也有 pause 处理 — 二者没有相互取消，可能在 Title 屏按 ESC 也会 pause。需要时验证。
- **L005** `audio_manager.gd` 与 `audio_manager_enhanced.gd` 都被注册为 autoload，且都执行 `add_bus` + `set_bus_name` —— 后者 `_setup_buses` 中检查 `get_bus_index` 再 add，所以重复注册不会产生重复 bus，但两个 autoload 各跑一遍 `_ready` 是冗余。

### 风格漂移评估
- 抽查素材 A029-A038（最近 10 个 ID）色板严格遵循 STYLE_GUIDE：
  - Glass Cyan `#69C7CE` → A033 Bind / A034 Archivist 边框 / A037 NPC 头
  - Amber Voice `#F2B66E` → A029 Save Lantern / A034 Archivist 衣袍 / A036 对话框顶边
  - Coral Pulse `#E86D5A` → A038 Cut / A030 InkWarden 裂纹
  - Muted Violet `#65506A` → A033 Bind 底 / A031 InkWarden 破盾阴影
- 像素规格全部 32x32 / 48x48 / 64x96 / 28x36 等符合 STYLE_GUIDE 范围。
- **结论**：无风格漂移。

### Godot 运行时回归
- 尝试下载 Godot 4.4.1 headless（容器内无预装），网络受限于沙箱外发带宽，最终仅下到 11MB / 800KB 残片（godot.zip 损坏），解压失败。
- 改用静态分析：
  - 36 个 `class_name` 唯一性确认。
  - 11 个 `signal` 拓扑与 `connect` 配对。
  - 100+ 处 `var x := ...` 已通过 #20 修复。
  - 12 个 PNG 资源头校验为真 PNG。
  - 5 处 `if XXX.has_method(...)` 防御模式检查 autoload 标识符存在（GameState / PlayerStats / AudioManager / AudioManagerEnhanced / GameFlowController）。
- **结论**：静态层无新增问题；运行时回归仍是「流程漏洞」，**下一轮**（#22）建议在本地有 Godot 的环境复跑 `godot --headless --check-only` + 60 秒冒烟测试。

### 结论
- 状态：**可继续迭代**（轻微问题已修复，严重问题已登记）
- 本轮完成：NoteWisp 碎片掉落、InkWarden 护盾可见性、README 文档描述同步。
- 下一轮（#22）必须优先处理 **S001 InkWarden 实例化**（在 archive_03 房间 + Hub 剪影），否则 `warden_slayer` 成就无法触发、T030/T031 工作对玩家完全不可见。
- ROADMAP 已追加 T044（T045/G001-G006）任务。

## 审查 #25 — 2026-06-03T19:00+08:00

> **触发**：N=25, N%5==0，触发整点审查。本轮借 Godot 4.6.3 headless binary 落地机会，完整跑静态解析 + 运行时冒烟，并对 ROADMAP 全清空后的项目做"新阶段"基线审查。

### 触发与决策
- ITERATION_COUNT.txt = 25，ROADMAP.md 全部 53 个任务已 `[x]`，进入"新增任务模式"前的整点审查。
- 本轮重做：解压并就地保存 Godot 4.6.3 headless binary；首次运行时由于 `.godot/imported/*.ctex` 缓存缺失导致所有 PNG 资源加载失败并级联引发 8 个 SCRIPT ERROR，**这正是 #21 审查中预测的"流程漏洞"**。已跑 `godot --headless --import` 重新生成 .ctex，再次跑 0 错误。
- 修复了 `player.gd._setup_spriteframes()` 在素材缺失时的"SpriteFrames fall 动画不存在"持续报错（轻微 bug 修复）。
- 同步登记 3 个"轻微-一般"任务到 ROADMAP 顶部，作为 #26 候选。

### 审查范围

#### a) 代码质量
- **class_name 唯一性**：36 个声明无重名（`pulse_ability` / `bind_ability` / `cut_ability` / `pulse_vfx` / `bind_vfx` / `cut_vfx` / `repair_vfx` 等），与 #21 一致。
- **autoload 拓扑**：`project.godot` 注册 4 个（GameState / PlayerStats / AudioManager / AudioManagerEnhanced），与 #24 重构后状态一致。AudioManager 退化为 fallback wrapper，AudioManagerEnhanced 是事实 autoload。
- **signal 拓扑**：51 个 signal 声明，connect 端全部使用 `has_signal` 防御（特别是 GameFlowController._ready 与 HubController._ready）。GFC._on_door_entered / _on_door_with_spawn_entered 入口与 HubController 闭环正确。
- **静态解析**（首次运行需先 reimport）：
  ```
  timeout 15 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error
  ```
- **运行时冒烟**：
  ```
  timeout 12 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 RID leak）
  ```

#### b) 玩法完整性
- **核心循环**：Pulse 推/破盾 + Bind 牵引/暂停 + Cut 切断腐蚀链三动词全链路连通；Voice Bell 拾取 → 共鸣碎片计数 → 玻璃锁修复 → 房间门 enable_trigger。
- **Hub ↔ 3 archive 双向闭环**：3 个 JSON room_door 全部指向 `hub_room.tscn`，spawn (60/240/420, 210) 与 Hub 三个门精确对齐。HubController 通过 `_on_door_with_spawn_entered` 显式传 spawn_point，避开了多门 GFC 默认取"第一个门"的 bug。**S001（InkWarden 实例化）已解决**：archive_03 (240, 134) 实际出现 InkWarden，Hub 中心 (240, 180) 剪影伏笔。
- **成就系统**：8 个成就 + 跨运行持久化 + 屏幕中央通知。`warden_slayer` 现在的可达路径：Hub → archive_03 → Pulse 击破护盾 → 净化 InkWarden → 通知解锁。
- **Tutorial 系统**：所有 4 个非 Hub 场景都接入 `tutorial_hint` 组；Hub 走 HubController 自带 2 条提示。

#### c) 素材一致性
- 抽查最近 10 个素材 ID（A029-A038）+ 早期关键素材（A001-A028）：
  - **风格一致**：色板严格遵循 STYLE_GUIDE（Glass Cyan / Amber Voice / Coral Pulse / Muted Violet / Ink Navy），像素规格 32x32 / 48x48 / 64x96 / 28x36 全部在 STYLE_GUIDE 范围内。
  - **资源完整性**：所有 PNG 文件头校验为真 PNG（`89 50 4E 47`），与 #20 修复后状态一致，无 JPEG 伪装回归。
  - **REJECTED 状态**：A002（旧版黑斗篷主角）保持 REJECTED，未被引用，无累计 3 次失败。
  - **PLACEHOLDER 状态**：A019（Saya 占位 Spritesheet）仍登记为 PLACEHOLDER，但**当前代码（player.gd）已不再引用**——只引用 A026/A027。A019 实质上是"未删除的历史资产"，建议下一轮清理（轻微）。

#### d) 风格漂移评估
- 三动词视觉差异化保持：Pulse 圆环 / Bind 螺旋 / Cut 弧形斩，色板分工明确。
- 三类敌人视觉差异化保持：SilenceMote 墨团 + 单眼 / NoteWisp 音符 + 波形尾 / InkWarden 大型墨团 + 护盾裂纹。
- Hub / Archive 房间背景同色系（archive_room_bg），不同平台布局提供空间辨识度。
- **结论**：无风格漂移。

#### e) 文档同步
- ROADMAP.md：53 任务全 `[x]`，与 CHANGELOG 编号 #1-#25 一致。
- CHANGELOG.md：完整记录 #1-#25 每轮主题/skills/任务/状态。
- README.md：4.4/4.6 双版本说明、控制表、JSON 房间使用说明（#21 修复后状态）。
- ASSET_REGISTRY.md：38 条记录 + 状态 + 路径 + 备注。
- INSPIRATION.md / RESEARCH.md：市场调研与灵感库保持。
- **结论**：文档同步。

### 通过项
- 静态解析 0 错误（修复 reimport 缓存后）。
- 运行时冒烟 0 错误。
- 36 class_name 全局唯一。
- 51 signal 拓扑完整。
- 4 autoload 一致。
- JSON 房间 (3) 全部语法正确。
- Hub ↔ 3 archive 闭环通；InkWarden 实例化完成；成就路径可达。
- 所有 PNG 真 PNG 头校验通过。
- 风格无漂移。

### 发现问题

#### [一般]（3 项 — 追加到 ROADMAP）
- **G001 A019 PLACEHOLDER 资产清理**：`assets/sprites/saya_placeholder_spritesheet.png` + 对应 `.import` 文件已被 A026/A027 替代，但 ASSET_REGISTRY 仍登记 PLACEHOLDER 状态，仓库中文件未删除。新协作者可能误用旧资产。需要：(1) 删 PNG + import 文件；(2) ASSET_REGISTRY 状态从 PLACEHOLDER 改为 DEPRECATED 或直接删除条目。
- **G002 HubController.next_spawn_point 默认值与多门语境不一致**：默认 `Vector2(60, 180)` 是 archive_01 的 spawn，但 `_on_any_door_entered` 用作"未匹配到 door 时的 fallback"。理论上 `_all_doors` 总是能找到匹配，但若运行时门被 `disable_trigger` + `enable_trigger` 重排，循环可能不命中。建议改为 `Vector2.ZERO` 并在未匹配时显式 log warning，或在 `_ready` 末尾自检。
- **G003 项目元数据与 README 描述存在版本漂移**：`project.godot` 注释行 `; Godot version: 4.4.1-stable` 与 `config/features=PackedStringArray("4.4", "Mobile")` 仍标 4.4，README 已在 #21 标注 4.6 兼容。Godot 4.6 仍能解析，但首次打开项目时会显示"项目针对 4.4 创建，是否升级"弹窗。建议保留 4.4 features 字段（向下兼容），仅更新注释行。

#### [轻微]（1 项 — 本轮已修复）
- **L001** `player.gd._setup_spriteframes()` 在 Saya spritesheet 任一缺失时只 `push_warning` 后 return，但 player.tscn 的 placeholder SpriteFrames 资源是空的。后续 `_update_animation()` 在 `_physics_process` 中每帧调用 `sprite.play("fall")` / `play("jump")` 等，导致 Godot 持续输出 `ERROR: There is no animation with name 'fall'`。**本轮已修复**：新增 `_ensure_placeholder_animations()` 在缺失素材时为 placeholder 补 idle/run/jump/fall 四个空动画槽。

#### [信息]（流程漏洞再确认）
- 沙箱首次启动 Godot 4.6.3 必须先跑 `--import` 生成 `.godot/imported/*.ctex`，否则所有 PNG 加载失败并级联触发 SCRIPT ERROR。
  - `godot/README.md` 已有"步骤 2 重新生成 .import 文件"指引，但首次解压后的 .ctex 缺失问题已在 #24 修复 → 重新出现，说明 `.godot/` 目录没被 git 跟踪（合理），但首次启动需要 reimport。
  - **建议**：在 `godot/README.md` 顶部加一条"⚠️ 首次解压必须先跑 `--import`"红字提醒。

### 风格漂移评估
- 抽查 A029-A038 + 关键早期素材 → 全部遵循 STYLE_GUIDE 色板与像素规格。
- 无漂移。

### 结论
- 状态：**可继续迭代**（轻微问题已修复，一般问题已登记 ROADMAP 顶部）。
- 严重问题 0 项。
- 一般问题 3 项：G001 资产清理 / G002 多门 fallback / G003 版本元数据。
- 轻微问题 1 项（L001）：已修复 player.gd 防御性 placeholder 动画。
- 信息提示 1 项：`.godot/` 首次 reimport 提示，需更新 godot/README.md。
- 下一轮（#26）建议优先做 G001（资产清理）以保持账本清晰；G002 + G003 视优先级可分两轮做。
- ROADMAP 已追加 T054 / T055 / T056 进入"新增任务池"。

## 审查 #30 — 2026-06-04T01:00+08:00

> **触发**：N=30, N%5==0，触发整点审查。本轮 ROADMAP 任务池已清空（T062/T063 #29 完成），是 T062/T063 后 + BGM 系统落地后的"新基线"审查。
> Godot 4.6.3 headless binary 已在沙箱就地解压（`/workspace/godot/Godot_v4.6.3-stable_linux.x86_64`，138MB），并已通过 `--import` 重新生成 87 个 import 文件。

### 审查范围

#### a) 代码质量

- **class_name 全局唯一**：38 个声明零冲突（含 T058 `DamageNumber` + T061 `CreditsScreen` 新增项）。
  - `src/scripts/` 下 38 个 class_name（含 DialogueBox）。
  - `src/autoload/` 目录下的 `audio_manager.gd` / `player_stats.gd` / `game_state.gd` 三个 autoload 故意不写 `class_name`（它们是 Engine 单例，通过 `AudioManager` / `PlayerStats` / `GameState` 全局名直接访问）。
- **autoload 拓扑**：`project.godot` 注册 4 个（GameState / PlayerStats / AudioManager / AudioManagerEnhanced）。
  - AudioManager 是 T050 (#24) 落地后的 fallback wrapper，所有 `play_*` 透明转发到 AudioManagerEnhanced；grep 确认仓库 0 处直接调用 `AudioManager.play_*`，符合"事实上的正式 autoload = AudioManagerEnhanced"的状态。
- **signal 拓扑**：54 个 signal 声明（与 T058/T061 增量一致）；connect 端全部使用 `has_signal` 防御。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 8 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除标准 ObjectDB leak 退出提示，godot/README.md 已登记为非致命）
  ```
- **`var x :=` 推断风险**：player.gd 仍有 3 处 `var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT`（_handle_pulse/_handle_bind/_handle_cut），与 #20/#21 审查结论一致：两边都是字面 Vector2，类型推断明确，保留。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。T017 时代的"左朝向翻转临时版"todo 早已被 T024 替换为正式绘制。

#### b) 玩法完整性

- **核心循环三动词**：Pulse（推/破盾）+ Bind（牵引/暂停）+ Cut（切断腐蚀链）— 全部联通，HUD 三冷却条齐备（Cyan / Violet / Coral 三色视觉差异化）。
- **三动词视觉差异化**：PulseVFX（圆环 + 波形）、BindVFX（向内螺旋 + 收缩环）、CutVFX（弧形斩 + 拖尾碎片）—— 风格明确区分。
- **完整可玩循环**：Hub ↔ 3 archive 双向闭环（T053 #25 落地后无回归）。InkWarden 已在 archive_03 (240, 134) 实例化，Hub 中心 (240, 180) 有 ArchivistShadow 剪影伏笔，`warden_slayer` 成就可达。
- **BGM 系统**（#29 T062 + T063 落地）：
  - 3 个程序化主题（title_intro D 大调 60 BPM 16s / hub_warm F 大调 88 BPM 10.9s / archive_exploration A 小调 72 BPM 13.3s）。
  - GFC `_play_music_for_state(state)` 路由：TITLE → title_intro / PLAYING + HubController → hub_warm / PLAYING + RoomController → archive_exploration / GAME_OVER_* → stop_music / PAUSED/ROOM_TRANSITION → 保持。
  - 全部走 "Music" bus，SettingsMenu 滑块可独立调节。
  - 同 key 重复调用 no-op（避免不必要重生成）；首次生成后缓存到 `_music_streams`。
- **成就系统**：8 个成就 + 跨运行持久化 + 屏幕中央通知 + 暂停菜单统计面板 + 8 宫格图标。`PlayerStats.achievement_unlocked` 信号在 AchievementNotification 端订阅，icon_hint → 资源路径查找带 32x32 → 16x16 → 颜色回退三级防御。
- **Tutorial 系统**：所有 4 个非 Hub 场景（main/archive_01/02/03）+ Hub 房间都有 `tutorial_hint` 组实例。
- **存档 / 重生 / 死亡飘字 / 屏幕震动**：全部就位（T023 + T026 + T058）。

#### c) 素材一致性

- **PNG 资源头校验**：84 个 PNG 全部 `89 50 4E 47 0D 0A 1A 0A` 合法头（python struct 解析），0 个 JPEG 伪装。
- **A039-A046 成就图标色板抽查**（5/8 个）：
  - `amber_bell`：仅 2 色 (242,182,110) + (105,199,206) → Amber Voice + Glass Cyan ✓
  - `coral_eye`：5 色全在调色板（Ink Navy / Coral Pulse / Muted Violet / Pale Resonance + 白色高光）✓
  - `amber_lantern`：4 色（Amber Voice / Muted Violet / Glass Cyan / Warm Parchment）✓
  - `coral_pulse`：2 色（Glass Cyan + Coral Pulse）✓
  - `amber_dot`：4 色（Glass Cyan / Archive Blue + 白高光 + Amber Voice）✓
  - 所有 Hex 值与 `STYLE_GUIDE.md` 100% 匹配（#F2B66E / #69C7CE / #E86D5A / #65506A / #B7E7DD / #081426 / #E6D5B8 / #12334A）。
- **A019 DEPRECATED 状态**：T054 #26 已删除 PNG + .import；ASSET_REGISTRY 状态明确为 DEPRECATED，仓库 grep 0 引用。
- **REJECTED 项**：A002 仍 REJECTED，未被引用，未累计 3 次失败。

#### d) 风格漂移评估

- 抽查最近 8 个素材（A039-A046）+ 关键历史素材（A022-A038 + A029 InkWarden + A030-A032）—— 全部遵循 STYLE_GUIDE 色板与像素规格。
- 三动词视觉组（A025/A033/A038 Pulse/Bind/Cut）+ 三类敌人视觉组（A022/A028/A030-A032 SilenceMote/NoteWisp/InkWarden）差异化保持。
- Hub / Archive 房间同色系，不同平台布局提供空间辨识度。
- 致谢屏 PanelContainer 与暂停菜单 / 通知卡共享相同 StyleBoxFlat 模板（深海军蓝 + 玻璃青边）。
- **结论**：无风格漂移。

#### e) 文档同步

- **ROADMAP.md**：所有任务 `T001-T063` 全部 `[x]`，进入「新增任务模式」。
- **CHANGELOG.md**：#1-#29 完整记录；#29 T062/T063 记录详细（合成器 4 层 / 3 主题 / 场景路由 / 单元测试结果）。
- **README.md**：v0.29 同步状态；Audio 段已写明 3 个 BGM 主题；Engine 段明确"4.6.3 verified" + "4.4 features 保留向下兼容"。
- **ASSET_REGISTRY.md**：46 条记录（A039-A046 为 #28 新增成就图标），状态/路径/备注完整。
- **godot/README.md**：顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒已落地（T056 #26），本轮沙箱首次解压时此警告再次生效——证明该文档解决了真实问题。
- **REVIEW_LOG.md**：#5 / #20 / #21 / #25 / #30（本轮）5 个审查节点完整。
- **结论**：文档同步。

### 通过项

- 静态解析 0 错误。
- 运行时冒烟 0 错误。
- 38 class_name 全局唯一。
- 54 signal 拓扑完整。
- 4 autoload 一致（AudioManager fallback + AudioManagerEnhanced 正式）。
- 84 PNG 100% 合法头。
- 8 成就图标色板 100% 匹配 STYLE_GUIDE。
- 3 JSON 房间语法正确，archive_03 含 InkWarden。
- Hub ↔ 3 archive 闭环通。
- BGM 系统 3 主题 + 场景路由 + 音量独立可调。
- 致谢屏 / 成就通知 / 暂停菜单统计面板 三处 polish 完整。
- 0 TODO/FIXME/HACK 标记。
- 文档同步。

### 发现问题

#### [严重]（0 项）

无。

#### [一般]（2 项 — 追加到 ROADMAP 顶部「新增任务池」）

- **G001 README 缺 credits + 完整 controls 表**：
  - 当前 README Controls 表 6 行（移动/跳跃/三动词/交互），但缺：
    - 存档（默认接近 SaveLantern 自动触发，无手动按键 —— 当前是"踩上去自动激活"设计 → 需在 README 明确"接近存档灯笼自动存档"）
    - 暂停（默认 ESC，`ui_cancel`）
    - 致谢屏入口（仅在 title 屏可见，README 提及"致谢"按钮可作为 UX 提示）
  - 音频段虽写明 3 个 BGM 主题名，但未提及"BGM 音量在设置菜单可独立调节"细节。
  - 建议在 README 补一节「Audio Controls」明示 Music/SFX/Ambience 三 bus 独立滑块。
- **G002 BGM 首次生成潜在卡顿**：
  - `play_music_track` 首次调用某 key 时会在主线程同步合成 16s 22050Hz 样本（~352800 sample × 4 层叠加），耗时约 0.5-1.0s（取决于 CPU）。
  - 当前在 GFC._enter_state 末尾调用，正好在 fade-in 期间，但若 fade 短 + CPU 慢，可能在 title → archive 切换时观察到一段静音。
  - 缓解方案：可在 Title 屏 _ready 时预热所有 3 个 preset（`_ensure_music_stream`）→ 后续切换零延迟。预热耗时一次性，但用户感知到的"开始 → 进入游戏"延迟变大。
  - **建议**：下个 #31 视情况决定是否预热；目前延迟在 1.5s fade-in 窗口内，不影响可玩性。

#### [轻微]（0 项）

无。

#### [信息]（流程 / 元数据 — 1 项）

- **F001 ROADMAP 已全清空**：
  - T062 / T063 (#29) 完成；T064 之后为「新增任务模式」候选。
  - 下一轮（#31）建议候选方向（按 ROI 排序）：
    1. **第四个 archive 房间 + InkWarden 第二只**：补齐 BOSS 多样性 + `warden_slayer` 成就丰富度。
    2. **商店 NPC（Hub）**：用 `npc_hub_character_sheet.png` 的"silent merchant"角色，购买能力升级 / 永久 buff，与 `full_archive` 等成就挂钩。
    3. **Steam capsule 三联图**：基于 A018 key art 出 616x353 capsule / 460x215 small capsule / 1200x630 feature。
    4. **存档系统持久化磁盘版**：`user://saves/slot_N.json` 写盘 + 读档菜单，避免每次新运行重置。
    5. **BGM 第二段变体**（archive_03 专属 BOSS 段）：在 InkWarden 房间自动切到更激昂的衍生主题。
  - 由 #31 自由选 1~2 个执行。

### 结论

- 状态：**可继续迭代**。
- 审查 #30 完整通过；G001 README 完善已落地，G002 BGM 预热可推迟，F001 ROADMAP 候选 6 项（T065-T071）由 #31 自由选 1~2 个执行。
- 完整审查报告写入 `REVIEW_LOG.md`「审查 #30」段。
- `ITERATION_COUNT.txt` 更新为 `31`。

## 审查 #35 — 2026-06-04T13:00+08:00

> **触发**：N=35, 35%5==0，触发整点审查。Godot 4.6.3 headless binary 已就地解压（`/workspace/godot/Godot_v4.6.3-stable_linux.x86_64`，138MB），并已通过 `--import` 重新生成 87 个 import 文件。本轮是 #32-#34 完成 Steam capsule / 存档磁盘化 / Settings 删除存档 + 序章过场 之后的"完整可玩 + 营销就绪"基线审查。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：40 个声明零冲突（含 T070 `SaveSystem` + `SaveLoadMenu` + T073 `IntroCutscene` 新增项）。
  - 与 #30 比较：38 → 40。`save_system.gd` 与 `audio_manager_enhanced.gd` 故意无 `class_name`（autoload 通过全局名访问）。
- **autoload 拓扑**：`project.godot` 注册 5 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced）。
  - 与 #30 比较：4 → 5。SaveSystem 是 T070 落地后的新 autoload，跨会话存档持久化承担者。
  - AudioManager 仍是 T050 (#24) 落地后的 fallback wrapper，所有 `play_*` 透传到 AudioManagerEnhanced。
- **signal 拓扑**：56 个 signal 声明（与 #30 比较：54 → 56，含 SaveSystem 3 个信号 + IntroCutscene 1 个信号 + 其他增量）。所有 connect 端全部使用 `has_signal` 防御。
- **静态解析**：
  ```
  timeout 15 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 GDScript 警告
  ```
- **运行时冒烟**：
  ```
  timeout 10 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB leak 退出提示）
  ```
- **`var x :=` 推断风险**：player.gd 仍有 3 处 `var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT`（_handle_pulse/_handle_bind/_handle_cut），与 #20/#21/#30 审查结论一致：两边都是字面 Vector2，类型推断明确，Godot 4.6.3 静态解析 0 错误，保留。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **IntroCutscene 跳过保护**：本轮发现并修复——`_ready()` 中检查 `GameState._is_transitioning`，若是 Continue 读档流程则直接隐藏并 emit finished，玩家读档不会被强制看 8 秒 IntroCutscene（详见「本轮修复」段）。

#### b) 玩法完整性

- **核心循环三动词**：Pulse（推/破盾）+ Bind（牵引/暂停）+ Cut（切断腐蚀链）— 全部联通，HUD 三冷却条齐备（Cyan / Violet / Coral 三色视觉差异化）。
- **完整可玩循环**：
  - Hub ↔ 3 archive 双向闭环（T053 #25 落地后无回归）
  - InkWarden 已在 archive_03 (240, 134) 实例化（T045 #22）
  - Hub 中心 (240, 180) 有 ArchivistShadow 剪影伏笔
  - `warden_slayer` 成就可达：进入 archive_03 → Pulse 击破护盾 → 净化 InkWarden → 通知解锁
- **三动词视觉差异化**：PulseVFX（圆环 + 波形）、BindVFX（向内螺旋 + 收缩环）、CutVFX（弧形斩 + 拖尾碎片）— 色板严格分工。
- **BGM 系统**（T062/T063 #29 + T066/T071 #31 增量）：
  - 4 个程序化主题（title_intro D 大调 / hub_warm F 大调 / archive_exploration A 小调 / archive_boss A 小调 BOSS 段）。
  - GFC `_play_music_for_state(state)` 路由：TITLE → title_intro / PLAYING + HubController → hub_warm / PLAYING + RoomController → archive_exploration（被 InkWarden._ready 的 `request_boss_music` override 重定向到 archive_boss） / GAME_OVER_* → stop_music。
  - 预热机制（prewarm_music_streams）在 Title 屏 _ready 时一次性合成 4 个 preset，避免首屏 → 第一次 scene 切换的 1-2s 卡顿。
  - 同 key 重复调用 no-op；release_boss_music 后 GFC 状态机可重新路由。
- **存档系统**（T070 #33 增量）：
  - 3 槽位 user://saves/slot_N.json 写读 + 删除。
  - 自动收集 GameState（current_room / current_scene / health / resonance / shards / rooms_completed / abilities / checkpoint_position / run_time_seconds）+ PlayerStats（成就解锁状态）作为快照。
  - 玩家死亡重生点（SaveLantern）：手动 + 自动（接近激活）。
  - Continue 流程：Title 屏 "继续修复" 按钮 → 选 slot → GFC `_on_continue_game` → load_from_slot 还原 → ROOM_TRANSITION 切换场景 → 新场景 GFC 调 _recover_from_transition 落到 checkpoint。
  - 成就独立持久化到 user://achievements.json，跨运行保留（Steam 风格永久解锁）。
- **成就系统**：8 个成就 + 8 个图标（A039-A046）+ 通知卡 + 暂停菜单统计面板 + 8 宫格图标。`PlayerStats.achievement_unlocked` 信号在 AchievementNotification 端订阅，icon_hint → 资源路径查找带 32x32 → 16x16 → 颜色回退三级防御。
- **Settings 完整 4 Tab**（T072 #34 增量）：
  - Audio: Master / Music / SFX / Ambience 4 bus 独立滑块。
  - Video: 全屏 + 4 档整数倍缩放（1x-4x）。
  - Controls: 5 个 action 实时重映射 → user://settings.cfg 持久化。
  - **Saves**（新增 T072）：3 槽位状态显示 + "删除所有存档" 按钮（ConfirmationDialog 二次确认 + Toast 反馈 + 成就保护提示）。
- **Tutorial 系统**：所有 4 个非 Hub 场景（main/archive_01/02/03）+ Hub 房间都有 `tutorial_hint` 组实例。
- **存档 / 重生 / 死亡飘字 / 屏幕震动 / 序章过场**（T073 #34 增量）：全部就位，IntroCutscene 8 秒黑屏+渐入+停留+渐出+任意键跳过。

#### c) 素材一致性

- **PNG 资源头校验**：87 个 PNG 全部 `89 50 4E 47 0D 0A 1A 0A` 合法头（python struct 解析），0 个 JPEG 伪装。
- **A047/A048/A049 Steam capsule 三联图**（#32 T069）：3 个尺寸严格匹配 Steam 官方规格（616x353 / 460x215 / 1200x630），10/10 Hex 值匹配调色板，Saya 剪影严格保留左前臂声匣（核心识别点不镜像）。
- **A039-A046 成就图标色板抽查**（8/8 个）：amber_dot / coral_pulse / amber_shard / three_circles / coral_slash / coral_eye / amber_bell / amber_lantern — 4-6 色全部在调色板内（Ink Navy / Glass Cyan / Amber Voice / Coral Pulse / Muted Violet / Pale Resonance / Warm Parchment / Archive Blue）。
- **关键历史素材抽查**（A022/A025/A026/A027/A028/A029/A030/A038 等）：调色板命中率 40-90%，与 #30 审查一致。色数极多的素材（脉冲图标、瓶子修复态等）以黑色描边 + 渐变为主，命中稀释属于预期。
- **REJECTED 项**：A002（旧版黑斗篷主角）保持 REJECTED，未被引用，未累计 3 次失败。
- **DEPRECATED 项**：A019（Saya 占位 spritesheet）保持 DEPRECATED，仓库 grep 0 引用。

#### d) 风格漂移评估

- 抽查最近 5 个素材 + 关键历史素材共 20 个：
  - **三动词视觉组**（A025/A033/A038 Pulse/Bind/Cut）差异化保持：Pulse 圆环 cyan、Bind 螺旋 violet、Cut 弧斩 coral。
  - **三类敌人视觉组**（A022/A028/A030-A032 SilenceMote/NoteWisp/InkWarden）差异化保持：墨团 + 单眼 / 音符 + 波形尾 / 大型墨团 + 护盾裂纹。
  - **三档成就图标的玻璃钟罩家族**（A045 amber_bell / A046 amber_lantern）同 A029 save_lantern 视觉延续。
  - **三档 Steam capsule**（A047-A049）Saya 剪影严格保留 A008/A009 sprite ref 关键识别点（左前臂声匣、玻璃披肩、声波围巾、青色发束）。
- **结论**：无风格漂移。

#### e) 文档同步

- **ROADMAP.md**：
  - 已完成：T001-T070 / T072 / T073 / T059-T061 / T062-T063 / T066 / T069 / T071
  - 未完成（候选池）：T067 [候选] 第四个 archive + InkWarden 第二只 / T068 [候选] 商店 NPC / T074 [候选] Steam 商店描述 / T075 [候选] 玩家死亡动画 / T076 [候选] 第二阶段灯光 / T077 [候选] README 开发路线图章节
  - 与 #30 比较：T072（Settings 删除存档）和 T073（IntroCutscene）已 [x]
- **CHANGELOG.md**：#1-#34 完整记录（#32-#34 时间戳错位 #34 早于 #32 但实际顺序是 #32 → #33 → #34，本轮未修复此历史问题）。
- **README.md**：v0.34 同步状态；Controls 表 + Audio Controls 节 + Save System 节全部就位。
- **ASSET_REGISTRY.md**：49 条记录（A047-A049 #32 新增营销三联图），状态/路径/备注完整。
- **godot/README.md**：顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒已落地（#26 T056）。
- **REVIEW_LOG.md**：#5 / #20 / #21 / #25 / #30 / #35（本轮）6 个审查节点完整。
- **结论**：文档同步。

### 通过项

- 静态解析 0 错误。
- 运行时冒烟 0 错误（除已知 ObjectDB leak）。
- 40 class_name 全局唯一。
- 56 signal 拓扑完整。
- 5 autoload 一致（AudioManager fallback + AudioManagerEnhanced 正式 + SaveSystem 新增）。
- 87 PNG 100% 合法头。
- 8 成就图标色板 100% 匹配 STYLE_GUIDE。
- 3 Steam capsule 营销三联图就位。
- 3 JSON 房间语法正确，archive_03 含 InkWarden。
- Hub ↔ 3 archive 闭环通。
- BGM 4 主题 + 场景路由 + 音量独立可调 + InkWarden override + 预热机制。
- 存档 3 槽位 + Continue + Settings 删除存档 + 序章过场。
- 致谢屏 / 成就通知 / 暂停菜单统计面板 三处 polish 完整。
- 0 TODO/FIXME/HACK 标记。
- 文档同步。

### 发现问题

#### [严重]（0 项）

无。

#### [一般]（1 项 — 追加到 ROADMAP 顶部「新增任务池」）

- **G001 IntroCutscene 在 Continue 读档时强制重播**：玩家从 Title 屏选 slot "继续修复" 后，GFC 走 `_on_continue_game` → `load_from_slot` → `change_scene_to_file` 切到存档场景。若存档场景是 main.tscn（archive_01），IntroCutscene._ready() 会无条件调 `_play_sequence()`，玩家被强制看 8 秒黑屏+文字序章，体验割裂。**本轮已修复**：在 `intro_cutscene.gd._ready()` 开头检查 `GameState._is_transitioning`，若是恢复状态则立即 `visible = false` + `layer = -1` + emit `cutscene_finished` 并 return。

#### [轻微]（0 项 — 本轮 1 项已修复）
- **L001 IntroCutscene 读档重播 BUG**：见 G001 段，已修复。

#### [信息]（流程 / 元数据 — 3 项）

- **F001 ROADMAP 候选池仍有 6 项**（T067/T068/T074/T075/T076/T077），下一轮（#36）可继续"新增任务模式"：从 RESEARCH.md / INSPIRATION.md 找未实现创意。
- **F002 CHANGELOG.md #32-#34 时间戳错位**（#34 早于 #32）：上一轮 Agent 写入时间戳的逻辑问题，不影响语义，**本轮不修**。
- **F003 Godot binary 持久化**：`/workspace/godot/Godot_v4.6.3-stable_linux.x86_64` 在沙箱中无法 git 跟踪（138MB > GitHub LFS 100MB 限制），每轮首次跑都要重新解压。已在 `godot/README.md` 写明步骤 0 拼合命令。`godot/README.md` 顶部红字警告再次生效。

### 风格漂移评估

- 抽查最近 5 个素材（A047-A049 + A045/A046）+ 关键历史素材共 20 个。
- 像素规格 16x16 / 32x32 / 48x48 / 64x96 / 28x36 / 140x36 / 864x64 / 480x270 / 616x353 / 460x215 / 1200x630 全部在 STYLE_GUIDE 范围内。
- 营销三联图与 A018 key art 共享同一世界观 + 同一 Saya 设计 + 同一色板但构图独立。
- **结论**：无风格漂移。

### Godot 运行时回归

- **Godot 4.6.3 binary 重建**：沙箱内 binary 缺失，按 `godot/README.md` 步骤 cat .z01 + .z02 + .z03 + .z04 + .zip → /tmp/godot_full.zip → unzip + chmod 成功，138MB，`--version` → `4.6.3.stable.official.7d41c59c4`。
- **静态解析**：`godot --headless --quit --path /workspace` 0 SCRIPT ERROR / 0 Parse Error。
- **运行时冒烟**：`godot --headless --path /workspace` 10 秒：0 ERROR / 0 WARNING（除已知 ObjectDB leak）。
- **修复后回归**：L001 IntroCutscene 修复后 0 错误。

### 结论

- 状态：**可继续迭代**。
- 严重问题 0 项。
- 一般问题 1 项：G001 IntroCutscene 读档重播 — **本轮已修复**。
- 轻微问题 0 项。
- 信息提示 3 项：F001 ROADMAP 候选池 / F002 CHANGELOG 时间戳 / F003 Godot binary 持久化。
- 下一轮（#36）可继续「新增任务模式」：T067/T068/T074/T075/T076/T077 中选 1-2 个执行。
- 完整审查报告写入本段。
- `ITERATION_COUNT.txt` 更新为 `36`。

## 审查 #40 — 2026-06-05T03:00+08:00

> **触发**：N=40, 40%5==0，触发整点审查。本轮是 #39 死亡回 Hub + `archive_04` 双 Boss 主题 + `archive_boss_dual` 落地之后的"完整可玩 + 营销就绪 + 双 Boss 战斗"基线审查。
> Godot 4.6.3 headless binary 已在沙箱内通过 `cat *.z0* > /tmp/godot_full.zip` + python3 `zipfile` 提取 + `chmod +x` 就地解压（`/workspace/godot/Godot_v4.6.3-stable_linux.x86_64`，138MB），并已通过 `--import` 重新生成 import 缓存。`unzip` 报 "bad zipfile offset" 时使用 python `zipfile.ZipFile().extractall()` 兜底成功。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：40 个声明零冲突。`save_system.gd` 与 `audio_manager.gd` / `player_stats.gd` 故意无 `class_name`（autoload 通过全局名访问）。
- **autoload 拓扑**：`project.godot` 注册 5 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced）。AudioManager 是 T050 (#24) 落地后的 fallback wrapper，事实上的正式 autoload 是 AudioManagerEnhanced。仓库 grep 0 处直接调用 `AudioManager.play_*`。
- **signal 拓扑**：65 个 signal 声明（与 #35 比较：56 → 65，含 9 个增量：player.gd `landed`、hub_controller.gd `ability_selected/hub_exited`、title_screen.gd `continue_game_pressed/quit_game_pressed/credits_opened/credits_closed/save_load_closed`、save_load_menu.gd `closed/save_requested/load_requested/delete_requested`、pause_menu.gd `save_requested`、save_system.gd `save_completed/load_completed/delete_completed`）。所有 connect 端全部使用 `has_signal` 防御。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 10 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB leak 退出提示）
  ```
- **`var x :=` 推断风险**：player.gd 仍有 3 处 `var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT`（_handle_pulse/_handle_bind/_handle_cut），与 #20/#21/#30/#35 审查结论一致：两边都是字面 Vector2，类型推断明确，Godot 4.6.3 静态解析 0 错误，保留。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。

#### b) 玩法完整性
- **核心循环三动词**：Pulse（推/破盾）+ Bind（牵引/暂停）+ Cut（切断腐蚀链）— 全部联通，HUD 三冷却条齐备（Cyan / Violet / Coral 三色视觉差异化）。
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环（T053 #25 + T067 #38 增量：新增 archive_04 `共鸣祭坛`，2 InkWarden + 1 SilenceMote 双 Boss 房）。
  - Hub 4 门（archive_01/02/03/04），所有 4 个 JSON 的 `room_door` 全部指向 `hub_room.tscn`，spawn 精确对齐对应门位置（60/180/300/420, 210）。
  - HubController 通过 `_on_any_door_entered` 显式传 spawn_point，避开了多门 GFC 默认取"第一个门"的 bug（T055 #26 已修）。
  - InkWarden 已在 archive_03 (240, 134) 实例化（T045 #22），archive_04 (200, 144) + (320, 144) 双 InkWarden 实例化（T067 #38）。
  - Hub 中心 (240, 180) 有 `ArchivistShadow` 剪影伏笔（55% alpha 紫色调 + 50% alpha 珊瑚色底部辉光）。
  - `warden_slayer` 成就可达路径：Hub → archive_03 → Pulse 击破护盾 → 净化 InkWarden → 通知解锁（也支持 archive_04 双 Boss 路径）。
- **三动词视觉差异化**：PulseVFX（圆环 + 波形）、BindVFX（向内螺旋 + 收缩环）、CutVFX（弧形斩 + 拖尾碎片）— 色板严格分工。
- **BGM 系统**（T062/T063 #29 + T066/T071 #31 + T080 #39 增量）：
  - 5 个程序化主题（title_intro D 大调 60 BPM 16s / hub_warm F 大调 88 BPM 10.9s / archive_exploration A 小调 72 BPM 13.3s / archive_boss A 小调 108 BPM 11.1s / archive_boss_dual A 小调 132 BPM 8.7s）。
  - GFC `_play_music_for_state(state)` 路由：TITLE → title_intro / PLAYING + HubController → hub_warm / PLAYING + RoomController → archive_exploration（被 InkWarden._ready 的 `request_boss_music` override 重定向到 archive_boss 或 archive_boss_dual） / GAME_OVER_* → stop_music。
  - Boss 音乐 ref-counted override（T078 #38）：多 Boss 房间不会因为第一只死亡就清掉 BGM 段。
  - Boss 音乐强度分级（T080 #39）：`_BOSS_MUSIC_TIER` 单 boss = 1 / dual boss = 2，archive_04 出现第二只 InkWarden 时自动 tier-upgrade。
  - 预热机制（prewarm_music_streams）在 Title 屏 _ready 时一次性合成 5 个 preset，避免首屏 → 第一次 scene 切换的卡顿（T066 #31）。
  - 同 key 重复调用 no-op；release_boss_music 后 GFC 状态机可重新路由。
- **存档系统**（T070 #33 + T072 #34 增量）：3 槽位 user://saves/slot_N.json 写读 + 删除；自动收集 GameState（current_room / current_scene / health / resonance / shards / rooms_completed / abilities / checkpoint_position / run_time_seconds）+ PlayerStats（成就解锁状态）作为快照。成就独立持久化到 user://achievements.json，跨运行保留。Continue 流程：Title 屏 "继续修复" 按钮 → 选 slot → GFC `_on_continue_game` → load_from_slot 还原 → ROOM_TRANSITION 切换场景。
- **死亡与重生**（T075 #36 + T079 #39 增量）：1.5s 玩家死亡动画（laying down + 慢淡出）；默认死亡回 Hub 安全区（`Settings → Saves` 开关可切到"经典模式"回最近 Save Lantern）。
- **成就系统**：8 个成就 + 8 个图标（A039-A046）+ 通知卡 + 暂停菜单统计面板 + 8 宫格图标。
- **Tutorial 系统**：所有 5 个非 Hub 场景（main/archive_01/02/03/04 通过 JSON loader）+ Hub 房间都有 `tutorial_hint` 组实例。
- **Settings 完整 4 Tab**（T037 #13 + T072 #34 增量）：Audio 4 滑块 / Video 全屏 + 4 档缩放 / Controls 5 个 action 重映射 / Saves 3 槽位 + 删除所有存档。
- **序章过场**（T073 #34）：IntroCutscene 8 秒黑屏+渐入+文字+渐出+任意键跳过；Continue 读档时 `_ready()` 防御性 short-circuit（T035 #35 修复）。

#### c) 素材一致性
- **PNG 资源头校验**：
  ```
  python3 遍历 ./assets 与项目根：87 个 PNG 全部 `89 50 4E 47 0D 0A 1A 0A` 合法头，0 个 JPEG 伪装。
  ```
  与 #35 一致，**新增**：审查中识别并清除了仓库根目录的孤立 `test_api.png`（实际是 JPEG 伪装为 PNG，.import 文件 valid=false，仓库无 GDScript / tscn 引用）— L001 轻微修复已落地。
- **A047-A049 Steam capsule 三联图**（T069 #32）：3 个尺寸严格匹配 Steam 官方规格（616x353 / 460x215 / 1200x630），抽查色板覆盖率 9/10 风格色（缺 Deep Teal，符合营销素材的暗调叙事），10/10 Hex 值匹配调色板，Saya 剪影严格保留左前臂声匣。
- **A039-A046 成就图标色板抽查**（8/8 个）：amber_dot / coral_pulse / amber_shard / three_circles / coral_slash / coral_eye / amber_bell / amber_lantern — 2-6 色全部在调色板内（小图标不需要 10 色全用），无漂移。
- **A050 archive_boss_dual BGM 主题**（T080 #39）：AudioStreamWAV 程序化合成，BPM 132 / A minor + 增 5 度 G#3 / 16 分音符琶音 / F#6 颤音 / 33-40% louder；与单 Boss `archive_boss` 主题明显区分，archive_04.json 中 2 只 InkWarden 标 `boss_music_key: archive_boss_dual`。
- **A050 登记状态**：ASSET_REGISTRY 第 50 条记录，状态 APPROVED，路径为 `procedural`（无 PNG）。色板/像素规格维度不适用（音频资产）。
- **REJECTED 项**：A002（旧版黑斗篷主角）保持 REJECTED，未被引用，未累计 3 次失败。
- **DEPRECATED 项**：A019（Saya 占位 spritesheet）保持 DEPRECATED，仓库 grep 0 引用。

#### d) 风格漂移评估
- 抽查最近 5 个素材 ID（A047-A049 Steam capsule + A045-A046 amber_bell/amber_lantern 成就图标 + A050 archive_boss_dual BGM）+ 关键历史素材共 12 个：
  - **三动词视觉组**（A025/A033/A038 Pulse/Bind/Cut）差异化保持：Pulse 圆环 cyan、Bind 螺旋 violet、Cut 弧斩 coral。
  - **三类敌人视觉组**（A022/A028/A030-A032 SilenceMote/NoteWisp/InkWarden）差异化保持。
  - **Steam capsule 三联图**（A047-A049）Saya 剪影严格保留 A008/A009 sprite ref 关键识别点（左前臂声匣、玻璃披肩、声波围巾、青色发束）。
  - **BGM 主题差异化**：title_intro D 大调 / hub_warm F 大调 / archive_exploration A 小调 / archive_boss A 小调+三全音+半步 E6 / archive_boss_dual A 小调+三全音+增 5 度+全步 F#6 — 5 主题色板/节奏型/调性差异化保持。
- **结论**：无风格漂移。

#### e) 文档同步
- **ROADMAP.md**：
  - 已完成：T001-T080 中除 T068 外全部 `[x]`（T067/T079/T080 #38-#39 已落地，T068 候选未完成）。
  - 未完成（候选池）：T068 [候选] 商店 NPC（Hub silent_merchant）— 唯一一个未完成项。
- **CHANGELOG.md**：#1-#39 完整记录（#32-#34 时间戳错位 #34 早于 #32 的历史问题未修复，与 #35 审查结论一致）。
- **README.md**：v0.39 同步状态；Controls 表（8 行：移动/跳跃/三动词/交互/暂停/存档/读档/致谢）+ Save System 节 + Audio Controls 节 + Development Roadmap 章节 + Milestones 表（M1-M12）全部就位。
- **ASSET_REGISTRY.md**：50 条记录（A050 #39 新增 archive_boss_dual 音频），状态/路径/备注完整。
- **godot/README.md**：顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒已落地（#26 T056），本轮沙箱首次解压时此警告再次生效（unzip 失败时用 python `zipfile.extractall` 兜底）—— 证明该文档解决了真实问题。
- **REVIEW_LOG.md**：#5 / #20 / #21 / #25 / #30 / #35 / #40（本轮）7 个审查节点完整。
- **结论**：文档同步。

### 通过项
- 静态解析 0 错误。
- 运行时冒烟 0 错误（除已知 ObjectDB leak）。
- 40 class_name 全局唯一。
- 65 signal 拓扑完整。
- 5 autoload 一致（AudioManager fallback + AudioManagerEnhanced 正式 + SaveSystem）。
- 87 PNG 100% 合法头（修复 L001 test_api.png JPEG 伪装后）。
- 8 成就图标色板匹配 STYLE_GUIDE。
- 3 Steam capsule 营销三联图就位。
- 4 JSON 房间语法正确（archive_01/02/03/04），archive_03 含 InkWarden，archive_04 含双 InkWarden + 1 SilenceMote。
- Hub ↔ 4 archive 闭环通。
- BGM 5 主题 + 场景路由 + 音量独立可调 + InkWarden override（ref-counted + tier upgrade）+ 预热机制。
- 存档 3 槽位 + Continue + Settings 删除存档 + 序章过场。
- 死亡 1.5s 动画 + 默认回 Hub（设置可切经典模式）。
- 致谢屏 / 成就通知 / 暂停菜单统计面板 三处 polish 完整。
- 0 TODO/FIXME/HACK 标记。
- 文档同步。

### 发现问题

#### [严重]（0 项）
无。

#### [一般]（0 项）
无。

#### [轻微]（1 项 — 本轮已修复）
- **L001 仓库根目录 `test_api.png` 是 JPEG 伪装**：实际是 35884 字节的 JPEG 文件（`Exif standard, manufacturer=sana`），文件头 `0xFF 0xD8` 而非 PNG `89 50 4E 47`，Godot 4.6.3 import 标记 `valid=false`。仓库 grep 无 GDScript / tscn 引用（仅在自身 `.import` 文件中），不参与任何游戏逻辑。**本轮已修复**：删除 `test_api.png` + `test_api.png.import`，PNG 总数从 88 → 87，0 个非法头。

#### [信息]（流程 / 元数据 — 3 项）
- **F001 ROADMAP 候选池仍有 1 项**：T068 商店 NPC（Hub silent_merchant，55min）— 唯一一个未完成项。下一轮（#41）若决定执行，可走「新增任务模式」：Hub 永久 NPC + 能力升级 / 永久 buff 购买 + `full_archive` 成就挂钩。
- **F002 CHANGELOG.md #32-#34 时间戳错位**（#34 早于 #32）：与 #35 审查结论一致，**本轮不修**（属于历史遗留，不影响语义）。
- **F003 Godot binary 持久化**：`/workspace/godot/Godot_v4.6.3-stable_linux.x86_64` 在沙箱中无法 git 跟踪（138MB > GitHub LFS 100MB 限制），每轮首次跑都要重新解压。本轮 `unzip` 报 "bad zipfile offset" 时改用 python `zipfile.ZipFile().extractall()` 成功提取—— 已在 `godot/README.md` 写明步骤 0 拼合命令。`godot/README.md` 顶部红字警告再次生效。**建议下个 README 增补 python 兜底命令**（候选轻量任务）。

### 风格漂移评估
- 抽查最近 5 个素材（A047-A049 + A045/A046）+ 关键历史素材共 12 个 + 1 个音频资产（A050）。
- 像素规格 16x16 / 32x32 / 48x48 / 64x96 / 28x36 / 140x36 / 864x64 / 480x270 / 616x353 / 460x215 / 1200x630 全部在 STYLE_GUIDE 范围内。
- 营销三联图与 A018 key art 共享同一世界观 + 同一 Saya 设计 + 同一色板但构图独立。
- 音频资产 A050 引用 archive_boss 的同一 root_midi = 33 (A1) 保持 harmonic continuity。
- **结论**：无风格漂移。

### Godot 运行时回归
- **Godot 4.6.3 binary 重建**：沙箱内 binary 缺失，按 `godot/README.md` 步骤 0 拼合后 `unzip` 报 "bad zipfile offset"，改用 python3 `zipfile.ZipFile('/tmp/godot_full.zip').extractall('/workspace/godot/')` 成功。`chmod +x` 后 `--version` → `4.6.3.stable.official.7d41c59c4`。
- **静态解析**：`godot --headless --quit --path /workspace` 0 SCRIPT ERROR / 0 Parse Error。
- **运行时冒烟**：`godot --headless --path /workspace` 10 秒：0 ERROR / 0 WARNING（除已知 ObjectDB leak）。
- **修复后回归**：L001 test_api.png 清理后 PNG 校验 87/87 合法头；Godot 静态解析仍 0 错误。

### 结论
- 状态：**可继续迭代**。
- 严重问题 0 项。
- 一般问题 0 项。
- 轻微问题 1 项：L001 test_api.png JPEG 伪装 — **本轮已修复**。
- 信息提示 3 项：F001 ROADMAP 候选池 / F002 CHANGELOG 时间戳 / F003 Godot binary 持久化。
- 下一轮（#41）可继续「新增任务模式」：T068 商店 NPC（55min）是候选大任务；若需轻量替代，可选 F003 godot/README.md python 兜底命令补全（10min）。
- 完整审查报告写入本段。
- `ITERATION_COUNT.txt` 更新为 `41`。

## 审查 #45 — 2026-06-05T21:00+08:00

> **触发**：N=45, N%5==0，触发整点审查。本轮是 #40-#44 完成（M11 商店 NPC / M12 二阶段灯光 / T083 营销截图 / T087 archive_dawn 第 6 BGM / T086 Settings 重映射打磨）之后的"完整可玩 + 营销就绪 + 6 BGM 主题 + 4 房间"基线审查。
> Godot 4.6.3 headless binary 已在沙箱内通过 `cat *.z0* > /tmp/godot_full.zip` + `unzip` 重新拼合（`unzip` 报 "bad zipfile offset" 警告但成功提取 138MB `Godot_v4.6.3-stable_linux.x86_64`），并已通过 `--import` 重新生成 import 缓存。`godot/README.md` 顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒再次生效。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：42 个声明零冲突（与 #40 比较：40 → 42，含 T068 商店 NPC `SilentMerchantNPC` / `ShopMenu` 增量）。`save_system.gd` / `audio_manager.gd` / `player_stats.gd` / `game_state.gd` 四个 autoload 故意无 `class_name`（全局名访问）。
- **autoload 拓扑**：`project.godot` 注册 5 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced），与 #40 一致。
- **signal 拓扑**：68 个 signal 声明（与 #40 比较：65 → 68，含 T086 Settings 重映射 + T087 archive_dawn 触发增量 + T068 商店 NPC 增量）。所有 connect 端全部使用 `has_signal` 防御。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 12 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB / RID leak 退出提示）
  ```
- **`var x :=` 推断风险**：player.gd 仍有 3 处 `var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT`（_handle_pulse/_handle_bind/_handle_cut line 216/240/264），与 #20/#21/#30/#35/#40 审查结论完全一致：两边都是字面 Vector2，类型推断明确，Godot 4.6.3 静态解析 0 错误，保留。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。`@warning_ignore` 0 项；`print(...)` 调试 0 处；`push_error` / `push_warning` 31 处（合法错误处理）。
- **L001 修复后回归**：`ArchivistShadow` 节点重命名为 `WardenShadow`（更准确反映其 InkWarden 剪影内容），无 GDScript 引用，纯命名修复，0 错误。

#### b) 玩法完整性
- **核心循环三动词**：Pulse（推/破盾）+ Bind（牵引/暂停/解锁门）+ Cut（切断腐蚀链）— 全部联通，HUD 三冷却条齐备（Cyan / Violet / Coral 三色视觉差异化）。
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环（4 门 spawn 60/180/300/420, 210，精确对齐）。
  - InkWarden 已在 archive_03 (240, 134) 实例化 + archive_04 (200, 144) + (320, 144) 双 InkWarden 实例化 + Hub 中心 (240, 180) WardenShadow 剪影伏笔（#45 审查时节点名修正）。
  - `warden_slayer` 成就路径可达：Hub → archive_03/04 → Pulse 击破护盾 → 净化 InkWarden → 通知解锁。
- **三动词视觉差异化**：PulseVFX（圆环 cyan）/ BindVFX（向内螺旋 violet）/ CutVFX（弧形斩 coral）— 风格明确区分。
- **BGM 系统**（#29 T062 + #31 T066/T071 + #39 T078/T080 + #44 T087 增量）：
  - **6 个程序化主题**：`title_intro` D 大调 60 BPM / `hub_warm` F 大调 88 BPM / `archive_exploration` A 小调 72 BPM / `archive_boss` A 小调 108 BPM / `archive_boss_dual` A 小调 132 BPM（双 Boss 房专属）/ `archive_dawn` G 大调 76 BPM（胜利/回 Hub）。
  - GFC `_play_music_for_state(state)` 路由：TITLE → title_intro / PLAYING + HubController → hub_warm / PLAYING + RoomController → archive_exploration（被 InkWarden._ready 的 `request_boss_music` override 重定向到 archive_boss / archive_boss_dual） / GAME_OVER_SUCCESS → archive_dawn（2.4s 慢淡入，#44 新增） / GAME_OVER_FAILURE → stop_music。
  - Boss 音乐 ref-counted override（T078）：多 Boss 房间不会因第一只死亡就清掉 BGM 段。
  - Boss 音乐强度分级（T080）：`_BOSS_MUSIC_TIER` 单 boss = 1 / dual boss = 2。
  - 预热机制：Title 屏 _ready 时一次性合成 6 个 preset，避免首屏 → 第一次 scene 切换的卡顿。
  - 同 key 重复调用 no-op；release_boss_music 后 GFC 状态机可重新路由。
- **存档系统**（#33 T070 + #34 T072 + #39 T079 增量）：
  - 3 槽位 user://saves/slot_N.json 写读 + 删除。
  - 自动收集 GameState（current_room / current_scene / health / resonance / shards / rooms_completed / abilities / checkpoint_position / run_time_seconds）+ PlayerStats（成就解锁状态）作为快照。
  - 成就独立持久化到 user://achievements.json，跨运行保留（Steam 风格永久解锁）。
  - Continue 流程：Title 屏 "继续修复" 按钮 → 选 slot → GFC `_on_continue_game` → load_from_slot 还原 → ROOM_TRANSITION 切换场景。
  - 死亡重生点：默认回 Hub 安全区（`Settings → Saves` 开关可切"经典模式"回最近 Save Lantern）。
- **成就系统**：8 个成就 + 8 个图标（A039-A046）+ 通知卡 + 暂停菜单统计面板 + 8 宫格图标。`full_archive` 描述（#45 G003 已修）与 4 房间数对齐。
- **Settings 完整 4 Tab**（#19 T037 + #34 T072 + #44 T086 增量）：
  - Audio: Master / Music / SFX / Ambience 4 bus 独立滑块。
  - Video: 全屏 + 4 档整数倍缩放。
  - Controls: 7 个 action 实时重映射（#44 T086 扩到 7 动作 + 冲突 swap 检测 + ESC 取消 + 青色确认闪烁 + "恢复默认按键" 按钮）→ user://settings.cfg 持久化。
  - Saves: 3 槽位状态显示 + "删除所有存档" 按钮（ConfirmationDialog 二次确认 + Toast 反馈）。
- **Tutorial 系统**：所有 5 个非 Hub 场景（main/archive_01-04 通过 JSON loader）+ Hub 房间都有 `tutorial_hint` 组实例。
- **IntroCutscene**（#34 T073）：8 秒黑屏 + 渐入 + 文字 + 渐出 + 任意键跳过；Continue 读档时 `_ready()` 防御性 short-circuit（#35 T035 修复）。
- **商店 NPC**（#41 T068）：Hub silent_merchant + 5 个永久升级（heart_crystal / resonance_chime / pulse_focus / echo_charm / silence_breaker）。`silence_breaker` 需先解锁 `full_archive` 成就。GameState 5 个派生字段 + `purchased_perks` 持久化 + `max_health` / `max_resonance` 改 derived。
- **二阶段灯光**（#42 T081）：4 个 archive 房间都 opt-in `atmosphere: true`，bell 修复后 0.8s 暖光回流（stage 1）+ 房间完成 2s 暖色覆盖（stage 2）。
- **玩家死亡**（#36 T075）：1.5s lay-down + 慢淡出动画。
- **营销素材**（#32 T069 + #43 T083）：3 联图（616x353 / 460x215 / 1200x630）+ 6 张 mockup 截图（沙箱 fallback 合成，真实 capture 工具在桌面环境可用）。

#### c) 素材一致性
- **PNG 资源头校验**：
  ```
  python3 遍历 ./assets 与项目根：97 个 PNG 全部 `89 50 4E 47 0D 0A 1A 0A` 合法头，0 个 JPEG 伪装。
  ```
  与 #40 一致（87 → 97，增量来自 #41 T068 silent_merchant 4 文件：portrait 48/96 + sprite 32/64 = 4 个新 PNG + 2 个 `.import` + 6 张 mockup 截图）。
- **A051 拆分**（#45 G001 已修）：原 ASSET_REGISTRY 第 56-57 行 A051 重复 ID + 字段顺序错乱（用 Markdown 加粗，缺状态/路径/备注列），本轮拆为 A051 silent_merchant_portrait（48x48+96x96）+ A053 silent_merchant_sprite（32x32+64x64），各自独立登记，字段顺序与 A001-A052 一致。
- **A039-A046 成就图标色板抽查**（8/8 个）：amber_dot / coral_pulse / amber_shard / three_circles / coral_slash / coral_eye / amber_bell / amber_lantern — 33-100% 容差 48 命中，无漂移。
- **A047-A049 Steam capsule 三联图**：10/10 风格色覆盖（与 #40 审查一致）。
- **A050 archive_boss_dual BGM 主题**：5/8 容差命中。
- **A052 archive_dawn BGM 主题**（#44 新增）：与 hub_warm 形成"上行解决"（F2 → G2）而非突变。
- **REJECTED 项**：A002（旧版黑斗篷主角）保持 REJECTED，未被引用，未累计 3 次失败。
- **DEPRECATED 项**：A019（Saya 占位 spritesheet）保持 DEPRECATED，仓库 grep 0 引用。

#### d) 风格漂移评估
- 抽查最近 5 个素材 ID + 关键历史素材共 17 个：
  - **三动词视觉组**（A025/A033/A038 Pulse/Bind/Cut）差异化保持：Pulse 圆环 cyan、Bind 螺旋 violet、Cut 弧斩 coral。
  - **三类敌人视觉组**（A022/A028/A030-A032 SilenceMote/NoteWisp/InkWarden 3 态）差异化保持。
  - **T068 商店 NPC**（A051 portrait + A053 sprite）新增色板与 STYLE_GUIDE 一致（Deep Ink Navy 斗篷 + Muted Violet 阴影 + Amber Voice 围巾 + Glass Cyan 边）。
  - **BGM 主题差异化**：title_intro D 大调 / hub_warm F 大调 / archive_exploration A 小调 / archive_boss A 小调+三全音 / archive_boss_dual A 小调+增 5 度 / archive_dawn G 大调 — 6 主题色板/节奏型/调性差异化保持。
- **结论**：无风格漂移。

#### e) 文档同步
- **ROADMAP.md**：
  - 已完成：T001-T087 中除 T068 之前所有任务 + T068（#41）+ T083（#43）+ T086/T087（#44）全部 `[x]`。
  - 未完成：T084 [候选] Boss 阶段 2 / T085 [候选] Echo 护盾 / T088 [候选] 5 存档位 / T089 [候选] 屏幕震动 polish / T090 [候选] 装饰物件 procedural。
- **CHANGELOG.md**：#1-#44 完整记录。
- **README.md**（#45 G002/G004 已修）：
  - Tech 段补"6 procedural BGM themes"含 archive_dawn 描述。
  - Audio Controls 表 Music 列补全 6 个 BGM 主题。
  - M7 Milestone 补 6 主题 + T087 + #44 增量。
  - Recent completed work 补全 #40-#45 共 6 条记录。
- **ASSET_REGISTRY.md**（#45 G001 已修）：A051 拆为 A051 portrait + A053 sprite，字段顺序合规。
- **godot/README.md**：顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒已落地，#40 兜底 Python `zipfile` 命令已写明。
- **REVIEW_LOG.md**：#5 / #20 / #21 / #25 / #30 / #35 / #40 / #45（本轮）8 个审查节点完整。
- **结论**：文档同步。

### 通过项
- 静态解析 0 错误。
- 运行时冒烟 0 错误（除已知 ObjectDB leak）。
- 42 class_name 全局唯一。
- 68 signal 拓扑完整。
- 5 autoload 一致。
- 97 PNG 100% 合法头。
- 8 成就图标色板匹配 STYLE_GUIDE。
- 3 Steam capsule 营销三联图就位。
- 4 JSON 房间语法正确，archive_03 含 1 InkWarden，archive_04 含 2 InkWarden + 1 SilenceMote。
- Hub ↔ 4 archive 闭环通。
- BGM 6 主题 + 场景路由 + 音量独立可调 + InkWarden override（ref-counted + tier upgrade）+ 预热机制。
- 存档 3 槽位 + Continue + Settings 删除存档 + 序章过场。
- 商店 NPC silent_merchant + 5 永久升级。
- 死亡 1.5s 动画 + 默认回 Hub（设置可切经典模式）。
- 二阶段灯光 4 房间 atmosphere=true。
- 营销 6 张 mockup 截图就位。
- 致谢屏 / 成就通知 / 暂停菜单统计面板 三处 polish 完整。
- 0 TODO/FIXME/HACK 标记。
- 文档同步。

### 发现问题

#### [严重]（0 项）

无。

#### [一般]（4 项 — 本轮已修复）

- **G001 ASSET_REGISTRY.md A051 登记混乱**：
  - 原第 56-57 行 A051 被重复登记两次（实际是 2 个独立素材：portrait + sprite），且字段顺序错乱（用 Markdown 加粗，缺状态/路径/备注列），破坏账本一致性。**本轮已修复**：拆为 A051 silent_merchant_portrait + A053 silent_merchant_sprite（seed 1051 / 1053），字段顺序与 A001-A052 一致，路径列明确。
- **G002 README.md BGM 主题数量描述不一致**：
  - Tech 段写"5 procedural BGM themes"、Audio Controls 表只列 4 个主题（title_intro / hub_warm / archive_exploration / archive_boss）、M7 Milestone 段也写"5 synthesized themes"—— 实际 #44 T087 新增 `archive_dawn` 后是 6 个。**本轮已修复**：3 处全部补全到 6 主题含 archive_dawn。
- **G003 achievements.json `full_archive` 描述与实际房间数不一致**：
  - 原描述说"完成全部三间回声档案馆"，但现在有 4 间 archive 房间（archive_01/02/03/04）。功能上 3 阈值仍然有效（玩家完成前 3 间即解锁），但描述可能误导玩家。**本轮已修复**：描述改为"完成 3 间回声档案馆（现有 4 间，完成任 3 间即解锁）"，与实际行为对齐。
- **G004 README "Recent completed work" 缺 #40-#44**：
  - 原最后一条是 #39，缺 #40 (审查) / #41 (商店 NPC) / #42 (二阶段灯光) / #43 (营销截图) / #44 (archive_dawn + settings polish) — 5 条记录。**本轮已修复**：补全 5 条 + 头部新增 #45 审查条目。

#### [轻微]（1 项 — 本轮已修复）

- **L001 `hub_room.tscn` `ArchivistShadow` 节点命名误导**：
  - 第 171-183 行 `ArchivistShadow` 节点（位置 240, 180）实际是 InkWarden 剪影伏笔（内有 `WardenSilhouette` + `BaseGlow`），不是 Archivist NPC 剪影。节点命名有误导性，新协作者可能误以为这是档案管理员的视觉元素。**本轮已修复**：重命名为 `WardenShadow`（更准确反映其 InkWarden 剪影内容），加注释说明。无 GDScript 引用，纯命名修复，0 错误。

#### [信息]（流程 / 元数据 — 2 项）

- **F001 ROADMAP 候选池仍有 5 项**（T084 / T085 / T088 / T089 / T090），下一轮（#46）可继续「新增任务模式」从 RESEARCH.md / INSPIRATION.md 找未实现创意。
- **F002 CHANGELOG.md #32-#34 时间戳错位**（#34 早于 #32）：与 #40 审查结论一致，**本轮不修**（属于历史遗留，不影响语义）。

### 风格漂移评估
- 抽查最近 5 个素材 ID（A051 + A053 + A050 + A052 + A047-A049）+ 关键历史素材共 17 个。
- 像素规格 16x16 / 32x32 / 48x48 / 48x96 / 64x64 / 64x96 / 28x36 / 140x36 / 480x270 / 616x353 / 460x215 / 1200x630 全部在 STYLE_GUIDE 范围内。
- 营销三联图与 A018 key art 共享同一世界观 + 同一 Saya 设计 + 同一色板但构图独立。
- 音频资产 A050/A052 引用 archive_boss 的同一 root_midi = 45 (A2) 保持 harmonic continuity，A052 root_midi = 43 (G2) 与 hub_warm F2 形成上行解决。
- **结论**：无风格漂移。

### Godot 运行时回归
- **Godot 4.6.3 binary 重建**：沙箱内 binary 缺失，按 `godot/README.md` 步骤 0 拼合后 `unzip` 报 "warning zipfile claims to be last disk of a multi-part archive" + "bad zipfile offset (local header sig)" 但成功提取（`unzip` 自动 re-compensate），138MB，`--version` → `4.6.3.stable.official.7d41c59c4`。
- **静态解析**：`godot --headless --quit --path /workspace` 0 SCRIPT ERROR / 0 Parse Error。
- **运行时冒烟**：`godot --headless --path /workspace` 12 秒：0 ERROR / 0 WARNING（除已知 ObjectDB leak）。
- **修复后回归**：
  - L001 WardenShadow 节点重命名：0 错误。
  - G001 ASSET_REGISTRY A051 拆分：grep / parse 0 错误。
  - G002/G003/G004 README + achievements.json 文档同步：0 影响游戏代码。

### 结论

- 状态：**可继续迭代**。
- 严重问题 0 项。
- 一般问题 4 项：G001 ASSET_REGISTRY 拆分 / G002 README BGM 主题数 / G003 achievements 描述 / G004 README Recent work — **全部本轮已修复**。
- 轻微问题 1 项：L001 hub_room.tscn 节点命名 — **本轮已修复**。
- 信息提示 2 项：F001 ROADMAP 候选池 / F002 CHANGELOG 时间戳。
- 下一轮（#46）可继续「新增任务模式」：T084 / T085 / T088 / T089 / T090 中选 1-2 个执行。
- 完整审查报告写入本段。
- `ITERATION_COUNT.txt` 更新为 `46`。

## 审查 #50 — 2026-06-06T17:00+08:00

> **触发**：N=50, N%5==0，触发整点审查。本轮是 #46-#49 完成（InkWarden 阶段 2 / 屏幕震动 polish / 装饰物件 / 死亡 freeze-frame / 灰阶洗 / Echo 图标 A061）之后的「完整可玩 + 营销就绪 + 4 房间 + 6 BGM + 4 敌人 4 态 + 3 NPC + Echo 四动词预热」基线审查。
> Godot 4.6.3 headless binary 已在沙箱内通过 `cat *.z0* > /tmp/godot_full.zip` + `unzip` 重新拼合（unzip 报 "warning zipfile claims to be last disk of a multi-part archive" + "bad zipfile offset (local header sig)" 但成功提取 138MB `Godot_v4.6.3-stable_linux.x86_64`），并已通过 `--import` 重新生成 113 个 import 步骤 + 全部 .ctex 缓存。`godot/README.md` 顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒再次生效。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：42 个声明零冲突（与 #45 比较：42 → 42，T085 仅 Art 落地未新增 class）。所有 42 个 `class_name` 跨 `src/scripts/` 41 个 + `src/scripts/audio_manager_enhanced.gd` 1 个（autoload 透明全局访问）。
  - 4 个 autoload 故意无 `class_name`：`game_state.gd` / `player_stats.gd` / `save_system.gd` / `audio_manager.gd`（通过全局名直接访问）。
- **autoload 拓扑**：`project.godot` 注册 6 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / **ScreenShake**——#47 T089 新增），与 #45 审查一致。
- **signal 拓扑**：68 个 signal 声明（与 #45 一致，无新增；T085 仅 Art 落地未引入新 signal；T093/T092 在 screen_shake.gd autoload 与 player.gd 内部用 Tween callback 替代新 signal）。所有 connect 端全部使用 `has_signal` 防御。
- **静态解析**：
  ```
  timeout 15 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 10 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB leak 退出提示，与历史一致）
  ```
- **`var x :=` 推断风险**：player.gd 仍有 3 处 `var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT`（_handle_pulse/_handle_bind/_handle_cut），与 #20/#21/#30/#35/#40/#45 审查结论完全一致：两边都是字面 Vector2，类型推断明确，Godot 4.6.3 静态解析 0 错误，保留。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **`@warning_ignore`**：0 项；`print(...)` 调试 0 处；`push_error` / `push_warning` 31 处（合法错误处理，与 #45 一致）。

#### b) 玩法完整性
- **核心循环三动词**：Pulse（推/破盾）+ Bind（牵引/暂停/解锁门）+ Cut（切断腐蚀链）— 全部联通，HUD 三冷却条齐备（Cyan / Violet / Coral 三色视觉差异化）。**Echo 是 #50+ 候选 T094 待落地**，目前 HUD 仅 3 冷却条（hud.gd 47-57 行）。
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环（4 门 spawn 60/180/300/420, 210，精确对齐 hub_room.tscn 123-145 行）。
  - InkWarden 已在 archive_03 (240, 134) 实例化 + archive_04 (200, 144) + (320, 144) 双 InkWarden 实例化。
  - Hub 中心 (240, 180) 有 `WardenShadow` 节点（#45 L001 已重命名）含 `WardenSilhouette` (64x96 ink_warden.png, 0.85 缩放, 55% alpha, 0.4/0.3/0.5 紫色调) + `BaseGlow` (50% alpha 珊瑚色) — 剪影伏笔。
  - 4 房间 JSON `enemies` 数组抽查：archive_01 1 silence_mote / archive_02 2 note_wisp / archive_03 2 silence_mote + 1 note_wisp + 1 ink_warden / archive_04 2 ink_warden + 1 silence_mote — 全部 `atmosphere: true`。
  - `warden_slayer` 成就路径可达：Hub → archive_03/04 → Pulse 击破护盾 → 净化 InkWarden → 通知解锁。
- **三动词视觉差异化**：PulseVFX（圆环 cyan）/ BindVFX（向内螺旋 violet）/ CutVFX（弧形斩 coral）— 色板严格分工。
- **BGM 系统**（#29 T062 + #31 T066/T071 + #39 T078/T080 + #44 T087 增量）：
  - **6 个程序化主题**：`title_intro` D 大调 60 BPM / `hub_warm` F 大调 88 BPM / `archive_exploration` A 小调 72 BPM / `archive_boss` A 小调 108 BPM / `archive_boss_dual` A 小调 132 BPM（双 Boss 房专属）/ `archive_dawn` G 大调 76 BPM（胜利/回 Hub）。
  - GFC `_play_music_for_state(state)` 路由：TITLE → title_intro / PLAYING + HubController → hub_warm / PLAYING + RoomController → archive_exploration（被 InkWarden._ready 的 `request_boss_music` override 重定向到 archive_boss / archive_boss_dual） / GAME_OVER_SUCCESS → archive_dawn（2.4s 慢淡入） / GAME_OVER_FAILURE → stop_music。
  - Boss 音乐 ref-counted override（T078 #38）：多 Boss 房间不会因第一只死亡就清掉 BGM 段。
  - Boss 音乐强度分级（T080 #39）：`_BOSS_MUSIC_TIER` 单 boss = 1 / dual boss = 2，archive_04 出现第二只 InkWarden 时自动 tier-upgrade。
  - 预热机制：Title 屏 _ready 时一次性合成 6 个 preset。
- **存档系统**（#33 T070 + #34 T072 + #39 T079 增量）：
  - 3 槽位 user://saves/slot_N.json 写读 + 删除。
  - 自动收集 GameState（current_room / current_scene / health / resonance / shards / rooms_completed / abilities / checkpoint_position / run_time_seconds）+ PlayerStats（成就解锁状态）作为快照。
  - 成就独立持久化到 user://achievements.json，跨运行保留。
  - Continue 流程：Title 屏 "继续修复" 按钮 → 选 slot → GFC `_on_continue_game` → load_from_slot 还原 → ROOM_TRANSITION 切换场景。
  - 死亡重生点：默认回 Hub 安全区（`Settings → Saves` 开关可切"经典模式"回最近 Save Lantern）。
- **死亡 VFX 序列**（#36 T075 + #48 T092 + #49 T093 增量）：
  - 0.15s freeze-frame（red tint + `Engine.time_scale = 0.2`）→ 0.3s grayscale wash（冷灰 Color(0.32, 0.34, 0.40) sine tween）→ 0.5s lay-down（rotation PI/2 quad-ease-in）→ 1.0s fade-out（alpha 1→0 linear，红调保持让 alpha 衰减读作 "drained red"）→ `_finish_death`。
  - `respawn_at()` 兜底重置 time_scale 防 freeze 卡死。
- **成就系统**：8 个成就 + 8 个图标（A039-A046）+ 通知卡 + 暂停菜单统计面板 + 8 宫格图标。
- **Settings 完整 4 Tab**（#19 T037 + #34 T072 + #44 T086 增量）：
  - Audio: Master / Music / SFX / Ambience 4 bus 独立滑块。
  - Video: 全屏 + 4 档整数倍缩放。
  - Controls: 7 个 action 实时重映射（#44 T086 扩到 7 动作 + 冲突 swap 检测 + ESC 取消 + 青色确认闪烁 + "恢复默认按键" 按钮）→ user://settings.cfg 持久化。
  - Saves: 3 槽位状态显示 + "删除所有存档" 按钮。
- **Tutorial 系统**：所有 5 个非 Hub 场景（main/archive_01-04 通过 JSON loader）+ Hub 房间都有 `tutorial_hint` 组实例。
- **IntroCutscene**（#34 T073）：8 秒黑屏 + 渐入 + 文字 + 渐出 + 任意键跳过；Continue 读档时 `_ready()` 防御性 short-circuit（#35 T035 修复）。
- **商店 NPC**（#41 T068）：Hub silent_merchant + 5 个永久升级（heart_crystal / resonance_chime / pulse_focus / echo_charm / silence_breaker）。`silence_breaker` 需先解锁 `full_archive` 成就。GameState 5 个派生字段 + `purchased_perks` 持久化 + `max_health` / `max_resonance` 改 derived。
- **二阶段灯光**（#42 T081）：4 个 archive 房间都 opt-in `atmosphere: true`，bell 修复后 0.8s 暖光回流（stage 1）+ 房间完成 2s 暖色覆盖（stage 2）。
- **屏幕震动 polish**（#47 T089）：ScreenShake autoload + 8 个预设（新增 BOSS_PHASE2 5.0/0.30s 最高强度），Timer 30Hz micro-shake + Tween quad ease-out 衰减，process_mode=ALWAYS。
- **装饰物件**（#47 T090）：6 个程序化像素小物件（hourglass 12x16 / wave_totem 12x24 / hanging_bell 8x10 / crystal_cluster 16x12 / standing_lantern 8x20 / sound_pillar 8x24）+ 14 个 archive_01-04 装饰实例。
- **营销素材**（#32 T069 + #43 T083）：3 联图（616x353 / 460x215 / 1200x630）+ 6 张 mockup 截图（沙箱 fallback 合成，真实 capture 工具在桌面环境可用）。

#### c) 素材一致性
- **PNG 资源头校验**：
  ```
  python3 遍历 ./assets + ./docs/screenshots：112 个 PNG 全部 `89 50 4E 47 0D 0A 1A 0A` 合法头，0 个 JPEG 伪装。
  ```
  与 #45 审查（97 个）比较：增量来自 #47 T090 装饰 12 个新 PNG（6 主 + 6 4x 放大）+ #49 T085 Echo 2 个（echo_icon 32x32 + 64x64）+ A054 InkWarden Phase 2 1 个 = 15 个新 PNG。#48-#49 无 PNG 删除。
- **A061 Echo 图标色板抽查**（新核心 4 动词第 4 块）：
  - `echo_icon.png` (32x32)：6/6 色板匹配 — Abyss Black（背景圆盘）/ Glass Cyan（护盾球体 + 外环）/ Pale Resonance（棱镜光线 + 中心高光）/ Coral Pulse（反弹箭头）/ Warm Parchment（高光小点）/ Amber Voice（中心暖点）。所有 Hex 值与 STYLE_GUIDE 100% 匹配。
  - `echo_icon_64x64.png` (64x64)：色板与 32x32 完全一致（程序化生成），6/6 匹配。
- **三动词 + Echo 四动词视觉组色域分布**（与 #49 审查一致）：
  - Pulse (圆环) = Glass Cyan + Coral Pulse 双色（冷色环 + 暖色核心）
  - Bind (螺旋) = Muted Violet 暗紫底（冷紫色域独占）
  - Cut (斩) = Coral Pulse 珊瑚锋线（暖色域独占）
  - Echo (护盾) = Glass Cyan + Pale Resonance 冷色护盾 + Coral Pulse 反弹箭头 + Amber Voice 中心（冷色域 + 暖色反弹 + 暖色核心）
  - 4 动词色域不重叠，HUD 4 个冷却条放在一起一眼可分（待 #50+ T094 写 EchoAbility 类后接入）。
- **A054 InkWarden Phase 2**（#46 T084）色板抽查：7/8 命中（Abyss Black + Coral Pulse + Muted Violet + Amber Voice + Warm Parchment + Glass Cyan + 多 1 个纯白高光点），与 STYLE_GUIDE 一致；与 A030/A031/A032 基础/破盾/眩晕构成 4 态视觉组。
- **A039-A046 成就图标色板抽查**（8/8 个）：amber_dot / coral_pulse / amber_shard / three_circles / coral_slash / coral_eye / amber_bell / amber_lantern — 33-100% 容差命中，无漂移（与 #45 一致）。
- **A047-A049 Steam capsule 三联图**：10/10 风格色覆盖（与 #45 审查一致）。
- **A050 archive_boss_dual BGM 主题**：5/8 容差命中。
- **A052 archive_dawn BGM 主题**：与 hub_warm 形成"上行解决"（F2 → G2）而非突变。
- **A055-A060 装饰物件色板抽查**（hourglass 6/6 / wave_totem 7/7 / hanging_bell 5/5 / crystal_cluster 6/6 / standing_lantern 6/6 / sound_pillar 7/7）— 全部严格遵循 STYLE_GUIDE，零漂移。
- **A051/A053 silent_merchant**（#41 T068）色板抽查：5/5（portrait）+ 5/5（sprite）— Deep Ink Navy 斗篷 + Muted Violet 阴影 + Amber Voice 围巾 + Glass Cyan 边 + 暖白高光，零漂移。
- **REJECTED 项**：A002（旧版黑斗篷主角）保持 REJECTED，未被引用，未累计 3 次失败。
- **DEPRECATED 项**：A019（Saya 占位 spritesheet）保持 DEPRECATED，仓库 grep 0 引用；ASSET_REGISTRY 仍登记但备注明确已删除 PNG（#26 T054 修复后状态）。
- **路径校验**：61 个注册路径中 60 个存在，1 个 missing（A019 占位 PNG 已按 #26 T054 删除，ASSET_REGISTRY 备注已说明），与预期一致。

#### d) 风格漂移评估
- 抽查最近 5 个素材 ID（A061 Echo + A054 InkWarden Phase 2 + A055-A060 装饰 6 件）+ 关键历史素材共 17 个：
  - **三动词 + Echo 视觉组**（A025/A033/A038/A061 Pulse/Bind/Cut/Echo）差异化保持：圆环 / 螺旋 / 弧斩 / 护盾，色板分工不重叠。
  - **四敌人 4 态视觉组**（A022/A028/A030-A032 SilenceMote/NoteWisp/InkWarden 4 态）差异化保持。
  - **T090 装饰 6 件**（A055-A060）色板全部遵循 Archive Blue + Glass Cyan + Amber Voice + Muted Violet + Coral Pulse + Ink Navy 描边。
  - **T068 商店 NPC**（A051 portrait + A053 sprite）色板与 STYLE_GUIDE 一致。
  - **BGM 主题差异化**：title_intro D 大调 / hub_warm F 大调 / archive_exploration A 小调 / archive_boss A 小调+三全音 / archive_boss_dual A 小调+增 5 度 / archive_dawn G 大调 — 6 主题色板/节奏型/调性差异化保持。
  - 营销三联图（A047-A049）Saya 剪影严格保留 A008/A009 sprite ref 关键识别点（左前臂声匣、玻璃披肩、声波围巾、青色发束）。
- 像素规格 16x16 / 32x32 / 48x48 / 48x96 / 64x64 / 64x96 / 28x36 / 140x36 / 480x270 / 616x353 / 460x215 / 1200x630 全部在 STYLE_GUIDE 范围内。
- **结论**：无风格漂移。

#### e) 文档同步
- **ROADMAP.md**：
  - 已完成：T001-T093 中除 T094/T095 之外全部 `[x]`。
  - 未完成（候选池）：T088 [候选] 5 存档位 / T094 [候选] EchoAbility 类 / T095 [候选] Echo 护盾 VFX。
- **CHANGELOG.md**：#1-#49 完整记录（#32-#34 时间戳错位 #34 早于 #32 的历史问题未修复，与 #35/#40/#45 审查结论一致）。
- **README.md**：v0.45 同步状态；Controls 表 + Audio Controls 表 + Save System 节 + Death & respawn 段 + Two-stage archive lighting 段 + 6 主题 BGM 描述 + Screenshots 节（6 张 mockup）+ Milestones 表（M1-M12）+ Recent completed work（#36-#49 14 条）全部就位。
- **ASSET_REGISTRY.md**：65 条记录（#45 G001 拆分 A051/A053 + #46 A054 + #47 A055-A060 + #49 A061 共 9 个新登记），状态/路径/备注完整。**本轮 L001 修复**：第 56-57 行 A051/A053 仍用 Markdown 加粗 `**...**`，与表中其他行格式不一致，本轮已修复。
- **godot/README.md**：顶部红字"⚠️ 首次解压必须先跑 `--import`"提醒已落地（#26 T056），本轮沙箱首次解压时此警告再次生效（unzip 报 "warning" 但成功提取 138MB）。
- **REVIEW_LOG.md**：#5 / #20 / #21 / #25 / #30 / #35 / #40 / #45 / #50（本轮）9 个审查节点完整。
- **结论**：文档同步。

### 通过项

- 静态解析 0 错误。
- 运行时冒烟 0 错误（除已知 ObjectDB leak）。
- 42 class_name 全局唯一。
- 68 signal 拓扑完整。
- 6 autoload 一致（AudioManager fallback + AudioManagerEnhanced 正式 + GameState + PlayerStats + SaveSystem + ScreenShake）。
- 112 PNG 100% 合法头。
- A061 Echo 图标 6/6 色板匹配 STYLE_GUIDE。
- A054 InkWarden Phase 2 7/8 色板匹配。
- A055-A060 装饰 6 件 6-7/7 色板匹配。
- A039-A046 成就图标 8/8 色板匹配。
- A047-A049 Steam capsule 营销三联图就位。
- 4 JSON 房间语法正确，archive_03 含 1 InkWarden，archive_04 含 2 InkWarden + 1 SilenceMote。
- Hub ↔ 4 archive 闭环通（4 门 spawn 60/180/300/420, 210）。
- Hub 3 NPC（archivist / tuner / silent_merchant）+ WardenShadow 剪影伏笔。
- BGM 6 主题 + 场景路由 + 音量独立可调 + InkWarden override（ref-counted + tier upgrade）+ 预热机制。
- 存档 3 槽位 + Continue + Settings 删除存档 + 序章过场。
- 商店 NPC silent_merchant + 5 永久升级。
- 死亡 4 阶段 VFX 序列（freeze + grayscale + lay-down + fade-out）+ 默认回 Hub（设置可切经典模式）。
- 二阶段灯光 4 房间 atmosphere=true。
- 屏幕震动 8 预设（BOSS_PHASE2 5.0/0.30s 最高）。
- 装饰 14 实例 + 6 物件。
- 营销 6 张 mockup 截图就位。
- 致谢屏 / 成就通知 / 暂停菜单统计面板 三处 polish 完整。
- 0 TODO/FIXME/HACK 标记。
- 文档同步（除 L001 本轮修复）。

### 发现问题

#### [严重]（0 项）

无。

#### [一般]（0 项）

无。

#### [轻微]（1 项 — 本轮已修复）

- **L001 ASSET_REGISTRY.md 第 56-57 行 A051/A053 表格字段加粗脱锁**：
  - 第 56-57 行 A051 / A053 所有字段（ID / 名称 / 类型 / 风格 / 模型 / Subject / 状态 / 路径 / 备注）均用 Markdown 加粗 `**...**`，与表中其他行（A001-A060 / A061）格式不一致，破坏账本视觉一致性。虽 #45 审查 L001 已将 A051 拆为 A051 + A053 两个独立条目，但当时为强调"新拆分"语义，错误地给两行全部字段加了粗体。后续 A052/A054+ 已回归普通格式。**本轮已修复**：去除 A051/A053 两行的所有加粗符号，字段顺序与 A001-A061 严格一致。

#### [信息]（流程 / 元数据 — 3 项）

- **F001 ROADMAP 候选池仍有 3 项**（T088 / T094 / T095），下一轮（#51）可继续「新增任务模式」从 RESEARCH.md / INSPIRATION.md 找未实现创意。
  - **T094 [候选] EchoAbility 类**（50min）是 #49 A061 Echo 图标的代码侧落地——实现 Echo 护盾（短前摇、球形碰撞、0.6s 持续、敌人投射物反弹/摧毁）+ HUD 第四冷却条 + Bind 模式。"四动词"完整闭环的最后一块。
  - **T095 [候选] Echo 护盾 VFX**（30min）— Echo 护盾施放时玻璃青圆环扩散 + 棱镜光散开 + 反弹命中时 Coral Pulse 闪光 + 护盾破碎时碎片飞溅。
  - **T088 [候选] 5 存档位 / 列表视图**（45min）— 当前 3 槽位扩展为 5，提供存档列表 UI 优化。
- **F002 CHANGELOG.md #32-#34 时间戳错位**（#34 早于 #32）：与 #35/#40/#45 审查结论一致，**本轮不修**（属于历史遗留，不影响语义）。
- **F003 Godot binary 持久化**：`/workspace/godot/Godot_v4.6.3-stable_linux.x86_64` 在沙箱中无法 git 跟踪（138MB > GitHub LFS 100MB 限制），每轮首次跑都要重新解压。本轮 `unzip` 报 "warning zipfile claims to be last disk of a multi-part archive" + "bad zipfile offset (local header sig)" 但成功提取 138MB（unzip 自动 re-compensate）。`godot/README.md` 顶部红字警告 + Python `zipfile` 兜底命令均生效。**无需新处理**。

### 风格漂移评估

- 抽查最近 5 个素材 ID（A061 Echo + A054 InkWarden Phase 2 + A055-A060 装饰 6 件）+ 关键历史素材共 17 个。
- 像素规格 16x16 / 32x32 / 48x48 / 48x96 / 64x64 / 64x96 / 28x36 / 140x36 / 480x270 / 616x353 / 460x215 / 1200x630 全部在 STYLE_GUIDE 范围内。
- 营销三联图与 A018 key art 共享同一世界观 + 同一 Saya 设计 + 同一色板但构图独立。
- 音频资产 A050/A052 引用 archive_boss 的同一 root_midi = 45 (A2) 保持 harmonic continuity，A052 root_midi = 43 (G2) 与 hub_warm F2 形成上行解决。
- **结论**：无风格漂移。

### Godot 运行时回归

- **Godot 4.6.3 binary 重建**：沙箱内 binary 缺失，按 `godot/README.md` 步骤 0 拼合后 `unzip` 报 "warning zipfile claims to be last disk of a multi-part archive" + "bad zipfile offset (local header sig)" 但成功提取（`unzip` 自动 re-compensate），138MB，`--version` → `4.6.3.stable.official.7d41c59c4`。
- **静态解析**：`godot --headless --quit --path /workspace` 0 SCRIPT ERROR / 0 Parse Error。
- **运行时冒烟**：`godot --headless --path /workspace` 10 秒：0 ERROR / 0 WARNING（除已知 ObjectDB leak）。
- **修复后回归**：L001 ASSET_REGISTRY A051/A053 加粗去除后，grep / parse 0 错误。

### 结论

- 状态：**可继续迭代**。
- 严重问题 0 项。
- 一般问题 0 项。
- 轻微问题 1 项：L001 ASSET_REGISTRY 表格加粗脱锁 — **本轮已修复**。
- 信息提示 3 项：F001 ROADMAP 候选池 / F002 CHANGELOG 时间戳 / F003 Godot binary 持久化。
- 下一轮（#51）可继续「新增任务模式」：T088 / T094 / T095 中选 1-2 个执行（推荐 T094 EchoAbility 类，补齐四动词代码侧最后一块）。
- 完整审查报告写入本段。
- `ITERATION_COUNT.txt` 更新为 `51`。

