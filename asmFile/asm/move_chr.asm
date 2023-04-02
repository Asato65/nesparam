; ------------------------------------------------------------------------------
; マリオ移動
; 左右移動
; 引数無し
; A, Xレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_MOVE_PLAYER:
		; 右方向速度
		lda #CON_R
		sta check_con_btn
		lda mario_speed_R
		sta mario_speed_tmp
		jsr S_GET_SPEED_L_OR_R
		lda mario_speed_tmp
		sta mario_speed_R

		; 左方向速度
		lda #CON_L
		sta check_con_btn
		lda mario_speed_L
		sta mario_speed_tmp
		jsr S_GET_SPEED_L_OR_R
		lda mario_speed_tmp
		sta mario_speed_L

		; 左右の速度からX方向の速度等を出す
		jsr S_CALC_SPEED_X

		; 縦方向速度
		jsr S_GET_SPEED_Y

		jsr S_CHECK_COLLISION

	;jsr S_STORE_AMOUNT_X

		jsr S_STORE_MARIO

		rts  ; -------------------------
