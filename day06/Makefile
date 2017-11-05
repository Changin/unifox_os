TARGET=boot.img

CFLAGS=-O2 --std=c11 -Wall -Wextra -Werror -fno-stack-protector

all:	$(TARGET)

.SUFFIXS:	.c .s .o

.s.o:
	nasm $< -f elf -o $@
.c.o:
	gcc -m32 -c -o $@ $(CFLAGS) $<

$(TARGET):	bootmgr.bin asmhead.bin kernel.bin
	cp bootmgr.bin $@
	ruby -e 'print "\0" * (0x4200-0x200)' >> $@
	cat asmhead.bin >> $@
	cat kernel.bin >> $@
	ruby -e 'size = File.size("$@"); print "\0" * (0x168000-size)' >> $@

bootmgr.bin:	bootmgr.o
	ld -m elf_i386 -N -e _start -Ttext 0x7c00 -S --oformat binary -o $@ $<

asmhead.bin:	asmhead.o
	ld -m elf_i386 -N -e _start -Ttext 0xc200 -S --oformat binary -o $@ $<

kernel.bin:	kernel.o graphic.o desctable.o stdio.o interrupt.o fifo.o asmfunc.o fontdata.o
	ld -m elf_i386 -T main.ls --oformat binary -o $@ $^

clean:
	rm -f *.o *.bin $(TARGET)
