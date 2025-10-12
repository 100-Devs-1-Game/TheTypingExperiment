extends Control

## Version 1: Minimal and Silent
## Skull appears instantly, text types out slowly underneath

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

var message_text: String = "Why did you do it?"
var current_char: int = 0

func _ready() -> void:
	skull_label.text = skull_art
	skull_label.modulate = Color(0.6, 0.6, 0.6, 1)  # Dim gray, visible immediately

	message_label.text = ""
	message_label.modulate = Color(0.5, 0.5, 0.5, 1)

	await get_tree().create_timer(2.0).timeout
	_type_message()

func _type_message() -> void:
	while current_char < message_text.length():
		if not get_tree() or not message_label:
			return

		message_label.text += message_text[current_char]
		current_char += 1

		# Slow, deliberate typing
		await get_tree().create_timer(0.15).timeout
