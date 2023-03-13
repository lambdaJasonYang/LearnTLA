------------------------------ MODULE tutorial2 ------------------------------- 
\* Below we show an example of bad specification,
\* it is bad because `a := a + 1` is assumed to be an atomic expression
EXTENDS Naturals, TLC
(*--algorithm prog 
variables 
    a = 0; 
    critical_section = 0;

process Left=0
begin
    L1: a := a + 1; \* <--- This is Bad 
    L2: if a = 1 then 
        critical_section := critical_section + 1;
        L3: critical_section := critical_section - 1;
    end if
end process

process Right=1
begin
    L1: a := a + 1; \* <--- This is Bad
    L2: if a = 1 then 
        critical_section := critical_section + 1;
        L3: critical_section := critical_section - 1;
    end if
end process

end algorithm;*)
\* BEGIN TRANSLATION (chksum(pcal) = "48bb4a48" /\ chksum(tla) = "2434b8da")
\* Label L1 of process Left at line 11 col 9 changed to L1_
\* Label L2 of process Left at line 12 col 9 changed to L2_
\* Label L3 of process Left at line 14 col 13 changed to L3_
VARIABLES a, critical_section, pc

vars == << a, critical_section, pc >>

ProcSet == {0} \cup {1}

Init == (* Global variables *)
        /\ a = 0
        /\ critical_section = 0
        /\ pc = [self \in ProcSet |-> CASE self = 0 -> "L1_"
                                        [] self = 1 -> "L1"]

L1_ == /\ pc[0] = "L1_"
       /\ a' = a + 1
       /\ pc' = [pc EXCEPT ![0] = "L2_"]
       /\ UNCHANGED critical_section

L2_ == /\ pc[0] = "L2_"
       /\ IF a = 1
             THEN /\ critical_section' = critical_section + 1
                  /\ pc' = [pc EXCEPT ![0] = "L3_"]
             ELSE /\ pc' = [pc EXCEPT ![0] = "Done"]
                  /\ UNCHANGED critical_section
       /\ a' = a

L3_ == /\ pc[0] = "L3_"
       /\ critical_section' = critical_section - 1
       /\ pc' = [pc EXCEPT ![0] = "Done"]
       /\ a' = a

Left == L1_ \/ L2_ \/ L3_

L1 == /\ pc[1] = "L1"
      /\ a' = a + 1
      /\ pc' = [pc EXCEPT ![1] = "L2"]
      /\ UNCHANGED critical_section

L2 == /\ pc[1] = "L2"
      /\ IF a = 1
            THEN /\ critical_section' = critical_section + 1
                 /\ pc' = [pc EXCEPT ![1] = "L3"]
            ELSE /\ pc' = [pc EXCEPT ![1] = "Done"]
                 /\ UNCHANGED critical_section
      /\ a' = a

L3 == /\ pc[1] = "L3"
      /\ critical_section' = critical_section - 1
      /\ pc' = [pc EXCEPT ![1] = "Done"]
      /\ a' = a

Right == L1 \/ L2 \/ L3

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == Left \/ Right
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 
DeadlockCondition == critical_section < 2 /\ critical_section >= 0
=============================================================================

