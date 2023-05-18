
;-------------------------------------------------------------
;	COMPOUND SPRITES
;-------------------------------------------------------------

COMPOUNDSPRITE_COFFEE_POT0 equ 0
COMPOUNDSPRITE_COFFEE_PRESS equ 1
COMPOUNDSPRITE_COFFEE_BIGPOT equ 2
COMPOUNDSPRITE_COFFEE_PRESSYFLIP equ 3

;-------------------------------------------------------------

COMPOUNDSPRITEFRAME_COFFEE_POT0_0 equ 0
COMPOUNDSPRITEFRAME_COFFEE_POT0_1 equ 1
COMPOUNDSPRITEFRAME_COFFEE_POT0_2 equ 2
COMPOUNDSPRITEFRAME_COFFEE_POT0_3 equ 3
COMPOUNDSPRITEFRAME_COFFEE_POT0_4 equ 4
COMPOUNDSPRITEFRAME_COFFEE_POT0_5 equ 5
COMPOUNDSPRITEFRAME_COFFEE_POT0_6 equ 6
COMPOUNDSPRITEFRAME_COFFEE_POT0_7 equ 7
COMPOUNDSPRITEFRAME_COFFEE_POT0_8 equ 8
COMPOUNDSPRITEFRAME_COFFEE_PRESS_0 equ 0
COMPOUNDSPRITEFRAME_COFFEE_PRESS_1 equ 1
COMPOUNDSPRITEFRAME_COFFEE_PRESS_2 equ 2
COMPOUNDSPRITEFRAME_COFFEE_PRESS_3 equ 3
COMPOUNDSPRITEFRAME_COFFEE_PRESS_4 equ 4
COMPOUNDSPRITEFRAME_COFFEE_PRESS_5 equ 5
COMPOUNDSPRITEFRAME_COFFEE_PRESS_6 equ 6
COMPOUNDSPRITEFRAME_COFFEE_PRESS_7 equ 7
COMPOUNDSPRITEFRAME_COFFEE_PRESS_8 equ 8
COMPOUNDSPRITEFRAME_COFFEE_PRESS_9 equ 9
COMPOUNDSPRITEFRAME_COFFEE_PRESS_10 equ 10
COMPOUNDSPRITEFRAME_COFFEE_PRESS_11 equ 11
COMPOUNDSPRITEFRAME_COFFEE_PRESS_12 equ 12
COMPOUNDSPRITEFRAME_COFFEE_PRESS_13 equ 13
COMPOUNDSPRITEFRAME_COFFEE_PRESS_14 equ 14
COMPOUNDSPRITEFRAME_COFFEE_PRESS_15 equ 15
COMPOUNDSPRITEFRAME_COFFEE_PRESS_16 equ 16
COMPOUNDSPRITEFRAME_COFFEE_PRESS_17 equ 17
COMPOUNDSPRITEFRAME_COFFEE_PRESS_18 equ 18
COMPOUNDSPRITEFRAME_COFFEE_PRESS_19 equ 19
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_0 equ 0
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_A equ 1
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_2 equ 2
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_3 equ 3
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_4 equ 4
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_B equ 5
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_6 equ 6
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_7 equ 7
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_8 equ 8
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_C equ 9
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_10 equ 10
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_11 equ 11
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_12 equ 12
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_D equ 13
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_14 equ 14
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_15 equ 15
COMPOUNDSPRITEFRAME_COFFEE_BIGPOT_16 equ 16
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_0 equ 0
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_1 equ 1
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_2 equ 2
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_3 equ 3
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_4 equ 4
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_5 equ 5
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_6 equ 6
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_7 equ 7
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_8 equ 8
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_9 equ 9
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_10 equ 10
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_11 equ 11
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_12 equ 12
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_13 equ 13
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_14 equ 14
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_15 equ 15
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_16 equ 16
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_17 equ 17
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_18 equ 18
COMPOUNDSPRITEFRAME_COFFEE_PRESSYFLIP_19 equ 19

;-------------------------------------------------------------

compoundsprites:	;FROM SNAKE ENGINE
	dc.w 4	;Num Sprites
	dc.l COMPSPR_Coffee_Pot0
	dc.l COMPSPR_Coffee_Press
	dc.l COMPSPR_Coffee_BigPot
	dc.l COMPSPR_Coffee_PressYflip

;-------------------------------------------------------------

COMPSPR_Coffee_Pot0:
	dc.w 9	;Num Frames
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_1
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_2
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_3
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_4
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_5
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_6
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_7
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Pot0_8
	dc.l 0
	dc.l 0
	dc.l 0

COMPSPRFRAME_NOFLIP_Coffee_Pot0_0:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-40	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_1:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_2:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-38	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_3:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-37	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_4:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-36	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_5:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-35	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_6:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-34	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_7:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-33	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Pot0_8:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_BOTTOM	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POT0_TOP	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -13,-32	;Offset

COMPSPR_Coffee_Press:
	dc.w 20	;Num Frames
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_1
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_2
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_3
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_4
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_5
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_6
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_7
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_8
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_9
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_10
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_11
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_12
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_13
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_14
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_15
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_16
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_17
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_18
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_Press_19
	dc.l 0
	dc.l 0
	dc.l 0

COMPSPRFRAME_NOFLIP_Coffee_Press_0:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-33	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_1:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-34	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_2:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-35	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_3:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-36	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_4:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-37	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_5:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-38	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_6:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_7:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-40	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_8:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-41	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_9:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-42	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_10:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-43	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_11:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-44	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_12:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-45	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_13:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-46	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_14:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-47	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_15:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-48	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_16:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-49	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_17:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-50	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_18:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-51	;Offset

COMPSPRFRAME_NOFLIP_Coffee_Press_19:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,-31	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,-52	;Offset

COMPSPR_Coffee_BigPot:
	dc.w 17	;Num Frames
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_1
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_2
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_3
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_4
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_5
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_6
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_7
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_8
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_9
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_10
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_11
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_12
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_13
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_14
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_15
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_BigPot_16
	dc.l 0
	dc.l 0
	dc.l 0

COMPSPRFRAME_NOFLIP_Coffee_BigPot_0:	;Frame Label: 
	dc.w 4	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_1:	;Frame Label: a
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,12	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_2:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE1	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,11	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_3:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE2	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,10	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_4:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE3	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -12,9	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_5:	;Frame Label: b
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 5,10	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_6:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE1	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 5,9	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_7:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE2	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 5,8	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_8:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE3	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 5,7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_9:	;Frame Label: c
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,10	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_10:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE1	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,9	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_11:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE2	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,8	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_12:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE3	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -8,7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_13:	;Frame Label: d
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 1,17	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_14:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE1	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 1,16	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_15:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE2	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 1,15	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPRFRAME_NOFLIP_Coffee_BigPot_16:	;Frame Label: 
	dc.w 5	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_POTBUBBLE3	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 1,14	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_12	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_11	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-7	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_10	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w 9,-39	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_BIGPOT0	;HWSprite In Spr
	dc.w 0	;Flips
	dc.w -23,-39	;Offset

COMPSPR_Coffee_PressYflip:
	dc.w 20	;Num Frames
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_1
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_2
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_3
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_4
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_5
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_6
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_7
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_8
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_9
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_10
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_11
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_12
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_13
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_14
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_15
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_16
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_17
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_18
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l COMPSPRFRAME_NOFLIP_Coffee_PressYflip_19
	dc.l 0
	dc.l 0
	dc.l 0

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_0:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,2	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_1:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,3	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_2:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,4	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_3:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,5	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_4:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,6	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_5:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,7	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_6:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,8	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_7:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,9	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_8:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,10	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_9:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,11	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_10:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,12	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_11:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,13	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_12:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,14	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_13:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,15	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_14:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,16	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_15:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,17	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_16:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,18	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_17:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,19	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_18:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,20	;Offset

COMPSPRFRAME_NOFLIP_Coffee_PressYflip_19:	;Frame Label: 
	dc.w 2	;Num HW Sprites
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSA	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -12,0	;Offset
	dc.w SPRITE_COFFEE_PAL0
	dc.w SPRFRAME_COFFEE_PAL0_PRESSB	;HWSprite In Spr
	dc.w FLIP_V	;Flips
	dc.w -8,21	;Offset

