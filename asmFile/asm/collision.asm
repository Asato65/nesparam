; ------------------------------------------------------------------------------
; あたり判定
; ------------------------------------------------------------------------------

.scope S_CHECK_COLLISION
	tmp_pos_left			= $d0
	tmp_pos_right			= $d1
	tmp_pos_top				= $d2
	tmp_pos_bottom			= $d3
	tmp_block_pos_left		= $d4
	tmp_block_pos_right		= $d5
	tmp_block_pos_top		= $d6
	tmp_block_pos_bottom	= $d7
	width					= $d8
	height					= $d9
	move_amount_disp		= $da
	tmp1					= $db
	start_x					= $dc
	start_y					= $dd
	collision_pos			= $de
.endscope

S_CHECK_COLLISION:
	; マリオ用データ初期化（仮）
	lda #$00
	sta S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::start_y

	lda #$02
	sta S_CHECK_COLLISION::start_x

	lda #$0c
	sta S_CHECK_COLLISION::width

	lda #$10
	sta S_CHECK_COLLISION::height

	; ここから処理
	jsr S_GET_TMP_POS
	lda mario_x_direction
	bne @R
	jsr S_GET_ISCOLLISION_L
	jmp @CHK_Y
@R:
	jsr S_GET_ISCOLLISION_R
@CHK_Y:
	lda mario_isjump
	bne @JUMP
	jsr S_GET_ISCOLLISION_GROUND
	jmp @MOVE
@JUMP:
	jsr S_GET_ISCOLLISION_UP

@MOVE:
	lda S_CHECK_COLLISION::collision_pos
	cmp #%0001
	bne @SKIP1
	lda ver_speed
	cmp #$01
	bpl @RIGHT_GROUND_COLLISION
	bmi @GROUND_COLLISION
@SKIP1:
	cmp #%0010
	bne @SKIP2
	lda ver_speed
	cmp #$01
	bpl @LEFT_GROUND_COLLISION
	bmi @GROUND_COLLISION
@SKIP2:
	cmp #%0011
	beq @GROUND_COLLISION
	cmp #%0100
	bne @SKIP3
	lda S_CHECK_COLLISION::tmp_pos_right
	and #%00001111
	cmp #$05
	bpl @UP_COLLISION
	bmi @RIGHT_UP_COLLISION
@SKIP3:
	;beq @RIGHT_COLLISION
	cmp #%0101
	beq @RIGHT_COLLISION
	cmp #%0110
	beq @STEP1_COLLISION				; 右上に上がっていく
	cmp #%0111
	beq @RIGHT_GROUND_COLLISION
	cmp #%1000
	bne @SKIP4
	lda S_CHECK_COLLISION::tmp_pos_left
	and #%00001111
	cmp #$0c
	bpl @LEFT_UP_COLLISION
	bmi @UP_COLLISION
@SKIP4:
	;beq @UP_COLLISION
	cmp #%1001
	beq @STEP2_COLLISION				; 右上に下がっていく
	cmp #%1010
	beq @LEFT_COLLISION
	cmp #%1011
	beq @LEFT_GROUND_COLLISION
	cmp #%1100
	beq @UP_COLLISION
	cmp #%1101
	beq @RIGHT_UP_COLLISION
	cmp #%1110
	beq @LEFT_UP_COLLISION
	bne @END

@RIGHT_COLLISION:
	jsr S_FIX_R_COLLISION
	jmp @END
@LEFT_COLLISION:
	jsr S_FIX_L_COLLISION
	jmp @END
@GROUND_COLLISION:
	jsr S_FIX_GROUND_COLLISION
	jmp @END
@UP_COLLISION:
	jsr S_FIX_UP_COLLISION
	jmp @END
@RIGHT_GROUND_COLLISION:
	jsr S_FIX_R_COLLISION
	jsr S_FIX_GROUND_COLLISION
	jmp @END
@RIGHT_UP_COLLISION:
	jsr S_FIX_R_COLLISION
	jsr S_FIX_UP_COLLISION
	jmp @END
@LEFT_GROUND_COLLISION:
	jsr S_FIX_L_COLLISION
	jsr S_FIX_GROUND_COLLISION
	jmp @END
@LEFT_UP_COLLISION:
	jsr S_FIX_L_COLLISION
	jsr S_FIX_UP_COLLISION
	jmp @END
@STEP1_COLLISION:
	lda mario_x_direction				; 階段に乗っているのか下から当たっているのか判定
	bne @RIGHT_GROUND_COLLISION			; 右から（上から）当たっている
	beq @LEFT_UP_COLLISION				; 左から（下から）当たっている
@STEP2_COLLISION:
	lda mario_x_direction				; 階段に乗っているのか下から当たっているのか判定
	bne @RIGHT_GROUND_COLLISION			; 右から（下から）当たっている
	beq @LEFT_UP_COLLISION				; 左から（上から）当たっている

@END:
	lda move_amount_sum
	ldx mario_x_direction
	bne @R2
	sub mario_pixel_speed
	clc
	bcc @STR_DATA						; 強制ジャンプ
@R2:
	add mario_pixel_speed
@STR_DATA:
	sta move_amount_sum
	lda move_amount_disp
	add #$00
	sta move_amount_disp
	lda mario_posy
	add ver_speed
	add ver_pos_fix_val
	sta mario_posy

	rts  ; -----------------------------

;* -----------------------------------------------------------------------------
;* 以下，上下左右当たり判定チェック
;* -----------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; 左あたり判定チェック
; ------------------------------------------------------------------------------

S_GET_ISCOLLISION_L:
	ldx S_CHECK_COLLISION::tmp_block_pos_left
	ldy S_CHECK_COLLISION::tmp_block_pos_top
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION_LEFT
	lda #%1000							; 左上
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION_LEFT:
	; あたり判定の幅が10H以上の大きな敵の時の動作（まだ組んでない）
	; lda S_CHECK_COLLISION::height
	; cmp #$11
	; bpl @SKIP
	lda S_CHECK_COLLISION::tmp_pos_top
	and #%11110000
	bpl @SKIP1							; 00以上スキップ
	cmp #$e0
	bpl @NOCOLLISION					; 00未満e0以上のときに衝突なし
@SKIP1:
	; tmpPosBottom > (tmpPosTop&F0H)+10H ならもう一つブロックチェック
	; よって，(tmpPosTmp&F0H) + 10H >= tmpPosBottom ならブロックチェックしない
	add #$10
	cmp S_CHECK_COLLISION::tmp_pos_bottom
	bpl @NOCOLLISION
	iny
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION
	lda #%0010							; 左下
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION:
	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 右あたり判定チェック
; ------------------------------------------------------------------------------

S_GET_ISCOLLISION_R:
	ldx S_CHECK_COLLISION::tmp_block_pos_right
	;inx
	ldy S_CHECK_COLLISION::tmp_block_pos_top
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION_RIGHT
	lda #%0100							; 右上
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
	rts  ; -----------------------------
@NOCOLLISION_RIGHT:
	lda S_CHECK_COLLISION::tmp_pos_top
	and #%11110000
	bpl @SKIP1
	cmp #$e0
	bpl @NOCOLLISION
@SKIP1:
	add #$10
	cmp S_CHECK_COLLISION::tmp_pos_bottom
	bpl @NOCOLLISION

	iny
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION
	lda #%0001							; 右下
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION:
	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 下あたり判定チェック
; ------------------------------------------------------------------------------

S_GET_ISCOLLISION_GROUND:
	ldx S_CHECK_COLLISION::tmp_block_pos_left
	ldy S_CHECK_COLLISION::tmp_block_pos_bottom
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION_GROUND
	lda #%0010							; 左下
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION_GROUND:
	; tmpPosRight > (tmpPosLeft&F0H)+10H ならブロックチェック
	; よって，(tmpPosTmp&F0H) + 10H >= tmpPosBottom ならブロックチェックしない
	lda S_CHECK_COLLISION::tmp_pos_left
	and #%11110000
	add #$10
	cmp S_CHECK_COLLISION::tmp_pos_right
	bpl @NOCOLLISION
	inx
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION
	lda #%0001							; 右下
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION:
	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 上あたり判定チェック
; ------------------------------------------------------------------------------

S_GET_ISCOLLISION_UP:
	ldx S_CHECK_COLLISION::tmp_block_pos_left
	ldy S_CHECK_COLLISION::tmp_block_pos_top
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION_UP
	lda #%1000							; 左上
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION_UP:
	lda S_CHECK_COLLISION::tmp_pos_left
	and #%11110000
	add #$10
	cmp S_CHECK_COLLISION::tmp_pos_right
	bpl @NOCOLLISION
	inx
	jsr S_GET_ISBLOCK
	beq @NOCOLLISION
	lda #%0100							; 右上
	ora S_CHECK_COLLISION::collision_pos
	sta S_CHECK_COLLISION::collision_pos
@NOCOLLISION:
	rts  ; -----------------------------

;* -----------------------------------------------------------------------------
;* 以下，上下左右座標修正
;* -----------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; 右へ座標修正（左に衝突）
; ------------------------------------------------------------------------------

S_FIX_L_COLLISION:
	lda move_amount_sum
	add S_CHECK_COLLISION::start_x
	and #%00001111
	cmp #$04
	bmi @SKIP1
	lda #$00
@SKIP1:
	sta mario_pixel_speed

	; fix L over
	lda mario_posx
	bmi @SKIP_FIX_L_OVER
	cmp mario_pixel_speed
	bpl @SKIP_FIX_L_OVER
	lda mario_posx
	sta mario_pixel_speed
@SKIP_FIX_L_OVER:

	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 左へ座標修正（右に衝突）
; ------------------------------------------------------------------------------

S_FIX_R_COLLISION:
	lda move_amount_sum
	add S_CHECK_COLLISION::start_x
	add S_CHECK_COLLISION::width
	cnn
	and #%00001111
	cmp #$04
	bmi @SKIP1
	lda #$00
@SKIP1:
	sta mario_pixel_speed

	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 下へ座標修正（上に衝突）
; ------------------------------------------------------------------------------

S_FIX_UP_COLLISION:
	lda #$00
	sta ver_speed
	sta ver_pos_fix_val

	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 上へ座標修正（下に衝突）
; ------------------------------------------------------------------------------

S_FIX_GROUND_COLLISION:
	ldx #$00
	lda ver_speed
	bmi @END
	beq @RESET_FIX_VAL
	lda mario_posy
	add S_CHECK_COLLISION::start_y
	add S_CHECK_COLLISION::height
	cnn
	and #%00001111
	sta ver_speed
	stx mario_isfly
@RESET_FIX_VAL:
	stx ver_pos_fix_val
@END:
	jsr S_RESET_PARAM_JUMP
	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 引数の座標のブロック判定
; 引数：X, YレジスタにブロックのX, Y座標
; 破壊：Aレジスタ（X, Y破壊しない）
; 戻り値：無し
; ------------------------------------------------------------------------------

S_GET_ISBLOCK:
	lda S_CHECK_COLLISION::move_amount_disp
	cpx #$10
	bmi @NOINCDISP
	eor #%00000001						; +1する→下位1bit変化
@NOINCDISP:
	and #%00000001
	add #$04
	sta addr_upper
	tya
	lsft4
	sta addr_lower
	txa
	and #%00001111
	ora addr_lower
	sta addr_lower
	sty S_CHECK_COLLISION::tmp1
	ldy #$00
	lda (addr_lower), y
	ldy S_CHECK_COLLISION::tmp1
	; ブロックにあたり判定があるか
	cmp #$00
	beq @NOCOLLISION
	lda #$01
	rts  ; -----------------------------
@NOCOLLISION:
	lda #$00
	rts  ; -----------------------------


; ------------------------------------------------------------------------------
; 仮座標やブロック座標、左端修正を行う
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_GET_TMP_POS:
	lda mario_x_direction
	bne @SKIP_FIX_OVER_L
	lda mario_posx
	bmi @SKIP_FIX_OVER_L
	cmp mario_pixel_speed				; subの代わり poxX - speed >= 0
	bpl @SKIP_FIX_OVER_L
	sta mario_pixel_speed				; 左端修正
@SKIP_FIX_OVER_L:
	lda move_amount_sum
	add S_CHECK_COLLISION::start_x
	ldx mario_x_direction				; 分岐用
	bne @R
	sub mario_pixel_speed
	sta S_CHECK_COLLISION::tmp_pos_left
	bcs @STORE_MOVE_AMOUNT
	ldx move_amount_disp
	dex
	stx S_CHECK_COLLISION::move_amount_disp
	jmp @STORE_MOVE_AMOUNT
@R:
	add mario_pixel_speed
	sta S_CHECK_COLLISION::tmp_pos_left
	bcc @STORE_MOVE_AMOUNT
	ldx move_amount_disp
	inx
	stx S_CHECK_COLLISION::move_amount_disp
@STORE_MOVE_AMOUNT:
	lda S_CHECK_COLLISION::tmp_pos_left		; 以前のtmp_posXと同じ
	rsft4
	sta S_CHECK_COLLISION::tmp_block_pos_left

	lda S_CHECK_COLLISION::tmp_pos_left
	add S_CHECK_COLLISION::width
	sub #$01
	sta S_CHECK_COLLISION::tmp_pos_right
	rsft4
	sta S_CHECK_COLLISION::tmp_block_pos_right

	lda mario_posy
	add ver_speed
	add ver_pos_fix_val
	add S_CHECK_COLLISION::start_y
	sta S_CHECK_COLLISION::tmp_pos_top
	rsft4
	sta S_CHECK_COLLISION::tmp_block_pos_top

	lda S_CHECK_COLLISION::tmp_pos_top
	add S_CHECK_COLLISION::height
	sta S_CHECK_COLLISION::tmp_pos_bottom
	rsft4
	sta S_CHECK_COLLISION::tmp_block_pos_bottom

	rts  ; -----------------------------
