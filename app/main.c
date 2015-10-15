/*******************************************************************************
**	File:
**
**		main.c
**
**  Contents:
**		uC/OS-II programming
**
**	History:
**		Date        Name              Description
**		------------------------------------------------------------------------
**
*******************************************************************************/
#include <stdio.h>
#include "uartdrv.h"

void uart_putc(int data);
//void Led_Display(int num);
void Timer_Init(void);

//
// 어플리케이션 메인 루틴
//
int main(void)
{
	int old,sec;

	InitSystem();
	Uart_Printf("hello, world!\n");
	for(;;)
	{
		//Uart_PutChar('$');	
		sec= getTick();

		if(!(sec%100) && (old != sec))
		{
			Uart_Printf("tick=%d\n", sec/100);
		}

		if(old != sec){ old= sec; }
	}

	return 0;    
}

/*-----------------------------------------------------------------------------
 * Program : main.c
-----------------------------------------------------------------------------*/
