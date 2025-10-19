extends BaseDay

## Day 5 - Final Day: System Collapse
## Symbol corruption with critical system failure

# Horror effects system
var horror_effects: HorrorEffectsManager

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 5
	corruption_color = "#ff4400"  # Red-orange for critical system failure
	use_corruption_animation = true  # Enable corruption animation

	# Setup corruption animation manager
	corruption_animation_manager = CorruptionAnimationManager.new()
	corruption_animation_manager.name = "Day5CorruptionAnimationManager"
	corruption_animation_manager.set_day(5)
	add_child(corruption_animation_manager)

	# Setup horror effects manager for Day 5
	_setup_horror_effects()

	super._ready()

func _setup_ui_theme() -> void:
	var red_tint = Color(1, 0.3, 0.2)  # Red-orange critical color
	var warning_red = Color(1, 0.2, 0.2)  # Bright red for critical warnings

	accuracy_label.modulate = warning_red  # System critical
	wmp_label.modulate = red_tint  # Maximum corruption
	day_stage_label.modulate = red_tint
	progress_label.modulate = warning_red
	message_overlay.modulate = red_tint

## Day 5 - Symbol corruption typewriter effect with system collapse
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.02  # Fastest, most erratic typing
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
		var is_corruption_char = _is_character_in_corruption_word(i, display_sentence)

		# Apply color formatting as we type
		if is_corruption_char:
			text_display.text += "[color=%s]%s[/color]" % [corruption_color, character]
		else:
			text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		# Extreme speed variation - system collapsing
		var speed_variation = randf() * 0.03  # 0-0.03 second variation
		await get_tree().create_timer(typing_speed + speed_variation).timeout

		# Dramatic pause for corruption words - system struggling to display
		if is_corruption_char and character == " ":
			await get_tree().create_timer(0.5).timeout

	# Longer pause before allowing typing - system on brink of failure
	await get_tree().create_timer(1.2).timeout

func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Day 5 - Use standardized horror effects
	if horror_effects:
		await horror_effects.show_day5_style_message(message_overlay, message)
	else:
		# Fallback to basic display if horror effects not available
		message_overlay.text = message
		message_overlay.visible = true
		await get_tree().create_timer(5.0).timeout
		message_overlay.visible = false

# Setup horror effects manager for Day 5
func _setup_horror_effects() -> void:
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "Day5HorrorEffects"
	add_child(horror_effects)
