
;	INCLUDE "compiledefs.X68"


;TEST_SOUND equ 0 ; Don't enable this in code, it is compiled in ffrom RUN_MUSICEST.bat

DO_REALTIME_COMMANDS equ 1
USE_PSG equ 1
USE_MUSIC equ 1


REG_HWVERSION equ $00A10001
REG_TMS equ $00A14000
RAM_START equ $00FF0000


BORDER macro \1
    PUSHALL
	move #\1,d0
	jsr VDP_SetBorderColor
	POPALL
	endm

;*******************************************************************************
; vectors
;*******************************************************************************
	dc.l	$FFFFFE00		; Stack pointer
	dc.l	Start			; Code start
	dc.l	ExceptionHandler_BusError	; Bus error
	dc.l	ExceptionHandler_AddressError	; Address error
	dc.l	ExceptionHandler_IllegalInstruction	; Illegal instruction
	dc.l	ExceptionHandler_DivByZero	; Divistion by zero
	dc.l	ExceptionHandler_CHK	; CHK exception
	dc.l	ExceptionHandler_TrapV	; TRAPV exception
	dc.l	ExceptionHandler_Privilege	; Privilege violation
	dc.l	ExceptionHandler_TraceException	; TRACE exeption
	dc.l	ExceptionHandler_Line10	; Line 1010 emulator
	dc.l	ExceptionHandler_Line15	; Line 1111 emulator
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Spurious	; Spurious exception
	dc.l	ExceptionHandler_Unhandled	; Interrupt request level 1 (lowest priority)
	dc.l	ExtInt			; Interrupt request level 2 (external interrupt)
	dc.l	ExceptionHandler_Unhandled	; Interrupt request level 3
	dc.l	HBlankRamAddr		; Interrupt request level 4 (VDP interrupt/HBlank)
	dc.l	ExceptionHandler_Unhandled	; Interrupt request level 5
	dc.l	VBlank			; Interrupt request level 6 (VDP interrupt/VBlank)
	dc.l	ExceptionHandler_Unhandled	; Interrupt request level 7 (highest priority)
	dc.l	ExceptionHandler_Trap0	; TRAP #00 exception
	dc.l	ExceptionHandler_Trap	; TRAP #01 exception
	dc.l	ExceptionHandler_Trap	; TRAP #02 exception
	dc.l	ExceptionHandler_Trap	; TRAP #03 exception
	dc.l	ExceptionHandler_Trap	; TRAP #04 exception
	dc.l	ExceptionHandler_Trap	; TRAP #05 exception
	dc.l	ExceptionHandler_Trap	; TRAP #06 exception
	dc.l	ExceptionHandler_Trap	; TRAP #07 exception
	dc.l	ExceptionHandler_Trap	; TRAP #08 exception
	dc.l	ExceptionHandler_Trap	; TRAP #09 exception
	dc.l	ExceptionHandler_Trap	; TRAP #10 exception
	dc.l	ExceptionHandler_Trap	; TRAP #11 exception
	dc.l	ExceptionHandler_Trap	; TRAP #12 exception
	dc.l	ExceptionHandler_ShowDebugArea ; TRAP #13 exception
	dc.l	ExceptionHandler_ShowMem	; TRAP #14 exception
	dc.l	ExceptionHandler_Trap	; TRAP #15 exception
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved
	dc.l	ExceptionHandler_Unhandled	; Reserved

;*******************************************************************************
; ROM header
;*******************************************************************************
	dc.b	'SEGA GENESIS    '	; console name
	dc.b	'(C)HUJO '			; copyright
 	dc.b	'2022.DEC'			; date
    dc.b	'RACING GAME                                     ' ; cart name
    dc.b	'RACING GAME                                     ' ; cart name (alt)
	dc.b	'GM 20200630-01'	; program type / serial number / version
	dc.w	$0000				; ROM checksum
	dc.b	'J               '	; I/O device support (unused)
	dc.l	$00000000			; address of ROM start
	dc.l	RomEnd				; address of ROM end
	dc.l	$FFFF0000,$FFFFFFFF	; RAM start/end
	dc.b 	'RA',$f8,$20
    dc.l	$200001, $20ffff		;dc.b	'            '		; backup RAM info
	;dc.b	'            '		; (12) backup RAM info
	dc.b	'            '		; (12) modem info
	dc.b	'SPACE PANTS GAMES                       ' ; comment	
	dc.b	'JUE             '	; regions allowed

;*******************************************************************************
; entry point & initialization
;*******************************************************************************
Start:
	move.w	#$2700,sr		; disable interrupts


.checksecurity:
	move.b	REG_HWVERSION,d0	; get the hardware version
	andi.b	#$0f,d0				; the last four bits contains the version
	beq.b	.skip				; skip the next instruction on v1 hardware
	move.l	#'SEGA',REG_TMS		; otherwise copy 'SEGA' to TMS register
.skip:

	jsr VDP_Init2			; this works on real hardware, original InitVDP doesnt.



	move.w	#$2700,sr	; disable interrupts
	
    bsr InitVDP				; real hardware crash likely in here

	
	bsr ClearVRAM
	bsr ClearCRAM
	bsr ClearRAM
	bsr Globals_ClearGsys
	jsr JOYSTICK_Init
	
	
	jsr MUSICPLAYER_InitGame
	move.w	#$2000,sr		; re-enable interrupts

.loop:

	jsr	WaitVBlank ; wait for vblank to start
	move.w	#$2700,sr		; disable interrupts
	jsr MAIN_UpdateVBL
	
	;move.w	#$2300,sr		; enable HBL ?
	move.w	#$2000,sr		; re-enable interrupts

	jsr JOYSTICK_Update
	jsr MUSICPLAYER_UpdateGame

	;jsr PSG_UpdateSFX
	;jsr MUSIC_UpdateSong

	move.l sysg_next_screen_addr,d0
	beq .noscreen
	move.l d0,a0
	jsr (a0)
	move.l #0,sysg_next_screen_addr
.noscreen:

	bra.w	.loop


;*******************************************************************************
; traps
;*******************************************************************************

ExtInt:
	rte

VBlank:
	    movem.l d0-d7/a0-a6,-(sp)

	add.l #1,sysg_vblcount
	move.l #0,g_hblcount

	move g_scroll_y,d0
	lsr #1,d0
	move d0,g_hblcount

    movem.l (sp)+,d0-d7/a0-a6
	rte


MUSICPLAYER_UpdateGame:
	move.l g_game_loopaddr,d0
	beq .no
	move.l d0,a0
	jsr (a0)
.no:
	rts
	
MUSICPLAYER_InitGame:
    move.l #UncompressArea,sysg_uncompress_addr

	jsr UTILS_InitRandSeed
	jsr InitState_MusicPlayer
	rts
	


	
    INCLUDE "debug.X68"

	INCLUDE "Globals.X68"
	INCLUDE "vdp.X68"
	INCLUDE "memory_map.X68"
    INCLUDE "debugpanel.X68"
    INCLUDE "ExceptionHandler.X68"


	INCLUDE "SpriteCache.X68"
	INCLUDE "Structs.X68"
	INCLUDE "Mem.X68"
	INCLUDE "gameobject_data.X68"
	INCLUDE "gameobject_structs.X68"
	INCLUDE "Fade.X68"

    INCLUDE "RamBlit.X68"
    INCLUDE "sram.X68"
    INCLUDE "gameplay_main.X68"

	INCLUDE "Cutscene.X68"

	INCLUDE "HolScreenBase.X68"
	
	INCLUDE "gameplaystate_titlescreen.X68"
	INCLUDE "gameplaystate_cutscene.X68"
	INCLUDE "gameplaystate_gameover.X68"
	INCLUDE "gameplaystate_racing.X68"
	INCLUDE "gameplaystate_commando.X68"
	INCLUDE "gameplaystate_musicplayer.X68"
	
    ifd IS_GAME_CUBEDROID
	INCLUDE "gameplaystate_cubedroid.X68"
	INCLUDE "gameplaystate_cubedroid_levelselect.X68"
	endif
	
	ifd IS_GAME_TD
	INCLUDE "gameplaystate_td.X68"
	endif
	
	INCLUDE "gameplaystate_helpscreen.X68"
	INCLUDE "gameplaystate_credits.X68"
	INCLUDE "gameplaystate_helpers.X68"
	
	INCLUDE "Compression.X68"
	INCLUDE "lz4w.X68"


	INCLUDE "spritecode.X68"
	INCLUDE "sprite_hol.X68"
	INCLUDE "HBL.X68"

	INCLUDE "Sound/Sound.X68"
	INCLUDE "Joystick.X68"
	INCLUDE "scroll.X68"
	INCLUDE "gameobjectdefs.X68"
	INCLUDE "GOTOOLS.X68"
	INCLUDE "unitytool.X68"
	INCLUDE "HudMessage.X68"

	INCLUDE "GOManager.X68"
	INCLUDE "go_hol.X68"
	INCLUDE "racing_path.X68"
	INCLUDE "go_player.X68"
	INCLUDE "go_aiplayer.X68"
	INCLUDE "go_holhud.X68"
	INCLUDE "Collision.X68"
	INCLUDE "utils.X68"
	
	INCLUDE "IMAGE.X68"
	INCLUDE "datatables.X68"
	INCLUDE "font.X68"
	INCLUDE "z80.X68"

    ;INCLUDE "SOUND_DualPCM_Data.X68"

	INCLUDE "ExportedSource/images_musicplayer.X68"
    INCLUDE "ExportedSource/NewMusic.X68"
	INCLUDE "ExportedSource/NewLevels.X68"
	INCLUDE "ExportedSource/NewGradients.X68"

	INCLUDE "ExportedSource/globalpalettes.X68"
	INCLUDE "ExportedSource/NewFonts.X68"
	INCLUDE "ExportedSource/NewImages.X68"
	INCLUDE "ExportedSource/NewSprites.X68"
	INCLUDE "ExportedSource/NewCompoundSprites.X68"
	INCLUDE "ExportedSource/NewBoneCompoundSprites.X68"
	INCLUDE "ExportedSource/NewParticles.X68"
	INCLUDE "ExportedSource/NewCurves.X68"
	INCLUDE "ExportedSource/NewSampleGroups.X68"
	
	ifd IS_GAME_CUBEDROID
	INCLUDE "ExportedSource/CubeDroid.X68"
	endif


	
;-------------------------------------------------------------------------------
; Z80 initialization data
;-------------------------------------------------------------------------------
Z80InitDataStart:
	dc.w	$af01
	dc.w	$d91f
	dc.w	$1127
	dc.w	$0021
	dc.w	$2600
	dc.w	$f977 
	dc.w    $edb0
	dc.w	$dde1
	dc.w	$fde1
	dc.w	$ed47
	dc.w	$ed4f
	dc.w	$d1e1                                   
	dc.w    $f108
	dc.w	$d9c1
	dc.w	$d1e1
	dc.w	$f1f9
	dc.w	$f3ed
	dc.w	$5636
	dc.w	$e9e9 
Z80InitDataEnd:

;-------------------------------------------------------------------------------
; VDP initialization data
;-------------------------------------------------------------------------------
;VDPInitDataStart:
;	dc.w	$8004	;
;	dc.w	$8174	;
;	dc.w	$8230
;	dc.w	$8328
;	dc.w	$8407
;	dc.w	$855C
;	dc.w	$8600
;	dc.w	$8700
;	dc.w	$8800
;	dc.w	$8900
;	dc.w	$8A00
;	dc.w	$8B00
;	dc.w	$8C81
;	dc.w	$8D2F		; h scroll
;	dc.w	$8E00
;	dc.w	$8F02
;	dc.w	$9001
;	dc.w	$9100
;	dc.w	$9200
;	dc.w	$93FF
;	dc.w	$94FF
;	dc.w	$9500
;	dc.w	$9600
;	dc.w	$9780
;VDPInitDataEnd:



VDP_Init2:
	    lea	SetupValues(pc),a5
	    movem.w	(a5)+,d5-d7
	    movem.l	(a5)+,a0-a4
	    moveq	#$17,d1
VDPInitLoop:
		moveq #0,d5
	    move.b	(a5)+,d5		;/*	add $8000 to value			*/
	    move.w	d5,(a4)			;/*	move value to	VDP register		*/
	    add.w	d7,d5			;/*	next register				*/
	    dbf	d1,VDPInitLoop
		rts

;vdp_control_port equ 0xC00004
;vdp_counter equ 0xC00008
;vdp_data_port equ 0xC00000
;z80_ram		equ $A00000	; start of Z80 RAM
;z80_bus_request	equ $A11100
;z80_reset		equ $A11200


	align 2
SetupValues:	
	dc.w		$8000			;/* VDP register start number*/
	dc.w		$3FFF			;/* size of RAM/4*/
	dc.w		$100			;/* VDP register diff*/

	dc.l		$A00000			;z80_ram			/* start	of Z80 RAM*/
	dc.l		$A11100			;z80_bus_request		/* Z80 bus request*/
	dc.l		$A11200			;z80_reset		/* Z80 reset*/
	dc.l		$C00000			;vdp_data_port		/* VDP data*/
	dc.l		$C00004		;vdp_control_port	/* VDP control*/

	dc.b		$04			;/* VDP $80 - 8-colour mode*/
	dc.b		$44			;/* VDP $81 - Megadrive mode, DMA enable		*/
	dc.b		($C000>>10)		;/* VDP $82 - foreground nametable address		*/
	dc.b		($F000>>10)		;/* VDP $83 - window nametable address		*/
	dc.b		($E000>>13)		;/* VDP $84 - background nametable address		*/
	dc.b		($D800>>9)		;/* VDP $85 - sprite table address		*/
	dc.b		0			;/* VDP $86 - unused		*/
	dc.b		0			;/*VDP $87 - background colour		*/
	dc.b		0			;/* VDP $88 - unused		*/
	dc.b		0			;/* VDP $89 - unused		*/
	dc.b		255			;/* VDP $8A - HBlank register		*/
	dc.b		0			;/* VDP $8B - full screen scroll		*/
	dc.b		$81			;/* VDP $8C - 40 cell display		*/
	dc.b		($FC00>>10)		;/* VDP $8D - hscroll table address		*/
	dc.b		0			;/* VDP $8E - unused		*/
	dc.b		1			;/* VDP $8F - VDP increment		*/
	dc.b		1			;/* VDP $90 - 64 cell hscroll size		*/
	dc.b		0			;/* VDP $91 - window h position		*/
	dc.b		0			;/* VDP $92 - window v position		*/
	dc.w		$FFFF		;	/* VDP $93/94 - DMA length		*/
	dc.w		0			;/* VDP $95/96 - DMA source		*/
	dc.b		$80			;/* VDP $97 - DMA fill VRAM		*/
	dc.l		$40000080		;/* VRAM address 0		*/
	align 2
	dc.w		$8104			;/* VDP display mode		*/
	dc.w		$8F02			;/* VDP increment		*/
	dc.l		$C0000000		;/* CRAM write mode		*/
	dc.l		$40000010		;/* VSRAM address 0		*/
	dc.b		$9F, $BF, $DF, $FF	;/* values for PSG channel volumes		*/

;*******************************************************************************
; end of rom
;*******************************************************************************
	align 2
RomEnd:
    end 0

