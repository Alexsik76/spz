STSEG SEGMENT PARA STACK "STACK"
              DB 256 DUP(?)
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
        CR      EQU    13                                                             ;EQU 0DH
        LF      EQU    10                                                             ;EQU 0AH
        MESSTR1 DB     "The program will multiply your number to 7.", CR, LF,\
                       "You can enter from -4681 to 4681.", CR, LF,\                  ; 01111111 11111111B
                       "Enter number: $"
        MESSER1 DB     CR, LF, "Not number!$"
        MESSER2 DB     CR, LF, "Value too big!$"
        SIGN    DB     0
        ERRVAL  DB     0
        MULT10  DW     1
        BINVAL  DW     0
        TOMUL   DW     7
        RESMUL  DW     0
        RESASC  DB     CR, LF, "Result is:", 6 DUP(' ')
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
                 CALL   GTINPT
                 CALL   CHKSIGN
                 CALL   ASCBI
                 CMP    ERRVAL, 1
                 JE     A20
                 MOV    AX, BINVAL
                 IMUL   TOMUL
                 JO     A10
                 LEA    SI, RESMUL
                 MOV    [SI], AX
                 CALL   BIASC
                 LEA    DX, RESASC
                 JMP    A20
        A10:     LEA    DX, MESSER2
        A20:     CALL   PRNMSG
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
                 LEA    DI, NUMFLD
                 MOV    AL, [DI]
                 CMP    AL, 2dh
                 JNE    Z11
                 MOV    SIGN, 1
                 JMP    Z12
        Z11:     MOV    SIGN, 0
        Z12:     RET
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
                 LEA    DX, MESSER1
                 MOV    ERRVAL, 1
                 RET
PNN ENDP

TOBIG PROC NEAR                                              ; to big number
                 LEA    DX, MESSER2
                 MOV    ERRVAL, 1
                 RET
TOBIG ENDP

ASCBI PROC NEAR                                              ; convert ASCII to bin
                 XOR    CX, CX
                 MOV    CL, NUMLEN
                 LEA    SI, NUMFLD-1
                 XOR    AX, AX
                 XOR    BX, BX
                 XOR    DX, DX
                 MOV    DL, SIGN                             ; if sign '-' is present, DL = 1.
                 ADD    SI, DX                               ; In this case we start from second symbol
                 SUB    CL, SIGN                             ; and will have shorter cycle
        C30:                                                 ; process every symbol
                 MOV    BX, CX
                 MOV    AL, [SI+BX]
                 CALL   CHECKNUM
                 CMP    ERRVAL, 1
                 JE     C70
                 SUB    AL, '0'
                 MUL    MULT10
                 ADD    BINVAL, AX
                 JO     TOBIG
                 CMP    ERRVAL, 1
                 JE     C70
                 MOV    AX, 10
                 MUL    MULT10
                 MOV    MULT10, AX
                 XOR    AX, AX
                 LOOP   C30
        C50:                                                 ; make bin negative
                 CMP    SIGN, 1
                 JNE    C70
        C60:     NEG    BINVAL
        C70:     RET
ASCBI ENDP
BIASC PROC                                                   ; convert bin to ASCII
                 LEA    SI, RESASC
                 ADD    SI, 13
                 MOV    AX, RESMUL
                 MOV    CX, 10
                 XOR    BX, BX
                 OR     AX, AX
                 JNS    D20
                 NEG    AX
        D20:     
                 CMP    AX, 10
                 JB     D30
                 XOR    DX, DX
                 DIV    CX
                 ADD    DX, '0'
                 PUSH   DX
                 INC    BL
                 JMP    D20
        D30:     
                 ADD    AX, '0'
                 PUSH   AX
                 INC    BL
                 MOV    AX, RESMUL
                 OR     AX, AX
                 JNS    D35
                 DEC    SI
                 PUSH   '-'
                 INC    BL
        D35:     
                 MOV    CX, BX
        D36:     
                 POP    AX
                 MOV    [SI], AL
                 INC    SI
                 LOOP   D36
                 MOV    DL, '$'
                 MOV    [SI], DL
        D40:     RET
BIASC ENDP

CSEG ENDS
     END MAIN