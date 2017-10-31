ORG		0x7c00					; Start at 0x7c00

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
times 18 db 0x00		; Padding (18 Byte)

entry:
	MOV		AX, 0			; AX = 0
	MOV		SS, AX			; SS = AX
	MOV		SP, 0x7c00		; SP = 0x7c00
	MOV		DS, AX			; DS = AX
	MOV		ES, AX			; ES = AX

	MOV		SI, msg			; SI = msg

putloop:
	MOV		AL,[SI]			; AL = &SI
	ADD		SI, 1			; SI += 1
	CMP		AL, 0			; if(AL == 0)
	JE		fin				; goto fin
	MOV		AH, 0x0e		; else, AH = 0x0e
	MOV		BX, 15			; BX = 15
	INT		0x10			; Call VBIOS
	JMP		putloop			; goto putloop
		
fin:
	HLT					    ; Halt CPU
	JMP		fin			    ; goto fin

msg:
	DW		0x0d0a, 0x0d0a	; "\n\n"
	DB		"Hello, World!!"; "Hello, World!!"
	DW		0x0d0a			; "\n"


times 510-($-$$) db 0x00	; Rest of sector fills with 0

DB		0x55, 0xaa			; 55 AA