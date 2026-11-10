class_name MainMenuScreen
extends Control

const GOLD := Color("eacb83")
const INK := Color("102c36")
const PALE := Color("edf5e9")
const MUTED := Color("9fb6b6")
const TEAL := Color("79d7c6")
var dragon: TextureRect
var message: AcceptDialog
var favorites: Array[DragonInstance] = []
var favorite_index := 0
var favorite_name: Label
var favorite_info: Label
var favorite_empty: Control
var favorite_previous: Button
var favorite_next: Button
var gold_value: Label
var diamond_value: Label
var food_value: Label
var user_menu: Control
var user_profile: Button

func _ready() -> void:
	_build_home()

func _box(color: Color, border: Color, radius: int = 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style

func _panel(parent: Node, rect: Rect2, color: Color, border: Color, radius: int = 18) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", _box(color, border, radius))
	parent.add_child(panel)
	return panel

func _text(parent: Node, value: String, rect: Rect2, font_size: int, color: Color = PALE) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node, value: String, rect: Rect2, highlighted: bool = false, feature: String = "") -> Button:
	var button := Button.new()
	button.text = value
	button.tooltip_text = feature if not feature.is_empty() else value
	button.position = rect.position
	button.size = rect.size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", INK if highlighted else PALE)
	button.add_theme_color_override("font_hover_color", INK if highlighted else GOLD)
	button.add_theme_color_override("font_pressed_color", INK if highlighted else GOLD)
	button.add_theme_stylebox_override("normal", _box(GOLD if highlighted else Color("193b44"), GOLD if highlighted else Color("34535a"), 12))
	button.add_theme_stylebox_override("hover", _box(Color("f7dfa5") if highlighted else Color("254e55"), GOLD, 12))
	button.add_theme_stylebox_override("pressed", _box(Color("c9aa67") if highlighted else Color("102c36"), TEAL, 12))
	button.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), TEAL, 12))
	parent.add_child(button)
	button.pressed.connect(_show_preview.bind(feature if not feature.is_empty() else value))
	return button

func _show_preview(feature: String) -> void:
	if "Chiến đấu" in feature:
		get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
		return
	if "Cài đặt" in feature:
		get_tree().change_scene_to_file("res://scenes/main/settings.tscn")
		return
	if "Lai tạo" in feature or "Hợp thể" in feature:
		get_tree().change_scene_to_file("res://scenes/breeding/breeding.tscn")
		return
	if "Triệu hồi" in feature:
		get_tree().change_scene_to_file("res://scenes/gacha/gacha.tscn")
		return
	if "Bộ sưu tập" in feature:
		get_tree().change_scene_to_file("res://scenes/collection/dragon_collection.tscn")
		return
	message.title = feature
	message.dialog_text = "Giao diện xem trước — %s.\nTính năng này sẽ được bổ sung ở giai đoạn tiếp theo." % feature
	message.popup_centered(Vector2i(440, 150))

func _build_home() -> void:
	var backdrop := TextureRect.new()
	backdrop.texture = preload("res://assets/textures/home_cavern.svg")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	# The design canvas scales with the project's 1280 x 720 viewport.
	var canvas := Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(canvas)
	_text(canvas, "LONG TỘC", Rect2(34, 17, 170, 29), 25, GOLD)
	_text(canvas, "T H Ứ C T Ỉ N H", Rect2(35, 47, 185, 22), 12, MUTED)
	_resource(canvas, 310, "◈", str(PlayerProfile.gold), GOLD)
	_resource(canvas, 505, "✦", str(PlayerProfile.diamonds), TEAL)
	_resource(canvas, 700, "♧", str(PlayerProfile.food), Color("b5d29b"))
	user_profile = _button(canvas,"",Rect2(958,18,288,62))
	user_profile.name = "UserProfile"
	user_profile.tooltip_text = "Hồ sơ người chơi"
	for connection in user_profile.pressed.get_connections():
		user_profile.pressed.disconnect(connection.callable)
	user_profile.pressed.connect(_toggle_user_menu)
	_profile_avatar(user_profile,Rect2(7,6,50,50))
	_text(user_profile,"Người bảo hộ",Rect2(72,8,185,27),17,PALE)
	_text(user_profile,"Hồ sơ người chơi",Rect2(72,36,185,19),11,TEAL)
	_text(user_profile,">",Rect2(265,18,18,24),17,GOLD)
	_text(canvas, "LONG ĐỘNG", Rect2(34, 106, 280, 32), 27)
	_text(canvas, "Nơi những huyền thoại nhỏ thức giấc.", Rect2(35, 143, 400, 24), 13, MUTED)
	# Story card.
	var story := _panel(canvas, Rect2(34, 198, 276, 340), Color("102c36e8"), Color("446066"))
	_text(story, "CỐT TRUYỆN CHÍNH", Rect2(22, 20, 240, 20), 11, GOLD)
	_text(story, "Tiếng gọi\ntừ lòng đất", Rect2(22, 51, 235, 81), 29)
	_text(story, "CHƯƠNG 01  ·  KHỞI NGUYÊN", Rect2(22, 145, 240, 22), 11, TEAL)
	_text(story, "Một nguồn sức mạnh cổ xưa\nđang thức tỉnh dưới long động.\nCùng rồng khám phá bí mật đầu tiên.", Rect2(22, 181, 240, 74), 13, MUTED)
	_button(story, "Khám phá    >", Rect2(22, 272, 232, 46), false, "Chiến đấu · Cốt truyện")
	# Central companion, drawn as an independent reusable vector asset.
	dragon = TextureRect.new()
	dragon.texture = null
	dragon.position = Vector2(390, 204)
	dragon.size = Vector2(500, 350)
	dragon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dragon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dragon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(dragon)
	dragon.set_deferred("size", Vector2(500, 350))
	DragonAnimator.attach(dragon).enable_sleep(true)
	var nameplate := _panel(canvas, Rect2(509, 525, 266, 68), Color("102c36eb"), Color("4c7476"), 16)
	favorite_name = _text(nameplate, "", Rect2(10, 9, 246, 26), 18)
	favorite_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	favorite_name.clip_text = true
	favorite_info = _text(nameplate, "", Rect2(10, 40, 246, 20), 11, TEAL)
	favorite_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	favorite_empty = Control.new()
	favorite_empty.position = Vector2(365, 280)
	favorite_empty.size = Vector2(555, 200)
	canvas.add_child(favorite_empty)
	_text(favorite_empty, "☆", Rect2(0, 0, 555, 65), 50, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text(favorite_empty, "Chưa có rồng yêu thích", Rect2(0, 77, 555, 35), 23).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text(favorite_empty, "Đánh dấu ☆ trong Bộ sưu tập để trưng bày tại đây.", Rect2(0, 122, 555, 30), 14, MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(favorite_empty, "Chọn rồng yêu thích", Rect2(145, 163, 265, 40), false, "Bộ sưu tập")
	favorite_previous = _button(canvas, "<", Rect2(360, 365, 45, 45))
	favorite_next = _button(canvas, ">", Rect2(880, 365, 45, 45))
	for button in [favorite_previous, favorite_next]:
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
	favorite_previous.pressed.connect(_cycle_favorite.bind(-1))
	favorite_next.pressed.connect(_cycle_favorite.bind(1))
	_refresh_favorite()

	# Summon is the primary entry point.
	var summon := _panel(canvas, Rect2(959, 198, 287, 340), Color("183c43f0"), Color("bba469"))
	_text(summon, "✦  TRIỆU HỒI RỒNG", Rect2(23, 20, 250, 22), 12, GOLD)
	_text(summon, "Hắc Hỏa\nthức giấc", Rect2(23, 56, 250, 80), 31)
	_text(summon, "HỎA  /  BÓNG TỐI", Rect2(23, 150, 250, 24), 13, TEAL)
	_text(summon, "Cơ bản 0,1% · Rồng 2 hệ\nBảo hiểm vàng sau tối đa 60 lượt", Rect2(23, 189, 250, 52), 13, MUTED)
	_text(summon, "✧     RỒNG NỔI BẬT     ✧", Rect2(23, 241, 240, 24), 13, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(summon, "Triệu hồi    ✦", Rect2(22, 278, 243, 44), true, "Triệu hồi")
	# Bottom navigation.
	_panel(self, Rect2(0, 654, 1280, 66), Color("0b202af5"), Color("344c51"), 0)
	var tabs := ["Chiến đấu", "Bộ sưu tập", "Triệu hồi", "Hợp thể"]
	var icons := ["battle", "collection", "summon", "fusion"]
	for i in range(tabs.size()):
		var tab := _button(self,tabs[i],Rect2(30+i*309,665,289,44),false,tabs[i])
		tab.icon = load("res://assets/icons/navigation/%s.svg" % icons[i])
		tab.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		tab.expand_icon = true
		tab.add_theme_constant_override("icon_max_width",28)
		for state in ["normal","hover","pressed","focus"]:
			var style := tab.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			style.content_margin_left = 24
			style.content_margin_right = 24
			tab.add_theme_stylebox_override(state,style)
	_build_user_menu()
	message = AcceptDialog.new()
	message.ok_button_text = "Đã hiểu"
	add_child(message)

func _resource(parent: Node, x: float, icon: String, value: String, color: Color) -> void:
	var pill := _panel(parent, Rect2(x, 25, 163, 44), Color("102b35"), Color("395057"), 13)
	_text(pill, icon, Rect2(13, 6, 31, 29), 23, color)
	var label := _text(pill, value, Rect2(49, 9, 107, 26), 18)
	if icon == "◈":
		gold_value = label
	elif icon == "✦":
		diamond_value = label
	elif icon == "♧":
		food_value = label

func _refresh_favorite() -> void:
	favorites.clear()
	for pet in PlayerCollection.owned_dragons:
		if pet.favorite:
			favorites.append(pet)
	favorite_empty.visible = favorites.is_empty()
	dragon.visible = not favorites.is_empty()
	favorite_previous.visible = favorites.size() > 1
	favorite_next.visible = favorites.size() > 1
	if favorites.is_empty():
		favorite_name.text = "Long động của bạn"
		favorite_info.text = "Chỉ trưng bày rồng yêu thích"
		return
	favorite_index = posmod(favorite_index, favorites.size())
	var pet := favorites[favorite_index]
	var unit := BattleCatalog.dragon(pet)
	dragon.texture = unit.portrait
	favorite_name.text = "★ " + unit.display_name
	favorite_info.text = "Cấp %d · %d / %d yêu thích" % [pet.level, favorite_index + 1, favorites.size()]

func _cycle_favorite(direction: int) -> void:
	favorite_index += direction
	_refresh_favorite()

func _profile_avatar(parent: Node, rect: Rect2) -> void:
	var avatar := TextureRect.new()
	avatar.texture = preload("res://assets/icons/navigation/profile.svg")
	avatar.position = rect.position
	avatar.size = rect.size
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(avatar)
	avatar.set_deferred("size",rect.size)

func _build_user_menu() -> void:
	user_menu = Control.new()
	user_menu.name = "UserMenu"
	user_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	user_menu.z_index = 20
	user_menu.visible = false
	add_child(user_menu)
	user_menu.gui_input.connect(func(event:InputEvent):
		if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			user_menu.hide()
	)
	var shade := ColorRect.new()
	shade.color = Color(0.015,0.04,0.06,0.48)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	user_menu.add_child(shade)
	_panel(user_menu,Rect2(808,94,438,493),Color("102936"),Color("8d825d"),22)
	var banner := _panel(user_menu,Rect2(821,107,412,151),Color("183c47"),Color("315a62"),16)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_profile_avatar(user_menu,Rect2(838,126,86,86))
	_text(user_menu,"HỒ SƠ NGƯỜI CHƠI",Rect2(941,126,240,23),11,TEAL)
	_text(user_menu,"Người bảo hộ",Rect2(941,155,240,38),25,GOLD)
	_text(user_menu,"Long động của bạn",Rect2(942,201,240,25),14,MUTED)
	var close := _button(user_menu,"x",Rect2(1187,111,32,30))
	close.tooltip_text = "Đóng hồ sơ"
	for connection in close.pressed.get_connections():
		close.pressed.disconnect(connection.callable)
	close.pressed.connect(user_menu.hide)
	var favorite_count := 0
	for pet in PlayerCollection.owned_dragons:
		if pet.favorite:
			favorite_count += 1
	var values := [PlayerCollection.owned_count(),favorite_count,PlayerProfile.stage_stars.size()]
	var labels := ["Rồng sở hữu","Yêu thích","Chương đã qua"]
	for i in range(3):
		var x := 833+i*132
		_panel(user_menu,Rect2(x,278,124,84),Color("0d232e"),Color("2d4a56"),13).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_text(user_menu,str(values[i]),Rect2(x+8,287,108,35),26,TEAL).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_text(user_menu,labels[i],Rect2(x+5,331,114,22),11,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text(user_menu,"HÀNH TRÌNH",Rect2(837,388,370,24),11,GOLD)
	var progress := "Bắt đầu chương đầu tiên tại Chiến đấu" if PlayerProfile.stage_stars.is_empty() else "Đã vượt %d chương trong Khe Nứt" % PlayerProfile.stage_stars.size()
	_text(user_menu,progress,Rect2(837,419,370,26),14,PALE)
	var settings := _button(user_menu,"Cài đặt",Rect2(833,470,388,64),false,"Cài đặt")
	settings.name = "UserSettings"
	settings.icon = preload("res://assets/icons/navigation/settings.svg")
	settings.expand_icon = true
	settings.add_theme_constant_override("icon_max_width",28)
	for state in ["normal","hover","pressed","focus"]:
		var style := settings.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		style.content_margin_left = 20
		style.content_margin_right = 20
		settings.add_theme_stylebox_override(state,style)
	_text(user_menu,"Âm thanh và tùy chọn trải nghiệm",Rect2(837,548,370,24),12,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _toggle_user_menu() -> void:
	user_menu.visible = not user_menu.visible
