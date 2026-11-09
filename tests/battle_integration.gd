extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _unit(id:String,side:String,skill:String = "basic") -> BattleUnitData:
	var unit := BattleUnitData.new()
	unit.id = id
	unit.display_name = id
	unit.side = side
	unit.max_hp = 1000
	unit.hp = 1000
	unit.attack = 100
	unit.defense = 40
	unit.speed = 80 if side=="player" else 40
	unit.skill = skill
	return unit

func _fixture(skill:String) -> BattleManager:
	var battle := BattleManager.new()
	battle.stage = BattleCatalog.data().stages[0]
	battle.wave = 1
	battle.phase = "battle"
	battle.players = [_unit("dragon","player",skill)]
	battle.enemies = [_unit("enemy_a","enemy"),_unit("enemy_b","enemy"),_unit("enemy_c","enemy")]
	battle.active = battle.players[0]
	battle.rng.seed = 42
	return battle

func _miss_seed() -> int:
	var rng := RandomNumberGenerator.new()
	for value in range(100):
		rng.seed = value
		if rng.randf()<.5:
			return value
	return 1

func _run() -> void:
	var battle := _fixture("fire_rain")
	var actor := battle.players[0]
	assert(battle.damage_preview(actor,battle.enemies[0],"basic") == 80)
	assert(battle.damage_preview(actor,battle.enemies[0],"fire_rain") == 30)
	assert(battle.damage_preview(actor,battle.enemies[0],"ice_tide") == 20)
	assert(battle.damage_preview(actor,battle.enemies[0],"dark_pierce") == 140)
	assert(battle.act("fire_rain").is_empty())
	for target in battle.enemies:
		assert(target.hp == 970 and target.statuses.is_empty())
	assert(actor.cooldowns.fire_rain == 3)
	for i in range(3):
		battle.active = actor
		assert(not battle.act("fire_rain").is_empty())
		assert(battle.act("basic","enemy_a").is_empty())
	assert(actor.cooldowns.fire_rain == 0)
	battle.enemies[1].hp = 0
	battle.enemies[2].hp = 0
	battle.active = actor
	var old_hp := battle.enemies[0].hp
	assert(battle.act("fire_rain").is_empty())
	assert(battle.enemies[0].hp == old_hp-30)
	battle.free()

	# Independent 35% freeze checks for every living victim.
	battle = _fixture("ice_tide")
	var probe := RandomNumberGenerator.new()
	var independent_seed := 0
	for value in range(10000):
		probe.seed = value
		if probe.randf()<.35 and probe.randf()>=.35 and probe.randf()<.35:
			independent_seed = value
			break
	battle.rng.seed = independent_seed
	assert(battle.act("ice_tide").is_empty())
	assert(battle.enemies[0].statuses.has("frozen"))
	assert(not battle.enemies[1].statuses.has("frozen"))
	assert(battle.enemies[2].statuses.has("frozen"))
	# Relations can be added by configuration; unknown pairs stay neutral.
	assert(battle.counter("new_element","fire") == 1.0)
	BattleCatalog.data().elements.fire.counters.water = 1.25
	assert(battle.counter("fire","water") == 1.25)
	BattleCatalog.data().elements.fire.counters.erase("water")
	battle.free()

	battle = _fixture("ice_tide")
	var target := battle.enemies[0]
	assert(battle.apply_status(target,"frozen",1))
	assert(not battle.apply_status(target,"frozen",1))
	assert(battle.apply_status(target,"blind",1))
	target.cooldowns.basic = 3
	battle.active = null
	battle.queue = [target,battle.players[0]]
	assert(battle.next_turn() == battle.players[0])
	assert(not target.statuses.has("frozen") and target.statuses.has("freeze_guard"))
	assert(target.statuses.has("blind") and target.cooldowns.basic == 2)
	assert(not battle.apply_status(target,"frozen",1))
	target.cooldowns.basic = 0
	battle.active = target
	assert(battle.act("basic","dragon").is_empty())
	assert(not target.statuses.has("blind") and not target.statuses.has("freeze_guard"))
	assert(battle.apply_status(target,"frozen",1))
	var elite := battle.enemies[1]
	elite.immunities = ["frozen"]
	assert(not battle.apply_status(elite,"frozen",1))
	assert(battle.log_lines[-1].contains("Miễn nhiễm"))
	assert(battle.apply_status(elite,"blind",1))
	battle.active = battle.players[0]
	assert(battle.act("ice_tide").is_empty())
	assert(elite.hp == 980)
	battle.free()

	# The blind check is performed once for the entire AoE action.
	battle = _fixture("basic")
	var caster := battle.enemies[0]
	caster.skill = "quake"
	caster.intent = "quake"
	battle.active = caster
	assert(battle.apply_status(caster,"blind",1))
	var extra := _unit("dragon_2","player")
	battle.players.append(extra)
	BattleCatalog.data().skills.quake.effects = [{"status":"poison","chance":1.0}]
	var seed_value := _miss_seed()
	battle.rng.seed = seed_value
	var expected_rng := RandomNumberGenerator.new()
	expected_rng.seed = seed_value
	expected_rng.randf()
	assert(battle.act("quake").is_empty())
	assert(battle.rng.randf() == expected_rng.randf())
	assert(caster.cooldowns.quake == 3 and caster.intent.is_empty())
	for dragon in battle.players:
		assert(dragon.hp == 1000 and not dragon.statuses.has("poison"))
	assert(not caster.statuses.has("blind"))
	assert("Hụt" in "\n".join(battle.log_lines))
	BattleCatalog.data().skills.quake.effects = []
	# Non-attack actions do not consume Blind.
	BattleCatalog.data().skills.test_heal = {"name":"Hồi phục thử","kind":"heal","target":"self","multiplier":1.0,"cooldown":3,"effects":[]}
	caster.skill = "test_heal"
	caster.hp = 500
	battle.apply_status(caster,"blind",1)
	battle.active = caster
	assert(battle.act("test_heal").is_empty())
	assert(caster.hp == 600 and caster.statuses.has("blind"))
	BattleCatalog.data().skills.erase("test_heal")
	battle.free()

	# Dead targets cannot consume actions; dead units in the queue never act.
	battle = _fixture("dark_pierce")
	battle.enemies[0].hp = 0
	assert(not battle.act("dark_pierce","enemy_a").is_empty())
	assert(not battle.players[0].cooldowns.has("dark_pierce"))
	battle.enemies[1].hp = 5
	assert(battle.act("dark_pierce","enemy_b").is_empty())
	assert(not battle.enemies[1].statuses.has("blind"))
	# Poison refreshes, ticks twice and can kill before an action.
	var last := battle.enemies[2]
	battle.apply_status(last,"poison",1)
	last.statuses.poison.remaining = 1
	battle.apply_status(last,"poison",1)
	assert(last.statuses.poison.remaining == 2)
	last.hp = 20
	battle.queue = [last]
	assert(battle.next_turn() == null and battle.phase == "won")
	battle.free()

	var party: Array[DragonInstance] = []
	for species in ["fire","water","shadow"]:
		var dragon := DragonInstance.new()
		dragon.instance_id = "pve_test_"+species
		dragon.species_id = species
		party.append(dragon)
	battle = BattleManager.new()
	battle.start(party,"rift_1")
	battle.players[0].hp = 150
	battle.players[0].cooldowns.fire_rain = 2
	for enemy in battle.enemies:
		enemy.hp = 0
	battle._check_end()
	assert(battle.wave == 1 and battle.players[0].hp == 150)
	assert(battle.players[0].cooldowns.fire_rain == 2)
	var boss := battle.enemies[0]
	battle.active = boss
	battle.enemy_action()
	assert(boss.intent == "quake" and not boss.cooldowns.has("quake"))
	battle._damage(boss,roundi(boss.max_hp*.61),"Thử")
	var boosted := boss.attack
	assert(boss.enraged)
	battle._damage(boss,1,"Thử")
	assert(boss.attack == boosted)
	battle.free()

	# A complete two-wave game followed by a single reward commit.
	battle = BattleManager.new()
	battle.start(party,"rift_1")
	battle.rng.seed = 71
	for i in range(300):
		if battle.phase != "battle":
			break
		var unit := battle.next_turn()
		if unit == null:
			break
		if unit.side == "enemy":
			battle.enemy_action()
		else:
			var skill := unit.skill if int(unit.cooldowns.get(unit.skill,0))==0 else "basic"
			var targets := battle.living("enemy")
			targets.sort_custom(func(a:BattleUnitData,b:BattleUnitData): return a.hp<b.hp)
			assert(battle.act(skill,targets[0].id).is_empty())
	assert(battle.phase == "won")
	PlayerProfile.stage_stars.clear()
	var gold_before := PlayerProfile.gold
	LocalSaveStore.load_error = "test save failure"
	assert(not battle.claim_rewards().is_empty())
	assert(PlayerProfile.gold == gold_before and not battle.rewards_claimed)
	LocalSaveStore.load_error = ""
	assert(battle.claim_rewards().is_empty())
	assert(PlayerProfile.gold == gold_before+270)
	assert(not battle.claim_rewards().is_empty())
	assert(PlayerProfile.gold == gold_before+270)
	assert(PlayerProfile.stage_stars.has("rift_1"))
	var screen = load("res://scenes/battle/battle.tscn").instantiate()
	root.add_child(screen)
	screen.party = party
	screen._prepare("rift_1")
	screen.battle.stage = battle.stage
	screen.battle.players = battle.players
	screen.battle.phase = "won"
	screen.battle.round_number = battle.round_number
	screen._render_result()
	screen.queue_free()
	print("PASS: skill coefficients; 3 own-turn cooldown; freeze immunity; elite immunity; blind AoE/single roll; heal exempt; dead targets; poison; wave HP; elite intent/enrage; full PvE victory; rewards once. Rounds=",battle.round_number)
	battle.free()
	await process_frame
	await process_frame
	quit()
