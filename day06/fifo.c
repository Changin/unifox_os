#include "fifo.h"

const int FLAGS_OVERRUN = 1 << 0;

void initFIFO8(struct FIFO8* FIFO, int size, unsigned char* buffer) {
    FIFO->buffer = buffer;
    FIFO->size = FIFO->free = size;
    FIFO->p = FIFO->q = 0;
    FIFO->flags = 0;
}

int putFIFO8(struct FIFO8* FIFO, unsigned char data) {
    if (FIFO->free == 0) {
        FIFO->flags |= FLAGS_OVERRUN;
        return -1;
    }
    FIFO->buffer[FIFO->p] = data;
    if (++FIFO->p >= FIFO->size)    {
        FIFO->p = 0;
    }
    --FIFO->free;
    return 0;
}

int getFIFO8(struct FIFO8* FIFO) {
    if (FIFO->free == FIFO->size)   {
        return -1;
    }
    int data = FIFO->buffer[FIFO->q];
    if (++FIFO->q >= FIFO->size)    {
        FIFO->q = 0;
    }
    ++FIFO->free;
    return data;
}

int getStatusFIFO8(struct FIFO8* FIFO) {
  return FIFO->size - FIFO->free;
}
