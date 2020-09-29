/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>

.code64
.text

.globl entry
entry:
  # Save LoadParams in uefi_lp.
  movq %rcx, uefi_lp(%rip)

  # Set the stack pointer.
  leaq bootstacktop(%rip),%rsp

  # Clear the frame pointer register (RBP)
  # so that once we get into debugging C code,
  # stack backtraces will be terminated properly.
  xorq %rbp, %rbp      # nuke frame pointer

  # now to C code
  call i386_init

  # Should never get here, but in case we do, just spin.
spin:  jmp  spin

.data

# Allocate boot stack forcing page alignment.
.p2align PGSHIFT
.globl bootstack
bootstack:
.space KSTKSIZE
.globl bootstacktop
bootstacktop:

# Provide storage for loader parameters.
.globl uefi_lp
uefi_lp:
  .quad 0x0
