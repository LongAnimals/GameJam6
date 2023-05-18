
SPRSTATE_INACTIVE equ 0
SPRSTATE_ACTIVE equ 1


SPR_1x1  equ %0000<<8  ; 1x1 tiles
SPR_2x1  equ %0100<<8  ; 2x1 tiles
SPR_3x1  equ %1000<<8  ; 3x1 tiles
SPR_4x1  equ %1100<<8  ; 4x1 tiles
SPR_1x2  equ %0001<<8  ; 1x2 tiles
SPR_2x2  equ %0101<<8  ; 2x2 tiles
SPR_3x2  equ %1001<<8  ; 3x2 tiles
SPR_4x2  equ %1101<<8  ; 4x2 tiles
SPR_1x3  equ %0010<<8  ; 1x3 tiles
SPR_2x3  equ %0110<<8  ; 2x3 tiles
SPR_3x3  equ %1010<<8  ; 3x3 tiles
SPR_4x3  equ %1110<<8  ; 4x3 tiles
SPR_1x4  equ %0011<<8  ; 1x4 tiles
SPR_2x4  equ %0111<<8  ; 2x4 tiles
SPR_3x4  equ %1011<<8  ; 3x4 tiles
SPR_4x4  equ %1111<<8  ; 4x4 tiles
PAL_0	equ $0000
PAL_1	equ $2000
PAL_2	equ $4000
PAL_3	equ $6000
PRIORITY equ $8000
NOPRIORITY equ $7fff



SPRITE_InitVdpRamSpriteList
	lea VDPSpriteList,a0
	moveq #0,d0
	move #(80)-1,d7
.loop
	move.l d0,(a0)+
	move.l d0,(a0)+
	dbra d7,.loop
	rts


UPDATESPR_GETGROUP macro    
	move.l sysg_sprites_baseaddr2,a2    ;lea sprdefs+2,a2
	move go_sprtype(a0),d0
	lsl #2,d0
	add d0,a2
	move.l (a2),a2
	;move.l go_sprgroup(a0),a2
	add.l #sprgroup_firstFrame,a2
    move.w go_frame(a0),d0                  ; frame
	lsl #sprgroupframe_sizeshift,d0	; couple of scans extra for mult
	add d0,a2	
	endm



; a0 is obj
; a5 is spr list to fill in
; d6 sprite link index
; Compound sprites don't use the original sprite's origin point
SPRITE_UpdateCompoundSprite:
    move.l d7,-(sp)
    move.l a4,-(sp)

;d5
	bsr GOTOOLS_GetCompSprFrameAddr

	move.l compoundspr_noflipaddr(a1),a3
	move.w compoundsprframe_numhwsprites(a3),d7	; num hw frames
	sub.w #1,d7
	lea compoundsprframe_firsthwspr(a3),a3
	
	lea SpriteVDPOffsets,a4
	move.l sysg_sprites_baseaddr,a1    ;lea sprdefs,a1
	
	move #FLIP_NOT_HV,d3
.loop:

	; go_sprgroup(a0) not used for compound spites, instead compoundsprframespr_sprindex is used to point to the from the start of the table (sprdefs)
	move compoundsprframespr_sprindex(a3),d0
	add d0,d0
	move d0,d1          ; save
	add d0,d0 
	move.l 2(a1,d0),a2
	
	lea sprgroup_firstFrame(a2),a2

   	move.w compoundsprframespr_sproffset(a3),d0		; frame index in to sprite
	lsl #sprgroupframe_sizeshift,d0
	add d0,a2	

	move go_y(a0),d0
	sub d5,d0
	add.w compoundsprframespr_yoff(a3),d0
	move.w d0,(a5)+

	;moveq #0,d0
    move.w d6,d0                ; link  
	or.w sprgroupframe_sizeFlags(a2),d0
    move.w d0,(a5)+

	move.w (a4,d1),d0       ; d3 is compoundsprframespr_sprindex * 2

	add.w sprgroupframe_charoffset(a2),d0
	or.w sprgroupframe_paletteFlags(a2),d0	
	or.w compoundsprframespr_flips(a3),d0

	move go_sprAttributes(a0),d1
	and d3,d1   ;#FLIP_NOT_HV,d1				; Flips flags are used to tell us to use the flipped version of the anim, so don't want to use the original flip flags as well
	or.w d1,d0
	move.w d0,(a5)+

	move go_x(a0),d0
	sub d4,d0
	add.w compoundsprframespr_xoff(a3),d0
	
	move.w d0,(a5)+

	addq #1,d6

.continue:
	lea compoundsprframespr_size(a3),a3
	dbra d7,.loop
	
    move.l (sp)+,a4
    move.l (sp)+,d7
	rts
	
.clipx:
    lea -6(a5),a5
    bra .continue
    
	

SPRITE_RenderOrigin:

	lea VDPSpriteList,a5

    moveq.l #1,d6       ;sprite link index

    jsr GOManager_GetList_Car
    move.l golist_objects_addr(a3),a0
    bsr .doone
    jsr GOManager_GetList_Treasure
    move.l golist_objects_addr(a3),a0
    bsr .doone
    bra .done
    
.doone:
    move golist_total(a3),d7
    subq #1,d7
.loop:
	cmp.b #SPRSTATE_ACTIVE,go_activestate(a0)
    bne .skip
    
	move.w g_scroll_x,d0
	cmp go_x(a0),d0
	bgt .skip
	add #SCR_W_PIXELS,d0
	cmp go_x(a0),d0
	blt .skip

	move.w g_scroll_y,d0
	cmp go_y(a0),d0
	bgt .skip
	add #SCR_H_PIXELS,d0
	cmp go_y(a0),d0
	blt .skip	

.innerloop:


	move.w go_y(a0),d0 
	sub.w g_scroll_y,d0
    add #128,d0
    sub #4,d0
    move d0,(a5)+   

    move.w d6,d0                ; link  
	or.w #SPR_1x1,d0
	move.w d0,(a5)+

	lea SpriteVDPOffsets+(SPRITE_DEBUG*2),a2
	move.w (a2),d0
	add #1,d0
	or.w #PRIORITY,d0
	or.w #PAL_1,d0
	move d0,(a5)+
	
    move.w go_x(a0),d0
    sub.w g_scroll_x,d0
	add #128,d0
	sub #4,d0
    move.w d0,(a5)+

	addq #1,d6

    
.skip:
    lea go_structsize(a0),a0
    dbra d7,.loop
    rts
    
.done:
	cmp #1,d6
	bne .notzero
	move.b #0,3(a5) 
	move #350+128,6(a5)		; no sprites? not sure what you should do. Moved this one off screen
	rts
.notzero:
	lea -8(a5),a5				; last table entry     
    move.b #0,3(a5)  
    rts


SPRITE_RenderCollision:
	lea VDPSpriteList,a5
    jsr GOManager_GetList_EnemyBullet
    move.l golist_objects_addr(a3),a0
    move golist_total(a3),d7
    subq #1,d7
    moveq.l #1,d6       ;sprite link index
.loop:
	cmp.b #SPRSTATE_ACTIVE,go_activestate(a0)
    bne .skip
    
	cmp.b #COLTYPE_NONE,go_coltype(a0)
	beq .skip
	move.l go_colliderAddr(a0),d0
	beq .skip
	
	move.l d0,a4
	move.l go_getCustomCollisionFunc(a0),d0
	bne .skip

	move.w g_scroll_x,d0
	cmp go_x(a0),d0
	bgt .skip
	add #SCR_W_PIXELS,d0
	cmp go_x(a0),d0
	blt .skip

	move.w g_scroll_y,d0
	cmp go_y(a0),d0
	bgt .skip
	add #SCR_H_PIXELS,d0
	cmp go_y(a0),d0
	blt .skip	

	move.l d7,-(sp)

	move.w (a4)+,d7	; num.. assume just 1 for now
	bra .loopfirsttime
.innerloop:


	move.w go_y(a0),d0 
	sub.w g_scroll_y,d0
	add.w collider_offset_y0(a4),d0
    add #128,d0
    move d0,(a5)+   

    move.w d6,d0                ; link  
	or.w #SPR_1x1,d0
	move.w d0,(a5)+

	lea SpriteVDPOffsets+(SPRITE_DEBUG*2),a2
	move.w (a2),d0
	or.w #PRIORITY,d0
	or.w #PAL_1,d0
	move d0,(a5)+
	
    move.w go_x(a0),d0
    sub.w g_scroll_x,d0
	add.w collider_offset_x0(a4),d0
	add #128,d0
    move.w d0,(a5)+

	addq #1,d6


	move.w go_y(a0),d0 
	sub.w g_scroll_y,d0
	add.w collider_offset_y1(a4),d0
    add #128,d0
    sub #8,d0
    move d0,(a5)+   

    move.w d6,d0                ; link  
	or.w #SPR_1x1,d0
	move.w d0,(a5)+

	lea SpriteVDPOffsets+(SPRITE_DEBUG*2),a2
	move.w (a2),d0
	or.w #PRIORITY,d0
	or.w #PAL_1,d0
	or.w #FLIP_V,d0
	or.w #FLIP_H,d0
	move d0,(a5)+
	
    move.w go_x(a0),d0
    sub.w g_scroll_x,d0
	add.w collider_offset_x1(a4),d0
	add #128,d0
	sub #8,d0
    move.w d0,(a5)+

	addq #1,d6

	lea collider_size(a4),a4
.loopfirsttime:
	dbra d7,.innerloop
	move.l (sp)+,d7
    
.skip:
    lea go_structsize(a0),a0
    dbra d7,.loop
	cmp #1,d6
	bne .notzero
	move.b #0,3(a5) 
	move #350+128,6(a5)		; no sprites? not sure what you should do. Moved this one off screen
	rts
.notzero:
	lea -8(a5),a5				; last table entry     
    move.b #0,3(a5)  
    rts

SPRITE_CLIPDIST equ 64

GameObjectSortList equ 0

; DO NOT USE
SPRITE_SortPriority:
	;move.l m_GameObjects,a0     ;lea GameObjects,a0
	lea GameObjectSortList+(MAX_GAMEOBJECTS*4*0),a1
	lea GameObjectSortList+(MAX_GAMEOBJECTS*4*1),a2
	lea GameObjectSortList+(MAX_GAMEOBJECTS*4*2),a3
	lea GameObjectSortList+(MAX_GAMEOBJECTS*4*3),a4

	move #0,d1
	move #0,d2
	move #0,d3
	move #0,d4

	move.w g_scroll_x,d5
	sub #SPRITE_CLIPDIST,d5

	move.w g_scroll_y,d6
	sub #SPRITE_CLIPDIST,d6


	move.l #MAX_GAMEOBJECTS-1,d7
.lp:
	cmp.b #SPRSTATE_ACTIVE,go_activestate(a0)
    bne .skip

	move.l go_flags(a0),d0
	btst #GOFLAG_INVISIBLE,d0
	bne .skip

	btst #GOFLAG_NOCULL,d0
	bne .nocull

	cmp go_x(a0),d5
	bgt .skip
	move d5,d0
	add #SCR_W_PIXELS+SPRITE_CLIPDIST+SPRITE_CLIPDIST,d0
	cmp go_x(a0),d0
	blt .skip
	
	move go_x(a0),d0
	sub g_scroll_x,d0
	cmp #511-128,d0		; AHA! 512 = 0, which then culls off a whole line
	bgt .skip
	cmp #0-128,d0
	blt .skip

	cmp go_y(a0),d6
	bgt .skip
	move d6,d0
	add #SCR_H_PIXELS+SPRITE_CLIPDIST+SPRITE_CLIPDIST,d0
	cmp go_y(a0),d0
	blt .skip

.nocull:

; pc relative jump table version:
;	move.b go_priority_b(a0),d0
;	add d0,d0
;	move .jumps(pc,d0),d0
;	jmp .jumps(pc,d0)
;.jumps:
;	dc.w .pri0-.jumps
;	dc.w .pri1-.jumps
;	dc.w .pri2-.jumps
;	dc.w .pri3-.jumps

; test specifically version: will be quicker if most priorities are low
	move.b go_priority_b(a0),d0
	;tst d0
	beq .pri0
	cmp.b #1,d0
	beq .pri1
	cmp.b #2,d0
	beq .pri2
	cmp.b #3,d0
	beq .pri3

		; shouldnt get here
	bra .skip

.pri0: move.l a0,(a1)+
	addq #1,d1
	lea go_structsize(a0),a0
	dbra d7,.lp
	bra .skip1
.pri1: move.l a0,(a2)+
	addq #1,d2
	lea go_structsize(a0),a0
	dbra d7,.lp
	bra .skip1
.pri2: move.l a0,(a3)+
	addq #1,d3
	lea go_structsize(a0),a0
	dbra d7,.lp
	bra .skip1
.pri3: move.l a0,(a4)+
	addq #1,d4
	lea go_structsize(a0),a0

	dbra d7,.lp
	bra .skip1

.skip:
	lea go_structsize(a0),a0
	dbra d7,.lp

.skip1

	;move d1,g_numsortedgos
	;move d2,g_numsortedgos1
	;move d3,g_numsortedgos2
	;move d4,g_numsortedgos3

	rts

SPRITE_UpdateFromGOs_3D:
	rts







AddSprgroupSprites:
	movem.l d7/a0,-(sp)
	lea Scratchpad,a0
	move (a0)+,d7
	bra .next	;subq #1,d7
.lp:

;	UPDATESPR_GETGROUP
	
	move.l sprbuf_sprgroup(a0),a2
	add.l #sprgroup_firstFrame,a2
    move.w sprbuf_frame(a0),d0                  ; frame
	lsl #sprgroupframe_sizeshift,d0	; couple of scans extra for mult
	add d0,a2	

;UPDATESPR_1a go_y(a0)
	move.w sprbuf_y(a0),d0 
	sub d5,d0
	sub.w (a2)+,d0
	swap d0

;UPDATESPR_2
    move.w d6,d0                ; link  
	or.w (a2)+,d0
	move.l d0,(a5)+

	move.w sprbuf_vdpbase(a0),d0

	add.w (a2)+,d0		;sprgroupframe_charoffset(a2)    
    and.w #$7ff,d0
	or.w (a2)+,d0	;sprgroupframe_paletteFlags(a2)
	or.w sprbuf_flags(a0),d0
	swap d0

;   UPDATESPR_4a go_x(a0)
    move.w sprbuf_x(a0),d0
	sub d4,d0
	sub.w (a2),d0	;sprgroupframe_originx(a2)
   ; and.w d3,d0	;#$1ff,d0
    move.l d0,(a5)+

;	UPDATESPR_5
	addq #1,d6

	lea sprbuf_size(a0),a0

.next:
	dbra d7,.lp
	movem.l (sp)+,d7/a0
	rts




SPRITE_SetBlankSpriteList:
	move.l #VDP_VRAM_WRITE_SPRITE,VDP_CONTROL    
	move.l #0,VDP_DATA
	move.l #0,VDP_DATA
	rts


;REG_DMALEN_LO :
;

; start DMA:
;A15-A0: VRAM/CRAM/VSRAM address.
;CD0: 1 = write; 0 = read.
;CD3-CD1: 000 = VRAM; 100 = CRAM (read); 001 = CRAM (write); 010 = VSRAM; 110 = VRAM (byte read)
;CD4: 1 = VRAM to VRAM copy.
;CD5: 1 = DMA. Used to automate data transfer without the need for the data port.

;dma
SPRITE_CopySpriteListToVRAM_DMA:
	move.l #VDPSpriteList,d0
	move.l #VDPADDR_SPRITE_ATTR,d1
	move.l #MAX_SPRITES*8,d2
	move #2,d3
	jsr VDP_SetDMA
	rts


SPRITE_CopySpriteListToVRAM_DMA_JustActiveSprites:

	move.l #VDPSpriteList,d0
	move.l #VDPADDR_SPRITE_ATTR,d1



	moveq #0,d2
	move g_num_sprites_active,d2

; WARNING, THIS IS INCORRECT - Number will be off by one 
	
	addq #1,d2
	cmp #80,d2
	ble .max
	move #80,d2
.max:
	lsl.l #3,d2

	move #2,d3
	jsr VDP_SetDMA
	rts



SPRITE_CopySpriteListToVRAM:
	move.l #VDP_VRAM_WRITE_SPRITE,VDP_CONTROL    
	lea VDPSpriteList,a0
	lea VDP_DATA,a1
	move #80-1,d7
.loop
	move.l (a0)+,(a1)
	move.l (a0)+,(a1)
	dbra d7,.loop
	rts


; d0 = x, d1 = y
; uses d2
SPRITE_Sprbuf_ClipSingle:

	move.w g_scroll_x,d2
	sub #SPRITE_CLIPDIST,d2

	cmp d0,d2
	bge .clip
	add #SCR_W_PIXELS+SPRITE_CLIPDIST+SPRITE_CLIPDIST,d2
	cmp d0,d2
	ble .clip


	move.w g_scroll_y,d2
	sub #SPRITE_CLIPDIST,d2

	cmp d1,d2
	bge .clip
	add #SCR_H_PIXELS+SPRITE_CLIPDIST+SPRITE_CLIPDIST,d2
	cmp d1,d2
	ble .clip



	moveq #0,d0
	rts

.clip:
	moveq #1,d0
	rts



