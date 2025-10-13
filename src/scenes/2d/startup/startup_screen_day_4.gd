extends BaseStartupScreen

## Day 4 - System Warning
## Reversed words + glitch blocks with purple theme

var corruption_animation_time: float = 0.0
var glitch_timer: float = 0.0
var glitch_blocks = ["█", "▓", "▒", "░", "▄", "▀"]

func _ready() -> void:
	DAY_NUMBER = 4
	super._ready()

func _process(delta: float) -> void:
	corruption_animation_time += delta
	glitch_timer += delta

	# Random glitch blocks appearing/disappearing in progress bar area
	if glitch_timer >= 0.25:
		glitch_timer = 0.0
		if randf() < 0.4:  # 40% chance
			_show_glitch_blocks()

## Day 4 - Purple terminal theme with warning hints
func _setup_retro_theme():
	var green_color = Color(0, 1, 0)
	var purple_tint = Color(0.8, 0.4, 0.8)
	var warning_red = Color(1, 0.6, 0.6)

	company_logo.modulate = purple_tint
	message1.modulate = green_color
	message2.modulate = purple_tint
	status_label.modulate = purple_tint
	copyright_label.modulate = purple_tint
	progress_bar.modulate = purple_tint

func _apply_day_specific_setup() -> void:
	# Reverse copyright year: 1994 -> 4991
	copyright_label.text = "© 4991 Cognitive Dynamics Inc."
	# Apply partial reversal to message2
	message2.text = _apply_partial_reversal(message2.text)

## Day 4 - Apply reversed words + glitch blocks
func _get_corrupted_message(message: String) -> String:
	var words = message.split(" ")
	var corrupted_words: PackedStringArray = []

	# Reverse 2-3 random words
	var reversal_count = 2 + randi() % 2  # 2 or 3 words
	var reversed_indices: Array[int] = []

	# Pick random word indices to reverse
	for i in range(reversal_count):
		if words.size() <= 2:
			break
		var idx = randi() % words.size()
		if idx not in reversed_indices:
			reversed_indices.append(idx)

	# Build corrupted message
	for i in range(words.size()):
		var word = words[i]
		if i in reversed_indices and word.length() > 2:
			# Reverse the word
			var reversed = ""
			for j in range(word.length() - 1, -1, -1):
				reversed += word[j]
			corrupted_words.append(reversed)
		else:
			corrupted_words.append(word)

	return " ".join(corrupted_words)

## Apply partial reversal to text (reverse 1-2 words)
func _apply_partial_reversal(text: String) -> String:
	var words = text.split(" ")
	var corrupted_words: PackedStringArray = []

	for word in words:
		if word.length() > 4 and randf() < 0.25:  # 25% chance for longer words
			var reversed = ""
			for j in range(word.length() - 1, -1, -1):
				reversed += word[j]
			corrupted_words.append(reversed)
		else:
			corrupted_words.append(word)

	return " ".join(corrupted_words)

## Show random glitch blocks in progress bar
func _show_glitch_blocks() -> void:
	var glitch_text = ""
	for i in range(3):
		glitch_text += glitch_blocks[randi() % glitch_blocks.size()]

	# Temporarily add glitch to status label
	if status_label and randf() < 0.5:
		var original_text = status_label.text
		status_label.text = original_text + " " + glitch_text
		await get_tree().create_timer(0.1).timeout
		if status_label:
			status_label.text = original_text
