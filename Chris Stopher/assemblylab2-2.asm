*PORT ADDRESSES
PORTB EQU $1004 ; 7-Segment display
PORTC EQU $1003  ; Logic switches
*DATA DIRECTION REGISTER for PORTC
DDRC EQU $1007

*START OF PROGRAM
      ORG $D000
START LDS #$01FF ;Initialize stack pointer (stack is used for temporary storage when using subroutines).
      CLRA ;Configure Port C as an input port (optional -
      STAA DDRC ; this is the default on reset).
      LDAA PORTC ;Load value from Port C
      STAA $0000 ;Store value at address 0000h.
      LDAA #$01 ;Immidiate load from Memory location 01
LOOP1 STAA PORTB;Output value to 7-segment display,
      JSR DELAY ; delay so output can be seen,
      ADDA #$01 ;Adds a second value
      DAA  ;Decimal Adjust A
      CMPA $0000 ;Compare A to memory 0000
      BNE LOOP1 ; and continue to display
      STAA PORTB ; till zero.
      BRA $

*SUBROUTINE for DELAY BETWEEN OUTPUTS

DELAY LDY #$0008
DELAY1 LDX #$8000
DELAY2 DEX
      BNE DELAY2
      DEY
      BNE DELAY1
      RTS
      ORG $FFFE ;Reset vector used when press reset button.
      FDB START ;Takes to 1st line of program code when reset vector has been reset.
