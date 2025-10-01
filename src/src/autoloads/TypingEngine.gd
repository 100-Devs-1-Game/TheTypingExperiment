extends Node

## Core typing logic engine with advanced adaptive learning
## Handles keystroke validation, intelligent word generation, and difficulty progression

signal letter_typed(letter: String, is_correct: bool, response_time: float)
signal word_completed(word: String, wpm: float, accuracy: float)
signal mistake_made(expected: String, typed: String)
signal new_letter_unlocked(letter: String)
signal mastery_achieved(letter: String)
signal real_time_stats_updated(wpm: float, accuracy: float)

var adaptive_algorithm: AdaptiveAlgorithm
var per_key_analytics: PerKeyAnalytics

# Dual text system for corruption support
var current_text: String = ""  # Original text for validation
var display_text: String = ""  # Corrupted text for display
var corruption_map: Array[bool] = []  # Tracks which words are corrupted
var current_position: int = 0
var last_keystroke_time: float = 0.0
var keystroke_times: Array[float] = []

# Real-time calculation variables
var session_start_time: float = 0.0
var total_keystrokes: int = 0
var correct_keystrokes: int = 0
var wpm_history: Array[float] = []
var accuracy_history: Array[float] = []
var calculation_interval: float = 1.0  # Update every second
var last_calculation_time: float = 0.0

# Smoothing parameters
var wmp_smoothing_factor: float = 0.3
var smoothed_wpm: float = 0.0
var current_accuracy: float = 100.0  # Direct calculation, no smoothing

func _ready() -> void:
	adaptive_algorithm = AdaptiveAlgorithm.new()
	per_key_analytics = PerKeyAnalytics.new()
	_setup_connections()

func _setup_connections() -> void:
	adaptive_algorithm.learning_data_updated.connect(_on_learning_data_updated)
	adaptive_algorithm.new_letter_unlocked.connect(_on_new_letter_unlocked)
	adaptive_algorithm.mastery_achieved.connect(_on_mastery_achieved)

	per_key_analytics.key_performance_updated.connect(_on_key_performance_updated)
	per_key_analytics.weakness_identified.connect(_on_weakness_identified)
	per_key_analytics.improvement_detected.connect(_on_improvement_detected)

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

	# Calculate current accuracy
	var current_accuracy: float = (float(correct_keystrokes) / float(total_keystrokes)) * 100.0

	# Apply smoothing only to WPM, not accuracy
	if smoothed_wpm == 0.0:
		smoothed_wpm = instant_wpm
	else:
		smoothed_wpm = (wmp_smoothing_factor * instant_wpm) + ((1.0 - wmp_smoothing_factor) * smoothed_wpm)

	# Store history for trend analysis
	wpm_history.append(smoothed_wpm)
	accuracy_history.append(current_accuracy)

	# Keep history size manageable
	if wpm_history.size() > 300:  # 5 minutes of data at 1 second intervals
		wpm_history.pop_front()
	if accuracy_history.size() > 300:
		accuracy_history.pop_front()

	real_time_stats_updated.emit(smoothed_wpm, current_accuracy)

func _on_learning_data_updated(letter: String, progress: float) -> void:
	# React to learning progress updates
	pass

func _on_new_letter_unlocked(letter: String) -> void:
	new_letter_unlocked.emit(letter)

func _on_mastery_achieved(letter: String) -> void:
	mastery_achieved.emit(letter)

func process_keystroke(typed_char: String) -> bool:
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

	# Record keystroke in adaptive algorithm
	adaptive_algorithm.record_keystroke(expected_char, is_correct, response_time)

	# Record detailed per-key analytics
	var context: Dictionary = _build_keystroke_context(typed_char, expected_char, current_position)
	per_key_analytics.record_keystroke(expected_char, is_correct, response_time, context)

	letter_typed.emit(typed_char, is_correct, response_time)

	if not is_correct:
		mistake_made.emit(expected_char, typed_char)

	# Check if word is completed
	if is_correct and (current_position >= current_text.length() or current_text[current_position] == " "):
		_on_word_completed()

	return is_correct

func _on_word_completed() -> void:
	word_completed.emit("", smoothed_wpm, current_accuracy)

func start_typing_session() -> void:
	session_start_time = 0.0  # Will be set on first keystroke
	last_calculation_time = 0.0
	last_keystroke_time = 0.0
	total_keystrokes = 0
	correct_keystrokes = 0
	current_position = 0
	smoothed_wpm = 0.0
	current_accuracy = 100.0
	wpm_history.clear()
	accuracy_history.clear()

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

func get_active_letters() -> Array[String]:
	return adaptive_algorithm.active_letters

func get_learning_progress() -> Dictionary:
	return adaptive_algorithm.get_learning_progress()

func get_real_time_wpm() -> float:
	return smoothed_wpm

func get_real_time_accuracy() -> float:
	return current_accuracy

func export_session_data() -> Dictionary:
	return {
		"adaptive_data": adaptive_algorithm.export_learning_data(),
		"wpm_history": wpm_history,
		"accuracy_history": accuracy_history,
		"session_duration": Time.get_unix_time_from_system() - session_start_time,
		"total_keystrokes": total_keystrokes,
		"correct_keystrokes": correct_keystrokes
	}

func _build_keystroke_context(typed_char: String, expected_char: String, position: int) -> Dictionary:
	var context: Dictionary = {
		"typed_key": typed_char,
		"expected_key": expected_char,
		"is_correct": typed_char.to_lower() == expected_char.to_lower(),
		"text_position": position,
		"response_time": 0.0
	}

	# Add preceding key context
	if position > 0:
		context.preceding_key = current_text[position - 1]

	# Add following key context
	if position + 1 < current_text.length():
		context.following_key = current_text[position + 1]

	# Add word position context
	var word_start: int = _find_word_start(position)
	var word_position: int = position - word_start
	context.word_position = word_position

	# Add timing context
	if last_keystroke_time > 0:
		var current_time: float = Time.get_unix_time_from_system()
		context.response_time = current_time - last_keystroke_time

	return context

func _find_word_start(position: int) -> int:
	var start: int = position
	while start > 0 and current_text[start - 1] != " ":
		start -= 1
	return start

func _on_key_performance_updated(key: String, metrics: Dictionary) -> void:
	# React to key performance updates
	pass

func _on_weakness_identified(key: String, weakness_type: String, severity: float) -> void:
	print("Weakness identified for key '%s': %s (severity: %.2f)" % [key, weakness_type, severity])

func _on_improvement_detected(key: String, improvement_metric: String, change: float) -> void:
	print("Improvement detected for key '%s': %s improved by %.2f" % [key, improvement_metric, change])

func get_per_key_analytics() -> PerKeyAnalytics:
	return per_key_analytics

func get_key_detailed_analysis(key: String) -> Dictionary:
	if per_key_analytics:
		return per_key_analytics.get_key_detailed_analysis(key)
	return {}

func get_overall_key_statistics() -> Dictionary:
	if per_key_analytics:
		return per_key_analytics.get_overall_statistics()
	return {}

func export_key_performance_report(key: String) -> String:
	if per_key_analytics:
		return per_key_analytics.export_detailed_report(key)
	return "Analytics not available"

func import_session_data(data: Dictionary) -> void:
	if data.has("adaptive_data"):
		adaptive_algorithm.import_learning_data(data.adaptive_data)
