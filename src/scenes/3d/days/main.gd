extends Node3D

enum PlayerState { WALKING, SEATED_AT_PC }

var showing_menu := false
var player_state := PlayerState.WALKING
var startup_triggered := false

@export var sub_viewport: SubViewport
@onready var monitor_viewport: SubViewport = $SubViewportContainer/SubViewport/World/SubViewport
@onready var player: MovementController = $SubViewportContainer/SubViewport/World/Player
@onready var head: Head = $SubViewportContainer/SubViewport/World/Player/Head
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/World/Player/Head/Camera
@onready var interaction_label: Label = $SubViewportContainer/SubViewport/World/Player/Head/InteractionLabel

# Chair positioning for sitting
var chair_position := Vector3(-2.75, 1.6, 3.55)
var chair_rotation := Vector3(0, deg_to_rad(90), 0)  # Face monitor

# Camera adjustments for sitting
var seated_camera_offset := Vector3(0, -0.3, 0)  # Lower when sitting
var seated_head_tilt := Vector3(deg_to_rad(-5), 0, 0)  # Slight down angle

# Original state (saved once when first sitting)
var original_player_position: Vector3
var original_player_rotation: Vector3
var original_head_rotation: Vector3
var original_camera_position: Vector3
var original_head_rot: Vector3

# State tracking
var is_state_saved := false

# Keyboard visualization
var keyboard_visualizer: KeyboardVisualizer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Add to group so head can find us
	add_to_group("main_environment")

	# Setup keyboard visualizer
	_setup_keyboard_visualizer()


func _input(event: InputEvent) -> void:
	# Handle exit from PC
	if event.is_action_pressed("ui_cancel") and player_state == PlayerState.SEATED_AT_PC:
		stand_up_from_computer()
		return

	# Normal menu handling when walking
	if event.is_action_pressed("ui_cancel") and player_state == PlayerState.WALKING:
		show_menu(!showing_menu)
		return

	# Handle keyboard visualization when seated at PC
	if player_state == PlayerState.SEATED_AT_PC and keyboard_visualizer:
		keyboard_visualizer.handle_input_event(event)

	# Forward input based on state
	match player_state:
		PlayerState.WALKING:
			sub_viewport.push_input(event)
		PlayerState.SEATED_AT_PC:
			# Only forward typing input to monitor when seated
			monitor_viewport.push_input(event)

# Called by the head script when player interacts with PC
func interact_with_pc():
	if player_state == PlayerState.WALKING:
		sit_at_computer()

func show_menu(_show:bool):
	showing_menu = _show
	if not showing_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#%GameScreen.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#%GameScreen.show()

# Fade transition system
func fade_transition(callback: Callable):
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_viewport().add_child(fade)

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.2)
	tween.tween_callback(callback)
	tween.tween_property(fade, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): fade.queue_free())

# Save original state (only once per session)
func save_original_state():
	if not is_state_saved:
		original_player_position = player.global_position
		original_player_rotation = player.rotation
		original_head_rotation = head.rotation
		original_camera_position = camera.position
		original_head_rot = head.rot
		is_state_saved = true

# Restore original state exactly
func restore_original_state():
	player.global_position = original_player_position
	player.rotation = original_player_rotation
	head.rotation = original_head_rotation
	camera.position = original_camera_position
	head.rot = original_head_rot
	is_state_saved = false

# New sitting system with fade transitions
func sit_at_computer():
	# Save state only if not already saved
	save_original_state()

	# Use fade transition for smooth sitting
	fade_transition(func(): _execute_sit_at_computer())

func _execute_sit_at_computer():
	player_state = PlayerState.SEATED_AT_PC

	# Disable player movement and head look
	player.is_active = false
	head.can_move_camera = false

	# Teleport player to chair
	player.global_position = chair_position
	player.rotation = chair_rotation

	# Adjust camera for seated position
	camera.position = Vector3(0, 0, 0) + seated_camera_offset
	head.rotation = seated_head_tilt

	# Show ESC hint briefly when seated, then eerie fade out
	interaction_label.text = "ESC: Stand Up"
	interaction_label.visible = true
	interaction_label.modulate.a = 1.0  # Ensure it starts fully visible

	# Wait 3 seconds then do eerie fade out
	await get_tree().create_timer(3.0).timeout
	if player_state == PlayerState.SEATED_AT_PC:  # Only fade if still seated
		await _eerie_fade_out_esc()
		if player_state == PlayerState.SEATED_AT_PC:  # Check again after fade
			interaction_label.visible = false

	# Trigger startup screen if not already done
	if not startup_triggered:
		startup_triggered = true
		start_monitor_startup()

func stand_up_from_computer():
	# Use fade transition for smooth standing
	fade_transition(func(): _execute_stand_up_from_computer())

func _execute_stand_up_from_computer():
	player_state = PlayerState.WALKING

	# Restore all original states exactly
	restore_original_state()

	# Re-enable player movement and head look
	player.is_active = true
	head.can_move_camera = true

	# Hide the ESC prompt and reset alpha
	interaction_label.visible = false
	interaction_label.modulate.a = 1.0  # Reset for next time

# Eerie low-fps fade out effect for ESC message (same as Day 2)
func _eerie_fade_out_esc() -> void:
	var fade_steps = 6  # Choppy fade out
	var fade_duration = 1.0  # Fast fade out
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not interaction_label:
			return

		var alpha = 1.0 - (float(step) / float(fade_steps))
		interaction_label.modulate.a = alpha

		if step < fade_steps:  # Don't wait after the last step
			await get_tree().create_timer(step_duration).timeout

# Monitor startup control
func start_monitor_startup():
	# Connect to startup screen completion signal
	var startup_screen = monitor_viewport.get_node("StartupScreen")
	if startup_screen:
		startup_screen.startup_complete.connect(_on_startup_complete)

func _on_startup_complete():
	# Load Day 1 content in the monitor SubViewport instead of changing scenes
	var day_1_scene = preload("res://scenes/2d/days/day_1.tscn")
	var day_1_instance = day_1_scene.instantiate()

	# Remove startup screen and replace with Day 1
	var startup_screen = monitor_viewport.get_node("StartupScreen")
	if startup_screen:
		startup_screen.queue_free()

	monitor_viewport.add_child(day_1_instance)

	# Connect to day end screen signal
	if day_1_instance.has_signal("day_end_screen_requested"):
		day_1_instance.day_end_screen_requested.connect(_on_day_end_screen_requested)

func _on_day_end_screen_requested():
	# Load day end screen on monitor instead of changing entire scene
	var day_end_scene = preload("res://scenes/2d/days/day_end_screen.tscn")
	var day_end_instance = day_end_scene.instantiate()

	# Remove current day content and replace with day end screen
	for child in monitor_viewport.get_children():
		child.queue_free()

	monitor_viewport.add_child(day_end_instance)

# Setup keyboard visualization system
func _setup_keyboard_visualizer() -> void:
	keyboard_visualizer = KeyboardVisualizer.new()
	keyboard_visualizer.name = "KeyboardVisualizer"
	add_child(keyboard_visualizer)

	# Connect to keyboard events for debugging (optional)
	if keyboard_visualizer.has_signal("key_pressed"):
		keyboard_visualizer.key_pressed.connect(_on_keyboard_key_pressed)
	if keyboard_visualizer.has_signal("key_released"):
		keyboard_visualizer.key_released.connect(_on_keyboard_key_released)

# Optional: Handle keyboard events for debugging or additional effects
func _on_keyboard_key_pressed(key_name: String) -> void:
	pass  # Could add sound effects or other feedback here

func _on_keyboard_key_released(key_name: String) -> void:
	pass  # Could add sound effects or other feedback here
