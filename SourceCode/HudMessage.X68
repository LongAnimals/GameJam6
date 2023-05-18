

HUDMESSAGE_SHOW macro \1
    lea \1,a1
    jsr HudMessage_Show
    endm 

;----------------------------------------------------------------
; Hud Message Queue thingy
;----------------------------------------------------------------


    clrso
hudmessage_timer so.w 1
hudmessage_textaddr so.l 1
hudmessage_structsize so.b 0

HudMessage_Init:
    lea g_hudmessage,a5
    
    
    rts
    
    
    
; called from Hud update
HudMessage_Update:
    PUSHALL
    lea g_hudmessage,a5
    tst hudmessage_timer(a5)
    beq .r
    
    sub #1,g_hudmessage
    bne .r
    
.clear:
    move.l #VDPADDR_WINDOW+(2*64)+((0)*2),d1
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    lea HolMessage_Clear,a0
    jsr FONT_DrawText    
    
    
.r: 
    POPALL
    rts

; a1 is text addr
HudMessage_Show:
    PUSHALL
    move.l a1,a2
    lea g_hudmessage,a5
    move #120,hudmessage_timer(a5)

    VRAM_GETCHARPOS_WINDOW 0,2
    jsr	VDP_BuildAndSetVRAMWriteAddress	
    move.l a2,a0
    jsr FONT_DrawText
    POPALL
    rts    
    
HudMessage_ShowEnteringLevel:
    PUSHALL
    lea HolMessage_Entering,a1
    bsr HudMessage_Show
    
    VRAM_GETCHARPOS_WINDOW 22,2
    jsr	VDP_BuildAndSetVRAMWriteAddress
    move sysg_hol_dungeonLevel,d0
    add #1,d0
    jsr FONT_DrawNumber_W_Variable
    POPALL
    rts	
    
    

HolMessage_Clear:               dc.b '                           ',ETX
HolMessage_Entering:            dc.b 'Entered Dungeon Level      ',ETX
HolMessage_FireRune:            dc.b 'You found a Fire Rune      ',ETX
HolMessage_LightningRune:       dc.b 'You found a Lightning Rune ',ETX
HolMessage_Key:                 dc.b 'You found a Dungeon Key    ',ETX
HolMessage_Cloak:               dc.b 'Found Invisibility Cloak   ',ETX
HolMessage_LevelUp:             dc.b 'LEVEL UP                   ',ETX
HolMessage_SecretArea:          dc.b 'You found a Secret Area    ',ETX
HolMessage_Thanks:              dc.b 'THANKS                     ',ETX
HolMessage_QuestFailed:         dc.b 'QUEST FAILED               ',ETX
HolMessage_QuestDone:           dc.b 'QUEST DONE                 ',ETX
HolMessage_LockedDoor:          dc.b 'You found a locked door    ',ETX
HolMessage_PermaItem:           dc.b 'You found a class item     ',ETX
HolMessage_InitialXpLevel:      dc.b 'Initial XP level increased!',ETX
HolMessage_FireRing:            dc.b 'You found a Ring Of Fire   ',ETX
HolMessage_Medallion:           dc.b 'You found Medallion Of Time',ETX
HolMessage_Well1:               dc.b 'you need a cup of life     ',ETX
HolMessage_Well2:               dc.b 'The Well heals you         ',ETX
HolMessage_Tower:               dc.b 'Receiving XP...            ',ETX
HolMessage_Switch:              dc.b 'Click...                   ',ETX

HolMessage_XPScroll:            dc.b 'You found an XP Scroll      ',ETX
HolMessage_FullHeal:            dc.b 'You are fully healed.       ',ETX
HolMessage_RegenPotion:         dc.b 'Found a Regeneration Potion ',ETX
HolMessage_Cup:                 dc.b 'You found a Cup Of Life     ',ETX
HolMessage_WoodShield:          dc.b 'You found a Wooden Shield   ',ETX
HolMessage_MetalShield:         dc.b 'You found a Metal Shield    ',ETX
HolMessage_TitaniumShield:      dc.b 'You found a Titanium Shield ',ETX
HolMessage_Lens:                dc.b 'You found Lens of Truth     ',ETX
    align 2
    