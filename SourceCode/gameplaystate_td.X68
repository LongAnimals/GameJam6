
PSGSFX_TD_PlayerShoot equ PSGSFX_gunslugs_shoot_dropper
PSGSFX_TD_BulletHitWrongEnemy equ PSGSFX_gunslugs_chym
PSGSFX_TD_BulletHitCorrectEnemy equ PSGSFX_gunslugs_fireball
PSGSFX_TD_BulletHitBubble equ PSGSFX_gunslugs_mine_explosion
PSGSFX_TD_BubbleReachedEnd equ PSGSFX_gunslugs_pickup_coin
PSGSFX_TD_EnemyReachedEnd equ PSGSFX_gunslugs_player_die

TD_AIRMETER_VDPINDEX equ $64|PAL_1

TD_SONG equ SONG_POE

TD_TUNNELGFX_0 equ $1

TD_PLAYER_SHOTTIME equ 20
TD_TIME_SUBHOURS equ 300        ; 5s*12 hours = 60s
TD_AIR_BUBBLE equ 32<<16
TD_AIR_HITENEMY equ -32<<16
TD_MAX_AIR equ 256
TD_AIR_PERFRAME equ -$800

    clrso
td_state            so.w 1
td_timer_hours        so.w 1
td_timer_subhours        so.w 1
td_air                  so.l 1

td_numTowersActive      so.w 1
td_m_pathlists          so.l 1
td_levelOverFlag       so.b 1
td_flags               so.b 1
td_playerBulletPositions so.w 4*2
td_bullet_path_addrs    so.l 4
td_spawnerGoList        so.l 4
td_currentFireDirection so.w 1
td_currentBullet so.w 1
td_fontdrawarea so.b     18
td_structsize           so.b 0

TD_EndState:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts
	
TD_InitGlobals:
    lea g_td,a0
    move #0,td_numTowersActive(a0)
    move.b #0,td_levelOverFlag(a0)
    
    move #12,td_timer_hours(a0)
    move #TD_TIME_SUBHOURS,td_timer_subhours(a0)
    
    move.l #TD_MAX_AIR<<16,td_air(a0)
    
    move #0,td_currentFireDirection(a0)
    move #0,td_state(a0)
    
    move.l #-1,td_playerBulletPositions(a0)
    move.l #-1,td_playerBulletPositions+4(a0)
    move.l #-1,td_playerBulletPositions+8(a0)
    move.l #-1,td_playerBulletPositions+12(a0)
    move.l #-1,td_spawnerGoList+0(a0)
    move.l #-1,td_spawnerGoList+4(a0)
    move.l #-1,td_spawnerGoList+8(a0)
    move.l #-1,td_spawnerGoList+12(a0)
    
    rts
	

TD_PATHSLIST_SIZE equ 2048

TD_MEM_AllocForGame
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_GameObjects,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_TD,a0
    bsr MEM_AllocateGroup
    
    bsr MEM_ShowDebug
    rts
    
MEM_Table_TD:

    dc.l g_td+td_m_pathlists
    dc.w TD_PATHSLIST_SIZE

    dc.l -1
    

TD_InitState:
	jsr Globals_ClearAll
    jsr MEM_Init
    jsr TD_MEM_AllocForGame 
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


    ifnd IS_FINAL_GAME
    move #0,sysg_levelIndex
    endif
    bsr TD_InitLevel

	jsr SOUND_Init
    move #0,sysg_current_music
    move #TD_SONG,d0
    jsr MUSIC_InitSong

	jsr SCROLL_SetNormalPlanes
	;jsr SCROLL_CreateDMATables


    bsr TD_InitGlobals
    jsr TD_InitForGame
    jsr TD_InitForLevel
    bsr TD_InitWorldAndLevelStuff_GFX
    bsr TD_InitWorldAndLevelStuff_Mem
    ;jsr SCROLL_FillScrollA
    ;jsr SCROLL_FillScrollB

	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #TD_UpdateGame,g_game_loopaddr
	move.l #TD_UpdateVBL,g_game_vbladdr

    

    rts
    
    
TD_NextLevel:
    add #1,sysg_levelIndex
    rts
    
TD_NUM_LEVELLAYOUTS equ 4
TD_InitLevel:
    moveq #0,d0
    move sysg_levelIndex,d0
    divu #TD_NUM_LEVELLAYOUTS,d0
    swap d0
    add d0,d0
    move .levels(pc,d0),d0
    jsr LEVEL_InitData
    rts
.levels
    dc.w LEVEL_TOWERDEFENSE
    dc.w LEVEL_TOWERDEFENSE1
    dc.w LEVEL_TOWERDEFENSE2
    dc.w LEVEL_TOWERDEFENSE3
        
        
TD_ResetForRealtimeCommand:
    bsr TD_InitGlobals
    jsr TD_InitForGame
    jsr TD_InitForLevel
    bsr TD_InitWorldAndLevelStuff_GFX
    bsr TD_InitWorldAndLevelStuff_Mem
    ;jsr SCROLL_FillScrollA
    ;jsr SCROLL_FillScrollB
    rts
    
    
TD_InitForGame:
    rts
    

TD_InitForLevel:
    rts
    

TD_InitWorldAndLevelStuff_Mem:
    bsr TD_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    jsr TD_InitGOs
    rts
    
TD_InitGOs:

    bsr TD_SpawnStuff

    lea TD_InitPlayer,a1
    bsr TD_SpawnGameObject_General

    lea TD_InitPlayerCoffin,a1
    bsr TD_SpawnGameObject_General

    lea TD_InitHUD,a1
    bsr TD_SpawnGameObject_General

    lea TD_InitSpawnerManager,a1
    bsr TD_SpawnGameObject_General
    
    rts

 TD_SpawnGameObject_General:
    jmp GOManager_SpawnGameObject_Treasure
TD_SpawnGameObject_Enemy:
    jmp GOManager_SpawnGameObject_Car
TD_SpawnGameObject_PlayerBullet:
    jmp GOManager_SpawnGameObject_PlayerBullet
    
    
go_td_numCommands equ go_word0
go_td_commandDir equ go_word1
go_td_commandNumSpaces equ go_word2
go_td_buildCount equ go_word3
go_td_commandIndex equ go_word4
go_td_prevCommandDir equ go_word5
go_td_commandAddr equ go_long0
go_td_pathTableAddr equ go_long1
go_td_basePathTableAddr equ go_long2
go_td_x equ go_timerl+0
go_td_y equ go_timerl+2
go_td_spawnerSide equ go_rot

TD_InitSpawner:
    GO_SET_INVISIBLE
    ;move #20,go_word0(a0)
    move #60,go_timer(a0)
    move.l #.firstTime,go_onUpdate(a0)
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    move.w PARAM_TD_SPAWNER_STARTSIDE(a1),go_td_spawnerSide(a0)
    move.w PARAM_TD_SPAWNER_ROTANDDIRLIST_NUM(a1),d0
    lsr #1,d0
    move d0,go_td_numCommands(a0)        ; num commands
    lea PARAM_TD_SPAWNER_ROTANDDIRLIST_DATA(a1),a2
    move.l a2,go_td_commandAddr(a0)

    move #-1,go_td_prevCommandDir(a0)
    move #-1,go_td_commandDir(a0)
    move #0,go_td_commandIndex(a0)
    
    move go_td_spawnerSide(a0),d0
    lsl #8,d0
    move.l g_td+td_m_pathlists,a1
    add d0,a1
    move.b #-1,(a1)+
    move.l a1,go_td_pathTableAddr(a0)
    move.l a1,go_td_basePathTableAddr(a0)       ; for use by crawlers
    
    lea g_td+td_spawnerGoList,a1
    move go_td_spawnerSide(a0),d0
    lsl #2,d0
    move.l a0,(a1,d0)
    
    rts
.firstTime:
    move go_x(a0),d0
    asr #4,d0
    move d0,go_td_x(a0)
    move go_y(a0),d0
    asr #4,d0
    move d0,go_td_y(a0)
    move #0,go_timer(a0)
    
.buildupdate_getcommand:
    add #1,go_td_commandIndex(a0)
    move go_td_commandIndex(a0),d0
    cmp go_td_numCommands(a0),d0
    move go_td_numCommands(a0),d1
    cmp d1,d0
    bgt .commands_done

    move go_td_commandDir(a0),go_td_prevCommandDir(a0)

    move.l go_td_commandAddr(a0),a1
    move (a1)+,go_td_commandDir(a0)     ; 
    move (a1)+,go_td_commandNumSpaces(a0)
    move.l a1,go_td_commandAddr(a0)

    move.l #.buildupdate_docommand,go_onUpdate(a0)
    move #0,go_td_buildCount(a0)
    



.buildupdate_docommand:
    sub #1,go_timer(a0)
    bge .buildupdate_docommand_waiting
    move #1,go_timer(a0)
    
    
    bsr TD_GetTile
    
    move go_td_x(a0),d0
    move go_td_y(a0),d1
;    move #TD_TUNNELGFX_0,d2
    move go_td_spawnerSide(a0),d4
    lsl #2,d4
    add d4,d2
    ;move #PAL_0,d3
    bsr TD_SetSingleTile
    
    move go_td_commandDir(a0),d0
    lsl #2,d0
    move.w .dirs(pc,d0),d1
    add d1,go_td_x(a0)
    move.w .dirs+2(pc,d0),d1
    add d1,go_td_y(a0)

    move go_td_commandDir(a0),d0
    
    ; build out list of dirs for use by walkers. Should maybe do this at the start
    move.l go_td_pathTableAddr(a0),a1
    move.b d0,(a1)+
    move.b #-1,(a1) ; end
    move.l a1,go_td_pathTableAddr(a0)
    
    add #1,go_td_buildCount(a0)
    move go_td_buildCount(a0),d0
    cmp go_td_commandNumSpaces(a0),d0
    bge .buildupdate_getcommand
    
.buildupdate_docommand_waiting:    
    rts

.dirs:
    dc.w 0,-1,1,0,0,1,-1,0

.commands_done:
    move go_td_spawnerSide(a0),d0
    lsl #2,d0
    lea g_td+td_playerBulletPositions,a1
    add d0,a1
    move go_td_x(a0),d0
    lsl #4,d0
    move d0,(a1)+
    move go_td_y(a0),d0
    lsl #4,d0
    move d0,(a1)+


    move.l #.update,go_onUpdate(a0)
    move #20,go_word0(a0)
    
.update:
    rts
    
    

TD_GetTile:
    tst go_td_buildCount(a0)
    beq .corner
    bra .no


.corner:
    move go_td_prevCommandDir(a0),d0
    bmi .no
    move go_td_commandDir(a0),d1
    bmi .no
    
    lea .tiles,a1
    lsl #2,d0
    move.l (a1,d0),a1
    add d1,d1
    move (a1,d1),d2
    move 8(a1,d1),d3
    
    lsl #4,d2
    add #TD_TUNNELGFX_0,d2
    or #PAL_0,d3
    rts
    
    
.no:
    move #TD_TUNNELGFX_0,d2
    move #PAL_0,d3
    rts

.tiles:
    dc.l .prev_up
    dc.l .prev_right
    dc.l .prev_down
    dc.l .prev_left
    
.prev_up:
    dc.w 0,1,0,1
    dc.w 0,0,0,FLIP_H
.prev_right:
    dc.w 1,0,1,1
    dc.w FLIP_HV,0,FLIP_H,0
.prev_down:
    dc.w 1,1,0,1
    dc.w 0,FLIP_V,0,FLIP_HV
.prev_left:
    dc.w 1,1,1,0
    dc.w FLIP_V,0,0,0
    
; a0 is spawner address
Spawner_AddCrawler:
    lea TD_InitCrawler0,a1
    bsr TD_SpawnGameObject_Enemy
    beq .no
    move go_x(a0),go_x(a1)
    move go_y(a0),go_y(a1)
    add #8,go_x(a1)
    add #8,go_y(a1)
    move.l go_td_basePathTableAddr(a0),a2
    move.l a2,go_td_basePathTableAddr(a1)
    move.l a2,go_td_pathTableAddr(a1)
.no:
    rts

Spawner_AddBubble:
    lea TD_InitBubble,a1
    bsr TD_SpawnGameObject_Enemy
    beq .no
    move go_x(a0),go_x(a1)
    move go_y(a0),go_y(a1)
    add #8,go_x(a1)
    add #8,go_y(a1)
    move.l go_td_basePathTableAddr(a0),a2
    move.l a2,go_td_basePathTableAddr(a1)
    move.l a2,go_td_pathTableAddr(a1)
.no:
    rts






TD_InitBubble:
    bsr TD_InitCrawlerBase

    SETSPR SPRITE_TD_PAL0
    move #SPRFRAME_TD_PAL0_BUBBLE,go_frame(a0)
    move.l #TD_Update_Bubble,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    
    move.b #3,go_coltype(a0)
    
    move #3,go_speed(a0)    
    bsr TD_Crawler_SetSpeed
    
    rts

; a1 is enemy
; a0 is bullet 
.collided:
    PSG_PLAY_SFX PSGSFX_TD_BulletHitBubble
    PUSHALL
    jsr GOManager_DeleteObject
    POPALL
    jmp GOManager_DeleteObjectA1    ; delete enemy

TD_Update_Bubble:
.nextcommand:
    bsr TD_Crawler_SetSpeed

    move.l go_td_pathTableAddr(a0),a1
    moveq #0,d0
    move.b (a1)+,d0
    bmi .reachedend
    
    move.l a1,go_td_pathTableAddr(a0)
    lsl #3,d0
    lea .dirs(pc),a2
    add d0,a2

    moveq #0,d1
    move go_word1(a0),d1

    move.l (a2)+,d0
    asl.l d1,d0
    move.l d0,go_dx(a0)

    move.l (a2)+,d0
    asl.l d1,d0
    move.l d0,go_dy(a0)

    move go_word2(a0),go_timer(a0)
    move.l #.updateMove,go_onUpdate(a0)
    
.updateMove:
    
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)

    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    sub #1,go_timer(a0)
    ble .nextcommand
    rts
    
.doanim:
    move g_timer1_shr3,d0
    and #3,d0
    add d0,d0
    move .frames(pc,d0),d0 
    add go_word0(a0),d0
    move d0,go_frame(a0)
    rts
.frames:
    dc.w 0,1,2,1        
.dirs:
    dc.l 0,-1<<14,1<<14,0,0,1<<14,-1<<14,0
    

.notatnode:
    rts    

.reachedend:
    PSG_PLAY_SFX PSGSFX_TD_BubbleReachedEnd
    move.l #TD_AIR_BUBBLE,d0
    bsr TD_AddAir
    jmp GOManager_DeleteObject
    rts



;d0.l is air to add / sub
TD_AddAir:
    add.l d0,g_td+td_air
    bge .ok1
    move #0,g_td+td_air
.ok1
    cmp #TD_MAX_AIR,g_td+td_air
    ble .airok
    move #TD_MAX_AIR,g_td+td_air
.airok:
    rts

;-------------------------------------------------------------------------------------------


TD_InitSpawnerManager:
    GO_SET_INVISIBLE
    lea TD_SpawnerData,a1
    
    move sysg_levelIndex,d0
    cmp #TD_MAX_LEVELDATA,d0
    blt .levelindex
    move #TD_MAX_LEVELDATA,d0
.levelindex:
    lsl #2+2,d0
    add d0,a1    
    
    move.l (a1)+,go_timerl(a0)
    move.l (a1)+,go_long0(a0)
    move.l (a1)+,go_long1(a0)
    move go_timerl(a0),go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    move #60,go_timer(a0)
    rts
    
.update:
    sub #1,go_timer(a0)
    blt .doit
    rts
.doit:
    move go_timerl(a0),go_timer(a0)
    move.l go_long0(a0),d0
    add.l d0,go_timerl(a0)
    
    move.l go_timerl(a0),d0
    cmp.l go_long1(a0),d0
    bge .okok
    move.l go_long1(a0),go_timerl(a0)
.okok:
    lea g_td+td_spawnerGoList,a1
    jsr UTILS_GetRandWordFast
    and #3,d0
    lsl #2,d0
    add d0,a1
    cmp.l #-1,(a1)
    beq .okok
    
    jsr UTILS_GetRandWordFast
    and #15,d0
    bne .nobubble
    
    PUSHALL
    move.l (a1)+,a0
    bsr Spawner_AddBubble
    POPALL
    rts
.nobubble:    
    PUSHALL
    move.l (a1)+,a0
    bsr Spawner_AddCrawler
    POPALL
    rts

TD_InitPlayerCoffin:
    SETSPR SPRITE_TD_PAL0
    move #SPRFRAME_TD_PAL0_COFFIN,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    lea TD_Player_Position,a1
    move (a1)+,go_x(a0)
    move (a1)+,go_y(a0)
    rts
.update:
    rts

TD_InitPlayer:
    SETSPR SPRITE_TD_PAL0
    move #SPRFRAME_TD_PAL0_ARROW_U,go_frame(a0)

    move #0,g_td+td_currentFireDirection
    move.l #.update,go_onUpdate(a0)
    move #0,go_shootTimer(a0)
    rts

.update:
    move g_pad0_pressed,d0

    btst #pad_button_left,d0
    beq .noL
    move #3,g_td+td_currentFireDirection
.noL:
    btst #pad_button_right,d0
    beq .noR
    move #1,g_td+td_currentFireDirection
.noR:
    btst #pad_button_up,d0
    beq .noU
    move #0,g_td+td_currentFireDirection
.noU:
    btst #pad_button_down,d0
    beq .noD
    move #2,g_td+td_currentFireDirection
.noD:

    bsr TD_Player_SetPosAndFrame
    
    
    sub #1,go_shootTimer(a0)
    bgt .cant_shoot
    move #0,go_shootTimer(a0)
    
    
    move g_pad0_pressed,d0
    btst #pad_button_a,d0
    beq .noA
    move #0,g_td+td_currentBullet
    bra .shoot
.noA:
    btst #pad_button_b,d0
    beq .noB
    move #1,g_td+td_currentBullet
    bra .shoot
.noB:
    btst #pad_button_c,d0
    beq .noC
    move #2,g_td+td_currentBullet
    bra .shoot
.noC:

.cant_shoot
    rts
    
.shoot:
    move #TD_PLAYER_SHOTTIME,go_shootTimer(a0)

    PSG_PLAY_SFX PSGSFX_TD_PlayerShoot


    move g_td+td_currentFireDirection,d0  ; fire side
    lsl #2,d0
    lea g_td+td_playerBulletPositions,a2
    cmp.l #-1,(a2,d0)
    beq .noshot
    
    lea TD_InitPlayerBullet,a1
    bsr TD_SpawnGameObject_PlayerBullet
    move g_td+td_currentFireDirection,d0  ; fire side
    lsl #2,d0
    lea g_td+td_playerBulletPositions,a2
    
    add d0,a2
    move g_td+td_currentFireDirection,go_rot(a1)
    move (a2)+,go_x(a1)
    move (a2)+,go_y(a1)
    
    move #SPRFRAME_TD_PAL0_PLAYERBULLET1,d0
    add g_td+td_currentBullet,d0
    move d0,go_frame(a1)

    move g_td+td_currentBullet,d0
    move.b d0,go_coltype(a1)
    rts
.noshot:
    move #0,go_shootTimer(a0)
    rts

TD_Player_Position
    dc.w 16*9,16*7
    
TD_Player_SetPosAndFrame:
    lea TD_Player_Position,a1
    move (a1)+,go_x(a0)
    move (a1)+,go_y(a0)

    move g_td+td_currentFireDirection,d0
    add d0,d0
    add d0,d0
    lea .offsets,a1
    add d0,a1
    move (a1)+,d1
    add d1,go_x(a0)
    move (a1)+,d1
    add d1,go_y(a0)
    
    move g_td+td_currentFireDirection,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    rts
.frames:
    dc.w SPRFRAME_TD_PAL0_ARROW_U,SPRFRAME_TD_PAL0_ARROW_R,SPRFRAME_TD_PAL0_ARROW_D,SPRFRAME_TD_PAL0_ARROW_L    



.offsets
    dc.w 16,0,32,8
    dc.w 16,16,0,8

    
TD_InitPlayerBullet:    
    SETSPR SPRITE_TD_PAL0
    move.l #.collided,go_onCollided(a0)
    move.l #.first,go_onUpdate(a0)
    move #20,go_timer(a0)
    rts
.collided:
    jmp GOManager_DeleteObject
    
.first:

; find end of path
    move.l g_td+td_m_pathlists,a1
    move go_rot(a0),d0
    lsl #8,d0
    add d0,a1
    lea 1(a1),a1
.findlp:
    move.b (a1)+,d0
    bmi .found
    bra .findlp
.found:
    lea -1(a1),a1
    move.l a1,go_td_pathTableAddr(a0)

    move.l #.update,go_onUpdate(a0)
    move.l #TD_UpdatePlayerBullet,go_onUpdate(a0)
    rts
    
.update:


    move.l go_td_pathTableAddr(a0),a1
    moveq #0,d0
    move.b -(a1),d0
    bmi .die
    move.l a1,go_td_pathTableAddr(a0)
    
    lsl #2,d0
    lea .dirs(pc,d0),a1
    move (a1)+,d0
    add d0,go_x(a0)
    move (a1)+,d0
    add d0,go_y(a0)

    rts
.dirs:
    dc.w 0,16,-16,0,0,-16,16,0
    
.die:
    jmp GOManager_DeleteObject

    
    
TD_UpdatePlayerBullet:
    move #3,go_speed(a0)
    bsr TD_Crawler_SetSpeed
.nextcommand:



    move.l go_td_pathTableAddr(a0),a1
    moveq #0,d0
    move.b -(a1),d0
    bmi .reachedend
    
    move.l a1,go_td_pathTableAddr(a0)
    lsl #3,d0
    lea .dirs(pc),a2
    add d0,a2

    moveq #0,d1
    move go_word1(a0),d1

    move.l (a2)+,d0
    neg.l d0
    asl.l d1,d0
    move.l d0,go_dx(a0)

    move.l (a2)+,d0
    neg.l d0
    asl.l d1,d0
    move.l d0,go_dy(a0)

    move go_word2(a0),go_timer(a0)
    move.l #.updateMove,go_onUpdate(a0)
    
.updateMove:
    
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)

    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    sub #1,go_timer(a0)
    ble .nextcommand
    rts
    
.dirs:
    dc.l 0,-1<<14,1<<14,0,0,1<<14,-1<<14,0     
 .die:
     jmp GOManager_DeleteObject   
.notatnode:
    rts    

.reachedend:
    PSG_PLAY_SFX PSGSFX_TD_BubbleReachedEnd
    move.l #TD_AIR_BUBBLE,d0
    bsr TD_AddAir
    jmp GOManager_DeleteObject
    rts
     
    
TD_UpdateFlash:
    tst go_nocollisiontimer(a0)
    beq .ok
    sub #1,go_nocollisiontimer(a0)
    bne .ok
    move #PAL_0,go_sprAttributes(a0)
.ok:
    rts
; enemy in a1
TD_EnemyCollided:
    tst go_nocollisiontimer(a1)
    bne .ok
    sub #1,go_health(a1)
    ble .dead
    move #PAL_1,go_sprAttributes(a1)
    move #3,go_nocollisiontimer(a1)
.ok:
    rts
.dead:
    jmp GOManager_DeleteObjectA1
    

    
TD_InitCrawlerBase:
    move #2,go_health(a0)
    move #0,go_nocollisiontimer(a0)
    rts

; d0
TD_SetSprBase:
	move.w d0,go_sprtype(a0)
	move.l sysg_sprites_baseaddr2,a1
	move d0,d1
	lsl #2,d1
	move.l (a1,d1),go_sprgroup(a0)
	lea SpriteVDPOffsets,a1
	add d0,d0
	move.w (a1,d0),go_vdpbase(a0)
    rts


TD_InitCrawler0:
    
    move go_td_spawnerSide(a1),go_td_spawnerSide(a0)
    bsr TD_InitCrawlerBase

    SETSPR SPRITE_TD_PAL0
    move #SPRFRAME_TD_PAL0_ENEMYBEETLE,go_frame(a0)
    move.l #TD_Update_Crawler,go_onUpdate(a0)
    move #$100,go_speed(a0)
    move.l #.collided,go_onCollided(a0)
    
    jsr UTILS_GetRandWordFast
    and.l #$ff,d0
    divu #3,d0
    swap d0
    
    move.b d0,go_coltype(a0)
    
    move d0,d6
    add d0,d0
    add d0,d0
    move .animbases+2(pc,d0),go_word0(a0)
    move .animbases(pc,d0),d0
    bsr TD_SetSprBase

    move go_word0(a0),go_frame(a0)

    move d6,d0
    add d0,d0
    move.w .healths(pc,d0),go_health(a0)

    move #0,go_speed(a0)    
    bsr TD_Crawler_SetSpeed
    
    rts
.animbases:
    dc.w SPRITE_TD_PAL1,SPRFRAME_TD_PAL1_ENEMYMANTIS
    dc.w SPRITE_TD_PAL0,SPRFRAME_TD_PAL0_ENEMYBEETLE
    dc.w SPRITE_TD_PAL1,SPRFRAME_TD_PAL1_ENEMYSLUG

.healths:
    dc.w 1,1,1,1


; a1 is enemy
; a0 is bullet 
.collided:
    PUSHALL
    jsr GOManager_DeleteObject
    POPALL
    

    move.b go_coltype(a0),d0
    move.b go_coltype(a1),d1
    cmp.b d1,d0
    beq .same
    
    PSG_PLAY_SFX PSGSFX_TD_BulletHitWrongEnemy

    
    ;add #1,go_speed(a1)
    ;cmp #3,go_speed(a1)
    ;blt .nospeed
    move #3,go_speed(a1)
.nospeed
    rts
    
.same:

    tst go_nocollisiontimer(a1)
    bne .ok
    sub #1,go_health(a1)
    ble .dead
    move #PAL_1,go_sprAttributes(a1)
    move #3,go_nocollisiontimer(a1)
.ok:
    rts
.dead:
    PSG_PLAY_SFX PSGSFX_TD_BulletHitCorrectEnemy
    
    add.l #1,sysg_score
    bsr TD_TestHighScore
    
    move.l #TD_Crawler_UpdateDie,go_onUpdate(a1)
    move.b #4,go_coltype(a1)
    move.l #0,go_frame(a1)
    
    moveq #0,d0
    move.b go_coltype(a0),d0
    add d0,d0
    move .animbases1(pc,d0),d0
    move d0,go_frame(a1)
    add #4,d0
    move d0,go_word1(a1)
    
    rts
    
.animbases1:
    dc.w SPRFRAME_TD_PAL1_MANTISDIE
    dc.w SPRFRAME_TD_PAL0_BEETLEDIE
    dc.w SPRFRAME_TD_PAL1_SLUGDIE
    


TD_Crawler_UpdateDie:
    add.l #$4000,go_frame(a0)
    move go_frame(a0),d0
    cmp go_word1(a0),d0
    beq .die
    rts
.die:
    sub.l #$4000,go_frame(a0)
    jmp GOManager_DeleteObject    ; delete enemy

TD_Crawler_SetSpeed:
    move go_speed(a0),d0
    add d0,d0
    move.w .speeds(pc,d0),go_word1(a0)  ; shift
    move.w .speeds+8(pc,d0),go_word2(a0)  ; time
    rts
.speeds:
    dc.w 0,1,2,3
    dc.w 64,32,16,8

TD_Update_Crawler:
.nextcommand:
    bsr TD_Crawler_SetSpeed

    move.l go_td_pathTableAddr(a0),a1
    moveq #0,d0
    move.b (a1)+,d0
    bmi .reachedend
    
    move.l a1,go_td_pathTableAddr(a0)
    lsl #3,d0
    lea .dirs(pc),a2
    add d0,a2

    moveq #0,d1
    move go_word1(a0),d1

    move.l (a2)+,d0
    asl.l d1,d0
    move.l d0,go_dx(a0)

    move.l (a2)+,d0
    asl.l d1,d0
    move.l d0,go_dy(a0)

    move go_word2(a0),go_timer(a0)
    move.l #.updateMove,go_onUpdate(a0)
    
.updateMove:
    bsr TD_UpdateFlash
    bsr .doanim
    
    move #0,d0
    tst go_dx(a0)
    bge .noflip
    move #FLIP_H,d0
.noflip:
    move d0,go_sprAttributes(a0)
    
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)

    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    sub #1,go_timer(a0)
    ble .nextcommand
    rts
    
.doanim:
    move g_timer1_shr3,d0
    and #3,d0
    add d0,d0
    move .frames(pc,d0),d0 
    add go_word0(a0),d0
    move d0,go_frame(a0)
    rts
.frames:
    dc.w 0,1,2,1        
.dirs:
    dc.l 0,-1<<14,1<<14,0,0,1<<14,-1<<14,0
    

.notatnode:
    rts    

.reachedend:
    PSG_PLAY_SFX PSGSFX_TD_EnemyReachedEnd
    move.l #TD_AIR_HITENEMY,d0
    bsr TD_AddAir
    jmp GOManager_DeleteObject
    rts


TD_InitPath:
    lsl #2,d0
    move.l sysg_levelInfo+levelinfo_paths,a1
    move.l (a1,d0),a1
    move.w #0,go_cpath+cpath_currentNode(a0)
    move.w (a1)+,go_cpath+cpath_numNodes(a0)
    move.l a1,go_cpath+cpath_firstNodeAddr(a0)
    rts
    

TD_InitWorldAndLevelStuff_GFX:
    jsr TD_InitVDPForLevel

    rts

TD_UpdateGameStuff:
    tst g_td+td_state
    bne .no

    sub #1,g_td+td_timer_subhours
    bgt .nosub
    move #TD_TIME_SUBHOURS,g_td+td_timer_subhours
    sub #1,g_td+td_timer_hours
    bgt .nosub
    move #0,g_td+td_timer_hours
    
    move.l #InitState_LevelOver,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut
    move #1,g_td+td_state

.nosub:
    move.l #TD_AIR_PERFRAME,d0
    bsr TD_AddAir
    
.no:
    rts

    
TD_PlayMusic:
    move #0,d0
    jsr MUSIC_InitSong
    rts
    
TD_InitVDPForLevel:
    jsr ClearVRAM

    lea SPRPAL_TD_Pal0,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource

    lea SPRPAL_TD_Pal1,a0
    move #1,d0
    jsr FADE_CopySinglePaletteToSource

;    lea SPRPAL_Whiteout,a0
;    move #1,d0
;    jsr FADE_CopySinglePaletteToSource
;    jsr FADE_Update

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP

    
	move #FONT_UNDERGROUND_PAL1,g_font_index
	move #1,g_font_palette_index
    jsr FONT_Init
    ;jsr FONT_LoadPalette
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
	
    bsr TD_InitBackgroundTiles
	
    rts
    
.sprites:
    dc.w SPRITE_TD_PAL0_TUNNELS
    dc.w SPRITE_TD_PAL0
    dc.w SPRITE_TD_PAL1
    dc.w -1


TD_InitBackgroundTiles:

    move g_vram_currentpos,g_vram_bg

    
    ;move.l sysg_levelInfo+levelinfo_palette0,a0 
    ;move 2(a0),d0
    ;lea 4(a0),a0
    ;jsr FADE_CopySinglePaletteToSource

    ;move.l sysg_levelInfo+levelinfo_palette1,a0 
    ;move 2(a0),d0
    ;lea 4(a0),a0
    ;jsr FADE_CopySinglePaletteToSource
    
    
    ;move.l sysg_levelInfo+levelinfo_tileData0,a4	;tile start     
    ;move.w imagecells_numcells(a4),d6
    ;move g_vram_currentpos,d0
    ;move.w d0,g_vram_bg
    ;add d6,g_vram_currentpos
    ;move.w	g_vram_bg,d1
    ;lsl #5,d1
    ;jsr	VDP_BuildVRAMWriteAddress
    ;move.l a4,a0
    ;jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags

    ;move.l sysg_levelInfo+levelinfo_tileData1,a4	;tile start     
    ;move.w imagecells_numcells(a4),d6
    ;move g_vram_currentpos,d0
    ;move.w d0,g_vram_fg
    ;add d6,g_vram_currentpos
    ;move.w	g_vram_fg,d1
    ;lsl #5,d1
    ;jsr	VDP_BuildVRAMWriteAddress
    ;move.l a4,a0
    ;jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags
    
    move #IMAGEASSET_TD_BACKDROP,d0
	jsr IMAGE_ShowStaticImagePlaneB        


; set up addr of tiles in ROM
	;move g_image_index,d0
	;move.l g_image_groupbase,a0	
	;jsr UNITYTOOL_GetImageData
	;move.l image_cells(a0),g_hol_romTileMapAddr

    rts


TD_UpdateGame:
    tst.b g_td+td_levelOverFlag
    bne .no

    jsr UTILS_GetRandWord
    bsr TD_UpdateGame_UpdateGlobals
    bsr TD_UpdateGame_Normal  
    jsr Game_UpdateRealtimeCommands      
      
    tst g_td+td_air
    bgt .noair
    move.b #1,g_td+td_levelOverFlag
    move.l #InitState_GameOver,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut
    
.noair:
      
.no:
    rts
    
TD_TestHighScore:    
    move.l sysg_score,d0
    cmp.l sysg_highscore,d0
    ble .nohighscore
    move.l d0,sysg_highscore
.nohighscore
    rts    

TD_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
TD_UpdateGame_UpdateGlobals:
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

    

TD_UpdateGame_Normal:
    bsr Racing_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    jsr GOManager_Update
	jsr SPRITE_UpdateFromGOManager_Racing
	bsr TD_BulletEnemyCollision
	
	bsr TD_UpdateGameStuff
    rts


TD_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr TD_UpdateScrollRegisters


    bsr VBL_DMAAirBar
    ;jsr Scroll_DumpEdgesToVDPA
    ;jsr Scroll_DumpEdgesToVDPB
    
	rts


VBL_DMAAirBar:
    
    lea SPRDEF_TD_Pal0_HudMeter_VDP+4,a0

    move #(32<<8)/TD_MAX_AIR,d0
    mulu g_td+td_air,d0
    lsr #8,d0
    lsl #5+2,d0
    add d0,a0
        
    move #TD_AIRMETER_VDPINDEX,d1
    lsl #5,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	

    bsr TD_UploadChars
    rts

TD_UploadChars:
    rept 4
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	endr
	rts
    

;-------------------------------------------------------------


TD_UpdateScrollRegisters:

	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_FULL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL
    
    AUTOINC 2
; hscroll
	
	move g_scroll_x,d0
	add g_screenshake_x,d0
	;and #15,d0
	neg d0
	move #0,d0
	
	SCROLL_START_WRITE_XPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
    AUTOINC 2
    move g_scroll_y,d0
    add g_screenshake_y,d0
    and #255,d0
    move #0,d0
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
	rts

    
    

    
    
 
 
 
 ;----------------------------------------------------------------------------------------------
 
 TD_SpawnStuff:
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
     bsr TD_FindSpawnEntryFromSpawner
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

 ;----------------------------------------------------------------------------------------------
 ; a5 is spawner entry
 ; returns a4 for spawner entry. 0 if none found
TD_FindSpawnEntryFromSpawner:
     lea TD_SpawnTab,a4
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

 

 
 TD_SpawnTab:
     SPAWNTABENTRY SPRDEF_TD_SPAWNER,0,TD_SpawnGameObject_General,TD_InitSpawner


; d0 / d1 x,y, d2 = tile index, d3 = pal     
TD_SetSingleTile:
    PUSHALL
    cmp #0,d0
    blt .clip
    cmp #0,d1
    blt .clip
    

    move d0,d6
    move d1,d7
    move d2,d5
    move d3,d4
    
    lea .offsets,a4
    and #FLIP_HV,d3
    
    cmp #0,d3
    beq .off0
    cmp #FLIP_H,d3
    beq .off1
    cmp #FLIP_V,d3
    beq .off2
    cmp #FLIP_HV,d3
    beq .off3
    
.off0:
    lea .offsets,a4
    bra .off99
.off1:
    lea .offsets+8,a4
    bra .off99
.off2:
    lea .offsets+16,a4
    bra .off99
.off3:
    lea .offsets+24,a4
.off99
    
    
    
; tile 0    
	move.l #VDPADDR_SCROLL_A,d1
    move d6,d0
	lsl #2,d0
	add d0,d1
	move d7,d0
	lsl #8,d0
	add d0,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    move d5,d0
    add (a4)+,d0
    or d4,d0
    move d0,VDP_DATA

; tile 1 (x+1)   
	move.l #VDPADDR_SCROLL_A,d1
    move d6,d0
	lsl #2,d0
    add #2,d0
	add d0,d1
	move d7,d0
	lsl #8,d0
	add d0,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    move d5,d0
    add (a4)+,d0
    or d4,d0
    move d0,VDP_DATA
    
; tile 2 (y+1)   
	move.l #VDPADDR_SCROLL_A,d1
    move d6,d0
	lsl #2,d0
	add d0,d1
	move d7,d0
	lsl #8,d0
	add #128,d0
	add d0,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    move d5,d0
    add (a4)+,d0
    or d4,d0
    move d0,VDP_DATA

; tile 3 (x+1,y+1)   
	move.l #VDPADDR_SCROLL_A,d1
    move d6,d0
	lsl #2,d0
    add #2,d0
	add d0,d1
	move d7,d0
	lsl #8,d0
	add #128,d0
	add d0,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    move d5,d0
    add (a4)+,d0
    or d4,d0
    move d0,VDP_DATA

.clip:
    
    POPALL
    rts
    
.offsets:
    dc.w 0,2,1,3
    dc.w 2,0,1,3        ;h
    dc.w 1,3,0,2        ;v
    dc.w 2,3,1,0


TD_COL_RADX equ 6
TD_COL_RADY equ 6
TD_BulletEnemyCollision:

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
    add #8,d0
    add #8,d1
    
    
    jsr GOManager_GetList_Car        ; enemies
    move.l a3,a4
    move golist_num_active(a4),d6
    beq .nobullets
    move.l golist_active_list_addr(a4),a4
    subq #1,d6
    
.loop2:
    tst.b go_activestate(a0)
    beq .skipEnemy

    move.l (a4)+,a1
    
    cmp.b #4,go_coltype(a1)
    beq .skipEnemy
    
    cmp.b #3,go_coltype(a1) 
    beq .isbubble
    move go_td_spawnerSide(a1),d2
    cmp go_rot(a0),d2
    bne .skipEnemy
.isbubble:
    
    move go_x(a1),d2
    sub d0,d2

    move go_y(a1),d3
    sub d1,d3
    
    cmp #TD_COL_RADX,d2
    bgt .skipEnemy
    cmp #-TD_COL_RADX,d2
    blt .skipEnemy
    
    
    cmp #TD_COL_RADX,d3
    bgt .skipEnemy
    cmp #-TD_COL_RADX,d3
    blt .skipEnemy

; callback on enemy
    PUSHALL
    move.l go_onCollided(a1),d0
    beq .nocolfunc2
    move.l d0,a5
    jsr (a5)
.nocolfunc2:
    POPALL
    bra .skipbullet
    
.skipEnemy:
    dbra d6,.loop2

.skipbullet:
    dbra d7,.loop1
    
.nobullets:
    rts


;----------------------------------------------------------------------------------------------------

TD_InitHUD:
    SETSPR SPRITE_TD_PAL0
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.render,go_onRender(a0)
    rts

.update:
    rts
    
.render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)

    
    bsr .rendercolors
    bsr .timer
    bsr .score
    bsr .airbar
    rts
   

    rts

.timer:

    move #130,d5
    move #5+3,d6
    move #SPRFRAME_TD_PAL0_HUD_TIMER,d1
    bsr TD_Hud_DoOne

    move #130+8,d5
    move #5,d6
    move g_td+td_timer_hours,d4
    bsr .renderNumber2

    rts

.score:

    move #5,d5
    move #5,d6
    move sysg_score+2,d4
    bsr .renderNumber5

    rts

.airbar:
    move #70,d5
    move #5+3,d6
    move #SPRFRAME_TD_PAL0_HUD_AIR,d1
    bsr TD_Hud_DoOne

    move #(32<<8)/TD_MAX_AIR,d1
    mulu g_td+td_air,d1
    lsr #8,d1
    add #SPRFRAME_TD_PAL0_HUDAIRBARFIRST,d1
    move #SPRFRAME_TD_PAL0_HUDAIRBARFIRST,d1
    move #70+8,d5
    move #5,d6
    bsr TD_Hud_DoOne
    rts


    rts

TD_HUDX0 equ 200
TD_HUDX1 equ 240
TD_HUDX2 equ 280

.rendercolors:
    move #TD_HUDX0,d5
    move #5,d6
    move #SPRFRAME_TD_PAL0_HUDA,d1
    bsr TD_Hud_DoOne

    move #TD_HUDX0+10,d5
    move #5,d6
    move #SPRFRAME_TD_PAL0_PLAYERBULLET1,d1
    bsr TD_Hud_DoOne

    move #TD_HUDX1,d5
    move #5,d6
    move #SPRFRAME_TD_PAL0_HUDB,d1
    bsr TD_Hud_DoOne

    move #TD_HUDX1+10,d5
    move #5,d6
    move #SPRFRAME_TD_PAL0_PLAYERBULLET2,d1
    bsr TD_Hud_DoOne

    move #TD_HUDX2,d5
    move #5,d6
    move #SPRFRAME_TD_PAL0_HUDC,d1
    bsr TD_Hud_DoOne

    move #TD_HUDX2+10,d5
    move #5,d6
    move #SPRFRAME_TD_PAL0_PLAYERBULLET3,d1
    bsr TD_Hud_DoOne
    rts

;d4
.renderNumber5:
    move d4,d0
    lea g_td+td_fontdrawarea,a1
    bsr TD_Hud_RenderNumber5
    lea g_td+td_fontdrawarea,a1
    bra .renderstring

.renderNumber2
    lea FONT_NumberTable_W_2,a1
    lsl #2,d4
    add d4,a1

;a1
.renderstring:
	moveq #0,d1		
	move.b	(a1)+,d1	
	beq .stringEnd		
	sub.b #'0',d1
	add #SPRFRAME_TD_PAL0_HUDNUM0,d1
	bsr TD_Hud_DoOne
	add #8,d5
	bra.s	.renderstring
.stringEnd:

    rts
    
TD_Hud_DoOne:
    move d1,sprbuf_frame(a5)
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts
    
TD_Hud_RenderNumber5
    PUSHALL
    and.l #$ffff,d0

	moveq #0,d5
	move d0,d5

	move d5,d0
	divu #10000,d0
	bsr .char

	clr.w d0
	swap d0
	divu #1000,d0
	bsr .char

	clr.w d0
	swap d0
	divu #100,d0
	bsr .char

	clr.w d0
	swap d0
	divu #10,d0
	bsr .char

	clr.w d0
	swap d0
	bsr .char
    POPALL
	rts

.char:
	move d0,d2
	add #'0',d2
	move.b  d2,(a1)+
	move.b #0,(a1)
	rts

TD_MAX_LEVELDATA equ 14
TD_SpawnerData:
    dc.l 60<<16,-1<<16,50<<16,0
    dc.l 50<<16,-1<<16,40<<16,0
    dc.l 40<<16,-1<<16,35<<16,0
    dc.l 40<<16,-1<<16,30<<16,0
    dc.l 40<<16,-1<<16,29<<16,0
    dc.l 40<<16,-1<<16,28<<16,0
    dc.l 40<<16,-1<<16,27<<16,0
    dc.l 40<<16,-1<<16,26<<16,0
    dc.l 40<<16,-1<<16,25<<16,0
    dc.l 40<<16,-1<<16,24<<16,0
    dc.l 40<<16,-1<<16,23<<16,0
    dc.l 40<<16,-1<<16,22<<16,0
    dc.l 40<<16,-1<<16,21<<16,0
    dc.l 40<<16,-1<<16,20<<16,0
    dc.l 40<<16,-1<<16,20<<16,0
