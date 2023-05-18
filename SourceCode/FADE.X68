
;-----------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------

FADE_INFO_STOP equ 0
FADE_INFO_IN equ 1
FADE_INFO_OUT equ 2
FADE_SPEED equ $80		;(8:8)


   clrso
fade_level so.b 2		; 8+8
fade_info so.b 1
fade_updated so.b 1
fade_done_callback so.l 1
fade_structsize so.b 0

;-----------------------------------------------------------------------------------------------------
; Macros 
;-----------------------------------------------------------------------------------------------------
FADE_STOP MACRO
	move.l #\1,g_fade+fade_done_callback
	ENDM

FADE_START_IN MACRO \1
    jsr SOUND_StartFadeIn
	move.l #\1,g_fade+fade_done_callback
	move.b #FADE_INFO_IN,g_fade+fade_info
	ENDM

FADE_START_OUT MACRO \1
	jsr SOUND_StartFadeOut
	move.l #\1,g_fade+fade_done_callback
	move.b #FADE_INFO_OUT,g_fade+fade_info
	ENDM

FADE_SETVALUE MACRO \1
	move.b #\1,g_fade+fade_level
	move.b #0,g_fade+fade_level+1
	ENDM



;-----------------------------------------------------------------------------------------------------
; Palette handling functionality
; usually called from VBL
; Just fades all palettes in or out, and calls a pre-update function
;-----------------------------------------------------------------------------------------------------
;
; THIS SHOULD BE SPLIT IN TO VBL and nonVBL parts
;
;-----------------------------------------------------------------------------------------------------


FADE_Update:

.FADE_Internal_DoMovement:
	cmp.b #FADE_INFO_STOP,g_fade+fade_info
	beq .nomovement

	cmp.b #FADE_INFO_IN,g_fade+fade_info
	bne .notIN

.fadingIN:
	add.w #FADE_SPEED,g_fade+fade_level
	cmp.b #7,g_fade+fade_level
	blt .skip1
	move.w #7<<8,g_fade+fade_level
	move.b #FADE_INFO_STOP,g_fade+fade_info
.skip1:
	move.b #1,g_fade+fade_updated
	bra .testcallback

.notIN: 

; therefore out
	sub.w #FADE_SPEED,g_fade+fade_level
	tst.b g_fade+fade_level
	bgt .skip2
	move.w #0,g_fade+fade_level
	move.b #FADE_INFO_STOP,g_fade+fade_info
.skip2:
	move.b #1,g_fade+fade_updated
	
.testcallback:
	cmp.b #FADE_INFO_STOP,g_fade+fade_info		; has done? do callback
	bne .nocallback
	move.l g_fade+fade_done_callback,d0
	beq .nocallback
	move.l #0,g_fade+fade_done_callback
	move.l d0,a0
	jsr (a0)
.nocallback:
.nomovement:
.exit:
	tst.b g_fade+fade_updated
	beq .notupdated
	bsr FADE_CopyAllPalettesWithFadeValue_FastColorFormat
	move.b #0,g_fade+fade_updated
	bsr FADE_DMAAllPalettes	; slightly faster than writing directly to VDP
.notupdated:
	rts


;-----------------------------------------------------------------------------------------------------
; Clear all ram copies of palettes
;-----------------------------------------------------------------------------------------------------
; d0 index of palette
; a0 source palette data
FADE_CopySinglePaletteToSource:
	lea RamPalettes,a1
	lsl #5,d0
	add d0,a1
	move #8-1,d0
.loop:
	move.l (a0)+,(a1)+
	dbra	d0,.loop
	move.b #1,g_fade+fade_updated
	rts

;-----------------------------------------------------------------------------------------------------
; Clear all ram copies of palettes
;-----------------------------------------------------------------------------------------------------

FADE_ClearAll:
	lea RamPalettes,a0
	move #(4*8)-1,d0
	moveq #0,d1
.loop:
	move.l d1,(a0)+
	dbra	d0,.loop
	move.b #1,g_fade+fade_updated
	rts


;-----------------------------------------------------------------------------------------------------
; Dump all palettes to VRAM
;-----------------------------------------------------------------------------------------------------

FADE_DMAAllPalettes:
coltab_addr equ $0
coltab_len equ 128
	move.w #REG_AUTOINC|2,VDP_CONTROL
	move.w #REG_DMALEN_LO+((coltab_len>>1)&$FF),VDP_CONTROL
	move.w #REG_DMALEN_HI+(((coltab_len>>1)&$FF00)>>8),VDP_CONTROL
	move.w #REG_DMA_SOURCE_LO+((RamPalettesDMA>>1)&$FF),VDP_CONTROL
	move.w #REG_DMA_SOURCE_MID+(((RamPalettesDMA>>1)&$FF00)>>8),VDP_CONTROL
	move.w #REG_DMA_SOURCE_HI+(((RamPalettesDMA>>1)&$7F0000)>>16),VDP_CONTROL
	move.l #DMA_DESTINATION_CRAM+((coltab_addr&$3FFF)<<16)+((coltab_addr&$C000)>>14),VDP_CONTROL
	rts


; returns fade color table in a0
FADE_GetFadeColorTableAddr:
	moveq #0,d0
	move.b g_fade+fade_level,d0	; 0 is black, 7 is full
	lea FadeLookupTable,a0
	lsl #8,d0
	lsl #2,d0
	add d0,a0
	rts

; a0 source
; a1 dest	(different locations)
; d0 num entries
; uses current fade value
FADE_ConvertColorListToFadeValues_FastColorFormat:
	move.l a1,a2	; dest
	move.l a0,a1 	; source
	move d0,d7
	subq #1,d7
	bsr FADE_GetFadeColorTableAddr
.loop:
	move.w	(a1)+,d0
	move (a0,d0),(a2)+
	dbra	d7,.loop
	rts


FADE_CopyAllPalettesWithFadeValue_FastColorFormat:
	bsr FADE_GetFadeColorTableAddr

	lea RamPalettesDMA,a3
	lea RamPalettes,a2

	rept 4*2
	movem.w	(a2)+,d0-d7
	move (a0,d0),(a3)+
	move (a0,d1),(a3)+
	move (a0,d2),(a3)+
	move (a0,d3),(a3)+
	move (a0,d4),(a3)+
	move (a0,d5),(a3)+
	move (a0,d6),(a3)+
	move (a0,d7),(a3)+
	endr					;1504
	rts


; fade level in d0
; palette index in d1
FADE_CopySinglePalettesWithFadeValue_FastColorFormat:
    lea FadeLookupTable,a0
    lsl #8,d0
    lsl #2,d0
    add d0,a0

    lsl #5,d1

	lea RamPalettesDMA,a3
	lea RamPalettes,a2
	add d1,a2
	add d1,a3

	rept 1*2
	movem.w	(a2)+,d0-d7
	move (a0,d0),(a3)+
	move (a0,d1),(a3)+
	move (a0,d2),(a3)+
	move (a0,d3),(a3)+
	move (a0,d4),(a3)+
	move (a0,d5),(a3)+
	move (a0,d6),(a3)+
	move (a0,d7),(a3)+
	endr					;1504
