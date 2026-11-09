extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 LocalSaveStore.load_error = ""
 PlayerCollection.owned_dragons.clear()
 var screen: MainMenuScreen = load("res://scenes/main/main_menu.tscn").instantiate()
 root.add_child(screen)
 await process_frame
 assert(screen.favorites.is_empty() and not screen.dragon.visible)
 assert(screen.favorite_empty.visible)
 screen.queue_free()
 await process_frame
 var pets: Array[DragonInstance] = []
 for i in range(3):
  var pet := DragonInstance.new()
  pet.instance_id = "care_%d" % i
  pet.species_id = ["fire","water","triple"][i]
  pet.favorite = i != 0
  pets.append(pet)
 PlayerCollection.owned_dragons.assign(pets)
 PlayerProfile.food = 36
 screen = load("res://scenes/main/main_menu.tscn").instantiate()
 root.add_child(screen)
 await process_frame
 assert(screen.favorites.size() == 2)
 assert(screen.favorites[0] == pets[1] and screen.favorites[1] == pets[2])
 assert(screen.dragon.texture == BattleCatalog.dragon(pets[1]).portrait)
 screen._cycle_favorite(1)
 assert(screen.dragon.texture == BattleCatalog.dragon(pets[2]).portrait)
 var before := BattleCatalog.dragon(pets[2])
 screen.care_selected = pets[2]
 screen._feed_selected()
 assert(pets[2].level == 2 and PlayerProfile.food == 31)
 assert(screen.favorite_info.text.begins_with("Cấp 2"))
 assert(BattleCatalog.dragon(pets[2]).attack > before.attack)
 assert(BattleCatalog.dragon(pets[2]).max_hp > before.max_hp)
 LocalSaveStore.load_error = "simulated failure"
 assert(not PlayerCollection.feed(pets[2]).is_empty())
 assert(pets[2].level == 2 and PlayerProfile.food == 31)
 LocalSaveStore.load_error = ""
 PlayerProfile.food = 0
 assert(not PlayerCollection.feed(pets[2]).is_empty())
 assert(pets[2].level == 2)
 PlayerProfile.food = 1000
 pets[2].level = PlayerCollection.MAX_LEVEL
 assert(not PlayerCollection.feed(pets[2]).is_empty())
 assert(PlayerProfile.food == 1000)
 var outsider := DragonInstance.new()
 assert(not PlayerCollection.feed(outsider).is_empty())
 screen.queue_free()
 await process_frame
 var store := LocalSaveStore.new()
 PlayerCollection.owned_dragons.clear()
 store._ready()
 assert(PlayerCollection.owned_dragons[2].level == 2)
 assert(PlayerCollection.owned_dragons[2].favorite)
 assert(PlayerProfile.food == 31)
 store.free()
 print("PASS: empty favorite home; only favorite portraits; cycling; feeding level and stats; cost; save rollback; insufficient food; max level; ownership; persisted level/food")
 quit()
