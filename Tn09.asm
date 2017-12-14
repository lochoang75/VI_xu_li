	list 		p=PIC18f8722
	#include	P18F8722.INC
	CONFIG	OSC=HS,WDT=OFF,LVP=OFF

	#define	NUT			PORTA,RA5
	#define	NUT_IO		TRISA,RA5
	#define	PWMOUT_IO	TRISC,RC2
	#define	PWMOUT		PORTC,RC2
	#define	LED			LATD,LATD0
	#define	NUTRB0		PORTB,RB0
	#define	NUTRB0_IO	TRISB,RB0
	code	H'00000'
	goto	start
	org		H'08'
	goto	isr_high
	org		H'18'
	goto	isr_low
	udata_acs
PWM_CFG		equ	H'0C'
T2_CFG		equ	H'05'
PR2_VAL		equ	.249
DUTY8_VAL	equ	.100
DUTY8_FULL	equ .250
stt			res	.1
PRG	code
start
	rcall	init
	rcall	init0_init
	rcall	Pwm_init
main
;	clrf	CCPR1L
;	bcf		CCP1CON,CCP1X
;	bcf		CCP1CON,CCP1Y

	btfss	PWMOUT
	clrf	LATD
wait
	btfss	PWMOUT
	bra		wait
	setf	LATD	
	bra		main
setLed
	setf	LATD
	btfss	PWMOUT
	return
	bra		setLed
init
	movlw	H'0F'
	movwf	ADCON1
	bsf		NUT_IO
	clrf	TRISD
	clrf	stt
	bsf		NUTRB0_IO
	return
init0_init	
	bsf	RCON,IPEN	;cho phep uu tien
	bcf	INTCON,INT0IF	;xoa co ngat IF
	bsf	INTCON,INT0IE	;cho phep ngat
	bsf	INTCON,GIEH	;cho phep ngat uu tien cao
	return
Pwm_init
	bcf		PWMOUT_IO
	movlw	PWM_CFG
	movwf	CCP1CON
	movlw	T2_CFG
	movwf	T2CON
	movlw	PR2_VAL
	movwf	PR2
	movlw	DUTY8_VAL
	movwf	CCPR1L
	bsf		CCP1CON,CCP1X
	bcf		CCP1CON,CCP1Y
	return
incst
	incf	stt
	movlw	.3
	cpfslt	stt
	clrf	stt
	return
isr_Rb0
	movlw	.0
	cpfsgt	stt
	bra		stt0
	movlw	.1
	cpfsgt	stt
	bra		stt1	
stt2
	movlw	H'FA'
	movwf	CCPR1L
	bcf		CCP1CON,CCP1X
	bcf		CCP1CON,CCP1Y	
	return
stt0
	clrf	CCPR1L
	bcf		CCP1CON,CCP1X
	bcf		CCP1CON,CCP1Y
	return
stt1
	movlw	DUTY8_VAL
	movwf	CCPR1L
	bsf		CCP1CON,CCP1X
	bcf		CCP1CON,CCP1Y
	return	
isr_high
	bcf		INTCON,INT0IF
	rcall	incst
	rcall	isr_Rb0
	retfie
isr_low	
	retfie
	end