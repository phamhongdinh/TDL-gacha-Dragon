extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 var dragons: Array[DragonInstance] = []
 for i in range(3):
  var pet := DragonInstance.new()
  pet.instance_id = "sale_%d" % i
  pet.species_id = ["fire","fire_water","triple"][i]
  pet.level = 2
  dragons.append(pet)
 PlayerCollection.owned_dragons.assign(dragons)
 PlayerProfile.gold = 100
 LocalSaveStore.load_error = ""
 assert(PlayerCollection.sell_price(dragons[0]) == 200)
 assert(PlayerCollection.sell_price(dragons[1]) == 2000)
 assert(PlayerCollection.sell_price(dragons[2]) == 10000)
 assert(PlayerCollection.set_favorite(dragons[2],true))
 assert(PlayerCollection.ordered_dragons()[0] == dragons[2])
 assert(not PlayerCollection.sell(dragons[2]).is_empty())
 assert(PlayerCollection.owned_count() == 3 and PlayerProfile.gold == 100)
 # Simulate persistence failure: favorite and sale must both roll back.
 LocalSaveStore.load_error = "simulated failure"
 assert(not PlayerCollection.set_favorite(dragons[0],true))
 assert(not dragons[0].favorite)
 assert(not PlayerCollection.sell(dragons[0]).is_empty())
 assert(PlayerProfile.gold == 100 and PlayerCollection.owned_count() == 3)
 LocalSaveStore.load_error = ""
 assert(PlayerCollection.sell(dragons[0]).is_empty())
 assert(PlayerProfile.gold == 300 and PlayerCollection.owned_count() == 2)
 assert(not PlayerCollection.sell(dragons[0]).is_empty())
 assert(PlayerProfile.gold == 300)
 # Save and reload the real serialized favorite flag and reduced collection.
 PlayerCollection.owned_dragons.clear()
 var store := LocalSaveStore.new()
 store._ready()
 assert(PlayerCollection.owned_count() == 2)
 assert(PlayerCollection.ordered_dragons()[0].favorite)
 assert(PlayerCollection.ordered_dragons()[0].species_id == "triple")
 assert(PlayerProfile.gold == 300)
 store.free()
 PlayerCollection.owned_dragons.assign(dragons)
 LocalSaveStore.load_error = "bulk failure"
 var before_bulk := PlayerProfile.gold
 assert(not PlayerCollection.sell_materials().error.is_empty())
 assert(PlayerCollection.owned_count() == 3 and PlayerProfile.gold == before_bulk)
 LocalSaveStore.load_error = ""
 var bulk := PlayerCollection.sell_materials()
 assert(bulk.count == 1 and bulk.gold == 200)
 assert(PlayerCollection.owned_count() == 2 and PlayerProfile.gold == before_bulk+200)
 assert(PlayerCollection.sale_materials().is_empty())
 assert(PlayerCollection.owned_dragons.has(dragons[1]) and PlayerCollection.owned_dragons.has(dragons[2]))
 var screen: DragonCollectionScreen = load("res://scenes/collection/dragon_collection.tscn").instantiate()
 root.add_child(screen)
 await process_frame
 assert(screen.grid.get_child_count() == 2)
 screen._confirm_sale(PlayerCollection.owned_dragons[0])
 await process_frame
 var dialog := screen.get_child(screen.get_child_count()-1) as ConfirmationDialog
 assert(dialog != null and dialog.visible)
 dialog.canceled.emit()
 assert(PlayerCollection.owned_count() == 2)
 screen.queue_free()
 await process_frame
 print("PASS: favorite order/persistence; sale price; favorite protection; save-failure rollback; sale once; reload; cancel confirmation")
 quit()
