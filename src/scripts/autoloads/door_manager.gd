extends Node

## Door Manager - Central authority for stage access codes and door unlocking
## Manages the relationship between day completion codes and stage progression

signal stage_unlocked(stage_number: int)
signal code_set_for_stage(stage_number: int, code: String)

# Stores access codes for each stage {stage_number: code_string}
var stage_codes: Dictionary = {}

# Tracks which stages have been unlocked
var unlocked_stages: Array[int] = [1]  # Stage 1 is always unlocked at start

func _ready() -> void:
	pass

## Sets the access code required to unlock a specific stage
## Called by day_end_screen when a day is completed
func set_code_for_stage(stage_number: int, code: String) -> void:
	stage_codes[stage_number] = code
	code_set_for_stage.emit(stage_number, code)
	print("[DoorManager] Code set for Stage %d: %s" % [stage_number, code])

## Validates if the entered code matches the required code for a stage
func validate_code(stage_number: int, entered_code: String) -> bool:
	if not stage_codes.has(stage_number):
		push_warning("[DoorManager] No code set for Stage %d" % stage_number)
		return false

	var required_code = stage_codes[stage_number]
	var is_valid = entered_code == required_code

	if is_valid:
		print("[DoorManager] Valid code entered for Stage %d" % stage_number)
	else:
		print("[DoorManager] Invalid code entered for Stage %d (Expected: %s, Got: %s)" % [stage_number, required_code, entered_code])

	return is_valid

## Marks a stage as unlocked
func unlock_stage(stage_number: int) -> void:
	if stage_number not in unlocked_stages:
		unlocked_stages.append(stage_number)
		stage_unlocked.emit(stage_number)
		print("[DoorManager] Stage %d unlocked!" % stage_number)

## Checks if a stage is currently unlocked
func is_stage_unlocked(stage_number: int) -> bool:
	return stage_number in unlocked_stages

## Gets the code for a specific stage (for debugging)
func get_code_for_stage(stage_number: int) -> String:
	return stage_codes.get(stage_number, "")

## Resets all progress (for testing or new game)
func reset_progress() -> void:
	stage_codes.clear()
	unlocked_stages = [1]
	print("[DoorManager] Progress reset - only Stage 1 unlocked")
