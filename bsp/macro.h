#ifndef __MACRO_H__
#define __MACRO_H__
//=============================================================================
// File Name : macro.h
//=============================================================================

// Bit opreation macros

#define	SetBit(dest, position)				((dest) |=  ((unsigned)0x1<<(position)))
#define	ClrBit(dest, position)				((dest) &= ~((unsigned)0x1<<(position)))
#define	IvtBit(dest, position)				((dest) ^=  ((unsigned)0x1<<(position)))

#define	ClrAra(dest, bits, position)		((dest) &= ~(((unsigned)bits)<<(position)))
#define	SetAra(dest, bits, position)		((dest) |=  (((unsigned)bits)<<(position)))
#define	IvtAra(dest, bits, position)		((dest) ^=  (((unsigned)bits)<<(position)))

#define	WrtBlk(dest, bits, data, position)	((dest) = ((unsigned)dest) & ~(((unsigned)bits)<<(position)) | (((unsigned)data)<<(position)))
#define ExtAra(dest, bits, position)		((((unsigned)dest)>>(position)) & (bits))

#define ChkSet(dest, position)				((((unsigned)dest)>>(position)) & 0x1)
#define ChkClr(dest, position)				(!((((unsigned)dest)>>(position)) & 0x1))


//#define __XDEF_REPORT_STAT
//#define __BUFFERED_IO
//#define _MINI_CALC_ 

#endif
