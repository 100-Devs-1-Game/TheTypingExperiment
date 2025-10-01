extends RefCounted
class_name AdaptiveAlgorithm

## Advanced adaptive learning algorithm for typing practice
## Analyzes typing patterns and generates targeted exercises

signal learning_data_updated(letter: String, progress: float)
signal new_letter_unlocked(letter: String)
signal mastery_achieved(letter: String)

const MIN_SAMPLES_FOR_ANALYSIS: int = 10
const MASTERY_WPM_THRESHOLD: float = 25.0
const MASTERY_ACCURACY_THRESHOLD: float = 0.95
const CONFIDENCE_INTERVAL: float = 0.95

# Letter frequency in English (for weighting)
const ENGLISH_LETTER_FREQUENCY: Dictionary = {
	"e": 12.7, "t": 9.1, "a": 8.2, "o": 7.5, "i": 7.0, "n": 6.7,
	"s": 6.3, "h": 6.1, "r": 6.0, "d": 4.3, "l": 4.0, "c": 2.8,
	"u": 2.8, "m": 2.4, "w": 2.4, "f": 2.2, "g": 2.0, "y": 2.0,
	"p": 1.9, "b": 1.3, "v": 1.0, "k": 0.8, "j": 0.15, "x": 0.15,
	"q": 0.10, "z": 0.07
}

# Learning progression order (easier letters first)
const LEARNING_PROGRESSION: Array[String] = [
	"a", "s", "d", "f", "j", "k", "l", "e", "r", "i", "o",
	"t", "n", "h", "u", "c", "m", "w", "g", "y", "p", "b",
	"v", "q", "x", "z"
]

var letter_learning_data: Dictionary = {}
var active_letters: Array[String] = []
var current_difficulty_level: int = 0
var session_performance_history: Array[Dictionary] = []
var word_generator: IntelligentWordGenerator

func _init() -> void:
	word_generator = IntelligentWordGenerator.new()
	_initialize_learning_data()
	_set_initial_letters()
	_setup_word_generator()

func _initialize_learning_data() -> void:
	for letter in LEARNING_PROGRESSION:
		letter_learning_data[letter] = {
			"attempts": [],
			"correct_count": 0,
			"total_count": 0,
			"speed_samples": [],
			"error_patterns": {},
			"learning_curve": [],
			"confidence_score": 0.0,
			"mastery_level": 0.0,
			"last_practice_time": 0.0,
			"retention_score": 1.0,
			"difficulty_rating": 1.0
		}

func _set_initial_letters() -> void:
	# Start with home row keys
	active_letters = ["a", "s", "d", "f", "j", "k", "l"]
	current_difficulty_level = active_letters.size()

func record_keystroke(letter: String, is_correct: bool, response_time: float) -> void:
	letter = letter.to_lower()
	if not letter_learning_data.has(letter):
		return

	var data: Dictionary = letter_learning_data[letter]
	var current_time: float = Time.get_unix_time_from_system()

	# Record the attempt
	var attempt: Dictionary = {
		"timestamp": current_time,
		"correct": is_correct,
		"response_time": response_time,
		"session_id": get_current_session_id()
	}

	data.attempts.append(attempt)
	data.total_count += 1

	if is_correct:
		data.correct_count += 1
		data.speed_samples.append(response_time)

		# Keep only recent speed samples for analysis
		if data.speed_samples.size() > 50:
			data.speed_samples.pop_front()
	else:
		_record_error_pattern(letter, attempt)

	data.last_practice_time = current_time
	_update_learning_metrics(letter)
	_check_progression(letter)

func _record_error_pattern(letter: String, attempt: Dictionary) -> void:
	var data: Dictionary = letter_learning_data[letter]
	var context: String = _get_typing_context(letter)

	if not data.error_patterns.has(context):
		data.error_patterns[context] = 0
	data.error_patterns[context] += 1

func _get_typing_context(letter: String) -> String:
	# Analyze context around the error (finger position, previous letter, etc.)
	# For now, return a simple classification
	var finger_mapping: Dictionary = {
		"a": "left_pinky", "s": "left_ring", "d": "left_middle", "f": "left_index",
		"j": "right_index", "k": "right_middle", "l": "right_ring"
	}
	return finger_mapping.get(letter, "unknown")

func _update_learning_metrics(letter: String) -> void:
	var data: Dictionary = letter_learning_data[letter]

	if data.total_count < MIN_SAMPLES_FOR_ANALYSIS:
		return

	# Calculate accuracy
	var accuracy: float = float(data.correct_count) / float(data.total_count)

	# Calculate average speed (WPM equivalent)
	var avg_speed: float = 0.0
	if data.speed_samples.size() > 0:
		var total_time: float = 0.0
		for time in data.speed_samples:
			total_time += time
		avg_speed = 60.0 / (total_time / data.speed_samples.size())  # Convert to CPM then estimate WPM

	# Calculate confidence score using statistical confidence interval
	var confidence: float = _calculate_confidence_score(data)
	data.confidence_score = confidence

	# Calculate mastery level (0.0 to 1.0)
	var speed_factor: float = min(avg_speed / MASTERY_WPM_THRESHOLD, 1.0)
	var accuracy_factor: float = min(accuracy / MASTERY_ACCURACY_THRESHOLD, 1.0)
	var confidence_factor: float = confidence

	data.mastery_level = (speed_factor + accuracy_factor + confidence_factor) / 3.0

	# Update retention score based on time since last practice
	_update_retention_score(letter)

	# Update difficulty rating based on error patterns
	_update_difficulty_rating(letter)

	learning_data_updated.emit(letter, data.mastery_level)

func _calculate_confidence_score(data: Dictionary) -> float:
	if data.total_count < MIN_SAMPLES_FOR_ANALYSIS:
		return 0.0

	var accuracy: float = float(data.correct_count) / float(data.total_count)
	var n: float = float(data.total_count)

	# Calculate confidence interval for accuracy
	var z_score: float = 1.96  # 95% confidence
	var margin_of_error: float = z_score * sqrt((accuracy * (1.0 - accuracy)) / n)

	# Higher confidence when margin of error is smaller
	var confidence: float = max(0.0, 1.0 - (margin_of_error * 2.0))
	return confidence

func _update_retention_score(letter: String) -> void:
	var data: Dictionary = letter_learning_data[letter]
	var current_time: float = Time.get_unix_time_from_system()
	var time_since_practice: float = current_time - data.last_practice_time

	# Forgetting curve: retention decreases over time
	var retention_decay: float = exp(-time_since_practice / (24.0 * 3600.0))  # 24 hour half-life
	data.retention_score = retention_decay

func _update_difficulty_rating(letter: String) -> void:
	var data: Dictionary = letter_learning_data[letter]
	var base_difficulty: float = 1.0 / ENGLISH_LETTER_FREQUENCY.get(letter, 1.0)

	# Adjust based on error patterns
	var error_frequency: float = 0.0
	if data.total_count > 0:
		error_frequency = float(data.total_count - data.correct_count) / float(data.total_count)

	data.difficulty_rating = base_difficulty * (1.0 + error_frequency * 2.0)

func _check_progression(letter: String) -> void:
	var data: Dictionary = letter_learning_data[letter]

	if data.mastery_level >= 0.8 and data.confidence_score >= 0.7:
		if not _has_mastered_letter(letter):
			mastery_achieved.emit(letter)

		# Check if we should unlock new letters
		_evaluate_new_letter_unlock()

func _has_mastered_letter(letter: String) -> bool:
	var data: Dictionary = letter_learning_data[letter]
	return data.mastery_level >= 0.8 and data.confidence_score >= 0.7

func _evaluate_new_letter_unlock() -> void:
	# Check if all active letters are sufficiently mastered
	var all_mastered: bool = true
	for letter in active_letters:
		if not _has_mastered_letter(letter):
			all_mastered = false
			break

	if all_mastered and current_difficulty_level < LEARNING_PROGRESSION.size():
		var next_letter: String = LEARNING_PROGRESSION[current_difficulty_level]
		active_letters.append(next_letter)
		current_difficulty_level += 1
		new_letter_unlocked.emit(next_letter)

func _setup_word_generator() -> void:
	if word_generator:
		word_generator.set_target_letters(active_letters)
		word_generator.set_difficulty_level(float(current_difficulty_level) / float(LEARNING_PROGRESSION.size()))

func generate_targeted_practice_text(word_count: int) -> String:
	var weak_letters: Array[String] = _identify_weak_letters()
	var practice_letters: Array[String] = _select_practice_letters(weak_letters)

	# Update word generator with current learning state
	_update_word_generator_settings(practice_letters)

	# Use intelligent word generator
	var words: Array[String] = word_generator.generate_targeted_words(practice_letters, word_count, _calculate_current_difficulty())

	return " ".join(words)

func _update_word_generator_settings(focus_letters: Array[String]) -> void:
	if not word_generator:
		return

	word_generator.set_target_letters(focus_letters)
	word_generator.set_difficulty_level(_calculate_current_difficulty())

	# Adjust word length based on skill level
	var avg_mastery: float = _calculate_average_mastery()
	var min_length: int = 3 if avg_mastery < 0.5 else 4
	var max_length: int = int(6 + avg_mastery * 4)  # 6-10 letters based on skill
	word_generator.set_word_length_range(min_length, max_length)

	# Adjust generation weights based on learning phase
	var phonetic_weight: float = 0.8 if avg_mastery < 0.3 else 0.6
	var ergonomic_weight: float = 0.4 if avg_mastery < 0.5 else 0.8
	word_generator.set_generation_weights(phonetic_weight, ergonomic_weight)

func _calculate_current_difficulty() -> float:
	var base_difficulty: float = float(current_difficulty_level) / float(LEARNING_PROGRESSION.size())
	var mastery_factor: float = _calculate_average_mastery()
	var session_factor: float = _calculate_session_performance_factor()

	return clamp((base_difficulty + mastery_factor + session_factor) / 3.0, 0.0, 1.0)

func _calculate_average_mastery() -> float:
	if active_letters.is_empty():
		return 0.0

	var total_mastery: float = 0.0
	for letter in active_letters:
		var data: Dictionary = letter_learning_data[letter]
		total_mastery += data.mastery_level

	return total_mastery / float(active_letters.size())

func _calculate_session_performance_factor() -> float:
	if session_performance_history.is_empty():
		return 0.5

	var recent_sessions: Array[Dictionary] = session_performance_history.slice(-5)  # Last 5 sessions
	var avg_performance: float = 0.0

	for session in recent_sessions:
		var wpm: float = session.get("wpm", 0.0)
		var accuracy: float = session.get("accuracy", 0.0)
		var session_score: float = (wpm / 60.0 + accuracy / 100.0) / 2.0
		avg_performance += session_score

	return avg_performance / float(recent_sessions.size())

func _identify_weak_letters() -> Array[String]:
	var weak_letters: Array[String] = []

	for letter in active_letters:
		var data: Dictionary = letter_learning_data[letter]
		var weakness_score: float = _calculate_weakness_score(data)

		if weakness_score > 0.3:  # Threshold for considering a letter "weak"
			weak_letters.append(letter)

	# Sort by weakness score (weakest first)
	weak_letters.sort_custom(func(a: String, b: String) -> bool:
		return _calculate_weakness_score(letter_learning_data[a]) > _calculate_weakness_score(letter_learning_data[b])
	)

	return weak_letters

func _calculate_weakness_score(data: Dictionary) -> float:
	var mastery_weakness: float = 1.0 - data.mastery_level
	var retention_weakness: float = 1.0 - data.retention_score
	var confidence_weakness: float = 1.0 - data.confidence_score

	# Weight recent performance more heavily
	var recency_weight: float = _calculate_recency_weight(data.last_practice_time)

	return (mastery_weakness + retention_weakness + confidence_weakness) / 3.0 * recency_weight

func _calculate_recency_weight(last_practice_time: float) -> float:
	var current_time: float = Time.get_unix_time_from_system()
	var time_diff: float = current_time - last_practice_time

	# More weight for letters practiced recently (inverse relationship)
	return max(0.1, 1.0 - (time_diff / (7.0 * 24.0 * 3600.0)))  # 7 day decay

func _select_practice_letters(weak_letters: Array[String]) -> Array[String]:
	var practice_letters: Array[String] = []

	# Include all weak letters
	practice_letters.append_array(weak_letters)

	# Add some strong letters for balance (prevent overemphasis on weak letters)
	var strong_letters: Array[String] = []
	for letter in active_letters:
		if not letter in weak_letters:
			strong_letters.append(letter)

	# Add 30% strong letters for balanced practice
	var strong_count: int = max(1, int(practice_letters.size() * 0.3))
	for i in range(min(strong_count, strong_letters.size())):
		practice_letters.append(strong_letters[i])

	return practice_letters

func _generate_targeted_word(practice_letters: Array[String]) -> String:
	if practice_letters.is_empty():
		practice_letters = active_letters

	var word_length: int = randi_range(3, 7)
	var word: String = ""

	for i in word_length:
		# 70% chance to use targeted letters, 30% any active letter
		if randf() < 0.7:
			word += practice_letters[randi() % practice_letters.size()]
		else:
			word += active_letters[randi() % active_letters.size()]

	return _make_pronounceable(word)

func _make_pronounceable(word: String) -> String:
	# Simple rules to make words more pronounceable
	var vowels: Array[String] = ["a", "e", "i", "o", "u"]
	var consonants: Array[String] = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"]

	var result: String = ""
	var last_was_vowel: bool = false

	for i in range(word.length()):
		var character: String = word[i]
		var is_vowel: bool = character in vowels

		# Alternate vowels and consonants when possible
		if i > 0 and last_was_vowel == is_vowel:
			# Try to find alternative from practice letters
			var alternatives: Array[String] = []
			for letter in active_letters:
				if (letter in vowels) != is_vowel:
					alternatives.append(letter)

			if not alternatives.is_empty():
				character = alternatives[randi() % alternatives.size()]
				is_vowel = character in vowels

		result += character
		last_was_vowel = is_vowel

	return result

func get_current_session_id() -> String:
	return str(Time.get_unix_time_from_system())

func get_learning_progress() -> Dictionary:
	var progress: Dictionary = {}

	for letter in active_letters:
		var data: Dictionary = letter_learning_data[letter]
		progress[letter] = {
			"mastery_level": data.mastery_level,
			"confidence_score": data.confidence_score,
			"total_attempts": data.total_count,
			"accuracy": float(data.correct_count) / max(1.0, float(data.total_count)),
			"retention_score": data.retention_score
		}

	return progress

func get_next_letters_to_unlock() -> Array[String]:
	var next_letters: Array[String] = []
	var remaining_letters: int = min(3, LEARNING_PROGRESSION.size() - current_difficulty_level)

	for i in range(remaining_letters):
		if current_difficulty_level + i < LEARNING_PROGRESSION.size():
			next_letters.append(LEARNING_PROGRESSION[current_difficulty_level + i])

	return next_letters

func export_learning_data() -> Dictionary:
	return {
		"letter_learning_data": letter_learning_data,
		"active_letters": active_letters,
		"current_difficulty_level": current_difficulty_level,
		"version": "1.0"
	}

func import_learning_data(data: Dictionary) -> void:
	if data.has("letter_learning_data"):
		letter_learning_data = data.letter_learning_data
	if data.has("active_letters"):
		var letters_array: Array = data.active_letters
		active_letters.clear()
		for letter in letters_array:
			if letter is String:
				active_letters.append(letter)
	if data.has("current_difficulty_level"):
		current_difficulty_level = data.current_difficulty_level
