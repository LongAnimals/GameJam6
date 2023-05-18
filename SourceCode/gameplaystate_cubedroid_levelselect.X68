

EndState_CDLS:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts


InitState_CDLS:
	jsr Globals_ClearAll
    jsr MEM_Init
    jsr MEM_Init
    jsr MEM_AllocForGame_CubeDroid 
	jsr ClearVRAM
	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
	move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL
    jsr VDP_ClearBorderColor
	jsr SCROLL_ResetHardware
	
    move #REG_WINDOW_HPOS|0,VDP_CONTROL
	
    move.l #sprdefs2,sysg_sprites_baseaddr
    move.l #sprdefs2+2,sysg_sprites_baseaddr2


	move.l #0,g_post_init_func
	move.l #0,g_game_loopaddr
	move.l #0,g_game_vbladdr

	move #0,g_vram_currentpos	; for loading in 

	jsr FADE_ClearAll

	jsr SOUND_Init
    move #0,sysg_current_music

;    move #SONG_CUBEDROID_A,d0    
;    jsr MUSIC_InitSong


	jsr SCROLL_SetNormalPlanes

    move #0,g_scroll_x
    move #0,g_scroll_y


    bsr CDLS_InitWorldAndLevelStuff_GFX
    bsr CDLS_InitWorldAndLevelStuff_Mem
    
    lea CD_InitCursor,a1
    jsr GOManager_SpawnGameObject_FX

    bsr CDLS_InitLocks
    
	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #CDLS_Update,g_game_loopaddr
	move.l #CDLS_UpdateVBL,g_game_vbladdr
    rts


CDLS_InitLocks:
    move #0,d6
.lp:
    move.l d6,-(sp)
    lea CD_InitLock,a1
    jsr GOManager_SpawnGameObject_Treasure
    move.l (sp)+,d6
    
    moveq #0,d0
    move d6,d0
    divu #6,d0
    move d0,gocd_cursor_y(a1)
    swap d0
    move d0,gocd_cursor_x(a1)

    move d6,gocd_levelindex(a1)

    add #1,d6
    cmp #36,d6
    blt .lp
    rts    
    
CDLS_UpdateVBL:	
    move #0,RamPalettes    
    jsr FADE_Update	
    jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr CD_UpdateScrollRegisters
    rts
    
CDLS_Update:
    jsr UTILS_GetRandWord
    bsr CD_UpdateGame_UpdateGlobals

    jsr GOManager_Update
	jsr SPRITE_UpdateFromGOManager_Racing
    rts

CDLS_InitWorldAndLevelStuff_GFX:
    jsr ClearVRAM

    lea SPRPAL_CubeDroidBG,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP

    lea .sprites,a5
.spritesLoop:
    move (a5)+,d0
    bmi .finishedSprites
    jsr UNITYTOOL_LoadSingleSprite
    bra .spritesLoop
.finishedSprites:

	move.l #SPRITE_DEBUG,d0
	jsr UNITYTOOL_LoadSingleSprite
	
    move #FONT_CUBEDROID_FONT0,g_font_index
    move #2,g_font_palette_index
    jsr FONT_Init
    jsr FONT_LoadPalette
    jsr FONT_LoadTiles

    move g_vram_currentpos,g_vram_bg

    move #IMAGEASSET_CUBEDROID_LEVELSELECT,g_image_index
    move.l #NEWIMAGEGROUP,g_image_groupbase
    jsr IMAGE_LoadCharsB
    jsr IMAGE_LoadMapB
    jsr IMAGE_LoadPalettes


    rts
    
.sprites:
    dc.w SPRITE_CUBEDROID_LEVELSELECT
    dc.w -1

    

CDLS_InitWorldAndLevelStuff_Mem:
    bsr CD_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    rts
    

CD_InitLock:
    SETSPR SPRITE_CUBEDROID_LEVELSELECT
    move #1,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:

    bsr CD_LevelSelect_GetScreenPosFromCursorPos
    move go_tox(a0),go_x(a0)
    move go_toy(a0),go_y(a0)

    move gocd_levelindex(a0),d0
    bsr CD_IsLevelUnlocked
    add #1,d0
    move d0,go_frame(a0)

    rts
    
;level in d0
CD_IsLevelUnlocked:
    tst d0
    beq .yes
    add d0,d0
    lea sysg_cd+cd_bestStepsTable,a1
    move (a1,d0),d0
    bne .yes
.no:
    moveq #1,d0
    rts
.yes:
    moveq #0,d0
    rts
    
    
    
    
gocd_cursor_x equ go_word0
gocd_cursor_y equ go_word1
gocd_levelindex equ go_word2
CD_InitCursor:
    move #0,gocd_cursor_x(a0)
    move #0,gocd_cursor_y(a0)
    move.l #0,go_tox(a0)
    move.l #0,go_toy(a0)
    move.l #0,go_x(a0)
    move.l #0,go_y(a0)
    SETSPR SPRITE_CUBEDROID_LEVELSELECT
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move g_pad0_pressed,d0

    btst #pad_button_left,d0
    beq .noL
    move #-1,d0
    move #0,d1
    bsr CD_MoveCursor
    bra .movebutton_done
.noL:
    btst #pad_button_right,d0
    beq .noR
    move #1,d0
    move #0,d1
    bsr CD_MoveCursor
    bra .movebutton_done
.noR:

    btst #pad_button_up,d0
    beq .noU
    move #0,d0
    move #-1,d1
    bsr CD_MoveCursor
    bra .movebutton_done
.noU:
    btst #pad_button_down,d0
    beq .noD
    move #0,d0
    move #1,d1
    bsr CD_MoveCursor
    bra .movebutton_done
.noD:

    
    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #2,d0
    add.l d0,go_x(a0) 

    move.l go_toy(a0),d0
    sub.l go_y(a0),d0
    asr.l #2,d0
    add.l d0,go_y(a0) 

.movebutton_done:

    bsr CD_LevelSelect_GetScreenPosFromCursorPos
    
    move g_pad0_pressed,d0
    btst #pad_button_a,d0
    beq .noA
    
    move gocd_cursor_y(a0),d0
    move d0,sysg_cd+cd_backgroundIndex
    mulu #6,d0
    add  gocd_cursor_x(a0),d0
    move d0,sysg_cd+cd_levelIndex

    
    bsr EndState_CDLS
    move.l #InitState_CD2,sysg_next_screen_addr

.noA:
    rts


CD_LevelSelect_GetScreenPosFromCursorPos:
    move gocd_cursor_x(a0),d0
    mulu #40,d0
    add #64,d0
    move d0,go_tox(a0)
    move #$8000,go_tox+2(a0)
    move gocd_cursor_y(a0),d0
    mulu #24,d0
    add #32,d0
    move d0,go_toy(a0)
    move #$8000,go_toy+2(a0)
    rts

CD_MoveCursor:
    add d0,gocd_cursor_x(a0)
    
    cmp #0,gocd_cursor_x(a0)
    bge .no_l
    move #5,gocd_cursor_x(a0)
    bra .donex
.no_l:
    cmp #5,gocd_cursor_x(a0)
    ble .no_r
    move #5,gocd_cursor_x(a0)
    bra .donex
.no_r:
.donex:


    add d1,gocd_cursor_y(a0)
    cmp #0,gocd_cursor_y(a0)
    bge .no_u
    move #5,gocd_cursor_y(a0)
    bra .doney
.no_u:
    cmp #5,gocd_cursor_y(a0)
    ble .no_d
    move #5,gocd_cursor_y(a0)
    bra .doney
.no_d:
.doney:
    rts

