extends Control

## Day 2 - First Cracks
## Introduction of ALL CAPS corruption mixed with normal text

signal stage_completed()
signal day_completed()

# UI References
@onready var text_display: RichTextLabel = %DisplayText
@onready var invisible_input: LineEdit = %InvisibleInput
@onready var wpm_label: Label = %WPMLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var day_stage_label: Label = %DayStageLabel
@onready var progress_label: Label = %ProgressLabel
@onready var restart_button: Button = %RestartButton
@onready var message_display: Label = %MessageDisplay

# Typing state
var practice_text: String = ""
var typed_characters: String = ""
var current_position: int = 0
var is_session_active: bool = false

# Visual settings
var typed_color: String = "#00ff00"
var untyped_color: String = "#00aa00"
var error_color: String = "#ff4444"
var corruption_color: String = "#ff0000"  # Red for corrupted text

# Corruption animation system
var corruption_animation_time: float = 0.0
var corruption_animation_speed: float = 1.3  # Speed of pulsing effects
var corruption_intensity_base: float = 0.3   # Base intensity that grows over time

# Day-specific data
const DAY_NUMBER: int = 2

func _ready() -> void:
	_setup_connections()
	_setup_ui_theme()
	_setup_interface()
	_initialize_day()

func _process(delta: float) -> void:
	# Update corruption animation time
	corruption_animation_time += delta * corruption_animation_speed

	# Only update display when text changes or on animation intervals
	if is_session_active and int(corruption_animation_time * 10) % 3 == 0:
		_update_display()

func _initialize_day() -> void:
	DayManager.start_day(DAY_NUMBER)
	_start_new_stage()

func _setup_connections() -> void:
	restart_button.pressed.connect(_restart_stage)
	invisible_input.text_changed.connect(_on_text_changed)
	invisible_input.gui_input.connect(_on_gui_input)

	# Connect to DayManager
	DayManager.message_ready.connect(_on_message_ready)
	DayManager.stage_completed.connect(_on_stage_completed)
	DayManager.day_completed.connect(_on_day_completed)

	# Connect to TypingEngine
	if TypingEngine:
		TypingEngine.letter_typed.connect(_on_letter_typed)
		TypingEngine.mistake_made.connect(_on_mistake_made)
		TypingEngine.real_time_stats_updated.connect(_on_real_time_stats_updated)

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var red_tint = Color(1, 0.8, 0.8)  # Slight red tint for corruption hints

	accuracy_label.modulate = green_color
	wpm_label.modulate = green_color
	day_stage_label.modulate = red_tint  # Hint of corruption starting
	progress_label.modulate = green_color
	message_display.modulate = red_tint

func _setup_interface() -> void:
	invisible_input.grab_focus()
	invisible_input.placeholder_text = ""
	invisible_input.position = Vector2(-1000, -1000)
	invisible_input.size = Vector2(100, 20)

	text_display.selection_enabled = false
	text_display.scroll_active = false

	# Configure message display for proper text wrapping
	message_display.visible = false
	message_display.text = ""
	message_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _start_new_stage() -> void:
	# Generate English text for typing from DayManager
	practice_text = DayManager.generate_stage_text()

	# Reset typing state
	typed_characters = ""
	current_position = 0
	is_session_active = false  # Don't allow typing yet

	invisible_input.text = ""
	invisible_input.editable = false  # Disable input during typewriter effect

	# Update UI
	day_stage_label.text = "Day %d - Stage %d" % [DAY_NUMBER, DayManager.current_stage]
	progress_label.text = "Stage %d of %d" % [DayManager.current_stage, DayManager.stages_per_day]

	progress_bar.value = 0.0
	wpm_label.text = "WPM: 0.0"
	accuracy_label.text = "Accuracy: 100.0%"

	# Show eerie typewriter effect first, then enable typing
	await _show_stage_text_typewriter()

	# Now enable typing practice
	is_session_active = true
	invisible_input.editable = true
	invisible_input.grab_focus()

	# Initialize systems
	if TypingEngine:
		TypingEngine.start_typing_session()
	if StatsManager:
		StatsManager.start_session()

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if is_session_active:
			if event.keycode == KEY_BACKSPACE:
				if invisible_input.text.length() > 0:
					var new_text = invisible_input.text.substr(0, invisible_input.text.length() - 1)
					invisible_input.text = new_text
					_on_text_changed(new_text)
					get_viewport().set_input_as_handled()
			elif event.unicode > 0:
				var char_to_add = char(event.unicode)
				if char_to_add.length() > 0 and char_to_add != "\n" and char_to_add != "\r":
					var new_text = invisible_input.text + char_to_add
					invisible_input.text = new_text
					_on_text_changed(new_text)
					get_viewport().set_input_as_handled()

func _on_text_changed(new_text: String) -> void:
	if not is_session_active or practice_text.is_empty():
		return

	if new_text.length() > typed_characters.length():
		_handle_character_input(new_text)
	elif new_text.length() < typed_characters.length():
		_handle_backspace(new_text)

func _handle_character_input(new_text: String) -> void:
	if current_position >= practice_text.length():
		return

	var typed_char: String = new_text[new_text.length() - 1]
	var expected_char: String = practice_text[current_position]
	var is_correct: bool = typed_char == expected_char

	if TypingEngine:
		TypingEngine.process_keystroke(typed_char)

	typed_characters = new_text
	current_position += 1

	# Force immediate display update on typing
	_update_display()
	_check_completion()

func _handle_backspace(new_text: String) -> void:
	if typed_characters.length() > 0 and current_position > 0:
		typed_characters = new_text
		current_position = typed_characters.length()
		_update_display()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		invisible_input.grab_focus()

func _update_display() -> void:
	if not text_display:
		return

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
				color = error_color  # Incorrect typing in error color
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
		var typed_glitch_chance = 0.01 * current_intensity  # Much lower chance
		if seeded_random.randf() < typed_glitch_chance:
			var glitch_chars = ["▓", "▒"]  # Less aggressive glitch chars for typed
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



func _check_completion() -> void:
	if current_position >= practice_text.length():
		_complete_stage()

func _complete_stage() -> void:
	is_session_active = false
	invisible_input.editable = false

	# Complete stage in DayManager
	DayManager.complete_stage()
	stage_completed.emit()

	# Wait for any messages, then continue
	await get_tree().create_timer(1.0).timeout

	if DayManager.current_stage <= DayManager.stages_per_day:
		_start_new_stage()

func _restart_stage() -> void:
	_start_new_stage()

func _on_message_ready(message: String, message_type: String) -> void:
	_show_message(message)

func _show_message(message: String) -> void:
	# Day 2 - Subtle eerie effects begin
	message_display.visible = true
	message_display.modulate.a = 0.0

	# Slowly fade in the message
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(message_display, "modulate:a", 1.0, 1.0)

	# Type out the message character by character for eerie effect
	_type_message_eerily(message)

	# Auto-hide message after 4 seconds
	await get_tree().create_timer(5.0).timeout

	# Fade out
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(message_display, "modulate:a", 0.0, 1.0)
	await fade_out_tween.finished
	message_display.visible = false

func _type_message_eerily(message: String) -> void:
	var typing_speed = 0.05  # Slow typing for eerie effect
	message_display.text = ""

	for i in range(message.length()):
		message_display.text += message[i]
		await get_tree().create_timer(typing_speed).timeout

		# Occasional pause for dramatic effect
		if message[i] == "." or message[i] == "?" or message[i] == "!":
			await get_tree().create_timer(0.3).timeout

func _on_stage_completed(day: int, stage: int) -> void:
	if day == DAY_NUMBER:
		pass

func _on_day_completed(day_number: int) -> void:
	if day_number == DAY_NUMBER:
		day_completed.emit()
		# Transition to day end screen
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://src/scenes/days/DayEndScreen.tscn")

func _on_letter_typed(letter: String, is_correct: bool, response_time: float) -> void:
	pass # Audio feedback could go here

func _on_mistake_made(expected: String, typed: String) -> void:
	pass

func _on_real_time_stats_updated(wpm: float, accuracy: float) -> void:
	wpm_label.text = "WPM: %.1f" % wpm
	accuracy_label.text = "Accuracy: %.1f%%" % accuracy

	var progress: float = 0.0
	if practice_text.length() > 0:
		progress = float(current_position) / float(practice_text.length())
	progress_bar.value = progress * 100
