class_name BattleManager
extends Node

var players: Array[BattleUnitData] = []
var enemies: Array[BattleUnitData] = []
var queue: Array[BattleUnitData] = []
var active: BattleUnitData
var stage: Dictionary
var wave := 0
var round_number := 0
var phase := "idle"
var log_lines: Array[String] = []
var rng := RandomNumberGenerator.new()
var rewards_claimed := false
var rewards := {}

func start(party: Array[DragonInstance],stage_id: String) -> void:
	players.clear()
	log_lines.clear()
	queue.clear()
	wave = 0
	round_number = 0
	active = null
	rewards_claimed = false
	rewards.clear()
	rng.randomize()
	for row in BattleCatalog.data().stages:
		if row.id == stage_id:
			stage = row
	for dragon in party:
		players.append(BattleCatalog.dragon(dragon))
	phase = "battle"
	_spawn_wave()

func _spawn_wave() -> void:
	enemies.clear()
	queue.clear()
	active = null
	for i in range(stage.waves[wave].size()):
		enemies.append(BattleCatalog.enemy(stage.waves[wave][i],i,wave,float(stage.scale)))
	log_lines.append("Đợt %d xuất hiện!" % (wave+1))
	_new_round()

func living(side: String) -> Array[BattleUnitData]:
	var result: Array[BattleUnitData] = []
	for unit in players if side == "player" else enemies:
		if unit.alive():
			result.append(unit)
	return result

func _new_round() -> void:
	round_number += 1
	queue = living("player")
	queue.append_array(living("enemy"))
	queue.sort_custom(func(a:BattleUnitData,b:BattleUnitData): return a.speed>b.speed if a.speed!=b.speed else a.id<b.id)

func _check_end() -> void:
	if living("player").is_empty():
		phase = "lost"
		active = null
	elif living("enemy").is_empty():
		if wave+1 < stage.waves.size():
			wave += 1
			_spawn_wave()
		else:
			phase = "won"
			active = null

func next_turn() -> BattleUnitData:
	if phase != "battle":
		return null
	if active != null:
		return active
	while phase == "battle":
		if queue.is_empty():
			_new_round()
		var unit: BattleUnitData = queue.pop_front()
		if not unit.alive():
			continue
		# Damage over time precedes action/skip checks.
		for id in unit.statuses.keys():
			var state: Dictionary = unit.statuses[id]
			var definition: Dictionary = BattleCatalog.data().statuses[id]
			if definition.kind == "dot":
				_damage(unit,maxi(1,roundi(unit.max_hp*definition.fraction)),definition.name)
				state.remaining -= 1
				if state.remaining <= 0:
					unit.statuses.erase(id)
		if not unit.alive():
			_check_end()
			continue
		var skipped := false
		for id in unit.statuses.keys():
			var definition: Dictionary = BattleCatalog.data().statuses[id]
			if definition.kind == "skip_action":
				unit.statuses[id].remaining -= 1
				if unit.statuses[id].remaining <= 0:
					unit.statuses.erase(id)
					var guard: String = definition.get("expires_grants","")
					if not guard.is_empty():
						_add_status(unit,guard)
				log_lines.append("%s: %s — bỏ lượt" % [unit.display_name,definition.name])
				skipped = true
				break
		if skipped:
			_finish_turn(unit,"",false,true)
			continue
		active = unit
		return active
	return null

func legal_targets(actor: BattleUnitData,skill_id: String) -> Array[BattleUnitData]:
	var skill: Dictionary = BattleCatalog.data().skills[skill_id]
	if skill.target == "self":
		return [actor]
	var side := actor.side
	if skill.target.ends_with("enemy") or skill.target.ends_with("enemies"):
		side = "enemy" if actor.side == "player" else "player"
	return living(side)

func damage_preview(actor: BattleUnitData,target: BattleUnitData,skill_id: String) -> int:
	var skill: Dictionary = BattleCatalog.data().skills[skill_id]
	var advantage := counter(skill_element(actor,skill_id),target.element)
	return maxi(1,roundi(actor.attack*skill.multiplier*advantage-target.defense*.5))

func skill_element(actor: BattleUnitData,skill_id: String) -> String:
	for key in BattleCatalog.data().elements:
		if BattleCatalog.data().elements[key].skill == skill_id:
			return key
	return actor.element

func counter(attacker_element: String,target_element: String) -> float:
	return float(BattleCatalog.data().elements.get(attacker_element,{}).get("counters",{}).get(target_element,1.0))

func act(skill_id: String,target_id: String = "") -> String:
	if phase != "battle" or active == null:
		return "Chưa đến lượt hành động."
	var actor := active
	if skill_id != "basic" and skill_id != actor.skill and not actor.skills.has(skill_id):
		return "Kỹ năng không hợp lệ."
	if int(actor.cooldowns.get(skill_id,0)) > 0:
		return "Kỹ năng đang hồi."
	var skill: Dictionary = BattleCatalog.data().skills[skill_id]
	var targets := legal_targets(actor,skill_id)
	if not skill.target.begins_with("all_") and skill.target != "self":
		var selected: Array[BattleUnitData] = []
		for target in targets:
			if target.id == target_id:
				selected.append(target)
		targets = selected
	if targets.is_empty():
		return "Chọn một mục tiêu còn sống."
	var attacking: bool = skill.kind == "attack"
	var missed := false
	if attacking:
		for id in actor.statuses:
			var state: Dictionary = BattleCatalog.data().statuses[id]
			if state.kind == "miss_attack":
				# One roll for the entire action, including all AoE victims.
				missed = rng.randf() < float(state.chance)
				break
	actor.cooldowns[skill_id] = int(skill.cooldown)
	if skill_id == actor.intent:
		actor.intent = ""
	log_lines.append("%s dùng %s" % [actor.display_name,skill.name])
	if missed:
		log_lines.append("%s: Hụt — toàn bộ đòn tấn công thất bại" % actor.display_name)
	else:
		for target in targets:
			if attacking:
				var multiplier := counter(skill_element(actor,skill_id),target.element)
				_damage(target,damage_preview(actor,target,skill_id),skill.name)
				if multiplier != 1:
					log_lines.append("Khắc chế ×%s" % str(multiplier))
			elif skill.kind == "heal":
				target.hp = mini(target.max_hp,target.hp+roundi(actor.attack*skill.multiplier))
			elif skill.kind == "shield":
				target.shield += roundi(actor.attack*skill.multiplier)
			if target.alive():
				for effect in skill.effects:
					apply_status(target,effect.status,float(effect.chance))
	_finish_turn(actor,skill_id,attacking,false)
	_check_end()
	return ""

func _damage(target: BattleUnitData,amount: int,source: String) -> void:
	var absorbed := mini(target.shield,amount)
	target.shield -= absorbed
	var damage := amount-absorbed
	target.hp = maxi(0,target.hp-damage)
	log_lines.append("%s: −%d máu (%s)" % [target.display_name,damage,source])
	if not target.alive():
		log_lines.append("%s bị hạ" % target.display_name)
	elif not target.enrage.is_empty() and not target.enraged and float(target.hp)/target.max_hp <= float(target.enrage.threshold):
		target.enraged = true
		target.attack *= float(target.enrage.multiplier)
		log_lines.append("%s: Lõi Đá Bùng Nổ — tăng 20%% tấn công" % target.display_name)

func apply_status(target: BattleUnitData,status_id: String,chance: float = 1.0) -> bool:
	if target.immunities.has(status_id):
		log_lines.append("%s: Miễn nhiễm" % target.display_name)
		return false
	for id in target.statuses:
		var existing: Dictionary = BattleCatalog.data().statuses[id]
		if existing.kind == "immunity" and existing.get("blocks",[]).has(status_id):
			log_lines.append("%s: Miễn nhiễm" % target.display_name)
			return false
	var definition: Dictionary = BattleCatalog.data().statuses[status_id]
	if target.statuses.has(status_id) and definition.stacking == "ignore":
		return false
	if rng.randf() >= chance:
		return false
	_add_status(target,status_id)
	log_lines.append("%s: %s" % [target.display_name,definition.name])
	return true

func _add_status(unit: BattleUnitData,id: String) -> void:
	unit.statuses[id] = {"remaining":int(BattleCatalog.data().statuses[id].remaining)}

func _finish_turn(unit: BattleUnitData,used_skill: String,attacked: bool,skipped: bool) -> void:
	for id in unit.cooldowns.keys():
		if id != used_skill:
			unit.cooldowns[id] = maxi(0,int(unit.cooldowns[id])-1)
	if not skipped:
		for id in unit.statuses.keys():
			var definition: Dictionary = BattleCatalog.data().statuses[id]
			if definition.get("consume_on","") == "action" or (attacked and definition.get("consume_on","") == "attack"):
				unit.statuses[id].remaining -= 1
				if unit.statuses[id].remaining <= 0:
					unit.statuses.erase(id)
	if unit.ai == "elite" and not skipped and used_skill != unit.skill and int(unit.cooldowns.get(unit.skill,0)) == 0:
		unit.intent = unit.skill
		log_lines.append("CẢNH BÁO: %s chuẩn bị %s ở lượt kế tiếp!" % [unit.display_name,BattleCatalog.data().skills[unit.skill].name])
	active = null

func enemy_action() -> void:
	if active == null or active.side != "enemy":
		return
	var actor := active
	var targets := living("player")
	if targets.is_empty():
		_check_end()
		return
	if actor.ai == "weakest":
		targets.sort_custom(func(a:BattleUnitData,b:BattleUnitData): return float(a.hp)/a.max_hp<float(b.hp)/b.max_hp)
	var skill_id := "basic"
	if actor.ai == "elite":
		if not actor.intent.is_empty() and int(actor.cooldowns.get(actor.skill,0)) == 0:
			skill_id = actor.skill
	elif int(actor.cooldowns.get(actor.skill,0)) == 0:
		skill_id = actor.skill
	act(skill_id,targets[0].id)

func stars() -> int:
	if phase != "won":
		return 0
	var result := 1
	if living("player").size() == players.size():
		result += 1
	if round_number <= 10:
		result += 1
	return result

func claim_rewards() -> String:
	if phase != "won" or rewards_claimed:
		return "Không có phần thưởng mới để nhận."
	var first := not PlayerProfile.stage_stars.has(stage.id)
	var amounts: Dictionary = stage.rewards.duplicate()
	for key in amounts:
		amounts[key] = int(amounts[key])+int(stage.first_bonus.get(key,0) if first else 0)
	var old_gold := PlayerProfile.gold
	var old_food := PlayerProfile.food
	var old_shards := PlayerProfile.shards
	var old_stars := PlayerProfile.stage_stars.duplicate()
	PlayerProfile.gold += int(amounts.gold)
	PlayerProfile.food += int(amounts.food)
	PlayerProfile.shards += int(amounts.shards)
	PlayerProfile.stage_stars[stage.id] = maxi(stars(),int(PlayerProfile.stage_stars.get(stage.id,0)))
	if LocalSaveStore.save_dragons(PlayerCollection.owned_dragons,PlayerCollection.pity_count) != OK:
		PlayerProfile.gold = old_gold
		PlayerProfile.food = old_food
		PlayerProfile.shards = old_shards
		PlayerProfile.stage_stars = old_stars
		return "Không lưu được phần thưởng. Bạn có thể thử nhận lại."
	rewards = amounts
	rewards_claimed = true
	return ""
