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

## Day 3 style message effect (unicode corruption with glitch pulses)
func show_day3_style_message(message_overlay: Control, message: String) -> void:
	if not get_tree() or not message_overlay:
		return

	message_overlay.visible = true
	var corruption_tint = Color(1, 0.4, 0.1, 0)  # Deep orange corruption color
	message_overlay.modulate = corruption_tint

	# Glitch the message text randomly before showing
	var unicode_chars = ["ţ", "ř", "ą", "ë", "ł", "ń", "đ", "ş", "ž", "ć", "ų", "ň", "ď", "ľ"]
	var glitched_message = _apply_message_corruption(message, unicode_chars, 0.4)

	# Unstable fade-in with digital artifacts
	await _corrupted_fade_in(message_overlay, glitched_message, unicode_chars)

	# Hold message with subtle glitch pulses
	await _hold_with_glitch_pulses(message_overlay, glitched_message, unicode_chars, 5.0)

	# Chaotic fade out with text degradation
	await _chaotic_fade_out(message_overlay)
	message_overlay.visible = false

## Day 4 style message effect (block corruption with glitch pulses)
func show_day4_style_message(message_overlay: Control, message: String) -> void:
	if not get_tree() or not message_overlay:
		return

	message_overlay.visible = true
	var purple_tint = Color(0.8, 0.4, 0.8, 0)  # Purple corruption color
	message_overlay.modulate = purple_tint

	# Glitch the message text with block characters
	var block_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"]
	var glitched_message = _apply_message_corruption(message, block_chars, 0.4)

	# Unstable fade-in with digital artifacts
	await _corrupted_fade_in(message_overlay, glitched_message, block_chars)

	# Hold message with subtle glitch pulses
	await _hold_with_glitch_pulses(message_overlay, glitched_message, block_chars, 4.5)

	# Chaotic fade out with text degradation
	await _chaotic_fade_out(message_overlay)
	message_overlay.visible = false

## Day 5 style message effect (symbol corruption with maximum chaos)
func show_day5_style_message(message_overlay: Control, message: String) -> void:
	if not get_tree() or not message_overlay:
		return

	message_overlay.visible = true
	var red_tint = Color(1, 0.3, 0.2, 0)  # Red-orange critical color
	message_overlay.modulate = red_tint

	# Apply maximum message corruption
	var symbol_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐", "■", "□", "▪", "▫", "◆", "◇", "●", "○"]
	var corrupted_message = _apply_message_corruption(message, symbol_chars, 0.6)

	# Chaotic fade-in with severe digital artifacts
	await _corrupted_fade_in_intense(message_overlay, corrupted_message, symbol_chars)

	# Hold message with intense glitch pulses
	await _hold_with_glitch_pulses_intense(message_overlay, corrupted_message, symbol_chars, 5.0)

	# Violent fade out with maximum text degradation
	await _chaotic_fade_out_intense(message_overlay)
	message_overlay.visible = false

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

## INTERNAL HORROR EFFECT FUNCTIONS (Days 3-5)

## Apply corruption to message text
func _apply_message_corruption(message: String, corruption_chars: Array, corruption_chance: float) -> String:
	var corrupted = ""
	var words = message.split(" ")

	for word_idx in range(words.size()):
		var word = words[word_idx]
		var corrupted_word = ""

		# Corrupt 1-2 characters per word max, skip short words
		if word.length() > 3 and randf() < corruption_chance:
			@warning_ignore("integer_division")
			var chars_to_corrupt = min(2, word.length() / 3)
			var corruption_positions = []

			# Pick random positions to corrupt (avoid first/last for readability)
			for i in range(chars_to_corrupt):
				var pos = randi_range(1, word.length() - 2)
				if pos not in corruption_positions:
					corruption_positions.append(pos)

			# Apply corruption only to selected positions
			for i in range(word.length()):
				if i in corruption_positions:
					corrupted_word += corruption_chars[randi() % corruption_chars.size()]
				else:
					corrupted_word += word[i]
		else:
			corrupted_word = word

		corrupted += corrupted_word
		if word_idx < words.size() - 1:
			corrupted += " "

	return corrupted

## Corrupted fade-in effect (Days 3-4)
func _corrupted_fade_in(message_overlay: Control, glitched_message: String, corruption_chars: Array) -> void:
	var fade_steps = 12
	var base_duration = 1.8
	var step_duration = base_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = float(step) / float(fade_steps)

		# Digital artifact simulation - random alpha jumps
		if randf() < 0.3:
			alpha += randf_range(-0.2, 0.3)
			alpha = clamp(alpha, 0.0, 1.0)

		message_overlay.modulate.a = alpha

		# Occasionally flicker the text corruption
		if step % 3 == 0 and randf() < 0.4:
			var reglitched = _apply_message_corruption(glitched_message, corruption_chars, 0.4)
			message_overlay.text = reglitched
		else:
			message_overlay.text = glitched_message

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.05, 0.1)
			await get_tree().create_timer(actual_duration).timeout

## Intense corrupted fade-in effect (Day 5)
func _corrupted_fade_in_intense(message_overlay: Control, corrupted_message: String, corruption_chars: Array) -> void:
	var fade_steps = 15
	var base_duration = 2.0
	var step_duration = base_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = float(step) / float(fade_steps)

		# Severe digital artifact simulation
		if randf() < 0.4:
			alpha += randf_range(-0.3, 0.4)
			alpha = clamp(alpha, 0.0, 1.0)

		message_overlay.modulate.a = alpha

		# Constantly flicker the text corruption
		if step % 2 == 0 and randf() < 0.6:
			var reglitched = _apply_message_corruption(corrupted_message, corruption_chars, 0.6)
			message_overlay.text = reglitched
		else:
			message_overlay.text = corrupted_message

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.08, 0.15)
			await get_tree().create_timer(actual_duration).timeout

## Hold message with glitch pulses (Days 3-4)
func _hold_with_glitch_pulses(message_overlay: Control, _message: String, corruption_chars: Array, duration: float) -> void:
	var elapsed = 0.0
	var pulse_interval = 0.8
	var next_pulse = pulse_interval

	while elapsed < duration:
		if not get_tree() or not message_overlay:
			return

		var delta = 0.1
		elapsed += delta

		# Subtle corruption pulses
		if elapsed >= next_pulse:
			next_pulse += pulse_interval + randf_range(-0.3, 0.5)

			# Intensity flicker
			var original_alpha = message_overlay.modulate.a
			message_overlay.modulate.a = original_alpha * randf_range(0.7, 1.3)

			# Brief text distortion
			var current_text = message_overlay.text
			message_overlay.text = _apply_message_corruption(current_text, corruption_chars, 0.4)

			await get_tree().create_timer(0.1).timeout

			if message_overlay:
				message_overlay.modulate.a = original_alpha
				message_overlay.text = current_text

		await get_tree().create_timer(delta).timeout

## Hold message with intense glitch pulses (Day 5)
func _hold_with_glitch_pulses_intense(message_overlay: Control, _message: String, corruption_chars: Array, duration: float) -> void:
	var elapsed = 0.0
	var pulse_interval = 0.6
	var next_pulse = pulse_interval

	while elapsed < duration:
		if not get_tree() or not message_overlay:
			return

		var delta = 0.1
		elapsed += delta

		# Intense corruption pulses
		if elapsed >= next_pulse:
			next_pulse += pulse_interval + randf_range(-0.4, 0.6)

			# Extreme intensity flicker
			var original_alpha = message_overlay.modulate.a
			message_overlay.modulate.a = original_alpha * randf_range(0.5, 1.5)

			# Severe text distortion
			var current_text = message_overlay.text
			message_overlay.text = _apply_message_corruption(current_text, corruption_chars, 0.6)

			await get_tree().create_timer(0.15).timeout

			if message_overlay:
				message_overlay.modulate.a = original_alpha
				message_overlay.text = current_text

		await get_tree().create_timer(delta).timeout

## Chaotic fade-out effect (Days 3-4)
func _chaotic_fade_out(message_overlay: Control) -> void:
	var fade_steps = 8
	var fade_duration = 1.2
	var step_duration = fade_duration / fade_steps
	var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "■", "□", "▪", "▫"]

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = 1.0 - (float(step) / float(fade_steps))

		# Chaotic alpha degradation
		if step > 2:
			alpha += randf_range(-0.4, 0.2)
			alpha = clamp(alpha, 0.0, 1.0)

		message_overlay.modulate.a = alpha

		# Text degradation - more corruption as it fades
		if step > 3:
			var current_text = message_overlay.text
			var corruption_level = float(step) / float(fade_steps)
			var degraded_text = _degrade_text(current_text, corruption_level, glitch_chars)
			message_overlay.text = degraded_text

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.1, 0.15)
			await get_tree().create_timer(actual_duration).timeout

## Intense chaotic fade-out effect (Day 5)
func _chaotic_fade_out_intense(message_overlay: Control) -> void:
	var fade_steps = 10
	var fade_duration = 1.5
	var step_duration = fade_duration / fade_steps
	var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "■", "□", "▪", "▫", "◆", "◇", "●", "○", "▬", "▭"]

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = 1.0 - (float(step) / float(fade_steps))

		# Maximum chaotic alpha degradation
		if step > 1:
			alpha += randf_range(-0.5, 0.3)
			alpha = clamp(alpha, 0.0, 1.0)

		message_overlay.modulate.a = alpha

		# Severe text degradation from start
		if step > 2:
			var current_text = message_overlay.text
			var corruption_level = float(step) / float(fade_steps)
			var degraded_text = _degrade_text_intense(current_text, corruption_level, glitch_chars)
			message_overlay.text = degraded_text

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.15, 0.2)
			await get_tree().create_timer(actual_duration).timeout

## Degrade text with glitch characters (Days 3-4)
func _degrade_text(text: String, corruption_level: float, glitch_chars: Array) -> String:
	var degraded = ""

	for i in range(text.length()):
		var single_char = text[i]
		# Increase corruption chance based on degradation level
		if single_char != " " and randf() < (corruption_level * 0.6):
			if randf() < 0.3:
				degraded += glitch_chars[randi() % glitch_chars.size()]
			else:
				degraded += ""  # Character deletion
		else:
			degraded += single_char

	return degraded

## Degrade text with intense glitch (Day 5)
func _degrade_text_intense(text: String, corruption_level: float, glitch_chars: Array) -> String:
	var degraded = ""

	for i in range(text.length()):
		var single_char = text[i]
		# Maximum corruption chance based on degradation level
		if single_char != " " and randf() < (corruption_level * 0.8):
			if randf() < 0.4:
				degraded += glitch_chars[randi() % glitch_chars.size()]
			else:
				degraded += ""  # Character deletion
		else:
			degraded += single_char

	return degraded
