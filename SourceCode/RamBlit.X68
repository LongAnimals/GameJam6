
;-------------------------------------------------------------------------------------------------------
;RAM BLITTER
;-------------------------------------------------------------------------------------------------------

    clrso
ramblit_source_image_addr so.l 1
ramblit_dest_addr so.l 1

ramblit_source_x so.w 1
ramblit_source_y so.w 1
ramblit_source_w so.w 1
ramblit_source_h so.w 1

ramblit_dest_x so.w 1
ramblit_dest_y so.w 1
ramblit_vram_offset so.w 1
ramblit_struct_size so.b 0


RAMBLIT_ClipDest:
    lea g_ramblit_data,a5
    
RAMBLIT_CLIP_X0 equ 0     ; inclusive
RAMBLIT_CLIP_X1 equ 40      ; exclusive. Display 0-X

RAMBLIT_CLIP_Y0 equ -12     ; inclusive
RAMBLIT_CLIP_Y1 equ 23  ;27      ; exclusive. Display 0-Y

    
; top edge:
    move ramblit_dest_y(a5),d0
    
    move d0,d1
    add ramblit_source_h(a5),d1
    
    cmp #RAMBLIT_CLIP_Y0,d1
    blt .cull

    cmp #RAMBLIT_CLIP_Y0,d0
    bge .ok_top
    
    move #RAMBLIT_CLIP_Y0,d2
    sub d0,d2

    sub d2,ramblit_source_h(a5)
    add d2,ramblit_source_y(a5)
    move #RAMBLIT_CLIP_Y0,ramblit_dest_y(a5)
    
.ok_top:
    
;bottom edge
    move ramblit_dest_y(a5),d0
    move d0,d1
    add ramblit_source_h(a5),d1
    
    cmp #RAMBLIT_CLIP_Y1,d0
    bgt .cull
    
    cmp #RAMBLIT_CLIP_Y1,d1
    blt .ok_bottom
    sub #RAMBLIT_CLIP_Y1,d1
    sub d1,ramblit_source_h(a5)
    
.ok_bottom:

;---------------

    
; left edge:
    move ramblit_dest_x(a5),d0
    move d0,d1
    add ramblit_source_w(a5),d1
    
    cmp #RAMBLIT_CLIP_X0,d1
    blt .cull

    cmp #RAMBLIT_CLIP_X0,d0
    bge .ok_left
    
    move d0,d2
    sub #RAMBLIT_CLIP_X0,d2
    
    add d2,ramblit_source_w(a5)
    sub d2,ramblit_source_x(a5)
    move #RAMBLIT_CLIP_X0,ramblit_dest_x(a5)

.ok_left:
    
;right edge
    move ramblit_dest_x(a5),d0
    move d0,d1
    add ramblit_source_w(a5),d1
    
    cmp #RAMBLIT_CLIP_X1,d0
    bgt .cull
    
    cmp #RAMBLIT_CLIP_X1,d1
    blt .ok_right
    sub #RAMBLIT_CLIP_X1,d1
    sub d1,ramblit_source_w(a5)
    
.ok_right:
    rts

.cull:
    move #-1,ramblit_source_w(a5)
    rts

RAMBLIT_Clear:
    move.l a0,-(sp)
    lea g_ramblit_data,a5
    
    move ramblit_vram_offset(a5),d0
    move d0,d1
    swap d0
    move d1,d0
       
    move.l ramblit_dest_addr(a5),a0
    move #((64*32*2)>>5)-1,d1
.lp:
    move.l d0,(a0)+
    move.l d0,(a0)+
    move.l d0,(a0)+
    move.l d0,(a0)+
    move.l d0,(a0)+
    move.l d0,(a0)+
    move.l d0,(a0)+
    move.l d0,(a0)+
    dbra d1,.lp
    move.l (sp)+,a0
    rts

RAMBLIT_Blit:
    move.l a0,-(sp)
    bsr RAMBLIT_ClipDest

    lea g_ramblit_data,a5
    
    tst ramblit_source_w(a5)
    ble .r
    tst ramblit_source_h(a5)
    ble .r
    
    move.l ramblit_dest_addr(a5),a3
    move.l ramblit_source_image_addr(a5),a4
    lea 6(a4),a2

; dest offset x
    move ramblit_dest_x(a5),d0
    add d0,d0
    add d0,a3

; dest offset y
    move ramblit_dest_y(a5),d0
    lsl #7,d0
    add d0,a3


; source x
    move ramblit_source_x(a5),d0
    add d0,d0
    add d0,a2

; source y
    move ramblit_source_y(a5),d0
    beq .no_sourcey_offset
    add d0,d0
    mulu tilemap_w(a4),d0
    add d0,a2
.no_sourcey_offset:

    
    move ramblit_source_h(a5),d7
    subq #1,d7
.ylp:
    move.l a2,a0
    move.l a3,a1
    move ramblit_source_w(a5),d6
    subq #1,d6
    move ramblit_vram_offset(a5),d5
.xlp:
    move (a0)+,d0
    add d5,d0
    move d0,(a1)+
    dbra d6,.xlp
    
    move 2(a4),d0
    add d0,d0
    add d0,a2           ; next source scan
    lea 128(a3),a3     ; next dest scan
    dbra d7,.ylp
.r: 
    move.l (sp)+,a0    
    rts     


RAMBLIT_Blit2:
    move.l a0,-(sp)
    bsr RAMBLIT_ClipDest

    lea g_ramblit_data,a5
    
    tst ramblit_source_w(a5)
    ble .r
    tst ramblit_source_h(a5)
    ble .r
    
    move.l ramblit_dest_addr(a5),a3
    move.l ramblit_source_image_addr(a5),a4
    lea 6(a4),a2

; dest offset x
    move ramblit_dest_x(a5),d0
    add d0,d0
    add d0,a3

; dest offset y
    move ramblit_dest_y(a5),d0
    lsl #7,d0
    add d0,a3


; source x
    move ramblit_source_x(a5),d0
    add d0,d0
    add d0,a2

; source y
    move ramblit_source_y(a5),d0
    beq .no_sourcey_offset
    add d0,d0
    mulu tilemap_w(a4),d0
    add d0,a2
.no_sourcey_offset:

    move ramblit_vram_offset(a5),d5
    move d5,d0
    swap d5
    move d0,d5
    
    move ramblit_source_h(a5),d7
    subq #1,d7
.ylp:
    move.l a2,a0
    move.l a3,a1
    move ramblit_source_w(a5),d6
    lsr #1,d6
    subq #1,d6
.xlp:
    move.l (a0)+,d0
    add.l d5,d0
    move.l d0,(a1)+
    dbra d6,.xlp
    
    move 2(a4),d0
    add d0,d0
    add d0,a2           ; next source scan
    lea 128(a3),a3     ; next dest scan
    dbra d7,.ylp
.r: 
    move.l (sp)+,a0    
    rts     

RAMBLIT_Blit2_12w:
    move.l a0,-(sp)
    bsr RAMBLIT_ClipDest

    lea g_ramblit_data,a5
    
    tst ramblit_source_w(a5)
    ble .r
    tst ramblit_source_h(a5)
    ble .r
    
    move.l ramblit_dest_addr(a5),a3
    move.l ramblit_source_image_addr(a5),a4
    lea 6(a4),a2

; dest offset x
    move ramblit_dest_x(a5),d0
    add d0,d0
    add d0,a3

; dest offset y
    move ramblit_dest_y(a5),d0
    lsl #7,d0
    add d0,a3


; source x
    move ramblit_source_x(a5),d0
    add d0,d0
    add d0,a2

; source y
    move ramblit_source_y(a5),d0
    beq .no_sourcey_offset
    add d0,d0
    mulu tilemap_w(a4),d0
    add d0,a2
.no_sourcey_offset:

    move ramblit_vram_offset(a5),d5
    move d5,d0
    swap d5
    move d0,d5
    
    move ramblit_source_h(a5),d7
    subq #1,d7
.ylp:
    move.l a2,a0
    move.l a3,a1

    rept 6
    move.l (a0)+,d0
    add.l d5,d0
    move.l d0,(a1)+
    endr
    
    move 2(a4),d0
    add d0,d0
    add d0,a2           ; next source scan
    lea 128(a3),a3     ; next dest scan
    dbra d7,.ylp
.r: 
    move.l (sp)+,a0    
    rts     



; called from a gameobject, a0 being gameobject

RAMBLIT_BlitSprite:
    ;lea SPRGROUP_gunslugs_player_0,a3

    lea sprgroup_firstFrame(a3),a3
    move.w go_frame(a0),d0                  ; frame
	lsl #sprgroupframe_sizeshift,d0	; couple of scans extra for mult
	add d0,a3	

    
    move.l m_RamTileMap,a1
    move go_x(a0),d0
    lsr #3,d0
    add d0,d0
    add d0,a1
    move go_y(a0),d0
    lsr #3,d0
    lsl #7,d0
    add d0,a1
    
    move sprgroupframe_sizeFlags(a3),d0
    lsr #8,d0
    and #15,d0
    lsl #2,d0
    lea RAMBLIT_SpriteSizeTable,a2
    move.l (a2,d0),a2

    move go_vdpbase(a0),d6
    add  sprgroupframe_charoffset(a3),d6


.loop:
    move (a2)+,d0
    bmi .done
    
    move.l a1,a4
    add d0,d0
    add d0,a4
    
    move (a2)+,d1
    lsl #7,d1
    add d1,a4
    
    move d6,d5
    or sprgroupframe_paletteFlags(a3),d5
    move d5,(a4)

    addq #1,d6    
    bra .loop
    
    
.done:
    rts
    

    ;dc.w 15	;Origin Y
	;dc.w SPR_2x2	;size flags
	;dc.w 0	;Cell offset
	;dc.w PAL_1|FLIP_NONE	;palette and flips
	;dc.w 8	;Origin X
	;dc.w 0,0,0	;Filler
    
    ;go_vdpbase(a0)
    
   
RAMBLIT_SpriteSizeTable:
    dc.l .0,.4,.8,.12
    dc.l .1,.5,.9,.13
    dc.l .2,.6,.10,.14
    dc.l .3,.7,.11,.15

.0: dc.w 0,0,-1                                          ; SPR_1x1  equ %0000<<8  ; 1x1 tiles
.1: dc.w 0,0, 1,0, -1                                       ; SPR_2x1  equ %0100<<8  ; 2x1 tiles
.2: dc.w 0,0, 1,0, -1                                        ; SPR_3x1  equ %1000<<8  ; 3x1 tiles
.3: dc.w 0,0, 1,0, 2,0, 3,0,-1                                ; SPR_4x1  equ %1100<<8  ; 4x1 tiles
.4: dc.w 0,0, 0,1, -1                                         ; SPR_1x2  equ %0001<<8  ; 1x2 tiles
.5: dc.w 0,0, 0,1, 1,0, 1,1, -1                             ; SPR_2x2  equ %0101<<8  ; 2x2 tiles
.6: dc.w 0,0, 0,1, 1,0, 1,1, 2,0, 2,1, -1                   ; SPR_3x2  equ %1001<<8  ; 3x2 tiles
.7: dc.w 0,0, 1,0, 1,0, 1,1, 2,0, 2,1, 3,0, 3,1, -1          ; SPR_4x2  equ %1101<<8  ; 4x2 tiles
.8: dc.w 0,0, 0,1, 0,2, -1                                   ; SPR_1x3  equ %0010<<8  ; 1x3 tiles
.9: dc.w 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, -1                    ; SPR_2x3  equ %0110<<8  ; 2x3 tiles
.10: dc.w 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 2,0, 2,1, 2,2, -1   ; SPR_3x3  equ %1010<<8  ; 3x3 tiles
.11: dc.w 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 2,0, 2,1, 2,2, 3,0, 3,1, 3,2, -1   ; SPR_4x3  equ %1110<<8  ; 4x3 tiles
.12: dc.w 0,0, 0,1, 0,2, 0,3, -1                                     ; SPR_1x4  equ %0011<<8  ; 1x4 tiles
.13: dc.w 0,0, 0,1, 0,2, 0,3, 1,0, 1,1, 1,2, 1,3, -1                     ; SPR_2x4  equ %0111<<8  ; 2x4 tiles
.14: dc.w 0,0, 0,1, 0,2, 0,3, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 2,2, 2,3, -1    ; SPR_3x4  equ %1011<<8  ; 3x4 tiles
.15: dc.w 0,0, 0,1, 0,2, 0,3, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 2,2, 2,3, 3,0, 3,1, 3,2, 3,3, -1       ; SPR_4x4  equ %1111<<8  ; 4x4 tiles
 