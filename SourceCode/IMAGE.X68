


;------------------------------------------------------------------------------------------------------------------------------------------------
; d0 is image index
;------------------------------------------------------------------------------------------------------------------------------------------------
IMAGE_ShowStaticImage:
	move.l #NEWIMAGEGROUP,g_image_groupbase
IMAGE_ShowStaticImage_SkipGroup:
	move d0,g_image_index
	jsr IMAGE_LoadPalettes
	jsr IMAGE_LoadChars
	jsr IMAGE_LoadMap	; in 
	rts

IMAGE_ShowStaticImage32:
	move.l #NEWIMAGEGROUP,g_image_groupbase
IMAGE_ShowStaticImage32_SkipGroup:
	move d0,g_image_index
	jsr IMAGE_LoadPalettes
	jsr IMAGE_LoadChars
	jsr IMAGE_LoadMap32	; in 
	rts	

;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------
IMAGE_ShowStaticImagePlaneB:
	move.l #NEWIMAGEGROUP,g_image_groupbase
	move d0,g_image_index
	jsr IMAGE_LoadPalettes
	jsr IMAGE_LoadCharsB
	jsr IMAGE_LoadMapB	; in 
	rts

IMAGE_ShowStaticImagePlaneB32:
	move.l #NEWIMAGEGROUP,g_image_groupbase
	move d0,g_image_index
	jsr IMAGE_LoadPalettes
	jsr IMAGE_LoadCharsB
	jsr IMAGE_LoadMapB32	; in 
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; d0 is image
;------------------------------------------------------------------------------------------------------------------------------------------------
IMAGE_LoadMap:
	move g_image_index,d0
	move.l g_image_groupbase,a0 ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l image_map(a0),a5
	lea tilemap_data(a5),a0
	
	cmp #COMPRESSION_RLE_Words, tilemap_compression_type(a5)
	bne .norle
; unpack to ram, then copy in as normal
	
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_RLE1_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.norle:
	cmp #COMPRESSION_LZ4W, tilemap_compression_type(a5)
	bne .nolz4w
; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.nolz4w:

.doit:
	move #0,d5

	move tilemap_h(a5),d7
	subq #1,d7
.yloop:

	move #0,d0
	move #0,d2
	move d5,d2

	PUSHALL
	move.l #VDPADDR_SCROLL_A,d1
	lsl #7,d2
	add.l d2,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	POPALL

	;jsr UpdateMapVRAM_SetWriteAddrB
	move tilemap_w(a5),d6
	subq #1,d6
.xloop:

	move (a0)+,d0
	add.w g_vram_image1,d0
	move.w d0,VDP_DATA
	dbra d6,.xloop

	add #1,d5
	
	dbra d7,.yloop
	rts


IMAGE_LoadMap_At:

    move d0,-(sp)
    move d1,-(sp)
    
	move g_image_index,d0
	move.l g_image_groupbase,a0 ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l image_map(a0),a5
	lea tilemap_data(a5),a0
	
	cmp #COMPRESSION_RLE_Words, tilemap_compression_type(a5)
	bne .norle
; unpack to ram, then copy in as normal
	
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_RLE1_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.norle:
	cmp #COMPRESSION_LZ4W, tilemap_compression_type(a5)
	bne .nolz4w
; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.nolz4w:

.doit:
	moveq #0,d5
    move 0(sp),d5          ; ypos
    lsl.l #7,d5
    
	move tilemap_h(a5),d7
	subq #1,d7
.yloop:

	move #0,d0
	moveq #0,d2
    move 2(sp),d2
    add d2,d2
    add d5,d2

	PUSHALL
	move.l #VDPADDR_SCROLL_A,d1
	add.l d2,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	POPALL

	;jsr UpdateMapVRAM_SetWriteAddrB
	move tilemap_w(a5),d6
	subq #1,d6
.xloop:

	move (a0)+,d0
	add.w g_vram_image1,d0
	move.w d0,VDP_DATA
	dbra d6,.xloop

	add #128,d5
	
	dbra d7,.yloop
	
	move (sp)+,d1
    move (sp)+,d0
	rts


IMAGE_LoadMap32:
	move g_image_index,d0
	move.l g_image_groupbase,a0 ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l image_map(a0),a5
	lea tilemap_data(a5),a0
	
	cmp #COMPRESSION_RLE_Words, tilemap_compression_type(a5)
	bne .norle
; unpack to ram, then copy in as normal
	
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_RLE1_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.norle:
	cmp #COMPRESSION_LZ4W, tilemap_compression_type(a5)
	bne .nolz4w
; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.nolz4w:

.doit:
	move #0,d5

	move tilemap_h(a5),d7
	subq #1,d7
.yloop:

	move #0,d0
	move #0,d2
	move d5,d2

	PUSHALL
	move.l #VDPADDR_SCROLL_A,d1
	lsl #6,d2
	add.l d2,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	POPALL

	;jsr UpdateMapVRAM_SetWriteAddrB
	move tilemap_w(a5),d6
	subq #1,d6
.xloop:

	move (a0)+,d0
	add.w g_vram_image1,d0
	move.w d0,VDP_DATA
	dbra d6,.xloop

	add #1,d5
	
	dbra d7,.yloop
	rts


IMAGE_LoadMapB:

	move g_image_index,d0
	move.l g_image_groupbase,a0     ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l image_map(a0),a5
	lea tilemap_data(a5),a0
	
	cmp #COMPRESSION_RLE_Words,tilemap_compression_type(a5)
	bne .norle

; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_RLE1_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.norle:
	cmp #COMPRESSION_LZ4W,tilemap_compression_type(a5)
	bne .nolz4w
; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.nolz4w:

.doit:

	move #0,d5

	move tilemap_h(a5),d7
	subq #1,d7
.yloop:

	move #0,d0
	move #0,d2
	move d5,d2

	PUSHALL
	move.l #VDPADDR_SCROLL_B,d1
	lsl #7,d2
	add.l d2,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	POPALL

	;jsr UpdateMapVRAM_SetWriteAddrB
	move tilemap_w(a5),d6
	subq #1,d6
.xloop:

	move (a0)+,d0
	add.w g_vram_image2,d0
	move.w d0,VDP_DATA
	dbra d6,.xloop

	add #1,d5
	
	dbra d7,.yloop
	rts

; d0 = tile x
; d1 = tile y to write to
IMAGE_LoadMapB_At:
    move d0,-(sp)
    move d1,-(sp)

	move g_image_index,d0
	move.l g_image_groupbase,a0     ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l image_map(a0),a5
	lea tilemap_data(a5),a0
	
	cmp #COMPRESSION_RLE_Words,tilemap_compression_type(a5)
	bne .norle

; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_RLE1_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.norle:
	cmp #COMPRESSION_LZ4W,tilemap_compression_type(a5)
	bne .nolz4w
; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.nolz4w:

.doit:

    moveq #0,d5
    move (sp),d5          ; ypos
    lsl.l #7,d5

	move tilemap_h(a5),d7
	subq #1,d7
.yloop:

	move #0,d0
    moveq #0,d2
    move 2(sp),d2
    add d2,d2
    add d5,d2

	PUSHALL
	move.l #VDPADDR_SCROLL_B,d1
	add.l d2,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	POPALL

	;jsr UpdateMapVRAM_SetWriteAddrB
	move tilemap_w(a5),d6
	subq #1,d6
.xloop:

	move (a0)+,d0
	add.w g_vram_image2,d0
	move.w d0,VDP_DATA
	dbra d6,.xloop

	add #128,d5
	
	dbra d7,.yloop
	
	move (sp)+,d1
	move (sp)+,d0
	rts


IMAGE_LoadMapB32:

	move g_image_index,d0
	move.l g_image_groupbase,a0 ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l image_map(a0),a5
	lea tilemap_data(a5),a0
	
	cmp #COMPRESSION_RLE_Words,tilemap_compression_type(a5)
	bne .norle

; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_RLE1_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.norle:
	cmp #COMPRESSION_LZ4W,tilemap_compression_type(a5)
	bne .nolz4w
; unpack to ram, then copy in as normal
	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit
.nolz4w:

.doit:

	move #0,d5

	move tilemap_h(a5),d7
	subq #1,d7
.yloop:

	move #0,d0
	move #0,d2
	move d5,d2

	PUSHALL
	move.l #VDPADDR_SCROLL_B,d1
	lsl #6,d2
	add.l d2,d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	POPALL

	;jsr UpdateMapVRAM_SetWriteAddrB
	move tilemap_w(a5),d6
	subq #1,d6
.xloop:

	move (a0)+,d0
	add.w g_vram_image2,d0
	move.w d0,VDP_DATA
	dbra d6,.xloop

	add #1,d5
	
	dbra d7,.yloop
	rts


	; g_image_blit_x
; g_image_blit_y
; g_image_blit_w
; g_image_blit_h
; g_image_blit_dest_x
; g_image_blit_dest_y
; g_image_index

IMAGE_CLIP_X0 equ 0
IMAGE_CLIP_Y0 equ 0
IMAGE_CLIP_X1 equ 40
IMAGE_CLIP_Y1 equ 28

IMAGE_ClipBlitParams:

	move #0,d5

	move g_image_blit_dest_x,d0
	sub #IMAGE_CLIP_X0,d0
	bge .nox0
	move #IMAGE_CLIP_X0,g_image_blit_dest_x
	add d0,g_image_blit_w
	sub d0,g_image_blit_x
.nox0:

	move g_image_blit_dest_y,d0
	sub #IMAGE_CLIP_Y0,d0
	bge .noy0
	move #IMAGE_CLIP_Y0,g_image_blit_dest_y
	add d0,g_image_blit_h
	sub d0,g_image_blit_y
.noy0:


	move g_image_blit_dest_x,d0
	add g_image_blit_w,d0
	sub #IMAGE_CLIP_X1,d0
	blt .nox1
	sub d0,g_image_blit_w
.nox1:

	move g_image_blit_dest_y,d0
	add g_image_blit_h,d0
	sub #IMAGE_CLIP_Y1,d0
	blt .noy1
	sub d0,g_image_blit_h
.noy1:

	rts

	


; g_image_blit_x
; g_image_blit_y
; g_image_blit_w
; g_image_blit_h
; g_image_blit_dest_x
; g_image_blit_dest_y
; g_image_blit_dest_vdpoffset
; g_image_blit_mapaddr

IMAGE_BlitImageMap:
	PUSHALL

	;move g_image_blit_w,d0
	;ble .return
	;move g_image_blit_h,d0
	;ble .return

	;move.l sysg_leveldata_addr,a0
	;move.w leveldef_bgindex(a0),d0

	move.l g_image_blit_mapaddr,a0
	move.l image_map(a0),a0

	;lea ImageGroup_PopVideo_IMAGEMAP_video_pandadance,a0

	move tilemap_w(a0),d0
	add d0,d0
	move d0,a4		;g_image_blit_temp1
	add.l #tilemap_data,a0


	move g_image_blit_y,d0
	move a4,d1
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0

	move g_image_blit_x,d0
	add d0,d0
	add d0,a0

	move.l a0,a1

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move.w g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	move g_image_blit_h,d7
	subq #1,d7
.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move.l a1,a0
	move g_image_blit_w,d6
	;lsr #1,d6
	subq #1,d6
.xloop:
	move.w (a0)+,d0
	add.w d5,d0					; might not work with priority set
	move.w d0,VDP_DATA
	dbra d6, .xloop

	add.w a4,a1			; add next row width to source
	add.l #128<<16,a5	; adding next row to upper word
	dbra d7,.yloop

.return:
	POPALL
	rts


; a3 contains a dc.w table of addresses to index in to the image map horizontally
IMAGE_BlitImageMap_XTable:
	PUSHALL

	move.l g_image_blit_mapaddr,a0
	move.l image_map(a0),a0

	move tilemap_w(a0),d0
	add d0,d0
	move d0,a4		;g_image_blit_temp1
	add.l #tilemap_data,a0


	move g_image_blit_y,d0
	move a4,d1
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0

	move g_image_blit_x,d0
	add d0,d0
	add d0,a0

	move.l a0,a1

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move.w g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	move g_image_blit_h,d7
	subq #1,d7
.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move.l a1,a0
	move g_image_blit_w,d6
	;lsr #1,d6
	subq #1,d6

	move.l a3,a2
	move (a2)+,d6		; number of tiles
	subq #1,d6

.xloop:
	move (a2)+,d0
	add d0,d0
	move.w (a0,d0),d0

	add.w d5,d0					; might not work with priority set
	move.w d0,VDP_DATA
	dbra d6, .xloop

	add.w a4,a1			; add next row width to source
	add.l #128<<16,a5	; adding next row to upper word
	dbra d7,.yloop

.return:
	POPALL
	rts


; a3 contains a dc.w table of addresses to index in to the image map vertically
IMAGE_BlitImageMap_YTable:
	PUSHALL


	move.l g_image_blit_mapaddr,a0
	move.l image_map(a0),a0

	move tilemap_w(a0),d0
	add d0,d0
	move d0,a4		;g_image_blit_temp1
	add.l #tilemap_data,a0


	move g_image_blit_y,d0
	move a4,d1
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0

	move g_image_blit_x,d0
	add d0,d0
	add d0,a0

	move.l a0,a1

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move.w g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	;move g_image_blit_h,d7
	;subq #1,d7

	move.l a3,a2
	move (a2)+,d7
	subq #1,d7

.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move.l a1,a0

	move a4,d1
	move (a2)+,d0
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0


	move g_image_blit_w,d6
	;lsr #1,d6
	subq #1,d6
.xloop:
	move.w (a0)+,d0
	add.w d5,d0					; might not work with priority set
	move.w d0,VDP_DATA
	dbra d6, .xloop

	;add.w a4,a1			; add next row width to source
	add.l #128<<16,a5	; adding next row to upper word
	dbra d7,.yloop

.return:
	POPALL
	rts


IMAGE_BlitImageMap_YTable_Yflip:
	PUSHALL


	move.l g_image_blit_mapaddr,a0
	move.l image_map(a0),a0

	move tilemap_w(a0),d0
	add d0,d0
	move d0,a4		;g_image_blit_temp1
	add.l #tilemap_data,a0


	move g_image_blit_y,d0
	move a4,d1
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0

	move g_image_blit_x,d0
	add d0,d0
	add d0,a0

	move.l a0,a1

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move.w g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	;move g_image_blit_h,d7
	;subq #1,d7

	move.l a3,a2
	move (a2)+,d7
	subq #1,d7

.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move.l a1,a0

	move a4,d1
	move (a2)+,d0
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0


	move g_image_blit_w,d6
	;lsr #1,d6
	subq #1,d6
.xloop:
	move.w (a0)+,d0
	add.w d5,d0					; might not work with priority set
	move d0,d1
	eor #FLIP_V,d0
	move.w d0,VDP_DATA
	dbra d6, .xloop

	sub.l #128<<16,a5	; adding prev row to upper word
	dbra d7,.yloop

.return:
	POPALL
	rts


; a2 contains a dc.w table of addresses to index in to the image map horizontally
; a3 contains a ... vertically
IMAGE_BlitImageMap_XYTable:
	PUSHALL

	move.l a2,g_IMAGE_xtable
	move.l a3,g_IMAGE_ytable

	move.l g_image_blit_mapaddr,a0
	move.l image_map(a0),a0

	move tilemap_w(a0),d0
	add d0,d0
	move d0,a4		;g_image_blit_temp1
	add.l #tilemap_data,a0


	move g_image_blit_y,d0
	move a4,d1
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0

	move g_image_blit_x,d0
	add d0,d0
	add d0,a0

	move.l a0,a1

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move.w g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	;move g_image_blit_h,d7
	;subq #1,d7

	move.l g_IMAGE_ytable,a2
	move (a2)+,d7
	subq #1,d7

.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move.l a1,a0

	move a4,d1
	move (a2)+,d0
	mulu d1,d0	;g_image_blit_temp1,d0
	add d0,a0

	move.l g_IMAGE_xtable,a3
	move (a3)+,d6		; number of tiles
	subq #1,d6

.xloop:
	move (a3)+,d0
	
	add d0,d0
	move.w (a0,d0),d0

	add.w d5,d0					; might not work with priority set
	move.w d0,VDP_DATA
	dbra d6, .xloop

	;add.w a4,a1			; add next row width to source
	add.l #128<<16,a5	; adding next row to upper word
	dbra d7,.yloop

.return:
	POPALL
	rts


;-------------------------

; minimum of 2 words in x
; g_image_blit_dest_vdpoffset
IMAGE_BlitFill:
	PUSHALL

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	move g_image_blit_h,d7
	subq #1,d7
.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move g_image_blit_w,d6
	lsr #1,d6
	subq #1,d6
.xloop:	
	move.l d5,VDP_DATA
	dbra d6, .xloop

	add.l #128<<16,a5	; adding next row to upper word
	dbra d7,.yloop

	POPALL
	rts

; g_image_blit_dest_vdpoffset
IMAGE_BlitFill_Word:
	PUSHALL

	move.l g_image_blit_vdp_baseaddr,d1
	move g_image_blit_dest_y,d0
	lsl #7,d0
	add d0,d1
	move g_image_blit_dest_x,d0
	add d0,d0
	add d0,d1
	move.l d1,a5

	jsr VDP_BuildVRAMWriteAddress
	move.l d1,a5

	move g_image_blit_dest_vdpoffset,d5
	move d5,d4
	swap d5
	move d4,d5

	move g_image_blit_h,d7
	subq #1,d7
.yloop:
	move.l a5,d1
	move.l d1,VDP_CONTROL

	move g_image_blit_w,d6
	subq #1,d6
.xloop:	
	move.w d5,VDP_DATA
	dbra d6, .xloop

	add.l #128<<16,a5	; adding next row to upper word
	dbra d7,.yloop

	POPALL
	rts


;-------------------------


; uses g_image_index
IMAGE_LoadPalettes:
	movem.l a0-a1 / d0-d1,-(sp)
	move g_image_index,d0
	move.l g_image_groupbase,a0	
	jsr UNITYTOOL_GetImageData
	move.l image_palette(a0),a0

	move (a0)+,d1	; num palettes
	subq #1,d1
.palloop:
	move (a0)+,d0		; palette index

	lea RamPalettes,a1
	lsl #5,d0
	add d0,a1

	move #(16)-1,d0
.loop:
	move.w	(a0)+,(a1)+
	dbra	d0,.loop

	dbra d1,.palloop
	movem.l (sp)+,a0-a1 / d0-d1
	
	move.b #1,g_fade+fade_updated
	rts


Image_AddBlankCharacterToVDP:
	move g_vram_currentpos,d0
	move d0,g_vram_blanktile	
	add #1,g_vram_currentpos
	move.w	d0,d1
	lsl #5,d1					;#0*32,d1   ; setup call to BuildVRAMWriteAddress
    jsr	VDP_BuildAndSetVRAMWriteAddress	
	moveq #0,d0
	rept 8
	move.l d0,VDP_DATA
	endr
    rts

; returns base address of this in d0
IMAGE_LoadChars_Adhoc:
	move g_image_index,d0
	move.l g_image_groupbase,a0	
	jsr UNITYTOOL_GetImageData
	move.l a0,a5

	move.l image_cells(a5),a4
	move.w imagecells_numcells(a4),d6

	move g_vram_currentpos,d0	
	move.w d0,d7
	add d6,g_vram_currentpos

	move.w	d0,d1
	lsl #5,d1					;#0*32,d1   ; setup call to BuildVRAMWriteAddress
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move d6,d0		; num cells
	move.l a4,a0
	jsr	UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	move d7,d0
	rts


; uses g_image_index
IMAGE_LoadChars:
	move g_image_index,d0
	move.l g_image_groupbase,a0 ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l a0,a5

	move.l image_cells(a5),a4		;tile start
	move.w imagecells_numcells(a4),d6

	move g_vram_currentpos,d0
	move.w d0,g_vram_image1
	add d6,g_vram_currentpos


	move.w	g_vram_image1,d1
	lsl #5,d1					;#0*32,d1   ; setup call to BuildVRAMWriteAddress
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move.l a4,a0
	jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	rts

IMAGE_LoadCharsB:
	move g_image_index,d0
	move.l g_image_groupbase,a0 ;lea ImageGroup_Screens,a0
	jsr UNITYTOOL_GetImageData
	move.l a0,a5

	move.l image_cells(a5),a4		;tile start
	move.w imagecells_numcells(a4),d6

	move g_vram_currentpos,d0
	move.w d0,g_vram_image2
	add d6,g_vram_currentpos


	move.w	g_vram_image2,d1
	lsl #5,d1					;#0*32,d1   ; setup call to BuildVRAMWriteAddress
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move.l a4,a0
	jsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags

	rts
