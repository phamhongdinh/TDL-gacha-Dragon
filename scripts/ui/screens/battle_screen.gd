class_name BattleScreen
extends Control

## Màn hình PK 3v3 Đấu Hạng (Auto-Battle theo lượt).
## Giữ tương thích với hệ thống BattleManager để không phá vỡ các bài test tích hợp sẵn có.

const GOLD := Color("eacb83")
const GOLD_BRIGHT := Color("ffe699")
const DARK_BG := Color("0b202b")
const PANEL_BG := Color("0f2836")
const MUTED := Color("adc0c9")

const SKILL_COST_BASIC := 0
const SKILL_COST_ULTIMATE := 140
const SKILL_COST_SUPPORT := 160

## Cấu hình đội hình giả lập 3v3 để xem và tương tác ngay khi mở scene.
## GHI CHÚ THAY ẢNH:
## - Đội trái dùng đúng 3 sprite gốc: water_shadow.png, fire_shadow.png, triple.png (giữ nguyên màu gốc).
## - Đội phải tái sử dụng water.png (vị trí rồng Băng), fire_water.png (vị trí rồng Thổ), shadow.png (vị trí rồng Nguyệt/Bóng Tối).
##   Khi có thêm ảnh rồng Băng/Thổ/Nguyệt riêng, chỉ cần thay đường dẫn `texture_path` tại đây.
const DEFAULT_PK_ROSTER := [
    {
        "id": "ally_fire_shadow",
        "name": "RỒNG HỎA · BÓNG TỐI",
        "side": "player",
        "element": "fire",
        "texture_path": "res://assets/textures/dragons/fire_shadow.png",
        "flip_h": false,
        "max_hp": 5990,
        "hp": 5990,
        "max_energy": 200,
        "energy": 120,
        "attack": 1680,
        "defense": 340,
        "speed": 125,
        "pos_ratio": Vector2(0.285, 0.275),
        "slot_size": Vector2(252, 224),
        "sprite_size": Vector2(228, 184),
        "bob_phase": 0.0,
        "placeholder_note": ""
    },
    {
        "id": "ally_water_shadow",
        "name": "RỒNG THỦY · BÓNG TỐI",
        "side": "player",
        "element": "water",
        "texture_path": "res://assets/textures/dragons/water_shadow.png",
        "flip_h": true,
        "max_hp": 5820,
        "hp": 5820,
        "max_energy": 200,
        "energy": 90,
        "attack": 1490,
        "defense": 360,
        "speed": 115,
        "pos_ratio": Vector2(0.130, 0.132),
        "slot_size": Vector2(228, 212),
        "sprite_size": Vector2(204, 170),
        "bob_phase": 1.4,
        "placeholder_note": ""
    },
    {
        "id": "ally_triple",
        "name": "RỒNG TAM HỆ",
        "side": "player",
        "element": "triple",
        "texture_path": "res://assets/textures/dragons/triple.png",
        "flip_h": false,
        "max_hp": 6360,
        "hp": 6360,
        "max_energy": 200,
        "energy": 140,
        "attack": 1820,
        "defense": 390,
        "speed": 108,
        "pos_ratio": Vector2(0.032, 0.358),
        "slot_size": Vector2(246, 224),
        "sprite_size": Vector2(224, 184),
        "bob_phase": 2.6,
        "placeholder_note": ""
    },
    {
        "id": "enemy_ice",
        "name": "RỒNG BĂNG HÀN",
        "side": "enemy",
        "element": "ice",
        "texture_path": "res://assets/textures/dragons/water.png",
        "flip_h": false,
        "max_hp": 5820,
        "hp": 4180,
        "max_energy": 200,
        "energy": 100,
        "attack": 1460,
        "defense": 310,
        "speed": 102,
        "pos_ratio": Vector2(0.548, 0.282),
        "slot_size": Vector2(236, 214),
        "sprite_size": Vector2(208, 172),
        "bob_phase": 0.8,
        "placeholder_note": "Placeholder: đang tái sử dụng water.png cho vị trí Rồng Băng. Thay texture_path khi có sprite hệ Băng riêng."
    },
    {
        "id": "enemy_earth",
        "name": "RỒNG NHAM THẠCH",
        "side": "enemy",
        "element": "earth",
        "texture_path": "res://assets/textures/dragons/fire_water.png",
        "flip_h": false,
        "max_hp": 7200,
        "hp": 7200,
        "max_energy": 200,
        "energy": 80,
        "attack": 1520,
        "defense": 420,
        "speed": 92,
        "pos_ratio": Vector2(0.708, 0.128),
        "slot_size": Vector2(228, 212),
        "sprite_size": Vector2(202, 168),
        "bob_phase": 2.1,
        "placeholder_note": "Placeholder: đang tái sử dụng fire_water.png cho vị trí Rồng Thổ. Thay texture_path khi có sprite hệ Thổ riêng."
    },
    {
        "id": "enemy_shadow",
        "name": "RỒNG NGUYỆT ẢNH",
        "side": "enemy",
        "element": "shadow",
        "texture_path": "res://assets/textures/dragons/shadow.png",
        "flip_h": true,
        "max_hp": 5680,
        "hp": 5680,
        "max_energy": 200,
        "energy": 110,
        "attack": 1590,
        "defense": 330,
        "speed": 85,
        "pos_ratio": Vector2(0.788, 0.362),
        "slot_size": Vector2(236, 220),
        "sprite_size": Vector2(210, 176),
        "bob_phase": 3.3,
        "placeholder_note": "Tái sử dụng shadow.png (lật ngang) cho vị trí Rồng Nguyệt Ảnh đội đối thủ."
    }
]

# Biến giữ tương thích với tests/battle_integration.gd
var battle: BattleManager
var mode := "pk"
var selected_stage := "rift_1"
var party: Array[DragonInstance] = []
var notice := ""

# Trạng thái màn PK 3v3
var pk_root: Control
var arena_backdrop: PkArenaBackdrop
var arena_stage: Control
var left_team_layer: Control
var right_team_layer: Control
var top_hud_bar: Control
var turn_order_bar: Control
var bottom_hud_panel: Control

var fighters: Array[PkFighterSlot] = []
var fighter_by_id: Dictionary = {}
var turn_order_ids: Array[String] = []
var current_turn_index: int = 2 # Nổi bật Rồng Tam Hệ sắp ra lượt tiếp theo sau pha tấn công mở màn
var turn_number: int = 4
var match_seconds: float = 42.0
var selected_fighter_id: String = "ally_triple"
var active_fighter_id: String = "ally_fire_shadow"

var auto_battle: bool = false
var speed_multiplier: int = 2 # 1 hoặc 2
var action_in_progress: bool = false
var match_finished: bool = false
var step_cooldown: float = 2.0

# Các node hiển thị HUD cập nhật động
var turn_badge_label: Label
var timer_label: Label
var status_banner_label: Label
var turn_icon_panels: Array[Panel] = []
var turn_icon_portraits: Array[TextureRect] = []
var selected_portrait: TextureRect
var selected_name_label: Label
var selected_hp_bar: ProgressBar
var selected_hp_label: Label
var selected_energy_bar: ProgressBar
var selected_energy_label: Label
var skill_btn_basic: PkSkillButton
var skill_btn_ultimate: PkSkillButton
var skill_btn_support: PkSkillButton
var btn_auto: Button
var btn_speed: Button
var btn_skip: Button
var result_modal: Control
var roster: Array[Dictionary] = []
var units: Dictionary = {}
var team_picker: Control
var skills_holder: HBoxContainer
var ability_buttons: Array[PkSkillButton] = []
var chosen_skill := "basic"
var chosen_target := ""
var confirm_button: Button
var picker_buttons: Dictionary = {}
var picker_summary: Control
var picker_page := 0
const PICKER_PAGE_SIZE := 12

func _ready() -> void:
    battle = BattleManager.new()
    add_child(battle)
    _ensure_pk_structure()
    pk_root.visible = false
    _show_chapters()
    resized.connect(_layout_fighters)

func _ensure_pk_structure() -> void:
    pk_root = get_node_or_null("PkRoot")
    if pk_root == null:
        pk_root = Control.new()
        pk_root.name = "PkRoot"
        pk_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        add_child(pk_root)

    arena_backdrop = pk_root.get_node_or_null("ArenaBackdrop")
    if arena_backdrop == null:
        arena_backdrop = PkArenaBackdrop.new()
        arena_backdrop.name = "ArenaBackdrop"
        arena_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        pk_root.add_child(arena_backdrop)

    arena_stage = pk_root.get_node_or_null("ArenaStage")
    if arena_stage == null:
        arena_stage = Control.new()
        arena_stage.name = "ArenaStage"
        arena_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        arena_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
        pk_root.add_child(arena_stage)

    left_team_layer = arena_stage.get_node_or_null("LeftTeamLayer")
    if left_team_layer == null:
        left_team_layer = Control.new()
        left_team_layer.name = "LeftTeamLayer"
        left_team_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        left_team_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        arena_stage.add_child(left_team_layer)

    right_team_layer = arena_stage.get_node_or_null("RightTeamLayer")
    if right_team_layer == null:
        right_team_layer = Control.new()
        right_team_layer.name = "RightTeamLayer"
        right_team_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        right_team_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        arena_stage.add_child(right_team_layer)

    top_hud_bar = pk_root.get_node_or_null("TopHudBar")
    if top_hud_bar == null:
        top_hud_bar = Control.new()
        top_hud_bar.name = "TopHudBar"
        top_hud_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
        top_hud_bar.offset_bottom = 96.0
        pk_root.add_child(top_hud_bar)

    turn_order_bar = pk_root.get_node_or_null("TurnOrderBar")
    if turn_order_bar == null:
        turn_order_bar = Control.new()
        turn_order_bar.name = "TurnOrderBar"
        turn_order_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
        turn_order_bar.offset_top = -224.0
        turn_order_bar.offset_bottom = -162.0
        pk_root.add_child(turn_order_bar)

    bottom_hud_panel = pk_root.get_node_or_null("BottomHudPanel")
    if bottom_hud_panel == null:
        bottom_hud_panel = Control.new()
        bottom_hud_panel.name = "BottomHudPanel"
        bottom_hud_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
        bottom_hud_panel.offset_left = 10.0
        bottom_hud_panel.offset_top = -156.0
        bottom_hud_panel.offset_right = -10.0
        bottom_hud_panel.offset_bottom = -8.0
        pk_root.add_child(bottom_hud_panel)

func _build_pk_screen() -> void:
    _build_top_bar()
    _spawn_fighters()
    _build_turn_order_bar()
    _build_bottom_panel()
    _refresh_all_hud()

# ============================================================================
# 1. THANH TRÊN CÙNG (TOP HUD BAR)
# ============================================================================
func _build_top_bar() -> void:
    for child in top_hud_bar.get_children():
        top_hud_bar.remove_child(child)
        child.queue_free()

    # Thẻ người chơi bên trái (ĐỈNH - Lv.12)
    var left_card := Panel.new()
    left_card.anchor_left = 0.0
    left_card.anchor_right = 0.0
    left_card.offset_left = 14.0
    left_card.offset_top = 10.0
    left_card.offset_right = 344.0
    left_card.offset_bottom = 78.0
    left_card.add_theme_stylebox_override("panel", _ornate_style(Color("0d2734e8"), GOLD, 34, 2))
    top_hud_bar.add_child(left_card)

    var left_avatar_frame := Panel.new()
    left_avatar_frame.position = Vector2(4, 3)
    left_avatar_frame.size = Vector2(62, 62)
    left_avatar_frame.clip_contents = true
    left_avatar_frame.add_theme_stylebox_override("panel", _ornate_style(Color("163d52"), GOLD_BRIGHT, 31, 2))
    left_card.add_child(left_avatar_frame)

    var left_avatar := TextureRect.new()
    left_avatar.texture = load("res://assets/textures/dragons/water_shadow.png")
    left_avatar.position = Vector2(5, 5)
    left_avatar.size = Vector2(52, 52)
    left_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    left_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    left_avatar.flip_h = true
    left_avatar_frame.add_child(left_avatar)
    left_avatar.set_deferred("size", Vector2(52, 52))

    var left_name := _styled_label("ĐỘI CỦA BẠN", 20, Color("ffffff"))
    left_name.position = Vector2(82, 9)
    left_name.size = Vector2(190, 28)
    left_card.add_child(left_name)

    var left_lv_badge := Panel.new()
    left_lv_badge.position = Vector2(78, 39)
    left_lv_badge.size = Vector2(92, 22)
    left_lv_badge.add_theme_stylebox_override("panel", _ornate_style(Color("091c26"), Color("9b834e"), 10, 1))
    left_card.add_child(left_lv_badge)

    var left_lv := _styled_label("%d rồng" % party.size(), 13, GOLD_BRIGHT)
    left_lv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    left_lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    left_lv.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    left_lv_badge.add_child(left_lv)

    # Nút nhỏ quay về Trang chủ ở góc trái
    var back_btn := Button.new()
    back_btn.text = "< Trang chủ"
    back_btn.position = Vector2(226, 37)
    back_btn.size = Vector2(92, 24)
    back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    back_btn.add_theme_font_size_override("font_size", 11)
    back_btn.add_theme_color_override("font_color", GOLD)
    back_btn.add_theme_stylebox_override("normal", _ornate_style(Color("143444"), Color("6c8791"), 8, 1))
    back_btn.add_theme_stylebox_override("hover", _ornate_style(Color("224b5e"), GOLD, 8, 1))
    back_btn.pressed.connect(func():
        if ResourceLoader.exists("res://scenes/main/main_menu.tscn"):
            get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
    )
    left_card.add_child(back_btn)

    # Khung trung tâm: ĐẤU HẠNG + LƯỢT + THỜI GIAN TRẬN ĐẤU
    var center_box := Control.new()
    center_box.anchor_left = 0.5
    center_box.anchor_right = 0.5
    center_box.offset_left = -190.0
    center_box.offset_top = 4.0
    center_box.offset_right = 190.0
    center_box.offset_bottom = 94.0
    center_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    top_hud_bar.add_child(center_box)

    var crest_panel := Panel.new()
    crest_panel.position = Vector2(25, 2)
    crest_panel.size = Vector2(330, 52)
    crest_panel.add_theme_stylebox_override("panel", _ornate_style(Color("0f2b38"), GOLD_BRIGHT, 18, 2))
    center_box.add_child(crest_panel)

    var ranked_title := _styled_label("CHƯƠNG %d" % BattleCatalog.chapter(selected_stage).number, 26, Color("fff3d1"))
    ranked_title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ranked_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ranked_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    crest_panel.add_child(ranked_title)

    var turn_plate := Panel.new()
    turn_plate.position = Vector2(78, 46)
    turn_plate.size = Vector2(224, 34)
    turn_plate.add_theme_stylebox_override("panel", _ornate_style(Color("163442"), GOLD, 12, 2))
    center_box.add_child(turn_plate)

    turn_badge_label = _styled_label("LƯỢT 04", 15, Color("fff7df"))
    turn_badge_label.position = Vector2(12, 1)
    turn_badge_label.size = Vector2(112, 30)
    turn_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    turn_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    turn_plate.add_child(turn_badge_label)

    timer_label = _styled_label("⏱ 00:42", 13, Color("7ef2e6"))
    timer_label.position = Vector2(120, 1)
    timer_label.size = Vector2(94, 30)
    timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    turn_plate.add_child(timer_label)

    # Thẻ đối thủ bên phải (HẮC LONG - Lv.12)
    var right_card := Panel.new()
    right_card.anchor_left = 1.0
    right_card.anchor_right = 1.0
    right_card.offset_left = -344.0
    right_card.offset_top = 10.0
    right_card.offset_right = -14.0
    right_card.offset_bottom = 78.0
    right_card.add_theme_stylebox_override("panel", _ornate_style(Color("0d2734e8"), GOLD, 34, 2))
    top_hud_bar.add_child(right_card)

    var right_name := _styled_label("QUÁI KHE NỨT", 20, Color("ffffff"))
    right_name.position = Vector2(24, 9)
    right_name.size = Vector2(222, 28)
    right_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    right_card.add_child(right_name)

    var right_lv_badge := Panel.new()
    right_lv_badge.position = Vector2(160, 39)
    right_lv_badge.size = Vector2(92, 22)
    right_lv_badge.add_theme_stylebox_override("panel", _ornate_style(Color("091c26"), Color("9b834e"), 10, 1))
    right_card.add_child(right_lv_badge)

    var right_lv := _styled_label("3 quái vật", 13, GOLD_BRIGHT)
    right_lv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    right_lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    right_lv.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    right_lv_badge.add_child(right_lv)

    var right_avatar_frame := Panel.new()
    right_avatar_frame.position = Vector2(264, 3)
    right_avatar_frame.size = Vector2(62, 62)
    right_avatar_frame.clip_contents = true
    right_avatar_frame.add_theme_stylebox_override("panel", _ornate_style(Color("311d4a"), GOLD_BRIGHT, 31, 2))
    right_card.add_child(right_avatar_frame)

    var right_avatar := TextureRect.new()
    right_avatar.texture = load("res://assets/textures/enemies/beetle.svg")
    right_avatar.position = Vector2(5, 5)
    right_avatar.size = Vector2(52, 52)
    right_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    right_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    right_avatar.flip_h = true
    right_avatar_frame.add_child(right_avatar)
    right_avatar.set_deferred("size", Vector2(52, 52))

# ============================================================================
# 2. ĐẤU TRƯỜNG TRUNG TÂM 3v3 (ARENA STAGE)
# ============================================================================
func _spawn_fighters() -> void:
    for child in left_team_layer.get_children():
        left_team_layer.remove_child(child)
        child.queue_free()
    for child in right_team_layer.get_children():
        right_team_layer.remove_child(child)
        child.queue_free()

    fighters.clear()
    fighter_by_id.clear()
    turn_order_ids.clear()

    for entry in roster:
        var slot := PkFighterSlot.new()
        slot.setup(entry)
        slot.set_meta("pos_ratio", entry.pos_ratio)
        slot.fighter_clicked.connect(_on_fighter_clicked)
        if entry.side == "player":
            left_team_layer.add_child(slot)
        else:
            right_team_layer.add_child(slot)
        fighters.append(slot)
        fighter_by_id[slot.fighter_id] = slot
        turn_order_ids.append(slot.fighter_id)

    _layout_fighters()

func _layout_fighters() -> void:
    var w := size.x if size.x > 0 else 1280.0
    var h := size.y if size.y > 0 else 720.0
    for slot in fighters:
        if not is_instance_valid(slot):
            continue
        var ratio: Vector2 = slot.get_meta("pos_ratio", Vector2(0.2, 0.25))
        slot.position = Vector2(w * ratio.x, h * ratio.y)


func _build_turn_order_bar() -> void:
    for child in turn_order_bar.get_children():
        turn_order_bar.remove_child(child)
        child.queue_free()
    turn_icon_panels.clear()
    turn_icon_portraits.clear()

    var bar_panel := Panel.new()
    bar_panel.anchor_left = 0.5
    bar_panel.anchor_right = 0.5
    bar_panel.offset_left = -336.0
    bar_panel.offset_top = 4.0
    bar_panel.offset_right = 336.0
    bar_panel.offset_bottom = 58.0
    bar_panel.add_theme_stylebox_override("panel", _ornate_style(Color("0b212de6"), GOLD, 16, 2))
    turn_order_bar.add_child(bar_panel)

    var hbox := HBoxContainer.new()
    hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hbox.offset_left = 18.0
    hbox.offset_right = -18.0
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    hbox.add_theme_constant_override("separation", 8)
    bar_panel.add_child(hbox)

    var title := _styled_label("THỨ TỰ RA LƯỢT  >", 13, Color("fff3d4"))
    hbox.add_child(title)

    for i in range(turn_order_ids.size()):
        var fid := turn_order_ids[i]
        var slot: PkFighterSlot = fighter_by_id[fid]

        var icon_frame := Panel.new()
        icon_frame.custom_minimum_size = Vector2(44, 44)
        icon_frame.size = Vector2(44, 44)
        icon_frame.clip_contents = true
        icon_frame.add_theme_stylebox_override("panel", _ornate_style(Color("173444"), GOLD, 8, 2))
        hbox.add_child(icon_frame)
        turn_icon_panels.append(icon_frame)

        var portrait := TextureRect.new()
        portrait.texture = slot.dragon_sprite.texture
        portrait.position = Vector2(3, 3)
        portrait.size = Vector2(38, 38)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        icon_frame.add_child(portrait)
        portrait.set_deferred("size", Vector2(38, 38))
        turn_icon_portraits.append(portrait)

        var btn := Button.new()
        btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        btn.flat = true
        btn.tooltip_text = "Thứ tự %d: %s" % [i + 1, slot.display_name]
        btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        btn.pressed.connect(_on_fighter_clicked.bind(fid))
        icon_frame.add_child(btn)

        if i < turn_order_ids.size() - 1:
            var arrow := _styled_label(">", 14, GOLD)
            hbox.add_child(arrow)

# ============================================================================
# 4. BẢNG ĐIỀU KHIỂN PHÍA DƯỚI (BOTTOM HUD PANEL)
# ============================================================================
func _build_bottom_panel() -> void:
    for child in bottom_hud_panel.get_children():
        bottom_hud_panel.remove_child(child)
        child.queue_free()
    for child in bottom_hud_panel.get_children():
        bottom_hud_panel.remove_child(child)
        child.queue_free()

    var main_bg := Panel.new()
    main_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    main_bg.add_theme_stylebox_override("panel", _ornate_style(Color("0a202cf2"), GOLD, 18, 2))
    bottom_hud_panel.add_child(main_bg)

    # --- 4A. Khung thông tin rồng đang chọn (Bên trái) ---
    var info_card := Panel.new()
    info_card.position = Vector2(10, 10)
    info_card.size = Vector2(442, 128)
    info_card.add_theme_stylebox_override("panel", _ornate_style(Color("102c3b"), GOLD, 16, 2))
    main_bg.add_child(info_card)

    var portrait_frame := Panel.new()
    portrait_frame.position = Vector2(10, 8)
    portrait_frame.size = Vector2(112, 112)
    portrait_frame.clip_contents = true
    portrait_frame.add_theme_stylebox_override("panel", _ornate_style(Color("1a394b"), GOLD_BRIGHT, 14, 2))
    info_card.add_child(portrait_frame)

    selected_portrait = TextureRect.new()
    selected_portrait.position = Vector2(4, 4)
    selected_portrait.size = Vector2(104, 104)
    selected_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    selected_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait_frame.add_child(selected_portrait)
    selected_portrait.set_deferred("size", Vector2(104, 104))

    selected_name_label = _styled_label("RỒNG TAM HỆ", 21, Color("fff6df"))
    selected_name_label.position = Vector2(136, 10)
    selected_name_label.size = Vector2(292, 28)
    info_card.add_child(selected_name_label)

    # Dòng HP
    var heart_icon := _styled_label("♥", 16, Color("ff8c69"))
    heart_icon.position = Vector2(136, 42)
    heart_icon.size = Vector2(20, 22)
    info_card.add_child(heart_icon)

    selected_hp_label = _styled_label("HP   6360 / 6360", 14, Color("f2f8ff"))
    selected_hp_label.position = Vector2(158, 42)
    selected_hp_label.size = Vector2(260, 20)
    info_card.add_child(selected_hp_label)

    var hp_bg := _ornate_style(Color("091922"), Color("5a7e8a"), 6, 1)
    var hp_fill := _ornate_style(Color("3ad856"), Color("9affab"), 5, 1)
    selected_hp_bar = ProgressBar.new()
    selected_hp_bar.position = Vector2(156, 65)
    selected_hp_bar.custom_minimum_size = Vector2(268, 12)
    selected_hp_bar.size = Vector2(268, 12)
    selected_hp_bar.max_value = 6360
    selected_hp_bar.value = 6360
    selected_hp_bar.show_percentage = false
    selected_hp_bar.add_theme_font_size_override("font_size", 1)
    selected_hp_bar.add_theme_stylebox_override("background", hp_bg)
    selected_hp_bar.add_theme_stylebox_override("fill", hp_fill)
    info_card.add_child(selected_hp_bar)
    selected_hp_bar.set_deferred("size", Vector2(268, 12))

    # Dòng Năng lượng
    var bolt_icon := _styled_label("⚡", 15, Color("56e8ff"))
    bolt_icon.position = Vector2(136, 82)
    bolt_icon.size = Vector2(20, 22)
    info_card.add_child(bolt_icon)

    selected_energy_label = _styled_label("NĂNG LƯỢNG   140 / 200", 13, Color("d8f4ff"))
    selected_energy_label.position = Vector2(158, 82)
    selected_energy_label.size = Vector2(260, 20)
    info_card.add_child(selected_energy_label)

    var en_bg := _ornate_style(Color("091922"), Color("4d7588"), 6, 1)
    var en_fill := _ornate_style(Color("22c4ff"), Color("aef4ff"), 5, 1)
    selected_energy_bar = ProgressBar.new()
    selected_energy_bar.position = Vector2(156, 105)
    selected_energy_bar.custom_minimum_size = Vector2(268, 12)
    selected_energy_bar.size = Vector2(268, 12)
    selected_energy_bar.max_value = 200
    selected_energy_bar.value = 140
    selected_energy_bar.show_percentage = false
    selected_energy_bar.add_theme_font_size_override("font_size", 1)
    selected_energy_bar.add_theme_stylebox_override("background", en_bg)
    selected_energy_bar.add_theme_stylebox_override("fill", en_fill)
    info_card.add_child(selected_energy_bar)
    selected_energy_bar.set_deferred("size", Vector2(268, 12))

    # --- 4B. Cụm 3 nút kỹ năng ở giữa (KỸ NĂNG / TUYỆT KỸ / HỖ TRỢ) ---
    skills_holder = HBoxContainer.new()
    skills_holder.anchor_left = 0.5
    skills_holder.anchor_right = 0.5
    skills_holder.offset_left = -168.0
    skills_holder.offset_top = 8.0
    skills_holder.offset_right = 266.0
    skills_holder.offset_bottom = 138.0
    skills_holder.alignment = BoxContainer.ALIGNMENT_CENTER
    skills_holder.add_theme_constant_override("separation", 18)
    main_bg.add_child(skills_holder)


    # Vạch ngăn cách vàng kim bên phải cụm kỹ năng
    var divider := ColorRect.new()
    divider.anchor_left = 1.0
    divider.anchor_right = 1.0
    divider.offset_left = -332.0
    divider.offset_top = 24.0
    divider.offset_right = -330.0
    divider.offset_bottom = 124.0
    divider.color = Color(0.84, 0.70, 0.42, 0.55)
    main_bg.add_child(divider)

    # --- 4C. Cụm 3 nút điều khiển trận (TỰ ĐỘNG / TỐC ĐỘ x1-x2 / BỎ QUA) ---
    var controls_box := HBoxContainer.new()
    controls_box.anchor_left = 1.0
    controls_box.anchor_right = 1.0
    controls_box.offset_left = -316.0
    controls_box.offset_top = 24.0
    controls_box.offset_right = -16.0
    controls_box.offset_bottom = 124.0
    controls_box.alignment = BoxContainer.ALIGNMENT_CENTER
    controls_box.add_theme_constant_override("separation", 10)
    main_bg.add_child(controls_box)

    btn_auto = _create_control_button("✋\nTHỦ CÔNG", false)
    btn_auto.pressed.connect(_toggle_auto_battle)
    controls_box.add_child(btn_auto)

    btn_speed = _create_control_button(">>\nTỐC ĐỘ x2", false)
    btn_speed.pressed.connect(_toggle_speed)
    controls_box.add_child(btn_speed)

    btn_skip = _create_control_button("✦\nXÁC NHẬN", true)
    btn_skip.pressed.connect(_confirm_skill)
    controls_box.add_child(btn_skip)

    # Dòng thông báo trạng thái nhỏ phía trên góc phải bảng dưới
    status_banner_label = _styled_label("Chọn kỹ năng hệ, mục tiêu rồi XÁC NHẬN", 11, MUTED)
    status_banner_label.anchor_left = 1.0
    status_banner_label.anchor_right = 1.0
    status_banner_label.offset_left = -800.0
    status_banner_label.offset_top = 4.0
    status_banner_label.offset_right = -20.0
    status_banner_label.offset_bottom = 22.0
    status_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    status_banner_label.clip_text = true
    main_bg.add_child(status_banner_label)

func _create_control_button(label_text: String, active_gold: bool) -> Button:
    var btn := Button.new()
    btn.custom_minimum_size = Vector2(92, 92)
    btn.text = label_text
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.add_theme_font_size_override("font_size", 13)
    _apply_control_button_style(btn, active_gold)
    return btn

func _apply_control_button_style(btn: Button, active_gold: bool) -> void:
    var border_col := GOLD_BRIGHT if active_gold else Color("8b9da6")
    var bg_col := Color("2d3422") if active_gold else Color("102a37")
    btn.add_theme_color_override("font_color", GOLD_BRIGHT if active_gold else Color("eaf4f7"))
    btn.add_theme_stylebox_override("normal", _ornate_style(bg_col, border_col, 14, 2 if active_gold else 1))
    btn.add_theme_stylebox_override("hover", _ornate_style(bg_col.lightened(0.12), GOLD_BRIGHT, 14, 2))
    btn.add_theme_stylebox_override("pressed", _ornate_style(bg_col.darkened(0.15), GOLD, 14, 2))

# ============================================================================
# CẬP NHẬT GIAO DIỆN & VÒNG LẶP CHIẾN ĐẤU TỰ ĐỘNG
# ============================================================================
func _process(delta: float) -> void:
    if mode != "pk" or match_finished or units.is_empty():
        return
    match_seconds += delta * speed_multiplier
    _update_header_clock()
    if action_in_progress:
        return
    if not auto_battle and battle.active != null and battle.active.side == "player":
        return
    step_cooldown -= delta * speed_multiplier
    if step_cooldown <= 0:
        _execute_next_turn_action()

func _update_header_clock() -> void:
    if turn_badge_label != null:
        turn_badge_label.text = "LƯỢT %02d" % turn_number
    if timer_label != null:
        var mins := int(match_seconds) / 60
        var secs := int(match_seconds) % 60
        timer_label.text = "⏱ %02d:%02d" % [mins, secs]

func _refresh_all_hud() -> void:
    _update_header_clock()

    # Làm nổi bật rồng sắp ra lượt trên thanh thứ tự lượt
    for i in range(turn_order_ids.size()):
        if i >= turn_icon_panels.size():
            break
        var fid := turn_order_ids[i]
        var unit: PkFighterSlot = fighter_by_id[fid]
        var panel := turn_icon_panels[i]
        var portrait := turn_icon_portraits[i]
        var is_next := (i == current_turn_index)
        if is_next:
            panel.add_theme_stylebox_override("panel", _ornate_style(Color("3c3118"), GOLD_BRIGHT, 10, 3))
            panel.scale = Vector2(1.08, 1.08)
        else:
            var border_c := Color("4992a6") if unit.team_side == "player" else Color("85587a")
            panel.add_theme_stylebox_override("panel", _ornate_style(Color("112936"), border_c, 8, 1))
            panel.scale = Vector2.ONE
        portrait.modulate.a = 1.0 if unit.hp > 0 else 0.3

    # Cập nhật bảng rồng đang chọn ở góc dưới trái
    var selected: PkFighterSlot = fighter_by_id.get(selected_fighter_id)
    if selected == null:
        selected = fighters[0]
    if selected_portrait != null:
        selected_portrait.texture = selected.dragon_sprite.texture
    if selected_name_label != null:
        selected_name_label.text = selected.display_name
    if selected_hp_bar != null:
        selected_hp_bar.max_value = selected.max_hp
        selected_hp_bar.value = selected.hp
    if selected_hp_label != null:
        selected_hp_label.text = "HP   %d / %d" % [selected.hp, selected.max_hp]
    if selected_energy_bar != null:
        selected_energy_bar.max_value = selected.max_energy
        selected_energy_bar.visible = false
    if selected_energy_label != null:
        selected_energy_label.text = "KỸ NĂNG HỆ · HỒI CHIÊU THEO LƯỢT"

    _refresh_ability_buttons()

func _on_fighter_clicked(fighter_id: String) -> void:
    if not units.has(fighter_id):
        return
    var unit: BattleUnitData = units[fighter_id]
    if unit.side == "enemy":
        if unit.alive():
            chosen_target = fighter_id
    else:
        selected_fighter_id = fighter_id
    _refresh_all_hud()
    _preview_skill()

func _on_player_skill_pressed(skill_id: String) -> void:
    chosen_skill = skill_id
    _refresh_all_hud()
    _preview_skill()

func _execute_next_turn_action() -> void:
    if match_finished or action_in_progress:
        return
    var actor := battle.next_turn()
    _sync_units()
    if actor == null:
        _check_pk_match_end()
        return
    active_fighter_id = actor.id
    current_turn_index = turn_order_ids.find(actor.id)
    turn_number = battle.round_number
    if actor.side == "player":
        selected_fighter_id = actor.id
        if not actor.skills.has(chosen_skill):
            chosen_skill = "basic"
        _refresh_all_hud()
        if not auto_battle:
            step_cooldown = 0.2
            _preview_skill()
            return
    var ability := "basic"
    for id in actor.skills:
        if int(actor.cooldowns.get(id,0)) == 0:
            ability = id
            break
    if actor.side == "enemy" and int(actor.cooldowns.get(actor.skill,0)) == 0:
        if actor.ai != "elite" or not actor.intent.is_empty():
            ability = actor.skill
    var targets := battle.legal_targets(actor,ability)
    if actor.ai == "weakest":
        targets.sort_custom(func(a:BattleUnitData,b:BattleUnitData): return float(a.hp)/a.max_hp < float(b.hp)/b.max_hp)
    if not targets.is_empty():
        _perform_combat_action(fighter_by_id[actor.id],ability,targets[0].id)

func _perform_combat_action(actor: PkFighterSlot, skill_id: String, target_id: String = "") -> void:
    if action_in_progress or battle.active == null or battle.active.id != actor.fighter_id:
        return
    action_in_progress = true
    var hp_before := {}
    for id in units:
        hp_before[id] = units[id].hp
    var error := battle.act(skill_id,target_id)
    if not error.is_empty():
        action_in_progress = false
        status_banner_label.text = error
        return
    var points: Array[Vector2] = []
    var did_miss := false
    for id in units:
        if int(hp_before[id]) > units[id].hp:
            points.append(fighter_by_id[id].get_center_global_or_local())
    if points.is_empty():
        did_miss = true
        if fighter_by_id.has(target_id):
            points.append(fighter_by_id[target_id].get_center_global_or_local())
    var effect := PkSkillVfx.new()
    effect.setup(actor.get_center_global_or_local(),points,_skill_element(skill_id,actor.element_key),skill_id == "basic",speed_multiplier,did_miss)
    pk_root.add_child(effect)
    _play_sfx("charge" if skill_id != "basic" else "hover")
    var direction := 1.0 if actor.team_side == "player" else -1.0
    var tw := create_tween()
    tw.tween_property(actor,"anim_offset",Vector2(-12*direction,-8),0.22/speed_multiplier)
    tw.tween_property(actor,"anim_offset",Vector2(40*direction,-14),0.24/speed_multiplier)
    await effect.impact
    if not is_inside_tree():
        return
    for id in units:
        var slot: PkFighterSlot = fighter_by_id[id]
        var damage: int = int(hp_before[id])-units[id].hp
        if damage > 0:
            slot.show_floating_damage(damage,false,1.0/speed_multiplier)
            var recoil := create_tween()
            recoil.tween_property(slot,"anim_offset",Vector2(15*direction,-5),0.09/speed_multiplier)
            recoil.tween_property(slot,"anim_offset",Vector2.ZERO,0.22/speed_multiplier)
    _play_sfx("crack" if skill_id == "ice_tide" else "rare" if skill_id == "dark_pierce" else "hatch")
    _sync_units()
    status_banner_label.text = " · ".join(battle.log_lines.slice(maxi(0,battle.log_lines.size()-4)))
    status_banner_label.tooltip_text = "\n".join(battle.log_lines.slice(maxi(0,battle.log_lines.size()-12)))
    var back := create_tween()
    back.tween_property(actor,"anim_offset",Vector2.ZERO,0.3/speed_multiplier)
    await effect.completed
    if not is_inside_tree():
        return
    action_in_progress = false
    chosen_skill = "basic"
    step_cooldown = 0.8
    _refresh_all_hud()
    _check_pk_match_end()

func _pick_target(side: String) -> PkFighterSlot:
    for slot in fighters:
        if slot.team_side == side and slot.hp > 0:
            return slot
    return null

func _pick_lowest_hp_ally(side: String) -> PkFighterSlot:
    var best: PkFighterSlot = null
    var best_ratio := 2.0
    for slot in fighters:
        if slot.team_side == side and slot.hp > 0:
            var ratio := float(slot.hp) / float(slot.max_hp)
            if ratio < best_ratio:
                best_ratio = ratio
                best = slot
    return best

# ============================================================================
# NÚT ĐIỀU KHIỂN TRẬN: TỰ ĐỘNG / TỐC ĐỘ x1-x2 / BỎ QUA
# ============================================================================
func _toggle_auto_battle() -> void:
    auto_battle = not auto_battle
    if btn_auto != null:
        btn_auto.text = "↻\nTỰ ĐỘNG" if auto_battle else "✋\nTHỦ CÔNG"
        _apply_control_button_style(btn_auto, auto_battle)
    if status_banner_label != null:
        status_banner_label.text = "Đã BẬT chế độ chiến đấu tự động" if auto_battle else "Thủ công: chọn kỹ năng hệ, mục tiêu rồi XÁC NHẬN"
    if auto_battle and not action_in_progress:
        step_cooldown = 0.25

func _toggle_speed() -> void:
    speed_multiplier = 1 if speed_multiplier == 2 else 2
    if btn_speed != null:
        btn_speed.text = ">>\nTỐC ĐỘ x%d" % speed_multiplier
        _apply_control_button_style(btn_speed, speed_multiplier == 2)
    if status_banner_label != null:
        status_banner_label.text = "Tốc độ trận đấu: x%d" % speed_multiplier

func _skip_battle() -> void:
    _confirm_skill()

func _check_pk_match_end() -> void:
    var allies_alive := 0
    var enemies_alive := 0
    for slot in fighters:
        if slot.hp > 0:
            if slot.team_side == "player":
                allies_alive += 1
            else:
                enemies_alive += 1
    if allies_alive > 0 and enemies_alive > 0:
        return

    match_finished = true
    var won := allies_alive > 0
    _show_pk_result_modal(won, allies_alive)

func _show_pk_result_modal(won: bool, allies_alive: int) -> void:
    if is_instance_valid(result_modal):
        pk_root.remove_child(result_modal)
        result_modal.queue_free()
    result_modal = Control.new()
    result_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    result_modal.z_index = 30
    pk_root.add_child(result_modal)
    var shade := ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.02,0.05,0.09,0.88)
    result_modal.add_child(shade)
    DragonUI.panel(result_modal,Rect2(310,130,660,470),Color("102b39"),GOLD_BRIGHT)
    DragonUI.text(result_modal,"VƯỢT QUA CHƯƠNG %d" % battle.stage.number if won else "ĐỘI RỒNG ĐÃ BỊ HẠ",Rect2(345,160,590,50),30,GOLD_BRIGHT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    DragonUI.text(result_modal,battle.stage.name,Rect2(345,215,590,36),22,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var stars := battle.stars() if won else 0
    DragonUI.text(result_modal,"★".repeat(stars)+"☆".repeat(3-stars),Rect2(345,254,590,45),30,GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    DragonUI.text(result_modal,"%d vòng · Còn %d / %d rồng" % [battle.round_number,allies_alive,party.size()],Rect2(345,308,590,30),18,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var rewards_label := DragonUI.text(result_modal,"Không có phần thưởng khi thất bại.",Rect2(345,352,590,80),18,GOLD,true)
    rewards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    if won:
        var first := not PlayerProfile.stage_stars.has(battle.stage.id)
        var amounts: Dictionary = battle.stage.rewards.duplicate()
        for key in amounts:
            amounts[key] = int(amounts[key])+int(battle.stage.first_bonus.get(key,0) if first else 0)
        rewards_label.text = "%d vàng · %d thức ăn · %d mảnh tinh thể%s" % [amounts.gold,amounts.food,amounts.shards,"\nGồm thưởng vượt chương lần đầu" if first else ""]
    var receive := DragonUI.button(result_modal,"Nhận thưởng",Rect2(495,442,290,55),true)
    receive.visible = won
    var chapters := DragonUI.button(result_modal,"Danh sách chương",Rect2(345,521,280,50))
    var retry := DragonUI.button(result_modal,"Chọn lại đội",Rect2(655,521,280,50))
    chapters.disabled = won and not battle.rewards_claimed
    retry.disabled = chapters.disabled
    chapters.pressed.connect(_return_to_chapters)
    retry.pressed.connect(_retry_chapter)
    receive.pressed.connect(func():
        var error := battle.claim_rewards()
        if not error.is_empty():
            rewards_label.text = error
            return
        receive.text = "Đã nhận thưởng"
        receive.disabled = true
        chapters.disabled = false
        retry.disabled = false
        rewards_label.text = "Đã nhận %d vàng · %d thức ăn · %d mảnh tinh thể\nTiến trình đã được lưu" % [battle.rewards.gold,battle.rewards.food,battle.rewards.shards]
    )

func _return_to_chapters() -> void:
    _clear_match_ui()
    _show_chapters()

func _retry_chapter() -> void:
    _clear_match_ui()
    _show_team_picker()

func _clear_match_ui() -> void:
    mode = "chapters"
    match_finished = false
    action_in_progress = false
    pk_root.visible = false
    if is_instance_valid(result_modal):
        pk_root.remove_child(result_modal)
        result_modal.queue_free()
    result_modal = null


func _reset_pk_match() -> void:
    get_tree().reload_current_scene()

func _play_sfx(sound_name: String) -> void:
    if is_inside_tree():
        var am := get_node_or_null("/root/AudioManager")
        if am != null and am.has_method("play"):
            am.call("play", sound_name)

func _ornate_style(bg: Color, border: Color, radius: int = 14, border_w: int = 2) -> StyleBoxFlat:
    var st := StyleBoxFlat.new()
    st.bg_color = bg
    st.border_color = border
    st.set_border_width_all(border_w)
    st.set_corner_radius_all(radius)
    return st

func _styled_label(txt: String, font_sz: int, col: Color) -> Label:
    var lbl := Label.new()
    lbl.text = txt
    lbl.add_theme_font_size_override("font_size", font_sz)
    lbl.add_theme_color_override("font_color", col)
    lbl.add_theme_color_override("font_outline_color", Color("06121a"))
    lbl.add_theme_constant_override("outline_size", 4)
    lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return lbl

## Các phương thức dưới đây được giữ lại để tương thích với bài test tự động `tests/battle_integration.gd`
func _prepare(stage_id: String) -> void:
    selected_stage = stage_id
    mode = "prepare"

func _render_result() -> void:
    mode = "result"
    if pk_root != null:
        pk_root.visible = false
    var won := battle != null and battle.phase == "won"
    DragonUI.text(self, "CHIẾN THẮNG" if won else "ĐỘI RỒNG ĐÃ BỊ HẠ", Rect2(250, 143, 780, 66), 40, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _show_team_picker() -> void:
    mode = "prepare"
    if is_instance_valid(team_picker):
        remove_child(team_picker)
        team_picker.queue_free()
    picker_buttons.clear()
    team_picker = Control.new()
    team_picker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(team_picker)
    DragonUI.panel(team_picker,Rect2(0,0,1280,720))
    DragonUI.text(team_picker,"CHƯƠNG %d · CHỌN ĐỘI RỒNG" % BattleCatalog.chapter(selected_stage).number,Rect2(210,28,950,50),30,GOLD)
    var back := DragonUI.button(team_picker,"< Quay lại",Rect2(25,30,160,45))
    back.pressed.connect(_show_chapters)
    DragonUI.text(team_picker,"Chọn tối đa 3 cá thể đang sở hữu · Rồng nhiều hệ dùng được kỹ năng của từng hệ",Rect2(30,95,1200,40),18,MUTED)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(25,150)
    scroll.size = Vector2(860,530)
    team_picker.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 4
    grid.add_theme_constant_override("h_separation",12)
    grid.add_theme_constant_override("v_separation",12)
    scroll.add_child(grid)
    var page_count := maxi(1,ceili(float(PlayerCollection.owned_dragons.size()) / PICKER_PAGE_SIZE))
    picker_page = clampi(picker_page,0,page_count-1)
    var visible_pets := PlayerCollection.ordered_dragons().slice(picker_page*PICKER_PAGE_SIZE,(picker_page+1)*PICKER_PAGE_SIZE)
    for instance in visible_pets:
        var unit := BattleCatalog.dragon(instance)
        var card := Panel.new()
        card.custom_minimum_size = Vector2(196,232)
        card.add_theme_stylebox_override("panel",DragonUI.style(Color("203b49"),GOLD if party.has(instance) else Color("4c6975")))
        grid.add_child(card)
        DragonUI.portrait(card,unit.portrait,Rect2(15,2,166,130))
        DragonUI.text(card,("★ " if instance.favorite else "")+unit.display_name,Rect2(10,134,180,28),13)
        DragonUI.text(card,"Cấp %d · %d kỹ năng hệ" % [instance.level,unit.skills.size()],Rect2(10,164,180,24),12,MUTED)
        var button := DragonUI.button(card,"Bỏ chọn" if party.has(instance) else "Chọn rồng",Rect2(10,193,176,32),party.has(instance))
        button.pressed.connect(_toggle_party.bind(instance))
        picker_buttons[instance.instance_id] = button
    if PlayerCollection.owned_dragons.is_empty():
        DragonUI.text(team_picker,"Bạn chưa có rồng. Hãy Triệu hồi trước khi vào PK.",Rect2(40,180,800,60),23,GOLD)
    var previous := DragonUI.button(team_picker,"< Trước",Rect2(25,680,130,32))
    previous.disabled = picker_page == 0
    previous.pressed.connect(_change_picker_page.bind(-1))
    DragonUI.text(team_picker,"Trang %d / %d" % [picker_page+1,page_count],Rect2(175,683,200,28),15,MUTED)
    var next := DragonUI.button(team_picker,"Sau >",Rect2(355,680,130,32))
    next.disabled = picker_page+1 >= page_count
    next.pressed.connect(_change_picker_page.bind(1))
    picker_summary = Control.new()
    team_picker.add_child(picker_summary)
    _refresh_party_picker()

func _refresh_party_picker() -> void:
    for child in picker_summary.get_children():
        picker_summary.remove_child(child)
        child.queue_free()
    for instance in PlayerCollection.owned_dragons:
        if picker_buttons.has(instance.instance_id):
            var button: Button = picker_buttons[instance.instance_id]
            button.text = "Bỏ chọn" if party.has(instance) else "Chọn rồng"
            button.disabled = not party.has(instance) and party.size() >= 3
    DragonUI.panel(picker_summary,Rect2(910,150,340,530))
    DragonUI.text(picker_summary,"ĐỘI HÌNH %d / 3" % party.size(),Rect2(930,170,300,40),23,GOLD)
    for i in range(party.size()):
        var unit := BattleCatalog.dragon(party[i])
        DragonUI.portrait(picker_summary,unit.portrait,Rect2(925,220+i*100,85,85))
        DragonUI.text(picker_summary,unit.display_name+"\nCấp %d" % party[i].level,Rect2(1015,240+i*100,225,60),14)
    var start := DragonUI.button(picker_summary,"Vào đấu trường",Rect2(935,590,290,55),true)
    start.disabled = party.is_empty()
    start.pressed.connect(_start_owned_match)

func _toggle_party(instance: DragonInstance) -> void:
    if party.has(instance):
        party.erase(instance)
    elif party.size() < 3:
        party.append(instance)
    _refresh_party_picker()

func _start_owned_match() -> void:
    # Revalidate ownership immediately before constructing a battle snapshot.
    for instance in party:
        if not PlayerCollection.owned_dragons.has(instance):
            party.erase(instance)
            _show_team_picker()
            return
    if party.is_empty():
        return
    team_picker.queue_free()
    team_picker = null
    battle.players.clear()
    battle.enemies.clear()
    battle.queue.clear()
    battle.log_lines.clear()
    var chapter := BattleCatalog.chapter(selected_stage)
    if chapter.is_empty() or not BattleCatalog.chapter_unlocked(selected_stage):
        _show_chapters()
        return
    battle.stage = chapter.duplicate(true)
    battle.rewards_claimed = false
    battle.rewards.clear()
    battle.active = null
    battle.wave = 0
    battle.round_number = 0
    battle.phase = "battle"
    battle.rng.randomize()
    units.clear()
    roster.clear()
    for i in range(party.size()):
        var unit := BattleCatalog.dragon(party[i])
        battle.players.append(unit)
        units[unit.id] = unit
        _add_roster_entry(unit,DEFAULT_PK_ROSTER[i],party[i].species_id)
    var monsters: Array = chapter.monsters
    for i in range(monsters.size()):
        var unit := BattleCatalog.chapter_enemy(selected_stage,i)
        battle.enemies.append(unit)
        units[unit.id] = unit
        var entry: Dictionary = DEFAULT_PK_ROSTER[i+3].duplicate(true)
        entry.id = unit.id
        entry.name = unit.display_name
        entry.side = "enemy"
        entry.element = "earth" if monsters[i] != "fungus" else "poison"
        entry.texture_path = "res://assets/textures/enemies/%s.svg" % monsters[i]
        entry.max_hp = unit.max_hp
        entry.hp = unit.hp
        entry.attack = unit.attack
        entry.defense = unit.defense
        entry.speed = unit.speed
        entry.energy = 0
        entry.flip_h = false
        entry.placeholder_note = "Quái vật từ khe nứt lòng đất"
        roster.append(entry)
    battle._new_round()
    mode = "pk"
    match_seconds = 0
    turn_number = 1
    current_turn_index = 0
    selected_fighter_id = battle.players[0].id
    active_fighter_id = selected_fighter_id
    auto_battle = false
    step_cooldown = 0.3
    pk_root.visible = true
    _build_pk_screen()
    turn_order_ids.sort_custom(func(a:String,b:String): return units[a].speed > units[b].speed if units[a].speed != units[b].speed else a < b)
    _build_turn_order_bar()
    _sync_units()

func _add_roster_entry(unit: BattleUnitData,layout: Dictionary,species_id: String) -> void:
    var entry := layout.duplicate(true)
    entry.id = unit.id
    entry.name = unit.display_name
    entry.side = unit.side
    entry.element = unit.element
    entry.texture_path = "res://assets/textures/dragons/%s.png" % species_id
    entry.max_hp = unit.max_hp
    entry.hp = unit.hp
    entry.attack = unit.attack
    entry.defense = unit.defense
    entry.speed = unit.speed
    entry.energy = 0
    entry.placeholder_note = ""
    roster.append(entry)

func _skill_element(skill_id: String,fallback: String) -> String:
    for key in BattleCatalog.data().elements:
        if BattleCatalog.data().elements[key].skill == skill_id:
            return key
    return fallback

func _sync_units() -> void:
    for id in units:
        if not fighter_by_id.has(id):
            continue
        var unit: BattleUnitData = units[id]
        var slot: PkFighterSlot = fighter_by_id[id]
        slot.hp = unit.hp
        slot.is_active_turn = battle.active != null and battle.active.id == id
        slot.is_selected = selected_fighter_id == id
        slot.refresh_ui()
        var states: Array[String] = []
        for status_id in unit.statuses:
            states.append(BattleCatalog.data().statuses[status_id].name)
        var status_label := slot.get_node_or_null("CombatStatuses") as Label
        if status_label == null:
            status_label = Label.new()
            status_label.name = "CombatStatuses"
            status_label.position = Vector2(0,30)
            status_label.size = Vector2(250,40)
            status_label.add_theme_font_size_override("font_size",12)
            status_label.add_theme_color_override("font_color",GOLD_BRIGHT)
            status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
            slot.add_child(status_label)
        status_label.text = " · ".join(states)
        var descriptions: Array[String] = []
        for status_id in unit.statuses:
            descriptions.append(BattleCatalog.data().statuses[status_id].description)
        slot.tooltip_text = "\n".join(descriptions)

func _refresh_ability_buttons() -> void:
    if skills_holder == null or not units.has(selected_fighter_id):
        return
    for child in skills_holder.get_children():
        skills_holder.remove_child(child)
        child.queue_free()
    ability_buttons.clear()
    var unit: BattleUnitData = units[selected_fighter_id]
    var ids: Array[String] = ["basic"]
    ids.append_array(unit.skills)
    var can_act := battle.active == unit and unit.side == "player" and unit.alive() and not action_in_progress and not auto_battle
    for id in ids:
        var data: Dictionary = BattleCatalog.data().skills[id]
        var cooldown := int(unit.cooldowns.get(id,0))
        var title: String = data.name
        var button := PkSkillButton.new()
        button.setup("skill",title,0,Vector2(94,128))
        skills_holder.add_child(button)
        button.skill_activated.connect(_on_player_skill_pressed.bind(id).unbind(1))
        button.set_energy_state(0,can_act)
        button.trigger_btn.tooltip_text = data.get("description","")+"\n"+("Hồi: %d lượt riêng" % cooldown if cooldown > 0 else "Sẵn sàng")
        button.cost_label.text = "%d lượt" % cooldown if cooldown > 0 else "%d%%" % roundi(data.multiplier*100)
        button.cost_label.visible = true
        button.modulate = Color("ffe699") if chosen_skill == id else Color.WHITE
        button.title_label.add_theme_font_size_override("font_size",10)
        button.title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.title_label.size = Vector2(90,35)
        ability_buttons.append(button)
    btn_skip.disabled = not can_act or int(unit.cooldowns.get(chosen_skill,0)) > 0
    _sync_units()

func _preview_skill() -> void:
    if battle.active == null or not units.has(selected_fighter_id):
        return
    var actor: BattleUnitData = units[selected_fighter_id]
    if actor != battle.active or actor.side != "player":
        status_banner_label.text = "Chờ đến lượt rồng này để dùng kỹ năng."
        return
    var skill: Dictionary = BattleCatalog.data().skills[chosen_skill]
    var targets := battle.legal_targets(actor,chosen_skill)
    if not targets.is_empty() and not targets.any(func(u:BattleUnitData): return u.id == chosen_target):
        chosen_target = targets[0].id
    for slot in fighters:
        slot.is_targeted = slot.hp > 0 and slot.team_side == "enemy" and (skill.target == "all_enemies" or slot.fighter_id == chosen_target)
        slot.refresh_ui()
    var scope := "Tất cả đối thủ" if skill.target == "all_enemies" else "Một đối thủ đã chọn"
    status_banner_label.text = "%s · %s · %d%% tấn công · Chọn mục tiêu rồi XÁC NHẬN" % [skill.name,scope,roundi(skill.multiplier*100)]
    status_banner_label.tooltip_text = skill.get("description","")

func _confirm_skill() -> void:
    if auto_battle or action_in_progress or battle.active == null or battle.active.side != "player":
        return
    selected_fighter_id = battle.active.id
    var targets := battle.legal_targets(battle.active,chosen_skill)
    if targets.is_empty():
        return
    if not targets.any(func(u:BattleUnitData): return u.id == chosen_target):
        chosen_target = targets[0].id
    _perform_combat_action(fighter_by_id[battle.active.id],chosen_skill,chosen_target)

func _change_picker_page(direction: int) -> void:
    picker_page += direction
    _show_team_picker()

func _show_chapters() -> void:
    mode = "chapters"
    pk_root.visible = false
    if is_instance_valid(team_picker):
        remove_child(team_picker)
        team_picker.queue_free()
    team_picker = Control.new()
    team_picker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(team_picker)
    DragonUI.panel(team_picker,Rect2(0,0,1280,720),Color("0b202b"))
    var back := DragonUI.button(team_picker,"< Trang chủ",Rect2(25,27,165,45))
    back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn"))
    DragonUI.text(team_picker,"CHIẾN DỊCH KHE NỨT",Rect2(220,23,900,55),32,GOLD_BRIGHT)
    DragonUI.text(team_picker,"Vượt chương để mở vùng tiếp theo · Máu và tấn công của quái tăng dần",Rect2(30,90,1200,35),18,MUTED)
    var rows: Array = BattleCatalog.data().chapters
    for i in range(rows.size()):
        var row: Dictionary = rows[i]
        var x := 28+(i%3)*416
        var y := 145+(i/3)*268
        var open := BattleCatalog.chapter_unlocked(row.id)
        DragonUI.panel(team_picker,Rect2(x,y,392,248),Color("16333e") if open else Color("112631"),GOLD if open else Color("344956"))
        DragonUI.text(team_picker,"CHƯƠNG %d" % row.number,Rect2(x+18,y+12,260,30),16,GOLD if open else MUTED)
        DragonUI.portrait(team_picker,load("res://assets/textures/enemies/%s.svg" % row.monsters[0]),Rect2(x+280,y+10,90,80))
        DragonUI.text(team_picker,row.name,Rect2(x+18,y+48,270,55),20,Color.WHITE,true)
        DragonUI.text(team_picker,"Máu quái ×%.2f · Tấn công ×%.2f" % [row.hp_scale,row.attack_scale],Rect2(x+18,y+108,360,27),15,MUTED)
        DragonUI.text(team_picker,"Thưởng: %d vàng · %d thức ăn · %d mảnh" % [row.rewards.gold,row.rewards.food,row.rewards.shards],Rect2(x+18,y+140,360,25),13,GOLD)
        var bonus := DragonUI.text(team_picker,"Lần đầu: +%d vàng, +%d thức ăn, +%d mảnh" % [row.first_bonus.gold,row.first_bonus.food,row.first_bonus.shards] if not PlayerProfile.stage_stars.has(row.id) else "Đã vượt: %s" % "★".repeat(int(PlayerProfile.stage_stars[row.id])),Rect2(x+18,y+168,360,24),12,MUTED)
        bonus.clip_text = true
        var enter := DragonUI.button(team_picker,"Chọn đội" if open else "Vượt chương trước để mở",Rect2(x+18,y+202,356,35),open)
        enter.disabled = not open
        enter.pressed.connect(_choose_chapter.bind(row.id))

func _choose_chapter(id: String) -> void:
    if not BattleCatalog.chapter_unlocked(id):
        return
    selected_stage = id
    party.clear()
    _show_team_picker()
