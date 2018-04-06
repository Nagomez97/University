% PRACTICA 3 %

% EJERCICIO 1 %

% Es necesario comprobar que X no sea una lista para que %
% no se devuelvan listas como posibles candidatos. Tambien %
% es necesario mirar si X pertenece al primer elemento de la %
% lista, que podria ser una sublista %

pertenece_m(X, [X|_]) :- X \= [_|_].
pertenece_m(X, [Y|_]) :- pertenece_m(X,Y).
pertenece_m(X, [_|Rs]) :- pertenece_m(X, Rs).

% EJERCICIO 2 %

% CONCATENA: %
concatena([], L, L).
concatena([X|L1], L2, [X|L3]) :- concatena(L1, L2, L3).

% INIVIERTE: %
invierte(L1, L2) :- invierte_aux(L1, L2, []).
invierte_aux([], L2, L3) :- L3 = L2.
invierte_aux([X|L1], L2, L3) :- 
    concatena([X], L3, A), 
    invierte_aux(L1, L2, A).

% EJERCICIO 3 %

% INSERTAR: %
insert([X-P], [], [X-P]).
insert([X-P], [A-P1|Rs], R) :- 
    P < P1, 
    concatena([X-P], [A-P1|Rs], C),
    C = R.
insert([X-P], [A-P1|Rs], [B-P2|Ls]) :-
    P > P1,
    P2 = P1,
    A = B,
    insert([X-P], Rs, Ls). 

% EJERCICIO 4.1 %

elem_count(_,[],0). %caso base

elem_count(X,[X|Rs], M) :- 
    elem_count(X, Rs, N), 
    M is N+1.

elem_count(X, [Y|Rs], M) :- 
    X \= Y, 
    elem_count(X, Rs, M).

/** <examples>
?- elem_count(1, [2,3], 1).

?- elem_count(1, [], 1).
   
?- elem_count(1, [1,2,3], 1).
   
?- elem_count(1, [1,2,3], 2).
   
?- elem_count(1, [1,2,3,1], X).
   
*/


% EJERCICIO 4.2 %

list_count([], A,  []) :- is_list(A).

list_count([X|Rs], L2, [A-C|Ls]) :- 
    X = A, 
    elem_count(X,L2,C), 
    list_count(Rs,L2,Ls).

/** <examples>
?- list_count([b],[b,a,b,a,b],Xn). 
?- list_count([b,a],[b,a,b,a,b],Xn). 
?- list_count([b,a,c],[b,a,b,a,b],Xn). 
?- list_count([],[b,a,b,a,b],Xn). 
?- list_count([a],[],Xn). 

*/
