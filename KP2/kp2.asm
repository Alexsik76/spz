STSEG SEGMENT PARA STACK "STACK"
              DB 32 DUP(?)
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
        CR      EQU    13                             ;или EQU 0DH
        LF      EQU    10                             ;или EQU 0AH
        TAB     EQU    09                             ;или EQU 09H
        MESSTR1 DB     "Enter number: $"
        MESSERR DB     CR, LF, "Not number!$"
        SIGN    DB     0
        MULT10  DB     1
        BINVAL  DB     0
        ASCVAL  DB     ?
        TOMUL   DB     7
        RESMUL  DB     7 DUP('0')
        RESASC  DB     CR, LF, 6 DUP(' '), '$'
                NUMPAR LABEL    BYTE
        MAXLEN  DB     6
        NUMLEN  DB     ?
        NUMFLD  DB     6 DUP('0')
        
DSEG ENDS
CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
                ASSUME CS: CSEG, DS: DSEG, SS: STSEG, ES: DSEG
                PUSH   DS
                XOR    AX, AX
                PUSH   AX
                MOV    AX, DSEG
                MOV    DS, AX
                MOV    ES, AX
                CALL   GTINPT
                CALL   CHKSIGN
                CALL   CHKNMBR
                JZ     E10
                CALL   ASBI
                MOV    AL, BINVAL
                MUL    TOMUL
                LEA    BX, RESMUL
                MOV    [BX], AX
                CALL   BIAS
                LEA    DX, RESASC
                CALL   PRNMSG
        E10:    RET
MAIN ENDP

GTINPT PROC NEAR                                                      ; get input
                LEA    DX, MESSTR1
                CALL   PRNMSG
                LEA    DX, NUMPAR
                MOV    AH, 10
                INT    21h
                RET
GTINPT ENDP

CHKSIGN PROC NEAR                                                     ; check is negative
                CLD
                LEA    DI, NUMFLD
                MOV    AL, '-'
                SCASB
                JNE    PPOS
                JE     PNG
                RET
CHKSIGN ENDP

CHKNMBR PROC NEAR                                                     ; check is number
                CLD
                LEA    DI, NUMFLD
                MOV    CL, NUMLEN
                MOV    AH,0
                MOV    AL, SIGN
                ADD    DI, AX
                SUB    CL, AL
        B20:    
                MOV    AL, [DI]
                CMP    AL, 48
                JB     PNN
                CMP    AL, 57
                JA     PNN
                INC    DI
                LOOP   B20
        B30:    RET
CHKNMBR ENDP

PRNMSG PROC NEAR                                                      ; print message
                MOV    AH, 9
                INT    21h
                RET
PRNMSG ENDP

PNN PROC NEAR                                                         ; not number
                LEA    DX, MESSERR
                CALL   PRNMSG
                XOR    BX, BX
                JMP    B30
                RET
                
PNN ENDP

PPOS PROC NEAR                                                        ; positive
                MOV    SIGN, 0
                RET
PPOS ENDP

PNG PROC NEAR                                                         ; negative
                MOV    SIGN, 1
                RET
PNG ENDP

ASBI PROC NEAR                                                        ; convert ASCII to bin
                MOV    CX, 10
                LEA    SI, NUMFLD-1
                XOR    AX, AX
                XOR    BX, BX

                MOV    AL, SIGN
                ADD    SI, AX
                MOV    BL, NUMLEN
                SUB    BL, SIGN
                LEA    AX,BINVAL
        C30:    
                MOV    AL, [SI+BX]
                AND    AX, 000FH
                MUL    MULT10
                ADD    BINVAL, AL
                MOV    AL, MULT10
                MUL    CX
                MOV    MULT10, AL
                DEC    BX
                JNZ    C30
                RET
ASBI ENDP
BIAS PROC
                
                MOV    CX,0010                                        ;Фактор деления
                LEA    SI,RESASC+7                                    ;Адрес ASCVAL
                MOV    AL,RESMUL                                      ;Загрузить дв. число
                
        D20:    
                CMP    AL,10                                          ;Значение меньше 10?
                JB     D30                                            ; Да - выйти
                XOR    DX,DX                                          ;Очистить часть частного
                DIV    CX                                             ;Разделить на 10
                OR     DL,30H
                MOV    [SI],DL                                        ;Записать ASCII-символ
                DEC    SI
                JMP    D20
        D30:    
                OR     AL,30H                                         ;3аписать поcл. частное
                MOV    [SI],AL                                        ; как ASCII-символ
                CMP    SIGN, 1
                JE     D40
                JMP    D50
        D40:    DEC    SI
                MOV    DL, 2DH
                MOV    [SI],DL
        D50:    RET
BIAS ENDP

CSEG ENDS
     END MAIN