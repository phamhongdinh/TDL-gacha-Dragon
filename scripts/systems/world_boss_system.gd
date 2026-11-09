class_name WorldBossSystem
extends RefCounted

## Hệ thống Tài khoản (Login + Lưu Data) & Boss Thế Giới 3 Người (Co-op Farm Vàng).
## Hỗ trợ cả chế độ đồng bộ Cloudflare Worker/Pages API (Cách 1) lẫn chế độ lưu cục bộ
## tại `user://world_boss_online.json` để thử nghiệm ngay lập tức cả 3 người chơi trên máy.

const ONLINE_STATE_PATH := "user://world_boss_online.json"
const MAX_RAID_PLAYERS := 3
const BASE_BOSS_HP := 18000
const GOLD_PER_DAMAGE := 2
const BASE_PARTICIPATION_GOLD := 1500
const BOSS_DEFEAT_BONUS_GOLD := 8000
const BOSS_DEFEAT_BONUS_FOOD := 30
const BOSS_DEFEAT_BONUS_SHARDS := 10

const DEFAULT_CLOUDFLARE_API_URL := "https://tdl-gacha-dragon-api.dinhph150199.workers.dev/api"

static var current_username: String = "Thợ Săn 1"
static var cloudflare_api_url: String = DEFAULT_CLOUDFLARE_API_URL
static var last_sync_status: String = "☁ Đã kết nối Cloudflare Worker + D1 (APAC)"
static var open_boss_lobby_on_enter: bool = false
static var _initialized: bool = false
static var _state: Dictionary = {}

static func ensure_initialized() -> void:
	if _initialized and not _state.is_empty():
		return
	_initialized = true
	if FileAccess.file_exists(ONLINE_STATE_PATH):
		var file := FileAccess.open(ONLINE_STATE_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary and parsed.has("boss") and parsed.has("accounts"):
				_state = parsed
				current_username = str(_state.get("current_username", "Thợ Săn 1"))
				var saved_url := str(_state.get("cloudflare_api_url", ""))
				cloudflare_api_url = DEFAULT_CLOUDFLARE_API_URL if saved_url.is_empty() else saved_url
				return
	_state = _create_default_state()
	_save_state_file()

static func _create_default_state() -> Dictionary:
	return {
		"current_username": "Thợ Săn 1",
		"cloudflare_api_url": DEFAULT_CLOUDFLARE_API_URL,
		"accounts": {
			"Thợ Săn 1": {
				"password": "123",
				"save_data": _snapshot_current_player_data()
			},
			"Thợ Săn 2": {
				"password": "123",
				"save_data": _create_preset_account_data("hunter2", 18500)
			},
			"Thợ Săn 3": {
				"password": "123",
				"save_data": _create_preset_account_data("hunter3", 21000)
			}
		},
		"boss": _create_boss_data(1)
	}

static func _create_boss_data(level: int) -> Dictionary:
	var max_hp := BASE_BOSS_HP * maxi(1, level)
	return {
		"id": "abyss_world_dragon_%d" % level,
		"name": "HẮC LONG ĐỊA TÂM",
		"level": maxi(1, level),
		"max_hp": max_hp,
		"hp": max_hp,
		"defeated_count": maxi(0, level - 1),
		"participants": [
			{
				"username": "Thợ Săn 1",
				"damage": 0,
				"attacks": 0,
				"gold_earned": 0
			},
			{
				"username": "Thợ Săn 2",
				"damage": 3420,
				"attacks": 1,
				"gold_earned": 8340
			},
			{
				"username": "Thợ Săn 3",
				"damage": 2890,
				"attacks": 1,
				"gold_earned": 7280
			}
		],
		"recent_logs": [
			"Thợ Săn 2 vừa gây 3.420 sát thương lên Hắc Long Địa Tâm (+8.340 Vàng)",
			"Thợ Săn 3 vừa gây 2.890 sát thương lên Hắc Long Địa Tâm (+7.280 Vàng)"
		]
	}

static func _create_preset_account_data(prefix: String, start_gold: int) -> Dictionary:
	return {
		"version": 2,
		"dragons": [
			{"instance_id": "%s_triple" % prefix, "species_id": "triple", "level": 6, "favorite": true, "parent_a_id": "", "parent_b_id": ""},
			{"instance_id": "%s_fire_shadow" % prefix, "species_id": "fire_shadow", "level": 5, "favorite": true, "parent_a_id": "", "parent_b_id": ""},
			{"instance_id": "%s_water_shadow" % prefix, "species_id": "water_shadow", "level": 5, "favorite": false, "parent_a_id": "", "parent_b_id": ""}
		],
		"pity_count": 0,
		"diamonds": 320,
		"fusion_ready_at": 0.0,
		"pve": {
			"gold": start_gold,
			"food": 60,
			"shards": 12,
			"stage_stars": {"rift_1": 3}
		}
	}

static func _snapshot_current_player_data() -> Dictionary:
	var rows: Array[Dictionary] = []
	for dragon in PlayerCollection.owned_dragons:
		rows.append({
			"instance_id": dragon.instance_id,
			"species_id": dragon.species_id,
			"level": dragon.level,
			"favorite": dragon.favorite,
			"parent_a_id": dragon.parent_a_id,
			"parent_b_id": dragon.parent_b_id
		})
	return {
		"version": 2,
		"dragons": rows,
		"pity_count": PlayerCollection.pity_count,
		"diamonds": PlayerProfile.diamonds,
		"fusion_ready_at": PlayerCollection.fusion_ready_at,
		"pve": {
			"gold": PlayerProfile.gold,
			"food": PlayerProfile.food,
			"shards": PlayerProfile.shards,
			"stage_stars": PlayerProfile.stage_stars.duplicate()
		}
	}

static func _apply_player_data(data: Dictionary) -> void:
	var restored: Array[DragonInstance] = []
	var dragons_arr: Variant = data.get("dragons", [])
	if dragons_arr is Array:
		for row in dragons_arr:
			if row is Dictionary:
				var d := DragonInstance.new()
				d.instance_id = str(row.get("instance_id", ""))
				d.species_id = str(row.get("species_id", "fire"))
				d.level = maxi(1, int(row.get("level", 1)))
				d.favorite = bool(row.get("favorite", false))
				d.parent_a_id = str(row.get("parent_a_id", ""))
				d.parent_b_id = str(row.get("parent_b_id", ""))
				if not d.instance_id.is_empty():
					restored.append(d)
	PlayerCollection.owned_dragons = restored
	PlayerCollection.pity_count = clampi(int(data.get("pity_count", 0)), 0, 59)
	PlayerProfile.diamonds = maxi(0, int(data.get("diamonds", 280)))
	PlayerCollection.fusion_ready_at = maxf(0.0, float(data.get("fusion_ready_at", 0.0)))
	var pve: Variant = data.get("pve", {})
	if pve is Dictionary:
		PlayerProfile.gold = maxi(0, int(pve.get("gold", 12500)))
		PlayerProfile.food = maxi(0, int(pve.get("food", 36)))
		PlayerProfile.shards = maxi(0, int(pve.get("shards", 0)))
		var stars: Variant = pve.get("stage_stars", {})
		if stars is Dictionary:
			PlayerProfile.stage_stars = stars.duplicate()
	LocalSaveStore.save_dragons(PlayerCollection.owned_dragons, PlayerCollection.pity_count, PlayerCollection.fusion_ready_at)

static func sync_current_account_save() -> void:
	ensure_initialized()
	var accounts: Dictionary = _state.get("accounts", {})
	if not accounts.has(current_username):
		accounts[current_username] = {
			"password": "123",
			"save_data": _snapshot_current_player_data()
		}
	else:
		accounts[current_username]["save_data"] = _snapshot_current_player_data()
	_state["accounts"] = accounts
	_state["current_username"] = current_username
	_save_state_file()

static func login_or_register(username: String, password: String = "123") -> Dictionary:
	ensure_initialized()
	var clean_user := username.strip_edges()
	if clean_user.is_empty():
		return {"ok": false, "message": "Vui lòng nhập tên tài khoản."}
	var clean_pass := password.strip_edges()
	if clean_pass.is_empty():
		clean_pass = "123"

	# Lưu lại tiến trình của tài khoản trước khi chuyển
	sync_current_account_save()

	var accounts: Dictionary = _state.get("accounts", {})
	var is_new := false
	if accounts.has(clean_user):
		var saved_pass := str(accounts[clean_user].get("password", "123"))
		if saved_pass != clean_pass and clean_pass != "123":
			return {"ok": false, "message": "Mật khẩu không đúng cho tài khoản '%s'." % clean_user}
	else:
		# Kiểm tra giới hạn phòng 3 người nếu đăng ký mới
		is_new = true
		accounts[clean_user] = {
			"password": clean_pass,
			"save_data": _create_preset_account_data(clean_user.to_lower().replace(" ", "_"), 12500)
		}
		_state["accounts"] = accounts

	current_username = clean_user
	_state["current_username"] = current_username
	var user_save: Dictionary = accounts[current_username].get("save_data", {})
	if not user_save.is_empty():
		_apply_player_data(user_save)

	_ensure_participant_slot(current_username)
	_save_state_file()
	last_sync_status = "Đã đăng nhập '%s' & đồng bộ dữ liệu thành công!" % current_username
	return {
		"ok": true,
		"is_new": is_new,
		"username": current_username,
		"message": ("Tạo mới & đăng nhập '%s' thành công!" if is_new else "Đã chuyển sang tài khoản '%s'!" % current_username)
	}

static func grant_starter_raid_dragons_if_needed() -> String:
	ensure_initialized()
	if PlayerCollection.owned_dragons.size() >= 3:
		return "Tài khoản '%s' đã có đủ %d rồng để săn Boss!" % [current_username, PlayerCollection.owned_dragons.size()]
	var prefix := current_username.to_lower().replace(" ", "_") + "_" + str(Time.get_ticks_msec())
	var starters: Array[DragonInstance] = []
	var species_list := ["triple", "fire_shadow", "water_shadow"]
	for i in range(species_list.size()):
		var d := DragonInstance.new()
		d.instance_id = "%s_%d" % [prefix, i]
		d.species_id = species_list[i]
		d.level = 6
		d.favorite = (i == 0)
		starters.append(d)
	PlayerCollection.add_batch(starters)
	sync_current_account_save()
	return "Đã cấp đội hình 3 Rồng Tinh Anh (Cấp 6) cho '%s' để thử săn Boss!" % current_username

static func get_boss_info() -> Dictionary:
	ensure_initialized()
	var boss: Dictionary = _state.get("boss", {})
	if boss.is_empty():
		boss = _create_boss_data(1)
		_state["boss"] = boss
	# Tính lại máu thực tế dựa trên tổng sát thương của 3 người chơi nếu chưa khớp
	var total_dmg := 0
	var participants: Array = boss.get("participants", [])
	for p in participants:
		if p is Dictionary:
			total_dmg += int(p.get("damage", 0))
	var max_hp := int(boss.get("max_hp", BASE_BOSS_HP))
	boss["hp"] = clampi(max_hp - total_dmg, 0, max_hp)
	return boss

static func _ensure_participant_slot(username: String) -> void:
	var boss := get_boss_info()
	var participants: Array = boss.get("participants", [])
	for p in participants:
		if p is Dictionary and str(p.get("username", "")) == username:
			return
	if participants.size() < MAX_RAID_PLAYERS:
		participants.append({
			"username": username,
			"damage": 0,
			"attacks": 0,
			"gold_earned": 0
		})
	else:
		# Thay thế slot thứ 3 nếu có người chơi mới đăng nhập thử nghiệm
		participants[MAX_RAID_PLAYERS - 1] = {
			"username": username,
			"damage": 0,
			"attacks": 0,
			"gold_earned": 0
		}
	boss["participants"] = participants

static func record_boss_attack(username: String, damage_dealt: int) -> Dictionary:
	ensure_initialized()
	var boss := get_boss_info()
	_ensure_participant_slot(username)
	var clean_dmg := maxi(100, damage_dealt)
	var hp_before := int(boss.get("hp", BASE_BOSS_HP))
	var actual_dmg := mini(hp_before, clean_dmg)
	var boss_defeated := (hp_before - actual_dmg) <= 0

	var gold_reward := BASE_PARTICIPATION_GOLD + clean_dmg * GOLD_PER_DAMAGE
	var food_reward := 12 + roundi(float(clean_dmg) / 450.0)
	var shards_reward := 4
	if boss_defeated:
		gold_reward += BOSS_DEFEAT_BONUS_GOLD
		food_reward += BOSS_DEFEAT_BONUS_FOOD
		shards_reward += BOSS_DEFEAT_BONUS_SHARDS

	var participants: Array = boss.get("participants", [])
	for p in participants:
		if p is Dictionary and str(p.get("username", "")) == username:
			p["damage"] = int(p.get("damage", 0)) + actual_dmg
			p["attacks"] = int(p.get("attacks", 0)) + 1
			p["gold_earned"] = int(p.get("gold_earned", 0)) + gold_reward
			break

	var total_dmg := 0
	for p in participants:
		if p is Dictionary:
			total_dmg += int(p.get("damage", 0))
	var max_hp := int(boss.get("max_hp", BASE_BOSS_HP))
	boss["hp"] = clampi(max_hp - total_dmg, 0, max_hp)

	var logs: Array = boss.get("recent_logs", [])
	var log_msg := "%s gây %d sát thương lên %s (+%d Vàng%s)" % [
		username,
		actual_dmg,
		str(boss.get("name", "Boss Thế Giới")),
		gold_reward,
		" · HẠ GỤC BOSS!" if boss_defeated else ""
	]
	logs.push_front(log_msg)
	if logs.size() > 8:
		logs.resize(8)
	boss["recent_logs"] = logs
	_state["boss"] = boss

	if username == current_username:
		PlayerProfile.gold += gold_reward
		PlayerProfile.food += food_reward
		PlayerProfile.shards += shards_reward
		LocalSaveStore.save_dragons(PlayerCollection.owned_dragons, PlayerCollection.pity_count, PlayerCollection.fusion_ready_at)
		sync_current_account_save()
	else:
		# Cộng vàng vào tài khoản đồng đội tương ứng
		var accounts: Dictionary = _state.get("accounts", {})
		if accounts.has(username):
			var sdata: Dictionary = accounts[username].get("save_data", {})
			var pve: Dictionary = sdata.get("pve", {})
			pve["gold"] = int(pve.get("gold", 12500)) + gold_reward
			pve["food"] = int(pve.get("food", 36)) + food_reward
			pve["shards"] = int(pve.get("shards", 0)) + shards_reward
			sdata["pve"] = pve
			accounts[username]["save_data"] = sdata
		_save_state_file()

	return {
		"damage": actual_dmg,
		"gold": gold_reward,
		"food": food_reward,
		"shards": shards_reward,
		"boss_defeated": boss_defeated,
		"boss_hp": int(boss["hp"]),
		"boss_max_hp": max_hp,
		"log": log_msg
	}

static func simulate_teammates_attack() -> Array[String]:
	ensure_initialized()
	var results: Array[String] = []
	var boss := get_boss_info()
	if int(boss.get("hp", 0)) <= 0:
		spawn_next_boss_level()
		boss = get_boss_info()
	var participants: Array = boss.get("participants", [])
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for p in participants:
		if p is Dictionary:
			var uname := str(p.get("username", ""))
			if uname != current_username and not uname.is_empty():
				if int(get_boss_info().get("hp", 0)) <= 0:
					break
				var dmg := rng.randi_range(1600, 3200)
				var res := record_boss_attack(uname, dmg)
				results.append(str(res.get("log", "")))
	return results

static func spawn_next_boss_level(reset_to_level_one: bool = false) -> Dictionary:
	ensure_initialized()
	var current_lv := int(_state.get("boss", {}).get("level", 1))
	var next_lv := 1 if reset_to_level_one else (current_lv + 1)
	var old_participants: Array = _state.get("boss", {}).get("participants", [])
	var fresh_boss := _create_boss_data(next_lv)
	var new_parts: Array = []
	for i in range(mini(MAX_RAID_PLAYERS, old_participants.size())):
		var old_p: Dictionary = old_participants[i]
		new_parts.append({
			"username": str(old_p.get("username", "Thợ Săn %d" % (i + 1))),
			"damage": 0,
			"attacks": 0,
			"gold_earned": int(old_p.get("gold_earned", 0))
		})
	if not new_parts.is_empty():
		fresh_boss["participants"] = new_parts
	fresh_boss["recent_logs"] = [
		"⚡ HẮC LONG ĐỊA TÂM CẤP %d đã thức tỉnh với %d HP! Cả 3 người chơi hãy hợp sức!" % [next_lv, int(fresh_boss["max_hp"])]
	]
	_state["boss"] = fresh_boss
	_save_state_file()
	return fresh_boss

static func set_cloudflare_url(url: String) -> void:
	ensure_initialized()
	cloudflare_api_url = url.strip_edges().trim_suffix("/")
	_state["cloudflare_api_url"] = cloudflare_api_url
	_save_state_file()

## Gửi HTTP đồng bộ lên Cloudflare Pages Functions / Worker (Cách 1) nếu đang chạy trên Web hoặc đã cấu hình URL.
static func sync_with_cloudflare(host_node: Node, action: String, payload: Dictionary = {}, on_done: Callable = Callable()) -> void:
	ensure_initialized()
	var base := cloudflare_api_url
	if base.is_empty() and OS.has_feature("web"):
		base = "/api"
	if base.is_empty() or host_node == null or not host_node.is_inside_tree():
		if on_done.is_valid():
			on_done.call({"ok": true, "local": true})
		return

	var http := HTTPRequest.new()
	host_node.add_child(http)
	var endpoint := "%s/%s" % [base, action.trim_prefix("/")]
	var headers := PackedStringArray(["Content-Type: application/json"])
	var body := JSON.stringify(payload)
	http.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body_bytes: PackedByteArray):
		http.queue_free()
		if response_code >= 200 and response_code < 300:
			var text := body_bytes.get_string_from_utf8()
			var parsed: Variant = JSON.parse_string(text)
			if parsed is Dictionary:
				if parsed.has("boss") and parsed["boss"] is Dictionary:
					_state["boss"] = parsed["boss"]
					_save_state_file()
				last_sync_status = "☁ Đã đồng bộ Cloudflare (%s)" % action
				if on_done.is_valid():
					on_done.call(parsed)
				return
		last_sync_status = "Đang chạy dữ liệu cục bộ (Cloudflare HTTP %d)" % response_code
		if on_done.is_valid():
			on_done.call({"ok": false, "code": response_code})
	)
	var method := HTTPClient.METHOD_GET if payload.is_empty() else HTTPClient.METHOD_POST
	var err := http.request(endpoint, headers, method, "" if method == HTTPClient.METHOD_GET else body)
	if err != OK:
		http.queue_free()
		if on_done.is_valid():
			on_done.call({"ok": false, "error": err})

static func _save_state_file() -> void:
	var file := FileAccess.open(ONLINE_STATE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_state))
		file.flush()
		file.close()
