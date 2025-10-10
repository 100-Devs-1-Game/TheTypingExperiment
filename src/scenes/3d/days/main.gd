extends Node3D

var showing_menu := false
var startup_triggered := false

@export var sub_viewport: SubViewport
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

# PC management
var pc_controllers: Array = []  # Array of PCController instances
var current_pc: PCController = null  # Currently active PC

# Keypad management
var keypad_controllers: Array = []  # Array of KeypadController instances
var current_keypad: KeypadController = null  # Currently active keypad

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Add to group so head can find us
	add_to_group("main_environment")

	# Setup modular systems
	_setup_modular_systems()
	_setup_keyboard_visualizer()
	_setup_keypad_visualizer()

	# Discover all PC instances
	_discover_pcs()

	# Discover all keypad instances
	_discover_keypads()


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
				# Forward typing input to current PC's monitor viewport
				if current_pc:
					var pc_viewport = current_pc.get_monitor_viewport()
					if pc_viewport:
						pc_viewport.push_input(event)
			PlayerStateManager.PlayerState.INTERACTING_WITH_KEYPAD:
				# Forward numeric input to current keypad's viewport
				if current_keypad:
					var keypad_viewport = current_keypad.get_node_or_null("KeypadSubViewport")
					if keypad_viewport:
						keypad_viewport.push_input(event)

# Called by the head script when player interacts with PC
func interact_with_pc():
	if not player_state_manager or not player_state_manager.can_interact():
		return

	# Find the nearest PC to interact with
	var nearest_pc = _get_nearest_pc()
	if not nearest_pc:
		push_error("[Main] No PC found to interact with")
		return

	current_pc = nearest_pc

	# Get seated position from PC's InteractionMarker
	var seated_transform = nearest_pc.get_seated_transform()

	# Sit at computer using dynamic position
	player_state_manager.sit_at_computer_dynamic(
		seated_transform.origin,
		seated_transform.basis.get_euler()
	)

	# Turn on the monitor and load content
	if not nearest_pc.is_monitor_on:
		nearest_pc.turn_on_monitor()

# Called by the head script when player interacts with keypad
func interact_with_keypad(keypad_node: Node3D = null):
	if not player_state_manager or not player_state_manager.can_interact():
		return

	# Find the keypad controller for this node
	if keypad_node:
		for keypad in keypad_controllers:
			if keypad == keypad_node or keypad.is_ancestor_of(keypad_node) or keypad_node.is_ancestor_of(keypad):
				current_keypad = keypad
				print("[Main] Interacting with Keypad for Stage %d" % keypad.unlocks_stage)

				# Set this keypad as active in the visualizer
				if keypad_visualizer:
					keypad_visualizer.set_active_keypad(keypad)
				break

	player_state_manager.use_keypad(keypad_node)

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

## Discovers all PC instances in the scene
func _discover_pcs() -> void:
	pc_controllers.clear()

	# Find all nodes in the "pc_station" group
	var pcs = get_tree().get_nodes_in_group("pc_station")

	for pc in pcs:
		if pc is PCController:
			pc_controllers.append(pc)
			print("[Main] Discovered PC for Day %d" % pc.day_number)

	print("[Main] Total PCs discovered: %d" % pc_controllers.size())

## Finds the nearest PC to the player
func _get_nearest_pc() -> PCController:
	if pc_controllers.is_empty():
		return null

	# For now, just find any PC that's close to the player
	# You could enhance this with distance checking
	var player_pos = player.global_position
	var nearest_pc: PCController = null
	var nearest_distance = INF

	for pc in pc_controllers:
		var distance = player_pos.distance_to(pc.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_pc = pc

	return nearest_pc

## Discovers all keypad instances in the scene
func _discover_keypads() -> void:
	keypad_controllers.clear()

	# Find all nodes in the "keypad_station" group
	var keypads = get_tree().get_nodes_in_group("keypad_station")

	for keypad in keypads:
		if keypad is KeypadController:
			keypad_controllers.append(keypad)
			print("[Main] Discovered Keypad for Stage %d" % keypad.unlocks_stage)

	print("[Main] Total Keypads discovered: %d" % keypad_controllers.size())

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

	# Connect to state changes to manage keypad visualizer
	player_state_manager.state_changed.connect(_on_player_state_changed)

	# Note: Chair configuration is now handled dynamically by PC instances via InteractionMarker
	# Each PC's InteractionMarker defines its own seated position

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

# Handle player state changes to manage keypad visualizer
func _on_player_state_changed(old_state: PlayerStateManager.PlayerState, new_state: PlayerStateManager.PlayerState) -> void:
	# Clear keypad visualizer when leaving keypad interaction state
	if old_state == PlayerStateManager.PlayerState.INTERACTING_WITH_KEYPAD and keypad_visualizer:
		keypad_visualizer.clear_active_keypad()
