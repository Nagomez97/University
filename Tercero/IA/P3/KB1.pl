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

% INVIERTE: %
invierte([],[]).
invierte([X],[X]).

same_last(X, [_,Y]) :- Y \= [_|_], X = Y.
