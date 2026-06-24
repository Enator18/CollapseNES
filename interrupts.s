NMI:
    PHA
    INC frame_counter
    TXA
    PHA
    TYA
    PHA

    LDA #$01           ; read controller
    STA JOY1
    STA controller     ; initialize the controller variable to $01 so that once the 8 button values are shifted in, 1 will be placed into the carry
    LSR A
    STA JOY1
:
    LDA JOY1
    LSR A              ; move the button value from bit 0 of A to the carry flag
    ROL controller     ; move the button value from the carry flag to bit 0 of the controller variable, shifting the other buttons as a result
    BCC :-             ; the carry flag will be 1 if the controller variable has been shifted left 8 times, indicating that all 8 buttons have been read 

    LDA #%00011110
    STA PPUMASK

    LDA #$88    ; start DMC timer sample
    STA $4010
    LDA #$01
    STA $4012
    STA $4013
    LDA #$10
    STA $4015

    LDA frame_ready
    BEQ lagframe

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
    STA frame_ready

setscroll:
    LDA ppu_ctrl
    STA PPUCTRL
    LDA #$00
    STA PPUSCROLL
    LDA scroll
    STA PPUSCROLL

lagframe:
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI


IRQ:
    PHA
    TXA
    PHA
    TYA
    PHA
    LDA #$0F
    STA $4010
    LDA #$00
    STA $4015

    LDA #%00000100
    LDX #$00
    LDY #%00001110
zerohitwait:
    BIT PPUSTATUS
    BVC zerohitwait
    STA PPUADDR
    STX PPUADDR
    STY PPUMASK

    LDX #$54
:
    DEX
    BNE :-

    LDA #$04
    STA PPUADDR
    LDA frame_counter
    AND #$78
    LSR
    LSR
    LSR
    ADC #$08
    STA PPUSCROLL

    AND #$F8
    ASL
    ASL
    STX PPUSCROLL ; X is 0 because of the loop above
    STA PPUADDR

    PLA
    TAY
    PLA
    TAX
    PLA
    RTI