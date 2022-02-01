;*************************************************************************;
; SNESKit template
;*************************************************************************;

;-------------------------------------------------------------------------;
.include "snes.inc"
.include "snes_decompress.inc"
.include "snes_zvars.inc"
.include "snes_joypad.inc"
;-------------------------------------------------------------------------;
.import DoSine
;-------------------------------------------------------------------------;
.global _nmi, main
.global oam_table, oam_hitable
;-------------------------------------------------------------------------;
.exportzp frame_ready
;-------------------------------------------------------------------------;

;/////////////////////////////////////////////////////////////////////////;
.zeropage
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
frame_ready:
	.res	1
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.bss
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
;oam_table:
;	.res	(128*4)
;oam_hitable:
;	.res	(128/4)
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
	lda	#80h			;
	sta	REG_INIDISP		;
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
	lda	#NMI_ON|NMI_JOYPAD	; enable NMI & auto-joypad [81h]
	sta	REG_NMITIMEN		;
;---------------------------------------;---------------------------------;
	cli				;
	wai				;
;---------------------------------------;---------------------------------;
	;lda	#1			;
	;sta	frame_ready		;
;---------------------------------------;---------------------------------;
	jmp	DoSine			;
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
;---------------------------------------;---------------------------------;
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

