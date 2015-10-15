#ifndef __UART_H__
#define __UART_H__

#include "typedef.h"

#define UART_CH0_BASE		0xEC000000
#define UART_CH1_BASE		0xEC000400
#define UART_CH2_BASE		0xEC000800
#define UART_CH3_BASE		0xEC000C00

#define printf         Uart_Printf

enum UART_CH_NUM
{
	UART_CH0=0,
	UART_CH1,
	UART_CH2,
	UART_CH3
};

enum UART_REG
{
	ULCON = 0x00,
	UCON = 0x04,
	UFCON = 0x08,
	UMCON = 0x0C,
	UTRSTAT = 0x10,
	UERSTAT = 0x14,
	UFSTAT = 0x18,
	UMSTAT = 0x1C,
	UTXD = 0x20,
	URXD = 0x24,
	UBRDIV = 0x28,
	DIVSL = 0x2C,
	INTP = 0x30,
	INTSP = 0x34,
	INTM = 0x38
};

#ifdef __cplusplus
extern "C" {
#endif

void Uart_Init(u32 uiBaudRate);
void Uart_PutChar(s8 cData);
void Uart_PutString(s8 *str);
void Uart_Printf(const s8 *fmt,...);
s8 Uart_GetChar(void);
s8 Uart_GetKey(void);
void Uart_GetString(s8 *string);
s32 Uart_GetIntNum(void);

#ifdef __cplusplus
}
#endif

#endif
