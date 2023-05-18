SAMPLES_GUNSLUGS equ 0
TEST_SOUND_DEBUG_COLORS equ 1
MUSIC_USE_TRACK_MUTED equ 1

InitState_MusicPlayer:


	VDP_DISABLE_HBL
   	move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
   	move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL


	jsr Globals_ClearAll


    move.l #sprdefs_musicplayer,sysg_sprites_baseaddr
    move.l #sprdefs_musicplayer+2,sysg_sprites_baseaddr2
	
	jsr MEM_Init
	jsr MEM_AllocForMusicPlayer 
	

	move.l #0,g_game_loopaddr
	move.l #0,g_game_vbladdr

	jsr ClearVRAM

	jsr FADE_ClearAll
	jsr GOManager_Setup_Game	
	jsr SPRITE_InitVdpRamSpriteList
	jsr SPRITE_CopySpriteListToVRAM
	jsr SCROLL_UpdatePositionsVDP       

	move #0,g_vram_currentpos

    jsr Image_AddBlankCharacterToVDP
	
	move.l #ImageGroup_Screens_MusicPlayer,g_image_groupbase
	move #IMAGEASSET_Screens_MusicPlayer_musicplayer_fg,d0
	jsr IMAGE_ShowStaticImage_SkipGroup
	move #IMAGEASSET_Screens_MusicPlayer_musicplayer_fg,d0
	jsr IMAGE_ShowStaticImage_SkipGroup


    move #FONT_MUSICPLAYER_PAL0,g_font_index
	move #0,g_font_palette_index
    jsr FONT_Init
    jsr FONT_LoadPalette
    jsr FONT_LoadTiles_InlineVDP


	jsr FONT_ClearRamScreen
	jsr FONT_ClearRamScreen2


	jsr SOUND_Init
    move #0,d0
	move.b d0,sysg_debug_musictestindex
	jsr MUSIC_InitSong
	move.l #0,sysg_music+sgmusic_callbackfunc


	move.l #VDPADDR_SCROLL_A,sysg_debugpanel+debugpanel_windowaddr
	move.l #MusicPlayer_Options,sysg_debugpanel+debugpanel_optionsaddr
	move #0,sysg_debugpanel+debugpanel_cursorpos
        
    move #0,g_music+gmusic_resetFlag

	jsr DEBUGPANEL_InitForUI
	jsr DEBUGPANEL_Redraw

	bsr MusicPlayer_InitGOs

	FADE_SETVALUE 0
	FADE_START_IN 0
	


	move.l #UpdateState_MusicPlayer,g_game_loopaddr
	move.l #UpdateStateVBL_MusicPlayer,g_game_vbladdr



	rts


MusicPlayer_InitGOs:
	jsr UNITYTOOL_ResetVramSpriteIndex

    lea Palette_Sprites_MusicPlayer,a0
    move #1,d0
    jsr FADE_CopySinglePaletteToSource

	move.l #SPRITE_musicplayer_keypress,d0
	jsr UNITYTOOL_LoadSingleSprite
	
	
	move #6-1,d7
	moveq #0,d6
.lp:
	lea InitMusicPlayerKeyPress,a1
	jsr GOManager_SpawnGameObject_Car
	move d6,go_musicplayer_trackIndex(a1)
	addq #1,d6
	dbra d7,.lp

	move #1-1,d7
	moveq #0,d6
.lp1:
	lea InitMusicPlayerSample,a1
	jsr GOManager_SpawnGameObject_Car
	move d6,go_musicplayer_trackIndex(a1)
	addq #1,d6
	dbra d7,.lp1

	rts



InitMusicPlayerSample:
	

    SETSPR SPRITE_musicplayer_keypress
	move #80,go_x(a0)
	move #90,go_y(a0)
	SET_GO_PRIORITY GOPRIORITY_2
	move #PRIORITY,go_sprAttributes(a0)
    move.l #.update,go_onUpdate(a0)
    move #6,go_frame(a0)
	rts

.update:
    
    move.l sysg_music+sgmusic_m_SampleTracks,a1
	move go_word0(a0),d0
	add d0,a1
	
	GO_SET_INVISIBLE
	cmp.b #-1,sampletrack_debug_valueA(a1)
	beq .noton
	GO_SET_VISIBLE
.noton:
    moveq #0,d0
	move.b sampletrack_debug_valueA(a1),d0

	lea MusicPlayerSamplePositions,a1
	add d0,d0
	add d0,d0
	add d0,a1
	move (a1)+,go_x(a0)
	move (a1)+,go_y(a0)
	;sub #4,go_x(a0)
	;sub #4+3,go_y(a0)

	rts

.notonscreen:
	GO_SET_INVISIBLE
	rts

MusicPlayerSamplePositions:
.posx set 252
.posy set 172
    dc.w .posx+00,.posy
    dc.w .posx+08,.posy
    dc.w .posx+16,.posy
    dc.w .posx+24,.posy
    dc.w .posx+32,.posy
    dc.w .posx+40,.posy
    dc.w .posx+48,.posy
    dc.w .posx+56,.posy
.posy set 172+16
    dc.w .posx+00,.posy
    dc.w .posx+08,.posy
    dc.w .posx+16,.posy
    dc.w .posx+24,.posy
    dc.w .posx+32,.posy
    dc.w .posx+40,.posy
    dc.w .posx+48,.posy
    dc.w .posx+56,.posy




go_musicplayer_trackIndex equ go_word0
InitMusicPlayerKeyPress:
    SETSPR SPRITE_musicplayer_keypress
	move #80,go_x(a0)
	move #90,go_y(a0)
	SET_GO_PRIORITY GOPRIORITY_2
	move #PRIORITY,go_sprAttributes(a0)
    move.l #.update,go_onUpdate(a0)
    move.l #.render,go_onRender(a0)
	rts

.update:
    rts
.noton:
	rts
	
.render:
    move.l sysg_music+sgmusic_m_FMTracks,a1    ;lea MusicPlayer_FMTracks,a1
    move go_musicplayer_trackIndex(a0),d0
    mulu #track_structsize,d0
    add d0,a1

    lea track_debug_currentnote(a1),a3
    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    tst.b track_debug_noteon(a1)
    beq .noton
    
    SETSPR SPRITE_musicplayer_keypress

    move #4-1,d7
.renderlp:
    
    move (a3)+,d0   ; note
    lsr #4,d0

    cmp #0,d0
    ble .off
    cmp #12*8,d0
    bge .off

    lea MusicPlayerKeyPositions,a1
    add d0,d0
    add d0,d0
    add d0,a1
    move (a1)+,sprbuf_x(a5)
    move (a1)+,sprbuf_y(a5)
    
    sub #4,sprbuf_x(a5)
    sub #4,sprbuf_y(a5)
    
    move go_musicplayer_trackIndex(a0),sprbuf_frame(a5)
    ;move #0,sprbuf_frame(a5)
    move.w go_sprAttributes(a0),sprbuf_flags(a5)
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    
.off:
    dbra d7,.renderlp
    rts



MusicPlayer_UpdateGOs:
	rts

UpdateState_MusicPlayer:
	add #1,g_timer1
	bsr MusicPlayer_ShowInfo

    ;BORDER 49
	move #2000,d7
.lp: dbra d7,.lp    
    ;BORDER 0

	jsr PSG_UpdateSFX
	BORDER 49
	jsr MUSIC_UpdateSong
	BORDER 0

	jsr GOManager_Update	
	jsr MusicPlayer_UpdateSpriteFromGOManager

	jsr DEBUGPANEL_Update

    
    move.l sysg_music+sgmusic_baseaddr,DebugArea
    
	tst g_music+gmusic_resetFlag
	beq .noreset
	move #0,g_music+gmusic_resetFlag
    move.l #$f0000,sysg_music+sgmusic_baseaddr

	move #0,d0
	move.b d0,sysg_debug_musictestindex
	jsr MUSIC_InitSong
.noreset:

	rts


MUSPLAYER_INFO_Y equ 20

MUSPLAYER_STATS_Y equ 5

MusicPlayer_ShowInfo:
	FONT_DRAW_AT VDPADDR_SCROLL_A,.txt0,1,MUSPLAYER_INFO_Y
	FONT_DRAW_AT VDPADDR_SCROLL_A,.txt1,1,(MUSPLAYER_INFO_Y+1)
	FONT_DRAW_AT VDPADDR_SCROLL_A,.txt1a,1,(MUSPLAYER_INFO_Y+2)
	FONT_DRAW_AT VDPADDR_SCROLL_A,.txt1b,1,(MUSPLAYER_INFO_Y+3)

	move g_music+gmusic_num_fm_tracks,d0
	FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (1+20),MUSPLAYER_INFO_Y

    bsr .count_mod_tracks
	move g_music+gmusic_num_active_fmmodifier_tracks,d0
	FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (1+20),(MUSPLAYER_INFO_Y+1)

	move g_music+gmusic_num_sample_tracks,d0
	FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (1+20),(MUSPLAYER_INFO_Y+2)

	move #0,d0
	FONT_DRAW_NUMBER2_AT VDPADDR_SCROLL_A, d0, (1+20),(MUSPLAYER_INFO_Y+3)


	moveq #0,d2
	move.b sysg_debug_musictestindex,d0
	jsr MUSIC_GetSong
	move.l a0,a2
	lea musicbase_titlestring(a2),a2
	move #1+8,d1		;x
	move #(MUSPLAYER_INFO_Y-2),d2		;y
	jsr MusicPlayer_PrintAt

	FONT_DRAW_AT VDPADDR_SCROLL_A,.txt2,1,(MUSPLAYER_INFO_Y-2)

	
	bsr MusicPlayer_ShowInfo_Note
	bsr MusicPlayer_ShowInfo_Arpeggiator
	bsr MusicPlayer_ShowInfo_Portamento
	bsr MusicPlayer_ShowInfo_Vibrato
	bsr MusicPlayer_ShowInfo_Instrument

	bsr MusicPlayer_ShowInfo_FMMod

	rts
.count_mod_tracks:
    move #0,g_music+gmusic_num_active_fmmodifier_tracks
	move.l sysg_music+sgmusic_m_FMModTracks,a1
    move #SOUND_MAX_FMMOD_TRACKS-1,d7
.findloop:
    tst.b fmmodtrack_active(a1)
    beq .notactive
    add #1,g_music+gmusic_num_active_fmmodifier_tracks
.notactive:
    lea fmmodtrack_structsize(a1),a1
    dbra d7,.findloop

    rts

.txt0: dc.b	'NUM FM TRACKS:',ETX
.txt1: dc.b	'NUM FMMOD TRACKS:',ETX
.txt1a: dc.b'NUM SAMPLE TRACKS:',ETX
.txt1b: dc.b'NUM PSG TRACKS:',ETX
.txt2: dc.b	'SONG:',ETX
	align 2


; d1 = x. d2 = y. a2 = text
MusicPlayer_PrintAt:
	PUSHALL

	and.l #$ffff,d1
	and.l #$ffff,d2
	lsl #7,d2
	add d1,d1
	add d2,d1
	add.l #VDPADDR_SCROLL_A,d1
	move.l d1,d0

    jsr	VDP_BuildAndSetVRAMWriteAddress	
	move.l a2,a0
	jsr FONT_DrawText

	POPALL
	rts

; d1 = x. d2 = y. d3 = number
MusicPlayer_NumberAt:
	PUSHALL

	and.l #$ffff,d1
	and.l #$ffff,d2
	lsl #7,d2
	add d1,d1
	add d2,d1
	add.l #VDPADDR_SCROLL_A,d1
	move.l d1,d0

    jsr	VDP_BuildAndSetVRAMWriteAddress	

	move d3,d0
	move.l a2,a0
	jsr FONT_DrawNumber_Byte

	POPALL
	rts

MusicPlayer_NumberAt_SingleChar:
	PUSHALL

	and.l #$ffff,d1
	and.l #$ffff,d2
	lsl #7,d2
	add d1,d1
	add d2,d1
	add.l #VDPADDR_SCROLL_A,d1
	move.l d1,d0

    jsr	VDP_BuildAndSetVRAMWriteAddress	

	move d3,d0
	move.l a2,a0
	jsr FONT_DrawNumber_Byte_SingleChar

	POPALL
	rts


MusicPlayer_ShowInfo_FMMod:
	move.l sysg_music+sgmusic_m_FMModTracks,a0     ; lea MusicPlayer_FMModTracks,a0
	move #SOUND_MAX_FMMOD_TRACKS,d7
	beq .return
	subq #1,d7

	move #20,d1		;x
	move #MUSPLAYER_STATS_Y+6,d2		;y

.lp:
    tst.b fmmodtrack_active(a0)
    beq .notactive

	moveq #0,d3
	move.w fmmodtrack_fmtrack_index(a0),d3
	bsr MusicPlayer_NumberAt_SingleChar


	cmp.b #0,fmtrack_debug_mode(a0)
	bne .notmode_wave

	add #2,d1
	moveq #0,d3
	move.b fmtrack_debug_operator(a0),d3
	lea .operatortext,a2
	lsl #2,d3
	add d3,a2
	bsr MusicPlayer_PrintAt

	add #4,d1
	moveq #0,d3
	move.b fmtrack_debug_register(a0),d3
	lea .registerstext,a2
	lsl #2,d3
	add d3,a2
	bsr MusicPlayer_PrintAt

	add #4,d1
	moveq #0,d3
	move.b fmtrack_debug_value(a0),d3
	bsr MusicPlayer_NumberAt
	
	sub #10,d1
	bra .next
.notmode_wave:
	cmp.b #1,fmtrack_debug_mode(a0)
	bne .notmode_rest
	lea .resttext,a2
	bsr MusicPlayer_PrintAt
	bra .next

.notmode_rest:
	cmp.b #2,fmtrack_debug_mode(a0)
	bne .notmode_set
	lea .settext,a2
	bsr MusicPlayer_PrintAt
	
	add #4,d1
	moveq #0,d3
	move.b fmtrack_debug_operator(a0),d3
	lea .operatortext,a2
	lsl #2,d3
	add d3,a2
	bsr MusicPlayer_PrintAt

	add #4,d1
	moveq #0,d3
	move.b fmtrack_debug_register(a0),d3
	lea .registerstext,a2
	lsl #2,d3
	add d3,a2
	bsr MusicPlayer_PrintAt

	add #4,d1
	moveq #0,d3
	move.b fmtrack_debug_value(a0),d3
	bsr MusicPlayer_NumberAt

	sub #12,d1

	bra .next
.notmode_set:

.next:
	add #1,d2
.notactive:
	lea fmmodtrack_structsize(a0),a0
	dbra d7,.lp

.return:
	rts
.cleartext:
	dc.b '                ',ETX
.operatortext:
	dc.b 'OP1',ETX
	dc.b 'OP2',ETX
	dc.b 'OP3',ETX
	dc.b 'OP4',ETX
	dc.b 'GLO',ETX
.resttext:
	dc.b 'R',ETX
.settext:
	dc.b 'SET',ETX
.registerstext:
	dc.b 'TL ',ETX	;OPERATOR_TOTALLEVEL
	dc.b 'AR ',ETX	;OPERATOR_ATTACKRATE
	dc.b 'DR ',ETX	;OPERATOR_DECAYRATE
	dc.b 'SL ',ETX	;OPERATOR_SUSTAINLEVEL
	dc.b 'DR2',ETX	;OPERATOR_DECAYRATE2
	dc.b 'RR ',ETX	;OPERATOR_RELEASERATE
	dc.b 'MUL',ETX	;OPERATOR_MULTIPLIER
	dc.b 'DT ',ETX	;OPERATOR_DETUNE
	dc.b 'RS ',ETX	;OPERATOR_RATESCALING
	dc.b 'SSG ',ETX	;OPERATOR_SSG
	align 2


MusicPlayer_ShowInfo_Note:
	move.l sysg_music+sgmusic_m_FMTracks,a0    ;lea MusicPlayer_FMTracks,a0
	move g_music+gmusic_num_fm_tracks,d7
	beq .return
	subq #1,d7

	move #28,d1		;x
	move #MUSPLAYER_STATS_Y,d2		;y

.lp:
	lea .offtxt,a2
	move.b track_debug_noteon(a0),d0
	beq .off
	lea .ontxt,a2
.off:
	bsr MusicPlayer_PrintAt

	add #1,d2
	lea track_structsize(a0),a0
	dbra d7,.lp

.return:
	rts
.ontxt dc.b	'X',ETX
.offtxt dc.b	'.',ETX
	align 2

MusicPlayer_ShowInfo_Arpeggiator:
	move.l sysg_music+sgmusic_m_FMTracks,a0    ;lea MusicPlayer_FMTracks,a0
	move g_music+gmusic_num_fm_tracks,d7
	beq .return
	subq #1,d7

	move #30,d1		;x
	move #MUSPLAYER_STATS_Y,d2		;y

.lp:
	lea .offtxt,a2
	move.b track_debug_arpeggio(a0),d0
	beq .off
	lea .ontxt,a2
.off:
	bsr MusicPlayer_PrintAt

	add #1,d2
	lea track_structsize(a0),a0
	dbra d7,.lp

.return:
	rts
.ontxt dc.b	'A',ETX
.offtxt dc.b	'.',ETX
	align 2

MusicPlayer_ShowInfo_Portamento:
	move.l sysg_music+sgmusic_m_FMTracks,a0    ;lea MusicPlayer_FMTracks,a0
	move g_music+gmusic_num_fm_tracks,d7
	beq .return
	subq #1,d7

	move #32,d1		;x
	move #MUSPLAYER_STATS_Y,d2		;y

.lp:
	lea .offtxt,a2
	move.b track_debug_portamento(a0),d0
	beq .off
	lea .ontxt,a2
.off:
	bsr MusicPlayer_PrintAt

	add #1,d2
	lea track_structsize(a0),a0
	dbra d7,.lp

.return:
	rts
.ontxt dc.b	'P',ETX
.offtxt dc.b	'.',ETX
	align 2



MusicPlayer_ShowInfo_Instrument:
	move.l sysg_music+sgmusic_m_FMTracks,a0    ;lea MusicPlayer_FMTracks,a0
	move g_music+gmusic_num_fm_tracks,d7
	beq .return
	subq #1,d7

    move.l sysg_music+sgmusic_instrumentNameListAddr,a3
    lea 2(a3),a3

	move #21,d1		;x
	move #MUSPLAYER_STATS_Y,d2		;y

.lp:
    move.l a3,a2
    moveq #0,d4
    move.b track_debug_instrumentIndex(a0),d4
    lsl #3,d4
    add d4,a2
    
	bsr MusicPlayer_PrintAt

	add #1,d2
	lea track_structsize(a0),a0
	dbra d7,.lp
.return:
    rts

MusicPlayer_ShowInfo_Vibrato:
	move.l sysg_music+sgmusic_m_FMTracks,a0    ;lea MusicPlayer_FMTracks,a0
	move g_music+gmusic_num_fm_tracks,d7
	beq .return
	subq #1,d7

	move #34,d1		;x
	move #MUSPLAYER_STATS_Y,d2		;y

.lp:
	lea .offtxt,a2
	move.b track_debug_vibrato(a0),d0
	beq .off
	lea .ontxt,a2
.off:
	bsr MusicPlayer_PrintAt

	add #1,d2
	lea track_structsize(a0),a0
	dbra d7,.lp

.return:
	rts
.ontxt dc.b	'V',ETX
.offtxt dc.b	'.',ETX
	align 2




UpdateStateVBL_MusicPlayer:	
	jsr SPRITE_CopySpriteListToVRAM_DMA	
	jsr FADE_Update

	jsr DEBUGPANEL_UpdateVBL

;	tst.l g_font_ramscreen_addr
;	beq .noramscreen
;	move #ACH_LIST_Y,d0
;	move #ACH_LIST_Y+12,d1
;	jsr FONT_DMA_RamScreen
;.noramscreen:

	;jsr ColorBars_HBL_InitForFrame


	rts


MusicPlayer_StopForFadeout:
	move.l #0,m_font_ramscreen_addr
	move.l #0,g_game_loopaddr
	rts

ExitState_MusicPlayer:
	move.l #0,g_game_vbladdr
	move.l #0,g_game_loopaddr
	move.l #0,sysg_music+sgmusic_callbackfunc
	VDP_DISABLE_HBL
	rts


MusicPlayer_Options:
	dc.w 2,MENUFLAGS_USE_START
	dc.w 0,5

	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMTracks+(track_structsize*0)+track_enabled, 0, .enabled0
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMTracks+(track_structsize*1)+track_enabled, 0, .enabled1
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMTracks+(track_structsize*2)+track_enabled, 0, .enabled2
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMTracks+(track_structsize*3)+track_enabled, 0, .enabled3
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMTracks+(track_structsize*4)+track_enabled, 0, .enabled4
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMTracks+(track_structsize*5)+track_enabled, 0, .enabled5

	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMModTracks+(fmmodtrack_structsize*0)+fmmodtrack_enabled, 0, .modenabled0
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMModTracks+(fmmodtrack_structsize*1)+fmmodtrack_enabled, 0, .modenabled1
	;dc.b MENUOPTION_TOGGLE,0
	;dc.l MusicPlayer_FMModTracks+(fmmodtrack_structsize*2)+fmmodtrack_enabled, 0, .modenabled2

	dc.b MENUOPTION_BYTE,0
	dc.l g_music+gmusic_delay+1, 0, .delay

	dc.b MENUOPTION_BYTE_BUTTON,0
	dc.l sysg_debug_musictestindex, MusicPlayer_ButtonPressed_TestMusic, .testmusic


.enabled0	dc.b	'CH 0',ETX
.enabled1	dc.b	'CH 1',ETX
.enabled2	dc.b	'CH 2',ETX
.enabled3	dc.b	'CH 3',ETX
.enabled4	dc.b	'CH 4',ETX
.enabled5	dc.b	'CH 5',ETX
.modenabled0 dc.b	'MOD 0',ETX
.modenabled1 dc.b	'MOD 1',ETX
.modenabled2 dc.b	'MOD 2',ETX
.testmusic  dc.b	'TEST MUSIC',ETX
.delay  dc.b	'DELAY',ETX

.text_quit	dc.b	'QUIT',ETX
.text_next	dc.b	'NEXT PAGE',ETX
	align 2

MusicPlayer_Options_ButtonPressed_Next:
	rts


MusicPlayer_ButtonPressed_TestMusic:
	lea .fadedout,a1
	jsr SOUND_StartFadeOut_WithCallback
	rts
.fadedout:
	jsr SOUND_Init
	move.l #NewMusic,sysg_music+sgmusic_baseaddr
	moveq #0,d0
	move.b sysg_debug_musictestindex,d0
	jsr MUSIC_InitSong
	rts

MusicPlayerKeyPositions:
.whitex set 7
.whitey set 205
.blackx set 12
.blacky set 201
.keyadd set 9
	rept 5
	dc.w .whitex,.whitey		;C
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky			;C#
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;D
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;D#
.blackx set .blackx+.keyadd
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;E
.whitex set .whitex+.keyadd
	dc.w .whitex,.whitey		;F
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;F#
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;G
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;G#
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;A
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;A#
.blackx set .blackx+.keyadd
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;B
.whitex set .whitex+.keyadd
	endr


.whitex set 7
.whitey set 218
.blackx set 12
.blacky set 215
	rept 5
	dc.w .whitex,.whitey		;C
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;C#
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;D
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;D#
.blackx set .blackx+.keyadd
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;E
.whitex set .whitex+.keyadd
	dc.w .whitex,.whitey		;F
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;F#
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;G
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;G#
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;A
.whitex set .whitex+.keyadd
	dc.w .blackx,.blacky		;A#
.blackx set .blackx+.keyadd
.blackx set .blackx+.keyadd
	dc.w .whitex,.whitey		;B
.whitex set .whitex+.keyadd
	endr


MusicPlayer_RegisterTexts:
    rts


MusicPlayer_UpdateSpriteFromGOManager:
	bsr SPRITE_InitRegistersForRender
.start:
    

    jsr GOManager_GetList_Car
    move.l golist_active_list_addr(a3),a4
    move   golist_num_active(a3),d7
    bsr SPRITE_UpdateFromGOManager_Hol_Inner_DoOne
.no2:

    cmp #MAX_SPRITES,d6
    bge .rts

.rts
    bsr SPRITE_UpdateFromGOManager_AfterAllDone

    rts



MusicPlayer_AddSprgroupSprites:
	movem.l d7/a0,-(sp)
	lea Scratchpad,a0
	move (a0)+,d7
	bra .next	;subq #1,d7
.lp:

;	UPDATESPR_GETGROUP
	
	move.l sprbuf_sprgroup(a0),a2
	add.l #sprgroup_firstFrame,a2
    move.w sprbuf_frame(a0),d0                  ; frame
	lsl #sprgroupframe_sizeshift,d0	; couple of scans extra for mult
	add d0,a2	

;UPDATESPR_1a go_y(a0)
	move.w sprbuf_y(a0),d0 
	sub d4,d0
	swap d4
	sub.w (a2)+,d0
	swap d0

;UPDATESPR_2
    move.w d6,d0                ; link  
	or.w (a2)+,d0
	move.l d0,(a5)+

	move.w sprbuf_vdpbase(a0),d0

	add.w (a2)+,d0		;sprgroupframe_charoffset(a2)    
    and.w #$7ff,d0
	or.w (a2)+,d0	;sprgroupframe_paletteFlags(a2)
	or.w sprbuf_flags(a0),d0
	or #PAL_3,d0
	swap d0

;   UPDATESPR_4a go_x(a0)
    move.w sprbuf_x(a0),d0
	sub d4,d0
	swap d4
	sub.w (a2),d0	;sprgroupframe_originx(a2)
   ; and.w d3,d0	;#$1ff,d0
    move.l d0,(a5)+

;	UPDATESPR_5
	addq #1,d6

	lea sprbuf_size(a0),a0

.next:
	dbra d7,.lp
	movem.l (sp)+,d7/a0
	rts
