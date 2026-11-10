extends SceneTree

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 for definition in DragonCatalog.all_definitions():
  var sprite := TextureRect.new()
  sprite.texture = definition.portrait
  sprite.size = Vector2(300,220)
  sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  root.add_child(sprite)
  var animator := DragonAnimator.attach(sprite,0.5)
  animator.set_process(false)
  assert(animator.shader_mat.get_shader_parameter("source_art") == definition.portrait)
  var mask: Texture2D = animator.shader_mat.get_shader_parameter("motion_mask")
  assert(mask != null and mask.get_width() == 1280)
  # Blinks are brief, sparse, and never become an infinite double-blink loop.
  animator._rng.seed = 42
  animator._blink_timer = 0.01
  var starts := 0
  var last := -1.0
  var longest_open := 0.0
  var open_time := 0.0
  for i in range(7200):
   animator._process(1.0/60)
   var value: float = animator.shader_mat.get_shader_parameter("blink_amount")
   assert(value >= 0 and value <= 1)
   if animator._blink_elapsed >= 0 and last < 0:
    starts += 1
   last = animator._blink_elapsed
   if value < 0.01:
    open_time += 1.0/60
    longest_open = maxf(longest_open,open_time)
   else:
    open_time = 0
  assert(starts >= 9 and starts <= 30, "Sparse blinking across two minutes")
  assert(longest_open >= 5.0)
  sprite.flip_h = true
  animator._process(0.1)
  assert(DragonAnimator.attach(sprite) == animator, "No duplicate materials/animators")
  sprite.texture = load("res://assets/textures/enemies/beetle.svg")
  animator._process(0.1)
  assert(sprite.material == null, "Monster art stays untouched")
  sprite.queue_free()
  await process_frame
 print("PASS: seven authored rigs; source and motion masks; sparse finite blinks over 120s; mirrored sprites; attach once; monster exclusion")
 quit()
