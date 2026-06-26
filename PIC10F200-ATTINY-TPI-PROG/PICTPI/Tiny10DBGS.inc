;
; this is for the console IO stuff when testing
;
#define	B9600
	#ifdef	B9600
delf	equ	0x20
delh	equ	delf/2
	#endif
	#ifdef	B4800
delf	equ	0x40
delh	equ	delf/2
	#endif
	#ifdef	B2400
delf	equ	0x8a
delh	equ	delf/2
	#endif
	#ifdef	B1200
delf	equ	0xd0x
delh	equ	delf/2
	#endif	
	#ifdef	B600
delf	equ	0xd0
delh	equ	delf/2
	#endif
;	#ifndef	Tset
;Tset	macro	bit
;	movlw	mask | 1 << bit
;	TRIS	GPIO
;	endm
;	#endif
;	#ifndef	Tclr
;Tclr	macro	bit
;	movlw	mask & ~( 1 << bit )
;	TRIS	GPIO
;	endm
;	#endif


sndByte	macro	byte
	movlw	byte
	call	rsndFrame
	endm

;
; make Even parity return 0 or 1 from entered byte
;
mmakepar	macro
	movwf	Dtmp
	swapf	Dtmp,w
	xorwf	Dtmp,w
	movwf	Dtmp
	movlw	041h
	addwf	Dtmp,f
	movlw	07ch
	iorwf	Dtmp,f
	movlw	02h
	addwf	Dtmp,f
	rlf	Dtmp,f
	endm




Tset	macro	bit
	movlw	mask | 1 << bit
	TRIS	GPIO
	endm

Tclr	macro	bit
	movlw	mask & ~( 1 << bit )
	TRIS	GPIO
	endm

;
; print location mHval as two hex digits <4-7><0-3>
;
Phex	macro	mHval
	swapf	mHval,w
	call	rPnib
	movf	mHval,w
	call	rPnib
	endm
;
; Pchar <mIval> print immediate value as a character
;
Pchar	macro	mIval
	movlw	mIval
	call	routch
	endm

	
;
; convert bits <0-3> of W to its ASCII equvalent in Otemp then prints it out 
;
rPnib	andlw	0fh
	movwf	Otemp
	movlw	6
	addwf	Otemp,f
	movlw	0x2a
	skpndc
	movlw	0x2a+0x07
	addwf	Otemp,w
	goto	routch
;
; rinch read one char from serial line to Otemp echo back
;
rinch
	#if	rxbit==txbit
	Tset	rxbit
	#endif
	movlw	080h
	movwf	Otemp			; set accumulator to 080h to act as a flag ...
in0	btfsc	GPIO,rxbit		; wait for a start bit
	goto	in0
	movlw	delh+delf		; wait one and a half bit times
in1	movwf	Dtmp			; and one bit time
	decfsz	Dtmp,f
	goto	$-1
	clrc				; assume we got a zero
	btfsc	GPIO,rxbit		; we did so skip ..
	setc				; else cy=1
	movlw	delf			; for one bit delay
	rrf	Otemp,f
	skpc
	goto	in1
	movwf	Dtmp			; skip the stop bt
	decfsz	Dtmp,f
	goto	$-1	
in2	movf	Otemp,w			; for outch !!!

;
; routch Real output char rtn ... patchable .. munches Stmp=bit counter, Ztmp=delay counter and Dtmp=Data accumulator
;
routch	movwf	Dtmp			; save entry byte here
	#if	rxbit==txbit
	Tclr	txbit
	#endif
outch2	movlw	11			; 8 bits + one stop
	movwf	Stmp			; for now !!!!!!
	bcf	GPIO,txbit		; send a start bit
	movlw	delf
oc2	movwf	Ztmp
	decfsz	Ztmp,f
	goto	$-1			; wait one bit time
	setc				; shift stop bits into accum
	rrf	Dtmp,f			; shift/test LSB
	skpc
	bcf	GPIO,txbit		; assume it's a 0
	skpnc				; it was so skip
	bsf	GPIO,txbit		; else so do a 1
	decfsz	Stmp,f			; backup bit count
	goto	oc2
	retlw	0

	