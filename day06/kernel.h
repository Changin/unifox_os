#ifndef __KERNEL_H__
#define __KERNEL_H__

struct BOOTINFO {
    char cyls;
    char leds;  
    char vmode; 
    char reserve;
    short scrnx, scrny;
    unsigned char* vram;
};

#define ADDRESS_BOOTINFO  0x00000ff0;

void hlt(void);
void cli(void);
void sti(void);
void stihlt(void);
int in8(int port);
void out8(int port, int data);
int loadEflags(void);
void storeEflags(int eflags);

void loadGdtr(int limit, int addr);
void loadIdtr(int limit, int addr);

#endif
