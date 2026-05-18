.proc move_and_collide
    LDA #$00
    STA on_ground
    CLC                ; apply X velocity
    LDA x_pos+0
    ADC x_vel+0
    STA x_pos+0
    LDA x_pos+1
    ADC x_vel+1
    STA x_pos+1
    
    CMP #$20
    BCC @xhit
    CMP #$D9
    BCS @xhit

    TAY
    LDX x_vel+1
    BMI :+
    CLC
    ADC #$07
:
    LSR A
    LSR A
    LSR A
    LSR A
    TAX
    LDA columns-2, X
    CMP y_pos+1
    BCS @noxhit
    TYA
@xhit:
    AND #$F8
    LDY #$C0
    LDX x_vel+1
    BPL :+
    LDY #$00
    AND #$F0
    CLC
    ADC #$10
:
    STY x_pos+0
    STA x_pos+1
    LDA #$00
    STA x_vel+0
    STA x_vel+1
@noxhit:
    CLC                ; apply Y velocity
    LDA y_pos+0
    ADC y_vel+0
    STA y_pos+0
    LDA y_pos+1
    ADC y_vel+1
    STA y_pos+1

    LDA x_pos+1
    LSR A
    LSR A
    LSR A
    LSR A
    TAX
    LDA columns-2, X
    CMP y_pos+1
    BCC @yhit
    LDA x_pos+1
    AND #$0F
    CMP #$09
    BCC @noyhit
    INX
    LDA columns-2, X
    CMP y_pos+1
    BCS @noyhit
@yhit:
    STA y_pos+1
    LDA #$C0
    STA y_pos+0
    LDA #$00
    STA y_vel+0
    STA y_vel+1
    LDA #$01
    STA on_ground
@noyhit:
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
    LDA columns-2, Y   ; increase column height
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
    STY R0
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

    LDA #$23            ; add palette updates
    STA VRAMBUF+10, Y   ; address MSB

    STX R2
    LDX #%11001100
    LDA R0
    AND #$01
    BEQ :+
    LDX #%00110011
:
    STX R3

    LDX #%11110000
    LDA R1
    AND #$10
    BEQ :+
    LDX #%00001111
:
    TXA
    ORA R3
    STA R3

    LDA R1
    LSR
    AND #$F0
    ORA R0
    LSR
    TAX
    ORA #$C0
    STA VRAMBUF+11, Y  ; address LSB

    LDA attr_buf, X
    AND R3
    STA attr_buf, X
    LDX R2
    STA VRAMBUF+12, Y  ; value
    
    LDA #$FF
    STA VRAMBUF+13, Y  ; vram buffer terminator
    
    TYA
    CLC
    ADC #$0D
    STA vram_index
    JMP blockloopend
    