class_name GachaScreen
extends Control

const GOLD := Color("eacb83")
const PALE := Color("edf5e9")
const MUTED := Color("aab8c5")
var banner: BannerDefinition
var rates_dialog: AcceptDialog
var rates_overlay: Control
var result_overlay: Control
var roll_one: Button
var roll_ten: Button
var pity_label: Label
var pity_bar: ProgressBar
var rolling := false
var reveal_tween: Tween

func _ready() -> void:
	banner = BannerManager.current_banner()
	var background := TextureRect.new()
	background.texture = preload("res://assets/textures/home_cavern.svg")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.modulate = Color("777b9c")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_panel(Rect2(0,0,1280,720),Color("0b1328bd"),Color.TRANSPARENT,0)
	var back := _button("< Quay lại",Rect2(32,26,164,44))
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn"))
	_text("ĐIỆN TRIỆU HỒI",Rect2(410,31,460,35),20,GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel(Rect2(1015,24,231,49),Color("152c3c"),Color("4c6b7c"),14)
	_text("◈",Rect2(1032,30,34,33),25,Color("82dce8"))
	_text("Kim cương",Rect2(1077,28,150,20),10,MUTED)
	_text(str(PlayerProfile.diamonds),Rect2(1077,45,150,24),18,PALE)
	_panel(Rect2(32,97,1214,340),Color("111f34e8"),Color("484362"))
	DragonUI.portrait(self,preload("res://assets/textures/summon_stage.svg"),Rect2(600,88,755,362))
	_text("GIAO ƯỚC HỎA / BÓNG TỐI",Rect2(65,128,580,26),12,GOLD)
	_text(banner.title,Rect2(65,176,590,62),39)
	_text("Ngọn lửa cổ đại đã tìm thấy
người kế thừa sức mạnh của bóng tối.",Rect2(68,260,510,70),19,Color("c5c9db"))
	_panel(Rect2(66,356,211,34),Color("352b43"),Color("9b7e91"),12)
	_text("RỒNG NỔI BẬT · HAI HỆ",Rect2(80,363,190,24),11,GOLD)
	var featured: DragonDefinition
	for definition in DragonCatalog.all_definitions():
		if definition.id == banner.featured_dragon_id:
			featured = definition
	if featured != null:
		var portrait := DragonUI.portrait(self,featured.portrait,Rect2(695,118,395,300))
		var idle := create_tween().set_loops()
		idle.tween_property(portrait,"position:y",110.0,2.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		idle.tween_property(portrait,"position:y",118.0,2.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var rates := _button("Chi tiết tỉ lệ",Rect2(1092,105,139,34))
	rates.add_theme_font_size_override("font_size",12)
	rates.pressed.connect(_show_rates)
	_panel(Rect2(32,452,1214,131),Color("182437ed"),Color("66516c"))
	_text("Hỏa · Bóng Tối",Rect2(57,468,770,35),24,Color("edc6e3"))
	_text("Kết hợp ngọn lửa nguyên thủy và sức mạnh bí ẩn của Bóng Tối.
Sở hữu sức tấn công mạnh mẽ, áp đảo đối thủ bằng những đòn đánh bùng nổ.",Rect2(58,514,1030,55),15,MUTED)
	_panel(Rect2(32,601,1214,96),Color("15263bf5"),Color("4b526c"))
	pity_label = _text("",Rect2(55,615,710,27),15,GOLD)
	pity_bar = ProgressBar.new()
	pity_bar.position = Vector2(55,681)
	pity_bar.size = Vector2(600,5)
	pity_bar.max_value = 60
	pity_bar.show_percentage = false
	pity_bar.add_theme_stylebox_override("background",_style(Color("303348"),Color.TRANSPARENT,3))
	pity_bar.add_theme_stylebox_override("fill",_style(GOLD,GOLD,3))
	add_child(pity_bar)
	pity_bar.set_deferred("size",Vector2(600,5))
	roll_one = _button("Triệu hồi ×1",Rect2(829,619,177,51))
	roll_ten = _button("Triệu hồi ×10",Rect2(1020,619,205,51),true)
	roll_one.pressed.connect(_roll.bind(1))
	roll_ten.pressed.connect(_roll.bind(10))
	_text("Lượt thử miễn phí",Rect2(829,676,396,18),10,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_update_count()
	rates_dialog = AcceptDialog.new()
	rates_dialog.title = "Thông báo triệu hồi"
	rates_dialog.ok_button_text = "Đã hiểu"
	add_child(rates_dialog)

func _percent(value: float) -> String:
	return ("%.1f%%" % (value * 100.0)).replace(".", ",")

func _show_rates() -> void:
	if rolling or is_instance_valid(result_overlay) or is_instance_valid(rates_overlay):
		return
	for child in get_children():
		if child is Button:
			child.disabled = true
	rates_overlay = Control.new()
	rates_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rates_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	rates_overlay.z_index = 30
	add_child(rates_overlay)
	DragonUI.panel(rates_overlay,Rect2(0,0,1280,720),Color("050c1beF"),Color.TRANSPARENT)
	DragonUI.panel(rates_overlay,Rect2(205,53,870,614),Color("142238"),Color("897292"))
	DragonUI.text(rates_overlay,"Tỉ lệ triệu hồi",Rect2(235,77,690,43),31,GOLD)
	DragonUI.text(rates_overlay,banner.title+" · Danh sách rồng trong giao ước",Rect2(236,129,740,25),14,MUTED)
	var close := DragonUI.button(rates_overlay,"Đóng",Rect2(973,78,76,37))
	close.pressed.connect(_close_rates)
	close.grab_focus()
	var ordered := [banner.featured_dragon_id,"fire","water","shadow"]
	var definitions := {}
	for definition in DragonCatalog.all_definitions():
		definitions[definition.id] = definition
	for i in range(ordered.size()):
		var definition: DragonDefinition = definitions[ordered[i]]
		var y := 176+i*64
		DragonUI.panel(rates_overlay,Rect2(235,y,810,55),Color("302b44") if i == 0 else Color("1b3043"),GOLD if i == 0 else Color("354e61"))
		DragonUI.portrait(rates_overlay,definition.portrait,Rect2(248,y+3,57,49))
		DragonUI.text(rates_overlay,definition.display_name,Rect2(319,y+5,560,25),16,definition.accent)
		DragonUI.text(rates_overlay,"Rồng nổi bật · Hai hệ" if i == 0 else "Một hệ · Nguyên liệu tăng cấp",Rect2(320,y+31,560,20),10,MUTED)
		DragonUI.text(rates_overlay,_percent(banner.probability(definition.id)),Rect2(928,y+11,103,32),23,GOLD if i == 0 else PALE)
	DragonUI.panel(rates_overlay,Rect2(235,447,810,103),Color("233349"),Color("816e50"))
	DragonUI.text(rates_overlay,"BẢO HIỂM RỒNG VÀNG · TỐI ĐA 60 LƯỢT",Rect2(253,460,770,25),14,GOLD)
	DragonUI.text(rates_overlay,"Sau 59 lượt chưa trúng vàng, lượt kế tiếp chắc chắn nhận rồng nổi bật.
Trúng vàng sẽ đếm lại từ 0; gói mười lượt được xét lần lượt từng trứng.",Rect2(253,496,770,48),13,PALE)
	DragonUI.text(rates_overlay,"Các tỉ lệ phía trên áp dụng trước lượt bảo hiểm. Không có rồng hai hệ khác
hoặc Tam Hệ trong giao ước này. Kết quả và bảo hiểm được lưu trên thiết bị.",Rect2(238,566,810,55),12,MUTED)
	DragonUI.text(rates_overlay,"Tiến độ hiện tại: %d / 60" % PlayerCollection.pity_count,Rect2(238,631,810,24),12,GOLD)

func _close_rates() -> void:
	if is_instance_valid(rates_overlay):
		remove_child(rates_overlay)
		rates_overlay.queue_free()
	rates_overlay = null
	for child in get_children():
		if child is Button:
			child.disabled = false

func _style(color: Color, border: Color, radius: int = 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style

func _panel(rect: Rect2, color: Color, border: Color, radius: int = 18) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(color, border, radius))
	add_child(panel)
	return panel

func _update_count() -> void:
	if pity_label != null:
		pity_label.text = "Bảo hiểm vàng: %d / 60  ·  Còn tối đa %d lượt" % [PlayerCollection.pity_count, GachaManager.PITY_LIMIT - PlayerCollection.pity_count]

	if pity_bar != null:
		pity_bar.value = PlayerCollection.pity_count

func _roll(count: int) -> void:
	if rolling or is_instance_valid(result_overlay) or is_instance_valid(rates_overlay):
		return
	rolling = true
	roll_one.disabled = true
	roll_ten.disabled = true
	var result := GachaManager.roll(count)
	if not result.error_message.is_empty():
		rates_dialog.dialog_text = result.error_message
		rates_dialog.popup_centered()
		roll_one.disabled = false
		roll_ten.disabled = false
		rolling = false
		return
	_update_count()
	for child in get_children():
		if child is Button:
			child.disabled = true
	var hatch := GachaHatch.new()
	hatch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hatch.z_index = 30
	add_child(hatch)
	hatch.setup(result)
	await hatch.finished
	remove_child(hatch)
	hatch.queue_free()
	_show_results(result)
	rolling = false

func _show_results(result: GachaResult) -> void:
	# Block underlying navigation and repeated activation while results are open.
	for child in get_children():
		if child is Button:
			child.disabled = true
	result_overlay = Control.new()
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.z_index = 20
	add_child(result_overlay)
	_panel(Rect2(0, 0, 1280, 720), Color("07101beF"), Color.TRANSPARENT, 0).reparent(result_overlay)
	_panel(Rect2(40, 48, 1200, 619), Color("162638"), Color("867593")).reparent(result_overlay)
	var heading := _text("Kết quả triệu hồi ×%d" % result.dragons.size(), Rect2(70, 66, 1140, 44), 30, GOLD)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.reparent(result_overlay)
	var subtitle := _text("Đã thêm vào Bộ sưu tập và lưu trên máy. Rồng trùng được giữ thành từng cá thể.", Rect2(70, 116, 1140, 25), 14, MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.reparent(result_overlay)
	var definitions := {}
	for definition in DragonCatalog.all_definitions():
		definitions[definition.id] = definition
	for i in range(result.dragons.size()):
		var dragon: DragonInstance = result.dragons[i]
		var definition: DragonDefinition = definitions[dragon.species_id]
		var x := 80.0 + (i % 5) * 226.0 if result.dragons.size() > 1 else 530.0
		var y := 157.0 + floori(i / 5.0) * 203.0 if result.dragons.size() > 1 else 243.0
		var card := _panel(Rect2(x, y, 216, 192), Color("243449"), definition.accent)
		card.reparent(result_overlay)
		var portrait := TextureRect.new()
		portrait.texture = definition.portrait
		portrait.position = Vector2(16, 8)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.size = Vector2(184, 112)
		card.add_child(portrait)
		portrait.set_deferred("size", Vector2(184, 112))
		var name_label := _text(definition.display_name, Rect2(x + 6, y + 121, 204, 27), 16, definition.accent)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.reparent(result_overlay)
		var role := "Nguyên liệu tăng cấp · Cấp 1" if definition.is_upgrade_material() else "RỒNG NỔI BẬT · Rồng 2 hệ · Cấp 1"
		var role_label := _text(role, Rect2(x + 5, y + 156, 206, 23), 11, GOLD)
		role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		role_label.reparent(result_overlay)
	var close_button := _button("Tiếp tục triệu hồi", Rect2(525, 596, 230, 46), true)
	close_button.reparent(result_overlay)
	close_button.pressed.connect(_close_results)
	close_button.grab_focus()
	result_overlay.modulate.a = 0.0
	reveal_tween = create_tween()
	reveal_tween.tween_property(result_overlay, "modulate:a", 1.0, 0.25)

func _close_results() -> void:
	if reveal_tween != null:
		reveal_tween.kill()
	if is_instance_valid(result_overlay):
		remove_child(result_overlay)
		result_overlay.queue_free()
	result_overlay = null
	for child in get_children():
		if child is Button:
			child.disabled = false
	roll_one.grab_focus()

func _text(value: String, rect: Rect2, font_size: int, color: Color = PALE) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label

func _button(value: String, rect: Rect2, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("20303b") if primary else PALE)
	button.add_theme_color_override("font_disabled_color", Color("d9c99f"))
	button.add_theme_stylebox_override("normal", _style(GOLD if primary else Color("253449"), GOLD if primary else Color("536477"), 12))
	button.add_theme_stylebox_override("hover", _style(Color("3d415b"), GOLD, 12))
	button.add_theme_stylebox_override("focus", _style(Color("3d415b"), GOLD, 12))
	button.add_theme_stylebox_override("disabled", _style(Color("4c4850"), Color("887b68"), 12))
	add_child(button)
	return button
