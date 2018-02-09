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
         (minusp (first x)) ;; Si alguno es negativo, devolver NIL
         (minusp (first y)))
           t))

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
  (cond ((and (null x) (null y)) 0) ;; Si estan vacías, devolver cero (caso base)
        ((caso-error x y) NIL) ;; Comprobamos errores
        (t (opera-con-error #'+ 
                            (* (first x) (first y)) 
                            (pe-rec (rest x) (rest y)))))) ;; Recursion

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
  (if (or (null x) (null y)) ;; Comprobamos que no esten vacios para evitar divisiones entre 0.
      0
    (opera-con-error #'/ 
                     (pe-rec x y)
                     (sqrt (* (pe-rec x x) 
                              (pe-rec y y))))))

;;; Pruebas
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
  (if (or (null x) (null y)) ;; Comprobamos que no esten vacios para evitar divisiones entre 0
      0
    (/ (pe-mapcar x y)
       (sqrt (* (pe-mapcar x x) 
                (pe-mapcar y y))))))

;;; Pruebas
(sc-mapcar '() '())
(sc-mapcar '(0 1) '(1 1))
(sc-mapcar '(0 1) '(1 0))
(sc-mapcar '(0 1) '(0 1))

;;; Ejercicio 1.2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sc-conf (x vs conf)
;;; Devuelve aquellos vectores similares a una categoria
;;;
;;; INPUT: x: vector, representado como una lista
;;; vs: vector de vectores, representado como una lista de listas
;;; conf: Nivel de confianza
;;; OUTPUT: Vectores cuya similitud es superior al nivel de confianza, ordenados
;;;
(defun sc-conf (x vs conf) 
  (mapcar #'second ;; Nos quedamos solo con el segundo
    (sort ;; De la lista ordenada de mayor a menor por el coseno
     (mapcan (lambda (y)
               (let ((cos (sc-rec x y))) ;; coseno entre los vectores
                 (when (opera-con-error #'> 
                                        cos 
                                        conf) 
                   (list (cons cos 
                               (list y)))))) ;; Lista con el coseno y el vector asociado al mismo
       vs) #'> :key #'first)))

;; Pruebas
(sc-conf '(1 0) '() 0.5) ;; NIL
(sc-conf '(1 0) '(()) 0.5) ;; NIL
(sc-conf '(1 0) '((0 1) (1 1) (1 0)) 0.5) ;; ((1 0) (1 1))
(sc-conf '(1 2 3) '((1 2 3) (1 2) (0 3 1) (0 0 1) (12 0 1)) 0.7) ;; ((1 2 3) (0 0 1) (0 3 1))

;; EJercicio 1.3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; calcular-cosenos (cats text func)
;;; Funcion auxiliar para obtener todas las tuplas posibles
;;;
;;; INPUT: cats: vector de vectores, representado como una lista de listas
;;; vs: vector 
;;; func: referencia a función para evaluar la similitud coseno
;;;
;;; OUTPUT: Pares identificador de categoría con resultado de similitud coseno
;;;
(defun calcular-cosenos (cats text func)
  (mapcar #'(lambda (x) 
              (cons (first x)
                    (funcall func (rest x) (rest text))))
    cats))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; coger-mayor (valores)
;;; Funcion auxiliar para obtener la mayor tupla
;;;
;;; INPUT: valores: lista de tuplas con los valores a analizar
;;;
;;; OUTPUT: tupla cuyo segundo elemento es el mayor de la lista
;;;
(defun coger-mayor (valores)
   (first (sort valores #'> :key #'rest)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sc-classifier (cats texts func)
;;; Clasifica a los textos en categorías.
;;;
;;; INPUT: cats: vector de vectores, representado como una lista de listas
;;; vs: vector de vectores, representado como una lista de listas
;;; func: referencia a función para evaluar la similitud coseno
;;; OUTPUT: Pares identificador de categoría con resultado de similitud coseno
;;;
(defun sc-classifier (cats texts func)
  (mapcan #'(lambda (x)
              (list 
               (coger-mayor (calcular-cosenos cats x func))))                    
    texts))













;; Ejercicio 2