

    clrso


SPRCACHE_Declare macro \1
    dc.l SprFrameCache+(\1*8)
    endm 

SPRCACHE_SetFrame macro \1
    ;move.l #SprFrameCache,go_cached_frame_addr(a0)
    move.l #SprFrameCache+(\1*8),go_cached_frame_addr(a0)
    endm

SPRCACHE_SetFrame_A1 macro \1
    move.l #SprFrameCache+(\1*8),go_cached_frame_addr(a1)
    endm
    

; a0 is list of dc.w SPRITES (do all frames per sprite). ends with -1
SpriteCache_BuildFrameList:
    move.l a0,a5                    ; a5 spr list
    move #0,g_sprcache_numframes
    
    lea SprFrameCache,a1
    move.l a1,g_sprcache_currentaddr
    
.sprlistloop:
    move (a5)+,d0           ; Sprite frame
    bmi .done
    
    move.l sysg_sprites_baseaddr,a4
    lea 2(a4),a4
    move d0,d1
    lsl #2,d1
    add d1,a4
    move.l (a4),a0          ; sprite    
    
    move.w sprgroup_numFrames(a0),d6
    sub #1,d6
    move #0,d1
.frameloop:
    PUSHALL
    bsr .getframestuff
    bsr SpriteCache_CacheFrame
    POPALL

    add #1,g_sprcache_numframes

    add #1,d1
    dbra d6,.frameloop
    
    bra .sprlistloop
    
.done:
    rts
    
; d0 = spr,d1 = frame
.getframestuff:
	move.l sysg_sprites_baseaddr2,a1    ;lea sprdefs+2,a1
	move d0,d2
	lsl #2,d0
	add d0,a1
	move.l (a1),a1
	add.l #sprgroup_firstFrame,a1

	lsl #sprgroupframe_sizeshift,d1
	add d1,a1
	move.l a1,g_sprcache_spraddr

	lea SpriteVDPOffsets,a1
	add d2,d2
	move.w (a1,d2),g_sprcache_sprcharoffset
    rts

    
SpriteCache_BuildFrames:
    rts
    move #0,g_sprcache_numframes
    
    lea SprFrameCache,a1
    move.l a1,g_sprcache_currentaddr
    
    move.l sysg_sprites_baseaddr,a4
    move (a4)+,d7   ; num sprites
    sub #1,d7
    
    move #0,d0      ; SPRITE_0
.spriteloop:
    move.l (a4)+,a0     ;sprgroup pointer
    move.w sprgroup_numFrames(a0),d6
    sub #1,d6
    move #0,d1
.frameloop:
    PUSHALL
    bsr .getframestuff
    bsr SpriteCache_CacheFrame
    POPALL

    add #1,g_sprcache_numframes

    add #1,d1
    dbra d6,.frameloop
    
    add #1,d0
    dbra d7,.spriteloop
    
    ;move g_sprcache_numframes,DebugArea
    ;DEBUG_HALT
    rts
    
; d0 = spr,d1 = frame
.getframestuff:
	move.l sysg_sprites_baseaddr2,a1    ;lea sprdefs+2,a1
	move d0,d2
	lsl #2,d0
	add d0,a1
	move.l (a1),a1
	add.l #sprgroup_firstFrame,a1

	lsl #sprgroupframe_sizeshift,d1
	add d1,a1
	move.l a1,g_sprcache_spraddr

	lea SpriteVDPOffsets,a1
	add d2,d2
	move.w (a1,d2),g_sprcache_sprcharoffset
    rts

SpriteCache_CacheFrame:
    move.l g_sprcache_currentaddr,a4
    move.l g_sprcache_spraddr,a2
    moveq #0,d6

;UPDATESPR_1a go_y(a0)
	move #0,d0              ; y pos
	sub.w (a2)+,d0	; sprgroupframe_originy(a2
	move.w d0,(a4)+

	move.w (a2)+,d0	; sprgroupframe_sizeFlags(a2),d0
	move.w d0,(a4)+
	
	move g_sprcache_sprcharoffset,d0
	add.w (a2)+,d0		;sprgroupframe_charoffset(a2)
	or.w (a2)+,d0	;sprgroupframe_paletteFlags(a2)
	move d0,(a4)+
	
    move #0,d0      ; xpos
	sub.w (a2),d0	;sprgroupframe_originx(a2)
    move.w d0,(a4)+

    move.l a4,g_sprcache_currentaddr
    rts

