;********************************************************************
; Software License Agreement
;
; The software supplied herewith by Microchip Technology
; Incorporated (the "Company") is intended and supplied to you, the
; Company’s customer, for use solely and exclusively on Microchip
; products. The software is owned by the Company and/or its supplier,
; and is protected under applicable copyright laws. All rights are
; reserved. Any use in violation of the foregoing restrictions may
; subject the user to criminal sanctions under applicable laws, as
; well as to civil liability for the breach of the terms and
; conditions of this license.
;
; THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,
; WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
; TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
; PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;
;********************************************************************

        LIST

; VARS.INC  INCLUDE FILE CONTAINING 
;           DECLARATIONS AND MACROS
;       NOLIST

;*******************************************************
;*                                                     *
;*                USED REGISTERS                       *
;*                                                     *
;*******************************************************

	CBLOCK  0x08
        temp1
        temp2

	txreg
        
        freqhi
        freqlo

        averagehi
        averagelo
        averagefraction

        avhitemp
        avlotemp

        differencehi
        differencelo

        t0prescaler
        
        userflag
        ENDC

;*******************************************************
;*                                                     *
;*                BIT DEFINITIONS                      *
;*                                                     *
;*******************************************************

; bit definitions in gpio
output     		equ .1

; bit definitions in userflag
keydown 		equ .0
lockavg 		equ .1      ; lock the averaging mechanism during continuous touch
sleeping 		equ	.3		; for use in going to and waking from sleep
oneshotdone		equ .4		; for use in seeing if one shot trigger output has happened - set on press, clr on release

         LIST
