#include "s5pc100_reg.inc"

	.equ	SaveDataAreaStart, __BSS_END__

	.text

/* Entry function for ARM-power-off */
	.global	OALClearDTLB
OALClearDTLB:
	mov     r0, #0
	mcr     p15, 0, r0, c8, c6, 0   // flush(=invalidate) data TLB
	nop
	nop
	mov     pc,lr
	.global	OALClearITLB          	    
OALClearITLB:
	mov     r0, #0
	mcr     p15, 0, r0, c8, c5, 0   // flush(=invalidate) instruction TLB
	nop
	nop
	mov     pc,lr
	.global	OALFlushDCache
OALFlushDCache:
	push    {r4-r5,r7,r9-r11,lr}    // store off registers to stack
	
	mrc     p15, 1, r0, c0, c0, 1           // read Cache Level ID
	ands    r3, r0, #0x7000000              // bit[26:24] LoC (3'b010 = level of coherency)  
	mov     r3, r3, lsr #23                 // cache level value
	beq     doneb                           // jump to doneb if cache level is 0   
	
	mov     r10, #0                         // start clean at cache level 0
loop1b:
	add     r2, r10, r10, lsr #1            // work out 3x current cache level
	mov     r1, r0, lsr r2                  // extract cache type bits from clidr
	and     r1, r1, #7                      // mask of the bits for current cache only
	cmp     r1, #2                          // see what cache we have at this level
	blt     skipb                           // skip if no cache, or just i-cache
	
	mcr     p15, 2, r10, c0, c0, 0          // Cache Size Selection (old:  select current cache level in cssr)
	mov     r1, #0
	mcr     p15, 0, r1, c7, c5, 4           // prefetch buffer flush to sync the change to the cachesize id reg
	mrc     p15, 1, r1, c0, c0, 0           // read the new Cache Size identification
	and     r2, r1, #7                      // extract the length of the cache lines
	add     r2, r2, #4                      // add 4 (line length offset)
	ldr     r4, =0x3ff
	ands    r4, r4, r1, lsr #3              // r4 is maximum number on the way size
	clz     r5, r4                          // r5 find bit position of way size increment
	ldr     r7, =0x7fff
	ands    r7, r7, r1, lsr #13             // r7 extract max number of the index size
                
loop2b:          
	mov     r9, r4                          // r9 is working copy of max way size
loop3b:          
	orr     r11, r10, r9, lsl r5            // factor way and cache number into r11
	orr     r11, r11, r7, lsl r2            // factor index number into r11
	
	mcr     p15, 0, r11, c7, c14, 2         // clean and invalidate data cache line by set/way
	
	subs    r9, r9, #1                      // decrement the way
	bge     loop3b
	
	subs    r7, r7, #1                      // decrement the index
	bge     loop2b
                
skipb:           
	add     r10, r10, #2                        // increment cache number
	cmp     r3, r10
	bgt     loop1b
                
doneb:           
	mov     r10, #0                             // swith back to cache level 0
	mcr     p15, 2, r10, c0, c0, 0              // select current cache level in cssr
	
	pop     {r4-r5,r7,r9-r11,pc}    // restore registers

	.global	OALFlushICache
OALFlushICache:
	mov     r0, #0
	mcr     p15, 0, r0, c7, c5, 0       // invalidate all instruction caches
	
	mov     r0, #0
	mcr     p15, 0, r0, c7, c5, 4       // flush the prefetch buffer
	mcr     p15, 0, r0, c7, c5, 6       // NOP (old: ; flush entire branch target cache)
	
	mov     pc,lr

	.global	OALEnableICache
OALEnableICache:
	MRC     p15,0,r0,c1,c0,0
	ORR     r0,r0,#(1<<12)
	MCR     p15,0,r0,c1,c0,0
	MOV     pc,lr

	.global	OALEnableDCache
OALEnableDCache:
	MRC     p15,0,r0,c1,c0,0
	ORR     r0,r0,#(1<<2)
	MCR     p15,0,r0,c1,c0,0
	MOV     pc,lr

	.global	OALEnableMmu
OALEnableMmu:
	MRC     p15,0,r0,c1,c0,0
	ORR     r0,r0,#(1<<0)
	MCR     p15,0,r0,c1,c0,0
	MOV     pc,lr                
                
///* 
// * Entry function for ARM-power-off 
// */
	.equ	MODE_USR,     	0x10
	.equ	MODE_FIQ,     	0x11
	.equ	MODE_IRQ,     	0x12
	.equ	MODE_SVC,     	0x13
	.equ	MODE_ABT,     	0x17
	.equ	MODE_UND,     	0x1b
	.equ	MODE_SYS,     	0x1f
	.equ	MODE_MASK,    	0x1f
	.equ	NO_INT,			0xc0

	.equ	I_CHECKSUM,		(4*0)
	.equ	I_WAKEADDR,		(4*1)
	.equ	I_SYSCTL,		(4*2) 
	.equ	I_MMUTTB0,		(4*3) 
	.equ	I_MMUTTB1,		(4*4) 
	.equ	I_MMUTTBCTL,	(4*5) 
	.equ	I_MMUDOMAIN,	(4*6) 
	.equ	I_SVC_SP,		(4*7) 
	.equ	I_SVC_LR,		(4*8) 
	.equ	I_SVC_SPSR,		(4*9) 
	.equ	I_IRQ_SP,		(4*10)
	.equ	I_IRQ_LR,		(4*11)
	.equ	I_IRQ_SPSR,		(4*12)
	.equ	I_FIQ_R8,		(4*13)
	.equ	I_FIQ_R9,		(4*14)
	.equ	I_FIQ_R10,		(4*15)
	.equ	I_FIQ_R11,		(4*16)
	.equ	I_FIQ_R12,		(4*17)
	.equ	I_FIQ_SP,		(4*18)
	.equ	I_FIQ_LR,		(4*19)
	.equ	I_FIQ_SPSR,		(4*20)
	.equ	I_SYS_SP,		(4*20)
	.equ	I_SYS_LR,		(4*21)
	.equ	I_UND_SP,		(4*22)
	.equ	I_UND_LR,		(4*23)
	.equ	I_UND_SPSR,		(4*24)
	.equ	I_ABT_SP,		(4*25)
	.equ	I_ABT_LR,		(4*26)
	.equ	I_ABT_SPSR,		(4*27)
	.equ	INFORM0,		0xE0108400

	.global	WfiForArmPwrOff
WfiForArmPwrOff:
	push    {r4-r12,lr}
	
	ldr     r4,=SaveDataAreaStart // Sleep Data Area Base Address
	
	// Set bit[24] in INFORM0(Alive reg)              
	LDR     r2,=INFORM0
	LDR     r1,[r2]
	ORR     r1,r1,#(1<<24)
	str     r1,[r2,#0]                
	
	///* 1. Save CP15 Register into Sleep Data Area in DRAM */
	
	ldr     r2,=WakeupHandler
	str     r2,[r4,#I_WAKEADDR]
	
	mrc     p15,0,r2,c1,c0,0           // Control
	str     r2,[r4,#I_SYSCTL]
	
	mrc     p15,0,r2,c2,c0,0
	//ldr     r0,=MMUTTB_SBZ_MASK
	//bic     r2,r2,r0
	str     r2,[r4,#I_MMUTTB0]
	
	mrc     p15,0,r2,c2,c0,1
	str     r2,[r4,#I_MMUTTB1]
	
	mrc     p15,0,r2,c2,c0,2
	str     r2,[r4,#I_MMUTTBCTL]
	
	mrc     p15,0,r2,c3,c0,0
	str     r2,[r4,#I_MMUDOMAIN]
	
	
	///* 2. Save CPU Register into Sleep Data Area in DRAM */
	
	mov     r1,#MODE_FIQ|NO_INT
	msr     cpsr_c,r1
	str     r8,[r4,#I_FIQ_R8]
	str     r9,[r4,#I_FIQ_R9]
	str     r10,[r4,#I_FIQ_R10]
	str     r11,[r4,#I_FIQ_R11]
	str     r12,[r4,#I_FIQ_R12]
	str     sp,[r4,#I_FIQ_SP]
	str     lr,[r4,#I_FIQ_LR]
	mrs     r0,spsr
	str     r0,[r4,#I_FIQ_SPSR]
	
	mov     r1,#MODE_ABT|NO_INT  
	msr     cpsr_c,r1
	str     sp,[r4,#I_ABT_SP]
	str     lr,[r4,#I_ABT_LR]
	mrs     r0,spsr
	str     r0,[r4,#I_ABT_SPSR]
	
	mov     r1,#MODE_IRQ|NO_INT  
	msr     cpsr_c,r1
	str     sp,[r4,#I_IRQ_SP]
	str     lr,[r4,#I_IRQ_LR]
	mrs     r0,spsr
	str     r0,[r4,#I_IRQ_SPSR]
	
	mov     r1,#MODE_UND|NO_INT  
	msr     cpsr_c,r1
	str     sp,[r4,#I_UND_SP]
	str     lr,[r4,#I_UND_LR]
	mrs     r0,spsr
	str     r0,[r4,#I_UND_SPSR]
	
	mov     r1,#MODE_SYS|NO_INT  
	msr     cpsr_c,r1
	str     sp,[r4,#I_SYS_SP]
	str     lr,[r4,#I_SYS_LR]
	
	
	mov     r1,#MODE_SVC|NO_INT
	msr     cpsr_cf,r1
	str     sp,[r4,#I_SVC_SP]
	str     lr,[r4,#I_SVC_LR]
	mrs     r0,spsr
	str     r0,[r4,#I_SVC_SPSR]

                ///* 4. Calculate CheckSum of Sleep Data */
//                ldr     r3,=SaveDataAreaStart
//                add     r3,r3,#4
//                ldr     r2,=0x0
//                ldr     r0,=(SLEEPDATA_SIZE-1)    
//2               ldr     r1,[r3],#4
//                and     r1,r1,#0x1
//                mov     r1,r1,LSL #31
//                orr     r1,r1,r1,LSR #1
//                add     r2,r2,r1
//                subs    r0,r0,#1
//                bne     %B2
 //               str     r0,[r4,#I_CHECKSUM*4]

                
	///* 5. Clear TLB and Flush Cache
	bl      OALClearDTLB
	bl      OALClearITLB
	bl      OALFlushDCache
	bl      OALFlushICache
	
	///* 6. Disable Caches.
	mov     r2,#0        
	mrc     p15,0,r2,c1,c0,0                    // Read Control register
	bic     r2,r2,#0x4 // Disable D-Cache at any level (bit[2] == 0)
	bic     r2,r2,#0x1000 // Disable I-Cache at any level (bit[12] == 0)
	mcr     p15,0,r2,c1,c0,0                    // Write Control register
	
	mrc     p15,0,r2,c1,c0,1                    // Read Auxiliary Control register
	bic     r2,r2,#0x2                          // Disable L2-Cache (bit[1] == 0)
	mcr     p15,0,r2,c1,c0,1 
	
	///* 8. Set Power Mode to Sleep
	.extern CoInvalidateDCacheForV7
	bl 	CoInvalidateDCacheForV7
	wfi
	b       .
////              pop     {r4-r12,pc}  //////
                
///* 
// * Handler of Wakeup from ARM power-down 
// */
	.global	WakeupHandler
WakeupHandler:
                ///* Calculate CheckSum of Sleep Data */
//                ldr     r3, =SaveDataAreaStart // Base of Sleep Data Area
//                add     r3,r3,#4
//                ldr     r2,=0 // CheckSum is in r2
//                ldr     r0,=(SLEEPDATA_SIZE-1)            // Size of Sleep Data Area (in words)
//2
//                ldr     r1, [r3], #4
//                and     r1, r1, #0x1
//                mov     r1, r1, LSL #31
//                orr     r1, r1, r1, LSR #1
//                add     r2, r2, r1 // CheckSum is in r2
//                subs    r0, r0, #1
//                bne     %B2
//                
//                ldr     r4, =SaveDataAreaStart // Base of Sleep Data Area
//                ldr     r1, [r4]
//                cmp     r1, r2 // Compare CheckSum Recalculated and Value in DRAM
//                bne     .

	// Clear bit[24] in INFORM0(Alive reg)              
	LDR     r2,=INFORM0
	LDR     r1,[r2]
	BIC     r1,r1,#(1<<24)
	str     r1,[r2,#0]
	
	///* Restore CP15 Register */

////                push     {r4-r12,lr} ////////
                
	ldr     r10,=SaveDataAreaStart // Base of Sleep Data Area
	ldr     r6,[r10, #I_MMUDOMAIN]    // Domain Access Control Register
	ldr     r5,[r10, #I_MMUTTBCTL]    // TTB Control Register
	ldr     r4,[r10, #I_MMUTTB1]    // TTB Register1
	ldr     r3,[r10, #I_MMUTTB0]    // TTB Register0
	ldr     r2,[r10, #I_SYSCTL]        // System Control Register
	nop
	nop
	
	mcr     p15, 0, r6, c3, c0, 0 // Restore Domain Access Control Register
	mcr     p15, 0, r5, c2, c0, 2 // Restore TTB Control Register
	mcr     p15, 0, r4, c2, c0, 1 // Restore TTB Register1
	mcr     p15, 0, r3, c2, c0, 0 // Restore TTB Register0
	mcr     p15, 0, r2, c1, c0, 0 // Restore System Control Register (MMU Control)
	mov     r0, #0x0
	mcr     p15, 0, r0, c8, c7, 0 // Invalidate I & D TLB
	
	ldr     r3,=SaveDataAreaStart // Sleep Data Area Base Address
	
	mrs     r2, cpsr
	bic     r1, r2, #0x1f // clear the mode bits from the cpsr value
	
	///* FIQ mode CPU Registers */
	orr     r0, r1, #MODE_FIQ | NO_INT // Enter FIQ mode,no interrupts
	msr     cpsr_c,r0
	ldr     r8,[r3,#I_FIQ_R8]
	ldr     r9,[r3,#I_FIQ_R9]
	ldr     r10,[r3,#I_FIQ_R10]
	ldr     r11,[r3,#I_FIQ_R11]
	ldr     r12,[r3,#I_FIQ_R12]
	ldr     sp,[r3,#I_FIQ_SP]
	ldr     lr,[r3,#I_FIQ_LR]
	ldr     r0,[r3,#I_FIQ_SPSR]
	msr     spsr_cxsf,r0
	
	///* Abort mode CPU Registers */
	orr     r0, r1, #MODE_ABT | NO_INT // Enter ABT mode,no IRQ - FIQ is available
	msr     cpsr_c,r0
	ldr     sp,[r3,#I_ABT_SP]
	ldr     lr,[r3,#I_ABT_LR]
	ldr     r0,[r3,#I_ABT_SPSR]
	msr     spsr_cxsf,r0
	
	///* IRQ mode CPU Registers */
	orr     r0, r1, #MODE_IRQ | NO_INT // Enter IRQ mode,no IRQ - FIQ is available
	msr     cpsr_c,r0
	ldr     sp,[r3,#I_IRQ_SP]
	ldr     lr,[r3,#I_IRQ_LR]
	ldr     r0,[r3,#I_IRQ_SPSR]
	msr     spsr_cxsf,r0                
	
	///* UNDined mode CPU Registers */
	orr     r0, r1, #MODE_UND | NO_INT // Enter UND mode,no IRQ - FIQ is available
	msr     cpsr_c,r0
	ldr     sp,[r3,#I_UND_SP]
	ldr     lr,[r3,#I_UND_LR]
	ldr     r0,[r3,#I_UND_SPSR]
	msr     spsr_cxsf,r0                
	
	///* System mode CPU Registers */
	orr     r0, r1, #MODE_SYS | NO_INT // Enter SYS mode,no IRQ - FIQ is available
	msr     cpsr_c,r0
	ldr     sp,[r3,#I_SYS_SP]
	ldr     lr,[r3,#I_SYS_LR]
	
	///* Supervisor mode CPU Registers */
	orr     r0, r1, #MODE_SVC | NO_INT // Enter SVC mode,no IRQ - FIQ is available
	msr     cpsr_cf,r0                
	ldr     sp,[r3,#I_SVC_SP]
	ldr     lr,[r3,#I_SVC_LR]
	ldr     r0,[r3,#I_SVC_SPSR]
	msr     spsr_cxsf,r0
	
	///* Return */
	pop     {r4-r12,pc}
                
///* system init code by meritech */
	.equ		SYSCONBASE,		0xe0100300
	.equ		PLLCONBASE1,	0xe0100000
	.equ		PLLCONBASE2,	0xe0100100
	.equ		PLLCONBASE3,	0xe0100200
	.equ		PLLCONBASE4,	0xe0100400
	.equ		DRAMCON,		0xE6000000

	.global	ClockForInit
ClockForInit:
	ldr	r0, =ELFIN_CLOCK_POWER_BASE	@0xe0100000

	mov	r1, #0xe00
	orr	r1, r1, #0x10
	str	r1, [r0, #APLL_LOCK_OFFSET]
	str	r1, [r0, #MPLL_LOCK_OFFSET]
	str	r1, [r0, #EPLL_LOCK_OFFSET]
	str	r1, [r0, #HPLL_LOCK_OFFSET]

	ldr   	r1, [r0, #CLK_DIV0_OFFSET]
	ldr	r2, =CLK_DIV0_MASK
	bic	r1, r1, r2

	ldr	r2, =CLK_DIV0_VAL
	orr	r1, r1, r2
	str	r1, [r0, #CLK_DIV0_OFFSET]

	ldr	r1, =APLL_VAL
	str	r1, [r0, #APLL_CON_OFFSET]

	ldr   	r1, [r0, #CLK_DIV1_OFFSET]
	ldr	r2, =CLK_DIV1_VAL
	orr	r1, r1, r2
	str	r1, [r0, #CLK_DIV1_OFFSET]

	ldr	r1, =MPLL_VAL
	str	r1, [r0, #MPLL_CON_OFFSET]
	ldr	r1, =EPLL_VAL
	str	r1, [r0, #EPLL_CON_OFFSET]
	ldr	r1, =HPLL_VAL
	str	r1, [r0, #HPLL_CON_OFFSET]

	ldr	r1, [r0, #CLK_SRC0_OFFSET]
	ldr	r2, =0x1111
	orr	r1, r1, r2
	str	r1, [r0, #CLK_SRC0_OFFSET]

	mov	r1, #0x10000
1:	subs	r1, r1, #1
	bne	1b

	mov	pc, lr
	
/*
// C100 Clock configuration : 667Mhz, 166Mhz, 133Mhz from cmm script
	LDR     r0,=SYSCONBASE
	LDR     r1,=0x00010000
	STR    r1,[r0,#0x4]
	LDR     r1,=0x00011000
	STR    r1,[r0,#0x4]
	LDR     r1,=0x00011100
	STR    r1,[r0,#0x4]
	LDR     r1,=0x00011110
	STR    r1,[r0,#0x4]
	LDR     r1,=0x00011110
	STR    r1,[r0,#0x4]
	LDR     r1,=0x00000001
	STR    r1,[r0,#0x8]
	LDR     r1,=0x00011001
	STR    r1,[r0]
	LDR     r1,=0x00011001
	STR    r1,[r0]
	LDR     r1,=0x00011301
	STR    r1,[r0]
	LDR     r1,=0x00011301
	STR    r1,[r0]
// SetLockTime & StartPLL                
	LDR     r0,=PLLCONBASE1
	LDR     r1,=0x00000e10
	STR    r1,[r0]
	LDR     r0,=PLLCONBASE2
	LDR     r1,=0x81bc0400
	STR    r1,[r0]
	NOP
	NOP
	NOP
	NOP
	NOP
	LDR     r0,=PLLCONBASE1
	LDR     r1,=0x00000e10
	STR    r1,[r0,#0x4]
	LDR     r0,=PLLCONBASE2
	LDR     r1,=0x80590201
	STR    r1,[r0,#0x4]
	NOP
	NOP
	NOP
	NOP
	NOP
	LDR     r0,=PLLCONBASE1
	LDR     r1,=0x00000e10
	STR    r1,[r0,#0x8]
	LDR     r0,=PLLCONBASE2
	LDR     r1,=0x80870303
	STR    r1,[r0,#0x8]
	NOP
	NOP
	NOP
	NOP
	NOP
	LDR     r0,=PLLCONBASE3
	LDR     r1,=0x00000000
	STR    r1,[r0]
	LDR     r0,=PLLCONBASE1
	LDR     r1,=0x00000e10
	STR    r1,[r0,#0xc]
	LDR     r0,=PLLCONBASE2
	LDR     r1,=0x80600603
	STR    r1,[r0,#0xc]
	NOP
	NOP
	NOP
	NOP
	NOP
// SetSourceClock
	LDR     r0,=PLLCONBASE3
	LDR     r1,=0x00000000
	STR    r1,[r0]
	LDR     r1,=0x00000001
	STR    r1,[r0]
	LDR     r1,=0x00000011
	STR    r1,[r0]
	LDR     r1,=0x00000111
	STR    r1,[r0]
	LDR     r1,=0x00001111
	STR    r1,[r0]
	LDR     r1,=0x00000001
	STR    r1,[r0,#0x4]
	LDR     r1,=0x01000001
	STR    r1,[r0,#0x4]
	LDR     r0,=PLLCONBASE4
	LDR     r1,=0x00009000
	STR    r1,[r0]
	MOV     pc,lr
*/
          
  .global Mraminit      
Mraminit:
// DRAM Initialization                
	LDR     r0,=DRAMCON
	LDR     r1,=0x003B3B00
	STR    r1,[r0,#0x18]
	LDR     r1,=0x00000004
	STR    r1,[r0,#0x1c]
	LDR     r1,=0x00000000
	STR    r1,[r0,#0x20]
	LDR     r1,=0x003B3B02
	STR    r1,[r0,#0x18]
	LDR     r1,=0x003B3B03
	STR    r1,[r0,#0x18]
	LDR     r1,=0x6A3B3B03
	STR    r1,[r0,#0x18]
	LDR     r1,=0x6A3B3B01
	STR    r1,[r0,#0x18]
	
	LDR     r1,=0xFF001010
	STR    r1,[r0]
	LDR     r1,=0xFF212100
	STR    r1,[r0,#0x4]
	LDR     r1,=0x20F80312
	STR    r1,[r0,#0x8]
	LDR     r1,=0x40F80312
	STR    r1,[r0,#0xc]
	LDR     r1,=0x20000000
	STR    r1,[r0,#0x14]
	LDR     r1,=0x0000004E
	STR    r1,[r0,#0x30]
	LDR     r1,=0x0C233287
	STR    r1,[r0,#0x34]
	LDR     r1,=0x12130005	
	STR    r1,[r0,#0x38]
	LDR     r1,=0x0E120122
	STR    r1,[r0,#0x3c]
	LDR     r1,=0x07000000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x01000000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x05000000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x05000000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x00000032
	STR    r1,[r0,#0x10]
	LDR     r1,=0x07100000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x01100000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x05100000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x05100000
	STR    r1,[r0,#0x10]
	LDR     r1,=0x00100032
	STR    r1,[r0,#0x10]
	LDR     r1,=0xFF001030
	STR    r1,[r0]
	LDR     r1,=0x00100002
	STR    r1,[r0,#0x28]
	LDR     r1,=0xFF212100
	STR    r1,[r0,#0x4]
	MOV     pc,lr



	.global DispExitChar
DispExitChar:
	LDR     r0,=UART_BASE
	LDR     r1,=0x04
	STRB    r1,[r0,#0x20]
	B       .

///* Enable I-Cache */
	.global	EnableICache
EnableICache:
	MRC     p15,0,r0,c1,c0,0
	ORR     r0,r0,#(1<<12)
	MCR     p15,0,r0,c1,c0,0
	MOV     pc,lr

/*
 * UART Channel[0] Initialization Function
 */
 	.global UART0_ASM_Init
UART0_ASM_Init:

	/* GPIO Setting for UART0 */
	ldr	r0, =ELFIN_GPIO_BASE
	ldr	r1, [r0]
	ldr 	r2, =(0xF<<12|0xF<<8|0xF<<4|0xF)
	bic	r1, r1, r2
	ldr	r2, =(2<<12|2<<8|2<<4|2)
	orr	r1, r1, r2
	str   	r1, [r0, #GPA0CON]

	ldr	r0, =ELFIN_UART_BASE
	mov	r1, #0x0
	str	r1, [r0, #UFCON0]
	str	r1, [r0, #UMCON0]

	mov	r1, #0x3
	str	r1, [r0, #ULCON0]

	ldr	r1, =0x245
	str	r1, [r0, #UCON0]

	ldr	r1, =0x23
	str	r1, [r0, #UBRDIV0]

	ldr	r1, =0x3
	str	r1, [r0, #UDIVSLOT0]

1:
	ldr	r1, [r0, #UTRSTAT0]
	bic	r1, r1, #0xfffffffd
	mov r1, r1, lsr #1
	cmp r1, #1
	bne 1b
	ldr	r1, =0x4d4d4d4d
	str	r1, [r0, #UTXH0]

	mov	pc, lr


/*
 * void uart_putc(int data);
 */
	.global uart_putc
uart_putc:
	ldr	r3, =ELFIN_UART_BASE
1:
	ldr	r1, [r3, #UTRSTAT0]
	bic	r1, r1, #0xfffffffd
	mov r1, r1, lsr #1
	cmp r1, #1
	bne 1b
	str	r0, [r3, #UTXH0]
	mov pc, lr


	.end
