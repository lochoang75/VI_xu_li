;************************************************************************
;*	Module PIC18Lcd.asm: PICDEM PIC18 LCD interface.		*
;*	Author: Nguyen Xuan Minh, CE-CSE-HCMUT-VNU			*
;*	Filenames: 						  	*
;*	PIC18Lcd.asm (functions) 				  	*
;*	PIC18Lcd.inc (extern, MACRO)   			  		*
;*	Update: April 1 ,2016					  	*
;************************************************************************
	list p=PIC18F8722
	#include p18F8722.inc

#define	LCD_RS	lcd_mask,7		;=0:command,=1:data
#define	LCD_RW	lcd_mask,6		;=0:write,=1:read

#define	LCD_CS	LATA,RA2	    	; LCD chip select
#define	LCD_CS_TRIS	TRISA,RA2
#define	LCD_RST	LATF,RF6	    	; LCD reset
#define	LCD_RST_TRIS	TRISF,RF6

	GLOBAL	lcd_wr,lcd_row,lcd_col
D_LCD_DATA	udata_acs
lcd_dem	res	.1
lcd_dem1a	res	.1
lcd_dem1b	res	.1
SPI_temp	res	.1
lcd_wr		res	.1
lcd_mask 	res	.1
lcd_row		res	.1
lcd_col		res	.1
lcd_quo		res	.1
lcd_rem		res	.1
lcd_cnt		res	.1
dec_buf		res	.6
hex_buf		res	.2
;
DIVISOR	equ	.10
lcd_dslo	res	.1
lcd_dshi	res	.1
lcd_arlo	res	.1
lcd_arhi	res	.1
lcd_qolo	res	.1
lcd_qohi	res	.1

PRG	CODE
;---------------------------------------------------------------
;LCD Initialization routine
;---------------------------------------------------------------
	global Lcd_init
Lcd_init	
	bcf 	LCD_CS_TRIS
	bsf	LCD_CS
	clrf	lcd_mask
	bcf	LCD_RST_TRIS
	bcf	LCD_RST
	rcall	Delay40ms
	bsf	LCD_RST		;reset Serial latch
	rcall	SPI_init	
	rcall 	SPIPortA_init
	rcall	SPIPortB_init
	rcall	Delay40ms
	rcall	Delay40ms
	movlw	B'00111100' 	;0011NFxx
	movwf	lcd_wr
	rcall	i_write
	movlw	B'00001100' 	;Display off
	movwf	lcd_wr
	rcall	i_write
	movlw	B'00000001' 	;Display Clear
	movwf	lcd_wr
	rcall	i_write
	movlw	B'00000110' 	;Entry mode
	movwf	lcd_wr
	rcall	i_write
	return
;---------------------------------------------------
;Clear screen LCD
;---------------------------------------------------
	global 	Lcd_cls
Lcd_cls
	movlw	H'01'
	movwf	lcd_wr
	rcall	i_write
	rcall	LCDBusy
	return
;---------------------------------------------------
;LCD gotoxy
;---------------------------------------------------
	global Lcd_gotoxy
Lcd_gotoxy
	movf	lcd_col,W
	tstfsz	lcd_row
	bra	row2
row1	bra	rowend	
row2	movlw	H'40'
	addwf	lcd_col,W
rowend	bsf	WREG,7
	movwf	lcd_wr
	rcall	i_write
	return
;---------------------------------------------------
;Put a character to LCD
;---------------------------------------------------
	global 	Lcd_putc
Lcd_putc
	rcall	d_write
	rcall	LCDBusy	
	return
;-------------------------------------
;Chia so 16 bit cho 10 lay ket qua nguyen 16 bit va so du
;I:	PROD=so bi chia 16 bit
;O:	WREG=so du, PROD= ket qua
;-------------------------------------
w_divb	clrf	lcd_qohi
	clrf	lcd_qolo
w_divb1	tstfsz	PRODH
	bra	w_divb2
	movlw	DIVISOR-1
	cpfsgt	PRODL
	bra	w_divbend
w_divb2	rcall	find_ar
	bra	w_divb1
w_divbend	
	movf	PRODL,W
	movwf	lcd_rem
	movf	lcd_qohi,W
	movwf	PRODH
	movf	lcd_qolo,W
	movwf	PRODL
	movf	lcd_rem,W
	return
find_ar	clrf	lcd_dshi
	movlw	DIVISOR		;ds16=DIVISOR
	movwf	lcd_dslo
	clrf	lcd_arhi	;ar16=1
	clrf	lcd_arlo
	bsf	lcd_arlo,0
f_ar1	
	bcf	STATUS,C
	rlcf	lcd_dslo
	rlcf	lcd_dshi
	bc	f_arover3	;ds overflow
	bcf	STATUS,C
	rlcf	lcd_arlo
	rlcf	lcd_arhi
	bc	f_arover2	;ar overflow
	movf	PRODH,W
	cpfseq	lcd_dshi
	bra	f_ar2
	;lcd_dshi=PRODH:compare lo
	movf	PRODL,W
	cpfsgt	lcd_dslo
	bra	f_ar1		;shift again
	bra	f_arover1	;ds>dd:back 1 step then subtract
f_ar2	cpfsgt	lcd_dshi	;ds>dd
	bra	f_ar1
f_arover1	
	bcf	STATUS,C
f_arover2	
	rrcf	lcd_arhi
	rrcf	lcd_arlo
	bcf	STATUS,C
f_arover3	
	rrcf	lcd_dshi
	rrcf	lcd_dslo
	movf	lcd_dslo,W
	subwf	PRODL
	movf	lcd_dshi,W
	subwfb	PRODH
	movf	lcd_arlo,W
	addwf	lcd_qolo
	movf	lcd_arhi,W
	addwfc	lcd_qohi
	return
;-------------------------------------
;Tenth V = ad_res*50/1024
;I:	PROD=ad_res*50
;O:	WREG=so du, PROD= ket qua
;-------------------------------------
	global	Div1024
Div1024	clrf	lcd_qohi
	clrf	lcd_qolo
D10241	movlw	H'04'
	cpfslt	PRODH
	bra	D10242
	bra	D1024end
D10242	rcall	find_ar2
	bra	D10241
D1024end	
	movf	PRODL,W
	movwf	lcd_rem
	movf	lcd_qohi,W
	movwf	PRODH
	movf	lcd_qolo,W
	movwf	PRODL
	movf	lcd_rem,W
	return
find_ar2	
	clrf	lcd_dslo
	movlw	H'04'		;ds16=H'400'
	movwf	lcd_dshi
	clrf	lcd_arhi	;ar16=1
	clrf	lcd_arlo
	bsf	lcd_arlo,0
f_a21	bcf	STATUS,C
	rlcf	lcd_dslo
	rlcf	lcd_dshi
	bc	f_a2over3	;ds overflow
	bcf	STATUS,C
	rlcf	lcd_arlo
	rlcf	lcd_arhi
	bc	f_a2over2	;ar overflow
	movf	PRODH,W
	cpfseq	lcd_dshi
	bra	f_a22
	;lcd_dshi=PRODH:compare lo
	movf	PRODL,W
	cpfsgt	lcd_dslo
	bra	f_a21		;shift again
	bra	f_a2over1	;ds>dd:back 1 step then subtract
f_a22	cpfsgt	lcd_dshi	;ds>dd
	bra	f_a21
f_a2over1	
	bcf	STATUS,C
f_a2over2	
	rrcf	lcd_arhi
	rrcf	lcd_arlo
	bcf	STATUS,C
f_a2over3	
	rrcf	lcd_dshi
	rrcf	lcd_dslo
	movf	lcd_dslo,W
	subwf	PRODL
	movf	lcd_dshi,W
	subwfb	PRODH
	movf	lcd_arlo,W
	addwf	lcd_qolo
	movf	lcd_arhi,W
	addwfc	lcd_qohi
	return	
;-------------------------------------
;Convert word to decimal ascii
;I:	PROD=so 16 bit
;O:	dec_buf:ma ASCII 5 byte
;-------------------------------------
w2a	lfsr	FSR0,dec_buf+5
	clrf	POSTDEC0
	movlw	.5
	movwf	lcd_cnt
w2a1	rcall	w_divb
	addlw	'0'
	movwf	POSTDEC0
	decfsz	lcd_cnt
	bra	w2a1
	return
;-------------------------------------
;Lcd_putw: Put word in decimal to LCD
;I:	PROD=so 16 bit
;-------------------------------------
	global	Lcd_putw
Lcd_putw	
	rcall	w2a
	lfsr	FSR1,dec_buf
	rcall	Lcd_putram
	return
;-------------------------------------
;Chia 10 lay ket qua nguyen
;I:	WREG=so bi chia
;O:	WREG=so du
;-------------------------------------
b_div10
	movwf	lcd_quo
	clrf	lcd_rem
	movlw	8
	movwf	lcd_cnt
b_m1
	bcf	STATUS,C
	rlcf	lcd_quo
	rlcf	lcd_rem
	movlw	.10
	subwf	lcd_rem,W
	btfss	STATUS,C
	bra	b_m2
	bsf	lcd_quo,0
	movwf	lcd_rem
	bra	b_m3
b_m2
	bcf	lcd_quo,0
b_m3	
	decfsz	lcd_cnt
	bra	b_m1
	movf	lcd_quo,W
	return
;-------------------------------------
;Chia 10 lay du
;I:	WREG=so bi chia
;O:	WREG=so du
;-------------------------------------
b_mod10
	rcall	b_div10
	movf	lcd_rem,W
	return
;-------------------------------------------------
;Convert byte into RAM buffer with decimal point 
;	between 2 digit
;I:	WREG=so, FSR0=address of buffer
;O:	[FSR0]:so thap phan 2 digit co dau cham o giua
;-------------------------------------------------
	global	bcd2p
bcd2p	rcall	b_div10
	addlw	'0'
	movwf	POSTINC0
	movlw	'.'
	movwf	POSTINC0
	movf	lcd_rem,W
	addlw	'0'
	movwf	INDF0
	return
;-------------------------------------------------
;Convert byte into RAM buffer with 2 decimal digit
;I:	WREG=so, FSR0=address of buffer
;O:	[FSR0]:so thap phan 2 digit
;-------------------------------------------------
	global	bcd2d
bcd2d	rcall	b_div10
	addlw	'0'
	movwf	POSTINC0
	movf	lcd_rem,W
	addlw	'0'
	movwf	INDF0
	return
;-------------------------------------
;Convert byte to decimal ascii
;I:	WREG=so
;O:	dec_buf:ma ASCII 3 byte
;-------------------------------------
b2a	lfsr	FSR0,dec_buf+3
	clrf	POSTDEC0
	rcall	b_mod10
	addlw	'0'
	movwf	POSTDEC0
	movf	lcd_quo,W
	rcall	b_mod10
	addlw	'0'
	movwf	POSTDEC0
	movf	lcd_quo,W
	addlw	'0'
	movwf	INDF0
	return
;-------------------------------------
;Lcd_putb: Put byte in decimal to LCD
;I:	WREG=so
;-------------------------------------
	global	Lcd_putb
Lcd_putb	rcall	b2a
	lfsr	FSR1,dec_buf
	rcall	Lcd_putram
	return
;-------------------------------------
;Lcd_puth: Put byte in hexadecimal to LCD
;I:	WREG=so
;-------------------------------------
	GLOBAL 	Lcd_puth
Lcd_puth	
	movwf	hex_buf
	swapf	hex_buf,W
	rcall	h2a
	movwf	lcd_wr
	rcall	Lcd_putc
	movf	hex_buf,W
	rcall	h2a
	movwf	lcd_wr
	rcall	Lcd_putc
	return
	
h2a
	andlw	H'0F'
	movwf	hex_buf+1
	movlw	.9
	cpfsgt	hex_buf+1
	bra	h2a1
	movlw	'A'-.10
	bra	h2a2
h2a1	movlw	'0'
h2a2	addwf	hex_buf+1,W
	return
;-------------------------------------
;Lcd_putram: Put asciiz from ram to LCD
;I:	FSR1=address of asciiz string
;-------------------------------------
	global	Lcd_putram
Lcd_putram
	tstfsz	INDF1
	bra	putram1
	return
putram1	movf	POSTINC1,W
	movwf	lcd_wr
	rcall	Lcd_putc
	bra	Lcd_putram
;-------------------------------------
;Lcd_putrom: Put asciiz from rom to LCD
;I:	TBLPTR=address of asciiz string
;-------------------------------------
	global	Lcd_putrom
Lcd_putrom
	TBLRD*+
	tstfsz	TABLAT
	bra	putrom1
	return
putrom1	movf	TABLAT,W
	movwf	lcd_wr
	rcall	Lcd_putc
	bra	Lcd_putrom
;--------------------------------------------------
;Write data to LCD
;---------------------------------------------------
d_write	bcf	LCD_RW		
	bsf	LCD_RS
	rcall	Write_PortA	
	rcall	Write_PortB
	bsf	LCD_RW
	rcall	Write_PortA	
	clrf	lcd_mask
	rcall	Write_PortA
	rcall	Delay
	return
;---------------------------------------------------
;Write instrution to LCD
;---------------------------------------------------
i_write
	clrf	lcd_mask
	rcall	Write_PortA	
	rcall	Write_PortB
	bsf	LCD_RW
	rcall	Write_PortA	
	clrf	lcd_mask
	rcall	Write_PortA
	rcall	Delay
	return
;---------------------------------------------------
;Initialize SPI 
;---------------------------------------------------
	    global SPI_init
SPI_init
	bcf	TRISC,5
	bcf	TRISC,3
	movlw	0x22
	movwf	SSP1CON1
	bsf	SSP1STAT,CKE
	bcf	PIR1,SSP1IF
	return
;---------------------------------------------------
;Send character to SPI port
;---------------------------------------------------
SPI_send	
	movf	SPI_temp,W
	movwf	SSP1BUF
wait1	btfss	PIR1,SSP1IF
	bra	wait1
	bcf	PIR1,SSP1IF
	movf	SSP1BUF,W
	return
;---------------------------------------------------
;Initialize MCP923S17 PortA
;---------------------------------------------------
SPIPortA_init
	bcf	LCD_CS
	movlw	H'40'		;write command
	movwf	SPI_temp
	rcall	SPI_send
	movlw	0x00		;IODIRA
	movwf	SPI_temp
	rcall	SPI_send
	movlw	0x00		;all output
	movwf	SPI_temp
	rcall	SPI_send
	bsf	LCD_CS
	return
;---------------------------------------------------
;Initialize MCP923S17 PortB
;---------------------------------------------------
SPIPortB_init
	bcf	LCD_CS
	movlw	H'40'		;write command	
	movwf	SPI_temp
	rcall	SPI_send
	movlw	0x01		;IODIRB
	movwf	SPI_temp
	rcall	SPI_send
	movlw	0x00		;all output
	movwf	SPI_temp
	rcall	SPI_send
	bsf	LCD_CS
	return
;---------------------------------------------------
;Write to  MCP923S17 PortB
;---------------------------------------------------
Write_PortB
	bcf	LCD_CS
	movlw	H'40'		;write command	
	movwf	SPI_temp
	rcall	SPI_send
	movlw	0x13		;GPIOB
	movwf	SPI_temp
	rcall	SPI_send
	movf	lcd_wr,W
	movwf	SPI_temp
	rcall	SPI_send
	bsf	LCD_CS
	return
;---------------------------------------------------
;Write to  MCP923S17 PortA
;---------------------------------------------------
Write_PortA
	bcf	LCD_CS
	movlw	H'40'		;write command	
	movwf	SPI_temp
	rcall	SPI_send
	movlw	0x12		;GPIOB
	movwf	SPI_temp
	rcall	SPI_send
	movf	lcd_mask,W
	movwf	SPI_temp
	rcall	SPI_send
	bsf	LCD_CS
	return
;---------------------------------------------------
;LCD busy delay (400?s)
;---------------------------------------------------
LCDBusy
	rcall	Delay
	rcall	Delay
	rcall	Delay
	rcall	Delay
	return
;----------------------------------------
;Delay 1000T=400?s
;----------------------------------------
Delay
	movlw	.249
	movwf	lcd_dem
	nop
lap1	
	nop	
	decfsz	lcd_dem
	bra	lap1
	return	
;----------------------------------------
; Ham lam tre 40ms = 100 x 400?s 
;----------------------------------------
Delay40ms	
	movlw	.100
	movwf	lcd_dem1b
lap3	rcall	Delay
	decfsz	lcd_dem1b
	bra 	lap3
	return
	end