#ifndef __GRAPHIC_H__
#define __GRAPHIC_H__

static const int COL8_BLACK = 0;
static const int COL8_RED = 1;
static const int COL8_GREEN = 2;
static const int COL8_YELLOW = 3;
static const int COL8_BLUE = 4;
static const int COL8_PURPLE = 5;
static const int COL8_CYAN = 6;
static const int COL8_WHITE = 7;
static const int COL8_GRAY = 8;
static const int COL8_DARK_RED = 9;
static const int COL8_DARK_GREEN = 10;
static const int COL8_DARK_YELLOW = 11;
static const int COL8_DARK_BLUE = 12;
static const int COL8_DARK_PURPLE = 13;
static const int COL8_DARK_CYAN = 14;
static const int COL8_DARK_GRAY = 15;

void initPalette(void);
void setPalette(int start, int end, unsigned char* rgb);
void fillBox8(unsigned char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);
void initScreen8(unsigned char* vram, int x, int y);
void putFont8(unsigned char* vram, int xsize, int x, int y, unsigned char c, const unsigned char* font);
void putASCII8(unsigned char* vram, int xsize, int x, int y, unsigned char c, const char* s);
void initCursor8(unsigned char* mouse, char bc);
void putBlock8_8(unsigned char* vram, int xsize, int pxsize, int pysize,
                 int px0, int py0, const unsigned char* buf, int bxsize);

#endif
