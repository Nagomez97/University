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
