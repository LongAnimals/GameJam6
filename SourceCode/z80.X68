
;https://github.com/michaelcmartin/bumbershoot/tree/master/genesis

Z80_RAM equ $00A00000


Z80_ADDRESS_SPACE equ $00A10000
Z80_BUSREQ equ $00A11100
Z80_RESET equ $00A11200

Z80_BANK_REG equ $a06000

Z80_MEMORY_MODE equ $a11000

Z80_BASE equ 0

; when accessing the z80 mem from the 68k, first stop the z80 using busreq.

;$a11100 D8 (W) 0 busreq cancel, 1: busreq request
;			(R) 0 CPU function stop accessible. 1 Functioning

; Access to z80:
; Write $0100 to $a11100 using word access
; Check to see that D8 of $a11100 becomes 0
; Access the z80 area
; Write $0000 to $a11100 using word access

; z80 reset:
 ; $a11200 D8 0:reset request. 1:reset cancel

; $a00000 Sound ram. Access from 68k by byte

; bank register
; access to the 68000 side memory area from z80 will be based on 32k byte unit
; to set bank reg:
; write 9 times to bank reg bit 0
; 9 bits correspond to 68k address 15-23
; 1st = a23, 2nd = a22, 9th = a15

; z80 3.58mhz
; 8k sample = 3580 / 8 = 447.5 cycles


Z80_SetupProgram:
    move    #0,Z80_RESET
    move.w  #$100,Z80_BUSREQ
    move.w  #$100,Z80_RESET
    
    ;; Load Z80 player program
    lea Z80_RAM,a0
    lea     Z80_SamplePlayer_1,a1
    move.w  #(Z80_SamplePlayer_1_End-Z80_SamplePlayer_1)-1,d0
.lp: 	
    move.b  (a1)+,(a0)+
    dbra    d0,.lp

    bsr Z80_Reset
    
    move.w  #$100,Z80_RESET
    move.w  #$000,Z80_BUSREQ

    rts



Z80_68kGetBus:
    move    #0,Z80_RESET
    move.w  #$100,Z80_BUSREQ
    move.w  #$100,Z80_RESET
    ;rts
.waitbus:
    btst    #0,Z80_BUSREQ
    bne.s   .waitbus
    rts

Z80_ReleaseBus:
    move #$100,Z80_RESET
    move.w  #$0,Z80_BUSREQ
    rts 
    
Z80_FastPause:
    move #$100,Z80_BUSREQ
    rts
    
Z80_Pause:
    move.w  #$100,Z80_BUSREQ
    rts
    move #100,d0
.wait:
    nop
    dbra d0,.wait
    ;btst    #0,Z80_BUSREQ
    ;bne.s   .wait
    rts


Z80_Resume:
    move #$00,Z80_BUSREQ
    rts

    
Z80_Reset:
    move #0,Z80_RESET
    move #20,d0
.l: dbra d0,.l
    rts


Z80_RAM_BusyFlag equ (Z80_RAM+13) ;byte
Z80_RAM_OverwriteFlag equ (Z80_RAM+14) ;byte
Z80_RAM_SampleAddr equ (Z80_RAM+8)

;ds.b $40000-$3c27c
; a0 = address
; d0 = length
PlaySampleIfFree:

    PUSHALL
    jsr Z80_Pause
    POPALL
    
    ;tst.b Z80_RAM_BusyFlag
    ;bne .dont_play
    
    move.b #1,Z80_RAM_BusyFlag

    lea Z80_RAM_SampleAddr,a2

; copy in length
    move.b  d0,(a2)+
    lsr.l   #8,d0
    move.b  d0,(a2)+

;copy in address of sample
    move.l a0,d0	; addr
    move.b  d0,(a2)+                ; low byte
    lsr.w   #8,d0           
    move.b  d0,(a2)+                ; mid byte
    swap d0
    move.b  d0,(a2)                 ; upper byte
   
.dont_play
    bsr Z80_Resume
    
    rts

PlaySampleIfFree_AlreadyHasBus:

    ;tst.b Z80_RAM_BusyFlag
    ;bne .dont_play
    
    move.b #1,Z80_RAM_BusyFlag

    lea Z80_RAM_SampleAddr,a2

; copy in length
    move.b  d0,(a2)+
    lsr.l   #8,d0
    move.b  d0,(a2)+

;copy in address of sample
    move.l a0,d0	; addr
    move.b  d0,(a2)+                ; low byte
    lsr.w   #8,d0           
    move.b  d0,(a2)+                ; mid byte
    swap d0
    move.b  d0,(a2)                 ; upper byte
   
.dont_play:
    
    rts


PlaySample_Overwrite:

    PUSHALL
    bsr Z80_Pause
    POPALL
    move.b #1,Z80_RAM_OverwriteFlag
    
    lea Z80_RAM_SampleAddr,a2
     move.b  #0,(a2)+
     move.b  #0,(a2)+
        
     bsr Z80_Resume
     
    rept 10
    nop
    endr
    
    bsr Z80_Pause
    move.b #0,Z80_RAM_OverwriteFlag
     move.b #1,Z80_RAM_BusyFlag

    lea Z80_RAM_SampleAddr,a2

; copy in length
    move.b  d0,(a2)+
    lsr.l   #8,d0
    move.b  d0,(a2)+

;copy in address of sample
    move.l a0,d0	; addr
    move.b  d0,(a2)+                ; low byte
    lsr.w   #8,d0           
    move.b  d0,(a2)+                ; mid byte
    swap d0
    move.b  d0,(a2)                 ; upper byte
   
.dont_play
    bsr Z80_Resume
    
    rts


PlaySample_Overwrite_AlreadyHasBus:

    move.b #1,Z80_RAM_OverwriteFlag
    
    lea Z80_RAM_SampleAddr,a2
     move.b  #0,(a2)+
     move.b  #0,(a2)+
        
    rept 30
    nop
    endr
    
    move.b #0,Z80_RAM_OverwriteFlag
     move.b #1,Z80_RAM_BusyFlag

    lea Z80_RAM_SampleAddr,a2

; copy in length
    move.b  d0,(a2)+
    lsr.l   #8,d0
    move.b  d0,(a2)+

;copy in address of sample
    move.l a0,d0	; addr
    move.b  d0,(a2)+                ; low byte
    lsr.w   #8,d0           
    move.b  d0,(a2)+                ; mid byte
    swap d0
    move.b  d0,(a2)                 ; upper byte
   
.dont_play
    
    rts


Z80_SamplePlayer_1:
    incbin "z80/z80dac.bin"
Z80_SamplePlayer_1_End:

        align   2
