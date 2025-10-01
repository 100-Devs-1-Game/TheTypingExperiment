extends RefCounted
class_name IntelligentWordGenerator

## Advanced word generation system using linguistic patterns and phonetic rules
## Creates natural, pronounceable words that focus on specific learning objectives

signal word_generated(word: String, difficulty: float, patterns: Array[String])

# Comprehensive phonetic pattern database
const PHONETIC_PATTERNS = {
	"vowels": ["a", "e", "i", "o", "u"],
	"consonants": ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"],
	"digraphs": ["th", "ch", "sh", "ph", "ck", "ng", "qu"],
	"common_endings": ["ing", "tion", "ed", "er", "ly", "est", "ness"],
	"common_beginnings": ["un", "re", "in", "dis", "en", "non", "over", "mis"],
	"syllable_patterns": [
		{"pattern": "CV", "weight": 0.3},    # Consonant-Vowel
		{"pattern": "CVC", "weight": 0.4},   # Consonant-Vowel-Consonant
		{"pattern": "CVCC", "weight": 0.2},  # Consonant-Vowel-Consonant-Consonant
		{"pattern": "CCVC", "weight": 0.1}   # Consonant-Consonant-Vowel-Consonant
	]
}

# Advanced letter frequency data (English)
const LETTER_FREQUENCY = {
	"e": 12.70, "t": 9.06, "a": 8.17, "o": 7.51, "i": 6.97, "n": 6.75,
	"s": 6.33, "h": 6.09, "r": 5.99, "d": 4.25, "l": 4.03, "c": 2.78,
	"u": 2.76, "m": 2.41, "w": 2.36, "f": 2.23, "g": 2.02, "y": 1.97,
	"p": 1.93, "b": 1.29, "v": 0.98, "k": 0.77, "j": 0.15, "x": 0.15,
	"q": 0.10, "z": 0.07
}

# Bigram and trigram frequency for natural word flow
const COMMON_BIGRAMS = {
	"th": 1.52, "er": 1.12, "on": 1.07, "an": 1.03, "re": 0.93, "he": 0.89,
	"in": 0.88, "ed": 0.83, "nd": 0.82, "ha": 0.78, "at": 0.77, "en": 0.71,
	"es": 0.70, "of": 0.69, "or": 0.69, "nt": 0.66, "ea": 0.65, "ti": 0.64,
	"to": 0.63, "it": 0.62, "st": 0.61, "io": 0.59, "le": 0.58, "is": 0.56,
	"ou": 0.55, "ar": 0.54, "as": 0.52, "de": 0.50, "rt": 0.50, "ve": 0.49
}

# Letter transition probabilities for smooth typing patterns
const LETTER_TRANSITIONS = {
	"finger_alternation": 0.7,   # Prefer alternating hands/fingers
	"same_finger_penalty": 0.2,  # Avoid same finger sequences
	"awkward_reach_penalty": 0.3 # Avoid difficult finger movements
}

# Keyboard layout for ergonomic analysis
const QWERTY_LAYOUT = {
	"left_hand": ["q", "w", "e", "r", "t", "a", "s", "d", "f", "g", "z", "x", "c", "v", "b"],
	"right_hand": ["y", "u", "i", "o", "p", "h", "j", "k", "l", "n", "m"],
	"home_row": ["a", "s", "d", "f", "j", "k", "l"],
	"top_row": ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
	"bottom_row": ["z", "x", "c", "v", "b", "n", "m"]
}

var target_letters: Array[String] = []
var difficulty_level: float = 0.5
var word_length_range: Vector2 = Vector2(3, 7)
var phonetic_weight: float = 0.8
var ergonomic_weight: float = 0.6

func _init() -> void:
	_validate_pattern_data()

func _validate_pattern_data() -> void:
	# Ensure phonetic patterns are valid
	assert(PHONETIC_PATTERNS.vowels.size() > 0, "Vowels array cannot be empty")
	assert(PHONETIC_PATTERNS.consonants.size() > 0, "Consonants array cannot be empty")

func generate_targeted_words(letter_focus: Array[String], word_count: int, difficulty: float = 0.5) -> Array[String]:
	target_letters = letter_focus.duplicate()
	difficulty_level = difficulty

	var generated_words: Array[String] = []
	var attempts: int = 0
	var max_attempts: int = word_count * 3

	while generated_words.size() < word_count and attempts < max_attempts:
		var word: String = _generate_single_word()
		if _validate_word_quality(word):
			generated_words.append(word)
			word_generated.emit(word, _calculate_word_difficulty(word), _extract_word_patterns(word))
		attempts += 1

	# Fill remaining slots with fallback generation if needed
	while generated_words.size() < word_count:
		generated_words.append(_generate_fallback_word())

	return generated_words

func _generate_single_word() -> String:
	var word_length: int = _determine_optimal_length()
	var generation_method: String = _select_generation_method()

	match generation_method:
		"syllable_based":
			return _generate_syllable_based_word(word_length)
		"pattern_based":
			return _generate_pattern_based_word(word_length)
		"frequency_based":
			return _generate_frequency_based_word(word_length)
		"ergonomic_optimized":
			return _generate_ergonomic_word(word_length)
		_:
			return _generate_pattern_based_word(word_length)

func _determine_optimal_length() -> int:
	# Adjust word length based on difficulty and target letters
	var base_length: float = lerp(word_length_range.x, word_length_range.y, difficulty_level)
	var letter_factor: float = 1.0 + (target_letters.size() * 0.1)
	return int(clamp(base_length * letter_factor, 3, 12))

func _select_generation_method() -> String:
	var methods: Array[Dictionary] = [
		{"name": "syllable_based", "weight": 0.4},
		{"name": "pattern_based", "weight": 0.3},
		{"name": "frequency_based", "weight": 0.2},
		{"name": "ergonomic_optimized", "weight": 0.1}
	]

	return _weighted_random_choice(methods)

func _weighted_random_choice(choices: Array[Dictionary]) -> String:
	var total_weight: float = 0.0
	for choice in choices:
		total_weight += choice.weight

	var random_value: float = randf() * total_weight
	var cumulative_weight: float = 0.0

	for choice in choices:
		cumulative_weight += choice.weight
		if random_value <= cumulative_weight:
			return choice.name

	return choices[0].name

func _generate_syllable_based_word(target_length: int) -> String:
	var syllables: Array[String] = []
	var remaining_length: int = target_length

	while remaining_length > 0:
		var syllable_pattern: String = _select_syllable_pattern()
		var syllable: String = _create_syllable(syllable_pattern)

		if syllable.length() <= remaining_length:
			syllables.append(syllable)
			remaining_length -= syllable.length()
		else:
			break

	var word: String = "".join(syllables)
	return _optimize_word_for_targets(word)

func _select_syllable_pattern() -> String:
	var patterns: Array[Dictionary] = []
	for pattern in PHONETIC_PATTERNS.syllable_patterns:
		# Convert "pattern" key to "name" key for compatibility
		patterns.append({"name": pattern.pattern, "weight": pattern.weight})
	return _weighted_random_choice(patterns)

func _create_syllable(pattern: String) -> String:
	var syllable: String = ""

	for i in range(pattern.length()):
		var char_type: String = pattern[i]
		match char_type:
			"C":
				syllable += _select_consonant()
			"V":
				syllable += _select_vowel()

	return syllable

func _select_consonant() -> String:
	var consonants: Array[String] = []
	for consonant in PHONETIC_PATTERNS.consonants:
		consonants.append(consonant)

	if target_letters.size() > 0:
		var target_consonants: Array[String] = []
		for letter in target_letters:
			if letter in consonants:
				target_consonants.append(letter)

		if target_consonants.size() > 0 and randf() < 0.7:
			return target_consonants[randi() % target_consonants.size()]

	return _frequency_weighted_letter_selection(consonants)

func _select_vowel() -> String:
	var vowels: Array[String] = []
	for vowel in PHONETIC_PATTERNS.vowels:
		vowels.append(vowel)

	if target_letters.size() > 0:
		var target_vowels: Array[String] = []
		for letter in target_letters:
			if letter in vowels:
				target_vowels.append(letter)

		if target_vowels.size() > 0 and randf() < 0.6:
			return target_vowels[randi() % target_vowels.size()]

	return _frequency_weighted_letter_selection(vowels)

func _frequency_weighted_letter_selection(available_letters: Array[String]) -> String:
	var weighted_letters: Array[Dictionary] = []

	for letter in available_letters:
		var frequency: float = LETTER_FREQUENCY.get(letter, 0.1)
		weighted_letters.append({"name": letter, "weight": frequency})

	return _weighted_random_choice(weighted_letters)

func _generate_pattern_based_word(target_length: int) -> String:
	var word: String = ""
	var last_was_vowel: bool = false
	var consecutive_consonants: int = 0

	for i in range(target_length):
		var use_target_letter: bool = target_letters.size() > 0 and randf() < 0.6
		var letter: String = ""

		if use_target_letter:
			letter = target_letters[randi() % target_letters.size()]
		else:
			# Apply phonetic rules
			var is_vowel_needed: bool = consecutive_consonants >= 2 or (i > 0 and not last_was_vowel and randf() < 0.4)

			if is_vowel_needed:
				letter = _select_vowel()
				last_was_vowel = true
				consecutive_consonants = 0
			else:
				letter = _select_consonant()
				last_was_vowel = false
				consecutive_consonants += 1

		word += letter

	return _apply_phonetic_improvements(word)

func _apply_phonetic_improvements(word: String) -> String:
	var improved: String = word

	# Apply common digraph replacements
	for digraph in PHONETIC_PATTERNS.digraphs:
		if randf() < 0.2 and improved.length() >= digraph.length():
			var position: int = randi() % (improved.length() - digraph.length() + 1)
			var replacement_chars: String = improved.substr(position, digraph.length())
			if _is_suitable_digraph_replacement(replacement_chars, digraph):
				improved = improved.left(position) + digraph + improved.substr(position + digraph.length())

	# Add common prefixes/suffixes based on difficulty
	if difficulty_level > 0.6 and randf() < 0.3:
		improved = _add_affix(improved)

	return improved

func _is_suitable_digraph_replacement(original: String, digraph: String) -> bool:
	# Check if the digraph replacement would improve pronounceability
	return original.length() == digraph.length() and not original in PHONETIC_PATTERNS.digraphs

func _add_affix(word: String) -> String:
	if randf() < 0.5:
		# Add prefix
		var prefixes: Array[String] = []
		for prefix in PHONETIC_PATTERNS.common_beginnings:
			prefixes.append(prefix)
		return prefixes[randi() % prefixes.size()] + word
	else:
		# Add suffix
		var suffixes: Array[String] = []
		for suffix in PHONETIC_PATTERNS.common_endings:
			suffixes.append(suffix)
		return word + suffixes[randi() % suffixes.size()]

func _generate_frequency_based_word(target_length: int) -> String:
	var word: String = ""

	for i in range(target_length):
		var use_bigram: bool = i > 0 and randf() < 0.4

		if use_bigram and word.length() > 0:
			var last_char: String = word[word.length() - 1]
			var next_char: String = _select_next_char_by_bigram(last_char)
			word += next_char
		else:
			var character: String = _select_char_by_frequency()
			word += character

	return _optimize_word_for_targets(word)

func _select_next_char_by_bigram(previous_char: String) -> String:
	var candidates: Array[String] = []
	var weights: Array[float] = []

	for bigram in COMMON_BIGRAMS:
		if bigram.begins_with(previous_char):
			var next_char: String = bigram[1]
			candidates.append(next_char)
			weights.append(COMMON_BIGRAMS[bigram])

	if candidates.is_empty():
		return _select_char_by_frequency()

	return _weighted_selection_from_arrays(candidates, weights)

func _select_char_by_frequency() -> String:
	if target_letters.size() > 0 and randf() < 0.7:
		return target_letters[randi() % target_letters.size()]

	var candidates: Array[String] = []
	var weights: Array[float] = []
	for letter in LETTER_FREQUENCY.keys():
		candidates.append(letter)
	for weight in LETTER_FREQUENCY.values():
		weights.append(weight)

	return _weighted_selection_from_arrays(candidates, weights)

func _weighted_selection_from_arrays(items: Array[String], weights: Array[float]) -> String:
	var total_weight: float = 0.0
	for weight in weights:
		total_weight += weight

	var random_value: float = randf() * total_weight
	var cumulative_weight: float = 0.0

	for i in range(items.size()):
		cumulative_weight += weights[i]
		if random_value <= cumulative_weight:
			return items[i]

	return items[0]

func _generate_ergonomic_word(target_length: int) -> String:
	var word: String = ""
	var last_hand: String = ""
	var finger_usage: Dictionary = {}

	for i in range(target_length):
		var letter: String = _select_ergonomic_letter(last_hand, finger_usage)
		word += letter

		# Update ergonomic tracking
		last_hand = _get_hand_for_letter(letter)
		var finger: String = _get_finger_for_letter(letter)
		finger_usage[finger] = finger_usage.get(finger, 0) + 1

	return _optimize_word_for_targets(word)

func _select_ergonomic_letter(avoid_hand: String, finger_usage: Dictionary) -> String:
	var candidates: Array[String] = []
	var all_letters: Array[String] = []
	for letter in LETTER_FREQUENCY.keys():
		all_letters.append(letter)

	for letter in all_letters:
		var letter_hand: String = _get_hand_for_letter(letter)
		var letter_finger: String = _get_finger_for_letter(letter)

		# Prefer hand alternation
		if avoid_hand == "" or letter_hand != avoid_hand:
			# Avoid overused fingers
			var finger_count: int = finger_usage.get(letter_finger, 0)
			if finger_count < 2:
				candidates.append(letter)

	if candidates.is_empty():
		candidates = all_letters

	# Weight candidates by target letter priority and ergonomics
	var best_candidate: String = candidates[0]
	var best_score: float = 0.0

	for candidate in candidates:
		var score: float = _calculate_ergonomic_score(candidate, avoid_hand, finger_usage)
		if score > best_score:
			best_score = score
			best_candidate = candidate

	return best_candidate

func _get_hand_for_letter(letter: String) -> String:
	if letter in QWERTY_LAYOUT.left_hand:
		return "left"
	elif letter in QWERTY_LAYOUT.right_hand:
		return "right"
	else:
		return "neutral"

func _get_finger_for_letter(letter: String) -> String:
	var finger_map: Dictionary = {
		"q": "left_pinky", "a": "left_pinky", "z": "left_pinky",
		"w": "left_ring", "s": "left_ring", "x": "left_ring",
		"e": "left_middle", "d": "left_middle", "c": "left_middle",
		"r": "left_index", "f": "left_index", "v": "left_index",
		"t": "left_index", "g": "left_index", "b": "left_index",
		"y": "right_index", "h": "right_index", "n": "right_index",
		"u": "right_index", "j": "right_index", "m": "right_index",
		"i": "right_middle", "k": "right_middle",
		"o": "right_ring", "l": "right_ring",
		"p": "right_pinky"
	}
	return finger_map.get(letter, "unknown")

func _calculate_ergonomic_score(letter: String, avoid_hand: String, finger_usage: Dictionary) -> float:
	var score: float = 1.0

	# Bonus for target letters
	if letter in target_letters:
		score *= 2.0

	# Bonus for hand alternation
	var letter_hand: String = _get_hand_for_letter(letter)
	if avoid_hand != "" and letter_hand != avoid_hand:
		score *= 1.5

	# Penalty for overused fingers
	var finger: String = _get_finger_for_letter(letter)
	var finger_count: int = finger_usage.get(finger, 0)
	score *= (1.0 / (1.0 + finger_count * 0.5))

	# Bonus for home row letters
	if letter in QWERTY_LAYOUT.home_row:
		score *= 1.3

	return score

func _optimize_word_for_targets(word: String) -> String:
	if target_letters.is_empty():
		return word

	var optimized: String = word
	var target_coverage: float = _calculate_target_coverage(word)

	# If target coverage is low, inject target letters
	if target_coverage < 0.3:
		optimized = _inject_target_letters(word)

	return optimized

func _calculate_target_coverage(word: String) -> float:
	if target_letters.is_empty():
		return 1.0

	var target_count: int = 0
	for i in range(word.length()):
		if word[i] in target_letters:
			target_count += 1

	return float(target_count) / float(word.length())

func _inject_target_letters(word: String) -> String:
	var result: String = word
	var injection_count: int = max(1, target_letters.size() / 3.0)

	for i in range(injection_count):
		var target_letter: String = target_letters[randi() % target_letters.size()]
		var position: int = randi() % (result.length() + 1)
		result = result.left(position) + target_letter + result.substr(position)

	return result

func _generate_fallback_word() -> String:
	var fallback_patterns: Array[String] = ["cat", "dog", "run", "jump", "fast", "slow", "good", "bad"]
	return fallback_patterns[randi() % fallback_patterns.size()]

func _validate_word_quality(word: String) -> bool:
	if word.length() < 2 or word.length() > 15:
		return false

	# Check for reasonable vowel/consonant ratio
	var vowel_count: int = 0
	for i in range(word.length()):
		if word[i] in PHONETIC_PATTERNS.vowels:
			vowel_count += 1

	var vowel_ratio: float = float(vowel_count) / float(word.length())
	return vowel_ratio >= 0.1 and vowel_ratio <= 0.8

func _calculate_word_difficulty(word: String) -> float:
	var difficulty: float = 0.0

	# Length factor
	difficulty += (word.length() - 3) * 0.1

	# Uncommon letter penalty
	for i in range(word.length()):
		var letter: String = word[i]
		var frequency: float = LETTER_FREQUENCY.get(letter, 0.1)
		difficulty += (1.0 - frequency / 12.7) * 0.2

	# Ergonomic difficulty
	difficulty += _calculate_ergonomic_difficulty(word)

	return clamp(difficulty, 0.0, 1.0)

func _calculate_ergonomic_difficulty(word: String) -> float:
	var difficulty: float = 0.0
	var last_hand: String = ""

	for i in range(word.length()):
		var letter: String = word[i]
		var hand: String = _get_hand_for_letter(letter)

		# Penalty for same hand consecutive letters
		if hand == last_hand and hand != "neutral":
			difficulty += 0.1

		# Penalty for awkward letters
		if not letter in QWERTY_LAYOUT.home_row:
			difficulty += 0.05

		last_hand = hand

	return difficulty / word.length()

func _extract_word_patterns(word: String) -> Array[String]:
	var patterns: Array[String] = []

	# Identify phonetic patterns
	for digraph in PHONETIC_PATTERNS.digraphs:
		if digraph in word:
			patterns.append("digraph_" + digraph)

	# Identify structural patterns
	if word.length() >= 5:
		patterns.append("long_word")

	var vowel_count: int = 0
	for i in range(word.length()):
		if word[i] in PHONETIC_PATTERNS.vowels:
			vowel_count += 1

	if vowel_count >= word.length() / 2:
		patterns.append("vowel_heavy")

	return patterns

func set_target_letters(letters: Array[String]) -> void:
	target_letters = letters.duplicate()

func set_difficulty_level(difficulty: float) -> void:
	difficulty_level = clamp(difficulty, 0.0, 1.0)

func set_word_length_range(min_length: int, max_length: int) -> void:
	word_length_range = Vector2(max(2, min_length), max(min_length + 1, max_length))

func set_generation_weights(phonetic: float, ergonomic: float) -> void:
	phonetic_weight = clamp(phonetic, 0.0, 1.0)
	ergonomic_weight = clamp(ergonomic, 0.0, 1.0)

## Apply corruption to a list of generated words
func apply_corruption_to_wordlist(words: Array[String]) -> Dictionary:
	var original_words: Array[String] = words.duplicate()
	var display_words: Array[String] = []
	var corruption_map: Array[bool] = []

	for word in words:
		if CorruptionManager and CorruptionManager.should_corrupt_word():
			var corrupted_word: String = CorruptionManager.corrupt_entire_word(word)
			display_words.append(corrupted_word)
			corruption_map.append(true)
		else:
			display_words.append(word)
			corruption_map.append(false)

	return {
		"original_words": original_words,
		"display_words": display_words,
		"corruption_map": corruption_map,
		"original_text": " ".join(original_words),
		"display_text": " ".join(display_words)
	}

## Enhanced word generation with corruption support
func generate_targeted_words_with_corruption(letter_focus: Array[String], word_count: int, difficulty: float = 0.5) -> Dictionary:
	var base_words: Array[String] = generate_targeted_words(letter_focus, word_count, difficulty)
	return apply_corruption_to_wordlist(base_words)

func get_generation_stats() -> Dictionary:
	return {
		"target_letters": target_letters.duplicate(),
		"difficulty_level": difficulty_level,
		"word_length_range": word_length_range,
		"phonetic_weight": phonetic_weight,
		"ergonomic_weight": ergonomic_weight
	}
