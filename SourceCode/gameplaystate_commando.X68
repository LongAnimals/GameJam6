
EndState_Commando:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts



InitState_Commando:
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


    move #LEVEL_COMMANDO,d0
    jsr LEVEL_InitData

	jsr SOUND_Init
    move #0,sysg_current_music
    move #0,d0
    jsr MUSIC_InitSong


	jsr SCROLL_SetNormalPlanes
	jsr SCROLL_CreateDMATables


    jsr Commando_InitForGame
    jsr Commando_InitForLevel

    bsr Commando_InitWorldAndLevelStuff_GFX
    bsr Commando_InitWorldAndLevelStuff_Mem

    move.l g_player,a0
    jsr HolUpdateScrollFromPlayer
    jsr HolLimitScrollEdges
    
    jsr SCROLL_FillScrollA
    jsr SCROLL_FillScrollB

    
    
	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #Commando_UpdateGame,g_game_loopaddr
	move.l #Commando_UpdateVBL,g_game_vbladdr

    

    rts
    
Commando_InitForGame:
    rts
    

Commando_InitForLevel:
    rts
    

Commando_InitWorldAndLevelStuff_Mem:
    bsr Commando_UpdateGame_InitGlobals

    bsr Commando_ClearZoneTrackerTable
    
	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    bsr Commando_SpawnStuff
    rts
    
    
GOManager_SpawnGameObject_Commando_Player:
    jmp GOManager_SpawnGameObject_Car

GOManager_SpawnGameObject_Commando_Shootable:
    jmp GOManager_SpawnGameObject_Treasure

GOManager_SpawnGameObject_Commando_PlayerBullet:
    jmp GOManager_SpawnGameObject_PlayerBullet

GOManager_SpawnGameObject_Commando_CollideWithPlayer:
    jmp GOManager_SpawnGameObject_EnemyBullet

GOManager_SpawnGameObject_Commando_FX:
    jmp GOManager_SpawnGameObject_FX
    
Commando_SpawnTab:
    SPAWNTABENTRY SPRDEF_COMMANDO_PLAYER,0,GOManager_SpawnGameObject_Commando_Player,Commando_InitPlayer
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ROCK,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitRock
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_STATIONARY_SHOOTING,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_Stationary_Shooting
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_STATIONARY_GRENADE,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_Stationary_Grenade
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_RUNRIGHT,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_RunRight
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_RUNLEFT,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_RunLeft
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_FOLLOWPATH,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_FollowPath
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_CHASE,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_Chase
    ;SPAWNTABENTRY SPRDEF_COMMANDO_PICKUP_WEAPON,0,GOManager_SpawnGameObject_Commando_CollideWithPlayer,Commando_InitPickup_Weapon
    ;SPAWNTABENTRY SPRDEF_COMMANDO_PICKUP_GOLD,0,GOManager_SpawnGameObject_Commando_CollideWithPlayer,Commando_InitPickup_Gold
    ;SPAWNTABENTRY SPRDEF_COMMANDO_GENERATOR,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitGenerator
    ;SPAWNTABENTRY SPRDEF_COMMANDO_ENEMY_PATROLZONE,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_PatrolZone
    
    ;SPAWNTABENTRY SPRDEF_COMMANDO_TANK,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_VerletTest     ;Commando_InitEnemy_Tank
    SPAWNTABENTRY SPRDEF_COMMANDO_TANK,0,GOManager_SpawnGameObject_Commando_Shootable,Commando_InitEnemy_IK     ;Commando_InitEnemy_Tank
    SPAWNTABEND
    
Commando_SpawnStuff:
    move.l sysg_levelInfo+levelinfo_spawners,a5
    move.l sysg_levelInfo+levelinfo_spawnerData,a6
    moveq #0,d6     ; spawn index
    lea 2(a6),a6
    move (a5)+,d7
    beq .exit
    subq #1,d7
.lp:
    cmp #SPAWNMETHOD_EXTERNALSPAWN,spawner_spawnmethod(a5)
    beq .skip_entry
    bsr Commando_FindSpawnEntryFromSpawner
    cmp.l #0,a4
    beq .skip_entry
    move.l cspawntab_initFunc(a4),a1
    move.l cspawntab_spawnFunc(a4),d0
    beq .skip_entry
    move.l d0,a2
    move.l a5,g_currentSpawnListAddr        ; for use in init function
    move.l a6,g_currentSpawnDataAddr        ; for use in init function
    jsr (a2)
    move spawner_x(a5),go_x(a1)
    move spawner_y(a5),go_y(a1)
    move d6,go_spawnTableIndex(a1)
    
.skip_entry:
    lea spawner_structsize(a5),a5
    addq #1,d6
    lea 4(a6),a6
    dbra d7,.lp

.exit:
    rts
        
; d0 is spawn table index 
Commando_SpawnExternal:
    PUSHALL
    
    move.l sysg_levelInfo+levelinfo_spawners,a5
    lea 2(a5),a5
    move d0,d1
    mulu #spawner_structsize,d1
    add d1,a5
    
    move.l sysg_levelInfo+levelinfo_spawnerData,a6
    lea 2(a6),a6
    lsl #2,d0
    add d0,a6
    
    bsr Commando_FindSpawnEntryFromSpawner
    cmp.l #0,a4
    beq .skip_entry
    
    ;DEBUG_HALT
    
    move.l cspawntab_initFunc(a4),a1
    move.l cspawntab_spawnFunc(a4),d0
    beq .skip_entry
    move.l d0,a2
    move.l a5,g_currentSpawnListAddr        ; for use in init function
    move.l a6,g_currentSpawnDataAddr        ; for use in init function
    jsr (a2)
    move spawner_x(a5),go_x(a1)
    move spawner_y(a5),go_y(a1)
    move d6,go_spawnTableIndex(a1)
.skip_entry:
    POPALL
    rts

; d0 is spawn table index 
Commando_SpawnByType:
    PUSHALL
    
    move.l a0,a5            ; original GO
    
    moveq #0,d1
    bsr Commando_FindSpawnEntryD0D1
    
    cmp.l #0,a4
    beq .skip_entry

    move.l cspawntab_initFunc(a4),a1
    move.l cspawntab_spawnFunc(a4),d0
    beq .skip_entry
    move.l d0,a2
    jsr (a2)
    move go_x(a5),go_x(a1)
    move go_y(a5),go_y(a1)
.skip_entry:
    POPALL
    rts
    
; d0 = type / d1 = subtype
; returns a4 for spawner entry. 0 if none found
Commando_FindSpawnEntryD0D1:
    lea Commando_SpawnTab,a4
.lp:
    cmp #-1,cspawntab_type(a4)
    beq .end
    cmp cspawntab_type(a4),d0
    bne .no
    cmp cspawntab_subtype(a4),d1
    bne .no
    rts
.no:
    lea cspawntab_structsize(a4),a4
    bra .lp
.end:
    move.l #0,a4
    rts
    
    
; a5 is spawner entry
; returns a4 for spawner entry. 0 if none found
Commando_FindSpawnEntryFromSpawner:
    lea Commando_SpawnTab,a4
    move spawner_type(a5),d0 
    move spawner_subtype(a5),d1 
.lp:
    cmp #-1,cspawntab_type(a4)
    beq .end
    cmp cspawntab_type(a4),d0
    bne .no
    cmp cspawntab_subtype(a4),d1
    bne .no
    rts
.no:
    lea cspawntab_structsize(a4),a4
    bra .lp
.end:
    move.l #0,a4
    rts
    
    

Commando_InitWorldAndLevelStuff_GFX:
    jsr Commando_InitVDPForLevel

    jsr SpriteCache_BuildFrames
    rts


    
Commando_PlayMusic:
    move #0,d0
    jsr MUSIC_InitSong
    rts

    
SPRPAL_Whiteout:
s	dc.w $3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe,$3fe
    
Commando_InitVDPForLevel:
    jsr ClearVRAM

    ;lea SPRPAL_Commando_Pal0,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource

    lea SPRPAL_Whiteout,a0
    move #1,d0
    jsr FADE_CopySinglePaletteToSource
    jsr FADE_Update

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP

    bsr Commando_InitBackgroundTiles
    
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
    ;dc.w SPRITE_CAR01
    ;dc.w SPRITE_CAR02
    ;dc.w SPRITE_CAR01_GHOST
    ;dc.w SPRITE_COMMANDO_PAL0
    ;dc.w SPRITE_COMMANDO_TANK
    dc.w -1


Commando_InitBackgroundTiles:

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


Commando_UpdateGame:
    tst.l g_stackwatch
    beq .ok
    DEBUG_HALT
.ok

    jsr UTILS_GetRandWord
    bsr Commando_UpdateGame_UpdateGlobals
    bsr Commando_UpdateGame_Normal        
    rts
    
Commando_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
Commando_UpdateGame_UpdateGlobals:
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

    

Commando_UpdateGame_Normal:
    bsr Racing_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    jsr GOManager_Update
	jsr SPRITE_UpdateFromGOManager_Racing
	BORDER 5
	jsr Commando_BulletEnemyCollision
	jsr Commando_PlayerEnemyBulletCollision
	jsr Commmando_PlayerTriggerZoneCollision
    jsr Scroll_UpdateEdgesA
    jsr Scroll_UpdateEdgesB
	BORDER 0
    rts


Commando_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr Commando_UpdateScrollRegisters

    jsr Scroll_DumpEdgesToVDPA
    jsr Scroll_DumpEdgesToVDPB
    
    ; these work much better in VBL
    ;bsr Scroll_UpdateDrawBackgroundTilesToVRAM_A
	rts

;-------------------------------------------------------------


Commando_UpdateScrollRegisters:

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

    
    
    

PADDIR_U    equ padmask_button_up                           ;$1
PADDIR_UR    equ padmask_button_up|padmask_button_right      ;$9
PADDIR_R    equ padmask_button_right                        ;$8
PADDIR_DR    equ padmask_button_right|padmask_button_down    ;$a
PADDIR_D    equ padmask_button_down                         ;$2
PADDIR_DL    equ padmask_button_down|padmask_button_left     ;$6
PADDIR_L    equ padmask_button_left                         ;$4
PADDIR_UL    equ padmask_button_left|padmask_button_up       ;$5

DIR_NONE equ -1
DIR_U equ 0
DIR_UR equ 1
DIR_R equ 2
DIR_DR equ 3
DIR_D equ 4
DIR_DL equ 5
DIR_L equ 6
DIR_UL equ 7

Commando_InitExplosion:
    move.l go_x(a1),go_x(a0)
    move.l go_y(a1),go_y(a0)
    
;    SETSPR SPRITE_COMMANDO_PAL0
;    move #SPRFRAME_COMMANDO_PAL0_EXPLO0,go_frame(a0)
    move #0,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move go_timer(a0),d0
    lsr #1,d0
    add d0,d0
    move .frames(pc,d0),d0
    bmi .die
    move d0,go_frame(a0)

    add #1,go_timer(a0)
    rts
.die:
    jmp GOManager_DeleteObject
.frames:
    ;dc.w SPRFRAME_COMMANDO_PAL0_EXPLO0
    ;dc.w SPRFRAME_COMMANDO_PAL0_EXPLO1
    ;dc.w SPRFRAME_COMMANDO_PAL0_EXPLO2
    ;dc.w SPRFRAME_COMMANDO_PAL0_EXPLO3
    ;dc.w SPRFRAME_COMMANDO_PAL0_EXPLO4
    ;dc.w SPRFRAME_COMMANDO_PAL0_EXPLO5
    dc.w -1

Commando_InitPlayerBulletFire:
    
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_PLAYERFIRE0,go_frame(a0)
    
    move #5,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    
    rts
.update:
    move.l g_player,a1
    move.l go_x(a1),go_x(a0)
    move.l go_y(a1),go_y(a0)
    sub #32,go_y(a0)
    add #5,go_x(a0)
    sub #1,go_timer(a0)
    beq .die
    rts
.die:
    jmp GOManager_DeleteObject

Commando_InitPlayerBullet:
    move.l go_x(a1),go_x(a0)
    move.l go_y(a1),go_y(a0)
    sub #16,go_y(a0)
    move go_firerot(a1),d0
    lsl #5,d0
    add go_initParam0(a1),d0
    move d0,go_rot(a0)
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_PLAYERBULLET0,go_frame(a0)
    
    move #15,go_timer(a0)
    
    
    move go_rot(a0),d0
    sub #64,d0
    jsr UTILS_GetSinCosLong
    lsl.l #4,d0
    move.l d0,go_dx(a0)
    lsl.l #4,d1
    move.l d1,go_dy(a0)

    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    
    rts    
    
.collided:
    jmp GOManager_DeleteObject    
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    move g_timer1_shr4,d0
    and #3,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    
    bsr CommandoIsBulletColliding
    bne .die
    
    sub #1,go_timer(a0)
    beq .die
    rts
.die:
    lea Commando_InitExplosion,a1
    jsr GOManager_SpawnGameObject_Commando_FX
    jmp GOManager_DeleteObject
    
    
.frames:
;    dc.w SPRFRAME_COMMANDO_PAL0_PLAYERBULLET0
;    dc.w SPRFRAME_COMMANDO_PAL0_PLAYERBULLET1
;    dc.w SPRFRAME_COMMANDO_PAL0_PLAYERBULLET2
;    dc.w SPRFRAME_COMMANDO_PAL0_PLAYERBULLET3







Commando_InitPlayer:
    move #0,g_playerWeaponType
    move.l a0,g_player
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_PLAYER,go_frame(a0)
    move #100,go_x(a0)    
    move #200,go_y(a0)    
    move #100,go_health(a0)
    move #0,go_nocollisiontimer(a0)
    move #0,go_shootTimer(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    rts    

.collided:
    tst go_nocollisiontimer(a0)
    bne .ok
    sub #1,go_health(a0)
    ble .dead
    move #PAL_1,go_sprAttributes(a0)
    move #10,go_nocollisiontimer(a0)
.ok:
    rts
.dead:
    move #100,go_health(a0)
    rts
    
.update:
    bsr Commando_UpdateFlash
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
    bsr .domove
    
    move g_pad0,d5
    btst #pad_button_c,d5
    beq .nofast
    bsr .domove
    bsr .domove
    bsr .domove
.nofast:
    
    sub #1,go_shootTimer(a0)
    bgt .noshoot
    
    move g_pad0,d5
    btst #pad_button_a,d5
    beq .noshoot
    
    bsr Commando_Player_DoShoot
    
.noshoot:
    rts
      

.domove:
      move.l #0,go_dx(a0)
      move.l #0,go_dy(a0)
  
  
  
      move g_pad0,d5
      and #padmask_button_udlr,d5
      
      move.b .pad_to_dir(pc,d5),d5
      cmp.b #DIR_NONE,d5
      beq .nomove
      
      and #$f,d5    
      move d5,go_rot(a0)
      
      move g_pad0,d5
      btst #pad_button_b,d5
      bne .nob
      move go_rot(a0),go_firerot(a0)
.nob
      
      
      bsr CommandoGetDxDyFromRotSpeed    
      
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
    
    move.l go_dx(a0),d0    
    add.l d0,go_x(a0)
    bsr CommandoIsPlayerColliding
    beq .nocolX
    move.l go_oldx(a0),go_x(a0)
.nocolX
    move.l go_dy(a0),d0    
    add.l d0,go_y(a0)
    bsr CommandoIsPlayerColliding
    beq .nocolY
    move.l go_oldy(a0),go_y(a0)
.nocolY

  
      
.nomove:

    move go_x(a0),d0
    sub #320/2,d0
    move d0,g_scroll_x
    move go_y(a0),d0
    sub #224/2,d0
    move d0,g_scroll_y
    
    jsr HolLimitScrollEdges
    
    rts


.pad_to_dir:
    dc.b DIR_NONE               ;0
    dc.b DIR_U                  ;PADDIR_U    ;1
    dc.b DIR_D                  ;PADDIR_D    ;2
    dc.b DIR_NONE                      ;3
    dc.b DIR_L                  ;PADDIR_L    ;4
    dc.b DIR_UL                 ;PADDIR_UL    ;5
    dc.b DIR_DL                 ;PADDIR_DL    ;6
    dc.b DIR_NONE                      ;7
    dc.b DIR_R                  ;PADDIR_R    ;8
    dc.b DIR_UR                 ;PADDIR_UR      ;9
    dc.b DIR_DR                 ;PADDIR_DR      a
    dc.b DIR_NONE                     ;b
    dc.b DIR_NONE                     ;c
    dc.b DIR_NONE                      ;d
    dc.b DIR_NONE                     ;e
    dc.b DIR_NONE                     ;f


Commando_Player_DoShoot:
    lea Commando_InitPlayerBulletFire,a1
    jsr GOManager_SpawnGameObject_Commando_FX

    move g_playerWeaponType,d0
    cmp #2,d0
    blt .ok
    move #2,d0
.ok:
    lsl #2,d0
    move.l .weapons(pc,d0),a1
    jmp (a1)
    
    
.weapons:
    dc.l .weapon0
    dc.l .weapon1
    dc.l .weapon2
    
.weapon0:
    move #8,go_shootTimer(a0)

    move #0,go_initParam0(a0)
    lea Commando_InitPlayerBullet,a1
    jsr GOManager_SpawnGameObject_Commando_PlayerBullet
    rts
.weapon1:
    move #8,go_shootTimer(a0)
    
    move #-8,go_initParam0(a0)
    lea Commando_InitPlayerBullet,a1
    jsr GOManager_SpawnGameObject_Commando_PlayerBullet
    
    move #8,go_initParam0(a0)
    lea Commando_InitPlayerBullet,a1
    jsr GOManager_SpawnGameObject_Commando_PlayerBullet
    rts
    
.weapon2:
    move #8,go_shootTimer(a0)
    
    move #0,go_initParam0(a0)
    lea Commando_InitPlayerBullet,a1
    jsr GOManager_SpawnGameObject_Commando_PlayerBullet
    
    move #-12,go_initParam0(a0)
    lea Commando_InitPlayerBullet,a1
    jsr GOManager_SpawnGameObject_Commando_PlayerBullet
    
    move #12,go_initParam0(a0)
    lea Commando_InitPlayerBullet,a1
    jsr GOManager_SpawnGameObject_Commando_PlayerBullet
    rts


HolPlayer_rotveltab:
.v set $10000*2
.v1 set $b4fd*2
    dc.l 0,-.v
    dc.l .v1,-.v1
    dc.l .v,0
    dc.l .v1,.v1
    dc.l 0,.v
    dc.l -.v1,.v1
    dc.l -.v,0
    dc.l -.v1,-.v1


CommandoGetDxDyFromRotSpeed:
    move go_rot(a0),d0
    lsl #3,d0
    lea HolPlayer_rotveltab,a1
    add d0,a1

    move.l (a1)+,d0
    move.l d0,go_dx(a0)
    
    move.l (a1)+,d0
    move.l d0,go_dy(a0)
    
    rts
    
Commando_UpdateEnemy_WaitForRange:
    move.l g_player,a1
    move go_y(a0),d0
    add #150,d0
    cmp go_y(a1),d0
    blt .no
    move.l go_nextUpdateFunc(a0),go_onUpdate(a0)
.no:
    rts

Commando_InitRock:
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_ROCK,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move #10,go_health(a0)
    move #0,go_nocollisiontimer(a0)
    move.l #Commando_EnemyCollided,go_onCollided(a0)
.update: 
    bsr Commando_UpdateFlash
    rts


;PARAM_COMMANDO_GENERATOR_GENERATEDTYPE so.w 1	;Spawner Def link index
;PARAM_COMMANDO_GENERATOR_TOTAL so.w 1	;Int 16
;PARAM_COMMANDO_GENERATOR_MAXATONCE so.w 1	;Int 16
;PARAM_COMMANDO_GENERATOR_DELAY so.w 1	;Seconds (frames)
Commando_InitGenerator:
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    move #0,go_word0(a0)    ; total counter

    move.l go_params_addr(a0),a1
    move PARAM_COMMANDO_GENERATOR_DELAY(a1),go_timer(a0)
    
    move.l #.update,go_onUpdate(a0)
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_ROCK,go_frame(a0)
    rts
.update: 
    sub #1,go_timer(a0)
    bge .ok
    
    move.l go_params_addr(a0),a1
    move PARAM_COMMANDO_GENERATOR_DELAY(a1),go_timer(a0)
    
    move PARAM_COMMANDO_GENERATOR_GENERATEDTYPE(a1),d0
    bsr Commando_SpawnByType

    move.l go_params_addr(a0),a1
    add #1,go_word0(a0)
    move go_word0(a0),d0
    cmp PARAM_COMMANDO_GENERATOR_TOTAL(a1),d0
    bge .die
.ok:
    rts
.die:
    jmp GOManager_DeleteObject
        
Commando_InitEnemyBase:
    ;SETSPR SPRITE_COMMANDO_PAL0
    move #5,go_health(a0)
    move #0,go_nocollisiontimer(a0)
    move.l #Commando_EnemyCollided,go_onCollided(a0)
    move.l #.update,go_onUpdate(a0)
.update: rts

Commando_EnemyCollided:
    tst go_nocollisiontimer(a0)
    bne .ok
    sub #2,go_health(a0)
    ble .dead
    move #PAL_1,go_sprAttributes(a0)
    move #10,go_nocollisiontimer(a0)
.ok:
    rts
.dead:
    move.l #0,go_onCollided(a0)
    move.l #.deadUpdate,go_onUpdate(a0)
    ;move #SPRFRAME_COMMANDO_PAL0_ENEMYDEAD,go_frame(a0)
    move #50,go_timer(a0)
    
.deadUpdate:
    sub #1,go_timer(a0)
    ble .die2
    rts
.die2:
    jmp GOManager_DeleteObject
    
Commando_UpdateFlash:
    tst go_nocollisiontimer(a0)
    beq .ok
    sub #1,go_nocollisiontimer(a0)
    bne .ok
    move #PAL_0,go_sprAttributes(a0)
.ok:
    rts


Commando_InitPickup_Gold:
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_PICKUP1,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    rts
.update: rts
.collided: 
    jmp GOManager_DeleteObject

Commando_InitPickup_Weapon:
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_PICKUP0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    rts
.update: rts
.collided: 
    add #1,g_playerWeaponType
    jmp GOManager_DeleteObject



;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------

Commando_InitEnemy_Tank:
    bsr Commando_InitEnemyBase
    move.l #.update,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    ;SETSPR SPRITE_COMMANDO_TANK
    ;SETCOMPSPR COMPOUNDSPRITE_COMMANDO_TANK
    ;SETCOMPSPR COMPOUNDSPRITE_COMMANDO_WAVY
    move #0,go_frame(a0)
    rts
.update:
    bsr Commando_UpdateFlash
    
    move g_timer1_shr4,d0
    and #7,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    
    move g_timer1_shr1,d0
    and #63,d0
    move d0,go_frame(a0)
    
    rts
.frames:
    dc.w 0,1,2,3,4,3,2,1

;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
    
Commando_InitEnemy_Stationary_Shooting:   
    bsr Commando_InitEnemyBase
    move #120,go_shoot_timerMax(a0)
    move.l #.update,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    bsr .initShot
    rts
.update:
    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash
    bsr Commando_Enemy_UpdateShooting
    rts
.initShot:
    rts


Commando_Enemy_UpdateShooting:
    sub #1,go_shootTimer(a0)
    bgt .shotOK
    
    lea Commando_InitEnemyBullet,a1
    jsr GOManager_SpawnGameObject_Commando_CollideWithPlayer
    move go_shoot_timerMax(a0),go_shootTimer(a0)
.shotOK:
    rts
    
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
    
Commando_InitEnemy_Stationary_Grenade:   
    bsr Commando_InitEnemyBase
    move #1120,go_shoot_timerMax(a0)
    move.l #.update,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    bsr .initShot
    rts
.update:
    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash
    bsr .updateShot
    rts
.initShot:
    move go_shoot_timerMax(a0),go_shootTimer(a0)
    rts

.updateShot:
    sub #1,go_shootTimer(a0)
    bgt .shotOK
    
    lea Commando_InitEnemyGrenade,a1
    jsr GOManager_SpawnGameObject_Commando_CollideWithPlayer
    bsr .initShot
.shotOK:
    rts




Commando_Enemy_UpdateAnim:
    move g_timer1_shr4,d0
    and #3,d0
    add d0,d0
    move.w .frames(pc,d0),go_frame(a0)
    rts
    
.frames:
    ;dc.w SPRFRAME_COMMANDO_PAL0_ENEMYSPR0
    ;dc.w SPRFRAME_COMMANDO_PAL0_ENEMYSPR1
    ;dc.w SPRFRAME_COMMANDO_PAL0_ENEMYSPR2
    ;dc.w SPRFRAME_COMMANDO_PAL0_ENEMYSPR1


    
    clrso
cpath_currentNode so.w 1
cpath_numNodes   so.w 1
cpath_firstNodeAddr       so.l 1
cpath_structsize so.b 0
; path index in d0
Commando_InitPath:
    lsl #2,d0
    move.l sysg_levelInfo+levelinfo_paths,a1
    move.l (a1,d0),a1
    move.w #0,go_cpath+cpath_currentNode(a0)
    move.w (a1)+,go_cpath+cpath_numNodes(a0)
    move.l a1,go_cpath+cpath_firstNodeAddr(a0)
    rts
    
;PARAM_COMMANDO_ENEMY_FOLLOWPATH_INITIALPATH
;PARAM_COMMANDO_ENEMY_FOLLOWPATH_SPEED
Commando_InitEnemy_FollowPath:
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move PARAM_COMMANDO_ENEMY_FOLLOWPATH_INITIALPATH(a1),d0
    bsr Commando_InitPath
    
    bsr Commando_InitEnemyBase
    move.l #Commando_Update_FollowPath,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    rts

Commando_Update_FollowPath:
    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash

    lea go_cpath(a0),a2
    move.l cpath_firstNodeAddr(a2),a3
    move cpath_currentNode(a2),d0
    lsl #3,d0
    add d0,a3
    
    
    move (a3),d0
    sub.w go_x(a0),d0
    move 2(a3),d1
    sub.w go_y(a0),d1
    jsr GetAtan2
    move d2,d0
    jsr GOTOOLS_GetMovementVecFromRot
    lsl.l #1,d2
    lsl.l #1,d1
    
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
        
        
    bsr Commando_Enemy_UpdateMovementFromDXDY        
        
        
    move (a3),d0
    sub go_x(a0),d0
    bge .ok1
    neg d0
.ok1
    move 2(a3),d1
    sub go_y(a0),d1
    bge .ok2
    neg d1
.ok2

    ;bra .notatnode
    cmp #4,d0
    bgt .notatnode
    cmp #4,d1
    bgt .notatnode
    
    add #1,cpath_currentNode(a2)
    move cpath_currentNode(a2),d0
    cmp cpath_numNodes(a2),d0
    beq .last
.notatnode:
    rts    

.last:
    move.l #.last,go_onUpdate(a0)
    rts
    
; d0 index
; return in a1
Commando_GetZoneFromIndex:
    move.l sysg_levelInfo+levelinfo_zones,a1
    lea 2(a1),a1
    lsl #2,d0
    move.l (a1,d0),a1
    rts
   
   
   
   
;----------------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------------------------
   
 ;PARAM_COMMANDO_ENEMY_PATROLZONE_PATROLZONE so.w 1	;zonelink index
Commando_InitEnemy_PatrolZone:
    bsr Commando_InitEnemyBase
    
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move PARAM_COMMANDO_ENEMY_PATROLZONE_PATROLZONE(a1),d0
    bsr Commando_GetZoneFromIndex
    move.l a1,go_zoneAddr(a0)

    move.l #.triggered,go_onTriggered(a0)

    move #80,go_shoot_timerMax(a0)
    move.l #.updateFirstTime,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    rts
    
.triggered:
    move.l #Commando_Enemy_UpdateChase,go_onUpdate(a0)
    rts

.getpoint:
    move.l go_zoneAddr(a0),a1

    move zone_x0(a1),d0
    move zone_x1(a1),d1
    jsr Utils_RandBetweenInclusive
    move d0,go_tox(a0)

    move zone_y0(a1),d0
    move zone_y1(a1),d1
    jsr Utils_RandBetweenInclusive
    move d0,go_toy(a0)
    
    move go_tox(a0),d0
    sub.w go_x(a0),d0
    move go_toy(a0),d1
    sub.w go_y(a0),d1
    jsr GetAtan2
    move d2,d0
    jsr GOTOOLS_GetMovementVecFromRot
    lsl.l #1,d2
    lsl.l #1,d1
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
    rts
    

.updateFirstTime:
    bsr .getpoint
    move.l #.update,go_onUpdate(a0)

.update:

    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash
    bsr Commando_Enemy_UpdateShooting    
    
    bsr Commando_Enemy_UpdateMovementFromDXDY


    move go_tox(a0),d0
    sub go_x(a0),d0
    bge .ok1
    neg d0
.ok1
    move go_toy(a0),d1
    sub go_y(a0),d1
    bge .ok2
    neg d1
.ok2

    cmp #4,d0
    bgt .notatnode
    cmp #4,d1
    bgt .notatnode
    
    bsr .getpoint
    
.notatnode:
    rts
    
;----------------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------------------------
       
Commando_InitEnemy_Chase:   
    bsr Commando_InitEnemyBase
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move PARAM_COMMANDO_ENEMY_CHASE_CHASELIMIT(a1),d0
    bsr Commando_GetZoneFromIndex
    move.l a1,go_zoneAddr(a0)

    
    move #80,go_shoot_timerMax(a0)
    move.l #.update,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    rts
    
.update:

    bsr Commando_Enemy_UpdateChase

; limit to zone
    move.l go_zoneAddr(a0),a1
 
    move go_x(a0),d0
    
    cmp zone_x0(a1),d0
    bge .okx0
    move zone_x0(a1),d0
.okx0:    
    cmp zone_x1(a1),d0
    ble .okx1
    move zone_x1(a1),d0
.okx1:
    move d0,go_x(a0)

    move go_y(a0),d0
    
    cmp zone_y0(a1),d0
    bge .oky0
    move zone_y0(a1),d0
.oky0:    
    cmp zone_y1(a1),d0
    ble .oky1
    move zone_y1(a1),d0
.oky1:
    move d0,go_y(a0)

    rts    
    
Commando_Enemy_UpdateChase:
    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash
    bsr Commando_Enemy_UpdateShooting    
    move.l g_player,a1
    jsr GOTOOLS_GetAngToGO
    move d0,go_rot(a0)
    jsr GOTOOLS_GetMovementVecFromRot
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
    bsr Commando_Enemy_UpdateMovementFromDXDY
    rts
    

Commando_Enemy_UpdateMovementFromDXDY:    
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
    
    move.l go_dx(a0),d0    
    add.l d0,go_x(a0)
    bsr CommandoIsPlayerColliding
    beq .nocolX
    move.l go_oldx(a0),go_x(a0)
.nocolX
    move.l go_dy(a0),d0    
    add.l d0,go_y(a0)
    bsr CommandoIsPlayerColliding
    beq .nocolY
    move.l go_oldy(a0),go_y(a0)
.nocolY
    rts
    
Commando_EnemyRun_UpdateBullet:
    move go_timer(a0),d0
    and #$1f,d0
    bne .ok
    lea Commando_InitEnemyBullet,a1
    jsr GOManager_SpawnGameObject_Commando_CollideWithPlayer
.ok:
    rts

Commando_InitEnemy_RunLeft:
    bsr Commando_InitEnemyBase
    move.l #.update,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    move #300,go_timer(a0)
.update:
    move.l g_player,a1
    move go_y(a0),d0
    add #50,d0
    cmp go_y(a1),d0
    blt .no
    
    move.l #.update_run,go_onUpdate(a0)
.no:
    rts
.update_run:
    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash
    bsr Commando_EnemyRun_UpdateBullet
    add.l #-$20000,go_x(a0)
    sub #1,go_timer(a0)
    ble .die
    rts
.die: jmp GOManager_DeleteObject

Commando_InitEnemy_RunRight:
    bsr Commando_InitEnemyBase
    move.l #.update,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    move #300,go_timer(a0)
.update:
    move.l g_player,a1
    move go_y(a0),d0
    add #50,d0
    cmp go_y(a1),d0
    blt .no
    
    move.l #.update_run,go_onUpdate(a0)
.no:
    rts
.update_run:
    bsr Commando_Enemy_UpdateAnim
    bsr Commando_UpdateFlash
    bsr Commando_EnemyRun_UpdateBullet
    add.l #$20000,go_x(a0)
    sub #1,go_timer(a0)
    ble .die
    rts
.die: jmp GOManager_DeleteObject


    
Commando_InitEnemy_Patrol_LR:
    bsr Commando_InitEnemyBase
    move.l #.initupdate1,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)

    ;move.l #.update1,go_updatefunc(a0)
    ;bsr .initupdate1
    bsr .initShot
    rts    

.initupdate1:
    move #50,go_timer(a0)
    move.l #.update1,go_onUpdate(a0)
    rts
    
.update1:
    bsr Commando_UpdateFlash
    bsr .updateShot
    add.l #$8000,go_x(a0)
    sub #1,go_timer(a0)
    beq .initupdate2
    rts
        
.initupdate2:
    move #50,go_timer(a0)
    move.l #.update2,go_onUpdate(a0)
    rts

.update2:
    bsr Commando_UpdateFlash
    bsr .updateShot
    add.l #-$8000,go_x(a0)
    sub #1,go_timer(a0)
    beq .initupdate1
    rts

.initShot:
    jsr UTILS_GetRandWordFast
    and #127,d0
    add #120,d0
    move d0,go_shootTimer(a0)
    rts

.updateShot:
    sub #1,go_shootTimer(a0)
    bgt .shotOK
    
    lea Commando_InitEnemyBullet,a1
    jsr GOManager_SpawnGameObject_Commando_CollideWithPlayer
    bsr .initShot
.shotOK:
    rts
    

Commando_InitEnemyGrenade:
    move.l go_x(a1),go_x(a0)
    move.l go_y(a1),go_y(a0)
    sub #16,go_y(a0)
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_GRENADE4,go_frame(a0)
    move.l g_player,a1
    jsr GOTOOLS_GetAngToGO
    move d0,go_rot(a0)
    jsr GOTOOLS_GetMovementVecFromRot
    lsl.l #1,d2
    lsl.l #1,d1
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
    
    move #100,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.render,go_onRender(a0)
    
    move.l #0,go_z(a0)
    move.l #-$18000,go_dz(a0)
    
    rts    

.update:

    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    add.l #$700,go_dz(a0)
    move.l go_dz(a0),d0
    add.l d0,go_z(a0)

    cmp #0,go_z(a0)
    bgt .hitfloor

    rts
    
.hitfloor:
    jmp GOManager_DeleteObject

.render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    
    move go_z(a0),d4
    neg d4
    lsr #4,d4
    cmp #3,d4
    ble .okh
    move #3,d4
.okh:
    
    ;move #SPRFRAME_COMMANDO_PAL0_GRENADE1,d0
    add d4,d0
    move go_x(a0),d5
    move go_y(a0),d6
    add go_z(a0),d6
    bsr .render_doone

    move g_timer1,d0
    and #1,d0
    beq .noshad
    ;move #SPRFRAME_COMMANDO_PAL0_GRENADESHADOW1,d0
    add d4,d0
    move go_x(a0),d5
    move go_y(a0),d6
    bsr .render_doone
.noshad:
    rts
    
.render_doone:
    move d0,sprbuf_frame(a5)
    
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts
    
.exit:
    rts

Commando_InitEnemyBullet:
    move.l go_x(a1),go_x(a0)
    move.l go_y(a1),go_y(a0)
    sub #16,go_y(a0)
    ;SETSPR SPRITE_COMMANDO_PAL0
    ;move #SPRFRAME_COMMANDO_PAL0_ENEMYBULLET,go_frame(a0)
    
    move.l g_player,a1
    jsr GOTOOLS_GetAngToGO
    move d0,go_rot(a0)
    jsr GOTOOLS_GetMovementVecFromRot
    lsl.l #2,d2
    lsl.l #2,d1
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
    
    
    move #100,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    
    rts    
    
.collided:
    bra .die 
    
.update
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    bsr CommandoIsBulletColliding
    bne .die

    sub #1,go_timer(a0)
    beq .die
    rts
.die:
    lea Commando_InitExplosion,a1
    jsr GOManager_SpawnGameObject_Commando_FX

    jmp GOManager_DeleteObject



Commando_PlayerEnemyBulletCollision:
    jsr GOManager_GetList_EnemyBullet
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .nobullets
    move.l golist_active_list_addr(a5),a5
    subq #1,d7


.loop1:
    move.l (a5)+,a0
    move go_x(a0),d0
    move go_y(a0),d1
    
    move.l g_player,a1
    
    move go_x(a1),d2
    sub d0,d2

    move go_y(a1),d3
    sub d1,d3
    
    cmp #COL_RADX,d2
    bgt .skip
    cmp #-COL_RADX,d2
    blt .skip
    
    
    cmp #COL_RADY,d3
    bgt .skip
    cmp #-COL_RADY,d3
    blt .skip

    PUSHALL
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    POPALL

    PUSHALL
    move.l go_onCollided(a1),d0
    beq .nocolfunc2
    move.l a1,a0
    move.l d0,a5
    jsr (a5)
.nocolfunc2:
    POPALL


.skip:
    dbra d7,.loop1
    
.nobullets:
    rts


COL_RADX equ 10
COL_RADY equ 20
Commando_BulletEnemyCollision:

    jsr GOManager_GetList_PlayerBullets
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .nobullets
    move.l golist_active_list_addr(a5),a5
    subq #1,d7


.loop1:
    move.l (a5)+,a0
    move go_x(a0),d0
    move go_y(a0),d1
    
    
    jsr GOManager_GetList_Treasure        ; enemies
    move.l a3,a4
    move golist_num_active(a4),d6
    beq .nobullets
    move.l golist_active_list_addr(a4),a4
    subq #1,d6
    
.loop2:
    move.l (a4)+,a1
    
    move go_x(a1),d2
    sub d0,d2

    move go_y(a1),d3
    sub d1,d3
    
    cmp #COL_RADX,d2
    bgt .skip
    cmp #-COL_RADX,d2
    blt .skip
    
    
    cmp #COL_RADY,d3
    bgt .skip
    cmp #-COL_RADY,d3
    blt .skip

    PUSHALL
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    POPALL

    PUSHALL
    move.l go_onCollided(a1),d0
    beq .nocolfunc2
    move.l a1,a0
    move.l d0,a5
    jsr (a5)
.nocolfunc2:
    POPALL


.skip:
    dbra d6,.loop2

    dbra d7,.loop1
    
.nobullets:
    rts

    clrso
zone_x0     so.w 1
zone_y0     so.w 1
zone_x1     so.w 1
zone_y1     so.w 1
zone_type   so.w 1
zone_base_size so.b 0

    setso zone_base_size
zone_num_links     so.w 1
zone_first_link   so.w 1

    setso zone_base_size
zone_callback_id     so.w 1
zone_callback_data   so.w 1


Commando_ClearZoneTrackerTable:
    move.l m_zoneTrackerTable,a0
    move #256,d0
    jsr UTILS_ClearRam
    rts

; zone index in d0
Commmando_PlayerTriggerZoneCollision:
    move.l g_player,a2
    move go_x(a2),d0
    move go_y(a2),d1

    move.l m_zoneTrackerTable,a4

    move.l sysg_levelInfo+levelinfo_zones,a0
    move (a0)+,d7
    beq .none
    moveq #0,d6             ; zone index
    subq #1,d7
.zoneloop:
    move.l (a0)+,a1
    
    tst.b (a4,d6)       ; already used ?
    bne .no
    
    tst zone_type(a1)
    beq .no
    
    cmp zone_x0(a1),d0
    blt .no
    cmp zone_x1(a1),d0
    bgt .no
    
    cmp zone_y0(a1),d1
    blt .no
    cmp zone_y1(a1),d1
    bgt .no
    
    
.hit:
    move.b #1,(a4,d6)       ; set to used

    cmp #ZONETYPE_TRIGGER,zone_type(a1)
    bne .notrigger
    bsr Commando_ZoneColl_DoTrigger
    bra .no
.notrigger:
    cmp #ZONETYPE_SPAWN,zone_type(a1)
    bne .nospawn
    bsr Commando_ZoneColl_DoSpawn
    bra .no
.nospawn:
    cmp #ZONETYPE_CALLBACK,zone_type(a1)
    bne .nocallback
    bsr Commando_ZoneColl_DoCallback
    bra .no
.nocallback:


.no:
    addq #1,d6
    dbra d7,.zoneloop
.none:
    rts

;zone_callback_id     so.w 1
;zone_callback_data   so.w 1
; a1 is zone
Commando_ZoneColl_DoCallback:
    move zone_callback_id(a1),d0
    lsl #2,d0
    move.l .callbacks(pc,d0),a2
    jmp (a2)

.callbacks:
    dc.l .callback0
    dc.l .callback1
    
.callback0:
    move #0,DebugArea
    move zone_callback_data(a1),DebugArea+2
    rts
.callback1:
    move #1,DebugArea
    move zone_callback_data(a1),DebugArea+2
    rts

; don't use d0-d1/d7 / a0-a1
; trigger in a1
Commando_ZoneColl_DoSpawn:
    PUSHALL
    move zone_num_links(a1),d6
    subq #1,d6                      ; never zero
    lea zone_first_link(a1),a5
.trigger_loop:
    move (a5)+,d0           ; d0 is spawn index
    bsr Commando_SpawnExternal
    dbra d6,.trigger_loop

    POPALL
    rts

Commando_ZoneColl_DoTrigger:
    PUSHALL
    move zone_num_links(a1),d6
    subq #1,d6                      ; never zero
    lea zone_first_link(a1),a5
.trigger_loop:
    move (a5)+,d2           ; d2 is spawn index
    
    PUSHALL
    jsr GOManager_GetList_Treasure                  ; objs
    
    move.l golist_active_list_addr(a3),a5
    move   golist_num_active(a3),d5
    subq #1,d5
    blt	.noobjs
.objloop:
    move.l (a5)+,a2         ; a2 GO
    ; should test if active etc.
    cmp go_spawnTableIndex(a2),d2
    bne .skipobj
    
    PUSHALL
    move.l go_onTriggered(a2),d0
    beq .notriggerfunc
    move.l d0,a5
    move.l a2,a0
    jsr (a5)
.notriggerfunc:
    POPALL
        
.skipobj:
    dbra d5,.objloop    
.noobjs:
    POPALL
    dbra d6,.trigger_loop
    
    POPALL
    rts
    
    
CommandoIsPlayerColliding:
    move.l sysg_levelInfo+levelinfo_collisionMap,a1
    lea 4(a1),a1
    
    move go_x(a0),d0
    lsr #3,d0
    add d0,a1
    move go_y(a0),d0
    lsr #3,d0
    
    mulu sysg_levelInfo+levelinfo_collisionMap_stride,d0
    add d0,a1
    move.b (a1),d0
    and.b #2,d0
    beq .nocol
    moveq #1,d0
    rts
.nocol:
    moveq #0,d0
    rts

CommandoIsBulletColliding:
    move.l sysg_levelInfo+levelinfo_collisionMap,a1
    lea 4(a1),a1
    
    move go_x(a0),d0
    lsr #3,d0
    add d0,a1
    move go_y(a0),d0
    lsr #3,d0
    
    mulu sysg_levelInfo+levelinfo_collisionMap_stride,d0
    add d0,a1
    move.b (a1),d0
    and.b #1,d0
    beq .nocol
    moveq #1,d0
    rts
.nocol:
    moveq #0,d0
    rts


;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------


IK_NUM_BONES equ 8
IKBONES_DISTANCE equ 8

    clrso
ik_x    so.w 1
ik_y    so.w 1
ik_structsize so.b 0

    clrso
gik_base_x so.w 1
gik_base_y so.w 1
gik_dist1 so.w 1
gik_dist2 so.w 1
gik_sx so.w 1
gik_sy so.w 1
gik_structsize so.b 0

Commando_InitEnemy_IK_InitBones:
    lea go_bonePositions(a0),a1
    move #IK_NUM_BONES-1,d6
    move go_x(a0),d0
    move go_y(a0),d1
.initlp:
    move.w d0,ik_x(a1)
    move.w d1,ik_y(a1)
    lea ik_structsize(a1),a1
    
    sub.w #IKBONES_DISTANCE,d1
    dbra d6,.initlp
    
    rts

Commando_InitEnemy_IK:


    bsr Commando_InitEnemyBase
    move.l #.first,go_nextUpdateFunc(a0)
    move.l #Commando_UpdateEnemy_WaitForRange,go_onUpdate(a0)
    ;SETSPR SPRITE_COMMANDO_PAL0

    move.l #Commando_Enemy_IK_Render,go_onRender(a0)
    move #0,go_frame(a0)
    rts
.first:
    bsr Commando_InitEnemy_IK_InitBones
    move.l #.update,go_nextUpdateFunc(a0)
.update:
    BORDER 33
    bsr Commando_Enemy_IK_Calculate
    BORDER 0
    rts

Commando_Enemy_IK_Render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    lea go_bonePositions(a0),a1
    move #IK_NUM_BONES-1,d4
.lp:
    move.w ik_x(a1),d5
    move.w ik_y(a1),d6
    bsr .render_doone
    lea ik_structsize(a1),a1
    dbra d4,.lp

    rts
    
.render_doone:
    ;move #SPRFRAME_COMMANDO_PAL0_PICKUP1,sprbuf_frame(a5)
    
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts




Commando_Enemy_IK_Calculate:
    move.l d7,-(sp)
    
    lea go_bonePositions(a0),a1
    move.w ik_x(a1),g_ik+gik_base_x
    move.w ik_y(a1),g_ik+gik_base_y          ; save base
    
    lea go_bonePositions(a0),a1      ; head pos
    lea ik_structsize(a1),a2      ; tail pos
    move.l g_player,a4
    move.w go_x(a4),d5          ; d5 / d6 is target pos
    move.w go_y(a4),d6
    move #IK_NUM_BONES-2,d7
.lp1:
    bsr .reach
    ; copy target to current head pos
    move.w d5,ik_x(a1)
    move.w d6,ik_y(a1)
    ; move returned value to target 
    move d0,d5
    move d1,d6
    
    ; next pos
    lea ik_structsize(a1),a1
    lea ik_structsize(a2),a2
    dbra d7,.lp1
; copy final target to current head pos
    move.w d5,ik_x(a1)
    move.w d6,ik_y(a1)

; pass 2
    lea go_bonePositions(a0),a1
    add #((IK_NUM_BONES-1)*ik_structsize),a1
    lea -ik_structsize(a1),a2
    lea Scratchpad+1024+512,a3      ; targetpos
    
    move.w g_ik+gik_base_x,d5
    move.w g_ik+gik_base_y,d6       ; restore base
        
    
    move #IK_NUM_BONES-2,d7
.lp2:
    bsr .reach
    ; copy target to current head pos
    move.w d5,ik_x(a1)
    move.w d6,ik_y(a1)
    ; move returned value to target 
    move d0,d5
    move d1,d6
    
    ; next pos
    lea -ik_structsize(a1),a1
    lea -ik_structsize(a2),a2
    dbra d7,.lp2
; copy final target to current head pos
    move.w d5,ik_x(a1)
    move.w d6,ik_y(a1)

    move.l (sp)+,d7
    rts
    
; (a1) = head pos
; (a2) = tail pos
; d5,d6 = target pos 
; returns d0,d1 as new tail position
.reach:

;var len = Vec2.Distance(head, tail);   (len is predefined / hardcoded)
;var len2 = Vec2.Distance(head, target)
    move d5,d2
    sub  ik_x(a1),d2
    move d6,d3
    sub  ik_y(a1),d3
    bsr .getdistance
    move.w d0,d1        ; dist2: store  (head to target distance)
    
;var scale = len / len2;

; don't need to calc original distance, that should be pre-stored. Use fixed value for now
    move.l #IKBONES_DISTANCE<<8,d0     ;; shift left 8 for fractional divide
 
    divu d1,d0      ; could definitely do a lookup here
    move d0,d2              ; d2 = scale
    
; var r0= target;       ; can ignore that
; var r1 = new Vec2(target.X + (s.X * scale), target.Y+(s.Y * scale));
    
;var s = head-target;
    
    move ik_x(a1),d0
    sub d5,d0     ;s.x
    muls d2,d0
    asr.l #8,d0
    add d5,d0             

    move ik_y(a1),d1
    sub d6,d1         ; s.y
    muls d2,d1
    asr.l #8,d1
    add d6,d1
    rts             


; d2,d3 dx,dy (not abs)
; returns distance in d0.l
.getdistance:
    tst d2
    bgt .dist_neg_x
    neg d2
.dist_neg_x:
    tst d3
    bgt .dist_neg_y
    neg d3
.dist_neg_y:

    cmp #63,d2
    blt .dist_max_x
    move #63,d2
.dist_max_x:
    cmp #63,d3
    blt .dist_max_y
    move #63,d3
.dist_max_y:

    lea SquareRootTableWord,a6
    add d2,d2
    lsl #6+1,d3                 ; y pos in table. 64*2
    add d3,a6
    move.w (a6,d2),d0
    rts
    
    


;(Vec2 , Vec2 ) Reach(Vec2 head, Vec2 tail, Vec2 target )
;{
;    var len = Vec2.Distance(head, tail);
;    var s = head-target;
;    var len2 = Vec2.Distance(head, target)
;
;    var scale = len / len2;
;
;    var r0= target;
;    var r1 = new Vec2(target.X + (s.X * scale), target.Y+(s.Y * scale));
;    return (r0, r1);
;}


