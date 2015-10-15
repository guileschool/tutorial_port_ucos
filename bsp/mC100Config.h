/*
 * mC100Config.h
 *
 *  Created on: 2010. 12. 6.
 *      Author: Seonghye, Son
 */

#ifndef MC100CONFIG_H_
#define MC100CONFIG_H_

#define	_DRAM0_BaseAddress		0x20000000
#define	_DRAM0_Size				0x20000000
#define _DRAM0_EndoAddress		(_DRAM0_BaseAddress+_DRAM0_Size)

// LCD Frame Buffer
#define LCD_FB0_SIZE			 		0x1000000       // 16[MB]
#define LCD_FB1_SIZE					0x1000000       // 16[MB]
#define LCD_FB2_SIZE					0x1000000       // 16[MB]
#define LCD_FB3_SIZE					0x1000000       // 16[MB]
#define LCD_FB4_SIZE					0x1000000       // 16[MB]
#define LCD_FB_TOTAL_SIZE	 		0x5000000       // 80[MB]
#define LCD_FB_SIZE_ALIGN			0x1000000       // 16[MB]

#define LCD_FB_START_ADDR			(_DRAM0_EndoAddress - 6*LCD_FB_SIZE_ALIGN)		// 0x3A00_0000
//#define LCD_FB0_START_ADDR		0x3A444442						// 0x3A00_0000
#define LCD_FB0_START_ADDR		(LCD_FB_START_ADDR)						// 0x3A00_0000
#define LCD_FB1_START_ADDR		(LCD_FB0_START_ADDR + LCD_FB0_SIZE)		// 0x3B00_0000
#define LCD_FB2_START_ADDR		(LCD_FB1_START_ADDR + LCD_FB1_SIZE)		// 0x3C00_0000
#define LCD_FB3_START_ADDR		(LCD_FB2_START_ADDR + LCD_FB2_SIZE)		// 0x3D00_0000
#define LCD_FB4_START_ADDR		(LCD_FB3_START_ADDR + LCD_FB3_SIZE)		// 0x3E00_0000
#define LCD_FB_END_ADDR			(LCD_FB4_START_ADDR + LCD_FB4_SIZE)		// 0x3F00_0000


#define	_MMUTT_SIZE				0x4000
#define	_MMUTT_STARTADDRESS		(_DRAM0_EndoAddress-_MMUTT_SIZE)

#define	_MMUTT_L2_SIZE			0x8000
#define	_MMUTT_L2_STARTADDRESS	(_MMUTT_STARTADDRESS-_MMUTT_L2_SIZE)


#endif /* MC100CONFIG_H_ */
