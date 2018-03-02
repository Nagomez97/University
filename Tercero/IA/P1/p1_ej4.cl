﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definicion de simbolos que representan valores de verdad,
;; conectores y predicados para evaluar si una expresion LISP
;; es un valor de verdad o un conector
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconstant +bicond+ '<=>)
(defconstant +cond+   '=>)
(defconstant +and+    '^)
(defconstant +or+     'v)
(defconstant +not+    '~)

(defun truth-value-p (x) 
  (or (eql x T) (eql x NIL)))

(defun unary-connector-p (x) 
  (eql x +not+))

(defun binary-connector-p (x) 
  (or (eql x +bicond+) 
      (eql x +cond+)))

(defun n-ary-connector-p (x) 
  (or (eql x +and+) 
      (eql x +or+)))

(defun connector-p (x) 
  (or (unary-connector-p  x)
      (binary-connector-p x)
      (n-ary-connector-p  x)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.1.1
;; Predicado para determinar si una expresion en LISP
;; es un literal positivo 
;;
;; RECIBE   : expresion 
;; EVALUA A : T si la expresion es un literal positivo, 
;;            NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun positive-literal-p (x)
  (and (atom x) 
       (not (or (connector-p x) 
                (truth-value-p x)))))

;; EJEMPLOS:
(positive-literal-p 'p)
;; evalua a T
(positive-literal-p T)
(positive-literal-p NIL)
(positive-literal-p '~)
(positive-literal-p '=>)
(positive-literal-p '(p))
(positive-literal-p '(~ p))
(positive-literal-p '(~ (v p q)))
;; evaluan a NIL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.1.2
;; Predicado para determinar si una expresion
;; es un literal negativo 
;;
;; RECIBE   : expresion x 
;; EVALUA A : T si la expresion es un literal negativo, 
;;            NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun negative-literal-p (x)
  (and (listp x) 
       (eql (first x) +not+) 
       (positive-literal-p (second x))))

;; EJEMPLOS:
(negative-literal-p '(~ p))        ; T
(negative-literal-p NIL)           ; NIL
(negative-literal-p '~)            ; NIL
(negative-literal-p '=>)           ; NIL
(negative-literal-p '(p))          ; NIL
(negative-literal-p '((~ p)))      ; NIL
(negative-literal-p '(~ T))        ; NIL
(negative-literal-p '(~ NIL))      ; NIL
(negative-literal-p '(~ =>))       ; NIL
(negative-literal-p 'p)            ; NIL
(negative-literal-p '((~ p)))      ; NIL
(negative-literal-p '(~ (v p q)))  ; NIL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.1.3
;; Predicado para determinar si una expresion es un literal  
;;
;; RECIBE   : expresion x  
;; EVALUA A : T si la expresion es un literal, 
;;            NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun literal-p (x) 
  (or (positive-literal-p x) (negative-literal-p x)))

;; EJEMPLOS:
(literal-p 'p)             
(literal-p '(~ p))      
;;; evaluan a T
(literal-p '(p))
(literal-p '(~ (v p q)))
;;; evaluan a  NIL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Predicado para determinar si una expresion esta en formato prefijo 
;;
;; RECIBE   : expresion x 
;; EVALUA A : T si x esta en formato prefijo, NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun wff-prefix-p (x)
  (unless (null x)             ;; NIL no es FBF en formato prefijo (por convencion)
    (or (literal-p x)          ;; Un literal es FBF en formato prefijo
        (and (listp x)         ;; En caso de que no sea un literal debe ser una lista
             (let ((connector (first x))
                   (rest_1    (rest  x)))
               (cond
                ((unary-connector-p connector)  ;; Si el primer elemento es un connector unario
                 (and (null (rest rest_1))      ;; deberia tener la estructura (<conector> FBF)
                      (wff-prefix-p (first rest_1)))) 
                ((binary-connector-p connector) ;; Si el primer elemento es un conector binario
                 (let ((rest_2 (rest rest_1)))  ;; deberia tener la estructura 
                   (and (null (rest rest_2))    ;; (<conector> FBF1 FBF2)
                        (wff-prefix-p (first rest_1))
                        (wff-prefix-p (first rest_2)))))               
                ((n-ary-connector-p connector)  ;; Si el primer elemento es un conector enario
                 (or (null rest_1)              ;; conjuncion o disyuncion vacias
                     (and (wff-prefix-p (first rest_1)) ;; tienen que ser FBF los operandos 
                          (let ((rest_2 (rest rest_1)))
                            (or (null rest_2)           ;; conjuncion o disyuncion con un elemento
                                (wff-prefix-p (cons connector rest_2)))))))	
                (t NIL)))))))                   ;; No es FBF en formato prefijo 
;;
;; EJEMPLOS:
(wff-prefix-p '(v))
(wff-prefix-p '(^))
(wff-prefix-p '(v A))
(wff-prefix-p '(^ (~ B)))
(wff-prefix-p '(v A (~ B)))
(wff-prefix-p '(v (~ B) A ))
(wff-prefix-p '(^ (V P (=> A (^ B (~ C) D))) (^ (<=> P (~ Q)) P) E))
;;; evaluan a T
(wff-prefix-p 'NIL)
(wff-prefix-p '(~))
(wff-prefix-p '(=>))
(wff-prefix-p '(<=>))
(wff-prefix-p '(^ (V P (=> A ( B ^ (~ C) ^ D))) (^ (<=> P (~ Q)) P) E))
;;; evaluan a NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.1.4
;; Predicado para determinar si una expresion esta en formato infijo 
;;
;; RECIBE   : expresion x 
;; EVALUA A : T si x esta en formato infijo, 
;;            NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun wff-infix-p (x)
   (unless (null x)             ;; NIL no es FBF en formato infijo (por convencion)
     (or (literal-p x)          ;; Un literal es FBF en formato infijo
         (and (listp x)         ;; En caso de que no sea un literal debe ser una lista
              (cond
               ((connector-p (first x)) ;; Caso conector en primera posicion
                (cond
                 ((unary-connector-p (first x)) ;; si es conector unario
                  (and (null (third x))         ;; deberia tener la estructura (<conector> FBF)
                       (wff-infix-p (second x))))
                 ((n-ary-connector-p (first x)) ;; si es conector n-ario
                  (null (second x)))            ;; debería tener la estructura (<conector>)
                 (t NIL)))
               ((binary-connector-p (second x))  ;; Caso conector binario
                (and (null (fourth x))           ;; deberia tener estructura (FBF <conector> FBF)
                     (wff-infix-p (first x))
                     (wff-infix-p (third x))))
               ((n-ary-connector-p (second x))   ;; Caso conector n-ario en segunda posicion
                (if (null (fourth x))            ;; formato (FBF <conector> FBF)
                    (and (wff-infix-p (first x))
                         (wff-infix-p (third x)))
                  (and (eql (second x) (fourth x)) ;; formaro (FBF <conector> FBF <conector igual> ...)
                       (wff-infix-p (first x))
                       (wff-infix-p (rest (rest x))))))
               (t NIL))))))
 

;;
;; EJEMPLOS:
;;
(wff-infix-p 'a) 						; T
(wff-infix-p '(^)) 					; T  ;; por convencion
(wff-infix-p '(v)) 					; T  ;; por convencion
(wff-infix-p '(A ^ (v))) 			      ; T  
(wff-infix-p '( a ^ b ^ (p v q) ^ (~ r) ^ s))  	; T 
(wff-infix-p '(A => B)) 				; T
(wff-infix-p '(A => (B <=> C))) 			; T
(wff-infix-p '( B => (A ^ C ^ D))) 			; T   
(wff-infix-p '( B => (A ^ C))) 			; T 
(wff-infix-p '( B ^ (A ^ C))) 			; T 
(wff-infix-p '((p v (a => (b ^ (~ c) ^ d))) ^ ((p <=> (~ q)) ^ p ) ^ e))  ; T 
(wff-infix-p nil) 					; NIL
(wff-infix-p '(a ^)) 					; NIL
(wff-infix-p '(^ a)) 					; NIL
(wff-infix-p '(a)) 					; NIL
(wff-infix-p '((a))) 				      ; NIL
(wff-infix-p '((a) b))   			      ; NIL
(wff-infix-p '(^ a b q (~ r) s))  		      ; NIL 
(wff-infix-p '( B => A C)) 			      ; NIL   
(wff-infix-p '( => A)) 				      ; NIL   
(wff-infix-p '(A =>)) 				      ; NIL   
(wff-infix-p '(A => B <=> C)) 		      ; NIL
(wff-infix-p '( B => (A ^ C v D))) 		      ; NIL   
(wff-infix-p '( B ^ C v D )) 			      ; NIL 
(wff-infix-p '((p v (a => e (b ^ (~ c) ^ d))) ^ ((p <=> (~ q)) ^ p ) ^ e)); NIL 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convierte FBF en formato prefijo a FBF en formato infijo
;;
;; RECIBE   : FBF en formato prefijo 
;; EVALUA A : FBF en formato infijo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun prefix-to-infix (wff)
  (when (wff-prefix-p wff)
    (if (literal-p wff)
        wff
      (let ((connector      (first wff))
            (elements-wff (rest wff)))
        (cond
         ((unary-connector-p connector) 
          (list connector (prefix-to-infix (second wff))))
         ((binary-connector-p connector) 
          (list (prefix-to-infix (second wff))
                connector
                (prefix-to-infix (third wff))))
         ((n-ary-connector-p connector) 
          (cond 
           ((null elements-wff)        ;;; conjuncion o disyuncion vacias. 
            wff)                       ;;; por convencion, se acepta como fbf en formato infijo
           ((null (cdr elements-wff))  ;;; conjuncion o disyuncion con un unico elemento
            (prefix-to-infix (car elements-wff)))  
           (t (cons (prefix-to-infix (first elements-wff)) 
                    (mapcan #'(lambda(x) (list connector (prefix-to-infix x))) 
                      (rest elements-wff))))))
         (t NIL)))))) ;; no deberia llegar a este paso nunca

;;
;;  EJEMPLOS:
;;
(prefix-to-infix '(v))          ; (V)
(prefix-to-infix '(^))          ; (^)
(prefix-to-infix '(v a))        ; A
(prefix-to-infix '(^ a))        ; A
(prefix-to-infix '(^ (~ a)))    ; (~ a)
(prefix-to-infix '(v a b))      ; (A v B)
(prefix-to-infix '(v a b c))    ; (A V B V C)
(prefix-to-infix '(^ (V P (=> A (^ B (~ C) D))) (^ (<=> P (~ Q)) P) E))
;;; ((P V (A => (B ^ (~ C) ^ D))) ^ ((P <=> (~ Q)) ^ P) ^ E)
(prefix-to-infix '(^ (v p (=> a (^ b (~ c) d))))) ; (P V (A => (B ^ (~ C) ^ D)))
(prefix-to-infix '(^ (^ (<=> p (~ q)) p ) e))     ; (((P <=> (~ Q)) ^ P) ^ E)  
(prefix-to-infix '( v (~ p) q (~ r) (~ s)))       ; ((~ P) V Q V (~ R) V (~ S))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.1.5
;;
;; Convierte FBF en formato infijo a FBF en formato prefijo
;;  
;; RECIBE   : FBF en formato infijo 
;; EVALUA A : FBF en formato prefijo 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun infix-to-prefix (wff)
  (when (wff-infix-p wff)
    (if (literal-p wff)
        wff
      (let ((first (first wff))
            (second (second wff)))
        (cond
         ((unary-connector-p first)
          (list first (infix-to-prefix second)))
         ((binary-connector-p second)
          (list second
                (infix-to-prefix first)
                (infix-to-prefix (third wff))))
         ((n-ary-connector-p second)
          (if (null (fourth wff))
              (list second 
                    (infix-to-prefix first) 
                    (infix-to-prefix (third wff)))
              (cons second 
                    (cons (infix-to-prefix first)
                          (rest (infix-to-prefix (rest (rest wff))))))))
         (t NIL))))))

;;
;; EJEMPLOS
;;
(infix-to-prefix nil)      ;; NIL
(infix-to-prefix 'a)       ;; a
(infix-to-prefix '((a)))   ;; NIL
(infix-to-prefix '(a))     ;; NIL
(infix-to-prefix '(((a)))) ;; NIL
(prefix-to-infix (infix-to-prefix '((p v (a => (b ^ (~ c) ^ d))) ^ ((p <=> (~ q)) ^ p) ^ e)) ) 
;;-> ((P V (A => (B ^ (~ C) ^ D))) ^ ((P <=> (~ Q)) ^ P) ^ E)


(infix-to-prefix '((p v (a => (b ^ (~ c) ^ d))) ^  ((p <=> (~ q)) ^ p) ^ e))  
;; (^ (V P (=> A (^ B (~ C) D))) (^ (<=> P (~ Q)) P) E)

(infix-to-prefix '(~ ((~ p) v q v (~ r) v (~ s))))
;; (~ (V (~ P) Q (~ R) (~ S)))


(infix-to-prefix
 (prefix-to-infix
  '(V (~ P) Q (~ R) (~ S))))
;;-> (V (~ P) Q (~ R) (~ S))

(infix-to-prefix
 (prefix-to-infix
  '(~ (V (~ P) Q (~ R) (~ S)))))
;;-> (~ (V (~ P) Q (~ R) (~ S)))


(infix-to-prefix 'a)  ; A
(infix-to-prefix '((p v (a => (b ^ (~ c) ^ d))) ^  ((p <=> (~ q)) ^ p) ^ e))  
;; (^ (V P (=> A (^ B (~ C) D))) (^ (<=> P (~ Q)) P) E)

(infix-to-prefix '(~ ((~ p) v q v (~ r) v (~ s))))
;; (~ (V (~ P) Q (~ R) (~ S)))

(infix-to-prefix  (prefix-to-infix '(^ (v p (=> a (^ b (~ c) d)))))) ; '(v p (=> a (^ b (~ c) d))))
(infix-to-prefix  (prefix-to-infix '(^ (^ (<=> p (~ q)) p ) e))) ; '(^ (^ (<=> p (~ q)) p ) e))  
(infix-to-prefix (prefix-to-infix '( v (~ p) q (~ r) (~ s))))  ; '( v (~ p) q (~ r) (~ s)))
;;;

(infix-to-prefix '(p v (a => (b ^ (~ c) ^ d)))) ; (V P (=> A (^ B (~ C) D)))
(infix-to-prefix '(((P <=> (~ Q)) ^ P) ^ E))  ; (^ (^ (<=> P (~ Q)) P) E)
(infix-to-prefix '((~ P) V Q V (~ R) V (~ S))); (V (~ P) Q (~ R) (~ S))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.1.6
;; Predicado para determinar si una FBF es una clausula  
;;
;; RECIBE   : FBF en formato prefijo 
;; EVALUA A : T si FBF es una clausula, NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun clause-p (wff)
  (when (and (wff-prefix-p wff) (listp wff))
    (let ((connector (first wff)))
      (when (eql connector +or+)
        (let ((elements (rest wff)))
        (cond ((null elements) ;;No hay más elementos, es clausula por convencion
               t)
              ((and (literal-p (first elements)) ;;Comprobamos el primer elemento
                    (clause-p (cons connector (rest elements)))) ;;El resto tienen que seguir el mismo esquema
               t)
              (t NIL))))))) ;;Nunca deberia llegar aqui

;;
;; EJEMPLOS:
;;
(clause-p '(v))             ; T
(clause-p '(v p))           ; T
(clause-p '(v (~ r)))       ; T
(clause-p '(v p q (~ r) s)) ; T
(clause-p NIL)                    ; NIL
(clause-p 'p)                     ; NIL
(clause-p '(~ p))                 ; NIL
(clause-p NIL)                    ; NIL
(clause-p '(p))                   ; NIL
(clause-p '((~ p)))               ; NIL
(clause-p '(^ a b q (~ r) s))     ; NIL
(clause-p '(v (^ a b) q (~ r) s)) ; NIL
(clause-p '(~ (v p q)))           ; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 1.7
;; Predicado para determinar si una FBF esta en FNC  
;;
;; RECIBE   : FFB en formato prefijo 
;; EVALUA A : T si FBF esta en FNC con conectores, 
;;            NIL en caso contrario. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun cnf-p (wff)
  (when (and (wff-prefix-p wff) (listp wff) (not (null wff)))
    (let ((connector (first wff)))
      (when (eql connector +and+)
        (let ((elements (rest wff)))
        (cond ((null elements) ;;No hay más elementos, es cnf por convencion
               t)
              ((and (clause-p (first elements)) ;;Comprobamos el primer elemento
                    (cnf-p (cons connector (rest elements)))) ;;El resto tienen que seguir el mismo esquema
               t)
              (t NIL)))))))
;;
;; EJEMPLOS:
;;
(cnf-p '(^ (v a  b c) (v q r) (v (~ r) s) (v a b))) ; T
(cnf-p '(^ (v a  b (~ c)) ))                        ; T
(cnf-p '(^ ))                                       ; T
(cnf-p '(^(v )))                                    ; T
(cnf-p '(~ p))                                      ; NIL
(cnf-p '(^ a b q (~ r) s))                          ; NIL
(cnf-p '(^ (v a b) q (v (~ r) s) a b))              ; NIL
(cnf-p '(v p q (~ r) s))                            ; NIL
(cnf-p '(^ (v a b) q (v (~ r) s) a b))              ; NIL
(cnf-p '(^ p))                                      ; NIL
(cnf-p '(v ))                                       ; NIL
(cnf-p NIL)                                         ; NIL
(cnf-p '((~ p)))                                    ; NIL
(cnf-p '(p))                                        ; NIL
(cnf-p '(^ (p)))                                    ; NIL
(cnf-p '((p)))                                      ; NIL
(cnf-p '(^ a b q (r) s))                            ; NIL
(cnf-p '(^ (v a  (v b c)) (v q r) (v (~ r) s) a b)) ; NIL
(cnf-p '(^ (v a (^ b c)) (^ q r) (v (~ r) s) a b))  ; NIL
(cnf-p '(~ (v p q)))                                ; NIL
(cnf-p '(v p q (r) s))                              ; NIL 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.2.1: Incluya comentarios en el codigo adjunto
;;
;; Dada una FBF, evalua a una FBF equivalente 
;; que no contiene el connector <=>
;;
;; RECIBE   : FBF en formato prefijo 
;; EVALUA A : FBF equivalente en formato prefijo 
;;            sin connector <=>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun eliminate-biconditional (wff)
  (if (or (null wff) (literal-p wff)) ;;En caso de que sea una lista vacía o un literal:
      wff                             ;; no tiene ningun bicondicional, por lo que no hace falta eliminar nada
    (let ((connector (first wff)))
      (if (eq connector +bicond+) ;;Si el conector es una bicondicional:
          (let ((wff1 (eliminate-biconditional (second wff)))  ;;Eliminamos la bicondicional de las dos 
                (wff2 (eliminate-biconditional (third  wff)))) ;;FBF de la bicondicional
            (list +and+ ;; Creamos una lista de la forma (^(w1 -> w2) (w2 -> w1))
                  (list +cond+ wff1 wff2)
                  (list +cond+ wff2 wff1)))
        (cons connector ;; Si no es una bicondicional tenemos que analizar el resto de FBF
              (mapcar #'eliminate-biconditional (rest wff)))))))

;;
;; EJEMPLOS:
;;
(eliminate-biconditional '(<=> p  (v q s p) ))
;;   (^ (=> P (v Q S P)) (=> (v Q S P) P))
(eliminate-biconditional '(<=>  (<=> p  q) (^ s (~ q))))
;;   (^ (=> (^ (=> P Q) (=> Q P)) (^ S (~ Q)))
;;      (=> (^ S (~ Q)) (^ (=> P Q) (=> Q P))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.2.2
;; Dada una FBF, que contiene conectores => evalua a
;; una FBF equivalente que no contiene el connector =>
;;
;; RECIBE   : wff en formato prefijo sin el connector <=> 
;; EVALUA A : wff equivalente en formato prefijo 
;;            sin el connector =>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun eliminate-conditional (wff)  
 (if (or (null wff) (literal-p wff))  ;;En caso de que sea una lista vacía o un literal:
      wff                             ;; no tiene ningun condicional, por lo que no hace falta eliminar nada
    (let ((connector (first wff)))
      (if (eq connector +cond+) ;;Si el conector es una condicional:
          (let ((wff1 (eliminate-conditional (second wff)))  ;;Eliminamos la condicional de las dos 
                (wff2 (eliminate-conditional (third  wff)))) ;;FBF de la condicional
            (list +or+ ;; Creamos una lista de la forma (^(w1 -> w2) (w2 -> w1))
                  (list +not+ wff1)
                  wff2))
        (cons connector ;; Si no es una condicional tenemos que analizar el resto de FBF
              (mapcar #'eliminate-conditional (rest wff)))))))       

;;
;; EJEMPLOS:
;;
(eliminate-conditional '(=> p q))                      ;;; (V (~ P) Q)
(eliminate-conditional '(=> p (v q s p)))              ;;; (V (~ P) (V Q S P))
(eliminate-conditional '(=> (=> (~ p) q) (^ s (~ q)))) ;;; (V (~ (V (~ (~ P)) Q)) (^ S (~ Q)))

(defun exchange-and-or (connector)
  (cond
   ((eq connector +and+) +or+)    
   ((eq connector +or+) +and+)
   (t connector)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.2.3
;; Dada una FBF, que no contiene los conectores <=>, => 
;; evalua a una FNF equivalente en la que la negacion  
;; aparece unicamente en literales negativos
;;
;; RECIBE   : FBF en formato prefijo sin conector <=>, => 
;; EVALUA A : FBF equivalente en formato prefijo en la que 
;;            la negacion  aparece unicamente en literales 
;;            negativos.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun reduce-scope-of-negation (wff)
  (if (or (null wff) (literal-p wff))  ;; En caso de que sea una lista vacía o un literal:
      wff                              ;; no tiene negaciones.
    (let ((connector (first wff)))
      (if (eq connector +not+) ;; Si el conector es una negación:
          (let ((connector-2 (first (second wff)))
                (args (rest (second wff))))
            (cond
             ((eq connector-2 +not+) ;; Doble negación
              (reduce-scope-of-negation (first args)))
             ((n-ary-connector-p connector-2) ;;De Morgan
              (cons (exchange-and-or connector-2) ;; Cambiamos signo y creamos una nueva lista
                     (mapcar #'(lambda (x)        ;; con todos los elementos con las negaciones reducidas
                                 (reduce-scope-of-negation (list +not+
                                                                 x)))
                       args)))
             (t (list +not+
                      (reduce-scope-of-negation (rest wff)))))) ;; Ultimo caso, revisamos argumentos
        (cons connector ;; Si no es una negacion tenemos que analizar el resto de FBF
              (mapcar #'reduce-scope-of-negation (rest wff)))))))

;;
;;  EJEMPLOS:
;;
(reduce-scope-of-negation '(~ (v p (~ q) r))) 
;;; (^ (~ P) Q (~ R))
(reduce-scope-of-negation '(~ (^ p (~ q) (v  r s (~ a))))) 
;;;  (V (~ P) Q (^ (~ R) (~ S) A))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.2.4: Comente el codigo adjunto 
;;
;; Dada una FBF, que no contiene los conectores <=>, => en la 
;; que la negacion aparece unicamente en literales negativos
;; evalua a una FNC equivalente en FNC con conectores ^, v  
;;
;; RECIBE   : FBF en formato prefijo sin conector <=>, =>, 
;;            en la que la negacion aparece unicamente 
;;            en literales negativos
;; EVALUA A : FBF equivalente en formato prefijo FNC 
;;            con conectores ^, v
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Función que combina un elt con todos los elementos de una lista
(defun combine-elt-lst (elt lst)
  (if (null lst)
      (list (list elt)) 
    (mapcar #'(lambda (x) (cons elt x)) lst))) ;; Crea un cons con los elementos correspondientes

;; Función que cambia entre formas normales
(defun exchange-NF (nf)
  (if (or (null nf) (literal-p nf)) ;; Si es NIL o un solo literal:
      nf                            ;; está en ambas formas normales
    (let ((connector (first nf)))
      (cons (exchange-and-or connector) ;; Cambiar conector (para cambiar de FN)
            (mapcar #'(lambda (x)       ;; Aplicar NF_AUX al resto y combinarlo con el conector
                          (cons connector x))
                (exchange-NF-aux (rest nf)))))))

;; Función auxiliar para exchange-NF-aux
(defun exchange-NF-aux (nf)
  (if (null nf) ;; Si es NIL, no lo procesamos.
      NIL       ;; COMENTARIO: pensamos que esto se podría simplificar con un unless
    (let ((lst (first nf)))
      (mapcan #'(lambda (x) 
                  (combine-elt-lst  ;; Combinamos cada elemento con la expresión
                   x                ;; obtenida de cambiar la FN del resto de elementos
                   (exchange-NF-aux (rest nf)))) 
        (if (literal-p lst) (list lst) (rest lst))))))

;; Simplicar un FN
(defun simplify (connector lst-wffs )
  (if (literal-p lst-wffs) ;; Si es un literal, no tenemos que simplificarlo
      lst-wffs                    
    (mapcan #'(lambda (x) ;; A todos los elementos
                (cond
                 ((literal-p x) (list x)) ;; Si es un literal, crear una lista con él
                 ((equal connector (first x)) ;; Si es un conector:
                  (mapcan ;; A todos los elementos aplicados al conector
                      #'(lambda (y) (simplify connector (list y))) ;; Simplificamos el elemento
                    (rest x))) ;; Por tanto devolvemos la lista sin el conector
                 (t (list x))))
      lst-wffs)))

;; Convierte una FBF a FNC 
(defun cnf (wff)
  (cond
   ((cnf-p wff) wff) ;; Si ya es cnf, no procesamos
   ((literal-p wff)  ;; Si es un literal lo cambiamos a (^(v a))
    (list +and+ (list +or+ wff)))
   ((let ((connector (first wff))) 
      (cond
       ((equal +and+ connector) ;; Si el conector es de tipo and
        (cons +and+ (simplify +and+ (mapcar #'cnf (rest wff))))) ;; Simplificamos el resto de elementos
       ((equal +or+ connector) ;; Si el conector es de tipo or
        (cnf (exchange-NF (cons +or+ (simplify +or+ (rest wff))))))))))) ;; Transformamos a fnc con exchange NF


(cnf 'a)

(cnf '(v (~ a) b c))
(print (cnf '(^ (v (~ a) b c) (~ e) (^ e f (~ g) h) (v m n) (^ r s q) (v u q) (^ x y))))
(print (cnf '(v (^ (~ a) b c) (~ e) (^ e f (~ g) h) (v m n) (^ r s q) (v u q) (^ x y))))
(print (cnf '(^ (v p  (~ q)) a (v k  r  (^ m  n)))))
(print (cnf '(v p  q  (^ r  m)  (^ n  a)  s )))
(exchange-NF '(v p  q  (^ r  m)  (^ n  a)  s ))
(cnf '(^ (v a b (^ y r s) (v k l)) c (~ d) (^ e f (v h i) (^ o p))))
(cnf '(^ (v a b (^ y r s)) c (~ d) (^ e f (v h i) (^ o p))))
(cnf '(^ (^ y r s (^ p q (v c d))) (v a b)))
(print (cnf '(^ (v (~ a) b c) (~ e) r s 
                (v e f (~ g) h) k (v m n) d)))
;;
(cnf '(^ (v p (~ q)) (v k r (^ m  n))))
(print  (cnf '(v (v p q) e f (^ r  m) n (^ a (~ b) c) (^ d s))))
(print (cnf '(^ (^ (~ y) (v r (^ s (~ x)) (^ (~ p) m (v c d))) (v (~ a) (~ b))) g)))
;;
;; EJEMPLOS:
;;
(cnf NIL)              ; NIL
(cnf 'a)               ; (^ (V A))
(cnf '(~ a))           ; (^ (V (~ A)))
(cnf '(V (~ P) (~ P))) ; (^ (V (~ P) (~ P)))
(cnf '(V A))           ; (^ (V A))
(cnf '(^ (v p (~ q)) (v k r (^ m  n))))
;;;   (^ (V P (~ Q)) (V K R M) (V K R N))
(print  (cnf '(v (v p q) e f (^ r  m) n (^ a (~ b) c) (^ d s))))
;;; (^ (V P Q E F R N A D)      (V P Q E F R N A S)
;;;    (V P Q E F R N (~ B) D)  (V P Q E F R N (~ B) S)
;;;    (V P Q E F R N C D)      (V P Q E F R N C S) 
;;;    (V P Q E F M N A D)      (V P Q E F M N A S) 
;;;    (V P Q E F M N (~ B) D)  (V P Q E F M N (~ B) S) 
;;;    (V P Q E F M N C D)      (V P Q E F M N C S))
;;;
(print 
 (cnf '(^ (^ (~ y) (v r (^ s (~ x)) 
                      (^ (~ p) m (v c d)))(v (~ a) (~ b))) g)))
;;;(^ (V (~ Y)) (V R S (~ P)) (V R S M) 
;;;   (V R S C D) (V R (~ X) (~ P)) 
;;;   (V R (~ X) M) (V R (~ X) C D)
;;;   (V (~ A) (~ B)) (V G))  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.2.5:
;;
;; Dada una FBF en  FNC
;; evalua a lista de listas sin conectores
;; que representa una conjuncion de disyunciones de literales
;;
;; RECIBE   : FBF en FNC con conectores ^, v
;; EVALUA A : FBF en FNC (con conectores ^, v eliminados)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun eliminate-rec(cnf)
  (mapcar #'(lambda (x)
            (if (literal-p x)
              x
              (eliminate-rec x)))
    (rest cnf)))

(defun eliminate-connectors (cnf)
  (when (cnf-p cnf)
    (eliminate-rec cnf)))

(eliminate-connectors 'nil) ;; nil
(eliminate-connectors (cnf '(^ (v p  (~ q))  (v k  r  (^ m  n))))) 
(eliminate-connectors
 (cnf '(^ (v (~ a) b c) (~ e) (^ e f (~ g) h) (v m n) (^ r s q) (v u q) (^ x y))))

(eliminate-connectors (cnf '(v p  q  (^ r  m)  (^ n  q)  s )))
(eliminate-connectors (print (cnf '(^ (v p  (~ q)) (~ a) (v k  r  (^ m  n))))))

(eliminate-connectors '(^))
(eliminate-connectors '(^ (v p (~ q)) (v) (v k r)))
(eliminate-connectors '(^ (v a b)))

;;   EJEMPLOS:
;;

(eliminate-connectors '(^ (v p (~ q)) (v k r)))
;; ((P (~ Q)) (K R))
(eliminate-connectors '(^ (v p (~ q)) (v q (~ a)) (v s e f) (v b)))
;; ((P (~ Q)) (Q (~ A)) (S E F) (B))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.2.6
;; Dada una FBF en formato infijo
;; evalua a lista de listas sin conectores
;; que representa la FNC equivalente
;;
;; RECIBE   : FBF 
;; EVALUA A : FBF en FNC (con conectores ^, v eliminados)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun wff-infix-to-cnf (wff)
  (eliminate-connectors            ;; Eliminamos conectores
   (cnf                            ;; De una cnf
    (reduce-scope-of-negation      ;; A la que hemos reducido las negaciones
     (eliminate-conditional        ;; Eliminado las condicionales
      (eliminate-biconditional     ;; Y bicondicionales
       (infix-to-prefix wff))))))) ;; De la fbf en formato prefijo

;;
;; EJEMPLOS:
;; 
(wff-infix-to-cnf 'a)
(wff-infix-to-cnf '(~ a))
(wff-infix-to-cnf  '( (~ p) v q v (~ r) v (~ s)))
(wff-infix-to-cnf  '((p v (a => (b ^ (~ c) ^ d))) ^ ((p <=> (~ q)) ^ p) ^ e))
;; ((P (~ A) B) (P (~ A) (~ C)) (P (~ A) D) ((~ P) (~ Q)) (Q P) (P) (E))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.1
;; eliminacion de literales repetidos una clausula 
;; 
;; RECIBE   : K - clausula (lista de literales, disyuncion implicita)
;; EVALUA A : clausula equivalente sin literales repetidos 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun eliminate-repeated-literals (k)
  (remove-duplicates k :test #'equal))

;;
;; EJEMPLO:
;;
(eliminate-repeated-literals '(a b (~ c) (~ a) a c (~ c) c a))
;;;   (B (~ A) (~ C) C A)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.2
;; eliminacion de clausulas repetidas en una FNC 
;; 
;; RECIBE   : cnf - FBF en FNC (lista de clausulas, conjuncion implicita)
;; EVALUA A : FNC equivalente sin clausulas repetidas 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun equal-clauses (a b) ;; Comprueba si dos clausulas son iguales
  (and (subsetp a b :test #'equal)   ;; a contenido en b
       (subsetp b a :test #'equal))) ;; b contenido en a

(defun eliminate-repeated-clauses (cnf) 
  (remove-duplicates 
   (mapcar #'eliminate-repeated-literals 
     cnf) 
   :test #'equal-clauses))

;;
;; EJEMPLO:
;;
(eliminate-repeated-clauses '(((~ a) c) (c (~ a)) ((~ a) (~ a) b c b) (a a b) (c (~ a) b  b) (a b)))
;;; ((C (~ A)) (C (~ A) B) (A B))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.3
;; Predicado que determina si una clausula subsume otra
;;
;; RECIBE   : K1, K2 clausulas
;; EVALUA a : (list K1) si K1 subsume a K2
;;            NIL en caso contrario
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun subsume (K1 K2)
  (when (subsetp K1 K2 :test #'equal)
    (list k1)))
  
;;
;;  EJEMPLOS:
;;
(subsume '(a) '(a b (~ c)))
;; ((a))
(subsume NIL '(a b (~ c)))
;; (NIL)
(subsume '(a b (~ c)) '(a) )
;; NIL
(subsume '( b (~ c)) '(a b (~ c)) )
;; (( b (~ c)))
(subsume '(a b (~ c)) '( b (~ c)))
;; NIL
(subsume '(a b (~ c)) '(d  b (~ c)))
;; nil
(subsume '(a b (~ c)) '((~ a) b (~ c) a))
;; ((A B (~ C)))
(subsume '((~ a) b (~ c) a) '(a b (~ c)) )
;; nil

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.4
;; eliminacion de clausulas subsumidas en una FNC 
;; 
;; RECIBE   : cnf (FBF en FNC)
;; EVALUA A : FBF en FNC equivalente a cnf sin clausulas subsumidas 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun is-subsumed (elt lst)
  (cond
      ((null lst) ;; Caso base, no ha sido subsumido
          NIL)
      ((subsume (first lst) elt) ;; Si es subsumido, devuelve True
          T)
      (T
          (is-subsumed elt (rest lst))))) ;; Recursion


(defun eliminate-subsumed-clauses-rec (processed new)
  (if (null new)
      processed
    (let ((f (first new)) (r (rest new)))
      (if (or (is-subsumed f processed) ;; Si f es subsumido por alguna clausula, no se añade a processed
              (is-subsumed f r))
          (eliminate-subsumed-clauses-rec processed r)
        (eliminate-subsumed-clauses-rec (cons f processed) r))))) ;; Si no ha sido subsumido, se añade a processed
      

(defun eliminate-subsumed-clauses (cnf)
  (eliminate-subsumed-clauses-rec nil cnf))

;;
;;  EJEMPLOS:
;;
(eliminate-subsumed-clauses 
 '((a b c) (b c) (a (~ c) b) ((~ a) b) (a b (~ a)) (c b a)))
;;; ((A (~ C) B) ((~ A) B) (B C)) ;; el orden no es importante
(eliminate-subsumed-clauses
 '((a b c) (b c) (a b c) (a (~ c) b) (b)  ((~ a) b) (a b (~ a)) (c b a)))
;;; ((B))
(eliminate-subsumed-clauses
 '((a b c) (b c) (a (~ c) b) ((~ a))  ((~ a) b) (a b (~ a)) (c b a)))
;;; ((A (~ C) B) ((~ A)) (B C))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.5
;; Predicado que determina si una clausula es tautologia
;;
;; RECIBE   : K (clausula)
;; EVALUA a : T si K es tautologia
;;            NIL en caso contrario
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun change-sign (K)
  (if (positive-literal-p K) ;; Negación del primer elemento
      (list +not+ K)
    (second K)))

(defun tautology-p (K)
  (unless (null K)
    (let* ((el (first K))
           (nel (change-sign el)))
      (if (member nel K :test #'equal)
          T
        (tautology-p (rest K))))))

;;
;;  EJEMPLOS:
;;
(tautology-p '((~ B) A C (~ A) D)) ;;; T 
(tautology-p '((~ B) A C D))       ;;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.6
;; eliminacion de clausulas en una FBF en FNC que son tautologia
;;
;; RECIBE   : cnf - FBF en FNC
;; EVALUA A : FBF en FNC equivalente a cnf sin tautologias 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun eliminate-tautologies (cnf) 
  (remove-if #'tautology-p cnf))

;;
;;  EJEMPLOS:
;;
(eliminate-tautologies 
 '(((~ b) a) (a (~ a) b c) ( a (~ b)) (s d (~ s) (~ s)) (a)))
;; (((~ B) A) (A (~ B)) (A))

(eliminate-tautologies '((a (~ a) b c)))
;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.3.7
;; simplifica FBF en FNC 
;;        * elimina literales repetidos en cada una de las clausulas 
;;        * elimina clausulas repetidas
;;        * elimina tautologias
;;        * elimina clausulass subsumidas
;;  
;; RECIBE   : cnf  FBF en FNC
;; EVALUA A : FNC equivalente sin clausulas repetidas, 
;;            sin literales repetidos en las clausulas
;;            y sin clausulas subsumidas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun simplify-cnf (cnf) 
  (eliminate-subsumed-clauses 
   (eliminate-tautologies 
    (eliminate-repeated-clauses 
     (mapcar #'eliminate-repeated-literals cnf)))))

;;
;;  EJEMPLOS:
;;
(simplify-cnf '((a a) (b) (a) ((~ b)) ((~ b)) (a b c a)  (s s d) (b b c a b)))
;; ((B) ((~ B)) (S D) (A)) ;; en cualquier orden


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.4.1
;; Construye el conjunto de clausulas lambda-neutras para una FNC 
;;
;; RECIBE   : cnf    - FBF en FBF simplificada
;;            lambda - literal positivo
;; EVALUA A : cnf_lambda^(0) subconjunto de clausulas de cnf  
;;            que no contienen el literal lambda ni ~lambda   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun extract-neutral-clauses (lambda cnf) 
  (let ((nlambda (change-sign lambda)))
    (remove-if #'(lambda (x) (or (member lambda x :test #'equal) 
                                 (member nlambda x :test #'equal)))
               cnf))) ;;Si lambda y nlambda estan en una clausla, la quitamos

;;
;;  EJEMPLOS:
;;
(extract-neutral-clauses 'p
                           '((p (~ q) r) (p q) (r (~ s) q) (a b p) (a (~ p) c) ((~ r) s)))
;; ((R (~ S) Q) ((~ R) S))


(extract-neutral-clauses 'r NIL)
;; NIL

(extract-neutral-clauses 'r '(NIL))
;; (NIL)

(extract-neutral-clauses 'r
                           '((p (~ q) r) (p q) (r (~ s) q) (a b p) (a (~ p) c) ((~ r) s)))
;; ((P Q) (A B P) (A (~ P) C))

(extract-neutral-clauses 'p
                           '((p (~ q) r) (p q) (r (~ s) p q) (a b p) (a (~ p) c) ((~ r) p s)))
;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.4.2
;; Construye el conjunto de clausulas lambda-positivas para una FNC
;;
;; RECIBE   : cnf    - FBF en FNC simplificada
;;            lambda - literal positivo
;; EVALUA A : cnf_lambda^(+) subconjunto de clausulas de cnf 
;;            que contienen el literal lambda  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun extract-positive-clauses (lambda cnf) 
    (remove-if #'(lambda (x) (not (member lambda x :test #'equal)))
               cnf)) ;;Si lambda no esta en una clausla, la quitamos
;;
;;  EJEMPLOS:
;;
(extract-positive-clauses 'p
                             '((p (~ q) r) (p q) (r (~ s) q) (a b p) (a (~ p) c) ((~ r) s)))

;; ((P (~ Q) R) (P Q) (A B P))


(extract-positive-clauses 'r NIL)
;; NIL
(extract-positive-clauses 'r '(NIL))
;; NIL
(extract-positive-clauses 'r
                             '((p (~ q) r) (p q) (r (~ s) q) (a b p) (a (~ p) c) ((~ r) s)))
;; ((P (~ Q) R) (R (~ S) Q))
(extract-positive-clauses 'p
                             '(((~ p) (~ q) r) ((~ p) q) (r (~ s) (~ p) q) (a b (~ p)) ((~ r) (~ p) s)))
;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.4.3
;; Construye el conjunto de clausulas lambda-negativas para una FNC 
;;
;; RECIBE   : cnf    - FBF en FNC simplificada
;;            lambda - literal positivo 
;; EVALUA A : cnf_lambda^(-) subconjunto de clausulas de cnf  
;;            que contienen el literal ~lambda  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun extract-negative-clauses (lambda cnf) 
  (let ((nlambda (change-sign lambda)))
    (remove-if #'(lambda (x) (not (member nlambda x :test #'equal)))
               cnf))) ;;Si nlambda no esta en una clausla, la quitamos

;;
;;  EJEMPLOS:
;;
(extract-negative-clauses 'p
                             '((p (~ q) r) (p q) (r (~ s) q) (a b p) (a (~ p) c) ((~ r) s)))
;; ((A (~ P) C))

(extract-negative-clauses 'r NIL)
;; NIL
(extract-negative-clauses 'r '(NIL))
;; NIL
(extract-negative-clauses 'r
                             '((p (~ q) r) (p q) (r (~ s) q) (a b p) (a (~ p) c) ((~ r) s)))
;; (((~ R) S))
(extract-negative-clauses 'p
                             '(( p (~ q) r) ( p q) (r (~ s) p q) (a b p) ((~ r) p s)))
;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.4.4
;; resolvente de dos clausulas
;;
;; RECIBE   : lambda      - literal positivo
;;            K1, K2      - clausulas simplificadas
;; EVALUA A : res_lambda(K1,K2) 
;;                        - lista que contiene la 
;;                          clausula que resulta de aplicar resolucion 
;;                          sobre K1 y K2, con los literales repetidos 
;;                          eliminados
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun resolve-on (lambda K1 K2) 
  (let ((nlambda (change-sign lambda)))
  (cond ((member lambda K1 :test #'equal)
         (when (member nlambda K2 :test #'equal) 
           (list (union (remove lambda K1 :test #'equal)
                  (remove nlambda K2 :test #'equal)
                  :test #'equal))))
        ((member nlambda K1 :test #'equal)
         (when (member lambda K2 :test #'equal)
           (list (union (remove nlambda K1 :test #'equal) 
                  (remove lambda K2 :test #'equal)
                  :test #'equal))))
        (t NIL))))

;;
;;  EJEMPLOS:
;;
(resolve-on 'p '(a b (~ c) p) '((~ p) b a q r s))
;; (((~ C) B A Q R S))

(resolve-on 'p '(a b (~ c) (~ p)) '( p b a q r s))
;; (((~ C) B A Q R S))

(resolve-on 'p '(p) '((~ p)))
;; (NIL)


(resolve-on 'p NIL '(p b a q r s))
;; NIL

(resolve-on 'p NIL NIL)
;; NIL

(resolve-on 'p '(a b (~ c) (~ p)) '(p b a q r s))
;; (((~ C) B A Q R S))

(resolve-on 'p '(a b (~ c)) '(p b a q r s))
;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.4.5
;; Construye el conjunto de clausulas RES para una FNC 
;;
;; RECIBE   : lambda - literal positivo
;;            cnf    - FBF en FNC simplificada
;;            
;; EVALUA A : RES_lambda(cnf) con las clauses repetidas eliminadas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun resolve-on-list (lambda K1 lst)
  (mapcar #'(lambda (x) (first (resolve-on lambda K1 x)))
    lst))

(defun build-RES (lambda cnf)
  (let ((nc (extract-negative-clauses lambda cnf))
        (pc (extract-positive-clauses lambda cnf)))
    (eliminate-repeated-clauses 
     (union (extract-neutral-clauses lambda cnf)
            (mapcan #'(lambda (x) (resolve-on-list lambda x nc))
              pc)
            :test #'equal-clauses))))
;;
;;  EJEMPLOS:
;;
(build-RES 'p NIL)
;; NIL
(build-RES 'P '((A  (~ P) B) (A P) (A B)));; ((A B))
(build-RES 'P '((B  (~ P) A) (A P) (A B)));; ((B A))

(build-RES 'p '(NIL))
;; (NIL)

(build-RES 'p '((p) ((~ p))))
;; (NIL)

(build-RES 'q '((p q) ((~ p) q) (a b q) (p (~ q)) ((~ p) (~ q))))
;; ((P) ((~ P) P) ((~ P)) (B A P) (B A (~ P)))

(build-RES 'p '((p q) (c q) (a b q) (p (~ q)) (p (~ q))))
;; ((A B Q) (C Q))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.5
;; Comprueba si una FNC es SAT calculando RES para todos los
;; atomos en la FNC 
;;
;; RECIBE   : cnf - FBF en FNC simplificada
;; EVALUA A :	T  si cnf es SAT
;;                NIL  si cnf es UNSAT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun get-literals-aux (K1 els) ;;Devuelve una lista con los literales no repetidos de una clausula
  (if (null K1)
      els
    (if (or (member (first K1) ;;Si esta en positivo
                    els 
                    :test #'equal)
            (member (change-sign (first K1)) ;;Si esta en negativo
                    els
                    :test #'equal))
        (get-literals-aux (rest K1) ;;No introducir el literal
                          els)
      (get-literals-aux (rest K1) ;;Introducir el literal
                        (cons (first K1) els)))))

(defun get-literals (cnf els) ;;Devuelve una lista con los literales no repetidos de una fnc
  (if (null cnf) 
      els
    (get-literals (rest cnf) (get-literals-aux (first cnf) els))))

(defun  RES-SAT-p-aux (cnf literals) 
  (cond ((null cnf) t) ;;Tautología
        ((null (first cnf)) NIL) ;;Contradicción
        (t (RES-SAT-p-aux (simplify-cnf 
                           (build-RES 
                            (first literals) cnf))
                          (rest literals))))) ;;Continuar recursion

(defun RES-SAT-p (cnf)
  (RES-SAT-p-aux cnf (get-literals cnf nil)))
         
         
;;
;;  EJEMPLOS:
;;
;;
;; SAT Examples
;;
(RES-SAT-p nil)  ;;; T
(RES-SAT-p '((p) ((~ q)))) ;;; T 
(RES-SAT-p
 '((a b d) ((~ p) q) ((~ c) a b) ((~ b) (~ p) d) (c d (~ a)))) ;;; T 
(RES-SAT-p
 '(((~ p) (~ q) (~ r)) (q r) ((~ q) p) ((~ q)) ((~ p) (~ q) r))) ;;;T
;;
;; UNSAT Examples
;;
(RES-SAT-p '(nil))         ;;; NIL
(RES-SAT-p '((S) nil))     ;;; NIL 
(RES-SAT-p '((p) ((~ p)))) ;;; NIL
(RES-SAT-p
 '(((~ p) (~ q) (~ r)) (q r) ((~ q) p) (p) (q) ((~ r)) ((~ p) (~ q) r))) ;;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4.6:
;; Resolucion basada en RES-SAT-p
;;
;; RECIBE   : wff - FBF en formato infijo 
;;            w   - FBF en formato infijo 
;;                               
;; EVALUA A : T   si w es consecuencia logica de wff
;;            NIL en caso de que no sea consecuencia logica.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun logical-consequence-RES-SAT-p (wff w)
  (not (RES-SAT-p (union (wff-infix-to-cnf wff) 
         (wff-infix-to-cnf (change-sign w))))))

;;
;;  EJEMPLOS:
;;
(logical-consequence-RES-SAT-p NIL 'a) ;;; NIL
(logical-consequence-RES-SAT-p NIL NIL) ;;; NIL
(logical-consequence-RES-SAT-p '(q ^ (~ q)) 'a) ;;; T 
(logical-consequence-RES-SAT-p '(q ^ (~ q)) '(~ a)) ;;; T 

(logical-consequence-RES-SAT-p '((p => (~ p)) ^ p) 'q)
;; T

(logical-consequence-RES-SAT-p '((p => (~ p)) ^ p) '(~ q))
;; T

(logical-consequence-RES-SAT-p '((p => q) ^ p) 'q)
;; T

(logical-consequence-RES-SAT-p '((p => q) ^ p) '(~q))
;; NIL

(logical-consequence-RES-SAT-p 
 '(((~ p) => q) ^ (p => (a v (~ b))) ^ (p => ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
 '(~ a))
;; T

(logical-consequence-RES-SAT-p 
 '(((~ p) => q) ^ (p => (a v (~ b))) ^ (p => ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
 'a)
;; T

(logical-consequence-RES-SAT-p 
 '(((~ p) => q) ^ (p => ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
 'a)
;; NIL

(logical-consequence-RES-SAT-p 
 '(((~ p) => q) ^ (p => ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
 '(~ a))
;; T

(logical-consequence-RES-SAT-p 
 '(((~ p) => q) ^ (p <=> ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
 'q)
;; NIL

(logical-consequence-RES-SAT-p 
 '(((~ p) => q) ^ (p <=> ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
 '(~ q))
;; NIL

(or 
 (logical-consequence-RES-SAT-p '((p => q) ^ p) '(~q))      ;; NIL
 (logical-consequence-RES-SAT-p 
  '(((~ p) => q) ^ (p => ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
  'a) ;; NIL
 (logical-consequence-RES-SAT-p 
  '(((~ p) => q) ^ (p <=> ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
  'q) ;; NIL
 (logical-consequence-RES-SAT-p 
  '(((~ p) => q) ^ (p <=> ((~ a) ^ b)) ^ ( (~ p) => (r  ^ (~ q)))) 
  '(~ q)))

