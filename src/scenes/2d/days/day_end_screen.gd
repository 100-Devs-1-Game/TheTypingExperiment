extends Control

## Day End Screen
## Shows completion messages between days and handles day transitions

@onready var title_label: Label = %TitleLabel
@onready var message_container: VBoxContainer = %MessageContainer
@onready var continue_button: Button = %ContinueButton
@onready var background: ColorRect = %Background

var current_day: int = 1
var message_labels: Array[Label] = []

func _ready() -> void:
	current_day = DayManager.current_day
	_setup_day_end_screen()
	_setup_connections()
	_animate_messages()

func _setup_connections() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func _setup_day_end_screen() -> void:
	var day_info = DayManager.get_current_day_info()

	# Set title
	title_label.text = "Day %d Complete" % current_day

	# Set theme based on day
	_apply_day_theme()

	# Create message labels
	_create_message_labels(day_info.get("day_end_messages", []))

	# Hide continue button initially
	continue_button.visible = false

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
	continue_button.visible = true

	# Animate button appearance
	continue_button.modulate.a = 0.0
	var button_tween = create_tween()
	button_tween.tween_property(continue_button, "modulate:a", 1.0, 0.5)

	# Add pulsing effect for urgency on later days
	if current_day >= 4:
		button_tween.tween_callback(_start_button_pulse)

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
