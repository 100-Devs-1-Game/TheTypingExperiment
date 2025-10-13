extends Control

## Day End Screen
## Shows completion messages between days and handles day transitions

@onready var title_label: Label = %TitleLabel
@onready var message_container: VBoxContainer = %MessageContainer
@onready var background: ColorRect = %Background
@onready var day_complete_message: Label = %DayCompleteMessage
@onready var elevator_message: Label = %ElevatorMessage
@onready var keypad_instruction: Label = %KeypadInstruction
@onready var keypad_code: Label = %KeypadCode

var current_day: int = 1
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

	# Set day completion message
	var messages = day_info.get("day_end_messages", [])
	if messages.size() > 0:
		day_complete_message.text = messages[0]

func _apply_day_theme() -> void:
	var text_color: Color
	match current_day:
		1:
			# Clean corporate look
			text_color = Color(0, 1, 0)
			background.color = Color(0, 0, 0, 1)
		2:
			# Slight corruption hints
			text_color = Color(1, 0.8, 0.8)
			background.color = Color(0.05, 0, 0, 1)
		3:
			# Orange corruption
			text_color = Color(1, 0.7, 0.3)
			background.color = Color(0.1, 0.05, 0, 1)
		4:
			# Purple warnings
			text_color = Color(1, 0.4, 1)
			background.color = Color(0.1, 0, 0.1, 1)
		5:
			# Critical red
			text_color = Color(1, 0.2, 0.2)
			background.color = Color(0.2, 0, 0, 1)

	# Apply color to all labels (start invisible)
	title_label.modulate = text_color
	day_complete_message.modulate = Color(text_color.r, text_color.g, text_color.b, 0)
	elevator_message.modulate = Color(text_color.r, text_color.g, text_color.b, 0)
	keypad_instruction.modulate = Color(text_color.r, text_color.g, text_color.b, 0)
	keypad_code.modulate = Color(text_color.r, text_color.g, text_color.b, 0)

func _animate_messages() -> void:
	# Animate day completion message appearing
	var tween = create_tween()
	tween.tween_property(day_complete_message, "modulate:a", 1.0, 1.0)

	# Add corruption effect for later days
	if current_day >= 3:
		tween.tween_callback(_add_corruption_effect.bind(day_complete_message))

	# Show continue button after message
	tween.tween_interval(2.0)
	tween.tween_callback(_show_continue_button)

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
	# Set and animate elevator message
	elevator_message.text = "Session upload finished. The elevator awaits..."

	var message_tween = create_tween()
	message_tween.tween_property(elevator_message, "modulate:a", 1.0, 1.0)

func _show_keypad_interface() -> void:
	# Set and animate keypad instruction first
	keypad_instruction.text = "Find the keypad to proceed..."

	var instruction_tween = create_tween()
	instruction_tween.tween_property(keypad_instruction, "modulate:a", 1.0, 1.0)
	instruction_tween.tween_interval(1.0)

	# Then show code after delay
	instruction_tween.tween_callback(_show_keypad_code)

func _show_keypad_code() -> void:
	# Set and animate keypad code
	keypad_code.text = "ACCESS CODE: %s" % required_code

	var code_tween = create_tween()
	code_tween.tween_property(keypad_code, "modulate:a", 1.0, 1.0)


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
