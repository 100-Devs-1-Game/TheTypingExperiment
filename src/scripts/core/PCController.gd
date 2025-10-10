class_name PCController
extends Node3D

## PC Controller - Manages individual PC instances
## Handles day content loading, monitor state, and seated positioning
##
## IMPORTANT: InteractionMarker defines the seated player position:
## - Position: Where the chair is located (player body position when seated)
## - Rotation: Camera facing direction (which way player looks when seated)

signal monitor_turned_on()
signal monitor_turned_off()
signal day_content_loaded(day_number: int)

@export var day_number: int = 1  ## Which day this PC loads (1-5)
@export var show_startup_on_first_use: bool = true  ## Show startup screen first time

@onready var interaction_marker: Marker3D = $InteractionMarker
@onready var monitor_viewport: SubViewport = $SubViewport

var is_monitor_on: bool = false
var startup_shown: bool = false

func _ready() -> void:
	# Add to group so main.gd can discover all PC instances
	add_to_group("pc_station")

	# Start with monitor off (black screen)
	_initialize_black_screen()

## Gets the transform for seating the player
## Returns the global transform of the InteractionMarker
func get_seated_transform() -> Transform3D:
	return interaction_marker.global_transform

## Gets the monitor viewport for input forwarding
func get_monitor_viewport() -> SubViewport:
	return monitor_viewport

## Turns on the monitor and loads appropriate content
func turn_on_monitor() -> void:
	if is_monitor_on:
		return

	is_monitor_on = true
	monitor_turned_on.emit()

	# Clear black screen
	for child in monitor_viewport.get_children():
		child.queue_free()

	# Show startup or day content
	if show_startup_on_first_use and not startup_shown:
		_load_startup_screen()
	else:
		_load_day_content()

## Turns off the monitor (back to black screen)
func turn_off_monitor() -> void:
	if not is_monitor_on:
		return

	is_monitor_on = false
	monitor_turned_off.emit()

	# Clear viewport and show black screen
	for child in monitor_viewport.get_children():
		child.queue_free()

	_initialize_black_screen()

## Initializes a black screen (monitor off state)
func _initialize_black_screen() -> void:
	var black_screen = ColorRect.new()
	black_screen.color = Color.BLACK
	black_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	monitor_viewport.add_child(black_screen)

## Loads the startup screen
func _load_startup_screen() -> void:
	var startup_scene = load("res://scenes/2d/startup/startup_screen.tscn")
	if not startup_scene:
		push_error("[PCController] Failed to load startup screen")
		_load_day_content()  # Fallback to day content
		return

	var startup_instance = startup_scene.instantiate()
	monitor_viewport.add_child(startup_instance)

	# Connect to startup completion signal
	if startup_instance.has_signal("startup_complete"):
		startup_instance.startup_complete.connect(_on_startup_complete)

	startup_shown = true

## Called when startup screen completes
func _on_startup_complete() -> void:
	# Remove startup screen
	for child in monitor_viewport.get_children():
		child.queue_free()

	# Load day content
	_load_day_content()

## Loads the day content based on day_number
func _load_day_content() -> void:
	var day_scene_path = "res://scenes/2d/days/day_%d.tscn" % day_number
	var day_scene = load(day_scene_path)

	if not day_scene:
		push_error("[PCController] Failed to load day scene: %s" % day_scene_path)
		return

	var day_instance = day_scene.instantiate()
	monitor_viewport.add_child(day_instance)

	# Connect to day end screen signal
	if day_instance.has_signal("day_end_screen_requested"):
		day_instance.day_end_screen_requested.connect(_on_day_end_screen_requested)

	day_content_loaded.emit(day_number)
	print("[PCController] Loaded Day %d content" % day_number)

## Called when day requests end screen
func _on_day_end_screen_requested() -> void:
	# Load day end screen
	var day_end_scene = load("res://scenes/2d/days/day_end_screen.tscn")
	if not day_end_scene:
		push_error("[PCController] Failed to load day end screen")
		return

	# Clear current content
	for child in monitor_viewport.get_children():
		child.queue_free()

	# Add day end screen
	var day_end_instance = day_end_scene.instantiate()
	monitor_viewport.add_child(day_end_instance)

	print("[PCController] Day %d end screen loaded" % day_number)
