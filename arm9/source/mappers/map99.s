@---------------------------------------------------------------------------------
	#include "equates.h"
@---------------------------------------------------------------------------------
	.global mapper99init
@---------------------------------------------------------------------------------
.section .text,"ax"
@---------------------------------------------------------------------------------
mapper99init:
@---------------------------------------------------------------------------------
	.word empty_W,empty_W,empty_W,empty_W

	ldrb_ r0,cartFlags
	orr r0,r0,#VS
	strb r0,[r1]

	ldr r0,=write4016
	ldr r1,=joypad_write_ptr
	str r0,[r1]

	bx lr
@---------------------------------------------------------------------------------
write4016:
@---------------------------------------------------------------------------------
	stmfd sp!,{r0,lr}

	mov r0,r0,lsr#2
	bl chr01234567_

	ldmfd sp!,{r0,lr}
	b joy0_W
@---------------------------------------------------------------------------------
