.scope MARIO_ANIME_INDEX
		STOP = $00
		ANIME = $01*2
		BRAKE = $04*2
		JUMP = $05*2
.endscope

.scope MARIO_WALK_ANIME_INDEX
		ANIME1 = MARIO_ANIME_INDEX::ANIME
		ANIME2 = MARIO_ANIME_INDEX::ANIME+02
		ANIME3 = MARIO_ANIME_INDEX::ANIME+04
.endscope


; ------------------------------------------------------------------------------
; マリオの座標、アニメーションをストア
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_STORE_MARIO:
		; X座標
		lda mario_pixel_speed
		ldx mario_x_direction			; 分岐用
		bne	@SKIP_CNN
		cnn
@SKIP_CNN:
		add mario_posx
		cmp #MARIO_MAX_POSX
		bmi @NOSCROLL					; スクロールするかの分岐
		beq @NOSCROLL
		sec
		sbc #MARIO_MAX_POSX
		jsr S_SCROLL_MAP				; スクロール、Aレジスタ引数
		lda #MARIO_MAX_POSX
@NOSCROLL:
		sta mario_posx

		lda mario_face_direction		; 顔の向きで分岐
		beq @L

		lda mario_posx					; X座標ストア、右に進んでるとき
		sta CHR_BUFFER::MARIO_POSX
		sta CHR_BUFFER::MARIO_POSX+$8
		add #$08
		sta CHR_BUFFER::MARIO_POSX+$4
		sta CHR_BUFFER::MARIO_POSX+$c
		clc
		bcc @END_STORE_POSX				; 強制ジャンプ
@L:
		lda mario_posx					; X座標ストア、左に進んでるとき
		sta CHR_BUFFER::MARIO_POSX+$4
		sta CHR_BUFFER::MARIO_POSX+$c
		add #$08
		sta CHR_BUFFER::MARIO_POSX
		sta CHR_BUFFER::MARIO_POSX+$8
@END_STORE_POSX:
		lda mario_face_direction		; マリオの方向を顔の方向で変える
		eor #$01
		clc
		ror
		ror
		ror
		sta CHR_BUFFER::MARIO_ATTR
		sta CHR_BUFFER::MARIO_ATTR+$4
		sta CHR_BUFFER::MARIO_ATTR+$8
		sta CHR_BUFFER::MARIO_ATTR+$c

		; Y座標
		lda mario_posy
		;cmp #$c0						; 床のあたり判定（一時）
		;bmi @NOCOLLISION
		;beq @NOCOLLISION
		;ldx #$c0
		;jsr S_RESET_PARAM_JUMP
		;lda #$c0
@NOCOLLISION:
		;sta mario_posy

		sta CHR_BUFFER::MARIO_POSY		; Y座標セット
		sta CHR_BUFFER::MARIO_POSY+$4
		add #$08
		sta CHR_BUFFER::MARIO_POSY+$8
		sta CHR_BUFFER::MARIO_POSY+$c

		; アニメーション
		lda mario_isfly
		beq @GROUND
		ldx #MARIO_ANIME_INDEX::JUMP	; ジャンプ
		jsr S_STORE_MARIO_TILE
		rts  ; -------------------------
@GROUND:								; 床
		lda mario_speed_L
		ora mario_speed_R
		beq @STOP						; 速度0
		lda brake
		bne @BRAKE
		jsr S_CHANGE_WALK_ANIME
		lda mario_anime_counter			; 引数
		asl
		add #MARIO_WALK_ANIME_INDEX::ANIME1
		tax
		jsr S_STORE_MARIO_TILE
		rts  ; -------------------------
@STOP:									; 静止中
		ldx #MARIO_ANIME_INDEX::STOP
		jsr S_STORE_MARIO_TILE
		rts  ; -------------------------
@BRAKE:									; ブレーキ
		ldx #MARIO_ANIME_INDEX::BRAKE
		jsr S_STORE_MARIO_TILE
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; 歩き、ダッシュ時のアニメーション変更
; 引数無し
; A, Xレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_CHANGE_WALK_ANIME:
					; 2 * (5 - speed)

; if (mario_anime_timer < frame_counter || frame_counter < mario_anime_timer - mario_anime_speed) {
; 	mario_anime_timer = frame_counter
; }
; if (mario_anime_timer == frame_counter) {
; 	// キャラクター変更
; }

; anime_timer 10
; anime_speed 4
; frame_counter
; 	0 -> 10
; 	6 -> 6
; 	10 -> 14 anime
; 	11 -> 10

		; if (mario_anime_timer < frame_counter || frame_counter + mario_anime_speed < mario_anime_timer) {
		; 	mario_anime_timer = frame_counter
		; }

		ldx mario_anime_timer
		beq @SKIP1
		dex
		stx mario_anime_timer
		rts  ; -------------------------
@SKIP1:
		lda #$04
		sub mario_pixel_speed
		sta mario_anime_timer
		sta mario_anime_speed

		ldx mario_anime_counter
		inx
		cpx #$03
		bne @SKIP2
		ldx #$00
@SKIP2:
		stx mario_anime_counter
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; マリオのタイルをスプライトバッファに保存
; 引数 Xレジスタ：ANIME_ARRのインデックス
; A, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_STORE_MARIO_TILE:
		lda MARIO_ANIME_ARR, x
		sta addr_lower
		lda MARIO_ANIME_ARR+1, x
		sta addr_upper
		ldy #$00
		lda (addr_lower), y
		sta CHR_BUFFER::MARIO_CHIP
		iny
		lda (addr_lower), y
		sta CHR_BUFFER::MARIO_CHIP+$4
		iny
		lda (addr_lower), y
		sta CHR_BUFFER::MARIO_CHIP+$8
		iny
		lda (addr_lower), y
		sta CHR_BUFFER::MARIO_CHIP+$c
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; マリオオブジェクトデータ
; ------------------------------------------------------------------------------

MARIO_STOP:
		.byte $00, $01, $02, $03

MARIO_ANIME1:
		.byte $04, $05, $06, $07

MARIO_ANIME2:
		.byte $08, $09, $0a, $0b

MARIO_ANIME3:
		.byte $0c, $0d, $0e, $0f

MARIO_JUMP:
		.byte $10, $11, $12, $13

MARIO_BRAKE:
		.byte $14, $15, $16, $17

MARIO_ANIME_ARR:
		.word MARIO_STOP
		.word MARIO_ANIME1, MARIO_ANIME2, MARIO_ANIME3
		.word MARIO_BRAKE
		.word MARIO_JUMP