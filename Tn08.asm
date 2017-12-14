	list 		p=PIC18f8722
	#include	P18F8722.INC
	CONFIG	OSC=HS,WDT=OFF,LVP=OFF
	#include	"LCD.inc"
	#include	"Adc.inc"
	
#define	NUT	PORTA,RA5
#define	NUT_IO	TRISA,RA5
	code	0
	goto	start
	udata_acs
buffer	res		.8
PRG	code
start
	rcall	init
	rcall	Lcd_init
	rcall	Adc_init
	rcall	Intro
main	btfsc	NUT
	bra	main
	rcall	Adc_go
main1	btfss	NUT
	bra	main1
	bra	main
;	
init	bsf	NUT_IO
	return
;
adc_str	data	"AD conversion",0
Intro
	movlw	.0
	movwf	lcd_col
	movlw	.0
	movwf	lcd_row	
	rcall	Lcd_gotoxy
	rcall	docdata
	return
docdata
	movlw	upper adc_str
	movwf	TBLPTRU
	movlw	high adc_str
	movwf	TBLPTRH
	movlw	low adc_str
	movwf	TBLPTRL
	lfsr	FSR0,buffer
	rcall	Lcd_putram
	return	
	global	Adc_process
Adc_process
	;rcall	Intro
	gotoxy	.1,.11
	putmw	ad_res
	return
	end
		