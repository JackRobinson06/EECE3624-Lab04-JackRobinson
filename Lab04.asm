/**************************************************************************
 * File: Lab04.asm
 * Lab Name: What’s Your Calling?
 * Author: Jack Robinson
 * Created: 9/15/2026
 *
 * This program...
 *************************************************************************/ 
 .def n = R16
.def result = R17
.org 0x0000 ; next instruction will be written to address 0x0000
            ; (the location of the reset vector)
rjmp main	; set reset vector to point to the main code entry point

main:       ; jump here on reset

		; initialize the stack (RAMEND = 0x10FF by default for the ATmega128A)
		ldi R16, HIGH(RAMEND)
		out SPH, R16
		ldi R16, low(RAMEND)
		out SPL, R16

		LDI  n, 5	; load a value into n
		PUSH n	; push it on the stack
		CALL factN	; calculate the factorial of n
		POP  result	; pop result off stack
here:
		RJMP here	; loop forever

factN:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Recursively computes n! via the stack only.
	; Caller: PUSH n / CALL factN / POP result (gets n!).
	; Y+3 = n's slot (past the 2-byte return address).
	; Base case n==1: slot already holds 1, just RET.
	; Else: push n-1, recurse, re-read Y (clobbered by
	; the call), reload n, multiply by popped (n-1)!,
	; STD result back into Y+3. Correct only up to n=5.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; recursive factorial code begins here
	IN YL, SPL
	IN YH, SPH
	LDD R18, Y+3
	CPI R18, 1
	BRNE recursiveCase
	ret
recursiveCase:
	dec R18
	push R18
	Call factN
	pop R19
	IN YL, SPL
	In YH, SPH
	LDD R18, Y+3
	MUL R18, R19
	STD Y+3, R0
	ret
	; return from the factN subroutine
