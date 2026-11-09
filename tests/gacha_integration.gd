extends SceneTree

# Run with an isolated APPDATA directory, never against the player's save.
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var initial := PlayerCollection.owned_count()
	var screen = load("res://scenes/gacha/gacha.tscn").instantiate()
	root.add_child(screen)
	var audio = root.get_node("AudioManager")
	assert(audio.effects.size() == 8)
	assert(audio.music.stream.get_length() > 20)
	var event := InputEventMouseButton.new()
	event.pressed = true
	audio._input(event)
	assert(audio.started)
	screen.roll_one.pressed.emit()
	assert(screen.rolling)
	assert(PlayerCollection.owned_count() == initial + 1)
	screen._roll(10)
	assert(PlayerCollection.owned_count() == initial + 1)
	await create_timer(0.8).timeout
	var hatch = screen.get_node_or_null("Control")
	for child in screen.get_children():
		if child.get_script() == load("res://scripts/ui/components/gacha_hatch.gd"):
			hatch = child
	assert(hatch != null)
	hatch.skip.pressed.emit()
	await process_frame
	assert(screen.result_overlay != null)
	assert(not screen.rolling)
	screen._close_results()
	screen.roll_ten.pressed.emit()
	await create_timer(8.1).timeout
	var additional_wait := 0.0
	while screen.rolling and additional_wait < 26:
		await create_timer(.2).timeout
		additional_wait += .2
	assert(not screen.rolling)
	assert(screen.result_overlay != null)
	assert(PlayerCollection.owned_count() == initial + 11)
	# Cover the rare animation without changing the random odds or granting rewards.
	var rare_result := GachaResult.new()
	var dragon := DragonInstance.new()
	dragon.species_id = "fire_shadow"
	rare_result.dragons.append(dragon)
	var cinematic = load("res://scripts/ui/components/gacha_hatch.gd").new()
	root.add_child(cinematic)
	cinematic.setup(rare_result)
	assert(cinematic.rare)
	assert(cinematic.portraits.size() == 1)
	cinematic._process(3.8)
	assert(cinematic.burst_played and cinematic.reveal_played)
	cinematic._process(1.6)
	assert(cinematic.spotlight.visible)
	assert(cinematic.spotlight.size.x >= 550)
	cinematic._finish()
	assert(cinematic.completed)
	cinematic.queue_free()
	var batch := GachaResult.new()
	for i in range(10):
		var instance := DragonInstance.new()
		instance.species_id = "fire_shadow" if i == 3 or i == 8 else ["fire","water","shadow"][i%3]
		batch.dragons.append(instance)
	var simultaneous = load("res://scripts/ui/components/gacha_hatch.gd").new()
	root.add_child(simultaneous)
	simultaneous.setup(batch)
	assert(simultaneous.portraits.size() == 10 and simultaneous.centers.size() == 10)
	assert(simultaneous.featured_count == 2)
	simultaneous._process(3.8)
	for portrait in simultaneous.portraits:
		assert(is_equal_approx(portrait.modulate.a, 1.0))
	simultaneous._process(1.6)
	assert(simultaneous.spotlight.visible and simultaneous.spotlight.size.x >= 550)
	simultaneous._process(2.7)
	assert(simultaneous.spotlight_index == 8)
	simultaneous._finish()
	simultaneous.queue_free()
	assert(PlayerCollection.owned_count() == initial + 11)
	print("PASS: x1 skip, x10 full hatch, lock, rare VFX/SFX, music, no duplicate rewards")
	screen.queue_free()
	audio.stop_all()
	await process_frame
	await process_frame
	await create_timer(.15).timeout
	quit()
