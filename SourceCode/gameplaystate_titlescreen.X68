
VersionText: dc.b	'      Version: 0.1',ETX
    align 2
VersionText_COFFEE: dc.b	'      Version: 0.6',ETX
    align 2
VersionText_UNDERGROUND: dc.b	'      Version: 0.6',ETX
    align 2
VersionText_TD: dc.b	'      Version: 0.8',ETX
    align 2


InitState_Title:
	VDP_DISABLE_HBL
   	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
   	move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL
    
    ;jsr VDP_ClearBorderColor 
	jsr Globals_ClearAll
	jsr MEM_Init
	jsr MEM_AllocForScreens 

	move #0,g_vram_currentpos

    jsr ClearVRAM
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
	jsr SCROLL_ResetHardware

	bsr FADE_ClearAll
	jsr SCROLL_SetNormalPlanes

    jsr Image_AddBlankCharacterToVDP

	;move #IMAGEASSET_TITLESCREEN,d0
    ifd IS_GAME_UNDERGROUND
    move #IMAGEASSET_UNDERGROUND_TITLESCREEN,d0
    endif
    ifd IS_GAME_COFFEE
    move #IMAGEASSET_COFFEE_TITLESCREEN,d0
    endif
    ifd IS_GAME_TD
    move #IMAGEASSET_TD_TITLESCREEN,d0
    endif

	jsr IMAGE_ShowStaticImagePlaneB


	move #FONT_UNDERGROUND_PAL1,g_font_index
	move #1,g_font_palette_index
	jsr FONT_InitAll

	move #REG_WINDOW_HPOS|0,VDP_CONTROL
	move #REG_WINDOW_VPOS|0,VDP_CONTROL

	move.w #0,sysg_debugpanel+debugpanel_cursorpos
    DEBUGPANEL_SET_WINDOWADDR VDPADDR_SCROLL_A	
    
    
    ifnd TEST_SOUND
    DEBUGPANEL_SET_OPTIONSADDR Title_Options
    endif	
	
;    jsr SRAM_LoadGame
	
	jsr DEBUGPANEL_InitForUI
	jsr DEBUGPANEL_Redraw
	
    ifd IS_GAME_UNDERGROUND
	bsr Title_ShowHighScore
	bsr Title_ShowVersion
	bsr Title_ShowScore
	endif

    ifd IS_GAME_COFFEE
	bsr Title_ShowHighScore
	bsr Title_ShowScore
	bsr Title_ShowVersion
	endif

    ifd IS_GAME_TD
	bsr Title_ShowHighScoreTD
	bsr Title_ShowScore
	bsr Title_ShowVersion
	endif

	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #UpdateState_Title,g_game_loopaddr
	move.l #UpdateStateVBL_Title,g_game_vbladdr
    
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


Title_ShowScore:
    move.l #VDPADDR_SCROLL_A+(21*128)+(13*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    lea .text,a0
    jsr FONT_DrawText

    move.l #VDPADDR_SCROLL_A+(21*128)+(24*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move #8,d0
    jsr FONT_ClearSpace

    move.l #VDPADDR_SCROLL_A+(21*128)+(24*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move sysg_score+2,d0 
    jsr FONT_DrawNumber_W_Variable
    rts
.text: dc.b	'Score: ',ETX
    align 2



Title_ShowHighScore:

    move.l #VDPADDR_SCROLL_A+(20*128)+(13*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    lea .text,a0
    jsr FONT_DrawText

    move.l #VDPADDR_SCROLL_A+(20*128)+(24*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move #8,d0
    jsr FONT_ClearSpace

    move.l #VDPADDR_SCROLL_A+(20*128)+(24*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move sysg_highscore+2,d0 
    jsr FONT_DrawNumber_W_Variable
    rts
.text: dc.b	'High Score: ',ETX
    align 2
    
Title_TestHighScore:
    move.l sysg_score,d0
    cmp.l sysg_highscore,d0
    ble .no
    move.l d0,sysg_highscore    
.no:
    rts
    
Title_ShowVersion:
    move.l #VDPADDR_SCROLL_A+(26*128)+(7*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    lea VersionText,a0
    ifd IS_GAME_COFFEE
    lea VersionText_COFFEE,a0
    endif
    ifd IS_GAME_UNDERGROUND
    lea VersionText_UNDERGROUND,a0
    endif
    ifd IS_GAME_TD
    lea VersionText_TD,a0
    endif
    jsr FONT_DrawText
    rts

    ifd IS_GAME_TD
Title_Options:
	dc.w 3,MENUFLAGS_USE_START
	
	dc.w 12,16
	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_Start,Title_Options_Text_Start

	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_CreditsScreen,Title_Options_Text_CreditsScreen
    
    dc.b MENUOPTION_BUTTON,0
    dc.l 0,Title_Options_ButtonPressed_HelpScreen,Title_Options_Text_HelpScreen
    endif

    ifd IS_GAME_COFFEE
    
Title_Options:
	dc.w 3,MENUFLAGS_USE_START
	
	dc.w 12,13
	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_Start,Title_Options_Text_Start

	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_CreditsScreen,Title_Options_Text_CreditsScreen
    
    dc.b MENUOPTION_BUTTON,0
    dc.l 0,Title_Options_ButtonPressed_HelpScreen,Title_Options_Text_HelpScreen
    
    endif

    ifd IS_GAME_UNDERGROUND
Title_Options:
    ifd IS_FINAL_GAME
	dc.w 2,MENUFLAGS_USE_START
	else
	dc.w 3,MENUFLAGS_USE_START
	endif
	
	dc.w 12,12
	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_Start,Title_Options_Text_Start

	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_CreditsScreen,Title_Options_Text_CreditsScreen

	dc.b MENUOPTION_TOGGLE,0
	dc.l sysg_cheatmode,0,Title_Options_Text_CheatMode

	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_HelpScreen,Title_Options_Text_HelpScreen
	;dc.b MENUOPTION_BYTE_TEXT,0
	;dc.l sysg_difficulty,Title_Difficulty_TextList,Title_Options_Text_Difficulty
	dc.b MENUOPTION_BUTTON,0
	dc.l 0,Title_Options_ButtonPressed_ClearSaveGame,Title_Options_Text_ClearSaveGame
	
	endif
	
Title_Difficulty_TextList
	dc.w 4
	dc.l .0, .1, .2, .3
.0: dc.b	'Normal     ',ETX
.1: dc.b	'Hard       ',ETX
.2: dc.b	'Insane     ',ETX
.3: dc.b	'IMPOSSIBLE?',ETX
	align 2
	
	
Title_Options_Text_Start	dc.b	'Start',ETX
Title_Options_Text_CheatMode dc.b 'Cheat Mode',ETX

Title_Options_Options	dc.b	'Options',ETX
Title_Options_TestSound dc.b	'TEST SOUND FX',ETX
Title_Options_TestMusic dc.b	'TEST MUSIC',ETX
Title_Options_TestMusicVolume dc.b	'MUSICVOLUME',ETX
Title_Options_Text_Difficulty	dc.b	'Difficulty:',ETX
Title_Options_Text_HelpScreen	dc.b	'Help',ETX
Title_Options_Text_CreditsScreen dc.b 'Credits',ETX
Title_Options_Text_Practice dc.b 'Practice',ETX
Title_Options_Text_Intro dc.b 'Intro',ETX
Title_Options_Text_Achievements dc.b 'Achievements',ETX
Title_Options_Text_ClearSaveGame dc.b 'CLEAR SAVED GAME',ETX

	align 2
	
Title_Options_ButtonPressed_ClearSaveGame:
	jsr SRAM_ClearSaveGame
	
	PUSHALL
	jsr DEBUGPANEL_Redraw
	bsr Title_ShowHighScore
	POPALL
	rts

Title_Options_ButtonPressed_HelpScreen:
	bsr Title_StopForFadeout
	FADE_START_OUT .done
	rts
.done:
	bsr ExitState_Title
	move.l #InitState_HelpScreen,sysg_next_screen_addr
	rts

Title_Options_ButtonPressed_CreditsScreen:
	bsr Title_StopForFadeout
	FADE_START_OUT .done
	rts
.done:
	bsr ExitState_Title
	move.l #InitState_Credits,sysg_next_screen_addr
	rts

Title_Options_ButtonPressed_Intro:
	bsr Title_StopForFadeout
	FADE_START_OUT .done
	rts
.done:
	bsr ExitState_Title
	;move.l #InitState_Intro,sysg_next_screen_addr
	rts

Title_Options_ButtonPressed_Achievements:
	bsr Title_StopForFadeout
	FADE_START_OUT .done
	rts
.done:
	bsr ExitState_Title
	;move.l #InitState_Achievements,sysg_next_screen_addr
	rts



    

Title_Options_ButtonPressed_Start:	
    jsr SRAM_SaveGame
    move #0,sysg_levelIndex
    move.l #0,sysg_score

	bsr Title_StopForFadeout
	FADE_START_OUT .done
	rts
.done:
	move.l #0,g_game_loopaddr
	bsr ExitState_Title
	
    ifd IS_GAME_UNDERGROUND
    move.l #UG_InitState,sysg_next_screen_addr
    endif
    ifd IS_GAME_COFFEE
    move.l #Coffee_InitState,sysg_next_screen_addr
    endif
    ifd IS_GAME_TD
    move.l #TD_InitState,sysg_next_screen_addr
    endif

	;move.l #InitState_CharSelect,sysg_next_screen_addr
	rts




UpdateState_Title:
	jsr UTILS_GetRandWord
	jsr DEBUGPANEL_Update

	cmp.b #FADE_INFO_STOP,g_fade+fade_info
	bne .notexited
    ;move g_pad0,d5
   
    ;btst #pad_button_a,d5
    ;beq .notexited

	

.notexited:
	rts



Title_StopForFadeout:
    ;VDP_DISABLE_HBL
    ;move.l #0,g_game_loopaddr
    ;move.w #0,sysg_debugpanel_redrawflags
    ;move #IMAGEASSET_Screens_title_fg,d0
    ;jsr IMAGE_ShowStaticImage
    rts

ExitState_Title:
    move.l #0,g_game_vbladdr
    move.l #0,g_game_loopaddr
    move.l #0,sysg_music+sgmusic_callbackfunc

    VDP_DISABLE_HBL

    ;add.l #1,sysg_vblcount
    ;jsr WaitVBlank

    rts


UpdateStateVBL_Title:
	bsr TitleScreen_UpdateGameObjectsVBL
	jsr FADE_Update
	
	jsr DEBUGPANEL_UpdateVBL
	
;	jsr ColorBars_HBL_InitForFrame

	rts


;-------------------------------------------------------------

TitleScreen_UpdateGameObjectsVBL:
	jsr SCROLL_UpdatePositionsVDP
	jsr SPRITE_CopySpriteListToVRAM_DMA
	
	rts







Title_ShowHighScoreTD:

    move.l #VDPADDR_SCROLL_A+(22*128)+(13*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    lea .text,a0
    jsr FONT_DrawText

    move.l #VDPADDR_SCROLL_A+(22*128)+(24*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move #8,d0
    jsr FONT_ClearSpace

    move.l #VDPADDR_SCROLL_A+(22*128)+(24*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move sysg_highscore+2,d0 
    jsr FONT_DrawNumber_W_Variable
    rts
.text: dc.b	'High Score: ',ETX
    align 2
