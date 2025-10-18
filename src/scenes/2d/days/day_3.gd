extends BaseDay

## Day 3 - Breaking Down
## Unicode glitch corruption with victim messages
@onready var progress_bar_label: Label = %ProgressBarLabel

# Day-specific visual settings
var corruption_animation_time: float = 0.0
var corruption_animation_speed: float = 1.5  # Speed of pulsing effects
var corruption_intensity_base: float = 0.4   # Base intensity (higher than Day 2)

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 3
	corruption_color = "#ff6600"  # Orange for unicode corruption
	super._ready()

func _process(delta: float) -> void:
	# Call parent to handle cursor blink
	super._process(delta)

	# Update corruption animation time
	corruption_animation_time += delta * corruption_animation_speed

	# Only update display when text changes or on animation intervals
	if is_session_active and int(corruption_animation_time * 10) % 3 == 0:
		_update_display()

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var orange_tint = Color(1, 0.7, 0.3)  # Orange corruption hints

	accuracy_label.modulate = green_color
	wmp_label.modulate = orange_tint  # Corruption affecting stats
	day_stage_label.modulate = orange_tint
	progress_label.modulate = green_color
	message_overlay.modulate = orange_tint
	progress_bar_label.modulate = green_color

## Day 3 - Unicode corruption typewriter effect
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
			await get_tree().create_timer(0.3).timeout

	# Pause before allowing typing
	await get_tree().create_timer(0.8).timeout

	# Initialize custom progress display after typewriter effect
	_update_progress_display()

func _update_display() -> void:
	if not text_display:
		return

	# Day 3 specific display logic with animated corruption effects
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

		# Add cursor styling (blinking underline, character color stays the same)
		if is_cursor_position and cursor_blink_on:
			display_text += "[u][color=%s]%s[/color][/u]" % [color, final_character]
		else:
			display_text += "[color=%s]%s[/color]" % [color, final_character]

	text_display.text = display_text

	# Update custom progress display for Day 3
	_update_progress_display()

## Day 3 - Override progress display to use text-based progress bar
func _update_progress_display() -> void:
	if not progress_bar or not progress_label:
		return

	# Calculate typing progress within current stage
	var progress: float = 0.0
	if practice_text.length() > 0:
		progress = float(current_position) / float(practice_text.length())

	# Hide the original progress bar
	progress_bar.visible = false

	# Create text progress bar for current stage typing progress
	var total_blocks = 10
	var filled_blocks = int(progress * total_blocks)
	var empty_blocks = total_blocks - filled_blocks

	var progress_text = ""
	# Add filled blocks (▓)
	for i in range(filled_blocks):
		progress_text += "▓"
	# Add empty blocks (░)
	for i in range(empty_blocks):
		progress_text += "░"

	# Update label with stage info and text progress bar
	progress_label.text = "Stage %d of %d" % [DayManager.current_stage, DayManager.stages_per_day]
	progress_bar_label.text = progress_text

## Day 3 - Per-character randomized corruption animation effects system
func _get_corruption_effects(char_position: int, is_typed_correctly: bool = false) -> Dictionary:
	var effects = {"color": corruption_color, "character": ""}

	# Calculate current animation intensity (grows over time during day)
	var stage_progress: float = float(DayManager.current_stage) / float(DayManager.stages_per_day)
	var current_intensity: float = corruption_intensity_base + (stage_progress * 0.5)  # Max intensity 0.9

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
	var pulse_speed: float = 2.0 + seeded_random.randf() * 1.5  # Random pulse speed 2.0-3.5
	var pulse_phase: float = sin(char_animation_time * pulse_speed) * 0.5 + 0.5  # 0.0 to 1.0
	var pulse_intensity: float = current_intensity * pulse_phase

	# TYPED CORRECTLY: Provide clear visual feedback for successful typing
	if is_typed_correctly:
		# Subtle pulsing for typed characters (less intense)
		var typed_pulse = sin(char_animation_time * 1.2) * 0.3 + 0.7  # 0.4 to 1.0 range
		var orange_intensity = int(204 * typed_pulse)  # Vary between #cc4400 and #dd4400
		effects.color = "#%02x4400" % orange_intensity

		# Reduced glitch chance for typed characters
		var glitch_base_chance: float = 0.04 + seeded_random.randf() * 0.05  # 4-9% base chance
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
			effects.color = "#ff6600"  # Bright orange at peak
		elif pulse_intensity > color_threshold_mid:
			effects.color = "#dd5500"  # Medium orange
		else:
			effects.color = "#cc4400"  # Dark orange at low

		# Character-specific flicker chance
		var flicker_chance: float = 0.18 + seeded_random.randf() * 0.15  # 18-33% base chance
		if seeded_random.randf() < flicker_chance * current_intensity:
			var flicker_colors = ["#ff6600", "#cc4400", "#aa3300", "#ff8833"]
			effects.color = flicker_colors[seeded_random.randi() % flicker_colors.size()]

		# Character-specific glitch substitution
		var glitch_base_chance: float = 0.05 + seeded_random.randf() * 0.06  # 5-11% base chance
		var glitch_chance: float = glitch_base_chance * current_intensity
		if seeded_random.randf() < glitch_chance:
			var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"]
			effects.character = glitch_chars[seeded_random.randi() % glitch_chars.size()]

	return effects

## Helper function to blend corruption colors with error color for visual feedback
func _blend_error_with_corruption(corruption_color_hex: String) -> String:
	# Parse the corruption color (hex format like "#ff6600")
	var hex_color = corruption_color_hex.replace("#", "")
	var red = ("0x" + hex_color.substr(0, 2)).hex_to_int()
	var green = ("0x" + hex_color.substr(2, 2)).hex_to_int()
	var blue = ("0x" + hex_color.substr(4, 2)).hex_to_int()

	# Blend with error color (yellow/orange tint)
	red = min(255, int(red * 0.9))
	green = min(255, int(green + 120))  # Add more yellow
	blue = max(0, int(blue))

	return "#%02x%02x%02x" % [red, green, blue]

# Note: _is_character_in_corruption_word() is now in BaseDay

func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Day 3 - Glitchy, unstable horror effects
	message_overlay.visible = true
	var corruption_tint = Color(1, 0.4, 0.1, 0)  # Deep orange corruption color
	message_overlay.modulate = corruption_tint

	# Glitch the message text randomly before showing
	var glitched_message = _apply_message_corruption(message)

	# Unstable fade-in with digital artifacts
	await _corrupted_fade_in(glitched_message)

	# Hold message with subtle glitch pulses
	await _hold_with_glitch_pulses(5.0)

	# Chaotic fade out with text degradation
	await _chaotic_fade_out()
	message_overlay.visible = false


## Eerie low-fps fade in effect
func _eerie_fade_in() -> void:
	var fade_steps = 8  # Low number of steps for choppy, eerie effect
	var fade_duration = 1.2  # Faster fade in time
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = float(step) / float(fade_steps)
		message_overlay.modulate.a = alpha

		if step < fade_steps:  # Don't wait after the last step
			await get_tree().create_timer(step_duration).timeout

## Eerie low-fps fade out effect
func _eerie_fade_out() -> void:
	var fade_steps = 6  # Even choppier fade out
	var fade_duration = 1.0  # Much faster fade out
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_overlay:
			return

		var alpha = 1.0 - (float(step) / float(fade_steps))
		message_overlay.modulate.a = alpha

		if step < fade_steps:  # Don't wait after the last step
			await get_tree().create_timer(step_duration).timeout


func _show_message2(message: String) -> void:
	# Day 3 - More urgent/distorted message effects
	if not get_tree() or not message_overlay:
		return

	message_overlay.visible = true
	var orange_tint = Color(1, 0.7, 0.3, 0)
	message_overlay.modulate = orange_tint

	# Faster fade in - more urgent
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(message_overlay, "modulate:a", 1.0, 0.5)

	# Faster typing for urgency
	_type_message_urgently(message)

	await get_tree().create_timer(4.0).timeout

	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(message_overlay, "modulate:a", 0.0, 0.5)
	await fade_out_tween.finished
	message_overlay.visible = false

func _type_message_urgently(message: String) -> void:
	is_typing_message = true
	var typing_speed = 0.03  # Faster typing shows urgency

	var tree = get_tree()
	if not tree or not message_overlay:
		is_typing_message = false
		return

	message_overlay.text = ""

	for i in range(message.length()):
		tree = get_tree()
		if not tree or not message_overlay:
			is_typing_message = false
			return

		message_overlay.text += message[i]
		await tree.create_timer(typing_speed).timeout

		# Shorter pauses for punctuation
		if message[i] == "." or message[i] == "?" or message[i] == "!":
			tree = get_tree()
			if not tree:
				is_typing_message = false
				return
			await tree.create_timer(0.15).timeout

	is_typing_message = false

## Day 3 Horror Functions

func _apply_message_corruption(message: String) -> String:
	# Apply unicode corruption to random characters for unsettling effect
	var corrupted = ""
	var corruption_chars = ["ţ", "ř", "ą", "ë", "ł", "ń", "đ", "ş", "ž", "ć", "ų", "ň", "ď", "ľ"]
	var words = message.split(" ")

	for word_idx in range(words.size()):
		var word = words[word_idx]
		var corrupted_word = ""

		# corrupt 1-2 characters per word max, and skip short/important words
		if word.length() > 3 and randf() < 0.4:  # 40% chance to corrupt longer words
			@warning_ignore("integer_division")
			var chars_to_corrupt = min(2, word.length() / 3)  # Max 2 chars or 1/3 of word
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

func _corrupted_fade_in(glitched_message: String) -> void:
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
			var reglitched = _apply_message_corruption(glitched_message)
			message_overlay.text = reglitched
		else:
			message_overlay.text = glitched_message

		if step < fade_steps:
			# Variable timing for unstable feel
			var actual_duration = step_duration + randf_range(-0.05, 0.1)
			await get_tree().create_timer(actual_duration).timeout

func _hold_with_glitch_pulses(duration: float) -> void:
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
			message_overlay.text = _apply_message_corruption(current_text)

			await get_tree().create_timer(0.1).timeout

			if message_overlay:
				message_overlay.modulate.a = original_alpha
				message_overlay.text = current_text

		await get_tree().create_timer(delta).timeout

func _chaotic_fade_out() -> void:
	var fade_steps = 8
	var fade_duration = 1.2
	var step_duration = fade_duration / fade_steps

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
			var degraded_text = _degrade_text(current_text, corruption_level)
			message_overlay.text = degraded_text

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.1, 0.15)
			await get_tree().create_timer(actual_duration).timeout

func _degrade_text(text: String, corruption_level: float) -> String:
	var degraded = ""
	var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "■", "□", "▪", "▫"]

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
