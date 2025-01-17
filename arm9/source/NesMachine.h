#ifndef NESMACHINE_HEADER
#define NESMACHINE_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "M6502.h"
#include "RP2C02.h"

typedef struct {
	M6502Core cpu;
	PPUCore ppu;
	u8 mapperData[96];

	u32 *romBase;
	u32 romMask;
	u32 prgSize8k;
	u32 prgSize16k;
	u32 prgSize32k;
	u32 emuFlags;
	u32 prgCrc;

	u32 lightY;

	u32 renderCount;
	u32 tempData[20];

	u8 cartFlags;
	u8 padding[3];
} NESCore;

extern M6502Core m6502Base;
extern NESCore globals;

#ifdef __cplusplus
}
#endif

#endif // NESMACHINE_HEADER
