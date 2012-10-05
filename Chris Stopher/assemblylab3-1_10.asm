*PORT ADDRESS
PORTA EQU $1000 ;pushbutton/speaker
*PARAMETER
NCYCLE EQU !8000
*START
       ORG $D000
START  LDS #$01FF ;Initialize stack pointer
       LDX #PORTA
POLL1  BRCLR $00,X,$01,POLL1
POLL2  BRSET $00,X,$01,POLL2
       JSR TONE   ;go to tone subroutine
       BRA POLL1  ;after the tone go to POLL1 and wait for button to be pushed again

;TONE SUBROUTINE (625 Hz)
TONE   LDY #NCYCLE ;load x with number of cycles
TONE1  BSET $00,X,$10   ;load value in accum X with 10 for a counter
       JSR TDLY    ;start the delay loop to make the tone last longer
       BRN $       ;branch never for delay purposes
       NOP
       NOP
       BCLR $00,X,$10
       JSR TDLY    ;start delay loop to make tone last longer
       DEY         ;decrement the LDX counter
       BNE TONE1   ;if tone is still active high branch
       RTS         ;return out of subroutine and back into main body of program

;DELAY LOOP (for Tone Subroutine)
TDLY   PSHX        ;pushes whatever is in x onto the stack
       PSHY        ;pushes whatever is in y onto the stack
       LDX #!16    ;loads decimal value 16 onto register x
DEL1   LDY #!12    ;loads decimal value 12 onto register y
DEL2   DEY         ;decrements y starting from decimal value 12
       BNE DEL2    ;until y goes to 0 the program will continue to branch
       BRN $       ;branch never for delay purposes
       DEX         ;decrements x starting from decimal value 16
       BNE DEL1    ;until x goes to 0 the program will continue to branch
       PULY        ;pulls y from the stack which would be what we original pushed onto the stack
       PULX        ;pulls x from stack
       RTS         ;returns to the tone subroutine

       ORG $FFFE
       FDB START
