;-------------------------------------------------------------------------;
.include "nmi.inc"
.include "oam.inc"
.include "options.inc"
.include "snes.inc"
.include "snes_joypad.inc"
;-------------------------------------------------------------------------;
.global _nmi
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
	.code
;/////////////////////////////////////////////////////////////////////////;


	.a16
	.i16


;-------------------------------------------------------------------------;
; NMI irq handler
;=========================================================================;
_nmi:
;=========================================================================;
	rep	#30h			; push a,x,y
					;
	pha				;
	phx				;
	phy				;---------------------------------;
					;
	sep	#20h			; 8bit akku
;---------------------------------------;---------------------------------;
	lda	options			;
	bit	#OPTION_FRAME_READY	;
	beq	_frame_not_ready	;
;---------------------------------------;---------------------------------;
	stz	REG_OAMADDL		; reset oam access
	stz	REG_OAMADDH		;
					;---------------------------------;
	lda	#%00000010		; copy oam buffers
	sta	REG_DMAP4		;
	lda	#REG_OAMDATA&255	;
	sta	REG_BBAD4		;
	ldy	#oam_table&65535	;
	lda	#^oam_table		;
	sty	REG_A1T4L		;
	sta	REG_A1B4		;
	ldy	#544			;	
	sty	REG_DAS4L		;
	lda	#%00010000		;
	sta	REG_MDMAEN		;
;---------------------------------------;---------------------------------;
_frame_not_ready:			;
;---------------------------------------;---------------------------------;
	jsr	joyRead			; read joypads
					;---------------------------------;
	lda	REG_TIMEUP		; read from REG_TIMEUP (?)
					;
	rep	#30h			; pop a,x,y
					;
	ply				;
	plx				;
	pla				;
					;
	rti				; return
