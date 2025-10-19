extends CharacterBody3D
class_name MovementController

## Horror game movement controller
## Slow, deliberate movement with head bobbing

# Movement settings (tuned for horror atmosphere)
@export_group("Movement")
@export var speed := 2.5  # Slow, deliberate walking (renamed from walk_speed for compatibility)
@export var acceleration := 4.0  # Slower acceleration for weighty feel
@export var deceleration := 6.0  # Slightly faster stop
@export_range(0.0, 1.0, 0.05) var air_control := 0.3

@export_group("Physics")
@export var gravity_multiplier := 3.0

@export_group("Head Bob")
@export var bob_frequency := 2.0  # How fast the head bobs
@export var bob_amplitude := 0.02  # How much the head bobs
@export var bob_transition_speed := 5.0  # How quickly bob starts/stops

@export var head : Node3D  # Head controller

var direction := Vector3()
var input_axis := Vector2()
var is_active := true:
	set(val):
		is_active = val
		head.is_active = is_active
		set_physics_process(is_active)
	get:
		return is_active

# Head bob state
var bob_time := 0.0
var current_bob_intensity := 0.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity")
		* gravity_multiplier)


# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	input_axis = Input.get_vector(&"move_back", &"move_forward",
			&"move_left", &"move_right")

	direction_input()

	# Apply gravity (no jumping in horror games, but we need gravity for teleportation)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Slight downward force to keep grounded
		velocity.y = -0.5

	accelerate(delta)
	move_and_slide()

	# Update head bob
	_update_head_bob(delta)

func direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0

	var temp_accel: float
	var target: Vector3 = direction * speed

	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration

	if not is_on_floor():
		temp_accel *= air_control

	temp_vel = temp_vel.lerp(target, temp_accel * delta)

	velocity.x = temp_vel.x
	velocity.z = temp_vel.z

## Update head bob effect when walking
func _update_head_bob(delta: float) -> void:
	if not head:
		return

	# Check if player is moving on ground
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	var is_moving = horizontal_velocity.length() > 0.1 and is_on_floor()

	# Smoothly transition bob intensity
	var target_intensity = 1.0 if is_moving else 0.0
	current_bob_intensity = lerp(current_bob_intensity, target_intensity, bob_transition_speed * delta)

	# Update bob time when moving
	if is_moving:
		bob_time += delta * bob_frequency

	# Calculate head bob offset
	var bob_offset = Vector3.ZERO
	if current_bob_intensity > 0.01:
		# Vertical bob (up and down)
		bob_offset.y = sin(bob_time * 2.0) * bob_amplitude * current_bob_intensity
		# Horizontal sway (side to side, subtle)
		bob_offset.x = sin(bob_time) * (bob_amplitude * 0.5) * current_bob_intensity

	# Apply bob to head position (using local position)
	if head.has_method("apply_head_bob"):
		head.apply_head_bob(bob_offset)
	else:
		# Fallback: directly modify head position if method doesn't exist
		# Store original position if not stored yet
		if not has_meta("head_original_pos"):
			set_meta("head_original_pos", head.position)

		var original_pos = get_meta("head_original_pos")
		head.position = original_pos + bob_offset
