extends Node

## DDLC-style text corruption manager
## Provides complete word corruption with various character replacement sets

signal corruption_applied(original_text: String, corrupted_text: String)

# Different corruption character sets for variety
const CORRUPTION_SETS: Dictionary = {
	"unicode_glitch": {
		"a": "ą", "b": "ҍ", "c": "ç", "d": "ԁ", "e": "ë", "f": "ƒ", "g": "ğ",
		"h": "ħ", "i": "ï", "j": "ʝ", "k": "ķ", "l": "ł", "m": "ɱ", "n": "ń",
		"o": "ø", "p": "þ", "q": "ɋ", "r": "ŕ", "s": "ş", "t": "ţ", "u": "ü",
		"v": "ṿ", "w": "ẅ", "x": "ẋ", "y": "ÿ", "z": "ẑ",
		"A": "Ą", "B": "Ҍ", "C": "Ç", "D": "Ԁ", "E": "Ë", "F": "Ƒ", "G": "Ğ",
		"H": "Ħ", "I": "Ï", "J": "Ĵ", "K": "Ķ", "L": "Ł", "M": "Ɱ", "N": "Ń",
		"O": "Ø", "P": "Þ", "Q": "Ɋ", "R": "Ŕ", "S": "Ş", "T": "Ţ", "U": "Ü",
		"V": "Ṿ", "W": "Ẅ", "X": "Ẋ", "Y": "Ÿ", "Z": "Ẑ",
		"0": "⊘", "1": "⌐", "2": "⌠", "3": "⌡", "4": "∞", "5": "φ",
		"6": "ε", "7": "∩", "8": "≡", "9": "±"
	},
	"block_corruption": {
		"a": "█", "b": "▓", "c": "▒", "d": "░", "e": "■", "f": "□", "g": "▪",
		"h": "▫", "i": "▬", "j": "▭", "k": "▮", "l": "▯", "m": "▰", "n": "▱",
		"o": "▲", "p": "△", "q": "▼", "r": "▽", "s": "◆", "t": "◇", "u": "◈",
		"v": "◉", "w": "◊", "x": "○", "y": "◌", "z": "●",
		"A": "█", "B": "▓", "C": "▒", "D": "░", "E": "■", "F": "□", "G": "▪",
		"H": "▫", "I": "▬", "J": "▭", "K": "▮", "L": "▯", "M": "▰", "N": "▱",
		"O": "▲", "P": "△", "Q": "▼", "R": "▽", "S": "◆", "T": "◇", "U": "◈",
		"V": "◉", "W": "◊", "X": "○", "Y": "◌", "Z": "●",
		"0": "▓", "1": "░", "2": "▒", "3": "█", "4": "■", "5": "□",
		"6": "▪", "7": "▫", "8": "▬", "9": "▭"
	},
	"symbol_corruption": {
		"a": "∀", "b": "ß", "c": "¢", "d": "∂", "e": "€", "f": "ƒ", "g": "¶",
		"h": "ℏ", "i": "¡", "j": "∆", "k": "κ", "l": "λ", "m": "µ", "n": "η",
		"o": "Ω", "p": "π", "q": "θ", "r": "®", "s": "§", "t": "†", "u": "υ",
		"v": "√", "w": "ω", "x": "χ", "y": "¥", "z": "ζ",
		"A": "∀", "B": "ß", "C": "©", "D": "∂", "E": "€", "F": "ƒ", "G": "¶",
		"H": "ℏ", "I": "¡", "J": "∆", "K": "κ", "L": "λ", "M": "µ", "N": "η",
		"O": "Ω", "P": "π", "Q": "θ", "R": "®", "S": "§", "T": "†", "U": "υ",
		"V": "√", "W": "ω", "X": "χ", "Y": "¥", "Z": "ζ",
		"0": "⊘", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵",
		"6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"
	},
	"zalgo_lite": {
		"a": "a̧", "b": "b̨", "c": "c̶", "d": "d̷", "e": "e̸", "f": "f̴", "g": "g̵",
		"h": "ḩ", "i": "į", "j": "j̶", "k": "k̷", "l": "l̸", "m": "m̴", "n": "n̵",
		"o": "o̧", "p": "p̨", "q": "q̶", "r": "r̷", "s": "s̸", "t": "t̴", "u": "u̵",
		"v": "v̧", "w": "w̨", "x": "x̶", "y": "y̷", "z": "z̸",
		"A": "A̧", "B": "B̨", "C": "C̶", "D": "D̷", "E": "E̸", "F": "F̴", "G": "G̵",
		"H": "Ḩ", "I": "Į", "J": "J̶", "K": "K̷", "L": "L̸", "M": "M̴", "N": "N̵",
		"O": "O̧", "P": "P̨", "Q": "Q̶", "R": "R̷", "S": "S̸", "T": "T̴", "U": "U̵",
		"V": "V̧", "W": "W̨", "X": "X̶", "Y": "Y̷", "Z": "Z̸",
		"0": "0̧", "1": "1̨", "2": "2̶", "3": "3̷", "4": "4̸", "5": "5̴",
		"6": "6̵", "7": "7̧", "8": "8̨", "9": "9̶"
	}
}

# Current corruption settings
var corruption_enabled: bool = true
var corruption_probability: float = 0.3  # 30% chance per word
var current_corruption_set: String = "unicode_glitch"
var corruption_intensity: float = 1.0

# Word tracking for corruption consistency
var corrupted_words_cache: Dictionary = {}

func _ready() -> void:
	print("DDLC Corruption System loaded!")
	run_corruption_test()

## Corrupts entire words in a text string, maintaining word boundaries
func apply_corruption_to_text(text: String) -> String:
	if not corruption_enabled:
		return text

	var words: PackedStringArray = text.split(" ")
	var corrupted_words: PackedStringArray = []

	for word in words:
		if should_corrupt_word():
			var corrupted_word: String = corrupt_entire_word(word)
			corrupted_words.append(corrupted_word)
		else:
			corrupted_words.append(word)

	var result: String = " ".join(corrupted_words)

	if result != text:
		corruption_applied.emit(text, result)

	return result

## Determines if a word should be corrupted based on probability settings
func should_corrupt_word() -> bool:
	return randf() < (corruption_probability * corruption_intensity)

## Corrupts every character in a word completely
func corrupt_entire_word(word: String) -> String:
	if word.is_empty():
		return word

	# Check cache first for consistency
	var cache_key: String = word + "_" + current_corruption_set
	if corrupted_words_cache.has(cache_key):
		return corrupted_words_cache[cache_key]

	var corruption_map: Dictionary = CORRUPTION_SETS.get(current_corruption_set, CORRUPTION_SETS.unicode_glitch)
	var corrupted_result: String = ""

	for i in range(word.length()):
		var character: String = word[i]
		var corrupted_char: String = corruption_map.get(character, character)
		corrupted_result += corrupted_char

	# Cache the result for consistency
	corrupted_words_cache[cache_key] = corrupted_result

	return corrupted_result

## Corrupts a specific character using the current corruption set
func corrupt_character(character: String) -> String:
	var corruption_map: Dictionary = CORRUPTION_SETS.get(current_corruption_set, CORRUPTION_SETS.unicode_glitch)
	return corruption_map.get(character, character)

## Returns all available corruption set names
func get_available_corruption_sets() -> Array[String]:
	var sets: Array[String] = []
	for set_name in CORRUPTION_SETS.keys():
		sets.append(set_name)
	return sets

## Sets the active corruption character set
func set_corruption_set(set_name: String) -> void:
	if set_name in CORRUPTION_SETS:
		current_corruption_set = set_name
		corrupted_words_cache.clear()  # Clear cache when changing sets

## Sets corruption probability (0.0 to 1.0)
func set_corruption_probability(probability: float) -> void:
	corruption_probability = clamp(probability, 0.0, 1.0)

## Sets corruption intensity multiplier (0.0 to 2.0)
func set_corruption_intensity(intensity: float) -> void:
	corruption_intensity = clamp(intensity, 0.0, 2.0)

## Enables or disables corruption system
func set_corruption_enabled(enabled: bool) -> void:
	corruption_enabled = enabled

## Clears the corruption cache (useful when changing settings)
func clear_corruption_cache() -> void:
	corrupted_words_cache.clear()

## Gets current corruption statistics
func get_corruption_stats() -> Dictionary:
	return {
		"enabled": corruption_enabled,
		"probability": corruption_probability,
		"intensity": corruption_intensity,
		"current_set": current_corruption_set,
		"available_sets": get_available_corruption_sets(),
		"cache_size": corrupted_words_cache.size()
	}

## Preview what a text would look like corrupted (for settings UI)
func preview_corruption(text: String, set_name: String = "") -> String:
	var original_set: String = current_corruption_set
	var original_enabled: bool = corruption_enabled

	if not set_name.is_empty():
		current_corruption_set = set_name
	corruption_enabled = true

	var preview_result: String = apply_corruption_to_text(text)

	# Restore original settings
	current_corruption_set = original_set
	corruption_enabled = original_enabled

	return preview_result

## Applies day-specific corruption to text with specific corruption words
func apply_day_corruption(text: String, corruption_words: Array, corruption_type: String) -> String:
	if not corruption_enabled or corruption_type == "none":
		return text

	var words: PackedStringArray = text.split(" ")
	var corrupted_words: PackedStringArray = []

	for word in words:
		if word in corruption_words:
			# Always corrupt words that are in the corruption list
			var corrupted_word: String = _corrupt_word_with_type(word, corruption_type)
			corrupted_words.append(corrupted_word)
		else:
			# Leave normal words unchanged
			corrupted_words.append(word)

	var result: String = " ".join(corrupted_words)

	if result != text:
		corruption_applied.emit(text, result)

	return result

## Corrupts a word using a specific corruption type
func _corrupt_word_with_type(word: String, corruption_type: String) -> String:
	if word.is_empty():
		return word

	# Handle special corruption types
	match corruption_type:
		"caps":
			return word.to_upper()
		"none":
			return word
		_:
			# Use existing corruption sets
			var original_set = current_corruption_set
			set_corruption_set(corruption_type)
			var result = corrupt_entire_word(word)
			set_corruption_set(original_set)
			return result

## Sets up corruption for a specific day
func configure_for_day(day_number: int) -> void:
	match day_number:
		1:
			# Day 1: No corruption
			set_corruption_enabled(false)
		2:
			# Day 2: CAPS corruption
			set_corruption_enabled(true)
			set_corruption_set("unicode_glitch")  # Fallback, but we use caps in apply_day_corruption
			set_corruption_probability(0.0)  # We handle corruption manually in DayManager
		3:
			# Day 3: Unicode glitch
			set_corruption_enabled(true)
			set_corruption_set("unicode_glitch")
			set_corruption_probability(0.0)
		4:
			# Day 4: Zalgo lite
			set_corruption_enabled(true)
			set_corruption_set("zalgo_lite")
			set_corruption_probability(0.0)
		5:
			# Day 5: Symbol corruption
			set_corruption_enabled(true)
			set_corruption_set("symbol_corruption")
			set_corruption_probability(0.0)

## Debug function to test corruption functionality
func run_corruption_test() -> void:
	print("🎮 DDLC-Style Corruption System Test")
	print("====================================")

	var test_words: Array[String] = ["hello", "world", "test", "corruption", "ddlc"]

	for set_name in CORRUPTION_SETS.keys():
		print("\n📝 Testing corruption set: %s" % set_name)
		set_corruption_set(set_name)

		for word in test_words:
			var corrupted = corrupt_entire_word(word)
			print("   '%s' -> '%s'" % [word, corrupted])

	print("\n🎯 Testing day-specific corruption:")
	var test_corruption_words = ["SOMETHING", "WRONG"]
	var test_text = "the quick SOMETHING brown fox WRONG jumps"
	var corrupted_text = apply_day_corruption(test_text, test_corruption_words, "caps")

	print("Original:  %s" % test_text)
	print("Corrupted: %s" % corrupted_text)

	print("\n✅ Corruption system test completed!")
