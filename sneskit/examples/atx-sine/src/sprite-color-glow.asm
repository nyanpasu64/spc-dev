;-------------------------------------------------------------------------;
.include "snes.inc"
;-------------------------------------------------------------------------;
.export SPRITE_COLOR_GLOW
;-------------------------------------------------------------------------;


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
SPRITE_COLOR_GLOW:
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
	.dbyt	$0000,$9F03,$9F02,$DA01,$5001,$C800,$8800,$1801
	.dbyt	$DF02,$5F02,$DA01,$0E01,$9F02,$DF01,$1F03,$1F03 
	;	-75
	.dbyt	$0000,$9F1B,$9F12,$D609,$4E09,$C600,$8800,$1601
	.dbyt	$DF1A,$5C1A,$D611,$0C11,$9F0A,$DF09,$1F13,$1F23 
	;	-50
	.dbyt	$0000,$9F33,$9C22,$D219,$4C11,$C608,$8600,$1209
	.dbyt	$DF3A,$5832,$D429,$0A21,$9F1A,$DC09,$1F23,$1F43 
	;	-25
	.dbyt	$0000,$9F53,$963A,$D029,$4A19,$C410,$8400,$0E09
	.dbyt	$DA5A,$544A,$D041,$0831,$9C22,$D811,$1F33,$1F63 
	; 0 %
	.dbyt	$0000,$9A6B,$924A,$CC31,$4821,$C418,$8408,$0C11
	.dbyt	$D67E,$5062,$CC51,$0639,$9632,$D219,$1A43,$1C7F 
	;	+25
	.dbyt	$0000,$947F,$8E5A,$CA41,$4629,$C220,$8208,$0811
	.dbyt	$D07E,$4C7E,$CA69,$0449,$903A,$CE21,$1453,$167F 
	;	+50
	.dbyt	$0000,$8C7F,$8872,$C651,$4431,$C228,$8208,$0619
	.dbyt	$CA7E,$487E,$C67D,$0259,$8A4A,$C829,$0C63,$0E7F 
	;	+75
	.dbyt	$0000,$867F,$847E,$C261,$4239,$C030,$8008,$0219
	.dbyt	$C47E,$447E,$C27D,$0269,$845A,$C431,$0673,$067F 
	;	+100
	.dbyt	$0000,$807F,$807E,$C069,$4041,$C030,$8010,$0021
	.dbyt	$C07E,$407E,$C07D,$007D,$8062,$C039,$007F,$007F 
	;	+75
	.dbyt	$0000,$867F,$847E,$C261,$4239,$C030,$8008,$0219
	.dbyt	$C47E,$447E,$C27D,$0269,$845A,$C431,$0673,$067F 
	;	+50
	.dbyt	$0000,$8C7F,$8872,$C651,$4431,$C228,$8208,$0619
	.dbyt	$CA7E,$487E,$C67D,$0259,$8A4A,$C829,$0C63,$0E7F 
	;	+25
	.dbyt	$0000,$947F,$8E5A,$CA41,$4629,$C220,$8208,$0811
	.dbyt	$D07E,$4C7E,$CA69,$0449,$903A,$CE21,$1453,$167F 
	;	0 %
	.dbyt	$0000,$9A6B,$924A,$CC31,$4821,$C418,$8408,$0C11
	.dbyt	$D67E,$5062,$CC51,$0639,$9632,$D219,$1A43,$1C7F 
	;	-25
	.dbyt	$0000,$9F53,$963A,$D029,$4A19,$C410,$8400,$0E09
	.dbyt	$DA5A,$544A,$D041,$0831,$9C22,$D811,$1F33,$1F63 
	;	-50
	.dbyt	$0000,$9F33,$9C22,$D219,$4C11,$C608,$8600,$1209
	.dbyt	$DF3A,$5832,$D429,$0A21,$9F1A,$DC09,$1F23,$1F43 
	;	-75
	.dbyt	$0000,$9F1B,$9F12,$D609,$4E09,$C600,$8800,$1601
	.dbyt	$DF1A,$5C1A,$D611,$0C11,$9F0A,$DF09,$1F13,$1F23
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;