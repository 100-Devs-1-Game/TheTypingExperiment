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

# Chair position for sitting
var chair_position := Vector3(-2.6, 0, 3.5)
var chair_rotation := Vector3(0, 90, 0)  # Face the monitor
var standing_position := Vector3()
var standing_rotation := Vector3()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Add to group so head can find us
	add_to_group("main_environment")

	# Store initial player position for standing up later
	standing_position = player.global_position
	standing_rotation = player.rotation

func _input(event: InputEvent) -> void:
	# Handle exit from PC
	if event.is_action_pressed("ui_cancel") and player_state == PlayerState.SEATED_AT_PC:
		stand_up_from_pc()
		return

	# Normal menu handling when walking
	if event.is_action_pressed("ui_cancel") and player_state == PlayerState.WALKING:
		show_menu(!showing_menu)
		return

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
		sit_at_pc()
		
func show_menu(_show:bool):
	showing_menu = _show
	if not showing_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#%GameScreen.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#%GameScreen.show()

# Sitting mechanics
func sit_at_pc():
	player_state = PlayerState.SEATED_AT_PC

	# Disable player movement and head look
	player.is_active = false
	head.can_move_camera = false

	# Store current position for standing up
	standing_position = player.global_position
	standing_rotation = player.rotation

	# Teleport player to chair
	player.global_position = chair_position
	player.rotation_degrees = chair_rotation

	# Start smooth camera transition to monitor
	animate_camera_to_monitor()

	# Show ESC hint when seated
	interaction_label.text = "ESC: Stand Up"
	interaction_label.visible = true

	# Trigger startup screen if not already done
	if not startup_triggered:
		startup_triggered = true
		start_monitor_startup()

func stand_up_from_pc():
	player_state = PlayerState.WALKING

	# Teleport player back to standing position
	player.global_position = standing_position
	player.rotation = standing_rotation

	# Animate camera back to normal
	animate_camera_to_normal()

	# Re-enable player movement and head look
	player.is_active = true
	head.can_move_camera = true

	# Hide the ESC prompt
	interaction_label.visible = false

# Camera transitions
func animate_camera_to_monitor():
	var tween = create_tween()
	tween.set_parallel(true)

	# Move camera closer and angle toward monitor
	var target_position = camera.position + Vector3(0, 0.2, -0.5)
	var target_rotation = camera.rotation_degrees + Vector3(-10, 0, 0)

	tween.tween_property(camera, "position", target_position, 1.0)
	tween.tween_property(camera, "rotation_degrees", target_rotation, 1.0)

func animate_camera_to_normal():
	var tween = create_tween()
	tween.set_parallel(true)

	# Reset camera to original position/rotation
	tween.tween_property(camera, "position", Vector3(0, 0, 0), 1.0)
	tween.tween_property(camera, "rotation_degrees", Vector3(0, 0, 0), 1.0)

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
