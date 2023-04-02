; ----- ゼロページ -----
tmp1						= $00
tmp2						= $01
tmp3						= $02

plt_vram_upper				= $03

addr_lower					= $05
addr_upper					= $06

; コントローラー
con_player1					= $07
con_player1_prev			= $08
con_player1_pushstart		= $09
con_player2					= $0a
con_player2_prev			= $0b
con_player2_pushstart		= $0c

; DRAWMAP
map_addr_lower				= $0d
map_addr_upper				= $0e
map_vaddr_upper				= $0f
map_vaddr_lower				= $10
main_disp					= $11		; メインスクリーン
map_scroll					= $12		; マップX座標
map_scroll_prev				= $13
map_buff_lower				= $14		; ram_posx_cnt
map_buff_upper				= $15		; (ram_posx_lpcnt & 01H + 4H) = 04H/05H
obj_posx					= $16
obj_posy					= $17
obj_chip					= $18		; 600Hのバッファで使われるチップ番号
obj_num						= $19
ram_posx_cnt				= $1a
ram_posx_lpcnt				= $1b
ef_cnt						= $1c
ram_posx					= $1d
ram_posy					= $1e
map_loop_y					= $1f

; movechr
mario_speed_L				= $20
mario_speed_R				= $21
mario_speed_tmp				= $22
check_con_btn				= $23
brake						= $24
mario_x_direction			= $25
mario_face_direction		= $26
mario_subpixel_speed		= $27
mario_pixel_speed			= $28
mario_speed_remainder		= $29
move_amount_sum				= $2a
move_amount_disp			= $2b

ver_pos_origin				= $2e		; ジャンプ開始時の位置
ver_speed					= $30		; 速度
ver_force_decimal_part		= $31		; 現在の加速度
ver_force_fall				= $32		; 降下時の加速度
ver_speed_decimal_part		= $33		; 加速度の増加値
ver_pos_decimal_part		= $34		; 累積計算での補正値

mario_posx = $35
mario_posy = $36
mario_isfly = $37

mario_speed_x				= $38		; 未使用

mario_anime_counter			= $39
mario_anime_timer			= $3a
mario_isjump				= $3b
mario_isend_brake			= $3c
flagA						= $3d
mario_anime_speed			= $3e

game_timer_bcd1				= $3f		; 3Byte確保、1が最上位
game_timer_bcd2				= $40
game_timer_bcd3				= $41
timer_update_flag			= $42
pause_flag					= $43

sound_ch1_num				= $44
sound_ch1_counter			= $45
sound_ch1_num_prev			= $46
sound_ch1_frame_cnt	= $47

cannot_control				= $48		; ポーズ音が鳴っている時動けないようにする、死んだ時などにも使える
is_collision_up				= $49
ver_pos_fix_val				= $4a		; 補正値

order_chk_collision			= $4b		; 当たり判定のチェックする順番


; カウンター（動作チェック用）
nmi_counter					= $f0		; NMIに入ったらとりあえずインクリメント
frame_counter				= $f1		; 画面更新をしたときだけインクリメント

; フラグ
isend_main					= $f2		; メインルーチン終了フラグ


; ----- 通常RAM -----

plt_arr						= $0600		; 8H Byte
map_data_arr				= $0610		; 8*F=78H Byte
plt_addr_arr				= $0690		; 10H Byte


; キャラクターバッファ
.scope CHR_BUFFER
	START					= $0300
	SPR0_POSY				= $0300		; 0番スプライト
	SPR0_CHIP				= $0301		; マリオチップ番号
	SPR0_ATTR				= $0302		; マリオ属性
	SPR0_POSX				= $0303		; マリオX座標
	MARIO_POSY				= $0304		; マリオY座標
	MARIO_CHIP				= $0305		; マリオチップ番号
	MARIO_ATTR				= $0306		; マリオ属性
	MARIO_POSX				= $0307		; マリオX座標
.endscope


; ----- I/Oポート -----
PPU_SET1					= $2000
PPU_SET2					= $2001
PPU_STATUS					= $2002
PPU_SCROLL					= $2005
PPU_ADDRESS 				= $2006
PPU_ACCESS					= $2007

SOUND_CH1_1					= $4000		; Duty(2)|時間カウンタ|音響変化|ボリューム(4)
SOUND_CH1_2					= $4001		; 周波数変化|変化速度(3)|変化方向|変化範囲(3)
SOUND_CH1_3					= $4002		; 周波数下位
SOUND_CH1_4					= $4003		; 再生時間(5)|周波数上位(3)
SOUND_CH2_1					= $4004
SOUND_CH2_2					= $4005
SOUND_CH2_3					= $4006
SOUND_CH2_4					= $4007
PPU_DMA						= $4014
SOUND_CHANNEL				= $4015		; 未使用(3)|DPCM|ノイズ|三角波|CH2|CH1
CON1_PORT					= $4016
CON2_PORT					= $4017