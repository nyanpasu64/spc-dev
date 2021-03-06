;*************************************************************************;
; SNESKit template
;*************************************************************************;

;-------------------------------------------------------------------------;
.include "oam.inc"
.include "screen.inc"
.include "snes.inc"
.include "snes_joypad.inc"
.include "snes_zvars.inc"
.include "graphics.inc"
;-------------------------------------------------------------------------;
.import DoSprite, clear_vram
;-------------------------------------------------------------------------;
.global _nmi, main
;-------------------------------------------------------------------------;
.exportzp timer
;-------------------------------------------------------------------------;



;/////////////////////////////////////////////////////////////////////////;
.zeropage
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
frame_ready:
	.res	1
timer:	.res	2
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


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
.code
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;


;-------------------------------------------------------------------------;
	.a8
	.i16
;-------------------------------------------------------------------------;


;::.....................................................................::;
; program entry point
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
main:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	stz	frame_ready
	ldx	#0000h
	stx	timer
	lda	#NMI_ON|NMI_JOYPAD
	sta	REG_NMITIMEN
;-------------------------------------------------------------------------;
	cli				; enable IRQ
;-------------------------------------------------------------------------;
	jmp	DoSprite


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
FadeInMosaic:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	lda	m1
	lsr
	cmp	#16
	beq	@endm
	sta	REG_INIDISP
	
	asl
	asl
	asl
	asl
	eor	#0f0h
	ora	#%111
	sta	REG_MOSAIC
	inc	m1

@endm:	rts
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
FadeOut:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	lda	#15			; fade out screen
:	wai				;
	dea				;
	sta	REG_INIDISP		;
	bne	:-			;
;--------------------------------------------------------------------
	lda	#80h
	sta	REG_INIDISP
;--------------------------------------------------------------------
	stz	m1
	rts
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
ScreenSaver:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	lda	m1
	cmp	#15
	bcc	_exit
;-------------------------------------------------------------------------;
	ldx	timer
	cpx	#60*120
	beq	GoDark
;-------------------------------------------------------------------------;
	lda	joy1_down
	eor	joy2_down
	eor	joy1_down+1
	eor	joy2_down+1
	beq	_exit
;-------------------------------------------------------------------------;
	lda	#0fh
	bra	SetIni
;-------------------------------------------------------------------------;
GoDark:	lda	#01h
SetIni:	sta	REG_INIDISP
	ldx	#0000h
	stx	timer

_exit:	rts
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
SpriteInit:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	ldx	#0000h
	lda	#01h
@setoffscr:
	sta	oam_table,x
	inx
	stz	oam_table,x
	inx
	cpx	#0200h
	bne	@setoffscr

	ldx	#0000h
	lda	#55h
@clr:	sta	oam_hitable,x		; initialize all sprites to be off the screen
	inx
	cpx	#0020h
	bne	@clr

	rts


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
