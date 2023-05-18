MAX_CUTSCENES equ 16

    
    
SPAWNTABENTRY macro \1,\2,\3,\4
    dc.w \1,\2
    dc.l \3
    dc.l \4
    endm
SPAWNTABEND macro
    dc.l -1,-1,-1
    endm
    
    clrso
cspawntab_type       so.w 1
cspawntab_subtype       so.w 1
cspawntab_spawnFunc  so.l 1
cspawntab_initFunc   so.l 1
cspawntab_structsize so.b 0


PUSHREGS macro \1
    movem.l \1,-(sp)
    endm
POPREGS macro \1
    movem.l (sp)+,\1
    endm

PUSHALL macro
    ifd USE_A6
    movem.l d0-d7/a0-a6,-(sp)
    else
    movem.l d0-d7/a0-a5,-(sp)    
    endif
    endm
POPALL macro
    ifd USE_A6
    movem.l (sp)+,d0-d7/a0-a6
    else
    movem.l (sp)+,d0-d7/a0-a5
    endif
    endm

	clrso
	setso $fff000   ;GLOBALS_ADDR   ; make sure g_size doesn't go up in to stack or worse
	
	
sysg_start so.b 0

sysg_vblcount so.l 1
sysg_difficulty so.b 1
sysg_practice_mode so.b 1
sysg_highscore so.l 1
sysg_score so.l 1

sysg_sprites_baseaddr so.l 1
sysg_sprites_baseaddr2 so.l 1
sysg_leveldata_addr so.l 1
sysg_leveldefs_addr so.l 1
sysg_levelchars_addr so.l 1
sysg_cheatmode  so.b 1
sysg_FILLERA so.b 1

sysg_levelInfo so.b levelinfo_structsize



sysg_debugpanel so.b debugpanel_structsize
sysg_levelIndex so.w 1


sysg_debug_showcollision so.b 1
sysg_FILLERB so.b 1
sysg_debug_spritegroupmask so.w 1
sysg_rand so.l 1
sysg_uncompress_addr so.l 1


sysg_music so.b sgmusic_structsize

sysg_next_screen_addr_after_fade so.l 1
sysg_next_screen_addr so.l 1
sysg_next_screen_data so.w 1
sysg_scene_exitFunc so.l 1

sysg_current_music so.w 1

sysg_hol_numMedallionsOfTime so.w 1
sysg_hol_numRingsOfFire so.w 1
sysg_hol_class_start_xplevels so.w 5
sysg_hol_class_permaitems so.w 5
sysg_hol_ui_playerClass so.w 1
sysg_hol_ui_playerClassVariant so.w 1

sysg_hol_totalLoot so.w 1
sysg_hol_totalKills so.w 1
sysg_hol_playerSkillLevel so.w 1
sysg_hol_maxPlayerHealth so.w 1
sysg_hol_playerHealth so.w 1
sysg_hol_playerScore so.l 1
sysg_hol_playerCoins so.w 1
sysg_hol_playerXp so.l 1
sysg_hol_nextPlayerXp so.l 1
sysg_hol_playerRegen so.w 1
sysg_hol_playerCloakedTimer so.w 1
sysg_hol_numPlayerKeys so.w 1

sysg_hol_playerClass so.w 1
sysg_hol_dungeonLevel so.w 1

sysg_hol_playerHasCup so.w 1
sysg_hol_playerHasLens so.w 1
sysg_hol_playerHasResurrectionRing so.w 1

    ifd IS_GAME_CUBEDROID
sysg_cd so.b cd_structsize
    endif

sysg_cutscenes_played so.b MAX_CUTSCENES

sysg_cutscene so.b cs_sysg_structsize

sysg_psg_active so.b 1
sysg_debug_musictestindex so.b 1

sysg_test_cutscene_index so.w 1

sysg_last so.b 0

m_hblankDataTable so.l 1

m_current_alloc_addr  so.l 1
m_CollisionMap so.l 1
m_ParticleSystem so.l 1
m_FXParticleSystem so.l 1

m_RamLightMap_current so.l 1
m_RamLightMap_static so.l 1
m_RamMonsterTable so.l 1
m_RamTileMap so.l 1
m_RamTileMap_HUD so.l 1
m_RamScrollEdge so.l 1
m_RamCollisionMap so.l 1
m_RamCollisionMap_Save so.l 1
m_RamUncompressedMap so.l 1

m_zoneTrackerTable so.l 1       

m_GOLists so.l 1
m_Golist_General so.l 1
m_Golist_FX so.l 1
m_Golist_Treasure so.l 1
m_Golist_PlayerBullets so.l 1
m_Golist_EnemyBullets so.l 1
m_Golist_UIScreens so.l 1

m_GOPointers_HitPlayerObjects_Points so.l 1
m_GOPointers_HitPlayerObjects_Boxes so.l 1
m_GOPointers_BulletObjects so.l 1
m_GOPointers_EnemyObjects so.l 1
m_HScrollDMATable so.l 1

m_SramSaveStateAddr so.l 1
m_font_ramscreen_addr so.l 1
m_font_ramscreen_addr2 so.l 1
m_spawnerAddr so.l 1
m_hol_maxActiveTable so.l 1
m_hol_sortlist so.l 1

m_cubedroid_goMap so.l 1
m_cubedroid_solidMap so.l 1
m_cubedroid_randomTileTable so.l 1
m_cubedroid_deferred_vram_write_table so.l 1

g_start so.b 0	

g_num_go_lists so.w 1
g_current_golist_addr so.l 1

g_scroll_columnA so.w 1
g_scroll_columnB so.w 1
g_scroll_rowA so.w 1
g_scroll_rowB so.w 1

g_hvcounter so.l 1

g_pad0Old so.w 1
g_pad0 so.w 1
g_pad0_pressed so.w 1
g_scroll_oldx so.l 1
g_scroll_oldy so.l 1
g_scroll_x so.l 1
g_scroll_dx so.l 1
g_scroll_y so.l 1
g_scroll_to_x so.l 1
g_scroll_to_y so.l 1
g_scrollb_x so.l 1
g_scrollb_y so.l 1
g_timer008 so.l 1
g_timer0175 so.l 1
g_timer025 so.l 1		
g_timer05 so.l 1		
g_timer1 so.l 1		
g_timer1_and1 so.l 1		
g_timer1_and3 so.l 1		
g_timer1_and7 so.l 1		
g_timer1_shr1 so.l 1		
g_timer1_shr2 so.l 1		
g_timer1_shr3 so.l 1		
g_timer1_shr4 so.l 1		
g_timer1_shr4_and1 so.l 1		
g_timer1_shr5 so.l 1		
g_timer1_shr5_and1 so.l 1		
g_timer1_shr6 so.l 1		
g_timer1_shr7 so.l 1		
g_timer1_shr8 so.l 1		

g_spritelist_hitplayer_point_amt so.w 1
g_spritelist_hitplayer_box_amt so.w 1
g_spritelist_bullet_amt so.w 1
g_spritelist_hitbyplayerbullet_amt so.w 1
g_game_loopaddr so.l 1
g_game_vbladdr so.l 1
g_player so.l 1
g_boss so.l 1
g_playerWeaponType so.w 1
g_aiPlayer0 so.l 1
g_playerGhost so.l 1
g_mapaddr so.l 1
g_colmapaddr so.l 1
g_colmap_w so.w 1
g_colmap_h so.w 1
g_collision_loop_mode so.w 1

g_laptime so.b laptime_structsize
g_bestlaptime so.b laptime_structsize

g_colmap_offsettable so.l 1
g_colmap_data so.l 1

g_post_init_func so.l 1

g_IMAGE_xtable so.l 1
g_IMAGE_ytable so.l 1

g_player_dead so.b 1
g_FILLERC so.b 1

g_vram_sprites so.w 1
g_vram_bg so.w 1
g_vram_fg so.w 1
g_vram_font so.w 1
g_vram_panel_font so.w 1
g_vram_windowtiles so.w 1
g_vram_image1 so.w 1
g_vram_image2 so.w 1
g_vram_blanktile so.w 1
g_vram_currentpos so.w 1

g_image_index so.w 1
g_image_groupbase so.l 1

g_fade so.b fade_structsize


g_info0 so.w 1
g_info1 so.w 1
g_info2 so.w 1
g_info3 so.w 1
g_info4 so.w 1

g_current_map_index so.w 1
g_highest_num_sprites_active so.w 1
g_num_sprites_active so.w 1
g_font_index so.w 1
g_font_palette_index so.w 1
g_font_cellbits so.w 1

g_has_initialised_hbl so.b 1
g_filler99 so.b 1
g_hblcount so.l 1
g_hblcount1 so.l 1
g_hbladder so.l 1
g_hbladder1 so.l 1
g_hbldata so.w 1

g_music so.b gmusic_structsize

g_cheatcode_counter so.w 1

g_scroll_vram_write_base_fg so.l 1
g_scroll_vram_write_base_bg so.l 1
g_scroll_priorityflag_fg so.w 1
g_scroll_priorityflag_bg so.w 1

g_sfx_nextchannel so.w 1
g_sfx_testsoundindex so.w 1


g_image_blit_vdp_table so.l 1
g_image_blit_vdp_baseaddr so.l 1
g_image_blit_x so.w 1
g_image_blit_y so.w 1
g_image_blit_w so.w 1
g_image_blit_h so.w 1
g_image_blit_dest_x so.w 1
g_image_blit_dest_y so.w 1
g_image_blit_dest_vdpoffset so.w 1
g_image_blit_mapaddr so.l 1

g_numberPrintArea so.w 10

g_colorbars_source_address so.l 1

g_cutscene so.b cs_structsize


g_screenshake_timer so.l 1
g_screenshake_x so.w 1
g_screenshake_y so.w 1
g_hol_gamestate so.w 1

g_hudmessage so.b hudmessage_structsize

g_ramblit_data so.b ramblit_struct_size

g_sprcache_spraddr so.l 1
g_sprcache_sprcharoffset so.w 1
g_sprcache_currentaddr so.l 1
g_sprcache_numframes so.w 1


g_musicsample_testcount so.w 1
g_musicsample_bank so.w 1

g_hol_romTileMapAddr so.l 1
g_hol_playerClassVariant so.w 1
g_hol_classdata so.l 1
g_hol_initialPlayerClass so.w 1
g_hol_runeLevel  so.w 1
g_hol_runeType  so.w 1
g_hol_runeShootTimer  so.w 1
g_hol_runeShootRot  so.w 1

g_hol_lightmap_active so.w 1
g_hol_lightmap_updateIndex so.w 1


g_hol_playerMaxShieldLevel so.w 1
g_hol_playerShieldLevel so.w 1
g_hol_playerShieldType so.w 1

g_hol_dungeonInfoAddr so.l 1
g_hol_dungeonMapAddr so.l 1
g_hol_dungeonColMapAddr so.l 1
g_hol_dungeonMonstersAddr so.l 1
g_hol_dungeonMonstersSelectionAddr so.l 1

g_hol_spawner_mode so.w 1
g_hol_spawner_perFrameCount so.w 1
g_hol_spawner_currentIndex so.w 1
g_hol_unspawner_currentIndex so.w 1

g_hol_hasHostage so.w 1
g_hol_hasCyclops so.w 1
g_hol_hasMinotaur so.w 1
g_hol_hasSwitches so.w 1
g_hol_hasShop   so.w 1
g_hol_hasQuest   so.w 1
g_hol_hasBats   so.w 1

g_hol_numBaddiesKilledInLevel so.w 1
g_hol_hasGeneratedKey so.w 1
g_hol_numRequiredForKey so.w 1


g_hol_switches_all_activated so.w 1
g_hol_switchstates so.b 4
g_hol_switchResetTimer so.w 1

g_hol_secretRoomFound so.w 1

g_hol_shopItemAddr so.l 1

g_holscreen so.b holscreen_structsize
g_nextHolScreenInitAddr so.l 1
g_holScreen_mode so.w 1

g_quest_time_mins so.w 1
g_quest_time_seconds so.w 1
g_quest_time_subseconds so.w 1
g_quest_active so.w 1
g_quest_item so.w 1
g_quest_numDone so.w 1
g_quest_rewardNumCoins so.w 1
g_quest_type so.w 1
g_quest_numRequired so.w 1
g_quest_rewardType so.w 1

g_currentSpawnListAddr so.l 1
g_currentSpawnDataAddr so.l 1

g_ik    so.b gik_structsize

    ifd IS_GAME_SCRAMBLE
g_scramble so.b scramble_structsize
    endif

    ifd IS_GAME_UNDERGROUND
g_ug so.b ug_structsize
    endif

    ifd IS_GAME_COFFEE
g_cof so.b cof_structsize
    endif

    ifd IS_GAME_TD
g_td so.b td_structsize
    endif

g_stackwatch        so.l 1      ; test this to see if it changes ever
g_last so.b 0



g_size equ g_last-sysg_start
sysg_size equ sysg_last-sysg_start

justg_size equ g_last-g_start


LEVELTYPE_NORMAL equ 0
LEVELTYPE_BOSS equ 1
LEVELTYPE_UI equ 2

; Sprite buffer.. used when creating sprites in the render callback function
	clrso
sprbuf_x so.w 1
sprbuf_y so.w 1
sprbuf_flags so.w 1
sprbuf_frame so.w 1
sprbuf_sprgroup so.l 1
sprbuf_vdpbase so.w 1
sprbuf_size so.b 0






    clrso
levelinfo_tileMap0      so.l 1
levelinfo_tileMap0_stride so.w 1
levelinfo_tileData0     so.l 1
levelinfo_palette0      so.l 1
levelinfo_tileMap1      so.l 1
levelinfo_tileMap1_stride so.w 1
levelinfo_tileData1     so.l 1
levelinfo_palette1      so.l 1
levelinfo_collisionMap  so.l 1
levelinfo_collisionMap_stride  so.w 1
levelinfo_surfaceMap    so.l 1
levelinfo_surfaceMap_stride    so.w 1
levelinfo_zones         so.l 1
levelinfo_spawners      so.l 1
levelinfo_spawnerData   so.l 1
levelinfo_paths         so.l 1
levelinfo_flowMap       so.l 1
levelinfo_structsize    so.b 0

    clrso
levelexport_tileMap0      so.l 1
levelexport_tileData0     so.l 1
levelexport_palette0      so.l 1
levelexport_tileMap1      so.l 1
levelexport_tileData1     so.l 1
levelexport_palette1      so.l 1
levelexport_collisionMap  so.l 1
levelexport_surfaceMap    so.l 1
levelexport_zones      so.l 1
levelexport_spawners      so.l 1
levelexport_spawnerData      so.l 1
levelexport_paths         so.l 1
levelexport_flowMap       so.l 1
levelexport_structsize    so.b 0


SCR_W	equ 40
SCR_H 	equ 28
SCR_W2	equ 20
SCR_H2 	equ 14

SCR_W_PIXELS	equ 320
SCR_H_PIXELS	equ	224

PLANE_W equ 64
PLANE_H equ 32

PLANE_W_LSHIFT equ 6

COMPRESSION_None equ 0
COMPRESSION_RLE_Words equ 1
COMPRESSION_LZ4W equ 2


Globals_ClearScratchpad:
	lea Scratchpad,a0
	move #SCRATCHPAD_SIZE-1,d7
.lp: move.b #0,(a0)+
	dbra d7,.lp
	rts


Globals_ClearGsys:
	lea sysg_start,a0
	move #sysg_size-1,d0
.lp: move.b #0,(a0)+
	dbra d0,.lp
	rts


; does not clear gsys_area
Globals_ClearAll:
	;move #(g_size-g_start)-1,d0
	move #justg_size-1,d0
	lea g_start,a0
.lp: move.b #0,(a0)+
	dbra d0,.lp
	rts

	
pad_button_up    equ $0
pad_button_down  equ $1
pad_button_left  equ $2
pad_button_right equ $3
pad_button_a     equ $C
pad_button_b     equ $4
pad_button_c     equ $5
pad_button_start equ $D



padmask_button_up equ 1<<pad_button_up
padmask_button_down equ 1<<pad_button_down
padmask_button_left equ 1<<pad_button_left
padmask_button_right equ 1<<pad_button_right
padmask_button_a equ 1<<pad_button_a
padmask_button_b equ 1<<pad_button_b
padmask_button_c equ 1<<pad_button_c
padmask_button_start equ 1<<pad_button_start

padmask_ABCStart equ padmask_button_a | padmask_button_b | padmask_button_c | padmask_button_start

padmask_button_udlr equ padmask_button_up | padmask_button_down | padmask_button_left | padmask_button_right




SET_BLIT_DEST macro \1, \2, \3, \4
	move.l \1,g_image_blit_vdp_baseaddr
	move.w \2,g_image_blit_dest_vdpoffset
	move.w \3,g_image_blit_dest_x
	move.w \4,g_image_blit_dest_y
	endm

SET_BLIT_SOURCE macro \1, \2, \3, \4, \5
	move.l \1,g_image_blit_mapaddr
	move.w \2,g_image_blit_x
	move.w \3,g_image_blit_y
	move.w \4,g_image_blit_w
	move.w \5,g_image_blit_h

	endm


SCREENPOS macro \1 \2 \3 \4
	move.l #\1 + (\3*128) + (\2*2),\4
	endm
	
FONT_DRAW_AT macro \1 \2 \3 \4
	lea \2,a0
	move.l #\1 + (\4*128) + (\3*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	endm

FONT_DRAW_AT_RAM macro \1 \2 \3 \4
	lea \2,a0
	move.l m_font_ramscreen_addr,a1
	add.l #(\4*128) + (\3*2),a1
	jsr FONT_DrawText_RamScreen
	endm
FONT_DRAW_AT_RAM2 macro \1 \2 \3 \4
	lea \2,a0
	move.l m_font_ramscreen_addr2,a1
	add.l #(\4*128) + (\3*2),a1
	jsr FONT_DrawText_RamScreen
	endm


FONT_DRAW_AT_A0 macro \1 \3 \4
	move.l #\1 + (\3*128) + (\2*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	endm

	
FONT_DRAW_NUMBER2_AT macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l	#\1 + (\3*2) + (\4*128) , d1
	jsr	VDP_BuildAndSetVRAMWriteAddress		
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_W_2
	endm

FONT_DRAW_NUMBER2_AT_RAM macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l m_font_ramscreen_addr,a1
	add.l	#(\3*2) + (\4*128) , a1
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_W_2_RamScreen
	endm

FONT_DRAW_NUMBER2_AT_RAM2 macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l m_font_ramscreen_addr2,a1
	add.l	#(\3*2) + (\4*128) , a1
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_W_2_RamScreen
	endm

FONT_SCREENPOS_RAM macro \1 \2 \3	; x,y,reg
	move.l m_font_ramscreen_addr,\3
	add.l	#(\1*2) + (\2*128) , \3
	endm


FONT_DRAW_NUMBER_BYTE_AT macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l	#\1 + (\3*2) + (\4*128) , d1
	jsr	VDP_BuildAndSetVRAMWriteAddress		
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_Byte
	endm


FONT_DRAW_NUMBER5_AT macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l	#\1 + (\3*2) + (\4*128) , d1
	jsr	VDP_BuildAndSetVRAMWriteAddress		
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_W_5
	endm


FONT_DRAW_NUMBER5_AT_RAM macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l m_font_ramscreen_addr,a1
	add.l	#(\3*2) + (\4*128) , a1
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_W_5_RamScreen
	endm

FONT_DRAW_NUMBER5_AT_RAM2 macro  \1 \2 \3 \4
	move.l d0,-(sp)
	move.l m_font_ramscreen_addr2,a1
	add.l	#(\3*2) + (\4*128) , a1
	move.l (sp)+,d0
	move \2,d0
	jsr FONT_DrawNumber_W_5_RamScreen
	endm



;-------------------------------------------------------------------------------
; WaitVBlank
;-------------------------------------------------------------------------------
WaitVBlank:
	move.l sysg_vblcount,d0
.loop
	move.l sysg_vblcount,d1
	cmp.l d0,d1
	beq .loop
	rts	; exit


ClearCRAM:
    lea     VDP_CONTROL,a1
	move.l	#VDP_CRAM_WRITE,(a1) ; set VDP ctrl to CRAM write
	move.w	#$003f,d1	; 3f = 63 = (64 palettes in CRAM - 1)
.loop:
	move.w	#$0000,(VDP_DATA)
	dbf	d1,.loop
	rts


ClearRAM:
	lea	MEM_START,a0
	move.w	#(STATIC_MEM_END-MEM_START),d1
.loop:
	move.b	#$0,(a0)+
	dbf	d1,.loop
	rts




ClearVRAM:
    lea     VDP_CONTROL,a1  
	move.l	#VDP_VRAM_WRITE,(a1)
	move.w	#$7FFF,d1
.loop:
	move.w	#$0000,(VDP_DATA)
	dbra	d1,.loop
	rts	

;d1 is amount of ram to clear
ClearVRAMRange:
    lea     VDP_CONTROL,a1  
	move.l	#VDP_VRAM_WRITE,(a1)
	lsr #1,d1   ; words
	subq #1,d1
.loop:
	move.w	#$0000,(VDP_DATA)
	dbra	d1,.loop
	rts	

PSG_PLAY_SFX macro \1
    ifd USE_PSG
	move.l d0,-(sp)
	move #\1,d0
	jsr PSG_PlayFx
	move.l (sp)+,d0
	endif
	endm
