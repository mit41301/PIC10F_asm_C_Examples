; half-duplex 81N serial uart in hand-tuned assembler
; * 1%/2% Tx/Rx timing error for 115.2kbps@8Mhz
; * 2%/1% Tx/Rx timing error for 230.4kbps@8Mhz
; * optimized for no jitter vs AVR305 with 1 cycle/bit jitter
; * @author: Ralph Doncaster
; * @version: $Id$
; Supports using only one pin on the AVR for both Tx and Rx
;              D1
;  AVR ----+--|>|-----+----- Tx
;          |      10K $ R1
;          +--------(/^\)--- Rx
;               NPN E   C
; 


.include	"Tiny10.inc"
.include	"BasicSerial.h"
.equ	BS,0x08
.equ	LF,0x0a
.equ	CR,0x0d
.equ	RAMSTART,0x40
.equ	RAMEND,0x5f
.equ	UART_Port,PORTB 
.equ	UART_Tx,2
.equ	UART_Rx,2
.equ	accA,16
.equ	accB,17
.equ	Tmp,21
.org	0x0000
start:	cli
				; set SP
	ldi	accA,lo8(RAMEND)	
	out	SPL,accA
	ldi	accA,hi8(RAMEND)
	out	SPH,accA
				; set clock divider
	ldi r16, 0x02		; clock divided by 4
	ldi r17, 0xD8		; the key for CCP
	out CCP, r17		; Configuration Change Protection, allows protected changes
	out CLKPSR, r16		; sets the clock divider
	sbi	PORTB,UART_Tx
	cbi	DDRB,UART_Tx
main:	ldi	accB,16
prtolp:	push	accB
	ldi	accA,' '
prtlp:	push	accA
	rcall	Outch
	pop	accA
	inc	accA
	cpi	accA,'q'
	brne	prtlp
	pop	accB
	dec	accB
	brne	prtolp
	rcall	crlf
	ldi	ZL,lo8(msg + MAPPED_FLASH_START )
	ldi	ZH,hi8(msg + MAPPED_FLASH_START )
	rcall	TxString
	ldi	ZL,lo8(foxes + MAPPED_FLASH_START )
	ldi	ZH,hi8(foxes + MAPPED_FLASH_START )
	rcall	TxString
	rcall	Inch
	rjmp	main


.global	TxString
; transmit a null terminated string in flash
; enter Zl,Zh -> string
TxString:	ld	accA,Z+			; get next char
	cpi	accA,0x00
	brne	TxStr1
	ret
TxStr1:	rcall	Outch
	rjmp	TxString
;
; print a blank
;
Space:	ldi	accA,' '			; space char
	rjmp	Outch
;
; throw a new linw couplet
;
crlf:	ldi	accA,CR
	rcall	Outch
	ldi	accA,LF

.global Outch
; transmit byte in accA 
; calling code must set Tx line to idle state (high) or 1st byte may be lost
; i.e. PORTB |= (1<<UART_Tx)
; munches accA,aCCb and Tmp
Outch:	cli
	sbi	UART_Port-1, UART_Tx	; set Tx line to output
	cbi	UART_Port, UART_Tx	; start bit
	in	accB, UART_Port
	ldi	Tmp, 15			; stop bit + idle state
					; 8 cycle loop + delay - total = 7 + 3*r22
TxLoop:	ldi	accB,TXDELAY		; delay (3 cycle * accB) -1
TxDelay:	dec	accB
	brne	TxDelay
	in	accB,UART_Port
	bst	accA,0			; store lsb in T
	bld	accB,UART_Tx
	lsr	Tmp
	ror	accA
	out	UART_Port, accB
	brne	TxLoop
	reti				; return and enable interrupts


.global Inch
#define	RX_PULLUP
; receive byte into accA
; munches accA and accB for delay timing
Inch:	cbi	UART_Port-1, UART_Rx  	; set Rx line to input
#ifdef RX_PULLUP
	sbi	UART_Port, UART_Rx  	; enable pullup
#endif
	ldi	accA,0x80		; data accumulator and bit shift counter
WaitStart:
	sbic	PINB, UART_Rx 	; wait for start edge
	rjmp	WaitStart
	cli				; 6 cycle loop + delay - total = 5 + 3*r22
					; delay (3 cycle * accA) -1 and clear carry with subi
Rxb0:	ldi	accB,RXDELAY+RXDELAY >>1	; get 1.5 bit delay
RxBit:	subi	accB, 1			; delay accB bits times
	brne	RxBit
	ldi	accB,RXDELAY		; 1 bit delay
	sbic	PINB, UART_Rx	; check UART PIN
	sec
	ror	accA
	brcc	RxBit
StopBit:	dec	accB			; accb has 1 bit time count
        	brne	StopBit
	reti				; return and enable interrupts


msg:	.ascii	"Hello, World!"
	.byte	0x0d,0x0a,0x00
foxes:	.ascii	"The quick brown fox jumps over the lazy dog!"
	.byte	0x0d,0x0a,0x00


