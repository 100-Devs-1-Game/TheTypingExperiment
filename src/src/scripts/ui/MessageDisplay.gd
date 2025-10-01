extends Control
class_name MessageDisplay

## Simple message display system for showing progress/encouragement messages

signal message_finished()

var current_label: Label
var is_showing_message: bool = false

func _ready() -> void:
	# Set up container properties for proper text wrapping
	custom_minimum_size = Vector2(400, 60)

## Shows a message with automatic text wrapping and fade animations
func show_message(message_text: String, message_type: String = "info") -> void:
	if is_showing_message:
		# If already showing a message, hide it first
		hide_current_message()
		await get_tree().process_frame

	is_showing_message = true

	# Create label for the message
	current_label = Label.new()
	current_label.text = message_text
	current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_label.clip_contents = true

	# Set size to fill the container for proper wrapping
	current_label.anchor_left = 0.0
	current_label.anchor_top = 0.0
	current_label.anchor_right = 1.0
	current_label.anchor_bottom = 1.0
	current_label.offset_left = 10
	current_label.offset_top = 10
	current_label.offset_right = -10
	current_label.offset_bottom = -10

	# Style based on message type
	match message_type:
		"opening":
			current_label.modulate = Color(0.8, 1.0, 0.8)
		"progress":
			current_label.modulate = Color(0.8, 0.8, 1.0)
		"encouragement":
			current_label.modulate = Color(1.0, 1.0, 0.8)
		"warning":
			current_label.modulate = Color(1.0, 0.8, 0.8)
		_:
			current_label.modulate = Color.WHITE

	# Start invisible
	current_label.modulate.a = 0.0

	add_child(current_label)

	# Animate the message
	_animate_message_in()

func _animate_message_in() -> void:
	visible = true

	# Fade in
	var tween = create_tween()
	tween.tween_property(current_label, "modulate:a", 1.0, 0.5)

	# Wait display duration (4 seconds)
	tween.tween_interval(4.0)

	# Fade out
	tween.tween_property(current_label, "modulate:a", 0.0, 1.0)

	# Hide and emit finished
	tween.tween_callback(_on_animation_finished)

func _on_animation_finished() -> void:
	hide_current_message()
	is_showing_message = false
	message_finished.emit()

func hide_current_message() -> void:
	if current_label:
		current_label.queue_free()
		current_label = null
	visible = false

## Check if currently showing a message
func is_displaying_message() -> bool:
	return is_showing_message
