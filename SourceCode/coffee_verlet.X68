
;-------------------------------------------------------------------------
;VERLET STUFF
;

    clrso
vp_x so.l 1
vp_y so.l 1
vp_oldx so.l 1
vp_oldy so.l 1
vp_fixed so.w 1
vp_structsize so.b 0

VERLET_GRAVITY equ $4000

COF_VERLET_MAXPOINTS equ 16
COF_VERLET_MAXCONNECTORS equ 16

;verletConnector
    clrso
vc_p0_addr so.l 1
vc_p1_addr so.l 1
vc_len  so.l 1
vc_structsize so.b 1

; verletSim
    clrso
vs_numPoints so.w 1
vs_numConnectors so.w 1
vs_structsize so.b 1


COFFEE_VERLET_TEST_SPACING equ 4

v set COFFEE_VERLET_TEST_SPACING
Coffee_VerletData_Fixes:
    dc.b 1,0,0,0,0,0,0,0
    dc.b 0,0,0,0,0,0,0,1
Coffee_VerletData_Points:
    dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dc.w 9999
    
Coffee_VerletData_Connectors:
    dc.w 0,1, 1,2, 2,3, 3,4, 4,5, 5,6, 6,7
    dc.w 7,8, 8,9, 9,10, 10,11, 11,12, 12,13, 13,14, 14,15
    dc.w 9999

Coffee_InitEnemy_Verlet_InitData:
    move.l g_cof+cof_m_verletPoints,a1      ;lea VerletPoints,a1
    lea Coffee_VerletData_Points,a2
    lea Coffee_VerletData_Fixes,a3
    lea g_cof+cof_verletSim,a4        ; lea VerletSim,a4
    move #0,vs_numPoints(a4)
    move #0,vs_numConnectors(a4)
    
    move.l go_x(a0),d0
    move.l go_y(a0),d1
.vertlp:
    move (a2)+,d0
    move (a2)+,d1
    cmp #9999,d0
    beq .doneVerts
    
    add #1,vs_numPoints(a4)

    moveq #0,d2
    move.w go_x(a0),d2
    add d0,d2
    swap d2
    move.l d2,vp_x(a1)
    move.l d2,vp_oldx(a1)

    moveq #0,d2
    move.w go_y(a0),d2
    add d1,d2
    swap d2
    move.l d2,vp_y(a1)
    move.l d2,vp_oldy(a1)
    
    moveq #0,d2
    move.b (a3)+,d2
    move d2,vp_fixed(a1)

    lea vp_structsize(a1),a1
    bra .vertlp
    
.doneVerts:
    
;---
    move.l g_cof+cof_m_verletConnectors,a1      ;lea VerletConnectors,a1
    lea Coffee_VerletData_Connectors,a2
    
.conLoop:
    move (a2)+,d5
    move (a2)+,d6
    cmp #9999,d5
    beq .doneConnectors
    
    add #1,vs_numConnectors(a4)
        
    move d5,d0
    mulu #vp_structsize,d0
    move.l g_cof+cof_m_verletPoints,a5  ;lea VerletPoints,a5
    add d0,a5
    move.l a5,vc_p0_addr(a1)

    move d6,d0
    mulu #vp_structsize,d0
    move.l g_cof+cof_m_verletPoints,a5  ;lea VerletPoints,a5
    add d0,a5
    move.l a5,vc_p1_addr(a1)
    
    move #COFFEE_VERLET_TEST_SPACING,vc_len(a1)
    lea vc_structsize(a1),a1
    
    bra .conLoop
.doneConnectors:
    rts

; d0,d1
; d2 vert index
Verlet_MovePoint:
    PUSHALL
    move.l g_cof+cof_m_verletPoints,a1  ;lea VerletPoints,a1
    mulu #vp_structsize,d2
    add d2,a1
    add.l d0,vp_x(a1)
    add.l d1,vp_y(a1)
    POPALL
    rts

; d2 vert index
Verlet_ClearFixed:
    PUSHALL
    move.l g_cof+cof_m_verletPoints,a1  ;lea VerletPoints,a1
    mulu #vp_structsize,d2
    add d2,a1
    move #0,vp_fixed(a1)
    POPALL
    rts

; d2 vert index
Verlet_SetFixed:
    PUSHALL
    move.l g_cof+cof_m_verletPoints,a1  ;lea VerletPoints,a1
    mulu #vp_structsize,d2
    add d2,a1
    move #1,vp_fixed(a1)
    POPALL
    rts

; d0,d1
Verlet_MoveFixedPoints:
    PUSHALL
    move.l g_cof+cof_m_verletPoints,a1  ;lea VerletPoints,a1
    move g_cof+cof_verletSim+vs_numPoints,d7
    subq #1,d7
    
.lp:
    tst vp_fixed(a1)
    beq .notfixed
    add.l d0,vp_x(a1)
    add.l d1,vp_y(a1)
.notfixed:
    lea vp_structsize(a1),a1
    dbra d7,.lp
    
    POPALL
    rts

Coffee_InitEnemy_VerletTest:
    SETSPR SPRITE_COFFEE_PAL0
    move #SPRFRAME_COFFEE_PAL0_BEANBULLET,go_frame(a0)

    move #250,go_x(a0)
    move #100,go_y(a0)
    move go_x(a0),go_startx(a0)
    move go_y(a0),go_starty(a0)

    move.l #.first,go_onUpdate(a0)
    move.l #Coffee_Enemy_VerletTest_Render,go_onRender(a0)
    rts
.first:
    bsr Coffee_InitEnemy_Verlet_InitData
    move.l #.update,go_onUpdate(a0)
.update:
    ;move.l g_player,a1
    ;move.l go_dx(a1),d0
    ;move.l go_dy(a1),d1
    ;move #7,d2
    ;bsr Verlet_MovePoint
    ;bra .no

    move.l go_x(a0),go_oldx(a0)    
    move.l go_y(a0),go_oldy(a0)    


    
    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #4,d0
    add.l d0,go_x(a0)

    move.l go_toy(a0),d0
    sub.l go_y(a0),d0
    asr.l #4,d0
    add.l d0,go_y(a0)

    move.l go_x(a0),d0
    sub.l go_oldx(a0),d0    
    move.l go_y(a0),d1
    sub.l go_oldy(a0),d1
    move #15,d2
    bsr Verlet_MovePoint
    
    sub #1,go_timer(a0)
    bgt .no

    move #10,go_timer(a0)

    move.l g_player,a1
    jsr UTILS_GetRandWordFast
    and #63,d0
    ;sub #64,d0
    ;add go_startx(a0),d0
    move go_x(a1),d0
    add #30+90,d0
    move d0,go_tox(a0)

    jsr UTILS_GetRandWordFast
    and #63,d0
    sub #32,d0
    ;add go_starty(a0),d0
    add go_y(a1),d0
    move d0,go_toy(a0)

.no
    
    BORDER 22
    bsr Coffee_Enemy_Verlet_CalculateVerts
    bsr Coffee_Enemy_Verlet_CalculateConnectors
    BORDER 0
    rts

Coffee_Enemy_VerletTest_Render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    move.l g_cof+cof_m_verletPoints,a1      ;lea VerletPoints,a1
    move g_cof+cof_verletSim+vs_numPoints,d4    ; VerletSim+vs_numPoints,d4
    subq #1,d4
.lp:
    move.w vp_x(a1),d5
    move.w vp_y(a1),d6
    bsr .render_doone
    lea vp_structsize(a1),a1
    dbra d4,.lp

    rts
.render_doone:
    move go_frame(a0),sprbuf_frame(a5)
    
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts    
    
Coffee_Enemy_Verlet_CalculateVerts:
    move.l d7,-(sp)

; update 
    move.l g_cof+cof_m_verletPoints,a1  ;lea VerletPoints,a1
    move g_cof+cof_verletSim+vs_numPoints,d7    ;move VerletSim+vs_numPoints,d7
    subq #1,d7
    move.l #VERLET_GRAVITY,d4
.vertlp:
    tst vp_fixed(a1)
    bne .skipvert
    move.l vp_x(a1),d5
    move.l vp_y(a1),d6
    
    move.l d5,d2 
    move.l d6,d3
    sub.l vp_oldx(a1),d2
    sub.l vp_oldy(a1),d3
    
    add.l d2,vp_x(a1)
    add.l d4,d3                     ; gravity
    add.l d3,vp_y(a1)
    
    move.l d5,vp_oldx(a1)
    move.l d6,vp_oldy(a1)
.skipvert:
    lea vp_structsize(a1),a1
    dbra d7,.vertlp

    move.l (sp)+,d7

    rts
    
Coffee_Enemy_Verlet_CalculateConnectors:
    move.l d7,-(sp)
    move.l g_cof+cof_m_verletConnectors,a1     ;lea VerletConnectors,a1
    move g_cof+cof_verletSim+vs_numConnectors,d7    ; move VerletSim+vs_numConnectors,d7
    subq #1,d7
.connectorLp:
    move.l vc_p0_addr(a1),a2        ; point0
    move.l vc_p1_addr(a1),a3        ; point1

    move.l vp_x(a2),d0
    add.l vp_x(a3),d0
    asr.l #1,d0
    move.l d0,a4                    ; a4 centre x
    move.l vp_y(a2),d0
    add.l vp_y(a3),d0
    asr.l #1,d0
    move.l d0,a5                    ; a5 centre y
    
    ; normalize.
    moveq #0,d2             ; flip flags
    moveq #0,d3             ; flip flags
    move.l vp_x(a3),d0
    sub.l vp_x(a2),d0
    bge .normalize_flipx
    neg.l d0
    moveq #-1,d2
.normalize_flipx:    
    move.l vp_y(a3),d1
    sub.l vp_y(a2),d1
    bge .normalize_flipy
    neg.l d1
    moveq #-1,d3
.normalize_flipy:    

; shr 14    
    rol.l #2,d0
    swap d0
    rol.l #2,d1
    swap d1
    
    cmp #63,d0
    ble .ok1
    move #63,d0
.ok1:
    cmp #63,d1
    ble .ok2
    move #63,d1
.ok2:
    
    
    move.l a5,-(sp)
    lsl #2,d0       ;3
    lsl #2,d1       ;3
    lsl #6,d1   ; 64 x64 table
    lea NormalizeVectorTable,a5
    add d0,a5
    add d1,a5
    move.w (a5)+,d0
    move.w (a5),d1
    move.l (sp)+,a5
    
    mulu #COFFEE_VERLET_TEST_SPACING/2*2,d0        ; /2 for half distance. *2 because [1.0] is stored as [32768] in the table, so needs 1 shift left
    mulu #COFFEE_VERLET_TEST_SPACING/2*2,d1
    
    eor.l d2,d0         ; flip back X if needed
    eor.l d3,d1         ; flip back Y if needed
    
    ; d0 / d1 is normalized len multiplied by len / 2
    
    tst vp_fixed(a2)
    bne .skip_vert_0
    move.l a4,d2
    sub.l d0,d2
    move.l d2,vp_x(a2)
    move.l a5,d2
    sub.l d1,d2
    move.l d2,vp_y(a2)
.skip_vert_0: 

    tst vp_fixed(a3)
    bne .skip_vert_1
    move.l a4,d2
    add.l d0,d2
    move.l d2,vp_x(a3)
    move.l a5,d2
    add.l d1,d2
    move.l d2,vp_y(a3)
.skip_vert_1: 
    
    
    lea vc_structsize(a1),a1
    dbra d7,.connectorLp
    
    
    move.l (sp)+,d7
    rts