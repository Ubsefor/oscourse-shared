
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

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800083:	45 85 ed             	test   %r13d,%r13d
  800086:	7e 0d                	jle    800095 <libmain+0x5f>
    binaryname = argv[0];
  800088:	49 8b 06             	mov    (%r14),%rax
  80008b:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800092:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800095:	4c 89 f6             	mov    %r14,%rsi
  800098:	44 89 ef             	mov    %r13d,%edi
  80009b:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000a2:	00 00 00 
  8000a5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000a7:	48 b8 bc 00 80 00 00 	movabs $0x8000bc,%rax
  8000ae:	00 00 00 
  8000b1:	ff d0                	callq  *%rax
#endif
}
  8000b3:	5b                   	pop    %rbx
  8000b4:	41 5c                	pop    %r12
  8000b6:	41 5d                	pop    %r13
  8000b8:	41 5e                	pop    %r14
  8000ba:	5d                   	pop    %rbp
  8000bb:	c3                   	retq   

00000000008000bc <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000bc:	55                   	push   %rbp
  8000bd:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000c0:	bf 00 00 00 00       	mov    $0x0,%edi
  8000c5:	48 b8 11 01 80 00 00 	movabs $0x800111,%rax
  8000cc:	00 00 00 
  8000cf:	ff d0                	callq  *%rax
}
  8000d1:	5d                   	pop    %rbp
  8000d2:	c3                   	retq   

00000000008000d3 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000d3:	55                   	push   %rbp
  8000d4:	48 89 e5             	mov    %rsp,%rbp
  8000d7:	53                   	push   %rbx
  8000d8:	48 89 fa             	mov    %rdi,%rdx
  8000db:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000de:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e3:	48 89 c3             	mov    %rax,%rbx
  8000e6:	48 89 c7             	mov    %rax,%rdi
  8000e9:	48 89 c6             	mov    %rax,%rsi
  8000ec:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8000ee:	5b                   	pop    %rbx
  8000ef:	5d                   	pop    %rbp
  8000f0:	c3                   	retq   

00000000008000f1 <sys_cgetc>:

int
sys_cgetc(void) {
  8000f1:	55                   	push   %rbp
  8000f2:	48 89 e5             	mov    %rsp,%rbp
  8000f5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	48 89 ca             	mov    %rcx,%rdx
  800103:	48 89 cb             	mov    %rcx,%rbx
  800106:	48 89 cf             	mov    %rcx,%rdi
  800109:	48 89 ce             	mov    %rcx,%rsi
  80010c:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010e:	5b                   	pop    %rbx
  80010f:	5d                   	pop    %rbp
  800110:	c3                   	retq   

0000000000800111 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800111:	55                   	push   %rbp
  800112:	48 89 e5             	mov    %rsp,%rbp
  800115:	53                   	push   %rbx
  800116:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80011a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80011d:	be 00 00 00 00       	mov    $0x0,%esi
  800122:	b8 03 00 00 00       	mov    $0x3,%eax
  800127:	48 89 f1             	mov    %rsi,%rcx
  80012a:	48 89 f3             	mov    %rsi,%rbx
  80012d:	48 89 f7             	mov    %rsi,%rdi
  800130:	cd 30                	int    $0x30
  if (check && ret > 0)
  800132:	48 85 c0             	test   %rax,%rax
  800135:	7f 07                	jg     80013e <sys_env_destroy+0x2d>
}
  800137:	48 83 c4 08          	add    $0x8,%rsp
  80013b:	5b                   	pop    %rbx
  80013c:	5d                   	pop    %rbp
  80013d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80013e:	49 89 c0             	mov    %rax,%r8
  800141:	b9 03 00 00 00       	mov    $0x3,%ecx
  800146:	48 ba 50 11 80 00 00 	movabs $0x801150,%rdx
  80014d:	00 00 00 
  800150:	be 22 00 00 00       	mov    $0x22,%esi
  800155:	48 bf 6f 11 80 00 00 	movabs $0x80116f,%rdi
  80015c:	00 00 00 
  80015f:	b8 00 00 00 00       	mov    $0x0,%eax
  800164:	49 b9 91 01 80 00 00 	movabs $0x800191,%r9
  80016b:	00 00 00 
  80016e:	41 ff d1             	callq  *%r9

0000000000800171 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800171:	55                   	push   %rbp
  800172:	48 89 e5             	mov    %rsp,%rbp
  800175:	53                   	push   %rbx
  asm volatile("int %1\n"
  800176:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017b:	b8 02 00 00 00       	mov    $0x2,%eax
  800180:	48 89 ca             	mov    %rcx,%rdx
  800183:	48 89 cb             	mov    %rcx,%rbx
  800186:	48 89 cf             	mov    %rcx,%rdi
  800189:	48 89 ce             	mov    %rcx,%rsi
  80018c:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018e:	5b                   	pop    %rbx
  80018f:	5d                   	pop    %rbp
  800190:	c3                   	retq   

0000000000800191 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800191:	55                   	push   %rbp
  800192:	48 89 e5             	mov    %rsp,%rbp
  800195:	41 56                	push   %r14
  800197:	41 55                	push   %r13
  800199:	41 54                	push   %r12
  80019b:	53                   	push   %rbx
  80019c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001a3:	49 89 fd             	mov    %rdi,%r13
  8001a6:	41 89 f6             	mov    %esi,%r14d
  8001a9:	49 89 d4             	mov    %rdx,%r12
  8001ac:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001b3:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001ba:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001c1:	84 c0                	test   %al,%al
  8001c3:	74 26                	je     8001eb <_panic+0x5a>
  8001c5:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001cc:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001d3:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001d7:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001db:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001df:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001e3:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001e7:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8001eb:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8001f2:	00 00 00 
  8001f5:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8001fc:	00 00 00 
  8001ff:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800203:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80020a:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800211:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800218:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80021f:	00 00 00 
  800222:	48 8b 18             	mov    (%rax),%rbx
  800225:	48 b8 71 01 80 00 00 	movabs $0x800171,%rax
  80022c:	00 00 00 
  80022f:	ff d0                	callq  *%rax
  800231:	45 89 f0             	mov    %r14d,%r8d
  800234:	4c 89 e9             	mov    %r13,%rcx
  800237:	48 89 da             	mov    %rbx,%rdx
  80023a:	89 c6                	mov    %eax,%esi
  80023c:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  800243:	00 00 00 
  800246:	b8 00 00 00 00       	mov    $0x0,%eax
  80024b:	48 bb 33 03 80 00 00 	movabs $0x800333,%rbx
  800252:	00 00 00 
  800255:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800257:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80025e:	4c 89 e7             	mov    %r12,%rdi
  800261:	48 b8 cb 02 80 00 00 	movabs $0x8002cb,%rax
  800268:	00 00 00 
  80026b:	ff d0                	callq  *%rax
  cprintf("\n");
  80026d:	48 bf a8 11 80 00 00 	movabs $0x8011a8,%rdi
  800274:	00 00 00 
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
  80027c:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80027e:	cc                   	int3   
  while (1)
  80027f:	eb fd                	jmp    80027e <_panic+0xed>

0000000000800281 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800281:	55                   	push   %rbp
  800282:	48 89 e5             	mov    %rsp,%rbp
  800285:	53                   	push   %rbx
  800286:	48 83 ec 08          	sub    $0x8,%rsp
  80028a:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80028d:	8b 06                	mov    (%rsi),%eax
  80028f:	8d 50 01             	lea    0x1(%rax),%edx
  800292:	89 16                	mov    %edx,(%rsi)
  800294:	48 98                	cltq   
  800296:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80029b:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002a1:	74 0b                	je     8002ae <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002a3:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002a7:	48 83 c4 08          	add    $0x8,%rsp
  8002ab:	5b                   	pop    %rbx
  8002ac:	5d                   	pop    %rbp
  8002ad:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002ae:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002b2:	be ff 00 00 00       	mov    $0xff,%esi
  8002b7:	48 b8 d3 00 80 00 00 	movabs $0x8000d3,%rax
  8002be:	00 00 00 
  8002c1:	ff d0                	callq  *%rax
    b->idx = 0;
  8002c3:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002c9:	eb d8                	jmp    8002a3 <putch+0x22>

00000000008002cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002cb:	55                   	push   %rbp
  8002cc:	48 89 e5             	mov    %rsp,%rbp
  8002cf:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002d6:	48 89 fa             	mov    %rdi,%rdx
  8002d9:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002e3:	00 00 00 
  b.cnt = 0;
  8002e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002ed:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8002f0:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8002f7:	48 bf 81 02 80 00 00 	movabs $0x800281,%rdi
  8002fe:	00 00 00 
  800301:	48 b8 f1 04 80 00 00 	movabs $0x8004f1,%rax
  800308:	00 00 00 
  80030b:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80030d:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800314:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80031b:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80031f:	48 b8 d3 00 80 00 00 	movabs $0x8000d3,%rax
  800326:	00 00 00 
  800329:	ff d0                	callq  *%rax

  return b.cnt;
}
  80032b:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800331:	c9                   	leaveq 
  800332:	c3                   	retq   

0000000000800333 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800333:	55                   	push   %rbp
  800334:	48 89 e5             	mov    %rsp,%rbp
  800337:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80033e:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800345:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80034c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800353:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80035a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800361:	84 c0                	test   %al,%al
  800363:	74 20                	je     800385 <cprintf+0x52>
  800365:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800369:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80036d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800371:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800375:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800379:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80037d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800381:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800385:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80038c:	00 00 00 
  80038f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800396:	00 00 00 
  800399:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80039d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003a4:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003ab:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003b2:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003b9:	48 b8 cb 02 80 00 00 	movabs $0x8002cb,%rax
  8003c0:	00 00 00 
  8003c3:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003c5:	c9                   	leaveq 
  8003c6:	c3                   	retq   

00000000008003c7 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003c7:	55                   	push   %rbp
  8003c8:	48 89 e5             	mov    %rsp,%rbp
  8003cb:	41 57                	push   %r15
  8003cd:	41 56                	push   %r14
  8003cf:	41 55                	push   %r13
  8003d1:	41 54                	push   %r12
  8003d3:	53                   	push   %rbx
  8003d4:	48 83 ec 18          	sub    $0x18,%rsp
  8003d8:	49 89 fc             	mov    %rdi,%r12
  8003db:	49 89 f5             	mov    %rsi,%r13
  8003de:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003e2:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003e5:	41 89 cf             	mov    %ecx,%r15d
  8003e8:	49 39 d7             	cmp    %rdx,%r15
  8003eb:	76 45                	jbe    800432 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003ed:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8003f1:	85 db                	test   %ebx,%ebx
  8003f3:	7e 0e                	jle    800403 <printnum+0x3c>
      putch(padc, putdat);
  8003f5:	4c 89 ee             	mov    %r13,%rsi
  8003f8:	44 89 f7             	mov    %r14d,%edi
  8003fb:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8003fe:	83 eb 01             	sub    $0x1,%ebx
  800401:	75 f2                	jne    8003f5 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800403:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800407:	ba 00 00 00 00       	mov    $0x0,%edx
  80040c:	49 f7 f7             	div    %r15
  80040f:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  800416:	00 00 00 
  800419:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80041d:	4c 89 ee             	mov    %r13,%rsi
  800420:	41 ff d4             	callq  *%r12
}
  800423:	48 83 c4 18          	add    $0x18,%rsp
  800427:	5b                   	pop    %rbx
  800428:	41 5c                	pop    %r12
  80042a:	41 5d                	pop    %r13
  80042c:	41 5e                	pop    %r14
  80042e:	41 5f                	pop    %r15
  800430:	5d                   	pop    %rbp
  800431:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800432:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800436:	ba 00 00 00 00       	mov    $0x0,%edx
  80043b:	49 f7 f7             	div    %r15
  80043e:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800442:	48 89 c2             	mov    %rax,%rdx
  800445:	48 b8 c7 03 80 00 00 	movabs $0x8003c7,%rax
  80044c:	00 00 00 
  80044f:	ff d0                	callq  *%rax
  800451:	eb b0                	jmp    800403 <printnum+0x3c>

0000000000800453 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800453:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800457:	48 8b 06             	mov    (%rsi),%rax
  80045a:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80045e:	73 0a                	jae    80046a <sprintputch+0x17>
    *b->buf++ = ch;
  800460:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800464:	48 89 16             	mov    %rdx,(%rsi)
  800467:	40 88 38             	mov    %dil,(%rax)
}
  80046a:	c3                   	retq   

000000000080046b <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80046b:	55                   	push   %rbp
  80046c:	48 89 e5             	mov    %rsp,%rbp
  80046f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800476:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80047d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800484:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80048b:	84 c0                	test   %al,%al
  80048d:	74 20                	je     8004af <printfmt+0x44>
  80048f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800493:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800497:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80049b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80049f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004a3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004a7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004ab:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004af:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004b6:	00 00 00 
  8004b9:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004c0:	00 00 00 
  8004c3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004c7:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004ce:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004d5:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004dc:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004e3:	48 b8 f1 04 80 00 00 	movabs $0x8004f1,%rax
  8004ea:	00 00 00 
  8004ed:	ff d0                	callq  *%rax
}
  8004ef:	c9                   	leaveq 
  8004f0:	c3                   	retq   

00000000008004f1 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8004f1:	55                   	push   %rbp
  8004f2:	48 89 e5             	mov    %rsp,%rbp
  8004f5:	41 57                	push   %r15
  8004f7:	41 56                	push   %r14
  8004f9:	41 55                	push   %r13
  8004fb:	41 54                	push   %r12
  8004fd:	53                   	push   %rbx
  8004fe:	48 83 ec 48          	sub    $0x48,%rsp
  800502:	49 89 fd             	mov    %rdi,%r13
  800505:	49 89 f7             	mov    %rsi,%r15
  800508:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80050b:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80050f:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800513:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800517:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80051b:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80051f:	41 0f b6 3e          	movzbl (%r14),%edi
  800523:	83 ff 25             	cmp    $0x25,%edi
  800526:	74 18                	je     800540 <vprintfmt+0x4f>
      if (ch == '\0')
  800528:	85 ff                	test   %edi,%edi
  80052a:	0f 84 8c 06 00 00    	je     800bbc <vprintfmt+0x6cb>
      putch(ch, putdat);
  800530:	4c 89 fe             	mov    %r15,%rsi
  800533:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800536:	49 89 de             	mov    %rbx,%r14
  800539:	eb e0                	jmp    80051b <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80053b:	49 89 de             	mov    %rbx,%r14
  80053e:	eb db                	jmp    80051b <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800540:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800544:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800548:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80054f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800555:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800559:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80055e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800564:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80056a:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80056f:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800574:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800578:	0f b6 13             	movzbl (%rbx),%edx
  80057b:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80057e:	3c 55                	cmp    $0x55,%al
  800580:	0f 87 8b 05 00 00    	ja     800b11 <vprintfmt+0x620>
  800586:	0f b6 c0             	movzbl %al,%eax
  800589:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800590:	00 00 00 
  800593:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800597:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80059a:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80059e:	eb d4                	jmp    800574 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005a0:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005a3:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005a7:	eb cb                	jmp    800574 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005a9:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005ac:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005b0:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005b4:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005b7:	83 fa 09             	cmp    $0x9,%edx
  8005ba:	77 7e                	ja     80063a <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005bc:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005c0:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005c4:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005c9:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005cd:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005d0:	83 fa 09             	cmp    $0x9,%edx
  8005d3:	76 e7                	jbe    8005bc <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005d5:	4c 89 f3             	mov    %r14,%rbx
  8005d8:	eb 19                	jmp    8005f3 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005da:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005dd:	83 f8 2f             	cmp    $0x2f,%eax
  8005e0:	77 2a                	ja     80060c <vprintfmt+0x11b>
  8005e2:	89 c2                	mov    %eax,%edx
  8005e4:	4c 01 d2             	add    %r10,%rdx
  8005e7:	83 c0 08             	add    $0x8,%eax
  8005ea:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005ed:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8005f0:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8005f3:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005f7:	0f 89 77 ff ff ff    	jns    800574 <vprintfmt+0x83>
          width = precision, precision = -1;
  8005fd:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800601:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800607:	e9 68 ff ff ff       	jmpq   800574 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80060c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800610:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800614:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800618:	eb d3                	jmp    8005ed <vprintfmt+0xfc>
        if (width < 0)
  80061a:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	41 0f 48 c0          	cmovs  %r8d,%eax
  800623:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800626:	4c 89 f3             	mov    %r14,%rbx
  800629:	e9 46 ff ff ff       	jmpq   800574 <vprintfmt+0x83>
  80062e:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800631:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800635:	e9 3a ff ff ff       	jmpq   800574 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80063a:	4c 89 f3             	mov    %r14,%rbx
  80063d:	eb b4                	jmp    8005f3 <vprintfmt+0x102>
        lflag++;
  80063f:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800642:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800645:	e9 2a ff ff ff       	jmpq   800574 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80064a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80064d:	83 f8 2f             	cmp    $0x2f,%eax
  800650:	77 19                	ja     80066b <vprintfmt+0x17a>
  800652:	89 c2                	mov    %eax,%edx
  800654:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800658:	83 c0 08             	add    $0x8,%eax
  80065b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80065e:	4c 89 fe             	mov    %r15,%rsi
  800661:	8b 3a                	mov    (%rdx),%edi
  800663:	41 ff d5             	callq  *%r13
        break;
  800666:	e9 b0 fe ff ff       	jmpq   80051b <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80066b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80066f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800673:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800677:	eb e5                	jmp    80065e <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800679:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80067c:	83 f8 2f             	cmp    $0x2f,%eax
  80067f:	77 5b                	ja     8006dc <vprintfmt+0x1eb>
  800681:	89 c2                	mov    %eax,%edx
  800683:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800687:	83 c0 08             	add    $0x8,%eax
  80068a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80068d:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80068f:	89 c8                	mov    %ecx,%eax
  800691:	c1 f8 1f             	sar    $0x1f,%eax
  800694:	31 c1                	xor    %eax,%ecx
  800696:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800698:	83 f9 09             	cmp    $0x9,%ecx
  80069b:	7f 4d                	jg     8006ea <vprintfmt+0x1f9>
  80069d:	48 63 c1             	movslq %ecx,%rax
  8006a0:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  8006a7:	00 00 00 
  8006aa:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006ae:	48 85 c0             	test   %rax,%rax
  8006b1:	74 37                	je     8006ea <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006b3:	48 89 c1             	mov    %rax,%rcx
  8006b6:	48 ba cb 11 80 00 00 	movabs $0x8011cb,%rdx
  8006bd:	00 00 00 
  8006c0:	4c 89 fe             	mov    %r15,%rsi
  8006c3:	4c 89 ef             	mov    %r13,%rdi
  8006c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cb:	48 bb 6b 04 80 00 00 	movabs $0x80046b,%rbx
  8006d2:	00 00 00 
  8006d5:	ff d3                	callq  *%rbx
  8006d7:	e9 3f fe ff ff       	jmpq   80051b <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006dc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006e0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006e4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e8:	eb a3                	jmp    80068d <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006ea:	48 ba c2 11 80 00 00 	movabs $0x8011c2,%rdx
  8006f1:	00 00 00 
  8006f4:	4c 89 fe             	mov    %r15,%rsi
  8006f7:	4c 89 ef             	mov    %r13,%rdi
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	48 bb 6b 04 80 00 00 	movabs $0x80046b,%rbx
  800706:	00 00 00 
  800709:	ff d3                	callq  *%rbx
  80070b:	e9 0b fe ff ff       	jmpq   80051b <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800710:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800713:	83 f8 2f             	cmp    $0x2f,%eax
  800716:	77 4b                	ja     800763 <vprintfmt+0x272>
  800718:	89 c2                	mov    %eax,%edx
  80071a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80071e:	83 c0 08             	add    $0x8,%eax
  800721:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800724:	48 8b 02             	mov    (%rdx),%rax
  800727:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80072b:	48 85 c0             	test   %rax,%rax
  80072e:	0f 84 05 04 00 00    	je     800b39 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800734:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800738:	7e 06                	jle    800740 <vprintfmt+0x24f>
  80073a:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80073e:	75 31                	jne    800771 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800740:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800744:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800748:	0f b6 00             	movzbl (%rax),%eax
  80074b:	0f be f8             	movsbl %al,%edi
  80074e:	85 ff                	test   %edi,%edi
  800750:	0f 84 c3 00 00 00    	je     800819 <vprintfmt+0x328>
  800756:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80075a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80075e:	e9 85 00 00 00       	jmpq   8007e8 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800763:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800767:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80076b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80076f:	eb b3                	jmp    800724 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800771:	49 63 f4             	movslq %r12d,%rsi
  800774:	48 89 c7             	mov    %rax,%rdi
  800777:	48 b8 c8 0c 80 00 00 	movabs $0x800cc8,%rax
  80077e:	00 00 00 
  800781:	ff d0                	callq  *%rax
  800783:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800786:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800789:	85 f6                	test   %esi,%esi
  80078b:	7e 22                	jle    8007af <vprintfmt+0x2be>
            putch(padc, putdat);
  80078d:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800791:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800795:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800799:	4c 89 fe             	mov    %r15,%rsi
  80079c:	89 df                	mov    %ebx,%edi
  80079e:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007a1:	41 83 ec 01          	sub    $0x1,%r12d
  8007a5:	75 f2                	jne    800799 <vprintfmt+0x2a8>
  8007a7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007ab:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007af:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007b3:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007b7:	0f b6 00             	movzbl (%rax),%eax
  8007ba:	0f be f8             	movsbl %al,%edi
  8007bd:	85 ff                	test   %edi,%edi
  8007bf:	0f 84 56 fd ff ff    	je     80051b <vprintfmt+0x2a>
  8007c5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007c9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007cd:	eb 19                	jmp    8007e8 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007cf:	4c 89 fe             	mov    %r15,%rsi
  8007d2:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d5:	41 83 ee 01          	sub    $0x1,%r14d
  8007d9:	48 83 c3 01          	add    $0x1,%rbx
  8007dd:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007e1:	0f be f8             	movsbl %al,%edi
  8007e4:	85 ff                	test   %edi,%edi
  8007e6:	74 29                	je     800811 <vprintfmt+0x320>
  8007e8:	45 85 e4             	test   %r12d,%r12d
  8007eb:	78 06                	js     8007f3 <vprintfmt+0x302>
  8007ed:	41 83 ec 01          	sub    $0x1,%r12d
  8007f1:	78 48                	js     80083b <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8007f3:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8007f7:	74 d6                	je     8007cf <vprintfmt+0x2de>
  8007f9:	0f be c0             	movsbl %al,%eax
  8007fc:	83 e8 20             	sub    $0x20,%eax
  8007ff:	83 f8 5e             	cmp    $0x5e,%eax
  800802:	76 cb                	jbe    8007cf <vprintfmt+0x2de>
            putch('?', putdat);
  800804:	4c 89 fe             	mov    %r15,%rsi
  800807:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80080c:	41 ff d5             	callq  *%r13
  80080f:	eb c4                	jmp    8007d5 <vprintfmt+0x2e4>
  800811:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800815:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800819:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80081c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800820:	0f 8e f5 fc ff ff    	jle    80051b <vprintfmt+0x2a>
          putch(' ', putdat);
  800826:	4c 89 fe             	mov    %r15,%rsi
  800829:	bf 20 00 00 00       	mov    $0x20,%edi
  80082e:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800831:	83 eb 01             	sub    $0x1,%ebx
  800834:	75 f0                	jne    800826 <vprintfmt+0x335>
  800836:	e9 e0 fc ff ff       	jmpq   80051b <vprintfmt+0x2a>
  80083b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80083f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800843:	eb d4                	jmp    800819 <vprintfmt+0x328>
  if (lflag >= 2)
  800845:	83 f9 01             	cmp    $0x1,%ecx
  800848:	7f 1d                	jg     800867 <vprintfmt+0x376>
  else if (lflag)
  80084a:	85 c9                	test   %ecx,%ecx
  80084c:	74 5e                	je     8008ac <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80084e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800851:	83 f8 2f             	cmp    $0x2f,%eax
  800854:	77 48                	ja     80089e <vprintfmt+0x3ad>
  800856:	89 c2                	mov    %eax,%edx
  800858:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80085c:	83 c0 08             	add    $0x8,%eax
  80085f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800862:	48 8b 1a             	mov    (%rdx),%rbx
  800865:	eb 17                	jmp    80087e <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800867:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80086a:	83 f8 2f             	cmp    $0x2f,%eax
  80086d:	77 21                	ja     800890 <vprintfmt+0x39f>
  80086f:	89 c2                	mov    %eax,%edx
  800871:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800875:	83 c0 08             	add    $0x8,%eax
  800878:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80087b:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80087e:	48 85 db             	test   %rbx,%rbx
  800881:	78 50                	js     8008d3 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800883:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800886:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80088b:	e9 b4 01 00 00       	jmpq   800a44 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800890:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800894:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800898:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80089c:	eb dd                	jmp    80087b <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80089e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008a6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008aa:	eb b6                	jmp    800862 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008ac:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008af:	83 f8 2f             	cmp    $0x2f,%eax
  8008b2:	77 11                	ja     8008c5 <vprintfmt+0x3d4>
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ba:	83 c0 08             	add    $0x8,%eax
  8008bd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c0:	48 63 1a             	movslq (%rdx),%rbx
  8008c3:	eb b9                	jmp    80087e <vprintfmt+0x38d>
  8008c5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008cd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d1:	eb ed                	jmp    8008c0 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008d3:	4c 89 fe             	mov    %r15,%rsi
  8008d6:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008db:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008de:	48 89 da             	mov    %rbx,%rdx
  8008e1:	48 f7 da             	neg    %rdx
        base = 10;
  8008e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008e9:	e9 56 01 00 00       	jmpq   800a44 <vprintfmt+0x553>
  if (lflag >= 2)
  8008ee:	83 f9 01             	cmp    $0x1,%ecx
  8008f1:	7f 25                	jg     800918 <vprintfmt+0x427>
  else if (lflag)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 5e                	je     800955 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8008f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008fa:	83 f8 2f             	cmp    $0x2f,%eax
  8008fd:	77 48                	ja     800947 <vprintfmt+0x456>
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800905:	83 c0 08             	add    $0x8,%eax
  800908:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80090b:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80090e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800913:	e9 2c 01 00 00       	jmpq   800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800918:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091b:	83 f8 2f             	cmp    $0x2f,%eax
  80091e:	77 19                	ja     800939 <vprintfmt+0x448>
  800920:	89 c2                	mov    %eax,%edx
  800922:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800926:	83 c0 08             	add    $0x8,%eax
  800929:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092c:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80092f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800934:	e9 0b 01 00 00       	jmpq   800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800939:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80093d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800941:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800945:	eb e5                	jmp    80092c <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800947:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800953:	eb b6                	jmp    80090b <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800955:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800958:	83 f8 2f             	cmp    $0x2f,%eax
  80095b:	77 18                	ja     800975 <vprintfmt+0x484>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800963:	83 c0 08             	add    $0x8,%eax
  800966:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800969:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80096b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800970:	e9 cf 00 00 00       	jmpq   800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800975:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800979:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800981:	eb e6                	jmp    800969 <vprintfmt+0x478>
  if (lflag >= 2)
  800983:	83 f9 01             	cmp    $0x1,%ecx
  800986:	7f 25                	jg     8009ad <vprintfmt+0x4bc>
  else if (lflag)
  800988:	85 c9                	test   %ecx,%ecx
  80098a:	74 5b                	je     8009e7 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80098c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80098f:	83 f8 2f             	cmp    $0x2f,%eax
  800992:	77 45                	ja     8009d9 <vprintfmt+0x4e8>
  800994:	89 c2                	mov    %eax,%edx
  800996:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80099a:	83 c0 08             	add    $0x8,%eax
  80099d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009a0:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009a3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009a8:	e9 97 00 00 00       	jmpq   800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009ad:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b0:	83 f8 2f             	cmp    $0x2f,%eax
  8009b3:	77 16                	ja     8009cb <vprintfmt+0x4da>
  8009b5:	89 c2                	mov    %eax,%edx
  8009b7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009bb:	83 c0 08             	add    $0x8,%eax
  8009be:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009c1:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009c4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009c9:	eb 79                	jmp    800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009cb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009cf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009d3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009d7:	eb e8                	jmp    8009c1 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e5:	eb b9                	jmp    8009a0 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009e7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ea:	83 f8 2f             	cmp    $0x2f,%eax
  8009ed:	77 15                	ja     800a04 <vprintfmt+0x513>
  8009ef:	89 c2                	mov    %eax,%edx
  8009f1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f5:	83 c0 08             	add    $0x8,%eax
  8009f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009fb:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8009fd:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a02:	eb 40                	jmp    800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a04:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a08:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a10:	eb e9                	jmp    8009fb <vprintfmt+0x50a>
        putch('0', putdat);
  800a12:	4c 89 fe             	mov    %r15,%rsi
  800a15:	bf 30 00 00 00       	mov    $0x30,%edi
  800a1a:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a1d:	4c 89 fe             	mov    %r15,%rsi
  800a20:	bf 78 00 00 00       	mov    $0x78,%edi
  800a25:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a28:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a2b:	83 f8 2f             	cmp    $0x2f,%eax
  800a2e:	77 34                	ja     800a64 <vprintfmt+0x573>
  800a30:	89 c2                	mov    %eax,%edx
  800a32:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a36:	83 c0 08             	add    $0x8,%eax
  800a39:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a3c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a3f:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a44:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a49:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a4d:	4c 89 fe             	mov    %r15,%rsi
  800a50:	4c 89 ef             	mov    %r13,%rdi
  800a53:	48 b8 c7 03 80 00 00 	movabs $0x8003c7,%rax
  800a5a:	00 00 00 
  800a5d:	ff d0                	callq  *%rax
        break;
  800a5f:	e9 b7 fa ff ff       	jmpq   80051b <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a64:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a68:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a6c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a70:	eb ca                	jmp    800a3c <vprintfmt+0x54b>
  if (lflag >= 2)
  800a72:	83 f9 01             	cmp    $0x1,%ecx
  800a75:	7f 22                	jg     800a99 <vprintfmt+0x5a8>
  else if (lflag)
  800a77:	85 c9                	test   %ecx,%ecx
  800a79:	74 58                	je     800ad3 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a7b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a7e:	83 f8 2f             	cmp    $0x2f,%eax
  800a81:	77 42                	ja     800ac5 <vprintfmt+0x5d4>
  800a83:	89 c2                	mov    %eax,%edx
  800a85:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a89:	83 c0 08             	add    $0x8,%eax
  800a8c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a8f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a92:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a97:	eb ab                	jmp    800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a99:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a9c:	83 f8 2f             	cmp    $0x2f,%eax
  800a9f:	77 16                	ja     800ab7 <vprintfmt+0x5c6>
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aa7:	83 c0 08             	add    $0x8,%eax
  800aaa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aad:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ab0:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ab5:	eb 8d                	jmp    800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ab7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800abb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800abf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ac3:	eb e8                	jmp    800aad <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800ac5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ac9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800acd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ad1:	eb bc                	jmp    800a8f <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ad3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ad6:	83 f8 2f             	cmp    $0x2f,%eax
  800ad9:	77 18                	ja     800af3 <vprintfmt+0x602>
  800adb:	89 c2                	mov    %eax,%edx
  800add:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ae1:	83 c0 08             	add    $0x8,%eax
  800ae4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ae7:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800ae9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aee:	e9 51 ff ff ff       	jmpq   800a44 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800af3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800af7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800afb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aff:	eb e6                	jmp    800ae7 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b01:	4c 89 fe             	mov    %r15,%rsi
  800b04:	bf 25 00 00 00       	mov    $0x25,%edi
  800b09:	41 ff d5             	callq  *%r13
        break;
  800b0c:	e9 0a fa ff ff       	jmpq   80051b <vprintfmt+0x2a>
        putch('%', putdat);
  800b11:	4c 89 fe             	mov    %r15,%rsi
  800b14:	bf 25 00 00 00       	mov    $0x25,%edi
  800b19:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b1c:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b20:	0f 84 15 fa ff ff    	je     80053b <vprintfmt+0x4a>
  800b26:	49 89 de             	mov    %rbx,%r14
  800b29:	49 83 ee 01          	sub    $0x1,%r14
  800b2d:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b32:	75 f5                	jne    800b29 <vprintfmt+0x638>
  800b34:	e9 e2 f9 ff ff       	jmpq   80051b <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b39:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b3d:	74 06                	je     800b45 <vprintfmt+0x654>
  800b3f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b43:	7f 21                	jg     800b66 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b45:	bf 28 00 00 00       	mov    $0x28,%edi
  800b4a:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800b51:	00 00 00 
  800b54:	b8 28 00 00 00       	mov    $0x28,%eax
  800b59:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b5d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b61:	e9 82 fc ff ff       	jmpq   8007e8 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b66:	49 63 f4             	movslq %r12d,%rsi
  800b69:	48 bf bb 11 80 00 00 	movabs $0x8011bb,%rdi
  800b70:	00 00 00 
  800b73:	48 b8 c8 0c 80 00 00 	movabs $0x800cc8,%rax
  800b7a:	00 00 00 
  800b7d:	ff d0                	callq  *%rax
  800b7f:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b82:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b85:	48 be bb 11 80 00 00 	movabs $0x8011bb,%rsi
  800b8c:	00 00 00 
  800b8f:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	0f 8f f2 fb ff ff    	jg     80078d <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b9b:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800ba2:	00 00 00 
  800ba5:	b8 28 00 00 00       	mov    $0x28,%eax
  800baa:	bf 28 00 00 00       	mov    $0x28,%edi
  800baf:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bb3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bb7:	e9 2c fc ff ff       	jmpq   8007e8 <vprintfmt+0x2f7>
}
  800bbc:	48 83 c4 48          	add    $0x48,%rsp
  800bc0:	5b                   	pop    %rbx
  800bc1:	41 5c                	pop    %r12
  800bc3:	41 5d                	pop    %r13
  800bc5:	41 5e                	pop    %r14
  800bc7:	41 5f                	pop    %r15
  800bc9:	5d                   	pop    %rbp
  800bca:	c3                   	retq   

0000000000800bcb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bcb:	55                   	push   %rbp
  800bcc:	48 89 e5             	mov    %rsp,%rbp
  800bcf:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bd3:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bd7:	48 63 c6             	movslq %esi,%rax
  800bda:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bdf:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800be3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800bea:	48 85 ff             	test   %rdi,%rdi
  800bed:	74 2a                	je     800c19 <vsnprintf+0x4e>
  800bef:	85 f6                	test   %esi,%esi
  800bf1:	7e 26                	jle    800c19 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800bf3:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800bf7:	48 bf 53 04 80 00 00 	movabs $0x800453,%rdi
  800bfe:	00 00 00 
  800c01:	48 b8 f1 04 80 00 00 	movabs $0x8004f1,%rax
  800c08:	00 00 00 
  800c0b:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c0d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c11:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c14:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c17:	c9                   	leaveq 
  800c18:	c3                   	retq   
    return -E_INVAL;
  800c19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c1e:	eb f7                	jmp    800c17 <vsnprintf+0x4c>

0000000000800c20 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c20:	55                   	push   %rbp
  800c21:	48 89 e5             	mov    %rsp,%rbp
  800c24:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c2b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c32:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c39:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c40:	84 c0                	test   %al,%al
  800c42:	74 20                	je     800c64 <snprintf+0x44>
  800c44:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c48:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c4c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c50:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c54:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c58:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c5c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c60:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c64:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c6b:	00 00 00 
  800c6e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c75:	00 00 00 
  800c78:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c7c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c83:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c8a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c91:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c98:	48 b8 cb 0b 80 00 00 	movabs $0x800bcb,%rax
  800c9f:	00 00 00 
  800ca2:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800ca4:	c9                   	leaveq 
  800ca5:	c3                   	retq   

0000000000800ca6 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800ca6:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ca9:	74 17                	je     800cc2 <strlen+0x1c>
  800cab:	48 89 fa             	mov    %rdi,%rdx
  800cae:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cb3:	29 f9                	sub    %edi,%ecx
    n++;
  800cb5:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cb8:	48 83 c2 01          	add    $0x1,%rdx
  800cbc:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cbf:	75 f4                	jne    800cb5 <strlen+0xf>
  800cc1:	c3                   	retq   
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cc7:	c3                   	retq   

0000000000800cc8 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc8:	48 85 f6             	test   %rsi,%rsi
  800ccb:	74 24                	je     800cf1 <strnlen+0x29>
  800ccd:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cd0:	74 25                	je     800cf7 <strnlen+0x2f>
  800cd2:	48 01 fe             	add    %rdi,%rsi
  800cd5:	48 89 fa             	mov    %rdi,%rdx
  800cd8:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cdd:	29 f9                	sub    %edi,%ecx
    n++;
  800cdf:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce2:	48 83 c2 01          	add    $0x1,%rdx
  800ce6:	48 39 f2             	cmp    %rsi,%rdx
  800ce9:	74 11                	je     800cfc <strnlen+0x34>
  800ceb:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cee:	75 ef                	jne    800cdf <strnlen+0x17>
  800cf0:	c3                   	retq   
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	c3                   	retq   
  800cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cfc:	c3                   	retq   

0000000000800cfd <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800cfd:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d09:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d0c:	48 83 c2 01          	add    $0x1,%rdx
  800d10:	84 c9                	test   %cl,%cl
  800d12:	75 f1                	jne    800d05 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d14:	c3                   	retq   

0000000000800d15 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d15:	55                   	push   %rbp
  800d16:	48 89 e5             	mov    %rsp,%rbp
  800d19:	41 54                	push   %r12
  800d1b:	53                   	push   %rbx
  800d1c:	48 89 fb             	mov    %rdi,%rbx
  800d1f:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d22:	48 b8 a6 0c 80 00 00 	movabs $0x800ca6,%rax
  800d29:	00 00 00 
  800d2c:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d2e:	48 63 f8             	movslq %eax,%rdi
  800d31:	48 01 df             	add    %rbx,%rdi
  800d34:	4c 89 e6             	mov    %r12,%rsi
  800d37:	48 b8 fd 0c 80 00 00 	movabs $0x800cfd,%rax
  800d3e:	00 00 00 
  800d41:	ff d0                	callq  *%rax
  return dst;
}
  800d43:	48 89 d8             	mov    %rbx,%rax
  800d46:	5b                   	pop    %rbx
  800d47:	41 5c                	pop    %r12
  800d49:	5d                   	pop    %rbp
  800d4a:	c3                   	retq   

0000000000800d4b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d4b:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d4e:	48 85 d2             	test   %rdx,%rdx
  800d51:	74 1f                	je     800d72 <strncpy+0x27>
  800d53:	48 01 fa             	add    %rdi,%rdx
  800d56:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d59:	48 83 c1 01          	add    $0x1,%rcx
  800d5d:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d61:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d65:	41 80 f8 01          	cmp    $0x1,%r8b
  800d69:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d6d:	48 39 ca             	cmp    %rcx,%rdx
  800d70:	75 e7                	jne    800d59 <strncpy+0xe>
  }
  return ret;
}
  800d72:	c3                   	retq   

0000000000800d73 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d73:	48 89 f8             	mov    %rdi,%rax
  800d76:	48 85 d2             	test   %rdx,%rdx
  800d79:	74 36                	je     800db1 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d7b:	48 83 fa 01          	cmp    $0x1,%rdx
  800d7f:	74 2d                	je     800dae <strlcpy+0x3b>
  800d81:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d85:	45 84 c0             	test   %r8b,%r8b
  800d88:	74 24                	je     800dae <strlcpy+0x3b>
  800d8a:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d8e:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d93:	48 83 c0 01          	add    $0x1,%rax
  800d97:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d9b:	48 39 d1             	cmp    %rdx,%rcx
  800d9e:	74 0e                	je     800dae <strlcpy+0x3b>
  800da0:	48 83 c1 01          	add    $0x1,%rcx
  800da4:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800da9:	45 84 c0             	test   %r8b,%r8b
  800dac:	75 e5                	jne    800d93 <strlcpy+0x20>
    *dst = '\0';
  800dae:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800db1:	48 29 f8             	sub    %rdi,%rax
}
  800db4:	c3                   	retq   

0000000000800db5 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800db5:	0f b6 07             	movzbl (%rdi),%eax
  800db8:	84 c0                	test   %al,%al
  800dba:	74 17                	je     800dd3 <strcmp+0x1e>
  800dbc:	3a 06                	cmp    (%rsi),%al
  800dbe:	75 13                	jne    800dd3 <strcmp+0x1e>
    p++, q++;
  800dc0:	48 83 c7 01          	add    $0x1,%rdi
  800dc4:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dc8:	0f b6 07             	movzbl (%rdi),%eax
  800dcb:	84 c0                	test   %al,%al
  800dcd:	74 04                	je     800dd3 <strcmp+0x1e>
  800dcf:	3a 06                	cmp    (%rsi),%al
  800dd1:	74 ed                	je     800dc0 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dd3:	0f b6 c0             	movzbl %al,%eax
  800dd6:	0f b6 16             	movzbl (%rsi),%edx
  800dd9:	29 d0                	sub    %edx,%eax
}
  800ddb:	c3                   	retq   

0000000000800ddc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800ddc:	48 85 d2             	test   %rdx,%rdx
  800ddf:	74 2f                	je     800e10 <strncmp+0x34>
  800de1:	0f b6 07             	movzbl (%rdi),%eax
  800de4:	84 c0                	test   %al,%al
  800de6:	74 1f                	je     800e07 <strncmp+0x2b>
  800de8:	3a 06                	cmp    (%rsi),%al
  800dea:	75 1b                	jne    800e07 <strncmp+0x2b>
  800dec:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800def:	48 83 c7 01          	add    $0x1,%rdi
  800df3:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800df7:	48 39 d7             	cmp    %rdx,%rdi
  800dfa:	74 1a                	je     800e16 <strncmp+0x3a>
  800dfc:	0f b6 07             	movzbl (%rdi),%eax
  800dff:	84 c0                	test   %al,%al
  800e01:	74 04                	je     800e07 <strncmp+0x2b>
  800e03:	3a 06                	cmp    (%rsi),%al
  800e05:	74 e8                	je     800def <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e07:	0f b6 07             	movzbl (%rdi),%eax
  800e0a:	0f b6 16             	movzbl (%rsi),%edx
  800e0d:	29 d0                	sub    %edx,%eax
}
  800e0f:	c3                   	retq   
    return 0;
  800e10:	b8 00 00 00 00       	mov    $0x0,%eax
  800e15:	c3                   	retq   
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1b:	c3                   	retq   

0000000000800e1c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e1c:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e1e:	0f b6 07             	movzbl (%rdi),%eax
  800e21:	84 c0                	test   %al,%al
  800e23:	74 1e                	je     800e43 <strchr+0x27>
    if (*s == c)
  800e25:	40 38 c6             	cmp    %al,%sil
  800e28:	74 1f                	je     800e49 <strchr+0x2d>
  for (; *s; s++)
  800e2a:	48 83 c7 01          	add    $0x1,%rdi
  800e2e:	0f b6 07             	movzbl (%rdi),%eax
  800e31:	84 c0                	test   %al,%al
  800e33:	74 08                	je     800e3d <strchr+0x21>
    if (*s == c)
  800e35:	38 d0                	cmp    %dl,%al
  800e37:	75 f1                	jne    800e2a <strchr+0xe>
  for (; *s; s++)
  800e39:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e3c:	c3                   	retq   
  return 0;
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	c3                   	retq   
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
  800e48:	c3                   	retq   
    if (*s == c)
  800e49:	48 89 f8             	mov    %rdi,%rax
  800e4c:	c3                   	retq   

0000000000800e4d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e4d:	48 89 f8             	mov    %rdi,%rax
  800e50:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e52:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e55:	40 38 f2             	cmp    %sil,%dl
  800e58:	74 13                	je     800e6d <strfind+0x20>
  800e5a:	84 d2                	test   %dl,%dl
  800e5c:	74 0f                	je     800e6d <strfind+0x20>
  for (; *s; s++)
  800e5e:	48 83 c0 01          	add    $0x1,%rax
  800e62:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e65:	38 ca                	cmp    %cl,%dl
  800e67:	74 04                	je     800e6d <strfind+0x20>
  800e69:	84 d2                	test   %dl,%dl
  800e6b:	75 f1                	jne    800e5e <strfind+0x11>
      break;
  return (char *)s;
}
  800e6d:	c3                   	retq   

0000000000800e6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e6e:	48 85 d2             	test   %rdx,%rdx
  800e71:	74 3a                	je     800ead <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e73:	48 89 f8             	mov    %rdi,%rax
  800e76:	48 09 d0             	or     %rdx,%rax
  800e79:	a8 03                	test   $0x3,%al
  800e7b:	75 28                	jne    800ea5 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e7d:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e81:	89 f0                	mov    %esi,%eax
  800e83:	c1 e0 08             	shl    $0x8,%eax
  800e86:	89 f1                	mov    %esi,%ecx
  800e88:	c1 e1 18             	shl    $0x18,%ecx
  800e8b:	41 89 f0             	mov    %esi,%r8d
  800e8e:	41 c1 e0 10          	shl    $0x10,%r8d
  800e92:	44 09 c1             	or     %r8d,%ecx
  800e95:	09 ce                	or     %ecx,%esi
  800e97:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e99:	48 c1 ea 02          	shr    $0x2,%rdx
  800e9d:	48 89 d1             	mov    %rdx,%rcx
  800ea0:	fc                   	cld    
  800ea1:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ea3:	eb 08                	jmp    800ead <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ea5:	89 f0                	mov    %esi,%eax
  800ea7:	48 89 d1             	mov    %rdx,%rcx
  800eaa:	fc                   	cld    
  800eab:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ead:	48 89 f8             	mov    %rdi,%rax
  800eb0:	c3                   	retq   

0000000000800eb1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800eb1:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800eb4:	48 39 fe             	cmp    %rdi,%rsi
  800eb7:	73 40                	jae    800ef9 <memmove+0x48>
  800eb9:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ebd:	48 39 f9             	cmp    %rdi,%rcx
  800ec0:	76 37                	jbe    800ef9 <memmove+0x48>
    s += n;
    d += n;
  800ec2:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ec6:	48 89 fe             	mov    %rdi,%rsi
  800ec9:	48 09 d6             	or     %rdx,%rsi
  800ecc:	48 09 ce             	or     %rcx,%rsi
  800ecf:	40 f6 c6 03          	test   $0x3,%sil
  800ed3:	75 14                	jne    800ee9 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800ed5:	48 83 ef 04          	sub    $0x4,%rdi
  800ed9:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800edd:	48 c1 ea 02          	shr    $0x2,%rdx
  800ee1:	48 89 d1             	mov    %rdx,%rcx
  800ee4:	fd                   	std    
  800ee5:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800ee7:	eb 0e                	jmp    800ef7 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800ee9:	48 83 ef 01          	sub    $0x1,%rdi
  800eed:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800ef1:	48 89 d1             	mov    %rdx,%rcx
  800ef4:	fd                   	std    
  800ef5:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800ef7:	fc                   	cld    
  800ef8:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ef9:	48 89 c1             	mov    %rax,%rcx
  800efc:	48 09 d1             	or     %rdx,%rcx
  800eff:	48 09 f1             	or     %rsi,%rcx
  800f02:	f6 c1 03             	test   $0x3,%cl
  800f05:	75 0e                	jne    800f15 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f07:	48 c1 ea 02          	shr    $0x2,%rdx
  800f0b:	48 89 d1             	mov    %rdx,%rcx
  800f0e:	48 89 c7             	mov    %rax,%rdi
  800f11:	fc                   	cld    
  800f12:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f14:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f15:	48 89 c7             	mov    %rax,%rdi
  800f18:	48 89 d1             	mov    %rdx,%rcx
  800f1b:	fc                   	cld    
  800f1c:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f1e:	c3                   	retq   

0000000000800f1f <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f1f:	55                   	push   %rbp
  800f20:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f23:	48 b8 b1 0e 80 00 00 	movabs $0x800eb1,%rax
  800f2a:	00 00 00 
  800f2d:	ff d0                	callq  *%rax
}
  800f2f:	5d                   	pop    %rbp
  800f30:	c3                   	retq   

0000000000800f31 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f31:	55                   	push   %rbp
  800f32:	48 89 e5             	mov    %rsp,%rbp
  800f35:	41 57                	push   %r15
  800f37:	41 56                	push   %r14
  800f39:	41 55                	push   %r13
  800f3b:	41 54                	push   %r12
  800f3d:	53                   	push   %rbx
  800f3e:	48 83 ec 08          	sub    $0x8,%rsp
  800f42:	49 89 fe             	mov    %rdi,%r14
  800f45:	49 89 f7             	mov    %rsi,%r15
  800f48:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f4b:	48 89 f7             	mov    %rsi,%rdi
  800f4e:	48 b8 a6 0c 80 00 00 	movabs $0x800ca6,%rax
  800f55:	00 00 00 
  800f58:	ff d0                	callq  *%rax
  800f5a:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f5d:	4c 89 ee             	mov    %r13,%rsi
  800f60:	4c 89 f7             	mov    %r14,%rdi
  800f63:	48 b8 c8 0c 80 00 00 	movabs $0x800cc8,%rax
  800f6a:	00 00 00 
  800f6d:	ff d0                	callq  *%rax
  800f6f:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f72:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f76:	4d 39 e5             	cmp    %r12,%r13
  800f79:	74 26                	je     800fa1 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f7b:	4c 89 e8             	mov    %r13,%rax
  800f7e:	4c 29 e0             	sub    %r12,%rax
  800f81:	48 39 d8             	cmp    %rbx,%rax
  800f84:	76 2a                	jbe    800fb0 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f86:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f8a:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f8e:	4c 89 fe             	mov    %r15,%rsi
  800f91:	48 b8 1f 0f 80 00 00 	movabs $0x800f1f,%rax
  800f98:	00 00 00 
  800f9b:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f9d:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fa1:	48 83 c4 08          	add    $0x8,%rsp
  800fa5:	5b                   	pop    %rbx
  800fa6:	41 5c                	pop    %r12
  800fa8:	41 5d                	pop    %r13
  800faa:	41 5e                	pop    %r14
  800fac:	41 5f                	pop    %r15
  800fae:	5d                   	pop    %rbp
  800faf:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fb0:	49 83 ed 01          	sub    $0x1,%r13
  800fb4:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fb8:	4c 89 ea             	mov    %r13,%rdx
  800fbb:	4c 89 fe             	mov    %r15,%rsi
  800fbe:	48 b8 1f 0f 80 00 00 	movabs $0x800f1f,%rax
  800fc5:	00 00 00 
  800fc8:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fca:	4d 01 ee             	add    %r13,%r14
  800fcd:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fd2:	eb c9                	jmp    800f9d <strlcat+0x6c>

0000000000800fd4 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fd4:	48 85 d2             	test   %rdx,%rdx
  800fd7:	74 3a                	je     801013 <memcmp+0x3f>
    if (*s1 != *s2)
  800fd9:	0f b6 0f             	movzbl (%rdi),%ecx
  800fdc:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fe0:	44 38 c1             	cmp    %r8b,%cl
  800fe3:	75 1d                	jne    801002 <memcmp+0x2e>
  800fe5:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fea:	48 39 d0             	cmp    %rdx,%rax
  800fed:	74 1e                	je     80100d <memcmp+0x39>
    if (*s1 != *s2)
  800fef:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ff3:	48 83 c0 01          	add    $0x1,%rax
  800ff7:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ffd:	44 38 c1             	cmp    %r8b,%cl
  801000:	74 e8                	je     800fea <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801002:	0f b6 c1             	movzbl %cl,%eax
  801005:	45 0f b6 c0          	movzbl %r8b,%r8d
  801009:	44 29 c0             	sub    %r8d,%eax
  80100c:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
  801012:	c3                   	retq   
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801018:	c3                   	retq   

0000000000801019 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801019:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80101d:	48 39 c7             	cmp    %rax,%rdi
  801020:	73 19                	jae    80103b <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801022:	89 f2                	mov    %esi,%edx
  801024:	40 38 37             	cmp    %sil,(%rdi)
  801027:	74 16                	je     80103f <memfind+0x26>
  for (; s < ends; s++)
  801029:	48 83 c7 01          	add    $0x1,%rdi
  80102d:	48 39 f8             	cmp    %rdi,%rax
  801030:	74 08                	je     80103a <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801032:	38 17                	cmp    %dl,(%rdi)
  801034:	75 f3                	jne    801029 <memfind+0x10>
  for (; s < ends; s++)
  801036:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801039:	c3                   	retq   
  80103a:	c3                   	retq   
  for (; s < ends; s++)
  80103b:	48 89 f8             	mov    %rdi,%rax
  80103e:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80103f:	48 89 f8             	mov    %rdi,%rax
  801042:	c3                   	retq   

0000000000801043 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801043:	0f b6 07             	movzbl (%rdi),%eax
  801046:	3c 20                	cmp    $0x20,%al
  801048:	74 04                	je     80104e <strtol+0xb>
  80104a:	3c 09                	cmp    $0x9,%al
  80104c:	75 0f                	jne    80105d <strtol+0x1a>
    s++;
  80104e:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801052:	0f b6 07             	movzbl (%rdi),%eax
  801055:	3c 20                	cmp    $0x20,%al
  801057:	74 f5                	je     80104e <strtol+0xb>
  801059:	3c 09                	cmp    $0x9,%al
  80105b:	74 f1                	je     80104e <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80105d:	3c 2b                	cmp    $0x2b,%al
  80105f:	74 2b                	je     80108c <strtol+0x49>
  int neg  = 0;
  801061:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801067:	3c 2d                	cmp    $0x2d,%al
  801069:	74 2d                	je     801098 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80106b:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801071:	75 0f                	jne    801082 <strtol+0x3f>
  801073:	80 3f 30             	cmpb   $0x30,(%rdi)
  801076:	74 2c                	je     8010a4 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801078:	85 d2                	test   %edx,%edx
  80107a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107f:	0f 44 d0             	cmove  %eax,%edx
  801082:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801087:	4c 63 d2             	movslq %edx,%r10
  80108a:	eb 5c                	jmp    8010e8 <strtol+0xa5>
    s++;
  80108c:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801090:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801096:	eb d3                	jmp    80106b <strtol+0x28>
    s++, neg = 1;
  801098:	48 83 c7 01          	add    $0x1,%rdi
  80109c:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010a2:	eb c7                	jmp    80106b <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010a4:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010a8:	74 0f                	je     8010b9 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010aa:	85 d2                	test   %edx,%edx
  8010ac:	75 d4                	jne    801082 <strtol+0x3f>
    s++, base = 8;
  8010ae:	48 83 c7 01          	add    $0x1,%rdi
  8010b2:	ba 08 00 00 00       	mov    $0x8,%edx
  8010b7:	eb c9                	jmp    801082 <strtol+0x3f>
    s += 2, base = 16;
  8010b9:	48 83 c7 02          	add    $0x2,%rdi
  8010bd:	ba 10 00 00 00       	mov    $0x10,%edx
  8010c2:	eb be                	jmp    801082 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010c4:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010c8:	41 80 f8 19          	cmp    $0x19,%r8b
  8010cc:	77 2f                	ja     8010fd <strtol+0xba>
      dig = *s - 'a' + 10;
  8010ce:	44 0f be c1          	movsbl %cl,%r8d
  8010d2:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010d6:	39 d1                	cmp    %edx,%ecx
  8010d8:	7d 37                	jge    801111 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010da:	48 83 c7 01          	add    $0x1,%rdi
  8010de:	49 0f af c2          	imul   %r10,%rax
  8010e2:	48 63 c9             	movslq %ecx,%rcx
  8010e5:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010e8:	0f b6 0f             	movzbl (%rdi),%ecx
  8010eb:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010ef:	41 80 f8 09          	cmp    $0x9,%r8b
  8010f3:	77 cf                	ja     8010c4 <strtol+0x81>
      dig = *s - '0';
  8010f5:	0f be c9             	movsbl %cl,%ecx
  8010f8:	83 e9 30             	sub    $0x30,%ecx
  8010fb:	eb d9                	jmp    8010d6 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8010fd:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801101:	41 80 f8 19          	cmp    $0x19,%r8b
  801105:	77 0a                	ja     801111 <strtol+0xce>
      dig = *s - 'A' + 10;
  801107:	44 0f be c1          	movsbl %cl,%r8d
  80110b:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80110f:	eb c5                	jmp    8010d6 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801111:	48 85 f6             	test   %rsi,%rsi
  801114:	74 03                	je     801119 <strtol+0xd6>
    *endptr = (char *)s;
  801116:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801119:	48 89 c2             	mov    %rax,%rdx
  80111c:	48 f7 da             	neg    %rdx
  80111f:	45 85 c9             	test   %r9d,%r9d
  801122:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801126:	c3                   	retq   
  801127:	90                   	nop
