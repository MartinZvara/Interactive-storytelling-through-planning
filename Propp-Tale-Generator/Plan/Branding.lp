#const n = 
#hide.
#show occurs/2.
#show holds/2.
state(0..n-1).

%===============================================================================
%                                    FLUENTS
%===============================================================================
fluent(actorAt(A,L)) :- actor(A), location(L).
fluent(captured(A1,A2)) :- actor(A1), actor(A2).
fluent(inBattle(A1,A2)) :- actor(A1), actor(A2).
fluent(isMarked(A)) :- actor(A).
fluent(saw(A,Action)) :- actor(A), action(Action).
fluent(have(A,O)) :- actor(A), object(O).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move(A,L)) :- actor(A), location(L).
action(mark(A1,A2)) :- actor(A1), actor(A2).
action(give(A1,A2,O)) :- actor(A1), actor(A2), object(O).


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
:- holds(N,actorAt(A,L)), occurs(N,move(A,L1)), not loc(L,L1), not loc(L1,L), L!=L1.
:- holds(N,captured(A1,A)), occurs(N,move(A,L1)).  
:- holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), occurs(N,give(A1,A2,O)), L1!=L2.
:- not holds(N,have(A1,O)), occurs(N,give(A1,A2,O)).
:- sObject(O), occurs(N,give(A1,A2,O)).
:- holds(N,captured(A1,A2)), occurs(N,give(A2,A3,O)).
:- holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), occurs(N,mark(A1,A2)), L1!=L2.
:- occurs(N,mark(A1,A2)), A1=A2.
:- holds(N,captured(A1,A2)), occurs(N,mark(A2,A3)).


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, isMarked(A2)) :- occurs(N, mark(A1,A2)), state(N).
 holds(N+1, have(A2,O)) :- occurs(N, mark(A1,A2)), sObject(O), state(N), holds(N,have(A1,O)).
-holds(N+1, have(A1,O)) :- occurs(N, give(A1,A2,O)), state(N).
 holds(N+1, have(A2,O)) :- occurs(N, give(A1,A2,O)), state(N).


%===============================================================================
%                                     GOAL
%===============================================================================
goal :- holds(n, actorAt(A1,L)), holds(n, actorAt(A2,L)), holds(n, isMarked(A1)), 
        holds(n, inBattle(A1,A2)), hero(A1), villain(A2), homeEnviroment(A2,L).  
:- not goal.
