
    
Racing_InitHud:
    move.l #.update,go_onUpdate(a0)
    GO_SET_INVISIBLE
    rts
.update:
    bsr HolHud_UpdateBestLapTime
    bsr HolHud_UpdateLapTime
    bsr HolHud_UpdateDebug
    rts
    
HolHud_UpdateLapTime:
    VRAM_GETCHARPOS_WINDOW 32,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea .time,a0
    jsr FONT_DrawText
    
    VRAM_GETCHARPOS_WINDOW 32,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea g_laptime,a2
    moveq #0,d0
    move.b laptime_minutes(a2),d0
    jsr FONT_DrawNumber_W_1

    VRAM_GETCHARPOS_WINDOW 34,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea g_laptime,a2
    moveq #0,d0
    move.b laptime_seconds(a2),d0
    jsr FONT_DrawNumber_W_2

    VRAM_GETCHARPOS_WINDOW 37,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea g_laptime,a2
    moveq #0,d0
    move.b laptime_subs(a2),d0
    jsr FONT_DrawNumber_W_2

    rts
.time: TEXTSTR 'x:xx.xx'

HolHud_UpdateBestLapTime:
    VRAM_GETCHARPOS_WINDOW 32-5,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea .time,a0
    jsr FONT_DrawText
    
    VRAM_GETCHARPOS_WINDOW 32,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea g_bestlaptime,a2
    moveq #0,d0
    move.b laptime_minutes(a2),d0
    jsr FONT_DrawNumber_W_1

    VRAM_GETCHARPOS_WINDOW 34,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea g_bestlaptime,a2
    moveq #0,d0
    move.b laptime_seconds(a2),d0
    jsr FONT_DrawNumber_W_2

    VRAM_GETCHARPOS_WINDOW 37,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea g_bestlaptime,a2
    moveq #0,d0
    move.b laptime_subs(a2),d0
    jsr FONT_DrawNumber_W_2

    rts
.time: TEXTSTR 'BEST x:xx.xx'


HolHud_UpdateDebug:
    ifnd IS_DEBUG_MODE
    rts
    endif
    
    VRAM_GETCHARPOS_WINDOW 0,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l DebugArea,d0
    jsr FONT_DrawHex_L

    VRAM_GETCHARPOS_WINDOW 0,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l DebugArea+4,d0
    jsr FONT_DrawHex_L

    VRAM_GETCHARPOS_WINDOW 0,2
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l DebugArea+8,d0
    jsr FONT_DrawHex_L
    
    rts
    
        ; player vel and ang, and pos
        VRAM_GETCHARPOS_WINDOW 0,0
        jsr VDP_BuildAndSetVRAMWriteAddress
        move DebugArea+2,d0
        jsr FONT_DrawHex_B

        VRAM_GETCHARPOS_WINDOW 0,1
        jsr VDP_BuildAndSetVRAMWriteAddress
        move DebugArea+2,d0
        jsr FONT_DrawHex_B
        VRAM_GETCHARPOS_WINDOW 0,2
        jsr VDP_BuildAndSetVRAMWriteAddress
        move DebugArea+4,d0
        jsr FONT_DrawHex_B

    rts
    
    ;VRAM_GETCHARPOS_WINDOW 0,0
    ;jsr VDP_BuildAndSetVRAMWriteAddress
    ;move #16,d0
    ;jsr FONT_ClearSpace
    
    ;VRAM_GETCHARPOS_WINDOW 0,4
    ;jsr VDP_BuildAndSetVRAMWriteAddress
    ;move #8,d0
    ;jsr FONT_ClearSpace
    
    ; player vel and ang, and pos
    VRAM_GETCHARPOS_WINDOW 0,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l g_player,a2
    lea go_moveVec(a2),a2
    move vec_ang(a2),d0
    jsr FONT_DrawHex_W

    VRAM_GETCHARPOS_WINDOW 5,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l g_player,a2
    lea go_moveVec(a2),a2
    move vec_speed(a2),d0
    jsr FONT_DrawHex_L

    VRAM_GETCHARPOS_WINDOW 14,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l g_player,a2
    move go_x(a2),d0
    jsr FONT_DrawHex_W

    VRAM_GETCHARPOS_WINDOW 19,0
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l g_player,a2
    move go_y(a2),d0
    jsr FONT_DrawHex_W
    
    
    VRAM_GETCHARPOS_WINDOW 0,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    move.l g_player,a2
    lea go_path(a2),a2
    move path_currentIndex(a2),d0
    jsr FONT_DrawHex_B

    VRAM_GETCHARPOS_WINDOW 3,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    move.l g_player,a2
    lea go_path(a2),a2
    move path_crossType(a2),d0
    jsr FONT_DrawHex_B


    VRAM_GETCHARPOS_WINDOW 8,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    move.l g_player,a2
    lea go_path(a2),a2
    move path_x(a2),d0
    jsr FONT_DrawHex_W
    

    VRAM_GETCHARPOS_WINDOW 13,1
    jsr VDP_BuildAndSetVRAMWriteAddress
    move.l g_player,a2
    lea go_path(a2),a2
    move path_y(a2),d0
    jsr FONT_DrawHex_W

    VRAM_GETCHARPOS_WINDOW 0,2
    jsr VDP_BuildAndSetVRAMWriteAddress
    move.l g_player,a2
    lea go_path(a2),a2
    move cpath_numNodes(a2),d0
    jsr FONT_DrawHex_W

    VRAM_GETCHARPOS_WINDOW 6,2
    jsr VDP_BuildAndSetVRAMWriteAddress
    move.l g_player,a2
    move go_lapIndex(a2),d0
    jsr FONT_DrawHex_W

    VRAM_GETCHARPOS_WINDOW 0,3
    jsr VDP_BuildAndSetVRAMWriteAddress
    lea PlaybackData,a2
    move record_currentIndex(a2),d0
    jsr FONT_DrawHex_W

    tst.l g_playerGhost
    beq .noghost
    
    VRAM_GETCHARPOS_WINDOW 14,4
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l g_playerGhost,a2
    move go_x(a2),d0
    jsr FONT_DrawHex_W

    VRAM_GETCHARPOS_WINDOW 19,4
    jsr VDP_BuildAndSetVRAMWriteAddress
    moveq #0,d0
    move.l g_playerGhost,a2
    move go_y(a2),d0
    jsr FONT_DrawHex_W
    

.noghost


    rts


