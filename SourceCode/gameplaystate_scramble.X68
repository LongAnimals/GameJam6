

Scramble_ExitState:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts

    clrso
scramble_scrollx so.w 1
scramble_enemyBulletTimer so.w 1
scramble_hscrolltabA so.w 28
scramble_hscrolltabB so.w 28

scramble_structsize so.b 0


Scramble_InitState:
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


    move #LEVEL_SCRAMBLE,d0
    jsr LEVEL_InitData

	jsr SOUND_Init
    move #0,sysg_current_music
    bsr Scramble_PlayMusic

	jsr SCROLL_SetNormalPlanes

    jsr Scramble_InitForGame
    jsr Scramble_InitForLevel

    bsr Scramble_InitWorldAndLevelStuff_GFX
    bsr Scramble_InitWorldAndLevelStuff_Mem
    
	FADE_SETVALUE 0
	FADE_START_IN 0

    bsr Scramble_InitHScroll
	move.l #Scramble_UpdateGame,g_game_loopaddr
	move.l #Scramble_UpdateVBL,g_game_vbladdr

    

    rts
    
Scramble_InitHScroll:
    lea g_scramble+scramble_hscrolltabA,a1
    move #28-1,d1
.lp:    move #0,(a1)+
    dbra d1,.lp
    rts 

Scramble_UpdateHScroll:
    lea g_scramble+scramble_hscrolltabA,a1
    lea .values,a0
    move #28-1,d1
.lp:
    move (a0)+,d0    
    add d0,(a1)+
    dbra d1,.lp
    rts 
.values: dc.w 1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8

Scramble_DMAHScroll:
    rts
    lea g_scramble+scramble_hscrolltabA,a1
	move.l #VDPSpriteList,d0
	move.l #VDPADDR_SPRITE_ATTR,d1
	move.l #MAX_SPRITES*8,d2
	move #2,d3
	jsr VDP_SetDMA
	rts
    
    
Scramble_ResetForRealtimeCommand:
    jsr Scramble_InitForGame
    jsr Scramble_InitForLevel
    
    bsr Scramble_InitWorldAndLevelStuff_GFX
    bsr Scramble_InitWorldAndLevelStuff_Mem
    rts
    
Scramble_InitForGame:
    rts
    

Scramble_InitForLevel:
    rts
    

Scramble_InitWorldAndLevelStuff_Mem:
    bsr Scramble_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    jsr Scramble_InitGOs
    rts
    
Scramble_InitGOs:
    lea Scramble_InitGenerator,a1
    jsr GOManager_SpawnGameObject_Car


    lea Scramble_InitPlayer,a1
    jsr GOManager_SpawnGameObject_Car
    
    rts


; extra = 0-7
Scramble_InitEnemy_Bouncer:        ; bouncer
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_ENEMY3,go_frame(a0)
    move.l #.update_normal,go_onUpdate(a0)
    move.l #Scramble_EnemyCollidedWithBullet,go_onCollided(a0)

    move #5,go_health(a0)
    
    move.l g_currentSpawnListAddr,a4
    move scramgen_x(a4),go_x(a0)
    
    moveq #0,d0
    move scramgen_extra0(a4),d0
    lsl.l #8,d0
    lsl.l #5,d0
    move.l d0,go_dx(a0)
    
    
    bsr Scramble_Enemy_PlaceOnScenery
    bsr .initstate_waiting
    rts
    
.initstate_waiting:
    move.l #0,go_dy(a0) 
    move #80,d0
    move d0,go_timer(a0)
    rts
.update_normal:
    sub #1,go_x(a0)
    sub #1,go_timer(a0)
    bgt .update_all
    move.l #-$40000,go_dy(a0)
    move.l #.update_jumping,go_onUpdate(a0)
    rts
    
.update_jumping    
    bsr Scramble_TestGenerateEnemyBullet
    move.l go_dx(a0),d0
    sub.l d0,go_x(a0)
    add.l #$1000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Scramble_GetSolidColGO
    beq .update_all
    
    bsr .initstate_waiting
    move.l #.update_normal,go_onUpdate(a0)
    
.update_all:
    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject



Scramble_Enemy_MoveUpwardsOutOfScenery:
    move go_x(a0),d3
    move go_y(a0),d4
.inityloop:
    move d3,d0
    move d4,d1    
    bsr Scramble_GetSolidCol
    beq .inityok
    sub #8,d4
    bra .inityloop
.inityok:
    add #8,d4
    move d4,go_y(a0)
    rts

Scramble_Enemy_PlaceOnScenery:
    move go_x(a0),d3
    move #224-8,d4
.inityloop:
    move d3,d0
    move d4,d1    
    bsr Scramble_GetSolidCol
    beq .inityok
    sub #8,d4
    bra .inityloop
.inityok:
    add #8,d4
    move d4,go_y(a0)
    rts
    
Scramble_InitEnemy_Rocket:        ; rocket
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_ENEMY2,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #Scramble_EnemyCollidedWithBullet,go_onCollided(a0)

    move #5,go_health(a0)
    
    move.l g_currentSpawnListAddr,a4
    move scramgen_x(a4),go_x(a0)

    jsr UTILS_GetRandWord
    and #127,d0
    add #100,d0
    move d0,go_timer(a0)
    move.l #0,go_dy(a0)
    
    bsr Scramble_Enemy_PlaceOnScenery

    rts
    
.update:
    sub #1,go_x(a0)
    sub #1,go_timer(a0)
    bgt .ok
    sub.l #$1000,go_dy(a0)
    
.ok:
    cmp #-50,go_y(a0)
    bgt .ok2
    move #-50,go_y(a0)
.ok2:

    move.l go_dy(a0),d0
    add.l d0,go_y(a0)


    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject

    
Scramble_EnemyCollidedWithBullet:
    sub #1,go_health(a0)
    ble .die
    rts
.die:
    jmp GOManager_DeleteObject




Scramble_TestGenerateEnemyBullet:
    cmp #60,g_scramble+scramble_enemyBulletTimer
    blt .r

    cmp #250,go_x(a0)
    bgt .r
    cmp #20,go_x(a0)
    blt .r

    lea Scramble_InitEnemyBullet,a1
    jsr GOManager_SpawnGameObject_EnemyBullet
    move #0,g_scramble+scramble_enemyBulletTimer
        
.r: rts
    
Scramble_InitEnemyBullet:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_ENEMYBULLET,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    
    move.l g_player,a1
    
    move.l g_player,a1
    jsr GOTOOLS_GetAngToGO
    move d0,go_rot(a0)
    jsr GOTOOLS_GetMovementVecFromRot
    lsl.l #3,d2
    lsl.l #3,d1
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)

    move #100,go_timer(a0)
    
    ;move.l #.collided,go_onCollided(a0)
    rts    
    
;.collided:
;    lea Scramble_InitExplosion,a1
;    jsr GOManager_SpawnGameObject_FX
;    jmp GOManager_DeleteObject
            
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Scramble_GetSolidColGO
    bne .die1

    sub #1,go_timer(a0)
    blt .die1

    cmp #320+32,go_x(a0)
    bge .die1    
    cmp #-32,go_x(a0)
    ble .die1    
    rts
.die:
    lea Scramble_InitExplosion,a1
    jsr GOManager_SpawnGameObject_FX
.die1:
    jmp GOManager_DeleteObject
    

Scramble_InitEnemy_FollowFloor:
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_ENEMY1,go_frame(a0)
    
    move.l #Scramble_EnemyCollidedWithBullet,go_onCollided(a0)

    move.l g_currentSpawnListAddr,a4
    move scramgen_x(a4),go_x(a0)
    move scramgen_y(a4),go_y(a0)
    and #$fffe,go_x(a0)
    and #$fffe,go_y(a0)

    bsr Scramble_Enemy_MoveUpwardsOutOfScenery

    move #5,go_health(a0)
    move #2,go_rot(a0)      ; down
    
    bsr .move
    move.l #.updatestate_move,go_onUpdate(a0)
    rts

.updatestate_test:
    
; test forwards: if it's blocked then turn right
    lea .forwardTests,a1
    bsr .testatoffset
    bne .turnright
; forwards is empty. Is the block to the left blocked?
    lea .leftTests,a1
    bsr .testatoffset
    bne .move
; the block to the left is blocked, 
; test the block to the bottom left
    lea .bottomLeftTests,a1
    bsr .testatoffset
    bne .turnLeft
    
.move:
    move go_rot(a0),d0
    lsl #3,d0
    lea .vectors,a1
    add d0,a1
    move.l (a1)+,go_dx(a0)
    move.l (a1)+,go_dy(a0)
    move #8,go_timer(a0)
    rts
    
.turnright:
    add #1,go_rot(a0)
    and #3,go_rot(a0)
    bra .updatestate_test

.turnLeft:
    sub #1,go_rot(a0)
    and #3,go_rot(a0)
    bra .move
    

; a1 is list
.testatoffset:
    move go_rot(a0),d0
    lsl #2,d0
    add d0,a1
    move go_x(a0),d0
    add (a1)+,d0
    move go_y(a0),d1
    add (a1)+,d1
    bsr Scramble_GetSolidCol
    rts
    
    
.updatestate_move:
    bsr Scramble_TestGenerateEnemyBullet

    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    sub #1,go_x(a0)     ; scroll
    
    cmp #-32,go_x(a0)
    blt .die
    
    sub #1,go_timer(a0)
    bgt .r
    bsr .updatestate_test
.r: rts

.die: 
    jmp GOManager_DeleteObject

.vectors:
    dc.l 0,-$10000, $10000,0, 0,$10000, -$10000,0
    
.forwardTests:
    dc.w 0,-8, 8,0, 0,8, -8,0

.leftTests:
    dc.w -8,0, 0,-8, 8,0, 0,8

.bottomLeftTests:
    dc.w -8,8, -8,-8, 8,-8, 8,8
    

;extra0 is path index    
Scramble_InitEnemy_FollowPath:
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_ENEMY1,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #Scramble_EnemyCollidedWithBullet,go_onCollided(a0)

    move #5,go_health(a0)

    move.l g_currentSpawnListAddr,a4

    lea sysg_levelInfo,a3
    move.l levelinfo_paths(a3),a3
    
    move scramgen_extra0(a4),d0
    and #3,d0
    lsl #2,d0
    move.l (a3,d0),a2       ;lea Level_4_Path_0,a2
    
    
    
    lea go_path(a0),a1
    move (a2)+,path_numNodes(a1)
    move.l a2,path_addr(a1)
    move.l #0,path_currentIndex(a1)

    move scramgen_x(a4),go_startx(a0)
    move scramgen_y(a4),go_starty(a0)
    move go_startx(a0),go_x(a0)
    move go_starty(a0),go_y(a0)
    

    rts
    
.update:
    bsr Scramble_TestGenerateEnemyBullet

    lea.l go_path(a0),a1
    move.l path_addr(a1),a2
    
    add #1,path_currentIndex(a1)
    move path_currentIndex(a1),d0
    cmp path_numNodes(a1),d0
    bge .die
    
    
    move path_currentIndex(a1),d0
    lsl #2,d0
    add d0,a2

    move (a2)+,d0
    add go_startx(a0),d0
    move d0,go_x(a0)
    
    move (a2)+,d0
    add go_starty(a0),d0
    move d0,go_y(a0)


    move.w go_x(a0),d0
    cmp #-32,d0
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject
    
    
    
;extra0 = rot offset, extra1 = rot speed, extra2 = multiplier 
Scramble_InitEnemy_UpDown:
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_ENEMY1,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #Scramble_EnemyCollidedWithBullet,go_onCollided(a0)

    move #5,go_health(a0)

    move.l g_currentSpawnListAddr,a4
    move scramgen_x(a4),go_startx(a0)
    move scramgen_y(a4),go_starty(a0)
    
    move scramgen_extra0(a4),go_timer(a0)
    move scramgen_extra1(a4),go_timerl(a0)
    move scramgen_extra2(a4),go_word0(a0)
    rts
    
.update:
    bsr Scramble_TestGenerateEnemyBullet

    move go_timerl(a0),d0
    add d0,go_timer(a0)
    move go_timer(a0),d0
    
    jsr UTILS_GetSinCosLong
    
    move go_word0(a0),d2
    muls d2,d0
    muls d2,d1
    
    add.l go_startx(a0),d0
    add.l go_starty(a0),d1
    move.l d0,go_x(a0)
    move.l d1,go_y(a0)
    
    sub.l #$18000,go_startx(a0)

    move.w go_x(a0),d0
    cmp #-32,d0
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject
    
    
    clrso
scramgen_xgap so.w 1    
scramgen_enemyAddr so.l 1    
scramgen_x so.w 1    
scramgen_y so.w 1    
scramgen_extra0 so.w 1    
scramgen_extra1 so.w 1    
scramgen_extra2 so.w 1    
scramgen_structsize so.w 1    

SCRAMGEN macro \1,\2,\3,\4
    dc.w \1
    dc.l \2
    dc.w \3,\4
    dc.w \5,\6,\7
    endm
    
go_scramgen_currentEntryAddr equ go_long0
go_scramgen_testPos equ go_word0
Scramble_InitGenerator:
    GO_SET_INVISIBLE
    move.l #.update,go_onUpdate(a0)
    move #0,go_timer(a0)
    move.l #Scramble_SpawnList,go_scramgen_currentEntryAddr(a0)
    move #0,go_scramgen_testPos(a0)
    rts
.update:
    move.l go_scramgen_currentEntryAddr(a0),a4
    
    cmp #-1,scramgen_xgap(a4)
    beq .looped
    cmp #-2,scramgen_xgap(a4)
    beq .finished
    
    
    move scramgen_xgap(a4),d0
    add go_scramgen_testPos(a0),d0
    cmp go_timer(a0),d0
    bne .nomatch
.found:

; generate
    PUSHALL
    move.l scramgen_enemyAddr(a4),a1
    move.l a4,g_currentSpawnListAddr
    jsr GOManager_SpawnGameObject_Treasure
    POPALL

    move scramgen_xgap(a4),d0
    add d0,go_scramgen_testPos(a0)      ; next position
    add.l #scramgen_structsize,go_scramgen_currentEntryAddr(a0)

    ; test for multiple spawns at same pos (xgap = 0)
    move.l go_scramgen_currentEntryAddr(a0),a4
    tst scramgen_xgap(a4)
    beq .found
    

.nomatch:
    add #1,go_timer(a0)
    rts
    
.looped:
    move.l #Scramble_SpawnList,go_scramgen_currentEntryAddr(a0)
    rts
.finished:
    jmp GOManager_DeleteObject
    
    
    
Scramble_GetSolidColGO:
    move go_x(a0),d0
    move go_y(a0),d1

; d0 xpos pixels
; d1 ypos pixels
Scramble_GetSolidCol:
    lea NEWIMAGEGROUP_IMAGEMAP_SCRAMBLE_FG,a2
    lea 6(a2),a2
    
    cmp #0,d1
    blt .empty
    
    add g_scramble+scramble_scrollx,d0
    and #511,d0
    lsr #3,d0
    lsl #1,d0
    add d0,a2
    
    lsr #3,d1
    lsl #6+1,d1
    add d1,a2
    
    move (a2),d0
    and #$3ff,d0
    beq .empty
    moveq #1,d0
    rts
.empty:
    moveq #0,d0
    rts
    


Scramble_InitExplosion:
    move.w go_x(a1),go_x(a0)
    move.w go_y(a1),go_y(a0)
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_EXPLOSION,go_frame(a0)
    move #20,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    GO_SET_INVISIBLE
    move g_timer1_and1,d0
    beq .noflash
    GO_SET_VISIBLE
.noflash:
    sub #1,go_x(a0)
    sub #1,go_timer(a0)
    ble .die
    rts
.die: jmp GOManager_DeleteObject
    
    
Scramble_InitPlayer:
    move.l a0,g_player
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #0,go_frame(a0)
    move #10*16,go_x(a0)
    move #8*16,go_y(a0)
    move.l #.render,go_onRender(a0)

    move.l go_x(a0),go_tox(a0)
    move.l go_y(a0),go_toy(a0)

    move #0,go_shootTimer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
    
.render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    move go_x(a0),d5
    move go_y(a0),d6
    move #0,d4
    bsr .render_doone

    move g_timer1_and1,d0
    beq .no
    move go_x(a0),d5
    move go_y(a0),d6
    move #1,d4
    bsr .render_doone
.no:
    rts
    
.render_doone:
    move d4,sprbuf_frame(a5)
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts
    
.update:
    add #1,g_scramble+scramble_scrollx

    move g_pad0,d0

    move.l #0,go_dx(a0)
    move.l #0,go_dy(a0)

    btst #pad_button_left,d0
    beq .noL
    move.l #-$20000,go_dx(a0)
.noL:
    btst #pad_button_right,d0
    beq .noR
    move.l #$20000,go_dx(a0)
.noR:

    btst #pad_button_up,d0
    beq .noU
    move.l #-$20000,go_dy(a0)
.noU:
    btst #pad_button_down,d0
    beq .noD
    move.l #$20000,go_dy(a0)
.noD:
    
    sub.b #1,go_shootTimer(a0)
    bgt .noA
    move.b #0,go_shootTimer(a0)
    move g_pad0,d0
    btst #pad_button_a,d0
    beq .noA
    bsr Scramble_GeneratePlayerBullet
.noA:
    sub.b #1,go_shootTimer+1(a0)
    bgt .noB
    move.b #0,go_shootTimer+1(a0)
    move g_pad0,d0
    btst #pad_button_b,d0
    beq .noB
    lea Scramble_InitBomb,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.b #30,go_shootTimer+1(a0)
.noB:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    rts
    
Scramble_GeneratePlayerBullet:

    bra .treble
    bra .double
    bra .single
    
.double:
    lea Scramble_InitPlayerBullet_Single,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.l #-$20000,go_dy(a1)
    lea Scramble_InitPlayerBullet_Single,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.l #$20000,go_dy(a1)
    
    move.b #10,go_shootTimer(a0)
    rts

.treble:
    lea Scramble_InitPlayerBullet_Single,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.l #-$30000,go_dy(a1)
    
    lea Scramble_InitPlayerBullet_Single,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.l #$30000,go_dy(a1)

    lea Scramble_InitPlayerBullet_Single,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.l #0,go_dy(a1)
    
    move.b #10,go_shootTimer(a0)
    rts
    

.single:
    lea Scramble_InitPlayerBullet_Single,a1
    jsr GOManager_SpawnGameObject_PlayerBullet
    move.b #10,go_shootTimer(a0)
    rts

Scramble_InitPlayerBullet_Single:
    bsr Scramble_InitPlayerBullet_All
    move.l #$100000,go_dx(a0)
    rts
         
        
Scramble_InitPlayerBullet_All:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_SHOT,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    rts    
    
.collided:
    lea Scramble_InitExplosion,a1
    jsr GOManager_SpawnGameObject_FX
    jmp GOManager_DeleteObject
            
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Scramble_GetSolidColGO
    bne .die

    cmp #320+32,go_x(a0)
    bge .die1    
    rts
.die:
    lea Scramble_InitExplosion,a1
    jsr GOManager_SpawnGameObject_FX
.die1:
    jmp GOManager_DeleteObject

Scramble_InitBomb:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    SETSPR SPRITE_SCRAMBLE_SPRITES
    move #SPRFRAME_SCRAMBLE_SPRITES_BOMB,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #0,go_dy(a0)
    rts
.update:
    sub.l #$8000,go_x(a0)
    add.l #$1000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Scramble_GetSolidColGO
    bne .die
    
    cmp #250,go_y(a0)
    bgt .die1
    rts
.die:
    lea Scramble_InitExplosion,a1
    jsr GOManager_SpawnGameObject_FX
.die1:
    jmp GOManager_DeleteObject

    
Scramble_EnemyCollided:
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
    


Scramble_InitWorldAndLevelStuff_GFX:
    jsr Scramble_InitVDPForLevel
    jsr SpriteCache_BuildFrames
    rts
    
Scramble_PlayMusic:
    move #0,d0
    jsr MUSIC_InitSong
    rts
    
    
Scramble_InitVDPForLevel:
    jsr ClearVRAM

	BORDER 0
    lea SPRPAL_Scramble_Sprites,a0
    move #2,d0
    jsr FADE_CopySinglePaletteToSource

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP

	move #IMAGEASSET_SCRAMBLE_BG,d0
	jsr IMAGE_ShowStaticImagePlaneB
	move #IMAGEASSET_SCRAMBLE_FG,d0
	jsr IMAGE_ShowStaticImage

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
    dc.w SPRITE_SCRAMBLE_SPRITES
    dc.w -1



Scramble_UpdateGame:
    tst.l g_stackwatch
    beq .ok
    DEBUG_HALT
.ok

    jsr UTILS_GetRandWord
    bsr Scramble_UpdateGame_UpdateGlobals
    bsr Scramble_UpdateGame_Normal  
    
    bsr Scramble_UpdateHScroll
    jsr Game_UpdateRealtimeCommands      
    rts
    
Scramble_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
Scramble_UpdateGame_UpdateGlobals:

    add #1,g_scramble+scramble_enemyBulletTimer


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

    

Scramble_UpdateGame_Normal:
    bsr Racing_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    BORDER 20
    jsr GOManager_Update
    jsr Scramble_BulletEnemyCollision
	jsr SPRITE_UpdateFromGOManager_Racing
	BORDER 0
    rts


Scramble_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
	
	bsr Scramble_DMAHScroll
    bsr Scramble_UpdateScrollRegisters
	rts

;-------------------------------------------------------------


Scramble_UpdateScrollRegisters:

	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_CELL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL


	move g_scramble+scramble_scrollx,d0
	add g_screenshake_x,d0
	neg d0
    lea g_scramble+scramble_hscrolltabA,a1

    AUTOINC 32
	SCROLL_START_WRITE_XPOS
	rept 28
	move d0,VDP_DATA
	endr
	SCROLL_START_WRITE_XPOS2
	rept 28
	move (a1)+,VDP_DATA
	endr
	
	
    AUTOINC 2
    move g_scroll_y,d0
    add g_screenshake_y,d0
    and #255,d0
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d1,VDP_DATA
	rts
    
    AUTOINC 2
; hscroll
	
	;move g_scroll_x,d0
	move g_scramble+scramble_scrollx,d0
	add g_screenshake_x,d0
	;and #15,d0
	neg d0
	moveq #0,d1

	SCROLL_START_WRITE_XPOS
	move d0,VDP_DATA
	move d1,VDP_DATA
    AUTOINC 2
    move g_scroll_y,d0
    add g_screenshake_y,d0
    and #255,d0
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d1,VDP_DATA
	rts

    
    
SCRAMBLE_COL_RADX equ 10
SCRAMBLE_COL_RADY equ 20
Scramble_BulletEnemyCollision:

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
    
    cmp #SCRAMBLE_COL_RADX,d2
    bgt .skip
    cmp #-SCRAMBLE_COL_RADX,d2
    blt .skip
    
    
    cmp #SCRAMBLE_COL_RADY,d3
    bgt .skip
    cmp #-SCRAMBLE_COL_RADY,d3
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



Scramble_SpawnList:

    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0


    SCRAMGEN 10,Scramble_InitEnemy_FollowPath,340,100,  0,0,0
    SCRAMGEN 100,Scramble_InitEnemy_FollowPath,340,100,  0,0,0
    SCRAMGEN 100,Scramble_InitEnemy_FollowPath,340,100,  0,0,0
    SCRAMGEN 100,Scramble_InitEnemy_FollowPath,340,100,  0,0,0
    
    
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,50,  0,4,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,80,  0,4,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,110,  0,4,16 
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,140,  0,4,16 
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0

    SCRAMGEN 50,Scramble_InitEnemy_UpDown,340,50,  0,-4,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,80,  0,-4,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,110,  0,-4,16 
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,140,  0,-4,16 

    SCRAMGEN 50,Scramble_InitEnemy_UpDown,340,50,  0,6,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,80,  0,6,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,110,  0,6,16 
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,140,  0,6,16 

    SCRAMGEN 50,Scramble_InitEnemy_UpDown,340,50,  0,-6,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,80,  0,-6,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,110,  0,-6,16 
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,140,  0,-6,16 

    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0

    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,8,10
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,7,30
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,6,50
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,5,70
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,90
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,3,110

    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0 

    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0

    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,10
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  32,4,30
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  64,4,50
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  96,4,70
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  128,4,90
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  160,4,110

    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0 
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0


    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,10
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,30
        SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0

    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,50

    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,70
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,90
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,110

    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0 


    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,10
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,15
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,20
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,25
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,30
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,35
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,40


    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,50,  0,4,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,16
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,150,  0,4,16 

    SCRAMGEN 80,Scramble_InitEnemy_UpDown,340,50,  0,4,20
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,100,  0,4,20 
    SCRAMGEN 0,Scramble_InitEnemy_UpDown,340,150,  0,4,20 
    
        SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0



    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  1,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  2,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  3,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  4,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  5,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  6,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Bouncer,352,0,  7,0,0
    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0
    
    
    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0 

    SCRAMGEN 10,Scramble_InitEnemy_FollowFloor,340,128,  0,0,0


    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,10
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,15
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,20
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,25
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,30
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,35
    SCRAMGEN 30,Scramble_InitEnemy_UpDown,340,100,  0,4,40

    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0
    SCRAMGEN 50,Scramble_InitEnemy_Rocket,352,0,  0,0,0 

    dc.w -1
