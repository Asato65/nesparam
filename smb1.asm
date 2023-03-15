.setcpu "6502"
.autoimport on

.segment "HEADER"
		.byte $4e, $45, $53, $1a
		.byte $02
		.byte $01
		.byte $01
		.byte $00
		.byte $00, $00, $00, $00
		.byte $00, $00, $00, $00

ABC = $2000
.segment "STARTUP"
.proc RESET
		sei
		ldx #$ff
		txs
		lda #$00
		sta ABC
		sta ABC
MAINLOOP:
		jmp MAINLOOP
.endproc

.segment "CHARS"
		.incbin "bg-spr.chr"

.segment "VECTORS"
		.word $8000
		.word RESET
		.word $8000