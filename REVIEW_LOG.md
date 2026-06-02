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
