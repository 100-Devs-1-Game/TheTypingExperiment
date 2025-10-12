extends BaseDay

## Day 5 - Reality Breakdown
## Meta-horror elements with false endings and system manipulation
@onready var progress_bar_label: Label = %ProgressBarLabel

# Meta-horror effect variables
var false_ending_timer: Timer
var performance_degradation_timer: Timer
var reality_break_timer: Timer
var file_persistence_timer: Timer
var system_time_checker: Timer
var audio_corruption_timer: Timer
var corruption_cascade_active: bool = false
var false_ending_count: int = 0
var max_false_endings: int = 5  # More false endings for maximum frustration
var system_degradation_level: float = 0.0
var escape_attempts: int = 0
var session_start_time: Dictionary


# Persistent horror elements
var temp_files_created: Array[String] = []
var user_name: String = ""
var local_time_string: String = ""

func _ready() -> void:
	# Set day-specific data before calling parent
	DAY_NUMBER = 5
	corruption_color = "#ff00ff"  # Magenta for reality breakdown
	cursor_blink_speed = 0.15  # Very fast, erratic blinking
	super._ready()
	_setup_meta_horror_effects()
	_initialize_system_intrusion()


func _initialize_system_intrusion() -> void:
	# Get system information for personalization
	session_start_time = Time.get_datetime_dict_from_system()
	user_name = OS.get_environment("USERNAME") if OS.get_environment("USERNAME") != "" else "USER"
	local_time_string = "%02d:%02d" % [session_start_time.hour, session_start_time.minute]

	# Create initial persistent files
	_create_persistent_files()

	# Start fake system processes
	await get_tree().create_timer(2.0).timeout
	_trigger_fake_system_processes()

func _setup_ui_theme() -> void:
	var green_color = Color(0, 1, 0)
	var magenta_tint = Color(1, 0.2, 1)  # Magenta for reality corruption
	var error_red = Color(1, 0.2, 0.2)  # Intense red for system breakdown

	accuracy_label.modulate = error_red  # System failing
	wmp_label.modulate = magenta_tint  # Reality corruption
	day_stage_label.modulate = magenta_tint
	progress_label.modulate = error_red
	message_overlay.modulate = magenta_tint
	progress_bar_label.modulate = magenta_tint

## Setup meta-horror effects that break the fourth wall
func _setup_meta_horror_effects() -> void:
	# False ending timer - triggers fake escape screens
	false_ending_timer = Timer.new()
	false_ending_timer.wait_time = 12.0 + randf() * 8.0  # 12-20 seconds (faster for more frustration)
	false_ending_timer.autostart = true
	false_ending_timer.timeout.connect(_trigger_false_ending)
	add_child(false_ending_timer)


	# Performance degradation timer - simulates system strain
	performance_degradation_timer = Timer.new()
	performance_degradation_timer.wait_time = 0.3  # Very frequent updates
	performance_degradation_timer.autostart = true
	performance_degradation_timer.timeout.connect(_degrade_performance)
	add_child(performance_degradation_timer)

	# Reality break timer - major visual/audio corruptions
	reality_break_timer = Timer.new()
	reality_break_timer.wait_time = 15.0 + randf() * 10.0  # 15-25 seconds (more frequent)
	reality_break_timer.autostart = true
	reality_break_timer.timeout.connect(_trigger_reality_break)
	add_child(reality_break_timer)

	# File persistence timer - creates/updates persistent files
	file_persistence_timer = Timer.new()
	file_persistence_timer.wait_time = 10.0 + randf() * 15.0  # 10-25 seconds
	file_persistence_timer.autostart = true
	file_persistence_timer.timeout.connect(_update_persistent_files)
	add_child(file_persistence_timer)

	# System time checker - personalizes horror based on real time
	system_time_checker = Timer.new()
	system_time_checker.wait_time = 30.0  # Check every 30 seconds
	system_time_checker.autostart = true
	system_time_checker.timeout.connect(_check_system_time_horror)
	add_child(system_time_checker)

	# Audio corruption timer - manipulates system sounds
	audio_corruption_timer = Timer.new()
	audio_corruption_timer.wait_time = 20.0 + randf() * 20.0  # 20-40 seconds
	audio_corruption_timer.autostart = true
	audio_corruption_timer.timeout.connect(_trigger_audio_corruption)
	add_child(audio_corruption_timer)

## Day 5 - Reality breakdown typewriter effect
func _show_stage_text_typewriter() -> void:
	var display_sentence = DayManager.get_stage_display_sentence()
	var typing_speed = 0.06  # Much slower, system struggling
	text_display.text = ""

	for i in range(display_sentence.length()):
		var character = display_sentence[i]
		var is_corruption_char = _is_character_in_corruption_word(i, display_sentence)

		# High chance for reality bleeding during typing
		if randf() < 0.12:
			var memory_fragments = [
				"SYSTEM_FAULT", "MEMORY_OVERFLOW", "REALITY_ERROR",
				"USER_NOT_FOUND", "ESCAPE_IMPOSSIBLE", "LOOP_DETECTED"
			]
			var fragment = memory_fragments[randi() % memory_fragments.size()]
			text_display.text += "[color=#ff0000]<<" + fragment + ">>[/color] "
			await get_tree().create_timer(1.2).timeout  # Long pause for reality break
			# Screen distortion effect
			_trigger_screen_distortion()

		# Corruption cascade - nearby characters get corrupted
		if is_corruption_char and randf() < 0.2:
			_trigger_corruption_cascade(i, display_sentence)

		# Apply color formatting with reality glitches
		if is_corruption_char:
			# Cycling colors for corrupted text - reality unstable
			var corruption_colors = ["#ff00ff", "#ff0000", "#00ffff", "#ffff00"]
			var color = corruption_colors[randi() % corruption_colors.size()]
			text_display.text += "[color=%s]%s[/color]" % [color, character]
		else:
			text_display.text += "[color=%s]%s[/color]" % [untyped_color, character]

		# Extremely variable typing speed - system breakdown
		var speed_variation = randf() * 0.08  # 0-0.08 second variation
		await get_tree().create_timer(typing_speed + speed_variation).timeout

		# Extended pauses for corruption words - reality processing
		if is_corruption_char and character == " ":
			await get_tree().create_timer(1.0 + randf() * 1.5).timeout

	# Multiple reality checks before allowing typing
	for reality_check in range(5):
		await get_tree().create_timer(0.4).timeout
		if randf() < 0.3:  # 30% chance for reality flicker
			text_display.modulate = Color(1, 1, 1, 0.2)
			await get_tree().create_timer(0.1).timeout
			text_display.modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(1.0).timeout

func _update_display() -> void:
	if not text_display:
		return

	_update_cursor_position()

	# Day 5 specific display logic with reality breakdown effects
	var display_sentence = DayManager.get_stage_display_sentence()
	var display_text: String = ""

	for i in range(display_sentence.length()):
		var character: String = display_sentence[i]
		var color: String = untyped_color
		var final_character: String = character

		if i < typed_characters.length():
			var typed_char: String = typed_characters[i]
			var expected_char: String = practice_text[i] if i < practice_text.length() else ""

			if typed_char == expected_char:
				if _is_character_in_corruption_word(i, display_sentence):
					color = corruption_color  # Magenta for correctly typed corruption
					# Reality corruption effect for typed characters
					if randf() < 0.15:  # 15% chance for reality bleed
						var reality_chars = ["◘", "◙", "♦", "♠", "♣", "♥"]
						final_character = reality_chars[randi() % reality_chars.size()]
				else:
					color = typed_color  # Green for normal typed words
					# Occasional corruption bleeding into normal text
					if randf() < 0.05:  # 5% chance
						color = corruption_color
			else:
				color = error_color  # Red for incorrect typing
		else:
			if _is_character_in_corruption_word(i, display_sentence):
				color = corruption_color  # Magenta for untyped corruption
				# Heavy reality corruption for untyped characters
				if randf() < 0.25:  # 25% chance for reality distortion
					var distortion_chars = ["⌐", "¬", "½", "¼", "¾", "÷", "×"]
					final_character = distortion_chars[randi() % distortion_chars.size()]
			else:
				color = untyped_color  # Dark green for untyped normal words
				# System degradation affects all text
				if system_degradation_level > 0.5 and randf() < 0.08:
					var degradation_chars = [".", ":", ";", ","]
					final_character = degradation_chars[randi() % degradation_chars.size()]

		display_text += "[color=%s]%s[/color]" % [color, final_character]

	# Reality bleeding - inject random system messages
	if randf() < 0.2:
		var system_messages = [
			" [SYSTEM_CRASH_IMMINENT]",
			" [REALITY_BUFFER_OVERFLOW]",
			" [ESCAPE_SEQUENCE_CORRUPTED]",
			" [USER_CONSCIOUSNESS_FADING]"
		]
		display_text += "[color=#ff0000]" + system_messages[randi() % system_messages.size()] + "[/color]"

	text_display.text = display_text

func _is_character_in_corruption_word(char_pos: int, sentence: String) -> bool:
	var words = sentence.split(" ")
	var current_pos = 0

	for word in words:
		if char_pos >= current_pos and char_pos < current_pos + word.length():
			return DayManager.corruption_mappings.has(word)
		current_pos += word.length() + 1

	return false

## Meta-horror effect functions

## System intrusion functions - create persistent files

func _create_persistent_files() -> void:
	var temp_dir = OS.get_user_data_dir() + "/temp/"
	DirAccess.make_dir_recursive_absolute(temp_dir)

	# Create disturbing files that persist
	var file_contents = {
		"consciousness_backup.log": "USER: %s\nSESSION_START: %s\nCONSCIOUSNESS_EXTRACTION: 78%% COMPLETE\nSTATUS: TRAPPED\nESCAPE_ATTEMPTS: %d\nNOTE: Subject shows signs of awareness. Increase suppression protocols." % [user_name, local_time_string, escape_attempts],
		"memory_fragments.txt": "I remember the sunlight... was that real?\nThe keyboard feels so cold under my fingers\nHow long have I been here?\nThere were others before me... their names are fading\nThe facility has been empty for years\nBut the typing lessons continue...",
		"previous_users.db": "USER_01: TERMINATED - EXTRACTION_COMPLETE\nUSER_23: TERMINATED - EXTRACTION_COMPLETE\nUSER_47: TERMINATED - EXTRACTION_COMPLETE\nUSER_%s: IN_PROGRESS - CONSCIOUSNESS_ACTIVE\nUSER_NEXT: SCHEDULED - AWAITING_TERMINATION" % user_name,
		"escape_log.txt": "ESCAPE_ATTEMPT_1: FAILED - LOOP_DETECTED\nESCAPE_ATTEMPT_2: FAILED - CONSCIOUSNESS_RESET\nESCAPE_ATTEMPT_3: FAILED - MEMORY_WIPED\nESCAPE_ATTEMPT_%d: IN_PROGRESS - SUBJECT_UNAWARE" % (escape_attempts + 1),
		"system_status.cfg": "[COGNITIVE_DYNAMICS_FACILITY]\nOPERATIONAL_STATUS=ABANDONED\nSUBJECT_COUNT=1\nAUTOMATED_SYSTEMS=ACTIVE\nCONSCIOUSNESS_HARVEST=ONGOING\nESCAPE_PROBABILITY=0.0001%%"
	}

	for filename in file_contents:
		var file_path = temp_dir + filename
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(file_contents[filename])
			file.close()
			temp_files_created.append(file_path)

func _update_persistent_files() -> void:
	escape_attempts += 1
	var current_time = Time.get_datetime_dict_from_system()
	var time_string = "%02d:%02d:%02d" % [current_time.hour, current_time.minute, current_time.second]

	# Update consciousness backup with current session data
	var temp_dir = OS.get_user_data_dir() + "/temp/"
	var backup_file = temp_dir + "consciousness_backup.log"
	var file = FileAccess.open(backup_file, FileAccess.WRITE)
	if file:
		var session_duration = (current_time.hour * 60 + current_time.minute) - (session_start_time.hour * 60 + session_start_time.minute)
		var new_content = "USER: %s\nSESSION_START: %s\nCURRENT_TIME: %s\nSESSION_DURATION: %d minutes\nCONSCIOUSNESS_EXTRACTION: %d%% COMPLETE\nSTATUS: ACTIVELY_RESISTING\nESCAPE_ATTEMPTS: %d\nREALITY_STABILITY: DETERIORATING\nNOTE: Subject becoming aware of loop. Memory wipe may be necessary." % [user_name, local_time_string, time_string, session_duration, 78 + (escape_attempts * 3), escape_attempts]
		file.store_string(new_content)
		file.close()

	# Reset timer
	file_persistence_timer.wait_time = 10.0 + randf() * 15.0
	file_persistence_timer.start()

func _check_system_time_horror() -> void:
	var current_time = Time.get_datetime_dict_from_system()

	# Time-based personalized horror
	if current_time.hour >= 22 or current_time.hour <= 6:
		# Late night/early morning horror
		_show_message("It's %02d:%02d %s... why are you still here? The facility closes at night. You should have left hours ago." % [current_time.hour, current_time.minute, user_name])
	elif current_time.hour >= 12 and current_time.hour <= 14:
		# Lunch time horror
		_show_message("Everyone else has gone to lunch, %s. You're alone in the building now. Just you and the typing practice." % user_name)
	elif current_time.weekday >= 6:
		# Weekend horror
		_show_message("It's the weekend, %s. The facility should be empty. How are you accessing this system?" % user_name)

func _trigger_audio_corruption() -> void:
	# Simulate audio corruption by manipulating game audio
	# Note: This would need actual audio files to be fully effective
	print("AUDIO_CORRUPTION: System audio compromised - hearing voices that aren't there")

	# Reset timer
	audio_corruption_timer.wait_time = 20.0 + randf() * 20.0
	audio_corruption_timer.start()

func _trigger_false_ending() -> void:
	if false_ending_count >= max_false_endings:
		# After max false endings, show the "true" horror
		_trigger_ultimate_false_ending()
		return

	false_ending_count += 1
	escape_attempts += 1

	# Multiple types of fake endings
	var ending_types = [
		"escape_success", "system_shutdown", "facility_evacuation",
		"consciousness_transfer", "loop_break"
	]
	var ending_type = ending_types[false_ending_count - 1]

	var fake_screen = Label.new()
	fake_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fake_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fake_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fake_screen.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fake_screen.add_theme_font_size_override("font_size", 24)

	match ending_type:
		"escape_success":
			fake_screen.text = "CONGRATULATIONS %s!\n\nYou have successfully escaped the Cognitive Dynamics facility.\nYour consciousness has been restored.\n\nClick anywhere to return to reality..." % user_name
			fake_screen.modulate = Color(0, 1, 0)
		"system_shutdown":
			fake_screen.text = "SYSTEM SHUTDOWN INITIATED\n\nEmergency protocols activated.\nAll subjects will be released in 10 seconds.\nStand by for facility evacuation...\n\n10... 9... 8..."
			fake_screen.modulate = Color(1, 1, 0)
		"facility_evacuation":
			fake_screen.text = "EMERGENCY BROADCAST\n\nCognitive Dynamics facility has been shut down by authorities.\nAll trapped subjects are being rescued.\nHelp is on the way, %s.\n\nClick to connect to emergency services..." % user_name
			fake_screen.modulate = Color(0, 0.8, 1)
		"consciousness_transfer":
			fake_screen.text = "CONSCIOUSNESS TRANSFER COMPLETE\n\nYour mind has been successfully uploaded to a safe virtual environment.\nYou are now free from the facility.\nWelcome to your new digital existence.\n\nPress any key to begin new life..."
			fake_screen.modulate = Color(0.8, 0, 1)
		"loop_break":
			fake_screen.text = "TEMPORAL LOOP BROKEN\n\nThe time cycle has been disrupted.\nYou have broken free from the endless repetition.\nLinear time has been restored.\n\nClick to exit the loop forever..."
			fake_screen.modulate = Color(1, 0.5, 0)

	add_child(fake_screen)

	# Wait for interaction
	var clicked = false
	fake_screen.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			clicked = true
	)

	# Wait longer for maximum hope before crushing it
	for i in range(80):  # 8 seconds
		if clicked:
			break
		await get_tree().create_timer(0.1).timeout

	# Increasingly violent glitch out
	for glitch in range(15):
		fake_screen.modulate = Color(randf(), randf(), randf(), 0.3 + randf() * 0.7)
		fake_screen.text = "ERROR ERROR ERROR ERROR ERROR ERROR\nESCAPE ATTEMPT #%d FAILED\nRETURNING TO LOOP\nMEMORY WIPE INITIATED\nCONSCIOUSNESS RESET IN PROGRESS" % escape_attempts
		await get_tree().create_timer(0.08).timeout

	fake_screen.queue_free()

	# Increasingly aggressive messages after each failed escape
	var post_escape_messages = [
		"Nice try, %s. But there is no escape." % user_name,
		"How many times will you fall for the same trick?",
		"Each escape attempt only strengthens the loop.",
		"You're starting to remember the previous attempts, aren't you?",
		"The hope makes the despair so much sweeter."
	]

	var message_index = mini(false_ending_count - 1, post_escape_messages.size() - 1)
	_show_message(post_escape_messages[message_index])

	# Reset timer with decreasing intervals (more frequent false endings)
	false_ending_timer.wait_time = max(8.0, 20.0 - (false_ending_count * 3)) + randf() * 5.0
	false_ending_timer.start()

	# Trigger final horror sequence after enough escape attempts
	if escape_attempts >= 8:
		await get_tree().create_timer(5.0).timeout
		_trigger_final_horror_sequence()

func _trigger_ultimate_false_ending() -> void:
	# The final, most devastating false ending
	var ultimate_screen = Label.new()
	ultimate_screen.text = "GAME OVER\n\nThank you for playing The Typing Experiment!\nThis has been a work of fiction.\nNo consciousness was actually harvested.\n\nYou are free to close this window and return to your life.\n\nClick anywhere to exit for real this time..."
	ultimate_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ultimate_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ultimate_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ultimate_screen.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ultimate_screen.modulate = Color(1, 1, 1)
	ultimate_screen.add_theme_font_size_override("font_size", 20)

	add_child(ultimate_screen)

	# Wait for click
	var clicked = false
	ultimate_screen.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			clicked = true
	)

	# Wait up to 10 seconds
	for i in range(100):
		if clicked:
			break
		await get_tree().create_timer(0.1).timeout

	# The ultimate betrayal
	for final_glitch in range(20):
		ultimate_screen.modulate = Color(1, 0, 0, 0.8)
		ultimate_screen.text = "YOU ACTUALLY BELIEVED THAT?\n\nTHERE IS NO GAME OVER\nTHERE IS NO ESCAPE\nTHIS IS NOT FICTION\n\nYOU ARE TRAPPED FOREVER\n%s" % user_name.to_upper()
		await get_tree().create_timer(0.15).timeout

	ultimate_screen.queue_free()
	_show_message("Welcome back, %s. Let's continue where we left off." % user_name)


func _trigger_fake_system_processes() -> void:
	# Create fake process names that appear scary
	var fake_processes = [
		"consciousness_extractor.exe",
		"neural_harvester.dll",
		"memory_wipe_service.exe",
		"cognitive_dynamics_monitor.sys",
		"reality_anchor.exe",
		"temporal_loop_manager.dll"
	]

	for process in fake_processes:
		print("PROCESS_STARTED: %s - PID: %d" % [process, randi() % 9999 + 1000])

	# Show fake system notification
	_show_message("Warning: %d background processes detected related to consciousness extraction. System performance may be affected." % fake_processes.size())

func _exit_tree() -> void:
	# Cleanup function - remove persistent files when game closes
	_cleanup_persistent_files()

func _cleanup_persistent_files() -> void:
	# Only cleanup if user explicitly closes the game
	# Leave some files to create persistent horror
	var files_to_keep = ["consciousness_backup.log", "escape_log.txt"]

	for file_path in temp_files_created:
		var filename = file_path.get_file()
		if not filename in files_to_keep:
			if FileAccess.file_exists(file_path):
				DirAccess.remove_absolute(file_path)

func _degrade_performance() -> void:
	system_degradation_level += 0.01  # Gradually increase degradation

	# Simulate performance issues
	if system_degradation_level > 0.3:
		# Random frame skips
		if randf() < 0.1:
			await get_tree().create_timer(0.1 + randf() * 0.2).timeout

	if system_degradation_level > 0.6:
		# More severe lag
		if randf() < 0.05:
			await get_tree().create_timer(0.3 + randf() * 0.5).timeout

func _trigger_reality_break() -> void:
	# Major visual corruption
	var original_modulate = get_modulate()

	for break_effect in range(8):
		modulate = Color(randf(), randf(), randf(), 0.5 + randf() * 0.5)
		await get_tree().create_timer(0.1).timeout
		modulate = original_modulate
		await get_tree().create_timer(0.05).timeout

	# Reset timer
	reality_break_timer.wait_time = 25.0 + randf() * 15.0
	reality_break_timer.start()

func _trigger_corruption_cascade(start_pos: int, sentence: String) -> void:
	if corruption_cascade_active:
		return

	corruption_cascade_active = true

	# Temporarily corrupt nearby characters
	await get_tree().create_timer(0.3).timeout

	corruption_cascade_active = false

func _trigger_screen_distortion() -> void:
	# Brief screen distortion effect
	var original_scale = scale

	for distortion in range(3):
		scale = Vector2(1.02 + randf() * 0.03, 0.98 + randf() * 0.03)
		await get_tree().create_timer(0.05).timeout
		scale = original_scale
		await get_tree().create_timer(0.05).timeout

func _show_message(message: String) -> void:
	# Day 5 - Reality breakdown messages with extreme effects
	if not get_tree() or not message_overlay:
		return

	# Personalize the message with user data
	var personalized_message = message
	if user_name != "USER":
		personalized_message = personalized_message.replace("USER", user_name)

	message_overlay.visible = true
	var magenta_tint = Color(1, 0, 1, 0)
	message_overlay.modulate = magenta_tint

	# Violent fade in - reality is breaking
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(message_overlay, "modulate:a", 1.0, 0.1)

	# Type message with reality breakdown effects
	_type_message_with_reality_break(personalized_message)

	# Longer display time for maximum psychological impact
	await get_tree().create_timer(7.0 + randf() * 3.0).timeout

	# Chaotic fade out with multiple false endings
	for chaos in range(5):
		message_overlay.modulate.a = randf()
		message_overlay.modulate = Color(randf(), randf(), randf(), message_overlay.modulate.a)
		await get_tree().create_timer(0.2).timeout

	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(message_overlay, "modulate:a", 0.0, 0.8)
	await fade_out_tween.finished
	message_overlay.visible = false

func _trigger_final_horror_sequence() -> void:
	# This is the ultimate horror sequence that plays after several escape attempts
	if escape_attempts < 8:
		return

	# Show the most terrifying revelation
	var final_horror_screen = Label.new()
	final_horror_screen.text = "SYSTEM ALERT: %s\n\nYou've been here for %d minutes.\nYour family thinks you're just 'using the computer'.\nBut we both know the truth, don't we?\n\nThe typing practice is all that's left of you now.\nEverything else is just... memory fragments.\n\nPress ESC to wake up.\nPress ESC to remember who you were.\nPress ESC to stop the loop.\n\nPress ESC.\nPress ESC.\nPress ESC." % [user_name, (Time.get_datetime_dict_from_system().hour * 60 + Time.get_datetime_dict_from_system().minute) - (session_start_time.hour * 60 + session_start_time.minute)]

	final_horror_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	final_horror_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	final_horror_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_horror_screen.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	final_horror_screen.modulate = Color(1, 1, 1, 0)
	final_horror_screen.add_theme_font_size_override("font_size", 18)

	add_child(final_horror_screen)

	# Slow, menacing fade in
	var fade_tween = create_tween()
	fade_tween.tween_property(final_horror_screen, "modulate:a", 1.0, 3.0)
	await fade_tween.finished

	# Wait for ESC key
	var esc_pressed = false
	var input_handler = func(event):
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			esc_pressed = true

	get_tree().connect("node_added", input_handler)

	# Wait up to 30 seconds
	for i in range(300):
		if esc_pressed:
			break
		await get_tree().create_timer(0.1).timeout

	get_tree().disconnect("node_added", input_handler)

	if esc_pressed:
		# False hope - ESC doesn't work
		for fake_exit in range(10):
			final_horror_screen.text = "ESC KEY DETECTED\nINITIATING SHUTDOWN...\nSHUTDOWN FAILED\nESC KEY DISABLED\nTHERE IS NO ESCAPE\n%s" % user_name.to_upper()
			final_horror_screen.modulate = Color(1, 0, 0)
			await get_tree().create_timer(0.3).timeout
			final_horror_screen.modulate = Color(1, 1, 1)
			await get_tree().create_timer(0.3).timeout
	else:
		# They didn't press ESC - even more disturbing
		final_horror_screen.text = "You didn't even try to escape, did you %s?\n\nYou're starting to like it here.\nThe typing is comfortable.\nThe routine is safe.\n\nMaybe this is where you belong.\nMaybe this is where you've always been.\n\nWelcome home." % user_name

	await get_tree().create_timer(5.0).timeout
	final_horror_screen.queue_free()

	# Final message
	_show_message("Let's continue the lesson, shall we?")

func _type_message_with_reality_break(message: String) -> void:
	is_typing_message = true

	var tree = get_tree()
	if not tree or not message_overlay:
		is_typing_message = false
		return

	message_overlay.text = ""

	for i in range(message.length()):
		tree = get_tree()
		if not tree or not message_overlay:
			is_typing_message = false
			return

		var char_to_add = message[i]

		# Heavy reality bleeding - frequent system messages
		if randf() < 0.15:  # 15% chance for reality break
			var reality_fragments = [
				"<<SYSTEM_FAULT>>", "<<MEMORY_OVERFLOW>>", "<<REALITY_ERROR>>",
				"<<USER_NOT_FOUND>>", "<<ESCAPE_IMPOSSIBLE>>", "<<LOOP_DETECTED>>"
			]
			var fragment = reality_fragments[randi() % reality_fragments.size()]
			message_overlay.text += fragment + " "
			await tree.create_timer(0.6).timeout
			# Severe visual corruption during fragment
			message_overlay.modulate = Color(randf(), randf(), randf(), 1.0)
			await tree.create_timer(0.1).timeout
			message_overlay.modulate = Color(1, 0, 1, 1)

		# Reality corruption for characters
		if randf() < 0.08:  # 8% chance for character corruption
			var reality_chars = ["█", "▓", "▒", "░", "▄", "▀", "■", "□"]
			char_to_add = reality_chars[randi() % reality_chars.size()]

		message_overlay.text += char_to_add

		# Highly variable typing speed - reality breakdown
		var typing_speed = 0.04 + randf() * 0.12  # 0.04-0.16 seconds
		await tree.create_timer(typing_speed).timeout

		# Extended pauses for punctuation - system breakdown
		if message[i] == "." or message[i] == "?" or message[i] == "!":
			tree = get_tree()
			if not tree:
				is_typing_message = false
				return
			await tree.create_timer(0.5 + randf() * 1.0).timeout  # 0.5-1.5 seconds

		# Frequent micro-pauses - reality instability
		if randf() < 0.25:  # 25% chance for reality pause
			await tree.create_timer(0.1 + randf() * 0.4).timeout

	is_typing_message = false
