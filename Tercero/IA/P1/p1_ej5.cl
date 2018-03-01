;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5.2
;; Pseudocodigo de un BFS
;;
;; RECIBE : META, COLA (cola con los caminos hasta los nodos del nivel actual), GRAFO
;;
;; EVALUA A : Un camino hasta el nodo objetivo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;function bfs (meta, cola, grafo):
;;  if(cola == null):
;;    return null ;;No se ha encontrado la meta
;;  
;;  else:
;;    camino_actual = first(cola) ;; Camino al nodo actual
;;    nodo = first(camino_actual) ;; Nodo actual
;;
;;    if(nodo == meta):
;;      return invertir(camino_actual) ;; Invertimos el camino, ya que lo hemos creado al reves
;;    
;;    else:
;;      for hijo in nodo.hijos():
;;        cola.remove()
;;        cola.append(camino_a_(hijo)) ;; Para cada hijo, sacamos el camino recorrido hasta llegar a el
                                     ;; y lo introducimos en la cola de caminos.
                                     ;; Es importante que el hijo se inserte al principio del camino,
                                     ;; para que sea el nodo que se expanda en la siguiente iteracion.
                                     ;; Por tanto, el camino se ira guardando al reves.
;;        return bfs(meta, cola, grafo)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5.3 y 5.4
;; Estudia y comenta la siguiente implementación del 
;; del algoritmo BFS
;;
;; RECIBE   : END (objetivo), QUEUE (cola de nodos a explorar)
;;            NET (grafo a explorar)
;; EVALUA A : Una lista con el camino encontrado hasta el objetivo
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bfs (end queue net)
  (if (null queue) '() ;; Si la cola esta vacia, se ha terminado
    (let* ((path (first queue))
           (node (first path)))
      (if (eql node end) ;; Test objetivo
          (reverse path) ;; Le da la vuelta al path para que
        (bfs end         ;; salga en orden el camino
             (append (rest queue) ;; Al hacer el append con el rest de la cola, es como si hiciesemos un remove()
                     (new-paths path node net)) ;; Explora el nodo, y mete los caminos descubertos al final de la cola
             net)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Funcion que descubre los hijos de un nodo, y devuelve una lista con
;; los nodos que se han descubierto hasta llegar al hijo. Estos caminos estan invertidos,
;; ya que en cada llamada se inserta el hijo en ultimo lugar
;;
;; REBIBE : PATH (lista de adyacencia), NODE (nodo a explorar), NET (grafo)
;; EVALUA A: Una lista con un camino por cada hijo de node
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun new-paths (path node net)
  (mapcar #'(lambda(n) ;; La funcion lambda inserta los hijos de node
              (cons n path)) ;; en los caminos
    (rest (assoc node net)))) 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5.5 y 5.6
;; Explica por qué esta función resuelve el problema de encontrar
;; el camino más corto entre dos nodos del grafo
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun shortest-path (start end net)
  (bfs end (list (list start)) net))

;; Para que funcione correctamente la función bfs, es necesario que
;; la entrada queue sea una lista de listas. Esto es porque la cola 
;; no va a ser una lista de nodos, sino una lista de caminos hasta el nodo.
;; BFS va a extraer el primer camino (la primera sublista) y, de ese camino,
;; extraerá el primer nodo (que es el nodo que querremos expandir).
;; A su vez, la función new-paths es la encargada de "descubrir" los hijos de
;; un nodo. Para ello, va anexando cada hijo al camino que recibe como argumento,
;; y terminará devolviendo una lista de caminos hasta cada nuevo hijo.
;; BFS hará un append de la lista con los nuevos caminos a queue, que es la cola
;; de la búsqueda en anchura. 
;; Como BFS extrae elementos del principio de la cola, y los que se añaden lo hacen al final,
;; los primeros nodos en ser descubiertos serán los que estén en niveles superiores y, por tanto,
;; la primera solución que se encuentre será la que está más arriba (la más corta)

(shortest-path 'a 'f '((a d) (b d f) (c e) (d f) (e b f) (f)))

;; Se ha realizado un trace de la llamada anterior para entender mejor el funcionamiento del algoritmo

;  0[5]: (SHORTEST-PATH A F
;                       ((A D)
;                        (B D F)
;                        (C E)
;                        (D F)
;                        (E B F)
;                        (F)))
;    1[5]: (BFS
;           F
;           ((A))                                     ;; Se llama a bfs con una lista de listas del nodo raíz
;           ((A D) (B D F) (C E) (D F) (E B F) (F)))
;      2[5]: (NEW-PATHS
;             (A)
;             A                                       ;; Se llama a new-paths con el camino actual (A)
;             ((A D)                                  ;; Y con el nodo a explorar A
;              (B D F)
;              (C E)
;              (D F)
;              (E B F)
;              (F)))
;      2[5]: returned ((D A))                         ;; Se devuelve una lista con el camino (invertido) 
;      2[5]: (BFS                                     ;; hasta cada hijo de A ((D A)=
;             F
;             ((D A))                                 ;; Se llama a BFS, con una cola de caminos hasta los
;             ((A D)                                  ;; nodos-hoja
;              (B D F)
;              (C E)
;              (D F)
;              (E B F)
;              (F)))
;        3[5]: (NEW-PATHS
;               (D A)
;               D                                     ;; Se expande D
;               ((A D)
;                (B D F)
;                (C E)
;                (D F)
;                (E B F)
;                (F)))
;        3[5]: returned ((F D A))                     ;; Se devuelve el camino hasta el único hijo de D
;        3[5]: (BFS
;               F
;               ((F D A))
;               ((A D)
;                (B D F)
;                (C E)
;                (D F)
;                (E B F)
;                (F)))
;        3[5]: returned (A D F)                       ;; Como ya se ha encontrado la meta, se devuelve el camino
;      2[5]: returned (A D F)                         ;; ordenado
;    1[5]: returned (A D F)
;  0[5]: returned (A D F)
; (A D F)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5.7
;; Utiliza el código anterior para encontrar el camino más corto entre los nodos F y C
;; en el siguiente grafo no dirigido. ¿Cuál es la llamada concreta que tienes que hacer?
;; ¿Qué resultado obtienes con dicha llamada?
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Para hacer la llamada correctamente, debemos escribir el grafo en forma de lista
;; Como el grafo es no dirigido, habrá bucles.
;; Para no hacerlo demasiado largo, hemos decidido usar un setf para guardar nuestro grafo
(setf net '((a b c d e) (b a d e f) (c a d) (d a b g h) (e a b g h) (f b h) (g c d e h) (h d e f g)))
(shortest-path 'f 'c net)
;; El resultado obtenido es (f b a c)


;; Claramente, el resultado va a depender del orden en el que insertemos las aristas en el grafo
;; Por ejemplo, la siguiente llamada devolverá un camino diferente
(setf net '((a b c d e) (h d e f g) (g c d e h) (b a d e f) (c a d) (d a b g h) (e a b g h) (f h b)))
(shortest-path 'f 'c net)
;; En este caso, el camino encontrado sería (f h g c)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5.8
;; El código anterior falla (entra en una recursión infinita) cuando hay ciclos en el
;; grafo y el problema de búsqueda no tiene solución. Ilustra con un ejemplo este caso
;; problemático y modifica el código para corregir este problema:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; La siguiente llamada va a hacer que bfs entre en un bucle infinito
(setf infinite '((a b c) (b a c) (c a b)))
(shortest-path-improved 'a 'e infinite)


(defun bfs-improved (end queue net)
  (if (null queue) '() ;; Si la cola esta vacia, se ha terminado
    (let* ((path (first queue))
           (node (first path)))
      (if (eql node end) ;; Test objetivo
          (reverse path) ;; Le da la vuelta al path para que
        (bfs-improved end         ;; salga en orden el camino
             (if (member node (rest path)) ;; comprobamos que no se haya pasado ya por ese nodo
                (rest queue)
                (append (rest queue) ;; Al hacer el append con el rest de la cola, es como si hiciesemos un remove()
                     (new-paths-improved path node net))) ;; Explora el nodo, y mete los caminos descubertos al final de la cola
             net)))))

(defun new-paths-improved (path node net)
  (mapcar #'(lambda(n) ;; La funcion lambda inserta los hijos de node
              (cons n path)) ;; en los caminos
    (rest (assoc node net)))) 

(defun shortest-path-improved (start end net)
  (bfs-improved end (list (list start)) net))


;; Usando la misma llamada que antes, podemos ver que se devuelve nil
;; El unico cambio que hemos hecho ha sido el de comprobar si el nodo a 
;; expandir esta en el camino recorrido. En caso afirmativo, si lo volvemos
;; a descubrir estariamos entrando en un bucle.