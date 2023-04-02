; ------------------------------------------------------------------------------
; キャリーなし加算、減算
; 引数：足し引きする値
; ------------------------------------------------------------------------------

.macro add VAL
		clc
		adc VAL
.endmacro

.macro sub VAL
		sec
		sbc VAL
.endmacro


; ------------------------------------------------------------------------------
; ロード命令拡張マクロ
; lda + arr
; 引数：読み込む配列ARRのアドレス、ARR[x][y]になるX、Yレジスタ
; Aレジスタ破壊
; 戻り値：Aレジスタ
; ------------------------------------------------------------------------------

.scope MACRO_TMP
		tmp1 = $d0
.endscope

.macro ldarr ADDR
		sty MACRO_TMP::tmp1				; 破壊するので
		txa
		asl								; *2（アドレスが16bitなのでARR[x][y]のxが+1 => 読み込むアドレスは+2する必要がある
		tay								; アドレッシングに使うためYレジスタへ
		lda ADDR, y
		sta addr_lower
		lda ADDR+1, y
		sta addr_upper
		ldy MACRO_TMP::tmp1
		lda (addr_lower), y
.endmacro


; ------------------------------------------------------------------------------
; RAM初期化
; initialize RAM
; 引数：初期化開始アドレス、初期化する値
; A, Xレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

.macro inirm ADDR, VAL
		lda VAL
		ldx #$00
:
		sta ADDR, x
		dex
		bne :-
.endmacro


; ------------------------------------------------------------------------------
; VRAM初期化
; initialize VRAM
; 引数：初期化する値
; A, X, Yレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

.macro inivrm VAL
		lda #$20
		sta PPU_ADDRESS
		lda #$00
		sta PPU_ADDRESS
		lda VAL
		ldx #$00
		ldy #$08
:
:
		sta PPU_ACCESS
		dex
		bne :-
		dey
		bne :--
.endmacro


; ------------------------------------------------------------------------------
; 負の数（2の補数）を求める
; Calculate Negative Numbers
; 引数なし
; Aレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

.macro cnn
		eor #$ff
		add #$01
.endmacro


; ------------------------------------------------------------------------------
; 上位4ビットを下位に持ってくる
; ------------------------------------------------------------------------------

 .macro rsft4
		lsr
		lsr
		lsr
		lsr
.endmacro


; ------------------------------------------------------------------------------
; 下位4bitを下位に持ってくる
; ------------------------------------------------------------------------------

.macro lsft4
		asl
		asl
		asl
		asl
.endmacro


; ------------------------------------------------------------------------------
; X, Yレジスタの加算、減算
; 引数：足し引きする値
; ------------------------------------------------------------------------------

; .macro adcx VAL
; 		pha
; 		txa
; 		adc VAL
; 		tax
; 		pla
; .endmacro

; .macro addx VAL
; 		pha
; 		txa
; 		add VAL
; 		tax
; 		pla
; .endmacro

; .macro adcy VAL
; 		pha
; 		tya
; 		adc VAL
; 		tay
; 		pla
; .endmacro

; .macro addy VAL
; 		pha
; 		tya
; 		add VAL
; 		tay
; 		pla
; .endmacro

; .macro sbcx VAL
; 		pha
; 		txa
; 		sbc VAL
; 		tax
; 		pla
; .endmacro

; .macro subx VAL
; 		pha
; 		txa
; 		sub VAL
; 		tax
; 		pla
; .endmacro

; .macro sbcy VAL
; 		pha
; 		tya
; 		sbc VAL
; 		tay
; 		pla
; .endmacro

; .macro suby VAL
; 		pha
; 		tya
; 		sub VAL
; 		tay
; 		pla
; .endmacro
