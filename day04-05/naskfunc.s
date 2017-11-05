[BITS 32]

global	io_hlt, io_cli, io_sti, io_stihlt
global	io_in8,  io_in16,  io_in32
GLOBAL	io_out8, io_out16, io_out32
GLOBAL	io_load_eflags, io_store_eflags
GLOBAL	load_gdtr, load_idtr

[SECTION .text]

io_hlt:
		HLT ; CPU 정지
		RET ; return

io_cli:
		CLI ; CPU 레벨에서 인터럽트 금지
		RET ; return

io_sti:
		STI ; CPU 레벨에서 인터럽트 허용
		RET ; return

io_stihlt:
		STI ; CPU 레벨에서 인터럽트 허용
		HLT ; CPU 정지
		RET ; return

io_in8:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX, 0		; EAX = 0
		IN		AL, DX		; DX번째 포트에 온 데이터를 AL로
		RET					; return

io_in16:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX, 0		; EAX = 0
		IN		AX, DX		; DX번째 포트에 온 데이터를 AX로
		RET					; return 

io_in32:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		IN		EAX, DX		; DX번째 포트에 온 데이터를 EAX로
		RET					; return

io_out8:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		AL,[ESP+8]	; AL = *(ESP + 8)
		OUT		DX, AL		; DX번째 포트로 AL의 데이터를 보냄
		RET

io_out16:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX,[ESP+8]	; EAX = *(ESP + 8)
		OUT		DX, AX		; DX번째 포트로 AX의 데이터를 보냄
		RET

io_out32:
		MOV		EDX,[ESP+4]	; EDX = *(ESP + 4)
		MOV		EAX,[ESP+8]	; EAX = *(ESP + 8)
		OUT		DX, EAX		; DX번째 포트로 EAX의 데이터를 보냄
		RET					; return

io_load_eflags:
		PUSHFD		; 스택에 EFLAGS를 push함
		POP		EAX ; 스택에서 EAX를 pop함
		RET			; return

io_store_eflags:
		MOV		EAX, [ESP+4]; EAX = *(ESP + 4)
		PUSH	EAX			; 스택에 EAX를 push함
		POPFD				; 스택에서 EFLAGS를 pop함
		RET					; return

; 현재는 알 필요가 없는 함수들 (5차시에 사용)

load_gdtr:
		MOV		AX, [ESP+4]
		MOV		[ESP+6], AX
		LGDT	[ESP+6]
		RET

load_idtr:
		MOV		AX, [ESP+4]
		MOV		[ESP+6], AX
		LIDT	[ESP+6]
		RET
