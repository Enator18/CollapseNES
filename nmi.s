NMI:
    PHA
    TXA
    PHA
    TYA
    PHA
    INC frame_counter
    LDA #$02           ; OAM DMA
    STA OAMDMA

    LDX #$00
vrambuffer:
    LDA VRAMBUF,X
    INX
    CMP #$FF        ; End of VRAM buffer
    BEQ vrambufferdone
    CMP #$40
    BCS @sequential
    STA PPUADDR
    INX
    LDA VRAMBUF,X
    STA PPUADDR
    INX
    LDA VRAMBUF,X
    STA PPUDATA
    INX
    JMP vrambuffer
@sequential:
    AND #$3F
    STA PPUADDR
    LDA VRAMBUF,X
    STA PPUADDR
    INX
    LDA VRAMBUF,X
    INX
    TAY
@updateloop:
    LDA VRAMBUF,X
	INX
	STA PPUDATA
	DEY
	BNE @updateloop
    JMP vrambuffer

vrambufferdone:
    LDA #$00
    STA vram_index

setscroll:
    LDA ppu_ctrl
    STA PPUCTRL
    LDA #$00
    STA PPUSCROLL
    LDA scroll
    STA PPUSCROLL
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI