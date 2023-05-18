

	clrso
golist_type             so.w 1
golist_debugname        so.l 1
golist_total 			so.w 1
golist_num_active 		so.w 1
golist_num_inactive 	so.w 1
golist_inactive_list_addr	so.l 1
golist_active_list_addr	so.l 1
golist_sort_list_addr	so.l 1
golist_objects_addr 	so.l 1
golist_highest_num_active 		so.w 1
golist_highest_num_inactive 	so.w 1
;golist_circular_index   so.w 1
;golist_circular_addr   so.l 1
golist_structsize		so.b 0

GOLIST_DEBUGNAME macro \1,\2
    endm

GOMANAGER_NUM_LISTS equ 6

; returns in a3
GOManager_GetList_Car:
    move.l m_GOLists,a3
    rts
GOManager_GetList_FX:
    move.l m_GOLists,a3
    lea golist_structsize(a3),a3
    rts
GOManager_GetList_Treasure:
    move.l m_GOLists,a3
    lea golist_structsize*2(a3),a3
    rts

GOManager_GetList_PlayerBullets:
    move.l m_GOLists,a3
    lea golist_structsize*3(a3),a3
    rts

GOManager_GetList_UIScreen:
    move.l m_GOLists,a3
    lea golist_structsize*4(a3),a3
    rts

GOManager_GetList_EnemyBullet:
    move.l m_GOLists,a3
    lea golist_structsize*5(a3),a3
    rts


GOManager_Setup_Game:
	
; player / general:
    move.l m_GOLists,a3
    move #0,g_num_go_lists

    move.l #'NORM',d1
    move #SPRLIST_NUM_CARS,d0
    move.l m_Golist_General,a0
    bsr GOManager_SetupMemory
	jsr GOManager_AddList
	lea golist_structsize(a3),a3

    move.l #'FX',d1
    move #SPRLIST_NUM_FX,d0
    move.l m_Golist_FX,a0
    bsr GOManager_SetupMemory
	jsr GOManager_AddList
	lea golist_structsize(a3),a3

    move.l #'TREA',d1
    move #SPRLIST_NUM_TREASURE,d0
    move.l m_Golist_Treasure,a0
    bsr GOManager_SetupMemory
	jsr GOManager_AddList
	lea golist_structsize(a3),a3

    move.l #'PBUL',d1
    move #SPRLIST_NUM_PLAYERBULLETS,d0
    move.l m_Golist_PlayerBullets,a0
    bsr GOManager_SetupMemory
	jsr GOManager_AddList
	lea golist_structsize(a3),a3

    move.l #'UISC',d1
    move #SPRLIST_NUM_UISCREENS,d0
    move.l m_Golist_UIScreens,a0
    bsr GOManager_SetupMemory
	jsr GOManager_AddList
	lea golist_structsize(a3),a3

    move.l #'EBUL',d1
    move #SPRLIST_NUM_ENEMYBULLETS,d0
    move.l m_Golist_EnemyBullets,a0
    bsr GOManager_SetupMemory
	jsr GOManager_AddList
	lea golist_structsize(a3),a3

    jsr SPRITE_SortTest1


	rts

; a3 is golist
; a0 is memory area
; d0 is amount 
; d1.l is debug name
GOManager_SetupMemory:
	move d0,golist_total(a3)
    move.l d1,golist_debugname(a3)

    move.l a0,golist_objects_addr(a3)
    move d0,d1
    mulu #go_structsize,d1
    add d1,a0
    move.l a0,golist_active_list_addr(a3)
    lsl #2,d0
    add d0,a0
    move.l a0,golist_inactive_list_addr(a3)
    
    rts
    
; a3 is goList
GoManager_ResetList:
    move.l golist_objects_addr(a3),a0 
    move golist_total(a3),d0    
    mulu #go_structsize,d0
	jsr UTILS_ClearRam

;    move.l golist_objects_addr(a3),golist_circular_addr(a3)
;    move #0,golist_circular_index(a3)

	moveq #0,d2
	move d2,golist_highest_num_active(a3)
	move d2,golist_highest_num_inactive(a3)
	
    move golist_total(a3),d1
	move d1,golist_num_inactive(a3)
	move d2,golist_num_active(a3)
	move.l golist_active_list_addr(a3),a1
	move.l golist_inactive_list_addr(a3),a2
	move.l golist_objects_addr(a3),a0 

    move #0,d5
	move d1,d7
	subq #1,d7
.lp:
	move.l d2,(a1)+
	move.l a0,(a2)+
	move.b #0,go_activestate(a0)
	
	move.l a3,go_golist_addr(a0)        ; store original address of list stuctures in gameobject
    move #-1,go_activelist_index(a0)
	
	move d5,go_index(a0)
	lea go_structsize(a0),a0
	
	addq #1,d5  ; index
	dbra d7,.lp
    rts    
    
; a3 is golist addr
GOManager_AddList:
    bsr GoManager_ResetList
	
    add #1,g_num_go_lists

	rts

GOManager_DeleteObjectA1:
    move.l a0,-(sp)
    move.l a1,a0
    bsr GOManager_DeleteObject
    move.l (sp)+,a0
    rts



;GOManager_GetFreeGO_Circular:
;    move.l golist_circular_addr(a3),a0
;    move.b #SPRSTATE_ACTIVE,go_activestate(a0)
;    add.l #go_structsize,golist_circular_addr(a3)
    
;    add #1,golist_circular_index(a3)
;    move golist_circular_index(a3),d0
;    cmp golist_total(a3),d0
;    blt .no
;    move.l golist_objects_addr(a3),golist_circular_addr(a3)
;    move #0,golist_circular_index(a3)
;.no:    
;    rts
    

;GOManager_DeleteObject_Circular:
;    cmp.b #SPRSTATE_INACTIVE,go_activestate(a0)     ; dont double deactivate
;    beq .no
;    move.b #SPRSTATE_INACTIVE,go_activestate(a0)
;    move.l go_ondeletedfunc(a0),d0
;    beq .nodeletefunc
;    move.l d0,a2
;    jsr (a2)
;.nodeletefunc:
;.no:
;    rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Get a free GameObject
; a3 is GOList addr 
; returns new GameObject in a0. Returns first if there are none free
;------------------------------------------------------------------------------------------------------------------------------------------------
GOManager_GetFreeGO:
; gets last in Inactive list and adds to end of Active list
	move.l golist_inactive_list_addr(a3),a1   ; list of addresses of inactive GOs
	move golist_num_inactive(a3),d0             ; get number of inactive GOs
	beq .noneleft							; if no inactive GOS available, skip
	subq #1,d0
	lsl #2,d0
	move.l (a1,d0),a0						; get address of last inactive GO - InactiveList+((numinactiveGOs-1) * 4)

	move.b #SPRSTATE_ACTIVE,go_activestate(a0)

	move.l golist_active_list_addr(a3),a1
	move golist_num_active(a3),d1

	move d1,go_activelist_index(a0)

	lsl #2,d1
	move.l a0,(a1,d1)

	add #1,golist_num_active(a3)
	sub #1,golist_num_inactive(a3)

.return:
	rts

.noneleft:
	move.l golist_objects_addr(a3),a0 
	rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Delete a gameObject if it's active
;  handle active / inactive lists
;  and update the spawn tracker if that's active
;------------------------------------------------------------------------------------------------------------------------------------------------
GOManager_DeleteObject:
	cmp.b #SPRSTATE_INACTIVE,go_activestate(a0)     ; dont double deactivate
	beq .no
	move.b #SPRSTATE_INACTIVE,go_activestate(a0)
	
    	
	;move.l go_maxcount_type(a0),d0
	;bmi .nomaxcount
	;move.l m_hol_maxActiveTable,a2
	;sub.b #1,(a2,d0)
.nomaxcount:
	
	;move.l go_spawnlist_addr(a0),d0
	;beq .nospawnlist
	;move.l d0,a2
	;move.l #-1,(a2)	
.nospawnlist:
	
	;move.l go_ondeletedfunc(a0),d0
	;beq .nodeletefunc
	;move.l d0,a2
	;jsr (a2)
.nodeletefunc:
	
	bra GOManager_DeleteFromActiveLists
.no:
	rts


GoManager_MarkSpawnListNoRespawn:
    move.l go_spawnlist_addr(a0),d0
    beq .nospawnlist
    move.l d0,a2
    move.l #-1,(a2)	
.nospawnlist:
    rts

;------------------------------------------------------------------------------------------------------------------------------------------------
; Remove a0 GameObject from ActiveList and add to InactiveList
; register-safe
;------------------------------------------------------------------------------------------------------------------------------------------------
; a3 is golist addr
GOManager_DeleteFromActiveLists:
	movem.l d0-d1/a1-a3,-(sp)
	move go_activelist_index(a0),d0
	blt .dontdoit
	
	move.l go_golist_addr(a0),a3    ; get the lists this object belongs to

	move golist_num_active(a3),d1       ;g_num_active_gos,d1
	beq .nomoveactive
	; remove this index from the active list, and replace with the last one
	move.l golist_active_list_addr(a3),a1       
	subq #1,d1
	lsl #2,d1
	move.l (a1,d1),a2
	move d0,go_activelist_index(a2)		; change the moving one's index in to the table
	move #-1,go_activelist_index(a0)

	lsl #2,d0
	move.l a2,(a1,d0)		; move the last in the list in to the empty space
.nomoveactive:
	sub #1,golist_num_active(a3)        ;g_num_active_gos

	move.l golist_inactive_list_addr(a3),a1   ;m_GameObjectInactiveList,a1
	move golist_num_inactive(a3),d0     ;g_num_inactive_gos,d0
	lsl #2,d0
	move.l a0,(a1,d0)
	add #1,golist_num_inactive(a3)      ;g_num_inactive_gos
.dontdoit:
	movem.l (sp)+,d0-d1/a1-a3
	rts


; a1 is init function
; returns object in a1
; passes a0 through to init function as a1
; not at all register safe
GOManager_SpawnGameObject_Car:
	move.l a0,-(sp)
    move.l a1,a2            ; save init function addr
    move.l a0,a1            ; save original caller
	movem.l a1-a3,-(sp)
	bsr GOManager_GetList_Car
	bra GOManager_SpawnGameObject_Inner

GOManager_SpawnGameObject_PlayerBullet:
	move.l a0,-(sp)
    move.l a1,a2            ; save init function addr
    move.l a0,a1            ; save original caller
	movem.l a1-a3,-(sp)
	bsr GOManager_GetList_PlayerBullets
	bra GOManager_SpawnGameObject_Inner

GOManager_SpawnGameObject_Treasure:
    move.l a0,-(sp)
    move.l a1,a2            ; save init function addr
    move.l a0,a1            ; save original caller
	movem.l a1-a3,-(sp)
	bsr GOManager_GetList_Treasure
	bra GOManager_SpawnGameObject_Inner

GOManager_SpawnGameObject_UIScreen:
    move.l a0,-(sp)
    move.l a1,a2            ; save init function addr
    move.l a0,a1            ; save original caller
	movem.l a1-a3,-(sp)
	bsr GOManager_GetList_UIScreen
	bra GOManager_SpawnGameObject_Inner
	
GOManager_SpawnGameObject_FX:
	move.l a0,-(sp)
    move.l a1,a2            ; save init function addr
    move.l a0,a1            ; save original caller
	movem.l a1-a3,-(sp)
	bsr GOManager_GetList_FX
	bra GOManager_SpawnGameObject_Inner

GOManager_SpawnGameObject_EnemyBullet:
	move.l a0,-(sp)
    move.l a1,a2            ; save init function addr
    move.l a0,a1            ; save original caller
	movem.l a1-a3,-(sp)
	bsr GOManager_GetList_EnemyBullet
	bra GOManager_SpawnGameObject_Inner
	

GOManager_SpawnGameObject_Inner
	
    move.l golist_inactive_list_addr(a3),a1   ; list of addresses of inactive GOs
    move golist_num_inactive(a3),d0             ; get number of inactive GOs
    beq .none_available							; if no inactive GOS available, skip
	
	bsr GOManager_GetFreeGO
	bsr GO_ClearGO
	movem.l (sp)+,a1-a3
	move.l a0,-(sp)
	jsr (a2)            ; call init function 
	move.l (sp)+,a1		; and return addr in a1
	move.l (sp)+,a0
	moveq #1,d0 
	rts
.none_available:

    movem.l (sp)+,a1-a3
	move.l (sp)+,a0
    moveq #0,d0
    rts
	

	


	

	
    
;GOManager_SpawnAdHocGameObject_FX_Circular
;	move.l a0,-(sp)
;    move.l a1,a2            ; save init function addr
;    move.l a0,a1            ; save original caller;
;	movem.l a1-a3,-(sp)
;	move.l m_GOLists,a3
;	lea golist_structsize*1(a3),a3
;	bsr GOManager_GetFreeGO_Circular
;	bsr GO_ClearGO
;	movem.l (sp)+,a1-a3
;	; generic init
;   move.l a0,-(sp)
;  jsr (a2)
;    move.l (sp)+,a1		; return in a1
;	move.l (sp)+,a0
;	rts




;------------------------------------------------------------------------------------------------------------------------------------------------
; Update all the active game objects, calling their go_updatefunc(a0)
;  d7 is unsafe during GameObject's update function
;------------------------------------------------------------------------------------------------------------------------------------------------
GOManager_Update:
    jsr GOManager_GetList_Car
    bsr .doone
    jsr GOManager_GetList_FX
    bsr .doone
    jsr GOManager_GetList_Treasure
    bsr .doone
    ;jsr GOManager_GetList_StaticTreasure
    ;bsr .doone
    jsr GOManager_GetList_PlayerBullets
    bsr .doone
    
    jsr GOManager_GetList_EnemyBullet
    bsr .doone
    
    
    rts

.doone:
    move.l golist_active_list_addr(a3),a1
    move golist_num_active(a3),d7
	bra .skip
.loop:
	move.l (a1)+,a0  
	move.l a1,-(sp)
	move.l go_onUpdate(a0),a1
	jsr (a1)
	move.l (sp)+,a1
.skip:
    dbra d7,.loop

    rts


