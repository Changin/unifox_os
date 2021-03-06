#include "stdio.h"

static char* itoa(char *s, int x, int base, const char* table, char padding, int keta) {
    int first = TRUE, negative = FALSE;

    if (x < 0) {
        x = -x;
        negative = TRUE;
    }
    *(--s) = '\0';
    do {
        if (first || x != 0)    {
            *(--s) = table[x % base];
        }
        else    {
            *(--s) = padding;
        }
        x /= base;
        --keta;
        first = FALSE;
    } while (x > 0 || keta > 0);
    if (negative)   {
        *(--s) = '-';
    }
    return s;
}

char* strcpy(char* dst, char* src) {
    char* orgDst = dst;

    while (1) {
        if ((*dst++ = *src++) == '\0')  {
            break;
        }
    }
    return orgDst;
}

int sprintf(char *str, const char *fmt, ...) {
    static const char hextable[] = "0123456789abcdef";
    int* arg = (int*)(&(&fmt)[1]);
    char* dst = str;

    while (*fmt != '\0') {
        if (*fmt != '%') {
            *dst++ = *fmt++;
            continue;
        }

        int keta = 0;
        char padding = ' ';
        char buf[sizeof(int) * 3 + 1], *last = &buf[sizeof(buf)];
        char* q;
  again:
        switch (*(++fmt)) {
            case '\0':  continue;
            case '0': padding = '0'; goto again;
            case '1': 
            case '2': 
            case '3': 
            case '4': 
            case '5': 
            case '6': 
            case '7': 
            case '8': 
            case '9': keta = *fmt - '0';  goto again;
            case 'd': q = itoa(last, *arg++, 10, hextable, padding, keta); break;
            case 'x': q = itoa(last, *arg++, 16, hextable, padding, keta); break;
            default: *dst++ = *fmt++; continue;
        }
        strcpy(dst, q);
        dst += (last - q) - 1;
        ++fmt;
    }
    *dst = '\0';
    return dst - str;
}
