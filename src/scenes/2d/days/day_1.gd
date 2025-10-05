extends BaseDay

## Day 1 - Corporate Normalcy
## First day of the typing practice, completely normal behavior

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 1
	corruption_color = "#00ff00"  # Green - no corruption yet
	cursor_blink_speed = 0.5
	super._ready()

func _setup_ui_theme() -> void:
	# Day 1 - Everything is normal corporate green
	var green_color = Color(0, 1, 0)
	accuracy_label.modulate = green_color
	wmp_label.modulate = green_color
	day_stage_label.modulate = green_color
	progress_label.modulate = green_color
	message_overlay.modulate = green_color

## Day 1 - Normal typewriter effect (no corruption)
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.05  # Normal typing speed for Day 1
	text_display.text = ""

	for i in range(display_sentence.length()):
		text_display.text += display_sentence[i]
		await get_tree().create_timer(typing_speed).timeout

	# Brief pause before allowing typing
	await get_tree().create_timer(0.5).timeout

# Day 1 uses the default _update_display() from base class (simple green/red display)
# Day 1 uses the default _show_message() from base class (simple message display)
