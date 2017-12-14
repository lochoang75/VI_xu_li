;=====================================;
; Name: Tn02.asm
; Project: Xuat so dem 8 bit ra led.
; Thoi gian tang so dem la 500 ms.
; Author: CE-CSE-HCMUT
; Creation Date: 07/08/2014
;======================================;
		list 		p=PIC18f8722
		#include 	p18f8722.inc
		#define 	LED 	LATD
		#define 	LED_IO 	TRISD
		#define 	NUTNHAN PORTA,RA5
		#define 	NUT_IO 	TRISA,RA5
CONFIG OSC = HS, WDT = OFF, LVP = OFF

; Dau chuong trinh
		code 	0
		goto 	start
; Vung du lieu RAM
		udata
	
chieu 	res 	.1
TANG 	equ 	0
dem 	res 	1
dem1a 	res 	1
dem1b 	res 	1
; Vung bat dau code
PRG 	code
start 	call 	init
; chuong trinh chinh
main 	incf 	LED
		call 	delay200ms
		bra		main 		; lap lai sau moi giay
		btfsc 	NUTNHAN 	; cho den khi RA5 duoc nhan 
		bra 	main1 		; khong nhan thi tiep tuc dem
		btg 	chieu,TANG 	; toggle doi chieu dem
nha 	btfss 	PORTA,RA5 	; chi doi khi RA5 duoc nhan 
		bra 	nha
; Kiem tra chieu de diem tang hay giam gia tri LED
main1 	btfsc 	chieu,TANG 	; bit0=0: dem tang 
		bra 	main2
		incf 	LED
		bra 	main3
main2 	decf 	LED 		; bit0=1: dem giam 
main3 	rcall 	delay200ms
		bra main
; Ham khoi dong ban dau
init 		
		movlw 	H'0F' 		; chon RA5 là digital
		movwf 	ADCON1
		bsf 	NUT_IO 		; RA5 là ngõ nnap
		clrf 	LED_IO
		clrf 	LED
		return
; Ham lam tre 1000T (vi FOSC=10MHz thì T=0.4µs,1000T=400µs)
delay
		movlw 	.249
		movwf 	dem
		nop 
lap1
		nop
		decfsz 	dem
		bra 	lap1
		return
; Ham lam tre 200ms = 500 x 400µs = 2 x 250 x 400µs
delay200ms
		movlw 	.2
		movwf 	dem1a
lap2
		movlw 	.250 	; vong lap ngoai (2 lan)
		movwf 	dem1b
lap3
		call 	delay 	; vong lap trong (250 lan)
		decfsz 	dem1b
		bra 	lap3 	; ket thuc vong lap trong
		decfsz 	dem1a
		bra 	lap2 	; ket thuc vong lap ngoai
		return
	end