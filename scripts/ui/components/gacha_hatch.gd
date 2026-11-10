class_name GachaHatch
extends Control

signal finished
var elapsed := 0.0
var rare := false
var amount := 1
var completed := false
var heading: Label
var caption: Label
var cracks_played := 0
var burst_played := false
var reveal_played := false
var skip: Button
var definitions: Array[DragonDefinition] = []
var portraits: Array[TextureRect] = []
var centers: Array[Vector2] = []
var spotlight: TextureRect
var shade: ColorRect
var featured_index := -1
var featured_count := 0
var featured_indices: Array[int] = []
var spotlight_index := -1
var breeding_reveal := false
var mythic_reveal := false
var element_colors := {"Hỏa": Color("ff9764"), "Thủy": Color("6ae3e2"), "Bóng Tối": Color("bb8bfa")}

func setup(result: GachaResult, from_breeding: bool = false) -> void:
	breeding_reveal = from_breeding
	amount = result.dragons.size()
	var catalog := {}
	for definition in DragonCatalog.all_definitions():
		catalog[definition.id] = definition
	for i in range(amount):
		var definition: DragonDefinition = catalog[result.dragons[i].species_id]
		definitions.append(definition)
		mythic_reveal = mythic_reveal or definition.elements.size() == 3
		var center := Vector2(192 + (i % 5) * 224, 261 + floori(i / 5.0) * 211) if amount == 10 else Vector2(640, 360)
		centers.append(center)
		var portrait := TextureRect.new()
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.texture = definition.portrait
		portrait.position = center - Vector2(88, 80) if amount == 10 else center - Vector2(230, 180)
		portrait.modulate.a = 0
		portrait.z_index = 1
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(portrait)
		portrait.set_deferred("size", Vector2(176, 160) if amount == 10 else Vector2(460, 360))
		DragonAnimator.attach(portrait)
		portraits.append(portrait)
		if not definition.is_upgrade_material():
			rare = true
			featured_count += 1
			featured_indices.append(i)
			if featured_index < 0:
				featured_index = i
	shade = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015, 0.025, 0.06, 0)
	shade.z_index = 2
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	if rare:
		spotlight = TextureRect.new()
		spotlight.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spotlight.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spotlight.texture = definitions[featured_index].portrait
		spotlight.visible = false
		spotlight.z_index = 3
		spotlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(spotlight)
		spotlight.set_deferred("size", Vector2(176, 160))
		DragonAnimator.attach(spotlight)
	heading = _label("%d TRỨNG RỒNG · GIAO ƯỚC NGUYÊN TỐ" % amount, 25, 58)
	caption = _label("Mỗi sắc trứng mang một sức mạnh đang chờ thức giấc.", 15, 610)
	if breeding_reveal:
		heading.text = "TRỨNG RỒNG THẦN ĐÃ HÌNH THÀNH"
		caption.text = "Sinh mệnh mới đang dần thức tỉnh bên trong vỏ trứng…"
	skip = Button.new()
	skip.text = "Bỏ qua  >"
	skip.position = Vector2(1090, 655)
	skip.size = Vector2(150, 40)
	skip.z_index = 4
	skip.disabled = true
	skip.pressed.connect(_finish)
	add_child(skip)
	AudioManager.play("charge")

func _label(value: String, font_size: int, y: float) -> Label:
	var label := Label.new()
	label.text = value
	label.position = Vector2(80, y)
	label.size = Vector2(1120, 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f4dfb6"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 4
	add_child(label)
	return label

func _process(delta: float) -> void:
	if completed:
		return
	elapsed += delta * (.65 if breeding_reveal else 1.0)
	skip.disabled = elapsed < 0.7
	for threshold in [1.45, 2.0, 2.55]:
		if elapsed >= threshold and cracks_played < [1.45, 2.0, 2.55].find(threshold) + 1:
			cracks_played += 1
			AudioManager.play("crack")
	if elapsed >= 2.85 and not burst_played:
		burst_played = true
		AudioManager.play("hatch")
	if elapsed >= 3.2:
		if not reveal_played:
			reveal_played = true
			AudioManager.play("reveal")
		var appear := clampf((elapsed - 3.2) / .5, 0, 1)
		for portrait in portraits:
			portrait.modulate.a = appear
		heading.text = "TRỨNG RỒNG ĐÃ NỞ!" if amount == 1 else "TẤT CẢ TRỨNG ĐÃ NỞ!"
		caption.text = "Đã nhận %d rồng · Kết quả được lưu vào Bộ sưu tập" % amount
	elif elapsed > 1.45:
		caption.text = "Năng lượng cộng hưởng… tất cả trứng sắp nở!"
	if rare and elapsed >= 4.35:
		var slot := mini(int((elapsed - 4.35) / 2.7), featured_indices.size() - 1)
		var selected := featured_indices[slot]
		if spotlight_index != selected:
			spotlight_index = selected
			spotlight.texture = definitions[selected].portrait
			AudioManager.play("rare")
		spotlight.visible = true
		portraits[selected].modulate.a = 0
		var zoom := ease(clampf((elapsed - 4.35 - slot * 2.7) / .8, 0, 1), .45)
		var initial_size := Vector2(176, 160) if amount == 10 else Vector2(460, 360)
		spotlight.size = initial_size.lerp(Vector2(560, 420), zoom)
		spotlight.position = (centers[selected] - initial_size / 2).lerp(Vector2(360, 145), zoom)
		shade.color.a = zoom * .84
		heading.text = ("✦ RỒNG TAM HỆ GIÁNG THẾ ✦" if mythic_reveal else "✦ HỢP THỂ THÀNH CÔNG ✦") if breeding_reveal else "✦ RỒNG NỔI BẬT · RỒNG VÀNG THỨC TỈNH ✦"
		caption.text = definitions[selected].display_name + ("  ·  Rồng vàng %d / %d" % [slot + 1, featured_count] if featured_count > 1 else "  ·  Giao ước hiếm đã được đáp lời")
	queue_redraw()
	if elapsed >= (5.0 + 2.7 * featured_count if rare else 5.7):
		_finish()

func _finish() -> void:
	if completed:
		return
	completed = true
	AudioManager.stop_cinematic()
	finished.emit()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("081021"))
	if mythic_reveal:
		for j in range(3):
			var color: Color = [Color("ff9866"),Color("67e5e4"),Color("c497ff")][j]
			var angle := elapsed * .7 + j * TAU/3
			var p := Vector2(640,360) + Vector2.from_angle(angle)*210
			draw_arc(Vector2(640,360),205+j*8,angle,angle+PI,80,Color(color,.5),3,true)
			for radius in range(6,0,-1):
				draw_circle(p,radius*6,Color(color,.025))
			draw_circle(p,8,color)
	for i in range(34):
		var p := Vector2(fmod(i * 127.7 + elapsed * 8, 1280), fmod(i * 71.1 - elapsed * 13 + 720, 720))
		draw_circle(p, 1 + i % 2, Color("78a6bb", .22))
	for i in range(definitions.size()):
		var definition := definitions[i]
		var color: Color = element_colors[definition.elements[0]]
		var center := centers[i]
		var factor := .64 if amount == 10 else 1.28
		for j in range(7, 0, -1):
			draw_circle(center, j * 15 * factor, Color(color, .018))
		draw_arc(center + Vector2(0, 72 * factor), 88 * factor, 0, TAU, 70, Color(color, .27), 1.5, true)
		for j in range(8):
			var p := center + Vector2.from_angle(j * TAU / 8 + elapsed * .4) * (100 * factor)
			draw_circle(p, 1.8, Color(color, .6))
		if elapsed < 2.85:
			var shake := sin(elapsed * 36 + i * .5) * maxf(0, elapsed - 1.1) * 3
			_draw_egg(center + Vector2(shake, sin(elapsed * 2.6 + i) * 3), factor, definition, elapsed > 1.45)
		elif elapsed < 3.9:
			var burst := elapsed - 2.85
			for j in range(12):
				var direction := Vector2.from_angle(j * TAU / 12)
				var alpha := maxf(0, 1 - burst)
				draw_line(center + direction * (20 + burst * 40), center + direction * (65 + burst * 95), Color(color, alpha), 2, true)
				var p := center + direction * (30 + burst * 100) + Vector2(0, burst * burst * 50)
				draw_colored_polygon(PackedVector2Array([p, p + Vector2(8,-9), p + Vector2(11,5)]), Color(color, alpha))
		var tag := " / ".join(definition.elements) if elapsed < 3.2 else definition.display_name
		var font := ThemeDB.get_project_theme().default_font
		var font_size := 13 if amount == 10 else 19
		var width := font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(font, center + Vector2(-width/2, 112 * factor + 27), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	if elapsed >= 2.85 and elapsed < 3.3:
		draw_rect(Rect2(0, 0, 1280, 720), Color(1, .96, .86, maxf(0, 1 - (elapsed-2.85)/.45) * .65))

func _draw_egg(center: Vector2, factor: float, definition: DragonDefinition, cracked: bool) -> void:
	var colors: Array[Color] = []
	for element in definition.elements:
		colors.append(element_colors[element])
	var outline := Color("efcf7d") if colors.size() > 1 else colors[0]
	var points := PackedVector2Array()
	for i in range(65):
		var angle := i * TAU / 64
		points.append(center + Vector2(cos(angle) * 77 * (1 + sin(angle) * .17), sin(angle) * 106) * factor)
	draw_colored_polygon(points, colors[0].darkened(.62))
	if colors.size() > 1:
		var half := PackedVector2Array()
		for i in range(33):
			var angle := -PI/2 + i * PI/32
			half.append(center + Vector2(cos(angle)*77*(1+sin(angle)*.17), sin(angle)*106)*factor)
		draw_colored_polygon(half, colors[1].darkened(.48))
	draw_polyline(points, outline, 3, true)
	for i in range(4):
		var p := center + Vector2(-22 + (i%2)*44, -45 + floori(i/2.0)*65)*factor
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-12)*factor,p+Vector2(8,0)*factor,p+Vector2(0,12)*factor,p+Vector2(-8,0)*factor]), outline)
	if cracked:
		var crack := PackedVector2Array()
		var vertices := [Vector2(4,-105),Vector2(-13,-66),Vector2(11,-40),Vector2(-8,-12),Vector2(13,14),Vector2(-15,49),Vector2(5,104)]
		for i in range(clampi(3+int((elapsed-1.45)*3),3,7)):
			crack.append(center + vertices[i]*factor)
		draw_polyline(crack, Color(outline,.3), 10*factor, true)
		draw_polyline(crack, Color("fff5d8"), 3*factor, true)
