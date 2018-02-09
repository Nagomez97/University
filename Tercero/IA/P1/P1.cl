;;; Ejercicio 1

;;; Ejercicio 1.1

;;; Recursion

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; opera-con-error(x y op)
;;; Funcion auxiliar que opera comprobando errores
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;; op: operacion a realizar
;;;
;;; OUTPUT: resultado de operacion o NIL en caso de error
;;;
(defun opera-con-error (op x y)
  (unless (or (null x) (null y))
    (funcall op x y)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; caso-error(x y)
;;; Funcion auxiliar que comprueba los casos de error
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;;
;;; OUTPUT: T (algo esta mal) o NIL (todo correcto)
;;;
(defun caso-error (x y)
  (when (or (null x) 
         (null y) 
         (minusp (first x)) 
         (minusp (first y)))
           t)) ;; Caso de longitudes diferentes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pe-rec (x y)
;;; Funcion auxiliar que calcula el producto escalar entre dos vectores
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;;
;;; OUTPUT: Producto escalar de ambos o NIL si hay algun error
;;;
(defun pe-rec (x y)
  (cond ((and (null x) (null y)) 0)
        ((caso-error x y) NIL)
        (t (opera-con-error #'+ 
                            (* (first x) (first y)) 
                            (pe-rec (rest x) (rest y))))))

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
  (if (or (null x) (null y))
      0
    (opera-con-error #'/ 
                     (pe-rec x y)
                     (sqrt (* (pe-rec x x) 
                              (pe-rec y y))))))

;;; PRUEBAS
(sc-rec '() '())
(sc-rec '(0 1) '(1 1))
(sc-rec '(0 1) '(1 0))
(sc-rec '(0 1) '(0 1))

;; Mapcar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pe-mapcar (x y)
;;; Calcula el producto escalar usando mapcar
;;;
;;; INPUT: x: vector, representado como una lista
;;; y: vector, representado como una lista
;;;
;;; OUTPUT: similitud coseno entre x e y
;;;
(defun pe-mapcar (x y)
  (apply #'+ (mapcar #'* x y)))

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
  (if (or (null x)
          (null y))
      0
    (/ (pe-mapcar x y)
       (sqrt (* (pe-mapcar x x) 
                (pe-mapcar y y))))))

;;; PRUEBAS
(sc-mapcar '() '())
(sc-mapcar '(0 1) '(1 1))
(sc-mapcar '(0 1) '(1 0))
(sc-mapcar '(0 1) '(0 1))
