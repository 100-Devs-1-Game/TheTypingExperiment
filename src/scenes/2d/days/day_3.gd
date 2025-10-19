extends BaseDay

## Day 3 - Breaking Down
## Unicode glitch corruption with victim messages
@onready var progress_bar_label: Label = %ProgressBarLabel

# Horror effects system
var horror_effects: HorrorEffectsManager

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 3
	corruption_color = "#ff6600"  # Orange for unicode corruption
	use_corruption_animation = true  # Enable corruption animation

	# Setup corruption animation manager
	corruption_animation_manager = CorruptionAnimationManager.new()
	corruption_animation_manager.name = "Day3CorruptionAnimationManager"
	corruption_animation_manager.set_day(3)
	add_child(corruption_animation_manager)

	# Setup horror effects manager for Day 3
	_setup_horror_effects()

	super._ready()

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var orange_tint = Color(1, 0.7, 0.3)  # Orange corruption hints

	accuracy_label.modulate = green_color
	wmp_label.modulate = orange_tint  # Corruption affecting stats
	day_stage_label.modulate = orange_tint
	progress_label.modulate = green_color
	message_overlay.modulate = orange_tint
	progress_bar_label.modulate = green_color

## Day 3 - Unicode corruption typewriter effect
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.04
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
			await get_tree().create_timer(0.3).timeout

	# Pause before allowing typing
	await get_tree().create_timer(0.8).timeout

	# Initialize custom progress display after typewriter effect
	_update_progress_display()

## Override _update_display to include custom progress bar update
func _update_display() -> void:
	super._update_display()
	_update_progress_display()

## Day 3 - Override progress display to use text-based progress bar
func _update_progress_display() -> void:
	if not progress_bar or not progress_label:
		return

	# Calculate typing progress within current stage
	var progress: float = 0.0
	if practice_text.length() > 0:
		progress = float(current_position) / float(practice_text.length())

	# Hide the original progress bar
	progress_bar.visible = false

	# Create text progress bar for current stage typing progress
	var total_blocks = 10
	var filled_blocks = int(progress * total_blocks)
	var empty_blocks = total_blocks - filled_blocks

	var progress_text = ""
	# Add filled blocks (▓)
	for i in range(filled_blocks):
		progress_text += "▓"
	# Add empty blocks (░)
	for i in range(empty_blocks):
		progress_text += "░"

	# Update label with stage info and text progress bar
	progress_label.text = "Stage %d of %d" % [DayManager.current_stage, DayManager.stages_per_day]
	progress_bar_label.text = progress_text

func _show_message(message: String) -> void:
	# Check if we're still in a valid scene
	if not get_tree() or not message_overlay:
		return

	# Day 3 - Use standardized horror effects
	if horror_effects:
		await horror_effects.show_day3_style_message(message_overlay, message)
	else:
		# Fallback to basic display if horror effects not available
		message_overlay.text = message
		message_overlay.visible = true
		await get_tree().create_timer(5.0).timeout
		message_overlay.visible = false

# Setup horror effects manager for Day 3
func _setup_horror_effects() -> void:
	horror_effects = HorrorEffectsManager.new()
	horror_effects.name = "Day3HorrorEffects"
	add_child(horror_effects)
