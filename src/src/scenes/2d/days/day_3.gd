extends BaseDay

## Day 3 - Breaking Down
## Unicode glitch corruption with victim messages
@onready var progress_bar_label: Label = %ProgressBarLabel

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 3
	corruption_color = "#ff6600"  # Orange for unicode corruption
	cursor_blink_speed = 0.5
	super._ready()

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

	_update_cursor_position()

	# Day 3 specific display logic with unicode corruption effects
	var display_sentence = DayManager.get_stage_display_sentence()
	var display_text: String = ""

	for i in range(display_sentence.length()):
		var character: String = display_sentence[i]
		var color: String = untyped_color

		if i < typed_characters.length():
			var typed_char: String = typed_characters[i]
			var expected_char: String = practice_text[i] if i < practice_text.length() else ""

			if typed_char == expected_char:
				if _is_character_in_corruption_word(i, display_sentence):
					color = corruption_color  # Orange for correctly typed corruption
				else:
					color = typed_color  # Green for normal typed words
			else:
				color = error_color  # Red for incorrect typing
		else:
			if _is_character_in_corruption_word(i, display_sentence):
				color = corruption_color  # Orange for untyped corruption
			else:
				color = untyped_color  # Dark green for untyped normal words

		display_text += "[color=%s]%s[/color]" % [color, character]

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
	
func _is_character_in_corruption_word(char_pos: int, sentence: String) -> bool:
	var words = sentence.split(" ")
	var current_pos = 0

	for word in words:
		if char_pos >= current_pos and char_pos < current_pos + word.length():
			return DayManager.corruption_mappings.has(word)
		current_pos += word.length() + 1

	return false


func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Day 2 - Eerie low-fps fade effects
	message_overlay.visible = true
	message_overlay.text = message  # Set text immediately
	var red_tint = Color(1, 0.8, 0.8, 0)  # Preserve red tint but start invisible
	message_overlay.modulate = red_tint

	# Eerie low-fps fade in effect
	await _eerie_fade_in()

	# Auto-hide message after 4 seconds
	await get_tree().create_timer(4.0).timeout

	# Eerie low-fps fade out effect
	await _eerie_fade_out()
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
