extends Node

# Placeholder audio manager for Voxglass
# Will be expanded with adaptive audio and SFX bus mixing

func _ready() -> void:
	# Ensure audio buses exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	if AudioServer.get_bus_index("Ambience") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Ambience")

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(stream: AudioStream) -> void:
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
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)
