extends Node

const SOUNDS := {
	"hover": preload("res://assets/audio/hover.wav"),
	"click": preload("res://assets/audio/click.wav"),
	"charge": preload("res://assets/audio/charge.wav"),
	"crack": preload("res://assets/audio/crack.wav"),
	"hatch": preload("res://assets/audio/hatch.wav"),
	"reveal": preload("res://assets/audio/reveal.wav"),
	"rare": preload("res://assets/audio/rare.wav"),
}
var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var muted := false
var started := false
var hover_time := 0
var music_level := 0.4
var effects_level := 0.65

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music = AudioStreamPlayer.new()
	var soundtrack: AudioStreamWAV = preload("res://assets/audio/longdong_ambient.wav").duplicate()
	soundtrack.loop_mode = AudioStreamWAV.LOOP_FORWARD
	soundtrack.loop_end = int(soundtrack.get_length() * soundtrack.mix_rate)
	music.stream = soundtrack
	music.volume_db = -8
	add_child(music)
	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.volume_db = -4
		add_child(player)
		effects.append(player)
	get_tree().node_added.connect(_watch_node)
	var preferences := ConfigFile.new()
	if preferences.load("user://audio.cfg") == OK:
		muted = preferences.get_value("audio", "muted", false) == true
		music_level = clampf(float(preferences.get_value("audio", "music_level", .4)), 0, 1)
		effects_level = clampf(float(preferences.get_value("audio", "effects_level", .65)), 0, 1)
	_apply_levels()
	_apply_mute()

func _watch_node(node: Node) -> void:
	if node is BaseButton:
		if not node.pressed.is_connected(play.bind("click")):
			node.pressed.connect(play.bind("click"))
		if not node.mouse_entered.is_connected(_hover):
			node.mouse_entered.connect(_hover)

func _input(event: InputEvent) -> void:
	if not started and ((event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed) or (event is InputEventScreenTouch and event.pressed)):
		started = true
		music.play()

func _hover() -> void:
	if Time.get_ticks_msec() - hover_time > 100:
		hover_time = Time.get_ticks_msec()
		play("hover")

func play(sound: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if muted or not SOUNDS.has(sound):
		return
	for player in effects:
		if not player.playing:
			player.stream = SOUNDS[sound]
			player.play()
			return

func stop_cinematic() -> void:
	for player in effects:
		if player.stream in [SOUNDS.charge, SOUNDS.crack, SOUNDS.hatch, SOUNDS.reveal, SOUNDS.rare]:
			player.stop()
			player.stream = null

func stop_all() -> void:
	music.stop()
	music.stream = null
	for player in effects:
		player.stop()
		player.stream = null

func _exit_tree() -> void:
	stop_all()

func set_muted(value: bool) -> void:
	muted = value
	_apply_mute()
	_save_preferences()

func set_music_level(value: float) -> void:
	music_level = clampf(value,0,1)
	_apply_levels()
	_save_preferences()

func set_effects_level(value: float) -> void:
	effects_level = clampf(value,0,1)
	_apply_levels()
	_save_preferences()

func _apply_levels() -> void:
	music.volume_db = linear_to_db(maxf(music_level,.0001))
	for player in effects:
		player.volume_db = linear_to_db(maxf(effects_level,.0001))

func _save_preferences() -> void:
	var preferences := ConfigFile.new()
	preferences.set_value("audio", "muted", muted)
	preferences.set_value("audio", "music_level", music_level)
	preferences.set_value("audio", "effects_level", effects_level)
	preferences.save("user://audio.cfg")

func _apply_mute() -> void:
	AudioServer.set_bus_mute(0, muted)
