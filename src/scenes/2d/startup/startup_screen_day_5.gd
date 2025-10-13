extends BaseStartupScreen

## Day 5 - System Collapse
## Maximum chaos with symbol corruption, screen flicker, and unstable progress

var corruption_animation_time: float = 0.0
var flicker_timer: float = 0.0
var chaos_timer: float = 0.0
var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "■", "□", "▪", "▫", "◆", "◇", "●", "○"]

# Progress bar chaos
var progress_direction: int = 1  # 1 = forward, -1 = backward

func _ready() -> void:
	DAY_NUMBER = 5
	super._ready()
	# Corrupt company name heavily
	company_logo.text = "¢Ωğńï†ïṿ€ Ð¥ń∀ɱïç§"

func _process(delta: float) -> void:
	corruption_animation_time += delta
	flicker_timer += delta
	chaos_timer += delta

	# Screen flicker effect - more intense
	if flicker_timer >= 0.08:
		flicker_timer = 0.0
		if randf() < 0.5:  # 50% chance to flicker
			_apply_screen_flicker()

	# Random chaos effects
	if chaos_timer >= 0.3:
		chaos_timer = 0.0
		_apply_chaos_effect()

## Day 5 - Critical red-orange theme
func _setup_retro_theme():
	var red_tint = Color(1, 0.3, 0.2)
	var warning_red = Color(1, 0.2, 0.2)
	var orange = Color(1, 0.5, 0)

	company_logo.modulate = red_tint
	message1.modulate = warning_red
	message2.modulate = red_tint
	status_label.modulate = red_tint
	copyright_label.modulate = warning_red
	progress_bar.modulate = red_tint

func _apply_day_specific_setup() -> void:
	# Corrupt all text heavily
	message1.text = _apply_heavy_symbol_corruption(message1.text)
	message2.text = _apply_heavy_symbol_corruption(message2.text)
	copyright_label.text = _apply_heavy_symbol_corruption(copyright_label.text)

## Day 5 - Apply heavy symbol corruption to all messages
func _get_corrupted_message(message: String) -> String:
	var words = message.split(" ")
	var corrupted_words: PackedStringArray = []

	# Corrupt 4-5 random words heavily
	var corruption_count = 4 + randi() % 2  # 4 or 5 words
	var corrupted_indices: Array[int] = []

	# Pick random word indices to corrupt
	for i in range(corruption_count):
		if words.size() == 0:
			break
		var idx = randi() % words.size()
		if idx not in corrupted_indices:
			corrupted_indices.append(idx)

	# Build corrupted message with random ERROR/CRITICAL insertions
	for i in range(words.size()):
		var word = words[i]
		if i in corrupted_indices and word.length() > 2:
			corrupted_words.append(_corrupt_word_symbols(word))
		else:
			corrupted_words.append(word)

		# Random ERROR/CRITICAL insertions
		if randf() < 0.15:  # 15% chance
			var warnings = ["ERROR", "CRITICAL", "FAIL", "!!!"]
			corrupted_words.append(warnings[randi() % warnings.size()])

	return " ".join(corrupted_words)

## Apply heavy symbol corruption to text
func _apply_heavy_symbol_corruption(text: String) -> String:
	var symbols = ["∂", "Ω", "η", "†", "¢", "µ", "π", "λ", "€", "ℏ", "¡", "§", "¥", "ω", "∀", "®", "¶", "κ", "ƒ", "√", "υ"]
	var words = text.split(" ")
	var corrupted_words: PackedStringArray = []

	for word in words:
		if word.length() > 2 and randf() < 0.6:  # 60% corruption chance
			corrupted_words.append(_corrupt_word_symbols(word))
		else:
			corrupted_words.append(word)

	return " ".join(corrupted_words)

## Corrupt a word with symbols
func _corrupt_word_symbols(word: String) -> String:
	var symbols = ["∂", "Ω", "η", "†", "¢", "µ", "π", "λ", "€", "ℏ", "¡", "§", "¥", "ω", "∀", "®", "¶", "κ", "ƒ", "√", "υ"]
	var corrupted = ""

	# Corrupt 60-80% of characters
	for i in range(word.length()):
		if randf() < 0.7:
			corrupted += symbols[randi() % symbols.size()]
		else:
			corrupted += word[i]

	return corrupted

## Apply screen flicker effect
func _apply_screen_flicker() -> void:
	var flicker_intensity = randf_range(0.3, 1.0)

	company_logo.modulate.a = flicker_intensity
	message1.modulate.a = flicker_intensity
	message2.modulate.a = flicker_intensity
	status_label.modulate.a = flicker_intensity
	copyright_label.modulate.a = flicker_intensity

	# Reset after short delay
	await get_tree().create_timer(0.05).timeout
	if company_logo:
		company_logo.modulate.a = 1.0
		message1.modulate.a = 1.0
		message2.modulate.a = 1.0
		status_label.modulate.a = 1.0
		copyright_label.modulate.a = 1.0

## Apply random chaos effects
func _apply_chaos_effect() -> void:
	var effect_choice = randi() % 3

	match effect_choice:
		0:  # Progress bar jumps backward
			if progress_bar and randf() < 0.4:
				var jump_back = randf_range(5.0, 15.0)
				progress_bar.value = max(0, progress_bar.value - jump_back)
		1:  # Random glitch characters appear in labels
			if randf() < 0.5 and status_label:
				var original = status_label.text
				var glitch = glitch_chars[randi() % glitch_chars.size()]
				status_label.text = original + " " + glitch + glitch + glitch
				await get_tree().create_timer(0.15).timeout
				if status_label:
					status_label.text = original
		2:  # Company logo corruption intensifies
			if randf() < 0.3 and company_logo:
				var temp_corrupt = _corrupt_word_symbols("CognitiveDynamics")
				var original = company_logo.text
				company_logo.text = temp_corrupt
				await get_tree().create_timer(0.2).timeout
				if company_logo:
					company_logo.text = original

## Override complete_startup for Day 5 chaos
func complete_startup():
	# Day 5 - Unstable completion message
	var completion_messages = [
		"Ready.",
		"SYSTEM CRITICAL",
		"ERROR: Ready.",
		"§†∀®†ïńğ...",
		"¢®ï†ï¢∀λ €®®Ω®"
	]
	status_label.text = completion_messages[randi() % completion_messages.size()]
	progress_bar.value = 100

	# Flicker violently before completion
	for i in range(5):
		await get_tree().create_timer(0.1).timeout
		_apply_screen_flicker()

	await get_tree().create_timer(1.0).timeout

	# Emit signal
	startup_complete.emit()
