class_name DragonUI
extends RefCounted

static func style(color: Color, border: Color, radius: int = 18) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	return box

static func panel(parent: Node, rect: Rect2, color: Color = Color("142937"), border: Color = Color("3c5663")) -> Panel:
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_stylebox_override("panel", style(color, border))
	parent.add_child(node)
	return node

static func text(parent: Node, value: String, rect: Rect2, font_size: int = 16, color: Color = Color("eef3ec"), wrap: bool = false) -> Label:
	var label := Label.new()
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

static func button(parent: Node, value: String, rect: Rect2, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("172b36") if primary else Color("e8f0e9"))
	button.add_theme_stylebox_override("normal", style(Color("edce88") if primary else Color("203b49"), Color("cfb57b") if primary else Color("4c6975"), 13))
	button.add_theme_stylebox_override("hover", style(Color("b99ce0") if primary else Color("335263"), Color("e9ce99"), 13))
	button.add_theme_stylebox_override("focus", style(Color("576077"), Color("f2d79a"), 13))
	button.add_theme_stylebox_override("disabled", style(Color("293d48"), Color("45545e"), 13))
	parent.add_child(button)
	return button

static func portrait(parent: Node, texture: Texture2D, rect: Rect2) -> TextureRect:
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = texture
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	image.set_deferred("size", rect.size)
	DragonAnimator.attach(image)
	return image
