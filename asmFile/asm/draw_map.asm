; ------------------------------------------------------------------------------
; マップを一列ずつ更新
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_DRAW_ADDMAP:
		; このルーチンの最初に地面、空をストアする
		jsr S_MAPRAM_INIT	; A, X, Yレジスタ破壊
@DRAW_ADDMAP_START:
		ldx obj_num	; これはCHK_EFまで破壊しては駄目
		; obj_posx, Yを求める
		lda MAP1_1_POS, x
		and #%11110000
		clc
		rsft4
		sta obj_posx
		lda MAP1_1_POS, x
		and #%00001111
		sta obj_posy
		; obj_chipを求める
		lda MAP1_1_OBJ, x
		sta obj_chip
		; obj_chipがEF, FFのときの分岐
		cmp #$ff	; FFで引っかかったときは何もしない
		bne @CHK_EF
		jsr S_CALC_PALETTE	; NMI用のデータ
		rts  ; -------------------------
@CHK_EF:	; EFで引っかかったとき→ef_cntとobj_numとram_posx_cnt（10HになったときはLPCNTも）だけインクリメントしたい
		cmp #$ef
		bne @STORE
		inc ef_cnt
		inc obj_num
		jsr S_CALC_PALETTE	; NMI用のデータ
		jsr S_INC_RAM_POSX_CNT
		rts  ; -------------------------
@STORE:
		; ram_posx_lpcnt = ef_cntでないときスキップ
		lda ram_posx_lpcnt
		cmp ef_cnt
		beq @LOOP	; BNE => ram_posx_cnt（10HになったときはLPCNTも）をインクリメントしたい
		jsr S_CALC_PALETTE	; NMI用のデータ
		jsr S_INC_RAM_POSX_CNT
		rts  ; -------------------------
@LOOP:
@CHK_X:
		lda ram_posx_cnt
		cmp obj_posx
		beq @CHK_Y	; Xが駄目->MAP_LOOP_Yを0にして終了，ram_posx_cntのインクリメント
		jsr S_CALC_PALETTE	; NMI用のデータ
		jsr S_INC_RAM_POSX_CNT
		rts  ; -------------------------
@CHK_Y:
		lda map_loop_y		; MAP_LOOP_Yからobj_posx，ram_posx_cntがobj_posyに等しくなければスキップ
		cmp obj_posy
		beq @CHK_POS_END	; この場合はMAP_LOOP_Yだけインクリメントしてloopの初めから
		jsr S_INC_MAP_LOOP_Y
		bne @GOTO_LOOP
		; 10になってたら
		jsr S_CALC_PALETTE	; NMI用のデータ
		rts  ; -------------------------
@GOTO_LOOP:
		bne @LOOP

@CHK_POS_END:
		; lda map_buff_lower
		; sta addr_lower
		; lda map_buff_upper
		; sta addr_upper

		lda obj_posy
		lsft4
		ora obj_posx
		sta addr_lower
		lda ram_posx_lpcnt
		and #%00000001
		add #$04
		sta addr_upper
		; obj_chipをADDR_LOWERの場所にストア
		lda obj_chip
		ldy #$00	; これはすぐ破壊してよし
		sta (addr_lower), y
		inc obj_num

		jsr S_CALC_PALETTE
		jsr S_INC_MAP_LOOP_Y
		beq @END
		jmp @DRAW_ADDMAP_START
@END:
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; ram_posx_cnt, ram_posx_lpcntのインクリメント，MAP_LOOP_Yの初期化
; 引数無し
; A, Xレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_INC_RAM_POSX_CNT:
		lda #$00
		sta map_loop_y	; セットで行う

		ldx ram_posx_cnt
		inx
		cpx #$10
		beq @INC_RAM_POSX_LPCNT
		stx ram_posx_cnt
		rts  ; -------------------------
@INC_RAM_POSX_LPCNT:
		ldx #$00
		stx ram_posx_cnt
		inc ram_posx_lpcnt
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; MAP_LOOP_Yをインクリメントし，10Hと比較した結果を返す
; 引数無し
; Aレジスタ破壊
; 戻り値ネガティブフラグ、ゼロフラグ
; ------------------------------------------------------------------------------

S_INC_MAP_LOOP_Y:
		inc map_loop_y
		lda map_loop_y
		cmp #$10
		bne @END
		lda #$00
		sta map_loop_y
@END:
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; RAM_LOWER/UPPERをセットする
; 引数無し
; Aレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_SET_RAM_ADDR:
		lda ram_posx_cnt
		sta map_buff_lower

		lda ram_posx_lpcnt
		and #%00000001
		sta map_vaddr_upper
		add #$04
		sta map_buff_upper

		rts  ; -------------------------


; ------------------------------------------------------------------------------
; マップを更新する行のRAMを初期化
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_MAPRAM_INIT:
		lda #SKY	; 初めは地面
		ldx #$00	; 画面上部分（タイム、スコア等の場所）も含めて更新している => 02でもOK
@LOOP:
		cpx #$0d	; 地面の数，変数で変えられるようにしたい
		bne @SKIP1
		lda #GROUND	; 空
@SKIP1:
		tay	; Aレジスタ退避
		lda ram_posx_cnt	; これはインクルード済み
		sta ram_posx
		txa
		lsft4
		ora ram_posx
		sta ram_posx
		lda ram_posx_lpcnt
		and #%00000001
		add #$04
		sta ram_posy
		tya	; Aレジスタ復旧
		ldy #$00
		sta (ram_posx), y
		inx
		cpx #$0f
		bne @LOOP

		rts  ; -------------------------


; ------------------------------------------------------------------------------
; NMIでストアするオブジェクトデータをバッファ（多分600H）に転送
; 引数無し
; A, X, Yレジスタ無し
; d0~d1使用
; 戻り値なし
; ------------------------------------------------------------------------------

.scope S_TRANSFAR_OBJDATA_TOBUFFER
	addr_lower = $d0
	addr_upper = $d1
.endscope

S_TRANSFAR_OBJDATA_TOBUFFER:
		lda map_buff_lower
	pha
	add #$20
		sta S_TRANSFAR_OBJDATA_TOBUFFER::addr_lower
	pla
	asl
	add #$80
		sta map_vaddr_lower				; X座標データ、Y座標はループで回す

		lda map_buff_upper
		sta S_TRANSFAR_OBJDATA_TOBUFFER::addr_upper
		lda map_vaddr_upper				; 0H or 1H
		asl
		asl								; 0H or 4H
		add #$20
		sta map_vaddr_upper				; 20H or 24H

		lda #$0d
		sta tmp1						; ループカウンタ
		ldx #$00
@LOOP1:
		ldy #$00
		lda (S_TRANSFAR_OBJDATA_TOBUFFER::addr_lower), y	; バッファデータ（0, A-Z）
		and #%00111111					; 0H, 41H~5BH =>  0H~1BH
		asl								; 0, A-Zに割り振られた16bitアドレスを拾ってくる
		tay
		lda OBJ_CHIP_MAP, y
		sta map_addr_lower				; 再利用
		iny
		lda OBJ_CHIP_MAP, y
		sta map_addr_upper				; 再利用


		; バッファに保存（2キャラクターデータ、2アドレス、2キャラクターデータ、2アドレス）
		lda map_vaddr_upper				; キャラクターのストア先アドレスをバッファに保存
		sta map_data_arr, x
		inx
		lda map_vaddr_lower
		sta map_data_arr, x
		inx

		ldy #$00
		lda (map_addr_lower), y			; ブロックのキャラクターデータ（4つ）が格納された配列を取得
		sta map_data_arr, x				; キャラクター1つ目
		inx
		iny
		lda (map_addr_lower), y
		sta map_data_arr, x
		inx

		lda map_vaddr_upper				; キャラクターのストア先アドレスをバッファに保存
		sta map_data_arr, x
		inx
		lda map_vaddr_lower
		add #$20
		sta map_data_arr, x
		inx

		iny
		lda (map_addr_lower), y			; キャラクター3つ目
		sta map_data_arr, x
		inx
		iny
		lda (map_addr_lower), y
		sta map_data_arr, x
		inx

		dec tmp1
		beq @END_SUB					; ループ終了

		lda S_TRANSFAR_OBJDATA_TOBUFFER::addr_lower
		add #$10
		sta S_TRANSFAR_OBJDATA_TOBUFFER::addr_lower
		lda map_vaddr_lower
		add #$40
		sta map_vaddr_lower
		bcc @SKIP_INC_UPPER
		inc map_vaddr_upper
@SKIP_INC_UPPER:
		jmp @LOOP1

@END_SUB:
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; RAM上のオブジェクトデータからパレットを計算する
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_CALC_PALETTE:
		jsr S_SET_RAM_ADDR

		lda map_buff_lower
		sta addr_lower
		lda map_buff_upper
		sta addr_upper

		ldx #$00	; インクリメント
@LOOP1:
		stx tmp1
		txa
		lsr	; 右シフト（/2）
		tax	; これは後に使うXレジスタの内容
		ldy #$00	; 固定，破壊OK
		lda (addr_lower), y
		and #%00110000
		rsft4
		pha	; 一時保存したAレジスタをスタックにきちんと保存（ここにパレットデータ）
		; シフトしてYレジスタにシフト量を入れる
		; xレジスタのbit0が0, N1のbit0が0（N1→X方向，Xレジスタ→Y方向）
		; XレジスタはもうAレジスタに入っている
		lda addr_lower
		and #%00000001
		sta tmp2
		lda tmp1
		and #%00000001
		asl
		ora tmp2
		tay	; 0~3でシフト量が入る（2倍して0, 2, 4, 6）
		bne @SKIP1
		pla
		clc
		bcc @SKIP3  ; 強制ジャンプ
@SKIP1:
		pla
@LOOP:
		asl
		asl
		dey
		bne @LOOP
		ora plt_arr, x
@SKIP3:
		sta plt_arr, x	; パレットデータをストア

		ldx tmp1

		lda addr_lower
		add #$10
		sta addr_lower

		inx
		cpx #$10
		beq @END
		jmp @LOOP1
@END:
		rts  ; -------------------------


; ------------------------------------------------------------------------------
; NMIでストアするパレットデータをバッファに転送
; 引数無し
; A, X, Yレジスタ破壊
; 戻り値無し
; ------------------------------------------------------------------------------

S_TRANSFAR_PLT_TOBUFFER:
		lda map_buff_lower
		sta addr_lower
		lda map_buff_upper
		sta addr_upper

		lda addr_upper
		cmp #$04
		bne @SKIP500
		lda #$23
		bne @SKIP1
@SKIP500:
		lda #$27
@SKIP1:
		sta plt_vram_upper

		ldx #$00
		ldy #$00
@LOOP1:
		lda addr_lower
		and #%00001110
		lsr	; 23c0の0を表す（下1ケタ）
		sta tmp1
		; 2桁目はループで回して求める
		; 3桁目はループのキャリー
		; 4桁目は画面1/2で切り替え
		txa
		asl
		asl
		asl
		ora tmp1
		add #$c0
		pha
		lda #$00
		add plt_vram_upper
		sta plt_vram_upper

		sta plt_addr_arr, y	; UPPER
		iny
		pla
		sta plt_addr_arr, y	; LOWER
		iny
		inx
		cpx #$08
		bne @LOOP1

		rts  ; -------------------------


; ------------------------------------------------------------------------------
; データ
; ------------------------------------------------------------------------------

OBJ_CHIP_MAP:
		.word OBJ_SKY	; 00
		.word $0000	; 41 A
		.word OBJ_BLOCK	; 42 B
		.word $0000	; 43 C
		.word $0000	; 44 D
		.word $0000	; 45 E
		.word $0000	; 46 F
		.word OBJ_GROUND	; 47 G
		.word $0000	; 48 H
		.word $0000	; 49 I
		.word $0000	; 4a J
		.word $0000	; 4b K
		.word $0000	; 4c L
		.word $0000	; 4d M
		.word $0000	; 4e N
		.word $0000	; 50 O
		.word $0000	; 51 P
		.word OBJ_QBLOCK	; 52 Q
		.word $0000	; 53 R
		.word $0000	; 54 S
		.word $0000	; 55 T
		.word $0000	; 56 U
		.word $0000	; 57 V
		.word $0000	; 58 W
		.word $0000	; 59 X
		.word $0000	; 5a Y
		.word $0000	; 5b Z

OBJ_SKY:
		.byte VSKY, VSKY, VSKY, VSKY

OBJ_GROUND:
		.byte VGROUND, VGROUND, VGROUND, VGROUND

OBJ_BLOCK:
		.byte VBLOCK1, VBLOCK2, VBLOCK1, VBLOCK2

OBJ_QBLOCK:
		.byte VQBLOCK1, VQBLOCK2, VQBLOCK3, VQBLOCK4