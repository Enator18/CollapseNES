RESET:
    SEI             ; disable IRQs
    CLD             ; disable decimal mode
    LDX #$40
    STX JOY2        ; disable APU frame counter IRQ - disable sound
    LDX #$ff
    TXS             ; setup stack starting at FF as it decrements instead if increments
    INX             ; overflow X reg to $00
    STX PPUCTRL     ; disable NMI - PPUCTRL reg
    STX PPUMASK     ; disable rendering - PPUMASK reg
    STX $4010       ; disable DMC IRQs

    BIT PPUSTATUS

@vblankwait1:  
    BIT PPUSTATUS
    BPL @vblankwait1

    LDX #$00

clearmem:
    LDA #$00        ; can also do TXA as x is $#00
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$fe
    STA $0200, x    ; Set aside space in RAM for sprite data
    INX 
    BNE clearmem

@vblankwait2:
    BIT PPUSTATUS
    BPL @vblankwait2

clearvram:
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDX #$00
    LDY #$00
:
    STA PPUDATA
    INX
    BNE :-
    INY
    CPY #$08
    BNE :-

loadpalette:
    LDA PPUSTATUS   ; read PPU status to reset PPU address
    LDA #$3F        ; Set PPU address to BG palette RAM ($3F00)
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    LDX #$00
:
    LDA palette,X
    STA PPUDATA
    INX
    CPX #$20
    BNE :-

initppu:
    LDA #$02            ; OAM DMA
    STA OAMDMA
    NOP

    LDA #$FF      ; init VRAM buffer
    STA VRAMBUF

    CLI                 ; clear interrups so NMI can be called
    LDA #%10100000
    STA ppu_ctrl
    STA PPUCTRL         ; the left most bit of $2000 sets wheteher NMI is enabled or not

    LDA #%00011110      ; enable background and sprites
    STA PPUMASK

initgame:
    LDA #$7C        ; init player position
    STA x_pos+1
    LDA #$D0
    STA y_pos+1

	LDX #$E0		; start row loop
	LDA #$01		; set accumluator to 1
@floorloop:
	STA colmap, X
	INX
	CPX #$F0
	BNE @floorloop
