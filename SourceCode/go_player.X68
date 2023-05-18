

GOIsColliding:
    move.l sysg_levelInfo+levelinfo_collisionMap,a1
    lea 4(a1),a1
    
    move go_x(a0),d0
    lsr #3,d0
    add d0,a1
    move go_y(a0),d0
    lsr #3,d0
    
    mulu sysg_levelInfo+levelinfo_collisionMap_stride,d0
    add d0,a1
    move.b (a1),d0
    beq .nocol
    moveq #1,d0
    rts
.nocol:
    moveq #0,d0
    rts

    

GOGetSurface:
    move.l sysg_levelInfo+levelinfo_surfaceMap,a1
    lea 4(a1),a1

    move go_x(a0),d0
    lsr #3,d0
    add d0,a1
    move go_y(a0),d0
    lsr #3,d0
    mulu sysg_levelInfo+levelinfo_surfaceMap_stride,d0
    add d0,a1
    move.b (a1),d0
    lea Racing_Surfaces,a4
    and #$ff,d0
    lsl #3,d0
    add d0,a4
    rts

GOGetFlow:
    move.l sysg_levelInfo+levelinfo_flowMap,a1
    lea 4(a1),a1
    
    move go_x(a0),d0
    lsr #3,d0
    add d0,a1
    move go_y(a0),d0
    lsr #3,d0
    lsl #7,d0
    add d0,a1
    move.b (a1),d0
    rts


    clrso
vec_speed   so.l 1 
vec_ang     so.w 1
vec_minSpeed    so.l 1
vec_maxSpeed    so.l 1
vec_structsize so.b 0

;a1
VEC_Clear:
    move.l #0,vec_speed(a1)
    move.w #0,vec_ang(a1)
    move.l #0,vec_minSpeed(a1)
    move.l #$40000,vec_maxSpeed(a1)
    rts

; a1 to a2
VEC_Copy:
    move.l vec_speed(a1),vec_speed(a1)
    move.w vec_ang(a1),vec_ang(a2)
    move.l vec_minSpeed(a1),vec_minSpeed(a2)
    move.l vec_maxSpeed(a1),vec_maxSpeed(a2)
    rts

; a1,d0    
VEC_Rotate:
    add.w d0,vec_ang(a1)
    rts
    
;a1,d0
VEC_AddToSpeedAndLimit:
    add.l d0,vec_speed(a1)
    move.l vec_speed(a1),d0
    
    cmp.l vec_minSpeed(a1),d0
    bgt .nomin
    move.l vec_minSpeed(a1),d0
.nomin:
    cmp.l vec_maxSpeed(a1),d0
    blt .nomax
    move.l vec_maxSpeed(a1),d0
.nomax:
    move.l d0,vec_speed(a1)
    rts


; turns a1 angle towards a2 angle
; d1 turn speed
VEC_TurnTowards:
    moveq #0,d0
    moveq #0,d2
	move.b vec_ang(a2),d0
	move.b vec_ang(a1),d2
	sub d2,d0
	and #$ff,d0

	cmp #0,d0
	beq .b
	cmp #128,d0
	blt .a
	sub.w d1,vec_ang(a1)
    rts
.a:
	add.w d1,vec_ang(a1)
.b:
	rts

; turns a1 angle towards a2 angle
; d1 turn speed
VEC_GetSteerDirTowards:
    moveq #0,d0
    moveq #0,d2
	move.b vec_ang(a2),d0
	move.b vec_ang(a1),d2
	sub d2,d0
	and #$ff,d0

	cmp #0,d0
	beq .b
	cmp #128,d0
	blt .a
	move #-1,d0
    rts
.a:
    move #1,d0
    rts
.b:
    moveq #0,d0
	rts


; d0 is max angle
VEC_LimitAngle:
    move.b vec_ang(a1),d1
    sub.b vec_ang(a2),d1
    and.l #$ff,d1
    ext.w d1
    tst d1
    bgt .limit_positive
.lmit_negative:
    move d0,d2
    neg d2
    cmp d2,d1
    bgt .lim_done
    move.b vec_ang(a2),d1
    sub.b d0,d1
    move.b d1,vec_ang(a1)
    bra .lim_done
    
.limit_positive
    cmp d0,d1
    blt .lim_done
    move.b vec_ang(a2),d1
    add.b d0,d1
    move.b d1,vec_ang(a1)
    
.lim_done:
    rts

; d0 is max angle
VEC_LimitSourceAngle:
    move.b vec_ang(a1),d1
    sub.b vec_ang(a2),d1
    and.l #$ff,d1
    ext.w d1
    tst d1
    bgt .limit_positive
.lmit_negative:
    move d0,d2
    neg d2
    cmp d2,d1
    bgt .lim_done
    move.b vec_ang(a1),d1
    add.b d0,d1
    move.b d1,vec_ang(a2)
    bra .lim_done
    
.limit_positive
    cmp d0,d1
    blt .lim_done
    move.b vec_ang(a1),d1
    sub.b d0,d1
    move.b d1,vec_ang(a2)
    
.lim_done:
    rts


;a1
; returns d0,d1 
VEC_GetDxDy:
    moveq #0,d0
    move.b vec_ang(a1),d0
    sub #64,d0
    and #$ff,d0
    
    jsr UTILS_GetSinCosLong
    
    move.l vec_speed(a1),d2
    asr.l #8,d2
    
    muls d2,d0
    muls d2,d1
    asr.l #8,d0
    asr.l #8,d1
    
    rts



HolUpdateScrollFromPlayer:
    move go_x(a0),d0
    sub #320/2,d0
    move d0,g_scroll_x
    move go_y(a0),d0
    sub #224/2,d0
    move d0,g_scroll_y
    rts
    
HolLimitScrollEdges:
    move g_scroll_x,d0
    bge .ok_l
    move #0,g_scroll_x    
.ok_l:
    move.l sysg_levelInfo+levelinfo_tileMap0,a1
    move 2(a1),d1
    sub #40,d1
    lsl #3,d1

    cmp d1,d0
    blt .ok_r
    move d1,g_scroll_x    
.ok_r:

    move g_scroll_y,d0
    bge .ok_t
    move #0,g_scroll_y    
.ok_t:
    move.l sysg_levelInfo+levelinfo_tileMap0,a1
    move 4(a1),d1
    sub #28,d1
    lsl #3,d1
    cmp d1,d0
    blt .ok_b
    move d1,g_scroll_y    
.ok_b:
    rts

Racing_InitDebugRotator:
    SETSPR SPRITE_DEBUG
    move #2,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move.l g_player,d0
    beq .exit
    move.l d0,a1
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    lea go_moveVec(a1),a2
    moveq #0,d0
    move.b vec_ang(a2),d0
    divu #(255/24),d0
    
    cmp #23,d0
    ble .ok1
    move #23,d0
.ok1:
    add #2,d0
    
    move d0,go_frame(a0)
.exit:
    rts

Racing_UpdateAngleCatchupOffset:

    tst.b go_usingHandbrake(a0)
    beq .off
.on:
    add #1,go_maxAngleCatchupOffset(a0)
    cmp #64,go_maxAngleCatchupOffset(a0)
    blt .exit
    move #64,go_maxAngleCatchupOffset(a0)
    bra .exit

.off:
    sub #1,go_maxAngleCatchupOffset(a0)
    cmp #32,go_maxAngleCatchupOffset(a0)
    bgt .exit
    move #32,go_maxAngleCatchupOffset(a0)
    bra .exit
.exit:
    rts

Racing_SetFrameFromAngle:
    moveq #0,d0
    move.b go_facingVec+vec_ang(a0),d0
    add #4,d0
    and #$ff,d0
    lsr #3,d0
    add d0,d0
    add d0,d0
    lea CarRot_FrameTable,a2
    add d0,a2
    move (a2)+,go_frame(a0)
    move (a2),go_sprAttributes(a0)
    rts

; get current speed as a percentage of total speed
; look that up in Curve_CarAccel
; add that to current speed, and limit to max 
; speed is w:w
Racing_CarAccelerate:
    lea go_moveVec(a0),a1
    move.l vec_speed(a1),d0
    move.l vec_maxSpeed(a1),d1
    lsr.l #8,d1
    divu d1,d0
    lea Curve_CarAccel+16,a2
    lsl #2,d0
    move.l (a2,d0),d0
    lsr.l #2,d0
    bsr VEC_AddToSpeedAndLimit
    rts
    
Racing_CarCoast:
    lea go_moveVec(a0),a1
    
    move.l #-$400,d0   
    bsr VEC_AddToSpeedAndLimit
    rts

Racing_CarBrake:
    lea go_moveVec(a0),a1
    
    move.l #-$1000,d0   
    bsr VEC_AddToSpeedAndLimit
    rts

Racing_CarSteer:
    tst go_steeringInput(a0)
    beq .exit
    lea go_facingVec(a0),a1
    move cardata_steeringVel(a5),d0
    tst go_steeringInput(a0)
    bge .noneg
    neg d0
.noneg:
    bsr VEC_Rotate
.exit:
    rts


; d1 is 'full speed' turn rate. 
; scale that to something like $400 as the speed scales from 0 to something like $40000
Racing_ScaleTurnSpeed:
    move.l go_moveVec+vec_speed(a0),d0
    cmp.l #$40000,d0
    blt .ok1
    move.l #$40000,d0
.ok1:

    lsr.l #8,d0 
    lsr.l #2,d0         ; range 0-1
    neg d0
    add #256,d0         ; 256-0
    
    ;d1 is catchup speed, something like $100 or $80 at d0=256 
    ; that should scale to $400 at d0 = 0
    
    move.l #$200,d2     ; max turn rate
    sub d1,d2           ; range
    ; range / 256 * scale (d0)
    
    mulu d0,d2
    lsr.l #8,d2
    add d1,d2
    move d2,d1 
    ;move.l d1,DebugArea     ; resultant turn rate
    
    rts

Racing_CarSteerCatchup:
    lea go_moveVec(a0),a1
    lea go_facingVec(a0),a2
    moveq #0,d1
    move surface_steeringCatchup_normal(a4),d1
    tst.b go_usingHandbrake(a0)
    beq .noHandbrake
    move surface_steeringCatchup_handbrake(a4),d1   
.noHandbrake:
    bsr Racing_ScaleTurnSpeed
    bsr VEC_TurnTowards
    rts
    
Racing_CarAccelDecel:
    btst #pad_button_up,d5
    tst.b go_updown_input(a0)
    beq .coast
    bgt .accel
.brake
    bra Racing_CarBrake
.accel:
    bra Racing_CarAccelerate
.coast:
    bra Racing_CarCoast
    
Racing_PlayerGetInputs:
    
; steering input    
    move #0,go_steeringInput(a0)  ;
    move g_pad0,d5
    btst #pad_button_left,d5
    beq .nol
    move #-1,go_steeringInput(a0)  ;
.nol:
    btst #pad_button_right,d5
    beq .nor
    move #1,go_steeringInput(a0)  ;
.nor:

;handbrake
    move.b #0,go_usingHandbrake(a0)
    btst #pad_button_b,d5
    beq .no_handbrake
    move.b #1,go_usingHandbrake(a0)
.no_handbrake:

;turbo
    ;move.b #0,go_usingTurbo(a0)
    ;btst #pad_button_b,d5
    ;beq .no_turbo
    ;move.b #1,go_usingTurbo(a0)
.no_turbo:
; accel / decel
    move.b #0,go_updown_input(a0)
    btst #pad_button_a,d5
    beq .noaccel
    move.b #1,go_updown_input(a0)
    bra .done_accel_decel
.noaccel:    
    btst #pad_button_c,d5
    beq .nodecel
    move.b #-1,go_updown_input(a0)
    bra .done_accel_decel
.nodecel:
    bsr Racing_CarCoast
.done_accel_decel:
    rts
    
Racing_CarApplyTurbo:
    tst.b go_usingTurbo(a0)
    beq .noturb
    move.l #SCREENSHAKE_MAX,g_screenshake_timer
    lea go_moveVec(a0),a1
    lea go_tempVec(a0),a2
    bsr VEC_Copy
    lea go_tempVec(a0),a1
    jsr UTILS_GetRandWordFast
    and #63,d0
    sub #32,d0
    add.b d0,vec_ang(a1)            ; random skittish angle on Turbo
    move.l #$10000,vec_speed(a1)
    jsr VEC_GetDxDy
    add.l d0,go_dx(a0)
    add.l d1,go_dy(a0)
.noturb:    
    rts
    
    
    
    
Racing_InitPlayer:
    move.l a0,g_player
    SETSPR SPRITE_COFFEE_PAL0_SOFTWARESPRITE
    move #0,go_frame(a0)
    move #100,go_x(a0)    
    move #350,go_y(a0)    
    
    lea go_facingVec(a0),a1
    bsr VEC_Clear
    
    lea go_moveVec(a0),a1
    bsr VEC_Clear
    
    lea go_tempVec(a0),a1
    bsr VEC_Clear
    
    move #-1,go_lapIndex(a0)    ; not crossed line yet
    move.l #$40000,go_currentTopSpeed(a0)
    
    jsr RECORD_Start
    move.l #32<<16,go_maxAngleCatchupOffset(a0)
    move.l #.firsttime,go_onUpdate(a0)
    
    move.l #.secondUpdate,go_onUpdate2(a0)
    
    jsr LAPTIME_Stop
    rts    
.firsttime:
    lea go_path(a0),a1
    move #0,d0
    bsr PATH_Init
    bsr PATH_CacheCurrentNodeData
    move.l #.update,go_onUpdate(a0)   

    
.update:
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)

.domove:
    move.l #0,go_dx(a0)
    move.l #0,go_dy(a0)

    bsr Racing_PlayerGetInputs
    
    lea Racing_CarData0,a5
    
    
    bsr GOGetSurface        ; in a4

; limit top speed based on car top speed and surface modifier.
; move a global TopSpeed variable towards the current     
    move.l cardata_topSpeed(a5),d0
    add.l surface_topSpeedModifier(a4),d0
    
    sub.l go_currentTopSpeed(a0),d0
    asr.l #4,d0
    add.l d0,go_currentTopSpeed(a0)
    
    
    lea go_moveVec(a0),a1
    ;move.l cardata_topSpeed(a5),vec_maxSpeed(a1)
    move.l go_currentTopSpeed(a0),vec_maxSpeed(a1)
    

    bsr Racing_CarAccelDecel

    bsr Racing_CarSteer
    bsr Racing_CarSteerCatchup



    bsr Racing_UpdateAngleCatchupOffset
    
    lea go_moveVec(a0),a1
    lea go_facingVec(a0),a2
    move go_maxAngleCatchupOffset(a0),d0
    bsr VEC_LimitSourceAngle    
    
    
    
    
    lea go_moveVec(a0),a1
    jsr VEC_GetDxDy
    move.l d0,go_dx(a0)
    move.l d1,go_dy(a0)

    bsr Racing_CarApplyTurbo


    rts

.secondUpdate:
    move.l go_dx(a0),d0    
    add.l d0,go_x(a0)
    bsr GOIsColliding
    beq .nocolX
    move.l go_oldx(a0),go_x(a0)
.nocolX
    move.l go_dy(a0),d0    
    add.l d0,go_y(a0)
    bsr GOIsColliding
    beq .nocolY
    move.l go_oldy(a0),go_y(a0)
.nocolY
    
    lea go_path(a0),a1
    bsr PATH_Test
    
    lea go_path(a0),a1
    tst path_passedNodeThisFrame(a1)
    bmi .nopassnode

    tst path_passedNodeThisFrame(a1)
    bne .notlapped
    
    add #1,go_lapIndex(a0)
    
    tst go_lapIndex(a0)
    bne .notfirstcross
    jsr LAPTIME_Start
    jsr RECORD_Start
    bra .nopassnode
    
.notfirstcross:
    
    bsr LAPTIME_TestBest
    beq .nobesttime
    jsr RECORD_CopyToPlayback
    
.nobesttime:
    
    bsr Racing_GhostPlayer_StartPlayback
    jsr LAPTIME_Start
    jsr RECORD_Start
.notlapped:
.nopassnode:
    
    bsr Racing_SetFrameFromAngle        
    
    jsr RECORD_AddPos
    jsr LAPTIME_Update

.nomove:
    bsr HolUpdateScrollFromPlayer
    bsr HolLimitScrollEdges

    rts
    
    

CarRot_FrameTable:
    dc.w 0,0
    dc.w 1,0
    dc.w 2,0
    dc.w 3,0
    dc.w 4,0
    dc.w 5,0
    dc.w 6,0
    dc.w 7,0
    
    dc.w 8,0
    
    dc.w 7,FLIP_V
    dc.w 6,FLIP_V
    dc.w 5,FLIP_V
    dc.w 4,FLIP_V
    dc.w 3,FLIP_V
    dc.w 2,FLIP_V
    dc.w 1,FLIP_V
    
    dc.w 0,FLIP_V
    
    dc.w 1,FLIP_V|FLIP_H
    dc.w 2,FLIP_V|FLIP_H
    dc.w 3,FLIP_V|FLIP_H
    dc.w 4,FLIP_V|FLIP_H
    dc.w 5,FLIP_V|FLIP_H
    dc.w 6,FLIP_V|FLIP_H
    dc.w 7,FLIP_V|FLIP_H
    
    dc.w 8,FLIP_H
    dc.w 7,FLIP_H
    dc.w 6,FLIP_H
    dc.w 5,FLIP_H
    dc.w 4,FLIP_H
    dc.w 3,FLIP_H
    dc.w 2,FLIP_H
    dc.w 1,FLIP_H
    
    

Racing_InitParticleTest:
    ;lea Psys_JuTest1,a1     ;ExportedParticles+compoundsprs_firstspriteaddr+(\1*4) ,a1
    move.l a1,go_compoundSprAddr(a0)
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    add #1,go_frame(a0)
    cmp #20,go_frame(a0)
    beq .die
    rts
.die:
    jmp GOManager_DeleteObject

Racing_InitPickup:
;    SETSPR SPRITE_GAMEOVERINGAME
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    rts


Racing_Debug_InitPathMarker:    
    SETSPR SPRITE_COFFEE_PAL0
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move.l g_player,d0
    move.l g_aiPlayer0,d0
    
    beq .r
    move.l d0,a1
    lea go_path(a1),a1
    move path_x(a1),go_x(a0)
    move path_y(a1),go_y(a0)
.r: rts
    
Racing_Debug_InitCompSprTest:    
    SETCOMPSPR 0
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move #200,go_x(a0)
    move #100,go_y(a0)
    rts
.update:
    move g_timer1,d0
    and #63,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)

    rts
.frames:
    dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
    dc.w 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    dc.w 32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17
    dc.w 16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
    
    
    

; called from player
Racing_GhostPlayer_StartPlayback:
    move.l g_playerGhost,a1
    move.l #Racing_GhostPlayer_Update,go_onUpdate(a1)
    GO_SET_VISIBLE_A1
    jsr PLAYBACK_Init
    rts
    

Racing_InitGhostPlayer:
    move.l a0,g_playerGhost
    SETSPR SPRITE_COFFEE_PAL0_SOFTWARESPRITE
    move #0,go_frame(a0)
    move.l #.update_nothing,go_onUpdate(a0)
    GO_SET_INVISIBLE
    rts   
.update_nothing:
    rts
    
Racing_GhostPlayer_Update:
    bsr PLAYBACK_GetNextPos
    bsr Racing_SetFrameFromAngle
    rts
    
    
    

    clrso
cardata_steeringVel so.w 1
cardata_topSpeed so.l 1

    clrso
surface_topSpeedModifier so.l 1
surface_steeringCatchup_normal  so.w 1
surface_steeringCatchup_handbrake  so.w 1

Racing_CarData0:
    dc.w $200               ; steering vel
    dc.l $60000                 ; top speed


Racing_Surfaces:
Racing_Surface_Grass:
    dc.l -$28000               ; topspeed modifier
    dc.w $c0,$80            ; steering catchup normal / handbrake
Racing_Surface_Tarmac:
    dc.l 0               ; topspeed modifier
    dc.w $100,$c0               ; steering catchup normal / handbrake
Racing_Surface_Mud:
    dc.l -$28000               ; topspeed modifier
    dc.w $c0,$80            ; steering catchup normal / handbrake
Racing_Surface_Water:
    dc.l -$40000               ; topspeed modifier
    dc.w $c0,$80            ; steering catchup normal / handbrake    