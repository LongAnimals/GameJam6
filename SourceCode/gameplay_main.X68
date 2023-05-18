
MAIN_UpdateGame:
	move.l g_game_loopaddr,d0
	beq .no
	move.l d0,a0
	jsr (a0)
.no:
	rts

MAIN_UpdateVBL:
	move.l g_game_vbladdr,d0
	beq .no
	move.l d0,a0
	jsr (a0)
.no:
	rts

MAIN_InitGame:
	move.l #UncompressArea,sysg_uncompress_addr
	jsr UTILS_InitRandSeed
	
	
	ifd IS_FINAL_GAME
	jsr InitState_Title
	rts
	endif

    ifd IS_GAME_CUBEDROID
	jsr InitState_CD
	rts
	endif

    ifd IS_GAME_COMMANDO
	jsr InitState_Commando
	rts
	endif

    ifd IS_GAME_TD
	jsr TD_InitState
	rts
	endif

    ifd IS_GAME_SCRAMBLE
	jsr Scramble_InitState
	rts
	endif
	
	ifd IS_GAME_RACING
	jsr InitState_Racing
	rts
	endif

    ifd IS_GAME_UNDERGROUND
	jsr UG_InitState
	rts
	endif

    ifd IS_GAME_COFFEE
	jsr Coffee_InitState
	rts
	endif














