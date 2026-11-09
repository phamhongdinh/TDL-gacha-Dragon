extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var audio = root.get_node("AudioManager")
	for child in audio.get_children():
		assert(not child is CanvasLayer)
	var settings = load("res://scenes/main/settings.tscn").instantiate()
	root.add_child(settings)
	settings.sound_toggle.button_pressed = false
	assert(audio.muted and not settings.music_slider.editable)
	settings.sound_toggle.button_pressed = true
	settings.music_slider.value = 25
	settings.effects_slider.value = 75
	assert(not audio.muted and is_equal_approx(audio.music_level,.25) and is_equal_approx(audio.effects_level,.75))
	var preferences := ConfigFile.new()
	assert(preferences.load("user://audio.cfg") == OK)
	assert(is_equal_approx(preferences.get_value("audio","music_level"),.25))
	settings.queue_free()
	var screen = load("res://scenes/gacha/gacha.tscn").instantiate()
	root.add_child(screen)
	var before := PlayerCollection.owned_count()
	for child in screen.get_children():
		if child is Button:
			assert(not child.text.contains("Lai tạo") and not child.text.contains("Bộ sưu tập"))
	screen._show_rates()
	assert(screen.rates_overlay != null)
	screen._roll(1)
	assert(PlayerCollection.owned_count() == before)
	screen._close_rates()
	assert(screen.rates_overlay == null and not screen.roll_one.disabled)
	PlayerProfile.diamonds = 456
	assert(LocalSaveStore.save_dragons(PlayerCollection.owned_dragons,PlayerCollection.pity_count) == OK)
	PlayerProfile.diamonds = 0
	var store := LocalSaveStore.new()
	store._ready()
	store.free()
	assert(PlayerProfile.diamonds == 456)
	print("PASS: sound only in settings, persisted levels, no gacha navigation, modal lock, diamond persistence")
	screen.queue_free()
	audio.stop_all()
	await process_frame
	await process_frame
	await create_timer(.15).timeout
	quit()
