	list 		p=PIC18f8722
	#include	P18F8722.INC
	CONFIG	OSC=HS,WDT=OFF,LVP=OFF
	#include	"Lcd.inc"
	
	
#define	NUT	PORTA,RA5
#define	NUT_IO	TRISA,RA5
	code	0
	goto	start
	org		0x18
	goto	isr_low
	org		0x08
	goto 	isr_high
	udata_acs
AD_CFG0	equ	h'01'
AD_CFG1	equ	h'0E'
AD_CFG2	equ	h'81'
ad_res	res	.2
row 	res .1
col		res	.1
PRG		code
start
	rcall	init
	rcall	Lcd_init
	rcall	Adc_init
	rcall	Intro
main	btfsc	NUT
	bra	main
	rcall	Adc_go
	bra	main
main1	btfss	NUT
	bra	main1
	bra	main
;	
init	bsf	NUT_IO
	return
Adc_init
	movlw	AD_CFG0	;chon kenh
	movwf	ADCON0
	movlw	AD_CFG1
	movwf	ADCON1
	movlw	AD_CFG2
	movwf	ADCON2
	bsf		RCON,IPEN
	bsf		IPR1,ADIP
	bsf		PIR1,ADIF
	bsf		PIE1,ADIE
	bsf		INTCON,GIEH
	bsf		INTCON,GIEL
	bsf		ADCON0,GO	
	return
;
Adc_go	bsf ADCON0,GO		;GO=1, bat dau qua trinh AD
Adc_wait btfsc ADCON0,DONE	;cho DONE=0, AD xong
		bra	 	Adc_wait
		movf	ADRESH,W		;doc ket qua cao
		movwf 	ad_res+1
		movf	ADRESL,W		;doc ket qua thap
		movwf 	ad_res
		rcall 	Adc_process
		return
adc_str	data	"AD conversion",.0
Intro	
	clrf row
	clrf col
	movff	row,lcd_row
	movff	col,lcd_col
	rcall	Lcd_gotoxy
	movlw	upper adc_str
	movwf	TBLPTRU		
	movlw	high adc_str
	movwf	TBLPTRH
	movlw	low adc_str
	movwf	TBLPTRL
	rcall	Lcd_putrom
	return		
	
Adc_process
	rcall	Intro
	movlw	.1
	movwf row
	movlw	.11
	movwf col
	movff	row,lcd_row
	movff	col,lcd_col
	rcall Lcd_gotoxy
	movff	ad_res+1,PRODH
	movff	ad_res,PRODL
	rcall Lcd_putw 
	return
Adc_isr
	btfss	PIR1,ADIF
	return
	movf	ADRESH,W		;doc ket qua cao
	movwf 	ad_res+1
	movf	ADRESL,W		;doc ket qua thap
	movwf 	ad_res
	rcall	Adc_process
	bsf		ADCON0,GO
	return
isr_low
	retfie
isr_high
	setf	LATD
	rcall	Adc_isr
	retfie
	end
		