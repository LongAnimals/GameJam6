


InitState_CutScene:
	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
	move #REG_MODE4|REGMASK_MODE4_H32|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
	move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL
    
    jsr VDP_ClearBorderColor 
    jsr Globals_ClearAll
    jsr MEM_Init
    jsr MEM_AllocForScreens 

    move #0,g_vram_currentpos

    jsr ClearVRAM
    jsr SPRITE_InitVdpRamSpriteList
    jsr SPRITE_CopySpriteListToVRAM
    jsr SCROLL_ResetHardware

    move.l #sprdefs2,sysg_sprites_baseaddr
    move.l #sprdefs2+2,sysg_sprites_baseaddr2

	bsr FADE_ClearAll
	jsr SCROLL_SetNormalPlanes
	
    jsr GOManager_Setup_Game
    bsr CutScene_InitSprites
    
	move #REG_WINDOW_HPOS|0,VDP_CONTROL
	move #REG_WINDOW_VPOS|0,VDP_CONTROL

	FADE_SETVALUE 0
	FADE_START_IN 0

    lea CutSceneState_Stop,a1
    jsr CutScene_SetStopFunction
    jsr InitCutscene

	move.l #UpdateState_CutScene,g_game_loopaddr
	move.l #UpdateStateVBL_CutScene,g_game_vbladdr


	jsr SOUND_Init
    move #0,sysg_current_music
    jsr Racing_PlayMusic
	rts

    


CutSceneState_Stop:	
    ;jsr SRAM_SaveGame

	;bsr CutScene_StopForFadeout
	FADE_START_OUT .done
	rts
.done:
	move.l #0,g_game_loopaddr
	bsr ExitState_CutScene
    lea sysg_cutscene,a3
    move.l cs_sysg_next_screen_ptr(a3),sysg_next_screen_addr

; test through them all    
    ;add #1,sysg_test_cutscene_index
    ;lea Cutscene_Addresses,a0
    ;move sysg_test_cutscene_index,d0
    ;lsl #2,d0
    ;add d0,a0
    ;move.l (a0),a0
    ;lea HolInitState,a1
    ;jsr CutScene_SetUp 
    ;move.l #InitState_CutScene,sysg_next_screen_addr
	rts

UpdateState_CutScene:

    jsr Racing_UpdateGame_UpdateGlobals
	jsr UTILS_GetRandWord
    ;jsr HolUpdateScreenShake

    jsr UpdateCutScene
	
	move #0,g_scroll_x
	move #0,g_scroll_y
	
    jsr HolScreenBase_UpdateGameObjects
    jsr SPRITE_UpdateFromGOManager_UIScreen

	cmp.b #FADE_INFO_STOP,g_fade+fade_info
	bne .notexited
.notexited:
	rts

ExitState_CutScene:
    move.l #0,g_game_vbladdr
    move.l #0,g_game_loopaddr
    move.l #0,sysg_music+sgmusic_callbackfunc
    VDP_DISABLE_HBL
    rts


UpdateStateVBL_CutScene:
	;jsr HolScrollCB
	jsr SPRITE_CopySpriteListToVRAM_DMA
	jsr FADE_Update
	rts


