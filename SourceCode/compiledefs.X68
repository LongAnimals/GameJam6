
;---------------------------------------------------------------------------------------
; Compilation Definitions
;---------------------------------------------------------------------------------------

IS_FINAL_GAME equ 1 
;IS_DEBUG_MODE equ 1

;IS_GAME_RACER equ 1
;IS_GAME_COMMANDO equ 1
;IS_GAME_CUBEDROID equ 1
;IS_GAME_SCRAMBLE equ 1
;IS_GAME_TD equ 1
IS_GAME_UNDERGROUND equ 1
;IS_GAME_COFFEE equ 1

    ifnd IS_GAME_COFFEE
USE_A6 equ 1
    endif

USE_HVCOUNTER_TIMINGS equ 1

;SHOW_BORDER_COLORS equ 1
USE_PSG equ 1
USE_MUSIC equ 1

;HOL_PLAYER_IGNORE_WALL_COLLISION equ 1

;TEST_CUTSCENE_INDEX equ 0
HOL_IGNORE_CUTSCENES equ 1

;HOL_DISABLE_LIGHTMAP_OVERLAY equ 1

HOL_OVERRIDE_STARTLEVEL equ 20
HOL_OVERRIDE_STARTPLAYERLEVEL equ 0
;HOL_OVERRIDE_PLAYER_CLASS equ 4

;HOL_OVERRIDE_DUNGEONMAP equ 1

;HOL_NUM_ENEMIES_FOR_KEY equ 58
;HOL_EXIT_ALWAYS_OPEN equ 1 
;HOL_EVERYTHING_FREE equ 1

HOL_IS_INVULNERABLE equ 1
HOL_SUPERBULLETS equ 1

HOL_SPAWN_SKULLS equ 1
HOL_SPAWN_ITEMS equ 1
HOL_SPAWN_BIGMONSTERS equ 1
HOL_SPAWN_SPIKES equ 1
HOL_SPAWN_FLAMEHEAD equ 1
HOL_SPAWN_MEETBOY equ 1
HOL_SPAWN_MEETBOYTINY equ 1

;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------


