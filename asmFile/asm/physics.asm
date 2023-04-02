PHYSICS:
		ldx ver_speed
		lda #$00
		sta tmp1  ; 累積計算の補正値
		lda ver_pos_decimal_part
		add ver_force_decimal_part
		sta ver_pos_decimal_part
		bcc @ENDIF1
		; オーバーフローしてたら
		lda #$00
		sta ver_pos_decimal_part
		inx
@ENDIF1:
		lda ver_speed_decimal_part
		add ver_force_decimal_part
		sta ver_speed_decimal_part
		bcc @SKIP2		; 繰り上がらなければスキップ
		lda #$00
		sta ver_speed_decimal_part
		inx
		cpx #DOWN_SPEED_LIMIT
		bmi @SKIP2
		lda ver_speed_decimal_part
		bmi @SKIP2
		ldx #DOWN_SPEED_LIMIT
		lda #$00
		sta ver_speed_decimal_part
@SKIP2:
		txa
		ldx #$00	; ゼロフラグを壊すので計算前に
		;add tmp1
		sta ver_speed
		bpl @STORE_JUMP_FLAG
		inx
@STORE_JUMP_FLAG:
		stx mario_isjump

		rts  ; -------------------------