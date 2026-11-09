class_name PkSkillButton
extends Control

## Nút kỹ năng tròn trong bảng điều khiển phía dưới màn PK:
## - "KỸ NĂNG" (vòng xoáy nguyên tố)
## - "TUYỆT KỸ" (ngôi sao bùng nổ ánh kim)
## - "HỖ TRỢ" (hoa sen lục bảo hồi phục)
## Tự động làm mờ (dimmed) khi rồng chưa đủ năng lượng.

signal skill_activated(skill_kind: String)

var skill_kind: String = "skill" # "skill" | "ultimate" | "support"
var title_text: String = "KỸ NĂNG"
var energy_cost: int = 0
var has_enough_energy: bool = true
var can_trigger: bool = true
var hovered: bool = false
var time_accum: float = 0.0

var trigger_btn: Button
var cost_label: Label
var title_label: Label

func setup(kind: String, title: String, cost: int, button_size: Vector2 = Vector2(126, 128)) -> void:
	skill_kind = kind
	title_text = title
	energy_cost = cost
	custom_minimum_size = button_size
	size = button_size
	clip_contents = false

	for child in get_children():
		remove_child(child)
		child.queue_free()

	title_label = Label.new()
	title_label.text = title_text
	title_label.position = Vector2(4, button_size.y - 30)
	title_label.size = Vector2(button_size.x - 8, 24)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.add_theme_color_override("font_color", Color("fff6dc"))
	title_label.add_theme_color_override("font_outline_color", Color("0c1c24"))
	title_label.add_theme_constant_override("outline_size", 4)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_label)

	cost_label = Label.new()
	cost_label.position = Vector2(8, button_size.y * 0.34)
	cost_label.size = Vector2(button_size.x - 16, 22)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 11)
	cost_label.add_theme_color_override("font_color", Color("ffd4c2"))
	cost_label.add_theme_color_override("font_outline_color", Color("050d14"))
	cost_label.add_theme_constant_override("outline_size", 5)
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_label)

	trigger_btn = Button.new()
	trigger_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trigger_btn.flat = true
	trigger_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	trigger_btn.mouse_entered.connect(func():
		hovered = true
		queue_redraw()
	)
	trigger_btn.mouse_exited.connect(func():
		hovered = false
		queue_redraw()
	)
	trigger_btn.pressed.connect(func():
		if has_enough_energy and can_trigger:
			skill_activated.emit(skill_kind)
	)
	add_child(trigger_btn)
	_refresh_state()

func set_energy_state(current_energy: int, allow_act: bool = true) -> void:
	has_enough_energy = current_energy >= energy_cost
	can_trigger = allow_act and has_enough_energy
	_refresh_state()

func _refresh_state() -> void:
	if trigger_btn != null:
		trigger_btn.disabled = not can_trigger
		trigger_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if can_trigger else Control.CURSOR_FORBIDDEN
		if energy_cost > 0:
			trigger_btn.tooltip_text = "%s (Yêu cầu %d Năng lượng)%s" % [
				title_text,
				energy_cost,
				" — Sẵn sàng kích hoạt!" if has_enough_energy else " — Chưa đủ năng lượng"
			]
		else:
			trigger_btn.tooltip_text = "%s (Không tốn năng lượng, hồi +60 Năng lượng)" % title_text

	if cost_label != null:
		if not has_enough_energy and energy_cost > 0:
			cost_label.text = "%d NL" % energy_cost
			cost_label.visible = true
		else:
			cost_label.visible = false

	# Trạng thái làm mờ rõ ràng khi chưa đủ năng lượng
	modulate = Color.WHITE if has_enough_energy else Color(0.45, 0.49, 0.55, 0.78)
	queue_redraw()

func _process(delta: float) -> void:
	time_accum += delta
	if skill_kind == "ultimate" and has_enough_energy:
		queue_redraw()

func _draw() -> void:
	var c := Vector2(size.x * 0.5, size.y * 0.43)
	var r := 43.0 if skill_kind != "ultimate" else 47.0

	# Quầng sáng mặt trời cho TUYỆT KỸ khi đủ năng lượng
	if skill_kind == "ultimate" and has_enough_energy:
		var pulse := 1.0 + 0.06 * sin(time_accum * 4.5)
		draw_circle(c, (r + 12.0) * pulse, Color(1.0, 0.82, 0.32, 0.24))
		for i in range(16):
			var ang := i * TAU / 16.0 + time_accum * 0.35
			var p_in := c + Vector2.from_angle(ang) * (r + 1.0)
			var p_out := c + Vector2.from_angle(ang) * (r + (11.0 if i % 2 == 0 else 6.0) * pulse)
			var left := c + Vector2.from_angle(ang - 0.09) * (r + 2.0)
			var right := c + Vector2.from_angle(ang + 0.09) * (r + 2.0)
			draw_colored_polygon(PackedVector2Array([left, p_out, right]), Color("ffd86e"))

	# Viền vàng kim
	var ring_col := Color("ffe38f") if (hovered and has_enough_energy) else Color("d8b467")
	draw_circle(c, r + 4.0, Color("0a1d26"))
	draw_circle(c, r + 2.5, ring_col)
	draw_circle(c, r - 1.5, Color("112736"))

	match skill_kind:
		"skill":
			# Vòng xoáy tam nguyên tố (KỸ NĂNG)
			draw_circle(c, r - 3.0, Color("142442"))
			var swirl_cols := [Color("37d8ff"), Color("ff7b29"), Color("d855ff")]
			for i in range(3):
				var a := i * TAU / 3.0 + 0.4
				var orb_c := c + Vector2.from_angle(a) * 14.0
				draw_circle(orb_c, 16.0, swirl_cols[i])
				draw_arc(c, 26.0, a, a + 1.7, 20, swirl_cols[i].lightened(0.25), 5.0, true)
			draw_circle(c, 7.0, Color("fff5d6"))
		"ultimate":
			# Ngôi sao bùng nổ 8 cánh (TUYỆT KỸ)
			draw_circle(c, r - 3.0, Color("2e1b4e"))
			draw_circle(c, r - 11.0, Color("633296"))
			for i in range(8):
				var ang := i * TAU / 8.0
				var tip_len := (r - 4.0) if i % 2 == 0 else (r - 13.0)
				var tip := c + Vector2.from_angle(ang) * tip_len
				var s1 := c + Vector2.from_angle(ang - 0.24) * 10.0
				var s2 := c + Vector2.from_angle(ang + 0.24) * 10.0
				draw_colored_polygon(PackedVector2Array([s1, tip, s2]), Color("ffe680") if i % 2 == 0 else Color("ff9ef5"))
			draw_circle(c, 9.0, Color.WHITE)
		"support":
			# Hoa sen lục bảo + chữ thập hồi phục (HỖ TRỢ)
			draw_circle(c, r - 3.0, Color("0d382e"))
			draw_circle(c, r - 12.0, Color("18634c"))
			for p in [-0.65, -0.32, 0.0, 0.32, 0.65]:
				var tip := c + Vector2(sin(p) * 24.0, 12.0 - cos(p) * 22.0)
				var base_l := c + Vector2(sin(p) * 8.0 - 7.0, 20.0)
				var base_r := c + Vector2(sin(p) * 8.0 + 7.0, 20.0)
				draw_colored_polygon(PackedVector2Array([base_l, tip, base_r]), Color("66ffaa"))
			for cross_pos in [c + Vector2(-14, -14), c + Vector2(14, -14), c + Vector2(0, -22)]:
				draw_rect(Rect2(cross_pos.x - 1.5, cross_pos.y - 5.0, 3.0, 10.0), Color("d4ffea"))
				draw_rect(Rect2(cross_pos.x - 5.0, cross_pos.y - 1.5, 10.0, 3.0), Color("d4ffea"))

	# Lớp phủ tối khi chưa đủ năng lượng
	if not has_enough_energy:
		draw_circle(c, r - 1.5, Color(0.03, 0.06, 0.10, 0.45))

	# Bảng tên kỹ năng phía dưới vòng tròn
	var plate_rect := Rect2(8.0, size.y - 31.0, size.x - 16.0, 25.0)
	var plate_pts := PackedVector2Array([
		Vector2(plate_rect.position.x + 8, plate_rect.position.y),
		Vector2(plate_rect.end.x - 8, plate_rect.position.y),
		Vector2(plate_rect.end.x, plate_rect.position.y + plate_rect.size.y * 0.5),
		Vector2(plate_rect.end.x - 8, plate_rect.end.y),
		Vector2(plate_rect.position.x + 8, plate_rect.end.y),
		Vector2(plate_rect.position.x, plate_rect.position.y + plate_rect.size.y * 0.5)
	])
	var plate_bg := Color("2b2316") if (skill_kind == "ultimate" and has_enough_energy) else Color("102936")
	draw_colored_polygon(plate_pts, plate_bg)
	draw_polyline(plate_pts, ring_col, 2.0, true)
