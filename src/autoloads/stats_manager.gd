extends Node

## Simple stats tracking for the horror typing game
## Focuses on basic WPM/accuracy without complex analytics

signal stats_updated(wpm: float, accuracy: float)

var current_session_wpm: float = 0.0
var current_session_accuracy: float = 100.0
var session_start_time: float = 0.0

# Performance tracking per stage
var stage_performance: Array[Dictionary] = []  # [{wpm: float, accuracy: float}, ...]

# Performance thresholds
const MIN_WPM_REQUIRED: float = 60.0
const MIN_ACCURACY_REQUIRED: float = 60.0

func _ready() -> void:
	pass

func start_session() -> void:
	session_start_time = Time.get_unix_time_from_system()
	current_session_wpm = 0.0
	current_session_accuracy = 100.0

func update_stats(wpm: float, accuracy: float) -> void:
	current_session_wpm = wpm
	current_session_accuracy = accuracy
	stats_updated.emit(wpm, accuracy)

func get_current_wpm() -> float:
	return current_session_wpm

func get_current_accuracy() -> float:
	return current_session_accuracy

## Records performance for a completed stage
func record_stage_performance(wpm: float, accuracy: float) -> void:
	stage_performance.append({"wpm": wpm, "accuracy": accuracy})
	print("[StatsManager] Stage %d recorded: WPM=%.1f, Accuracy=%.1f%%" % [stage_performance.size(), wpm, accuracy])

## Clears stage performance for new day
func reset_stage_performance() -> void:
	stage_performance.clear()

## Calculates average WPM across all recorded stages
func get_average_wpm() -> float:
	if stage_performance.is_empty():
		return 0.0

	var total_wpm: float = 0.0
	for stage in stage_performance:
		total_wpm += stage.wpm

	return total_wpm / stage_performance.size()

## Calculates average accuracy across all recorded stages
func get_average_accuracy() -> float:
	if stage_performance.is_empty():
		return 0.0

	var total_accuracy: float = 0.0
	for stage in stage_performance:
		total_accuracy += stage.accuracy

	return total_accuracy / stage_performance.size()

## Checks if performance meets minimum requirements
func meets_performance_requirements() -> bool:
	var avg_wpm = get_average_wpm()
	var avg_accuracy = get_average_accuracy()

	var meets_wpm = avg_wpm >= MIN_WPM_REQUIRED
	var meets_accuracy = avg_accuracy >= MIN_ACCURACY_REQUIRED

	print("[StatsManager] Performance check: WPM=%.1f (req: %.1f), Accuracy=%.1f%% (req: %.1f%%)" % [avg_wpm, MIN_WPM_REQUIRED, avg_accuracy, MIN_ACCURACY_REQUIRED])

	return meets_wpm and meets_accuracy

## Gets performance summary for display
func get_performance_summary() -> Dictionary:
	return {
		"average_wpm": get_average_wpm(),
		"average_accuracy": get_average_accuracy(),
		"stages_completed": stage_performance.size(),
		"meets_requirements": meets_performance_requirements()
	}
