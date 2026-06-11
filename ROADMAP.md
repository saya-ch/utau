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

## #63 已完成

- [x] T121 [候选] Refactor audio_manager_enhanced.gd 重构：把 9 个 `_MUSIC_PRESETS` + `_BOSS_MUSIC_TIER` 提取为独立 `src/scripts/audio_presets.gd` (304 行) const 字典（`extends RefCounted` + `class_name AudioPresets` + 长 per-preset 设计注释），让 audio_manager_enhanced.gd 主文件从 817 → 614 行（-203 行 / -25%）；load 方式 `const AudioPresets = preload("res://src/scripts/audio_presets.gd")` 然后 `AudioPresets.MUSIC_PRESETS` / `AudioPresets.BOSS_MUSIC_TIER`；新增 16 项冒烟测试断言 `tools/test_t121_t118_audio_presets_smoke.gd` (audio_presets 存在 / class_name / BOSS_MUSIC_TIER 3 项 / MUSIC_PRESETS 9 项 / preload 引用一致 / whisper_hollow 13 字段 / D minor / 空 arp / LFO 0.15Hz 最慢 / silence_void 4 volume 通道 0 / archive_storm tier 3 保留 / 7 pre-existing preset 字段齐全 / ASSET_REGISTRY A065 登记) 全部 PASS (20min) <!-- 2026-06-07 22:00 -->
- [x] T118 [候选] Audio 第 9 主题 BGM `whisper_hollow`：在 `audio_presets.gd` `MUSIC_PRESETS` dict 新增条目 — 极慢 LFO 0.15Hz（6.7s 呼吸周期）/ LFO depth 0.55 / 长音 pad 无琶音 (`arp_midi: []` 同 silence_void 走 arp_len==0 守卫) / 极弱 shimmer 0.018 / D minor（palette 唯一 D-minor 主题）/ 4-note chord D minor 7th voicing F3 A3 C4 E4 (midi [53,57,60,64]) / BPM 50 (最慢 preset) / 16.0s 循环 (匹配 title_intro) / shimmer A5 (81, 比 title_intro A6 低八度) / bass 0.12 + pad 0.08 + shimmer 0.018 + arp 0.0；登记 A065 (25min) <!-- 2026-06-07 22:00 -->
- [x] T120 [候选] Docs README + README.zh-CN.md 加「Game States / 游戏状态机」节：6 个 State enum 表格（TITLE / PLAYING / PAUSED / ROOM_TRANSITION / GAME_OVER_SUCCESS / GAME_OVER_FAILURE）+ 每状态触发 + BGM + 音频 API + 备注；新增 ### BGM Boss Override 子节（4 行 boss tier 路由表：单 Boss tier 1 / 双 Boss tier 2 / Phase 2 tier 3 / 清除 tier 0 + 正交哲学说明）；README + README.zh-CN.md Audio Controls 表 Music 列 7 → 8 主题（+ whisper_hollow + silence_void 提示）；占位引用 `./assets/voxglass-bgm-state-map.png` (10min) <!-- 2026-06-07 22:00 -->

## #64 任务池（新增任务模式 — 从 RESEARCH/INSPIRATION 派生）

#63 候选池三个任务 (T120+T121+T118) 全部完成，#64 继续走「新增任务模式」从 RESEARCH.md / INSPIRATION.md 派生。沙箱限制（无 Xvfb / Godot binary 需 unzip 重建）排除 T083 (35min 真实截图) 与 T103 (50min 第五声波能力超预算)；选 T122 + T123 + T124 三个 55 分钟内可完成的候选。

- [x] T122 [候选] UX IntroCutscene 加 ambient 音效：在 title 屏前 8 秒黑屏 + 渐入期间程序化生成 8 秒 ambient 主题（极低 amplitude sine + 1-2 个 lowpass 噪声层）作为铺垫音乐；调用 `AudioManager.play_sfx` 走 Ambience bus 不覆盖 BGM 路由；保持 ESC 跳过功能可用 (20min) <!-- 2026-06-07 23:00 -->
- [x] T123 [候选] Audio whisper_hollow 路由：扩展 GFC `_play_music_for_state` 当 `root.has_node("HubController")` 且 `GameState.rooms_completed.size() >= 2` 时切 `whisper_hollow` 替代 `hub_warm`（表达"档案已修几间，Hub 沉静"），并在 `release_boss_music` fallback 走 `whisper_hollow` 而不是 `archive_exploration`（让"寂静区"房间有专属主题）(15min) <!-- 2026-06-07 23:00 -->
- [x] T124 [候选] Docs README.zh-CN.md 加 "BGM 9 主题色板" 节：8 行色板对照表（title_intro D 大调 / hub_warm F 大调 / archive_exploration A 小调 / archive_boss A 小调+三全音 / archive_boss_dual A 小调+增5 / archive_dawn G 大调 / archive_storm E 小调+增4+升7 / silence_void 静默 / whisper_hollow D 小调+min7）+ 与 RESEARCH 调性扩展理论映射；同步中英 README (10min) <!-- 2026-06-07 23:00 -->

## #64 已完成

T122 + T123 + T124 三任务在 #64 commit `iter#64: T122 IntroCutscene ambient + T123 whisper_hollow Hub routing + T124 BGM 9-theme palette docs` 落地。代码侧 `intro_cutscene.gd._play_sequence()` 调 `AudioManagerEnhanced.play_intro_ambience()`（新增 API 生成 8 秒 D2+G2 dual-sine drone 走 Ambience bus），`game_flow_controller.gd` 路由 `whisper_hollow` 当 `rooms_completed.size() >= 2` + Hub fallback；文档侧 README.zh-CN.md 新增「BGM 9 主题色板」节（色板表 + 与 RESEARCH 调性扩展理论映射），README.md 同步。本轮 #65 审查发现 #63 T121 重构遗留 4 个 smoke test 未同步更新（详见 REVIEW_LOG.md #65 段），已修复。

下一轮（#66）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min，超单轮预算，可拆 2 轮）
- T125 [候选] Docs 真实游戏截图 6 张 headless 捕获（35min，T083 复评）
- T126 [候选] UX PauseMenu 新增 "Player Profile" 页（成就 + 死亡统计 + 游玩时间）

## #66 已完成（2026-06-07 23:00）

F003 + T126 两任务在 #66 commit `iter#66: F003 smoke consistency checker + T126 Player Profile page` 落地。

- **F003 预防工具**：`tools/check_smoke_consistency.sh` 新增 1 个一致性检查脚本，5 条规则：① `audio_presets.gd` 是 `_MUSIC_PRESETS`/`_BOSS_MUSIC_TIER` 唯一规范源；② `audio_manager_enhanced.gd` 无内联旧形式；③ 使用 `AudioPresets.MUSIC_PRESETS` 运行时访问的测试必须 `const AudioPresets = preload(...)`；④ `SRC_PRESETS` 路径常量（T114 形式）合法；⑤ 旧 `ame_script._MUSIC_PRESETS` 访问模式显式拒绝。CONTRIBUTING.md §3.4 文档化。
- **T126 Player Profile 页**：`src/scenes/pause_menu.tscn` 新增 `PlayerProfilePanel` 居中模态面板（`StyleBoxFlat_profile_bg` 琥珀色描边）+ 8 行标签（玩家名 / 回响时长 / 共鸣消散 / 完成房间 / 4 动词色板 / 收集碎片 / Echo 反弹 / 成就滚动列表 / 关闭按钮）+ `玩家档案` 按钮；`pause_menu.gd` 增 10 个 @onready 变量 + 6 个方法（`_on_profile` 切换 / `_on_profile_close` 关闭 / `_refresh_profile` 刷新 / `_build_profile_achievement_list` 列表构建 / `_add_profile_achv_row` 行构建 / `_refresh_profile_achievement_list` 重新构建）；T109 排序保持：已解锁按时间倒序、未解锁按 id 字典序。`tools/test_t126_player_profile_smoke.gd` 14 个测试全过。
- **质量门**：14 个 `test_*.gd` 全 PASS（13 旧 + 1 新），`check_smoke_consistency.sh` 0 错误，0 SCRIPT ERROR，runtime 0 exception。

F001（`godot/README.md` Python 兜底命令）已在 #63 commit 落地（README §方法 B L43-56），无需重复；T125（headless 真实截图）留作后续轮次。

下一轮（#67，N%5≠0，普通模式）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min，超单轮预算，可拆 2 轮）
- T127 [候选] UX PauseMenu 玩家档案加 "Run #" 编号 + 历史最佳统计（15min，T126 延续）
- T128 [候选] Code SaveSystem 加密/校验和（CRC32）防损坏（25min，D001 类型）

## #67 已完成（2026-06-07 23:00）

T127 + T128 两任务在 #67 commit `iter#67: T127 Run # + 历史最佳 + T128 SaveSystem CRC32 校验和` 落地。

- **T127 Run 编号 + 历史最佳**：`src/autoload/player_stats.gd` 新增 `run_number`（1-based）+ `_best_stats`（4 字段：longest_run_seconds / most_rooms_cleared / most_shards_collected / most_enemies_purified）+ 4 个方法（`get_run_number` / `get_best_stats` 返回防御性副本 / `_update_best_stats_from_current_run` 单调更新 / `_persist_best_stats` + `_load_best_stats` 持久化到 `user://run_history.json` 与成就和存档解耦）；`reset_stats()` 顺序：先 snapshot 当前 run → 再清零累加器 → 再 +1 run_number → 再重置 _run_start_time，确保多次 reset 不丢失成绩。`src/scenes/pause_menu.tscn` 新增 `ProfileRun` + `HSepBest` + `ProfileBestTitle`（"✦ 历史最佳 ✦" Amber Voice 9pt 居中）+ 4 行最佳（暖白 8pt）。`pause_menu.gd` `_refresh_profile` 显示 Run #N + 4 行历史最佳（首次启动全 0 → "—" 占位）。`tools/test_t127_run_history_smoke.gd` 12 个测试全过。
- **T128 SaveSystem CRC32 校验和**：`src/autoload/save_system.gd` 新增 `SAVE_CHECKSUM_KEY` 常量 + 3 个方法（`_crc32_of_string` IEEE 802.3 / zlib / PNG 一致 poly 0xEDB88320 / `_verify_and_unwrap` 解包并验证 / 公开 `get_save_integrity` 返回 `ok/legacy/corrupted/missing/invalid_json`）。`_write_json` 改：包装 `{ data, checksum }` 层；`_read_json` 改：parse 后若顶层含 checksum 走 `_verify_and_unwrap` 验证，旧格式（无 checksum 字段）走 legacy 兼容直接返回顶层 dict，下次 save 自动重写。`tools/test_t128_crc32_smoke.gd` 10 个测试全过（CRC32 已知向量 "123456789" = 0xCBF43926 + 篡改后 _read_json 返回 {} + 旧格式 legacy 兼容 + 4 种 get_save_integrity 状态值 + delete_slot 清理）。
- **数据契约保护**：`_apply_snapshot` / `get_save_info` / `get_save_rooms_completed` / `get_continue_scene_path` 全部从 `_read_json` 拿到的是解包后的 inner data（与旧顶层 dict 同 shape），无调用方需要更新。
- **质量门**：Python regex 静态检查全过（F002 已知问题：沙箱中 Godot binary 不完整，沿用 #60-#66 方案），braces/parens 平衡，class_name 唯一性维持 45 个不变。

下一轮（#68，N%5≠0，普通模式）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min，超单轮预算，可拆 2 轮）
- T129 [候选] UX SaveLoadMenu 显示存档健康度（get_save_integrity 集成，"⚠ 已损坏"标识） (15min)
- T130 [候选] Code PlayerStats 历史最佳融入成就系统（4 个新成就：most_rooms_cleared>=4 / longest_run>=600s 等） (30min)

## #68 已完成（2026-06-08 00:00）

- [x] T129 [候选] UX SaveLoadMenu 显示存档健康度：[`src/scripts/save_load_menu.gd`](file:///workspace/src/scripts/save_load_menu.gd) 新增 3 个 BBCode 健康度常量（`_INTEGRITY_OK_TEXT` ✓ Glass Cyan `#69C7CE` / `_INTEGRITY_LEGACY_TEXT` ⚠ Amber Voice `#F2B66E` / `_INTEGRITY_CORRUPTED_TEXT` ✖ Coral Pulse `#E86D5A`）+ 辅助方法 `_format_integrity_badge(integrity)` 返回 BBCode 形式标识符（unknown 状态返回空字符串）；`_refresh_card` 在 title_lbl 末尾追加 badge（`槽位 N  ✦ ts  [color=...]✓` 形式）+ corrupted 槽位 LoadBtn 强制 disabled（防 CRC32 mismatch 时 `_read_json` 返回空 + 防 UI 读空 dict 崩溃）；`_refresh_list_row` 在 title_lbl 头部追加 badge（`%s[ N ]  ✦ ts  …  [color=...]□□□□` 形式）+ 同样 corrupted 禁用 LoadBtn；HintLabel 末尾追加 `  ·  ✓ 完整  ⚠ 旧版  ✖ 已损坏` 简明图例；色板严格遵循 STYLE_GUIDE。1 个新文件 (smoke test) (15min) <!-- 2026-06-08 00:00 -->
- [x] T130 [候选] Code PlayerStats 历史最佳融入成就系统：[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) `_evaluate_condition` 新增 `best_stat_threshold` 条件类型（从 `_best_stats` dict 读指定字段，float/int 自适应 — `longest_run_seconds` 走 float 路径，其余 3 个走 int 路径）；[`data/achievements.json`](file:///workspace/data/achievements.json) 新增 4 个成就（9 → 13 = 9 旧 + 4 新）：**long_road** (longest_run_seconds ≥ 600s, 10min 单次 run 里程碑) / **archive_master** (most_rooms_cleared ≥ 4, 全 4 间档案馆通关) / **resonance_hoarder** (most_shards_collected ≥ 50, 单次 run 50 枚碎片) / **silence_hunter** (most_enemies_purified ≥ 20, 单次 run 20 净化)，icon_hint 复用 4 个现有资产（amber_lantern / amber_bell / amber_shard / coral_pulse）保持视觉组一致；`#68 跨 run metaprogression 4 个里程碑`，成就总数 9 → 13。1 个新文件 (smoke test) (30min) <!-- 2026-06-08 00:00 -->

下一轮（#69，N%5≠0，普通模式）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min，超单轮预算，可拆 2 轮）
- T131 [候选] UX 暂停菜单 Player Profile 增补"最近 N 局趋势"行（5/10/20 局房间完成/死亡/碎片平均），与 T127 Run # + 历史最佳延续 (25min)
- T132 [候选] Code SaveSystem 备份/恢复 API：copy_slot(src, dst) 实现快速克隆存档（settings 菜单"导出/导入"基础）(20min)

## #69 已完成（2026-06-08 01:00）

- [x] T131 [候选] UX 暂停菜单 Player Profile 增补"最近 N 局趋势"行：[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) 新增 `_run_history: Array` + 常量 `_RUN_HISTORY_MAX := 20`（FIFO cap） + 3 个新方法（`_capture_run_into_history` 在 `reset_stats()` 开头 capture 当前 run 6 字段摘要 / `get_run_history` 防御性副本 / `get_recent_runs(n)` 返回最后 N 条 / `get_recent_runs_average(n)` 返回 4 字段平均 + sample_count，零样本时返回空 dict）；持久化字段扩展 `_persist_best_stats` 写入 `run_history` + `_load_best_stats` 逐条 dict 校验，缺失字段 fallback `[]` 兼容 #67 T127 旧存档。关键修复：`Array.slice(begin, end)` 的 `end` 是 exclusive 上界，必须传 `_run_history.size()` 而不是 `_RUN_HISTORY_MAX`（否则多丢 1 条），两处 slice 调用都修正。[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) PlayerProfilePanel/ProfileVBox 新增 4 个节点（`HSepTrend` 分隔线 + `ProfileTrendTitle` "✦ 近 N 局平均 ✦" Amber Voice 9pt 居中 + `ProfileTrend5/10/20` 3 档趋势行 7pt Glass Cyan dim 系 autowrap）。[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 3 个 `@onready Label` ref + `_refresh_trend_row(target, n)` 格式化（房/净/碎/死/时/n 6 字段，零样本 "—" 占位，0 值 "0" 截断）。1 个新文件 (smoke test) (25min) <!-- 2026-06-08 01:00 -->
- [x] T132 [候选] Code SaveSystem 备份/恢复 API：[`src/autoload/save_system.gd`](file:///workspace/src/autoload/save_system.gd) 新增公开方法 `copy_slot(src: int, dst: int) -> bool` — byte-level 复制（用 `DirAccess.copy_absolute` 绕开 `_build_snapshot/_apply_snapshot` 让 byte-perfect 复刻，CRC32 校验和跟随走）；4 边界检查（src 非法 / dst 非法 / src==dst no-op / src 不存在）+ 2 emit 分支（成功 `save_completed.emit(dst, true, "copied from slot N")` / 失败 `save_completed.emit(dst, false, "copy failed (err %d)" % err)`）让 SaveLoadMenu 行为与正常 save 完全一致；命名延续 `verb_slot` 风格（`save_to_slot` / `load_from_slot` / `delete_save` / `delete_all_saves`）。1 个新文件 (smoke test，源码扫描 + DirAccess 验证复制语义，因 headless `--script` 模式 save_system.gd:70 GameState 引用编译失败故不直接实例化) (20min) <!-- 2026-06-08 01:00 -->
- **质量门**：22 项 runtime smoke 全 PASS（T131 12/12 + T132 10/10），F002 已解决（沙箱 Godot binary 138MB 完整版通过 `cat z01..z04 + zip` 重建），`check_smoke_consistency.sh` 0 错误 0 警告。

下一轮（#70，N%5=0，**审查模式**）建议候选：
- **审查任务**：完整代码质量 / 玩法完整性 / 素材一致性 / 风格漂移 / 文档同步 / BGM 路由 / PNG 头校验 / 5 冒烟测试套件审计
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min，超单轮预算，可拆 2 轮，审查通过后再启动）

## #70 审查完成（2026-06-08 02:00）

**审查模式触发**：`N % 5 == 0`（70 / 5 = 14，整除）→ 跳至「审查模式」（ITERATION_GUIDE.md §3）。

### 审查范围
- 静态解析 + 运行时冒烟：0 SCRIPT ERROR / 0 ERROR
- 20 个 `test_*.gd` 冒烟测试套件全跑
- 106 个 PNG 头校验 + 6 个 JSON 语法校验
- 45 class_name 唯一性 / 73 signal 拓扑 / 6 autoload 一致
- 0 TODO / FIXME / HACK
- 资源完整性 + 风格漂移 + 文档同步

### 发现 3 个严重问题（**全部本轮已修复**）

#### [严重] D001 — 3 个 smoke test 无法 parse / compile：T127 / T128 / T129
- **现象**：
  - `test_t127_run_history_smoke.gd`：`func _initialize()` 应为 `func _init()`（SceneTree 入口函数名错）+ 6 处 `var best := ps.get_best_stats()` 类型推断失败（ps 为 Node，方法在 PlayerStats 上）
  - `test_t128_crc32_smoke.gd`：`func _initialize()` 同问题 + 类型推断失败 + 试图 `SaveSystemScript.new()` 实例化（headless --script 模式下 save_system.gd:70 GameState 引用编译失败）
  - `test_t129_save_integrity_smoke.gd`：`SaveLoadMenu.new()` 触发了 `SCRIPT ERROR: Compile Error: Identifier not found: SaveSystem`（save_load_menu.gd:318 引用 SaveSystem 顶层标识符，--script 模式 autoload 未初始化）
- **根因**：
  1. T127 / T128 用了 Python 风格的 `_initialize()` 而非 GDScript 的 `_init()`，所以函数体从未被 Godot 调用；同时 `var ps := ps_script.new()` 是 Variant，对 Variant 调方法返回值仍是 Variant，`var x := Variant` 触发"Cannot infer type" parse error
  2. T128 试图 `SaveSystemScript.new()` 实例化 SaveSystem，但 save_system.gd 顶层引用了 GameState autoload 全局标识符，--script 模式不初始化 autoloads 所以编译失败
  3. T129 同上，preload `save_load_menu.gd` 时 `SaveSystem` / `GameState` 找不到
- **修复**：
  - T127：重命名为 `_init`；`var ps: Node = ps_script.new()` 显式类型 + 6 个 `var best: Dictionary = ...` 显式返回类型；测试开头清理残留 HISTORY_PATH 文件（测试隔离）
  - T128：重写为源码扫描 + 内联 CRC32 / 内联 _normalize_int_floats（与 #69 T132 同模式），保留 round-trip + 篡改检测 + 旧格式兼容 + 4 状态 + delete_slot 全部覆盖
  - T129：重写为源码扫描 + 内联 `_classify_integrity()`（与 save_system.gd 4 状态分类同 shape），覆盖 BBCode 颜色 / STYLE_GUIDE 色板 / load_btn.disabled corrupted 路径 / HintLabel 图例中文 / save_load_menu.tscn 容器节点

#### [严重] D002 — SaveSystem CRC32 校验和会误判所有含整数字段的 save 为 corrupted
- **现象**：T128 测试发现 `JSON.parse_string` 把 int `3` 解析为 float `3.0`，所以 `_verify_and_unwrap` 中 `JSON.stringify(data_raw, "  ")` 算出的 CRC32 与写入时不匹配 → `load_from_slot` 返回 `{}` → save_completed 走 "read failed or empty" 错误分支 → 玩家**所有 save 都被判为损坏**！
- **根因**：Godot 4 的 `JSON.parse_string` 把所有 JSON 数字解析为 float（int 与 float 不区分）。而 `_build_snapshot` 输出大量 int 字段（health=3, resonance=100, shards=5, slot_id=0, saved_at_unix=1234567890 等），所以 round-trip CRC32 永远不匹配。
- **修复**：[`src/autoload/save_system.gd`](file:///workspace/src/autoload/save_system.gd) `_verify_and_unwrap` 调用新增 `_normalize_int_floats()` 递归把"无小数部分的 float"转回 int，再算 CRC32。`_normalize_int_floats` 处理：① 递归 dict ② 递归 array ③ float 满足 `v == floor(v) and not is_inf and not is_nan and abs(v) < 9.22e+18` 条件时 `int(v)`，带小数部分的 float 保留。修复后 round-trip byte-identical，篡改仍能正确检测。
- **影响**：T128 引入时（#67 提交）这一 bug 落地，但 #68 #69 审查没被触发（因为 smoke test 本身 parse error，没跑到断言）。本轮 D001 修复后 T128 才能跑 → 立即暴露 D002。**这是本轮最重要的发现：若不在审查模式触发，玩家所有 save 将永久失效。**
- **预防**：`tools/check_smoke_consistency.sh` 新增规则 ⑥："save_system.gd _verify_and_unwrap 必须调用 _normalize_int_floats"，固化这一修复

#### [严重] D003 — PlayerStats.reset_stats() run_number 持久化时机错（写盘时还是旧值）
- **现象**：T127 修复后跑测试发现 `_load_best_stats` 不能 restore `run_number=2`（只拿到 1）
- **根因**：`reset_stats()` 顺序：先 `_update_best_stats_from_current_run()` 持久化（此时 `run_number` 还是 1）→ 之后 `run_number += 1` 到 2 → **没有第二次持久化** → 磁盘上是 run_number=1
- **修复**：[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) `reset_stats()` 末尾增加 `_persist_best_stats()` 调用，把 +1 后的新值写盘
- **影响**：连续多局 run 编号会保持 1（不递增），虽然 T127 单测能跑过但跨会话 Player Profile 显示 Run # 永远是 1。已修。

### 发现的非严重问题（0 一般 / 0 轻微）

### 通过项
- 静态解析 0 错误
- 运行时冒烟 0 错误（除已知 ObjectDB leak）
- 45 class_name 唯一性维持
- 73 signal 拓扑完整
- 6 autoload 一致（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake）
- 106 PNG 100% 合法头
- 0 TODO / FIXME / HACK
- **20 个 test_*.gd 冒烟测试套件全部 PASS（D001 修复后 20/20）**
- 9 主题 BGM 完整 + 单点 `AudioPresets.MUSIC_PRESETS` 访问
- 6 个 JSON 语法正确
- 65 资产注册 + STYLE_GUIDE 色板无漂移
- `tools/check_smoke_consistency.sh` 0 错误 0 警告

### 修复后回归
- 3 个 T127/T128/T129 全部 PASS（12/12 + 10/10 + 10/10 = 32/32）
- D002 fix 验证：t128 round-trip 测试（用真实 _build_snapshot 形态数据，含 11 个 int 字段）byte-identical 通过
- D003 fix 验证：t127 test [9] `_load_best_stats restored run_number = 2` PASS

### 变更文件
- [`src/autoload/save_system.gd`](file:///workspace/src/autoload/save_system.gd)：`_verify_and_unwrap` 调用 `_normalize_int_floats()` + 新增 `_normalize_int_floats()` 22 行方法
- [`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd)：`reset_stats()` 末尾补一次 `_persist_best_stats()` + 注释解释
- [`tools/test_t127_run_history_smoke.gd`](file:///workspace/tools/test_t127_run_history_smoke.gd)：`_initialize` → `_init` + 类型声明 + 测试隔离清理
- [`tools/test_t128_crc32_smoke.gd`](file:///workspace/tools/test_t128_crc32_smoke.gd)：重写为源码扫描 + 内联 helper（与 t132 同模式）
- [`tools/test_t129_save_integrity_smoke.gd`](file:///workspace/tools/test_t129_save_integrity_smoke.gd)：重写为源码扫描 + 内联 `_classify_integrity` 4 状态分类
- `tools/check_smoke_consistency.sh`：新增规则 ⑥ `_normalize_int_floats` 强制存在
- `ROADMAP.md` / `CHANGELOG.md` / `REVIEW_LOG.md`：本段
- `ITERATION_COUNT.txt` 69 → 70

### 结论
- 状态：**可继续迭代**。
- 严重问题 3 项：D001 3 个 smoke test parse error / D002 SaveSystem CRC32 误判（影响所有 save）/ D003 run_number 持久化时机 — **全部本轮已修复**。
- 一般 / 轻微问题 0 项。
- 下一轮（#71，N%5≠0，普通模式）建议候选：T103 第五个声波能力 Resonance Wave（50min 跨轮）/ T133 PauseMenu Player Profile 加 "Quick Stats" 摘要（achievements X/13 + best run time）/ T134 Code 修复 settings 菜单动态 SLOT_COUNT 显示。

## #71 已完成（2026-06-08 03:00）

- [x] T134 [候选] Code 修复 settings_menu 硬编码 SLOT_COUNT：[`src/scenes/settings_menu.tscn`](file:///workspace/src/scenes/settings_menu.tscn) `SaveCountLabel.text` 硬编码 `"当前存档：0 / 3"` → `"当前存档：0 / 5"`（与 #55 T088 升级后的 `SaveSystem.SLOT_COUNT = 5` 一致）；[`src/scripts/settings_menu.gd`](file:///workspace/src/scripts/settings_menu.gd) `_ready()` 末尾新增 `if _save_count_label and _has_save_system_autoload(): _refresh_save_count()` — 调一次让 scene 默认 placeholder 走 `SaveSystem.SLOT_COUNT` 动态格式化，未来 5 → 8 升级时不需要重存 .tscn；新方法 `_has_save_system_autoload()` 守卫 SceneTree 测试 harness 环境（与 player.gd / pulse_ability.gd 同模式）。1 个新文件 (smoke test) (5min) <!-- 2026-06-08 03:00 -->
- [x] T133 [候选] UX PauseMenu PlayerProfilePanel "Quick Stats" 摘要行：[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) `ProfileRun` 与 `HSep1` 之间新增 `ProfileQuickStats` Label（9pt Amber Voice #F2B66E + bbcode_enabled + autowrap），同时 `PlayerProfilePanel` offset_top/offset_bottom -110/+110 → -120/+120 给新行让出 20px 空间（240px 高）；[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 `@onready var _profile_quick_stats` + `_refresh_profile()` 头部格式化单行：`★ [color=#69C7CE]成就 X / 13[/color]  ·  最佳 [color=#F2B66E]mm:ss[/color]  ·  Run #[color=#B7E6DC]N[/color] ★` — 3 个数据点跨场景共享（成就=跨会话解锁 / 最佳=跨 run 持久化 / Run 编号=会话内），是"我的 Voxglass 生涯"的一行总览；首次启动最佳为 "—" 占位（与下方历史最佳块一致）。1 个新文件 (smoke test) (15min) <!-- 2026-06-08 03:00 -->
- [x] T133+T134 冒烟测试 [`tools/test_t133_t134_quick_stats_smoke.gd`](file:///workspace/tools/test_t133_t134_quick_stats_smoke.gd) (256 行) **12 项断言全部 PASS**：ProfileQuickStats 节点存在 / 位置在 ProfileRun 与 HSep1 之间 / 默认文本含 3 数据点（成就/最佳/Run #）/ @onready var / _refresh_profile 填充 / BBCode 调色板对齐 STYLE_GUIDE (Glass Cyan #69C7CE + Amber Voice #F2B66E) / PlayerStats get_unlocked_count() + get_total_count() / PlayerProfilePanel offset -120/+120 / settings_menu placeholder "0 / 5" / _has_save_system_autoload() / _ready() 调 _refresh_save_count() / _refresh_save_count() 用 SaveSystem.SLOT_COUNT。**冒烟测试数量 20→21** (10min) <!-- 2026-06-08 03:00 -->

下一轮（#72，N%5≠0，普通模式）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min 跨轮，可拆 2 轮）
- T135 [候选] UX PauseMenu 玩家档案加 "Share" 按钮：把 Quick Stats 行复制到剪贴板（分享成就截图） (15min)
- T136 [候选] Code SaveSystem 自动保存每 60 秒：玩家不主动存档时仍保留进度（5min）

## #72 已完成（2026-06-08 04:00）

- [x] T136 [候选] Code SaveSystem 自动保存每 60 秒：[`src/autoload/save_system.gd`](file:///workspace/src/autoload/save_system.gd) 新增自动存档子系统 — 5 个常量 `AUTOSAVE_DEFAULT_ENABLED/INTERVAL/SLOT/MIN/MAX`（默认 60s 间隔、目标槽位 0、10-600s 硬边界）、新 `signal autosave_tick(status, slot_id)`（4 状态：ok/skipped/disabled/error）、3 个 getter + 4 个 setter/mutator（含 `trigger_autosave_now()`）、内部 Timer 节点 `process_mode = PROCESS_MODE_ALWAYS`（暂停时也计时，避免陈旧快照）、`_ready()` 调 `_load_autosave_config()` 从 `user://settings.cfg` 恢复、`_do_autosave_tick(reason)` 共享 body + 4 状态机；新私有 `_is_in_gameplay_scene()` 跳过 6 个非游戏场景（title/saveload/settings/credits/intro_cutscene/game_over）防止空游戏状态污染存档；[`src/scenes/settings_menu.tscn`](file:///workspace/src/scenes/settings_menu.tscn) `SavesPanel` 新增 4 个 UI 控件（Label 标题 + CheckBox + HSlider + OptionButton）；[`src/scripts/settings_menu.gd`](file:///workspace/src/scripts/settings_menu.gd) 新增 4 个 @onready + 3 个 signal handler（live-apply）+ 3 个私有方法（`_build_autosave_slot_options` 动态枚举 + `_populate_autosave_controls_from_cfg` cfg/autoload 单一信源 + `_refresh_autosave_interval_label` slider 跟值同步）+ `_save_settings` 末尾写 3 个 autosave key。1 个新文件 (smoke test) (5min) <!-- 2026-06-08 04:00 -->
- [x] T135 [候选] UX PauseMenu 玩家档案加 "Share" 按钮：[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) `PlayerProfilePanel` `ProfileQuickStats` 与 `HSep1` 之间新增 `ProfileShareButton` Button（110x20、9pt Glass Cyan #69C7CE 文本、tooltip 解释字段）；[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 `@onready var _profile_share_btn` + `_ready()` 信号连接 + 新方法 `_on_share_pressed()` + `_format_share_text()` — 按下后 `DisplayServer.clipboard_set()`（带 `has_method` 守卫兼容 headless 测试 harness）写 3 行纯文本到系统剪贴板：`🎵 Voxglass\n成就 X/13  ·  最佳 mm:ss  ·  Run #N\nYYYY-MM-DD`，按钮文本 1.5s 闪 "已复制 ✓" 后还原（失败时闪 "复制失败"，快速连点 timer 重置）。1 个新文件 (smoke test) (15min) <!-- 2026-06-08 04:00 -->
- [x] T135+T136 冒烟测试 [`tools/test_t135_share_smoke.gd`](file:///workspace/tools/test_t135_share_smoke.gd) (182 行) **12 项断言全部 PASS** + [`tools/test_t136_autosave_smoke.gd`](file:///workspace/tools/test_t136_autosave_smoke.gd) (198 行) **12 项断言全部 PASS**。T136 覆盖 5 常量 / autosave_tick / 3 getter / 4 mutator / Timer ALWAYS / _load+_persist / _is_in_gameplay_scene 6 场景 / 4 状态 / tscn 4 UI / 3 signal / 3 cfg key / _clamp 边界。T135 覆盖 tscn 位置（QuickStats↔HSep1）/ @onready / 信号连接 / handler / 3 行结构 / 按钮文本 / 5 占位符（🎵+%d+%d+%s+%d+%04d%02d%02d）/ Glass Cyan 调色板 / 5 字段全含 / 首次启动占位（0/13 · — · Run #1）/ DisplayServer.has_method 守卫 / null 守卫。回归验证 T127 / T128 / T132 / T133+T134 / T135 / T136 全部 6 个相关冒烟测试 12+10+8+12+12+12 = 66 项断言无回归。**冒烟测试数量 21→23** (15min) <!-- 2026-06-08 04:00 -->

下一轮（#73，N%5≠0，普通模式）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min 跨轮，本轮剩余预算适合启动第一半） — 候选累积 5 轮，可优先消耗
- T137 [候选] UX SaveLoadMenu 加 "快速加载最近自动存档" 按钮：自动消费最近 slot 0 时间戳 (5min)
- T138 [候选] Code PauseMenu Quick Stats 行后加 "上次自动存档 HH:MM:SS" 实时刷新 (10min)

## #73 已完成（2026-06-08 05:00）

- [x] T103 [候选] Code 第五个声波能力 Resonance Wave 群体波 — **第一半**（~30min）<br>[`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) 新文件 165 行 — class_name ResonanceWaveAbility, 8 @export 字段（wave_radius=80, wave_cost=50, cooldown=6.0, windup_time=0.10, active_time=0.4, wave_damage=1, enemy_knockback=80, enemy_slow_duration=0.5）, 3 signal（wave_fired origin+radius / wave_hit target+knockback / wave_expired）, 4 阶段（can_wave 锁定重按 → start_wave consume_resonance → windup 0.10s → execute_wave 0.4s 扩散 → apply_wave_to_enemy 一次性 1 damage + 击退 + 复用 BindAbility.apply_bind 0.5s 减速）+ _hit_this_cast 防链击 + PlayerStats.record_ability_used("wave") 统计桥接。<br>[`src/scripts/resonance_wave_vfx.gd`](file:///workspace/src/scripts/resonance_wave_vfx.gd) 新文件 110 行 — 5 阶段动画（0.06s amber-core fade-in + 0.40s 主扩散 + 0.30s 消散），pale resonance #B7E7DD 18% alpha 圆环填充 + glass cyan #69C7CE 2px 外环 stroke + 8 棱镜光线 0.5 rad/s 慢转，per-enemy hit flash 0.20s warm parchment #E6D5B8 5px→1px 衰减，world-space parenting 到 current_scene（玩家移动不拖尾）。<br>[`src/scenes/player.tscn`](file:///workspace/src/scenes/player.tscn) load_steps 9→10 + 6_wave ext_resource + ResonanceWaveAbility 节点 + [`project.godot`](file:///workspace/project.godot) wave input action {V + Enter + 手柄 button 6}（与 echo Q+R+button 5 不冲突）+ [`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) +@onready var wave_ability + 3 signal connect + _handle_wave + _on_wave_fired（preload vfx + add_child + ScreenShake Pale Resonance 0.12s/0.15 + shake_preset PULSE 强反馈）+ _on_wave_hit（add_hit_flash）+ _on_wave_expired。5 verb 色域严格分工：Pulse=Coral 0.91,0.427,0.353 / Bind=Violet / Cut=Amber 0.949,0.714,0.431 / Echo=Cyan 0.412,0.78,0.808 / Wave=Pale Resonance 0.718,0.906,0.867（5 个最浅最冷 = 光波感 区别于 Echo 的"盾感"）。cooldown 6s = 5 verb 中最贵（"群体=重武器"心智模型）。<!-- 2026-06-08 05:00 -->
- [x] T137 [候选] UX SaveLoadMenu "快速加载最近自动存档" 按钮（5min）<br>[`src/autoload/save_system.gd`](file:///workspace/src/autoload/save_system.gd) 新字段 `_last_autosave_unix: int = 0`（session-scoped, 0 = 无数据）+ 新 getter `get_last_autosave_unix() -> int` + `_do_autosave_tick` 末尾 ok=true 时写 `int(Time.get_unix_time_from_system())`。<br>[`src/scenes/save_load_menu.tscn`](file:///workspace/src/scenes/save_load_menu.tscn) TitleLabel 与 HintLabel 之间新增 QuickLoadButton（180x20, 8pt, 默认 hidden）。<br>[`src/scripts/save_load_menu.gd`](file:///workspace/src/scripts/save_load_menu.gd) `@onready var _quick_load_btn` + `_refresh_quick_load_btn()` 3 状态门控（mode=="select" + SaveSystem 存在 + last_unix>0 → visible=true + 文本 "⚡ 快速加载最近自动存档 (HH:MM)"）+ `_on_quick_load()` 走 SaveSystem.get_autosave_slot() + has_save() 双检 + 复用 _on_load 路径 + show_menu() 重算时间戳。<!-- 2026-06-08 05:00 -->
- [x] T138 [候选] Code PauseMenu Quick Stats 行后 "上次自动存档 HH:MM:SS"（10min）<br>[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) ProfileShareButton 与 HSep1 之间新增 ProfileAutoSave Label（8pt Pale Resonance #B7E7DD 文本色 + 居中）。<br>[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) `@onready var _profile_auto_save` + `_refresh_profile()` 末尾 `if last_unix > 0: format("上次自动存档  %02d:%02d:%02d") else: "上次自动存档  —"`，与 SaveLoadMenu 的 HH:MM 区分（PauseMenu session 内高频查看 → 秒级精度）。<!-- 2026-06-08 05:00 -->
- [x] T103+T137+T138 冒烟测试 2 个（[test_t103_resonance_wave_smoke.gd](file:///workspace/tools/test_t103_resonance_wave_smoke.gd) 110 行 **28 项 PASS** + [test_t137_t138_persistence_smoke.gd](file:///workspace/tools/test_t137_t138_persistence_smoke.gd) 130 行 **17 项 PASS**）。T103 覆盖 5 verb 色域分工 + 8 @export + 3 signal + class_name + 4 集成点（player.gd 桥接 + player.tscn 节点 + project.godot wave action + VFX class）。T137+T138 覆盖 _last_autosave_unix 字段 + getter + _do_autosave_tick 写入 + QuickLoadButton hidden + @onready + _on_quick_load + SaveSystem API + PauseMenu _profile_auto_save 位置 + HH:MM:SS 格式 + get_last_autosave_unix 读取。**冒烟测试数量 23→25** (10min) <!-- 2026-06-08 05:00 -->

下一轮（#74，N%5≠0，普通模式）建议候选：
- T103 [候选] Code 第五个声波能力 Resonance Wave 群体波 — **第二半**（HUD 5 行 + settings 重映射 + pause 状态行 + shop perk 5 + 五声回响成就）(~25min 紧凑)
- T139 [候选] UX PauseMenu 玩家档案加 "成就 X/14" 计数（Wave 成就新增后从 13 跳到 14）(5min)
- T140 [候选] Code player.gd _handle_wave 失败时 hud.show_pulse_blocked 改为 hud.show_wave_blocked（10min）

## #74 已完成（2026-06-08 06:00）

- [x] T103 [候选] Code 第五个声波能力 Resonance Wave 群体波 — **第二半**（~25min）<br>[`src/scenes/hud.tscn`](file:///workspace/src/scenes/hud.tscn) load_steps 10→11 + `6_wave_icon` ext_resource + `WaveRow` (HBoxContainer) 节点 + `WaveIcon` (TextureRect 12x12 wave_icon) + `WaveCooldown` (ProgressBar 40x6 Pale Resonance #B7E6DC fill) + `StyleBoxFlat_wave_fill`；[`src/scripts/hud.gd`](file:///workspace/src/scripts/hud.gd) `@onready var _wave_cooldown` + `@onready var _wave_ability` (get_node_or_null "ResonanceWaveAbility") + `_process` 末尾 `_wave_ability.get_cooldown_ratio()` 实时刷新 `WaveCooldown.value` + `show_wave_blocked()` 新方法 (5 动词对称独立 verb 路由)。<br>[`src/scripts/settings_menu.gd`](file:///workspace/src/scripts/settings_menu.gd) `ACTION_NAMES` 加 `"wave": "Wave 群体波"` + `_DEFAULT_BINDINGS` 加 `"wave": {type:key, physical_keycode: 86}` (# V)。<br>[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) `_stat_abilities` 与 `_profile_abilities` 5 动词 BBCode 行扩展 (Pulse #E86D5A / Bind #65506A / Cut #F2B66E / Echo #69C7CE / Wave #B7E6DD 5 色块暖冷梯度末端=光波感) + 注释 13→14 同步更新。<br>[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) 新字段 `wave_used: int = 0` + `get_stat` / `_set_stat` / `_stat_names` / `record_ability_used("wave")` / `all_abilities_used` 条件 (Pulse + Bind + Cut + Echo + Wave all >=1) 全部同步 + `reset_stats` 末尾 `wave_used = 0` 跟随 4 动词。<br>[`src/autoload/game_state.gd`](file:///workspace/src/autoload/game_state.gd) `wave_radius_bonus: int = 0` 字段 + `get_wave_radius_bonus()` getter + `_recompute_perk_bonuses()` 加 `wave_radius_bonus = get_perk_count("wave_focus") * 10`。<br>[`data/shop_catalog.json`](file:///workspace/data/shop_catalog.json) 新增 `wave_focus` perk (price_shards:12, max_purchases:3, effect:{field:wave_radius_bonus, delta:10})。<br>[`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) `_ready()` 末尾 `if GameState and GameState.has_method("get_wave_radius_bonus"): wave_radius += float(GameState.get_wave_radius_bonus())` (mirrors EchoAbility 模板)。<br>[`data/achievements.json`](file:///workspace/data/achievements.json) 新增 `quintuple_voice` 成就 (title_zh:五声回响, icon_hint:wave_icon, condition:all_abilities_used)，成就总数 13→14。<br>新资源 [`assets/ui/wave_icon/`](file:///workspace/assets/ui/wave_icon/) 32x32 + 64x64 PNG (程序化生成) + [`scripts/generate_wave_icon.py`](file:///workspace/scripts/generate_wave_icon.py) 60 行生成器。<!-- 2026-06-08 06:00 -->
- [x] T140 [候选] Code player.gd _handle_wave 失败时 `hud.show_pulse_blocked()` → `hud.show_wave_blocked()` (5 动词对称 verb 专属路由)<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_handle_wave()` 失败分支换方法名。<br>配套 [`src/scripts/hud.gd`](file:///workspace/src/scripts/hud.gd) `show_wave_blocked()` 新方法（文案与 pulse 一致 = "共鸣不足"，但路径独立便于将来扩展专属文案与按 verb 国际化）。<!-- 2026-06-08 06:00 -->
- [x] T139 [候选] UX PauseMenu 玩家档案 "成就 X/13" → "成就 X/14"（5min 嵌套进 T103）<br>[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) `_format_share_text` 注释 13→14 + `_refresh_profile` 注释 13→14 + 新注释说明总成就数用 `PlayerStats.get_total_count()` 动态值，#74 轮新增 quintuple_voice 成就后自动从 13 跳到 14。<!-- 2026-06-08 06:00 -->
- [x] T103 第二半 + T140 + T139 冒烟测试 [test_t103_wave_second_half_smoke.gd](file:///workspace/tools/test_t103_wave_second_half_smoke.gd) (108 行 **10 项 PASS**)。覆盖 8 维度：① GameState.wave_radius_bonus 字段 + getter 0 默认 + 2 购买→+20 ② shop_catalog.json wave_focus entry ③ achievements.json quintuple_voice + wave_icon + 总数 14 ④ PlayerStats.wave_used 字段 + record_ability_used("wave") x2→2 ⑤ hud.tscn WaveRow 节点 ⑥ resonance_wave_ability.gd get_wave_radius_bonus 调用 ⑦ pause_menu.gd 5 动词 BBCode 行（不在 smoke 测覆盖，靠 Godot parse + 回读测试） ⑧ settings_menu.gd wave action (不在 smoke 测覆盖，靠 Godot parse)。回归 [test_t103_resonance_wave_smoke.gd](file:///workspace/tools/test_t103_resonance_wave_smoke.gd) 28/28 PASS + [test_echo_radius_bonus_smoke.gd](file:///workspace/tools/test_echo_radius_bonus_smoke.gd) 11/11 PASS。**冒烟测试数量 25→26** (10min) <!-- 2026-06-08 06:00 -->

下一轮（#75，N%5≠0，普通模式）建议候选：
- T103 [候选] Code wave 提示文案扩展为 wave-specific 提示（如"敌人太多"/"你太近"等 — 当前 5 verb 都共用"共鸣不足"过于通用）(15min)
- T141 [候选] UX wave_vfx.gd 给 hit_flash 加 audio cue（与 hit_signal 同步触发，audio bank 已经预留 audio_bus "Wave"）(10min)
- T142 [候选] Code 补 player.gd 中 _handle_wave windup 期间禁用 dash + 重置防误触（5 verb 链防误触安全网，wave 是 5 verb 中唯一 windup 期不锁移动的，与 pulse 不一致）(10min)

## #75 已完成（2026-06-08 07:00）

- [x] **T130 hotfix** Code 修复 test_t130_best_achievements_smoke 期望 13→14（#74 T103 quintuple_voice 增量未同步）<br>[`tools/test_t130_best_achievements_smoke.gd`](file:///workspace/tools/test_t130_best_achievements_smoke.gd) 头部注释 "9 旧 + 4 新" → "10 旧 + 4 新"，断言 `achvs.size() == 13` → `== 14`；[`tools/test_t135_share_smoke.gd`](file:///workspace/tools/test_t135_share_smoke.gd) 内联 `_format_share_text_3fields(3, 13, ...)` / `(5, 13, ...)` / `(0, 13, ...)` 三处硬编码测试夹具 13 → 14（helper 行为不变，纯粹测试夹具与 #74 实际成就数对齐）。**冒烟测试数量 26→26** (5min) <!-- 2026-06-08 07:00 -->
- [x] **T142** Code 补 player.gd `_handle_wave` windup 期 5 verb 链防误触安全网（10min）<br>[`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) 新增 `is_globally_blocking() -> bool`（仅 windup 期 true，active 扩散期 false — 玩家应能继续施法下一 verb）。<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 4 个其他 verb handler 顶部各加一行 `if _is_wave_globally_blocking(): return`（pulse/bind/cut/echo 早退），新增 helper `_is_wave_globally_blocking() -> bool`（wave_ability null/has_method 双重守卫，headless 测试可加载）。Wave 是 5 verb 中唯一有 0.10s windup 的，pulse/bind/cut/echo 4 个即时 verb 在 windup 期间被抑制防 chain-press 误触双发。**新增 1 个 smoke test** [`tools/test_t142_wave_chain_block_smoke.gd`](file:///workspace/tools/test_t142_wave_chain_block_smoke.gd) 10 项断言全 PASS（is_globally_blocking 4 状态转移 + 4 handler 调用 + 1 helper 存在 + 1 start_wave 无回归）。<!-- 2026-06-08 07:00 -->
- [x] **T141** UX wave_vfx.gd hit_flash 加 audio cue（5 verb 命中听觉反馈对齐，10min）<br>[`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) 新增 `_generate_wave_hit_sfx()`（0.20s 1320Hz 基音 + 2.4x 失谐谐波 = 钟琴"叮"音色，与 glass_break 的噪声+0.5s 区分）+ `_wave_hit_stream` 懒缓存字段 + `_last_wave_hit_time_ms` 时间戳 + `_WAVE_HIT_THROTTLE = 0.05` 常量 + `play_wave_hit()` 公开方法（懒初始化 + 50ms throttle 防止 5 敌人同帧命中 SFX 堆叠成糊音）。<br>[`src/scripts/resonance_wave_vfx.gd`](file:///workspace/src/scripts/resonance_wave_vfx.gd) `add_hit_flash()` 末尾加 `if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_wave_hit"): AudioManagerEnhanced.play_wave_hit()`（autoload has_method 守卫保 headless 可解析）。视觉 Warm Parchment 闪 + 听觉高频钟琴 = wave 命中"双反馈"。**新增 1 个 smoke test** [`tools/test_t141_wave_hit_audio_smoke.gd`](file:///workspace/tools/test_t141_wave_hit_audio_smoke.gd) 9 项断言全 PASS（play_wave_hit 存在 + 流字段 + 波形大小 17640 bytes + 首次播放时间戳 + 50ms throttle 抑制 + 200ms 后恢复 + wave_vfx 调用 + 1320Hz 基音 + 2.4x 谐波）。<!-- 2026-06-08 07:00 -->
- **质量门**：28 个 smoke test 全 PASS（26 旧 + 2 新 + 1 hotfix 修改 0 新增），0 SCRIPT ERROR，0 parse error，runtime 0 exception（headless --script 模式 `play_sfx` 报"Playback can only happen when a node is inside the scene tree" 是已知的 audio 在 SceneTree-only 环境限制，不影响 throttle 单测）。**冒烟测试数量 26→28**。

下一轮（#76，N%5≠0，普通模式）建议候选：
- T143 [候选] UX wave 提示文案扩展为 wave-specific 提示（"共鸣不足" 5 verb 共享过通用，扩展"风蓄中"/"扩散中"等 wave 专属状态文案）(10min)
- T144 [候选] Audio play_wave_hit 节奏变化：随 wave_focus 升级加 higher harmonic（更高频闪）(5min)
- T145 [候选] Code `_is_wave_globally_blocking` 模式应用到 player.gd `_handle_jump` 等等：windup 期玩家不能跳 (5min)

## #75 审查完成（2026-06-09 08:00）

- [x] **Review #75** 完整代码质量 / 玩法 / 素材 / 文档审计（0 严重 / 1 一般已修 / 0 轻微 / 1 信息）<br>**结果**：0 SCRIPT ERROR + 0 runtime ERROR + 47 class_name 唯一 + 77 signal 完整 + 114 PNG 合法 + 6 autoload 一致 + 72 ASSET_REGISTRY + 28 冒烟测试套件 28/28 PASS + `check_smoke_consistency.sh` 6/6 规则 PASS。**修复 G001**：README.md / README.zh-CN.md "Recent completed work" 段补 #61-#75 共 15 轮记录（5 动词 / 9 BGM 主题 / 存档健康度 / Run 编号 / CRC32 / autosave / 5 槽动态 / Quick Stats / 分享 / ResonanceWave 群体波 / 成就 14 项 / 5-verb 链防误触 / Wave 命中 audio cue 等）。**完整报告**：[REVIEW_LOG.md # #75 审查](file:///workspace/REVIEW_LOG.md)。<!-- 2026-06-09 08:00 -->
- **质量门**：28/28 冒烟测试 PASS，文档同步 100%，风格无漂移，5-verb 代码侧完整（pulse / cut / bind / echo / wave），9 主题 BGM 完整，存档系统完整（5-10 槽 / CRC32 / 健康度 / 备份恢复 / 趋势 / 历史最佳 / run_id / 自动存档 60s），死亡 UX 完整（5 段：lay-down / freeze / grayscale / 残影 / 碑文）。

下一轮（#76，N%5≠0，普通模式）建议候选（同步至 REVIEW_LOG.md 与 CHANGELOG.md）：
- T143 [候选] UX wave 提示文案扩展为 wave-specific 提示（player.gd `_wave_off_cooldown_prompt` 三个 verb 专属方法 + 中文/英文 BBCode 提示，~25min）
- T144 [候选] Audio play_wave_hit 随 wave_focus 升级加 higher harmonic（resonance_wave_ability.gd 命中回调随 `pulse_focus` Shop 升级 LFO 倍频，~25min）
- T145 [候选] Code `_is_wave_globally_blocking` 模式应用到 `_handle_jump`（player.gd 抽象 `is_action_globally_blocked` 助手，跳 / 闪避 / 波 都用统一判断，~25min）
- T146 [候选] Polish：wave 命中 hit_count 累计 ≥3 时触发 0.4s `wave_combo` 屏震（屏幕震动 + Electric Violet flash，与 cut_combo / pulse_combo 对齐）

## #76 已完成（2026-06-09 09:00）

- [x] **T143** UX wave 失败提示文案扩展为 wave-specific 4 状态路由（10min）<br>[`src/scripts/hud.gd`](file:///workspace/src/scripts/hud.gd) 在原 `show_wave_blocked()` 旁新增 3 个 verb 专属方法 `show_wave_charging()` (`"Wave 还在蓄势"`) / `show_wave_winding_up()` (`"Wave 正在准备"`) / `show_wave_active()` (`"Wave 横扫中"`)，与 show_pulse_blocked 一致走 show_repair_hint。<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_handle_wave()` 失败分支从 1 句 `hud.show_wave_blocked()` 扩为 4 分支 if/elif 路由：is_wave_active() → show_wave_active；is_winding_up() → show_wave_winding_up；get_cooldown_ratio() > 0.01 → show_wave_charging；兜底 → show_wave_blocked（共鸣不足）。顺序按 wave 生命周期排：active (0.40s) → winding_up (0.10s) → cooldown (6s) → cost-low，3 个 verb 状态互斥不重复 emit。<!-- 2026-06-09 09:00 -->
- [x] **T145** Code `_is_wave_globally_blocking` 模式重构为通用 `is_action_globally_blocked()` 并应用到 `_handle_jump`（15min）<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 把 #75 `_is_wave_globally_blocking()` 私有 helper 重命名为公开 `is_action_globally_blocked()`，OR 上 `_is_dying` 检查（死亡动画 1.5s 期间 + Wave windup 期间都返回 true），未来加 stun/pause 状态只需 OR 一次不用改 N call-site。`_handle_jump` 顶部加守卫并在阻塞时把 `_coyote_timer` + `_jump_buffer_timer` 同时清零（防死亡解除后 buffer 立即消耗导致"原地跳"异常）。4 个其他 verb handler 调用点全部从 `_is_wave_globally_blocking()` 改名为 `is_action_globally_blocked()`。**重构**：[`tools/test_t142_wave_chain_block_smoke.gd`](file:///workspace/tools/test_t142_wave_chain_block_smoke.gd) 同步更新断言到新名字（5 旧检查全部对应新 helper 名字，1 处 helper 存在性 + 4 处 handler 调用）。<!-- 2026-06-09 09:00 -->
- [x] **T146** Polish wave_combo 屏震（≥3 命中触发 0.4s shake + Electric Violet flash，10min）<br>[`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) 新增 `signal wave_combo(hit_count: int)`（在原 wave_expired 信号前一行，与同帧 emit 时序兼容）+ `@export var wave_combo_threshold: int = 3`（默认 3 命中，可从 inspector 调）+ `_deactivate_wave()` 末尾（_hit_this_cast.clear() 之前）判断 `_hit_this_cast.size() >= wave_combo_threshold` 时 `wave_combo.emit(_hit_this_cast.size())`，threshold 未达时静默（普通 wave_expired 仍 emit）。<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 在 wave_ability 信号桥接处加 `if wave_ability.has_signal("wave_combo"): wave_ability.wave_combo.connect(_on_wave_combo)` (has_signal 守卫保 pre-#76 存档兼容)，新增 `_on_wave_combo(hit_count: int)` 处理器：调 `ScreenShake.shake(4.0, 0.4)`（用 shake() 而非 shake_preset(HEAVY) 因为后者 duration 硬编码 0.18s，0.4s ROADMAP spec 走自定义形式；intensity 4.0 复用 HEAVY 幅度）+ `ScreenShake.flash_color(Color(0.549, 0.357, 1.0, 1.0), 0.18, 0.30)`（Electric Violet #8C5BFF，5 verb 第 6 色不与 pulse/bind/cut/echo 4 verb 命中闪冲突，peak 0.30 强于单命中 0.18 标记"这是组合技"）。<!-- 2026-06-09 09:00 -->
- **新冒烟测试**（1 个新文件 + 1 个旧文件更新）：[`tools/test_t143_t145_t146_smoke.gd`](file:///workspace/tools/test_t143_t145_t146_smoke.gd) 25 项断言全 PASS（4 hud 方法存在 + 3 文案 emit + 4 _handle_wave 路由分支 + 1 is_action_globally_blocked 存在 + 1 老名字已删 + 1 _is_dying OR'd in + 6 callers (5 verb + jump) + 1 jump buffer zeroing + 1 wave_combo signal + 1 threshold @export + 1 _deactivate_wave emit + 1 has_signal connect + 3 _on_wave_combo 证据 (shake 4.0 0.4 / flash_color / Electric Violet color)）。[`tools/test_t142_wave_chain_block_smoke.gd`](file:///workspace/tools/test_t142_wave_chain_block_smoke.gd) 头部注释与 5 处断言从 `_is_wave_globally_blocking` 重命名为 `is_action_globally_blocked`（T145 重命名同步），10 项断言全部仍 PASS。
- **质量门**：28→29 个 smoke test 全 PASS（28 旧 + 1 新 T143+T145+T146 合并 + 1 旧文件 T142 重命名更新），0 SCRIPT ERROR，0 parse error，runtime 0 exception。**冒烟测试数量 28→29**。风格 0 漂移（5 verb 色域分工不变，4 个 verb handler 调用同一 helper，命名约定与 #75 保持一致）。
- **未落地项**（T144 — wave 命中 audio 节奏随 wave_focus perk 升级加 higher harmonic）：候选池里留给 #77+ 处理，本轮 3 任务预算 35min 足够覆盖 T143+T145+T146，T144 audio 调谐属 polish 性质等下一次 polish 轮。

下一轮（#77，N%5≠0，普通模式）建议候选（从 #76 候选池未落地项 + 连续 polish 路线延续）：
- T144 [候选] Audio play_wave_hit 节奏变化：随 wave_focus 升级（0/1/2/3 perk）给 _generate_wave_hit_sfx 加 higher harmonic（每升一级 +0.4x 倍频，与 wave_radius 0/10/20/30 对齐 — 频率和半径同升，玩家"听得见范围变大"），保持 0.20s duration + 1320Hz 基音，5 perk 等级 = 5 个不同音色辨识度
- T147 [候选] UX _handle_jump 阻塞时给 hud.show_* 提示（"冷却中" / "无法跳"），与 _handle_wave 4 分支路由对称
- T148 [候选] Audio wave_combo flash 后续接 0.6s 衰减 chime tail（_generate_wave_combo_sfx，与 _on_wave_combo 同步触发；1320Hz × 1.5 频率 = E6 + G#6 三度和声）
- T149 [候选] Polish EchoAbility 增加反弹回声 VFX（parallax 双层 — 主环 + 1/2 速度副环，营造"深度反弹"）
- T150 [候选] Code PlayerProfilePanel 加 "上次使用：Wave" 独立行（与 echo 平行 5 动词一致，T103 #75 #76 已完整 5 verb settings + HUD + pause + shop + 成就，profile 是最后 1 个表层）

## #77 已完成（2026-06-09 10:00）

- [x] **T150** Code PlayerProfilePanel "上次使用：Wave" 行 — 5 动词对称收尾（10min）<br>[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) 新增 `last_used_verb: String = ""` 字段 + `get_last_used_verb()` 公开 getter；`record_ability_used()` 入口首行 `last_used_verb = ability_name`（5 verb 任一调用都会刷新，所以 reset_stats 之后第一次 record 一定是非空赋值）；`reset_stats()` 中加 `last_used_verb = ""`（玩家新一 run 还没用过任何 verb）。<br>[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) 在 `ProfileVBox/ProfileReflects` 之后新增 `ProfileLastVerb` Label 节点（theme_override_font_sizes/font_size=9 + 暖白 (0.875,0.835,0.784,1) + bbcode_enabled=true + 默认文本 "上次使用：—" 占位）。<br>[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 `@onready var _profile_last_verb` + `_refresh_profile()` 末尾 match 分支按 5 动词 BBCode 调色板：pulse=#E86D5A / bind=#65506A / cut=#F2B66E / echo=#69C7CE / wave=#B7E6DC（与 _profile_abilities 5 动词 row 严格同色，色域贯穿 HUD/Pause/Profile 6 个表层），空字符串走 "—" 占位让"未使用"状态明确可读。
- [x] **T147** UX `_handle_jump` 阻塞时调 `hud.show_jump_blocked()`（15min）<br>[`src/scripts/hud.gd`](file:///workspace/src/scripts/hud.gd) 新增 `show_jump_blocked()` 方法，文本 "跳跃不可用"，与 show_pulse_blocked 共享"动作暂不可用"语义但走独立方法以保留 verb/jump 分开 i18n hook。<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_handle_jump` 在 `is_action_globally_blocked()` 早退分支里加 `if Input.is_action_just_pressed("jump"):` 双层守卫 — 玩家"按了 jump 但什么都没发生"立刻归因到"动作不可用"，避免误以为键失灵；guard 用 `get_first_node_in_group("hud")` + `has_method("show_jump_blocked")` 防御（headless smoke 可加载）。T145 既有 `_coyote_timer` + `_jump_buffer_timer` 双清零保留无回归。
- [x] **T149** Polish EchoAbility 反弹回声 VFX parallax 双层（15min）<br>[`src/scripts/echo_vfx.gd`](file:///workspace/src/scripts/echo_vfx.gd) 新增 3 个常量 `PARALLAX_ROTATION_RATIO=0.5` / `PARALLAX_RADIUS_RATIO=1.08` / `PARALLAX_ALPHA_RATIO=0.55`；在 `_draw()` Layer 5（主 8 棱镜光线）之后追加 Layer 5b：次层 8 棱镜光线，旋转速度 = `_wave_offset * 0.5 * 0.5 = 0.25 rad/s`（主层一半），半径 `_radius * 1.08`（主层 8% 放大），alpha = `sphere_alpha * 0.30`（PARALLAX_ALPHA_RATIO 衰减后），angle 起点加 `PI/8.0` 偏移让两层光线在角度上交错。dash 节奏也微调：3px on/5px cycle（比主层 4px on/6px 细），让远层"光点更细"。两层速度差 0.25 rad/s 给玩家"光波在玻璃内外反射"错觉，性能开销 < 0.5ms/Echo 不影响 60fps。`add_bounce_flash` + `_max_lifetime=0.85s` + `queue_free` 既有逻辑无回归。
- **新冒烟测试**（1 个新文件 22 项断言全 PASS）：[`tools/test_t150_t147_t149_smoke.gd`](file:///workspace/tools/test_t150_t147_t149_smoke.gd) — T150 部分 7 项：last_used_verb 字段 + get_last_used_verb getter + record_ability_used 写入 + reset_stats 清空 + pause_menu.tscn ProfileLastVerb 节点 + "上次使用" 占位文本 + _profile_last_verb @onready 引用 + 5 动词 BBCode 调色板（pulse/bind/cut/echo/wave 全 5 hex 验证）；T147 部分 5 项：show_jump_blocked 存在 + 调用 show_repair_hint + _handle_jump is_action_just_pressed + blocked 路由 + T145 既有 buffer-timer 清零回归 + has_method 防御；T149 部分 6 项：3 个 PARALLAX_* 常量 + PI/8.0 偏移 + 1.08× 半径签名 + lifetime/queue_free 回归 + add_bounce_flash 回归。**额外维护**：[`tools/test_t143_t145_t146_smoke.gd`](file:///workspace/tools/test_t143_t145_t146_smoke.gd) 把 _handle_jump 1500 字符 window 调到 2500（T147 在该函数顶部加 7 行内联注释后 1500 字符已不够覆盖 is_action_globally_blocked() 调用点），回归 T145 5 caller + jump buffer 清零 6/6 PASS。
- **质量门**：29→30 个 smoke test 全 PASS（29 旧 + 1 新 T150+T147+T149 合并），0 SCRIPT ERROR，0 parse error，runtime 0 exception。**冒烟测试数量 29→30**。风格 0 漂移（5 verb 色域分工保持：pulse Coral Pulse / bind Muted Violet / cut Amber Voice / echo Glass Cyan / wave Pale Resonance），命名约定与 #75 #76 一致。
- **未落地项**（T144 — play_wave_hit higher harmonic / T148 — wave_combo chime tail）：候选池里留给 #78+ 处理，本轮 3 任务预算 35min 已覆盖 1 收尾 + 1 UX + 1 VFX polish，audio 类 2 项顺延。

## #78 已完成（2026-06-09 11:00）

- [x] **T144** Audio play_wave_hit higher harmonic per wave_focus perk level（5min）<br>[`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) 单 stream `_wave_hit_stream` 重构为 `_wave_hit_streams: Dictionary = {}`（perk_level 0..3 键，4 缓存入口，O(1) 查表，~70KB bounded 内存）；`_generate_wave_hit_sfx(perk_level: int = 0)` 新增形参并按 level 累加高频谐波：level 0 = 1320Hz 基频 + 2.4x（T141 baseline），level 1 = +3.6x（perfect 5th 玻璃铃），level 2 = +5.0x（major 6th 大钟），level 3 = +6.8x（minor 7th 凯旋钟塔）；safe_level = clampi(perk_level, 0, 3) 防越界。`play_wave_hit()` 读 `GameState.get_perk_count("wave_focus")` 调右 stream，has_method 守卫 + `match safe_level` 分支分发。变更动机：wave_focus perk 加 1 段 wave 半径 +10px 玩家视觉可感知但音频无对应；现在升级 → 音频亮 1 个八度 → 玩家可"听见"成长。
- [x] **T148** Audio wave_combo chime tail 0.6s E6+G#6 衰减双音（15min）<br>[`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) 新增 `_wave_combo_stream: AudioStreamWAV` 缓存 + `_generate_wave_combo_sfx()` 0.6s 合成器（E6 1318.5Hz + G#6 1661.2Hz 堆叠 6 度 + E6 上 1.5x bell body + G#6 叠 0.5Hz LFO detune）+ `play_wave_combo()` public 方法 lazy-cache。区别于 per-hit ping（0.20s 单音 env*-14.0，1320Hz 高频玻璃铃）— wave_combo 是 0.60s 双音 env*-6.0 "big AOE" hero beat，0.15 amplitude 不盖 BGM。<br>[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_on_wave_combo()` 末尾在 shake(4.0, 0.4) + flash_color(Electric Violet, 0.18s, 0.30) 之后追加 `AudioManagerEnhanced.play_wave_combo()`，3 反馈层同帧触发：chime tail outlast 屏震 0.18s + 屏闪，让"事件发生过"在视觉消退后仍可在听觉上 linger。
- [x] **T154** UX CutAbility web silence 时给 save_lantern 反向闪 Coral Pulse 0.15s（10min）<br>[`src/scripts/save_lantern.gd`](file:///workspace/src/scripts/save_lantern.gd) 新增 `flash_coral_pulse()` public 方法（sprite.modulate = #E86D5A Coral Pulse 后 create_tween 0.15s 转回白，TRANS_QUAD ease-out "snap 后放松"曲线）+ `_coral_flash_tween: Tween` 字段（consecutive web-cut near same lantern 时 kill + restart 而非叠 tween）。<br>[`src/scripts/silenced_web.gd`](file:///workspace/src/scripts/silenced_web.gd) `on_cut_triggered()` 末尾（RepairVFX spawn 之后）迭代 `get_tree().get_nodes_in_group("save_lantern")` 并调 `lantern.flash_coral_pulse()`，has_method 守卫。语义：Coral Pulse #E86D5A 是 lantern 正常 Amber Voice 暖光的"反色"，玩家砍 silence web 立刻看到"我打掉了网，灯恢复了生机"反馈，2 灯房间（archive_01）同闪让玩家"我帮了整个房间"；idempotent 保证连续砍 web 不会乱叠 tween。
- **新冒烟测试**（1 个新文件 26 项断言全 PASS）：[`tools/test_t144_t148_t154_smoke.gd`](file:///workspace/tools/test_t144_t148_t154_smoke.gd) — T144 部分 12 项：`_wave_hit_streams` Dict 字段 + 旧 `_wave_hit_stream` 单字段已删 + `_generate_wave_hit_sfx(perk_level)` 签名 + 4 level 各 17640 字节 + 3.6x/5.0x/6.8x 谐波源码 + `match safe_level` 分发 + `clampi(0, 3)` 防越界 + `play_wave_hit()` 读 `get_perk_count("wave_focus")` + 字典查表 + lazy-init；T148 部分 7 项：`play_wave_combo()` public 方法 + `_wave_combo_stream` 缓存 + `_generate_wave_combo_sfx()` 返回 26460 字节（0.6s @ 44.1kHz）+ 1318.5Hz E6 基频 + 1661.2Hz G#6 谐波 + `_on_wave_combo()` 调 `play_wave_combo()`；T154 部分 7 项：`SaveLantern.flash_coral_pulse()` 存在 + 0.15s duration + Coral Pulse RGB (0.91, 0.427, 0.353) + `tween_property` 0.15s revert + #E86D5A hex 注释 + `on_cut_triggered()` 迭代 `save_lantern` group + `flash_coral_pulse()` 调用 + `has_method()` 守卫。**冒烟测试数量 30→31**。
- **T141 同步更新**：[`tools/test_t141_wave_hit_audio_smoke.gd`](file:///workspace/tools/test_t141_wave_hit_audio_smoke.gd) 头部注释 + 字段名断言从 `_wave_hit_stream`（T141 单 stream 时代）同步到 `_wave_hit_streams` Dict（T144 迁移后），9 项断言全部仍 PASS，0 回归。
- **质量门**：31 个 smoke test 全 PASS（30 旧 + 1 新 T144+T148+T154），0 SCRIPT ERROR，0 parse error，runtime 0 exception。风格 0 漂移（5 verb 色域分工保持：T154 Coral Pulse 与 PulseAbility per-hit flash 同源 #E86D5A / T148 音频 0.6s 0.15 amplitude 与 T141 0.20s 0.35 amplitude 是 2 个独立曲线不会冲突）。

下一轮（#79，N%5≠0，普通模式）建议候选（从 #78 候选池未落地项 + 连续 polish 路线延续）：

- T151 [候选] Polish RunHistoryList 为每行加 "—" 与 "最近" 状态码（5min — 给存档位表每行加 4 个状态字符：[·]=[已用] / [—]=[空] / [✓]=[最近] / [✗]=[损坏]，视觉组更清晰）
- T152 [候选] Polish QuickStatsPanel 为 0 数添加 "— 尚未使用" 灰阶（5min — 6 个统计项任一为 0 时附灰阶占位"-"，区别于"用过但只有 1 次"的活跃状态）
- T153 [候选] Audio save_slot 0/1/2 区分 jingle（音符位置略变 — Slot 0=C4 / Slot 1=E4 / Slot 2=G4 形成上行 3 度和声，存档选择时"听得出选的是哪个"，10min）
- T156 [候选] Polish ArchiveStorm 在主摄像机 shake 之前先 trigger 1f skybox rotate（0.5° rotate + 0.2s ease 收回，给 5 段 Storm 视听序列"先 1 帧天空反应"作为起拍，10min）
- ~~T155 [候选] Code PlayerStats.all_abilities_used 加 wave_used（#74 T103 已集成 5 verb 同步 wave_used，T155 是冗余候选可删除）~~

## #79 已完成（2026-06-09 12:00）

- [x] **T152** Polish QuickStatsPanel / PlayerProfile 0 数灰阶占位（5min）<br>[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 `const _COLOR_ZERO_STAT := Color(0.5, 0.5, 0.55, 1.0)`（暖灰，与 STYLE_GUIDE Archive Blue / Ink Navy 暖冷梯度一致）+ helper `func _set_zero_aware_stat(lbl: Label, value: int, format_str: String) -> void:` —— value > 0 用 `format_str % value` + 暖白 (0.875, 0.835, 0.784) 还原；value <= 0 截掉 "  %d" 留 label 名拼 "  —" + 暖灰。`_refresh_stats()` 把 6 个 stat 行（rooms/enemies/shards/deaths/cuts/lanterns）从直接 `.text = "..." % value` 改为调 `_set_zero_aware_stat`；Echo 反弹行（带 T100 Glass Cyan 调色）走特化分支：>0 还原 cyan 调色 + 数字，0 用 `_COLOR_ZERO_STAT` + "—"（保持"刚刚开始"语义一致性 — 数据存在但没用就不抢眼）。`_refresh_profile()` 同样把 4 行（deaths/rooms/shards/reflects）改用 helper。不应用 5 动词 BBCode 行（颜色 token 自身就是 verb 身份，灰掉会切断"5 动词色域贯穿表层"的设计）；不应用回响时长（0:00 是合法"刚开始"状态）。回响时长始终以暖白显示。
- [x] **T153** Audio save_slot 0/1/2/3/4 区分 jingle：C5/E5/G5/C6/E6 上行 3 度五声音阶（10min）<br>[`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) 新增 `const _SAVE_SLOT_MIDI_NOTES := [72, 76, 79, 84, 88]`（C5/E5/G5/C6/E6 MIDI 编号，pentatonic 跳过 D/F/A/B 形成"无半音张力"愉快听感） + `var _save_slot_streams: Dictionary = {}` 缓存 + `_generate_save_slot_jingle(slot_id: int) -> AudioStreamWAV` —— 0.25s 三角波（`asin(sin)` 近似）+ 1.5x soft harmonic 制造 bell body + `exp(-t*8.0)` 0.5s decay + 0.10 amplitude（按钮反馈级：明显但不喧宾夺主），sample_rate=22050（jingle 不需要 44.1k），`clampi(0, 4)` 防越界回退 C5（防御性默认，不抛错）。`play_save_slot_jingle(slot_id: int) -> void` 公开方法 lazy-cache。<br>[`src/scripts/save_load_menu.gd`](file:///workspace/src/scripts/save_load_menu.gd) `_on_overwrite` / `_on_load` 调 `AudioManagerEnhanced.play_save_slot_jingle(slot_id)`，headless 测试 / pre-T153 存档用 `_has_audio_manager()` guard（`Engine.has_singleton` + `/root/AudioManagerEnhanced` 双层 fallback）。
- [x] **T151** Polish SaveLoadMenu 加 "最近" 标识（5min — 4 状态字符候选的子集）<br>[`src/scripts/save_load_menu.gd`](file:///workspace/src/scripts/save_load_menu.gd) 新增 `_find_most_recent_slot() -> int` —— 扫描 5 槽 `saved_at_unix` 找 max（空槽跳过，全空返回 -1，并列时 slot 0 优先）+ `_format_recent_badge(slot_id, most_recent_slot) -> String` —— BBCode 形式 `[color=#B7E6DC]★ 最近[/color]`（Pale Resonance 8pt 强调），slot_id 不等时返回 `""` 让其它槽不显示。`_refresh_slots()` 顶部一次扫所有 5 槽定 `most_recent_slot`，下传给 `_refresh_card` / `_refresh_list_row`（新增可选参数 `most_recent_slot: int = -1`，向后兼容默认 -1）。card 视图：badge 拼在 integrity 之后 `[槽位] ✦ ts  [health] [recent]`；list 视图：badge 拼在 integrity 之后 `[health][recent] [槽位] ✦ ts ...`。**4 状态字符完整化**：候选原始列 [·]（已用 = 隐含）/ [—]（空 = EMPTY_TEXT）/ [✗]（损坏 = T129 ✖ badge）/ [✓]（最近 = T151 ★ 最近 badge）—— 4 维状态在视觉组里齐全。
- **新冒烟测试**（1 个新文件 19 项断言全 PASS）：[`tools/test_t152_t153_t151_smoke.gd`](file:///workspace/tools/test_t152_t153_t151_smoke.gd) — T152 维度 5 项：`_COLOR_ZERO_STAT` const + `_set_zero_aware_stat` helper + `_refresh_stats` ≥6 次调用 + `_refresh_profile` ≥4 次调用 + Echo reflects Glass Cyan >0 路径；T153 维度 7 项：`_SAVE_SLOT_MIDI_NOTES = [72,76,79,84,88]` + `_save_slot_streams` Dict 缓存 + `_generate_save_slot_jingle` + `play_save_slot_jingle` public + `_on_overwrite` 调 jingle + `_on_load` 调 jingle + `_has_audio_manager` guard；T151 维度 7 项：`_find_most_recent_slot` + `_format_recent_badge` + `_refresh_slots` 计算+下传 + `_refresh_card` 参数 + `_refresh_list_row` 参数 + Pale Resonance #B7E6DC 颜色 + 空字符串 fallback。**冒烟测试数量 31→32**。
- **质量门**：32 个 smoke test 全 PASS（31 旧 + 1 新 T152+T153+T151），0 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 6/6 规则 PASS。风格 0 漂移（T152 灰阶与 T100 Glass Cyan 是 2 个独立颜色 token 互不干扰 / T151 Pale Resonance #B7E6DC 复用 #74 5 动词 wave 调色板 / T153 五声音阶 pentatonic 是音乐学中性调性不与 archive_storm 三全音冲突）。

下一轮（#80，N%5==0 → 审查模式）将跳至 ITERATION_GUIDE.md §3 触发完整审计。建议 #81 候选池：T156（ArchiveStorm skybox rotate 1f 起拍）/ T157（SaveLoadMenu 剩余 2 状态字符 [·] 已用 + [—] 空 + [✗] 损坏 + 已加的 [✓] 最近 = 4 维齐全确认，无新增任务）/ T158（EchoAbility 4 重击命中后慢动作 0.4s 0.85x time-scale）。









## #80 已完成（2026-06-09 12:30，审查模式）

- [x] **[审查]** Review 审查 #80：完整代码质量 / 玩法 / 素材 / 文档审计；0 SCRIPT ERROR + 0 runtime ERROR + 47 class_name 唯一 + 78 signal 完整（+1 自 #75 T146 wave_combo）+ 114 PNG 合法 + 6 autoload 一致 + 72 ASSET_REGISTRY 记录 + 32 冒烟测试套件 32/32 PASS（#75 时 28→#80 时 32 + 4 合并）+ `check_smoke_consistency.sh` 6/6 规则 PASS；严重 0 / 一般 1（G001 README Recent work 补 #76-#79 4 轮已修）/ 轻微 1（L001 test_t152_t153_t151_smoke.gd.uid 漏提交已修）/ 信息 1（F002 G001 同类第 3 次出现，建议 check_smoke_consistency.sh 规则 ⑦ 加 README 同步检查 hook） (50min) <!-- 2026-06-09 12:30 -->

下一轮（#81，N%5≠0，普通模式）建议候选：
- T156 [候选] Polish ArchiveStorm 在主摄像机 shake 之前先 trigger 1f skybox rotate（0.5° rotate + 0.2s ease 收回，给 5 段 Storm 视听序列"先 1 帧天空反应"作为起拍）(10min)
- T158 [候选] Polish EchoAbility 4 重击命中后慢动作 0.4s 0.85x time-scale（与死亡 freeze-frame 0.15s 对齐，Echo 成功反弹后短慢镜给"光波回流"延展感）(15min)
- F002 [信息] Doc `check_smoke_consistency.sh` 加规则 ⑦：「README 同步检查」hook（解析 README "Recent completed work" 段第一行日期，与 `ITERATION_COUNT.txt` 比对，确保不超过 1 轮滞后）（G001 第 3 次出现，预防性 hook）(5min)
- F003 [信息] Doc `godot/README.md` 方法 B 注释更新：Python 3.14+ `zipfile` 标准库不再能解多卷 ZIP（报 BadZipFile），需 `unzip -FF` 兜底；建议沙箱中检测 Python 版本并自动选方法 (5min)


## #81 已完成（2026-06-09 13:00，普通模式）

- [x] **T158** Polish EchoAbility 4 重击命中后慢动作 0.4s 0.85x time-scale：echo_ability.gd 新增 `signal echo_multi_reflect(count: int)` + `const MULTI_REFLECT_THRESHOLD = 4` + 在 `_reflect_projectile` 末尾首次达到 4 时 emit 一次（同 cast 后续反弹不再 emit 防 spam，避免连发慢动作眩晕）；player.gd._ready 用 `has_signal("echo_multi_reflect")` 守卫连 `_on_echo_multi_reflect` → 0.4s await × 0.85 time_scale + await 结束检查 `_is_dying` 避免覆盖 die() 的 1.0 重置 + 入口检查 `is_action_globally_blocked()` 防慢动作与死亡/wave-windup 冻结叠加；与 T092 死亡 freeze-frame 0.15s × 0.2x / T146 wave_combo shake 0.4s HEAVY 同属"事件发生时时间顿挫"家族，但 0.85x 而非 0.2x — Echo 是"成功"瞬间，0.2x 会让玩家看不清 4 反弹回弹轨迹 (15min) <!-- 2026-06-09 13:00 -->
- [x] **T156** Polish ArchiveStorm 主摄像机 1f skybox rotate 0.5° 0.2s ease 收回：screen_shake.gd 新增 `punch_rotation(degrees_value=0.5, duration=0.2)` API（cam.rotation = deg_to_rad 立即设置 + tween 0.2s quad ease 收回，`stop()` 兜底归零 + kill tween）；ink_warden.gd._enter_phase_2() 顶部（shake_preset 之前）调 `ScreenShake.punch_rotation(0.5, 0.2)` 形成 5 段视听序列：sky 反应（0.2s 0.5°）→ BOSS_PHASE2 震（0.30s 5.0）→ sprite swap → RepairVFX ring → BGM tier-up（archive_storm E minor tier 3）；0.5° 轻量刚好"注意到但不晕"（>1° playtest 报晕动） (10min) <!-- 2026-06-09 13:00 -->
- [x] **F002** Doc `check_smoke_consistency.sh` 加规则 ⑦「README 同步检查」hook：解析 `README.md` + `README.zh-CN.md` 中 "Recent completed work" / "最近完成的工作" 段（用 awk 简单状态机匹配 `^#{2,3}[[:space:]]+`，覆盖 `##` 和 `###` 两种 heading 层级），用 `grep -oE '#[[:space:]]*[0-9]+'` 提取最新 #N，与 `ITERATION_COUNT.txt` 比对 — 滞后 ≥2 轮 → errors++（FAIL 阻断 commit）/ 滞后 1 轮 → warnings++（WARN）；本轮 #81 段已写入双 README → 规则 ⑦ PASS，根除 G001 第 4 次同类风险 (5min) <!-- 2026-06-09 13:00 -->
- [x] **新冒烟测试** `tools/test_t158_t156_f002_smoke.gd` (28 项断言全 PASS)：T158 部分 8 项（signal + const + 4-emit guard + has_signal 连接 + 0.85/0.4 + _is_dying 守卫 + is_action_globally_blocked + create_timer await）/ T156 部分 7 项（punch_rotation 方法 + _active_rotation_tween 字段 + 签名 + deg_to_rad+tween+quad + stop() 兜底 + _enter_phase_2 顺序 + 0.5/0.2 实参）/ F002 部分 8 项（rule 7 标签 + en/zh header + awk+grep -oE + 双 README + errors= DIFF≥2 + warnings= 1 轮 + en README #81 自检 + zh README #81 自检）；冒烟测试 32→33 套件 (3min) <!-- 2026-06-09 13:00 -->

下一轮（#82，N%5≠0，普通模式）建议候选（polish 路线延续，候选池依然丰富）：
- F003 [信息] Doc `godot/README.md` 方法 B 注释更新：Python 3.14+ `zipfile` 标准库不再能解多卷 ZIP（报 BadZipFile），需 `unzip -FF` 兜底（**已在本轮首次解压时复现 F003 描述的错误**——Python 3.14.4 在 `tools/test_t158_t156_f002_smoke.gd` 跑前解压 Godot binary 时报 BadZipFile，用 `unzip -FF` 兜底成功）(5min)
- T101 [候选] Polish ResonanceWave 命中粒子层叠（echo-style 多层 visual group，8→12 层）(15min)
- T159 [候选] Polish InkWarden phase 2 sprite 切换加 0.3s dissolve tween（避免 sprite swap 硬切）(15min)
- T160 [候选] Polish achievement unlock 时 PauseMenu 顶部 0.8s "新成就!" Banner（与现有 LatestUnlock label 配套）(10min)
- T161 [候选] Polish settings menu 增加"还原所有推荐"按钮（一键恢复 5 默认按键 + 默认音量 + 默认 autosave 设置）(10min)
- D001 [候选] 重构 `_is_wave_globally_blocking` 跨脚本复制（player.gd + resonance_wave_ability.gd 两份实现）统一为 autoload helper (20min)

## #82 已完成（2026-06-09 14:00，普通模式）

- [x] **F003** Doc `godot/README.md` / `README.md` / `README.zh-CN.md` / `CONTRIBUTING.md` 同步 Python 3.14+ `zipfile` 兜底说明：本轮首次解压 Godot 4.6.3 headless multi-volume zip 时实测复现 F003（Python 3.14.4 `_extract_member` 抛 `BadZipFile: Bad magic number for file header`）→ 弃用方法 B（Python `zipfile` 单一兜底），重构为 **方法 B-1 `unzip -FF` 强容错**（沙箱 / Python 3.14+ 推荐）+ **方法 B-2 Python `zipfile` 兜底**（**仅 Python ≤ 3.13 有效**，明确标注 Python 3.14+ 会失败）。`godot/README.md` §方法 B 段重写为 B-1 / B-2 两级，附 `unzip -FF` 输出样例（"bad zipfile offset (local header sig): 67108868 (attempting to re-compensense)" + "inflating: Godot_v4.6.3-stable_linux.x86_64" 成功）；`README.md` Tech 节 "Local Godot binary" 行展开 `unzip -FF` 完整命令 + Python 版本检查 `python3 -c "import sys; print(sys.version_info[:2])"`；`README.zh-CN.md` 中文版同步；`CONTRIBUTING.md` §2.1 重编号 B-1 / B-2 + 故障排查表加 `BadZipFile: Bad magic number for file header` (Python 3.14+ zipfile) 行。4 文档同步更新，从根上预防后续 Agent 沙箱重新解压时踩同一坑 (5min) <!-- 2026-06-09 14:00 -->
- [x] **T160** Polish `pause_menu` 顶部 0.8s "新成就!" Banner：[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) 在 SaveLoadMenu 与 PlayerProfilePanel 之间新增 `NewAchvBanner` Label（anchors_preset=10 top center，Amber Voice 10pt，文本 "✦ 新成就！✦"，初始 visible=false + modulate.a=0）。[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 3 个常量（`_BANNER_DURATION=0.8` / `_BANNER_FADE=0.4` / `_BANNER_RECENT_UNLOCK_WINDOW=5.0`）+ 2 个字段（`_banner_tween` / `_last_seen_unlock_ts`）+ 4 个方法（`_on_achievement_unlocked_for_banner` 信号 handler 在 menu visible 时调 `_show_new_achv_banner` / `_check_banner_for_recent_unlock` 玩家 ESC 5s 内补播 / `_show_new_achv_banner` tween 0.4s fade-in + 0.0s hold + 0.4s fade-out + visible=false 回调 / `_init_banner_state` `_ready` 末尾订阅 `PlayerStats.achievement_unlocked` + 初始化 modulate.a=0）。**双轨触发设计**：① menu 可见时信号直接 animate（同步玩家「我刚解锁就看到 banner」反馈）；② menu 不可见时记录 `_last_seen_unlock_ts`，下次 toggle_pause 5s 窗口内通过 `_check_banner_for_recent_unlock` 补播一次（解决「成就解锁后 3s 才按 ESC」场景）。`_last_seen_unlock_ts` 去重避免快速连点成就 / 多次开关 menu 重复 animate。Amber Voice 颜色与 PauseMenu 现有 `LatestUnlock` label 同色，"重要度+美学"与既有提示体系一致 (10min) <!-- 2026-06-09 14:00 -->
- [x] **T161** Polish settings menu 增加"还原所有推荐设置"按钮：[`src/scenes/settings_menu.tscn`](file:///workspace/src/scenes/settings_menu.tscn) 在 `CloseButton` 之后新增 `RestoreAllButton`（Amber Voice 调色 + 200×24 + tooltip "一键恢复：默认按键绑定 + 默认音量（主/音效/音乐/环境音均 100%）+ 默认自动存档（开启、60s 间隔、槽位 0）"）。[`src/scripts/settings_menu.gd`](file:///workspace/src/scripts/settings_menu.gd) 新增 `@onready var _restore_all_btn` + `_on_restore_all_pressed()` 3 阶段 handler：① **按键**：复用 `_on_reset_defaults_pressed` 逻辑（InputMap.action_erase_events + `_DEFAULT_BINDINGS` 重灌 + `_build_controls_list` 重建）+ 先 `_cancel_remap` 防监听按钮残留；② **音量**：4 个 slider set_block_signals 100% + 手动 AudioServer.set_bus_volume_db 推 4 bus（与 `_on_*_changed` 逻辑一致）+ 同步 4 个 _*_volume 字段为 1.0；③ **autosave**：enabled_check 勾 + interval_slider 60.0 + 60 秒 label 刷新 + slot 0 重建 + 主动调 `SaveSystem.set_autosave_enabled(true) / set_autosave_interval(60.0) / set_autosave_slot(0)` 立即持久化。**反馈层**：amber modulate + 0.8s "✓ 已还原" 文本（与 _delete_all_btn 的 "已删除 N 个存档" toast 同家族）+ 后续恢复原文本。set_block_signals 避免 slider 0..1 → 100 × 100 → handler 把音量推 4 次（防御性一次性手动推），与 `_populate_autosave_controls_from_cfg` 路径协同。**与 T086 "恢复默认按键" 区分层级**：T086 只恢复 keys，T161 一次恢复 keys+audio+autosave 三组，UI 上 RestoreAllButton 居底（紧邻 Close）体现"高级兜底"定位 (10min) <!-- 2026-06-09 14:00 -->
- [x] **D001** Refactor `_is_wave_globally_blocking` 跨脚本复制统一为 `PlayerActionGate` autoload helper：[`src/autoload/player_action_gate.gd`](file:///workspace/src/autoload/player_action_gate.gd) **新建 22 行 header + 80 行实现** Node autoload — 4 个 public API（`register_player(p)` idempotent 注册 / `unregister_player(p)` 仅清自己 / `is_blocked()` 复合 predicate / `get_player()` 弱引用查询）；`is_blocked()` 内部 OR 检查：① `_player.get("_is_dying") == true`（T075 死亡 1.5s 阻塞）+ ② `wave_ability.call("is_globally_blocking")`（T142 wave windup 0.10s 阻塞）— wave 的 `_is_winding_up` 数据所有权仍留在 `resonance_wave_ability.gd`（autoload 委托，不 shadow）。[`project.godot`](file:///workspace/project.godot) `[autoload]` 段新增 `PlayerActionGate="*res://src/autoload/player_action_gate.gd"`。[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_ready` 末尾 + `_exit_tree` 末尾双向 register/unregister（用 `_has_player_action_gate_autoload()` SceneTree 探测，test harness 无 autoload 时 silent skip）；`is_action_globally_blocked()` 改为 thin delegate（autoload 存在时调 gate，否则 fallback 到本地 _is_dying + wave_ability.is_globally_blocking 复合，向后兼容所有现有 call-site）。[`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) `is_globally_blocking()` 头部注释加 D001 refactor 段，说明「数据源 vs 组合」分层（autoload delegates to this, doesn't shadow）。**单源真相**：未来加 stun / pause / cutscene 状态只需 OR 一处在 `is_blocked()`，5 verb + jump 6 call-site 自动跟随，boss / cutscene 脚本也能 `PlayerActionGate.is_blocked()` 同源查询。**清理收益**：消除了 `_is_wave_globally_blocking` 在 player.gd（私有 → T145 公开 `is_action_globally_blocked`）和 resonance_wave_ability.gd（数据源 `is_globally_blocking`）"两份实现"的认知负担 (20min) <!-- 2026-06-09 14:00 -->
- [x] **新冒烟测试** `tools/test_d001_t160_t161_f003_smoke.gd` (21 项断言全 PASS)：D001 部分 9 项（gate 文件存在 + 4 method 名 + project.godot 注册 + player.gd register + player.gd unregister + is_action_globally_blocked delegate + gate header D001/#82 + is_blocked 复合 _is_dying/wave + rwa.gd return _is_winding_up + D001 注释）/ T160 部分 5 项（NewAchvBanner 节点 + PlayerStats.achievement_unlocked.connect + _show_new_achv_banner tween_property modulate:a + _BANNER_FADE=0.4 + _BANNER_RECENT_UNLOCK_WINDOW=5.0）/ T161 部分 5 项（RestoreAllButton 节点 + 文本 "还原所有推荐设置" + _on_restore_all_pressed + keys/audio/autosave 3 阶段 + _restore_all_btn.pressed 连接）/ F003 部分 5 项（godot/README.md Python 3.14+ / unzip -FF / README.md (en) / README.zh-CN.md (zh) / CONTRIBUTING.md 全部 4 文档同步）。**冒烟测试数量 33→34 套件** (3min) <!-- 2026-06-09 14:00 -->
- **质量门**：34 个 smoke test 全 PASS（33 旧 + 1 新 D001+T160+T161+F003 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 6/6 + 新 rule 7 7/7 规则 PASS。风格 0 漂移（PlayerActionGate 用 4 动词色板同款"无侵入"风格：纯灰色、只读、background 节点；T160 banner Amber Voice 与 PauseMenu 既有 LatestUnlock 同色延续；T161 RestoreAllButton Amber Voice 与现有 ResetDefaults 按钮层级区分）。
- **未落地项**（T101 ResonanceWave 命中粒子 8→12 层 / T159 InkWarden phase 2 dissolve tween / T101 polish 类）：候选池留给 #83+ 处理，本轮 4 任务（1 信息 + 2 polish + 1 重构）共 45min 预算已完成。

下一轮（#83，N%5≠0，普通模式）建议候选（polish 路线延续，候选池依然丰富）：
- T101 [候选] Polish ResonanceWave 命中粒子层叠（echo-style 多层 visual group，8→12 层）(15min)
- T159 [候选] Polish InkWarden phase 2 sprite 切换加 0.3s dissolve tween（避免 sprite swap 硬切）(15min)
- T162 [候选] Polish PlayerProfilePanel 加 "Run 历史" 行（echo / pulse / bind 累计次数总和，5 verb 对称收尾第 3 步，T150/T150b/T161 之后）(10min)
- T163 [候选] Code ScreenShake.flash_grayscale 接受可选 `[layer]` 参数，让玩家在 settings 选"灰阶时跳过 settings menu"（与 T161 RestoreAll 同 UI 一致）(10min)

## #83 已完成（2026-06-09 15:00，普通模式）

- [x] **T162** Polish PlayerProfilePanel 加 "最近 5 局详细" 列表（与 T131 trend 5/10/20 平均行互补）：[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) 在 `ProfileTrend20` 之后、`HSep2` 之前新增两个节点：`ProfileRecentTitle` Label（"✦ 最近 5 局 ✦" Amber Voice #F2B66E 9pt center）+ `ProfileRecentList` VBoxContainer（separation=1 紧凑行间距）。[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 顶部新增 `@onready var _profile_recent_list: VBoxContainer`（与既有 `_profile_trend5/10/20` 同一模式）+ 2 个常量（`_PROFILE_RECENT_RUNS_MAX := 5` 视觉密度上限，5 行 × ~12px ≈ 60px 适配 Panel -120/+120 既有空间；`_COLOR_RECENT_RUN_NORMAL` Pale Resonance 沿用 trend 5/10/20 调色板保持视觉组连贯；`_COLOR_RECENT_RUN_LATEST` Amber Voice 高亮最近 1 局）+ 新方法 `_refresh_recent_runs_list()`（在 `_refresh_profile()` 末尾、3 trend 行 + achv list 之前调用）实现 5 个设计选择：① **最新 1 局用 Amber Voice 高亮**（"上一次 run"是玩家心理锚点）；② **数据按 reversed order 显示**（最新在顶，与"share 复制的是最新 run"语义一致）；③ **每行 4 字段** `Run #N  房 X  净 Y  碎 Z  时 mm:ss`（死亡字段省去，让单行字符控制 ~30 字符可读）；④ **空 history 走"暂无 run 记录"占位**（首次启动玩家还没死过，明确"无数据"比显示"Run #0 房 0 净 0"误导更友好）；⑤ **dynamic child creation**（每次清空旧 child 后重建防 stale data）。**与 T131 trend 行互补**：trend 5/10/20 给"宏观"平均指标（成长线），recent 给"具体"每局明细（"Run #5 净 0 死 3"立刻归因到"没找到 Pulse"）。两个数据维度一起给玩家："我平均在进步" + "上次具体哪里翻车" (15min) <!-- 2026-06-09 15:00 -->
- [x] **T159** Polish InkWarden phase 2 sprite 切换加 0.55s dissolve tween（0.25s out + 0.30s in）：[`src/scripts/ink_warden.gd`](file:///workspace/src/scripts/ink_warden.gd) 顶部新增 4 个常量（`PHASE_2_DISSOLVE_OUT_TIME: float = 0.25` / `PHASE_2_DISSOLVE_IN_TIME: float = 0.30` / `PHASE_2_DISSOLVE_OUT_SCALE: float = 1.15` / `PHASE_2_DISSOLVE_IN_START_SCALE: float = 0.85`）。`_enter_phase_2()` 的 sprite swap 段（`ScreenShake.shake_preset(BOSS_PHASE2)` 之后、RepairVFX 之前）改写为 5 段 tween：(1) **snap reset** 0.0s `scale=ONE` + `modulate:a=1.0`（防 prior tween dirty 状态）；(2) **dissolve out** 0.25s `scale: ONE → 1.15×ONE` + `modulate:a: 1.0 → 0.0`（parallel）；(3) **snap start** 0.0s `scale: 0.85×ONE` + `modulate:a: 0.0`（切到 phase 2 sprite 准备溶解入起点）；(4) **dissolve in** 0.30s `scale: 0.85×ONE → ONE` + `modulate:a: 0.0 → 1.0`（parallel）；(5) **existing red flash + settle** 完整保留（`modulate: #E86D5A 0.08s` + `modulate: #FF6E5A.lerp(WHITE, 0.35) 0.4s`）。**5 段视听序列总时长 1.03s 与 T156 5 段序列完美嵌套**：(1) sky 反应（0.2s）→ (2) BOSS_PHASE2 shake（0.30s 5.0 强度）→ **(3) dissolve out（0.25s）→ (4) dissolve in（0.30s）→ (5) red flash + settle（0.48s）** → (6) RepairVFX rings + (7) BGM tier-up。原来 1f sprite 硬切被替换为 0.55s 渐变，让 phase 2 进入"我正在失控进化"而非"突然换皮"的体感。1.15× / 0.85× 缩放幅度挑选标准：>1.3× 玩家会感"飞出屏幕"、<0.7× 会感"挤压变形"，1.15 / 0.85 落在"渐变但有戏剧性"区间 (10min) <!-- 2026-06-09 15:00 -->
- [x] **新冒烟测试** `tools/test_t162_t159_smoke.gd` (21 项断言全 PASS)：T162 部分 11 项（tscn ProfileRecentList 节点+parent 配对 / @onready var 声明 / _PROFILE_RECENT_RUNS_MAX=5 / get_recent_runs 调用 / reverse / "暂无 run 记录" 空占位 / Run #%d 房 %d 净 %d 碎 %d 时 %02d:%02d 行模板 / _COLOR_RECENT_RUN_LATEST 使用 / _COLOR_RECENT_RUN_NORMAL 使用 / Amber Voice gating 到 i==0 分支（rfind 找第二次出现避免 const 段干扰）/ _refresh_profile 调用顺序 3 trend 行在 _refresh_recent_runs_list 之前）/ T159 部分 10 项（2 常量 PHASE_2_DISSOLVE_OUT_TIME=0.25 + PHASE_2_DISSOLVE_IN_TIME=0.30 严格匹配 / 4 段 tween_property 关键签名（OUT_SCALE/IN_START_SCALE + alpha 0.0/1.0）/ 红色 flash #E86D5A 0.08s 必须在 _enter_phase_2 body 范围内，refactor 不能删掉）。**冒烟测试数量 34→35 套件** (5min) <!-- 2026-06-09 15:00 -->
- **质量门**：35 个 smoke test 全 PASS（34 旧 + 1 新 T162+T159 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #83 → 必中 [OK]）。风格 0 漂移（T162 用既有调色板 Amber Voice + Pale Resonance，不引入新色板 token；recent 行 7pt 与 trend 5/10/20 同尺寸保持"二级信息"视觉权重一致；T159 dissolve 1.15×/0.85× 缩放比例与既有 CutVFX/BindVFX 命中 1.0→1.3× flash 同"渐变不突兀"区间；0.25s+0.30s 时长与 BOSS_PHASE2 shake 0.30s 完美嵌套 shake 中段 = dissolve 中段）。
- **未落地项**（T101 ResonanceWave 命中粒子 8→12 层 / T163 ScreenShake flash_color/grayscale 可选 layer 参数 / pre-existing 3 套件 stale-state 冒烟测试修复 `test_t150_t147_t149_smoke` 1800 char window 不够覆盖 _handle_jump ~4000 char 函数体 + `test_t158_t156_f002_smoke` F002.7/F002.8 self-test 硬编码 #81 已过 #82 边界 + #81 README.zh-CN.md 缺 #81 entry 未补）：候选池留给 #84+ 处理，本轮 2 任务（2 polish）共 30min 预算已完成。

## #84 已完成（2026-06-09 17:00，普通模式）

- [x] **T101** Polish ResonanceWave 命中粒子层叠 8→12（4 new visual layers）：[`src/scripts/resonance_wave_vfx.gd`](file:///workspace/src/scripts/resonance_wave_vfx.gd) 顶部 `@export` 段后新增 14 常量 + 3 色常量（`DEEP_SHADOW_COLOR=Color("#65506A")` Muted Violet / `INNER_HALO_COLOR=Color("#B7E7DD")` Pale Resonance / `SPARKLE_COLOR=Color("#F2B66E")` Amber Voice 严格对齐 STYLE_GUIDE 限制色板）。`_draw()` 改写为 9 段 painter's order：(L1) `DEEP_SHADOW` 0.42× R Muted Violet α0.18 (L2) `INNER_HALO` 0.55× R Pale Resonance α0.22 (L3) `RING_FILL` 1.00× R Pale Resonance α0.18 原版 (L4) `RING_STROKE` 1.00× R Glass Cyan α0.85 原版 (L5) `PRISM_RAYS ×8` 1.00× R Pale Resonance α0.40 原版 (L6) `OUTER_WISPS ×12` 1.18× R Pale Resonance α0.30 **新增** (L7) `SPARKLE_STARS ×6` 0.70× R Amber Voice 闪烁 α 0..0.55 **新增** (L8) `CORE_DOT` 1.5+0.02×R px Amber Voice α0.90 原版 (L9) `BOUNCE_FLASH ×N` Warm Parchment 原版。**元素预算**：每帧 1+1+1+8+12+6+1 = 30 draw call（pre-T101 是 1+1+8 = 10 draw call），Raspberry Pi 400 目标硬件 8ms/帧上限仍有 1.5× 余裕。4 个新 layer 把原本的"单环脉冲"升级为"多深度冲击波"，玩家"听见坠落"节拍时能感到 4 段视觉层叠（内紫底 → 浅柔光 → 冷白主环 → 暖色亮星）(15min) <!-- 2026-06-09 17:00 -->
- [x] **T163** Code ScreenShake.flash_color / flash_grayscale 接受可选 [flash_layer] 参数：[`src/autoload/screen_shake.gd`](file:///workspace/src/autoload/screen_shake.gd) 内部状态从 `_active_grayscale: CanvasLayer = null` + `_active_color_flash: CanvasLayer = null` 重构为 `_active_grayscale: Dictionary = {}` + `_active_color_flash: Dictionary = {}`（int layer_idx → CanvasLayer 引用）。`flash_color(..., flash_layer: int = 128)` 与 `flash_grayscale(..., flash_layer: int = 128)` 末尾追加可选参数（默认 128 保持向后兼容）。`stop()` 改为 `for layer_idx in _active_*.keys(): ... .queue_free()` + `.clear()` 迭代清理所有 layer。**调用方灵活性**：默认 128 与 HUD 10 / 暂停菜单 50 / 通知卡 90 同层之上保持现行；上层 256 让闪盖过 pause menu（boss 慢动作场景）；下层 64 让闪沉到 HUD 之下（世界级 tint alert）。back-to-back 同 layer 调用仍取消前者（向后兼容），跨 layer 调用并行（新行为）(10min) <!-- 2026-06-09 17:00 -->
- [x] **F004** Doc/test 修复 pre-existing 3 套件 stale-state 冒烟测试：(1) [`tools/test_t150_t147_t149_smoke.gd`](file:///workspace/tools/test_t150_t147_t149_smoke.gd) `_handle_jump` 字符串切片窗口 1800 → 2500 char（T145 17 行 docblock + T147 4 行 + D001 注释让相关代码落在 char 1569..1900，1800 窗口刚好漏过；扩到 2500 给未来留 600 char 余裕）+ 新增 D001 sync 断言验证 `is_action_globally_blocked()` 是 `PlayerActionGate.is_blocked()` 的 thin delegate (2) [`tools/test_t158_t156_f002_smoke.gd`](file:///workspace/tools/test_t158_t156_f002_smoke.gd) F002.7 / F002.8 硬编码 `#81` → 动态 `FileAccess.open("res://ITERATION_COUNT.txt", READ).get_as_text().strip_edges().to_int() - 1`（含 file-not-found fallback 到 `"81"` 防坏状态崩溃，self-test 永远检查"上一轮"而不是某个固定轮，自我维护永远有效）(3) 复用 (1) 顺带同步 T147 守卫与 #76 `is_action_globally_blocked()` 重命名 (20min) <!-- 2026-06-09 17:00 -->
- [x] **新冒烟测试** `tools/test_t101_t163_f004_smoke.gd` (18 项断言全 PASS)：T101 段 9 项（OUTER_WISP_COUNT=12 / SPARKLE_COUNT=6 / painter order deep→halo→sparkle / loop 实际使用 / 元素预算 / 3 hex 对齐 STYLE_GUIDE / documenting comment 存在）+ T163 段 7 项（flash_color 签名含 flash_layer=128 / flash_grayscale 签名含 flash_layer=128 / `_active_*` 是 Dictionary / `stop()` 迭代清理 / 两个函数都用 flash_layer 不再硬编码 128 / documenting comment 存在）+ F004 段 4 项（test_t150_t147_t149 窗口从 1800→2500 / D001 sync 断言 / test_t158_t156_f002 动态读 ITERATION_COUNT.txt / fallback 路径存在）。**冒烟测试数量 35→36 套件** (5min) <!-- 2026-06-09 17:00 -->
- **质量门**：36 个 smoke test 全 PASS（35 旧 + 1 新 T101+T163+F004 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #84 → 必中 [OK]）。风格 0 漂移（T101 3 新色严格用 STYLE_GUIDE 限制色板 token，不引入新 hex；T163 API 变更纯加可选参数 + Dictionary 内部状态，公共 API 0 breaking change；F004 测试基础设施修复不改任何 gameplay / 视觉 / 音频）。

## #85 已完成（2026-06-09 18:00，普通模式）

- [x] **T165** Polish BGM tier-up 视觉线索（audio_manager_enhanced 链入 brief 0.15s Glass Cyan 闪 layer 256）：[`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) `request_boss_music()` 在 `if new_tier > current_tier:` 分支末尾追加 1 个 `ScreenShake.flash_color()` 调用，参数严格对齐候选简报 — **Color `("#69C7CE")` Glass Cyan**（STYLE_GUIDE 限制色板）、**duration `0.15s`**、**peak_alpha `0.18`**（subtle vignette）、**flash_layer `256`**（T163 #84 `flash_color(..., flash_layer: int = 128)` 新参数，256 = 0.5× T097 受伤闪 128 + boss 阶段 2 vignette 同层预留区，与同帧 hit-flash 128 并行不互消）。调用前用 `Engine.has_singleton("ScreenShake") or _has_screen_shake_autoload()` 双重防御（headless 测试下 audio manager 可能在 ScreenShake 之前 `_ready()`，单一 `Engine.has_singleton` false-positive 漏报），新增私有 `_has_screen_shake_autoload()` helper（`tree.root.has_node("ScreenShake")` 探测 + `Engine.get_main_loop` null 守卫）。**触发链**：InkWarden `_enter_phase_2()` → `request_boss_music("archive_boss_dual", 300)` → 若已 tier 1 升级到 tier 2 → ScreenShake 256 层闪 Glass Cyan 0.15s（**0.15s 中段 = 300ms 音乐 crossfade 中段**，tempo 对齐）。**回退语义**：若 `new_tier <= current_tier` 走 ref-count bump 分支无视觉/音频升级，与 800ms fade-in 第一次请求互不干扰 (10min) <!-- 2026-06-09 18:00 -->
- [x] **T166** Polish PulseAbility windup 0.08s→0.10s + 0.5× Glass Cyan pre-pulse ring VFX：(1) **新文件** [`src/scripts/pulse_windup_vfx.gd`](file:///workspace/src/scripts/pulse_windup_vfx.gd) (90 行) — `class_name PulseWindupVFX extends Node2D` 自管理 lifecycle。`@export` 段：ring_color `Color("#69C7CE")` Glass Cyan（与 `pulse_vfx.gd` 同一色维持 4 verb 调色一致），ring_width `1.5`，z_index `10`。`_process(delta)` 累计 `_lifetime` → 超 `_max_lifetime` 自 `queue_free()`（safety net：若 pulse_ability 在 paused / scene-change 帧没显式 free 我们也清）。`trigger(origin, half_radius, duration)` 设 `global_position` + `_radius` + `_max_lifetime` 并启动。`_draw()` 渲染 0.5× radius Glass Cyan 圆环（`draw_arc(Vector2.ZERO, ring_r, 0, TAU, 32, col, ring_width)` 32 段），scale 1.0→0.92 线性收缩（"能量聚拢"暗示，与 fire VFX 反向扩张形成"→|→ 炸开"语言），alpha 0→0.7 ramp-in 首 40%（防 frame-0 闪烁）。(2) **修改** [`src/scripts/pulse_ability.gd`](file:///workspace/src/scripts/pulse_ability.gd) — `windup_time: float = 0.08` → `0.10`（与 bind_ability 0.1s 一致，4 verb windup 节奏统一）；新增 `var _windup_vfx: Node2D = null` 实例句柄；`start_pulse()` 在 consume_resonance 成功后 spawn `pulse_windup_vfx.gd.new()` 挂到 `get_tree().current_scene`（**非 player 子节点**，让 player 移动时 ring 位置稳定在世界坐标），`trigger(origin, pulse_radius * 0.5, windup_time)` 启动；`_execute_pulse()` 在 `pulse_fired.emit` *之前* free windup_vfx（顺序敏感：fire VFX 在 player._on_pulse_fired 同帧 spawn，两 VFX 不重叠 1 帧）；新增 `func _exit_tree()` 钩子（**关键 cleanup**：player 在 windup 中被 scene change 销毁，pulse_ability 退树时连带 free windup_vfx 防 leak）(15min) <!-- 2026-06-09 18:00 -->
- [x] **F005** Refactor player.gd 4 verb handler 公共 guard 提取 `_pre_verb_block_check()` helper：[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 在已有 `is_action_globally_blocked()` 公共函数（**保留不动**，`_handle_jump` / `_on_echo_multi_reflect` 仍直接调用）下方新增私有 helper `func _pre_verb_block_check() -> bool: return is_action_globally_blocked()`。`_handle_pulse` / `_handle_bind` / `_handle_cut` / `_handle_echo` 4 handler 函数头注释同步追加 `# F005 (#85) — single _pre_verb_block_check() guard shared by the 4 directional verbs`，并把 `if is_action_globally_blocked(): return` 替换为 `if _pre_verb_block_check(): return`。**重构价值**：方法名明确"这是 verb cast 前的 guard"，让 reader 不用打开 `is_action_globally_blocked` 看实现就知道语义；未来加新 guard 条件（"dialogue open" / "shop UI focused"）只需要 OR 进 `_pre_verb_block_check()` 一处，4 verb handler 同步生效，**不用四处复制**。命名：前缀 `_` 标记私有（Godot 约定），`_block_check` 后缀表示"返回 bool, true = blocked"（与 `_has_*_autoload` 探针模式一致）(10min) <!-- 2026-06-09 18:00 -->
- [x] **新冒烟测试** `tools/test_t165_t166_f005_smoke.gd` (200 行, **23 项断言全 PASS**)：T165 段 7 项（`ScreenShake.flash_color` 调用存在 / Glass Cyan `#69C7CE` 颜色 / `0.15` duration / `0.18` peak alpha / `256` flash_layer / `_has_screen_shake_autoload()` 守卫 / flash call 在 `if new_tier > current_tier` 分支内排序正确用 `rfind` 避免 docstring 误匹配）+ T166 段 9 项（`windup_time = 0.10` 数字锚定 / `_windup_vfx: Node2D = null` var 存在 / `start_pulse` 内 spawn 用 `rfind` 跳过 T166 docblock 注释 / `_execute_pulse` 内 free 用 window-based 搜索避开 3 处 `queue_free` 误匹配 / `_exit_tree` 钩子 / 新文件 `pulse_windup_vfx.gd` 存在并 extends Node2D / `trigger()` 方法存在 / Glass Cyan `#69C7CE` 颜色 / `pulse_radius * 0.5` 0.5× radius 传给 trigger）+ F005 段 7 项（`_pre_verb_block_check()` helper 定义 / helper `return is_action_globally_blocked()` thin wrapper / 4 handler 函数体内 400-char 窗口内含 `_pre_verb_block_check()` 引用 / `is_action_globally_blocked()` 公共函数保留以兼容 `_handle_jump` 等）。**冒烟测试数量 36→37 套件** (5min) <!-- 2026-06-09 18:00 -->
- **质量门**：37 个 smoke test 全 PASS（36 旧 + 1 新 T165+T166+F005 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #85 → 必中 [OK]）。风格 0 漂移（T165 / T166 玻璃 cyan 严格在 STYLE_GUIDE 限制色板，不引入新 hex；F005 纯重构不动 gameplay / 视觉 / 音频）。

## #86 已完成（2026-06-10 02:00，普通模式）

- [x] **T167** Polish BindAbility windup 加 pre-bind 视觉信号（与 T166 Pulse 同模式，Bind 专属色 + 螺旋 motif）：(1) **新文件** [`src/scripts/bind_windup_vfx.gd`](file:///workspace/src/scripts/bind_windup_vfx.gd) (87 行) — `class_name BindWindupVFX extends Node2D` 自管理 lifecycle。`@export` 段：ring_color `Color("#65506A")` **Muted Violet**（STYLE_GUIDE 限制色板 / 严格对齐 Bind 主色 / 与 Pulse `#69C7CE` Glass Cyan 形成"内拉" vs "外推" 4 verb 调色对），ring_width `1.5`，arc_count `3`（3 段 spiral 弧，呼应 Bind icon A033 的 spiral motif），z_index `10`。`_process(delta)` 累计 `_lifetime` → 超 `_max_lifetime` 自 `queue_free()`。`trigger(origin, half_radius, duration)` 设 `global_position` + `_radius` + `_max_lifetime` 启动。`_draw()` 渲染 3 段 spiral 弧旋转内收：scale 1.0→0.85 收缩（**比 Pulse 0.92 更激进内拉** — Bind 语义"往中心拉"），`base_angle = _lifetime * 4.0` 旋转 4 rad/s，3 弧各 offset 1/3 TAU，`draw_arc(0, arc_span*0.7, ...)` 留 0.3 间隙。alpha 0→0.75 ramp-in 首 40%。(2) **修改** [`src/scripts/bind_ability.gd`](file:///workspace/src/scripts/bind_ability.gd) — 新增 `var _windup_vfx: Node2D = null` 实例句柄；`start_bind()` 在 consume_resonance 成功后 spawn `bind_windup_vfx.gd.new()` 挂到 `get_tree().current_scene`，`trigger(origin, bind_radius * 0.5, windup_time)` 启动；`_execute_bind()` 在 `bind_fired.emit` *之前* free windup_vfx（顺序敏感：bind VFX 同帧 spawn 替换 windup）；新增 `func _exit_tree()` 钩子（**关键 cleanup**：player 在 windup 中被 scene change 销毁，bind_ability 退树时连带 free windup_vfx 防 leak）(10min) <!-- 2026-06-10 02:00 -->
- [x] **T168** Polish EchoAbility 起手 0.08s 玻璃护盾球 0.5×→1.0× 撑开：(1) **新文件** [`src/scripts/echo_windup_vfx.gd`](file:///workspace/src/scripts/echo_windup_vfx.gd) (90 行) — `class_name EchoWindupVFX extends Node2D` 自管理 lifecycle。**与 Pulse/Bind 反向 motion language** —— Pulse/Bind 是 **0.5× → 0.85-0.92× 内缩**（能量聚拢/向内拉），Echo 是 **0.5× → 1.0× 外撑**（盾"砰"地一下弹出接住来袭）。`_draw()` 3 层 painter's order：Layer 1 玻璃填充 `draw_circle` 半径 `lerp(half, full, t)` alpha 0→0.18、Layer 2 高光 rim `draw_arc` 1.5px alpha 0→0.55、Layer 3 中央暖点 `draw_circle(Vector2.ZERO, 2px)` alpha 0→0.45。三色皆来自 EchoVFX palette 维持 verb 调色一致：fill `Color("#69C7CE")` Glass Cyan / rim `Color("#B7E7DD")` Pale Resonance / core `Color("#F2B66E")` Amber Voice。Alpha ramp-in `t / 0.5`（**比 Pulse 的 0.4 更快** — Echo windup 仅 0.08s 短窗口，前 0.04s 必须 readable）。`trigger(origin, half_radius, full_radius, duration)` 4 参数支持 Echo 的 `echo_radius * 0.5 → echo_radius` 撑开范围。(2) **修改** [`src/scripts/echo_ability.gd`](file:///workspace/src/scripts/echo_ability.gd) — 新增 `var _windup_vfx: Node2D = null` 实例句柄；`start_echo()` 在 consume_resonance 成功后 spawn `echo_windup_vfx.gd.new()` 挂到 `get_tree().current_scene`，`trigger(origin, echo_radius * 0.5, echo_radius, windup_time)` 启动；`_execute_echo()` 在 `_is_active = true` 状态翻转 + `echo_fired.emit` *之前* free windup_vfx；新增 `func _exit_tree()` 钩子（**关键 cleanup**：player 在 windup 中被 scene change 销毁，echo_ability 退树时连带 free windup_vfx 防 leak）(10min) <!-- 2026-06-10 02:00 -->
- [x] **F006** Refactor player.gd 4 verb handler 整段提取 `_try_verb()` helper（F005 进阶版）：[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 在文件末尾追加 1 个 `_try_verb()` helper + 4 个 `_start_X_at()` wrapper（`_start_pulse_at` / `_start_bind_at` / `_start_cut_at` / `_start_echo_at`），4 verb handler 各自缩成 1 行委托 `_try_verb("pulse", _start_pulse_at)` 等。**新 `_try_verb(action_name: String, start_fn: Callable) -> void`** —— 5 步中央管道：(1) `_pre_verb_block_check()` 守卫复用 F005 helper → (2) `Input.is_action_just_pressed(action_name)` rising-edge → (3) 在 helper 内计算 `origin = global_position + Vector2(0, -8)` + `dir = Vector2.RIGHT if _facing_right else Vector2.LEFT`（4 verb 共用"头部 8px / 面向方向"公式，与原 handler 字节级一致）→ (4) `start_fn.call(origin, dir)` 委托给 verb 内部 `start_*()`（Echo wrapper 忽略 `dir` 因盾中心 pop 语义）→ (5) 失败时统一 `hud.show_pulse_blocked()` 提示（与原 handler 行为完全一致）。**新 4 个 wrapper** 签名统一 `(origin: Vector2, dir: Vector2) -> bool`，内部 `if ability: return ability.start_X(origin, dir) else: return false`（`else false` 路径让 `_try_verb()` 触发 blocked toast 兜底，**保持 #85 旧语义不变**）。Echo wrapper `_start_echo_at(origin, _dir)` 用下划线前缀标记 `_dir` unused。**4 handler 改写**：`_handle_pulse()` / `_handle_bind()` / `_handle_cut()` / `_handle_echo()` 各自函数体从 8-9 行缩成 1 行。**Wave 排除**：`# F006 (#86) — Why not also include _handle_wave?` docblock 详述 Wave 有 4 个 verb 状态路由（active/winding_up/charging/blocked，T143）需要 4 分支专属 HUD 提示，**不能套这个 1-toast 通用 helper**，`_handle_wave()` 保持原样。**真正价值**：未来加新 guard 条件（"dialogue open"）只需要 OR 进 `_pre_verb_block_check()` 一处；未来加第 6 verb（方向性）只需要写 1 行 `_handle_X()` + 1 个 `_start_X_at()` wrapper (15min) <!-- 2026-06-10 02:00 -->
- **质量门**：37 个 smoke test 全 PASS（无新增，本轮仅源码 + 2 新文件 + 3 改文件 + 0 新测试 — #85 审查通过后零回归历史 + 本轮源码净增 ~245 行未达 500 阈值，**保留 #87 视情况添加 `test_t167_t168_f006_smoke.gd`**），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #86 → 必中 [OK]）。风格 0 漂移（T167 `#65506A` Muted Violet / T168 `#69C7CE`+`#B7E7DD`+`#F2B66E` 3 色皆为 STYLE_GUIDE 限制色板内，不引入新 hex；F006 纯重构不动 gameplay / 视觉 / 音频 / 任何 VFX 数值）。

## #87 已完成（2026-06-10 09:00，普通模式）

- [x] **I005** Info 补 #86 缺测试 `tools/test_t167_t168_f006_smoke.gd`（230 行, **33 项断言全 PASS**）：T167 Bind windup VFX 11 项（bind_windup_vfx.gd 存在 + extends Node2D + Muted Violet `#65506A` + arc_count=3 + _end_scale=0.85 内拉 + lifecycle + bind_ability spawn/free/_exit_tree 顺序 + bind_radius*0.5 透传）+ T168 Echo windup VFX 11 项（echo_windup_vfx.gd 4 参数 trigger 签名 + 3 色 Glass Cyan + Pale Resonance + Amber Voice + _end_scale=1.0 撑开 vs Pulse 0.92/Bind 0.85 内缩反向 + _start_scale=0.5 + lifecycle + echo_ability spawn/free/_exit_tree 顺序 + echo_radius*0.5+echo_radius 4 参数 trigger 调用）+ F006 refactor 8 项（_try_verb() 2 参签名 + 4 个 _start_X_at() wrapper + 4 verb handler 体内 _try_verb 委托 600 char 窗口允许 docblock + _try_verb body 含 3 关键步骤 + _handle_wave 保持原 4 状态路由 + F005 helper 保留 + D001 is_action_globally_blocked 公开函数保留）+ D001 regression + 4 verb 一致性交叉检查 3 项 (5min) <!-- 2026-06-10 09:00 -->
- [x] **T169** Polish CutAbility 起手 0.06s 黄色 line streak pre-cut VFX：(1) **新文件** [`src/scripts/cut_windup_vfx.gd`](file:///workspace/src/scripts/cut_windup_vfx.gd) (61 行) — `class_name CutWindupVFX extends Node2D` **4 verb windup 第 4 视觉 motif** — Pulse ring（0.5×→0.92× 内缩）/ Bind spiral（0.5×→0.85× 旋转内收）/ Echo sphere（0.5×→1.0× 撑开）/ **Cut streak**（0.0×→1.0× 沿 cut 方向延伸，让玩家在 0.06s 前摇中即可辨别哪个 verb 在蓄力，5-verb 链 T142 防误触 UX 提示完整），Amber Voice `#F2B66E` 严格对齐 STYLE_GUIDE 限制色板（**4 verb 调色四元组** Pulse Glass Cyan / Bind Muted Violet / Echo Glass Cyan+Amber Voice / Cut Amber Voice），`trigger(origin, half_radius, direction, duration)` 4 参数签名（与 T168 Echo 对齐），2px stroke 双线 draw_line + 1.5px 垂直偏移防 dark tileset 1px 直线消失，alpha 0→0.7 ramp-in 前 40%（Cut 0.06s 是 4 verb 最短前摇比 Pulse 0.4 更快），scale 0.0→1.0 沿 cut 方向延伸（与 cut_vfx.gd arc swing motion 同向 windup-to-fire 过渡连续）。(2) **修改** [`src/scripts/cut_ability.gd`](file:///workspace/src/scripts/cut_ability.gd) — 新增 `var _windup_vfx: Node2D = null` 句柄 + `start_cut()` 集成 + `_execute_cut()` 顺序敏感 free（cut_vfx.gd 同帧 spawn arc 替换 streak）+ `func _exit_tree()` 钩子（3 道 free 保险同 T166/T167/T168 模式）(10min) <!-- 2026-06-10 09:00 -->
- [x] **F007** Refactor 4 verb ability 内部共享 2 helper 模式（4 verb 各加 byte-identical `_consume_verb_cost(cost: int) -> bool` + `_setup_windup_state(origin, direction) -> void`，GDScript 限制 4 verb 各自重写一份 helper，但命名 + 签名 + docblock 一致，未来 base class `_verb_ability_base.gd` 抽取铺路）：4 verb `start_X()` 顶部 4-5 行（`if not can_X: return false; if not GameState.consume_resonance(X_cost): return false; _is_winding_up = true; _windup_timer = windup_time; _pending_origin = origin; _pending_direction = direction`）缩为 2 行调用（`if not _consume_verb_cost(X_cost): return false; _setup_windup_state(origin, direction)`）；echo_ability 特殊处理 — `start_echo(origin)` 不接收 direction 参数（盾中心 pop 语义）但调用 `_setup_windup_state(origin, Vector2.ZERO)` 保持 4 verb 签名一致，新增 `var _pending_direction: Vector2 = Vector2.ZERO` 字段（不读只用，与 pulse/bind/cut 字段定义 byte-identical）；**3 层 helper 抽象栈** —— F005 player 层 `_pre_verb_block_check` / F006 player 层 `_try_verb` / F007 ability 层 `_consume_verb_cost` + `_setup_windup_state`，未来加 verb 边际成本降到 "1 行 wrapper + 1 个新 ability 文件 + copy-paste 2 helper" (15min) <!-- 2026-06-10 09:00 -->
- **质量门**：38 个 smoke test 全 PASS（37 旧 + 1 新 T167+T168+F006+I005 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #87 → 必中 [OK]）。风格 0 漂移（T169 `#F2B66E` Amber Voice 严格在 STYLE_GUIDE 限制色板内，4 verb 调色 4 元组 Pulse Glass Cyan / Bind Muted Violet / Echo Glass Cyan+Amber Voice / Cut Amber Voice 形成 windup 语言对；F007 纯重构不动 gameplay / 视觉 / 音频 / 任何 VFX 数值）。

## #88 已完成（2026-06-10 14:00，普通模式）

- [x] **T170** Polish 4 verb 命中反馈 VFX 路线（与 T166/T167/T168/T169 windup 路线对偶，本轮并行完成 3 子任务 — T170a 补 Bind 命中缺漏 / T170b 补 Echo 非反弹命中缺漏 / T170c 补 Pulse 命中屏抖）：[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) 改动 1 文件净增 ~50 行。**4 verb 命中反馈色域 4 元组最终对齐**（Pulse Coral / Bind Violet / Cut Amber / Echo Cyan 各自占调色板 1/4 区域），任何 1 verb 命中闪 1ms 内可凭色域识别"是哪个 verb"——这一直是 Voxglass 视觉组的 5 表面层之一，本轮把缺失的 3 块补齐：
  - **T170a** Bind 命中反馈（10min, 1 文件）：`_ready` 中 `bind_ability.bind_hit.connect(_on_bind_hit)`（`if bind_ability.has_signal("bind_hit"):` 守卫保 pre-bind-hit 存档版本兼容老 bind_ability.gd 不带 bind_hit signal 的情况），新增 `_on_bind_hit(target)` handler：`if target == null: return` 守卫（与 pulse_ability.gd 同样约定，bind_ability.gd 在 cast 成功但命中区域无敌人时 emit `bind_hit(null)`）→ `ScreenShake.flash_color(Color(0.398, 0.314, 0.416, 1.0), 0.10, 0.18)`（Muted Violet `#65506A` 是 Bind 主题色，严格对齐 STYLE_GUIDE 限制色板）→ `ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)`（LIGHT 1.0/0.08s 补"钉住"触感，**LIGHT 而非 HEAVY** 因为 Bind 语义"温柔牵制"而非"暴力推开"）。**0.10s / 0.18 数值与 Pulse 命中（T098）严格对称**让 4 verb 反馈节奏统一，未来 4 verb 命中触感可以"听出 1/16 beat 模式"形成"haptic groove"。4 verb 调色 4 元组从 Pulse Coral / Cut Amber / Echo Cyan（3 verb）扩展为 Pulse Coral / **Bind Violet** / Cut Amber / Echo Cyan（4 verb），与 T166 Pulse windup Glass Cyan / T167 Bind windup Muted Violet / T168 Echo windup Glass Cyan+Amber+Glass Cyan / T169 Cut windup Amber Voice 4 verb windup VFX 色域**完美同构**——windup 用 1 色，hit 用另 1 色，每 verb 自带 2 色调色对（windup→hit transition 让玩家"知道这 verb 在充能→充好了打到了"）。
  - **T170b** Echo 命中非反弹反馈（10min, 1 文件）：`_on_echo_hit(target, is_reflect)` 之前 `if not is_reflect: return` 早退无任何屏幕反馈（`echo_ability.gd:278 emit(echo_hit, enemy, false)` 是敌人物理接触护盾被 _apply_bind_to_enemy 短致盲 0 伤的语义路径），现在改为：非反弹路径调 `ScreenShake.flash_color(Color(0.412, 0.78, 0.808, 1.0), 0.06, 0.12)`（Glass Cyan `#69C7CE` 是 Echo 主题色）→ `return`；反弹路径 (T097) 保留 0.08s / 0.20 peak 不变（与 add_bounce_flash VFX 在 enemy 世界坐标的 Coral Pulse 形成「护盾 cyan (施法) → 反弹 cyan (屏幕) + coral (命中点)」双层视觉反馈）。**数值设计 6:3 比例**：反弹 0.20 peak (强烈"成功回击") / 非反弹 0.12 peak (温和"挡住了") = 6:3 比例让"反 > 挡"视觉权重正确，玩家在 0.05s 反射时间内从屏幕闪强度能区分"我弹回去了" vs "我挡住了"——这是 4 verb 中唯一有 sub-verb 反馈分级的，反弹 vs 挡是 Echo 核心 UX 决策点。
  - **T170c** Pulse 命中屏抖（10min, 1 文件）：`_on_pulse_hit(target, _knockback)` 在已有 Coral flash（T098 `flash_color(Color(0.91, 0.427, 0.353, 1.0), 0.10, 0.18)`）之外补 `ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)` (1.0/0.08s) 作为"打到了"补充触觉。**与 `_on_pulse_fired` 的 PULSE 2.0/0.10s shake 间隔 0.05~0.15s 不会重叠**——fire shake 是 0.10s 衰减，hit shake 在 pulse 环扩散 + 敌人距离决定的时间点（0.05~0.15s 后）触发，hit shake 0.08s 才开始 = fire shake 已衰减完，**视觉上是"推→中"两步触觉**而非叠加震。LIGHT 而非 HEAVY 因为 Pulse 单体命中反馈已经很强（环扩散 + 击退 + Coral 闪），多一个 HEAVY 反而喧宾夺主；LIGHT 让 hit 触感"补"在 fire 之上，玩家感到"我的 Pulse 不仅推开了，还把对方钉了一下"。
- [x] **新冒烟测试** `tools/test_t170_smoke.gd` (210 行, **21 项断言全 PASS**)：T170a 段 8 项（`bind_ability.bind_hit.connect(_on_bind_hit)` 存在于 `_ready` 段 / `if bind_ability.has_signal("bind_hit"):` 守卫 / `_on_bind_hit(target: Node) -> void` handler 定义 / `if target == null:` 守卫 / `Color(0.398, 0.314, 0.416, 1.0)` Muted Violet 色 / 完整 `flash_color(...0.10, 0.18)` 调用 / `ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)` / `T170a (#88)` docblock 标记）+ T170b 段 6 项（`if not is_reflect:` 分支保留 / 用 500-char 窗口扫描验证 `if not is_reflect:` 之后调 `flash_color` 而非早退 / `Color(0.412, 0.78, 0.808, 1.0)` Glass Cyan 色 / 完整 `flash_color(...0.06, 0.12)` 非反弹参数 / 反弹路径 `flash_color(...0.08, 0.2)` 无回归 / `T170b (#88)` docblock 标记）+ T170c 段 3 项（`_on_pulse_hit` 内 `shake_preset(LIGHT)` / `T170c (#88)` docblock 标记 / `flash_color(...0.10, 0.18)` Coral flash 无回归）+ **跨任务回归 4 verb 色域分工交叉检查 4 项**（Pulse Coral `#E86D5A` / Bind Violet `#65506A` / Cut Amber `#F2B66E` / Echo Cyan `#69C7CE` 4 色均保留无回滚）。**冒烟测试数量 38→39 套件** (5min) <!-- 2026-06-10 14:00 -->
- **质量门**：39 个 smoke test 全 PASS（38 旧 + 1 新 T170 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #88 → 必中 [OK]）。风格 0 漂移（T170a `#65506A` Muted Violet / T170b `#69C7CE` Glass Cyan / T170c 复用 T098 `#E86D5A` Coral Pulse — 严格在 STYLE_GUIDE 限制色板内，**4 verb 命中色 4 元组 Pulse Coral / Bind Violet / Cut Amber / Echo Cyan 全部在限制色板内**，无 #4 板外颜色；3 个反馈都是 ScreenShake autoload 调用，0 个新 Node2D VFX 节点 / 0 个新 `_process` 开销）。

## #89 已完成（2026-06-10 19:00，普通模式）

- [x] **T171** Polish WaveAbility 0.5× Pale Resonance 3 环 halo windup VFX（5 verb windup 家族最后 1 个缺漏闭环）：新建 [`src/scripts/wave_windup_vfx.gd`](file:///workspace/src/scripts/wave_windup_vfx.gd)（110 行 `class_name WaveWindupVFX extends Node2D`）+ 修改 [`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) `start_wave()` +25 行。**5 verb windup 调色五元组正式闭环**（Pulse Cyan `#69C7CE` / Bind Violet `#65506A` / Cut Amber `#F2B66E` / Echo Cyan `#69C7CE` / Wave Pale Resonance `#B7E7DD`）。**设计决策**：
  - **颜色 Pale Resonance `#B7E7DD`**：比 Pulse Cyan 更冷更"光"（RGB ≈ 0.717/0.906/0.866 蓝色占比 < 0.1 → 几乎纯白微青），与 Wave "AOE 中心爆发而非定向打击" 语义匹配——色温"穿透力最强"，AOE 一波全清时 Wave 颜色应"压全场"；4 verb 各自 1.5px 描边维持 4 verb 调色板分工（Pulse windup `#69C7CE` / Bind windup `#65506A` / Echo windup `#69C7CE` / Cut windup `#F2B66E`）
  - **3 环 concentric halo 主题**：r_ratio [0.40, 0.65, 0.92]（ring 0 内 0.40× / ring 1 中 0.65× / ring 2 外 0.92×），3 环填满 0.5× half-radius 盒而不重叠 fire VFX 的 0×→1.0× 扩张区
  - **per-ring alpha_mult [0.55, 0.78, 1.0]**：外环最亮（1.0）= "声波前导"（leading edge of sound），中环 0.78，内环 0.55（so the trio reads as "echoes trailing behind", not a solid disc）
  - **phase_offset [0.0, 0.18, 0.36]**：3 环 alpha 渐入 staggered 0.18/0.36——ring 0 t=0.0 达峰，ring 1 t=0.18 达峰，ring 2 t=0.36 达峰（视觉结果是 halo 在 windup 期间"向外绽放"——**Sound radiating** 主题，与 4 verb 1.0→0.92 收缩 ring / 1.0→0.85 螺旋 arcs / 0.5→1.0 球 / 0.0→1.0 streak 4 个主题区分）
  - **peak_alpha 0.65**：比 PulseWindupVFX 0.70 略低 0.05——"比空气还轻的 verb"，transient 非 solid 屏障
  - **ring_width 1.2**：比 4 verb 1.5px 细 0.3px——3 环同时存在需要视觉层次，1.2 让最外环 0.92× size 仍清晰但不喧宾夺主
  - **integrate in start_wave()**：`preload("res://src/scripts/wave_windup_vfx.gd").new()` + `trigger(_pending_origin, wave_radius * 0.5, windup_time)` + `scene.add_child(windup_vfx)`（**preload 而非 class_name 引用**——与 4 verb 家族一致，preload 是 path-based 引用，headless smoke test 中 class registration 可能滞后，preload 让 load-order 决定性；**0.5× radius**——4 verb 家族一致 "precursor 而非 fire"；**挂到 current_scene 而非 player 子节点**——5 verb 家族一致：ring 位置稳定在世界坐标，player 移动时 ring 不跟着走，让 0.10s 期间 halo 是"我留在原地的 0.5s 警告"而非"我跟随玩家的拖尾"）
- [x] **T170d** Polish Cut 命中屏抖（_on_cut_hit 已有 Amber flash (T098) + _on_cut_fired shake (T089)，本轮决定加 LIGHT 1.0/0.08s shake 闭环 4 verb 命中屏抖分工）：[`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_on_cut_hit(_target)` 在 `flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)` 之后追加 `shake_preset(ScreenShake.Preset.LIGHT)`。**4 verb 命中屏抖 1.0/0.08s LIGHT 数值统一**：
  - **与 T170c Pulse 命中屏抖完全同构**：`shake_preset(LIGHT 1.0/0.08s)` 在 fire shake 之后 0.03~0.10s 触发 = "挥→中" 两步触觉；CUT 1.5/0.06s fire shake 衰减完（0.06s）= LIGHT 1.0/0.08s hit shake 才开始（0.08s），**不重叠**
  - **max_targets=6 多目标风险由 ScreenShake tween 内部 dedupe 兜底**：`_perform_arc_hit_check` 在同一帧遍历并逐个 emit cut_hit，ScreenShake.shake_preset 内部用 tween 重新启动（"新 shake 覆盖旧 shake"语义，参考 T170c 注释"最后命中那下为准"），6 个 hit 也只看到 1 次 0.08s LIGHT 抖动，与 Pulse 多目标场景行为完全一致
  - **LIGHT 而非 HEAVY**：Cut 单体命中反馈已经很强（弧扩散 + 击退 + Amber 闪 + 声音 cue），HEAVY 喧宾夺主
  - **Amber flash 无回归**：`flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)` 保留
- [x] **新冒烟测试** `tools/test_t171_t170d_smoke.gd` (152 行, **18 项断言全 PASS**)：T171 段 10 项（`class_name WaveWindupVFX` 声明 / `extends Node2D` 与 4 verb 一致 / `trigger(origin, half_radius, duration)` 签名匹配 4 verb 家族 / `Color("#B7E7DD")` Pale Resonance 第 5 色 / `@export var ring_count: int = 3` 默认 3 环 / `z_index = 10` above world below HUD / `queue_free()` safety net / `T171 (#89)` docblock 标记 / docblock 含 "ripple outward" sound-wave motif 关键词 / `STYLE_GUIDE` 引用作为色域来源权威）+ T171 集成段 4 项（`resonance_wave_ability.gd:start_wave` 内 `preload("res://src/scripts/wave_windup_vfx.gd").new()` 存在 / 完整 `trigger(_pending_origin, wave_radius * 0.5, windup_time)` 调用 / `scene.add_child(windup_vfx)` 挂到 current_scene / `T171 (#89)` docblock 标记在 resonance_wave_ability.gd）+ T170d 段 4 项（`_on_cut_hit` 内 `ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)` 调用 / `T170d (#89)` docblock 标记 / 完整 `flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)` Amber flash 无回归 / `if ScreenShake and ScreenShake.has_method("shake_preset"):` 守卫保留）。**冒烟测试数量 39→40 套件** (10min) <!-- 2026-06-10 19:00 -->
- **质量门**：40 个 smoke test 全 PASS（39 旧 + 1 新 T171+T170d 合并），0 新增 SCRIPT ERROR，0 parse error，runtime 0 exception。`tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步：本轮 commit 时同步把双 README 升级到 #89 → 必中 [OK]）。风格 0 漂移（T171 `#B7E7DD` Pale Resonance 严格在 STYLE_GUIDE 限制色板内，**5 verb windup 五元组 Pulse Cyan / Bind Violet / Cut Amber / Echo Cyan / Wave Pale 全部在限制色板内**；T170d 复用 T098 Amber `#F2B66E` + LIGHT preset，**4 verb 命中反馈色 4 元组 + LIGHT 0.08s 屏抖分工 5 元组**完整；T171 1 个新 Node2D VFX 节点，_process 单次 increment delta + queue_redraw，**0.10s 生命周期**，0 持续 _process 开销；T170d 0 个新 Node，0 个新 _process）。

## #90 已完成（2026-06-10 20:00，审查模式）

- [x] **审查 #90（主）**：完整代码质量 / 玩法 / 素材 / 文档审计。**质量门**：0 SCRIPT ERROR / 0 Parse Error（`godot --headless --quit --path /workspace` 静态解析 0 错）/ 0 runtime ERROR（`--headless` 启动 0 错，仅已知 ObjectDB leak warning 与 #60+ 良性告警一致）/ 55 个 `.gd` 文件 / 52 个 class_name 全局唯一（+4 windup classes 来自 #86 T167 Bind + #86 T168 Echo + #89 T171 Wave + 1 stable）/ 69 signal 声明 / 29 个 `.tscn` / 8 个 `.json` 全 json.load() PASS / 7 autoload 一致（`GameState` / `PlayerStats` / `SaveSystem` / `AudioManager` / `AudioManagerEnhanced` / `ScreenShake` / `PlayerActionGate`）/ 0 TODO/FIXME/HACK / 114 PNG 100% 合法（PNG 魔数 `\x89PNG\r\n\x1a\n` 严格匹配 0 损坏）/ **102 个 .uid 文件 0 空文件**（本轮修复 #86 留下的 2 个空 .uid：`bind_windup_vfx.gd.uid` 0B → 20B `uid://bh4oc6o1wkpl6` / `echo_windup_vfx.gd.uid` 0B → 20B `uid://clcrt5damt18k`，由 `rm` + `godot --headless --import` 重新生成）/ ASSET_REGISTRY 72 条 / 40 套件 smoke test **40/40 100% PASS**（L001 修复后重测 0 回归）/ `tools/check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步 hook 由 #85 F002 引入已工作） / runtime 0 exception。**严重 0 / 一般 0 / 轻微 1（L001 已修） / 信息 1（F004 audio 闭环建议下个 5 轮间隔 #91-#95 集中做）**：
  - **L001 修复完成（5min, 2 文件）**：`rm` 2 个空 .uid 文件 + `godot --headless --path /workspace --import` 重新生成 import 缓存 + 重测 40 套件 smoke test 100% PASS（BindWindupVFX `uid://bh4oc6o1wkpl6` / EchoWindupVFX `uid://clcrt5damt18k`）。**L001 累计原因**：`uid_cache.bin` 在 #86 时未注册 bind/echo 2 个 windup 脚本（其他 3 verb 已有 cache），`godot --import` 阶段脚本无 class registration 触发 `.uid` 写入失败（生成 0B 占位文件）。**修复方式**：`rm` 让 Godot 重新尝试注册。下次注意：新建带 `class_name` 的脚本后必须 `godot --headless --import` 一次才能生成 valid .uid；本轮把这条经验也写进 CONTRIB.md 留作 F008 信息。
  - **5 verb windup 闭环最终态**（审计结论）：5 个 `class_name extends Node2D` 类（`PulseWindupVFX` Glass Cyan `#69C7CE` 1.0×→0.92× 收缩 ring T166 #85 / `BindWindupVFX` Muted Violet `#65506A` 1.0×→0.85× 螺旋内收 T167 #86 / `EchoWindupVFX` Glass Cyan + Pale + Amber 三色 0.5×→1.0× 球外撑 T168 #86 / `CutWindupVFX` Amber `#F2B66E` 0.0×→1.0× streak 横扫 T169 #87 / `WaveWindupVFX` Pale Resonance `#B7E7DD` 3 环 ripple outward T171 #89），`trigger(origin, half_radius, duration)` 签名一致，**5 verb motif 全部独立**（Pulse 收缩 / Bind 螺旋 / Echo 撑开 / Cut 横扫 / Wave 涟漪），5 verb 色严格在 STYLE_GUIDE 限制色板内，0 板外色
  - **4 verb 命中反馈闭环最终态**（审计结论）：Pulse Coral `#E86D5A` (0.91, 0.427, 0.353) flash 0.10s/0.18 + Bind Violet `#65506A` (0.398, 0.314, 0.416) flash 0.10s/0.18 + Cut Amber `#F2B66E` (0.949, 0.714, 0.431) flash 0.09s/0.18 + Echo Cyan `#69C7CE` (0.412, 0.78, 0.808) flash 反射 0.08s/0.20 / 非反射 0.06s/0.12 4 verb 命中色 4 元组 + 4 verb LIGHT 1.0/0.08s 屏抖 5 元组完全统一（来自 T170a/b/c/d #88-#89，**4 verb 命中节奏"1/16 beat groove"**）
  - **风格漂移评估**：5 verb windup 5 色 + 4 verb 命中 4 色 = 9 独立色值全部在 STYLE_GUIDE 限制色板内（#69C7CE / #65506A / #F2B66E / #B7E7DD / #E86D5A 5 个核心色），0 板外色
- **完整审查报告**：[REVIEW_LOG.md](file:///workspace/REVIEW_LOG.md) `## 审查 #90 — 2026-06-10T20:00+08:00` 段（约 145 行详细报告含 5 verb windup motif 五元组 / 4 verb 命中色四元组 / 5 verb windup 五元组色域 / 风格漂移 / Godot 运行时回归 / 下一轮候选等）
- **下一轮（#91，N%5≠0，普通模式）建议候选**（按 ITERATION_GUIDE.md §2.1 候选评分）：
  - **F004 [信息优先]** Audio 5 verb 闭环 — Echo / Bind / Wave 3 verb 的 verb-fire + hit + 冷却 3 段 audio cue（与 T146 wave_combo chime tail + T098 5 verb 命中色域对偶的 audio 维度闭环）(30min) — **下个 5 轮间隔 #91-#95 集中做**
  - **T172** [候选] Polish T165 ScreenShake.flash_color 重构后补 4 verb 命中色在 ScreenShake 端的查表常量（让 4 verb 命中色 4 元组从一个常量数组出，避免 `Color(0.91, 0.427, 0.353, 1.0)` 字面值在 4 处复写）(10min)
  - **T173** [候选] Polish 5 verb windup VFX 退出时若被打断（如 player 死亡 / 场景切换）补 0.05s 淡出 tween（目前 queue_free 立即销毁会"破影"，5 verb 5 windup 一致 fade-out 0.05s）(15min)
  - **L002** [信息] Doc README.zh-CN.md "Recent work" 与 README.md 同步检查 — 现有 rule 7 已能 PASS，但 ROADMAP #89 段中文版未单独维护（如需中文独立同步可加 rule 8，但目前未触发；记录备查）(5min)
  - **F008** [信息] Doc `CONTRIBUTING.md` 补"新建 class_name 脚本必须 `godot --headless --import` 一次生成 valid .uid"经验（L001 根因 + 修复方式，避免 #86 4 轮欠账重演）(5min)
- **质量门**：0 SCRIPT ERROR + 0 parse error + runtime 0 exception + 40 smoke test 套件 40/40 PASS + `tools/check_smoke_consistency.sh` 7/7 规则 PASS。风格 0 漂移（修复不涉及新增色 / 数值 / 时序；仅修复 .uid 文件合法性）。**整体评分：优秀**（与 #75 #80 #85 一致 — 0 严重 / 0 一般 / 1 轻微已修 / 1 信息）。 (45min) <!-- 2026-06-10 20:00 -->

## #92 已完成（2026-06-10 21:00，普通模式）

#90 审查建议的 5 轮间隔 #92-#96 集中做（信号 [信息]）的 5 个候选中，**T173 / F008 / L002** 三个全部落地（T172 / F004 [信息] 候选项被本轮确认 subsumed/下移）；**T173.C**（#89 T171 漏判的 `resonance_wave_ability._exit_tree()` 钩子缺漏）也顺手补全，**5 verb `_exit_tree` 家族正式一致**。新增 `I007` 49 项 smoke 测试（I006 #89 → I007 #91 测试套件 +1）。

- [x] **T173** Polish 5 verb windup VFX 退出时 0.05s 淡出 tween（"VFX 退出家族"）：5 verb windup VFX 各自新增 `func fade_out_and_free() -> void`（实现一致 + byte-identical 可复制给未来 6th verb 接入），步骤：`(1) if not _active: queue_free() return` 早退守卫（idempotent 防御重入）→ `(2) _active = false` 停 `_process` 避免与 tween 竞速 → `(3) var start_alpha: float = modulate.a` 捕获当前透明度 → `(4) var tween := create_tween()` + `tween.tween_property(self, "modulate:a", 0.0, 0.05)`（`"modulate:a"` Godot 4 tween 语法从 1.0→0.0 0.05s TRANS_QUAD EASE_OUT 平滑淡出）→ `(5) tween.tween_callback(queue_free)` 淡出结束自动 free。修改 5 文件 [`src/scripts/pulse_windup_vfx.gd`](file:///workspace/src/scripts/pulse_windup_vfx.gd) / [`src/scripts/bind_windup_vfx.gd`](file:///workspace/src/scripts/bind_windup_vfx.gd) / [`src/scripts/echo_windup_vfx.gd`](file:///workspace/src/scripts/echo_windup_vfx.gd) / [`src/scripts/cut_windup_vfx.gd`](file:///workspace/src/scripts/cut_windup_vfx.gd) / [`src/scripts/wave_windup_vfx.gd`](file:///workspace/src/scripts/wave_windup_vfx.gd) 5 文件 +23 行（5 × ~5 行实现 + 5 × 12 行 docblock）；0.05s 0.4× room transition duration 让 VFX 永远在下一房间 load 前 vanish（无视觉残留）；fade-out 是 queued-free 同帧触发无 overlap（5 verb 一致） (15min) <!-- 2026-06-10 22:00 -->
- [x] **T173.B** Polish 4 verb ability `_exit_tree()` 从硬 `_windup_vfx.queue_free()` 切换为 `_windup_vfx.fade_out_and_free()`：修改 [`src/scripts/pulse_ability.gd`](file:///workspace/src/scripts/pulse_ability.gd) / [`src/scripts/bind_ability.gd`](file:///workspace/src/scripts/bind_ability.gd) / [`src/scripts/echo_ability.gd`](file:///workspace/src/scripts/echo_ability.gd) / [`src/scripts/cut_ability.gd`](file:///workspace/src/scripts/cut_ability.gd) 4 文件各 +3 行 + 10 行 docblock，让 player 死亡 / 场景切换打断 windup（0.04~0.10s 窗口）时 VFX 平滑淡出而非硬 pop；start_*/_execute_* 内的硬 `_windup_vfx.queue_free()` 保留（**合法保留**理由：start_* 的 defensive cleanup 用于清 leaked VFX，_execute_* 在 fire 帧立刻把 windup 替换为 fire VFX——硬切换是设计意图） (5min) <!-- 2026-06-10 22:00 -->
- [x] **T173.C** Code 补 `resonance_wave_ability._exit_tree()` 钩子（#89 T171 漏判，Wave 是 5 verb ability 中**唯一缺 `_exit_tree()`**）：(a) `var _windup_vfx: Node2D = null` 成员句柄（与 4 verb 句柄命名一致）→ (b) `start_wave()` 在 `scene.add_child(windup_vfx)` 之后追加 `_windup_vfx = windup_vfx` 把 spawn 局部变量存到成员 → (c) 文件末尾追加 `_exit_tree()` 函数（15 行 + 12 行 docblock）调 `fade_out_and_free()` + 清句柄。**5 verb _exit_tree 家族正式一致** —— Pulse T166 / Bind T167 / Echo T168 / Cut T169 / Wave T173 (5min) <!-- 2026-06-10 22:00 -->
- [x] **I007** Info 新增 5 verb windup 淡出 tween smoke 测试 `tools/test_t173_windup_fadeout_smoke.gd` (158 行, **49 项断言全 PASS**) —— T173.A 5 verb × 6 断言 = 30 锚点（fade_out_and_free 函数声明 / create_tween 存在 / `"modulate:a", 0.0` 终值 / `0.05` 时长 / queue_free 结束 / T173 (#92) docblock 标记） + T173.B 4 verb ability × 4 断言 = 16 锚点（_exit_tree 函数存在 / fade_out_and_free 调用 / _exit_tree 函数体内**不**再含 _windup_vfx.queue_free()——通过 `_extract_exit_tree_body()` 提取函数体限定 scope，避免 start_*/_execute_* 合法硬 queue_free 误报 / T173 docblock 标记） + T173.C 3 锚点（Wave _exit_tree 存在 / fade_out_and_free 调用 / docblock 标记）。**额外修复**：T165/T166/F005 旧测试 `t166_ability.rfind("pulse_windup_vfx.gd")` 模式被 T173 docblock 注释（"See pulse_windup_vfx.gd:fade_out_and_free"）骗到错误位置（rfind 找到 docblock 注释而非 start_pulse() 内的 preload 真实调用），改为"从 func start_pulse 头到 func _execute_pulse 头区间内 find + 跳过 docblock 误报"的鲁棒模式；T167/T168/F006 旧测试 2 处 `bind_windup_vfx.gd` / `echo_windup_vfx.gd` 同样问题同法修。**冒烟测试数量 40→41 套件** (5min) <!-- 2026-06-10 22:00 -->
- [x] **F008** Doc CONTRIBUTING.md 补"新建 class_name 脚本必须 --import 一次生成 valid .uid"经验（**已在 #90 落地** —— `CONTRIBUTING.md` §2.2.1 已包含完整 32 行经验段：3 触发场景按频率排序 + 3 预防措施 + §8 故障排查表 `<script>.gd.uid 0 字节（**L001 #90**）` 行；本轮 L002 验证 rule 7 hook 自动 PASS 无需手动补内容）(2min) <!-- 2026-06-10 22:00 -->
- [x] **L002** Doc `README.md` + `README.zh-CN.md` "Recent completed work" / "最近完成的工作" 段同步 #91（**已在 #90 末尾预留 #91 占位** —— 上轮 #90 结束 pre-populated #91 段；本轮更新内容反映 T173 + T173.C + I007 实际落地范围，不是 T172 / F008 旧的占位内容）(3min) <!-- 2026-06-10 22:00 -->

- **质量门**：0 SCRIPT ERROR + 0 parse error + runtime 0 exception + **41 smoke test 套件 41/41 PASS**（与 #90 比 +1：I007 T173.WindupFadeout）+ `tools/check_smoke_consistency.sh` 7/7 规则 PASS。**整体评分：优秀**（与 #85 #90 一致 — 0 严重 / 0 一般 / 0 轻微 / 0 信息）。**5 verb windup "VFX 退出家族"最终态** —— 5 verb 5 元组 (Pulse / Bind / Echo / Cut / Wave) × 2 钩子 (`fade_out_and_free` + `start_*` `_windup_vfx` 句柄) × 1 退出点 (`_exit_tree` 调 `fade_out_and_free`) 全部统一，5 份 `fade_out_and_free` 实现 byte-identical 可作为 6th verb 接入模板。**回归修复**：T165/T166/F005 + T167/T168/F006 共 2 套件 3 处断言因 T173 docblock 注释与目标字符串 `pulse_windup_vfx.gd` 重叠而误判（rfind 模式脆弱），改为"区间内 find + 跳过 docblock"鲁棒模式。 (35min) <!-- 2026-06-10 22:00 -->

## #93 已完成（2026-06-11 22:00，普通模式）

#92 候选池 5 项中**T174 + L003** 2 项落地；F004 评估后继续延后（30min 跨任务太重，**1/5 进度推 #94 起点 = 1 段 audio cue**）；F009 + D002 顺延到 #94 候选池。

- [x] **T174** Polish 5 verb windup VFX ramp-in 阶段也用 tween 平滑（与 #92 T173 ramp-out 对偶，"VFX 进入家族"正式闭环）：5 verb windup VFX `trigger()` 函数体追加 4 行 ramp-in tween — `(1) modulate.a = 0.0` 显式初始化（保证 tween 起点一致）→ `(2) var ramp_tween := create_tween()` 创建 tween → `(3) tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)` 二次曲线 + 缓出（front-load 可见性，让短 windup 也读得清）→ `(4) tween.tween_property(self, "modulate:a", 1.0, _max_lifetime)` 全 windup 时长 ramp-in 1.0。`_draw()` 内同步移除旧 `var alpha_t := clampf(t / 0.4, 0, 1)`（Pulse/Bind/Cut）或 `clampf(t / 0.5, 0, 1)`（Echo）或 `clampf((t - phase_offset) / 0.4, 0, 1)`（Wave 3 环 ripple）线性 ramp，`col.a` 改为常量 peak 由 modulate.a tween 驱动全局 fade-in。修改 5 文件 [`src/scripts/pulse_windup_vfx.gd`](file:///workspace/src/scripts/pulse_windup_vfx.gd) / [`src/scripts/bind_windup_vfx.gd`](file:///workspace/src/scripts/bind_windup_vfx.gd) / [`src/scripts/echo_windup_vfx.gd`](file:///workspace/src/scripts/echo_windup_vfx.gd) / [`src/scripts/cut_windup_vfx.gd`](file:///workspace/src/scripts/cut_windup_vfx.gd) / [`src/scripts/wave_windup_vfx.gd`](file:///workspace/src/scripts/wave_windup_vfx.gd) 5 文件 +13 行（5 × 4 行实现 + 5 × 9 行 docblock）；**5 verb ramp-in 一致性**：5 份 trigger() tween 实现 byte-identical（modulate.a=0.0 起点 + TRANS_QUAD EASE_OUT 曲线 + 1.0 终值 + _max_lifetime 时长）可作为 6th verb 接入模板；5 verb 共用 tween 曲线让 0.04s Cut（短）/ 0.10s Pulse/Bind/Wave（长）都有相同 "ramp-up then settle" 视觉节奏，玩家学到一次 ramp-in 曲线就 apply 全 5 verb。**Wave 旧 ripple 折衷**：Wave 旧 3 环 phase_offset 涟漪（ring 0 t=0.0 / ring 1 t=0.18 / ring 2 t=0.36）改为 3 环同时 fade-in（仅保留 r_ratio 0.40/0.65/0.92 半径差 + ring_alpha_mult 0.55/0.78/1.0 亮度差），ripple 涟漪感由"时序错位"转为"空间层次"——更简单可预测，且与其他 4 verb 的 tween 曲线严格一致 (15min) <!-- 2026-06-11 22:00 -->
- [x] **I008** Info 新增 5 verb windup ramp-in tween smoke 测试 `tools/test_t174_windup_rampin_smoke.gd` (110 行, **40 项断言全 PASS**) —— T174.A 5 verb × 8 断言 = 40 锚点：(1) trigger() 内 `modulate.a = 0.0` 显式初始化 → (2) trigger() 内 `create_tween()` 存在 → (3) tween 终值 `"modulate:a", 1.0` 字符串锚定（Godot 4 tween 语法）→ (4) tween duration 引用 `_max_lifetime`（不是硬编码常量，保证 windup_time 改了自动同步）→ (5) `Tween.TRANS_QUAD` 二次曲线（不是 LINEAR 平移回退）→ (6) `Tween.EASE_OUT` 缓出（前段快后段慢，符合"ring 出现"视觉直觉）→ (7) `T174 (#93)` docblock 标记 → (8) 旧 `alpha_t := clampf(t / X, ...)` 线性 ramp 严格从源代码中删除（**双重严格**：先按行分割源码 + 跳过注释行 + 找 `alpha_t := clampf(t /` 模式，避免误命中 `var t := clampf(_lifetime / ...)` 这种合法的 lifetime 线性进展）。**冒烟测试数量 41→42 套件** (5min) <!-- 2026-06-11 22:00 -->
- [x] **L003** Doc `README.md` + `README.zh-CN.md` "Recent completed work" / "最近完成的工作" 段同步 #92（**已在 #91 末尾预留 #92 占位** —— 上轮 #91 结束 pre-populated #92 段；本轮更新内容反映 T174 + I008 实际落地范围，不是 T172 / F008 旧的占位内容）(2min) <!-- 2026-06-11 22:00 -->

- **质量门**：0 SCRIPT ERROR + 0 parse error + runtime 0 exception + **42 smoke test 套件 42/42 PASS**（与 #92 比 +1：I008 T174.WindupRampin）+ `tools/check_smoke_consistency.sh` 7/7 规则 PASS。**整体评分：优秀**（与 #92 一致 — 0 严重 / 0 一般 / 0 轻微 / 0 信息）。**5 verb windup "VFX 进入+退出家族"双闭环最终态** —— 进入侧（T174 0.04~0.10s ramp-in tween）+ 退出侧（T173 0.05s ramp-out tween）+ 中段（fire VFX takes over 同帧无 overlap）三段时间轴都统一为 tween 曲线，5 份 trigger() ramp-in 实现 byte-identical + 5 份 fade_out_and_free ramp-out 实现 byte-identical，可作为 6th verb 接入模板。 (22min) <!-- 2026-06-11 22:00 -->

#94 候选池（来自 #93 落地评估）：
- **T174.B** [候选] Code test base 抽取：将 5 verb windup VFX 的 4 行 tween 代码（modulate.a=0.0 + create_tween + TRANS_QUAD EASE_OUT + tween_property）抽到 `_WindupVFXBase` 父类（注意 GDScript no-cross-script-inheritance 限制，需用 `class_name _VerbWindupVFXBase extends Node2D` 父类 + 5 verb extends 该父类 + abstract `func _get_peak_alpha() -> float` 虚函数，**D002 的轻量版预演**）(20min)
- **F004** [信息] Audio 5 verb 闭环（#90 审查建议 5 轮间隔 #91-#95 集中做，#92 评估 #93 评估后**本轮 1/5 进度：1 verb = Pulse 已有 play_pulse() 但无 caller，本轮可在 1 verb ability 加 1 行 `AudioManagerEnhanced.play_pulse()` 调用把 fire SFX 闭环**）(10min)
- **F009** [信息] Doc `STYLE_GUIDE.md` 加 4 verb 命中色查表常量定义段（5min，T172 的 4 元组本身值得在 STYLE_GUIDE 独立段固化）
- **L004** [信息] Doc README "Screenshots" 节补 VFX 链 ramp-in/ramp-out 双闭环示例（10min）

#93 候选池（来自 #92 落地评估）：
- **F004** [信息] Audio 5 verb 闭环（30min，#90 审查建议 5 轮间隔 #91-#95 集中做 —— **本轮 #91 评估后延后到 #92-#95**：Pulse `play_pulse()` 已在 `audio_manager_enhanced.gd` 定义但无 caller，Bind/Cut/Echo/WaveFire 4 stream 尚未生成，且 5 verb 各需 fire + hit + cooldown 3 段 audio cue —— 3 verb × 3 cue = 9 cue + 5 verb stream 集成 = ~30min 跨任务，**5 轮间隔 = 2 cue/轮**）
- **T172** [候选] Polish ScreenShake 4 verb 命中色查表常量（**已在 #90 review 之前 subsumed** —— `ScreenShake.VERB_HIT_PULSE_COLOR` / `VERB_HIT_BIND_COLOR` / `VERB_HIT_CUT_COLOR` / `VERB_HIT_ECHO_COLOR` 4 const 已在 `screen_shake.gd` 定义，`player.gd` 5 处调用点全部走常量引用，`test_t170_smoke.gd` + `test_t171_t170d_smoke.gd` + `test_t098_t100_smoke.gd` 3 套件已验）
- **F009** [信息] Doc STYLE_GUIDE.md 加 4 verb 命中色查表常量定义段（5min，T172 的 4 元组本身值得在 STYLE_GUIDE 独立段固化）
- **L003** [信息] Doc README "Screenshots" 节补 VFX 链示例（10min）
- **T174** [候选] Polish 5 verb windup VFX ramp-in 阶段也用 tween 平滑（与 T173 ramp-out 对偶，让 0.04~0.10s windup 启动也是平滑曲线而非 `_active=true → 帧 0 全亮度 pop`）(15min)
- **D002** [信息] Code base class 抽取：`_verb_ability_base.gd` 把 4 verb (Pulse/Bind/Cut/Echo) + Wave 的公共方法 (`_consume_verb_cost` / `_setup_windup_state` / `_exit_tree` / `_windup_vfx` 句柄) 真正抽取成基类（**#87 F007 保守版是 byte-identical copy**，未抽 base class；本任务是真抽，需要处理 5 verb 各自 method override 的细节差异）(30min)

#88 候选池（已落地 T170）：
- ~~T170 [候选] Polish 4 verb 命中 VFX 路线（与 T166/T167/T168/T169 windup 路线对偶）~~ → 已在 #88 落地（**T170a Bind 命中反馈** + **T170b Echo 命中非反弹反馈** + **T170c Pulse 命中屏抖** 3 子任务并行完成，**T170d Cut 命中屏抖** 保留为 #89 候选因 Cut 命中反馈 design 决定先评估"边际价值"）

#87 候选池（已落地 I005+T169+F007）：
- ~~I005 [候选] Info 视情况添加 `tools/test_t167_t168_f006_smoke.gd` 冒烟测试（仿 #84 / #85 模板，~200 行覆盖 3 任务 18+ 项断言）~~ → 已在 #87 落地（实际 230 行 33 项断言）
- ~~T169 [候选] Polish CutAbility 起手 0.06s 黄色 line streak pre-cut 视觉信号（与 T166/T167/T168 一致节奏统一 4 verb windup 语言）~~ → 已在 #87 落地（实际 Cut windup 0.04s 仍是 instant-fire，但加 0.06s windup VFX **叠加**在 0.04s fire 上即变成 0.06s 总前摇——这是设计变更，候选标"0.06s pre-cut 视觉"实际是"0.06s pre-cut + 0.04s fire" = 0.10s 总耗时，与 Pulse 0.10s + Bind 0.10s 节奏统一，**未来需要评估**是否调整 cut_ability.windup_time 0.04→0.06 让节奏完全统一）
- ~~F007 [候选] Tech debt: 提取 4 verb 的 `start_pulse/start_bind/start_cut/start_echo` 公共 "ability-null + cost + cooldown 守卫" 整段到 `_try_verb_ability()` helper~~ → 已在 #87 落地（保守版 4 verb 内部 helper byte-identical copy，未引入 base class——base class 抽取为 #88 候选 F007b）
- ~~T164 [候选] Polish InkWarden phase 3 dissolve~~ → #87 延后到 #88 候选（phase 3 锚点仍不明，**先确定 _break_shield / _enter_stun / _purify 哪个算 phase 3**）

#86 候选池（已落地 T167+T168+F006）：
- ~~T167 [候选] Polish BindAbility windup 加 pre-bind 视觉信号（与 T166 Pulse 同模式，0.5× 收缩圆环，Bind Purple #65506A 主色）(10min)~~ → 已在 #86 落地
- ~~T168 [候选] Polish EchoAbility 起手 0.10s 玻璃护盾球 0.5× 缩小 → 1.0× 撑开（pre-emptive 视觉信号，Glass Cyan）(10min)~~ → 已在 #86 落地
- ~~F006 [候选] Tech debt: 提取 4 verb handler 整段为 `_try_verb()` helper（F005 进阶版）(25min)~~ → 已在 #86 落地（实际 15min 比预算 25min 快，因为 4 verb handler 公共路径在 F005 已被注释明确，wrapper 设计 1 改 1 步到位）

#85 候选池（已落地 T165+T166+F005）：
- ~~T165 [候选] Polish BGM tier-up visual cue (audio_manager_enhanced._on_tier_up 链入 brief 0.15s Glass Cyan 闪) (10min)~~ → 已在 #85 落地
- ~~T166 [候选] Polish PulseAbility windup 0.10s 加 0.5× 圆环 pre-pulse（pre-emptive 视觉信号让玩家更易预判）(15min)~~ → 已在 #85 落地
- ~~F005 [候选] Tech debt: 提取 `player.gd` `_handle_pulse` / `_handle_bind` / `_handle_cut` / `_handle_echo` 公共 OR 守卫到 `_pre_verb_block_check()` helper (减少 4 处 `is_action_globally_blocked` 重复) (15min)~~ → 已在 #85 落地（实际 10min 比预算 15min 快，因为 4 处调用形式已统一到一行 `is_action_globally_blocked()`，只需改名 + 加 wrapper）

#84 候选池（已落地 T101+T163+F004）：
- ~~T101 [候选] Polish ResonanceWave 命中粒子层叠（echo-style 多层 visual group，8→12 层）(15min)~~ → 已在 #84 落地
- ~~T163 [候选] Code ScreenShake.flash_color / flash_grayscale 接受可选 `[layer]` 参数（与 T161 RestoreAll 同 UI 一致）(10min)~~ → 已在 #84 落地
- ~~F004 [信息] Doc/test 修复 pre-existing 3 套件 stale-state 冒烟测试：`test_t150_t147_t149_smoke` 1800 char window 扩展到 4500 char 覆盖 _handle_jump 完整函数体 / `test_t158_t156_f002_smoke` F002.7/F002.8 self-test 解硬编码 #81 → 动态读 ITERATION_COUNT.txt - 1 / `test_t150_t147_t149_smoke` 部分 T147 守卫与 #76 重构同步（20min）~~ → 已在 #84 落地（实际 1800→2500，4500 偏大）
