.segment "ZEROPAGE"           ; The first page of internal RAM
    R0:            .res 1     ; Scratch Registers
    R1:            .res 1
    R2:            .res 1
    R3:            .res 1
    R4:            .res 1
    R5:            .res 1
    R6:            .res 1
    R7:            .res 1
    R8:            .res 1
    R9:            .res 1
    R10:           .res 1
    R11:           .res 1
    R12:           .res 1
    R13:           .res 1
    R14:           .res 1
    R15:           .res 1
    ppu_ctrl:      .res 1     ; A CPU side mirror of the PPUCTRL register
    vram_index:    .res 1     ; Current index of the VRAM buffer
    frame_counter: .res 1     ; General purpose frame counter
    frame_ready:   .res 1     ; Used to indicate to the NMI handler that frame is ready to be drawn
    scroll:        .res 1     ; Y pixel position of screen scroll
    oam_index:     .res 1     ; Current index of the OAM buffer
    controller:    .res 1     ; Controller input
    prng:          .res 2     ; The prng seed/value
    player_dir:    .res 1     ; Facing direction of the player (0: right, 1: left)
    x_pos:         .res 2     ; X position of the player (LSB: subpixel position, MSB: pixel position)
    y_pos:         .res 2     ; Y position of the player (LSB: subpixel position, MSB: pixel position)
    x_vel:         .res 2     ; X velocity of the player (LSB: subpixel velocity, MSB: pixel velocity)
    y_vel:         .res 2     ; Y velocity of the player (LSB: subpixel velocity, MSB: pixel velocity)

    on_ground:     .res 1     ; Whether the player is on the ground
    jumping:       .res 1     ; Whether the jump button was held last frame
    p_anim_frame:  .res 1     ; The current frame of the player's animation
    spawn_timer:   .res 1     ; The number of frames until the next block spawns
    block_col:     .res 3     ; The column of the falling blocks
    block_x_pos:   .res 3     ; The x coordinate of the falling blocks
    block_y_pos:   .res 3     ; The y coordinate of the falling blocks
    columns:       .res 12    ; The y coord of the top of each block column


.segment "RAM"                ; The rest of internal RAM after ZP, the OAM buffer, and the VRAM buffer
    attr_buf:      .res 64    ; A mirror of the nametable A attribute table for single 16x16 updates
