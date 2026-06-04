writevram:          ; adds a write to the vram buffer (A: VRAM address MSB, Y: VRAM address LSB, R0: value)
    LDX vram_index
    STA VRAMBUF,X
    INX
    TYA
    STA VRAMBUF,X
    INX
    LDA R0
    STA VRAMBUF,X
    INX
    STX vram_index
    LDA #$FF
    STA VRAMBUF,X
    RTS


oamsprite:          ; adds a sprite to OAM (R0: Tile Index, R1: Attribute Byte, R2: X Position, A: Y Position)
    CLC             ; CLC instead of SEC to account for sprite 1-pixel offset
    SBC scroll
    BCS :+
    SBC #$0F        ; correct for wrap around
:
    LDY oam_index
    STA OAMBUF,Y
    INY
    LDA R0
    STA OAMBUF,Y
    INY
    LDA R1
    STA OAMBUF,Y
    INY
    LDA R2
    STA OAMBUF,Y
    INY
    STY oam_index
    RTS


oamclear:           ; clears OAM
    LDX #$00
    LDA #$FF        ; this Y coordinate puts the sprite off screen
:
    STA OAMBUF,X
    INX
    INX
    INX
    INX
    BNE :-
    STX oam_index
    RTS