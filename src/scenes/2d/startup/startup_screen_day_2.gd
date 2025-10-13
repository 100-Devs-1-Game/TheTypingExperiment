extends BaseStartupScreen

## Day 2 - First Cracks
## Occasional CAPS corruption mixed with normal text

var corruption_animation_time: float = 0.0

func _ready() -> void:
	DAY_NUMBER = 2
	super._ready()

func _process(delta: float) -> void:
	corruption_animation_time += delta

## Day 2 - Green with subtle red tint hints
func _setup_retro_theme():
	var green_color = Color(0, 1, 0)
	var amber_color = Color(1, 0.8, 0)
	var red_tint = Color(1, 0.8, 0.8)

	company_logo.modulate = green_color
	message1.modulate = green_color
	message2.modulate = amber_color
	status_label.modulate = red_tint  # Hint of corruption
	copyright_label.modulate = Color(0, 0.7, 0)
	progress_bar.modulate = green_color

## Day 2 - Apply CAPS corruption to random words in progress messages
func _get_corrupted_message(message: String) -> String:
	var words = message.split(" ")
	var corrupted_words: PackedStringArray = []

	# Corrupt 2-3 random words in the message
	var corruption_count = 2 + randi() % 2  # 2 or 3 words
	var corrupted_indices: Array[int] = []

	# Pick random word indices to corrupt (avoid first and last word)
	for i in range(corruption_count):
		if words.size() <= 2:
			break
		var idx = 1 + randi() % (words.size() - 2)
		if idx not in corrupted_indices:
			corrupted_indices.append(idx)

	# Build corrupted message
	for i in range(words.size()):
		var word = words[i]
		if i in corrupted_indices:
			# Apply CAPS and red pulse effect
			corrupted_words.append(word.to_upper())
		else:
			corrupted_words.append(word)

	return " ".join(corrupted_words)
