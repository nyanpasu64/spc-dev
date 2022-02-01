;-------------------------------------------------------------------------;
.include "graphics.inc"
.include "snes.inc"
.include "snes_decompress.inc"
.include "snes_zvars.inc"
;-------------------------------------------------------------------------;
.export LargeScreen
;-------------------------------------------------------------------------;
MAX_WAI = 2
SC_OPT = SC_64x64

BG1GFX	= 00000h
BG1MAP1	= 0c000h

bg1hofs	= m7
bg1vofs	= m6
wait	= m5
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.code
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
	.a8
	.i16
;-------------------------------------------------------------------------;


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
LargeScreen:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	rep	#10h
	sep	#20h

	DoDecompressDataVram gfx_arm_warTiles, BG1GFX
	DoDecompressDataVram gfx_arm_warMap, BG1MAP1
	DoCopyPalette gfx_arm_warPal, 0, 64

	lda	#MAX_WAI
	sta	wait

	lda	#BGMODE_3
	sta	REG_BGMODE

	lda	#(BG1MAP1>>9)|SC_OPT
	sta	REG_BG1SC

	lda	#TM_BG1
	sta	REG_TM

	lda	#0fh
	sta	REG_INIDISP
;=========================================================================;
Loop:
;=========================================================================;
	lda	REG_RDNMI
	bpl	Loop
;-------------------------------------------------------------------------;
	dec	wait
	lda	wait
	bne	Loop
;-------------------------------------------------------------------------;
	lda	#MAX_WAI
	sta	wait

	inc	bg1vofs
	lda	bg1vofs
	sta	REG_BG1HOFS
	bne	:+
;-------------------------------------------------------------------------;
	inc	bg1vofs+1
;-------------------------------------------------------------------------;
:	lda	bg1vofs+1
	and	#%11
	sta	REG_BG1HOFS
	sta	bg1vofs+1
	bra	Loop
