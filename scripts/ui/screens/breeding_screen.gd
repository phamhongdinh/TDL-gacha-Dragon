class_name BreedingScreen
extends Control

const GOLD := Color("eacb83")
const MUTED := Color("a8bbc4")
var selectors: Array[Button] = []
var images: Array[TextureRect] = []
var parent_names: Array[Label] = []
var selected_species: Array[String] = ["", ""]
var catalog := {}
var note: Label
var status: Label
var action: Button
var combinations_button: Button
var busy := false
var modal: Control
var navigation: Array[Button] = []
var last_cooldown := -1
var preview_species: Array[String] = []

func _process(_delta:float) -> void:
	var remaining := BreedingManager.cooldown_remaining()
	if action != null and remaining != last_cooldown:
		last_cooldown = remaining
		_update_action()

func _update_action() -> void:
	var remaining := BreedingManager.cooldown_remaining()
	var plan := BreedingManager.recipe(_parent(0),_parent(1))
	action.disabled = busy or is_instance_valid(modal) or remaining > 0 or not plan.error.is_empty()
	action.text = "Hồi hợp thể · %d giây" % remaining if remaining > 0 else "Hợp thể"

func _ready() -> void:
	for definition in DragonCatalog.all_definitions():
		catalog[definition.id] = definition
	var backdrop := TextureRect.new()
	backdrop.texture = preload("res://assets/textures/home_cavern.svg")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.modulate = Color("9ec8c2")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	DragonUI.panel(self,Rect2(0,0,1280,720),Color("0b2233df"),Color.TRANSPARENT)
	var back := DragonUI.button(self,"< Quay lại",Rect2(32,26,165,44))
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn"))
	navigation.append(back)
	DragonUI.text(self,"Hợp thể rồng thần",Rect2(270,87,740,55),36,GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	DragonUI.text(self,"Hợp nhất hai dòng sức mạnh, đánh thức một sinh mệnh huyền bí.",Rect2(260,148,760,28),15,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(2):
		var x := 38 if i == 0 else 920
		DragonUI.panel(self,Rect2(x,200,322,333),Color("173440"),Color("507779"))
		DragonUI.text(self,"RỒNG THỨ NHẤT" if i == 0 else "RỒNG THỨ HAI",Rect2(x+20,219,280,25),13,GOLD)
		images.append(DragonUI.portrait(self,null,Rect2(x+30,252,262,182)))
		var name_label := DragonUI.text(self,"Chưa chọn loại rồng",Rect2(x+15,438,292,25),17)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		parent_names.append(name_label)
		var choose := DragonUI.button(self,"Chọn loại rồng",Rect2(x+16,481,290,38))
		choose.pressed.connect(_open_selector.bind(i))
		selectors.append(choose)
	DragonUI.text(self,"+",Rect2(371,340,45,46),40,GOLD)
	DragonUI.text(self,"+",Rect2(864,340,45,46),40,GOLD)
	DragonUI.panel(self,Rect2(428,200,424,333),Color("263747"),Color("a99b78"))
	DragonUI.text(self,"KẾT QUẢ CÓ THỂ NHẬN",Rect2(450,219,380,26),13,GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	DragonUI.portrait(self,preload("res://assets/textures/fusion_egg.svg"),Rect2(523,249,234,185))
	combinations_button = DragonUI.button(self,"Xem tổ hợp rồng",Rect2(466,469,348,46))
	combinations_button.pressed.connect(_show_combinations)
	note = DragonUI.text(self,"",Rect2(40,550,1200,40),14,MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	DragonUI.panel(self,Rect2(34,601,1212,94),Color("142c39"),Color("536a71"))
	status = DragonUI.text(self,"",Rect2(56,620,800,59),14,MUTED)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action = DragonUI.button(self,"Hợp thể",Rect2(925,621,295,51),true)
	action.pressed.connect(_breed)
	_update_preview()

func _parent(index:int) -> DragonInstance:
	for dragon in PlayerCollection.owned_dragons:
		if dragon.species_id == selected_species[index]:
			return dragon
	return null

func _choose_species(slot:int,species:String) -> void:
	if busy or not catalog.has(species) or PlayerCollection.count_species(species) == 0 or selected_species[1-slot] == species:
		return
	selected_species[slot] = species
	_close_modal()
	_update_preview()

func _update_preview() -> void:
	for i in range(2):
		var parent := _parent(i)
		images[i].texture = catalog[parent.species_id].portrait if parent != null else null
		parent_names[i].text = catalog[parent.species_id].display_name if parent != null else "Chưa chọn loại rồng"
		selectors[i].text = "Đổi loại rồng" if parent != null else "Chọn loại rồng"
	var plan := BreedingManager.recipe(_parent(0),_parent(1))
	_update_action()
	combinations_button.disabled = busy or is_instance_valid(modal) or _parent(0) == null or _parent(1) == null
	note.text = "Hai dòng nguyên tố đã sẵn sàng hợp thể." if plan.error.is_empty() else plan.error
	status.text = "Luôn nhận một rồng sau hợp thể; hai rồng ban đầu được giữ nguyên.\nThời gian hồi 30 giây tính từ lúc bắt đầu hợp thể."

func _lock_controls(locked:bool) -> void:
	for button in navigation + selectors + [combinations_button,action]:
		button.disabled = locked

func _new_modal(title:String,subtitle:String) -> void:
	_lock_controls(true)
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.z_index = 25
	add_child(modal)
	DragonUI.panel(modal,Rect2(0,0,1280,720),Color("06101bed"),Color.TRANSPARENT)
	DragonUI.panel(modal,Rect2(110,43,1060,634),Color("162c3b"),Color("778c8c"))
	DragonUI.text(modal,title,Rect2(139,65,890,43),29,GOLD)
	DragonUI.text(modal,subtitle,Rect2(140,115,910,30),13,MUTED)
	var close := DragonUI.button(modal,"Đóng",Rect2(1054,68,87,38))
	close.pressed.connect(_close_modal)
	close.grab_focus()

func _close_modal() -> void:
	if is_instance_valid(modal):
		remove_child(modal)
		modal.queue_free()
	modal = null
	_lock_controls(busy)
	_update_preview()

func _open_selector(slot:int) -> void:
	if busy or is_instance_valid(modal):
		return
	_new_modal("Chọn loại rồng thứ nhất" if slot == 0 else "Chọn loại rồng thứ hai","Chọn theo hình và nguyên tố. Mỗi loại chỉ xuất hiện một lần.")
	var index := 0
	for definition in DragonCatalog.all_definitions():
		var x := 141+(index%4)*251
		var y := 166+floori(index/4.0)*243
		var owned := PlayerCollection.count_species(definition.id)>0
		var used := selected_species[1-slot] == definition.id
		DragonUI.panel(modal,Rect2(x,y,235,225),Color("203c49"),definition.accent.darkened(.4))
		var portrait := DragonUI.portrait(modal,definition.portrait,Rect2(x+25,y+8,185,135))
		portrait.modulate.a = 1.0 if owned else .32
		DragonUI.text(modal,definition.display_name,Rect2(x+11,y+143,215,29),15,definition.accent).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var button := DragonUI.button(modal,"Chưa sở hữu" if not owned else ("Đã chọn ở ô khác" if used else "Chọn rồng"),Rect2(x+13,y+181,209,33))
		button.add_theme_font_size_override("font_size",12)
		button.disabled = not owned or used
		button.pressed.connect(_choose_species.bind(slot,definition.id))
		index += 1

func _show_combinations() -> void:
	if busy or is_instance_valid(modal) or _parent(0) == null or _parent(1) == null:
		return
	var first: DragonDefinition = catalog[selected_species[0]]
	var second: DragonDefinition = catalog[selected_species[1]]
	var outcomes := BreedingManager.possible_outcomes(_parent(0),_parent(1))
	preview_species.clear()
	_new_modal("Kết quả từ cặp rồng đã chọn",first.display_name+" + "+second.display_name)
	DragonUI.panel(modal,Rect2(141,159,998,109),Color("213f4c"),Color("506c78"))
	DragonUI.portrait(modal,first.portrait,Rect2(210,164,113,95))
	DragonUI.text(modal,first.display_name,Rect2(336,191,237,43),17,first.accent)
	DragonUI.text(modal,"+",Rect2(617,189,42,44),30,GOLD)
	DragonUI.portrait(modal,second.portrait,Rect2(694,164,113,95))
	DragonUI.text(modal,second.display_name,Rect2(815,191,279,43),17,second.accent)
	if outcomes.is_empty():
		DragonUI.text(modal,"Cặp rồng này chưa có tổ hợp hợp thể phù hợp.",Rect2(165,357,950,70),20,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return
	DragonUI.text(modal,"CHỈ CÁC RỒNG DƯỚI ĐÂY CÓ THỂ XUẤT HIỆN",Rect2(143,287,992,30),13,GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var card_width := 235
	var gap := 17
	var start := 640-(outcomes.size()*card_width+(outcomes.size()-1)*gap)/2
	for i in range(outcomes.size()):
		var definition := outcomes[i]
		preview_species.append(definition.id)
		var x := start+i*(card_width+gap)
		DragonUI.panel(modal,Rect2(x,331,card_width,244),Color("23394c"),definition.accent.darkened(.3))
		DragonUI.portrait(modal,definition.portrait,Rect2(x+19,343,197,157))
		DragonUI.text(modal,definition.display_name,Rect2(x+8,507,219,31),16,definition.accent).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		DragonUI.text(modal,"Rồng thần" if definition.elements.size()>1 else "Rồng một hệ",Rect2(x+8,546,219,24),12,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	DragonUI.text(modal,"Mỗi lần hợp thể nhận một trong các rồng trên. Hai rồng ban đầu vẫn được giữ nguyên.",Rect2(144,612,992,30),13,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _breed() -> void:
	if busy or is_instance_valid(modal):
		return
	var plan := BreedingManager.recipe(_parent(0),_parent(1))
	if BreedingManager.cooldown_remaining() > 0:
		_update_action()
		return
	if not plan.error.is_empty():
		note.text = plan.error
		return
	busy = true
	_lock_controls(true)
	var result := BreedingManager.attempt(_parent(0),_parent(1))
	status.text = "Hai nguồn nguyên tố đang hợp nhất…"
	AudioManager.play("charge")
	await get_tree().create_timer(1.5).timeout
	AudioManager.stop_cinematic()
	if result.offspring != null:
		var hatch_result := GachaResult.new()
		hatch_result.dragons.append(result.offspring)
		var hatch := GachaHatch.new()
		hatch.z_index = 30
		hatch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(hatch)
		hatch.setup(hatch_result,true)
		await hatch.finished
		remove_child(hatch)
		hatch.queue_free()
	busy = false
	_lock_controls(false)
	_update_preview()
	if not result.error_message.is_empty():
		status.text = result.error_message
	elif result.success:
		status.text = "Hợp thể thành công! %s đã nở và được lưu trong Bộ sưu tập.\nHai rồng ban đầu vẫn được giữ nguyên." % catalog[result.offspring.species_id].display_name
	else:
		status.text = "Chưa tạo được rồng thần. Bạn nhận %s, đã lưu vào Bộ sưu tập.\nHai rồng ban đầu vẫn được giữ nguyên." % catalog[result.offspring.species_id].display_name
