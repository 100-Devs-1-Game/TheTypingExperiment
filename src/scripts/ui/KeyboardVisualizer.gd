class_name KeyboardVisualizer
extends Node

## Modular keyboard visualization system for 3D key press animations
## Automatically discovers keyboard meshes and animates them on input

signal key_pressed(key_name: String)
signal key_released(key_name: String)

# Animation settings
@export var press_depth: float = 0.02  # How far down keys move when pressed
@export var press_duration: float = 0.1  # Animation duration for press
@export var release_duration: float = 0.15  # Animation duration for release

# Internal state
var keyboard_keys: Dictionary = {}  # Maps input codes to MeshInstance3D nodes
var original_positions: Dictionary = {}  # Stores original Y positions
var pressed_keys: Dictionary = {}  # Tracks currently pressed keys
var active_tweens: Dictionary = {}  # Tracks active animations

# Key mapping from Godot input codes to keyboard mesh naming patterns
var key_mappings: Dictionary = {
	# Letters
	KEY_A: "a", KEY_B: "b", KEY_C: "c", KEY_D: "d", KEY_E: "e",
	KEY_F: "f", KEY_G: "g", KEY_H: "h", KEY_I: "i", KEY_J: "j",
	KEY_K: "k", KEY_L: "l", KEY_M: "m", KEY_N: "n", KEY_O: "o",
	KEY_P: "p", KEY_Q: "q", KEY_R: "r", KEY_S: "s", KEY_T: "t",
	KEY_U: "u", KEY_V: "v", KEY_W: "w", KEY_X: "x", KEY_Y: "y", KEY_Z: "z",

	# Numbers
	KEY_0: "0", KEY_1: "1", KEY_2: "2", KEY_3: "3", KEY_4: "4",
	KEY_5: "5", KEY_6: "6", KEY_7: "7", KEY_8: "8", KEY_9: "9",

	# Special keys
	KEY_SPACE: "space",
	KEY_ENTER: "enter",
	KEY_BACKSPACE: "backspace",
	KEY_SHIFT: "shift",
	KEY_CTRL: "ctrl",
	KEY_ALT: "alt",
	KEY_ESCAPE: "escape",
	KEY_TAB: "tab",
	KEY_CAPSLOCK: "caps",

	# Punctuation
	KEY_PERIOD: "period",
	KEY_COMMA: "comma",
	KEY_SEMICOLON: "semicolon",
	KEY_APOSTROPHE: "apostrophe",
	KEY_SLASH: "slash",
	KEY_BACKSLASH: "backslash",
	KEY_BRACKETLEFT: "bracketleft",
	KEY_BRACKETRIGHT: "bracketright",
	KEY_MINUS: "minus",
	KEY_EQUAL: "equal"
}

func _ready() -> void:
	_discover_keyboard_keys()

## Automatically discovers all keyboard key meshes in the scene
func _discover_keyboard_keys() -> void:
	keyboard_keys.clear()
	original_positions.clear()

	# Search for keyboard meshes in the entire scene tree
	_search_for_keyboard_meshes(get_tree().current_scene)

	print("KeyboardVisualizer: Discovered %d keyboard keys" % keyboard_keys.size())

## Recursively search for keyboard mesh nodes
func _search_for_keyboard_meshes(node: Node) -> void:
	# Check if this node is a keyboard key mesh
	if node is MeshInstance3D and _is_keyboard_key_mesh(node.name):
		var key_identifier = _extract_key_from_mesh_name(node.name)
		if key_identifier != "":
			keyboard_keys[key_identifier] = node
			original_positions[key_identifier] = node.position.y

	# Recursively search children
	for child in node.get_children():
		_search_for_keyboard_meshes(child)

## Check if a mesh name represents a keyboard key
func _is_keyboard_key_mesh(mesh_name: String) -> bool:
	return mesh_name.begins_with("pc_keyboard_mp_2_")

## Extract key identifier from mesh name
func _extract_key_from_mesh_name(mesh_name: String) -> String:
	# Remove prefix "pc_keyboard_mp_2_"
	var key_part = mesh_name.replace("pc_keyboard_mp_2_", "")

	# Handle special cases and clean up the key identifier
	match key_part:
		"space_bar":
			return "space"
		"enter_key":
			return "enter"
		"backspace_key":
			return "backspace"
		"left_shift", "right_shift":
			return "shift"
		"left_ctrl", "right_ctrl":
			return "ctrl"
		"left_alt", "right_alt":
			return "alt"
		"caps_lock":
			return "caps"
		_:
			return key_part

## Handle input events and trigger key animations
func handle_input_event(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event = event as InputEventKey
	var key_code = key_event.keycode

	# Get the key identifier from our mapping
	if not key_mappings.has(key_code):
		return

	var key_identifier = key_mappings[key_code]

	# Check if we have this key in our discovered meshes
	if not keyboard_keys.has(key_identifier):
		return

	if key_event.pressed and not pressed_keys.has(key_identifier):
		_animate_key_press(key_identifier)
	elif not key_event.pressed and pressed_keys.has(key_identifier):
		_animate_key_release(key_identifier)

## Animate a key being pressed down
func _animate_key_press(key_identifier: String) -> void:
	if not keyboard_keys.has(key_identifier):
		return

	var key_mesh = keyboard_keys[key_identifier]
	var original_y = original_positions[key_identifier]
	var target_y = original_y - press_depth

	# Mark key as pressed
	pressed_keys[key_identifier] = true

	# Stop any existing animation for this key
	if active_tweens.has(key_identifier):
		active_tweens[key_identifier].kill()

	# Create press animation
	var tween = create_tween()
	tween.tween_property(key_mesh, "position:y", target_y, press_duration)
	tween.tween_callback(func(): _on_press_animation_complete(key_identifier))

	active_tweens[key_identifier] = tween
	key_pressed.emit(key_identifier)

## Animate a key being released
func _animate_key_release(key_identifier: String) -> void:
	if not keyboard_keys.has(key_identifier):
		return

	var key_mesh = keyboard_keys[key_identifier]
	var original_y = original_positions[key_identifier]

	# Mark key as released
	pressed_keys.erase(key_identifier)

	# Stop any existing animation for this key
	if active_tweens.has(key_identifier):
		active_tweens[key_identifier].kill()

	# Create release animation
	var tween = create_tween()
	tween.tween_property(key_mesh, "position:y", original_y, release_duration)
	tween.tween_callback(func(): _on_release_animation_complete(key_identifier))

	active_tweens[key_identifier] = tween
	key_released.emit(key_identifier)

## Called when press animation completes
func _on_press_animation_complete(key_identifier: String) -> void:
	if active_tweens.has(key_identifier):
		active_tweens.erase(key_identifier)

## Called when release animation completes
func _on_release_animation_complete(key_identifier: String) -> void:
	if active_tweens.has(key_identifier):
		active_tweens.erase(key_identifier)

## Public method to manually trigger key press (useful for visual-only effects)
func trigger_key_press(key_identifier: String) -> void:
	if keyboard_keys.has(key_identifier) and not pressed_keys.has(key_identifier):
		_animate_key_press(key_identifier)

## Public method to manually trigger key release
func trigger_key_release(key_identifier: String) -> void:
	if keyboard_keys.has(key_identifier) and pressed_keys.has(key_identifier):
		_animate_key_release(key_identifier)

## Release all currently pressed keys (useful for cleanup)
func release_all_keys() -> void:
	var keys_to_release = pressed_keys.keys().duplicate()
	for key_identifier in keys_to_release:
		_animate_key_release(key_identifier)

## Get list of currently pressed keys
func get_pressed_keys() -> Array:
	return pressed_keys.keys()

## Check if a specific key is currently pressed
func is_key_pressed(key_identifier: String) -> bool:
	return pressed_keys.has(key_identifier)

## Debug function to list all discovered keys
func get_discovered_keys() -> Array:
	return keyboard_keys.keys()