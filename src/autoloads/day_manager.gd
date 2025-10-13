extends Node

## Day progression manager for 5-day corruption story
## Handles day transitions, stage tracking, and message systems

signal day_started(day_number: int)
signal stage_completed(day: int, stage: int)
signal day_completed(day_number: int)
signal message_ready(message: String, message_type: String)

enum MessageType {
	OPENING,
	PROGRESS,
	ENCOURAGEMENT,
	DAY_END
}

# Current progression state
var current_day: int = 5
var current_stage: int = 1
var stages_per_day: int = 5
var total_days: int = 5

# Word pool for random sentence generation
var normal_word_pool: Array[String] = [
	"the", "and", "for", "are", "but", "not", "you", "all", "can", "had",
	"her", "was", "one", "our", "out", "day", "get", "has", "him", "his",
	"how", "its", "may", "new", "now", "old", "see", "two", "who", "boy",
	"did", "let", "man", "put", "say", "she", "too", "use", "way", "will",
	"about", "after", "again", "along", "among", "being", "below", "could",
	"every", "first", "found", "great", "group", "house", "large", "might",
	"never", "other", "place", "right", "small", "sound", "still", "such",
	"these", "think", "three", "under", "water", "where", "while", "world",
	"would", "write", "years", "young", "quick", "brown", "jumps", "over",
	"lazy", "pack", "with", "five", "dozen", "here", "more", "than", "when",
	"typing", "several", "big", "jugs", "wine", "kept", "boxes", "always"
]

# Corrupted words for each day and stage (these stay fixed)
var day_stage_corrupted_words: Dictionary = {
	1: {
		1: [], 2: [], 3: [], 4: [], 5: []  # Day 1 has no corruption
	},
	2: {
		1: ["SOMETHING", "WRONG", "WITH", "SYSTEM"],
		2: ["FEELS", "DIFFERENT", "TODAY"],
		3: ["NOT", "ALONE", "IN", "HERE"],
		4: ["EVENTS", "REPEAT", "ENDLESSLY"],
		5: ["PAST", "INFLUENCES", "PRESENT", "SECRETLY"]
	},
	3: {
		1: ["ţŕąþþëԁ", "ïń", "çøğńïţïṿë", "ԁÿńąɱïçş", "ƒąçïłïţÿ"],
		2: ["çøńşçïøüşńëşş", "ҍëïńğ", "ëẋţŕąçţëԁ"],
		3: ["þąţţëŕńş", "ɱąþþëԁ", "ƒŕøɱ", "ҍŕąïń"],
		4: ["ţħïş", "ïş", "ńøţ", "ŕëął"],
		5: ["ẅë", "ąŕë", "şţüçķ", "ħëłþ", "üş"]
	},
	4: {
		1: ["ssenssuoicsnoc", "gnieb", "detcartxe"],
		2: ["retne", "tcerroc", "dapyek", "yek"],
		3: ["uoy", "lliw ", "eb", "kcuts"],
		4: ["etinifedni", "etinifni", "lanrete"],
		5: ["uoy", "tonnac", "pots"]
	},
	5: {
		1: ["∂Ωη†", "¢Ωµπλ€†€", "†ℏ¡§", "λ€§§Ωη"],
		2: ["¥Ωυ", "ω¡λλ", "∂¡€"],
		3: ["∀ω∀®€η€§§", "¡§", "ƒ®∀gµ€η†€∂", "ƒΩ®€√€®"],
		4: ["¢®¡†¡¢∀λ", "λ€§§Ωη", "¡η¢Ωµπλ€†€"],
		5: ["ƒ¡η∀λ", "§€qu€η¢€", "¡η¡†¡∀†€∂"]
	}
}

# Day-specific data from markdown files
var day_data: Dictionary = {
	1: {
		"opening_messages": [
			"Welcome to TypingMaster Pro v2.3",
			"Thank you for choosing Cognitive Dynamics software solutions"
		],
		"progress_messages": [
			"Consistent practice leads to lasting improvement",
			"Professional typing standards require continued practice"
		],
		"encouragement_messages": [
			"Cognitive Dynamics appreciates your commitment to excellence",
			"Your dedication to improvement is commendable"
		],
		"day_end_messages": [
			"Lesson 1 complete. Great job today!"
		],
		"stage_sentences": [
			"about other sound way place years use she for put will who group place great would below you old can",
			"water small house are too young her again might old the her and man are water old could you house",
			"she found group and about will her world years such other sound first found small again but out has had",
			"place among for she other these water house about could would right who the great large might him her will",
			"man not you write how group our not found years put house use let sound man such day she use"
		],
		"corruption_type": "none"
	},
	2: {
		"opening_messages": [
			"Loading lesson 2... Error in user database detected... Continuing...",
			"Unable to clear cache from prior user, previous user session still active"
		],
		"progress_messages": [
			"Warning: Unable to verify text authenticity",
			"the practice sessions are lasting longer than scheduled"
		],
		"encouragement_messages": [
			"Cognitive Dynamics appreciates your unwavering repetition",
			"Improvement metrics no longer align with human learning models..."
		],
		"day_end_messages": [
			"Lesson 2 complete. Data backup initiated... some files corrupted",
		],
		"stage_sentences": [
			"the quick brown fox SOMETHING jumps over WRONG the lazy WITH dog THIS",
			"pack my box FEELS with five DIFFERENT dozen liquor TODAY jugs yesterday",
			"how vexingly NOT quick daft ALONE zebras jump IN here",
			"accuracy is THEY more important WATCH than speed EVERYTHING when typing",
			"several big LETTERS jugs CHANGING of wine BY kept THEMSELVES in dozen boxes"
		],
		"corruption_type": "caps"
	},
	3: {
		"opening_messages": [
			"Data backup initiated... some files corrupted",
			"secret key… same as… year of creation"
		],
		"progress_messages": [
			"Alerts may be deceptive — ignore at your own risk.",
			"the interface isn’t teaching — it’s absorbing"
		],
		"encouragement_messages": [
			"neural pathway mapping at 47% completion",
			"Warning: neural pattern anomalies detected",
			"brain-computer interface calibration in progress"
		],
		"day_end_messages": [
			"Lesson 3 complete. Warning: consciousness drift detected",
		],
		"stage_sentences": [
			"the quick ţŕąþþëԁ brown fox ïń jumps çøğńïţïṿë over the ԁÿńąɱïçş lazy ƒąçïłïţÿ dog",
			"pack my çøńşçïøüşńëşş box with ҍëïńğ five dozen ëẋţŕąçţëԁ liquor jugs ƒŕøɱ slowly",
			"how vexingly ҍŕąïń quick daft þąţţëŕńş zebras ҍëïńğ jump ɱąþþëԁ badly",
			"accuracy is ńøţ more important ŕëął than ńøţ speed ŕëął when typing",
			"several big ẅë jugs ąŕë of wine ńøţ kept çøɱþüţëŕş in dozen ħëłþ boxes üş"
		],
		"corruption_type": "unicode_glitch"
	},
	4: {
		"opening_messages": [
			"Warning: Unauthorized access detected",
			"Previous user session has been active for 847 days"
		],
		"progress_messages": [
			"Our consciousness is being partitioned into parallel minds.",
			"Type the secret code into the keypad, failure is certain otherwise."
		],
		"encouragement_messages": [
			"they're harvesting our consciousness for processing power",
			"neural extraction at 78% completion",
		],
		"day_end_messages": [
			"Lesson 4 complete. tomorrow's final session has been... permanently altered"
		],
		"stage_sentences": [
			"pack my ssenssuoicsnoc box with gnieb five dozen detcartxe liquor jugs rof slowly",
			"the quick yad brown eno fox dna jumps epacse over the tod lazy txt dog",
			"how vexingly terces quick daft yek zebras ni jump tnemesab badly",
			"accuracy is epacse more important tod than txt speed elif when typing",
			"several big enibmoc jugs htob of wine syek kept ot in dozen eerf boxes su"
		],
		"corruption_type": "reversed"
	},
	5: {
		"opening_messages": [
			"Do not complete this lesson",
			"WARNING: Software behavior is no longer predictable"
		],
		"progress_messages": [
			"If this message appears, the secret key was not entered on keypad three...",
			"the facility has been abandoned"
		],
		"encouragement_messages": [
			"neural pattern backup corrupted - subject may retain awareness during extraction",
			"CRITICAL: failed to reset behavioral loops"
		],
		"day_end_messages": [
			"The previous user session has ended"
		],
		"stage_sentences": [
			"the quick ∂Ωη† brown fox ¢Ωµπλ€†€ jumps †ℏ¡§ over the λ€§§Ωη lazy Ω® dog",
			"pack my ¥Ωυ box with ω¡λλ five dozen ∂¡€ liquor jugs ∀η∂ slowly",
			"how vexingly §†∀¥ quick daft †®∀ππ€∂ zebras ƒΩ®€√€® jump ¡η badly",
			"accuracy is ¢Ωµß¡η€ more important Ω®¡¶¡η∀λ than ∀η∂ speed §€¢®€† when typing",
			"several big κ€¥§ jugs †Ω of wine €§¢∀π€ kept ∀η∂ in dozen ƒ®€€ boxes υ§"
		],
		"corruption_type": "symbol_corruption"
	}
}

# Corruption-to-English word mappings for typing
var corruption_mappings: Dictionary = {
	# Day 2 - CAPS words
	"SOMETHING": "something",
	"WRONG": "wrong",
	"WITH": "with",
	"THIS": "this",
	"FEELS": "feels",
	"DIFFERENT": "different",
	"TODAY": "today",
	"NOT": "not",
	"ALONE": "alone",
	"IN": "in",
	"HERE": "here",
	"THEY": "they",
	"WATCH": "watch",
	"EVERYTHING": "everything",
	"LETTERS": "letters",
	"CHANGING": "changing",
	"BY": "by",
	"THEMSELVES": "themselves",

	# Day 3 - Unicode corruption
	"ţŕąþþëԁ": "trapped",
	"ïń": "in",
	"çøğńïţïṿë": "cognitive",
	"ԁÿńąɱïçş": "dynamics",
	"ƒąçïłïţÿ": "facility",
	"çøńşçïøüşńëşş": "consciousness",
	"ҍëïńğ": "being",
	"ëẋţŕąçţëԁ": "extracted",
	"ƒŕøɱ": "from",
	"ҍŕąïń": "brain",
	"þąţţëŕńş": "patterns",
	"ɱąþþëԁ": "mapped",
	"ńøţ": "not",
	"ŕëął": "real",
	"ẅë": "we",
	"ąŕë": "are",
	"çøɱþüţëŕş": "computers",
	"ħëłþ": "help",
	"üş": "us",

	# Day 4 - Reversed words (type what you see - no mappings needed)

	# Day 5 - Symbol corruption
	"∂Ωη†": "dont",
	"¢Ωµπλ€†€": "complete",
	"†ℏ¡§": "this",
	"λ€§§Ωη": "lesson",
	"¥Ωυ": "you",
	"ω¡λλ": "will",
	"∂¡€": "die",
	"∀η∂": "and",
	"∀ω∀®€η€§§": "awareness",
	"¡§": "is",
	"ƒ®∀gµ€η†€∂": "fragmented",
	"ƒΩ®€√€®": "forever",
	"¢®¡†¡¢∀λ": "critical",
	"¡η¢Ωµπλ€†€": "incomplete",
	"ƒ¡η∀λ": "final",
	"§€qu€η¢€": "sequence",
	"¡η¡†¡∀†€∂": "initiated",
}

# Message tracking
var pending_messages: Array = []
var message_queue_index: int = 0

# Cache for generated sentences to ensure consistency
var cached_stage_sentences: Dictionary = {}

func _ready() -> void:
	pass

## Starts a new day with opening messages
func start_day(day_number: int) -> void:
	current_day = day_number
	current_stage = 1

	if current_day > total_days:
		return

	# Clear cached sentences for new day
	cached_stage_sentences.clear()

	# Validate day number
	if not day_data.has(current_day):
		push_error("[DayManager] Invalid day number: %d" % current_day)
		return

	# Configure corruption for this day
	if CorruptionManager:
		CorruptionManager.configure_for_day(current_day)
	else:
		push_error("[DayManager] CorruptionManager not available")

	# Get day info for messages
	var day_info = day_data[current_day]

	# NOTE: Opening messages are now shown on the startup screen (handled by startup_screen_day_X.gd)
	# They are no longer queued here during the day scene initialization
	# if day_info.has("opening_messages"):
	# 	for message in day_info.opening_messages:
	# 		queue_message(message, MessageType.OPENING)

	day_started.emit(current_day)

## Completes current stage and triggers appropriate messages
func complete_stage() -> void:
	stage_completed.emit(current_day, current_stage)

	var day_info = day_data[current_day]

	# Show messages based on stage number
	match current_stage:
		1, 3, 5: # Encouragement messages after stages 1, 3, 5
			if day_info.encouragement_messages.size() > 0:
				var msg_index: int = (current_stage - 1) / 2 # 0, 1, 2
				if msg_index < day_info.encouragement_messages.size():
					queue_message(day_info.encouragement_messages[msg_index], MessageType.ENCOURAGEMENT)
		2, 4: # Progress messages after stages 2, 4
			if day_info.progress_messages.size() > 0:
				var msg_index: int = (current_stage - 2) / 2 # 0, 1
				if msg_index < day_info.progress_messages.size():
					queue_message(day_info.progress_messages[msg_index], MessageType.PROGRESS)

	current_stage += 1

	# Check if day is complete
	if current_stage > stages_per_day:
		complete_day()

## Completes current day and shows end messages
func complete_day() -> void:

	var day_info = day_data[current_day]

	# Show all day end messages
	for message in day_info.day_end_messages:
		queue_message(message, MessageType.DAY_END)

	day_completed.emit(current_day)

## Advances to next day
func advance_to_next_day() -> void:
	if current_day < total_days:
		start_day(current_day + 1)

## Generates typing text for current stage using randomized sentences
func generate_stage_text() -> String:
	# Get or generate the cached sentence for this stage
	var stage_key = "%d_%d" % [current_day, current_stage]
	if not cached_stage_sentences.has(stage_key):
		cached_stage_sentences[stage_key] = _generate_randomized_sentence(current_day)

	var randomized_sentence = cached_stage_sentences[stage_key]

	# Convert corrupted words to English for typing
	var english_sentence = _convert_corruption_to_english(randomized_sentence)

	return english_sentence

## Generates a randomized sentence with corrupted words mixed in
func _generate_randomized_sentence(day: int) -> String:
	# Get the specific corrupted words for this day and stage
	var day_stages = day_stage_corrupted_words.get(day, {})
	var stage_corrupted_words = day_stages.get(current_stage, [])

	# For Day 1 or stages without corruption, return random normal words
	if stage_corrupted_words.is_empty():
		var words: Array[String] = []
		for i in range(12):  # Generate 12 random words
			words.append(normal_word_pool[randi() % normal_word_pool.size()])
		return " ".join(words)

	# For other stages, mix specific corrupted words with random normal words
	var sentence_words: Array[String] = []

	# Generate sentence with 2-3 normal words between each corrupted word
	for i in range(stage_corrupted_words.size()):
		# Add 2-3 random normal words before each corrupted word
		var normal_count = 2 + randi() % 2  # 2 or 3 words
		for j in range(normal_count):
			sentence_words.append(normal_word_pool[randi() % normal_word_pool.size()])

		# Add the specific corrupted word for this stage
		sentence_words.append(stage_corrupted_words[i])

	# Add a few more normal words at the end
	var end_count = 2 + randi() % 2
	for i in range(end_count):
		sentence_words.append(normal_word_pool[randi() % normal_word_pool.size()])

	return " ".join(sentence_words)

## Converts corrupted words in a sentence to their English equivalents for typing
func _convert_corruption_to_english(corrupted_sentence: String) -> String:
	var words = corrupted_sentence.split(" ")
	var english_words: PackedStringArray = []

	for word in words:
		if corruption_mappings.has(word):
			# This is a corrupted word, replace with English equivalent
			english_words.append(corruption_mappings[word])
		else:
			# This is a normal word, keep as is
			english_words.append(word)

	return " ".join(english_words)

## Gets the original corrupted sentence for display purposes
func get_stage_display_sentence() -> String:
	# Get the same cached sentence used for typing
	var stage_key = "%d_%d" % [current_day, current_stage]
	if not cached_stage_sentences.has(stage_key):
		cached_stage_sentences[stage_key] = _generate_randomized_sentence(current_day)

	return cached_stage_sentences[stage_key]

## Queues a message for display
func queue_message(message: String, type: MessageType) -> void:
	var message_type_string = MessageType.keys()[type].to_lower()
	pending_messages.append({"text": message, "type": message_type_string})
	message_ready.emit(message, message_type_string)

## Gets next pending message
func get_next_message() -> Dictionary:
	if pending_messages.is_empty():
		return {}

	return pending_messages.pop_front()

## Checks if there are pending messages
func has_pending_messages() -> bool:
	return not pending_messages.is_empty()

## Gets current day info
func get_current_day_info() -> Dictionary:
	return day_data.get(current_day, {})

## Gets current progress info
func get_progress_info() -> Dictionary:
	return {
		"current_day": current_day,
		"current_stage": current_stage,
		"total_days": total_days,
		"stages_per_day": stages_per_day,
		"progress_percent": ((current_day - 1) * stages_per_day + (current_stage - 1)) / float(total_days * stages_per_day) * 100.0
	}

## Resets to day 1
func reset_progress() -> void:
	current_day = 1
	current_stage = 1
	pending_messages.clear()
	message_queue_index = 0
	start_day(1)
