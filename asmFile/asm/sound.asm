S_INIT_SOUND:
	lda SOUND_CHANNEL
	ora #%00000001
	sta SOUND_CHANNEL
	lda #%10011111
	sta SOUND_CH1_1						; Duty50%(2)、ループ無し、音響固定、ボリューム最大(4)
	lda #%00000000
	sta SOUND_CH1_2						; 周波数変化なし（bit7）、他は設定せず
	rts  ; -----------------------------

S_SOUND:
	jsr S_INIT_SOUND
	; サウンド番号取得
	lda sound_ch1_num
	bne @SOUND_NUM_N0
	sta sound_ch1_num_prev
	rts  ; -----------------------------
@SOUND_NUM_N0:
	cmp sound_ch1_num_prev
	beq @SOUND_INIT_SKIP
	sta sound_ch1_num_prev
	lda #$00
	sta sound_ch1_counter
	lda frame_counter
	sta sound_ch1_frame_cnt
	lda #%10111111
	sta SOUND_CH1_1
@SOUND_INIT_SKIP:
	lda frame_counter
	cmp sound_ch1_frame_cnt
	beq @CHANGE_SOUND
	rts  ; -----------------------------
@CHANGE_SOUND:
	ldx sound_ch1_num					; フレームカウンタの更新
	dex
	ldy sound_ch1_counter
	ldarr SOUND_TIME					; SOUND_TIME[num][cnt]
	bne @SKIP_SOUND_END
	lda #$00
	sta sound_ch1_counter
	sta sound_ch1_num
	sta SOUND_CH1_3
	sta SOUND_CH1_4
	lda #%10110000
	sta SOUND_CH1_1
@SKIP_SOUND_END:
	add frame_counter
	sta sound_ch1_frame_cnt

	ldx sound_ch1_num					; 周波数下位8bitの設定
	dex
	ldy sound_ch1_counter
	ldarr SOUND_ADDR_LOWER
	sta SOUND_CH1_3

	ldx sound_ch1_num					; 音の長さ（bit0-4）、周波数上位3bit（bit5-7）の設定
	dex
	ldy sound_ch1_counter
	ldarr SOUND_ADDR_UPPER
	sta SOUND_CH1_4

	ldx sound_ch1_num
	dex
	inc sound_ch1_counter

	rts  ; -----------------------------
