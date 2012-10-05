;Project number 4
;Expirment 2
;Group 3 - Roberto, Chris
;10/2/2012
;Used code from Doctor Horiwitz's in class interrupt
;example. Also used code from BCD subtraction from
;doctor Horiwitz.
**********************************************
* Port Addresses							 *
**********************************************
PORTA 	EQU $1000 ;pushbutton/speaker
PORTB 	EQU $1004 ; 7-Segment display
PORTC 	EQU $1003 ; LED
PORTE 	EQU $100A ; LOGIC SWITCHES
**********************************************
* Data Direction Register for PortC			 *
**********************************************
DDRC 	EQU $1007
**********************************************
* Parameter									 *
**********************************************
NCYCLE 	EQU !250
bcdf   	EQU $0000   ;bcd flag: 0=not bcd, 1=bcd
d1     	EQU $0001   ;d1 of d1d0
d0     	EQU $0002   ;d0 of d1
btoh   	EQU $0031   
**********************************************
* Start										 *
**********************************************
		ORG $D000
**********************************************
* Initilization step's						 *
**********************************************
START  	LDS #$01FF ;Initialize stack pointer
		cli		  ;enable interrupts
		CLRA
		CLR  BCDF  ;bcdf=0, not bcd; 1, bcd
		LDAA #$FF  ;set portc as output instead of input
		STAA DDRC  
**********************************************
* Background routine						 *
**********************************************
POLL0  	LDAB PORTA ;load value from port a
		ANDB  #$01 ;masks lcb
		BEQ    POLL0;branch while pushbutton is not pushed
POLL1  	LDAB PORTA ;load value from port a;
		BITB #$01  ;masks lcb but does not store it
		BNE POLL1  ;when button is pushed branch
		LDAA PORTE
		STAA $0007 ;if switches equal zero branch to
		beq  notbcd;notbcd
		TAB
		ANDA #$0F ;mask the 4 lsb's to store the lsb's
		STAA d0   ;in d0
		CMPA #$09 ; if d0 is higher than 9 branch to
		BHI  notbcd ;notbcd
bcd0   	andb #$f0 ;mask the 4 msb's to store the msb's 
		stab d1	 ;in d1
		cmpb #$90 ;if d1 is higher than 9 branch to
		bhi  notbcd ;notbcd
bcd1   	inc  bcdf   ;sets bcdf flag to 1 if you have a
		ldaa $0007  ;valid bcd number
		anda #$0F   ;masks the lsb's and branches to less
		bne  less   ;if d0 is not equal to zero
		jsr shift   ;jump to shift subroutine
		ldaa #$00   ;if d0 is equal to zero
		beq  d0ez   ;branch to d0ez
d0ez   	ldab $0008  ;display zero on the
		staa portb  ;7-segment display then
		JSR  DELAY3 ;delay and add
		adda $0008  ;d1 to zero
		daa         ;decimal adjust for bcd
		tab		   ;compare d1 to switch value
		cmpa $0007  ;if d1 is less than the switch
		bls  d0ez   ;value loop to d0ez and continue count up 
		bra end     ;until a acumm is greater then switch value
		ldaa #$00   ;branch to end which brances to start
less   	staa portb ;display switch value in 
		JSR  DELAY3 ;7-segment display
        adda d0     ;add d0 to value
		daa	       ;decimal adjust for bcd
		cmpa $0007  ;compare to switch value
		bls  less   ;if count up is lower branch to less
end    	bra start   ;else branch to start
**********************************************
* code for task if not bcd                   *
**********************************************
notbcd	JSR DELAY	;if not bcd display 	
	    JSR TONE    ;delay then set      
        LDAA $0007  ;the tone then
	    STAA PORTC  ;display the notbcd
		JSR DELAY3  ;on the led's then
		LDAA #$00   ;delay then clear
        STAA PORTC  ;the led's and sound
		JSR DELAY   ;the tone again
		JSR TONE    ;then branch to end
        bra end		;which branches to start
**********************************************
* D1 Shift Subroutine						 *
**********************************************
shift  	ldaa d1 ;shift d1 4 times 
		lsr d1  ;to the right so
		lsr d1  ;that d1 is now 
		lsr d1  ;in the d0 location
		lsr d1  ;then store that 
		ldaa d1 ;in acumb and
		staa $0008 ;return to 
		tab		  ;subroutine
		rts
**********************************************
* TONE SUBROUTINE (625 Hz)				     *
**********************************************
TONE   	LDX #NCYCLE ;load x with number of cycles
TONE1  	LDAB #$10   ;load value in accum b with 10 for a counter
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
**********************************************
* Delay Loop (for Tone Subroutine)			 *
**********************************************
TDLY   	PSHX        ;pushes whatever is in x onto the stack
		PSHY        ;pushes whatever is in y onto the stack
		LDX #!259    ;loads decimal value 16 onto register x
DEL1   	DEX         ;decrements x starting from decimal value 16
		BNE DEL1    ;until x goes to 0 the program will continue to branch
		NOP         ;increase delay 2 clock cycles
		PULY        ;pulls y from the stack which would be what we original pushed onto the stack
		PULX        ;pulls x from stack
		RTS         ;returns to the tone subroutine
**********************************************
* SUBROUTINE for Delay Between Outputs		 *
**********************************************
DELAY  	LDY #$0008 ;delay from tone subroutine
DELAY1 	LDX #$8000
DELAY2 	DEX
		BNE DELAY2
		DEY
		BNE DELAY1
		RTS
**********************************************
* SUBROUTINE for Delay2 Between Outputs		 *
**********************************************
DELAY3 	LDY #$0009 ;delay for tone burst
DELAY4 	LDX #$8000
DELAY5 	DEX
		BNE DELAY5
		DEY
		BNE DELAY4
		RTS
**********************************************
* SUBROUTINE for decimal conversion  		 *
**********************************************
decon2 	staa porte 
		clra
		ldx #$0A ;divide switch value by 0A
		idiv     ;quotient ends up in x
		std $0038;remainder ends up in d
		stx $0040; jump to shiftd subroutine
		jsr shiftd; shift d 4 places
		ldaa $0041;load 4 lsb's from x to a
		jsr shiftd;then shift d 4 places again
		staa $0043;then return to subroutine
		staa $0044
		rts
**********************************************
* SUBROUTINE for Shifting D accumulator		 *
**********************************************
shiftd  lsld ;shifting d left 4 places
		lsld
		lsld
		lsld
		rts
**********************************************
* SUBROUTINE Count Down in interrupt		 *
**********************************************
cdown	cmpa $000E;compare decimal with dex value
		bhi  dechi;branch to dechi when decimal is higher
		rts ;return to interrupt subroutine1
**********************************************
* SUBROUTINE for decimal higher than hex     *
**********************************************
dechi  	ANDA #$0F ;mask and store
		ldaa d0   ;d0
		bne  subb ;if d0 is not zero branch to subb
		ldaa $0043;if d0 is zero
		staa portb;display value on 7-seg
		jsr  delay3;then delay.
sub3   	staa portb;start sub3 loop 
		jsr delay3;display value on 7-seg
		ldaa #$99 ;do BCD subtraction by d1
		suba d1   ;the same d1 in bkgroutine
		sec		  ;keep comparing value to switch
		adca $0043;values as long is decimal value
		daa		  ;is higher than hex value.
		staa $0043;if decimal value is not higher than
		cmpa $000E;or equal to the switch value
		bhs  sub3 ;terminate loop and return to
		bra  end2 ;interrupt subroutine1.
subb   	ldab d0    ;display decimal
		ldaa $0043 ;in 7-segement display
		staa portb ;then delay
		jsr delay3 ;start the sub2
sub2   	staa portb ;loop. Display
		jsr delay3 ;decimal on 7-seg
		ldaa #$99  ;then do BCD subtraction
		suba d0	   ;by the d0 in bkgroutine each time through loop
		sec		   ;keep comparing value to switch values
		adca $0043 ;as long as decimal is higher keep going
		daa 	   ;through loop when decimal is lower
		staa $0043 ;terminate loop and
		cmpa $000E ;and return to interrupt subroutine1
		bhs  sub2
		bra  end2
end2   	rts
**********************************************
* Branch for Tone2 Interrupt Subroutine2     *
**********************************************
isound2	JSR TONE ;sound subroutine for interrupt
		ldaa $000E;subroutine2.
		staa portc;It tones outputs to led's
		jsr delay3;clears led's then jumps back to
		clra	  ;endpb
		staa portc
		jmp endpb
**********************************************
* SUBROUTINE for pb2 interrupt				 *
**********************************************
inter2
POLL7  	LDAB PORTA ;load value from port a
		ANDB  #$04 ;masks lcb
		BNE POLL7  ;branch while pushbutton is not pushed
POLL5  	LDAB PORTA ;load value from port a;
		BITB #$04  ;masks lcb but does not store it
		BEQ POLL5  ;when button is pushed branch
		ldaa porte ;when switch value is equal to
		staa $000E ;zero branch to notbcd2.
		beq  notbcd2
		TAB
		anda #$0f	;mask's lsb's stores value
		staa d0		;in d0
		cmpa #$09	;compare d0 to 9
		BHI  notbcd2;if d0 is higher than 9 branch
		andb #$f0	;to notbcd2.
		stab d1		;do the same for d1
		cmpb #$90   ;compare d1 to $90 if higher
		bhi  notbcd2;branch to notbcd
		ldaa $000E  ;output switch value to
		staa porte	;7-segment display
		staa $0043	;then jump to the 
		jsr  BCDT	;BCDT subroutine.
		ldaa $000E  ;Then compares the switch
		cmpa $0054	;value to the transpose value
		bhi  bhigh	;branchs if switch value is higher
		bra  blow	;else branches to blow
bhigh  	staa portb	;starts bhigh loop
		jsr  delay3 ;displays the switch value on 7-seg
		ldaa $0054  ;displays the transpose value on 
		staa portb 	;7-seg display then delays
		jsr  delay3	;then display 0d1 on 7-seg
		anda #$0f	;then displays 0d0 on 7-seg.
		staa portb	;then branches to rts which
		jsr  delay3 ;branches to rti
		ldaa $000E
		anda #$0f
		staa portb
		jsr  delay3
		bra endpb
blow   	ldaa $0054 ;starts blow loop
		staa portb ;displays the tranpose value
		jsr  delay3;on 7-seg display.
		ldaa $000E ;Then displays the switch vlaue
		staa portb ;on the 7-seg display.
		jsr  delay3;then display 0d1 on 7-seg
		ldaa $0054 ;then display 0d0 on 7-seg
		anda #$0f  ;then branches to rts 
		staa portb ;which branches to rti
		jsr  delay3
		ldaa $000E
		anda #$0f
		staa portb
		jsr  delay3
		bra endpb 
endpb  	rts
**********************************************
*Branch for notbcd2 						 *
**********************************************
notbcd2 JSR DELAY ;invalid bcd subroutine that
		JSR TONE  ;tones then loads value in led's
        LDAA $0007 ;then clears led's
		STAA PORTC ;then tones again
		JSR DELAY3
		LDAA #$00
        STAA PORTC
		JSR DELAY
		JSR TONE
        bra endpb
**********************************************
* SUBROUTINE for transpose					 *
**********************************************
trans   clrb	;transposes d1d0 to d0d1
		ldaa porte
		lsrd  
		lsrd  
		lsrd  
		lsrd  
		aba 
		staa $0054
		rts
**********************************************
* SUBROUTINE for BCDT						 *
**********************************************
BCDT   	ldd  porte ;loads switchs into d then
		jsr  trans ;jumps to trans subroutine
		rts
**********************************************
* SUBROUTINE for Interrupt ton pb1 subroutine*
**********************************************
isound	JSR TONE   ;tones then displays
		ldaa $000E ;invalid value on led's
		staa portc ;then clears led's
		jsr delay3
		clra
		staa portc
		bra back
**********************************************
* SUBROUTINE for pb2						 *
**********************************************
pb2		jsr  inter2 ;subroutine to jump to pb2 interrupt
		bra  endrti ;suproutine2.

**********************************************
* Interupt for interrupt subroutine1		 *
**********************************************
inter  	ldab porta ;determines whenter to go through subroutine1
		andb #$02  ;or subroutine2 before polling starts
		beq  poll4
		bra  pb2
POLL4  	LDAB PORTA ;load value from port a
		ANDB  #$02 ;masks lcb
		BNE POLL4  ;branch while pushbutton is not pushed
POLL6  	LDAB PORTA ;load value from port a;
		BITB #$02  ;masks lcb but does not store it
		BEQ POLL6  ;when button is pushed branch
		ldaa porte 
		staa $000E
		TAB
		beq  isound ;if switch values are zero branch
		CMPA #$10   ;if switch is less than 9 branch
back   	blo  isound ;to invalid isound subroutine
		cmpb #$63   ;else if switch values are greater than $63
		bhi  isound ;branch to invalid isound subroutine
		ldaa $000E	
		staa porte
		staa $0043
		jsr  decon2 ;jump to decimal conversion routine
		jsr  cdown  ;jump to countdown routine
endrti 	rti
       
       org $fff2	;interrupt reset vector
       fdb inter
             
       ORG $FFFE
       FDB START






