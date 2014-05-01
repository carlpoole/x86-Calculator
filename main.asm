TITLE Calculator Program - CARL POOLE 5/1/14 (main.asm)
INCLUDE Irvine32.inc

ENTER_KEY = 13

.data 

; --------------------------------------
; Places to store operands and operator
; --------------------------------------

variableA	DWORD 0
variableB	DWORD 0
neg1		BYTE  0
neg2		BYTE  0
errflag		BYTE  0

; ---------------
; Message Strings
; ---------------

welcome		BYTE '-- Carls Calculator --',0
example		BYTE 'Enter your operation (E.G.): -12+34 or 1455*2',0
illegalChar BYTE '!! Invalid Input Char !!',0
divbyzero	BYTE '!! Cannot div by zero !!',0
ofErrorSt	BYTE '!! Overflow Error !!',0

.code 

main PROC

	; ------------------------
	; App Welcome and Example
	; ------------------------

	MOV edx, OFFSET welcome
	CALL writestring
	CALL CrLf
	MOV edx, OFFSET example
	CALL writestring
	CALL CrLf
	CALL CrLf

	START:			; App loops back here after calculating
	MOV eax, 0
	MOV ebx, 0

	; ------------------------
	; Process Input FSM
	; ------------------------

	StateA: ; read in one char at a time, continue reading until get a sign 

	 mov eax, 0
	 call ReadChar 

	 cmp al, '-'		; check if a negative symbol was first
	 jnz NOTNEGATIVE
	 MOV neg1, 1		; Flag neg1 to make sure to negate later
	 call ReadChar

	 NOTNEGATIVE:
	 call IsDigit		;check to see if the value entered was a digit 
	 jnz CHARERR 
	 sub al, '0' 
	 MOVZX eax, al
	 mov variableA, eax 
	 jmp StateB 

	StateB:				; check first if a valid operator was entered
	 mov eax, 0 
	 call ReadChar 
	 cmp al, '+' 
	 jnz C1 
	 mov ecx, addition 
	 jmp StateC 
	 C1:
	 cmp al, '-' 
	 jnz C2 
	 mov ecx, subtraction 
	 jmp StateC 
	 C2:
	 cmp al, '*' 
	 jnz C3 
	 mov ecx, multiplication 
	 jmp StateC 
	 C3:
	 cmp al, '/' 
	 jnz C4 
	 mov ecx, division 
	 jmp StateC 
	 C4:
	 cmp al, '%' 
	 jnz C5 
	 mov ecx, modulo 
	 jmp StateC 
	 C5:
		jmp L1

 	L1: 
	 call IsDigit		; check to see if the value entered was a digit 
	 jnz CHARERR 
	 sub al, '0'
	 MOVZX eax, al 
	 mov ebx, eax 
	 mov eax, 10 
	 imul variableA 
	 jo OVFERR 
	 mov variableA, eax
	 add variableA, ebx		; variableA = variableA * 10 + ebx 
	 jmp StateB				; jump back and check if operator entered yet

	StateC:
	 mov eax, 0
	 call ReadChar 

	 cmp al, '-'		; check if a negative symbol was first and flag if so
	 jnz NOTNEGATIVE2
	 MOV neg2, 1
	 call ReadChar

	 NOTNEGATIVE2:
	 call IsDigit		; check to see if the value entered was a digit 
	 jnz CHARERR 
	 sub al, '0' 
	 MOVZX eax, al
	 mov variableB, eax 
	 jmp StateD 

	StateD:				; continues reading second number until enter key

	 mov eax, 0 
	 call ReadChar 
	 cmp al, ENTER_KEY 
	 jz Done 
	 call isDigit 
	 jnz CHARERR 
	 sub al, '0' 
	 MOVZX eax, al
	 mov ebx, eax 
	 mov eax, 10 
	 imul variableB 
	 jo OVFERR 
	 mov variableB, eax 
	 add variableB, ebx
	 jmp StateD 

	Done: 

	 cmp neg1, 1			; if any operators were flagged negative
	 jnz SKIPNEG1
	 MOV eax, variableA
	 NEG eax				; Negate them
	 MOV variableA, eax

	 SKIPNEG1:

	 cmp neg2, 1
	 jnz SKIPNEG2
	 MOV eax, variableB
	 NEG eax
	 MOV variableB, eax

	 SKIPNEG2:


	 call ecx				; run the calculation

	 cmp errflag, 1			; if error printed skip printing answer (wrong anyway)
	 jz AGAIN

	 call writeInt			; print answer

	 JMP AGAIN				

	 ; ----- Error handling section is here --------

	CHARERR:
		CALL errChar
		JMP AGAIN

	DIV0ERR:
		CALL errDiv0
		JMP AGAIN

	OVFERR:
		CALL ofError
		JMP AGAIN

	; -----------------------------------------------

	AGAIN:					; loop back to start to do another calculation
	 MOV  errflag, 0
	 call CrLf
	 call CrLf
	 jmp START

	 EXIT

main ENDP

errChar PROC
	MOV edx, OFFSET illegalChar
	CALL CrLf
	CALL writestring 
	RET
errChar ENDP

errDiv0 PROC
	MOV edx, OFFSET divbyzero
	CALL CrLf
	CALL writestring 
	RET
errDiv0 ENDP

ofError PROC
	MOV edx, OFFSET ofErrorSt
	CALL CrLf
	CALL writestring 
	RET
ofError ENDP

addition PROC
	MOV eax, variableA
	ADD eax, variableB
	jno done 
	CALL ofError
	MOV  errflag, 1
done: 
	RET
addition ENDP

subtraction PROC
	MOV eax, variableA
	SUB eax, variableB
	jno done 
	CALL ofError
	MOV  errflag, 1
done: 
	RET
subtraction ENDP

multiplication PROC
	MOV eax, variableA
	MOV ebx, variableB
	CDQ
	IMUL ebx
	jno done 
	CALL ofError
	MOV  errflag, 1
done: 
	RET
multiplication ENDP

division PROC

	MOV eax, variableA
	CDQ
	MOV ebx, variableB
	CDQ
	CMP ebx, 0
	JE DIV0
	IDIV ebx
	jno done 
	CALL ofError
	MOV  errflag, 1
done: 
	RET

DIV0: 
	MOV  errflag, 1
	CALL errDiv0
	RET
division ENDP

modulo PROC

	MOV eax, variableA
	CDQ
	MOV ebx, variableB
	CDQ
	CMP ebx, 0
	JE DIV0
	IDIV ebx
	MOV eax, edx
	RET

DIV0: 
	MOV  errflag, 1
	CALL errDiv0
	RET
modulo ENDP



END main