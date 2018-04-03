### Traps Records

1. pushf before call the origin interruption.
2. the int 16h will change ds and so on in the process but restore them at last, so assign the segment registers and general registers in int 9h and save all the registers.
3. the IF and TF is originally set to 0(closed)