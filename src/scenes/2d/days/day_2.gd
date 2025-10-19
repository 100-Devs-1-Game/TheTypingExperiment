extends BaseDay

## Day 2 - First Cracks
## Introduction of ALL CAPS corruption mixed with normal text

# Horror effects system
var horror_effects: HorrorEffectsManager

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 2
	corruption_color = "#ff0000"  # Red for corrupted text
	use_corruption_animation = true  # Enable corruption animation

	# Setup corruption animation manager
	corruption_animation_manager = CorruptionAnimationManager.new()
	corruption_animation_manager.name = "Day2CorruptionAnimationManager"
	corruption_animation_manager.set_day(2)
	add_child(corruption_animation_manager)

	# Setup horror effects manager for Day 2
	_setup_horror_effects()

	super._ready()

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var red_tint = Color(1, 0.8, 0.8)  # Slight red tint for corruption hints

	accuracy_label.modulate = green_color
	wmp_label.modulate = green_color
	day_stage_label.modulate = red_tint  # Hint of corruption starting
	progress_label.modulate = green_color
	message_overlay.modulate = red_tint

## Day 2 - Eerie typewriter effect with first corruption
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.04  # Slightly faster, more urgent
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
		var is_corruption_char = _is_character_in_corruption_word(i, display_sentence)

		# Apply color formatting as we type
		if is_corruption_char:
			text_display.text += "[color=%s]%s[/color]" % [corruption_color, character]
		else:
			text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		await get_tree().create_timer(typing_speed).timeout

		# Dramatic pause for corruption words
		if is_corruption_char and character == " ":
			await get_tree().create_timer(0.2).timeout

	# Pause before allowing typing
	await get_tree().create_timer(0.8).timeout

func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Day 2 - Use standardized horror effects
	if horror_effects:
		await horror_effects.show_day2_style_message(message_overlay, message)
	else:
		# Fallback to basic display if horror effects not available
		message_overlay.text = message
		message_overlay.visible = true
		await get_tree().create_timer(4.0).timeout
		message_overlay.visible = false

# Setup horror effects manager for Day 2
func _setup_horror_effects() -> void:
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "Day2HorrorEffects"
	add_child(horror_effects)
