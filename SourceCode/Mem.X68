
    ifd IS_GAME_COMMANDO
SPRLIST_NUM_CARS equ 2              ; player
SPRLIST_NUM_FX equ 8                ; fx
SPRLIST_NUM_TREASURE equ 24         ; shootable
SPRLIST_NUM_PLAYERBULLETS equ 12        
SPRLIST_NUM_ENEMYBULLETS equ 12
SPRLIST_NUM_UISCREENS equ 1
    endif
    
    ifd  IS_GAME_TD
SPRLIST_NUM_CARS equ 64              ; enemies
SPRLIST_NUM_FX equ 4               ; ----
SPRLIST_NUM_TREASURE equ 8         ; general
SPRLIST_NUM_PLAYERBULLETS equ 8     ; player bullets   
SPRLIST_NUM_ENEMYBULLETS equ 1      ;-------
SPRLIST_NUM_UISCREENS equ 1
    endif

    ifd  IS_GAME_SCRAMBLE
SPRLIST_NUM_CARS equ 4              ; 
SPRLIST_NUM_FX equ 12               ; ----
SPRLIST_NUM_TREASURE equ 40         ; enemies 
SPRLIST_NUM_PLAYERBULLETS equ 16     ;     
SPRLIST_NUM_ENEMYBULLETS equ 4     ;-------
SPRLIST_NUM_UISCREENS equ 12
    endif

    ifd  IS_GAME_UNDERGROUND
SPRLIST_NUM_CARS equ 1              ; 
SPRLIST_NUM_FX equ 20               ; ----
SPRLIST_NUM_TREASURE equ 40         ; enemies  
SPRLIST_NUM_PLAYERBULLETS equ 1     ;      
SPRLIST_NUM_ENEMYBULLETS equ 1     ; 
SPRLIST_NUM_UISCREENS equ 1
    endif

    ifd  IS_GAME_COFFEE
SPRLIST_NUM_CARS equ 4              ; 
SPRLIST_NUM_FX equ 12               ; ----
SPRLIST_NUM_TREASURE equ 40         ; enemies 
SPRLIST_NUM_PLAYERBULLETS equ 16     ;     
SPRLIST_NUM_ENEMYBULLETS equ 24     ;-------
SPRLIST_NUM_UISCREENS equ 1
    endif


    ifd IS_GAME_RACER
SPRLIST_NUM_CARS equ 16
SPRLIST_NUM_FX equ 16
SPRLIST_NUM_TREASURE equ 16
SPRLIST_NUM_PLAYERBULLETS equ 16
SPRLIST_NUM_ENEMYBULLETS equ 1
SPRLIST_NUM_UISCREENS equ 1
    endif

    ifd IS_GAME_CUBEDROID
SPRLIST_NUM_CARS equ 2
SPRLIST_NUM_FX equ 3
SPRLIST_NUM_TREASURE equ 90
SPRLIST_NUM_PLAYERBULLETS equ 1
SPRLIST_NUM_ENEMYBULLETS equ 16
SPRLIST_NUM_UISCREENS equ 1
    endif

    ifd TEST_SOUND
SPRLIST_NUM_CARS equ 16
SPRLIST_NUM_FX equ 16
SPRLIST_NUM_TREASURE equ 8
SPRLIST_NUM_PLAYERBULLETS equ 8
SPRLIST_NUM_ENEMYBULLETS equ 8
SPRLIST_NUM_UISCREENS equ 8
    endif

MEM_SHOW_DEBUG equ 1

;------------------------------------------------------------------------------------------------------------------------------------------------
; Memory Management
;------------------------------------------------------------------------------------------------------------------------------------------------



    ifd IS_GAME_CUBEDROID
MEM_AllocForGame_CubeDroid:
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_GameObjects,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_CubeDroid,a0
    bsr MEM_AllocateGroup
    
    bsr MEM_ShowDebug
    rts
    endif


MEM_AllocForGame:
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_GameObjects,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Collision,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Scroll,a0
    bsr MEM_AllocateGroup
    
    
    bsr MEM_ShowDebug
    rts

MEM_AllocForScreens:
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_GameObjects_Screens,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_Scroll,a0
    bsr MEM_AllocateGroup
    
    bsr MEM_ShowDebug    
    rts

MEM_AllocForMusicPlayer:
    lea MEM_Table_Sound,a0
    bsr MEM_AllocateGroup

    lea MEM_Table_Generic,a0
    bsr MEM_AllocateGroup
    
    lea MEM_Table_GameObjects,a0
    bsr MEM_AllocateGroup

    bsr MEM_ShowDebug
    rts

    
MEM_ShowDebug:
    ifd MEM_SHOW_DEBUG
    move.l #'HEAP',DebugArea
    move.l #MEM_RAM_HEAP,DebugArea+4
    move.l #'CURR',DebugArea+8
    move.l m_current_alloc_addr,DebugArea+12
    move.l #'LEFT',DebugArea+16
    
    move.l #$FFFFFF-512,d0
    sub.l m_current_alloc_addr,d0
    move.l d0,DebugArea+20
    ;DEBUG_SHOWWINDOW_68K
    endif
    rts


MEM_Table_Scroll_MusicPlayer:    
    dc.l m_font_ramscreen_addr
    dc.w 64*32*2        ; 4k for screen map for now. only really used for bosses.

    dc.l m_font_ramscreen_addr2
    dc.w 64*32*2        ; 4k for screen map for now. only really used for bosses.

    dc.l -1

    ifd IS_GAME_CUBEDROID

MEM_Table_CubeDroid:
    dc.l m_cubedroid_goMap
    dc.w CUBEDROID_MAP_SIZE*4

    dc.l m_cubedroid_solidMap
    dc.w CUBEDROID_MAP_SIZE

    dc.l m_cubedroid_randomTileTable
    dc.w CUBEDROID_MAP_SIZE

    dc.l -1
    endif
    
MEM_Table_Scroll:    
    dc.l m_RamTileMap
    dc.w H_MAP_SIZE       ; 1k
    dc.l m_RamLightMap_current
    dc.w H_MAP_SIZE       ; 1k
    dc.l m_RamLightMap_static
    dc.w H_MAP_SIZE       ; 1k

    ;dc.l m_RamPreCalcedScrollTable
    ;dc.w 64*4           ;2s56 bytes 
    
    dc.l -1

MEM_Table_Collision:    
    ;dc.l m_RamCollisionMap
    ;dc.w H_COLMAP_SIZE_IN_RAM        ; 
    ;dc.l m_RamItemCollisionMap
    ;dc.w H_COLMAP_SIZE_IN_RAM        ; 1k
    
    dc.l m_zoneTrackerTable
    dc.w 256
    
    dc.l -1


MEM_Table_Sound:
    dc.l sysg_music+sgmusic_m_FMTracks
    dc.w MUSICPLAYER_SIZE
    dc.l sysg_music+sgmusic_m_FMModTracks
    dc.w MUSICPLAYER_FMMOD_SIZE
    dc.l sysg_music+sgmusic_m_SampleTracks
    dc.w MUSICPLAYER_SAMPLETRACK_SIZE
    dc.l sysg_music+sgmusic_m_PsgSfxPlayer
    dc.w PSGSFXPLAYER_SIZE
    dc.l -1

    
MEM_Table_Generic:
    dc.l m_SramSaveStateAddr
    dc.w sram_struct_size
    
    ;dc.w m_HScrollDMATable
    ;dc.w HSCROLLDMA_TABLE_SIZE
    
    dc.l -1
    
    
MEM_Table_GameObjects:
    
    dc.l m_GOLists
    dc.w golist_structsize*GOMANAGER_NUM_LISTS
    
    dc.l m_Golist_General
    dc.w (go_structsize+8)*SPRLIST_NUM_CARS
    dc.l m_Golist_FX
    dc.w (go_structsize+8)*SPRLIST_NUM_FX
    dc.l m_Golist_Treasure
    dc.w (go_structsize+8)*SPRLIST_NUM_TREASURE
    dc.l m_Golist_PlayerBullets
    dc.w (go_structsize+8)*SPRLIST_NUM_PLAYERBULLETS
    dc.l m_Golist_UIScreens
    dc.w (go_structsize+8)*SPRLIST_NUM_UISCREENS
    dc.l m_Golist_EnemyBullets
    dc.w (go_structsize+8)*SPRLIST_NUM_ENEMYBULLETS

    dc.l m_hol_sortlist
    dc.w 64*4
    
    dc.l -1
    

MEM_Table_GameObjects_Screens:
    
    dc.l m_GOLists
    dc.w golist_structsize*GOMANAGER_NUM_LISTS
    
    dc.l m_Golist_General
    dc.w (go_structsize+8)*SPRLIST_NUM_CARS
    dc.l m_Golist_FX
    dc.w (go_structsize+8)*SPRLIST_NUM_FX
    dc.l m_Golist_Treasure
    dc.w (go_structsize+8)*SPRLIST_NUM_TREASURE
    dc.l m_Golist_UIScreens
    dc.w (go_structsize+8)*SPRLIST_NUM_UISCREENS
    dc.l m_Golist_PlayerBullets
    dc.w (go_structsize+8)*SPRLIST_NUM_PLAYERBULLETS
    dc.l m_Golist_EnemyBullets
    dc.w (go_structsize+8)*SPRLIST_NUM_ENEMYBULLETS


    dc.l -1

    
    
MEM_Init:
    move.l #MEM_RAM_HEAP,m_current_alloc_addr
    
    rts

; group in a0
MEM_AllocateGroup:
.loop:
    move.l (a0)+,d0             ; get storage offset or 'finished' indicator
    bmi .done                   ; exit if end of list
    move.l d0,a1
    move.l m_current_alloc_addr,d1
    move.l d1,(a1)      ; store base address in globals
    moveq #0,d0
    move (a0)+,d0
    add.l d0,m_current_alloc_addr         ; add offset to base address
    
    movem.l d0-d3/a0-a3,-(sp)
    move.l d1,a0
    jsr UTILS_ClearRam
    movem.l (sp)+,d0-d3/a0-a3
     
    bra .loop
    
.done:
    rts
    
