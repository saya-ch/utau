class_name PauseMenu
extends Control

signal resume_pressed
signal restart_pressed
signal quit_to_title_pressed
signal settings_pressed
signal save_requested(slot_id: int)  # T070 — PauseMenu → GFC

@onready var _resume_btn: Button = $VBoxContainer/ResumeButton
@onready var _save_btn: Button = $VBoxContainer/SaveButton
@onready var _profile_btn: Button = $VBoxContainer/ProfileButton  # T126
@onready var _settings_btn: Button = $VBoxContainer/SettingsButton
@onready var _restart_btn: Button = $VBoxContainer/RestartButton
@onready var _quit_btn: Button = $VBoxContainer/QuitToTitleButton
@onready var _save_load_menu: SaveLoadMenu = $SaveLoadMenu

# Statistics panel nodes
@onready var _stats_panel: PanelContainer = $StatsPanel
@onready var _achv_progress: Label = $StatsPanel/StatsMargin/StatsVBox/AchvProgress
@onready var _stat_rooms: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatRoomsCleared
@onready var _stat_enemies: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatEnemiesPurified
@onready var _stat_shards: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatShards
@onready var _stat_deaths: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatDeaths
@onready var _stat_abilities: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatAbilities
@onready var _stat_cuts: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatCuts
@onready var _stat_reflects: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatReflects
@onready var _stat_lanterns: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatLanterns
@onready var _stat_time: Label = $StatsPanel/StatsMargin/StatsVBox/StatTime
# T236 (#154) — StatsPanel 底部 BGM 主题提示行. 玩家打开 PauseMenu 立即
# 可见"现在听的是哪个 BGM 主题" (例 "BGM · archive_exploration"), 不需要
# 切到 Settings 调 Music bus 音量才能猜到. 7pt 暖白小字 + 1 个 ` · ` middle-dot
# 与 ProfileQuickStats 4 段 + ProfileAudit 4 字段行风格 100% 一致. _ready
# 末尾调一次 _refresh_stat_bgm() 拉 AudioManagerEnhanced.get_current_music_key()
# 公开 API (#62 T117 落地), 空字符串 fallback "—".
@onready var _stat_bgm: Label = $StatsPanel/StatsMargin/StatsVBox/StatBGM
@onready var _achv_grid: HBoxContainer = $StatsPanel/StatsMargin/StatsVBox/AchvGrid
@onready var _latest_unlock: Label = $StatsPanel/StatsMargin/StatsVBox/LatestUnlock
# T160 — "新成就！" 顶部 Banner。anchored top center of pause
# menu, hidden by default.  When PlayerStats.achievement_unlocked
# fires AND the pause menu is visible, we animate it 0.4s fade-in +
# 0.4s hold + 0.4s fade-out (合计 0.8s 净可见 + 进出淡入淡出).
# If the player opens the pause menu within 5 seconds of a recent
# unlock, the banner also fires once on _ready (catches the
# "玩家在成就解锁 3 秒后按 ESC" 场景, 此时 achievement_unlocked
# 信号在 menu 隐藏时不响应, 重新打开需要补播).
@onready var _new_achv_banner: Label = $NewAchvBanner
const _BANNER_DURATION := 0.8
const _BANNER_FADE := 0.4
const _BANNER_RECENT_UNLOCK_WINDOW := 5.0
var _banner_tween: Tween = null
var _last_seen_unlock_ts: int = 0

# T126 — Player Profile panel nodes (full-screen modal with detailed stats + achievement list)
@onready var _profile_panel: PanelContainer = $PlayerProfilePanel
@onready var _profile_time: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTime
@onready var _profile_deaths: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileDeaths
@onready var _profile_rooms: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRooms
@onready var _profile_abilities: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAbilities
@onready var _profile_shards: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileShards
@onready var _profile_reflects: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileReflects
# T150 — 上次使用的 verb 行（5 动词 BBCode 调色板）。
@onready var _profile_last_verb: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileLastVerb
# T127 — Run 编号 + 历史最佳 4 行
@onready var _profile_run: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRun
# T133 — Quick Stats 摘要行（一行总览：成就进度 + 最佳单局 + Run #）
# T217 (#138) — 4 段独立 hover 联动: 1 个 HBoxContainer 居中, 4 个 sub-Label
# 各 1 段, 中间 3 个 sep 静态 Label "·" 间隔, 两端 2 个 star 静态 Label "★" 装饰.
# 4 sub-Label mouse_filter=STOP + mouse_entered/mouse_exited 1 对 handler 处理 4 段
# (bind 段号). hover 任 1 段 → 该段提亮 (modulate Color.WHITE) + 其他 3 段 dim 50% alpha.
# T213 tooltip 整体绑定到 HBoxContainer, 4 sub-Label 各自独立 hover 联动.
@onready var _profile_quick_stats: HBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats
@onready var _quick_stats_achievement: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsAchievement
@onready var _quick_stats_best_time: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsBestTime
@onready var _quick_stats_longest_room: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsLongestRoom
@onready var _quick_stats_run_number: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsRunNumber
# T135 — Share button.  Click → copy the Quick Stats line
# (achievements + best time + run # + date) to the system
# clipboard via DisplayServer.clipboard_set().  Feedback
# flips the label to "已复制 ✓" for 1.5s then restores.
@onready var _profile_share_btn: Button = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileShareButton
# T138 — 上次自动存档时间戳。每次 PauseMenu 打开时刷新；auto-save
# 期间可能多次更新，所以显示 HH:MM:SS（与 SaveLoadMenu 的 HH:MM
# 区分，因为 PauseMenu 是在 session 内高频查看，秒级精度更有用）。
@onready var _profile_auto_save: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAutoSave
# T201 (#117) — PlayerProfilePanel 顶级行：跨局聚合 stats。
# AvgResonance: 历史平均共鸣(碎/房) = sum(shards) / sum(rooms) across run_history。
# BestStreak: 历史单局最高 rooms_cleared + 该局时长 (mm:ss)。
# 都用 Glass Cyan 9pt 居中, 与上下 9pt stats 行视觉对齐, 2 行只占 ~32px 高度。
# T203 (#119) — ProfileAvgResonance / ProfileBestStreak 2 个 Label
# 节点。#117 T201 落地时 tscn 段用了 `#` 注释 (tscn 语法要求 `;`),
# Godot 4.6 tscn parser 在 `#` 行 abort, 后续 2 个节点被丢弃, 运
# 行时 @onready 报 "Node not found" ERROR 至今未修。本轮将 tscn 全
# 部 `#` 注释转 `;` (含 ProfileAutoSave 行内 `# T138` 与 5 行大段
# 注释), Godot 解析恢复, 2 个 @onready 字段成功绑定, _refresh_top
# _aggregate_rows 在 PauseMenu 打开时正常刷新。
@onready var _profile_avg_resonance: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAvgResonance
@onready var _profile_best_streak: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestStreak
# T209 (#128) — 顶级行第 3 块 "最长单房"。 数据源 _best_stats
# ["longest_room_seconds"] (mm:ss)。 n=0 (玩家从未通关过任何房)
# 时显示 "—", 与 AvgResonance / BestStreak 风格保持一致。
@onready var _profile_longest_room: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileLongestRoom
# T232 (#151) — 顶级行第 4 块 "近期共鸣 (近因加权)". 跨 run 时间
# 衰减权重 (exponential decay 0.5), 让最近 run 权重远高于早期 run,
# 反映玩家"当前技能"更灵敏. 替代候选: 不动 T201 跨 run 累计比, 1 个
# 全新行 "★ 近期共鸣 (近因加权) — %.1f 碎/房 (n=%d, 衰 0.5) ★". 与
# T201 AvgResonance / T209 LongestRoom 顶级行同色 Glass Cyan (4 顶级
# 行 palette 一致). 9pt 字号, 居中. 占位符 "—" 与 T201/T209 完全同款.
@onready var _profile_recent_resonance: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRecentResonance
@onready var _profile_best_time: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestTime
@onready var _profile_best_rooms: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestRooms
@onready var _profile_best_shards: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestShards
@onready var _profile_best_enemies: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestEnemies
# T131 — 近 N 局平均（5/10/20 三档）趋势行
@onready var _profile_trend5: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTrend5
@onready var _profile_trend10: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTrend10
@onready var _profile_trend20: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTrend20
# T162 (#83) — 最近 5 局详细行（每局 1 行：Run #N 房 X 净 Y 碎 Z 时 mm:ss）
@onready var _profile_recent_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRecentList
@onready var _profile_achv_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAchvScroll/ProfileAchvList
# T229 (#149) — 存档 5 slot 健康状态 1 行 (ok / 损坏 / 漂移 / 空).
# _refresh_profile_audit 在 _refresh_profile 末尾调, 拉 SaveSystem.audit_save_slots()
# 公共接口, 渲染成 1 行紧凑 Label. 颜色: 全 ok 暖白, 损坏>0 暖红, 漂移>0 暖黄.
@onready var _profile_audit: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAudit
@onready var _profile_close_btn: Button = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileCloseButton

const ICON_PATH_BASE := "res://assets/ui/achievements"
const ICON_DEFAULT := "amber_dot"

# T250 (#168) — 6 verb 关联成就 (quadruple_voice=echo_icon /
# quintuple_voice=wave_icon / sextuple_voice=whisper_icon) slot tooltip
# 扩展数据源. AchievementGrid 14 slot 中这 3 个 slot 的 icon_hint
# 对应 6 verb 视觉组 (Pulse / Bind / Cut / Echo / Wave / Whisper 6 verb
# 调色六元组 + 6 verb 几何 5 动态 + 1 静态). 玩家 hover 6 verb 关联
# 成就 slot 时, tooltip 追加 4 行 "6 verb 视觉组连贯" 段: 主色
# (color hex + color name) + 几何 (verb 核心形状描述) + 调色
# 严格不重叠 (6 verb 调色六元组 0 重叠, 与 5 verb 5 色 RGB 立方
# 距离 ≥ 30%) + 视觉组定位 (5 verb 全是动作 / 6 verb 是 debuff 贴身
# 唯一"不扩散" 几何). 11 个非 6 verb 关联 slot 走默认 3 行 tooltip
# (T109 #60 既有 "title + desc + 解锁时间", 0 触碰 0 回归). 走
# const 权威数据源 + _build_verb_achievement_tooltip() 函数生成
# 多行纯文本, 与 T199 / T213 / T216 / T249 tooltip 模式完全同源
# (1 header 段名 + 多行 bullet 段内容, BBCode 0 走 tooltip 路径).
# 0 副作用: ICON_PATH_BASE / ICON_DEFAULT 0 改; AchievementGrid
# slot 创建路径 0 改 (slot 仍是 16x16 TextureRect + mouse_filter=STOP
# + mouse_entered/exited 2 signal); 11 个非 6 verb 关联 slot tooltip
# 100% 兼容 (T109 #60 既有 "title + desc + 解锁时间" 3 行 0 改);
# _build_verb_achievement_tooltip 仅追加 4 行 (原 3 行 → 7 行, 7 行
# tooltip Godot 4.6 自带渲染器 5s timeout 完全可读, 玩家 hover 充分
# 吸收 6 verb 调色 + 6 verb 几何 + 视觉组连贯 3 维信息).
const _VERB_ACHV_ICON_HINTS := ["echo_icon", "wave_icon", "whisper_icon"]

# T250 (#168) — 6 verb 关联成就 icon_hint → 6 verb 视觉组连贯数据
# (4 字段: 关联成就 id / verb 序号 1-6 / 主色 hex / 主色名 / 几何
# 描述 / 视觉组连贯短句). 3 个 icon_hint 各自独立 4-字段 dict,
# 走 _build_verb_achievement_tooltip() 按 icon_hint 查找 + 渲染
# 4 行 tooltip 扩展段. 字段顺序: 关联成就 → verb 序号 → 主色 →
# 主色名 → 几何 → 视觉组短句. 0 副作用: 6 verb 调色六元组权威源
# (Pulse Coral #E86D5A / Bind Muted Violet #65506A / Cut Amber #F2B66E
# / Echo Glass Cyan #69C7CE / Wave Pale Resonance #B7E7DD / Whisper
# Muted Mauve #C8A4D8) 与 STYLE_GUIDE.md 6 verb palette 段 1:1 对齐;
# 6 verb 几何 (5 verb 全是动态几何 + Whisper 唯一"不扩散" 静态球)
# 与 ASSET_REGISTRY.md A071/A074 + STYLE_GUIDE 6 verb 视觉组段 1:1
# 对齐. 后人加新 verb (第 7 verb) 必须同步扩展本表 + _VERB_ACHV_ICON_HINTS
# + 6 verb palette + 6 verb 视觉组段, 0 字段孤悬.
const _VERB_ACHV_INFO := {
	"echo_icon": {
		"achv_id": "quadruple_voice",
		"verb_index": 4,    # Echo = 4 verb
		"color": "#69C7CE", # Glass Cyan — Echo 4 verb 命中色
		"color_name": "Glass Cyan",
		"geometry_zh": "盾球扩散 — 4 verb 命中色向四周辐射",
		"visual_group": "5 verb 全是动态几何 (Pulse 圆环 / Bind 螺旋 / Cut 锋线 / Echo 盾球 / Wave 双环) — 玩家扫到 cyan = 4 verb 命中",
	},
	"wave_icon": {
		"achv_id": "quintuple_voice",
		"verb_index": 5,    # Wave = 5 verb
		"color": "#B7E7DD", # Pale Resonance — Wave 5 verb 主色
		"color_name": "Pale Resonance",
		"geometry_zh": "双环扩散 — 5 verb 双环 (mid-wave crest) + 8 棱线",
		"visual_group": "5 verb 全是动态几何, Wave 是最冷最浅 (Pulse 暖珊瑚 → Bind 暗紫 → Cut 暖琥珀 → Echo 冷青 → Wave 淡青白)",
	},
	"whisper_icon": {
		"achv_id": "sextuple_voice",
		"verb_index": 6,    # Whisper = 6 verb
		"color": "#C8A4D8", # Muted Mauve — Whisper 6 verb 主色
		"color_name": "Muted Mauve",
		"geometry_zh": "静态球 — 6 verb 唯一\"不扩散\" 几何 (sphere constant + core dot)",
		"visual_group": "6 verb 是 debuff 贴身 (0.15s 静默场), 5 verb 全是动作 — 玩家扫到 mauve = 第 6 verb 不扩散",
	},
}

# T244 (#161) — PauseMenu 6 verb hover 行 状态文字: 6 verb row
# (StatsPanel._stat_abilities + ProfilePanel._profile_abilities) 加
# mouse_entered/exited handler, 0.12s tween font_color (theme_override
# _colors/font_color) + modulate RGB 加色 (1.0→1.15 additive brighten)
# 同步 T231 (#151) ProfileRecentList 5 行 alpha boost + T240 (#158) 5 行
# font_color 0.12s 节奏. 让"6 verb row 是交互元素" 视觉组连贯, tooltip
# 之外还有"行本身亮一阶" 即时反馈, 玩家"hover 进去" 0 歧义. T199
# tooltip (5s timeout 文字详情) 仍保留, T244 是即时 "行被点中" 视觉
# 强调, 0 冲突. 0 副作用: _stat_abilities._profile_abilities 是
# Label 节点, mouse_filter 默认 STOP (T199 tooltip 路径已 connect 验证),
# 加 1 对 handler 0 干扰既有 tooltip / _refresh 路径 / 6 verb BBCode
# 内容 (text 字段 0 改, 仅 modulate + theme_override 临时改).
const _VERB_ROW_HOVER_FADE_DURATION := 0.12
const _VERB_ROW_HOVER_FONT_COLOR := Color(1.0, 0.96, 0.88, 1.0)  # warm cream brighten
const _VERB_ROW_HOVER_MODULATE := Color(1.15, 1.15, 1.15, 1.0)   # additive brighten (1.0 → 1.15)
const _VERB_ROW_BASE_MODULATE := Color(1.0, 1.0, 1.0, 1.0)       # baseline
const _VERB_ROW_BASE_FONT_COLOR := Color(0.875, 0.835, 0.784, 1.0) # Voxglass Warm White (与 pause_menu.tscn StatRows 同源) — T244 (#161) tween 渐回 baseline 用, T246 (#163) 修复 pre-existing parse error
# T244 tween cache. 1 对 _stat_abilities / _profile_abilities 共享
# 1 个 font_color tween 引用 + 1 个 modulate tween 引用. 同 row 不可能
# 同时 hover_in 和 hover_out, 单鼠标场景 2 row 同时 hover 0 发生 (Stats
# panel 和 Profile panel 是互斥 visibility), 共享 1 个 tween 引用 0 风险.
# kill 旧 tween 防快速 hover 进出叠加撕裂.
var _verb_row_font_color_tween: Tween = null
var _verb_row_modulate_tween: Tween = null

# T162 (#83) — 最近 N 局详细行显示的最多局数。选 5 是因为 PauseMenu
# 受 PlayerProfilePanel 高度限制（offset_top/offset_bottom -120/+120），
# 5 行 × ~12px 行高 = 60px 适合既有空间（trend 3 行 + recent 5 行 +
# 1 个 title = 5+ 标签 仍 容纳）。再多会触发玩家滚动，让"信息密度"
# 落到反效果。Get more (up to 20) via get_recent_runs(n) 程序接口。
const _PROFILE_RECENT_RUNS_MAX := 5

# T199 (#116) — 5 verb 详细参数表（hover tooltip 用）。每个 verb 给出
# cost (共鸣消耗) / cooldown (冷却秒) / radius (判定半径) / key (默认键位) /
# desc_zh (一句中文). 数据从 player.tscn 5 verb 节点 + project.godot 5
# input action 单点摘抄，作为权威源；新增第 6 verb 时必须同步扩展本表 +
# pause_menu.tscn (Label 位置) + player.gd (_handle_*) + 项目文档
# (F013.D 接入路径)。BBCode 颜色 token 与 _stat_abilities /
# _profile_abilities row 完全一致（5 动词色域贯穿）。
const _VERB_HINT_DATA := [
	{
		"key": "J",
		"name_zh": "Pulse",
		"name_color": "#E86D5A",
		"cost": 15,
		"cooldown_s": 0.5,
		"radius_px": 48,
		"desc_zh": "推波 / 破盾 — 击退 + 击破 InkWarden 护盾",
	},
	{
		"key": "K",
		"name_zh": "Bind",
		"name_color": "#65506A",
		"cost": 20,
		"cooldown_s": 1.2,
		"radius_px": 40,
		"desc_zh": "牵引 / 暂停 — 锁敌 + 解锁能力门",
	},
	{
		"key": "L",
		"name_zh": "Cut",
		"name_color": "#F2B66E",
		"cost": 25,
		"cooldown_s": 0.8,
		"radius_px": 64,
		"desc_zh": "切断 / 贯穿 — 斩断腐蚀链 + 群体贯穿",
	},
	{
		"key": "Q",
		"name_zh": "Echo",
		"name_color": "#69C7CE",
		"cost": 30,
		"cooldown_s": 4.0,
		"radius_px": 30,
		"desc_zh": "护盾 / 反弹 — 0.4s 玻璃盾反弹敌人投射物",
	},
	{
		"key": "V",
		"name_zh": "Wave",
		"name_color": "#B7E6DC",
		"cost": 50,
		"cooldown_s": 6.0,
		"radius_px": 80,
		"desc_zh": "群体波 / 横扫 — 80px 圆内全体击退 + 暂停",
	},
	# F013.E (#159) — 第六动词 Whisper 接入 _VERB_HINT_DATA (6 verb 接入路径 §9.1 第 8 步).
	# T199 tooltip 第 6 行 bullet 同步出现. 色域 Muted Mauve #C8A4D8
	# 与 5 verb 严格不重叠. 数值: cost 35, cooldown 5.0s, radius 50px.
	# 6 verb 同步影响 _build_verb_hint_tooltip header (5 声波能力 → 6 声波能力).
	{
		"key": "T",
		"name_zh": "Whisper",
		"name_color": "#C8A4D8",
		"cost": 35,
		"cooldown_s": 5.0,
		"radius_px": 50,
		"desc_zh": "静默场 / 贴身 — 50px 圆内全体冻结 1.2s",
	},
]

# T199 (#116) — 根据 _VERB_HINT_DATA 生成多行 tooltip 文本。返回纯文本
# (5 行 + 头) Godot 4.6 自带 tooltip 渲染器会按 \n 自动换行。BBCode 不
# 走 tooltip 路径（Label 节点 bbcode_enabled 不影响 tooltip 渲染），所以
# 这里走纯文本 + 关键词前置动词名（"Pulse (J)"）让玩家按名字 + 键位
# 即可识别，零歧义。颜色信息在 PauseMenu 5 verb row 已经在视觉上区分
# 5 块，tooltip 只承担"参数详情"职责。Tooltip 显示时间由 Godot 默认
# 5s (Pointer.timeout) 控制，玩家可读充分。
func _build_verb_hint_tooltip() -> String:
	var lines: Array[String] = []
	# F013.E (#159) — 5 声波能力 → 6 声波能力 (Whisper 加入).
	lines.append("6 声波能力 — 悬停查看详细")
	for v in _VERB_HINT_DATA:
		var d: Dictionary = v
		lines.append("• %s (%s) — 消耗 %d  冷却 %.1fs  半径 %dpx" % [
			String(d["name_zh"]),
			String(d["key"]),
			int(d["cost"]),
			float(d["cooldown_s"]),
			int(d["radius_px"]),
		])
		lines.append("    %s" % String(d["desc_zh"]))
	return "\n".join(lines)

# T213 (#133) — ProfileQuickStats 4 段总览 hover tooltip 数据源。
# 4 段权威解释 + 颜色 token + 详细位置提示。共享 _QUICK_STATS_HINT
# 避免硬编码, 后人加段/改色只需改这里, _build_quick_stats_tooltip
# 负责按 4 段顺序渲染.
#
# 4 段 = 跨 run 累计 4 个最常用指标, 玩家在 PauseMenu 1 行看到
# 4 个颜色但具体含义不写出来, 悬停即弹 9 行说明.
const _QUICK_STATS_HINT := [
	{
		"label": "成就",
		"color": "#69C7CE",
		"color_name": "Glass Cyan",
		"desc_zh": "已解锁 / 总数 — 跨 run 累计解锁数",
		"detail": "下方成就滚动列表逐项展示 14 成就状态",
	},
	{
		"label": "最佳",
		"color": "#F2B66E",
		"color_name": "Amber Voice",
		"desc_zh": "单次 run 最长回响时长 — 跨 run 最佳",
		"detail": "顶级行 ★ 最佳单局 (mm:ss) 同字段",
	},
	{
		"label": "最长单房",
		"color": "#65506A",
		"color_name": "Muted Violet",
		"desc_zh": "单房最长耗时 — 跨 run 最佳",
		"detail": "顶级行 ★ 最长单房 (mm:ss) 同字段",
	},
	{
		"label": "Run #",
		"color": "#B7E6DC",
		"color_name": "Pale Resonance",
		"desc_zh": "当前会话第几局 — 1-based session 内",
		"detail": "PauseMenu 顶部 Run 字段 + 档案 Run #",
	},
]

# T213 (#133) — 根据 _QUICK_STATS_HINT 生成多行 tooltip 文本。返回
# 纯文本 (4 段 + 头 + 4 缩进描述) Godot 4.6 自带 tooltip 渲染器会按
# \n 自动换行。BBCode 不走 tooltip 路径 (Label 节点 bbcode_enabled
# 不影响 tooltip 渲染), 所以这里走纯文本 + 关键词前置段名. 颜色
# hex + 颜色名都给出色弱玩家辅助. 5s timeout 玩家可读充分.
func _build_quick_stats_tooltip() -> String:
	var lines: Array[String] = []
	lines.append("4 段总览 — 悬停查看每段含义")
	for h in _QUICK_STATS_HINT:
		var d: Dictionary = h
		lines.append("• %s — %s" % [
			String(d["label"]),
			String(d["desc_zh"]),
		])
		lines.append("    颜色: %s  %s  ·  %s" % [
			String(d["color"]),
			String(d["color_name"]),
			String(d["detail"]),
		])
	return "\n".join(lines)

# T216 (#137) — ProfileRecentList 5 行 hover tooltip 数据源。
# 5 字段权威解释 (Run #/房/净/碎/时) + 字段名 + 详细来源. 共享
# _RECENT_ROW_HINT 避免硬编码, 后人加字段/改措辞只需改这里,
# _build_recent_row_tooltip 负责按 5 字段顺序渲染.
#
# 5 字段 = 每行 1 局历史 run 的可读明细, 玩家打开 PauseMenu 用
# 鼠标扫 5 行时, 5 字段 5 行 7pt 小字但具体含义不写出来, 悬停
# 即弹 6 行说明 (1 header + 5 字段 bullet). 与 T213 QuickStats 4 段
# 总览 tooltip 同模式 (const 权威数据源 + _build_*_tooltip 函数生成
# 纯文本), 但本表是 5 字段"单行 run 明细" (T213 是 4 段"跨 run
# 累计聚合"), 数据语义不同. T215 静态高亮层 (悬停整行提亮到
# Color.WHITE) + T216 tooltip 层 (悬停 5 字段含义) 双层互补:
# T215 给"鼠标在哪一行"视觉反馈, T216 给"这一行 5 字段含义" 静态
# 信息; 玩家两个都需要: 1) 知道当前指哪行 (T215); 2) 知道 5 字段
# 是什么意思 (T216); 3) 不想看任何提示 → 不悬停, 1 行 5 字段 7pt
# 小字 + 1 行最新 1 局 Amber Voice + 4 行 Pale Resonance 已经够区分.
#
# T219 (#141) — 扩展到 7 字段 (Run #/房/净/碎/时 + 房/时 + 净/时).
# 房/时 = 房间/分钟 (rounded) = rooms_cleared / (run_time_seconds /
# 60) — 玩家通关节奏密度 (本局推进速度); 净/时 = 敌/分钟 (rounded)
# = enemies_purified / (run_time_seconds / 60) — 玩家战斗节奏 (本局
# 击杀速度). 派生自原 5 字段中的 房/净/时, 不需要新采集. 与
# T213 QuickStats 4 段 hover tooltip (悬停揭示"4 段是什么") 一致,
# 都是"原 5 字段太密集玩家看不出 X/Y 派生含义, 悬停揭示". 7 字段
# = 1 header + 7 字段 bullet = 8 行, 玩家扫描"节奏类"信息时
# 完整看到 Run # + 原始 3 数 + 时长 + 2 个派生率, 8 行 tooltip 完全
# 可读 (Godot 4.6 tooltip 自动换行, 5s timeout 充分).
const _RECENT_ROW_HINT := [
	{
		"label": "Run #",
		"desc_zh": "当前会话第几局 — 1-based session 内累计计数",
		"detail": "PauseMenu 顶部 Run 字段 + 档案 Run # 同字段",
	},
	{
		"label": "房",
		"desc_zh": "本 run 通关房间数 — Voice Bell 修复 + 房完成",
		"detail": "RoomController._complete_room 累计",
	},
	{
		"label": "净",
		"desc_zh": "本 run 净化敌人数 — Pulse 击破 + Echo 反弹击杀",
		"detail": "PlayerStats.record_enemy_purified 累计",
	},
	{
		"label": "碎",
		"desc_zh": "本 run 共鸣碎片拾取数 — Voice Bell 修复后 1 枚 + Shard 道具",
		"detail": "PlayerStats.record_shard_collected 累计",
	},
	{
		"label": "时",
		"desc_zh": "本 run 总时长 mm:ss — 从玩家进入第 1 房到死亡/通关",
		"detail": "GameState.run_start_time / run_time_seconds",
	},
	{
		"label": "房/时",
		"desc_zh": "本 run 房间/分钟 (rounded) — 玩家通关节奏密度, 派生自房/时",
		"detail": "rooms_cleared / (run_time_seconds / 60)",
	},
	{
		"label": "净/时",
		"desc_zh": "本 run 敌/分钟 (rounded) — 玩家战斗节奏, 派生自净/时",
		"detail": "enemies_purified / (run_time_seconds / 60)",
	},
]

# T216 (#137) — 根据 _RECENT_ROW_HINT 生成多行 tooltip 文本。返回
# 纯文本 (5 字段 + 1 header = 6 行) Godot 4.6 自带 tooltip 渲染器
# 会按 \n 自动换行. BBCode 不走 tooltip 路径 (Label 节点 bbcode_
# enabled 不影响 tooltip 渲染), 所以这里走纯文本 + bullet "• 段
# 名 — 含义" 与 T213 _build_quick_stats_tooltip 完全同模式. 5s
# timeout 玩家可读充分.
#
# T219 (#141) — 5 字段 → 7 字段: 5 行 8 行 tooltip 仍然走 _RECENT_ROW_HINT
# 自动遍历 (5 → 7 字段, 0 改函数体), 1 header + 7 字段 bullet + 7 字段
# detail = 1 + 14 = 15 行, Godot 4.6 tooltip 自动换行 5s timeout 完全
# 容纳 (玩家可读充分, 7 字段含义 + 公式全部展示). 函数本体 for h in
# _RECENT_ROW_HINT / "• %s — %s" 格式 0 改, 0 hard-code 5 或 7, 0 回归
# 风险. 旧 T216 5 字段版本测试 (I042 44 断言) 仍可通过 (字段从 5 增
# 到 7, 旧断言只查 "• %s — %s" 格式 + 5 字段 label 0 删, T219 全部
# 兼容).
#
# 与 T213 QuickStats 4 段总览 tooltip 区别: QuickStats 是 4 段"跨
# run 累计聚合" (成就 / 最佳 / 最长单房 / Run #), RecentList 5 字
# 段是"单 run 明细" (Run # / 房 / 净 / 碎 / 时), 数据语义不同 →
# 字段名不同, 含义不同. T216 不复用 _QUICK_STATS_HINT 是因为 4
# 段 vs 5 段结构不同 + 字段含义完全不同 (T213 是"我在第几局"
# 跨 run, T216 是"这一局我做了啥" 单 run). 共享 _build_*_tooltip
# 函数模式 (pure function from const) 但数据 const 独立.
func _build_recent_row_tooltip() -> String:
	var lines: Array[String] = []
	lines.append("最近一局明细 — 悬停查看每字段含义")
	for h in _RECENT_ROW_HINT:
		var d: Dictionary = h
		lines.append("• %s — %s" % [
			String(d["label"]),
			String(d["desc_zh"]),
		])
		lines.append("    %s" % String(d["detail"]))
	return "\n".join(lines)

# T217 (#138) — QuickStats 4 段独立 hover 联动. 玩家鼠标进入任 1 段
# (Achievement/BestTime/LongestRoom/RunNumber) → _on_quick_stats_hover_in(idx)
# 翻 `_quick_stats_hovered_idx` 字段 (1 段对应 0-3 idx) + 调 _apply_quick_stats
# _hover_state() 把 4 sub-Label 的 modulate 全部重算: idx 段 = Color.WHITE (亮),
# 其他 3 段 = _QUICK_STATS_DIM (50% alpha 暗). 玩家"鼠标在 4 段中哪一段"
# 视觉明确. T214 (#134) 旧版 1 Label + 4 BBCode 段 + 1 段 (Run #) 单独高亮
# 升级到 T217 (#138) 4 sub-Label + 1 段高亮 + 3 段 dim 全联动 (4 段独立).
#
# 为什么不复用 T214 旧版 1 Label + 4 BBCode 段 + string 替换: T214 string
# 替换只能改 1 段 1 段独立 (mouse_entered 是 Label 级事件, 1 Label 1 触发,
# 1 触发只能改 1 段), "1 段高亮 + 3 段 dim" 在 1 Label 文本上需要 4 段
# 颜色 token 独立 splice (alpha=0.5 BBCode), 与"提亮 + 粗体" string 替换
# 交织, 容易错位. 4 sub-Label 拆分后, 4 段每段独立 modulate, "1 亮 3 暗"
# 是 1 循环 4 赋值, 0 字符串处理. tscn 14 行 4 sub-Label + 3 sep + 2 star,
# gd 4 字段 1 状态 2 handler 1 apply 函数, 复杂度可控.
func _on_quick_stats_hover_in(idx: int) -> void:
	# 越界检查 + null guard (与 T215 (#136) ProfileRecentList 5 行 hover 模式同源)
	if idx < 0 or idx > 3:
		return
	if not _quick_stats_achievement or not _quick_stats_best_time \
			or not _quick_stats_longest_room or not _quick_stats_run_number:
		return
	# re-entrant guard: 同一 idx 多次触发 0 副作用
	if _quick_stats_hovered_idx == idx:
		return
	_quick_stats_hovered_idx = idx
	_apply_quick_stats_hover_state()

func _on_quick_stats_hover_out(idx: int) -> void:
	# 越界检查 + null guard
	if idx < 0 or idx > 3:
		return
	if not _quick_stats_achievement or not _quick_stats_best_time \
			or not _quick_stats_longest_room or not _quick_stats_run_number:
		return
	# 已经被其他段接管 (idx 不等于 hovered) → 不 clear, 0 副作用
	# 例: hover Achievement → idx=0; 移到 BestTime → mouse_exited(Achievement)
	# 先 fire (idx=0, hovered=0, 走 clear path), 但同时 mouse_entered(BestTime)
	# 也会 fire (idx=1, hovered=0, 走 set 1 path); mouse_entered 在
	# mouse_exited 之后 fire (Godot 4 内部事件顺序), 所以最终 hovered=1
	# 是正确状态. 此处只在 idx == hovered 时才 clear, 避免误清
	if _quick_stats_hovered_idx != idx:
		return
	_quick_stats_hovered_idx = -1
	_apply_quick_stats_hover_state()

# T217 (#138) — apply 函数: 4 sub-Label modulate 全部重算. idx 段 = WHITE
# (亮), 其他 3 段 = _QUICK_STATS_DIM (50% alpha 暗). _refresh_profile() 末尾
# 也调 1 次重新 apply (玩家 _refresh 时正在 hover 段要保持高亮, 其他段从
# _refresh 重置后 dim 不能丢). null guard 4 个 sub-Label (defensive, _ready
# 之前 _apply 0 副作用).
# T225 (#147) — ProfileQuickStats 4 段 hover 提亮 fade-out 持续 0.3s.
# T217 (#138) 旧版 _apply_quick_stats_hover_state 立即重算 4 sub-Label
# modulate: idx 段 = WHITE, 其他 3 段 = _QUICK_STATS_DIM. "snap 切换" 在
# 鼠标快速横扫 4 段时容易"瞬变" 不够丝滑. T225 (#147) 升级: 0.3s 渐变
# 让 idx 段从 dim (0.5 alpha) 渐到 WHITE (1.0 alpha) + 其他 3 段从
# WHITE (1.0) 渐到 dim (0.5), 与 T215 (#136) ProfileRecentList 5 行
# hover font_color 提亮 fade 0.2s 模式同源 (5 行 hover 提亮 fade 0.2s +
# 4 段 hover 提亮 fade 0.3s 跨面板一致, 给玩家"hover 焦点" 视觉组连贯).
# 实现: _apply_quick_stats_hover_state 每次调时先 kill 旧 tween, 创建
# 新 tween 0.3s set_parallel 4 个 tween_property 改 modulate 字段. 1 个
# 全局 tween 而不是 4 个 tween (4 个 sub-Label 共享 1 个 tween 引用,
# 互不冲突, 简化). 选 0.3s 因为 (a) 比 T217 旧版 0s snap 慢, 视觉丝滑;
# (b) 比 T218 click 联动 pulse 0.4s 短, 不会盖过 click pulse; (c) 与
# T215 5 行 hover fade 0.2s 接近 (0.1s 差异可接受).
const _QUICK_STATS_HOVER_FADE_DURATION := 0.3

# T225 (#147) — apply 函数: 4 sub-Label modulate 字段 (Color 4 通道) 全部
# 0.3s 渐变. idx 段 → WHITE (亮), 其他 3 段 → _QUICK_STATS_DIM (0.5 alpha
# 暗). _refresh_profile() 末尾也调 1 次重新 apply (玩家 _refresh 时正在
# hover 段要保持高亮, 其他段从 _refresh 重置后 dim 不能丢). null guard 4
# 个 sub-Label (defensive, _ready 之前 _apply 0 副作用). 每次调时先 kill
# 旧 tween, 避免快速 hover 进出 4 段时 tween 叠加 (例如 hover Achievement
# (idx=0) 0.3s fade 期间移到 BestTime (idx=1), mouse_exited(0) → hovered
# =-1 → fade 到 all dim; mouse_entered(1) → hovered=1 → fade 到 idx 1 亮
# + 3 段 dim. 没有 kill 旧 tween, 两条 tween 叠加会出现"idx 1 已经亮但 0
# 还在 fade 中" 视觉撕裂). 注意: T225 改 modulate 字段 (Color), T218 click
# 联动 pulse 改 modulate.a 字段 (float) 且作用在 _profile_achv_list 等
# list 段节点 (不同节点), 0 冲突.
func _apply_quick_stats_hover_state() -> void:
	if not _quick_stats_achievement or not _quick_stats_best_time \
			or not _quick_stats_longest_room or not _quick_stats_run_number:
		return
	if _quick_stats_hover_tween != null and _quick_stats_hover_tween.is_valid():
		_quick_stats_hover_tween.kill()
	var t := create_tween()
	t.set_parallel(true)
	var subs: Array = [_quick_stats_achievement, _quick_stats_best_time, _quick_stats_longest_room, _quick_stats_run_number]
	for i in range(4):
		var target_color: Color
		if i == _quick_stats_hovered_idx:
			target_color = Color.WHITE
		else:
			target_color = _QUICK_STATS_DIM
		t.tween_property(subs[i], "modulate", target_color, _QUICK_STATS_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_quick_stats_hover_tween = t

# T218 (#139) — QuickStats 4 段 click handler. 4 sub-Label 共享 1 对
# _on_quick_stats_clicked handler (bind 段号 idx 0-3). 收到 gui_input
# event 后过滤: 只处理左键按下 (mb.pressed && mb.button_index ==
# MOUSE_BUTTON_LEFT), 忽略右键/滚轮/移动/释放. 越界 idx 0 副作用
# (defensive, bind 0-3 应该不会越界). 4 idx → target 映射通过 match
# (idx 是 int, match 是 GDScript 4.x 推荐的枚举式 switch, 编译期校验):
#   idx 0 = Achievement   → _profile_achv_list   (成就列表 ScrollContainer 内 VBox)
#   idx 1 = BestTime      → _profile_best_streak (顶级行第 2 块)
#   idx 2 = LongestRoom   → _profile_longest_room (顶级行第 3 块)
#   idx 3 = RunNumber     → _profile_recent_list (最近 5 局详细行 VBox)
# target null guard (defensive, _ready 之前或 hot-reload 异常时 0 副作用)
# 调 _pulse_quick_stats_target(target) 触发对应 list 段 0.4s pulse.
func _on_quick_stats_clicked(idx: int, event: InputEvent) -> void:
	if idx < 0 or idx > 3:
		return
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if not (mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT):
		return
	var target: Control = null
	match idx:
		0:
			target = _profile_achv_list
		1:
			target = _profile_best_streak
		2:
			target = _profile_longest_room
		3:
			target = _profile_recent_list
	if target == null:
		return
	_pulse_quick_stats_target(target)

# T218 (#139) — per-target pulse helper. 接受 1 个 Control target, 触
# 发 0.4s 1 轮回弹: modulate.a 1.0 → 0.4 (0.15s) → 1.0 (0.25s). 用
# Dictionary _quick_stats_pulse_tweens (Control → Tween) 跟踪每 target
# 的 tween 引用, 而不是单一全局 tween, 因为 4 段 click 可以并发 (玩家
# 快速点 2 段时第 1 段不要被 kill 留下中间 alpha). 每次新 click:
# 1) kill 旧 tween (如该 target 已有); 2) reset target.modulate.a = 1.0
# 避免中间值残留 (例如玩家 click 同一段 2 次, 第 1 次 tween kill 后
# target 可能是 0.7, 显式 reset 让玩家看到 "snap 到 1.0" 再 fade, 比
# "卡在 0.7 然后 fade 到 0.4" 更明确). 3) 创建新 tween + 2 段 tween_
# property (in / out) 链式 (不 parallel, 必须先 in 再 out). 4) 存
# Dictionary 用于下次 click 检测.
func _pulse_quick_stats_target(target: Control) -> void:
	if _quick_stats_pulse_tweens.has(target):
		var old_tween: Tween = _quick_stats_pulse_tweens[target]
		if old_tween != null and old_tween.is_valid():
			old_tween.kill()
	target.modulate.a = 1.0
	var t := create_tween()
	t.tween_property(target, "modulate:a", _QUICK_STATS_PULSE_ALPHA_LOW, _QUICK_STATS_PULSE_DURATION_IN)
	t.tween_property(target, "modulate:a", 1.0, _QUICK_STATS_PULSE_DURATION_OUT)
	_quick_stats_pulse_tweens[target] = t

# T162 (#83) — 最近 5 局行 BBCode 调色板：每行用 Pale Resonance
# (与 trend 5/10/20 一致) 让视觉组连贯；最新 1 局用 Amber Voice 暖色
# 高亮以 "上一次 run" 是玩家最关注的指标。
const _COLOR_RECENT_RUN_NORMAL := Color(0.718, 0.906, 0.867, 1.0) # Pale Resonance
const _COLOR_RECENT_RUN_LATEST := Color(0.949, 0.714, 0.431, 1.0) # Amber Voice

# T219 (#141) — ProfileRecentList 5 局行 alpha 渐变。最新 1 局 (i==0) 用
# _ALPHA_MAX 满亮（让"上一局"在视觉上最突出，玩家最关心）; 最旧 1 局
# (i==_PROFILE_RECENT_RUNS_MAX-1) 用 _ALPHA_MIN 50% 暗（让历史 run
# 退到背景层，避免与新 run 抢视觉焦点）。中间 3 局按 i 线性插值
# （i 越大越暗）。modulate.a 整体透明度 5 行梯度：1.0 / 0.875 / 0.75 /
# 0.625 / 0.5（5 步等差，步长 0.125）。与 T215 (#136) hover handler 互
# 不干扰 (hover handler 改 font_color 不改 modulate.a)。
const _RECENT_ROW_ALPHA_MAX := 1.0
const _RECENT_ROW_ALPHA_MIN := 0.5

# T152 (#79) — 0 数灰阶占位色。在 _refresh_stats() / _refresh_profile()
# 末尾的 stat 数字 0 时，把 Label 的 font_color 设为这个暖灰
# (0.5, 0.5, 0.55, 1)，让"未使用"状态在视觉组里"灰掉"，与
# 已有数字（暖白 0.875, 0.835, 0.784）形成对比。Echo 反弹行
# (T100 Glass Cyan) 也会被灰掉——保留"刚刚开始"的语义一致性：
# 数据存在但还没使用，就不抢眼。
# 不应用到 5 动词 BBCode 行（颜色 token 自身就是 verb 身份，
# 灰掉会切断"5 动词色域贯穿表层"的设计）。也不应用到时间字段
# (回响时长)——0:00 是合法的"刚开始"状态，与"已死 0 次"语义
# 不同。回响时长始终以暖白显示。
const _COLOR_ZERO_STAT := Color(0.5, 0.5, 0.55, 1.0)

var _is_paused: bool = false
var _profile_open: bool = false  # T126 — track panel state
# T217 (#138) — ProfileQuickStats 4 段独立 hover 联动状态字段. 玩家鼠
# 标进入任 1 段 (Achievement/BestTime/LongestRoom/RunNumber) → idx 段
# 提亮 (modulate WHITE) + 其他 3 段 dim 50% alpha. 字段存 idx 0-3, -1
# 表示无 hover (mouse_exited 后). 替代 T214 (#134) 旧版 bool 字段
# _quick_stats_hovered (只能表达"是否在 hover" 1 bit, 不能表达"hover
# 哪一段"). T217 4 sub-Label modulate 独立管理, 不需要 T214 旧版
# _quick_stats_default_text 字符串缓存 (modulate 是 4 个独立字段,
# _apply_quick_stats_hover_state() 重算即可).
var _quick_stats_hovered_idx: int = -1
# T217 (#138) — 4 sub-Label dim 50% alpha 颜色. modulate.a = 0.5 + RGB 不变
# (用 Color.WHITE * 0.5 等价于 RGB 0.5+0.5+0.5, 但我们要 RGB 不变只改
# alpha, 所以用 Color(1, 1, 1, 0.5) modulate 模式 (multiplicative blend)
# 与 Color(0.5, 0.5, 0.5, 1.0) modulate (灰化) 区分: Color.WHITE * 0.5
# 是 multiplicative, RGB 各 ×0.5, 4 sub-Label 原色 (Glass Cyan /
# Amber Voice / Muted Violet / Pale Resonance) 全部淡 50% 而非变灰.
const _QUICK_STATS_DIM := Color(1.0, 1.0, 1.0, 0.5)
# T218 (#139) — click 联动 pulse 节奏参数. 玩家点击 4 段中任 1 段 → 触
# 发对应 list 段的"pulse" (modulate.a 1.0→ALPHA_LOW→1.0 一轮回弹).
# 0.15s 渐入 (从 1.0 到 0.4 alpha) + 0.25s 渐出 (从 0.4 回到 1.0) = 0.4s
# 总时长. 选 0.4s 因为 (a) 比 hover_in/out 反馈略长, 给玩家"我点了,有
# 反应"的明确确认; (b) 比 banner 0.6s fade-in 短, 不会盖过 banner.
# _ALPHA_LOW 0.4: 暗 60% 让对应 list 段"明显一暗再亮", 但不"消失";
# 0.0 会让玩家以为目标节点被隐藏, 0.6 又显得"几乎没动".
const _QUICK_STATS_PULSE_DURATION_IN := 0.15
const _QUICK_STATS_PULSE_DURATION_OUT := 0.25
const _QUICK_STATS_PULSE_ALPHA_LOW := 0.4
# T218 (#139) — per-target tween 引用表 (Control → Tween). 用 Dictionary
# (不是单一全局 tween) 是为了 4 段 click 可以并发: 例如玩家点 Achievement
# (idx 0 → _profile_achv_list 正在 pulse 0.4s) 期间又点 BestTime (idx 1 →
# _profile_best_streak), 两条 tween 各自 track 各自 target, 互不打断.
# 如果是单一全局 tween, 第二次 click 会 kill 第一次, 把 achv_list 卡在
# 中间 alpha (如 0.7), 视觉上"卡住"直到下次 _refresh 才修. 每次 click
# 前先 kill 旧 tween + reset target.modulate.a = 1.0 避免中间值残留.
var _quick_stats_pulse_tweens: Dictionary = {}
# T225 (#147) — ProfileQuickStats 4 段 hover 提亮 tween 引用. 1 个全局
# tween (不是 4 个), 因为 4 sub-Label modulate 同步渐变, 用 1 个 tween
# 4 个 set_parallel tween_property 即可. 每次 _apply_quick_stats_hover_state
# 先 kill 旧 tween 再创建新 tween, 避免快速 hover 进出 4 段时 tween 叠加.
var _quick_stats_hover_tween: Tween = null
# T226 (#147) — AchievementGrid 14 slot base alpha 字典 (slot → base_alpha).
# _refresh_achievement_grid 末尾存每个 slot 当前 base alpha (unlocked=1.0,
# locked=lerp(_ACHV_LOCKED_ALPHA_START, _ACHV_LOCKED_ALPHA_END, progress)).
# _on_slot_hover_in 读 base_alpha + _SLOT_HOVER_BRIGHT_ALPHA_BOOST 算 boosted
# alpha (clamp 1.0), 让 locked slot hover 时 "微微亮一阶" 暗示可点查看.
# _on_slot_hover_out 读 base_alpha 恢复 modulate 终点 alpha, 替换 T111 旧版
# hardcoded alpha 0.5 让 locked slot 跟随解锁进度退场. 与 T222 (#144)
# 解锁进度联动 0 冲突 (T222 改 _refresh 末尾 modulate base, T226 hover 时
# +0.1 偏移 base; 两者时序分离).
var _slot_hover_alpha_base: Dictionary = {}
# T231 (#151) — ProfileRecentList 5 局行 base alpha 字典 (row → base_alpha).
# _refresh_recent_runs_list 末尾存每行 base alpha (5 行 1.0 / 0.875 / 0.75 /
# 0.625 / 0.5 = T219 (#141) alpha 渐变 base 值). _on_recent_row_hover_in
# 读 base + _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST (clamp 1.0) 算 boosted
# alpha, 让 5 行 hover 时 "微微亮一阶" 暗示"我正在看这一行", 与 T226
# AchievementGrid slot hover +0.1 boost 完全同模式. _on_recent_row_hover_out
# 读 base alpha 恢复 modulate 终点 alpha, 与 T215 (#136) font_color 提亮
# 到 Color.WHITE 同 row 叠加 (2 个 hover 反馈层: font_color 提亮 + alpha
# boost). 0.12s fade 与 T226 hover fade 0.12s 同节奏. 与 T219 (#141) alpha
# 渐变 0 冲突 (T219 改 _refresh 末尾 modulate base, T231 hover 时 +0.1 偏移
# base; 两者时序分离). 与 T225 (#147) ProfileQuickStats 4 段 hover tween
# 0 冲突 (T225 改 4 sub-Label modulate, T231 改 5 row modulate; 不同节点).
var _recent_row_hover_alpha_base: Dictionary = {}
# T215 (#136) — ProfileRecentList 5 局行悬停高亮状态字段。
# 玩家鼠标进入任一 run row → 该行 font_color 提亮到 Color.WHITE（从
# _COLOR_RECENT_RUN_LATEST / _COLOR_RECENT_RUN_NORMAL 还原色）;
# 鼠标离开 → restore 到 _recent_row_default_color[idx]（_refresh_recent_runs_list
# 在创建 row 时保存，避免误把高亮版当 default 写回）。
# 与 T214 (#134) _quick_stats_hovered 模式同源（每次 _refresh_recent_runs_list
# 清空 + 重建 row 子节点 → 数组 resize 到新长度），但 5 行独立 hover_in
# handler（互不干扰；T162 (#83) 同 row_lbl 5 个连续节点）。
# 0 跨行联动：玩家 hover 第 3 行只提亮第 3 行，其他 4 行保持原色（避免
# 重叠抖动 + 与 T214 Run # 段 1 段提亮 0 冲突）。
var _recent_row_hovered: Array = []        # Array[bool] length = _PROFILE_RECENT_RUNS_MAX
var _recent_row_default_color: Array = []  # Array[Color] length = row count

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

	_resume_btn.pressed.connect(_on_resume)
	_save_btn.pressed.connect(_on_save)
	_profile_btn.pressed.connect(_on_profile)  # T126
	_settings_btn.pressed.connect(_on_settings)
	_restart_btn.pressed.connect(_on_restart)
	_quit_btn.pressed.connect(_on_quit_to_title)

	# T070 — SaveLoadMenu signal wiring (mode = save, so only save/delete)
	_save_load_menu.save_requested.connect(_on_save_load_saved)
	_save_load_menu.delete_requested.connect(_on_save_load_deleted)
	_save_load_menu.load_requested.connect(_on_save_load_loaded)  # defensive

	# T126 — Profile panel close button
	_profile_close_btn.pressed.connect(_on_profile_close)
	# T135 — share-to-clipboard button.  Idempotent: pressing
	# repeatedly just rewrites the clipboard with the same
	# text and refreshes the "已复制 ✓" feedback timer.
	_profile_share_btn.pressed.connect(_on_share_pressed)

	_build_achievement_grid()
	_build_profile_achievement_list()

	# T199 (#116) — 5 verb row hover tooltip. 玩家在 PauseMenu
	# 看到 [color=#E86D5A]Pulse 7[/color] row 时, 悬停即弹多行文本
	# 显示每个 verb 的 cost / cooldown / radius / 键位 / 一句中文描述。
	# 两处 Label (StatsPanel StatAbilities + ProfilePanel ProfileAbilities)
	# 共享同一份权威数据 (VERB_HINT_DATA), 避免双源。tooltip 渲染
	# 由 Godot 4.6 自带 Popup 处理, 5s timeout, 玩家可读充分。
	# F013.E (#159) — header 5 声波能力 → 6 声波能力 (Whisper 加入).
	# T244 (#161) — 6 verb row 加 mouse_entered/exited handler, 0.12s
	# tween font_color + modulate RGB 加色 (1.0→1.15 additive brighten)
	# 同步 T231+T240 节奏. 让"6 verb row 是交互元素" 视觉组连贯, 配合
	# T199 tooltip 提供即时"行被点中" 视觉强调.
	var _verb_hint_text: String = _build_verb_hint_tooltip()
	if _stat_abilities:
		_stat_abilities.tooltip_text = _verb_hint_text
		# T244 — mouse_entered/exited handler 0.12s tween (与 T199 tooltip 并存)
		_stat_abilities.mouse_entered.connect(_on_verb_row_hover_in)
		_stat_abilities.mouse_exited.connect(_on_verb_row_hover_out)
	if _profile_abilities:
		_profile_abilities.tooltip_text = _verb_hint_text
		# T244 — Profile panel 6 verb row 同样加 hover handler (与 Stats panel 共享
		# 1 对 _on_verb_row_hover_in / _out, 2 row 互斥 visibility 0 干扰)
		_profile_abilities.mouse_entered.connect(_on_verb_row_hover_in)
		_profile_abilities.mouse_exited.connect(_on_verb_row_hover_out)

	# T160 — Banner 起始态：modulate.a = 0 + 隐藏。
	# 玩家从按下 ESC 到 _ready 完成时 banner 仍默认 visible=false，
	# 我们的 _show_banner() 在 animate 时才设 visible=true。
	if _new_achv_banner:
		_new_achv_banner.modulate.a = 0.0
		_new_achv_banner.visible = false

	# T213 (#133) — ProfileQuickStats 4 段总览 hover tooltip
	# 玩家悬停 QuickStats 1 行 (★ 成就 X/Y · 最佳 mm:ss · 最长单房 mm:ss · Run #N ★) 时,
	# 弹多行文本显示 4 段各自的含义 + 颜色 hex + 详细位置. 与 T199 5 verb tooltip 风格
	# 一致: 纯文本 + 关键词前置, Godot 4.6 自带 tooltip 渲染器按 \n 自动换行, 5s timeout
	# 玩家可读充分. 4 段 4 色 (Glass Cyan / Amber Voice / Muted Violet / Pale Resonance)
	# 已经在视觉上明显区分, tooltip 只承担"含义详情"职责, 颜色 hex 给色弱玩家辅助.
	# T217 (#138) — tooltip 绑到 HBoxContainer (parent). 旧版 T214 时期
	# 1 Label 是绑到 _profile_quick_stats 自身; T217 拆 4 sub-Label 后,
	# tooltip 绑到 HBoxContainer 让 4 sub-Label 共享同一 tooltip (玩家
	# 悬停任 1 sub-Label 都弹同一文本, 0 行为差异, 4 段 tooltip 含义
	# 共享). HBoxContainer 继承自 Control, 支持 tooltip_text.
	if _profile_quick_stats:
		_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()

	# T217 (#138) — QuickStats 4 段独立 hover 联动 (4 sub-Label). T214 (#134)
	# 旧版 1 Label + 4 BBCode 段 1 段 (Run #) 单独高亮 → T217 (#138) 4 sub-Label
	# 1 段高亮 + 3 段 dim 50% alpha 全联动. 4 sub-Label 各 mouse_filter=STOP
	# (Label 默认 MOUSE_FILTER_IGNORE 显式设 STOP, 与 T111 (#58) 成就 grid
	# TextureRect + T214 (#134) QuickStats 1 Label 同模式). 4 sub-Label
	# mouse_entered.connect 1 对 handler (bind 段号 idx 0-3) 处理 4 段;
	# mouse_exited.connect 同 1 对. T213 tooltip 在 hover 时弹 4 段含义说
	# 明 (静态信息), T217 4 段全联动 给玩家"鼠标进入 4 段中哪一段" 视觉
	# 反馈 (动态焦点); T213 + T217 双层互补.
	if _quick_stats_achievement:
		_quick_stats_achievement.mouse_filter = Control.MOUSE_FILTER_STOP
		_quick_stats_achievement.mouse_entered.connect(_on_quick_stats_hover_in.bind(0))
		_quick_stats_achievement.mouse_exited.connect(_on_quick_stats_hover_out.bind(0))
	if _quick_stats_best_time:
		_quick_stats_best_time.mouse_filter = Control.MOUSE_FILTER_STOP
		_quick_stats_best_time.mouse_entered.connect(_on_quick_stats_hover_in.bind(1))
		_quick_stats_best_time.mouse_exited.connect(_on_quick_stats_hover_out.bind(1))
	if _quick_stats_longest_room:
		_quick_stats_longest_room.mouse_filter = Control.MOUSE_FILTER_STOP
		_quick_stats_longest_room.mouse_entered.connect(_on_quick_stats_hover_in.bind(2))
		_quick_stats_longest_room.mouse_exited.connect(_on_quick_stats_hover_out.bind(2))
	if _quick_stats_run_number:
		_quick_stats_run_number.mouse_filter = Control.MOUSE_FILTER_STOP
		_quick_stats_run_number.mouse_entered.connect(_on_quick_stats_hover_in.bind(3))
		_quick_stats_run_number.mouse_exited.connect(_on_quick_stats_hover_out.bind(3))
	# T218 (#139) — QuickStats 4 段 click 联动 (4 sub-Label). T217 (#138)
	# 4 段 hover 联动 (mouse_entered/exited) 给玩家"鼠标进入 4 段中哪一段"
	# 视觉反馈; T218 4 段 click 联动 给玩家"我点了哪一段, 对应 list 段在哪"
	# 的明确指示. 玩家点击 Achievement 段 (idx 0) → _profile_achv_list
	# (成就列表) pulse 一下; BestTime (idx 1) → _profile_best_streak
	# (顶级行第 2 块) pulse; LongestRoom (idx 2) → _profile_longest_room
	# (顶级行第 3 块) pulse; RunNumber (idx 3) → _profile_recent_list
	# (最近 5 局详细行) pulse. 0 scroll/位置变化 (panel 是 fixed-size, 4
	# 目标都已在 view 内, pulse 足够定位). mouse_default_cursor_shape
	# = CURSOR_POINTING_HAND 给视觉暗示"这 4 段可点" (Label 默认 cursor
	# 是箭头, T218 显式设手指 cursor 跟 T199 verb hint + T160 banner 互
	# 相呼应). gui_input.connect 1 个 click handler (bind 段号 idx 0-3)
	# 处理 4 段 click (与 T217 4 段 hover 同模式).
	if _quick_stats_achievement:
		_quick_stats_achievement.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_quick_stats_achievement.gui_input.connect(_on_quick_stats_clicked.bind(0))
	if _quick_stats_best_time:
		_quick_stats_best_time.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_quick_stats_best_time.gui_input.connect(_on_quick_stats_clicked.bind(1))
	if _quick_stats_longest_room:
		_quick_stats_longest_room.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_quick_stats_longest_room.gui_input.connect(_on_quick_stats_clicked.bind(2))
	if _quick_stats_run_number:
		_quick_stats_run_number.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_quick_stats_run_number.gui_input.connect(_on_quick_stats_clicked.bind(3))

	# T160 — 订阅成就解锁全局信号。任何时候 unlock 触发我们
	# 调 _show_banner(), 内部检查 visible + ts 避免重复动画.
	if PlayerStats and PlayerStats.has_signal("achievement_unlocked"):
		PlayerStats.achievement_unlocked.connect(_on_achievement_unlocked_for_banner)

	# T236 (#154) — StatsPanel 底部 BGM 主题提示行. _ready 末尾首次
	# 拉 AudioManagerEnhanced.get_current_music_key() 公开 API (#62 T117
	# 落地), 渲染到 _stat_bgm.label. 空字符串 fallback "—" (0 主题
	# 或 audio_manager_enhanced 尚未初始化). _refresh_stats 末尾
	# 也会调一次, 0 双源, 仅 0 主题初始态时这一次的值会被 _refresh_stats
	# 覆盖, 0 性能浪费 (单一 `if has_node` + 1 次 dict lookup).
	_refresh_stat_bgm()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	_is_paused = not _is_paused
	get_tree().paused = _is_paused
	visible = _is_paused

	if _is_paused:
		# If a SaveLoadMenu is somehow already open from previous state, close it
		if _save_load_menu.visible:
			_save_load_menu.hide_menu()
		# T126 — make sure profile panel is closed when re-opening pause
		if _profile_open:
			_on_profile_close()
		modulate = Color.TRANSPARENT
		_refresh_stats()
		# T160 — 检查玩家在按 ESC 前 5s 内是否刚解锁过成就（信号在
		# menu 隐藏时不响应, 这里补播一次). 仅对 latest unlock ts
		# > _last_seen_unlock_ts 的事件触发, 避免重复动画.
		_check_banner_for_recent_unlock()
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)


# T160 — Achievement unlocked signal handler.  We only show
# the banner if the pause menu is actually visible (in-game
# achievement notifications go through AchievementNotification
# CanvasLayer; this banner is a complementary "in-pause"
# reminder).  We also record the unlock timestamp so the
# toggle_pause "recent unlock" check in _check_banner_for_recent_unlock
# can avoid double-firing.
func _on_achievement_unlocked_for_banner(_id_val: String, _title_zh: String, _desc_zh: String) -> void:
	if not _is_paused:
		# Even if menu isn't visible, still record the ts so the
		# next toggle_pause can decide whether to show.
		var sorted_unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
		if not sorted_unlocked.is_empty():
			_last_seen_unlock_ts = int(sorted_unlocked[sorted_unlocked.size() - 1][3])
		return
	_show_new_achv_banner()

# T160 — 玩家刚按 ESC 时检查是否有"近期解锁"未播过 banner.
# 通过比 _last_seen_unlock_ts 与最新 unlock ts 实现去重.
func _check_banner_for_recent_unlock() -> void:
	if _new_achv_banner == null:
		return
	var sorted_unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	if sorted_unlocked.is_empty():
		return
	var latest: Array = sorted_unlocked[sorted_unlocked.size() - 1]
	var latest_ts: int = int(latest[3])
	if latest_ts <= _last_seen_unlock_ts or latest_ts <= 0:
		return
	# 5s 窗口：只对"刚刚"的解锁补播 banner, 太久前的成就属于"历史"
	# 让 LatestUnlock label 持续显示就够了.
	var now_unix: int = int(Time.get_unix_time_from_system())
	if now_unix - latest_ts > int(_BANNER_RECENT_UNLOCK_WINDOW):
		# 把 ts 同步到 _last_seen_unlock_ts 但不播 banner, 避免再次触发
		_last_seen_unlock_ts = latest_ts
		return
	_last_seen_unlock_ts = latest_ts
	_show_new_achv_banner()

# T160 — Show the "新成就！" banner: 0.4s fade-in + 0.4s hold + 0.4s
# fade-out.  净可见 0.8s + 进出淡入淡出 = 总动画 1.2s.
# Kill 任何 in-flight tween 避免快速连点成就时动画叠加.
func _show_new_achv_banner() -> void:
	if _new_achv_banner == null:
		return
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()
	_new_achv_banner.text = "✦ 新成就！✦"
	_new_achv_banner.modulate.a = 0.0
	_new_achv_banner.visible = true
	_banner_tween = create_tween()
	# Fade in 0.4s
	_banner_tween.tween_property(_new_achv_banner, "modulate:a", 1.0, _BANNER_FADE)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Hold 0.4s (BANNER_DURATION - 2 * FADE = 0.8 - 0.8 = 0.0s;
	# the visible "hold" is 0.0s by spec, the player sees the
	# banner pop in then immediately pop out, the 0.8s spec
	# from ROADMAP T160 is "净可见" not "total animation").
	# The combination of fade-in + fade-out gives ~0.8s perceived.
	# Fade out 0.4s
	_banner_tween.tween_interval(0.0)
	_banner_tween.tween_property(_new_achv_banner, "modulate:a", 0.0, _BANNER_FADE)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Cleanup callback: hide node so it doesn't intercept mouse
	_banner_tween.tween_callback(func() -> void:
		if _new_achv_banner:
			_new_achv_banner.visible = false
	)


func _refresh_stats() -> void:
	_achv_progress.text = "成就: %d/%d" % [PlayerStats.get_unlocked_count(), PlayerStats.get_total_count()]
	# T152 (#79) — 0 数灰阶占位：值 0 → 文本 "—" + 暖灰；
	# 值 > 0 → 暖白 + 数字。当前 run 状态行用 _set_zero_aware_stat
	# 统一处理 rooms/enemies/shards/deaths/cuts/reflects/lanterns。
	_set_zero_aware_stat(_stat_rooms, PlayerStats.rooms_cleared, "完成房间  %d")
	_set_zero_aware_stat(_stat_enemies, PlayerStats.enemies_purified, "净化敌人  %d")
	_set_zero_aware_stat(_stat_shards, PlayerStats.shards_collected, "收集碎片  %d")
	_set_zero_aware_stat(_stat_deaths, PlayerStats.deaths, "共鸣消散  %d")
	# T102/T103 — 五动词 row 颜色对齐：每个动词用 STYLE_GUIDE 色域 HEX
	# BBCode 包裹 — Pulse = Coral Pulse #E86D5A / Bind = Muted Violet
	# #65506A / Cut = Amber Voice #F2B66E / Echo = Glass Cyan #69C7CE /
	# Wave = Pale Resonance #B7E6DC（#74 轮新加第五动词，与
	# resonance_wave_ability.gd 主色一致；冷色+1 颜色饱和度=5 动词中
	# 最"光波"的暖冷梯度末端）。
	# 数字也跟着动词上色，让"用得越多 = 颜色越跳"成为可读统计。
	# bbcode_enabled 在 pause_menu.tscn 节点上预设；分隔符 " · " 仍
	# 用默认暖白 (0.875, 0.835, 0.784) 作为「中性框架」，5 动词色
	# 块在视觉组里跳出来。视觉组层面：5 动词色域贯穿 6 处（HUD 5
	# 冷却条 + 屏幕命中闪 + PauseMenu 5 动词行 + 商店 echo_charm +
	# 成就图标 A025/A033/A038/A061 + 新增 A066 quintuple_voice），
	# 1px 8pt 小字也能分辨。
	# F013.E (#159) — 第六动词 Whisper 加 6 verb row (Muted Mauve #C8A4D8).
	# 6 verb 接入路径 §9.1 第 8 步: pause_menu.gd::_stat_abilities BBCode
	# 5 → 6 verb. 数字也跟着上色 (与 5 verb 同), 视觉组里 6 块色清晰可分.
	_stat_abilities.text = "[color=#E86D5A]Pulse %d[/color]  ·  [color=#65506A]Bind %d[/color]  ·  [color=#F2B66E]Cut %d[/color]  ·  [color=#69C7CE]Echo %d[/color]  ·  [color=#B7E6DC]Wave %d[/color]  ·  [color=#C8A4D8]Whisper %d[/color]" % [
		PlayerStats.pulse_used, PlayerStats.bind_used,
		PlayerStats.cut_used, PlayerStats.echo_used,
		PlayerStats.wave_used, PlayerStats.whisper_used
	]
	# T152 (#79) — 斩断腐蚀 / Echo 反弹 / 存档灯笼 同样 0 数灰阶。
	# Echo 反弹原本带 Glass Cyan 调色 (T100) —— >0 时还原回 cyan，
	# 0 时按规则"灰掉" (灰阶 + "—" 占位)。色彩与"刚刚开始"的语
	# 义一致：数据存在但还没使用，就不抢眼。
	_set_zero_aware_stat(_stat_cuts, PlayerStats.silence_webs_cut, "斩断腐蚀  %d")
	if PlayerStats.echo_reflects > 0:
		_stat_reflects.text = "Echo 反弹  %d" % PlayerStats.echo_reflects
		_stat_reflects.add_theme_color_override("font_color", Color(0.412, 0.78, 0.808, 1.0))
	else:
		_stat_reflects.text = "Echo 反弹  —"
		_stat_reflects.add_theme_color_override("font_color", _COLOR_ZERO_STAT)
	_set_zero_aware_stat(_stat_lanterns, PlayerStats.save_lanterns_activated, "存档灯笼  %d")
	var t := int(PlayerStats.get_run_time_seconds())
	var m := t / 60
	var s := t % 60
	_stat_time.text = "回响时长  %02d:%02d" % [m, s]
	# T109 — 最近解锁行：取解锁时间戳最大的成就 + 时间。
	# 未解锁时显示 "—" 占位（与 tooltip 一致）。
	var sorted_unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	if sorted_unlocked.is_empty():
		_latest_unlock.text = "最近解锁：—"
	else:
		var latest: Array = sorted_unlocked[sorted_unlocked.size() - 1]
		var latest_title: String = latest[1]
		var latest_ts: int = int(latest[3])
		var ts_str := "—"
		if latest_ts > 0:
			var dt := Time.get_datetime_dict_from_unix_time(latest_ts)
			ts_str = "%02d-%02d %02d:%02d" % [dt.month, dt.day, dt.hour, dt.minute]
		_latest_unlock.text = "最近解锁：%s  %s" % [latest_title, ts_str]
	_refresh_achievement_grid()
	# T236 (#154) — StatsPanel 底部 BGM 主题提示行. 玩家在 PauseMenu
	# 打开时立即可见"现在听的是哪个 BGM 主题" (例 "BGM · archive_exploration"),
	# 不需要切到 Settings 调 Music bus 音量才能猜到. 与 _ready 末尾
	# _refresh_stat_bgm() 首次拉取 + 0 主题 fallback "—" 同步 (0 双源).
	# 这里放 _refresh_stats 末尾是因为 toggle_pause 打开 PauseMenu
	# 时 _refresh_stats 被调 (T160 时期惯例), BGM 主题可能在玩家
	# 上一局结束后已切换 (SettingsMenu 调过, 或者 audio_manager_enhanced.gd
	# 内部 boss / state 切换), 重新拉一次保证当前 PauseMenu 显示的
	# BGM 主题 100% 是当前正在播放的主题 (不缓存).
	_refresh_stat_bgm()

# T236 (#154) — StatsPanel 底部 BGM 主题提示行. 拉
# AudioManagerEnhanced.get_current_music_key() 公开 API (autoload #62 T117
# 落地, 9 主题之一 title_intro / hub_warm / archive_exploration /
# archive_boss / archive_boss_dual / archive_dawn / archive_storm /
# silence_void / whisper_hollow; 返回 String, 空字符串 = 未播放), 渲染
# 到 _stat_bgm.label. 空字符串 fallback "—" (0 主题, audio_manager_enhanced
# 尚未初始化, 或玩家在 Settings 切到 0 volume muted 主题). 7pt 暖白小字 +
# 1 个 ` · ` middle-dot (0.5 + middle-dot + 0.5) 视觉风格与 ProfileQuickStats
# 4 段 + ProfileAudit 4 字段行 + T235 ProfileRecentList 5 行 0 100% 一致,
# 玩家跨面板视觉组连贯. 0 主题切换时不调 signal, 0 timer, 0 副作用, 0 性能
# 影响 (单次 dict lookup + 1 个 label.text 赋值). 防御: _stat_bgm 节点 0
# always-present (pause_menu.tscn 显式存在), 0 显式 null check 需要.
func _refresh_stat_bgm() -> void:
	var current_key: String = AudioManagerEnhanced.get_current_music_key()
	var display: String = current_key if not current_key.is_empty() else "—"
	_stat_bgm.text = "BGM · %s" % display

# T222 (#144) — AchievementGrid locked slot alpha fade. 14 成就
# 解锁进度 (unlocked/total) 线性插值 mapped to modulate.a: 玩家
# 0/14 解锁 → 0.5 alpha (full muted, 起步态) ; 玩家 14/14 解锁 →
# 0.2 alpha (locked slots 0 残留 fade out, 14 成就都亮, 视觉组
# "完成态" 整版清空暗色). 中间按 unlocked/total 比例线性.
# RGB 通道保留 (0.25, 0.25, 0.3) = 暗灰调, 只改 alpha. 与 T111
# hover handler 0 冲突 (hover 改 modulate → 暖色, 0 改 alpha).
# 0.2 终点而非 0.0 避免 fade 到底 0 透明让玩家以为"成就消失".
# T109 时间排序 + T111 hover + T213 4 段 tooltip + T218 click
# 联动 全 0 触碰, 仅 _refresh_achievement_grid 末尾 locked 段
# 改 Color.alpha 用 _ACHV_LOCKED_ALPHA_START/_END lerp 计算.
const _ACHV_LOCKED_ALPHA_START := 0.5
const _ACHV_LOCKED_ALPHA_END := 0.2
const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)
# T226 (#147) — AchievementGrid 14 slot hover +1 灰阶预览. T111 (#58) 旧版
# _on_slot_hover_in / _out 用 0.12s quad-out tween 改 3 个 property (scale
# 1.0→1.5, self_modulate 1.0→1.4, modulate 暖色 1.0→1.2/1.1/0.9). "1.5x
# 放大 + 暖色" 视觉组明确, 但"locked slot (alpha 0.5/0.2 lerp) 是否可
# 点查看" 反馈弱 — 玩家看到 locked slot 0.5 alpha 暗, hover 进去之前不
# 知道会有什么变化. T226 (#147) 升级: locked slot hover 时 modulate alpha
# 从 base (0.5/0.2) +0.1 → 0.6/0.3, 让玩家"微微亮一阶" 暗示"可点查看
# tooltip". unlocked slot alpha 1.0 clamp 到 1.0, 不变 (已经最亮).
# 与 T222 (#144) 解锁进度联动 0 冲突 (T222 改 _refresh 末尾 modulate
# base, T226 hover 时 +0.1 偏移 base; 两者时序分离). 实现: 1 个 Dictionary
# _slot_hover_alpha_base (slot → base_alpha) 在 _refresh_achievement_grid
# 末尾存每个 slot 当前 base alpha (unlocked = 1.0, locked = lerp). 0.12s
# fade 与 T111 旧版 0.12s quad-out 同节奏, 1 套 tween 内部 4 个 set_parallel
# 同步推进.
const _SLOT_HOVER_BRIGHT_ALPHA_BOOST := 0.1
const _SLOT_HOVER_FADE_DURATION := 0.12
# T231 (#151) — ProfileRecentList 5 局行 hover +0.1 alpha boost (T215 1 步升级).
# T215 (#136) 旧版 _on_recent_row_hover_in / _out 只改 font_color (snap
# 立即重算, 0 tween), 玩家看到 5 行 7pt 小字 hover 时虽然 font_color 提亮
# 到 #FFFFFF, 但 modulate.a 还是 T219 (#141) 5 行 alpha 渐变 (1.0 / 0.875
# / 0.75 / 0.625 / 0.5) 中的 base 值. 旧版 "最旧 1 局" (i==4) base 0.5
# alpha, hover 进去只看到 font_color 提亮但 alpha 还是 0.5 半暗, 视觉上
# "我 hover 进去效果不明显" (本来 0.5 半暗, hover 完还是 0.5 半暗). T231
# 升级: hover 时 modulate.a 额外 +0.1 (clamp 1.0), 让 5 行 hover 时 alpha
# 也"微微亮一阶" 暗示"我正在看这一行", 与 T226 (#147) AchievementGrid
# slot hover +0.1 boost 完全同模式 (跨面板 hover 反馈一致). 实现: 1
# 个 Dictionary _recent_row_hover_alpha_base (row → base_alpha) 在
# _refresh_recent_runs_list 末尾存每行 base alpha (5 行 1.0/0.875/0.75/
# 0.625/0.5); _on_recent_row_hover_in 读 base + 0.1 boost (clampf 1.0)
# tween 0.12s quad-ease-out 到 boosted alpha; _on_recent_row_hover_out
# 读 base alpha tween 0.12s 恢复. 0.12s fade 与 T226 AchievementGrid
# hover fade 0.12s 同节奏. T215 (#136) font_color 提亮到 Color.WHITE
# 保留 (snap 立即, 与 T226 1.5x 放大 + 暖色 模式不同 — T215 1 Label
# row, 0 scale 变化), 2 个 hover 反馈层 (font_color 提亮 + alpha boost)
# 在同一 row 上叠加, 玩家视觉组连贯.
const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1
const _RECENT_ROW_HOVER_FADE_DURATION := 0.12
# T240 (#158) — ProfileRecentList 5 行 hover font_color 提亮 0.12s 渐变 (T215 1 步升级, 与
# T231 alpha boost 同步). T215 (#136) 旧版 _on_recent_row_hover_in / _out 走 add_theme_color_
# override snap 立即重算 font_color (Color.WHITE 或 default_color), 玩家"鼠标进入 → 行
# 立即变 WHITE" 是 snap 切换, 不够丝滑. T240 (#158) 升级: 0.12s 渐变 (TRANS_QUAD + EASE_OUT)
# 让 font_color 从 default_color 渐变到 Color.WHITE (hover_in) 或反向 (hover_out). 与 T231
# alpha boost 0.12s 节奏同步 (同 _RECENT_ROW_HOVER_FADE_DURATION = 0.12, 同一行 row 同时 (1)
# font_color 0.12s 渐到 WHITE + (2) modulate:a 0.12s 渐到 base+0.1 → 双通道同步, 视觉组
# 连贯). 与 T225 (#147) ProfileQuickStats 4 段 hover 0.3s + T226 (#145) AchievementGrid slot
# hover 0.12s + T231 (#151) RecentList 5 行 alpha boost 0.12s + T240 5 行 font_color 0.12s
# 跨面板 hover 节奏 100% 透明 (玩家 0 歧义感知"hover 一致"). 0 副作用: T215 _recent_row_
# hovered / _recent_row_default_color 0 改; T231 _RECENT_ROW_HOVER_FADE_DURATION 保留;
# T234/T235 row text literal 0 改; T216 tooltip_text 0 改; T219 alpha 渐变 0 改; 1 个
# tween cache (_recent_row_font_color_tween) 5 行共享, 防快速 hover 进出 tween 叠加撕裂.
const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12
# T240 tween cache (5 行 row 共用 1 个 font_color tween 引用, mouse 移开时 kill 旧
# tween 释放; 与 T225 #147 _quick_stats_hover_tween + T231 #151 5 行独立 alpha_tween
# 不同 — T240 跨 5 行共享 1 个 tween 因为同 row 不可能同时 hover_in 和 hover_out, 5 行
# 同时 hover 在玩家单鼠标场景下也 0 发生, 共享 1 个 tween 引用 0 风险).
var _recent_row_font_color_tween: Tween = null
# T249 (#167) — ProfileRecentList 5 行 row 文本 5 字段 → 7 字段扩展 (同步 _RECENT_ROW_HINT
# tooltip 字段顺序). 在 _refresh_recent_runs_list format 字符串中 inline 加 2 派生率 (房/时
# + 净/时) = row 文本 5 字段 → 7 字段, 6 个 middle-dot 分隔符 (4 原 5 字段 + 2 新派生率)
# 拼接, 7 字段顺序与 _RECENT_ROW_HINT tooltip 100% 对齐: Run # → 房 → 净 → 碎 → 时 → 房/时
# → 净/时 (玩家 hover 弹 tooltip 看 7 字段顺序, row 文本 7 字段顺序也是同样 1→7, 跨层视觉
# 组连贯, 0 字段顺序错位 0 歧义). 派生率算法: rooms_per_minute = round(rooms / (t_sec /
# 60.0)); enemies_per_minute = round(enemies / (t_sec / 60.0)); 防御: t_sec == 0 (玩家
# 0 时长就死亡) → 派生率 0 (var init 0 + if t_sec > 0.0 守卫跳过赋值, 0/0 = nan 防御).
# 与 _RECENT_ROW_TIP_INDICATOR 末位保留 (T234 #153 tip indicator 0 删), 0 BBCode 包裹
# (T249 走纯文本 + add_theme_color_override, 0 theme override 优先级冲突, 与 T215+T240
# hover 主题色 override 路径完全兼容, 0 额外 BBox 0 重排). 同步 T231 (#151) 5 行 alpha
# boost + T240 (#158) 5 行 font_color 0.12s 渐变 hover 反馈节奏, hover 时整行 7 字段高
# 亮 (T215 Color.WHITE + T240 0.12s tween + T231 +0.1 alpha boost) 0 触碰 hover handler,
# 0 触碰 T215/T216/T219/T231/T232/T234/T235/T240/T136/T137 任何 const. 单行字符从 ~30 扩
# 到 ~50 (7pt 字号下 ≈ 130-140 px, 5 行均 < 240 px, ProfileRecentList ScrollContainer 容器
# 宽容纳, 0 layout 抖动). I060 (#167) 冒烟测试 35 项断言全 pass.
# T232 (#151) — 顶级行第 4 块 "近期共鸣 (近因加权)" 跨 run 时间衰减权重.
# 玩家 5 局历史 weight = [0.5^4, 0.5^3, 0.5^2, 0.5^1, 0.5^0] = [0.0625, 0.125,
# 0.25, 0.5, 1.0] 倒序加在 5 局 shards / 5 局 rooms 上, 算 weighted_ratio =
# sum(weight*shards)/sum(weight*rooms). 玩家技能最近 5 局稳步提升时, 早期
# 低分 run 拉低均值幅度被压制, 跨 run 加权比 5 局同等加权更接近"现在". 0.5
# 衰减 vs 0.7 衰减: 0.5 压制早期 run 80% 权重, 0.7 压制 50% — 0.5 更灵敏
# 反映技能变化, 与 "近期" 命名一致. 与 T201 AvgResonance 区别: T201 跨
# 全 run 累计比 (稳定基线), T232 跨 N 局加权 (近期技能). 玩家 1-2 局
# 早期 history 时加权效果 ≈ 简单平均 (权重都接近 0.0625-0.5), 不会
# 突变. history 大小 0 路径 "—" 占位 (与 T201/T209 同款).
const _RECENT_RESONANCE_DECAY := 0.5
const _RECENT_RESONANCE_HISTORY_WINDOW := 5
# T234 (#153) — ProfileRecentList 5 行 row text 末尾 1 个 "↗" 字符
# (space + right arrow Unicode U+2197) 永远 visible, 提示玩家"行末有
# tooltip, 悬停查看 7 字段完整含义 (含 房/时 + 净/时 2 个派生率
# T216 (#137) hint 5→7 字段扩展)". row 文本当前只显示 5 字段
# (Run #/房/净/碎/时), tooltip 多 2 个派生率 (房/时/净/时)
# 算自原 5 字段 — "↗" 提示玩家"hover here for 2 extra derived
# rate fields". T215 (#136) font_color 提亮 + T231 (#151) alpha +0.1
# boost 同步: 悬停时 row 整行变 WHITE + alpha +0.1, "↗" 自然被
# 高亮 (1 个 font_color + 1 个 modulate.a 同时作用, 与 row 其余字符
# 同步, 0 单独 indicator tween). 1 个 unicode 字符 (3 字节 UTF-8
# "↗" + 1 字节 ASCII " ") 比 "?" / "ⓘ" 更具方向感 (指向 tooltip
# "上方" 弹出的视觉隐喻). 与 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST
# + _RECENT_ROW_HOVER_FADE_DURATION 0 冲突 (T234 仅改 row 文本
# literal 末尾, T231 改 modulate.a, 0 干扰; "↗" 1 字符 inline 0
# 影响 row 宽度 7pt 字号下 1 char ≈ 1.5-2px, 5 行均 < 240px 远
# 低于 ProfileRecentList ScrollContainer 容器宽).
const _RECENT_ROW_TIP_INDICATOR := " ↗"
# T235 (#154) — ProfileRecentList 5 行 row 文本字段间分隔用 ` · ` middle-dot
# (中点 U+00B7) 视觉细化. 之前 row 文本是 `"Run #3  房 4  净 12  碎 28  时 01:23 ↗"`
# (2 空格分隔, 7 字段 5 + 1 tip), 视觉上 "字段拥挤 + 强调不明显". T235 改成
# `"Run #3 · 房 4 · 净 12 · 碎 28 · 时 01:23 ↗"` (4 个 ` · ` 中点分隔符), 与
# ProfileQuickStats 4 段 (`unlocked_count · best_time_str · longest_room_str · run_number`)
# + ProfileAudit 4 字段 (`ok · 损坏 · 漂移 · 空`) 中点分隔风格 100% 一致, 玩家
# 跨面板视觉组连贯. 1 个 const `_RECENT_ROW_FIELD_SEP := "  ·  "` (2 空格 + 中点
# + 2 空格 = 5 字符 inline, 7pt 字号下 ≈ 6-7 px / 分隔符, 4 分隔符共 ~25 px, 5 行
# 总宽 ≈ 180-200 px 完全在 ProfileRecentList ScrollContainer 容器宽内 0 layout 抖动).
# T234 (#153) 末位 `_RECENT_ROW_TIP_INDICATOR = " ↗"` 保留, 0 字符冲突 (T235
# 仅改 5 字段间分隔符, 末尾 ↗ 字符 literal 0 改); T215 (#136) font_color 提亮
# + T231 (#151) alpha +0.1 boost hover 时同步作用整行 (含 ↗ 与 4 个 · 字符),
# 0 单独 indicator handler, 0 复杂度, 0 副作用, 0 性能影响.
const _RECENT_ROW_FIELD_SEP := "  ·  "

# === 成就图标网格 ===

func _build_achievement_grid() -> void:
	# T109 — 按解锁时间排序：先建所有节点，最后按解锁时间戳
	# 重排顺序（早解锁靠左 → 晚解锁靠右）。未解锁的成就保留
	# 在末尾，按 id 字母序保持稳定。
	var all: Array = PlayerStats.get_all_achievements()
	var unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	var unlocked_ids: Array = []
	for row in unlocked:
		unlocked_ids.append(row[0])
	var locked: Array = []
	for ach in all:
		var id_val: String = ach.get("id", "")
		if id_val == "":
			continue
		if not unlocked_ids.has(id_val):
			locked.append(ach)
	locked.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	var ordered: Array = unlocked.duplicate()  # [id, title, desc, ts]
	for ach in locked:
		ordered.append([ach.get("id", ""), ach.get("title_zh", ach.get("id", "")), ach.get("description_zh", ""), 0])

	# Create a TextureRect for each achievement, in time-sorted order
	for row in ordered:
		var id_val: String = row[0]
		var title_zh: String = row[1]
		var desc_zh: String = row[2]
		var ts: int = int(row[3])
		# Find the original definition to get the icon_hint
		var hint: String = ICON_DEFAULT
		for ach in all:
			if ach.get("id", "") == id_val:
				hint = ach.get("icon_hint", ICON_DEFAULT)
				break
		var tex := _load_icon_texture(hint)
		var slot := TextureRect.new()
		slot.custom_minimum_size = Vector2(16, 16)
		slot.texture = tex
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# T109 — tooltip 加解锁时间："解锁于 MM-DD HH:MM"（未解锁显示 "-"）
		var ts_str := "—"
		if ts > 0:
			var dt := Time.get_datetime_dict_from_unix_time(ts)
			ts_str = "%02d-%02d %02d:%02d" % [dt.month, dt.day, dt.hour, dt.minute]
		# T250 (#168) — 6 verb 关联成就 (echo_icon / wave_icon /
		# whisper_icon 3 icon_hint) slot tooltip 扩展 3 行 → 8 行
		# (追加 "6 verb 视觉组" 段: header + verb 序号 + 主色 hex + 主色名 +
		# 几何 + 视觉组连贯短句). 11 个非 6 verb 关联 slot 走 _build_verb_achievement_tooltip
		# 内部 has() guard 100% 兼容 (返回 base_tooltip 原样, T109 #60
		# 既有 3 行 0 改 0 回归). 调用顺序: 先拼 T109 base_tooltip, 再走
		# T250 扩展器 — 单一职责拆分, 11 slot 0 触碰 3 slot 升级.
		var base_tooltip := "%s  %s\n解锁于 %s" % [title_zh, desc_zh, ts_str]
		slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint)
		slot.name = "AchvSlot_" + id_val
		# T111 — hover 高亮支持：mouse_filter STOP + mouse_entered / mouse_exited signal。
		# TextureRect 默认 mouse_filter = IGNORE，hover 不会触发。设为 STOP 让 Control
		# 接收鼠标进入/离开事件。_on_slot_hover_in / _on_slot_hover_out 做放大 1.5x +
		# 暖色边框 tween，过渡 0.12s。
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.mouse_entered.connect(_on_slot_hover_in.bind(slot))
		slot.mouse_exited.connect(_on_slot_hover_out.bind(slot))
		_achv_grid.add_child(slot)

func _on_slot_hover_in(slot: TextureRect) -> void:
	# T111 — 放大 1.5x (16→24) + Pale Resonance 高亮 + 1px Amber Voice 暖边描边
	# (用 modulate.a 0.95 + self_modulate 实现「亮起来」效果，原 modulate 控制解锁
	# 灰阶)。tween 0.12s quad-ease-out 让过渡丝滑不突兀。
	# T226 (#147) — +1 灰阶预览. 现有 modulate tween 终点 alpha 改为 base + 0.1
	# (clamp 1.0). unlocked slot 1.0 + 0.1 = 1.0 不变 (clamp); locked slot
	# 0.5/0.2 + 0.1 = 0.6/0.3 "微微亮一阶" 暗示可点查看 tooltip. _slot_hover
	# _alpha_base[slot] 在 _refresh_achievement_grid 末尾存每个 slot base alpha
	# (unlocked=1.0, locked=lerp(0.5,0.2,progress)). default 1.0 (defensive:
	# _refresh 之前 _on_slot_hover_in 0 越界读 dict fallback).
	if not is_instance_valid(slot):
		return
	var base_alpha: float = 1.0
	if _slot_hover_alpha_base.has(slot):
		base_alpha = _slot_hover_alpha_base[slot]
	var boosted_alpha: float = clampf(base_alpha + _SLOT_HOVER_BRIGHT_ALPHA_BOOST, 0.0, 1.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slot, "scale", Vector2(1.5, 1.5), _SLOT_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot, "self_modulate", Color(1.4, 1.4, 1.4, 1.0), _SLOT_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# T226 (#147) — modulate RGB 暖色 (T111) + alpha 提升 +0.1 (T226 + 灰阶预览)
	tween.tween_property(slot, "modulate", Color(1.2, 1.1, 0.9, boosted_alpha), _SLOT_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_slot_hover_out(slot: TextureRect) -> void:
	# T111 — 恢复：根据解锁状态回写 modulate / self_modulate
	# T226 (#147) — locked slot 恢复 base alpha (lerp 0.5→0.2, 跟随解锁进度),
	# 替换 T111 旧版 hardcoded alpha 0.5. unlocked slot alpha 仍是 1.0.
	if not is_instance_valid(slot):
		return
	var base_alpha: float = 1.0
	if _slot_hover_alpha_base.has(slot):
		base_alpha = _slot_hover_alpha_base[slot]
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slot, "scale", Vector2(1.0, 1.0), _SLOT_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 恢复逻辑：未解锁用淡灰调 (0.25, 0.25, 0.3, base_alpha lerp)，已解锁用纯白
	var id_val: String = slot.name.substr(9)  # strip "AchvSlot_"
	if PlayerStats.is_unlocked(id_val):
		tween.tween_property(slot, "self_modulate", Color.WHITE, _SLOT_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(slot, "modulate", Color.WHITE, _SLOT_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		# T226 (#147) — locked slot 恢复 base alpha (lerp 0.5→0.2 跟随解锁进度)
		var locked_color: Color = Color(_ACHV_LOCKED_COLOR_RGB.r, _ACHV_LOCKED_COLOR_RGB.g, _ACHV_LOCKED_COLOR_RGB.b, base_alpha)
		tween.tween_property(slot, "self_modulate", locked_color, _SLOT_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(slot, "modulate", locked_color, _SLOT_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _refresh_achievement_grid() -> void:
	# T222 (#144) — 解锁进度联动 alpha. 14 成就 unlocked/total
	# 比例 0..1 映射到 _ACHV_LOCKED_ALPHA_START..END 线性插值.
	# 0 解锁 = 0.5 满 alpha, 14 解锁 = 0.2 最低 alpha, 中间按
	# progress 插值. 玩家推进时 locked slots 视觉上"退场", 已
	# 解锁的 14 成就 占视觉组主焦点.
	var unlocked_count: int = PlayerStats.get_unlocked_count()
	var total_count: int = PlayerStats.get_total_count()
	var progress: float = 0.0
	if total_count > 0:
		progress = float(unlocked_count) / float(total_count)
	var locked_alpha: float = lerp(_ACHV_LOCKED_ALPHA_START, _ACHV_LOCKED_ALPHA_END, progress)
	var locked_color: Color = Color(_ACHV_LOCKED_COLOR_RGB.r, _ACHV_LOCKED_COLOR_RGB.g, _ACHV_LOCKED_COLOR_RGB.b, locked_alpha)
	for child in _achv_grid.get_children():
		if not child.name.begins_with("AchvSlot_"):
			continue
		var id_val: String = child.name.substr(9)  # strip "AchvSlot_"
		if PlayerStats.is_unlocked(id_val):
			child.modulate = Color.WHITE
			child.self_modulate = Color.WHITE
			# T226 (#147) — unlocked slot base alpha 1.0 (modulate WHITE)
			_slot_hover_alpha_base[child] = 1.0
		else:
			child.modulate = locked_color
			child.self_modulate = locked_color
			# T226 (#147) — locked slot base alpha = locked_alpha (lerp 跟随解锁进度)
			_slot_hover_alpha_base[child] = locked_alpha

func _load_icon_texture(icon_hint: String) -> Texture2D:
	var path := "%s/%s/%s.png" % [ICON_PATH_BASE, icon_hint, icon_hint]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

# T250 (#168) — 6 verb 关联成就 slot tooltip 扩展生成器. 输入:
# base_tooltip = T109 (#60) 既有 3 行 "title + desc + 解锁时间"
# tooltip (11 个非 6 verb 关联 slot 100% 兼容, 0 触碰 0 回归);
# icon_hint = 14 slot 中某一个的 icon_hint. 输出: 如果 icon_hint
# 在 _VERB_ACHV_ICON_HINTS (echo_icon / wave_icon / whisper_icon 3 个
# 6 verb 关联 icon_hint), 返回 base_tooltip + "\n\n" + 4 行 "6 verb
# 视觉组连贯" 段 (header "6 verb 视觉组" + 1 行 verb 序号 + 主色 +
# 1 行 几何 + 1 行 视觉组连贯短句) = 3 + 5 = 8 行 tooltip; 否则
# 返回 base_tooltip 原样 (11 个非 6 verb 关联 slot 0 触碰 0 回归).
# 走纯文本 (BBCode 0 走 tooltip 路径, 与 T199 / T213 / T216 / T249
# tooltip 模式完全同源), Godot 4.6 自带 tooltip 渲染器 5s timeout
# 8 行完全可读, 玩家 hover 充分吸收 6 verb 调色 + 6 verb 几何 +
# 视觉组连贯 3 维信息. 0 副作用: base_tooltip 0 改 (T109 #60 既有
# 3 行 100% 兼容); 输出文本仅追加 5 行, 0 BBCode 渲染复杂度, 0
# theme override 优先级冲突 (T249 #167 0 BBCode 路径 0 触碰); 0
# 性能变化 (string concat O(n) 单次 slot 创建时, 14 slot × 1 次 = 14 次
# 触发频次 0 在 per-frame, 玩家触发频次由打开 PauseMenu 决定).
func _build_verb_achievement_tooltip(base_tooltip: String, icon_hint: String) -> String:
	if not _VERB_ACHV_ICON_HINTS.has(icon_hint):
		return base_tooltip
	if not _VERB_ACHV_INFO.has(icon_hint):
		return base_tooltip
	var info: Dictionary = _VERB_ACHV_INFO[icon_hint]
	var extra_lines: Array[String] = []
	extra_lines.append("")  # blank line for tooltip 段分隔 (Godot 4.6 tooltip 渲染保留空行间距)
	extra_lines.append("6 verb 视觉组")
	extra_lines.append("• 第 %d verb · %s  %s" % [
		int(info["verb_index"]),
		String(info["color"]),
		String(info["color_name"]),
	])
	extra_lines.append("• 几何 — %s" % String(info["geometry_zh"]))
	extra_lines.append("• 视觉组 — %s" % String(info["visual_group"]))
	return base_tooltip + "\n".join(extra_lines)

func _on_resume() -> void:
	toggle_pause()
	resume_pressed.emit()

func _on_save() -> void:
	# T070 — open SaveLoadMenu in save-mode (write only).
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
		return
	_save_load_menu.mode = "save"
	_save_load_menu.refresh()
	_save_load_menu.show_menu()

func _on_save_load_saved(slot_id: int) -> void:
	# SaveSystem writes the snapshot; GFC shows a brief toast.
	# We forward the slot id up via save_requested signal so GFC can
	# call SaveSystem.save_to_slot() and show the HUD hint.
	save_requested.emit(slot_id)
	_save_load_menu.refresh()  # refresh so overwrite button text updates

func _on_save_load_deleted(slot_id: int) -> void:
	SaveSystem.delete_slot(slot_id)
	_save_load_menu.refresh()

func _on_save_load_loaded(_slot_id: int) -> void:
	# PauseMenu's SaveLoadMenu is in save mode, load button is disabled.
	# Defensive: just close the menu if a load was somehow triggered.
	_save_load_menu.hide_menu()

func _on_settings() -> void:
	settings_pressed.emit()

func _on_restart() -> void:
	# Close SaveLoadMenu before quitting
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
	get_tree().paused = false
	_is_paused = false
	restart_pressed.emit()

func _on_quit_to_title() -> void:
	# Close SaveLoadMenu before quitting
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
	get_tree().paused = false
	_is_paused = false
	quit_to_title_pressed.emit()

# === T126 — Player Profile page ===
#
# Modal panel opened via the new "玩家档案" button (or any equivalent
# entry point).  Showcased data: player name (placeholder), run time,
# room count, death count, shard count, 4-verb colorized usage, and a
# scrollable list of all 8+ achievements with full text + unlock time.
# The panel is independent of the small StatsPanel sidebar so the
# sidebar remains a glanceable summary.

func _on_profile() -> void:
	# Toggle the profile panel; if it's already open, just close.
	if _profile_open:
		_on_profile_close()
		return
	# Close SaveLoadMenu if it's open (no two modals at once).
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
	_refresh_profile()
	_profile_panel.visible = true
	_profile_open = true

func _on_profile_close() -> void:
	_profile_panel.visible = false
	_profile_open = false

# T135 — Share button handler.  Reads the live Quick Stats
# fields (achievements / best time / run #) and writes a
# one-line plain-text summary to the system clipboard.
# DisplayServer.clipboard_set returns void; we don't try
# to confirm the write because the OS clipboard is opaque
# (and the player will paste somewhere visible to verify).
# On success, flash the button label to "已复制 ✓" for 1.5s
# so the player gets visual confirmation.  On failure
# (extremely rare — DisplayServer unavailable in headless
# or some Linux compositors), flash "复制失败" instead.
# Either way the label restores after 1.5s; pressing the
# button again before the restore just restarts the timer.
func _on_share_pressed() -> void:
	if _profile_share_btn == null:
		return
	var text: String = _format_share_text()
	# DisplayServer may be absent in some headless test setups;
	# guard with has_method so a unit test that instantiates
	# the panel directly doesn't crash on a missing singleton.
	var ok: bool = false
	if DisplayServer.has_method("clipboard_set"):
		DisplayServer.clipboard_set(text)
		ok = true
	var original_text: String = "分享到剪贴板"
	if _profile_share_btn.text != original_text:
		# Stash the original only on the first press; subsequent
		# presses keep whatever the original was before the
		# "已复制 ✓" overwrite.  This avoids the case where
		# a slow restore timer overwrites the stashed "已复制 ✓"
		# with itself instead of the canonical label.
		original_text = _profile_share_btn.text
	_profile_share_btn.text = "已复制 ✓" if ok else "复制失败"
	# Kill any in-flight timer so a quick second click doesn't
	# race against the previous 1.5s restore callback.
	var t := get_tree().create_timer(1.5)
	t.timeout.connect(func() -> void:
		if _profile_share_btn != null and is_instance_valid(_profile_share_btn):
			_profile_share_btn.text = original_text
	)

# Build the plain-text share summary.  Kept in plain text
# (no BBCode) so it pastes correctly into Twitter / Discord /
# Reddit / Steam chat / clipboard-aware friends.  Format:
#
#   🎵 Voxglass
#   成就 3 / 14  ·  最佳 04:32  ·  Run #7
#   2026-06-08
#
# The 🎵 glyph is a single emoji as a Voxglass visual hook;
# players on platforms that strip emoji still get a clean
# three-line summary.  We use ASCII dot (·) instead of • so
# the line is unambiguous across encodings.
func _format_share_text() -> String:
	var unlocked_count: int = PlayerStats.get_unlocked_count()
	var total_count: int = PlayerStats.get_total_count()
	var best: Dictionary = PlayerStats.get_best_stats()
	var best_time: float = float(best.get("longest_run_seconds", 0.0))
	var best_str: String
	if best_time > 0.0:
		var bm: int = int(best_time) / 60
		var bs: int = int(best_time) % 60
		best_str = "%02d:%02d" % [bm, bs]
	else:
		best_str = "—"
	var run_number: int = PlayerStats.get_run_number()
	# Build a YYYY-MM-DD stamp from local time so the share
	# reflects "when the player copied this" not "when the
	# save was made" (those can differ by hours).
	var dt := Time.get_datetime_dict_from_system()
	var date_str: String = "%04d-%02d-%02d" % [int(dt["year"]), int(dt["month"]), int(dt["day"])]
	return "🎵 Voxglass\n成就 %d / %d  ·  最佳 %s  ·  Run #%d\n%s" % [
		unlocked_count, total_count, best_str, run_number, date_str
	]

func _refresh_profile() -> void:
	# T127 — Run 编号（1-based；首次启动为 1，每次 reset_run 后 +1）。
	# 玩家看到"这是我的第 N 个 run"是一种 metaprogression 反馈。
	_profile_run.text = "Run #%d" % PlayerStats.get_run_number()
	# T133/T139 — Quick Stats 摘要行（achievements X/14 · 最佳回响 · Run #N）。
	# 设计为 BBCode 形式：3 个数据点都跨场景共享（成就=跨会话解锁 / 最佳=
	# 跨 run 持久化 / Run 编号=会话内），所以是"我的 Voxglass 生涯"的一行总览。
	# Amber Voice 暖色 + 9pt 比上下两行（Run # 8pt / 第一节统计 9pt）更显眼，作为
	# "header subtitle" 出现在标题与详细数据之间。首次启动时最佳 = "—" 占位
	# 与下方历史最佳块一致；零成就时仍显示 "成就 0 / 14" 表明进度条尚未启动。
	# T139 — 14 是动态值（`PlayerStats.get_total_count()`），不再硬编码 ——
	# #74 轮新增 quintuple_voice 成就后从 13 跳到 14；未来加成就只改 achievements.json。
	var unlocked_count: int = PlayerStats.get_unlocked_count()
	var total_count: int = PlayerStats.get_total_count()
	# Avoid shadowing the `best` dict used by the T127 historical-best
	# block further down in this function.  Read fresh into a
	# local; cheap call, no semantic dependence.
	var quick_best: Dictionary = PlayerStats.get_best_stats()
	var quick_best_time: float = float(quick_best.get("longest_run_seconds", 0.0))
	var best_time_str: String
	if quick_best_time > 0.0:
		var qbm: int = int(quick_best_time) / 60
		var qbs: int = int(quick_best_time) % 60
		best_time_str = "%02d:%02d" % [qbm, qbs]
	else:
		best_time_str = "—"
	# T210 (#129) — 在 QuickStats 顶级 summary 行加 "最长单房" 缩略 (T209
	# top row 数据源 `_best_stats["longest_room_seconds"]` 缩略版). 之前
	# QuickStats 行只有 "成就 / 最佳回响 / Run #" 3 段, 玩家点开 PauseMenu
	# 顶部第一秒看到的是 1 行总览, 缺 "我卡得最久的一房" 这个回忆锚点.
	# 现在 4 段聚合: 成就 N/N (Glass Cyan) + 最佳回响 mm:ss (Amber Voice)
	# + 最长单房 mm:ss (Muted Violet, 与 top row 3 块 Glass Cyan 区分 — top
	# row 是 3 块全 Glass Cyan 表达 "聚合", QuickStats 是 4 段 4 色表达
	# "总览") + Run # (Pale Resonance). n=0 (无 longest room 记录) →
	# "—" 占位, 与 QuickStats 最佳回响 / 顶级行 AvgResonance/BestStreak/
	# LongestRoom 4 处占位风格完全一致. mm:ss 格式与 _profile_best_streak
	# / _profile_longest_room 完全同款 (`"%02d:%02d"`), 玩家读 4 段时间
	# 数字时不会因格式差异跳戏.
	#
	# 设计 rationale (polish 边际效用递增): T133 (#60) 落地 ProfileQuickStats
	# 1 行总览让玩家打开 PauseMenu 0.5s 即知 "我是谁" 代替逐行读 trend/recent
	# 推断. T201 (#117) 加 AvgResonance + BestStreak 顶级行 2 块, T209 (#128)
	# 加 LongestRoom 顶级行第 3 块. T210 (#129) 把 LongestRoom 同步进
	# QuickStats 让 "4 段总览" 完整 = 玩家 1 眼看到成就 + 整局最佳 + 单房
	# 最佳 + 当前 run #, 4 维聚合不用 scroll 看到 trend/recent. 与 LongestRoom
	# top row 0 重复 (top row 是 9pt 居中独立行, QuickStats 是 1 行内联).
	var quick_longest_room: float = float(quick_best.get("longest_room_seconds", 0.0))
	var longest_room_str: String
	if quick_longest_room > 0.0:
		var qlm: int = int(quick_longest_room) / 60
		var qls: int = int(quick_longest_room) % 60
		longest_room_str = "%02d:%02d" % [qlm, qls]
	else:
		longest_room_str = "—"
	# T217 (#138) — 拆 1 Label 4 BBCode 段 → 4 sub-Label. 旧版 T214
	# 时期 1 Label 4 BBCode 段 1 行显示, 现在拆 4 sub-Label 各 1 段
	# (HBoxContainer 居中, 3 sep 静态 Label + 2 star 静态 Label 间隔).
	# 4 sub-Label 颜色通过 theme_override_colors/font_color 单独设
	# (tscn 1:1 对应 STYLE_GUIDE 4 段 4 色 — Glass Cyan / Amber Voice
	# / Muted Violet / Pale Resonance, T210 literal 颜色 token 严格保留).
	# 4 sub-Label 文本独立 set, 不再 1 BBCode 字符串拼接 (T210 #129 4 段
	# 1 BBCode 写法废弃, 但 4 段数据源 (unlocked_count/total_count/
	# best_time_str/longest_room_str/PlayerStats.get_run_number())
	# 完全保留, 玩家 1 眼看到 4 段聚合不变).
	if _quick_stats_achievement:
		_quick_stats_achievement.text = "成就 %d / %d" % [unlocked_count, total_count]
	if _quick_stats_best_time:
		_quick_stats_best_time.text = "最佳 %s" % best_time_str
	if _quick_stats_longest_room:
		_quick_stats_longest_room.text = "最长单房 %s" % longest_room_str
	if _quick_stats_run_number:
		_quick_stats_run_number.text = "Run #%d" % PlayerStats.get_run_number()
	# T217 (#138) — 重新 apply hover 状态. 4 sub-Label text setter 不触
	# 发 mouse_entered/exited (set text 是属性赋值, 0 鼠标事件), 所以
	# _quick_stats_hovered_idx 字段不变. _apply_quick_stats_hover_state()
	# 重算 4 sub-Label modulate: 玩家 _refresh 时正在 hover 段要保持高亮
	# (modulate Color.WHITE), 其他段从 _refresh 重置后 dim 不能丢
	# (modulate _QUICK_STATS_DIM). T214 (#134) 旧版 _quick_stats_default_text
	# 字符串缓存废弃 (modulate 4 字段独立管理, 不需要 default 字符串).
	_apply_quick_stats_hover_state()
	var t := int(PlayerStats.get_run_time_seconds())
	var m := t / 60
	var s := t % 60
	_profile_time.text = "回响时长  %02d:%02d" % [m, s]
	# T152 (#79) — 玩家档案 stat 行同样 0 数灰阶占位。回响时长不
	# 应用（与 QuickStatsPanel 理由一致：0:00 是合法"刚开始"）。
	_set_zero_aware_stat(_profile_deaths, PlayerStats.deaths, "共鸣消散  %d")
	_set_zero_aware_stat(_profile_rooms, PlayerStats.rooms_cleared, "完成房间  %d")
	# T102/T103 — 五动词 BBCode 颜色主题化（与 _stat_abilities 一致）
	# F013.E (#159) — 第六动词 Whisper 加 6 verb row (与 _stat_abilities 同).
	_profile_abilities.text = "[color=#E86D5A]Pulse %d[/color]  ·  [color=#65506A]Bind %d[/color]  ·  [color=#F2B66E]Cut %d[/color]  ·  [color=#69C7CE]Echo %d[/color]  ·  [color=#B7E6DC]Wave %d[/color]  ·  [color=#C8A4D8]Whisper %d[/color]" % [
		PlayerStats.pulse_used, PlayerStats.bind_used,
		PlayerStats.cut_used, PlayerStats.echo_used,
		PlayerStats.wave_used, PlayerStats.whisper_used
	]
	_set_zero_aware_stat(_profile_shards, PlayerStats.shards_collected, "收集碎片  %d")
	# T152 — Echo 反弹行：>0 → 暖白 + 数字；0 → 暖灰 + "—"（档案面板
	# 没用 T100 的 Glass Cyan 强调，所以这里只走标准 zero-aware 路径）
	_set_zero_aware_stat(_profile_reflects, PlayerStats.echo_reflects, "Echo 反弹  %d")
	# T150 — 上次使用 verb（5 动词 BBCode 调色板对齐）。把 record_ability_used
	# 写入的英文 id 映射为 BBCode 形式：Pulse #E86D5A / Bind #65506A /
	# Cut #F2B66E / Echo #69C7CE / Wave #B7E6DC，色块与 _profile_abilities
	# 完全一致（"5 动词色域"贯穿 HUD / Pause / Profile / 命中闪 6 个表层）。
	# F013.E (#159) — 第六分支 "whisper" 加 match (Muted Mauve #C8A4D8).
	# 空字符串 = 本 run 还没用过任何 verb（reset_stats 之后立即打开
	# 暂停），显示 "—" 占位让"未使用"状态明确可读。
	if _profile_last_verb:
		var last_verb: String = PlayerStats.get_last_used_verb()
		match last_verb:
			"pulse":
				_profile_last_verb.text = "上次使用：[color=#E86D5A]Pulse[/color]"
			"bind":
				_profile_last_verb.text = "上次使用：[color=#65506A]Bind[/color]"
			"cut":
				_profile_last_verb.text = "上次使用：[color=#F2B66E]Cut[/color]"
			"echo":
				_profile_last_verb.text = "上次使用：[color=#69C7CE]Echo[/color]"
			"wave":
				_profile_last_verb.text = "上次使用：[color=#B7E6DC]Wave[/color]"
			# F013.E (#159) — 第六 verb whisper 分支, 色 #C8A4D8.
			"whisper":
				_profile_last_verb.text = "上次使用：[color=#C8A4D8]Whisper[/color]"
			_:
				_profile_last_verb.text = "上次使用：—"
	# T127 — 历史最佳 4 行（持久化跨 run；首次启动全 0 → 显示 "—"）。
	# 视觉组：4 行用暖白 + 8pt 小字，与上方当前 run 状态形成对比。
	# 「—」占位让"还没创造记录"的状态在 UI 上明确可读。
	var best: Dictionary = PlayerStats.get_best_stats()
	var best_time := float(best.get("longest_run_seconds", 0.0))
	if best_time > 0.0:
		var bm := int(best_time) / 60
		var bs := int(best_time) % 60
		_profile_best_time.text = "最长回响  %02d:%02d" % [bm, bs]
	else:
		_profile_best_time.text = "最长回响  —"
	var best_rooms := int(best.get("most_rooms_cleared", 0))
	_profile_best_rooms.text = "最多房间  %s" % (str(best_rooms) if best_rooms > 0 else "—")
	var best_shards := int(best.get("most_shards_collected", 0))
	_profile_best_shards.text = "最多碎片  %s" % (str(best_shards) if best_shards > 0 else "—")
	var best_enemies := int(best.get("most_enemies_purified", 0))
	_profile_best_enemies.text = "最多净化  %s" % (str(best_enemies) if best_enemies > 0 else "—")
	# T138 — 上次自动存档时间（HH:MM:SS）。如果 SaveSystem autoload
	# 不可用或本会话还没 auto-save 过（_last_autosave_unix == 0），
	# 显示 "—" 占位。0 视为"无数据"（不要当作 1970-01-01 显示）。
	if _profile_auto_save and SaveSystem and SaveSystem.has_method("get_last_autosave_unix"):
		var last_unix: int = int(SaveSystem.get_last_autosave_unix())
		if last_unix > 0:
			var dt := Time.get_datetime_dict_from_unix_time(last_unix)
			_profile_auto_save.text = "上次自动存档  %02d:%02d:%02d" % [dt["hour"], dt["minute"], dt["second"]]
		else:
			_profile_auto_save.text = "上次自动存档  —"
	elif _profile_auto_save:
		_profile_auto_save.text = "上次自动存档  —"
	# T201 (#117) — 跨局聚合 stats 顶级行（2 行）。
	# 用 _run_history 防御性副本（get_run_history() 已 duplicate），
	# 避免外部 mutate 内部状态；空 history → "—" 占位, 避免除
	# 0 与 "n=0 0.0" 这种让玩家误以为 avg=0 的视觉。
	_refresh_top_aggregate_rows()
	# T131 — 近 N 局平均（5/10/20 三档）趋势行。让玩家看到
	# "最近 N 局的平均表现"，与上方"历史最佳"形成对比：
	# 最佳 = 单一极值（峰值），趋势 = 平滑平均（成长线）。
	# 零样本（首次启动）显示 "—"，>=1 样本显示 4 字段平均。
	_refresh_trend_row(_profile_trend5, 5)
	_refresh_trend_row(_profile_trend10, 10)
	_refresh_trend_row(_profile_trend20, 20)
	# T162 (#83) — 最近 N 局详细列表（每局 1 行：Run #N 房 X 净 Y 碎 Z 时 mm:ss）。
	# 与 trend 5/10/20 平均互补：trend 给"宏观"指标，recent 给"具体"哪些 run
	# 特别好/差，玩家点开 pause 看到"上次 Run #5 净 0 死 3"立刻归因到"我那局没
	# 找到 Pulse"。空 history 走"暂无 run 记录"占位（首次启动玩家还没死过）。
	_refresh_recent_runs_list()
	# Refresh achievement list state (new unlocks may have changed).
	_refresh_profile_achievement_list()
	# T229 (#149) — 存档 5 slot 健康状态 1 行. SaveSystem.audit_save_slots 是
	# 公共方法, 内部读 5 slot 各自 .json, 算 ok/corrupted/drift/empty 计数.
	# ProfileAudit 在 ProfileRecentList 后 1 行, 与 ProfileTrend 5/10/20 行
	# 视觉组连贯 (7pt 暖白小字). 玩家打开 PauseMenu 即知"我 5 存档 ok
	# 还是某个 slot 损坏了", 不需要切 TitleScreen 看 Output panel.
	_refresh_profile_audit()

# T229 (#149) — 存档 5 slot 巡检 1 行渲染. 调 SaveSystem.audit_save_slots()
# 公共接口 (返回 Dictionary 含 ok / corrupted / drift / empty / total +
# 4 ids arrays). 渲染策略: 全 ok → 暖白 1 行; 损坏>0 → 暖红强调;
# 漂移>0 → 暖黄; 否则暖白. 7pt 1 行紧凑 "存档 3 ok · 0 损坏 · 0 漂移 · 2 空".
# 防御性: SaveSystem autoload 在 headless / 反序列化失败时可能为 null,
# 守卫 + 显示 "—" 占位避免 NPE. 与 _refresh_top_aggregate_rows 0 重复
# (本函数看存档健康, aggregate 看 run history, 2 个完全独立数据源).
func _refresh_profile_audit() -> void:
	if not _profile_audit:
		return
	if not SaveSystem or not SaveSystem.has_method("audit_save_slots"):
		_profile_audit.text = "存档  —  0  损坏  0  漂移  —  空"
		_profile_audit.add_theme_color_override("font_color", _COLOR_ZERO_STAT)
		return
	var report: Dictionary = SaveSystem.audit_save_slots()
	var ok_n: int = int(report.get("ok", 0))
	var corrupted_n: int = int(report.get("corrupted", 0))
	var drift_n: int = int(report.get("drift", 0))
	var empty_n: int = int(report.get("empty", 0))
	# 1 行紧凑 4 字段 (ok/损坏/漂移/空). 用中点 "·" 与 ProfileQuickStats
	# 4 段 + ProfileRecentList 7 字段行风格完全一致 (玩家视觉组连贯).
	_profile_audit.text = "存档  %d ok  ·  %d 损坏  ·  %d 漂移  ·  %d 空" % [
		ok_n, corrupted_n, drift_n, empty_n
	]
	# 颜色: 损坏>0 暖红 (0.85, 0.45, 0.4) — 玩家必须注意; 漂移>0 暖黄
	# (0.85, 0.71, 0.43) — 警告但非紧急; 全 ok 暖白 (0.875, 0.835, 0.784).
	# 损坏优先级 > 漂移 (损坏 = 文件无法 parse, 漂移 = 文件 ok 但字段缺失).
	var color: Color
	if corrupted_n > 0:
		color = Color(0.85, 0.45, 0.4, 1.0)
	elif drift_n > 0:
		color = Color(0.85, 0.71, 0.43, 1.0)
	else:
		color = Color(0.875, 0.835, 0.784, 1.0)
	_profile_audit.add_theme_color_override("font_color", color)

# T131 — 趋势行格式化。把 4 字段平均 + 样本数压成单行 Label 文本。
# 例："近 5 局   房 1.4  净 3.2  碎 8.1  时 02:35  死 0.4 (n=5)"
# 中文 1-字 key = 紧凑排版。零样本时 "—" 占位。
func _refresh_trend_row(target: Label, n: int) -> void:
	var avg: Dictionary = PlayerStats.get_recent_runs_average(n)
	if avg.is_empty():
		target.text = "近 %d 局   —" % n
		return
	var rooms_avg: float = float(avg.get("rooms_cleared", 0.0))
	var enemies_avg: float = float(avg.get("enemies_purified", 0.0))
	var shards_avg: float = float(avg.get("shards_collected", 0.0))
	var deaths_avg: float = float(avg.get("deaths", 0.0))
	var time_avg: float = float(avg.get("run_time_seconds", 0.0))
	var tm: int = int(time_avg) / 60
	var ts: int = int(time_avg) % 60
	var sample_count: int = int(avg.get("sample_count", 0))
	# 一位小数（统计面板需要 7pt 小字可读）；0 显示 "0" 而非 ".0"
	var rooms_str: String = ("%.1f" % rooms_avg) if rooms_avg > 0.0 else "0"
	var enemies_str: String = ("%.1f" % enemies_avg) if enemies_avg > 0.0 else "0"
	var shards_str: String = ("%.1f" % shards_avg) if shards_avg > 0.0 else "0"
	var deaths_str: String = ("%.1f" % deaths_avg) if deaths_avg > 0.0 else "0"
	target.text = "近 %d 局   房 %s  净 %s  碎 %s  死 %s  时 %02d:%02d  (n=%d)" % [
		n, rooms_str, enemies_str, shards_str, deaths_str, tm, ts, sample_count
	]

# T162 (#83) — 最近 N 局详细行：每局 1 行紧凑展示（Run #N 房 X 净 Y 碎 Z 时 mm:ss）。
# 与 _refresh_trend_row 不同：trend 给"平均 / 趋势"宏观指标；recent 给"具体每一局"
# 的可读明细，玩家点开 pause 看到"Run #5 净 0 死 3"立刻归因到"我那局没找到 Pulse"
# ——"每一局值多少钱"的具象数据。
#
# 设计选择：
# ① **最近 1 局用 Amber Voice 高亮**（暖色）— "上一次 run"是玩家最关心的指标，
#    视觉上"上一次我玩了什么"是心理锚点；其余 N-1 局用 Pale Resonance（与 trend 行
#    一致保持视觉组连贯）。
# ② **数据按 reversed order 显示**（最新在顶）— 与"share 复制的是最新 run"语义一致。
# ③ **每行 5 字段** (Run # / 房 / 净 / 碎 / 时) — 死亡字段省去（trend 已有平均），
#    让单行字符控制在 ~30 个内（7pt 小字、480px 宽容器约 60 字符）保持可读。
# ③.T216 (#137) **每行 5 字段 hover tooltip 绑定** — 5 行都用同一
#    _build_recent_row_tooltip() (const 权威 _RECENT_ROW_HINT 渲染)
#    给玩家悬停即弹 5 字段含义. 字段含义对 5 行都相同 (每行都
#    显示 5 字段), 5 行复用同一 tooltip 0 差异. 与 T215 静态高亮层
#    (悬停整行提亮) 互补: T215 给"鼠标在哪一行" 视觉, T216 给
#    "5 字段含义" 静态信息. 玩家不悬停 = 1 行 5 字段 7pt 小字
#    够区分, 不强制提示; 玩家悬停 = tooltip 弹出 5 字段含义,
#    5s timeout 自动消失.
# ④ **空 history 走"暂无 run 记录"占位** — 首次启动玩家还没死过，UI 明确"无数据"
#    比显示"Run #0  房 0  净 0"误导更友好。
# ⑤ **dynamic child creation** — ProfileRecentList 在 _ready 时为空，每次
#    _refresh_recent_runs_list 调用清空旧 child 后重建（防 stale data + 与
#    _refresh_profile_achievement_list 同模式）。
# ⑥.T219 (#141) **5 行 alpha 渐变** (1.0 / 0.875 / 0.75 / 0.625 / 0.5) —
#    5 行整体透明度按 i 线性插值, 最新 (i==0) 满亮, 最旧 (i==4) 半暗.
#    让"上一局"在视觉上最突出 (玩家最关注), 历史 4 局退到背景层避免
#    抢焦点. modulate.a 透明度 与 font_color 无关, 0 冲突 T215 hover
#    (改 font_color 不改 modulate.a). 7 字段 tooltip (T216 hint 5 → 7
#    扩展: Run #/房/净/碎/时 + 房/时 + 净/时) 由 _build_recent_row_
#    tooltip 自动遍历 _RECENT_ROW_HINT 渲染, 函数本体 0 改.
func _refresh_recent_runs_list() -> void:
	if not _profile_recent_list:
		return
	# 5a — 清空旧 child（防 stale data，每次 _refresh_profile 都重建）
	for child in _profile_recent_list.get_children():
		child.queue_free()
	_profile_recent_list.get_children().clear()  # defensive double-clear
	# T215 (#136) — 重置 hover 状态数组：每次 _refresh 都重建 5 行 → 数组 resize 到新长度。
	# _recent_row_hovered 是 5 行独立的 bool flag（防止 re-entrant trigger），
	# _recent_row_default_color 保存每行还原色（避免 hover_out 错把高亮版当 default 写回）。
	# 0 跨行联动 — 数组 index = row index，与 _profile_recent_list.get_child(i) 1:1 对齐。
	_recent_row_hovered.clear()
	_recent_row_default_color.clear()
	# T231 (#151) — 重置 _recent_row_hover_alpha_base 字典：每次 _refresh 重建 5 行
	# → 旧 dict 元素被覆盖前先 clear 防 stale entry 残留 (与 _recent_row_hovered /
	# _recent_row_default_color 同模式). 0 跨行联动 — 字典 key = row index,
	# 与 _profile_recent_list.get_child(i) 1:1 对齐.
	_recent_row_hover_alpha_base.clear()
	# 5b — 拉最近 N 局（FIFO 数组，索引 0 = 最旧，最后 = 最新；reverse 让最新在顶）
	var recent: Array = PlayerStats.get_recent_runs(_PROFILE_RECENT_RUNS_MAX)
	if recent.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "暂无 run 记录"
		empty_lbl.add_theme_font_size_override("font_size", 7)
		empty_lbl.add_theme_color_override("font_color", _COLOR_ZERO_STAT)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_profile_recent_list.add_child(empty_lbl)
		# T215 (#136) — 空 history 路径也保持 _recent_row_hovered 与 _recent_row_default_color
		# 同长度（虽然只有 1 个空 row 不参与 hover，但数组对齐让下游 hover handler 越界检查 O(1)）。
		# 实际上空 row 不 connect mouse signal，所以不需要默认色记录，0 副作用扩散。
		return
	# Reverse to show newest first (defensive copy via get_recent_runs)
	var reversed_runs: Array = recent.duplicate()
	reversed_runs.reverse()
	for i in range(reversed_runs.size()):
		var run: Dictionary = reversed_runs[i]
		var run_n: int = int(run.get("run_number", 0))
		var rooms: int = int(run.get("rooms_cleared", 0))
		var enemies: int = int(run.get("enemies_purified", 0))
		var shards: int = int(run.get("shards_collected", 0))
		var t_sec: float = float(run.get("run_time_seconds", 0.0))
		var tm: int = int(t_sec) / 60
		var ts: int = int(t_sec) % 60
		# T249 (#167) — 派生率 (房/时, 净/时) 算自原 5 字段. 玩家本 run
		# 房间/分钟 + 敌/分钟 (rounded) = 推进节奏 + 战斗节奏. 与 T216
		# (#137) _RECENT_ROW_HINT 7 字段 tooltip (Run #/房/净/碎/时 + 房/时
		# + 净/时) 字段顺序保持一致: tooltip 7 字段 顺序 = row 7 字段顺序
		# (玩家悬停 tooltip 看到什么字段顺序, row 文本就是什么顺序, 跨层
		# 视觉组连贯). 防御: t_sec == 0 (玩家 0 时长就死亡) → 派生率 0
		# (避免 0/0 = nan, 与 trend 行 0 样本 "—" 占位策略一致 — 0 数值
		# 占位比 "—" 字符在 row 文本 inline 更紧凑 7pt 字号下不显示意义
		# 模糊). 与 _RECENT_ROW_FIELD_SEP 4 中点分隔符扩展到 6 中点 (7
		# 字段 = 6 间隔), 与 ProfileQuickStats 4 段 + ProfileAudit 4 字段
		# 行 100% 视觉组连贯 (跨面板 7pt 小字 + middle-dot 分隔).
		var rooms_per_minute: int = 0
		var enemies_per_minute: int = 0
		if t_sec > 0.0:
			rooms_per_minute = int(round(float(rooms) / (t_sec / 60.0)))
			enemies_per_minute = int(round(float(enemies) / (t_sec / 60.0)))
		# 5c — build row label
		var row_lbl: Label = Label.new()
		# T234 (#153) — row 文本末尾追加 _RECENT_ROW_TIP_INDICATOR (" ↗")
		# 永远 visible 提示玩家"行末有 tooltip, 悬停查看 7 字段完整含义
		# (含 房/时 + 净/时 2 个派生率)". 原 5 字段 format 0 改, 1 字符
		# 追加. T215 (#136) font_color 提亮 + T231 (#151) alpha +0.1 boost
		# hover 时同步作用整行 (含 "↗" 字符), 0 单独 indicator handler
		# (0 复杂度, 0 副作用, 0 性能影响). 1 个字符 + 1 个空格 = 2 char
		# inline, 7pt 字号下 ≈ 4-5 px, 5 行均 < 240px, 完全在 ProfileRecentList
		# ScrollContainer 容器宽内 (0 layout 抖动).
		#
		# T235 (#154) — 5 字段间分隔用 _RECENT_ROW_FIELD_SEP ("  ·  ")
		# middle-dot 视觉细化, 与 ProfileQuickStats 4 段 + ProfileAudit
		# 4 字段行风格 100% 一致, 玩家跨面板视觉组连贯. format 字符串
		# 4 个 %s placeholder 拼成 4 个 `  ·  ` 中点分隔符 (Run # / 房 / 净
		# / 碎 / 时), T234 末尾 `↗` literal 0 改, T215+T231 hover 反馈
		# 0 触碰 (5 字段 + 4 分隔符 + 1 tip indicator = 10 tokens inline).
		#
		# T249 (#167) — 5 字段 → 7 字段扩展: 加 "房/时 X  ·  净/时 X"
		# 2 派生率 inline 拼接, 6 中点分隔符 (5 字段 4 间隔 + 2 派生率 2
		# 间隔 = 6 间隔), 7 字段 + 6 分隔符 + 1 tip indicator = 14 tokens.
		# 7 字段顺序与 _RECENT_ROW_HINT tooltip 100% 对齐: Run # → 房 →
		# 净 → 碎 → 时 → 房/时 → 净/时 (玩家 hover 弹 tooltip 看 7 字段
		# 顺序, row 文本 7 字段顺序也是同样 1→7, 跨层视觉组连贯, 0
		# 字段顺序错位 0 歧义). 单行字符从 ~30 扩到 ~50 (7pt 字号下
		# ≈ 130-140 px, 5 行均 < 240 px, ProfileRecentList ScrollContainer
		# 容器宽容纳, 0 layout 抖动). 与 T216 tooltip_text 0 触碰 (只是
		# row 文本 inline 加 2 派生率, tooltip 7 字段顺序已是权威).
		row_lbl.text = "Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s" % [
			run_n, _RECENT_ROW_FIELD_SEP,
			rooms, _RECENT_ROW_FIELD_SEP,
			enemies, _RECENT_ROW_FIELD_SEP,
			shards, _RECENT_ROW_FIELD_SEP,
			tm, ts, _RECENT_ROW_FIELD_SEP,
			rooms_per_minute, _RECENT_ROW_FIELD_SEP,
			enemies_per_minute, _RECENT_ROW_TIP_INDICATOR
		]
		row_lbl.add_theme_font_size_override("font_size", 7)
		# 5d — 最新 1 局用 Amber Voice 高亮 (i == 0)
		var default_color: Color
		if i == 0:
			default_color = _COLOR_RECENT_RUN_LATEST
		else:
			default_color = _COLOR_RECENT_RUN_NORMAL
		row_lbl.add_theme_color_override("font_color", default_color)
		row_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
		# T219 (#141) — 5 行 alpha 渐变（最新最亮，最旧最暗）。modulate.a
		# 5 步等差梯度 1.0 / 0.875 / 0.75 / 0.625 / 0.5 (5 步等差, 步长 0.125),
		# i==0 满亮 (Amber Voice) → i==4 50% 暗 (Pale Resonance). 5 行透明
		# 梯度让"上一局 (最新)"在视觉上最突出 (玩家最关注), 历史 4 局
		# 退到背景层避免抢焦点. modulate.a 整体透明度 与 font_color
		# 无关, T215 hover handler (改 font_color = Color.WHITE) 0 冲突:
		# 悬停时仍可看到高亮 WHITE × row_alpha 联动, 未悬停看到
		# default_color (Amber Voice / Pale Resonance) × row_alpha 联动.
		# 5 行 modulate 数值通过 const 1.0 / 0.5 + _PROFILE_RECENT_RUNS_MAX
		# 5 步线性插值, 改 const 不需要改 5 行赋值, 0 重复. 旧版本用
		# 1.0 满 alpha 一致, 0 视觉跳动: i==0 之前也是 1.0, 现在仍是 1.0.
		var alpha_step: float = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1)
		var row_alpha: float = _RECENT_ROW_ALPHA_MAX - float(i) * alpha_step
		row_lbl.modulate = Color(1.0, 1.0, 1.0, row_alpha)
		# T231 (#151) — 存 5 行 base alpha 到 _recent_row_hover_alpha_base 字典.
		# _on_recent_row_hover_in 读 dict + 0.1 boost (clampf 1.0) 算 boosted alpha,
		# _on_recent_row_hover_out 读 dict 恢复 base. 与 T219 (#141) alpha 渐变
		# 0 冲突 (T219 改 _refresh 末尾 modulate base, T231 hover 时 +0.1 偏移 base;
		# 两者时序分离 — T231 在 T219 设完 base 之后存 dict, hover 时再算 boosted).
		# 字典 key 用 row index (int), value = row_alpha (float).
		_recent_row_hover_alpha_base[i] = row_alpha
		# T215 (#136) — 5 行独立 hover 高亮 wiring：mouse_filter=STOP 显式设
		# (Label 默认 MOUSE_FILTER_IGNORE → 不会触发 mouse_entered signal)，
		# 与 T111 (#58) 成就 grid TextureRect、T214 (#134) ProfileQuickStats
		# Label 1 行 hover 同模式。mouse_entered.bind(i) / mouse_exited.bind(i)
		# 把行号绑到 handler 让 1 对函数处理 5 行（避免 5 个 _on_recent_row_N_*
		# 重复定义）。default_color 同步保存到 _recent_row_default_color 让
		# hover_out 0 误把高亮版当 default 写回。
		row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		row_lbl.mouse_entered.connect(_on_recent_row_hover_in.bind(i))
		row_lbl.mouse_exited.connect(_on_recent_row_hover_out.bind(i))
		# T216 (#137) — 5 行 hover tooltip 绑定 (悬停 1 行 = 5 字段含义
		# 静态信息层). 5 行都用同一 _build_recent_row_tooltip() 函数
		# 生成 11 行 tooltip (1 header + 5 字段 × 2 行/字段: bullet "• 段
		# 名 — 含义" + 缩进 "    detail") — 0 区别于 5 行 (5 行都用
		# 同一提示, 因为字段含义对每行都相同, 玩家悬停 5 行任意 1 行
		# = 看 5 字段含义). 与 T215 静态高亮层 (悬停整行提亮到
		# #FFFFFF) 双层互补: T215 给"鼠标在哪一行" 视觉反馈, T216 给
		# "5 字段含义" 静态信息; 玩家两个都需要.
		row_lbl.tooltip_text = _build_recent_row_tooltip()
		_recent_row_hovered.append(false)
		_recent_row_default_color.append(default_color)
		_profile_recent_list.add_child(row_lbl)

# T215 (#136) — ProfileRecentList 第 idx 行悬停高亮（玩家 mouse_entered handler）。
# 把 _profile_recent_list.get_child(idx) 的 font_color 提亮到 Color.WHITE，
# 让玩家在 5 行里清楚看到"鼠标正指着哪一局"。与 T214 (#134) QuickStats Run #
# 段 hover 高亮同源模式（label font_color 提亮到 #FFFFFF = 0 干扰原 BBCode
# 路径），但这里走 add_theme_color_override（不需 BBCode 包裹 — 整行单色）。
# 0 跨行联动：idx 参数只对当前行生效，5 行独立 _on_recent_row_hover_in 互不干扰。
# re-entrant safety: _recent_row_hovered[idx] = true 防止 mouse_entered 在同
# 一 idx 上多次触发（理论不应发生，但防御性 guard）。
#
# T240 (#158) — T215 snap 升级: font_color 提亮从 add_theme_color_override 立即
# 重算 → 0.12s tween_property 渐变 (TRANS_QUAD + EASE_OUT), 与 T231 alpha boost
# 0.12s 同步 (同 _RECENT_ROW_HOVER_FADE_DURATION). T240 共享 _recent_row_font_color_
# tween 引用 — 5 行共用 1 个 tween (同 row 不可能同时 hover_in/out, 单鼠标场景
# 5 行同时 hover 0 发生, 0 风险). kill 旧 tween 防快速 hover 进出叠加撕裂. T215
# 旧 add_theme_color_override 删 — tween_property 改 "theme_override_colors/font_color"
# sub-property (Godot 4 Label font_color 走 theme system, tween 走 theme override
# 路径与 add_theme_color_override 同源, 渲染层读最新 override 值, 0 冲突).
func _on_recent_row_hover_in(idx: int) -> void:
	if not _profile_recent_list:
		return
	if idx < 0 or idx >= _profile_recent_list.get_child_count():
		return
	if idx < _recent_row_hovered.size() and _recent_row_hovered[idx]:
		return  # re-entrant guard
	if idx >= _recent_row_hovered.size():
		_recent_row_hovered.resize(idx + 1)
	_recent_row_hovered[idx] = true
	var row: Node = _profile_recent_list.get_child(idx)
	if row and row is Label:
		# T240 (#158) — 0.12s tween font_color 提亮到 Color.WHITE (T215 snap 升级,
		# 与 T231 alpha boost 同步). Godot 4 Label 没有 font_color 直接属性 (字体色
		# 走 theme 系统, add_theme_color_override("font_color", ...) 设 theme override),
		# 所以 tween 必须走 "theme_override_colors/font_color" sub-property 路径
		# (与 add_theme_color_override 同源, tween 改 override 值, 渲染层读最新 override).
		# kill 旧 tween 防快速 hover 进出叠加; 5 行共享 1 个 tween 引用.
		if _recent_row_font_color_tween != null and _recent_row_font_color_tween.is_valid():
			_recent_row_font_color_tween.kill()
		_recent_row_font_color_tween = create_tween()
		_recent_row_font_color_tween.tween_property(row, "theme_override_colors/font_color", Color.WHITE, _RECENT_ROW_FONT_COLOR_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# T231 (#151) — 5 行 hover +0.1 alpha boost (T215 1 步升级, T226 模式同源).
		# 读 _recent_row_hover_alpha_base[idx] (T231 在 _refresh_recent_runs_list 末尾
		# 存每行 base alpha = 1.0 / 0.875 / 0.75 / 0.625 / 0.5 5 步渐变). default 1.0
		# (defensive: _refresh 之前或 hot-reload 异常时 _on_recent_row_hover_in 越界
		# 读 dict fallback, 1.0 + 0.1 = 1.0 clamp 不变). boosted_alpha = clampf(base +
		# 0.1, 0, 1): 最旧 1 局 (i==4) 0.5 + 0.1 = 0.6 "微微亮一阶", 最新 1 局 (i==0)
		# 1.0 + 0.1 = 1.0 clamp 不变 (已经最亮). tween 0.12s quad-ease-out 让
		# 0.1 差值渐变不"瞬变", 与 T226 AchievementGrid hover 0.12s 同节奏. 1 个
		# tween RGB 通道保持 (1.0, 1.0, 1.0) 不动 (T240 font_color tween 与 modulate
		# 通道独立, 0 干扰), 只改 modulate.a 1 通道.
		var base_alpha: float = 1.0
		if _recent_row_hover_alpha_base.has(idx):
			base_alpha = float(_recent_row_hover_alpha_base[idx])
		var boosted_alpha: float = clampf(base_alpha + _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST, 0.0, 1.0)
		var alpha_tween := create_tween()
		alpha_tween.tween_property(row, "modulate:a", boosted_alpha, _RECENT_ROW_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# T215 (#136) — ProfileRecentList 第 idx 行悬停取消（玩家 mouse_exited handler）。
# restore 到 _recent_row_default_color[idx]（_refresh_recent_runs_list 在创建
# row 时保存），让行恢复 Amber Voice（最新 1 局）/ Pale Resonance（其他 4 局）。
# 防御：_recent_row_default_color 越界 / 空 → 0 副作用退出。
# _recent_row_hovered[idx] = false re-entrant safety 防止下次 mouse_entered 误判。
#
# T240 (#158) — T215 snap 升级: font_color 渐回 default_color 走 0.12s tween_property
# (TRANS_QUAD + EASE_OUT), 与 T231 alpha 渐回 0.12s 同步. 与 hover_in 共享 1 个
# _recent_row_font_color_tween 引用 — kill 旧 tween, 新 tween 渐回 default_color.
func _on_recent_row_hover_out(idx: int) -> void:
	if not _profile_recent_list:
		return
	if idx < 0 or idx >= _profile_recent_list.get_child_count():
		return
	if idx < _recent_row_hovered.size():
		_recent_row_hovered[idx] = false
	if idx >= _recent_row_default_color.size():
		return  # default color not saved (e.g. empty history) → 0 副作用
	var default_color: Color = _recent_row_default_color[idx]
	var row: Node = _profile_recent_list.get_child(idx)
	if row and row is Label:
		# T240 (#158) — 0.12s tween font_color 渐回 default_color (T215 snap 升级,
		# 与 T231 alpha restore 0.12s 同步). Godot 4 Label font_color 走 theme system,
		# tween 必须走 "theme_override_colors/font_color" sub-property 路径 (与
		# add_theme_color_override 同源, 改 override 值). kill 旧 tween 防快速
		# hover 进出叠加.
		if _recent_row_font_color_tween != null and _recent_row_font_color_tween.is_valid():
			_recent_row_font_color_tween.kill()
		_recent_row_font_color_tween = create_tween()
		_recent_row_font_color_tween.tween_property(row, "theme_override_colors/font_color", default_color, _RECENT_ROW_FONT_COLOR_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# T231 (#151) — 5 行 hover 退出 tween 恢复 base alpha. 读 _recent_row_hover
		# _alpha_base[idx] (T231 _refresh 末尾存, default 1.0). tween 0.12s quad-ease-out
		# 把 modulate.a 从 boosted_alpha 渐回 base_alpha, 与 _on_recent_row_hover_in
		# tween 0.12s 同节奏 (跨 hover in/out 一致, 玩家看到"hover 进去亮一阶 →
		# 退出渐回原 alpha" 双向对称). 0 防御需要: dict 越界 / 旧 _refresh dict
		# 残留 → default 1.0 + 0.1 = 1.0 clamp, 玩家看到"立即恢复"无视觉跳动.
		var base_alpha: float = 1.0
		if _recent_row_hover_alpha_base.has(idx):
			base_alpha = float(_recent_row_hover_alpha_base[idx])
		var alpha_tween := create_tween()
		alpha_tween.tween_property(row, "modulate:a", base_alpha, _RECENT_ROW_HOVER_FADE_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# T244 (#161) — 6 verb row hover handler. 玩家悬停 StatsPanel._stat_abilities
# 或 ProfilePanel._profile_abilities 任 1 行, 0.12s tween 同步作用 2 通道:
# (1) font_color 渐到 _VERB_ROW_HOVER_FONT_COLOR (warm cream, 提亮 0.875/0.835/0.784
# → 1.0/0.96/0.88), 走 theme_override_colors/font_color sub-property (T240
# 模式同源, 与 _recent_row_font_color_tween 共享 1 个引用避免叠加撕裂).
# (2) modulate RGB 渐到 _VERB_ROW_HOVER_MODULATE (1.0/1.0/1.0/1.0 →
# 1.15/1.15/1.15/1.0) additive brighten, 整行 (含 BBCode inline 色块)
# 视觉提亮 ~15%, 与 T231 (#151) ProfileRecentList 5 行 alpha boost
# +0.1 节奏同源 (跨面板 hover 视觉组连贯). 玩家"hover 进去" 即时
# 反馈行被点中, 0 歧义. T199 tooltip 仍保留 (5s timeout 文字详情),
# T244 是行本身亮一阶的视觉强调, 2 者并存 0 冲突. 防御: _stat_abilities
# / _profile_abilities 同时为 null (玩家 _ready 时序竞态 / 未来 scene
# 改造) → early return 0 副作用. mouse_entered handler 共享 1 对
# (2 row 互斥 visibility, Stats / Profile 不会同时可见, 单鼠标场景
# 不可能同时 hover_in 2 row), 共享 handler 0 风险.
func _on_verb_row_hover_in() -> void:
	# 找当前可见 row (Stats 与 Profile 互斥, 取 1 个非 null 即可)
	var target: Label = _stat_abilities if _stat_abilities else _profile_abilities
	if target == null:
		return
	# (1) font_color tween (T240 模式, 0.12s quad-ease-out)
	if _verb_row_font_color_tween != null and _verb_row_font_color_tween.is_valid():
		_verb_row_font_color_tween.kill()
	_verb_row_font_color_tween = create_tween()
	_verb_row_font_color_tween.tween_property(target, "theme_override_colors/font_color", _VERB_ROW_HOVER_FONT_COLOR, _VERB_ROW_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# (2) modulate RGB additive brighten tween (T231 模式, 0.12s quad-ease-out)
	# 1.0 → 1.15 短暂提升, 整行 (含 BBCode inline 色块) 视觉提亮 ~15%.
	# Godot 4 Label modulate 字段是 Color, tween 改 r/g/b/a 全 4 通道, 与
	# font_color theme_override 独立 (1 个走 theme, 1 个走 modulate, 渲染
	# 层都读最新值, 0 干扰). 同步 tween 跨 2 通道让"hover 进入" 视觉
	# 是 1 个 0.12s 渐变整体, 玩家"hover 进去" 即时反馈 "行被点中".
	if _verb_row_modulate_tween != null and _verb_row_modulate_tween.is_valid():
		_verb_row_modulate_tween.kill()
	_verb_row_modulate_tween = create_tween()
	_verb_row_modulate_tween.tween_property(target, "modulate", _VERB_ROW_HOVER_MODULATE, _VERB_ROW_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# T244 (#161) — 6 verb row hover_out handler. 玩家 mouse_exited, 0.12s tween
# 渐回 baseline: (1) font_color → theme default (走 add_theme_color_override
# null 是清掉, 但 tween 目标必须 Color, 这里用 _VERB_ROW_BASE_FONT_COLOR
# 暖白 0.875/0.835/0.784 与 _ready 起始 _stat_abilities._profile_abilities
# theme default font_color 0.875/0.835/0.784 = Voxglass Warm White 同源
# [与 _build_verb_hint_tooltip 描述], tween 渐回"暖白默认色" 与 T199
# tooltip 视觉组连贯). (2) modulate → (1, 1, 1, 1) baseline. kill 旧
# tween 防快速 hover 进出叠加撕裂. 共享 1 对 handler (2 row 互斥), 0
# 副作用.
func _on_verb_row_hover_out() -> void:
	var target: Label = _stat_abilities if _stat_abilities else _profile_abilities
	if target == null:
		return
	# (1) font_color tween 渐回 baseline warm white
	if _verb_row_font_color_tween != null and _verb_row_font_color_tween.is_valid():
		_verb_row_font_color_tween.kill()
	_verb_row_font_color_tween = create_tween()
	_verb_row_font_color_tween.tween_property(target, "theme_override_colors/font_color", _VERB_ROW_BASE_FONT_COLOR, _VERB_ROW_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# (2) modulate tween 渐回 baseline (1, 1, 1, 1)
	if _verb_row_modulate_tween != null and _verb_row_modulate_tween.is_valid():
		_verb_row_modulate_tween.kill()
	_verb_row_modulate_tween = create_tween()
	_verb_row_modulate_tween.tween_property(target, "modulate", _VERB_ROW_BASE_MODULATE, _VERB_ROW_HOVER_FADE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# T201 (#117) — 跨局聚合 2 行（AvgResonance + BestStreak）。仅在
# PauseMenu 打开时调一次, 每次 _refresh_profile 重复（成本 < 0.5ms,
# 30 局 _run_history 一遍 linear scan, 对玩家暂停操作不可见）。
# 防御性：PlayerStats 在 headless 测试 / SaveLoadMenu 反序列化失败
# 时可能为 null, 守卫 + early return, 避免 NPE。
func _refresh_top_aggregate_rows() -> void:
	if not _profile_avg_resonance or not _profile_best_streak:
		return
	if not PlayerStats or not PlayerStats.has_method("get_run_history"):
		_profile_avg_resonance.text = "★ 平均共鸣 —  ★"
		_profile_best_streak.text = "★ 最佳单局 —  ★"
		if _profile_longest_room:
			_profile_longest_room.text = "★ 最长单房 —  ★"
		if _profile_recent_resonance:
			_profile_recent_resonance.text = "★ 近期共鸣 (近因加权) —  ★"
		return
	var history: Array = PlayerStats.get_run_history()
	# T201 — 零样本（首次启动或尚未 reset_run 过）→ "—" 占位, 不显
	# 0.0 / 0 房, 避免玩家误以为"avg=0"而慌（其实是没有数据）。
	if history.is_empty():
		_profile_avg_resonance.text = "★ 平均共鸣 —  ★"
		_profile_best_streak.text = "★ 最佳单局 —  ★"
		if _profile_longest_room:
			_profile_longest_room.text = "★ 最长单房 —  ★"
		if _profile_recent_resonance:
			_profile_recent_resonance.text = "★ 近期共鸣 (近因加权) —  ★"
		return
	# AvgResonance = sum(shards) / sum(rooms)。聚合"碎/房"是一个
	# 跨 run 累计比, 而非单 run 平均, 因为 avg(per-run avg) 会被
	# 0 房 run 拖偏 (例如 5 局有 1 局是 0 房, 那局 avg 巨大但物理
	# 意义弱)。聚合比与玩家"我每次房间平均能吸多少共鸣"直觉一
	# 致, 是 _trend (5/10/20) 行算术平均的互补视角。
	var total_shards: int = 0
	var total_rooms: int = 0
	for entry in history:
		if entry is Dictionary:
			total_shards += int(entry.get("shards_collected", 0))
			total_rooms += int(entry.get("rooms_cleared", 0))
	if total_rooms > 0:
		var avg_resonance: float = float(total_shards) / float(total_rooms)
		_profile_avg_resonance.text = "★ 平均共鸣 — %.1f 碎/房 (n=%d) ★" % [avg_resonance, history.size()]
	else:
		_profile_avg_resonance.text = "★ 平均共鸣 — (无房记录, n=%d) ★" % history.size()
	# BestStreak = rooms_cleared 最高的那个 run, 同时显示
	# run_number + 净 + 碎 + 时 (mm:ss) 一行, 让玩家一眼看到"我
	# 最强一局是什么样"。tied 时取最新（_run_history 后者覆盖
	# 前者 = 后入后出 / FIFO, 直接 > 比较可; 我们用 <= 保证新覆盖
	# 旧, 让"我最近一次破纪录"显示在最前）。
	var best_run: Dictionary = {}
	for entry in history:
		if entry is Dictionary:
			if best_run.is_empty() or int(entry.get("rooms_cleared", 0)) >= int(best_run.get("rooms_cleared", 0)):
				best_run = entry
	if not best_run.is_empty():
		var br_rooms: int = int(best_run.get("rooms_cleared", 0))
		var br_enemies: int = int(best_run.get("enemies_purified", 0))
		var br_shards: int = int(best_run.get("shards_collected", 0))
		var br_time: float = float(best_run.get("run_time_seconds", 0.0))
		var br_run_num: int = int(best_run.get("run_number", 0))
		var br_t: int = int(br_time)
		var br_m: int = br_t / 60
		var br_s: int = br_t % 60
		_profile_best_streak.text = "★ 最佳单局 #%d — %d 房 %d 净 %d 碎 %02d:%02d ★" % [
			br_run_num, br_rooms, br_enemies, br_shards, br_m, br_s
		]
	else:
		_profile_best_streak.text = "★ 最佳单局 —  ★"
	# T209 (#128) — 顶级行第 3 块 "最长单房"。数据源是
	# _best_stats["longest_room_seconds"]（PlayerStats 在
	# _update_best_stats_from_current_run 末尾单调更新, 同时写盘）。
	# 直接 PlayerStats.get_best_stats() 读 dict, 避免再扫一遍
	# history（history snapshot 里也有 longest_room_seconds, 但取
	# 跨 run max 等价于 _best_stats 的语义, 而且省一次 O(n) 遍历）。
	if _profile_longest_room:
		var best_stats: Dictionary = PlayerStats.get_best_stats() if PlayerStats.has_method("get_best_stats") else {}
		var lr: float = float(best_stats.get("longest_room_seconds", 0.0))
		if lr > 0.0:
			var lr_t: int = int(lr)
			var lr_m: int = lr_t / 60
			var lr_s: int = lr_t % 60
			_profile_longest_room.text = "★ 最长单房 %02d:%02d ★" % [lr_m, lr_s]
		else:
			_profile_longest_room.text = "★ 最长单房 —  ★"
	# T232 (#151) — 顶级行第 4 块 "近期共鸣 (近因加权)". 跨 run 5 局
	# 加权衰减: 5 局 (新→旧) weight = [0.5^0, 0.5^1, 0.5^2, 0.5^3, 0.5^4] =
	# [1.0, 0.5, 0.25, 0.125, 0.0625]. history.size() < 5 时取 size() 局
	# 加权. weighted_ratio = sum(w[i] * shards[i]) / sum(w[i] * rooms[i])
	# 其中 i=0 是最新 run (history 末尾). 与 T201 AvgResonance 区别:
	# T201 跨所有 run 累计比, T232 跨最近 5 局加权 — 后者更灵敏反映
	# "当前技能". history 空 (新玩家) → "—" 占位. history 全 0 房
	# (e.g. 5 局连续 abort) → "— (无房记录, n=N) ★" 与 T201 fallback
	# 风格一致. 显示 "★ 近期共鸣 (近因加权) — %.1f 碎/房 (n=%d, 衰 %.1f) ★"
	# 让玩家明确知道是加权版 (与简单平均区分).
	if _profile_recent_resonance:
		if history.is_empty():
			_profile_recent_resonance.text = "★ 近期共鸣 (近因加权) —  ★"
		else:
			var w_total_shards: float = 0.0
			var w_total_rooms: float = 0.0
			var w_count: int = min(history.size(), _RECENT_RESONANCE_HISTORY_WINDOW)
			# 从 history 末尾 (最新 run) 倒取 _RECENT_RESONANCE_HISTORY_WINDOW 局
			for i in range(w_count):
				# i=0 是新→旧权重最大, history 末尾 = 最新 run
				var h_idx: int = history.size() - 1 - i
				var entry = history[h_idx]
				if entry is Dictionary:
					var w: float = pow(_RECENT_RESONANCE_DECAY, float(i))
					w_total_shards += w * float(int(entry.get("shards_collected", 0)))
					w_total_rooms += w * float(int(entry.get("rooms_cleared", 0)))
			if w_total_rooms > 0.0:
				var recent_resonance: float = w_total_shards / w_total_rooms
				_profile_recent_resonance.text = "★ 近期共鸣 (近因加权) — %.1f 碎/房 (n=%d, 衰 %.1f) ★" % [
					recent_resonance, history.size(), _RECENT_RESONANCE_DECAY
				]
			else:
				_profile_recent_resonance.text = "★ 近期共鸣 (近因加权) — (无房记录, n=%d) ★" % history.size()

func _build_profile_achievement_list() -> void:
	# Build a full-text list of all achievements: 32x32 icon + title +
	# description + unlock time (or "未解锁" placeholder).  Same data
	# source as the sidebar's AchvGrid but in a more readable form.
	var sorted_unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	var unlocked_ids: Array = []
	for row in sorted_unlocked:
		unlocked_ids.append(row[0])
	# T109 — sort unlocked by time, locked by id (stable order)
	var all: Array = PlayerStats.get_all_achievements()
	var locked: Array = []
	for ach in all:
		var id_val: String = ach.get("id", "")
		if id_val == "":
			continue
		if not unlocked_ids.has(id_val):
			locked.append(ach)
	locked.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	# Build display rows
	for row in sorted_unlocked:
		_add_profile_achv_row(row[0], row[1], row[2], int(row[3]), true)
	for ach in locked:
		var id_val: String = ach.get("id", "")
		var title_zh: String = ach.get("title_zh", id_val)
		var desc_zh: String = ach.get("description_zh", "")
		_add_profile_achv_row(id_val, title_zh, desc_zh, 0, false)

func _add_profile_achv_row(id_val: String, title_zh: String, desc_zh: String, ts: int, is_unlocked: bool) -> void:
	var hint: String = ICON_DEFAULT
	for ach in PlayerStats.get_all_achievements():
		if ach.get("id", "") == id_val:
			hint = ach.get("icon_hint", ICON_DEFAULT)
			break
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 16)
	row.name = "ProfileAchv_" + id_val
	# Icon (32x32 — same source as 16x16, but 2x scale)
	var tex := _load_icon_texture(hint)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(16, 16)
	icon.texture = tex
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if not is_unlocked:
		icon.modulate = Color(0.25, 0.25, 0.3, 0.5)
		icon.self_modulate = Color(0.25, 0.25, 0.3, 0.5)
	row.add_child(icon)
	# Text column
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title_lbl := Label.new()
	title_lbl.text = title_zh
	title_lbl.add_theme_font_size_override("font_size", 8)
	if is_unlocked:
		title_lbl.add_theme_color_override("font_color", Color(0.949, 0.714, 0.431, 1))  # Amber Voice
	else:
		title_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55, 1))  # greyed out
	text_col.add_child(title_lbl)
	var desc_lbl := Label.new()
	desc_lbl.text = desc_zh
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_color_override("font_color", Color(0.718, 0.906, 0.867, 1))  # Pale Resonance
	text_col.add_child(desc_lbl)
	row.add_child(text_col)
	# Time column
	var time_lbl := Label.new()
	if is_unlocked and ts > 0:
		var dt := Time.get_datetime_dict_from_unix_time(ts)
		time_lbl.text = "%02d-%02d %02d:%02d" % [dt.month, dt.day, dt.hour, dt.minute]
	else:
		time_lbl.text = "—"
	time_lbl.add_theme_font_size_override("font_size", 7)
	time_lbl.add_theme_color_override("font_color", Color(0.875, 0.835, 0.784, 1))
	row.add_child(time_lbl)
	_profile_achv_list.add_child(row)

func _refresh_profile_achievement_list() -> void:
	# Clear and rebuild.  Cheap: <20 rows, no expensive work.  Triggered
	# when the player opens the panel (potentially after a fresh unlock).
	for child in _profile_achv_list.get_children():
		child.queue_free()
	_build_profile_achievement_list()

# T152 (#79) — 0 数灰阶占位 helper。value <= 0 → 文本 "—"，色
# 调 _COLOR_ZERO_STAT（暖灰）；value > 0 → 用 format_str 格式化数
# 字，色调还原为暖白 (0.875, 0.835, 0.784)（与 STYLE_GUIDE 暖
# 白一致；不用 _COLOR_NORMAL_STAT 是因为可能 label 之前被
# 别的代码设过 Glass Cyan 调色——还原暖白是更安全的"中性
# 状态"）。format_str 不应包含 BBCode 色码：这里走纯文本 +
# 主题色调路径，与 5 动词行（BBCode 路径）区分。
func _set_zero_aware_stat(lbl: Label, value: int, format_str: String) -> void:
	if lbl == null:
		return
	if value > 0:
		lbl.text = format_str % value
		lbl.add_theme_color_override("font_color", Color(0.875, 0.835, 0.784, 1.0))
	else:
		# 把 format_str 里的 "  %d" 截掉前缀只留 label 名（"完成房间  %d" → "完成房间"）。
		# 这样 "—" 不会与 %d 错位；保留中文 label 名 + 两个空格的视觉节奏。
		var label_part: String = format_str
		var idx := label_part.find("  %d")
		if idx >= 0:
			label_part = label_part.substr(0, idx)
		lbl.text = "%s  —" % label_part
		lbl.add_theme_color_override("font_color", _COLOR_ZERO_STAT)
