/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>

#ifdef CONFIG_KSPACE
.comm intr_ret_rip, 8
.comm intr_rbp_reg, 8
.comm intr_rsp_reg, 8
.comm intr_cs, 8
.comm intr_rflags, 8
#endif

.text

.globl clock_thdlr
.type clock_thdlr, @function;
.align 2;
#ifdef CONFIG_KSPACE
clock_thdlr:
  popq intr_ret_rip(%rip)
  popq intr_cs(%rip)
  popq intr_rflags(%rip)
  movq %rbp, intr_rbp_reg(%rip)
  movq %rsp, intr_rsp_reg(%rip)
  movq $0x0,%rbp
  leaq bootstacktop(%rip),%rsp
  pushq $GD_KD
  pushq intr_rsp_reg(%rip)
  pushq intr_rflags(%rip)
  pushq intr_cs(%rip)
  pushq intr_ret_rip(%rip)
  pushq $0
  pushq $(IRQ_OFFSET + IRQ_CLOCK)
  pushq $0x0 // %ds
  pushq $0x0 // %es

  pushq %rax
  pushq %rbx
  pushq %rcx
  pushq %rdx
  pushq intr_rbp_reg(%rip)
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

  movq %rsp,%rdi
  call trap
  jmp .
#else
clock_thdlr:
  jmp .
#endif
