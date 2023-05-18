
Racing_InitAICar:
    move.l a0,g_aiPlayer0
    SETSPR SPRITE_COFFEE_PAL0_SOFTWARESPRITE
    move #0,go_frame(a0)
    move #100,go_x(a0)    
    move #200,go_y(a0)    
    
  
    
    lea go_facingVec(a0),a1
    bsr VEC_Clear
    
    lea go_moveVec(a0),a1
    bsr VEC_Clear
    
    lea go_tempVec(a0),a1
    bsr VEC_Clear
    
    bsr .setrandspeed
    
    move.l #.firsttime,go_onUpdate(a0)
    move.l #.secondUpdate,go_onUpdate2(a0)
    
    move #60,go_timer(a0)
    rts    
    

    
    
.setrandspeed:
    jsr UTILS_GetRandWordFast
    and.l #$ffff,d0
    lsl.l #1,d0
    add.l #$58000,d0
    move.l d0,go_currentTopSpeed(a0)
    ;move.l d0,go_moveVec+vec_speed(a0)
    
    jsr UTILS_GetRandWordFast
    and #15,d0
    sub #8,d0
    move d0,go_ai_bodger(a0)
    
    rts
    
 .firsttime:
     lea go_path(a0),a1
     move go_index(a0),d0
     and #1,d0
     move #0,d0
     bsr PATH_Init
     bsr PATH_CacheCurrentNodeData
     move.l #.update,go_onUpdate(a0)   
.update:

    sub #1,go_timer(a0)
    bgt .notimer
    jsr UTILS_GetRandWordFast
    and #31,d0
    add #20,d0
    move d0,go_timer(a0)
    bsr .setrandspeed
.notimer:
    
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)

.domove:
    move.l #0,go_dx(a0)
    move.l #0,go_dy(a0)


    lea go_moveVec(a0),a1
    move.l go_currentTopSpeed(a0),d0
    move.l #$40000,d0
    sub.l vec_speed(a1),d0
    asr.l #5,d0
    add.l d0,vec_speed(a1)


    lea Racing_Surface_Tarmac,a4
    lea Racing_CarData0,a5

    jsr GOGetFlow
    
    beq .dir_towards_node
    lea go_tempVec(a0),a1
    move.b d0,vec_ang(a1)
    bra .dir_done

.dir_towards_node
    lea go_path(a0),a1
    bsr PATH_GetCurrentNodeXY

    lea go_tempVec(a0),a1
    sub go_x(a0),d0
    sub go_y(a0),d1
    jsr GetAtan2
    move.b d2,vec_ang(a1)
.dir_done:
    
    move go_ai_bodger(a0),d0
    add.b d0,vec_ang(a1)

    
    lea go_moveVec(a0),a1
    lea go_tempVec(a0),a2
    jsr VEC_GetSteerDirTowards
    move d0,go_steeringInput(a0)
    jsr Racing_CarSteer

    lea go_facingVec(a0),a1
    lea go_moveVec(a0),a2
    move vec_ang(a1),vec_ang(a2)
    
    
    
   ; lea go_moveVec(a0),a1
   ; lea go_facingVec(a0),a2
   ; move surface_steeringCatchup_normal(a4),d1
   ; bsr VEC_TurnTowards
    
    lea go_moveVec(a0),a1
    jsr VEC_GetDxDy
    move.l d0,go_dx(a0)
    move.l d1,go_dy(a0)
    
;     move.l #0,go_dx(a0)
;     move.l #0,go_dy(a0)

    ; use car dir to get prev pos
    ;lea go_moveVec(a0),a1
    ;lea go_tempVec(a0),a2
    ;jsr VEC_Copy
    
    ;lea go_tempVec(a0),a1
    ;move.l #$20000,vec_speed(a1)
    ;add.b #128,vec_ang(a1)
    ;jsr VEC_GetDxDy
    
    ;add.l go_x(a0),d0
    ;move.l d0,go_oldx(a0)
    ;add.l go_y(a0),d1
    ;move.l d1,go_oldy(a0)
    
    
  
    
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
    jsr PATH_Test
    rts