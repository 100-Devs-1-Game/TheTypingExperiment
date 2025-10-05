extends Node3D

var showing_menu := false

@export var sub_viewport: SubViewport
@onready var monitor_viewport: SubViewport = $SubViewportContainer/SubViewport/World/SubViewport

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Connect to startup screen completion signal
	var startup_screen = monitor_viewport.get_node("StartupScreen")
	if startup_screen:
		startup_screen.startup_complete.connect(_on_startup_complete)

func _input(event: InputEvent) -> void:
	sub_viewport.push_input(event)
	# Also forward input to monitor viewport for Day 1 interaction
	monitor_viewport.push_input(event)
	if event.is_action_pressed("ui_cancel"):
		show_menu(!showing_menu)
		
func show_menu(_show:bool):
	showing_menu = _show
	if not showing_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#%GameScreen.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#%GameScreen.show()

func _on_startup_complete():
	# Load Day 1 content in the monitor SubViewport instead of changing scenes
	var day_1_scene = preload("res://scenes/2d/days/day_1.tscn")
	var day_1_instance = day_1_scene.instantiate()

	# Remove startup screen and replace with Day 1
	var startup_screen = monitor_viewport.get_node("StartupScreen")
	if startup_screen:
		startup_screen.queue_free()

	monitor_viewport.add_child(day_1_instance)
