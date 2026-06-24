.include "defines.s"
.include "romheader.s"
.include "variables.s"

.segment "CODE"
.include "init.s"
.include "loop.s"
.include "interrupts.s"
.include "ppulib.s"
.include "utils.s"
.include "data.s"


.segment "VECTORS"
    .word  NMI
    .word  RESET
    .word  IRQ
.segment "CHARS"
    .incbin "tiles.chr"
    .incbin "sprites.chr"