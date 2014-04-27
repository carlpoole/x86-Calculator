TITLE Calculator				(main.asm)
INCLUDE Irvine32.inc
.data 

; --------------------------------------
; Places to store operands and operator
; --------------------------------------

operString	DWORD 30 dup(0)
val1		DWORD ?
val2		DWORD ?
oper		BYTE  ?
result		DWORD ?

; ---------------
; Message Strings
; ---------------

welcome		BYTE '-- Carls Calculator --',0
example		BYTE 'Enter your operation (E.G.): -12 + 34 or 1455 * 2',0
illegalChar BYTE 'Invalid Input Char',0
illegalOper BYTE 'Must enter + - * / % only',0
divbyzero	BYTE 'Cannot div by zero',0

.code 

main PROC

	; ------------------------
	; App Welcome and Example
	; ------------------------
	MOV eax, 0
	MOV edx, OFFSET welcome
	CALL writestring
	CALL CrLf
	MOV edx, OFFSET example
	CALL writestring
	CALL CrLf
	CALL CrLf

	; ------------------------
	; Read Operation String
	; ------------------------

	MOV ecx, lengthOf operString
	MOV edx, offset operString
	CALL readString

	; ------------
	; FSM Parsing
	; ------------

	MOV esi, OFFSET operString

	; Do initial test to see if negative
	;	or digit begins the string

	MOV eax, [esi]
	call IsDigit
	jnz CHARERR

	MOV bx, 0 ; counter for 

	READFIRST:
		MOV eax, [esi]

		; Check if space
		;	if so, jump to read operator

		cmp al, 32
		je READOPER

		; Check if digit
		;	if not, 

		call IsDigit
		jnz CHARERR

		; Push number char onto stack
		PUSH eax
		inc bx

		inc esi
		loop READFIRST

	READOPER:

		PUTVAL1:
			MOV eax, 0
			POP eax
			MOV val1, eax
			call writeInt

		inc esi
		MOV eax, [esi]

		cmp al, '+'
			je GOODOPER
		cmp al, '-'
			je GOODOPER
		cmp al, '/'
			je GOODOPER
		cmp al, '*'
			je GOODOPER
		cmp al, '%'
			je GOODOPER

		jmp CHARERR 

	GOODOPER:
		MOV oper, al

	READSECOND:
		ADD esi, 2
		SUB ecx, 2

		; Check if nothing was given for 2nd

		MOV eax, [esi]
		cmp al, 0
		je CHARERR
		cmp al, 10
		je CHARERR

		READSECOND_1:
			MOV eax, [esi]

			; Check if end reached
			cmp al, 0
			je DONE
			cmp al, 10
			je DONE

			; Check if digit
			;	if not, 

			call IsDigit
			jnz CHARERR

			inc esi
			loop READSECOND_1

	DONE:

	; ----------------
	; Execute operand
	; ----------------

	MOV al, oper

	PLUSOPER:
		cmp al, '+'
		jne MINOPER
		call addition
		jmp FINISHUP
	MINOPER:
		cmp al, '-'
		jne DIVOPER
		call subtraction
		jmp FINISHUP
	DIVOPER:
		cmp al, '/'
		jne MULTOPER
		call division
		jmp FINISHUP
	MULTOPER:
		cmp al, '*'
		jne MODOPER
		call multiplication
		jmp FINISHUP
	MODOPER:
		call modulo

	FINISHUP:

		MOV al, '='
		call writeChar
		MOV al, ' '
		call writeChar
		MOV eax, result
		call writeInt

	EXIT

	CHARERR:
		CALL errChar

	DIV0ERR:
		CALL errDiv0

main ENDP

errChar PROC

	MOV edx, OFFSET illegalChar
	CALL CrLf
	CALL writestring 

	EXIT
errChar ENDP

errDiv0 PROC

	MOV edx, OFFSET divbyzero
	CALL CrLf
	CALL writestring 

	EXIT
errDiv0 ENDP

addition PROC

	MOV eax, val1
	ADD eax, val2
	MOV result, eax

	RET
addition ENDP

subtraction PROC

	MOV eax, val1
	SUB eax, val2
	MOV result, eax

	RET
subtraction ENDP

multiplication PROC
	RET
multiplication ENDP

division PROC
	RET
division ENDP

modulo PROC
	RET
modulo ENDP



END main