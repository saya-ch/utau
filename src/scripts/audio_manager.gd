extends Node

# Compatibility / fallback wrapper for legacy `AudioManager` autoload.
#
# The canonical audio autoload in Voxglass is `AudioManagerEnhanced`
# (res://src/autoload/audio_manager_enhanced.gd), which provides all
# procedural SFX, music, and bus mixing.
#
# This file is kept as a thin pass-through so that any code path still
# referencing `AudioManager.<method>()` continues to work without
# duplicating the actual SFX generation / bus setup logic.
#
# It is NOT registered as a project autoload any more (see #T050).
# Direct `AudioManagerEnhanced.<method>()` calls remain the preferred API.

func _ready() -> void:
	# Defer to the canonical autoload so the SFX / Music / Ambience
	# buses are created exactly once.
	if Engine.has_singleton("AudioManagerEnhanced") or _audio_enhanced_exists():
		pass

func _audio_enhanced_exists() -> bool:
	# Explicit Node type — `get_tree().root` is a Window, not Variant; using
	# `var x := ... if ... else null` would otherwise infer to Variant.
	var root: Node = get_tree().root if get_tree() else null
	if root == null:
		return false
	return root.has_node("AudioManagerEnhanced")

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
	if _audio_enhanced_exists() and AudioManagerEnhanced.has_method("play_sfx"):
		AudioManagerEnhanced.play_sfx(stream, bus)
		return
	# Fallback: spawn a one-shot player on the default bus.
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(stream: AudioStream) -> void:
	if _audio_enhanced_exists() and AudioManagerEnhanced.has_method("play_music"):
		AudioManagerEnhanced.play_music(stream)

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	if _audio_enhanced_exists() and AudioManagerEnhanced.has_method("set_bus_volume"):
		AudioManagerEnhanced.set_bus_volume(bus_name, volume_db)
		return
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func has_method(name: String) -> bool:
	# Surface the canonical autoload's method set as if it were our own,
	# so call-sites using `AudioManager.has_method(...)` keep working.
	if _audio_enhanced_exists():
		return AudioManagerEnhanced.has_method(name)
	return false
