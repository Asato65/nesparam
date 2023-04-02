; ------------------------------------------------------------------------------
; NMIでパレットデータをバッファからVRAMへストアする
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_STORE_PLT_TO_BUFF:
		ldx #$00
		ldy #$00
@STORE_LOOP:
		lda plt_addr_arr, x				; アドレスセット
		sta PPU_ADDRESS
		inx
		lda plt_addr_arr, x
		sta PPU_ADDRESS
		inx
		lda plt_arr, y					; パレットデータセット
		sta PPU_ACCESS

		iny
		cpy #$08
		bne @STORE_LOOP
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; VRAMにマップをストアする
; 引数無し
; A, Xレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_STORE_MAPOBJ_VRAM:
		ldx #$00
@LOOP1:
		lda map_data_arr, x
		sta PPU_ADDRESS
		inx
		lda map_data_arr, x
		sta PPU_ADDRESS
		inx

		lda map_data_arr, x
		sta PPU_ACCESS
		inx
		lda map_data_arr, x
		sta PPU_ACCESS
		inx

		cpx #$0f*2*4					; *4はinxを一回のループ中に4回行うから
		bne @LOOP1
		rts  ; -------------------------