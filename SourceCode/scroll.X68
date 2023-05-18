
SCROLL_CreateDMATables:
    lea ScrollDMATableA_Rows,a0
    move.l #VDPADDR_SCROLL_A,d5
    move.l #ScrollRowEdgeBufferA,d6
    bsr .dorows    

    lea ScrollDMATableA_Columns,a0    
    move.l #VDPADDR_SCROLL_A,d5
    move.l #ScrollColumnEdgeBufferA,d6
    
    bsr .docolumns

    lea ScrollDMATableB_Rows,a0
    move.l #VDPADDR_SCROLL_B,d5
    move.l #ScrollRowEdgeBufferB,d6
    bsr .dorows    

    lea ScrollDMATableB_Columns,a0    
    move.l #VDPADDR_SCROLL_B,d5
    move.l #ScrollColumnEdgeBufferB,d6
    bsr .docolumns
    
    rts
    
.dorows:
    move #0,d7
.rowloop:
    move.l d5,d1
    move d7,d0
    and.w #31,d0
    lsl.w #7,d0
    add.w d0,d1
    move.l d6,d0
    move.l #64*2,d2
    move #2,d3
    PUSHALL
    jsr VDP_CreateDMA
    POPALL
    lea 16(a0),a0
    
    add #1,d7
    cmp #32,d7
    blt .rowloop
    rts
    
.docolumns:
    move #0,d7
.columnloop:
    move.l d5,d1
    move d7,d0
    and.w #63,d0
    add d0,d0
    add.w d0,d1
    move.l d6,d0
    move.l #32*2,d2
    move #128,d3
    PUSHALL
    jsr VDP_CreateDMA
    POPALL
    lea 16(a0),a0

    add #1,d7
    cmp #64,d7
    blt .columnloop
    rts

    

SCROLL_FillScrollA:
    move.l g_scroll_y,-(sp)
    move #28-1,d7
.lp:
    move.w g_scroll_y,d5
    lsr #3,d5
    move d5,g_scroll_rowA
    PUSHALL
    bsr Scroll_DrawRowToRamBufferA
    POPALL
    bsr Scroll_DumpRowToVDPA
    add #8,g_scroll_y
    dbra d7,.lp
    move.l (sp)+,g_scroll_y
    rts 

SCROLL_FillScrollB:
    move.l g_scroll_y,-(sp)
    move #28-1,d7
.lp:
    move.w g_scroll_y,d5
    lsr #3,d5
    move d5,g_scroll_rowB
    PUSHALL
    bsr Scroll_DrawRowToRamBufferB
    POPALL
    bsr Scroll_DumpRowToVDPB
    add #8,g_scroll_y
    dbra d7,.lp
    move.l (sp)+,g_scroll_y
    rts 
    
    
Scroll_UpdateEdgesA:
    bsr SCROLL_UpdateRowsA
    bsr SCROLL_UpdateColumnsA
    rts

Scroll_DumpEdgesToVDPA:
    bsr Scroll_DumpRowToVDPA
    bsr Scroll_DumpColumnToVDPA
    rts

Scroll_UpdateEdgesB:
    bsr SCROLL_UpdateRowsB
    bsr SCROLL_UpdateColumnsB
    rts

Scroll_DumpEdgesToVDPB:
    bsr Scroll_DumpRowToVDPB
    bsr Scroll_DumpColumnToVDPB
    rts
        

SCROLL_UpdateRowsA:
    move g_scroll_y,d5
    cmp g_scroll_oldy,d5
    bge .down
.up:
    lsr #3,d5
    bra .start
.down
    lsr #3,d5
    add #31,d5
.start:
    move d5,g_scroll_rowA
    bsr Scroll_DrawRowToRamBufferA
    rts

SCROLL_UpdateRowsB:
    move g_scroll_y,d5
    cmp g_scroll_oldy,d5
    bge .down
.up:
    lsr #3,d5
    bra .start
.down
    lsr #3,d5
    add #31,d5
.start:
    move d5,g_scroll_rowB
    bsr Scroll_DrawRowToRamBufferB
    rts


SCROLL_UpdateColumnsA:
    move g_scroll_x,d5
    cmp g_scroll_oldx,d5
    bge .right
.left:
    lsr #3,d5
    bra .start
.right:
    lsr #3,d5
    add #40,d5
.start:
    move d5,g_scroll_columnA
    bsr Scroll_DrawColumnToRamBufferA
    rts

SCROLL_UpdateColumnsB:
    move g_scroll_x,d5
    cmp g_scroll_oldx,d5
    bge .right
.left:
    lsr #3,d5
    bra .start
.right:
    lsr #3,d5
    add #40,d5
.start:
    move d5,g_scroll_columnB
    bsr Scroll_DrawColumnToRamBufferB
    rts


Scroll_DumpRowToVDPA:
    AUTOINC 2
    lea ScrollDMATableA_Rows,a0
    move g_scroll_rowA,d5
    and #31,d5
    lsl #4,d5
    add d5,a0
    
    lea VDP_CONTROL,a1
    move.l (a0)+,(a1)
    move.l (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    rts

Scroll_DumpRowToVDPB:
    AUTOINC 2
    lea ScrollDMATableB_Rows,a0
    move g_scroll_rowB,d5
    and #31,d5
    lsl #4,d5
    add d5,a0
    
    lea VDP_CONTROL,a1
    move.l (a0)+,(a1)
    move.l (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    rts

Scroll_DumpColumnToVDPA:
    AUTOINC 128
    lea ScrollDMATableA_Columns,a0
    move g_scroll_columnA,d5
    and #63,d5
    lsl #4,d5
    add d5,a0
    
    lea VDP_CONTROL,a1
    move.l (a0)+,(a1)
    move.l (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    
    AUTOINC 2
    rts

Scroll_DumpColumnToVDPB:
    AUTOINC 128
    lea ScrollDMATableB_Columns,a0
    move g_scroll_columnB,d5
    and #63,d5
    lsl #4,d5
    add d5,a0
    
    lea VDP_CONTROL,a1
    move.l (a0)+,(a1)
    move.l (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    move.w (a0)+,(a1)
    
    AUTOINC 2
    rts


; d5 is y offset in 8s
; do a full 64 wide line 
; map is assumed to be >=64 wide
; always draw from 0 in X in vram.. no need to wrap
 Scroll_DrawRowToRamBufferA:
    move.l sysg_levelInfo+levelinfo_tileMap1,a0
    ifd IS_GAME_COFFEE
    move.l sysg_levelInfo+levelinfo_tileMap0,a0
    endif
         
    lea 6(a0),a0
    lea ScrollRowEdgeBufferA,a1 
; y pos in to map
    move d5,d0
    mulu sysg_levelInfo+levelinfo_tileMap1_stride,d0
    add d0,a0    
    
; xpos in to map
    move g_scroll_x,d0
    lsr #3,d0
    add d0,d0
    add d0,a0
    move g_vram_fg,d1
 
    
    move g_scroll_x,d0
    lsr #3,d0
    move d0,d2
    and #63,d2
    add d2,d2
    move #63<<1,d3
    
    move #40-1,d7
.hlp:
    move (a0)+,d0
    add d1,d0
    move d0,(a1,d2)
    
    addq #2,d2
    and d3,d2
    dbra d7,.hlp

    rts

 Scroll_DrawRowToRamBufferB:
    move.l sysg_levelInfo+levelinfo_tileMap0,a0     
    lea 6(a0),a0
    
    lea ScrollRowEdgeBufferB,a1 

; y pos in to map
    move d5,d0
    mulu sysg_levelInfo+levelinfo_tileMap0_stride,d0     
    add d0,a0    
    
; xpos in to map
    move g_scroll_x,d0
    lsr #3,d0
    add d0,d0
    add d0,a0
    move g_vram_bg,d1
 
    
    move g_scroll_x,d0
    lsr #3,d0
    move d0,d2
    and #63,d2
    add d2,d2
    move #63<<1,d3
    
    move #40-1,d7
.hlp:
    move (a0)+,d0
    add d1,d0
    move d0,(a1,d2)
    
    addq #2,d2
    and d3,d2
    dbra d7,.hlp

    rts


; d5 is x offset in 8s
; do a full 32 high line 
; map is assumed to be >=32 high
 Scroll_DrawColumnToRamBufferA:
    move.l sysg_levelInfo+levelinfo_tileMap1,a0     
    ifd IS_GAME_COFFEE
    move.l sysg_levelInfo+levelinfo_tileMap0,a0
    endif
    lea 6(a0),a0

    lea ScrollColumnEdgeBufferA,a1 

; y pos in to map
    move d5,d0
    add d0,d0
    add d0,a0    
    
    
; xpos in to map
    move g_scroll_y,d0
    lsr #3,d0
    mulu sysg_levelInfo+levelinfo_tileMap1_stride,d0
    add d0,a0

    move g_vram_fg,d1
    
    move g_scroll_y,d0
    lsr #3,d0
    move d0,d2
    and #31,d2
    add d2,d2
    move #31<<1,d3
    
    
    move sysg_levelInfo+levelinfo_tileMap1_stride,d4
    
    move #32-1,d7
.vlp:
    move (a0),d0
    add d4,a0
    add d1,d0
    move d0,(a1,d2)
    addq #2,d2
    and d3,d2           ; wrap d2 offset in to ram buffer
    dbra d7,.vlp
    
    rts
    
    
    
 Scroll_DrawColumnToRamBufferB:
    move.l sysg_levelInfo+levelinfo_tileMap0,a0
         
    lea 6(a0),a0
    
    lea ScrollColumnEdgeBufferB,a1 

; y pos in to map
    move d5,d0
    add d0,d0
    add d0,a0    
    
    
; xpos in to map
    move g_scroll_y,d0
    lsr #3,d0
    mulu sysg_levelInfo+levelinfo_tileMap0_stride,d0
    ;lsl #8,d0
    add d0,a0

    move g_vram_bg,d1
 
    
    move g_scroll_y,d0
    lsr #3,d0
    move d0,d2
    and #31,d2
    add d2,d2
    move #31<<1,d3
    
    move sysg_levelInfo+levelinfo_tileMap0_stride,d4
    move #32-1,d7
.vlp:
    move (a0),d0
    add d4,a0
    add d1,d0
    move d0,(a1,d2)
    
    addq #2,d2
    and d3,d2
    dbra d7,.vlp
    
    rts
    



SCROLL_ResetHardware:
	move #REG_MODE3 | REGMASK_MODE3_HSCROLLMODE_FULL |REGMASK_MODE3_VSCROLLMODE_FULL, VDP_CONTROL

	moveq #0,d0
	SCROLL_START_WRITE_XPOS   ;
	move.w d0,VDP_DATA    
	move.w d0,VDP_DATA    
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
	rts

SCROLL_UpdatePositionsVDP:

	lea VDP_DATA,a0	
	move.w 	g_scroll_x,d0
	move.w d0,d1
	asr #1,d1
	neg d0
	neg d1

; whole screen:
   SCROLL_START_WRITE_XPOS
	move.w d0,(a0)    
	move.w d1,(a0)

	move.w 	g_scroll_y,d0
	move d0,d1
	asr #1,d1

	SCROLL_START_WRITE_YPOS
	move d0,(a0)
	move d1,(a0)

	rts

SCROLL_SetNormalPlanes:
	move.l #VDP_VRAM_WRITE_A,g_scroll_vram_write_base_fg
	move.l #VDP_VRAM_WRITE_B,g_scroll_vram_write_base_bg
	move.w #0,g_scroll_priorityflag_fg
	move.w #0,g_scroll_priorityflag_bg
	rts




