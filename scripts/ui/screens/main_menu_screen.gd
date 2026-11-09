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
var care_panel: Panel
var care_selected: DragonInstance
var care_notice := ""
var gold_value: Label
var diamond_value: Label
var food_value: Label
var user_name_label: Label
var login_modal: Control
var home_scroll: ScrollContainer

func _ready() -> void:
	WorldBossSystem.ensure_initialized()
	_build_home()
	var float_tween := create_tween().set_loops()
	float_tween.tween_property(dragon, "position:y", dragon.position.y - 9, 2.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(dragon, "position:y", dragon.position.y, 2.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

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
	if "Boss Thế Giới" in feature:
		WorldBossSystem.open_boss_lobby_on_enter = true
		get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
		return
	if "Tài khoản" in feature:
		_show_login_modal()
		return
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
	home_scroll = ScrollContainer.new()
	home_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	home_scroll.offset_bottom = -66
	home_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(home_scroll)
	var canvas := Control.new()
	canvas.custom_minimum_size = Vector2(1264,1160)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_scroll.add_child(canvas)
	_text(canvas, "LONG TỘC", Rect2(34, 17, 170, 29), 25, GOLD)
	_text(canvas, "T H Ứ C T Ỉ N H", Rect2(35, 47, 185, 22), 12, MUTED)
	_panel(canvas, Rect2(239, 20, 253, 54), Color("102b35"), Color("395057"), 14)
	_panel(canvas, Rect2(248, 28, 38, 38), Color("34595d"), GOLD, 12)
	_text(canvas, "07", Rect2(255, 33, 33, 26), 18, GOLD)
	user_name_label = _text(canvas, WorldBossSystem.current_username, Rect2(300, 26, 180, 25), 16)
	_text(canvas, "Tổ đội 3 người · Cloud", Rect2(300, 50, 180, 20), 11, TEAL)
	_button(canvas, "👤 Tài khoản", Rect2(502, 25, 136, 44), false, "Tài khoản")
	_resource(canvas, 650, "◈", str(PlayerProfile.gold), GOLD)
	_resource(canvas, 832, "✦", str(PlayerProfile.diamonds), TEAL)
	_resource(canvas, 1014, "♧", str(PlayerProfile.food), Color("b5d29b"))
	_button(canvas, "...", Rect2(1192, 24, 54, 46), false, "Cài đặt")
	_text(canvas, "LONG ĐỘNG", Rect2(34, 106, 280, 32), 27)
	_text(canvas, "Nơi những huyền thoại nhỏ thức giấc.", Rect2(35, 143, 400, 24), 13, MUTED)
	_text(canvas, "TRANG CHỦ", Rect2(1009, 111, 240, 20), 11, MUTED)
	# Story card.
	var story := _panel(canvas, Rect2(34, 198, 276, 340), Color("102c36e8"), Color("446066"))
	_text(story, "CỐT TRUYỆN CHÍNH", Rect2(22, 20, 240, 20), 11, GOLD)
	_text(story, "Tiếng gọi\ntừ lòng đất", Rect2(22, 51, 235, 81), 29)
	_text(story, "CHƯƠNG 01  ·  KHỞI NGUYÊN", Rect2(22, 145, 240, 22), 11, TEAL)
	_text(story, "Một nguồn sức mạnh cổ xưa\nđang thức tỉnh dưới long động.\nCùng rồng khám phá bí mật đầu tiên.", Rect2(22, 181, 240, 74), 13, MUTED)
	_button(story, "Khám phá    >", Rect2(22, 272, 232, 46), false, "Chiến đấu · Cốt truyện")
	_text(canvas, "✧  Thế giới đang chờ bạn khám phá", Rect2(42, 556, 320, 24), 12, MUTED)
	_button(canvas, "🔥 Boss Thế Giới (3 Người · Farm Vàng)", Rect2(34, 604, 402, 38), true, "Boss Thế Giới")
	# Central companion, drawn as an independent reusable vector asset.
	_text(canvas, "RỒNG YÊU THÍCH", Rect2(533, 179, 220, 23), 11, TEAL).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dragon = TextureRect.new()
	dragon.texture = null
	dragon.position = Vector2(390, 204)
	dragon.size = Vector2(500, 350)
	dragon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dragon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dragon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(dragon)
	dragon.set_deferred("size", Vector2(500, 350))
	var nameplate := _panel(canvas, Rect2(509, 525, 266, 68), Color("102c36eb"), Color("4c7476"), 16)
	favorite_name = _text(nameplate, "", Rect2(10, 9, 246, 26), 18)
	favorite_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	favorite_name.clip_text = true
	favorite_info = _text(nameplate, "", Rect2(10, 40, 246, 20), 11, TEAL)
	favorite_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	favorite_empty = Control.new()
	favorite_empty.position = Vector2(365,280)
	favorite_empty.size = Vector2(555,200)
	canvas.add_child(favorite_empty)
	_text(favorite_empty,"☆",Rect2(0,0,555,65),50,GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text(favorite_empty,"Chưa có rồng yêu thích",Rect2(0,77,555,35),23).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text(favorite_empty,"Đánh dấu ☆ trong Bộ sưu tập để trưng bày tại đây.",Rect2(0,122,555,30),14,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(favorite_empty,"Chọn rồng yêu thích",Rect2(145,163,265,40),false,"Bộ sưu tập")
	favorite_previous = _button(canvas,"<",Rect2(360,365,45,45))
	favorite_next = _button(canvas,">",Rect2(880,365,45,45))
	for button in [favorite_previous,favorite_next]:
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
	favorite_previous.pressed.connect(_cycle_favorite.bind(-1))
	favorite_next.pressed.connect(_cycle_favorite.bind(1))
	_refresh_favorite()
	var care_shortcut := _button(canvas,"Chăm sóc và cho rồng ăn",Rect2(455,604,374,38))
	for connection in care_shortcut.pressed.get_connections():
		care_shortcut.pressed.disconnect(connection.callable)
	care_shortcut.pressed.connect(func(): home_scroll.scroll_vertical = 600)
	care_panel = _panel(canvas,Rect2(34,690,1212,420),Color("102c36f0"),Color("537976"))
	_refresh_care()

	# Summon is the primary entry point.
	var summon := _panel(canvas, Rect2(959, 198, 287, 340), Color("183c43f0"), Color("bba469"))
	_text(summon, "✦  TRIỆU HỒI RỒNG", Rect2(23, 20, 250, 22), 12, GOLD)
	_text(summon, "Hắc Hỏa\nthức giấc", Rect2(23, 56, 250, 80), 31)
	_text(summon, "HỎA  /  BÓNG TỐI", Rect2(23, 150, 250, 24), 13, TEAL)
	_text(summon, "Cơ bản 0,1% · Rồng 2 hệ\nBảo hiểm vàng sau tối đa 60 lượt", Rect2(23, 189, 250, 52), 13, MUTED)
	_text(summon, "✧     RỒNG NỔI BẬT     ✧", Rect2(23, 241, 240, 24), 13, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(summon, "Triệu hồi    ✦", Rect2(22, 278, 243, 44), true, "Triệu hồi")
	_text(canvas, "Điểm trong game · Không nạp tiền", Rect2(964, 556, 290, 24), 12, MUTED)
	# Bottom navigation.
	_panel(self, Rect2(0, 654, 1280, 66), Color("0b202af5"), Color("344c51"), 0)
	var tabs := ["•   Trang chủ", "•   Chiến đấu", "▧   Bộ sưu tập", "✦   Triệu hồi", "♧   Hợp thể"]
	for i in range(tabs.size()):
		var tab := _button(self, tabs[i], Rect2(30 + i * 246, 665, 234, 44), i == 0)
		if i == 0:
			for connection in tab.pressed.get_connections():
				tab.pressed.disconnect(connection.callable)
			tab.pressed.connect(func(): home_scroll.scroll_vertical = 0)
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

func _refresh_top_resources() -> void:
	if user_name_label != null:
		user_name_label.text = WorldBossSystem.current_username
	if gold_value != null:
		gold_value.text = str(PlayerProfile.gold)
	if diamond_value != null:
		diamond_value.text = str(PlayerProfile.diamonds)
	if food_value != null:
		food_value.text = str(PlayerProfile.food)

func _show_login_modal() -> void:
	if is_instance_valid(login_modal):
		remove_child(login_modal)
		login_modal.queue_free()
	login_modal = Control.new()
	login_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(login_modal)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.06, 0.09, 0.85)
	login_modal.add_child(shade)
	var card := _panel(login_modal, Rect2(260, 82, 760, 550), Color("102c36"), GOLD, 18)
	_text(card, "ĐĂNG NHẬP & LƯU DỮ LIỆU ĐÁM MÂY (CLOUDFLARE)", Rect2(28, 20, 700, 34), 22, GOLD)
	_text(card, "Tài khoản đang hoạt động: %s  ·  Vàng: %d  ·  Rồng: %d" % [WorldBossSystem.current_username, PlayerProfile.gold, PlayerCollection.owned_count()], Rect2(28, 56, 700, 26), 15, TEAL)
	_text(card, "Chuyển nhanh giữa 3 người chơi trong phòng săn Boss Thế Giới:", Rect2(28, 94, 700, 24), 14, MUTED)

	var status_lbl := _text(card, WorldBossSystem.last_sync_status, Rect2(28, 434, 700, 28), 14, GOLD)
	for i in range(3):
		var preset_user := "Thợ Săn %d" % (i + 1)
		var is_curr := WorldBossSystem.current_username == preset_user
		var qbtn := _button(card, ("✓ " if is_curr else "👤 ") + preset_user, Rect2(28 + i * 238, 126, 224, 44), is_curr)
		for conn in qbtn.pressed.get_connections():
			qbtn.pressed.disconnect(conn.callable)
		qbtn.pressed.connect(func():
			var res := WorldBossSystem.login_or_register(preset_user, "123")
			WorldBossSystem.sync_with_cloudflare(self, "login", {"username": preset_user, "password": "123", "save_data": WorldBossSystem._snapshot_current_player_data()})
			status_lbl.text = str(res.get("message", ""))
			_refresh_top_resources()
			_refresh_favorite()
			_refresh_care()
			_show_login_modal()
		)

	_text(card, "Hoặc đăng nhập / tạo tài khoản tên riêng:", Rect2(28, 188, 400, 24), 14, MUTED)
	var user_input := LineEdit.new()
	user_input.placeholder_text = "Nhập tên tài khoản (VD: LongVuong01)"
	user_input.text = WorldBossSystem.current_username
	user_input.position = Vector2(28, 216)
	user_input.size = Vector2(340, 42)
	card.add_child(user_input)

	var pass_input := LineEdit.new()
	pass_input.placeholder_text = "Mật khẩu (mặc định: 123)"
	pass_input.secret = true
	pass_input.text = "123"
	pass_input.position = Vector2(384, 216)
	pass_input.size = Vector2(180, 42)
	card.add_child(pass_input)

	var login_btn := _button(card, "Đăng nhập / Lưu", Rect2(578, 216, 154, 42), true)
	for conn in login_btn.pressed.get_connections():
		login_btn.pressed.disconnect(conn.callable)
	login_btn.pressed.connect(func():
		var res := WorldBossSystem.login_or_register(user_input.text, pass_input.text)
		status_lbl.text = str(res.get("message", ""))
		if bool(res.get("ok", false)):
			WorldBossSystem.sync_with_cloudflare(self, "login", {"username": WorldBossSystem.current_username, "password": pass_input.text, "save_data": WorldBossSystem._snapshot_current_player_data()})
			_refresh_top_resources()
			_refresh_favorite()
			_refresh_care()
			_show_login_modal()
	)

	_text(card, "Cấu hình Cloudflare Worker / Pages API URL (Cách 1 — để trống nếu tự động dùng /api):", Rect2(28, 276, 700, 24), 13, MUTED)
	var api_input := LineEdit.new()
	api_input.placeholder_text = "VD: https://tdl-gacha-dragon.pages.dev/api"
	api_input.text = WorldBossSystem.cloudflare_api_url
	api_input.position = Vector2(28, 304)
	api_input.size = Vector2(536, 40)
	card.add_child(api_input)

	var save_api_btn := _button(card, "☁ Đồng bộ Cloud", Rect2(578, 304, 154, 40), false)
	for conn in save_api_btn.pressed.get_connections():
		save_api_btn.pressed.disconnect(conn.callable)
	save_api_btn.pressed.connect(func():
		WorldBossSystem.set_cloudflare_url(api_input.text)
		WorldBossSystem.sync_current_account_save()
		status_lbl.text = "Đang đồng bộ dữ liệu lên Cloudflare..."
		WorldBossSystem.sync_with_cloudflare(self, "save", {
			"username": WorldBossSystem.current_username,
			"save_data": WorldBossSystem._snapshot_current_player_data()
		}, func(_resp: Dictionary):
			if is_instance_valid(status_lbl):
				status_lbl.text = WorldBossSystem.last_sync_status
		)
	)

	var starter_btn := _button(card, "🎁 Nhận 3 Rồng Tinh Anh (Test săn Boss)", Rect2(28, 366, 360, 44), false)
	for conn in starter_btn.pressed.get_connections():
		starter_btn.pressed.disconnect(conn.callable)
	starter_btn.pressed.connect(func():
		status_lbl.text = WorldBossSystem.grant_starter_raid_dragons_if_needed()
		_refresh_top_resources()
		_refresh_favorite()
		_refresh_care()
	)

	var boss_go_btn := _button(card, "🔥 Vào Phòng Boss Thế Giới (3 Người)", Rect2(404, 366, 328, 44), true, "Boss Thế Giới")
	for conn in boss_go_btn.pressed.get_connections():
		boss_go_btn.pressed.disconnect(conn.callable)
	boss_go_btn.pressed.connect(func():
		WorldBossSystem.open_boss_lobby_on_enter = true
		get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
	)

	var close_btn := _button(card, "Đóng", Rect2(290, 480, 180, 44), false)
	for conn in close_btn.pressed.get_connections():
		close_btn.pressed.disconnect(conn.callable)
	close_btn.pressed.connect(func():
		if is_instance_valid(login_modal):
			remove_child(login_modal)
			login_modal.queue_free()
			login_modal = null
	)

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
	favorite_index = posmod(favorite_index,favorites.size())
	var pet := favorites[favorite_index]
	var unit := BattleCatalog.dragon(pet)
	dragon.texture = unit.portrait
	favorite_name.text = "★ "+unit.display_name
	favorite_info.text = "Cấp %d · %d / %d yêu thích" % [pet.level,favorite_index+1,favorites.size()]

func _cycle_favorite(direction: int) -> void:
	favorite_index += direction
	_refresh_favorite()

func _refresh_care() -> void:
	for child in care_panel.get_children():
		care_panel.remove_child(child)
		child.queue_free()
	_text(care_panel,"CHĂM SÓC RỒNG",Rect2(26,20,900,40),27,GOLD)
	_text(care_panel,"Chọn rồng trong bộ sưu tập và cho ăn để tăng cấp.",Rect2(28,67,1000,28),16,MUTED)
	var pets := PlayerCollection.ordered_dragons()
	if pets.is_empty():
		_text(care_panel,"Bạn chưa có rồng để chăm sóc.",Rect2(280,145,850,45),25)
		_text(care_panel,"Triệu hồi rồng mới để bắt đầu nuôi dưỡng.",Rect2(280,203,850,35),18,MUTED)
		_button(care_panel,"Đến Triệu hồi",Rect2(280,275,300,50),true,"Triệu hồi")
		return
	if care_selected == null or not pets.has(care_selected):
		care_selected = pets[0]
	var unit := BattleCatalog.dragon(care_selected)
	DragonUI.portrait(care_panel,unit.portrait,Rect2(25,112,235,245))
	var selector := OptionButton.new()
	selector.position = Vector2(285,115)
	selector.size = Vector2(865,45)
	selector.add_theme_font_size_override("font_size",18)
	care_panel.add_child(selector)
	for i in range(pets.size()):
		var row := BattleCatalog.dragon(pets[i])
		selector.add_item(("★ " if pets[i].favorite else "")+row.display_name+" · Cấp %d" % pets[i].level)
		if pets[i] == care_selected:
			selector.select(i)
	selector.item_selected.connect(func(index:int):
		care_selected = pets[index]
		care_notice = ""
		_refresh_care()
	)
	_text(care_panel,"Cấp %d  ·  Máu %d  ·  Tấn công %d  ·  Phòng thủ %d" % [care_selected.level,unit.max_hp,roundi(unit.attack),roundi(unit.defense)],Rect2(285,178,880,35),19,TEAL)
	_text(care_panel,"Thức ăn đang có: %d" % PlayerProfile.food,Rect2(285,225,800,30),18,GOLD)
	var cost := PlayerCollection.feeding_cost(care_selected)
	var feed := _button(care_panel,"Cho ăn · %d thức ăn → Cấp %d" % [cost,care_selected.level+1],Rect2(285,275,540,55),true)
	for connection in feed.pressed.get_connections():
		feed.pressed.disconnect(connection.callable)
	feed.disabled = PlayerProfile.food < cost or care_selected.level >= PlayerCollection.MAX_LEVEL
	if care_selected.level >= PlayerCollection.MAX_LEVEL:
		feed.text = "Đã đạt cấp tối đa"
	elif PlayerProfile.food < cost:
		feed.text = "Cần %d thức ăn · Hiện có %d" % [cost,PlayerProfile.food]
	feed.pressed.connect(_feed_selected)
	_text(care_panel,care_notice if not care_notice.is_empty() else "Mỗi lần cho ăn tăng 1 cấp · Chi phí: 5 × cấp hiện tại · Tối đa cấp 100",Rect2(285,350,880,40),14,MUTED)

func _feed_selected() -> void:
	var error := PlayerCollection.feed(care_selected)
	care_notice = "Rồng đã tăng lên cấp %d!" % care_selected.level if error.is_empty() else error
	food_value.text = str(PlayerProfile.food)
	_refresh_favorite()
	_refresh_care()
