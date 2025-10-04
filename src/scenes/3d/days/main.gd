extends Node3D

var showing_menu := false

@export var sub_viewport: SubViewport

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	sub_viewport.push_input(event)
	if event.is_action_pressed("ui_cancel"):
		show_menu(!showing_menu)
		
func show_menu(_show:bool):
	showing_menu = _show
	if not showing_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#%GameScreen.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#%GameScreen.show()
