
obj/prog//test3:     file format elf64-x86-64


Disassembly of section .text:

0000000001020000 <_start>:

  // If not, push dummy argc/argv arguments.
  // This happens when we are loaded by the kernel,
  // because the kernel does not know about passing arguments.
  // Marking argc and argv as zero.
  pushq $0
 1020000:	6a 00                	pushq  $0x0
  pushq $0
 1020002:	6a 00                	pushq  $0x0

0000000001020004 <args_exist>:

args_exist:
  movq 8(%rsp), %rsi
 1020004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
  movq (%rsp), %rdi
 1020009:	48 8b 3c 24          	mov    (%rsp),%rdi
  movq $0, %rbp
 102000d:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  call libmain
 1020014:	e8 32 00 00 00       	callq  102004b <libmain>
1:
  jmp 1b
 1020019:	eb fe                	jmp    1020019 <args_exist+0x15>

000000000102001b <umain>:
#include <inc/lib.h>

void (*volatile sys_yield)(void);

void
umain(int argc, char **argv) {
 102001b:	55                   	push   %rbp
 102001c:	48 89 e5             	mov    %rsp,%rbp
 102001f:	41 54                	push   %r12
 1020021:	53                   	push   %rbx
 1020022:	bb 03 00 00 00       	mov    $0x3,%ebx
  int i, j;

  for (j = 0; j < 3; ++j) {
    for (i = 0; i < 10000; ++i) {
    }
    sys_yield();
 1020027:	49 bc 08 10 02 01 00 	movabs $0x1021008,%r12
 102002e:	00 00 00 
umain(int argc, char **argv) {
 1020031:	b8 10 27 00 00       	mov    $0x2710,%eax
    for (i = 0; i < 10000; ++i) {
 1020036:	83 e8 01             	sub    $0x1,%eax
 1020039:	75 fb                	jne    1020036 <umain+0x1b>
    sys_yield();
 102003b:	49 8b 04 24          	mov    (%r12),%rax
 102003f:	ff d0                	callq  *%rax
  for (j = 0; j < 3; ++j) {
 1020041:	83 eb 01             	sub    $0x1,%ebx
 1020044:	75 eb                	jne    1020031 <umain+0x16>
  }
}
 1020046:	5b                   	pop    %rbx
 1020047:	41 5c                	pop    %r12
 1020049:	5d                   	pop    %rbp
 102004a:	c3                   	retq   

000000000102004b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 102004b:	55                   	push   %rbp
 102004c:	48 89 e5             	mov    %rsp,%rbp
  thisenv = 0;
 102004f:	48 b8 10 10 02 01 00 	movabs $0x1021010,%rax
 1020056:	00 00 00 
 1020059:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // save the name of the program so that panic() can use it
  if (argc > 0)
 1020060:	85 ff                	test   %edi,%edi
 1020062:	7e 0d                	jle    1020071 <libmain+0x26>
    binaryname = argv[0];
 1020064:	48 8b 06             	mov    (%rsi),%rax
 1020067:	48 a3 00 10 02 01 00 	movabs %rax,0x1021000
 102006e:	00 00 00 

  // call user main routine
  umain(argc, argv);
 1020071:	48 b8 1b 00 02 01 00 	movabs $0x102001b,%rax
 1020078:	00 00 00 
 102007b:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
 102007d:	48 a1 18 10 02 01 00 	movabs 0x1021018,%rax
 1020084:	00 00 00 
 1020087:	ff d0                	callq  *%rax
#endif
}
 1020089:	5d                   	pop    %rbp
 102008a:	c3                   	retq   
