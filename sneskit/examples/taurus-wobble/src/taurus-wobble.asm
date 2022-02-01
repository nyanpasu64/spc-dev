;-------------------------------------------------------------------------;
.include "copying.inc"
.include "snes.inc"
.include "snes_decompress.inc"
.include "snes_joypad.inc"
.include "snes_zvars.inc"
;-------------------------------------------------------------------------;
.export DoTaurusWobble
;-------------------------------------------------------------------------;


;-------------------------------------------------------------------------;
RAM_CGDATA = 0500h
RAM_STUFF = 0600h	; too lazy to define what these do
RAM_M7A	= 1000h
;-------------------------------------------------------------------------;


;-------------------------------------------------------------------------;
bg1_vofs_index	=	0408h
end_flag	=	bg1_vofs_index+2
fade_in_delay	=	end_flag+1
fi_inidisp	=	fade_in_delay+1
fo_inidisp	=	fi_inidisp+1
loop1_timer	=	fo_inidisp+1
m7c_index	=	loop1_timer+2
m7x_index	=	m7c_index+2
m7y_index	=	m7x_index+2
shadow_m7a	=	m7y_index+2
zoom_in1	=	shadow_m7a+2
routine		=	zoom_in1+2
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.code
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
	.a8
	.i16
;-------------------------------------------------------------------------;


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
DoTaurusWobble:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;

	rep	#10h
	sep	#20h

	lda	#80h
	sta	REG_INIDISP
	sta	REG_VMAIN

	stz	REG_M7A
	sta	REG_M7A
	stz	REG_M7D
	sta	REG_M7D
	lda	#30h
	sta	REG_CGSWSEL
	lda	#0e0h
	sta	REG_COLDATA
	lda	#0ffh
	sta	REG_WRIO

	stz	REG_BG1SC
	stz	REG_BG12NBA
	lda	#BGMODE_7
	sta	REG_BGMODE
	lda	#TM_BG1
	sta	REG_TM
	stz	REG_M7SEL
	lda	#0a3h
	sta	REG_OBSEL
;-------------------------------------------------------------------------;
	DoCopyPalette PLASMA_PAL, 0, 64
;-------------------------------------------------------------------------;
	lda	#^M7MAP
	ldy	#M7MAP
	sty	memptr
	sta	memptr+2

	lda	#^M7GFX
	ldx	#M7GFX
	ldy	#0400h

	jsr	Copy256x256Mode7Gfx
;-------------------------------------------------------------------------;
	ldx	#0000h
	txy
:	stz	RAM_M7A,x
	inx
	tya
	sta	RAM_M7A,x
	inx
	stz	RAM_M7A,x
	inx
	iny
	cpy	#00e0h
	bne	:-
;-------------------------------------------------------------------------;
	lda	#0ffh
	sta	REG_DAS0
	sta	REG_DAS0+1
	sta	REG_DAS0+2

	stz	RAM_M7A,x
	stz	REG_HDMAEN

	lda	#DMAP_XFER_MODE_2
	sta	REG_DMAP0
	lda	#<REG_M7A
	sta	REG_BBAD0
	ldx	#RAM_M7A
	stx	REG_A1T0L
	;lda	#^LIST_M7A	; use ^LIST_M7A if LIST_M7A is not in .code
	stz	REG_A1B0

	lda	#01h
	sta	REG_HDMAEN

	stz	RAM_STUFF+011h
	stz	RAM_STUFF+012h
	stz	RAM_STUFF+013h
	stz	RAM_STUFF+065h

	ldx	#0000h
	stx	RAM_STUFF+030h
	stx	RAM_STUFF+000h
	stx	RAM_STUFF+002h
	stx	RAM_STUFF+004h
	stx	RAM_STUFF+006h
	stx	RAM_STUFF+008h
	stx	RAM_STUFF+00ah
	stx	RAM_STUFF+00ch
	stx	RAM_STUFF+00fh
	stx	RAM_STUFF+067h
	stx	RAM_STUFF+069h

	rep	#30h

	lda	#(PLASMA_PAL_END-PLASMA_PAL)-1	; bytes to transfer
	ldx	#PLASMA_PAL			; source address
	ldy	#RAM_STUFF+06bh			; destination address
	mvn	80h,^PLASMA_PAL			; dest bank, source bank
	;	^^-- DBR will equal this value

	sep	#20h

	lda	#NMI_ON|NMI_JOYPAD
	sta	REG_NMITIMEN

	cli
;-------------------------------------------------------------------------;
TaurusLoop:
;-------------------------------------------------------------------------;
	lda	REG_RDNMI
	bpl	TaurusLoop
;-------------------------------------------------------------------------;
	jsr	ColorFade
	jsr	ListM7A
	jsr	RamM7A
	jsr	FadeIn
	jsr	Joypad
	ldx	RAM_STUFF+030h
	cpx	#0400h
	beq	SetEnd
;-------------------------------------------------------------------------;
	inx
	stx	RAM_STUFF+030h
;-------------------------------------------------------------------------;
:	lda	RAM_STUFF+013h
	bne	End
;-------------------------------------------------------------------------;
	bra	TaurusLoop
;-------------------------------------------------------------------------;
SetEnd:	lda	#01h
	sta	RAM_STUFF+065h
	bra	:-
;-------------------------------------------------------------------------;
End:	stz	REG_HDMAEN
	stz	REG_TM
	jmp	DoTaurusWobble


;=========================================================================;
ColorFade:
;=========================================================================;
	lda	RAM_STUFF+065h
	beq	:+
;-------------------------------------------------------------------------;
	ldx	RAM_STUFF+069h
	cpx	#0004h
	beq	:++
;-------------------------------------------------------------------------;
	inx	
	stx	RAM_STUFF+069h
:	rts
;-------------------------------------------------------------------------;
:	ldx	#0000h
	stx	RAM_STUFF+069h
	ldx	RAM_STUFF+067h
	cpx	#0014h
	bne	:+
;-------------------------------------------------------------------------;
	lda	#01h			; set end
	sta	RAM_STUFF+013h
	rts
;-------------------------------------------------------------------------;
:	inx
	stx	RAM_STUFF+067h
	ldx	#0000h
:	lda	RAM_STUFF+08dh,x
	sta	RAM_STUFF+08bh,x
	inx
	cpx	#001eh
	bne	:-
;-------------------------------------------------------------------------;
	ldx	#001eh
:	lda	RAM_STUFF+06bh,x
	sta	RAM_STUFF+06dh,x
	dex
	bpl	:-
;-------------------------------------------------------------------------;
	stz	RAM_STUFF+06bh
	stz	RAM_STUFF+06ch
	stz	RAM_STUFF+0a9h
	stz	RAM_STUFF+0aah
	stz	REG_CGADD
	ldx	#0000h
;-------------------------------------------------------------------------;
:	lda	RAM_STUFF+06bh,x
	sta	REG_CGDATA
	inx
	cpx	#0040h
	bne	:-
;-------------------------------------------------------------------------;
	rts


;=========================================================================;
FadeIn:
;=========================================================================;
	lda	RAM_STUFF+011h
	cmp	#02h
	beq	DoFadeIn
;-------------------------------------------------------------------------;
	ina
	sta	RAM_STUFF+011h
	rts
;-------------------------------------------------------------------------;
DoFadeIn:
;-------------------------------------------------------------------------;
	stz	RAM_STUFF+011h
	lda	RAM_STUFF+012h
	cmp	#0fh
	beq	:+
;-------------------------------------------------------------------------;
	ina
	sta	REG_INIDISP
	sta	RAM_STUFF+012h
;-------------------------------------------------------------------------;
:	rts


;=========================================================================;
Joypad:
;=========================================================================;
	lda	RAM_STUFF+065h
	bne	:+++
;-------------------------------------------------------------------------;
:	lda	REG_HVBJOY
	beq	:-
;-------------------------------------------------------------------------;
	lda	joy1_down
	ora	joy2_down
	bne	:+
;-------------------------------------------------------------------------;
	lda	joy1_down+1
	ora	joy2_down+1
	bne	:+
	rts	
;-------------------------------------------------------------------------;	
:	lda	#01h
	sta	RAM_STUFF+065h
:	rts


;=========================================================================;
ListM7A:
;=========================================================================;
	ldx	#0001h
	ldy	RAM_STUFF+00ah
	sty	RAM_STUFF+006h
	ldy	RAM_STUFF+00ch
	sty	RAM_STUFF+008h
:	ldy	RAM_STUFF+006h
:	lda	LIST_M7A_2,y
	cmp	#0ffh
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny
	sty	RAM_STUFF+006h
	sta	RAM_STUFF+00eh
	ldy	RAM_STUFF+008h
:	lda	LIST_M7A,y
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny
	sty	RAM_STUFF+008h
	clc
	adc	RAM_STUFF+00eh
	sta	RAM_M7A,x
	inx	
	inx	
	inx	
	cpx	#02a1h
	bne	:-----
;-------------------------------------------------------------------------;
	ldy	RAM_STUFF+00ah
:	lda	LIST_M7A_2,y
	cmp	#0ffh
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny
	sty	RAM_STUFF+00ah
	ldy	RAM_STUFF+00ch
;-------------------------------------------------------------------------;
:	lda	LIST_M7A,y
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny
	sty	RAM_STUFF+00ch
	ldy	RAM_STUFF+00ch
;-------------------------------------------------------------------------;
:	lda	LIST_M7A,y
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny
	sty	RAM_STUFF+00ch
	ldy	RAM_STUFF+00ch
;-------------------------------------------------------------------------;
:	lda	LIST_M7A,y
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny
	ldy	RAM_STUFF+00a
;-------------------------------------------------------------------------;
:	lda	LIST_M7A_2,y
	cmp	#0ffh
	bne	:+
;-------------------------------------------------------------------------;
	ldy	#0000h
	bra	:-
;-------------------------------------------------------------------------;
:	iny

	lda	#80h
	sta	REG_M7X
	stz	REG_M7X
	stz	REG_M7Y
	stz	REG_M7Y
	stz	REG_M7D
	stz	REG_M7D
	rts


;=========================================================================;
RamM7A:
;=========================================================================;
	ldx	RAM_STUFF+00fh
	cpx	#02a0h
	beq	:+
;-------------------------------------------------------------------------;
	lda	#01h
	sta	RAM_M7A,x
	inx	
	inx	
	inx	
	stx	RAM_STUFF+00fh
:	rts	


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
LIST_M7A:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
	.byte	$61,$64,$66,$69,$6b,$6e,$70,$73
	.byte	$75,$77,$7a,$7c,$7e,$80,$83,$85
	.byte	$87,$89,$8b,$8c,$8e,$90,$91,$93
	.byte	$95,$96,$97,$98,$9a,$9b,$9c,$9c
	.byte	$9d,$9e,$9f,$9f,$9f,$a0,$a0,$a0
	.byte	$a0,$a0,$a0,$9f,$9f,$9f,$9e,$9d
	.byte	$9c,$9c,$9b,$9a,$98,$97,$96,$95
	.byte	$93,$91,$90,$8e,$8c,$8b,$89,$87
	.byte	$85,$83,$80,$7e,$7c,$7a,$77,$75
	.byte	$73,$70,$6e,$6b,$69,$66,$64,$61
	.byte	$5f,$5c,$5a,$57,$55,$52,$50,$4d
	.byte	$4b,$49,$46,$44,$42,$40,$3d,$3b
	.byte	$39,$37,$35,$34,$32,$30,$2f,$2d
	.byte	$2b,$2a,$29,$28,$26,$25,$24,$24
	.byte	$23,$22,$21,$21,$21,$20,$20,$20
	.byte	$20,$20,$20,$21,$21,$21,$22,$23
	.byte	$24,$24,$25,$26,$28,$29,$2a,$2b
	.byte	$2d,$2f,$30,$32,$34,$35,$37,$39
	.byte	$3b,$3d,$40,$42,$44,$46,$49,$4b
	.byte	$4d,$50,$52,$55,$57,$5a,$5c,$5f
	.byte	$61,$64,$66,$69,$6b,$6e,$70,$73
	.byte	$75,$77,$7a,$7c,$7e,$80,$83,$85
	.byte	$87,$89,$8b,$8c,$8e,$90,$91,$93
	.byte	$95,$96,$97,$98,$9a,$9b,$9c,$9c
	.byte	$9d,$9e,$9f,$9f,$9f,$a0,$a0,$a0
	.byte	$a0,$a0,$a0,$9f,$9f,$9f,$9e,$9d
	.byte	$9c,$9c,$9b,$9a,$98,$97,$96,$95
	.byte	$93,$91,$90,$8e,$8c,$8b,$89,$87
	.byte	$85,$83,$80,$7e,$7c,$7a,$77,$75
	.byte	$73,$70,$6e,$6b,$69,$66,$64,$61
	.byte	$5f,$5c,$5a,$57,$55,$52,$50,$4d
	.byte	$4b,$49,$46,$44,$42,$40,$3d,$3b
	.byte	$39,$37,$35,$34,$32,$30,$2f,$2d
	.byte	$2b,$2a,$29,$28,$26,$25,$24,$24
	.byte	$23,$22,$21,$21,$21,$20,$20,$20
	.byte	$20,$20,$20,$21,$21,$21,$22,$23
	.byte	$24,$24,$25,$26,$28,$29,$2a,$2b
	.byte	$2d,$2f,$30,$32,$34,$35,$37,$39
	.byte	$3b,$3d,$40,$42,$44,$46,$49,$4b
	.byte	$4d,$50,$52,$55,$57,$5a,$5c,$5f
	.byte	$5d,$57,$52,$4c,$47,$42,$3d,$38
	.byte	$34,$30,$2c,$29,$26,$24,$22,$21
	.byte	$20,$20,$20,$21,$22,$24,$26,$29
	.byte	$2c,$30,$34,$38,$3d,$42,$47,$4c
	.byte	$52,$57,$5d,$63,$69,$6e,$74,$79
	.byte	$7e,$83,$88,$8c,$90,$94,$97,$9a
	.byte	$9c,$9e,$9f,$a0,$a0,$a0,$9f,$9e
	.byte	$9c,$9a,$97,$94,$90,$8c,$88,$83
	.byte	$7e,$79,$74,$6e,$69,$63,$00
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
LIST_M7A_2:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
	.byte	$2d,$29,$26,$22,$1f,$1b,$18,$15
	.byte	$12,$0f,$0c,$0a,$08,$06,$04,$03
	.byte	$02,$01,$00,$00,$00,$00,$01,$02
	.byte	$03,$04,$06,$08,$0a,$0c,$0f,$12
	.byte	$15,$18,$1b,$1f,$22,$26,$29,$2d
	.byte	$31,$35,$38,$3c,$3f,$43,$46,$49
	.byte	$4c,$4f,$52,$54,$56,$58,$5a,$5b
	.byte	$5c,$5d,$5e,$5e,$5e,$5e,$5d,$5c
	.byte	$5b,$5a,$58,$56,$54,$52,$4f,$4c
	.byte	$49,$46,$43,$3f,$3c,$38,$35,$31
	.byte	$30,$33,$36,$39,$3c,$3f,$42,$44
	.byte	$47,$49,$4c,$4e,$50,$52,$54,$56
	.byte	$57,$59,$5a,$5b,$5c,$5d,$5d,$5e
	.byte	$5e,$5e,$5e,$5d,$5d,$5c,$5b,$5a
	.byte	$59,$57,$56,$54,$52,$50,$4e,$4c
	.byte	$49,$47,$44,$42,$3f,$3c,$39,$36
	.byte	$33,$30,$2e,$2b,$28,$25,$22,$1f
	.byte	$1c,$1a,$17,$15,$12,$10,$0e,$0c
	.byte	$0a,$08,$07,$05,$04,$03,$02,$01
	.byte	$01,$00,$00,$00,$00,$00,$01,$01
	.byte	$02,$03,$04,$05,$07,$08,$0a,$0c
	.byte	$0e,$10,$12,$15,$17,$1a,$1c,$1f
	.byte	$22,$25,$28,$2b,$2e,$30,$33,$36
	.byte	$39,$3c,$3f,$42,$44,$47,$49,$4c
	.byte	$4e,$50,$52,$54,$56,$57,$59,$5a
	.byte	$5b,$5c,$5d,$5d,$5e,$5e,$5e,$5e
	.byte	$5d,$5d,$5c,$5b,$5a,$59,$57,$56
	.byte	$54,$52,$50,$4e,$4c,$49,$47,$44
	.byte	$42,$3f,$3c,$39,$36,$33,$30,$2e
	.byte	$2b,$28,$25,$22,$1f,$1c,$1a,$17
	.byte	$15,$12,$10,$0e,$0c,$0a,$08,$07
	.byte	$05,$04,$03,$02,$01,$01,$00,$00
	.byte	$00,$00,$00,$01,$01,$02,$03,$04
	.byte	$05,$07,$08,$0a,$0c,$0e,$10,$12
	.byte	$15,$17,$1a,$1c,$1f,$22,$25,$28
	.byte	$2b,$2e,$ff
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
M7GFX:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
	.incbin	"../mode7gfx/m7_vert_bar.pc7"
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
M7MAP:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
	.incbin	"../mode7gfx/vert_bar.bin"
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
PLASMA_PAL:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
	.word	$0000,$0000,$0461,$04a1,$0ce3,$1523,$1d65,$25a5
	.word	$2625,$2667,$2ea7,$372b,$476f,$57b3,$67b7,$6ffb
	.word	$7fff,$5fbf,$3fbf,$3efd,$3e3b,$45f9,$4db9,$55b7
	.word	$55b3,$4d6f,$44ed,$3cab,$2c69,$2467,$1c25,$1423

	.word	$1423,$1c25,$2467,$2c69,$3cab,$44ed,$4d6f,$55b3
	.word	$55b7,$4db9,$45f9,$3e3b,$3efd,$3fbf,$5fbf,$7fff
	.word	$6ffb,$67b7,$57b3,$476f,$372b,$2ea7,$2667,$2625
	.word	$25a5,$1d65,$1523,$0ce3,$04a1,$0461,$0000,$0000
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
PLASMA_PAL_END:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
