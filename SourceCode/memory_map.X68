

SOUND_MAX_FM_TRACKS equ 6
SOUND_MAX_FMMOD_TRACKS equ 7
SOUND_MAX_SAMPLE_TRACKS equ 1

MUSICPLAYER_SIZE equ (track_structsize*SOUND_MAX_FM_TRACKS)
MUSICPLAYER_FMMOD_SIZE equ (fmmodtrack_structsize*SOUND_MAX_FMMOD_TRACKS)
MUSICPLAYER_SAMPLETRACK_SIZE equ (sampletrack_structsize*SOUND_MAX_SAMPLE_TRACKS)

MAX_PSGSFX equ 3
DEBUG_AREA_SIZE equ $100
REALTIME_COMMANDS_SIZE equ $100
HBLANK_CODE_SIZE equ 64
HBLANK_DATA_SIZE equ 8

MAX_PARTICLES equ 1
MAX_FXPARTICLES equ 1
MAX_GAMEOBJECTS equ 1
VDP_SPRITE_LIST_SIZE equ 96 * 8       ; allowing space for more than 64 - write over

RAM_PALETTES_SIZE equ 16*4*2

SPRITE_VDP_OFFSETS_SIZE equ (SPRITE_TOTAL*2)

    ifd TEST_SOUND      ; 
SCRATCHPAD_SIZE equ 512
UNCOMPRESS_AREA_SIZE equ 512    ;1024*2
    endif

    ifd IS_GAME_CUBEDROID
SCRATCHPAD_SIZE equ 512
UNCOMPRESS_AREA_SIZE equ 512    ;1024*2
    endif

    ifd IS_GAME_COFFEE
SCRATCHPAD_SIZE equ 2048
UNCOMPRESS_AREA_SIZE equ 512    ;1024*2
    endif

    ifd IS_GAME_UNDERGROUND
SCRATCHPAD_SIZE equ 2048+1024
UNCOMPRESS_AREA_SIZE equ 1024*2
    
    endif

    ifd IS_GAME_TD
SCRATCHPAD_SIZE equ 2048+1024
UNCOMPRESS_AREA_SIZE equ 1024*2
    
    endif

;SCRATCHPAD_SIZE equ 2048+1024
;UNCOMPRESS_AREA_SIZE equ 1024*2


HSCROLLDMA_TABLE_SIZE equ (224*4)



PSGSFXPLAYER_SIZE equ (psgsfx_structsize * MAX_PSGSFX)

HBLANK_PALETTE_COPY_SIZE equ 4      ;224 * 2 not used, but keep it referenced so we can compile

SCROLL_EDGE_BUFFER_SIZE = (64*2)*2


;-------------------------------------------------------------------------------
; memory map
;-------------------------------------------------------------------------------


MEM_START equ $FF0000

; STATIC ram addresses here:

; scratch area easily visible in Gens
    setso $ff0000
DebugArea           so.b DEBUG_AREA_SIZE        ; careful if you change this. need to change Globals 'so' as well.
RealtimeCommands    so.b REALTIME_COMMANDS_SIZE 

    ifd USE_HVCOUNTER_TIMINGS
HVCounterRam      so.b HVCOUNTER_RAM_SIZE
    endif
HBlankRamAddr       so.b HBLANK_CODE_SIZE

HBlankPaletteCopy   so.b HBLANK_PALETTE_COPY_SIZE
RamPalettes         so.b RAM_PALETTES_SIZE
RamPalettesDMA      so.b RAM_PALETTES_SIZE
VDPSpriteList       so.b VDP_SPRITE_LIST_SIZE
SpriteVDPOffsets    so.b SPRITE_VDP_OFFSETS_SIZE
SprFrameCache       so.b 128*8   ;)1024       ;CACHEDFRAMES_TOTAL
Scratchpad          so.b SCRATCHPAD_SIZE
ScrollRowEdgeBufferA    so.b SCROLL_EDGE_BUFFER_SIZE
ScrollColumnEdgeBufferA    so.b SCROLL_EDGE_BUFFER_SIZE
ScrollRowEdgeBufferB    so.b SCROLL_EDGE_BUFFER_SIZE
ScrollColumnEdgeBufferB    so.b SCROLL_EDGE_BUFFER_SIZE

ScrollDMATableA_Rows so.b 32*16
ScrollDMATableA_Columns so.b 64*16
ScrollDMATableB_Rows so.b 32*16
ScrollDMATableB_Columns so.b 64*16

    ifd IS_GAME_RACER
RecordData          so.b record_structsize
PlaybackData        so.b record_structsize
    else
RecordData          so.b 0
PlaybackData        so.b 0    
    endif
UncompressArea      so.b UNCOMPRESS_AREA_SIZE
STATIC_MEM_END      so.b 0

MEM_RAM_HEAP equ STATIC_MEM_END

    rsset $ff0000


