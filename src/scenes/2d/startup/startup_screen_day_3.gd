extends BaseStartupScreen

## Day 3 - Breaking Down
## Unicode glitch corruption with flickering effects

var corruption_animation_time: float = 0.0
var flicker_timer: float = 0.0

func _ready() -> void:
	DAY_NUMBER = 3
	super._ready()
	# Corrupt company name
	company_logo.text = "Çøğńïţïṿë Ðÿńąɱïçş"

func _process(delta: float) -> void:
	corruption_animation_time += delta
	flicker_timer += delta

	# Flickering effect on company logo and corrupted text
	if flicker_timer >= 0.15:
		flicker_timer = 0.0
		if randf() < 0.3:  # 30% chance to flicker
			var flicker_alpha = randf_range(0.7, 1.0)
			company_logo.modulate.a = flicker_alpha
			status_label.modulate.a = flicker_alpha
		else:
			company_logo.modulate.a = 1.0
			status_label.modulate.a = 1.0

## Day 3 - Orange/amber terminal theme
func _setup_retro_theme():
	var green_color = Color(0, 1, 0)
	var orange_tint = Color(1, 0.7, 0.3)
	var amber_color = Color(1, 0.8, 0)

	company_logo.modulate = orange_tint
	message1.modulate = green_color
	message2.modulate = amber_color
	status_label.modulate = orange_tint
	copyright_label.modulate = Color(0, 0.7, 0)
	progress_bar.modulate = orange_tint

func _apply_day_specific_setup() -> void:
	# Apply light unicode corruption to message1 and message2
	message1.text = _apply_light_unicode_corruption(message1.text)
	message2.text = _apply_light_unicode_corruption(message2.text)

## Day 3 - Apply unicode corruption to random words
func _get_corrupted_message(message: String) -> String:
	var words = message.split(" ")
	var corrupted_words: PackedStringArray = []

	# Corrupt 3-4 random words
	var corruption_count = 3 + randi() % 2  # 3 or 4 words
	var corrupted_indices: Array[int] = []

	# Pick random word indices to corrupt
	for i in range(corruption_count):
		if words.size() <= 2:
			break
		var idx = randi() % words.size()
		if idx not in corrupted_indices:
			corrupted_indices.append(idx)

	# Build corrupted message
	for i in range(words.size()):
		var word = words[i]
		if i in corrupted_indices and word.length() > 2:
			corrupted_words.append(_corrupt_word_unicode(word))
		else:
			corrupted_words.append(word)

	return " ".join(corrupted_words)

## Apply light corruption (1-2 characters) to messages
func _apply_light_unicode_corruption(text: String) -> String:
	var corruption_chars = ["ţ", "ř", "ą", "ë", "ł", "ń", "đ", "ş", "ž", "ć", "ų", "ň", "ď", "ľ", "ï", "ø", "ÿ"]
	var words = text.split(" ")
	var corrupted_words: PackedStringArray = []

	for word in words:
		if word.length() > 4 and randf() < 0.3:  # 30% chance for longer words
			var char_pos = randi() % word.length()
			var corrupted = word.substr(0, char_pos) + corruption_chars[randi() % corruption_chars.size()] + word.substr(char_pos + 1)
			corrupted_words.append(corrupted)
		else:
			corrupted_words.append(word)

	return " ".join(corrupted_words)

## Corrupt a word with unicode characters
func _corrupt_word_unicode(word: String) -> String:
	var corruption_chars = ["ţ", "ř", "ą", "ë", "ł", "ń", "đ", "ş", "ž", "ć", "ų", "ň", "ď", "ľ", "ï", "ø", "ÿ", "ğ", "ƒ", "ԁ"]
	var corrupted = ""

	# Corrupt 40-60% of characters
	for i in range(word.length()):
		if randf() < 0.5 and i != 0 and i != word.length() - 1:  # Keep first/last char
			corrupted += corruption_chars[randi() % corruption_chars.size()]
		else:
			corrupted += word[i]

	return corrupted
