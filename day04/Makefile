TARGET=boot.img

CFLAGS=-O2 --std=c11 -Wall -Wextra -Werror

all:	$(TARGET)

.SUFFIXS:	.c .s .o

.s.o:
	nasm $< -f elf -o $@
.c.o:
	gcc -m32 -c -o $@ $(CFLAGS) $<

$(TARGET):	ipl.bin haribote.bin bootpack.bin
	cp ipl.bin $@
	ruby -e 'print "\0" * (0x4200-0x200)' >> $@
	cat haribote.bin >> $@
	cat bootpack.bin >> $@
	ruby -e 'size = File.size("$@"); print "\0" * (0x168000-size)' >> $@

ipl.bin:	ipl.o
	ld -m elf_i386 -N -e _start -Ttext 0x7c00 -S --oformat binary -o $@ $<

haribote.bin:	haribote.o
	ld -m elf_i386 -N -e _start -Ttext 0xc200 -S --oformat binary -o $@ $<

bootpack.bin:	bootpack.o naskfunc.o
	ld -m elf_i386 -T harimain.ls --oformat binary -o $@ $^

clean:
	rm -f *.o *.bin $(TARGET)
