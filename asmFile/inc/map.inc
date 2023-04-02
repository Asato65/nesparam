; 床=A=41 => 00
; レンガ=B=42 => 01
; これはランレングスでなく，オブジェクトの位置を指定して配置した方がいい？

MAP1_1_POS:
	; 1
	;.byte $21	; X 2, Y 1に配置
	.byte $0b, $0c
	.byte $16, $1a, $1b;, $1c
	.byte $2b
	.byte $3a, $3b
	.byte $79
	.byte $8a
	.byte $9b, $9c
	.byte $ac
	.byte $cc
	.byte $db, $dc
	.byte $ea, $eb, $ec
	.byte $ef
	; 2
	.byte $4a, $4b, $4c
	.byte $8d, $8e
	.byte $c9
	.byte $ef
	; 3
	.byte $13
	.byte $14
	.byte $4d
	.byte $4e
	.byte $a8
	.byte $ef
	; 4
	.byte $53
	.byte $ef

	.byte $ff

MAP1_1_OBJ:
	.byte BLOCK, BLOCK
	.byte BLOCK, BLOCK, BLOCK;, BLOCK
	.byte BLOCK
	.byte BLOCK, BLOCK
	.byte BLOCK
	.byte BLOCK
	.byte BLOCK, BLOCK
	.byte BLOCK
	.byte BLOCK
	.byte BLOCK, BLOCK
	.byte BLOCK, BLOCK, BLOCK
	.byte $ef
	;2
	.byte BLOCK, BLOCK, BLOCK
	.byte SKY, SKY
	.byte QBLOCK
	.byte $ef
	;3
	.byte BLOCK
	.byte BLOCK
	.byte BLOCK
	.byte BLOCK
	.byte QBLOCK
	.byte $ef
	; 4
	.byte BLOCK
	.byte $ef
	;end
	.byte $ff

MAP1_1_DATA:
	.byte $00	; 地上
	.byte $02	; 画面下


; よって，レンガが(8, 8)に配置される（分割したマップの）
; オブジェクト情報は400~5ff番地に保存する
; 400番台，500番台に入る時にマップ番号を更新