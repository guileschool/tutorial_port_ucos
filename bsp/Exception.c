//#include "2440addr.h"
//#include "macro.h"

void Exception_Init(void);
void Undef_Handler(void);
void Pabort_Handler(void);
void Dabort_Handler(void);
void SWI_Handler(void);

void SWI_Handler(void)
{
	Uart_Printf("SWI exception.\n");
	for(;;);
}

void Undef_Handler(void) 
{
	Uart_Printf("Undefined instruction exception.\n");
	for(;;);
}

void Pabort_Handler(void)
{
	volatile int prefetch_addr=0;
	
	 __asm volatile(
		"mov %[retval],lr\n"
		"sub %[retval],%[retval],#4\n"
		: [retval] "=r" (prefetch_addr) : :
	);	
	Uart_Printf("Pabort exception in address 0x%08x.\n", prefetch_addr);		
	for(;;);
}

void Dabort_Handler(void)
{
	volatile int data_addr=0;

	 __asm volatile(
		"mov %[retval1],lr\n"
		"sub %[retval1],%[retval1],#8\n"
		: [retval1] "=r" (data_addr) : :
	);	
	Uart_Printf("Dabort exception in address 0x%08x.\n", data_addr);				
	for(;;);
}

