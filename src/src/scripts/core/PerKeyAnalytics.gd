extends RefCounted
class_name PerKeyAnalytics

## Comprehensive per-key statistics and analysis system
## Tracks detailed metrics for each key including speed, accuracy, timing, and error patterns

signal key_performance_updated(key: String, metrics: Dictionary)
signal weakness_identified(key: String, weakness_type: String, severity: float)
signal improvement_detected(key: String, improvement_metric: String, change: float)

# Key position mapping for ergonomic analysis
const KEY_POSITIONS = {
	# Row 1 (numbers)
	"1": {"row": 1, "col": 1, "finger": "left_pinky", "hand": "left"},
	"2": {"row": 1, "col": 2, "finger": "left_ring", "hand": "left"},
	"3": {"row": 1, "col": 3, "finger": "left_middle", "hand": "left"},
	"4": {"row": 1, "col": 4, "finger": "left_index", "hand": "left"},
	"5": {"row": 1, "col": 5, "finger": "left_index", "hand": "left"},
	"6": {"row": 1, "col": 6, "finger": "right_index", "hand": "right"},
	"7": {"row": 1, "col": 7, "finger": "right_index", "hand": "right"},
	"8": {"row": 1, "col": 8, "finger": "right_middle", "hand": "right"},
	"9": {"row": 1, "col": 9, "finger": "right_ring", "hand": "right"},
	"0": {"row": 1, "col": 10, "finger": "right_pinky", "hand": "right"},

	# Row 2 (QWERTY)
	"q": {"row": 2, "col": 1, "finger": "left_pinky", "hand": "left"},
	"w": {"row": 2, "col": 2, "finger": "left_ring", "hand": "left"},
	"e": {"row": 2, "col": 3, "finger": "left_middle", "hand": "left"},
	"r": {"row": 2, "col": 4, "finger": "left_index", "hand": "left"},
	"t": {"row": 2, "col": 5, "finger": "left_index", "hand": "left"},
	"y": {"row": 2, "col": 6, "finger": "right_index", "hand": "right"},
	"u": {"row": 2, "col": 7, "finger": "right_index", "hand": "right"},
	"i": {"row": 2, "col": 8, "finger": "right_middle", "hand": "right"},
	"o": {"row": 2, "col": 9, "finger": "right_ring", "hand": "right"},
	"p": {"row": 2, "col": 10, "finger": "right_pinky", "hand": "right"},

	# Row 3 (ASDF - Home row)
	"a": {"row": 3, "col": 1, "finger": "left_pinky", "hand": "left", "home_row": true},
	"s": {"row": 3, "col": 2, "finger": "left_ring", "hand": "left", "home_row": true},
	"d": {"row": 3, "col": 3, "finger": "left_middle", "hand": "left", "home_row": true},
	"f": {"row": 3, "col": 4, "finger": "left_index", "hand": "left", "home_row": true},
	"g": {"row": 3, "col": 5, "finger": "left_index", "hand": "left"},
	"h": {"row": 3, "col": 6, "finger": "right_index", "hand": "right"},
	"j": {"row": 3, "col": 7, "finger": "right_index", "hand": "right", "home_row": true},
	"k": {"row": 3, "col": 8, "finger": "right_middle", "hand": "right", "home_row": true},
	"l": {"row": 3, "col": 9, "finger": "right_ring", "hand": "right", "home_row": true},

	# Row 4 (ZXCV)
	"z": {"row": 4, "col": 1, "finger": "left_pinky", "hand": "left"},
	"x": {"row": 4, "col": 2, "finger": "left_ring", "hand": "left"},
	"c": {"row": 4, "col": 3, "finger": "left_middle", "hand": "left"},
	"v": {"row": 4, "col": 4, "finger": "left_index", "hand": "left"},
	"b": {"row": 4, "col": 5, "finger": "left_index", "hand": "left"},
	"n": {"row": 4, "col": 6, "finger": "right_index", "hand": "right"},
	"m": {"row": 4, "col": 7, "finger": "right_index", "hand": "right"}
}

# Comprehensive key metrics storage
var key_metrics: Dictionary = {}
var session_data: Dictionary = {}
var historical_data: Dictionary = {}

# Analysis parameters
var analysis_window_size: int = 50  # Number of recent keystrokes to analyze
var trend_detection_sessions: int = 10  # Sessions for trend analysis
var weakness_threshold: float = 0.6  # Below this is considered weak
var improvement_threshold: float = 0.15  # Minimum improvement to detect

func _init() -> void:
	_initialize_key_metrics()

func _initialize_key_metrics() -> void:
	for key in KEY_POSITIONS.keys():
		key_metrics[key] = {
			# Basic performance metrics
			"total_attempts": 0,
			"correct_attempts": 0,
			"current_accuracy": 0.0,
			"lifetime_accuracy": 0.0,
			"average_speed": 0.0,  # Characters per minute
			"best_speed": 0.0,
			"consistency_score": 0.0,

			# Timing analysis
			"response_times": [],
			"speed_trend": [],
			"accuracy_trend": [],
			"recent_speeds": [],
			"keystroke_intervals": [],

			# Error analysis
			"error_types": {},
			"error_patterns": [],
			"substitution_errors": {},
			"timing_errors": 0,
			"consecutive_errors": 0,
			"max_error_streak": 0,

			# Learning progression
			"mastery_level": 0.0,
			"confidence_score": 0.0,
			"learning_velocity": 0.0,
			"plateau_detection": 0,
			"breakthrough_sessions": [],

			# Context analysis
			"preceding_keys": {},
			"following_keys": {},
			"bigram_performance": {},
			"trigram_performance": {},
			"position_in_word": {},

			# Ergonomic factors
			"finger_fatigue_score": 0.0,
			"hand_alternation_bonus": 0.0,
			"reach_difficulty": _calculate_reach_difficulty(key),
			"home_row_advantage": KEY_POSITIONS[key].get("home_row", false),

			# Session tracking
			"sessions_practiced": 0,
			"last_practice_time": 0.0,
			"practice_frequency": 0.0,
			"retention_score": 1.0,

			# Advanced metrics
			"micro_timing_variance": 0.0,
			"motor_memory_strength": 0.0,
			"cognitive_load_estimate": 0.0,
			"improvement_rate": 0.0,
			"skill_transfer_score": 0.0
		}

func _calculate_reach_difficulty(key: String) -> float:
	var pos: Dictionary = KEY_POSITIONS.get(key, {})
	var difficulty: float = 0.0

	# Distance from home row
	var home_row: int = 3
	var row_distance: int = abs(pos.get("row", 3) - home_row)
	difficulty += row_distance * 0.2

	# Finger stretch (pinky is harder)
	var finger: String = pos.get("finger", "")
	if "pinky" in finger:
		difficulty += 0.3
	elif "ring" in finger:
		difficulty += 0.1

	# Edge keys are harder
	var col: int = pos.get("col", 5)
	if col <= 2 or col >= 9:
		difficulty += 0.2

	return clamp(difficulty, 0.0, 1.0)

func record_keystroke(key: String, is_correct: bool, response_time: float, context: Dictionary = {}) -> void:
	key = key.to_lower()
	if not key_metrics.has(key):
		return

	var metrics: Dictionary = key_metrics[key]
	var current_time: float = Time.get_unix_time_from_system()

	# Update basic metrics
	metrics.total_attempts += 1
	if is_correct:
		metrics.correct_attempts += 1

	# Update accuracy
	metrics.current_accuracy = float(metrics.correct_attempts) / float(metrics.total_attempts)
	metrics.lifetime_accuracy = metrics.current_accuracy

	# Update speed metrics
	if is_correct and response_time > 0:
		var cpm: float = 60.0 / response_time  # Characters per minute
		metrics.recent_speeds.append(cpm)

		# Keep only recent speeds for current average
		if metrics.recent_speeds.size() > analysis_window_size:
			metrics.recent_speeds.pop_front()

		# Calculate current average speed
		var total_speed: float = 0.0
		for speed in metrics.recent_speeds:
			total_speed += speed
		metrics.average_speed = total_speed / metrics.recent_speeds.size()

		# Update best speed
		if cpm > metrics.best_speed:
			metrics.best_speed = cpm

		# Store for trend analysis
		metrics.speed_trend.append({"time": current_time, "speed": cpm})
		if metrics.speed_trend.size() > 100:
			metrics.speed_trend.pop_front()

	# Update timing analysis
	metrics.response_times.append(response_time)
	if metrics.response_times.size() > analysis_window_size:
		metrics.response_times.pop_front()

	# Error analysis
	if not is_correct:
		_analyze_error(key, context)
		metrics.consecutive_errors += 1
		if metrics.consecutive_errors > metrics.max_error_streak:
			metrics.max_error_streak = metrics.consecutive_errors
	else:
		metrics.consecutive_errors = 0

	# Context analysis
	_analyze_keystroke_context(key, context)

	# Update advanced metrics
	_update_advanced_metrics(key)

	# Update session tracking
	metrics.last_practice_time = current_time
	metrics.sessions_practiced += 1

	# Emit performance update
	key_performance_updated.emit(key, _get_key_summary(key))

	# Check for weaknesses and improvements
	_detect_performance_changes(key)

func _analyze_error(key: String, context: Dictionary) -> void:
	var metrics: Dictionary = key_metrics[key]

	# Categorize error type
	var error_type: String = _classify_error_type(key, context)
	metrics.error_types[error_type] = metrics.error_types.get(error_type, 0) + 1

	# Track substitution patterns
	var typed_key: String = context.get("typed_key", "")
	if typed_key != "":
		metrics.substitution_errors[typed_key] = metrics.substitution_errors.get(typed_key, 0) + 1

	# Timing-based error detection
	var response_time: float = context.get("response_time", 0.0)
	if response_time > 2.0:  # Very slow response
		metrics.timing_errors += 1

	# Store error pattern
	var error_pattern: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"error_type": error_type,
		"context": context.duplicate()
	}
	metrics.error_patterns.append(error_pattern)

	# Keep only recent errors
	if metrics.error_patterns.size() > 50:
		metrics.error_patterns.pop_front()

func _classify_error_type(key: String, context: Dictionary) -> String:
	var typed_key: String = context.get("typed_key", "")
	var response_time: float = context.get("response_time", 0.0)

	# Physical proximity errors
	if _are_keys_adjacent(key, typed_key):
		return "adjacent_key"

	# Same finger errors
	if _same_finger_keys(key, typed_key):
		return "same_finger"

	# Speed-related errors
	if response_time < 0.1:
		return "too_fast"
	elif response_time > 2.0:
		return "too_slow"

	# Hand coordination errors
	if _different_hand_keys(key, typed_key):
		return "hand_confusion"

	return "other"

func _are_keys_adjacent(key1: String, key2: String) -> bool:
	var pos1: Dictionary = KEY_POSITIONS.get(key1, {})
	var pos2: Dictionary = KEY_POSITIONS.get(key2, {})

	if pos1.is_empty() or pos2.is_empty():
		return false

	var row_diff: int = abs(pos1.row - pos2.row)
	var col_diff: int = abs(pos1.col - pos2.col)

	return row_diff <= 1 and col_diff <= 1

func _same_finger_keys(key1: String, key2: String) -> bool:
	var pos1: Dictionary = KEY_POSITIONS.get(key1, {})
	var pos2: Dictionary = KEY_POSITIONS.get(key2, {})

	return pos1.get("finger", "") == pos2.get("finger", "")

func _different_hand_keys(key1: String, key2: String) -> bool:
	var pos1: Dictionary = KEY_POSITIONS.get(key1, {})
	var pos2: Dictionary = KEY_POSITIONS.get(key2, {})

	return pos1.get("hand", "") != pos2.get("hand", "")

func _analyze_keystroke_context(key: String, context: Dictionary) -> void:
	var metrics: Dictionary = key_metrics[key]

	# Track preceding and following keys
	var preceding_key: String = context.get("preceding_key", "")
	var following_key: String = context.get("following_key", "")

	if preceding_key != "":
		metrics.preceding_keys[preceding_key] = metrics.preceding_keys.get(preceding_key, 0) + 1

	if following_key != "":
		metrics.following_keys[following_key] = metrics.following_keys.get(following_key, 0) + 1

	# Bigram analysis
	if preceding_key != "":
		var bigram: String = preceding_key + key
		var bigram_perf: Dictionary = metrics.bigram_performance.get(bigram, {"attempts": 0, "correct": 0})
		bigram_perf.attempts += 1
		if context.get("is_correct", false):
			bigram_perf.correct += 1
		metrics.bigram_performance[bigram] = bigram_perf

	# Position in word analysis
	var word_position: int = context.get("word_position", -1)
	if word_position >= 0:
		var pos_data: Dictionary = metrics.position_in_word.get(str(word_position), {"attempts": 0, "correct": 0})
		pos_data.attempts += 1
		if context.get("is_correct", false):
			pos_data.correct += 1
		metrics.position_in_word[str(word_position)] = pos_data

func _update_advanced_metrics(key: String) -> void:
	var metrics: Dictionary = key_metrics[key]

	# Calculate consistency score
	if metrics.response_times.size() >= 10:
		var times_array: Array[float] = []
		for time in metrics.response_times:
			times_array.append(time)
		metrics.consistency_score = _calculate_consistency(times_array)

	# Calculate micro-timing variance
	if metrics.recent_speeds.size() >= 5:
		var speed_array: Array[float] = []
		for speed in metrics.recent_speeds:
			speed_array.append(speed)
		metrics.micro_timing_variance = _calculate_variance(speed_array)

	# Update mastery level
	metrics.mastery_level = _calculate_mastery_level(key)

	# Calculate confidence score
	metrics.confidence_score = _calculate_confidence_score(key)

	# Update learning velocity
	if metrics.speed_trend.size() >= 5:
		metrics.learning_velocity = _calculate_learning_velocity(key)

	# Detect plateaus
	_detect_learning_plateau(key)

	# Calculate motor memory strength
	metrics.motor_memory_strength = _calculate_motor_memory_strength(key)

func _calculate_consistency(times: Array[float]) -> float:
	if times.size() < 2:
		return 0.0

	var mean: float = 0.0
	for time in times:
		mean += time
	mean /= times.size()

	var variance: float = 0.0
	for time in times:
		variance += pow(time - mean, 2)
	variance /= times.size()

	var std_dev: float = sqrt(variance)
	var coefficient_of_variation: float = std_dev / mean if mean > 0 else 1.0

	# Lower CV = higher consistency
	return clamp(1.0 - coefficient_of_variation, 0.0, 1.0)

func _calculate_variance(values: Array[float]) -> float:
	if values.size() < 2:
		return 0.0

	var mean: float = 0.0
	for value in values:
		mean += value
	mean /= values.size()

	var variance: float = 0.0
	for value in values:
		variance += pow(value - mean, 2)

	return variance / values.size()

func _calculate_mastery_level(key: String) -> float:
	var metrics: Dictionary = key_metrics[key]

	var accuracy_factor: float = metrics.current_accuracy
	var speed_factor: float = min(metrics.average_speed / 300.0, 1.0)  # Normalize to 300 CPM max
	var consistency_factor: float = metrics.consistency_score
	var confidence_factor: float = metrics.confidence_score

	return (accuracy_factor + speed_factor + consistency_factor + confidence_factor) / 4.0

func _calculate_confidence_score(key: String) -> float:
	var metrics: Dictionary = key_metrics[key]

	# Statistical confidence based on sample size and accuracy
	var n: float = float(metrics.total_attempts)
	if n < 10:
		return 0.0

	var p: float = metrics.current_accuracy
	var margin_of_error: float = 1.96 * sqrt((p * (1.0 - p)) / n)  # 95% confidence interval

	return clamp(1.0 - (margin_of_error * 2.0), 0.0, 1.0)

func _calculate_learning_velocity(key: String) -> float:
	var metrics: Dictionary = key_metrics[key]
	var trend: Array = metrics.speed_trend

	if trend.size() < 5:
		return 0.0

	# Linear regression on speed over time
	var n: float = float(trend.size())
	var sum_x: float = 0.0
	var sum_y: float = 0.0
	var sum_xy: float = 0.0
	var sum_x2: float = 0.0

	for i in range(trend.size()):
		var x: float = float(i)
		var y: float = trend[i].speed
		sum_x += x
		sum_y += y
		sum_xy += x * y
		sum_x2 += x * x

	var slope: float = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
	return slope  # Positive = improving, negative = declining

func _detect_learning_plateau(key: String) -> void:
	var metrics: Dictionary = key_metrics[key]

	# Check if recent performance has been flat
	if metrics.learning_velocity < 0.1 and metrics.learning_velocity > -0.1:
		metrics.plateau_detection += 1
	else:
		metrics.plateau_detection = 0

	# Detect breakthrough sessions
	if metrics.learning_velocity > 5.0:  # Significant improvement
		metrics.breakthrough_sessions.append(Time.get_unix_time_from_system())
		if metrics.breakthrough_sessions.size() > 10:
			metrics.breakthrough_sessions.pop_front()

func _calculate_motor_memory_strength(key: String) -> float:
	var metrics: Dictionary = key_metrics[key]

	# Based on consistency, automaticity (low response time variance), and retention
	var consistency: float = metrics.consistency_score
	var automaticity: float = 1.0 / (1.0 + metrics.micro_timing_variance)
	var retention: float = metrics.retention_score

	return (consistency + automaticity + retention) / 3.0

func _detect_performance_changes(key: String) -> void:
	var metrics: Dictionary = key_metrics[key]

	# Detect weaknesses
	if metrics.mastery_level < weakness_threshold:
		var weakness_type: String = _identify_primary_weakness(key)
		var severity: float = 1.0 - metrics.mastery_level
		weakness_identified.emit(key, weakness_type, severity)

	# Detect improvements
	if metrics.speed_trend.size() >= 5:
		var recent_improvement: float = _calculate_recent_improvement(key)
		if recent_improvement > improvement_threshold:
			improvement_detected.emit(key, "speed", recent_improvement)

func _identify_primary_weakness(key: String) -> String:
	var metrics: Dictionary = key_metrics[key]

	if metrics.current_accuracy < 0.8:
		return "accuracy"
	elif metrics.average_speed < 120:  # Less than 120 CPM
		return "speed"
	elif metrics.consistency_score < 0.6:
		return "consistency"
	elif metrics.consecutive_errors > 3:
		return "error_prone"
	else:
		return "general"

func _calculate_recent_improvement(key: String) -> float:
	var metrics: Dictionary = key_metrics[key]
	var trend: Array = metrics.speed_trend

	if trend.size() < 10:
		return 0.0

	var recent_half: Array = trend.slice(-5)
	var previous_half: Array = trend.slice(-10, -5)

	var recent_avg: float = 0.0
	for entry in recent_half:
		recent_avg += entry.speed
	recent_avg /= recent_half.size()

	var previous_avg: float = 0.0
	for entry in previous_half:
		previous_avg += entry.speed
	previous_avg /= previous_half.size()

	return (recent_avg - previous_avg) / previous_avg if previous_avg > 0 else 0.0

func get_key_detailed_analysis(key: String) -> Dictionary:
	if not key_metrics.has(key):
		return {}

	var metrics: Dictionary = key_metrics[key]
	var analysis: Dictionary = {}

	# Performance summary
	analysis.performance = {
		"accuracy": metrics.current_accuracy,
		"speed_cpm": metrics.average_speed,
		"mastery_level": metrics.mastery_level,
		"consistency": metrics.consistency_score,
		"confidence": metrics.confidence_score
	}

	# Error analysis
	analysis.errors = {
		"total_errors": metrics.total_attempts - metrics.correct_attempts,
		"error_rate": 1.0 - metrics.current_accuracy,
		"max_error_streak": metrics.max_error_streak,
		"common_error_types": _get_top_error_types(key),
		"substitution_patterns": _get_top_substitutions(key)
	}

	# Learning progression
	analysis.learning = {
		"learning_velocity": metrics.learning_velocity,
		"plateau_sessions": metrics.plateau_detection,
		"breakthrough_count": metrics.breakthrough_sessions.size(),
		"motor_memory_strength": metrics.motor_memory_strength
	}

	# Context patterns
	analysis.context = {
		"difficult_bigrams": _get_difficult_bigrams(key),
		"problematic_positions": _get_problematic_positions(key),
		"finger_conflicts": _get_finger_conflicts(key)
	}

	# Recommendations
	analysis.recommendations = _generate_key_recommendations(key)

	return analysis

func _get_key_summary(key: String) -> Dictionary:
	if not key_metrics.has(key):
		return {}

	var metrics: Dictionary = key_metrics[key]
	return {
		"accuracy": metrics.current_accuracy,
		"speed": metrics.average_speed,
		"mastery": metrics.mastery_level,
		"consistency": metrics.consistency_score,
		"total_attempts": metrics.total_attempts
	}

func _get_top_error_types(key: String) -> Array[Dictionary]:
	var metrics: Dictionary = key_metrics[key]
	var error_types: Dictionary = metrics.error_types

	var sorted_errors: Array[Dictionary] = []
	for error_type in error_types:
		sorted_errors.append({"type": error_type, "count": error_types[error_type]})

	sorted_errors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.count > b.count)
	return sorted_errors.slice(0, 3)  # Top 3

func _get_top_substitutions(key: String) -> Array[Dictionary]:
	var metrics: Dictionary = key_metrics[key]
	var substitutions: Dictionary = metrics.substitution_errors

	var sorted_subs: Array[Dictionary] = []
	for sub_key in substitutions:
		sorted_subs.append({"substituted_key": sub_key, "count": substitutions[sub_key]})

	sorted_subs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.count > b.count)
	return sorted_subs.slice(0, 3)  # Top 3

func _get_difficult_bigrams(key: String) -> Array[String]:
	var metrics: Dictionary = key_metrics[key]
	var bigrams: Dictionary = metrics.bigram_performance

	var difficult: Array[String] = []
	for bigram in bigrams:
		var perf: Dictionary = bigrams[bigram]
		var accuracy: float = float(perf.correct) / float(perf.attempts) if perf.attempts > 0 else 1.0
		if accuracy < 0.7 and perf.attempts >= 5:
			difficult.append(bigram)

	return difficult

func _get_problematic_positions(key: String) -> Array[int]:
	var metrics: Dictionary = key_metrics[key]
	var positions: Dictionary = metrics.position_in_word

	var problematic: Array[int] = []
	for pos_str in positions:
		var perf: Dictionary = positions[pos_str]
		var accuracy: float = float(perf.correct) / float(perf.attempts) if perf.attempts > 0 else 1.0
		if accuracy < 0.7 and perf.attempts >= 3:
			problematic.append(int(pos_str))

	return problematic

func _get_finger_conflicts(key: String) -> Array[String]:
	var metrics: Dictionary = key_metrics[key]
	var conflicts: Array[String] = []

	var key_finger: String = KEY_POSITIONS.get(key, {}).get("finger", "")

	for error_key in metrics.substitution_errors:
		var error_finger: String = KEY_POSITIONS.get(error_key, {}).get("finger", "")
		if error_finger == key_finger and metrics.substitution_errors[error_key] >= 3:
			conflicts.append(error_key)

	return conflicts

func _generate_key_recommendations(key: String) -> Array[String]:
	var recommendations: Array[String] = []
	var analysis: Dictionary = get_key_detailed_analysis(key)

	# Accuracy recommendations
	if analysis.performance.accuracy < 0.8:
		recommendations.append("Focus on accuracy over speed for this key")

	# Speed recommendations
	if analysis.performance.speed_cpm < 120:
		recommendations.append("Practice this key in isolation to build muscle memory")

	# Consistency recommendations
	if analysis.performance.consistency < 0.6:
		recommendations.append("Practice rhythmic typing patterns with this key")

	# Error-specific recommendations
	var error_types: Array = analysis.errors.get("common_error_types", [])
	for error_dict in error_types:
		var error_type: String = error_dict.type
		match error_type:
			"adjacent_key":
				recommendations.append("Slow down to avoid hitting adjacent keys")
			"same_finger":
				recommendations.append("Practice finger independence exercises")
			"too_fast":
				recommendations.append("Reduce typing speed to improve accuracy")
			"hand_confusion":
				recommendations.append("Practice hand alternation patterns")

	return recommendations

func export_detailed_report(key: String) -> String:
	var analysis: Dictionary = get_key_detailed_analysis(key)
	var report: String = ""

	report += "=== DETAILED KEY ANALYSIS: %s ===\n\n" % key.to_upper()

	# Performance overview
	var perf: Dictionary = analysis.performance
	report += "PERFORMANCE OVERVIEW:\n"
	report += "Accuracy: %.1f%%\n" % (perf.accuracy * 100.0)
	report += "Speed: %.0f CPM\n" % perf.speed_cpm
	report += "Mastery Level: %.1f%%\n" % (perf.mastery_level * 100.0)
	report += "Consistency: %.1f%%\n" % (perf.consistency * 100.0)
	report += "Confidence: %.1f%%\n\n" % (perf.confidence * 100.0)

	# Error analysis
	var errors: Dictionary = analysis.errors
	report += "ERROR ANALYSIS:\n"
	report += "Total Errors: %d\n" % errors.total_errors
	report += "Error Rate: %.1f%%\n" % (errors.error_rate * 100.0)
	report += "Max Error Streak: %d\n\n" % errors.max_error_streak

	# Recommendations
	var recs: Array = analysis.recommendations
	if not recs.is_empty():
		report += "RECOMMENDATIONS:\n"
		for rec in recs:
			report += "• %s\n" % rec

	return report

func get_overall_statistics() -> Dictionary:
	var stats: Dictionary = {
		"total_keys_analyzed": key_metrics.size(),
		"average_accuracy": 0.0,
		"average_speed": 0.0,
		"average_mastery": 0.0,
		"weakest_keys": [],
		"strongest_keys": [],
		"most_improved_keys": []
	}

	var total_accuracy: float = 0.0
	var total_speed: float = 0.0
	var total_mastery: float = 0.0
	var key_count: int = 0

	var key_performances: Array[Dictionary] = []

	for key in key_metrics:
		var metrics: Dictionary = key_metrics[key]
		if metrics.total_attempts > 0:
			total_accuracy += metrics.current_accuracy
			total_speed += metrics.average_speed
			total_mastery += metrics.mastery_level
			key_count += 1

			key_performances.append({
				"key": key,
				"mastery": metrics.mastery_level,
				"improvement": metrics.learning_velocity
			})

	if key_count > 0:
		stats.average_accuracy = total_accuracy / key_count
		stats.average_speed = total_speed / key_count
		stats.average_mastery = total_mastery / key_count

	# Sort and get top/bottom performers
	key_performances.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.mastery > b.mastery)

	# Get strongest and weakest keys
	var strong_count: int = min(5, key_performances.size())
	var weak_count: int = min(5, key_performances.size())

	for i in range(strong_count):
		stats.strongest_keys.append(key_performances[i].key)

	for i in range(weak_count):
		stats.weakest_keys.append(key_performances[key_performances.size() - 1 - i].key)

	# Sort by improvement and get most improved
	key_performances.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.improvement > b.improvement)
	var improved_count: int = min(5, key_performances.size())
	for i in range(improved_count):
		if key_performances[i].improvement > 0:
			stats.most_improved_keys.append(key_performances[i].key)

	return stats
