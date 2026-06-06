# Roadmap

## 当前方向

工作标题：**Voxglass**

目标：做一款可下载的 2D 独立游戏竖切，不做 Web 小游戏。首个里程碑是一个能在 60 秒内展示「进入房间 -> Pulse 声波反制 -> 修复玻璃声匣 -> 开门」的可玩原型。

## 任务队列

- [x] T001 Code 搭建 Godot 4.x 项目骨架、主场景、输入映射与 480x270 内部分辨率 (45min)
- [x] T002 Code 实现 Saya 移动、跳跃、下落缓冲、土狼时间与镜头跟随；碰撞盒不包含声匣/披肩外轮廓 (50min) <!-- 依赖:T001 -->
- [x] T003 Art 根据 A007-A009 制作 Saya 左/右朝向 idle/run/jump 占位 spritesheet，左臂声匣不得镜像错位 (45min) <!-- 依赖:T001 -->
- [x] T004 Code 实现 Pulse 声波动作：短前摇、圆环判定、击退、玻璃锁触发 (50min) <!-- 依赖:T002 -->
- [x] T005 Art 根据 A003/A012/A017 制作首个回声档案馆 tile proxy 图集与背景分层 (45min) <!-- 依赖:T001 -->
- [x] T006 Code 实现单房间灰盒：平台、浅水危险区、声匣门、修复目标 (50min) <!-- 依赖:T002 -->
- [x] T007 VFX 根据 A014 制作 Pulse 圆环、玻璃裂纹亮起、修复成功暖色波形特效 (45min) <!-- 依赖:T004 -->
- [x] T008 Code 根据 A011 实现 silence mote 敌人：巡逻、波形预兆、可被 Pulse 击退/净化 (50min) <!-- 依赖:T004 -->
- [x] T009 UI 根据 A015 实现 HUD：生命、共鸣能量、Pulse 冷却、声匣修复提示 (40min) <!-- 依赖:T004 -->
- [x] T010 Code 实现房间完成奖励：共鸣碎片计数、修复动画、门开启状态 (45min) <!-- 依赖:T006,T008 --> <!-- 2026-06-02 12:00 -->
- [x] T011 Docs 写首版 Steam 页面定位：一句话卖点、短描述、标签、首屏截图清单 (35min) <!-- 依赖:T006 --> <!-- 2026-06-02 12:00 -->
- [x] T012 Code 打包首个 60 秒竖切：开始房间、1 个敌人、1 个声匣、1 扇门、失败/重试 (55min) <!-- 依赖:T007,T009,T010 --> <!-- 2026-06-02 12:40 -->
- [x] T013 Art 从 A011/A013/A014/A015 切分或重绘第二轮核心素材：silence mote spritesheet、voice bell 修复前后、Pulse icon (50min) <!-- 依赖:T003,T005 --> <!-- 2026-06-02 13:00 -->
- [x] T014 Review 第 5 轮审查：核心循环、手感、可读性、风格漂移与文档同步 (45min) <!-- 依赖:T012 --> <!-- 2026-06-02 12:20 -->
- [x] T015 Code 补充 icon.svg 与项目图标 (15min) <!-- 2026-06-02 12:40 -->
- [x] T016 Code 实现开始菜单与暂停菜单 (40min) <!-- 依赖:T012 --> <!-- 2026-06-02 12:40 -->
- [x] T017 Art 生成 Saya 正式版 idle/run/jump 左右朝向 spritesheet（替代 A019 占位） (55min) <!-- 依赖:T003 --> <!-- 2026-06-02 14:00 -->
- [x] T018 Code 实现第二个房间变体：不同平台布局、新增 note wisp 敌人 (50min) <!-- 依赖:T012,T013 --> <!-- 2026-06-02 14:00 -->
- [x] T019 VFX 增强：环境粒子（水面浮光、灰尘）、声匣修复后房间色调渐变 (40min) <!-- 依赖:T007 --> <!-- 2026-06-02 15:00 -->
- [x] T020 Audio 设计音效占位系统：Pulse 回声、脚步声、玻璃碎裂、敌人低鸣 (35min) <!-- 依赖:T004,T008 --> <!-- 2026-06-02 15:00 -->
- [x] T021 Art 生成 NoteWisp 正式版精灵素材 (30min) <!-- 依赖:T018 --> <!-- 2026-06-02 15:00 -->
- [x] T022 Code 实现房间切换与进度持久化 (40min) <!-- 依赖:T018 --> <!-- 2026-06-02 16:00 -->
- [x] T023 Code 玩家受击无敌帧、屏幕震动与受伤音效；敌人受击闪烁增强 (35min) <!-- 2026-06-02 17:00 -->
- [x] T024 Art 生成 Saya 左朝向正式版 spritesheet（独立绘制，非镜像，替代 A027 临时版） (45min) <!-- 依赖:T017 --> <!-- 2026-06-02 17:00 -->
- [x] T025 Code 实现第三个房间变体 archive_03：垂直阶梯平台 + 混合敌人（2 SilenceMote + 1 NoteWisp）+ 双水域 (40min) <!-- 依赖:T018,T022 --> <!-- 2026-06-02 17:00 -->
- [x] T026 Code 实现存档检查点（Save Lantern）+ 死亡重生点 (35min) <!-- 2026-06-02 18:00 -->
- [x] T027 Code 增强 SilenceMote AI：追击状态 + 净化后掉落 (30min) <!-- 2026-06-02 18:00 -->
- [x] T028 Art 生成存档灯笼素材 + 检查点 VFX (25min) <!-- 依赖:T026 --> <!-- 2026-06-02 18:00 -->

## 新增任务池

- [x] T029 Code 实现共鸣碎片拾取物（ResonanceShard）：掉落物物理、吸引、收集动画 (30min) <!-- 2026-06-02 19:00 -->
- [x] T030 Code 实现精英敌人 InkWarden：高血量、护盾、破盾后眩晕 (50min) <!-- 2026-06-02 20:00 -->
- [x] T031 Art 生成 InkWarden 精英敌人素材 (35min) <!-- 2026-06-02 20:00 -->
- [x] T032 Code 实现第二个声波能力 Bind（牵引/暂停）：新输入键、新 VFX、新交互 (55min) <!-- 2026-06-02 20:00 -->
- [x] T033 Code 实现能力门系统：需要特定能力解锁的通道 (40min) <!-- 2026-06-02 21:00 -->
- [x] T034 Art 生成 Bind 能力图标与 VFX 素材 (30min) <!-- 2026-06-02 21:00 -->
- [x] T035 Code 实现 Hub 区域：安全区、NPC 对话框架、能力选择 (50min) <!-- 2026-06-02 22:00 -->
- [x] T036 Art 生成 Hub NPC 头像与对话 UI (35min) <!-- 2026-06-02 22:00 -->
- [x] T037 Code 实现设置菜单：音量、分辨率、按键重映射 (35min) <!-- 2026-06-02 19:00 -->
- [x] T038 Code 实现关卡编辑器支持：房间配置 JSON 化 (45min) <!-- 2026-06-03 10:00 -->
- [x] T039 Code 实现 Cut 声波能力（第三动词）：短前摇、弧形判定、切断腐蚀链、贯穿伤害 (50min) <!-- 2026-06-03 11:00 -->
- [x] T040 Art 生成 Cut 能力图标素材 (20min) <!-- 2026-06-03 11:00 -->

- [x] T041 Code 实现玩家统计与成就系统：PlayerStats autoload、8 个成就定义、暂停菜单统计面板、屏幕中央成就通知 (45min) <!-- 2026-06-03 12:00 -->
- [x] T042 Code Tutorial 引导提示控件：屏幕底部淡入淡出文字、archive_01 接入 3-4 条首次提示 (15min) <!-- 2026-06-03 12:00 -->
- [x] T043 Bug 修复 Godot 4.6.3 parse 错误集：8 个 GDScript 文件类型推断 / 命名冲突 + 6 个 PNG 资源（实际是 JPEG 转码）(30min) <!-- 2026-06-03 13:00 -->
- [x] T044 **Review 审查 #21** 代码质量 / 玩法完整性 / 素材一致性 / 文档同步：修复 NoteWisp 不掉碎片、InkWarden 护盾不可视三元 bug、README 描述 (50min) <!-- 2026-06-03 14:00 -->

## 待办任务池（来自审查 #21）

- [x] T045 **[严重]** Code 在 archive_03.json 实例化 InkWarden，并在 hub_room.tscn 放置 InkWarden 剪影 / 雕像作为伏笔，使 `warden_slayer` 成就可达 (40min) <!-- 2026-06-03 15:00 -->
- [x] T046 **[一般]** Code Hub 房间补 GameFlowController 实例：解决 Hub → archive 切换时状态机不一致 (25min) <!-- 2026-06-03 16:00 -->
- [x] T047 **[一般]** Code Hub 房间补 TutorialHint 节点 + 1-2 条 Hub 专属提示（"与档案管理员交谈"） (20min) <!-- 2026-06-03 16:00 -->
- [x] T048 **[一般]** Refactor HubController 仿照 GameFlowController._on_door_entered 模板重写，统一 transition 回调 (20min) <!-- 2026-06-03 16:00 -->
- [x] T049 **[一般]** Refactor RoomDoor.open() / _close() 命名：改为 `enable_trigger()` / `disable_trigger()` 并加注释 (10min) <!-- 2026-06-03 15:00 -->

## 新增任务池（#23 起）

- [x] T050 **[一般]** Audio AudioManager 与 AudioManagerEnhanced 重复 autoload 检查与去重：保留一份作为正式 autoload，另一份仅作为 fallback 包装层 (20min) <!-- 2026-06-03 16:00 -->
- [x] T051 **[一般]** Code main 房间、archive_02/03 房间补 TutorialHint 节点：保证所有非 JSON 房间在手动 .tscn 中也接入了 tutorial_hint (15min) <!-- 2026-06-03 16:00 -->
- [x] T052 **[一般]** Code 修复 game_flow_controller.gd:36 的 add_child 时机问题（`add_child.call_deferred`，消除已知轻微警告） (10min) <!-- 2026-06-03 16:00 -->

## 新增任务池（#25 起）

- [x] T053 Code 完整可玩循环：Hub ↔ 3 个 archive 房间双向闭环。修 3 个 JSON room_door 目标 → hub_room.tscn、hub_room.tscn 扩展为 3 门 (60,210)→archive_01/(240,210)→archive_02/(420,210)→archive_03、RoomDoor 加 door_id 导出、HubController 收集所有门并自动 enable_trigger、GFC 新增 _on_door_with_spawn_entered 入口支持显式 spawn_point、_recover_from_transition 适配 deferred add_child 的 fade_in 时机、room_archive_02.tscn 修复 hazard_water.gd ext_resource id bug (50min) <!-- 2026-06-03 17:00 -->

## 新增任务池（#25 审查）

- [x] T054 **[一般]** Docs A019 PLACEHOLDER 资产清理：删除 `assets/sprites/saya_placeholder_spritesheet.png` + 对应 `.import` 文件，ASSET_REGISTRY 状态从 PLACEHOLDER 改为 DEPRECATED (10min)
- [x] T055 **[一般]** Code HubController 多门 fallback 修复：`next_spawn_point` 默认值改为 `Vector2.ZERO`，未匹配到门时显式 `push_warning` + 落到 GFC 默认取第一个门 (15min)
- [x] T056 **[一般]** Docs godot/README.md 顶部添加"⚠️ 首次解压必须先跑 `--import`"红字提醒，避免后续审查再触发同款 .ctex 缺失级联 (5min)
- [x] T057 **[信息]** Docs project.godot 注释行 `; Godot version: 4.4.1-stable` → `; Godot version: 4.6.3-stable (verified)`，同步 README 描述 (5min) <!-- 2026-06-03 21:00 -->

## 新增任务池（#27 起）

- [x] T058 Code 实现战斗飘字反馈系统（DamageNumber）：单脚本 + .tscn，6 种 Kind（DMG/CRIT/HEAL/PURIFY/SHIELD/MISS），接入玩家受击 + 3 类敌人受击/净化/破盾 (25min) <!-- 2026-06-03 21:00 -->

## 新增任务池（#28 起）

- [x] T059 Art 生成 8 个成就图标素材（程序化像素艺术 16x16）：amber_dot / coral_pulse / amber_shard / three_circles / coral_slash / coral_eye / amber_bell / amber_lantern，色板严格对齐 STYLE_GUIDE，登记 A039-A046 (25min) <!-- 2026-06-03 23:00 -->
- [x] T060 Code 成就图标接入：将 achievement_notification.tscn 的 IconRect ColorRect 替换为 TextureRect，按成就 id 查 icon 路径；暂停菜单统计面板新增「已解锁成就缩略」横向列表显示 16x16 图标 (20min) <!-- 2026-06-03 23:00 -->
- [x] T061 Code Credits 致谢屏 + 标题屏接入：credits_screen.gd/.tscn 单文件可滚动 Label，列出引擎/工具/作者占位，标题屏新增"致谢"按钮 (15min) <!-- 2026-06-03 23:00 -->

## 新增任务池（#29 起）

- [x] T062 **[一般]** Code 程序化 BGM 合成器：在 AudioManagerEnhanced 新增 `_generate_music_track(key, duration)`，合成 3 个主题（title_intro 序章 / hub_warm 安全区 / archive_exploration 探索）—— 沉郁正弦 pad + 钟形琶音 + 玻璃青颤音；新增 `play_music_track(key, fade_ms=1500)` API 支持交叉淡入淡出；Music bus 复用 settings 菜单滑块 (30min) <!-- 2026-06-04 00:30 -->
- [x] T063 **[一般]** Code BGM 场景集成：GameFlowController 新增 `_play_music_for_state(state)`，_enter_state() 末尾根据 state + scene 类型自动切到 title_intro / hub_warm / archive_exploration / 停止；scene 切换时新场景 GFC 重 _ready 自动接管 BGM (25min) <!-- 2026-06-04 00:30 -->

## 新增任务池（#30 审查）

- [x] T064 **[审查]** Review 审查 #30：完整代码质量 / 玩法 / 素材 / 文档 / BGM 路由 / PNG 头校验审计；0 SCRIPT ERROR + 0 runtime ERROR + 38 class_name 唯一 + 84 PNG 合法 + 8 成就图标色板 100% 匹配；严重 0 / 一般 2 / 轻微 0 / 信息 1（ROADMAP 全清空） (50min) <!-- 2026-06-04 01:00 -->
- [x] T065 **[一般]** Docs README 完善：补全 Controls 表（暂停 ESC / 存档自动触发 / 致谢屏入口）+ 新增「Audio Controls」节明示 Music/SFX/Ambience 三 bus 独立滑块 (10min) <!-- 2026-06-04 01:00 -->
- [x] T066 **[一般]** VFX BGM 预热：Title 屏 _ready 时预生成 4 个主题到 `_music_streams` 缓存；首次切换零卡顿 (15min) <!-- 2026-06-04 02:00 -->
- [x] T071 **[候选]** Audio BGM archive_03 专属 BOSS 段衍生主题：InkWarden 出现时切到更激昂版本 (25min) <!-- 2026-06-04 02:00 -->
- [x] T067 **[候选]** Art 第四个 archive 房间 + InkWarden 第二只实例化；补 `warden_slayer` 成就丰富度 (50min) <!-- 2026-06-04 18:00 -->
- [x] T068 [已完成] Code 商店 NPC（Hub silent_merchant）：能力升级 / 永久 buff 购买，与 `full_archive` 成就挂钩 (55min) - **#41 轮**
- [x] T069 **[候选]** Art Steam capsule 三联图：基于 A018 key art 出 616x353 / 460x215 / 1200x630 三档 (30min) <!-- 2026-06-04 04:00 -->
- [x] T070 **[候选]** Code 存档系统持久化磁盘版：user://saves/slot_N.json 写盘 + 读档菜单 (50min) <!-- 2026-06-04 03:00 -->

## 新增任务池（#33 起）

- [x] T070 **[候选]** Code 存档系统持久化磁盘版（落 #33）<!-- 2026-06-04 03:00 -->
- [x] T067 **[候选]** Art 第四个 archive 房间 + InkWarden 第二只实例化（落 #38）<!-- 2026-06-04 18:00 -->
- [x] T068 **[候选]** Code 商店 NPC (Hub silent_merchant) (55min)
- [x] T072 **[候选]** UX Settings 加「删除所有存档」按钮 + 危险操作确认 (15min) — #34
- [x] T073 **[候选]** Art 序章过场：标题屏前 8 秒无声黑屏 + 渐入 + 文字「声音被寂静吞噬」 (30min) — #34
- [x] T074 **[候选]** Docs Steam 商店描述 + 短描述：基于 capsule + 调研写 200 词主文 (20min) <!-- 2026-06-04 14:00 -->
- [x] T075 [候选] Code 玩家死亡动画 (laying down + 慢淡出 1.5s) (20min) <!-- 2026-06-04 14:00 -->
- [x] T076 [候选] Art 第二个 archive 房间二阶段灯光：bell 修好后 0.8s 暖光回流 (25min) <!-- 2026-06-04 17:00 -->
- [x] T077 [候选] Docs README 加「开发路线图」章节 + Roadmap 链接 (10min) <!-- 2026-06-04 14:00 -->

## 新增任务池（#38 起）

- [x] T078 **[候选]** Code Boss 音乐 override 引用计数：AudioManagerEnhanced 新增 `_boss_override_count`，request_boss_music / release_boss_music 改为 ref-counted 语义，使多 Boss 房间（archive_04 双 InkWarden）不会因为第一只死亡就清掉 BGM 段；InkWarden 新增 `_exit_tree` 兜底，在玩家中途退出房间时调用 release_boss_music (20min) <!-- 2026-06-04 18:00 -->

下一轮（#39）建议候选：
- T068 **[候选]** Code 商店 NPC（Hub silent_merchant） — 最后一个候选大任务，Hub 永久 NPC + 能力升级 / 永久 buff 购买 + `full_archive` 成就挂钩 (55min)
- T079 **[候选]** Code 玩家死亡后重生点：默认 Hub safe_room；或新增「继续本房间」开关 (25min)
- T080 **[候选]** Art archive_04 专属 BGM 主题：`archive_boss_dual` 较 `archive_boss` 更激昂（双 Boss 房专属） (30min)

## 新增任务池（#39 起）

- [x] T079 **[候选]** Code 玩家死亡后重生点：默认回 Hub safe_room（保护玩家），Settings → Saves tab 新增「死亡后回 Hub 安全区」开关（默认开）；关闭时回最近存档灯笼（继续本房间经典模式）。GameState 新增 `respawn_to_hub: bool` + `set_respawn_to_hub()` / `get_respawn_to_hub()` API + HUB_SAFE_ROOM_PATH / HUB_SAFE_SPAWN 常量。GameFlowController 修复 _ready 顺序：先检查 _is_transitioning，再走 is_hub_mode 短路（否则死亡回 Hub 不会走 _recover_from_transition，玩家会留在旧场景已释放的位置) (25min) <!-- 2026-06-04 19:00 -->
- [x] T080 **[候选]** Art archive_04 专属 BGM 主题 `archive_boss_dual`：在 _MUSIC_PRESETS 新增条目（BPM 132 / 16 分音符琶音 / 增 5 度 G#3 二次不和谐 / F#6 颤音 / +33-40% 音量），AudioManagerEnhanced 引入 `_BOSS_MUSIC_TIER` 强度分级表 + tier 升级逻辑（短淡入），InkWarden 增 `@export var boss_music_key: String = "archive_boss"`，RoomLoader 透传 `boss_music_key` JSON 字段，archive_04.json 2 只 InkWarden 标 `archive_boss_dual`。登记 A050 (30min) <!-- 2026-06-04 19:00 -->

## 新增任务池（#41 起）

- [x] T068 **[候选]** Code 商店 NPC（Hub silent_merchant）：5 个永久 perk（heart_crystal / resonance_chime / pulse_focus / echo_charm / silence_breaker），GameState 5 个派生字段 + `purchased_perks` 持久化 + `max_health` / `max_resonance` 改 derived，PulseAbility / CutAbility 伤害/半径/击杀回响挂钩，ShopMenu 模态 UI，SilentMerchantNPC 自管交互不接管 HubController，Achievement `full_archive` 解锁额外破寂者；登记 A051 (55min) <!-- 2026-06-05 04:00 -->

## 新增任务池（#42 起）

- [x] T081 **[收尾]** Code/VFX 完成 M12 T076：archive_01.json + archive_03.json opt-in `"atmosphere": true` 字段，全 4 房间均有 bell 修复 0.8s 暖光回流 + 房间完成 2s 暖色覆盖 (5min) <!-- 2026-06-05 12:00 -->
- [x] T082 **[收尾]** Docs godot/README.md "首次解压" 段拆分为方法 A (unzip) + 方法 B (Python `zipfile` 兜底，注释说明 `bad zipfile offset` 沙箱触发场景) + 验证段，落地 #40 审查 F003 (10min) <!-- 2026-06-05 12:00 -->

下一轮（#43）建议候选：

- **T083 [候选]** Docs 实际游戏截图 6 张 headless 捕获脚本 + `docs/screenshots/` + README 截图节（关闭 M10 营销上线最后阻塞） (35-40min)
- T084 [候选] Code Boss 阶段 2：InkWarden 半血后进入第二阶段（视觉变化 + 招式变化）(40min)
- T085 [候选] Art 第三个声波能力 Echo：护盾反弹 (35min)
- T086 [候选] UI 第二轮 Settings polish：5 个 action 重映射 UI 视觉与状态提示 (20min)
- T087 [候选] Audio 第五个 BGM 主题 `archive_dawn`（修复后回响，胜利/Hub 重置时使用）(25min)

## #44 已完成

- [x] T086 [候选] UI 第二轮 Settings polish：5 动作扩到 7 动作 (move_right/bind/cut) / 监听状态 amber 脉冲 (0.4s 双向 tween) / ESC 取消恢复原键名 / 冲突检测 (相同 key 时另一 action 自动释放) / "恢复默认按键" 按钮 + 青色确认闪烁；详见 settings_menu.gd 注释 (§44, UI polish) <!-- 2026-06-05 18:00 -->
- [x] T087 [候选] Audio 第 6 BGM 主题 `archive_dawn`：G major 三和弦 (G3 B3 D4) / 76bpm / 12.6s loop / D6 颤音 / 0.30Hz LFO / 比 hub_warm 略重 bass；GAME_OVER_SUCCESS 状态自动切换 + PlayerStats 在 `full_archive` 成就解锁时主动触发；prewarm 自动包含（dict 迭代）；登记 A052；详见 audio_manager_enhanced.gd 注释 (§44, BGM) <!-- 2026-06-05 18:00 -->

下一轮（#45）建议候选：

- **T084 [候选]** Code Boss 阶段 2：InkWarden 半血后进入第二阶段（视觉变化 + 招式变化）(40min) — review 模式预热
- T085 [候选] Art 第三个声波能力 Echo：护盾反弹 (35min)
- T088 [候选] UX 5 个存档位 / 列表视图 (45min)
- T089 [候选] VFX 屏幕震动 polish (15min)
- T090 [候选] Art 装饰物件 procedural (25min)

## #46 已完成

- [x] T084 [候选] Code Boss 阶段 2：InkWarden 半血后进入第二阶段（视觉变化 + 招式变化）：新增 A054 阶段 2 精灵 + 6 个常量（speed/cool/burst/slam 调优）+ `_enter_phase_2()` 视觉切换 + 调色 tween + 3×RepairVFX 阶段特效 + 顶部 "怒" 飘字 + BGM tier upgrade（archive_boss → archive_boss_dual via AudioManagerEnhanced.request_boss_music）+ `_fire_burst()` 三连发散 + `_tick_slam()` 4.5s 间隔的 AOE 冲撞（0.9s 预警 → SLAM_RADIUS 56 范围 2 伤）+ `_process_patrol/_process_chase` 速度乘数（1.5/1.6）+ 投射物冷却乘数（0.55）+ `_purify` 双 release（1200+600 解决 BGM 计数泄漏）+ `_exit_tree` 二阶段请求兜底（详见 ink_warden.gd 注释 §46, Boss 阶段 2） <!-- 2026-06-06 05:00 -->

下一轮（#47）建议候选：
- T085 [候选] Art 第三个声波能力 Echo：护盾反弹 (35min)
- T088 [候选] UX 5 个存档位 / 列表视图 (45min)
- T089 [候选] VFX 屏幕震动 polish (15min)
- T090 [候选] Art 装饰物件 procedural (25min)
