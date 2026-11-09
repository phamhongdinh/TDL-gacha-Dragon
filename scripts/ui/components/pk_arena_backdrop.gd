class_name PkArenaBackdrop
extends Control

## Bối cảnh Đấu trường dưới lòng đất (Underground Dragon Arena).
## Vẽ cổng năng lượng xanh ngọc, cột đá cổ, đèn lồng, tinh thể và vòng tròn ma thuật
## kết hợp cùng nền hang động có sẵn trong project.

var time_accum: float = 0.0
var impact_flash: float = 0.0
var impact_pos: Vector2 = Vector2(640, 340)
var impact_color: Color = Color("ff7b39")
var attack_beam_alpha: float = 0.0
var attack_from: Vector2 = Vector2.ZERO
var attack_to: Vector2 = Vector2.ZERO
var attack_element: String = "fire"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cavern := TextureRect.new()
	cavern.texture = preload("res://assets/textures/home_cavern.svg")
	cavern.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cavern.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cavern.stretch_mode = TextureRect.STRETCH_SCALE
	cavern.modulate = Color(0.55, 0.72, 0.78, 0.45)
	cavern.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cavern)
	move_child(cavern, 0)

func _process(delta: float) -> void:
	time_accum += delta
	if impact_flash > 0.0:
		impact_flash = maxf(0.0, impact_flash - delta * 0.95)
	if attack_beam_alpha > 0.0:
		attack_beam_alpha = maxf(0.0, attack_beam_alpha - delta * 0.85)
	queue_redraw()

func trigger_clash(from_pos: Vector2, to_pos: Vector2, element: String) -> void:
	attack_from = from_pos
	attack_to = to_pos
	attack_element = element
	attack_beam_alpha = 1.0
	impact_pos = to_pos
	impact_flash = 1.0
	match element:
		"fire":
			impact_color = Color("ff7832")
		"water", "ice":
			impact_color = Color("52e5ff")
		"triple":
			impact_color = Color("ffe066")
		"earth":
			impact_color = Color("e0a958")
		_:
			impact_color = Color("c57bff")

func _draw() -> void:
	var w := size.x if size.x > 0 else 1280.0
	var h := size.y if size.y > 0 else 720.0
	var sx := w / 1280.0
	var sy := h / 720.0
	var s := minf(sx, sy)

	# 1. Nền hang động sâu xanh đen
	draw_rect(Rect2(0, 0, w, h), Color("071620"))
	for i in range(6):
		var ratio := float(i) / 5.0
		draw_circle(Vector2(w * 0.5, h * 0.34), (520.0 - i * 70.0) * s, Color(0.05, 0.25 + ratio * 0.12, 0.30 + ratio * 0.10, 0.14))

	# 2. Cổng năng lượng xanh ngọc ở trung tâm (Teal Energy Portal)
	var portal_center := Vector2(w * 0.5, h * 0.31)
	var portal_r := 124.0 * s
	# Viền đá cổ của cổng
	draw_arc(portal_center, portal_r + 22.0 * s, 0, TAU, 64, Color("16343f"), 28.0 * s)
	draw_arc(portal_center, portal_r + 22.0 * s, 0, TAU, 64, Color("57878f"), 2.0 * s)
	draw_arc(portal_center, portal_r + 8.0 * s, 0, TAU, 64, Color("c8a862"), 3.0 * s)
	# Các ô ký tự cổ trên vòng đá
	for i in range(16):
		var ang := i * TAU / 16.0
		var p1 := portal_center + Vector2.from_angle(ang) * (portal_r + 12.0 * s)
		var p2 := portal_center + Vector2.from_angle(ang) * (portal_r + 31.0 * s)
		draw_line(p1, p2, Color("294e5a"), 2.0 * s)
		var rune_pt := portal_center + Vector2.from_angle(ang + TAU / 32.0) * (portal_r + 21.0 * s)
		draw_circle(rune_pt, 2.5 * s, Color(0.45, 0.95, 0.88, 0.45 + 0.35 * sin(time_accum * 2.5 + i)))

	# Lõi xoáy năng lượng xanh ngọc
	for i in range(8, 0, -1):
		var r := portal_r * (float(i) / 8.0)
		var col := Color("092d38").lerp(Color("3bf0d8"), 1.0 - float(i) / 8.0)
		col.a = 0.26
		draw_circle(portal_center, r, col)
	for swirl in range(4):
		var base_ang := time_accum * 0.9 + swirl * (TAU / 4.0)
		draw_arc(portal_center, portal_r * (0.42 + swirl * 0.13), base_ang, base_ang + PI * 0.85, 32, Color(0.42, 0.98, 0.90, 0.38), 3.0 * s, true)
	# Ấn rồng phát sáng giữa cổng
	draw_arc(portal_center, portal_r * 0.32, -PI * 0.7, PI * 0.9, 28, Color(0.65, 1.0, 0.94, 0.55), 5.0 * s, true)

	# 3. Cột đá cổ hai bên & Cờ hiệu Long Tộc
	var pillar_xs := [w * 0.11, w * 0.27, w * 0.73, w * 0.89]
	for idx in range(pillar_xs.size()):
		var px: float = pillar_xs[idx]
		var pw := (68.0 if (idx == 0 or idx == 3) else 52.0) * sx
		var py := h * (0.06 if (idx == 0 or idx == 3) else 0.10)
		var ph := h * (0.44 if (idx == 0 or idx == 3) else 0.36)
		draw_rect(Rect2(px - pw * 0.5, py, pw, ph), Color("122a36"))
		draw_rect(Rect2(px - pw * 0.5, py, pw, ph), Color("2f525e"), false, 2.0 * s)
		# Chân cột
		draw_rect(Rect2(px - pw * 0.62, py + ph - 18.0 * sy, pw * 1.24, 18.0 * sy), Color("1b3a47"))
		draw_rect(Rect2(px - pw * 0.62, py + ph - 18.0 * sy, pw * 1.24, 18.0 * sy), Color("887348"), false, 1.5 * s)
		# Cờ treo trên 2 cột ngoài
		if idx == 0 or idx == 3:
			var bw := pw * 0.72
			var bh := ph * 0.52
			var bx := px - bw * 0.5
			var by := py + 42.0 * sy
			var banner_pts := PackedVector2Array([
				Vector2(bx, by),
				Vector2(bx + bw, by),
				Vector2(bx + bw, by + bh),
				Vector2(px, by + bh + 22.0 * sy),
				Vector2(bx, by + bh)
			])
			draw_colored_polygon(banner_pts, Color("4a2035") if idx == 0 else Color("3a1f42"))
			draw_polyline(banner_pts, Color("d4af63"), 2.0 * s, true)
			draw_circle(Vector2(px, by + bh * 0.48), 11.0 * s, Color(0.88, 0.72, 0.38, 0.55))

	# 4. Sàn đấu trường đá cổ & Vòng tròn ma thuật (Arena Floor & Magic Seal)
	var floor_center := Vector2(w * 0.5, h * 0.63)
	var floor_rx := 590.0 * sx
	var floor_ry := 175.0 * sy
	_draw_ellipse(floor_center, floor_rx, floor_ry, Color("132936"), Color("355866"), 2.5 * s)
	_draw_ellipse(floor_center, floor_rx * 0.80, floor_ry * 0.78, Color("17313f"), Color("b59452"), 2.2 * s)
	_draw_ellipse(floor_center, floor_rx * 0.52, floor_ry * 0.50, Color(0.08, 0.19, 0.25, 0.65), Color("d6b265"), 2.0 * s)

	# Đường khắc hoa văn trên mặt sàn đá
	for i in range(12):
		var ang := i * TAU / 12.0 + 0.15
		var inner_pt := floor_center + Vector2(cos(ang) * floor_rx * 0.25, sin(ang) * floor_ry * 0.25)
		var outer_pt := floor_center + Vector2(cos(ang) * floor_rx * 0.79, sin(ang) * floor_ry * 0.78)
		draw_line(inner_pt, outer_pt, Color(0.84, 0.69, 0.38, 0.32), 1.6 * s)
	# Đồ hình rồng vàng giữa sàn
	_draw_ellipse(floor_center, floor_rx * 0.24, floor_ry * 0.24, Color(0.85, 0.68, 0.34, 0.12), Color(0.92, 0.76, 0.42, 0.55), 2.2 * s)

	# 5. Đèn lồng đá cổ ấm áp hai bên (Warm Stone Lanterns)
	var lanterns := [
		Vector2(w * 0.04, h * 0.48),
		Vector2(w * 0.36, h * 0.33),
		Vector2(w * 0.64, h * 0.33),
		Vector2(w * 0.96, h * 0.48)
	]
	for lp in lanterns:
		var flicker := 0.88 + 0.12 * sin(time_accum * 4.2 + lp.x)
		draw_circle(lp, 42.0 * s * flicker, Color(1.0, 0.68, 0.24, 0.14))
		draw_circle(lp, 22.0 * s * flicker, Color(1.0, 0.78, 0.36, 0.26))
		draw_rect(Rect2(lp.x - 12.0 * s, lp.y - 16.0 * s, 24.0 * s, 32.0 * s), Color("ffcf70"))
		draw_rect(Rect2(lp.x - 15.0 * s, lp.y - 20.0 * s, 30.0 * s, 6.0 * s), Color("263d47"))
		draw_rect(Rect2(lp.x - 14.0 * s, lp.y + 15.0 * s, 28.0 * s, 5.0 * s), Color("263d47"))

	# 6. Cụm tinh thể xanh ngọc phát sáng ở tiền cảnh / hậu cảnh
	_draw_crystal_cluster(Vector2(w * 0.03, h * 0.78), 1.0 * s, false)
	_draw_crystal_cluster(Vector2(w * 0.97, h * 0.78), 1.0 * s, true)
	_draw_crystal_cluster(Vector2(w * 0.19, h * 0.77), 0.75 * s, false)
	_draw_crystal_cluster(Vector2(w * 0.81, h * 0.77), 0.75 * s, true)

	# 7. Hiệu ứng đòn tấn công & va chạm nguyên tố trên sàn đấu
	if attack_beam_alpha > 0.01:
		var dir := (attack_to - attack_from)
		var normal := Vector2(-dir.y, dir.x).normalized()
		for ray in range(-2, 3):
			var offset := normal * (ray * 8.0 * s)
			var mid := attack_from.lerp(attack_to, 0.55) + offset * 1.4
			var col := impact_color
			col.a = attack_beam_alpha * (0.85 - absf(ray) * 0.15)
			draw_line(attack_from + offset * 0.3, mid, col, (5.5 - absf(ray)) * s, true)
			draw_line(mid, attack_to + offset * 0.6, Color(1.0, 0.95, 0.78, col.a), (4.5 - absf(ray)) * s, true)

	if impact_flash > 0.01:
		var burst_r := (36.0 + (1.0 - impact_flash) * 75.0) * s
		draw_circle(impact_pos, burst_r, Color(impact_color.r, impact_color.g, impact_color.b, impact_flash * 0.28))
		for k in range(10):
			var ang := k * TAU / 10.0 + time_accum * 2.0
			var r_in := 12.0 * s
			var r_out := (38.0 + (k % 2) * 28.0) * s * (1.2 - impact_flash * 0.3)
			var p_in := impact_pos + Vector2.from_angle(ang) * r_in
			var p_out := impact_pos + Vector2.from_angle(ang) * r_out
			draw_line(p_in, p_out, Color(1.0, 0.92, 0.68, impact_flash), 3.0 * s, true)

	# 8. Hạt ma thuật lơ lửng
	for i in range(24):
		var px := fmod(i * 137.3 + time_accum * (10.0 + (i % 3) * 4.0), w)
		var py := fmod(i * 83.7 - time_accum * (14.0 + (i % 4) * 3.0) + h, h * 0.82)
		var alpha := 0.25 + 0.25 * sin(time_accum * 2.0 + i)
		draw_circle(Vector2(px, py), (1.6 + (i % 2)) * s, Color(0.48, 0.95, 0.88, alpha))

func _draw_ellipse(center: Vector2, rx: float, ry: float, fill: Color, border: Color, width: float) -> void:
	var pts := PackedVector2Array()
	for i in range(65):
		var ang := i * TAU / 64.0
		pts.append(center + Vector2(cos(ang) * rx, sin(ang) * ry))
	draw_colored_polygon(pts, fill)
	draw_polyline(pts, border, width, true)

func _draw_crystal_cluster(origin: Vector2, scale_factor: float, flip: bool) -> void:
	var dir := -1.0 if flip else 1.0
	var shards := [
		[Vector2(0, 0), Vector2(14 * dir, -52), Vector2(28 * dir, -12), Color("29b8b2")],
		[Vector2(10 * dir, 4), Vector2(32 * dir, -38), Vector2(38 * dir, 2), Color("5ef2e2")],
		[Vector2(-8 * dir, 6), Vector2(4 * dir, -34), Vector2(16 * dir, 4), Color("1d8588")]
	]
	for shard in shards:
		var pts := PackedVector2Array([
			origin + shard[0] * scale_factor,
			origin + shard[1] * scale_factor,
			origin + shard[2] * scale_factor
		])
		draw_colored_polygon(pts, shard[3])
		draw_polyline(pts, Color("a5fff5"), 1.2 * scale_factor, true)
