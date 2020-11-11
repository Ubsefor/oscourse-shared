/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>
#include <kern/macro.h>

#include <kern/picirq.h>

#ifdef CONFIG_KSPACE
.comm intr_ret_rip, 8
.comm intr_rsp_reg, 8
.comm intr_cs, 8
.comm intr_ss, 8
.comm intr_rflags, 8
#endif

###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)                                   \
  .globl name;            /* define global symbol for 'name' */  \
  .type name, @function;  /* symbol type is function */          \
  .align 2;               /* align function definition */        \
  name:                   /* function starts here */             \
  pushq $(num);                                                  \
  jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num) \
  .globl name;                      \
  .type name, @function;            \
  .align 2;                         \
  name:                             \
  pushq $0;                         \
  pushq $(num);                     \
  jmp _alltraps

.text

.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
  subq $8,%rsp
  movw %ds,(%rsp)
  subq $8,%rsp
  movw %es,(%rsp)
  PUSHA
  movq $GD_KD,%rax
  movq %rax,%ds
  movq %rax,%es
  movq %rsp,%rdi
  call trap
  jmp .

.globl clock_thdlr
.type clock_thdlr, @function;
.align 2;
#ifdef CONFIG_KSPACE
clock_thdlr:
  popq intr_ret_rip(%rip)
  popq intr_cs(%rip)
  popq intr_rflags(%rip)
  popq intr_rsp_reg(%rip)
  popq intr_ss(%rip)
  leaq bootstacktop(%rip),%rsp
  pushq intr_ss(%rip)
  pushq intr_rsp_reg(%rip)
  pushq intr_rflags(%rip)
  pushq intr_cs(%rip)
  pushq intr_ret_rip(%rip)
  pushq $0x0
  pushq $(IRQ_OFFSET + IRQ_CLOCK)
  pushq $0x0 // %ds
  pushq $0x0 // %es

  pushq %rax
  pushq %rbx
  pushq %rcx
  pushq %rdx
  pushq %rbp
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

  xorl %ebp, %ebp
  movq %rsp,%rdi
  call trap
  jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK)
// LAB 8: Your code here.

#endif
