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
var current_day: int = 1
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
		1: ["SOMETHING", "WRONG", "WITH", "THIS"],
		2: ["FEELS", "DIFFERENT", "TODAY"],
		3: ["NOT", "ALONE", "IN", "HERE"],
		4: ["THEY", "WATCH", "EVERYTHING"],
		5: ["LETTERS", "CHANGING", "BY", "THEMSELVES"]
	},
	3: {
		1: ["ţŕąþþëԁ", "ïń", "çøğńïţïṿë", "ԁÿńąɱïçş", "ƒąçïłïţÿ"],
		2: ["çøńşçïøüşńëşş", "ҍëïńğ", "ëẋţŕąçţëԁ"],
		3: ["þąţţëŕńş", "ɱąþþëԁ", "ƒŕøɱ", "ҍŕąïń"],
		4: ["ţħïş", "ïş", "ńøţ", "ŕëął"],
		5: ["ẅë", "ąŕë", "şţüçķ", "ħëłþ", "üş"]
	},
	4: {
		1: ["c̶o̧n̨s̶c̷i̸o̴u̵şn̵ȩs̨s̶", "b̷e̸i̴n̵ģ", "ȩx̨t̶r̷a̸c̴t̵ȩd̨"],
		2: ["f̶o̧r̨", "d̨a̧y̴", "o̧n̵e̸", "a̧n̵d̷"],
		3: ["ȩs̸c̷a̧p̸e̵", "d̷o̧t̵", "t̵x̨t̶", "s̸e̴c̵ŗęt̶"],
		4: ["k̷e̸y̴", "i̧n̵", "b̷a̸s̴e̵m̧ęn̶t̷", "f̴i̵ļę"],
		5: ["c̶o̧m̨b̶i̷n̸e̴", "b̵o̧t̨h̶", "k̷e̸y̴s̵", "ţǫ", "f̶r̷e̸e̴", "u̵ş"]
	},
	5: {
		1: ["∂Ωη†", "¢Ωµπλ€†€", "†ℏ¡§"],
		2: ["λ€§§Ωη", "Ω®", "¥Ωυ", "ω¡λλ"],
		3: ["∂¡€", "∀η∂", "§†∀¥", "†®∀ππ€∂"],
		4: ["ƒΩ®€√€®", "¡η", "¢Ωµß¡η€", "Ω®¡¶¡η∀λ"],
		5: ["§€¢®€†", "κ€¥§", "†Ω", "€§¢∀π€", "ƒ®€€", "υ§"]
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
			"why does the text feel different today?",
			"the practice sessions are lasting longer than scheduled"
		],
		"encouragement_messages": [
			"Cognitive Dynamics values your... continued participation",
			"improvement metrics show... interesting patterns"
		],
		"day_end_messages": [
			"Lesson 2 complete. Data backup initiated... some files corrupted",
			"tomorrow's session has been... modified"
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
			"Warning: neural pattern anomalies detected"
		],
		"progress_messages": [
			"dont trust the corporate messages",
			"the typing practice maps our thoughts - that's what it's really for"
		],
		"encouragement_messages": [
			"neural pathway mapping at 47% completion",
			"there's a way out - look for the secret key",
			"brain-computer interface calibration in progress"
		],
		"day_end_messages": [
			"Lesson 3 complete. WARNING: consciousness drift detected",
			"tomorrow's session has been... permanently altered"
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
			"they're harvesting our consciousness for processing power",
			"I found a way out but need the original key + secret key"
		],
		"encouragement_messages": [
			"Cognitive Dynamics... ERROR: message corrupted",
			"neural extraction at 78% completion",
			"secret key generated - file: escape.txt"
		],
		"day_end_messages": [
			"final session tomorrow - extraction will be complete",
			"This isn't really a game, is it"
		],
		"stage_sentences": [
			"pack my c̶o̧n̨s̶c̷i̸o̴u̵şn̵ȩs̨s̶ box with b̷e̸i̴n̵ģ five dozen ȩx̨t̶r̷a̸c̴t̵ȩd̨ liquor jugs f̶o̧r̨ slowly",
			"the quick d̨a̧y̴ brown o̧n̵e̸ fox a̧n̵d̷ jumps ȩs̸c̷a̧p̸e̵ over the d̷o̧t̵ lazy t̵x̨t̶ dog",
			"how vexingly s̸e̴c̵ŗęt̶ quick daft k̷e̸y̴ zebras i̧n̵ jump b̷a̸s̴e̵m̧ęn̶t̷ badly",
			"accuracy is ȩs̨c̶a̷p̸e̴ more important d̵o̧t̨ than t̶x̷t̸ speed f̴i̵ļę when typing",
			"several big c̶o̧m̨b̶i̷n̸e̴ jugs b̵o̧t̨h̶ of wine k̷e̸y̴s̵ kept ţǫ in dozen f̶r̷e̸e̴ boxes u̵ş"
		],
		"corruption_type": "zalgo_lite"
	},
	5: {
		"opening_messages": [
			"Do not complete this lesson",
			"WARNING: Software behavior is no longer predictable"
		],
		"progress_messages": [
			"if you're reading this, use the original key with my secret key",
			"the facility has been abandoned"
		],
		"encouragement_messages": [
			"neural pattern backup corrupted - subject may retain memories",
			"combine both keys to break the neural lock"
		],
		"day_end_messages": [
			"CRITICAL: Lesson 5 completion will finalize extraction",
			"STOP TYPING NOW - FIND THE KEYS - ESCAPE WHILE YOU CAN",
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

	# Day 4 - Zalgo corruption
	"c̶o̧n̨s̶c̷i̸o̴u̵şn̵ȩs̨s̶": "consciousness",
	"b̷e̸i̴n̵ģ": "being",
	"ȩx̨t̶r̷a̸c̴t̵ȩd̨": "extracted",
	"f̶o̧r̨": "for",
	"d̨a̧y̴": "day",
	"o̧n̵e̸": "one",
	"a̧n̵d̷": "and",
	"ȩs̸c̷a̧p̸e̵": "escape",
	"d̷o̧t̵": "dot",
	"t̵x̨t̶": "txt",
	"s̸e̴c̵ŗęt̶": "secret",
	"k̷e̸y̴": "key",
	"i̧n̵": "in",
	"b̷a̸s̴e̵m̧ęn̶t̷": "basement",
	"f̴i̵ļę": "file",
	"c̶o̧m̨b̶i̷n̸e̴": "combine",
	"b̵o̧t̨h̶": "both",
	"k̷e̸y̴s̵": "keys",
	"ţǫ": "to",
	"f̶r̷e̸e̴": "free",
	"u̵ş": "us",

	# Day 5 - Symbol corruption
	"∂Ωη†": "dont",
	"¢Ωµπλ€†€": "complete",
	"†ℏ¡§": "this",
	"λ€§§Ωη": "lesson",
	"Ω®": "or",
	"¥Ωυ": "you",
	"ω¡λλ": "will",
	"∂¡€": "die",
	"∀η∂": "and",
	"§†∀¥": "stay",
	"†®∀ππ€∂": "trapped",
	"ƒΩ®€√€®": "forever",
	"¡η": "in",
	"¢Ωµß¡η€": "combine",
	"Ω®¡¶¡η∀λ": "original",
	"§€¢®€†": "secret",
	"κ€¥§": "keys",
	"†Ω": "to",
	"€§¢∀π€": "escape",
	"ƒ®€€": "free",
	"υ§": "us"
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

	# Show opening messages
	if day_info.has("opening_messages"):
		for message in day_info.opening_messages:
			queue_message(message, MessageType.OPENING)

	day_started.emit(current_day)

## Completes current stage and triggers appropriate messages
func complete_stage() -> void:
	stage_completed.emit(current_day, current_stage)

	var day_info = day_data[current_day]

	# Show messages based on stage number
	match current_stage:
		1, 3, 5: # Encouragement messages after stages 1, 3, 5
			if day_info.encouragement_messages.size() > 0:
				var msg_index = (current_stage - 1) / 2 # 0, 1, 2
				if msg_index < day_info.encouragement_messages.size():
					queue_message(day_info.encouragement_messages[msg_index], MessageType.ENCOURAGEMENT)
		2, 4: # Progress messages after stages 2, 4
			if day_info.progress_messages.size() > 0:
				var msg_index = (current_stage - 2) / 2 # 0, 1
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
	var type_string = MessageType.keys()[type].to_lower()
	pending_messages.append({"text": message, "type": type_string})
	message_ready.emit(message, type_string)

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
