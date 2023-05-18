
;USE_SRAM equ 1

SRAM_START_ADDR:  equ $200001  ; First SRAM address
SRAM_END_ADDR:    equ $20FFFF  ; Last SRAM address
SRAM_LOCK_ADDR:   equ $A130F1  ; Write 1 to unlock SRAM

SRAM_VALID_DATA_VALUE equ $12349876


	clrso
sram_valid_data so.l 1
sram_checksum so.w 1
sram_data_start so.b 0
sram_cutscenes_played so.b 16
sram_highscore so.l 1
sram_difficulty so.b 1
sram_FILLER so.b 1
sram_last_selected_player_class so.w 1
sram_hol_class_start_xplevels so.w 5
sram_hol_class_permaitems so.w 5
sram_hol_numMedallionsOfTime so.w 1
sram_hol_numRingsOfFire so.w 1
sram_last_selected_player_class_variant so.w 1
sram_struct_size so.b 0

SRAM_SaveGame:
    ifnd USE_SRAM
    rts
    endif
        
	PUSHALL
	move.l m_SramSaveStateAddr,a0       ;lea SramSaveStateAddr,a0
	move.l #SRAM_VALID_DATA_VALUE,sram_valid_data(a0)

    bsr SRAM_CopyToSaveData

; calc andwrite checksum
	bsr SRAM_CalcChecksum
	move.l m_SramSaveStateAddr,a0       ;
	move.b d0,sram_checksum(a0)

; write data to sram itself
	move.b  #1,SRAM_LOCK_ADDR
	move.l m_SramSaveStateAddr,a0       ;lea SramSaveStateAddr,a0
	lea SRAM_START_ADDR,a1
	move #sram_struct_size-1,d7
.lp:
	move.b (a0)+,(a1)
	lea 2(a1),a1
	dbra d7,.lp

	move.b  #0,SRAM_LOCK_ADDR

	POPALL
	rts


; returns checksum in d0.b
SRAM_CalcChecksum:
   ifnd USE_SRAM
   rts
   endif
    
    
    move.l m_SramSaveStateAddr,a0       ;lea SramSaveStateAddr+sram_data_start,a0
    add.l #sram_data_start,a0
	move #(sram_struct_size-sram_data_start),d2
	move.b #$c3,d0
.lp:
	move.b (a0)+,d1
	eor.b d1,d0
	dbra d2,.lp
	move.l m_SramSaveStateAddr,a0       ;move.b d0,SramSaveStateAddr+sram_checksum
	move.b d0,sram_checksum(a0)
	rts




SRAM_LoadGame:
    ifnd USE_SRAM
    rts
    endif
	
	PUSHALL
; write data to sram itself
	move.b  #1,SRAM_LOCK_ADDR
	lea SRAM_START_ADDR,a0
	move.l m_SramSaveStateAddr,a1       ;lea SramSaveStateAddr,a1
	move #sram_struct_size-1,d7
.lp:
	move.b (a0),(a1)+
	lea 2(a0),a0
	dbra d7,.lp
	move.b  #0,SRAM_LOCK_ADDR


	bsr SRAM_CalcChecksum
	move.l m_SramSaveStateAddr,a0       ;
	cmp.b sram_checksum(a0),d0              ;cmp.b SramSaveStateAddr+sram_checksum,d0
	bne .invalid_checksum


	move.l m_SramSaveStateAddr,a0       ;lea SramSaveStateAddr,a0
	cmp.l #SRAM_VALID_DATA_VALUE,sram_valid_data(a0)
	bne .invaliddata


    bsr SRAM_CopyFromSaveData
    bra .return

.invaliddata:
	bsr SRAM_ClearSaveGame
	bra .return

.invalid_checksum:
	bsr SRAM_ClearSaveGame
	bra .return
.return:
    POPALL
	rts


SRAM_ClearSaveGame:
    ifnd USE_SRAM
    rts
    endif
	move.l #0,sysg_highscore
	
    move.b #0,sysg_difficulty
    move.w #0,sysg_hol_ui_playerClass
    move.w #0,sysg_hol_ui_playerClassVariant
    move.w #0,sysg_hol_numMedallionsOfTime
    move #0,sysg_hol_numRingsOfFire


	lea sysg_cutscenes_played,a0
    move #MAX_CUTSCENES,d0
    jsr UTILS_ClearRam
    
	lea sysg_hol_class_start_xplevels,a0
    move #5*2,d0
    jsr UTILS_ClearRam

	lea sysg_hol_class_permaitems,a0
    move #5*2,d0
    jsr UTILS_ClearRam
    
	bsr SRAM_SaveGame
	rts


SRAM_CopyToSaveData:
    PUSHALL
    
    move.l m_SramSaveStateAddr,a2
	
	move.l sysg_highscore,sram_highscore(a2)


	move.b sysg_difficulty,sram_difficulty(a2)
	move.w sysg_hol_ui_playerClass,sram_last_selected_player_class(a2)
	move.w sysg_hol_ui_playerClassVariant,sram_last_selected_player_class_variant(a2)
    move sysg_hol_numMedallionsOfTime,sram_hol_numMedallionsOfTime(a2)
    move sysg_hol_numRingsOfFire,sram_hol_numRingsOfFire(a2)

	lea sysg_cutscenes_played,a0
	lea sram_cutscenes_played(a2),a1
    move MAX_CUTSCENES,d0
    jsr UTILS_Copy
	
	lea sysg_hol_class_start_xplevels,a0
	lea sram_hol_class_start_xplevels(a2),a1
    move #5*2,d0
    jsr UTILS_Copy

	lea sysg_hol_class_permaitems,a0
	lea sram_hol_class_permaitems(a2),a1
    move #5*2,d0
    jsr UTILS_Copy
	
	POPALL
	rts

SRAM_CopyFromSaveData:
    PUSHALL
    
    move.l m_SramSaveStateAddr,a2
	
	move.l sram_highscore(a2),sysg_highscore

	move.b sram_difficulty(a2),sysg_difficulty
	move.w sram_last_selected_player_class(a2),sysg_hol_ui_playerClass
	move.w sram_last_selected_player_class_variant(a2),sysg_hol_ui_playerClassVariant
	
	move sram_hol_numMedallionsOfTime(a2),sysg_hol_numMedallionsOfTime
    move sram_hol_numRingsOfFire(a2),sysg_hol_numRingsOfFire

    lea sram_cutscenes_played(a2),a0
    lea sysg_cutscenes_played,a1
    move MAX_CUTSCENES,d0
    jsr UTILS_Copy

    
    lea sysg_cutscenes_played,a1
    move.b #1,(a1)+
    move.b #1,(a1)+
    move.b #1,(a1)+
	
	lea sram_hol_class_start_xplevels(a2),a0
	lea sysg_hol_class_start_xplevels,a1
    move #5*2,d0
    jsr UTILS_Copy

	lea sram_hol_class_permaitems(a2),a0
	lea sysg_hol_class_permaitems,a1
    move #5*2,d0
    jsr UTILS_Copy
	
	
	POPALL
	rts
