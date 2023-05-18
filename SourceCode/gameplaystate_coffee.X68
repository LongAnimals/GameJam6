
    INCLUDE "coffee_verlet.X68"

COFFEE_BOSS1_HEADTIME_ON equ 500 
COFFEE_BOSS1_HEADTIME_OFF equ 500 

COF_BOSS_DEAD_TIME equ 60*5
COF_PLAYER_SHOT_TIMER equ 8
COF_INITIAL_WEAPON equ 0
COF_INITIAL_HEALTH equ 26          ;26
COF_GROUND_PER_PICKUPLEVEL equ 12

COF_HEALTH_ROCKET equ 10
COF_HEALTH_BIGPOT equ 200
COF_HEALTH_SCALER equ 30
COF_HEALTH_POT0 equ 20
COF_HEALTH_PRESS equ 20
COF_HEALTH_BEAN0 equ 1
COF_HEALTH_BEAN1 equ 8
COF_HEALTH_BEAN2 equ 16
COF_HEALTH_BOSS1 equ 500

COF_SCORE_ROCKET equ 10
COF_SCORE_BIGPOT equ 50
COF_SCORE_SCALER equ 30
COF_SCORE_POT0 equ 20
COF_SCORE_PRESS equ 20
COF_SCORE_BEAN0 equ 1
COF_SCORE_BEAN1 equ 2
COF_SCORE_BEAN2 equ 3
COF_SCORE_BOSS1 equ 100

Coffee_ExitState:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts

;multigen
    clrso
mg_active   so.b      1
mg_state    so.b      1
mg_timer    so.w      1
mg_timerMax    so.w      1
mg_x        so.w    1        
mg_y        so.w    1        
mg_generateFunc    so.l  1
mg_spawnerListAddr    so.l  1
mg_spawnerDataAddr    so.l  1
mg_pathDataAddr    so.l    1
mg_count    so.w    1
mg_data0    so.w    1
mg_data1    so.w    1
mg_data2    so.w    1
mg_data3    so.w    1
mg_data4    so.w    1
mg_data5    so.w    1
mg_structsize   so.w 0

COFFEE_MULTIGEN_AMT equ 8
COFFEE_MULTIGEN_SIZE equ COFFEE_MULTIGEN_AMT * mg_structsize 

COFFEE_SCROLLSPEED equ $8000

COFFEE_SORTEDSPAWNLIST_NUMENTRIES equ 128

COFFEE_NUM_COLLISION_BUCKETS equ 5
COFFEE_MAX_PER_BUCKET equ 32
COFFEE_BUCKET_LSR equ 6

COF_SPRSCALEBUFFER_SIZE equ (16*32)     ; 4x4 sprite, 512 bytes

    clrso
cof_scrollx so.l 1
cof_scrollSpeed so.l 1
cof_enemyBulletTimer so.w 1
cof_hscrolltabA so.w 28
cof_hscrolltabB so.w 28
cof_m_multigen so.l 1
cof_resetLevelFlag so.b 1
cof_pauseScrollFlag so.b 1
cof_pickupLevel so.w     1
cof_weaponLevel so.w     1
cof_fontdrawarea so.b     18
cof_loopCounter so.w 1
cof_word0 so.w 1
cof_long0 so.l 1
cof_m_verletPoints so.l 1
cof_m_verletConnectors so.l 1
cof_verletSim so.b vc_structsize
cof_playerInvulnerableTimer so.w 1
cof_playerHealth so.w 1
cof_boss1Data       so.b boss1_structsize
cof_sortedSpawnListCurrentIndex so.w 1
cof_sortedSpawnList so.w COFFEE_SORTEDSPAWNLIST_NUMENTRIES*2
cof_m_collision_EnemyBuckets so.l 1
cof_collEnemyBucketPointers so.l COFFEE_NUM_COLLISION_BUCKETS
cof_m_collision_BulletBuckets so.l 1
cof_collBulletBucketPointers so.l COFFEE_NUM_COLLISION_BUCKETS
cof_m_spriteScaleBuffer    so.l 1
cof_spriteScaleVDPOffset    so.w 1
cof_doSpriteScale so.w 1
cof_structsize so.b 0

Coffee_InitGlobals:
    move.l #0,g_cof+cof_scrollx
    move #0,g_cof+cof_enemyBulletTimer
    move.b #0,g_cof+cof_resetLevelFlag
    move #0,g_cof+cof_pickupLevel
    move #COF_INITIAL_WEAPON,g_cof+cof_weaponLevel
    move.b #0,g_cof+cof_pauseScrollFlag
    move.l #COFFEE_SCROLLSPEED,g_cof+cof_scrollSpeed
    move.l #0,sysg_score
    move.w #0,g_cof+cof_playerInvulnerableTimer
    move.w #COF_INITIAL_HEALTH,g_cof+cof_playerHealth
    move.w #0,g_cof+cof_sortedSpawnListCurrentIndex
    move.w #0,g_cof+cof_doSpriteScale
    
    move.l #0,g_boss
    rts

Coffee_MEM_AllocForGame
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup
    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup
    lea MEM_Table_GameObjects,a0
    bsr MEM_AllocateGroup
    lea MEM_Table_Coffee,a0
    bsr MEM_AllocateGroup
    bsr MEM_ShowDebug
    rts
MEM_Table_Coffee:
    dc.l g_cof+cof_m_multigen
    dc.w COFFEE_MULTIGEN_SIZE

    dc.l m_hblankDataTable
    dc.w (256*4)*2  ; = 2048

    dc.l g_cof+cof_m_spriteScaleBuffer
    dc.w COF_SPRSCALEBUFFER_SIZE


    dc.l g_cof+cof_m_collision_EnemyBuckets
    dc.w COFFEE_NUM_COLLISION_BUCKETS*COFFEE_MAX_PER_BUCKET*4        ;512
    dc.l g_cof+cof_m_collision_BulletBuckets
    dc.w COFFEE_NUM_COLLISION_BUCKETS*COFFEE_MAX_PER_BUCKET*4        ;512

    
    dc.l g_cof+cof_m_verletPoints
    dc.w COF_VERLET_MAXPOINTS*vp_structsize         ;10*32 = 320
    dc.l g_cof+cof_m_verletConnectors
    dc.w COF_VERLET_MAXCONNECTORS*vc_structsize     ;12*32
    

    dc.l -1

Coffee_InitState:
    move.l #Coffee_ExitState,sysg_scene_exitFunc
	jsr Globals_ClearAll
    jsr MEM_Init
    jsr Coffee_MEM_AllocForGame 
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

    ;move.b #1,sysg_cheatmode

    jsr ColorBars_InitHBL

    move #LEVEL_COFFEE1,d0
    jsr LEVEL_InitData

    bsr SpriteScaler_Init

	jsr SOUND_Init
    move #SONG_COFFEEBACH,d0
    jsr MUSIC_InitSong
    
	jsr SCROLL_SetNormalPlanes
	jsr SCROLL_CreateDMATables

    move.l #0,g_scroll_x
    move.l #0,g_scroll_y
    bsr Coffee_CreateSortedSpawnList
    bsr Coffee_InitGlobals
    jsr Coffee_InitForGame
    jsr Coffee_InitForLevel
    bsr Coffee_InitMultiGen

    bsr Coffee_InitWorldAndLevelStuff_GFX
    bsr Coffee_InitWorldAndLevelStuff_Mem
    
    move.l #0,g_scroll_x
    move.l #0,g_scroll_y
    jsr SCROLL_FillScrollA
    bsr Coffee_InitBG_HScroll

	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #Coffee_UpdateGame,g_game_loopaddr
	move.l #Coffee_UpdateVBL,g_game_vbladdr

    

    rts

Coffee_ResetForRealtimeCommand:
    move.l #0,g_scroll_x
    move.l #0,g_scroll_y

    bsr Coffee_InitGlobals
    jsr Coffee_InitForGame
    jsr Coffee_InitForLevel
    bsr Coffee_InitMultiGen
    bsr Coffee_InitWorldAndLevelStuff_GFX
    bsr Coffee_InitWorldAndLevelStuff_Mem
    
    move.l #0,g_scroll_x
    move.l #0,g_scroll_y
    jsr SCROLL_FillScrollA
    bsr Coffee_UpdateSpawnSingleCallStuff
    bsr Coffee_InitBG_HScroll

    rts

    
Coffee_InitBG_HScroll:
    lea g_cof+cof_hscrolltabA,a1
    move #28-1,d1
.lp:    move #0,(a1)+
    dbra d1,.lp
    rts 

Coffee_UpdateBG_HScroll:
    lea g_cof+cof_hscrolltabA,a1
    lea .values,a0
    move #28-1,d7
    move g_timer1,d2
    move #1,d3
.lp:
    move d2,d0
    and (a0)+,d0
    beq .no
    sub d3,(a1) 
.no:    
    lea 2(a1),a1
    dbra d7,.lp
    rts 
.values: 
    dc.w 1,1,1,1,3,3,3,3,7,7,7,7,15,15,15,15
    dc.w 7,7,7,7,3,3,3,3,1,1,1,1,1,1,1,1
    
    
Coffee_InitForGame:
    rts
    

Coffee_InitForLevel:
    rts
    

Coffee_InitWorldAndLevelStuff_Mem:
    bsr Coffee_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    jsr Coffee_InitGOs
    rts
    
Coffee_InitGOs:

    lea Coffee_InitHUD,a1
    bsr CoffeeSpawnGO_General

    bsr Coffee_FindAndInitPlayer
    ;lea Coffee_InitPlayer,a1
    ;bsr CoffeeSpawnGO_General

    ;lea Coffee_InitEnemy_VerletTest,a1
    ;bsr CoffeeSpawnGO_General
    
    rts

CoffeeSpawnGO_General:
    jmp GOManager_SpawnGameObject_Car

CoffeeSpawnGO_Enemy:
    jmp GOManager_SpawnGameObject_Treasure

CoffeeSpawnGO_EnemyBullet:
    jmp GOManager_SpawnGameObject_EnemyBullet

CoffeeSpawnGO_PlayerBullet:
    jmp GOManager_SpawnGameObject_PlayerBullet

CoffeeSpawnGO_Pickup:
    jmp GOManager_SpawnGameObject_Treasure

CoffeeSpawnGO_FX:
    jmp GOManager_SpawnGameObject_FX



Coffee_Enemy_MoveUpwardsOutOfScenery:
    move go_x(a0),d3
    move go_y(a0),d4
.inityloop:
    move d3,d0
    move d4,d1    
    bsr Coffee_GetSolidCol
    beq .inityok
    sub #8,d4
    bra .inityloop
.inityok:
    add #8,d4
    move d4,go_y(a0)
    rts

Coffee_Enemy_PlaceOnScenery:
    move go_x(a0),d3
    move #224-8,d4
.inityloop:
    move d3,d0
    move d4,d1    
    bsr Coffee_GetSolidCol
    beq .inityok
    sub #8,d4
    bra .inityloop
.inityok:
    add #8,d4
    move d4,go_y(a0)
    rts
    
Coffee_InitEnemy_Rocket:        ; rocket
    SETSPR SPRITE_COFFEE_PAL0
    move #SPRFRAME_COFFEE_PAL0_SPOON,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)

    move #COF_HEALTH_ROCKET,go_health(a0)
    move #COF_SCORE_ROCKET,go_score(a0)

    jsr UTILS_GetRandWord
    and #127,d0
    add #150,d0
    move d0,go_timer(a0)
    move.l #0,go_dy(a0)

    move.l #.colldier,go_colliderAddr(a0)
    rts

.colldier:
    dc.w -8,8,-32,0

    
.update:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)
    sub #1,go_timer(a0)
    bgt .ok
    sub.l #$800,go_dy(a0)
    
    cmp.l #-$10000,go_dy(a0)
    bgt .nomax
    move.l #-$10000,go_dy(a0)
.nomax
    
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

    
Coffee_EnemyCollidedWithBullet_UseSpawnForGrounds:
    move go_health(a1),d0
    sub d0,go_health(a0)
    ble .die
    PSG_PLAY_SFX PSGSFX_gunslugs_hit_crate
    rts
.die:
    PSG_PLAY_SFX PSGSFX_gunslugs_mine_explosion
    moveq #0,d0
    move.w go_score(a0),d0
    add.l d0,sysg_score
    bsr Coffee_TestHighScore 


    lea Coffee_InitGrounds,a1
    jsr CoffeeSpawnGO_EnemyBullet

    jmp GOManager_DeleteObject
    
Coffee_EnemyCollidedWithBullet:
    bra Coffee_EnemyCollidedWithBullet_UseSpawnForGrounds


    move go_health(a1),d0
    sub d0,go_health(a0)
    ble .die
    PSG_PLAY_SFX PSGSFX_gunslugs_hit_crate
    rts
.die:
    PSG_PLAY_SFX PSGSFX_gunslugs_mine_explosion
    moveq #0,d0
    move.w go_score(a0),d0
    add.l d0,sysg_score
    bsr Coffee_TestHighScore 


    ;bra COFFEE_ConvertEnemyToGrounds
    lea Coffee_InitGrounds,a1
    jsr CoffeeSpawnGO_EnemyBullet

    jmp GOManager_DeleteObject


;-------------------------------------------------------------------------------------------

Coffee_InitEnemy_BigPot:
    SETSPR SPRITE_COFFEE_PAL0
    SETCOMPSPR COMPOUNDSPRITE_COFFEE_BIGPOT
    move #0,go_frame(a0)
    move #COF_HEALTH_BIGPOT,go_health(a0)
    move #COF_SCORE_BIGPOT,go_score(a0)
    move.l #.colldier,go_colliderAddr(a0)
    move.l #.oncollided,go_onCollided(a0)
    move.l #.state_moveon,go_onUpdate(a0)
    move.l #-$40000,go_dx(a0)
    rts

.colldier:
    dc.w -32,32,-32,32
.oncollided:
    bsr Coffee_EnemyCollidedWithBullet_UseSpawnForGrounds   ; cos of active state being tested here, that's a bit shit
    tst.b go_activestate(a0)
    bne .collided1
    move.l #COFFEE_SCROLLSPEED,g_cof+cof_scrollSpeed
    move.b #0,g_cof+cof_pauseScrollFlag
.collided1: 
    rts


.animate:
    add.l #$3000,go_frame(a0)
    cmp #16,go_frame(a0)
    blt .noanim
    move.l #0,go_frame(a0)
.noanim:
    rts
    

.state_moveon:
    bsr .animate
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    add.l #$1000,go_dx(a0)
    bgt .moveon_done
    rts
.moveon_done:
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
    move #0,go_word0(a0)
    move.b #1,g_cof+cof_pauseScrollFlag
    move.l #0,g_cof+cof_scrollSpeed
    bsr .initstate_move
    rts
    
.initstate_move:
    move.l #.update_move,go_onUpdate(a0)
    move #50,go_timer(a0)

    move go_word0(a0),d0
    lsl #2,d0
    lea .offsets,a1
    add d0,a1
    moveq #0,d1
    move (a1)+,d1
    swap d1
    add.l go_oldx(a0),d1
    move.l d1,go_tox(a0)
    moveq #0,d1
    move (a1)+,d1
    swap d1
    add.l go_oldy(a0),d1
    move.l d1,go_toy(a0)

    add #1,go_word0(a0)
    cmp #3,go_word0(a0)
    ble .imok
    move #0,go_word0(a0)
.imok
    rts
    
.offsets:
    dc.w -50,-50
    dc.w 50,-50
    dc.w 50,30
    dc.w -50,30
    
.update_move:
    bsr .animate
    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #4,d0
    add.l d0,go_x(a0)
    
    move.l go_toy(a0),d0
    sub.l go_y(a0),d0
    asr.l #4,d0
    add.l d0,go_y(a0)

    sub #1,go_timer(a0)
    blt .initstate_shoot
    rts    
    
    
.initstate_shoot:
    move #30,go_timer(a0)    
    move #10,go_shootTimer(a0)
    move.l #.update_shoot,go_onUpdate(a0)
    rts
    
.update_shoot:
    bsr .animate
    sub #1,go_shootTimer(a0)
    blt .noshoot
    move go_x(a0),-(sp)
    move go_y(a0),-(sp)
    sub #32,go_y(a0)
    sub #16,go_x(a0)
    lea Coffee_InitEnemyBullet_Vels,a1
    jsr CoffeeSpawnGO_EnemyBullet
    move (sp)+,go_y(a0)
    move (sp)+,go_x(a0)


    lea .vels,a2
    move go_shootTimer(a0),d0
    lsl #3,d0
    add d0,a2
    move.l (a2)+,go_dx(a1)
    move.l (a2),go_dy(a1)
    

.noshoot
    sub #1,go_timer(a0)
    blt .initstate_move
    rts    
    
    
.die:
    jmp GOManager_DeleteObject

.vels:
    dc.l -$10000,-$8000
    dc.l -$18000,-$4000
    dc.l -$20000,$00000
    dc.l -$18000,$4000
    dc.l -$10000,$8000

    dc.l -$10000,-$a000
    dc.l -$18000,-$6000
    dc.l -$20000,$00000
    dc.l -$18000,$6000
    dc.l -$10000,$a000

;-------------------------------------------------------------------------------------------

Coffee_InitEnemy_Scaler:
    SETSPR SPRITE_COFFEE_PAL0_SOFTWARESPRITE
    move #0,go_frame(a0)
    move #COF_HEALTH_SCALER,go_health(a0)
    move #COF_SCORE_SCALER,go_score(a0)
    move.l #.colldier,go_colliderAddr(a0)
    move.l #.collided,go_onCollided(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #-$18000,go_dx(a0)
    rts

.collided:
    move go_health(a1),d0
    sub d0,go_health(a0)
    ble .die
    PSG_PLAY_SFX PSGSFX_gunslugs_hit_crate
    rts
.die:
    PSG_PLAY_SFX PSGSFX_gunslugs_mine_explosion
    moveq #0,d0
    move.w go_score(a0),d0
    add.l d0,sysg_score
    bsr Coffee_TestHighScore 
    
    move #0,g_cof+cof_doSpriteScale
    jmp GOManager_DeleteObject

.colldier:
    dc.w -16,16,-16,16

.update:
    move #1,g_cof+cof_doSpriteScale
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    cmp #-32,go_x(a0)
    blt .off
    rts
.off:
    move #0,g_cof+cof_doSpriteScale
    jmp GOManager_DeleteObject
    

;-------------------------------------------------------------------------------------------

Coffee_InitEnemy_Pot0:
    SETSPR SPRITE_COFFEE_PAL0
    SETCOMPSPR COMPOUNDSPRITE_COFFEE_POT0
    move.l #.update,go_onUpdate(a0)
    move #COF_HEALTH_POT0,go_health(a0)
    move #COF_SCORE_POT0,go_score(a0)
    move #100,go_shootTimer(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    move.l #.colldier,go_colliderAddr(a0)
    move #0,go_frame(a0)
    rts

.colldier:
    dc.w -16,16,-40,0

.update:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)
    
    sub #1,go_shootTimer(a0)
    bgt .noshoot
    move #100,go_shootTimer(a0)
    sub #40,go_y(a0)
    lea Coffee_InitEnemyBullet_ShootAtPlayer,a1
    jsr CoffeeSpawnGO_EnemyBullet
    add #40,go_y(a0)
.noshoot:
    
    move g_timer1,d0
    lsr #2,d0
    and #15,d0
    move.b .frames(pc,d0),go_frame+1(a0)
    
    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject
.frames:
    dc.b 0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1

;-------------------------------------------------------------------------------------------

Coffee_InitEnemy_Press:
    SETSPR SPRITE_COFFEE_PAL0
    SETCOMPSPR COMPOUNDSPRITE_COFFEE_PRESS
    move #COF_HEALTH_PRESS,go_health(a0)
    move #COF_SCORE_PRESS,go_score(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    move.l #.colldier,go_colliderAddr(a0)
    bsr .initstate_normal
    move.l #0,go_frame(a0)
    rts

.colldier:
    dc.w -16,16,-32,0

.initstate_normal
    move.l #.update_normal,go_onUpdate(a0)
    move #0,go_timer(a0)
    rts

.update_normal:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)

    add.l #$4000,go_frame(a0)
    cmp #19,go_frame(a0)
    beq .initstate_cooldown    
    
    cmp #-32,go_x(a0)
    blt .die
    rts

    rts        
        
.initstate_shoot:
    move #0,go_frame(a0)
    move #3,go_shootTimer(a0)
    move.l #.updatestate_shoot,go_onUpdate(a0)
    rts
.updatestate_shoot:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)
    sub #1,go_shootTimer(a0)
    blt .initstate_normal
    move go_x(a0),-(sp)
    move go_y(a0),-(sp)
    sub #32,go_y(a0)
    lea Coffee_InitEnemyBullet_Vels,a1
    jsr CoffeeSpawnGO_EnemyBullet
    move (sp)+,go_y(a0)
    move (sp)+,go_x(a0)


    lea .vels,a2
    move go_shootTimer(a0),d0
    lsl #3,d0
    add d0,a2
    move.l (a2)+,go_dx(a1)
    move.l (a2),go_dy(a1)
    rts
    
.initstate_cooldown:
    move.l #.updatestate_cooldown,go_onUpdate(a0)
    move #19,go_frame(a0)

.updatestate_cooldown
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)
    
    sub #2,go_frame(a0)
    ble .initstate_shoot
    
    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject

.vels:
    dc.l -$8000-COFFEE_SCROLLSPEED,-$c000
    dc.l 0000-COFFEE_SCROLLSPEED,-$10000
    dc.l $8000-COFFEE_SCROLLSPEED,-$c000
;-------------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------

Coffee_InitEnemy_PressYflip:
    SETSPR SPRITE_COFFEE_PAL0
    SETCOMPSPR COMPOUNDSPRITE_COFFEE_PRESSYFLIP
    move #COF_HEALTH_PRESS,go_health(a0)
    move #COF_SCORE_PRESS,go_score(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    move.l #.colldier,go_colliderAddr(a0)
    bsr .initstate_normal
    move.l #0,go_frame(a0)
    rts

.colldier:
    dc.w -32,32,0,64

.initstate_normal
    move.l #.update_normal,go_onUpdate(a0)
    move #0,go_timer(a0)
    rts

.update_normal:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)

    add.l #$4000,go_frame(a0)
    cmp #19,go_frame(a0)
    beq .initstate_cooldown    
    
    cmp #-32,go_x(a0)
    blt .die
    rts

    rts        
        
.initstate_shoot:
    move #0,go_frame(a0)
    move #3,go_shootTimer(a0)
    move.l #.updatestate_shoot,go_onUpdate(a0)
    rts
.updatestate_shoot:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)
    sub #1,go_shootTimer(a0)
    blt .initstate_normal
    move go_x(a0),-(sp)
    move go_y(a0),-(sp)
    add #32,go_y(a0)
    lea Coffee_InitEnemyBullet_Vels,a1
    jsr CoffeeSpawnGO_EnemyBullet
    move (sp)+,go_y(a0)
    move (sp)+,go_x(a0)


    lea .vels,a2
    move go_shootTimer(a0),d0
    lsl #3,d0
    add d0,a2
    move.l (a2)+,go_dx(a1)
    move.l (a2),go_dy(a1)
    rts
    
.initstate_cooldown:
    move.l #.updatestate_cooldown,go_onUpdate(a0)
    move #19,go_frame(a0)

.updatestate_cooldown
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)
    
    sub #2,go_frame(a0)
    ble .initstate_shoot
    
    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject

.vels:
    dc.l -$8000-COFFEE_SCROLLSPEED,$c000
    dc.l 0000-COFFEE_SCROLLSPEED,$10000
    dc.l $8000-COFFEE_SCROLLSPEED,$c000
;-------------------------------------------------------------------------------------------------------

Coffee_TestGenerateEnemyBullet:
    cmp #60,g_cof+cof_enemyBulletTimer
    blt .r

    cmp #250,go_x(a0)
    bgt .r
    cmp #20,go_x(a0)
    blt .r

    lea Coffee_InitEnemyBullet_ShootAtPlayer,a1
    jsr CoffeeSpawnGO_EnemyBullet
    move #0,g_cof+cof_enemyBulletTimer
        
.r: rts
    
Coffee_InitEnemyBullet_ShootAtPlayer:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    ;SETSPR SPRITE_COFFEE_PAL0
    ;move #SPRFRAME_COFFEE_PAL0_BEANBULLET,go_frame(a0)
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_BEANBULLET
    
    move.l #.update,go_onUpdate(a0)

    bsr Coffee_CollisionFromFrame
        
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
    
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Coffee_GetSolidColGO
    bne .die1

    sub #1,go_timer(a0)
    blt .die1

    cmp #320+32,go_x(a0)
    bge .die1    
    cmp #-32,go_x(a0)
    ble .die1    
    rts
.die:
    lea Coffee_InitExplosion,a1
    jsr CoffeeSpawnGO_FX
.die1:
    jmp GOManager_DeleteObject
    

Coffee_InitEnemyBullet_Vels:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    ;SETSPR SPRITE_COFFEE_PAL0
    ;move #SPRFRAME_COFFEE_PAL0_BEANBULLET,go_frame(a0)
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_BEANBULLET
    move.l #.update,go_onUpdate(a0)
    bsr Coffee_CollisionFromFrame
    rts    
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Coffee_GetSolidColGO
    bne .die1

    cmp #224+32,go_y(a0)
    bge .die1    
    cmp #-32,go_y(a0)
    ble .die1    

    cmp #320+32,go_x(a0)
    bge .die1    
    cmp #-32,go_x(a0)
    ble .die1    
    rts
.die:
    lea Coffee_InitExplosion,a1
    jsr CoffeeSpawnGO_FX
.die1:
    jmp GOManager_DeleteObject


COFFEE_ConvertEnemyToGrounds:
    move.l #Coffee_UpdateGrounds,go_onUpdate(a0)
    move.b #0,go_coltype(a0)
    move.b #COLTYPE_PICKUP,go_coltype(a0)
    move.l #-$10000,go_dy(a0)
    move #120,go_timer(a0)
    move.l #.collision,go_colliderAddr(a0);
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_GROUNDS
    move #0,go_frame(a0)
    move.l #0,go_onCollided(a0)
    move.l #0,go_compoundSprAddr(a0)
    rts
.collision:
    dc.w -12,12,-12,12
    
Coffee_InitGrounds:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    move.l #Coffee_UpdateGrounds,go_onUpdate(a0)
    move.b #0,go_coltype(a0)
    move.b #COLTYPE_PICKUP,go_coltype(a0)
    move.l #-$10000,go_dy(a0)
    move #120,go_timer(a0)
    move.l #.collision,go_colliderAddr(a0);
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_GROUNDS
    move #0,go_frame(a0)
    rts
.collision:
    dc.w -12,12,-12,12
    
Coffee_UpdateGrounds
    
    sub.l #$18000,go_x(a0)
    
    sub #1,go_timer(a0)
    ble .die
    
    move go_timer(a0),d0
    and #3,d0
    add d0,d0
    move.w .flips(pc,d0),go_sprAttributes(a0)
    
    cmp #-32,go_x(a0)
    blt .die
    rts
.die: jmp GOManager_DeleteObject

.flips:
    dc.w 0,FLIP_H,FLIP_HV,FLIP_V

;d0 is index
Coffee_SetEnemySprFromIndex:
    lsl #4,d0
    move.l .animbases+0(pc,d0),go_long2(a1) ; frame table
    move .animbases+4(pc,d0),go_health(a1)
    move .animbases+6(pc,d0),go_score(a1)
    
    move.l go_long2(a1),a2
    move.l (a2),go_cached_frame_addr(a1)
    
    move .animbases+8(pc,d0),d1
    move.l sysg_sprites_baseaddr2,a2
    lsl #2,d1
    move.l (a2,d1),a2 ;go_sprgroup

    move.l sprgroup_coltable_addr(a2),a2
    move .animbases+10(pc,d0),d0
    lsl #3,d0
    add d0,a2
    move.l a2,go_colliderAddr(a1)

    rts

.animbases:
    dc.l .frames_small
    dc.w COF_HEALTH_BEAN0,COF_SCORE_BEAN0
    dc.w SPRITE_COFFEE_PAL0,SPRFRAME_COFFEE_PAL0_BEAN_SMALL,0,0
    
    dc.l .frames_medium
    dc.w COF_HEALTH_BEAN1,COF_SCORE_BEAN1
    dc.w SPRITE_COFFEE_PAL0,SPRFRAME_COFFEE_PAL0_BEAN_MEDIUM,0,0
    
    dc.l .frames_large
    dc.w COF_HEALTH_BEAN2,COF_SCORE_BEAN2
    dc.w SPRITE_COFFEE_PAL0,SPRFRAME_COFFEE_PAL0_BEAN_LARGE,0,0

.frames_small:
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_0
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_1
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_2
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_3
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_4
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_3
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_2
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_1
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_0
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_1
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_2
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_3
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_4
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_3
    dc.l FLIP_H
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_2
    dc.l FLIP_H
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN1_1
    dc.l FLIP_H

.frames_medium:
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_0
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_1
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_2
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_3
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_4
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_3
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_2
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_1
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_0
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_1
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_2
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_3
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_4
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_3
    dc.l FLIP_H
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_2
    dc.l FLIP_H
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN2_1
    dc.l FLIP_H

.frames_large:
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_0
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_1
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_2
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_3
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_4
    dc.l 0
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_3
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_2
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_1
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_0
    dc.l FLIP_V
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_1
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_2
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_3
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_4
    dc.l FLIP_HV
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_3
    dc.l FLIP_H
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_2
    dc.l FLIP_H
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN3_1
    dc.l FLIP_H

go_cof_path_yflipped equ go_word0
go_cof_path_followScroll equ go_word1
Coffee_InitEnemy_FollowPath_Relative:
    move.l #.update,go_onUpdate(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN_SMALL

    jsr UTILS_GetRandWordFast
    move d0,go_frame(a0)

    rts
    
.update:
    bsr CoffeeBean_Animate

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
    
    tst go_cof_path_yflipped(a0)
    bne .yflipped
    move (a2)+,d0
    add go_starty(a0),d0
    move d0,go_y(a0)
    bra .skipyflipped    
.yflipped
    move go_starty(a0),d0
    sub (a2)+,d0
    move d0,go_y(a0)
.skipyflipped

    tst go_cof_path_followScroll(a0)
    beq .noFollowScroll
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_startx(a0)
.noFollowScroll

    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject


CoffeeBean_Animate:
    add #1,go_frame(a0)
    move go_frame(a0),d0
    lsr #2,d0
    and #15,d0
    add d0,d0
    add d0,d0
    add d0,d0
    move.l go_long2(a0),a3
    add d0,a3
    move.l (a3)+,go_cached_frame_addr(a0)
    move.l (a3),d0
    move d0,go_sprAttributes(a0)
    rts
    

Coffee_InitEnemy_FollowPath_Absolute:
    move.l #.update,go_onUpdate(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN_LARGE
    
    jsr UTILS_GetRandWordFast
    move d0,go_frame(a0)

    rts
    
.update:
    bsr CoffeeBean_Animate

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
    sub g_cof+cof_scrollx,d0
    move d0,go_x(a0)
    move (a2)+,d0    
    move d0,go_y(a0)

    cmp #-32,go_x(a0)
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject
    
    
;-----------------------------------------------------------------------------------

go_cof_circler_width equ go_word0
go_cof_circler_height equ go_word1

Coffee_InitEnemy_Circler:
    move.l #.update,go_onUpdate(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    rts
    
.update:

    move go_speed(a0),d0
    add d0,go_rot(a0)
    move go_rot(a0),d0
    jsr UTILS_GetSinCosLong
    
    muls go_cof_circler_width(a0),d0
    add.l go_startx(a0),d0
    move.l d0,go_x(a0)

    muls go_cof_circler_height(a0),d1
    add.l go_starty(a0),d1
    move.l d1,go_y(a0)
    
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_startx(a0)

    move.w go_x(a0),d0
    cmp #-32,d0
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject

;-----------------------------------------------------------------------------------
; , go_speed, go_rot, go_cof_updown_height
go_cof_updown_height equ go_word0
Coffee_InitEnemy_UpDown:
    move.l #.update,go_onUpdate(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL0_BEAN_MEDIUM
    jsr UTILS_GetRandWordFast
    move d0,go_frame(a0)

    rts
    
.update:
    bsr CoffeeBean_Animate
    move go_speed(a0),d0
    add d0,go_rot(a0)
    move go_rot(a0),d0
    
;    jsr UTILS_GetSinCosLong
    lea SinCosTable,a3
    and.l #$ff,d0
    lsl #2,d0
    move.w (a3,d0),d1    ;sin
    ext.l d1

    muls go_cof_updown_height(a0),d1
    add.l go_starty(a0),d1
    move.l d1,go_y(a0)
    
    move go_startx(a0),go_x(a0)
    move.l go_dx(a0),d0
    sub.l g_cof+cof_scrollSpeed,d0 
    add.l d0,go_startx(a0)
    
    move.w go_x(a0),d0
    cmp #-32,d0
    blt .die
    rts
.die:
    jmp GOManager_DeleteObject
    
    
Coffee_GetSolidColGO:
    move go_x(a0),d0
    move go_y(a0),d1

; d0 xpos pixels
; d1 ypos pixels
Coffee_GetSolidCol:
    move.l sysg_levelInfo+levelinfo_collisionMap,a2
    lea 4(a2),a2

    add g_cof+cof_scrollx,d0
    lsr #3,d0
    add d0,a2
    
    ; shr 3, shl 9 = shl 6, and $fff8
    and #$fff8,d1
    lsl #6,d1
    ;lsr #3,d1
    ;lsl #8,d1       ;256 wide
    ;lsl #1,d1       ; 512 wide
    
    move.b (a2,d1),d0
    rts
.empty:
    moveq #0,d0
    rts

COF_SOLIDCOL_GO macro    
    move go_x(a0),d0
    move go_y(a0),d1
    move.l sysg_levelInfo+levelinfo_collisionMap,a2
    lea 4(a2),a2

    add g_cof+cof_scrollx,d0
    lsr #3,d0
    add d0,a2
    
    ; shr 3, shl 9 = shl 6, and $fff8
    and #$fff8,d1
    lsl #6,d1
    move.b (a2,d1),d0
    endm


Coffee_InitExplosion:
    move.w go_x(a1),go_x(a0)
    move.w go_y(a1),go_y(a0)
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL1_EXPLOSION
    move #20,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move g_timer1_and1,d0
    beq .noflash
    GO_EXCHANGE_VISIBLE
.noflash:
    move.l g_cof+cof_scrollSpeed,d0 
    sub.l d0,go_x(a0)

    sub #1,go_timer(a0)
    ble .die
    rts
.die: jmp GOManager_DeleteObject
    
    
COF_PLAYER_ACCY equ $8000
COF_PLAYER_MAXDY equ $20000
Coffee_Player_UpdateMove:
    move g_pad0,d0

    move d0,d1
    and #padmask_button_left|padmask_button_right,d1
    beq .no_leftright

    btst #pad_button_left,d0
    beq .noL
    add.l #-COF_PLAYER_ACCY,go_dx(a0)
    cmp.l #-COF_PLAYER_MAXDY,go_dx(a0)
    bgt .noL
    move.l #-COF_PLAYER_MAXDY,go_dx(a0)
.noL:
    btst #pad_button_right,d0
    beq .noR
    add.l #COF_PLAYER_ACCY,go_dx(a0)
    cmp.l #COF_PLAYER_MAXDY,go_dx(a0)
    blt .noR
    move.l #COF_PLAYER_MAXDY,go_dx(a0)
.noR:
    bra .try_ud

.no_leftright:
    move.l go_dx(a0),d0
    bgt .decelx_positive

.decelx_negative:
    add.l #COF_PLAYER_ACCY,d0
    blt .decelx_ok
    move.l #0,d0
    bra .decelx_ok
    
.decelx_positive:
    sub.l #COF_PLAYER_ACCY,d0
    bgt .decelx_ok
    move.l #0,d0
    bra .decelx_ok

.decelx_ok:
    move.l d0,go_dx(a0)

.try_ud
    move g_pad0,d0

    move d0,d1
    and #padmask_button_up|padmask_button_down,d1
    beq .no_updown
    
.do_updown:
    btst #pad_button_up,d0
    beq .noU
    add.l #-COF_PLAYER_ACCY,go_dy(a0)
    cmp.l #-COF_PLAYER_MAXDY,go_dy(a0)
    bgt .noU
    move.l #-COF_PLAYER_MAXDY,go_dy(a0)
.noU:
    btst #pad_button_down,d0
    beq .noD
    add.l #COF_PLAYER_ACCY,go_dy(a0)
    cmp.l #COF_PLAYER_MAXDY,go_dy(a0)
    blt .noD
    move.l #COF_PLAYER_MAXDY,go_dy(a0)
.noD:
    rts

.no_updown:
    move.l go_dy(a0),d0
    bgt .decely_positive

.decely_negative:
    add.l #COF_PLAYER_ACCY,d0
    blt .decely_ok
    move.l #0,d0
    bra .decely_ok
    
.decely_positive:
    sub.l #COF_PLAYER_ACCY,d0
    bgt .decely_ok
    move.l #0,d0
    bra .decely_ok

.decely_ok:
    move.l d0,go_dy(a0)
    rts
    
Coffee_Player_DoDamage:
    tst g_cof+cof_playerInvulnerableTimer
    bgt .nodie

    lea Coffee_InitExplosion,a1
    jsr CoffeeSpawnGO_FX

    move #120,g_cof+cof_playerInvulnerableTimer
    sub #1,g_cof+cof_playerHealth
    bgt .nodie
    
    move.l #InitState_GameOver,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut
    move.l #0,go_onCollided(a0)
.nodie:

    rts

    
Coffee_InitPlayer:
    move.l a0,g_player
;    SETSPR SPRITE_COFFEE_PAL1
    SPRCACHE_SetFrame CACHEDSPR_SPRITE_COFFEE_PAL1_PLAYERSHIP
 ;   move #0,go_frame(a0)
    move #4*16,go_x(a0)
    move #8*16,go_y(a0)

    move.l go_x(a0),go_tox(a0)
    move.l go_y(a0),go_toy(a0)

    move #0,go_shootTimer(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    rts
    
.collided:
    cmp.b #COLTYPE_PICKUP,go_coltype(a1)
    bne .collided_bullet_or_enemy
    jsr GOManager_DeleteObjectA1
    bsr Coffee_PickedUpGrounds
    rts
.collided_bullet_or_enemy:
    bsr Coffee_Player_DoDamage
    rts
    
    
.update:
    sub #1,g_cof+cof_playerInvulnerableTimer
    bge .noinvun1
    move #0,g_cof+cof_playerInvulnerableTimer
.noinvun1:

    GO_SET_VISIBLE
    tst g_cof+cof_playerInvulnerableTimer
    beq .noinvun2
    move g_timer1,d0
    lsr #2,d0
    and #1,d0
    beq .noinvun2
    GO_SET_INVISIBLE
.noinvun2:

    sub.b #1,go_shootTimer(a0)
    bgt .noA
    move.b #0,go_shootTimer(a0)
    move g_pad0,d0
    btst #pad_button_a,d0
    beq .noA
    bsr Coffee_GeneratePlayerBullet
.noA:

    bsr Coffee_Player_UpdateMove

    
    move.l go_x(a0),d3
    move.l go_dx(a0),d2
    add.l d2,go_x(a0)
    COF_SOLIDCOL_GO
    beq .colok1
    move.l d3,go_x(a0)
    move.l g_cof+cof_scrollSpeed,d3
    sub.l d3,go_x(a0)
.colok1:
    

    move.l go_y(a0),d3
    move.l go_dy(a0),d2
    add.l d2,go_y(a0)
    COF_SOLIDCOL_GO
    beq .colok2
    move.l d3,go_y(a0)
.colok2:

    
    cmp #8,go_x(a0)
    bgt .edge1
    
    COF_SOLIDCOL_GO
    beq .nosquish
    bsr Coffee_Player_DoDamage

.nosquish:    
    move #8,go_x(a0)
.edge1:
    cmp #320-8,go_x(a0)
    blt .edge2
    move #320-8,go_x(a0)
.edge2:

    cmp #8,go_y(a0)
    bgt .edge3
    move #8,go_y(a0)
.edge3:
    cmp #224-8,go_y(a0)
    blt .edge4
    move #224-8,go_y(a0)
.edge4:
    
    
    rts
    
    
Coffee_PickedUpGrounds:
    PSG_PLAY_SFX PSGSFX_gunslugs_pickup_coin
    add #1,g_cof+cof_pickupLevel
    cmp #COF_GROUND_PER_PICKUPLEVEL,g_cof+cof_pickupLevel
    blt .no
    add #1,g_cof+cof_weaponLevel
    move #0,g_cof+cof_pickupLevel
.no:
    rts
    
Coffee_GeneratePlayerBullet:
    PSG_PLAY_SFX PSGSFX_gunslugs_shoot_electro 

    move g_cof+cof_weaponLevel,d0
    cmp #COF_MAX_SHOTTYPES-1,d0
    blt .nomax
    move #COF_MAX_SHOTTYPES-1,d0
.nomax
    lsl #2,d0
    move.l .shots(pc,d0),a5
    move.b #COF_PLAYER_SHOT_TIMER,go_shootTimer(a0)
.shotlp:
    move.l (a5)+,d6
    
    bmi .shotsdone
    
    lea Coffee_InitPlayerBullet_Single,a1
    jsr CoffeeSpawnGO_PlayerBullet
    beq .shotsdone
    move.l (a5)+,go_dx(a1)
    move.l (a5)+,go_dy(a1)
    add d6,d6
    move.w .healthFromFrame(pc,d6),go_health(a1)
    add d6,d6
    move.l .cachedSprites(pc,d6),go_cached_frame_addr(a1)
    bra .shotlp
.shotsdone:
    rts
.healthFromFrame:
    dc.w 1,2,3
    
.cachedSprites:
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL1_PLAYERBULLET1
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL1_PLAYERBULLET2
    SPRCACHE_Declare CACHEDSPR_SPRITE_COFFEE_PAL1_PLAYERBULLET3

COF_SHOTANGLE_0 equ 0
COF_SHOTANGLE_1 equ $20000
COF_SHOTANGLE_2 equ $20000
COF_SHOTSPEED_0 equ $80000 
COF_SHOTSPEED_1 equ $60000 

COF_MAX_SHOTTYPES equ 12
.shots:
    dc.l .shot0,.shot1,.shot2
    dc.l .shot3,.shot4,.shot5
    dc.l .shot6,.shot7,.shot8
    dc.l .shot9,.shot10,.shot11

.shot0: dc.l 0,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l -1
.shot1: dc.l 1,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l -1
.shot2: dc.l 2,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l -1

.shot3: dc.l 0,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 0,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 0,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1
.shot4: dc.l 1,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 0,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 0,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1
.shot5: dc.l 2,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 0,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 0,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1

.shot6: dc.l 0,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 1,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 1,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1
.shot7: dc.l 1,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 1,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 1,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1
.shot8: dc.l 2,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 1,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 1,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1

.shot9: dc.l 0,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 2,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 2,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1
.shot10: dc.l 1,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 2,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 2,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1
.shot11: dc.l 2,COF_SHOTSPEED_0,COF_SHOTANGLE_0
        dc.l 2,COF_SHOTSPEED_1,-COF_SHOTANGLE_1
        dc.l 2,COF_SHOTSPEED_1,COF_SHOTANGLE_1
        dc.l -1


Coffee_InitPlayerBullet_Single:
        
Coffee_InitPlayerBullet_All:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    add #16,go_x(a0)    ;spout
    sub #4,go_y(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    rts    
    
    
.collided:
    lea Coffee_InitExplosion,a1
    jsr CoffeeSpawnGO_FX
    jmp GOManager_DeleteObject
            
.update:
    lea go_dx(a0),a1
    move.l (a1)+,d0     ;dx
    add.l d0,(a1)+      ;x
    move.l (a1)+,d0     ;dy
    add.l d0,(a1)+      ;y
    
    COF_SOLIDCOL_GO
    bne .die

    cmp #320+32,go_x(a0)
    bge .die1    
    rts
.die:
    lea Coffee_InitExplosion,a1
    jsr CoffeeSpawnGO_FX
.die1:
    jmp GOManager_DeleteObject

Coffee_InitBomb:
    move.l go_x(a1),go_x(a0)    
    move.l go_y(a1),go_y(a0)    
    SETSPR SPRITE_COFFEE_PAL1
    move #SPRFRAME_COFFEE_PAL1_PLAYERBULLET1,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #0,go_dy(a0)
    rts
.update:
    sub.l #$8000,go_x(a0)
    add.l #$1000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr Coffee_GetSolidColGO
    bne .die
    
    cmp #250,go_y(a0)
    bgt .die1
    rts
.die:
    lea Coffee_InitExplosion,a1
    jsr CoffeeSpawnGO_FX
.die1:
    jmp GOManager_DeleteObject

    
Coffee_EnemyCollided:
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
    


Coffee_InitWorldAndLevelStuff_GFX:
    jsr Coffee_InitVDPForLevel
    rts

    
    
Coffee_InitVDPForLevel:
    jsr ClearVRAM

	BORDER 0
    lea SPRPAL_Coffee_Pal0,a0
    move #0,d0
    jsr FADE_CopySinglePaletteToSource

    lea SPRPAL_Coffee_Pal1,a0
    move #1,d0
    jsr FADE_CopySinglePaletteToSource

	move #0,g_vram_currentpos
    jsr Image_AddBlankCharacterToVDP



    bsr .dobackgrounds

    move.w g_vram_currentpos,g_cof+cof_spriteScaleVDPOffset

    lea .sprites,a5
.spritesLoop:
    move (a5)+,d0
    bmi .finishedSprites
    jsr UNITYTOOL_LoadSingleSprite
    bra .spritesLoop
.finishedSprites:

	move.l #SPRITE_DEBUG,d0
	jsr UNITYTOOL_LoadSingleSprite

    lea .cachesprites,a0
    jsr SpriteCache_BuildFrameList
	
    rts

.dobackgrounds:
    move.l sysg_levelInfo+levelinfo_tileData0,a4	;tile start     
    move.w imagecells_numcells(a4),d6
    move g_vram_currentpos,d0
    move.w d0,g_vram_fg
    add d6,g_vram_currentpos
    move.w	g_vram_fg,d1
    lsl #5,d1
    jsr	VDP_BuildVRAMWriteAddress
    move.l a4,a0
    jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags

    move.l sysg_levelInfo+levelinfo_palette1,a0 
    move 2(a0),d0
    lea 4(a0),a0
    jsr FADE_CopySinglePaletteToSource
    
    move #IMAGEASSET_COFFEE_BG0,d0
    jsr IMAGE_ShowStaticImagePlaneB


    rts

    
.sprites:
    dc.w SPRITE_COFFEE_PAL0_SOFTWARESPRITE
    dc.w SPRITE_COFFEE_PAL0
    dc.w SPRITE_COFFEE_PAL0_BEAN1
    dc.w SPRITE_COFFEE_PAL0_BEAN2
    dc.w SPRITE_COFFEE_PAL0_BEAN3
    dc.w SPRITE_COFFEE_PAL1
    dc.w SPRITE_COFFEE_PAL0_HUD
    dc.w -1

.cachesprites:
    dc.w SPRITE_COFFEE_PAL0
    dc.w SPRITE_COFFEE_PAL0_BEAN1
    dc.w SPRITE_COFFEE_PAL0_BEAN2
    dc.w SPRITE_COFFEE_PAL0_BEAN3
    dc.w SPRITE_COFFEE_PAL1
    dc.w -1



Coffee_UpdateGame:

    jsr UTILS_GetRandWord
    bsr Coffee_UpdateGame_UpdateGlobals
    
    ifnd IS_FINAL_GAME
    move g_pad0,d0
    btst #pad_button_c,d0
    beq .normal
    bsr Coffee_UpdateGame_Normal  
    bsr Coffee_UpdateGame_Normal  
    bsr Coffee_UpdateGame_Normal        
    bsr Coffee_UpdateGame_Normal        
    bsr Coffee_UpdateGame_Normal        
    bsr Coffee_UpdateGame_Normal        
    bsr Coffee_UpdateGame_Normal        
.normal:
    endif
    bsr Coffee_UpdateGame_Normal  
    
    
    bsr Coffee_UpdateBG_HScroll
    jsr Game_UpdateRealtimeCommands      

    
    tst.b g_cof+cof_resetLevelFlag
    beq .no
    bsr Coffee_ResetForRealtimeCommand
.no:
    rts
    
Coffee_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
Coffee_UpdateGame_UpdateGlobals:

    add #1,g_cof+cof_enemyBulletTimer


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



Coffee_UpdateGame_Normal:
    ;bsr Racing_UpdateScreenShake
    move.l g_cof+cof_scrollx,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy
    
    tst.b g_cof+cof_pauseScrollFlag
    bne .noscroll
    add.l #COFFEE_SCROLLSPEED,g_cof+cof_scrollx
.noscroll:

    tst.b g_cof+cof_pauseScrollFlag
    bne .noscroll1
    bsr Coffee_UpdateSpawnSingleCallStuff
    bsr Coffee_UpdateMultiGen
.noscroll1:
    HVTIMER_START0 'goma'
    jsr GOManager_Update
    HVTIMER_END0
    ;BORDER 9
    ;bsr Coffee_BulletEnemyCollision_MakeBulletBuckets
    ;bsr Coffee_BulletEnemyCollisionBucketed
    bsr Coffee_BulletEnemyCollision
    bsr Coffee_PlayerEnemyCollision
    bsr Coffee_PlayerEnemyBulletCollision
    HVTIMER_START1 'sprt'
	jsr SPRITE_UpdateFromGOManager_Racing
	HVTIMER_END1
	move.l g_cof+cof_scrollx,g_scroll_x
    jsr Coffee_SCROLL_UpdateColumnsA

    HVTIMER_START2 'scal'
    bsr SpriteScaler_Update
	HVTIMER_END2


    move.l #0,g_scroll_x
    
    ;jsr HVCounter_CopyToDebug

    rts


Coffee_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
	
    jsr Scroll_DumpColumnToVDPA

    bsr SpriteScaler_DMA

    bsr Coffee_UpdateScrollRegisters
    jsr ColorBars_HBL_InitForFrame
	rts

;-------------------------------------------------------------


Coffee_UpdateScrollRegisters:

	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_CELL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL


	move g_cof+cof_scrollx,d0
	add g_screenshake_x,d0
	neg d0

	move g_cof+cof_scrollx,d1
	lsr #1,d1
	neg d1

    lea g_cof+cof_hscrolltabA,a1

    AUTOINC 32
	SCROLL_START_WRITE_XPOS
	rept 28
	move d0,VDP_DATA
	endr
	SCROLL_START_WRITE_XPOS2
	rept 28
	move (a1)+,VDP_DATA
	endr


	;SCROLL_START_WRITE_XPOS
	;move d0,VDP_DATA
	;move d1,VDP_DATA
	
	
    AUTOINC 2
    move g_scroll_y,d0
    add g_screenshake_y,d0
    and #255,d0
    move #0,d0
    move #0,d1
    
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d1,VDP_DATA
	rts

    

Coffee_BulletEnemyCollision_MakeEnemyBuckets:

; init pointers:
    move.l g_cof+cof_m_collision_EnemyBuckets,a0
    lea g_cof+cof_collEnemyBucketPointers,a1
    move #COFFEE_NUM_COLLISION_BUCKETS-1,d7
.initlp:
    move.l a0,(a1)+
    move.l #-1,(a0)
    lea COFFEE_MAX_PER_BUCKET*4(a0),a0
    dbra d7,.initlp

    jsr GOManager_GetList_Treasure        ; enemies outer loop
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .nobullets
    move.l golist_active_list_addr(a5),a5
    subq #1,d7
    
    lea g_cof+cof_collEnemyBucketPointers,a4
    
    moveq #4,d1
    moveq #0,d2
    moveq #4,d3
.loop1:
    move.l (a5)+,a0             ;enemy
    
    ;cmp.b #COLTYPE_PICKUP,go_coltype(a0)
    ;beq .skip_enemy
        
    move.l go_colliderAddr(a0),a2
    move go_x(a0),d5
    move d5,d6
    add (a2)+,d5        ;collider_offset_x0(a2),d5	; enemy left
    add (a2)+,d6        ;collider_offset_x1(a2),d6	; enemy right
        
    ;move go_colbox_x0(a0),d5    
    ;move go_colbox_y0(a0),d6
        
    

    lsr #COFFEE_BUCKET_LSR,d5       ; bucket size = 64
    bge .okclip1
    move d2,d5          ; d2 = 0
    bra .okclip2
.okclip1:
    cmp d3,d5           ;d3 = 4
    ble .okclip2
    move d3,d5
.okclip2:

    ;lsr #COFFEE_BUCKET_LSR,d6       ; bucket size = 64
    ;bge .okclip1a
    ;move #0,d6
.okclip1a:
    ;cmp #4,d6
    ;ble .okclip2a
    ;move #4,d6
.okclip2a:

    lsl #2,d5
    move.l (a4,d5),a2
    move.l a0,(a2)
    add.l d1,(a1,d5)

.skip_enemy:
    dbra d7,.loop1

; shove -1s on the ends
    lea g_cof+cof_collEnemyBucketPointers,a4
    moveq #-1,d0
    rept 5
    move.l (a4)+,a2
    move.l d0,(a2)
    endr
 
.nobullets:


    rts

Coffee_BulletEnemyCollision_MakeBulletBuckets:
; init pointers:
    move.l g_cof+cof_m_collision_BulletBuckets,a0
    lea g_cof+cof_collBulletBucketPointers,a1
    move #COFFEE_NUM_COLLISION_BUCKETS-1,d7
.initlp:
    move.l a0,(a1)+
    move.l #-1,(a0)
    lea COFFEE_MAX_PER_BUCKET*4(a0),a0
    dbra d7,.initlp
    
    jsr GOManager_GetList_PlayerBullets       ; player bullets
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .nobullets
    move.l golist_active_list_addr(a5),a5
    subq #1,d7
    
    lea g_cof+cof_collBulletBucketPointers,a4
    
    moveq #4,d1
    moveq #0,d2
    moveq #4,d3
.loop1:
    move.l (a5)+,a0             ;bullet

    move go_x(a0),d5

    lsr #COFFEE_BUCKET_LSR,d5       ; bucket size = 64
    bge .okclip1
    move d2,d5          ; d2 = 0
    bra .okclip2
.okclip1:
    cmp d3,d5           ;d3 = 4
    ble .okclip2
    move d3,d5
.okclip2:
    lsl #2,d5
    move.l (a4,d5),a2
    move.l a0,(a2)
    move.l #-1,4(a2)
    add.l d1,(a1,d5)

    dbra d7,.loop1

.nobullets:
    rts



; enemy outer loop.
;bucketed bullet inner loop 
Coffee_BulletEnemyCollisionBucketed:
    jsr GOManager_GetList_Treasure        ; enemies outer loop
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .nobullets
    move.l golist_active_list_addr(a5),a5
    subq #1,d7

.enemyLoop:
    move.l (a5)+,a0             ;enemy
    
    cmp.b #COLTYPE_PICKUP,go_coltype(a0)
    beq .skip_enemy
        
    move.l go_colliderAddr(a0),a2
        
    move go_x(a0),d5
    move d5,d6
    add (a2)+,d5        ;collider_offset_x0(a2),d5	; enemy left
    add (a2)+,d6        ;collider_offset_x1(a2),d6	; enemy right

    move go_y(a0),d3
    move d3,d4
    add (a2)+,d3        ;collider_offset_y0(a2),d3	; enemy t
    add (a2)+,d4        ;collider_offset_y1(a2),d4	; enemy b
    
    move d5,d0
    lsr #COFFEE_BUCKET_LSR,d0       ; bucket size = 64
    bge .okclip1
    move #0,d0
.okclip1:
    cmp #4,d0
    ble .okclip2
    move #4,d0
.okclip2:
    bsr .dobulletbucket
    bra .skip_enemy


.dobulletbucket:
    move.l g_cof+cof_m_collision_BulletBuckets,a4
    lsl #5+2,d0
    add d0,a4
    
    
.bulletBucketLoop:
    move.l (a4)+,a1
    cmp.l #-1,a1
    beq .donebullets
   
    move go_x(a1),d0
    cmp d5,d0
    blt .skip
    cmp d6,d0
    bgt .skip
    
    move go_y(a1),d0
    cmp d3,d0
    blt .skip
    cmp d4,d0
    bgt .skip


    movem.l d2-d5/a0/a1/a4/a5,-(sp)
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    movem.l (sp)+,d2-d5/a0/a1/a4/a5


    movem.l d2-d5/a0/a1/a4/a5,-(sp)
    exg.l a0,a1
    move.l go_onCollided(a0),d0
    beq .nocolfunc2
    move.l d0,a5
    jsr (a5)
.nocolfunc2:
    movem.l (sp)+,d2-d5/a0/a1/a4/a5


.skip:
    bra .bulletBucketLoop

.donebullets:
    rts

.skip_enemy:
    dbra d7,.enemyLoop
    
.nobullets:
    rts
    
Coffee_BulletEnemyCollision:
    jsr GOManager_GetList_Treasure        ; enemies outer loop
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .nobullets
    move.l golist_active_list_addr(a5),a5
    subq #1,d7

    jsr GOManager_GetList_PlayerBullets     ; bullets inner loop
    move.l a3,a4
    move golist_num_active(a4),d6
    beq .nobullets
    move.l golist_active_list_addr(a4),a4
    subq #1,d6

    move d6,g_cof+cof_word0
    move.l a4,g_cof+cof_long0

.loop1:
    move.l (a5)+,a0             ;enemy
    
   ; cmp.b #COLTYPE_PICKUP,go_coltype(a0)
   ; beq .skip_enemy
        
    move.l go_colliderAddr(a0),a2
        
    move go_x(a0),d5
    move d5,d6
    add (a2)+,d5        ;collider_offset_x0(a2),d5	; enemy left
    add (a2)+,d6        ;collider_offset_x1(a2),d6	; enemy right

    move go_y(a0),d3
    move d3,d4
    add (a2)+,d3        ;collider_offset_y0(a2),d3	; enemy t
    add (a2)+,d4        ;collider_offset_y1(a2),d4	; enemy b
    
    move g_cof+cof_word0,g_cof+cof_loopCounter
    move.l g_cof+cof_long0,a4
    
.loop2:
    move.l (a4)+,a1
    ;tst.b go_activestate(a1)       ; not sure if this is better or not
    ;beq .skip
   
    move go_x(a1),d0
    cmp d5,d0
    blt .skip
    cmp d6,d0
    bgt .skip
    
    move go_y(a1),d0
    cmp d3,d0
    blt .skip
    cmp d4,d0
    bgt .skip

    movem.l d2-d5/a0/a1/a4/a5,-(sp)
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    movem.l (sp)+,d2-d5/a0/a1/a4/a5


    movem.l d2-d5/a0/a1/a4/a5,-(sp)
    exg.l a0,a1
    move.l go_onCollided(a0),d0
    beq .nocolfunc2
    move.l d0,a5
    jsr (a5)
.nocolfunc2:
    movem.l (sp)+,d2-d5/a0/a1/a4/a5


.skip:
    sub #1,g_cof+cof_loopCounter
    bge .loop2

.skip_enemy:
    dbra d7,.loop1
    
.nobullets:
    rts


Coffee_PlayerEnemyBulletCollision:
    tst.b sysg_cheatmode
    bne .noenemies

    jsr GOManager_GetList_EnemyBullet
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .noenemies
    move.l golist_active_list_addr(a5),a5
    subq #1,d7

    
    move.l g_player,a0
    move go_x(a0),d5
    move go_y(a0),d6
    
.loop:
    move.l (a5)+,a1
    
    move.l go_colliderAddr(a1),a2
    cmp.l #0,a2
    beq .skip
    
    move go_x(a1),d0
    move d0,d1
	add collider_offset_x0(a2),d0	; enemy left
	cmp d0,d5
	blt .skip
	
	add collider_offset_x1(a2),d1	; enemy right
	cmp d1,d5
	bgt .skip
	
    move go_y(a1),d0
    move d0,d1
	add collider_offset_y0(a2),d0	; enemy top
	cmp d0,d6
	blt .skip
	
	add collider_offset_y1(a2),d1	; enemy bottom
	cmp d1,d6
	bgt .skip

; only do player callback
    PUSHALL
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    POPALL


.skip:
    dbra d7,.loop
    
.noenemies:
    rts

Coffee_PlayerEnemyCollision:
    tst.b sysg_cheatmode
    bne .noenemies

    jsr GOManager_GetList_Treasure        ; enemies
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .noenemies
    move.l golist_active_list_addr(a5),a5
    subq #1,d7

    
    move.l g_player,a0
    move go_x(a0),d5
    move go_y(a0),d6
    
.loop:
    move.l (a5)+,a1
    
    move.l go_colliderAddr(a1),a2
    cmp.l #0,a2
    beq .skip
    
    move go_x(a1),d0
    move d0,d1
	add collider_offset_x0(a2),d0	; enemy left
	cmp d0,d5
	blt .skip
	
	add collider_offset_x1(a2),d1	; enemy right
	cmp d1,d5
	bgt .skip
	
    move go_y(a1),d0
    move d0,d1
	add collider_offset_y0(a2),d0	; enemy top
	cmp d0,d6
	blt .skip
	
	add collider_offset_y1(a2),d1	; enemy bottom
	cmp d1,d6
	bgt .skip

; only do player callback
    PUSHALL
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    POPALL


.skip:
    dbra d7,.loop
    
.noenemies:
    rts


;---------------------------------------------------------------------------------------

Coffee_FindSingleCallSpawnEntryFromSpawner:
    lea Coffee_SpawnTabSingleCall,a4
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

Coffee_CreateSortedSpawnList:
    move #0,g_cof+cof_sortedSpawnListCurrentIndex
    lea g_cof+cof_sortedSpawnList,a1
    move.l sysg_levelInfo+levelinfo_spawners,a0
    move (a0)+,d7
    move d7,d1
    subq #1,d1
    moveq #0,d2
.clrlp:
    move spawner_x(a0),0(a1)
    move d2,2(a1)
    addq #1,d2
    lea 4(a1),a1
    lea spawner_structsize(a0),a0
    dbra d1,.clrlp
    move.l #-1,(a1)

    
    lea g_cof+cof_sortedSpawnList,a0
    move #0,d0
.lp0:
    lea g_cof+cof_sortedSpawnList,a1
    move #0,d1
.lp1:
    move (a0),d2
    move (a1),d3
    cmp d3,d2
    bge .noswap
    
    move.l (a0),d3
    move.l (a1),d4
    move.l d4,(a0)
    move.l d3,(a1)
    
.noswap:
    lea 4(a1),a1
    addq #1,d1
    cmp d7,d1
    blt .lp1
    
    lea 4(a0),a0
    addq #1,d0
    cmp d7,d0
    blt .lp0
    
    rts
    

    
; using pre sorted index list
Coffee_UpdateSpawnSingleCallStuff:
    
    
.next:    
    lea g_cof+cof_sortedSpawnList,a1
    move g_cof+cof_sortedSpawnListCurrentIndex,d0
    lsl #2,d0
    add d0,a1

    
    move.l g_cof+cof_scrollx,d6
    add.l #(320+32)<<16,d6
    
    moveq #0,d1
    move 0(a1),d1
    bmi .exit
    swap d1
    cmp.l d6,d1
    
    bgt .exit
    
    ; found it. so point to original data
    
    move.l sysg_levelInfo+levelinfo_spawners,a5
    move.l sysg_levelInfo+levelinfo_spawnerData,a3
    lea 2(a5),a5
    lea 2(a3),a3
    
    move 2(a1),d0       ; index
    
    move d0,d1
    mulu #spawner_structsize,d0
    add d0,a5
    lsl #2,d1
    add d1,a3

    add #1,g_cof+cof_sortedSpawnListCurrentIndex

    bsr Coffee_FindSingleCallSpawnEntryFromSpawner
    cmp.l #0,a4
    beq .next

    move.l a5,g_currentSpawnListAddr 
    move.l a3,g_currentSpawnDataAddr 

    PUSHALL
    
    bsr Coffee_AddMultiGen              ;
    cmp.l #0,a0 
    beq .nomultigen_available
    move.l g_currentSpawnDataAddr,mg_spawnerDataAddr(a0)
    move.l g_currentSpawnListAddr,mg_spawnerListAddr(a0)
    move.l cspawntab_initFunc(a4),a3
    jsr (a3)

.nomultigen_available:
    POPALL
    
    bra .next

.exit:
    rts
;---------------------------------------
Coffee_UpdateSpawnSingleCallStuff1:
    move.l sysg_levelInfo+levelinfo_spawners,a5
    move.l sysg_levelInfo+levelinfo_spawnerData,a3
    ;moveq #0,d6     ; spawn index
    lea 2(a3),a3
    move (a5)+,d7
    beq .exit
    subq #1,d7
    move.l g_cof+cof_scrollx,d6
    add.l #(320+32)<<16,d6
.lp:
    moveq #0,d1
    move spawner_x(a5),d1
    swap d1
    cmp.l d6,d1
    bne .skip_entry

    bra .skip_entry
    bsr Coffee_FindSingleCallSpawnEntryFromSpawner
    cmp.l #0,a4
    beq .skip_entry

    move.l a5,g_currentSpawnListAddr 
    move.l a3,g_currentSpawnDataAddr 

    PUSHALL
    
    bsr Coffee_AddMultiGen              ;
    cmp.l #0,a0 
    beq .nomultigen_available
    move.l g_currentSpawnDataAddr,mg_spawnerDataAddr(a0)
    move.l g_currentSpawnListAddr,mg_spawnerListAddr(a0)
    move.l cspawntab_initFunc(a4),a3
    jsr (a3)

.nomultigen_available
    POPALL
    ; so, don't actually spawn a gameobject, but call some code instead

.skip_entry:
    lea spawner_structsize(a5),a5
    ;addq #1,d6
    lea 4(a3),a3
    dbra d7,.lp    
.exit:
    rts
    
;---------------------------------------

Coffee_InitMultiGen_Circler:
    move.l mg_spawnerDataAddr(a0),a3
    move.l (a3),a3
    move PARAM_COFFEE_CIRCLER_AMOUNT(a3),mg_count(a0)
    ;move PARAM_COFFEE_CIRCLER_SPACING(a3),mg_timerMax(a0)
    move #0,mg_timerMax(a0)
    move PARAM_COFFEE_CIRCLER_WIDTH(a3),mg_data0(a0)
    move PARAM_COFFEE_CIRCLER_HEIGHT(a3),mg_data1(a0)
    move PARAM_COFFEE_CIRCLER_SPEED(a3),mg_data2(a0)
    move PARAM_COFFEE_CIRCLER_ROTOFFSET(a3),mg_data3(a0) ; rot offset
    move #0,mg_data4(a0) ; x offset. ; generates them all at the same place, but one per frame 
    move #0,mg_data5(a0) ; current rot 
    move.l #.generate,mg_generateFunc(a0)
    

    rts

.generate:
    lea Coffee_InitEnemy_Circler,a1
    bsr CoffeeSpawnGO_Enemy
    
    move.l mg_spawnerListAddr(a0),a5
    move #320+16,d0
    sub mg_data4(a0),d0
    move d0,go_startx(a1)
    
    move spawner_y(a5),go_starty(a1)
    
    move mg_data0(a0),go_cof_circler_width(a1)    
    move mg_data1(a0),go_cof_circler_height(a1)    
    move mg_data2(a0),go_speed(a1)    
    move mg_data5(a0),go_rot(a1)    
    
    move mg_data3(a0),d0
    add d0,mg_data5(a0)
    add #1,mg_data4(a0)
    
    move #1,d0
    bsr Coffee_SetEnemySprFromIndex

    rts


;---------------------------------------

Coffee_InitMultiGen_UpDown:
    move.l mg_spawnerDataAddr(a0),a3
    move.l (a3),a3
    move PARAM_COFFEE_UPDOWN_AMOUNT(a3),mg_count(a0)
    move PARAM_COFFEE_UPDOWN_SPACING(a3),mg_timerMax(a0)
    move PARAM_COFFEE_UPDOWN_ENEMYTYPE(a3),mg_data1(a0)
    move.l #.generate,mg_generateFunc(a0)
    move #0,mg_data0(a0)
    rts
.generate:
    lea Coffee_InitEnemy_UpDown,a1
    bsr CoffeeSpawnGO_Enemy
    
    move.l mg_spawnerListAddr(a0),a5
    move #320+16,go_startx(a1)
    move spawner_y(a5),go_starty(a1)
    
;go_speed, go_rot, go_cof_updown_height

    move mg_data0(a0),go_rot(a1)
    move.l mg_spawnerDataAddr(a0),a3
    move.l (a3),a3
    move PARAM_COFFEE_UPDOWN_STARTROT(a3),go_rot(a1)
    move PARAM_COFFEE_UPDOWN_ADD_ROT(a3),d0
    add d0,mg_data0(a0)
    move PARAM_COFFEE_UPDOWN_ROTSPEED(a3),go_speed(a1)
    move PARAM_COFFEE_UPDOWN_SCALE(a3),go_cof_updown_height(a1)
    move PARAM_COFFEE_UPDOWN_VELX(a3),go_dx(a1)
    
    move mg_data1(a0),d0
    bsr Coffee_SetEnemySprFromIndex

    rts

    
Coffee_InitMultiGen_Path:
    move.l mg_spawnerDataAddr(a0),a3
    move.l (a3),a3
    move PARAM_COFFEE_PATH_AMOUNT(a3),mg_count(a0)
    move PARAM_COFFEE_PATH_SPACING(a3),mg_timerMax(a0)
    move PARAM_COFFEE_PATH_MIRRORY(a3),mg_data0(a0)
    move PARAM_COFFEE_PATH_ENEMYTYPE(a3),mg_data1(a0)
    move PARAM_COFFEE_PATH_FOLLOWSCROLL(a3),mg_data2(a0)
    
    move.l sysg_levelInfo+levelinfo_paths,a2
    move PARAM_COFFEE_PATH_PATH(a3),d0
    lsl #2,d0
    move.l (a2,d0),mg_pathDataAddr(a0)
    
    move.l #.generate,mg_generateFunc(a0)
    rts
.generate:

    move.l mg_pathDataAddr(a0),a2
    lea 2(a2),a2
    cmp.l #0,(a2)   ; first position.. is it 0,0? should export some flags instead.
    beq .relative
.absolute:
    lea Coffee_InitEnemy_FollowPath_Absolute,a1
    bra .spawn
.relative:
    lea Coffee_InitEnemy_FollowPath_Relative,a1
.spawn:
    bsr CoffeeSpawnGO_Enemy
    
    move mg_data1(a0),d0
    bsr Coffee_SetEnemySprFromIndex
   
    move.l mg_pathDataAddr(a0),a2
    move (a2)+,go_path+path_numNodes(a1)
    move.l a2,go_path+path_addr(a1)
    move.l #0,go_path+path_currentIndex(a1)

    move mg_data0(a0),go_cof_path_yflipped(a1)
    move mg_data2(a0),go_cof_path_followScroll(a1)

    move.l mg_spawnerListAddr(a0),a5
    move #320+16,go_startx(a1)
    move spawner_y(a5),go_starty(a1)
    
    move go_startx(a1),go_x(a1)
    move go_starty(a1),go_y(a1)
    rts


;-------------------------------------------------------------------------------------

Coffee_InitMultiGen_Rocket:
    move.l mg_spawnerDataAddr(a0),a3
    move.l (a3),a3
    move PARAM_COFFEE_ROCKET_AMOUNT(a3),mg_count(a0)
    move PARAM_COFFEE_ROCKET_SPACING(a3),mg_timerMax(a0)
    move.l #.generate,mg_generateFunc(a0)
    rts
.generate:
    lea Coffee_InitEnemy_Rocket,a1
    bsr CoffeeSpawnGO_Enemy

    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    rts

;-------------------------------------------------------------------------------------

Coffee_InitMultiGen_Boss1
    


    move.b #1,g_cof+cof_pauseScrollFlag
    move.l #0,g_cof+cof_scrollSpeed
    
    lea Coffee_InitEnemy_Boss1,a1
    bsr CoffeeSpawnGO_Enemy
    
    
    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    move.b #0,mg_active(a0)
    
    ; boss arm path
    move.l mg_spawnerDataAddr(a0),a3
    move.l (a3),a3
    move.l sysg_levelInfo+levelinfo_paths,a2
    move PARAM_COFFEE_BOSS1_PATH0(a3),d0
    lsl #2,d0
    move.l (a2,d0),a2
    
    move (a2)+,go_path+path_numNodes(a1)
    move.l a2,go_path+path_addr(a1)
    move.l #0,go_path+path_currentIndex(a1)

    rts

;-------------------------------------------------------------------------------------


Coffee_InitMultiGen_Scaler
    lea Coffee_InitEnemy_Scaler,a1
    bsr CoffeeSpawnGO_Enemy
    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    move.b #0,mg_active(a0)
    rts


Coffee_InitMultiGen_BigPot
    lea Coffee_InitEnemy_BigPot,a1
    bsr CoffeeSpawnGO_Enemy
    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    move.b #0,mg_active(a0)
    rts

;-------------------------------------------------------------------------------------

Coffee_InitMultiGen_Pot0:
    lea Coffee_InitEnemy_Pot0,a1
    bsr CoffeeSpawnGO_Enemy
    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    move.b #0,mg_active(a0)
    rts


;-------------------------------------------------------------------------------------
Coffee_InitMultiGen_PressYflip:
    lea Coffee_InitEnemy_PressYflip,a1
    bsr CoffeeSpawnGO_Enemy
    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    move.b #0,mg_active(a0)
    rts

;-------------------------------------------------------------------------------------
Coffee_InitMultiGen_Press:
    lea Coffee_InitEnemy_Press,a1
    bsr CoffeeSpawnGO_Enemy
    move.l mg_spawnerListAddr(a0),a5
    move.l #(320+32)<<16,go_x(a1)
    move spawner_y(a5),go_y(a1)
    move.b #0,mg_active(a0)
    rts

Coffee_InitMultiGen:
    move.l g_cof+cof_m_multigen,a0
    move #COFFEE_MULTIGEN_SIZE,d0
    jmp UTILS_ClearRam

Coffee_AddMultiGen:
    move.l g_cof+cof_m_multigen,a0
    move #COFFEE_MULTIGEN_AMT-1,d7
.lp:
    tst.b mg_active(a0)
    beq .found
    lea mg_structsize(a0),a0
    dbra d7,.lp
    move.l #0,a0
    rts
.found:
    move.b #1,mg_active(a0)
    move.b #0,mg_state(a0)
    rts

Coffee_UpdateMultiGen:
    move.l g_cof+cof_m_multigen,a0
    move #COFFEE_MULTIGEN_AMT-1,d7
.lp:
    tst.b mg_active(a0)
    beq .skip
    tst.b mg_state(a0)
    bne .dowait
    move.l mg_generateFunc(a0),a1
    jsr (a1)
    sub #1,mg_count(a0)
    ble .delete
    move mg_timerMax(a0),mg_timer(a0)
    sub #1,mg_timer(a0)
    move.b #1,mg_state(a0)
.dowait:
    sub #1,mg_timer(a0)
    bge .skip
    move.b #0,mg_state(a0)
    
.skip:
    lea mg_structsize(a0),a0
    dbra d7,.lp
    rts
.delete:
    move.b #0,mg_active(a0)
    bra .skip    

;-------------------------------------------------------------------------------------

Coffee_InitHUD:
    SETSPR SPRITE_COFFEE_PAL0_HUD
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.render,go_onRender(a0)
    rts

.update:
    ;move g_scroll_y,go_y(a0)
    rts
    
.render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    bsr .renderbossbar
    bsr .renderplayerbar
    bsr .score
    rts
   
   ifd USE_HVCOUNTER_TIMINGS
    lea HVCounterRam+(2*hvc_structsize),a1
    moveq #0,d4
    move.b hvc_timetaken(a1),d4
    move #20,d5
    move #5,d6
    bsr .renderNumber3

    lea HVCounterRam+(2*hvc_structsize),a1
    moveq #0,d4
    move.b hvc_worsttime(a1),d4
    move #20+50,d5
    move #5,d6
    bsr .renderNumber3
    rts

    lea HVCounterRam+(1*hvc_structsize),a1
    moveq #0,d4
    move.b hvc_timetaken(a1),d4
    move #120,d5
    move #5,d6
    bsr .renderNumber3 

    lea HVCounterRam+(1*hvc_structsize),a1
    moveq #0,d4
    move.b hvc_worsttime(a1),d4
    move #120+50,d5
    move #5,d6
    bsr .renderNumber3 

    endif
    rts

    jsr GOManager_GetList_Treasure        ; enemies outer loop
    move golist_num_active(a3),d4
    move #200,d5
    move #5,d6
    bsr .renderNumber3 

    jsr GOManager_GetList_PlayerBullets        ; enemies outer loop
    move golist_num_active(a3),d4
    move #230,d5
    move #5,d6
    bsr .renderNumber3 

    rts

.score:
    ;move #20,d5
    ;move #5,d6
    ;move g_cof+cof_weaponLevel,d4
    ;move g_cof+cof_playerHealth,d4
    ;bsr .renderNumber2 

    move #50,d5
    move #5,d6
    move sysg_score+2,d4
    bsr .renderNumber5

    rts


.renderbossbar:
    tst.l g_boss
    beq .noboss
    move #280,d5
    move #5,d6
    move #SPRFRAME_COFFEE_PAL0_HUD_HEART_ENEMY,d1
    bsr Coffee_Hud_DoOne

    move.l g_boss,a1
    move #(16<<8)/COF_HEALTH_BOSS1,d1
    mulu go_health(a1),d1
    lsr #8,d1
    add #SPRFRAME_COFFEE_PAL0_HUD_HEALTHBAR_ENEMY,d1
    move #280+10,d5
    move #5,d6
    bsr Coffee_Hud_DoOne
.noboss:
    rts

.renderplayerbar:
    move #10,d5
    move #5,d6
    move #SPRFRAME_COFFEE_PAL0_HUD_HEART_PLAYER,d1
    bsr Coffee_Hud_DoOne

    move #(16<<8)/COF_INITIAL_HEALTH,d1
    mulu g_cof+cof_playerHealth,d1
    lsr #8,d1
    add #SPRFRAME_COFFEE_PAL0_HUD_HEALTHBAR_PLAYER,d1
    move #10+10,d5
    move #5,d6
    bsr Coffee_Hud_DoOne
    rts

;d4
.renderNumber5:
    move d4,d0
    lea g_cof+cof_fontdrawarea,a1
    bsr Coffee_Hud_RenderNumber5
    lea g_cof+cof_fontdrawarea,a1
    bra .renderstring

.renderNumber2
    lea FONT_NumberTable_W_2,a1
    lsl #2,d4
    add d4,a1
    bra .renderstring

.renderNumber3
    lea FONT_NumberTable_Byte,a1
    lsl #2,d4
    add d4,a1
    bra .renderstring

;a1
.renderstring:
	moveq #0,d1		
	move.b	(a1)+,d1	
	beq .stringEnd		
	sub.b #'0',d1
	bsr Coffee_Hud_DoOne
	add #8,d5
	bra.s	.renderstring
.stringEnd:

    rts
    
Coffee_Hud_DoOne:
    move d1,sprbuf_frame(a5)
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move g_scroll_y,d0
    add d0,sprbuf_y(a5)
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts
    
Coffee_Hud_RenderNumber5
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



Coffee_FindAndInitPlayer:
    move.l sysg_levelInfo+levelinfo_spawners,a5
    move.l sysg_levelInfo+levelinfo_spawnerData,a3
    moveq #0,d6     ; spawn index
    lea 2(a3),a3
    move (a5)+,d7
    beq .exit
    subq #1,d7
.lp:
    cmp #SPRDEF_COFFEE_PLAYER,spawner_type(a5)
    beq .found
    lea spawner_structsize(a5),a5
    lea 4(a3),a3
    dbra d7,.lp    
.exit:
    rts
.found:
    PUSHALL
    lea Coffee_InitPlayer,a1
    bsr CoffeeSpawnGO_General
    POPALL
    
    move spawner_y(a5),go_y(a1)
    move spawner_x(a5),d0
    sub #50,d0
    bge .ok
    move #0,d0
.ok:
    swap d0
    clr.w d0
    move.l d0,g_cof+cof_scrollx
    rts
    
    
    
Coffee_SCROLL_UpdateColumnsA:
    move g_scroll_x,d5
    lsr #3,d5
    add #40,d5
    move d5,g_scroll_columnA

    move.l sysg_levelInfo+levelinfo_tileMap0,a0
    lea 6(a0),a0
    lea ScrollColumnEdgeBufferA,a1 

    move g_timer1,d6
    and #3,d6           ; portion

; x pos in to map
    move d5,d0
    add d0,d0
    add d0,a0    
    
    
    
    
; ypos in to map
    move g_scroll_y,d0
    lsr #3,d0
    
    move d6,d1
    lsl #3,d1
    add d1,d0
    
    mulu sysg_levelInfo+levelinfo_tileMap1_stride,d0
    add d0,a0

    
    move g_scroll_y,d0
    lsr #3,d0
    
    move d6,d1
    lsl #3,d1
    add d1,d0
    
    move d0,d2
    and #31,d2
    add d2,d2
    move #31<<1,d3
    
    move g_vram_fg,d1

    move sysg_levelInfo+levelinfo_tileMap1_stride,d4
    
    move #32-1,d7
    move #16-1,d7
    move #8-1,d7
.vlp:
    move (a0),d0
    add d4,a0
    add d1,d0
    move d0,(a1,d2)
    addq #2,d2
    and d3,d2           ; wrap d2 offset in to ram buffer
    dbra d7,.vlp
    
    rts
    
    
    
    
;-------------------------------------------------------------------------------------------

    clrso
boss1_armX0 so.w 1
boss1_armY0 so.w 1
boss1_armX1Old so.w 1
boss1_armY1Old so.w 1
boss1_armX1 so.w 1
boss1_armY1 so.w 1
boss1_pathOffsetX so.w 1
boss1_pathOffsetY so.w 1
boss1_hoseRenderEndPosX so.w 1
boss1_hoseRenderEndPosY so.w 1
boss1_headFrame so.l 1
boss1_headState so.l 1
boss1_headTimer so.w 1
boss1_headX so.w 1
boss1_headY so.w 1
boss1_beanCanShoot so.w 1
boss1_structsize so.b 0

Coffee_InitBoss1Verlets:
    move.l g_cof+cof_m_verletPoints,a1      ;lea VerletPoints,a1
    lea Coffee_VerletData_Points,a2
    lea Coffee_VerletData_Fixes,a3
    lea g_cof+cof_verletSim,a4        ; lea VerletSim,a4
    move #0,vs_numPoints(a4)
    move #0,vs_numConnectors(a4)
    
    lea g_cof+cof_boss1Data,a5
    
.vertlp:
    move (a2)+,d0
    move (a2)+,d1
    cmp #9999,d0
    beq .doneVerts
    
    add #1,vs_numPoints(a4)

    moveq #0,d2
    move.w boss1_armX0(a5),d2
    add d0,d2
    swap d2
    move.l d2,vp_x(a1)
    move.l d2,vp_oldx(a1)

    moveq #0,d2
    move.w boss1_armY0(a5),d2
    add d1,d2
    swap d2
    move.l d2,vp_y(a1)
    move.l d2,vp_oldy(a1)
    
    moveq #0,d2
    move.b (a3)+,d2
    move d2,vp_fixed(a1)

    lea vp_structsize(a1),a1
    bra .vertlp
    
.doneVerts:
    
;---
    move.l g_cof+cof_m_verletConnectors,a1      ;lea VerletConnectors,a1
    lea Coffee_VerletData_Connectors,a2
    
.conLoop:
    move (a2)+,d5
    move (a2)+,d6
    cmp #9999,d5
    beq .doneConnectors
    
    add #1,vs_numConnectors(a4)
        
    move d5,d0
    mulu #vp_structsize,d0
    move.l g_cof+cof_m_verletPoints,a5  ;lea VerletPoints,a5
    add d0,a5
    move.l a5,vc_p0_addr(a1)

    move d6,d0
    mulu #vp_structsize,d0
    move.l g_cof+cof_m_verletPoints,a5  ;lea VerletPoints,a5
    add d0,a5
    move.l a5,vc_p1_addr(a1)
    
    move #COFFEE_VERLET_TEST_SPACING,vc_len(a1)
    lea vc_structsize(a1),a1
    
    bra .conLoop
.doneConnectors:
    rts

Coffee_Boss1_InitArm:
    lea g_cof+cof_boss1Data,a3
    move #210,boss1_armX0(a3)
    move #107,boss1_armY0(a3)
    move #250,boss1_armX1(a3)
    move #100,boss1_armY1(a3)
    
    move boss1_armX1(a3),boss1_armX1Old(a3)
    move boss1_armY1(a3),boss1_armY1Old(a3)
    
    move #210,boss1_pathOffsetX(a3)
    move #100,boss1_pathOffsetY(a3)
    
    bsr Coffee_InitBoss1Verlets

    rts

Coffee_Boss1_UpdateArm:
    lea g_cof+cof_boss1Data,a3

    move boss1_armX1(a3),boss1_armX1Old(a3)
    move boss1_armY1(a3),boss1_armY1Old(a3)
    
    lea.l go_path(a0),a1
    move.l path_addr(a1),a2
    
    add #1,path_currentIndex(a1)
    move path_currentIndex(a1),d0
    cmp path_numNodes(a1),d0
    blt .ok
    move #0,path_currentIndex(a1)
.ok:
    
    
    move path_currentIndex(a1),d0
    lsl #2,d0
    add d0,a2
    
    move (a2)+,d0
    add boss1_pathOffsetX(a3),d0
    move d0,boss1_armX1(a3)
    move (a2)+,d0
    add boss1_pathOffsetY(a3),d0
    move d0,boss1_armY1(a3)

    moveq #0,d0
    moveq #0,d1
    move.w boss1_armX1(a3),d0
    sub.w boss1_armX1Old(a3),d0    
    move.w boss1_armY1(a3),d1
    sub.w boss1_armY1Old(a3),d1
    swap d0
    swap d1
    move #15,d2
    bsr Verlet_MovePoint

    rts

Coffee_Boss1_Render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)


    move.l g_cof+cof_m_verletPoints,a1      ;lea VerletPoints,a1
    move g_cof+cof_verletSim+vs_numPoints,d4    ; VerletSim+vs_numPoints,d4
    subq #1,d4
.lp:
    move.w vp_x(a1),d5
    move.w vp_y(a1),d6
    
    move d5,g_cof+cof_boss1Data+boss1_hoseRenderEndPosX
    move d6,g_cof+cof_boss1Data+boss1_hoseRenderEndPosY
    
    move #SPRFRAME_COFFEE_PAL0_BOSSPIPE,sprbuf_frame(a5)
    cmp #0,d4
    bne .nofr
    move #SPRFRAME_COFFEE_PAL0_BOSSPIPEHEAD,sprbuf_frame(a5)
.nofr:

    bsr .render_doone
    lea vp_structsize(a1),a1
    dbra d4,.lp

    lea g_cof+cof_boss1Data,a3
    move boss1_headFrame(a3),sprbuf_frame(a5)
    move.w boss1_headX(a3),d5
    move.w boss1_headY(a3),d6
    bsr .render_doone

    rts
.render_doone:
    
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts    



Coffee_Boss1_InitHeadState0:
    lea g_cof+cof_boss1Data,a3
    move #SPRFRAME_COFFEE_PAL0_BOSSHEAD,boss1_headFrame(a3)
    move.l #Coffee_Boss1_UpdateHead,boss1_headState(a3)
    move #COFFEE_BOSS1_HEADTIME_OFF,boss1_headTimer(a3)
    move.w #194,boss1_headX(a3)
    move.w #50,boss1_headY(a3)
    move.l #Boss1_Collider,go_colliderAddr(a0)
    move #0,boss1_beanCanShoot(a3)
    rts

Coffee_Boss1_UpdateHead:
.statewaitoff:
    move.l #0,go_colliderAddr(a0)
    move #0,boss1_beanCanShoot(a3)
    
    lea g_cof+cof_boss1Data,a3
    move #SPRFRAME_COFFEE_PAL0_BOSSHEAD,boss1_headFrame(a3)
    
    sub #1,boss1_headTimer(a3)
    bge .rts
    
    move.l #.state_appear,boss1_headState(a3)

    
    rts
    
.state_appear:
    move #0,boss1_beanCanShoot(a3)
    move.l #0,go_colliderAddr(a0)
    lea g_cof+cof_boss1Data,a3
    add.l #$4000,boss1_headFrame(a3)
    
    cmp #SPRFRAME_COFFEE_PAL0_BOSSHEADEND1,boss1_headFrame(a3)
    blt .rts
    
    move #COFFEE_BOSS1_HEADTIME_ON,boss1_headTimer(a3)
    move.l #.state_attack,boss1_headState(a3)
    rts

.state_attack:
    bsr .doshoot
    move.l #Boss1_Collider,go_colliderAddr(a0)
    move #1,boss1_beanCanShoot(a3)

    lea g_cof+cof_boss1Data,a3
    move g_timer1_shr4_and1,d0
    add #SPRFRAME_COFFEE_PAL0_BOSSHEADEND1,d0
    move d0,boss1_headFrame(a3)

    sub #1,boss1_headTimer(a3)
    bgt .rts
    move.l #.state_disappear,boss1_headState(a3)
    rts
    
.state_disappear:
    move #0,boss1_beanCanShoot(a3)
    move.l #0,go_colliderAddr(a0)
    lea g_cof+cof_boss1Data,a3
    sub.l #$4000,boss1_headFrame(a3)
    
    cmp #SPRFRAME_COFFEE_PAL0_BOSSHEAD,boss1_headFrame(a3)
    bgt .rts
    
    move #COFFEE_BOSS1_HEADTIME_OFF,boss1_headTimer(a3)
    move.l #.statewaitoff,boss1_headState(a3)
    rts
.rts:
    rts
    
.doshoot:
    move g_timer1,d0
    and #17,d0
    bne .no
    lea .pos_beans,a2
    lea Coffee_InitEnemy_Boss1_FlyingBean,a1
    bsr .generateAt
.no:
    rts
.pos_beans dc.w 200,60
    
.generateAt:
    
    move.l go_x(a0),-(sp)
    move.l go_y(a0),-(sp)
    move (a2)+,go_x(a0)
    move (a2)+,go_y(a0)
    jsr CoffeeSpawnGO_EnemyBullet
    move.l (sp)+,go_y(a0)
    move.l (sp)+,go_x(a0)
    rts

    
Coffee_TestHighScore:    
    move.l sysg_score,d0
    cmp.l sysg_highscore,d0
    ble .nohighscore
    move.l d0,sysg_highscore
.nohighscore
    rts    
    
Boss1_Collider:
    dc.w 0,0+32,48,48+32

Coffee_InitEnemy_Boss1:
    move.l a0,g_boss
    SETSPR SPRITE_COFFEE_PAL0
    move #SPRFRAME_COFFEE_PAL0_BOSSPIPE,go_frame(a0)
    move #COF_HEALTH_BOSS1,go_health(a0)
    move #COF_SCORE_BOSS1,go_score(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    move.l #Coffee_Boss1_Render,go_onRender(a0)

    bsr Coffee_Boss1_InitHeadState0
    
    move #150,go_x(a0)  
    move #00,go_y(a0)
    bsr Coffee_Boss1_InitArm
    
    lea g_cof+cof_boss1Data,a3
    move #0,boss1_beanCanShoot(a3)

    rts


    
    
.update_head:
    lea g_cof+cof_boss1Data,a3
    move.l boss1_headState(a3),a4
    jsr (a4)
    rts
    

    
.collided:
    move go_health(a1),d0
    sub d0,go_health(a0)
    ble .die
    PSG_PLAY_SFX PSGSFX_gunslugs_hit_crate
    rts
.die:
    PSG_PLAY_SFX PSGSFX_gunslugs_mine_explosion
    moveq #0,d0
    move.w go_score(a0),d0
    add.l d0,sysg_score
    
    bsr Coffee_TestHighScore 
    
    
    move.l #0,go_colliderAddr(a0)
    move.l #0,g_boss
    move.l #.update_dead,go_onUpdate(a0)
    move #COF_BOSS_DEAD_TIME,go_timer(a0)
    rts




.update_dead:
    move #15,d2
    bsr Verlet_ClearFixed
    bsr Coffee_Enemy_Verlet_CalculateVerts
    bsr Coffee_Enemy_Verlet_CalculateConnectors
    
    lea g_cof+cof_boss1Data,a3
    move #SPRFRAME_COFFEE_PAL0_BOSSHEADDEAD,boss1_headFrame(a3)

    sub #1,go_timer(a0)
    bgt .nodead_finish

    
    move.l #InitState_GameComplete,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut
.nodead_finish:
    rts

.update:
    bsr .update_head

    move #200,go_x(a0)  
    move #00,go_y(a0)
    
    bsr Coffee_Boss1_UpdateArm


        
    move.l g_player,a1
    cmp #140,go_x(a1)
    blt .okplayer
    move #140,go_x(a1)
.okplayer:
        
    lea g_cof+cof_boss1Data,a3
    tst boss1_beanCanShoot(a3)
    bne .noSteam

    move g_timer1,d0
    and #1<<6,d0
    beq .noSteam

    move g_timer1,d0
    and #3,d0
    bne .noSteam

    lea Coffee_InitEnemy_Boss1_Steam,a1
    jsr CoffeeSpawnGO_EnemyBullet
    beq .noSteam
    lea g_cof+cof_boss1Data,a3
    move boss1_hoseRenderEndPosX(a3),go_x(a1)
    move boss1_hoseRenderEndPosY(a3),go_y(a1)
    
.noSteam:

    bsr Coffee_Enemy_Verlet_CalculateVerts
    bsr Coffee_Enemy_Verlet_CalculateConnectors

    rts
    
    
    
    
Coffee_InitEnemy_Boss1_Steam:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    SETSPR SPRITE_COFFEE_PAL0
    move #SPRFRAME_COFFEE_PAL0_STEAM0,go_frame(a0)

    move.l #.update,go_onUpdate(a0)

    move.l #-$50000,go_dx(a0)
    move.l #0,go_long0(a0)

    bsr Coffee_CollisionFromFrame    
    rts

.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    
    add.l #$180,go_dx(a0)
    
    move go_long0(a0),d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    
    add.l #$2000,go_long0(a0)
    cmp #7,go_long0(a0)
    beq .die
    
    cmp #-32,go_x(a0)
    blt .die
    
    rts
.die:
    jmp GOManager_DeleteObject
.frames:
    dc.w SPRFRAME_COFFEE_PAL0_STEAM0
    dc.w SPRFRAME_COFFEE_PAL0_STEAM1
    dc.w SPRFRAME_COFFEE_PAL0_STEAM2
    dc.w SPRFRAME_COFFEE_PAL0_STEAM3
    dc.w SPRFRAME_COFFEE_PAL0_STEAM2
    dc.w SPRFRAME_COFFEE_PAL0_STEAM1
    dc.w SPRFRAME_COFFEE_PAL0_STEAM0


Coffee_InitEnemy_Boss1_FlyingBean:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    SETSPR SPRITE_COFFEE_PAL0
    move #SPRFRAME_COFFEE_PAL0_BEANBULLET,go_frame(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)

    bsr Coffee_CollisionFromFrame
    move.l #.update,go_onUpdate(a0)
    move #1,go_health(a0)
    move #0,go_score(a0)
    move.l #Coffee_EnemyCollidedWithBullet,go_onCollided(a0)

    jsr UTILS_GetRandWordFast
    and #7,d0
    add #3,d0
    move d0,d5
    
    jsr UTILS_GetRandWordFast
    and #31,d0
    sub #64-16,d0
    jsr GOTOOLS_GetMovementVecFromRot
    muls d5,d2
    muls d5,d1
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
    

    move.l #.collider,go_colliderAddr(a0)    
    rts
.collider:
    dc.w -6,6,-6,6

.update:

    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    add.l #$1000,go_dy(a0)
    
    cmp #-32,go_x(a0)
    blt .die
    cmp #224+32,go_y(a0)
    bgt .die
    rts
.die:
    jmp GOManager_DeleteObject
    
    
Coffee_CollisionFromFrameA1:
    move.l go_sprgroup(a1),a2
    move.l sprgroup_coltable_addr(a2),a2
    move go_frame(a1),d0
    lsl #3,d0
    add d0,a2
    move.l a2,go_colliderAddr(a1)
	rts

Coffee_CollisionFromFrame:
    move.l go_sprgroup(a0),a1
    move.l sprgroup_coltable_addr(a1),a1
    move go_frame(a0),d0
    lsl #3,d0
    add d0,a1
    move.l a1,go_colliderAddr(a0)
	rts

Coffee_SpawnTabSingleCall:
    SPAWNTABENTRY SPRDEF_COFFEE_UPDOWN,0,0,Coffee_InitMultiGen_UpDown
    SPAWNTABENTRY SPRDEF_COFFEE_PATH,0,0,Coffee_InitMultiGen_Path
    SPAWNTABENTRY SPRDEF_COFFEE_ROCKET,0,0,Coffee_InitMultiGen_Rocket
    SPAWNTABENTRY SPRDEF_COFFEE_PRESS,0,0,Coffee_InitMultiGen_Press
    SPAWNTABENTRY SPRDEF_COFFEE_PRESSYFLIP,0,0,Coffee_InitMultiGen_PressYflip
    SPAWNTABENTRY SPRDEF_COFFEE_POT0,0,0,Coffee_InitMultiGen_Pot0
    SPAWNTABENTRY SPRDEF_COFFEE_CIRCLER,0,0,Coffee_InitMultiGen_Circler
    SPAWNTABENTRY SPRDEF_COFFEE_BIGPOT,0,0,Coffee_InitMultiGen_BigPot
    SPAWNTABENTRY SPRDEF_COFFEE_BOSS1,0,0,Coffee_InitMultiGen_Boss1
    SPAWNTABENTRY SPRDEF_COFFEE_SCALER,0,0,Coffee_InitMultiGen_Scaler
    SPAWNTABEND    







SpriteScaler_Init:
    lea SPRDEF_Coffee_Pal0_SoftwareSprite+4,a0
    move.l g_cof+cof_m_spriteScaleBuffer,a1
    move #(COF_SPRSCALEBUFFER_SIZE)-1,d1
.lp:
    move.b #0,(a1)+
    dbra d1,.lp
    rts    


SpriteScaler_Update:
    tst g_cof+cof_doSpriteScale
    bne .a
    rts
.tabx:
    dc.w 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
    dc.w 15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0
.taby:
    dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    dc.w 31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

.a
    lea SpriteScaleYTable,a2
    move.l g_cof+cof_m_spriteScaleBuffer,a1
    
    move g_timer1,d6
    lsr #1,d6
    and #63,d6
    add d6,d6
    
    lea SpriteScaler_ScanCopies,a3
    lea .tabx,a5
    move.w (a5,d6),d0
    lsl #2,d0
    move.l (a3,d0),a3
    
    lea .taby,a5
    move.w (a5,d6),d0
    lsl #6,d0
    add d0,a2
    
    move.l #0,d4
    move #32-1,d7
.lp:
    move (a2)+,d0
    bmi .clear
    
    lea SPRDEF_Coffee_Pal0_SoftwareSprite+4,a0
    lsl #2,d0
    add d0,a0
    jsr (a3)
    
    move.l d0,(a1)        ; 1 row of 1 char
    move.l d1,128(a1)
    move.l d2,256(a1)
    move.l d3,384(a1)
    lea 4(a1),a1
    dbra d7,.lp
    bra .done
    
.clear:
    move.l d4,(a1)
    move.l d4,128(a1)
    move.l d4,256(a1)
    move.l d4,384(a1)
    lea 4(a1),a1
    dbra d7,.lp
    
.done:
    lea .taby,a5
    move.w (a5,d6),d0   ; num lines done
    move d0,d4
    
    jsr UTILS_GetRandWordFastUpTo
    
    lsl #2,d0
    move.l g_cof+cof_m_spriteScaleBuffer,a1
    add d0,a1
    
    move d4,d0
    lsr #1,d0
    jsr UTILS_GetRandWordFastUpTo
    add d0,d0    
    move .spakoffsets(pc,d0),d0

    move.b #$ff,(a1,d0)

    rts    
    
.spakoffsets:
    dc.w c00,c01,c02,c03,c10,c11,c12,c13,c20,c21,c22,c23,c30,c31,c32,c32
    

SpriteScaler_ScanCopies:
    dc.l SpriteScaler_ScanCopies_2
    dc.l SpriteScaler_ScanCopies_4
    dc.l SpriteScaler_ScanCopies_6
    dc.l SpriteScaler_ScanCopies_8
    dc.l SpriteScaler_ScanCopies_10
    dc.l SpriteScaler_ScanCopies_12
    dc.l SpriteScaler_ScanCopies_14
    dc.l SpriteScaler_ScanCopies_16
    dc.l SpriteScaler_ScanCopies_18
    dc.l SpriteScaler_ScanCopies_20
    dc.l SpriteScaler_ScanCopies_22
    dc.l SpriteScaler_ScanCopies_24
    dc.l SpriteScaler_ScanCopies_26
    dc.l SpriteScaler_ScanCopies_28
    dc.l SpriteScaler_ScanCopies_30
    dc.l SpriteScaler_ScanCopies_32

c0 equ 0
c1 equ 128
c2 equ 256
c3 equ 384

c00 equ c0+0
c01 equ c0+1
c02 equ c0+2
c03 equ c0+3

c10 equ c1+0
c11 equ c1+1
c12 equ c1+2
c13 equ c1+3

c20 equ c2+0
c21 equ c2+1
c22 equ c2+2
c23 equ c2+3

c30 equ c3+0
c31 equ c3+1
c32 equ c3+2
c33 equ c3+3



;;;	2 dc.w c00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;;;	4 dc.w c00,c20,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;;;	6 dc.w c00,c11,c22,0,0,0,0,0,0,0,0,0,0,0,0,0
;;;	8 dc.w c00,c10,c20,c30,0,0,0,0,0,0,0,0,0,0,0,0
;;;	10 dc.w c00,c03,c12,c21,c30,0,0,0,0,0,0,0,0,0,0,0
;;;	12 dc.w c00,c02,c11,c20,c22,c31,0,0,0,0,0,0,0,0,0,0
;;;	14 dc.w c00,c02,c10,c12,c21,c23,c31,0,0,0,0,0,0,0,0,0
;;;	16 dc.w c00,c02,c10,c12,c20,c22,c30,c32,0,0,0,0,0,0,0,0
;;;	18 dc.w c00,c01,c03,c11,c13,c20,c22,c30,c32,0,0,0,0,0,0,0
;;;	20 dc.w c00,c01,c03,c10,c12,c20,c21,c23,c30,c32,0,0,0,0,0,0
;;;	22 dc.w c00,c01,c02,c10,c11,c13,c20,c22,c23,c31,c32,0,0,0,0,0
;;;	24 dc.w c00,c01,c02,c10,c11,c12,c20,c21,c22,c23,c31,c32,c33,0,0,0
;;;	26 dc.w c00,c01,c02,c03,c10,c12,c13,c20,c21,c23,c30,c31,c32,0,0,0
;;;	28 dc.w c00,c01,c02,c03,c10,c11,c12,c20,c21,c22,c23,c30,c31,c32,0,0
;;;	30 dc.w c00,c01,c02,c03,c10,c11,c12,c13,c20,c21,c22,c23,c30,c31,c32,0
;;;	32 dc.w c00,c01,c02,c03,c10,c11,c12,c13,c20,c21,c22,c23,c30,c31,c32,c33


SpriteScaler_ScanCopies_32
    move.l c0(a0),d0
    move.l c1(a0),d1
    move.l c2(a0),d2
    move.l c3(a0),d3
    rts

;	2 dc.w c00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
SpriteScaler_ScanCopies_2:
    move.b c00(a0),d0
    lsl #8,d0
    move.b #0,d0
    swap d0
    move.w #0,d0

    moveq #0,d1
    moveq #0,d2
    moveq #0,d3
    rts


;	4 dc.w c00,c20,0,0,0,0,0,0,0,0,0,0,0,0,0,0
SpriteScaler_ScanCopies_4:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c20(a0),d0
    swap d0
    move.w #0,d0

    moveq #0,d1
    moveq #0,d2
    moveq #0,d3
    rts

;	6 dc.w c00,c11,c22,0,0,0,0,0,0,0,0,0,0,0,0,0
SpriteScaler_ScanCopies_6:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c1(a0),d0
    swap d0
    move.b c22(a0),d0
    lsl #8,d0
    move.b #0,d0

    moveq #0,d1
    moveq #0,d2
    moveq #0,d3
    rts

;	10 dc.w c00,c03,c12,c21,c30,0,0,0,0,0,0,0,0,0,0,0
SpriteScaler_ScanCopies_10:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c03(a0),d0
    swap d0
    move.b c12(a0),d0
    lsl #8,d0
    move.b c21(a0),d0

    move.b c30(a0),d1
    lsl #8,d1
    move.b #0,d1
    swap d1
    move.w #0,d1

    moveq #0,d2
    moveq #0,d3
    rts

;	12 dc.w c00,c02,c11,c20,c22,c31,0,0,0,0,0,0,0,0,0,0
SpriteScaler_ScanCopies_12:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c02(a0),d0
    swap d0
    move.b c11(a0),d0
    lsl #8,d0
    move.b c20(a0),d0

    move.b c22(a0),d1
    lsl #8,d1
    move.b c31(a0),d1
    swap d1
    move.w #0,d1

    moveq #0,d2
    moveq #0,d3
    rts

;	14 dc.w c00,c02,c10,c12,c 21,c23,c31,0, 0,0,0,0, 0,0,0,0
SpriteScaler_ScanCopies_14:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c02(a0),d0
    swap d0
    move.b c10(a0),d0
    lsl #8,d0
    move.b c12(a0),d0

    move.b c21(a0),d1
    lsl #8,d1
    move.b c23(a0),d1
    swap d1
    move.b c31(a0),d1
    lsl #8,d1
    move.b #0,d1

    moveq #0,d2
    moveq #0,d3
    rts

;	18 dc.w c00,c01,c03,c11, c13,c20,c22,c30, c32,0,0,0, 0,0,0,0
SpriteScaler_ScanCopies_18:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c01(a0),d0
    swap d0
    move.b c03(a0),d0
    lsl #8,d0
    move.b c11(a0),d0

    move.b c13(a0),d1
    lsl #8,d1
    move.b c20(a0),d1
    swap d1
    move.b c22(a0),d1
    lsl #8,d1
    move.b c30(a0),d1

    move.b c32(a0),d2
    lsl #8,d2
    move.b #0,d2
    swap d2
    move.w #0,d2

    moveq #0,d3
    rts


;	20 dc.w c00,c01,c03,c10, c12,c20,c21,c23, c30,c32,0,0, 0,0,0,0
SpriteScaler_ScanCopies_20:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c01(a0),d0
    swap d0
    move.b c03(a0),d0
    lsl #8,d0
    move.b c10(a0),d0

    move.b c12(a0),d1
    lsl #8,d1
    move.b c20(a0),d1
    swap d1
    move.b c21(a0),d1
    lsl #8,d1
    move.b c23(a0),d1

    move.b c30(a0),d2
    lsl #8,d2
    move.b c32(a0),d2
    swap d2
    move.w #0,d2

    moveq #0,d3
    rts

;	22 dc.w c00,c01,c02,c10,c11,c13,c20,c22,c23,c31,c32,0,0,0,0,0
SpriteScaler_ScanCopies_22:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c01(a0),d0
    swap d0
    move.b c02(a0),d0
    lsl #8,d0
    move.b c10(a0),d0

    move.b c11(a0),d1
    lsl #8,d1
    move.b c13(a0),d1
    swap d1
    move.b c20(a0),d1
    lsl #8,d1
    move.b c22(a0),d1

    move.b c23(a0),d2
    lsl #8,d2
    move.b c31(a0),d2
    swap d2
    move.b c32(a0),d2
    lsl #8,d2
    move.b #0,d2

    moveq #0,d3
    rts

;	26 dc.w c00,c01,c02,c03,c10,c12,c13,c20,c21,c23,c30,c31,c32,0,0,0
SpriteScaler_ScanCopies_26:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c01(a0),d0
    swap d0
    move.b c02(a0),d0
    lsl #8,d0
    move.b c03(a0),d0

    move.b c10(a0),d1
    lsl #8,d1
    move.b c12(a0),d1
    swap d1
    move.b c13(a0),d1
    lsl #8,d1
    move.b c20(a0),d1

    move.b c21(a0),d2
    lsl #8,d2
    move.b c23(a0),d2
    swap d2
    move.b c30(a0),d2
    lsl #8,d2
    move.b c31(a0),d2

    move.b c32(a0),d3
    lsl #8,d3
    move.b #0,d3
    swap d3
    move.w #0,d3
    rts

;	28 dc.w c00,c01,c02,c03, c10,c11,c12,c20, c21,c22,c23,c30, c31,c32,0,0
SpriteScaler_ScanCopies_28:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c01(a0),d0
    swap d0
    move.b c02(a0),d0
    lsl #8,d0
    move.b c03(a0),d0

    move.b c10(a0),d1
    lsl #8,d1
    move.b c11(a0),d1
    swap d1
    move.b c12(a0),d1
    lsl #8,d1
    move.b c20(a0),d1

    move.b c21(a0),d2
    lsl #8,d2
    move.b c22(a0),d2
    swap d2
    move.b c23(a0),d2
    lsl #8,d2
    move.b c30(a0),d2

    move.b c31(a0),d3
    lsl #8,d3
    move.b c32(a0),d3
    swap d3
    move.w #0,d3
    rts


SpriteScaler_ScanCopies_30:
    move.b c00(a0),d0
    lsl #8,d0
    move.b c01(a0),d0
    swap d0
    move.b c02(a0),d0
    lsl #8,d0
    move.b c03(a0),d0

    move.b c10(a0),d1
    lsl #8,d1
    move.b c11(a0),d1
    swap d1
    move.b c12(a0),d1
    lsl #8,d1
    move.b c13(a0),d1

    move.b c20(a0),d2
    lsl #8,d2
    move.b c21(a0),d2
    swap d2
    move.b c22(a0),d2
    lsl #8,d2
    move.b c23(a0),d2

    move.b c30(a0),d3
    lsl #8,d3
    move.b c31(a0),d3
    swap d3
    move.b c32(a0),d3
    lsl #8,d3
    move.b #0,d3
    rts

SpriteScaler_ScanCopies_24:
    move.b c0+0(a0),d0
    lsl #8,d0
    move.b c0+1(a0),d0
    swap d0
    move.b c0+3(a0),d0
    lsl #8,d0
    move.b c1+0(a0),d0

    move.b c1+1(a0),d1
    lsl #8,d1
    move.b c1+3(a0),d1
    swap d1
    move.b c2+0(a0),d1
    lsl #8,d1
    move.b c2+1(a0),d1

    move.b c2+3(a0),d2
    lsl #8,d2
    move.b c3+0(a0),d2
    swap d2
    move.b c3+1(a0),d2
    lsl #8,d2
    move.b c3+3(a0),d2
    
    moveq #0,d3
    rts
    
SpriteScaler_ScanCopies_16:
    move.b c0(a0),d0
    lsl #8,d0
    move.b c0+2(a0),d0
    swap d0
    move.b c1(a0),d0
    lsl #8,d0
    move.b c1+2(a0),d0

    move.b c2(a0),d1
    lsl #8,d1
    move.b c2+2(a0),d1
    swap d1
    move.b c3(a0),d1
    lsl #8,d1
    move.b c3+2(a0),d1
    
    moveq #0,d2
    moveq #0,d3
    rts
    
SpriteScaler_ScanCopies_8:
    move.b c0(a0),d0
    lsl #8,d0
    move.b c1(a0),d0
    swap d0
    move.b c2(a0),d0
    lsl #8,d0
    move.b c3(a0),d0

    moveq #0,d1
    moveq #0,d2
    moveq #0,d3
    rts
    
    
    
SpriteScaler_DMA:
    tst g_cof+cof_doSpriteScale
    beq .no

    move.l g_cof+cof_m_spriteScaleBuffer,d0
	move.l #0,d1
	move g_cof+cof_spriteScaleVDPOffset,d1
	lsl #5,d1
	move.l #COF_SPRSCALEBUFFER_SIZE,d2
	move #2,d3
	jsr VDP_SetDMA
.no:
    rts

SpriteScaleYTable:
	dc.w 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,10,21,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,8,16,24,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,6,12,19,25,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,5,10,16,21,26,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,4,9,13,18,22,27,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,4,8,12,16,20,24,28,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,3,7,10,14,17,21,24,28,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,3,6,9,12,16,19,22,25,28,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,2,5,8,11,14,17,20,23,26,29,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,2,5,8,10,13,16,18,21,23,26,29,31,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,2,4,7,9,12,14,17,19,22,24,27,29,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,2,4,6,9,11,13,16,18,20,22,25,27,29,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,2,4,6,8,10,12,14,17,19,21,23,25,27,29,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,3,5,7,9,11,13,15,16,18,20,22,24,26,28,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,3,5,7,8,10,12,14,16,17,19,21,23,24,26,28,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,3,5,6,8,10,11,13,15,16,18,20,21,23,25,26,28,30,31,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,3,4,6,8,9,11,12,14,16,17,19,20,22,24,25,27,28,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22,24,25,27,28,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,2,4,5,7,8,10,11,13,14,16,17,18,20,21,23,24,26,27,29,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,2,4,5,6,8,9,11,12,13,15,16,18,19,20,22,23,25,26,27,29,30,31,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,2,4,5,6,8,9,10,11,13,14,15,17,18,20,21,22,24,25,26,28,29,30,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,2,3,5,6,7,8,10,11,12,14,15,16,17,19,20,21,23,24,25,26,28,29,30,-1,-1,-1,-1,-1,-1,-1
	dc.w 0,1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,20,22,23,24,25,27,28,29,30,-1,-1,-1,-1,-1,-1
	dc.w 0,1,2,3,4,5,7,8,9,10,11,13,14,15,16,17,18,20,21,22,23,24,26,27,28,29,30,31,-1,-1,-1,-1
	dc.w 0,1,2,3,4,5,6,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,-1,-1,-1
	dc.w 0,1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,-1,-1,-1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,-1,-1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
SpriteScaleXTable:
;	dc.w c00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w c00,c20,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w c00,c11,c22,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w c00,c10,c20,c30,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w c00,c03,c12,c21,c30,0,0,0,0,0,0,0,0,0,0,0
;	dc.w c00,c02,c11,c20,c22,c31,0,0,0,0,0,0,0,0,0,0
;	dc.w c00,c02,c10,c12,c21,c23,c31,0,0,0,0,0,0,0,0,0
;	dc.w c00,c02,c10,c12,c20,c22,c30,c32,0,0,0,0,0,0,0,0
;	dc.w c00,c01,c03,c11,c13,c20,c22,c30,c32,0,0,0,0,0,0,0
;	dc.w c00,c01,c03,c10,c12,c20,c21,c23,c30,c32,0,0,0,0,0,0
;	dc.w c00,c01,c02,c10,c11,c13,c20,c22,c23,c31,c32,0,0,0,0,0
;	dc.w c00,c01,c02,c10,c11,c12,c20,c21,c22,c23,c31,c32,c33,0,0,0
;	dc.w c00,c01,c02,c03,c10,c12,c13,c20,c21,c23,c30,c31,c32,0,0,0
;	dc.w c00,c01,c02,c03,c10,c11,c12,c20,c21,c22,c23,c30,c31,c32,0,0
;	dc.w c00,c01,c02,c03,c10,c11,c12,c13,c20,c21,c22,c23,c30,c31,c32,0
;	dc.w c00,c01,c02,c03,c10,c11,c12,c13,c20,c21,c22,c23,c30,c31,c32,c33

