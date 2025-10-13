extends Control

## Day End Screen
## Shows completion messages between days and handles day transitions

@onready var title_label: Label = %TitleLabel
@onready var message_container: VBoxContainer = %MessageContainer
@onready var background: ColorRect = %Background

var current_day: int = 1
var message_labels: Array[Label] = []
var required_code: String = ""

func _ready() -> void:
	current_day = DayManager.current_day
	_generate_code()
	_setup_day_end_screen()
	_setup_connections()
	_animate_messages()

func _setup_connections() -> void:
	pass  # No button connections needed anymore

func _generate_code() -> void:
	# Retrieve the code for the next stage from DoorManager
	# Codes are generated at scene startup in main.gd
	if current_day > 1:
		var next_stage = current_day + 1
		required_code = DoorManager.get_code_for_stage(next_stage)

		# Fallback: Generate if no code exists (shouldn't happen)
		if required_code == "":
			randomize()
			for i in range(4):
				required_code += str(randi() % 10)
			DoorManager.set_code_for_stage(next_stage, required_code)
			push_warning("[DayEndScreen] No code found for Stage %d, generated: %s" % [next_stage, required_code])

		print("[DayEndScreen] Day %d code: %s (unlocks Stage %d)" % [current_day, required_code, next_stage])

func _setup_day_end_screen() -> void:
	var day_info = DayManager.get_current_day_info()

	# Set title
	title_label.text = "Day %d Complete" % current_day

	# Set theme based on day
	_apply_day_theme()

	# Create message labels
	_create_message_labels(day_info.get("day_end_messages", []))

func _apply_day_theme() -> void:
	match current_day:
		1:
			# Clean corporate look
			title_label.modulate = Color(0, 1, 0)
			background.color = Color(0, 0, 0, 1)
		2:
			# Slight corruption hints
			title_label.modulate = Color(1, 0.8, 0.8)
			background.color = Color(0.05, 0, 0, 1)
		3:
			# Orange corruption
			title_label.modulate = Color(1, 0.7, 0.3)
			background.color = Color(0.1, 0.05, 0, 1)
		4:
			# Purple warnings
			title_label.modulate = Color(1, 0.4, 1)
			background.color = Color(0.1, 0, 0.1, 1)
		5:
			# Critical red
			title_label.modulate = Color(1, 0.2, 0.2)
			background.color = Color(0.2, 0, 0, 1)

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
		# Day 1: Show elevator message and auto-advance
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

func _show_keypad_interface() -> void:
	# Create code display label
	var code_label = Label.new()
	code_label.text = "ACCESS CODE: %s" % required_code
	code_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_label.modulate.a = 0.0
	code_label.add_theme_font_size_override("font_size", 48)

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
	code_tween.tween_interval(1.0)

	# Add instruction message
	code_tween.tween_callback(_show_keypad_instruction)

func _show_keypad_instruction() -> void:
	# Create instruction label
	var instruction_label = Label.new()
	instruction_label.text = "Find the keypad to proceed..."
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction_label.modulate.a = 0.0

	# Apply day-specific color
	match current_day:
		2: instruction_label.modulate = Color(1, 0.8, 0.8, 0)
		3: instruction_label.modulate = Color(1, 0.7, 0.3, 0)
		4: instruction_label.modulate = Color(1, 0.4, 1, 0)
		5: instruction_label.modulate = Color(1, 0.2, 0.2, 0)

	message_container.add_child(instruction_label)

	# Animate instruction appearing
	var instruction_tween = create_tween()
	instruction_tween.tween_property(instruction_label, "modulate:a", 1.0, 1.0)


func _advance_to_next_day() -> void:
	var next_day = current_day + 1

	# Transition to next day scene
	match next_day:
		2:
			get_tree().change_scene_to_file("res://scenes/2d/days/day_2.tscn")
		3:
			get_tree().change_scene_to_file("res://scenes/2d/days/day_3.tscn")
		4:
			get_tree().change_scene_to_file("res://scenes/2d/days/day_4.tscn")
		5:
			get_tree().change_scene_to_file("res://scenes/2d/days/day_5.tscn")
		_:
			# Day 5 complete - show game completion
			_handle_game_completion()

func _handle_game_completion() -> void:
	# Game complete - show final screen or return to menu

	# Could transition to:
	# - Credits scene
	# - Main menu with "Game Complete" status
	# - Ending cutscene
	# For now, return to startup
	get_tree().change_scene_to_file("res://src/scenes/2d/startup/StartupScreen.tscn")
