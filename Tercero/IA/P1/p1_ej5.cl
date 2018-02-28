;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5.2
;; Pseudocodigo de un BFS
;;
;; RECIBE : META, COLA (cola con los caminos hasta los nodos del nivel actual), GRAFO
;;
;; EVALUA A : Un camino hasta el nodo objetivo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function bfs (meta, cola, grafo):
  if(cola == null):
    return null ;;No se ha encontrado la meta
  
  else:
    camino_actual = first(cola) ;; Camino al nodo actual
    nodo = first(camino_actual) ;; Nodo actual

    if(nodo == meta):
      return invertir(camino_actual) ;; Invertimos el camino, ya que lo hemos creado al reves
    
    else:
      for hijo in nodo.hijos():
        cola.remove()
        cola.append(camino_a_(hijo)) ;; Para cada hijo, sacamos el camino recorrido hasta llegar a el
                                     ;; y lo introducimos en la cola de caminos.
                                     ;; Es importante que el hijo se inserte al principio del camino,
                                     ;; para que sea el nodo que se expanda en la siguiente iteracion.
                                     ;; Por tanto, el camino se ira guardando al reves.
        return bfs(meta, cola, grafo)



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


(setf map '((a d) (b d f) (c e) (d f) (e b f) (f)))

(bfs 'd '((c)) map)