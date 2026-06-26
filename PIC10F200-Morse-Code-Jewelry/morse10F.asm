; version PIC10F222-compatible
; cleaned up for Hackaday
; (C) 2010-2018 Yann Guidon whygee@f-cpu.org
; Released under CC-ND-NC

        TITLE       "morse10F200"
        SUBTITLE    "version 22march2018"

        LIST        P=10F200
        INCLUDE	    "p10f200.inc"
        RADIX       DEC

#define _A  2 | ((2)<<3)
#define _B  4 | ((1)<<3)
#define _C  4 | ((1+4)<<3)
#define _D  3 | ((1)<<3)
#define _E  1 | ((0)<<3)
#define _F  4 | ((4)<<3)
#define _G  4 | ((1+2)<<3)
#define _H  4 | ((0)<<3)
#define _I  2 | ((0)<<3)
#define _J  4 | ((2+4+8)<<3)
#define _K  3 | ((1+4)<<3)
#define _L  4 | ((2)<<3)
#define _M  2 | ((1+2)<<3)
#define _N  2 | ((1)<<3)
#define _O  3 | ((1+2+4)<<3)
#define _P  4 | ((2+4)<<3)
#define _Q  4 | ((1+2+8)<<3)
#define _R  3 | ((2)<<3)
#define _S  3 | ((0)<<3)
#define _T  1 | ((1)<<3)
#define _U  3 | ((4)<<3)
#define _V  4 | ((8)<<3)
#define _W  3 | ((2+4)<<3)
#define _X  4 | ((1+8)<<3)
#define _Y  4 | ((1+4+8)<<3)
#define _Z  4 | ((1+2)<<3)

#define _Agrave  5 | ((2+4+16)<<3)  ; à
#define _Ccedil  5 | ((1+4)<<3)     ; ç
#define _CH      4 | ((1+2+4+8)<<3) ; ch
#define _Egrave  5 | ((2+16)<<3)    ; è
#define _Eaigu   5 | ((4)<<3)       ; é
#define _egal    5 | ((1+16)<<3)    ; =
#define _fract   5 | ((1+8)<<3)     ;  /
#define _exclam  5 | ((4+8)<<3)     ; !
#define _AR      5 | ((2+8)<<3)     ; stop / end of message
#define _AS      5 | ((2)<<3)       ; wait
#define _BT      5 | ((1+16)<<3)    ; separaration


#define _1  5 | ((2+4+8+16)<<3)
#define _2  5 | ((4+8+16)<<3)
#define _3  5 | ((8+16)<<3)
#define _4  5 | ((16)<<3)
#define _5  5 | ((0)<<3)
#define _6  5 | ((1)<<3)
#define _7  5 | ((1+2)<<3)
#define _8  5 | ((1+2+4)<<3)
#define _9  5 | ((1+2+4+8)<<3)
#define _0  5 | ((1+2+4+8+16)<<3)

#define __  0

	; check this !
        __config   0x0FE8 &_CP_ON ; _MCLRE_ON & _CP_ON & _WDT_OFF

        ; bit 0 : 0 = 4MHz
        ; bit 1 : 0 = MCPU : pull-up enabled
        ; bit 2 : 0 = WDT disable
        ; bit 3 : 1 = Copy Protection Off
        ; bit 4 : 0 = MCLRE=I/O

        cblock 0x10 ; compatible with all PIC10F2xx
          ONE   ; constant 1
          cpt1  ; waiting/counters
          cpt2
          reg   ; current character
          len   ; number of tics
          index ; character counter
        endc

#define MORSE_OUT   2           ; GP1 = data (select your pin)
#define MORSE_ON   (~MORSE_OUT) ; data out, enable the LED
#define MORSE_OFF  (-1)         ; disable data out

        org         0
debut:
        ; init output port

	clrf GPIO ; Tie LED to +3V, PIC=low-side

	; for the 10F22x : clrf ADCON0
        clrf 7

        movlw 1 ; init the constant
        movwf ONE

        ; prescaler max, assigned to TMR0
        ; no pull-up or wake up
        movlw 0xC7 ; 1100 0 111
        option

        ; short wait
        call espace
        call espace

rebouclage:
        clrf index;

endless:
        call texte ; read the next char.
        movwf reg ; save the char
        incf index,f ; increment the char counter

; structure of the 3 LSB in reg :
; 0 : space between words
; 1-5 : 5 bits to decode, in MSB
; 6,7 : not used

;************** check if space : **************
        movf reg, f
        btfss STATUS, Z
        goto nospace

; space between words :
;        movlw 5-1 ; 1 tic already done
;        call wait
        call espace
        call espace
        call espace
        call espace

        goto endless

;************** decode the letters: **************
nospace:

; copy the 3LSB of reg into len (counter of tics)
        movfw reg
        andlw 7
        movwf len

; preshift MSB
        rrf reg, f
        rrf reg, f
        rrf reg, f

loop_tic:
; LED ON
          movlw MORSE_ON
          tris GPIO

; decode : dash or dot ?
          movlw 1 ; default : dot = 1 tic
          rrf reg, f ; get a new bit
          btfsc STATUS, C ; if it's a dot, keep the default tic count
          xorlw 2 ; 3 tics if dash
          call wait

; space between two tics:
          call espace

; reloop
        decfsz len, f
        goto loop_tic

; space between 2 letters :
;        movlw 3-1 ; 1 tic already done
;        call wait
        call espace
        call espace

        goto endless


#define ratio (2<<4) ; hint : cf swapf for sub-unit wait
espace:
; turn off
        movlw MORSE_OFF
        tris GPIO

	; relic from a different version
        movlw ratio
        call wait
        movlw 256-ratio
        call wait

        return

;--------------------------------------------
;  wait for a given number of tics in W
;--------------------------------------------

wait:   movwf cpt2
        swapf cpt2,f ; x16

wait1:  movlw 200 ; 1 tic
        movwf cpt1

; 4*1us*250=1ms :
wait2:    movlw 250
;Delays 4w cycles (0=256)
wait3:      addwf ONE,w
		    btfss STATUS, Z 
		    goto wait3

          decfsz cpt1,f
          goto wait2

        decfsz cpt2,f
        goto wait1
        return


texte:  movfw index
        addwf PCL,f
; 193  chars. max.

        include "message.inc"

        retlw __
        retlw __
        retlw __
        retlw __

        goto rebouclage ; mega hack ! *wink*
         ; (side effect : stack is saturated...)
    end
