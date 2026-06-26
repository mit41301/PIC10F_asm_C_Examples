;**************************************************************************
; FILE:      reactometer.asm                                              *
; CONTENTS:  Reactometer reaction timer                                   *
; COPYRIGHT: MadLab Ltd. 2005                                             *
; AUTHOR:    James Hutchby                                                *
; UPDATED:   02/03/05                                                     *
;**************************************************************************

     list p=10F200

     include "p10f200.inc"

     __config _IntRC_OSC & _WDT_OFF & _MCLRE_OFF & _CP_ON

     __idlocs h'ED10'

     errorlevel -305


;**************************************************************************
;                                                                         *
; Specification                                                           *
;                                                                         *
;**************************************************************************

; power-up self-test - all LEDs lit in turn (in demonstration of
; scoring system)

; button starts running lights, freezes after random period
; times player response to this and displays as score (1 to 10)

; player loses if button pressed too early or too late (all LEDs flash)


;**************************************************************************
;                                                                         *
; Port assignments                                                        *
;                                                                         *
;**************************************************************************

GPIO_IO   equ  b'1111'             ; port I/O status

BUTTON    equ  3                   ; pushbutton

IO_1      equ  b'1100'             ; LED I/O status and masks
MASK_1    equ  b'1110'
IO_2_3    equ  b'1101'
MASK_2_3  equ  b'1101'
IO_4_5    equ  b'1110'
MASK_4_5  equ  b'1111'
IO_6_7    equ  b'1011'
MASK_6_7  equ  b'1111'


;**************************************************************************
;                                                                         *
; Constants and timings                                                   *
;                                                                         *
;**************************************************************************

CLOCK     equ  d'4000000'     ; processor clock frequency in Hz

SCORE     equ  d'10'          ; maximum score
RELEASE   equ  d'25'          ; button release time

MIN_REACT      equ  d'12'     ; minimum reaction time
MAX_REACT      equ  d'32'     ; maximum reaction time

; delay periods in ms
POLL_DELAY     equ  d'25'
DEMO_DELAY     equ  d'225'
RUNNING_DELAY  equ  d'75'
FREEZE_DELAY   equ  d'250'
REACT_DELAY    equ  d'20'
SCORE_DELAY    equ  d'40'
FLASH_DELAY    equ  d'200'


;**************************************************************************
;                                                                         *
; File register usage                                                     *
;                                                                         *
;**************************************************************************

RAM  set  h'10'

     cblock RAM
     release                       ; button timer
     leds                          ; LED flags
     score                         ; score, 0 to 10
     react                         ; reaction timer
     random                        ; random number
     timer                         ; timer
     work1, work2                  ; work registers
     RAM_
     endc

     if RAM_ > h'20'
     error "File register usage overflow"
     endif

; LED flags
LED_1          equ  0              ; set if LED1 on
LED_2_3        equ  1              ; set if LED2 and LED3 on
LED_4_5        equ  2              ; set if LED4 and LED5 on
LED_6_7        equ  3              ; set if LED6 and LED7 on


;**************************************************************************
;                                                                         *
; Macros                                                                  *
;                                                                         *
;**************************************************************************

routine   macro label              ; routine
label
          endm

table     macro label              ; define lookup table
label     addwf PCL
          endm

entry     macro value              ; define table entry
          retlw value
          endm

index     macro label              ; index lookup table
          call label
          endm

jump      macro label              ; jump through table
          goto label
          endm

tstw      macro                    ; test w register
          iorlw 0
          endm

movff     macro f1,f2              ; move file to file
          movfw f1
          movwf f2
          endm

movlf     macro n,f                ; move literal to file
          movlw n
          movwf f
          endm


;--------------------------------------------------------------------------
; reset vector
;--------------------------------------------------------------------------

          org 0

          andlw ~1
          movwf OSCCAL

          goto main_entry


;**************************************************************************
;                                                                         *
; Lookup tables                                                           *
;                                                                         *
;**************************************************************************

          table scores

          entry (0<<LED_1)|(0<<LED_2_3)|(0<<LED_4_5)|(0<<LED_6_7)
          entry (0<<LED_1)|(0<<LED_2_3)|(0<<LED_4_5)|(1<<LED_6_7)
          entry (0<<LED_1)|(0<<LED_2_3)|(1<<LED_4_5)|(0<<LED_6_7)
          entry (0<<LED_1)|(1<<LED_2_3)|(0<<LED_4_5)|(0<<LED_6_7)
          entry (1<<LED_1)|(0<<LED_2_3)|(0<<LED_4_5)|(0<<LED_6_7)
          entry (1<<LED_1)|(0<<LED_2_3)|(0<<LED_4_5)|(1<<LED_6_7)
          entry (1<<LED_1)|(0<<LED_2_3)|(1<<LED_4_5)|(0<<LED_6_7)
          entry (1<<LED_1)|(1<<LED_2_3)|(0<<LED_4_5)|(0<<LED_6_7)
          entry (1<<LED_1)|(1<<LED_2_3)|(0<<LED_4_5)|(1<<LED_6_7)
          entry (1<<LED_1)|(1<<LED_2_3)|(1<<LED_4_5)|(0<<LED_6_7)
          entry (1<<LED_1)|(1<<LED_2_3)|(1<<LED_4_5)|(1<<LED_6_7)


          table reactions

          entry d'10'
          entry d'9'
          entry d'8'
          entry d'7'
          entry d'6'
          entry d'5'
          entry d'5'
          entry d'4'
          entry d'4'
          entry d'3'
          entry d'3'
          entry d'2'
          entry d'2'
          entry d'2'
          entry d'1'
          entry d'1'
          entry d'1'
          entry d'1'
          entry d'1'
          entry d'1'


;**************************************************************************
;                                                                         *
; Procedures                                                              *
;                                                                         *
;**************************************************************************

;--------------------------------------------------------------------------
; polls the button, returns NZ flag set if pressed
;--------------------------------------------------------------------------

          routine poll_button

          clrf GPIO                     ; LEDs off
          movlw GPIO_IO
          tris GPIO

          movlw b'10001111'             ; enable weak pull-ups
          option

          setz
          btfss GPIO,BUTTON
          clrz

          movlw b'11001111'             ; disable weak pull-ups
          option

          retlw 0


;--------------------------------------------------------------------------
; waits while multiplexing the LEDs, fed with the wait in ms in w reg,
; returns NZ flag set if button pressed
;--------------------------------------------------------------------------

          routine long_wait

          clrw

          routine wait_ms

LED_      macro led,io,mask

          local wait1,wait2

          movlw GPIO_IO
          tris GPIO
          clrf GPIO

          btfss leds,led
          goto wait1

          movlf mask,GPIO
          movlw io
          tris GPIO

WAIT      set  CLOCK/(d'4000'*d'12')    ; 1/4 ms

wait1     movlf WAIT,work2
wait2     decfsz work2                  ; [4]
          goto wait2                    ; [8]

          endm

          movwf work1

wait3     LED_ LED_1,IO_1,MASK_1
          LED_ LED_2_3,IO_2_3,MASK_2_3
          LED_ LED_4_5,IO_4_5,MASK_4_5
          LED_ LED_6_7,IO_6_7,MASK_6_7

          call poll_button              ; button pressed ?
          bz wait4                      ; branch if not

          tstf release                  ; waiting for release ?
          bnz wait5                     ; branch if yes

          clrz                          ; signal button pressed
          retlw 0

wait4     tstf release
          skpz
          decf release

wait5     decfsz work1
          goto wait3

          setz                          ; signal button not pressed
          retlw 0


;--------------------------------------------------------------------------
; shows the score, fed with the wait period in ms in w reg
;--------------------------------------------------------------------------

          routine show_score

          movwf work1

          movfw score
          index scores
          movwf leds

          movfw work1
          goto wait_ms


;--------------------------------------------------------------------------
; main entry point
;--------------------------------------------------------------------------

          routine main_entry

          clrf GPIO                     ; initialise port
          movlw GPIO_IO
          tris GPIO

          movlw b'11001111'             ; weak pull-ups disabled
          option

          clrf release

;         goto demo_mode


;--------------------------------------------------------------------------
; demo mode
;--------------------------------------------------------------------------

          routine demo_mode

          movlf d'20',timer             ; initialise timer

demo1     clrf score

demo2     movlw DEMO_DELAY
          call show_score
          bnz timer_mode                ; exit if button pressed

          incf score

          movlw SCORE+1
          subwf score,w
          bnz demo2

          call long_wait
          call long_wait
          call long_wait
          call long_wait

          decfsz timer
          goto demo1

;         goto main_loop


;--------------------------------------------------------------------------
; main loop
;--------------------------------------------------------------------------

          routine main_loop

          clrf leds                     ; LEDs off

          movlf RELEASE,release         ; wait for button to be pressed
loop1     movlw POLL_DELAY
          call wait_ms
          bz loop1

;         goto timer_mode


;--------------------------------------------------------------------------
; reaction timer
;--------------------------------------------------------------------------

          routine timer_mode

          clrf leds                     ; LEDs off

          movlf RELEASE,release
          movlw POLL_DELAY
          call wait_ms

;         clrf random

WAIT      set  CLOCK/(d'10000'*d'12')   ; 100 us

time1     movlf WAIT,work1
time2     decfsz work1                  ; [4]
          goto time2                    ; [8]

          incf random                   ; random timing from button release

          call poll_button              ; wait for button to be released
          bnz time1

          clrf leds
          movlf RELEASE,release
          movlw POLL_DELAY
          call wait_ms

          movfw TMR0
          xorwf random
          bcf random,7
          bcf random,6
          movlw FREEZE_DELAY/RUNNING_DELAY
          addwf random

          movlf 1<<LED_6_7,leds         ; running LEDs for random time

time3     movlw RUNNING_DELAY
          call wait_ms
          bnz time8                     ; branch if button pressed too early

          rrf leds
          movlw 1<<LED_6_7
          skpnc
          movwf leds

          decfsz random
          goto time3

          clrf react                    ; freeze LEDs

time4     movlw REACT_DELAY             ; wait for button to be pressed
          call wait_ms
          bnz time5

          incf react

          movlw MAX_REACT
          subwf react,w
          bz time8                      ; branch if button pressed too late

          goto time4

time5     movlw MIN_REACT               ; calculate score
          subwf react,w
          skpc
          clrw
          index reactions
          movwf react

          clrf score                    ; display score
time6     movlf -1,release
          movlw SCORE_DELAY
          call show_score
          incf score
          decf score,w
          subwf react,w
          bnz time6

          clrf timer                    ; wait for button to be pressed
          movlf RELEASE,release
time7     call long_wait
          bnz timer_mode
          decfsz timer
          goto time7

          goto main_loop

time8     movlf d'100',timer            ; flash all LEDs to signal failure
          movlf h'ff',release
          movlf h'ff',leds
time9     movlw FLASH_DELAY
          call wait_ms
          bnz timer_mode
          comf leds
          decfsz timer
          goto time9

          goto main_loop


          end
