------------------------------ MODULE tutorial2 ------------------------------- 
EXTENDS Naturals, TLC
(*--algorithm prog 
variables 
    a = 0; 
    critical_section = 0;
    temp;

process Left=0
begin
    L1: temp := a + 1;
    L2: a := temp;
    L3: if a = 1 then 
        critical_section := critical_section + 1;
        L4: critical_section := critical_section - 1;
    end if
end process

process Right=1
begin
    L1: temp := a + 1;
    L2 : a := temp;
    L3: if a = 1 then 
        critical_section := critical_section + 1;
        L4: critical_section := critical_section - 1;
    end if
end process

end algorithm;*)
\* BEGIN TRANSLATION (chksum(pcal) = "9496b0fe" /\ chksum(tla) = "cf75ec02")
\* Label L1 of process Left at line 11 col 9 changed to L1_
\* Label L2 of process Left at line 12 col 9 changed to L2_
\* Label L3 of process Left at line 13 col 9 changed to L3_
\* Label L4 of process Left at line 15 col 13 changed to L4_
CONSTANT defaultInitValue
VARIABLES a, critical_section, temp, pc

vars == << a, critical_section, temp, pc >>

ProcSet == {0} \cup {1}

Init == (* Global variables *)
        /\ a = 0
        /\ critical_section = 0
        /\ temp = defaultInitValue
        /\ pc = [self \in ProcSet |-> CASE self = 0 -> "L1_"
                                        [] self = 1 -> "L1"]

L1_ == /\ pc[0] = "L1_"
       /\ temp' = a + 1
       /\ pc' = [pc EXCEPT ![0] = "L2_"]
       /\ UNCHANGED << a, critical_section >>

L2_ == /\ pc[0] = "L2_"
       /\ a' = temp
       /\ pc' = [pc EXCEPT ![0] = "L3_"]
       /\ UNCHANGED << critical_section, temp >>

L3_ == /\ pc[0] = "L3_"
       /\ IF a = 1
             THEN /\ critical_section' = critical_section + 1
                  /\ pc' = [pc EXCEPT ![0] = "L4_"]
             ELSE /\ pc' = [pc EXCEPT ![0] = "Done"]
                  /\ UNCHANGED critical_section
       /\ UNCHANGED << a, temp >>

L4_ == /\ pc[0] = "L4_"
       /\ critical_section' = critical_section - 1
       /\ pc' = [pc EXCEPT ![0] = "Done"]
       /\ UNCHANGED << a, temp >>

Left == L1_ \/ L2_ \/ L3_ \/ L4_

L1 == /\ pc[1] = "L1"
      /\ temp' = a + 1
      /\ pc' = [pc EXCEPT ![1] = "L2"]
      /\ UNCHANGED << a, critical_section >>

L2 == /\ pc[1] = "L2"
      /\ a' = temp
      /\ pc' = [pc EXCEPT ![1] = "L3"]
      /\ UNCHANGED << critical_section, temp >>

L3 == /\ pc[1] = "L3"
      /\ IF a = 1
            THEN /\ critical_section' = critical_section + 1
                 /\ pc' = [pc EXCEPT ![1] = "L4"]
            ELSE /\ pc' = [pc EXCEPT ![1] = "Done"]
                 /\ UNCHANGED critical_section
      /\ UNCHANGED << a, temp >>

L4 == /\ pc[1] = "L4"
      /\ critical_section' = critical_section - 1
      /\ pc' = [pc EXCEPT ![1] = "Done"]
      /\ UNCHANGED << a, temp >>

Right == L1 \/ L2 \/ L3 \/ L4

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

