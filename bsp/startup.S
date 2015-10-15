#include "s5pc100_reg.inc"

;/* Space for Image Size*/
/* Function & Script Label definitions */
	.extern main  
	.extern __TEXT_START__
	.extern __BSS_START__             
	.extern __BSS_END__   
	.extern __DATA_START__             
	.extern __DATA_END__  
	.extern __RODATA_END__ 

	.extern DispExitChar

	.extern ClockForInit
	.extern UART0_ASM_Init
	.extern Led_Display
	
  .extern OS_CPU_ARM_ExceptIrqHndlr

	.text

	.global IRQHandler
	.global _start
	
_start:
start:
	
;/* Exception Entries */
	.global ResetEntry
	.extern Dabort_Handler
	.extern Pabort_Handler
	.extern SWI_Handler
	.extern Undef_Handler
	.extern OS_CPU_ARM_ExceptIrqHndlr
	
ResetEntry:		B       ResetHandler
UndefEntry:		B       Undef_Handler					@@UndefHandler
SwiEntry:			B       SWI_Handler						@@SWIHandler
IAbortEntry:	B       Pabort_Handler				@@PAbortHandler
DAbortEntry:	B       Dabort_Handler				@@DAbortHandler
        			B       .
IrqEntry:     B       OS_CPU_ARM_ExceptIrqHndlr		@@IRQHandler
FiqEntry:			B       FIQHandler

	/* Reset Handler */

	
	.global ResetHandler
	.extern EnableICache
	.extern DisableWatchDogTimer
	.extern	Mraminit
	.extern CoSetExceptonVectoerBase
	.extern CoDisableIrq
	.extern main
	.extern exit
	.extern InitCVar
	.extern WakeupHandler
	.global start

ResetHandler:
	
	MRC p15,0,r0,c1,c0,0
	ORR r0,r0,#(1<<12)
	MCR	p15,0,r0,c1,c0,0 	/* Enable I-Cache */
	
	LDR	r0,=0xffffffff
	MCR	p15,0,r0,c1,c0,2 	/* Enable coprocessors */
	MOV	R0,#0x40000000
	
@@	msr	FPEXC,r0 			/* Globally enable NEON & VFP */
	
	BL	CoEnableBranchPrediction	/* Enable flow prediction */

	LDR r0,=WDT_BASE		/* Disable Watchdog Timer */
	MOV r1,#0
	STR r1,[r0]
	
	/*  DDR2 Drive Strength Setting */
	ldr		r5, =0xE03003CC
	ldr		r1, =0x55A5
	str		r1, [r5]
	ldr		r5, =0xE03003EC
	ldr		r1, =0x5555
	str		r1, [r5]
	ldr		r5, =0xE030040C
	str		r1, [r5]
	ldr		r5, =0xE030042C
	str		r1, [r5]
	ldr		r5, =0xE030044C
	str		r1, [r5]
	ldr		r5, =0xE030046C
	str		r1, [r5]
	ldr		r5, =0xE030048C
	str		r1, [r5]
	ldr		r5, =0xE03004AC
	ldr		r1, =0xA955
	str		r1, [r5]
	ldr		r5, =0xE03004CC
	ldr		r1, =0x2AAA
	str		r1, [r5]

	ldr		r5, =GPH0CON
	ldr		r1, =(1<<0)
	str		r1, [r5]
	ldr		r1, =1
	str		r1, [r5, #4]

	/* GPIO Initialization */
	ldr		r0, =GPJ4CON
	ldr		r1, =0x00001111
	str		r1, [r0]

	ldr		r0, =GPK1CON
	ldr		r1, =0x00002222
	str		r1, [r0]

	ldr		r0, =GPK3CON
	ldr		r1, =0x11111100
	str		r1, [r0]

	ldr		r0, =GPK3DAT
	ldr		r1, =0xff
	str		r1, [r0]

	/* IO Retention release */
	ldr		r0, =(ELFIN_CLOCK_POWER_BASE + OTHERS)
	ldr		r1, [r0]
	ldr		r2, =(1<<31)
	orr		r1, r1, r2
	str		r1, [r0]

	/*
	 *	 clock block for ram
	 */
	BL		ClockForInit
//	BL		Mraminit

	BL		UART0_ASM_Init

	BL      InitStackRegs

	mov		r0, #'0'
	BL		uart_putc

	LDR     r0,=ResetEntry
	BL      CoSetExceptonVectoerBase

	mov		r0, #'1'
	BL		uart_putc

	/* Load INFORM0(Alive reg) */
	LDR     r2,=INFORM0
	LDR     r1,[r2]                
	ANDS    r3,r1,#(1<<24)
	BEQ     Normal_wakeup
	BL      WakeupHandler              

Normal_wakeup:
	/* when we already run in ram, we don't need to relocate U-Boot.
	 * and actually, memory controller must be configured before U-Boot
	 * is running in ram.
	 */
	ldr	r0, =0xff000fff
	bic	r1, pc, r0				/* r0 <- current base addr of code */
	ldr	r2, =__TEXT_START__		/* r1 <- original base addr in ram */
	bic	r2, r2, r0				/* r0 <- current base addr of code */
	cmp     r1, r2				/* compare r0, r1                  */

	bl	InitCVar			/* r1 == r2 then skip flash copy   */

	BL  main

	b		.


///* Init Stack Pointer */
#define	USERMODE 		0x10
#define	FIQMODE  		0x11
#define	IRQMODE  		0x12
#define	SVCMODE  		0x13
#define	ABORTMODE		0x17
#define	UNDEFMODE		0x1b
#define	MODEMASK 		0x1f
#define	NOINT    		0xc0

.equ		STACK_BASE_ADDR, 	0x2fff8000
.equ		SvcStackSt, 			(STACK_BASE_ADDR - 0x3800)
.equ		UserStackSt,			(STACK_BASE_ADDR - 0x2800)
.equ		UndefStackSt,			(STACK_BASE_ADDR - 0x2400)
.equ		AbortStackSt,			(STACK_BASE_ADDR - 0x2000)
.equ		IrqStackSt,	  		(STACK_BASE_ADDR - 0x1000)
.equ		FIQStackSt,		  	(STACK_BASE_ADDR - 0x0)



	/* Stack & Heap
	 * Because the 'One memory region' model is used,
	 * the seperate heap region is not defined. (Sean)
	 */
InitStackRegs:
	MRS   r0,cpsr
	BIC   r0,r0,#MODEMASK

	ORR		r1, r0, #FIQMODE|NOINT
	MSR		cpsr, r1
	LDR		sp, =FIQStackSt

	ORR		r1, r0, #UNDEFMODE|NOINT
	MSR		cpsr, r1
	LDR		sp, =UndefStackSt

	ORR		r1, r0, #ABORTMODE|NOINT
	MSR		cpsr, r1
	LDR		sp, =AbortStackSt

	ORR   r1,r0,#IRQMODE|NOINT
	MSR   cpsr_cxsf,r1
	LDR   sp,=IrqStackSt

	ORR   r1,r0,#SVCMODE|NOINT
	MSR   cpsr_cxsf,r1
	LDR   sp,=SvcStackSt

	MOV   pc,lr

	/* Initialize RW/ZI Area */
InitCVar:
 ldr  r0, =__RODATA_END__
 ldr  r1, =__DATA_START__
  mov r2, r0, lsr #12
  mov r3, r1, lsr #12
  
 cmp  r2, r3
 beq  2f
 ldr  r3, =__BSS_START__
1:               // Copy RW Region
 cmp  r1, r3
 ldrccb   r2, [r0], #0x1
 strccb  r2, [r1], #0x1
 bcc  1b

2:
	ldr  r3, =__BSS_START__
	ldr		r1, =__BSS_END__
	mov		r2, #0x0
3:      								// Clear BSS(ZI) Region
	cmp		r3, r1
	strccb	r2, [r3], #1
	bcc	 	3b

	mov     pc,lr

/*
 * Exception Handlers
 */
UndefHandler:
	mov		r0, #'u'
	bl		uart_putc
	b .

SWIHandler:
	mov		r0, #'s'
	bl		uart_putc
	b .

PAbortHandler:
	mov		r0, #'p'
	bl		uart_putc
	b .

DAbortHandler:
	mov		r0, #'d'
	bl		uart_putc
	b .

IRQHandler:
	sub lr, lr, #4
	stmfd sp!,{r0-r12,lr}

	ldr		r0, =VIC0_ISRADDR
	cmp		r0,#0
	beq		1f
	ldr		lr,=end
	ldr		pc, [r0, #0]
1:
	ldr		r0, =VIC1_ISRADDR
	cmp		r0,#0
	beq		2f
	ldr		lr,=end
	ldr		pc, [r0, #0]
2:
	ldr		r0, =VIC2_ISRADDR
	cmp		r0,#0
	beq		end
	ldr		lr,=end
	ldr		pc, [r0, #0]

end:
	ldmfd sp!,{r0-r12,pc}^

FIQHandler:
	mov		r0, #'f'
	bl		uart_putc
	b .

	.end
