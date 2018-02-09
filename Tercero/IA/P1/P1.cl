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
;;; filtrar-vectores (x vs conf)
;;; Funcion para seleccionar los vectores a analizar posteriormente
;;;
;;; INPUT: x: vector, representado como una lista
;;; vs: vector de vectores, representado como una lista de listas
;;; conf: Nivel de confianza
;;;
;;; OUTPUT: lista de tupas con la confianza y el vector al que pertenece
;;;
(defun filtrar-vectores (x vs conf)
  (mapcan (lambda (y)
            (let ((cos (sc-rec x y))) ;; coseno entre los vectores
              (when (opera-con-error #'> 
                                     cos 
                                     conf) 
                (list (cons cos 
                            (list y)))))) ;; Lista con el coseno y el vector asociado al mismo
       vs))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sc-conf (x vs conf)
;;; Devuelve aquellos vectores similares a una categoria
;;;
;;; INPUT: x: vector, representado como una lista
;;; vs: vector de vectores, representado como una lista de listas
;;; conf: Nivel de confianza
;;;
;;; OUTPUT: Vectores cuya similitud es superior al nivel de confianza, ordenados
;;;
(defun sc-conf (x vs conf) 
  (mapcar #'second ;; Nos quedamos solo con el segundo
    (sort ;; De la lista ordenada de mayor a menor por el coseno
     (filtrar-vectores x vs conf) #'> :key #'first)))

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

;; Ejercicio 1.4
(setf cats '((1 43 23 12) (2 33 54 24)))
(setf texts '((1 3 22 134) (2 43 26 58)))
(sc-classifier cats texts #'sc-rec) ;;((2 . 0.48981872) (1 . 0.81555086))
(sc-classifier cats texts #'sc-mapcar) ;;((2 . 0.48981872) (1 . 0.81555086))

(setf cats '((1 43 23 12 1 5 3) (2 33 54 24 52 68 84) 
             (3 2 3 4 5 6 7) (4 8 12 34 53 10 53) 
             (5 1 1 1 1 1 1) (6 68 35 111 54 65 87)
             (7 95 84 75 87 95 76) (8 1 1 1 1 1 1)
             (9 32 64 15 97 68 2) (10 54 87 91 56 57 30)
             (11 64 97 84 62 35 45) (12 88 99 54 61 55 32)))
(setf texts '((1 3 22 134 53 65 75) (2 43 26 58 65 78 45)
              (3 4 6 5 12 34 15) (4 5 6 7 12 34 65)
              (5 5 24 87 91 448 35) (6 5 78 35 94 68 54)
              (7 95 84 75 87 95 76) (8 1 1 1 1 1 1)))
(time (sc-classifier cats texts #'sc-rec))
(time (sc-classifier cats texts #'sc-mapcar))

;; Podemos apreciar que el tiempo invertido es mayor en nuestra implementacion recursiva
;; que en la implementacion mediante mapcar. Esto puede deberse a la paralelizacion de 
;; los calculos realizada por las funciones de tipo map.
;; Ademas podemos ver que la funcion recursiva además realiza muchos más accesos a memoria.

;; Ejercicio 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Returns true if the tolerance has been reached
;;
;; a: lower extremum of the interval in which we search for the root
;; b: b>a upper extremum of the interval in which we search for the root
;; tol: tolerance for the stopping criterion: if b-a < tol the function
;; returns true if the tolerance has been reached.
(defun test (a b tol)
  (when (< (- b a) tol)
    T))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finds a root of f between the points a and b using bisection.
;;
;; If f(a)f(b)>0 there is no guarantee that there will be a root in the
;; interval, and the function will return NIL.
;;
;; f: function of a single real parameter with real values whose root
;; we want to find
;; a: lower extremum of the interval in which we search for the root
;; b: b>a upper extremum of the interval in which we search for the root
;; tol: tolerance for the stopping criterion: if b-a < tol the function
;; returns (a+b)/2 as a solution.
;;
(defun bisect (f a b tol)
  (let ((med (/ (+ a b) 2)))
    (cond ((= 0 (funcall f a)) 
      a)
    ((= 0 (funcall f b)) 
      b)
    ((test a b tol) 
      med)
    ((> (* (funcall f a) (funcall f b)) 0)
      nil)
    ((< (* (funcall f a) (funcall f med)) 0)
      (bisec f a med tol))
    ((< (* (funcall f med) (funcall f b)) 0)
     (bisec f med b tol)))))








;; Ejercicio 3

;; Ejercicio 3.1

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
              (cond ((and (atom x) (atom elt)) ;; Elementos individuales
                     (list elt x))
                    ((atom elt) ;; LST es lista de listas
                     (cons elt x))
                    ((atom x) ;; ELT es una lista
                     (append elt (list x)))
                    (t (append elt x)))) ;; Ambos son listas
    lst))

;; Pruebas
(combine-elt-lst 'a NIL) ;; NIL
(combine-elt-lst 1 '(1 2 3 4)) ;; ((1 1) (1 2) (1 3) (1 4))
(combine-elt-lst 'b '(a c)) ;; ((b a) (b c))

;; Ejercicio 3.2

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

;; Pruebas
(combine-lst-lst nil nil) ;; --> NIL
(combine-lst-lst '(a b c) nil) ;; --> NIL
(combine-lst-lst NIL '(a b c)) ;; --> NIL
(combine-lst-lst '(a b c) '(1 2)) ;; --> ((A 1) (A 2) (B 1) (B 2) (C 1) (C 2))

;; Ejercicio 3.3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-list-of-lsts-aux (lstolsts acc)
;;; Calcula todas las posibles combinaciones entre n listas
;;;
;;; INPUT: lstolsts: lista de listas a combinar
;;; acc: lista de listas acumulada
;;; OUTPUT: lista de listas con todas las combinaciones
;;;
(defun combine-list-of-lsts-aux (lstolsts acc)
  (if (null lstolsts) acc
    (combine-list-of-lsts-aux (rest lstolsts)
                               (combine-lst-lst acc
                                                (first lstolsts)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-list-of-lsts (lstolsts)
;;; Calcula todas las posibles combinaciones entre n listas
;;;
;;; INPUT: lstolsts: lista de listas a combinar
;;;
;;; OUTPUT: lista de listas con todas las combinaciones
;;;
(defun combine-list-of-lsts (lstolsts)
  (unless (null lstolsts)
    (if (null (rest lstolsts))
        (mapcar #'list (first lstolsts))
      (combine-list-of-lsts-aux (cddr lstolsts)
                                (combine-lst-lst (first lstolsts)
                                                 (second lstolsts))))))

;; Pruebas
(combine-list-of-lsts '(() (+ -) (1 2 3 4))) ;; --> NIL
(combine-list-of-lsts '((a b c) () (1 2 3 4))) ;; --> NIL
(combine-list-of-lsts '((a b c) (1 2 3 4) ())) ;; --> NIL
(combine-list-of-lsts '((1 2 3 4))) ;; --> ((1) (2) (3) (4))
(combine-list-of-lsts '((a b c) (+ -) (1 2 3 4)))








