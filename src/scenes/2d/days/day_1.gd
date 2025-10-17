extends BaseDay

## Day 1 - Corporate Normalcy
## First day of the typing practice, completely normal behavior

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 1
	corruption_color = "#00ff00"  # Green - no corruption yet
	super._ready()

func _setup_ui_theme() -> void:
	# Day 1 - Everything is normal corporate green
	var green_color = Color(0, 1, 0)
	accuracy_label.modulate = green_color
	wmp_label.modulate = green_color
	day_stage_label.modulate = green_color
	progress_label.modulate = green_color
	message_overlay.modulate = green_color

# Day 1 uses the default _update_display() from base class (simple green/red display)
# Day 1 uses the default _show_message() from base class (simple message display)
