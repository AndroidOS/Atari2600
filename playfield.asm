  processor 6502

  include "vcs.h"
  include "macro.h"

  org $F000

;base on Gustavo Pezzi's work.

START:
  CLEAN_START     ; Macro to clear memory

  ldx #$80        ; Blue background color
  stx COLUBK

  lda #$1C        ; yellow playfield
  sta COLUPF

; Start a new frame - Turn on VBLANK and VSYNC
StartFrame:
  lda #2          ;same as binary value %00000010
  sta VBLANK      ;turn on VBLANK
  sta VSYNC       ;turn on VSYNC

  ; Generate the 3 lines of VSYNC
  ;sta WSYNC       ;first scanline
  ;sta WSYNC       ;second scanline
  ;sta WSYNC       ;third scanline
  REPEAT 3
    sta WSYNC       ;3 scanlines for VSYNC
  REPEND
  lda #0
  sta VSYNC       ;turn off VSYNC

  ; TIA generate 37 scanlines of VBLANK
  ldx #37         ;X = 37 (to count 37 scanlines)
LoopVBlank:
  sta WSYNC       ;hit WSYNC and wait for the next scanline
  dex             ;dec x by 1
  bne LoopVBlank  ;Loop while x != 0
  lda #0
  sta VBLANK      ;Turn off VBLANK

  ;Set the CTRLPF register to allow playfield reflection
  ldx #%00000001 ; CTRLPF register (D0 means reflect the PF)
  stx CTRLPF

;Draw the 192 visible scanlines
  ;Skip 7 scanlines with no PF Set
  ldx #0
  stx PF0
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ;Set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
  ldx #%11100000
  stx PF0
  ldx #%11111111
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ;Set the next 164 lines only with PF0 third bit enabled
  ldx #%00100000
  stx PF0
  ldx #0
  stx PF1
  stx PF2
  REPEAT 80
    sta WSYNC
  REPEND

  ;Set the next 4 lines only with PF0 1110 and PF1 and PF2 1111 1111
  ldx #%11100000
  stx PF0
  ldx #$FF
  stx PF1
  stx PF2
  REPEAT 4
    sta WSYNC
  REPEND

  ;Set the next 164 lines only with PF0 third bit enabled
  ldx #%00100000
  stx PF0
  ldx #0
  stx PF1
  stx PF2
  REPEAT 80
    sta WSYNC
  REPEND

  ;Set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
  ldx #%11100000
  stx PF0
  ldx #%11111111
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ;Skip 7 scanlines with no PF Set
  ldx #0
  stx PF0
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ;Output 30 more VBLANK lines (overscan) to complete frame
  lda #2          ;Turn on VBLANK again
  sta VBLANK
  ldx #30         ;Counter for 30 scanlines
LoopOverscan:
  sta WSYNC       ;wait for next scanline
  dex             ;x--
  bne LoopOverscan ;Loop while x != 0





  jmp StartFrame

  ;Complete 4K ROM
  org $FFFC ; 6502 start vector location
  .word START ; START memory location
  .word START ; Fill ROM to 4K
