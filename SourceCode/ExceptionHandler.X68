

EXCEPTIONHANDLER_PUSHREGS macro
    move.l a6,-(sp)
    move.l a5,-(sp)
    move.l a4,-(sp)
    move.l a3,-(sp)
    move.l a2,-(sp)
    move.l a1,-(sp)
    move.l a0,-(sp)
    move.l d7,-(sp)
    move.l d6,-(sp)
    move.l d5,-(sp)
    move.l d4,-(sp)
    move.l d3,-(sp)
    move.l d2,-(sp)
    move.l d1,-(sp)
    move.l d0,-(sp)
    endm

ExceptionHandler_ShowBlueScreen:
    move.l #0,g_game_loopaddr
    move.l #0,g_game_vbladdr

    move.w	#REG_MODE1|REGMASK_MODE1_REQUIRED,VDP_CONTROL
    move #REG_MODE4|REGMASK_MODE4_H40|REGMASK_MODE4_NO_INTERLACE,VDP_CONTROL
    move #REG_SCROLLSIZE|VDP_PLANESIZE_64x32,VDP_CONTROL
	move #REG_MODE3|REGMASK_MODE3_HSCROLLMODE_FULL|REGMASK_MODE3_VSCROLLMODE_FULL,VDP_CONTROL

    jsr ClearVRAM
    
    jsr SPRITE_InitVdpRamSpriteList
    jsr FADE_ClearAll
    move #0,g_vram_currentpos

    jsr Image_AddBlankCharacterToVDP

	move #FONT_CUBEDROID_FONT0,g_font_index
	move #1,g_font_palette_index
	jsr FONT_InitAll
	
	move #200,RamPalettes
	move.b #FADE_INFO_STOP,g_fade+fade_info
	move.b #1,g_fade+fade_updated
	move.b #7,g_fade+fade_level
	jsr FADE_Update
	
	moveq #0,d0
	SCROLL_START_WRITE_XPOS   ;
	move.w d0,VDP_DATA    
	move.w d0,VDP_DATA    
	SCROLL_START_WRITE_YPOS
	move d0,VDP_DATA
	move d0,VDP_DATA
	

    rts


    
ExceptionHandler_BusError:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_BusError,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_AddressError:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_AddressError,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_IllegalInstruction:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_IllegalInstruction,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_DivByZero:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_DivByZero,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_CHK:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_CHK,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_TrapV:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_TRAPV,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_Privilege:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_PrivilegeException,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_TraceException:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_TraceException,4,4
    bra ExceptionHandler_ShowExceptionAddress


ExceptionHandler_Line10:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Line10,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_Line15:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Line15,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_Spurious:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Spurious,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_Unhandled:
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Unhandled,4,4
    bra ExceptionHandler_ShowExceptionAddress

ExceptionHandler_Trap:
ExceptionHandler_Trap0:
    
    EXCEPTIONHANDLER_PUSHREGS
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Trap,4,4
    bra ExceptionHandler_ShowExceptionAddress
    


ExceptionHandler_ShowDebugArea:
    move.l #DebugArea,-(sp)
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Trap13,4,1

    bra ExceptionHandler_ShowMemAtRegOnStack

ExceptionHandler_ShowMem:
    move.l a0,-(sp)
    bsr ExceptionHandler_ShowBlueScreen
    FONT_DRAW_AT VDPADDR_SCROLL_A,ExceptionHandlerText_Trap14,4,1
    bra ExceptionHandler_ShowMemAtRegOnStack
    
ExceptionHandler_Mempositions:
    VRAM_DECLARE_CHARPOS_A 1,5
    VRAM_DECLARE_CHARPOS_A 11,5
    VRAM_DECLARE_CHARPOS_A 21,5
    VRAM_DECLARE_CHARPOS_A 31,5
    VRAM_DECLARE_CHARPOS_A 1,6
    VRAM_DECLARE_CHARPOS_A 11,6
    VRAM_DECLARE_CHARPOS_A 21,6
    VRAM_DECLARE_CHARPOS_A 31,6
    VRAM_DECLARE_CHARPOS_A 1,7
    VRAM_DECLARE_CHARPOS_A 11,7
    VRAM_DECLARE_CHARPOS_A 21,7
    VRAM_DECLARE_CHARPOS_A 31,7
    VRAM_DECLARE_CHARPOS_A 1,8
    VRAM_DECLARE_CHARPOS_A 11,8
    VRAM_DECLARE_CHARPOS_A 21,8
    VRAM_DECLARE_CHARPOS_A 31,8

    VRAM_DECLARE_CHARPOS_A 1,10
    VRAM_DECLARE_CHARPOS_A 11,10
    VRAM_DECLARE_CHARPOS_A 21,10
    VRAM_DECLARE_CHARPOS_A 31,10
    VRAM_DECLARE_CHARPOS_A 1,11
    VRAM_DECLARE_CHARPOS_A 11,11
    VRAM_DECLARE_CHARPOS_A 21,11
    VRAM_DECLARE_CHARPOS_A 31,11
    VRAM_DECLARE_CHARPOS_A 1,12
    VRAM_DECLARE_CHARPOS_A 11,12
    VRAM_DECLARE_CHARPOS_A 21,12
    VRAM_DECLARE_CHARPOS_A 31,12
    VRAM_DECLARE_CHARPOS_A 1,13
    VRAM_DECLARE_CHARPOS_A 11,13
    VRAM_DECLARE_CHARPOS_A 21,13
    VRAM_DECLARE_CHARPOS_A 31,13
    
    VRAM_DECLARE_CHARPOS_A 1,15
    VRAM_DECLARE_CHARPOS_A 11,15
    VRAM_DECLARE_CHARPOS_A 21,15
    VRAM_DECLARE_CHARPOS_A 31,15
    VRAM_DECLARE_CHARPOS_A 1,16
    VRAM_DECLARE_CHARPOS_A 11,16
    VRAM_DECLARE_CHARPOS_A 21,16
    VRAM_DECLARE_CHARPOS_A 31,16
    VRAM_DECLARE_CHARPOS_A 1,17
    VRAM_DECLARE_CHARPOS_A 11,17
    VRAM_DECLARE_CHARPOS_A 21,17
    VRAM_DECLARE_CHARPOS_A 31,17
    VRAM_DECLARE_CHARPOS_A 1,18
    VRAM_DECLARE_CHARPOS_A 11,18
    VRAM_DECLARE_CHARPOS_A 21,18
    VRAM_DECLARE_CHARPOS_A 31,18

    VRAM_DECLARE_CHARPOS_A 1,20
    VRAM_DECLARE_CHARPOS_A 11,20
    VRAM_DECLARE_CHARPOS_A 21,20
    VRAM_DECLARE_CHARPOS_A 31,20
    VRAM_DECLARE_CHARPOS_A 1,21
    VRAM_DECLARE_CHARPOS_A 11,21
    VRAM_DECLARE_CHARPOS_A 21,21
    VRAM_DECLARE_CHARPOS_A 31,21
    VRAM_DECLARE_CHARPOS_A 1,22
    VRAM_DECLARE_CHARPOS_A 11,22
    VRAM_DECLARE_CHARPOS_A 21,22
    VRAM_DECLARE_CHARPOS_A 31,22
    VRAM_DECLARE_CHARPOS_A 1,23
    VRAM_DECLARE_CHARPOS_A 11,23
    VRAM_DECLARE_CHARPOS_A 21,23
    VRAM_DECLARE_CHARPOS_A 31,23


ExceptionHandler_Regpositions:
    VRAM_DECLARE_CHARPOS_A 4,10
    VRAM_DECLARE_CHARPOS_A 4,11
    VRAM_DECLARE_CHARPOS_A 4,12
    VRAM_DECLARE_CHARPOS_A 4,13
    VRAM_DECLARE_CHARPOS_A 4,14
    VRAM_DECLARE_CHARPOS_A 4,15
    VRAM_DECLARE_CHARPOS_A 4,16
    VRAM_DECLARE_CHARPOS_A 4,17
    VRAM_DECLARE_CHARPOS_A 20,10
    VRAM_DECLARE_CHARPOS_A 20,11
    VRAM_DECLARE_CHARPOS_A 20,12
    VRAM_DECLARE_CHARPOS_A 20,13
    VRAM_DECLARE_CHARPOS_A 20,14
    VRAM_DECLARE_CHARPOS_A 20,15
    VRAM_DECLARE_CHARPOS_A 20,16
    VRAM_DECLARE_CHARPOS_A 20,17
    
    

ExceptionHandlerText_DivByZero:             dc.b 'Divide by zero error',ETX
ExceptionHandlerText_BusError:              dc.b 'Bus error',ETX
ExceptionHandlerText_AddressError:          dc.b 'Address error',ETX
ExceptionHandlerText_IllegalInstruction:    dc.b 'Illegal Instruction',ETX
ExceptionHandlerText_CHK:                   dc.b 'CHK',ETX
ExceptionHandlerText_TRAPV                  dc.b 'TrapV',ETX
ExceptionHandlerText_PrivilegeException     dc.b 'Privilege Exception',ETX
ExceptionHandlerText_TraceException         dc.b 'Trace Exception',ETX
ExceptionHandlerText_Line10                 dc.b 'Line 10 Exception',ETX
ExceptionHandlerText_Line15                 dc.b 'Line 15 Exception',ETX
ExceptionHandlerText_Spurious               dc.b 'Spurious Exception',ETX
ExceptionHandlerText_Unhandled              dc.b 'Unhandled Exception',ETX
ExceptionHandlerText_Trap                   dc.b 'Trap Exception',ETX
ExceptionHandlerText_Trap14                   dc.b 'Trap14 Mem at a0',ETX
ExceptionHandlerText_Trap13                   dc.b 'Trap13 Mem at DebugArea',ETX
    align 2

ExceptionHandler_ShowMemAtRegOnStack:
    move.l (sp)+,a6


    VRAM_GETCHARPOS_A 30,1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move.l a6,d0
    jsr FONT_DrawHex_L

    
    lea ExceptionHandler_Mempositions,a5
    move #64-1,d7
.lp:
    move.l (a5)+,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move.l (a6)+,d0
    jsr FONT_DrawHex_L
    dbra d7,.lp
    bra ExceptionHandler_LockUp

ExceptionHandler_ShowExceptionAddress:
    FONT_DRAW_AT VDPADDR_SCROLL_A,.txt,4,6
    VRAM_GETCHARPOS_A 8,6
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move.l 2+(15*4)(sp),d0
    jsr FONT_DrawHex_L

    FONT_DRAW_AT VDPADDR_SCROLL_A,.txt1,4,8
    VRAM_GETCHARPOS_A 8,8
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move.w (15*4)(sp),d0
    jsr FONT_DrawHex_W
    
    

    lea ExceptionHandler_Regpositions,a5
    rept 15
    move.l (a5)+,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move.l (sp)+,d0
    jsr FONT_DrawHex_L
    endr

    bra ExceptionHandler_LockUp
    rts

.txt:  dc.b 'At:',ETX
.txt1:  dc.b 'SR:',ETX
    align 2


ExceptionHandler_LockUp:
.a bra .a
