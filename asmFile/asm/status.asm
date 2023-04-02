; ------------------------------------------------------------------------------
; ゲームタイマーの表示
; 画面更新時に実行してゲームタイマーを更新する
; 引数なし
; Aレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

.scope S_DISP_TIME
	UPPER = $20
	LOWER = $7a
.endscope

S_DISP_TIME:
		lda #S_DISP_TIME::UPPER
		sta PPU_ADDRESS
		lda #S_DISP_TIME::LOWER
		sta PPU_ADDRESS
		lda game_timer_bcd1
		ora #$30
		sta PPU_ACCESS
		lda game_timer_bcd2
		ora #$30
		sta PPU_ACCESS
		lda game_timer_bcd3
		ora #$30
		sta PPU_ACCESS

		rts  ; -------------------------


; ------------------------------------------------------------------------------
; 32Fごとにフレームタイマーをデクリメント
; 引数なし
; Aレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

S_DEC_TIME:
		lda frame_counter
		and #%00011111
		beq @DEC_TIME
		rts  ; -------------------------
@DEC_TIME:
		lda #$01
		sta timer_update_flag

		ldx game_timer_bcd3
		dex
		cpx #$ff
		beq @SKIP1
		stx game_timer_bcd3
		rts  ; -------------------------
@SKIP1:
		ldx #$09
		stx game_timer_bcd3

		ldx game_timer_bcd2
		dex
		cpx #$ff
		beq @SKIP2
		stx game_timer_bcd2
		rts  ; -------------------------
@SKIP2:
		ldx #$09
		stx game_timer_bcd2

		ldx game_timer_bcd1
		dex
		cpx #$ff
		beq @SKIP3
		stx game_timer_bcd1
		rts  ; -------------------------
@SKIP3:
		ldx #$09
		stx game_timer_bcd1

		rts  ; -------------------------
