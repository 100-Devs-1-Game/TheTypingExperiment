class_name KeypadVisualizer
extends Node

## Modular keypad visualization system for 3D key press animations
## Automatically discovers keypad meshes and animates them on input

signal key_pressed(key_name: String)
signal key_released(key_name: String)

# Animation settings
@export var press_depth: float = 0.01  # How far down keys move when pressed
@export var press_duration: float = 0.1  # Animation duration for press
@export var release_duration: float = 0.15  # Animation duration for release

# Internal state
var keypad_keys: Dictionary = {}  # Maps input codes to MeshInstance3D nodes
var original_positions: Dictionary = {}  # Stores original Y positions
var pressed_keys: Dictionary = {}  # Tracks currently pressed keys
var active_tweens: Dictionary = {}  # Tracks active animations

# Key mapping from Godot input codes to keypad mesh naming patterns
var key_mappings: Dictionary = {
	# Numpad numbers
	KEY_KP_0: "0",
	KEY_KP_1: "1",
	KEY_KP_2: "2",
	KEY_KP_3: "3",
	KEY_KP_4: "4",
	KEY_KP_5: "5",
	KEY_KP_6: "6",
	KEY_KP_7: "7",
	KEY_KP_8: "8",
	KEY_KP_9: "9",

	# Regular number keys (top row)
	KEY_0: "0",
	KEY_1: "1",
	KEY_2: "2",
	KEY_3: "3",
	KEY_4: "4",
	KEY_5: "5",
	KEY_6: "6",
	KEY_7: "7",
	KEY_8: "8",
	KEY_9: "9",
}

func _ready() -> void:
	_discover_keypad_keys()

## Automatically discovers all keypad key meshes in the scene
func _discover_keypad_keys() -> void:
	keypad_keys.clear()
	original_positions.clear()

	# Search for keypad meshes in the entire scene tree
	_search_for_keypad_meshes(get_tree().current_scene)

	print("KeypadVisualizer: Discovered %d keypad keys" % keypad_keys.size())

## Recursively search for keypad mesh nodes
func _search_for_keypad_meshes(node: Node) -> void:
	# Check if this node is a keypad key mesh
	if node is MeshInstance3D and _is_keypad_key_mesh(node.name):
		var key_identifier = _extract_key_from_mesh_name(node.name)
		if key_identifier != "":
			keypad_keys[key_identifier] = node
			original_positions[key_identifier] = node.position.y

	# Recursively search children
	for child in node.get_children():
		_search_for_keypad_meshes(child)

## Check if a mesh name represents a keypad key
func _is_keypad_key_mesh(mesh_name: String) -> bool:
	return mesh_name.begins_with("keypad_2_") and not mesh_name.ends_with("_emission")

## Extract key identifier from mesh name
func _extract_key_from_mesh_name(mesh_name: String) -> String:
	# Remove prefix "keypad_2_"
	var key_part = mesh_name.replace("keypad_2_", "")

	# The key part should be just the number (0-9)
	if key_part.is_valid_int():
		return key_part

	return ""

## Handle input events and trigger key animations
## Returns true if the event was handled (consumed), false otherwise
func handle_input_event(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false

	var key_event = event as InputEventKey
	var key_code = key_event.keycode

	# Only handle keys that are in our mapping
	if not key_mappings.has(key_code):
		return false  # Let other handlers process this key

	var key_identifier = key_mappings[key_code]

	# Check if we have this key in our discovered meshes
	if not keypad_keys.has(key_identifier):
		return false

	if key_event.pressed and not pressed_keys.has(key_identifier):
		_animate_key_press(key_identifier)
		return true  # Event consumed
	elif not key_event.pressed and pressed_keys.has(key_identifier):
		_animate_key_release(key_identifier)
		return true  # Event consumed

	return false

## Animate a key being pressed down
func _animate_key_press(key_identifier: String) -> void:
	if not keypad_keys.has(key_identifier):
		return

	var key_mesh = keypad_keys[key_identifier]
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
	if not keypad_keys.has(key_identifier):
		return

	var key_mesh = keypad_keys[key_identifier]
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
	if keypad_keys.has(key_identifier) and not pressed_keys.has(key_identifier):
		_animate_key_press(key_identifier)

## Public method to manually trigger key release
func trigger_key_release(key_identifier: String) -> void:
	if keypad_keys.has(key_identifier) and pressed_keys.has(key_identifier):
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
	return keypad_keys.keys()
