
MAX_SPRITES equ 64




SPRITE_UpdateFromGOManager_AfterAllDone:

	cmp #1,d6
	bne .notzero
	move.b #0,3(a5) 
	move #350+128,6(a5)		; no sprites? not sure what you should do. Moved this one off screen
	bra .r

.notzero:
	lea -8(a5),a5				; last table entry     
    move.b #0,3(a5)  
.r:

    sub #1,d6
	move d6,g_num_sprites_active

    rts


SPRITE_InitRegistersForRender:
	lea VDPSpriteList,a5
	moveq.l #1,d6       ;sprite link index
	move.w #128,d2
	move.w #$3ff,d3
; scroll positions with 128 offset added, both in d4
	
    
    move g_scroll_x,d4
    sub #128,d4
    add g_screenshake_x,d4

    move g_scroll_y,d5
    sub #128,d5
    add g_screenshake_y,d5

    rts
    
SPRITE_SortTest1:
    jsr GOManager_GetList_Car
    move.l golist_objects_addr(a3),a4
    move.l m_hol_sortlist,a1
    move   golist_total(a3),d7
    subq #1,d7
.lp:
    move.l a4,(a1)+
    lea go_structsize(a4),a4
    dbra d7,.lp
    rts
    
; making assumptions:
; never 0-2 entries
; always even number of entries
; sorts half the list every other frame
SPRITE_SortNormalList:
    ;bra SPRITE_SortNormalList_OnePass
    jsr GOManager_GetList_Car
    move.l m_hol_sortlist,a4
    move   golist_total(a3),d7
    lsr #1,d7
    
    move g_timer1,d0
    and #1,d0
    beq .firsthalf
.secondhalf:
    move d7,d0
    add d0,d0
    add d0,d0
    add d0,a4
    bra .doit
    
.firsthalf:

.doit:
    subq #1,d7      ; -1 for dbra, and -1 more for pre-fetching first pointer.
    
    move.l (a4)+,a0
    move go_y(a0),d0
.objectloop:
    move.l (a4)+,a1
    move go_y(a1),d1

    cmp d1,d0
    blt .swap           ; branch on swap, as no-branch is fewer cycles.
    
.noswap:                ; move the 'current' pointer to the 'previous' pointer, and same with the y pos, so we don't need to fetch em again
    move.l a1,a0
    move.w d1,d0
    dbra d7,.objectloop
    rts
    
.swap:                  ; if swapped, we don't need to exchange current pointers, or positions, as they're already swapped, I think
    move.l a1,-8(a4)
    move.l a0,-4(a4)
    dbra d7,.objectloop
.exit:
    rts
    

SPRITE_SortNormalList_OnePass:
    jsr GOManager_GetList_Car
    move.l m_hol_sortlist,a4
    move   golist_total(a3),d7
    
    cmp #1,d7
    ble .exit       ; minimum 2
    subq #2,d7      ; -1 for dbra, and -1 more for pre-fetching first pointer.
    move #0,d5
    
    ; 56-62 cycles per loop with no swap, 80-86 if swapped.
    
    move.l (a4)+,a0
    move go_y(a0),d0
.objectloop:
    move.l (a4)+,a1
    move go_y(a1),d1
    cmp d1,d0
    blt .swap           ; branch on swap, as no-branch is fewer cycles.
.noswap:                ; move the 'current' pointer to the 'previous' pointer, and same with the y pos, so we don't need to fetch em again
    move.l a1,a0
    move.w d1,d0
    dbra d7,.objectloop
    rts
.swap:                  ; if swapped, we don't need to exchange current pointers, or positions, as they're already swapped, I think
    move.l a1,-8(a4)
    move.l a0,-4(a4)
    dbra d7,.objectloop
.exit:
    rts
     

SPRITE_SortNormalList_Simple:
    jsr GOManager_GetList_Car
    move.l m_hol_sortlist,a4
    move   golist_total(a3),d7
    
    cmp #1,d7
    ble .exit       ; minimum 2
    subq #1,d7
    
 ; 80 cycles per loop with no swap, 108-114 cycles per loop with swap
    
.lp:
    move.l (a4),a0                  ; first obj pointer
    move.l 4(a4),a1                 ; second obj pointer                     
    move go_y(a0),d0                
    cmp go_y(a1),d0                 ; compare y pos
    bge .next
    move.l a1,(a4)                  ; if swapped, swap the pointers around
    move.l a0,4(a4)
.next:
    lea 4(a4),a4                    ; next pointer in list                    
    dbra d7,.lp
    
.exit:
    rts
    

SPRITE_UpdateFromGOManager_UIScreen:
	bsr SPRITE_InitRegistersForRender
	
    jsr GOManager_GetList_UIScreen
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne
    bra SPRITE_UpdateFromGOManager_AfterAllDone
    

SPRITE_UpdateFromGOManager_Racing:
    
    move g_timer1,d0
    and #1,d0
    beq .nocol
	tst.b sysg_debug_showcollision
	beq .nocol
	
	cmp.b #1,sysg_debug_showcollision
	bne .nocol1
	bra SPRITE_RenderCollision
.nocol1:
	cmp.b #2,sysg_debug_showcollision
	bne .nocol2
	bra SPRITE_RenderOrigin
.nocol2:
    
		
.nocol:
	bsr SPRITE_InitRegistersForRender


.start:
    

    btst.b #0,sysg_debug_spritegroupmask+1
    bne .no1
    jsr GOManager_GetList_FX
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne
.no1:
    
    cmp #MAX_SPRITES,d6
    bge .rts

    btst.b #1,sysg_debug_spritegroupmask+1
    bne .no2
    jsr GOManager_GetList_Car
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne
.no2:

    cmp #MAX_SPRITES,d6
    bge .rts

    jsr GOManager_GetList_PlayerBullets
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne

    cmp #MAX_SPRITES,d6
    bge .rts
    
    jsr GOManager_GetList_EnemyBullet
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne

    cmp #MAX_SPRITES,d6
    bge .rts
      
    btst.b #2,sysg_debug_spritegroupmask+1
    bne .no3
    jsr GOManager_GetList_Treasure
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne
.no3
    
.rts
    bsr SPRITE_UpdateFromGOManager_AfterAllDone

    rts

SPRITE_UpdateFromGOManager_Hol_Inner_DoOne:

	tst d7
	beq .rts
	subq #1,d7

.loop:
    move.l (a4)+,a0
    
    tst.b go_activestate(a0)
    beq .skip

	move.l go_flags(a0),d0
	btst #GOFLAG_INVISIBLE,d0
	bne .skip
	
	move.l go_compoundSprAddr(a0),d0
	bne .is_compound
	
	ifnd IS_GAME_COFFEE     ; no clip needed for coffee
	
	move go_x(a0),d0
	sub g_scroll_x,d0
	cmp #-32,d0
	blt .skip
	cmp #320+32,d0
	bgt .skip

	move go_y(a0),d0
	sub g_scroll_y,d0
	cmp #-32,d0
	blt .skip
	cmp #224+32,d0
	bgt .skip
	
	endif


	move.l go_onRender(a0),d0
	beq .noc
	move.l d0,a1
	movem.l d0-d7/a0-a5,-(sp)
	jsr (a1)
	movem.l (sp)+,d0-d7/a0-a5

	bsr AddSprgroupSprites


	bra .skip
.noc:
    bra .no

.is_compound:

; clip compound sprite with extra info for full size of compound sprite
    ;move go_x(a0),d0
	;sub g_scroll_x,d0
	;move d0,d1
	;add go_compound_x0(a0),d0
	;add go_compound_x1(a0),d1
	;cmp #0,d1
	;blt .skip
	;cmp #256,d0
	;bgt .skip

    ;move go_y(a0),d0
	;sub g_scroll_y,d0
	;move d0,d1
	;add go_compound_y0(a0),d0
	;add go_compound_y1(a0),d1
	;cmp #0,d1
	;blt .skip
	;cmp #256,d0
	;bgt .skip


	move.l go_compoundSprAddr(a0),d0
	beq .no
	movem.l d2-d3,-(sp)
	bsr SPRITE_UpdateCompoundSprite
	movem.l (sp)+,d2-d3

	bra .skip
.no:


	;move.l go_onBeforeMainRender(a0),d0
	;beq .nod1	
	;move.l d0,a1
	;movem.l d0-d7/a0-a5,-(sp)
	;jsr (a1)
	;movem.l (sp)+,d0-d7/a0-a5
	;bsr AddSprgroupSprites
;.nod1:

    ;d5

    move.l go_cached_frame_addr(a0),d0
    beq .not_cached
    
    move.l d0,a2
    
    move.l (a2)+,(a5)
    move.l (a2)+,4(a5)
    
    move.w go_y(a0),d0
    sub d5,d0
    add d0,(a5)
    
    move.b d6,3(a5)
    
    move.w go_x(a0),d0
    sub d4,d0
    add d0,6(a5)
    
    move.w go_sprAttributes(a0),d0
    or.w d0,4(a5)

    addq #1,d6
    lea 8(a5),a5

    bra .skip
.not_cached:
	;UPDATESPR_GETGROUP
    move.l go_sprgroup(a0),a2
    lea sprgroup_firstFrame(a2),a2
    move.w go_frame(a0),d0                  ; frame
    lsl #sprgroupframe_sizeshift,d0	
    add d0,a2	

	
;UPDATESPR_1a go_y(a0)
	move.w go_y(a0),d0
	sub d5,d0
	sub.w (a2)+,d0	; sprgroupframe_originy(a2¬
	swap d0

    move.w d6,d0                ; link  
	or.w (a2)+,d0	; sprgroupframe_sizeFlags(a2),d0
	move.l d0,(a5)+

	move go_vdpbase(a0),d0

	add.w (a2)+,d0		;sprgroupframe_charoffset(a2)
    ;and.w #$7ff,d0
	or.w (a2)+,d0	;sprgroupframe_paletteFlags(a2)
	or.w go_sprAttributes(a0),d0
	
	swap d0

    move.w go_x(a0),d0
	sub d4,d0
	sub.w (a2),d0	;sprgroupframe_originx(a2)
    move.l d0,(a5)+

	addq #1,d6

    
;    move.l go_onAfterMainRender(a0),d0
;    beq .nod2
;    move.l d0,a1
;    movem.l d0-d7/a0-a5,-(sp)
;    jsr (a1)
;    movem.l (sp)+,d0-d7/a0-a5
;    bsr AddSprgroupSprites
;.nod2:

    cmp #MAX_SPRITES,d6
    bge .rts
    
.skip:
    dbra d7,.loop
    
.rts
    rts


Sprite_HOL_Sort_UIScreen:
    rts
    
Sprite_HOL_Sort_NormalList:
    jsr GOManager_GetList_Car
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    beq .skip2
    subq #1,d7
    
.loop:
    move.l (a4)+,a0
    move.l go_flags(a0),d0
    btst #GOFLAG_INVISIBLE,d0
    bne .skip1

    cmp.b #GOPRIORITY_0,go_priority_b(a0)
    bne .pri1
.pri0:
    move.l a0,(a1)+
    addq #1,d1
    dbra d7,.loop
    bra .skip2
.pri1:
    move.l a0,(a2)+
    addq #1,d2
.skip1:
    dbra d7,.loop
.skip2:
    rts

Sprite_HOL_Sort_Treasure:
    jsr GOManager_GetList_Treasure
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    beq .skip2
    subq #1,d7
    
.loop:
    move.l (a4)+,a0
    move.l go_flags(a0),d0
    btst #GOFLAG_INVISIBLE,d0
    bne .skip1

    cmp.b #GOPRIORITY_0,go_priority_b(a0)
    bne .pri1
.pri0:
    move.l a0,(a1)+
    addq #1,d1
    dbra d7,.loop
    bra .skip2
.pri1:
    move.l a0,(a2)+
    addq #1,d2
.skip1:
    dbra d7,.loop
.skip2:
    rts

    
Sprite_HOL_Sort_FX:
    jsr GOManager_GetList_FX
    
    bra .not_circular
    
;.type_circular:
;    move.l golist_objects_addr(a3),a0
;    move golist_total(a3),d7
;	bra .first_circular
;.loop_circular:
;    tst.b go_activestate(a0)
;    beq .next_circular
;	move.l go_flags(a0),d0
;    btst #GOFLAG_INVISIBLE,d0
;    bne .next_circular
;    move.l a0,(a2)+
;    addq #1,d2
;.next_circular:
;    lea go_structsize(a0),a0
;.first_circular:
;    dbra d7,.loop_circular
;    bra .rts
    
.not_circular:
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    beq .rts
    subq #1,d7
    
.fxloop:
    move.l (a4)+,a0
    move.l go_flags(a0),d0
    btst #GOFLAG_INVISIBLE,d0
    bne .fxskip
    move.l a0,(a2)+
    addq #1,d2
.fxskip:
    dbra d7,.fxloop
.rts:



    rts     
