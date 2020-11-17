
obj/user/faultreadkernel:     file format elf64-x86-64


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
  800023:	e8 2f 00 00 00       	callq  800057 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// buggy program - faults with a read from kernel space

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  cprintf("I read %08x from location 0x8040000000!\n", *(unsigned *)0x8040000000);
  80002e:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  800035:	00 00 00 
  800038:	8b 30                	mov    (%rax),%esi
  80003a:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  800041:	00 00 00 
  800044:	b8 00 00 00 00       	mov    $0x0,%eax
  800049:	48 ba da 01 80 00 00 	movabs $0x8001da,%rdx
  800050:	00 00 00 
  800053:	ff d2                	callq  *%rdx
}
  800055:	5d                   	pop    %rbp
  800056:	c3                   	retq   

0000000000800057 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800057:	55                   	push   %rbp
  800058:	48 89 e5             	mov    %rsp,%rbp
  80005b:	41 56                	push   %r14
  80005d:	41 55                	push   %r13
  80005f:	41 54                	push   %r12
  800061:	53                   	push   %rbx
  800062:	41 89 fd             	mov    %edi,%r13d
  800065:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800068:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80006f:	00 00 00 
  800072:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800079:	00 00 00 
  80007c:	48 39 c2             	cmp    %rax,%rdx
  80007f:	73 23                	jae    8000a4 <libmain+0x4d>
  800081:	48 89 d3             	mov    %rdx,%rbx
  800084:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800088:	48 29 d0             	sub    %rdx,%rax
  80008b:	48 c1 e8 03          	shr    $0x3,%rax
  80008f:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
  800099:	ff 13                	callq  *(%rbx)
    ctor++;
  80009b:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80009f:	4c 39 e3             	cmp    %r12,%rbx
  8000a2:	75 f0                	jne    800094 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  8000a4:	48 b8 6c 10 80 00 00 	movabs $0x80106c,%rax
  8000ab:	00 00 00 
  8000ae:	ff d0                	callq  *%rax
  8000b0:	83 e0 1f             	and    $0x1f,%eax
  8000b3:	48 89 c2             	mov    %rax,%rdx
  8000b6:	48 c1 e2 05          	shl    $0x5,%rdx
  8000ba:	48 29 c2             	sub    %rax,%rdx
  8000bd:	48 89 d0             	mov    %rdx,%rax
  8000c0:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000c7:	00 00 00 
  8000ca:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000ce:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000d5:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000d8:	45 85 ed             	test   %r13d,%r13d
  8000db:	7e 0d                	jle    8000ea <libmain+0x93>
    binaryname = argv[0];
  8000dd:	49 8b 06             	mov    (%r14),%rax
  8000e0:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000e7:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000ea:	4c 89 f6             	mov    %r14,%rsi
  8000ed:	44 89 ef             	mov    %r13d,%edi
  8000f0:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f7:	00 00 00 
  8000fa:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000fc:	48 b8 11 01 80 00 00 	movabs $0x800111,%rax
  800103:	00 00 00 
  800106:	ff d0                	callq  *%rax
#endif
}
  800108:	5b                   	pop    %rbx
  800109:	41 5c                	pop    %r12
  80010b:	41 5d                	pop    %r13
  80010d:	41 5e                	pop    %r14
  80010f:	5d                   	pop    %rbp
  800110:	c3                   	retq   

0000000000800111 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800111:	55                   	push   %rbp
  800112:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800115:	bf 00 00 00 00       	mov    $0x0,%edi
  80011a:	48 b8 0c 10 80 00 00 	movabs $0x80100c,%rax
  800121:	00 00 00 
  800124:	ff d0                	callq  *%rax
}
  800126:	5d                   	pop    %rbp
  800127:	c3                   	retq   

0000000000800128 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800128:	55                   	push   %rbp
  800129:	48 89 e5             	mov    %rsp,%rbp
  80012c:	53                   	push   %rbx
  80012d:	48 83 ec 08          	sub    $0x8,%rsp
  800131:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800134:	8b 06                	mov    (%rsi),%eax
  800136:	8d 50 01             	lea    0x1(%rax),%edx
  800139:	89 16                	mov    %edx,(%rsi)
  80013b:	48 98                	cltq   
  80013d:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800142:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800148:	74 0b                	je     800155 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80014a:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80014e:	48 83 c4 08          	add    $0x8,%rsp
  800152:	5b                   	pop    %rbx
  800153:	5d                   	pop    %rbp
  800154:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800155:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800159:	be ff 00 00 00       	mov    $0xff,%esi
  80015e:	48 b8 ce 0f 80 00 00 	movabs $0x800fce,%rax
  800165:	00 00 00 
  800168:	ff d0                	callq  *%rax
    b->idx = 0;
  80016a:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800170:	eb d8                	jmp    80014a <putch+0x22>

0000000000800172 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800172:	55                   	push   %rbp
  800173:	48 89 e5             	mov    %rsp,%rbp
  800176:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80017d:	48 89 fa             	mov    %rdi,%rdx
  800180:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800183:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80018a:	00 00 00 
  b.cnt = 0;
  80018d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800194:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800197:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80019e:	48 bf 28 01 80 00 00 	movabs $0x800128,%rdi
  8001a5:	00 00 00 
  8001a8:	48 b8 98 03 80 00 00 	movabs $0x800398,%rax
  8001af:	00 00 00 
  8001b2:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001b4:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001bb:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001c2:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001c6:	48 b8 ce 0f 80 00 00 	movabs $0x800fce,%rax
  8001cd:	00 00 00 
  8001d0:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001d8:	c9                   	leaveq 
  8001d9:	c3                   	retq   

00000000008001da <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001da:	55                   	push   %rbp
  8001db:	48 89 e5             	mov    %rsp,%rbp
  8001de:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001e5:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001ec:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001f3:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001fa:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800201:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800208:	84 c0                	test   %al,%al
  80020a:	74 20                	je     80022c <cprintf+0x52>
  80020c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800210:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800214:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800218:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80021c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800220:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800224:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800228:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80022c:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800233:	00 00 00 
  800236:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80023d:	00 00 00 
  800240:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800244:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80024b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800252:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800259:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800260:	48 b8 72 01 80 00 00 	movabs $0x800172,%rax
  800267:	00 00 00 
  80026a:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80026c:	c9                   	leaveq 
  80026d:	c3                   	retq   

000000000080026e <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80026e:	55                   	push   %rbp
  80026f:	48 89 e5             	mov    %rsp,%rbp
  800272:	41 57                	push   %r15
  800274:	41 56                	push   %r14
  800276:	41 55                	push   %r13
  800278:	41 54                	push   %r12
  80027a:	53                   	push   %rbx
  80027b:	48 83 ec 18          	sub    $0x18,%rsp
  80027f:	49 89 fc             	mov    %rdi,%r12
  800282:	49 89 f5             	mov    %rsi,%r13
  800285:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800289:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80028c:	41 89 cf             	mov    %ecx,%r15d
  80028f:	49 39 d7             	cmp    %rdx,%r15
  800292:	76 45                	jbe    8002d9 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800294:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800298:	85 db                	test   %ebx,%ebx
  80029a:	7e 0e                	jle    8002aa <printnum+0x3c>
      putch(padc, putdat);
  80029c:	4c 89 ee             	mov    %r13,%rsi
  80029f:	44 89 f7             	mov    %r14d,%edi
  8002a2:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	75 f2                	jne    80029c <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002aa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b3:	49 f7 f7             	div    %r15
  8002b6:	48 b8 b3 11 80 00 00 	movabs $0x8011b3,%rax
  8002bd:	00 00 00 
  8002c0:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002c4:	4c 89 ee             	mov    %r13,%rsi
  8002c7:	41 ff d4             	callq  *%r12
}
  8002ca:	48 83 c4 18          	add    $0x18,%rsp
  8002ce:	5b                   	pop    %rbx
  8002cf:	41 5c                	pop    %r12
  8002d1:	41 5d                	pop    %r13
  8002d3:	41 5e                	pop    %r14
  8002d5:	41 5f                	pop    %r15
  8002d7:	5d                   	pop    %rbp
  8002d8:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	49 f7 f7             	div    %r15
  8002e5:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002e9:	48 89 c2             	mov    %rax,%rdx
  8002ec:	48 b8 6e 02 80 00 00 	movabs $0x80026e,%rax
  8002f3:	00 00 00 
  8002f6:	ff d0                	callq  *%rax
  8002f8:	eb b0                	jmp    8002aa <printnum+0x3c>

00000000008002fa <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002fa:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002fe:	48 8b 06             	mov    (%rsi),%rax
  800301:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800305:	73 0a                	jae    800311 <sprintputch+0x17>
    *b->buf++ = ch;
  800307:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80030b:	48 89 16             	mov    %rdx,(%rsi)
  80030e:	40 88 38             	mov    %dil,(%rax)
}
  800311:	c3                   	retq   

0000000000800312 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800312:	55                   	push   %rbp
  800313:	48 89 e5             	mov    %rsp,%rbp
  800316:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80031d:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800324:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80032b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800332:	84 c0                	test   %al,%al
  800334:	74 20                	je     800356 <printfmt+0x44>
  800336:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80033a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80033e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800342:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800346:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80034a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80034e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800352:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800356:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80035d:	00 00 00 
  800360:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800367:	00 00 00 
  80036a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80036e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800375:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80037c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800383:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80038a:	48 b8 98 03 80 00 00 	movabs $0x800398,%rax
  800391:	00 00 00 
  800394:	ff d0                	callq  *%rax
}
  800396:	c9                   	leaveq 
  800397:	c3                   	retq   

0000000000800398 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800398:	55                   	push   %rbp
  800399:	48 89 e5             	mov    %rsp,%rbp
  80039c:	41 57                	push   %r15
  80039e:	41 56                	push   %r14
  8003a0:	41 55                	push   %r13
  8003a2:	41 54                	push   %r12
  8003a4:	53                   	push   %rbx
  8003a5:	48 83 ec 48          	sub    $0x48,%rsp
  8003a9:	49 89 fd             	mov    %rdi,%r13
  8003ac:	49 89 f7             	mov    %rsi,%r15
  8003af:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003b2:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003b6:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003ba:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003be:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003c2:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003c6:	41 0f b6 3e          	movzbl (%r14),%edi
  8003ca:	83 ff 25             	cmp    $0x25,%edi
  8003cd:	74 18                	je     8003e7 <vprintfmt+0x4f>
      if (ch == '\0')
  8003cf:	85 ff                	test   %edi,%edi
  8003d1:	0f 84 8c 06 00 00    	je     800a63 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003d7:	4c 89 fe             	mov    %r15,%rsi
  8003da:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003dd:	49 89 de             	mov    %rbx,%r14
  8003e0:	eb e0                	jmp    8003c2 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003e2:	49 89 de             	mov    %rbx,%r14
  8003e5:	eb db                	jmp    8003c2 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003e7:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003eb:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003ef:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003f6:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003fc:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800400:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800405:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80040b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800411:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800416:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80041b:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80041f:	0f b6 13             	movzbl (%rbx),%edx
  800422:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800425:	3c 55                	cmp    $0x55,%al
  800427:	0f 87 8b 05 00 00    	ja     8009b8 <vprintfmt+0x620>
  80042d:	0f b6 c0             	movzbl %al,%eax
  800430:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800437:	00 00 00 
  80043a:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80043e:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800441:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800445:	eb d4                	jmp    80041b <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800447:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80044a:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80044e:	eb cb                	jmp    80041b <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800450:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800453:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800457:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80045b:	8d 50 d0             	lea    -0x30(%rax),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 7e                	ja     8004e1 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800463:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800467:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80046b:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800470:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800474:	8d 50 d0             	lea    -0x30(%rax),%edx
  800477:	83 fa 09             	cmp    $0x9,%edx
  80047a:	76 e7                	jbe    800463 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80047c:	4c 89 f3             	mov    %r14,%rbx
  80047f:	eb 19                	jmp    80049a <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800481:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800484:	83 f8 2f             	cmp    $0x2f,%eax
  800487:	77 2a                	ja     8004b3 <vprintfmt+0x11b>
  800489:	89 c2                	mov    %eax,%edx
  80048b:	4c 01 d2             	add    %r10,%rdx
  80048e:	83 c0 08             	add    $0x8,%eax
  800491:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800494:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800497:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80049a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80049e:	0f 89 77 ff ff ff    	jns    80041b <vprintfmt+0x83>
          width = precision, precision = -1;
  8004a4:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004a8:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004ae:	e9 68 ff ff ff       	jmpq   80041b <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004b3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004b7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004bb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004bf:	eb d3                	jmp    800494 <vprintfmt+0xfc>
        if (width < 0)
  8004c1:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004ca:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004cd:	4c 89 f3             	mov    %r14,%rbx
  8004d0:	e9 46 ff ff ff       	jmpq   80041b <vprintfmt+0x83>
  8004d5:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004d8:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004dc:	e9 3a ff ff ff       	jmpq   80041b <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004e1:	4c 89 f3             	mov    %r14,%rbx
  8004e4:	eb b4                	jmp    80049a <vprintfmt+0x102>
        lflag++;
  8004e6:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004e9:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004ec:	e9 2a ff ff ff       	jmpq   80041b <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004f4:	83 f8 2f             	cmp    $0x2f,%eax
  8004f7:	77 19                	ja     800512 <vprintfmt+0x17a>
  8004f9:	89 c2                	mov    %eax,%edx
  8004fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004ff:	83 c0 08             	add    $0x8,%eax
  800502:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800505:	4c 89 fe             	mov    %r15,%rsi
  800508:	8b 3a                	mov    (%rdx),%edi
  80050a:	41 ff d5             	callq  *%r13
        break;
  80050d:	e9 b0 fe ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800512:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800516:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80051a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80051e:	eb e5                	jmp    800505 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800520:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800523:	83 f8 2f             	cmp    $0x2f,%eax
  800526:	77 5b                	ja     800583 <vprintfmt+0x1eb>
  800528:	89 c2                	mov    %eax,%edx
  80052a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80052e:	83 c0 08             	add    $0x8,%eax
  800531:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800534:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800536:	89 c8                	mov    %ecx,%eax
  800538:	c1 f8 1f             	sar    $0x1f,%eax
  80053b:	31 c1                	xor    %eax,%ecx
  80053d:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053f:	83 f9 09             	cmp    $0x9,%ecx
  800542:	7f 4d                	jg     800591 <vprintfmt+0x1f9>
  800544:	48 63 c1             	movslq %ecx,%rax
  800547:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  80054e:	00 00 00 
  800551:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800555:	48 85 c0             	test   %rax,%rax
  800558:	74 37                	je     800591 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80055a:	48 89 c1             	mov    %rax,%rcx
  80055d:	48 ba d4 11 80 00 00 	movabs $0x8011d4,%rdx
  800564:	00 00 00 
  800567:	4c 89 fe             	mov    %r15,%rsi
  80056a:	4c 89 ef             	mov    %r13,%rdi
  80056d:	b8 00 00 00 00       	mov    $0x0,%eax
  800572:	48 bb 12 03 80 00 00 	movabs $0x800312,%rbx
  800579:	00 00 00 
  80057c:	ff d3                	callq  *%rbx
  80057e:	e9 3f fe ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800583:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800587:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80058b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80058f:	eb a3                	jmp    800534 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800591:	48 ba cb 11 80 00 00 	movabs $0x8011cb,%rdx
  800598:	00 00 00 
  80059b:	4c 89 fe             	mov    %r15,%rsi
  80059e:	4c 89 ef             	mov    %r13,%rdi
  8005a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a6:	48 bb 12 03 80 00 00 	movabs $0x800312,%rbx
  8005ad:	00 00 00 
  8005b0:	ff d3                	callq  *%rbx
  8005b2:	e9 0b fe ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005b7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005ba:	83 f8 2f             	cmp    $0x2f,%eax
  8005bd:	77 4b                	ja     80060a <vprintfmt+0x272>
  8005bf:	89 c2                	mov    %eax,%edx
  8005c1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005c5:	83 c0 08             	add    $0x8,%eax
  8005c8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005cb:	48 8b 02             	mov    (%rdx),%rax
  8005ce:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005d2:	48 85 c0             	test   %rax,%rax
  8005d5:	0f 84 05 04 00 00    	je     8009e0 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005db:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005df:	7e 06                	jle    8005e7 <vprintfmt+0x24f>
  8005e1:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005e5:	75 31                	jne    800618 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005eb:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005ef:	0f b6 00             	movzbl (%rax),%eax
  8005f2:	0f be f8             	movsbl %al,%edi
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	0f 84 c3 00 00 00    	je     8006c0 <vprintfmt+0x328>
  8005fd:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800601:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800605:	e9 85 00 00 00       	jmpq   80068f <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80060a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80060e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800612:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800616:	eb b3                	jmp    8005cb <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800618:	49 63 f4             	movslq %r12d,%rsi
  80061b:	48 89 c7             	mov    %rax,%rdi
  80061e:	48 b8 6f 0b 80 00 00 	movabs $0x800b6f,%rax
  800625:	00 00 00 
  800628:	ff d0                	callq  *%rax
  80062a:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80062d:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800630:	85 f6                	test   %esi,%esi
  800632:	7e 22                	jle    800656 <vprintfmt+0x2be>
            putch(padc, putdat);
  800634:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800638:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80063c:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800640:	4c 89 fe             	mov    %r15,%rsi
  800643:	89 df                	mov    %ebx,%edi
  800645:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800648:	41 83 ec 01          	sub    $0x1,%r12d
  80064c:	75 f2                	jne    800640 <vprintfmt+0x2a8>
  80064e:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800652:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800656:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80065a:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80065e:	0f b6 00             	movzbl (%rax),%eax
  800661:	0f be f8             	movsbl %al,%edi
  800664:	85 ff                	test   %edi,%edi
  800666:	0f 84 56 fd ff ff    	je     8003c2 <vprintfmt+0x2a>
  80066c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800670:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800674:	eb 19                	jmp    80068f <vprintfmt+0x2f7>
            putch(ch, putdat);
  800676:	4c 89 fe             	mov    %r15,%rsi
  800679:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067c:	41 83 ee 01          	sub    $0x1,%r14d
  800680:	48 83 c3 01          	add    $0x1,%rbx
  800684:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800688:	0f be f8             	movsbl %al,%edi
  80068b:	85 ff                	test   %edi,%edi
  80068d:	74 29                	je     8006b8 <vprintfmt+0x320>
  80068f:	45 85 e4             	test   %r12d,%r12d
  800692:	78 06                	js     80069a <vprintfmt+0x302>
  800694:	41 83 ec 01          	sub    $0x1,%r12d
  800698:	78 48                	js     8006e2 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80069e:	74 d6                	je     800676 <vprintfmt+0x2de>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 cb                	jbe    800676 <vprintfmt+0x2de>
            putch('?', putdat);
  8006ab:	4c 89 fe             	mov    %r15,%rsi
  8006ae:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006b3:	41 ff d5             	callq  *%r13
  8006b6:	eb c4                	jmp    80067c <vprintfmt+0x2e4>
  8006b8:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006bc:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006c0:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006c3:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006c7:	0f 8e f5 fc ff ff    	jle    8003c2 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006cd:	4c 89 fe             	mov    %r15,%rsi
  8006d0:	bf 20 00 00 00       	mov    $0x20,%edi
  8006d5:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006d8:	83 eb 01             	sub    $0x1,%ebx
  8006db:	75 f0                	jne    8006cd <vprintfmt+0x335>
  8006dd:	e9 e0 fc ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
  8006e2:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006e6:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006ea:	eb d4                	jmp    8006c0 <vprintfmt+0x328>
  if (lflag >= 2)
  8006ec:	83 f9 01             	cmp    $0x1,%ecx
  8006ef:	7f 1d                	jg     80070e <vprintfmt+0x376>
  else if (lflag)
  8006f1:	85 c9                	test   %ecx,%ecx
  8006f3:	74 5e                	je     800753 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006f5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006f8:	83 f8 2f             	cmp    $0x2f,%eax
  8006fb:	77 48                	ja     800745 <vprintfmt+0x3ad>
  8006fd:	89 c2                	mov    %eax,%edx
  8006ff:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800703:	83 c0 08             	add    $0x8,%eax
  800706:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800709:	48 8b 1a             	mov    (%rdx),%rbx
  80070c:	eb 17                	jmp    800725 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80070e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800711:	83 f8 2f             	cmp    $0x2f,%eax
  800714:	77 21                	ja     800737 <vprintfmt+0x39f>
  800716:	89 c2                	mov    %eax,%edx
  800718:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80071c:	83 c0 08             	add    $0x8,%eax
  80071f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800722:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800725:	48 85 db             	test   %rbx,%rbx
  800728:	78 50                	js     80077a <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80072a:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80072d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800732:	e9 b4 01 00 00       	jmpq   8008eb <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800737:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80073b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80073f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800743:	eb dd                	jmp    800722 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800745:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800749:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80074d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800751:	eb b6                	jmp    800709 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800753:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800756:	83 f8 2f             	cmp    $0x2f,%eax
  800759:	77 11                	ja     80076c <vprintfmt+0x3d4>
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800761:	83 c0 08             	add    $0x8,%eax
  800764:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800767:	48 63 1a             	movslq (%rdx),%rbx
  80076a:	eb b9                	jmp    800725 <vprintfmt+0x38d>
  80076c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800770:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800774:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800778:	eb ed                	jmp    800767 <vprintfmt+0x3cf>
          putch('-', putdat);
  80077a:	4c 89 fe             	mov    %r15,%rsi
  80077d:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800782:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800785:	48 89 da             	mov    %rbx,%rdx
  800788:	48 f7 da             	neg    %rdx
        base = 10;
  80078b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800790:	e9 56 01 00 00       	jmpq   8008eb <vprintfmt+0x553>
  if (lflag >= 2)
  800795:	83 f9 01             	cmp    $0x1,%ecx
  800798:	7f 25                	jg     8007bf <vprintfmt+0x427>
  else if (lflag)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	74 5e                	je     8007fc <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80079e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007a1:	83 f8 2f             	cmp    $0x2f,%eax
  8007a4:	77 48                	ja     8007ee <vprintfmt+0x456>
  8007a6:	89 c2                	mov    %eax,%edx
  8007a8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ac:	83 c0 08             	add    $0x8,%eax
  8007af:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007b2:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ba:	e9 2c 01 00 00       	jmpq   8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007bf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c2:	83 f8 2f             	cmp    $0x2f,%eax
  8007c5:	77 19                	ja     8007e0 <vprintfmt+0x448>
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007cd:	83 c0 08             	add    $0x8,%eax
  8007d0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d3:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007db:	e9 0b 01 00 00       	jmpq   8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007e0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007ec:	eb e5                	jmp    8007d3 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007ee:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007f2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007f6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007fa:	eb b6                	jmp    8007b2 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007fc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007ff:	83 f8 2f             	cmp    $0x2f,%eax
  800802:	77 18                	ja     80081c <vprintfmt+0x484>
  800804:	89 c2                	mov    %eax,%edx
  800806:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80080a:	83 c0 08             	add    $0x8,%eax
  80080d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800810:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800812:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800817:	e9 cf 00 00 00       	jmpq   8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80081c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800820:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800824:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800828:	eb e6                	jmp    800810 <vprintfmt+0x478>
  if (lflag >= 2)
  80082a:	83 f9 01             	cmp    $0x1,%ecx
  80082d:	7f 25                	jg     800854 <vprintfmt+0x4bc>
  else if (lflag)
  80082f:	85 c9                	test   %ecx,%ecx
  800831:	74 5b                	je     80088e <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800833:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800836:	83 f8 2f             	cmp    $0x2f,%eax
  800839:	77 45                	ja     800880 <vprintfmt+0x4e8>
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800841:	83 c0 08             	add    $0x8,%eax
  800844:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800847:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80084a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80084f:	e9 97 00 00 00       	jmpq   8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800854:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800857:	83 f8 2f             	cmp    $0x2f,%eax
  80085a:	77 16                	ja     800872 <vprintfmt+0x4da>
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800862:	83 c0 08             	add    $0x8,%eax
  800865:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800868:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80086b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800870:	eb 79                	jmp    8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800872:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800876:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80087e:	eb e8                	jmp    800868 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800880:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800884:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800888:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80088c:	eb b9                	jmp    800847 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  80088e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800891:	83 f8 2f             	cmp    $0x2f,%eax
  800894:	77 15                	ja     8008ab <vprintfmt+0x513>
  800896:	89 c2                	mov    %eax,%edx
  800898:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80089c:	83 c0 08             	add    $0x8,%eax
  80089f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a2:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008a4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008a9:	eb 40                	jmp    8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008ab:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008af:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b7:	eb e9                	jmp    8008a2 <vprintfmt+0x50a>
        putch('0', putdat);
  8008b9:	4c 89 fe             	mov    %r15,%rsi
  8008bc:	bf 30 00 00 00       	mov    $0x30,%edi
  8008c1:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008c4:	4c 89 fe             	mov    %r15,%rsi
  8008c7:	bf 78 00 00 00       	mov    $0x78,%edi
  8008cc:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008cf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d2:	83 f8 2f             	cmp    $0x2f,%eax
  8008d5:	77 34                	ja     80090b <vprintfmt+0x573>
  8008d7:	89 c2                	mov    %eax,%edx
  8008d9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008dd:	83 c0 08             	add    $0x8,%eax
  8008e0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008e3:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008e6:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008eb:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008f0:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008f4:	4c 89 fe             	mov    %r15,%rsi
  8008f7:	4c 89 ef             	mov    %r13,%rdi
  8008fa:	48 b8 6e 02 80 00 00 	movabs $0x80026e,%rax
  800901:	00 00 00 
  800904:	ff d0                	callq  *%rax
        break;
  800906:	e9 b7 fa ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80090b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800913:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800917:	eb ca                	jmp    8008e3 <vprintfmt+0x54b>
  if (lflag >= 2)
  800919:	83 f9 01             	cmp    $0x1,%ecx
  80091c:	7f 22                	jg     800940 <vprintfmt+0x5a8>
  else if (lflag)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 58                	je     80097a <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800922:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800925:	83 f8 2f             	cmp    $0x2f,%eax
  800928:	77 42                	ja     80096c <vprintfmt+0x5d4>
  80092a:	89 c2                	mov    %eax,%edx
  80092c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800930:	83 c0 08             	add    $0x8,%eax
  800933:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800936:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800939:	b9 10 00 00 00       	mov    $0x10,%ecx
  80093e:	eb ab                	jmp    8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800940:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800943:	83 f8 2f             	cmp    $0x2f,%eax
  800946:	77 16                	ja     80095e <vprintfmt+0x5c6>
  800948:	89 c2                	mov    %eax,%edx
  80094a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094e:	83 c0 08             	add    $0x8,%eax
  800951:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800954:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800957:	b9 10 00 00 00       	mov    $0x10,%ecx
  80095c:	eb 8d                	jmp    8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80095e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800962:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800966:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096a:	eb e8                	jmp    800954 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  80096c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800970:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800974:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800978:	eb bc                	jmp    800936 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  80097a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80097d:	83 f8 2f             	cmp    $0x2f,%eax
  800980:	77 18                	ja     80099a <vprintfmt+0x602>
  800982:	89 c2                	mov    %eax,%edx
  800984:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800988:	83 c0 08             	add    $0x8,%eax
  80098b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80098e:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800990:	b9 10 00 00 00       	mov    $0x10,%ecx
  800995:	e9 51 ff ff ff       	jmpq   8008eb <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80099a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80099e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a6:	eb e6                	jmp    80098e <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009a8:	4c 89 fe             	mov    %r15,%rsi
  8009ab:	bf 25 00 00 00       	mov    $0x25,%edi
  8009b0:	41 ff d5             	callq  *%r13
        break;
  8009b3:	e9 0a fa ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
        putch('%', putdat);
  8009b8:	4c 89 fe             	mov    %r15,%rsi
  8009bb:	bf 25 00 00 00       	mov    $0x25,%edi
  8009c0:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009c3:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009c7:	0f 84 15 fa ff ff    	je     8003e2 <vprintfmt+0x4a>
  8009cd:	49 89 de             	mov    %rbx,%r14
  8009d0:	49 83 ee 01          	sub    $0x1,%r14
  8009d4:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009d9:	75 f5                	jne    8009d0 <vprintfmt+0x638>
  8009db:	e9 e2 f9 ff ff       	jmpq   8003c2 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009e0:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009e4:	74 06                	je     8009ec <vprintfmt+0x654>
  8009e6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009ea:	7f 21                	jg     800a0d <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ec:	bf 28 00 00 00       	mov    $0x28,%edi
  8009f1:	48 bb c5 11 80 00 00 	movabs $0x8011c5,%rbx
  8009f8:	00 00 00 
  8009fb:	b8 28 00 00 00       	mov    $0x28,%eax
  800a00:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a04:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a08:	e9 82 fc ff ff       	jmpq   80068f <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a0d:	49 63 f4             	movslq %r12d,%rsi
  800a10:	48 bf c4 11 80 00 00 	movabs $0x8011c4,%rdi
  800a17:	00 00 00 
  800a1a:	48 b8 6f 0b 80 00 00 	movabs $0x800b6f,%rax
  800a21:	00 00 00 
  800a24:	ff d0                	callq  *%rax
  800a26:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a29:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a2c:	48 be c4 11 80 00 00 	movabs $0x8011c4,%rsi
  800a33:	00 00 00 
  800a36:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	0f 8f f2 fb ff ff    	jg     800634 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a42:	48 bb c5 11 80 00 00 	movabs $0x8011c5,%rbx
  800a49:	00 00 00 
  800a4c:	b8 28 00 00 00       	mov    $0x28,%eax
  800a51:	bf 28 00 00 00       	mov    $0x28,%edi
  800a56:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a5a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a5e:	e9 2c fc ff ff       	jmpq   80068f <vprintfmt+0x2f7>
}
  800a63:	48 83 c4 48          	add    $0x48,%rsp
  800a67:	5b                   	pop    %rbx
  800a68:	41 5c                	pop    %r12
  800a6a:	41 5d                	pop    %r13
  800a6c:	41 5e                	pop    %r14
  800a6e:	41 5f                	pop    %r15
  800a70:	5d                   	pop    %rbp
  800a71:	c3                   	retq   

0000000000800a72 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a72:	55                   	push   %rbp
  800a73:	48 89 e5             	mov    %rsp,%rbp
  800a76:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a7a:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a7e:	48 63 c6             	movslq %esi,%rax
  800a81:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a86:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a91:	48 85 ff             	test   %rdi,%rdi
  800a94:	74 2a                	je     800ac0 <vsnprintf+0x4e>
  800a96:	85 f6                	test   %esi,%esi
  800a98:	7e 26                	jle    800ac0 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a9a:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a9e:	48 bf fa 02 80 00 00 	movabs $0x8002fa,%rdi
  800aa5:	00 00 00 
  800aa8:	48 b8 98 03 80 00 00 	movabs $0x800398,%rax
  800aaf:	00 00 00 
  800ab2:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ab4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ab8:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800abb:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800abe:	c9                   	leaveq 
  800abf:	c3                   	retq   
    return -E_INVAL;
  800ac0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac5:	eb f7                	jmp    800abe <vsnprintf+0x4c>

0000000000800ac7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ac7:	55                   	push   %rbp
  800ac8:	48 89 e5             	mov    %rsp,%rbp
  800acb:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ad2:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ad9:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ae0:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ae7:	84 c0                	test   %al,%al
  800ae9:	74 20                	je     800b0b <snprintf+0x44>
  800aeb:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800aef:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800af3:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800af7:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800afb:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800aff:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b03:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b07:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b0b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b12:	00 00 00 
  800b15:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b1c:	00 00 00 
  800b1f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b23:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b2a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b31:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b38:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b3f:	48 b8 72 0a 80 00 00 	movabs $0x800a72,%rax
  800b46:	00 00 00 
  800b49:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b4b:	c9                   	leaveq 
  800b4c:	c3                   	retq   

0000000000800b4d <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b4d:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b50:	74 17                	je     800b69 <strlen+0x1c>
  800b52:	48 89 fa             	mov    %rdi,%rdx
  800b55:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b5a:	29 f9                	sub    %edi,%ecx
    n++;
  800b5c:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b5f:	48 83 c2 01          	add    $0x1,%rdx
  800b63:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b66:	75 f4                	jne    800b5c <strlen+0xf>
  800b68:	c3                   	retq   
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b6e:	c3                   	retq   

0000000000800b6f <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b6f:	48 85 f6             	test   %rsi,%rsi
  800b72:	74 24                	je     800b98 <strnlen+0x29>
  800b74:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b77:	74 25                	je     800b9e <strnlen+0x2f>
  800b79:	48 01 fe             	add    %rdi,%rsi
  800b7c:	48 89 fa             	mov    %rdi,%rdx
  800b7f:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b84:	29 f9                	sub    %edi,%ecx
    n++;
  800b86:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b89:	48 83 c2 01          	add    $0x1,%rdx
  800b8d:	48 39 f2             	cmp    %rsi,%rdx
  800b90:	74 11                	je     800ba3 <strnlen+0x34>
  800b92:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b95:	75 ef                	jne    800b86 <strnlen+0x17>
  800b97:	c3                   	retq   
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	c3                   	retq   
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800ba3:	c3                   	retq   

0000000000800ba4 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800ba4:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bb0:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bb3:	48 83 c2 01          	add    $0x1,%rdx
  800bb7:	84 c9                	test   %cl,%cl
  800bb9:	75 f1                	jne    800bac <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bbb:	c3                   	retq   

0000000000800bbc <strcat>:

char *
strcat(char *dst, const char *src) {
  800bbc:	55                   	push   %rbp
  800bbd:	48 89 e5             	mov    %rsp,%rbp
  800bc0:	41 54                	push   %r12
  800bc2:	53                   	push   %rbx
  800bc3:	48 89 fb             	mov    %rdi,%rbx
  800bc6:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bc9:	48 b8 4d 0b 80 00 00 	movabs $0x800b4d,%rax
  800bd0:	00 00 00 
  800bd3:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bd5:	48 63 f8             	movslq %eax,%rdi
  800bd8:	48 01 df             	add    %rbx,%rdi
  800bdb:	4c 89 e6             	mov    %r12,%rsi
  800bde:	48 b8 a4 0b 80 00 00 	movabs $0x800ba4,%rax
  800be5:	00 00 00 
  800be8:	ff d0                	callq  *%rax
  return dst;
}
  800bea:	48 89 d8             	mov    %rbx,%rax
  800bed:	5b                   	pop    %rbx
  800bee:	41 5c                	pop    %r12
  800bf0:	5d                   	pop    %rbp
  800bf1:	c3                   	retq   

0000000000800bf2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf2:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bf5:	48 85 d2             	test   %rdx,%rdx
  800bf8:	74 1f                	je     800c19 <strncpy+0x27>
  800bfa:	48 01 fa             	add    %rdi,%rdx
  800bfd:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c00:	48 83 c1 01          	add    $0x1,%rcx
  800c04:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c08:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c0c:	41 80 f8 01          	cmp    $0x1,%r8b
  800c10:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c14:	48 39 ca             	cmp    %rcx,%rdx
  800c17:	75 e7                	jne    800c00 <strncpy+0xe>
  }
  return ret;
}
  800c19:	c3                   	retq   

0000000000800c1a <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c1a:	48 89 f8             	mov    %rdi,%rax
  800c1d:	48 85 d2             	test   %rdx,%rdx
  800c20:	74 36                	je     800c58 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c22:	48 83 fa 01          	cmp    $0x1,%rdx
  800c26:	74 2d                	je     800c55 <strlcpy+0x3b>
  800c28:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c2c:	45 84 c0             	test   %r8b,%r8b
  800c2f:	74 24                	je     800c55 <strlcpy+0x3b>
  800c31:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c35:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c3a:	48 83 c0 01          	add    $0x1,%rax
  800c3e:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c42:	48 39 d1             	cmp    %rdx,%rcx
  800c45:	74 0e                	je     800c55 <strlcpy+0x3b>
  800c47:	48 83 c1 01          	add    $0x1,%rcx
  800c4b:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c50:	45 84 c0             	test   %r8b,%r8b
  800c53:	75 e5                	jne    800c3a <strlcpy+0x20>
    *dst = '\0';
  800c55:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c58:	48 29 f8             	sub    %rdi,%rax
}
  800c5b:	c3                   	retq   

0000000000800c5c <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c5c:	0f b6 07             	movzbl (%rdi),%eax
  800c5f:	84 c0                	test   %al,%al
  800c61:	74 17                	je     800c7a <strcmp+0x1e>
  800c63:	3a 06                	cmp    (%rsi),%al
  800c65:	75 13                	jne    800c7a <strcmp+0x1e>
    p++, q++;
  800c67:	48 83 c7 01          	add    $0x1,%rdi
  800c6b:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c6f:	0f b6 07             	movzbl (%rdi),%eax
  800c72:	84 c0                	test   %al,%al
  800c74:	74 04                	je     800c7a <strcmp+0x1e>
  800c76:	3a 06                	cmp    (%rsi),%al
  800c78:	74 ed                	je     800c67 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c7a:	0f b6 c0             	movzbl %al,%eax
  800c7d:	0f b6 16             	movzbl (%rsi),%edx
  800c80:	29 d0                	sub    %edx,%eax
}
  800c82:	c3                   	retq   

0000000000800c83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c83:	48 85 d2             	test   %rdx,%rdx
  800c86:	74 2f                	je     800cb7 <strncmp+0x34>
  800c88:	0f b6 07             	movzbl (%rdi),%eax
  800c8b:	84 c0                	test   %al,%al
  800c8d:	74 1f                	je     800cae <strncmp+0x2b>
  800c8f:	3a 06                	cmp    (%rsi),%al
  800c91:	75 1b                	jne    800cae <strncmp+0x2b>
  800c93:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c96:	48 83 c7 01          	add    $0x1,%rdi
  800c9a:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c9e:	48 39 d7             	cmp    %rdx,%rdi
  800ca1:	74 1a                	je     800cbd <strncmp+0x3a>
  800ca3:	0f b6 07             	movzbl (%rdi),%eax
  800ca6:	84 c0                	test   %al,%al
  800ca8:	74 04                	je     800cae <strncmp+0x2b>
  800caa:	3a 06                	cmp    (%rsi),%al
  800cac:	74 e8                	je     800c96 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800cae:	0f b6 07             	movzbl (%rdi),%eax
  800cb1:	0f b6 16             	movzbl (%rsi),%edx
  800cb4:	29 d0                	sub    %edx,%eax
}
  800cb6:	c3                   	retq   
    return 0;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbc:	c3                   	retq   
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	c3                   	retq   

0000000000800cc3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cc3:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cc5:	0f b6 07             	movzbl (%rdi),%eax
  800cc8:	84 c0                	test   %al,%al
  800cca:	74 1e                	je     800cea <strchr+0x27>
    if (*s == c)
  800ccc:	40 38 c6             	cmp    %al,%sil
  800ccf:	74 1f                	je     800cf0 <strchr+0x2d>
  for (; *s; s++)
  800cd1:	48 83 c7 01          	add    $0x1,%rdi
  800cd5:	0f b6 07             	movzbl (%rdi),%eax
  800cd8:	84 c0                	test   %al,%al
  800cda:	74 08                	je     800ce4 <strchr+0x21>
    if (*s == c)
  800cdc:	38 d0                	cmp    %dl,%al
  800cde:	75 f1                	jne    800cd1 <strchr+0xe>
  for (; *s; s++)
  800ce0:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ce3:	c3                   	retq   
  return 0;
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce9:	c3                   	retq   
  800cea:	b8 00 00 00 00       	mov    $0x0,%eax
  800cef:	c3                   	retq   
    if (*s == c)
  800cf0:	48 89 f8             	mov    %rdi,%rax
  800cf3:	c3                   	retq   

0000000000800cf4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cf4:	48 89 f8             	mov    %rdi,%rax
  800cf7:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cf9:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cfc:	40 38 f2             	cmp    %sil,%dl
  800cff:	74 13                	je     800d14 <strfind+0x20>
  800d01:	84 d2                	test   %dl,%dl
  800d03:	74 0f                	je     800d14 <strfind+0x20>
  for (; *s; s++)
  800d05:	48 83 c0 01          	add    $0x1,%rax
  800d09:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d0c:	38 ca                	cmp    %cl,%dl
  800d0e:	74 04                	je     800d14 <strfind+0x20>
  800d10:	84 d2                	test   %dl,%dl
  800d12:	75 f1                	jne    800d05 <strfind+0x11>
      break;
  return (char *)s;
}
  800d14:	c3                   	retq   

0000000000800d15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d15:	48 85 d2             	test   %rdx,%rdx
  800d18:	74 3a                	je     800d54 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d1a:	48 89 f8             	mov    %rdi,%rax
  800d1d:	48 09 d0             	or     %rdx,%rax
  800d20:	a8 03                	test   $0x3,%al
  800d22:	75 28                	jne    800d4c <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d24:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d28:	89 f0                	mov    %esi,%eax
  800d2a:	c1 e0 08             	shl    $0x8,%eax
  800d2d:	89 f1                	mov    %esi,%ecx
  800d2f:	c1 e1 18             	shl    $0x18,%ecx
  800d32:	41 89 f0             	mov    %esi,%r8d
  800d35:	41 c1 e0 10          	shl    $0x10,%r8d
  800d39:	44 09 c1             	or     %r8d,%ecx
  800d3c:	09 ce                	or     %ecx,%esi
  800d3e:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d40:	48 c1 ea 02          	shr    $0x2,%rdx
  800d44:	48 89 d1             	mov    %rdx,%rcx
  800d47:	fc                   	cld    
  800d48:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d4a:	eb 08                	jmp    800d54 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d4c:	89 f0                	mov    %esi,%eax
  800d4e:	48 89 d1             	mov    %rdx,%rcx
  800d51:	fc                   	cld    
  800d52:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d54:	48 89 f8             	mov    %rdi,%rax
  800d57:	c3                   	retq   

0000000000800d58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d58:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d5b:	48 39 fe             	cmp    %rdi,%rsi
  800d5e:	73 40                	jae    800da0 <memmove+0x48>
  800d60:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d64:	48 39 f9             	cmp    %rdi,%rcx
  800d67:	76 37                	jbe    800da0 <memmove+0x48>
    s += n;
    d += n;
  800d69:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d6d:	48 89 fe             	mov    %rdi,%rsi
  800d70:	48 09 d6             	or     %rdx,%rsi
  800d73:	48 09 ce             	or     %rcx,%rsi
  800d76:	40 f6 c6 03          	test   $0x3,%sil
  800d7a:	75 14                	jne    800d90 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d7c:	48 83 ef 04          	sub    $0x4,%rdi
  800d80:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d84:	48 c1 ea 02          	shr    $0x2,%rdx
  800d88:	48 89 d1             	mov    %rdx,%rcx
  800d8b:	fd                   	std    
  800d8c:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d8e:	eb 0e                	jmp    800d9e <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d90:	48 83 ef 01          	sub    $0x1,%rdi
  800d94:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d98:	48 89 d1             	mov    %rdx,%rcx
  800d9b:	fd                   	std    
  800d9c:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d9e:	fc                   	cld    
  800d9f:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800da0:	48 89 c1             	mov    %rax,%rcx
  800da3:	48 09 d1             	or     %rdx,%rcx
  800da6:	48 09 f1             	or     %rsi,%rcx
  800da9:	f6 c1 03             	test   $0x3,%cl
  800dac:	75 0e                	jne    800dbc <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800dae:	48 c1 ea 02          	shr    $0x2,%rdx
  800db2:	48 89 d1             	mov    %rdx,%rcx
  800db5:	48 89 c7             	mov    %rax,%rdi
  800db8:	fc                   	cld    
  800db9:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dbb:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800dbc:	48 89 c7             	mov    %rax,%rdi
  800dbf:	48 89 d1             	mov    %rdx,%rcx
  800dc2:	fc                   	cld    
  800dc3:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dc5:	c3                   	retq   

0000000000800dc6 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dc6:	55                   	push   %rbp
  800dc7:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dca:	48 b8 58 0d 80 00 00 	movabs $0x800d58,%rax
  800dd1:	00 00 00 
  800dd4:	ff d0                	callq  *%rax
}
  800dd6:	5d                   	pop    %rbp
  800dd7:	c3                   	retq   

0000000000800dd8 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dd8:	55                   	push   %rbp
  800dd9:	48 89 e5             	mov    %rsp,%rbp
  800ddc:	41 57                	push   %r15
  800dde:	41 56                	push   %r14
  800de0:	41 55                	push   %r13
  800de2:	41 54                	push   %r12
  800de4:	53                   	push   %rbx
  800de5:	48 83 ec 08          	sub    $0x8,%rsp
  800de9:	49 89 fe             	mov    %rdi,%r14
  800dec:	49 89 f7             	mov    %rsi,%r15
  800def:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800df2:	48 89 f7             	mov    %rsi,%rdi
  800df5:	48 b8 4d 0b 80 00 00 	movabs $0x800b4d,%rax
  800dfc:	00 00 00 
  800dff:	ff d0                	callq  *%rax
  800e01:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e04:	4c 89 ee             	mov    %r13,%rsi
  800e07:	4c 89 f7             	mov    %r14,%rdi
  800e0a:	48 b8 6f 0b 80 00 00 	movabs $0x800b6f,%rax
  800e11:	00 00 00 
  800e14:	ff d0                	callq  *%rax
  800e16:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e19:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e1d:	4d 39 e5             	cmp    %r12,%r13
  800e20:	74 26                	je     800e48 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e22:	4c 89 e8             	mov    %r13,%rax
  800e25:	4c 29 e0             	sub    %r12,%rax
  800e28:	48 39 d8             	cmp    %rbx,%rax
  800e2b:	76 2a                	jbe    800e57 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e2d:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e31:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e35:	4c 89 fe             	mov    %r15,%rsi
  800e38:	48 b8 c6 0d 80 00 00 	movabs $0x800dc6,%rax
  800e3f:	00 00 00 
  800e42:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e44:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e48:	48 83 c4 08          	add    $0x8,%rsp
  800e4c:	5b                   	pop    %rbx
  800e4d:	41 5c                	pop    %r12
  800e4f:	41 5d                	pop    %r13
  800e51:	41 5e                	pop    %r14
  800e53:	41 5f                	pop    %r15
  800e55:	5d                   	pop    %rbp
  800e56:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e57:	49 83 ed 01          	sub    $0x1,%r13
  800e5b:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e5f:	4c 89 ea             	mov    %r13,%rdx
  800e62:	4c 89 fe             	mov    %r15,%rsi
  800e65:	48 b8 c6 0d 80 00 00 	movabs $0x800dc6,%rax
  800e6c:	00 00 00 
  800e6f:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e71:	4d 01 ee             	add    %r13,%r14
  800e74:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e79:	eb c9                	jmp    800e44 <strlcat+0x6c>

0000000000800e7b <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e7b:	48 85 d2             	test   %rdx,%rdx
  800e7e:	74 3a                	je     800eba <memcmp+0x3f>
    if (*s1 != *s2)
  800e80:	0f b6 0f             	movzbl (%rdi),%ecx
  800e83:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e87:	44 38 c1             	cmp    %r8b,%cl
  800e8a:	75 1d                	jne    800ea9 <memcmp+0x2e>
  800e8c:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e91:	48 39 d0             	cmp    %rdx,%rax
  800e94:	74 1e                	je     800eb4 <memcmp+0x39>
    if (*s1 != *s2)
  800e96:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e9a:	48 83 c0 01          	add    $0x1,%rax
  800e9e:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ea4:	44 38 c1             	cmp    %r8b,%cl
  800ea7:	74 e8                	je     800e91 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ea9:	0f b6 c1             	movzbl %cl,%eax
  800eac:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eb0:	44 29 c0             	sub    %r8d,%eax
  800eb3:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	c3                   	retq   
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebf:	c3                   	retq   

0000000000800ec0 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800ec0:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ec4:	48 39 c7             	cmp    %rax,%rdi
  800ec7:	73 19                	jae    800ee2 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ec9:	89 f2                	mov    %esi,%edx
  800ecb:	40 38 37             	cmp    %sil,(%rdi)
  800ece:	74 16                	je     800ee6 <memfind+0x26>
  for (; s < ends; s++)
  800ed0:	48 83 c7 01          	add    $0x1,%rdi
  800ed4:	48 39 f8             	cmp    %rdi,%rax
  800ed7:	74 08                	je     800ee1 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed9:	38 17                	cmp    %dl,(%rdi)
  800edb:	75 f3                	jne    800ed0 <memfind+0x10>
  for (; s < ends; s++)
  800edd:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ee0:	c3                   	retq   
  800ee1:	c3                   	retq   
  for (; s < ends; s++)
  800ee2:	48 89 f8             	mov    %rdi,%rax
  800ee5:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee6:	48 89 f8             	mov    %rdi,%rax
  800ee9:	c3                   	retq   

0000000000800eea <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800eea:	0f b6 07             	movzbl (%rdi),%eax
  800eed:	3c 20                	cmp    $0x20,%al
  800eef:	74 04                	je     800ef5 <strtol+0xb>
  800ef1:	3c 09                	cmp    $0x9,%al
  800ef3:	75 0f                	jne    800f04 <strtol+0x1a>
    s++;
  800ef5:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ef9:	0f b6 07             	movzbl (%rdi),%eax
  800efc:	3c 20                	cmp    $0x20,%al
  800efe:	74 f5                	je     800ef5 <strtol+0xb>
  800f00:	3c 09                	cmp    $0x9,%al
  800f02:	74 f1                	je     800ef5 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f04:	3c 2b                	cmp    $0x2b,%al
  800f06:	74 2b                	je     800f33 <strtol+0x49>
  int neg  = 0;
  800f08:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f0e:	3c 2d                	cmp    $0x2d,%al
  800f10:	74 2d                	je     800f3f <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f12:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f18:	75 0f                	jne    800f29 <strtol+0x3f>
  800f1a:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f1d:	74 2c                	je     800f4b <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f1f:	85 d2                	test   %edx,%edx
  800f21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f26:	0f 44 d0             	cmove  %eax,%edx
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f2e:	4c 63 d2             	movslq %edx,%r10
  800f31:	eb 5c                	jmp    800f8f <strtol+0xa5>
    s++;
  800f33:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f37:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f3d:	eb d3                	jmp    800f12 <strtol+0x28>
    s++, neg = 1;
  800f3f:	48 83 c7 01          	add    $0x1,%rdi
  800f43:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f49:	eb c7                	jmp    800f12 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f4b:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f4f:	74 0f                	je     800f60 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f51:	85 d2                	test   %edx,%edx
  800f53:	75 d4                	jne    800f29 <strtol+0x3f>
    s++, base = 8;
  800f55:	48 83 c7 01          	add    $0x1,%rdi
  800f59:	ba 08 00 00 00       	mov    $0x8,%edx
  800f5e:	eb c9                	jmp    800f29 <strtol+0x3f>
    s += 2, base = 16;
  800f60:	48 83 c7 02          	add    $0x2,%rdi
  800f64:	ba 10 00 00 00       	mov    $0x10,%edx
  800f69:	eb be                	jmp    800f29 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f6b:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f6f:	41 80 f8 19          	cmp    $0x19,%r8b
  800f73:	77 2f                	ja     800fa4 <strtol+0xba>
      dig = *s - 'a' + 10;
  800f75:	44 0f be c1          	movsbl %cl,%r8d
  800f79:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f7d:	39 d1                	cmp    %edx,%ecx
  800f7f:	7d 37                	jge    800fb8 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f81:	48 83 c7 01          	add    $0x1,%rdi
  800f85:	49 0f af c2          	imul   %r10,%rax
  800f89:	48 63 c9             	movslq %ecx,%rcx
  800f8c:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f8f:	0f b6 0f             	movzbl (%rdi),%ecx
  800f92:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f96:	41 80 f8 09          	cmp    $0x9,%r8b
  800f9a:	77 cf                	ja     800f6b <strtol+0x81>
      dig = *s - '0';
  800f9c:	0f be c9             	movsbl %cl,%ecx
  800f9f:	83 e9 30             	sub    $0x30,%ecx
  800fa2:	eb d9                	jmp    800f7d <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fa4:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fa8:	41 80 f8 19          	cmp    $0x19,%r8b
  800fac:	77 0a                	ja     800fb8 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fae:	44 0f be c1          	movsbl %cl,%r8d
  800fb2:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fb6:	eb c5                	jmp    800f7d <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fb8:	48 85 f6             	test   %rsi,%rsi
  800fbb:	74 03                	je     800fc0 <strtol+0xd6>
    *endptr = (char *)s;
  800fbd:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fc0:	48 89 c2             	mov    %rax,%rdx
  800fc3:	48 f7 da             	neg    %rdx
  800fc6:	45 85 c9             	test   %r9d,%r9d
  800fc9:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fcd:	c3                   	retq   

0000000000800fce <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fce:	55                   	push   %rbp
  800fcf:	48 89 e5             	mov    %rsp,%rbp
  800fd2:	53                   	push   %rbx
  800fd3:	48 89 fa             	mov    %rdi,%rdx
  800fd6:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fde:	48 89 c3             	mov    %rax,%rbx
  800fe1:	48 89 c7             	mov    %rax,%rdi
  800fe4:	48 89 c6             	mov    %rax,%rsi
  800fe7:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fe9:	5b                   	pop    %rbx
  800fea:	5d                   	pop    %rbp
  800feb:	c3                   	retq   

0000000000800fec <sys_cgetc>:

int
sys_cgetc(void) {
  800fec:	55                   	push   %rbp
  800fed:	48 89 e5             	mov    %rsp,%rbp
  800ff0:	53                   	push   %rbx
  asm volatile("int %1\n"
  800ff1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	48 89 ca             	mov    %rcx,%rdx
  800ffe:	48 89 cb             	mov    %rcx,%rbx
  801001:	48 89 cf             	mov    %rcx,%rdi
  801004:	48 89 ce             	mov    %rcx,%rsi
  801007:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801009:	5b                   	pop    %rbx
  80100a:	5d                   	pop    %rbp
  80100b:	c3                   	retq   

000000000080100c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80100c:	55                   	push   %rbp
  80100d:	48 89 e5             	mov    %rsp,%rbp
  801010:	53                   	push   %rbx
  801011:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801015:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801018:	be 00 00 00 00       	mov    $0x0,%esi
  80101d:	b8 03 00 00 00       	mov    $0x3,%eax
  801022:	48 89 f1             	mov    %rsi,%rcx
  801025:	48 89 f3             	mov    %rsi,%rbx
  801028:	48 89 f7             	mov    %rsi,%rdi
  80102b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80102d:	48 85 c0             	test   %rax,%rax
  801030:	7f 07                	jg     801039 <sys_env_destroy+0x2d>
}
  801032:	48 83 c4 08          	add    $0x8,%rsp
  801036:	5b                   	pop    %rbx
  801037:	5d                   	pop    %rbp
  801038:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801039:	49 89 c0             	mov    %rax,%r8
  80103c:	b9 03 00 00 00       	mov    $0x3,%ecx
  801041:	48 ba 70 15 80 00 00 	movabs $0x801570,%rdx
  801048:	00 00 00 
  80104b:	be 22 00 00 00       	mov    $0x22,%esi
  801050:	48 bf 8f 15 80 00 00 	movabs $0x80158f,%rdi
  801057:	00 00 00 
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
  80105f:	49 b9 8c 10 80 00 00 	movabs $0x80108c,%r9
  801066:	00 00 00 
  801069:	41 ff d1             	callq  *%r9

000000000080106c <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80106c:	55                   	push   %rbp
  80106d:	48 89 e5             	mov    %rsp,%rbp
  801070:	53                   	push   %rbx
  asm volatile("int %1\n"
  801071:	b9 00 00 00 00       	mov    $0x0,%ecx
  801076:	b8 02 00 00 00       	mov    $0x2,%eax
  80107b:	48 89 ca             	mov    %rcx,%rdx
  80107e:	48 89 cb             	mov    %rcx,%rbx
  801081:	48 89 cf             	mov    %rcx,%rdi
  801084:	48 89 ce             	mov    %rcx,%rsi
  801087:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801089:	5b                   	pop    %rbx
  80108a:	5d                   	pop    %rbp
  80108b:	c3                   	retq   

000000000080108c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80108c:	55                   	push   %rbp
  80108d:	48 89 e5             	mov    %rsp,%rbp
  801090:	41 56                	push   %r14
  801092:	41 55                	push   %r13
  801094:	41 54                	push   %r12
  801096:	53                   	push   %rbx
  801097:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80109e:	49 89 fd             	mov    %rdi,%r13
  8010a1:	41 89 f6             	mov    %esi,%r14d
  8010a4:	49 89 d4             	mov    %rdx,%r12
  8010a7:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8010ae:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010b5:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010bc:	84 c0                	test   %al,%al
  8010be:	74 26                	je     8010e6 <_panic+0x5a>
  8010c0:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010c7:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010ce:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010d2:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010d6:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010da:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010de:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010e2:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010e6:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010ed:	00 00 00 
  8010f0:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010f7:	00 00 00 
  8010fa:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010fe:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801105:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80110c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801113:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80111a:	00 00 00 
  80111d:	48 8b 18             	mov    (%rax),%rbx
  801120:	48 b8 6c 10 80 00 00 	movabs $0x80106c,%rax
  801127:	00 00 00 
  80112a:	ff d0                	callq  *%rax
  80112c:	45 89 f0             	mov    %r14d,%r8d
  80112f:	4c 89 e9             	mov    %r13,%rcx
  801132:	48 89 da             	mov    %rbx,%rdx
  801135:	89 c6                	mov    %eax,%esi
  801137:	48 bf a0 15 80 00 00 	movabs $0x8015a0,%rdi
  80113e:	00 00 00 
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	48 bb da 01 80 00 00 	movabs $0x8001da,%rbx
  80114d:	00 00 00 
  801150:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801152:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801159:	4c 89 e7             	mov    %r12,%rdi
  80115c:	48 b8 72 01 80 00 00 	movabs $0x800172,%rax
  801163:	00 00 00 
  801166:	ff d0                	callq  *%rax
  cprintf("\n");
  801168:	48 bf c8 15 80 00 00 	movabs $0x8015c8,%rdi
  80116f:	00 00 00 
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
  801177:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801179:	cc                   	int3   
  while (1)
  80117a:	eb fd                	jmp    801179 <_panic+0xed>
