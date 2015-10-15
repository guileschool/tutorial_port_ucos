/*******************************************************************************
**	File:
**
**		libc.c
**
**  Contents:
**		uC/OS-II programming
**
**	History:
**		Date        Name              Description
**		------------------------------------------------------------------------
**
*******************************************************************************/
#include "C100RegAddr.h"
#include "libc.h"
#include "timer.h"

static void StartTimeTick(void);
void UART0_IntHandler(void);


#define C1      523     // Do
#define C1_     554
#define D1      587     // Re
#define D1_     622
#define E1      659     // Mi
#define F1      699     // Pa
#define F1_     740
#define G1      784     // Sol
#define G1_     831
#define A1      880     // La
#define A1_     932
#define B1      988     // Si
#define C2      C1*2    // Do
#define C2_     C1_*2
#define D2      D1*2    // Re
#define D2_     D1_*2
#define E2      E1*2    // Mi
#define F2      F1*2    // Pa
#define F2_     F1_*2
#define G2      G1*2    // Sol
#define G2_     G1_*2
#define A2      A1*2    // La
#define A2_     A1_*2
#define B2      B1*2    // Si

void OSTickISR(void);

static int tick= 0;

//
// UART0 인터럽트 서비스 루틴
//
void ISR_UART0(void)
{    
  	rUTXH0 = Uart_GetChar();
		rUINTSP0 = (0x1<<0);//rSUBSRCPND	= BIT_SUB_RXD0;
		rUINTP0  = (0x1<<0);//rINTPND		= BIT_UART0;
}

/*
 * =====================================================================
 * PORTS Librarues
 * =====================================================================
 */
void Port_Init(void)
{
    	int i;
	
	// LED Port Initialization
	rGPJ4CON=(rGPJ4CON & ~(0xFFFF))|(1<<12|1<<8|1<<4|1);
	rGPJ4PDNPULL=0x0;
	rGPJ4DAT=0x0;

	rGPJ1CON=(rGPJ4CON & ~(0xF0F00))+(1<<16)+(1<<8);
//	rGPJ4PDNPULL=0x0;

	rGPJ1DAT |= (1<<4)+(1<<2);
	rGPJ1DAT &= ~(1<<4);
	
	for(i=0; i<500000; i++)
	{
		rGPJ1DAT &= ~(1<<4);
	}
	
	rGPJ1DAT |= (1<<4);
	
	// LCD Black Light Brightness
	rGPDCON=(rGPDCON & ~(0xF))|(1);
	rGPDDAT|=(1<<0);

	// AC97 I/F Port Initialization

	// Multi-Touch Interrupt, GPH0[2] => XEINT[2]
	rGPH0CON=(rGPH0CON & ~(0xF<<8))|(2<<8);
	rGPH0PULL=(rGPH0PULL & (3<<4));
    
    
    
/********************************************************************
    
    // [ Configure TZPC for DMAC(non-secure) ]
	Outp32(0xe3800804, 0xff);
	Outp32(0xE3800810, 0xff);
	Outp32(0xe2900804, 0xff);
	Outp32(0xE2800810, 0xff);
	Outp32(0xE280081C, 0xff);
	Outp32(0xE2900804, 0xff);
	Outp32(0xE2900810, 0xff);

	// [ EVT0 : Clock IO Pad Drive Strength revision ]
	Outp32(0xe030056c, 0x112);	// ETC4DRV

#ifndef BOOT_CODE
 #if defined(WAIKIKI)
	// [ Configure the PMIC ]
	SetGpioBit(GPB, 2, 1); // AP_PS_HOLD
	InitGpioBit(GPB, 2, OUT);
	SetGpioBitPdn(GPB, 2, PDN_OUT1); // Set PWRHOLD to high in PDN mode
	
	InitMAX8698();

	// [ Configure USB Switch for the S20 Connector ]
	SetGpioBit(GPK2, 5, 0); // USB_SEL
	InitGpioBit(GPK2, 5, OUT);
 #elif defined(BB37)
	// [ Configure the PMIC ]
	SetGpioBit(GPB, 2, 1); // AP_PS_HOLD
	InitGpioBit(GPB, 2, OUT);
	SetGpioBitPdn(GPB, 2, PDN_OUT1); // Set PWRHOLD to high in PDN mode
	
	InitMAX8698();

	// [ Configure USB Switch for the S20 Connector ]
	SetGpioBit(GPK2, 5, 0);  // USB_SEL
	InitGpioBit(GPK2, 5, OUT);
#elif defined(WMG150)
	// [ Configure the PMIC ]
	SetGpioBit(GPB, 2, 1); // AP_PS_HOLD
	InitGpioBit(GPB, 2, OUT);
	SetGpioBitPdn(GPB, 2, PDN_OUT1); // Set PWRHOLD to high in PDN mode
	
	InitMAX8698();
	// Uart_TV_sel
	SetGpioBit(GPH0, 3, 1);  
	InitGpioBit(GPH0, 3, OUT);
 #else
//	InitLTC3714(PMIC_ARM, VOUT_1_25);
 #endif

#endif // BOOT_CODE

#if !defined(FPGA) && !defined(BOOT_CODE)
	InitSyscon();
	InitAsyncBridge();
#endif
*/
}

void InitSystem(void)
{
	Uart_Init(115200);
	Port_Init();

	VIC_Init();
// UART 인터럽트 등록
//	rVIC1VECTADDR10 	= (unsigned int)UART0_IntHandler;
//  rVIC1INTENABLE |= (1<<10);
	
    // start time TICK
	StartTimeTick();

// interrupt enable
#if 1
	asm volatile("mrs r12, cpsr\n"
    "bic r12, r12, #0xC0\n"
    "msr cpsr_c, r12");
#endif
}

void Led_Display(int data)
{
	/* 
	 * LED On : Active low 
	 *        LED1->GPJ4, LED2->GPJ4, LED3->GPJ4
	 * Setup GPBCON
	 *  GPJ4CON[5:4] : 01-> GPJ4 Output mode
	 *  GPJ4CON[7:6] : 01-> GPJ4 Output mode
	 *  GPJ4CON[9:8] : 01-> GPJ4 Output mode
	 * GPJ4UP : pull-up function disable
	 */
	/* YOUR CODE HERE : Rebis보드  */ 
	// B2:B1:B1 => LED2:LED3:LED4 => GPE12:GPG5:GPE11

	rGPJ4DAT = 0xF;

	if(data  & 0x01) rGPJ4DAT &= ~(0x1<<0);
	if(data  & 0x02) rGPJ4DAT &= ~(0x1<<1);
	if(data  & 0x04) rGPJ4DAT &= ~(0x1<<2); 
	if(data  & 0x08) rGPJ4DAT &= ~(0x1<<3); 

}

void VIC_Init(void)
{
	// Disable All Interrupt
	rVIC0INTENCLEAR=0xFFFFFFFF;
	rVIC1INTENCLEAR=0xFFFFFFFF;
	rVIC2INTENCLEAR=0xFFFFFFFF;

	// Clear All Interrupt Pending
	rVIC0ADDRESS=0;
	rVIC1ADDRESS=0;
	rVIC2ADDRESS=0;
}

#if 1
// 타임틱 발생 함수 PWM의 Timer4를 사용함(Timer4가 PWM인가?)
void StartTimeTick(void)
{
	int ticf;
	
	ticf = 16113;	//66000000/(256*16);  //PCLK/8
#if 1
   // PV=3
	rTCFG0=(rTCFG0&~(0xFF<<8))|((0xff)<<8);
	// DV=1
	rTCFG1=(rTCFG1&~(0xF<<16))|(4<<16);
	
	rTCNTB4 = ticf / 100;                 // 
		
	// Manual Update & auto-reload on
	rTCON=(rTCON&~(7<<20))|(1<<22|1<<21);
	rTCON &= ~(1<<21);
	rTCON |=  (1<<20);			// Start for Timer4
	
	// TimeTick 인터럽트 벡터 설치 & 인터럽트 마스킹 해제
	rVIC0VECTADDR25  = (unsigned)OSTickISR;
	
    rVIC0INTSELECT = 0;
    
    rTINT_CSTAT |= (1<<4);
    rVIC0INTENABLE |= (1<<25);
	
#else	
	rTCFG0 = (0<<8)|(0xff); //256
	rTCFG1 = (1<<3);             //1/16, no DMA

	/* TCON설정 :Dead zone disable,  auto reload on[3], output inverter off
	*  manual update no operation, timer0 stop, TCNTB0=0, TCMPB0 =0
	*/
	rTCON  = (0<<4)|(1<<3)|(0<<2)|(0<<1)|(0);
	rTCNTB0 = 0;
	rTCMPB0 = 0;
	
    rTCNTB0 = ticf / 100;
    rTCON |= (1<<1)|(0);
	rTCON &= ~(1<<1);

	rTCON |= 1;
	
    rVIC0VECTADDR21 = (unsigned int)OSTickISR;
	
	rVIC0INTSELECT = 0;

	rTINT_CSTAT |= 1;
    rVIC0INTENABLE |= (1<<21);
#endif
}
#endif
void Timer0_INTClear(void)
{
    rVIC0INTENCLEAR |= (1<<21);     
}
void Timer4_INTClear(void)
{
    rVIC0INTENCLEAR = (1<<25);
    rTINT_CSTAT|=(1<<9);
    //rVIC0ADDRESS =0;
    //rVIC1ADDRESS =0;
    //rVIC2ADDRESS =0;
}
void Timer4_INTEnable(void)
{
    rVIC0ADDRESS =0;
    rVIC0INTENABLE = (1<<25);
}


void OSTickISR(void)
{
//	Uart_PutChar('c');
//  Led_Display(tick);
//	tick++;
  OSTimeTick();   // kernel timer handler
  rTINT_CSTAT |=(1<<9);
  rVIC0ADDRESS =0;
}

int getTick(void)
{
		return(tick);
}

void UART0_IntHandler(void)
{
  ISR_UART0();
  rVIC1ADDRESS =0;
  rVIC0ADDRESS =0;
}

/*-----------------------------------------------------------------------------
 * Program : LIBC.C
-----------------------------------------------------------------------------*/