	list		p=PIC18F8722
	#include	p18f8722.inc
	extern	Serial_process,Rcerr_process
#define	SSP_IN	TRISC,RC7
#define	SSP_OUT	TRISC,RC6
	udata_acs
	global	tx_char,rc_char
TX_CFG	equ	B'00100100'
RC_CFG	equ	B'10010000'
BAUDRATE	equ	.64
tx_char	res	.1
rc_char	res	.1
PRG	code
	global	Serial_init	
Serial_init
	bsf	SSP_IN		;ngo nhan du lieu noi tiep
	bcf	SSP_OUT		;ngo truyen du lieu noi tiep
	movlw	TX_CFG		;cau hinh truyen
	movwf	TXSTA1
	movlw	RC_CFG		;cau hinh nhan
	movwf	RCSTA1
	movlw	BAUDRATE	;toc do truyen/nhan
	movwf	SPBRG
	bsf	RCON,IPEN	;cho phep uu tien
	bsf	IPR1,RC1IP	;nhan uu tien cao
	bcf	PIR1,RC1IF	;xoa co ngat nhan
	bsf	PIE1,RC1IE	;cho phep ngat nhan
	bsf	INTCON,GIEH	;cho phep ngat toan cuc
	bsf	INTCON,GIEL
	return
;---------------------------------
; Truyen 1 ky tu
; I:	serial_char=ky tu can truyen
;---------------------------------
	global	Send_char
Send_char
	movf	tx_char,W
	movwf	TXREG1
send1	btfss	PIR1,TX1IF	;truyen xong TX1IF=1
	bra	send1
	return
;----------------------------------------------
;Serial_isr - Trinh phuc vu ngat giao tiep UART
; - Kiem tra co ngat nhan RCIF va xoa
; - Kiem tra nhan loi va xu ly
; - Goi trinh xu ly nhan Serial_process
;----------------------------------------------
RCERROR	equ	.6
	global	Serial_isr
Serial_isr
	btfss	PIR1,RC1IF
	return			;khong phai ngat nhan
	movlw	RCERROR		;kiem tra loi
	andwf	RCSTA1,W
	btfss	STATUS,Z
	bra		Rcv_error
	rcall	Serial_process
	return
Rcv_error	
	bcf	RCSTA1,CREN	;xoa loi
	bsf	RCSTA1,CREN
	rcall	Rcerr_process
	return
	end
	