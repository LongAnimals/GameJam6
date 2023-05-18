;-------------------------------------------------------------
;	Exported from Unity Tool
;-------------------------------------------------------------
;-------------------------------------------------------------

SAMPLE_GUNSLUGS_MUSIC1 equ 0

;-------------------------------------------------------------
SAMPLES_GUNSLUGS:
	dc.l SAMPLEDATA_GUNSLUGS_Music1,SAMPLEDATA_GUNSLUGS_Music1_Reverse,SAMPLEDATA_GUNSLUGS_Music1,SAMPLEDATA_GUNSLUGS_Music1_Reverse
	dcb.b $18*$10,$00
SAMPLEDATA_GUNSLUGS_MUTE: dcb.b $8000-(($18*$10)*2),$80
SAMPLEDATA_GUNSLUGS_MUTE_Reverse: dcb.b $18*$10,$00

;-------------------------------------------------------------
SAMPLEDATA_GUNSLUGS_Music1:
;	Sample Rate: 7000
;	Num Samples: 707368
	incbin "ExportedSource/SAMPLE_GUNSLUGS_Music1.bin"
SAMPLEDATA_GUNSLUGS_Music1_Reverse:

;-------------------------------------------------------------

	dcb.b $18*$10,$00
	align 2