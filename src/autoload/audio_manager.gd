extends Node

# AudioManager — fallback wrapper for AudioManagerEnhanced (T050).
#
# After T050, the official autoload is AudioManagerEnhanced, which owns the
# procedural SFX, music, and bus setup. This script remains registered as an
# autoload purely as a defensive fallback layer: if AudioManagerEnhanced is
# somehow missing, this stub still creates the basic audio buses so the game
# does not crash. All other methods forward to AudioManagerEnhanced.
#
# Public API (mirrors the legacy placeholder signatures):
#   play_sfx(stream, bus = "SFX")
#   play_music(stream)
#   set_bus_volume(bus_name, volume_db)
#
# Anything that wants the procedural SFX (play_pulse / play_footstep / etc.)
# should call AudioManagerEnhanced directly.

func _ready() -> void:
	# Only set up buses if AudioManagerEnhanced is absent (e.g. someone
	# accidentally removed it from project.godot). AudioManagerEnhanced
	# already creates SFX / Music / Ambience, so this is a true fallback.
	if not _enhanced_exists():
		_ensure_buses_fallback()

func _enhanced_exists() -> bool:
	# Engine.get_singleton returns null in Godot 4 for autoloads registered
	# by path; the canonical lookup is via the SceneTree. We do a
	# `has_node` style check by name.
	var root := get_tree().root if is_inside_tree() else null
	if root == null:
		return false
	return root.has_node("AudioManagerEnhanced")

func _ensure_buses_fallback() -> void:
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	if AudioServer.get_bus_index("Ambience") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Ambience")

func _delegate() -> Node:
	var root := get_tree().root
	return root.get_node_or_null("AudioManagerEnhanced")

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
	var target := _delegate()
	if target and target.has_method("play_sfx"):
		target.call("play_sfx", stream, bus)
		return
	# Fallback: play one-shot locally so the SFX is not lost.
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(stream: AudioStream) -> void:
	var target := _delegate()
	if target and target.has_method("play_music"):
		target.call("play_music", stream)
		return
	# Fallback: simple single-track replacement.
	var existing := get_node_or_null("MusicPlayer") as AudioStreamPlayer
	if existing:
		existing.stop()
		existing.queue_free()
	var player := AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	player.stream = stream
	player.bus = "Music"
	add_child(player)
	player.play()

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var target := _delegate()
	if target and target.has_method("set_bus_volume"):
		target.call("set_bus_volume", bus_name, volume_db)
		return
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)
