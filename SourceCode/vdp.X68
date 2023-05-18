; ----------------------------------------------------------------------------------------------------------------------
; CONTROL REGISTERS
; ----------------------------------------------------------------------------------------------------------------------
VDP_DATA equ $00C00000
VDP_CONTROL equ $00C00004
VDP_COUNTER equ $00C00008

; ----------------------------------------------------------------------------------------------------------------------
; ALL REGISTERS
; ----------------------------------------------------------------------------------------------------------------------
REG_MODE1	equ $8000
REG_MODE2	equ $8100
REG_PATTERNNAME_SCROLLA equ $8200
REG_PATTERNNAME_WINDOW equ $8300
REG_PATTERNNAME_SCROLLB equ $8400
REG_SPRITE_ATTRIBUTE equ $8500
REG_6 equ $8600
REG_BACKGROUND_COLOR equ $8700
REG_8 equ $8800
REG_9 equ $8900
REG_HINT equ $8a00	
REG_MODE3	equ $8b00
REG_MODE4	equ $8c00
REG_HSCROLL equ $8d00	; 0 0 15 14 13 12 11 10
REG_14 equ $8e00
REG_AUTOINC equ $8f00			; INC7-INC0: Value to be added to the VDP address register after each read/write to the data port. 2 is most common.
REG_SCROLLSIZE equ $9000
REG_WINDOW_HPOS equ $9100
; b7 : 0: Window is left from base point / 1 : Window is right from base point
; b0-4 base value (CELL)
REG_WINDOW_VPOS equ $9200
; b7: 0 : Window is upper side from base point /1 : Window is lower side from base point
REG_DMALEN_LO equ $9300			;L7-L0: Low byte of DMA length in bytes, divided by 2.
REG_DMALEN_HI equ $9400			;H7-H0: High byte of DMA length in bytes, divided by 2.
REG_DMA_SOURCE_LO equ $9500		; L7-L0: Low byte of DMA source address, divided by 2.
REG_DMA_SOURCE_MID equ $9600	;M7-M0: Middle byte of DMA source address, divided by 2.
REG_DMA_SOURCE_HI equ $9700		;H5-H0: High byte of DMA source address, divided by 2.
								; (7,6) T1/T0: DMA type. 0x = 68k to VRAM copy (T0 is used as the highest bit in source address); 10 = VRAM fill (source can be left blank); 11 = VRAM to VRAM copy.



; ----------------------------------------------------------------------------------------------------------------------
; REGISTER VALUES
; ----------------------------------------------------------------------------------------------------------------------

REGMASK_MODE1_ENABLEHINT equ $10
REGMASK_MODE1_REQUIRED equ $4

REGMASK_MODE2_REQUIRED equ $4
REGMASK_MODE2_ENABLE_DISPLAY equ $40
REGMASK_MODE2_ENABLE_VINT equ $20
REGMASK_MODE2_ENABLE_DMA equ $10
REGMASK_MODE2_30CELL equ $8

REGMASK_MODE3_IE2 equ $8
REGMASK_MODE3_HSCROLLMODE_FULL equ 0
REGMASK_MODE3_HSCROLLMODE_CELL equ 2
REGMASK_MODE3_HSCROLLMODE_SCAN equ 3
REGMASK_MODE3_VSCROLLMODE_FULL equ 0<<2
REGMASK_MODE3_VSCROLLMODE_CELL equ 1<<2

REGMASK_MODE4_SH_MODE equ $8		; shadow / highlight mode
REGMASK_MODE4_H40 equ $81
REGMASK_MODE4_H32 equ $0
REGMASK_MODE4_NO_INTERLACE equ $0

REGMASK_WINDOW_LEFT equ 0
REGMASK_WINDOW_RIGHT equ $80
REGMASK_WINDOW_UP equ 0
REGMASK_WINDOW_DOWN equ $80


; ----------------------------------------------------------------------------------------------------------------------
; DMA TYPES AND DESTINATIONS
; ----------------------------------------------------------------------------------------------------------------------
DMA_RAM_TO_VRAM equ $00			; ( (60 T0 is used as the highest bit in source address); 
DMA_VRAM_FILL equ $80
DMA_VRAM_TO_VRAM equ $c0
DMA_DESTINATION_VRAM equ $40000080
DMA_DESTINATION_CRAM equ $C0000080
DMA_DESTINATION_VSRAM equ $40000090


VDP_VRAM_WRITE_A equ $40000003	; register 2
VDP_VRAM_WRITE_HSCROLL equ $7C000002	; register 13
VDP_VRAM_WRITE_SPRITE equ $78000002	; register 5
VDP_VRAM_WRITE_B equ $60000003	; register 4
VDP_VRAM_WRITE_WINDOW equ $60000002	; register 3
VDP_VRAM_WRITE_VSCROLL equ $40000010	; vscroll write

VDP_CRAM_READ equ $20000000
VDP_CRAM_WRITE equ $C0000000
VDP_VRAM_READ equ $00000000
VDP_VRAM_WRITE equ $40000000
VDP_VSRAM_READ equ $10000000
VDP_VSRAM_WRITE equ $14000000


; ----------------------------------------------------------------------------------------------------------------------
; PLANE SIZES
; ----------------------------------------------------------------------------------------------------------------------
VDP_PLANESIZE_32x32 equ 0
VDP_PLANESIZE_64x32 equ 1
VDP_PLANESIZE_128x32 equ 3
VDP_PLANESIZE_32x64 equ $10
VDP_PLANESIZE_64x64 equ $11
VDP_PLANESIZE_32x128 equ $30

; ----------------------------------------------------------------------------------------------------------------------
; VDP addresses - for current game
; ----------------------------------------------------------------------------------------------------------------------

VDPADDR_FONT equ $d000
VDPADDR_HSCROLL equ $dc00
VDPADDR_HSCROLL2 equ $dc02  ;b002
VDPADDR_WINDOW equ $b000
VDPADDR_SCROLL_A equ $c000
VDPADDR_SCROLL_B equ $e000
VDPADDR_SPRITE_ATTR equ $b800

; ----------------------------------------------------------------------------------------------------------------------
; REGISTER SET MACROS
; ----------------------------------------------------------------------------------------------------------------------
SETREG_HSCROLL macro \1
	move #REG_HSCROLL | (\1>>10),VDP_CONTROL
	endm
SETREG_PATTERNNAME_SCROLLA macro \1
	move.w	#REG_PATTERNNAME_SCROLLA | ((\1&$e000)>>10), VDP_CONTROL
	endm
SETREG_PATTERNNAME_WINDOW macro \1
	move.w	#REG_PATTERNNAME_WINDOW | ((\1&$f800)>>10), VDP_CONTROL
	endm
SETREG_PATTERNNAME_SCROLLB macro \1
	move.w	#REG_PATTERNNAME_SCROLLB | ((\1&$e000)>>13), VDP_CONTROL
	endm
SETREG_PATTERNNAME_SPRITE_ATTRIBUTE macro \1
	move.w	#REG_SPRITE_ATTRIBUTE | ((\1&$fc00)>>9), VDP_CONTROL
	endm


VRAM_GETCHARPOS macro \1, \2, \3
	move.l #\1 + ((\3)*128) + ((\2)*2),d1
	endm

VRAM_GETCHARPOS_A macro \1, \2
	move.l #VDPADDR_SCROLL_A + ((\2)*128) + ((\1)*2),d1
	endm
VRAM_DECLARE_CHARPOS_A macro \1, \2
	dc.l VDPADDR_SCROLL_A + ((\2)*128) + ((\1)*2)
	endm


VRAM_GETCHARPOS_WINDOW macro \1, \2
	move.l #VDPADDR_WINDOW + ((\2)*128) + ((\1)*2),d1
	endm


AUTOINC macro \1
	move.w #REG_AUTOINC|\1,VDP_CONTROL
	endm

SCROLL_START_WRITE_XPOS macro
	move.l #VDP_VRAM_WRITE|((VDPADDR_HSCROLL&$3fff)<<16)|((VDPADDR_HSCROLL&$c000)>>14),VDP_CONTROL
	endm
SCROLL_START_WRITE_XPOS2 macro
	move.l #VDP_VRAM_WRITE|((VDPADDR_HSCROLL2&$3fff)<<16)|((VDPADDR_HSCROLL2&$c000)>>14),VDP_CONTROL
	endm

SCROLL_START_WRITE_YPOS macro
	move.l #VDP_VRAM_WRITE_VSCROLL,VDP_CONTROL ; setup write to vscroll
	endm

VDP_DISABLE_HBL macro	
	move.w	#REG_MODE1 | REGMASK_MODE1_REQUIRED , VDP_CONTROL
	endm



; d0.b = color index
; uses palette 0
VDP_SetBorderColor:
	PUSHALL
	move.w #REG_BACKGROUND_COLOR,d1
    or.w d0,d1
    move.w d1,VDP_CONTROL
	POPALL
    rts  

VDP_ClearBorderColor:
	PUSHALL
	move.w #REG_BACKGROUND_COLOR,d1
    move.w d1,VDP_CONTROL
	POPALL
    rts  


;-------------------------------------------------------------------------------
; BuildVRAMWriteAddress
; builds the VRAM write address based on a relative address
; i.e. - passing $2200 should return $62000000
; d1 = relative VDP write address, final result is also stored in d1
; d0 is modified in this routine
;-------------------------------------------------------------------------------
VDP_BuildVRAMWriteAddress:
	; the two highest bits in d1 need to be the lowest bits in the final result
	move.w	d1,d0 ; start by copying d1 to d0	
	lsr.w	#7,d0	; shift bits 7 to the right
	lsr.w	#7,d0	; shift bits 7 more to the right
	and.l	#3,d0	; clear all but lowest two
	; the two highest bits from d1 are now in d0
	swap	d1	; move the value in d1 to the high word
	and.l	#%00111111111111110000000000000000,d1	; clear all but the magic 14
	add.l	d0,d1	; add the value in d0
	add.l	#VDP_VRAM_WRITE,d1	; add the base VRAM write address
	rts

VDP_BuildAndSetVRAMWriteAddress:
	; the two highest bits in d1 need to be the lowest bits in the final result
	move.w	d1,d0 ; start by copying d1 to d0	
	lsr.w	#7,d0	; shift bits 7 to the right
	lsr.w	#7,d0	; shift bits 7 more to the right
	and.l	#3,d0	; clear all but lowest two
	; the two highest bits from d1 are now in d0
	swap	d1	; move the value in d1 to the high word
	and.l	#%00111111111111110000000000000000,d1	; clear all but the magic 14
	add.l	d0,d1	; add the value in d0
	add.l	#VDP_VRAM_WRITE,d1	; add the base VRAM write address
	move.l d1,VDP_CONTROL
	rts


; d0.0 source address
; d1 dest addr in vram
; d2.L length
; d3 autoinc
; can save a few scans by caching this stuff
VDP_SetDMA:

	or.w #REG_AUTOINC,d3
	move.w d3,VDP_CONTROL

	lsr.l #1,d2

	move.l  d0, d7
    lsr.l   #1, d7
    and.l   #$7FFFFF, d7

	lea     VDP_CONTROL, a0
    lea     -10(sp), sp
    
    move.l  sp, a5
    move.l  #(REG_DMALEN_HI<<16)|REG_DMALEN_LO, (a5)+
    move.l  #(REG_DMA_SOURCE_HI<<16)|REG_DMA_SOURCE_MID, (a5)+
    move.w  #REG_DMA_SOURCE_LO, (a5)+
    
    movep.l d7, -7(a5)
    movep.w d2, -9(a5)		; length
    
    move.l  (sp)+, (a0)
    move.l  (sp)+, (a0)
    move.w  (sp)+, (a0)

 	and.l   #$FFFF, d1
    lsl.l   #2, d1
    lsr.w   #2, d1
    swap    d1
    or.l    #DMA_DESTINATION_VRAM, d1
	move.l  d1, -(sp)
	move.w  (sp)+, (a0)
    move.w  (sp)+, (a0)

	rts


; d0.0 source address
; d1 dest addr in vram
; d2.L length
; d3 autoinc
; can save a few scans by caching this stuff
; a0 is ram address to write to
VDP_CreateDMA:

	;or.w #REG_AUTOINC,d3
	;move.w d3,VDP_CONTROL

	lsr.l #1,d2

	move.l  d0,d7
    lsr.l   #1,d7
    and.l   #$7FFFFF,d7

    lea     -10(sp),sp
    
    move.l  sp,a5
    move.l  #(REG_DMALEN_HI<<16)|REG_DMALEN_LO,(a5)+
    move.l  #(REG_DMA_SOURCE_HI<<16)|REG_DMA_SOURCE_MID,(a5)+
    move.w  #REG_DMA_SOURCE_LO,(a5)+
    
    movep.l d7,-7(a5)
    movep.w d2,-9(a5)		; length
    
    move.l  (sp)+,(a0)+
    move.l  (sp)+,(a0)+
    move.w  (sp)+,(a0)+

 	and.l   #$FFFF,d1
    lsl.l   #2,d1
    lsr.w   #2,d1
    swap    d1
    or.l    #DMA_DESTINATION_VRAM,d1
	move.l  d1,-(sp)
	move.w  (sp)+,(a0)+
    move.w  (sp)+,(a0)+

	rts


VDP_SetDMA_CRAM:

;REG_DMALEN_LO equ $9300			;L7-L0: Low byte of DMA length in bytes, divided by 2.
;REG_DMALEN_HI equ $9400			;H7-H0: High byte of DMA length in bytes, divided by 2.

	or.w #REG_AUTOINC,d3
	move.w d3,VDP_CONTROL

	lsr.l #1,d2

	move d2,d3
	and #$ff,d3
	or.w #REG_DMALEN_LO,d3
	move d3,VDP_CONTROL
	

	move d2,d3
	and #$ff00,d3
	lsr #8,d3
	or.w #REG_DMALEN_HI,d3
	move d3,VDP_CONTROL

	lsr.l #1,d0
	move.l d0,d3
	and.l #$ff,d3
	or #REG_DMA_SOURCE_LO,d3
	move d3,VDP_CONTROL

	move.l d0,d3
	and.l #$ff00,d3
	lsr.l #8,d3
	or #REG_DMA_SOURCE_MID,d3
	move d3,VDP_CONTROL

	move.l d0,d3
	and.l #$7f0000,d3
	swap d3
	or #REG_DMA_SOURCE_HI,d3
	move d3,VDP_CONTROL

	move.l d1,d3
	and.l #$3fff,d3
	swap d3
	clr.w d3

	move.l d1,d4
	and.l #$c000,d4
	lsr.l #8,d4
	lsr.l #6,d4

	or.l d3,d4
	or.l #DMA_DESTINATION_CRAM,d4
	move.l d4,VDP_CONTROL

	rts

	
VDP_EnableShadowHighlightMode:
	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE|REGMASK_MODE4_SH_MODE,VDP_CONTROL
	rts

VDP_DisableShadowHighlightMode:
	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
	rts	


	
InitVDP:
;	lea	VDPInitDataStart,a0	; load the address of the VDP init data to a0
	;move.w	#(VDPInitDataEnd-VDPInitDataStart)/2,d1	; length of init data to d1
;.loop:
;	move.w	(a0)+,(VDP_CONTROL)	; write the init data
;	dbf	d1,.loop		; decrement value of d1 and loop if not 0

	;move.w #$8d00,VDP_CONTROL		; dummy for now
	;SETREG_HSCROLL VDPADDR_HSCROLL

	move.w	#REG_MODE1 | REGMASK_MODE1_REQUIRED, VDP_CONTROL
	move.w	#REG_MODE2 | REGMASK_MODE2_REQUIRED |REGMASK_MODE2_ENABLE_DISPLAY |REGMASK_MODE2_ENABLE_VINT |REGMASK_MODE2_ENABLE_DMA, VDP_CONTROL

	AUTOINC 2	; 

	; rts

	SETREG_PATTERNNAME_SCROLLA VDPADDR_SCROLL_A
	SETREG_PATTERNNAME_WINDOW VDPADDR_WINDOW
	SETREG_PATTERNNAME_SCROLLB VDPADDR_SCROLL_B
	SETREG_PATTERNNAME_SPRITE_ATTRIBUTE VDPADDR_SPRITE_ATTR
	move.w #REG_6,VDP_CONTROL
	move.w #REG_BACKGROUND_COLOR,VDP_CONTROL
	move.w #REG_8,VDP_CONTROL
	move.w #REG_9,VDP_CONTROL
	move.w #REG_HINT,VDP_CONTROL
	move #REG_MODE3 | REGMASK_MODE3_HSCROLLMODE_FULL |REGMASK_MODE3_VSCROLLMODE_FULL, VDP_CONTROL
	move #REG_MODE4 | REGMASK_MODE4_H40 |REGMASK_MODE4_NO_INTERLACE , VDP_CONTROL
	SETREG_HSCROLL VDPADDR_HSCROLL
	move.w #REG_14,VDP_CONTROL

	; rts. Black screen after this

	move #REG_SCROLLSIZE | VDP_PLANESIZE_64x32, VDP_CONTROL
	move #REG_WINDOW_HPOS | 0, VDP_CONTROL
	move #REG_WINDOW_VPOS | 0, VDP_CONTROL

	rts

	move #REG_DMALEN_LO | $ff, VDP_CONTROL
	move #REG_DMALEN_HI | $ff, VDP_CONTROL
	move #REG_DMA_SOURCE_LO | 0, VDP_CONTROL
	move #REG_DMA_SOURCE_MID | 0, VDP_CONTROL
	move #REG_DMA_SOURCE_HI | 0, VDP_CONTROL

	rts	
