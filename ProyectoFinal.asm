
;*******************************************************************************
;                                                                              *
;    Filename:           Proyecto Final                                        *
;    Date:               11/11/20                                              *
;    File Version:       Progresiva                                            *
;    Author:             Diego Sebasti�n Mazariegos Guzm�n                     *
;    Company:            UVG                                                   *
;    Description:        Uso del PIC16F887 junto con servos para simular el    *
;                        funcionamiento de una cara de un robot.               *
;*******************************************************************************

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
GPR_VAR      UDATA
W_T          RES 1
STATUS_T     RES 1
ADC_1        RES 1
ADC_2        RES 1
ADC1_H       RES 1
ADC2_H       RES 1
D_100us      RES 1
D2_100us     RES 1
D_4          RES 1
D_4_2	     RES 1
D_ADC        RES 1

R_VE         CODE     0x0000
    GOTO     SETUP
    I_VE     CODE 0x0004
     
PUSH:
    MOVWF    W_T
    SWAPF    STATUS, W
    MOVWF    STATUS_T
    
ISR:
    BTFSS    INTCON, T0IF
    GOTO     POP
    MOVLW    .206
    MOVWF    TMR0
    BCF      INTCON, T0IF
    DECFSZ   D_100us
    GOTO     DEC_H
    GOTO     DEC_4
    
DECRE4:
    MOVLW    .100
    MOVWF    D_100ms
    DECFSZ   D_4,   1
    ;GOTO    POP
    GOTO     BATMAN_1
    GOTO     REASING
    
DECRE_H:
    DECFSZ   ADC1_H,  1
    GOTO     ADC_H
    GOTO     ADC_L
    
ADC_H:
    BANKSEL  PORTD
    BSF      PORTD, RD2
    ;GOTO    POP
    GOTO     BATMAN_1
    
ADC_L:
    MOVLW    .1
    MOVWF    ADC1_H
    BCF      PORTD, RD2
    ;GOTO    POP
    GOTO     BATMAN_1
    
REASIGN:
    MOVLW    .100
    MOVWF    D_100us
    MOVLW    .4
    MOVWF    D_4
    MOVLW    .19
    MOVWF    ADC1__H
    MOVF     ADC_P1,  W
    ADDWF    ADC1_H,  1
    ;GOTO    POP
    GOTO     BATMAN_1
    
BATMAN_1:
    DECFSZ   D2_100us,  1
    GOTO     DECRE_H2
    GOTO     D_4_2
    
D_4_2:
    MOVLW    .100
    MOVWF    D2_100us
    DECFSZ   D_4_2,  1
    GOTO     POP
    GOTO     REASIGN2
    
DECRE_H2:
    DECFSZ   ADC2_H,  1
    GOTO     ADC_H_2
    GOTO     ADC_L_2
    
ADC_H_2:
    BANKSEL  PORTD
    BSF      PORTD, RD3
    GOTO     POP
    
ADC_L_2:
    MOVLW    .1
    MOVWF    ADC2_H
    BCF      PORTD, RD3
    GOTO     POP
    
REASIGN2:
    MOVLW    .100
    MOVWF    D2_100us
    MOVLW    .4
    MOVWF    D_4_2
    MOVLW    .19
    MOVWF    ADC2_P2,  W
    ADDWF    ADC2_H,   1
    GOTO     POP
    
POP:
    SWAPF    STATUS_T,  W
    MOVWF    STATUS
    SWAPF    W_T, F
    SWAPF    W_T, W
    RETFIE
    
SETUP
    CALL     CONFIG_IO
    CALL     CONFIG_TIMER0
    
    ;ACTIVAR INTERRUPCIONES
    BSF      INTCON, T0IE
    BCF      INTCON, T0IF
    BSF      INTCON, GIE
    
    ;CONFIGURACI�N ADCON1
    BANKSEL  ADCON1
    MOVLW    B'00000000'
    MOVWF    ADCON1
    
    MOVLW    .100
    MOVWF    D_100us
    MOVLW    .4
    MOVWF    D_4
    
    GOTO     LOOP
    
LOOP
    ;CONFI ADC
    ;---------------------------------------------------------------------------
	CALL     D_INICIO
	CLRF     ADRESH
	BANKSEL  ADCON0
	MOVLW    B'01010001'
	MOVWF    ADCON0
	BSF      ADCON0, GO
	BTFSC    ADCON0, GO
	GOTO     $-1
	
	MOVF    ADRESH, 0
	MOVWF   ADC_P1
	BANKSEL STATUS
	BCF     STATUS,    C
	RRF     ADC_P1,    1
	BCF     STATUS,    C
	RRF     ADC_P1,    1
	BCF     STATUS,    C
	RRF     ADC_P1,    1
;-------------------------------------------------------------------------------
	CALL    D_INICIO
	CLRF    ADRESH
	BANKSEL ADCON0
	MOVLW   B'01010101'
	MOVWF   ADCON0
	BSF     ADCON0, GO
	BTFSC   ADCON0, GO
	GOTO    $-1
	MOVF    ADRESH, 0
	MOVWF   ADC_P2
	BANKSEL STATUS
	BCF     STATUS,    C
	RRF     ADC_P2,    1
	BCF     STATUS,    C
	RRF     ADC_P2,    1
	BCF     STATUS,    C
	RRF     ADC_P2,    1
	
	GOTO    LOOP
	
    CONFIG_IO
	BANKSEL TRISA
	CLRF    TRISA
	COMF    TRISA,     1
	CLRF    TRISE,    
	COMF    TRISE,     1
	CLRF    TRISB
	MOVLW   B'10001000'
	MOVWF   TRISC
	MOVLW   B'00000011'
	MOVWF   TRISD
	
	BANKSEL ANSEL
	MOVLW   B'11111111'
	MOVWF   ANSEL
	CLRF    ANSELH
	
	BANKSEL PORTA
	CLRF    PORTA
	CLRF    PORTB
	CLRF    PORTC
	CLRF    PORTD
	CLRF    PORTE
	
	RETURN
	
    CONFIG_TIMER0
	BANKSEL OPTION_REG
	BCF     OPTION_REG, T0CS
	BSF     OPTION_REG, PSA
	BCF     OPTION_REG, PS2
	BCF     OPTION_REG, PS1
	BCF     OPTION_REG, PS0
	BANKSEL TMR0
	MOVLW   .206
	MOVWF   TMR0
	BCF     INTCON, T0IF
	RETURN
	
    D_INCIO
	DECFSZ  D_ADC, 1
	GOTO    $-1
	MOVLW   .20
	MOVWF   D_ADC
	RETURN
	
	END
