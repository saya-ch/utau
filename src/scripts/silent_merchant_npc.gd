class_name SilentMerchantNPC
extends Area2D

## T068 — 无声商贩 NPC
##
## Hub 安全区永久 NPC，提供"能力升级 / 永久 buff 购买"功能。
## 自管理交互（与 HubController 解耦）：玩家走近显示 "按 E 交易"，
## 按 E 后打开 ShopMenu 模态层。
##
## 设计依据：与普通对话 NPC（Archivist / Tuner）不同，商人提供
## 的是 UI 重型操作（5 行商品 + 购买按钮 + 货币 + 货币动态禁用），
## 与 dialogue_box 适配成本高。独立控制流更清晰。

signal interacted(npc_id: String)

@export var npc_id: String = "silent_merchant"
@export var npc_name: String = "无声商贩"
@export var interaction_radius: float = 24.0
@export var portrait_texture: Texture2D = null

var _player_in_range: bool = false
var _shop_open: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hint: Label = $InteractionHint
@onready var _shop_menu: ShopMenu = get_tree().root.get_node_or_null("HubRoom/ShopMenu") as ShopMenu

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Defensive: if a scene-level collision shape wasn't authored,
	# synthesize a 24px circle (matches the regular NPC default so
	# interaction feels consistent).
	if _collision and _collision.shape == null:
		var shape := CircleShape2D.new()
		shape.radius = interaction_radius
		_collision.shape = shape

	if _hint:
		_hint.visible = false
		_hint.text = "按 E 交易"
		_hint.modulate = Color("#F2B66E")

	# The ShopMenu lives in the Hub room as a sibling — we resolve it
	# lazily so a direct scene preview of the merchant doesn't crash.
	_try_resolve_shop_menu()
	if _shop_menu and _shop_menu.has_signal("closed"):
		_shop_menu.closed.connect(_on_shop_closed)

func _try_resolve_shop_menu() -> void:
	if _shop_menu != null:
		return
	# Walk the current scene tree looking for the first ShopMenu node.
	# Cheaper than registering a group, and resilient to scene reorg.
	_find_shop_menu_recursive(get_tree().current_scene)

func _find_shop_menu_recursive(node: Node) -> void:
	if node == null or _shop_menu != null:
		return
	if node is ShopMenu:
		_shop_menu = node
		return
	for child in node.get_children():
		_find_shop_menu_recursive(child)
		if _shop_menu != null:
			return

func _input(event: InputEvent) -> void:
	if _shop_open:
		return
	if _player_in_range and event.is_action_pressed("interact"):
		_open_shop()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		if _hint:
			_hint.visible = true
			var tween := create_tween()
			tween.tween_property(_hint, "modulate:a", 1.0, 0.2)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if _hint:
			var tween := create_tween()
			tween.tween_property(_hint, "modulate:a", 0.0, 0.2)
			tween.tween_callback(func() -> void: _hint.visible = false)

func _open_shop() -> void:
	if _shop_open:
		return
	_try_resolve_shop_menu()
	if _shop_menu == null:
		push_warning("SilentMerchantNPC: ShopMenu not found in scene tree")
		return
	_shop_open = true
	get_tree().paused = true
	_shop_menu.show_menu()
	interacted.emit(npc_id)

func _on_shop_closed() -> void:
	_shop_open = false
	get_tree().paused = false
