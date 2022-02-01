;--------------------------------------------------------------------
.include "copying.inc"
.include "snes.inc"
.include "snes_zvars.inc"
;--------------------------------------------------------------------

;--////////////////////////////////////////////////////////////////--
	.code
;--////////////////////////////////////////////////////////////////--

	.a8
	.i16

;********************************************************************
; copy data to vram with DMA
;
; a = increment when writing higher byte (00h|80h)
; x = transer size (bytes)
; y = VRAM address (words!)
;********************************************************************

;====================================================================
M7DMAtoVRAM:
;====================================================================
	sty	REG_DMAP0		; destination = vram
	stx	REG_A1T0L		; set transfer size
	sta	REG_A1B0		; bank
;---------------------------------------;----------------------------
	ldx	#4000h			;
	stx	REG_DAS0L		;
	ldx	#0000h
	stx	REG_VMADDL		;
;---------------------------------------;----------------------------
	lda	#01h			; start transfer
	sta	REG_MDMAEN		;----------------------------
	rts

;******************************************************************************
; copy data to RAM with DMA
;	
; a,y = ROM address
; x = size (bytes)
; WMADD = target
;******************************************************************************
DMAtoRAM:
;------------------------------------------------------------------------------
	sta	REG_A1B7
	sty	REG_A1T7
	
	stx	REG_DAS7L		; set transfer size
	lda	#<REG_WMDATA		; target = WRAM
	sta	REG_BBAD7		;
	stz	REG_DMAP7		;
	lda	#1<<7			;
	sta	REG_MDMAEN		; start transfer
;------------------------------------------------------------------------------
	rts

