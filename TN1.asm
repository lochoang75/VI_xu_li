;===================================================
; Chuong trinh: IO port.
; Noi dung: Su dung nut nhan RA5 de thay doi LED hien thi.
;	Ban dau, hien thi gia tri H'XX' ra LED va cho nhan nut RA5.
;	Khi nhan RA5, tang gia tri hien ra LED len 1.
;	Khi nha RA5 khong lam gi ca.
;===================================================
		list 		p=PIC18F8722
		#include 	p18f8722.inc
		CONFIG	OSC = HS, WDT = OFF, LVP = OFF
		#define LED 	LATD
		#define LED_IO	TRISD
		#define NUT		PORTA,RA5
		#define NUT_IO	TRISA,RA5
		code H'00000'
		goto start
;vung dinh nghia du lieu
		udata_acs
TRI_BD	equ H'00'
DEM		equ	H'10'
;vung dinh nghia cac chuong trinh con
PRG		code
start	rcall 	init
;chuong trinh chinh
main	btfsc	NUT
		bra		main
		rcall	xuat_led
recheck	btfss	NUT
		bra		recheck
		bra 	main
;khoi dong gia tri ban dau
init 	movlw	H'0f'
		movwf	ADCON1
		bsf		NUT_IO
		clrf	LED_IO
		movlw	TRI_BD
		movwf	LED
		return
xuat_led	incf	LED
			return
			endt