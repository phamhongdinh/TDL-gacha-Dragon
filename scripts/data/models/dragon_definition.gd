class_name DragonDefinition
extends Resource

@export var id: String
@export var display_name: String
@export var elements: Array[String] = []
@export var description: String
@export var accent: Color = Color.WHITE
@export var portrait: Texture2D

func is_upgrade_material() -> bool:
	return elements.size() == 1
