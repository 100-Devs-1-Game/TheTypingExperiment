extends Control

## Game Over Variant 5: "Stalking Presence"
## Both skulls visible, slowly closing in on player (scaling up)

@onready var skull_label: Label = %SkullLabel
@onready var skull_label_2: Label = %SkullLabel2

var horror_effects: HorrorEffectsManager

func _ready() -> void:
	_setup_horror_effects()

	if skull_label:
		skull_label.visible = false
		skull_label.modulate = Color(1, 0, 0, 0)
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

	# Fade in both skulls
	if skull_label:
		skull_label.visible = true
		_fade_in_skull(skull_label, 0.0)

	if skull_label_2:
		await get_tree().create_timer(1.5).timeout
		skull_label_2.visible = true
		_fade_in_skull(skull_label_2, 1.5)

	# Start slow zoom on both
	if skull_label:
		_slow_zoom(skull_label)

	if skull_label_2:
		_slow_zoom(skull_label_2)

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

	while true:
		if not get_tree() or not skull:
			return

		var delta = get_process_delta_time()
		zoom_time += delta

		# Very slow zoom from 1.0 to 1.3 over 40 seconds
		var zoom_progress = min(zoom_time / 40.0, 1.0)
		var eased_zoom = ease(zoom_progress, -1.5)  # Slow start
		var scale = lerp(start_scale, 1.3, eased_zoom)

		skull.scale = Vector2(scale, scale)


		await get_tree().process_frame
