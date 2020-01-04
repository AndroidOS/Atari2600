  processor 6502

  include "vcs.h"
  include "macro.h"

  org $F000 ; Start of program

START:
  CLEAN_START ; Macro to clear memory

; set Stella VCS emulator from auto-detect to NSTC
LOOP:
  lda #$1E
  sta COLUBK ; Store A to background colour address $A9
  jmp LOOP


  org $FFFC ; 6502 start vector location
  .word START ; START memory location
  .word START ; Fill ROM to 4K
