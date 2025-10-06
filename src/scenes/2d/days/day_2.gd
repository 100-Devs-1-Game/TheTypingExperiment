extends BaseDay

## Day 2 - First Cracks
## Introduction of ALL CAPS corruption mixed with normal text

# Day-specific visual settings
var corruption_animation_time: float = 0.0
var corruption_animation_speed: float = 1.3  # Speed of pulsing effects
var corruption_intensity_base: float = 0.3   # Base intensity that grows over time

# Horror effects system
var horror_effects: HorrorEffectsManager

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 2
	corruption_color = "#ff0000"  # Red for corrupted text
	cursor_blink_speed = 0.5

	# Setup horror effects manager for Day 2
	_setup_horror_effects()

	super._ready()

func _process(delta: float) -> void:
	# Update corruption animation time
	corruption_animation_time += delta * corruption_animation_speed

	# Only update display when text changes or on animation intervals
	if is_session_active and int(corruption_animation_time * 10) % 3 == 0:
		_update_display()

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var red_tint = Color(1, 0.8, 0.8)  # Slight red tint for corruption hints

	accuracy_label.modulate = green_color
	wmp_label.modulate = green_color
	day_stage_label.modulate = red_tint  # Hint of corruption starting
	progress_label.modulate = green_color
	message_overlay.modulate = red_tint

## Day 2 - Eerie typewriter effect with first corruption
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.04  # Slightly faster, more urgent
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
		var is_corruption_char = _is_character_in_corruption_word(i, display_sentence)

		# Apply color formatting as we type
		if is_corruption_char:
			text_display.text += "[color=%s]%s[/color]" % [corruption_color, character]
		else:
			text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		await get_tree().create_timer(typing_speed).timeout

		# Dramatic pause for corruption words
		if is_corruption_char and character == " ":
			await get_tree().create_timer(0.2).timeout

	# Pause before allowing typing
	await get_tree().create_timer(0.8).timeout

func _update_display() -> void:
	if not text_display:
		return

	_update_cursor_position()

	# Get the corrupted display text (what the user sees)
	var display_sentence = DayManager.get_stage_display_sentence()
	var display_text: String = ""

	# Advanced character-by-character display with corruption animation effects
	for i in range(display_sentence.length()):
		var character: String = display_sentence[i]
		var color: String = untyped_color
		var final_character: String = character

		if i < typed_characters.length():
			# Character has been typed
			var typed_char: String = typed_characters[i]
			var expected_char: String = practice_text[i] if i < practice_text.length() else ""

			# Check if the typing was correct (compare against English text)
			if typed_char == expected_char:
				# Determine color based on what's being displayed
				if _is_character_in_corruption_word(i, display_sentence):
					# Apply animated corruption effects to CORRECTLY TYPED corrupted words
					var corruption_effects = _get_corruption_effects(i, true)  # true = typed correctly
					color = corruption_effects.color
					# Use glitch character if available
					if corruption_effects.character != "":
						final_character = corruption_effects.character
					else:
						final_character = character
				else:
					color = typed_color  # Normal typed words in green
			else:
				# Incorrect typing - check if it's a corruption character
				if _is_character_in_corruption_word(i, display_sentence):
					# Apply corruption effects even for incorrect typing, but with error tinting
					var corruption_effects = _get_corruption_effects(i, false)  # false = maintain untyped effects
					# Tint the corruption color with error color for visual feedback
					var error_tinted_color = _blend_error_with_corruption(corruption_effects.color)
					color = error_tinted_color
					# Still use glitch character if available
					if corruption_effects.character != "":
						final_character = corruption_effects.character
					else:
						final_character = character
				else:
					color = error_color  # Normal incorrect typing in error color
		else:
			# Character not yet typed - show in untyped color
			if _is_character_in_corruption_word(i, display_sentence):
				# Apply animated corruption effects to UNTYPED corrupted words
				var corruption_effects = _get_corruption_effects(i, false)  # false = not typed yet
				color = corruption_effects.color
				# Use glitch character if available (character-specific chance)
				if corruption_effects.character != "":
					final_character = corruption_effects.character
				else:
					final_character = character
			else:
				color = untyped_color  # Normal untyped words

		display_text += "[color=%s]%s[/color]" % [color, final_character]

	text_display.text = display_text

## Helper function to determine if character at position is part of a corruption word
func _is_character_in_corruption_word(char_pos: int, sentence: String) -> bool:
	var words = sentence.split(" ")
	var current_pos = 0

	for word in words:
		if char_pos >= current_pos and char_pos < current_pos + word.length():
			# Character is within this word
			return _is_corruption_word(word)
		current_pos += word.length() + 1  # +1 for space

	return false

func _is_corruption_word(word: String) -> bool:
	# Check if word is in the corruption mappings (meaning it's a corrupted word)
	return DayManager.corruption_mappings.has(word)

## Day 2 - Per-character randomized corruption animation effects system
func _get_corruption_effects(char_position: int, is_typed_correctly: bool = false) -> Dictionary:
	var effects = {"color": corruption_color, "character": ""}

	# Calculate current animation intensity (grows over time during day)
	var stage_progress: float = float(DayManager.current_stage) / float(DayManager.stages_per_day)
	var current_intensity: float = corruption_intensity_base + (stage_progress * 0.4)  # Max intensity 0.7

	# Create unique seed for this character position for consistent randomization
	var char_seed: int = (char_position * 17 + 23) % 1000  # Unique seed per character
	var seeded_random = RandomNumberGenerator.new()
	seeded_random.seed = char_seed + int(corruption_animation_time * 10) % 100  # Change seed over time

	# Character-specific timing offset
	var char_time_offset: float = float(char_position) * 0.3  # Each char offset by 0.3 seconds
	var char_animation_time: float = corruption_animation_time + char_time_offset

	# Base pulsing effect with character-specific timing
	var pulse_speed: float = 2.5 + seeded_random.randf() * 1.5  # Random pulse speed 2.5-4.0
	var pulse_phase: float = sin(char_animation_time * pulse_speed) * 0.5 + 0.5  # 0.0 to 1.0
	var pulse_intensity: float = current_intensity * pulse_phase

	# TYPED CORRECTLY: Provide clear visual feedback for successful typing
	if is_typed_correctly:
		# Correctly typed corrupted characters get a distinct appearance
		# Base color is darker/more muted to show "completion"
		var typed_base_color = "#aa0000"  # Darker red base for typed characters

		# Subtle pulsing for typed characters (less intense)
		var typed_pulse = sin(char_animation_time * 1.5) * 0.3 + 0.7  # 0.4 to 1.0 range
		var red_intensity = int(170 * typed_pulse)  # Vary between #aa0000 and #bb0000
		effects.color = "#%02x0000" % red_intensity

		# Reduced glitch chance for typed characters (shows stability)
		var glitch_base_chance: float = 0.03 + seeded_random.randf() * 0.04  # 3-7% base chance
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
			effects.color = "#ff0000"  # Bright red at peak
		elif pulse_intensity > color_threshold_mid:
			effects.color = "#dd0000"  # Medium red
		else:
			effects.color = "#cc0000"  # Dark red at low

		# Character-specific flicker chance (random per character)
		var flicker_chance: float = 0.15 + seeded_random.randf() * 0.15  # 15-30% base chance
		if seeded_random.randf() < flicker_chance * current_intensity:
			# Flicker between different red intensities
			var flicker_colors = ["#ff0000", "#cc0000", "#aa0000", "#ff3333"]
			effects.color = flicker_colors[seeded_random.randi() % flicker_colors.size()]

		# Character-specific glitch substitution (random per character)
		var glitch_base_chance: float = 0.03 + seeded_random.randf() * 0.04  # 3-7% base chance
		var glitch_chance: float = glitch_base_chance * current_intensity
		if seeded_random.randf() < glitch_chance:
			var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"]
			effects.character = glitch_chars[seeded_random.randi() % glitch_chars.size()]

	return effects

## Helper function to blend corruption colors with error color for visual feedback
func _blend_error_with_corruption(corruption_color: String) -> String:
	# Parse the corruption color (hex format like "#ff0000")
	var hex_color = corruption_color.replace("#", "")
	var red = ("0x" + hex_color.substr(0, 2)).hex_to_int()
	var green = ("0x" + hex_color.substr(2, 2)).hex_to_int()
	var blue = ("0x" + hex_color.substr(4, 2)).hex_to_int()

	# Blend with error color (yellow/orange tint) to indicate error while keeping corruption effects
	# Error color is typically yellow/orange, so we add green component and reduce red slightly
	red = min(255, int(red * 0.9))  # Slightly reduce red intensity
	green = min(255, int(green + 100))  # Add yellow/orange tint
	blue = max(0, int(blue))  # Keep blue component low

	return "#%02x%02x%02x" % [red, green, blue]

func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Day 2 - Use standardized horror effects
	if horror_effects:
		await horror_effects.show_day2_style_message(message_overlay, message)
	else:
		# Fallback to basic display if horror effects not available
		message_overlay.text = message
		message_overlay.visible = true
		await get_tree().create_timer(4.0).timeout
		message_overlay.visible = false

# Setup horror effects manager for Day 2
func _setup_horror_effects() -> void:
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "Day2HorrorEffects"
	add_child(horror_effects)
