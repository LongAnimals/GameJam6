

InitState_GameComplete:
    move.l #ExitState_GameComplete,sysg_scene_exitFunc

	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
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
    bsr GameComplete_InitSprites
    
    ifd IS_GAME_COFFEE
	bsr Title_ShowHighScore
	bsr Title_ShowScore
	endif
    
    move #0,RamPalettes ; bg color

	move #REG_WINDOW_HPOS|0,VDP_CONTROL
	move #REG_WINDOW_VPOS|0,VDP_CONTROL

	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #UpdateState_GameComplete,g_game_loopaddr
	move.l #UpdateStateVBL_GameComplete,g_game_vbladdr


	jsr SOUND_Init
	move #SONG_FIREBIRD,d0
    ifd IS_GAME_UNDERGROUND
    move #SONG_FIREBIRD,d0
    endif
    ifd IS_GAME_COFFEE
    move #SONG_COFFEEBACH,d0
    endif
    ifd IS_GAME_TD
    move #TD_SONG,d0
    endif
    jsr MUSIC_InitSong
	rts



GameComplete_InitSprites:

        
    move #IMAGEASSET_UNDERGROUND_GAMECOMPLETESCREEN,d0
    ifd IS_GAME_UNDERGROUND
    move #IMAGEASSET_UNDERGROUND_GAMECOMPLETESCREEN,d0
    endif
	jsr IMAGE_ShowStaticImagePlaneB
	
    move #FONT_UNDERGROUND_PAL1,g_font_index
    move #1,g_font_palette_index
    jsr FONT_InitAll
        

; ui palette
;    lea SPRPAL_UI,a0
;    move #1,d0
;    jsr FADE_CopySinglePaletteToSource

    rts
    

UpdateState_GameComplete:
	jsr UTILS_GetRandWord
	
    move.l #0,g_scroll_x
    move.l #0,g_scroll_y

    jsr HolScreenBase_UpdateGameObjects
    jsr SPRITE_UpdateFromGOManager_UIScreen

	cmp.b #FADE_INFO_STOP,g_fade+fade_info
	bne .notexited
    move g_pad0,d5
   
    btst #pad_button_a,d5
    beq .notexited

    move.l #InitState_Title,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut

.notexited:
	rts

ExitState_GameComplete:
    move.l #0,g_game_vbladdr
    move.l #0,g_game_loopaddr
    move.l #0,sysg_music+sgmusic_callbackfunc
    VDP_DISABLE_HBL
    rts

UpdateStateVBL_GameComplete:
	jsr SCROLL_UpdatePositionsVDP
	jsr SPRITE_CopySpriteListToVRAM_DMA
	jsr FADE_Update
	rts


