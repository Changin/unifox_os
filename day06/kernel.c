#include "kernel.h"
#include "desctable.h"
#include "fifo.h"
#include "graphic.h"
#include "interrupt.h"
#include "stdio.h"

static const int PORT_KEYDAT = 0x0060;
static const int PORT_KEYSTA = 0x0064;
static const int PORT_KEYCMD = 0x0064;
static const int KEYSTA_SEND_NOTREADY = 0x02;
static const int KEYCMD_WRITE_MODE = 0x60;
static const int KBC_MODE = 0x47;

static const int KEYCMD_SENDTO_MOUSE = 0xd4;
static const int MOUSECMD_ENABLE = 0xf4;

void waitKBCSendReady(void) {
    while (1)    {
        if ((in8(PORT_KEYSTA) & KEYSTA_SEND_NOTREADY) == 0)  {
            break;
        }
    }
}

void initKeyboard(void) {
    waitKBCSendReady();
    out8(PORT_KEYCMD, KEYCMD_WRITE_MODE);
    waitKBCSendReady();
    out8(PORT_KEYDAT, KBC_MODE);
}

void enableMouse(void) {
    waitKBCSendReady();
    out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
    waitKBCSendReady();
    out8(PORT_KEYDAT, MOUSECMD_ENABLE);
}

void Main(void) {
    unsigned char keyBuffer[32], mouseBuffer[128];
    struct BOOTINFO* bootInfo = (struct BOOTINFO*)ADDRESS_BOOTINFO;
    unsigned char cursor[256];
    int mx = (bootInfo->scrnx - 16) / 2;
    int my = (bootInfo->scrny - 28 - 16) / 2;
    char xy[40];
    char s[4];

    initGDTIDT();
    initPIC();
    sti();

    initFIFO8(&keyFIFO, 32, keyBuffer);
    initFIFO8(&mouseFIFO, 128, mouseBuffer);
    out8(PIC0_IMR, 0xf9);
    out8(PIC1_IMR, 0xef);

    initKeyboard();

    initPalette();
    initScreen8(bootInfo->vram, bootInfo->scrnx, bootInfo->scrny);

  
    initCursor8(cursor, COL8_DARK_CYAN);
    putBlock8_8(bootInfo->vram, bootInfo->scrnx, 16, 16, mx, my, cursor, 16);

    sprintf(xy, "(%d, %d)", mx, my);
    putASCII8(bootInfo->vram, bootInfo->scrnx, 0, 0, COL8_WHITE, xy);

    enableMouse();

    while (1) {
        cli();
        if (getStatusFIFO8(&keyFIFO) != 0) {
            int i = getFIFO8(&keyFIFO);;

            sti();

            sprintf(s, "%02x", i);
            fillBox8(bootInfo->vram, bootInfo->scrnx, COL8_DARK_CYAN, 0, 16, 16, 32);
            putASCII8(bootInfo->vram, bootInfo->scrnx, 0, 16, COL8_WHITE, s);
            continue;
        }
        if (getStatusFIFO8(&mouseFIFO) != 0) {
            int i = getFIFO8(&mouseFIFO);

            sti();

            sprintf(s, "%02x", i);
            fillBox8(bootInfo->vram, bootInfo->scrnx, COL8_DARK_CYAN, 32, 16, 48, 32);
            putASCII8(bootInfo->vram, bootInfo->scrnx, 32, 16, COL8_WHITE, s);
            continue;
        }

        stihlt();
    }
}
