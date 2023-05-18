
    clrso
path_addr           so.l 1
path_numNodes       so.w 1
path_currentIndex   so.w 1
path_crossType      so.w 1
path_testfunct      so.l 1
path_x              so.w 1
path_y              so.w 1
path_passedNodeThisFrame so.w 1     ; -1 if none
path_structsize     so.b 0

    clrso
pathnode_x          so.w 1
pathnode_y          so.w 1
pathnode_crossType  so.w 1
pathnode_filler     so.w 1
pathnode_stuctsize  so.w 1

; path in a1
; d0 path index 
PATH_Init:
    move.l sysg_levelInfo+levelinfo_paths,a2
    add d0,d0
    add d0,d0
    move.l (a2,d0),a2
    move (a2)+,path_numNodes(a1)
    move #0,path_currentIndex(a1)
    move.l a2,path_addr(a1)
    move #-1,path_passedNodeThisFrame(a1)
    rts

PATH_CacheCurrentNodeData:
    move.w path_currentIndex(a1),d0
    lsl #3,d0
    move.l path_addr(a1),a2
    add d0,a2
    move pathnode_x(a2),path_x(a1)
    move pathnode_y(a2),path_y(a1)
    move pathnode_crossType(a2),path_crossType(a1)
    move pathnode_crossType(a2),d0
    add d0,d0
    add d0,d0
    lea CheckPassed_Functions,a2
    move.l (a2,d0),path_testfunct(a1)
    rts


PATH_NextPos:
    add #1,path_currentIndex(a1)
    move path_currentIndex(a1),d0
    cmp path_numNodes(a1),d0
    blt .no
    move #0,path_currentIndex(a1)
.no:
    rts
    
; a1 is path
; return x,y,in d0,d1 
PATH_GetCurrentNodeXY:
    move.w path_currentIndex(a1),d0
    lsl #3,d0
    move.l path_addr(a1),a2
    add d0,a2
    move (a2)+,d0
    move (a2)+,d1
    rts


; assumes data is cached with PATH_CacheCurrentNodeData
; go pos and oldpos
; Path struct in a1
PATH_Test:
    move #-1,path_passedNodeThisFrame(a1)
    move.l path_testfunct(a1),d0
    beq .notest
    move.l d0,a2 
    jsr (a2)
    beq .notest
    
    move path_currentIndex(a1),path_passedNodeThisFrame(a1)
    ; passed here
    bsr PATH_NextPos
    bsr PATH_CacheCurrentNodeData
.notest:
    rts
    
CheckPassed_Functions:
    dc.l 0
    dc.l CheckPassed_HLine
    dc.l CheckPassed_VLine
    dc.l CheckPassed_Diag2
    dc.l CheckPassed_Diag1


; tl to br
CheckPassed_Diag1:
    move path_x(a1),d0
    move path_y(a1),d1
    sub go_oldy(a0),d1
    add d1,d0

    move go_oldx(a0),d1
    cmp d0,d1
    blt .old_less
.old_greater:
    move path_x(a1),d0
    move path_y(a1),d1
    sub go_y(a0),d1
    add d1,d0
    move go_x(a0),d1
    cmp d0,d1
    blt .passed
    
    moveq #0,d0
    rts
    
.old_less:
    move path_x(a1),d0
    move path_y(a1),d1
    sub go_y(a0),d1
    add d1,d0
    move go_x(a0),d1
    cmp d0,d1
    bge .passed
    
    moveq #0,d0
    rts
.passed:
    moveq #1,d0
    rts

    


CheckPassed_Diag2:
    move path_x(a1),d0
    move path_y(a1),d1
    sub go_oldy(a0),d1
    sub d1,d0

    move go_oldx(a0),d1
    cmp d0,d1
    blt .old_less
.old_greater:
    move path_x(a1),d0
    move path_y(a1),d1
    sub go_y(a0),d1
    sub d1,d0
    move go_x(a0),d1
    cmp d0,d1
    blt .passed
    
    moveq #0,d0
    rts
    
.old_less:
    move path_x(a1),d0
    move path_y(a1),d1
    sub go_y(a0),d1
    sub d1,d0
    move go_x(a0),d1
    cmp d0,d1
    bge .passed
    
    moveq #0,d0
    rts
.passed:
    moveq #1,d0
    rts



; a1 path
CheckPassed_HLine:  
    move path_y(a1),d0
    cmp go_oldy(a0),d0
    blt .prev_less
    
    cmp go_y(a0),d0
    blt .passed
    moveq #0,d0
    rts
    
.prev_less:

    cmp go_y(a0),d0
    bge .passed
    moveq #0,d0
    rts
.passed:
    moveq #1,d0
    rts


CheckPassed_VLine:
    move path_x(a1),d0
    cmp go_oldx(a0),d0
    blt .prev_less
    
    cmp go_x(a0),d0
    blt .passed
    moveq #0,d0
    rts
    
.prev_less:
    cmp go_x(a0),d0
    bge .passed
    moveq #0,d0
    rts
.passed:
    moveq #1,d0
    rts



;-----------------------------------------------------------------------------------------------------------------------

RECORD_DATA_MAXSIZE equ 6000
    clrso
record_currentIndex so.w 1
record_currentAddr so.l 1
record_currentsize so.w 1
record_skipCount so.w 1
record_prevPosX so.w 1
record_prevPosY so.w 1
record_lastdataX so.b 1
record_lastdataY so.b 1
record_data so.b RECORD_DATA_MAXSIZE
record_structsize so.b 0


PLAYBACK_Init:
    lea PlaybackData,a1
    move #0,record_currentIndex(a1)
    lea record_data(a1),a2
    move.l a2,record_currentAddr(a1)
    rts
    
PLAYBACK_GetNextPos:
    lea PlaybackData,a1
    
    move.l record_currentAddr(a1),a2
    
    tst record_currentIndex(a1)
    bne .notfirst
    
    move (a2)+,go_x(a0)
    move (a2)+,go_y(a0)
    move.b (a2)+,go_facingVec+vec_ang(a0)
    bra .done
    
.notfirst:
    move.b (a2)+,d0
    ext.w d0
    add record_prevPosX(a1),d0
    move d0,go_x(a0)
    
    move.b (a2)+,d0
    ext.w d0
    add record_prevPosY(a1),d0
    move d0,go_y(a0)

    move.b (a2)+,go_facingVec+vec_ang(a0)
    
    bra .done
    
.done:
    move.l a2,record_currentAddr(a1)
    add #1,record_currentIndex(a1)
    move go_x(a0),record_prevPosX(a1)
    move go_y(a0),record_prevPosY(a1)
    rts

RECORD_CopyToPlayback:
    move.l a0,-(sp)
    lea RecordData,a0
    lea PlaybackData,a1
    move #record_structsize,d0
    jsr UTILS_Copy
    move.l (sp)+,a0
    rts


RECORD_Start:
    lea RecordData,a1
    move #0,record_currentIndex(a1)
    lea record_data(a1),a2
    move.l a2,record_currentAddr(a1)
    move #0,record_currentsize(a1)
    rts


RECORD_MAXDIST_INCLUSIVE equ 7
;a0 is GO
RECORD_AddPos:
    lea RecordData,a1
    move.l record_currentAddr(a1),a2
    
    cmp #0,record_currentIndex(a1)
    bne .notfirst
    move go_x(a0),(a2)+
    move go_y(a0),(a2)+
    move.b go_facingVec+vec_ang(a0),(a2)+

    move go_x(a0),record_prevPosX(a1)
    move go_y(a0),record_prevPosY(a1)
    add #5,record_currentsize(a1)
    move.l a2,record_currentAddr(a1)
    addq #1,record_currentIndex(a1)
    bra .done
    
.notfirst:
    move go_x(a0),d0
    sub record_prevPosX(a1),d0
    move go_y(a0),d1
    sub record_prevPosY(a1),d1
    
    cmp #RECORD_MAXDIST_INCLUSIVE,d0
    bgt .error
    cmp #-RECORD_MAXDIST_INCLUSIVE,d0
    blt .error
    cmp #RECORD_MAXDIST_INCLUSIVE,d1
    bgt .error
    cmp #-RECORD_MAXDIST_INCLUSIVE,d1
    blt .error
    
    move.b d0,record_lastdataX(a1)
    move.b d1,record_lastdataY(a1)

    ;move.b d0,d2
    ;lsl.b #4,d2
    ;or.b d1,d2
    ;move.b d2,(a2)+
    ;add #1,record_currentsize(a1)
    ;move.l a2,record_currentAddr(a1)
    ;addq #1,record_currentIndex(a1)
        
    move.b d0,(a2)+
    move.b d1,(a2)+
    move.b go_facingVec+vec_ang(a0),(a2)+
    add #3,record_currentsize(a1)
    move.l a2,record_currentAddr(a1)
    addq #1,record_currentIndex(a1)
    
    move go_x(a0),record_prevPosX(a1)
    move go_y(a0),record_prevPosY(a1)
    bra .done
    
.done:
    move record_currentsize(a1),d0
    cmp #RECORD_DATA_MAXSIZE,d0
    blt .ok
    move #0,record_currentsize(a1)
    lea record_data(a1),a2
    move.l a2,record_currentAddr(a1)
.ok
    
    rts
.error:
    DEBUG_HALT
    rts
    

    clrso
laptime_recording so.b 1
laptime_subs so.b 1
laptime_seconds so.b 1
laptime_minutes so.b 1
laptime_structsize so.b 1


LAPTIME_Start:
    lea g_laptime,a1
    move.b #1,laptime_recording(a1)
    move.b #0,laptime_subs(a1)
    move.b #0,laptime_seconds(a1)
    move.b #0,laptime_minutes(a1)
    rts        
    
LAPTIME_Stop:
    lea g_laptime,a1
    move.b #0,laptime_recording(a1)
    rts
    
LAPTIME_Update:
    lea g_laptime,a1
    tst.b laptime_recording(a1)
    beq .r
    add.b #1,laptime_subs(a1)
    cmp.b #60,laptime_subs(a1)
    blt .r
    move.b #0,laptime_subs(a1)
    add.b #1,laptime_seconds(a1)
    cmp.b #60,laptime_seconds(a1)
    blt .r
    add.b #1,laptime_minutes(a1)
.r: rts

LAPTIME_TestBest:
    lea g_laptime,a1
    lea g_bestlaptime,a2
    
    tst.b laptime_minutes(a2)
    bne .doit
    tst.b laptime_seconds(a2)
    bne .doit
    tst.b laptime_subs(a2)
    bne .doit
    bra .bettertime

.doit:
    move.b laptime_minutes(a1),d0
    cmp.b laptime_minutes(a2),d0
    bgt .no
    blt .bettertime
    
    move.b laptime_seconds(a1),d0
    cmp.b laptime_seconds(a2),d0
    bgt .no
    blt .bettertime

    move.b laptime_subs(a1),d0
    cmp.b laptime_subs(a2),d0
    bgt .no
    
.bettertime:
    move.b laptime_minutes(a1),laptime_minutes(a2)
    move.b laptime_seconds(a1),laptime_seconds(a2)
    move.b laptime_subs(a1),laptime_subs(a2)
    moveq #1,d0
    rts
    
.no:
    moveq #0,d0
    rts
    