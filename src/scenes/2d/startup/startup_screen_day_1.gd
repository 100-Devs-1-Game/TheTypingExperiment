extends BaseStartupScreen

## Day 1 - Corporate Normalcy
## Clean, professional startup with no corruption

func _ready() -> void:
	DAY_NUMBER = 1
	super._ready()

## Day 1 - Clean corporate green theme
func _setup_retro_theme():
	var green_color = Color(0, 1, 0)
	var amber_color = Color(1, 0.8, 0)

	company_logo.modulate = green_color
	message1.modulate = green_color
	message2.modulate = amber_color
	status_label.modulate = green_color
	copyright_label.modulate = Color(0, 0.7, 0)
	progress_bar.modulate = green_color

## Day 1 - No corruption, everything normal
func _get_corrupted_message(message: String) -> String:
	return message
