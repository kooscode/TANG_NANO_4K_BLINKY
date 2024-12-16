
/*
 -------------------------------------------------------------------------------
 Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
 -------------------------------------------------------------------------------
*/


/*
 * Bootloader for ARM Cortex-M3
 * 1. Initialize .data and .bss sections in SRAM.
 * 2. Transfer control to the `main` function.
 * 3. Trap in an infinite loop if `main` returns unexpectedly.
 */

/* Assembly Directives */
.cpu cortex-m3	/* Target Cortex M3 */
.arch armv7-m	/* Target ARMv7-M ARchitecture */
.syntax unified	/* Enable unified ARM and Thumb assembly syntax */
.thumb			/* Generate Thumb-2 machine code and not ARM - Cortex M3 only supports Thumb */

/* Directives for output binary options using ARM EABI (Embedded Application Binary Interface) */
.eabi_attribute 20, 1 /* CPU supports Thumb-2 instruction set. */
.eabi_attribute 21, 1 /* 8-byte alignment required for the stack pointer */
.eabi_attribute 23, 3 /* Use hardware floating-point ABI (hard float) */
.eabi_attribute 24, 1 /* Use support for half-precision floating point (optional). */
.eabi_attribute 25, 1 /* Use ARMv7-M architecture-specific ABI */
.eabi_attribute 26, 1 /* Software support for division instructions */
.eabi_attribute 30, 1 /* Use a specific procedure call standard */
.eabi_attribute 34, 1 /* Use long branch relocations in Thumb-2. */
.eabi_attribute 18, 4 /* Enable ARM version or additional features (e.g., the M-profile vector table) */

.text
	
	/* ARM Cortex M3 Interrupt Vector Offsets from the Gowin datasheet */
	/* https://www.gowinsemi.com/upload/database_doc/1807/document/674d2552278ec.pdf */
	/* PAGE 31 */

	/* === Internal Interrupts ===*/
	.word 0x20004000 	/* _StackTop */
	.word _start+1   	/* Reset_Handler (+1 means LSB is 1=Thumb2 Mode NOT 0=ARM) */
	.word _infloop		/* NMI_Handler */
	.word _infloop		/* HardFault_Handler */
	.word _infloop		/* MemMange_Handler */
	.word _infloop		/* BusFault_Handler */
	.word _infloop		/* UsageFault_Handler */
	.word _infloop		/* reserved */
	.word _infloop		/* reserved */
	.word _infloop		/* reserved */
	.word _infloop		/* reserved */
	.word _infloop		/* SVC_Handler */
	.word _infloop		/* DebugMon_Handler */
	.word _infloop		/* reserved */
	.word _infloop		/* PendSV_Handler */
	.word _infloop		/* SysTick_Handler */
	/* === External Interrupts === */
	.word _infloop		/* UART0_Handler */
	.word _infloop		/* USER_INT0 */
	.word _infloop		/* UART1_Handler */
	.word _infloop		/* USER_INT1_Handler */
	.word _infloop		/* USER_INT2_Handler */
	.word _infloop		/* RTC_Handler */
	.word _infloop		/* PORT0_COMB_Handler */
	.word _infloop		/* USER_INT3_Handler */
	.word _infloop		/* TIMER1_Handler */
	.word _infloop		/* TIMER2_Handler */
	.word _infloop		/* reserved */
	.word _infloop		/* I2C_Handler	*/
	.word _infloop		/* UARTOVF_Handler */
	.word _infloop		/* USER_INT4 */
	.word _infloop		/* USER_INT5 */
	.word _infloop		/* reserved */
	.word _infloop		/* PORT0_0_Handler */
	.word _infloop		/* PORT0_1_Handler */
	.word _infloop		/* PORT0_2_Handler */
	.word _infloop		/* PORT0_3_Handler */
	.word _infloop		/* PORT0_4_Handler */
	.word _infloop		/* PORT0_5_Handler */
	.word _infloop		/* PORT0_6_Handler */
	.word _infloop		/* PORT0_7_Handler */
	.word _infloop		/* PORT0_8_Handler */
	.word _infloop		/* PORT0_9_Handler */
	.word _infloop		/* PORT0_10_Handler */
	.word _infloop		/* PORT0_11_Handler */
	.word _infloop		/* PORT0_12_Handler */
	.word _infloop		/* PORT0_13_Handler */
	.word _infloop		/* PORT0_14_Handler */
	.word _infloop		/* PORT0_15_Handler */

/* mem_copy(src, dest_start, dest_end) - assumes 4-byte aligned */
.macro mem_copy src, dest_start, dest_end
    ldr r0, =\src       /* Source address */
    ldr r1, =\dest_start/* Destination Start address */
    ldr r2, =\dest_end	/* Destination End address */
1:	cmp r1, r2          /* Check if dest_end reached */
    ittt lo				/* If r1 < r2, execute the next 3 instructions */
    ldrlo r3, [r0], #4  /* Load 4 bytes from address [r0] into r3 and post-increment r0 by 4 */
    strlo r3, [r1], #4  /* Store 4 bytes from r3 into address [r1] and post-increment r1 by 4 */
    blo 1b        		/* Loop if more data remains to be copied */
.endm

/* mem_zero(dest_start, dest_end) - assumes 4-byte aligned */
.macro mem_zero dest_start, dest_end
    ldr r0, =\dest_start/* Destination Start address */
    ldr r1, =\dest_end	/* Destination End address */
    movs r2, #0         /* Move 0x00 constant into r2 */
1:  cmp r0, r1     		/* Check if dest_end reached */
    itt lo				/* If r0 < r1, execute the next 2 instructions */
    strlo r2, [r0], #4  /* Store 4 * 0x00 bytes from r2 into address [r0] and post-increment r0 by 4 */
    blo 1b         		/* Loop if more memory needs to be zero'd out */
.endm

/* Infinite Loop - I'm using this for all unassigned Interrupt handlers.. */
_infloop:
    b . /* infinite loop */

/************** BOOTLOADER **************/
.global _start
_start:
	/* Initialize .data section and copies all "Initialized" global and static variable values from FLASH to SRAM 
	   Refer to the firmware.ld linker script to ensure .data is propertly mapped between lam and vma 
	   lma=load memory address (address in flash), vma=virtual memory address (addres in sram) */
	mem_copy __data_lma_start__, __data_vma_start__, __data_vma_end__

	/* Zero-initialize .bss section in SRAM where all non-Initialzed global/static variables will be stored, 
	   these Global/Static variables have no initialized value and needs to be zero'd out */
	mem_zero __bss_vma_start__, __bss_vma_end__

	/* After globa/static variable values are set or zero'd out, transfer control to the main() program
	   Ensure the C++ main() is extern "C" decorated */
	bl main	

	/* Trap in an infinite loop if main accidently returns 
	   Ensure the C++ main() is wrapped in a while(true) and will never return */
	b _infloop	
