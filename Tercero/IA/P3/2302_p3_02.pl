% PRACTICA 3 %

% EJERCICIO 1 %

% Es necesario comprobar que X no sea una lista para que %
% no se devuelvan listas como posibles candidatos. Tambien %
% es necesario mirar si X pertenece al primer elemento de la %
% lista, que podria ser una sublista %

pertenece_m(X, [X|_]) :- X \= [_|_].
pertenece_m(X, [Y|_]) :- pertenece_m(X,Y).
pertenece_m(X, [_|Rs]) :- pertenece_m(X, Rs).

/** <examples>
?- pertenece_m(X, [2,[1,3],[1,[4,5]]])
*/

% EJERCICIO 2 %

% CONCATENA: %
concatena([], L, L).
concatena([X|L1], L2, [X|L3]) :- concatena(L1, L2, L3).

% INVIERTE: %
invierte(L1, L2) :- invierte_aux(L1, L2, []).
invierte_aux([], L2, L3) :- L3 = L2.
invierte_aux([X|L1], L2, L3) :- 
    concatena([X], L3, A), 
    invierte_aux(L1, L2, A).

/** <examples>
?- invierte([1, 2], L).
?- invierte([], L).
?- invierte([1, 2, 5, 4], L).
*/

% EJERCICIO 3 %

% INSERTAR: %
insert([X-P], [], [X-P]).
insert([X-P], [A-P1|Rs], R) :- 
    P =< P1, 
    concatena([X-P], [A-P1|Rs], C),
    C = R.
insert([X-P], [A-P1|Rs], [B-P2|Ls]) :-
    P > P1,
    P2 = P1,
    A = B,
    insert([X-P], Rs, Ls). 

/** <examples>
?- insert([a-6],[], X).
?- insert([a-6],[p-0], X).
?- insert([a-6],[p-0, g-7], X).
?- insert([a-6],[p-0, g-7, t-2], X).
*/

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

list_count([X|Rs], L2, [X-C|Ls]) :- 
    elem_count(X,L2,C), 
    list_count(Rs,L2,Ls).

/** <examples>
?- list_count([b],[b,a,b,a,b],Xn). 
?- list_count([b,a],[b,a,b,a,b],Xn). 
?- list_count([b,a,c],[b,a,b,a,b],Xn). 
?- list_count([],[b,a,b,a,b],Xn). 
?- list_count([a],[],Xn). 
*/

% EJERCICIO 5 %

sort_list([],[]).
sort_list([A|Rs], B) :- 
    sort_list(Rs, L), 
    insert([A], L, B).

/** <examples>
?- sort_list([p-0, a-6, g-7, t-2], X).
?- sort_list([p-0, a-6, g-7,p-9, t-2], X).
?- sort_list([p-0, a-6, g-7,p-9, t-2, 9-99], X).
*/

% EJERCICIO 6 %

build_tree([A-_], tree(A,nil,nil)).
build_tree([A,B|Rs], X) :- 
    build_tree([B|Rs], X1),
    build_tree([A], A1),
    X = tree(1, A1, X1).


/** <examples>
?- build_tree([p-0, a-6, g-7, p-9, t-2, 9-99], X).
?- build_tree([p-55, a-6, g-7, p-9, t-2, 9-99], X).
?- build_tree([p-55, a-6, g-2, p-1], X).
?- build_tree([a-11, b-6, c-2, d-1], X).
*/

% EJERCICIO 7.1 %

encode_elem(A, [], tree(A,nil,nil)).
encode_elem(A, [0], tree(1,tree(A,nil,nil),_)).
encode_elem(A, X, tree(1, tree(B, _, _), G)) :- 
    A \= B,
    encode_elem(A, X1, G),
    concatena([1], X1, X).

/** <examples>
?- encode_elem(a, X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
?- encode_elem(b, X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
?- encode_elem(c, X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
?- encode_elem(d, X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
*/

% EJERCICIO 7.2 %

encode_list([],[],_).
encode_list([A|Rs], B, T) :-
    encode_list(Rs, C, T),
    encode_elem(A, X, T),
    B = [X|C].

/** <examples>
?- encode_list([a], X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
?- encode_list([a,a], X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
?- encode_list([a,d,a], X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
?- encode_list([a,d,a, q], X, tree(1, tree(a, nil, nil), tree(1, tree(b, nil, nil), tree(1, tree(c, nil, nil), tree(d, nil, nil))))).
*/

% EJERCICIO 8 %

dictionary([a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z]).

encode(A, B) :- 
    dictionary(D),
    list_count(D, A, C),
    sort_list(C, S),
    invierte(S, I),
    build_tree(I, T),
    encode_list(A, B, T).

/** <examples>
?- encode([i,a],X).
?- encode([i,n,t,e,l,i,g,e,n,c,i,a,a,r,t,i,f,i,c,i,a,l],X).
?- encode([i,2,a],X).
*/


