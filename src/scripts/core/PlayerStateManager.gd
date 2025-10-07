class_name PlayerStateManager
extends Node

## Modular player state management system for interaction states
## Handles sitting, camera positioning, state saving/restoration with configurable settings

signal state_changed(old_state: PlayerState, new_state: PlayerState)
signal sitting_started()
signal sitting_completed()
signal standing_started()
signal standing_completed()

enum PlayerState { WALKING, SEATED_AT_PC, INTERACTING_WITH_KEYPAD, CUSTOM_INTERACTION }

# Core references (set during initialization)
var player: MovementController
var head: Node3D  # Head controller (changed from PlayerHead to avoid class name conflicts)
var camera: Camera3D
var interaction_label: Label

# Current state
var current_state: PlayerState = PlayerState.WALKING
var is_state_saved: bool = false

# Configurable sitting settings
@export var chair_position: Vector3 = Vector3(-2.75, 1.6, 3.55)
@export var chair_rotation: Vector3 = Vector3(0, deg_to_rad(90), 0)
@export var seated_camera_offset: Vector3 = Vector3(0, -0.3, 0)
@export var seated_head_tilt: Vector3 = Vector3(deg_to_rad(-5), 0, 0)

# Configurable keypad interaction settings
@export var keypad_camera_position: Vector3 = Vector3(0, 0, 0)  # Fixed camera position when using keypad
@export var keypad_head_rotation: Vector3 = Vector3(0, 0, 0)  # Fixed head rotation when using keypad

# ESC prompt settings
@export var show_esc_prompt: bool = true
@export var esc_prompt_text: String = "ESC: Stand Up"
@export var esc_prompt_delay: float = 3.0

# Original state storage
var original_player_position: Vector3
var original_player_rotation: Vector3
var original_head_rotation: Vector3
var original_camera_position: Vector3
var original_head_rot: Vector3

# External managers (optional)
var fade_manager: FadeTransitionManager
var horror_effects: HorrorEffectsManager

func _ready() -> void:
	# Allow configuration across scene transitions
	process_mode = Node.PROCESS_MODE_ALWAYS

## Initialize the player state manager with required references
func initialize(
	player_ref: MovementController,
	head_ref: Node3D,
	camera_ref: Camera3D,
	interaction_label_ref: Label = null
) -> void:

	player = player_ref
	head = head_ref
	camera = camera_ref
	interaction_label = interaction_label_ref

	# Don't save state immediately - wait until first interaction like original code

## Set external managers for enhanced effects
func set_external_managers(fade_mgr: FadeTransitionManager = null, horror_mgr: HorrorEffectsManager = null) -> void:
	fade_manager = fade_mgr
	horror_effects = horror_mgr

## Main function to transition to seated state
func sit_at_computer(use_fade_transition: bool = true) -> void:
	if current_state != PlayerState.WALKING:
		return

	sitting_started.emit()

	if use_fade_transition and fade_manager:
		await fade_manager.fade_to_black(_execute_sit_at_computer)
	else:
		_execute_sit_at_computer()

	sitting_completed.emit()

## Main function to transition back to walking state
func stand_up_from_computer(use_fade_transition: bool = true) -> void:
	if current_state != PlayerState.SEATED_AT_PC:
		return

	standing_started.emit()

	if use_fade_transition and fade_manager:
		await fade_manager.fade_to_black(_execute_stand_up_from_computer)
	else:
		_execute_stand_up_from_computer()

	standing_completed.emit()

## Execute the sitting transition
func _execute_sit_at_computer() -> void:
	# Save original state only if not already saved (like original implementation)
	_save_original_state()

	var old_state = current_state
	current_state = PlayerState.SEATED_AT_PC

	# Disable player movement and head look
	if player:
		player.is_active = false
	if head:
		head.can_move_camera = false

	# Teleport player to chair
	if player:
		player.global_position = chair_position
		player.rotation = chair_rotation

	# Adjust camera for seated position
	if camera:
		camera.position = Vector3(0, 0, 0) + seated_camera_offset
	if head:
		head.rotation = seated_head_tilt

	# Handle ESC prompt with horror effects if available
	if show_esc_prompt and interaction_label:
		_show_esc_prompt()

	state_changed.emit(old_state, current_state)

## Execute the standing transition
func _execute_stand_up_from_computer() -> void:
	var old_state = current_state
	current_state = PlayerState.WALKING

	# Restore all original states exactly (like original implementation)
	_restore_original_state()

	# Re-enable player movement and head look
	if player:
		player.is_active = true
	if head:
		head.can_move_camera = true

	# Hide ESC prompt
	if interaction_label:
		interaction_label.visible = false
		interaction_label.modulate.a = 1.0  # Reset for next time

	state_changed.emit(old_state, current_state)

## Show ESC prompt with optional horror effects
func _show_esc_prompt() -> void:
	if not interaction_label:
		return

	interaction_label.text = esc_prompt_text
	interaction_label.visible = true
	interaction_label.modulate.a = 1.0

	# Wait then apply eerie fade out if horror effects available
	if esc_prompt_delay > 0:
		await get_tree().create_timer(esc_prompt_delay).timeout

		# Only proceed if still seated
		if current_state == PlayerState.SEATED_AT_PC:
			if horror_effects:
				await horror_effects.fade_out_esc_prompt(interaction_label)
			else:
				# Fallback simple fade
				interaction_label.visible = false

## Save original state (only once per session)
func _save_original_state() -> void:
	if not is_state_saved and player and head and camera:
		original_player_position = player.global_position
		original_player_rotation = player.rotation
		original_head_rotation = head.rotation
		original_camera_position = camera.position
		original_head_rot = head.rot
		is_state_saved = true

## Restore original state exactly
func _restore_original_state() -> void:
	if not is_state_saved:
		return

	if player:
		player.global_position = original_player_position
		player.rotation = original_player_rotation
	if head:
		head.rotation = original_head_rotation
		head.rot = original_head_rot
	if camera:
		camera.position = original_camera_position

	# Reset state saved flag like original implementation
	is_state_saved = false

## Keypad interaction functions - freeze player in place with camera zoom
func use_keypad(use_fade_transition: bool = true) -> void:
	if current_state != PlayerState.WALKING:
		return

	# Save original state before any changes
	_save_original_state()

	var old_state = current_state
	current_state = PlayerState.INTERACTING_WITH_KEYPAD

	# Disable movement and camera control
	if player:
		player.is_active = false
	if head:
		head.can_move_camera = false

	# Transition camera to fixed keypad position with fade
	if use_fade_transition and fade_manager:
		await fade_manager.fade_to_black(_execute_keypad_camera_transition)
	else:
		_execute_keypad_camera_transition()

	# Show ESC prompt
	if show_esc_prompt and interaction_label:
		interaction_label.text = "ESC: Stop Using Keypad"
		interaction_label.visible = true
		interaction_label.modulate.a = 1.0

	state_changed.emit(old_state, current_state)

func stop_using_keypad(use_fade_transition: bool = true) -> void:
	if current_state != PlayerState.INTERACTING_WITH_KEYPAD:
		return

	var old_state = current_state
	current_state = PlayerState.WALKING

	# Restore camera to original position with fade
	if use_fade_transition and fade_manager:
		await fade_manager.fade_to_black(_execute_keypad_camera_restore)
	else:
		_execute_keypad_camera_restore()

	# Re-enable movement
	if player:
		player.is_active = true
	if head:
		head.can_move_camera = true

	# Hide interaction label
	if interaction_label:
		interaction_label.visible = false

	state_changed.emit(old_state, current_state)

## Execute camera transition to fixed keypad position
func _execute_keypad_camera_transition() -> void:
	if not camera or not head:
		return

	# Instantly snap to fixed keypad viewing position
	camera.position = keypad_camera_position
	head.rotation = keypad_head_rotation

	# Reset head.rot to match the new rotation (for proper camera control restoration)
	if head.has_method("set") and head.get("rot") != null:
		head.rot = keypad_head_rotation

## Execute camera restore from keypad
func _execute_keypad_camera_restore() -> void:
	if not camera or not head or not is_state_saved:
		return

	# Instantly restore to original position
	camera.position = original_camera_position
	head.rotation = original_head_rotation
	head.rot = original_head_rot

## Custom interaction state for extensibility
func set_custom_interaction_state(
	disable_movement: bool = true,
	custom_position: Vector3 = Vector3.ZERO,
	custom_rotation: Vector3 = Vector3.ZERO,
	custom_camera_offset: Vector3 = Vector3.ZERO
) -> void:

	var old_state = current_state
	current_state = PlayerState.CUSTOM_INTERACTION

	if disable_movement:
		if player:
			player.is_active = false
		if head:
			head.can_move_camera = false

	if custom_position != Vector3.ZERO and player:
		player.global_position = custom_position
	if custom_rotation != Vector3.ZERO and player:
		player.rotation = custom_rotation
	if custom_camera_offset != Vector3.ZERO and camera:
		camera.position = custom_camera_offset

	state_changed.emit(old_state, current_state)

## Return to walking from any state
func return_to_walking() -> void:
	if current_state == PlayerState.WALKING:
		return

	var old_state = current_state

	# Restore movement regardless of previous state
	_restore_original_state()

	if player:
		player.is_active = true
	if head:
		head.can_move_camera = true

	current_state = PlayerState.WALKING
	state_changed.emit(old_state, current_state)

## Configuration functions

func set_chair_configuration(position: Vector3, rotation: Vector3, camera_offset: Vector3, head_tilt: Vector3) -> void:
	chair_position = position
	chair_rotation = rotation
	seated_camera_offset = camera_offset
	seated_head_tilt = head_tilt

func set_esc_prompt_configuration(show: bool, text: String, delay: float) -> void:
	show_esc_prompt = show
	esc_prompt_text = text
	esc_prompt_delay = delay

## State query functions

func get_current_state() -> PlayerState:
	return current_state

func is_walking() -> bool:
	return current_state == PlayerState.WALKING

func is_seated() -> bool:
	return current_state == PlayerState.SEATED_AT_PC

func is_in_custom_interaction() -> bool:
	return current_state == PlayerState.CUSTOM_INTERACTION

func is_using_keypad() -> bool:
	return current_state == PlayerState.INTERACTING_WITH_KEYPAD

func can_interact() -> bool:
	return current_state == PlayerState.WALKING

## Handle input for state transitions (call from main input handler)
func handle_input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			PlayerState.SEATED_AT_PC:
				stand_up_from_computer()
				return true  # Input handled
			PlayerState.INTERACTING_WITH_KEYPAD:
				stop_using_keypad()
				return true  # Input handled
			PlayerState.CUSTOM_INTERACTION:
				return_to_walking()
				return true  # Input handled

	return false  # Input not handled