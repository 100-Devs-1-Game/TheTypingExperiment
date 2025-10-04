extends Node3D
class_name Head


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

func _process(_delta):
	if ray_cast.is_colliding():
		if not interaction_label.visible and can_move_camera:
			interaction_label.visible = true
	else:
		if  interaction_label.visible:
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
