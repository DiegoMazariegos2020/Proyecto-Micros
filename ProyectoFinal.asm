
;*******************************************************************************
;                                                                              *
;    Filename:           Proyecto Final                                        *
;    Date:               11/11/20                                              *
;    File Version:       Progresiva                                            *
;    Author:             Diego Sebastián Mazariegos Guzmán                     *
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
ADC_3	     RES 1
ADC_4	     RES 1
ADC1_H       RES 1
ADC2_H       RES 1
D_20ms       RES 1
D2_20ms      RES 1 
D_100us      RES 1
D2_100us     RES 1
D_4          RES 1
D_4_2	     RES 1
D_ADC        RES 1
VA_ADC1      RES 1
VA_ADC2      RES 1
DELAY        RES 1
DU_CY1	     RES 1
DU_CY2	     RES 1
	
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
    
    ;CONFIGURACIÓN ADCON1
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
	
    START
	CALL    CONF_IO
	CALL    CONF_ADC
	;CALL CONF_PWM
	
	BANKSEL VAL_ADC
	CLRF    VAL_ADC1
	CLRF    VAL_ADC2
	
	MOVLW   .10
	MOVWF   DELAY
	
	GOTO    LOOP
	
    LOOP
	BTFSC   PORTA, RA7
	GOTO    MOS_VALS_ACTS
	BCF     PORTC, RC0
	
	CLRF    ADRESH
	CALL    D_INICIO
	BANKSEL ADCON0
	MOVLW   B'01011001'
	MOVWF   ADCON0
	BSF     ADCON0, GO
	BTFSC   ADCON0, GO
	GOTO    $-1
	
	MOVF    ADRES, 0
	MOVWF   VAL_ADC
	MOVWF   PORTB
	
	;--------------------SEPARACIÓN-----------------------------------------
	
	CLRF    ADRESH
	CALL    D_INICIO
	BANKSEL ADCON0
	MOVLW   B'01011101'
	MOVWF   ADCON0
	BSF     ADCON0, GO
	BTFSC   ADCON0, GO
	GOTO    $-1
	
	MOVF    ADRESH, 0
	MOVWF   VAL_ADC2
	MOVWF   PORTD
	
	GOTO    LOOP
	
;---------------------------SEPARACIÓN------------------------------------------
	
MOS_VALS_ACTS
	BANKSEL PORTA
	BTFSC  ´PORTA, RA4
	GOTO    $-1
	BSF     PORTC, RC0
	
	MOVF    VAL_ADC2, 0
	MOVWF   PORTD 
	
	MOVF    VAL_ADC1, 0
	MOVWF   PORTB
	
	BTFSC   PORTA, RA6
	GOTO    LOOP
	GOTO    MOS_VALS_ACTS
	
    ;CONF_PWM
	;BANKSEL T2CON
	;MOVLW   B'00000111'
	;MOVWF   T2CON
	
	;BANKSEL PR2
	;MOVLW   .156
	;MOVWF   PR2
	
	;BANKSEL TRISC
	;MOVLW   B'00000000'
	;MOVWF   TRISC
	
	;CONFI CCP1CON
	;BANKSEL CCP1CON
	;BSF     CCP1CON,  3
	;BSF     CCP1CON,  2
	;BCF     CCP1CON,  1
	;BCF     CCP1CON,  0
	
	;CONFI CCP2CON
	;BANKSEL CCP2CON
	;BSF     CCP2CON, 3
	;BSF     CCP2CON, 2
	
	;RETURN
	
CONFIG_IO
	BANKSEL  ANSEL
	CLRF     ANSEL
	COMF     ANSEL
	
	BANKSEL  TRISA
	MOVLW    B'11111100'
	MOVWF    TRISA
	CLRF     TRISC
	CLRF     TRISB
	CLRF     TRISD
	CLRF     TRISE
	COMF     TRISE
	
	BANKSEL  PORTA
	CLRF     PORTA
	CLRF     PORTC
	CLRF     PORTB
	CLRF     PORTD
	RETURN
	
	CONF_ADC
	BANKSEL  ADCON1
	MOVLW    B'00000000'
	MOVWF    ADCON1
	
	RETURN
	
	D_INICIO
	DECFSZ   DELAY
	GOTO     $-1
	MOVLW    .10
	MOVWF    DELAY
	RETURN
	
PUSH:
    MOVWF        W_T
    SWAPF        STATUS, W
    MOVWF        STATUS_T
ISR:
    BTFSS        INTCON, T0IF
    GOTO         POP
    MOVLW        .10
    MOVWF        TMR0
    BCF          INTCON, T0IF
    GOTO         PWM_1
    
BACK1:
    GOTO         PWM_2
    GOTO         POP
    
BACK2:
    GOTO         POP
    
PWM_1
    DECFSZ       DU_CY1,    1
    GOTO         BACK1
    GOTO         DUTY
    
PWM_2
    DECFSZ       DU_CY2,    1
    GOTO         BACK2
    GOTO         DUTY2
    
DUTY:
    BCF          PORTD,  RD2
    MOVWF        .1
    MOVWF        DU_CY1
    DECFSZ       D_20ms,    1
    GOTO         BACK1
    GOTO         PWM
    
PWM:
    BSF          PORTD, RD2
    MOVLW        .200
    SUBWF        ADC_1,  0
    BTFSS        STATUS, C
    GOTO         RA_2
    MOVLW        .2
    MOVWF        DU_CY1
    MOVLW        .38
    MOVWF        D_20ms
    GOTO         BACK1
    
RA_2:
    MOVLW        .150
    SUBWF        ADC_1,  0
    BTFSS        STATUS, C
    GOTO         RA_3
    MOVLW        .3
    MOVWF        DU_CY1
    MOVLW        .37
    MOVWF        D_20ms
    GOTO         BACK1
    
RA_3:
    MOVLW        .100
    SUBWF        ADC_1,  0
    BTFSS        STATUS, C
    GOTO         RA_4
    MOVLW        .4
    MOVWF        DU_CY1
    MOVLW        .36
    MOVWF        D_20ms
    GOTO         BACK1
    
RA_4:
    MOVLW        .50
    SUBWF        ADC,    0
    BTFSS        STATUS, C
    GOTO         RA_5
    MOVLW        .5
    MOVWF        DU_CY1
    MOVLW        .35
    MOVWF        D_20ms
    GOTO         BACK1
    
RA_5:
    MOVLW        .6
    MOVWF        DU_CY1
    MOVLW        .34
    MOVWF        D_20ms
    GOTO         BACK1
    
DUTY2:
    BCF          PORTD, RD3
    MOVLW        .1
    MOVWF        DU_CY2
    DECFSZ       D_20ms,    1
    GOTO         BACK2
    GOTO         PWM2
    
PWM2:
    BSF          PORTD,  RD3
    MOVLW        .200
    SUBWF        ADC_2,  0
    BTFSS        STATUS, C
    GOTO         RA_2_2
    MOVLW        .6
    MOVWF        DU_CY2
    MOVLW        .34
    MOVWF        D2_20ms
    GOTO         BACK2
    
RA_2_2:
    MOVLW        .150
    SUBWF        ADC_2,  0
    BTFSS        STATUS, C
    GOTO         RA_3_2
    MOVLW        .5
    MOVWF        DU_CY2
    MOVLW        .35
    MOVWF        D_20ms
    GOTO         BACK2
    
RA_3_2:
    MOVLW        .100
    SUBWF        ADC_2,  0
    BTFSS        STATUS, C
    GOTO         RA_4_2
    MOVLW        .4
    MOVWF        DU_CY2
    MOVLW        .36
    MOVWF        D2_20ms
    GOTO         BACK2
    
RA_4_2:
    MOVLW        .50
    SUBWF        ADC_2,  0
    BTFSS        STATUS, C
    GOTO         RA_5_2
    MOVLW        .3
    MOVWF        DU_CY2
    MOVLW        .37
    MOVWF        D2_20ms
    GOTO         BACK2
    
RA_5_2:
    MOVLW        .2
    MOVWF        DU_CY2
    MOVLW        .38
    MOVWF        D2_20ms
    
    
	
	END
