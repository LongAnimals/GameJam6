

COLORBARS_PALADDR equ (VDP_CRAM_WRITE+0)    ;(31<<17))


; a0 colorbar format address, eg. ImageGroup_Screens_COLORBARS_title_fg
ColorBars_InitHBL:
	move.b #1,g_has_initialised_hbl
	move #0,g_hblcount
	bsr Colorbars_SetColorTable
	rts


; write to a0+
Colorbars_UpdateColorTable
    move g_timer1,d0
    and #15,d0
    lsl #4,d0

    ;and #255,d0
    lsl #2,d0
    move.l m_hblankDataTable,a0
    add d0,a0
    
    move g_timer1,d0
    lsr #4,d0
    and #3,d0
    lsl #2,d0
    
    lea ExportedGradients+2,a1
    move.l (a1,d0),a1
    lea 4(a1),a1

    move #32-1,d7
.lp
    move (a1)+,d0
    
    lea FadeLookupTable+(1024*7),a2
    move (a2,d0),d0

    
    move d0,(a0)+
    
    lea FadeLookupTable+(1024*3),a2
    move (a2,d0),d0
    
    move d0,(a0)+
    dbra d7,.lp
    rts

    
    
    

; write 2 colors for each scan
Colorbars_SetColorTable:
    move.l m_hblankDataTable,a0
    move.l a0,a3
    lea 1024(a3),a3
    
    move #3*4,d0
    lea ExportedGradients+2,a1
    move.l (a1,d0),a1
    lea 4(a1),a1

    move #256-1,d7
.lp
    move (a1)+,d0
    
    lea FadeLookupTable+(1024*7),a2
    move (a2,d0),d0

    
    move d0,(a0)+
    move d0,(a3)+
    
    lea FadeLookupTable+(1024*3),a2
    move (a2,d0),d0
    
    move d0,(a0)+
    move d0,(a3)+
    dbra d7,.lp
    rts
    
	

HBL_TurnOff:
;    move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
    rts

ColorBars_HBL_InitForFrame:
    ifd SHOW_BORDER_COLORS
    rts
    endif
    ;rts
	tst.b g_has_initialised_hbl
	beq .done
	move.b #0,g_has_initialised_hbl
	
	move #REG_HINT|0,d0
	move d0,VDP_CONTROL
	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED|REGMASK_MODE1_ENABLEHINT,VDP_CONTROL


	move.l #ColorBars_HBL_Len,d0
	lea HBlankRamAddr,a1
	lea ColorBars_HBL,a0
	jsr UTILS_Copy
.done:
.no

    ;bsr Colorbars_UpdateColorTable  
    move.l m_hblankDataTable,a6
    
    lea SinCosTable,a0
    move g_timer1,d0
    and.l #$ff,d0
    lsl #2,d0
    adda.l d0,a0
    move.w (a0)+,d1    ;sin
    lsr #8,d1
    move d1,d5
    
    and #$ff,d5
    add d5,d5    
    add d5,d5    
    add d5,a6    
    
    move.l #VDP_CRAM_WRITE+COLORBAR_ADDR,VDP_CONTROL
	rts

COLORBAR_ADDR equ ($42<<16)

;    BORDER
ColorBars_HBL:
.start:
    move.l (a6)+,VDP_DATA
    move.l #VDP_CRAM_WRITE+COLORBAR_ADDR,VDP_CONTROL
    rte
.end:
ColorBars_HBL_Len equ (.end-.start)

