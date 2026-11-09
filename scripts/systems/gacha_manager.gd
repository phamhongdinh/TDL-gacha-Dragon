class_name GachaManager
extends Node

const PITY_LIMIT := 60

static func species_with_pity(banner: BannerDefinition, ticket: int, pity: int) -> String:
	if pity >= PITY_LIMIT - 1:
		return banner.featured_dragon_id
	return species_for_ticket(banner, ticket)

static func species_for_ticket(banner: BannerDefinition, ticket: int) -> String:
	var cumulative := 0
	for species in banner.weights:
		cumulative += int(banner.weights[species])
		if ticket < cumulative and ticket >= 0:
			return species
	return ""

static func roll(count: int) -> GachaResult:
	var result := GachaResult.new()
	if count != 1 and count != 10:
		result.error_message = "Chỉ hỗ trợ triệu hồi ×1 hoặc ×10."
		return result
	var banner := BannerManager.current_banner()
	var total := 0
	for weight in banner.weights.values():
		total += int(weight)
	var random := RandomNumberGenerator.new()
	random.randomize()
	var next_pity := PlayerCollection.pity_count
	for i in range(count):
		var dragon := DragonInstance.new()
		dragon.instance_id = Crypto.new().generate_random_bytes(16).hex_encode()
		dragon.species_id = species_with_pity(banner, random.randi_range(0, total - 1), next_pity)
		next_pity = 0 if dragon.species_id == banner.featured_dragon_id else next_pity + 1
		result.dragons.append(dragon)
	if not PlayerCollection.add_batch(result.dragons, next_pity):
		result.dragons.clear()
		result.error_message = "Không lưu được kết quả. Chưa có rồng nào được thêm.\n" + LocalSaveStore.load_error
	return result
