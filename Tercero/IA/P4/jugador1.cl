(defpackage :grupo14pareja023Xf0604 ; se declara un paquete lisp que usa common-lisp
(:use :common-lisp :mancala) ; y mancala, y exporta la función de evaluación
(:export :heuristica :*alias*)) ; heurística y un alias para el torneo

(in-package grupo14pareja023Xf0604)

(defun heuristica (estado) ; función de evaluación heurística a implementar
  (first (posiciones-con-fichas-lado (estado-tablero estado)
                                     (estado-lado-sgte-jugador estado)
                                     0)))

(defvar *alias* '|Campeon|) ; alias que aparecerá en el ranking
