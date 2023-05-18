
ADD_DY macro
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    endm
ADD_DX macro
    move.l go_dx(a0),d0
    add.l d0,go_x(a0)
    endm

ADD_DY_GRAV macro
    add.l #GRAVITY,go_dy(a0)
    move.l go_dy(a0),d0
    add.l d0,go_y(a0)
    endm

GO_SET_SCREENSHAKE macro \1
    move.l #SCREENSHAKE_MAX,g_screenshake_timer
    endm


GAMESTATE_NORMAL equ 0
GAMESTATE_FADEOUT equ 1

H_MAP_WIDTH equ 32
H_MAP_HEIGHT equ 32
H_COLMAP_HEIGHT equ 32
H_MAP_SIZE equ H_MAP_WIDTH*H_MAP_HEIGHT      ;1024
H_COLMAP_WIDTH_IN_RAM equ H_MAP_WIDTH
H_COLMAP_SIZE_IN_RAM equ H_COLMAP_WIDTH_IN_RAM*H_COLMAP_HEIGHT      ;1024
H_COLMAP_WIDTH_SHIFT equ 5

