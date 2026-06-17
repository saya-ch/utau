class_name ShopMenu
extends Control

## T068 — 无声商贩商店菜单
##
## 加载 data/shop_catalog.json 显示 5 个永久升级商品，货币为
## GameState.shards（共鸣碎片）。购买后立即应用 GameState 中的
## bonus 字段；玩家可在多次 run 中累积购买。
##
## 解锁条件：
## - 心之共鸣晶 / 共鸣钟 / 声波聚焦 / 回响护符：始终可见可购买
## - 破寂者（一次性奖励）：需要先解锁 full_archive 成就
##
## 关闭：ESC 键 / 关闭按钮 / 在菜单外按 E 不重开（避免与玩家移动冲突）

signal closed
signal perk_purchased(perk_id: String)

const SHOP_CATALOG_PATH := "res://data/shop_catalog.json"

@onready var _title_label: Label = $Panel/VBoxContainer/TitleRow/TitleLabel
@onready var _close_btn: Button = $Panel/VBoxContainer/TitleRow/CloseButton
@onready var _shard_label: Label = $Panel/VBoxContainer/TitleRow/ShardLabel
@onready var _item_list: VBoxContainer = $Panel/VBoxContainer/ItemList
@onready var _hint_label: Label = $Panel/VBoxContainer/HintLabel

var _items: Array = []               # shop_catalog.json 原始数据
var _item_rows: Dictionary = {}      # perk_id -> { button, price_label, count_label, item_data }

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_close_btn.pressed.connect(_on_close_pressed)
	_title_label.modulate = Color("#F2B66E")
	_title_label.text = "无声商贩"
	_hint_label.text = "ESC 关闭   |   货币 = 共鸣碎片"
	_hint_label.modulate = Color("#B7E7DD")
	_shard_label.modulate = Color("#E6D5B8")
	_load_catalog()
	_build_item_rows()
	_refresh_all()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	show()
	modulate = Color.TRANSPARENT
	_refresh_all()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func _on_close_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(func() -> void:
		hide()
		closed.emit()
	)

# === 加载目录 ===

func _load_catalog() -> void:
	if not FileAccess.file_exists(SHOP_CATALOG_PATH):
		push_warning("ShopMenu: catalog not found at %s" % SHOP_CATALOG_PATH)
		return
	var file := FileAccess.open(SHOP_CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_warning("ShopMenu: failed to open catalog")
		return
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		push_warning("ShopMenu: failed to parse catalog")
		return
	_items = parsed.get("items", [])

# === 构建行 ===

func _build_item_rows() -> void:
	# Clear any pre-existing rows (defensive against re-builds).
	for child in _item_list.get_children():
		child.queue_free()
	_item_rows.clear()

	for item_data in _items:
		var perk_id: String = item_data.get("id", "")
		if perk_id == "":
			continue
		var result := _build_item_row(item_data)
		var row: Node = result[0]
		var entry: Dictionary = result[1]
		_item_list.add_child(row)
		_item_rows[perk_id] = entry

func _build_item_row(item_data: Dictionary) -> Array:
	# Row layout: [Name+Desc (expand)] [Status+Price] [Buy button]
	# Returns: [HBoxContainer, Dictionary_entry]
	# The Dictionary entry exposes child widgets for _refresh_item().
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size = Vector2(0, 36)
	row.add_theme_constant_override("separation", 8)

	# Name + description column
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 1)

	var name_label := Label.new()
	name_label.text = item_data.get("name_zh", item_data.get("id", ""))
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.modulate = Color("#F2B66E")
	info.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = item_data.get("description_zh", "")
	desc_label.add_theme_font_size_override("font_size", 8)
	desc_label.modulate = Color("#B7E7DD")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc_label)

	row.add_child(info)

	# Status column (price + bought count)
	var status := VBoxContainer.new()
	status.custom_minimum_size = Vector2(96, 0)
	status.add_theme_constant_override("separation", 1)

	var price_label := Label.new()
	price_label.add_theme_font_size_override("font_size", 9)
	price_label.modulate = Color("#E6D5B8")
	status.add_child(price_label)

	var count_label := Label.new()
	count_label.add_theme_font_size_override("font_size", 8)
	count_label.modulate = Color("#69C7CE")
	status.add_child(count_label)

	row.add_child(status)

	# Buy button
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(72, 28)
	btn.add_theme_font_size_override("font_size", 9)
	var perk_id: String = item_data.get("id", "")
	btn.pressed.connect(func() -> void: _on_buy_pressed(perk_id))
	row.add_child(btn)

	return [row, {
		"price_label": price_label,
		"count_label": count_label,
		"button": btn,
		"item_data": item_data,
	}]

# === 刷新显示 ===

func _refresh_all() -> void:
	_shard_label.text = "◆ %d" % GameState.shards
	for perk_id in _item_rows.keys():
		_refresh_item(perk_id)

const _PERK_LEVEL_ROMAN := ["—", "I", "II", "III", "IV", "V"]


func _format_perk_level_label(count: int) -> String:
	# F012 (#101) — replace flat "已购 %d/%d" with a perk-level
	# readout.  "Lv —" when none purchased, then "Lv I" / "Lv II" /
	# "Lv III" as the player invests.  Roman numerals match the
	# 5-verb perk-level naming in audio_manager_enhanced.gd
	# (T181 / T182 — perk_level 0..3 → — / I / II / III), so a
	# Pulse Focus "Lv II" card in the shop reads the same as a
	# Pulse hit SFX at perk_level 2.  Falls back to "Lv %d" if a
	# future perk ever exceeds the 6-step roman table.
	if count < 0:
		count = 0
	if count < _PERK_LEVEL_ROMAN.size():
		return "Lv %s" % _PERK_LEVEL_ROMAN[count]
	return "Lv %d" % count


func _refresh_item(perk_id: String) -> void:
	if not _item_rows.has(perk_id):
		return
	var entry: Dictionary = _item_rows[perk_id]
	var data: Dictionary = entry.get("item_data", {})
	var price_label: Label = entry.get("price_label")
	var count_label: Label = entry.get("count_label")
	var btn: Button = entry.get("button")

	var price: int = int(data.get("price_shards", 0))
	var max_purchases: int = int(data.get("max_purchases", 1))
	var unlock_achv: String = data.get("unlock_achievement", "")
	var category: String = data.get("category", "upgrade")

	var count := GameState.get_perk_count(perk_id)
	var at_max := count >= max_purchases
	var can_afford := GameState.shards >= price
	var unlocked := unlock_achv == "" or PlayerStats.is_unlocked(unlock_achv)

	if price_label:
		if price == 0:
			price_label.text = "免费"
		else:
			price_label.text = "◆ %d" % price

	if count_label:
		# F012 (#101) — perk-level readout ("Lv —" / "Lv I" / …).
		count_label.text = _format_perk_level_label(count)
		# Subtle color hint when a perk has been leveled up at
		# all; full saturation at max.  Keeps the rest of the
		# slot layout unchanged.
		if count == 0:
			count_label.modulate = Color(0.65, 0.65, 0.7, 0.9)
		elif at_max:
			count_label.modulate = Color(1.0, 0.78, 0.55, 1.0)
		else:
			count_label.modulate = Color(0.62, 0.85, 0.95, 1.0)

	if btn:
		btn.disabled = at_max or not can_afford or not unlocked
		if at_max:
			btn.text = "已满"
		elif not unlocked:
			btn.text = "未解锁"
		elif not can_afford:
			btn.text = "◆ 不足"
		else:
			btn.text = "购买"

# === 购买处理 ===

func _on_buy_pressed(perk_id: String) -> void:
	if not _item_rows.has(perk_id):
		return
	var data: Dictionary = _item_rows[perk_id].get("item_data", {})
	var price: int = int(data.get("price_shards", 0))
	var max_purchases: int = int(data.get("max_purchases", 1))
	var unlock_achv: String = data.get("unlock_achievement", "")

	# Defensive gates (the button is also disabled, but a stale event
	# could still land here if the menu re-renders between user click
	# and signal fire).
	if unlock_achv != "" and not PlayerStats.is_unlocked(unlock_achv):
		_show_flash("需要先解锁「完整档案」成就")
		return

	var success := GameState.purchase_perk(perk_id, price, max_purchases)
	if not success:
		_show_flash("购买失败")
		return

	# Refresh the GameState-derived values on the player.  In normal
	# flow, the player is in the Hub so its abilities are in standby
	# (no per-frame consumption).  Re-applying damage/radius is safe
	# because PulseAbility._ready sums onto the export value exactly
	# once; in the Hub we re-derive the total from scratch.
	var player := get_tree().get_first_node_in_group("player") as Node
	if player:
		var pulse := player.get_node_or_null("PulseAbility") as Node
		if pulse and "pulse_radius" in pulse and "damage" in pulse and pulse.has_method("_has_game_state_autoload"):
			# Reset to base export value first by re-reading the
			# scene-level exports is non-trivial from script; we
			# instead rebuild totals from the per-perk deltas stored
			# in GameState (which is the source of truth after the
			# shop opens).
			pulse.set("pulse_radius", 48.0 + GameState.get_pulse_radius_bonus())
			pulse.set("damage", 1 + GameState.get_damage_bonus())
			pulse.set("pulse_kill_refund", GameState.get_pulse_kill_refund())
		var cut := player.get_node_or_null("CutAbility") as Node
		if cut and "damage" in cut:
			cut.set("damage", 2 + GameState.get_damage_bonus())
		# T096 — echo_charm grants +8px to the Echo shield radius.  Re-apply
		# the same way PulseAbility re-derives its radius: take the @export
		# base (30.0) + the per-perk delta from GameState.  This matches
		# what EchoAbility._ready would do on a fresh _ready, so the Hub
		# and the field stay consistent.
		var echo := player.get_node_or_null("EchoAbility") as Node
		if echo and "echo_radius" in echo:
			echo.set("echo_radius", 30.0 + float(GameState.get_echo_radius_bonus()))
		# Health & resonance UI must re-render to reflect the new max
		# (max_health / max_resonance are derived properties whose value
		# changes as soon as the bonus is applied; the setter alone
		# would re-emit only if the value actually moves, so we
		# explicitly fan out the signal).
		GameState.refresh_vitals()

	perk_purchased.emit(perk_id)
	_refresh_all()

	# F013 (#102) — Audio feedback: purchase_confirm chord (the
	# player just spent shards) + level_up arpeggio whose base note
	# scales with the perk's NEW level (0=I → 1=II → 2=III → 3=IV
	# → so the same perk being upgraded for the 3rd time plays a
	# higher arpeggio than the 1st).  Played in order so the chord
	# lands first ("ding! got it") then the arpeggio sweeps
	# ("and now it's stronger").  The clamp keeps level 4+ (max
	# exceeded by future catalog expansion) at the top arpeggio.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced")
	if ame:
		if ame.has_method("play_shop_purchase_confirm"):
			ame.play_shop_purchase_confirm()
		var new_count: int = GameState.get_perk_count(perk_id)
		if ame.has_method("play_shop_level_up"):
			ame.play_shop_level_up(max(0, new_count - 1))
		# T185 (#103) — 屏抖反馈 (升档 ≥2 时).  level 0=I (首次购买)
		# 不抖 (柔和反馈, 与 purchase_confirm chord 已经够),
		# level 1=II 起开始小屏抖 (2.5 / 0.15s, 介于 LIGHT 1.0/0.08
		# 与 HEAVY 4.0/0.18 之间 — 比 verb fire PULSE 2.0/0.10 略强
		# 一点点, 表明"这是商店升级" 而非 "我用了一次 verb").
		# 阈值 ≥2 (即 new_count ≥ 2, 即 II 级及以上) 与 F013
		# arpeggio base MIDI 60/62/64/65 同步, 升档的"重大感"
		# 在音高 + 屏抖 + 文案三层同时强化.
		# has_method 守卫 (而不是 autoload null check) 因为 T185
		# 是 #103 新加, 老版本 ame 没这个 preset enum 值会
		# 抛 push_warning ("unknown preset") 而不是 crash.
		if new_count >= 2 and ScreenShake.has_method("shake_preset") \
				and ScreenShake.Preset.has("PERK_LEVEL_UP"):
			ScreenShake.shake_preset(ScreenShake.Preset.PERK_LEVEL_UP)

	# Brief flash confirmation
	var entry: Dictionary = _item_rows[perk_id]
	var btn: Button = entry.get("button")
	if btn:
		btn.modulate = Color("#F2B66E")
		var tween := create_tween()
		tween.tween_property(btn, "modulate", Color.WHITE, 0.4)

	_show_flash("购买成功")

func _show_flash(text: String) -> void:
	# Repurpose the title label for a brief status flash.  Cheap and
	# in-keeping with the menu's muted visual style (we don't add
	# a new label just for one-line confirmations).
	_title_label.text = text
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_callback(func() -> void: _title_label.text = "无声商贩")

# === 外部刷新（被 SilentMerchantNPC 互动时调用） ===

func refresh() -> void:
	_refresh_all()
