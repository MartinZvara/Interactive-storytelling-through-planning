#const s = 1000.
#const a = 2.
#const b = 4. %4.
#const c = 6. %6.
#const d = 8. %8.
#const e = 13.
#const f = 16.
#const g = 17.
#const h = 25.
#const i = 29.
#const j = 32.
#const k = 33.
#const l = 35.
#show occurs/2.
%#show holds/2.
state(0..l-1).
cost(0..s).
live(0..100).

%===============================================================================
%                                    FLUENTS
%===============================================================================
fluent(actorAt(A,L)) :- actor(A), location(L).
fluent(have(A,O)) :- actor(A), object(O).
fluent(captured(A1,A2)) :- actor(A1), actor(A2).
fluent(inBattle(A1,A2)) :- actor(A1), actor(A2).
fluent(isMarked(A)) :- actor(A).
fluent(saw(Actor,Action)) :- actor(Actor), action(Action).
fluent(cursed(A)) :- actor(A).
fluent(score(S)) :- cost(S).
fluent(live(A,L)) :- actor(A), live(L).
fluent(dead(A)) :- actor(A).
fluent(attackedBy(A1,A2,O)) :- actor(A1), actor(A2), object(O).


%===============================================================================
%                                    ACTIONS
%===============================================================================
action(move_to(A,L)) :- actor(A), location(L).
action(take(A,O)) :- actor(A), object(O).
action(give(A1,A2,O)) :- actor(A1), actor(A2), object(O).
action(show(A1,A2,O)) :- actor(A1), actor(A2), sObject(O).
action(capture(A1,A2)) :- actor(A1), actor(A2).  
action(mark(A1,A2)) :- actor(A1), actor(A2). 
action(marry(A1,A2)) :- actor(A1), actor(A2). 
action(defeat(A1,A2)) :- actor(A1), actor(A2).
%action(fight_with(A1,A2)) :- actor(A1), actor(A2).
%action(curse(A1,A2)) :- actor(A1), actor(A2).
%action(cure(A1,A2)) :- actor(A1), actor(A2).
%action(dodge(A1,A2,O)) :- actor(A1), actor(A2), object(O).
%action(hit(A1,A2,O)) :- actor(A1), actor(A2), object(O).
%action(attack(A1,A2,O)) :- actor(A1), actor(A2), object(O).

sAction(tell_to(A1,A2,Action)) :- actor(A1), actor(A2), action(Action). 


%===============================================================================
%                                 INITIAL STATE
%===============================================================================
holds(0,actorAt(A,L)) :- actor(A), location(L), on(A,L).
holds(0,have(A,O)) :- actor(A), object(O), on(O,A).
holds(0,score(0)).
holds(0,live(A,100)) :- actor(A).


%===============================================================================
%                                ACTION GENERATOR
%=============================================================================== 
 occurs(N,A) :- not -occurs(N,A), state(N), action(A).
-occurs(N,B) :- occurs(N,A), state(N), action(A), action(B), A!=B.
%-occurs(N,B) :- occurs(N,A), state(N), sAction(A), action(B), A!=B.
% occurs(N,A) :- not -occurs(N,A), state(N), sAction(A).
%-occurs(N,B) :- occurs(N,A), state(N), action(A), sAction(B), A!=B.
%-occurs(N,B) :- occurs(N,A), state(N), sAction(A), sAction(B), A!=B.


%===============================================================================
%                                    INERTIA
%===============================================================================
 holds(N+1,F) :-  holds(N,F), not -holds(N+1,F), state(N), fluent(F).
-holds(N+1,F) :- -holds(N,F), not  holds(N+1,F), state(N), fluent(F).


%===============================================================================
%                                 EXECUTABILITY
%===============================================================================
:- occurs(N,move_to(A,L1)), holds(N,actorAt(A,L)), not loc(L,L1), not loc(L1,L), L!=L1.
:- occurs(N,move_to(A,L1)), holds(N,cursed(A)).
:- occurs(N,move_to(A,L1)), holds(N,dead(A)).
:- occurs(N,move_to(A,L1)), holds(N,captured(A1,A)).
:- occurs(N,move_to(A1,L)), holds(N,inBattle(A1,A2)).
:- occurs(N,move_to(A2,L)), holds(N,inBattle(A1,A2)).

:- occurs(N,take(A,O)), holds(N,actorAt(A,L)), not on(O,L).
:- occurs(N,take(A,O)), holds(N,dead(A,L)).
:- occurs(N,take(A1,O)), holds(N,have(A2,O)).
  
:- occurs(N,give(A1,A2,O)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,give(A1,A2,O)), not holds(N,have(A1,O)).
:- occurs(N,give(A1,A2,O)), sObject(O).
:- occurs(N,give(A2,A3,O)), holds(N,captured(A1,A2)).
:- occurs(N,give(A1,A2,O)), holds(N,dead(A1)).
:- occurs(N,give(A1,A2,O)), holds(N,dead(A2)).

:- occurs(N,capture(A1,A2)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,capture(A,A)).
:- occurs(N,capture(A1,A4)), holds(N,captured(A3,A4)).
:- occurs(N,capture(A1,A2)), not princess(A2).
:- occurs(N,capture(A1,A2)), not negativeCharacter(A1).
:- occurs(N,capture(A1,A2)), holds(N,dead(A1)).
:- occurs(N,capture(A1,A2)), holds(N,dead(A2)).

:- occurs(N,tell_to(A1,A2,Act)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,tell_to(A1,A2,Act)), holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), not holds(N, saw(A1, Act)), not fHero(A1).
:- occurs(N,tell_to(A1,A2,Act)), holds(N,dead(A1)).
:- occurs(N,tell_to(A1,A2,Act)), holds(N,dead(A2)).
:- occurs(N,tell_to(A,A,Act)).

:- occurs(N,mark(A1,A2)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,mark(A,A)).
:- occurs(N,mark(A2,A3)), holds(N, captured(A1,A2)).
:- occurs(N,mark(A1,A2)), holds(N, dead(A1)).
:- occurs(N,mark(A1,A2)), holds(N, dead(A2)).
:- occurs(N,mark(A1,A2)), not holds(N, have(A1,O)), sObject(O).

:- occurs(N,show(A1,A2,O)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,show(A1,A2,O)), holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), not holds(N,have(A1,O)).
:- occurs(N,show(A1,A2,O)), holds(N, dead(A1)).
:- occurs(N,show(A1,A2,O)), holds(N, dead(A2)).

:- occurs(N,fight_with(A1,A2)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,fight_with(A1,A2)), not positiveCharacter(A1).
:- occurs(N,fight_with(A1,A2)), not negativeCharacter(A2).
:- occurs(N,fight_with(A,A)).
:- occurs(N,fight_with(A1,A2)), holds(N,inBattle(A1,A2)).
:- occurs(N,fight_with(A1,A2)), holds(N, dead(A1)).
:- occurs(N,fight_with(A1,A2)), holds(N, dead(A2)).

:- occurs(N,defeat(A1,A2)), not holds(N,inBattle(A1,A2)).
:- occurs(N,defeat(A1,A2)), not holds(N,dead(A2)). 

:- occurs(N,curse(A,A)).
:- occurs(N,curse(A1,A2)), not traitor(A1).
:- occurs(N,curse(A1,A2)), not hero(A2).
:- occurs(N,curse(A1,A2)), holds(N,cursed(A2)).
:- occurs(N,curse(A1,A2)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,curse(A1,A2)), holds(N, dead(A1)).
:- occurs(N,curse(A1,A2)), holds(N, dead(A2)).

:- occurs(N,cure(A,A)).
:- occurs(N,cure(A1,A2)), not holds(N,cursed(A2)).
:- occurs(N,cure(A1,A2)), traitor(A1).
:- occurs(N,cure(A1,A2)), holds(N,actorAt(A1,L1)), holds(N,actorAt(A2,L2)), L1!=L2.
:- occurs(N,cure(A1,A2)), holds(N, dead(A1)).
:- occurs(N,cure(A1,A2)), holds(N, dead(A2)).

:- occurs(N,attack(A1,A2,O)), not holds(N,inBattle(A1,A2)), not holds(N,inBattle(A2,A1)).
:- occurs(N,attack(A1,A2,O)), not holds(N,have(A1,O)).
:- occurs(N,attack(A1,A2,O)), not dodgeable(O).
:- occurs(N,attack(A1,A2,O)), holds(N,dead(A1)).
:- occurs(N,attack(A1,A2,O)), holds(N,dead(A2)).

:- occurs(N,hit(A1,A2,O)), not holds(N,attackedBy(A1,A2,O)).
:- occurs(N,hit(A1,A2,O)), holds(N,dead(A2)).

:- occurs(N,dodge(A1,A2,O)), not holds(N,attackedBy(A2,A1,O)).
:- occurs(N,dodge(A1,A2,O)), holds(N, dead(A1)).

:- occurs(N,marry(A,A)).


%===============================================================================
%                              ACTIONS DESCRIPTION
%===============================================================================
-holds(N+1, actorAt(A,L)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 holds(N+1, actorAt(A,L1)) :- occurs(N, move_to(A,L1)), holds(N,actorAt(A,L)), state(N).
 
 holds(N+1, isMarked(A2)) :- occurs(N, mark(A1,A2)), state(N).
 
 holds(N+1, captured(A1,A2)) :- occurs(N, capture(A1,A2)), state(N).
-holds(N+1, captured(A1,A2)) :- occurs(N, defeat(A3,A1)), actor(A2), state(N).
 holds(N+1, actorAt(A2,L)) :- occurs(N, capture(A1,A2)), on(A1,L), state(N).
-holds(N+1, actorAt(A2,L)) :- occurs(N, capture(A1,A2)), not on(A1,L), location(L), state(N).
 holds(N+1, actorAt(A1,L)) :- occurs(N, capture(A1,A2)), on(A1,L), state(N).
-holds(N+1, actorAt(A1,L)) :- occurs(N, capture(A1,A2)), not on(A1,L), location(L), state(N).
 
 holds(N+1, inBattle(A1,A2)) :- occurs(N, fight_with(A1,A2)), state(N).
-holds(N+1, inBattle(A1,A2)) :- occurs(N, defeat(A1,A2)), state(N).
 
 holds(N+1, have(A2,O)) :- occurs(N, mark(A1,A2)), sObject(O), state(N), holds(N,have(A1,O)).
 holds(N+1, have(A,O)) :- occurs(N, take(A,O)), state(N).
 
-holds(N+1, have(A1,O)) :- occurs(N, give(A1,A2,O)), state(N).
 holds(N+1, have(A2,O)) :- occurs(N, give(A1,A2,O)), state(N).
 
 holds(N+1,cursed(A2)) :- occurs(N,curse(A1,A2)), state(N).
-holds(N+1,cursed(A2)) :- occurs(N,cure(A1,A2)), state(N).
 
 holds(N+1, saw(A2, Act)) :- occurs(N, tell_to(A1,A2,Act)), state(N).
 holds(N+1, saw(A1,defeat(A1,A2))) :- occurs(N, defeat(A1,A2)), state(N).
 holds(N+1, saw(A3,defeat(A1,A2))) :- occurs(N, defeat(A1,A2)), holds(N,actorAt(A3,L)), holds(N,actorAt(A1,L)), state(N).
 holds(N+1, saw(A1, capture(A2,A3))) :- occurs(N, capture(A2,A3)), holds(N,actorAt(A1,L)), holds(N,actorAt(A2,L)), A1!=A2, A1!=A3, state(N).

 holds(N+1, live(A2,L-50)) :- occurs(N, hit(A1,A2,O)), holds(N, live(A2,L)).
-holds(N+1, live(A2,L)) :- occurs(N, hit(A1,A2,O)), holds(N, live(A2,L)).
 holds(N+1, dead(A2)) :- occurs(N, hit(A1,A2,O)), holds(N, live(A2,L)), L<=50.
 
 holds(N+1, attackedBy(A1,A2,O)) :- occurs(N,attack(A1,A2,O)).  
-holds(N+1, attackedBy(A1,A2,O)) :- holds(N,attackedBy(A1,A2,O)).

 holds(N+1, married(A1,A2)) :- occurs(N, marry(A1,A2)), state(N).
   

%===============================================================================
%                                COST DESCRIPTION
%===============================================================================
-holds(N+1,score(P)) :- holds(N,score(Q)), Q > P, state(N), cost(P), cost(Q).
 
%when one or two actor perform two same action which result of second action is same as before preforming first action score will decrease
 holds(N+2, score(S-1)) :- occurs(N+1, move_to(A,L1)), occurs(N, move_to(A,L2)), holds(N+1, score(S)), holds(N,actorAt(A,L1)), state(N).
 holds(N+2, score(S-1)) :- occurs(N+1, give(A1,A2,O)), occurs(N, give(A2,A1,O)), holds(N+1, score(S)), state(N).
 
%when one actor perform two different action then score will increase because one actor performing these two action thus it develop storyline
 holds(N+2, score(S+2)) :- occurs(N+1, take(A,O)), occurs(N, move_to(A,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+1)) :- occurs(N+1, give(A1,A2,O)), occurs(N, move_to(A1,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+1)) :- occurs(N+1, give(A2,A1,O)), occurs(N, move_to(A1,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+1)) :- occurs(N+1, tell_to(A1,A2,Act)), occurs(N, move_to(A1,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+1)) :- occurs(N+1, tell_to(A2,A1,Act)), occurs(N, move_to(A1,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+1)) :- occurs(N+1, capture(A1,A2)), occurs(N, move_to(A1,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+1)) :- occurs(N+1, capture(A1,A2)), occurs(N, move_to(A2,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+2)) :- occurs(N+1, cure(A1,A2)), occurs(N, move_to(A1,L)), holds(N+1, score(S)), state(N).
 holds(N+2, score(S+2)) :- occurs(N+1, cure(A1,A2)), occurs(N, give(A2,A1,O)), holds(N+1, score(S)), state(N).
 
 holds(N+1, score(S+7)) :- occurs(N, hit(A1,A2,O)), holds(N, score(S)), state(N). 
 holds(N+1, score(S+6)) :- occurs(N, dodge(A1,A2,O)), holds(N, score(S)), state(N). 
 holds(N+1, score(S+3)) :- occurs(N, curse(A1,A2)), holds(N, score(S)), state(N).  


%===============================================================================
%                                     GOAL
%===============================================================================
absentation :- holds(N,actorAt(A1, L)), not homeEnviroment(A1, L), hero(A1), N > 0, N <= a, 
                holds(N, score(M)), cost(M), M > 0.
                
violation :- holds(N,actorAt(A1, L)), homeEnviroment(A1, L), holds(N,captured(A1,A3)), 
              villain(A1), princess(A3), holds(N,saw(A2,capture(A1,A3))), questGiver(A2), 
              holds(N,actorAt(A2, L2)), homeEnviroment(A2,L2), N>a, N<=b, holds(N, score(M)), 
              cost(M), M >= 3.
              
transproposal :- holds(N, actorAt(A1,L)), holds(N, actorAt(A2,L)), hero(A1), questGiver(A2), 
                  holds(N, saw(A2,capture(A3,A4))), holds(N, saw(A1,capture(A3,A4))), villain(A3), 
                  homeEnviroment(A2,L), N>b, N<=c, holds(N, score(M)), cost(M), M > 0.
                  
ffdonor :- holds(d, actorAt(A1,L)), holds(d, actorAt(A2,L)), holds(d, have(A1,O)), hero(A1), 
            donor(A2), homeEnviroment(A2,L), holds(M, have(A2,O)), state(M), M<d, holds(d, score(S)), 
            cost(S), S >= 4. 
            
guidance :- holds(e, actorAt(A1,L)), holds(e, actorAt(A2,L)), hero(A1), villain(A2), homeEnviroment(A2,L), 
            holds(e, score(S)), cost(S), S >= 6, holds(e,have(A2,O)), on(O,cave).
            
struggle :- holds(f, actorAt(A1,L)), holds(f, actorAt(A2,L)), holds(f, inBattle(A1,A2)), hero(A1), 
            villain(A2), homeEnviroment(A2,L), holds(f, score(S)), cost(S), S >= 13.
            
branding :- holds(N, actorAt(A1,L)), holds(N, actorAt(A2,L)), holds(N, isMarked(A1)), holds(N, inBattle(A1,A2)),
             hero(A1), villain(A2), homeEnviroment(A2,L), N > f, N <= g. 
              
victory :- holds(N, actorAt(A1,L)), holds(N, actorAt(A2,L)), -holds(N, inBattle(A1,A2)), hero(A1), 
            villain(A2), homeEnviroment(A2,L), N > g, N <= h, holds(h, score(S)), cost(S), S >= 32.
            
return :- holds(N, actorAt(A1,L)), hero(A1), homeEnviroment(A1,L), not holds(i,cursed(A1)), N > h, N <= i, 
            holds(i, score(S)), cost(S), S >= 37.

unfoundedclaims :-  holds(j, actorAt(A1,L)), holds(j, actorAt(A2,L)), holds(j, actorAt(A3,L)), holds(j, actorAt(A4,L)), 
                      hero(A1), fHero(A2), princess(A3), dispatcher(A4), occurs(j-1, tell_to(A1,A4,defeat(A1,A5))),
                      state(N), N<j, holds(N, saw(A4,defeat(A2,A5))), homeEnviroment(A4,L).

recognition :-  holds(k, actorAt(A1,L)), holds(k, actorAt(A2,L)), hero(A1), dispatcher(A2), occurs(k-1, show(A1,A2,O)), 
                  homeEnviroment(A2,L).
                  
wedding :- holds(l, actorAt(A1,L)), holds(l, actorAt(A2,L)), hero(A1), princess(A2),
             holds(l, married(A1,A2)), homeEnviroment(A2,L).
           
:- not absentation.
:- not violation.
:- not transproposal.
:- not ffdonor.
:- not guidance.
:- not struggle.
:- not branding.
:- not victory.
:- not return.
:- not unfoundedclaims.
:- not recognition.
:- not wedding.
