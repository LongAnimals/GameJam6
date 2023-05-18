

POOPY equ 0
UIGenericBackground_ScrollTable equ POOPY
UIGenericBackground_ScrollTableDMA equ POOPY+1024
UIGenericBackground_ScrollTableSource equ POOPY+2048

UIGenericBackground_ScrollTableA equ UIGenericBackground_ScrollTableSource


UIGenericBackground_Init:
	lea UIGenericBackground_ScrollTable,a0
	lea UIGenericBackground_ScrollTableDMA,a1
	lea UIGenericBackground_ScrollTableSource,a2
	move #224-1,d7
	moveq #0,d6
.hlp:
	move.l d6,(a0)+
	move.l d6,(a1)+

	jsr UTILS_GetRandWord
	and.l #$ffff,d0
	lsl.l #2,d0
	add.l #$4000,d0
	move.l d0,(a2)+

	dbra d7,.hlp
	rts

UIGenericBackground_Update:
	move #REG_MODE3 | REGMASK_MODE3_HSCROLLMODE_SCAN |REGMASK_MODE3_VSCROLLMODE_FULL, VDP_CONTROL

	lea UIGenericBackground_ScrollTable,a1
	lea UIGenericBackground_ScrollTableDMA,a3
	lea UIGenericBackground_ScrollTableSource,a0
	moveq #0,d0
	move #(224/4)-1,d7
.hlp:

	rept 4
	move.w d0,(a3)+		; store 0 for fg scroll
	move.w (a1),(a3)+		; store word for bg scroll from long_length data table
	move.l (a0)+,d1		; grab scroll speed for scan
	sub.l d1,(a1)+	; subtract it from the long-length data table
	endr

	dbra d7,.hlp
	rts

UIGenericBackground_DMACopy:
scrolltabledma_len equ 224*4
	move.l #UIGenericBackground_ScrollTableDMA,d0
	move.l #VDPADDR_HSCROLL,d1
	move.l #scrolltabledma_len,d2
	move #2,d3
	jsr VDP_SetDMA
	rts


;----------------------------------------------------------------------------------------------------------------------

