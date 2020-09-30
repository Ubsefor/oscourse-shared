
obj/prog//test1:     file format elf64-x86-64


Disassembly of section .text:

0000000001000000 <_start>:

  // If not, push dummy argc/argv arguments.
  // This happens when we are loaded by the kernel,
  // because the kernel does not know about passing arguments.
  // Marking argc and argv as zero.
  pushq $0
 1000000:	6a 00                	pushq  $0x0
  pushq $0
 1000002:	6a 00                	pushq  $0x0

0000000001000004 <args_exist>:

args_exist:
  movq 8(%rsp), %rsi
 1000004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
  movq (%rsp), %rdi
 1000009:	48 8b 3c 24          	mov    (%rsp),%rdi
  movq $0, %rbp
 100000d:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  call libmain
 1000014:	e8 32 00 00 00       	callq  100004b <libmain>
1:
  jmp 1b
 1000019:	eb fe                	jmp    1000019 <args_exist+0x15>

000000000100001b <umain>:
#include <inc/lib.h>

void (*volatile sys_yield)(void);

void
umain(int argc, char **argv) {
 100001b:	55                   	push   %rbp
 100001c:	48 89 e5             	mov    %rsp,%rbp
 100001f:	41 54                	push   %r12
 1000021:	53                   	push   %rbx
 1000022:	bb 03 00 00 00       	mov    $0x3,%ebx
  int i, j;

  for (j = 0; j < 3; ++j) {
    for (i = 0; i < 10000; ++i) {
    }
    sys_yield();
 1000027:	49 bc 08 10 00 01 00 	movabs $0x1001008,%r12
 100002e:	00 00 00 
umain(int argc, char **argv) {
 1000031:	b8 10 27 00 00       	mov    $0x2710,%eax
    for (i = 0; i < 10000; ++i) {
 1000036:	83 e8 01             	sub    $0x1,%eax
 1000039:	75 fb                	jne    1000036 <umain+0x1b>
    sys_yield();
 100003b:	49 8b 04 24          	mov    (%r12),%rax
 100003f:	ff d0                	callq  *%rax
  for (j = 0; j < 3; ++j) {
 1000041:	83 eb 01             	sub    $0x1,%ebx
 1000044:	75 eb                	jne    1000031 <umain+0x16>
  }
}
 1000046:	5b                   	pop    %rbx
 1000047:	41 5c                	pop    %r12
 1000049:	5d                   	pop    %rbp
 100004a:	c3                   	retq   

000000000100004b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 100004b:	55                   	push   %rbp
 100004c:	48 89 e5             	mov    %rsp,%rbp
  thisenv = 0;
 100004f:	48 b8 10 10 00 01 00 	movabs $0x1001010,%rax
 1000056:	00 00 00 
 1000059:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // save the name of the program so that panic() can use it
  if (argc > 0)
 1000060:	85 ff                	test   %edi,%edi
 1000062:	7e 0d                	jle    1000071 <libmain+0x26>
    binaryname = argv[0];
 1000064:	48 8b 06             	mov    (%rsi),%rax
 1000067:	48 a3 00 10 00 01 00 	movabs %rax,0x1001000
 100006e:	00 00 00 

  // call user main routine
  umain(argc, argv);
 1000071:	48 b8 1b 00 00 01 00 	movabs $0x100001b,%rax
 1000078:	00 00 00 
 100007b:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
 100007d:	48 a1 18 10 00 01 00 	movabs 0x1001018,%rax
 1000084:	00 00 00 
 1000087:	ff d0                	callq  *%rax
#endif
}
 1000089:	5d                   	pop    %rbp
 100008a:	c3                   	retq   
