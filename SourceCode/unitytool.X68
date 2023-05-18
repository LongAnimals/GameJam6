
FLIP_NONE equ 0
FLIP_H equ $800
FLIP_V equ $1000
FLIP_HV equ $1800
FLIP_NOT_HV equ $e7ff
FLIP_NOT_V equ $efff
FLIP_NOT_H equ $f7ff

FLIP_H_BIT equ 11
FLIP_V_BIT equ 12

LEVELFLAG_SWITCH_PLANES equ 1

SPRMEMTYPE_VRAM equ 0
SPRMEMTYPE_ROM equ 1

ZONETYPE_BOX equ 0
ZONETYPE_CIRCLE equ 1

	clrso
levelcharset_charset so.l 1
levelcharset_mapanims so.l 1



; d0 is image index
; returns a0 pointing to image_data
; a0 is group pointer
UNITYTOOL_GetImageData:
	add.l #images_first_image,a0
	mulu #image_size,d0
	add d0,a0
	rts

; returns in d0
UNITYTOOL_GetNumLevels:
	move.l sysg_leveldefs_addr,a0		;lea PandaLevels,a0
	move levelsdef_numlevels(a0),d0
	rts


;returnscollision  map in a1
UNITYTOOL_GetLevelCollisionMap:
	move.l sysg_leveldata_addr,a1
	move.l leveldef_collision(a1),a1
	rts


;returns map in a1
UNITYTOOL_GetLevelTileMap:
	move.l sysg_leveldata_addr,a1
	move.l leveldef_tilemap(a1),a1
	rts

; index in d0
;returns map in a0
UNITYTOOL_GetImageGroup_FarBackgrounds
	;lea ImageGroup_FarBackgrounds,a0
	add.l #images_first_image,a0
	mulu #image_size,d0
	add.l d0,a0
	rts


; uses sysg_levelchars_addr as base
UNITYTOOL_LoadAllLevelTiles:

	move.l sysg_leveldata_addr,a0
	move.w leveldef_fgindex(a0),d0
	lsl #3,d0

	move.l sysg_levelchars_addr,a5		;lea Panda_LevelCharSets,a5
	move.l levelcharset_charset(a5,d0),a4

	move.w imagecells_numcells(a4),d6

	move g_vram_currentpos,d0
	move.w d0,g_vram_fg
	add d6,g_vram_currentpos

	move d0,d1
	lsl #5,d1
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move.l a4,a0
	bsr.w	UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	rts

UNITYTOOL_LoadBackgroundChars:
	move.l sysg_leveldata_addr,a0
	move.w leveldef_bgindex(a0),d0

	jsr UNITYTOOL_GetImageGroup_FarBackgrounds
	move.l image_cells(a0),a4
	move.w imagecells_numcells(a4),d6

	move g_vram_currentpos,d0
	move.w d0,g_vram_bg
	add d6,g_vram_currentpos

	move d0,d1
	lsl #5,d1
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move.l a4,a0
	bsr.w	UNITYTOOL_UploadMultipleCharsWithCompressionFlags

	rts


; assumes that the map size is exactly 64x32
UNITYTOOL_LoadBackgroundMap:

	move.l sysg_leveldata_addr,a0
	move.w leveldef_bgindex(a0),d0

	jsr UNITYTOOL_GetImageGroup_FarBackgrounds	

	move.l image_map(a0),a5
	
	cmp #COMPRESSION_RLE_Words,tilemap_compression_type(a5)
	beq UNITYTOOL_UncompressMapToVDP_RLE
	cmp #COMPRESSION_LZ4W,tilemap_compression_type(a5)
	bne .nolz4w

	move.l sysg_uncompress_addr,a1
	move.l a5,a0
	jsr COMPRESSION_Map_LZ4W_To_Ram
	move.l sysg_uncompress_addr,a5
	lea tilemap_data(a5),a0
	bra .doit

.nolz4w:

.doit:

	move.w tilemap_w(a5),d0
	move.w tilemap_h(a5),d1
	lea tilemap_data(a5),a0
	;add.l #tilemap_data,a0
	move d0,d7
	mulu d1,d7
	subq #1,d7

	moveq #0,d0
	or.l g_scroll_vram_write_base_bg,d0
	move.l d0,VDP_CONTROL

.loop:
	moveq #0,d0
	move.w (a0)+,d0
	add.w g_vram_bg,d0
	or.w g_scroll_priorityflag_bg,d0
	move.w d0,VDP_DATA
	dbra d7, .loop
	rts


UNITYTOOL_UncompressMapToVDP_RLE:
	move.l a5,a0
	add.l #tilemap_data,a0
	moveq #0,d0
	or.l g_scroll_vram_write_base_bg,d0
	move.l d0,VDP_CONTROL
	move.w g_vram_bg,d0
	add.w g_scroll_priorityflag_bg,d0
	jsr COMPRESSION_RLE1ToVDP_WithExtraData
	rts


UNITYTOOL_LoadAllLevelPalettes:
	move.l sysg_leveldata_addr,a0
	move.l leveldef_palettes(a0),a0

	lea RamPalettes,a1
	move #(4*8)-1,d0
.loop:
	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

UNITYTOOL_ResetVramSpriteIndex:
	move g_vram_currentpos,d0
	move.w d0,g_vram_sprites
	rts


; d0 is sprite index
UNITYTOOL_LoadSingleSprite:
	PUSHALL

	move.l sysg_sprites_baseaddr2,a4    ;lea sprdefs+2,a4
	move d0,d1
	lsl #2,d1
	add d1,a4
	move.l (a4),a4		; addr of group

	move g_vram_currentpos,d5

	lea SpriteVDPOffsets,a3
	add d0,d0
	move d5,(a3,d0)		; write the base address of the group in to RAM table

	; do chars for one group
	move.l sprgroup_cells_addr(a4),a0		; the def
	move.l a0,a3		; a0 is now an ImageCells addr 

	
	move.w sprgroup_numchars(a4),d6		; number of cells
	add d6,g_vram_currentpos

	move d5,d1
	lsl #5,d1
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move.l a3,a0
	PUSHALL
	bsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	POPALL

	POPALL

	rts


UNITYTOOL_LoadAllSprites:

	move.l sysg_leveldata_addr,a5
	move.l leveldef_usedsprites(a5),a5
	move (a5)+,d7
	subq #1,d7

	move g_vram_currentpos,d0
	move.w d0,g_vram_sprites

	move d0,d5
.gl:
	move.w (a5)+,d0	; sprite type

	move.l sysg_sprites_baseaddr2,a4        ;lea sprdefs+2,a4
	move d0,d1
	lsl #2,d1
	add d1,a4
	move.l (a4),a4		; addr of group

	lea SpriteVDPOffsets,a3
	add d0,d0
	move d5,(a3,d0)		; write the base address of the group in to RAM table


	; do chars for one group
	move.l sprgroup_cells_addr(a4),a0		; the def
	move.l a0,a3		; a0 is now an ImageCells addr 

	move.w sprgroup_numchars(a4),d6		; number of cells
	add d6,g_vram_currentpos

	move d5,d1
	lsl #5,d1
	jsr	VDP_BuildVRAMWriteAddress	; build the VRAM write address, using d1
	move.l a3,a0
	PUSHALL
	bsr UNITYTOOL_UploadMultipleCharsWithCompressionFlags
	POPALL

	add	d6,d5		; next cell addr in vram
.skip:
	dbra d7,.gl

	rts




; a0 = addr of cells
; d0 = num cells
; d1.l vdp control addr
UNITYTOOL_UploadMultipleChars:
	subq	#$01,d0	; iterate over ((number of tiles to load) - 1)
	move.l	d1,(VDP_CONTROL)
.loop:
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	dbra d0,.loop
	rts


UNITYTOOL_UploadMultipleCharsWithCompressionFlags:
	cmp.w #COMPRESSION_None,imagecells_compression_type(a0)
	beq UNITYTOOL_UploadMultipleChars_Uncompressed
	cmp.w #COMPRESSION_RLE_Words,imagecells_compression_type(a0)
	beq UNITYTOOL_UploadMultipleCharsRLE1
	cmp.w #COMPRESSION_LZ4W,imagecells_compression_type(a0)
	beq UNITYTOOL_UploadMultipleCharsLZ4W
	rts

; d1.l VDP addr
; a0 is chars data
UNITYTOOL_UploadMultipleChars_Uncompressed:

	move.l	d1,(VDP_CONTROL)
	move imagecells_numcells(a0),d0
	subq #1,d0
	lea imagecells_data(a0),a0
.loop:
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	dbra d0,.loop
	rts	

; d1.l vdp control addr
; a0 = addr of RLE data
UNITYTOOL_UploadMultipleCharsRLE1:
	move.l	d1,(VDP_CONTROL)
	lea imagecells_data(a0),a0

	jsr COMPRESSION_RLE1ToVDP
	rts

; d1.l vdp control addr
; a0 = addr of RLE data
UNITYTOOL_UploadMultipleCharsLZ4W:
	move.l d1,-(sp)


	move.l a0,a5
	lea imagecells_data(a5),a0

	move.l sysg_uncompress_addr,a1
	jsr COMPRESSION_LZ4W_To_Ram
	move.l (sp)+,d1

	move.l sysg_uncompress_addr,a0
	move.l	d1,(VDP_CONTROL)
	move imagecells_numcells(a5),d0
	subq #1,d0
.loop:
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	move.l (a0)+,(VDP_DATA)
	dbra d0,.loop
	rts	



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
