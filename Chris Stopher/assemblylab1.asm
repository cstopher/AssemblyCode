*PORT ADDRESSES
PORTB EQU $1004 
PORTC EQU $1003 
*DATA DIRECTION REGISTER for PORTC
DDRC EQU $1007
*START of PROGRAM
      ORG $D000
START LDS #$01FF 
      LDAA #$00
      STAA DDRC 
      LDAA PORTC 
      STAA $0000 
      STAA PORTB 
      NOP
      LDAA PORTC 
      STAA PORTB 
      NOP
      ADDA $0000 
      STAA PORTB 
      NOP
      BRA $ 
      ORG $FFFE 
      FDB START
