#ifndef __FIFO_H__
#define __FIFO_H__

struct FIFO8 {
    unsigned char* buffer;
    int p, q, size, free, flags;
};
void initFIFO8(struct FIFO8* FIFO, int size, unsigned char* buffer);
int putFIFO8(struct FIFO8* FIFO, unsigned char data);
int getFIFO8(struct FIFO8* FIFO);
int getStatusFIFO8(struct FIFO8* FIFO);

#endif
