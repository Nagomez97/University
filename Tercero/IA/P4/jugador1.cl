(defpackage :grupo14pareja023Xf0604 ; se declara un paquete lisp que usa common-lisp
(:use :common-lisp :mancala) ; y mancala, y exporta la funci�n de evaluaci�n
(:export :heuristica :*alias*)) ; heur�stica y un alias para el torneo

(in-package grupo14pareja023Xf0604)

(defun heuristica (estado) ; funci�n de evaluaci�n heur�stica a implementar
  (first (posiciones-con-fichas-lado (estado-tablero estado)
                                     (estado-lado-sgte-jugador estado)
                                     0)))

(defvar *alias* '|Campeon|) ; alias que aparecer� en el ranking
