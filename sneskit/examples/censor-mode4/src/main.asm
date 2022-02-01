;*************************************************************************;
; SNESKit template
;*************************************************************************;

;-------------------------------------------------------------------------;
.include "snes.inc"
.include "snes_joypad.inc"
;.include "snesmod.inc"
;.include "soundbank.inc"
;-------------------------------------------------------------------------;
.import DoMode4
;-------------------------------------------------------------------------;
.global _nmi, main
;-------------------------------------------------------------------------;
.exportzp frame_ready
;-------------------------------------------------------------------------;
.export oam_hitable, oam_table
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
oam_table:
	.res	(128*4)
oam_hitable:
	.res	(128/4)
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
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
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
	jmp	DoMode4


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
	lda	frame_ready		; skip frame update if not ready!
	cmp	#1			;
	bne	_frame_not_ready	;
;---------------------------------------;---------------------------------;
	ldy	#0000h			;
	sty	REG_OAMADDL		; reset oam access
					;---------------------------------;
	lda	#DMAP_XFER_MODE_2	; copy oam buffers
	sta	REG_DMAP6		;
	lda	#<REG_OAMDATA		;
	sta	REG_BBAD6		;
	ldy	#oam_table&65535	;
	lda	#^oam_table		;
	sty	REG_A1T6L		;
	sta	REG_A1B6		;
	ldy	#544			;	
	sty	REG_DAS6L		;
	lda	#%01000000		;
	sta	REG_MDMAEN		;
;---------------------------------------;---------------------------------;
_frame_not_ready:			;
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
