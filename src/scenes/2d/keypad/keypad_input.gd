extends Control

## Keypad input screen for 8-digit code entry

signal code_entered(code: String)
signal code_changed(current_code: String)

@onready var input_display: Label = %InputDisplay

const MAX_DIGITS = 8
const GREEN_COLOR = Color(0, 1, 0)

var current_code: String = ""

func _ready() -> void:
	# Apply green color to labels
	input_display.modulate = GREEN_COLOR

	_update_display()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return

	var key_event = event as InputEventKey

	# Handle backspace
	if key_event.keycode == KEY_BACKSPACE:
		if current_code.length() > 0:
			current_code = current_code.substr(0, current_code.length() - 1)
			_update_display()
			code_changed.emit(current_code)
		get_viewport().set_input_as_handled()
		return

	# Handle numeric input (regular numbers and numpad)
	var digit = ""
	match key_event.keycode:
		KEY_0, KEY_KP_0: digit = "0"
		KEY_1, KEY_KP_1: digit = "1"
		KEY_2, KEY_KP_2: digit = "2"
		KEY_3, KEY_KP_3: digit = "3"
		KEY_4, KEY_KP_4: digit = "4"
		KEY_5, KEY_KP_5: digit = "5"
		KEY_6, KEY_KP_6: digit = "6"
		KEY_7, KEY_KP_7: digit = "7"
		KEY_8, KEY_KP_8: digit = "8"
		KEY_9, KEY_KP_9: digit = "9"

	if digit != "" and current_code.length() < MAX_DIGITS:
		current_code += digit
		_update_display()
		code_changed.emit(current_code)

		# Auto-submit when 8 digits entered
		if current_code.length() == MAX_DIGITS:
			_submit_code()

		get_viewport().set_input_as_handled()

func _update_display() -> void:
	# Show current code with underscores for remaining digits
	var display_text = current_code
	var remaining = MAX_DIGITS - current_code.length()
	for i in range(remaining):
		display_text += "_"

	input_display.text = display_text

func _submit_code() -> void:
	code_entered.emit(current_code)
	# Could add feedback here (success/error)

func clear_code() -> void:
	current_code = ""
	_update_display()
