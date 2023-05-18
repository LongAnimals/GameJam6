

SPRITEANIMMODE_NORMAL equ 0
SPRITEANIMMODE_DIRECTIONAL equ 1


	clrso 
pathcmds_baseaddr so.l 1
pathcmds_current_index so.w 1
pathcmds_num_commands so.w 1
pathcmds_current_addr so.l 1
pathcmds_structsize so.b 0

	clrso
pathcmd_position so.w 1
pathcmd_command so.w 1
pathcmd_data0	so.w 1
pathcmd_data1	so.w 1
pathcmd_structsize so.b 0

	clrso
wavedefs_numwaves 		so.w 1
wavedefs_wavesptr		so.l 1

	clrso
wavedef_sprite_index so.w 1
wavedef_collider_addr so.l 1
wavedef_startx 		so.w 1
wavedef_starty 		so.w 1
wavedef_delay 		so.w 1
wavedef_delay1 		so.w 1
wavedef_animmode	so.w 1
wavedef_sprAnimVel	so.l 1
wavedef_bulletsperframe so.w 1
wavedef_pathbranchchance so.w 1
wavedef_path0 		so.l 1
wavedef_path0_commands so.l 1
wavedef_path1 		so.l 1
wavedef_path1_commands so.l 1
wavedef_layout 		so.l 1
wavedef_branchpath 		so.l 1
wavedef_structsize 	so.b 0



;--------------------------------------------------------------------------------------------------
; LEVELSDEF
; Main exported levels struct
;--------------------------------------------------------------------------------------------------
	clrso
levelsdef_numlevels so.w 1
levelsdef_firstleveladdr so.l 0


;--------------------------------------------------------------------------------------------------
; LEVELDEF
; for each level definition
;--------------------------------------------------------------------------------------------------
	clrso
leveldef_flags so.l 1
leveldef_zones so.l 1
leveldef_spawners so.l 1
leveldef_tilemap so.l 1
leveldef_paths so.l 1
leveldef_palettes so.l 1
leveldef_collision so.l 1
leveldef_usedsprites so.l 1
leveldef_levelname so.l 1
leveldef_fgindex so.w 1
leveldef_bgindex so.w 1

;--------------------------------------------------------------------------------------------------
; TILEMAP
; standard background map
;--------------------------------------------------------------------------------------------------
	clrso
tilemap_compression_type so.w 1
tilemap_w so.w 1
tilemap_h so.w 1
tilemap_data so.b 0


;--------------------------------------------------------------------------------------------------
; COLLISION MAP
; data is stored as a (crunched) bitmap. one bit per tile.
; offset table is a lookup table for y index, as widths aren't necessarily bit friendly.
;--------------------------------------------------------------------------------------------------	
	clrso
collisionmap_compression_type so.w 1
collisionmap_w so.w 1
collisionmap_h so.w 1
collisionmap_dataaddr so.l 1
collisionmap_offset_table so.b 0

;--------------------------------------------------------------------------------------------------
; COMPOUND SPRITE STUFF
; need some renaming done here - 'frame' is not ideal
;--------------------------------------------------------------------------------------------------	
	clrso
compoundsprs_numsprites so.w 1
compoundsprs_firstspriteaddr so.b 0

	clrso
compoundspr_numframes so.w 1
compoundspr_firstframeaddr so.b 0

	clrso
compoundspr_noflipaddr so.l 1
compoundspr_collisionaddr so.l 1
compoundspr_hflipaddr so.l 1
compoundspr_collisionaddr_hflip so.l 1
compoundspr_size so.b 1
compoundspr_sizeshift equ 4

	clrso
compoundsprframe_numhwsprites so.w 1
compoundsprframe_firsthwspr so.b 0

	clrso
compoundsprframespr_sprindex so.w 1
compoundsprframespr_sproffset so.w 1
compoundsprframespr_flips so.w 1
compoundsprframespr_xoff so.w 1
compoundsprframespr_yoff so.w 1
compoundsprframespr_size so.b 0


;--------------------------------------------------------------------------------------------------
; SPR GROUP
; top level of a group of sprites. Contains multiple frames in a group
;--------------------------------------------------------------------------------------------------	clrso
	clrso
sprgroup_coltable_addr so.l 1
sprgroup_cells_addr so.l 1
sprgroup_numchars so.w 1
sprgroup_numFrames so.w 1
sprgroup_firstFrame so.b 0

;--------------------------------------------------------------------------------------------------
; SPR GROUP FRAME
; per sprite data. This is in a format useful for copying direct to hardware Sprite List format
;--------------------------------------------------------------------------------------------------	clrso
	clrso
sprgroupframe_originy so.w 1
sprgroupframe_sizeFlags so.w 1
sprgroupframe_charoffset so.w 1
sprgroupframe_paletteFlags so.w 1
sprgroupframe_originx so.w 1
sprgroupframe_filler so.w 3
sprgroupframe_size so.b 0
sprgroupframe_sizeshift equ 4



;--------------------------------------------------------------------------------------------------
; COLLIDERS
; Top level management
;--------------------------------------------------------------------------------------------------	clrso
	clrso
colliders_numgroups so.w 1
colliders_firstgroupoffset so.w 1
		
	
;--------------------------------------------------------------------------------------------------
; COLLIDER GROUP
; A list of colliders
;--------------------------------------------------------------------------------------------------	clrso
	clrso
collidergroup_numcolliders so.w 1
collidergroup_firstoffset so.b 0

;--------------------------------------------------------------------------------------------------
; COLLIDER
; the format is CPU friendly, accessed with postincrements
;--------------------------------------------------------------------------------------------------	clrso
	clrso
collider_offset_x0 so.w 1
collider_offset_x1 so.w 1
collider_offset_y0 so.w 1
collider_offset_y1 so.w 1
collider_size so.b 0
	


;--------------------------------------------------------------------------------------------------
; ZONES
; Top level, held within level data 
;--------------------------------------------------------------------------------------------------	clrso
	clrso
zones_num so.w 1
zones_firstpointer so.l 1



;--------------------------------------------------------------------------------------------------
; IMAGES
; Top level. Images come in distinct groups at authoring time. Each one has this structure
;--------------------------------------------------------------------------------------------------	clrso
	clrso
images_numimages so.w 1
images_total_cells so.w 1
images_first_image so.b 4

;--------------------------------------------------------------------------------------------------
; IMAGE
; Self contained information for each image (image being a map and cells)
;--------------------------------------------------------------------------------------------------	clrso
    clrso
image_cells so.l 1
image_map so.l 1
image_palette so.l 1
image_colorbars so.l 1
image_size so.b 1

;--------------------------------------------------------------------------------------------------
; COLORBAR
; Self contained information for each image (image being a map and cells)
;--------------------------------------------------------------------------------------------------	clrso
    clrso
colorbar_spacing so.w 1
colorbar_num_colors so.w 1
colorbar_first_color so.b 0


;--------------------------------------------------------------------------------------------------
; IMAGECELLS
; Info for a generic group of cell data. Used elsewhere too, eg. sprites
;--------------------------------------------------------------------------------------------------	clrso
	clrso
imagecells_compression_type so.w 1
imagecells_numcells so.w 1
imagecells_data so.b 1


;--------------------------------------------------------------------------------------------------
; EXPORTED FONT
; top level structure for a font
;--------------------------------------------------------------------------------------------------	clrso
	clrso
exfont_chars so.l 1
exfont_palette so.l 1


;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------------
; OPTIONS - used for debug, pause menu, title screen etc.
;--------------------------------------------------------------------------------------------------
	clrso
options_type so.b 1
options_flags so.b 1
options_varaddr so.l 1
options_buttonaddr so.l 1
options_labeladdr so.l 1
options_size so.b 0

options_textlist equ options_buttonaddr

;--------------------------------------------------------------------------------------------------
; OPTION GROUP
;--------------------------------------------------------------------------------------------------
	clrso
optiongroup_amt so.w 1
optiongroup_flags so.w 1
optiongroup_x so.w 1
optiongroup_y so.w 1
optiongroup_first so.b 0



;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
; GAMEWORLDS
; USed for progression through levels and zones
;--------------------------------------------------------------------------------------------------
	clrso
gameworlds_numworlds so.w 1
gameworlds_firstworldaddr so.l 1

	clrso
gameworlds_levels_addr so.l 1
gameworlds_displayname_addr so.l 1

;--------------------------------------------------------------------------------------------------
; GAMEWORLD
;--------------------------------------------------------------------------------------------------
	clrso
gameworld_numlevels so.w 1
gameworld_firstlevelindex so.w 1


;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
; PARTICLE SYSTEM -PS
;--------------------------------------------------------------------------------------------------
    clrso
ps_state so.w 1
ps_timer so.w 1
ps_sprcharoffset so.w 1
ps_flipbits so.w 1
ps_spraddr so.l 1
ps_dx   so.l 1
ps_x    so.l 1
ps_dy   so.l 1
ps_y    so.l 1
ps_updatefunc so.l 1
ps_structsize so.b 0 

    clrso
fxps_state so.w 1
fxps_dx   so.l 1
fxps_x    so.l 1
fxps_dy   so.l 1
fxps_y    so.l 1
fxps_timer so.w 1
fxps_rot so.w 1
fxps_rot_vel so.w 1
fxps_updatefunc so.l 1
fxps_structsize so.b 0 

;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
; SPAWN INFO
; Data for each spawnable object
; varable length - per object data added at the end
;--------------------------------------------------------------------------------------------------
    clrso
spawn_xpos so.w 1
spawn_ypos so.w 1
spawn_type so.w 1
spawn_flipflags so.w 1
spawn_spawn_offset so.w 1
spawn_unspawn_offset so.w 1
spawn_data so.w 1

;--------------------------------------------------------------------------------------------------
; SPAWNTABLE data
; Data to keep track of spawned objects
;--------------------------------------------------------------------------------------------------
	clrso
spawntable_always_active_addr so.l 1
spawntable_spawnable_addr so.l 1
