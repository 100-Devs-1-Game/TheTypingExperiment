extends Node3D
# Note: class_name removed to avoid global script class conflicts
# This script is referenced by scene node path instead


@export_node_path("Camera3D") var cam_path := NodePath("Camera")
@onready var cam: Camera3D = get_node(cam_path)

@export var mouse_sensitivity := 2.0
@export var y_limit := 90.0
var mouse_axis := Vector2()
var rot := Vector3()
var is_active := true

@export var ray_cast: RayCast3D
@export var interaction_label: Label
var can_move_camera = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_sensitivity = mouse_sensitivity / 1000
	y_limit = deg_to_rad(y_limit)


# Called when there is an input event
func _input(event: InputEvent) -> void:
	if not is_active:
		return
		
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_axis = event.relative
		camera_rotation()
	
	
	if event.is_action_pressed("interact") and ray_cast.is_colliding():
		var object = ray_cast.get_collider()
		# Check if we're looking at the PC
		if object and object.name == "PCInteraction":
			# Find the main script and trigger PC interaction
			var main_script = get_tree().get_first_node_in_group("main_environment")
			if main_script and main_script.has_method("interact_with_pc"):
				main_script.interact_with_pc()
				get_viewport().set_input_as_handled()
		# Check if we're looking at the Keypad
		elif object and object.name == "KeypadInteraction":
			# Find the main script and trigger keypad interaction
			var main_script = get_tree().get_first_node_in_group("main_environment")
			if main_script and main_script.has_method("interact_with_keypad"):
				# Pass the parent keypad node (the collider's parent)
				var keypad_node = object.get_parent()
				main_script.interact_with_keypad(keypad_node)
				get_viewport().set_input_as_handled()
		# Check if we're looking at an Elevator
		elif object and object.name == "ElevatorInteraction":
			# Find the main script and trigger elevator interaction
			var main_script = get_tree().get_first_node_in_group("main_environment")
			if main_script and main_script.has_method("interact_with_elevator"):
				# Pass the parent elevator node (the collider's parent)
				var elevator_node = object.get_parent()
				main_script.interact_with_elevator(elevator_node)
				get_viewport().set_input_as_handled()

func _process(_delta):
	# Only show interaction prompts when we can move the camera (not seated/using keypad)
	if can_move_camera:
		if ray_cast.is_colliding():
			var object = ray_cast.get_collider()
			if object and object.name == "PCInteraction":
				interaction_label.text = "E: Use Computer"
				if not interaction_label.visible:
					interaction_label.visible = true
			elif object and object.name == "KeypadInteraction":
				interaction_label.text = "E: Use Keypad"
				if not interaction_label.visible:
					interaction_label.visible = true
			elif object and object.name == "ElevatorInteraction":
				interaction_label.text = "E: Use Elevator"
				if not interaction_label.visible:
					interaction_label.visible = true
			else:
				# Not an interactable object, hide label
				if interaction_label.visible:
					interaction_label.visible = false
		else:
			if interaction_label.visible:
				interaction_label.visible = false
	else:
		# Hide interaction label when camera movement is disabled (seated/interacting)
		if interaction_label.visible:
			interaction_label.visible = false
			
# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	var joystick_axis := Input.get_vector(&"look_left", &"look_right",
			&"look_down", &"look_up")
	
	if joystick_axis != Vector2.ZERO:
		mouse_axis = joystick_axis * 1000.0 * delta
		camera_rotation()


func camera_rotation() -> void:
	# Horizontal mouse look.
	rot.y -= mouse_axis.x * mouse_sensitivity
	# Vertical mouse look.
	rot.x = clamp(rot.x - mouse_axis.y * mouse_sensitivity, -y_limit, y_limit)
	
	get_owner().rotation.y = rot.y
	rotation.x = rot.x
