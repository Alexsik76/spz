STSEG SEGMENT PARA STACK "STACK"
          DB 32 DUP(?)
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
    MESSTR1 DB     "Enter number ->$"
    MESSTR2 DB     "Number is negative$"
    MESSTR3 DB     "Number is positive$"
            NUMPAR LABEL    BYTE
    MAXLEN  DB     6
    NUBLEN  DB     ?
    NUMFLD  DB     6 DUP('0')
DSEG ENDS
CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
         ASSUME CS: CSEG, DS: DSEG, SS: STSEG, ES: DSEG    ;
         PUSH   DS                               ; init
         XOR    AX, AX                           ;
         PUSH   AX                               ;
    
    ; print request
         MOV    AX, DSEG
         MOV    DS, AX
         MOV    ES, AX
         LEA    DX, MESSTR1
         MOV    AH, 9
         INT    21h
    
    ; get number
         LEA    DX, NUMPAR
         MOV    AH, 10
         INT    21h

    ; check is negative
         CLD
         LEA    DI, NUMFLD
         MOV    AL, '-'
         SCASB
         JNE    PPOS
         JE     PNG
E90:     RET
MAIN ENDP

PPOS PROC NEAR                                   ; print positive
         LEA    DX, MESSTR3
         MOV    AH, 9
         INT    21h
         JMP E90
PPOS ENDP

PNG PROC NEAR                                    ; print negative
         LEA    DX, MESSTR2
         MOV    AH, 9
         INT    21h
         JMP E90
PNG ENDP

CSEG ENDS
     END MAIN