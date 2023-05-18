;------------------------------------------------------------------------------------------------------------------------------------------------
; General Utilities
;------------------------------------------------------------------------------------------------------------------------------------------------

INCLUDE_ATAN2_TABLE equ 1
;INCLUDE_NORMAL_TABLE equ 1


;------------------------------------------------------------------------------------------------------------------------------------------------
; Clear some Ram. Not optimized yet
; a0 addr
; d0 number of bytes to clear
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_ClearRam:
    moveq #0,d1
	bra .next
.loop:
    move.b d1,(a0)+
.next:
    dbra d0,.loop
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Set some Ram. Not optimized yet
; a0 addr
; d0 number of bytes to clear
; d1.b byte to set
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_SetRamBytes:
	bra .next
.loop:
    move.b d1,(a0)+
.next:
    dbra d0,.loop
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Copy To Ram. Not optimized yet
; a0 addr0. a1 addr1
; d0.w number of bytes to copy
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_Copy:
	bra .next_bytes
.loop_bytes:
    move.b (a0)+,(a1)+
.next_bytes:
    dbra d0,.loop_bytes
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; Get Rand word or long. (both the same now)
; Returns in d0.l.
; Register safe
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_GetRandLong:
UTILS_GetRandWord:

		movem.l d1-d7,-(sp)
		move.l sysg_rand,d7
        move.l    d7,d6        ; copy Rand(i)
        move.l    #127773,d2    ; sythetic modulus
        bsr.b      .Div        ; divide d6 by 127773
        move.l    d4,d5        ; copy to K1
        muls       #-2836,d5    ; d5 = -2836 * K1
        mulu       #42591,d4    ; multiply d4 by 127773
        move.l    d4,d6
        add.l      d4,d4
        add.l      d6,d4
        sub.l      d4,d7        ; d7 = Rand(i) - K1 * 127773

        moveq    #4,d4        ; loop counter
.loop:        
        move.l    d7,d6        ; multiply d7 by 16807
        lsl.l        #3,d7
        sub.l      d6,d7
        dbf        d4,.loop

        add.l      d5,d7        ; d7 = Rand(i + 1)
        bpl.b      .exit
        addi.l      #$7fffffff,d7    ; normalize negative result
.exit:       
		move.l  d7,sysg_rand
		move.l d7,d0
		movem.l (sp)+,d1-d7
        rts

***********************************************************

.Div:   add.l      d6,d6        ; shift out unused bit
        moveq    #0,d4        ; quotient
        moveq    #14,d3      ; counter
        move.w  d6,d5        ; save low word of Rand(i)
        swap     d6
        andi.l     #$ffff,d6    ; d6 = Rand(i) DIV 2^15

.divloop:        
        add.w    d4,d4        ; line up quotient and..
        add.w    d5,d5        ;   dividend
        addx.l    d6,d6        ; shift in bit of low word
        cmp.l     d2,d6        ; trial subtraction
        bmi.b     .divexit
        sub.l      d2,d6        ; real subtraction
        addq.w  #1,d4        ; put 1 in quotient
.divexit: dbf       d3,.divloop     ; loop
        rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Not a very good random number generator!
; trashes d1 and d2
; return in d0
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_GetRandLongFast:
UTILS_GetRandWordFast:

    movem.l d1-d2,-(sp)
    move.l  sysg_rand,d0
    btst    #1,d0
    sne     d1
    btst    #5,d0
    sne     d2
    eor.b   d2,d1
    btst    #6,d0
    sne     d2
    eor.b   d2,d1
    btst    #31,d0
    sne     d2
    eor.b   d2,d1
    add.b   d1,d1
    addx.l  d0,d0
    move.l sysg_rand,d1
    eor.l d1,d0
    move.l  d0,sysg_rand
    
    movem.l (sp)+,d1-d2
    rts

UTILS_InitRandSeed:
	move.l #$12345678,sysg_rand;
	rts

;d0 is range. exclusive.
UTILS_GetRandWordFastUpTo:
    tst d0
    beq .zero
    move d0,-(sp)
    bsr UTILS_GetRandWordFast
    and.l #$ffff,d0
    move (sp)+,d1
    divu d1,d0
    swap d0
.zero
    rts


;d0 min, d1 max (inclusive)
Utils_RandBetweenInclusive:
    move d0,d2
    move d1,d3
    cmp d2,d3
    beq .zero
    bsr UTILS_GetRandWord
    and.l #$ffff,d0
    move d3,d1
    sub d2,d1           ; difference
    addq #1,d1
    divu d1,d0
    swap d0
    add d2,d0           ; first offset
    rts
.zero:
    rts

;------------------------------------------------------------------------------------------------------------------------------------------------    
; angle in d0, 0-255
; returns in d1 / d2
; safe for the rest
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_GetSinCos:
    movem.l a0/d0,-(sp)
    lea SinCosTable,a0
    and.l #$ff,d0
    lsl #2,d0
    adda.l d0,a0
	moveq #0,d1
	moveq #0,d2
    move.w (a0)+,d1    ;sin
    move.w (a0),d2     ;cos
    
    movem.l (sp)+,a0/d0
    rts


;------------------------------------------------------------------------------------------------------------------------------------------------    
; angle in d0, 0-255
; returns in d0/d1
;' PARAMETERS HAVE CHANGED!
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_GetSinCosLong:
    movem.l a0,-(sp)
    lea SinCosTable,a0
    and.l #$ff,d0
    lsl #2,d0
    adda.l d0,a0
    move.w (a0)+,d1    ;sin
    move.w (a0),d0     ;cos
	ext.l d1
	ext.l d0
    movem.l (sp)+,a0
    rts
    
M_SinCosLong macro \1    
    lea SinCosTable,\1
    and.w #$ff,d0
    add d0,d0
    add d0,d0
    adda d0,a0
    move.w (a0)+,d1    ;sin
    move.w (a0),d0     ;cos
	ext.l d1
	ext.l d0
    endm
    
;------------------------------------------------------------------------------------------------------------------------------------------------    
; angle in d0, 0-255
; returns in d1
; safe for the rest
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_GetSin:
    movem.l a0/d0,-(sp)
    lea SinCosTable,a0
    and #$ff,d0
    lsl #2,d0
    adda d0,a0
	moveq #0,d1
    move.w (a0),d1    ;sin    
    movem.l (sp)+,a0/d0
    rts

;------------------------------------------------------------------------------------------------------------------------------------------------    
; angle in d0, 0-255
; returns in d1 / d2
; safe for the rest
;------------------------------------------------------------------------------------------------------------------------------------------------
UTILS_GetCos:
    movem.l a0/d0,-(sp)
    lea SinCosTable,a0
    and #$ff,d0
    lsl #2,d0
    adda d0,a0
	moveq #0,d1
    move.w 2(a0),d1    ;cos
    movem.l (sp)+,a0/d0
    rts


;------------------------------------------------------------------------------------------------------------------------------------------------
;dx -31 to 31 d0
;dy -31 to 31 d1
;------------------------------------------------------------------------------------------------------------------------------------------------
GetNormal:
	move.l a2,-(sp)
.again:

	cmp #31,d0
	bgt .divide
	cmp #-31,d0
	blt .divide
	cmp #31,d1
	bgt .divide
	cmp #-31,d1
	blt .divide
	bra .no2
.divide:
	asr #1,d0
	asr #1,d1
	bra .again
.no2:

    ifd INCLUDE_NORMAL_TABLE
	lea NormalTable_32_32+ (64*4*32) + (4*32),a2
	endif
	asl #2,d0
	asl #2,d1
	asl #6,d1
	add d0,a2
	add d1,a2
	move.w (a2),d0
	move.w 2(a2),d1
	ext.l d0
	ext.l d1

	move.l (sp)+,a2
	rts


;------------------------------------------------------------------------------------------------------------------------------------------------
; d0,d1 are x and y offsets
; returns angle in d2.w
;------------------------------------------------------------------------------------------------------------------------------------------------
GetAtan2:
	movem.l a0/d0-d1,-(sp)

	move d0,d2
	move d1,d3
	
	cmp #0,d0
	blt .x_neg
.x_pos:
	cmp #0,d1
	blt .pXnY
	bra .pXpY
.x_neg:
	cmp #0,d1
	blt .nXnY
	bra .nXpY

.pXpY:		; both positive
	bsr .lookup
	add #64,d2
	and #$ff,d2
	bra .exit
.pXnY:		; pos x, neg y
	neg d3
	bsr .lookup
	move #63,d3
	sub d2,d3
	move d3,d2
	and #$ff,d2
	
	bra .exit
.nXpY:		; neg x, pos y
	neg d2
	bsr .lookup

	move #63,d3
	sub d2,d3
	move d3,d2
	and #$ff,d2
	add #128,d2
	and #$ff,d2

	bra .exit
.nXnY:		; both negative
	neg d2
	neg d3
	bsr .lookup
	sub #64,d2
	and #$ff,d2
	bra .exit

; d2,d3 positive
.lookup:	
	cmp #64,d2
	bge .toohigh
	cmp #64,d3
	bge .toohigh	
.ok1
    ifd INCLUDE_ATAN2_TABLE
	lea Atan2Table_64_64,a0
	endif

	and.l #$ffff,d3
	and.l #$ffff,d2
	lsl.l #6+0,d3
	;lsl.l #0+0,d2
	add.l d2,a0
	add.l d3,a0
	moveq #0,d2
	move.b (a0),d2
	rts
	
.toohigh:
	lsr #1,d2
	lsr #1,d3
	bra .lookup

.exit:
	movem.l (sp)+,a0/d0-d1
	rts



UTILS_CheckStack:
    rts
    lea $ffffff-3,a0
    move #0,d1
.lp:
    move.l -(a0),d0
    add.l #4,d1
    tst.l d0
    beq .done
    bra .lp
.done:
    ;move.l a0,DebugArea
    ;move.l d1,DebugArea+4
    rts
    
    
SCENETRANSITION_FadeOut:
	FADE_START_OUT .done
	rts
.done:
    move.l sysg_scene_exitFunc,d0
    beq .noexitfunc
    move.l #0,sysg_scene_exitFunc
    move.l d0,a1
    jsr (a1)
.noexitfunc:
    move.l  sysg_next_screen_addr_after_fade,sysg_next_screen_addr
    move.l #0,sysg_next_screen_addr_after_fade
    rts
