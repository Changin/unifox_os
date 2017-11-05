BOOTPACK	EQU		0x00280000		; bootpack의 로드 장소
CACHE		EQU		0x00100000		; 디스크 캐쉬 장소
REALCACHE	EQU		0x00008000		; 디스크 캐쉬 장소 (리얼모드에서)

; 부팅 정보가 위치한 장소
CYLS	EQU		0x0ff0			; 실린더
LEDS	EQU		0x0ff1			; 키보드 LED
VMODE	EQU		0x0ff2			; 몇 비트의 색깔인가
SCRNX	EQU		0x0ff4			; 해상도의 X
SCRNY	EQU		0x0ff6			; 해상도의 Y
VRAM	EQU		0x0ff8			; 그래픽 버퍼 시작 번지

;ORG		0xc200		; 0xc200에서 시작한다

[BITS 16]

global _start
 
_start:
; 화면 모드 설정
XOR		AX, AX
MOV		DS, AX   
MOV		AL, 0x13				; AL = 0x13 (320x240, 8비트 칼라)
MOV		AH, 0x00					; AH = 0x00
INT		0x10					; INT 10h
MOV		BYTE [VMODE], 8			; *(VMODE) = 8 (8비트 색깔임)
MOV		WORD [SCRNX], 320		; *(SCRNX) = 320 (해상도의 x가 320임)
MOV		WORD [SCRNY], 200		; *(SCRNY) = 200 (해상도의 y가 200임)
MOV		DWORD [VRAM], 0x000a0000; *(VRAM) = 0x000a0000 (그래픽 버퍼 시작 번지임)

; 키보드의 LED를 받아옴
MOV		AH, 0x02				; AH = 0x02
INT		0x16 					; INT 16h
MOV		[LEDS], AL				; *(LEDS) = AL

; PIC 죽여놓기
MOV		AL, 0xff; AL = 0xff
OUT		0x21, AL; 0x21번 포트로 AL의 내용을 보냄
NOP				; 잠깐의 휴식 (인식이 잘되도록)
OUT		0xa1, AL; 0xa1번 포트로 AL의 내용을 보냄
CLI				; CPU 레벨에서 인터럽트 금지

; A20 게이트 설정
CALL	waitkbdout	; waitkbdout()
MOV		AL, 0xd1	; AL = 0xd1
OUT		0x64, AL	; 0x64번 포트로 AL의 내용을 보냄
CALL	waitkbdout	; waitkbdout()
MOV		AL, 0xdf	; AL = 0xdf
OUT		0x60, AL	; 0x60번 포트로 AL의 내용을 보냄
CALL	waitkbdout	; waitkbdout()

; 보호모드 설정
LGDT	[GDTR0]			; GDTR0으로 GDT 설정 (지금은 의미 없음)
MOV		EAX, CR0		; EAX = CR0
AND		EAX, 0x7fffffff	; EAX = EAX && 0x7fffffff (페이징 금지를 위해 31번째 비트를 0으로 함)
OR		EAX, 0x00000001	; EAX = EAX | 0x00000001 (보호모드 이행을 위해 0번째 비트를 1로 함)
MOV		CR0, EAX		; CR0 = EAX
JMP		pipelineflush	; goto pipelineflush

pipelineflush:
		MOV		AX, 1*8			; AX = 8
		MOV		DS, AX			; DS = AX
		MOV		ES, AX			; ES = AX
		MOV		FS, AX			; FS = AX
		MOV		GS, AX			; GS = AX
		MOV		SS, AX			; SS = AX

; bootpack 전송

		MOV		ESI, bootpack		; ESI = bootpack
		MOV		EDI, BOOTPACK		; EDI = BOOTPACK
		MOV		ECX,512 * 1024 / 4	; ECX = 128 * 1024
		CALL	memcpy				; memcpy()

; 디스크 데이터 전송

		MOV		ESI, 0x7c00			; ESI = 0x7c00
		MOV		EDI, CACHE				; EDI = CACHE
		MOV		ECX,512 / 4			; ECX = 512 / 4
		CALL	memcpy					; memcpy()

		MOV		ESI, REALCACHE + 512	; ESI = REALCACHE + 512
		MOV		EDI, CACHE + 512	; EDI = CACHE + 512
		MOV		ECX, 0					; ECX = 0
		MOV		CL, BYTE [CYLS]			; CL = *(CYLS)
		IMUL	ECX, 512 * 18 * 2 / 4	; ECX *= 512 * 18 * 2 / 4
		SUB		ECX, 512 / 4			; ECX -= 512 / 4
		CALL	memcpy					; memcpy()

; bootpack 시작

		MOV		EBX, BOOTPACK		; EBX = BOOTPACK
		MOV		ECX, [EBX + 16]		; ECX = *(EBX + 16)
		ADD		ECX, 3				; ECX += 3
		SHR		ECX, 2				; ECX /= 4
		JZ		skip				; if(SHR결과 == 0) goto skip
		MOV		ESI,[EBX + 20]		; ESI = *(EBX + 20)
		ADD		ESI,EBX				; ESI += EBX
		MOV		EDI,[EBX + 12]		; EDI = *(EBX + 12)
		CALL	memcpy				; memcpy()

skip:
		MOV		ESP,[EBX+12]			; ESP = *(EBX + 12)
		JMP		DWORD 2 * 8:0x0000001b	; 

waitkbdout:
		IN		 AL, 0x64			; 0x64번 포트에 온 데이터를 AL로
		AND		 AL, 0x02			; AL = AL | 0x02
		IN		 AL, 0x60 			; 0x60번 포트에 온 데이터를 AL로
		JNZ		 waitkbdout			; if(AND결과 != 0) goto waitkbdout
		RET							; return

memcpy:
		MOV		EAX, [ESI]			; EAX = *(ESI)
		ADD		ESI, 4				; ESI += 4
		MOV		[EDI], EAX			; *(EDI) = EAX
		ADD		EDI, 4				; EDI += 4
		SUB		ECX, 1				; ECX -= 1
		JNZ		memcpy				; if(SUB결과 != 0) goto memcpy
		RET							; return

; 우선은 신경쓰지 않아도 됨

		ALIGNB	16

GDT0:
		TIMES 8 DB 0x00							
		DW		0xffff, 0x0000, 0x9200, 0x00cf
		DW		0xffff, 0x0000, 0x9a28, 0x0047
		DW		0

GDTR0:
		DW		8 * 3 - 1
		DD		GDT0

		ALIGNB	16
		
bootpack:
