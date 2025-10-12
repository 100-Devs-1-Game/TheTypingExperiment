class_name BaseDay
extends Control

## Base class for all day scenes
## Contains all common typing functionality and UI setup
## Day-specific classes only need to override corruption and visual effects

signal stage_completed()
signal day_completed()
signal day_end_screen_requested()

# UI References (all days use these)
@onready var text_display: RichTextLabel = %DisplayText
@onready var cursor: ColorRect = %Cursor
@onready var invisible_input: LineEdit = %InvisibleInput
@onready var wmp_label: Label = %WPMLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var day_stage_label: Label = %DayStageLabel
@onready var progress_label: Label = %ProgressLabel
@onready var restart_button: Button = %RestartButton
@onready var message_overlay: Label = %MessageOverlay

# Typing state (identical across all days)
var practice_text: String = ""
var typed_characters: String = ""
var current_position: int = 0
var is_session_active: bool = false

# Base visual settings (can be overridden)
var typed_color: String = "#00ff00"
var untyped_color: String = "#00aa00"
var error_color: String = "#ff4444"
var corruption_color: String = "#ff0000"  # Overridden in child classes
var cursor_blink_speed: float = 0.5       # Overridden in child classes

# Cursor animation (now using modular TextCursorCalculator)
var cursor_blinker: TextCursorCalculator.CursorBlinker

# Message handling
var is_typing_message: bool = false

# Day-specific data (must be set in child classes)
var DAY_NUMBER: int = 1

func _ready() -> void:
	_setup_connections()
	_setup_ui_theme()
	_setup_interface()
	_start_cursor_blinking()
	_initialize_day()

func _initialize_day() -> void:
	DayManager.start_day(DAY_NUMBER)
	_start_new_stage()
#TODO: Fix by removing cursor blinker maybe
#func _exit_tree() -> void:
	## Disconnect all signals to prevent memory leaks
	#if restart_button and restart_button.pressed.is_connected(_restart_stage):
		#restart_button.pressed.disconnect(_restart_stage)
#
	#if invisible_input:
		#if invisible_input.text_changed.is_connected(_on_text_changed):
			#invisible_input.text_changed.disconnect(_on_text_changed)
		#if invisible_input.gui_input.is_connected(_on_gui_input):
			#invisible_input.gui_input.disconnect(_on_gui_input)
#
	## Disconnect DayManager signals
	#if DayManager:
		#if DayManager.message_ready.is_connected(_on_message_ready):
			#DayManager.message_ready.disconnect(_on_message_ready)
		#if DayManager.day_completed.is_connected(_on_day_completed):
			#DayManager.day_completed.disconnect(_on_day_completed)
#
	## Disconnect TypingEngine signals
	#if TypingEngine and TypingEngine.real_time_stats_updated.is_connected(_on_real_time_stats_updated):
		#TypingEngine.real_time_stats_updated.disconnect(_on_real_time_stats_updated)
#
	## Clean up cursor blinker
	#if cursor_blinker:
		#cursor_blinker.stop()

func _setup_connections() -> void:
	restart_button.pressed.connect(_restart_stage)
	invisible_input.text_changed.connect(_on_text_changed)
	invisible_input.gui_input.connect(_on_gui_input)

	# Connect to DayManager
	DayManager.message_ready.connect(_on_message_ready)
	DayManager.day_completed.connect(_on_day_completed)

	# Connect to TypingEngine
	if TypingEngine:
		TypingEngine.real_time_stats_updated.connect(_on_real_time_stats_updated)

# VIRTUAL FUNCTION - Override in child classes for day-specific UI themes
func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	accuracy_label.modulate = green_color
	wmp_label.modulate = green_color
	day_stage_label.modulate = green_color
	progress_label.modulate = green_color

func _setup_interface() -> void:
	invisible_input.grab_focus()
	invisible_input.placeholder_text = ""
	invisible_input.position = Vector2(-1000, -1000)
	invisible_input.size = Vector2(100, 20)

	text_display.selection_enabled = false
	text_display.scroll_active = false

	cursor.color = Color(0, 1, 0, 1)
	cursor.visible = true

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

	# Position cursor at the beginning
	if cursor:
		cursor.visible = true
		# Reset cursor to starting position - calculate proper line height
		var font = text_display.get_theme_default_font()
		var font_size = text_display.get_theme_font_size("normal_font_size")
		var line_height = font.get_height(font_size)
		cursor.position = Vector2(30.0, 30.0 + line_height)  # 30px margin + line height
		_start_cursor_blinking()

	progress_bar.value = 0.0
	wmp_label.text = "WPM: 0.0"
	accuracy_label.text = "Accuracy: 100.0%"

	# Show typewriter effect first, then enable typing
	await _show_stage_text_typewriter()

	# Now enable typing practice
	is_session_active = true
	invisible_input.editable = true
	invisible_input.grab_focus()

	# Initialize systems
	if TypingEngine:
		TypingEngine.current_text = practice_text
		TypingEngine.start_typing_session()
		# Note: TypingEngine.start_typing_session() already handles all stats tracking
		# StatsManager was redundant and has been removed

# VIRTUAL FUNCTION - Override in child classes for day-specific typewriter effects
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.04  # Slightly faster, more urgent
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
	
		text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		await get_tree().create_timer(typing_speed).timeout

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

	if TypingEngine:
		# Sync TypingEngine position with our position
		TypingEngine.current_position = current_position
		TypingEngine.process_keystroke(typed_char)

	typed_characters = new_text
	current_position += 1

	# Force immediate display update on typing
	_update_display()
	_update_cursor_position()
	_check_completion()

func _handle_backspace(new_text: String) -> void:
	if typed_characters.length() > 0 and current_position > 0:
		typed_characters = new_text
		current_position = typed_characters.length()

		# Sync TypingEngine position when backspacing
		if TypingEngine:
			TypingEngine.current_position = current_position

		_update_display()
		_update_cursor_position()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		invisible_input.grab_focus()

# VIRTUAL FUNCTION - Override in child classes for day-specific display logic
func _update_display() -> void:
	if not text_display:
		return

	var display_text: String = ""

	# Default simple display (Day 1 style)
	for i in range(practice_text.length()):
		var character: String = practice_text[i]
		var color: String = untyped_color

		if i < typed_characters.length():
			var typed_char: String = typed_characters[i]
			if typed_char == character:
				color = typed_color
			else:
				color = error_color

		display_text += "[color=%s]%s[/color]" % [color, character]

	text_display.text = display_text

func _update_cursor_position() -> void:
	if not cursor or not text_display:
		return

	# Get the display text for cursor positioning
	var display_sentence = DayManager.get_stage_display_sentence()
	var current_position = typed_characters.length()

	# Use modular TextCursorCalculator for positioning
	var target_position = TextCursorCalculator.calculate_typing_cursor_position(
		display_sentence,
		current_position,
		text_display,
		30.0  # 30px margin
	)

	# Animate cursor to new position
	TextCursorCalculator.animate_cursor_to_position(cursor, target_position, 0.1)

func _start_cursor_blinking() -> void:
	if cursor_blinker:
		cursor_blinker.stop_blinking()

	# Use modular cursor blinker
	if cursor:
		cursor_blinker = TextCursorCalculator.CursorBlinker.new(
			cursor,
			Color(typed_color),    # Bright color
			Color(untyped_color),  # Dim color
			cursor_blink_speed
		)

func _check_completion() -> void:
	if current_position >= practice_text.length():
		_complete_stage()

## Helper function to determine if character at position is part of a corruption word
## Used by day-specific classes to determine coloring and effects
func _is_character_in_corruption_word(char_pos: int, sentence: String) -> bool:
	var words = sentence.split(" ")
	var current_pos = 0

	for word in words:
		if char_pos >= current_pos and char_pos < current_pos + word.length():
			# Character is within this word - check if it's corrupted
			# Check both corruption_mappings AND day_stage_corrupted_words
			if DayManager.corruption_mappings.has(word):
				return true

			# Also check if word is in the current day/stage corrupted words list
			var day_stages = DayManager.day_stage_corrupted_words.get(DayManager.current_day, {})
			var stage_corrupted_words = day_stages.get(DayManager.current_stage, [])
			if word in stage_corrupted_words:
				return true
		current_pos += word.length() + 1  # +1 for space

	return false

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
	# Wait for any previous message to finish typing before starting new one
	while is_typing_message:
		# Check if tree is still valid during scene transitions
		var tree = get_tree()
		if not tree:
			return
		await tree.process_frame
	_show_message(message)

# VIRTUAL FUNCTION - Override in child classes for day-specific message effects
func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Default simple message display (Day 1 style)
	message_overlay.text = message
	message_overlay.visible = true

	# Auto-hide message after 3 seconds
	await get_tree().create_timer(3.0).timeout
	message_overlay.visible = false

func _on_day_completed(day_number: int) -> void:
	if day_number == DAY_NUMBER:
		day_completed.emit()
		# Request day end screen (let 3D environment handle it)
		await get_tree().create_timer(2.0).timeout
		day_end_screen_requested.emit()

func _on_real_time_stats_updated(wmp: float, accuracy: float) -> void:
	wmp_label.text = "WPM: %.1f" % wmp
	accuracy_label.text = "Accuracy: %.1f%%" % accuracy

	var progress: float = 0.0
	if practice_text.length() > 0:
		progress = float(current_position) / float(practice_text.length())
	progress_bar.value = progress * 100
