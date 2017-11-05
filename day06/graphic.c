#include "graphic.h"
#include "kernel.h"

extern const unsigned char fontData[][16];

void initPalette(void)	{
	static unsigned char RGBTable[16 * 3] = {
		0x00, 0x00, 0x00,	//  0: 검정
		0xff, 0x00, 0x00,	//  1: 밝은 빨강
		0x00, 0xff, 0x00,	//  2: 밝은 초록
		0xff, 0xff, 0x00,	//  3: 밝은 노랑
		0x00, 0x00, 0xff,	//  4: 밝은 파랑
		0xff, 0x00, 0xff,	//  5: 밝은 보라
		0x00, 0xff, 0xff,	//  6: 밝은 하늘
		0xff, 0xff, 0xff,	//  7: 하양
		0xc6, 0xc6, 0xc6,	//  8: 밝은 회색
		0x84, 0x00, 0x00,	//  9: 어두운 빨강
		0x00, 0x84, 0x00,	// 10: 어두운 초록
		0x84, 0x84, 0x00,	// 11: 어두운 노랑
		0x00, 0x00, 0x84,	// 12: 어두운 파랑
		0x84, 0x00, 0x84,	// 13: 어두운 보라
		0x00, 0x84, 0x84,	// 14: 어두운 하늘
		0x84, 0x84, 0x84	// 15: 어두운 회색
	};

	setPalette(0, 15, RGBTable);
}

void setPalette(int start, int end, unsigned char* RGB) {
    int eflags = loadEflags();

    cli();
    out8(0x03c8, start);

    for (int i = start; i <= end; ++i) {
        out8(0x03c9, RGB[0] / 4);
        out8(0x03c9, RGB[1] / 4);
        out8(0x03c9, RGB[2] / 4);
        RGB += 3;
    }

    storeEflags(eflags);
}

void fillBox8(unsigned char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1) {
    for (int y = y0; y < y1; ++y)   {
        for (int x = x0; x < x1; ++x)   {
            vram[y * xsize + x] = c;
        }
    }
}

void initScreen8(unsigned char* vram, int x, int y) {
    fillBox8(vram, x, COL8_DARK_CYAN,  0,          0, x, y - 28);
    fillBox8(vram, x, COL8_GRAY,       0, y - 28, x, y - 27);
    fillBox8(vram, x, COL8_WHITE,      0, y - 27, x, y - 26);
    fillBox8(vram, x, COL8_GRAY,       0, y - 26, x, y);

    fillBox8(vram, x, COL8_WHITE,      3, y - 24,    60, y - 23);
    fillBox8(vram, x, COL8_WHITE,      2, y - 24,     3, y - 3);
    fillBox8(vram, x, COL8_DARK_GRAY,  3, y -  4,    60, y - 3);
    fillBox8(vram, x, COL8_DARK_GRAY, 59, y - 23,    60, y - 4);
    fillBox8(vram, x, COL8_BLACK,      2, y -  3,    60, y - 2);
    fillBox8(vram, x, COL8_BLACK,     60, y - 24,    61, y - 2);

    fillBox8(vram, x, COL8_DARK_GRAY, x - 47, y - 24, x -  3, y - 23);
    fillBox8(vram, x, COL8_DARK_GRAY, x - 47, y - 23, x - 46, y - 3);
    fillBox8(vram, x, COL8_WHITE,     x - 47, y -  3, x -  3, y - 2);
    fillBox8(vram, x, COL8_WHITE,     x -  3, y - 24, x -  2, y - 2);
}

void putChar8(unsigned char* vram, int xsize, int x, int y, unsigned char c, const unsigned char* font) {
    for (int i = 0; i < 16; ++i)    {
        for (int j = 0; j < 8; ++j) {
            if (font[i] & (0x80 >> j))  {
                vram[(y + i) * xsize + x + j] = c;
            }
        }
    }
}

void putASCII8(unsigned char* vram, int xsize, int x, int y, unsigned char c, const char* s) {
    while (*s != '\0') {
        putChar8(vram, xsize, x, y, c, fontData[(unsigned char)*s++]);
        x += 8;
    }
}

void initCursor8(unsigned char* mouse, char bc) {
    static const char cursor[16][16] = {
        "**************..",
        "*ooooooooooo*...",
        "*oooooooooo*....",
        "*ooooooooo*.....",
        "*oooooooo*......",
        "*ooooooo*.......",
        "*ooooooo*.......",
        "*oooooooo*......",
        "*oooo**ooo*.....",
        "*ooo*..*ooo*....",
        "*oo*....*ooo*...",
        "*o*......*ooo*..",
        "**........*ooo*.",
        "*..........*ooo*",
        "............*oo*",
        ".............***",
    };
    for (int y = 0; y < 16; ++y) {
        for (int x = 0; x < 16; ++x) {
            unsigned char c = bc;
            switch (cursor[y][x]) {
                case '*':  c = COL8_BLACK; break;
                case 'o':  c = COL8_WHITE; break;
            }
            mouse[y * 16 + x] = c;
        }
    }
}

void putBlock8_8(unsigned char* vram, int xsize, int pxsize, int pysize, int px0, int py0, const unsigned char* buf, int bxsize) {
    for (int y = 0; y < pysize; ++y)    {
        for (int x = 0; x < pxsize; ++x)    {
            vram[(py0 + y) * xsize + (px0 + x)] = buf[y * bxsize + x];
        }
    }
}
