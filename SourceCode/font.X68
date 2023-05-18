

;------------------------------------------------------------------------------------------------------------------------------------------------

FONT_RAMSCREEN_SIZE equ 64*32
ETX equ 0	; end of text
RT_NEWLINE equ 1

;------------------------------------------------------------------------------------------------------------------------------------------------
; Init font handling
; call fter setting up global variables. eg:
;	move #FONT_white_on_transparent,g_font_index
;	move #1,g_font_palette_index
;	jsr FONT_Init
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_Init:
	move.l #0,m_font_ramscreen_addr
	move g_font_palette_index,d0
	ror #3,d0
	or.w #PRIORITY,d0
	move d0,g_font_cellbits
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Set up the font, palette, and tiles, all in one. Called the same way as FONT_Init
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_InitAll:
	jsr FONT_Init
	bsr FONT_LoadPalette
   	bsr FONT_LoadTiles
	rts
	

;------------------------------------------------------------------------------------------------------------------------------------------------
; Load palette for font after setting up with FONT_Init
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_LoadPalette:

	bsr FONT_GetBaseExportAddress
	move.l exfont_palette(a0),a0

	lea RamPalettes,a1
	move g_font_palette_index,d0
	lsl #5,d0
	add d0,a1
	move #(1*8)-1,d0
.loop:
	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Get address of font data from g_font_index(a0)
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_GetBaseExportAddress:
	;lea ExportedFonts,a0
	lea NewFonts,a0
	move g_font_index,d0
	lsl #3,d0
	add d0,a0
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Load font tiles to VDP
; uses g_font_index
; stores font character index ing_vram_font
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_LoadTiles:

	bsr FONT_GetBaseExportAddress
	move.l exfont_chars(a0),a0

	;a0 font is now 'imagecells' format
	
	move.l a0,a4
	move.w imagecells_numcells(a0),d6

	move #VDPADDR_FONT/32,d0		; space between scrolls
	move.w d0,g_vram_font

	;move g_vram_currentpos,d0
	;move.w d0,g_vram_font
	;add d6,g_vram_currentpos

	; font tiles
	move.w	d0,d1
	lsl #5,d1	;#FONT_VDP,d1	; setup call to BuildVRAMWriteAddress
	jsr		VDP_BuildVRAMWriteAddress	; build the VRAM write address

	move.l a4,a0
	jsr	UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Load font tiles to VDP
; uses g_font_index
; stores font character index ing_vram_font
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_LoadTiles_InlineVDP:

	bsr FONT_GetBaseExportAddress
	move.l exfont_chars(a0),a0

	;a0 font is now 'imagecells' format
	
	move.l a0,a4
	move.w imagecells_numcells(a0),d6

	move g_vram_currentpos,d0
	move.w d0,g_vram_font
	add d6,g_vram_currentpos

	; font tiles
	move.w	d0,d1
	lsl #5,d1	;#FONT_VDP,d1	; setup call to BuildVRAMWriteAddress
	jsr		VDP_BuildVRAMWriteAddress	; build the VRAM write address

	move.l a4,a0
	jsr	UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; a0 address of string
; a1 vdp address
;------------------------------------------------------------------------------------------------------------------------------------------------

FONT_DrawText:
	move g_vram_font,d0
	or.w g_font_cellbits,d0
	or.w #PRIORITY,d0
	bra FONT_DrawText_Inner


FONT_DrawText_RamScreen:
	move g_vram_font,d0
	or.w g_font_cellbits,d0
	or.w #PRIORITY,d0
	bra FONT_DrawText_Inner_RamScreen

FONT_DrawRichText_RamScreen:
	move g_vram_font,d0
	or.w g_font_cellbits,d0
	or.w #PRIORITY,d0
	bra FONT_DrawRichText_Inner_RamScreen


FONT_DrawText16_RamScreen:
	move g_vram_font,d0
	or.w g_font_cellbits,d0
	or.w #PRIORITY,d0
	bra FONT_DrawText16_Inner_RamScreen



FONT_DrawText_Inner:
	lea VDP_DATA,a1
	sub #$20,d0
.lp:
	rept 8
	moveq #0,d1		
	move.b	(a0)+,d1	
	beq .end		
	add.w	d0,d1
	move.w  d1,(a1)
	endr
	bra.s	.lp

.end:
	rts

; d0 number of spaces
FONT_ClearSpace:
    move d0,d2
    subq #1,d2
	move g_vram_font,d0
	or.w g_font_cellbits,d0
	or.w #PRIORITY,d0
	lea VDP_DATA,a1
	sub #$20,d0
.lp:
	moveq #0,d1		
	move.b	#' ',d1	
	add.w	d0,d1
	move.w  d1,(a1)
	dbra	d2,.lp
	rts



; a1 ram address
FONT_DrawRichText_Inner_RamScreen:
    move.l a1,a5
	sub #$20,d0
.lp:
	moveq #0,d1		
	move.b	(a0)+,d1	
	cmp.b #ETX,d1
	beq .end	
	cmp.b #RT_NEWLINE,d1
	bne .no_newline
	add #128,a5
	move.l a5,a1
	bra .lp
.no_newline:	
	add.w	d0,d1
	move.w  d1,(a1)+
	bra.s	.lp
.end:
	rts


; a1 ram address
FONT_DrawText_Inner_RamScreen:
	sub #$20,d0
.lp:
	rept 8
	moveq #0,d1		
	move.b	(a0)+,d1	
	beq .end		
	add.w	d0,d1
	move.w  d1,(a1)+
	endr
	bra.s	.lp
.end:
	rts


; a1 ram address
FONT_DrawText16_Inner_RamScreen:
	PUSHALL
	lea 128(a1),a2

	move d0,d6				; font offset

.lp:
	moveq #0,d0
	move.b	(a0)+,d0
	cmp.b #ETX,d0
	beq .end

	sub #$20,d0
	move d0,d1
	add d0,d0
	move d0,d2
	add.w	d6,d2

	move.w d2,(a1)+
	addq #1,d2
	move.w d2,(a1)+
	add #192-1,d2
	move.w d2,(a2)+
	addq #1,d2
	move.w d2,(a2)+

	bra.s	.lp
.end:
	POPALL
	rts


FONT_ClearRamScreen:
	move.l m_font_ramscreen_addr,a0
	
	move g_vram_panel_font,d0
	add #' ',d0
	or.w g_font_cellbits,d0
;	move #0,d0
	move #FONT_RAMSCREEN_SIZE-1,d1
.lp:
	move.w  d0,(a0)+
	dbra	d1,.lp
	rts

; d0 is line index
FONT_ClearLine_RamScreen:
	PUSHALL
	move.l m_font_ramscreen_addr,a0
	lsl #7,d0
	add d0,a0
	move #0,d0
	move #40-1,d1
.lp:
	move.w  d0,(a0)+
	dbra	d1,.lp
	POPALL
	rts

FONT_ClearRamScreen2:
	move.l m_font_ramscreen_addr2,a0
	move #0,d0
	move #FONT_RAMSCREEN_SIZE-1,d1
.lp:
	move.w  d0,(a0)+
	dbra	d1,.lp
	rts


; d0 is first line
; d1 is second line
FONT_DMA_RamScreen:
	moveq #0,d3
	moveq #0,d4
	move d0,d3
	move d1,d4
	move d4,d5
	sub d0,d5	; num lines
	addq #1,d5	; num lines

	move.l m_font_ramscreen_addr,d0
	move.l #VDPADDR_SCROLL_A,d1

	lsl.l #7,d3
	add.l d3,d0
	add.l d3,d1

	;add.l #(128*6),d0
	;add.l #(128*6),d1

	move.l #FONT_RAMSCREEN_SIZE,d2

	moveq #0,d2
	move d5,d2
	lsl.l #7,d2

	;move.l #128*10,d2

	moveq #2,d3
	jsr VDP_SetDMA
	rts

FONT_DMA_RamScreenB:
	moveq #0,d3
	moveq #0,d4
	move d0,d3
	move d1,d4
	move d4,d5
	sub d0,d5	; num lines
	addq #1,d5	; num lines

	move.l m_font_ramscreen_addr,d0
	move.l #VDPADDR_SCROLL_B,d1

	lsl.l #7,d3
	add.l d3,d0
	add.l d3,d1

	;add.l #(128*6),d0
	;add.l #(128*6),d1

	move.l #FONT_RAMSCREEN_SIZE,d2

	moveq #0,d2
	move d5,d2
	lsl.l #7,d2

	;move.l #128*10,d2

	moveq #2,d3
	jsr VDP_SetDMA
	rts



;------------------------------------------------------------------------------------------------------------------------------------------------
; print a 2 digit number in d0, from 0-99
; a1 is addr for VRAM
;------------------------------------------------------------------------------------------------------------------------------------------------
FONT_DrawNumber_Byte:
	PUSHALL

	lea FONT_NumberTable_Byte,a0
	lsl #2,d0
	add d0,a0
	jsr FONT_DrawText
	POPALL
	rts
	
FONT_DrawNumber_Byte_SingleChar:
	PUSHALL
	lea FONT_NumberTable_Byte_SingleChar,a0
	lsl #1,d0
	add d0,a0
	jsr FONT_DrawText
	POPALL
	rts	

FONT_DrawNumber_Byte_RamScreen:
	PUSHALL

	lea FONT_NumberTable_Byte,a0
	lsl #2,d0
	add d0,a0
	jsr FONT_DrawText_RamScreen
	POPALL
	rts	

FONT_NumberTable_Byte_SingleChar:
	dc.b '0',ETX,'1',ETX,'2',ETX,'3',ETX,'4',ETX
	dc.b '5',ETX,'6',ETX,'7',ETX,'8',ETX,'9',ETX
	align 2

FONT_NumberTable_Byte:
	dc.b '000',ETX,'001',ETX,'002',ETX,'003',ETX,'004',ETX,'005',ETX,'006',ETX,'007',ETX,'008',ETX,'009',ETX,'010',ETX,'011',ETX,'012',ETX,'013',ETX,'014',ETX,'015',ETX,'016',ETX,'017',ETX,'018',ETX,'019',ETX,'020',ETX,'021',ETX,'022',ETX,'023',ETX,'024',ETX,'025',ETX,'026',ETX,'027',ETX,'028',ETX,'029',ETX,'030',ETX,'031',ETX,'032',ETX,'033',ETX,'034',ETX,'035',ETX,'036',ETX,'037',ETX,'038',ETX,'039',ETX,'040',ETX,'041',ETX,'042',ETX,'043',ETX,'044',ETX,'045',ETX,'046',ETX,'047',ETX,'048',ETX,'049',ETX,'050',ETX,'051',ETX,'052',ETX,'053',ETX,'054',ETX,'055',ETX,'056',ETX,'057',ETX,'058',ETX,'059',ETX,'060',ETX,'061',ETX,'062',ETX,'063',ETX,'064',ETX,'065',ETX,'066',ETX,'067',ETX,'068',ETX,'069',ETX,'070',ETX,'071',ETX,'072',ETX,'073',ETX,'074',ETX,'075',ETX,'076',ETX,'077',ETX,'078',ETX,'079',ETX,'080',ETX,'081',ETX,'082',ETX,'083',ETX,'084',ETX,'085',ETX,'086',ETX,'087',ETX,'088',ETX,'089',ETX,'090',ETX,'091',ETX,'092',ETX,'093',ETX,'094',ETX,'095',ETX,'096',ETX,'097',ETX,'098',ETX,'099',ETX,'100',ETX,'101',ETX,'102',ETX,'103',ETX,'104',ETX,'105',ETX,'106',ETX,'107',ETX,'108',ETX,'109',ETX,'110',ETX,'111',ETX,'112',ETX,'113',ETX,'114',ETX,'115',ETX,'116',ETX,'117',ETX,'118',ETX,'119',ETX,'120',ETX,'121',ETX,'122',ETX,'123',ETX,'124',ETX,'125',ETX,'126',ETX,'127',ETX,'128',ETX,'129',ETX,'130',ETX,'131',ETX,'132',ETX,'133',ETX,'134',ETX,'135',ETX,'136',ETX,'137',ETX,'138',ETX,'139',ETX,'140',ETX,'141',ETX,'142',ETX,'143',ETX,'144',ETX,'145',ETX,'146',ETX,'147',ETX,'148',ETX,'149',ETX,'150',ETX,'151',ETX,'152',ETX,'153',ETX,'154',ETX,'155',ETX,'156',ETX,'157',ETX,'158',ETX,'159',ETX,'160',ETX,'161',ETX,'162',ETX,'163',ETX,'164',ETX,'165',ETX,'166',ETX,'167',ETX,'168',ETX,'169',ETX,'170',ETX,'171',ETX,'172',ETX,'173',ETX,'174',ETX,'175',ETX,'176',ETX,'177',ETX,'178',ETX,'179',ETX,'180',ETX,'181',ETX,'182',ETX,'183',ETX,'184',ETX,'185',ETX,'186',ETX,'187',ETX,'188',ETX,'189',ETX,'190',ETX,'191',ETX,'192',ETX,'193',ETX,'194',ETX,'195',ETX,'196',ETX,'197',ETX,'198',ETX,'199',ETX,'200',ETX,'201',ETX,'202',ETX,'203',ETX,'204',ETX,'205',ETX,'206',ETX,'207',ETX,'208',ETX,'209',ETX,'210',ETX,'211',ETX,'212',ETX,'213',ETX,'214',ETX,'215',ETX,'216',ETX,'217',ETX,'218',ETX,'219',ETX,'220',ETX,'221',ETX,'222',ETX,'223',ETX,'224',ETX,'225',ETX,'226',ETX,'227',ETX,'228',ETX,'229',ETX,'230',ETX,'231',ETX,'232',ETX,'233',ETX,'234',ETX,'235',ETX,'236',ETX,'237',ETX,'238',ETX,'239',ETX,'240',ETX,'241',ETX,'242',ETX,'243',ETX,'244',ETX,'245',ETX,'246',ETX,'247',ETX,'248',ETX,'249',ETX,'250',ETX,'251',ETX,'252',ETX,'253',ETX,'254',ETX
	align 2


FONT_DrawNumber_W_2:
	PUSHALL
	lea FONT_NumberTable_W_2,a0
	lsl #2,d0
	add d0,a0
	jsr FONT_DrawText
	POPALL
	rts

FONT_DrawNumber_W_1:
	PUSHALL

	lea FONT_NumberTable_Byte_SingleChar,a0
	add d0,d0
	add d0,a0
	jsr FONT_DrawText
	POPALL
	rts


FONT_DrawNumber_W_2_RamScreen:
	PUSHALL

	lea FONT_NumberTable_W_2,a0
	lsl #2,d0
	add d0,a0
	jsr FONT_DrawText_RamScreen
	POPALL
	rts


FONT_NumberTable_W_2:
	dc.b '00',ETX,0,'01',ETX,0,'02',ETX,0,'03',ETX,0,'04',ETX,0,'05',ETX,0,'06',ETX,0,'07',ETX,0,'08',ETX,0,'09',ETX,0,'10',ETX,0,'11',ETX,0,'12',ETX,0,'13',ETX,0,'14',ETX,0,'15',ETX,0,'16',ETX,0,'17',ETX,0,'18',ETX,0,'19',ETX,0,'20',ETX,0,'21',ETX,0,'22',ETX,0,'23',ETX,0,'24',ETX,0,'25',ETX,0,'26',ETX,0,'27',ETX,0,'28',ETX,0,'29',ETX,0,'30',ETX,0,'31',ETX,0,'32',ETX,0,'33',ETX,0,'34',ETX,0,'35',ETX,0,'36',ETX,0,'37',ETX,0,'38',ETX,0,'39',ETX,0,'40',ETX,0,'41',ETX,0,'42',ETX,0,'43',ETX,0,'44',ETX,0,'45',ETX,0,'46',ETX,0,'47',ETX,0,'48',ETX,0,'49',ETX,0,'50',ETX,0,'51',ETX,0,'52',ETX,0,'53',ETX,0,'54',ETX,0,'55',ETX,0,'56',ETX,0,'57',ETX,0,'58',ETX,0,'59',ETX,0,'60',ETX,0,'61',ETX,0,'62',ETX,0,'63',ETX,0,'64',ETX,0,'65',ETX,0,'66',ETX,0,'67',ETX,0,'68',ETX,0,'69',ETX,0,'70',ETX,0,'71',ETX,0,'72',ETX,0,'73',ETX,0,'74',ETX,0,'75',ETX,0,'76',ETX,0,'77',ETX,0,'78',ETX,0,'79',ETX,0,'80',ETX,0,'81',ETX,0,'82',ETX,0,'83',ETX,0,'84',ETX,0,'85',ETX,0,'86',ETX,0,'87',ETX,0,'88',ETX,0,'89',ETX,0,'90',ETX,0,'91',ETX,0,'92',ETX,0,'93',ETX,0,'94',ETX,0,'95',ETX,0,'96',ETX,0,'97',ETX,0,'98',ETX,0,'99',ETX,0
	align 2



; a0 is start of number to print
; d0 is number of digits - MUST BE multiple of 2
FONT_DrawNumber_BCD:
	lea VDP_DATA,a2

	move g_vram_font,d2
	or.w g_font_cellbits,d2
	add #16,d2

    move d0,d5
    beq .exit
    lsr #1,d5
    subq #1,d5
.lp:
    move.b (a0)+,d0
    move d0,d1
    lsr #4,d0
    and #$f,d0
    bsr .char

    move d1,d0
    and #$f,d0
    bsr .char
    dbra d5,.lp
    rts
	
.char:
	add d2,d0
	move.w  d0,(a2)
.exit:
	rts	

;a0 is number
;d0 is number of digits
FONT_DrawNumber_BCD_NoLeadingZeroes:
	lea VDP_DATA,a2

	move g_vram_font,d2
	or.w g_font_cellbits,d2
	add #16,d2
	
	
	move.l a0,a1
	move d0,d1
	lsr #1,d1
	subq #1,d1
.tstlp:
    tst.b (a1)+
    bne .hasnumber
	dbra d1,.tstlp
; 0 here. draw a 0
    move.w  d2,(a2)
    rts
	
.hasnumber:    
    move #0,d4  ; has done leading zero

    move d0,d5
    beq .exit
    lsr #1,d5
    subq #1,d5
.lp:
    move.b (a0)+,d0
    move d0,d1
    lsr #4,d0
    and #$f,d0
    bsr .char

    move d1,d0
    and #$f,d0
    bsr .char
    dbra d5,.lp
.exit:
    rts
	
.char:
    tst d4
    bne .doit
.testleadingzero:
    tst d0
    beq .leadingzero_found
    moveq #1,d4                 ; set flag to say print further zeros
.doit:
	add d2,d0
	move.w  d0,(a2)
.leadingzero_found:
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; print a 5 digit number in d0
; a1 is addr for VRAM
;------------------------------------------------------------------------------------------------------------------------------------------------

FONT_DrawNumber_W_5:
	lea VDP_DATA,a2

    and.l #$ffff,d0

	move g_vram_font,d1
	or.w g_font_cellbits,d1
	add #16,d1

	
	moveq #0,d5
	move d0,d5

	move d5,d0
	divu #10000,d0
	bsr .char

	clr.w d0
	swap d0
	divu #1000,d0
	bsr .char

	clr.w d0
	swap d0
	divu #100,d0
	bsr .char

	clr.w d0
	swap d0
	divu #10,d0
	bsr .char

	clr.w d0
	swap d0
	bsr .char

	rts

.char:
	move d0,d2
	add d1,d2
	move.w  d2,(a2)
	rts

; d0.l
FONT_DrawHex_L:
    lea VDP_DATA,a2
    move g_vram_font,d2
    or.w g_font_cellbits,d2
    sub #32,d2

    move #8-1,d4
    lea .chars,a1
.loop:
    rol.l #4,d0
    move.l d0,d1
    and.l #$f,d1
    move.b (a1,d1),d1
    add d2,d1
    move d1,(a2)

    dbra d4,.loop
    rts
.chars: dc.b '0123456789ABCDEF'

; d0.w
FONT_DrawHex_W:
    lea VDP_DATA,a2
    move g_vram_font,d2
    or.w g_font_cellbits,d2
    sub #32,d2

    move #4-1,d4
    lea .chars,a1
.loop:
    rol.w #4,d0
    move.w d0,d1
    and.w #$f,d1
    move.b (a1,d1),d1
    add d2,d1
    move d1,(a2)
    dbra d4,.loop
    rts
.chars: dc.b '0123456789ABCDEF'

; d0.w
FONT_DrawHex_B:
    lea VDP_DATA,a2
    move g_vram_font,d2
    or.w g_font_cellbits,d2
    sub #32,d2
    rol.w #8,d0
    move #2-1,d4
    lea .chars,a1
.loop:
    rol.w #4,d0
    move.w d0,d1
    and.w #$f,d1
    move.b (a1,d1),d1
    add d2,d1
    move d1,(a2)
    dbra d4,.loop
    rts
.chars: dc.b '0123456789ABCDEF'


FONT_DrawNumber_W_Variable:
	lea VDP_DATA,a2

    move d0,d6
    and.l #$ffff,d6
 
    lea g_numberPrintArea,a5
    
    moveq #0,d5
    
    cmp #32767,d6
    ble .numok
    move #32767,d6
.numok:

    add #6*2,d4                 ; max 5 chars
    and.l #$ffff,d6
.scorelp:
    cmp #10,d6
    blt .score_last
    divu #10,d6
    swap d6
    move d6,d3      ; remainder
    swap d6
    and.l #$ffff,d6

.char:
    move d3,d0
    move d0,(a5)+
    addq #1,d5
    bra .scorelp
    
    rts
.score_last:
   move d6,d0
   move d0,(a5)+
   addq #1,d5

   
   
; now in reverse order
    move d5,d4
    subq #1,d4
.loop2:

    move.w -(a5),d0

    move g_vram_font,d1
    or.w g_font_cellbits,d1
    add #16,d1                      ; d1
    add d1,d0
    move d0,(a2)

    dbra d4,.loop2
    
.no:
    move d5,d0      ; num chars
   rts



; d0 number
; a1 addr
FONT_DrawNumber_W_5_RamScreen:

	move g_vram_font,d1
	or.w g_font_cellbits,d1
	add #16,d1

	
	moveq #0,d5
	move d0,d5

	move d5,d0
	divu #10000,d0
	bsr .char

	clr.w d0
	swap d0
	divu #1000,d0
	bsr .char

	clr.w d0
	swap d0
	divu #100,d0
	bsr .char

	clr.w d0
	swap d0
	divu #10,d0
	bsr .char

	clr.w d0
	swap d0
	bsr .char

	rts

.char:
	move d0,d2
	add d1,d2
	move.w  d2,(a1)+
	rts



