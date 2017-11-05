CYLS	EQU		10				; 실린더

[BITS 16]

global _start

_start:
; Standard FAT12 BPB
		JMP		entry
		DB		0x90
		DB		"EXAM-IPL"		; OEM Name
		DW		512			    ; Bytes Per Sector(512, 1024, 2048, 4096, usually use 512)
		DB		1			    ; Sector Per Cluster(1, 2, 4, 8, 16, 32, 64, 128, usually use 1)
		DW		1			    ; Reserved Sector Count(FAT12, FAT16 = 1, FAT32 = 2)
		DB		2			    ; Number of FATs(FAT, Backup FAT)
		DW		224			    ; Boot Entry Count
		DW		2880			; Total Sector
		DB		0xf0			; Media Type(Floopy Disk = 0xf0, Hard Disk = 0xf8)
		DW		9			    ; FAT Size
		DW		18			    ; Sector Per Track
		DW		2			    ; Number of Heads
		DD		0			    ; Hidden Sector
		DD		2880			; Total Sector
		DB		0				; Drive Number
		DB		0				; Reserved1
		DB		0x29			; Boot Signature
		DD		0xffffffff		; Volume ID
		DB		"EXAMPLE-OS "	; Volume Lable(11 Byte)
		DB		"FAT12   "		; File System Type (8 Byte)
		TIMES 18 DB 0x00		; Padding (18 Byte)

; 

entry:
		MOV		AX, 0			; AX = 0
		MOV		SS, AX			; SS = AX
		MOV		SP, 0x7c00		; SP = 0x7c00
		MOV		DS, AX			; DS = AX

		MOV		AX, 0x0820		; AX = 0x0820
		MOV		ES, AX			; ES = AX = 0x0820
		MOV		CH, 0			; CH = 0 (실린더 0)
		MOV		DH, 0			; DH = 0 (헤드 0)
		MOV		CL, 2			; CL = 2 (섹터 2)

readloop:
		MOV		SI, 0			; SI = 0 (실패 횟수 0)

retry:
		MOV		AH, 0x02		; AH = 0x02 (디스크 읽기)
		MOV		AL, 1			; AL = 1 (섹터 1개)
		MOV		BX, 0			; BX = 0
		MOV		DL, 0x00		; DL = 0 (0번째 드라이브)
		INT		0x13			; INT 13h
		JNC		next			; if(CF != 1) goto next
		ADD		SI, 1			; SI += 1
		CMP		SI, 5			; SI == 5?
		JAE		error			; if (SI >= 5) goto error
		MOV		AH,0x00			; AH = 0x00 (디스크 리셋)
		MOV		DL, 0x00		; DL = 0x00 (0번째 드라이브)
		INT		0x13			; INT 13h
		JMP		retry			; goto retry

next:
		MOV		AX, ES			; AX = ES
		ADD		AX,0x0020		; AX += 0x0020
		MOV		ES, AX			; ES = AX
		ADD		CL, 1			; CL += 1
		CMP		CL, 18			; CL == 18?
		JBE		readloop		; if(CL <= 18) goto readloop
		MOV		CL,1			; CL = 1
		ADD		DH,1			; DH += 1
		CMP		DH,2			; DH == 2?
		JB		readloop		; if(DH < 2) goto readloop
		MOV		DH,0			; DH = 0
		ADD		CH,1			; CH = 1
		CMP		CH,CYLS			; CH == CYLS?
		JB		readloop		; if(CH < CYLS) goto readloop

		MOV		[0x0ff0], CH	; *(0x0ff0) = CH
		JMP		0xc200			; goto 0xc200

error:
		MOV		AX,0			; AX = 0
		MOV		ES,AX			; ES = 0
		MOV		SI,msg			; SI = msg
putloop:
		MOV		AL,[SI]			; AL = *(SI)
		ADD		SI, 1			; SI += 1
		CMP		AL,0			; AL == 0?
		JE		fin				; if(AL == 0) goto fin
		MOV		AH, 0x0e		; AH = 0x0e
		MOV		BX, 15			; BX = 15
		INT		0x10			; INT 10h
		JMP		putloop			; goto putloop

fin:
		HLT						; CPU 정지
		JMP		fin				; goto fin
msg:
		DW		0x0d0a, 0x0d0a	; "\n\n"
		DB		"Load Error"		; "Load Error"
		DW		0x0d0a				; "\n"

		TIMES 510-($-$$)	DB 0x00		; 0x7dfe까지 다 0으로 채움

		DB		0x55, 0xAA			; 55 AA