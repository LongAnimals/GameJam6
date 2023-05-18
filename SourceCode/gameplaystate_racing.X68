
EndState_Racing:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts



InitState_Racing:
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
    
    ifd IS_DEBUG_MODE
    move #REG_WINDOW_VPOS|4,VDP_CONTROL
    endif

	
    move.l #sprdefs2,sysg_sprites_baseaddr
    move.l #sprdefs2+2,sysg_sprites_baseaddr2


	move.l #0,g_post_init_func
	move.l #0,g_game_loopaddr
	move.l #0,g_game_vbladdr

	move #0,g_vram_currentpos	; for loading in 

	jsr FADE_ClearAll


    move #LEVEL_DRIVINGMAP1,d0
    jsr LEVEL_InitData

	jsr SOUND_Init
    move #0,sysg_current_music
    ;jsr Racing_PlayMusic

	jsr SCROLL_SetNormalPlanes
	jsr SCROLL_CreateDMATables


    jsr Racing_InitForGame

    jsr Racing_InitForLevel
    

    bsr Racing_InitWorldAndLevelStuff_GFX
    bsr Racing_InitWorldAndLevelStuff_Mem

    move.l g_player,a0
    jsr HolUpdateScrollFromPlayer
    jsr HolLimitScrollEdges
    
    jsr SCROLL_FillScrollA
    jsr SCROLL_FillScrollB

    
    
	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #Racing_UpdateGame,g_game_loopaddr
	move.l #Racing_UpdateVBL,g_game_vbladdr
    rts
    
Racing_InitForGame:
    rts
    

Racing_InitForLevel:
    rts
    

Racing_InitWorldAndLevelStuff_Mem:
    bsr Racing_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM

    lea Racing_InitDebugRotator,a1
    jsr GOManager_SpawnGameObject_FX
    


    ;lea Racing_Debug_InitPathMarker,a1
    ;jsr GOManager_SpawnGameObject_Treasure

;    lea Racing_Debug_InitCompSprTest,a1
;    jsr GOManager_SpawnGameObject_Treasure

    lea Racing_InitGhostPlayer,a1
    jsr GOManager_SpawnGameObject_FX


    move #SPRDEF_PLAYERSTART,d0
    bsr Spawner_GetAllOfType
    lea Scratchpad+1024,a5
    move (a5)+,d7
    beq .noaicars
    subq #1,d7
.lp:
    move.l a5,-(sp)
    tst d7      ; is last?
    bne .notplayer
    lea Racing_InitPlayer,a1
    jsr GOManager_SpawnGameObject_Car
    bra .notai
.notplayer:
    lea Racing_InitAICar,a1
    jsr GOManager_SpawnGameObject_Car
.notai:
    move.l (sp)+,a5
    
    move.l (a5)+,a4
    move spawner_x(a4),go_x(a1)
    move spawner_y(a4),go_y(a1)
    move spawner_rot(a4),d0
    move.b d0,go_facingVec+vec_ang(a1)
    move.b d0,go_moveVec+vec_ang(a1)
    dbra d7,.lp
.noaicars:

    lea Racing_InitHud,a1
    jsr GOManager_SpawnGameObject_Treasure

    ;bsr Racing_InitSpawners
    rts
    

    clrso
spawntab_type       so.l 1
spawntab_spawnFunc  so.l 1
spawntab_initFunc   so.l 1
spawntab_filler     so.l 1
    
    clrso
spawner_x           so.w 1
spawner_y           so.w 1
spawner_type        so.w 1
spawner_subtype     so.w 1
spawner_rot         so.w 1
spawner_spawnmethod so.w 1
spawner_fillers     so.w 2
spawner_structsize  so.w 0
    
SpawnTab:
    dc.l SPRDEF_PLAYERSTART,0,0,0
    dc.l SPRDEF_PICKUP,GOManager_SpawnGameObject_Treasure,Racing_InitPickup,0
    
Racing_InitSpawners:
    move.l sysg_levelInfo+levelinfo_spawners,a5
    move (a5)+,d7
    beq .exit
    subq #1,d7
.lp:
    move spawner_type(a5),d0
    lsl #4,d0
    lea SpawnTab,a4
    add d0,a4
    move.l spawntab_initFunc(a4),a1
    move.l spawntab_spawnFunc(a4),d0
    beq .skip
    move.l d0,a2
    jsr (a2)
    move spawner_x(a5),go_x(a1)
    move spawner_y(a5),go_y(a1)
    
.skip:
    lea spawner_structsize(a5),a5
    dbra d7,.lp

.exit:
    rts
    
; d0 = type
; Scratchpad = number of items,  and list of addresses in the spawner table
Spawner_GetAllOfType:

    lea Scratchpad+1024,a3
    move #0,(a3)
    lea 2(a3),a4
    
    move.l sysg_levelInfo+levelinfo_spawners,a5
    move (a5)+,d7
    beq .exit
    subq #1,d7
.lp:
    cmp spawner_type(a5),d0
    bne .skip
    move.l a5,(a4)+
    add #1,(a3) 
.skip:
    lea spawner_structsize(a5),a5
    dbra d7,.lp
.exit:
    rts    

Racing_InitWorldAndLevelStuff_GFX:
    jsr Racing_InitVDPForLevel

    jsr SpriteCache_BuildFrames
    rts


    
Racing_PlayMusic:
    move #0,d0
    jsr MUSIC_InitSong
    rts

    
Racing_InitVDPForLevel:
    jsr ClearVRAM

    ;lea SPRPAL_Car01,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource
    jsr FADE_Update

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP

    bsr Racing_InitBackgroundTiles
    
	move #FONT_CUBEDROID_FONT0,g_font_index
	move #1,g_font_palette_index
    jsr FONT_Init
    jsr FONT_LoadPalette
    jsr FONT_LoadTiles


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
    ;dc.w SPRITE_CAR01
    ;dc.w SPRITE_CAR02
    ;dc.w SPRITE_CAR01_GHOST
    ;dc.w SPRITE_GAMEOVERINGAME
    ;dc.w SPRITE_MONSTERS
    ;dc.w SPRITE_ROTATOR
    ;dc.w SPRITE_ROTATOR2
    dc.w -1


Racing_InitBackgroundTiles:

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


Racing_UpdateGame:
    tst.l g_stackwatch
    beq .ok
    DEBUG_HALT
.ok

    jsr UTILS_GetRandWord
    bsr Racing_UpdateGame_UpdateGlobals
    bsr Racing_UpdateGame_Normal        
    rts
    
Racing_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
Racing_UpdateGame_UpdateGlobals:
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

    

Racing_UpdateGame_Normal:
    bsr Racing_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    jsr GOManager_Update
	jsr SPRITE_UpdateFromGOManager_Racing
	BORDER 22
	bsr Racing_CollideCars
	BORDER 33
	bsr Racing_CarSecondUpdate
	BORDER 5
    jsr Scroll_UpdateEdgesA
    jsr Scroll_UpdateEdgesB
	BORDER 0
    rts


Racing_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr Racing_UpdateScrollRegisters

    jsr Scroll_DumpEdgesToVDPA
    jsr Scroll_DumpEdgesToVDPB
    
    ; these work much better in VBL
    ;bsr Scroll_UpdateDrawBackgroundTilesToVRAM_A
	rts

;-------------------------------------------------------------


Racing_UpdateScrollRegisters:

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

    
SCREENSHAKE_MAX equ $20000
SCREENSHAKE_DECREASE_VEL equ $4000

Racing_UpdateScreenShake:

    move g_screenshake_timer,d0
    beq .no
    
    lea Racing_ScreenShakeTable,a0
    lsl #7,d0
    add d0,a0
    
    move g_timer1,d1
    and #63<<1,d1
    add d1,a0
    
    move (a0)+,g_screenshake_x
    move (a0)+,g_screenshake_y
    
    sub.l #SCREENSHAKE_DECREASE_VEL,g_screenshake_timer
    bge .ok
    move.l #0,g_screenshake_timer
.ok:
    rts
.no:
    move #0,g_screenshake_x
    move #0,g_screenshake_y
    rts
    
    
    
    
COL_RAD equ 10
Racing_CollideCars:


    jsr GOManager_GetList_Car
    move.l a3,a5
    move.l golist_active_list_addr(a5),a4

    move #6,d5  ; radius

    moveq #0,d7
.loop1:
    move.l (a4)+,a0
    move go_x(a0),d0
    move go_y(a0),d1
    
    
    move.l golist_active_list_addr(a5),a3
    moveq #0,d6
.loop2:
    move.l (a3)+,a1
    cmp d7,d6
    ble .skip

    
    move go_x(a1),d2
    sub d0,d2

    move go_y(a1),d3
    sub d1,d3
    
    cmp #COL_RAD,d2
    bgt .skip
    cmp #-COL_RAD,d2
    blt .skip
    
    
    cmp #COL_RAD,d3
    bgt .skip
    cmp #-COL_RAD,d3
    blt .skip
    

    move.l go_x(a1),d2
    sub.l go_x(a0),d2
    asr.l #3,d2
    sub.l d2,go_dx(a0)
    add.l d2,go_dx(a1)

    move.l go_y(a1),d2
    sub.l go_y(a0),d2
    asr.l #3,d2
    sub.l d2,go_dy(a0)
    add.l d2,go_dy(a1)

.skip:
    addq #1,d6
    cmp golist_num_active(a5),d6
    blt .loop2

    addq #1,d7
    cmp golist_num_active(a5),d7
    blt .loop1
    
    rts
    


Racing_CarSecondUpdate:

    jsr GOManager_GetList_Car
    move.l a3,a5
    move.l golist_active_list_addr(a5),a4

    moveq #0,d7
.loop1:
    move.l (a4)+,a0
    move.l go_onUpdate2(a0),d0
    beq .no
    move.l d0,a1
    jsr (a1)
.no:
    addq #1,d7
    cmp golist_num_active(a5),d7
    blt .loop1
    
    rts
    


; d0 = level index
LEVEL_InitData:
    mulu #levelexport_structsize,d0
    lea ExportedLevels+2,a0
    add d0,a0

    lea sysg_levelInfo,a1
    move.l (a0)+,levelinfo_tileMap0(a1)
    move.l (a0)+,levelinfo_tileData0(a1)
    move.l (a0)+,levelinfo_palette0(a1)
    move.l (a0)+,levelinfo_tileMap1(a1)
    move.l (a0)+,levelinfo_tileData1(a1)
    move.l (a0)+,levelinfo_palette1(a1)
    move.l (a0)+,levelinfo_collisionMap(a1)
    move.l (a0)+,levelinfo_surfaceMap(a1)
    move.l (a0)+,levelinfo_zones(a1)
    move.l (a0)+,levelinfo_spawners(a1)
    move.l (a0)+,levelinfo_spawnerData(a1)
    move.l (a0)+,levelinfo_paths(a1)
    move.l (a0)+,levelinfo_flowMap(a1)
    
    bsr LEVEL_InitData_SetStrides
    rts
    
LEVEL_InitData_SetStrides:
    lea sysg_levelInfo,a1
    move.l levelinfo_tileMap0(a1),a2
    move 2(a2),d0
    add d0,d0
    move d0,levelinfo_tileMap0_stride(a1)
    
    move.l levelinfo_tileMap1(a1),a2
    move 2(a2),d0
    add d0,d0
    move d0,levelinfo_tileMap1_stride(a1)

    move.l levelinfo_collisionMap(a1),a2
    move.l a2,a0
    move 0(a2),d0
    move d0,levelinfo_collisionMap_stride(a1)
    
    move.l levelinfo_surfaceMap(a1),a2
    move 0(a2),d0
    move d0,levelinfo_surfaceMap_stride(a1)
    
    rts
    
    
