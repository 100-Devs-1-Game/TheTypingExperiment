class_name FadeTransitionManager
extends Node

## Generic fade transition system for reusable screen transitions
## Supports smooth fades, choppy horror effects, and custom timing

signal fade_started(transition_type: String)
signal fade_completed(transition_type: String)

enum FadeType {
	SMOOTH,        # Standard smooth fade
	EERIE_IN,      # Choppy horror fade in
	EERIE_OUT,     # Choppy horror fade out
	INSTANT        # No animation, immediate transition
}

# Default fade settings
@export var default_fade_duration: float = 0.2
@export var default_fade_color: Color = Color.BLACK

# Horror effect settings
@export var eerie_fade_in_steps: int = 8
@export var eerie_fade_in_duration: float = 1.2
@export var eerie_fade_out_steps: int = 6
@export var eerie_fade_out_duration: float = 1.0

# Internal state
var active_fades: Array[ColorRect] = []

func _ready() -> void:
	# Ensure this manager can work across scene transitions
	process_mode = Node.PROCESS_MODE_ALWAYS

## Main transition function - executes callback during peak fade
func transition(callback: Callable, fade_type: FadeType = FadeType.SMOOTH,
				fade_color: Color = Color.BLACK, custom_duration: float = -1.0) -> void:

	var duration = custom_duration if custom_duration > 0 else default_fade_duration
	var type_name = FadeType.keys()[fade_type]

	fade_started.emit(type_name)

	match fade_type:
		FadeType.SMOOTH:
			await _smooth_transition(callback, fade_color, duration)
		FadeType.EERIE_IN:
			await _eerie_transition_in(callback, fade_color)
		FadeType.EERIE_OUT:
			await _eerie_transition_out(callback, fade_color)
		FadeType.INSTANT:
			await _instant_transition(callback)

	fade_completed.emit(type_name)

## Smooth fade transition (original main.gd logic)
func _smooth_transition(callback: Callable, fade_color: Color, duration: float) -> void:
	var fade = _create_fade_overlay(fade_color)

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, duration)
	tween.tween_callback(callback)
	tween.tween_property(fade, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): _cleanup_fade_overlay(fade))

	await tween.finished

## Eerie choppy fade in effect
func _eerie_transition_in(callback: Callable, fade_color: Color) -> void:
	var fade = _create_fade_overlay(fade_color)

	# Choppy fade in
	await _choppy_fade(fade, 0.0, 1.0, eerie_fade_in_steps, eerie_fade_in_duration)

	# Execute callback at peak
	callback.call()

	# Choppy fade out
	await _choppy_fade(fade, 1.0, 0.0, eerie_fade_out_steps, eerie_fade_out_duration)

	_cleanup_fade_overlay(fade)

## Eerie choppy fade out effect (for elements already visible)
func _eerie_transition_out(callback: Callable, fade_color: Color) -> void:
	# Execute callback immediately (no fade in needed)
	callback.call()

	# Wait a frame for callback to complete
	await get_tree().process_frame

	var fade = _create_fade_overlay(fade_color)
	fade.modulate.a = 0.0  # Start invisible for fade out only

	# Choppy fade out only
	await _choppy_fade(fade, 0.0, 1.0, eerie_fade_out_steps, eerie_fade_out_duration)

	_cleanup_fade_overlay(fade)

## Instant transition with no animation
func _instant_transition(callback: Callable) -> void:
	callback.call()
	await get_tree().process_frame

## Choppy fade animation with configurable steps and timing
func _choppy_fade(fade_overlay: ColorRect, start_alpha: float, end_alpha: float,
				  steps: int, duration: float) -> void:
	var step_duration = duration / steps

	for step in range(steps + 1):
		if not get_tree() or not fade_overlay:
			return

		var alpha = start_alpha + (end_alpha - start_alpha) * (float(step) / float(steps))
		fade_overlay.modulate.a = alpha

		if step < steps:  # Don't wait after the last step
			await get_tree().create_timer(step_duration).timeout

## Create a full-screen fade overlay
func _create_fade_overlay(fade_color: Color) -> ColorRect:
	var fade = ColorRect.new()
	fade.color = fade_color
	fade.modulate.a = 0.0
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input

	# Add to viewport to ensure it covers everything
	get_viewport().add_child(fade)
	active_fades.append(fade)

	return fade

## Clean up fade overlay
func _cleanup_fade_overlay(fade_overlay: ColorRect) -> void:
	if fade_overlay and is_instance_valid(fade_overlay):
		active_fades.erase(fade_overlay)
		fade_overlay.queue_free()

## Public utility functions for common fade operations

## Simple fade to black and back
func fade_to_black(callback: Callable, fade_type: FadeType = FadeType.SMOOTH) -> void:
	await transition(callback, fade_type, Color.BLACK)

## Fade with custom color
func fade_with_color(callback: Callable, color: Color, fade_type: FadeType = FadeType.SMOOTH) -> void:
	await transition(callback, fade_type, color)

## Eerie horror fade (uses choppy in/out)
func eerie_horror_fade(callback: Callable, fade_color: Color = Color.BLACK) -> void:
	await transition(callback, FadeType.EERIE_IN, fade_color)

## Clean up all active fades (useful for scene transitions)
func cleanup_all_fades() -> void:
	for fade in active_fades.duplicate():
		_cleanup_fade_overlay(fade)
	active_fades.clear()

## Get current number of active fade overlays
func get_active_fade_count() -> int:
	return active_fades.size()

## Check if any fades are currently active
func has_active_fades() -> bool:
	return active_fades.size() > 0