COLTYPE_NONE equ 0
COLTYPE_BULLET equ 1
COLTYPE_HITPLAYER_POINT equ 2
COLTYPE_HITBYPLAYERBULLET equ 3
COLTYPE_PLAYER equ 4
COLTYPE_HITPLAYER_BOX equ 5
COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_POINT equ 6
COLTYPE_HITBYPLAYERBULLET_AND_HITPLAYER_BOX equ 7
COLTYPE_PICKUP equ 8


; lower number = nearer the camera
GOPRIORITY_0 equ 0
GOPRIORITY_1 equ 1
GOPRIORITY_2 equ 2
GOPRIORITY_3 equ 3

GOFLAG_INVISIBLE equ 1
GOFLAG_NOCOLLIDE equ 2
GOFLAG_NOCULL equ 3



    clrso


go_flags 				so.l 1
go_type 				so.w 1
go_tox 					so.l 1
go_toy 					so.l 1
go_ax 					so.l 1      ; acceleration
go_dx 					so.l 1
go_x 					so.l 1
go_dy 					so.l 1
go_y 					so.l 1
go_oldx                 so.l 1
go_oldy                 so.l 1

go_x3 					so.l 1
go_y3 					so.l 1
go_z3 					so.l 1
go_x3a 					so.l 1
go_y3a 					so.l 1


go_dz 					so.l 1
go_z 					so.l 1

go_follow_offset_x  so.w 1
go_follow_offset_y  so.w 1

go_params_addr       so.l 1

go_spawnlist_addr       so.l 1
go_maxcount_type       so.l 1

go_spawnTableIndex      so.w 1

go_bonePositions so.l IK_NUM_BONES

    ifd IS_GAME_CUBEDROID
go_cd_onPushed      so.l 1
go_cd_onEntered      so.l 1
go_cd_onMoveFinished      so.l 1
go_cd_isPushable      so.w 1
go_cd_canMoveOnTo      so.w 1
    endif

    ifd IS_DEBUG_MODE
go_debugname            so.l 1
go_debugstate            so.l 1
    endif

go_bulletTarget         so.l 1

go_prevUpdateFunc 			so.l 1					
go_onUpdate 			so.l 1					
go_onUpdate2 			so.l 1					
go_nextUpdateFunc 			so.l 1					
go_onRender 			so.l 1					; called if non zero at render time
go_onBeforeMainRender so.l 1
go_onAfterMainRender so.l 1
go_cached_frame_addr     so.l 1
go_onDeleted        so.l 1
go_getCustomCollisionFunc 		so.l 1					; 
go_onCollided 		so.l 1
;go_on_exploded_func		so.l 1
go_index                so.w 1
go_collidedindex 		so.w 1
go_colliderAddr 		so.l 1
go_compoundSprAddr 		so.l 1
go_compound_x0          so.w 1
go_compound_x1          so.w 1
go_compound_y0          so.w 1
go_compound_y1          so.w 1

go_onTriggered       so.l 1
go_zoneAddr             so.l 1

go_sprAttributes 	    so.w 1
go_activestate 			so.b 1
go_coltype 				so.b 1
go_frame 				so.l 1	; l (with fraction)
go_framevel 			so.l 1	; l (with fraction)
go_rot 					so.l 1   ; l with fraction. Only uses .b in top word
go_firerot				so.l 1   ; l with fraction. Only uses .b in top word

go_linkedGO             so.l 1
go_initParam0          so.w 1

go_maxAngleCatchupOffset       so.l 1

go_currentTopSpeed      so.l 1
go_usingHandbrake       so.b 1
go_usingTurbo          so.b 1
go_updown_input          so.b 1
go_filler0              so.b 1
go_facingVec              so.b vec_structsize
go_moveVec              so.b vec_structsize
go_tempVec              so.b vec_structsize
go_steeringInput        so.w 1

go_ai_bodger            so.w 1
go_path                 so.b path_structsize
go_lapIndex                so.w 1

go_speed                so.l 1
go_maxspeed             so.l 1
go_state 				so.w 1
go_substate             so.w 1      ; used for follow player
go_follow_toplayeroffset so.w 1
go_priority_b 			so.w 1							; only 2 bits used
go_timer 				so.w 1
go_timerl 				so.l 1
go_shoot_timerMax       so.w 1
go_shootTimer           so.w 1
go_follow_timer			so.w 1
go_sprgroup 			so.l 1
go_sprtype 				so.w 1
go_vdpbase 				so.w 1
go_startx 				so.l 1
go_starty 				so.l 1
go_word0 				so.w 1
go_word1 				so.w 1
go_word2 				so.w 1
go_word3 				so.w 1
go_word4 				so.w 1
go_word5 				so.w 1
go_long0                so.l 1
go_long1                so.l 1
go_long2                so.l 1
go_cutscene_cb          so.l 1
go_activelist_index 	so.w 1
go_golist_addr          so.l 1

go_nocollisiontimer so.w 1

go_health           so.w 1
go_maxHealth           so.w 1
go_scorepopup      so.l 1
go_score            so.w 1

go_ug_ventHoleIndex so.w 1

go_cpath             so.b cpath_structsize

;go_fire_timer       so.w 1
;go_xfacing          so.w 1
;go_firedfromcover   so.w 1
;go_max_xvel         so.l 1
;go_start_dy         so.l 1
;go_at_edge          so.b 1
;go_on_ground        so.b 1
;go_hit_wall        so.b 1
;go_prev_on_ground        so.b 1
;go_transport_worldindex so.w 1
;go_transport_worldreturnindex so.w 1
;go_playerbullettype so.w 1
;go_num_bounces so.w 1

go_chataddr so.l 1

;go_solid_tiles      so.b 0
;go_solid_l          so.b 1
;go_solid_c          so.b 1
;go_solid_r          so.b 1
;go_solid_dl          so.b 1
;go_solid_dc          so.b 1
;go_solid_dr          so.b 1


go_structsize 		so.b 0


   align 2


