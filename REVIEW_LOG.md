# 审查日志

## 审查 #19 — 2026-06-03T12:00+08:00
> 触发：用户手动请求全面审查（最近一次正式审查为 #5，已跨 13 轮未经审查）。

### 范围
- 完整代码审计：38 个 GDScript + 19 个 Scene + 3 个 JSON 房间配置 + 1 个 project.godot
- 全部 38 个 ASSET_REGISTRY 资产（重点抽查最近 4 轮新增）
- 三种 verb 交互闭环（Pulse / Bind / Cut）
- 文档三方同步（ROADMAP ↔ CHANGELOG ↔ README）
- 全部 40 个 ROADMAP 任务交付质量

### 通过项

#### A) 代码质量
- [x] 全部 .tscn / .gd / .json 文件语法可解析（手动 + Python 校验）
- [x] 没有 GDScript 缩进/制表符混用
- [x] 没有循环导入（所有 `class_name` 引用单向）
- [x] 全部 21 个关键资产存在且 PIL 可加载
- [x] Pulse / Bind / Cut 三种能力均已实现类结构与信号连接
- [x] GameState autoload 单例运行良好（resonance / shards / abilities / heal / reset_run）
- [x] RoomLoader 支持 5 种 interactable 类型（glass_lock / voice_bell / save_lantern / silenced_web / [其他]）
- [x] RoomController `_find_room_objects` 已修复（使用 `get_parent().get_node_or_null`）

#### B) 玩法完整性
- [x] **三动词闭环**：Pulse (推/破盾，圆环) + Bind (牵引/暂停，螺旋) + Cut (切断/贯穿，弧斩) — 完成 RESEARCH.md 核心设计
- [x] **核心循环可玩**：进入房间 → 战斗 (P/B/C 击敌) → 修复玻璃锁 (Pulse) → 收集共鸣 (VoiceBell) → 开门 (RoomDoor)
- [x] **Hub 教程对话**：档案管理员 5 句对话 + 选项分支
- [x] **设置菜单 / 暂停菜单 / 死亡屏幕 / 标题屏幕** 完整

#### C) 素材一致性
- [x] **无 REJECTED 累积**（A002 为旧版废案，已记录）
- [x] **A038 Cut 图标** vs A025 Pulse + A033 Bind 形成「三动词」视觉组合
- [x] **A037 NPC 占位精灵** 与 A036 头像风格统一
- [x] **A035/A036 Hub 头像 + 对话框** 色板一致
- [x] **SilencedWeb 程序化绘制** 使用 STYLE_GUIDE 6 个色板色
- [x] 21 个关键资产全部存在并可加载

#### D) 风格漂移评估
> 抽查 5 个最近 4 轮新增素材

| 资产 | 色板命中 | 几何/构图 | 描边 | 调色温度 | 评分 |
|------|----------|----------|------|----------|------|
| A038 Cut 图标 | ✓ | 水平斩击 + 锋利碎片 | ✓ 1px | 中性偏冷，闪光点暖 | 95/100 |
| A037 NPC 占位 | ✓ | 圆形头 + 矩形身 | ✓ 1px 黑 | 暖头 + 冷身 | 90/100 |
| A036 Archivist 头像 | ✓ | 长袍+手杖 | ✓ 1px | 冷紫 + 暖橙 | 92/100 |
| A033 Bind 图标 | ✓ | 螺旋 + 拖尾 | ✓ 1px | 中性冷 | 90/100 |
| SilencedWeb 程序化 | ✓ | 矩形网 + 交叉线 | ✓ 1px | 冷紫腐蚀 + 暖光 | 88/100 |

**结论：无风格漂移。** 最近 4 轮新增资产全部符合 STYLE_GUIDE 宪法。

#### E) 文档同步
- [x] ROADMAP T001-T040 全部完成（无 `- [ ]`）
- [x] CHANGELOG 含 #1-#18 完整记录
- [x] README 控制表已含 Bind + Cut
- [x] ASSET_REGISTRY 含 A001-A038 全部登记
- [x] data/rooms/README.md 已文档化 silenced_web
- [x] ITERATION_COUNT.txt = 18

### 发现问题

#### [严重] S-01: Cut 能力无法触发 SilencedWeb（物理查询层不匹配）
- **位置**：`src/scripts/cut_ability.gd:104` + `src/scripts/silenced_web.gd:21`
- **现象**：Cut 物理查询 `collision_mask = 0b11100`（Layer 3 Enemy + Layer 4 Hazard + Layer 5 Interactable），但 SilencedWeb 位于 `collision_layer = 1`（World Layer 1）。结果：物理查询根本不会返回 SilencedWeb，`on_cut_triggered()` 永远不会被调用。Pulse 同理无法推到 Web（设计上允许，但注释误导说"作为 hazard 处理"）。
- **影响**：T039 的核心交付场景"用 Cut 斩开腐蚀丝网"在游戏中**完全失效**。玩家按 L 切网，没有任何反应。T040 图标已就位但能力无法演示。
- **修复方向**：在 `CutAbility._perform_cut_hit_check()` 中额外按 `corruption_chain` 组迭代（与 enemies 相同的弧度过滤），或把 SilencedWeb 改到 Layer 4 (Hazard) 并把 physics_mask 同步调整。
- **下轮处理**：T041 [严重] 必修

#### [一般] G-01: AudioManagerEnhanced 缺少 Cut / Bind / 修复成功的音效
- **位置**：`src/scripts/audio_manager_enhanced.gd`
- **现象**：`play_damage()` 每次调用都重新生成 `AudioStreamWAV`（应缓存为 `_damage_stream`）。Cut / Bind / SaveLantern / AbilityGate 触发时无对应音效（`play_repair_success` 是软引用 no-op，Cut/Bind 完全没有调用）。
- **影响**：三动词听觉反馈不均衡，玩家只能听到 Pulse 与脚步声，破坏"音频是动词感官表达"的设计原则（来自 P023 音频设计）。

#### [一般] G-02: Bind 暂停语义未落地（apply_bind 死代码）
- **位置**：`src/scripts/bind_ability.gd:127-132`
- **现象**：`bind_ability.gd` 调用 `enemy.apply_bind(duration)`，但全部三个敌人脚本（silence_mote / note_wisp / ink_warden）均**未实现**该方法。所有敌人走 damage=0 + pull 的 fallback 分支。
- **影响**：Bind 实际上"不暂停敌人"，仅做零伤牵引。设计文档暗示的"暂停"语义在游戏中不存在，但 HUD 冷却条照常显示，可能误导玩家。
- **修复方向**：在 enemy 基类/各 enemy 中实现 `apply_bind(duration)` 状态机，或将 bind_ability.gd 文档化注释说明当前是"软绑定"。

#### [一般] G-03: silenced_web 误标 hazards 组 + 误导注释
- **位置**：`src/scripts/silenced_web.gd:22`
- **现象**：注释 `# Treated as hazard for pulse` 但 `add_to_group("hazards")` 后 pulse_ability 通过物理查询 Layer 4 找到 hazards，silenced_web 在 Layer 1，**永远查不到**。组是死成员。
- **影响**：代码可读性差，pulse 与 silenced_web 的交互规则不清晰。
- **修复方向**：移除 `add_to_group("hazards")`，注释改为 `# Cut-only obstacle; pulses pass through`；与 S-01 修复合并实施。

#### [轻微] M-01: pulse_icon.png 路径重复
- **位置**：`assets/sprites/pulse_icon.png` + `assets/ui/pulse_icon/pulse_icon.png` 双份
- **修复方向**：HUD 已引用 `assets/sprites/pulse_icon.png`；保留 sprites 路径，删除 `assets/ui/pulse_icon/` 目录（与 Bind/Cut 的统一 ui 目录分离是历史遗留），或反向统一到 ui 目录。
- **本次顺手修复**：✅ 已确认两侧内容一致（MD5 相同），建议下轮做最终整理，本轮不破坏引用。

#### [轻微] M-02: hub_controller 档案管理员对话未提及 Cut
- **位置**：`src/scripts/hub_controller.gd`
- **现象**：对话只提 Pulse 和 Bind，T039 添加 Cut 后未同步更新教程。
- **本次顺手修复**：✅ 已添加 Cut 说明句

#### [轻微] M-03: ink_warden._process_chase modulate 判定 no-op
- **位置**：`src/scripts/ink_warden.gd:152-154`
- **现象**：条件 `_sprite.modulate == Color.WHITE` 与赋值 `Color("#E86D5A").lerp(Color.WHITE, 0.3)` 不变量，逻辑死分支。
- **本次顺手修复**：✅ 已简化为每帧重新应用 chase tint

#### [轻微] M-04: room_transition.fade_in 未发 transition_finished
- **位置**：`src/scripts/room_transition.gd`
- **现象**：`fade_out` 通过 tween_callback 发信号，`fade_in` 不发，外部监听 fade_in 完成的代码会卡住。
- **本次顺手修复**：✅ 已在 fade_in 末尾补发（带 `not get_tree().paused` 保护）

#### [轻微] M-05: `icon.svg` 项目图标偏 Pulse 风格
- **位置**：`icon.svg`
- **现象**：项目图标使用 Pulse 同心圆 + 中央 Coral 圆点，作为游戏整体标识不具代表性。三个 verb 各有图形，但游戏图标只展示一个。
- **修复方向**：下轮抽空重做为「三 verb 组合徽章」（P + B + C 三角符号）。优先级低。

#### [轻微] M-06: silenced_web 放置位置在 archive_01.json 偏弱
- **位置**：`data/rooms/archive_01.json` `position: [380, 200]`
- **现象**：丝网位于 y=200 地面，但 Platform3 在 [400, 140]，玩家可从上方跳过去，无需用 Cut。下次手动测试可能发现"切网无关紧要"。
- **修复方向**：下个房间（archive_03）补一个战略放置的丝网，必须用 Cut 才能通过。

#### [轻微] M-07: JSON 房间内容在 archive_03 没有 silenced_web
- **位置**：`data/rooms/archive_03.json` interactables 数组
- **现象**：archive_03 已被 ITERATION_GUIDE 暗示为「最终房间」（game_flow_controller 的 `_is_final_room` 检查 `archive_final` 这个不存在的 id），但 archive_03 实际只是个普通房间，没有任何最终房间标识，且没有 silenced_web。
- **修复方向**：与 S-01 修复同步，archive_03 添加战略性 silenced_web 作为终极测试。

#### [轻微] M-08: AbilityGate / SaveLantern 引用不存在的 `play_repair_success`
- **位置**：`src/scripts/save_lantern.gd:94-95` + `src/scripts/ability_gate.gd:67-68`
- **现象**：`AudioManagerEnhanced.has_method("play_repair_success")` 永远返回 false（`play_repair` 是真实方法名），调用静默 no-op。修复时无音效。
- **修复方向**：与 G-01 一并修复，添加 `play_repair_success` 音效。

### 风格漂移评估（汇总）
- **整体一致性**：高。最近 4 轮（T033-T040）所有新增美术资源、UI 图标、VFX 视觉均严格遵循 STYLE_GUIDE 色板（#081426 #1D6570 #69C7CE #B7E7DD #E86D5A #F2B66E #65506A #E6D5B8）与几何规范（1px 黑描边 / 32x32 图标 / 程序化像素）。
- **三动词视觉差异性**：✓ Pulse（圆环扩散）/ Bind（向内螺旋）/ Cut（水平弧斩）三种 VFX 各具形态，颜色区分明显（Amber / Muted Violet / Coral）。
- **结论**：**无风格漂移**。本项目可视为「风格稳定」状态。

### 结论
- **状态：需修复后再继续** ⏸
- **必修（严重）**：
  1. S-01 修复 Cut 触发 SilencedWeb（**下轮 T041 不可绕过**）
- **建议（一般）**：G-01/G-02/G-03 合并到 T041 一并修复（共 ~30min 投入）
- **本次已修复轻微问题**：M-02 / M-03 / M-04 共 3 项
- **可推迟**：M-01 / M-05 / M-06 / M-07 / M-08
- **下一轮强制任务**：T041 [严重] Cut ↔ SilencedWeb 物理层修复 + 三动词音效补齐 + apply_bind 语义实现

### 关键指标
- **资产数**：38
- **代码行数**：~4,200 行 GDScript（19 个 Scene + 38 个 Script）
- **ROADMAP 完成度**：40/40 = 100%
- **REJECTED 累计**：0
- **本次审查时长**：~25 min（数据收集 18min + 报告书写 7min）
- **本次顺手修复**：3 项轻微问题（M-02 / M-03 / M-04）
