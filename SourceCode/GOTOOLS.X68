;------------------------------------------------------------------------------------------------------------------------------------------------
; General GameObject helpers
;------------------------------------------------------------------------------------------------------------------------------------------------


;------------------------------------------------------------------------------------------------------------------------------------------------
; Initialise the GameObject in a0. Resets all variables which need to be reset to prevent weird stuff happening!
;------------------------------------------------------------------------------------------------------------------------------------------------
GO_ClearGO:
	moveq #0,d0
    move.l d0,go_flags(a0)

	move.l d0,go_compoundSprAddr(a0)
	
	    ifd IS_GAME_CUBEDROID
    move.l #0,go_cd_onPushed(a0)
    move.l #0,go_cd_onEntered(a0)
    move.l #0,go_cd_onMoveFinished(a0)
    move.w #0,go_cd_isPushable(a0)
    move.w #0,go_cd_canMoveOnTo(a0)
        endif

    move #-32,go_compound_x0(a0)
    move #32,go_compound_x1(a0)
    move #-32,go_compound_y0(a0)
    move #32,go_compound_y1(a0)
	
	move.l #-1,go_maxcount_type(a0)
	move.l d0,go_onTriggered(a0)
	move.l d0,go_onUpdate(a0)
	move.l d0,go_onRender(a0)
	move.l d0,go_onBeforeMainRender(a0)
	move.l d0,go_onAfterMainRender(a0)
	move.l d0,go_onDeleted(a0)
	move.l d0,go_sprgroup(a0)
	move.l d0,go_colliderAddr(a0)
	move.l d0,go_getCustomCollisionFunc(a0)
	move.l d0,go_onCollided(a0)
	
	move.l d0,go_spawnlist_addr(a0)
	move.l d0,go_cached_frame_addr(a0)

	move d0,go_sprAttributes(a0)
	move.l d0,go_scorepopup(a0)
	SET_GO_PRIORITY GOPRIORITY_1
	move #-1,go_type(a0)
	move.b #COLTYPE_NONE,go_coltype(a0)
	

	rts
    
;------------------------------------------------------------------------------------------------------------------------------------------------
; Update all the active game objects, calling their go_updatefunc(a0)
;  d7 is unsafe during GameObject's update function
;------------------------------------------------------------------------------------------------------------------------------------------------
GO_Update:
    rts



;------------------------------------------------------------------------------------------------------------------------------------------------
; is GameObject a0 position within a square radius of GameObject a1 ?
; a0 = obj, a1 = obj with box
; d0 = xdist (radius)
; d1 = ydist (radius)
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_IsGoWithinSquareRadius:
	move.w go_x(a1),d2
	sub.w go_x(a0),d2
	bge .neg1
	neg	d2
.neg1:
	cmp d0,d2
	bgt .return

	move.w go_y(a1),d2
	sub.w go_y(a0),d2
	bge .neg2
	neg	d2
.neg2:
	cmp d1,d2
	bgt .return
.near:
	moveq #1,d0
	rts
.return:
	moveq #0,d0
	rts


GOTOOLS_Sqrt_16_8_Fast
        move.w d1,-(sp) ;(8)
        move.w #-1,d1   ;(8)
.qsqrt1  addq.w #2,d1    ;(4)
        sub.w d1,d0     ;(4)
        bpl  .qsqrt1     ;(10/8)
        asr.w #1,d1     ;(8)
        move.w d1,d0    ;(4)
        move.w (sp)+,d1 ;(12)
.done    rts             ;(16)

GOTOOLS_Sqrt_16_8:
   		movem.l d1-d4,-(sp) ;(24)
        move.w #7,d4    ;(8)     ; Loop count (bits-1 of result).
        clr.w d1        ;(4)     ; Error term in D1.
        clr.w d2        ;(4)
.sqrt1   add.w d0,d0     ;(4)     ; Get 2 leading bits a time and add
        addx.w d1,d1    ;(4)     ; into Error term for interpolation.
        add.w d0,d0     ;(4)     ; (Classical method, easy in binary).
        addx.w d1,d1    ;(4)
        add.w d2,d2     ;(4)     ; Running estimate *2.
        move.w d2,d3    ;(4)
        add.w d3,d3     ;(4)
        cmp.w d3,d1     ;(4)
        bls.s .sqrt2     ;(10/8)  ; New Error term > 2* Running estimate?
        addq.w #1,d2    ;(4)     ; Yes, we want a '1' bit then.
        addq.w #1,d3    ;(4)     ; Fix up new Error term.
        sub.w d3,d1     ;(4)
.sqrt2   dbra d4,.sqrt1   ;(10/14) ; Do all 8 bit-pairs.
        move.w d2,d0    ;(4)
        movem.l (sp)+,d1-d4 ;(28)
        rts             ;(16)

; d0x, d1y
GOTOOLS_NormalizeVec:
	moveq #0,d2
	moveq #0,d3
	move.l d0,d2
	move.l d1,d3

	muls d0,d0
	muls d1,d1
	add d1,d0
	bsr GOTOOLS_Sqrt_16_8_Fast

	and.l #$ffff,d0

	;d0 = magnitude
	; divide each axis by magnitide

	ext.l d2
	asl.l #8,d2
	divs d0,d2
	and.l #$ffff,d2
	ext.l d2
	asl.l #8,d2
	;asl.l #4,d2

	ext.l d3
	asl.l #8,d3
	divs d0,d3
	and.l #$ffff,d3
	ext.l d3
	asl.l #8,d3
	;asl.l #4,d3

	move.l d2,d0
	move.l d3,d1
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; Set X flip bits on a0 to look towards GameObject a1
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_FlipToFaceGO:
	move #FLIP_NONE,d0	
	move go_x(a0),d1
	cmp go_x(a1),d1
	blt .noflip
	move #FLIP_H,d0
.noflip:
	move d0,go_sprAttributes(a0)
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Set X flip bits on a0 based on velocity in d0.l
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_FlipToVelocityL:
	move #FLIP_NONE,d1
	tst.l d0
	bgt .noflip
	move #FLIP_H,d1
.noflip:
	move d1,go_sprAttributes(a0)
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; d0 is angle. Modified.
; returns x=d2.l, y=d1.l
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetMovementVecFromRot:
	and #$ff,d0
	sub.w #64,d0
	and #$ff,d0
	jsr UTILS_GetSinCos
	ext.l d1
	ext.l d2
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; d0: angle to rotate towards 
; d1.l rot speed
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_RotateTowards:
	move go_rot(a0),d2
	sub d2,d0
	and #$ff,d0

	cmp #0,d0
	beq .b
	cmp #128,d0
	blt .a
	sub.l d1,go_rot(a0)
	bra .b
.a:
	add.l d1,go_rot(a0)
.b:
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; a1 is object to face
; returns angle in d0
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetAngToGO:
	move go_x(a1),d0
	sub.w go_x(a0),d0
	move go_y(a1),d1
	sub.w go_y(a0),d1
	jsr GetAtan2
	move d2,d0
	rts



;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GETANG_GO macro \1 \2
	move go_x(\2),d0
	sub.w go_x(\1),d0
	move go_y(\2),d1
	sub.w go_y(\1),d1
	jsr GetAtan2
	move d2,d0
	endm
	
;------------------------------------------------------------------------------------------------------------------------------------------------
; d0 is x diff
; d1 is y diff
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetAng:
	jsr GetAtan2
	move d2,d0
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; d0.w is number of frames
; uses d1
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_LoopAnim:
	move.l go_frame(a0),d1
	add.l go_framevel(a0),d1
	swap d1
	cmp d0,d1
	blt .noloop
	sub d0,d1
.noloop:
	swap d1
	move.l d1,go_frame(a0)
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; d0.w is number of frames
; uses d1 ; destroys d0
; zero bit set on return
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_PlayAnim:
	move.l go_framevel(a0),d1
	add.l d1,go_frame(a0)
	cmp go_frame(a0),d0
	bgt .no
	sub #1,d1
	move d0,go_frame(a0)
	moveq #1,d0
	rts
.no
	moveq #0,d0
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_dummy_collided
	jsr GOManager_DeleteObject	
	rts

    
;------------------------------------------------------------------------------------------------------------------------------------------------
; d0 is index
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_SetPathFromIndex:
	bsr GOTOOLS_GetPathsAddr
	lea 2(a1),a1
	lsl #2,d0
	add d0,a1
	move.l (a1),a1
	move.l a1,go_pathfollow_addr(a0)
	move.l #0,go_pathfollow_index(a0)
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetPathsAddr:
    move.l sysg_leveldata_addr,a1
	move.l leveldef_paths(a1),a1
	rts
	
;------------------------------------------------------------------------------------------------------------------------------------------------
;d0 is path index
;returns in a1
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetPathAddr:
    move.l sysg_leveldata_addr,a1
	move.l leveldef_paths(a1),a1
	lea 2(a1),a1
	lsl #2,d0
	move.l (a1,d0),a1
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_MoveToStartIndex:
	move go_pathfollow_index(a0),d3
	beq GOTOOLS_GetPathZeroPosition
	bsr GOTOOLS_GetPathZeroPosition
	move go_x(a0),d0
	move go_y(a0),d1
	subq #1,d3
.lp:
	move.b (a1)+,d2
	ext.w d2
	add d2,d0
	move.b (a1)+,d2
	ext.w d2
	add d2,d1
	dbra d3,.lp
	move d0,go_x(a0)
	move d1,go_y(a0)
	rts


; not in GOs.. need to reinstate them if using pathfollow
go_pathfollow_addr equ 0
go_pathfollow_x equ 0
go_pathfollow_y equ 0
go_pathfollow_index equ 0

;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetPathZeroPosition:
	move.l go_pathfollow_addr(a0),a1
	lea 2(a1),a1	; num positions
	move.w (a1)+,go_x(a0)
	move.w (a1)+,go_y(a0)
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetPathZeroPosition_SeparatePos:
	move.l go_pathfollow_addr(a0),a1
	lea 2(a1),a1	; num positions
	move.w (a1)+,go_pathfollow_x(a0)
	move.w (a1)+,go_pathfollow_y(a0)
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_UpdatePathFollowLoop_SeparatePos:
	move go_pathfollow_index(a0),d0
	bne .notfirst
	bsr GOTOOLS_GetPathZeroPosition_SeparatePos
	bra .follow
.notfirst:
	bsr GOTOOLS_UpdatePathFollow_Inner_SeparatePos
.follow:

	move.l go_pathfollow_addr(a0),a1
	move.w (a1)+,d2	; num positions
	sub #1,d2
	add.l #$10000,go_pathfollow_index(a0)
	move go_pathfollow_index(a0),d0
	cmp d2,d0
	blt .noloop
	move.l #0,go_pathfollow_index(a0)
.noloop:
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_UpdatePathFollowLoop:
	move go_pathfollow_index(a0),d0
	bne .notfirst
	bsr GOTOOLS_GetPathZeroPosition
	bra .follow
.notfirst:
	bsr GOTOOLS_UpdatePathFollow_Inner
.follow:

	move.l go_pathfollow_addr(a0),a1
	move.w (a1)+,d2	; num positions
	sub #1,d2
	add.l #$10000,go_pathfollow_index(a0)
	move go_pathfollow_index(a0),d0
	cmp d2,d0
	blt .noloop
	move.l #0,go_pathfollow_index(a0)
.noloop:
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; go_pathfollow_index(a0) in d0
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_UpdatePathFollow_Inner:
	move.l go_pathfollow_addr(a0),a1
	move.w (a1)+,d2	; num positions
	lea 4(a1),a1	;start pos

	lsl #1,d0
	add d0,a1
	move.b (a1)+,d0
	ext.w d0
	add d0,go_x(a0)
	move.b (a1)+,d0
	ext.w d0
	add d0,go_y(a0)
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; go_pathfollow_index(a0) in d0
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_UpdatePathFollow_Inner_SeparatePos:
	move.l go_pathfollow_addr(a0),a1
	move.w (a1)+,d2	; num positions
	lea 4(a1),a1	;start pos

	lsl #1,d0
	add d0,a1
	move.b (a1)+,d0
	ext.w d0
	add d0,go_pathfollow_x(a0)
	move.b (a1)+,d0
	ext.w d0
	add d0,go_pathfollow_y(a0)
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_SetPosFromPath:
	move go_pathfollow_index(a0),d0
	move.l go_pathfollow_addr(a0),a1
	move.w (a1)+,d2	; num positions
	lsl #2,d0
	add d0,a1
	move.w (a1)+,go_x(a0)
	move.w (a1)+,go_y(a0)
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; sets d0 to 1 if path completed
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_UpdatePathFollowOnce:
	move go_pathfollow_index(a0),d0
	bne .notfirst
	bsr GOTOOLS_GetPathZeroPosition
	bra .follow
.notfirst:
	bsr GOTOOLS_UpdatePathFollow_Inner
.follow:
	add.l #$10000,go_pathfollow_index(a0)

	move.l go_pathfollow_addr(a0),a1
	move.w (a1)+,d2	; num positions
	sub #1,d2
	move go_pathfollow_index(a0),d0
	cmp d2,d0
	blt .noloop
	move.l #0,go_pathfollow_index(a0)
	moveq #1,d0
	rts
	
.noloop:
	moveq #0,d0
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; a0 is current object
; a1 is object to shoot at
; d0 is shift value multiplier
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_SetVelTowardsObject:
	move d0,d2	; save shift val
	moveq #0,d0
	moveq #0,d1
	move.w go_x(a1),d0
	sub.w go_x(a0),d0
	move.w go_y(a1),d1
	sub.w go_y(a0),d1

	jsr GetNormal

	lsl.l #8,d0
	lsl.l #8,d1

	move.l d0,go_dx(a0)
	move.l d1,go_dy(a0)

    rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; go_framevel(a0) is framevel
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_LoopCompoundSpriteAnim:
	move.l go_compoundSprAddr(a0),a1
	move.l go_framevel(a0),d0
	add.l d0,go_frame(a0)
	move go_frame(a0),d0	
	moveq #0,d1
	move (a1),d1
	cmp d1,d0
	blt .no
	swap d1
	sub.l d1,go_frame(a0)
.no:
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; sets d0 to true when done
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_PlayCompoundSpriteAnim:
	move.l go_compoundSprAddr(a0),a1
	move.l go_framevel(a0),d0
	add.l d0,go_frame(a0)
	move go_frame(a0),d0	
	moveq #0,d1
	move (a1),d1	; num frames
	cmp d1,d0
	blt .no
	swap d1
	sub.l d1,go_frame(a0)
	moveq #1,d0
	rts
.no:
	moveq #0,d0
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_PlayCompoundSpriteAnimPingPong
	move.l go_compoundSprAddr(a0),a1
	move.l go_framevel(a0),d0
	bge .forwards
.backwards:
	add.l d0,go_frame(a0)
	move go_frame(a0),d0	
	bge .no
	move.l #0,go_frame(a0)
	neg.l go_framevel(a0)
.finished:
	moveq #1,d0
	rts	
.forwards:
	add.l d0,go_frame(a0)
	move go_frame(a0),d0	
	moveq #0,d1
	move (a1),d1
	cmp d1,d0
	blt .no
	sub.w #1,d1
	move.w d1,go_frame(a0)
	neg.l go_framevel(a0)
.no:
	moveq #0,d0
	rts	


;------------------------------------------------------------------------------------------------------------------------------------------------
; a1 frame list (bytes)
;eg: Anim:dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,12,11,10,9,8,7,6,5,4,3,2,1,0,-1   align 2
; -1 means last frame
; uses go_metaframe
; maximum 255 frames
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_PlayMetaAnim:
    rts
;	move.l go_framevel(a0),d0
;	add.l d0,go_metaframe(a0)
;	move go_metaframe(a0),d0	
;	moveq #0,d1
;	move.b (a1,d0),d1
;	cmp.b #-1,d1
;	beq .finished
;	move d1,go_frame(a0)
;	moveq #0,d0
;	rts
;.finished
;	moveq #1,d0
;	rts





;------------------------------------------------------------------------------------------------------------------------------------------------
; a0 is GameObject
; returns compspr addr in a1
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_GetCompSprFrameAddr:
	move.l go_compoundSprAddr(a0),a1
	add.l #compoundspr_firstframeaddr,a1
	move.w go_frame(a0),d0
	lsl #compoundspr_sizeshift,d0
	add d0,a1
	rts



;------------------------------------------------------------------------------------------------------------------------------------------------
; a0 is GO with trigger, go_triggeraddr is trigger addr
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_IsPlayerInTriggerZone:
	move.l g_player,a1
	move go_x(a1),d0
	move go_y(a1),d1
	bra GOTOOLS_IsPosInTriggerZone

;------------------------------------------------------------------------------------------------------------------------------------------------
; a0 is GO with trigger, d0 x, d1 y, go_triggeraddr is trigger addr
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_IsPosInTriggerZone:
	;JSmove.l go_triggeraddr(a0),a1
	lea 2(a1),a1	; ignore number of triggers
	
	move go_x(a0),d2
	move d2,d3
	add (a1)+,d2
	cmp d2,d0
	blt .no
	add (a1)+,d3
	cmp d3,d0
	bgt .no

	move go_y(a0),d2
	move d2,d3
	add (a1)+,d2
	cmp d2,d1
	blt .no
	add (a1)+,d3
	cmp d3,d1
	bgt .no

	moveq #1,d0
	rts
.no:
	moveq #0,d0
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
GOTOOLS_FlickerSpriteOnTimer:
	move.l go_flags(a0),d1
	bclr #GOFLAG_INVISIBLE,d1
	move go_timer(a0),d2
	cmp d0,d2
	bgt .notnearend
	and #2,d2
	beq .notnearend
	bset #GOFLAG_INVISIBLE,d1
.notnearend:
	move.l d1,go_flags(a0)	
	rts



