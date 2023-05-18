
TEMPLATE_ExitState:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts



TEMPLATE_InitState:
	jsr Globals_ClearAll
    jsr MEM_Init
    jsr MEM_AllocForGame 
	jsr ClearVRAM
	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
	move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL
    jsr VDP_ClearBorderColor
	jsr SCROLL_ResetHardware
	
    move #REG_WINDOW_HPOS|0,VDP_CONTROL
    ;move #REG_WINDOW_VPOS|28,VDP_CONTROL
    
    ;if IS_DEBUG_MODE
    ;move #REG_WINDOW_VPOS|4,VDP_CONTROL
    ;endif

	
    move.l #sprdefs2,sysg_sprites_baseaddr
    move.l #sprdefs2+2,sysg_sprites_baseaddr2


	move.l #0,g_post_init_func
	move.l #0,g_game_loopaddr
	move.l #0,g_game_vbladdr

	move #0,g_vram_currentpos	; for loading in 

	jsr FADE_ClearAll


    move #1,d0
    jsr LEVEL_InitData

	jsr SOUND_Init
    move #0,sysg_current_music

	jsr SCROLL_SetNormalPlanes
	jsr SCROLL_CreateDMATables


    jsr TEMPLATE_InitForGame
    jsr TEMPLATE_InitForLevel

    bsr TEMPLATE_InitWorldAndLevelStuff_GFX
    bsr TEMPLATE_InitWorldAndLevelStuff_Mem

    jsr SCROLL_FillScrollA
    jsr SCROLL_FillScrollB

    
    
	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #TEMPLATE_UpdateGame,g_game_loopaddr
	move.l #TEMPLATE_UpdateVBL,g_game_vbladdr

    

    rts
    
TEMPLATE_InitForGame:
    rts
    

TEMPLATE_InitForLevel:
    rts

TEMPLATE_InitWorldAndLevelStuff_GFX:
    jsr TEMPLATE_InitVDPForLevel
    jsr SpriteCache_BuildFrames
    rts
    

TEMPLATE_InitWorldAndLevelStuff_Mem:
    bsr TEMPLATE_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    jsr TEMPLATE_InitGOs
    rts
    
TEMPLATE_InitGOs:
    lea TEMPLATE_InitCursor,a1
    jsr GOManager_SpawnGameObject_FX
   
    rts
    
    
TEMPLATE_InitCursor:
    SETSPR SPRITE_TD_PAL0
    move #0,go_frame(a0)
    move #10*16,go_x(a0)
    move #8*16,go_y(a0)

    move.l go_x(a0),go_tox(a0)
    move.l go_y(a0),go_toy(a0)

    move.l #.update,go_onUpdate(a0)
.update:
    move g_pad0_pressed,d0

    btst #pad_button_left,d0
    beq .noL
    sub #16,go_tox(a0)
.noL:
    btst #pad_button_right,d0
    beq .noR
    add #16,go_tox(a0)
.noR:

    btst #pad_button_up,d0
    beq .noU
    sub #16,go_toy(a0)
.noU:
    btst #pad_button_down,d0
    beq .noD
    add #16,go_toy(a0)
.noD:
    
    btst #pad_button_a,d0
    beq .noA
    
.noA:

    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #3,d0
    add.l d0,go_x(a0)

    move.l go_toy(a0),d0
    sub.l go_y(a0),d0
    asr.l #3,d0
    add.l d0,go_y(a0)
    rts
        
    
    
TEMPLATE_PlayMusic:
    move #0,d0
    jsr MUSIC_InitSong
    rts

    
    
TEMPLATE_InitVDPForLevel:
    jsr ClearVRAM

    lea SPRPAL_TD_Pal0,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource

    lea SPRPAL_Whiteout,a0
    move #1,d0
    jsr FADE_CopySinglePaletteToSource
    jsr FADE_Update

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP

    bsr TEMPLATE_InitBackgroundTiles
    
	;move #FONT_CUBEDROID_FONT0,g_font_index
	;move #1,g_font_palette_index
    ;jsr FONT_Init
    ;jsr FONT_LoadPalette
    ;jsr FONT_LoadTiles


    lea .sprites,a5
.spritesLoop:
    move (a5)+,d0
    bmi .finishedSprites
    jsr UNITYTOOL_LoadSingleSprite
    bra .spritesLoop
.finishedSprites:

	move.l #SPRITE_DEBUG,d0
	jsr UNITYTOOL_LoadSingleSprite
    rts
    
.sprites:
    dc.w SPRITE_TD_PAL0
    dc.w -1


TEMPLATE_InitBackgroundTiles:

    move g_vram_currentpos,g_vram_bg

    
    move.l sysg_levelInfo+levelinfo_palette0,a0 
    move 2(a0),d0
    lea 4(a0),a0
    jsr FADE_CopySinglePaletteToSource

    move.l sysg_levelInfo+levelinfo_palette1,a0 
    move 2(a0),d0
    lea 4(a0),a0
    jsr FADE_CopySinglePaletteToSource
    
    
    move.l sysg_levelInfo+levelinfo_tileData0,a4	;tile start     
    move.w imagecells_numcells(a4),d6
    move g_vram_currentpos,d0
    move.w d0,g_vram_bg
    add d6,g_vram_currentpos
    move.w	g_vram_bg,d1
    lsl #5,d1
    jsr	VDP_BuildVRAMWriteAddress
    move.l a4,a0
    jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags

    move.l sysg_levelInfo+levelinfo_tileData1,a4	;tile start     
    move.w imagecells_numcells(a4),d6
    move g_vram_currentpos,d0
    move.w d0,g_vram_fg
    add d6,g_vram_currentpos
    move.w	g_vram_fg,d1
    lsl #5,d1
    jsr	VDP_BuildVRAMWriteAddress
    move.l a4,a0
    jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags
    

    ;move g_vram_currentpos,g_vram_fg
    ;move #IMAGEASSET_MAP01_TOP,g_image_index
    ;move.l #NEWIMAGEGROUP,g_image_groupbase
    ;jsr IMAGE_LoadPalettes
    ;jsr IMAGE_LoadChars

; set up addr of tiles in ROM
	move g_image_index,d0
	move.l g_image_groupbase,a0	
	jsr UNITYTOOL_GetImageData
	move.l image_cells(a0),g_hol_romTileMapAddr

    rts


TEMPLATE_UpdateGame:
    tst.l g_stackwatch
    beq .ok
    DEBUG_HALT
.ok

    jsr UTILS_GetRandWord
    bsr TEMPLATE_UpdateGame_UpdateGlobals
    bsr TEMPLATE_UpdateGame_Normal        
    rts
    
TEMPLATE_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
TEMPLATE_UpdateGame_UpdateGlobals:
	add.l #$1000,g_timer008		; update timers. They all need to pass through all integers, so nothing higher than 1
	add.l #$2000,g_timer0175
	add.l #$4000,g_timer025
	add.l #$8000,g_timer05
	add.l #$10000,g_timer1
	move.l g_timer1,d0
	lsr.l #1,d0
	move.l d0,g_timer1_shr1 
	lsr.l #1,d0
	move.l d0,g_timer1_shr2 
	lsr.l #1,d0
	move.l d0,g_timer1_shr3 
	lsr.l #1,d0
	move.l d0,g_timer1_shr4 
	lsr.l #1,d0
	move.l d0,g_timer1_shr5 
	lsr.l #1,d0
	move.l d0,g_timer1_shr6 
	lsr.l #1,d0
	move.l d0,g_timer1_shr7 
	lsr.l #1,d0
	move.l d0,g_timer1_shr8 
	
	move.l g_timer1,d0
	and.l #$10000,d0
	move.l d0,g_timer1_and1

	move.l g_timer1,d0
	and.l #$30000,d0
	move.l d0,g_timer1_and3

	move.l g_timer1,d0
	and.l #$70000,d0
	move.l d0,g_timer1_and7

    move g_timer1_shr4,d0
    and #1,d0
    move d0,g_timer1_shr4_and1

    move g_timer1_shr5,d0
    and #1,d0
    move d0,g_timer1_shr5_and1
	
    rts

    

TEMPLATE_UpdateGame_Normal:
    bsr Racing_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    jsr GOManager_Update
	jsr SPRITE_UpdateFromGOManager_Racing
	BORDER 5
    jsr Scroll_UpdateEdgesA
    jsr Scroll_UpdateEdgesB
	BORDER 0
    rts


TEMPLATE_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr TEMPLATE_UpdateScrollRegisters

    jsr Scroll_DumpEdgesToVDPA
    jsr Scroll_DumpEdgesToVDPB
    
    ; these work much better in VBL
    ;bsr Scroll_UpdateDrawBackgroundTilesToVRAM_A
	rts

;-------------------------------------------------------------


TEMPLATE_UpdateScrollRegisters:

	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_FULL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL
    
    AUTOINC 2
; hscroll
	
	move g_scroll_x,d0
	add g_screenshake_x,d0
	;and #15,d0
	neg d0
	
	SCROLL_START_WRITE_XPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
    AUTOINC 2
    move g_scroll_y,d0
    add g_screenshake_y,d0
    and #255,d0
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
	rts

    
    

TEMPLATE_InitPlayer:
    rts