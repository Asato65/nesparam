; ------------------------------------------------------------------------------
; 上昇速度を出す
; ------------------------------------------------------------------------------

S_GET_SPEED_Y:
		jsr JUMP_CHECK
		jsr MOVE_PROCESS
		rts  ; -------------------------


S_RESET_PARAM_JUMP:
		; lda #$00
		; sta ver_speed
		; sta ver_force_decimal_part
		; sta ver_force_fall
		; sta ver_speed_decimal_part
		; sta ver_pos_decimal_part
		; sta mario_isfly
		; stx mario_posy

		lda VER_FORCE_DECIMAL_PART_DATA
		sta ver_force_decimal_part
		lda VER_FALL_FORCE_DATA
		sta ver_force_fall
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
; 引数なし（変更）
JUMP_CHECK:
		lda con_player1_pushstart
		and #CON_A
		bne @SKIP1
		; 初めてジャンプボタンが押されてないとき終了
		rts  ; -------------------------
@SKIP1:
		lda mario_isfly
		bne @SKIP2
		; 地面にいるときジャンプ開始準備
		jsr PREPARING_JUMP
@SKIP2:
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

PREPARING_JUMP:
		ldx #$01
		stx mario_isfly
		stx mario_isjump
		dex
		stx ver_speed_decimal_part
		lda mario_posy
		sta ver_pos_origin

		; Xレジスタ = 0（idx）
		lda mario_speed_L
		sec
		sbc mario_speed_R
		bpl @SKIP5
		cnn
@SKIP5:
		; | L - R | を求めてX方向のスピードの絶対値を求める
		cmp #$1c
		bmi @SKIP1
		inx
@SKIP1:
		cmp #$19
		bmi @SKIP2
		inx
@SKIP2:
		cmp #$10
		bmi @SKIP3
		inx
@SKIP3:
		cmp #$09
		bmi @SKIP4
		inx
@SKIP4:

		lda VER_FORCE_DECIMAL_PART_DATA, x
		sta ver_force_decimal_part
		lda VER_FALL_FORCE_DATA, x
		sta ver_force_fall
		lda INITIAL_VER_FORCE_DATA, x
		sta ver_speed_decimal_part
		lda INITIAL_VER_SPEED_DATA, x
		sta ver_speed

		rts  ; -------------------------


; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; 引数なし（変更）
MOVE_PROCESS:
		lda ver_speed
		bpl @SKIP1
		lda con_player1
		and #CON_A
		bne @SKIP2
		lda con_player1_prev
		and #CON_A
		beq @SKIP2
@SKIP1:
		lda ver_force_fall
		sta ver_force_decimal_part
@SKIP2:
		jsr PHYSICS
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

PHYSICS:
		ldx #$00
		stx ver_pos_fix_val
		lda ver_pos_decimal_part
		add ver_force_decimal_part
		sta ver_pos_decimal_part
		bcc @SKIP_OVERFLOW
		; オーバーフローしてたら
		stx ver_pos_decimal_part
		inx
		stx ver_pos_fix_val				; 補正値があったらここで修正
@SKIP_OVERFLOW:
		lda ver_speed_decimal_part
		add ver_force_decimal_part
		sta ver_speed_decimal_part
		bcc @END_SUB
		lda #$00
		sta ver_speed_decimal_part

		ldx ver_speed
		inx
		cpx #DOWN_SPEED_LIMIT
		bmi @STORE_VER_SPEED
		;lda ver_speed_decimal_part
		;bpl @STORE_VER_SPEED
		ldx #DOWN_SPEED_LIMIT
		lda #$00
		sta ver_speed_decimal_part
@STORE_VER_SPEED:
		stx ver_speed
		txa								; Xレジスタの値を比較するのでここでフラグを更新
		bmi @END_SUB
		lda #$00
		sta mario_isjump

@END_SUB:
		rts  ; -------------------------



; ------------------------------------------------------------------------------
; 重力データとか
; ------------------------------------------------------------------------------

DOWN_SPEED_LIMIT = $04		; 落下の最高速度
; 加速度の増加値
VER_FORCE_DECIMAL_PART_DATA:
		.byte $20, $20, $1e, $28, $28
; 降下時の加速度
VER_FALL_FORCE_DATA:
		.byte $70, $70, $60, $90, $90
; 初速度(v0)
INITIAL_VER_SPEED_DATA:
		.byte $fc, $fc, $fc, $fb, $fb
; 初期加速度(a)
INITIAL_VER_FORCE_DATA:
		.byte $00, $00, $00, $00, $00