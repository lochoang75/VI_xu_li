;===========================================;
; Khoi dong Timer0 dem 16 bit.
; De tinh thoi khoan tao ra boi Timer0, ta can biet mot so diem
; 	1. Tan so xung clock ngoai:	FOSC=10Mhz
; 	2. Thang dem truoc (prescaler):	prescaler=2
; 	3. So dem: 			n=12500
; thoi gian tao ra ngat tu Timer0:	t = (1/(FOSC/4))*prescaler*n
;			        	  = 10 ms
;===========================================;
		list 		p=PIC18f8722 
		#include 	P18F8722.INC
		CONFIG	OSC = HS, WDT = OFF, LVP = OFF
		#include	"Timer.inc"
		#include	"LCD.inc"
		#define	LED	LATD
		#define	LED_IO	TRISD
	
		code	0
		goto	start
		org	H'08'
		goto	isr_high
		org	H'18'
		goto	isr_low

		#define	FLAG_1S	flags,0		
;vung du lieu RAM
		udata_acs
SODEM1S		equ		.100
dem		res		.1
flags		res		.1
col			res		.1
row			res		.1
duli		res		.1
;vung chuong trinh ROM
PRG		code
;bat dau chuong trinh
start
	rcall	init
	rcall	Timer0_init
	rcall		init
	rcall		Lcd_init	
;chuong trinh chinh
main		
		movlw		.0
		movwf		lcd_row
		movlw		.0
		movwf		lcd_col
		movlw		.0
		movwf		col
		rcall		Lcd_gotoxy
		movlw		.33
		movwf		lcd_wr
		movlw		.33
		movwf		duli
		rcall		Lcd_putc
lap		btfss	FLAG_1S
		bra	lap
		bcf	INTCON,GIEH
		bcf	FLAG_1S
		bsf	INTCON,GIEH
		rcall	Lcd_cls
		;incf	lcd_col
		;movlw		.1
		;movwf		lcd_row
		rcall		inc_col
		movff		row,lcd_row
		movff		col,lcd_col
		rcall		Lcd_gotoxy
		incf		duli
		movff		duli,lcd_wr
		rcall		Lcd_putc	
		bra	lap

inc_col
		incf		col
		movlw		.16
		cpfseq		col
		return
		clrf		col
		incf		row
		movlw		.2
		cpfseq		row
		return
		clrf		row
		return		
		
;ham khoi dong ban dau
init	movlw	H'0F'
		movwf	ADCON1
		clrf	LED_IO
		movlw	SODEM1S
		movwf	dem
		clrf	LED
		bcf		FLAG_1S
		return
;Chuong trinh xu ly dinh ky cua Timer (10ms/lan)	
		global	Timer_process
Timer_process
		decfsz	dem
		return
		bsf	FLAG_1S
		movlw	SODEM1S
		movwf	dem
		return
;Phuc vu ngat uu tien thap	
isr_low	rcall	Timer0_isr
		retfie
isr_high
		retfie
		end