*PORT ADDRESS
PORTA EQU $1000 ;pushbutton/speaker
PORTB EQU $1004 ; 7-Segment display/LED
PORTC EQU $1003 ; LED
PORTE EQU $100A ; LOGIC SWITCHES

*DATA DIRECTION REGISTER for PORTC
DDRC EQU $1007

*PARAMETER
NCYCLE EQU !250

*START
       ORG $D000
START  LDS #$01FF ;Initialize stack pointer

       CLRA
       LDAA #$FF
       STAA DDRC

       LDAA $0000
       STAA PORTB
       JSR DELAY
       JSR TONE

       LDAA $0001
       STAA PORTB
       JSR DELAY
       JSR TONE

       ADDA $0000
       DAA
       STAA $000E
       LDAA #$00
       ADCA #$00
       STAA $0015
       LDAA $0002
       STAA PORTB
       JSR DELAY
       JSR TONE

       ADDA $000E
       DAA
       STAA $000F
       LDAA #$00
       ADCA $0015
       STAA $0016
       LDAA PORTE
       STAA $0003
       STAA PORTB
       JSR DELAY
       JSR TONE
       ADDA $000F
       DAA
       STAA $0010
       LDAA #$00
       ADCA $0016
       STAA $0017 
       LDAA $0010
       STAA PORTB ;Output value to 7-segment display,
       JSR DELAY
       JSR TONE
       LDAA $0017
       STAA PORTC ; output carry(msb) to led's
       BNE DTONE
       JSR TONE
       JSR DELAY
       JSR TONE
DTONE  JSR TONE




POLL1  LDAB PORTA ;load value from port a
       ANDB  #$01 ;masks lcb
       BEQ    POLL1;branch while pushbutton is not pushed
POLL2  LDAB PORTA ;load value from port a;
       BITB #$01  ;masks lcb but does not store it
       BNE POLL2  ;when button is pushed branch
       JSR TONE   ;go to tone subroutine
       BRA POLL1  ;after the tone go to POLL1 and wait for button to be pushed again

;TONE SUBROUTINE (625 Hz)
TONE   LDX #NCYCLE ;load x with number of cycles
TONE1  LDAB #$10   ;load value in accum b with 10 for a counter
       STAB PORTA  ;store value in port a in accum b
       JSR TDLY    ;start the delay loop to make the tone last longer
       BRN $       ;branch never for delay purposes
       BRN $       ;branch never for delay purposes
       NOP
       NOP
       LDAB #$00   ;load accum b with 00
       STAB PORTA  ;then store that value into port a
       JSR TDLY    ;start delay loop to make tone last longer
       DEX         ;decrement the LDX counter
       BNE TONE1   ;if tone is still active high branch
       RTS         ;return out of subroutine and back into main body of program

;DELAY LOOP (for Tone Subroutine)
TDLY   PSHX        ;pushes whatever is in x onto the stack
       PSHY        ;pushes whatever is in y onto the stack
       LDX #!259    ;loads decimal value 16 onto register x
DEL1   DEX         ;decrements x starting from decimal value 16
       BNE DEL1    ;until x goes to 0 the program will continue to branch
       NOP         ;increase delay 2 clock cycles
       PULY        ;pulls y from the stack which would be what we original pushed onto the stack
       PULX        ;pulls x from stack
       RTS         ;returns to the tone subroutine
       

*SUBROUTINE for DELAY BETWEEN OUTPUTS

DELAY  LDY #$0008
DELAY1 LDX #$8000
DELAY2 DEX
       BNE DELAY2
       DEY
       BNE DELAY1
       RTS


       ORG $FFFE
       FDB START



