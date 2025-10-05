extends Control

@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var company_logo: Label = $CenterContainer/VBoxContainer/CompanyLogo
@onready var product_name: Label = $CenterContainer/VBoxContainer/ProductName
@onready var subtitle: Label = $CenterContainer/VBoxContainer/Subtitle
@onready var copyright_label: Label = $CenterContainer/VBoxContainer/Copyright

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

func _ready():
	setup_retro_theme()
	start_startup_sequence()

func setup_retro_theme():
	var green_color = Color(0, 1, 0)
	var amber_color = Color(1, 0.8, 0)

	company_logo.modulate = green_color
	product_name.modulate = green_color
	subtitle.modulate = amber_color
	status_label.modulate = green_color
	copyright_label.modulate = Color(0, 0.7, 0)

	progress_bar.modulate = green_color

func start_startup_sequence():
	startup_timer = Timer.new()
	add_child(startup_timer)
	startup_timer.timeout.connect(_update_startup_progress)

	progress_bar.value = 0
	_update_startup_progress()

func _update_startup_progress():
	if current_message_index < startup_messages.size():
		status_label.text = startup_messages[current_message_index]
		progress_bar.value = (float(current_message_index) / float(startup_messages.size())) * 100.0

		current_message_index += 1

		var delay = randf_range(0.8, 2.0)
		if current_message_index == 3:
			delay = randf_range(2.0, 4.0)

		startup_timer.wait_time = delay
		startup_timer.start()
	else:
		complete_startup()

func complete_startup():
	status_label.text = "Ready."
	progress_bar.value = 100

	await get_tree().create_timer(1.0).timeout

	# Emit signal instead of changing scenes
	startup_complete.emit()
