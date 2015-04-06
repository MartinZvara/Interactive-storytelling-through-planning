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
fluent(saw(Actor,Action)) :- actor(Actor), action(Action).
fluent(have(A,O)) :- actor(A), object(O).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move_to(A,L)) :- actor(A), location(L).
action(capture(A1,A2)) :- actor(A1), actor(A2).
action(defeat(A1,A2)) :- actor(A1), actor(A2).
sAction(tell_to(A1,A2,Action)) :- actor(A1), actor(A2), action(Action). %koli zacykleniu 


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
:- holds(N,actorAt(A,L)), occurs(N,move_to(A,L1)), not loc(L,L1), not loc(L1,L), L!=L1.
:- holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), occurs(N,give(A1,A2,O)), L1!=L2.
:- holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), occurs(N,give(A1,A2,O)), not holds(N,have(A1,O)).
:- holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), occurs(N,tell_to(A1,A2,Act)), L1!=L2.
:- holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), occurs(N,tell_to(A1,A2,Act)), not holds(N, saw(A1, Act)), not fHero(A1). 
:- occurs(N, capture(A1,A2)).
:- occurs(N, defeat(A1,A2)).


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
-holds(N+1, have(A1,O)) :- occurs(N, give(A1,A2,O)), state(N).
 holds(N+1, have(A2,O)) :- occurs(N, give(A1,A2,O)), state(N).
 holds(N+1, saw(A2, Act)) :- occurs(N, tell_to(A1,A2,Act)), state(N).


%===============================================================================
%                                     GOAL
%===============================================================================
goal :-  holds(n, actorAt(A1,L)), holds(n, actorAt(A2,L)), holds(n, actorAt(A3,L)),
         holds(n, actorAt(A4,L)), hero(A1), fHero(A2), princess(A3), dispatcher(A4),
         occurs(N, tell_to(A1,A4,defeat(A1,A5))), state(N), N<n, 
         holds(n, saw(A4,defeat(A2,A5))), homeEnviroment(A4,L). 
:- not goal.
