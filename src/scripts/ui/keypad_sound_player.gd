class_name KeypadSoundPlayer
extends Node

## Polyphonic keypad button sound system
## Uses round-robin pool of 5 AudioStreamPlayers for simultaneous button sounds

# Audio player pool for polyphonic playback
var audio_players: Array[AudioStreamPlayer] = []
var current_player_index: int = 0
const PLAYER_POOL_SIZE: int = 5  # Up to 5 simultaneous button sounds

# Sound pools
var key_sounds: Array[AudioStream] = []
var success_sound: AudioStream
var fail_sound: AudioStream

func _ready() -> void:
	# Create pool of 5 audio players
	for i in range(PLAYER_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.name = "KeypadAudioPlayer_%d" % i
		add_child(player)
		audio_players.append(player)

	# Preload key sound (1 file)
	key_sounds = [
		preload("res://assets/external/custom_sfx/keypad/keypad-60512-key1.wav")
	]

	# Preload success and fail sounds
	success_sound = preload("res://assets/external/custom_sfx/keypad/keypad-60512-success.wav")
	fail_sound = preload("res://assets/external/custom_sfx/keypad/keypad-60512-fail.wav")

## Handle input and play appropriate sound
func handle_input_event(event: InputEvent) -> void:
	# Only respond to key press events
	if not event is InputEventKey:
		return

	var key_event = event as InputEventKey

	# Only play on key press (not release)
	if not key_event.pressed:
		return

	# Check if it's a digit or backspace
	var is_valid_keypad_input = false
	match key_event.keycode:
		KEY_0, KEY_KP_0, KEY_1, KEY_KP_1, KEY_2, KEY_KP_2, KEY_3, KEY_KP_3,\
		KEY_4, KEY_KP_4, KEY_5, KEY_KP_5, KEY_6, KEY_KP_6, KEY_7, KEY_KP_7,\
		KEY_8, KEY_KP_8, KEY_9, KEY_KP_9, KEY_BACKSPACE:
			is_valid_keypad_input = true

	if is_valid_keypad_input:
		play_random_key_sound()

## Play a random key sound (for digit buttons and backspace)
func play_random_key_sound() -> void:
	var random_index = randi() % key_sounds.size()

	# Get next player in rotation
	var player = audio_players[current_player_index]
	player.stream = key_sounds[random_index]
	player.play()

	# Rotate to next player in pool
	current_player_index = (current_player_index + 1) % PLAYER_POOL_SIZE

## Play success sound when correct code is entered
func play_success_sound() -> void:
	# Get next player in rotation
	var player = audio_players[current_player_index]
	player.stream = success_sound
	player.play()

	# Rotate to next player in pool
	current_player_index = (current_player_index + 1) % PLAYER_POOL_SIZE

## Play fail sound when incorrect code is entered
func play_fail_sound() -> void:
	# Get next player in rotation
	var player = audio_players[current_player_index]
	player.stream = fail_sound
	player.play()

	# Rotate to next player in pool
	current_player_index = (current_player_index + 1) % PLAYER_POOL_SIZE
