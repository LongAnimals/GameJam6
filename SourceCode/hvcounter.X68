HVCOUNTER equ $c00008

    
    ifd USE_HVCOUNTER_TIMINGS
    
HVTIMER_START0 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(0*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END0 macro
    move.l a0,-(sp)
    lea HVCounterRam+(0*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START1 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(1*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END1 macro
    move.l a0,-(sp)
    lea HVCounterRam+(1*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START2 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(2*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END2 macro
    move.l a0,-(sp)
    lea HVCounterRam+(2*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START3 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(3*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END3 macro
    move.l a0,-(sp)
    lea HVCounterRam+(3*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START4 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(4*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END4 macro
    move.l a0,-(sp)
    lea HVCounterRam+(4*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START5 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(5*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END5 macro
    move.l a0,-(sp)
    lea HVCounterRam+(5*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START6 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(6*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END6 macro
    move.l a0,-(sp)
    lea HVCounterRam+(6*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm

HVTIMER_START7 macro \1
    movem.l a0/d0,-(sp)
    lea HVCounterRam+(7*hvc_structsize),a0
    move.l #\1,d0
    jsr HVCounter_Start
    movem.l (sp)+,a0/d0
    endm
    
HVTIMER_END7 macro
    move.l a0,-(sp)
    lea HVCounterRam+(7*hvc_structsize),a0
    jsr HVCounter_End
    move.l (sp)+,a0
    endm
    
    else
    
HVTIMER_START0 macro \1
    endm
HVTIMER_END0 macro
    endm
HVTIMER_START1 macro \1
    endm
HVTIMER_END1 macro
    endm
HVTIMER_START2 macro \1
    endm
HVTIMER_END2 macro
    endm
HVTIMER_START3 macro \1
    endm
HVTIMER_END3 macro
    endm
HVTIMER_START4 macro \1
    endm
HVTIMER_END4 macro
    endm
HVTIMER_START5 macro \1
    endm
HVTIMER_END5 macro
    endm
HVTIMER_START6 macro \1
    endm
HVTIMER_END6 macro
    endm
HVTIMER_START7 macro \1
    endm
HVTIMER_END7 macro
    endm
    
    endif

; d0.l
HVCounter_Start:
    move HVCOUNTER,hvc_starttime(a0)
    move.l d0,hvc_name(a0)
    rts

HVCounter_End:
    move.l d0,-(sp)
    move HVCOUNTER,d0
    sub hvc_starttime(a0),d0
    move d0,hvc_timetaken(a0)
    move hvc_timetaken(a0),d0
    cmp hvc_worsttime(a0),d0
    ble .no
    move d0,hvc_worsttime(a0)
.no:
    
    move.l (sp)+,d0
    rts
        
HVCounter_CopyToDebug:
    ifd USE_HVCOUNTER_TIMINGS
    move #HVCOUNTER_MAX_TIMERS-1,d7
    lea HVCounterRam,a0
    lea DebugArea,a1
.lp:
    move.l hvc_name(a0),(a1)+
    move hvc_timetaken(a0),d0
    lsr #8,d0
    move d0,(a1)+
    move hvc_worsttime(a0),d0
    lsr #8,d0
    move d0,(a1)+
    lea hvc_structsize(a0),a0
    dbra d7,.lp
    endif
    rts


    clrso
ghvc_currentTimer   so.w 1
ghvc_structsize   so.w 1

    clrso
hvc_name        so.l 1
hvc_starttime   so.w 1 
hvc_timetaken   so.w 1 
hvc_worsttime   so.w 1 
hvc_structsize  so.w 1 

HVCOUNTER_MAX_TIMERS equ 8    
HVCOUNTER_RAM_SIZE equ (hvc_structsize*HVCOUNTER_MAX_TIMERS)