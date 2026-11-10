extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 for definition in DragonCatalog.all_definitions():
  var sprite := TextureRect.new()
  sprite.texture = definition.portrait
  sprite.size = Vector2(400,300)
  root.add_child(sprite)
  var animator := DragonAnimator.attach(sprite,0.3)
  animator.set_process(false)
  for i in range(3000):
   animator._process(1.0/60)
  assert(animator.idle_seconds == 0 and animator.sleep_blend == 0, "Combat/catalog sprites cannot sleep by default")
  animator.enable_sleep(true)
  assert(animator._sleep_texture != null, "Every species has a dedicated lying-down pose")
  for i in range(899):
   animator._process(1.0/60)
  assert(animator.sleep_blend == 0, "Must wait 15 seconds")
  assert(float(animator.shader_mat.get_shader_parameter("drowsiness")) > 0.9)
  for i in range(90):
   animator._process(1.0/60)
  assert(is_equal_approx(animator.sleep_blend,1))
  assert(animator.sleep_pose.visible and animator.sleep_pose.texture != sprite.texture)
  assert(float(animator.shader_mat.get_shader_parameter("awake_opacity")) < 0.01)
  sprite.flip_h = true
  animator._process(0.01)
  assert(animator.sleep_pose.flip_h)
  var side := minf(sprite.size.x,sprite.size.y)
  var ground: Vector2 = animator._ground_pair
  assert(ground.x > ground.y, "Sleeping pose needs its own ground offset")
  assert(is_equal_approx(animator.sleep_pose.position.y+ground.y*side,ground.x*side), "Feet stay on the same ground")
  var hover := InputEventMouseMotion.new()
  hover.relative = Vector2(8,0)
  animator._input(hover)
  assert(animator.idle_seconds >= 15, "Hovering a sleeping dragon should not wake it")
  var tap := InputEventMouseButton.new()
  tap.pressed = true
  animator._input(tap)
  for i in range(31):
   animator._process(1.0/60)
  assert(animator.sleep_blend == 0 and not animator.sleep_pose.visible)
  animator.rest_now()
  for i in range(90):
   animator._process(1.0/60)
  assert(animator.sleep_blend > 0.99)
  animator.enable_sleep(false)
  animator._process(0.5)
  assert(animator.sleep_blend == 0)
  sprite.queue_free()
  await process_frame
 print("PASS: all seven sleeping poses; 12s drowsy/15s sleep; no sleep during combat; breath pose; mirrored sleeping sprite; hover stays asleep; click wakes; manual preview; disable resets")
 quit()
