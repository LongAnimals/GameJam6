

UNDERGROUND_SPIKE_VDPINDEX equ $4|PAL_1
UNDERGROUND_FLAME_VDPINDEX equ $0|PAL_1

PSGSFX_UG_Flap equ PSGSFX_gunslugs_bouncer_bounce
PSGSFX_UG_Die equ PSGSFX_gunslugs_player_die
PSGSFX_UG_GetPickup equ PSGSFX_gunslugs_chym
PSGSFX_UG_GenerateChaser equ PSGSFX_gunslugs_hit_crate
PSGSFX_UG_ChaserDie equ PSGSFX_gunslugs_shoot_chicken
PSGSFX_UG_ParticleHitVentHole equ PSGSFX_gunslugs_shoot_flame
PSGSFX_UG_VentHoleSpawnPickup equ PSGSFX_gunslugs_shoot_chicken
PSGSFX_UG_TimerBonus equ PSGSFX_gunslugs_ballup_laser
PSGSFX_UG_LimpetMine equ PSGSFX_gunslugs_mine_explosion


    clrso
ug_levelIndex       so.w 1

ug_inLevelOverSequence so.w 1
ug_levelOverSequenceTimer so.w 1
ug_levelOverSequenceTimerMax so.w 1

ug_startScore   so.l 1
ug_startHighScore   so.l 1

ug_timer_seconds        so.w 1
ug_timer_subseconds        so.w 1

ug_totalGems            so.w 1
ug_numGemsCollected     so.w 1

ug_levelOverFlag       so.b 1
ug_debugNextLevelFlag               so.b 1

ug_ventHoleIndex     so.w 1
ug_ventHoleGOList       so.l 8

ug_chaserHoleIndex      so.w 1
ug_chaserHoleGOList       so.l 8

ug_limpetMineIndex     so.w 1
ug_LimpetMineGOList       so.l 8

ug_spawnCount           so.w 1
ug_m_ramscreen          so.l 1
ug_m_map                so.l 1
ug_m_angleTable         so.l 1
ug_m_flowMap            so.l 1
ug_m_particles          so.l 1
ug_m_collisionMap       so.l 1
ug_nextParticleAddr     so.l 1
ug_pastLastParticleAddr so.l 1
ug_flowmapUpdateIndex   so.w 1
ug_blank_tile           so.w 1      
ug_fontdrawarea so.b     18

ug_structsize           so.b 0


UG_InitGlobals:
    lea g_ug,a0
    move #0,ug_numGemsCollected(a0)
    move #0,ug_totalGems(a0)
    move.b #0,ug_levelOverFlag(a0)
    move.b #0,ug_debugNextLevelFlag(a0)
    
    move #0,ug_inLevelOverSequence(a0)
    move #0,ug_ventHoleIndex(a0)
    move #0,ug_chaserHoleIndex(a0)
    move #0,ug_limpetMineIndex(a0)
    move #0,ug_flowmapUpdateIndex(a0)
    
    move #6,ug_timer_seconds(a0)
    move #0,ug_timer_subseconds(a0)
    move #0,ug_levelIndex(a0)
    
    move.l sysg_highscore,ug_startHighScore(a0)
    move.l sysg_score,ug_startScore(a0)

    rts
    
UG_ResetLevelScore:
    move.l g_ug+ug_startHighScore,sysg_highscore
    move.l g_ug+ug_startScore,sysg_score
    rts

    clrso
ugp_active so.b 1
ugp_flags so.b 1
ugp_x so.l 1
ugp_y so.l 1
ugp_timer so.w 1
ugp_tile so.w 1
ugp_structsize so.b 0

UG_PARTICLES_NUMPERFRAME equ 32
UG_PARTICLES_NUMFRAMES equ 8
UG_MAX_PARTICLES equ UG_PARTICLES_NUMFRAMES*UG_PARTICLES_NUMPERFRAME

UG_PARTICLES_RAMSIZE equ UG_MAX_PARTICLES*ugp_structsize
UG_FLOWMAP_SIZE equ 32*64      ;2k
UG_COLMAP_SIZE equ 32*64      ;2k
UG_MAP_SIZE     equ 32*64*2 ;4k
UG_SCREEN_RAM_SIZE equ 32*32*2  ;2k

UG_ANGLE_TABLE_SIZE equ 128*8

UG_ExitState:
	jsr VDP_DisableShadowHighlightMode
	VDP_DISABLE_HBL
	rts


UG_MEM_AllocForGame
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_GameObjects,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Underground,a0
    bsr MEM_AllocateGroup
    
    bsr MEM_ShowDebug
    rts

MEM_Table_Underground:

    dc.l g_ug+ug_m_map
    dc.w UG_MAP_SIZE

    dc.l g_ug+ug_m_ramscreen
    dc.w UG_SCREEN_RAM_SIZE

    dc.l g_ug+ug_m_particles
    dc.w UG_PARTICLES_RAMSIZE

    dc.l g_ug+ug_m_flowMap
    dc.w UG_FLOWMAP_SIZE

    dc.l g_ug+ug_m_collisionMap
    dc.w UG_COLMAP_SIZE

    dc.l g_ug+ug_m_angleTable
    dc.w UG_ANGLE_TABLE_SIZE
    

    dc.l -1


UG_InitState:
    move.l #UG_ExitState,sysg_scene_exitFunc
	jsr Globals_ClearAll
    jsr MEM_Init
    jsr UG_MEM_AllocForGame 
	jsr ClearVRAM
	move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
	move #REG_MODE4|REGMASK_MODE4_H32|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
	move #REG_SCROLLSIZE|VDP_PLANESIZE_32x32,VDP_CONTROL
    jsr VDP_ClearBorderColor
	jsr SCROLL_ResetHardware
	

    move #REG_WINDOW_HPOS|0,VDP_CONTROL
    ;if IS_DEBUG_MODE
    ;move #REG_WINDOW_VPOS|4,VDP_CONTROL
    ;endif

    ;move.b #1,sysg_cheatmode
	
    move.l #sprdefs2,sysg_sprites_baseaddr
    move.l #sprdefs2+2,sysg_sprites_baseaddr2


	move.l #0,g_post_init_func
	move.l #0,g_game_loopaddr
	move.l #0,g_game_vbladdr

	move #0,g_vram_currentpos	; for loading in 

	jsr FADE_ClearAll


    
    ifnd IS_FINAL_GAME
    move #2,sysg_levelIndex    
    endif
    bsr UG_InitLevelData




	jsr SOUND_Init
	move #0,sysg_current_music
    move #SONG_FIREBIRD,d0

    jsr MUSIC_InitSong

    

    bsr UG_InitGlobals
    
    bsr UG_SetLevelTimer

    
    jsr UG_InitForGame
    jsr UG_InitForLevel

    bsr UG_InitWorldAndLevelStuff_GFX
    bsr UG_InitWorldAndLevelStuff_Mem

    bsr UG_InitOptimizedAngleTable
    bsr UG_InitRamMap
    bsr UG_InitCollisionMap
    bsr UG_InitParticles
    bsr UG_InitFlowMap
    
    jsr UG_InitGOs

	FADE_SETVALUE 0
	FADE_START_IN 0

	move.l #UG_UpdateGame,g_game_loopaddr
	move.l #UG_UpdateVBL,g_game_vbladdr

    rts


UG_NextLevel:
    add #1,sysg_levelIndex
    ;cmp #6,sysg_levelIndex
    ;blt .nowrap
    ;move #0,sysg_levelIndex
.nowrap:
    rts
    
UG_InitLevelData:
    move sysg_levelIndex,d0
    add d0,d0
    move .levels(pc,d0),d0
    jsr LEVEL_InitData
    rts

UNDERGROUND_NUM_LEVELS equ 10

.levels:
    dc.w LEVEL_UNDERGROUND1
    dc.w LEVEL_UNDERGROUND2
    dc.w LEVEL_UNDERGROUND3
    dc.w LEVEL_UNDERGROUND4
    dc.w LEVEL_UNDERGROUND5
    dc.w LEVEL_UNDERGROUND6
    dc.w LEVEL_UNDERGROUND7
    dc.w LEVEL_UNDERGROUND8
    dc.w LEVEL_UNDERGROUND9
    dc.w LEVEL_UNDERGROUND10

UG_SetLevelTimer:
    move sysg_levelIndex,d0
    add d0,d0
    move .times(pc,d0),g_ug+ug_timer_seconds
    rts
.times:
    dc.w 40+60
    dc.w 55+40
    dc.w 75+30
    dc.w 80+30
    dc.w 95+30
    dc.w 160+30
    dc.w 120+30
    dc.w 170+30
    dc.w 120+30
    dc.w 120+30
    


UG_ResetForRealtimeCommand:
    move.l #0,g_game_loopaddr
    move.l #0,g_game_vbladdr
    	
   
    bsr UG_InitGlobals
    bsr UG_SetLevelTimer
    jsr UG_InitForGame
    jsr UG_InitForLevel

    bsr UG_InitWorldAndLevelStuff_GFX
    bsr UG_InitWorldAndLevelStuff_Mem

    bsr UG_InitOptimizedAngleTable
    bsr UG_InitRamMap
    bsr UG_InitCollisionMap
    bsr UG_InitParticles
    bsr UG_InitFlowMap
    
    jsr UG_InitGOs
    
    move.l #UG_UpdateGame,g_game_loopaddr
    move.l #UG_UpdateVBL,g_game_vbladdr
    
    rts

    
UG_InitForGame:
    rts
    

UG_InitForLevel:
    rts

UG_InitWorldAndLevelStuff_GFX:
    jsr UG_InitVDPForLevel
    rts
    

UG_InitWorldAndLevelStuff_Mem:
    bsr UG_UpdateGame_InitGlobals

	move.l #0,g_scroll_x 
	move.l #0,g_scroll_y 
	move.l #0,g_scroll_to_x 
	move.l #0,g_scroll_to_y 

	jsr GOManager_Setup_Game
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
    
    rts
    
    
UG_InitGOs:
    lea UG_InitHUD,a1
    bsr UG_SpawnGameObject_General

    bsr UG_SpawnStuff
    bsr UG_SpawnSingleCallStuff
    rts

UG_InitHUD:
    SETSPR SPRITE_UNDERGROUND_PAL1_HUD
    move #0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.render,go_onRender(a0)
    rts

.update:
    move g_scroll_y,go_y(a0)
    rts
    
.render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)

    move #10,d5
    move #5,d6
    move #SPRFRAME_UNDERGROUND_PAL1_HUD_TIME,d1
	bsr .render_doone
   
    move #10+24,d5
    move #4,d6
    move g_ug+ug_timer_seconds,d4
    bsr .renderNumber3 

    move #170,d5
    move #5,d6
    move #SPRFRAME_UNDERGROUND_PAL1_HUD_SCORE,d1
	bsr .render_doone
   
    move #170+30,d5
    move #4,d6
    move sysg_score+2,d4
    bsr .renderNumber5 

    rts

.renderNumber5:
    move d4,d0
    lea g_ug+ug_fontdrawarea,a1
    bsr UG_Hud_RenderNumber5
    lea g_ug+ug_fontdrawarea,a1
    bra .renderstring


;d4
.renderNumber3
    lea FONT_NumberTable_Byte,a1
    lsl #2,d4
    add d4,a1


;a1
.renderstring:
	moveq #0,d1		
	move.b	(a1)+,d1	
	beq .stringEnd		
	sub.b #'0',d1
	bsr .render_doone
	add #8,d5
	bra.s	.renderstring
.stringEnd:

    rts
    
.render_doone:
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
    
UG_Hud_RenderNumber5
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
    

;-----------------------------------------------------------------------------------------------    

;-----------------------------------------------------------------------------------------------    

; a1 is GO
UG_LimpetMineHitParticle:
    sub #1,go_health(a1)
    bgt .no
    
    PSG_PLAY_SFX PSGSFX_UG_LimpetMine

    
    tst  go_word0(a1)
    beq .limpet
.killer:
    bsr .delete_col

    jsr GOManager_DeleteObjectA1

    move go_x(a1),d0
    move go_y(a1),d1
    add #8,d0
    sub #24,d1
    bsr UG_ExplosionObjectCollision

    move.l a1,a0
    lea UG_InitExplosion,a1
    bsr UG_SpawnGameObject_General
    move go_x(a0),d0
    add #8,d0
    move d0,go_x(a1)
    move go_y(a0),d0
    sub #24,d0
    move d0,go_y(a1)
    
    rts 
        
.limpet:
    bsr .delete_col
    
    move #0,d2    
    lea .bangoffsets,a2
    move #4-1,d3
.bangloop:
    move go_x(a1),d0
    add (a2),d0
    move go_y(a1),d1
    add 2(a2),d1
    move #0,d2
    bsr UG_SetColTile
    
    move go_x(a1),d0
    add (a2),d0
    move go_y(a1),d1
    add 2(a2),d1
    move g_ug+ug_blank_tile,d2
    bsr UG_SetRamMapTile
    
    lea 4(a2),a2
    dbra d3,.bangloop

 

    jsr GOManager_DeleteObjectA1 
    
    move.l a1,a0
    lea UG_InitExplosion,a1
    bsr UG_SpawnGameObject_General
    move go_x(a0),d0
    add #8,d0
    move d0,go_x(a1)
    move go_y(a0),d0
    sub #8,d0
    move d0,go_y(a1)
    
    
.no
    rts
.bangoffsets:
    dc.w 0,-8,8,-8,0,-16,8,-16
.delete_col:
    move #0,d2    
    lea UG_LimpetMine_ColOffsets,a2
    move #2-1,d3
.colloop:
    move go_x(a1),d0
    add (a2)+,d0
    move go_y(a1),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop
    rts    

    

UG_LimpetMine_ColOffsets:
    dc.w 0,0, 8,0

UG_InitLimpetKillerUp:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_LIMPETKILLERUP,go_frame(a0)
    move.l #.first,go_onUpdate(a0)
    
    move #1,go_word0(a0)
    move #8,go_maxHealth(a0)
    move #8,go_health(a0)
    
    move g_ug+ug_limpetMineIndex,d0
    move d0,go_ug_ventHoleIndex(a0)
    lsl #2,d0
    lea g_ug+ug_LimpetMineGOList,a2
    move.l a0,(a2,d0)
    
    add #1,g_ug+ug_limpetMineIndex
    rts
    
    
.first:
    move go_ug_ventHoleIndex(a0),d2
    add #UG_COL_LIMPETMINE_FIRST,d2
    
    lea UG_LimpetMine_ColOffsets,a2
    move #4-1,d3
.colloop:
    move go_x(a0),d0
    add (a2)+,d0
    move go_y(a0),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop
    
    move.l #.update,go_onUpdate(a0)
.update:
    move go_maxHealth(a0),d0
    sub go_health(a0),d0
    add #SPRFRAME_UNDERGROUND_PAL1_LIMPETKILLERUP,d0
    cmp #SPRFRAME_UNDERGROUND_PAL1_LIMPETKILLERUP_LAST,d0
    blt .fr0
    move #SPRFRAME_UNDERGROUND_PAL1_LIMPETKILLERUP_LAST,d0
.fr0:
    move d0,go_frame(a0)

    rts


UG_InitLimpetMineUp:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_LIMPETMINEUP,go_frame(a0)
    move.l #.first,go_onUpdate(a0)
    
    move #0,go_word0(a0)
    move #8,go_maxHealth(a0)
    move #8,go_health(a0)
    
    move g_ug+ug_limpetMineIndex,d0
    move d0,go_ug_ventHoleIndex(a0)
    lsl #2,d0
    lea g_ug+ug_LimpetMineGOList,a2
    move.l a0,(a2,d0)
    
    add #1,g_ug+ug_limpetMineIndex
    rts
    
    
.first:
    move go_ug_ventHoleIndex(a0),d2
    add #UG_COL_LIMPETMINE_FIRST,d2
    
    lea UG_LimpetMine_ColOffsets,a2
    move #4-1,d3
.colloop:
    move go_x(a0),d0
    add (a2)+,d0
    move go_y(a0),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop
    
    move.l #.update,go_onUpdate(a0)
.update:
    move go_maxHealth(a0),d0
    sub go_health(a0),d0
    add #SPRFRAME_UNDERGROUND_PAL1_LIMPETMINEUP,d0
    cmp #SPRFRAME_UNDERGROUND_PAL1_LIMPETMINEUP_LAST,d0
    blt .fr0
    move #SPRFRAME_UNDERGROUND_PAL1_LIMPETMINEUP_LAST,d0
.fr0:
    move d0,go_frame(a0)

    rts

;-----------------------------------------------------------------------------------------------    

; a1 is particle
UG_InitSteam:
    move ugp_x(a1),d0
    move d0,go_x(a0)
    move ugp_y(a1),d1
    move d1,go_y(a0)
    SETSPR SPRITE_UNDERGROUND_PAL2
    move.l #.update,go_onUpdate(a0)
    move.l #0,go_frame(a0)
    move #SPRFRAME_UNDERGROUND_PAL2_STEAM,go_frame(a0)
    rts
    
.update:
    add.l #$4000,go_frame(a0)
    cmp #SPRFRAME_UNDERGROUND_PAL2_STEAMLAST,go_frame(a0)
    bgt .die
    rts
    
.die:
    jmp GOManager_DeleteObject

;-----------------------------------------------------------------------------------------------    

; a1 is GO
UG_VentHoleHitParticle:


    PUSHALL
    lea UG_InitSteam,a1
    bsr UG_SpawnGameObject_General
    POPALL

    sub #1,go_health(a1)
    bgt .no

    move #0,d2    
    lea UG_VentHole_ColOffsets,a2
    move #4-1,d3
.colloop:
    move go_x(a1),d0
    add (a2)+,d0
    move go_y(a1),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop

    move.l a1,-(sp)
    move.l a1,a0
    lea UG_InitPickupFromVentHole,a1
    bsr UG_SpawnGameObject_HitPlayer
    PSG_PLAY_SFX PSGSFX_UG_VentHoleSpawnPickup

    move go_x(a0),go_x(a1)
    move go_y(a0),go_y(a1)
    add #16,go_x(a1)
    move.l (sp)+,a1


    ; delete the vent hole
    jsr GOManager_DeleteObjectA1 
    rts
.no
    PSG_PLAY_SFX PSGSFX_UG_ParticleHitVentHole

    rts
    
UG_Vent_ColOffsets:
UG_VentHole_ColOffsets:
    dc.w 0,0, 8,0, 16,0, 24,0
    
UG_InitVentHole:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_VENTHOLE,go_frame(a0)
    move.l #.first,go_onUpdate(a0)
    
    move #16,go_maxHealth(a0)
    move #16,go_health(a0)
    
    move g_ug+ug_ventHoleIndex,d0
    move d0,go_ug_ventHoleIndex(a0)
    lsl #2,d0
    lea g_ug+ug_ventHoleGOList,a2
    move.l a0,(a2,d0)
    add #1,g_ug+ug_ventHoleIndex

    add #1,g_ug+ug_totalGems

    rts
    

    
.first:
    move go_ug_ventHoleIndex(a0),d2
    add #UG_COL_VENTHOLE_FIRST,d2
    
    lea UG_VentHole_ColOffsets,a2
    move #4-1,d3
.colloop:
    move go_x(a0),d0
    add (a2)+,d0
    move go_y(a0),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop
    

    move.l #.update,go_onUpdate(a0)
.update:
    move go_maxHealth(a0),d4
    sub go_health(a0),d4
    bgt .no
    move #0,d4 
.no
    lsr #1,d4
    cmp #7,d4
    blt .no1
    move #7,d4
.no1:

    add #SPRFRAME_UNDERGROUND_PAL1_VENTHOLE,d4
    move d4,go_frame(a0)
    rts
    
;-----------------------------------------------------------------------------

; a1 is GO
UG_ChaserHoleHitParticle:
    sub #1,go_health(a1)
    bgt .no

    move #0,d2    
    lea UG_VentHole_ColOffsets,a2
    move #2-1,d3
.colloop:
    move go_x(a1),d0
    add (a2)+,d0
    move go_y(a1),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop

    ; delete the vent hole
    jsr GOManager_DeleteObjectA1 
    ; DIE!    

    move.l a1,-(sp)
    move.l a1,a0
    lea UG_InitChaser,a1
    bsr UG_SpawnGameObject_HitPlayer
    PSG_PLAY_SFX PSGSFX_UG_GenerateChaser

    move go_x(a0),go_x(a1)
    move go_y(a0),go_y(a1)
    add #8,go_x(a1)
    add #8,go_y(a1)
    move.l (sp)+,a1
.no
    rts

UG_InitChaserVentHole:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_KILLABLEVENTHOLE,go_frame(a0)
    move.l #.first,go_onUpdate(a0)
    move #1,go_health(a0)
    
    add #1,g_ug+ug_totalGems

    
    move g_ug+ug_chaserHoleIndex,d0
    move d0,go_ug_ventHoleIndex(a0)
    lsl #2,d0
    lea g_ug+ug_chaserHoleGOList,a2
    move.l a0,(a2,d0)
    add #1,g_ug+ug_chaserHoleIndex

    rts
.first:
    move go_ug_ventHoleIndex(a0),d2
    add #UG_COL_CHASERHOLE_FIRST,d2
    
    lea UG_VentHole_ColOffsets,a2
    move #2-1,d3
.colloop:
    move go_x(a0),d0
    add (a2)+,d0
    move go_y(a0),d1
    add (a2)+,d1
    bsr UG_SetColTile
    dbra d3,.colloop
    
    move.l #.update,go_onUpdate(a0)
.update:
    rts


;-----------------------------------------------------------------------------

; path index in d0
UG_InitPath:
    lsl #2,d0
    move.l sysg_levelInfo+levelinfo_paths,a1
    move.l (a1,d0),a1
    move.w #0,go_cpath+cpath_currentNode(a0)
    move.w (a1)+,go_cpath+cpath_numNodes(a0)
    move.l a1,go_cpath+cpath_firstNodeAddr(a0)
    rts
    

UG_FollowPath:
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
    
    
    move go_speed(a0),d0
    muls d0,d1
    muls d0,d2
    asr.l #8,d1
    asr.l #8,d2
    
    ;lsl.l #1,d2
    ;lsl.l #1,d1
    
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
        
        
    bsr UG_Enemy_UpdateMovementFromDXDY        
        
        
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
    move #0,cpath_currentNode(a2)
    rts
    
UG_Enemy_UpdateMovementFromDXDY:    
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
      
    move.l go_dx(a0),d0    
    add.l d0,go_x(a0)
    ;bsr CommandoIsPlayerColliding
    ;beq .nocolX
    ;move.l go_oldx(a0),go_x(a0)
.nocolX
    move.l go_dy(a0),d0    
    add.l d0,go_y(a0)
    ;bsr CommandoIsPlayerColliding
    ;beq .nocolY
    ;move.l go_oldy(a0),go_y(a0)
.nocolY
    rts


UG_Enemy_UpdateMovementFromDXDY_WithCollision:    
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
      
    move.l go_dx(a0),d0    
    add.l d0,go_x(a0)
    bsr UG_GetColTile_GO
    beq .nocolX
    move.l go_oldx(a0),go_x(a0)
.nocolX
    move.l go_dy(a0),d0    
    add.l d0,go_y(a0)
    bsr UG_GetColTile_GO
    beq .nocolY
    move.l go_oldy(a0),go_y(a0)
.nocolY
    rts

UG_Enemy_UpdateMovementFromDXDY_WithCollisionAndKillable:    
    move.l go_x(a0),go_oldx(a0)
    move.l go_y(a0),go_oldy(a0)
      
    move.l go_dx(a0),d0    
    add.l d0,go_x(a0)
    bsr UG_GetColTile_GO
    beq .nocolX
    cmp #UG_COL_DEATH,d0
    beq .die
    move.l go_oldx(a0),go_x(a0)
.nocolX
    move.l go_dy(a0),d0    
    add.l d0,go_y(a0)
    bsr UG_GetColTile_GO
    beq .nocolY
    cmp #UG_COL_DEATH,d0
    beq .die
    move.l go_oldy(a0),go_y(a0)
.nocolY
    moveq #0,d0
    rts

.die:
    moveq #1,d0
    rts

;-----------------------------------------------------------------------------


UG_CollisionFromFrame:
    move.l go_sprgroup(a0),a1
    move.l sprgroup_coltable_addr(a1),a1
    move go_frame(a0),d0
    lsl #3,d0
    add d0,a1
    move.l a1,go_colliderAddr(a0)
	rts
    
    
UG_InitWallClimberTongue:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    add #3,go_y(a0)
    add #8,go_x(a0)
    move go_x(a0),go_startx(a0)
    move.l a1,go_linkedGO(a0)
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBERTONGUELINK,go_frame(a0)
    move.l #.update_out,go_onUpdate(a0)
    move #0,go_timer(a0)
    move.l #.render,go_onRender(a0)
    
    bsr UG_CollisionFromFrame
    rts
    
.render:
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    ;move go_x(a0),sprbuf_x(a5)    
    ;move go_y(a0),sprbuf_y(a5)    
    ;move go_frame(a0),sprbuf_frame(a5)
    ;bsr .render_doone

    moveq #0,d6
    move go_x(a0),d6
    sub go_startx(a0),d6    ; dist
    swap d6
    asr.l #3,d6             ; dist / 8
    
; get the rot adder across the
    move #0,d1      ; current rot
    move #128/8,d1  ; rot adder    
    
    move go_x(a0),d3
    sub go_startx(a0),d3    ; dist
    move #128,d2     ; max
    sub d3,d2
    bgt .nono
    move #0,d2
.nono:
    lsr #2,d2
    

    move #8-1,d4
    move.l go_startx(a0),d5
    move.l d6,d0
    asr.l #1,d0
    add.l d0,d5     ; add half
.lp:
    move.l d5,d0
    swap d0
    move d0,sprbuf_x(a5)
    move go_y(a0),sprbuf_y(a5)
    
    lea SinCosTable,a1
    move d1,d0
    add #128/8,d1
    lsl #2,d0
    adda d0,a1      ; rot lookup
    
    move (a1),d0
    ext.l d0
    
    muls d2,d0
    
    ;lsl.l #5,d0
    swap d0
    add d0,sprbuf_y(a5)
    
    
    
    
    move #SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBERTONGUELINK,sprbuf_frame(a5)
    tst d4 
    bne .notend
    move #SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBERTONGUE,sprbuf_frame(a5)    
.notend
    bsr .render_doone
    add.l d6,d5
    dbra d4,.lp
    rts

.render_doone:
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    rts


.update_out:
    add.l #$20000,go_x(a0)
    
    bsr UG_GetColTile_GO
    bne .collided_out
    rts
.collided_out:
    move.l #.update_in,go_onUpdate(a0)
    rts

.update_in:
    add.l #-$10000,go_x(a0)
    move go_x(a0),d0
    cmp go_startx(a0),d0
    bgt .r
    move.l go_linkedGO(a0),a1
    move #0,go_timer(a1)
    jmp GOManager_DeleteObject
    
.r:
    rts




;----------------------------------------------------------------------------------------------
UG_InitExplosion:
    SETSPR SPRITE_UNDERGROUND_PAL2
    move #SPRFRAME_UNDERGROUND_PAL2_EXPLOSION,go_frame(a0)
    move #60,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    GO_SET_INVISIBLE
    move g_timer1_and1,d0
    beq .noflash
    GO_SET_VISIBLE
.noflash:
    sub #1,go_timer(a0)
    ble .die
    rts
.die: jmp GOManager_DeleteObject
;----------------------------------------------------------------------------------------------


UG_SingleCall_InitHelpText
   PUSHALL
    move.l g_currentSpawnListAddr,a2
    
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move PARAM_UNDERGROUND_HELPTEXT_TEXT_WIDTH(a1),d2
    lea PARAM_UNDERGROUND_HELPTEXT_TEXT_CHARS(a1),a0

    move spawn_xpos(a2),d0
    lsr #3,d0
    move spawn_ypos(a2),d1
    lsr #3,d1
    bsr UG_WriteTextToRamMap
    
    POPALL
    rts

; a0 is text
; d0 / d1 x,y (chars)
; d2 is max width
UG_WriteTextToRamMap:
    move.l g_ug+ug_m_map,a1
    add d0,d0
    add d0,a1
    lsl #5+1,d1
    add d1,a1

    move g_vram_font,d0
    or.w g_font_cellbits,d0
    or.w #PRIORITY,d0
    
    move #0,d3  ; current pos
    sub #$20,d0
.lp:
    moveq #0,d1		
    move.b	(a0)+,d1	
    beq .end		
    add.w	d0,d1
    move.w  d1,(a1)+
    
    add #1,d3
    cmp d2,d3
    blt .ok 
    move #0,d3
    add #32*2,a1
    sub d2,a1
    sub d2,a1
.ok:
    bra.s	.lp
.end:
    rts

    
    
UG_SingleCall_InitSpike:
    PUSHALL
    move.l g_currentSpawnListAddr,a2
    move spawn_xpos(a2),d0
    move spawn_ypos(a2),d1
    move #UG_COL_DEATH,d2
    
    
    bsr UG_SetColTile
    
    ;lea SpriteVDPOffsets,a1
    ;move #SPRITE_UNDERGROUND_PAL2,d2
    ;add d2,d2
    ;move.w (a1,d2),d2
    ;add #SPRFRAME_UNDERGROUND_PAL2_SPIKE,d2
    
    ;move.l sysg_sprites_baseaddr2,a4    ;lea sprdefs+2,a4
    ;;move #SPRFRAME_UNDERGROUND_PAL2_SPIKE,d1
    ;lsl #2,d1
    ;add d1,a4
    ;move.l (a4),a4		; addr of group

    
    ;or #PAL_2,d2
    
    move spawn_xpos(a2),d0
    move spawn_ypos(a2),d1
    move #UNDERGROUND_SPIKE_VDPINDEX,d2
    bsr UG_SetRamMapTile
    
    POPALL
    rts

UG_InitWallWalkerBelow2:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_WALLWALKER2,go_frame(a0)
    move #0,go_word0(a0)
    bra UG_InitWallWalkerBelow_All

UG_InitWallWalkerBelow:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_WALLWALKER,go_frame(a0)
    move #1,go_word0(a0)
    bra UG_InitWallWalkerBelow_All

UG_InitWallWalkerBelow_All:
    move.l #.update,go_onUpdate(a0)
    
    bsr UG_CollisionFromFrame
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    move.l PARAM_UNDERGROUND_WALLWALKERBELOW_SPEED(a1),go_dx(a0)
    tst PARAM_UNDERGROUND_WALLWALKERBELOW_START_DIRECTION(a1)
    beq .noflip
    neg.l go_dx(a0)
.noflip:    
    move.l go_dx(a0),go_long0(a0)   ;save it
    rts
    
.frames:
    dc.w SPRFRAME_UNDERGROUND_PAL1_WALLWALKER
    dc.w SPRFRAME_UNDERGROUND_PAL1_WALLWALKER1
    
.update:
    tst go_word0(a0)
    beq .noanim
    move g_timer1_shr4_and1,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
.noanim

; check left / right
    move.l go_x(a0),d0
    add.l go_dx(a0),d0
    swap d0
    move go_y(a0),d1
    sub #4,d1
    bsr UG_GetColTile
    beq .ok_move
    neg.l go_dx(a0)

.ok_move:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    
    move go_x(a0),d0
    move go_y(a0),d1
    add #4,d1
    bsr UG_GetColTile
    bne .ok
    neg.l go_dx(a0)
.ok:
.r:  rts


UG_InitWallWalkerAbove:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_WALLWALKERTOP,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    move.l PARAM_UNDERGROUND_WALLWALKERABOVE_SPEED(a1),go_dx(a0)
    tst PARAM_UNDERGROUND_WALLWALKERABOVE_START_DIRECTION(a1)
    beq .noflip
    neg.l go_dx(a0)
.noflip:    
    rts
    
.update:

; check left / right
    move.l go_x(a0),d0
    add.l go_dx(a0),d0
    swap d0
    move go_y(a0),d1
    add #4,d1
    bsr UG_GetColTile
    beq .ok_move
    neg.l go_dx(a0)

.ok_move:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    
    move go_x(a0),d0
    move go_y(a0),d1
    sub #4,d1
    bsr UG_GetColTile
    bne .ok
    neg.l go_dx(a0)
.ok:
.r:  rts



go_ug_wallclimber_range0 equ go_word0
go_ug_wallclimber_range1 equ go_word1
go_ug_wallclimber_facing equ go_word2
UG_InitWallClimber:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBER,go_frame(a0)
    move.l #.first,go_onUpdate(a0)
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    move #1,go_rot(a0)  ; 0 and 1 for up and down, this time
    rts
    
.first:
    move.l go_params_addr(a0),a1
    
    move PARAM_UNDERGROUND_WALLCLIMBER_FACING(a1),go_ug_wallclimber_facing(a0)
    move PARAM_UNDERGROUND_WALLCLIMBER_SHOTTIME(a1),go_shoot_timerMax(a0)
    move go_shoot_timerMax(a0),go_shootTimer(a0)
    
    lea PARAM_UNDERGROUND_WALLCLIMBER_CLIMBRANGE(a1),a1
    move 2(a1),d0
    add go_y(a0),d0
    move d0,go_ug_wallclimber_range0(a0)

    move 6(a1),d0
    add go_y(a0),d0
    move d0,go_ug_wallclimber_range1(a0)
    
    move #0,go_sprAttributes(a0)
    tst go_ug_wallclimber_facing(a0)
    bne .startright
    move #FLIP_H,go_sprAttributes(a0)
.startright:

    move.l #.update,go_onUpdate(a0)
    rts
.update:
    bsr .animate

    move go_rot(a0),d0
    lsl #2,d0
    move.l .speeds(pc,d0),d0
    add.l d0,go_y(a0)
    
    move go_y(a0),d0
    cmp go_ug_wallclimber_range1(a0),d0
    blt .notbottom
    move go_ug_wallclimber_range1(a0),go_y(a0)
    move #0,go_rot(a0)
.notbottom:

    move go_y(a0),d0
    cmp go_ug_wallclimber_range0(a0),d0
    bgt .nottop
    move go_ug_wallclimber_range0(a0),go_y(a0)
    move #1,go_rot(a0)
.nottop:
    
    sub #1,go_shootTimer(a0)
    bgt .noshoot
    move go_shoot_timerMax(a0),go_shootTimer(a0)
    
    lea UG_InitWallClimberTongue,a1
    bsr UG_SpawnGameObject_HitPlayer
    
    move #64,go_timer(a0)
    move.l #.update_wait,go_onUpdate(a0)
    move #SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBER2,go_frame(a0)
.noshoot:
     rts
 
 .update_wait:      ; waits for shot object to set timer to 0
    cmp #0,go_timer(a0)
    bgt .r
    move.l #.update,go_onUpdate(a0) 
 .r: rts
     
 .animate:
    move g_timer1_shr4_and1,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    rts
     
 .speeds:
    dc.l -$4000,$4000

.frames:
    dc.w SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBER,SPRFRAME_UNDERGROUND_PAL1_WALLCLIMBER1


;-----------------------------------------------------------------------------

UG_InitPickupFromVentHole:
    bsr UG_InitPickup_All
    move.l #$30000,go_dy(a0)
    move.l #.update,go_onUpdate(a0)
    move #30,go_timer(a0)
.update:
    sub.l #$1c00,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    bsr UG_InitPickup_Update
    
    cmp #0,go_dy(a0)
    blt .stop
    rts
    
.stop:
    move.l #UG_InitPickup_Update,go_onUpdate(a0)
    rts
    
UG_InitPickupFromChaser:
    move go_oldx(a1),go_x(a0)
    move go_oldy(a1),go_y(a0)
    bsr UG_InitPickup_All
    rts
    
.stop:
    move.l #UG_InitPickup_Update,go_onUpdate(a0)
    rts
    
UG_InitPickup:
    add #1,g_ug+ug_totalGems
    bra UG_InitPickup_All

UG_InitPickup_All:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_PICKUP1,go_frame(a0)
    move.l #UG_InitPickup_Update,go_onUpdate(a0)
    
    move.l #.collided,go_onCollided(a0)
    move.b #1,go_coltype(a0)
    move.l #.collision,go_colliderAddr(a0)
    rts
.collision:
    dc.w -16,16,-16,16
    
    
 .collided:
    add #1,g_ug+ug_numGemsCollected  


    add.l #10,sysg_score
    jsr Title_TestHighScore

   	PSG_PLAY_SFX PSGSFX_UG_GetPickup

    move.l #.collided_update,go_onUpdate(a0)
    move #20,go_timer(a0)
    move.l #0,go_onCollided(a0)
    rts
    
.collided_update:
    sub #1,go_timer(a0)
    ble .die
    move.l g_player,a1
    move.l go_x(a1),d0
    sub.l go_x(a0),d0
    asr.l #3,d0
    add.l d0,go_x(a0)
    move.l go_y(a1),d0
    sub.l go_y(a0),d0
    asr.l #3,d0
    add.l d0,go_y(a0)
    
    rts    
.die:    jmp GOManager_DeleteObject

    
UG_InitPickup_Update:
    move g_timer1_shr3,d0
    and #$3<<1,d0
    move UG_Pickup_Attrs(pc,d0),go_sprAttributes(a0)
    rts
     
UG_Pickup_Attrs:
    dc.w 0,FLIP_H,FLIP_HV,FLIP_V
     
     
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------    

UG_InitChaser:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_CHASER,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    
    move #60*10,go_timer(a0)
    bsr UG_CollisionFromFrame    
    move #$0,go_speed(a0)
    rts

.update:

    move.l g_player,a1
        
    move go_x(a0),go_oldx(a0)
    move go_y(a0),go_oldy(a0)
        
    move go_x(a1),d0
    sub.w go_x(a0),d0
    move go_y(a1),d1
    sub.w go_y(a0),d1
    jsr GetAtan2
    move d2,d0
    jsr GOTOOLS_GetMovementVecFromRot
    
    add #4,go_speed(a0)
    cmp #$140,go_speed(a0)
    blt .okspeed
    move #$140,go_speed(a0)
.okspeed
    move go_speed(a0),d0
    muls d0,d1
    muls d0,d2
    asr.l #8,d1
    asr.l #8,d2
    move.l d2,go_dx(a0)
    move.l d1,go_dy(a0)
    bsr UG_Enemy_UpdateMovementFromDXDY_WithCollisionAndKillable      
    bne .die
    
    ;GO_SET_VISIBLE
    ;sub #1,go_timer(a0)
    ;ble .die
    ;cmp #60*2,go_timer(a0)
    ;bgt .r
    ;move go_timer(a0),d0
    ;and #4,d0
    ;beq .r
    ;GO_SET_INVISIBLE
.r
   rts
.die:
    lea UG_InitPickupFromChaser,a1
    bsr UG_SpawnGameObject_HitPlayer
    
    PSG_PLAY_SFX PSGSFX_UG_ChaserDie

    jmp GOManager_DeleteObject
;-----------------------------------------------------------------------------------------------    


UG_InitEnemyBat:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_BAT0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    move.l PARAM_UNDERGROUND_ENEMYBAT_SPEED(a1),d0
    lsr.l #8,d0
    move d0,go_speed(a0)            ; long 16:16 down to word 8:8

    move PARAM_UNDERGROUND_ENEMYBAT_INITIALPATH(a1),d0
    blt .init_stationary
    bsr UG_InitPath
    
    rts

.init_stationary:
     move.l #.update_stationary,go_onUpdate(a0)
     rts
.update_stationary:
    bsr .doanim
    rts

.update:
    bsr UG_FollowPath
    bsr .doanim
    rts
.doanim:
    move g_timer1_shr4,d0
    and #3,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
    
    bsr UG_CollisionFromFrame
    rts
    
.frames dc.w SPRFRAME_UNDERGROUND_PAL1_BAT0,SPRFRAME_UNDERGROUND_PAL1_BAT1,SPRFRAME_UNDERGROUND_PAL1_BAT2,SPRFRAME_UNDERGROUND_PAL1_BAT1

;-----------------------------------------------------------------------------

UG_InitEnemyAcidGenerator:
    SETSPR SPRITE_UNDERGROUND_PAL2
    move #SPRFRAME_UNDERGROUND_PAL2_ACIDGENERATOR,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    move PARAM_UNDERGROUND_ACIDGENERATOR_FREQUENCY(a1),go_timer(a0)
    
    rts
.update:
    sub #1,go_timer(a0)
    ble .gen
    rts        
        
.gen:
    
    lea UG_InitEnemyAcid,a1
    jsr UG_SpawnGameObject_HitPlayer
    move.l go_params_addr(a0),a1
    move PARAM_UNDERGROUND_ACIDGENERATOR_FREQUENCY(a1),go_timer(a0)
    rts

UG_InitEnemyAcid:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    add #8,go_x(a0)
    add #8,go_y(a0)

    SETSPR SPRITE_UNDERGROUND_PAL2
    move #SPRFRAME_UNDERGROUND_PAL2_ACIDFORM,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #0,go_dy(a0)
    rts
.update:
    cmp #SPRFRAME_UNDERGROUND_PAL2_ACIDDROP,go_frame(a0)
    bge .nofr
    add.l #$2000,go_frame(a0)
.nofr:

    bsr UG_CollisionFromFrame

    add.l #$1000,go_dy(a0)
    cmp.l #$20000,go_dy(a0)
    blt .nomaxy
    move.l #$20000,go_dy(a0)
.nomaxy:
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    bsr UG_GetColTile_GO
    bne .hitfloor
    rts
    
.hitfloor:
    move.l #0,go_colliderAddr(a0)
    move.l #.update_splash,go_onUpdate(a0)
    move #SPRFRAME_UNDERGROUND_PAL2_ACIDSPLASH,go_frame(a0)
.update_splash:
    add.l #$2000,go_frame(a0)
    cmp #SPRFRAME_UNDERGROUND_PAL2_10+1,go_frame(a0)
    bge .nosplashfr
    rts
.nosplashfr:
    GO_SET_INVISIBLE
    jmp GOManager_DeleteObject

    
;-----------------------------------------------------------------------------
  
    
UG_InitEnemyJumper:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_ENEMY_JUMPER,go_frame(a0)
    
    lea .frames1,a1
    move g_ug+ug_spawnCount,d0
    and #1,d0
    beq .fr0
    lea .frames2,a1
.fr0:
    move.l a1,go_long0(a0)
    
    move.l #.first,go_onUpdate(a0)
    
    move.l g_currentSpawnListAddr,a2
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move.l a1,go_params_addr(a0)
    
    bsr UG_CollisionFromFrame

    rts
.first:
    move.l go_y(a0),go_toy(a0)
    
.initstate_waiting:
    move.l go_long0(a0),a1
    move 0(a1),go_frame(a0)
    move.l #.update_waiting,go_onUpdate(a0)
    move.l #0,go_dy(a0) 
    move.l go_params_addr(a0),a1
    move PARAM_UNDERGROUND_ENEMYJUMPER_WAITTIME(a1),go_timer(a0)
    rts
.frames1:
    dc.w SPRFRAME_UNDERGROUND_PAL1_ENEMY_JUMPER,SPRFRAME_UNDERGROUND_PAL1_ENEMY_JUMPER1
.frames2:
    dc.w SPRFRAME_UNDERGROUND_PAL1_ENEMY_JUMPERB,SPRFRAME_UNDERGROUND_PAL1_ENEMY_JUMPERB1
    
    
    
.update_waiting:

    sub #1,go_timer(a0)
    bgt .rts
    move.l go_params_addr(a0),a1
    move.l PARAM_UNDERGROUND_ENEMYJUMPER_JUMPSPEED(a1),d0
    neg.l d0
    move.l d0,go_dy(a0)
    move.l #.update_jumping,go_onUpdate(a0)
    move.l go_long0(a0),a1
    move 2(a1),go_frame(a0)
    rts
    
.update_jumping    
    add.l #$1000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)

    move go_y(a0),d0
    cmp go_toy(a0),d0
    blt .rts
    move.l go_toy(a0),go_y(a0)
    
    bsr .initstate_waiting
   
.rts
    rts

UG_InitVent:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_VENT,go_frame(a0)
    move.l #.first,go_onUpdate(a0)    
    
    move #0,go_word0(a0)
    
    rts
    
.first:
    lea UG_Vent_ColOffsets,a2
    move #4-1,d3
.colloop:
    move go_x(a0),d0
    add (a2)+,d0
    move go_y(a0),d1
    add (a2)+,d1
    move #UG_COL_WALL,d2
    bsr UG_SetColTile
    dbra d3,.colloop
    move.l #.update,go_onUpdate(a0)    
    
.update:
    move g_timer1,d0
    and #7,d0
    bne .nospawn
    bsr UG_AddParticleFromGO
    
    add #1,go_word0(a0)
    and #3,go_word0(a0)
.nospawn:
    rts

;------------------------------------------------------------------------------
UG_InitBlower:
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_FIREBAT0,go_frame(a0)
    move.l #.update,go_onUpdate(a0)
 
    move.l #$4000,go_dx(a0)
    move #180,go_timer(a0)

    bsr UG_CollisionFromFrame
    
    move.l g_currentSpawnDataAddr,a1
    move.l (a1),a1
    move PARAM_UNDERGROUND_BLOWER_INITIALDIR(a1),d0
    bne .nostartflip
    neg.l go_dx(a0)
.nostartflip:
    
    bsr .setflowdir
    rts
    
.frames:
    dc.w SPRFRAME_UNDERGROUND_PAL1_FIREBAT0
    dc.w SPRFRAME_UNDERGROUND_PAL1_FIREBAT1
    dc.w SPRFRAME_UNDERGROUND_PAL1_FIREBAT2
    dc.w SPRFRAME_UNDERGROUND_PAL1_FIREBAT1


.update:
    move g_timer1_shr2,d0
    and #3<<1,d0
    move .frames(pc,d0),go_frame(a0)

    bsr UG_WriteBlowerToFlowMap
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    sub #1,go_timer(a0)
    ble .done
    rts    
    
.done:
    neg.l go_dx(a0)
    move #180,go_timer(a0)
    
.setflowdir:
    move.b #96,go_word0(a0)
    tst go_dx(a0)
    bge .no
    move.b #32,go_word0(a0)
.no
    
 

    ;bsr UG_WritePlayerToFlowMap

    rts
    
UG_WriteBlowerToFlowMap:

    move.b go_word0(a0),d3   
         
    lea .offsets,a2
    move #15-1,d5
.lp:
    move (a2)+,d0
    move (a2)+,d1
    asl #3,d0
    asl #3,d1
    add go_x(a0),d0
    add go_y(a0),d1
    bsr .writeval
    dbra d5,.lp
    
    rts
.offsets:
    dc.w -2,0,-1,0,0,0,1,0,2,0
    dc.w -2,1,-1,1,0,1,1,1,2,1
    dc.w -2,-1,-1,-1,0,-1,1,-1,2,-1
.writeval:
    move.l g_ug+ug_m_flowMap,a1
    lsr #3,d0
    add d0,a1
    lsr #3,d1
    lsl #5,d1
    add d1,a1
    move.b d3,(a1)
    rts    
    
;------------------------------------------------------------------------------

FLY_WALKVEL equ $4000
FLY_ACCELX equ $800
FLY_DECELX equ $200
FLY_FLAP_DY equ -$8000
FLY_MAXDX equ $10000

FLY_MAXDY equ $10000
FLY_MINDY equ -$10000
FLY_GRAVITY equ $400

go_ugplayer_flaptimer equ go_word0
go_ugplayer_onground equ go_word1

UG_Player_InitDie:
    PSG_PLAY_SFX PSGSFX_UG_Die

    tst.b sysg_cheatmode
    beq .nocheat
    rts
.nocheat:
    move go_sprAttributes(a0),d0
    eor #FLIP_V,d0
    move d0,go_sprAttributes(a0)
    move.l #0,go_onCollided(a0)
    move #100,go_timer(a0)
    move.l #.update_dead,go_onUpdate(a0)
.update_dead:

    move g_timer1,d0
    and #3,d0
    bne .noparticle
    lea UG_InitPlayerFeather,a1
    bsr UG_SpawnGameObject_General
.noparticle:

    add #$1,go_y(a0)
    sub #1,go_timer(a0)
    beq .finally_dead
    rts
.finally_dead:
    move.b #1,g_ug+ug_levelOverFlag
    rts
    
UG_InitPlayerFeather:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_FEATHERS0,go_frame(a0)
    move #30,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    
    jsr UTILS_GetRandWordFast
    and #3,d0
    add #SPRFRAME_UNDERGROUND_PAL1_FEATHERS0,d0
    move d0,go_frame(a0)
    
    jsr UTILS_GetRandWordFast
    and #15,d0
    swap d0
    lsr.l #2,d0
    sub.l #$20000,d0
    move.l d0,go_dy(a0)

    jsr UTILS_GetRandWordFast
    move d0,d1
    and #15,d1
    swap d1
    asr.l #3,d1
    
    
    jsr UTILS_GetRandWordFast
    and #1,d0
    beq .noflip
    neg.l d1
.noflip:
    move.l d1,go_dx(a0)
    
    

        
    rts
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    add.l #$800,go_dy(a0)

    sub #1,go_timer(a0)
    ble .die
    rts
.die jmp GOManager_DeleteObject
    
    
UG_InitPlayerFlapParticle:
    move go_x(a1),go_x(a0)
    move go_y(a1),go_y(a0)
    move.l go_dx(a1),d0
    neg.l d0
    move.l d0,go_dx(a0)
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #SPRFRAME_UNDERGROUND_PAL1_FEATHERS0,go_frame(a0)
    move #30,go_timer(a0)
    move.l #.update,go_onUpdate(a0)
    
   
    
    move.l #0,go_dy(a0)

    jsr UTILS_GetRandWordFast
    move d0,d1
    and #7,d0
    add #SPRFRAME_UNDERGROUND_PAL1_FLAP,d0
    move d0,go_frame(a0)
    
    and #FLIP_H|FLIP_V,d1
    move d1,go_sprAttributes(a0)    
    
        
    rts
.update:
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    add.l #$800,go_dy(a0)

    sub #1,go_timer(a0)
    ble .die
    rts
.die jmp GOManager_DeleteObject

    
   
UG_UpdatePlayer_Walk:
    move.l #0,go_dx(a0)
    move g_pad0,d0
    btst #pad_button_left,d0
    beq .noL
    move.l #-FLY_WALKVEL,go_dx(a0)
    move #FLIP_H,go_sprAttributes(a0)
.noL:
    btst #pad_button_right,d0
    beq .noR
    move.l #FLY_WALKVEL,go_dx(a0)
    move #0,go_sprAttributes(a0)
.noR:

.skipmove:
    move g_pad0_pressed,d0
    btst #pad_button_a,d0
    beq .no_a
    add.l #FLY_FLAP_DY,go_dy(a0)
    PSG_PLAY_SFX PSGSFX_UG_Flap
    move #10,go_ugplayer_flaptimer(a0)
    

.no_a:

    rts
        
UG_PlayerUpdateInEndSequence:
    move.l #0,go_onCollided(a0)
    rts
        
        
UG_InitPlayer:
    move.l a0,g_player
    SETSPR SPRITE_UNDERGROUND_PAL1
    move #0,go_frame(a0)
    move #10*16,go_x(a0)
    move #30*16,go_y(a0)

    move #0,go_ugplayer_flaptimer(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.collided,go_onCollided(a0)
    
    
    rts
    
.collided:
    tst.b go_coltype(a1)    ; pickup?
    bne .ispickup
    
    
    bra UG_Player_InitDie

.ispickup:  
    rts
    

    
.update:

    move #0,go_ugplayer_onground(a0)    ; on ground?

    move go_x(a0),d0
    move go_y(a0),d1
    add #1,d1
    bsr UG_GetColTile
    beq .notonfloor
    bsr UG_UpdatePlayer_Walk
    move #1,go_ugplayer_onground(a0)    ; on ground?
    bra .skipmove
    
.notonfloor:
    move g_pad0,d0
    btst #pad_button_left,d0
    beq .noL
    add.l #-FLY_ACCELX,go_dx(a0)
    move #FLIP_H,go_sprAttributes(a0)
.noL:
    btst #pad_button_right,d0
    beq .noR
    add.l #FLY_ACCELX,go_dx(a0)
    move #0,go_sprAttributes(a0)
.noR:

.skipmove:
    move g_pad0_pressed,d0
    btst #pad_button_a,d0
    beq .no_a
    add.l #FLY_FLAP_DY,go_dy(a0)
    
    lea UG_InitPlayerFlapParticle,a1
    bsr UG_SpawnGameObject_General

   	PSG_PLAY_SFX PSGSFX_UG_Flap

    move #10,go_ugplayer_flaptimer(a0)
.no_a:

    ifd IS_DEBUG_MODE
    move g_pad0_pressed,d0
    btst #pad_button_b,d0
    beq .no_b
    move.b #1,g_ug+ug_debugNextLevelFlag
.no_b:
    endif

    move g_pad0,d0
    and #padmask_button_left|padmask_button_right,d0
    bne .decel_done
    
    tst.l go_dx(a0)
    blt .decel_x0
.decel_x1:
    sub.l #FLY_DECELX,go_dx(a0)
    bgt .decel_done
    move.l #0,go_dx(a0)
    bra .decel_done
    
.decel_x0:
    add.l #FLY_DECELX,go_dx(a0)
    blt .decel_done
    move.l #0,go_dx(a0)
.decel_done
    
    
    cmp.l #FLY_MAXDX,go_dx(a0)
    blt .okmaxdx
    move.l #FLY_MAXDX,go_dx(a0)
.okmaxdx 
    cmp.l #-FLY_MAXDX,go_dx(a0)
    bgt .okmaxdx1
    move.l #-FLY_MAXDX,go_dx(a0)
.okmaxdx1 
    
    move.l go_x(a0),d3     ; prev
            
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    move go_x(a0),d0
    move go_y(a0),d1
    bsr UG_GetColTile
    beq .okx
    cmp #UG_COL_DEATH,d0
    beq .hitdeath
    move.l #0,go_dx(a0)
    move.l d3,go_x(a0)
.okx:
    
    add.l #FLY_GRAVITY,go_dy(a0)
    cmp.l #FLY_MAXDY,go_dy(a0)
    blt .okmaxdy
    move.l #FLY_MAXDY,go_dy(a0)
.okmaxdy
    cmp.l #FLY_MINDY,go_dy(a0)
    bgt .okmaxdy1
    move.l #FLY_MINDY,go_dy(a0)
.okmaxdy1 
    
    move.l go_y(a0),d3     ; prev
            
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    move go_x(a0),d0
    move go_y(a0),d1
    bsr UG_GetColTile
    beq .oky
    cmp #UG_COL_DEATH,d0
    beq .hitdeath
    move.l d3,go_y(a0)
    move.l #0,go_dy(a0)
.oky:
    
    
    move.l go_y(a0),d0
    sub.l #112<<16,d0
    bge .ok1
    move.l #0,d0
.ok1:
    move.l d0,g_scroll_y
    cmp #(64-28)*8,g_scroll_y
    blt .ok2
    move #(64-28)*8,g_scroll_y
.ok2:
    
    
    move #1,go_frame(a0)
    sub #1,go_ugplayer_flaptimer(a0)
    bgt .noflapframe
    move #0,go_ugplayer_flaptimer(a0)
    move #0,go_frame(a0)
.noflapframe:

    tst go_ugplayer_onground(a0) 
    beq .notong
    bsr .walkanim
    
.notong:

    bsr UG_WritePlayerToFlowMap
    rts
.hitdeath:
    bra UG_Player_InitDie
    

.walkanim:    
    move #SPRFRAME_UNDERGROUND_PAL1_FIREBIRDWALK1,go_frame(a0)
    tst.l go_dx(a0)
    beq .rts
    move g_timer1,d0
    lsr #4,d0
    and #1,d0
    add d0,d0
    move .frames(pc,d0),go_frame(a0)
.rts
    rts

  
.frames:
    dc.w SPRFRAME_UNDERGROUND_PAL1_FIREBIRDWALK0
    dc.w SPRFRAME_UNDERGROUND_PAL1_FIREBIRDWALK1

    
    
UG_InitVDPForLevel:
    jsr ClearVRAM

    lea SPRPAL_Underground_Pal1,a0
    move #1,d0
    jsr FADE_CopySinglePaletteToSource
    lea SPRPAL_Underground_Pal2,a0
    move #2,d0
    jsr FADE_CopySinglePaletteToSource


	move #0,g_vram_currentpos
    ;jsr Image_AddBlankCharacterToVDP

    
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
	
	
    move #IMAGEASSET_UNDERGROUND_BG0,d0
    jsr IMAGE_ShowStaticImagePlaneB32

    bsr UG_InitBackgroundTiles

    rts
    
.sprites:
    dc.w SPRITE_UNDERGROUND_PAL1_TILESPRITES
    dc.w SPRITE_UNDERGROUND_PAL1
    dc.w SPRITE_UNDERGROUND_PAL2
    dc.w SPRITE_UNDERGROUND_PAL1_HUD
    dc.w -1


UG_InitBackgroundTiles:

    move g_vram_currentpos,g_vram_bg
    
    move.l sysg_levelInfo+levelinfo_palette0,a0 
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


; set up addr of tiles in ROM
;	move g_image_index,d0
;	move.l g_image_groupbase,a0	
;	jsr UNITYTOOL_GetImageData
;	move.l image_cells(a0),g_hol_romTileMapAddr

    rts


UG_UpdateLevelOverSequence:
    cmp #2,g_ug+ug_inLevelOverSequence
    beq .no
    
    sub #1,g_ug+ug_levelOverSequenceTimer
    bgt .no
    
    PSG_PLAY_SFX PSGSFX_UG_TimerBonus

    move g_ug+ug_levelOverSequenceTimerMax,g_ug+ug_levelOverSequenceTimer
    
    sub #1,g_ug+ug_levelOverSequenceTimerMax
    cmp #2,g_ug+ug_levelOverSequenceTimerMax
    bgt .nomin
    move #2,g_ug+ug_levelOverSequenceTimerMax
.nomin:
    
    add.l #10,sysg_score
    jsr Title_TestHighScore

    sub #1,g_ug+ug_timer_seconds
    bge .no
    
    move #0,g_ug+ug_timer_seconds
    
    move #2,g_ug+ug_inLevelOverSequence
    move.l #InitState_LevelOver,sysg_next_screen_addr_after_fade
    jsr SCENETRANSITION_FadeOut
    
.no:
    rts
    

UG_UpdateGame:
    jsr UTILS_GetRandWord
    bsr UG_UpdateGame_UpdateGlobals
    bsr UG_UpdateGame_Normal      
    
    jsr Game_UpdateRealtimeCommands      

    tst g_ug+ug_inLevelOverSequence
    beq .noleveloverseq
    bsr UG_UpdateLevelOverSequence
    bra .nogems

.noleveloverseq:
    move g_ug+ug_numGemsCollected,d0
    ;ble .nogems
    cmp g_ug+ug_totalGems,d0
    blt .nogems
    
    move #0,g_ug+ug_levelOverSequenceTimer
    move #1,g_ug+ug_inLevelOverSequence
    move #20,g_ug+ug_levelOverSequenceTimerMax
    
    move.l g_player,a1
    move.l #UG_PlayerUpdateInEndSequence,go_onUpdate(a1)
    
    rts
    
.nogems:
  
    tst.b g_ug+ug_levelOverFlag
    beq .nolevelover

    bsr UG_ResetLevelScore
    move.l #InitState_GameOver,sysg_next_screen_addr_after_fade
    move #0,sysg_next_screen_data
    jsr SCENETRANSITION_FadeOut
.nolevelover:

    tst.b g_ug+ug_debugNextLevelFlag
    beq .nonextlevel
     bsr UG_NextLevel
        bsr UG_ResetForRealtimeCommand
.nonextlevel:
  
    rts
    
UG_UpdateGame_InitGlobals:
    move.l #0,g_timer1
    move.l #0,g_timer0175
    move.l #0,g_timer025
    move.l #0,g_timer008
    move.l #0,g_timer05
    rts
UG_UpdateGame_UpdateGlobals:
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

    

UG_UpdateGame_Normal:
    bsr Racing_UpdateScreenShake
    move.l g_scroll_x,g_scroll_oldx
    move.l g_scroll_y,g_scroll_oldy

    jsr GOManager_Update
    
    bsr UG_PlayerObjectCollision
    
    BORDER 0
    BORDER 0
    bsr UG_UpdateParticles
    BORDER 0
    bsr UG_UpdateFlowMap
    BORDER 0
    bsr UG_CopyBGToRamScreen
    bsr UG_RenderParticlesToRamScreen
    BORDER 0
	jsr SPRITE_UpdateFromGOManager_Racing
	BORDER 0
	
	bsr UG_UpdateTimers
	
    rts

UG_UpdateTimers:
    tst g_ug+ug_inLevelOverSequence
    bne .no

    sub #1,g_ug+ug_timer_subseconds
    bgt .nosub
    sub #1,g_ug+ug_timer_seconds
    bgt .nosub1
    move #0,g_ug+ug_timer_seconds
    move #0,g_ug+ug_timer_subseconds
    
    bsr UG_ResetLevelScore

    move.l #InitState_GameOver,sysg_next_screen_addr_after_fade
    move #1,sysg_next_screen_data
    jsr SCENETRANSITION_FadeOut

    bra .nosub
.nosub1:
    move #60,g_ug+ug_timer_subseconds
.nosub:
    rts

.no:
    rts


UG_UpdateVBL:	
    move #0,RamPalettes    
	jsr FADE_Update	
	jsr SPRITE_CopySpriteListToVRAM_DMA
    bsr UG_UpdateScrollRegisters

    bsr UG_SpikeAnimation

    bsr UG_DMARamScreenA
	rts


UG_TILE_SPIKE equ 36	
UG_SpikeAnimation:
    
    lea SPRDEF_Underground_Pal1_TileSprites+4,a0
    
    move g_timer1_shr3,d0
    and #3,d0
    add #4,d0
    lsl #5,d0
    add d0,a0
        
    move #UNDERGROUND_SPIKE_VDPINDEX,d1
    lsl #5,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	

    bsr UG_UploadChar
    rts
    
UG_UploadChar:
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	rts
    

;-------------------------------------------------------------


UG_UpdateScrollRegisters:

	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_FULL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL
    
    AUTOINC 2
; hscroll
	
	move #0,d0
	SCROLL_START_WRITE_XPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
    AUTOINC 2
    move g_scroll_y,d0
    and #7,d0
    
    move g_scroll_y,d1
    lsr #1,d1
    
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d1,VDP_DATA
	rts

    
    
UG_DMARamScreenA:
	move.l g_ug+ug_m_ramscreen,d0
	move.l #VDPADDR_SCROLL_A,d1
	move.l #32*32*2,d2
	move #2,d3
	jsr VDP_SetDMA
	rts

UG_CopyBGToRamScreen:
    move.l g_ug+ug_m_ramscreen,a1
    move.l g_ug+ug_m_map,a0

    move g_scroll_y,d0
    lsr #3,d0
    lsl #5+1,d0     
    add d0,a0                   ; always 32 chars wide

; 32*32 = 2048

    rept 36     ;39 for nearly 2048. This is more like 29 rows, all we need
    movem.l (a0),d0-d7/a2-a6        ;8+5 = 13. 13*4 =52 bytes 
    movem.l d0-d7/a2-a6,(a1)        ;8+5 = 13. 13*4 =52 bytes
    lea 52(a0),a0 
    lea 52(a1),a1 
    endr
    rts
    
;---------------------------------------------------------------------------------

UG_WritePlayerToFlowMap:
    move.l g_player,a0
    
    move.l go_dx(a0),d0
    add.l #FLY_MAXDX,d0
    
    asr.l #8,d0
    asr.l #2,d0
    move.l d0,d3
    
    lea .offsets,a2
    move #9-1,d5
.lp:
    move go_x(a0),d0
    move go_y(a0),d1
    add (a2)+,d0
    add (a2)+,d1
    bsr .writeval
    dbra d5,.lp
    
    rts
.offsets:
    dc.w -8,-8,0,-8,8,-8
    dc.w -8,0,0,0,8,0
    dc.w -8,8,0,8,8,8
    
    
.writeval:
    move.l g_ug+ug_m_flowMap,a1
    lsr #3,d0
    add d0,a1
    lsr #3,d1
    lsl #5,d1
    add d1,a1
    move.b d3,(a1)
    rts
    
    
    
    

UG_InitFlowMap:
    move.l sysg_levelInfo+levelinfo_flowMap,a0
    lea 4(a0),a0
    move.l g_ug+ug_m_flowMap,a1
    
    
    move #UG_FLOWMAP_SIZE-1,d1
.lp:
    moveq #0,d0
    move.b (a0)+,d0
    ; convert to 0-128 left to right. no downward.
    add.b #64,d0
    move.b d0,(a1)+
    dbra d1,.lp
    move #0,g_ug+ug_flowmapUpdateIndex
    rts
    
; gradually move flowmap ram version back to normal
UG_FLOWMAP_NUMPERFRAME equ 32
UG_UpdateFlowMap:
    move.l g_ug+ug_m_flowMap,a1
    move.l sysg_levelInfo+levelinfo_flowMap,a0
    lea 4(a0),a0
    move g_ug+ug_flowmapUpdateIndex,d0
    add d0,a0
    add d0,a1
    
    move #UG_FLOWMAP_NUMPERFRAME-1,d7
.lp:
    moveq #0,d0
    moveq #0,d1
    move.b (a0)+,d0
    add #64,d0
    move.b (a1),d1
    add d0,d1
    lsr #1,d1
    move.b d1,(a1)+
    
    dbra d7,.lp
    
    move g_ug+ug_flowmapUpdateIndex,d0
    add #UG_FLOWMAP_NUMPERFRAME,d0
    cmp #UG_FLOWMAP_SIZE,d0
    blt .noreset
    move #0,d0
.noreset:
    move d0,g_ug+ug_flowmapUpdateIndex
    rts
    
;---------------------------------------------------------------------------------

;---------------------------------------------------------------------------------

UG_InitRamMap:
    move.l g_ug+ug_m_map,a1
    move.l sysg_levelInfo+levelinfo_tileMap0,a0
    lea 6(a0),a0
;    move #UG_MAP_SIZE,d0
;    jsr UTILS_Copy
    
    move g_vram_bg,d0
    move #(UG_MAP_SIZE/2)-1,d7
.lp:
    move (a0)+,d1
    add d0,d1
    move d1,(a1)+
    dbra d7,.lp
    
    rts

;---------------------------------------------------------------------------------

UG_TILEMAP_BLANK equ 4

    clrso
UG_COL_EMPTY so.b 1
UG_COL_WALL so.b 1
UG_COL_DEATH so.b 1
UG_COL_VENTHOLE_FIRST so.b 7
UG_COL_VENTHOLE_LAST so.b 1
UG_COL_CHASERHOLE_FIRST so.b 7
UG_COL_CHASERHOLE_LAST so.b 1
UG_COL_LIMPETMINE_FIRST so.b 7
UG_COL_LIMPETMINE_LAST so.b 1

UG_InitCollisionMap:

    move.l g_ug+ug_m_map,a0
    move #UG_COLMAP_SIZE-1,d7
    move #0,d1
.lp1:
    move (a0)+,d0
    and #$3ff,d0
    cmp d1,d0
    ble .ok1
    move d0,d1
.ok1:
    dbra d7,.lp1
    
    ;d1 is blank?
    
    move d1,g_ug+ug_blank_tile


    move.l g_ug+ug_m_collisionMap,a1
    move.l g_ug+ug_m_map,a0



    
    move #UG_COLMAP_SIZE-1,d7
.lp:
    move.b #UG_COL_EMPTY,(a1)
    move (a0)+,d0
    and #$3ff,d0
    cmp d1,d0   ;#UG_TILEMAP_BLANK,d0
    beq .blank
    move.b #UG_COL_WALL,(a1)
.blank:
    lea 1(a1),a1
    dbra d7,.lp
    rts

; d0/d1, d2.w
; trashes A4
UG_SetRamMapTile:
    move.l g_ug+ug_m_map,a4
    lsr #3,d0
    add d0,d0
    add d0,a4
    lsr #3,d1
    lsl #5+1,d1
    move.w d2,(a4,d1)
    rts


; d0/d1, d2.b
; trashes A4
UG_SetColTile:
    move.l g_ug+ug_m_collisionMap,a4
    lsr #3,d0
    add d0,a4
    lsr #3,d1
    lsl #5,d1
    move.b d2,(a4,d1)
    rts


UG_GetColTile_GO:
    move go_x(a0),d0
    move go_y(a0),d1
UG_GetColTile:
    move.l g_ug+ug_m_collisionMap,a4
    lsr #3,d0
    add d0,a4
    lsr #3,d1
    lsl #5,d1
    moveq #0,d0
    move.b (a4,d1),d0
    rts



;---------------------------------------------------------------------------------

UG_InitParticles:
    move.l g_ug+ug_m_particles,a0
    move.l a0,g_ug+ug_nextParticleAddr
    lea UG_PARTICLES_RAMSIZE(a0),a0
    move.l a0,g_ug+ug_pastLastParticleAddr
    
    move.l g_ug+ug_m_particles,a0
    move #UG_PARTICLES_RAMSIZE,d0
    jmp UTILS_ClearRam
    
; a0 is GO
; uses A1 and some low Ds
UG_AddParticleFromGO_Offsets:
    dc.w 0,1,2,3,0,3,1,2,0,1,3,2,3,1,2,0
    dc.w 0,2,1,3,0,2,1,3,2,1,3,0,2,3,1,0
    
UG_ParticleTiles:
    dc.w UNDERGROUND_FLAME_VDPINDEX+0
    dc.w UNDERGROUND_FLAME_VDPINDEX+1
    dc.w UNDERGROUND_FLAME_VDPINDEX+2
    dc.w UNDERGROUND_FLAME_VDPINDEX+3

; a0 is GO    
UG_AddParticleFromGO:

    move.l g_ug+ug_m_particles,a1
    move #UG_MAX_PARTICLES-1,d0
.lp:
    tst.b ugp_active(a1)
    beq .free
    lea ugp_structsize(a1),a1
    dbra d0,.lp
    rts    
.free:
    move g_timer1,d0
    lsr #3,d0
    lea UG_AddParticleFromGO_Offsets,a2
    and #31,d0
    lsl #1,d0
    move (a2,d0),d0
    lsl #3,d0
    swap d0
    add.l go_x(a0),d0
    move.l d0,ugp_x(a1)
    move.l go_y(a0),ugp_y(a1)
    
    move #0,ugp_timer(a1)
    
    move go_word0(a0),d0
    and #3,d0
    add d0,d0
    lea UG_ParticleTiles,a2
    move (a2,d0),ugp_tile(a1)
    
    move.b #1,ugp_active(a1)
.inited:
    lea ugp_structsize(a1),a1
    cmp.l g_ug+ug_pastLastParticleAddr,a1
    bne .ok
    move.l g_ug+ug_m_particles,a1
.ok 
    move.l a1,g_ug+ug_nextParticleAddr
    rts

UG_AddParticleFromGO1:
    move.l g_ug+ug_nextParticleAddr,a1
    
    
    jsr UTILS_GetRandWordFast
    and #3,d0
    lsl #3,d0
    swap d0
    add.l go_x(a0),d0
    move.l d0,ugp_x(a1)
    move.l go_y(a0),ugp_y(a1)
    
    move.b #1,ugp_active(a1)
.inited:
    lea ugp_structsize(a1),a1
    cmp.l g_ug+ug_pastLastParticleAddr,a1
    bne .ok
    move.l g_ug+ug_m_particles,a1
.ok 
    move.l a1,g_ug+ug_nextParticleAddr
    rts

UG_RenderParticlesToRamScreen:

    move.l g_ug+ug_m_particles,a0
    
     move.l g_ug+ug_m_ramscreen,a2
     
    move.w g_scroll_y,d3
    move d3,d4
    add #28*8,d4
    
    
    move #UG_MAX_PARTICLES-1,d7
.lp:
    tst.b ugp_active(a0)
    beq .next

    move.w ugp_y(a0),d1
    cmp d3,d1
    ble .skip
    cmp d4,d1
    bgt .skip
    
.onscreen:
    move ugp_x(a0),d0

    move.l a2,a1
    lsr #3,d0
    add d0,d0
    add d0,a1
    
    move.w g_scroll_y,d5
    lsr #3,d5
    
    lsr #3,d1
    sub d5,d1
    lsl #5+1,d1
    add d1,a1
    move.w ugp_tile(a0),(a1)
    ;move.w #$d|PAL_1,(a1)
    
    
.skip:
.next:
    lea ugp_structsize(a0),a0
    dbra d7,.lp
    rts




UG_CountActiveParticles:
    move.l g_ug+ug_m_particles,a0
    moveq #0,d0
    move #UG_MAX_PARTICLES-1,d7
.lp:
    tst.b ugp_active(a0)
    beq .next
    addq #1,d0
.next:
    lea ugp_structsize(a0),a0
    dbra d7,.lp
    rts        
    
UG_InitOptimizedAngleTable:
    move.l g_ug+ug_m_angleTable,a1
    
    move #128-1,d7
    move #0,d6
.lp:
    move d6,d0
    add #128,d0
    jsr UTILS_GetSinCos
    ext.l d1
    ext.l d2
    asl.l #4,d1
    asl.l #4,d2
    move.l d2,(a1)+
    move.l d1,(a1)+    
    addq #1,d6
    dbra d7,.lp    
    
    rts

    
UG_UpdateParticles:

    move g_timer1,d6
    and #UG_PARTICLES_NUMFRAMES-1,d6

    move.l g_ug+ug_m_flowMap,a5

    move.l g_ug+ug_m_angleTable,a1
    move.l g_ug+ug_m_collisionMap,a4

    move.l g_ug+ug_m_particles,a0
    move d6,d0
    mulu #ugp_structsize*UG_PARTICLES_NUMPERFRAME,d0
    add d0,a0
    move #UG_PARTICLES_NUMPERFRAME-1,d7
.lp:
    tst.b ugp_active(a0)
    beq .next
    
; flow map
    move.l a5,a3
    move ugp_x(a0),d0
    lsr #3,d0
    add d0,a3
    move ugp_y(a0),d0
    lsr #3,d0
    lsl #5,d0
    add d0,a3      
    moveq #0,d0
    move.b (a3),d0
 
 ; movement
    lsl #3,d0
    move.l (a1,d0),d1
    add.l d1,ugp_x(a0)
    move.l 4(a1,d0),d1
    add.l d1,ugp_y(a0)
    
; check collision    
    move ugp_x(a0),d0
    move ugp_y(a0),d1
    move.l a4,a2
    lsr #3,d0
    add d0,a2
    lsr #3,d1
    lsl #5,d1
    moveq #0,d0
    move.b (a2,d1),d0
    beq .okhitwall

    move.b #0,ugp_active(a0)
    
    cmp #UG_COL_VENTHOLE_FIRST,d0
    blt .notventhole
    cmp #UG_COL_VENTHOLE_LAST,d0
    bgt .notventhole
    bra .venthole
.notventhole
    cmp #UG_COL_CHASERHOLE_FIRST,d0
    blt .notchaserhole
    cmp #UG_COL_CHASERHOLE_LAST,d0
    bgt .notchaserhole
    bra .chaserhole
.notchaserhole
    cmp #UG_COL_LIMPETMINE_FIRST,d0
    blt .notlimpetmine
    cmp #UG_COL_LIMPETMINE_LAST,d0
    bgt .notlimpetmine
    bra .limpetmine
.notlimpetmine


.okhitwall:

        
.ok:
.next:
    lea ugp_structsize(a0),a0
    dbra d7,.lp
    rts

.chaserhole
    PUSHALL
    lea g_ug+ug_chaserHoleGOList,a1
    sub #UG_COL_CHASERHOLE_FIRST,d0
    lsl #2,d0
    add d0,a1
    move.l (a1),a1      ; go addr
    bsr UG_ChaserHoleHitParticle
    POPALL
    bra .okhitwall

.limpetmine
    PUSHALL
    lea g_ug+ug_LimpetMineGOList,a1
    sub #UG_COL_LIMPETMINE_FIRST,d0
    lsl #2,d0
    add d0,a1
    move.l (a1),a1      ; go addr
    bsr UG_LimpetMineHitParticle
    POPALL
    bra .okhitwall

.venthole:
    PUSHALL
    lea g_ug+ug_ventHoleGOList,a1
    sub #UG_COL_VENTHOLE_FIRST,d0
    lsl #2,d0
    add d0,a1
    move.l (a1),a1      ; go addr
    bsr UG_VentHoleHitParticle
    POPALL
    bra .okhitwall


UG_SpawnGameObject_HitPlayer:
    jmp GOManager_SpawnGameObject_Treasure
UG_SpawnGameObject_Player:
    jmp GOManager_SpawnGameObject_FX
UG_SpawnGameObject_General:
    jmp GOManager_SpawnGameObject_FX

    
    
UG_SpawnSingleCallStuff:
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
    bsr UG_FindSingleCallSpawnEntryFromSpawner
    cmp.l #0,a4
    beq .skip_entry

    move.l a5,g_currentSpawnListAddr        ; for use in init function
    move.l a6,g_currentSpawnDataAddr        ; for use in init function

    move.l cspawntab_initFunc(a4),a3
    jsr (a3)
    ; so, don't actually spawn a gameobject, but call some code instead

.skip_entry:
    add #1,g_ug+ug_spawnCount
    lea spawner_structsize(a5),a5
    addq #1,d6
    lea 4(a6),a6
    dbra d7,.lp    
.exit:
    rts
    
UG_SpawnStuff:
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
    bsr UG_FindSpawnEntryFromSpawner
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
    add #1,g_ug+ug_spawnCount

    lea spawner_structsize(a5),a5
    addq #1,d6
    lea 4(a6),a6
    dbra d7,.lp

.exit:
    rts

; a5 is spawner entry
; returns a4 for spawner entry. 0 if none found
UG_FindSpawnEntryFromSpawner:
    lea UG_SpawnTab,a4
    bra UG_FindSpawnEntryFromSpawner_Inner    

UG_FindSingleCallSpawnEntryFromSpawner:
    lea UG_SpawnTabSingleCall,a4
    bra UG_FindSpawnEntryFromSpawner_Inner    
    
UG_FindSpawnEntryFromSpawner_Inner:
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


; player point vs enemy colbox
UG_PlayerObjectCollision:
    
    jsr GOManager_GetList_Treasure       ; ' collide with player'
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .noememies
    move.l golist_active_list_addr(a5),a5
    subq #1,d7

    move.l g_player,a1
    move go_x(a1),d5
    move go_y(a1),d6

.loop1:
    move.l (a5)+,a0
    
    move.l go_colliderAddr(a0),a2
    cmp.l #0,a2
    beq .skip
    
    move go_x(a0),d0
    move d0,d1
	add collider_offset_x0(a2),d0	; enemy left
	cmp d0,d5
	blt .skip
	
	add collider_offset_x1(a2),d1	; enemy right
	cmp d1,d5
	bgt .skip
	
    move go_y(a0),d0
    move d0,d1
	add collider_offset_y0(a2),d0	; enemy top
	cmp d0,d6
	blt .skip
	
	add collider_offset_y1(a2),d1	; enemy bottom
	cmp d1,d6
	bgt .skip
    
; callback player
    PUSHALL
    exg.l a0,a1 
    move.l go_onCollided(a0),d0
    beq .nocolfunc1
    move.l d0,a5
    jsr (a5)
.nocolfunc1:
    POPALL

; callback enemy
    PUSHALL
    move.l go_onCollided(a0),d0
    beq .nocolfunc2
    move.l d0,a5
    jsr (a5)
.nocolfunc2:
    POPALL

.skip:
    dbra d7,.loop1
    
.noememies:
    rts


; d0,d1 x,y
UG_ExplosionObjectCollision:
    PUSHALL
    move d0,d5
    move d1,d6

    jsr GOManager_GetList_Treasure       ; ' collide with player'
    move.l a3,a5
    move golist_num_active(a5),d7
    beq .noememies
    move.l golist_active_list_addr(a5),a5
    subq #1,d7

.loop1:
    move.l (a5)+,a0
    
    move.l go_colliderAddr(a0),a2
    cmp.l #0,a2
    beq .skip
    
    move go_x(a0),d0
    move d0,d1
    sub #32,d0
	;add collider_offset_x0(a2),d0	; enemy left
	cmp d0,d5
	blt .skip
	
	add #32,d1      ;add collider_offset_x1(a2),d1	; enemy right
	cmp d1,d5
	bgt .skip
	
    move go_y(a0),d0
    move d0,d1
	add collider_offset_y0(a2),d0	; enemy top
	cmp d0,d6
	blt .skip
	
	add collider_offset_y1(a2),d1	; enemy bottom
	cmp d1,d6
	bgt .skip
    
; callback enemy
    PUSHALL
    jsr GOManager_DeleteObject
    POPALL

.skip:
    dbra d7,.loop1
    
.noememies:
    POPALL
    rts
    
    
UG_SpawnTab:
    SPAWNTABENTRY SPRDEF_UNDERGROUND_PLAYER,0,UG_SpawnGameObject_Player,UG_InitPlayer
    SPAWNTABENTRY SPRDEF_UNDERGROUND_VENT,0,UG_SpawnGameObject_General,UG_InitVent
    SPAWNTABENTRY SPRDEF_UNDERGROUND_VENTHOLE,0,UG_SpawnGameObject_General,UG_InitVentHole
    SPAWNTABENTRY SPRDEF_UNDERGROUND_KILLABLEVENTHOLE,0,UG_SpawnGameObject_General,UG_InitChaserVentHole
    SPAWNTABENTRY SPRDEF_UNDERGROUND_ENEMYJUMPER,0,UG_SpawnGameObject_HitPlayer,UG_InitEnemyJumper
    SPAWNTABENTRY SPRDEF_UNDERGROUND_ACIDGENERATOR,0,UG_SpawnGameObject_General,UG_InitEnemyAcidGenerator
    SPAWNTABENTRY SPRDEF_UNDERGROUND_ENEMYBAT,0,UG_SpawnGameObject_HitPlayer,UG_InitEnemyBat
    SPAWNTABENTRY SPRDEF_UNDERGROUND_PICKUP1,0,UG_SpawnGameObject_HitPlayer,UG_InitPickup
    SPAWNTABENTRY SPRDEF_UNDERGROUND_WALLCLIMBER,0,UG_SpawnGameObject_General,UG_InitWallClimber
    SPAWNTABENTRY SPRDEF_UNDERGROUND_WALLWALKERBELOW,0,UG_SpawnGameObject_HitPlayer,UG_InitWallWalkerBelow
    SPAWNTABENTRY SPRDEF_UNDERGROUND_WALLWALKERBELOW2,0,UG_SpawnGameObject_HitPlayer,UG_InitWallWalkerBelow2
    SPAWNTABENTRY SPRDEF_UNDERGROUND_WALLWALKERABOVE,0,UG_SpawnGameObject_HitPlayer,UG_InitWallWalkerAbove
    SPAWNTABENTRY SPRDEF_UNDERGROUND_LIMPETMINEUP,0,UG_SpawnGameObject_General,UG_InitLimpetMineUp
    SPAWNTABENTRY SPRDEF_UNDERGROUND_LIMPETKILLERUP,0,UG_SpawnGameObject_General,UG_InitLimpetKillerUp
    SPAWNTABENTRY SPRDEF_UNDERGROUND_BLOWER,0,UG_SpawnGameObject_HitPlayer,UG_InitBlower
    SPAWNTABEND
UG_SpawnTabSingleCall:
    SPAWNTABENTRY SPRDEF_UNDERGROUND_SPIKE,0,0,UG_SingleCall_InitSpike
    SPAWNTABENTRY SPRDEF_UNDERGROUND_HELPTEXT,0,0,UG_SingleCall_InitHelpText
    SPAWNTABEND
