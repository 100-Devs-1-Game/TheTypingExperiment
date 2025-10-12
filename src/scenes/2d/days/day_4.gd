extends BaseDay

## Day 4 - System Warning
## Reversed words corruption with escape clues
@onready var progress_bar_label: Label = %ProgressBarLabel

# Day-specific visual settings
var corruption_animation_time: float = 0.0
var corruption_animation_speed: float = 1.8  # Faster than Day 3
var corruption_intensity_base: float = 0.5   # Higher intensity than Day 3

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 4
	corruption_color = "#aa00aa"  # Purple for reversed corruption
	cursor_blink_speed = 0.4  # Faster blinking shows system stress
	super._ready()

func _process(delta: float) -> void:
	# Update corruption animation time
	corruption_animation_time += delta * corruption_animation_speed

	# Only update display when text changes or on animation intervals
	if is_session_active and int(corruption_animation_time * 10) % 3 == 0:
		_update_display()

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var purple_tint = Color(0.8, 0.4, 0.8)  # Purple corruption hints
	var warning_red = Color(1, 0.6, 0.6)  # Warning red for system stress

	accuracy_label.modulate = warning_red  # System degrading
	wmp_label.modulate = purple_tint  # Heavy corruption affecting stats
	day_stage_label.modulate = purple_tint
	progress_label.modulate = warning_red
	message_overlay.modulate = purple_tint
	progress_bar_label.modulate = purple_tint

## Day 4 - Reversed word corruption typewriter effect with system stress
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.03  # Faster, more erratic typing
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
		var is_corruption_char = _is_character_in_corruption_word(i, display_sentence)

		# Apply color formatting as we type
		if is_corruption_char:
			text_display.text += "[color=%s]%s[/color]" % [corruption_color, character]
		else:
			text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		# Variable typing speed - system is unstable
		var speed_variation = randf() * 0.02  # 0-0.02 second variation
		await get_tree().create_timer(typing_speed + speed_variation).timeout

		# Longer dramatic pause for corruption words - system struggling
		if is_corruption_char and character == " ":
			await get_tree().create_timer(0.4).timeout

	# Longer pause before allowing typing - system stress
	await get_tree().create_timer(1.0).timeout

func _update_display() -> void:
	if not text_display:
		return

	_update_cursor_position()

	# Day 4 specific display logic with animated corruption effects
	var display_sentence = DayManager.get_stage_display_sentence()
	var display_text: String = ""

	for i in range(display_sentence.length()):
		var character: String = display_sentence[i]
		var color: String = untyped_color
		var final_character: String = character

		if i < typed_characters.length():
			# Character has been typed
			var typed_char: String = typed_characters[i]
			var expected_char: String = practice_text[i] if i < practice_text.length() else ""

			if typed_char == expected_char:
				if _is_character_in_corruption_word(i, display_sentence):
					# Apply animated corruption effects to CORRECTLY TYPED corrupted words
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
				# Apply animated corruption effects to UNTYPED corrupted words
				var corruption_effects = _get_corruption_effects(i, false)
				color = corruption_effects.color
				if corruption_effects.character != "":
					final_character = corruption_effects.character
				else:
					final_character = character
			else:
				color = untyped_color  # Dark green for untyped normal words

		display_text += "[color=%s]%s[/color]" % [color, final_character]

	text_display.text = display_text

## Day 4 - Per-character randomized corruption animation effects system
func _get_corruption_effects(char_position: int, is_typed_correctly: bool = false) -> Dictionary:
	var effects = {"color": corruption_color, "character": ""}

	# Calculate current animation intensity (grows over time during day)
	var stage_progress: float = float(DayManager.current_stage) / float(DayManager.stages_per_day)
	var current_intensity: float = corruption_intensity_base + (stage_progress * 0.4)  # Max intensity 0.9

	# Create unique seed for this character position for consistent randomization
	# Use floor division to make seed change only at specific time intervals (every ~0.3 seconds)
	var time_step: int = int(corruption_animation_time / 0.3)  # Changes every 0.3 seconds
	var char_seed: int = (char_position * 17 + 23) % 1000  # Unique seed per character
	var seeded_random = RandomNumberGenerator.new()
	seeded_random.seed = char_seed + time_step  # Seed changes only with time_step, not every frame

	# Character-specific timing offset
	var char_time_offset: float = float(char_position) * 0.3  # Each char offset by 0.3 seconds
	var char_animation_time: float = corruption_animation_time + char_time_offset

	# Base pulsing effect with character-specific timing
	var pulse_speed: float = 2.5 + seeded_random.randf() * 2.0  # Random pulse speed 2.5-4.5 (faster)
	var pulse_phase: float = sin(char_animation_time * pulse_speed) * 0.5 + 0.5  # 0.0 to 1.0
	var pulse_intensity: float = current_intensity * pulse_phase

	# TYPED CORRECTLY: Provide clear visual feedback for successful typing
	if is_typed_correctly:
		# Correctly typed corrupted characters get a distinct appearance
		var typed_base_color = "#880088"  # Darker purple base for typed characters

		# Subtle pulsing for typed characters (less intense)
		var typed_pulse = sin(char_animation_time * 1.5) * 0.3 + 0.7  # 0.4 to 1.0 range
		var purple_intensity = int(136 * typed_pulse)  # Vary between #880088 and #990099
		effects.color = "#%02x00%02x" % [purple_intensity, purple_intensity]

		# Reduced glitch chance for typed characters
		var glitch_base_chance: float = 0.05 + seeded_random.randf() * 0.06  # 5-11% base chance
		var typed_glitch_chance: float = glitch_base_chance * current_intensity
		if seeded_random.randf() < typed_glitch_chance:
			var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"]
			effects.character = glitch_chars[seeded_random.randi() % glitch_chars.size()]

	# UNTYPED: Full corruption animation effects
	else:
		# Color animation with character-specific thresholds
		var color_threshold_high: float = 0.6 + seeded_random.randf() * 0.2  # 0.6-0.8
		var color_threshold_mid: float = 0.3 + seeded_random.randf() * 0.2   # 0.3-0.5

		if pulse_intensity > color_threshold_high:
			effects.color = "#aa00aa"  # Bright purple at peak
		elif pulse_intensity > color_threshold_mid:
			effects.color = "#990099"  # Medium purple
		else:
			effects.color = "#880088"  # Dark purple at low

		# Character-specific flicker chance
		var flicker_chance: float = 0.20 + seeded_random.randf() * 0.15  # 20-35% base chance (higher than Day 3)
		if seeded_random.randf() < flicker_chance * current_intensity:
			var flicker_colors = ["#aa00aa", "#880088", "#770077", "#bb00bb"]
			effects.color = flicker_colors[seeded_random.randi() % flicker_colors.size()]

		# Character-specific glitch substitution
		var glitch_base_chance: float = 0.06 + seeded_random.randf() * 0.07  # 6-13% base chance (higher than Day 3)
		var glitch_chance: float = glitch_base_chance * current_intensity
		if seeded_random.randf() < glitch_chance:
			var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"]
			effects.character = glitch_chars[seeded_random.randi() % glitch_chars.size()]

	return effects

## Helper function to blend corruption colors with error color for visual feedback
func _blend_error_with_corruption(corruption_color_hex: String) -> String:
	# Parse the corruption color (hex format like "#aa00aa")
	var hex_color = corruption_color_hex.replace("#", "")
	var red = ("0x" + hex_color.substr(0, 2)).hex_to_int()
	var green = ("0x" + hex_color.substr(2, 2)).hex_to_int()
	var blue = ("0x" + hex_color.substr(4, 2)).hex_to_int()

	# Blend with error color (yellow/orange tint)
	red = min(255, int(red * 0.9))
	green = min(255, int(green + 140))  # Add more yellow for error
	blue = max(0, int(blue * 0.8))

	return "#%02x%02x%02x" % [red, green, blue]

# Note: _is_character_in_corruption_word() is now in BaseDay

func _show_message(message: String) -> void:
	# Day 4 - System warning style with fade and corruption
	if not get_tree() or not message_overlay:
		return

	# Apply corruption to message text
	var corrupted_message = _apply_glitch_corruption(message)
	message_overlay.text = corrupted_message

	message_overlay.visible = true
	var purple_tint = Color(0.8, 0.4, 0.8, 0)
	message_overlay.modulate = purple_tint

	# Choppy fade in (Day 2 style)
	await _choppy_fade_in()

	# Display duration
	await get_tree().create_timer(4.5).timeout

	# Choppy fade out
	await _choppy_fade_out()

	message_overlay.visible = false

func _apply_glitch_corruption(message: String) -> String:
	var corrupted = ""
	var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"]

	for i in range(message.length()):
		var char = message[i]
		# 7% chance to corrupt each non-space character
		if char != " " and randf() < 0.07:
			corrupted += glitch_chars[randi() % glitch_chars.size()]
		else:
			corrupted += char

	return corrupted

func _choppy_fade_in() -> void:
	var fade_steps = 8  # Low-fps choppy effect
	var fade_duration = 1.2
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = float(step) / float(fade_steps)
		message_overlay.modulate.a = alpha

		if step < fade_steps:
			await get_tree().create_timer(step_duration).timeout

func _choppy_fade_out() -> void:
	var fade_steps = 6  # Choppier fade out
	var fade_duration = 1.0
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = 1.0 - (float(step) / float(fade_steps))
		message_overlay.modulate.a = alpha

		if step < fade_steps:
			await get_tree().create_timer(step_duration).timeout
