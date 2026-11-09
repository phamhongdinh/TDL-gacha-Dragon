extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _buttons(node: Node, text: String) -> Array[Button]:
 var result: Array[Button] = []
 if node is Button and node.text == text:
  result.append(node)
 for child in node.get_children():
  result.append_array(_buttons(child,text))
 return result

func _run() -> void:
 PlayerProfile.stage_stars = {}
 LocalSaveStore.load_error = ""
 var hp := 0.0
 var attack := 0.0
 for chapter in BattleCatalog.data().chapters:
  assert(chapter.hp_scale > hp and chapter.attack_scale > attack)
  hp = chapter.hp_scale
  attack = chapter.attack_scale
  for i in range(chapter.monsters.size()):
   var unit := BattleCatalog.chapter_enemy(chapter.id,i)
   var base := BattleCatalog.enemy(chapter.monsters[i],i,0,1)
   assert(unit.max_hp == roundi(base.max_hp*chapter.hp_scale))
   assert(is_equal_approx(unit.attack,base.attack*chapter.attack_scale))
 assert(BattleCatalog.chapter_unlocked("rift_1"))
 assert(not BattleCatalog.chapter_unlocked("rift_2"))
 var pet := DragonInstance.new()
 pet.instance_id = "chapter_test_pet"
 pet.species_id = "triple"
 pet.level = 8
 PlayerCollection.owned_dragons.assign([pet])
 var screen: BattleScreen = load("res://scenes/battle/battle.tscn").instantiate()
 root.add_child(screen)
 await process_frame
 assert(screen.mode == "chapters")
 screen._choose_chapter("rift_3")
 assert(screen.mode == "chapters", "Cannot choose a locked chapter")
 screen._choose_chapter("rift_1")
 screen.party.assign([pet])
 screen._start_owned_match()
 screen.mode = "test"
 var battle := screen.battle
 var actions := 0
 while battle.phase == "battle" and actions < 100:
  var actor := battle.next_turn()
  if actor == null:
   break
  var skill := "basic"
  if actor.side == "player":
   for id in actor.skills:
    if int(actor.cooldowns.get(id,0)) == 0:
     skill = id
     break
  elif int(actor.cooldowns.get(actor.skill,0)) == 0:
   skill = actor.skill
  var targets := battle.legal_targets(actor,skill)
  assert(battle.act(skill,targets[0].id).is_empty())
  actions += 1
 assert(battle.phase == "won")
 var gold_before := PlayerProfile.gold
 screen._show_pk_result_modal(true,battle.living("player").size())
 var receive := _buttons(screen.result_modal,"Nhận thưởng")[0]
 var chapters := _buttons(screen.result_modal,"Danh sách chương")[0]
 assert(chapters.disabled)
 LocalSaveStore.load_error = "simulated write failure"
 receive.pressed.emit()
 assert(PlayerProfile.gold == gold_before and not battle.rewards_claimed)
 assert(chapters.disabled and not receive.disabled)
 LocalSaveStore.load_error = ""
 receive.pressed.emit()
 assert(battle.rewards_claimed and receive.disabled and not chapters.disabled)
 assert(PlayerProfile.gold == gold_before+250)
 assert(BattleCatalog.chapter_unlocked("rift_2"))
 assert(not BattleCatalog.chapter_unlocked("rift_3"))
 assert(not battle.claim_rewards().is_empty())
 assert(PlayerProfile.gold == gold_before+250)
 # Replaying a cleared chapter gives base rewards, without first-clear bonus.
 battle.rewards_claimed = false
 assert(battle.claim_rewards().is_empty())
 assert(PlayerProfile.gold == gold_before+250+150)
 battle.phase = "lost"
 battle.rewards_claimed = false
 assert(not battle.claim_rewards().is_empty())
 screen._return_to_chapters()
 assert(screen.mode == "chapters")
 screen.queue_free()
 await process_frame
 var store := LocalSaveStore.new()
 PlayerProfile.stage_stars.clear()
 store._ready()
 assert(BattleCatalog.chapter_unlocked("rift_2"), "Progress survives reload")
 store.free()
 print("PASS: six chapters; HP/attack scaling; lock gates; real victory; reward UI; save rollback; first-clear once; replay reward; loss no reward; persisted unlock")
 quit()
