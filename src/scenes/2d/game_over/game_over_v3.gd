extends Control

## Version 3: Instant Dread
## Everything appears at once, skull pulses slowly with red tint

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

var pulse_time: float = 0.0

func _ready() -> void:
	skull_label.text = skull_art
	message_label.text = "Why did you do it?"

	skull_label.modulate = Color(0.6, 0.6, 0.6, 1)
	message_label.modulate = Color(0.6, 0.6, 0.6, 1)

func _process(delta: float) -> void:
	pulse_time += delta * 0.8

	# Slow pulse between gray and red
	var pulse = (sin(pulse_time) + 1.0) / 2.0  # 0 to 1

	var gray_val = 0.6
	var red_val = 0.6 + (pulse * 0.3)

	skull_label.modulate = Color(red_val, gray_val * (1.0 - pulse * 0.5), gray_val * (1.0 - pulse * 0.5), 1)
	message_label.modulate = Color(red_val * 0.8, gray_val * 0.7, gray_val * 0.7, 1)
