		list 		p=PIC18f8722 
		#include 	P18F8722.INC
		extern		Timer_process
SODEM10MS	equ		.12500	
PRG		code				
;Cau hinh Timer0	
		global	Timer0_init
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
		movlw	high (-SODEM10MS)	;nap lai so dem
		movwf	TMR0H
		movlw	low (-SODEM10MS)
		movwf	TMR0L
		bsf	T0CON,TMR0ON		;cho phep dem
		return
;Chuong trinh phuc vu ngat quang Timer0
		global	Timer0_isr
Timer0_isr
		rcall	Timer0_reset
		rcall	Timer_process
		return
		end
		