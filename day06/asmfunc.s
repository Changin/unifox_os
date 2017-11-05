[BITS 32]

GLOBAL	hlt, cli, sti, stihlt
GLOBAL	in8,  in16,  in32
GLOBAL	out8, out16, out32
GLOBAL	loadEflags, storeEflags
GLOBAL	loadGdtr, loadIdtr
GLOBAL  asmInt21, asmInt2c
EXTERN  int21, int2c

[SECTION .text]

hlt:
		HLT ; CPU 정지
		RET ; return

cli:
		CLI ; CPU 레벨에서 인터럽트 금지
		RET ; return

sti:
		STI ; CPU 레벨에서 인터럽트 허용
		RET ; return

stihlt:
		STI ; CPU 레벨에서 인터럽트 허용
		HLT ; CPU 정지
		RET ; return

in8:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX, 0		; EAX = 0
		IN		AL, DX		; DX번째 포트에 온 데이터를 AL로
		RET					; return

in16:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX, 0		; EAX = 0
		IN		AX, DX		; DX번째 포트에 온 데이터를 AX로
		RET					; return 

in32:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		IN		EAX, DX		; DX번째 포트에 온 데이터를 EAX로
		RET					; return

out8:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		AL,[ESP+8]	; AL = *(ESP + 8)
		OUT		DX, AL		; DX번째 포트로 AL의 데이터를 보냄
		RET

out16:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX,[ESP+8]	; EAX = *(ESP + 8)
		OUT		DX, AX		; DX번째 포트로 AX의 데이터를 보냄
		RET

out32:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX,[ESP+8]	; EAX = *(ESP + 8)
		OUT		DX, EAX		; DX번째 포트로 EAX의 데이터를 보냄
		RET					; return

loadEflags:
		PUSHFD		; 스택에 EFLAGS를 push함
		POP		EAX ; 스택에서 EAX를 pop함
		RET			; return

storeEflags:
		MOV		EAX, [ESP+4]; EAX = *(ESP + 4)
		PUSH	EAX			; 스택에 EAX를 push함
		POPFD				; 스택에서 EFLAGS를 pop함
		RET					; return
		
loadGdtr:
		MOV		AX, [ESP+4]	; AX = *(ESP + 4)
		MOV		[ESP+6], AX	; *(ESP + 6) = AX	
		LGDT	[ESP+6]		; ESP ~ ESP + 6 까지 LGDT (ESP ~ ESP + 4 = GDT 주소, ESP + 5 ~ ESP + 6 = GDT 크기)
		RET					; return

loadIdtr:
		MOV		AX, [ESP+4]	; AX = *(ESP + 4)
		MOV		[ESP+6], AX	; *(ESP + 6) = AX
		LIDT	[ESP+6]		; ESP ~ ESP + 6 까지 LIDT (ESP ~ ESP + 4 = IDT 주소 ,ESP + 5 ~ ESP + 6 = IDT 크기)
		RET					; return

asmInt21:
		PUSH	ES			
		PUSH	DS			
		PUSHAD				
		PUSH	ESP
		MOV		AX, SS
		MOV		DS, AX
		MOV		ES, AX
		CALL	int21
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

asmInt2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		PUSH	ESP
		MOV		AX, SS
		MOV		DS, AX
		MOV		ES, AX
		CALL	int2c
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD