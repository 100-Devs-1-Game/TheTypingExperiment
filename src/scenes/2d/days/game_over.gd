extends Control

## Game Over scene with ominous ASCII skull
## Displays after certain ending conditions

@onready var skull_label: Label = %SkullLabel
@onready var message_label: Label = %MessageLabel

var skull_art: String = """


                                     M MMN P MLLMPQMOOROOMOPQNN
                                           L   K    L     J
                          ROQPQPQQOOPPPPPNQPQPPPQQPPPOOPQQRPPQPOOOPRQQPP
                        ONNLKKKNMMOMLMNONNLOMMLNLPMMOMMLNKMLMMLKMNMMNMMM   O
                      O NNOOOPONNMMMOOONNOPOPMMNONMMNNMNONNNOPOOPNOPPOOMNQN
                    NOPNNNONPPPPNONNONONNMNMNMONONONNOOONOMMMONNNNNNOPNQNPSTUU
                      OLJJKLPPROONOPPONOPPPOOOOPPPOOOONONMOPPPPNOOOQTQRRRRQPQR
                 OPOPOPONOOPRRQQQQQNQQQQPOOPOOPQPPOPPOOOPPRPQQQPPQPQOQPSQSQPQQQQOP
                               L   POOOONNKNNNMNMNNKMMMMMMONNOO  N
               PNOMRPOPONNPPNPQQQPRQQRSRRPSPPPPRQRPPPQOQRQSQQPRRRRQQPPMPORPOQPPQPPNOQ
               N  PNN OMNOOMO PPPPOOONMOPNLMNNMMMNNNPNOMNQOQSRPQNONQOO ONONMONQ  OONM
             N MNOOQNPPNOOOPOPQRRPOPPPPPPPROPQQQOQOPQOOQPQRRRRRQRRRRRQNPOPOOPNPNRQPNN P
                 QQPSPPPOOPOOOPPPOOSLORPOQLMMOPOOMRNQNQPRRSQPPMNOPLNPPLOQPPOPRRQQPOQR
             N   N PO OPPQQ        POOQPPPNQPPOPOPONPQQQQORRPOP    O    RPPP    R N
                 PPMOQPOPQPOO        LLKPPNQQONNOPNLNOQORNQOOON        P NRSRPSOSPO

                 URQQRQ P                     QL OP RMO                      P TSRR

                                           S   OPPPNPPS
                                            POPLNPO POPN
                                           O  LI NMNP N
                                           QMOL         Q
                                           QQ           R
                                         OLP            R S

               NK                    QPPPN                QOPPO                 P LLQ P
               POON               OPL PPO                     N P               Q RPP
             P PQON   O     P     PPPRPP O                N O N  L           P    PPN N
              LQTTQRRS   OQPSNN                               OOO      Q     RQQSSQPP
             S   US                                              W     R        S     P
               PM  R                 O                                          RPPOP   P

             PKN                         P                O OQM                       Q
                                           T            P
                                        LO R            M POPM
                                     QTT       Q          NUTRT
             T                       Q N QPOPOPP    R PMO M SRR                       T
                                   J POPRS POPMN    NOOPPOSSQPRPP
                                     NPR                     PS
                                   I QRRPO                PRR PPO

                                R P            R      P   QRS

                                  QP T         RR         O   P













                                         T R   V    U   V S





"""

var glitch_animation_time: float = 0.0
var glitch_speed: float = 1.5
var base_color: Color = Color(0.8, 0.8, 0.8)  # Light gray for skull
var is_glitching: bool = false

func _ready() -> void:
	# Start invisible
	skull_label.modulate = Color(0.8, 0.8, 0.8, 0)
	message_label.modulate = Color(1, 0.3, 0.2, 0)  # Red-orange color

	skull_label.text = skull_art
	message_label.text = "Why did you do it?"

	# Start the sequence
	await _show_sequence()

func _process(delta: float) -> void:
	if is_glitching:
		glitch_animation_time += delta * glitch_speed
		_apply_glitch_effects()

func _show_sequence() -> void:
	# First fade in the message
	await _fade_in_message()

	# Hold message
	await get_tree().create_timer(3.0).timeout

	# Fade out message
	await _fade_out_message()

	# Brief pause
	await get_tree().create_timer(1.0).timeout

	# Fade in skull with glitch effects
	await _fade_in_skull()

	# Start continuous glitching
	is_glitching = true

func _fade_in_message() -> void:
	var fade_steps = 12
	var base_duration = 1.8
	var step_duration = base_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_label:
			return

		var alpha = float(step) / float(fade_steps)

		# Digital artifact simulation - random alpha jumps
		if randf() < 0.3:
			alpha += randf_range(-0.2, 0.3)
			alpha = clamp(alpha, 0.0, 1.0)

		message_label.modulate.a = alpha

		# Occasionally flicker the text
		if step % 3 == 0 and randf() < 0.4:
			message_label.modulate = Color(1, 0.2, 0.2, alpha)  # Brighter red flicker
		else:
			message_label.modulate = Color(1, 0.3, 0.2, alpha)  # Normal red-orange

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.05, 0.1)
			await get_tree().create_timer(actual_duration).timeout

func _fade_out_message() -> void:
	var fade_steps = 8
	var fade_duration = 1.2
	var step_duration = fade_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not message_label:
			return

		var alpha = 1.0 - (float(step) / float(fade_steps))

		# Chaotic alpha degradation
		if step > 2:
			alpha += randf_range(-0.4, 0.2)
			alpha = clamp(alpha, 0.0, 1.0)

		message_label.modulate.a = alpha

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.1, 0.15)
			await get_tree().create_timer(actual_duration).timeout

func _fade_in_skull() -> void:
	var fade_steps = 20
	var base_duration = 3.0
	var step_duration = base_duration / fade_steps

	for step in range(fade_steps + 1):
		if not get_tree() or not skull_label:
			return

		var alpha = float(step) / float(fade_steps)

		# Digital artifact simulation
		if randf() < 0.25:
			alpha += randf_range(-0.15, 0.25)
			alpha = clamp(alpha, 0.0, 1.0)

		skull_label.modulate.a = alpha

		# Start subtle glitching halfway through fade
		if step > fade_steps / 2:
			if randf() < 0.3:
				var glitch_color = Color(
					base_color.r + randf_range(-0.2, 0.2),
					base_color.g + randf_range(-0.2, 0.2),
					base_color.b + randf_range(-0.2, 0.2),
					alpha
				)
				skull_label.modulate = glitch_color
			else:
				skull_label.modulate = Color(base_color.r, base_color.g, base_color.b, alpha)

		if step < fade_steps:
			var actual_duration = step_duration + randf_range(-0.05, 0.08)
			await get_tree().create_timer(actual_duration).timeout

func _apply_glitch_effects() -> void:
	if not skull_label:
		return

	var current_alpha = skull_label.modulate.a

	# Random glitch pulses
	if int(glitch_animation_time * 10) % 15 == 0:
		# Color glitch
		if randf() < 0.4:
			var glitch_intensity = randf_range(0.1, 0.3)
			skull_label.modulate = Color(
				base_color.r + randf_range(-glitch_intensity, glitch_intensity),
				base_color.g + randf_range(-glitch_intensity, glitch_intensity),
				base_color.b + randf_range(-glitch_intensity, glitch_intensity),
				current_alpha
			)
		else:
			skull_label.modulate = Color(base_color.r, base_color.g, base_color.b, current_alpha)

	# Occasional intensity flicker
	if int(glitch_animation_time * 10) % 27 == 0 and randf() < 0.3:
		skull_label.modulate.a = current_alpha * randf_range(0.7, 1.3)
		await get_tree().create_timer(0.1).timeout
		if skull_label:
			skull_label.modulate.a = current_alpha
