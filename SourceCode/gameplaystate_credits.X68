

InitState_Credits:
    move.l #ExitState_Credits,sysg_scene_exitFunc
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

	jsr FADE_ClearAll
	jsr SCROLL_SetNormalPlanes
    
    jsr GOManager_Setup_Game
    bsr Credits_InitSprites

	move #REG_WINDOW_HPOS|0,VDP_CONTROL
	move #REG_WINDOW_VPOS|0,VDP_CONTROL

	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #UpdateState_Credits,g_game_loopaddr
	move.l #UpdateStateVBL_Credits,g_game_vbladdr

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


UpdateState_Credits:
	jsr UTILS_GetRandWord
	
    move.l #0,g_scroll_x
    move.l #0,g_scroll_y

	cmp.b #FADE_INFO_STOP,g_fade+fade_info
	bne .notexited
    move g_pad0,d5
   
    btst #pad_button_a,d5
    beq .notexited

    move.l #InitState_Title,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut


.notexited:
	rts

Credits_InitSprites:

	move #IMAGEASSET_UNDERGROUND_CREDITSSCREEN,d0
	
	ifd IS_GAME_COFFEE
	move #IMAGEASSET_COFFEE_CREDITSSCREEN,d0
	endif
	ifd IS_GAME_TD
	move #IMAGEASSET_TD_CREDITSSCREEN,d0
	endif
	
	jsr IMAGE_ShowStaticImagePlaneB
    jsr IMAGE_LoadMap       ; shove it on to plane A also 
    rts


ExitState_Credits:
    move.l #0,g_game_vbladdr
    move.l #0,g_game_loopaddr
    move.l #0,sysg_music+sgmusic_callbackfunc
    VDP_DISABLE_HBL
    rts

UpdateStateVBL_Credits:
	jsr SCROLL_UpdatePositionsVDP
	jsr SPRITE_CopySpriteListToVRAM_DMA
	jsr FADE_Update
	rts


