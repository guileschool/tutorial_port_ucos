#ifndef __INT_H__
#define __INT_H__

#include "../kernel/ucos_ii.h"

typedef enum 
{
	INT_EINT0    		= 0,
	INT_EINT1           = 1,
	INT_EINT2           = 2,
	INT_EINT3           = 3,
	INT_EINT4           = 4,
	INT_EINT5           = 5,
	INT_EINT6           = 6,
	INT_EINT7           = 7,
	INT_EINT8           = 8,
	INT_EINT9           = 9,
	INT_EINT10          = 10,
	INT_EINT11          = 11,
	INT_EINT12          = 12,
	INT_EINT13          = 13,
	INT_EINT14          = 14,
	INT_EINT15          = 15,
	INT_EINT16_31       = 16,
	INT_BATF            = 17,
	INT_MDMA            = 18,
	INT_DMA_A           = 19,
	INT_DMA_B           = 20,   
	INT_TIMER0          = 21,
	INT_TIMER1          = 22,
	INT_TIMER2          = 23,
	INT_TIMER3          = 24,
	INT_TIMER4          = 25,
	INT_SYS_TIMER       = 26,   
	INT_WDT             = 27,
	INT_RTC_ALARM       = 28,
	INT_RTC_TIC         = 29,
	INT_GPIO            = 30,
	//RESERVED          = 31,
						
	INT_CORTEX0         = 32,
	INT_CORTEX1         = 33,
	INT_CORTEX2         = 34,
	INT_CORTEX3         = 35,
	INT_CORTEX4         = 36,
	INT_IEM_APC         = 37,
	INT_IEM_IEC         = 38,   
	INT_ONDC            = 39,
	INT_NFC             = 40,
	INT_CFC             = 41,
	INT_UART_A          = 42,
	INT_UART_B          = 43,
	INT_UART_C          = 44,
	INT_UART_D          = 45,
	INT_I2C             = 46,
	INT_SPI_A           = 47,
	INT_SPI_B           = 48,
	INT_SPI_C           = 49,
	INT_IRDA            = 50,
	INT_CAN_A           = 51,
	INT_CAN_B           = 52,
	INT_HSI_RX          = 53,
	INT_HSI_TX          = 54,
	INT_UHOST           = 55,
	INT_USB             = 56,
	INT_MSM             = 57,
	INT_SDHC_A          = 58,
	INT_SDHC_B          = 59,
	INT_SDHC_C          = 60,
	INT_MIPI_CSI_S      = 61,
	INT_MIPI_DSI_M      = 62,
	//RESERVED          = 63,
						
	INT_LCD0            = 64,
	INT_LCD1            = 65,
	INT_LCD2            = 66,
	INT_LCD3            = 67,
	INT_ROTATOR         = 68,
	INT_CAMIF_A         = 69,
	INT_CAMIF_B         = 70,
	INT_CAMIF_C         = 71,
	INT_JPEG            = 72,
	INT_2D              = 73,
	INT_3D              = 74,
	INT_MIXER           = 75,
	INT_HDMI            = 76,
	INT_HDMI_I2C        = 77,
	INT_MFC             = 78,
	INT_TVENC           = 79,   
	INT_I2S_A           = 80,
	INT_I2S_B           = 81,
	INT_I2S_C           = 82,
	INT_AC97            = 83,
	INT_PCM_A           = 84,
	INT_PCM_B           = 85,
	INT_SPDIF           = 86,
	INT_ADC             = 87,
	INT_PENDN           = 88,
	INT_KEYPAD          = 89,
	INT_GPS             = 90,
	INT_SEC             = 91,
	INT_SEC_RX          = 92,
	INT_SEC_TX          = 93,
	INT_SDM_IRQ         = 94,
	INT_SDM_FIQ         = 95
} INT_NUM;

/*
class INTC
{
public:
	void InitIp(void);
	void SetHandler(INT_NUM eIntNum, void (*handler)() __irq);
	void SetHandlerAndUnmask(INT_NUM eIntNum, void (*handler)() __irq);
	void Mask(INT_NUM eIntNum);
	void Unmask(INT_NUM eIntNum);
	void ClearPending(INT_NUM eIntNum);
	void IsPendingIntr(bool& bPending);
	void SetVicPriority(INT_NUM eIntNum, u32 uPriority);
};
*/
void InitIp(void);
void SetHandler(INT32U eIntNum, void (*handler)(void));
void SetHandlerAndUnmask(INT32U eIntNum, void (*handler)(void));
void Mask(INT32U eIntNum);
void Unmask(INT32U eIntNum);
void ClearPending(INT32U eIntNum);
void IsPendingIntr(BOOLEAN * bPending);
void SetVicPriority(INT32U eIntNum, INT32U uPriority);
#endif // __INT_H__

