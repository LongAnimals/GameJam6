

; a0 is tile map addr
; a1 is ram addr
COMPRESSION_Map_LZ4W_To_Ram:
	move.w (a0)+,(a1)+	;type
	move.w (a0)+,(a1)+	;w
	move.w (a0)+,(a1)+	;h
	bsr lz4w_unpack_a
	rts


COMPRESSION_LZ4W_To_Ram:
	bsr lz4w_unpack_a
	rts




; a0 is tile map addr
; a1 is ram addr
COMPRESSION_RLE1_To_Ram:
	
	move.w (a0)+,(a1)+	;type
	move.w (a0)+,(a1)+	;w
	move.w (a0)+,(a1)+	;h

	move (a0)+,d7
	bra .first_outer
.outer_loop:
	move (a0)+,d1		;positive = run of same, negative = run of different
	blt .run_of_different
.run_of_same:
	subq #1,d1
	move.w (a0)+,d0
.lp1:
	move.w d0,(a1)+
	dbra d1,.lp1
	bra .next

.run_of_different:
	neg d1
	subq #1,d1
.lp2:
	move.w (a0)+,(a1)+
	dbra d1,.lp2
.next:
.first_outer:
	dbra d7,.outer_loop
	rts

; a0 is compressed data
; VDP_CONTROL is already set up. Just write to VDP_DATA
COMPRESSION_RLE1ToVDP:
	moveq #0,d0
	bra COMPRESSION_RLE1ToVDP_WithExtraData

; a0 is compressed data
; d0 is added to data
; VDP_CONTROL is already set up. Just write to VDP_DATA
COMPRESSION_RLE1ToVDP_WithExtraData:
	move (a0)+,d7
	bra .first_outer
.outer_loop:
	move (a0)+,d1		;positive = run of same, negative = run of different
	blt .run_of_different
.run_of_same:
	subq #1,d1
	move.w (a0)+,d2
	add d0,d2
.lp1:
	move.w d2,VDP_DATA
	dbra d1,.lp1
	bra .next

.run_of_different:
	neg d1
	subq #1,d1
.lp2:
	move.w (a0)+,d2
	add d0,d2
	move d2,VDP_DATA
	dbra d1,.lp2
.next:
.first_outer:
	dbra d7,.outer_loop
	rts	
	