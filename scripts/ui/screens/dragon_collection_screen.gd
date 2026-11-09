class_name DragonCollectionScreen
extends Control

const GOLD := Color("eacb83")
const MUTED := Color("a4babe")
var grid: GridContainer
var owned_tab: Button
var catalog_tab: Button
var content: VBoxContainer
var owned_page := 0
var notice := ""
var gold_label: Label
const PAGE_SIZE := 12

func _ready() -> void:
	var background := TextureRect.new()
	background.texture = preload("res://assets/textures/home_cavern.svg")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color("0a2029dc")
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 30)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)
	var header := HBoxContainer.new()
	page.add_child(header)
	var back := _button("<  Trang chủ")
	header.add_child(back)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn"))
	var brand := _label("LONG TỘC THỨC TỈNH   /   LONG ĐIỂN", 13, GOLD)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(brand)
	page.add_child(_label("Bộ sưu tập rồng", 32))
	gold_label = _label("Vàng: %d" % PlayerProfile.gold, 17, GOLD)
	header.add_child(gold_label)
	page.add_child(_label("Hỏa, Thủy và Bóng Tối — khám phá những người bạn của long động.", 15, MUTED))
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 12)
	page.add_child(tabs)
	owned_tab = _button("Đang sở hữu  ·  %d" % PlayerCollection.owned_count())
	catalog_tab = _button("Long điển  ·  7 mẫu")
	tabs.add_child(owned_tab)
	tabs.add_child(catalog_tab)
	var sell_materials := _button("Bán rồng 1 hệ")
	sell_materials.pressed.connect(_confirm_material_sale)
	tabs.add_child(sell_materials)
	owned_tab.pressed.connect(_show_owned)
	catalog_tab.pressed.connect(_show_catalog)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	page.add_child(_label("Rồng 1 hệ: nguyên liệu tăng cấp  ·  Rồng 2–3 hệ: chiến đấu  ·  Lưu cục bộ", 12, MUTED))
	_show_owned()

func _label(value: String, font_size: int, color: Color = Color("edf5e9")) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _style(color: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func _button(value: String) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 44
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", _style(Color("173640"), Color("41616a")))
	button.add_theme_stylebox_override("hover", _style(Color("28505a"), GOLD))
	button.add_theme_stylebox_override("focus", _style(Color("28505a"), Color("79d7c6")))
	return button

func _clear(selected: Button) -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	for button in [owned_tab, catalog_tab]:
		button.add_theme_color_override("font_color", GOLD if button == selected else Color("edf5e9"))

func _show_owned() -> void:
	_clear(owned_tab)
	owned_tab.text = "Đang sở hữu  ·  %d" % PlayerCollection.owned_count()
	gold_label.text = "Vàng: %d" % PlayerProfile.gold
	if PlayerCollection.owned_count() > 0:
		content.add_child(_label("Yêu thích được xếp đầu · Bán từng cá thể nhận vàng · Bỏ yêu thích trước khi bán", 14, MUTED))
		if not notice.is_empty():
			content.add_child(_label(notice, 15, GOLD))
		_build_owned_grid()
		return
	if not notice.is_empty():
		content.add_child(_label(notice,15,GOLD))
	# A species in the catalog is never counted as an owned dragon.
	var center := CenterContainer.new()
	center.custom_minimum_size.y = 340
	content.add_child(center)
	var empty := VBoxContainer.new()
	empty.add_theme_constant_override("separation", 16)
	center.add_child(empty)
	for entry in [["◇", 54, GOLD], ["Chưa có rồng nào", 27, Color("edf5e9")], ["Bạn đang sở hữu 0 rồng.\nGhé Long điển để xem 7 mẫu rồng có thể khám phá.", 16, MUTED]]:
		var label := _label(entry[0], entry[1], entry[2])
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_child(label)
	var explore := _button("Xem Long điển   >")
	empty.add_child(explore)
	explore.pressed.connect(_show_catalog)

func _show_catalog() -> void:
	_clear(catalog_tab)
	content.add_child(_label("DANH MỤC LOÀI  /  7 MẪU", 12, GOLD))
	_build_grid(false)

func _build_grid(owned_only: bool) -> void:
	grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)
	for definition in DragonCatalog.all_definitions():
		var quantity := PlayerCollection.count_species(definition.id)
		if owned_only and quantity == 0:
			continue
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(285, 290)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _style(Color("16333e"), definition.accent.darkened(0.5)))
		grid.add_child(card)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 5)
		card.add_child(column)
		column.add_child(_label("SỞ HỮU ×%d" % quantity if quantity > 0 else "CHƯA SỞ HỮU", 10, GOLD if quantity > 0 else MUTED))
		var portrait := TextureRect.new()
		portrait.texture = definition.portrait
		portrait.custom_minimum_size = Vector2(0, 135)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		column.add_child(portrait)
		column.add_child(_label(definition.display_name, 19, definition.accent))
		column.add_child(_label(" / ".join(definition.elements), 11, definition.accent))
		column.add_child(_label("NGUYÊN LIỆU TĂNG CẤP" if definition.is_upgrade_material() else "RỒNG CHIẾN ĐẤU", 10, GOLD))
		var description := _label(definition.description, 12, MUTED)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(description)

func _build_owned_grid() -> void:
	var ordered := PlayerCollection.ordered_dragons()
	var page_count := maxi(1,ceili(float(ordered.size())/PAGE_SIZE))
	owned_page = clampi(owned_page,0,page_count-1)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation",16)
	content.add_child(navigation)
	var previous := _button("< Trước")
	previous.disabled = owned_page == 0
	previous.pressed.connect(_change_owned_page.bind(-1))
	navigation.add_child(previous)
	navigation.add_child(_label("Trang %d / %d" % [owned_page+1,page_count],16,MUTED))
	var next := _button("Sau >")
	next.disabled = owned_page+1 >= page_count
	next.pressed.connect(_change_owned_page.bind(1))
	navigation.add_child(next)
	grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation",14)
	grid.add_theme_constant_override("v_separation",14)
	content.add_child(grid)
	var definitions := {}
	for definition in DragonCatalog.all_definitions():
		definitions[definition.id] = definition
	for dragon in ordered.slice(owned_page*PAGE_SIZE,(owned_page+1)*PAGE_SIZE):
		var definition: DragonDefinition = definitions[dragon.species_id]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(285,290)
		card.add_theme_stylebox_override("panel",_style(Color("16333e"),GOLD if dragon.favorite else definition.accent.darkened(0.5)))
		grid.add_child(card)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation",6)
		card.add_child(column)
		column.add_child(_label("★ YÊU THÍCH" if dragon.favorite else "RỒNG CỦA BẠN",11,GOLD if dragon.favorite else MUTED))
		var portrait := TextureRect.new()
		portrait.texture = definition.portrait
		portrait.custom_minimum_size = Vector2(0,110)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		column.add_child(portrait)
		column.add_child(_label(definition.display_name,18,definition.accent))
		column.add_child(_label("Cấp %d · %s" % [dragon.level," / ".join(definition.elements)],12,MUTED))
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation",8)
		column.add_child(actions)
		var favorite := _button("★ Đã thích" if dragon.favorite else "☆ Yêu thích")
		favorite.add_theme_font_size_override("font_size",12)
		favorite.pressed.connect(_favorite.bind(dragon))
		actions.add_child(favorite)
		var sell := _button("Bán · %d vàng" % PlayerCollection.sell_price(dragon))
		sell.add_theme_font_size_override("font_size",12)
		sell.disabled = dragon.favorite
		sell.tooltip_text = "Bỏ yêu thích để bán" if dragon.favorite else "Xem và xác nhận trước khi bán cá thể này"
		sell.pressed.connect(_confirm_sale.bind(dragon))
		actions.add_child(sell)

func _change_owned_page(direction: int) -> void:
	owned_page += direction
	_show_owned()

func _favorite(dragon: DragonInstance) -> void:
	if not PlayerCollection.set_favorite(dragon,not dragon.favorite):
		notice = "Không lưu được yêu thích. Hãy thử lại."
	else:
		notice = "Đã cập nhật yêu thích."
	owned_page = 0
	_show_owned()

func _confirm_sale(dragon: DragonInstance) -> void:
	var definition_name := "Rồng"
	for definition in DragonCatalog.all_definitions():
		if definition.id == dragon.species_id:
			definition_name = definition.display_name
	var dialog := ConfirmationDialog.new()
	dialog.title = "Xác nhận bán rồng"
	dialog.dialog_text = "Bán %s cấp %d?\nBạn nhận %d vàng và cá thể này sẽ rời bộ sưu tập." % [definition_name,dragon.level,PlayerCollection.sell_price(dragon)]
	dialog.ok_button_text = "Bán rồng"
	dialog.cancel_button_text = "Giữ lại"
	add_child(dialog)
	dialog.confirmed.connect(func():
		var price := PlayerCollection.sell_price(dragon)
		var error := PlayerCollection.sell(dragon)
		notice = "Đã bán rồng, nhận %d vàng." % price if error.is_empty() else error
		_show_owned()
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(560,200))

func _confirm_material_sale() -> void:
	var candidates := PlayerCollection.sale_materials()
	var gold := 0
	for dragon in candidates:
		gold += PlayerCollection.sell_price(dragon)
	if candidates.is_empty():
		notice = "Không có rồng 1 hệ có thể bán. Rồng yêu thích được giữ lại."
		_show_owned()
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Bán toàn bộ rồng 1 hệ"
	dialog.dialog_text = "Bán %d rồng 1 hệ để nhận %d vàng?\nRồng yêu thích và rồng 2–3 hệ được giữ lại." % [candidates.size(),gold]
	dialog.ok_button_text = "Bán tất cả"
	dialog.cancel_button_text = "Giữ lại"
	add_child(dialog)
	dialog.confirmed.connect(func():
		var result := PlayerCollection.sell_materials()
		notice = "Đã bán %d rồng 1 hệ, nhận %d vàng." % [result.count,result.gold] if result.error.is_empty() else result.error
		_show_owned()
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(570,200))
