extends Control

## Version 4: Line-by-Line Descent
## Skull appears line by line from top to bottom, message appears last

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

var skull_lines: Array = []
var current_line: int = 0

func _ready() -> void:
	skull_lines = skull_art.split("\n")

	skull_label.text = ""
	skull_label.modulate = Color(0.7, 0.7, 0.7, 1)

	message_label.text = ""
	message_label.modulate = Color(0.8, 0.3, 0.3, 1)

	_reveal_skull()

func _reveal_skull() -> void:
	while current_line < skull_lines.size():
		if not get_tree() or not skull_label:
			return

		skull_label.text += skull_lines[current_line]
		if current_line < skull_lines.size() - 1:
			skull_label.text += "\n"

		current_line += 1

		# Faster at first, slower as it progresses
		var delay = 0.02 + (float(current_line) / float(skull_lines.size())) * 0.06
		await get_tree().create_timer(delay).timeout

	# Reveal message after skull is complete
	await get_tree().create_timer(0.8).timeout
	message_label.text = "Why did you do it?"
