STSEG SEGMENT PARA STACK "STACK"
              DB 256 DUP(?)
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
        CR      EQU    13                              ;или EQU 0DH
        LF      EQU    10                              ;или EQU 0AH
        MESSTR1 DB     "Enter number: $"
        MESSERR DB     CR, LF, "Not number!$"
        MESS1 DB     CR, LF, "Value to big!$"
        SIGN    DB     0
        ERRVAL  DB     0
        MULT10  DW     1
        BINVAL  DW     0
        ASCVAL  DB     ?
        TOMUL   DW     7
        RESMUL  DW     0
        RESASC  DB     CR, LF, 6 DUP(' '), '$'
                NUMPAR LABEL    BYTE
        MAXLEN  DB     6
        NUMLEN  DB     ?
        NUMFLD  DB     6 DUP('0')
        
DSEG ENDS
CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
                 ASSUME CS: CSEG, DS: DSEG, SS: STSEG
                 PUSH   DS
                 XOR    AX, AX
                 PUSH   AX
                 MOV    AX, DSEG
                 MOV    DS, AX
                 MOV    ES, AX
                 CALL   GTINPT
                 CALL   CHKSIGN
                 CALL   ASBI
                 CMP    ERRVAL, 1
                 JE     E10
                 MOV    AX, BINVAL
                 MUL    TOMUL
                 JC     TOBIG
                 CMP    ERRVAL, 1
                 JE     E10
                 LEA    BX, RESMUL
                 MOV    [BX], AX
                 CALL   BIAS
                 LEA    DX, RESASC
        E10:     CALL   PRNMSG
                 RET
MAIN ENDP

GTINPT PROC NEAR                                             ; get input
                 LEA    DX, MESSTR1
                 CALL   PRNMSG
                 LEA    DX, NUMPAR
                 MOV    AH, 10
                 INT    21h
                 RET
GTINPT ENDP

CHKSIGN PROC NEAR                                            ; check is negative
                 CLD
                 LEA    DI, NUMFLD
                 MOV    AL, [DI]
                 CMP    AL, 2dh
                 JNE    Z11
                 MOV    SIGN, 1
                 jmp    Z12
        Z11:     MOV    SIGN, 0
        Z12:     ret
CHKSIGN ENDP

PRNMSG PROC NEAR                                             ; print message
                 MOV    AH, 9
                 INT    21h
                 RET
PRNMSG ENDP

CHECKNUM PROC NEAR
                 CMP    AL, 48
                 JB     PNN
                 CMP    AL, 57
                 JA     PNN
                 RET
CHECKNUM ENDP

PNN PROC NEAR                                                ; not number
                 LEA    DX, MESSERR
                 MOV    ERRVAL, 1
                 RET
PNN ENDP

TOBIG PROC NEAR                                                ; to big number
                 LEA    DX, MESS1
                 MOV    ERRVAL, 1
                 RET
TOBIG ENDP


ASBI PROC NEAR                                               ; convert ASCII to bin
                 XOR    CX, CX
                 MOV    CL, NUMLEN
                 LEA    SI, NUMFLD-1                         ; to get in 101 the last symbol addr
                 XOR    AX, AX
                 XOR    BX, BX
                 XOR    DX, DX
                 MOV    DL, SIGN
                 ADD    SI, DX
                 SUB    CL, SIGN
        C30:     
                 MOV    BX, CX
                 MOV    AL, [SI+BX]
                 CALL   CHECKNUM
                 CMP    ERRVAL, 1
                 JE     C50
                 SUB    AL, '0'
                 MUL    MULT10
                 ADD    BINVAL, AX
                 JC     TOBIG
                 CMP    ERRVAL, 1
                 JE     C50
                 MOV    AX, 10
                 MUL    MULT10
                 MOV    MULT10, AX
                 XOR    AX, AX
                 LOOP   C30
        C50:     RET
ASBI ENDP
BIAS PROC                                                    ; convert bin to ASCII
                 MOV    CX,0010
                 LEA    SI,RESASC+7
                 MOV    AX,RESMUL
                
        D20:     
                 CMP    AX,10
                 JB     D30
                 XOR    DX,DX
                 DIV    CX
                 OR     DL,30H
                 MOV    [SI],DL
                 DEC    SI
                 JMP    D20
        D30:     
                 OR     AL,30H
                 MOV    [SI],AL
                 CMP    SIGN, 1
                 JE     D40
                 JMP    D50
        D40:     DEC    SI
                 MOV    DL, 2DH
                 MOV    [SI],DL
        D50:     RET
BIAS ENDP

CSEG ENDS
     END MAIN