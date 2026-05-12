.proc bg_collision  ; collides the player with the background tiles
left       := x_pos+1
leftshift  := R0
right      := R1
rightshift := R2
top        := y_pos+1
bottom     := R3
    LDA #$00
    STA x_eject
    STA y_eject
    STA collision
    STA on_ground
    LDA left
    CLC
    ADC #PLAYERWIDTH-1
    STA right       ; right edge
    LDA top
    CLC
    ADC #PLAYERHEIGHT-1
    STA bottom      ; bottom edge

@topleft:
    LDA left        ; top left corner
    LSR A
    LSR A
    LSR A
    LSR A
    STA leftshift   ; The lower 4 bits store the x position of the tile in the tile map
    LDA top
    AND #$f0        ; The upper 4 bits store the y position of the tile in the tile map
    CLC
    ADC leftshift
    TAX             ; X is now the index of the tile contianing the player's top-left corner
    LDA colmap,X
    BEQ :+          ; if the tile has collision, collide
    INC collision
    LDA left
    AND #$0f
    SEC
    SBC #$10
    STA x_eject
    LDA top
    AND #$0f
    SEC
    SBC #$10
    STA y_eject
:

@top_right:
    LDA right       ; top right corner
    LSR A
    LSR A
    LSR A
    LSR A
    STA rightshift
    LDA top
    AND #$f0
    CLC
    ADC rightshift
    TAX
    LDA colmap,X
    BEQ :+
    INC collision
    LDA right
    AND #$0f
    CLC
    ADC #$01
    STA x_eject
    LDA top
    AND #$0f
    SEC
    SBC #$10
    STA y_eject
:

@bot_left:
    LDA bottom      ; bottom left corner
    AND #$f0
    CLC
    ADC leftshift
    TAX
    LDA colmap,X
    BEQ :+
    INC collision
    INC on_ground
    LDA left
    AND #$0f
    SEC
    SBC #$10
    STA x_eject
    LDA bottom
    AND #$0f
    CLC
    ADC #$01
    STA y_eject
:

@bot_right:
    LDA bottom      ; bottom right corner
    AND #$f0
    CLC
    ADC rightshift
    TAX
    LDA colmap,X
    BEQ :+
    INC collision
    INC on_ground
    LDA right
    AND #$0f
    CLC
    ADC #$01
    STA x_eject
    LDA bottom
    AND #$0f
    CLC
    ADC #$01
    STA y_eject
:
    RTS
.endproc

update_prng:
    LDA prng+1
    LSR A
    LDA prng+0
    ROR A
    EOR prng+1
    STA prng+1
    ROR A
    EOR prng+0
    STA prng+0
    EOR prng+1
    STA prng+1
    RTS


placeblock:
    AND #$F0           ; set collision
    ORA R0
    TAY
    LDA #$01
    STA colmap, Y
    LDY R0             ; increase column height
    LDA columns-2, Y
    STA R1
    SBC #$10
    STA columns-2, Y
    LDA #$00
    STA block_col, X

    LDA R1             ; add vram updates
    ASL
    ROL
    ROL
    ORA #$60
    LDY vram_index
    STA VRAMBUF+0, Y     ; address MSB
    STA VRAMBUF+5, Y

    LDA R1
    ASL
    ORA R0
    ASL
    STA VRAMBUF+1, Y   ; top address LSB
    ORA #$20
    STA VRAMBUF+6, Y   ; bottom address LSB

    LDA #$02
    STA VRAMBUF+2, Y   ; run length
    STA VRAMBUF+7, Y

    STA VRAMBUF+3, Y   ; top left corner tile
    LDA #$03
    STA VRAMBUF+8, Y   ; bottom left corner tile

    LDA #$04
    STA VRAMBUF+4, Y   ; top right corner tile
    LDA #$05
    STA VRAMBUF+9, Y   ; bottom right corner tile
    
    LDA #$FF
    STA VRAMBUF+10, Y  ; vram buffer terminator
    
    TYA
    CLC
    ADC #$0A
    STA vram_index
    JMP blockloopend
    