extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 for element in ["fire","water","shadow"]:
  for speed in [1.0,2.0]:
   var effect := PkSkillVfx.new()
   var points: Array[Vector2] = [Vector2(800,300),Vector2(1000,400)]
   effect.setup(Vector2(300,300),points,element,false,speed)
   root.add_child(effect)
   effect.set_process(false)
   var events := {"impact":0,"completed":0}
   effect.impact.connect(func(): events.impact += 1)
   effect.completed.connect(func(): events.completed += 1)
   effect._process(0.81/speed)
   assert(events.impact == 0)
   effect._process(0.02/speed)
   assert(events.impact == 1)
   effect._process(0.01/speed)
   assert(events.impact == 1, "Impact must not repeat")
   effect._process(1.1/speed)
   assert(events.completed == 1)
   assert(effect.targets.size() == 2, "AoE retains every target")
   await process_frame
 var miss := PkSkillVfx.new()
 var target: Array[Vector2] = [Vector2(800,300)]
 miss.setup(Vector2(300,300),target,"shadow",false,1,true)
 assert(miss.missed)
 miss.free()
 print("PASS: fire/water/shadow effect lifecycle; one impact; AoE targets; speed x1/x2; miss flag")
 quit()
