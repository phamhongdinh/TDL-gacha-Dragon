extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var banner := BannerManager.current_banner()
	# Exact base odds before hard pity; every ticket is gold at the threshold.
	var counts := {}
	for ticket in range(10000):
		var species := GachaManager.species_with_pity(banner, ticket, 58)
		counts[species] = counts.get(species, 0) + 1
		assert(GachaManager.species_with_pity(banner, ticket, 59) == banner.featured_dragon_id)
	assert(counts == banner.weights)
	var starting_count := PlayerCollection.owned_count()
	PlayerCollection.pity_count = 59
	var one := GachaManager.roll(1)
	assert(one.error_message.is_empty())
	assert(one.dragons[0].species_id == banner.featured_dragon_id)
	assert(PlayerCollection.pity_count == 0)
	PlayerCollection.pity_count = 55
	var ten := GachaManager.roll(10)
	assert(ten.error_message.is_empty())
	assert(ten.dragons.size() == 10)
	var expected := 55
	var gold := 0
	for dragon in ten.dragons:
		if expected == 59:
			assert(dragon.species_id == banner.featured_dragon_id)
		if dragon.species_id == banner.featured_dragon_id:
			expected = 0
			gold += 1
		else:
			expected += 1
	assert(gold >= 1)
	assert(PlayerCollection.pity_count == expected)
	assert(PlayerCollection.owned_count() == starting_count + 11)
	# A failed save must not commit either the rewards or the counter.
	LocalSaveStore.load_error = "test write failure"
	assert(not GachaManager.roll(1).error_message.is_empty())
	assert(PlayerCollection.pity_count == expected)
	assert(PlayerCollection.owned_count() == starting_count + 11)
	LocalSaveStore.load_error = ""
	# Simulate reopening the app from the stored v2 file.
	PlayerCollection.owned_dragons.clear()
	PlayerCollection.pity_count = 0
	var store := LocalSaveStore.new()
	store._ready()
	store.free()
	assert(PlayerCollection.pity_count == expected)
	assert(PlayerCollection.owned_count() == starting_count + 11)
	print("PASS: base 0.1%, hard pity 60, reset, x10 crossing threshold, persistence, rollback")
	quit()
