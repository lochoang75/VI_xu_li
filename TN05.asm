	list	p=PIC18f8722
	#include	p18f8722.inc
	#include	"LCD.inc"
	CONFIG	OSC = HS, WDT = OFF, LVP = OFF

;#define	LED	LAT
;#define	LED_IO	TRISB
#define	KEY_IO	TRISB
#define	ALLCOL	PORTB
#define	ALLROW	LATB


#define	COL1	PORTB,RB0
#define	COL2	PORTB,RB1
#define	COL3	PORTB,RB2
#define	COL4	PORTB,RB3
#define	ROW1	LATB,RB4
#define	ROW2	LATB,RB5
#define	ROW3	LATB,RB6
#define	ROW4	LATB,RB7
sodem	equ	.12500

#define	MAXIDX	.4

	code	H'00000'
	goto	start
	;org	H'08'
	;goto	isr_high
	org	H'18'
	goto	isr_low
;
	udata_acs
KeyReg	res	.1
row_idx	res	.1
row	res	.1
key res	.1
key_code	res	.1
scan_code	res	.1
dem1a	res		.1
dem1b	res		.1
dem		res		.1
hang	res		.1
cot		res		.1
idx		res		.1
tem		res		.1

PRG	code
start
	rcall	init
	rcall	Lcd_init
	rcall	Timer0_init
main
	bcf	ROW1	;hoac ALLROW=B'11101111'
	bcf	ROW2
	bcf	ROW3
	bcf	ROW4
main1
	bra	main1

init
	movlw	H'0F'	;Digital input
	movwf	ADCON1
	movlw	H'0F'	;Sinh vien xac dinh gia tri XX
	movwf	KEY_IO	;cau hinh keyboard
;	clrf	LED_IO	
 ; 	clrf	LED
	movlw	.1
	movwf	hang
	movlw	.7
	movwf	cot
	clrf	tem
	clrf	TRISD
	;khoi dong cac bien can thiet
	return
Getscancode
	movf	row_idx,w
	incf	WREG
	dcfsnz	WREG
	bra		getrow1
	dcfsnz	WREG
	bra		getrow2
	dcfsnz	WREG
	bra		getrow3
getrow4
	movlw	H'7F'
	bra		getend
getrow3
	movlw	H'BF'
	bra		getend
getrow2
	movlw	H'DF'
	bra		getend
getrow1
	movlw	H'EF'
getend
	movwf	scan_code
	return
Getkey
	movf	ALLCOL,W
	movwf	key
	clrf	key_code
	btfss	key,0
	bra		Getkeyend
	incf	key_code
	btfss	key,1
	bra		Getkeyend
	incf	key_code
	btfss	key,2
	bra		Getkeyend
	incf	key_code
	btfss	key,3
	bra		Getkeyend
	setf	key_code
	return
Getkeyend
	movf	row_idx,W
	rlncf	WREG
	rlncf	WREG
	addwf	key_code
	return
Inc_rowidx
	incf	row_idx
	movlw	MAXIDX
	cpfslt	row_idx
	clrf	row_idx
	return
Keycode_process
	rcall	xuat_lcd
	return
delay
		movlw	.249
		movwf	dem
		nop
lap1		
		nop		
		decfsz	dem
		bra	lap1
		return	
delay500ms	
		movlw	.5		
		movwf	dem1a		
lap2		
		movlw	.250		
		movwf	dem1b		
lap3		
		rcall	delay		
		decfsz	dem1b			
		bra 	lap3		
		decfsz	dem1a		
		bra 	lap2		
		return		
Timer0_init
		bsf	RCON,IPEN		;su dung uu tien
		bcf	INTCON2,TMR0IP		;Timer0 uu tien thap
		bsf	INTCON,TMR0IE		;cho phep ngat Timer0
		bsf	INTCON,GIEH		;cho phep ngat uu tien cao
		bsf	INTCON,GIEL		;cho phep ngat uu tien thap
		clrf	T0CON			;dem 16 bit, prescaler=2
		rcall	Timer0_reset
		return
;
Timer0_reset
		bcf	INTCON,TMR0IF		;xoa co ngat
		bcf	T0CON,TMR0ON		;cam dem
		movlw	HIGH(-sodem)	;nap lai so dem
		movwf	TMR0H
		movlw	LOW(-sodem)
		movwf	TMR0L
		bsf	T0CON,TMR0ON		;cho phep dem
		return
;Chuong trinh phuc vu ngat quang Timer0
isr_low
		;rcall	Getkey
		rcall	Timer_process
		rcall	Timer0_reset
		retfie
Timer_process
                                               
		rcall	Getscancode
		movwf	ALLROW
		rcall	Getkey
		rcall	Inc_rowidx
		incf	key_code,W
		tstfsz	WREG
		rcall	Keycode_process
		return
xuat_lcd
		movlw	.65
		addwf	key_code,0
		movwf	idx
		movff	hang,lcd_row
		movff	cot,lcd_col
		rcall	Lcd_gotoxy
		movff	idx,lcd_wr
		movff	key_code,LATD
		rcall	Lcd_putc
		;rcall	Lcd_cls
		return
end