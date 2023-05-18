
CTRL_1_DATA equ $00A10003
CTRL_2_DATA equ $00A10005
CTRL_X_DATA equ $00A10007
CTRL_1_CONTROL equ $00A10009
CTRL_2_CONTROL equ $00A1000B
CTRL_X_CONTROL equ $00A1000D

JOYSTICK_Init:
	move.b	#$40,CTRL_1_CONTROL
	nop
	nop
	move.b	#$43,CTRL_2_CONTROL
	nop
	nop
	move.b	#$7C,CTRL_2_DATA
	nop
	nop
	move.b	#$7F,CTRL_2_CONTROL
	nop
	nop
	move.b	#$7C,CTRL_2_DATA
	nop
	nop
	rts


	
JOYSTICK_Update:
	move.b CTRL_1_DATA, d0    ; Read upper byte from data port
	rol.w  #$8, d0          ; Move to upper byte of d0
	move.b #$40, CTRL_1_DATA ; Write bit 7 to data port
	move.b CTRL_1_DATA, d0    ; Read lower byte from data port
	move.b #$00, CTRL_1_DATA ; Put data port back to normal

	not d0
    move d0,g_pad0	; current pad in d0

 	move g_pad0Old,d0	
	move g_pad0,d1
	eor d1,d0
	and d0,d1
	move d1,g_pad0_pressed

	move g_pad0,g_pad0Old

	rts
