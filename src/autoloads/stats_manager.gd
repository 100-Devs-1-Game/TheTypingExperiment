extends Node

## Simple stats tracking for the horror typing game
## Focuses on basic WPM/accuracy without complex analytics

signal stats_updated(wpm: float, accuracy: float)

var current_session_wpm: float = 0.0
var current_session_accuracy: float = 100.0
var session_start_time: float = 0.0

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

func get_session_duration() -> float:
	if session_start_time > 0:
		return Time.get_unix_time_from_system() - session_start_time
	return 0.0

func get_current_wpm() -> float:
	return current_session_wpm

func get_current_accuracy() -> float:
	return current_session_accuracy
