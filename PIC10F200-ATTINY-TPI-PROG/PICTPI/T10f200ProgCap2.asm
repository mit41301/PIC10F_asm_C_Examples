	Processor	10f200
	#include    <p10f200.inc>
	radix	DEC
; ext reset, no code protect, no watchdog, 4Mhz int clock
     __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC
	list
Ram		equ	010h
AddressHi	equ	Ram
AddressLo	equ	AddressHi+1
DataHi		equ	AddressLo+1
DataLo		equ	DataHi+1
Dtmp		equ	DataLo+1
Otemp		equ	Dtmp+1
IP		equ	Otemp+1
Wr1		equ	IP+1
RetCode		equ	Wr1
Stmp		equ	Wr1+1
Xtmp		equ	Stmp+1
Ztmp		equ	Xtmp+1

sClk		equ	0		; TPI clock
sDat		equ	1		; TPI data
sRst		equ	0		; TPI reset is shared with the clock
txbit		equ	2		; serial IO to console/app
rxbit		equ	2		; uses just one bit !
mask		equ	~(1 << sClk | 1 << txbit |1 << sDat | 1 << sRst) & 3fh
optval		equ	b'11000000'
;
;
;
	org	0x00
Start	movwf	OSCCAL			; set oscillator callibration
	goto	Rst


#define	TESTING
	#ifdef	TESTING
	#include	<Tiny10DBGS.inc>		; includes IO roitines and set clear macros
	#endif				; end of TESTING


sndRx	sndByte	024h			; send a read byte command and increment pointer
rgetByte
	Tset	sDat			; set data line to INPUT
	clrf	Xtmp			; try this many times ( for i=0 i <256; i++)
getBlp	decf	Xtmp,f			; check loop count (i--)
	skpnz
	retlw	-1
	bcf	GPIO,sClk		; set clock LOW to get one bit
	movlw	0			; assume we have a zero
	btfsc	GPIO,sDat		; it is so skip
	movlw	1			; Cy=1 ....
	bsf	GPIO,sClk		; set clock HIGH
	iorlw	0			; 0 or 1 ? 0=a start bit ....
	skpz				; it was zero so carry on
	goto	getBlp
	clrf	Wr1			; we got a start bit sooooo ..clear down accum
	clrf	Dtmp			; ... 16 bits
	movlw	11			; collect 11 bits: 8 data, P , st, st
	movwf	Xtmp			; for(Xtmp=11; Xtmp >0; Xtmp - -)
getB0	bcf	GPIO,sClk		; set clock LOW to get one bit
	btfsc	GPIO,sDat		; it is a zero so skip
	bsf	Dtmp,3			; put a bit in the accumulator and ....
	bsf	GPIO,sClk		; set clock HIGH
	clrc				; shift a zero to the MSB 
	rrf	Dtmp,f			; now do a ...
	rrf	Wr1,f			; ... 16 bit shift
	decfsz	Xtmp,f			; backup for loop counter (Xtmp - -)
	goto	getB0			; carry on
	retlw	0			; go back
;
; set the address in Buffer,Buffer+1 Hi Lo
;
rsetAddr
	sndByte	068h			; set address low cmd
	movf	AddressLo,w		; low address
	call	rsndFrame		; send that frame
	sndByte	069h			; set address high cmd
	movf	AddressHi,w		; high address and drop into  ...

rsndFrame
	movwf	Wr1			; save entry data
	Tclr	sDat			; set data to output
	movf	Wr1,w
	mmakepar			; create parity bit in carry
	clrf	Dtmp			; high byte of 12 bit word
	rlf	Dtmp,f			; shift parity in
	rlf	Wr1,f
	rlf	Dtmp,f		 	; bit 0 of Wr1=start bit=0
	bsf	Dtmp,2
	bsf	Dtmp,3			; two stopbits
	movlw	12			; bit counter
	movwf	Otemp			; save it here
sndb0	btfsc	Wr1,0			; is it a 0 ?
	bsf	GPIO,sDat		; nope send a one
	btfss	Wr1,0			; or a 1 ?
	bcf	GPIO,sDat		; so send a 0
	bcf	GPIO,sClk		; set Clock LOW
	bsf	GPIO,sClk		; set Clock HIGH
	rrf	Dtmp,f			; shift next bits ...
	rrf	Wr1,f			; ... as a 16 bit lump
	decfsz	Otemp,f			; backup bit counter
	goto	sndb0			; loop on
	retlw	0			; back to whence we came
;
;
;

;
; send at least 16 high pulses to initaalise the line 
;
rinitLine
xinitl	Tclr	sDat			; set data to OUTPUT
	movlw	17			; fro(i=0; I < 17; i++)
	movwf	Dtmp			; counter
	bsf	GPIO,sDat		; set data line to one
do16	bcf	GPIO,sClk		; set Clock LOW
	bsf	GPIO,sClk		; set Clock HIGH
	decfsz	Dtmp,f			; backup counters
	goto	do16			; loop till done
	sndByte	0e0h			; send init NVM Key
	sndByte	0ffh			; ... plus the key
	sndByte	088h
	sndByte	0d8h
	sndByte	0cdh
	sndByte	045h
	sndByte	0abh
	sndByte	089h
	movlw	012h
	goto	rsndFrame		; get out via sending last byte
	
;
; writeWord writes the word at DataHi,DataLo to AddressHi,AddressLo
;
rwriteWord
wrt1	sndByte	0f3h
	sndByte	01dh			; send a write command
	sndByte	064h
	movf	DataHi,w			; then dat HIGH LOW
	call	rsndFrame
WrtHi	sndByte	064h
	movf	DataLo,w
	call	rsndFrame
Dunnit	sndByte	072h			; send read status command
	call	rgetByte			; get status back
	btfsc	RetCode,7		; wait for command completion
	goto	Dunnit
	retlw	0			; done
;
; erase the page set by the caller
;
reraPg	sndByte	0f3h			; send erase command
	sndByte	014h
	goto	WrtHi			; ANY write to the high byte starts the page erase

;
; rgetAddr read a 4 hex digit word to AddressHi,AddressLo
;
rgetAddr
	movlw	AddressHi		; address info goes here
rget4Hex
	movwf	FSR			; Point FSR at Buffer (entry param)
	clrf	IP
rget4H	clrf	INDF
rget4H0	call	rinch			; read a byte into the buffer
	movlw	'0'
	subwf	Otemp,f
	skpc
	goto	rget4H0
	movlw	':'-'0'
	subwf	Otemp,w
	skpc
	goto	ishex
	movlw	'A'-'0'
	subwf	Otemp,w
	skpc
	goto	rget4H0
	movlw	'G'-'0'
	subwf	Otemp,w
	skpnc
	goto	rget4H0
	movlw	7
	subwf	Otemp,f
ishex	swapf	INDF,f
	movf	Otemp,w
	iorwf	INDF,f
	incf	IP,f
	btfsc	IP,0
	goto	rget4H0
	incf	FSR,f			; bump ptr
	btfsc	FSR,0			; 0 ->1 -> 0 for two bytes ....
	goto	rget4H			; loop till done
	retlw	0

Rst	movlw	mask			; set txbit and LED as output
	TRIS	GPIO
	movlw	(~mask) & 03eh		; 1 << sClk | 1 << txbit | 1 << sRst | 1 << sDat
	movwf	GPIO
	movlw	optval			; set option reg values
	option				; the set the option reg
main	Pchar	0ah			; do a newline
	movlw	'#'
	call	routch
	call	rinch			; read a char
	movlw	'I'
	subwf	Otemp,w
	skpnc
	goto	main
	movlw	'A'
	subwf	Otemp,f
	skpc
	goto	main
	movf	Otemp,w
	addwf	PCL,f
	goto	SetCmd			; Set A=Address
ConCmd	call	rinitLine			;  B=Begin programming initialise TPI 
	goto	main			; C=not used
DiscCmd	bcf	GPIO,sRst		;  D=Disconnect programming set reset line high (inverted)=disconnect
	goto	main			; E not used
	goto	EraCmd			; f= Format (erase) current segment
	goto	RdCmd			; G=Get data from chip
;
; H=HexEdit (Write) data to current address
;
WrtCmd	movlw	DataHi			; pointer to data
	call	rget4Hex			; common entry point to read 2 bytes of data
	call	rwriteWord		; write them to flash
	goto	main			; continue
;
; A Set Address to use 
;
SetCmd	call	rgetAddr			; get a 2 byte address
	call	rsetAddr			; set address on chip
	goto	main
;
; G=Get Bytes read 2 bytes current address
;
RdCmd
	call	sndRx			; send a read byte command and increment pointer
	Phex	RetCode
	call	sndRx			; send a read byte command and increment pointer
	Phex	RetCode
	goto	main			; carry on
.;
; F=Format (Erase) current segment
;
EraCmd	bsf	AddressLo,0		; make the address the high byte
	call	rsetAddr			; set address on chip
	call	reraPg			; erase the page
	goto	main
	end
