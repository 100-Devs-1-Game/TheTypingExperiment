extends Node

## Manages typing statistics, progress tracking, and persistent data
## Handles WPM/accuracy analytics and user progress storage

signal stats_updated(wpm: float, accuracy: float)
signal new_personal_best(metric: String, value: float)
signal achievement_unlocked(achievement_name: String)

const SAVE_FILE_PATH: String = "user://typing_stats.save"

var session_stats: Dictionary = {}
var lifetime_stats: Dictionary = {}
var personal_bests: Dictionary = {}
var achievements: Dictionary = {}

var current_session_wpm: float = 0.0
var current_session_accuracy: float = 100.0
var current_session_keystrokes: int = 0
var current_session_time: float = 0.0

func _ready() -> void:
	_initialize_stats()
	load_stats()

func _initialize_stats() -> void:
	session_stats = {
		"start_time": 0.0,
		"end_time": 0.0,
		"total_keystrokes": 0,
		"correct_keystrokes": 0,
		"words_typed": 0,
		"errors_made": 0,
		"peak_wpm": 0.0,
		"average_wpm": 0.0,
		"final_accuracy": 0.0
	}

	lifetime_stats = {
		"total_sessions": 0,
		"total_time_practiced": 0.0,
		"total_keystrokes": 0,
		"total_words_typed": 0,
		"total_errors": 0,
		"best_wpm": 0.0,
		"best_accuracy": 0.0,
		"average_wpm": 0.0,
		"average_accuracy": 0.0,
		"letters_mastered": [],
		"current_streak": 0,
		"longest_streak": 0
	}

	personal_bests = {
		"fastest_wpm": 0.0,
		"highest_accuracy": 0.0,
		"longest_session": 0.0,
		"most_words_in_session": 0,
		"fastest_improvement": 0.0
	}

	achievements = {
		"first_session": false,
		"reach_30_wpm": false,
		"reach_60_wpm": false,
		"reach_100_wpm": false,
		"perfect_accuracy": false,
		"ten_sessions": false,
		"hundred_sessions": false,
		"master_all_letters": false,
		"speed_demon": false,
		"accuracy_expert": false
	}

func start_session() -> void:
	session_stats.start_time = Time.get_unix_time_from_system()
	session_stats.total_keystrokes = 0
	session_stats.correct_keystrokes = 0
	session_stats.words_typed = 0
	session_stats.errors_made = 0
	session_stats.peak_wpm = 0.0

	current_session_wpm = 0.0
	current_session_accuracy = 100.0
	current_session_keystrokes = 0
	current_session_time = 0.0

func update_session_stats(wpm: float, accuracy: float, keystrokes: int, time_elapsed: float) -> void:
	current_session_wpm = wpm
	current_session_accuracy = accuracy
	current_session_keystrokes = keystrokes
	current_session_time = time_elapsed

	if wpm > session_stats.peak_wpm:
		session_stats.peak_wpm = wpm

	session_stats.total_keystrokes = keystrokes
	session_stats.correct_keystrokes = int(keystrokes * (accuracy / 100.0))
	session_stats.errors_made = keystrokes - session_stats.correct_keystrokes

	# Store adaptive learning progress
	_track_learning_progress()

	stats_updated.emit(wpm, accuracy)
	_check_personal_bests()

func end_session() -> void:
	session_stats.end_time = Time.get_unix_time_from_system()
	session_stats.final_accuracy = current_session_accuracy
	session_stats.average_wpm = current_session_wpm

	_update_lifetime_stats()
	_check_achievements()
	save_stats()

func _update_lifetime_stats() -> void:
	lifetime_stats.total_sessions += 1
	var session_duration: float = session_stats.end_time - session_stats.start_time
	lifetime_stats.total_time_practiced += session_duration
	lifetime_stats.total_keystrokes += session_stats.total_keystrokes
	lifetime_stats.total_words_typed += session_stats.words_typed
	lifetime_stats.total_errors += session_stats.errors_made

	if current_session_wpm > lifetime_stats.best_wpm:
		lifetime_stats.best_wpm = current_session_wpm

	if current_session_accuracy > lifetime_stats.best_accuracy:
		lifetime_stats.best_accuracy = current_session_accuracy

	# Calculate running averages
	var total_sessions: float = float(lifetime_stats.total_sessions)
	lifetime_stats.average_wpm = ((lifetime_stats.average_wpm * (total_sessions - 1)) + current_session_wpm) / total_sessions
	lifetime_stats.average_accuracy = ((lifetime_stats.average_accuracy * (total_sessions - 1)) + current_session_accuracy) / total_sessions

	# Update streak
	if current_session_accuracy >= 90.0:
		lifetime_stats.current_streak += 1
		if lifetime_stats.current_streak > lifetime_stats.longest_streak:
			lifetime_stats.longest_streak = lifetime_stats.current_streak
	else:
		lifetime_stats.current_streak = 0

func _check_personal_bests() -> void:
	var new_best: bool = false

	if current_session_wpm > personal_bests.fastest_wpm:
		personal_bests.fastest_wpm = current_session_wpm
		new_personal_best.emit("WPM", current_session_wpm)
		new_best = true

	if current_session_accuracy > personal_bests.highest_accuracy:
		personal_bests.highest_accuracy = current_session_accuracy
		new_personal_best.emit("Accuracy", current_session_accuracy)
		new_best = true

	if current_session_time > personal_bests.longest_session:
		personal_bests.longest_session = current_session_time
		new_personal_best.emit("Session Length", current_session_time)
		new_best = true

func _check_achievements() -> void:
	if not achievements.first_session:
		achievements.first_session = true
		achievement_unlocked.emit("First Steps")

	if current_session_wpm >= 30.0 and not achievements.reach_30_wpm:
		achievements.reach_30_wpm = true
		achievement_unlocked.emit("Speed Walker")

	if current_session_wpm >= 60.0 and not achievements.reach_60_wpm:
		achievements.reach_60_wpm = true
		achievement_unlocked.emit("Speed Runner")

	if current_session_wpm >= 100.0 and not achievements.reach_100_wpm:
		achievements.reach_100_wpm = true
		achievement_unlocked.emit("Speed Demon")

	if current_session_accuracy >= 100.0 and not achievements.perfect_accuracy:
		achievements.perfect_accuracy = true
		achievement_unlocked.emit("Perfectionist")

	if lifetime_stats.total_sessions >= 10 and not achievements.ten_sessions:
		achievements.ten_sessions = true
		achievement_unlocked.emit("Dedicated Learner")

	if lifetime_stats.total_sessions >= 100 and not achievements.hundred_sessions:
		achievements.hundred_sessions = true
		achievement_unlocked.emit("Typing Master")

func _track_learning_progress() -> void:
	# Store current learning state from TypingEngine
	var learning_data: Dictionary = TypingEngine.get_learning_progress()
	var _session_data: Dictionary = TypingEngine.export_session_data()

	# Add timestamp and session info
	var progress_entry: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"wpm": current_session_wpm,
		"accuracy": current_session_accuracy,
		"learning_data": learning_data,
		"session_duration": current_session_time,
		"keystrokes": current_session_keystrokes
	}

	# Store in lifetime stats for trend analysis
	if not lifetime_stats.has("progress_history"):
		lifetime_stats.progress_history = []

	lifetime_stats.progress_history.append(progress_entry)

	# Keep only last 100 session records to manage file size
	if lifetime_stats.progress_history.size() > 100:
		lifetime_stats.progress_history.pop_front()

func save_stats() -> void:
	var save_data: Dictionary = {
		"lifetime_stats": lifetime_stats,
		"personal_bests": personal_bests,
		"achievements": achievements,
		"adaptive_data": TypingEngine.export_session_data() if TypingEngine else {},
		"save_timestamp": Time.get_unix_time_from_system(),
		"version": "2.0"
	}

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

	# Also create a backup
	_create_backup(save_data)

func _create_backup(save_data: Dictionary) -> void:
	var backup_path: String = "user://typing_stats_backup.save"
	var file: FileAccess = FileAccess.open(backup_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_stats() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		_try_load_backup()
		return

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close()

		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)

		if parse_result == OK:
			var save_data: Dictionary = json.data
			_load_save_data(save_data)
		else:
			print("Error parsing save file, trying backup...")
			_try_load_backup()

func _try_load_backup() -> void:
	var backup_path: String = "user://typing_stats_backup.save"
	if not FileAccess.file_exists(backup_path):
		return

	var file: FileAccess = FileAccess.open(backup_path, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close()

		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)

		if parse_result == OK:
			var save_data: Dictionary = json.data
			_load_save_data(save_data)
			print("Loaded from backup file")

func _load_save_data(save_data: Dictionary) -> void:
	if save_data.has("lifetime_stats"):
		lifetime_stats = save_data.lifetime_stats
	if save_data.has("personal_bests"):
		personal_bests = save_data.personal_bests
	if save_data.has("achievements"):
		achievements = save_data.achievements
	if save_data.has("adaptive_data") and TypingEngine:
		TypingEngine.import_session_data(save_data.adaptive_data)

	# Handle version migration
	var version: String = save_data.get("version", "1.0")
	if version == "1.0":
		_migrate_from_v1()

func _migrate_from_v1() -> void:
	# Add any new fields that didn't exist in v1.0
	if not lifetime_stats.has("progress_history"):
		lifetime_stats.progress_history = []

	print("Migrated save data from v1.0 to v2.0")

func get_progress_summary() -> Dictionary:
	return {
		"current_wpm": current_session_wpm,
		"current_accuracy": current_session_accuracy,
		"session_time": current_session_time,
		"lifetime_sessions": lifetime_stats.total_sessions,
		"best_wpm": lifetime_stats.best_wpm,
		"average_wpm": lifetime_stats.average_wpm,
		"current_streak": lifetime_stats.current_streak
	}

func get_detailed_stats() -> Dictionary:
	return {
		"session": session_stats,
		"lifetime": lifetime_stats,
		"personal_bests": personal_bests,
		"achievements": achievements,
		"analytics": get_advanced_analytics()
	}

func get_advanced_analytics() -> Dictionary:
	var analytics: Dictionary = {}

	# Progress trend analysis
	analytics.progress_trends = _analyze_progress_trends()

	# Learning speed analysis
	analytics.learning_speed = _analyze_learning_speed()

	# Performance patterns
	analytics.performance_patterns = _analyze_performance_patterns()

	# Weak points identification
	analytics.weak_points = _identify_weak_points()

	# Improvement suggestions
	analytics.suggestions = _generate_improvement_suggestions()

	return analytics

func _analyze_progress_trends() -> Dictionary:
	var trends: Dictionary = {}

	if not lifetime_stats.has("progress_history") or lifetime_stats.progress_history.size() < 2:
		return trends

	var history: Array = lifetime_stats.progress_history
	var recent_sessions: Array = history.slice(-10)  # Last 10 sessions

	# Calculate WPM trend
	var wpm_values: Array[float] = []
	var accuracy_values: Array[float] = []

	for session in recent_sessions:
		wpm_values.append(session.get("wpm", 0.0))
		accuracy_values.append(session.get("accuracy", 0.0))

	trends.wpm_trend = _calculate_trend(wpm_values)
	trends.accuracy_trend = _calculate_trend(accuracy_values)
	trends.improvement_rate = _calculate_improvement_rate(wpm_values)

	return trends

func _calculate_trend(values: Array[float]) -> String:
	if values.size() < 2:
		return "insufficient_data"

	var first_half: Array[float] = values.slice(0, values.size() / 2)
	var second_half: Array[float] = values.slice(values.size() / 2)

	var first_avg: float = _array_average(first_half)
	var second_avg: float = _array_average(second_half)

	var improvement: float = second_avg - first_avg
	var improvement_percent: float = (improvement / first_avg) * 100.0

	if improvement_percent > 5.0:
		return "improving"
	elif improvement_percent < -5.0:
		return "declining"
	else:
		return "stable"

func _calculate_improvement_rate(values: Array[float]) -> float:
	if values.size() < 2:
		return 0.0

	var first_value: float = values[0]
	var last_value: float = values[-1]

	if first_value == 0:
		return 0.0

	return ((last_value - first_value) / first_value) * 100.0

func _array_average(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0

	var sum: float = 0.0
	for value in arr:
		sum += value

	return sum / arr.size()

func _analyze_learning_speed() -> Dictionary:
	var analysis: Dictionary = {}

	if TypingEngine:
		var learning_data: Dictionary = TypingEngine.get_learning_progress()
		var active_letters: Array[String] = TypingEngine.get_active_letters()

		var total_mastery: float = 0.0
		var letter_count: int = 0

		for letter in active_letters:
			if learning_data.has(letter):
				total_mastery += learning_data[letter].get("mastery_level", 0.0)
				letter_count += 1

		var avg_mastery: float = total_mastery / max(1.0, float(letter_count))

		analysis.average_mastery = avg_mastery
		analysis.letters_unlocked = active_letters.size()
		analysis.mastery_category = _categorize_mastery_level(avg_mastery)

	return analysis

func _categorize_mastery_level(mastery: float) -> String:
	if mastery >= 0.9:
		return "expert"
	elif mastery >= 0.7:
		return "advanced"
	elif mastery >= 0.5:
		return "intermediate"
	elif mastery >= 0.3:
		return "beginner"
	else:
		return "novice"

func _analyze_performance_patterns() -> Dictionary:
	var patterns: Dictionary = {}

	# Analyze consistency
	if lifetime_stats.has("progress_history"):
		var wpm_variance: float = _calculate_variance("wpm")
		var accuracy_variance: float = _calculate_variance("accuracy")

		patterns.wpm_consistency = "high" if wpm_variance < 5.0 else ("medium" if wpm_variance < 15.0 else "low")
		patterns.accuracy_consistency = "high" if accuracy_variance < 3.0 else ("medium" if accuracy_variance < 8.0 else "low")

	# Best performance times (could be expanded with time-of-day analysis)
	patterns.peak_performance_wpm = personal_bests.fastest_wpm
	patterns.peak_performance_accuracy = personal_bests.highest_accuracy

	return patterns

func _calculate_variance(metric: String) -> float:
	if not lifetime_stats.has("progress_history"):
		return 0.0

	var values: Array[float] = []
	for session in lifetime_stats.progress_history:
		values.append(session.get(metric, 0.0))

	if values.size() < 2:
		return 0.0

	var mean: float = _array_average(values)
	var variance_sum: float = 0.0

	for value in values:
		variance_sum += pow(value - mean, 2)

	return variance_sum / values.size()

func _identify_weak_points() -> Dictionary:
	var weak_points: Dictionary = {}

	if TypingEngine:
		var learning_data: Dictionary = TypingEngine.get_learning_progress()

		var weakest_letters: Array[String] = []
		var lowest_mastery: float = 1.0

		for letter in learning_data:
			var mastery: float = learning_data[letter].get("mastery_level", 0.0)
			if mastery < 0.6:  # Below 60% mastery
				weakest_letters.append(letter)
			if mastery < lowest_mastery:
				lowest_mastery = mastery

		weak_points.letters = weakest_letters
		weak_points.lowest_mastery = lowest_mastery

	# Analyze speed vs accuracy trade-off
	if current_session_wpm > 0 and current_session_accuracy > 0:
		var speed_accuracy_ratio: float = current_session_wpm / current_session_accuracy
		weak_points.focus_area = "speed" if speed_accuracy_ratio < 0.3 else ("accuracy" if speed_accuracy_ratio > 1.0 else "balanced")

	return weak_points

func _generate_improvement_suggestions() -> Array[String]:
	var suggestions: Array[String] = []
	var weak_points: Dictionary = _identify_weak_points()
	var trends: Dictionary = _analyze_progress_trends()

	# Accuracy-based suggestions
	if current_session_accuracy < 90.0:
		suggestions.append("Focus on accuracy over speed - aim for 95%+ accuracy")
	elif current_session_accuracy >= 95.0 and current_session_wpm < 30.0:
		suggestions.append("Great accuracy! Now gradually increase your typing speed")

	# Speed-based suggestions
	if current_session_wpm < 25.0:
		suggestions.append("Practice regularly for 15-20 minutes daily to build muscle memory")
	elif current_session_wpm >= 60.0:
		suggestions.append("Excellent speed! Consider practicing advanced typing patterns")

	# Letter-specific suggestions
	if weak_points.has("letters") and weak_points.letters.size() > 0:
		var letter_list: String = ", ".join(weak_points.letters)
		suggestions.append("Focus extra practice on these letters: " + letter_list)

	# Trend-based suggestions
	if trends.has("wpm_trend") and trends.wmp_trend == "declining":
		suggestions.append("Take breaks to avoid fatigue - consistent practice beats marathon sessions")

	# General suggestions
	if suggestions.is_empty():
		suggestions.append("Keep up the great work! Consistent practice leads to improvement")

	return suggestions

func export_detailed_report() -> String:
	var analytics: Dictionary = get_advanced_analytics()
	var report: String = ""

	report += "=== TYPING PERFORMANCE REPORT ===\n\n"

	# Summary stats
	report += "CURRENT SESSION:\n"
	report += "WPM: %.1f | Accuracy: %.1f%%\n" % [current_session_wpm, current_session_accuracy]
	report += "Session Duration: %.1f minutes\n\n" % [current_session_time / 60.0]

	# Lifetime stats
	report += "LIFETIME STATISTICS:\n"
	report += "Total Sessions: %d\n" % lifetime_stats.total_sessions
	report += "Best WPM: %.1f | Best Accuracy: %.1f%%\n" % [lifetime_stats.best_wpm, lifetime_stats.best_accuracy]
	report += "Average WPM: %.1f | Average Accuracy: %.1f%%\n\n" % [lifetime_stats.average_wpm, lifetime_stats.average_accuracy]

	# Progress trends
	if analytics.has("progress_trends"):
		var trends = analytics.progress_trends
		report += "PROGRESS TRENDS:\n"
		report += "WPM Trend: %s\n" % trends.get("wpm_trend", "unknown")
		report += "Accuracy Trend: %s\n" % trends.get("accuracy_trend", "unknown")
		report += "Improvement Rate: %.1f%%\n\n" % trends.get("improvement_rate", 0.0)

	# Suggestions
	if analytics.has("suggestions"):
		report += "IMPROVEMENT SUGGESTIONS:\n"
		for suggestion in analytics.suggestions:
			report += "• " + suggestion + "\n"

	return report
