class_name BannerManager
extends Node

static func current_banner() -> BannerDefinition:
	var banner := BannerDefinition.new()
	banner.id = "shadow_flame"
	banner.title = "Hắc Hỏa thức giấc"
	banner.featured_dragon_id = "fire_shadow"
	banner.weights = {"fire": 3330, "water": 3330, "shadow": 3330, "fire_shadow": 10}
	return banner
