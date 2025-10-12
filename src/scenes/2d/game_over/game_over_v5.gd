extends Control

## Version 5: Slow Fade with Heavy Breathing
## Very slow fade in (5+ seconds), skull barely visible, oppressive silence

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

var fade_time: float = 0.0
var max_fade_time: float = 6.0

func _ready() -> void:
	skull_label.text = skull_art
	message_label.text = "Why did you do it?"

	skull_label.modulate = Color(0.4, 0.4, 0.4, 0)
	message_label.modulate = Color(0.4, 0.4, 0.4, 0)

func _process(delta: float) -> void:
	if fade_time < max_fade_time:
		fade_time += delta

		var alpha = fade_time / max_fade_time
		# Very subtle, never fully opaque
		alpha = clamp(alpha * 0.5, 0.0, 0.5)

		skull_label.modulate.a = alpha
		message_label.modulate.a = alpha * 0.8
