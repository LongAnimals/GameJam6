REG_DEBUG_TIMER equ $9f00
REG_DEBUG_MESSAGE equ $9e00
REG_DEBUG_CONTROL equ $9d00

REGFLAG_TIMER_COUNTER_OUTPUT equ $0
REGFLAG_TIMER_COUNTER_START equ $80
REGFLAG_TIMER_COUNTER_RESET equ $40

REGFLAG_DEBUG_PAUSE equ 0
REGFLAG_DEBUG_SHOW68K equ 1
REGFLAG_DEBUG_SHOWz80 equ 2
REGFLAG_DEBUG_SHOWVDP equ 3
REGFLAG_DEBUG_SHOWLAYERS equ $f
REGFLAG_DEBUG_SHOWMESSAGE equ $10
REGFLAG_DEBUG_SHOW_CD equ 4
REGFLAG_DEBUG_SHOW_CD2 equ 5
REGFLAG_DEBUG_SHOW_CD3 equ 6
REGFLAG_DEBUG_SHOW_MASTER_SH2 equ 7
REGFLAG_DEBUG_SHOW_SLAVE_SH2 equ 8
REGFLAG_DEBUG_SHOW_32X_VDP equ 9
REGFLAG_DEBUG_SHOW_VDP_REGISTERS equ 10
REGFLAG_DEBUG_SHOW_SPRITES equ 11
REGFLAG_DEBUG_SHOW_YM equ 12
REGFLAG_DEBUG_SHOW_PSG equ 13


DEBUG_WAIT macro
    move.l d0,-(sp)
    move #60000,d0
.waitloop:
    sub #1,d0
    bne .waitloop
    move.l (sp)+,d0
    endm

DEBUG_HALT_OUTPUT macro \1
    move.l #\1,DebugArea
.aaaa bra .aaaa
    endm


DEBUG_SHOWREGS macro
    trap #15
    endm
DEBUG_SHOWMEM_A0 macro
    trap #14
    endm
DEBUG_SHOWMEM_DEBUGAREA macro
    trap #13
    endm

DEBUG_HALT macro
.aaaa bra .aaaa
    endm

DEBUG_PAUSE macro
	ifd IS_DEBUG_MODE
	;move.w #REG_DEBUG_CONTROL|REGFLAG_DEBUG_PAUSE,VDP_CONTROL
	endif
	endm
DEBUG_SHOWWINDOW_MESSAGE macro
	ifd IS_DEBUG_MODE
	;move.w #REG_DEBUG_CONTROL|REGFLAG_DEBUG_SHOWMESSAGE,VDP_CONTROL
	endif
	endm
DEBUG_SHOWWINDOW_68K macro
	ifd IS_DEBUG_MODE
	;move.w #REG_DEBUG_CONTROL|REGFLAG_DEBUG_SHOW68K,VDP_CONTROL
	endif
	endm
DEBUG_SHOWWINDOW_Z80 macro
	ifd IS_DEBUG_MODE
	;move.w #REG_DEBUG_CONTROL|REGFLAG_DEBUG_SHOWz80,VDP_CONTROL
	endif
	endm

DEBUG_SHOWWINDOW_YM macro
	ifd IS_DEBUG_MODE
	;move.w #REG_DEBUG_CONTROL|REGFLAG_DEBUG_SHOW_YM,VDP_CONTROL
	endif
	endm


DEBUG_LONG_DEBUGAREA macro \1 \2 \3
	ifd IS_DEBUG_MODE
	;move.l #\2,DebugArea+(\1*8)
	;move.l #\3,DebugArea+4+(\1*8)
	endif
	endm


DEBUG_MESSAGESTR macro \1
	ifd IS_DEBUG_MODE
	move.l a0,-(sp)
	move.l #\1,a0
	jsr DEBUG_PrintMessageA0
	move.l (sp)+,a0
	DEBUG_SHOWWINDOW_MESSAGE
	endif
	endm

DEBUG_MESSAGESTR_A0 macro
	ifd IS_DEBUG_MODE
	jsr DEBUG_PrintMessageA0
	DEBUG_SHOWWINDOW_MESSAGE
	endif
	endm

DEBUG_MESSAGELONG macro \1
	ifd IS_DEBUG_MODE
	move.l #\1,d0
	jsr DEBUG_PrintMessageD0
	DEBUG_SHOWWINDOW_MESSAGE
	endif
	endm

DEBUG_MESSAGEREGISTER macro \1
	ifd IS_DEBUG_MODE
	PUSHALL
	move.l \1,d0
	jsr DEBUG_PrintMessageD0
	DEBUG_SHOWWINDOW_MESSAGE
	POPALL
	endif

	endm


DEBUG_TIMER_START macro
	ifd IS_DEBUG_MODE
	move #REG_DEBUG_TIMER | REGFLAG_TIMER_COUNTER_START,VDP_CONTROL
	endif
	endm

DEBUG_TIMER_PRINT macro
	ifd IS_DEBUG_MODE
	move #REG_DEBUG_TIMER | REGFLAG_TIMER_COUNTER_OUTPUT,VDP_CONTROL
	endif
	endm

DEBUG_TIMER_RESET macro
	ifd IS_DEBUG_MODE
	move #REG_DEBUG_TIMER | REGFLAG_TIMER_COUNTER_RESET,VDP_CONTROL
	endif
	endm




DEBUG_PrintMessageD0
	move.l d0,-(sp)
	move.l d1,-(sp)

	rept 4
	rol.l #8,d0
	moveq #0,d1
	move.b d0,d1
	or #REG_DEBUG_MESSAGE,d1
	move d1,VDP_CONTROL
	endr

	move #REG_DEBUG_MESSAGE ,VDP_CONTROL
	move.l (sp)+,d1
	move.l (sp)+,d0
	rts



DEBUG_PrintMessageA0
	move.l d0,-(sp)
.lp:
	moveq #0,d0
	move.b (a0)+,d0
	cmp.b #ETX,d0
	beq .done
	or #REG_DEBUG_MESSAGE,d0
	move d0,VDP_CONTROL
	bra .lp
.done:
	move #REG_DEBUG_MESSAGE,VDP_CONTROL
	move.l (sp)+,d0
	rts


DEBUG_ClearDebugArea:
    lea DebugArea,a0
    move #DEBUG_AREA_SIZE,d0
    jsr UTILS_ClearRam
    rts
