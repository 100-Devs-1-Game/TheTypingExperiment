extends Control

## Game Over Final Screen with eerie skull animation

@onready var skull_label: Label = %SkullLabel
@onready var skull_label_2: Label = %SkullLabel2

# Horror effects system
var horror_effects: HorrorEffectsManager

# Store original position of skull_label_2
var skull_2_final_position: Vector2

func _ready() -> void:
	# Setup horror effects manager
	_setup_horror_effects()

	# Hide skulls initially
	if skull_label:
		skull_label.visible = false

	if skull_label_2:
		skull_label_2.visible = false
		skull_label_2.modulate = Color(1, 0, 0, 0)  # Red tint, fully transparent

	# Start the eerie skull animation
	_show_skull_eerily()

func _setup_horror_effects() -> void:
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "GameOverHorrorEffects"
	add_child(horror_effects)

## Show the skull with Day 2 style eerie animation
func _show_skull_eerily() -> void:
	if not get_tree() or not skull_label:
		return

	# Wait a moment before showing skull
	await get_tree().create_timer(0.5).timeout

	if not skull_label:
		return

	skull_label.visible = true

	# Eerie choppy fade in (Day 2 style)
	await _choppy_fade_in()

	# Start the second skull animation in parallel with glitch pulses
	if skull_label_2:
		_show_and_move_skull_2()

	# Hold the skull with subtle glitch pulses
	await _hold_with_glitch_pulses(8.0)

## Show second skull and slowly move it to final position
func _show_and_move_skull_2() -> void:
	if not get_tree() or not skull_label_2 or not skull_label:
		return

	# Brief delay before second skull appears
	await get_tree().create_timer(1.0).timeout

	if not skull_label_2 or not skull_label:
		return

	# Store skull_2's final position and move it to skull_label's global position
	skull_2_final_position = skull_label_2.position
	skull_label_2.position = skull_label.global_position
	skull_label_2.visible = true

	# Fade in the second skull (faster than first)
	await _choppy_fade_in_skull_2()

	# Slowly drift to final position
	await _drift_to_final_position()

## Choppy fade in for second skull
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

## Slowly drift skull_2 to its final position - imperceptibly slow at first
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

## Choppy low-FPS fade in for horror effect
func _choppy_fade_in() -> void:
	var fade_steps = 8  # Low number = choppy, unsettling
	var fade_duration = 1.5
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not skull_label:
			return

		var alpha = float(step) / float(fade_steps)
		skull_label.modulate.a = alpha

		if step < fade_steps:
			await get_tree().create_timer(step_duration).timeout

## Hold skull with subtle glitch pulses for horror effect
func _hold_with_glitch_pulses(duration: float) -> void:
	var elapsed = 0.0
	var pulse_interval = 1.0
	var next_pulse = pulse_interval

	while elapsed < duration:
		if not get_tree() or not skull_label:
			return

		var delta = 0.1
		elapsed += delta

		# Subtle horror pulses
		if elapsed >= next_pulse:
			next_pulse += pulse_interval + randf_range(-0.3, 0.5)

			# Intensity flicker
			var original_alpha = skull_label.modulate.a
			skull_label.modulate.a = original_alpha * randf_range(0.8, 1.2)

			await get_tree().create_timer(0.1).timeout

			if skull_label:
				skull_label.modulate.a = original_alpha

		await get_tree().create_timer(delta).timeout
