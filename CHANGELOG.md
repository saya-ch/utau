# Changelog

> **归档策略**：保留 **#72 ~ #71**（2 条详细条目 + 对应 ROADMAP 下一轮建议）在 CHANGELOG.md；
> **详细条目 #66 ~ #53**（4 条）+ **condensed 条目 #INIT ~ #52**（52 条）+ **迭代时间线表 #60 ~ #70**（4 条）
> 原样迁移至 [`CHANGELOG_ARCHIVE.md`](file:///workspace/CHANGELOG_ARCHIVE.md)，全部 72 轮迭代记录 100% 完整可追溯。

## [2026-06-08 04:00 #72] - T136 SaveSystem 自动存档 60s + T135 PauseMenu 分享剪贴板 | skills:无（polish 轮，仅源码 + 冒烟） | 任务ID:T136, T135 | 通过

- **#71 审查前连续 2 个轻量任务（全部 PASS）**：
  - **T136 落地 (5min, 3 文件变更)**：[`src/autoload/save_system.gd`](file:///workspace/src/autoload/save_system.gd) 新增自动存档系统 — 5 个常量 `AUTOSAVE_DEFAULT_ENABLED/INTERVAL/SLOT/MIN/MAX`（默认 60s 间隔、目标槽位 0、10-600s 硬边界）、新 `signal autosave_tick(status, slot_id)`（4 状态：ok/skipped/disabled/error）、3 个 getter (`get_autosave_enabled/interval/slot`) + 4 个 setter/mutator (`set_autosave_enabled/interval/slot` + `trigger_autosave_now()`)、内部 Timer 节点 `process_mode = PROCESS_MODE_ALWAYS`（暂停菜单时也计时，避免"暂停 5 分钟后死亡 + 存档仍 1 小时前"陈旧快照）、`_ready()` 调 `_load_autosave_config()` 从 `user://settings.cfg` 恢复、`_do_autosave_tick(reason)` 共享自动/手动 body + 4 状态机；新私有方法 `_is_in_gameplay_scene()` 跳过 6 个非游戏场景（title/saveload/settings/credits/intro_cutscene/game_over）防止空游戏状态污染存档；[`src/scenes/settings_menu.tscn`](file:///workspace/src/scenes/settings_menu.tscn) `SavesPanel` 新增 4 个 UI 控件 — `AutoSaveLabel` 标题 + `AutoSaveEnabledCheck` (CheckBox) + `AutoSaveIntervalRow` (Label + value Label 60 秒) + `AutoSaveIntervalSlider` (HSlider 10-600s 10s 步长) + `AutoSaveSlotRow` (Label + OptionButton 0-4 槽位) + `AutoSaveHintLabel` 说明行；[`src/scripts/settings_menu.gd`](file:///workspace/src/scripts/settings_menu.gd) 新增 4 个 @onready 引用 + 3 个 signal handler（live-apply 到 SaveSystem 立即生效，不需关闭菜单）+ `_build_autosave_slot_options(select_index)`（0..SLOT_COUNT-1 动态枚举，未来 5→8 升级不重存 scene）+ `_populate_autosave_controls_from_cfg(cfg)`（从 SaveSystem 实时状态拉取，cfg + autoload 单一信源）+ `_refresh_autosave_interval_label(value)`（slider 跟值读数同步）+ `_save_settings` 末尾写 3 个 autosave key（enabled/interval/slot）。SaveSystem + SettingsMenu 双写 cfg 收敛到 last-writer-wins。
  - **T135 落地 (15min, 2 文件变更)**：[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) `PlayerProfilePanel` `ProfileQuickStats` 与 `HSep1` 之间新增 `ProfileShareButton` Button（110x20、9pt Glass Cyan #69C7CE 文本、tooltip 解释字段）；[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 `@onready var _profile_share_btn` + `_ready()` 信号连接 `_profile_share_btn.pressed.connect(_on_share_pressed)` + 新方法 `_on_share_pressed()` + `_format_share_text()` — 按下后 `DisplayServer.clipboard_set()`（带 `has_method` 守卫兼容 headless 测试 harness）写 3 行纯文本到系统剪贴板：`🎵 Voxglass\n成就 X/13  ·  最佳 mm:ss  ·  Run #N\nYYYY-MM-DD`（ASCII · 替代 • 跨编码清晰，🎵 emoji 作为 Voxglass 视觉钩子、平台剥离后仍是干净 3 行），按钮文本 1.5s 闪 "已复制 ✓" 后还原（失败时闪 "复制失败"，快速连点 timer 重置）。
  - **冒烟测试** [`tools/test_t136_autosave_smoke.gd`](file:///workspace/tools/test_t136_autosave_smoke.gd) (198 行) **12 项断言全部 PASS** + [`tools/test_t135_share_smoke.gd`](file:///workspace/tools/test_t135_share_smoke.gd) (182 行) **12 项断言全部 PASS**。T136 覆盖 5 个常量 / autosave_tick signal / 3 getter / 4 mutator / Timer process_mode=ALWAYS / _load+_persist_autosave_config / _is_in_gameplay_scene 6 场景 / _do_autosave_tick 4 状态 / tscn 4 UI 控件 / 3 signal handler / _save_settings 3 key / _clamp_autosave_interval min/max 边界。T135 覆盖 tscn 位置（QuickStats 与 HSep1 之间）/ @onready / 信号连接 / _on_share_pressed / _format_share_text 3 行结构 / 按钮默认文本 / 5 占位符（🎵+%d+%d+%s+%d+%04d%02d%02d）/ Glass Cyan 调色板 / 5 字段全包含 / 首次启动占位（0/13 · — · Run #1）/ DisplayServer.has_method 守卫 / null 守卫。**冒烟测试数量 21→23**。
  - **回归验证**：T127 / T128 / T132 / T133+T134 / T135 / T136 全部 6 个相关冒烟测试 12+10+8+12+12+12 = 66 项断言无回归。
- **质量自检**：
  - Godot 4.6.3 binary 重建 + `--headless --import` + `--headless --quit` 静态解析 0 错误。
  - 全局 532 行新代码（T136 三文件 318 行 + T135 两文件 92 行 + 2 个 smoke test 380 行 + 详情调整），无破坏性变更（所有新 method 都是新增/可选接口）。
  - 关键设计：自动存档 skip 规则（6 非游戏场景）+ Timer process_mode=ALWAYS（暂停时也计时）+ cfg 双写 last-writer-wins（autoload setter + settings menu 同步写） + Share 文本纯文本/ASCII · 编码安全/DisplayServer.has_method 守卫。
  - 玩家体验：暂停菜单分享按钮 1 击 = 3 行文本到剪贴板（含成就/最佳/Run/日期），可直贴 Discord/Steam/Reddit；自动存档默认 60s 静默工作，玩家从不需要记得"我刚才存没"。

## [2026-06-08 03:00 #71] - T134 settings 动态 SLOT_COUNT + T133 PauseMenu Quick Stats 摘要行 | skills:无（polish 轮，仅源码 + 冒烟） | 任务ID:T134, T133 | 通过

- **#70 审查后建议落地（2 个任务，全部 PASS）**：
  - **T134 落地 (5min, 2 文件变更)**：[`src/scenes/settings_menu.tscn`](file:///workspace/src/scenes/settings_menu.tscn) `SaveCountLabel.text` 硬编码 `"当前存档：0 / 3"` → `"当前存档：0 / 5"`（与 #55 T088 升级后的 `SaveSystem.SLOT_COUNT = 5` 一致）；[`src/scripts/settings_menu.gd`](file:///workspace/src/scripts/settings_menu.gd) `_ready()` 末尾新增 `if _save_count_label and _has_save_system_autoload(): _refresh_save_count()` — 调一次让 scene 默认 placeholder 走 `SaveSystem.SLOT_COUNT` 动态格式化，未来 5 → 8 升级时不需要重存 .tscn；新方法 `_has_save_system_autoload()` 守卫 SceneTree 测试 harness 环境（与 player.gd / pulse_ability.gd 同模式）。
  - **T133 落地 (15min, 2 文件变更)**：[`src/scenes/pause_menu.tscn`](file:///workspace/src/scenes/pause_menu.tscn) `ProfileRun` 与 `HSep1` 之间新增 `ProfileQuickStats` Label（9pt Amber Voice #F2B66E + bbcode_enabled + autowrap），同时 `PlayerProfilePanel` offset_top/offset_bottom -110/+110 → -120/+120 给新行让出 20px 空间（240px 高）；[`src/scripts/pause_menu.gd`](file:///workspace/src/scripts/pause_menu.gd) 新增 `@onready var _profile_quick_stats` + `_refresh_profile()` 头部格式化单行：`★ [color=#69C7CE]成就 X / 13[/color]  ·  最佳 [color=#F2B66E]mm:ss[/color]  ·  Run #[color=#B7E6DC]N[/color] ★` — 3 个数据点跨场景共享（成就=跨会话解锁 / 最佳=跨 run 持久化 / Run 编号=会话内），是"我的 Voxglass 生涯"的一行总览；首次启动最佳为 "—" 占位（与下方历史最佳块一致）。
  - **冒烟测试** [`tools/test_t133_t134_quick_stats_smoke.gd`](file:///workspace/tools/test_t133_t134_quick_stats_smoke.gd) (256 行) **12 项断言全部 PASS** — ProfileQuickStats 节点存在 / 位置在 ProfileRun 与 HSep1 之间 / 默认文本含 3 数据点（成就/最佳/Run #）/ @onready var / _refresh_profile 填充 / BBCode 调色板对齐 STYLE_GUIDE (Glass Cyan #69C7CE + Amber Voice #F2B66E) / PlayerStats get_unlocked_count() + get_total_count() / PlayerProfilePanel offset -120/+120 / settings_menu placeholder "0 / 5" / _has_save_system_autoload() / _ready() 调 _refresh_save_count() / _refresh_save_count() 用 SaveSystem.SLOT_COUNT。**冒烟测试数量 20→21**。
  - **文档**：[`CONTRIBUTING.md`](file:///workspace/CONTRIBUTING.md) §3.3 表格 14 → 21 行（新增 T129/T130/T131/T132/T133-T134 五条 + 修正计数），§3.3 标题"14 个" → "21 个"，#66 → #71 注释更新；[ROADMAP.md](file:///workspace/ROADMAP.md) 新增 `## #71 已完成` 段，T134 + T133 两条 + 冒烟测试一条 + #72 建议候选 (T103 / T135 / T136) 三条。
- **质量自检**：
  - 21/21 冒烟测试 PASS（20 旧 + 1 新 T133-T134）。
  - `tools/check_smoke_consistency.sh` → `[OK] No consistency errors. (0 warnings). Safe to commit.`
  - `timeout 15 godot --headless --quit --path /workspace` → 0 SCRIPT ERROR / 0 Parse Error。
  - `timeout 30 godot --headless --path /workspace` runtime → 0 ERROR / 0 exception（除已知 ObjectDB leak）。
- **未落地项**：
  - F001 / F002（Godot binary 持久化）：沿用 #70 方案（`cat z0* + zip` → `unzip`）。
  - T103（第五个声波能力 Resonance Wave）：50min 跨轮，留作 #72 启动第一半。
- **下一轮（#72，N%5≠0，普通模式）建议候选**（已写入 ROADMAP 顶部）：
  - T103 [候选] Code 第五个声波能力 Resonance Wave 群体波（50min 跨轮，可拆 2 轮）
  - T135 [候选] UX PauseMenu 玩家档案加 "Share" 按钮：把 Quick Stats 行复制到剪贴板（分享成就截图） (15min)
  - T136 [候选] Code SaveSystem 自动保存每 60 秒：玩家不主动存档时仍保留进度 (5min)

