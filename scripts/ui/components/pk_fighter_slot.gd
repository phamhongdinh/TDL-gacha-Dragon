class_name PkFighterSlot
extends Control

## Thành phần hiển thị 1 rồng trên sàn đấu PK 3v3.
## Giữ nguyên tỉ lệ gốc của rồng (STRETCH_KEEP_ASPECT_CENTERED, không cắt đầu/cánh/đuôi),
## kèm vòng chân đế nguyên tố, biểu tượng hệ, thanh HP và số sát thương nổi.

signal fighter_clicked(fighter_id: String)

var fighter_id: String = ""
var display_name: String = ""
var team_side: String = "player" # "player" | "enemy"
var element_key: String = "fire" # "water" | "fire" | "triple" | "ice" | "earth" | "shadow"
var max_hp: int = 5820
var hp: int = 5820
var max_energy: int = 200
var energy: int = 100
var attack_stat: int = 1480
var defense_stat: int = 320
var speed_stat: int = 90
var is_active_turn: bool = false
var is_selected: bool = false
var is_targeted: bool = false
var placeholder_note: String = ""

var visual_root: Control
var dragon_sprite: TextureRect
var hud_holder: Control
var hp_bar: ProgressBar
var hp_label: Label
var damage_label: Label
var badge_drawer: Control
var click_area: Button

var base_sprite_pos: Vector2 = Vector2.ZERO
var anim_offset: Vector2 = Vector2.ZERO
var bob_phase: float = 0.0
var time_accum: float = 0.0
var hit_effect_timer: float = 0.0

func _init() -> void:
	clip_contents = false
	mouse_filter = Control.MOUSE_FILTER_PASS

func setup(data: Dictionary) -> void:
	fighter_id = String(data.get("id", "fighter"))
	display_name = String(data.get("name", "Rồng"))
	team_side = String(data.get("side", "player"))
	element_key = String(data.get("element", "fire"))
	max_hp = int(data.get("max_hp", 5820))
	hp = int(data.get("hp", max_hp))
	max_energy = int(data.get("max_energy", 200))
	energy = int(data.get("energy", 100))
	attack_stat = int(data.get("attack", 1500))
	defense_stat = int(data.get("defense", 300))
	speed_stat = int(data.get("speed", 90))
	placeholder_note = String(data.get("placeholder_note", ""))
	bob_phase = float(data.get("bob_phase", 0.0))

	var box_size: Vector2 = data.get("slot_size", Vector2(230, 220))
	custom_minimum_size = box_size
	size = box_size

	_build_nodes(data)
	refresh_ui()

func _build_nodes(data: Dictionary) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	visual_root = Control.new()
	visual_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visual_root.clip_contents = false
	visual_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual_root)

	# 1. Sprite rồng: dùng STRETCH_KEEP_ASPECT_CENTERED và khung rộng để không cắt đầu, cánh hoặc đuôi
	dragon_sprite = TextureRect.new()
	var tex_path := String(data.get("texture_path", "res://assets/textures/dragons/fire.png"))
	if ResourceLoader.exists(tex_path):
		dragon_sprite.texture = load(tex_path)
	dragon_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dragon_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dragon_sprite.flip_h = bool(data.get("flip_h", false))
	dragon_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Không bao giờ tự ý đổi màu gốc của sprite
	dragon_sprite.self_modulate = Color.WHITE

	var sprite_size: Vector2 = data.get("sprite_size", Vector2(210, 175))
	base_sprite_pos = Vector2((size.x - sprite_size.x) * 0.5, size.y - sprite_size.y - 8.0)
	dragon_sprite.position = base_sprite_pos
	dragon_sprite.size = sprite_size
	visual_root.add_child(dragon_sprite)
	dragon_sprite.set_deferred("size", sprite_size)

	# 2. Thanh HP và biểu tượng hệ phía trên đầu rồng
	hud_holder = Control.new()
	hud_holder.position = Vector2((size.x - 156.0) * 0.5, -6.0)
	hud_holder.size = Vector2(156, 36)
	hud_holder.clip_contents = false
	hud_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual_root.add_child(hud_holder)

	# Khung nền thanh HP
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color("0d222d")
	bar_bg.border_color = Color("d8b76c")
	bar_bg.set_border_width_all(1)
	bar_bg.set_corner_radius_all(4)

	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color("39d454")
	bar_fill.set_border_width_all(0)
	bar_fill.set_corner_radius_all(3)

	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(26, 19)
	hp_bar.custom_minimum_size = Vector2(124, 10)
	hp_bar.size = Vector2(124, 10)
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar.add_theme_font_size_override("font_size", 1)
	hp_bar.add_theme_stylebox_override("background", bar_bg)
	hp_bar.add_theme_stylebox_override("fill", bar_fill)
	hud_holder.add_child(hp_bar)
	hp_bar.set_deferred("size", Vector2(124, 10))

	hp_label = Label.new()
	hp_label.position = Vector2(26, 0)
	hp_label.size = Vector2(126, 18)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 13)
	hp_label.add_theme_color_override("font_color", Color("f7fbff"))
	hp_label.add_theme_color_override("font_outline_color", Color("07131c"))
	hp_label.add_theme_constant_override("outline_size", 4)
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_holder.add_child(hp_label)

	# Huy hiệu biểu tượng hệ bên trái thanh HP
	badge_drawer = Control.new()
	badge_drawer.position = Vector2(0, 8)
	badge_drawer.size = Vector2(30, 30)
	badge_drawer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_drawer.draw.connect(_draw_element_badge)
	hud_holder.add_child(badge_drawer)

	# 3. Nhãn sát thương nổi (-1640)
	damage_label = Label.new()
	damage_label.position = Vector2((size.x - 160.0) * 0.5, -42.0)
	damage_label.size = Vector2(160, 36)
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.add_theme_font_size_override("font_size", 28)
	damage_label.add_theme_color_override("font_color", Color("ff5924"))
	damage_label.add_theme_color_override("font_outline_color", Color("240804"))
	damage_label.add_theme_constant_override("outline_size", 7)
	damage_label.visible = false
	damage_label.z_index = 12
	damage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual_root.add_child(damage_label)

	# 4. Nút tương tác chọn rồng để xem thông tin hoặc chọn mục tiêu
	click_area = Button.new()
	click_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_area.flat = true
	click_area.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var tip := "%s (%s)\nHP: %d / %d  |  Năng lượng: %d / %d" % [display_name, element_key.to_upper(), hp, max_hp, energy, max_energy]
	if not placeholder_note.is_empty():
		tip += "\n[Placeholder: %s]" % placeholder_note
	click_area.tooltip_text = tip
	click_area.pressed.connect(func(): fighter_clicked.emit(fighter_id))
	add_child(click_area)

func set_dragon_texture(texture: Texture2D, flip_horizontal: bool = false) -> void:
	if dragon_sprite != null:
		dragon_sprite.texture = texture
		dragon_sprite.flip_h = flip_horizontal
		dragon_sprite.self_modulate = Color.WHITE

func refresh_ui() -> void:
	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
	if hp_label != null:
		hp_label.text = "%d / %d" % [hp, max_hp]
	if dragon_sprite != null:
		dragon_sprite.modulate.a = 1.0 if hp > 0 else 0.32
	if click_area != null:
		var tip := "%s\nHP: %d / %d  |  Năng lượng: %d / %d" % [display_name, hp, max_hp, energy, max_energy]
		if not placeholder_note.is_empty():
			tip += "\n[Ghi chú: %s]" % placeholder_note
		click_area.tooltip_text = tip
	if badge_drawer != null:
		badge_drawer.queue_redraw()
	queue_redraw()

func show_floating_damage(amount: int, is_heal: bool = false, duration: float = 1.15) -> void:
	if damage_label == null:
		return
	damage_label.visible = true
	damage_label.scale = Vector2.ONE
	damage_label.position = Vector2((size.x - 160.0) * 0.5, -38.0)
	damage_label.modulate.a = 1.0
	if is_heal:
		damage_label.text = "+%d" % amount
		damage_label.add_theme_color_override("font_color", Color("57f287"))
	else:
		damage_label.text = "-%d" % amount
		damage_label.add_theme_color_override("font_color", Color("ff5c28"))
		hit_effect_timer = 0.55
	var tw := create_tween()
	tw.tween_property(damage_label, "position:y", -62.0, duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(damage_label, "modulate:a", 0.0, duration * 0.45).set_delay(duration * 0.55)
	tw.tween_callback(func():
		if is_instance_valid(damage_label):
			damage_label.visible = false
	)

func show_static_damage_banner(amount: int) -> void:
	if damage_label == null:
		return
	damage_label.text = "-%d" % amount
	damage_label.add_theme_color_override("font_color", Color("ff5c28"))
	damage_label.position = Vector2((size.x - 160.0) * 0.5, -42.0)
	damage_label.modulate.a = 1.0
	damage_label.visible = true
	hit_effect_timer = 0.95

func get_center_global_or_local() -> Vector2:
	return position + Vector2(size.x * 0.5, size.y * 0.58)

func _process(delta: float) -> void:
	time_accum += delta
	if hit_effect_timer > 0.0:
		hit_effect_timer = maxf(0.0, hit_effect_timer - delta)
	if dragon_sprite != null and hp > 0:
		var bob := sin(time_accum * 2.6 + bob_phase) * 4.0
		dragon_sprite.position = base_sprite_pos + Vector2(0, bob) + anim_offset
	queue_redraw()

func _draw() -> void:
	# Vẽ vòng sáng chân đế dưới chân rồng + hiệu ứng đến lượt / mục tiêu bị tấn công
	var foot_center := Vector2(size.x * 0.5, size.y - 18.0) + anim_offset
	var rx := size.x * 0.36
	var ry := 18.0

	var ring_color := Color("3ce8f5") if team_side == "player" else Color("f0a83e")
	if is_active_turn:
		ring_color = Color("ff8c2b") if element_key == "fire" else Color("ffe268")
	elif is_selected:
		ring_color = Color("7affd8")

	# Quầng sáng nền
	_draw_oval(foot_center, rx * 1.12, ry * 1.15, Color(ring_color.r, ring_color.g, ring_color.b, 0.16), Color(ring_color.r, ring_color.g, ring_color.b, 0.45), 1.8)
	_draw_oval(foot_center, rx * 0.88, ry * 0.86, Color(ring_color.r, ring_color.g, ring_color.b, 0.22), ring_color, 2.6)

	# Hiệu ứng rồng đang đến lượt hành động
	if is_active_turn and hp > 0:
		var pulse := 1.0 + 0.08 * sin(time_accum * 6.0)
		_draw_oval(foot_center, rx * 1.24 * pulse, ry * 1.28 * pulse, Color(1.0, 0.62, 0.18, 0.10), Color(1.0, 0.84, 0.38, 0.85), 2.5)
		for i in range(6):
			var ang := time_accum * 2.5 + i * TAU / 6.0
			var spark := foot_center + Vector2(cos(ang) * rx * 1.05, sin(ang) * ry * 1.05 - 10.0)
			draw_circle(spark, 3.2, Color("ffea88"))

	# Hiệu ứng mục tiêu đang bị tấn công (Target Lock + Tia va chạm)
	if is_targeted or hit_effect_timer > 0.0:
		var body_center := Vector2(size.x * 0.5, size.y * 0.55) + anim_offset
		var alpha := clampf(hit_effect_timer * 1.6, 0.35, 1.0) if hit_effect_timer > 0.0 else 0.75
		draw_arc(body_center, 54.0, 0, TAU, 36, Color(1.0, 0.42, 0.18, alpha * 0.75), 2.5)
		for i in range(8):
			var ang := i * TAU / 8.0 + time_accum * 3.0
			var p1 := body_center + Vector2.from_angle(ang) * 18.0
			var p2 := body_center + Vector2.from_angle(ang) * 58.0
			draw_line(p1, p2, Color(1.0, 0.82, 0.38, alpha * 0.85), 2.4, true)

func _draw_oval(center: Vector2, rx: float, ry: float, fill: Color, stroke: Color, width: float) -> void:
	var pts := PackedVector2Array()
	for i in range(49):
		var a := i * TAU / 48.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, fill)
	draw_polyline(pts, stroke, width, true)

func _draw_element_badge() -> void:
	var c := Vector2(15, 15)
	var r := 13.0
	var bg_col := Color("183848")
	match element_key:
		"water":
			bg_col = Color("1968b8")
		"fire":
			bg_col = Color("c83e1b")
		"triple":
			bg_col = Color("292442")
		"ice":
			bg_col = Color("1b78b8")
		"earth":
			bg_col = Color("8c6422")
		"shadow", "moon":
			bg_col = Color("43296b")

	badge_drawer.draw_circle(c, r + 1.5, Color("e6c878"))
	badge_drawer.draw_circle(c, r, bg_col)

	match element_key:
		"water":
			var drop := PackedVector2Array([
				c + Vector2(0, -8),
				c + Vector2(6, 2),
				c + Vector2(4, 7),
				c + Vector2(0, 9),
				c + Vector2(-4, 7),
				c + Vector2(-6, 2)
			])
			badge_drawer.draw_colored_polygon(drop, Color("7eeeff"))
		"fire":
			var flame := PackedVector2Array([
				c + Vector2(0, -9),
				c + Vector2(6, -1),
				c + Vector2(5, 6),
				c + Vector2(0, 9),
				c + Vector2(-5, 6),
				c + Vector2(-6, -1)
			])
			badge_drawer.draw_colored_polygon(flame, Color("ffd15c"))
			badge_drawer.draw_circle(c + Vector2(0, 3), 3.2, Color("ff5d22"))
		"triple":
			badge_drawer.draw_circle(c + Vector2(-4, -3), 4.2, Color("ff6238"))
			badge_drawer.draw_circle(c + Vector2(4, -3), 4.2, Color("45e3ff"))
			badge_drawer.draw_circle(c + Vector2(0, 4), 4.2, Color("ffd859"))
		"ice":
			for i in range(3):
				var a := i * PI / 3.0
				var d := Vector2.from_angle(a) * 7.5
				badge_drawer.draw_line(c - d, c + d, Color("d9f8ff"), 2.0, true)
			badge_drawer.draw_circle(c, 2.5, Color.WHITE)
		"earth":
			var m1 := PackedVector2Array([c + Vector2(-8, 6), c + Vector2(-2, -6), c + Vector2(5, 6)])
			var m2 := PackedVector2Array([c + Vector2(-1, 6), c + Vector2(4, -3), c + Vector2(9, 6)])
			badge_drawer.draw_colored_polygon(m1, Color("f5d27a"))
			badge_drawer.draw_colored_polygon(m2, Color("d4a84e"))
		_:
			# Biểu tượng Nguyệt / Bóng Tối
			badge_drawer.draw_circle(c, 6.8, Color("ffd86b"))
			badge_drawer.draw_circle(c + Vector2(3.0, -2.0), 5.6, bg_col)
