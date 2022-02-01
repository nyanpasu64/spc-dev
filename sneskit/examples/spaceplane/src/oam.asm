;-------------------------------------------------------------------------;
.include "oam.inc"
.include "snes.inc"
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


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
ResetOAM:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	ldx	#oam_table
	stx	REG_WMADDL
	stz	REG_WMADDH

	ldx	#0080h
	lda	#0e0h
:	sta	REG_WMDATA
	sta	REG_WMDATA
	stz	REG_WMDATA
	stz	REG_WMDATA
	dex
	bpl	:-

	ldx	#oam_hitable
	stx	REG_WMADDL
	ldx	#0010h
:	stz	REG_WMDATA
	stz	REG_WMDATA
	dex
	bpl	:-

	rts

