 TITLE ELECTRONIC DICE ON PIC10F200 PROJECT
 SUBTITLE DICE with 7 LED

    #include <p10F200.inc>

    __CONFIG   _IntRC_OSC & _WDT_OFF & _MCLRE_OFF & _CP_OFF
    __IDLOCS H'6282'

RAM  set  h'10'

     cblock RAM
face_value          ;EQU     0x10        ; Random number
disp_timer_1        ;EQU     0x11        ; Delay counter 1
disp_timer_2        ;EQU     0x12        ; Delay counter 2
multiplexing_timer  ;EQU     0x13        ; Multiplexing counter
ghost_wipe_timer    ;EQU     0x14        ; Ghosting protection counter
RAM_				;Dummy End of RAM variable location indicator
     endc

     if RAM_ > h'20'
     error "File register usage overflow"
     endif

    ORG     0x0000

START:
    ANDLW   ~1
    MOVWF   OSCCAL              ; Calibration
    MOVLW   B'00000000'
    OPTION                      ; Configuring Wakeup on GP3 pin
    CLRF    face_value          ; Clearing variable face_value

MAIN_LOOP:
    MOVLW   B'1111'
    TRIS    GPIO                ; Setting all gpios as an input (Hi-Z state)

    BTFSS   GPIO, 3             ; Test GP3 state
    GOTO    DICE_RANDOM_ROLL    ; If GP3 == LOW (Start rolling)
    SLEEP                       ; If GP3 == HIGH (Power down)
    NOP

DICE_RANDOM_ROLL:		; Random number generation
    INCF    face_value, F       ; Increment counter
    MOVLW   7
    XORWF   face_value, W       ; Compare face_value with 7
    BTFSS   STATUS, Z
    GOTO    CHECK_BUTTON        ; If face_value < 7
    MOVLW   1                   ; If face_value = 7
    MOVWF   face_value          ; Reset counter to 1

CHECK_BUTTON:
    BTFSS   GPIO, 3             ; Test GP3 state
    GOTO    DICE_RANDOM_ROLL    ; If GP3 == LOW (Keep rolling)

    MOVLW   0xFF                ; Loading literals to verification timer
    MOVWF   disp_timer_1

; SOFTWARE DEBOUNCING (ignore change in state on GP3 if it is shorter than 10 ms) 
VERIFY_STABILITY_LOOP:
    MOVLW   0x20                ; Loading sampling frequency
    MOVWF   disp_timer_2

SAMPLE_PIN_LOOP:
    BTFSS   GPIO, 3             ; Test GP3 state again
    GOTO    DICE_RANDOM_ROLL    ; If GP3 == LOW (Bounce detected - Reset)

    DECFSZ  disp_timer_2, F
    GOTO    SAMPLE_PIN_LOOP

    DECFSZ  disp_timer_1, F     ; Decrement main verification timer
    GOTO    VERIFY_STABILITY_LOOP

    GOTO    START_ANIMATION     ; Button is stable

START_ANIMATION:
    				; STEP 1: DIAGONAL 1
    MOVLW   B'0100'             ; GP0 = LOW, GP2 == HIGH
    MOVWF   GPIO
    MOVLW   B'1010'             ; Configuring GP2 and GP0 as output
    TRIS    GPIO
    CALL    ANIM_DELAY		; Animation display delay
    CALL    ANIM_OFF		; Animation parts separation for visual effect

    				; STEP 2: DIAGONAL 2
    MOVLW   B'0001'             ; GP0 == HIGH, GP2 == LOW
    MOVWF   GPIO
    MOVLW   B'1010'             ; Configuring GP2 and GP0 as output
    TRIS    GPIO
    CALL    ANIM_DELAY
    CALL    ANIM_OFF

    				; STEP 3: CENTER
    MOVLW   B'0100'             ; GP2 == HIGH, GP1 == LOW
    MOVWF   GPIO
    MOVLW   B'1001'             ; Configuring GP1 and GP2 as output
    TRIS    GPIO
    CALL    ANIM_DELAY
    CALL    ANIM_OFF

    				; STEP 4: SIDES
    MOVLW   B'0011'             ; GP0 == HIGH, GP1 == HIGH
    MOVWF   GPIO
    MOVLW   B'1000'             
    TRIS    GPIO
    CALL    ANIM_DELAY
    CALL    ANIM_OFF

    				; REPEAT FOR EFFECT
    MOVLW   B'0001'
    MOVWF   GPIO
    MOVLW   B'1010'
    TRIS    GPIO
    CALL    ANIM_DELAY
    CALL    ANIM_OFF

    GOTO    INIT_DISPLAY        ; End of animation

ANIM_OFF:
    MOVLW   B'1111'
    TRIS    GPIO                ; Setting all gpios as an input (OFF)

    MOVLW   0xFF                ; Loading literals to delay timers
    MOVWF   disp_timer_1
    MOVLW   0x4F
    MOVWF   disp_timer_2
ANIM_OFF_LOOP:
    DECFSZ  disp_timer_1, F
    GOTO    ANIM_OFF_LOOP
    DECFSZ  disp_timer_2, F
    GOTO    ANIM_OFF_LOOP

    RETLW   0

ANIM_DELAY:
    MOVLW   0xFF                ; Loading literals to delay timers
    MOVWF   disp_timer_1
    MOVLW   0x17
    MOVWF   disp_timer_2
ANIM_DELAY_LOOP:
    DECFSZ  disp_timer_1, F
    GOTO    ANIM_DELAY_LOOP
    DECFSZ  disp_timer_2, F
    GOTO    ANIM_DELAY_LOOP
    RETLW   0


INIT_DISPLAY:
    MOVLW   0xFF                ; Loading literals to timers registers
    MOVWF   disp_timer_1
    MOVLW   0x0F
    MOVWF   disp_timer_2

MAIN_DISPLAY:
    ; PHASE A DISPLAY ;
    MOVLW   B'1111'             ; Discharging parasitic capacitance
    TRIS    GPIO
    CALL    GHOST_WIPE_DELAY

    MOVF    face_value, W       ; Configuring GPIOS for phase A
    CALL    PHASE_A_GPIO
    MOVWF   GPIO

    MOVF    face_value, W       ; Configuring logic state for phase A
    CALL    PHASE_A_TRIS
    TRIS    GPIO

    CALL    MULTIPLEXING_DELAY

    ; PHASE B DISPLAY ;
    MOVLW   B'1111'             ; Discharging parasitic capacitance
    TRIS    GPIO
    CALL    GHOST_WIPE_DELAY

    MOVF    face_value, W       ; Configuring GPIOS for phase B
    CALL    PHASE_B_GPIO
    MOVWF   GPIO

    MOVF    face_value, W       ; Configuring logic state for phase B
    CALL    PHASE_B_TRIS
    TRIS    GPIO

    CALL    MULTIPLEXING_DELAY

    DECFSZ  disp_timer_1, F     ; Delay loop for display duration
    GOTO    MAIN_DISPLAY
    DECFSZ  disp_timer_2, F
    GOTO    MAIN_DISPLAY

    GOTO    MAIN_LOOP           ; End of display procedure

MULTIPLEXING_DELAY:             ; Delay loop for time between the phase A and B
    MOVLW   0x20
    MOVWF   multiplexing_timer
MULTIPLEXING_DELAY_LOOP:
    DECFSZ  multiplexing_timer, F
    GOTO    MULTIPLEXING_DELAY_LOOP
    RETLW   0

GHOST_WIPE_DELAY:               ; Delay loop for discharging parasitic capacitance
    MOVLW   0x20
    MOVWF   ghost_wipe_timer
GHOST_WIPE_DELAY_LOOP:
    DECFSZ  ghost_wipe_timer, F
    GOTO    GHOST_WIPE_DELAY_LOOP
    RETLW   0

PHASE_A_GPIO:
    ADDWF   PCL, F
    RETLW   b'0000'             ; 0
    RETLW   b'0000'             ; 1 (OFF)
    RETLW   b'0001'             ; 2 (GP0 == HIGH)
    RETLW   b'0001'             ; 3 (GP0 == HIGH)
    RETLW   b'0001'             ; 4 (GP0 == HIGH)
    RETLW   b'0001'             ; 5 (GP0 == HIGH)
    RETLW   b'0011'             ; 6 (GP0 == HIGH, GP1 == HIGH)

PHASE_A_TRIS:
    ADDWF   PCL, F
    RETLW   b'1111'             ; 0
    RETLW   b'1111'             ; 1 (OFF)
    RETLW   b'1000'             ; 2 (Configuring GP0, GP1, GP2 as an output)
    RETLW   b'1000'             ; 3 (Configuring GP0, GP1, GP2 as an output)
    RETLW   b'1000'             ; 4 (Configuring GP0, GP1, GP2 as an output)
    RETLW   b'1000'             ; 5 (Configuring GP0, GP1, GP2 as an output)
    RETLW   b'1000'             ; 6 (Configuring GP0, GP1, GP2 as an output)

PHASE_B_GPIO:
    ADDWF   PCL, F
    RETLW   b'0000'		; 0
    RETLW   b'0100'             ; 1 (GP2 == HIGH)
    RETLW   b'0100'             ; 2 (OFF)
    RETLW   b'0100'             ; 3 (GP2 == HIGH)
    RETLW   b'0100'             ; 4 (GP2 == HIGH)
    RETLW   b'0100'             ; 5 (GP2 == HIGH)
    RETLW   b'0100'             ; 6 (GP2 == HIGH)

PHASE_B_TRIS:
    ADDWF   PCL, F
    RETLW   b'1111'		; 0
    RETLW   b'1001'             ; 1 (Configuring GP1 and GP2 as an output)
    RETLW   b'1111'             ; 2 (OFF)
    RETLW   b'1001'             ; 3 (Configuring GP1 and GP2 as an output)
    RETLW   b'1010'             ; 4 (Configuring GP0 and GP2 as an output)
    RETLW   b'1000'             ; 5 (Configuring GP0, GP1 and GP2 as an output)
    RETLW   b'1010'             ; 6 (Configuring GP0 and GP2 as an output)

    END

