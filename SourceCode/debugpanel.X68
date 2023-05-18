;-----------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------

    clrso
debugpanel_active so.b 1
debugpanel_use_start_as_button so.b 1
debugpanel_cursorpos so.w 1
debugpanel_cursorpos_old so.w 1
debugpanel_redrawflags so.w 1
debugpanel_windowaddr so.l 1
debugpanel_redrawaddr so.l 1
debugpanel_optionsaddr so.l 1
debugpanel_structsize so.b 0



MENUOPTION_TOGGLE equ 0
MENUOPTION_BYTE equ 1
MENUOPTION_BYTE_BUTTON equ 2
MENUOPTION_BUTTON equ 3
MENUOPTION_TEXT_FUNCTION equ 4
MENUOPTION_BYTE_TEXT equ 5
MENUOPTION_FLAG_NOSFX equ 1

MENUFLAGS_NONE equ 0
MENUFLAGS_USE_START equ $1

DEBUGPANEL_RENDERADDR macro \1 \2
	move.l sysg_debugpanel+debugpanel_windowaddr,d1
	move.l sysg_debugpanel+debugpanel_optionsaddr,a5
	move optiongroup_y(a5),d2
	lsl #7,d2
	add d2,d1
	move optiongroup_x(a5),d2
	add d2,d2
	add d2,d1
	add.l #(128*\2) + (\1*2),d1
	endm

DEBUGPANEL_PLAY_SFX macro \1
	btst.b #MENUOPTION_FLAG_NOSFX,options_flags(a0)
	beq .no
	move.l d0,-(sp)
	move #\1,d0
	jsr PSG_PlayFx
	move.l (sp)+,d0
.no:
	endm
	
DEBUGPANEL_SET_OPTIONSADDR macro \1
    move.l #\1,sysg_debugpanel+debugpanel_optionsaddr
    endm

DEBUGPANEL_SET_WINDOWADDR macro \1
    move.l #\1,sysg_debugpanel+debugpanel_windowaddr
    endm


;-----------------------------------------------------------------------------------------------------
; Initialise the system for UI work, like title screens and options
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_InitForUI:
	move.l #DEBUGPANEL_RedrawForUI_Callback,sysg_debugpanel+debugpanel_redrawaddr
	move #0,sysg_debugpanel+debugpanel_cursorpos
	move #0,sysg_debugpanel+debugpanel_cursorpos_old
	bsr DEBUGPANEL_Hide
	rts

;-----------------------------------------------------------------------------------------------------
; Initialise the system for Gameplay  - ie Pause panel
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_InitForLevel:
	move.l #DEBUGPANEL_RedrawForWindow_Callback,sysg_debugpanel+debugpanel_redrawaddr
	move #0,g_image_index
	move #0,sysg_debugpanel+debugpanel_cursorpos
	move #0,sysg_debugpanel+debugpanel_cursorpos_old
	jsr IMAGE_LoadChars
	bsr DEBUGPANEL_FillMap
	bsr DEBUGPANEL_Hide
	rts


;-----------------------------------------------------------------------------------------------------
; Copy to VRAM whole of debug panel background. Assumes 40x28
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_FillMap:
	moveq #0,d0     ;IMAGEASSET_Screens_debugpanel,d0
	lea NEWIMAGEGROUP,a0
	jsr UNITYTOOL_GetImageData
	

	move.l image_map(a0),a4
	lea tilemap_data(a4),a0
	move.l sysg_debugpanel+debugpanel_windowaddr,d5

	lea VDP_DATA,a5

	move.w g_vram_image1,d4
	move d4,d2
	swap d4
	move d2,d4

	move #28-1,d7
.ylp:
	move.l d5,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	move #(64/2)-1,d6
.loop:
	move.l (a0)+,d0
	add.l d4,d0
	move.l d0,(a5)
	dbra d6,.loop
	add.l #128,d5
	dbra d7,.ylp

	rts

;-----------------------------------------------------------------------------------------------------
; WHAT IS THIS HACK?
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_ClearArea:

	move #14-1,d7
	move #10,d6
.lp:
	bsr .draw
	addq #1,d6
	dbra d7,.lp
	rts

.draw:
    
	move.l sysg_debugpanel+debugpanel_windowaddr,d1
	move d6,d2		; ypos
	lsl #7,d2
	add d2,d1
	move #0,d2		; xpos
	add d2,d2
	add d2,d1

	lea .cleartext,a0
	PUSHALL
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	POPALL
	rts
.cleartext: dc.b '                                        ',ETX
	align 2

;-----------------------------------------------------------------------------------------------------
; Redraw the panel using a pointer to the redraw function
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_Redraw:
	move.l sysg_debugpanel+debugpanel_redrawaddr,a0
	jsr (a0)
	rts

DEBUGPANEL_REDRAWFLAG_CURSOR equ 1
DEBUGPANEL_REDRAWFLAG_ALLTEXT equ 2
DEBUGPANEL_REDRAWFLAG_SINGLELINE equ 3

DEBUGPANEL_RedrawCursorMove:
	bset #DEBUGPANEL_REDRAWFLAG_CURSOR,sysg_debugpanel+debugpanel_redrawflags+1
	rts

DEBUGPANEL_RedrawText:	
	bset #DEBUGPANEL_REDRAWFLAG_ALLTEXT,sysg_debugpanel+debugpanel_redrawflags+1
	rts

DEBUGPANEL_RedrawSingleLine:	
	bset #DEBUGPANEL_REDRAWFLAG_SINGLELINE,sysg_debugpanel+debugpanel_redrawflags+1
	rts


DEBUGPANEL_UpdateVBL:
	btst #DEBUGPANEL_REDRAWFLAG_CURSOR,sysg_debugpanel+debugpanel_redrawflags+1
	beq .nocursor
	bclr #DEBUGPANEL_REDRAWFLAG_CURSOR,sysg_debugpanel+debugpanel_redrawflags+1
	bsr DEBUGPANEL_DrawCursorImmediate
.nocursor:

	btst #DEBUGPANEL_REDRAWFLAG_ALLTEXT,sysg_debugpanel+debugpanel_redrawflags+1
	beq .noalltext
	bclr #DEBUGPANEL_REDRAWFLAG_ALLTEXT,sysg_debugpanel+debugpanel_redrawflags+1
	bsr DEBUGPANEL_RenderTextImmediate
.noalltext:

	btst #DEBUGPANEL_REDRAWFLAG_SINGLELINE,sysg_debugpanel+debugpanel_redrawflags+1
	beq .nosingleline
	bclr #DEBUGPANEL_REDRAWFLAG_SINGLELINE,sysg_debugpanel+debugpanel_redrawflags+1
	bsr DEBUGPANEL_RenderSingleLineImmediate
.nosingleline:

	rts

DEBUGPANEL_DrawCursorImmediate:
	
; delete old cursor 
	DEBUGPANEL_RENDERADDR 0,0
	move sysg_debugpanel+debugpanel_cursorpos_old,d0
	lsl #7,d0
	add d0,d1
	lea DEBUGPANEL_TextCursor_Undraw,a0	
	bsr .draw

; draw new one
	DEBUGPANEL_RENDERADDR 0,0
	move sysg_debugpanel+debugpanel_cursorpos,d0
	lsl #7,d0
	add d0,d1
	lea DEBUGPANEL_TextCursor,a0	
	bsr .draw
	rts
.draw
	PUSHALL
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	POPALL


	rts


;-----------------------------------------------------------------------------------------------------
; Render all text for the debug panel
; uses sysg_debug_optionsaddr and associated vars
;-----------------------------------------------------------------------------------------------------

DEBUGPANEL_RenderTextImmediate:
	move.l sysg_debugpanel+debugpanel_optionsaddr,a0
	move.w optiongroup_amt(a0),d7
	subq #1,d7	; num options

	DEBUGPANEL_RENDERADDR 4,0
	move.l sysg_debugpanel+debugpanel_optionsaddr,a5
	lea optiongroup_first(a5),a5
.optionloop:	
	move.l options_labeladdr(a5),a0
	bsr .draw
	add.l #128,d1
	lea options_size(a5),a5
	dbra d7,.optionloop

	move.l sysg_debugpanel+debugpanel_optionsaddr,a0
	move.w optiongroup_amt(a0),d7
	subq #1,d7	; num options
	
	DEBUGPANEL_RENDERADDR 17,0

	move.l sysg_debugpanel+debugpanel_optionsaddr,a5
	lea optiongroup_first(a5),a5
.optionloop1:	
	cmp.b #MENUOPTION_TOGGLE,options_type(a5)
	bne .nottoggle
.toggle:
	lea DEBUGPANEL_TextOff,a0
	move.l options_varaddr(a5),a4
	move.b (a4),d0
	beq .toggleoff
	lea DEBUGPANEL_TextOn,a0
.toggleoff:
	bsr .draw
	bra .next
.nottoggle:

	cmp.b #MENUOPTION_TEXT_FUNCTION,options_type(a5)
	bne .not_textfunction
.textfunction:

	move.l options_buttonaddr(a5),a4
	moveq #0,d0
	jsr (a4)	; returns 2 digit number in d0

	bsr .draw2digitnum
	bra .next


.not_textfunction:
	cmp.b #MENUOPTION_BYTE,options_type(a5)
	beq .byte
	cmp.b #MENUOPTION_BYTE_BUTTON,options_type(a5)
	beq .byte
	bra .notbyte
.byte:
	move.l options_varaddr(a5),a4
	moveq #0,d0
	move.b (a4),d0
	bsr .draw2digitnum
	bra .next
.notbyte:

	cmp.b #MENUOPTION_BYTE_TEXT,options_type(a5)
	bne .notbytetext
	move.l options_varaddr(a5),a4
	moveq #0,d0
	move.b (a4),d0
	move.l options_textlist(a5),a3
	lea 2(a3),a3
	lsl #2,d0
	add d0,a3
	move.l (a3),a0
	bsr .draw
	bra .next
.notbytetext:

.next:
	lea options_size(a5),a5
	add.l #128,d1
	dbra d7,.optionloop1

	rts
.draw
	PUSHALL
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	POPALL
	rts
.draw2digitnum
	PUSHALL
	move.l d0,-(sp)
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	move.l (sp)+,d0
	jsr FONT_DrawNumber_Byte
	POPALL
	rts


;-----------------------------------------------------------------------------------------------------
; Render all text for the debug panel
; uses sysg_debug_optionsaddr and associated vars
; use sysg_debugpanel+debugpanel_cursorpos for the line to change
;-----------------------------------------------------------------------------------------------------

DEBUGPANEL_RenderSingleLineImmediate:
	move.l sysg_debugpanel+debugpanel_optionsaddr,a0

	DEBUGPANEL_RENDERADDR 4,0
	move.l sysg_debugpanel+debugpanel_optionsaddr,a5
	lea optiongroup_first(a5),a5

	move sysg_debugpanel+debugpanel_cursorpos,d0
	mulu #options_size,d0
	add d0,a5
	move sysg_debugpanel+debugpanel_cursorpos,d0
	mulu #128,d0
	add d0,d1
	move.l options_labeladdr(a5),a0
	bsr .draw


	move.l sysg_debugpanel+debugpanel_optionsaddr,a0
	
	DEBUGPANEL_RENDERADDR 17,0

	move.l sysg_debugpanel+debugpanel_optionsaddr,a5

	move sysg_debugpanel+debugpanel_cursorpos,d0
	mulu #options_size,d0
	add d0,a5
	move sysg_debugpanel+debugpanel_cursorpos,d0
	mulu #128,d0
	add d0,d1


	lea optiongroup_first(a5),a5
.optionloop1:	
	cmp.b #MENUOPTION_TOGGLE,options_type(a5)
	bne .nottoggle
.toggle:
	lea DEBUGPANEL_TextOff,a0
	move.l options_varaddr(a5),a4
	move.b (a4),d0
	beq .toggleoff
	lea DEBUGPANEL_TextOn,a0
.toggleoff:
	bsr .draw
	bra .next
.nottoggle:

	cmp.b #MENUOPTION_TEXT_FUNCTION,options_type(a5)
	bne .not_textfunction
.textfunction:

	move.l options_buttonaddr(a5),a4
	moveq #0,d0
	jsr (a4)	; returns 2 digit number in d0

	bsr .draw2digitnum
	bra .next


.not_textfunction:
	cmp.b #MENUOPTION_BYTE,options_type(a5)
	beq .byte
	cmp.b #MENUOPTION_BYTE_BUTTON,options_type(a5)
	beq .byte
	bra .notbyte
.byte:
	move.l options_varaddr(a5),a4
	moveq #0,d0
	move.b (a4),d0
	bsr .draw2digitnum
	bra .next
.notbyte:

	cmp.b #MENUOPTION_BYTE_TEXT,options_type(a5)
	bne .notbytetext
	move.l options_varaddr(a5),a4
	moveq #0,d0
	move.b (a4),d0
	move.l options_textlist(a5),a3
	lea 2(a3),a3
	lsl #2,d0
	add d0,a3
	move.l (a3),a0
	bsr .draw
	bra .next
.notbytetext:

.next:
	
	rts
.draw
	PUSHALL
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	jsr FONT_DrawText
	POPALL
	rts
.draw2digitnum
	PUSHALL
	move.l d0,-(sp)
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	move.l (sp)+,d0
	jsr FONT_DrawNumber_Byte
	POPALL
	rts




;-----------------------------------------------------------------------------------------------------
; Callback for UI redraw
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_RedrawForUI_Callback:	
	bsr DEBUGPANEL_RenderTextImmediate
	bsr DEBUGPANEL_DrawCursorImmediate
	rts

;-----------------------------------------------------------------------------------------------------
; Callback for Ingame (window) redraw
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_RedrawForWindow_Callback:
	bsr DEBUGPANEL_FillMap
	bsr DEBUGPANEL_RenderTextImmediate
	bsr DEBUGPANEL_DrawCursorImmediate
	rts


DEBUGPANEL_Clear:
	bsr DEBUGPANEL_FillMap
	rts




;-----------------------------------------------------------------------------------------------------
; set the debug panel active, and set the window to full
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_Show:
	move.b #1,sysg_debugpanel+debugpanel_active
	move #REG_WINDOW_VPOS | $00 | 28,VDP_CONTROL
	rts

DEBUGPANEL_ShowAndRedraw:
	move.b #1,sysg_debugpanel+debugpanel_active
	move #REG_WINDOW_VPOS | $00 | 28,VDP_CONTROL
	bsr DEBUGPANEL_Redraw
	rts



;-----------------------------------------------------------------------------------------------------
; set the debug panel inactive, and set the window to 0
;-----------------------------------------------------------------------------------------------------
DEBUGPANEL_Hide:
	move.b #0,sysg_debugpanel+debugpanel_active
	move #REG_WINDOW_VPOS | $00 | 0,VDP_CONTROL
	rts


;-----------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------	
DEBUGPANEL_Update:
	move g_pad0_pressed,d5
    ;btst #pad_button_start,d5
	;bne DEBUGPANEL_Hide

	move.l sysg_debugpanel+debugpanel_optionsaddr,a0
	move.w optiongroup_amt(a0),d4
	subq #1,d4	; num options

	btst #pad_button_up,d5
	beq .notup
	move sysg_debugpanel+debugpanel_cursorpos,sysg_debugpanel+debugpanel_cursorpos_old
	sub.w #1,sysg_debugpanel+debugpanel_cursorpos
	cmp #0,sysg_debugpanel+debugpanel_cursorpos
	bge .nowrap1
	move d4,sysg_debugpanel+debugpanel_cursorpos
.nowrap1:
	PSG_PLAY_SFX PSGSFX_ui_move_cursor
	bsr DEBUGPANEL_RedrawCursorMove
	rts

.notup:
	btst #pad_button_down,d5
	beq .notdown
	move sysg_debugpanel+debugpanel_cursorpos,sysg_debugpanel+debugpanel_cursorpos_old
	add.w #1,sysg_debugpanel+debugpanel_cursorpos
	cmp sysg_debugpanel+debugpanel_cursorpos,d4
	bge .nowrap2
	move #0,sysg_debugpanel+debugpanel_cursorpos
.nowrap2:
	PSG_PLAY_SFX PSGSFX_ui_move_cursor
	bsr DEBUGPANEL_RedrawCursorMove
	rts
.notdown:

	btst #pad_button_left,d5
	beq .notleft
	move.b #-1,d0
	bsr DEBUGPANEL_Update_LeftRight_Pressed
	bra .redrawandreturn

.notleft:
	btst #pad_button_right,d5
	beq .notright
	move.b #1,d0
	bsr DEBUGPANEL_Update_LeftRight_Pressed
	bra .redrawandreturn
.notright:

	btst #pad_button_a,d5
	bne .pressed
	btst #pad_button_b,d5
	bne .pressed
	btst #pad_button_c,d5
	bne .pressed
	move.l sysg_debugpanel+debugpanel_optionsaddr,a0
	move.w optiongroup_flags(a0),d4
	and #MENUFLAGS_USE_START,d4
	beq .notpressed
	btst #pad_button_start,d5
	bne .pressed
	bra .notpressed

.pressed:
	bsr DEBUGPANEL_RedrawSingleLine
	bsr DEBUGPANEL_Update_A_Pressed
.notpressed:
	rts
.redrawandreturn:
	bsr DEBUGPANEL_RedrawSingleLine
	rts


; d0 is amount to add
DEBUGPANEL_Update_LeftRight_Pressed
	bsr DEBUGPANEL_GetItemDataAddr
	cmp.b #MENUOPTION_BYTE_BUTTON,options_type(a0)
	beq .leftright
	cmp.b #MENUOPTION_BYTE,options_type(a0)
	beq .leftright
	cmp.b #MENUOPTION_BYTE_TEXT,options_type(a0)
	beq .leftright
	rts
.leftright:
	DEBUGPANEL_PLAY_SFX PSGSFX_ui_change_value
	bsr DEBUGPANEL_UpdateByte

	cmp.b #MENUOPTION_BYTE_TEXT,options_type(a0)
	bne .notbytetext1
	bsr DEBUGPANEL_GetItemDataAddr
	move.l options_varaddr(a0),a1
	cmp.b #-1,(a1)
	bne .notbytetext
	move.l options_textlist(a0),a3
	move (a3),d0
	subq #1,d0
	move.b d0,(a1)
	bra .notbytetext1
.notbytetext:
	move.l options_textlist(a0),a3
	move (a3),d0
	cmp.b (a1),d0
	bne .notbytetext1
	move.b #0,(a1)
.notbytetext1:
	rts

DEBUGPANEL_Update_A_Pressed:
	bsr DEBUGPANEL_GetItemDataAddr
	cmp.b #MENUOPTION_TOGGLE,options_type(a0)
	bne .notToggle
	bra DEBUGPANEL_UpdateToggle
.notToggle:

	cmp.b #MENUOPTION_BUTTON,options_type(a0)
	beq .button
	cmp.b #MENUOPTION_BYTE_BUTTON,options_type(a0)
	beq .button
	bra .notButton
.button:
	bra DEBUGPANEL_UpdateButton
.notButton:
	
	rts



DEBUGPANEL_UpdateToggle
	DEBUGPANEL_PLAY_SFX PSGSFX_ui_select
	bsr DEBUGPANEL_GetItemDataAddr
	move.l options_varaddr(a0),a1
	not.b (a1)
	rts

DEBUGPANEL_UpdateButton
	DEBUGPANEL_PLAY_SFX PSGSFX_ui_select
	bsr DEBUGPANEL_GetItemDataAddr
	move.l options_buttonaddr(a0),a1
	jmp (a1)



; d0 is amount to add
DEBUGPANEL_UpdateByte
	bsr DEBUGPANEL_GetItemDataAddr
	move.l options_varaddr(a0),a1
	add.b d0,(a1)
	rts

; in a0, regisrter safe
DEBUGPANEL_GetItemDataAddr:
	move.l d0,-(sp)
	move.l sysg_debugpanel+debugpanel_optionsaddr,a0
	lea optiongroup_first(a0),a0
	moveq #0,d0
	move.w sysg_debugpanel+debugpanel_cursorpos,d0
	mulu #options_size,d0
	add d0,a0
	move.l (sp)+,d0
	rts

DEBUGPANEL_TextCursor_Undraw	dc.b	'   ',ETX
DEBUGPANEL_TextCursor	dc.b	'  ^',ETX		; panda in font
DEBUGPANEL_TextOn	dc.b	'On ',ETX
DEBUGPANEL_TextOff	dc.b	'Off',ETX
	align 2
