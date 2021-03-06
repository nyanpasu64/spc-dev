;-------------------------------------------------------------------------;
.include "bg_scrolltext.inc"
.include "snes.inc"
;-------------------------------------------------------------------------;
.importzp shadow_hdmaen
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.bss
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
scrollcolumn:
	.res 2
scrollcount:
	.res 2
scrollstorage1:
	.res 2
scrollstorage2:
	.res 2
scrollstorage3:
	.res 2
scrolltext:
	.res 2
scrollval:
	.res 2
scrollypos:
	.res 2
sineoffset:
	.res 2
xstorage1:
	.res 2
xstorage2:
	.res 2
;-------------------------------------------------------------------------;


;-------------------------------------------------------------------------;
RAM_BG2HOFS	=	04e7h	; 39h/57 bytes
RAM_VSINE	=	7f0000h	;
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.zeropage
;/////////////////////////////////////////////////////////////////////////;


;-------------------------------------------------------------------------;
text_ptr:
	.res 3
;-------------------------------------------------------------------------;


;/////////////////////////////////////////////////////////////////////////;
.code
;/////////////////////////////////////////////////////////////////////////;


;=========================================================================;
;       Code (c) 1995 -Pan-/ANTHROX   All code can be used at will!
;=========================================================================;                     

	.a8
	.i16


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
; A = Text bank
; B = Scrolltext YPOS (0-15)
; X = Text address
; Y = BG VRAM address
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
SetupBGScrollText:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	rep	#10h
	sep	#20h

	sta	text_ptr+2
	stx	text_ptr
	sty	scrollstorage1
	sty	scrollstorage2
	sty	scrollstorage3

	ldx	#0000h
	stx	scrolltext
	stx	sineoffset

	ldx	#0090h
	stx	scrollval
	stx	scrollcount
	dex
	stx	scrollcolumn

	xba			; get scrolltext Y position

	rep	#30h

	and	#%1111		; do not exceed 0fh

	asl a			; *2
	asl a			; *4
	asl a			; *8

	pha			; number of hdma lines for bg2hofs

	asl a			; *16
	asl a			; *32

	sta	scrollypos	; number of vram chars for scrolltext ypos

	pla

	sep	#20h

	sec
	sbc	#04h
	sta	RAM_BG2HOFS
	stz	RAM_BG2HOFS+1
	sta	RAM_BG2HOFS+2

	ldx	#0003h
	lda	#01h
:	sta	RAM_BG2HOFS,x
	inx
	stz	RAM_BG2HOFS,x
	inx
	sta	RAM_BG2HOFS,x
	inx
	cpx	#0011h*3
	bne	:-

	stz	RAM_BG2HOFS,x
	stz	RAM_BG2HOFS+1,x
	stz	RAM_BG2HOFS+2,x

	lda     #DMAP_XFER_MODE_2
	sta	REG_DMAP4

	lda     #<REG_BG2HOFS
	sta     REG_BBAD4         
	ldx     #RAM_BG2HOFS
	stx     REG_A1T4L
	stz     REG_A1B4

	lda	#%10000
	sta	shadow_hdmaen

	phb

	rep	#30h

	lda	#VSINE_END-VSINE	; copy VSINE twice
	pha
	ldx	#VSINE
	phx
	ldy	#RAM_VSINE

	mvn	^RAM_VSINE,^VSINE
	;	^^-- DBR = ^RAM_VSINE now

	plx
	pla
	ldy	#RAM_VSINE+(VSINE_END-VSINE)
	mvn	^RAM_VSINE,^VSINE

	sep	#20h

	plb

	rts


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
;                              Scroll Routine
; Leaves X untouched
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
BGScrollText:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	rep	#10h
	sep	#20h

	ldy	scrollval
	iny
	iny
	sty	scrollval

	dec	scrollcount
	dec	scrollcount
	lda	scrollcount
	beq	ScrollOk
;-------------------------------------------------------------------------;
	rts
;-------------------------------------------------------------------------;
ScrollOk:
;-------------------------------------------------------------------------;
	lda	#10h
	sta	scrollcount

	lda	scrollcolumn
	inc a				; increase scroll column
	and	#1fh
	sta	scrollcolumn

	rep	#30h

	lda	scrollcolumn
	and	#000fh
	asl a
	clc
	adc	scrollstorage3
	adc	scrollypos
	sta	scrollstorage1

	lda	scrollcolumn
	and	#0010h
	bne	Eq400
;-------------------------------------------------------------------------;
	lda	scrollstorage1	
	sta	scrollstorage2		; the address
	bra	Not400
;-------------------------------------------------------------------------;
Eq400:
;-------------------------------------------------------------------------;
	lda	scrollstorage1
	clc
	adc	#0400h
	sta	scrollstorage2
;-------------------------------------------------------------------------;
Not400:
;-------------------------------------------------------------------------;
	ldy	scrolltext
	lda	[text_ptr],y
	and	#00ffh
	bne	NoResetScroll
;-------------------------------------------------------------------------;
	ldy	#0000h
	sty	scrolltext
	bra	Not400
;-------------------------------------------------------------------------;
NoResetScroll:
;-------------------------------------------------------------------------;
	cmp	#005fh
	bcc	AllCaps
;-------------------------------------------------------------------------;
	sec
	sbc	#0020h
;-------------------------------------------------------------------------;
AllCaps:
;-------------------------------------------------------------------------;
	sec
	sbc	#0020h
	asl a
	;ora	#0c00h			; change palette
	ldy	scrollstorage2
	sty	REG_VMADDL
	sta	REG_VMDATAL
	inc a
	sta	REG_VMDATAL
	dec a
	pha
	lda	scrollstorage2
	clc
	adc	#0020h
	sta	scrollstorage2
	pla
	ldy	scrollstorage2
	sty	REG_VMADDL
	clc
	adc	#0080h
	sta	REG_VMDATAL
	inc a
	sta	REG_VMDATAL
	
	sep	#20h

	ldy	scrolltext
	iny
	sty	scrolltext
	rts


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
;                      Plane 1 HDMA swing left/right
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
BGScrollSquish:
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
	rep	#10h
	sep	#20h

	inc	sineoffset		; increase sine offset ($00 - $ff)

	rep	#30h

	ldx	#0010h
	stx	xstorage1
	
	ldy	#0000h
	
	lda	sineoffset
	sta	xstorage2
	asl a
	tax
;-------------------------------------------------------------------------;
HDMASwish:
;-------------------------------------------------------------------------;
	iny			 
	
	lda	xstorage2
	asl a
	tax

	lda	RAM_VSINE,x
	clc
	adc	scrollval
			 
	sta	RAM_BG2HOFS+3,y
	
	inc	xstorage2

	iny	 
	iny
	dec	xstorage1
	bne	HDMASwish
;-------------------------------------------------------------------------;
	sep	#20h
	rts


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
VSINE:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
 .word	108,109,111,112,113,114,115,115,116,117,118,119,120,120,121,122
 .word	122,123,123,124,124,125,125,125,126,126,126,127,127,127,127,127
 .word	127,127,127,127,127,127,126,126,126,125,125,125,124,124,123,123
 .word	122,122,121,120,120,119,118,117,116,115,115,114,113,112,111,109
 .word	108,107,106,105,104,103,101,100,099,097,096,095,093,092,091,089
 .word	088,086,085,083,082,080,079,077,076,074,073,071,070,068,067,065
 .word	064,062,060,059,057,056,054,053,051,050,048,047,045,044,042,041
 .word	039,038,036,035,034,032,031,030,028,027,026,024,023,022,021,020
 .word	019,018,016,015,014,013,012,012,011,010,009,008,007,007,006,005
 .word	005,004,004,003,003,002,002,002,001,001,001,000,000,000,000,000
 .word	000,000,000,000,000,000,001,001,001,002,002,002,003,003,004,004
 .word	005,005,006,007,007,008,009,010,011,012,012,013,014,015,016,018
 .word	019,020,021,022,023,024,026,027,028,030,031,032,034,035,036,038
 .word	039,041,042,044,045,047,048,050,051,053,054,056,057,059,060,062
 .word	064,065,067,068,070,071,073,074,076,077,079,080,082,083,085,086
 .word	088,089,091,092,093,095,096,097,099,100,101,103,104,105,106,107
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
VSINE_END:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
