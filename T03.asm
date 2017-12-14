;===================================================
; Chuong trinh: Interrupt.asm
; Noi dung: Su dung nut nhan RB0 qua INT0.
;===================================================
	list		p=PIC18F8722
	#include	p18f8722.inc
	CONFIG	OSC = HS, WDT = OFF, LVP = OFF
	code 	H'0000'
	goto 	start
	org		0x08
	goto	isr_high
	org		0x18
	goto	isr_low
	#define	LED		LATD
	#define	LED_IO	TRISD
	#define	NUTRB0	PORTB,RB0
	#define	NUTRB0_IO	TRISB,RB0
;vung du lieu
	udata_acs
idx		res		.1
idx2		res		.1
maxidx	equ		.4 ;Thay doi gia tri dem
buffer	res		.4	;thay doi kich thuoc so bien dem duoc
dem		res		.1
dem1a	res		.1
dem1b	res		.1
demngoai	res	.1
so_q1	res		.1
;vung code
PRG		code
start	rcall	init;init data
		rcall	init_T0;init timer0
main	bra		main
init
	movlw	H'0F'
	movwf	ADCON1
	clrf	LED_IO
	bsf		NUTRB0_IO
	clrf	idx
	clrf	dem1a
	clrf	dem1b
	clrf	dem
	clrf	demngoai
	clrf	so_q1
	clrf	idx2
	rcall 	xuat_led
	return
init_T0
	bsf		RCON,IPEN
	bcf		INTCON,INT0IF
	bsf		INTCON,INT0IE
	bsf		INTCON,GIEH
	return
xuat_led
	movlw	upper dulieu
	movwf	TBLPTRU
	movlw	high dulieu
	movwf	TBLPTRH
	movlw	low dulieu
	movwf	TBLPTRL
	movf	idx,w
	incf	WREG
trabang
	TBLRD*+
	decfsz	WREG
	bra		trabang
	movf	TABLAT,W
	movwf	LED
	rcall	inc_idx
	return
dulieu	db	H'00',H'C3',H'FF',H'C3';dem nhu bai tap lam them 1
dulieu2	db	H'81',H'E7',H'E7',H'81'
dulieu3 db	H'00',H'C0',H'F0',H'FC',H'7F',H'1F',H'07',H'01'
dulieu4	db	H'80',H'E0',H'F8',H'FE',H'3F',H'0F',H'03',H'00'
rom2ram1
	movlw	upper dulieu
	movwf	TBLPTRU
	movlw	high dulieu
	movwf	TBLPTRH
	movlw	low dulieu
	movwf	TBLPTRL
	lfsr	FSR0,buffer
	movlw	maxidx
	rcall	chep
	rcall	xuat_led3
	return
xuat_led3
	lfsr	FSR1,buffer
	movf	idx,W
	movf	PLUSW1,W
	movwf	LED
	rcall	inc_idx2
	return
chep
	TBLRD*+
	movff	TABLAT,POSTINC0
	decfsz	WREG
	bra		chep
	return
rom2ram2
	movlw	upper dulieu2
	movwf	TBLPTRU
	movlw	high dulieu2
	movwf	TBLPTRH
	movlw	low dulieu2
	movwf	TBLPTRL
	lfsr	FSR0,buffer
	movlw	maxidx
	rcall	chep
	rcall	xuat_led2
	return
xuat_led2
	lfsr	FSR1,buffer
	movf	idx,W
	movf	PLUSW1,W
	movwf	LED
	rcall	inc_idx
	return
doi_q1
	tstfsz	so_q1
	bra		q1_2
q1_1
	rcall	rom2ram1
	incf	so_q1
	return
q1_2
	rcall	rom2ram2
	clrf	so_q1
	return
	
delay1000T
	movlw	.249
	movwf	dem
	nop
lap
	nop
	decfsz	dem
	bra		lap
	return
delay500ms
	movwf	demngoai
	movlw	.5
	movwf	dem1a
lap1
	movlw	.250
	movwf	dem1b
lap2
	rcall	delay1000T
	decfsz	dem1b
	bra 	lap2
	decfsz	dem1a
	bra		lap1
	return	
inc_idx
	incf	idx
	movlw	maxidx
	cpfslt	idx
	clrf	idx
	return
inc_idx2
	incf	idx2
	movlw	maxidx
	cpfslt	idx2
	clrf	idx2
	return
isr_high
	bcf		INTCON,INT0IF
	rcall	doi_q1
	;rcall	delay500ms
	retfie
isr_low
	retfie
end


