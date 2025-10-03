extends BaseDay

## Day 4 - System Warning
## Heavy zalgo corruption with escape clues
@onready var progress_bar_label: Label = %ProgressBarLabel

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 4
	corruption_color = "#aa00aa"  # Purple for zalgo corruption
	cursor_blink_speed = 0.4  # Faster blinking shows system stress
	super._ready()

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

## Day 4 - Zalgo corruption typewriter effect with system stress
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

	# Day 4 specific display logic with zalgo corruption effects
	var display_sentence = DayManager.get_stage_display_sentence()
	var display_text: String = ""

	for i in range(display_sentence.length()):
		var character: String = display_sentence[i]
		var color: String = untyped_color
		var final_character: String = character

		if i < typed_characters.length():
			var typed_char: String = typed_characters[i]
			var expected_char: String = practice_text[i] if i < practice_text.length() else ""

			if typed_char == expected_char:
				if _is_character_in_corruption_word(i, display_sentence):
					color = corruption_color  # Purple for correctly typed corruption
					# Add slight glitch effect for typed zalgo characters
					if randf() < 0.1:  # 10% chance for glitch
						var glitch_chars = ["▓", "▒", "░"]
						final_character = glitch_chars[randi() % glitch_chars.size()]
				else:
					color = typed_color  # Green for normal typed words
			else:
				color = error_color  # Red for incorrect typing
		else:
			if _is_character_in_corruption_word(i, display_sentence):
				color = corruption_color  # Purple for untyped corruption
				# Add glitch effect for untyped zalgo characters
				if randf() < 0.15:  # 15% chance for glitch
					var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀"]
					final_character = glitch_chars[randi() % glitch_chars.size()]
			else:
				color = untyped_color  # Dark green for untyped normal words

		display_text += "[color=%s]%s[/color]" % [color, final_character]

	text_display.text = display_text

func _is_character_in_corruption_word(char_pos: int, sentence: String) -> bool:
	var words = sentence.split(" ")
	var current_pos = 0

	for word in words:
		if char_pos >= current_pos and char_pos < current_pos + word.length():
			return DayManager.corruption_mappings.has(word)
		current_pos += word.length() + 1

	return false

func _show_message(message: String) -> void:
	# Day 4 - System warning style messages with glitch effects
	if not get_tree() or not message_overlay:
		return

	message_overlay.visible = true
	var purple_tint = Color(0.8, 0.4, 0.8, 0)
	message_overlay.modulate = purple_tint

	# Quick flash fade in - system warning style
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(message_overlay, "modulate:a", 1.0, 0.2)

	# Erratic typing with glitches
	_type_message_with_glitches(message)

	await get_tree().create_timer(4.5).timeout

	# Quick fade out
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(message_overlay, "modulate:a", 0.0, 0.3)
	await fade_out_tween.finished
	message_overlay.visible = false

func _type_message_with_glitches(message: String) -> void:
	is_typing_message = true

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

		var char_to_add = message[i]

		# Random glitch chance for characters
		if randf() < 0.05:  # 5% chance for glitch
			var glitch_chars = ["▓", "░", "▒", "█"]
			char_to_add = glitch_chars[randi() % glitch_chars.size()]

		message_overlay.text += char_to_add

		# Variable typing speed - system is unstable
		var typing_speed = 0.02 + randf() * 0.04  # 0.02-0.06 seconds
		await tree.create_timer(typing_speed).timeout

		# Shorter, more frequent pauses
		if message[i] == "." or message[i] == "?" or message[i] == "!":
			tree = get_tree()
			if not tree:
				is_typing_message = false
				return
			await tree.create_timer(0.1).timeout

	is_typing_message = false
