extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 var original := PlayerCollection.owned_dragons.duplicate()
 PlayerCollection.owned_dragons.clear()
 for definition in DragonCatalog.all_definitions():
  var instance := DragonInstance.new()
  instance.instance_id = "aaa_"+definition.id
  instance.species_id = definition.id
  instance.level = 3
  var unit := BattleCatalog.dragon(instance)
  assert(unit.skills.size() == definition.elements.size(), "Every element grants its skill")
  PlayerCollection.owned_dragons.append(instance)
 for i in range(1000):
  var extra := DragonInstance.new()
  extra.instance_id = "extra_%d" % i
  extra.species_id = "fire"
  PlayerCollection.owned_dragons.append(extra)
 var screen: BattleScreen = load("res://scenes/battle/battle.tscn").instantiate()
 root.add_child(screen)
 await process_frame
 assert(screen.mode == "chapters")
 screen._choose_chapter("rift_1")
 assert(screen.mode == "prepare")
 assert(screen.picker_buttons.size() == screen.PICKER_PAGE_SIZE, "Large collections render only one page")
 screen._toggle_party(PlayerCollection.owned_dragons[0])
 screen._change_picker_page(1)
 assert(screen.picker_buttons.size() == screen.PICKER_PAGE_SIZE)
 assert(screen.party[0] == PlayerCollection.owned_dragons[0], "Selection survives paging")
 screen._change_picker_page(-1)
 screen.party.assign([PlayerCollection.owned_dragons[6],PlayerCollection.owned_dragons[3]])
 screen._start_owned_match()
 await process_frame
 assert(screen.battle.players.size() == 2)
 assert(screen.battle.enemies.size() == 3)
 assert(screen.fighters.size() == 5)
 assert(screen.battle.players[0].id == "aaa_triple")
 assert(screen.battle.players[0].skills.size() == 3)
 assert(screen.battle.players[1].skills.size() == 2)
 assert(screen.battle.enemies[0].display_name == "Bọ Giáp Đá")
 assert(screen.battle.enemies[1].ai == "weakest")
 assert(screen.battle.enemies[2].skill == "venom")
 assert(screen.roster[2].texture_path.begins_with("res://assets/textures/enemies/"))
 assert(not screen.auto_battle)
 screen._execute_next_turn_action()
 assert(screen.battle.active.id == "aaa_triple")
 assert(screen.ability_buttons.size() == 4)
 var actor: BattleUnitData = screen.battle.active
 var target: BattleUnitData = screen.battle.enemies[0]
 var before := target.hp
 screen._on_player_skill_pressed("fire_rain")
 assert(screen.battle.active == actor and target.hp == before, "Preview cannot spend a turn")
 await screen._perform_combat_action(screen.fighter_by_id[actor.id],"fire_rain",target.id)
 assert(target.hp < before)
 assert(actor.cooldowns.fire_rain == 3)
 assert(not actor.cooldowns.has("ice_tide"))
 assert(screen.battle.active == null)
 # A skill from another element remains ready and legal on the next own turn.
 screen.battle.active = actor
 assert(screen.battle.act("ice_tide",target.id).is_empty())
 assert(actor.cooldowns.ice_tide == 3)
 assert(actor.cooldowns.fire_rain == 2)
 # Normal attacks never mutate persistent pet state.
 assert(PlayerCollection.owned_dragons[6].level == 3)
 screen.mode = "test"
 screen.queue_free()
 await process_frame
 PlayerCollection.owned_dragons.assign(original)
 print("PASS: owned party selection; level stats; 1/2/3 element skills; PK roster; manual turns; preview; independent cooldowns; no pet mutation")
 quit()


