.include "defines.s"
.include "romheader.s"
.include "variables.s"

.segment "CODE"
.include "init.s"
.include "loop.s"
.include "nmi.s"
.include "ppulib.s"
.include "utils.s"
.include "data.s"


.segment "VECTORS"
    .word  NMI
    .word  RESET
    .word  0
.segment "CHARS"
    .incbin "tiles.chr"
    .incbin "sprites.chr"