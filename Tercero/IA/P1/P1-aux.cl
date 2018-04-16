;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-elt-lst (elt lst)
;;; Combina un elemento con todos los elementos de una lista.
;;;
;;; INPUT: elt: elemento a combinar
;;; lst: lista de elementos a combinar
;;;
;;; OUTPUT: lista de listas con todas las combinaciones
;;;
(defun combine-elt-lst (elt lst)
  (mapcar #'(lambda (x)
              (cons elt (if (listp x) x
                          (list x))))
    lst))

(combine-elt-lst 1 '())
(combine-elt-lst 1 '(1 2 3))
(combine-elt-lst 1 '(1 (2) 3))
(combine-elt-lst 1 '(1 NIL 3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-lst-lst (lst1 lst2)
;;; Realiza el producto cartesiano entre dos listas
;;;
;;; INPUT: lst1: lista 1
;;; lst2: lista 2
;;;
;;; OUTPUT: lista de listas con todas las combinaciones
;;;
(defun combine-lst-lst (lst1 lst2)
  (mapcan #'(lambda (x)
              (combine-elt-lst x lst2))
    lst1))

(combine-lst-lst nil nil) ;; --> NIL
(combine-lst-lst '(a b c) nil) ;; --> NIL
(combine-lst-lst NIL '(a b c)) ;; --> NIL
(combine-lst-lst '(a (b) c) '(1 2)) ;; --> ((A 1) (A 2) ((B) 1) ((B) 2) (C 1) (C 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-list-of-lsts-aux (lstolsts acc)
;;; Funcion auxiliar recursiva para el calculo de todas las 
;;; posibilidades entre n listas
;;;
;;; INPUT: lstolsts: lista de listas a combinar
;;; 
;;; OUTPUT: lista de listas con todas las combinaciones
;;;
(defun combine-list-of-lsts-aux (lstolsts)
  (if (null (rest lstolsts)) (first lstolsts) ;; Si es el ultimo elemento no continuara la recursion
    (combine-lst-lst (first lstolsts)
                     (combine-list-of-lsts-aux (rest lstolsts)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-list-of-lsts (lstolsts)
;;; Calcula todas las posibles combinaciones entre n listas
;;;
;;; INPUT: lstolsts: lista de listas a combinar
;;;
;;; OUTPUT: lista de listas con todas las combinaciones
;;;
(defun combine-list-of-lsts (lstolsts)
  (if (null lstolsts) '(NIL)
    (if (null (rest lstolsts))
        (mapcar #'list (first lstolsts)) ;; Lista con todos los elementos en listas
      (combine-list-of-lsts-aux lstolsts))))

(combine-list-of-lsts NIL)
(combine-list-of-lsts '(() (+ -) (1 2 3 4))) ;; --> NIL
(combine-list-of-lsts '((a b c) () (1 2 3 4))) ;; --> NIL
(combine-list-of-lsts '((a b c) (1 2 3 4) ())) ;; --> NIL
(combine-list-of-lsts '((1 2 3 4))) ;; --> ((1) (2) (3) (4))
(combine-list-of-lsts '((a b c) (+ -) (1 2 3 4))) ;; --> ((A + 1) (A + 2) (A + 3) (A + 4) (A - 1) (A - 2) (A - 3)
 (A - 4) (B + 1) (B + 2) ...)