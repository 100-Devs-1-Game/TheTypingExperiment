extends Node3D

var showing_menu := false
var startup_triggered := false

@export var sub_viewport: SubViewport
@onready var monitor_viewport: SubViewport = $SubViewportContainer/SubViewport/World/MonitorSubViewport
@onready var keypad_viewport: SubViewport = $SubViewportContainer/SubViewport/World/KeypadSubViewport
@onready var player: MovementController = $SubViewportContainer/SubViewport/World/Player
@onready var head: Node3D = $SubViewportContainer/SubViewport/World/Player/Head
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/World/Player/Head/Camera
@onready var interaction_label: Label = $SubViewportContainer/SubViewport/World/Player/Head/InteractionLabel
@onready var esc_prompt_label: Label = $UI/EscPromptLabel

# Modular systems
var fade_manager: FadeTransitionManager
var horror_effects: HorrorEffectsManager
var player_state_manager: PlayerStateManager
var keyboard_visualizer: KeyboardVisualizer
var keypad_visualizer: KeypadVisualizer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Add to group so head can find us
	add_to_group("main_environment")

	# Setup modular systems
	_setup_modular_systems()
	_setup_keyboard_visualizer()
	_setup_keypad_visualizer()


func _input(event: InputEvent) -> void:
	# Let player state manager handle state transitions first
	if player_state_manager and player_state_manager.handle_input_event(event):
		return  # Input was handled by state manager

	# Normal menu handling when walking
	if event.is_action_pressed("ui_cancel") and player_state_manager and player_state_manager.is_walking():
		show_menu(!showing_menu)
		return

	# Handle keyboard visualization when seated at PC
	if player_state_manager and player_state_manager.is_seated() and keyboard_visualizer:
		keyboard_visualizer.handle_input_event(event)

	# Handle keypad visualization when using keypad
	if player_state_manager and player_state_manager.is_using_keypad() and keypad_visualizer:
		keypad_visualizer.handle_input_event(event)

	# Forward input based on state
	if player_state_manager:
		match player_state_manager.get_current_state():
			PlayerStateManager.PlayerState.WALKING:
				sub_viewport.push_input(event)
			PlayerStateManager.PlayerState.SEATED_AT_PC:
				# Only forward typing input to monitor when seated
				monitor_viewport.push_input(event)
			PlayerStateManager.PlayerState.INTERACTING_WITH_KEYPAD:
				# Forward numeric input to keypad viewport
				keypad_viewport.push_input(event)

# Called by the head script when player interacts with PC
func interact_with_pc():
	if player_state_manager and player_state_manager.can_interact():
		player_state_manager.sit_at_computer()

		# Trigger startup screen if not already done
		if not startup_triggered:
			startup_triggered = true
			start_monitor_startup()

# Called by the head script when player interacts with keypad
func interact_with_keypad():
	if player_state_manager and player_state_manager.can_interact():
		player_state_manager.use_keypad()

func show_menu(_show:bool):
	showing_menu = _show
	if not showing_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#%GameScreen.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#%GameScreen.show()

# Legacy fade transition function (maintained for compatibility)
func fade_transition(callback: Callable):
	if fade_manager:
		await fade_manager.fade_to_black(callback)
	else:
		# Fallback if fade manager not available
		callback.call()

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

# Setup modular systems
func _setup_modular_systems() -> void:
	# Setup fade transition manager
	fade_manager = FadeTransitionManager.new()
	fade_manager.name = "FadeTransitionManager"
	add_child(fade_manager)

	# Setup horror effects manager
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "HorrorEffectsManager"
	add_child(horror_effects)

	# Setup player state manager
	player_state_manager = PlayerStateManager.new()
	player_state_manager.name = "PlayerStateManager"
	add_child(player_state_manager)

	# Initialize player state manager with references
	player_state_manager.initialize(player, head, camera, interaction_label, esc_prompt_label)
	player_state_manager.set_external_managers(fade_manager, horror_effects)

	# Configure chair settings
	player_state_manager.set_chair_configuration(
		Vector3(-2.75, 1.6, 3.55),     # chair_position
		Vector3(0, deg_to_rad(90), 0), # chair_rotation (face monitor)
		Vector3(0, -0.3, 0),           # seated_camera_offset
		Vector3(deg_to_rad(-5), 0, 0)  # seated_head_tilt
	)

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

# Setup keypad visualization system
func _setup_keypad_visualizer() -> void:
	keypad_visualizer = KeypadVisualizer.new()
	keypad_visualizer.name = "KeypadVisualizer"
	add_child(keypad_visualizer)

	# Connect to keypad events for debugging (optional)
	if keypad_visualizer.has_signal("key_pressed"):
		keypad_visualizer.key_pressed.connect(_on_keypad_key_pressed)
	if keypad_visualizer.has_signal("key_released"):
		keypad_visualizer.key_released.connect(_on_keypad_key_released)

# Optional: Handle keypad events for debugging or additional effects
func _on_keypad_key_pressed(key_name: String) -> void:
	pass  # Could add sound effects or other feedback here

func _on_keypad_key_released(key_name: String) -> void:
	pass  # Could add sound effects or other feedback here
