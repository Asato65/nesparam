; ------------------------------------------------------------------------------
; メイン処理
; ------------------------------------------------------------------------------

S_MAIN:
		lda #%10001000					; ステータス表示のためスクロールリセット
		sta PPU_SET1
		lda #$00
		sta PPU_SCROLL
		sta PPU_SCROLL

		lda sound_ch1_num
		and #%00000001
		sta cannot_control

		jsr S_GET_CON					; コントローラー取得
		lda con_player1_pushstart
		and #CON_START
		beq @SKIP_TOGGLE_PAUSE
		lda pause_flag
		eor #$01
		sta pause_flag
		lda #$01
		sta sound_ch1_num

		lda sound_ch1_num
		and #%00000001
		sta cannot_control

		bne @WAIT_SPR0_HIT

@SKIP_TOGGLE_PAUSE:
		lda pause_flag
		ora cannot_control
		bne @WAIT_SPR0_HIT				; ポーズ中スキップ

		; ポーズがかかってないとき、0爆弾待ち中の動作
		jsr S_DEC_TIME
		inc $e0

@WAIT_SPR0_HIT:
		bit PPU_STATUS
		bvc @WAIT_SPR0_HIT				; 0爆弾待ち
		jsr S_SET_SCROLL

		lda pause_flag
		ora cannot_control
		bne @PAUSING_SKIP

		; ポーズがかかっていないときの動作
		;lda con_player1				; 多段ジャンプの実装
		;and #CON_A
		;bne @SKIP_UPDATE_FLY_FLUG
		; lda #$00
		;sta mario_isfly
@SKIP_UPDATE_FLY_FLUG:
		jsr S_MOVE_PLAYER				; プレイヤー移動

@PAUSING_SKIP:
		jsr S_SOUND

		lda ver_speed
		ora mario_isfly
		and #%01111111
		beq @SKIP1
		lda #$01
@SKIP1:
		sta mario_isfly

		lda #$01
		sta isend_main					; フラグを立てる

		rts  ; -------------------------
