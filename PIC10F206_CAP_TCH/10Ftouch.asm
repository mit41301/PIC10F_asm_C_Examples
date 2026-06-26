;********************************************************
;* file: 10ftouch.asm                           ver 1.2 *
;* auth: m. flipse                                      *
;* date:                                                *
;*
;* modf: T. Perme
;* date: 24 March 2008
;* desc: 
;*
;* Software License Agreement
;*
;* The software supplied herewith by Microchip Technology
;* Incorporated (the "Company") is intended and supplied to you, the
;* Company’s customer, for use solely and exclusively on Microchip
;* products. The software is owned by the Company and/or its supplier,
;* and is protected under applicable copyright laws. All rights are
;* reserved. Any use in violation of the foregoing restrictions may
;* subject the user to criminal sanctions under applicable laws, as
;* well as to civil liability for the breach of the terms and
;* conditions of this license.
;*
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,
;* WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;*
;********************************************************

        processor pic10f206
        radix   dec

        include <p10f206.inc>
        include "Vars.inc"

gatedtime       equ     .33     	; time in msec that is used to measure the frequency

avdepth         equ     .5     		; averaging depth
                                	;    2 ^ (n-1) x oldvalue + newvalue
                                	; = ---------------------------------
                                	;               (2 ^ n)

; For Proximity
triplo_prx      equ     .16     	; difference between average and current
triphi_prx      equ     .0      	; frequency value for a key to be detected. (512 counts)
									; Smaller values have a more sensitive trip (good for proximity)
; For Touch
triplo_tch      equ     .50      	; difference between average and current
triphi_tch      equ     .1      	; frequency value for a key to be detected. (512 counts)
									; Smaller values have a more sensitive trip (good for proximity)

hysteresis      equ     .200    	; constant that is used to lower the averagevalue

                                	; when continuous touch is enabled

        __config  _intrc_osc & _wdt_on & _mclre_off & _cp_off
        


        org     .0      	        ; reset vector
reset
        movwf   osccal	            ; calibrate internal oscillator

		; If waking from intentional sleep, return back to post-sleep command
		; CWUF = 0, GPWUF = 0, TO = 0, PO = 0        STATUS BITS for wake from WDT
;		movf	STATUS, w
;		andlw	b'11111000'			; and off ALU status bits to zero
;		btfsc	STATUS, Z			; check if all bits are zero, branch accordingly
;		goto	jumpbackaftersleep	; all zero
;		goto	jumpinit			; non-zero

jumpbackaftersleep:
;		clrwdt						; Clr wdt, resetting PO and TO to 1 in status reg
;		goto	wake_from_sleep
		
jumpinit:		
        call    init				;  init the device if starting from power-up
        goto    main

;********************************************************
;* subroutine init                                      *
;********************************************************
;{
init    
        movlw   b'11110111'
              ;   ||||||||_ ps0
              ;   |||||||__ ps1
              ;   ||||||___ ps2   set prescaler to 1:256
              ;   |||||____ psa   prescaler assigned to tmr0
              ;   ||||_____ t0se  increment on high to low
              ;   |||______ t0cs  transition on t0cki
              ;   ||_______ #gppu pull-ups disabled
              ;   |________ #gpwu wake-up on pin change disabled
        option

        movlw   b'00001011'
              ;   ||||||||_ #cwu    wake-up on comp change disabled
              ;   |||||||__ cpref   pos ref is cin+
              ;   ||||||___ cnref   neg ref is internal 0.6V reference
              ;   |||||____ cmpon   comparator on
              ;   ||||_____ cmpt0cs comparator output used as tmr0 clock
              ;   |||______ pol     output is inverted
              ;   ||_______ #couten output is placed on cout pin
              ;   |________ cmpout  -read only bit-
        movwf   cmcon0

        movlw   b'11111001'     ; set gp1 and gp2 as an output
        tris    gpio

        clrf    averagehi
        clrf    averagelo
        clrf    averagefraction
        
        clrf    userflag

        retlw   .0
;}

;********************************************************
;* subroutine delay                                     *
;* descr: causes a timing delay in mSecs                *
;*                                                      *
;* in:    w - value in mSecs                            *
;********************************************************
;{
delay
        movwf   temp1
wait
        movlw   .249
        movwf   temp2
           clrwdt				; instead of nop, use clrwdt to clrwdt while awake
           decfsz  temp2		; all other code is much much less than 18ms (WDT timeout) when not delaying
           goto    $-2

        decfsz  temp1
        goto    wait
        retlw   .0
;}
;********************************************************
;* subroutine: average
;* descr: 
;*
;* in:    freqhi, freqlo                                *
;********************************************************
;{
average
        movf    averagehi,w
        movwf   avhitemp
        movf    averagelo,w
        movwf   avlotemp
        clrf    temp2           ; make a copy of the original value

        call    divideby2pwrn   ; divide the copy by 2^n
;******
        movf    temp2,w
        subwf   averagefraction ; and subtract the result from the original
        btfsc   status,c
        goto    hopover
        decf    averagelo
        movlw   .255
        xorwf   averagelo,w
        btfsc   status,z
        decf    averagehi           
hopover
        movf    avlotemp,w
        subwf   averagelo
        btfss   status,c
        decf    averagehi

        movf    avhitemp,w
        subwf   averagehi       ; average - 1/(2^n)
;******
        movf    freqhi,w
        movwf   avhitemp
        movf    freqlo,w
        movwf   avlotemp        ; make a copy of the original value
        clrf    temp2

        call    divideby2pwrn   ; divide by 2^n

        movf    temp2,w
        addwf   averagefraction
        btfss   status,c
        goto    hopover2
        incf    averagelo
        btfsc   status,z
        incf    averagehi
hopover2
        movf    avlotemp,w
        addwf   averagelo
        btfsc   status,c
        incf    averagehi
        movf    avhitemp,w
        addwf   averagehi

        retlw   .0

divideby2pwrn
        movlw   avdepth
        movwf   temp1
shift1
        bcf     status,c
        rrf     avhitemp
        rrf     avlotemp
        rrf     temp2
        decfsz  temp1
        goto    shift1
        retlw   .0
;}
;********************************************************
;* subroutine: checkdifference                          *
;* descr: subtracts actual value from average           *
;*                                                      *
;* out:   freqhi:freqlo  with frequency                 *
;********************************************************
;{
checkdifference
        movf    averagehi,w
        movwf   differencehi
        movf    averagelo,w
        movwf   differencelo    ; make a copy of the averagevalue

        movf    freqlo,w
        subwf   differencelo
        btfss   status,c
        decf    differencehi
        movf    freqhi,w
        subwf   differencehi    ; averagevalue - currentvalue

        btfsc   status,c        ; is the difference negative?
        goto    evaldifference  ; no positive, check if it exceeds the trip point
        movf    freqhi,w        ; yes, key is released
        movwf   averagehi       ; average should follow actual value
        movf    freqlo,w
        movwf   averagelo
        clrf    differencehi
        clrf    differencelo
        bcf     userflag,keydown

        retlw   .0

evaldifference
        bcf     userflag,keydown

		movlw	triphi_tch
		btfsc	gpio, 3
        movlw   triphi_prx
        subwf   differencehi,w
        btfss   status,z        ; are hi bytes equal?
        goto    results


		movlw	triplo_tch
		btfsc	gpio, 3
        movlw   triplo_prx      ; yes, compare lower bytes
        subwf   differencelo,w
results

        btfss   status,c        ; was the difference > trip point?
        retlw   .0              ; no, return

        bsf     userflag,keydown ; yes, set the keydown flag

        retlw   .0
;}
;********************************************************
;* subroutine: getfrequency                             *
;* descr: converts to binary coded decimal              *
;*                                                      *
;* out:   freqhi:freqlo  with frequency                 *
;********************************************************
;{
getfrequency
        movlw   b'11110111'
              ;   ||||||||_ ps0
              ;   |||||||__ ps1
              ;   ||||||___ ps2   set prescaler to 1:256
              ;   |||||____ psa   prescaler assigned to tmr0
              ;   ||||_____ t0se  increment on high to low
              ;   |||______ t0cs  transition on t0cki
              ;   ||_______ #gppu pull-ups disabled
              ;   |________ #gpwu wake-up on pin change disabled
        option

        movlw   b'00001011'
              ;   ||||||||_ #cwu    wake-up on comp change disabled
              ;   |||||||__ cpref   pos ref is cin+
              ;   ||||||___ cnref   neg ref is internal 0.6V reference
              ;   |||||____ cmpon   comparator on
              ;   ||||_____ cmpt0cs comparator output used as tmr0 clock
              ;   |||______ pol     output is inverted
              ;   ||_______ #couten output is placed on cout pin
              ;   |________ cmpout  -read only bit-
        movwf   cmcon0
        
        movlw   .255            ; frequency will be stored in freqhi:freqlo
        movwf   freqlo          ; freqlo is pre-initialised here

        clrf    tmr0            ; clear tmr0 and the 1:256 prescaler
        movlw   gatedtime
        call    delay           ; wait N mSec for scan time

        bcf     cmcon0,cmpon    ; turn off oscillator

        movf    tmr0,w          ; high byte of value is stored in tmr0
        movwf   freqhi          ; low value is still in the prescaler

; To get the value from the prescaler (which is not directly readable),
; the clock source for tmr0 is changed to Fosc/4.
; Next the value of tmr0 is observed. The time is takes for the next
; increment is an indication of the value of the prescaler.

        movlw   b'11010111'     ; change clock source to Fosc/4
        option

measureprescaler
        incf    freqlo          ; was initialised to 255 and set to 0 here
        movf    tmr0,w          ; get the current value of tmr0
        xorwf   freqhi,w        ; compare it with the original value of tmr0
        btfsc   status,z        ; did tmr0 increment?
        goto    measureprescaler ; no, loop and increment freqlo

; Now freqlo ranges from 0 to 43. The next section will muliply it
; with 6 and clipped to 255, to get the lobyte of the frequency count.

        bcf     status,c        ; clear the carry bit
        rlf     freqlo          ; muliply by 2
        rlf     freqlo ,w       ; and muliply by 2 again, but put the result in w
        addwf   freqlo          ; add it to the doubled value (multiplied by 6)
        btfss   status,c        ; did it overflow (6 x 43 = 258)
        goto    nooverflow      ; no, go on
        movlw   .255            ; yes, clip it to 255
        movwf   freqlo 

nooverflow
        comf    freqlo          ; the time for the prescaler to roll over was measured,
                                ; so its value was 255 - prescaler value

; Because of the way the prescaler rollover time was measured (6 Tcy in measureprescaler),
; atleast the 2 least significant bits in freqhi:frequlo are useless.
; Therefore the final result is divided by 4.

        bcf     status,c
        rrf     freqhi
        rrf     freqlo
        bcf     status,c
        rrf     freqhi
        rrf     freqlo          ; divide by 4


		bcf		cmcon0, cmpon	; turn comp off to conserve power

        retlw   .0              ; done
;}



;********************************************************
;* main                                                 *
;********************************************************
;{
main
        movlw   gatedtime
        call    delay           ; wait 30mSec

        movlw   .49
        movwf   differencelo
        movlw   .1
        movwf   differencehi
        call    evaldifference
        
        nop

        call    getfrequency
        movf    freqhi,w
        movwf   averagehi
        movf    freqlo,w
        movwf   averagelo


mainloop
		; Sensing and Detection
        call    getfrequency
        call    average
        call    checkdifference

		; Check if Key Was Pressed
		btfsc	userflag, keydown
		goto	react_keydown
		btfss	userflag, keydown
		goto	react_keyup

		; If a press was detected, output low (LED ON) else output high (LED OFF)
react_keydown:
		bcf		gpio, output			; turn led on
		goto	finish_loop
react_keyup:
		bsf		gpio, output			; turn led off
		goto	finish_loop


		; Code below was left in to show possible use of sleeping and waking via WDT
		; to significantly reduce power.  Requires code on power up (also commented)
		; in order to determine that it is a wake from sleep, not power up in order
		; to resume normal operation		

finish_loop:	
		; Sleep
 ; 		movlw   b'11111011'				; Prescalar on 1:8 WDT, assign to WDT
 ;  	option
 ;		movlw	.1
 ;		call	delay					; delay for 1 ms to ensure comparator off, everything settled before sleep
 ;		sleep							; goto sleep for ~144ms (8*18ms)
 ;		nop								; don't pre-fetch anything unintended after sleep instruction
 ;      Sleep Code Commented out
		
		; Sleeping more between scans will reduce avg current
		; 33ms on, 144ms off avg draw =  ~70uA		WDT prescale 1:8	(5.6scan per sec)
		; 33ms on, 288ms off avg draw =  ~50ua		WDT prescale 1:16	(3.1scan per sec)

		
wake_from_sleep:
 ;  	movlw   b'11110111'				; Return Prescalar to 1:256 assigned to TMR0
 ;   	option							; re-init option reg
 ;		movlw	b'00001011'
 ;		movwf	cmcon0					; re-init cmcon0
 ;		movlw	b'11111001'
 ;		tris	gpio					; re-init gpio
 ;      Sleep code commented
	
		goto	mainloop				; stay in main loop


;---------------------------------------------------------------------       
        end
