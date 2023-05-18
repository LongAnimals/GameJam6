

MOVE_Y_WITH_GRAVITY macro
	add.l #GRAVITY,go_dy(a0)
	move.l go_dy(a0),d0
	add.l d0,go_y(a0)
	endm

MOVE_XY_WITH_GRAVITY macro
	add.l #GRAVITY,go_dy(a0)
	move.l go_dy(a0),d0
	add.l d0,go_y(a0)
	move.l go_dx(a0),d0
	add.l d0,go_x(a0)
	endm

MOVE_XY macro
	move.l go_dy(a0),d0
	add.l d0,go_y(a0)
	move.l go_dx(a0),d0
	add.l d0,go_x(a0)
	endm

; shift right by \1, and AND with \2
GLOBAL_ANIMFRAME macro \1 \2
	move g_timer1,d0
	lsr #\1,d0
	and #\2,d0
	move d0,go_frame(a0)
	endm

SET_COMPSPR_COLLIDER macro \1
	lea \1,a1
	lea compoundspr_firstframeaddr(a1),a1
	move go_sprAttributes(a0),d0
	and #FLIP_H,d0
	bne .xflip
	move.l compoundspr_collisionaddr(a1),go_collideraddr(a0)
	bra .exit
.xflip:
	move.l compoundspr_collisionaddr_hflip(a1),go_collideraddr(a0)
.exit:
	endm

SPAWN_GO macro \1
	move #\1,d0
	jsr SPAWN_AddDataTableGameObjectFromUpdate
	move.l go_x(a0),go_x(a1)
	move.l go_y(a0),go_y(a1)
	endm

SPAWN_GO_NOPOSOVERRIDE macro \1
	move #\1,d0
	jsr SPAWN_AddDataTableGameObjectFromUpdate
	endm


SET_DEATHCOLLISION macro \1
	move.b #COLTYPE_HITPLAYER_POINT,go_coltype(a0)
	;move.l #EnemyHitPlayerCB,go_collidedfunc(a0)
	move.l #\1,go_collideraddr(a0)
	endm

SET_CALLBACK_COLLISION macro \1 \2
	move.b #COLTYPE_HITPLAYER_POINT,go_coltype(a0)
	move.l #\2,go_collidedfunc(a0)
	move.l #\1,go_collideraddr(a0)
	endm


SET_COLLISIONFUNC macro \1 \2
	move.b #COLTYPE_HITPLAYER_POINT,go_coltype(a0)
	move.l #COLLIDER_frog,go_collideraddr(a0)	; tells it there's a collision, for now
	move.l #\2,go_collidedfunc(a0)
	move.l #\1,go_collisionfunc(a0)
	endm

SET_GO_PRIORITY macro \1
	move.b #\1,go_priority_b(a0)
	endm

SETCOMPSPR macro \1
    lea compoundsprites+compoundsprs_firstspriteaddr+(\1*4) ,a1
    ;lea BoneCompSprs+compoundsprs_firstspriteaddr+(\1*4) ,a1
    move.l (a1),go_compoundSprAddr(a0)
    endm


PUSHSPR macro
    move go_sprtype(a0),-(sp)
    move.l go_sprgroup(a0),-(sp)
    move go_vdpbase(a0),-(sp)
    endm

POPSPR macro
    move (sp)+,go_vdpbase(a0)
    move.l (sp)+,go_sprgroup(a0)
    move (sp)+,go_sprtype(a0)
    endm

    
SETSPR macro \1
	move.l a1,-(sp)
	move.w #\1,go_sprtype(a0)
	move.l sysg_sprites_baseaddr2,a1
	add.l #\1*4,a1
	move.l (a1),go_sprgroup(a0)       ;	move.l (sprdefs+2+(\1*4)),go_sprgroup(a0)
	
	lea SpriteVDPOffsets,a1
	move #\1,d0
	add d0,d0
	move.w (a1,d0),go_vdpbase(a0)
	move.l (sp)+,a1
	endm

SETSPR_AND_FRAME macro \1,\2
	move.l a1,-(sp)
	move.w #\1,go_sprtype(a0)
	move.l sysg_sprites_baseaddr2,a1
	add.l #\1*4,a1
	move.l (a1),go_sprgroup(a0)       ;	move.l (sprdefs+2+(\1*4)),go_sprgroup(a0)
	
	lea SpriteVDPOffsets,a1
	move #\1,d0
	add d0,d0
	move.w (a1,d0),go_vdpbase(a0)
	move.l (sp)+,a1
	
	move #\2,go_frame(a0)
	endm


; in d0 and d1
; go_sprgroup in d0 and go_vdpbase in d1
GETSPRRENDERVALUES macro \1
   move.l a1,-(sp)
	move.w #\1,go_sprtype(a0)
	move.l sysg_sprites_baseaddr2,a1
    add.l #\1*4,a1                  
    move.l (a1),d0      ;move.l (sprdefs+2+(\1*4)),d0
	lea SpriteVDPOffsets,a1
	move #\1,d1
	add d1,d1
	move.w (a1,d1),d1
	move.l (sp)+,a1
	endm
	

SETSPRANDCOLLIDER macro \1
	move.l a1,-(sp)
	move.w #\1,go_sprtype(a0)
	move.l sysg_sprites_baseaddr2,a1
	add.l #\1*4,a1                 
	move.l (a1),go_sprgroup(a0)  ;move.l (sprdefs+2+(\1*4)),go_sprgroup(a0)
	lea SpriteVDPOffsets,a1
	move #\1,d0
	add d0,d0
	move.w (a1,d0),go_vdpbase(a0)
	lea colliders+2,a1
	add d0,d0
	move.l (a1,d0),go_collideraddr(a0)
	move.l (sp)+,a1
	endm
	

SETSPR_A1 macro \1
    move.l a2,-(sp)
	move.w #\1,go_sprtype(a1)
	move.l sysg_sprites_baseaddr2,a2
    add.l #\1*4,a2
    move.l (a2),go_sprgroup(a1)   ;move.l (sprdefs+2+(\1*4)),go_sprgroup(a1)
	lea SpriteVDPOffsets,a2
	move #\1,d0
	add d0,d0
	move.w (a2,d0),go_vdpbase(a1)
	move.l (sp)+,a2
	endm


GO_SET_VISIBLE macro	
	bclr #GOFLAG_INVISIBLE,go_flags+3(a0)
	endm

GO_EXCHANGE_VISIBLE macro	
	bchg #GOFLAG_INVISIBLE,go_flags+3(a0)
	endm

GO_SET_INVISIBLE macro	
	bset #GOFLAG_INVISIBLE,go_flags+3(a0)
	endm

GO_SET_VISIBLE_A1 macro	
	bclr #GOFLAG_INVISIBLE,go_flags+3(a1)
	endm

GO_SET_INVISIBLE_A1 macro	
	bset #GOFLAG_INVISIBLE,go_flags+3(a1)
	endm

GO_SET_VISIBLE_GTIMER macro \1
    move g_timer1,d0
    lsr #\1,d0
    and #1,d0
    bne ._setvisible_1
	bclr #GOFLAG_INVISIBLE,go_flags+3(a0)
    bra ._setvisible_2
._setvisible_1:	
	bset #GOFLAG_INVISIBLE,go_flags+3(a0)
._setvisible_2:
	endm

