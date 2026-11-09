class_name SettingsScreen
extends Control

var sound_toggle: CheckButton
var music_slider: HSlider
var effects_slider: HSlider

func _ready() -> void:
	DragonUI.panel(self,Rect2(0,0,1280,720),Color("0d1c2b"),Color.TRANSPARENT)
	var back := DragonUI.button(self,"< Quay lại",Rect2(32,26,160,44))
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn"))
	DragonUI.text(self,"Cài đặt",Rect2(280,114,700,60),36,Color("edcf8d"))
	DragonUI.text(self,"Tùy chỉnh âm thanh theo cách bạn muốn trải nghiệm.",Rect2(280,176,730,30),16,Color("a4bac4"))
	DragonUI.panel(self,Rect2(260,232,760,378),Color("182e3e"),Color("59707a"))
	sound_toggle = CheckButton.new()
	sound_toggle.text = "Bật âm thanh"
	sound_toggle.position = Vector2(295,258)
	sound_toggle.size = Vector2(685,50)
	sound_toggle.button_pressed = not AudioManager.muted
	sound_toggle.toggled.connect(_toggle)
	add_child(sound_toggle)
	music_slider = _slider("Nhạc nền",350,AudioManager.music_level)
	effects_slider = _slider("Hiệu ứng âm thanh",448,AudioManager.effects_level)
	music_slider.value_changed.connect(func(value:float): AudioManager.set_music_level(value/100))
	effects_slider.value_changed.connect(func(value:float): AudioManager.set_effects_level(value/100))
	DragonUI.text(self,"Lựa chọn được tự động lưu trên thiết bị này.",Rect2(296,554,680,30),14,Color("a4bac4"))
	_toggle(not AudioManager.muted)

func _slider(title:String,y:float,value:float) -> HSlider:
	DragonUI.text(self,title,Rect2(298,y,670,26),17)
	var slider := HSlider.new()
	slider.position = Vector2(298,y+38)
	slider.size = Vector2(674,27)
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = roundi(value*100)
	slider.tooltip_text = title
	add_child(slider)
	return slider

func _toggle(enabled:bool) -> void:
	AudioManager.set_muted(not enabled)
	music_slider.editable = enabled
	effects_slider.editable = enabled
