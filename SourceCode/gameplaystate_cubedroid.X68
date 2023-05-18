
;CD_PLAYER_SPEED equ 2
;CD_PLAYER_SPEEDAMT equ 8
CD_PLAYER_SPEED equ 1
CD_PLAYER_SPEEDAMT equ 16

CD_STARTLEVEL equ 0
CD_STARTBG equ 0

CUBEDROID_SKIP_LANDING_SEQUENCE equ 1
CUBEDROID_SKIP_END_SEQUENCE equ 1

CUBEDROID_MAP_W equ 12
CUBEDROID_MAP_H equ 12
CUBEDROID_MAP_SIZE equ 12*12




CUBEDROID_NUM_LEVELS equ 36

EndState_CD:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts


InitState_CD:
    ;bra InitState_CDLS
    move #CD_STARTLEVEL,sysg_cd+cd_levelIndex
    move #CD_STARTBG,sysg_cd+cd_backgroundIndex
    
    
InitState_CD2:

	jsr Globals_ClearAll
    jsr MEM_Init
    jsr MEM_Init
    jsr MEM_AllocForGame_CubeDroid 
	jsr ClearVRAM
	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
	move #REG_MODE4|REGMASK_MODE4_H32|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
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

	jsr SOUND_Init
	jsr SCROLL_SetNormalPlanes
    move #0,g_scroll_x
    move #0,g_scroll_y

	move.l #CD_UpdateGame,g_game_loopaddr
	move.l #CD_UpdateVBL,g_game_vbladdr

    bsr CD_RestartLevel

    rts

CD_PlayLevelCompleteMusic:
    moveq #SONG_CUBEDROID_ENDLEVEL,d0     
    jsr MUSIC_InitSong
    rts

CD_PlayFinishedMusic:
    move sysg_cd+cd_currentLevelMusic,d0
    move.b .musdata(pc,d0),d0     
    jsr MUSIC_InitSong
    rts
.musdata:
    dc.b SONG_CUBEDROID_A_FAST,SONG_CUBEDROID_A_FAST
    dc.b SONG_CUBEDROID_A_FAST,SONG_CUBEDROID_A_FAST

CD_PlayMusic:
    add #1,sysg_cd+cd_currentLevelMusic
    cmp #2,sysg_cd+cd_currentLevelMusic
    blt .ok
    move #0,sysg_cd+cd_currentLevelMusic
.ok:

    move sysg_cd+cd_currentLevelMusic,d0
    move.b .musdata(pc,d0),d0     
    jsr MUSIC_InitSong
    rts
.musdata:
    dc.b SONG_CUBEDROID_A,SONG_CUBEDROID_A
    dc.b SONG_CUBEDROID_A,SONG_CUBEDROID_A

CD_RestartLevel:
    jsr CD_InitLevelPointers

    bsr CD_InitWorldAndLevelStuff_GFX
    bsr CD_InitWorldAndLevelStuff_Mem
    jsr CD_ClearGrid
    bsr CD_InitSolid
    moveq #0,d0
    ifd CUBEDROID_SKIP_LANDING_SEQUENCE
    jsr CD_DrawTileMap
    jsr CD_InitSpawners
    endif
    bsr CD_InitHud
    bsr CD_PlayMusic

	FADE_SETVALUE 0
	FADE_START_IN 0
    
    rts
    
CD_InitForGame:
    rts
    

CD_InitForLevel:
    rts
    

CD_InitWorldAndLevelStuff_Mem:
    bsr CD_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    jsr CD_InitGOs
    bsr CD_StartLevelStartSequence
    rts
    
CD_InitGOs:
    rts

CD_StartLevelEndSequence:
    bsr CD_ClearAllTileSprites
    lea CD_InitMapBreakerController,a1
    bsr CDGenType_Normal
    rts    

CD_StartLevelStartSequence:
    ifd CUBEDROID_SKIP_LANDING_SEQUENCE
    rts
    endif
    ;move #$8000,d0
    ;jsr CD_DrawTileMap

    bsr CD_ClearAllTileSprites
    lea CD_InitMapStarterController,a1
    bsr CDGenType_Normal
    rts    

    
CD_SPRLIST_NUM_NORMAL equ SPRLIST_NUM_FX
CD_ClearAllTileSprites:
    PUSHALL
    bsr CD_GetGOList_Normal     ; a3
    move.l golist_active_list_addr(a3),a1
    move golist_num_active(a3),d7
    beq .r
    subq #1,d7
.lp:
    move.l (a1)+,a0
    PUSHALL
    jsr GOManager_DeleteObject
    POPALL
    dbra d7,.lp
.r: 
    POPALL
    rts
    
    

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitCannonU:
    move #0,go_rot(a0)
    bra  CD_InitCannon
CD_InitCannonR:
    move #1,go_rot(a0)
    bra  CD_InitCannon
CD_InitCannonD:
    move #2,go_rot(a0)
    bra  CD_InitCannon
CD_InitCannonL:
    move #3,go_rot(a0)
    bra  CD_InitCannon

CD_InitCannon:
    SETSPR SPRITE_CUBEDROID_CANNON
    move #0,go_frame(a0)
    move.l #.state_firsttime,go_onUpdate(a0)
    move #PRIORITY,go_sprAttributes(a0)
    
    move go_rot(a0),d0
    add d0,d0
    move d0,go_frame(a0)
    rts

.state_firsttime:
    bsr CD_WriteGOSolid
    
    move.l #.state_waiting,go_onUpdate(a0)
.state_waiting:
    tst sysg_cd+cd_allBatteriesCollected
    beq .ok      ; can't do stuff until batteries collected
    move.l #.state_shooting,go_onUpdate(a0)
    add #1,go_frame(a0)
.state_shooting:

    sub #1,go_timer(a0)
    bgt .ok
    move #30,go_timer(a0)
    bsr .testshoot
.ok:
    rts    


.testshoot:
    move go_rot(a0),d0
    beq .up
    cmp #1,d0
    beq .right
    cmp #2,d0
    beq .down
    cmp #3,d0
    beq .left
    rts

.right:
    bsr CD_IsPlayerSameY
    beq .noshoot
    bsr CD_GetPlayerSideOfObjX
    ble .noshoot
    lea CD_InitCannonBullet_R,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts

.down:
    bsr CD_IsPlayerSameX
    beq .noshoot
    bsr CD_GetPlayerSideOfObjY
    ble .noshoot
    lea CD_InitCannonBullet_D,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts

.left:
    bsr CD_IsPlayerSameY
    beq .noshoot
    bsr CD_GetPlayerSideOfObjX
    bge .noshoot
    lea CD_InitCannonBullet_L,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts

.up:
    bsr CD_IsPlayerSameX
    beq .noshoot
    bsr CD_GetPlayerSideOfObjY
    bge .noshoot
    lea CD_InitCannonBullet_U,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts

    
.noshoot:
    rts
    
    
    



CD_GetPlayerSideOfObjX
    move.l g_player,a1
    move go_x(a0),d0
    lsr #4,d0
    move go_x(a1),d1
    lsr #4,d1
    cmp d0,d1
    beq .same
    bgt .higher
.lower
    moveq #-1,d0
    rts
.higher
    moveq #1,d0
    rts
.same:
    moveq #0,d0
    rts

CD_GetPlayerSideOfObjY
    move.l g_player,a1
    move go_y(a0),d0
    lsr #4,d0
    move go_y(a1),d1
    lsr #4,d1
    cmp d0,d1
    beq .same
    bgt .higher
.lower
    moveq #-1,d0
    rts
.higher
    moveq #1,d0
    rts
.same:
    moveq #0,d0
    rts


; 0 if NOT teh same y
CD_IsPlayerSameY:
    move.l g_player,a1
    move go_y(a0),d0
    lsr #4,d0
    move go_y(a1),d1
    lsr #4,d1
    cmp d1,d0
    bne .no
    moveq #1,d0
    rts
.no:
    moveq #0,d0
    rts

CD_IsPlayerSameX:
    move.l g_player,a1
    move go_x(a0),d0
    lsr #4,d0
    move go_x(a1),d1
    lsr #4,d1
    cmp d1,d0
    bne .no
    moveq #1,d0
    rts
.no:
    moveq #0,d0
    rts

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitMoverU:
    bsr CD_InitMover
    move #0,go_rot(a0)
    
    rts
CD_InitMoverR:
    bsr CD_InitMover
    move #1,go_rot(a0)
    rts
CD_InitMoverD:
    bsr CD_InitMover
    move #2,go_rot(a0)
    rts
CD_InitMoverL:
    bsr CD_InitMover
    move #3,go_rot(a0)
    rts

CD_InitMover:
    SETSPR SPRITE_CUBEDROID_DIRECTIONALMOVER
    move #0,go_frame(a0)
    move #PRIORITY,go_sprAttributes(a0)
    
    move.l #.state_first,go_onUpdate(a0)
    move #60,go_timer(a0)
    rts 
.state_first:
    bsr CD_WriteGOSolid
    sub #1,go_timer(a0)
    bgt .r
    move.l #.state_waiting,go_onUpdate(a0)
.r: rts
    
.state_waiting:
    bsr .setframe
    
    move go_rot(a0),d0
    lea .offsets,a1
    lsl #2,d0
    add d0,a1
    move (a1)+,d0
    add go_x(a0),d0
    move (a1)+,d1
    add go_y(a0),d1

    bsr .testForSolid
    
    tst d0
    beq .canmove
    rts  
.canmove:
    
    move go_x(a0),go_oldx(a0)
    move go_y(a0),go_oldy(a0)
    bsr CD_WriteGOSolid
    
    move go_rot(a0),d0
    lea .ds,a1
    lsl #2,d0
    add d0,a1
    move (a1)+,go_dx(a0)
    move (a1)+,go_dy(a0)
    
    lea .offsets,a1
    move go_rot(a0),d0
    lsl #2,d0
    add d0,a1
    move go_x(a0),d0
    add.w (a1)+,d0
    move.w d0,go_tox(a0)
    move go_y(a0),d0
    add.w (a1)+,d0
    move.w d0,go_toy(a0)
    
    bsr CD_WriteToGOSolid
    
    move #16,go_timer(a0)
    move.l #.state_moving,go_onUpdate(a0)
    bsr CD_ClearGOToGrid
    rts

.state_moving:
    move go_dx(a0),d0
    add d0,go_x(a0)
    move go_dy(a0),d0
    add d0,go_y(a0)
    sub #1,go_timer(a0)
    bgt .nomove
    move.l #.state_waiting,go_onUpdate(a0)
    bsr CD_ClearOldGOSolid
    bsr CD_WriteGOToGrid
    bsr CD_ClearGOOldPosSolid
.nomove:
    rts        
    
.testForSolid:
    move d0,d5
    move d1,d6
    bsr CD_GetIsSolid
    bne .isSolid
    
    move d5,d0
    move d6,d1
    bsr CD_GetObjAt
    cmp.l #0,a1
    bne .isSolid
    moveq #0,d0
    rts  
.isSolid:
    moveq #1,d0
    rts

.setframe:
    move go_rot(a0),d0
    add d0,d0
    move d0,go_frame(a0)
    rts    

.ds:
    dc.w 0,-1,  1,0, 0,1, -1,0

.offsets:
    dc.w 0,-16,  16,0, 0,16, -16,0


;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitRollerSaw:
    SETSPR SPRITE_CUBEDROID_ROLLERSAW
    move #0,go_frame(a0)
    move.l #.state_waiting,go_onUpdate(a0)
    move #0,go_rot(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts
.state_waiting:
    
    move go_rot(a0),d0
    lea .offsets,a1
    lsl #2,d0
    add d0,a1
    move (a1)+,d0
    add go_x(a0),d0
    move (a1)+,d1
    add go_y(a0),d1

    bsr .testForSolid
    
    tst d0
    beq .canmove
    add #1,go_rot(a0)
    and #3,go_rot(a0)
    rts  
.canmove:
    move go_x(a0),go_oldx(a0)
    move go_y(a0),go_oldy(a0)
    
    bsr CD_WriteGOSolid
    
    move go_rot(a0),d0
    lea .ds,a1
    lsl #3,d0
    add d0,a1
    move.l (a1)+,go_dx(a0)
    move.l (a1)+,go_dy(a0)
    
    lea .offsets,a1
    move go_rot(a0),d0
    lsl #2,d0
    add d0,a1
    move go_x(a0),d0
    add.w (a1)+,d0
    move.w d0,go_tox(a0)
    move go_y(a0),d0
    add.w (a1)+,d0
    move.w d0,go_toy(a0)
    
    bsr CD_WriteToGOSolid
    
    move #16*4,go_timer(a0)
    move.l #.state_moving,go_onUpdate(a0)
    bsr CD_ClearGOToGrid
    rts

.state_moving:
    bsr .animate

    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    sub #1,go_timer(a0)
    bgt .nomove
    move.l #.state_waiting,go_onUpdate(a0)
    bsr CD_ClearOldGOSolid
    bsr CD_WriteGOToGrid
    bsr CD_ClearGOOldPosSolid
.nomove:
    rts        
    
.testForSolid:
    bsr CD_GetIsSolid
    rts  

.animate:
    move g_timer1_shr4,d0
    and #3,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    rts
    
.frames: dc.w 0,1,2,1

.ds:
    dc.l 0,-$4000,  $4000,0, 0,$4000, -$4000,0

.offsets:
    dc.w 0,-16,  16,0, 0,16, -16,0

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_DIR_U equ 0 
CD_DIR_R equ 1 
CD_DIR_D equ 2 
CD_DIR_L equ 3 

CD_GuardianGetDirection:
    move.l g_player,a1
    moveq #0,d0
    lea Scratchpad,a2
    lea Scratchpad+8,a3

    move go_x(a1),d1
    sub go_x(a0),d1
    blt .x_left
    bgt .x_right
.x_left:
    move #CD_DIR_L,(a2)+
    move #CD_DIR_R,-(a3)
    bra .x_done
.x_right:
    move #CD_DIR_R,(a2)+
    move #CD_DIR_L,-(a3)
.x_done:    
    
    move go_y(a1),d1
    sub go_y(a0),d1
    blt .y_up
    bgt .y_down
.y_up:
    move #CD_DIR_U,(a2)+
    move #CD_DIR_D,-(a3)
    bra .y_done
.y_down:
    move #CD_DIR_D,(a2)+
    move #CD_DIR_U,-(a3)
    bra .y_done
.y_done:    


    lea Scratchpad,a3 
; randomly swap the first two
    jsr UTILS_GetRandWordFast
    move d0,d6
    and #1,d0
    beq .noswap0
    move (a3),d0
    move 2(a3),d1
    move d1,(a3)
    move d0,2(a3)
.noswap0:
; second two
    and #4,d6
    beq .noswap1
    move 4(a3),d0
    move 6(a3),d1
    move d1,6(a3)
    move d0,4(a3)
.noswap1:

    ; scratchpad now contains preferred order of directions
   
    lea Scratchpad,a3 
    move #4-1,d6
.lp:
    move (a3)+,d0
    move d0,go_rot(a0)
    lea .offsets,a1
    lsl #2,d0
    add d0,a1
    move (a1)+,d0
    add go_x(a0),d0
    move (a1)+,d1
    add go_y(a0),d1

    bsr .testForSolid
    
    tst d0
    beq .canmove

    dbra d6,.lp
    move #-1,d0
.canmove:
    rts

.testForSolid:
    bsr CD_GetIsSolid
    rts  

.offsets:
    dc.w 0,-16,  16,0, 0,16, -16,0

CD_InitGuardian:
    SETSPR SPRITE_CUBEDROID_GUARDIAN
    move #0,go_frame(a0)
    move.l #.state_waiting,go_onUpdate(a0)
    move #0,go_rot(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts
.state_waiting:
    tst sysg_cd+cd_allBatteriesCollected
    beq .nomove
    
    bsr CD_GuardianGetDirection
    bmi .r
    ; go_rot is set up here
    bra .canmove
.r: rts  

.canmove:
    move go_x(a0),go_oldx(a0)
    move go_y(a0),go_oldy(a0)
    
    bsr CD_WriteGOSolid
    
    move go_rot(a0),d0
    lea .ds,a1
    lsl #3,d0
    add d0,a1
    move.l (a1)+,go_dx(a0)
    move.l (a1)+,go_dy(a0)
    
    lea .offsets,a1
    move go_rot(a0),d0
    lsl #2,d0
    add d0,a1
    move go_x(a0),d0
    add.w (a1)+,d0
    move.w d0,go_tox(a0)
    move go_y(a0),d0
    add.w (a1)+,d0
    move.w d0,go_toy(a0)
    
    bsr CD_WriteToGOSolid
    
    
    move #32,go_timer(a0)
    move.l #.state_moving,go_onUpdate(a0)
    bsr CD_ClearGOToGrid
    rts

.state_moving:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    sub #1,go_timer(a0)
    bgt .nomove
    move.l #.state_waiting,go_onUpdate(a0)
    bsr CD_ClearOldGOSolid
    bsr CD_WriteGOToGrid
    bsr CD_ClearGOOldPosSolid
.nomove:
    rts        
    
.testForSolid:
    bsr CD_GetIsSolid
    rts  

.ds:
    dc.l 0,-$8000,  $8000,0, 0,$8000, -$8000,0

.offsets:
    dc.w 0,-16,  16,0, 0,16, -16,0

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitLaserTower:
    SETSPR SPRITE_CUBEDROID_LASERTOWER
    move #0,go_frame(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts
.state_firstTime:
    bsr CD_WriteGOSolid
    move.l #.state_waiting,go_onUpdate(a0)
.state_waiting:
    move.l g_player,a1

    bsr CD_IsPlayerSameY
    beq .not_same_y
.same_y:
    bsr CD_GetPlayerSideOfObjX
    blt .test_left
    bgt .test_right
    
.not_same_y:
    bsr CD_IsPlayerSameX
    beq .not_same_x
.same_x:
    bsr CD_GetPlayerSideOfObjY
    blt .test_up
    bgt .test_down
.not_same_x:

    rts    
.test_right:
    lea CD_InitLaserBullet_R,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts
.test_left:
    lea CD_InitLaserBullet_L,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts
.test_down:
    lea CD_InitLaserBullet_D,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts
.test_up:
    lea CD_InitLaserBullet_U,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    rts
    
CD_InitCannonBullet_U:
    move #0,d0
    move #-8,d1
    move #0,go_dx(a0)
    move #-8,go_dy(a0)
    bra CD_InitCannonBullet_All
CD_InitCannonBullet_D:
    move #0,d0
    move #8,d1
    move #0,go_dx(a0)
    move #8,go_dy(a0)
    bra CD_InitCannonBullet_All
CD_InitCannonBullet_L:
    move #-8,d0
    move #0,d1
    move #-8,go_dx(a0)
    move #0,go_dy(a0)
    bra CD_InitCannonBullet_All
CD_InitCannonBullet_R:
    move #8,d0
    move #0,d1
    move #8,go_dx(a0)
    move #0,go_dy(a0)
    bra CD_InitCannonBullet_All
    
CD_InitCannonBullet_All:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    add d0,go_x(a0)
    add d1,go_y(a0)
    SETSPR SPRITE_CUBEDROID_BULLETS
    move #0,go_frame(a0)
    move #10,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move go_dx(a0),d0
    add d0,go_x(a0)
    move go_dy(a0),d0
    add d0,go_y(a0)
    
    bsr .testForSolid
    bne .die
    
    sub #1,go_timer(a0)
    beq .die
    rts
.die:
    jmp GOManager_DeleteObject
.testForSolid:
    bsr CD_GetGoPosIsSolid
    rts  
    



;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitLaserBullet_U:
    move #3,d0
    move #0,d1
    move #0,go_dx(a0)
    move #-16,go_dy(a0)
     move #2,go_frame(a0)
    bra CD_InitLaserBullet_All
CD_InitLaserBullet_D:
    move #3,d0
    move #0,d1
    move #0,go_dx(a0)
    move #16,go_dy(a0)
    move #2,go_frame(a0)
    bra CD_InitLaserBullet_All
CD_InitLaserBullet_L:
    move #0,d0
    move #0,d1
    move #-16,go_dx(a0)
    move #0,go_dy(a0)
    move #1,go_frame(a0)
    bra CD_InitLaserBullet_All
CD_InitLaserBullet_R:
    move #0,d0
    move #0,d1
    move #16,go_dx(a0)
    move #0,go_dy(a0)
    move #1,go_frame(a0)
    bra CD_InitLaserBullet_All
    
CD_InitLaserBullet_All:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    add d0,go_x(a0)
    add d1,go_y(a0)
    SETSPR SPRITE_CUBEDROID_BULLETS
    move #10,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move go_dx(a0),d0
    add d0,go_x(a0)
    move go_dy(a0),d0
    add d0,go_y(a0)
    
    bsr .testForSolid
    bne .die
    
    sub #1,go_timer(a0)
    beq .die
    rts
.die:
    jmp GOManager_DeleteObject
.testForSolid:
    bsr CD_GetGoPosIsSolid
    rts  
    



;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

;a0
CD_InitTeleportCrateDissolve:
    SETSPR SPRITE_CUBEDROID_TELEPORTCRATE_DISSOLVE
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    GO_SET_VISIBLE
.update:
    add.l #$4000,go_frame(a0)
    cmp #15,go_frame(a0)
    beq .die
    rts
.die:
    cmp #15-1,go_frame(a0)
    jmp GOManager_DeleteObject

CD_InitTeleportCrate:
    SETSPR SPRITE_CUBEDROID_TELEPORTCRATE
    move #1,go_frame(a0)
    move.l #.test_teleports,go_cd_onMoveFinished(a0)
    move #TELEPORTCRATESPR_VDP_INDEX,go_word0(a0)
    move #PAL_1,go_word1(a0)
    move #PRIORITY,go_sprAttributes(a0)

    bra DC_InitCrate_All
.test_teleports:
    move #4-1,d6
    lea .offsets,a5
    move #0,d5              ; has found a match
.lp:
    move go_x(a0),d0
    add (a5)+,d0
    move go_y(a0),d1
    add (a5)+,d1
    bsr CD_GetObjAt
    cmp.l #0,a1
    beq .no
    
    cmp #CDObj_TELEPORTCRATE,go_type(a1)
    bne .no
    
    exg.l a0,a1
    jsr CD_ClearGOToGrid
    jsr CD_ClearGOSolid
    bsr CD_Crate_Write_Defer_UnderTileToBackground
    bsr CD_InitTeleportCrateDissolve

    exg.l a0,a1
    move #1,d5
    
.no:
    dbra d6,.lp
    
    tst d5
    beq .notfound

    jsr CD_ClearGOToGrid
    jsr CD_ClearGOSolid
    bsr CD_Crate_Write_Defer_UnderTileToBackground
    bsr CD_InitTeleportCrateDissolve
    
.notfound

    rts    
.offsets:
    dc.w 16,0, 0,16, -16,0, 0,-16

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitRandomBlockTable:
    move.l m_cubedroid_randomTileTable,a1
    move #0,d0
.initlp:
    move.b d0,(a1)+
    addq #1,d0
    cmp #CUBEDROID_MAP_SIZE,d0
    blt .initlp
    
    bsr CD_ShuffleByteList
    
    rts
    
    

    

CD_InitMapStarterController:
    GO_SET_INVISIBLE
    bsr CD_InitRandomBlockTable
    move.l #.update,go_onUpdate(a0)
    move #0,go_word0(a0)
    move #1,go_timer(a0)
    rts
.update:
    sub #1,go_timer(a0)
    bge .r
    lea CD_InitStartSequenceTileSprite,a1
    bsr CDGenType_Normal
    
    moveq #0,d0
    move go_word0(a0),d0
    
    move.l m_cubedroid_randomTileTable,a2
    move.b (a2,d0),d0
    and #$ff,d0
    move d0,d6
    
    divu #12,d0
    move d0,go_word2(a1)
    move d0,d1
    lsl #4,d1
    add #8,d1
    move d1,go_y3(a1)
    swap d0
    move d0,go_word1(a1)
    lsl #4,d0
    add #8,d0
    move d0,go_x3(a1)
    
    
    sub #16*6,go_x3(a1)
    sub #16*6,go_y3(a1)
    
    move.l sysg_cd+cd_breakuptable_addr,a2
    moveq #0,d0
    move.b (a2,d6),d0
    lsl #3,d0
    move d0,go_word0(a1)
    
    
    
    move #0,go_timer(a0)
    add #1,go_word0(a0)
    cmp #144,go_word0(a0)
    bge .doneall
    
.r: rts

.doneall:
    move.l #.update_doneall,go_onUpdate(a0)
    move #50,go_timer(a0)
.update_doneall:
    sub #1,go_timer(a0)
    bgt .r
    jsr CD_InitSpawners

    jmp GOManager_DeleteObject


CD_InitStartSequenceTileSprite:
    SETSPR SPRITE_CUBEDROID_TILESHRINK
    move #0,go_frame(a0)
    move.l #.firstTime,go_onUpdate(a0)
    move #0,go_timer(a0)
    GO_SET_INVISIBLE
    move #255,go_z3(a0)

    move #0,go_rot(a0)

    rts

.firstTime:
    move go_x3(a0),go_x3a(a0)
    move go_y3(a0),go_y3a(a0)
    move.l #.update,go_onUpdate(a0)
    GO_SET_VISIBLE
    

.update:
    ;add #16,go_rot(a0)
    ;move go_rot(a0),d0
    ;jsr UTILS_GetSinCosLong
    ;muls go_x3a(a0),d0
    ;muls go_y3a(a0),d1
    ;asr.l #8,d0
    ;asr.l #8,d1
    ;asr.l #8,d0
    ;asr.l #8,d1
    ;move.l d0,go_x3(a0)
    ;move.l d1,go_y3(a0)


    bsr CD_PerspectiveTransform

    move go_z3(a0),d0
    sub #64,d0
    lsr #5,d0
    cmp #7,d0
    blt .ok
    move #7,d0
.ok:
    add go_word0(a0),d0
    move d0,go_frame(a0)

    sub #6,go_z3(a0)
    cmp #64,go_z3(a0)
    ble .die
    rts
.die:
    PUSHALL
    move go_word1(a0),d6
    move go_word2(a0),d7
    bsr CD_Write_Defer_TileToBackground_PRIORITY
    POPALL


    jmp GOManager_DeleteObject



;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
CD_InitMapBreakerController:
    GO_SET_INVISIBLE
    bsr CD_InitRandomBlockTable
    move.l #.update,go_onUpdate(a0)
    move #0,go_word0(a0)
    move #1,go_timer(a0)
    rts
.update:
    sub #1,go_timer(a0)
    bge .r
    lea CD_InitTileExploder,a1
    bsr CDGenType_Normal
    
    moveq #0,d0
    move go_word0(a0),d0
    
    move.l m_cubedroid_randomTileTable,a2
    move.b (a2,d0),d0
    and #$ff,d0
    move d0,d6
    
    divu #12,d0
    move d0,d1
    lsl #4,d1
    add #8,d1
    move d1,go_y3(a1)
    swap d0
    lsl #4,d0
    add #8,d0
    move d0,go_x3(a1)
    
    move go_x3(a1),d0
    lsr #4,d0
    move go_y3(a1),d1
    lsr #4,d1
    move d0,go_word2(a1)
    move d1,go_word3(a1)
    ;bsr CD_ClearSingleTile
    
    
    sub #16*6,go_x3(a1)
    sub #16*6,go_y3(a1)
    
    move.l sysg_cd+cd_breakuptable_addr,a2
    moveq #0,d0
    move.b (a2,d6),d0
    lsl #3,d0
    move d0,go_word0(a1)
    
    move #0,go_timer(a0)
    add #1,go_word0(a0)
    cmp #144,go_word0(a0)
    bge .doneall
    
.r: rts

.doneall:
    move.l #.update_doneall,go_onUpdate(a0)
    move #50,go_timer(a0)
.update_doneall:
    sub #1,go_timer(a0)
    bgt .r
.nextlevel:
    move #1,sysg_cd+cd_incrementLevel
    jmp GOManager_DeleteObject


CD_InitTileExploder:
    SETSPR SPRITE_CUBEDROID_TILESHRINK
    move #0,go_frame(a0)
    move.l #.firstTime,go_onUpdate(a0)
    move #0,go_timer(a0)
    GO_SET_INVISIBLE
    move #63,go_z3(a0)

    rts

.firstTime:
    bsr CD_PerspectiveTransform
    move go_word0(a0),go_frame(a0)

    move.l #.secondTime,go_onUpdate(a0)
    GO_SET_VISIBLE
    rts    
.secondTime:
    move go_word2(a0),d0
    move go_word3(a0),d1
    bsr CD_ClearSingleTile
    move.l #.update,go_onUpdate(a0)

.update:
    bsr CD_PerspectiveTransform
    move go_word0(a0),go_frame(a0)

    sub #1,go_z3(a0)
    cmp #0,go_z3(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject



;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------


CD_InitDeferredWriteTableForFrame:
    move #0,sysg_cd+cd_deferredWriteNum
    rts

CD_UpdateDeferredWriteTable:
    move sysg_cd+cd_deferredWriteNum,d7
    beq .r
    sub #1,d7
    lea sysg_cd+cd_deferredWriteTable,a6
.lp:    
    move cdvram_x(a6),d0
    move cdvram_y(a6),d1
    move cdvram_index(a6),d2
    move cdvram_attr(a6),d3
    bsr CD_SetSingleTile
    lea cdvram_structsize(a6),a6
    dbra d7,.lp
    
.r: rts

; in a1
CD_GetDeferredWriteTablePos:
    move.l d0,-(sp)
    move sysg_cd+cd_deferredWriteNum,d0
    lea sysg_cd+cd_deferredWriteTable,a1
    mulu #cdvram_structsize,d0
    add d0,a1
    move.l (sp)+,d0
    rts


CRATESPR_VDP_INDEX equ $172
TELEPORTCRATESPR_VDP_INDEX equ $17a
CD_Crate_Defer_WriteToBackground:
    PUSHALL
    move go_x(a0),d0
    lsr #4,d0
    move go_y(a0),d1
    lsr #4,d1
    move go_word0(a0),d2
    move go_word1(a0),d3
    
    bsr CD_GetDeferredWriteTablePos
    move d0,cdvram_x(a1)
    move d1,cdvram_y(a1)
    move d2,cdvram_index(a1)
    move d3,cdvram_attr(a1)
    add #1,sysg_cd+cd_deferredWriteNum
    
    ;bsr CD_SetSingleTile
    POPALL
    rts

CD_Crate_Write_Defer_UnderTileToBackground:
    PUSHALL    
    
    move go_x(a0),d6
    lsr #4,d6
    move go_y(a0),d7
    lsr #4,d7
    
    move.l sysg_cd+cd_map_addr,a3
    
    move d6,d0
    lsl #1,d0
    add d0,a3
    move d7,d0
    mulu #12*2,d0
    add d0,a3               ; a3 source map pos
    move (a3),d2        ; sprite index
    lsl #2,d2           ; *4 for 4 chars per sprite
    add #1,d2       ; blank offset
    
    move go_x(a0),d0
    lsr #4,d0
    move go_y(a0),d1
    lsr #4,d1
    move #0,d3


    bsr CD_GetDeferredWriteTablePos
    move d0,cdvram_x(a1)
    move d1,cdvram_y(a1)
    move d2,cdvram_index(a1)
    move d3,cdvram_attr(a1)
    add #1,sysg_cd+cd_deferredWriteNum

    ;bsr CD_SetSingleTile
    POPALL
    rts


; d6/d7
CD_Write_Defer_TileToBackground:
    PUSHALL    
    move.l sysg_cd+cd_map_addr,a3
    
    move d6,d0
    lsl #1,d0
    add d0,a3
    move d7,d0
    mulu #12*2,d0
    add d0,a3               ; a3 source map pos
    move (a3),d2        ; sprite index
    lsl #2,d2           ; *4 for 4 chars per sprite
    add #1,d2       ; blank offset
    
    move go_x(a0),d0
    lsr #4,d0
    move go_y(a0),d1
    lsr #4,d1
    move #0,d3


    bsr CD_GetDeferredWriteTablePos
    move d0,cdvram_x(a1)
    move d1,cdvram_y(a1)
    move d2,cdvram_index(a1)
    move d3,cdvram_attr(a1)
    add #1,sysg_cd+cd_deferredWriteNum

    ;bsr CD_SetSingleTile
    POPALL
    rts

CD_Write_Defer_TileToBackground_PRIORITY:
    PUSHALL    
    move.l sysg_cd+cd_map_addr,a3
    
    move d6,d0
    lsl #1,d0
    add d0,a3
    move d7,d0
    mulu #12*2,d0
    add d0,a3               ; a3 source map pos
    move (a3),d2        ; sprite index
    lsl #2,d2           ; *4 for 4 chars per sprite
    add #1,d2       ; blank offset
    
    move go_x(a0),d0
    lsr #4,d0
    move go_y(a0),d1
    lsr #4,d1
    move #$8000,d3

    bsr CD_GetDeferredWriteTablePos
    move d0,cdvram_x(a1)
    move d1,cdvram_y(a1)
    move d2,cdvram_index(a1)
    move d3,cdvram_attr(a1)
    add #1,sysg_cd+cd_deferredWriteNum
    POPALL
    rts


CD_InitCrate:
    SETSPR SPRITE_CUBEDROID_CRATE
    move #0,go_frame(a0)
    move.l #0,go_cd_onMoveFinished(a0)
    move #CRATESPR_VDP_INDEX,go_word0(a0)
    move #PAL_0,go_word1(a0)
    move #PRIORITY,go_sprAttributes(a0)

    bra DC_InitCrate_All
        
DC_InitCrate_All:
    move #1,go_cd_isPushable(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move.l #.onPushed,go_cd_onPushed(a0)
    rts
    
.state_firstTime:
    jsr CD_WriteGOSolid
    bsr CD_Crate_Defer_WriteToBackground
    GO_SET_INVISIBLE

    move.l #.state_waiting,go_onUpdate(a0)
    
.state_waiting:
    rts    
    
.state_moving:
    GO_SET_VISIBLE
;    cmp #1,go_timerl(a0)
;    bne .nowrite
;    GO_SET_VISIBLE
;.nowrite:
;    add #1,go_timerl(a0)


    move go_dx(a0),d0
    add d0,go_x(a0)
    move go_dy(a0),d0
    add d0,go_y(a0)
    sub #1,go_timer(a0)
    bgt .nomove
    move.l #.state_waiting,go_onUpdate(a0)
    bsr CD_ClearOldGOSolid
    bsr CD_WriteGOToGrid
    bsr CD_ClearGOOldPosSolid
    
    bsr CD_Crate_Defer_WriteToBackground
    GO_SET_INVISIBLE

    
    move.l go_cd_onMoveFinished(a0),d0
    beq .nomove
    move.l d0,a2
    jsr (a2)
.nomove:
    rts
        
.onPushed:
 
    moveq #SAMPLE_DRUMKIT1_KICK,d0
    jsr Samples_PlayDrumKitSample

        
    move go_x(a1),go_oldx(a1)
    move go_y(a1),go_oldy(a1)
    
    
    move go_rot(a0),go_rot(a1)
    move go_dx(a0),go_dx(a1)
    move go_dy(a0),go_dy(a1)
    move #CD_PLAYER_SPEEDAMT,go_timer(a1)    
    move.l #.state_moving,go_onUpdate(a1)
    move.l a0,-(sp)
    move.l a1,a0

    bsr CD_WriteGOSolid

    lea .offsets,a2
    move go_rot(a0),d0
    lsl #2,d0
    add d0,a2
    move go_x(a0),d0
    add.w (a2)+,d0
    move.w d0,go_tox(a0)
    move go_y(a0),d0
    add.w (a2)+,d0
    move.w d0,go_toy(a0)

    bsr CD_WriteToGOSolid
    bsr CD_ClearGOToGrid
    
    bsr CD_Crate_Write_Defer_UnderTileToBackground
    GO_SET_VISIBLE
       
    move #0,go_timerl(a0)

    move.l (sp)+,a0

    rts
.offsets:
    dc.w 0,-16,  16,0, 0,16, -16,0



;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------


CD_InitBoss:
    SETSPR SPRITE_CUBEDROID_BOSS
    move #0,go_frame(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts
.state_firstTime:
    move.l #.state_waiting,go_onUpdate(a0)
.state_waiting:
    rts    

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------


CD_InitRotatingLight:
    SETSPR SPRITE_CUBEDROID_ROTATINGLIGHT
    move #0,go_frame(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts
.state_firstTime:
    add #8,go_x(a0)
    add #8,go_y(a0)
    move.l #.state_waiting,go_onUpdate(a0)
    GO_SET_INVISIBLE
.state_waiting:
    ;tst sysg_cd+cd_allBatteriesCollected
    ;beq .ok
    GO_SET_VISIBLE
    move.l #.state_active,go_onUpdate(a0)
.state_active:
    rts
    
.ok:
    rts    

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitBattery:
    SETSPR SPRITE_CUBEDROID_BATTERY
    move #SPRFRAME_CUBEDROID_BATTERY_0,go_frame(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move.l #.onPlayerEntered,go_cd_onEntered(a0)
    move #1,go_cd_canMoveOnTo(a0)
    add #1,sysg_cd+cd_totalBatteries
    move #PRIORITY,go_sprAttributes(a0)
    rts

.state_firstTime:
    jsr CD_WriteGOSolid
    move.l #.state_waiting,go_onUpdate(a0)
    
.state_waiting:
    rts    
    
.onPlayerEntered:
    add #1,go_frame(a0)
    jsr CD_ClearGOSolid
    move.l #0,go_cd_onEntered(a0)

    move.l #CD_SCREENSHAKE_MAX,g_screenshake_timer

    add #1,sysg_cd+cd_numBatteriesCollected
    move sysg_cd+cd_numBatteriesCollected,d0
    cmp sysg_cd+cd_totalBatteries,d0
    blt .notall
    move #1,sysg_cd+cd_allBatteriesCollected
    bsr CD_PlayFinishedMusic

    

.notall:
    rts

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

CD_InitExit:
    SETSPR SPRITE_CUBEDROID_EXIT
    move #0,sysg_cd+cd_exitFrame
    move #0,go_frame(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move.l #.onPlayerEntered,go_cd_onEntered(a0)
    move #0,go_cd_canMoveOnTo(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts
.state_firstTime:
    bsr CD_WriteGOToGrid
    ifd CUBEDROID_SKIP_LANDING_SEQUENCE
    move.l #.state_waiting,go_onUpdate(a0)
    bra .state_waiting
    endif
    move.l #.state_landing,go_onUpdate(a0)
    move.l go_x(a0),go_tox(a0)
    move.l go_y(a0),go_toy(a0)
    sub.w #12*16,go_y(a0)
    add.w #3*16,go_x(a0)
    move #120,go_timer(a0)
    
.state_landing:
    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #4,d0
    add.l d0,go_x(a0)
    
    move.l go_toy(a0),d0
    sub.l go_y(a0),d0
    asr.l #4,d0
    add.l d0,go_y(a0)
    
    sub #1,go_timer(a0)
    bgt .r
    move.l go_tox(a0),go_x(a0)
    move.l go_toy(a0),go_y(a0)
    move.l #.state_waiting,go_onUpdate(a0)
.r: rts


    
.state_waiting:
    tst sysg_cd+cd_allBatteriesCollected
    beq .r
    move #1,go_cd_canMoveOnTo(a0)
    move.l #.state_opening,go_onUpdate(a0)
    move #0,go_timer(a0)
    rts

.state_opening:
    sub #1,go_timer(a0)
    bgt .r
    move #10,go_timer(a0)
    add #1,sysg_cd+cd_exitFrame
    cmp #10,sysg_cd+cd_exitFrame
    blt .r
    move #10,sysg_cd+cd_exitFrame
    rts

.state_closing:
    sub #1,go_timer(a0)
    bgt .r
    move #10,go_timer(a0)
    add #1,sysg_cd+cd_exitFrame
    cmp #20,sysg_cd+cd_exitFrame
    blt .r
    move #20,sysg_cd+cd_exitFrame
    move #1,sysg_cd+cd_startLevelEndSequence
    move.l #.state_takingOff,go_onUpdate(a0)
    move.l #0,go_dx(a0)
    move.l #0,go_dy(a0)
    rts
    
.state_takingOff:
    add.l #$40,go_dx(a0)
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    sub.l #$400,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    rts    
    
.onPlayerEntered:   ; a1 is player
    ;move #1,g_cd+cd_incrementLevel
    
    move.l #CD_UpdatePlayerExited,go_onUpdate(a1)
    
    move sysg_cd+cd_levelIndex,d0
    add d0,d0
    lea sysg_cd+cd_bestStepsTable,a2
    move (a2,d0),d1
    beq .setit
    cmp sysg_cd+cd_numStepsTaken,d1
    bge .nosetit
.setit:
    move sysg_cd+cd_numStepsTaken,(a2,d0)
.nosetit:
    
    move.l #.state_closing,go_onUpdate(a0)
    move #0,go_timer(a0)
    
    bsr CD_PlayLevelCompleteMusic
    rts
    
    
CD_GetBestSteps:
    move sysg_cd+cd_levelIndex,d0
    add d0,d0
    lea sysg_cd+cd_bestStepsTable,a1
    move (a1,d0),d0
    rts
        
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
    

    
CD_UpdatePlayerExited:
    GO_SET_INVISIBLE
    rts
CD_InitPlayer:
    SETSPR SPRITE_CUBEDROID_PLAYER
    move #SPRFRAME_CUBEDROID_PLAYER_D0,go_frame(a0)
    move.l #.state_firstTime,go_onUpdate(a0)
    move.l a0,g_player
    move #0,go_rot(a0)
    move #PRIORITY,go_sprAttributes(a0)
    rts    
.state_firstTime:
    bsr CD_WriteGOToGrid
    ifd CUBEDROID_SKIP_LANDING_SEQUENCE
    move.l #.state_waiting,go_onUpdate(a0)
    bra .state_waiting
    endif
    move.l #.state_landing,go_onUpdate(a0)
    move.l go_x(a0),go_tox(a0)
    move.l go_y(a0),go_toy(a0)
    sub.w #16*16,go_y(a0)
    sub.w #4*16,go_x(a0)
    move #120,go_timer(a0)
    
.state_landing:
    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #4,d0
    add.l d0,go_x(a0)
    
    move.l go_toy(a0),d0
    sub.l go_y(a0),d0
    asr.l #4,d0
    add.l d0,go_y(a0)
    
    sub #1,go_timer(a0)
    bgt .r
    move.l go_tox(a0),go_x(a0)
    move.l go_toy(a0),go_y(a0)
    move.l #.state_waiting,go_onUpdate(a0)
.r: rts
    
    
.state_waiting:
    
    move g_pad0,d0

    btst #pad_button_left,d0
    beq .noL
    bsr CD_CanPlayerMove_Left
    beq .noL
    bsr .initstate_moving
    move #3,go_rot(a0)
    move #-CD_PLAYER_SPEED,go_dx(a0)
    bsr CD_OnPlayerMove_Left
    bra .movebutton_done
.noL:
    btst #pad_button_right,d0
    beq .noR
    bsr CD_CanPlayerMove_Right
    beq .noR
    bsr .initstate_moving
    move #1,go_rot(a0)
    move #CD_PLAYER_SPEED,go_dx(a0)
    bsr CD_OnPlayerMove_Right
    bra .movebutton_done
.noR:

    btst #pad_button_up,d0
    beq .noU
    bsr CD_CanPlayerMove_Up
    beq .noU
    bsr .initstate_moving
    move #0,go_rot(a0)
    move #-CD_PLAYER_SPEED,go_dy(a0)
    bsr CD_OnPlayerMove_Up
    bra .movebutton_done
.noU:
    btst #pad_button_down,d0
    beq .noD
    bsr CD_CanPlayerMove_Down
    beq .noD
    bsr .initstate_moving
    move #2,go_rot(a0)
    move #CD_PLAYER_SPEED,go_dy(a0)
    bsr CD_OnPlayerMove_Down
    bra .movebutton_done
.noD:

.movebutton_done:

    move g_pad0_pressed,d0
    btst #pad_button_a,d0
    beq .noA
    move #1,sysg_cd+cd_restartLevel
.noA:

    move g_pad0_pressed,d0
    btst #pad_button_c,d0
    beq .noC
    
    ifd CUBEDROID_SKIP_END_SEQUENCE
    move #1,sysg_cd+cd_incrementLevel
    else
    move #1,sysg_cd+cd_startLevelEndSequence
    endif
    
.noC:
    move g_pad0_pressed,d0
    btst #pad_button_b,d0
    beq .noB
    move.l #InitState_CDLS,sysg_next_screen_addr
    ;not sysg_cd+cd_showDebug
.noB:




    rts

.state_moving:
    bsr .animate
    move go_dx(a0),d0
    add d0,go_x(a0)
    move go_dy(a0),d0
    add d0,go_y(a0)
    sub #1,go_timer(a0)
    bgt .nomove
    move.l #.state_waiting,go_onUpdate(a0)
    bsr CD_OnPlayerFinishedMoving
    bsr CD_WriteGOToGrid
.nomove:
    rts
        
.animate:
    move go_rot(a0),d0
    add d0,d0
    move g_timer1_shr4,d1
    and #1,d1
    add d1,d0
    move d0,go_frame(a0)
    rts
        
        
.initstate_moving:
    add #1,sysg_cd+cd_numStepsTaken
    move #0,go_dx(a0)
    move #0,go_dy(a0)
    move #CD_PLAYER_SPEEDAMT,go_timer(a0)    
    move.l #.state_moving,go_onUpdate(a0)
    bsr CD_ClearGOToGrid
    rts


CD_OnPlayerFinishedMoving:
    move go_x(a0),d0
    move go_y(a0),d1
    bsr CD_GetObjAt
    cmp.l #0,a1
    beq .noobj
    
    move.l go_cd_onEntered(a1),a2
    cmp.l #0,a2
    beq .noobj
    exg.l a0,a1
    jsr (a2)
    exg.l a0,a1

.noobj:
    rts


CD_CanPlayerMove_Right:
    move #16,d0
    move #0,d1
    bra CD_CanPlayerMove  
CD_CanPlayerMove_Up:
    move #0,d0
    move #-16,d1
    bra CD_CanPlayerMove  
CD_CanPlayerMove_Down:
    move #0,d0
    move #16,d1
    bra CD_CanPlayerMove  
CD_CanPlayerMove_Left:
    move #-16,d0
    move #0,d1
    bra CD_CanPlayerMove  

CD_CanPlayerMove:
    move d0,d4
    move d1,d5

    move d4,d0
    move d5,d1
    add go_x(a0),d0
    add go_y(a0),d1
    bsr CD_GetIsSolid_Original
    bne .cantmove

; is it empty of GO?    
    move d4,d0
    move d5,d1
    add go_x(a0),d0
    add go_y(a0),d1
    bsr CD_IsPosEmpty
    beq .canmove 

; there's a GO, is it pushable or movable onto
    move d4,d0
    move d5,d1
    add go_x(a0),d0
    add go_y(a0),d1
    bsr CD_GetObjAt
    cmp.l #0,a1
    beq .cantmove
    tst go_cd_isPushable(a1)
    bne .pushing
    
    tst go_cd_canMoveOnTo(a1)
    bne .canmove

.cantmove:
    moveq #0,d0
    rts
    
.pushing:
    move d4,d0
    move d5,d1
    add d0,d0
    add d1,d1
    add go_x(a0),d0
    add go_y(a0),d1

    bsr CD_GetIsSolid
    tst d0
    bne .cantmove
    

.canmove:
    moveq #1,d0
    rts
    


CD_OnPlayerMove_Right:
    move #16,d0
    move #0,d1
    bra CD_OnPlayerMove  
CD_OnPlayerMove_Up:
    move #0,d0
    move #-16,d1
    bra CD_OnPlayerMove  
CD_OnPlayerMove_Down:
    move #0,d0
    move #16,d1
    bra CD_OnPlayerMove  
CD_OnPlayerMove_Left:
    move #-16,d0
    move #0,d1
    bra CD_OnPlayerMove  
    
CD_OnPlayerMove:

    move d0,d4
    move d1,d5
    
    move d4,d0
    move d5,d1
    add go_x(a0),d0
    add go_y(a0),d1
    bsr CD_GetObjAt
    
    cmp.l #0,a1
    beq .noobj    

    move.l go_cd_onPushed(a1),d0
    beq .nopush
    move.l d0,a2
    jsr (a2)
.nopush:
    
.noobj:
    moveq #0,d0
    rts    


CD_InitWorldAndLevelStuff_GFX:
    jsr CD_InitVDPForLevel

    ;jsr SpriteCache_BuildFrames
    rts


    
CD_InitVDPForLevel:
    jsr ClearVRAM

    lea SPRPAL_CubeDroidBG,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource

    lea SPRPAL_CubeDroid_TeleportCrate,a0
    move #3,d0
    jsr FADE_CopySinglePaletteToSource

    jsr FADE_Update


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

    bsr CD_InitBackgroundTiles


    rts
    
.sprites:
    dc.w SPRITE_CUBEDROIDBG
    dc.w SPRITE_CUBEDROIDBG_EXTRA0
    dc.w SPRITE_CUBEDROIDBG_EXTRA1
    dc.w SPRITE_CUBEDROIDBG_EXTRA2
    dc.w SPRITE_CUBEDROIDBG_EXTRA3
    dc.w SPRITE_CUBEDROIDBG_EXTRA4
    dc.w SPRITE_CUBEDROID_BATTERY
    dc.w SPRITE_CUBEDROID_LASERTOWER
    dc.w SPRITE_CUBEDROID_GUARDIAN
    dc.w SPRITE_CUBEDROID_ROTATINGLIGHT
    dc.w SPRITE_CUBEDROID_EXIT
    dc.w SPRITE_CUBEDROID_CRATE
    dc.w SPRITE_CUBEDROID_TELEPORTCRATE
    dc.w SPRITE_CUBEDROID_TELEPORTCRATE_DISSOLVE
    dc.w SPRITE_CUBEDROID_PLAYER
    dc.w SPRITE_CUBEDROID_PLAYERDIE
    dc.w SPRITE_CUBEDROID_CANNON
    dc.w SPRITE_CUBEDROID_ROLLERSAW
    dc.w SPRITE_CUBEDROID_DIRECTIONALMOVER
    dc.w SPRITE_CUBEDROID_BULLETS
    dc.w SPRITE_CUBEDROID_BOSS
    dc.w SPRITE_CUBEDROID_TILESHRINK
    dc.w -1


CD_InitBackgroundTiles:

    move g_vram_currentpos,g_vram_bg


    moveq #0,d0
    move sysg_cd+cd_levelIndex,d0
    divu #6,d0
    move d0,sysg_cd+cd_backgroundIndex

    move sysg_cd+cd_backgroundIndex,d0
    add d0,d0
    move .bgs(pc,d0),g_image_index
    
    move.l #NEWIMAGEGROUP,g_image_groupbase
    jsr IMAGE_LoadCharsB
    jsr IMAGE_LoadMapB
    jsr IMAGE_LoadPalettes

    move.l #NEWIMAGEGROUP,g_image_groupbase
    move #IMAGEASSET_CUBEDROID_HUD,g_image_index
    jsr IMAGE_LoadChars
    jsr IMAGE_LoadMap
    jsr IMAGE_LoadPalettes

    rts
.bgs:
    dc.w IMAGEASSET_CUBEDROID_BG0,IMAGEASSET_CUBEDROID_BG1,IMAGEASSET_CUBEDROID_BG2,IMAGEASSET_CUBEDROID_BG3,IMAGEASSET_CUBEDROID_BG4,IMAGEASSET_CUBEDROID_BG5


CD_UpdateGame:
    bsr CD_InitDeferredWriteTableForFrame
    jsr UTILS_GetRandWord
    bsr CD_UpdateGame_UpdateGlobals

    jsr CD_InitHud
    
    BORDER 3
    bsr CD_UpdateGame_Normal
    BORDER 0       
    
    ;bsr WriteDebugColMap
    
    tst sysg_cd+cd_showDebug
    beq .nodebug
    bsr CD_DrawDebugLayer
.nodebug
    
    
    tst sysg_cd+cd_startLevelEndSequence
    beq .no_startLevelEndSequence
    move #0,sysg_cd+cd_startLevelEndSequence
    bsr CD_StartLevelEndSequence
.no_startLevelEndSequence:
    
    
    tst sysg_cd+cd_incrementLevel
    beq .nonext
    move #0,sysg_cd+cd_incrementLevel
    add #1,sysg_cd+cd_levelIndex
    bsr CD_RestartLevel
.nonext:

    tst sysg_cd+cd_restartLevel
    beq .norestart
    move #0,sysg_cd+cd_restartLevel
    bsr CD_RestartLevel
.norestart:
     
    rts
    
CD_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
CD_UpdateGame_UpdateGlobals:
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

    

CD_UpdateGame_Normal:
    bsr CD_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    jsr GOManager_Update
	jsr SPRITE_UpdateFromGOManager_Racing
    rts


CD_UpdateVBL:
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr CD_UpdateScrollRegisters

    bsr CD_UpdateDeferredWriteTable
    bsr CD_UpdateVDPAnim    
	rts

;-------------------------------------------------------------


CD_UpdateScrollRegisters:

	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_FULL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL
    
    AUTOINC 2
; hscroll
	
	move g_scroll_x,d0
	move #0,d0
	add g_screenshake_x,d0
	neg d0
	
	SCROLL_START_WRITE_XPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
    AUTOINC 2
    move g_scroll_y,d0
    add g_screenshake_y,d0
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
	rts

    
    
CD_InitHud:

    move sysg_cd+cd_numStepsTaken,d0
    FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (28),13

	lea .levelnames,a0
	move sysg_cd+cd_levelIndex,d0
	lsl #2,d0
	add d0,a0
	move.l #VDPADDR_SCROLL_A + (9*128) + (28*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText

    bsr CD_GetBestSteps
    FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (28),17


    lea .texts,a5
    move sysg_cd+cd_levelIndex,d0
    cmp #5,d0
    bgt .nohelp
    mulu #12,d0
    add d0,a5

	move.l (a5)+,a0
	move.l #VDPADDR_SCROLL_A + (24*128) + (28*0),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	move.l (a5)+,a0
	move.l #VDPADDR_SCROLL_A + (25*128) + (28*0),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	move.l (a5)+,a0
	move.l #VDPADDR_SCROLL_A + (26*128) + (28*0),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	
.nohelp:	
	rts

    ;move sysg_cd+cd_numBatteriesCollected,d0
    ;FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (28),5
    ;move sysg_cd+cd_totalBatteries,d0
    ;FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (32),5
    ;rts

.texts:
    dc.l .text0a,.text0b,.text0c
    dc.l .text1a,.text1b,.text1c
    dc.l .text2a,.text2b,.text2c
    dc.l .text3a,.text3b,.text3c
    dc.l .text4a,.text4b,.text4c
    dc.l .text5a,.text5b,.text5c

;             00000000001111111111222222222233 
;             01234567890123456789012345678901
.text0a: dc.b 'Use the DPAD to move around.',ETX 
.text0b: dc.b 'Pick up the batteries',ETX
.text0c: dc.b '.. and get out of there',ETX

.text1a: dc.b 'Laser Towers shoot you if',ETX 
.text1b: dc.b 'aligned horizontally or ',ETX
.text1c: dc.b 'vertically with you',ETX

.text2a: dc.b 'Cannons wake up when all',ETX 
.text2b: dc.b 'batteries are removed.',ETX
.text2c: dc.b '',ETX

.text3a: dc.b 'Guardians wake up when all',ETX 
.text3b: dc.b 'batteries are removed.',ETX
.text3c: dc.b 'They start looking for you.',ETX

.text4a: dc.b 'Roller Saws are always ',ETX 
.text4b: dc.b 'looking for trouble.',ETX
.text4c: dc.b 'Steer clear of them',ETX

.text5a: dc.b 'Blue crates are teleport',ETX 
.text5b: dc.b 'crates. They disappear when',ETX
.text5c: dc.b 'next to each other',ETX

    align 2


.levelnames:
    dc.b '1-1',ETX
    dc.b '1-2',ETX
    dc.b '1-3',ETX
    dc.b '1-4',ETX
    dc.b '1-5',ETX
    dc.b '1-6',ETX
    dc.b '2-1',ETX
    dc.b '2-2',ETX
    dc.b '2-3',ETX
    dc.b '2-4',ETX
    dc.b '2-5',ETX
    dc.b '2-6',ETX
    dc.b '3-1',ETX
    dc.b '3-2',ETX
    dc.b '3-3',ETX
    dc.b '3-4',ETX
    dc.b '3-5',ETX
    dc.b '3-6',ETX
    dc.b '4-1',ETX
    dc.b '4-2',ETX
    dc.b '4-3',ETX
    dc.b '4-4',ETX
    dc.b '4-5',ETX
    dc.b '4-6',ETX
    dc.b '5-1',ETX
    dc.b '5-2',ETX
    dc.b '5-3',ETX
    dc.b '5-4',ETX
    dc.b '5-5',ETX
    dc.b '5-6',ETX
    dc.b '6-1',ETX
    dc.b '6-2',ETX
    dc.b '6-3',ETX
    dc.b '6-4',ETX
    dc.b '6-5',ETX
    dc.b '6-6',ETX
    
CD_PlanetNames:
    dc.l .p0,.p1,.p2,.p3,.p4,.p5
.p0 dc.b 'Aruru',ETX
.p1 dc.b 'Ishtar',ETX
.p2 dc.b 'Nergal',ETX
.p3 dc.b 'Ninurta',ETX
.p4 dc.b 'Marouk',ETX
.p5 dc.b 'Shamash',ETX
    align 2

; d0 / d1 x,y, d2 = tile index, d3 = pal     
CD_SetSingleTile:
    PUSHALL
    move d0,d6
    move d1,d7
    move d2,d5
    move d3,d4
    
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
    add #2,d0
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
    add #1,d0
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
    add #3,d0
    or d4,d0
    move d0,VDP_DATA
    
    POPALL
    rts

; d0 / d1 x,y     
CD_ClearSingleTile:
    PUSHALL
    move d0,d6
    move d1,d7
    
; tile 0    
	move.l #VDPADDR_SCROLL_A,d1
    move d6,d0
	lsl #2,d0
	add d0,d1
	move d7,d0
	lsl #8,d0
	add d0,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    move #0,VDP_DATA

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
    move #0,VDP_DATA
    
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
    move #0,VDP_DATA

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
    move #0,VDP_DATA
    
    POPALL
    rts


; d0 value to OR in to tile data
CD_DrawTileMap:
    move d0,d4

    AUTOINC 2
    
    move #0,d7
.yloop:
    move #0,d6
.xloop:
    move.l sysg_cd+cd_map_addr,a0
    
    move d6,d0
    lsl #1,d0
    add d0,a0
    move d7,d0
    mulu #12*2,d0
    add d0,a0               ; a0 source map pos
    move (a0),d5        ; sprite index
    lsl #2,d5           ; *4 for 4 chars per sprite
    add #1,d5       ; blank offset

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
    add #2,d0
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
    add #1,d0
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
    add #3,d0
    or d4,d0
    move d0,VDP_DATA
    
    add #1,d6
    cmp #12,d6
    blt .xloop

    add #1,d7
    cmp #12,d7
    blt .yloop
    rts

CD_DrawDebugLayer:

    AUTOINC 2
    
    move #0,d7
.yloop:
    move #0,d6
.xloop:
    move.l m_cubedroid_solidMap,a0
    
    move d6,d0
    add d0,a0
    move d7,d0
    mulu #12,d0
    add d0,a0
                   
    moveq #0,d5
    move.b (a0),d5
    lsl #5,d5        
    or.w #$8000,d5

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
    move d0,VDP_DATA

    
    add #1,d6
    cmp #12,d6
    blt .xloop

    add #1,d7
    cmp #12,d7
    blt .yloop
    rts
    
    
;CDObj_CRATE equ 0
;CDObj_PLAYER equ 1
;CDObj_BATTERY equ 2
;CDObj_EXIT equ 3
;CDObj_DIRECTIONALMOVER_U equ 4
;CDObj_DIRECTIONALMOVER_R equ 5
;CDObj_DIRECTIONALMOVER_D equ 6
;CDObj_DIRECTIONALMOVER_L equ 7
;CDObj_TELEPORTCRATE equ 8
;CDObj_GUARDIAN equ 9
;CDObj_LASERTOWER equ 10
;CDObj_CANNON_U equ 11
;CDObj_CANNON_R equ 12
;CDObj_CANNON_D equ 13
;CDObj_CANNON_L equ 14
;CDObj_ROLLERSAW equ 15


CD_GetGOList_Normal:
    jmp GOManager_GetList_Treasure

CDGenType_Normal:
    jmp GOManager_SpawnGameObject_Treasure
CDGenType_Player:
    jmp GOManager_SpawnGameObject_FX


; x,y,type,0    
CD_InitSpawners:
    move.l sysg_cd+cd_objs_addr,a5
    
.lp:
    move (a5),d0
    cmp #-1,d0
    beq .exit
    
    move 4(a5),d0
    lea CD_SpawnTable,a4
    mulu #12,d0
    add d0,a4

    PUSHALL
    move.l 8(a4),a1         ; GO function
    move.l 4(a4),a2         ; spawn func
    jsr (a2)
    
    move (a5),d0
    lsl #4,d0
    move d0,go_x(a1)
    move 2(a5),d0
    lsl #4,d0
    move d0,go_y(a1)
    move 4(a5),go_type(a1)
    move.l a1,a0
    bsr  CD_WriteGOToGrid
    POPALL

    lea 8(a5),a5
    bra .lp
    
    
.exit:
    rts
    
CD_ClearGrid:
    move.l m_cubedroid_goMap,a0
    move #12*12*4,d0
    jsr UTILS_ClearRam
    rts
    
    
CD_WriteGOToGrid:
    PUSHALL
    move.l m_cubedroid_goMap,a2
    move go_x(a0),d0
    lsr #4,d0
    lsl #2,d0
    add d0,a2
    move go_y(a0),d0
    lsr #4,d0
    mulu #12*4,d0
    add d0,a2
    move.l a0,(a2)
    POPALL
    rts
    
; in world coords. d0,d1. Returns in a1
CD_GetObjAt:
    cmp #0,d0
    blt .off
    cmp #12*16,d0
    bge .off
    cmp #0,d1
    blt .off
    cmp #12*16,d1
    bge .off


    move.l m_cubedroid_goMap,a2
    lsr #4,d0
    lsl #2,d0
    add d0,a2
    lsr #4,d1
    mulu #12*4,d1
    add d1,a2
    move.l (a2),a1
    rts
.off:
    move.l #0,a1
    rts

; in world coords. d0,d1. 
; d0=0 = empty
CD_IsPosEmpty:
    cmp #0,d0
    blt .off
    cmp #12*16,d0
    bge .off
    cmp #0,d1
    blt .off
    cmp #12*16,d1
    bge .off
    
    move.l m_cubedroid_goMap,a2
    lsr #4,d0
    lsl #2,d0
    add d0,a2
    lsr #4,d1
    mulu #12*4,d1
    add d1,a2
    cmp.l #0,(a2)
    bne .off
    moveq #0,d0
    rts
.off:
    moveq #1,d0
    rts
        
; in world coords. d0,d1
CD_ClearGOToGrid:
    PUSHALL
    move.l m_cubedroid_goMap,a2
    move go_x(a0),d0
    lsr #4,d0
    lsl #2,d0
    add d0,a2
    move go_y(a0),d0
    lsr #4,d0
    mulu #12*4,d0
    add d0,a2
    move.l #0,(a2)
    POPALL
    rts
    
;d0,d1  worldpos / d0
CD_GetGoPosIsSolid:
    move go_x(a0),d0
    move go_y(a0),d1

; returns 1 if solid    
CD_GetIsSolid:
    cmp #0,d0
    blt .solid
    cmp #12*16,d0
    bge .solid
    cmp #0,d1
    blt .solid
    cmp #12*16,d1
    bge .solid

    move.l m_cubedroid_solidMap,a2
    lsr #4,d0
    add d0,a2
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    moveq #0,d0
    move.b (a2),d0
    rts
.solid:
    moveq #1,d0
    rts

CD_GetIsSolid_Original:
    cmp #0,d0
    blt .solid
    cmp #12*16,d0
    bge .solid
    cmp #0,d1
    blt .solid
    cmp #12*16,d1
    bge .solid

    move.l sysg_cd+cd_solids_addr,a2
    lsr #4,d0
    add d0,a2
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    moveq #0,d0
    move.b (a2),d0
    rts
.solid:
    moveq #1,d0
    rts


CD_WriteGOSolid:
    move.l m_cubedroid_solidMap,a2
    move go_x(a0),d0
    lsr #4,d0
    add d0,a2
    move go_y(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #1,(a2)
    rts

CD_WriteToGOSolid:
    move.l m_cubedroid_solidMap,a2
    move go_tox(a0),d0
    lsr #4,d0
    add d0,a2
    move go_toy(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #1,(a2)
    rts

CD_ClearToGOSolid:
    move.l m_cubedroid_solidMap,a2
    move go_tox(a0),d0
    lsr #4,d0
    add d0,a2
    move go_toy(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #0,(a2)
    rts

CD_WriteOldGOSolid:
    move.l m_cubedroid_solidMap,a2
    move go_oldx(a0),d0
    lsr #4,d0
    add d0,a2
    move go_oldy(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #1,(a2)
    rts

CD_ClearOldGOSolid:
    move.l m_cubedroid_solidMap,a2
    move go_oldx(a0),d0
    lsr #4,d0
    add d0,a2
    move go_oldy(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #0,(a2)
    rts

    
CD_ClearGOSolid:
    move.l m_cubedroid_solidMap,a2
    move go_x(a0),d0
    lsr #4,d0
    add d0,a2
    move go_y(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #0,(a2)
    rts

CD_ClearGOOldPosSolid:
    move.l m_cubedroid_solidMap,a2
    move go_oldx(a0),d0
    lsr #4,d0
    add d0,a2
    move go_oldy(a0),d1
    lsr #4,d1
    mulu #12,d1
    add d1,a2
    move.b #0,(a2)
    rts
    
    
WriteDebugColMap:
    lea DebugArea,a0
    move #16*12,d0
    jsr UTILS_ClearRam
    
    move.l m_cubedroid_solidMap,a0
    lea DebugArea,a1
    
    move #12-1,d7
.ylp
    move #12-1,d6
.xlp:
    move.b (a0)+,(a1)+
    dbra d6,.xlp
    lea 16-12(a1),a1
    dbra d7,.ylp
    rts
    
    
    

    clrso
cdvram_x so.w 1
cdvram_y so.w 1
cdvram_index so.w 1
cdvram_attr so.w 1
cdvram_structsize so.w 1

    clrso
cd_totalBatteries so.w 1
cd_numBatteriesCollected so.w 1
cd_allBatteriesCollected so.w 1
cd_levelIndex so.w 1
cd_numStepsTaken so.w 1
cd_backgroundIndex so.w 1
cd_showDebug so.w 1  
cd_incrementLevel so.w 1  
cd_startLevelEndSequence so.w 1
cd_restartLevel so.w 1  
cd_exitFrame so.w 1  
cd_currentLevelMusic so.w 1  
cd_map_addr so.l 1  
cd_objs_addr so.l 1
cd_solids_addr so.l 1
cd_breakuptable_addr so.l 1
cd_bestStepsTable so.w CUBEDROID_NUM_LEVELS

cd_deferredWriteNum so.w 1
cd_deferredWriteTable so.b (cdvram_structsize*128)

cd_structsize so.b 0  



CD_InitLevelPointers:
    move #0,sysg_cd+cd_totalBatteries
    move #0,sysg_cd+cd_numBatteriesCollected
    move #0,sysg_cd+cd_allBatteriesCollected
    move #0,sysg_cd+cd_startLevelEndSequence
    move #0,sysg_cd+cd_incrementLevel
    move #0,sysg_cd+cd_numStepsTaken
    move #0,sysg_cd+cd_deferredWriteNum

    move sysg_cd+cd_levelIndex,d0
    lea CubeDroid,a0
    mulu #16,d0
    add d0,a0
    move.l (a0)+,sysg_cd+cd_map_addr
    move.l (a0)+,sysg_cd+cd_breakuptable_addr
    move.l (a0)+,sysg_cd+cd_solids_addr
    move.l (a0)+,sysg_cd+cd_objs_addr
    rts
    
CD_InitSolid:
    move.l sysg_cd+cd_solids_addr,a0
    move.l m_cubedroid_solidMap,a1
    move #12*12,d0
    jsr UTILS_Copy
    rts 


; rots
; 0
; 11.25
; 22.5
; 33.75
; 45
; 56.25
; 67.5
; 78.75







CD_VDPANIM_BATTERY_ADDR equ ($13d*32)
CD_VDPANIM_BATTERYCOLLECTED_ADDR equ ($141*32)
CD_VDPANIM_LASERTOWER_ADDR equ ($145*32)
CD_VDPANIM_GUARDIAN_ADDR equ ($14d*32)
CD_VDPANIM_ROTATINGLIGHT_ADDR equ ($159*32)
CD_VDPANIM_EXIT_ADDR equ ($169*32)

CD_UpdateVDPAnim:

; rotating light
    move g_timer1,d0
    and #1,d0
    beq .do_exit

	move.l #SPRDEF_CubeDroid_RotatingLight_VDP+4,d0
	move g_timer1_shr2,d1
	and #7,d1
	lsl #5,d1
	lsl #4,d1
	add d1,d0
	move.l #CD_VDPANIM_ROTATINGLIGHT_ADDR,d1
	move.l #32*16,d2
	move #2,d3
	jsr VDP_SetDMA
	bra .skip_exit
	

.do_exit:
;exit

	move.l #SPRDEF_CubeDroid_Exit_VDP+4,d0
	move sysg_cd+cd_exitFrame,d1
	mulu #32*9,d1
	add d1,d0
	move.l #CD_VDPANIM_EXIT_ADDR,d1
	move.l #32*9,d2
	move #2,d3
	jsr VDP_SetDMA
.skip_exit:

	move.l #SPRDEF_CubeDroid_Battery_VDP+4,d0
	move g_timer1_shr3,d1
	and #15,d1
	lsl #5+2,d1
	add d1,d0
	move.l #CD_VDPANIM_BATTERY_ADDR,d1
	move.l #32*4,d2
	move #2,d3
	jsr VDP_SetDMA

	move.l #SPRDEF_CubeDroid_BatteryCollected_VDP+4,d0
	move g_timer1_shr2,d1
	and #15,d1
	lsl #5+2,d1
	add d1,d0
	move.l #CD_VDPANIM_BATTERYCOLLECTED_ADDR,d1
	move.l #32*4,d2
	move #2,d3
	jsr VDP_SetDMA
	
	
	move.l #SPRDEF_CubeDroid_LaserTower_VDP+4,d0
	move g_timer1_shr3,d1
	add #4,d1
	and #15,d1
	lsl #5+2,d1
	add d1,d0
	move.l #CD_VDPANIM_LASERTOWER_ADDR,d1
	move.l #32*4,d2
	move #2,d3
	jsr VDP_SetDMA

	move.l #SPRDEF_CubeDroid_LaserGuardian_VDP+4,d0
	moveq #0,d1
	move g_timer1,d1
	lsr #1,d1
	divu #10,d1
	swap d1
	lsl #5+2,d1
	add d1,d0
	move.l #CD_VDPANIM_GUARDIAN_ADDR,d1
	move.l #32*4,d2
	move #2,d3
	jsr VDP_SetDMA
	
	
	rts


CD_SCREENSHAKE_MAX equ $20000
CD_SCREENSHAKE_DECREASE_VEL equ $4000

CD_UpdateScreenShake:

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
    
    sub.l #CD_SCREENSHAKE_DECREASE_VEL,g_screenshake_timer
    bge .ok
    move.l #0,g_screenshake_timer
.ok:
    rts
.no:
    move #0,g_screenshake_x
    move #0,g_screenshake_y
    rts


CD_SpawnTable:
    dc.l CDObj_CRATE,CDGenType_Normal,CD_InitCrate
    dc.l CDObj_PLAYER,CDGenType_Player,CD_InitPlayer
    dc.l CDObj_BATTERY,CDGenType_Normal,CD_InitBattery
    dc.l CDObj_EXIT,CDGenType_Player,CD_InitExit
    dc.l CDObj_DIRECTIONALMOVER_U,CDGenType_Normal,CD_InitMoverU
    dc.l CDObj_DIRECTIONALMOVER_R,CDGenType_Normal,CD_InitMoverR
    dc.l CDObj_DIRECTIONALMOVER_D,CDGenType_Normal,CD_InitMoverD
    dc.l CDObj_DIRECTIONALMOVER_L,CDGenType_Normal,CD_InitMoverL
    dc.l CDObj_TELEPORTCRATE,CDGenType_Normal,CD_InitTeleportCrate
    dc.l CDObj_GUARDIAN,CDGenType_Normal,CD_InitGuardian
    dc.l CDObj_LASERTOWER,CDGenType_Normal,CD_InitLaserTower
    dc.l CDObj_CANNON_U,CDGenType_Normal,CD_InitCannonU
    dc.l CDObj_CANNON_R,CDGenType_Normal,CD_InitCannonR
    dc.l CDObj_CANNON_D,CDGenType_Normal,CD_InitCannonD
    dc.l CDObj_CANNON_L,CDGenType_Normal,CD_InitCannonL
    dc.l CDObj_ROLLERSAW,CDGenType_Normal,CD_InitRollerSaw
    dc.l CDObj_ROTATINGLIGHT,CDGenType_Normal,CD_InitRotatingLight
    dc.l CDObj_BOSS,CDGenType_Normal,CD_InitBoss

;CD_InitMapShrinkerController
        
CD_PerspectiveTransform:
	move go_z3(a0),d0
	lea CD_PerspectiveTable+2,a1
	lsl #2,d0
	move.l (a1,d0),d0

	move go_x3(a0),d1
	muls d0,d1
	asr.l #8,d1
	add #16*6,d1
	move.w d1,go_x(a0)

	move go_y3(a0),d1
	muls d0,d1
	asr.l #8,d1
	add #16*6,d1
	move.w d1,go_y(a0)


	rts


CD_PerspectiveTable:
	dc.w 255
	dc.l 16384,8192,5461,4096,3276,2730,2340,2048,1820,1638,1489,1365,1260,1170,1092,1024,963,910,862,819,780,744,712,682,655,630,606,585,564,546,528,512,496,481,468,455,442,431,420,409,399,390,381,372,364,356,348,341,334,327,321,315,309,303,297,292,287,282,277,273,268,264,260,256,252,248,244,240,237,234,230,227,224,221,218,215,212,210,207,204,202,199,197,195,192,190,188,186,184,182,180,178,176,174,172,170,168,167,165,163,162,160,159,157,156,154,153,151,150,148,147,146,144,143,142,141,140,138,137,136,135,134,133,132,131,130,129,128,127,126,125,124,123,122,121,120,119,118,117,117,116,115,114,113,112,112,111,110,109,109,108,107,107,106,105,105,104,103,103,102,101,101,100,99,99,98,98,97,96,96,95,95,94,94,93,93,92,92,91,91,90,90,89,89,88,88,87,87,86,86,85,85,84,84,84,83,83,82,82,81,81,81,80,80,79,79,79,78,78,78,77,77,76,76,76,75,75,75,74,74,74,73,73,73,72,72,72,71,71,71,70,70,70,70,69,69,69,68,68,68,67,67,67,67,66,66,66,66,65,65,65,65,64,64,64
        
CD_ShuffleByteList:
    PUSHALL

    move.l m_cubedroid_randomTileTable,a1
    
    move #144-1,d7
.lp:
    move d7,d0
    jsr UTILS_GetRandWordFastUpTo
    move d0,d6  ;k
    
    move.b (a1,d7),d0
    move.b (a1,d6),d1
    move.b d1,(a1,d7)
    move.b d0,(a1,d6)
    
    sub #1,d7
    bgt .lp
        
    POPALL
    rts
        
;	public static void Shuffle<T>(this List<T> list)
;	{
;		var r = new System.Random();
;//Step 1: For each unshuffled item in the collection
;		for (int n = list.Count - 1; n > 0; --n)
;		{
;			//Step 2: Randomly pick an item which has not been shuffled
;			int k = r.Next(n + 1);
;
;			//Step 3: Swap the selected item with the last "unstruck" letter in the collection
;			T temp = list[n];
;			list[n] = list[k];
;			list[k] = temp;
;		} 
;	}        