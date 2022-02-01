;-------------------------------------------------------------------------;
.include "color_change.inc"
.include "snes.inc"
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.zeropage
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
cc_cgadd:
	.res 1
cc_cgdata:
	.res 2
storage:
	.res 2
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.code
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
	.a8
	.i16
;-------------------------------------------------------------------------;


;=========================================================================;
IncreaseBlue:
;=========================================================================;
	lda	cc_cgdata+1
	and	#7ch
	cmp	#7ch
	beq	exit1
;-------------------------------------------------------------------------;
	lda	cc_cgdata+1
	ror	a
	ror	a
	inc	a
	rol	a
	rol	a
	sta	cc_cgdata+1
;-------------------------------------------------------------------------;
exit1:	rts
;=========================================================================;
IncreaseGreen:
;=========================================================================;
	lda	cc_cgdata+1
	and	#03h
	cmp	#03h
	beq	incgrn1
;-------------------------------------------------------------------------;
incgrn2:
;-------------------------------------------------------------------------;
	lda	cc_cgdata
	and	#0e0h
	cmp	#0e0h
	beq	incgrn3
;-------------------------------------------------------------------------;
	lda	#20h
	clc
	adc	cc_cgdata
	sta	storage
	lda    	cc_cgdata
	and	#1fh
	ora	storage
	sta	cc_cgdata
	rts
;-------------------------------------------------------------------------;
incgrn1:
;-------------------------------------------------------------------------;
	lda	cc_cgdata
	and	#0e0h
	cmp	#0e0h
	bne	incgrn2
	rts
;-------------------------------------------------------------------------;
incgrn3:
;-------------------------------------------------------------------------;
	inc	cc_cgdata+1
	lda	cc_cgdata
	and	#1fh
	sta	cc_cgdata
	rts
;=========================================================================;
DecreaseBlue:
;=========================================================================;
	lda	cc_cgdata+1
	bit	#7ch
	beq	exit1
	ror	a
	ror	a
	dec	a
	rol	a
	rol	a
	sta	cc_cgdata+1
	rts
;=========================================================================;
DecreaseGreen:
;=========================================================================;
	lda	cc_cgdata
	and	#0e0h
	beq	decgrn2
;-------------------------------------------------------------------------;
decgrn1:
;-------------------------------------------------------------------------;
	rol	a
	rol	a
	rol	a
	rol	a
	dec	a
	ror	a
	ror	a
	ror	a
	ror	a
	sta	storage
	lda	cc_cgdata
	and	#1fh
	ora	storage
	sta	cc_cgdata
	rts
;-------------------------------------------------------------------------;
decgrn2:
;-------------------------------------------------------------------------;
	lda	cc_cgdata+1
	and	#03h
	beq	exit1
;-------------------------------------------------------------------------;
	dec	cc_cgdata+1
	lda	#0e0h
	ora	cc_cgdata
	sta	cc_cgdata
	rts
;=========================================================================;
IncreaseRed:
;=========================================================================;
	lda	cc_cgdata
	and	#1fh
	cmp	#1fh
	beq	exit1
	inc	cc_cgdata
	rts
;=========================================================================;
DecreaseRed:
;=========================================================================;
	lda	cc_cgdata
	and	#1fh
	beq	exit1
	dec	cc_cgdata
	rts
;=========================================================================;
IncreaseRGB:
;=========================================================================;
	sta	cc_cgadd
	jsr	IncreaseRed
	jsr	IncreaseGreen
	jsr	IncreaseBlue
	bra	SetColor
;=========================================================================;
DecreaseRGB:
;=========================================================================;
	sta	cc_cgadd
	jsr	DecreaseBlue
	jsr	DecreaseGreen
	jsr	DecreaseRed
;=========================================================================;
ScreenOffSetColor:
;=========================================================================;
	lda	#8fh
	sta	REG_INIDISP
;=========================================================================;
SetColor:
;=========================================================================;
	lda	cc_cgadd
	sta	REG_CGADD
	lda	cc_cgdata
	sta	REG_CGDATA
	lda	cc_cgdata+1
	sta	REG_CGDATA
	bcc	:+
;-------------------------------------------------------------------------;
	lda	#0fh
	sta	REG_INIDISP
:	rts
;=========================================================================;
GetColor:
;=========================================================================;
	sta	cc_cgadd
	sta	REG_CGADD
	lda	REG_CGDATA
	sta	cc_cgdata
	lda	REG_CGDATA
	sta	cc_cgdata+1
	rts