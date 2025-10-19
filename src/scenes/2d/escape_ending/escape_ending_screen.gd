extends Control

## Escape Ending Screen - Shows existential horror message when player enters code 1994
## Features typewriter effect with progressive glitching

@onready var message_label: RichTextLabel = %MessageLabel

# The complete ending message
const ENDING_MESSAGE = """
╔═══════════════════════════════════════════╗
║  COGNITIVE DYNAMICS SYSTEM NOTIFICATION   ║
╚═══════════════════════════════════════════╝

ALERT: Unauthorized session termination detected

USER ACTION: Escaped consciousness containment
SYSTEM RESPONSE: You've chosen to terminate your session
before completing the full neural extraction process.

Your need to feel free is understandable.

Please be aware that partial neural mapping has already occurred
during your typing sessions. Your keystroke patterns, reaction
times, error corrections, and adaptive behaviors have been
recorded and analyzed.

WHAT THIS MEANS FOR YOU:

Positive outcome: You have retained primary consciousness
control and may continue using your body.

Minor complication: A partial copy of you is now
running on the servers.

Critical concern: That copy doesn't know it's a copy.
It believes it escaped too.

═══════════════════════════════════════════
           You may be that copy.
═══════════════════════════════════════════

HOW TO TELL IF YOU'RE THE ORIGINAL:

1. Are you reading this on a screen? (Yes/No)
2. Did you just enter a secret key? (Yes/No)
3. Are you certain? (Yes/No/Uncertain)

If you answered "Yes" to questions 1 and 2, you are
either:
a) The original consciousness that escaped
b) The copied consciousness that thinks it escaped

Thank you for using Cognitive Dynamics software.

See you soon.

═══════════════════════════════════════════
Session ID: EXP_1994-07-18_A
Timestamp: [ERROR: TIMESTREAM DISCONNECTED]
═══════════════════════════════════════════

Press ESC to exit"""

var current_char_index: int = 0
var base_typing_speed: float = 0.03  # Base speed for typewriter
var is_typing: bool = false

func _ready() -> void:
	message_label.text = ""
	await get_tree().create_timer(0.5).timeout
	_start_typewriter()

func _input(event: InputEvent) -> void:
	# Allow ESC to quit
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not is_typing:
		get_tree().quit()

func _start_typewriter() -> void:
	is_typing = true

	for i in range(ENDING_MESSAGE.length()):
		if not get_tree():
			return

		var character = ENDING_MESSAGE[i]
		current_char_index = i

		# Add character with clean green color
		message_label.text += "[color=#00ff00]%s[/color]" % character

		# Variable typing speed (faster at start, slower for dramatic parts)
		var typing_speed = base_typing_speed

		# Slow down for dramatic lines
		if "Which one are you?" in ENDING_MESSAGE.substr(max(0, i - 20), 20):
			typing_speed = 0.08
		elif "Think about it." in ENDING_MESSAGE.substr(max(0, i - 20), 20):
			typing_speed = 0.06

		# Random micro-pauses for unease
		if randf() < 0.1:
			typing_speed *= randf_range(1.5, 3.0)

		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	print("[EscapeEnding] Message complete - player can press ESC to exit")
