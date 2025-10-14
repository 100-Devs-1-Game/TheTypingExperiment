extends Control

## Both skulls visible, slowly closing in on player (scaling up)

@onready var skull_label: Label = %SkullLabel
@onready var skull_label_2: Label = %SkullLabel2

var horror_effects: HorrorEffectsManager
var skull_2_final_position: Vector2
var skull_1_finished_zoom: bool = false

func _ready() -> void:
	_setup_horror_effects()

	if skull_label:
		skull_label.visible = false
		skull_label.pivot_offset = skull_label.size / 2

	if skull_label_2:
		skull_label_2.visible = false
		skull_label_2.modulate = Color(1, 0, 0, 0)
		skull_label_2.pivot_offset = skull_label_2.size / 2

	_show_skull_eerily()

func _setup_horror_effects() -> void:
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "GameOverHorrorEffects"
	add_child(horror_effects)

func _show_skull_eerily() -> void:
	if not get_tree():
		return

	await get_tree().create_timer(0.5).timeout

	# Fade in first skull
	if skull_label:
		skull_label.visible = true
		await _fade_in_skull(skull_label, 0.0)

	# Start zoom on first skull and wait for it to finish
	if skull_label:
		await _slow_zoom(skull_label)

	# Mark that first skull finished zooming
	skull_1_finished_zoom = true

	# Now show second skull
	if skull_label_2 and skull_label:
		await _show_and_move_skull_2()

func _fade_in_skull(skull: Label, delay: float) -> void:
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	var fade_steps = 10
	var fade_duration = 2.0
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not skull:
			return

		var alpha = float(step) / float(fade_steps)
		skull.modulate.a = alpha

		if step < fade_steps:
			await get_tree().create_timer(step_duration).timeout

func _slow_zoom(skull: Label) -> void:
	var zoom_time = 0.0
	var start_scale = 1.0
	var zoom_duration = 40.0

	while zoom_time < zoom_duration:
		if not get_tree() or not skull:
			return

		var delta = get_process_delta_time()
		zoom_time += delta

		# Very slow zoom from 1.0 to 1.3 over 40 seconds
		var zoom_progress = min(zoom_time / zoom_duration, 1.0)
		var eased_zoom = ease(zoom_progress, -1.5)  # Slow start
		var skull_scale = lerp(start_scale, 1.3, eased_zoom)

		skull.scale = Vector2(skull_scale, skull_scale)

		await get_tree().process_frame

	# Zoom finished - keep at final scale
	skull.scale = Vector2(1.3, 1.3)

func _show_and_move_skull_2() -> void:
	if not get_tree() or not skull_label_2 or not skull_label:
		return

	# Brief delay before second skull appears
	await get_tree().create_timer(1.0).timeout

	if not skull_label_2 or not skull_label:
		return

	# Store skull_2's final position
	skull_2_final_position = skull_label_2.position

	# Use skull_1's position directly - it's already at the correct visual position
	skull_label_2.position = skull_label.position

	# Set skull_2 to same scale as skull_1
	skull_label_2.scale = skull_label.scale
	skull_label_2.visible = true

	# Fade in the second skull
	await _choppy_fade_in_skull_2()

	# Slowly drift to final position
	await _drift_to_final_position()

func _choppy_fade_in_skull_2() -> void:
	var fade_steps = 6
	var fade_duration = 1.0
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not skull_label_2:
			return

		var alpha = float(step) / float(fade_steps)
		skull_label_2.modulate.a = alpha

		if step < fade_steps:
			await get_tree().create_timer(step_duration).timeout

func _drift_to_final_position() -> void:
	if not get_tree() or not skull_label_2:
		return

	var drift_duration = 30.0  # Extremely slow, almost imperceptible movement
	var start_position = skull_label_2.position
	var elapsed = 0.0

	while elapsed < drift_duration:
		if not get_tree() or not skull_label_2:
			return

		var delta = get_process_delta_time()
		elapsed += delta

		var progress = elapsed / drift_duration
		# Very gentle easing - starts almost imperceptibly slow
		var eased_progress = ease(progress, -2.0)  # Strong ease out for very subtle start

		skull_label_2.position = start_position.lerp(skull_2_final_position, eased_progress)

		await get_tree().process_frame
