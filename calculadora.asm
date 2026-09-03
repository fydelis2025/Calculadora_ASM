; ============================================================
; CALCULADORA ASSEMBLY x64 - WINDOWS API - Adiel Santos Fontes
; ============================================================
;
; NASM + MinGW / Strawberry
;
; Compilar:
;
; nasm -f win64 calculadora.asm -o calculadora.o
;
; Linkar:
;
; C:\Strawberry\c\bin\g++.exe calculadora.o -o calculadora.exe -mwindows -luser32 -lkernel32
;
; ============================================================

bits 64
default rel

; ============================================================
; WINDOWS API
; ============================================================

extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow

extern GetMessageA
extern TranslateMessage
extern DispatchMessageA

extern DefWindowProcA
extern PostQuitMessage

extern GetModuleHandleA
extern ExitProcess

extern GetStockObject
extern SetWindowTextA
extern GetWindowTextA


; ============================================================
; CONSTANTES
; ============================================================

%define WS_OVERLAPPEDWINDOW 0x00CF0000

%define WS_CHILD            0x40000000
%define WS_VISIBLE          0x10000000
%define WS_BORDER           0x00800000

%define ES_RIGHT            0x00000002
%define ES_READONLY         0x00000800

%define BS_PUSHBUTTON       0x00000000

%define WM_CREATE           0x0001
%define WM_DESTROY          0x0002
%define WM_COMMAND          0x0111

%define SW_SHOW             5

%define COLOR_WINDOW        5


; ============================================================
; IDS DOS BOTÕES
; ============================================================

%define ID_0        100
%define ID_1        101
%define ID_2        102
%define ID_3        103
%define ID_4        104
%define ID_5        105
%define ID_6        106
%define ID_7        107
%define ID_8        108
%define ID_9        109

%define ID_PLUS     110
%define ID_SUB      112
%define ID_MUL      113
%define ID_DIV      114
%define ID_CLEAR    115
%define ID_EQUAL    120

%define ID_DISPLAY  201


; ============================================================
; DADOS SOMENTE LEITURA
; ============================================================

section .rdata

    className:
        db "CalcAssemblyClass", 0

    windowTitle:
        db "Calculadora Assembly x64", 0

    editClass:
        db "EDIT", 0

    buttonClass:
        db "BUTTON", 0

    txtZero:
        db "0", 0

    txtError:
        db "Erro", 0

    txt7:
        db "7", 0

    txt8:
        db "8", 0

    txt9:
        db "9", 0

    txtDiv:
        db "/", 0

    txt4:
        db "4", 0

    txt5:
        db "5", 0

    txt6:
        db "6", 0

    txtMul:
        db "*", 0

    txt1:
        db "1", 0

    txt2:
        db "2", 0

    txt3:
        db "3", 0

    txtSub:
        db "-", 0

    txtClear:
        db "C", 0

    txt0:
        db "0", 0

    txtPlus:
        db "+", 0

    txtEqual:
        db "=", 0


; ============================================================
; TABELA DE TEXTOS DOS BOTÕES
; ============================================================

buttonTexts:

    dq txt7
    dq txt8
    dq txt9
    dq txtDiv

    dq txt4
    dq txt5
    dq txt6
    dq txtMul

    dq txt1
    dq txt2
    dq txt3
    dq txtSub

    dq txtClear
    dq txt0
    dq txtPlus
    dq txtEqual


; ============================================================
; TABELA DE IDS
; ============================================================

buttonIDs:

    dd ID_7
    dd ID_8
    dd ID_9
    dd ID_DIV

    dd ID_4
    dd ID_5
    dd ID_6
    dd ID_MUL

    dd ID_1
    dd ID_2
    dd ID_3
    dd ID_SUB

    dd ID_CLEAR
    dd ID_0
    dd ID_PLUS
    dd ID_EQUAL


; ============================================================
; DADOS
; ============================================================

section .data

    hInstance:
        dq 0

    hMainWnd:
        dq 0

    hEdit:
        dq 0

    storedValue:
        dq 0

    pendingOp:
        dq 0

    clearOnNext:
        dq 0


; ============================================================
; MEMÓRIA
; ============================================================

section .bss

    msg:
        resb 48

    wc:
        resb 80

    ; Buffer principal
    buffer:
        resb 128

    ; Buffer para leitura do visor
    inputBuffer:
        resb 128


; ============================================================
; CÓDIGO
; ============================================================

section .text

global main


; ============================================================
; MAIN
; ============================================================

main:

    ; Shadow space
    ; + alinhamento
    sub rsp, 40


    ; --------------------------------------------------------
    ; hInstance
    ; --------------------------------------------------------

    xor ecx, ecx

    call GetModuleHandleA

    mov [hInstance], rax


    ; --------------------------------------------------------
    ; WNDCLASSEXA
    ; --------------------------------------------------------

    mov dword [wc+0], 80

    ; CS_HREDRAW | CS_VREDRAW
    mov dword [wc+4], 3

    lea rax, [WindowProc]

    mov qword [wc+8], rax

    mov dword [wc+16], 0

    mov dword [wc+20], 0

    mov rax, [hInstance]

    mov qword [wc+24], rax

    ; hIcon
    mov qword [wc+32], 0


    ; --------------------------------------------------------
    ; Cursor
    ; --------------------------------------------------------

    ; Usamos cursor padrão do sistema
    mov qword [wc+40], 0


    ; --------------------------------------------------------
    ; Background
    ; --------------------------------------------------------

    sub rsp, 32

    mov ecx, COLOR_WINDOW

    call GetStockObject

    add rsp, 32

    mov qword [wc+48], rax


    ; Menu
    mov qword [wc+56], 0


    ; Nome da classe
    lea rax, [className]

    mov qword [wc+64], rax


    ; Ícone pequeno
    mov qword [wc+72], 0


    ; --------------------------------------------------------
    ; Registrar classe
    ; --------------------------------------------------------

    lea rcx, [wc]

    call RegisterClassExA

    test eax, eax

    jz .sair


    ; ========================================================
    ; CRIAR JANELA PRINCIPAL
    ; ========================================================

    sub rsp, 96

    xor ecx, ecx

    lea rdx, [className]

    lea r8, [windowTitle]

    mov r9d, WS_OVERLAPPEDWINDOW


    ; X
    mov qword [rsp+32], 300

    ; Y
    mov qword [rsp+40], 150

    ; Width
    mov qword [rsp+48], 290

    ; Height
    mov qword [rsp+56], 360


    ; Parent
    mov qword [rsp+64], 0

    ; Menu
    mov qword [rsp+72], 0


    ; Instance
    mov rax, [hInstance]

    mov qword [rsp+80], rax


    ; lpParam
    mov qword [rsp+88], 0


    call CreateWindowExA

    add rsp, 96


    test rax, rax

    jz .sair


    mov [hMainWnd], rax


    ; ========================================================
    ; MOSTRAR JANELA
    ; ========================================================

    sub rsp, 32

    mov rcx, [hMainWnd]

    mov edx, SW_SHOW

    call ShowWindow

    add rsp, 32


    ; ========================================================
    ; ATUALIZAR JANELA
    ; ========================================================

    sub rsp, 32

    mov rcx, [hMainWnd]

    call UpdateWindow

    add rsp, 32


    ; ========================================================
    ; CRIAR VISOR
    ; ========================================================

    sub rsp, 96

    xor ecx, ecx

    lea rdx, [editClass]

    lea r8, [txtZero]

    mov r9d, WS_CHILD | WS_VISIBLE | WS_BORDER | ES_RIGHT | ES_READONLY


    ; X
    mov qword [rsp+32], 20

    ; Y
    mov qword [rsp+40], 20

    ; Width
    mov qword [rsp+48], 240

    ; Height
    mov qword [rsp+56], 35


    ; Parent
    mov rax, [hMainWnd]

    mov qword [rsp+64], rax


    ; ID
    mov qword [rsp+72], ID_DISPLAY


    ; Instance
    mov rax, [hInstance]

    mov qword [rsp+80], rax


    ; Param
    mov qword [rsp+88], 0


    call CreateWindowExA

    add rsp, 96


    test rax, rax

    jz .sair


    mov [hEdit], rax


    ; ========================================================
    ; CRIAR 16 BOTÕES
    ; ========================================================

    xor r12d, r12d


.loopBotoes:

    cmp r12d, 16

    jge .fimBotoes


    ; --------------------------------------------------------
    ; Calcula linha
    ; --------------------------------------------------------

    mov eax, r12d

    xor edx, edx

    mov ecx, 4

    div ecx

    ; EAX = linha
    ; EDX = coluna


    ; --------------------------------------------------------
    ; X = 20 + coluna * 55
    ; --------------------------------------------------------

    imul edx, edx, 55

    add edx, 20

    mov r13d, edx


    ; --------------------------------------------------------
    ; Y = 70 + linha * 45
    ; --------------------------------------------------------

    imul eax, eax, 45

    add eax, 70

    mov r14d, eax


    ; --------------------------------------------------------
    ; texto
    ; --------------------------------------------------------

    lea rax, [buttonTexts]

    mov r15, [rax + r12*8]


    ; --------------------------------------------------------
    ; ID
    ; --------------------------------------------------------

    lea rax, [buttonIDs]

    mov ebx, [rax + r12*4]


    ; --------------------------------------------------------
    ; CreateWindowExA
    ; --------------------------------------------------------

    sub rsp, 96

    xor ecx, ecx

    lea rdx, [buttonClass]

    mov r8, r15

    mov r9d, WS_CHILD | WS_VISIBLE


    ; X
    movsxd rax, r13d

    mov qword [rsp+32], rax


    ; Y
    movsxd rax, r14d

    mov qword [rsp+40], rax


    ; Width
    mov qword [rsp+48], 50

    ; Height
    mov qword [rsp+56], 38


    ; Parent
    mov rax, [hMainWnd]

    mov qword [rsp+64], rax


    ; ID
    movsxd rax, ebx

    mov qword [rsp+72], rax


    ; Instance
    mov rax, [hInstance]

    mov qword [rsp+80], rax


    ; Param
    mov qword [rsp+88], 0


    call CreateWindowExA

    add rsp, 96


    inc r12d

    jmp .loopBotoes


.fimBotoes:


    ; ========================================================
    ; LOOP DE MENSAGENS
    ; ========================================================

.messageLoop:

    sub rsp, 40

    lea rcx, [msg]

    xor edx, edx

    xor r8d, r8d

    xor r9d, r9d

    call GetMessageA

    add rsp, 40


    test eax, eax

    jle .sair


    ; --------------------------------------------------------
    ; TranslateMessage
    ; --------------------------------------------------------

    sub rsp, 40

    lea rcx, [msg]

    call TranslateMessage

    add rsp, 40


    ; --------------------------------------------------------
    ; DispatchMessage
    ; --------------------------------------------------------

    sub rsp, 40

    lea rcx, [msg]

    call DispatchMessageA

    add rsp, 40


    jmp .messageLoop


.sair:

    xor ecx, ecx

    call ExitProcess


; ============================================================
; WINDOW PROC
; ============================================================

WindowProc:

    ; Preserva registradores não-voláteis
    push r12
    push r13

    sub rsp, 40


    ; ========================================================
    ; WM_DESTROY
    ; ========================================================

    cmp edx, WM_DESTROY

    je .destroy


    ; ========================================================
    ; WM_COMMAND
    ; ========================================================

    cmp edx, WM_COMMAND

    je .command


    ; ========================================================
    ; Evento não tratado
    ; ========================================================

    call DefWindowProcA

    add rsp, 40

    pop r13
    pop r12

    ret


; ============================================================
; WM_COMMAND
; ============================================================

.command:

    ; --------------------------------------------------------
    ; LOWORD(wParam)
    ; --------------------------------------------------------

    mov eax, r8d

    and eax, 0FFFFh


    ; ========================================================
    ; DIGITOS
    ; ========================================================

    cmp eax, ID_0
    je .digit0

    cmp eax, ID_1
    je .digit1

    cmp eax, ID_2
    je .digit2

    cmp eax, ID_3
    je .digit3

    cmp eax, ID_4
    je .digit4

    cmp eax, ID_5
    je .digit5

    cmp eax, ID_6
    je .digit6

    cmp eax, ID_7
    je .digit7

    cmp eax, ID_8
    je .digit8

    cmp eax, ID_9
    je .digit9


    ; ========================================================
    ; OPERADORES
    ; ========================================================

    cmp eax, ID_PLUS
    je .plus

    cmp eax, ID_SUB
    je .sub

    cmp eax, ID_MUL
    je .mul

    cmp eax, ID_DIV
    je .div

    cmp eax, ID_CLEAR
    je .clear

    cmp eax, ID_EQUAL
    je .equal


    jmp .commandEnd


; ============================================================
; DIGITO 0
; ============================================================

.digit0:

    mov al, '0'

    jmp .addDigit


; ============================================================
; DIGITO 1
; ============================================================

.digit1:

    mov al, '1'

    jmp .addDigit


; ============================================================
; DIGITO 2
; ============================================================

.digit2:

    mov al, '2'

    jmp .addDigit


; ============================================================
; DIGITO 3
; ============================================================

.digit3:

    mov al, '3'

    jmp .addDigit


; ============================================================
; DIGITO 4
; ============================================================

.digit4:

    mov al, '4'

    jmp .addDigit


; ============================================================
; DIGITO 5
; ============================================================

.digit5:

    mov al, '5'

    jmp .addDigit


; ============================================================
; DIGITO 6
; ============================================================

.digit6:

    mov al, '6'

    jmp .addDigit


; ============================================================
; DIGITO 7
; ============================================================

.digit7:

    mov al, '7'

    jmp .addDigit


; ============================================================
; DIGITO 8
; ============================================================

.digit8:

    mov al, '8'

    jmp .addDigit


; ============================================================
; DIGITO 9
; ============================================================

.digit9:

    mov al, '9'


; ============================================================
; ADICIONAR DIGITO
; ============================================================

.addDigit:

    ; Guarda o caractere
    mov byte [buffer], al

    mov byte [buffer+1], 0


    ; --------------------------------------------------------
    ; Se acabou de clicar em operador
    ; começa novo número
    ; --------------------------------------------------------

    cmp qword [clearOnNext], 1

    je .newNumber


    ; --------------------------------------------------------
    ; Ler visor atual
    ; --------------------------------------------------------

    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [inputBuffer]

    mov r8d, 127

    call GetWindowTextA

    add rsp, 32


    ; --------------------------------------------------------
    ; Verifica se é "0"
    ; --------------------------------------------------------

    cmp byte [inputBuffer], '0'

    jne .append


    cmp byte [inputBuffer+1], 0

    je .newNumber


; ============================================================
; CONCATENAR
; ============================================================

.append:

    lea r10, [inputBuffer]


.findEnd:

    cmp byte [r10], 0

    je .putDigit

    inc r10

    jmp .findEnd


.putDigit:

    mov al, [buffer]

    mov [r10], al

    mov byte [r10+1], 0


    ; --------------------------------------------------------
    ; Atualizar visor
    ; --------------------------------------------------------

    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [inputBuffer]

    call SetWindowTextA

    add rsp, 32

    jmp .commandEnd


; ============================================================
; NOVO NUMERO
; ============================================================

.newNumber:

    mov qword [clearOnNext], 0


    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [buffer]

    call SetWindowTextA

    add rsp, 32

    jmp .commandEnd


; ============================================================
; +
; ============================================================

.plus:

    mov qword [pendingOp], 1

    jmp .saveOperand


; ============================================================
; -
; ============================================================

.sub:

    mov qword [pendingOp], 2

    jmp .saveOperand


; ============================================================
; *
; ============================================================

.mul:

    mov qword [pendingOp], 3

    jmp .saveOperand


; ============================================================
; /
; ============================================================

.div:

    mov qword [pendingOp], 4

    jmp .saveOperand


; ============================================================
; SALVAR OPERANDO
; ============================================================

.saveOperand:

    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [buffer]

    mov r8d, 127

    call GetWindowTextA

    add rsp, 32


    lea rcx, [buffer]

    call atoi_simple


    mov [storedValue], rax

    mov qword [clearOnNext], 1

    jmp .commandEnd


; ============================================================
; CLEAR
; ============================================================

.clear:

    mov qword [storedValue], 0

    mov qword [pendingOp], 0

    mov qword [clearOnNext], 0


    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [txtZero]

    call SetWindowTextA

    add rsp, 32

    jmp .commandEnd


; ============================================================
; IGUAL
; ============================================================

.equal:

    cmp qword [pendingOp], 0

    je .commandEnd


    ; --------------------------------------------------------
    ; Ler segundo número
    ; --------------------------------------------------------

    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [buffer]

    mov r8d, 127

    call GetWindowTextA

    add rsp, 32


    ; --------------------------------------------------------
    ; Converter
    ; --------------------------------------------------------

    lea rcx, [buffer]

    call atoi_simple


    ; segundo número
    mov r12, rax


    ; primeiro número
    mov rax, [storedValue]


    ; --------------------------------------------------------
    ; SOMA
    ; --------------------------------------------------------

    cmp qword [pendingOp], 1

    je .calculateAdd


    ; --------------------------------------------------------
    ; SUBTRAÇÃO
    ; --------------------------------------------------------

    cmp qword [pendingOp], 2

    je .calculateSub


    ; --------------------------------------------------------
    ; MULTIPLICAÇÃO
    ; --------------------------------------------------------

    cmp qword [pendingOp], 3

    je .calculateMul


    ; --------------------------------------------------------
    ; DIVISÃO
    ; --------------------------------------------------------

    cmp qword [pendingOp], 4

    je .calculateDiv


    jmp .commandEnd


; ============================================================
; SOMA
; ============================================================

.calculateAdd:

    add rax, r12

    jmp .showResult


; ============================================================
; SUBTRAÇÃO
; ============================================================

.calculateSub:

    sub rax, r12

    jmp .showResult


; ============================================================
; MULTIPLICAÇÃO
; ============================================================

.calculateMul:

    imul rax, r12

    jmp .showResult


; ============================================================
; DIVISÃO
; ============================================================

.calculateDiv:

    test r12, r12

    jz .divisionZero


    cqo

    idiv r12

    jmp .showResult


; ============================================================
; DIVISÃO POR ZERO
; ============================================================

.divisionZero:

    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [txtError]

    call SetWindowTextA

    add rsp, 32


    mov qword [pendingOp], 0

    mov qword [clearOnNext], 1

    jmp .commandEnd


; ============================================================
; MOSTRAR RESULTADO
; ============================================================

.showResult:

    ; RAX = resultado

    lea rdx, [buffer]

    call itoa_simple


    sub rsp, 32

    mov rcx, [hEdit]

    lea rdx, [buffer]

    call SetWindowTextA

    add rsp, 32


    mov qword [pendingOp], 0

    mov qword [clearOnNext], 1

    jmp .commandEnd


; ============================================================
; FINAL DO WM_COMMAND
; ============================================================

.commandEnd:

    xor eax, eax

    add rsp, 40

    pop r13
    pop r12

    ret


; ============================================================
; WM_DESTROY
; ============================================================

.destroy:

    xor ecx, ecx

    call PostQuitMessage

    xor eax, eax

    add rsp, 40

    pop r13
    pop r12

    ret


; ============================================================
; atoi_simple
;
; RCX = endereço da string
;
; retorna:
; RAX = número
; ============================================================

atoi_simple:

    xor rax, rax

    xor r9, r9


    ; --------------------------------------------------------
    ; Sinal negativo
    ; --------------------------------------------------------

    movzx rdx, byte [rcx]

    cmp dl, '-'

    jne .atoiLoop

    mov r9, 1

    inc rcx


.atoiLoop:

    movzx rdx, byte [rcx]

    test dl, dl

    jz .atoiDone


    ; Ignora caracteres não numéricos
    cmp dl, '0'

    jb .atoiDone

    cmp dl, '9'

    ja .atoiDone


    sub rdx, '0'


    imul rax, rax, 10

    add rax, rdx


    inc rcx

    jmp .atoiLoop


.atoiDone:

    test r9, r9

    jz .atoiReturn


    neg rax


.atoiReturn:

    ret


; ============================================================
; itoa_simple
;
; RAX = número
; RDX = endereço do buffer
;
; retorna:
; RAX = endereço da string
; ============================================================

itoa_simple:

    push rbx

    push r12


    mov r12, rdx


    lea rbx, [r12+127]

    mov byte [rbx], 0

    dec rbx


    xor r9, r9


    ; --------------------------------------------------------
    ; Zero
    ; --------------------------------------------------------

    test rax, rax

    jnz .itoaNotZero


    mov byte [rbx], '0'

    mov rax, rbx

    jmp .itoaDone


.itoaNotZero:

    ; --------------------------------------------------------
    ; Negativo
    ; --------------------------------------------------------

    test rax, rax

    jns .itoaPositive


    mov r9, 1

    neg rax


.itoaPositive:


.itoaLoop:

    xor rdx, rdx

    mov rcx, 10

    div rcx

    add dl, '0'

    mov [rbx], dl

    dec rbx

    test rax, rax

    jnz .itoaLoop


    ; --------------------------------------------------------
    ; Sinal
    ; --------------------------------------------------------

    test r9, r9

    jz .itoaNoSign


    mov byte [rbx], '-'

    dec rbx


.itoaNoSign:

    lea rax, [rbx+1]


.itoaDone:

    pop r12

    pop rbx

    ret
