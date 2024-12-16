ENTRY(_start)

MEMORY
{
   flash (rx) : ORIGIN = 0x00000000, LENGTH = 0x8000  /* 32kb Flash memory for code and read-only data */
   sram (rwx) : ORIGIN = 0x20000000, LENGTH = 0x4000  /* 16kb SRAM for stack, heap, and global variables */
}

SECTIONS
{
  /* Code and Read-Only Data -  Code is executed from FLASH and ReadOnly Data also directly accessed from FLASH*/
  .text   : { *(.text*) } > flash
  .rodata : { *(.rodata*) } > flash

  /* Initialized Global/Static Variable Data Must be copied from Load Memory Address (LMA=FLASH) to Virtual Memory Address (VMA=SRAM) */
  __data_lma_start__ = ALIGN(4);
  .data : AT(__data_lma_start__)
  {	
    __data_vma_start__ = .;
    *(.data*)
    __data_vma_end__ = .;
  } > sram

  /* Uninitialized Global/Static Variables (Must be Zero-Initialized) */
  .bss :
  {
    __bss_vma_start__ = ALIGN(4);
    *(.bss*)
    __bss_vma_end__ = .;
  } > sram

 /* Stack and Heap Regions */
  _stack_top = ORIGIN(sram) + LENGTH(sram); /* Top of stack (grows downward) */
  _heap_top = __bss_vma_end__;             /* Start of heap */
  _heap_end = _heap_top - 0x100;           /* Reserve 256 bytes for stack */
  _stack_bottom = _heap_end;               /* Define stack bottom */
}
