extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	LocalSaveStore.load_error = ""
	if FileAccess.file_exists(WorldBossSystem.ONLINE_STATE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(WorldBossSystem.ONLINE_STATE_PATH))
	WorldBossSystem._initialized = false
	WorldBossSystem._state.clear()
	WorldBossSystem.ensure_initialized()

	# 1. Kiểm tra đăng nhập & chuyển đổi giữa 3 tài khoản người chơi
	var login1 := WorldBossSystem.login_or_register("Thợ Săn 1", "123")
	assert(bool(login1.get("ok", false)) and WorldBossSystem.current_username == "Thợ Săn 1")
	WorldBossSystem.grant_starter_raid_dragons_if_needed()
	assert(PlayerCollection.owned_dragons.size() >= 3, "Thợ Săn 1 có đủ 3 rồng để săn Boss")

	var login2 := WorldBossSystem.login_or_register("Thợ Săn 2", "123")
	assert(bool(login2.get("ok", false)) and WorldBossSystem.current_username == "Thợ Săn 2")
	var gold_hunter2_before := PlayerProfile.gold
	assert(gold_hunter2_before >= 12500)

	# Quay lại Thợ Săn 1
	WorldBossSystem.login_or_register("Thợ Săn 1", "123")
	var gold_before := PlayerProfile.gold
	var boss_before := WorldBossSystem.get_boss_info()
	var hp_before := int(boss_before.get("hp", 0))
	assert(hp_before > 0, "Boss Thế Giới đang còn máu")

	# 2. Mở giao diện Phòng Săn Boss Thế Giới 3 người trong BattleScreen
	var screen: BattleScreen = load("res://scenes/battle/battle.tscn").instantiate()
	root.add_child(screen)
	await process_frame
	assert(screen.mode == "chapters")
	screen._show_world_boss_lobby()
	assert(screen.mode == "world_boss" and screen.is_world_boss_match)
	assert(screen.party.size() == 3)

	# 3. Vào trận đánh Boss Thế Giới và gây sát thương để farm Vàng
	screen._start_world_boss_match()
	await process_frame
	assert(screen.mode == "pk" and screen.is_world_boss_match)
	assert(screen.battle.enemies.size() == 3)
	assert(screen.battle.enemies[0].id == "world_boss_main")

	screen.world_boss_session_damage = 2400
	screen._show_world_boss_result_modal()
	assert(screen.world_boss_reward_claimed)
	assert(PlayerProfile.gold > gold_before + 5000, "Săn Boss Thế Giới thưởng lượng Vàng lớn")
	var hp_after_p1 := int(WorldBossSystem.get_boss_info().get("hp", 0))
	assert(hp_after_p1 == hp_before - 2400, "Máu chung của Boss giảm đúng bằng sát thương gây ra")

	# 4. Giả lập 2 đồng đội còn lại trong phòng 3 người cùng tấn công Boss
	var logs := WorldBossSystem.simulate_teammates_attack()
	assert(logs.size() == 2, "2 đồng đội trong tổ đội 3 người cùng đánh Boss")
	assert(int(WorldBossSystem.get_boss_info().get("hp", 0)) < hp_after_p1)

	screen.mode = "test"
	screen.queue_free()
	await process_frame
	print("PASS: 3-player login/save; World Boss lobby; shared Boss HP; massive Gold reward farming; co-op teammate attacks")
	quit()
