TEXTSTR macro \1
    dc.b \1,ETX
    align 2
    endm

CutScene_TryExit:
    PUSHALL
    move.l sysg_cutscene+cs_sysg_onstop_cb,a1
    jsr (a1)
    POPALL
    rts

CutScene_InitSprites:

    jsr Image_AddBlankCharacterToVDP

	;move #IMAGEASSET_TITLESCREEN,d0
	;jsr IMAGE_ShowStaticImagePlaneB


	move #FONT_CUBEDROID_FONT0,g_font_index
	move #1,g_font_palette_index
	jsr FONT_InitAll

    ;lea SPRPAL_Cutscene,a0
    ;move #0,d0
    ;jsr FADE_CopySinglePaletteToSource
 
    ;lea SPRPAL_UI,a0
    ;move #1,d0
    ;jsr FADE_CopySinglePaletteToSource

    ;lea SPRPAL_UI_Players,a0
    ;move #2,d0
    ;jsr FADE_CopySinglePaletteToSource

    ;move #SPRITE_CUTSCENE,d0
    ;jsr UNITYTOOL_LoadSingleSprite

    ;move #SPRITE_UI,d0
    ;jsr UNITYTOOL_LoadSingleSprite

    ;move #SPRITE_UI_PLAYERS,d0
    ;jsr UNITYTOOL_LoadSingleSprite

    lea g_cutscene,a5
    
    lea Cutscene_TextGameObj,a1
    jsr GOManager_SpawnGameObject_UIScreen
    lea cs_textObjs(a5),a2
    add #cs_textobj_structsize*0,a2 
    move.l a2,g_textrender_textaddr(a1)

    lea Cutscene_TextGameObj,a1
    jsr GOManager_SpawnGameObject_UIScreen
    lea cs_textObjs(a5),a2
    add #cs_textobj_structsize*1,a2 
    move.l a2,g_textrender_textaddr(a1)

    lea Cutscene_TextGameObj,a1
    jsr GOManager_SpawnGameObject_UIScreen
    lea cs_textObjs(a5),a2
    add #cs_textobj_structsize*2,a2 
    move.l a2,g_textrender_textaddr(a1)

    lea Cutscene_TextGameObj,a1
    jsr GOManager_SpawnGameObject_UIScreen
    lea cs_textObjs(a5),a2
    add #cs_textobj_structsize*3,a2 
    move.l a2,g_textrender_textaddr(a1)

    move #0,RamPalettes

    rts



g_textrender_textaddr equ go_long0
Cutscene_TextGameObj:
    move.l #Cutscene_RenderTextGameObj,go_onRender(a0)
    move.l #.update,go_onUpdate(a0)
    rts
.update:
    move.l g_textrender_textaddr(a0),a1
    add #1,cs_textobj_timer(a1)
    rts
    
Cutscene_RenderTextGameObj:
    PUSHALL
    move.l #SPRGROUP_InternalTextSprites,go_sprgroup(a0)       ;	move.l (sprdefs+2+(\1*4)),go_sprgroup(a0)
    move.w g_vram_font,go_vdpbase(a0)

    lea Scratchpad,a4
    lea 2(a4),a5
    move #0,(a4)
    
    
    move.l g_textrender_textaddr(a0),a1 
    tst cs_textobj_active(a1)
    beq .exit
    
    move cs_textobj_tox(a1),d5
    move cs_textobj_toy(a1),d6
    lea cs_textobj_string(a1),a2
.lp:
    moveq #0,d0
    move.b (a2)+,d0
    beq .exit
    sub #32,d0
    bsr .render_doone
    add #8,d5
    bra .lp
    
.exit:
    POPALL
    rts
    
;d3 / d4 from pos
; d5 / d6 to pos
.render_doone:
    PUSHREGS d0-d7
    move d0,sprbuf_frame(a5)
    
    ; timer is incremented in update
    ; get timer, subtract the index of the letter '(a4)' - and limit it to 0-15
    move cs_textobj_timer(a1),d1
    sub (a4),d1
    bge .nomin
    move #0,d1
.nomin
    cmp #15,d1
    blt .nomax
    move #15,d1
.nomax:
    
    moveq #0,d0
    move d5,d0
    sub cs_textobj_fromx(a1),d0
    muls d1,d0
    asr.w #4,d0
    add cs_textobj_fromx(a1),d0
    move d0,d5
    
    moveq #0,d0
    move d6,d0
    sub cs_textobj_fromy(a1),d0
    muls d1,d0
    asr.w #4,d0
    add cs_textobj_fromy(a1),d0
    move d0,d6

    
    move d5,sprbuf_x(a5)    
    move d6,sprbuf_y(a5)        
    move.w #PAL_1,sprbuf_flags(a5)
    move.l go_sprgroup(a0),sprbuf_sprgroup(a5)
    move.w go_vdpbase(a0),sprbuf_vdpbase(a5)
    lea sprbuf_size(a5),a5
    add #1,(a4)	
    POPREGS d0-d7
    rts

    clrso
cs_textobj_active    so.w 1
cs_textobj_timer    so.w 1
cs_textobj_tox    so.w 1
cs_textobj_toy    so.w 1
cs_textobj_fromx    so.w 1
cs_textobj_fromy    so.w 1
cs_textobj_string so.b 32
cs_textobj_structsize so.b 0

    clrso
cs_sysg_start_ptr       so.l 1
cs_sysg_next_screen_ptr so.l 1
cs_sysg_onstop_cb       so.l 1
cs_sysg_structsize      so.b 0

    clrso
cs_command_ptr      so.l 1
cs_timer            so.w 1
cs_active           so.w 1
cs_next_gameobj_ptr so.l 1
cs_gameobjects      so.l 16
cs_textTimers       so.w 4
cs_useTextTimers    so.w 1
cs_updateMode       so.w 1
cs_textObjs         so.b cs_textobj_structsize*4
cs_structsize       so.w 1

CS_UPDATEMODE_COMMANDS equ 0
CS_UPDATEMODE_WAITTIMER equ 1
CS_UPDATEMODE_WAITFORBUTTON equ 2
CS_UPDATEMODE_STOPPED equ 3

CS_SPEECHTIME   equ 100

CutScene_SetUp:
    move.l a0,sysg_cutscene+cs_sysg_start_ptr
    move.l a1,sysg_cutscene+cs_sysg_next_screen_ptr
    rts
    
    ; a1
CutScene_SetStopFunction:
    move.l a1,sysg_cutscene+cs_sysg_onstop_cb
    rts

InitCutscene:
    lea g_cutscene,a5
    
    lea sysg_cutscene,a3
    move.l cs_sysg_start_ptr(a3),cs_command_ptr(a5)
    
    move #0,cs_timer(a5)
    lea cs_gameobjects(a5),a4
    move.l a4,cs_next_gameobj_ptr(a5)
    move #1,cs_active(a5)
    
    lea cs_textTimers(a5),a0
    move.w #0,(a0)+
    move.w #0,(a0)+
    move.w #0,(a0)+
    move.w #0,(a0)+
    
    bsr CutScene_ClearAllText 
    
    move #CS_UPDATEMODE_COMMANDS,cs_updateMode(a5)
    
    move #1,cs_useTextTimers(a5)
    rts
    
UpdateCutScene:
    lea g_cutscene,a5
    tst cs_active(a5)
    beq .exit

    tst cs_useTextTimers(a5)
    beq .notexttimers
    
    lea cs_textTimers(a5),a0
    move #4-1,d7
    move #0,d0
.cleartextloop:
    tst (a0)
    beq .txtlp_next
    sub #1,(a0)
    bne .txtlp_next
    
    bsr CutScene_ClearTextLine
.txtlp_next:
    addq #1,d0
    lea 2(a0),a0
    dbra d7,.cleartextloop
.notexttimers:


    cmp #CS_UPDATEMODE_COMMANDS,cs_updateMode(a5)
    beq .state_commands
    cmp #CS_UPDATEMODE_WAITTIMER,cs_updateMode(a5)
    beq .state_waittimer
    cmp #CS_UPDATEMODE_WAITFORBUTTON,cs_updateMode(a5)
    beq .state_waitforbutton
    rts

.state_waitforbutton:
    move g_pad0_pressed,d0
    btst #pad_button_a,d0
    beq .exit

    VRAM_GETCHARPOS_A 0,20
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move #32,d0	
    jsr FONT_ClearSpace
    
    move #CS_UPDATEMODE_COMMANDS,cs_updateMode(a5)
    bra .state_commands    


.state_waittimer:
    sub #1,cs_timer(a5)
    bgt .exit
    move #CS_UPDATEMODE_COMMANDS,cs_updateMode(a5)
    bra .state_commands    
    

.state_commands:
    move.l cs_command_ptr(a5),a4

.command_loop:
    move.l (a4),a1
    jsr (a1)
    move.l a4,cs_command_ptr(a5)
    
    cmp #CS_UPDATEMODE_COMMANDS,cs_updateMode(a5)
    beq .command_loop
    
    
.no_command:
.exit
    rts



;-------------------------------------------------------------------------------------------------
CS_SetTextTimers_value equ 4
CS_SetTextTimers_commandsize equ 6
CS_SetTextTimers macro \1
    dc.l CSCommand_SetTextTimers
    dc.w \1
    endm

CSCommand_SetTextTimers:
    move.w CS_SetTextTimers_value(a4),cs_useTextTimers(a5)
    add.l #CS_SetTextTimers_commandsize,a4
    rts



;-------------------------------------------------------------------------------------------------
    setso 4
CS_AddObjAt_GOInitFunc so.l 1
CS_AddObjAt_x so.w 1
CS_AddObjAt_y so.w 1
CS_AddObjAt_commandsize so.w 1

CS_AddObjAt macro \1,\2,\3
    dc.l CSCommand_AddObjectAt
    dc.l \1     ; GO init 
    dc.w \2,\3  ;x,y
    endm

CSCommand_AddObjectAt:
    move.l CS_AddObjAt_GOInitFunc(a4),a1
    jsr GOManager_SpawnGameObject_UIScreen
    move.l #0,go_cutscene_cb(a1)
    move.w CS_AddObjAt_x(a4),go_x(a1)
    move.w CS_AddObjAt_y(a4),go_y(a1)
    
    move.l cs_next_gameobj_ptr(a5),a3
    move.l a1,(a3)
    add.l #4,cs_next_gameobj_ptr(a5)
    
    add.l #CS_AddObjAt_commandsize,a4
    rts

;-------------------------------------------------------------------------------------------------
        setso 4
CS_AddObj_GOInitFunc so.l 1
CS_AddObj_commandsize so.w 0
CS_AddObj macro \1
    dc.l CSCommand_AddObject
    dc.l \1     ; GO init 
    endm

CSCommand_AddObject:
    move.l CS_AddObj_GOInitFunc(a4),a1
    jsr GOManager_SpawnGameObject_UIScreen
    move.l #0,go_cutscene_cb(a1)
    
    move.l cs_next_gameobj_ptr(a5),a3
    move.l a1,(a3)
    add.l #4,cs_next_gameobj_ptr(a5)
    
    add.l #CS_AddObj_commandsize,a4
    rts

;-------------------------------------------------------------------------------------------------

        setso 4
CS_ClearSpeech_commandsize so.w 0
CS_ClearSpeech macro
    dc.l CSCommand_ClearSpeech
    endm



CSCommand_ClearSpeech:
    
    bsr CutScene_ClearAllText
    
    add.l #CS_ClearSpeech_commandsize,a4
    rts

;-------------------------------------------------------------------------------------------------

        setso 4
CS_CharSpeech_index so.w 1
CS_CharSpeech_go_offset so.w 1
CS_CharSpeech_speechaddr so.l 1
CS_CharSpeech_commandsize so.w 0
CS_CharSpeech macro \1,\2,\3
    dc.l CSCommand_CharSpeech
    dc.w \1
    dc.w \2*4
    dc.l \3
    endm


CSCommand_CharSpeech:
    PUSHALL
    
    lea cs_gameobjects(a5),a3
    add CS_CharSpeech_go_offset(a4),a3
    move.l (a3),a0      ; gameobj addr
    
    
    move.l CS_CharSpeech_speechaddr(a4),a2
    bsr Cutscene_GetTextPixelsize
    lsr #1,d0
    
    
    move go_x(a0),d1
    sub d0,d1
    move go_y(a0),d2
    sub #64,d2    
    move.w CS_CharSpeech_index(a4),d3
    mulu #10,d3
    add d3,d2
    move.w CS_CharSpeech_index(a4),d0
    move go_x(a0),d3
    move go_y(a0),d4
    sub #16,d4

    bsr CutScene_SetSpeech        
    
.exit:
    POPALL
    add.l #CS_CharSpeech_commandsize,a4
    rts

;-------------------------------------------------------------------------------------------------

        setso 4
CS_Speech_index so.w 1
CS_Speech_speechaddr so.l 1
CS_Speech_commandsize so.w 0
CS_Speech macro \1,\2
    dc.l CSCommand_Speech
    dc.w \1
    dc.l \2
    endm



CSCommand_Speech:
    PUSHALL
    move.w CS_Speech_index(a4),d0
    move.l CS_Speech_speechaddr(a4),a2
    move #16,d1    
    move #16,d2    
    move.w CS_Speech_index(a4),d3
    lsl #3,d3
    add d3,d2
    move #0,d3
    move #0,d4
    bsr CutScene_SetSpeech    

    POPALL
    add.l #CS_Speech_commandsize,a4
    rts


; d0 speech spr index
; d1 topos x
; d2 topos y
; d3 startpos x
; d4 startpos y
; a2 text addr
CutScene_SetSpeech:
    PUSHALL
    move d0,d5
    lea cs_textTimers(a5),a0
    add d5,d5
    move #CS_SPEECHTIME,(a0,d5)

    lea cs_textObjs(a5),a1
    mulu #cs_textobj_structsize,d0
    add d0,a1
    
    move d3,cs_textobj_fromx(a1)
    move d4,cs_textobj_fromy(a1)
    move #0,cs_textobj_timer(a1)
    move #1,cs_textobj_active(a1)
    move d1,cs_textobj_tox(a1)
    move d2,cs_textobj_toy(a1)
    lea cs_textobj_string(a1),a3
    move #31,d7 
.cpylp:
    move.b (a2)+,(a3)+
    dbra d7,.cpylp
    POPALL
    rts

; a2 text addr
; returns d0
Cutscene_GetTextPixelsize:
    movem.l a3/d1,-(sp)
    move.l a2,a3
    move #0,d0
.lp:
    move.b (a3)+,d1
    beq .done
    add #8,d0
    bra .lp
.done:
    movem.l (sp)+,a3/d1
    rts
         

        
CutScene_ClearAllText:
    move #0,d0
    bsr CutScene_ClearTextLine
    move #1,d0
    bsr CutScene_ClearTextLine
    move #2,d0
    bsr CutScene_ClearTextLine
    move #3,d0
    bsr CutScene_ClearTextLine
    rts


; d0 is line index
CutScene_ClearTextLine:
    PUSHALL
    lea cs_textObjs(a5),a1
    mulu #cs_textobj_structsize,d0
    add d0,a1
    move #0,cs_textobj_active(a1)
    POPALL
    rts

;-------------------------------------------------------------------------------------------------

    setso 4
CS_GoFunc_go_offset so.w 1
CS_GOFunc_funcaddr so.l 1
CS_GOFunc_structsize so.w 0
CS_GOFunc macro \1,\2
    dc.l CSCommand_GOFunc
    dc.w \1*4     ; game object index (times 4 for addressing)
    dc.l \2     ; func to call on gameobject
    endm

CSCommand_GOFunc:
    PUSHALL
    lea cs_gameobjects(a5),a3
    add CS_GoFunc_go_offset(a4),a3
    move.l (a3),a0      ; gameobj addr
    move.l CS_GOFunc_funcaddr(a4),a1
    jsr (a1)
    POPALL
    add.l #CS_GOFunc_structsize,a4
    rts

;-------------------------------------------------------------------------------------------------

    setso 4
CS_GoFrame_go_offset so.w 1
CS_GOFrame_frame_index so.w 1
CS_GOFrame_structsize so.w 0
CS_GOFrame macro \1,\2
    dc.l CSCommand_CS_GOFrame
    dc.w \1*4     ; game object index (times 4 for addressing)
    dc.w \2     ; func to call on gameobject
    endm

CSCommand_CS_GOFrame:
    PUSHALL
    lea cs_gameobjects(a5),a3
    add CS_GoFrame_go_offset(a4),a3
    move.l (a3),a0      ; gameobj addr
    move CS_GOFrame_frame_index(a4),go_frame(a0)
    POPALL
    add.l #CS_GOFrame_structsize,a4
    rts

;-------------------------------------------------------------------------------------------------

    setso 4
CS_WaitForButton_structsize so.w 0
CS_WaitForButton macro \1
    dc.l CSCommand_WaitForButton
    endm

CSCommand_WaitForButton:
    VRAM_GETCHARPOS_A 6,20
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    lea .text,a0
    jsr FONT_DrawText
    
    move #CS_UPDATEMODE_WAITFORBUTTON,cs_updateMode(a5)
    add.l #CS_WaitForButton_structsize,a4
    rts
.text: dc.b "Press A to continue",ETX
    align 2


;-------------------------------------------------------------------------------------------------
    
        setso 4
CS_Move_go_offset so.w 1
CS_Move_x_offset so.w 1
CS_Move_commandsize so.w 0
CS_Move macro \1,\2
    dc.l CSCommand_Move
    dc.w \1*4     ; game object index (times 4 for addressing)
    dc.w \2     ; x offset
    endm
    
CSCommand_Move:
    lea cs_gameobjects(a5),a3
    add CS_Move_go_offset(a4),a3
    move.l (a3),a0
    move.l #.updatego,go_cutscene_cb(a0)
    move go_x(a0),d0
    add CS_Move_x_offset(a4),d0
    move d0,go_tox(a0)
    add.l #CS_Move_commandsize,a4
    rts

.updatego:
    move #0,go_sprAttributes(a0)
    move #1,d1
    move go_tox(a0),d0
    cmp go_x(a0),d0
    beq .done
    bgt .right
    move #FLIP_H,go_sprAttributes(a0)
    move #-1,d1
.right

    add d1,go_x(a0)
.done:
.ok: rts

;-------------------------------------------------------------------------------------------------
    setso 4
CS_MoveTo_go_offset so.w 1
CS_MoveTo_x_pos so.w 1
CS_MoveTo_commandsize so.w 0
CS_MoveTo macro \1,\2
    dc.l CSCommand_MoveTo
    dc.w \1*4     ; game object index (times 4 for addressing)
    dc.w \2     ; x pos
    endm

CSCommand_MoveTo:
    lea cs_gameobjects(a5),a3
    add CS_MoveTo_go_offset(a4),a3
    move.l (a3),a0
    move.l #.updatego,go_cutscene_cb(a0)
    move CS_MoveTo_x_pos(a4),go_tox(a0)
    add.l #CS_MoveTo_commandsize,a4
    rts

.updatego:
    move #0,go_sprAttributes(a0)
    move #1,d1
    move go_tox(a0),d0
    cmp go_x(a0),d0
    beq .done
    bgt .right
    move #FLIP_H,go_sprAttributes(a0)
    move #-1,d1
.right

    add d1,go_x(a0)
.done:
.ok: rts

;-------------------------------------------------------------------------------------------------
    setso 4
CS_Stop_commandsize so.w 0
CS_Stop macro \1
    dc.l CSCommand_Stop
    endm    

CSCommand_Stop:
    move #0,cs_active(a5)
    jsr CutScene_TryExit
    move #CS_UPDATEMODE_STOPPED,cs_updateMode(a5)
    rts

;-------------------------------------------------------------------------------------------------

    setso 4
CS_WaitTime_delay so.w 1
CS_WaitTime_commandsize so.w 0
CS_WaitTime macro \1
    dc.l CSCommand_WaitTime
    dc.w \1
    endm
   
    
CSCommand_WaitTime:
    move #CS_UPDATEMODE_WAITTIMER,cs_updateMode(a5)
    move CS_WaitTime_delay(a4),cs_timer(a5) 
    add.l #CS_WaitTime_commandsize,a4
    rts    

;-------------------------------------------------------------------------------------------------

Cutscene_Avatar1:
    bsr Cutscene_Avatar
    move #0,go_word0(a0)
    rts
Cutscene_Avatar2:
    bsr Cutscene_Avatar
    move #1,go_word0(a0)
    rts
Cutscene_Avatar3:
    bsr Cutscene_Avatar
    move #2,go_word0(a0)
    rts
Cutscene_Avatar4:
    bsr Cutscene_Avatar
    move #3,go_word0(a0)
    rts
Cutscene_Knight:
    bsr Cutscene_Avatar
    move #4,go_word0(a0)
    rts

Cutscene_Avatar:
    move.l #.update,go_onUpdate(a0)
;    SETSPR SPRITE_UI_PLAYERS
    rts
.update:
    move go_word0(a0),d0
    add d0,d0
  ;  add #SPRFRAME_UI_PLAYERS_0,d0
    move g_timer1_shr5,d1
    and #1,d1
    add d1,d0
    move d0,go_frame(a0)
    
    bsr CutSceneGO_CallCutsceneUpdateFunc    
    rts

CutSceneGO_CallCutsceneUpdateFunc:
    move.l go_cutscene_cb(a0),d0
    beq .nocs
    move.l d0,a1
    jsr (a1)
.nocs:
    rts

    clrso
CUTSCENE_HERO so.b 1
CUTSCENE_EASYJOB so.b 1
CUTSCENE_QUEST so.b 1
CUTSCENE_SWITCHES so.b 1
CUTSCENE_BATS so.b 1
CUTSCENE_UPGRADE_DUNGEON so.b 1
CUTSCENE_SHOP so.b 1
CUTSCENE_CYCLOPS so.b 1
CUTSCENE_HOSTAGE so.b 1
CUTSCENE_FIRE so.b 1
CUTSCENE_MINOTAUR so.b 1

Cutscene_Addresses
    dc.l Cutscene0    
    dc.l Cutscene1    
    dc.l Cutscene2    
    dc.l Cutscene3    
    dc.l Cutscene4    
    dc.l Cutscene5    
    dc.l Cutscene6    
    dc.l Cutscene7    
    dc.l Cutscene8    
    dc.l Cutscene9    
    dc.l Cutscene10    
    dc.l Cutscene11    


;-------------------------------------------------------------------------------------
Cutscene0:        ; dungeon needs hero
    CS_AddObjAt     Cutscene_Avatar1,80,-10
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_AddObjAt     Cutscene5_Princess,128+30+23,100-8
    CS_AddObjAt     Cutscene5_ThroneA,128+30,100-28
    CS_AddObjAt     Cutscene5_ThroneB,128+30+32,100-28
    CS_Move         CS_AVATAR3,136
    CS_Move         CS_AVATAR2,136
    CS_Move         CS_AVATAR1,136
    ;CS_Move         CS_AVATAR0,136
    
    
    CS_WaitTime     150
; princess starts speech
    CS_CharSpeech   0,4,AnimSpeech01
    CS_CharSpeech   1,4,AnimSpeech02
    CS_CharSpeech   2,4,AnimSpeech03
    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech   0,4,AnimSpeech04
    CS_CharSpeech  1,4,AnimSpeech05

    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech   0,CS_AVATAR3,AnimSpeech07
    CS_GOFunc       CS_AVATAR0,Cutscene0_AvatarFallOn

    
    CS_WaitTime     200
    
    CS_CharSpeech   0,CS_AVATAR3,AnimSpeech09
    CS_WaitTime     100

    CS_Stop        
    
Cutscene0_AvatarFallOn:
    move.l #.update,go_onUpdate(a0)
    move.l #$0,go_dy(a0)
    move #0,go_timer(a0)
.update:      
    add.l #$2000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    cmp #100,go_y(a0)
    blt .nohit
    
    move #100,go_y(a0)
    
    add #1,go_timer(a0)
    cmp #4,go_timer(a0)
    bgt .nohit
    
    move.l go_dy(a0),d0
    asr.l #1,d0
    neg.l d0
    move.l d0,go_dy(a0)
.nohit:

    move #0,go_sprAttributes(a0)
    tst go_dy(a0)
    bgt .noneg
    move #FLIP_V,go_sprAttributes(a0)
.noneg:

    rts

;-------------------------------------------------------------------------------------

CS_AVATAR0 equ 0
CS_AVATAR1 equ 1
CS_AVATAR2 equ 2
CS_AVATAR3 equ 3

Cutscene1:    ; easiest job
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_Move         CS_AVATAR3,156
    CS_Move         CS_AVATAR2,156
    CS_Move         CS_AVATAR1,156
    CS_Move         CS_AVATAR0,156

    CS_WaitTime     140


    CS_WaitTime     20
    CS_CharSpeech   0,CS_AVATAR2,AnimSpeech10
    CS_CharSpeech   1,CS_AVATAR2,AnimSpeech12
    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech   0,CS_AVATAR2,AnimSpeech13

    CS_WaitTime     80
    CS_AddObjAt     Cutscene1_Eyes,128-10,80-20
    CS_WaitTime     20
    CS_AddObjAt     Cutscene1_Eyes,128+30,80-10
    CS_WaitTime     20
    CS_AddObjAt     Cutscene1_Eyes,128-20,80-5
    CS_WaitTime     20
    CS_AddObjAt     Cutscene1_Eyes,128-5,80-14
    CS_WaitTime     20
    CS_AddObjAt     Cutscene1_Eyes,128+20,8018
    CS_WaitTime     20
    CS_AddObjAt     Cutscene1_Eyes,128+10,80-8


    CS_WaitTime     60
    CS_CharSpeech   0,CS_AVATAR2,AnimSpeech15
    CS_WaitTime     120
    
    CS_Stop         
    
    
Cutscene1_Eyes:
    move.l #.update,go_onUpdate(a0)
;    SETSPR SPRITE_CUTSCENE
 ;   move #SPRFRAME_CUTSCENE_EYES,go_frame(a0)
.update: rts
    

;-------------------------------------------------------------------------------------

Cutscene2:    ; a quest door
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_AddObjAt     Cutscene2_QuestDoor,128,80
    CS_Move         CS_AVATAR3,156
    CS_Move         CS_AVATAR2,156
    CS_Move         CS_AVATAR1,156
    CS_Move         CS_AVATAR0,156

    CS_WaitTime     160
    CS_CharSpeech   0,CS_AVATAR3,AnimSpeech16
    CS_WaitTime     80
    CS_CharSpeech   0,CS_AVATAR3,AnimSpeech18
    CS_CharSpeech   1,CS_AVATAR3,AnimSpeech19
    CS_WaitTime     100
    CS_CharSpeech   0,CS_AVATAR0,AnimSpeech20
    CS_WaitTime     60
    CS_CharSpeech   0,CS_AVATAR0,AnimSpeech21
    CS_CharSpeech   1,CS_AVATAR0,AnimSpeech22
    CS_WaitTime     100
    CS_Stop         

Cutscene2_QuestDoor:
;    SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_QUESTDOOR
    move.l #.u,go_onUpdate(a0)
.u: rts

;-------------------------------------------------------------------------------------

Cutscene3:    ; switch / statues
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_AddObjAt     Cutscene3_Switch,80,100
    CS_AddObjAt     Cutscene3_TowerA,170,104-16
    
    CS_Move         CS_AVATAR3,156
    CS_Move         CS_AVATAR2,156
    CS_Move         CS_AVATAR1,156
    CS_Move         CS_AVATAR0,156

   ; CS_GOFrame      4,SPRFRAME_CUTSCENE_SWITCHDOWN      

    CS_WaitTime     200
  ;  CS_GOFrame      4,SPRFRAME_CUTSCENE_SWITCHUP
    CS_WaitTime     20
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech23
    
    CS_MoveTo       CS_AVATAR0,80
    CS_WaitTime     50
 ;   CS_GOFrame      4,SPRFRAME_CUTSCENE_SWITCHDOWN      
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech26
    CS_WaitTime     100
    CS_GOFunc       5,Cutscene_GoSetInvisible
    CS_AddObjAt     Cutscene3_TowerB0,170,104-32
    CS_AddObjAt     Cutscene3_TowerB1,170,104-32-32
    CS_MoveTo       CS_AVATAR0,100
    CS_WaitTime     50


    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech27
    CS_CharSpeech       1,CS_AVATAR3,AnimSpeech28
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech31
    
    CS_WaitTime     100
    CS_Stop         

Cutscene_GoSetInvisible:
    GO_SET_INVISIBLE
    rts

Cutscene3_TowerA:
   ; SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_TOWERA
    move.l #.u,go_onUpdate(a0)
.u: rts

Cutscene3_TowerB0:
 ;   SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_TOWERB0
    move.l #.u,go_onUpdate(a0)
.u: rts
Cutscene3_TowerB1:
;    SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_TOWERB1
    move.l #.u,go_onUpdate(a0)
.u: rts


Cutscene3_Switch:
;    SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_SWITCHDOWN
    move.l #.u,go_onUpdate(a0)
.u: rts


;-------------------------------------------------------------------------------------

Cutscene4:    ; bats added
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_Move         CS_AVATAR3,156
    CS_Move         CS_AVATAR2,156
    CS_Move         CS_AVATAR1,156
    CS_Move         CS_AVATAR0,156

    CS_AddObjAt     Cutscene4_Bat,128-80,100-50
    CS_AddObjAt     Cutscene4_Bat,128-40,100-30
    CS_AddObjAt     Cutscene4_Bat,128,100-40
    CS_AddObjAt     Cutscene4_Bat,128+40,100-50
    CS_AddObjAt     Cutscene4_Bat,128+80,100-30
    
    
    CS_WaitTime     160
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech32
    CS_CharSpeech       1,CS_AVATAR3,AnimSpeech33
    CS_CharSpeech       2,CS_AVATAR3,AnimSpeech34
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR2,AnimSpeech35
    CS_WaitTime     50

    CS_AddObjAt     Cutscene4_BatSignal,128+-30,100-40
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech37
    CS_WaitTime     150

    CS_GOFunc       4,Cutscene4_Bat_Moveto   
    CS_GOFunc       5,Cutscene4_Bat_Moveto   
    CS_GOFunc       6,Cutscene4_Bat_Moveto   
    CS_GOFunc       7,Cutscene4_Bat_Moveto   
    CS_GOFunc       8,Cutscene4_Bat_Moveto   

    CS_WaitTime     10
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech38
    CS_CharSpeech       1,CS_AVATAR2,AnimSpeech38
    CS_CharSpeech       2,CS_AVATAR1,AnimSpeech38

    CS_WaitTime     100
    CS_Stop         
    
Cutscene4_Bat_Moveto:
    move.l #.u,go_onUpdate(a0)
    move #128,go_tox(a0)
    move #90,go_toy(a0)
.u: 
    bsr Cutscene4_Bat_Animate
    
    move.l go_tox(a0),d0
    sub.l go_x(a0),d0
    asr.l #7,d0
    add.l d0,go_x(a0)

    move.l go_toy(a0),d0
    sub.l go_starty(a0),d0
    asr.l #7,d0
    add.l d0,go_starty(a0)
    
    rts

Cutscene4_Bat:
   ; SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_BATA
    move.l #.first,go_onUpdate(a0)
    jsr UTILS_GetRandWordFast
    and #7,d0
    move d0,go_word0(a0)
    rts

.first:
    jsr UTILS_GetRandWordFast
    and #15,d0
    sub #8,d0
    add d0,go_x(a0)
    jsr UTILS_GetRandWordFast
    and #15,d0
    sub #8,d0
    add d0,go_y(a0)

    move go_y(a0),go_starty(a0)
    move.l #.u,go_onUpdate(a0)
.u: 
    bsr Cutscene4_Bat_Animate
    rts

Cutscene4_Bat_Animate:
    move g_timer1_shr4_and1,d0
;    add #SPRFRAME_CUTSCENE_BATA,d0
    move d0,go_frame(a0)
    
    move g_timer1_shr2,d0
    add go_word0(a0),d0
    and #7,d0
    add d0,d0
    move .positions(pc,d0),d0
    add go_starty(a0),d0
    move d0,go_y(a0)
    
    rts
.positions:
    dc.w 0,1,2,2,1,0,-1,-1
    
Cutscene4_BatSignal:
  ;  SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_BATSIGNAL
    move.l #.u,go_onUpdate(a0)
.u: rts
    
;-------------------------------------------------------------------------------------

    
Cutscene5:    ; upgrade dungeon
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_AddObjAt     Cutscene5_Princess,128+10+23,100-8
    CS_AddObjAt     Cutscene5_ThroneA,128+10,100-28
    CS_AddObjAt     Cutscene5_ThroneB,128+10+32,100-28
    CS_Move         CS_AVATAR3,136
    CS_Move         CS_AVATAR2,136
    CS_Move         CS_AVATAR1,136
    CS_Move         CS_AVATAR0,136

    CS_WaitTime     160
    CS_CharSpeech       0,4,AnimSpeech39
    CS_WaitTime     100
    CS_CharSpeech       0,4,AnimSpeech41
    CS_CharSpeech       1,4,AnimSpeech42
    CS_CharSpeech       2,4,AnimSpeech43
    CS_WaitTime     120
    CS_CharSpeech       0,4,AnimSpeech44
    CS_CharSpeech       1,4,AnimSpeech45
    CS_CharSpeech       2,4,AnimSpeech46
    CS_WaitTime     120
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech15
    CS_WaitTime     60
    CS_CharSpeech       1,CS_AVATAR0,AnimSpeech47
    
    CS_WaitTime     120
    CS_Stop         

Cutscene5_ThroneA:
;    SETSPR_AND_FRAME SPRITE_UI,SPRFRAME_UI_THRONEA
    move.l #.u,go_onUpdate(a0)
.u  rts
Cutscene5_ThroneB:
 ;   SETSPR_AND_FRAME SPRITE_UI,SPRFRAME_UI_THRONEB
    move.l #.u,go_onUpdate(a0)
.u  rts
Cutscene5_Princess:
  ;  SETSPR_AND_FRAME SPRITE_UI,SPRFRAME_UI_PRINCESSA
    move.l #.u,go_onUpdate(a0)
.u  
    move g_timer1_shr5_and1,d0
   ; add #SPRFRAME_UI_PRINCESSA,d0
    move d0,go_frame(a0)
    rts
;-------------------------------------------------------------------------------------

Cutscene6:    ; a shop door
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_AddObjAt     Cutscene6_ShopDoor,128,80
    CS_Move         CS_AVATAR3,156
    CS_Move         CS_AVATAR2,156
    CS_Move         CS_AVATAR1,156
    CS_Move         CS_AVATAR0,156
    
    CS_WaitTime     150
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech48
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech49
    CS_CharSpeech       1,CS_AVATAR3,AnimSpeech50
    CS_CharSpeech       2,CS_AVATAR3,AnimSpeech52
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech55
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech25
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech53
    CS_CharSpeech       1,CS_AVATAR0,AnimSpeech54
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech07
    
    CS_WaitTime     100
    CS_Stop         
    
Cutscene6_ShopDoor:
    ;SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_SHOPDOOR
    move.l #.u,go_onUpdate(a0)
.u: rts
    
    
;-------------------------------------------------------------------------------------

Cutscene7:    ; cyclop
   CS_AddObjAt     Cutscene_Avatar1,-46,100
   CS_AddObjAt     Cutscene_Avatar2,-34,100
   CS_AddObjAt     Cutscene_Avatar3,-22,100
   CS_AddObjAt     Cutscene_Avatar4,-10,100
   CS_AddObjAt     Cutscene6_Cyclops,280,100
   CS_Move         CS_AVATAR3,156
   CS_Move         CS_AVATAR2,156
   CS_Move         CS_AVATAR1,156
   CS_Move         CS_AVATAR0,156
   CS_Move         4,-100

    
    CS_WaitTime     160

    CS_GOFunc       4,Cutscene6_Cyclops_Wait
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech56
    CS_WaitTime     80



    CS_GOFunc       4,Cutscene6_Cyclops_Wait
    CS_WaitTime     60
    CS_GOFunc       4,Cutscene6_Cyclops_Hit
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech58
    CS_GOFunc       CS_AVATAR0,Cutscene6_Avatar_Hit
    CS_WaitTime     30

    CS_GOFunc       4,Cutscene6_Cyclops_Wait
    CS_WaitTime     60
    CS_GOFunc       4,Cutscene6_Cyclops_Hit
    CS_CharSpeech       1,CS_AVATAR1,AnimSpeech58
    CS_GOFunc       CS_AVATAR1,Cutscene6_Avatar_Hit
    CS_WaitTime     30

    CS_GOFunc       4,Cutscene6_Cyclops_Wait
    CS_WaitTime     60
    CS_GOFunc       4,Cutscene6_Cyclops_Hit
    CS_CharSpeech       2,CS_AVATAR2,AnimSpeech58
    CS_GOFunc       CS_AVATAR2,Cutscene6_Avatar_Hit
    CS_WaitTime     30

    CS_GOFunc       4,Cutscene6_Cyclops_Wait
    CS_WaitTime     60
    CS_GOFunc       4,Cutscene6_Cyclops_Hit
    CS_CharSpeech       3,CS_AVATAR3,AnimSpeech58
    CS_GOFunc       CS_AVATAR3,Cutscene6_Avatar_Hit
    CS_WaitTime     30
    
    CS_WaitTime     100
    CS_Stop         
    
Cutscene6_Avatar_Hit:
    move.l #.u,go_onUpdate(a0)
    move.l go_y(a0),go_starty(a0)
    move.l #-$40000,go_dy(a0)
.u: 
    sub.l #$20000,go_x(a0)

    add.l #$4000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    move go_y(a0),d0
    cmp go_starty(a0),d0
    ble .nofloor
    move.l #-$30000,go_dy(a0)
    move.l go_starty(a0),go_y(a0)
.nofloor:
    rts    
    
    
Cutscene6_Cyclops:
    ;SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_CYCLOPSA
    move.l #.u,go_onUpdate(a0)
.u: 
    move g_timer1_shr4_and1,d0
  ;  add #SPRFRAME_CUTSCENE_CYCLOPSA,d0
    move d0,go_frame(a0)
    move #FLIP_H,go_sprAttributes(a0)
    bsr CutSceneGO_CallCutsceneUpdateFunc    
    rts    
    
Cutscene6_Cyclops_Wait:    
 ;   SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_CYCLOPSA
    move.l #.u,go_onUpdate(a0)
    move.l #0,go_cutscene_cb(a0)
.u: 
    move #FLIP_H,go_sprAttributes(a0)
    rts    

Cutscene6_Cyclops_Hit:    
 ;  SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_CYCLOPSC
    move.l #.u,go_onUpdate(a0)
    move.l #0,go_cutscene_cb(a0)
    move.l #SCREENSHAKE_MAX,g_screenshake_timer
.u: 
    move #FLIP_H,go_sprAttributes(a0)
    rts    
    
;-------------------------------------------------------------------------------------

Cutscene8:    ; hostage
    CS_AddObjAt     Cutscene_Avatar1,-46,100
    CS_AddObjAt     Cutscene_Avatar2,-34,100
    CS_AddObjAt     Cutscene_Avatar3,-22,100
    CS_AddObjAt     Cutscene_Avatar4,-10,100
    CS_AddObjAt     Cutscene8_Cage,166,100
    CS_Move         CS_AVATAR3,156
    CS_Move         CS_AVATAR2,156
    CS_Move         CS_AVATAR1,156
    CS_Move         CS_AVATAR0,156

    CS_WaitTime     160
    CS_CharSpeech       0,4,AnimSpeech15    
    CS_WaitTime     50
    CS_CharSpeech       0,4,AnimSpeech60
    CS_CharSpeech       1,4,AnimSpeech61
    CS_CharSpeech       2,4,AnimSpeech62
    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech63
    CS_CharSpeech       1,CS_AVATAR0,AnimSpeech64
    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech       0,4,AnimSpeech07
    CS_CharSpeech       1,4,AnimSpeech65
    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech66
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech67
    CS_WaitTime     100
    CS_ClearSpeech
    CS_CharSpeech       0,4,AnimSpeech07
    
    CS_WaitTime     100
    CS_Stop         

Cutscene8_Cage:
;    SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_CAGEA
    move.l #.u,go_onUpdate(a0)
.u: 
    move g_timer1_shr5_and1,d0
;    add #SPRFRAME_CUTSCENE_CAGEA,d0
    move d0,go_frame(a0)
    rts


;-------------------------------------------------------------------------------------

Cutscene9:    ; fire
   CS_AddObjAt     Cutscene_Avatar1,-46,100
   CS_AddObjAt     Cutscene_Avatar2,-34,100
   CS_AddObjAt     Cutscene_Avatar3,-22,100
   CS_AddObjAt     Cutscene_Avatar4,-10,100
   CS_AddObjAt     Cutscene9_Fire,270,100
   CS_Move         CS_AVATAR3,136
   CS_Move         CS_AVATAR2,136
   CS_Move         CS_AVATAR1,136
   CS_Move         CS_AVATAR0,136


    CS_WaitTime     150
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech69
    CS_WaitTime     60
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech71

    CS_WaitTime     60
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech72
    CS_MoveTo       4,160
    CS_WaitTime     60
    CS_Move         CS_AVATAR3,20
    CS_WaitTime     60
    CS_Move         CS_AVATAR3,-20

    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech74
    CS_CharSpeech       1,CS_AVATAR3,AnimSpeech75

    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech08
    CS_Move         CS_AVATAR3,-200
    CS_Move         CS_AVATAR2,-200
    CS_Move         CS_AVATAR1,-200
    CS_Move         CS_AVATAR0,-200
    CS_Move         4,-200

    CS_WaitTime     120

    CS_Stop         

Cutscene9_Fire:
 ;   SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_FIREA
    move.l #.u,go_onUpdate(a0)
.u: 
    move g_timer1_shr3,d0
    and #3<<1,d0
    move .frames(pc,d0),go_frame(a0)
    
    bsr CutSceneGO_CallCutsceneUpdateFunc    

    rts
.frames:
   ; dc.w SPRFRAME_CUTSCENE_FIREA
  ;  dc.w SPRFRAME_CUTSCENE_FIREB
  ;  dc.w SPRFRAME_CUTSCENE_FIREC
  ;  dc.w SPRFRAME_CUTSCENE_FIREB
    

;-------------------------------------------------------------------------------------

Cutscene10:    ; minotaur
   CS_AddObjAt     Cutscene_Avatar1,-46,100
   CS_AddObjAt     Cutscene_Avatar2,-34,100
   CS_AddObjAt     Cutscene_Avatar3,-22,100
   CS_AddObjAt     Cutscene_Avatar4,-10,100
   CS_AddObjAt     Cutscene10_Minotaur,-16,100
   CS_Move         CS_AVATAR3,156
   CS_Move         CS_AVATAR2,156
   CS_Move         CS_AVATAR1,156
   CS_Move         CS_AVATAR0,156

    CS_WaitTime     160
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech76
    CS_CharSpeech       1,CS_AVATAR3,AnimSpeech77
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech78
    CS_CharSpeech       1,CS_AVATAR3,AnimSpeech79
    CS_WaitTime     100

    CS_MoveTo       4,70
    CS_WaitTime     120

    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech80
    CS_WaitTime     100
    CS_CharSpeech       0,CS_AVATAR3,AnimSpeech82
    CS_WaitTime     100

    CS_CharSpeech       0,CS_AVATAR0,AnimSpeech58
    CS_CharSpeech       1,CS_AVATAR1,AnimSpeech58
    CS_CharSpeech       2,CS_AVATAR2,AnimSpeech58
    CS_CharSpeech       3,CS_AVATAR3,AnimSpeech58
    
    CS_GOFunc       4,Cutscene10_Minotaur_Hit
    CS_GOFunc       CS_AVATAR3,Cutscene10_Avatar_Hit
    CS_WaitTime     5
    CS_GOFunc       CS_AVATAR2,Cutscene10_Avatar_Hit
    CS_WaitTime     5
    CS_GOFunc       CS_AVATAR1,Cutscene10_Avatar_Hit
    CS_WaitTime     5
    CS_GOFunc       CS_AVATAR0,Cutscene10_Avatar_Hit
    CS_WaitTime     60
    CS_GOFunc       4,Cutscene10_Minotaur_Wait
    
    CS_WaitTime     100
    CS_Stop         

Cutscene10_Minotaur:
  ;  SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_MINOTAURA
    move.l #.u,go_onUpdate(a0)
.u: 
    move g_timer1_shr4_and1,d0
  ;  add #SPRFRAME_CUTSCENE_MINOTAURA,d0
    move d0,go_frame(a0)
    bsr CutSceneGO_CallCutsceneUpdateFunc    
    rts    
    
Cutscene10_Minotaur_Wait:    
  ;  SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_MINOTAURA
    move.l #.u,go_onUpdate(a0)
    move.l #0,go_cutscene_cb(a0)
.u: 
    rts    

Cutscene10_Minotaur_Hit:    
  ;  SETSPR_AND_FRAME SPRITE_CUTSCENE,SPRFRAME_CUTSCENE_MINOTAURC
    move.l #.u,go_onUpdate(a0)
    move.l #0,go_cutscene_cb(a0)
    move.l #SCREENSHAKE_MAX,g_screenshake_timer
.u: 
    rts    
    
Cutscene10_Avatar_Hit:
    move.l #.u,go_onUpdate(a0)
    move.l go_y(a0),go_starty(a0)
    move.l #-$40000,go_dy(a0)
.u: 
    add.l #$20000,go_x(a0)

    add.l #$4000,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    
    move go_y(a0),d0
    cmp go_starty(a0),d0
    ble .nofloor
    move.l #-$30000,go_dy(a0)
    move.l go_starty(a0),go_y(a0)
.nofloor:
    rts    
    

;-------------------------------------------------------------------------------------

; unused? I have not seen it when playing
Cutscene11:    ; perma items
   CS_AddObjAt     Cutscene_Avatar1,-46,100
   CS_AddObjAt     Cutscene_Avatar2,-34,100
   CS_AddObjAt     Cutscene_Avatar3,-22,100
   CS_AddObjAt     Cutscene_Avatar4,-10,100
   CS_Move         CS_AVATAR3,156
   CS_Move         CS_AVATAR2,156
   CS_Move         CS_AVATAR1,156
   CS_Move         CS_AVATAR0,156


    CS_WaitTime     20
    CS_Speech       0,AnimSpeech83
    CS_WaitTime     20
    CS_Speech       0,AnimSpeech84
    CS_WaitTime     20
    CS_Speech       0,AnimSpeech85
    CS_WaitTime     20
    CS_Speech       0,AnimSpeech86
    CS_WaitTime     20
    CS_Speech       0,AnimSpeech87
    CS_WaitTime     20
    CS_Speech       0,AnimSpeech88
    
    CS_WaitTime     100
    CS_Stop         


;-------------------------------------------------------------------------------------

AnimSpeech01:    TEXTSTR 'Our Dungeon'
AnimSpeech02:    TEXTSTR 'Is in need'
AnimSpeech03:    TEXTSTR 'Of an agile Hero'
AnimSpeech04:    TEXTSTR 'To bring order'
AnimSpeech05:    TEXTSTR 'And balance'
AnimSpeech06:    TEXTSTR 'Ouch'
AnimSpeech07:    TEXTSTR '...'
AnimSpeech08:    TEXTSTR '!'
AnimSpeech09:    TEXTSTR 'We are ready...'
AnimSpeech10:    TEXTSTR 'This dungeon looting '

AnimSpeech11:    TEXTSTR '---'
AnimSpeech12:    TEXTSTR 'Could be'
AnimSpeech13:    TEXTSTR 'The easist job ever!'
AnimSpeech14:    TEXTSTR '---'
AnimSpeech15:    TEXTSTR 'Uhm'
AnimSpeech16:    TEXTSTR 'Cool. A Quest Door'
AnimSpeech17:    TEXTSTR  'Cool'
AnimSpeech18:    TEXTSTR 'A great way'
AnimSpeech19:    TEXTSTR 'To earn extras'
AnimSpeech20:    TEXTSTR 'Shhht'

AnimSpeech21:    TEXTSTR 'The tax agency'
AnimSpeech22:    TEXTSTR 'Lives nearby...'
AnimSpeech23:    TEXTSTR "Hey, what's that?"
AnimSpeech24:    TEXTSTR      "What's that"
AnimSpeech25:    TEXTSTR '?'
AnimSpeech26:    TEXTSTR 'Switch'
AnimSpeech27:    TEXTSTR 'Wow'
AnimSpeech28:    TEXTSTR 'How did that happen?'
AnimSpeech29:    TEXTSTR    'That'
AnimSpeech30:    TEXTSTR    'Happen'

AnimSpeech31:    TEXTSTR 'Real mystery..'
AnimSpeech32:    TEXTSTR 'So we dod a good job.'
AnimSpeech33:    TEXTSTR 'Job and as a reward'
AnimSpeech34:    TEXTSTR 'We get BATS!?'
AnimSpeech35:    TEXTSTR "Don't wake them.."
AnimSpeech36:    TEXTSTR 'I think'
AnimSpeech37:    TEXTSTR 'Na na na na.. bat..'
AnimSpeech38:    TEXTSTR 'Nooooo'
AnimSpeech39:    TEXTSTR 'Thanks to hard work,'
AnimSpeech40:    TEXTSTR     'Hard work'

AnimSpeech41:    TEXTSTR 'The Dungeon is growing'
AnimSpeech42:    TEXTSTR 'and attracting new'
AnimSpeech43:    TEXTSTR 'monsters again'
AnimSpeech44:    TEXTSTR 'Keep it up and'
AnimSpeech45:    TEXTSTR 'our difficulty rating'
AnimSpeech46:    TEXTSTR 'will improve'
AnimSpeech47:    TEXTSTR 'What now?'
AnimSpeech48:    TEXTSTR 'A shop!'
AnimSpeech49:    TEXTSTR 'With all this loot we'
AnimSpeech50:    TEXTSTR 'should be able to buy'

AnimSpeech51:    TEXTSTR     'To buy'
AnimSpeech52:    TEXTSTR 'Great new things'
AnimSpeech53:    TEXTSTR 'I could use'
AnimSpeech54:    TEXTSTR 'A new hat!'
AnimSpeech55:    TEXTSTR 'Hat'
AnimSpeech56:    TEXTSTR 'Ah he looks Cute!'
AnimSpeech57:    TEXTSTR 'Cute'
AnimSpeech58:    TEXTSTR 'Whaa'
AnimSpeech59:    TEXTSTR 'Run!'
AnimSpeech60:    TEXTSTR 'Hi.'

AnimSpeech61:    TEXTSTR 'Can you guys'
AnimSpeech62:    TEXTSTR 'Help me?'
AnimSpeech63:    TEXTSTR 'Sure...'
AnimSpeech64:    TEXTSTR "What's the problem?"
AnimSpeech65:    TEXTSTR "I'm in a cage."
AnimSpeech66:    TEXTSTR "Ow OK"
AnimSpeech67:    TEXTSTR 'Do you have a key?'
AnimSpeech68:    TEXTSTR      'A key?'
AnimSpeech69:    TEXTSTR 'These Dungeons are cold.'
AnimSpeech70:    TEXTSTR     'Are cold'

AnimSpeech71:    TEXTSTR 'Yeah'
AnimSpeech72:    TEXTSTR 'But watch out for fire.'
AnimSpeech73:    TEXTSTR     'For fire'
AnimSpeech74:    TEXTSTR 'In here'
AnimSpeech75:    TEXTSTR "It's a dangerous thing"
AnimSpeech76:    TEXTSTR "I think we've"
AnimSpeech77:    TEXTSTR 'now seen most of'
AnimSpeech78:    TEXTSTR 'the dangers this'
AnimSpeech79:    TEXTSTR 'Dungeon has to offer'
AnimSpeech80:    TEXTSTR 'Uh Guys'

AnimSpeech81:    TEXTSTR 'Guys'
AnimSpeech82:    TEXTSTR 'Now what?'
AnimSpeech83:    TEXTSTR "It's pretty"
AnimSpeech84:    TEXTSTR 'What is it?'
AnimSpeech85:    TEXTSTR "I don't know"
AnimSpeech86:    TEXTSTR "But let's"
AnimSpeech87:    TEXTSTR 'Collect em all.'
AnimSpeech88:    TEXTSTR 'Pokemon'
AnimSpeech89:    TEXTSTR ''
AnimSpeech90:    TEXTSTR ''

    align 2









