class_name BattleCatalog
extends RefCounted

static var config: Dictionary = {}

static func data() -> Dictionary:
	if config.is_empty():
		config = JSON.parse_string(FileAccess.get_file_as_string("res://resources/battle/config.json"))
	return config

static func element_for(names: Array[String]) -> String:
	for name in names:
		for id in data().elements:
			if data().elements[id].catalog_names.has(name):
				return id
	return ""

static func dragon(instance: DragonInstance) -> BattleUnitData:
	var unit := BattleUnitData.new()
	for definition in DragonCatalog.all_definitions():
		if definition.id != instance.species_id:
			continue
		unit.id = instance.instance_id
		unit.display_name = definition.display_name
		unit.element = element_for(definition.elements)
		unit.portrait = definition.portrait
		var stats: Dictionary = data().dragon_stats[str(definition.elements.size())]
		var growth := 1 + .08 * (instance.level - 1)
		var passive: Dictionary = data().elements.get(unit.element,{}).get("passive",{})
		unit.max_hp = roundi(stats.hp * growth * passive.get("hp",1))
		unit.hp = unit.max_hp
		unit.attack = stats.attack * growth * passive.get("attack",1)
		unit.defense = stats.defense * growth * passive.get("defense",1)
		unit.speed = int(stats.speed)
		unit.skill = data().elements.get(unit.element,{}).get("skill","basic")
		for element_name in definition.elements:
			var names: Array[String] = [element_name]
			var key := element_for(names)
			var ability: String = data().elements.get(key,{}).get("skill","basic")
			if ability != "basic" and not unit.skills.has(ability):
				unit.skills.append(ability)
		unit.passive_name = passive.get("name","")
	return unit

static func enemy(species: String, index: int, wave: int, scale: float) -> BattleUnitData:
	var row: Dictionary = data().enemies[species]
	var unit := BattleUnitData.new()
	unit.id = "enemy_%d_%d" % [wave,index]
	unit.side = "enemy"
	unit.display_name = row.name
	unit.max_hp = roundi(row.hp * scale)
	unit.hp = unit.max_hp
	unit.attack = row.attack * scale
	unit.defense = row.defense * scale
	unit.speed = int(row.speed)
	unit.element = row.element
	unit.skill = row.skill
	unit.ai = row.ai
	unit.immunities = row.immunities.duplicate()
	unit.enrage = row.get("enrage",{}).duplicate(true)
	unit.portrait = load("res://assets/textures/enemies/%s.svg" % row.portrait)
	return unit

static func chapter(id: String) -> Dictionary:
	for row in data().chapters:
		if row.id == id:
			return row
	return {}

static func chapter_unlocked(id: String) -> bool:
	var rows: Array = data().chapters
	for i in range(rows.size()):
		if rows[i].id == id:
			return i == 0 or PlayerProfile.stage_stars.has(rows[i-1].id)
	return false

static func chapter_enemy(chapter_id: String,index: int) -> BattleUnitData:
	var row := chapter(chapter_id)
	var unit := enemy(row.monsters[index],index,0,1.0)
	unit.max_hp = roundi(unit.max_hp * row.hp_scale)
	unit.hp = unit.max_hp
	unit.attack *= row.attack_scale
	return unit
