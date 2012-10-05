*PORT ADDRESS
PORTA EQU $1000 ;pushbutton/speaker
PORTB EQU $1004 ; 7-Segment display
PORTC EQU $1003 ; LED
PORTE EQU $100A ; LOGIC SWITCHES

*DATA DIRECTION REGISTER for PORTC
DDRC EQU $1007

*PARAMETER
NCYCLE EQU !250
bcdf   EQU $0000   ;bcd flag: 0=not bcd, 1=bcd
d1     EQU $0001
d0     EQU $0002
btoh   EQU $0031

*START
       ORG $D000

START  LDS #$01FF ;Initialize stack pointer
       cli
       CLRA
       CLR  BCDF  ;bcdf=0, not bcd; 1, bcd
       LDAA #$FF
       STAA DDRC




POLL0  LDAB PORTA ;load value from port a
       ANDB  #$01 ;masks lcb
       BEQ    POLL0;branch while pushbutton is not pushed
POLL1  LDAB PORTA ;load value from port a;
       BITB #$01  ;masks lcb but does not store it
       BNE POLL1  ;when button is pushed branch
       LDAA PORTE
       STAA $0007
       TAB
       ANDA #$0F
       STAA d0
       CMPA #$09
       BHI  notbcd
bcd0   andb #$f0
       stab d1
       cmpb #$90
       bhi  notbcd
bcd1   inc  bcdf
       ldaa $0007
       anda #$0F
       bne  less
       jsr shift
       ldaa #$00
       beq  d0ez
d0ez   ldab $0008
       staa portb
       JSR  DELAY3
       adda $0008
       daa
       tab
       cmpa $0007
       bls  d0ez
       bra end
       ldaa #$00
less   staa portb
       JSR  DELAY3
       adda d0
       daa
       cmpa $0007
       bls  less
end    bra start
;end    bra $



**********************************************
* code for task if not bcd
**********************************************
notbcd                          ;input is not bcd
        JSR DELAY
	JSR TONE           ; do task of your choice
        LDAA $0007
	STAA PORTC
	JSR DELAY3
	LDAA #$00
        STAA PORTC
	JSR DELAY
	JSR TONE

        bra end

;shift subroutine
shift  ldaa d1
       lsr d1
       lsr d1
       lsr d1
       lsr d1
       ldaa d1
       staa $0008
       tab
       rts

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

*SUBROUTINE for DELAY2 BETWEEN OUTPUTS

DELAY3  LDY #$0009
DELAY4 LDX #$8000
DELAY5 DEX
       BNE DELAY5
       DEY
       BNE DELAY4
       RTS

;deccon2
decon2
	staa porte
	clra
	ldx #$0A
	idiv
	std $0038
	stx $0040
	jsr shiftd
	ldaa $0041
	jsr shiftd
	staa $0043
	staa $0044
	rts

;shiftd subroutine
shiftd
	 lsld
	 lsld
	 lsld
	 lsld
	 rts

;count down subroutine
cdown

	cmpa $000E
	bhi  dechi
	rts

;decimal higher than hex

dechi  ANDA #$0F
       STAA d0
       bne  subb
       ldaa $0043
       staa d1
       jsr shift
       staa d1
       ldaa $0043
       staa portb
       jsr  delay3
sub3   staa portb
       jsr delay3
       ldaa #$99
       suba d1
       sec
       adca $0043
       daa
       staa $0043
       cmpa $000E
       bhs  sub3
       bra  end2

subb   ldab d0
       ldaa $0043
       staa portb
       jsr delay3
sub2   staa portb
       jsr delay3
       ldaa #$99
       suba d0
       sec
       adca $0043
       daa
       staa $0043
       cmpa $000E
       bhs  sub2
       bra  end2
end2   rts

;interrupt tone subroutine
isound
	JSR TONE
	ldaa $000E
	staa portc
	jsr delay3
	clra
	staa portc
	bra back


;interrupt routine pb1
inter
POLL4  LDAB PORTA ;load value from port a;
       BITB #$02  ;masks lcb but does not store it
       BNE POLL4  ;when button is pushed branch
       ldaa porte
       staa $000E
       TAB
       CMPA #$10
back   blo  isound
       cmpb #$63
       bhi  isound
       ldaa $000E
       staa porte
       staa $0043
       jsr  decon2
       jsr  cdown
       rti
       
       org $fff2
       fdb inter
             
       ORG $FFFE
       FDB START






