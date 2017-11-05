#include "interrupt.h"
#include "kernel.h"
#include "fifo.h"
#include "graphic.h"
#include "stdio.h"

static const int PORT_KEYDAT = 0x0060;

struct FIFO8 keyFIFO;
struct FIFO8 mouseFIFO;

void initPIC(void) {
    out8(PIC0_IMR, 0xff); 
    out8(PIC1_IMR, 0xff);

    out8(PIC0_ICW1, 0x11);   
    out8(PIC0_ICW2, 0x20);  
    out8(PIC0_ICW3, 1 << 2);  
    out8(PIC0_ICW4, 0x01); 

    out8(PIC1_ICW1, 0x11);    
    out8(PIC1_ICW2, 0x28);    
    out8(PIC1_ICW3, 2); 
    out8(PIC1_ICW4, 0x01);  

    out8(PIC0_IMR, 0xfb);  
    out8(PIC1_IMR, 0xff);
}

void int21() {
    out8(PIC0_OCW2, 0x61);
    unsigned char data = in8(PORT_KEYDAT);
    putFIFO8(&keyFIFO, data);
}

void int2c() {
    out8(PIC1_OCW2, 0x64);
    out8(PIC0_OCW2, 0x62);
    unsigned char data = in8(PORT_KEYDAT);
    putFIFO8(&mouseFIFO, data);
}
