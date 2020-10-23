#include <inc/mmu.h>
#include <inc/memlayout.h>

.data
// Define the global symbols 'envs', 'pages', 'uvpt', 'uvpd', 'uvpde' and 'uvpml4e'
// so that they can be used in C as if they were ordinary global arrays.
  .globl envs
  .set envs, UENVS
  .globl pages
  .set pages, UPAGES
  .globl uvpt
  .set uvpt, UVPT
  .globl uvpd
  .set   uvpd, uvpt+UVPTSIZE
  .globl  uvpde
  .set    uvpde,uvpd+UVPDSIZE
  .globl  uvpml4e
  .set    uvpml4e,uvpde+UVPDESIZE


// Entrypoint - this is where the kernel (or our parent environment)
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
  // See if we were started with arguments on the stack
#ifndef CONFIG_KSPACE
  movabs $USTACKTOP, %rax
  cmpq %rax,%rsp
  jne args_exist
#endif

  // If not, push dummy argc/argv arguments.
  // This happens when we are loaded by the kernel,
  // because the kernel does not know about passing arguments.
  // Marking argc and argv as zero.
  pushq $0
  pushq $0

args_exist:
  movq 8(%rsp), %rsi
  movq (%rsp), %rdi
  movq $0, %rbp
  call libmain
1:
  jmp 1b
