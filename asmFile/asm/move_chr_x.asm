; ------------------------------------------------------------------------------
; マリオX座標移動
; 事前にメモリーに必要な値をストアして左右それぞれのスピードを出せる
; 引数無し（チェックするコントローラーの方向と変更するスピードをメモリーにストア）
; A, Xレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_GET_SPEED_L_OR_R:
		lda con_player1_pushstart
		and check_con_btn
		beq @SKIP1						; ボタンが初めて押されたとき以外スキップ
		lda mario_speed_tmp
		bne @SKIP1						; 進む方向のスピードが0でないときスキップ
		lda mario_pixel_speed
		bne @BRAKE						; スピードが0でないときスキップ
		lda #MARIO_FIRST_SPEED
		sta mario_speed_tmp				; 走り始めの速度
		bne @SKIP1						; 強制ジャンプ
@BRAKE:
		lda #$01						; 2方向に動き始めたとき、速度を0でなくする
		sta mario_speed_tmp
@SKIP1:
		lda mario_speed_tmp
		bne @SKIP2						; スピード0のとき終了
		rts  ; -------------------------
@SKIP2:
		lda con_player1
		and check_con_btn
		bne @SKIP3
		ldx mario_speed_tmp				; ボタンが押されてないとき速度下降（0まで）
		dex
		cpx #$10
		bpl @STORE_SPEED_DOWN
		ldx #$00						; 速度が0より小さい時速度を0に
@STORE_SPEED_DOWN:
		stx mario_speed_tmp
		rts  ; -------------------------
@SKIP3:									; 右ボタン押されていて速度あり
		lda mario_isfly
		beq @ADD_SPEED
		lda check_con_btn				; 下位がLRの順
		and #%00000001
		cmp mario_x_direction
		beq @ADD_SPEED					; 方向が同じときスキップ
		lda frame_counter
		and #%00000011
		beq @ADD_SPEED
		rts  ; -------------------------
@ADD_SPEED:
		lda con_player1
		and #CON_B
		beq @WALK
		lda mario_speed_tmp				; ダッシュ
		add #MARIO_DASH_INCSPEED
		cmp #MARIO_DASH_MAXSPEED
		bmi @STORE_SPEED_DASH
		lda #MARIO_DASH_MAXSPEED		; ダッシュ速度で維持
@STORE_SPEED_DASH:
		sta mario_speed_tmp
		rts  ; -------------------------
@WALK:									; 歩き
		lda mario_speed_tmp
		cmp #MARIO_WALK_MAXSPEED
		bpl @WALK_SPEED_DOWN
		add #MARIO_WALK_INCSPEED
		cmp #$16
		bpl @SKIP_SLOW_SPEED
		pha
		lda frame_counter
		and #%00000000					; 速度が小さいときの調整
		beq @PLA_SPEED
		pla
		rts  ; -------------------------
@PLA_SPEED:
		pla
@SKIP_SLOW_SPEED:
		cmp #MARIO_WALK_MAXSPEED
		bmi @STORE_SPEED_UP_WALK
		lda #MARIO_WALK_MAXSPEED		; 歩き速度で維持
@STORE_SPEED_UP_WALK:
		sta mario_speed_tmp
		rts  ; -------------------------
@WALK_SPEED_DOWN:						; 歩きになってダッシュから速度を減少させる
		sec
		sbc #MARIO_WALK_INCSPEED
		cmp #MARIO_WALK_MAXSPEED
		bpl @STORE_SPEED_DOWN_WALK
		lda #MARIO_WALK_MAXSPEED		; 歩き速度で維持
@STORE_SPEED_DOWN_WALK:
		sta mario_speed_tmp
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; 左右それぞれのスピードから速度を出し、ブレーキや向きフラグをセット
; 引数無し
; A, Xレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_CALC_SPEED_X:
		ldx #$00						; 値セット用
		lda mario_speed_L
		bne @SPEED_L_NOT0
		lda mario_speed_R
		bne @SPEED_L0_R_NOT0
		stx mario_subpixel_speed		; 左 = 0、右 = 0
		stx mario_pixel_speed
		stx mario_speed_remainder
		stx brake
		rts  ; -------------------------
@SPEED_L_NOT0:							; 左速度あり
		lda mario_speed_R
		bne @SPEED_LR_NOT0
		jsr S_STORE_PIXEL_SPEED			; 左 ≠ 0、右 = 0
		stx mario_x_direction
		stx mario_face_direction
		stx brake
		stx flagA
		rts  ; -------------------------
@SPEED_L0_R_NOT0:						; 左 = 0、右 ≠ 0
		jsr S_STORE_PIXEL_SPEED
		stx brake
		stx flagA
		inx
		stx mario_x_direction
		stx mario_face_direction
		rts  ; -------------------------
@SPEED_LR_NOT0:							; 左 ≠ 0、右 ≠ 0
		lda flagA
		cmp #$02
		beq @SKIP_SET_FLAG
		lda #$01
		sta flagA
		lda mario_x_direction
		eor #%00000001
		sta mario_face_direction
@SKIP_SET_FLAG:
		lda mario_speed_L
		cmp mario_speed_R
		beq @SPEED_L_EQUAL_R
		bmi @SPEED_BIGGER_R
		stx mario_x_direction			; 左 > 右
		jsr S_STORE_PIXEL_SPEED
		lda mario_face_direction
		beq @SPEED_BIGGER_L_FACE_L
		inx
		stx brake						; ブレーキON
		lda #$10
		sta mario_speed_R				; ブレーキの時
		rts  ; -------------------------
@SPEED_BIGGER_L_FACE_L:
		stx brake						; ブレーキOFF
		lda #$02
		sta flagA
		rts  ; -------------------------
@SPEED_L_EQUAL_R:						; 左 = 右
		stx brake
		lda #$02
		sta flagA
		lda mario_face_direction
		beq @SPEED_L_EQUAL_R_FACE_L
		inx
		stx mario_x_direction
		rts  ; -------------------------
@SPEED_L_EQUAL_R_FACE_L:
		stx mario_x_direction
		rts  ; -------------------------
@SPEED_BIGGER_R:						; 左 < 右
		inx
		stx mario_x_direction
		jsr S_STORE_PIXEL_SPEED
		lda mario_face_direction
		beq @SPEED_BIGGER_R_FACE_L
		dex
		stx brake						; ブレーキOFF
		lda #$02
		sta flagA
		rts  ; -------------------------
@SPEED_BIGGER_R_FACE_L:
		stx brake						; ブレーキoN
		lda #$10
		sta mario_speed_L
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; サブピクセル、ピクセルの移動スピードをストアする
; 引数無し
; Aレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_STORE_PIXEL_SPEED:
		lda mario_speed_L
		sec
		sbc mario_speed_R
		bpl @SKIP1
		cnn
@SKIP1:
		add mario_speed_remainder
		sta mario_subpixel_speed
		and #%00001111
		sta mario_speed_remainder
		lda mario_subpixel_speed
		and #%11110000
		rsft4
		sta mario_pixel_speed
		rts  ; -------------------------
