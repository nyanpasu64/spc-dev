;-------------------------------------------------------------------------;
.include "render_string.inc"
.include "snes.inc"
;-------------------------------------------------------------------------;


;=========================================================================;
;           Converted from Mukunda's macro in Skipp and Friends
;=========================================================================;


;/////////////////////////////////////////////////////////////////////////;
.zeropage
;/////////////////////////////////////////////////////////////////////////;


text_address:
	.res 3


;/////////////////////////////////////////////////////////////////////////;
.bss
;/////////////////////////////////////////////////////////////////////////;


render_string_palette:
	.res 1


;/////////////////////////////////////////////////////////////////////////;
	.code
;/////////////////////////////////////////////////////////////////////////;


	.a8
	.i16


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
RenderString:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	stx	text_address
	sty	REG_VMADD
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:++
;-------------------------------------------------------------------------;
:	iny
	sta	REG_VMDATAL
	xba
	sta	REG_VMDATAH
;-------------------------------------------------------------------------;
:	xba
	lda	[text_address],y
	bne	:--
	rts

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
RenderStringBank0:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	stz	text_address+2
	bra	RenderString

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
RenderStringGetPalette:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	lda	render_string_palette
	bra	RenderString

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
RenderStringSetBank:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	sta	text_address+2
	rts

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
RenderStringSetPalette:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	sta	render_string_palette
	rts