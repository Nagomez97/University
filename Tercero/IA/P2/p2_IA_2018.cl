;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Lab assignment 2: Search
;;    LAB GROUP: 2302
;;    Couple:  07
;;    Author 1: José Ignacio Gómez García
;;    Author 2: Óscar Gómez Borzdynski
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Problem definition
;;
(defstruct problem
  states               ; List of states
  initial-state        ; Initial state
  f-goal-test          ; reference to a function that determines whether 
                       ; a state fulfills the goal 
  f-h                  ; reference to a function that evaluates to the 
                       ; value of the heuristic of a state
  f-search-state-equal ; reference to a predicate that determines whether
                       ; two nodes are equal, in terms of their search state 
  operators)           ; list of operators (references to functions) to generate succesors
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Node in search tree
;;
(defstruct node 
  state           ; state label
  parent          ; parent node
  action          ; action that generated the current node from its parent
  (depth 0)       ; depth in the search tree
  (g 0)           ; cost of the path from the initial state to this node
  (h 0)           ; value of the heurstic
  (f 0))          ; g + h 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Actions 
;;
(defstruct action
  name              ; Name of the operator that generated the action
  origin            ; State on which the action is applied
  final             ; State that results from the application of the action
  cost )            ; Cost of the action
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Search strategies 
;;
(defstruct strategy
  name              ; name of the search strategy
  node-compare-p)   ; boolean comparison
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    END: Define structures
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    BEGIN: Define galaxy
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *planets* '(Avalon Davion Katril Kentares Mallory Proserpina Sirtis))

(defparameter *white-holes*  
  '((Avalon Mallory 6.4) (Avalon Proserpina 8.6) 
    (Mallory Katril 10) (Mallory Proserpina 15)
    (Katril Mallory 10) (Katril Davion 9)
    (Davion Proserpina 5) (Davion Sirtis 6)
    (Sirtis Davion 6) (Sirtis Proserpina 12)
    (Proserpina Sirtis 12) (Proserpina Davion 5) (Proserpina Mallory 15) (Proserpina Avalon 8.6)
    (Kentares Proserpina 7) (Kentares Katril 10) (Kentares Avalon 3)))

(defparameter *worm-holes*  
  '((Avalon Kentares 4) (Avalon Mallory 9)
    (Davion Katril 5) (Davion Sirtis 8)  
    (Kentares Avalon 4) (Kentares Proserpina 12)
    (Mallory Avalon 9) (Mallory Katril 5) (Mallory Proserpina 11) 
    (Katril Mallory 5) (Katril Davion 5) (Katril Sirtis 10)
    (Sirtis Katril 10) (Sirtis Davion 8) (Sirtis Proserpina 9)
    (Proserpina Sirtis 9) (Proserpina Mallory 11) (Proserpina Kentares 12)))
 
(defparameter *sensors* 
  '((Avalon 15) (Davion 5) (Mallory 12) (Kentares 14) (Proserpina 7) (Katril 9) (Sirtis 0)))

(defparameter *planet-origin* 'Mallory)
(defparameter *planets-destination* '(Sirtis))
(defparameter *planets-forbidden*   '(Avalon))
(defparameter *planets-mandatory*   '(Katril Proserpina))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; BEGIN: Exercise 1 -- Evaluation of the heuristic
;;
;; Returns the value of the heuristics for a given state
;;
;;  Input:
;;    state: the current state (vis. the planet we are on)
;;    sensors: a sensor list, that is a list of pairs
;;                (state cost)
;;             where the first element is the name of a state and the second
;;             a number estimating the cost to reach the goal
;;
;;  Returns:
;;    The cost (a number) or NIL if the state is not in the sensor list
;;
(defun f-h-galaxy (state sensors)
  (cadr (assoc state sensors)))

(f-h-galaxy 'Sirtis *sensors*) ;-> 0
(f-h-galaxy 'Avalon *sensors*) ;-> 15
(f-h-galaxy 'Earth  *sensors*) ;-> NIL


;;
;; END: Exercise 1 -- Evaluation of the heuristic
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 2 -- Navigation operators
;;
;; Returns a list of all posible actions from a state
;;
;;  Input:
;;    state: the current state (vis. the planet we are on)
;;    [white/worm]-holes: Links in our galaxy of a certain type
;;    (planets-forbidden): Only if worm holes. Planets that are not allowed to be visited
;;                         allowed to be visited via worm-holes
;;
;;  Returns:
;;    A list with all possible actions from the original state
;;    avoiding the links that go to a forbidden planet.
;;

;; Function that evaluates a link
(defun check-hole (hole state forbidden name)
  (let ((origin (first hole))
        (destination (second hole))
        (cost (third hole)))
    (when (and (eql origin state) ;;If the origin of the link is the state we are on
               (null (member destination forbidden))) ;; And the destination is not forbidden
      (list (make-action :name name ;; Create an action within a list
                   :origin state
                   :final destination
                   :cost cost)))))

;; Generical function for evaluating links
(defun navigate (state holes planets-forbidden name)
  (mapcan #'(lambda (x) (check-hole x 
                                    state 
                                    planets-forbidden 
                                    name))
    holes))

;; Function for evaluating white holes
(defun navigate-white-hole (state white-holes)
  (navigate state
            white-holes
            NIL
            'NAVIGATE-WHITE-HOLE))

;; Function for evaluating worm holes
(defun navigate-worm-hole (state worm-holes planets-forbidden)
  (navigate state 
            worm-holes 
            planets-forbidden 
            'NAVIGATE-WORM-HOLE))


(navigate-worm-hole 'Mallory *worm-holes* *planets-forbidden*)  ;-> 
;;;(#S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL KATRIL :COST 5)
;;; #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL PROSERPINA :COST 11))

(navigate-worm-hole 'Mallory *worm-holes* NIL)  ;-> 
;;;(#S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL AVALON :COST 9)
;;; #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL KATRIL :COST 5)
;;; #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL PROSERPINA :COST 11))


(navigate-white-hole 'Kentares *white-holes*) ;->
;;;(#S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN KENTARES :FINAL AVALON :COST 3)
;;; #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN KENTARES :FINAL KATRIL :COST 10)
;;; #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN KENTARES :FINAL PROSERPINA :COST 7))


(navigate-worm-hole 'Uranus *worm-holes* *planets-forbidden*)  ;-> NIL


;;
;; END: Exercise 2 -- Navigation operators
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 3 -- Goal test
;;
;; Returns a list of all posible actions from a state
;;
;;  Input:
;;    node: the current node (vis. the planet we are on)
;;    planets-destination: List of planets we need to reach (one of them)
;;    planets-mandatory: List of planets we need to visit.
;;
;;  Returns:
;;    T if we reached the goal, NIL otherwise
;;

;; Checks if the path followed includes the mandatory planets
(defun check-path (node planets)
  (let ((new-planets (remove (node-state node) 
                             planets)))
    (if (null new-planets) ;; No more mandatory planets to visit
        T
      (let ((parent (node-parent node)))
        (unless (null parent) ;; No more path to analyze
          (check-path parent ;; Check next step of the path
                      new-planets))))))

;; Checks if we fullfilled the requirements
(defun f-goal-test-galaxy (node planets-destination planets-mandatory) 
  (and (member (node-state node) 
               planets-destination) ;; Check if the node is a destination
       (check-path node planets-mandatory))) ;; Check if we visited the mandatory planets


(defparameter node-01
   (make-node :state 'Avalon) )
(defparameter node-02
   (make-node :state 'Kentares :parent node-01))
(defparameter node-03
   (make-node :state 'Katril :parent node-02))
(defparameter node-04
   (make-node :state 'Kentares :parent node-03))
(f-goal-test-galaxy node-01 '(kentares urano) '(Avalon Katril)); -> NIL
(f-goal-test-galaxy node-02 '(kentares urano) '(Avalon Katril)); -> NIL
(f-goal-test-galaxy node-03 '(kentares urano) '(Avalon Katril)); -> NIL
(f-goal-test-galaxy node-04 '(kentares urano) '(Avalon Katril)); -> T


;;
;; END: Exercise 3 -- Goal test
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise  -- Equal predicate for search states
;;

;; comprueba si dos listas tienen los mismos elementos
(defun equal-lists (list1 list2)
  (and (subsetp list1 list2 :test #'equal) 
       (subsetp list2 list1 :test #'equal)))

;; Devuelve los nodos obligatorios que han sido visitados para llegar al nodo
(defun get-mandatory-path (node planets-mandatory path)
  (if (equal-lists planets-mandatory path)
      path
    (let ((parent (node-parent node))
          (state (node-state node)))
      (if (null parent) ;; Nodo raiz
          (if (member state planets-mandatory) ;; Si es obligatorio
              (cons state path) ;; Poner el primero de la lista
            path);; No lo añadimos
        (if (member state planets-mandatory) ;; Si es obligatorio
            (get-mandatory-path parent ;; Resto de nodos
                                planets-mandatory
                                (cons state path)) ;; Lo añadimos
          (get-mandatory-path parent ;; Resto de nodos
                              planets-mandatory
                              path)))))) ;; No lo añadimos  

;; Función para valorar si dos nodos son iguales
(defun f-search-state-equal-galaxy (node-1 node-2 &optional planets-mandatory)
  (when (equal (node-state node-1) (node-state node-2))
    (and (equal-lists (get-mandatory-path node-1 planets-mandatory NIL)
                      (get-mandatory-path node-2 planets-mandatory NIL)))))    
       
(f-search-state-equal-galaxy node-01 node-01) ;-> T
(f-search-state-equal-galaxy node-01 node-02) ;-> NIL
(f-search-state-equal-galaxy node-02 node-04) ;-> T

(f-search-state-equal-galaxy node-01 node-01 '(Avalon)) ;-> T
(f-search-state-equal-galaxy node-01 node-02 '(Avalon)) ;-> NIL
(f-search-state-equal-galaxy node-02 node-04 '(Avalon)) ;-> T

(f-search-state-equal-galaxy node-01 node-01 '(Avalon Katril)) ;-> T
(f-search-state-equal-galaxy node-01 node-02 '(Avalon Katril)) ;-> NIL
(f-search-state-equal-galaxy node-02 node-04 '(Avalon Katril)) ;-> NIL


;;
;; END: Exercise  -- Equal predicate for search states
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  BEGIN: Exercise 4 -- Define the galaxy structure
;;
;;
(defparameter *galaxy-M35* 
  (make-problem 
   :states               *planets*          
   :initial-state        *planet-origin*
   :f-goal-test          #'(lambda (node) 
                             (f-goal-test-galaxy node *planets-destination*
                                                 *planets-mandatory*))
   :f-h                  #'(lambda (state) 
                             (f-h-galaxy state *sensors*)) 
   :f-search-state-equal #'(lambda (node-1 node-2) 
                             (f-search-state-equal-galaxy node-1
                                                          node-2
                                                          *planets-mandatory*))
   :operators            (list #'(lambda (state) 
                                   (navigate-worm-hole state
                                                       *worm-holes*
                                                       *planets-forbidden*))
                               #'(lambda (state)
                                   (navigate-white-hole state
                                                        *white-holes*)))))

;;
;;  END: Exercise 4 -- Define the galaxy structure
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN Exercise 5: Expand node
;;

;; Function to get all the posible actions from a node
(defun get-all-actions (node problem)
  (mapcan #'(lambda (x) (funcall x (node-state node)))
    (problem-operators problem)))

;; Function to expand a node
(defun expand-node (node problem)
  (mapcar #'(lambda (x) ;; Iterating through all actions
              (let* ((final (action-final x))
                    (g (+ (node-g node) (action-cost x)))
                    (h (funcall (problem-f-h problem) final)))
                (make-node :state final ;; Create a new node structure
                           :parent node
                           :action x
                           :depth (+ (node-depth node) 1)
                           :g g
                           :h h
                           :f (+ g h))))
      (get-all-actions node problem)))

(expand-node (make-node :state 'Kentares :depth 0 :g 0 :f 0) *galaxy-M35*)
;;;(#S(NODE :STATE AVALON
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL AVALON
;;;                           :COST 3)
;;;         :DEPTH 1
;;;         :G ...)
;;; #S(NODE :STATE KATRIL
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL KATRIL
;;;                           :COST 10)
;;;         :DEPTH 1
;;;         :G ...)
;;; #S(NODE :STATE PROSERPINA
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL PROSERPINA
;;;                           :COST 7)
;;;         :DEPTH 1
;;;         :G ...)
;;; #S(NODE :STATE PROSERPINA
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL PROSERPINA
;;;                           :COST 12)
;;;         :DEPTH 1
;;;         :G ...))



;;
;; END Exercise 5: Expand node
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  BEGIN Exercise 6 -- Node list management
;;;  

;; Parameter for the unifirm-cost strategy
(defparameter *uniform-cost* 
  (make-strategy :name 'uniform-cost
                 :node-compare-p #'(lambda (x y) (if (null y)
                                                     t
                                                   (< (node-g x) 
                                                    (node-g y)))))) ;; Compare path cost to node

;; Insert a node in the corresponding position accord to the strategy
(defun insert-sort-node (node lst-nodes strategy)
  (let ((first (first lst-nodes)))
    (if (funcall (strategy-node-compare-p strategy) 
                 node 
                 first) ;; Check strategy
        (cons node lst-nodes) ;; Place the node
      (cons first 
            (insert-sort-node node ;; Recursive call
                              (rest lst-nodes) 
                              strategy)))))

;; Insert nodes in lst-nodes according to strategy
(defun insert-nodes-strategy (nodes lst-nodes strategy)
  (if (null nodes)
      lst-nodes ;; No more nodes to insert
    (insert-nodes-strategy (rest nodes) ;; Recursive call
                         (insert-sort-node (first nodes) ;; Inserting one node
                                           lst-nodes 
                                           strategy) 
                         strategy)))

(defparameter node-00
  (make-node :state 'Proserpina :depth 8 :g 4 :f 0) )
(defparameter node-01
   (make-node :state 'Avalon :depth 0 :g 0 :f 0) )
(defparameter node-02
  (make-node :state 'Kentares :depth 2 :g 50 :f 50) )
(defparameter node-03
   (make-node :state 'Davion :depth 0 :g 6 :f 0) )
(defparameter node-04
  (make-node :state 'Katril :depth 2 :g 0 :f 50) )
(defparameter lst-nodes-00
             (list node-04 node-03))

(print (insert-nodes-strategy (list node-00 node-01 node-02) 
                              lst-nodes-00 
                              *uniform-cost*));->
;;;
;;;(#S(NODE :STATE AVALON :PARENT NIL :ACTION NIL :DEPTH 0 :G 0 :H 0 :F 0)
;;; #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;; #S(NODE :STATE AVALON :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL AVALON :COST 12) :DEPTH 13 :G 22 :H 5 :F 27)
;;; #S(NODE :STATE DAVION :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL DAVION :COST 14) :DEPTH 13 :G 24 :H 1 :F 25)
;;; #S(NODE :STATE MALLORY :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 17) :DEPTH 13 :G 27 :H 7 :F 34)
;;; #S(NODE :STATE SIRTIS :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 10) :DEPTH 13 :G 20 :H 0 :F 20)
;;; #S(NODE :STATE KENTARES :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL KENTARES :COST 21) :DEPTH 13 :G 31 :H 4 :F 35)
;;; #S(NODE :STATE MALLORY :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 16) :DEPTH 13 :G 26 :H 7 :F 33)
;;; #S(NODE :STATE SIRTIS :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 7) :DEPTH 13 :G 17 :H 0 :F 17)
;;; #S(NODE :STATE KENTARES :PARENT NIL :ACTION NIL :DEPTH 2 :G 50 :H 0 :F 50)) 


(print 
 (insert-nodes-strategy (list node-00 node-01 node-02) 
                        (sort (copy-list lst-nodes-00) #'<= :key #'node-g) 
                        *uniform-cost*));->
;;;
;;;(#S(NODE :STATE AVALON :PARENT NIL :ACTION NIL :DEPTH 0 :G 0 :H 0 :F 0)
;;; #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;; #S(NODE :STATE SIRTIS :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 7) :DEPTH 13 :G 17 :H 0 :F 17)
;;; #S(NODE :STATE SIRTIS :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 10) :DEPTH 13 :G 20 :H 0 :F 20)
;;; #S(NODE :STATE AVALON :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL AVALON :COST 12) :DEPTH 13 :G 22 :H 5 :F 27)
;;; #S(NODE :STATE DAVION :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL DAVION :COST 14) :DEPTH 13 :G 24 :H 1 :F 25)
;;; #S(NODE :STATE MALLORY :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 16) :DEPTH 13 :G 26 :H 7 :F 33)
;;; #S(NODE :STATE MALLORY :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 17) :DEPTH 13 :G 27 :H 7 :F 34)
;;; #S(NODE :STATE KENTARES :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL KENTARES :COST 21) :DEPTH 13 :G 31 :H 4 :F 35)
;;; #S(NODE :STATE KENTARES :PARENT NIL :ACTION NIL :DEPTH 2 :G 50 :H 0 :F 50)) 


;;
;;    END: Exercise 6 -- Node list management
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 7 -- Definition of the A* strategy
;;
;; A strategy is, basically, a comparison function between nodes to tell 
;; us which nodes should be analyzed first. In the A* strategy, the first 
;; node to be analyzed is the one with the smallest value of g+h
;;

(defparameter *A-star*
  (make-strategy :name 'A-star
                 :node-compare-p #'(lambda (x y) (if (null y)
                                                     t
                                                   (< (node-f x) 
                                                    (node-f y)))))) ;; Compare cost + heuristic

;;
;; END: Exercise 7 -- Definition of the A* strategy
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;    BEGIN Exercise 8: Search algorithm
;;;


;;; Function to check if a node is closed
;;; It will return T if the node is already explored and
;;; has a bigger g
(defun check-closed (node closed problem)
  (unless (null closed)
    (let ((test (member node    ;; Check if the node is in the close list
                        closed  ;; If the node is in it, it returns the cons of closed.
                        :test #'(lambda (x y) 
                                  (funcall (problem-f-search-state-equal problem) 
                                           x 
                                           y)))))
      (and test (> (node-g node) 
                   (node-g (first test))))))) ;; If the test checks and the g is bigger,
                                              ;; we dont want to explore it
          

(defun recursive-graph-search (open closed problem strategy)
  (unless (null open)
    (let ((first (first open)))
      (if (funcall (problem-f-goal-test problem) ;; Si es la meta
                   first)
          first
        (if (check-closed first closed problem)
            (recursive-graph-search (rest open)
                                    closed
                                    problem
                                    strategy) ;; No expandimos ese nodo
          (recursive-graph-search (insert-nodes-strategy (expand-node first 
                                                                    problem) 
                                                       (rest open) 
                                                       strategy) ;; Expandimos y añadmos a abiertos
                                (cons first closed) ;; Lo añadimos a cerrados
                                problem
                                strategy))))))

(defun graph-search (problem strategy)
  (recursive-graph-search (list (make-node :state (problem-initial-state problem)))
                          NIL
                          problem 
                          strategy))

;
;  Solve a problem using the A* strategy
;
(defun a-star-search (problem)
  (graph-search problem *A-star*))


(print (graph-search *galaxy-M35* *A-star*));->
;;;#S(NODE :STATE ...
;;;        :PARENT #S(NODE :STATE ...
;;;                        :PARENT #S(NODE :STATE ...)) 


(print (a-star-search *galaxy-M35*));->
;;;#S(NODE :STATE ...
;;;        :PARENT #S(NODE :STATE ...
;;;                        :PARENT #S(NODE :STATE ...)) 


;;; 
;;;    END Exercise 8: Search algorithm
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;    BEGIN Exercise 9: Solution path / action sequence
;;;

;; Función recursiva para obtener el path
(defun rec-solution-path (node path)
  (let ((parent (node-parent node))
        (state (node-state node)))
    (if (null parent) ;; Nodo raiz
        (cons state path) ;; Poner el primero de la lista
      (rec-solution-path parent ;; Resto de nodos
                         (cons state path))))) ;; Ponerlos al principio de la lista y seguir

;; Función que devuelve el path hasta node
(defun solution-path (node)
  (unless (null node) ;; Comprobar si es NIL
    (rec-solution-path node NIL)))

(solution-path nil) ;;; -> NIL 
(solution-path (a-star-search *galaxy-M35*))  ;;;-> (MALLORY ...)

;; Función recursiva que devuelve la lista de acciones para llegar al nodo
(defun rec-action-sequence (node actions)
  (let ((parent (node-parent node))
        (action (node-action node)))
    (if (null parent) ;; Nodo raiz
        actions ;; Devolver la lista
      (rec-action-sequence parent ;; Resto de nodos
                         (cons action actions))))) ;; Ponerlos al principio de la lista y seguir

;; Función que devuelve la lista de acciones necesarias para llegar al nodo
(defun action-sequence (node)
  (unless (null node) ;; Comprobar si es NIL 
    (rec-action-sequence node NIL)))

(action-sequence (a-star-search *galaxy-M35*))
;;; ->
;;;(#S(ACTION :NAME ...)) 

;;; 
;;;    END Exercise 9: Solution path / action sequence
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;    BEGIN Exercise 10: depth-first / breadth-first
;;;

(defun depth-first-node-compare-p (node-1 node-2)
  T) ;; Last explored node gets in the first position of open-nodes

(defparameter *depth-first*
  (make-strategy
   :name 'depth-first
   :node-compare-p #'depth-first-node-compare-p))

(solution-path (graph-search *galaxy-M35* *depth-first*))
;;; -> (MALLORY ... )

(defun breadth-first-node-compare-p (node-1 node-2)
  (null node-2)) ;; Last explored node gets in the last position of open-nodes

(defparameter *breadth-first*
  (make-strategy
   :name 'breadth-first
   :node-compare-p #'breadth-first-node-compare-p))

(solution-path (graph-search *galaxy-M35* *breadth-first*))
;; -> (MALLORY ... )

;;; 
;;;    END Exercise 10: depth-first / breadth-first
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
