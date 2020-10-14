/* Simple linker script for the JOS kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_head64)

SECTIONS
{
  . = 0x01500000;

  .bootstrap : {
    obj/kern/bootstrap.o (.text .data .bss)
  }

  /* Link the kernel at this address: "." means the current address */
  /* Note, KASAN shadow is loaded at 0xFA000000 in GNUMakefile, keep them in sync */
  . = 0x8041600000;

  /* AT(...) gives the load address of this section, which tells
     the boot loader where to load the kernel in physical memory */
  .text : AT(0x01600000) {
    __text_start = .;
    *(EXCLUDE_FILE(*obj/kern/bootstrap.o) .text .stub .text.* .gnu.linkonce.t.*)
    . = ALIGN(8);
    __text_end = .;
  }

  PROVIDE(etext = .); /* Define the 'etext' symbol to this value */

  .rodata : {
    __rodata_start = .;
    *(EXCLUDE_FILE(*obj/kern/bootstrap.o) .rodata .rodata.* .gnu.linkonce.r.* .data.rel.ro.local)
    . = ALIGN(8);
    __rodata_end = .;
  }


  /* Adjust the address for the data segment to the next page */
  . = ALIGN(0x1000);

  /* The data segment */
  .data : {
    __data_start = .;
    *(EXCLUDE_FILE(obj/kern/bootstrap.o) .data .data.rel .data.rel.local .got .got.plt)
    . = ALIGN(8);
    __data_end = .;
  }

  .ctors :
  {
    __ctors_start = .;
    KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP(* (.init_array .ctors))
    __ctors_end = .;
    . = ALIGN(8);
  }

  .dtors :
  {
    __dtors_start = .;
    KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP(*(.fini_array .dtors))
    __dtors_end = .;
    . = ALIGN(8);
  }

  PROVIDE(edata = .);

  .bss : {
    __bss_start = .;
    *(EXCLUDE_FILE(obj/kern/bootstrap.o) .bss)
    *(COMMON)
    /* Ensure page-aligned segment size */
    . = ALIGN(0x1000);
    __bss_end = .;
  }

  PROVIDE(end = .);

  /DISCARD/ : {
    *(.eh_frame .note.GNU-stack)
  }
}
