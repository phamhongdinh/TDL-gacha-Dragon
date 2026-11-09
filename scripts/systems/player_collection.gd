class_name PlayerCollection
extends Node

# No starter dragons are granted. Rolls add individual, persistent instances.
static var owned_dragons: Array[DragonInstance] = []
static var pity_count: int = 0
static var fusion_ready_at: float = 0.0
const SELL_VALUES := {"1":100,"2":1000,"3":5000}
const MAX_LEVEL := 100
const FEED_BASE_COST := 5

static func feeding_cost(dragon: DragonInstance) -> int:
	return FEED_BASE_COST * dragon.level

static func feed(dragon: DragonInstance) -> String:
	if not owned_dragons.has(dragon):
		return "Rồng không còn trong bộ sưu tập."
	if dragon.level >= MAX_LEVEL:
		return "Rồng đã đạt cấp tối đa."
	var cost := feeding_cost(dragon)
	if PlayerProfile.food < cost:
		return "Chưa đủ thức ăn. Hãy chiến đấu để nhận thêm."
	var old_level := dragon.level
	var old_food := PlayerProfile.food
	dragon.level += 1
	PlayerProfile.food -= cost
	if LocalSaveStore.save_dragons(owned_dragons,pity_count) != OK:
		dragon.level = old_level
		PlayerProfile.food = old_food
		return "Không lưu được. Cấp rồng và thức ăn được giữ nguyên."
	return ""

static func ordered_dragons() -> Array[DragonInstance]:
	var favorites: Array[DragonInstance] = []
	var others: Array[DragonInstance] = []
	for dragon in owned_dragons:
		if dragon.favorite:
			favorites.append(dragon)
		else:
			others.append(dragon)
	favorites.append_array(others)
	return favorites

static func set_favorite(dragon: DragonInstance, value: bool) -> bool:
	if not owned_dragons.has(dragon):
		return false
	var previous := dragon.favorite
	dragon.favorite = value
	if LocalSaveStore.save_dragons(owned_dragons,pity_count) != OK:
		dragon.favorite = previous
		return false
	return true

static func sell_price(dragon: DragonInstance) -> int:
	for definition in DragonCatalog.all_definitions():
		if definition.id == dragon.species_id:
			return int(SELL_VALUES[str(definition.elements.size())]) * maxi(1,dragon.level)
	return 0

static func sell(dragon: DragonInstance) -> String:
	if not owned_dragons.has(dragon):
		return "Rồng này không còn trong bộ sưu tập."
	if dragon.favorite:
		return "Hãy bỏ yêu thích trước khi bán rồng này."
	var price := sell_price(dragon)
	if price <= 0:
		return "Không xác định được giá bán."
	var remaining: Array[DragonInstance] = owned_dragons.duplicate()
	remaining.erase(dragon)
	var old_gold := PlayerProfile.gold
	PlayerProfile.gold += price
	if LocalSaveStore.save_dragons(remaining,pity_count) != OK:
		PlayerProfile.gold = old_gold
		return "Không lưu được giao dịch. Rồng và vàng vẫn được giữ nguyên."
	owned_dragons = remaining
	return ""

static func owned_count() -> int:
	return owned_dragons.size()

static func count_species(species_id: String) -> int:
	var count := 0
	for dragon in owned_dragons:
		if dragon.species_id == species_id:
			count += 1
	return count

static func add_batch(dragons: Array[DragonInstance], next_pity: int = -1, next_fusion_ready_at: float = -1.0) -> bool:
	var updated: Array[DragonInstance] = owned_dragons.duplicate()
	updated.append_array(dragons)
	var updated_pity := pity_count if next_pity < 0 else next_pity
	var updated_ready_at := fusion_ready_at if next_fusion_ready_at < 0 else next_fusion_ready_at
	if LocalSaveStore.save_dragons(updated, updated_pity, updated_ready_at) != OK:
		return false
	owned_dragons = updated
	pity_count = updated_pity
	fusion_ready_at = updated_ready_at
	return true

static func sale_materials() -> Array[DragonInstance]:
	var result: Array[DragonInstance] = []
	for dragon in owned_dragons:
		for definition in DragonCatalog.all_definitions():
			if definition.id == dragon.species_id and definition.elements.size() == 1 and not dragon.favorite:
				result.append(dragon)
	return result

static func sell_materials() -> Dictionary:
	var candidates := sale_materials()
	var remaining: Array[DragonInstance] = owned_dragons.duplicate()
	var gold := 0
	for dragon in candidates:
		gold += sell_price(dragon)
		remaining.erase(dragon)
	if candidates.is_empty():
		return {"count":0,"gold":0,"error":"Không có rồng 1 hệ có thể bán."}
	var previous := PlayerProfile.gold
	PlayerProfile.gold += gold
	if LocalSaveStore.save_dragons(remaining,pity_count) != OK:
		PlayerProfile.gold = previous
		return {"count":0,"gold":0,"error":"Không lưu được. Rồng và vàng được giữ nguyên."}
	owned_dragons = remaining
	return {"count":candidates.size(),"gold":gold,"error":""}
