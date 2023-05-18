
COLLISION_LOOP_MODE_PLAYER_VS_POINTS equ 0
COLLISION_LOOP_MODE_BULLET_VS_ENEMY equ 1
COLLISION_LOOP_MODE_BULLET_VS_GAMEOBJECT equ 2
COLLISION_LOOP_MODE_PLAYER_VS_BOX equ 3



;------------------------------------------------------------------------------------------------------------------------------------------------
; Default collider data for if something doesn't have a collider
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_DefaultColliderData:
	dc.w 1
	dc.w -4,-4,4,4


;------------------------------------------------------------------------------------------------------------------------------------------------
; Set a rectanglular area of tiles to 1
; d0 x tile d1 y tile, ; d2 width ; d3 height
; register safe
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_SetCollisionTileBlock
	PUSHALL
.yloop:
	move d2,d7
.xloop:
	bsr COLL_SetCollisionTile
	addq #1,d0
	subq #1,d7
	bgt .xloop
	sub d2,d0
	addq #1,d1
	subq #1,d3
	bgt .yloop
	POPALL
	rts

COLL_SetCollisionTileBlockClipped
	PUSHALL
.yloop:
	move d2,d7
.xloop:
	tst d0
	blt .no
	tst d1
	blt .no

	bsr COLL_SetCollisionTile
.no:
	addq #1,d0
	subq #1,d7
	bgt .xloop
	sub d2,d0
	addq #1,d1
	subq #1,d3
	bgt .yloop
	POPALL
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; Set a rectanglular area of tiles to 0
; d0 x tile d1 y tile, ; d2 width ; d3 height
; register safe
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_ClearCollisionTileBlock
	PUSHALL
.yloop:
	move d2,d7
.xloop:
	bsr COLL_ClearCollisionTile
	addq #1,d0
	subq #1,d7
	bgt .xloop
	sub d2,d0
	addq #1,d1
	subq #1,d3
	bgt .yloop
	POPALL
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Set a single collision tile
; d0 x tile; d1 y tile
; register safe
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_SetCollisionTile:
	PUSHALL
	bsr COLL_GetMapCollision
	move.b (a1),d0
	bset d3,d0
	move.b d0,(a1)
	POPALL
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Clear a single collision tile
; d0 x tile; d1 y tile
; register safe
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_ClearCollisionTile:
	PUSHALL
	bsr COLL_GetMapCollision
	move.b (a1),d0
	bclr d3,d0
	move.b d0,(a1)
	POPALL
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; Collision map is copied to RAM at CollisionMap so that it can be edited at runtime.
; Collision map is assumed to be Lz4w compressed at this point
;------------------------------------------------------------------------------------------------------------------------------------------------
COLLISION_MAP_SIZE equ (128*128/8)+6
COLL_CopyCollisionToRam:
	jsr UNITYTOOL_GetLevelCollisionMap
	move.l a1,a0
	move.l a1,a2

	move.w collisionmap_w(a0),g_colmap_w
	move.w collisionmap_h(a0),g_colmap_h
	lea collisionmap_offset_table(a0),a1
	move.l a1,g_colmap_offsettable
	move.l collisionmap_dataaddr(a0),g_colmap_data

	move.l m_CollisionMap,g_colmapaddr
	move.l collisionmap_dataaddr(a0),a0

	cmp #COMPRESSION_None,collisionmap_compression_type(a2)
	beq .nocompression
	cmp #COMPRESSION_LZ4W,collisionmap_compression_type(a2)
	beq .compressed_lz4w
	rts


.compressed_lz4w:
	move.l m_CollisionMap,a1    ;lea CollisionMap,a1
	jsr COMPRESSION_LZ4W_To_Ram
	rts

.nocompression:
	move.l m_CollisionMap,a1    ;lea CollisionMap,a1
	move #COLLISION_MAP_SIZE-1,d7
.lp
	move.b (a0)+,(a1)+
	dbra d7,.lp
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; Test collision map to see if an entry is 0 or 1
; d0 is x (in chars), d1 is y (in chars)
; sets  a1 pointer to collision byte
; sets d3 bit index
;  return zero flag set or not
; not register safe
; POSSIBLE OPTIMIZATION: Store bits right to left instead of left to right. Saving the 0-7 swap
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_GetMapCollision:
	move.l g_colmapaddr,a1					; Get collision map address in a1
	move.l g_colmap_offsettable,a2			; Get y offset table in a2
	move d0,d3									; save xpos 

	lsr #3,d0									; divide by 8 to get byte offset
	add d0,a1									; add x byte offset to map address
	add d1,d1									; y pos *= 2
	add (a2,d1),a1								; add y offset from lookup table to map address
	move.b (a1),d0								; get the byte from the collision map

	and #7,d3									; d3 is the bit within the byte
	sub #7,d3									; bits are stored left to right, 
	neg d3										; so swap over 0-7 to become 7-0
	btst d3,d0									; test if that bit index is on or off
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Wrapper for GameObject hitting map at a certain position
; return zero flag set or not
; not register safe
;------------------------------------------------------------------------------------------------------------------------------------------------
COLL_HasGOHitMap:
	move go_x(a0),d0
	move go_y(a0),d1
	lsr #3,d0
	lsr #3,d1
	bsr COLL_GetMapCollision
	rts



;------------------------------------------------------------------------------------------------------------------------------------------------
; PLAYER SPECIFIC collision function. Tests all around the player
;------------------------------------------------------------------------------------------------------------------------------------------------

COLL_HORIZ_XOFF0 equ -1
COLL_HORIZ_XOFF1 equ 1
COLL_VERT_YOFF0 equ -1
COLL_VERT_YOFF1 equ -1

COLL_YOFF_ABOVE equ -2
COLL_YOFF_BELOW equ 0
COLL_XOFF_LEFT equ -2
COLL_XOFF_RIGHT equ 2



;-----------------------------------------------------------------------------------------------------
; Player vs all other objects which can touch the player and have a reaction, enemies, bullets, pickups, etc.
; Top level function
;-----------------------------------------------------------------------------------------------------
COLL_Player_VS_Points:
    move #COLLISION_LOOP_MODE_PLAYER_VS_POINTS,g_collision_loop_mode
    
	move.l g_player,a0

	move.l go_colliderAddr(a0),a1
	add.l #collidergroup_firstoffset,a1

	move go_x(a0),d0	
	move d0,d1
	add collider_offset_x0(a1),d0	; player left
	add collider_offset_x1(a1),d1	; player right
	
	move go_y(a0),d2
	move d2,d3
	add collider_offset_y0(a1),d2	; player top
	add collider_offset_y1(a1),d3	; player bottom

	;move.l m_GOPointers_HitPlayerObjects_Points,a5     ;lea GOPointers_HitPlayerObjects,a5
	;move g_spritelist_hitplayer_point_amt,d6
	;subq #1,d6
	;blt	.ret
	
    jsr GOManager_GetList_Treasure
    move.l golist_active_list_addr(a3),a5
    move   golist_num_active(a3),d6
    subq #1,d6
    blt	.ret

.bulletloop:

	move.l (a5)+,a1

    move.b go_coltype(a1),d4
	
	cmp.b #COLTYPE_HITPLAYER_POINT,d4
	bne .nocol	

	move go_x(a1),d4
	cmp d0,d4
	blt .nocol
	cmp d1,d4
	bgt .nocol

	move go_y(a1),d4
	cmp d2,d4
	blt .nocol
	cmp d3,d4
	bgt .nocol

.collided:

	PUSHALL
	move.l go_onCollided(a0),d0
	beq .nocolfunc1
	move.l d0,a5
	jsr (a5)
.nocolfunc1:
	POPALL

	PUSHALL
	move.l go_onCollided(a1),d0
	beq .nocolfunc2
	move.l a1,a0
	move.l d0,a5
	jsr (a5)
.nocolfunc2:
	POPALL

.nocol:
	dbra d6,.bulletloop
.ret:
	rts

;-----------------------------------------------------------------------------------------------------
; Top level function
;-----------------------------------------------------------------------------------------------------

COLL_BULLET_RADIUS equ 6

COLL_Bullet_Vs_Enemy:
    move #COLLISION_LOOP_MODE_BULLET_VS_ENEMY,g_collision_loop_mode
;	move.l m_GOPointers_EnemyObjects,a4     ;lea GOPointers_EnemyObjects,a4
;	move g_spritelist_hitbyplayerbullet_amt,d7
;	subq #1,d7
;	blt	.ret
	
    jsr GOManager_GetList_Car
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    subq #1,d7
    blt	.ret
	

.enemyloop:
	move.l (a4)+,a0
	
	move.b go_coltype(a0),d0
	
	cmp.b #COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_BOX,d0
	beq .doenemy
	cmp.b #COLTYPE_HITBYPLAYERBULLET,d0
	beq .doenemy
	cmp.b #COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_POINT,d0
	beq .doenemy
	bra .skipenemy

.doenemy:	
	move.l go_colliderAddr(a0),a1
	add.l #collidergroup_firstoffset,a1

	move go_x(a0),d0	
	move d0,d1
	add collider_offset_x0(a1),d0	;  left
	add collider_offset_x1(a1),d1	;  right
	
	move go_y(a0),d2
	move d2,d3
	add collider_offset_y0(a1),d2	;  top
	add collider_offset_y1(a1),d3	;  bottom


	;move.l m_GOPointers_BulletObjects,a5    ;lea GOPointers_BulletObjects,a5
	;move g_spritelist_bullet_amt,d6
	;subq #1,d6
	;blt	.ret
	
	;a3

    jsr GOManager_GetList_PlayerBullets
    move.l golist_active_list_addr(a3),a5
    move   golist_num_active(a3),d6
    subq #1,d6
    blt	.ret
.bulletloop:

	move.l (a5)+,a1
	
	tst.b go_activestate(a1)
	beq .skipbullet

	move go_x(a1),d4
	add #COLL_BULLET_RADIUS,d4
	cmp d0,d4
	blt .nocol
	sub #COLL_BULLET_RADIUS*2,d4
	cmp d1,d4
	bgt .nocol

	move go_y(a1),d4
	add #COLL_BULLET_RADIUS,d4
	cmp d2,d4
	blt .nocol
	sub #COLL_BULLET_RADIUS*2,d4
	cmp d3,d4
	bgt .nocol

.collided:

; enemy callback
	PUSHALL
	move.l go_onCollided(a0),d0
	beq .nocolfunc1
	move.l d0,a5
	jsr (a5)
.nocolfunc1:
	POPALL

; bullet callback
	PUSHALL
	move.l go_onCollided(a1),d0
	beq .nocolfunc2
	move.l a1,a0
	move.l d0,a5
	jsr (a5)
.nocolfunc2:
	POPALL


.skipbullet:
.nocol:
	dbra d6,.bulletloop
.skipenemy:
	dbra d7,.enemyloop
.ret:
	rts

;-----------------------------------------------------------------------------------------------------

; a0 is GameObject
; a2 is list of pointers to colliders, ending with -1
;  if entry is zero, skip it (but increment index) 
; called from GameObject update
; go_collidedindex is set on GameObject when there is a callback
COLL_Bullet_Vs_GameObject_CollisionList:
    move #COLLISION_LOOP_MODE_BULLET_VS_GAMEOBJECT,g_collision_loop_mode
    move #0,go_collidedindex(a0)
.colliderloop:
	move.l (a2)+,d0
	bmi .ret
	beq .skipcollider
	move.l d0,a1
	
	add.l #collidergroup_firstoffset,a1

	move go_x(a0),d0	
	move d0,d1
	add collider_offset_x0(a1),d0	;  left
	add collider_offset_x1(a1),d1	;  right
	
	move go_y(a0),d2
	move d2,d3
	add collider_offset_y0(a1),d2	;  top
	add collider_offset_y1(a1),d3	;  bottom


	move.l m_GOPointers_BulletObjects,a5    ;lea GOPointers_BulletObjects,a5
	move g_spritelist_bullet_amt,d6
	subq #1,d6
	blt	.ret

.bulletloop:

	move.l (a5)+,a1
	
	tst.b go_activestate(a1)
	beq .skipbullet

	move go_x(a1),d4
	add #COLL_BULLET_RADIUS,d4
	cmp d0,d4
	blt .nocol
	sub #COLL_BULLET_RADIUS*2,d4
	cmp d1,d4
	bgt .nocol

	move go_y(a1),d4
	add #COLL_BULLET_RADIUS,d4
	cmp d2,d4
	blt .nocol
	sub #COLL_BULLET_RADIUS*2,d4
	cmp d3,d4
	bgt .nocol

.collided:

; enemy callback
	PUSHALL
	move.l go_onCollided(a0),d0
	beq .nocolfunc1
	move.l d0,a5
	jsr (a5)
.nocolfunc1:
	POPALL

; bullet callback
	PUSHALL
	move.l go_onCollided(a1),d0
	beq .nocolfunc2
	move.l a1,a0
	move.l d0,a5
	jsr (a5)
.nocolfunc2:
	POPALL


.skipbullet:
.nocol:
	dbra d6,.bulletloop

.skipcollider:
    add #1,go_collidedindex(a0)
    bra .colliderloop
.ret:
	rts

;-----------------------------------------------------------------------------------------------------

; bullets are normal. collision list is offset from scroll x,y
; a0 is GameObject
; a2 is list of pointers to colliders, ending with -1
;  if entry is zero, skip it (but increment index) 
; called from GameObject update
; go_collidedindex is set on GameObject when there is a callback
COLL_Bullet_Vs_GameObject_CollisionList_ScreenPositionList:
    move #COLLISION_LOOP_MODE_BULLET_VS_GAMEOBJECT,g_collision_loop_mode
    move #0,go_collidedindex(a0)
.colliderloop:
	move.l (a2)+,d0
	blt .ret
	beq .skipcollider
	move.l d0,a1
	
	add.l #collidergroup_firstoffset,a1

	move g_scroll_x,d0	
	move d0,d1
	add collider_offset_x0(a1),d0	;  left
	add collider_offset_x1(a1),d1	;  right
	
	move #0,d2
	move d2,d3
	add collider_offset_y0(a1),d2	;  top
	add collider_offset_y1(a1),d3	;  bottom


	move.l m_GOPointers_BulletObjects,a5    ;lea GOPointers_BulletObjects,a5
	move g_spritelist_bullet_amt,d6
	subq #1,d6
	blt	.ret

.bulletloop:

	move.l (a5)+,a1
	
	tst.b go_activestate(a1)
	beq .skipbullet

	move go_x(a1),d4
	add #COLL_BULLET_RADIUS,d4
	cmp d0,d4
	blt .nocol
	sub #COLL_BULLET_RADIUS*2,d4
	cmp d1,d4
	bgt .nocol

	move go_y(a1),d4
	add #COLL_BULLET_RADIUS,d4
	cmp d2,d4
	blt .nocol
	sub #COLL_BULLET_RADIUS*2,d4
	cmp d3,d4
	bgt .nocol

.collided:

; enemy callback
	PUSHALL
	move.l go_onCollided(a0),d0
	beq .nocolfunc1
	move.l d0,a5
	jsr (a5)
.nocolfunc1:
	POPALL

; bullet callback
	PUSHALL
	move.l go_onCollided(a1),d0
	beq .nocolfunc2
	move.l a1,a0
	move.l d0,a5
	jsr (a5)
.nocolfunc2:
	POPALL


.skipbullet:
.nocol:
	dbra d6,.bulletloop

.skipcollider:
   add #1,go_collidedindex(a0)
   bra .colliderloop
.ret:
	rts

;-----------------------------------------------------------------------------------------------------

COLL_Player_VS_Box:
    move #COLLISION_LOOP_MODE_PLAYER_VS_BOX,g_collision_loop_mode

	move.l g_player,a0

	move.l go_colliderAddr(a0),a1
	add.l #collidergroup_firstoffset,a1

	move go_x(a0),d0	
	move d0,d1
	add collider_offset_x0(a1),d0	; player left
	add collider_offset_x1(a1),d1	; player right
	
	move go_y(a0),d2
	move d2,d3
	add collider_offset_y0(a1),d2	; player top
	add collider_offset_y1(a1),d3	; player bottom

	;move.l m_GOPointers_HitPlayerObjects_Boxes,a4
	;move g_spritelist_hitplayer_box_amt,d7
	;subq #1,d7
	;blt	.ret
	
    jsr GOManager_GetList_Car
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    subq #1,d7
    blt	.ret

.enemyloop:
	move.l (a4)+,a0
	
	move.b go_coltype(a0),d4
	
	cmp.b #COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_BOX,d4
	beq .doenemy
	cmp.b #COLTYPE_HITPLAYER_BOX,d4
	beq .doenemy
	bra .skip

.doenemy:		
	
	move.l go_colliderAddr(a0),a1
	add.l #collidergroup_firstoffset,a1

	move go_x(a0),d4	
	move d4,d5
	add collider_offset_x0(a1),d4	; left
	add collider_offset_x1(a1),d5	; right

	cmp d5,d0		
	bgt .skip
	cmp d4,d1		
	blt .skip
	
	move go_y(a0),d4
	move d4,d5
	add collider_offset_y0(a1),d4	;  top
	add collider_offset_y1(a1),d5	;  bottom

	cmp d5,d2		
	bgt .skip
	cmp d4,d3		
	blt .skip

.collided:
	PUSHALL
	move.l a0,a1	; collidee
	move.l g_player,a0
	move.l go_onCollided(a0),d0
	beq .nocolfunc1
	move.l d0,a5
	jsr (a5)
.nocolfunc1:
	POPALL

	PUSHALL
	move.l go_onCollided(a0),d0
	beq .nocolfunc2
	move.l g_player,a1
	move.l d0,a5
	jsr (a5)
.nocolfunc2:
	POPALL

.skip:
	dbra d7,.enemyloop
.ret:
	rts


; called from GameObject update
COLL_SingleVsPlayer:

	move.l g_player,a1

	move.l go_colliderAddr(a1),a2
	add.l #collidergroup_firstoffset,a2

	move go_x(a1),d0	
	move d0,d1
	add collider_offset_x0(a2),d0	; player left
	add collider_offset_x1(a2),d1	; player right
	
	move go_y(a1),d2
	move d2,d3
	add collider_offset_y0(a2),d2	; player top
	add collider_offset_y1(a2),d3	; player bottom

	move.l go_colliderAddr(a0),a1
	add.l #collidergroup_firstoffset,a1

	move go_x(a0),d4	
	move d4,d5
	add collider_offset_x0(a1),d4	; left
	add collider_offset_x1(a1),d5	; right

	cmp d5,d0		
	bgt .skip
	cmp d4,d1		
	blt .skip
	
	move go_y(a0),d4
	move d4,d5
	add collider_offset_y0(a1),d4	;  top
	add collider_offset_y1(a1),d5	;  bottom

	cmp d5,d2		
	bgt .skip
	cmp d4,d3		
	blt .skip

	PUSHALL
	move.l go_onCollided(a0),d0
	beq .nocolfunc2
	move.l g_player,a1
	move.l d0,a5
	jsr (a5)
.nocolfunc2:
	POPALL

.skip:
.ret:
	rts


;-----------------------------------------------------------------------------------------------------
; Separates gameObject list in to multiple different lists depending on how they're used for collision
; BUT, currently it's only one list, so this is probably slower than not creating the lists
;-----------------------------------------------------------------------------------------------------
COLL_MakeGameObjectLists:
   
	
	move.l m_GOPointers_HitPlayerObjects_Points,a1
	move.l m_GOPointers_BulletObjects,a2
	move.l m_GOPointers_EnemyObjects,a3
	move.l m_GOPointers_HitPlayerObjects_Boxes,a4
	moveq #0,d1	; numA
	moveq #0,d2	; numB
	moveq #0,d3	; numC
	moveq #0,d4	; numC
	
	
    move.l m_GOLists,a5
    move.l golist_objects_addr(a5),a0
    move golist_total(a5),d7
    subq #1,d7
    bsr .doone

    move.l m_GOLists,a5
    lea golist_structsize*2(a5),a5      ; important objs
    move.l golist_objects_addr(a5),a0
    move golist_total(a5),d7
    subq #1,d7
    bsr .doone

    	
    move d1,g_spritelist_hitplayer_point_amt
    move d2,g_spritelist_bullet_amt
    move d3,g_spritelist_hitbyplayerbullet_amt
    move d4,g_spritelist_hitplayer_box_amt
    rts
.doone:
	
.l1:
	tst.b go_activestate(a0)
	beq .next
	move.b  go_coltype(a0),d5
	cmp.b #COLTYPE_HITPLAYER_POINT,d5
	beq .hitplayer_point
	cmp.b #COLTYPE_HITPLAYER_BOX,d5
	beq .hitplayer_box
	cmp.b #COLTYPE_BULLET,d5
	beq .bullet
	cmp.b #COLTYPE_HITBYPLAYERBULLET,d5
	beq .hitbyplayerbullet
	cmp.b #COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_POINT,d5
	beq .hitbyplayerbullet_and_hitplayer
	cmp.b #COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_BOX,d5
	beq .hitbyplayerbullet_and_hitplayer_box
	bra .next

.hitplayer_point:
	move.l a0,(a1)+	
	addq #1,d1
	bra .next
.bullet:
	move.l a0,(a2)+	
	addq #1,d2
	bra .next

.hitbyplayerbullet:
	move.l a0,(a3)+	
	addq #1,d3
	bra .next
	
.hitplayer_box:
	move.l a0,(a4)+	
	addq #1,d4
	bra .next
	
.hitbyplayerbullet_and_hitplayer:
	move.l a0,(a3)+	
	addq #1,d3
    move.l a0,(a1)+	
	addq #1,d1	
	bra .next	
.hitbyplayerbullet_and_hitplayer_box:
	move.l a0,(a3)+	
	addq #1,d3
    move.l a0,(a4)+	
    addq #1,d4
    bra .next

.next
	lea go_structsize(a0),a0
	dbra d7,.l1
	

	rts


; a0 isGameObject
; d0 is radius
COLL_IsOffMapEdge:
	move #0,d1
	sub d0,d1
	cmp go_x(a0),d1
	bgt .off

	move #0,d1
	sub d0,d1
	cmp go_y(a0),d1
	bgt .off

	move g_colmap_w,d1
	lsl #3,d1
	add d0,d1
	cmp go_x(a0),d1
	blt .off

	move g_colmap_h,d1
	lsl #3,d1
	add d0,d1
	cmp go_y(a0),d1
	blt .off

	moveq #0,d0
	rts

.off:
	moveq #1,d0
	rts


