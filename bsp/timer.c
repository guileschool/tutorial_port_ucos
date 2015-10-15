/*
 * timer.c
 *
 *  Created on: 2010. 5. 5.
 *      Author: Jongin, Cha
 */

#include "C100RegAddr.h"
#include "typedef.h"
#include "timer.h"

void OSTickISR(void);

void Timer_Init(void)
{
	/*
	* 	Timer Init
	* Prescaler value : 255, dead zone length = 0
	* Divider value : 1/16, no DMA mode
	* New frequency : (PCLK/(Prescaler value+1))*Divider value = (66Mhz/(256))*(1/16)
	*				  = 16.1KHz(62.061us)
	*/
	unsigned int ticf;
	
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

void Timer_Delay(int msec)
{
	/*
	* 1) TCNTB0설정 : 넘겨받는 data의 단위는 msec이다.
	*                  따라서 msec가 그대로 TCNTB0값으로 설정될 수는 없다.
	* 2) manual update후에  timer0를 start시킨다.
	* 	 note : The bit has to be cleared at next writing.
	* 3) TCNTO0값이 0이 될때까지 기다린다.
	*/
	rTCNTB0 = 16.1 * msec;

	rTCON |= (1<<1)|(0);
	rTCON &= ~(1<<1);

	rTCON |= 1;

	while(rTCNTO0 != 0);
}
