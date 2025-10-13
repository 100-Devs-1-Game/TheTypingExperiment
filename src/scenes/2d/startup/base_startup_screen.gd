class_name BaseStartupScreen
extends Control

## Base class for all day-specific startup screens
## Contains common startup sequence logic and UI references

@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var company_logo: Label = $CenterContainer/VBoxContainer/CompanyLogo
@onready var message1: Label = $CenterContainer/VBoxContainer/Message1
@onready var message2: Label = $CenterContainer/VBoxContainer/Message2
@onready var copyright_label: Label = $CenterContainer/VBoxContainer/Copyright

# Base startup messages (can be overridden by child classes)
var startup_messages = [
	"Initializing keyboard drivers...",
	"Loading word databases...",
	"Calibrating typing metrics...",
	"Configuring user interface...",
	"Performing system checks...",
	"Starting TypingMaster Pro v2.3..."
]

var current_message_index = 0
var startup_timer: Timer

signal startup_complete

# Day-specific data (must be set by child classes)
var DAY_NUMBER: int = 1

func _ready():
	_load_day_messages()
	_setup_retro_theme()
	_apply_day_specific_setup()
	start_startup_sequence()

## Loads messages from DayManager for this day
func _load_day_messages() -> void:
	if DayManager.day_data.has(DAY_NUMBER):
		var day_info = DayManager.day_data[DAY_NUMBER]
		if day_info.has("opening_messages") and day_info.opening_messages.size() >= 2:
			message1.text = day_info.opening_messages[0]
			message2.text = day_info.opening_messages[1]

## VIRTUAL - Override in child classes for day-specific theme
func _setup_retro_theme():
	var green_color = Color(0, 1, 0)
	var amber_color = Color(1, 0.8, 0)

	company_logo.modulate = green_color
	message1.modulate = green_color
	message2.modulate = amber_color
	status_label.modulate = green_color
	copyright_label.modulate = Color(0, 0.7, 0)
	progress_bar.modulate = green_color

## VIRTUAL - Override in child classes for day-specific setup
func _apply_day_specific_setup() -> void:
	pass

func start_startup_sequence():
	startup_timer = Timer.new()
	add_child(startup_timer)
	startup_timer.timeout.connect(_update_startup_progress)

	progress_bar.value = 0
	_update_startup_progress()

func _update_startup_progress():
	if current_message_index < startup_messages.size():
		# Get the message (may be corrupted by child class)
		var message = _get_corrupted_message(startup_messages[current_message_index])
		status_label.text = message
		progress_bar.value = (float(current_message_index) / float(startup_messages.size())) * 100.0

		current_message_index += 1

		var delay = randf_range(0.8, 2.0)
		if current_message_index == 3:
			delay = randf_range(2.0, 4.0)

		startup_timer.wait_time = delay
		startup_timer.start()
	else:
		complete_startup()

## VIRTUAL - Override in child classes to apply message corruption
func _get_corrupted_message(message: String) -> String:
	return message

func complete_startup():
	status_label.text = "Ready."
	progress_bar.value = 100

	await get_tree().create_timer(1.0).timeout

	# Emit signal instead of changing scenes
	startup_complete.emit()
