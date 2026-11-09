extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _rng(success: bool, chance: float) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	for value in range(10000):
		rng.seed = value
		if BreedingManager.succeeds(chance, rng.randi_range(0,9999)) == success:
			rng.seed = value
			return rng
	return rng

func _run() -> void:
	# Fixture is restricted to the isolated test APPDATA profile.
	PlayerCollection.owned_dragons.clear()
	PlayerCollection.pity_count = 17
	PlayerCollection.fusion_ready_at = 0
	for species in ["fire","water","shadow","fire_water","fire_shadow"]:
		var dragon := DragonInstance.new()
		dragon.instance_id = "test_" + species
		dragon.species_id = species
		PlayerCollection.owned_dragons.append(dragon)
	var parents := PlayerCollection.owned_dragons.duplicate()
	assert(BreedingManager.recipe(parents[0],parents[1]).target.id == "fire_water")
	assert(BreedingManager.recipe(parents[1],parents[0]).target.id == "fire_water")
	assert(BreedingManager.recipe(parents[3],parents[4]).target.id == "triple")
	assert(not BreedingManager.recipe(parents[0],parents[0]).error.is_empty())
	assert(not BreedingManager.recipe(parents[0],parents[3]).error.is_empty())
	var water_shadow := DragonInstance.new()
	water_shadow.instance_id = "test_water_shadow"
	water_shadow.species_id = "water_shadow"
	PlayerCollection.owned_dragons.append(water_shadow)
	for pair in [[parents[3],parents[2]],[parents[4],parents[1]],[water_shadow,parents[0]]]:
		for order in [pair,[pair[1],pair[0]]]:
			var plan := BreedingManager.recipe(order[0],order[1])
			assert(plan.error.is_empty() and plan.target.id == "triple")
			assert(is_equal_approx(plan.chance,.01))
			var outcomes := BreedingManager.possible_outcomes(order[0],order[1])
			assert(outcomes.size() == 4 and outcomes[0].id == "triple")
	PlayerCollection.owned_dragons.pop_back()
	var two := 0
	var three := 0
	for ticket in range(10000):
		two += int(BreedingManager.succeeds(.05,ticket))
		three += int(BreedingManager.succeeds(.01,ticket))
	assert(two == 500 and three == 100)
	var failure := BreedingManager.attempt(parents[0],parents[1],_rng(false,.05))
	assert(not failure.success and failure.error_message.is_empty())
	assert(PlayerCollection.owned_count() == 6)
	assert(failure.offspring != null and failure.offspring.species_id in ["fire","water"])
	assert(BreedingManager.cooldown_remaining() > 0)
	assert(not BreedingManager.attempt(parents[0],parents[1]).error_message.is_empty())
	PlayerCollection.fusion_ready_at = 0
	var success := BreedingManager.attempt(parents[0],parents[1],_rng(true,.05))
	assert(success.success and success.offspring.species_id == "fire_water")
	assert(success.offspring.parent_a_id == parents[0].instance_id)
	assert(success.offspring.parent_b_id == parents[1].instance_id)
	assert(PlayerCollection.owned_count() == 7 and PlayerCollection.pity_count == 17)
	PlayerCollection.fusion_ready_at = 0
	var triple := BreedingManager.attempt(parents[3],parents[2],_rng(true,.01))
	assert(triple.success and triple.offspring.species_id == "triple")
	PlayerCollection.fusion_ready_at = 0
	LocalSaveStore.load_error = "test failure"
	assert(not BreedingManager.attempt(parents[0],parents[1],_rng(true,.05)).success)
	LocalSaveStore.load_error = ""
	assert(PlayerCollection.owned_count() == 8)
	assert(PlayerCollection.fusion_ready_at == 0)
	var store := LocalSaveStore.new()
	store._ready()
	store.free()
	assert(PlayerCollection.owned_dragons[5].parent_a_id == "test_fire")
	assert(PlayerCollection.pity_count == 17)
	assert(BreedingManager.cooldown_remaining() > 0)
	PlayerCollection.fusion_ready_at = 0
	var screen = load("res://scenes/breeding/breeding.tscn").instantiate()
	root.add_child(screen)
	assert(screen.combinations_button.disabled)
	screen._choose_species(0,"fire")
	assert(screen.combinations_button.disabled)
	screen._choose_species(1,"water")
	assert(not screen.combinations_button.disabled)
	assert(not screen.action.disabled)
	assert(screen._parent(0).instance_id == "test_fire")
	assert(screen._parent(1).instance_id == "test_water")
	var duplicate := DragonInstance.new()
	duplicate.instance_id = "later_fire"
	duplicate.species_id = "fire"
	PlayerCollection.owned_dragons.append(duplicate)
	assert(screen._parent(0).instance_id == "test_fire")
	screen._show_combinations()
	assert(screen.modal != null)
	assert(screen.preview_species.size() == 3)
	assert(screen.preview_species.has("fire_water") and screen.preview_species.has("fire") and screen.preview_species.has("water"))
	assert(not screen.preview_species.has("shadow") and not screen.preview_species.has("triple"))
	screen._close_modal()
	screen._choose_species(0,"fire_water")
	screen._choose_species(1,"shadow")
	screen._show_combinations()
	assert(screen.preview_species.size() == 4 and screen.preview_species.has("triple"))
	assert(not screen.preview_species.has("fire_shadow") and not screen.preview_species.has("water_shadow"))
	screen._close_modal()
	screen._choose_species(0,"fire_water")
	screen._choose_species(1,"fire_shadow")
	screen._show_combinations()
	assert(screen.preview_species.size() == 4 and screen.preview_species.has("triple"))
	assert(not screen.preview_species.has("water_shadow"))
	screen._close_modal()
	screen._choose_species(0,"fire")
	screen._choose_species(1,"water")
	screen._open_selector(0)
	assert(screen.modal != null)
	screen._close_modal()
	var result := GachaResult.new()
	result.dragons.append(triple.offspring)
	var hatch = load("res://scripts/ui/components/gacha_hatch.gd").new()
	root.add_child(hatch)
	hatch.setup(result,true)
	assert(hatch.amount == 1 and hatch.mythic_reveal)
	hatch._process(3.8)
	assert(not hatch.reveal_played)
	hatch._process(4.5)
	assert(hatch.spotlight.visible)
	hatch._finish()
	hatch.queue_free()
	PlayerCollection.fusion_ready_at = Time.get_unix_time_from_system() + 30
	screen._update_action()
	assert(screen.action.disabled and screen.action.text.contains("giây"))
	PlayerCollection.fusion_ready_at = Time.get_unix_time_from_system() - 1
	screen._update_action()
	assert(not screen.action.disabled and BreedingManager.cooldown_remaining() == 0)
	print("PASS: recipes, exact 5%/1%, parent retention, fallback reward, cooldown/reload/rollback, lineage, pity unchanged, UI preview")
	screen.queue_free()
	root.get_node("AudioManager").stop_all()
	await process_frame
	await process_frame
	await create_timer(.15).timeout
	quit()
