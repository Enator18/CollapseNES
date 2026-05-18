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
    LDA #$FF
    STA $0200, x    ; Set aside space in RAM for sprite data
    INX 
    BNE clearmem

@vblankwait2:
    BIT PPUSTATUS
    BPL @vblankwait2

initvram:
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDX #$BC
    LDY #$04
:
    STA PPUDATA
    INX
    BNE :-
    DEY
    BNE :-
@drawfloor:
    LDA #$02
    LDX #$0C
    LDY #$04
    STY R0
@drawfloorloop:
    STA PPUDATA
    STY PPUDATA
    DEX
    BNE @drawfloorloop
    LDY #$08
:
    STX PPUDATA
    DEY
    BNE :-
    EOR #$07
    TAY
    EOR #$06
    LDX #$0C
    DEC R0
    BNE @drawfloorloop

@floorattr:
    LDA #$23
    STA PPUADDR
    LDX #$F1
    STX PPUADDR
    INX
    LDA #$00
:
    STA PPUDATA
    INX
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
    LDA #$01        ; init rng
    STA prng+0
    STA frame_ready

    LDA #$7C        ; init player position
    STA x_pos+1
    LDA #$C0
    STA y_pos+1
    
@initspawn:
    LDA #$18
    STA spawn_timer
@initcolumns:
    LDX #$0C
    LDA #$C0
:
    DEX
    STA columns, X
    BNE :- 