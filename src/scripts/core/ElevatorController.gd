class_name ElevatorController
extends Node3D

## Elevator interaction controller
## Handles player teleportation with fade transitions and door opening based on stage completion

signal elevator_used(elevator_name: String)
signal doors_opened()
signal doors_closed()

@export var elevator_name: String = "elevator_1"
@export var unlocks_after_stage: int = 1  # Which stage completion unlocks this elevator
@export var teleport_offset: Vector3 = Vector3.ZERO  # Optional offset from teleport marker
@export var doors_start_open: bool = false  # If true, doors start open on scene start

# References to elevator components
@onready var teleport_marker: Marker3D = $TeleportMarker
@onready var door_a: Node3D = null  # Will be found in _ready()
@onready var door_b: Node3D = null  # Will be found in _ready()

# Door state
var doors_are_open: bool = false
var is_unlocked: bool = false

# Door animation settings (matching KeypadController)
@export var door_animation_duration: float = 1.0  # Seconds to open/close

func _ready() -> void:
	# Add to group so main can find us
	add_to_group("elevator_station")

	# Find door nodes by searching for elevator_door in children
	_find_door_nodes()

	# Connect to DayManager signals
	if DayManager:
		DayManager.stage_completed.connect(_on_stage_completed)

	# Check if elevator should already be unlocked based on current progress
	_check_initial_unlock_state()

## Finds door nodes in the elevator hierarchy
func _find_door_nodes() -> void:
	# Search for nodes with "elevator_door" in their name
	var elevator_node = get_node_or_null("elevator_22/elevator_2")
	if not elevator_node:
		push_error("[ElevatorController] Could not find elevator_2 node")
		return

	for child in elevator_node.get_children():
		if "elevator_door" in child.name.to_lower():
			if not door_a:
				door_a = child
				print("[ElevatorController] Found door_a: %s" % door_a.name)
			elif not door_b:
				door_b = child
				print("[ElevatorController] Found door_b: %s" % door_b.name)

	if not door_a or not door_b:
		push_warning("[ElevatorController] Could not find both elevator doors")

## Check if elevator should be unlocked based on current game progress
func _check_initial_unlock_state() -> void:
	# If doors should start open, open them without unlocking the elevator
	if doors_start_open:
		is_unlocked = true  # Mark as unlocked so it can be used
		doors_are_open = false  # Reset flag so open_doors() will work
		open_doors()
		return

	if not DayManager:
		return

	# Unlock if we've completed the required stage
	# For elevator_1: unlocks after stage 1 (which means current_stage >= 2)
	var current_day = DayManager.current_day
	var current_stage = DayManager.current_stage

	# Calculate total stages completed
	var total_stages_completed = (current_day - 1) * DayManager.stages_per_day + (current_stage - 1)

	if total_stages_completed >= unlocks_after_stage:
		unlock_elevator()

## Called when any stage is completed
func _on_stage_completed(day: int, stage: int) -> void:
	# Calculate total stages completed
	var total_stages_completed = (day - 1) * DayManager.stages_per_day + stage

	# Check if this elevator should unlock
	if total_stages_completed >= unlocks_after_stage and not is_unlocked:
		unlock_elevator()

## Unlocks the elevator and opens doors
func unlock_elevator() -> void:
	if is_unlocked:
		return

	is_unlocked = true
	print("[ElevatorController] Elevator '%s' unlocked!" % elevator_name)

	# Open doors automatically when unlocked
	open_doors()

## Opens the elevator doors (matching KeypadController method)
func open_doors() -> void:
	if doors_are_open or not door_a or not door_b:
		return

	doors_are_open = true
	print("[ElevatorController] Opening elevator doors")

	# Animate doors to fixed positions (same as KeypadController)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(door_a, "position:x", 0.7, door_animation_duration)
	tween.parallel().tween_property(door_b, "position:x", -0.7, door_animation_duration)

	await tween.finished
	doors_opened.emit()

## Closes the elevator doors (optional, for future use)
func close_doors() -> void:
	if not doors_are_open or not door_a or not door_b:
		return

	doors_are_open = false
	print("[ElevatorController] Closing elevator doors")

	# Animate doors back to closed position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(door_a, "position:x", 0.0, door_animation_duration)
	tween.parallel().tween_property(door_b, "position:x", 0.0, door_animation_duration)

	await tween.finished
	doors_closed.emit()

## Returns the teleport destination for this elevator
func get_teleport_position() -> Vector3:
	if teleport_marker:
		return teleport_marker.global_position + teleport_offset
	return global_position + teleport_offset

## Returns the teleport rotation for this elevator
func get_teleport_rotation() -> Vector3:
	if teleport_marker:
		return teleport_marker.global_rotation
	return global_rotation

## Check if player can use this elevator
func can_use_elevator() -> bool:
	return is_unlocked and doors_are_open

## Use the elevator (called by main.gd)
func use_elevator() -> void:
	if not can_use_elevator():
		print("[ElevatorController] Elevator not yet unlocked or doors closed")
		return

	elevator_used.emit(elevator_name)
