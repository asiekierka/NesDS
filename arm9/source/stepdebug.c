#include <nds.h>
#include "c_defs.h"
#include "NesMachine.h"

unsigned int stepinfo[1024];
extern unsigned int *pstep;

unsigned char ptbuf[1024] = 
/*1234567890123456789012345678901*/
"frame:         line:            "
"pc:                             "
"A:   X:   Y:   P:   SP:         "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
"                                "
;

void shex(unsigned char *p,int d,int n) {
	u16 c;
	do {
		c=d&0x0f;
		if(c<10) c+='0';
		else c=c-10+'A';
		d>>=4;
		p[n--]=c;
	} while(n>=0);
}

#define shex8(a,b) shex(a,b,1)
#define shex16(a,b) shex(a,b,3)
#define shex24(a,b) shex(a,b,5)
#define shex32(a,b) shex(a,b,7)


void stepdebug()
{ 
	static int frameCount = 0;
	static int line, keys, oldkeys, opCount = 0;
	unsigned int i;
	i = 0;
	opCount++;
	if(line == 240 && globals.ppu.scanline == 241) {
		frameCount++;
		swiWaitForVBlank();
		//keys = IPC_KEYS;
		keys &= ~KEY_SELECT;
	}
	if(keys & KEY_SELECT) {
		line = globals.ppu.scanline;
		//pstep = stepinfo;
		return;
	}
	if(keys & KEY_R && line == globals.ppu.scanline) {
		return;
	}
	line = globals.ppu.scanline;
	shex32(ptbuf + 6, frameCount);
	shex16(ptbuf + 20, globals.ppu.scanline);
//	shex16(ptbuf + 32 + 3, m6502Base.regPc - m6502Base.lastBank);
//	shex8(ptbuf + 32 + 8, *m6502Base.regPc);
//	shex8(ptbuf + 32 + 11, *(m6502Base.regPc + 1));
//	shex8(ptbuf + 32 + 14, *(m6502Base.regPc + 2));
	shex32(ptbuf + 50, opCount);

	shex8(ptbuf + 64 + 2, m6502Base.regA>>24);
	shex8(ptbuf + 64 + 7, m6502Base.regX>>24);
	shex8(ptbuf + 64 + 12, m6502Base.regY>>24);
	shex8(ptbuf + 64 + 17, m6502Base.cycles);

	for(i = 0; i < 8; i++) {
		shex8(ptbuf + 96 + 3*i, globals.ppu.nesChrMap[i]);
	}
	for(i = 0; i < 4; i++) {
		shex8(ptbuf + 128 + 3*i, globals.ppu.nesChrMap[i + 8]);
	}
	for(i = 4; i < 8; i++) {
//		shex8(ptbuf + 128 + 3*i, ((m6502Base.memTbl[i] - globals.romBase) >> 13) + i);
	}

	consoletext(0, ptbuf, 0);
	//memset( ptbuf + 192 + count * 8, 32, (18 * 4 - count) * 8);

	do {
		IPC_KEYS = keysCurrent();
		keys = IPC_KEYS;
		if(keys & oldkeys & (KEY_SELECT | KEY_R | KEY_L)) {
			//pstep = stepinfo;
			return;
		}
		if(keys & (KEY_SELECT | KEY_R | KEY_L)) {
			//pstep = stepinfo;
			break;
		}
		swiWaitForVBlank();
		oldkeys = 0;
	}
	while(1);
	oldkeys = keys;
	//pstep = stepinfo;
}
