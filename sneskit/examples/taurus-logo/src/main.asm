;*************************************************************************;
; SNESKit template
;*************************************************************************;

;-------------------------------------------------------------------------;
.include "snes.inc"
.include "snes_joypad.inc"
;.include "snesmod.inc"
;.include "soundbank.inc"
;-------------------------------------------------------------------------;
.import DoTaurusLogo
;-------------------------------------------------------------------------;
.global _nmi, main
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.code
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
	.a8
	.i16
;-------------------------------------------------------------------------;


;.........................................................................;
; program entry point
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
main:
;:::::::::::::::::::::::::::::::::::::::;:::::::::::::::::::::::::::::::::;
	;jsr	spcBoot			; boot SPC
	;lda	#^__SOUNDBANK__		; setup soundbank
	;jsr	spcSetBank		;
	;lda	#^SoundTable|80h	; setup soundtable
	;ldy	#.LOWORD(SoundTable)	;
	;jsr	spcSetSoundTable	;
					;
	;lda	#38			; (*256 bytes = largest sound size)
	;jsr	spcAllocateSoundRegion	;
;---------------------------------------;---------------------------------;
	jmp	DoTaurusLogo
;---------------------------------------;---------------------------------;

;.........................................................................;
; NMI irq handler
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
_nmi:
;:::::::::::::::::::::::::::::::::::::::;:::::::::::::::::::::::::::::::::;
	rep	#30h			; a,x,y = 16-biy
					;
	pha				; push a,x,y
	phx				;
	phy				;
					;
	sep	#20h			; a = 16-bit

	jsr	joyRead			; read joypads
					;--------------------------
	lda	REG_TIMEUP		; read from REG_TIMEUP
					;
	rep	#30h			; a,x,y = 16-bit
					;
	ply				; pop y,x,a
	plx				;
	pla				;
	rti				; return

;/////////////////////////////////////////////////////////////////////////;
.segment "HDATA"
;/////////////////////////////////////////////////////////////////////////;
.segment "HRAM"
;/////////////////////////////////////////////////////////////////////////;
.segment "HRAM2"
;/////////////////////////////////////////////////////////////////////////;
