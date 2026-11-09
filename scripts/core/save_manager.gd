class_name LocalSaveStore
extends Node

const SAVE_PATH := "user://collection.json"
static var load_error: String = ""

func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		load_error = "Không đọc được dữ liệu bộ sưu tập."
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary or (data.get("version") != 1 and data.get("version") != 2) or not data.get("dragons") is Array:
		load_error = "Dữ liệu bộ sưu tập không hợp lệ. Không ghi đè file lưu."
		return
	var pity: Variant = data.get("pity_count", 0) if data.version == 2 else 0
	if not (pity is float or pity is int) or pity < 0 or pity > 59 or pity != floor(pity):
		load_error = "Bộ đếm bảo hiểm không hợp lệ. Không ghi đè file lưu."
		return
	var restored: Array[DragonInstance] = []
	var diamonds: Variant = data.get("diamonds", 280)
	if not (diamonds is float or diamonds is int) or diamonds < 0 or diamonds != floor(diamonds):
		load_error = "Số kim cương không hợp lệ. Không ghi đè file lưu."
		return
	var known := {}
	var pve: Variant = data.get("pve",{})
	if not pve is Dictionary:
		load_error = "Tiến trình chiến đấu không hợp lệ."
		return
	for key in ["gold","food","shards"]:
		var value: Variant = pve.get(key,0)
		if not (value is int or value is float) or value < 0 or value != floor(value):
			load_error = "Tài nguyên chiến đấu không hợp lệ."
			return
	var saved_stars: Variant = pve.get("stage_stars",{})
	if not saved_stars is Dictionary:
		load_error = "Số sao màn chơi không hợp lệ."
		return
	for value in saved_stars.values():
		if not (value is int or value is float) or value < 1 or value > 3 or value != floor(value):
			load_error = "Số sao màn chơi không hợp lệ."
			return
	var ready_at: Variant = data.get("fusion_ready_at", 0)
	if not (ready_at is float or ready_at is int) or ready_at < 0 or not is_finite(float(ready_at)):
		load_error = "Thời gian chờ hợp thể không hợp lệ."
		return
	var seen := {}
	for definition in DragonCatalog.all_definitions():
		known[definition.id] = true
	for row in data.dragons:
		if not row is Dictionary:
			load_error = "Dữ liệu rồng không hợp lệ."
			return
		var id: Variant = row.get("instance_id", "")
		var species: Variant = row.get("species_id", "")
		var level: Variant = row.get("level", 1)
		if not id is String or id.is_empty() or seen.has(id) or not species is String or not known.has(species) or not (level is float or level is int) or level < 1 or level != floor(level):
			load_error = "Dữ liệu rồng không hợp lệ. Không ghi đè file lưu."
			return
		seen[id] = true
		var dragon := DragonInstance.new()
		dragon.instance_id = id
		dragon.species_id = species
		dragon.level = int(level)
		if not row.get("favorite", false) is bool:
			load_error = "Đánh dấu yêu thích không hợp lệ. Không ghi đè file lưu."
			return
		dragon.favorite = row.get("favorite", false)
		if not row.get("parent_a_id", "") is String or not row.get("parent_b_id", "") is String:
			load_error = "Thông tin bố mẹ không hợp lệ."
			return
		dragon.parent_a_id = row.get("parent_a_id", "")
		dragon.parent_b_id = row.get("parent_b_id", "")
		restored.append(dragon)
	PlayerCollection.owned_dragons = restored
	PlayerCollection.pity_count = int(pity)
	PlayerProfile.diamonds = int(diamonds)
	PlayerCollection.fusion_ready_at = float(ready_at)
	PlayerProfile.gold = int(pve.get("gold",12500))
	PlayerProfile.food = int(pve.get("food",36))
	PlayerProfile.shards = int(pve.get("shards",0))
	PlayerProfile.stage_stars = saved_stars.duplicate()

static func save_dragons(dragons: Array[DragonInstance], pity: int = 0, ready_at: float = -1.0) -> Error:
	if not load_error.is_empty():
		return ERR_FILE_CORRUPT
	var rows: Array[Dictionary] = []
	for dragon in dragons:
		rows.append({"instance_id": dragon.instance_id, "species_id": dragon.species_id, "level": dragon.level, "favorite": dragon.favorite, "parent_a_id": dragon.parent_a_id, "parent_b_id": dragon.parent_b_id})
	var temporary := SAVE_PATH + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version": 2, "dragons": rows, "pity_count": pity, "diamonds": PlayerProfile.diamonds, "fusion_ready_at": PlayerCollection.fusion_ready_at if ready_at < 0 else ready_at,"pve":{"gold":PlayerProfile.gold,"food":PlayerProfile.food,"shards":PlayerProfile.shards,"stage_stars":PlayerProfile.stage_stars}}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporary, SAVE_PATH)
