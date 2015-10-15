//==============================================================================
// Clock Controller APIs
// File Name : clkcon.c
// Creator : Ha Dong-Mun(chaboom@ajou.ac.kr)
// Date : 2009/12/04
//==============================================================================

#include "typedef.h"
#include "C100RegAddr.h"
#include "clkcon.h"
#include "uartdrv.h"

u32 get_FOUT_APLL(void)
{
	u32 mdiv, pdiv, sdiv;
	u32 fout;
	
	mdiv=((rAPLL_CON & (0x3FF<<16)) >> 16);
	pdiv=((rAPLL_CON & (0x3F<<8)) >> 8);
	sdiv=((rAPLL_CON & (0x7<<0)) >> 0);

#ifdef DEBUG
	Uart_Printf("rAPLL_CON=%08X\n", rAPLL_CON);
	Uart_Printf("mdiv=%d\n", mdiv);
	Uart_Printf("pdiv=%d\n", pdiv);
	Uart_Printf("sdiv=%d\n", sdiv);
#endif

	fout=((u64)mdiv*(u64)FIN_APLL)/((u64)pdiv*(1<<sdiv));
	return(fout);
}

u32 get_FOUT_MPLL(void)
{
	u32 mdiv, pdiv, sdiv;
	u64 fout;
	
	mdiv=((rMPLL_CON & (0xFF<<16)) >> 16);
	pdiv=((rMPLL_CON & (0x3F<<8)) >> 8);
	sdiv=((rMPLL_CON & (0x7<<0)) >> 0);

#ifdef DEBUG
	Uart_Printf("rMPLL_CON=%08X\n", rMPLL_CON);
	Uart_Printf("mdiv=%d\n", mdiv);
	Uart_Printf("pdiv=%d\n", pdiv);
	Uart_Printf("sdiv=%d\n", sdiv);
#endif

	fout=((u64)mdiv*(u64)FIN_MPLL)/((u64)pdiv*(1<<sdiv));
	return(fout);
}

u32 get_ARMCLK(void)
{
	u32 DIV_APLL, DIV_ARM;
	u32 MUX_APLL;

	DIV_APLL=(rCLK_DIV0&0x1)+1;
	DIV_ARM=((rCLK_DIV0&(0x7<<4))>>4)+1;

	MUX_APLL=(rCLK_SRC0 & (1<<0));

	if(MUX_APLL!=0)
	{
		return(get_FOUT_APLL()/DIV_APLL/DIV_ARM);
	}
	else
	{
		return(FIN_APLL);
	}
}

u32 get_HCLKD0(void)
{
	u32 DIV_D0_BUS;
	
	DIV_D0_BUS=((rCLK_DIV0&(0x7<<8))>>8)+1;
	return(get_ARMCLK()/DIV_D0_BUS);
}

u32 get_HCLKD1(void)
{
	u32 MUX_APLL;
	u32 MUX_MPLL;
	u32 MUX_AM;
	u32 OUT_MUX_AM;
	u32 DIV_APLL2;
	u32 DIV_D1_BUS;

	MUX_APLL=(rCLK_SRC0 & (1<<0));
	MUX_MPLL=(rCLK_SRC0 & (1<<4));
	MUX_AM=(rCLK_SRC0 & (1<<16));

	DIV_D1_BUS=((rCLK_DIV1 & (0x7<<12))>>12)+1;	
	DIV_APLL2=((rCLK_DIV1 & (0x7<<0))>>0)+1;

	if(MUX_AM != 0)
	{
		if(MUX_APLL != 0)
		{
			OUT_MUX_AM=(get_FOUT_APLL()/DIV_APLL2);
		}
		else
		{
			OUT_MUX_AM=(FIN_APLL/DIV_APLL2);
		}
	}
	else
	{
		if(MUX_MPLL != 0)
		{
			OUT_MUX_AM=get_FOUT_MPLL();
		}
		else
		{
			OUT_MUX_AM=FIN_MPLL;
		}
	}

	return(OUT_MUX_AM/DIV_D1_BUS);
}

u32 get_PCLKD1(void)
{
	u32 DIV_PCLK;

	DIV_PCLK=((rCLK_DIV1 & (0x7<<16))>>16)+1;
	return(get_HCLKD1()/DIV_PCLK);
}


