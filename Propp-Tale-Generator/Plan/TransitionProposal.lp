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
fluent(saw(Actor,Action)) :- actor(Actor), action(Action).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move_to(A,L)) :- actor(A), location(L).
action(capture(A1,A2)) :- actor(A1), actor(A2).
sAction(tell_to(A1,A2,Action)) :- actor(A1), actor(A2), action(Action). 


%===============================================================================
%                                 INITIAL STATE
%===============================================================================


%===============================================================================
%                                ACTION GENERATOR
%=============================================================================== 
 occurs(N,A) :- not -occurs(N,A), state(N), action(A).
-occurs(N,B) :- occurs(N,A), state(N), action(A), action(B), A!=B.
-occurs(N,B) :- occurs(N,A), state(N), sAction(A), action(B), A!=B.
 occurs(N,A) :- not -occurs(N,A), state(N), sAction(A).
-occurs(N,B) :- occurs(N,A), state(N), action(A), sAction(B), A!=B.
-occurs(N,B) :- occurs(N,A), state(N), sAction(A), sAction(B), A!=B.


%===============================================================================
%                                    INERTIA
%===============================================================================
 holds(N+1,F) :-  holds(N,F), not -holds(N+1,F), state(N), fluent(F).
-holds(N+1,F) :- -holds(N,F), not  holds(N+1,F), state(N), fluent(F).


%===============================================================================
%                                 EXECUTABILITY
%===============================================================================
:- holds(N,actorAt(A,L)), occurs(N, move_to(A,L1)), not loc(L,L1), not loc(L1,L), L!=L1.
:- holds(N, captured(A1,A)), occurs(N, move_to(A,L1)).
:- occurs(N, capture(A1,A2)).
:- holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), occurs(N,tell_to(A1,A2,Act)), L1!=L2.
:- holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), occurs(N,tell_to(A1,A2,Act)), not holds(N, saw(A1, Act)). 


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, saw(A2, Act)) :- occurs(N, tell_to(A1,A2,Act)), state(N).


%===============================================================================
%                                     GOAL
%===============================================================================
goal :-  holds(n, actorAt(A1,L2)), holds(n, actorAt(A2,L2)), hero(A1), questGiver(A2), 
         holds(n, saw(A2,Act)), holds(n, saw(A1,Act)), homeEnviroment(A2,L2). 
:- not goal.
