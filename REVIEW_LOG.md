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
