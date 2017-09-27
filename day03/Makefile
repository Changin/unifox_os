AS = nasm
TEST = qemu-system-i386

all : run

ipl.bin : ipl.asm Makefile
	$(AS) ipl.asm -f bin -o ipl.bin

run : ipl.bin
	$(TEST) -L . -boot c -m 256 -hda ipl.bin