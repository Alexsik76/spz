STSEG SEGMENT PARA STACK "STACK"
          DB 64 DUP ( "STACK" )
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
    SOURCE DB 10, 20, 30, 40
    DEST   DB 4 DUP ( "?" )
DSEG ENDS
CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
         ASSUME CS: CSEG, DS: DSEG, SS: STSEG
    ; ���� ����୥���
         PUSH   DS
         MOV    AX, 0                            ; ��� XOR AX, AX
         PUSH   AX
    ; ?�?�?��?���?� DS
         MOV    AX, DSEG
         MOV    DS, AX
    ; ������ ��ᨢ
         MOV    DEST, 0
         MOV    DEST+1, 0
         MOV    DEST+2, 0
         MOV    DEST+3, 0
    ; ���ᨫ����
         MOV    AL, SOURCE
         MOV    DEST+3, AL
         MOV    AL, SOURCE+1
         MOV    DEST+2, AL
         MOV    AL, SOURCE+2
         MOV    DEST+1, AL
         MOV    AL, SOURCE+3
         MOV    DEST, AL
         RET
MAIN ENDP
CSEG ENDS
END MAIN