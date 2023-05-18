;-------------------------------------------------------------------------
;VERLET STUFF
;

VERLET_USE_32 equ 1
;VERLET_USE_16 equ 1


    ifd VERLET_USE_32
;verletPoint
    clrso
vp_x so.l 1
vp_y so.l 1
vp_oldx so.l 1
vp_oldy so.l 1
vp_fixed so.w 1
vp_structsize so.b 0

VERLET_GRAVITY equ $2000
    endif

    ifd VERLET_USE_16
;verletPoint
    clrso
vp_x so.w 1
vp_y so.w 1
vp_oldx so.w 1
vp_oldy so.w 1
vp_fixed so.w 1
vp_structsize so.b 0


VERLET_GRAVITY equ $2000
    endif

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

VerletPoints        equ Scratchpad+1024
VerletConnectors    equ Scratchpad+1024+1024
VerletSim           equ Scratchpad+1024+1024+9120

VERLET_TEST_SPACING equ 12

v set VERLET_TEST_SPACING
VerletData_Fixes:
    dc.b 1,0,0,0,0,0,0,1
    dc.b 1,0,0,0,1,0,0,0
    dc.b 1,0,1,0,0,0,0,0
    dc.b 1,0,0,0,0,0,0,0


    ;dc.b 1,1,1,1, 1,0,0,0, 1,0,0,0, 1,0,0,0
VerletData_Points:

    dc.w 0,(v*0),0, (v*1),0, (v*2),0, (v*3),0, (v*4),0, (v*5),0, (v*6),0, (v*7)
    dc.w 40,(v*0),40, (v*1),40, (v*2),40, (v*3),40, (v*4),40, (v*5),40, (v*6),40, (v*7)
    dc.w 80,(v*0),80, (v*1),80, (v*2),80, (v*3),80, (v*4),80, (v*5),80, (v*6),80, (v*7)
    dc.w 120,(v*0),120, (v*1),120, (v*2),120, (v*3),120, (v*4),120, (v*5),120, (v*6),120, (v*7)
    dc.w 9999

    dc.w (v*0),(v*0), (v*1),(v*0), (v*2),(v*0), (v*3),(v*0)
    dc.w (v*0),(v*1), (v*1),(v*1), (v*2),(v*1), (v*3),(v*1)
    dc.w (v*0),(v*2), (v*1),(v*2), (v*2),(v*2), (v*3),(v*2)
    dc.w (v*0),(v*3), (v*1),(v*3), (v*2),(v*3), (v*3),(v*3)
    dc.w 9999
VerletData_Connectors:
    dc.w 0,1, 1,2, 2,3, 3,4, 4,5, 5,6, 6,7
    dc.w 08,09,09,10,10,11,11,12,12,13,13,14,14,15
    dc.w 16,17,17,18,18,19,19,20,20,21,21,22,22,23
    dc.w 24,25,25,26,26,27,27,28,28,29,29,30,30,31
    
    dc.w 9999
    
    dc.w 0,1, 1,2, 2,3
    dc.w 4,5, 5,6, 6,7
    dc.w 8,9, 9,10, 10,11
    dc.w 12,13, 13,14, 14,15
    
    dc.w 0,4, 4,8, 8,12
    dc.w 1,5, 5,9, 9,13
    dc.w 2,6, 6,10, 10,14
    dc.w 3,7, 7,11, 11,15
    dc.w 9999
    
    

Commando_InitEnemy_Verlet_InitData:
    lea VerletPoints,a1
    lea VerletData_Points,a2
    lea VerletData_Fixes,a3
    lea VerletSim,a4
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
    lea VerletConnectors,a1
    lea VerletData_Connectors,a2
    
.conLoop:
    move (a2)+,d5
    move (a2)+,d6
    cmp #9999,d5
    beq .doneConnectors
    
    add #1,vs_numConnectors(a4)
        
    move d5,d0
    mulu #vp_structsize,d0
    lea VerletPoints,a5
    add d0,a5
    move.l a5,vc_p0_addr(a1)

    move d6,d0
    mulu #vp_structsize,d0
    lea VerletPoints,a5
    add d0,a5
    move.l a5,vc_p1_addr(a1)
    
    move #VERLET_TEST_SPACING,vc_len(a1)
    lea vc_structsize(a1),a1
    
    bra .conLoop
.doneConnectors:

    ;move vs_numConnectors(a4),DebugArea
    ;DEBUG_SHOWMEM_DEBUGAREA

    rts

; d0,d1
Verlet_MoveFixedPoints:
    PUSHALL
    lea VerletPoints,a1
    move VerletSim+vs_numPoints,d7
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

Commando_InitEnemy_VerletTest:
    bsr Commando_InitEnemyBase
    move.l #.first,go_onUpdate(a0)
    SETSPR SPRITE_COMMANDO_PAL0
    move.l #Commando_Enemy_VerletTest_Render,go_onRender(a0)
    move #0,go_frame(a0)
    rts
.first:
    bsr Commando_InitEnemy_Verlet_InitData
    move.l #.update,go_onUpdate(a0)
.update:
    BORDER 33
    
    
    move g_pad0,d0
    btst #pad_button_left,d0
    beq .notl
    move.l #-2<<16,d0
    move.l #0,d1
    bsr Verlet_MoveFixedPoints
.notl:
    btst #pad_button_right,d0
    beq .notr
    move.l #2<<16,d0
    move.l #0,d1
    bsr Verlet_MoveFixedPoints
.notr:
    btst #pad_button_up,d0
    beq .noty
    move.l #0,d0
    move.l #-2<<16,d1
    bsr Verlet_MoveFixedPoints
.noty:
    btst #pad_button_down,d0
    beq .notd
    move.l #0,d0
    move.l #2<<16,d1
    bsr Verlet_MoveFixedPoints
.notd:
    
    
    bsr Commando_Enemy_Verlet_CalculateVerts
    bsr Commando_Enemy_Verlet_CalculateConnectors
    BORDER 0
    rts

Commando_Enemy_VerletTest_Render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    lea VerletPoints,a1
    move VerletSim+vs_numPoints,d4
    subq #1,d4
.lp:
    move.w vp_x(a1),d5
    move.w vp_y(a1),d6
    bsr .render_doone
    lea vp_structsize(a1),a1
    dbra d4,.lp

    rts
.render_doone:
    move #SPRFRAME_COMMANDO_PAL0_PICKUP1,sprbuf_frame(a5)
    
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts    
    
Commando_Enemy_Verlet_CalculateVerts:
    move.l d7,-(sp)

; update 
    lea VerletPoints,a1
    move VerletSim+vs_numPoints,d7
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
    
Commando_Enemy_Verlet_CalculateConnectors:
    move.l d7,-(sp)
    lea VerletConnectors,a1
    move VerletSim+vs_numConnectors,d7
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
    
    
    lsl #2,d0       ;3
    lsl #2,d1       ;3
    lsl #6,d1   ; 64 x64 table
    lea NormalizeVectorTable,a6
    add d0,a6
    add d1,a6

    move.w (a6)+,d0
    move.w (a6),d1
    
    mulu #VERLET_TEST_SPACING/2*2,d0        ; /2 for half distance. *2 because [1.0] is stored as [32768] in the table, so needs 1 shift left
    mulu #VERLET_TEST_SPACING/2*2,d1
    
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
    
