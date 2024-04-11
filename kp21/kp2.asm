STSEG SEGMENT PARA STACK "STACK"
          DB 32 DUP(?)
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
    inputPrompt db 'Введіть ціле число: $'
    errorMsg    db 'Помилка введення. Спробуйте ще раз.$'
    resultMsg   db 'Результат: $'
    inputBuffer db 6                                         ; Максимальна довжина числа + знак нового рядка
    number      dw ?

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

    ; Запит на введення числа
    inputNumber:    
                    mov    ah, 09h
                    lea    dx, inputPrompt
                    int    21h
                    call   readInteger
                    jc     inputNumber                                ; Якщо сталася помилка, повторити запит

    ; Виконання арифметичної операції
                    ; sub    number, 23

    ; Виведення результату
                    lea    dx, resultMsg
                    mov    ah, 09h
                    int    21h
                    call   printInteger

    ; Завершення програми
                    mov    ax, 4C00h
                    int    21h

    ; Процедура для читання цілого числа з консолі
readInteger proc near
    ; Читання рядка
                    mov    ah, 0Ah
                    lea    dx, inputBuffer
                    int    21h
    ; Перетворення рядка в число
                    mov    si, offset inputBuffer + 1                 ; Переходимо до першого символу
                    call   stringToInteger
                    ret
readInteger endp

    ; Процедура для перетворення рядка в число
stringToInteger proc near
                    xor    ax, ax                                     ; AX = 0
                    xor    cx, cx                                     ; Скидання CX для використання в якості лічильника
                    mov    cl, byte ptr [si]                          ; Довжина рядка
                    inc    si                                         ; Перехід до першого символу числа
    checkDigit:     
    ; Перевірка на кінець рядка

                    loop   readDigit
                    mov    number, ax
                    clc                                               ; Очищення флага переривання для індикації успішного вводу
                    ret
    readDigit:      
    ; Перетворення символу в число
                    mov    dl, byte ptr [si]
                    sub    dl, '0'                                    ; Перетворення ASCII-символу в число
    ; Перевірка на валідність цифри
                    cmp    dl, 9
                    ja     error                                      ; Якщо DL > 9, символ не є цифрою
    ; Додавання цифри до числа
    ; MOV CH, 10
                    MOV    BL, 10
                    IMUL   BL
                    add    ax, dx
                    inc    si

                    jmp    checkDigit
    error:          
                    stc                                               ; Встановлення флага переривання
                    ret
stringToInteger endp

    ; Процедура для виведення числа на екран
printInteger proc near
    ; Конвертація числа у рядок і його виведення
                    mov    ax, number
                    call   integerToString
                    mov    ah, 09h
                    lea    dx, inputBuffer                         ; Використання inputBuffer як буфера для рядка
                    int    21h
                    ret
printInteger endp

    ; Процедура для конвертації числа у рядок
integerToString proc near
                  
                    MOV    CX,0010
                    LEA    SI,inputBuffer+5
                    MOV    AX,number
                    
                
    D20:            
                    CMP    AX,0010
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
                    MOV    AL, '$'
                    LEA    SI,inputBuffer+7
                    MOV    [SI], AL
                   
                    RET
                
integerToString endp
MAIN ENDP
CSEG ENDS
     END MAIN
