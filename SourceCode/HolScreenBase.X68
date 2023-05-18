; HolScreens are static screens with their own input and display, but used from the main game, instead of separate states

    clrso
holscreen_scroll_x so.l 1
holscreen_scroll_y so.l 1
holscreen_structsize so.b 0


HolScreen_EnterScreen macro \1
    move.l #\1,d0
    jsr HolScreen_DoEnterScreen
    endm


HolScreen_DoEnterScreen:
    move.l d0,g_nextHolScreenInitAddr
    move #1,g_holScreen_mode
    rts

; called at end of main loop so we can set up new screen after all is done
HolScreen_GlobalUpdate:
    tst g_holScreen_mode
    beq .r
    cmp #1,g_holScreen_mode
    beq .startfade
    rts
.startfade:
    move.l #0,g_game_loopaddr
    move.l #HolUpdatFadeVBL,g_game_vbladdr

    ;jsr HolFadeOutForScreen
    move #2,g_holScreen_mode
.r  rts


HolUpdatFadeVBL:	
	jsr FADE_Update
    rts	

    
HolScreen_SetupReturnValues:
    lea g_holscreen,a1
    move.l holscreen_scroll_x(a1),g_scroll_x
    move.l holscreen_scroll_y(a1),g_scroll_y
    
    ;jsr HolInitFromStaticScreen
    ;move.l #HolUpdateGame,g_game_loopaddr
    ;move.l #HolUpdateVBL,g_game_vbladdr
    rts

HolScreen_GlobalExit:
    ;jsr HolFadeOutFromScreenToGame    
	rts
    
HolScreenBase_GlobalInit:
    move.l #0,g_game_loopaddr
    move.l #0,g_game_vbladdr

    lea g_holscreen,a1
    move.l g_scroll_x,holscreen_scroll_x(a1)
    move.l g_scroll_y,holscreen_scroll_y(a1)

    move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
    move #REG_MODE4|REGMASK_MODE4_H32|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
    move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL

    jsr ClearVRAM

    jsr GOManager_GetList_UIScreen
    jsr GoManager_ResetList
    
    jsr SPRITE_InitVdpRamSpriteList
    
    jsr FADE_ClearAll
    
    move #0,g_vram_currentpos
    rts    


HolScreenBase_UpdateGameObjects:
    jsr GOManager_GetList_UIScreen
    move.l golist_active_list_addr(a3),a1
    move golist_num_active(a3),d7
	bra .skip
.loop:

	move.l (a1)+,a0  
	move.l a1,-(sp)
	move.l go_onUpdate(a0),a1
	jsr (a1)
	move.l (sp)+,a1
.skip:
    dbra d7,.loop
    

    rts


    
HolScreenBase_UpdateVBL:
	jsr HolScreenBase_UpdateScroll
	jsr SPRITE_CopySpriteListToVRAM_DMA
	jsr FADE_Update
	rts


HolScreenBase_UpdateScroll:
.nocustom:

	lea VDP_DATA,a0
	move #0,d0	

    SCROLL_START_WRITE_XPOS
	move.w d0,(a0)    
	move.w d0,(a0)
	SCROLL_START_WRITE_YPOS
	move d0,(a0)
	move d0,(a0)

	rts

