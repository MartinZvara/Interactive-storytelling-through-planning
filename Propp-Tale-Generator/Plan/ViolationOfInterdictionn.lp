#const n = 
#hide.
#show occurs/2.
#show holds/2.
state(0..n-1).

%===============================================================================
%                                    FLUENTS
%===============================================================================
fluent(actorAt(A,L)) :- actor(A), location(L).
fluent(have(A,O)) :- actor(A), object(O).
fluent(captured(A1,A2)) :- actor(A1), actor(A2).
fluent(saw(A,Action)) :- actor(A), action(Action).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move_to(A,L)) :- actor(A), location(L).
action(capture(A1,A2)) :- actor(A1), actor(A2).


%===============================================================================
%                                 INITIAL STATE
%===============================================================================


%===============================================================================
%                                ACTION GENERATOR
%=============================================================================== 
 occurs(N,A) :- not -occurs(N,A), state(N), action(A).
-occurs(N,B) :- occurs(N,A), state(N), action(A), action(B), A!=B.


%===============================================================================
%                                    INERTIA
%===============================================================================
 holds(N+1,F) :-  holds(N,F), not -holds(N+1,F), state(N), fluent(F).
-holds(N+1,F) :- -holds(N,F), not  holds(N+1,F), state(N), fluent(F).


%===============================================================================
%                                 EXECUTABILITY
%===============================================================================
:- holds(N,actorAt(A,L)), occurs(N, move_to(A,L1)), not loc(L,L1), not loc(L1,L), L!=L1.
:- holds(N,captured(A1,A2)), occurs(N, move_to(A1,L)).
:- holds(N,captured(A1,A2)), occurs(N, capture(A2,A3)).
:- holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), occurs(N,capture(A1,A2)), L1!=L2. 


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, captured(A1,A2)) :- occurs(N, capture(A1,A2)), state(N).
 holds(N+1, actorAt(A2,L)) :- occurs(N, capture(A1,A2)), on(A1,L), state(N).
-holds(N+1, actorAt(A2,L)) :- occurs(N, capture(A1,A2)), not on(A1,L), location(L), state(N).
 holds(N+1, actorAt(A1,L)) :- occurs(N, capture(A1,A2)), on(A1,L), state(N).
-holds(N+1, actorAt(A1,L)) :- occurs(N, capture(A1,A2)), not on(A1,L), location(L), state(N).
 holds(N+1, saw(A1, capture(A2,A3))) :- occurs(N, capture(A2,A3)), holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), A1!=A2, A1!=A3.

%===============================================================================
%                                     GOAL
%===============================================================================
goal :- holds(n,actorAt(A1, L)), homeEnviroment(A1, L), holds(n,captured(A1,A2)), villain(A1), 
        princess(A2), holds(n,saw(A3,capture(A1,A2))), questGiver(A3), holds(n,actorAt(A3, L2)), 
        homeEnviroment(A3,L2), not holds(n,saw(A4,capture(A1,A2))), hero(A4).   
:- not goal.
