@---------------------------------------------------------------------------------
	#include "M6502mac.h"
	#include "macro.h"
@---------------------------------------------------------------------------------	
	.global m6502Reset
	.global defaultScanlineHook
	.global Vec6502
	.global m6502NMI
	.global CheckI

	.global m6502OpTable

@---------------------------------------------------------------------------------
.section .itcm, "ax"
@---------------------------------------------------------------------------------
_xx:@	???					@invalid opcode
@---------------------------------------------------------------------------------
#ifdef DEBUG
	ldr_ r1,m6502BadOpCount
	add r1,r1,#1
	str_ r1,m6502BadOpCount
#endif
	bl debugStep
	fetch 2
@---------------------------------------------------------------------------------
_00:@   BRK
@---------------------------------------------------------------------------------
#ifdef DEBUG
	ldr_ r1,m6502BRKCount
	add r1,r1,#1
	str_ r1,m6502BRKCount
#endif
	bl debugStep

	ldr_ r0,m6502LastBank
	sub r1,m6502pc,r0
	add r0,r1,#1
	push16			@save PC

	encodeP (B+R)		@save P

	ldr r12,=IRQ_VECTOR
	bl VecCont

	fetch 7
	.ltorg
@---------------------------------------------------------------------------------
_01:@   ORA ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opORA
	fetch 6
@---------------------------------------------------------------------------------
_05:@   ORA $nn
@---------------------------------------------------------------------------------
	doZ
	opORA
	fetch 3
@---------------------------------------------------------------------------------
_06:@   ASL $nn
@---------------------------------------------------------------------------------
	doZ
	opASL
	@fetch_c 5
	fetch 5
@---------------------------------------------------------------------------------
_08:@   PHP
@---------------------------------------------------------------------------------
	encodeP (B+R)
	push8 r0
	fetch 3
@---------------------------------------------------------------------------------
_09:@   ORA #$nn
@---------------------------------------------------------------------------------
	doIMM
	opORA
	fetch 2
@---------------------------------------------------------------------------------
_0A:@   ASL
@---------------------------------------------------------------------------------
	adds m6502a,m6502a,m6502a
	mov m6502nz,m6502a,asr#24		@NZ
	orr cycles,cycles,#CYC_C		@Prepare C
	fetch_c 2						@also subs carry
@---------------------------------------------------------------------------------
_0D:@   ORA $nnnn
@---------------------------------------------------------------------------------
	doABS
	opORA
	fetch 4
@---------------------------------------------------------------------------------
_0E:@   ASL $nnnn
@---------------------------------------------------------------------------------
	doABS
	opASL
	@fetch_c 6
	fetch 6
@---------------------------------------------------------------------------------
_10:@   BPL *
@---------------------------------------------------------------------------------
	tst m6502nz,#0x80000000
	ldrsb r0,[m6502pc],#1
	addeq m6502pc,m6502pc,r0
	subeq cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_11:@   ORA ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opORA
	fetch 5
@---------------------------------------------------------------------------------
_15:@   ORA $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opORA
	fetch 4
@---------------------------------------------------------------------------------
_16:@   ASL $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opASL
	@fetch_c 6
	fetch 6
@---------------------------------------------------------------------------------
_18:@   CLC
@---------------------------------------------------------------------------------
	bic cycles,cycles,#CYC_C
	fetch 2
@---------------------------------------------------------------------------------
_19:@   ORA $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opORA
	fetch 4
@---------------------------------------------------------------------------------
_1D:@   ORA $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opORA
	fetch 4
@---------------------------------------------------------------------------------
_1E:@   ASL $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opASL
	@fetch_c 7
	fetch 7
@---------------------------------------------------------------------------------
_20:@   JSR $nnnn
@---------------------------------------------------------------------------------
	ldrb r2,[m6502pc],#1
	ldr_ r1,m6502LastBank
	sub r0,m6502pc,r1
	ldrb r1,[m6502pc]
	orr m6502pc,r2,r1,lsl#8
	push16
	encodePC
	fetch 6
@---------------------------------------------------------------------------------
_21:@   AND ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opAND
	fetch 6
@---------------------------------------------------------------------------------
_24:@   BIT $nn
@---------------------------------------------------------------------------------
	doZ
	opBIT
	fetch 3
@---------------------------------------------------------------------------------
_25:@   AND $nn
@---------------------------------------------------------------------------------
	doZ
	opAND
	fetch 3
@---------------------------------------------------------------------------------
_26:@   ROL $nn
@---------------------------------------------------------------------------------
	doZ
	opROL
	fetch 5
@---------------------------------------------------------------------------------
_28:@   PLP
@---------------------------------------------------------------------------------
	pop8 r0
	decodeP
	fetch 4
@---------------------------------------------------------------------------------
_29:@   AND #$nn
@---------------------------------------------------------------------------------
	doIMM
	opAND
	fetch 2
@---------------------------------------------------------------------------------
_2A:@   ROL
@---------------------------------------------------------------------------------
	movs cycles,cycles,lsr#1		@get C
	orrcs m6502a,m6502a,#0x00800000
	adds m6502a,m6502a,m6502a
	mov m6502nz,m6502a,asr#24		@NZ
	adc cycles,cycles,cycles		@Set C
	fetch 2
@---------------------------------------------------------------------------------
_2C:@   BIT $nnnn
@---------------------------------------------------------------------------------
	doABS
	opBIT
	fetch 4
@---------------------------------------------------------------------------------
_2D:@   AND $nnnn
@---------------------------------------------------------------------------------
	doABS
	opAND
	fetch 4
@---------------------------------------------------------------------------------
_2E:@   ROL $nnnn
@---------------------------------------------------------------------------------
	doABS
	opROL
	fetch 6
@---------------------------------------------------------------------------------
_30:@   BMI *
@---------------------------------------------------------------------------------
	tst m6502nz,#0x80000000
	ldrsb r0,[m6502pc],#1
	addne m6502pc,m6502pc,r0
	subne cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_31:@   AND ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opAND
	fetch 5
@---------------------------------------------------------------------------------
_35:@   AND $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opAND
	fetch 4
@---------------------------------------------------------------------------------
_36:@   ROL $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opROL
	fetch 6
@---------------------------------------------------------------------------------
_38:@   SEC
@---------------------------------------------------------------------------------
	orr cycles,cycles,#CYC_C
	fetch 2
@---------------------------------------------------------------------------------
_39:@   AND $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opAND
	fetch 4
@---------------------------------------------------------------------------------
_3D:@   AND $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opAND
	fetch 4
@---------------------------------------------------------------------------------
_3E:@   ROL $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opROL
	fetch 7
@---------------------------------------------------------------------------------
_40:@   RTI
@---------------------------------------------------------------------------------
	pop8 r0		@pop 6502 flags and decode
	decodeP
	pop16		@pop the return address
	encodePC
@	sub cycles,cycles,#6*3*CYCLE	@not implemented yet in PocketNES.
@	b checkirqdisable				@Fixes ???
	fetch 6
@---------------------------------------------------------------------------------
_41:@   EOR ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opEOR
	fetch 6
@---------------------------------------------------------------------------------
_45:@   EOR $nn
@---------------------------------------------------------------------------------
	doZ
	opEOR
	fetch 3
@---------------------------------------------------------------------------------
_46:@   LSR $nn
@---------------------------------------------------------------------------------
	doZ
	opLSR
	fetch 5
@---------------------------------------------------------------------------------
_48:@   PHA
@---------------------------------------------------------------------------------
	mov r0,m6502a,lsr#24
	push8 r0
	fetch 3
@---------------------------------------------------------------------------------
_49:@   EOR #$nn
@---------------------------------------------------------------------------------
	doIMM
	opEOR
	fetch 2
@---------------------------------------------------------------------------------
_4A:@   LSR
@---------------------------------------------------------------------------------
	movs m6502nz,m6502a,lsr#25	@Z, N=0
	mov m6502a,m6502nz,lsl#24		@result without garbage
	orr cycles,cycles,#CYC_C		@Prepare C
	fetch_c 2
@---------------------------------------------------------------------------------
_4C:@   JMP $nnnn
@---------------------------------------------------------------------------------
	ldrb r0,[m6502pc],#1
	ldrb r1,[m6502pc]
	orr m6502pc,r0,r1,lsl#8
	encodePC
	fetch 3
@---------------------------------------------------------------------------------
_4D:@   EOR $nnnn
@---------------------------------------------------------------------------------
	doABS
	opEOR
	fetch 4
@---------------------------------------------------------------------------------
_4E:@   LSR $nnnn
@---------------------------------------------------------------------------------
	doABS
	opLSR
	fetch 6
@---------------------------------------------------------------------------------
_50:@   BVC *
@---------------------------------------------------------------------------------
	tst cycles,#CYC_V
	ldrsb r0,[m6502pc],#1
	addeq m6502pc,m6502pc,r0
	subeq cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_51:@   EOR ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opEOR
	fetch 5
@---------------------------------------------------------------------------------
_55:@   EOR $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opEOR
	fetch 4
@---------------------------------------------------------------------------------
_56:@   LSR $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opLSR
	fetch 6
@---------------------------------------------------------------------------------
_58:@   CLI
@---------------------------------------------------------------------------------
	bic cycles,cycles,#CYC_I
@	sub cycles,cycles,#2*3*CYCLE	@not implemented yet on PocketNES
@	b checkirqs						@Fixes ???
	fetch 2
@---------------------------------------------------------------------------------
_59:@   EOR $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opEOR
	fetch 4
@---------------------------------------------------------------------------------
_5D:@   EOR $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opEOR
	fetch 4
@---------------------------------------------------------------------------------
_5E:@   LSR $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opLSR
	fetch 7
@---------------------------------------------------------------------------------
_60:@   RTS
@---------------------------------------------------------------------------------
	pop16
	add m6502pc,m6502pc,#1
	encodePC
	fetch 6
@---------------------------------------------------------------------------------
_61:@   ADC ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opADC
	fetch_c 6
@---------------------------------------------------------------------------------
_65:@   ADC $nn
@---------------------------------------------------------------------------------
	doZ
	opADC
	fetch_c 3
@---------------------------------------------------------------------------------
_66:@   ROR $nn
@---------------------------------------------------------------------------------
	doZ
	opROR
	fetch 5
@---------------------------------------------------------------------------------
_68:@   PLA
@---------------------------------------------------------------------------------
	pop8 m6502nz
	mov m6502a,m6502nz,lsl#24
	fetch 4
@---------------------------------------------------------------------------------
_69:@   ADC #$nn
@---------------------------------------------------------------------------------
	doIMM
	opADC
	fetch_c 2
@---------------------------------------------------------------------------------
_6A:@   ROR
@---------------------------------------------------------------------------------
	movs cycles,cycles,lsr#1		@get C
	mov m6502a,m6502a,rrx
	movs m6502nz,m6502a,asr#24	@NZ
	and m6502a,m6502a,#0xff000000
	adc cycles,cycles,cycles		@Set C
	fetch 2
@---------------------------------------------------------------------------------
_6C:@   JMP ($nnnn)
@---------------------------------------------------------------------------------
	doABS
	adr_ r1,m6502MemTbl
	and r2,addy,#0xE000
	ldr r1,[r1,r2,lsr#11]
	ldrb m6502pc,[r1,addy]!
	ldrb r0,[r1,#1]
	orr m6502pc,m6502pc,r0,lsl#8
	encodePC
	fetch 5
@---------------------------------------------------------------------------------
_6D:@   ADC $nnnn
@---------------------------------------------------------------------------------
	doABS
	opADC
	fetch_c 4
@---------------------------------------------------------------------------------
_6E:@   ROR $nnnn
@---------------------------------------------------------------------------------
	doABS
	opROR
	fetch 6
@---------------------------------------------------------------------------------
_70:@   BVS *
@---------------------------------------------------------------------------------
	tst cycles,#CYC_V
	ldrsb r0,[m6502pc],#1
	addne m6502pc,m6502pc,r0
	subne cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_71:@   ADC ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opADC
	@fetch_c 5
	fetch_c 4
@---------------------------------------------------------------------------------
_75:@   ADC $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opADC
	fetch_c 4
@---------------------------------------------------------------------------------
_76:@   ROR $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opROR
	fetch 6
@---------------------------------------------------------------------------------
_78:@   SEI
@---------------------------------------------------------------------------------
	orr cycles,cycles,#CYC_I
	fetch 2
@---------------------------------------------------------------------------------
_79:@   ADC $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opADC
	fetch_c 4
@---------------------------------------------------------------------------------
_7D:@   ADC $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opADC
	fetch_c 4
@---------------------------------------------------------------------------------
_7E:@   ROR $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opROR
	fetch 7
@---------------------------------------------------------------------------------
_81:@   STA ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opSTORE m6502a
	fetch 6
@---------------------------------------------------------------------------------
_84:@   STY $nn
@---------------------------------------------------------------------------------
	doZ
	opSTORE m6502y
	fetch 3
@---------------------------------------------------------------------------------
_85:@   STA $nn
@---------------------------------------------------------------------------------
	doZ
	opSTORE m6502a
	fetch 3
@---------------------------------------------------------------------------------
_86:@   STX $nn
@---------------------------------------------------------------------------------
	doZ
	opSTORE m6502x
	fetch 3
@---------------------------------------------------------------------------------
_88:@   DEY
@---------------------------------------------------------------------------------
	sub m6502y,m6502y,#0x01000000
	mov m6502nz,m6502y,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_8A:@   TXA
@---------------------------------------------------------------------------------
	mov m6502a,m6502x
	mov m6502nz,m6502x,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_8C:@   STY $nnnn
@---------------------------------------------------------------------------------
	doABS
	opSTORE m6502y
	fetch 4
@---------------------------------------------------------------------------------
_8D:@   STA $nnnn
@---------------------------------------------------------------------------------
	doABS
	opSTORE m6502a
	fetch 4
@---------------------------------------------------------------------------------
_8E:@   STX $nnnn
@---------------------------------------------------------------------------------
	doABS
	opSTORE m6502x
	fetch 4
@---------------------------------------------------------------------------------
_90:@   BCC *
@---------------------------------------------------------------------------------
	tst cycles,#CYC_C			@Test Carry
	ldrsb r0,[m6502pc],#1
	addeq m6502pc,m6502pc,r0
	subeq cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_91:@   STA ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opSTORE m6502a
	fetch 6
@---------------------------------------------------------------------------------
_94:@   STY $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opSTORE m6502y
	fetch 4
@---------------------------------------------------------------------------------
_95:@   STA $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opSTORE m6502a
	fetch 4
@---------------------------------------------------------------------------------
_96:@   STX $nn,Y
@---------------------------------------------------------------------------------
	doZIYf
	opSTORE m6502x
	fetch 4
@---------------------------------------------------------------------------------
_98:@   TYA
@---------------------------------------------------------------------------------
	mov m6502a,m6502y
	mov m6502nz,m6502y,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_99:@   STA $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opSTORE m6502a
	fetch 5
@---------------------------------------------------------------------------------
_9A:@   TXS
@---------------------------------------------------------------------------------
	mov r0,m6502x,lsr#24
	strb_ r0,m6502RegSP
	fetch 2
@---------------------------------------------------------------------------------
_9D:@   STA $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opSTORE m6502a
	fetch 5
@---------------------------------------------------------------------------------
_A0:@   LDY #$nn
@---------------------------------------------------------------------------------
	doIMM
	opLOAD m6502y
	fetch 2
@---------------------------------------------------------------------------------
_A1:@   LDA ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opLOAD m6502a
	fetch 6
@---------------------------------------------------------------------------------
_A2:@   LDX #$nn
@---------------------------------------------------------------------------------
	doIMM
	opLOAD m6502x
	fetch 2
@---------------------------------------------------------------------------------
_A4:@   LDY $nn
@---------------------------------------------------------------------------------
	doZ
	opLOAD m6502y
	fetch 3
@---------------------------------------------------------------------------------
_A5:@   LDA $nn
@---------------------------------------------------------------------------------
	doZ
	opLOAD m6502a
	fetch 3
@---------------------------------------------------------------------------------
_A6:@   LDX $nn
@---------------------------------------------------------------------------------
	doZ
	opLOAD m6502x
	fetch 3
@---------------------------------------------------------------------------------
_A8:@   TAY
@---------------------------------------------------------------------------------
	mov m6502y,m6502a
	mov m6502nz,m6502y,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_A9:@   LDA #$nn
@---------------------------------------------------------------------------------
	doIMM
	opLOAD m6502a
	fetch 2
@---------------------------------------------------------------------------------
_AA:@   TAX
@---------------------------------------------------------------------------------
	mov m6502x,m6502a
	mov m6502nz,m6502x,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_AC:@   LDY $nnnn
@---------------------------------------------------------------------------------
	doABS
	opLOAD m6502y
	fetch 4
@---------------------------------------------------------------------------------
_AD:@   LDA $nnnn
@---------------------------------------------------------------------------------
	doABS
	opLOAD m6502a
	fetch 4
@---------------------------------------------------------------------------------
_AE:@   LDX $nnnn
@---------------------------------------------------------------------------------
	doABS
	opLOAD m6502x
	fetch 4
@---------------------------------------------------------------------------------
_B0:@   BCS *
@---------------------------------------------------------------------------------
	tst cycles,#CYC_C			@Test Carry
	ldrsb r0,[m6502pc],#1
	addne m6502pc,m6502pc,r0
	subne cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_B1:@   LDA ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opLOAD m6502a
	fetch 5
@---------------------------------------------------------------------------------
_B4:@   LDY $nn,X
@---------------------------------------------------------------------------------
	doZIX
	opLOAD m6502y
	fetch 4
@---------------------------------------------------------------------------------
_B5:@   LDA $nn,X
@---------------------------------------------------------------------------------
	doZIX
	opLOAD m6502a
	fetch 4
@---------------------------------------------------------------------------------
_B6:@   LDX $nn,Y
@---------------------------------------------------------------------------------
	doZIY
	opLOAD m6502x
	fetch 4
@---------------------------------------------------------------------------------
_B8:@   CLV
@---------------------------------------------------------------------------------
	bic cycles,cycles,#CYC_V
	fetch 2
@---------------------------------------------------------------------------------
_B9:@   LDA $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opLOAD m6502a
	fetch 4
@---------------------------------------------------------------------------------
_BA:@   TSX
@---------------------------------------------------------------------------------
	ldrb_ m6502x,m6502RegSP
	mov m6502x,m6502x,lsl#24
	mov m6502nz,m6502x,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_BC:@   LDY $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opLOAD m6502y
	fetch 4
@---------------------------------------------------------------------------------
_BD:@   LDA $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opLOAD m6502a
	fetch 4
@---------------------------------------------------------------------------------
_BE:@   LDX $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opLOAD m6502x
	fetch 4
@---------------------------------------------------------------------------------
_C0:@   CPY #$nn
@---------------------------------------------------------------------------------
	doIMM
	opCOMP m6502y
	fetch_c 2
@---------------------------------------------------------------------------------
_C1:@   CMP ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opCOMP m6502a
	fetch_c 6
@---------------------------------------------------------------------------------
_C4:@   CPY $nn
@---------------------------------------------------------------------------------
	doZ
	opCOMP m6502y
	fetch_c 3
@---------------------------------------------------------------------------------
_C5:@   CMP $nn
@---------------------------------------------------------------------------------
	doZ
	opCOMP m6502a
	fetch_c 3
@---------------------------------------------------------------------------------
_C6:@   DEC $nn
@---------------------------------------------------------------------------------
	doZ
	opDEC
	fetch 5
@---------------------------------------------------------------------------------
_C8:@   INY
@---------------------------------------------------------------------------------
	add m6502y,m6502y,#0x01000000
	mov m6502nz,m6502y,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_C9:@   CMP #$nn
@---------------------------------------------------------------------------------
	doIMM
	opCOMP m6502a
	fetch_c 2
@---------------------------------------------------------------------------------
_CA:@   DEX
@---------------------------------------------------------------------------------
	sub m6502x,m6502x,#0x01000000
	mov m6502nz,m6502x,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_CC:@   CPY $nnnn
@---------------------------------------------------------------------------------
	doABS
	opCOMP m6502y
	fetch_c 4
@---------------------------------------------------------------------------------
_CD:@   CMP $nnnn
@---------------------------------------------------------------------------------
	doABS
	opCOMP m6502a
	fetch_c 4
@---------------------------------------------------------------------------------
_CE:@   DEC $nnnn
@---------------------------------------------------------------------------------
	doABS
	opDEC
	fetch 6
@---------------------------------------------------------------------------------
_D0:@   BNE *
@---------------------------------------------------------------------------------
	tst m6502nz,#0xff
	ldrsb r0,[m6502pc],#1
	addne m6502pc,m6502pc,r0
	subne cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_D1:@   CMP ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opCOMP m6502a
	fetch_c 5
@---------------------------------------------------------------------------------
_D5:@   CMP $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opCOMP m6502a
	fetch_c 4
@---------------------------------------------------------------------------------
_D6:@   DEC $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opDEC
	fetch 6
@---------------------------------------------------------------------------------
_D8:@   CLD
@---------------------------------------------------------------------------------
	bic cycles,cycles,#CYC_D
	fetch 2
@---------------------------------------------------------------------------------
_D9:@   CMP $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opCOMP m6502a
	fetch_c 4
@---------------------------------------------------------------------------------
_DD:@   CMP $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opCOMP m6502a
	fetch_c 4
@---------------------------------------------------------------------------------
_DE:@   DEC $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opDEC
	fetch 7
@---------------------------------------------------------------------------------
_E0:@   CPX #$nn
@---------------------------------------------------------------------------------
	doIMM
	opCOMP m6502x
	fetch_c 2
@---------------------------------------------------------------------------------
_E1:@   SBC ($nn,X)
@---------------------------------------------------------------------------------
	doIIX
	opSBC
	fetch_c 6
@---------------------------------------------------------------------------------
_E4:@   CPX $nn
@---------------------------------------------------------------------------------
	doZ
	opCOMP m6502x
	fetch_c 3
@---------------------------------------------------------------------------------
_E5:@   SBC $nn
@---------------------------------------------------------------------------------
	doZ
	opSBC
	fetch_c 3
@---------------------------------------------------------------------------------
_E6:@   INC $nn
@---------------------------------------------------------------------------------
	doZ
	opINC
	fetch 5
@---------------------------------------------------------------------------------
_E8:@   INX
@---------------------------------------------------------------------------------
	add m6502x,m6502x,#0x01000000
	mov m6502nz,m6502x,asr#24
	fetch 2
@---------------------------------------------------------------------------------
_E9:@   SBC #$nn
@---------------------------------------------------------------------------------
	doIMM
	opSBC
	fetch_c 2
@---------------------------------------------------------------------------------
_EA:@   NOP
@---------------------------------------------------------------------------------
	fetch 2
@---------------------------------------------------------------------------------
_EC:@   CPX $nnnn
@---------------------------------------------------------------------------------
	doABS
	opCOMP m6502x
	fetch_c 4
@---------------------------------------------------------------------------------
_ED:@   SBC $nnnn
@---------------------------------------------------------------------------------
	doABS
	opSBC
	fetch_c 4
@---------------------------------------------------------------------------------
_EE:@   INC $nnnn
@---------------------------------------------------------------------------------
	doABS
	opINC
	fetch 6
@---------------------------------------------------------------------------------
_F0:@   BEQ *
@---------------------------------------------------------------------------------
	tst m6502nz,#0xff
	ldrsb r0,[m6502pc],#1
	addeq m6502pc,m6502pc,r0
	subeq cycles,cycles,#3*CYCLE
	fetch 2
@---------------------------------------------------------------------------------
_F1:@   SBC ($nn),Y
@---------------------------------------------------------------------------------
	doIIY
	opSBC
	fetch_c 5
@---------------------------------------------------------------------------------
_F5:@   SBC $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opSBC
	fetch_c 4
@---------------------------------------------------------------------------------
_F6:@   INC $nn,X
@---------------------------------------------------------------------------------
	doZIXf
	opINC
	fetch 6
@---------------------------------------------------------------------------------
_F8:@   SED
@---------------------------------------------------------------------------------
	orr cycles,cycles,#CYC_D
	fetch 2
@---------------------------------------------------------------------------------
_F9:@   SBC $nnnn,Y
@---------------------------------------------------------------------------------
	doAIY
	opSBC
	fetch_c 4
@---------------------------------------------------------------------------------
_FD:@   SBC $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opSBC
	fetch_c 4
@---------------------------------------------------------------------------------
_FE:@   INC $nnnn,X
@---------------------------------------------------------------------------------
	doAIX
	opINC
	fetch 7
@---------------------------------------------------------------------------------
.section .text, "ax"
@---------------------------------------------------------------------------------
defaultScanlineHook:
@---------------------------------------------------------------------------------
	fetch 0
@---------------------------------------------------------------------------------
CheckI:							@ Check Interrupt Disable
@---------------------------------------------------------------------------------
	tst cycles,#CYC_I
	bne defaultScanlineHook		@ We dont want no stinkin irqs
@---------------------------------------------------------------------------------
irq6502:
@---------------------------------------------------------------------------------
	ldr r12,=IRQ_VECTOR
	bl Vec6502
	fetch 7
@---------------------------------------------------------------------------------
m6502NMI:
@---------------------------------------------------------------------------------
	ldr r12,=NMI_VECTOR
@---------------------------------------------------------------------------------
Vec6502:
@---------------------------------------------------------------------------------
	ldr_ r0,m6502LastBank
	sub r0,m6502pc,r0
	push16						@ Save PC

	encodeP (R)					@ Save P
VecCont:
	push8 r0

	orr cycles,cycles,#CYC_I	@ Disable IRQ
@	bic cycles,cycles,#CYC_D	@ and decimal mode

	ldr_ r0,m6502MemTbl+7*4
	ldrb m6502pc,[r0,r12]!
	ldrb r2,[r0,#1]
	orr m6502pc,m6502pc,r2,lsl#8
	encodePC					@ Get IRQ vector

	bx lr
@----------------------------------------------------------------------------
IRQ_VECTOR		= 0xfffe @ IRQ/BRK interrupt vector address
RES_VECTOR		= 0xfffc @ RESET interrupt vector address
NMI_VECTOR		= 0xfffa @ NMI interrupt vector address
@---------------------------------------------------------------------------------
m6502Reset:	@ Called by CPU_Reset (r0-r9 are free to use)
@---------------------------------------------------------------------------------
	stmfd sp!, {lr}

@---cpu reset
	mov m6502nz,#0
	mov m6502a,#0
	mov m6502x,#0
	mov m6502y,#0
	adr_ m6502_rmem,m6502ReadTbl
	add r0,m6502zpage,#0x100
	str_ r0,m6502RegSP	@S=0xFD (0x100-3)
	mov cycles,#0		@D=0, C=0, V=0, I=1 disable IRQ.

	@(clear irq/nmi/res source)...

	ldr r12,=RES_VECTOR
	bl Vec6502

	adr_ r0,m6502Regs
	stmia r0,{m6502nz-m6502pc}
	ldmfd sp!, {pc}
@---------------------------------------------------------------------------------
debugWrite:
	stmfd sp!, {r0-r3, lr}
	mov r1, addy
	bl debugwrite_c
	ldmfd sp!, {r0-r3, pc}

@---------------------------------------------------------------------------------
debugStep:
	stmfd sp!, {r0-r3, lr}
	adr_ r2,m6502Regs
	stmia r2,{m6502nz-m6502pc}		@refresh 6502 state
	bl stepdebug

	ldmfd sp!, {r0-r3, pc}

@---------------------------------------------------------------------------------
.section .dtcm, "aw"
@---------------------------------------------------------------------------------
m6502OpTable:
	.long _00,_01,_xx,_xx,_xx,_05,_06,_xx,_08,_09,_0A,_xx,_xx,_0D,_0E,_xx
	.long _10,_11,_xx,_xx,_xx,_15,_16,_xx,_18,_19,_xx,_xx,_xx,_1D,_1E,_xx
	.long _20,_21,_xx,_xx,_24,_25,_26,_xx,_28,_29,_2A,_xx,_2C,_2D,_2E,_xx
	.long _30,_31,_xx,_xx,_xx,_35,_36,_xx,_38,_39,_xx,_xx,_xx,_3D,_3E,_xx
	.long _40,_41,_xx,_xx,_xx,_45,_46,_xx,_48,_49,_4A,_xx,_4C,_4D,_4E,_xx
	.long _50,_51,_xx,_xx,_xx,_55,_56,_xx,_58,_59,_xx,_xx,_xx,_5D,_5E,_xx
	.long _60,_61,_xx,_xx,_xx,_65,_66,_xx,_68,_69,_6A,_xx,_6C,_6D,_6E,_xx
	.long _70,_71,_xx,_xx,_xx,_75,_76,_xx,_78,_79,_xx,_xx,_xx,_7D,_7E,_xx
	.long _xx,_81,_xx,_xx,_84,_85,_86,_xx,_88,_xx,_8A,_xx,_8C,_8D,_8E,_xx
	.long _90,_91,_xx,_xx,_94,_95,_96,_xx,_98,_99,_9A,_xx,_xx,_9D,_xx,_xx
	.long _A0,_A1,_A2,_xx,_A4,_A5,_A6,_xx,_A8,_A9,_AA,_xx,_AC,_AD,_AE,_xx
	.long _B0,_B1,_xx,_xx,_B4,_B5,_B6,_xx,_B8,_B9,_BA,_xx,_BC,_BD,_BE,_xx
	.long _C0,_C1,_xx,_xx,_C4,_C5,_C6,_xx,_C8,_C9,_CA,_xx,_CC,_CD,_CE,_xx
	.long _D0,_D1,_xx,_xx,_xx,_D5,_D6,_xx,_D8,_D9,_xx,_xx,_xx,_DD,_DE,_xx
	.long _E0,_E1,_xx,_xx,_E4,_E5,_E6,_xx,_E8,_E9,_EA,_xx,_EC,_ED,_EE,_xx
	.long _F0,_F1,_xx,_xx,_xx,_F5,_F6,_xx,_F8,_F9,_xx,_xx,_xx,_FD,_FE,_xx
  @m6502ReadTbl
	.skip 8*4	@$0000-FFFF
  @m6502WriteTbl
	.skip 8*4	@$0000-FFFF
  @m6502MemTbl
	.skip 4*4	@$0000-7FFF
	.skip 4*4	@$8000-FFFF

	@group these together for save/loadstate
	.skip 8*4 @m6502Regs (nz,rmem,a,x,y,cycles,pc,sp)
	.byte 0 	;@ m6502IrqPending
	.byte 0 	;@ m6502NMIPin
	.skip 2		;@ padding

	.long 0		;@ LastBank:		Last memmap added to PC (used to calculate current PC)
	.long 0 	;@ OldCycles:		Backup of cycles
	.long 0		;@ NextTimeout:		Jump here when cycles runs out
#ifdef DEBUG
	.skip 2*4
#endif

@---------------------------------------------------------------------------------