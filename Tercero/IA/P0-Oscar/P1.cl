;;; Ejercicio 1

;;; Ejercicio 1.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sc-rec-aux (x y p nx ny)
;;; Funcion auxiliar para calcular el valor de la similitud coseno
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;; p: acumulacion del producto escalar
;;; nx: acumulacion de la norma de x
;;; ny: acumulacion de la norma de y
;;;
;;; OUTPUT: similitud coseno entre x e y
;;;
(defun sc-rec-aux (x y p nx ny)
  (cond ((and (null x) (null y))(/ p (* nx ny)))
        ((or (null y) (null x))(NIL))
        ((< (first x) 0)(NIL))
        ((< (first y) 0)(NIL))
        (t(sc-rec-aux((rest x) (rest y) (+ p (* (first x) (first y)))
                      (+ nx (* (first x) (first x))) (+ ny (* (first y) (first y))))))))
  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sc-rec (x y)
;;; Calcula la similitud coseno de un vector de forma recursiva
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;;
;;; OUTPUT similitud coseno entre x e y
;;;
(defun sc-rec (x y)
  (sc-rec-aux(x y 0 0 0)))