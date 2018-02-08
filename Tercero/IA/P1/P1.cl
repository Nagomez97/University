;;; Ejercicio 1

;;; Ejercicio 1.1

;;; Recursion

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
  (cond ((and (null x) (null y))(/ p (* (sqrt nx) (sqrt ny)))) ;; Caso base, devuelve el calculo completo en funcion de los acumuladores
        ((or (null y) (null x)) NIL) ;; Caso de longitudes diferentes
        ((< (first x) 0) NIL) ;; Caso un numero negativo en x
        ((< (first y) 0) NIL) ;; Caso un numero negativo en y
        (t (sc-rec-aux (rest x) (rest y) (+ p (* (first x) (first y)))
                      (+ nx (* (first x) (first x))) (+ ny (* (first y) (first y))))))) ;; Recursion con actualizacion de acumuladores

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
  (unless (or (null x) (null y))
  (sc-rec-aux x y 0 0 0))) ;; Llamada a la funcion auxiliar recursiva

;; Mapcar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sc-mapcar (x y)
;;; Calcula la similitud coseno de un vector usando mapcar
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;;
;;; OUTPUT: similitud coseno entre x e y
;;;
(defun sc-mapcar (x y)
  (unless (or (null x) (null y))
  (/ (reduce #'+ (mapcar #'* x y)) (* (sqrt (reduce #'+ (mapcar #'* x x))) (sqrt (reduce #'+ (mapcar #'* y y)))))))


















