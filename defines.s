; Constants
VRAMBUF   = $0100   ; The location in memory of the VRAM write buffer in CPU memory that stores changes to VRAM that are made each frame
OAMBUF    = $0200   ; The location in memory of the sprite buffer in CPU memory that gets copied into OAM every frame

; Registers
PPUCTRL   = $2000   ; VPHB SINN -> NMI enable (V), PPU master/slave (P), sprite height (H), background tile select (B), sprite tile select (S), increment mode (I), nametable select (NN)
PPUMASK   = $2001   ; BGRs bMmG -> color emphasis (BGR), sprite enable (s), background enable (b), sprite left column enable (M), background left column enable (m), greyscale (G)
PPUSTATUS = $2002   ; VSO- ---- -> vblank (V), sprite 0 hit (S), sprite overflow (O); read resets write pair for $2005/$2006
OAMADDR   = $2003   ; aaaa aaaa -> OAM read/write address
OAMDATA   = $2004   ; dddd dddd -> OAM data read/write
PPUSCROLL = $2005   ; xxxx xxxx -> fine scroll position (two writes: X scroll, Y scroll)
PPUADDR   = $2006   ; aaaa aaaa -> PPU read/write address (two writes: most significant byte, least significant byte)
PPUDATA   = $2007   ; dddd dddd -> PPU data read/write

OAMDMA    = $4014   ; aaaa aaaa -> OAM DMA high address
SNDCHN    = $4015   ; ---D NT21 -> Control: DMC enable, length counter enables: noise, triangle, pulse 2, pulse 1 (write)
                    ; IF-D NT21 -> Status: DMC interrupt, frame interrupt, length counter status: noise, triangle, pulse 2, pulse 1 (read)
JOY1      = $4016   ; Controller 1 Read
JOY2      = $4017   ; Controller 2 Read
                    ; SD-- ---- -> Frame counter: 5-frame sequence, disable frame interrupt (write)

ATTR_0 = %00000000
ATTR_1 = %01010101
ATTR_2 = %10101010
ATTR_3 = %11111111

BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

PLAYERWIDTH  = $08
PLAYERHEIGHT = $10

JUMPVELOCITY = $06  ; the y velocity applied when the player jumps in pixels
MOVEACCEL    = $40  ; the acceleration applied by movement each frame in subpixels
MOVEDRAG     = $40  ; the deceleration applied by drag each frame in subpixels
LOWGRAV      = $40  ; the acceleration applied by gravity each frame while holding jump in subpixels
HIGHGRAV     = $C0  ; the acceleration applied by gravity each frame in subpixels
FALLSPEED    = $05  ; the terminal velocity when falling in pixels
MOVESPEED    = $02  ; the max horizontal move speed in pixels
BLOCKSPEED   = $04  ; the speed that blocks fall in pixels
