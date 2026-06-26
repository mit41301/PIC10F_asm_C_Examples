; Simulated Neuron Program
    ;This will flash a PIC10F200 with a program that takes an input and
    ;produces two outputs one for the soma representing the full burst refractory 
    ;period and on for the axon which gives an action potential or a 12 action potential burst
    ;as selected by the user
    ;These can by considered as units that can be put together in a larger 
    ; circuit to build a network.
    
    
PROCESSOR 10F200

; PIC10F200 Configuration Bit Settings

; Assembly source line config statements

; CONFIG
  CONFIG  WDTE = OFF            ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF              ; Code Protect (Code protection off)
  CONFIG  MCLRE = OFF           ; Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

; config statements should precede project file includes.
#include <xc.inc>


PSECT resetVect, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
    
    
PSECT code, delta=2
main:
    
    movlw 0b00001100 ; first four zeros are irrelevent. 
		     ; last four GP3, GP2, GP1, GP0
		     ; 1 will set to input, 0 will set to output
		     ; GP3 is input only. This is used to select the mode. High = burst low = 1 AP
		     ; Here GP2 is the input--dendric arbor
		     ; GP1 is the soma output -- represents burst refractory period
		     ; GP0 is the axon -- this carries the burst
       
    tris 6 ;the 6 sets tris to the value stored in W
    nop
    
    nop
    movlw 0b11011111 ;the zero here will set GP2 to IO rather than external clock
    option ; the contents of the working register is moved to OPTION register 
    nop


mainloop:
    movlw 12 ; sets number action potential in the bursts to 12
    movwf 0x13 ; stores number of bursts in memory address 0x13
    nop
    bcf GP1; sets soma output to low. Cell is ready for signal
    bcf GP0 ; sets axon the output to low --- no action potentials going
    btfss GP2 ; Polls GP2 until a high signal is received
    goto mainloop
    movlw 53   ;This should delay about 0.5 s --53^3/307200 s--
    bsf GP1; sets soma output to high. This represents the start of the 
		; the full refractory period--absolute and relative
		; high signals on GP2
    call delay
    nop
burst:    
    bsf GP0 ; sets the output to high--first action potential
    movlw 20 ;This should delay about 0.025 s --20^3/307200 s-- repetition period
		; of the action potential burst
    call delay
    btfsc GP3
    bcf GP0; set the output to low --- interval between action potential 
    movlw 20 
    call delay ;This should delay about 0.025 s --20^3/307200 s--
    decfsz 0x13, 1
    goto burst
    nop
    movlw 53; This should delay about 0.5 s refractory period
    call delay
    goto mainloop
    
delay: ; this is a three-layer nested loop. wouldn't need 3 but it is what I had 
	; from other programs
    movwf 0x12
out_out_loop:
    movwf 0x11
outer_loop:
    movwf 0x10
delay_loop:
    decfsz 0x10, 1
    goto delay_loop
    decfsz 0x11, 1
    goto outer_loop
    decfsz 0x12, 1
    goto out_out_loop
    retlw 0 ; the return sets the working register to zero. 
    nop
    
END resetVect 
