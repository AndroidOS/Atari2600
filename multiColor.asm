  processor 6502

  include "vcs.h"
  include "macro.h"

  org $F000
  
;base on Gustavo Pezzi's work.

START:
  CLEAN_START     ; Macro to clear memory

; Start a new frame - Turn on VBLANK and VSYNC
NextFrame:
  lda #2          ;same as binary value %00000010
  sta VBLANK      ;turn on VBLANK
  sta VSYNC       ;turn on VSYNC

; Generate the 3 lines of VSYNC
  sta WSYNC       ;first scanline
  sta WSYNC       ;second scanline
  sta WSYNC       ;third scanline
  lda #0
  sta WSYNC       ;turn off VSYNC

; TIA generate 37 scanlines of VBLANK
  lda #37         ;X = 37 (to count 37 scanlines)
LoopVBlank:
  sta WSYNC       ;hit WSYNC and wait for the next scanline
  dex             ;dec x by 1
  bne LoopVBlank  ;Loop while x != 0
  lda #0
  sta VBLANK      ;Turn off VBLANK

; Draw 192 visible scanlines (kernel)
  ldx #192        ;counter for 192 visible scanlines
LoopVisible:
  stx COLUBK      ;set the background colour
  sta WSYNC       ;wait for next scanline
  dex             ;x--
  bne LoopVisible ;Loop while x != 0

;Output 30 more VBLANK lines (overscan) to complete frame
  lda #2          ;Turn on VBLANK again
  sta VBLANK
  ldx #30         ;Counter for 30 scanlines
LoopOverscan:
  sta WSYNC       ;wait for next scanline
  dex             ;x--
  bne LoopOverscan ;Loop while x != 0

  jmp NextFrame

;Complete 4K ROM
  org $FFFC ; 6502 start vector location
  .word START ; START memory location
  .word START ; Fill ROM to 4K
