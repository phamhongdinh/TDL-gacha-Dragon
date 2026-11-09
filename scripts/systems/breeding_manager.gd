class_name BreedingManager
extends Node

const COOLDOWN_SECONDS := 30

static func cooldown_remaining() -> int:
	return maxi(0,ceili(PlayerCollection.fusion_ready_at - Time.get_unix_time_from_system()))

static func recipe(parent_a: DragonInstance, parent_b: DragonInstance) -> Dictionary:
	if parent_a == null or parent_b == null:
		return {"error": "Chọn đủ hai loại rồng để hợp thể."}
	if parent_a.instance_id == parent_b.instance_id:
		return {"error": "Cần hai cá thể khác nhau."}
	if not PlayerCollection.owned_dragons.has(parent_a) or not PlayerCollection.owned_dragons.has(parent_b):
		return {"error": "Chỉ có thể chọn rồng đang sở hữu."}
	var catalog := {}
	for definition in DragonCatalog.all_definitions():
		catalog[definition.id] = definition
	if not catalog.has(parent_a.species_id) or not catalog.has(parent_b.species_id):
		return {"error": "Không tìm thấy loài rồng."}
	var a: DragonDefinition = catalog[parent_a.species_id]
	var b: DragonDefinition = catalog[parent_b.species_id]
	var elements: Array[String] = a.elements.duplicate()
	for element in b.elements:
		if not elements.has(element):
			elements.append(element)
	var chance := 0.0
	if a.elements.size() == 1 and b.elements.size() == 1 and elements.size() == 2:
		chance = .05
	elif a.elements.size() <= 2 and b.elements.size() <= 2 and elements.size() == 3:
		chance = .01
	else:
		return {"error": "Chọn hai rồng một hệ khác nhau, hoặc kết hợp đủ ba nguyên tố từ rồng một/hai hệ."}
	for definition in catalog.values():
		if definition.elements.size() == elements.size():
			var matches := true
			for element in elements:
				matches = matches and definition.elements.has(element)
			if matches:
				return {"error": "", "chance": chance, "target": definition}
	return {"error": "Chưa có công thức cho cặp rồng này."}

static func succeeds(chance: float, ticket: int) -> bool:
	return ticket >= 0 and ticket < roundi(chance * 10000)

static func possible_outcomes(parent_a: DragonInstance, parent_b: DragonInstance) -> Array[DragonDefinition]:
	var outcomes: Array[DragonDefinition] = []
	var plan := recipe(parent_a,parent_b)
	if not plan.error.is_empty():
		return outcomes
	outcomes.append(plan.target)
	var elements: Array[String] = []
	var definitions := DragonCatalog.all_definitions()
	for definition in definitions:
		if definition.id == parent_a.species_id or definition.id == parent_b.species_id:
			for element in definition.elements:
				if not elements.has(element):
					elements.append(element)
	for definition in definitions:
		if definition.elements.size() == 1 and elements.has(definition.elements[0]):
			outcomes.append(definition)
	return outcomes

static func attempt(parent_a: DragonInstance, parent_b: DragonInstance, rng: RandomNumberGenerator = null) -> BreedingResult:
	var result := BreedingResult.new()
	if cooldown_remaining() > 0:
		result.error_message = "Hợp thể đang hồi, vui lòng chờ %d giây." % cooldown_remaining()
		return result
	var plan := recipe(parent_a, parent_b)
	if not plan.error.is_empty():
		result.error_message = plan.error
		return result
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var hybrid_success := succeeds(plan.chance, rng.randi_range(0, 9999))
	var child := DragonInstance.new()
	child.instance_id = Crypto.new().generate_random_bytes(16).hex_encode()
	child.species_id = plan.target.id
	if not hybrid_success:
		var basic: Array[DragonDefinition] = []
		for definition in possible_outcomes(parent_a,parent_b):
			if definition.elements.size() == 1:
				basic.append(definition)
		child.species_id = basic[rng.randi_range(0,basic.size()-1)].id
	child.parent_a_id = parent_a.instance_id
	child.parent_b_id = parent_b.instance_id
	var batch: Array[DragonInstance] = [child]
	if not PlayerCollection.add_batch(batch, -1, Time.get_unix_time_from_system() + COOLDOWN_SECONDS):
		result.error_message = "Không lưu được rồng con. Hãy kiểm tra dữ liệu lưu."
		return result
	result.success = hybrid_success
	result.offspring = child
	return result
