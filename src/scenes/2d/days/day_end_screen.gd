extends Control

## Day End Screen
## Shows completion messages between days and handles day transitions

@onready var title_label: Label = %TitleLabel
@onready var message_container: VBoxContainer = %MessageContainer
@onready var continue_button: Button = %ContinueButton
@onready var background: ColorRect = %Background
@onready var keypad_container: Control = %KeypadContainer

var current_day: int = 1
var message_labels: Array[Label] = []
var current_code: String = ""
var required_code: String = ""

# Preload keypad scene
const KeypadScene = preload("res://scenes/2d/keypad/keypad_input.tscn")

func _ready() -> void:
	current_day = DayManager.current_day
	_generate_code()
	_setup_day_end_screen()
	_setup_connections()
	_animate_messages()

func _setup_connections() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func _generate_code() -> void:
	# Generate a random 4-digit code for days 2-5
	if current_day > 1:
		randomize()
		required_code = ""
		for i in range(4):
			required_code += str(randi() % 10)
		print("Day %d code: %s" % [current_day, required_code])  # Debug output

func _setup_day_end_screen() -> void:
	var day_info = DayManager.get_current_day_info()

	# Set title
	title_label.text = "Day %d Complete" % current_day

	# Set theme based on day
	_apply_day_theme()

	# Create message labels
	_create_message_labels(day_info.get("day_end_messages", []))

	# Hide continue button and keypad initially
	continue_button.visible = false
	if keypad_container:
		keypad_container.visible = false

func _apply_day_theme() -> void:
	match current_day:
		1:
			# Clean corporate look
			title_label.modulate = Color(0, 1, 0)
			background.color = Color(0, 0, 0, 1)
			continue_button.modulate = Color(0, 1, 0)
		2:
			# Slight corruption hints
			title_label.modulate = Color(1, 0.8, 0.8)
			background.color = Color(0.05, 0, 0, 1)
			continue_button.modulate = Color(1, 0.8, 0.8)
		3:
			# Orange corruption
			title_label.modulate = Color(1, 0.7, 0.3)
			background.color = Color(0.1, 0.05, 0, 1)
			continue_button.modulate = Color(1, 0.7, 0.3)
		4:
			# Purple warnings
			title_label.modulate = Color(1, 0.4, 1)
			background.color = Color(0.1, 0, 0.1, 1)
			continue_button.modulate = Color(1, 0.4, 1)
		5:
			# Critical red
			title_label.modulate = Color(1, 0.2, 0.2)
			background.color = Color(0.2, 0, 0, 1)
			continue_button.modulate = Color(1, 0.2, 0.2)
			continue_button.text = "ESCAPE" if current_day == 5 else "Continue"

func _create_message_labels(messages: Array) -> void:
	# Clear existing message labels
	for child in message_container.get_children():
		child.queue_free()

	message_labels.clear()

	# Create new labels for each message
	for message in messages:
		var label = Label.new()
		label.text = message
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.modulate.a = 0.0  # Start invisible for animation

		# Apply day-specific styling
		match current_day:
			1:
				label.modulate = Color(0, 1, 0, 0)
			2:
				label.modulate = Color(1, 0.8, 0.8, 0)
			3:
				label.modulate = Color(1, 0.7, 0.3, 0)
			4:
				label.modulate = Color(1, 0.4, 1, 0)
			5:
				label.modulate = Color(1, 0.2, 0.2, 0)

		message_container.add_child(label)
		message_labels.append(label)

func _animate_messages() -> void:
	# Animate messages appearing one by one
	for i in range(message_labels.size()):
		var label = message_labels[i]
		var delay = i * 1.5  # 1.5 seconds between messages

		# Create tween for fade in
		var tween = create_tween()
		tween.tween_interval(delay)
		tween.tween_property(label, "modulate:a", 1.0, 1.0)

		# Add typing sound effect or screen flicker if needed
		if current_day >= 3:
			tween.tween_callback(_add_corruption_effect.bind(label))

	# Show continue button after all messages
	var final_delay = message_labels.size() * 1.5 + 2.0
	var button_tween = create_tween()
	button_tween.tween_interval(final_delay)
	button_tween.tween_callback(_show_continue_button)

func _add_corruption_effect(label: Label) -> void:
	# Add subtle corruption effects for later days
	if current_day >= 4:
		# Briefly flicker the label
		var flicker_tween = create_tween()
		flicker_tween.tween_property(label, "modulate:a", 0.3, 0.1)
		flicker_tween.tween_property(label, "modulate:a", 1.0, 0.1)

func _show_continue_button() -> void:
	if current_day == 1:
		# Day 1: Show elevator message with continue button
		_show_day_1_message()
	else:
		# Days 2-5: Show keypad with code
		_show_keypad_interface()

func _show_day_1_message() -> void:
	# Create elevator message label
	var elevator_label = Label.new()
	elevator_label.text = "Session upload finished. The elevator awaits..."
	elevator_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elevator_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	elevator_label.modulate = Color(0, 1, 0, 0)  # Start invisible

	message_container.add_child(elevator_label)

	# Animate the message appearing
	var message_tween = create_tween()
	message_tween.tween_property(elevator_label, "modulate:a", 1.0, 1.0)
	message_tween.tween_interval(1.0)
	message_tween.tween_callback(_show_day_1_continue_button)

func _show_day_1_continue_button() -> void:
	continue_button.visible = true
	continue_button.text = "Enter Elevator"

	# Animate button appearance
	continue_button.modulate.a = 0.0
	var button_tween = create_tween()
	button_tween.tween_property(continue_button, "modulate:a", 1.0, 0.5)

func _show_keypad_interface() -> void:
	if not keypad_container:
		push_error("KeypadContainer not found!")
		return

	# Create code display label
	var code_label = Label.new()
	code_label.text = "ACCESS CODE: %s" % required_code
	code_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_label.modulate.a = 0.0

	# Apply day-specific color
	match current_day:
		2: code_label.modulate = Color(1, 0.8, 0.8, 0)
		3: code_label.modulate = Color(1, 0.7, 0.3, 0)
		4: code_label.modulate = Color(1, 0.4, 1, 0)
		5: code_label.modulate = Color(1, 0.2, 0.2, 0)

	message_container.add_child(code_label)

	# Animate code display
	var code_tween = create_tween()
	code_tween.tween_property(code_label, "modulate:a", 1.0, 1.0)
	code_tween.tween_interval(1.5)
	code_tween.tween_callback(_show_keypad)

func _show_keypad() -> void:
	if not keypad_container:
		return

	# Instance and setup keypad
	var keypad = KeypadScene.instantiate()
	keypad_container.add_child(keypad)

	# Connect keypad signals
	if keypad.has_signal("code_entered"):
		keypad.code_entered.connect(_on_keypad_code_entered)

	# Show keypad container
	keypad_container.visible = true
	keypad_container.modulate.a = 0.0

	var keypad_tween = create_tween()
	keypad_tween.tween_property(keypad_container, "modulate:a", 1.0, 0.5)

func _on_keypad_code_entered(entered_code: String) -> void:
	if entered_code == required_code:
		# Correct code - advance to next day
		_advance_to_next_day()
	else:
		# Wrong code - show error feedback
		_show_code_error()

func _show_code_error() -> void:
	# Flash the keypad red briefly
	var error_tween = create_tween()
	error_tween.tween_property(keypad_container, "modulate", Color(1, 0, 0, 1), 0.1)
	error_tween.tween_property(keypad_container, "modulate", Color(1, 1, 1, 1), 0.1)
	error_tween.tween_property(keypad_container, "modulate", Color(1, 0, 0, 1), 0.1)
	error_tween.tween_property(keypad_container, "modulate", Color(1, 1, 1, 1), 0.1)

	# Reset the keypad
	if keypad_container.get_child_count() > 0:
		var keypad = keypad_container.get_child(0)
		if keypad.has_method("clear_code"):
			keypad.clear_code()

func _start_button_pulse() -> void:
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(continue_button, "modulate:a", 0.6, 0.5)
	pulse_tween.tween_property(continue_button, "modulate:a", 1.0, 0.5)

func _on_continue_pressed() -> void:
	# Determine next action based on current day
	if current_day >= 5:
		# End of game - could show credits or return to main menu
		_handle_game_completion()
	else:
		# Advance to next day
		_advance_to_next_day()

func _advance_to_next_day() -> void:
	var next_day = current_day + 1

	# Transition to next day scene (only Day 2 exists currently)
	match next_day:
		2:
			get_tree().change_scene_to_file("res://scenes/2d/days/day_2.tscn")
		_:
			# Days 3-5 scenes don't exist yet, handle completion
			_handle_game_completion()

func _handle_game_completion() -> void:
	# Game complete - show final screen or return to menu

	# Could transition to:
	# - Credits scene
	# - Main menu with "Game Complete" status
	# - Ending cutscene
	# For now, return to startup
	get_tree().change_scene_to_file("res://src/scenes/2d/startup/StartupScreen.tscn")

func _input(event: InputEvent) -> void:
	# Allow Enter/Space to continue when button is visible
	if event is InputEventKey and event.pressed and continue_button.visible:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_on_continue_pressed()
