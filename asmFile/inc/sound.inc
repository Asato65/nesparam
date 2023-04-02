; PAUSE
PAUSE_SOUND_LOWER:
		.byte $80, $a0, $80, $a0, $80, $a0

PAUSE_SOUND_UPPER:						; 上位5bitは音の長さ、フレームで管理するため設定不要
		.byte $f0, $f0, $f0, $f0, $f0, $f0

PAUSE_SOUND_TIME:
		.byte $05, $05, $05, $05, $05, $10, $00

; JUMP
JUMP_SOUND_LOWER:
	.byte $c0

JUMP_SOUND_UPPER:
	.byte $80

JUMP_SOUND_TIME:
	.byte $60, $00


; ADDR ARRAY

SOUND_ADDR_LOWER:
		.word PAUSE_SOUND_LOWER			; 1
		.word JUMP_SOUND_LOWER

SOUND_ADDR_UPPER:
		.word PAUSE_SOUND_UPPER			; 1
		.word JUMP_SOUND_UPPER

SOUND_TIME:
		.word PAUSE_SOUND_TIME			; 1
		.word JUMP_SOUND_TIME
