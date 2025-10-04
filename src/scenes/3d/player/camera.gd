extends Camera3D

@onready var light : SpotLight3D = $SpotLight3D

func _input(event):
		if event.is_action_pressed("toggle_flashlight"):
			if light.visible:
				light.visible = false
			else:
				light.visible = true
