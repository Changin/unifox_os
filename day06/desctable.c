#include "desctable.h"
#include "kernel.h"
#include "interrupt.h"

struct SEGMENT_DESCRIPTOR {
    short limit_low, base_low;
    char base_mid, access_right;
    char limit_high, base_high;
};

struct GATE_DESCRIPTOR {
    short offset_low, selector;
    char dw_count, access_right;
    short offset_high;
};

void setSegDesc(struct SEGMENT_DESCRIPTOR* sd, unsigned int limit, int base, int ar) {
    if (limit > 0xfffff) {
        ar |= 0x8000;
        limit /= 0x1000;
    }
    sd->limit_low = limit & 0xffff;
    sd->base_low = base & 0xffff;
    sd->base_mid = (base >> 16) & 0xff;
    sd->access_right = ar & 0xff;
    sd->limit_high = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
    sd->base_high = (base >> 24) & 0xff;
}

void setGateDesc(struct GATE_DESCRIPTOR* gd, int offset, int selector, int ar) {
    gd->offset_low = offset & 0xffff;
    gd->selector = selector;
    gd->dw_count = (ar >> 8) & 0xff;
    gd->access_right = ar & 0xff;
    gd->offset_high = (offset >> 16) & 0xffff;
}

void initGDTIDT(void) {
    struct SEGMENT_DESCRIPTOR* gdt = (struct SEGMENT_DESCRIPTOR*)ADR_GDT;
    struct GATE_DESCRIPTOR* idt = (struct GATE_DESCRIPTOR*)ADR_IDT;

    for (int i = 0; i < LIMIT_GDT / 8; ++i) {
        setSegDesc(gdt + i, 0, 0, 0);
    }
    setSegDesc(gdt + 1, 0xffffffff, 0x00000000, AR_DATA32_RW);
    setSegDesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER);
    loadGdtr(LIMIT_GDT, ADR_GDT);

    for (int i = 0; i < LIMIT_IDT / 8; ++i) {
        setGateDesc(idt + i, 0, 0, 0);
    }
    loadIdtr(LIMIT_IDT, ADR_IDT);

    setGateDesc(idt + 0x21, (int)asmInt21, 2 * 8, AR_INTGATE32);
    setGateDesc(idt + 0x2c, (int)asmInt2c, 2 * 8, AR_INTGATE32);
}
