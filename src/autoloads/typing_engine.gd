extends Node

## Core typing logic engine
## Handles keystroke validation, WPM/accuracy calculation, and corruption support

signal real_time_stats_updated(wpm: float, accuracy: float)


# Dual text system for corruption support
var current_text: String = ""  # Original text for validation
var display_text: String = ""  # Corrupted text for display
var corruption_map: Array[bool] = []  # Tracks which words are corrupted
var current_position: int = 0
var last_keystroke_time: float = 0.0

# Real-time calculation variables
var session_start_time: float = 0.0
var total_keystrokes: int = 0
var correct_keystrokes: int = 0
var calculation_interval: float = 1.0  # Update every second
var last_calculation_time: float = 0.0

# Current session metrics
var smoothed_wpm: float = 0.0
var current_accuracy: float = 100.0

func _process(_delta: float) -> void:
	var current_time: float = Time.get_unix_time_from_system()

	if session_start_time > 0 and current_time - last_calculation_time >= calculation_interval:
		_calculate_real_time_metrics()
		last_calculation_time = current_time

func generate_practice_text(word_count: int = 20) -> String:
	# Use simple word list for now instead of complex generation
	var words: Array[String] = [
		"the", "and", "for", "are", "but", "not", "you", "all", "can", "had",
		"her", "was", "one", "our", "out", "day", "get", "has", "him", "his",
		"how", "its", "may", "new", "now", "old", "see", "two", "who", "boy",
		"did", "let", "man", "put", "say", "she", "too", "use", "way", "will",
		"about", "after", "again", "along", "among", "being", "below", "could",
		"every", "first", "found", "great", "group", "house", "large", "might",
		"never", "other", "place", "right", "small", "sound", "still", "such",
		"these", "think", "three", "under", "water", "where", "while", "world",
		"would", "write", "years", "young"
	]

	var generated_words: Array[String] = []
	for i in word_count:
		generated_words.append(words[randi() % words.size()])

	# Apply corruption if CorruptionManager is available
	if CorruptionManager and CorruptionManager.corruption_enabled:
		var corruption_data = _apply_corruption_to_words(generated_words)
		current_text = corruption_data.original_text
		display_text = corruption_data.display_text
		corruption_map = corruption_data.corruption_map
	else:
		current_text = " ".join(generated_words)
		display_text = current_text
		corruption_map = []
		for i in generated_words.size():
			corruption_map.append(false)

	current_position = 0
	return current_text

## Apply corruption to word list and return dual text data
func _apply_corruption_to_words(words: Array[String]) -> Dictionary:
	var original_words: Array[String] = words.duplicate()
	var display_words: Array[String] = []
	var word_corruption_map: Array[bool] = []

	for word in words:
		if CorruptionManager.should_corrupt_word():
			var corrupted_word: String = CorruptionManager.corrupt_entire_word(word)
			display_words.append(corrupted_word)
			word_corruption_map.append(true)
		else:
			display_words.append(word)
			word_corruption_map.append(false)

	return {
		"original_text": " ".join(original_words),
		"display_text": " ".join(display_words),
		"corruption_map": word_corruption_map
	}

func _calculate_real_time_metrics() -> void:
	if total_keystrokes == 0:
		return

	var current_time: float = Time.get_unix_time_from_system()
	var time_elapsed: float = current_time - session_start_time

	if time_elapsed <= 0:
		return

	# Calculate instantaneous WPM
	var chars_per_minute: float = (float(correct_keystrokes) / time_elapsed) * 60.0
	var instant_wpm: float = chars_per_minute / 5.0  # Standard: 5 characters = 1 word

	# Update class accuracy variable
	current_accuracy = (float(correct_keystrokes) / float(total_keystrokes)) * 100.0

	# Simple WPM calculation without complex smoothing
	smoothed_wpm = instant_wpm

	real_time_stats_updated.emit(smoothed_wpm, current_accuracy)


func process_keystroke(typed_char: String) -> bool:
	# Validate current_text exists
	if current_text.is_empty():
		push_error("[TypingEngine] current_text is empty - cannot process keystroke")
		return false

	if current_position >= current_text.length():
		return false

	var current_time: float = Time.get_unix_time_from_system()
	var expected_char: String = current_text[current_position]
	var is_correct: bool = typed_char.to_lower() == expected_char.to_lower()

	# Start timing on first keystroke
	if session_start_time == 0.0:
		session_start_time = current_time
		last_calculation_time = current_time

	# Calculate response time
	var response_time: float = 0.0
	if last_keystroke_time > 0:
		response_time = current_time - last_keystroke_time
	last_keystroke_time = current_time

	# Update counters
	total_keystrokes += 1
	if is_correct:
		correct_keystrokes += 1
		current_position += 1

	# Update accuracy (only changes on keystrokes)
	current_accuracy = (float(correct_keystrokes) / float(total_keystrokes)) * 100.0

	return is_correct

func start_typing_session() -> void:
	session_start_time = 0.0  # Will be set on first keystroke
	last_calculation_time = 0.0
	last_keystroke_time = 0.0
	total_keystrokes = 0
	correct_keystrokes = 0
	current_position = 0
	smoothed_wpm = 0.0
	current_accuracy = 100.0

	# Reset corruption state
	corruption_map.clear()
	display_text = current_text

func get_current_character() -> String:
	if current_position < current_text.length():
		return current_text[current_position]
	return ""

func get_typing_progress() -> float:
	if current_text.length() == 0:
		return 0.0
	return float(current_position) / float(current_text.length())

## Get the display text (with corruption) for UI rendering
func get_display_text() -> String:
	return display_text

## Check if the current word is corrupted
func is_current_word_corrupted() -> bool:
	if corruption_map.is_empty():
		return false

	# Find which word we're currently in
	var words: PackedStringArray = current_text.split(" ")
	var char_count: int = 0
	var word_index: int = 0

	for i in range(words.size()):
		var word_length: int = words[i].length()
		if current_position <= char_count + word_length:
			word_index = i
			break
		char_count += word_length + 1  # +1 for space

	if word_index < corruption_map.size():
		return corruption_map[word_index]

	return false


func get_real_time_wpm() -> float:
	return smoothed_wpm

func get_real_time_accuracy() -> float:
	return current_accuracy

func export_session_data() -> Dictionary:
	return {
		"session_duration": Time.get_unix_time_from_system() - session_start_time,
		"total_keystrokes": total_keystrokes,
		"correct_keystrokes": correct_keystrokes
	}
