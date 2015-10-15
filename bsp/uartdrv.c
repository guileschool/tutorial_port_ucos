//==============================================================================
// UART APIs
// File Name : uartddrv.c
// Date : 2009/12/04
//==============================================================================
/**/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdarg.h>
#include <locale.h> //uartdrv.c

#include "C100RegAddr.h"
#include "uartdrv.h"

void Uart_Init(u32 uiBaudRate)
{
	const u32 uArrUDIVSLOT[16] = {
			0x0000, 0x0080, 0x0808, 0x0888, 0x2222, 0x4924, 0x4a52, 0x54aa,
			0x5555, 0xd555, 0xd5d5, 0xddd5, 0xdddd, 0xdfdd, 0xdfdf, 0xffdf};

	float fDIV_VAL;
	u32 uDIV_VAL;
	u32 uSlotIndex;

	// Port Setting for UART[0], GPA0[0]:RxD, GPA0[1]:TxD
	rGPA0CON=(rGPA0CON&~(0xF<<4|0xF))|(2<<4|2);

	// Normal Mode, No Parity, 1-Stop Bit, Word Length=8
	rULCON0=(0<<6|0<<3|0<<2|3);

	// Disable FIFO
	rUFCON0=0;


	// Disable AFC(Auto Flow Control)
	rUMCON0=0;

	//PCLK, TX/RX INTR Type=Pulse, All INTR=Disable, Normal Operation, Normal Transmit, TX/RX Mode=Interrupt or Polling	
	rUCON0&= ~((1<<9)|(1<<8)|(1<<3)|(1<<1));
	rUCON0=(0<<10|0<<9|0<<8|0<<7|0<<6|0<<5|0<<4|0<<3|1<<2|0<<1|1<<0);

	fDIV_VAL=(get_PCLKD1()/16.0/(float)uiBaudRate)-1;
	uDIV_VAL=(u32)fDIV_VAL;
	rUBRDIV0=uDIV_VAL;
	
	rUINTSP0 = (0xf<<0);
	rUINTP0  = (0xf<<0);

	rUINTM0 = (3<<1)|(2<<1)|(1<<1)|(1<<0);
	uSlotIndex=(u32)((fDIV_VAL - (float)uDIV_VAL)*16);
	rUDIVSLOT0=uArrUDIVSLOT[uSlotIndex];
}

void Uart_PutChar(s8 cData)
{
	if(cData=='\n')
	{
		// Wait Tx Buffer Empty
		while((rUTRSTAT0 & (1<<1))==0);
		rUTXH0='\r';
	}
	
	// Wait Tx Buffer Empty
	while((rUTRSTAT0 & (1<<1))==0);
	rUTXH0=cData;
}

void Uart_PutString(s8 *str)
{
	while(*str)
	{
		Uart_PutChar(*(str++));
	}
}

void Uart_Printf(const s8 *fmt,...)
{
    va_list ap;
    s8 string[256];

    va_start(ap, fmt);
    vsprintf(string, fmt, ap);
    Uart_PutString(string);
    va_end(ap);
}

s8 Uart_GetChar(void)
{
	// Wait Rx Buffer Data Ready
	while((rUTRSTAT0&0x1)==0);
	return(rURXH0);
}

s8 Uart_GetKey(void)
{
	// Check Rx Buffer Data Ready
	if((rUTRSTAT0&0x1)==0)
	{
		return(0);
	}
	else
	{
		return(rURXH0);
	}
}

void Uart_GetString(s8 *string)
{
	s8 *string2 = string;
	s8 c;
	
	while((c = Uart_GetChar())!='\r')
	{
		if(c=='\b')
		{
			if( (int)string2 < (int)string )
			{
				Uart_Printf("\b \b");
				string--;
			}
		}
		else 
		{
			*(string++) = c;
			Uart_PutChar(c);
		}
	}
	
	(*string)='\0';
	Uart_PutChar('\n');
}

s32 Uart_GetIntNum(void)
{
	s8 str[30];
	s8 *string = str;
	s32 base     = 10;
	s32 minus    = 0;
	s32 result   = 0;
	s32 lastIndex;    
	s32 i;

	// To use "atoi(), "isalpha()", and "isupper()" Locale must be set before.
	setlocale(LC_ALL, "C");
	
	Uart_GetString(string);
    
	if(string[0]=='-')
	{
		minus = 1;
		string++;
	}
    
	if(string[0]=='0' && (string[1]=='x' || string[1]=='X'))
	{
		base = 16;
		string += 2;
	}
    
	lastIndex = strlen(string) - 1;
    
	if(lastIndex<0)
		return(-1);
    
	if(string[lastIndex]=='h' || string[lastIndex]=='H' )
	{
		base = 16;
		string[lastIndex] = 0;
		lastIndex--;
	}

//	Uart_Printf("base=%d, lastIndex=%d, minus=%d\n", base, lastIndex, minus);
	
	if(base==10)
	{
		result = atoi(string);
		result = minus ? (-1*result):result;
	}
	else
	{
		for(i=0;i<=lastIndex;i++)
		{
			if(isalpha(string[i]))
			{
				if(isupper(string[i]))
				{
					result = (result<<4) + string[i] - 'A' + 10;
				}
				else
				{
					result = (result<<4) + string[i] - 'a' + 10;
				}
			}
			else
			{
				result = (result<<4) + string[i] - '0';
			}
		}
		
		result = minus ? (-1*result):result;
	}
	
	return(result);
}
