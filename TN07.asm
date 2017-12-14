		list		p=PIC18f8722
		#include	p18f8722.inc
		#include	"LCD.inc"
		#include	"Serial.inc"
		CONFIG	OSC = HS, WDT = OFF, LVP = OFF
		#define		LED		LATD
		#define		LED_IO	TRISD
		#define		NUT		PORTA,RA5
		#define		NUT_IO	TRISA,RA5
		code 0
		goto	start
		org		0x08
		goto	high_isr
		org		0x18
		goto	low_isr

		udata_acs
row		res		.1
col		res		.1
dl		res		.1

PRG		code

start	rcall	init
		rcall	Lcd_init
		rcall	Serial_init
main
		setf	LATD
		btfsc	NUT
		bra		main
		rcall	Truyen
wait	btfss	NUT
		bra 	wait
		bra		main

init	movlw	H'0F'
		movwf	ADCON1
		clrf	LED
		clrf	LED_IO
		bsf		NUT_IO
		clrf	row
		movlw	.16
		movwf	col
		clrf	dl
		clrf	rc_char
		movlw	'1'
		movwf	tx_char
		return
xuat_lcd
		movff		row,lcd_row
		movff		col,lcd_col
		rcall		Lcd_gotoxy
		movff		dl,lcd_wr
		rcall		Lcd_putc
		return
global	Serial_process
Serial_process
		movff		RCREG1,dl
		movlw		.1
		movwf		row
		rcall		xuat_lcd
		;movff		rc_char, LED
		return
global	Rcerr_process
Rcerr_process
		setf		LED
		return
Truyen
		clrf		row
		rcall		inc_col
		movff		tx_char,dl
		rcall		xuat_lcd
		rcall		Send_char
	;	setf		LATD
		incf		tx_char

		return
inc_col
		incf	col
		movlw	.16
		cpfslt	col
		clrf	col
		return
high_isr
		clrf		LATD
		rcall		Serial_isr
		retfie
low_isr
		retfie
		end
