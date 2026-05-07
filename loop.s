mainloop:              ; the main game tick loop
    JSR nmiwait        ; wait until next frame

    LDA #$01           ; read controller
    STA JOY1
    STA controller     ; initialize the controller variable to $01 so that once the 8 button values are shifted in, 1 will be placed into the carry
    LSR a
    STA JOY1
:
    LDA JOY1
    LSR a              ; move the button value from bit 0 of A to the carry flag
    ROL controller     ; move the button value from the carry flag to bit 0 of the controller variable, shifting the other buttons as a result
    BCC :-             ; the carry flag will be 1 if the controller variable has been shifted left 8 times, indicating that all 8 buttons have been read

updatespawn:
    DEC spawn_timer
    BNE @nospawn
@getcol:
    LDA #$18
    STA spawn_timer
    LDA prng+1
    LSR A
    TAX
    LDA prng+0
    ROR A
    CLC
    ADC prng+0
    TXA
    ADC prng+1
    ROR A
    LSR A
    LSR A
    LSR A
    LSR A

@nospawn:
    LDA controller     ; right button
    AND #BUTTON_RIGHT
    BEQ @noright
    LDA #$00
    STA player_dir
    CLC                ; increase the X velocity by an acceleration amount of 0.25
    LDA x_vel+0
    ADC #MOVEACCEL
    STA x_vel+0
    LDA x_vel+1
    ADC #$00
    STA x_vel+1
    BMI :+             ; if velocity is negative, no clamp needed
    CMP #MOVESPEED     ; if the MSB of velocity is less than movespeed, no clamp needed
    BCC gravity
    LDA #$00
    STA x_vel+0
    LDA #MOVESPEED
    STA x_vel+1
:
    JMP gravity
@noright:
    LDA controller     ; left button
    AND #BUTTON_LEFT
    BEQ @nodir
    LDA #$40
    STA player_dir
    SEC                ; decrease the X velocity by an acceleration amount of 0.25
    LDA x_vel+0
    SBC #MOVEACCEL
    STA x_vel+0
    LDA x_vel+1
    SBC #$00
    STA x_vel+1
    BPL gravity                ; if velocity is positive, no clamp needed
    CMP #(MOVESPEED ^ $FF)+1   ; if the MSB of velocity is greater than -movespeed, no clamp needed
    BCS gravity
    LDA #$00
    STA x_vel+0
    LDA #(MOVESPEED ^ $FF)+1
    STA x_vel+1
    JMP gravity
@nodir:
    LDA x_vel+0
    ORA x_vel+1
    BEQ gravity
    LDA x_vel+1
    BMI @negative
    BNE :+             ; positive velocity drag
    LDA x_vel+0
    CMP #MOVEDRAG
    BCS :+
    LDA #$00
    STA x_vel+0
    JMP gravity
:
    SEC
    LDA x_vel+0
    SBC #MOVEDRAG
    STA x_vel+0
    LDA x_vel+1
    SBC #$00
    STA x_vel+1
    JMP gravity
@negative:             ; negative velocity drag
    CMP #$FF
    BNE :+
    LDA x_vel+0
    CMP #(MOVEDRAG ^ $FF)+2
    BCC :+
    LDA #$00
    STA x_vel+0
    STA x_vel+1
    JMP gravity
:
    CLC
    LDA x_vel+0
    ADC #MOVEDRAG
    STA x_vel+0
    LDA x_vel+1
    ADC #$00
    STA x_vel+1

gravity:
    LDA y_vel+1
    BMI applygravity
    CMP #FALLSPEED
    BCS terminal_velocity
applygravity:
    LDA controller
    AND #BUTTON_A
    BNE lowgrav
    LDA #HIGHGRAV
    JMP gravready
lowgrav:
    LDA #LOWGRAV
gravready:
    CLC
    ADC y_vel+0
    STA y_vel+0
    LDA y_vel+1
    ADC #$00
    STA y_vel+1
    JMP handlejump
terminal_velocity:
    LDA #$00
    STA y_vel+0
    LDA #FALLSPEED
    STA y_vel+1

handlejump:
    LDA on_ground
    BEQ applyvelocity
    LDA controller
    AND #BUTTON_A
    BEQ releasejump
    LDA jumping
    BNE applyvelocity
    STA y_vel+0
    LDA #$01
    STA jumping
    LDA #(JUMPVELOCITY ^ $FF)+1
    STA y_vel+1
releasejump:
    STA jumping

applyvelocity:
    CLC                ; apply X velocity
    LDA x_pos+0
    ADC x_vel+0
    STA x_pos+0
    LDA x_pos+1
    ADC x_vel+1
    STA x_pos+1
    
player_collision:
    JSR bg_collision   ; X collision
    LDA collision
    BEQ apply_y_vel
    LDA #$00
    STA x_vel+1
    STA x_vel+0
    LDX player_dir
    BNE @backwards
    LDA #$C0
@backwards:
    STA x_pos+0
    LDA x_pos+1
    SEC
    SBC x_eject
    STA x_pos+1
apply_y_vel:
    CLC                ; apply Y velocity
    LDA y_pos+0
    ADC y_vel+0
    STA y_pos+0
    LDA y_pos+1
    ADC y_vel+1
    STA y_pos+1

    JSR bg_collision   ; Y collision
    LDA collision
    BEQ :+
    LDA #$00
    STA y_vel+1
    STA y_vel+0
    LDA #$C0
    STA y_pos+0
    LDA y_pos+1
    SEC
    SBC y_eject
    STA y_pos+1
:

drawplayer:
    JSR oamclear       ; draw sprites
    LDA #$01
    STA R0
    LDA x_pos+1
    STA R1
    LDA y_pos+1
    STA R2
    LDA #%00000000
    ORA player_dir
    STA R3
    JSR oamsprite

    JMP mainloop