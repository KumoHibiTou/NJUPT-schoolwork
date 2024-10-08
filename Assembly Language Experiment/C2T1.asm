.486

DATA SEGMENT USE16
	FLAG DB 0
    STR1 DB 30,?,30 DUP(?)
    STR2 DB 30,?,30 DUP(?)
    
	HITID DB 'INPUT YOUR ID:$'
	HITPASS DB'INPUT YOUR PASSWORD:$'
	HITWRONG DB'INPUT IS WRONG'
	WRONGLEN EQU $-HITWRONG
	MESG DB 'WELCOME'
	MESGLEN EQU $-MESG
	SDT DB 'Login:'
	SDTLEN EQU $-SDT
	ID DB 'ABCDEFG';ID DATA
	IDLEN EQU $-ID
    PASSWORD DB '111111';PASSWORD DATA
    PASSLEN EQU $-PASSWORD
    
DATA ENDS

CODE SEGMENT USE16
    ASSUME CS:CODE,DS:DATA,ES:DATA
    
BEG:
    MOV AX,DATA
    MOV DS,AX
    MOV ES,AX
    MOV AX,0003H
    INT 10H
    MOV AX,1301H
    MOV BH,0
    MOV BL,01110001B
    MOV CX,SDTLEN
    MOV DH,0
    MOV DL,(80-SDTLEN)/2
    MOV BP, OFFSET SDT
    INT 10H
    CALL ENT
    MOV AH,9
    MOV DX,OFFSET HITID
    INT 21H
    MOV AH,0AH
	MOV DX,OFFSET STR1
	INT 21H
	CALL ENT
	MOV AH,9
    MOV DX,OFFSET HITPASS
    INT 21H
    MOV SI,0
    LEA BX,STR2+2
AGAIN:
	MOV AH,07H
	INT 21H
	CMP AL,0DH
	JZ TYPE_END
	CMP AL,0
	JZ AGAIN
	CMP AL,08H
	JZ BACKSPACE
	CALL EXPSD
	JMP AGAIN

BACKSPACE:
	CMP SI,0
	JZ AGAIN
	MOV BYTE PTR [BX+SI],0
	DEC SI
	CALL DEL
	JMP AGAIN
		
TYPE_END:
	MOV BX,SI
	MOV STR2+1,BL
	MOV CL,STR1+1
	MOV CH,0
	CMP CX,IDLEN
	JNZ WRONG
	MOV SI,OFFSET STR1+2
	MOV DI,OFFSET ID
	MOV FLAG,0
	CALL COMPARE
	CMP FLAG,1
	JNZ WRONG
	MOV CL,STR2+1
	MOV CH,0
	CMP CX,PASSLEN
	JNZ WRONG
	MOV SI,OFFSET STR2+2
	MOV DI,OFFSET PASSWORD
	MOV FLAG,0
	CALL COMPARE
	CMP FLAG,1
	JNZ WRONG
	JZ WELCOME

WRONG:
	CALL ENT
	MOV AH,03H
    MOV BH,0
    INT 10H
	MOV AX,1301H
    MOV BH,0
    MOV BL,11110101B
    MOV CX,WRONGLEN
    MOV DL,(80-WRONGLEN)/2
    MOV BP, OFFSET HITWRONG
    INT 10H
    JMP EXIT		
	
WELCOME:
	CALL ENT
	MOV AH,03H
	MOV BH,0
	INT 10H
	MOV AX,1301H
	MOV BH,0
	MOV BL,00000010B
    MOV CX,MESGLEN
    MOV DL,(80-MESGLEN)/2
    MOV BP, OFFSET MESG
    INT 10H
    JMP EXIT

EXIT:
	MOV AH,4CH
	INT 21H
	
DEL PROC
	MOV DL,08H
	MOV AH,02H
	INT 21H
	MOV DL,0H
	MOV AH,02H
	INT 21H
	MOV DL,08H
	MOV AH,02H
	INT 21H
	RET
DEL ENDP
	
ENT PROC;换行代码
	MOV AH,2
	MOV DL,0DH
	INT 21H
	MOV AH,2
	MOV DL,0AH
	INT 21H
	RET
ENT ENDP
	
EXPSD PROC;加密输入
	
	MOV [BX+SI],AL
	INC SI
	MOV DL,'*';表示成*
	MOV AH,02H
	INT 21H
	RET
EXPSD ENDP

COMPARE PROC
	REPE CMPSB
	JNZ OUT_CMP
	MOV FLAG,1
OUT_CMP:
	RET
COMPARE ENDP
	
CODE ENDS
    END BEG

