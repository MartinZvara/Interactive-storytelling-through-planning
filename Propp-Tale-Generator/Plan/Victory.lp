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
fluent(defeated(A)) :- actor(A).
fluent(inBattle(A1,A2)) :- actor(A1), actor(A2).
fluent(isMarked(A)) :- actor(A).
fluent(saw(A,Action)) :- actor(A), action(Action).
fluent(have(A,O)) :- actor(A), object(O).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move(A,L)) :- actor(A), location(L).
action(defeat(A1,A2)) :- actor(A1), actor(A2).
action(save(A1,A2)) :- actor(A1), actor(A2). 


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
:- not holds(N,inBattle(A1,A2)), occurs(N,defeat(A1,A2)).
:- not holds(N,captured(A1,A2)), occurs(N,save(A3,A2)).
:- holds(N,captured(A1,A2)), not holds(N,defeated(A1)) occurs(N,save(A3,A2)).


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move(A,L1)), holds(N,actorAt(A,L)), state(N).
-holds(N+1, inBattle(A1,A2)) :- occurs(N, defeat(A1,A2)), state(N).
 holds(N+1, defeated(A1)) :- occurs(N, defeat(A2,A1)), state(N).
-holds(N+1, captured(A1,A2)) :- occurs(N, save(A3,A2)), state(N), actor(A1).
 holds(N+1, saw(A1,defeat(A1,A2))) :- occurs(N, defeat(A1,A2)), state(N).
 holds(N+1, saw(A3,defeat(A1,A2))) :- occurs(N, defeat(A1,A2)), holds(N,actorAt(A3,L)), 
                                      holds(N,actorAt(A1,L)), state(N).


%===============================================================================
%                                     GOAL
%===============================================================================
goal :- holds(n, actorAt(A1,L)), holds(n, actorAt(A2,L)), -holds(n, captured(A1,A2)), 
        princess(A2), villain(A1), homeEnviroment(A2,L).  
:- not goal.
