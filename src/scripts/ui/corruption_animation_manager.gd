class_name CorruptionAnimationManager
extends Node

## Centralized corruption animation effects manager
## Handles all visual corruption effects for days 2-5 to eliminate code duplication

# Day-specific configuration
const DAY_CONFIGS: Dictionary = {
	2: {
		"corruption_color": "#ff0000",
		"animation_speed": 1.3,
		"intensity_base": 0.3,
		"intensity_max": 0.7,
		"pulse_speed_min": 2.5,
		"pulse_speed_max": 4.0,
		"flicker_chance_min": 0.15,
		"flicker_chance_max": 0.30,
		"glitch_base_min": 0.03,
		"glitch_base_max": 0.07,
		"typed_glitch_multiplier": 0.5,
		"time_step_interval": 0.3,
		"char_time_offset": 0.3,
		"color_high": "#ff0000",
		"color_mid": "#dd0000",
		"color_low": "#cc0000",
		"flicker_colors": ["#ff0000", "#cc0000", "#aa0000", "#ff3333"],
		"glitch_chars": ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"],
		"typed_color_base": 170,  # For #aa0000 to #bb0000 range
		"typed_pulse_speed": 1.5
	},
	3: {
		"corruption_color": "#ff6600",
		"animation_speed": 1.5,
		"intensity_base": 0.4,
		"intensity_max": 0.9,
		"pulse_speed_min": 2.0,
		"pulse_speed_max": 3.5,
		"flicker_chance_min": 0.18,
		"flicker_chance_max": 0.33,
		"glitch_base_min": 0.05,
		"glitch_base_max": 0.11,
		"typed_glitch_multiplier": 0.5,
		"time_step_interval": 0.3,
		"char_time_offset": 0.3,
		"color_high": "#ff6600",
		"color_mid": "#dd5500",
		"color_low": "#cc4400",
		"flicker_colors": ["#ff6600", "#cc4400", "#aa3300", "#ff8833"],
		"glitch_chars": ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"],
		"typed_color_base": 204,  # For #cc4400 to #dd4400 range
		"typed_pulse_speed": 1.2
	},
	4: {
		"corruption_color": "#aa00aa",
		"animation_speed": 1.8,
		"intensity_base": 0.5,
		"intensity_max": 0.9,
		"pulse_speed_min": 2.5,
		"pulse_speed_max": 4.5,
		"flicker_chance_min": 0.20,
		"flicker_chance_max": 0.35,
		"glitch_base_min": 0.06,
		"glitch_base_max": 0.13,
		"typed_glitch_multiplier": 0.5,
		"time_step_interval": 0.3,
		"char_time_offset": 0.3,
		"color_high": "#aa00aa",
		"color_mid": "#990099",
		"color_low": "#880088",
		"flicker_colors": ["#aa00aa", "#880088", "#770077", "#bb00bb"],
		"glitch_chars": ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐"],
		"typed_color_base": 136,  # For #880088 to #990099 range
		"typed_pulse_speed": 1.5
	},
	5: {
		"corruption_color": "#ff4400",
		"animation_speed": 2.5,
		"intensity_base": 0.7,
		"intensity_max": 1.0,
		"pulse_speed_min": 3.0,
		"pulse_speed_max": 6.0,
		"flicker_chance_min": 0.30,
		"flicker_chance_max": 0.50,
		"glitch_base_min": 0.10,
		"glitch_base_max": 0.20,
		"typed_glitch_multiplier": 0.6,
		"time_step_interval": 0.25,
		"char_time_offset": 0.2,
		"color_high": "#ff4400",
		"color_mid": "#dd3300",
		"color_low": "#aa2200",
		"flicker_colors": ["#ff4400", "#ee3300", "#cc2200", "#ff5500", "#ff0000"],
		"glitch_chars": ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐", "■", "□", "▪", "▫", "◆", "◇", "●", "○"],
		"typed_color_base": 170,  # For variable red-orange range
		"typed_pulse_speed": 2.0
	}
}

# Animation state
var corruption_animation_time: float = 0.0
var current_day: int = 2

func _ready() -> void:
	pass

## Update animation time (call from _process in day scripts)
func update_animation_time(delta: float) -> void:
	var config = DAY_CONFIGS.get(current_day, DAY_CONFIGS[2])
	corruption_animation_time += delta * config.animation_speed

## Set which day's configuration to use
func set_day(day_number: int) -> void:
	current_day = day_number

## Get corruption animation effects for a character
## Returns: {"color": String, "character": String}
func get_corruption_effects(char_position: int, current_stage: int,
							stages_per_day: int, is_typed_correctly: bool = false) -> Dictionary:

	var config = DAY_CONFIGS.get(current_day, DAY_CONFIGS[2])
	var effects = {"color": config.corruption_color, "character": ""}

	# Calculate current animation intensity (grows over time during day)
	var stage_progress: float = float(current_stage) / float(stages_per_day)
	var intensity_range = config.intensity_max - config.intensity_base
	var current_intensity: float = config.intensity_base + (stage_progress * intensity_range)

	# Create unique seed for this character position for consistent randomization
	var time_step: int = int(corruption_animation_time / config.time_step_interval)
	var char_seed: int = (char_position * 17 + 23) % 1000
	var seeded_random = RandomNumberGenerator.new()
	seeded_random.seed = char_seed + time_step

	# Character-specific timing offset
	var char_time_offset: float = float(char_position) * config.char_time_offset
	var char_animation_time: float = corruption_animation_time + char_time_offset

	# Base pulsing effect with character-specific timing
	var pulse_speed: float = config.pulse_speed_min + seeded_random.randf() * (config.pulse_speed_max - config.pulse_speed_min)
	var pulse_phase: float = sin(char_animation_time * pulse_speed) * 0.5 + 0.5
	var pulse_intensity: float = current_intensity * pulse_phase

	# TYPED CORRECTLY: Provide clear visual feedback for successful typing
	if is_typed_correctly:
		effects = _get_typed_effects(config, char_animation_time, seeded_random, current_intensity)
	# UNTYPED: Full corruption animation effects
	else:
		effects = _get_untyped_effects(config, pulse_intensity, seeded_random, current_intensity)

	return effects

## Get effects for correctly typed characters
func _get_typed_effects(config: Dictionary, char_animation_time: float,
						seeded_random: RandomNumberGenerator, current_intensity: float) -> Dictionary:
	var effects = {"color": config.corruption_color, "character": ""}

	# Subtle pulsing for typed characters
	var typed_pulse = sin(char_animation_time * config.typed_pulse_speed) * 0.3 + 0.7

	# Day-specific typed color calculation
	match current_day:
		2:
			var red_intensity = int(config.typed_color_base * typed_pulse)
			effects.color = "#%02x0000" % red_intensity
		3:
			var orange_intensity = int(config.typed_color_base * typed_pulse)
			effects.color = "#%02x4400" % orange_intensity
		4:
			var purple_intensity = int(config.typed_color_base * typed_pulse)
			effects.color = "#%02x00%02x" % [purple_intensity, purple_intensity]
		5:
			var red_intensity = int(config.typed_color_base * typed_pulse)
			var green_intensity = int(34 * typed_pulse)
			effects.color = "#%02x%02x00" % [red_intensity, green_intensity]

	# Reduced glitch chance for typed characters
	var glitch_base_chance: float = config.glitch_base_min + seeded_random.randf() * (config.glitch_base_max - config.glitch_base_min)
	var typed_glitch_chance: float = glitch_base_chance * current_intensity * config.typed_glitch_multiplier

	if seeded_random.randf() < typed_glitch_chance:
		effects.character = config.glitch_chars[seeded_random.randi() % config.glitch_chars.size()]

	return effects

## Get effects for untyped characters
func _get_untyped_effects(config: Dictionary, pulse_intensity: float,
						  seeded_random: RandomNumberGenerator, current_intensity: float) -> Dictionary:
	var effects = {"color": config.corruption_color, "character": ""}

	# Color animation with character-specific thresholds
	var color_threshold_high: float = 0.6 + seeded_random.randf() * 0.2
	var color_threshold_mid: float = 0.3 + seeded_random.randf() * 0.2

	if pulse_intensity > color_threshold_high:
		effects.color = config.color_high
	elif pulse_intensity > color_threshold_mid:
		effects.color = config.color_mid
	else:
		effects.color = config.color_low

	# Character-specific flicker chance
	var flicker_chance: float = config.flicker_chance_min + seeded_random.randf() * (config.flicker_chance_max - config.flicker_chance_min)
	if seeded_random.randf() < flicker_chance * current_intensity:
		effects.color = config.flicker_colors[seeded_random.randi() % config.flicker_colors.size()]

	# Character-specific glitch substitution
	var glitch_base_chance: float = config.glitch_base_min + seeded_random.randf() * (config.glitch_base_max - config.glitch_base_min)
	var glitch_chance: float = glitch_base_chance * current_intensity

	if seeded_random.randf() < glitch_chance:
		effects.character = config.glitch_chars[seeded_random.randi() % config.glitch_chars.size()]

	return effects

## Get the corruption color for the current day
func get_corruption_color() -> String:
	var config = DAY_CONFIGS.get(current_day, DAY_CONFIGS[2])
	return config.corruption_color

## Get the animation speed for the current day
func get_animation_speed() -> float:
	var config = DAY_CONFIGS.get(current_day, DAY_CONFIGS[2])
	return config.animation_speed

## Reset animation time (useful for testing or scene transitions)
func reset_animation_time() -> void:
	corruption_animation_time = 0.0
