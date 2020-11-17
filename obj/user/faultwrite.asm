
obj/user/faultwrite:     file format elf64-x86-64


Disassembly of section .text:

0000000000800000 <__text_start>:
.text
.globl _start
_start:
  // See if we were started with arguments on the stack
#ifndef CONFIG_KSPACE
  movabs $USTACKTOP, %rax
  800000:	48 b8 00 b0 ff ff 7f 	movabs $0x7fffffb000,%rax
  800007:	00 00 00 
  cmpq %rax,%rsp
  80000a:	48 39 c4             	cmp    %rax,%rsp
  jne args_exist
  80000d:	75 04                	jne    800013 <args_exist>

  // If not, push dummy argc/argv arguments.
  // This happens when we are loaded by the kernel,
  // because the kernel does not know about passing arguments.
  // Marking argc and argv as zero.
  pushq $0
  80000f:	6a 00                	pushq  $0x0
  pushq $0
  800011:	6a 00                	pushq  $0x0

0000000000800013 <args_exist>:

args_exist:
  movq 8(%rsp), %rsi
  800013:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
  movq (%rsp), %rdi
  800018:	48 8b 3c 24          	mov    (%rsp),%rdi
  movq $0, %rbp
  80001c:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  call libmain
  800023:	e8 0e 00 00 00       	callq  800036 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  *(volatile unsigned *)0 = 0;
  80002a:	c7 04 25 00 00 00 00 	movl   $0x0,0x0
  800031:	00 00 00 00 
}
  800035:	c3                   	retq   

0000000000800036 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800036:	55                   	push   %rbp
  800037:	48 89 e5             	mov    %rsp,%rbp
  80003a:	41 56                	push   %r14
  80003c:	41 55                	push   %r13
  80003e:	41 54                	push   %r12
  800040:	53                   	push   %rbx
  800041:	41 89 fd             	mov    %edi,%r13d
  800044:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800047:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80004e:	00 00 00 
  800051:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800058:	00 00 00 
  80005b:	48 39 c2             	cmp    %rax,%rdx
  80005e:	73 23                	jae    800083 <libmain+0x4d>
  800060:	48 89 d3             	mov    %rdx,%rbx
  800063:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800067:	48 29 d0             	sub    %rdx,%rax
  80006a:	48 c1 e8 03          	shr    $0x3,%rax
  80006e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800073:	b8 00 00 00 00       	mov    $0x0,%eax
  800078:	ff 13                	callq  *(%rbx)
    ctor++;
  80007a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80007e:	4c 39 e3             	cmp    %r12,%rbx
  800081:	75 f0                	jne    800073 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  800083:	48 b8 a5 01 80 00 00 	movabs $0x8001a5,%rax
  80008a:	00 00 00 
  80008d:	ff d0                	callq  *%rax
  80008f:	83 e0 1f             	and    $0x1f,%eax
  800092:	48 89 c2             	mov    %rax,%rdx
  800095:	48 c1 e2 05          	shl    $0x5,%rdx
  800099:	48 29 c2             	sub    %rax,%rdx
  80009c:	48 89 d0             	mov    %rdx,%rax
  80009f:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000a6:	00 00 00 
  8000a9:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000ad:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000b4:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000b7:	45 85 ed             	test   %r13d,%r13d
  8000ba:	7e 0d                	jle    8000c9 <libmain+0x93>
    binaryname = argv[0];
  8000bc:	49 8b 06             	mov    (%r14),%rax
  8000bf:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000c6:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000c9:	4c 89 f6             	mov    %r14,%rsi
  8000cc:	44 89 ef             	mov    %r13d,%edi
  8000cf:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000d6:	00 00 00 
  8000d9:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000db:	48 b8 f0 00 80 00 00 	movabs $0x8000f0,%rax
  8000e2:	00 00 00 
  8000e5:	ff d0                	callq  *%rax
#endif
}
  8000e7:	5b                   	pop    %rbx
  8000e8:	41 5c                	pop    %r12
  8000ea:	41 5d                	pop    %r13
  8000ec:	41 5e                	pop    %r14
  8000ee:	5d                   	pop    %rbp
  8000ef:	c3                   	retq   

00000000008000f0 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000f0:	55                   	push   %rbp
  8000f1:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f9:	48 b8 45 01 80 00 00 	movabs $0x800145,%rax
  800100:	00 00 00 
  800103:	ff d0                	callq  *%rax
}
  800105:	5d                   	pop    %rbp
  800106:	c3                   	retq   

0000000000800107 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800107:	55                   	push   %rbp
  800108:	48 89 e5             	mov    %rsp,%rbp
  80010b:	53                   	push   %rbx
  80010c:	48 89 fa             	mov    %rdi,%rdx
  80010f:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800112:	b8 00 00 00 00       	mov    $0x0,%eax
  800117:	48 89 c3             	mov    %rax,%rbx
  80011a:	48 89 c7             	mov    %rax,%rdi
  80011d:	48 89 c6             	mov    %rax,%rsi
  800120:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800122:	5b                   	pop    %rbx
  800123:	5d                   	pop    %rbp
  800124:	c3                   	retq   

0000000000800125 <sys_cgetc>:

int
sys_cgetc(void) {
  800125:	55                   	push   %rbp
  800126:	48 89 e5             	mov    %rsp,%rbp
  800129:	53                   	push   %rbx
  asm volatile("int %1\n"
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	b8 01 00 00 00       	mov    $0x1,%eax
  800134:	48 89 ca             	mov    %rcx,%rdx
  800137:	48 89 cb             	mov    %rcx,%rbx
  80013a:	48 89 cf             	mov    %rcx,%rdi
  80013d:	48 89 ce             	mov    %rcx,%rsi
  800140:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %rbx
  800143:	5d                   	pop    %rbp
  800144:	c3                   	retq   

0000000000800145 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800145:	55                   	push   %rbp
  800146:	48 89 e5             	mov    %rsp,%rbp
  800149:	53                   	push   %rbx
  80014a:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800151:	be 00 00 00 00       	mov    $0x0,%esi
  800156:	b8 03 00 00 00       	mov    $0x3,%eax
  80015b:	48 89 f1             	mov    %rsi,%rcx
  80015e:	48 89 f3             	mov    %rsi,%rbx
  800161:	48 89 f7             	mov    %rsi,%rdi
  800164:	cd 30                	int    $0x30
  if (check && ret > 0)
  800166:	48 85 c0             	test   %rax,%rax
  800169:	7f 07                	jg     800172 <sys_env_destroy+0x2d>
}
  80016b:	48 83 c4 08          	add    $0x8,%rsp
  80016f:	5b                   	pop    %rbx
  800170:	5d                   	pop    %rbp
  800171:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800172:	49 89 c0             	mov    %rax,%r8
  800175:	b9 03 00 00 00       	mov    $0x3,%ecx
  80017a:	48 ba 70 11 80 00 00 	movabs $0x801170,%rdx
  800181:	00 00 00 
  800184:	be 22 00 00 00       	mov    $0x22,%esi
  800189:	48 bf 8f 11 80 00 00 	movabs $0x80118f,%rdi
  800190:	00 00 00 
  800193:	b8 00 00 00 00       	mov    $0x0,%eax
  800198:	49 b9 c5 01 80 00 00 	movabs $0x8001c5,%r9
  80019f:	00 00 00 
  8001a2:	41 ff d1             	callq  *%r9

00000000008001a5 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001a5:	55                   	push   %rbp
  8001a6:	48 89 e5             	mov    %rsp,%rbp
  8001a9:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001af:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b4:	48 89 ca             	mov    %rcx,%rdx
  8001b7:	48 89 cb             	mov    %rcx,%rbx
  8001ba:	48 89 cf             	mov    %rcx,%rdi
  8001bd:	48 89 ce             	mov    %rcx,%rsi
  8001c0:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001c2:	5b                   	pop    %rbx
  8001c3:	5d                   	pop    %rbp
  8001c4:	c3                   	retq   

00000000008001c5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001c5:	55                   	push   %rbp
  8001c6:	48 89 e5             	mov    %rsp,%rbp
  8001c9:	41 56                	push   %r14
  8001cb:	41 55                	push   %r13
  8001cd:	41 54                	push   %r12
  8001cf:	53                   	push   %rbx
  8001d0:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001d7:	49 89 fd             	mov    %rdi,%r13
  8001da:	41 89 f6             	mov    %esi,%r14d
  8001dd:	49 89 d4             	mov    %rdx,%r12
  8001e0:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001e7:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001ee:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001f5:	84 c0                	test   %al,%al
  8001f7:	74 26                	je     80021f <_panic+0x5a>
  8001f9:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800200:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800207:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80020b:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80020f:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800213:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800217:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80021b:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80021f:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800226:	00 00 00 
  800229:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800230:	00 00 00 
  800233:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800237:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80023e:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800245:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800253:	00 00 00 
  800256:	48 8b 18             	mov    (%rax),%rbx
  800259:	48 b8 a5 01 80 00 00 	movabs $0x8001a5,%rax
  800260:	00 00 00 
  800263:	ff d0                	callq  *%rax
  800265:	45 89 f0             	mov    %r14d,%r8d
  800268:	4c 89 e9             	mov    %r13,%rcx
  80026b:	48 89 da             	mov    %rbx,%rdx
  80026e:	89 c6                	mov    %eax,%esi
  800270:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  800277:	00 00 00 
  80027a:	b8 00 00 00 00       	mov    $0x0,%eax
  80027f:	48 bb 67 03 80 00 00 	movabs $0x800367,%rbx
  800286:	00 00 00 
  800289:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80028b:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800292:	4c 89 e7             	mov    %r12,%rdi
  800295:	48 b8 ff 02 80 00 00 	movabs $0x8002ff,%rax
  80029c:	00 00 00 
  80029f:	ff d0                	callq  *%rax
  cprintf("\n");
  8002a1:	48 bf c8 11 80 00 00 	movabs $0x8011c8,%rdi
  8002a8:	00 00 00 
  8002ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b0:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002b2:	cc                   	int3   
  while (1)
  8002b3:	eb fd                	jmp    8002b2 <_panic+0xed>

00000000008002b5 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002b5:	55                   	push   %rbp
  8002b6:	48 89 e5             	mov    %rsp,%rbp
  8002b9:	53                   	push   %rbx
  8002ba:	48 83 ec 08          	sub    $0x8,%rsp
  8002be:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002c1:	8b 06                	mov    (%rsi),%eax
  8002c3:	8d 50 01             	lea    0x1(%rax),%edx
  8002c6:	89 16                	mov    %edx,(%rsi)
  8002c8:	48 98                	cltq   
  8002ca:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002cf:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002d5:	74 0b                	je     8002e2 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002d7:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002db:	48 83 c4 08          	add    $0x8,%rsp
  8002df:	5b                   	pop    %rbx
  8002e0:	5d                   	pop    %rbp
  8002e1:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002e2:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002e6:	be ff 00 00 00       	mov    $0xff,%esi
  8002eb:	48 b8 07 01 80 00 00 	movabs $0x800107,%rax
  8002f2:	00 00 00 
  8002f5:	ff d0                	callq  *%rax
    b->idx = 0;
  8002f7:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002fd:	eb d8                	jmp    8002d7 <putch+0x22>

00000000008002ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002ff:	55                   	push   %rbp
  800300:	48 89 e5             	mov    %rsp,%rbp
  800303:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80030a:	48 89 fa             	mov    %rdi,%rdx
  80030d:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800310:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800317:	00 00 00 
  b.cnt = 0;
  80031a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800321:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800324:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80032b:	48 bf b5 02 80 00 00 	movabs $0x8002b5,%rdi
  800332:	00 00 00 
  800335:	48 b8 25 05 80 00 00 	movabs $0x800525,%rax
  80033c:	00 00 00 
  80033f:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800341:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800348:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80034f:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800353:	48 b8 07 01 80 00 00 	movabs $0x800107,%rax
  80035a:	00 00 00 
  80035d:	ff d0                	callq  *%rax

  return b.cnt;
}
  80035f:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800365:	c9                   	leaveq 
  800366:	c3                   	retq   

0000000000800367 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800367:	55                   	push   %rbp
  800368:	48 89 e5             	mov    %rsp,%rbp
  80036b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800372:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800379:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800380:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800387:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80038e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800395:	84 c0                	test   %al,%al
  800397:	74 20                	je     8003b9 <cprintf+0x52>
  800399:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80039d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003a1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003a5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003a9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003ad:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003b1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003b5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003b9:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003c0:	00 00 00 
  8003c3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003ca:	00 00 00 
  8003cd:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003d1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003d8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003df:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003e6:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003ed:	48 b8 ff 02 80 00 00 	movabs $0x8002ff,%rax
  8003f4:	00 00 00 
  8003f7:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003f9:	c9                   	leaveq 
  8003fa:	c3                   	retq   

00000000008003fb <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003fb:	55                   	push   %rbp
  8003fc:	48 89 e5             	mov    %rsp,%rbp
  8003ff:	41 57                	push   %r15
  800401:	41 56                	push   %r14
  800403:	41 55                	push   %r13
  800405:	41 54                	push   %r12
  800407:	53                   	push   %rbx
  800408:	48 83 ec 18          	sub    $0x18,%rsp
  80040c:	49 89 fc             	mov    %rdi,%r12
  80040f:	49 89 f5             	mov    %rsi,%r13
  800412:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800416:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800419:	41 89 cf             	mov    %ecx,%r15d
  80041c:	49 39 d7             	cmp    %rdx,%r15
  80041f:	76 45                	jbe    800466 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800421:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800425:	85 db                	test   %ebx,%ebx
  800427:	7e 0e                	jle    800437 <printnum+0x3c>
      putch(padc, putdat);
  800429:	4c 89 ee             	mov    %r13,%rsi
  80042c:	44 89 f7             	mov    %r14d,%edi
  80042f:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800432:	83 eb 01             	sub    $0x1,%ebx
  800435:	75 f2                	jne    800429 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800437:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	49 f7 f7             	div    %r15
  800443:	48 b8 ca 11 80 00 00 	movabs $0x8011ca,%rax
  80044a:	00 00 00 
  80044d:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800451:	4c 89 ee             	mov    %r13,%rsi
  800454:	41 ff d4             	callq  *%r12
}
  800457:	48 83 c4 18          	add    $0x18,%rsp
  80045b:	5b                   	pop    %rbx
  80045c:	41 5c                	pop    %r12
  80045e:	41 5d                	pop    %r13
  800460:	41 5e                	pop    %r14
  800462:	41 5f                	pop    %r15
  800464:	5d                   	pop    %rbp
  800465:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800466:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80046a:	ba 00 00 00 00       	mov    $0x0,%edx
  80046f:	49 f7 f7             	div    %r15
  800472:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800476:	48 89 c2             	mov    %rax,%rdx
  800479:	48 b8 fb 03 80 00 00 	movabs $0x8003fb,%rax
  800480:	00 00 00 
  800483:	ff d0                	callq  *%rax
  800485:	eb b0                	jmp    800437 <printnum+0x3c>

0000000000800487 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800487:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80048b:	48 8b 06             	mov    (%rsi),%rax
  80048e:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800492:	73 0a                	jae    80049e <sprintputch+0x17>
    *b->buf++ = ch;
  800494:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800498:	48 89 16             	mov    %rdx,(%rsi)
  80049b:	40 88 38             	mov    %dil,(%rax)
}
  80049e:	c3                   	retq   

000000000080049f <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80049f:	55                   	push   %rbp
  8004a0:	48 89 e5             	mov    %rsp,%rbp
  8004a3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004aa:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004b1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004b8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004bf:	84 c0                	test   %al,%al
  8004c1:	74 20                	je     8004e3 <printfmt+0x44>
  8004c3:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004c7:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004cb:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004cf:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004d3:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004d7:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004db:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004df:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004e3:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004ea:	00 00 00 
  8004ed:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004f4:	00 00 00 
  8004f7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004fb:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800502:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800509:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800510:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800517:	48 b8 25 05 80 00 00 	movabs $0x800525,%rax
  80051e:	00 00 00 
  800521:	ff d0                	callq  *%rax
}
  800523:	c9                   	leaveq 
  800524:	c3                   	retq   

0000000000800525 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800525:	55                   	push   %rbp
  800526:	48 89 e5             	mov    %rsp,%rbp
  800529:	41 57                	push   %r15
  80052b:	41 56                	push   %r14
  80052d:	41 55                	push   %r13
  80052f:	41 54                	push   %r12
  800531:	53                   	push   %rbx
  800532:	48 83 ec 48          	sub    $0x48,%rsp
  800536:	49 89 fd             	mov    %rdi,%r13
  800539:	49 89 f7             	mov    %rsi,%r15
  80053c:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80053f:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800543:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800547:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80054b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80054f:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800553:	41 0f b6 3e          	movzbl (%r14),%edi
  800557:	83 ff 25             	cmp    $0x25,%edi
  80055a:	74 18                	je     800574 <vprintfmt+0x4f>
      if (ch == '\0')
  80055c:	85 ff                	test   %edi,%edi
  80055e:	0f 84 8c 06 00 00    	je     800bf0 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800564:	4c 89 fe             	mov    %r15,%rsi
  800567:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80056a:	49 89 de             	mov    %rbx,%r14
  80056d:	eb e0                	jmp    80054f <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80056f:	49 89 de             	mov    %rbx,%r14
  800572:	eb db                	jmp    80054f <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800574:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800578:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80057c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800583:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800589:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800592:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800598:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80059e:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005a3:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005a8:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005ac:	0f b6 13             	movzbl (%rbx),%edx
  8005af:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005b2:	3c 55                	cmp    $0x55,%al
  8005b4:	0f 87 8b 05 00 00    	ja     800b45 <vprintfmt+0x620>
  8005ba:	0f b6 c0             	movzbl %al,%eax
  8005bd:	49 bb 80 12 80 00 00 	movabs $0x801280,%r11
  8005c4:	00 00 00 
  8005c7:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005cb:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005ce:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005d2:	eb d4                	jmp    8005a8 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005d4:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005d7:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005db:	eb cb                	jmp    8005a8 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005dd:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005e0:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005e4:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005e8:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005eb:	83 fa 09             	cmp    $0x9,%edx
  8005ee:	77 7e                	ja     80066e <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005f0:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005f4:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005f8:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005fd:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800601:	8d 50 d0             	lea    -0x30(%rax),%edx
  800604:	83 fa 09             	cmp    $0x9,%edx
  800607:	76 e7                	jbe    8005f0 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800609:	4c 89 f3             	mov    %r14,%rbx
  80060c:	eb 19                	jmp    800627 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80060e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800611:	83 f8 2f             	cmp    $0x2f,%eax
  800614:	77 2a                	ja     800640 <vprintfmt+0x11b>
  800616:	89 c2                	mov    %eax,%edx
  800618:	4c 01 d2             	add    %r10,%rdx
  80061b:	83 c0 08             	add    $0x8,%eax
  80061e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800621:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800624:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800627:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80062b:	0f 89 77 ff ff ff    	jns    8005a8 <vprintfmt+0x83>
          width = precision, precision = -1;
  800631:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800635:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80063b:	e9 68 ff ff ff       	jmpq   8005a8 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800640:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800644:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800648:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80064c:	eb d3                	jmp    800621 <vprintfmt+0xfc>
        if (width < 0)
  80064e:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800651:	85 c0                	test   %eax,%eax
  800653:	41 0f 48 c0          	cmovs  %r8d,%eax
  800657:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80065a:	4c 89 f3             	mov    %r14,%rbx
  80065d:	e9 46 ff ff ff       	jmpq   8005a8 <vprintfmt+0x83>
  800662:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800665:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800669:	e9 3a ff ff ff       	jmpq   8005a8 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80066e:	4c 89 f3             	mov    %r14,%rbx
  800671:	eb b4                	jmp    800627 <vprintfmt+0x102>
        lflag++;
  800673:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800676:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800679:	e9 2a ff ff ff       	jmpq   8005a8 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80067e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800681:	83 f8 2f             	cmp    $0x2f,%eax
  800684:	77 19                	ja     80069f <vprintfmt+0x17a>
  800686:	89 c2                	mov    %eax,%edx
  800688:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80068c:	83 c0 08             	add    $0x8,%eax
  80068f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800692:	4c 89 fe             	mov    %r15,%rsi
  800695:	8b 3a                	mov    (%rdx),%edi
  800697:	41 ff d5             	callq  *%r13
        break;
  80069a:	e9 b0 fe ff ff       	jmpq   80054f <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80069f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006a3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006a7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006ab:	eb e5                	jmp    800692 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006ad:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006b0:	83 f8 2f             	cmp    $0x2f,%eax
  8006b3:	77 5b                	ja     800710 <vprintfmt+0x1eb>
  8006b5:	89 c2                	mov    %eax,%edx
  8006b7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006bb:	83 c0 08             	add    $0x8,%eax
  8006be:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006c1:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006c3:	89 c8                	mov    %ecx,%eax
  8006c5:	c1 f8 1f             	sar    $0x1f,%eax
  8006c8:	31 c1                	xor    %eax,%ecx
  8006ca:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006cc:	83 f9 09             	cmp    $0x9,%ecx
  8006cf:	7f 4d                	jg     80071e <vprintfmt+0x1f9>
  8006d1:	48 63 c1             	movslq %ecx,%rax
  8006d4:	48 ba 40 15 80 00 00 	movabs $0x801540,%rdx
  8006db:	00 00 00 
  8006de:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006e2:	48 85 c0             	test   %rax,%rax
  8006e5:	74 37                	je     80071e <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006e7:	48 89 c1             	mov    %rax,%rcx
  8006ea:	48 ba eb 11 80 00 00 	movabs $0x8011eb,%rdx
  8006f1:	00 00 00 
  8006f4:	4c 89 fe             	mov    %r15,%rsi
  8006f7:	4c 89 ef             	mov    %r13,%rdi
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	48 bb 9f 04 80 00 00 	movabs $0x80049f,%rbx
  800706:	00 00 00 
  800709:	ff d3                	callq  *%rbx
  80070b:	e9 3f fe ff ff       	jmpq   80054f <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800710:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800714:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800718:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80071c:	eb a3                	jmp    8006c1 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80071e:	48 ba e2 11 80 00 00 	movabs $0x8011e2,%rdx
  800725:	00 00 00 
  800728:	4c 89 fe             	mov    %r15,%rsi
  80072b:	4c 89 ef             	mov    %r13,%rdi
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	48 bb 9f 04 80 00 00 	movabs $0x80049f,%rbx
  80073a:	00 00 00 
  80073d:	ff d3                	callq  *%rbx
  80073f:	e9 0b fe ff ff       	jmpq   80054f <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800744:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800747:	83 f8 2f             	cmp    $0x2f,%eax
  80074a:	77 4b                	ja     800797 <vprintfmt+0x272>
  80074c:	89 c2                	mov    %eax,%edx
  80074e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800752:	83 c0 08             	add    $0x8,%eax
  800755:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800758:	48 8b 02             	mov    (%rdx),%rax
  80075b:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80075f:	48 85 c0             	test   %rax,%rax
  800762:	0f 84 05 04 00 00    	je     800b6d <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800768:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80076c:	7e 06                	jle    800774 <vprintfmt+0x24f>
  80076e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800772:	75 31                	jne    8007a5 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800774:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800778:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80077c:	0f b6 00             	movzbl (%rax),%eax
  80077f:	0f be f8             	movsbl %al,%edi
  800782:	85 ff                	test   %edi,%edi
  800784:	0f 84 c3 00 00 00    	je     80084d <vprintfmt+0x328>
  80078a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80078e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800792:	e9 85 00 00 00       	jmpq   80081c <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800797:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80079b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80079f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007a3:	eb b3                	jmp    800758 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007a5:	49 63 f4             	movslq %r12d,%rsi
  8007a8:	48 89 c7             	mov    %rax,%rdi
  8007ab:	48 b8 fc 0c 80 00 00 	movabs $0x800cfc,%rax
  8007b2:	00 00 00 
  8007b5:	ff d0                	callq  *%rax
  8007b7:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007ba:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007bd:	85 f6                	test   %esi,%esi
  8007bf:	7e 22                	jle    8007e3 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007c1:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007c5:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007c9:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007cd:	4c 89 fe             	mov    %r15,%rsi
  8007d0:	89 df                	mov    %ebx,%edi
  8007d2:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007d5:	41 83 ec 01          	sub    $0x1,%r12d
  8007d9:	75 f2                	jne    8007cd <vprintfmt+0x2a8>
  8007db:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007df:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007e7:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007eb:	0f b6 00             	movzbl (%rax),%eax
  8007ee:	0f be f8             	movsbl %al,%edi
  8007f1:	85 ff                	test   %edi,%edi
  8007f3:	0f 84 56 fd ff ff    	je     80054f <vprintfmt+0x2a>
  8007f9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007fd:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800801:	eb 19                	jmp    80081c <vprintfmt+0x2f7>
            putch(ch, putdat);
  800803:	4c 89 fe             	mov    %r15,%rsi
  800806:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800809:	41 83 ee 01          	sub    $0x1,%r14d
  80080d:	48 83 c3 01          	add    $0x1,%rbx
  800811:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800815:	0f be f8             	movsbl %al,%edi
  800818:	85 ff                	test   %edi,%edi
  80081a:	74 29                	je     800845 <vprintfmt+0x320>
  80081c:	45 85 e4             	test   %r12d,%r12d
  80081f:	78 06                	js     800827 <vprintfmt+0x302>
  800821:	41 83 ec 01          	sub    $0x1,%r12d
  800825:	78 48                	js     80086f <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800827:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80082b:	74 d6                	je     800803 <vprintfmt+0x2de>
  80082d:	0f be c0             	movsbl %al,%eax
  800830:	83 e8 20             	sub    $0x20,%eax
  800833:	83 f8 5e             	cmp    $0x5e,%eax
  800836:	76 cb                	jbe    800803 <vprintfmt+0x2de>
            putch('?', putdat);
  800838:	4c 89 fe             	mov    %r15,%rsi
  80083b:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800840:	41 ff d5             	callq  *%r13
  800843:	eb c4                	jmp    800809 <vprintfmt+0x2e4>
  800845:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800849:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80084d:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800850:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800854:	0f 8e f5 fc ff ff    	jle    80054f <vprintfmt+0x2a>
          putch(' ', putdat);
  80085a:	4c 89 fe             	mov    %r15,%rsi
  80085d:	bf 20 00 00 00       	mov    $0x20,%edi
  800862:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800865:	83 eb 01             	sub    $0x1,%ebx
  800868:	75 f0                	jne    80085a <vprintfmt+0x335>
  80086a:	e9 e0 fc ff ff       	jmpq   80054f <vprintfmt+0x2a>
  80086f:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800873:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800877:	eb d4                	jmp    80084d <vprintfmt+0x328>
  if (lflag >= 2)
  800879:	83 f9 01             	cmp    $0x1,%ecx
  80087c:	7f 1d                	jg     80089b <vprintfmt+0x376>
  else if (lflag)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 5e                	je     8008e0 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800882:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800885:	83 f8 2f             	cmp    $0x2f,%eax
  800888:	77 48                	ja     8008d2 <vprintfmt+0x3ad>
  80088a:	89 c2                	mov    %eax,%edx
  80088c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800890:	83 c0 08             	add    $0x8,%eax
  800893:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800896:	48 8b 1a             	mov    (%rdx),%rbx
  800899:	eb 17                	jmp    8008b2 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80089b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089e:	83 f8 2f             	cmp    $0x2f,%eax
  8008a1:	77 21                	ja     8008c4 <vprintfmt+0x39f>
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a9:	83 c0 08             	add    $0x8,%eax
  8008ac:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008af:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008b2:	48 85 db             	test   %rbx,%rbx
  8008b5:	78 50                	js     800907 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008b7:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008bf:	e9 b4 01 00 00       	jmpq   800a78 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008c4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008cc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d0:	eb dd                	jmp    8008af <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008da:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008de:	eb b6                	jmp    800896 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008e0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008e3:	83 f8 2f             	cmp    $0x2f,%eax
  8008e6:	77 11                	ja     8008f9 <vprintfmt+0x3d4>
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ee:	83 c0 08             	add    $0x8,%eax
  8008f1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008f4:	48 63 1a             	movslq (%rdx),%rbx
  8008f7:	eb b9                	jmp    8008b2 <vprintfmt+0x38d>
  8008f9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008fd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800901:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800905:	eb ed                	jmp    8008f4 <vprintfmt+0x3cf>
          putch('-', putdat);
  800907:	4c 89 fe             	mov    %r15,%rsi
  80090a:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80090f:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800912:	48 89 da             	mov    %rbx,%rdx
  800915:	48 f7 da             	neg    %rdx
        base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80091d:	e9 56 01 00 00       	jmpq   800a78 <vprintfmt+0x553>
  if (lflag >= 2)
  800922:	83 f9 01             	cmp    $0x1,%ecx
  800925:	7f 25                	jg     80094c <vprintfmt+0x427>
  else if (lflag)
  800927:	85 c9                	test   %ecx,%ecx
  800929:	74 5e                	je     800989 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80092b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092e:	83 f8 2f             	cmp    $0x2f,%eax
  800931:	77 48                	ja     80097b <vprintfmt+0x456>
  800933:	89 c2                	mov    %eax,%edx
  800935:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800939:	83 c0 08             	add    $0x8,%eax
  80093c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093f:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800942:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800947:	e9 2c 01 00 00       	jmpq   800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80094c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094f:	83 f8 2f             	cmp    $0x2f,%eax
  800952:	77 19                	ja     80096d <vprintfmt+0x448>
  800954:	89 c2                	mov    %eax,%edx
  800956:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095a:	83 c0 08             	add    $0x8,%eax
  80095d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800960:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800963:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800968:	e9 0b 01 00 00       	jmpq   800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80096d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800971:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800975:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800979:	eb e5                	jmp    800960 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80097b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800983:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800987:	eb b6                	jmp    80093f <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800989:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80098c:	83 f8 2f             	cmp    $0x2f,%eax
  80098f:	77 18                	ja     8009a9 <vprintfmt+0x484>
  800991:	89 c2                	mov    %eax,%edx
  800993:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800997:	83 c0 08             	add    $0x8,%eax
  80099a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80099d:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80099f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009a4:	e9 cf 00 00 00       	jmpq   800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ad:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b5:	eb e6                	jmp    80099d <vprintfmt+0x478>
  if (lflag >= 2)
  8009b7:	83 f9 01             	cmp    $0x1,%ecx
  8009ba:	7f 25                	jg     8009e1 <vprintfmt+0x4bc>
  else if (lflag)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 5b                	je     800a1b <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009c0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c3:	83 f8 2f             	cmp    $0x2f,%eax
  8009c6:	77 45                	ja     800a0d <vprintfmt+0x4e8>
  8009c8:	89 c2                	mov    %eax,%edx
  8009ca:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ce:	83 c0 08             	add    $0x8,%eax
  8009d1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d4:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009d7:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009dc:	e9 97 00 00 00       	jmpq   800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e4:	83 f8 2f             	cmp    $0x2f,%eax
  8009e7:	77 16                	ja     8009ff <vprintfmt+0x4da>
  8009e9:	89 c2                	mov    %eax,%edx
  8009eb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ef:	83 c0 08             	add    $0x8,%eax
  8009f2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f5:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009f8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009fd:	eb 79                	jmp    800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a03:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a0b:	eb e8                	jmp    8009f5 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a0d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a11:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a15:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a19:	eb b9                	jmp    8009d4 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a1b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a1e:	83 f8 2f             	cmp    $0x2f,%eax
  800a21:	77 15                	ja     800a38 <vprintfmt+0x513>
  800a23:	89 c2                	mov    %eax,%edx
  800a25:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a29:	83 c0 08             	add    $0x8,%eax
  800a2c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a2f:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a31:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a36:	eb 40                	jmp    800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a38:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a3c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a40:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a44:	eb e9                	jmp    800a2f <vprintfmt+0x50a>
        putch('0', putdat);
  800a46:	4c 89 fe             	mov    %r15,%rsi
  800a49:	bf 30 00 00 00       	mov    $0x30,%edi
  800a4e:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a51:	4c 89 fe             	mov    %r15,%rsi
  800a54:	bf 78 00 00 00       	mov    $0x78,%edi
  800a59:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a5c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a5f:	83 f8 2f             	cmp    $0x2f,%eax
  800a62:	77 34                	ja     800a98 <vprintfmt+0x573>
  800a64:	89 c2                	mov    %eax,%edx
  800a66:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a6a:	83 c0 08             	add    $0x8,%eax
  800a6d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a70:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a73:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a78:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a7d:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a81:	4c 89 fe             	mov    %r15,%rsi
  800a84:	4c 89 ef             	mov    %r13,%rdi
  800a87:	48 b8 fb 03 80 00 00 	movabs $0x8003fb,%rax
  800a8e:	00 00 00 
  800a91:	ff d0                	callq  *%rax
        break;
  800a93:	e9 b7 fa ff ff       	jmpq   80054f <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a98:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a9c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aa0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aa4:	eb ca                	jmp    800a70 <vprintfmt+0x54b>
  if (lflag >= 2)
  800aa6:	83 f9 01             	cmp    $0x1,%ecx
  800aa9:	7f 22                	jg     800acd <vprintfmt+0x5a8>
  else if (lflag)
  800aab:	85 c9                	test   %ecx,%ecx
  800aad:	74 58                	je     800b07 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800aaf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ab2:	83 f8 2f             	cmp    $0x2f,%eax
  800ab5:	77 42                	ja     800af9 <vprintfmt+0x5d4>
  800ab7:	89 c2                	mov    %eax,%edx
  800ab9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800abd:	83 c0 08             	add    $0x8,%eax
  800ac0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ac3:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ac6:	b9 10 00 00 00       	mov    $0x10,%ecx
  800acb:	eb ab                	jmp    800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800acd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ad0:	83 f8 2f             	cmp    $0x2f,%eax
  800ad3:	77 16                	ja     800aeb <vprintfmt+0x5c6>
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800adb:	83 c0 08             	add    $0x8,%eax
  800ade:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ae1:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ae4:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae9:	eb 8d                	jmp    800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800aeb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aef:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800af7:	eb e8                	jmp    800ae1 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800af9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800afd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b01:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b05:	eb bc                	jmp    800ac3 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b07:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b0a:	83 f8 2f             	cmp    $0x2f,%eax
  800b0d:	77 18                	ja     800b27 <vprintfmt+0x602>
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b15:	83 c0 08             	add    $0x8,%eax
  800b18:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b1b:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b1d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b22:	e9 51 ff ff ff       	jmpq   800a78 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b27:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b2b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b2f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b33:	eb e6                	jmp    800b1b <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b35:	4c 89 fe             	mov    %r15,%rsi
  800b38:	bf 25 00 00 00       	mov    $0x25,%edi
  800b3d:	41 ff d5             	callq  *%r13
        break;
  800b40:	e9 0a fa ff ff       	jmpq   80054f <vprintfmt+0x2a>
        putch('%', putdat);
  800b45:	4c 89 fe             	mov    %r15,%rsi
  800b48:	bf 25 00 00 00       	mov    $0x25,%edi
  800b4d:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b50:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b54:	0f 84 15 fa ff ff    	je     80056f <vprintfmt+0x4a>
  800b5a:	49 89 de             	mov    %rbx,%r14
  800b5d:	49 83 ee 01          	sub    $0x1,%r14
  800b61:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b66:	75 f5                	jne    800b5d <vprintfmt+0x638>
  800b68:	e9 e2 f9 ff ff       	jmpq   80054f <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b6d:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b71:	74 06                	je     800b79 <vprintfmt+0x654>
  800b73:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b77:	7f 21                	jg     800b9a <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b79:	bf 28 00 00 00       	mov    $0x28,%edi
  800b7e:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800b85:	00 00 00 
  800b88:	b8 28 00 00 00       	mov    $0x28,%eax
  800b8d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b91:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b95:	e9 82 fc ff ff       	jmpq   80081c <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b9a:	49 63 f4             	movslq %r12d,%rsi
  800b9d:	48 bf db 11 80 00 00 	movabs $0x8011db,%rdi
  800ba4:	00 00 00 
  800ba7:	48 b8 fc 0c 80 00 00 	movabs $0x800cfc,%rax
  800bae:	00 00 00 
  800bb1:	ff d0                	callq  *%rax
  800bb3:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bb6:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bb9:	48 be db 11 80 00 00 	movabs $0x8011db,%rsi
  800bc0:	00 00 00 
  800bc3:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	0f 8f f2 fb ff ff    	jg     8007c1 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bcf:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800bd6:	00 00 00 
  800bd9:	b8 28 00 00 00       	mov    $0x28,%eax
  800bde:	bf 28 00 00 00       	mov    $0x28,%edi
  800be3:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800be7:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800beb:	e9 2c fc ff ff       	jmpq   80081c <vprintfmt+0x2f7>
}
  800bf0:	48 83 c4 48          	add    $0x48,%rsp
  800bf4:	5b                   	pop    %rbx
  800bf5:	41 5c                	pop    %r12
  800bf7:	41 5d                	pop    %r13
  800bf9:	41 5e                	pop    %r14
  800bfb:	41 5f                	pop    %r15
  800bfd:	5d                   	pop    %rbp
  800bfe:	c3                   	retq   

0000000000800bff <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bff:	55                   	push   %rbp
  800c00:	48 89 e5             	mov    %rsp,%rbp
  800c03:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c07:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c0b:	48 63 c6             	movslq %esi,%rax
  800c0e:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c13:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c17:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c1e:	48 85 ff             	test   %rdi,%rdi
  800c21:	74 2a                	je     800c4d <vsnprintf+0x4e>
  800c23:	85 f6                	test   %esi,%esi
  800c25:	7e 26                	jle    800c4d <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c27:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c2b:	48 bf 87 04 80 00 00 	movabs $0x800487,%rdi
  800c32:	00 00 00 
  800c35:	48 b8 25 05 80 00 00 	movabs $0x800525,%rax
  800c3c:	00 00 00 
  800c3f:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c41:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c45:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c48:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c4b:	c9                   	leaveq 
  800c4c:	c3                   	retq   
    return -E_INVAL;
  800c4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c52:	eb f7                	jmp    800c4b <vsnprintf+0x4c>

0000000000800c54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c54:	55                   	push   %rbp
  800c55:	48 89 e5             	mov    %rsp,%rbp
  800c58:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c5f:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c66:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c6d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c74:	84 c0                	test   %al,%al
  800c76:	74 20                	je     800c98 <snprintf+0x44>
  800c78:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c7c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c80:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c84:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c88:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c8c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c90:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c94:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c98:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c9f:	00 00 00 
  800ca2:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ca9:	00 00 00 
  800cac:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cb0:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cb7:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cbe:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cc5:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800ccc:	48 b8 ff 0b 80 00 00 	movabs $0x800bff,%rax
  800cd3:	00 00 00 
  800cd6:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cd8:	c9                   	leaveq 
  800cd9:	c3                   	retq   

0000000000800cda <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cda:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cdd:	74 17                	je     800cf6 <strlen+0x1c>
  800cdf:	48 89 fa             	mov    %rdi,%rdx
  800ce2:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ce7:	29 f9                	sub    %edi,%ecx
    n++;
  800ce9:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cec:	48 83 c2 01          	add    $0x1,%rdx
  800cf0:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cf3:	75 f4                	jne    800ce9 <strlen+0xf>
  800cf5:	c3                   	retq   
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cfb:	c3                   	retq   

0000000000800cfc <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cfc:	48 85 f6             	test   %rsi,%rsi
  800cff:	74 24                	je     800d25 <strnlen+0x29>
  800d01:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d04:	74 25                	je     800d2b <strnlen+0x2f>
  800d06:	48 01 fe             	add    %rdi,%rsi
  800d09:	48 89 fa             	mov    %rdi,%rdx
  800d0c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d11:	29 f9                	sub    %edi,%ecx
    n++;
  800d13:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d16:	48 83 c2 01          	add    $0x1,%rdx
  800d1a:	48 39 f2             	cmp    %rsi,%rdx
  800d1d:	74 11                	je     800d30 <strnlen+0x34>
  800d1f:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d22:	75 ef                	jne    800d13 <strnlen+0x17>
  800d24:	c3                   	retq   
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2a:	c3                   	retq   
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d30:	c3                   	retq   

0000000000800d31 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d31:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d3d:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d40:	48 83 c2 01          	add    $0x1,%rdx
  800d44:	84 c9                	test   %cl,%cl
  800d46:	75 f1                	jne    800d39 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d48:	c3                   	retq   

0000000000800d49 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d49:	55                   	push   %rbp
  800d4a:	48 89 e5             	mov    %rsp,%rbp
  800d4d:	41 54                	push   %r12
  800d4f:	53                   	push   %rbx
  800d50:	48 89 fb             	mov    %rdi,%rbx
  800d53:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d56:	48 b8 da 0c 80 00 00 	movabs $0x800cda,%rax
  800d5d:	00 00 00 
  800d60:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d62:	48 63 f8             	movslq %eax,%rdi
  800d65:	48 01 df             	add    %rbx,%rdi
  800d68:	4c 89 e6             	mov    %r12,%rsi
  800d6b:	48 b8 31 0d 80 00 00 	movabs $0x800d31,%rax
  800d72:	00 00 00 
  800d75:	ff d0                	callq  *%rax
  return dst;
}
  800d77:	48 89 d8             	mov    %rbx,%rax
  800d7a:	5b                   	pop    %rbx
  800d7b:	41 5c                	pop    %r12
  800d7d:	5d                   	pop    %rbp
  800d7e:	c3                   	retq   

0000000000800d7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d7f:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d82:	48 85 d2             	test   %rdx,%rdx
  800d85:	74 1f                	je     800da6 <strncpy+0x27>
  800d87:	48 01 fa             	add    %rdi,%rdx
  800d8a:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d8d:	48 83 c1 01          	add    $0x1,%rcx
  800d91:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d95:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d99:	41 80 f8 01          	cmp    $0x1,%r8b
  800d9d:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800da1:	48 39 ca             	cmp    %rcx,%rdx
  800da4:	75 e7                	jne    800d8d <strncpy+0xe>
  }
  return ret;
}
  800da6:	c3                   	retq   

0000000000800da7 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800da7:	48 89 f8             	mov    %rdi,%rax
  800daa:	48 85 d2             	test   %rdx,%rdx
  800dad:	74 36                	je     800de5 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800daf:	48 83 fa 01          	cmp    $0x1,%rdx
  800db3:	74 2d                	je     800de2 <strlcpy+0x3b>
  800db5:	44 0f b6 06          	movzbl (%rsi),%r8d
  800db9:	45 84 c0             	test   %r8b,%r8b
  800dbc:	74 24                	je     800de2 <strlcpy+0x3b>
  800dbe:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dc2:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dc7:	48 83 c0 01          	add    $0x1,%rax
  800dcb:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800dcf:	48 39 d1             	cmp    %rdx,%rcx
  800dd2:	74 0e                	je     800de2 <strlcpy+0x3b>
  800dd4:	48 83 c1 01          	add    $0x1,%rcx
  800dd8:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800ddd:	45 84 c0             	test   %r8b,%r8b
  800de0:	75 e5                	jne    800dc7 <strlcpy+0x20>
    *dst = '\0';
  800de2:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800de5:	48 29 f8             	sub    %rdi,%rax
}
  800de8:	c3                   	retq   

0000000000800de9 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800de9:	0f b6 07             	movzbl (%rdi),%eax
  800dec:	84 c0                	test   %al,%al
  800dee:	74 17                	je     800e07 <strcmp+0x1e>
  800df0:	3a 06                	cmp    (%rsi),%al
  800df2:	75 13                	jne    800e07 <strcmp+0x1e>
    p++, q++;
  800df4:	48 83 c7 01          	add    $0x1,%rdi
  800df8:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dfc:	0f b6 07             	movzbl (%rdi),%eax
  800dff:	84 c0                	test   %al,%al
  800e01:	74 04                	je     800e07 <strcmp+0x1e>
  800e03:	3a 06                	cmp    (%rsi),%al
  800e05:	74 ed                	je     800df4 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e07:	0f b6 c0             	movzbl %al,%eax
  800e0a:	0f b6 16             	movzbl (%rsi),%edx
  800e0d:	29 d0                	sub    %edx,%eax
}
  800e0f:	c3                   	retq   

0000000000800e10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e10:	48 85 d2             	test   %rdx,%rdx
  800e13:	74 2f                	je     800e44 <strncmp+0x34>
  800e15:	0f b6 07             	movzbl (%rdi),%eax
  800e18:	84 c0                	test   %al,%al
  800e1a:	74 1f                	je     800e3b <strncmp+0x2b>
  800e1c:	3a 06                	cmp    (%rsi),%al
  800e1e:	75 1b                	jne    800e3b <strncmp+0x2b>
  800e20:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e23:	48 83 c7 01          	add    $0x1,%rdi
  800e27:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e2b:	48 39 d7             	cmp    %rdx,%rdi
  800e2e:	74 1a                	je     800e4a <strncmp+0x3a>
  800e30:	0f b6 07             	movzbl (%rdi),%eax
  800e33:	84 c0                	test   %al,%al
  800e35:	74 04                	je     800e3b <strncmp+0x2b>
  800e37:	3a 06                	cmp    (%rsi),%al
  800e39:	74 e8                	je     800e23 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e3b:	0f b6 07             	movzbl (%rdi),%eax
  800e3e:	0f b6 16             	movzbl (%rsi),%edx
  800e41:	29 d0                	sub    %edx,%eax
}
  800e43:	c3                   	retq   
    return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
  800e49:	c3                   	retq   
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4f:	c3                   	retq   

0000000000800e50 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e50:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e52:	0f b6 07             	movzbl (%rdi),%eax
  800e55:	84 c0                	test   %al,%al
  800e57:	74 1e                	je     800e77 <strchr+0x27>
    if (*s == c)
  800e59:	40 38 c6             	cmp    %al,%sil
  800e5c:	74 1f                	je     800e7d <strchr+0x2d>
  for (; *s; s++)
  800e5e:	48 83 c7 01          	add    $0x1,%rdi
  800e62:	0f b6 07             	movzbl (%rdi),%eax
  800e65:	84 c0                	test   %al,%al
  800e67:	74 08                	je     800e71 <strchr+0x21>
    if (*s == c)
  800e69:	38 d0                	cmp    %dl,%al
  800e6b:	75 f1                	jne    800e5e <strchr+0xe>
  for (; *s; s++)
  800e6d:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e70:	c3                   	retq   
  return 0;
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	c3                   	retq   
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	c3                   	retq   
    if (*s == c)
  800e7d:	48 89 f8             	mov    %rdi,%rax
  800e80:	c3                   	retq   

0000000000800e81 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e81:	48 89 f8             	mov    %rdi,%rax
  800e84:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e86:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e89:	40 38 f2             	cmp    %sil,%dl
  800e8c:	74 13                	je     800ea1 <strfind+0x20>
  800e8e:	84 d2                	test   %dl,%dl
  800e90:	74 0f                	je     800ea1 <strfind+0x20>
  for (; *s; s++)
  800e92:	48 83 c0 01          	add    $0x1,%rax
  800e96:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e99:	38 ca                	cmp    %cl,%dl
  800e9b:	74 04                	je     800ea1 <strfind+0x20>
  800e9d:	84 d2                	test   %dl,%dl
  800e9f:	75 f1                	jne    800e92 <strfind+0x11>
      break;
  return (char *)s;
}
  800ea1:	c3                   	retq   

0000000000800ea2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800ea2:	48 85 d2             	test   %rdx,%rdx
  800ea5:	74 3a                	je     800ee1 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ea7:	48 89 f8             	mov    %rdi,%rax
  800eaa:	48 09 d0             	or     %rdx,%rax
  800ead:	a8 03                	test   $0x3,%al
  800eaf:	75 28                	jne    800ed9 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800eb1:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800eb5:	89 f0                	mov    %esi,%eax
  800eb7:	c1 e0 08             	shl    $0x8,%eax
  800eba:	89 f1                	mov    %esi,%ecx
  800ebc:	c1 e1 18             	shl    $0x18,%ecx
  800ebf:	41 89 f0             	mov    %esi,%r8d
  800ec2:	41 c1 e0 10          	shl    $0x10,%r8d
  800ec6:	44 09 c1             	or     %r8d,%ecx
  800ec9:	09 ce                	or     %ecx,%esi
  800ecb:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ecd:	48 c1 ea 02          	shr    $0x2,%rdx
  800ed1:	48 89 d1             	mov    %rdx,%rcx
  800ed4:	fc                   	cld    
  800ed5:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ed7:	eb 08                	jmp    800ee1 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	48 89 d1             	mov    %rdx,%rcx
  800ede:	fc                   	cld    
  800edf:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ee1:	48 89 f8             	mov    %rdi,%rax
  800ee4:	c3                   	retq   

0000000000800ee5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ee5:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ee8:	48 39 fe             	cmp    %rdi,%rsi
  800eeb:	73 40                	jae    800f2d <memmove+0x48>
  800eed:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ef1:	48 39 f9             	cmp    %rdi,%rcx
  800ef4:	76 37                	jbe    800f2d <memmove+0x48>
    s += n;
    d += n;
  800ef6:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800efa:	48 89 fe             	mov    %rdi,%rsi
  800efd:	48 09 d6             	or     %rdx,%rsi
  800f00:	48 09 ce             	or     %rcx,%rsi
  800f03:	40 f6 c6 03          	test   $0x3,%sil
  800f07:	75 14                	jne    800f1d <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f09:	48 83 ef 04          	sub    $0x4,%rdi
  800f0d:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f11:	48 c1 ea 02          	shr    $0x2,%rdx
  800f15:	48 89 d1             	mov    %rdx,%rcx
  800f18:	fd                   	std    
  800f19:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f1b:	eb 0e                	jmp    800f2b <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f1d:	48 83 ef 01          	sub    $0x1,%rdi
  800f21:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f25:	48 89 d1             	mov    %rdx,%rcx
  800f28:	fd                   	std    
  800f29:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f2b:	fc                   	cld    
  800f2c:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f2d:	48 89 c1             	mov    %rax,%rcx
  800f30:	48 09 d1             	or     %rdx,%rcx
  800f33:	48 09 f1             	or     %rsi,%rcx
  800f36:	f6 c1 03             	test   $0x3,%cl
  800f39:	75 0e                	jne    800f49 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f3b:	48 c1 ea 02          	shr    $0x2,%rdx
  800f3f:	48 89 d1             	mov    %rdx,%rcx
  800f42:	48 89 c7             	mov    %rax,%rdi
  800f45:	fc                   	cld    
  800f46:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f48:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f49:	48 89 c7             	mov    %rax,%rdi
  800f4c:	48 89 d1             	mov    %rdx,%rcx
  800f4f:	fc                   	cld    
  800f50:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f52:	c3                   	retq   

0000000000800f53 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f53:	55                   	push   %rbp
  800f54:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f57:	48 b8 e5 0e 80 00 00 	movabs $0x800ee5,%rax
  800f5e:	00 00 00 
  800f61:	ff d0                	callq  *%rax
}
  800f63:	5d                   	pop    %rbp
  800f64:	c3                   	retq   

0000000000800f65 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f65:	55                   	push   %rbp
  800f66:	48 89 e5             	mov    %rsp,%rbp
  800f69:	41 57                	push   %r15
  800f6b:	41 56                	push   %r14
  800f6d:	41 55                	push   %r13
  800f6f:	41 54                	push   %r12
  800f71:	53                   	push   %rbx
  800f72:	48 83 ec 08          	sub    $0x8,%rsp
  800f76:	49 89 fe             	mov    %rdi,%r14
  800f79:	49 89 f7             	mov    %rsi,%r15
  800f7c:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f7f:	48 89 f7             	mov    %rsi,%rdi
  800f82:	48 b8 da 0c 80 00 00 	movabs $0x800cda,%rax
  800f89:	00 00 00 
  800f8c:	ff d0                	callq  *%rax
  800f8e:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f91:	4c 89 ee             	mov    %r13,%rsi
  800f94:	4c 89 f7             	mov    %r14,%rdi
  800f97:	48 b8 fc 0c 80 00 00 	movabs $0x800cfc,%rax
  800f9e:	00 00 00 
  800fa1:	ff d0                	callq  *%rax
  800fa3:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fa6:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800faa:	4d 39 e5             	cmp    %r12,%r13
  800fad:	74 26                	je     800fd5 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800faf:	4c 89 e8             	mov    %r13,%rax
  800fb2:	4c 29 e0             	sub    %r12,%rax
  800fb5:	48 39 d8             	cmp    %rbx,%rax
  800fb8:	76 2a                	jbe    800fe4 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fba:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fbe:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fc2:	4c 89 fe             	mov    %r15,%rsi
  800fc5:	48 b8 53 0f 80 00 00 	movabs $0x800f53,%rax
  800fcc:	00 00 00 
  800fcf:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fd1:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fd5:	48 83 c4 08          	add    $0x8,%rsp
  800fd9:	5b                   	pop    %rbx
  800fda:	41 5c                	pop    %r12
  800fdc:	41 5d                	pop    %r13
  800fde:	41 5e                	pop    %r14
  800fe0:	41 5f                	pop    %r15
  800fe2:	5d                   	pop    %rbp
  800fe3:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fe4:	49 83 ed 01          	sub    $0x1,%r13
  800fe8:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fec:	4c 89 ea             	mov    %r13,%rdx
  800fef:	4c 89 fe             	mov    %r15,%rsi
  800ff2:	48 b8 53 0f 80 00 00 	movabs $0x800f53,%rax
  800ff9:	00 00 00 
  800ffc:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800ffe:	4d 01 ee             	add    %r13,%r14
  801001:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801006:	eb c9                	jmp    800fd1 <strlcat+0x6c>

0000000000801008 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801008:	48 85 d2             	test   %rdx,%rdx
  80100b:	74 3a                	je     801047 <memcmp+0x3f>
    if (*s1 != *s2)
  80100d:	0f b6 0f             	movzbl (%rdi),%ecx
  801010:	44 0f b6 06          	movzbl (%rsi),%r8d
  801014:	44 38 c1             	cmp    %r8b,%cl
  801017:	75 1d                	jne    801036 <memcmp+0x2e>
  801019:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80101e:	48 39 d0             	cmp    %rdx,%rax
  801021:	74 1e                	je     801041 <memcmp+0x39>
    if (*s1 != *s2)
  801023:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801027:	48 83 c0 01          	add    $0x1,%rax
  80102b:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801031:	44 38 c1             	cmp    %r8b,%cl
  801034:	74 e8                	je     80101e <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801036:	0f b6 c1             	movzbl %cl,%eax
  801039:	45 0f b6 c0          	movzbl %r8b,%r8d
  80103d:	44 29 c0             	sub    %r8d,%eax
  801040:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801041:	b8 00 00 00 00       	mov    $0x0,%eax
  801046:	c3                   	retq   
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80104c:	c3                   	retq   

000000000080104d <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80104d:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801051:	48 39 c7             	cmp    %rax,%rdi
  801054:	73 19                	jae    80106f <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801056:	89 f2                	mov    %esi,%edx
  801058:	40 38 37             	cmp    %sil,(%rdi)
  80105b:	74 16                	je     801073 <memfind+0x26>
  for (; s < ends; s++)
  80105d:	48 83 c7 01          	add    $0x1,%rdi
  801061:	48 39 f8             	cmp    %rdi,%rax
  801064:	74 08                	je     80106e <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801066:	38 17                	cmp    %dl,(%rdi)
  801068:	75 f3                	jne    80105d <memfind+0x10>
  for (; s < ends; s++)
  80106a:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80106d:	c3                   	retq   
  80106e:	c3                   	retq   
  for (; s < ends; s++)
  80106f:	48 89 f8             	mov    %rdi,%rax
  801072:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801073:	48 89 f8             	mov    %rdi,%rax
  801076:	c3                   	retq   

0000000000801077 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801077:	0f b6 07             	movzbl (%rdi),%eax
  80107a:	3c 20                	cmp    $0x20,%al
  80107c:	74 04                	je     801082 <strtol+0xb>
  80107e:	3c 09                	cmp    $0x9,%al
  801080:	75 0f                	jne    801091 <strtol+0x1a>
    s++;
  801082:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801086:	0f b6 07             	movzbl (%rdi),%eax
  801089:	3c 20                	cmp    $0x20,%al
  80108b:	74 f5                	je     801082 <strtol+0xb>
  80108d:	3c 09                	cmp    $0x9,%al
  80108f:	74 f1                	je     801082 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801091:	3c 2b                	cmp    $0x2b,%al
  801093:	74 2b                	je     8010c0 <strtol+0x49>
  int neg  = 0;
  801095:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80109b:	3c 2d                	cmp    $0x2d,%al
  80109d:	74 2d                	je     8010cc <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80109f:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010a5:	75 0f                	jne    8010b6 <strtol+0x3f>
  8010a7:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010aa:	74 2c                	je     8010d8 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010ac:	85 d2                	test   %edx,%edx
  8010ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010b3:	0f 44 d0             	cmove  %eax,%edx
  8010b6:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010bb:	4c 63 d2             	movslq %edx,%r10
  8010be:	eb 5c                	jmp    80111c <strtol+0xa5>
    s++;
  8010c0:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010c4:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010ca:	eb d3                	jmp    80109f <strtol+0x28>
    s++, neg = 1;
  8010cc:	48 83 c7 01          	add    $0x1,%rdi
  8010d0:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010d6:	eb c7                	jmp    80109f <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010d8:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010dc:	74 0f                	je     8010ed <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010de:	85 d2                	test   %edx,%edx
  8010e0:	75 d4                	jne    8010b6 <strtol+0x3f>
    s++, base = 8;
  8010e2:	48 83 c7 01          	add    $0x1,%rdi
  8010e6:	ba 08 00 00 00       	mov    $0x8,%edx
  8010eb:	eb c9                	jmp    8010b6 <strtol+0x3f>
    s += 2, base = 16;
  8010ed:	48 83 c7 02          	add    $0x2,%rdi
  8010f1:	ba 10 00 00 00       	mov    $0x10,%edx
  8010f6:	eb be                	jmp    8010b6 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010f8:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010fc:	41 80 f8 19          	cmp    $0x19,%r8b
  801100:	77 2f                	ja     801131 <strtol+0xba>
      dig = *s - 'a' + 10;
  801102:	44 0f be c1          	movsbl %cl,%r8d
  801106:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80110a:	39 d1                	cmp    %edx,%ecx
  80110c:	7d 37                	jge    801145 <strtol+0xce>
    s++, val = (val * base) + dig;
  80110e:	48 83 c7 01          	add    $0x1,%rdi
  801112:	49 0f af c2          	imul   %r10,%rax
  801116:	48 63 c9             	movslq %ecx,%rcx
  801119:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80111c:	0f b6 0f             	movzbl (%rdi),%ecx
  80111f:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801123:	41 80 f8 09          	cmp    $0x9,%r8b
  801127:	77 cf                	ja     8010f8 <strtol+0x81>
      dig = *s - '0';
  801129:	0f be c9             	movsbl %cl,%ecx
  80112c:	83 e9 30             	sub    $0x30,%ecx
  80112f:	eb d9                	jmp    80110a <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801131:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801135:	41 80 f8 19          	cmp    $0x19,%r8b
  801139:	77 0a                	ja     801145 <strtol+0xce>
      dig = *s - 'A' + 10;
  80113b:	44 0f be c1          	movsbl %cl,%r8d
  80113f:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801143:	eb c5                	jmp    80110a <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801145:	48 85 f6             	test   %rsi,%rsi
  801148:	74 03                	je     80114d <strtol+0xd6>
    *endptr = (char *)s;
  80114a:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80114d:	48 89 c2             	mov    %rax,%rdx
  801150:	48 f7 da             	neg    %rdx
  801153:	45 85 c9             	test   %r9d,%r9d
  801156:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80115a:	c3                   	retq   
  80115b:	90                   	nop
