extends Control

## Version 2: Corrupted Reveal
## Skull slowly materializes from corruption characters, text flickers above

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

var corruption_progress: float = 0.0
var is_revealing: bool = false

func _ready() -> void:
	message_label.text = "Why did you do it?"
	message_label.modulate = Color(0.8, 0.2, 0.2, 0)

	skull_label.text = ""
	skull_label.modulate = Color(0.7, 0.7, 0.7, 1)

	await get_tree().create_timer(1.0).timeout

	# Flash message in
	_flash_message()

	await get_tree().create_timer(0.5).timeout
	is_revealing = true

func _process(delta: float) -> void:
	if is_revealing:
		corruption_progress += delta * 0.4
		_update_skull_reveal()

		if corruption_progress >= 1.0:
			is_revealing = false
			skull_label.text = skull_art

func _update_skull_reveal() -> void:
	var revealed_text = ""
	var glitch_chars = ["█", "▓", "▒", "░", "▄", "▀", "▌", "▐", "■", "□"]

	for i in range(skull_art.length()):
		var char = skull_art[i]
		var reveal_threshold = float(i) / float(skull_art.length())

		if corruption_progress > reveal_threshold:
			# Character is revealed
			revealed_text += char
		else:
			# Still corrupted
			if char != " " and char != "\n":
				revealed_text += glitch_chars[randi() % glitch_chars.size()]
			else:
				revealed_text += char

	skull_label.text = revealed_text

func _flash_message() -> void:
	for i in range(5):
		if not message_label:
			return
		message_label.modulate.a = 1.0 if i % 2 == 0 else 0.0
		await get_tree().create_timer(0.1).timeout

	message_label.modulate.a = 1.0
