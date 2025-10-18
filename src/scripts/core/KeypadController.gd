class_name KeypadController
extends Node3D

## Keypad Controller - Manages keypad-door interactions
## Validates codes with DoorManager and triggers door animations

signal code_validated(is_correct: bool)
signal door_opened()
signal escape_ending_triggered()  ## Emitted when secret code 1994 is entered on Keypad_3

enum DoorType {
	ROTATING,   ## Door rotates on Y axis
	ELEVATOR    ## Elevator doors slide on X axis
}

@export var unlocks_stage: int = 2  ## Which stage this keypad unlocks
@export var door_type: DoorType = DoorType.ROTATING  ## Type of door mechanism
@export var door_node_path: NodePath  ## Path to the door node (for ROTATING doors)
@export var door_a_node_path: NodePath  ## Path to first elevator door (for ELEVATOR type)
@export var door_b_node_path: NodePath  ## Path to second elevator door (for ELEVATOR type)
@export var target_rotation_y: float = 90.0  ## Target Y rotation in degrees (for ROTATING doors)
@export var door_animation_duration: float = 1.5  ## How long the door animation takes

@onready var keypad_input = $KeypadSubViewport/KeypadInput

var is_door_open: bool = false

func _ready() -> void:
	# Connect to keypad input signal
	if keypad_input and keypad_input.has_signal("code_entered"):
		keypad_input.code_entered.connect(_on_code_entered)
	else:
		push_error("[KeypadController] KeypadInput not found or missing code_entered signal")

## Called when player enters a code on the keypad
func _on_code_entered(entered_code: String) -> void:
	print("[KeypadController] Code entered: %s for Stage %d" % [entered_code, unlocks_stage])

	# Validate code with DoorManager
	var is_valid = DoorManager.validate_code(unlocks_stage, entered_code)
	code_validated.emit(is_valid)

	if is_valid:
		# Show success feedback
		if keypad_input and keypad_input.has_method("show_success"):
			keypad_input.show_success()

		# Check for secret escape ending (stage 999)
		if unlocks_stage == 999:
			escape_ending_triggered.emit()
			print("[KeypadController] Secret code entered - triggering escape ending")
		else:
			_open_door()
			DoorManager.unlock_stage(unlocks_stage)
	else:
		# Show error feedback and allow retry
		if keypad_input and keypad_input.has_method("show_error"):
			keypad_input.show_error()

		print("[KeypadController] Incorrect code - player can retry")

## Opens the door based on door type
func _open_door() -> void:
	if is_door_open:
		print("[KeypadController] Door already open")
		return

	is_door_open = true

	match door_type:
		DoorType.ROTATING:
			_open_rotating_door()
		DoorType.ELEVATOR:
			_open_elevator_doors()

	door_opened.emit()
	print("[KeypadController] Door opened for Stage %d" % unlocks_stage)

## Opens a rotating door by animating Y rotation
func _open_rotating_door() -> void:
	var door = get_node_or_null(door_node_path)
	if not door:
		push_error("[KeypadController] Door node not found at path: %s" % door_node_path)
		return

	var target_rotation = deg_to_rad(target_rotation_y)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(door, "rotation:y", target_rotation, door_animation_duration)

	print("[KeypadController] Rotating door to %d degrees" % target_rotation_y)

## Opens elevator doors by sliding them apart on X axis
func _open_elevator_doors() -> void:
	var door_a = get_node_or_null(door_a_node_path)
	var door_b = get_node_or_null(door_b_node_path)

	if not door_a or not door_b:
		push_error("[KeypadController] Elevator doors not found. A: %s, B: %s" % [door_a_node_path, door_b_node_path])
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(door_a, "position:x", 0.7, door_animation_duration)
	tween.parallel().tween_property(door_b, "position:x", -0.7, door_animation_duration)

	print("[KeypadController] Opening elevator doors")
