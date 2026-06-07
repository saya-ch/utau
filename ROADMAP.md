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
- T088 [候选] UX 5 存档位 / 列表视图 (45min)
- T089 [候选] VFX 屏幕震动 polish (15min)
- T090 [候选] Art 装饰物件 procedural (25min)

## #47 已完成

- [x] T089 [候选] VFX 屏幕震动 polish：新增 `src/autoload/screen_shake.gd` autoload，提供 `ScreenShake.shake(intensity, duration)` 与 `ScreenShake.shake_preset(Preset)` API（8 个预设：LIGHT/PULSE/BIND/CUT/DAMAGE/DEATH/BOSS_PHASE2/HEAVY），Timer 高频抖动（30Hz micro-shake）+ Tween 衰减曲线（quad ease-out）保证结束归零；`project.godot` 注册为第 6 个 autoload；player.gd 5 处 inline 震动（pulse/bind/cut/damage/death）+ ink_warden.gd `_enter_phase_2()` 阶段 2 切换全部接入预设，Preset.BOSS_PHASE2 强度 5.0/0.30s 是新增最高强度（详见 screen_shake.gd 注释 §47, VFX polish）<!-- 2026-06-06 10:15 -->
- [x] T090 [候选] Art 装饰物件 procedural：6 个程序化像素小物件（hourglass 12x16 / wave_totem 12x24 / hanging_bell 8x10 / crystal_cluster 16x12 / standing_lantern 8x20 / sound_pillar 8x24）登记 A055-A060，色板严格遵循 STYLE_GUIDE（Archive Blue + Glass Cyan + Amber Voice + Muted Violet + Coral Pulse），1px Ink Navy 描边，每件主精灵 + 4x NEAREST 放大版（共 12 个 PNG + 12 个 .import）；RoomLoader 集成 `_build_decoration()` + `_DECORATION_PATHS` 表，z_index=-1 排在背景上、玩家下；archive_01-04 JSON `decorations` 字段配置 14 个装饰实例（archive_01: 4 件 / archive_02: 3 件 / archive_03: 4 件 / archive_04: 5 件，含对称双 wave_totem 配双 hanging_bell 的共鸣祭坛布局）（详见 room_loader.gd 注释 §47, Decoration；scripts/generate_decorative_props.py）<!-- 2026-06-06 10:15 -->

下一轮（#48）建议候选：
- T085 [候选] Art 第三个声波能力 Echo：护盾反弹 (35min)
- T088 [候选] UX 5 存档位 / 列表视图 (45min)
- T091 [候选] Docs README 增补 python zipfile 兜底命令（T085+#47 F003 落实）(10min)
- T092 [候选] VFX 玩家死亡 freeze-frame (0.15s 慢动作 + 红洗) (20min)

## #48 已完成

- [x] T092 [候选] VFX 玩家死亡 freeze-frame：`player.gd` `die()` 开头 `Engine.time_scale = 0.2` + `sprite.modulate = Color(1.4, 0.45, 0.45)`；0.15s 链入 tween 首位（`tween_interval`）再 `tween_callback(_end_death_freeze_frame)` 恢复 time_scale=1.0；之后接 T075 既有 0.5s lay-down + 1.0s fade-out 红调衰减（"drained red" 而非 flashing red 视觉）；`respawn_at()` 兜底重置 time_scale 防卡死；详见 player.gd 注释 §48 (VFX, 死亡 freeze-frame)
- [x] T091 [候选] Docs README 增补 python zipfile 兜底命令：新增 "Headless Godot Binary Setup" 子节，方法 A（unzip）+ 方法 B（Python `zipfile`）双命令完整照搬 `godot/README.md`；Tech 节 "Local Godot binary" 行加交叉链接；Tech 节 "Death & respawn" 行追加 T092 freeze-frame 描述

下一轮（#49）建议候选：
- **T085 [候选]** Art 第三个声波能力 Echo：护盾反弹图标 A061 (35min)
- T088 [候选] UX 5 存档位 / 列表视图 (45min)
- T093 [候选] VFX 玩家死亡后房间灰阶 (post-death 短暂 0.3s 灰度洗) (15min)

## #49 已完成

- [x] T093 [候选] VFX 玩家死亡后房间灰阶洗：ScreenShake autoload 新增 `flash_grayscale(duration, peak_alpha)` API（顶层 CanvasLayer layer=128 + 全屏 ColorRect + 双向 sine tween 0.05s 最短半周期 + 自清空回调）；`player.gd.die()` 在 T092 freeze-frame 回调 `_end_death_freeze_frame` 之后插入 tween_callback `_flash_death_grayscale_wash` 调 `ScreenShake.flash_grayscale(0.3, 0.55)`；视觉序列：0.15s freeze (red flash) → 0.3s grayscale wash（与 lay-down 0.5s 前 0.3s 重叠）→ lay-down → fade-out；冷灰色调 (0.32, 0.34, 0.40) = Ink Navy + Muted Violet + Deep Teal 去饱和，呼应 Voxglass 沉郁调性。ScreenShake.stop() 也兜底清理灰阶引用 (15min) <!-- 2026-06-06 17:00 -->
- [x] T085 [候选] Art 第三个声波能力 Echo 护盾反弹图标 A061：程序化像素绘制 32x32 + 64x64 双导出。视觉组成为 Glass Cyan 玻璃护盾球体（半透明 + Pale Resonance 高光 + 暖白反光小点）+ 8 方向棱镜折射光线 (Pale Resonance 1px) + 双向 Coral Pulse 反弹箭头（V 形头部）+ Amber Voice 中心暖点 + Ink Navy 圆盘底 + Glass Cyan 1px 外环。色板严格遵循 STYLE_GUIDE，区别于 Pulse (圆环/双色) / Bind (螺旋/暗紫) / Cut (斩/珊瑚) 三动词，形成「四动词」视觉组。代码侧 T085 仅 Art 落地，HUD 接入待 #50+ 写 EchoAbility 类后再做 (35min) <!-- 2026-06-06 17:00 -->

下一轮（#50）建议候选：

- T088 [候选] UX 5 存档位 / 列表视图 (45min)
- T094 [候选] Code EchoAbility 类 + 护盾反弹逻辑：实现 Echo 护盾（短前摇、球形碰撞、0.6s 持续、敌人投射物在护盾上反弹/摧毁） + HUD 第四冷却条 + Bind 模式 (Cut + Echo 形成"四动词") (50min)
- T095 [候选] VFX Echo 护盾生成/破碎 VFX：Echo 护盾施放时玻璃青圆环扩散 + 棱镜光散开 + 反弹命中时 Coral Pulse 闪光 + 护盾破碎时碎片飞溅 (30min)

## #50 已完成

- [x] **[审查]** Review 审查 #50：完整代码质量 / 玩法完整性 / 素材一致性 / 风格漂移 / 文档同步；0 SCRIPT ERROR + 0 runtime ERROR + 42 class_name 唯一 + 68 signal 完整 + 112 PNG 100% 合法头 + A061 Echo 6/6 色板匹配；严重 0 / 一般 0 / 轻微 1（已修：ASSET_REGISTRY A051/A053 表格加粗脱锁）/ 信息 3（ROADMAP 候选池 3 项 T088/T094/T095 推荐 T094 EchoAbility 类） (50min) <!-- 2026-06-06 17:00 -->

## #51 已完成

- [x] T094 [候选] Code EchoAbility 类 + 护盾反弹逻辑：新建 `src/scripts/echo_ability.gd` (218 行) 完整实现第四动词 — 9 个 @export (echo_radius=30/echo_cost=30/cooldown=4.0s/windup=0.08s/active=0.6s/reflect_speed=1.5x/reflect_damage=1/enemy_knockback=120/enemy_stun=0.3s)、4 信号 (echo_fired/echo_hit/echo_blocked/echo_expired)、短前摇-护盾-反弹-失效四阶段、反射追踪 `_reflected_this_cast` 防双反弹、敌人接触推+短致盲、HUD 第四冷却条 (EchoRow/EchoIcon/EchoCooldown，Glass Cyan 配色 #69C7CE)、project.godot `echo` 输入映射（Q + R + 手柄 button 5）、player.tscn EchoAbility 节点、player.gd `_handle_echo/_on_echo_fired/_on_echo_hit/_on_echo_expired` 信号桥接、pause_menu 状态行扩展到 4 动词、settings_menu 7→8 action 重映射（Q=echo 默认键，物理键 81）、credits_screen 列名扩展；PlayerStats 新增 echo_used/echo_reflects 计数 + `record_echo_reflect()` API + `all_abilities_used` 条件同步升级到 4 动词（同时解锁 `triple_voice` 和 `quadruple_voice` 两枚成就，新增 A062 quadruple_voice 成就条目 — 使用 icon_hint=echo_icon 复用 A061 资产）；tools/ 增 2 个冒烟测试脚本（test_echo_smoke.gd 验证 class_name/9 exports/5 methods/4 signals + fresh instance 状态；test_echo_vfx_smoke.gd 验证 trigger/add_bounce_flash + 5 帧 _draw 不抛异常 + lifetime 0.85s 自我 queue_free）；T095 一并落地：新建 `src/scripts/echo_vfx.gd` (180 行) — 8 层视觉组（violet 阴影 / cyan 主体 / cyan rim / pale 高光 crescent / 8 棱镜光线 / amber 中心 / 白色 sparkle / Coral Pulse 反弹闪光）严格遵循 STYLE_GUIDE。0 SCRIPT ERROR + 0 runtime ERROR + 5 帧 _draw 冒烟通过 (50min) <!-- 2026-06-06 18:00 -->

下一轮（#52）建议候选：

- T088 [候选] UX 5 存档位 / 列表视图 (45min)
- T096 [候选] Code Echo 与既有系统交互：NoteProjectile 投射物注册 `enemy_projectiles` 组、NoteWisp/SilenceMote/InkWarden 接触代码路径、AchievementScreen 增加 echo_used/echo_reflects 显示、ShopMenu 调整 echo_charm 文案修正（原 "Pulse kill refunds 5 resonance" 是 T068 笔误，应改为 Echo-related 描述）(40min)
- T097 [候选] VFX Echo 反弹命中时屏幕轻微 cyan flash（区分于 start 的"防御-弹回"和反弹命中的"玻璃碎"瞬间）(15min)

## #52 已完成

- [x] T096 [候选] Code Echo 与既有系统交互（解决 #51 审查 I001/I002）：1️⃣ **echo_charm 笔误修正** (I001) — `data/shop_catalog.json` 把 ID `echo_charm` 的 effect 从 `pulse_kill_refund` (×5) 改为 `echo_radius_bonus` (×8) — 真正让 ID 与效果对得上，description_zh/en 同步重写为 "Echo 护盾判定半径 +8" / "Increase Echo shield radius by 8px"；2️⃣ **GameState 新增 `echo_radius_bonus` 字段** + `get_echo_radius_bonus()` getter + `_recompute_perk_bonuses` 映射（×8/level），`pulse_kill_refund` 字段保留以兼容旧存档（仅读取不写）；3️⃣ **EchoAbility._ready 应用 bonus** — 30.0 base + GameState.get_echo_radius_bonus()，has_method 守卫让 headless 冒烟可跑；4️⃣ **ShopMenu 购买时回写** — 走 "30.0 + get_echo_radius_bonus()" 与 EchoAbility._ready 一致公式，不需 reload 场景；5️⃣ **pause_menu StatReflects 节点** — 新增 "Echo 反弹  X" 标签，绑定 `PlayerStats.echo_reflects`；6️⃣ **note_projectile.gd 加注释** — I002 验证完成 (NoteProjectile 已在 #50 T094 落地时即加入 `enemy_projectiles` 组，SilenceMote/NoteWisp/InkWarden 已在 `enemies` 组)，所以 I002 实质上**已被 #50 解决**，本轮补文档确认现状，让未来新增敌人投射物时知道要在 _ready 里 `add_to_group("enemy_projectiles")` (40min) <!-- 2026-06-06 22:00 -->
- [x] T097 [候选] VFX Echo 反弹命中 cyan flash：1️⃣ **ScreenShake 新增 `flash_color(color, duration, peak_alpha)` API** — 复用 `flash_grayscale` 形态（顶层 CanvasLayer layer=128 + 全屏 ColorRect + 双向 sine tween 0.05s 最短半周期 + 自清空回调），但接受自定义颜色（默认 Glass Cyan #69C7CE = Echo 主题色），与 `_active_grayscale` 平行的 `_active_color_flash` 引用防叠加；`ScreenShake.stop()` 兜底清理；2️⃣ **player.gd._on_echo_hit 在 is_reflect=true 时调 `flash_color(cyan, 0.08, 0.2)`** — 与既有 `_current_echo_vfx.add_bounce_flash(target.global_position)` 双层视觉反馈（护盾 cyan 施法 → 反弹 cyan 屏幕 + coral 命中点）；3️⃣ 灰阶洗、彩色闪共用 CanvasLayer 顶层，互不干扰；3 个新文件变更 (screen_shake.gd/player.gd)，0 文件删除 (15min) <!-- 2026-06-06 22:00 -->

下一轮（#53）建议候选：

- **T088 [候选]** UX 5 存档位 / 列表视图 (45min)
- T098 [候选] VFX Pulse / Cut / Echo 命中时 screen flash_color 颜色主题化（Pulse=Coral Pulse, Cut=Amber Voice, Echo=Glass Cyan）让三大能力视觉组齐整 (25min)
- T099 [候选] Docs 真实游戏截图 6 张 headless 捕获 + `docs/screenshots/` + README 截图节 (35min) — 复评 T083
- T100 [候选] UX 暂停菜单 EchoAbility row 加 _stat_reflects 颜色强调（cyan 高亮 vs 其他 row 灰）让反弹成就更显眼 (10min)

## #53 已完成

- [x] T098 [候选] VFX Pulse/Cut/Echo 命中时 screen flash_color 颜色主题化：1️⃣ **Pulse 命中 Coral Pulse flash** — `player.gd._ready` 新增 `pulse_ability.pulse_hit.connect(_on_pulse_hit)`（has_signal 防御），`_on_pulse_hit(target, _knockback)` 检查 target != null（pulse_ability.gd:126 占位 emit 不触发）后调 `ScreenShake.flash_color(Color(0.91, 0.427, 0.353, 1.0), 0.10, 0.18)` — 暖珊瑚色 0.10s / peak 0.18；2️⃣ **Cut 命中 Amber Voice flash** — `cut_ability.cut_hit.connect(_on_cut_hit)`，`_on_cut_hit(_target)` 调 `ScreenShake.flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)` — 暖琥珀色 0.09s（短于 Pulse 反映 Cut 短促锋利的动词特性）；3️⃣ **Echo 反弹 cyan flash**（#52 T097 已有）保持；4️⃣ **色域分布** — Pulse 暖珊瑚 / Bind 暗紫 / Cut 暖琥珀 / Echo 冷青 4 动词色域互不重叠，HUD 4 冷却条 + 屏幕命中闪一眼可分；5️⃣ 2 个新文件变更 (player.gd + new tools/test_t098_t100_smoke.gd)，0 文件删除 (25min) <!-- 2026-06-06 23:30 -->
- [x] T100 [候选] UX 暂停菜单 EchoAbility row 颜色强调：1️⃣ **pause_menu.tscn StatReflects 行** — `theme_override_colors/font_color` 从暖白 `(0.875, 0.835, 0.784, 1)` 改为 Glass Cyan `(0.412, 0.78, 0.808, 1)`（与 _stat_time 同色），让 Echo 反弹统计在视觉组里跳出来；2️⃣ **pause_menu.gd._refresh_stats() 末尾** — 加 `_stat_reflects.add_theme_color_override("font_color", Color(0.412, 0.78, 0.808, 1.0))` 防御性保持（即使 .tscn 主题被其他脚本覆盖，每次刷新也会回写）；3️⃣ **视觉组对齐** — Echo = Glass Cyan 贯穿（HUD EchoCooldown + 反弹屏幕闪 + 暂停统计行 + 商店 echo_charm 描述），4 动词色域在 4 个界面位置都保持一致 (10min) <!-- 2026-06-06 23:30 -->

## #55 已完成

- [x] T088 [候选] UX 5 存档位 / 列表视图：save_system.gd / save_load_menu.gd SLOT_COUNT 3→5，title_screen.gd range(3)→range(SaveSystem.SLOT_COUNT)，settings_menu.gd 注释去 "3 slots" 字样；新增 list 紧凑视图（每行 28px，单 Label 摘要 + 50/50/32 按钮），card 视图紧凑化（每行 56→44px，按钮 72→56px）；LayoutButton 切换 card↔list + layout_changed signal；save_load_menu.tscn RootPanel 200→360 高，新增 LayoutButton 节点；tools/test_t088_save_slots_smoke.gd 7 项集成断言全 PASS（详见 CHANGELOG #55）<!-- 2026-06-07 11:00 -->
- [x] **[审查]** Review 审查 #55：完整代码质量 / 玩法完整性 / 素材一致性 / 风格漂移 / 文档同步 / BGM 路由 / PNG 头校验 / 5 冒烟测试套件审计；0 SCRIPT ERROR + 0 runtime ERROR + 44 class_name 唯一 + 73 signal 完整 + 112 PNG 合法 + 6 autoload 一致 + 62 ASSET_REGISTRY 记录；严重 0 / 一般 0 / 轻微 1（L001 test_t088_save_slots_smoke.gd.uid 漏提交，本轮修复）/ 信息 3（F001 ROADMAP 候选池基本清空 / F002 CHANGELOG 时间戳 / F003 Godot binary 持久化）。完整报告写入 REVIEW_LOG.md 审查 #55 段（详见 CHANGELOG #55-Review）<!-- 2026-06-07 11:09 -->

## #56 已完成

- [x] T105 [候选] UX SaveLoadMenu 4 档案房进度时间线：`src/autoload/save_system.gd` 新增 `get_save_rooms_completed(slot_id) -> Array`（从存档 JSON game_state.rooms_completed 提取房间 id 数组，空槽/无字段安全返回 []）；`src/scripts/save_load_menu.gd` 新增 `ARCHIVE_ROOMS = [archive_01, archive_02, archive_03, archive_04]` 常量 + 3 个颜色常量（_COLOR_PROGRESS_FILLED Amber Voice / _COLOR_PROGRESS_EMPTY Ink Navy / _COLOR_PROGRESS_BORDER Glass Cyan 0.7a）+ `_make_progress_cell(index)` 工厂（14x6 PanelContainer + StyleBoxFlat 1px 描边，stylebox 引用存 cell meta 供 _apply_progress 切换填充色）+ `_apply_progress(panel, rooms_completed)`（card 视图逐 cell 切换 bg_color）+ `_format_progress_inline(rooms_completed)`（list 视图 BBCode 形式 `[color=#F2B66E]■[/color]`/`[color=#12334A]□[/color]` 4 格 unicode 方块）；`_make_card_panel` 高度 44→56 容纳 ProgressRow + 4 Cell_%d 子节点；`_make_list_row` TitleLbl `bbcode_enabled = true` 让 [color=…]BBCode 生效；`_refresh_card`/`_refresh_list_row` 末尾按存档数据调 `_apply_progress`/`_format_progress_inline`，空槽走 `_apply_progress(panel, [])` 全空；新冒烟测试 `tools/test_t105_save_progress_smoke.gd` 8 项断言全 PASS (25min) <!-- 2026-06-07 13:00 -->
- [x] T106 [候选] Docs README 中文版（Steam 中国市场必要）：新建 `README.zh-CN.md` 完整翻译英文 README（含 Status / Tech / Project Structure / Controls / Screenshots / Save System / Audio Controls / 死亡与重生序列 / 商店系统 / 成就系统 / Development / Headless Godot 二进制设置 / 开发路线图 / 里程碑 M1-M12 / 最近完成的工作 / 下一步阅读 / 房间编辑器 JSON / Credits 与许可 18 节），保留 `data/rooms/archive_01` 英文 key / `EchoAbility` 类名 / `Pulse / Bind / Cut / Echo` 4 动词英文术语（避免开发者切语言时找错文件）；英文 README 顶部 + 底部加交叉链接（「🇨🇳 简体中文版 README 可用」/「🇬🇧 English · 🇨🇳 简体中文版」）；README 末尾新增「Credits 与许可」节（中文版含完整节） (30min) <!-- 2026-06-07 13:00 -->

## #57 已完成

- [x] T109 [候选] UX 暂停菜单成就解锁时间戳：`src/autoload/player_stats.gd` 新增 `_unlock_timestamps: Dictionary`（id → Unix 秒） + `get_unlock_timestamp(id) -> int` + `get_unlocked_achievements_sorted_by_time() -> Array`（返回 `[id, title_zh, description_zh, timestamp]` 4 元组升序）；`_unlock_achievement` 在已有时间戳时不更新（避免反复 _check_achievements 触发时刷新）；`_persist_achievements` 写 `unlock_timestamps: {id: ts}` 字段 + `_load_persistent_achievements` 兼容旧存档（无此字段 fallback `{}`）；`src/scripts/pause_menu.gd._build_achievement_grid` 重写为「已解锁按时间戳升序 + 未解锁按 id 字母序」合并顺序，每个 16x16 图标 tooltip 加 `解锁于 MM-DD HH:MM` 文字（未解锁显示 "—"）；`src/scenes/pause_menu.tscn` 新增 `LatestUnlock` Label（Amber Voice 6pt 暖色，紧贴 AchvGrid 下方）；`pause_menu.gd._refresh_stats()` 末尾填充 `最近解锁：<title_zh>  <时间>`。新冒烟测试 `tools/test_t109_achv_timestamp_smoke.gd` 12 项断言全 PASS (15min) <!-- 2026-06-07 14:00 -->
- [x] T110 [候选] Docs CONTRIBUTING.md 新开发者指南：新建 `CONTRIBUTING.md` (194 行) 9 大节 —— 仓库结构总览 / 首次启动（3 种 Godot 拼合方法 + --import）/ 质量自检（静态 + 运行时 + **7 个冒烟测试套件列表**）/ 提交格式 / 迭代节奏（正常/审查/新增任务）/ 美术资源登记 / 文档同步 5 问 / 故障排查速查表 / 决策记录位置；测试门槛写进贡献指南（新增模块同步加 test_Txxx） (15min) <!-- 2026-06-07 14:00 -->

下一轮（#58）建议候选：
- **T107 [候选]** Code 第 7 主题 BGM `archive_storm`：与 archive_boss 平行但更混沌压迫（双 LFO + 增 5 度不和谐 + F#6 颤音）用于 InkWarden 二阶段或 archive_04 入场 (30min)
- **T111 [候选]** UX PauseMenu 成就 grid 加 hover 高亮：当前 16x16 图标 tooltip 已有，但视觉上未解锁 / 已解锁无明显差异；加 hover 时图标放大 1.5x + 暖色边框，让「最近解锁」更突出 (10min)
- **T112 [候选]** Code 玩家死亡重生 Hub / SaveLantern 二选一选项 T079 校验：玩家开启「死亡回 Hub」+ 关闭「死亡回 SaveLantern」时，依次走「玩家死亡 → GFC._on_player_died → Settings.respawn_to_hub 检查 → GameState respawn_to_hub=true → Hub safe_room」完整路径；当前只有 API 缺少端到端冒烟 (15min)
- **T113 [候选]** Docs README 引用 CONTRIBUTING.md：英文 + 中文 README 顶部 "Development" 节加 CONTRIBUTING 链接，让新协作者能直接定位 (5min)

## #58 已完成

- [x] T113 [候选] Docs README 引用 CONTRIBUTING.md：英文 README 「## Development」节顶部加 `[CONTRIBUTING.md](./CONTRIBUTING.md)` 链接 + 简述 9 节内容（仓库结构 / 3 种 Godot 拼合方法 / 7 冒烟测试套件 / 提交格式 / 迭代节奏 / 美术登记 / 文档同步 5 问 / 故障排查 / 决策记录）；README.zh-CN.md 同步加中文版（涵盖 9 节的中文简述）。CONTRIBUTING.md 9 大节本来就完整，本轮只是把入口暴露给 README 读者，让新协作者不依赖"先看到 CONTRIBUTING.md 文件"才能找到 (5min) <!-- 2026-06-07 15:00 -->
- [x] T111 [候选] UX PauseMenu 成就 grid hover 高亮：`src/scripts/pause_menu.gd` `_build_achievement_grid()` 在创建 TextureRect 时追加 `slot.mouse_filter = Control.MOUSE_FILTER_STOP`（TextureRect 默认 IGNORE，hover 不触发）+ `mouse_entered.connect(_on_slot_hover_in.bind(slot))` + `mouse_exited.connect(_on_slot_hover_out.bind(slot))`；新方法 `_on_slot_hover_in` 做 scale 1.0→1.5x + self_modulate 灰→亮 (1.4, 1.4, 1.4) + modulate 暖色 (1.2, 1.1, 0.9) 0.12s tween (Tween.TRANS_QUAD EASE_OUT)；`_on_slot_hover_out` 恢复 scale + 根据 is_unlocked 回写 modulate/self_modulate（已解锁 → WHITE / 未解锁 → 0.25 灰调）。3 套 tween 用 `tween.set_parallel(true)` 同步过渡丝滑不突兀 (10min) <!-- 2026-06-07 15:00 -->
- [x] T112 [候选] Code 玩家死亡重生 Hub / SaveLantern 端到端冒烟：新建 `tools/test_t112_respawn_hub_e2e_smoke.gd` (213 行) 13 项集成断言 — GameState.respawn_to_hub 字段默认 true / set_respawn_to_hub+get_respawn_to_hub 方法 / HUB_SAFE_ROOM_PATH = "res://src/scenes/hub_room.tscn" / HUB_SAFE_SPAWN = Vector2(240, 210) / setter 切换 round-trip / game_state.gd `if respawn_to_hub and not is_hub:` 分支设 _pending_room_path = HUB_SAFE_ROOM_PATH + _is_transitioning = true + change_scene_to_file / 经典模式分支 player.respawn_at(spawn) 走 checkpoint / Vector2(60, 180) fallback / GFC._ready `if GameState._is_transitioning:` 出现在 `elif is_hub_mode:` 之前 (T079 顺序修复) / T079 注释块 / _recover_from_transition 调 player.respawn_at(_pending_spawn_point) / settings_menu.gd cfg.set_value("gameplay", "respawn_to_hub") / cfg.get_value / GameState.set_respawn_to_hub / settings_menu.tscn 死亡后回 Hub toggle label。**全部 PASS**。冒烟测试数量 7→8 (15min) <!-- 2026-06-07 15:00 -->

## #59 已完成

- [x] **CHANGELOG 同步**：[`CHANGELOG.md`](file:///workspace/CHANGELOG.md) 补全 #57（T109+T110 成就时间戳+CONTRIBUTING）和 #58（T113+T111+T112 README 引用+PauseMenu hover+死亡回 Hub 端到端冒烟）两条本该在那两轮就追加的 CHANGELOG 段。前两轮 git commit 时只更了 ITERATION_COUNT 没更 CHANGELOG 段（过程漏记），本轮一并补齐 (5min) <!-- 2026-06-07 16:00 -->
- [x] T107 [候选] Code 第 7 主题 BGM `archive_storm`：在 [`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) `_MUSIC_PRESETS` dict 新增 `archive_storm` 预设 + `_BOSS_MUSIC_TIER` 新增 `"archive_storm": 3`（严格高于 `archive_boss_dual` 2 级）。设计：E minor（区别于 archive_boss/dual 的 A minor 和声对比）+ BPM 120（介于 boss 108 / dual 132 之间）+ root E1 sub-bass（28，最深"thunder"）+ 4 音 chord E2+G#2+B2+D3（E 小调 + 增 4 度 + 升高 7 度不和谐叠层）+ 16 个 16 分音符琶音 E4 G4 B4 D5 + F#5 peak（chromatic neighbor 半音阶旋风）+ G#6 shimmer（比 dual F#6 高半音"screaming"）+ LFO 0.66Hz/0.85 depth（所有 preset 最深调制）+ shimmer_mod 0.014 激进颤音 + 10.0s 循环（20 拍） + 4 套音量全部上抬（bass 0.34 最重 / arp 0.36 / pad 0.18 / shimmer 0.055）。InkWarden Phase 2 跃迁 [`src/scripts/ink_warden.gd`](file:///workspace/src/scripts/ink_warden.gd:529) `ame.call("request_boss_music", "archive_storm", 600)` 替换原 `"archive_boss_dual"`。自动 tier-upgrade：单 boss（key `archive_boss` tier 1）Phase 2 → 升 tier 3；archive_04 (key `archive_boss_dual` tier 2) Phase 2 → 升 tier 3；已 tier 3 时 no-op。预热自动覆盖（`prewarm_music_streams()` 迭代 dict），0 行其他 API 变更。ASSET_REGISTRY A063 条目登记 (30min) <!-- 2026-06-07 16:00 -->
- [x] T107 冒烟测试 [`tools/test_t107_archive_storm_smoke.gd`](file:///workspace/tools/test_t107_archive_storm_smoke.gd) (198 行) 10 项断言：`_MUSIC_PRESETS` 含 `archive_storm` / 13 个字段齐全 / `_BOSS_MUSIC_TIER["archive_storm"] == 3` / 严格 `> archive_boss_dual 2` / 16 音琶音长度 / E minor root E1 + chord 含 E2 / bass_volume 0.34 是 7 个 preset 最高 / InkWarden Phase 2 调 `request_boss_music("archive_storm", 600)` / chord_midi 4 音不和谐 / `_ensure_music_stream("archive_storm")` 实际生成 ~10s AudioStreamWAV（441000 字节单声道 22.05kHz）。**全部 PASS**。冒烟测试数量 8→9 (10min) <!-- 2026-06-07 16:00 -->

下一轮（#60）建议候选：
- T114 [候选] Code 第 8 主题 BGM `silence_void`：完全静音主题（玩家死亡/转场 fade-out 专用 / 4 秒 0 振幅循环，区别于所有有 BGM 主题的"音乐在场"，表达"空无"）(20min)
- T115 [候选] UX 玩家死亡 UI overlay 增加"上一句碑文"回忆条：fade-in 后 0.4s 之前的话语飘在屏中央 0.6s 渐隐（强化 lore 氛围）(20min)
- T116 [候选] Code 玩家死亡后 InkWarden 残影保留 1.5s 慢动作：残影渐变 alpha 1.0→0 + 颜色 cycle 暖→冷 (15min)
- T117 [候选] Docs 设计文档补充第 8 关 finale 主题的草图：`silence_void → archive_dawn` 二阶段曲式（4 秒空 → 12.6 秒 dawn 渐入）叙事 (15min)

## #56 候选池（已落地，见上）

下一轮（#56）建议候选：
- T103 [候选] Code 第五个能力元素：基于 RESEARCH.md 调性扩展（声音修复主题还可派生 Resonance Wave 群体波或 Whisper 短距减速）(50min)
- T104 [候选] Art 第 5 主题 BGM `archive_storm`：暴风雨主题（用于 InGame 危机时刻或双 Boss 房间，区别于 archive_boss_dual 的"激昂"，偏向"混沌+压迫"）(30min)
- T105 [候选] UX SaveLoadMenu 状态条展示：每个 slot 行追加 mini 时间线（房间进度条 1/4 + 1/4 + 1/4 + 1/4）(25min)
- T106 [候选] Docs README 中文版：基于英文 README 翻译（Steam 中国市场必要）(30min)

## #54 已完成

- [x] T101 [候选] VFX GlassLock 修复成功时 Amber Voice flash_color：1️⃣ **glass_lock.gd._unlock()** 在 spawn repair_vfx 之后、HUD hint 之前插入 `ScreenShake.flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.5, 0.18)`（Amber Voice #F2B66E，0.5s 比 Pulse/Cut/Echo 三动词闪都长，强调"声音回归"的延续性而非命中瞬时反馈）；2️⃣ `has_method` 防御让 headless 冒烟可跑；3️⃣ **色域主题化扩展** — 4 动词屏幕闪（Pulse coral 0.10s / Bind 暂无 / Cut amber 0.09s / Echo cyan 0.08s）+ 1 环境反馈（GlassLock amber 0.5s），"Amber Voice = 修复/胜利"主题贯穿；4️⃣ 1 个新文件变更 (glass_lock.gd)，0 文件删除 (15min) <!-- 2026-06-07 09:00 -->
- [x] T102 [候选] UI PauseMenu 四动词 row 颜色对齐：1️⃣ **pause_menu.tscn StatAbilities 节点** — 加 `bbcode_enabled = true`（让 Label 解释 [color=...] BBCode 标签）；2️⃣ **pause_menu.gd._refresh_stats()** — `_stat_abilities.text` 从 "Pulse X · Bind X · Cut X · Echo X" 改为 BBCode 形式：`[color=#E86D5A]Pulse X[/color]  ·  [color=#65506A]Bind X[/color]  ·  [color=#F2B66E]Cut X[/color]  ·  [color=#69C7CE]Echo X[/color]` — Pulse Coral / Bind Violet / Cut Amber / Echo Cyan，4 动词色域严格对齐 STYLE_GUIDE；3️⃣ 4 个 HEX 100% 匹配调色板，1px 8pt 小字也可读；4️⃣ 视觉组层面：四动词色域在 5 个界面位置都保持一致（HUD 4 冷却条 + 屏幕命中闪 + PauseMenu 4 动词行 + 商店 echo_charm + 成就图标 A025/A033/A038/A061）；5️⃣ 2 个新文件变更 (pause_menu.gd + pause_menu.tscn)，0 文件删除 (20min) <!-- 2026-06-07 09:00 -->

下一轮（#55）建议候选：

- T088 [候选] UX 5 存档位 / 列表视图 (45min)
- T099 [候选] Docs 真实游戏截图 6 张 headless 捕获 (35min) — 复评 T083
- T101 [候选] VFX GlassLock 修复成功时 Amber Voice flash_color（延续四动词色域主题化到环境交互）(15min)
- T102 [候选] UI PauseMenu 四动词 row 颜色对齐（Pulse=Coral Pulse / Bind=Muted Violet / Cut=Amber Voice / Echo=Glass Cyan）(20min)

## #60 已完成（审查）

- [x] **[审查]** Review 审查 #60：完整代码质量 / 玩法完整性 / 素材一致性 / 风格漂移 / 文档同步 / BGM 路由 / PNG 头校验 / 5 冒烟测试套件审计；0 SCRIPT ERROR + 0 runtime ERROR + 44 class_name 唯一 + 73 signal 完整 + 112 PNG 合法 + 6 autoload 一致 + 64 ASSET_REGISTRY 记录；严重 0 / 一般 0 / 轻微 0（无）/ 信息 2（F001 ROADMAP 候选池仍有 4 项可继续 / F002 Godot binary 持久化无解）。**结论：可继续迭代**。完整报告写入 REVIEW_LOG.md 审查 #60 段（267 行）<!-- 2026-06-07 11:00 -->

## #61 已完成

- [x] T114 [候选] Code 第 8 主题 BGM `silence_void`：在 [`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) `_MUSIC_PRESETS` dict 新增 `silence_void` 预设 —— 完全静音 4 秒 0 振幅 loop，bpm=60（与 title_intro 同频以备 T117 finale crossfade），所有 4 个音量通道（arp/pad/bass/shimmer）+ LFO/shimmer 归零；[GFC](file:///workspace/src/scripts/game_flow_controller.gd#L176-L188) `State.GAME_OVER_FAILURE` 由 `stop_music(1200)` 改为 `play_music_track("silence_void", 1200)`（功能等价，但 audio_manager 状态从「流销毁」变为「silence_void 在跑」——给 T117 silence_void → archive_dawn crossfade 留接口）；同时修复潜在 `arp_len == 0` 除零 bug（之前任何空 arp 预设会触发 `% 0` 死循环）：将 arp_envelope 数学挪到 `if arp_len > 0:` 守卫块内。`_MUSIC_PRESETS` 总数 7→8；`prewarm_music_streams` doc 同步更新。ASSET_REGISTRY A050 登记 (20min) <!-- 2026-06-07 12:00 -->
- [x] T115 [候选] UX 玩家死亡 UI overlay 增加「上一句碑文」回忆条：[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 新增 6 句静态 Voxglass 调性碑文（声音会回来/它只是在等 / 你听见寂静了/那就还没结束 / 我数着/每一个被遗忘的音节 / 走慢一点/它们就在脚下 / 修复不是救/是记住 / 下一段路/比上一段短），14pt Label + Amber Voice #F2B66E 暖色 + AUTOWRAP_WORD_SMART；新建 CanvasLayer（layer=64，低于 ScreenShake 128）+ CenterContainer + Label，在 `_build_death_quote_overlay()` 中一次性创建，`die()` tween chain 末尾插入 `tween_callback(_show_death_quote)`；4 个时序常量 `DEATH_QUOTE_FADE_IN=0.4s / HOLD=1.5s / FADE_OUT=0.6s / PEAK_ALPHA=0.85` + 独立 tween（fire-and-forget）以 0.4+1.5+0.6=2.5s 节奏完成；`respawn_at` 调 `_hide_death_quote()` clean kill in-flight tween + 清空 label.text；与 T092/T093 时序关系：碑文是死亡 tween 链里**最后一个**回调，所以是玩家重生前看到的最末一帧 (20min) <!-- 2026-06-07 12:00 -->
- [x] T116 [候选] Code 玩家死亡后 InkWarden 残影保留 1.5s 慢动作：[`src/scripts/ink_warden.gd`](file:///workspace/src/scripts/ink_warden.gd) 新增 `request_afterimage()` 方法 —— 在 `get_tree().current_scene` 创建临时 Sprite2D 复制 boss 当前帧 texture + global_position，scale (1.08, 0.96) 制造「倾斜」感（不完美 clone = 记忆感）；modulate 路径 Hot Coral Pulse tint 起点 `Color(0.91, 0.43, 0.35, 0.85)` → Glass Cyan `Color(0.41, 0.78, 0.81, 0.0)` over 1.5s（冷暖循环 + alpha 0.85→0 = 温热的威胁正在被世界忘掉）；z_index = -2 在活 boss 后面/背景前面；`_is_dead` / `_is_purified` 守卫 + has_method 守卫；[`player.gd.die()`](file:///workspace/src/scripts/player.gd) 头部遍历 `get_tree().get_nodes_in_group("elite_enemies")` 调 `request_afterimage()`，残影在 freeze-frame 0.15s 结束后已在场上，符合「boss 看着玩家倒下」的叙事意图 (15min) <!-- 2026-06-07 12:00 -->
- [x] T114+T115+T116 冒烟测试 [tools/test_t114_t115_t116_death_ux_smoke.gd](file:///workspace/tools/test_t114_t115_t116_death_ux_smoke.gd) 13 项断言全部 PASS：silence_void preset 字段完整 + 0 振幅 byte stream 验证（实际合成 + 全部 0 字节）+ GFC GAME_OVER_FAILURE 路由至 silence_void + GFC GAME_OVER_FAILURE 不再调 stop_music + AudioManagerEnhanced arp-empty 无 %0 bug + Player 有 6 句 _DEATH_QUOTES + Player 有 4 个时序常量 + Player 有 _build_death_quote_overlay + Player 有 _show_death_quote + _hide_death_quote + respawn_at 调 _hide_death_quote + InkWarden 有 request_afterimage + request_afterimage 守卫 _is_dead / _is_purified + player.die() 遍历 elite_enemies。**全部 PASS**。冒烟测试数量 9→10 (5min) <!-- 2026-06-07 12:00 -->

下一轮（#62）建议候选：
- T117 [候选] Docs 设计文档补充第 8 关 finale 主题的草图：`silence_void → archive_dawn` 二阶段曲式（4 秒空 → 12.6 秒 dawn 渐入）叙事 (15min)
- **新增任务模式** 从 [RESEARCH.md](file:///workspace/RESEARCH.md) / [INSPIRATION.md](file:///workspace/INSPIRATION.md) 找新方向

## #62 已完成

- [x] T117 [候选] Code/Audio + Docs 升级：把 T114 留的接口实际落地为 [`audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) `play_music_finale()` API（5 个 `FINALE_*` 常量 + phase 1 `play_music_track("silence_void", 400ms)` + phase 2 `get_tree().create_timer(4.0)` 调度 + `_current_music_key` 启发式 preempt 守卫），GFC `State.GAME_OVER_SUCCESS` 路由改用 `ame.call("play_music_finale")`（替代原直接调 archive_dawn），GAME_OVER_FAILURE 仍走 silence_void；silence_void 注释从 "2 个使用场景" 升级到 "3 个使用场景"；新增 [`tools/test_t117_finale_smoke.gd`](file:///workspace/tools/test_t117_finale_smoke.gd) 15 项断言全 PASS；冒烟测试总数 10 → 11。详见 [CHANGELOG.md #62](file:///workspace/CHANGELOG.md) 段 (30min) <!-- 2026-06-07 18:00 -->

## #63 任务池（新增任务模式 — 从 RESEARCH/INSPIRATION 派生）

ROADMAP 全清空（候选池最后一个任务 T117 已落地），按 ITERATION_GUIDE 步骤 4 进入「新增任务模式」：从 `RESEARCH.md` / `INSPIRATION.md` 找未实现创意，结合代码现状挑 3 个任务 55 分钟内可完成的最小集。

- [ ] T120 [候选] Docs README + README.zh-CN.md 加「Game States」节：列 6 个 State enum 值（TITLE / PLAYING / PAUSED / ROOM_TRANSITION / GAME_OVER_SUCCESS / GAME_OVER_FAILURE）+ 每个状态对应的 BGM 路由 + 触发条件 + `play_music_finale()` 二阶段曲式，让协作者一眼看全 GFC 状态机；同步中英 README (10min)
- [ ] T121 [候选] Refactor audio_manager_enhanced.gd 重构：把 8 个 `_MUSIC_PRESETS` + `_BOSS_MUSIC_TIER` 提取为独立 `src/scripts/audio_presets.gd` const 字典（纯数据 + 长注释），让 audio_manager_enhanced.gd 主文件保持 700 行以下可读；load 方式 `const AudioPresets = preload("res://src/scripts/audio_presets.gd")` 然后 `AudioPresets.MUSIC_PRESETS`；新增 3 个冒烟测试断言（audio_presets 存在 / 8 preset 字段齐全 / 引用一致）(20min)
- [ ] T118 [候选] Audio 第 9 主题 BGM `whisper_hollow`：在 `_MUSIC_PRESETS` dict 新增条目 — 极轻 LFO 0.15Hz / 0.55 深度 / 长音 pad 无琶音 / 极弱 shimmer 0.018 / D minor（D3 root + 4-note chord D3 F3 A3 C4 含 minor 7th）/ BPM 50 / 16.0s 循环（比 silence_void 更"在"但比 archive_dawn 更"远"）；设计上为"无敌人安静区/Hub 扩展"用，让 8 主题色板里多一个"深度静默"档；登记 A065 (25min)

下一轮（#64）建议候选：
- T083 [候选] Docs 真实游戏截图 6 张 headless 捕获（已用 mockup 替代）
- T103 [候选] Code 第五个声波能力（50min，超单轮预算）
- T122 [候选] UX 玩家过场动画扩展（intro 已 8 秒 + 文字，可加音效）

