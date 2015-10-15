#ifndef __TYPEDEF_H__
#define __TYPEDEF_H__

typedef unsigned char		u8;
typedef unsigned short int	u16;
typedef unsigned int		u32;
typedef unsigned long long	u64;
	
typedef char				s8;
typedef short int			s16;
typedef int				s32;
typedef long long			s64;

typedef unsigned int		bool;

typedef volatile unsigned char			v_u8;
typedef volatile unsigned short int		v_u16;
typedef volatile unsigned int			v_u32;
typedef volatile unsigned long long		v_u64;
	
typedef volatile char					v_s8;
typedef volatile short int				v_s16;
typedef volatile int					v_s32;
typedef volatile long long				v_s64;

typedef unsigned char		unchar;

//typedef unsigned short		ushort;
//typedef unsigned int		uint;
typedef unsigned long		ulong;
typedef unsigned char		uchar;

typedef volatile unsigned long	vu_long;
typedef volatile unsigned short vu_short;
typedef volatile unsigned char	vu_char;

#define __REGb(x)		(*(v_u8 *)(x))
#define __REGhw(x)		(*(v_u16 *)(x))
#define __REGw(x)		(*(v_u32 *)(x))
#define __REGdw(x)		(*(v_u64 *)(x))

#define KB(n)		(n<<10)
#define MB(n)		(n<<20)

#define Outp32(addr, data)		(*(volatile u32 *)(addr) = (data))
#define Outp16(addr, data)		(*(volatile u16 *)(addr) = (data))
#define Outp8(addr, data)		(*(volatile u8 *)(addr) = (data))
#define Inp32(addr, data)		(data = (*(volatile u32 *)(addr)))
#define Inp16(addr, data)		(data = (*(volatile u16 *)(addr)))
#define Inp8(addr, data)		(data = (*(volatile u8 *)(addr)))

#define TRUE   1   /* Logical 1 */
#define FALSE  0   /* Logical 0 */

#define true   1   /* Logical 1 */
#define false  0   /* Logical 0 */

#endif
