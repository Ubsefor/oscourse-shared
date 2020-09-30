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

#ifdef CONFIG_KSPACE
.comm ret_rip, 8
.comm rbp_reg, 8
.comm rsp_reg, 8
.comm _g_ret,  8

_generall_syscall:
  cli
  popq _g_ret(%rip)
  popq ret_rip(%rip)
  movq %rbp, rbp_reg(%rip)
  movq %rsp, rsp_reg(%rip)
  movq $0x0,%rbp
  leaq bootstacktop(%rip),%rsp
  pushq $GD_KD
  pushq rsp_reg(%rip)
  pushfq
  # Guard to avoid hard to debug errors due to cli misusage.
  orl $FL_IF, (%rsp)
  pushq $GD_KT
  pushq ret_rip(%rip)
  pushq $0x0
  pushq $0x0
  pushq $0x0 // %ds
  pushq $0x0 // %es
  pushq %rax
  pushq %rbx
  pushq %rcx
  pushq %rdx
  pushq rbp_reg(%rip)
  pushq %rdi
  pushq %rsi
  pushq %r8
  pushq %r9
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  movq  %rsp, %rdi
  pushq _g_ret(%rip)
  ret

.globl sys_yield
.type  sys_yield, @function
sys_yield:
  call _generall_syscall
  call csys_yield
  jmp .

# LAB 3: Your code here.
.globl sys_exit
.type  sys_exit, @function
sys_exit:
  call _generall_syscall
  call csys_exit
  jmp .
#endif

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
