class_name KeyboardSoundPlayer
extends Node

## Polyphonic keyboard typing sound system
## Uses round-robin pool of 10 AudioStreamPlayers for simultaneous key sounds

# Audio player pool for polyphonic playback
var audio_players: Array[AudioStreamPlayer] = []
var current_player_index: int = 0
const PLAYER_POOL_SIZE: int = 10  # Up to 10 simultaneous key sounds

# Sound pools
var spacebar_sounds: Array[AudioStream] = []
var key_sounds: Array[AudioStream] = []

func _ready() -> void:
	# Create pool of 10 audio players
	for i in range(PLAYER_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.name = "KeyboardAudioPlayer_%d" % i
		add_child(player)
		audio_players.append(player)

	# Preload spacebar sounds (3 files)
	spacebar_sounds = [
		preload("res://assets/external/custom_sfx/keyboard/space/keyboard-sound-200501-space1.wav"),
		preload("res://assets/external/custom_sfx/keyboard/space/keyboard-sound-200501-space2.wav"),
		preload("res://assets/external/custom_sfx/keyboard/space/keyboard-sound-200501-space3.wav")
	]

	# Preload key sounds (5 files)
	key_sounds = [
		preload("res://assets/external/custom_sfx/keyboard/key/keyboard-sound-200501-key1.wav"),
		preload("res://assets/external/custom_sfx/keyboard/key/keyboard-sound-200501-key2.wav"),
		preload("res://assets/external/custom_sfx/keyboard/key/keyboard-sound-200501-key3.wav"),
		preload("res://assets/external/custom_sfx/keyboard/key/keyboard-sound-200501-key4.wav"),
		preload("res://assets/external/custom_sfx/keyboard/key/keyboard-sound-200501-key5.wav")
	]

## Handle input and play appropriate sound
func handle_input_event(event: InputEvent) -> void:
	# Only respond to key press events
	if not event is InputEventKey:
		return

	var key_event = event as InputEventKey

	# Only play on key press (not release)
	if not key_event.pressed:
		return

	# Check if it's spacebar
	if key_event.keycode == KEY_SPACE:
		play_random_spacebar_sound()
	else:
		# All other keys use regular key sounds
		play_random_key_sound()

## Play a random key sound (for letters, numbers, backspace, etc.)
func play_random_key_sound() -> void:
	var random_index = randi() % key_sounds.size()

	# Get next player in rotation
	var player = audio_players[current_player_index]
	player.stream = key_sounds[random_index]
	player.play()

	# Rotate to next player in pool
	current_player_index = (current_player_index + 1) % PLAYER_POOL_SIZE

## Play a random spacebar sound
func play_random_spacebar_sound() -> void:
	var random_index = randi() % spacebar_sounds.size()

	# Get next player in rotation
	var player = audio_players[current_player_index]
	player.stream = spacebar_sounds[random_index]
	player.play()

	# Rotate to next player in pool
	current_player_index = (current_player_index + 1) % PLAYER_POOL_SIZE
