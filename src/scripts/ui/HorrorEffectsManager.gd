class_name HorrorEffectsManager
extends Node

## Standardized horror effects system for consistent eerie animations
## Built on top of FadeTransitionManager for reusable horror patterns

signal horror_effect_started(effect_name: String)
signal horror_effect_completed(effect_name: String)

enum HorrorIntensity {
	SUBTLE,    # Slight eerie effects
	MODERATE,  # Clear horror elements
	INTENSE    # Full glitch/corruption effects
}

# Core systems
var fade_manager: FadeTransitionManager

# Standardized horror timing (consistent across game)
var standard_horror_fade_in_steps: int = 8
var standard_horror_fade_in_duration: float = 1.2
var standard_horror_fade_out_steps: int = 6
var standard_horror_fade_out_duration: float = 1.0

# Horror color palette
var horror_colors: Dictionary = {
	"red_tint": Color(1, 0.8, 0.8),
	"corruption_red": Color(1, 0, 0),
	"dark_red": Color(0.5, 0, 0),
	"glitch_white": Color(1, 1, 1, 0.8)
}

func _ready() -> void:
	_setup_fade_manager()

## Setup internal fade manager
func _setup_fade_manager() -> void:
	fade_manager = FadeTransitionManager.new()
	fade_manager.name = "InternalFadeManager"

	# Configure with standardized horror settings
	fade_manager.eerie_fade_in_steps = standard_horror_fade_in_steps
	fade_manager.eerie_fade_in_duration = standard_horror_fade_in_duration
	fade_manager.eerie_fade_out_steps = standard_horror_fade_out_steps
	fade_manager.eerie_fade_out_duration = standard_horror_fade_out_duration

	add_child(fade_manager)

## Apply eerie message fade to any Control node (Day 2 style)
func apply_eerie_message_fade(target_node: Control, message_text: String = "",
							  display_duration: float = 4.0,
							  tint_color: Color = Color(1, 0.8, 0.8)) -> void:

	if not target_node:
		return

	var effect_name = "eerie_message_fade"
	horror_effect_started.emit(effect_name)

	# Set message text if provided
	if message_text != "" and target_node.has_method("set_text"):
		target_node.text = message_text

	# Make visible and set tint
	target_node.visible = true
	target_node.modulate = Color(tint_color.r, tint_color.g, tint_color.b, 0)

	# Eerie choppy fade in
	await _choppy_fade_control(target_node, 0.0, 1.0,
							   standard_horror_fade_in_steps,
							   standard_horror_fade_in_duration)

	# Display duration
	await get_tree().create_timer(display_duration).timeout

	# Eerie choppy fade out
	await _choppy_fade_control(target_node, 1.0, 0.0,
							   standard_horror_fade_out_steps,
							   standard_horror_fade_out_duration)

	target_node.visible = false
	horror_effect_completed.emit(effect_name)

## Apply eerie fade out to any Control node (ESC prompt style)
func apply_eerie_fade_out(target_node: Control, fade_duration: float = 1.0) -> void:
	if not target_node:
		return

	var effect_name = "eerie_fade_out"
	horror_effect_started.emit(effect_name)

	# Use standardized choppy fade out
	await _choppy_fade_control(target_node, 1.0, 0.0,
							   standard_horror_fade_out_steps,
							   fade_duration)

	target_node.visible = false
	horror_effect_completed.emit(effect_name)

## Apply screen-wide horror transition
func apply_horror_screen_transition(callback: Callable,
								   intensity: HorrorIntensity = HorrorIntensity.MODERATE,
								   fade_color: Color = Color.BLACK) -> void:

	var effect_name = "horror_screen_transition"
	horror_effect_started.emit(effect_name)

	match intensity:
		HorrorIntensity.SUBTLE:
			# Slightly choppy transition
			fade_manager.eerie_fade_in_steps = 10
			fade_manager.eerie_fade_out_steps = 8
		HorrorIntensity.MODERATE:
			# Standard horror timing
			fade_manager.eerie_fade_in_steps = standard_horror_fade_in_steps
			fade_manager.eerie_fade_out_steps = standard_horror_fade_out_steps
		HorrorIntensity.INTENSE:
			# Very choppy, glitchy
			fade_manager.eerie_fade_in_steps = 4
			fade_manager.eerie_fade_out_steps = 3

	await fade_manager.transition(callback, FadeTransitionManager.FadeType.EERIE_IN, fade_color)

	# Reset to standard settings
	fade_manager.eerie_fade_in_steps = standard_horror_fade_in_steps
	fade_manager.eerie_fade_out_steps = standard_horror_fade_out_steps

	horror_effect_completed.emit(effect_name)

## Apply glitch effect to text (rapid color/alpha changes)
func apply_text_glitch_effect(target_node: Control, glitch_duration: float = 2.0,
							  glitch_intensity: float = 0.5) -> void:

	if not target_node:
		return

	var effect_name = "text_glitch"
	horror_effect_started.emit(effect_name)

	var original_modulate = target_node.modulate
	var glitch_timer = 0.0
	var glitch_interval = 0.1  # How often to glitch

	while glitch_timer < glitch_duration:
		if not get_tree() or not target_node:
			break

		# Random glitch effects
		if randf() < glitch_intensity:
			# Flicker alpha
			target_node.modulate.a = randf_range(0.3, 1.0)

			# Random color tint
			if randf() < 0.3:
				target_node.modulate = horror_colors.corruption_red
			elif randf() < 0.2:
				target_node.modulate = horror_colors.glitch_white
		else:
			# Return to normal occasionally
			target_node.modulate = original_modulate

		await get_tree().create_timer(glitch_interval).timeout
		glitch_timer += glitch_interval

	# Restore original state
	target_node.modulate = original_modulate
	horror_effect_completed.emit(effect_name)

## Internal choppy fade function for Control nodes
func _choppy_fade_control(control: Control, start_alpha: float, end_alpha: float,
						  steps: int, duration: float) -> void:

	var step_duration = duration / steps

	for step in range(steps + 1):
		if not get_tree() or not control:
			return

		var alpha = start_alpha + (end_alpha - start_alpha) * (float(step) / float(steps))
		control.modulate.a = alpha

		if step < steps:  # Don't wait after the last step
			await get_tree().create_timer(step_duration).timeout

## Utility functions for common horror patterns

## Day 2 style message effect
func show_day2_style_message(message_overlay: Control, message: String) -> void:
	await apply_eerie_message_fade(message_overlay, message, 4.0, horror_colors.red_tint)

## ESC prompt style fade
func fade_out_esc_prompt(prompt_label: Control) -> void:
	await apply_eerie_fade_out(prompt_label, standard_horror_fade_out_duration)

## PC sitting horror transition
func horror_sitting_transition(callback: Callable) -> void:
	await apply_horror_screen_transition(callback, HorrorIntensity.MODERATE, Color.BLACK)

## Get horror color by name
func get_horror_color(color_name: String) -> Color:
	return horror_colors.get(color_name, Color.WHITE)

## Apply horror tint to any node
func apply_horror_tint(target_node: Control, tint_name: String = "red_tint") -> void:
	if target_node and horror_colors.has(tint_name):
		target_node.modulate = horror_colors[tint_name]

## Remove horror tint (restore to white)
func remove_horror_tint(target_node: Control) -> void:
	if target_node:
		target_node.modulate = Color.WHITE

## Check if any horror effects are currently active
func has_active_effects() -> bool:
	return fade_manager.has_active_fades() if fade_manager else false