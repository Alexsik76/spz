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
             ASSUME CS: CSEG, DS: DSEG, SS: STSEG, ES: DSEG     ;
             PUSH   DS                                          ; init
             XOR    AX, AX                                      ;
             PUSH   AX                                          ;
     
    
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
     E80:    CALL   CHKNMBR
             RET
MAIN ENDP

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

PNN PROC NEAR                                                   ; print not number
             LEA    DX, MESSTR4
             MOV    AH, 9
             INT    21h
             RET
PNN ENDP

PPOS PROC NEAR                                                  ; print positive
             LEA    DX, MESSTR3
             MOV    AH, 9
             INT    21h
             MOV    AL, 00h
             JMP    E80
PPOS ENDP

PNG PROC NEAR                                                   ; print negative
             LEA    DX, MESSTR2
             MOV    AH, 9
             INT    21h
             MOV    AL, 01h
             JMP    E80
PNG ENDP

CSEG ENDS
     END MAIN