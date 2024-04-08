STSEG SEGMENT PARA STACK "STACK"
           DB 32 DUP(?)
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
     CR      EQU    13                                ;или EQU 0DH
     LF      EQU    10                                ;или EQU 0AH
     TAB     EQU    09                                ;или EQU 09H
     MESSTR1 DB     "Enter number ->$"
     MESSTR2 DB     CR, LF, "Number is negative$"
     MESSTR3 DB     CR, LF, "Number is positive$"
     MESSTR4 DB     CR, LF, "Not number$"
             NUMPAR LABEL    BYTE
     MAXLEN  DB     6
     NUBLEN  DB     ?
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
             CALL   PRNMSG
             RET
MAIN ENDP

GTINPT PROC NEAR                                                ; get input
             LEA    DX, MESSTR1
             CALL   PRNMSG
             LEA    DX, NUMPAR
             MOV    AH, 10
             INT    21h
             RET
GTINPT ENDP

CHKSIGN PROC NEAR                                               ; check is negative
             CLD
             LEA    DI, NUMFLD
             MOV    AL, '-'
             SCASB
             JNE    PPOS
             JE     PNG
             RET
CHKSIGN ENDP

CHKNMBR PROC NEAR                                               ; check is number
             CLD
             LEA    DI, NUMFLD
             MOV    CL, NUBLEN
             MOV    AH, 00h
             ADD    DI, AX
             SUB    CL, AL
     C20:    
             MOV    AL, [DI]
             CMP    AL, 48
             JB     PNN
             CMP    AL, 57
             JA     PNN
             INC    DI
             LOOP   C20
             RET
CHKNMBR ENDP

PRNMSG PROC NEAR                                                ; print message
             MOV    AH, 9
             INT    21h
             RET
PRNMSG ENDP

PNN PROC NEAR                                                   ; not number
             LEA    DX, MESSTR4
             RET
PNN ENDP

PPOS PROC NEAR                                                  ; positive
             LEA    DX, MESSTR3
             MOV    AL, 00h
             RET
PPOS ENDP

PNG PROC NEAR                                                   ; negative
             LEA    DX, MESSTR2
             MOV    AL, 01h
             RET
PNG ENDP

CSEG ENDS
     END MAIN