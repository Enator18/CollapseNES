move_and_collide:
    LDA #$00
    STA on_ground      ; 0 on_ground
    CLC                ; apply X velocity (16 bit addition)
    LDA x_pos+0		   ; lower bytes
    ADC x_vel+0
    STA x_pos+0
    LDA x_pos+1		   ; upper bytes
    ADC x_vel+1
    STA x_pos+1

    TAY		           ; write x position to y register
    LSR A			   ; divide it by 16
    LSR A
    LSR A
    LSR A
    TAX				   ; now the horizontal tile is in the x register

    TYA				   ; these next two lines put the right 4 bits of the x pos in the accumulator
    AND #$0F
    CMP #$09		   ; if that's less than 9, jump to checkxblock because our left half is on the left side of the tile we're on, so we didn't hit anything
    BCC @checkxblock
					   ; we might've hit something; let's check
    BIT x_vel+1		   ; here we set the minus flag based on the x velocity
    BMI :+			   ; if we're moving left skip the next thing
    INX				   ; otherwise, increment x, because we're moving right, so we look at one column to the right
:
    CPX #$02		   ; if our tile is less than 2, we're colliding with the left wall, jump to x hit
    BCC @xhit
    CPX #$0E		   ; if our tile is greater than or equal to 14, we're collding with the right wall, jump to x hit
    BCS @xhit

    LDA columns-2, X   ; our tile is between 2 and 13 in world space, but we store 0 to 11, so subtract 2, and get the column value there
    CMP y_pos+1		   ; check if that height is >= our y pos (up is down so if it is, there's no hit, otherwise proceed to hit)
    BCC @xhit		   ; we never need to worry about block collisions if we hit a tile, so skip to xhit
@checkxblock:
	LDY #$03		   ; start a 3 thing for loop
@xblockloop:
	DEY				   ; countdown
	BMI @noxhit		   ; exit loop when we're done
	TXA				   ; compare the yth block to see if we hit it
	CMP block_col, Y
	BNE @xblockloop	   ; return to start of loop if we didn't find anything
					   ; check collisions if we did find something
	LDA block_y_pos, Y ; read the y pos of the yth block
	SEC
	SBC #$10		   ; move up 1 tile
	CMP y_pos+1
	BCS @xblockloop	   ; if we're above it, keep checking

	ADC #$1F

	CMP y_pos+1
	BCC @xblockloop	   ; if we're below it, keep checking
@xhit:
    LDA x_pos+1        ; put the x pos in the accumulator and round to the nearest half-tile
    AND #$F8
    LDY #$C0		   ; set the fractional position to .75, the biggest multiple of .25 you can have before moving a full position
    BIT x_vel+1		   ; check our direction
    BPL :+			   ; if we were going right, our job is done, so skip
    LDY #$00		   ; otherwise that stuff we did was useless so start over. Start by setting fractional pos to 0 so that we're all the way on the left of the block
    AND #$F0		   ; snap them to the left of their tile, then move them one tile right, so they're at the far left of the space to the right
    CLC
    ADC #$10
:
    STY x_pos+0		   ; update the fractional position
    STA x_pos+1		   ; update the position
    LDA #$00		   ; 0 the velocity because we collided
    STA x_vel+0
    STA x_vel+1
@noxhit:
    CLC                ; apply Y velocity, another 16 bit add
    LDA y_pos+0
    ADC y_vel+0
    STA y_pos+0
    LDA y_pos+1
    ADC y_vel+1
    STA y_pos+1

    LDA x_pos+1		   ; recalculate x pos because we might've moved
    LSR A
    LSR A
    LSR A
    LSR A
    TAX
    LDA columns-2, X   ; grab our column's height value
    CMP y_pos+1		   ; check if we're hitting a tile and handle it if we are
    BCC @yhit
    LDA x_pos+1		   ; look at the right 4 bits of our world pos and see if we're on the left half of a tile
    AND #$0F
    CMP #$09
    BCC @noyhit		   ; if we are, then we didn't hit anything
    INX				   ; increment the column index to look to the column to the right that we're also touching
    LDA columns-2, X   ; if we're not hitting it, we can skip the hit check
    CMP y_pos+1
    BCS @noyhit
@yhit:
    STA y_pos+1		   ; the top of the column is already where they should be standing so teleport there
    LDA #$C0		   ; put their fractional position as low as possible
    STA y_pos+0
    LDA #$00		   ; reset the y velocity
    STA y_vel+0
    STA y_vel+1
    LDA #$01		   ; store that we hit the ground
    STA on_ground
@noyhit:
    RTS

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
    
