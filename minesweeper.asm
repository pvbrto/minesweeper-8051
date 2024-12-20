RS      EQU     P1.3
EN      EQU     P1.2

ORG 0000H
MOV TMOD,#22H
MOV TH0,#241
MOV TL0,#241
SETB TR0
MOV TH1,#241
MOV TL1,#241
SETB TR1
LJMP START

ORG 0030H

CAMPOMINADO:
DB "CAMPO MINADO"
DB 00H

APERTE0:
DB "APERTE "0""
DB 00H

LINHA1:
DB "     ****************"
DB 00H

LINHA2: 
DB "     ****************"
DB 00H

LIMPANDO:
DB " "
DB 00H

BOMBITA:
DB "."
DB 00H

PARABENS:
DB "      VOCE GANHOU =)"
DB 00H

PARABENS2:
DB "TENTATIVAS="

ORG 0100H

START:
MOV R2, #0H
MOV R4, #0H
MOV 40H, #'#' 
MOV 41H, #0H
MOV 42H, #'*'
MOV 43H, #09H
MOV 44H, #08H
MOV 45H, #07H
MOV 46H, #06H
MOV 47H, #05H
MOV 48H, #04H
MOV 49H, #03H
MOV 4AH, #02H
MOV 4BH, #01H
MOV R0, #50H

RESETBOMB:
MOV @R0, #0H
INC R0
CJNE R0, #60H, RESETBOMB
MOV R0, #60H

RESETBOMB2:
MOV @R0, #0H
INC R0
CJNE R0, #70H, RESETBOMB2

ACALL LCD_INIT
MOV A, #2H
ACALL POSICIONACURSOR
MOV DPTR, #CAMPOMINADO
ACALL ESCREVESTRINGROM
MOV A, #43H
ACALL POSICIONACURSOR
MOV DPTR, #APERTE0
ACALL ESCREVESTRINGROM
ACALL PLAY
JMP $

PLAY:
JB P2.0, PLAY
MOV R5, #4H
ACALL GERARBOMBAS
MOV A, 00H
ACALL POSICIONACURSOR
MOV DPTR, #LINHA1
ACALL ESCREVESTRINGROM
MOV A, 40H
ACALL POSICIONACURSOR
MOV DPTR, #LINHA2
ACALL ESCREVESTRINGROM
MOV R3, #32

ESCOLHA:
INC R4

LENDO:
MOV A, #40H
ACALL LEITURATECLADO
JNB F0, LENDO
MOV A, #40H
ADD A, R0
MOV R0, A
MOV A, @R0
MOV B, #10
MUL AB
MOV 7EH, A 
MOV R2, 7EH
CLR F0
ACALL DELAY2

LENDO2:
MOV A, #40H
ACALL LEITURATECLADO
JNB F0, LENDO2  
ADD A, R0
MOV R0, A
MOV A, @R0
ADD A, R2
MOV 7EH, A
CLR F0
ACALL DELAY2

LENDO3:
MOV A, #40H
ACALL LEITURATECLADO
JNB F0, LENDO3  
ADD A, R0
MOV R0, A
MOV A, @R0
CJNE A, #00H, SEGUNDAL
MOV 7FH, #00H
SJMP BREAKPOINT

SEGUNDAL:
MOV 7FH, #01H
MOV A, 7EH
ADD A, #40H
MOV 7EH, A

BREAKPOINT:
CLR F0
MOV A, 7EH
MOV R0, 7FH
CJNE R0, #00H, VARRE1
ADD A, #50H
SJMP CONTINUAR

VARRE1:
ADD A, #20H

CONTINUAR:
MOV R5, A
MOV R1, A
CJNE @R1, #01H, CELULASEMBOMBA
SJMP CELULACOMBOMBA

CELULASEMBOMBA:
MOV A, 7EH
ACALL POSICIONACURSOR
MOV DPTR, #LIMPANDO
ACALL ESCREVESTRINGROM
SJMP ANALISOU

CELULACOMBOMBA:
MOV A, 7EH
ACALL POSICIONACURSOR
MOV DPTR, #BOMBITA
ACALL ESCREVESTRINGROM

ANALISOU:
MOV A, R5
MOV R1, A
CJNE @R1, #01H, ESCOLHA
DEC R6
CJNE R6, #00H, REPETINDO
SJMP GANHOU

REPETINDO:
DJNZ R3, ESCOLHA

GANHOU:
ACALL CLEARDISPLAY
MOV A, #01H
ACALL POSICIONACURSOR
MOV DPTR, #PARABENS
ACALL ESCREVESTRINGROM
MOV A, #41H
ACALL POSICIONACURSOR
MOV DPTR, #PARABENS2
ACALL ESCREVESTRINGROM
MOV A, R4
MOV B, #10
DIV AB
ADD A, #30H
MOV R3, A
MOV R4, B
MOV A, #4DH
ACALL POSICIONACURSOR
MOV A, R3
ACALL SENDCHARACTER
MOV A, R4
ADD A, #30H
MOV R4, A
ACALL SENDCHARACTER
RET

GERARBOMBAS:
MOV A, #255
SUBB A, TL0
ADD A, #50H
MOV R0, A
MOV @R0, #1
MOV A, #255
SUBB A, TL1
ADD A, #61H
MOV R1, A
MOV @R1, #1
DJNZ R5, GERARBOMBAS
ACALL CLEARDISPLAY
MOV R1, #0H
MOV R0, #0H
MOV R6, #08H
RET

ESCREVESTRINGROM:
MOV R1, #00H

LOOP:
MOV A, R1
MOVC A,@A+DPTR
JZ FINISH2
ACALL SENDCHARACTER
INC R1
MOV A, R1
JMP LOOP

LEITURATECLADO:
MOV R0, #0
MOV P0, #0FFH	
CLR P0.0
CALL COLSCAN
JB F0, FINISH2
SETB P0.0
CLR P0.1
CALL COLSCAN
JB F0, FINISH2
SETB P0.1
CLR P0.2
CALL COLSCAN
JB F0, FINISH2
SETB P0.2
CLR P0.3
CALL COLSCAN
JB F0, FINISH2

FINISH2:
RET

COLSCAN:
JNB P0.4, GOTKEY
INC R0
JNB P0.5, GOTKEY
INC R0
JNB P0.6, GOTKEY
INC R0
RET

GOTKEY:
SETB F0
RET

LCD_INIT:
CLR RS	
CLR P1.7
CLR P1.6
SETB P1.5
CLR P1.4
SETB EN
CLR EN
CALL DELAY
SETB EN
CLR EN
SETB P1.7
SETB EN	
CLR EN
CALL DELAY
CLR P1.7
CLR P1.6
CLR P1.5
CLR P1.4
SETB EN
CLR EN
SETB P1.6
SETB P1.5
SETB EN
CLR EN
CALL DELAY
CLR P1.7
CLR P1.6
CLR P1.5
CLR P1.4
SETB EN
CLR EN
SETB P1.7
SETB P1.6
SETB P1.5
SETB P1.4
SETB EN
CLR EN
CALL DELAY
RET

SENDCHARACTER:
SETB RS
MOV C, ACC.7
MOV P1.7, C	
MOV C, ACC.6
MOV P1.6, C
MOV C, ACC.5
MOV P1.5, C
MOV C, ACC.4
MOV P1.4, C
SETB EN
CLR EN
MOV C, ACC.3
MOV P1.7, C
MOV C, ACC.2
MOV P1.6, C
MOV C, ACC.1
MOV P1.5, C
MOV C, ACC.0
MOV P1.4, C
SETB EN
CLR EN
CALL DELAY
CALL DELAY
RET

POSICIONACURSOR:
CLR RS	
SETB P1.7
MOV C, ACC.6
MOV P1.6, C
MOV C, ACC.5
MOV P1.5, C
MOV C, ACC.4
MOV P1.4, C
SETB EN
CLR EN
MOV C, ACC.3
MOV P1.7, C
MOV C, ACC.2
MOV P1.6, C
MOV C, ACC.1
MOV P1.5, C
MOV C, ACC.0
MOV P1.4, C
SETB EN
CLR EN
CALL DELAY
CALL DELAY
RET

RETORNACURSOR:
CLR RS	
CLR P1.7
CLR P1.6
CLR P1.5
CLR P1.4
SETB EN
CLR EN
CLR P1.7
CLR P1.6
SETB P1.5
SETB P1.4
SETB EN
CLR EN
CALL DELAY
RET

CLEARDISPLAY:
CLR RS	
CLR P1.7
CLR P1.6
CLR P1.5
CLR P1.4
SETB EN
CLR EN
CLR P1.7
CLR P1.6
CLR P1.5
SETB P1.4
SETB EN
CLR EN
CALL DELAY
RET

DELAY:
MOV R7, #50
DJNZ R7, $
RET

DELAY2:
MOV R7, #255
DJNZ R7, $
RET
