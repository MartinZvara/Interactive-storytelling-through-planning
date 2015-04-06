#const n = 
#hide.
#show occurs/2.
#show holds/2.
state(0..n-1).

%===============================================================================
%                                    FLUENTS
%===============================================================================
fluent(actorAt(A,L)) :- actor(A), location(L).
fluent(homeEnviroment(A,L)) :- actor(A), location(L).
fluent(captured(A1,A2)) :- actor(A1), actor(A2).
fluent(saw(A,Action)) :- actor(A), action(Action).
fluent(have(A,O)) :- actor(A), object(O).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move_to(A,L)) :- actor(A), location(L).
action(capture(A1,A2)) :- actor(A1), actor(A2). 


%===============================================================================
%                                 INITIAL STATE
%===============================================================================
%holds(0, have(A,O)) :- actor(A), object(O), on(A,O).


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
:- holds(N,actorAt(A,L)), occurs(N, move_to(A,L1)), holds(N, captured(A1,A)).
:- occurs(N, capture(A1,A2)).


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).


%===============================================================================
%                                     GOAL
%===============================================================================
goal :- holds(n, actorAt(A1,L)), holds(n, actorAt(A2,L)), hero(A1), villain(A2), 
        homeEnviroment(A2,L).  
:- not goal.
