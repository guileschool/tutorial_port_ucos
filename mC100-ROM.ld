/*---------------------------------------------------------------------------*/
/*- NAME: Test firmware Linker Script File for ROM Workspace                 */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/*---------------------------------------------------------------------------*/
/*- File source          : GCC_ROM.ld                                        */
/*- Object               : Linker Script File for ROM Workspace              */
/*- Modified             : sungho,Park                                       */
/*---------------------------------------------------------------------------*/

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

MEMORY
{
  CODE (rx) : ORIGIN  = 0x90000000, LENGTH = 0x08000000
  DATA (rw) : ORIGIN  = 0x20000000, LENGTH = 0x10000000
}
/* Section Definitions */
SECTIONS
{
  /* first section is .text which is used for code */
  .text : 
  {
    *(.text) 
    *startup.o (.text)
    . = ALIGN(4); 
  } >CODE
  
  /* .rodata section which is used for read-only data (constants) */
  .rodata :
  {
    rodata_start_addr = .;
    *(.rodata)
    *(.rodata.*)
    . = ALIGN(4);
     _etext = .;
     PROVIDE ( _etext = .);
     __RODATA_END__ = .;
     rodata_end_addr = .; 
  } >CODE 

  /* .data section which is used for initialized data */
  .data  : AT(_etext)
  {
   data_start_addr = .;
    __DATA_START__ = .;
    *(.data)
    *(.data.*)
    . = ALIGN(4);
    __DATA_END__ = .;
    data_end_addr = .;
    
  } > DATA

  /* .bss section which is used for uninitialized data */
  .bss :
  {
    __BSS_START__ = .;
    bss_start_addr = .;
    *(.bss)
    *(.bss.*)

    __BSS_END__ = .;
    bss_end_addr = .; 
    . = ALIGN(4);
  } 
  end = .;
  PROVIDE(end = .);

}
