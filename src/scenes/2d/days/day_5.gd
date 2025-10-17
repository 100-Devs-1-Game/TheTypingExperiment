extends BaseDay

## Day 5 - Final Day: System Collapse
## Symbol corruption with critical system failure
@onready var progress_bar_label: Label = %ProgressBarLabel

# Day-specific visual settings
var corruption_animation_time: float = 0.0
var corruption_animation_speed: float = 2.5  # Fastest, most chaotic
var corruption_intensity_base: float = 0.7   # Highest intensity

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 5
	corruption_color = "#ff4400"  # Red-orange for critical system failure
	super._ready()

func _process(delta: float) -> void:
	# Update corruption animation time
	corruption_animation_time += delta * corruption_animation_speed

	# Constantly update display for maximum chaos
	if is_session_active and int(corruption_animation_time * 10) % 2 == 0:
		_update_display()

func _setup_ui_theme() -> void:
	var red_tint = Color(1, 0.3, 0.2)  # Red-orange critical color
	var warning_red = Color(1, 0.2, 0.2)  # Bright red for critical warnings

	accuracy_label.modulate = warning_red  # System critical
	wmp_label.modulate = red_tint  # Maximum corruption
	day_stage_label.modulate = red_tint
	progress_label.modulate = warning_red
	message_overlay.modulate = red_tint
	progress_bar_label.modulate = red_tint

## Day 5 - Symbol corruption typewriter effect with system collapse
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.02  # Fastest, most erratic typing
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
		var is_corruption_char = _is_character_in_corruption_word(i, display_sentence)

		# Apply color formatting as we type
		if is_corruption_char:
			text_display.text += "[color=%s]%s[/color]" % [corruption_color, character]
		else:
			text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		# Extreme speed variation - system collapsing
		var speed_variation = randf() * 0.03  # 0-0.03 second variation
		await get_tree().create_timer(typing_speed + speed_variation).timeout

		# Dramatic pause for corruption words - system struggling to display
		if is_corruption_char and character == " ":
			await get_tree().create_timer(0.5).timeout

	# Longer pause before allowing typing - system on brink of failure
	await get_tree().create_timer(1.2).timeout

func _update_display() -> void:
	if not text_display:
		return

	# Day 5 specific display logic with maximum corruption effects
	var display_sentence = DayManager.get_stage_display_sentence()
	var display_text: String = ""

	for i in range(display_sentence.length()):
		var character: String = display_sentence[i]
		var color: String = untyped_color
		var final_character: String = character
		var is_cursor_position: bool = (i == current_position)

		if i < typed_characters.length():
			# Character has been typed
			var typed_char: String = typed_characters[i]
			var expected_char: String = practice_text[i] if i < practice_text.length() else ""

			if typed_char == expected_char:
				if _is_character_in_corruption_word(i, display_sentence):
					# Apply maximum animated corruption effects to CORRECTLY TYPED corrupted words
					var corruption_effects = _get_corruption_effects(i, true)
					color = corruption_effects.color
					if corruption_effects.character != "":
						final_character = corruption_effects.character
					else:
						final_character = character
				else:
					color = typed_color  # Green for normal typed words
			else:
				if _is_character_in_corruption_word(i, display_sentence):
					# Apply corruption effects even for incorrect typing
					var corruption_effects = _get_corruption_effects(i, false)
					var error_tinted_color = _blend_error_with_corruption(corruption_effects.color)
					color = error_tinted_color
					if corruption_effects.character != "":
						final_character = corruption_effects.character
					else:
						final_character = character
				else:
					color = error_color  # Red for incorrect typing
		else:
			# Character not yet typed
			if _is_character_in_corruption_word(i, display_sentence):
				# Apply maximum animated corruption effects to UNTYPED corrupted words
				var corruption_effects = _get_corruption_effects(i, false)
				color = corruption_effects.color
				if corruption_effects.character != "":
					final_character = corruption_effects.character
				else:
					final_character = character
			else:
				color = untyped_color  # Dark green for untyped normal words

		# Add cursor styling (underline) to current character
		if is_cursor_position:
			display_text += "[u][color=%s]%s[/color][/u]" % [color, final_character]
		else:
			display_text += "[color=%s]%s[/color]" % [color, final_character]

	text_display.text = display_text

## Day 5 - Maximum chaos corruption animation system
func _get_corruption_effects(char_position: int, is_typed_correctly: bool = false) -> Dictionary:
	var effects = {"color": corruption_color, "character": ""}

	# Calculate current animation intensity (maximum chaos throughout day)
	var stage_progress: float = float(DayManager.current_stage) / float(DayManager.stages_per_day)
	var current_intensity: float = corruption_intensity_base + (stage_progress * 0.3)  # Max intensity 1.0

	# Create unique seed for this character position for consistent randomization
	var time_step: int = int(corruption_animation_time / 0.25)  # Changes every 0.25 seconds (faster)
	var char_seed: int = (char_position * 19 + 29) % 1000  # Unique seed per character
	var seeded_random = RandomNumberGenerator.new()
	seeded_random.seed = char_seed + time_step

	# Character-specific timing offset
	var char_time_offset: float = float(char_position) * 0.2  # Each char offset by 0.2 seconds
	var char_animation_time: float = corruption_animation_time + char_time_offset

	# Base pulsing effect with character-specific timing
	var pulse_speed: float = 3.0 + seeded_random.randf() * 3.0  # Random pulse speed 3.0-6.0 (fastest)
	var pulse_phase: float = sin(char_animation_time * pulse_speed) * 0.5 + 0.5  # 0.0 to 1.0
	var pulse_intensity: float = current_intensity * pulse_phase

	# TYPED CORRECTLY: Provide clear visual feedback for successful typing
	if is_typed_correctly:
		# Subtle pulsing for typed characters
		var typed_pulse = sin(char_animation_time * 2.0) * 0.3 + 0.7  # 0.4 to 1.0 range
		var red_intensity = int(170 * typed_pulse)  # Vary between #aa2200 and #cc3300
		var green_intensity = int(34 * typed_pulse)
		effects.color = "#%02x%02x00" % [red_intensity, green_intensity]

		# Glitch chance for typed characters (higher than previous days)
		var glitch_base_chance: float = 0.08 + seeded_random.randf() * 0.08  # 8-16% base chance
		var typed_glitch_chance: float = glitch_base_chance * current_intensity
		if seeded_random.randf() < typed_glitch_chance:
			var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐", "■", "□", "▪", "▫", "◆", "◇"]
			effects.character = glitch_chars[seeded_random.randi() % glitch_chars.size()]

	# UNTYPED: Maximum corruption animation effects
	else:
		# Color animation with character-specific thresholds
		var color_threshold_high: float = 0.5 + seeded_random.randf() * 0.2  # 0.5-0.7 (easier to trigger)
		var color_threshold_mid: float = 0.2 + seeded_random.randf() * 0.2   # 0.2-0.4

		if pulse_intensity > color_threshold_high:
			effects.color = "#ff4400"  # Bright red-orange at peak
		elif pulse_intensity > color_threshold_mid:
			effects.color = "#dd3300"  # Medium red-orange
		else:
			effects.color = "#aa2200"  # Dark red-orange at low

		# Character-specific flicker chance (highest of all days)
		var flicker_chance: float = 0.30 + seeded_random.randf() * 0.20  # 30-50% base chance
		if seeded_random.randf() < flicker_chance * current_intensity:
			var flicker_colors = ["#ff4400", "#ee3300", "#cc2200", "#ff5500", "#ff0000"]
			effects.color = flicker_colors[seeded_random.randi() % flicker_colors.size()]

		# Character-specific glitch substitution (maximum chaos)
		var glitch_base_chance: float = 0.10 + seeded_random.randf() * 0.10  # 10-20% base chance (highest)
		var glitch_chance: float = glitch_base_chance * current_intensity
		if seeded_random.randf() < glitch_chance:
			var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐", "■", "□", "▪", "▫", "◆", "◇", "●", "○"]
			effects.character = glitch_chars[seeded_random.randi() % glitch_chars.size()]

	return effects

## Helper function to blend corruption colors with error color for visual feedback
func _blend_error_with_corruption(corruption_color_hex: String) -> String:
	# Parse the corruption color (hex format like "#ff4400")
	var hex_color = corruption_color_hex.replace("#", "")
	var red = ("0x" + hex_color.substr(0, 2)).hex_to_int()
	var green = ("0x" + hex_color.substr(2, 2)).hex_to_int()
	var blue = ("0x" + hex_color.substr(4, 2)).hex_to_int()

	# Blend with error color (yellow tint for visibility)
	red = min(255, int(red * 0.95))
	green = min(255, int(green + 150))  # Add yellow for error visibility
	blue = max(0, int(blue * 0.7))

	return "#%02x%02x%02x" % [red, green, blue]

# Note: _is_character_in_corruption_word() is now in BaseDay

func _show_message(message: String) -> void:
	# Day 5 - Maximum chaos horror effects with system collapse
	if not get_tree() or not message_overlay:
		return

	message_overlay.visible = true
	var red_tint = Color(1, 0.3, 0.2, 0)  # Red-orange critical color
	message_overlay.modulate = red_tint

	# Apply maximum message corruption
	var corrupted_message = _apply_message_corruption(message)

	# Chaotic fade-in with severe digital artifacts
	await _corrupted_fade_in(corrupted_message)

	# Hold message with intense glitch pulses
	await _hold_with_glitch_pulses(5.0)

	# Violent fade out with maximum text degradation
	await _chaotic_fade_out()
	message_overlay.visible = false

func _apply_message_corruption(message: String) -> String:
	# Apply maximum glitch corruption for final day
	var corrupted = ""
	var corruption_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐", "■", "□", "▪", "▫", "◆", "◇", "●", "○"]
	var words = message.split(" ")

	for word_idx in range(words.size()):
		var word = words[word_idx]
		var corrupted_word = ""

		# corrupt 2-3 characters per word, even in shorter words
		if word.length() > 2 and randf() < 0.6:  # 60% chance to corrupt
			@warning_ignore("integer_division")
			var chars_to_corrupt = min(3, word.length() / 2)  # Max 3 chars or half of word
			var corruption_positions = []

			# Pick random positions to corrupt
			for i in range(chars_to_corrupt):
				var pos = randi_range(0, word.length() - 1)
				if pos not in corruption_positions:
					corruption_positions.append(pos)

			# Apply corruption to selected positions
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

func _corrupted_fade_in(corrupted_message: String) -> void:
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
			var reglitched = _apply_message_corruption(corrupted_message)
			message_overlay.text = reglitched
		else:
			message_overlay.text = corrupted_message

		if step < fade_steps:
			# Extreme variable timing for chaotic feel
			var actual_duration = step_duration + randf_range(-0.08, 0.15)
			await get_tree().create_timer(actual_duration).timeout

func _hold_with_glitch_pulses(duration: float) -> void:
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
			message_overlay.text = _apply_message_corruption(current_text)

			await get_tree().create_timer(0.15).timeout

			if message_overlay:
				message_overlay.modulate.a = original_alpha
				message_overlay.text = current_text

		await get_tree().create_timer(delta).timeout

func _chaotic_fade_out() -> void:
	var fade_steps = 10
	var fade_duration = 1.5
	var step_duration = fade_duration / fade_steps

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
			var degraded_text = _degrade_text(current_text, corruption_level)
			message_overlay.text = degraded_text

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.15, 0.2)
			await get_tree().create_timer(actual_duration).timeout

func _degrade_text(text: String, corruption_level: float) -> String:
	var degraded = ""
	var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "■", "□", "▪", "▫", "◆", "◇", "●", "○", "▬", "▭"]

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
