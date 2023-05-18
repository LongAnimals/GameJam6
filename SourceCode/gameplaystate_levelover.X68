

InitState_LevelOver:
    move.l #ExitState_LevelOver,sysg_scene_exitFunc
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
    bsr LevelOver_InitSprites
    
    move #0,RamPalettes

	move #REG_WINDOW_HPOS|0,VDP_CONTROL
	move #REG_WINDOW_VPOS|0,VDP_CONTROL

	FADE_SETVALUE 0
	FADE_START_IN 0

    ifd IS_GAME_UNDERGROUND
	bsr Title_ShowHighScore
	bsr Title_ShowScore
	endif

    ifd IS_GAME_TD
    bsr Title_ShowHighScore
	bsr Title_ShowScore
	endif


	move.l #UpdateState_LevelOver,g_game_loopaddr
	move.l #UpdateStateVBL_LevelOver,g_game_vbladdr


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



LevelOver_InitSprites:

        
    move #IMAGEASSET_UNDERGROUND_LEVELCOMPLETESCREEN,d0
    ifd IS_GAME_UNDERGROUND
    move #IMAGEASSET_UNDERGROUND_LEVELCOMPLETESCREEN,d0
    endif
    ifd IS_GAME_TD
    move #IMAGEASSET_TD_LEVELCOMPLETESCREEN,d0
    endif
	jsr IMAGE_ShowStaticImagePlaneB        

    move #FONT_UNDERGROUND_PAL1,g_font_index
    move #1,g_font_palette_index
    jsr FONT_InitAll

    rts
    

UpdateState_LevelOver:
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

	ifd IS_GAME_TD
	jsr TD_NextLevel
	move.l #TD_InitState,sysg_next_screen_addr_after_fade
	endif
	
	ifd IS_GAME_UNDERGROUND
	bsr UG_NextLevel
	cmp #UNDERGROUND_NUM_LEVELS,sysg_levelIndex
	bge .underground_done
	move.l #UG_InitState,sysg_next_screen_addr_after_fade
    bra .underground_done1	
.underground_done:	
    move.l #InitState_GameComplete,sysg_next_screen_addr_after_fade
.underground_done1:	
	endif

    jsr SCENETRANSITION_FadeOut

.notexited:
	rts


ExitState_LevelOver:
    move.l #0,g_game_vbladdr
    move.l #0,g_game_loopaddr
    move.l #0,sysg_music+sgmusic_callbackfunc
    VDP_DISABLE_HBL
    rts

UpdateStateVBL_LevelOver:
	jsr SCROLL_UpdatePositionsVDP
	jsr SPRITE_CopySpriteListToVRAM_DMA
	jsr FADE_Update
	rts


