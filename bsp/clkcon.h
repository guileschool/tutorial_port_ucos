#ifndef __CLKCON_H__
#define __CLKCON_H__

#define FIN_APLL		12000000
#define FIN_MPLL		12000000
#define FIN_EPLL		12000000
#define FIN_HPLL		27000000

#ifdef __cplusplus
extern "C" {
#endif

u32 get_FOUT_APLL(void);
u32 get_FOUT_MPLL(void);
u32 get_ARMCLK(void);
u32 get_HCLKD0(void);
u32 get_HCLKD1(void);
u32 get_PCLKD1(void);

#ifdef __cplusplus
}
#endif

#endif
