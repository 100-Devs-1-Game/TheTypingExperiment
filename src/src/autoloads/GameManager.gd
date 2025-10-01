extends Node

## Central game state manager for the typing practice game
## Handles scene transitions, session management, and global game state

signal session_started()
signal session_ended()
signal game_paused(is_paused: bool)

enum GameState {
	MENU,
	TYPING,
	PAUSED,
	RESULTS
}

var current_state: GameState = GameState.MENU
var session_start_time: float = 0.0
var is_session_active: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_typing_session() -> void:
	if is_session_active:
		return

	current_state = GameState.TYPING
	is_session_active = true
	session_start_time = Time.get_unix_time_from_system()
	session_started.emit()

func end_typing_session() -> void:
	if not is_session_active:
		return

	current_state = GameState.RESULTS
	is_session_active = false
	session_ended.emit()

func pause_game() -> void:
	if current_state != GameState.TYPING:
		return

	current_state = GameState.PAUSED
	get_tree().paused = true
	game_paused.emit(true)

func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return

	current_state = GameState.TYPING
	get_tree().paused = false
	game_paused.emit(false)

func return_to_menu() -> void:
	current_state = GameState.MENU
	is_session_active = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func get_session_duration() -> float:
	if not is_session_active:
		return 0.0

	var current_time: float = Time.get_unix_time_from_system()
	return current_time - session_start_time
