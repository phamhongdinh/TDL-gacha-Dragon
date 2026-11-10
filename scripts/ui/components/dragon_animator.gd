class_name DragonAnimator
extends Control

## Bộ hiệu ứng chuyển động sống động cho tất cả các chú rồng:
## 1. Mắt rồng tự động chớp mắt tự nhiên theo thời gian (kèm nhịp chớp kép ngẫu nhiên).
## 2. Cánh rồng vỗ và chuyển động nhịp nhàng liên tục.
## 3. Lửa và năng lượng nguyên tố trên cơ thể, bờm sừng, vai và đuôi rồng chuyển động rực cháy liên tục.

const IDLE_SHADER: Shader = preload("res://resources/dragon_idle.gdshader")

static var _shared_shader: Shader = null

var target_sprite: TextureRect
var shader_mat: ShaderMaterial
var _last_texture: Texture2D = null
var _species_key: String = ""
var _is_dragon_texture: bool = false

var _time: float = 0.0
var _phase_offset: float = 0.0
var _blink_timer: float = 1.8
var _blink_elapsed: float = -1.0
var _double_blink_pending: bool = false
var _blink_cycle_count: int = 0
var _rng := RandomNumberGenerator.new()
var _gaze_timer := 8.0
var _gaze := Vector2.ZERO
var _gaze_target := Vector2.ZERO
const SLEEP_AFTER := 15.0
const DROWSY_AFTER := 12.0
var sleep_enabled := false
var idle_seconds := 0.0
var sleep_blend := 0.0
var sleep_pose: TextureRect
var sleep_time := 0.0
var _sleep_texture: Texture2D
const SLEEP_GROUND := {
 "fire": Vector2(0.93359375,0.76171875),
 "fire_shadow": Vector2(0.9140625,0.83203125),
 "fire_water": Vector2(0.92578125,0.7734375),
 "shadow": Vector2(0.92578125,0.78125),
 "triple": Vector2(0.890625,0.796875),
 "water": Vector2(0.91796875,0.76171875),
 "water_shadow": Vector2(0.90625,0.76171875)
}
var _ground_pair := Vector2(0.92,0.75)

func enable_sleep(enabled: bool = true) -> void:
	sleep_enabled = enabled
	wake()
	_sync_sleep_texture()

func rest_now() -> void:
	if sleep_enabled and _sleep_texture != null:
		idle_seconds = SLEEP_AFTER+1.0

func wake() -> void:
	idle_seconds = 0.0

func _input(event: InputEvent) -> void:
	if not sleep_enabled or target_sprite == null or not target_sprite.is_visible_in_tree():
		return
	if event is InputEventMouseMotion and event.relative.length() > 2:
		if idle_seconds < SLEEP_AFTER and sleep_blend < 0.01:
			wake()
		return
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed) or (event is InputEventScreenTouch and event.pressed) or event is InputEventScreenDrag:
		wake()

func _sync_sleep_texture() -> void:
	_sleep_texture = null
	if sleep_enabled and _is_dragon_texture:
		var path := "res://assets/textures/dragons/sleeping/%s.png" % _species_key
		if ResourceLoader.exists(path):
			_sleep_texture = load(path)
			_ground_pair = SLEEP_GROUND[_species_key]
	if sleep_pose == null and sleep_enabled:
		sleep_pose = TextureRect.new()
		sleep_pose.name = "SleepingPose"
		sleep_pose.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sleep_pose.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sleep_pose.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(sleep_pose)
	if sleep_pose != null:
		sleep_pose.texture = _sleep_texture
		sleep_pose.visible = _sleep_texture != null and sleep_blend > 0

func _update_rest(delta: float) -> void:
	if sleep_enabled and _sleep_texture != null:
		idle_seconds += delta
	else:
		idle_seconds = 0.0
	var goal := 1.0 if idle_seconds >= SLEEP_AFTER else 0.0
	sleep_blend = move_toward(sleep_blend,goal,delta/(1.3 if goal > sleep_blend else 0.45))
	var drowsy := smoothstep(DROWSY_AFTER,SLEEP_AFTER,idle_seconds) if sleep_enabled else 0.0
	shader_mat.set_shader_parameter("awake_opacity",1.0-sleep_blend)
	shader_mat.set_shader_parameter("drowsiness",drowsy)
	if sleep_pose != null:
		sleep_time += delta
		sleep_pose.visible = sleep_blend > 0 and _sleep_texture != null
		sleep_pose.size = target_sprite.size
		var image_side := minf(target_sprite.size.x,target_sprite.size.y)
		sleep_pose.position = Vector2(0,(_ground_pair.x-_ground_pair.y)*image_side)
		sleep_pose.pivot_offset = Vector2(target_sprite.size.x*0.5,(target_sprite.size.y-image_side)*0.5+image_side*_ground_pair.y)
		var breath := sin(sleep_time*1.7)
		sleep_pose.scale = Vector2(1.0+breath*0.003,1.0+breath*0.016)
		sleep_pose.flip_h = target_sprite.flip_h
		sleep_pose.modulate.a = sleep_blend


const RIG := {
 "fire": [Vector2(0.385,0.43),Vector2(0.795,0.49),Vector4(0.61,0.369,0.055,0.038),Vector4(0.790,0.350,0.023,0.034)],
 "shadow": [Vector2(0.375,0.44),Vector2(0.752,0.48),Vector4(0.589,0.382,0.053,0.037),Vector4(0.765,0.355,0.022,0.031)],
 "fire_shadow": [Vector2(0.423,0.40),Vector2(0.79,0.45),Vector4(0.651,0.338,0.048,0.034),Vector4(0.811,0.315,0.021,0.028)],
 "fire_water": [Vector2(0.26,0.49),Vector2(0.575,0.515),Vector4(0.277,0.373,0.023,0.033),Vector4(0.444,0.371,0.050,0.037)],
 "triple": [Vector2(0.265,0.425),Vector2(0.64,0.44),Vector4(0.337,0.356,0.024,0.032),Vector4(0.462,0.350,0.043,0.035)],
 "water": [Vector2.ZERO,Vector2.ZERO,Vector4(0.205,0.370,0.018,0.030),Vector4(0.359,0.372,0.048,0.036)],
 "water_shadow": [Vector2.ZERO,Vector2.ZERO,Vector4(0.244,0.350,0.018,0.028),Vector4(0.388,0.366,0.050,0.033)]
}
const TAIL_REGIONS := {
 "fire":Vector4(0.15,0.75,0.14,0.14),
 "shadow":Vector4(0.17,0.77,0.14,0.12),
 "fire_shadow":Vector4(0.16,0.73,0.14,0.14),
 "fire_water":Vector4(0.83,0.73,0.14,0.16),
 "triple":Vector4(0.83,0.76,0.14,0.12),
 "water":Vector4(0.83,0.66,0.14,0.20),
 "water_shadow":Vector4(0.83,0.66,0.14,0.20)
}
const FLAME_TIPS := {
 "fire": [Vector2(0.54,0.075),Vector2(0.10,0.59)],
 "fire_shadow": [Vector2(0.31,0.18),Vector2(0.115,0.56)],
 "fire_water": [Vector2(0.46,0.085)],
 "triple": [Vector2(0.27,0.17)],
 "shadow": [],"water": [],"water_shadow": []
}

## Dữ liệu tọa độ UV mắt, cánh và điểm phát lửa trên cơ thể cho từng loài rồng
const SPECIES_CONFIG := {
 "fire": {"eyelid":Color("f58a47"),"flame_core":Color("fff078"),"flame_edge":Color("ff5b1f")},
 "fire_shadow": {"eyelid":Color("654258"),"flame_core":Color("ffe869"),"flame_edge":Color("ff4726")},
 "shadow": {"eyelid":Color("554568"),"flame_core":Color("e0b0ff"),"flame_edge":Color("9b3dff")},
 "triple": {"eyelid":Color("eee7f5"),"flame_core":Color("fff184"),"flame_edge":Color("ff6229")},
 "fire_water": {"eyelid":Color("f3dfcf"),"flame_core":Color("fff07a"),"flame_edge":Color("ff5c26")},
 "water": {"eyelid":Color("c8ece0"),"flame_core":Color("b8ffff"),"flame_edge":Color("24d4ff")},
 "water_shadow": {"eyelid":Color("bce5f5"),"flame_core":Color("9ef6ff"),"flame_edge":Color("8e54ff")}
}

static func attach(sprite: TextureRect, custom_phase: float = -1.0) -> DragonAnimator:
	if sprite == null:
		return null
	var existing := sprite.get_node_or_null("DragonAnimator") as DragonAnimator
	if existing != null:
		existing._sync_species_from_texture()
		return existing
	var animator := DragonAnimator.new()
	animator.name = "DragonAnimator"
	animator.setup_for_sprite(sprite, custom_phase)
	sprite.add_child(animator)
	return animator

func setup_for_sprite(sprite: TextureRect, custom_phase: float = -1.0) -> void:
	target_sprite = sprite
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false

	if custom_phase >= 0.0:
		_phase_offset = custom_phase
	else:
		_phase_offset = fmod(float( abs(get_instance_id()) % 1000 ) * 0.137, TAU)

	_time = _phase_offset
	_rng.randomize()
	_blink_timer = _rng.randf_range(3.5,7.0)
	_gaze_timer = _rng.randf_range(8.0,14.0)

	if _shared_shader == null:
		_shared_shader = IDLE_SHADER

	shader_mat = ShaderMaterial.new()
	shader_mat.shader = _shared_shader
	_sync_species_from_texture()

func _sync_species_from_texture() -> void:
	if target_sprite == null:
		return
	_last_texture = target_sprite.texture
	if _last_texture == null:
		_is_dragon_texture = false
		target_sprite.material = null
		sleep_blend = 0.0
		_sync_sleep_texture()
		queue_redraw()
		return

	var path := _last_texture.resource_path
	# Chỉ áp dụng chuyển động rồng cho các texture rồng trong thư mục dragons/
	if not ("/dragons/" in path or "\\dragons\\" in path):
		_is_dragon_texture = false
		target_sprite.material = null
		sleep_blend = 0.0
		_sync_sleep_texture()
		queue_redraw()
		return

	var file_stem := path.get_file().get_basename()
	if not SPECIES_CONFIG.has(file_stem):
		_is_dragon_texture = false
		target_sprite.material = null
		return
	_species_key = file_stem
	_is_dragon_texture = true
	target_sprite.material = shader_mat

	var cfg: Dictionary = SPECIES_CONFIG[_species_key]
	var rig: Array = RIG[_species_key]
	shader_mat.set_shader_parameter("source_art",_last_texture)
	shader_mat.set_shader_parameter("motion_mask",load("res://assets/textures/dragons/motion/%s_mask.svg" % _species_key))
	shader_mat.set_shader_parameter("eye1_rect",rig[2])
	shader_mat.set_shader_parameter("eye2_rect",rig[3])
	shader_mat.set_shader_parameter("eyelid_color",cfg.eyelid)
	shader_mat.set_shader_parameter("left_hinge",rig[0])
	shader_mat.set_shader_parameter("right_hinge",rig[1])
	shader_mat.set_shader_parameter("wing_amplitude",0.18)
	shader_mat.set_shader_parameter("tail_region",TAIL_REGIONS[_species_key])
	shader_mat.set_shader_parameter("aquatic",_species_key in ["water","water_shadow"])
	shader_mat.set_shader_parameter("flame_core_color",cfg.flame_core)
	shader_mat.set_shader_parameter("flame_edge_color",cfg.flame_edge)
	shader_mat.set_shader_parameter("anim_time",_time)
	shader_mat.set_shader_parameter("blink_amount",0.0)
	_blink_elapsed = -1.0
	_double_blink_pending = false
	_blink_timer = _rng.randf_range(4.0,8.0)
	_gaze = Vector2.ZERO
	_gaze_target = Vector2.ZERO
	idle_seconds = 0.0
	sleep_blend = 0.0
	_sync_sleep_texture()
	queue_redraw()

func _process(delta: float) -> void:
	if target_sprite == null:
		return
	if target_sprite.texture != _last_texture:
		_sync_species_from_texture()
	if not _is_dragon_texture or not target_sprite.is_visible_in_tree() or target_sprite.modulate.a < 0.45:
		return

	_update_rest(delta)
	_time += delta
	shader_mat.set_shader_parameter("anim_time", _time)

	_gaze_timer -= delta
	if _gaze_timer <= 0:
		_gaze_target = Vector2(_rng.randf_range(-0.0012,0.0012),_rng.randf_range(-0.0006,0.0006))
		_gaze_timer = _rng.randf_range(8.0,15.0)
	_gaze = _gaze.lerp(_gaze_target,1.0-exp(-delta*4.0))
	shader_mat.set_shader_parameter("gaze",_gaze)
	var blink_val := 0.0
	if _blink_elapsed >= 0.0:
		_blink_elapsed += delta
		# 45 ms close, 25 ms hold, 110 ms reopen: blink never loops indefinitely.
		if _blink_elapsed < 0.045:
			blink_val = smoothstep(0.0,0.045,_blink_elapsed)
		elif _blink_elapsed < 0.070:
			blink_val = 1.0
		elif _blink_elapsed < 0.180:
			blink_val = 1.0-smoothstep(0.070,0.180,_blink_elapsed)
		else:
			_blink_elapsed = -1.0
			_blink_cycle_count += 1
			_blink_timer = 0.18 if _double_blink_pending else _rng.randf_range(5.5,11.0)
			_double_blink_pending = false
	else:
		_blink_timer -= delta
		if _blink_timer <= 0:
			_blink_elapsed = 0.0
			# A short scheduled follow-up must not schedule another follow-up.
			_double_blink_pending = _blink_timer > -delta*1.5 and _rng.randf() < 0.06 and _blink_cycle_count % 2 == 0
	shader_mat.set_shader_parameter("blink_amount",maxf(blink_val,smoothstep(DROWSY_AFTER,SLEEP_AFTER,idle_seconds)*0.85 if sleep_enabled else 0.0))
	if sleep_enabled or not FLAME_TIPS[_species_key].is_empty():
		queue_redraw()

func _draw() -> void:
	if not _is_dragon_texture or target_sprite == null or target_sprite.texture == null:
		return
	# Khi rồng bị hạ gục (mờ đi trong trận), giảm hiệu ứng lửa
	if target_sprite.modulate.a < 0.45:
		return

	if sleep_blend > 0.65:
		var font := ThemeDB.fallback_font
		for i in range(3):
			var phase := fmod(sleep_time*0.28+i*0.33,1.0)
			var point := Vector2(target_sprite.size.x*0.67+phase*25,target_sprite.size.y*(0.48-phase*0.25))
			draw_string(font,point,"z",HORIZONTAL_ALIGNMENT_LEFT,-1,16+int(phase*10),Color(0.75,0.9,1.0,sin(phase*PI)*sleep_blend*0.85))
		return
	var rect_size := target_sprite.size
	var side := minf(rect_size.x, rect_size.y)
	if side < 42.0:
		return
	var origin := Vector2((rect_size.x - side) * 0.5, (rect_size.y - side) * 0.5)
	var scale_factor := side / 280.0
	var flipped := target_sprite.flip_h

	var cfg: Dictionary = SPECIES_CONFIG.get(_species_key, SPECIES_CONFIG["fire"])
	var core_col: Color = cfg["flame_core"]
	var edge_col: Color = cfg["flame_edge"]
	var anchors: Array = FLAME_TIPS[_species_key]
	for i in range(anchors.size()):
		var uv_pt: Vector2 = anchors[i]
		var nx := (1.0-uv_pt.x) if flipped else uv_pt.x
		var base := origin+Vector2(nx*side,uv_pt.y*side)
		var phase := _time*4.0+i*2.4
		var height := (27+8*sin(phase)+4*sin(phase*1.73))*scale_factor
		var width := 4.8*scale_factor
		_draw_living_flame_tongue(base,width,height,sin(phase)*7.0*scale_factor,core_col,edge_col,phase)
		var travel := fmod(_time*0.38+i*0.41,1.0)
		var spark := base+Vector2(sin(phase+travel*4)*4,-travel*24)*scale_factor
		draw_circle(spark,0.8*scale_factor,Color(core_col.r,core_col.g,core_col.b,sin(travel*PI)*0.48))

func _draw_living_flame_tongue(base: Vector2, half_w: float, height: float, tip_sway: float, core_col: Color, edge_col: Color, phase: float) -> void:
	# Curved silhouette with a tapered tip and a smaller, delayed inner core.
	for layer in range(2):
		var points := PackedVector2Array()
		var factor := 1.0 if layer == 0 else 0.57
		for side_sign in [-1.0,1.0]:
			for j in range(13):
				if side_sign > 0 and j == 0:
					continue
				var t := j/12.0 if side_sign < 0 else 1.0-j/12.0
				var taper := pow(1.0-t,0.7)
				var bend := sin(t*2.4+phase)*t*t*tip_sway
				points.append(base+Vector2(bend+side_sign*half_w*taper,-height*t)*factor)
		var color := edge_col if layer == 0 else core_col
		color.a = (0.40 if layer == 0 else 0.65)*(1.0-sleep_blend)
		draw_colored_polygon(points,color)
