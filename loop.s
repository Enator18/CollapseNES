mainloop:              ; the main game tick loop
    JSR nmiwait        ; wait until next frame

    JSR oamclear

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

playermovement:
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
    JSR move_and_collide

updateblocks:
    DEC spawn_timer    ; update spawn timer

    LDX #$02           ; move existing blocks
blockupdateloop:
    LDA block_col, X
    BEQ @maybespawn    ; maybe spawn a block if this slot is empty
    LDA block_y_pos, X
    CLC
    ADC #BLOCKSPEED
    STA block_y_pos, X
    JMP @checkcollide
@maybespawn:           ; maybe spawn a new block
    LDA spawn_timer    ; check the spawn timer
    BNE blockloopend   ; spawn if timer is equal to 0
    LDA prng+1         ; choose a random column to spawn at
    LSR A
    TAY
    LDA prng+0
    ROR A
    CLC
    ADC prng+0
    TYA
    ADC prng+1
    ROR A
    CLC
    ADC #$20
    AND #$F0
    STA block_x_pos, X
    LSR A
    LSR A
    LSR A
    LSR A
    STA block_col, X

    LDA #$18           ; reset spawn timer
    STA spawn_timer
    
    LDA #$01
    STA block_y_pos, X ; start the block at the top of the screen
@checkcollide:
    LDY block_col, X
    CMP columns-2, Y   ; the column values go from 2-13 to better line up with positions
    BCC :+
    JMP placeblock
:
    LDA #$02          ; draw falling block sprites
    STA R0
    LDA #%00000001
    STA R1
    LDA block_y_pos, X
    TAY
    LDA block_x_pos, X
    STA R2
    JSR oamsprite
    CLC
    ADC #$08
    STA R2
    LDA #$04
    STA R0
    LDA block_y_pos, X
    TAY
    JSR oamsprite
blockloopend:
    DEX
    BPL blockupdateloop

drawplayer:
    LDA #$01
    STA R0
    LDA #%00000000
    ORA player_dir
    STA R1
    LDA x_pos+1
    STA R2
    LDY y_pos+1
    JSR oamsprite

    LDA #$01
    STA frame_ready

    JMP mainloop