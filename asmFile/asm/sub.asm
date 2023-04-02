; ------------------------------------------------------------------------------
; コントローラー取得
; 引数無し
; A, Xレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

S_GET_CON:
		lda con_player1					; 更新する前のコントローラーの状態を保存
		sta con_player1_prev
		lda con_player2
		sta con_player2_prev

		ldx #$01						; コントローラー初期化
		stx CON1_PORT
		dex
		stx CON1_PORT

		ldx #$08
@GET_CON1_PORT:
		lda CON1_PORT
		and #%00000011
		cmp #$01						; A + 0xFF, Aレジスタが1のときキャリーが発生
		rol con_player1
		dex
		bne @GET_CON1_PORT

		ldx #$08
@GET_CON2_PORT:
		lda CON2_PORT
		and #%00000011
		cmp #$01						; A + 0xFF, Aレジスタが1のときキャリーが発生
		rol con_player2
		dex
		bne @GET_CON2_PORT

		lda con_player1_prev
		eor #$ff
		and con_player1
		sta con_player1_pushstart

		lda con_player2_prev
		eor #$ff
		and con_player2
		sta con_player2_pushstart

		rts  ; -------------------------


; ------------------------------------------------------------------------------
; スクロール座標変更、マップ描画
; 引数：Aレジスタ（スクロールするピクセル数）
; A, Xレジスタ破壊
; 戻り値なし
; ------------------------------------------------------------------------------

S_SCROLL_MAP:
		; 座標変更
		add map_scroll					; スクロール座標
		sta map_scroll
		; マップの更新
		and #%00001111					; 上位4ビットをマスク
		cmp mario_pixel_speed
		bpl @SKIP_UPDATE_MAP
		jsr S_DRAW_ADDMAP				; マップを一列更新
		jsr S_TRANSFAR_OBJDATA_TOBUFFER
		jsr S_TRANSFAR_PLT_TOBUFFER
@SKIP_UPDATE_MAP:
		lda map_scroll_prev				; メインとなる画面の選択
		bpl @SKIP_CHANGE_MAINDISP
		lda map_scroll
		bmi @SKIP_CHANGE_MAINDISP
		ldx main_disp
		inx
		txa
		and #$01
		sta main_disp
@SKIP_CHANGE_MAINDISP:
		lda map_scroll
		sta map_scroll_prev
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; スクロール位置のセット
; NMI後などに使用
; 引数無し（スクロール位置を変更するならMAP_SCROLLにストアしておく）
; Aレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_SET_SCROLL:
		lda main_disp					; メイン画面セット
		ora #%10001000
		sta PPU_SET1

		lda map_scroll					; スクロール座標セット
		sta PPU_SCROLL
		lda #$00
		sta PPU_SCROLL
		rts  ; -------------------------
