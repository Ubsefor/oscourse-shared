
obj/user/hello:     file format elf64-x86-64


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
  800023:	e8 4e 00 00 00       	callq  800076 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	53                   	push   %rbx
  80002f:	48 83 ec 08          	sub    $0x8,%rsp
  cprintf("hello, world\n");
  800033:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  80003a:	00 00 00 
  80003d:	b8 00 00 00 00       	mov    $0x0,%eax
  800042:	48 bb c5 01 80 00 00 	movabs $0x8001c5,%rbx
  800049:	00 00 00 
  80004c:	ff d3                	callq  *%rbx
  cprintf("i am environment %08x\n", thisenv->env_id);
  80004e:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  800055:	00 00 00 
  800058:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80005e:	48 bf 8e 11 80 00 00 	movabs $0x80118e,%rdi
  800065:	00 00 00 
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	ff d3                	callq  *%rbx
}
  80006f:	48 83 c4 08          	add    $0x8,%rsp
  800073:	5b                   	pop    %rbx
  800074:	5d                   	pop    %rbp
  800075:	c3                   	retq   

0000000000800076 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800076:	55                   	push   %rbp
  800077:	48 89 e5             	mov    %rsp,%rbp
  80007a:	41 56                	push   %r14
  80007c:	41 55                	push   %r13
  80007e:	41 54                	push   %r12
  800080:	53                   	push   %rbx
  800081:	41 89 fd             	mov    %edi,%r13d
  800084:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800087:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80008e:	00 00 00 
  800091:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800098:	00 00 00 
  80009b:	48 39 c2             	cmp    %rax,%rdx
  80009e:	73 23                	jae    8000c3 <libmain+0x4d>
  8000a0:	48 89 d3             	mov    %rdx,%rbx
  8000a3:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  8000a7:	48 29 d0             	sub    %rdx,%rax
  8000aa:	48 c1 e8 03          	shr    $0x3,%rax
  8000ae:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b8:	ff 13                	callq  *(%rbx)
    ctor++;
  8000ba:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8000be:	4c 39 e3             	cmp    %r12,%rbx
  8000c1:	75 f0                	jne    8000b3 <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000c3:	45 85 ed             	test   %r13d,%r13d
  8000c6:	7e 0d                	jle    8000d5 <libmain+0x5f>
    binaryname = argv[0];
  8000c8:	49 8b 06             	mov    (%r14),%rax
  8000cb:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000d2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000d5:	4c 89 f6             	mov    %r14,%rsi
  8000d8:	44 89 ef             	mov    %r13d,%edi
  8000db:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000e2:	00 00 00 
  8000e5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000e7:	48 b8 fc 00 80 00 00 	movabs $0x8000fc,%rax
  8000ee:	00 00 00 
  8000f1:	ff d0                	callq  *%rax
#endif
}
  8000f3:	5b                   	pop    %rbx
  8000f4:	41 5c                	pop    %r12
  8000f6:	41 5d                	pop    %r13
  8000f8:	41 5e                	pop    %r14
  8000fa:	5d                   	pop    %rbp
  8000fb:	c3                   	retq   

00000000008000fc <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000fc:	55                   	push   %rbp
  8000fd:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800100:	bf 00 00 00 00       	mov    $0x0,%edi
  800105:	48 b8 f7 0f 80 00 00 	movabs $0x800ff7,%rax
  80010c:	00 00 00 
  80010f:	ff d0                	callq  *%rax
}
  800111:	5d                   	pop    %rbp
  800112:	c3                   	retq   

0000000000800113 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800113:	55                   	push   %rbp
  800114:	48 89 e5             	mov    %rsp,%rbp
  800117:	53                   	push   %rbx
  800118:	48 83 ec 08          	sub    $0x8,%rsp
  80011c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80011f:	8b 06                	mov    (%rsi),%eax
  800121:	8d 50 01             	lea    0x1(%rax),%edx
  800124:	89 16                	mov    %edx,(%rsi)
  800126:	48 98                	cltq   
  800128:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80012d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800133:	74 0b                	je     800140 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800135:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800139:	48 83 c4 08          	add    $0x8,%rsp
  80013d:	5b                   	pop    %rbx
  80013e:	5d                   	pop    %rbp
  80013f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800140:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800144:	be ff 00 00 00       	mov    $0xff,%esi
  800149:	48 b8 b9 0f 80 00 00 	movabs $0x800fb9,%rax
  800150:	00 00 00 
  800153:	ff d0                	callq  *%rax
    b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80015b:	eb d8                	jmp    800135 <putch+0x22>

000000000080015d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80015d:	55                   	push   %rbp
  80015e:	48 89 e5             	mov    %rsp,%rbp
  800161:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800168:	48 89 fa             	mov    %rdi,%rdx
  80016b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800175:	00 00 00 
  b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80017f:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800182:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800189:	48 bf 13 01 80 00 00 	movabs $0x800113,%rdi
  800190:	00 00 00 
  800193:	48 b8 83 03 80 00 00 	movabs $0x800383,%rax
  80019a:	00 00 00 
  80019d:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80019f:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001a6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001ad:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001b1:	48 b8 b9 0f 80 00 00 	movabs $0x800fb9,%rax
  8001b8:	00 00 00 
  8001bb:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001c3:	c9                   	leaveq 
  8001c4:	c3                   	retq   

00000000008001c5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001c5:	55                   	push   %rbp
  8001c6:	48 89 e5             	mov    %rsp,%rbp
  8001c9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001d0:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001d7:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001de:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001e5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001ec:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001f3:	84 c0                	test   %al,%al
  8001f5:	74 20                	je     800217 <cprintf+0x52>
  8001f7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8001fb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8001ff:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800203:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800207:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80020b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80020f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800213:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800217:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80021e:	00 00 00 
  800221:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800228:	00 00 00 
  80022b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80022f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800236:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80023d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800244:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80024b:	48 b8 5d 01 80 00 00 	movabs $0x80015d,%rax
  800252:	00 00 00 
  800255:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800257:	c9                   	leaveq 
  800258:	c3                   	retq   

0000000000800259 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800259:	55                   	push   %rbp
  80025a:	48 89 e5             	mov    %rsp,%rbp
  80025d:	41 57                	push   %r15
  80025f:	41 56                	push   %r14
  800261:	41 55                	push   %r13
  800263:	41 54                	push   %r12
  800265:	53                   	push   %rbx
  800266:	48 83 ec 18          	sub    $0x18,%rsp
  80026a:	49 89 fc             	mov    %rdi,%r12
  80026d:	49 89 f5             	mov    %rsi,%r13
  800270:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800274:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800277:	41 89 cf             	mov    %ecx,%r15d
  80027a:	49 39 d7             	cmp    %rdx,%r15
  80027d:	76 45                	jbe    8002c4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80027f:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800283:	85 db                	test   %ebx,%ebx
  800285:	7e 0e                	jle    800295 <printnum+0x3c>
      putch(padc, putdat);
  800287:	4c 89 ee             	mov    %r13,%rsi
  80028a:	44 89 f7             	mov    %r14d,%edi
  80028d:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800290:	83 eb 01             	sub    $0x1,%ebx
  800293:	75 f2                	jne    800287 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800295:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	49 f7 f7             	div    %r15
  8002a1:	48 b8 af 11 80 00 00 	movabs $0x8011af,%rax
  8002a8:	00 00 00 
  8002ab:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002af:	4c 89 ee             	mov    %r13,%rsi
  8002b2:	41 ff d4             	callq  *%r12
}
  8002b5:	48 83 c4 18          	add    $0x18,%rsp
  8002b9:	5b                   	pop    %rbx
  8002ba:	41 5c                	pop    %r12
  8002bc:	41 5d                	pop    %r13
  8002be:	41 5e                	pop    %r14
  8002c0:	41 5f                	pop    %r15
  8002c2:	5d                   	pop    %rbp
  8002c3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	49 f7 f7             	div    %r15
  8002d0:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002d4:	48 89 c2             	mov    %rax,%rdx
  8002d7:	48 b8 59 02 80 00 00 	movabs $0x800259,%rax
  8002de:	00 00 00 
  8002e1:	ff d0                	callq  *%rax
  8002e3:	eb b0                	jmp    800295 <printnum+0x3c>

00000000008002e5 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002e5:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002e9:	48 8b 06             	mov    (%rsi),%rax
  8002ec:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x17>
    *b->buf++ = ch;
  8002f2:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8002f6:	48 89 16             	mov    %rdx,(%rsi)
  8002f9:	40 88 38             	mov    %dil,(%rax)
}
  8002fc:	c3                   	retq   

00000000008002fd <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8002fd:	55                   	push   %rbp
  8002fe:	48 89 e5             	mov    %rsp,%rbp
  800301:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800308:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80030f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800316:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80031d:	84 c0                	test   %al,%al
  80031f:	74 20                	je     800341 <printfmt+0x44>
  800321:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800325:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800329:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80032d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800331:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800335:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800339:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80033d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800341:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800348:	00 00 00 
  80034b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800352:	00 00 00 
  800355:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800359:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800360:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800367:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80036e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800375:	48 b8 83 03 80 00 00 	movabs $0x800383,%rax
  80037c:	00 00 00 
  80037f:	ff d0                	callq  *%rax
}
  800381:	c9                   	leaveq 
  800382:	c3                   	retq   

0000000000800383 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800383:	55                   	push   %rbp
  800384:	48 89 e5             	mov    %rsp,%rbp
  800387:	41 57                	push   %r15
  800389:	41 56                	push   %r14
  80038b:	41 55                	push   %r13
  80038d:	41 54                	push   %r12
  80038f:	53                   	push   %rbx
  800390:	48 83 ec 48          	sub    $0x48,%rsp
  800394:	49 89 fd             	mov    %rdi,%r13
  800397:	49 89 f7             	mov    %rsi,%r15
  80039a:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80039d:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003a1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003a5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003a9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003ad:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003b1:	41 0f b6 3e          	movzbl (%r14),%edi
  8003b5:	83 ff 25             	cmp    $0x25,%edi
  8003b8:	74 18                	je     8003d2 <vprintfmt+0x4f>
      if (ch == '\0')
  8003ba:	85 ff                	test   %edi,%edi
  8003bc:	0f 84 8c 06 00 00    	je     800a4e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003c2:	4c 89 fe             	mov    %r15,%rsi
  8003c5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003c8:	49 89 de             	mov    %rbx,%r14
  8003cb:	eb e0                	jmp    8003ad <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003cd:	49 89 de             	mov    %rbx,%r14
  8003d0:	eb db                	jmp    8003ad <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003d2:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003d6:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003da:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003e1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003e7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003eb:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003f0:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8003f6:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8003fc:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800401:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800406:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80040a:	0f b6 13             	movzbl (%rbx),%edx
  80040d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800410:	3c 55                	cmp    $0x55,%al
  800412:	0f 87 8b 05 00 00    	ja     8009a3 <vprintfmt+0x620>
  800418:	0f b6 c0             	movzbl %al,%eax
  80041b:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800422:	00 00 00 
  800425:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800429:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80042c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800430:	eb d4                	jmp    800406 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800432:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800435:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800439:	eb cb                	jmp    800406 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80043b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80043e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800442:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800446:	8d 50 d0             	lea    -0x30(%rax),%edx
  800449:	83 fa 09             	cmp    $0x9,%edx
  80044c:	77 7e                	ja     8004cc <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80044e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800452:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800456:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80045b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80045f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800462:	83 fa 09             	cmp    $0x9,%edx
  800465:	76 e7                	jbe    80044e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800467:	4c 89 f3             	mov    %r14,%rbx
  80046a:	eb 19                	jmp    800485 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80046c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80046f:	83 f8 2f             	cmp    $0x2f,%eax
  800472:	77 2a                	ja     80049e <vprintfmt+0x11b>
  800474:	89 c2                	mov    %eax,%edx
  800476:	4c 01 d2             	add    %r10,%rdx
  800479:	83 c0 08             	add    $0x8,%eax
  80047c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80047f:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800482:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800485:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800489:	0f 89 77 ff ff ff    	jns    800406 <vprintfmt+0x83>
          width = precision, precision = -1;
  80048f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800493:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800499:	e9 68 ff ff ff       	jmpq   800406 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80049e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004a2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004a6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004aa:	eb d3                	jmp    80047f <vprintfmt+0xfc>
        if (width < 0)
  8004ac:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004b5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004b8:	4c 89 f3             	mov    %r14,%rbx
  8004bb:	e9 46 ff ff ff       	jmpq   800406 <vprintfmt+0x83>
  8004c0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004c3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004c7:	e9 3a ff ff ff       	jmpq   800406 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004cc:	4c 89 f3             	mov    %r14,%rbx
  8004cf:	eb b4                	jmp    800485 <vprintfmt+0x102>
        lflag++;
  8004d1:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004d4:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004d7:	e9 2a ff ff ff       	jmpq   800406 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004dc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004df:	83 f8 2f             	cmp    $0x2f,%eax
  8004e2:	77 19                	ja     8004fd <vprintfmt+0x17a>
  8004e4:	89 c2                	mov    %eax,%edx
  8004e6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004ea:	83 c0 08             	add    $0x8,%eax
  8004ed:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004f0:	4c 89 fe             	mov    %r15,%rsi
  8004f3:	8b 3a                	mov    (%rdx),%edi
  8004f5:	41 ff d5             	callq  *%r13
        break;
  8004f8:	e9 b0 fe ff ff       	jmpq   8003ad <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8004fd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800501:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800505:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800509:	eb e5                	jmp    8004f0 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80050b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80050e:	83 f8 2f             	cmp    $0x2f,%eax
  800511:	77 5b                	ja     80056e <vprintfmt+0x1eb>
  800513:	89 c2                	mov    %eax,%edx
  800515:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800519:	83 c0 08             	add    $0x8,%eax
  80051c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80051f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800521:	89 c8                	mov    %ecx,%eax
  800523:	c1 f8 1f             	sar    $0x1f,%eax
  800526:	31 c1                	xor    %eax,%ecx
  800528:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052a:	83 f9 09             	cmp    $0x9,%ecx
  80052d:	7f 4d                	jg     80057c <vprintfmt+0x1f9>
  80052f:	48 63 c1             	movslq %ecx,%rax
  800532:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  800539:	00 00 00 
  80053c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800540:	48 85 c0             	test   %rax,%rax
  800543:	74 37                	je     80057c <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800545:	48 89 c1             	mov    %rax,%rcx
  800548:	48 ba d0 11 80 00 00 	movabs $0x8011d0,%rdx
  80054f:	00 00 00 
  800552:	4c 89 fe             	mov    %r15,%rsi
  800555:	4c 89 ef             	mov    %r13,%rdi
  800558:	b8 00 00 00 00       	mov    $0x0,%eax
  80055d:	48 bb fd 02 80 00 00 	movabs $0x8002fd,%rbx
  800564:	00 00 00 
  800567:	ff d3                	callq  *%rbx
  800569:	e9 3f fe ff ff       	jmpq   8003ad <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80056e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800572:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800576:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80057a:	eb a3                	jmp    80051f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80057c:	48 ba c7 11 80 00 00 	movabs $0x8011c7,%rdx
  800583:	00 00 00 
  800586:	4c 89 fe             	mov    %r15,%rsi
  800589:	4c 89 ef             	mov    %r13,%rdi
  80058c:	b8 00 00 00 00       	mov    $0x0,%eax
  800591:	48 bb fd 02 80 00 00 	movabs $0x8002fd,%rbx
  800598:	00 00 00 
  80059b:	ff d3                	callq  *%rbx
  80059d:	e9 0b fe ff ff       	jmpq   8003ad <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005a2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005a5:	83 f8 2f             	cmp    $0x2f,%eax
  8005a8:	77 4b                	ja     8005f5 <vprintfmt+0x272>
  8005aa:	89 c2                	mov    %eax,%edx
  8005ac:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005b0:	83 c0 08             	add    $0x8,%eax
  8005b3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005b6:	48 8b 02             	mov    (%rdx),%rax
  8005b9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005bd:	48 85 c0             	test   %rax,%rax
  8005c0:	0f 84 05 04 00 00    	je     8009cb <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005c6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005ca:	7e 06                	jle    8005d2 <vprintfmt+0x24f>
  8005cc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005d0:	75 31                	jne    800603 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005d6:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005da:	0f b6 00             	movzbl (%rax),%eax
  8005dd:	0f be f8             	movsbl %al,%edi
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	0f 84 c3 00 00 00    	je     8006ab <vprintfmt+0x328>
  8005e8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005ec:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005f0:	e9 85 00 00 00       	jmpq   80067a <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005f5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005f9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005fd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800601:	eb b3                	jmp    8005b6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800603:	49 63 f4             	movslq %r12d,%rsi
  800606:	48 89 c7             	mov    %rax,%rdi
  800609:	48 b8 5a 0b 80 00 00 	movabs $0x800b5a,%rax
  800610:	00 00 00 
  800613:	ff d0                	callq  *%rax
  800615:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800618:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80061b:	85 f6                	test   %esi,%esi
  80061d:	7e 22                	jle    800641 <vprintfmt+0x2be>
            putch(padc, putdat);
  80061f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800623:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800627:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80062b:	4c 89 fe             	mov    %r15,%rsi
  80062e:	89 df                	mov    %ebx,%edi
  800630:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800633:	41 83 ec 01          	sub    $0x1,%r12d
  800637:	75 f2                	jne    80062b <vprintfmt+0x2a8>
  800639:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80063d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800645:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800649:	0f b6 00             	movzbl (%rax),%eax
  80064c:	0f be f8             	movsbl %al,%edi
  80064f:	85 ff                	test   %edi,%edi
  800651:	0f 84 56 fd ff ff    	je     8003ad <vprintfmt+0x2a>
  800657:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80065b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80065f:	eb 19                	jmp    80067a <vprintfmt+0x2f7>
            putch(ch, putdat);
  800661:	4c 89 fe             	mov    %r15,%rsi
  800664:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800667:	41 83 ee 01          	sub    $0x1,%r14d
  80066b:	48 83 c3 01          	add    $0x1,%rbx
  80066f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800673:	0f be f8             	movsbl %al,%edi
  800676:	85 ff                	test   %edi,%edi
  800678:	74 29                	je     8006a3 <vprintfmt+0x320>
  80067a:	45 85 e4             	test   %r12d,%r12d
  80067d:	78 06                	js     800685 <vprintfmt+0x302>
  80067f:	41 83 ec 01          	sub    $0x1,%r12d
  800683:	78 48                	js     8006cd <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800685:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800689:	74 d6                	je     800661 <vprintfmt+0x2de>
  80068b:	0f be c0             	movsbl %al,%eax
  80068e:	83 e8 20             	sub    $0x20,%eax
  800691:	83 f8 5e             	cmp    $0x5e,%eax
  800694:	76 cb                	jbe    800661 <vprintfmt+0x2de>
            putch('?', putdat);
  800696:	4c 89 fe             	mov    %r15,%rsi
  800699:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80069e:	41 ff d5             	callq  *%r13
  8006a1:	eb c4                	jmp    800667 <vprintfmt+0x2e4>
  8006a3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006a7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006ab:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006ae:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006b2:	0f 8e f5 fc ff ff    	jle    8003ad <vprintfmt+0x2a>
          putch(' ', putdat);
  8006b8:	4c 89 fe             	mov    %r15,%rsi
  8006bb:	bf 20 00 00 00       	mov    $0x20,%edi
  8006c0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006c3:	83 eb 01             	sub    $0x1,%ebx
  8006c6:	75 f0                	jne    8006b8 <vprintfmt+0x335>
  8006c8:	e9 e0 fc ff ff       	jmpq   8003ad <vprintfmt+0x2a>
  8006cd:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006d1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006d5:	eb d4                	jmp    8006ab <vprintfmt+0x328>
  if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7f 1d                	jg     8006f9 <vprintfmt+0x376>
  else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 5e                	je     80073e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006e0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006e3:	83 f8 2f             	cmp    $0x2f,%eax
  8006e6:	77 48                	ja     800730 <vprintfmt+0x3ad>
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006ee:	83 c0 08             	add    $0x8,%eax
  8006f1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006f4:	48 8b 1a             	mov    (%rdx),%rbx
  8006f7:	eb 17                	jmp    800710 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8006f9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006fc:	83 f8 2f             	cmp    $0x2f,%eax
  8006ff:	77 21                	ja     800722 <vprintfmt+0x39f>
  800701:	89 c2                	mov    %eax,%edx
  800703:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800707:	83 c0 08             	add    $0x8,%eax
  80070a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80070d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800710:	48 85 db             	test   %rbx,%rbx
  800713:	78 50                	js     800765 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800715:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800718:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80071d:	e9 b4 01 00 00       	jmpq   8008d6 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800722:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800726:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80072a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80072e:	eb dd                	jmp    80070d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800730:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800734:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800738:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073c:	eb b6                	jmp    8006f4 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80073e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800741:	83 f8 2f             	cmp    $0x2f,%eax
  800744:	77 11                	ja     800757 <vprintfmt+0x3d4>
  800746:	89 c2                	mov    %eax,%edx
  800748:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80074c:	83 c0 08             	add    $0x8,%eax
  80074f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800752:	48 63 1a             	movslq (%rdx),%rbx
  800755:	eb b9                	jmp    800710 <vprintfmt+0x38d>
  800757:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80075b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80075f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800763:	eb ed                	jmp    800752 <vprintfmt+0x3cf>
          putch('-', putdat);
  800765:	4c 89 fe             	mov    %r15,%rsi
  800768:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80076d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800770:	48 89 da             	mov    %rbx,%rdx
  800773:	48 f7 da             	neg    %rdx
        base = 10;
  800776:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80077b:	e9 56 01 00 00       	jmpq   8008d6 <vprintfmt+0x553>
  if (lflag >= 2)
  800780:	83 f9 01             	cmp    $0x1,%ecx
  800783:	7f 25                	jg     8007aa <vprintfmt+0x427>
  else if (lflag)
  800785:	85 c9                	test   %ecx,%ecx
  800787:	74 5e                	je     8007e7 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800789:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80078c:	83 f8 2f             	cmp    $0x2f,%eax
  80078f:	77 48                	ja     8007d9 <vprintfmt+0x456>
  800791:	89 c2                	mov    %eax,%edx
  800793:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800797:	83 c0 08             	add    $0x8,%eax
  80079a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80079d:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a5:	e9 2c 01 00 00       	jmpq   8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007aa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007ad:	83 f8 2f             	cmp    $0x2f,%eax
  8007b0:	77 19                	ja     8007cb <vprintfmt+0x448>
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007b8:	83 c0 08             	add    $0x8,%eax
  8007bb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007be:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c6:	e9 0b 01 00 00       	jmpq   8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007cb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007cf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007d3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007d7:	eb e5                	jmp    8007be <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e5:	eb b6                	jmp    80079d <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007e7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007ea:	83 f8 2f             	cmp    $0x2f,%eax
  8007ed:	77 18                	ja     800807 <vprintfmt+0x484>
  8007ef:	89 c2                	mov    %eax,%edx
  8007f1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007f5:	83 c0 08             	add    $0x8,%eax
  8007f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007fb:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8007fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800802:	e9 cf 00 00 00       	jmpq   8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800807:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80080b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80080f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800813:	eb e6                	jmp    8007fb <vprintfmt+0x478>
  if (lflag >= 2)
  800815:	83 f9 01             	cmp    $0x1,%ecx
  800818:	7f 25                	jg     80083f <vprintfmt+0x4bc>
  else if (lflag)
  80081a:	85 c9                	test   %ecx,%ecx
  80081c:	74 5b                	je     800879 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80081e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800821:	83 f8 2f             	cmp    $0x2f,%eax
  800824:	77 45                	ja     80086b <vprintfmt+0x4e8>
  800826:	89 c2                	mov    %eax,%edx
  800828:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80082c:	83 c0 08             	add    $0x8,%eax
  80082f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800832:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800835:	b9 08 00 00 00       	mov    $0x8,%ecx
  80083a:	e9 97 00 00 00       	jmpq   8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80083f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800842:	83 f8 2f             	cmp    $0x2f,%eax
  800845:	77 16                	ja     80085d <vprintfmt+0x4da>
  800847:	89 c2                	mov    %eax,%edx
  800849:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80084d:	83 c0 08             	add    $0x8,%eax
  800850:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800853:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800856:	b9 08 00 00 00       	mov    $0x8,%ecx
  80085b:	eb 79                	jmp    8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80085d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800861:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800865:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800869:	eb e8                	jmp    800853 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80086b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80086f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800873:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800877:	eb b9                	jmp    800832 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800879:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80087c:	83 f8 2f             	cmp    $0x2f,%eax
  80087f:	77 15                	ja     800896 <vprintfmt+0x513>
  800881:	89 c2                	mov    %eax,%edx
  800883:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800887:	83 c0 08             	add    $0x8,%eax
  80088a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80088d:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80088f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800894:	eb 40                	jmp    8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800896:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80089a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80089e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a2:	eb e9                	jmp    80088d <vprintfmt+0x50a>
        putch('0', putdat);
  8008a4:	4c 89 fe             	mov    %r15,%rsi
  8008a7:	bf 30 00 00 00       	mov    $0x30,%edi
  8008ac:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008af:	4c 89 fe             	mov    %r15,%rsi
  8008b2:	bf 78 00 00 00       	mov    $0x78,%edi
  8008b7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008ba:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008bd:	83 f8 2f             	cmp    $0x2f,%eax
  8008c0:	77 34                	ja     8008f6 <vprintfmt+0x573>
  8008c2:	89 c2                	mov    %eax,%edx
  8008c4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008c8:	83 c0 08             	add    $0x8,%eax
  8008cb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ce:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008d1:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008d6:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008db:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008df:	4c 89 fe             	mov    %r15,%rsi
  8008e2:	4c 89 ef             	mov    %r13,%rdi
  8008e5:	48 b8 59 02 80 00 00 	movabs $0x800259,%rax
  8008ec:	00 00 00 
  8008ef:	ff d0                	callq  *%rax
        break;
  8008f1:	e9 b7 fa ff ff       	jmpq   8003ad <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008f6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008fa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008fe:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800902:	eb ca                	jmp    8008ce <vprintfmt+0x54b>
  if (lflag >= 2)
  800904:	83 f9 01             	cmp    $0x1,%ecx
  800907:	7f 22                	jg     80092b <vprintfmt+0x5a8>
  else if (lflag)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 58                	je     800965 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80090d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800910:	83 f8 2f             	cmp    $0x2f,%eax
  800913:	77 42                	ja     800957 <vprintfmt+0x5d4>
  800915:	89 c2                	mov    %eax,%edx
  800917:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091b:	83 c0 08             	add    $0x8,%eax
  80091e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800921:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800924:	b9 10 00 00 00       	mov    $0x10,%ecx
  800929:	eb ab                	jmp    8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80092b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092e:	83 f8 2f             	cmp    $0x2f,%eax
  800931:	77 16                	ja     800949 <vprintfmt+0x5c6>
  800933:	89 c2                	mov    %eax,%edx
  800935:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800939:	83 c0 08             	add    $0x8,%eax
  80093c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800942:	b9 10 00 00 00       	mov    $0x10,%ecx
  800947:	eb 8d                	jmp    8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800949:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800951:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800955:	eb e8                	jmp    80093f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800957:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80095f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800963:	eb bc                	jmp    800921 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800965:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800968:	83 f8 2f             	cmp    $0x2f,%eax
  80096b:	77 18                	ja     800985 <vprintfmt+0x602>
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800973:	83 c0 08             	add    $0x8,%eax
  800976:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800979:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80097b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800980:	e9 51 ff ff ff       	jmpq   8008d6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800985:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800989:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80098d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800991:	eb e6                	jmp    800979 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800993:	4c 89 fe             	mov    %r15,%rsi
  800996:	bf 25 00 00 00       	mov    $0x25,%edi
  80099b:	41 ff d5             	callq  *%r13
        break;
  80099e:	e9 0a fa ff ff       	jmpq   8003ad <vprintfmt+0x2a>
        putch('%', putdat);
  8009a3:	4c 89 fe             	mov    %r15,%rsi
  8009a6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009ab:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009ae:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009b2:	0f 84 15 fa ff ff    	je     8003cd <vprintfmt+0x4a>
  8009b8:	49 89 de             	mov    %rbx,%r14
  8009bb:	49 83 ee 01          	sub    $0x1,%r14
  8009bf:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009c4:	75 f5                	jne    8009bb <vprintfmt+0x638>
  8009c6:	e9 e2 f9 ff ff       	jmpq   8003ad <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009cb:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009cf:	74 06                	je     8009d7 <vprintfmt+0x654>
  8009d1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009d5:	7f 21                	jg     8009f8 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d7:	bf 28 00 00 00       	mov    $0x28,%edi
  8009dc:	48 bb c1 11 80 00 00 	movabs $0x8011c1,%rbx
  8009e3:	00 00 00 
  8009e6:	b8 28 00 00 00       	mov    $0x28,%eax
  8009eb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009ef:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009f3:	e9 82 fc ff ff       	jmpq   80067a <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009f8:	49 63 f4             	movslq %r12d,%rsi
  8009fb:	48 bf c0 11 80 00 00 	movabs $0x8011c0,%rdi
  800a02:	00 00 00 
  800a05:	48 b8 5a 0b 80 00 00 	movabs $0x800b5a,%rax
  800a0c:	00 00 00 
  800a0f:	ff d0                	callq  *%rax
  800a11:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a14:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a17:	48 be c0 11 80 00 00 	movabs $0x8011c0,%rsi
  800a1e:	00 00 00 
  800a21:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a25:	85 c0                	test   %eax,%eax
  800a27:	0f 8f f2 fb ff ff    	jg     80061f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2d:	48 bb c1 11 80 00 00 	movabs $0x8011c1,%rbx
  800a34:	00 00 00 
  800a37:	b8 28 00 00 00       	mov    $0x28,%eax
  800a3c:	bf 28 00 00 00       	mov    $0x28,%edi
  800a41:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a45:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a49:	e9 2c fc ff ff       	jmpq   80067a <vprintfmt+0x2f7>
}
  800a4e:	48 83 c4 48          	add    $0x48,%rsp
  800a52:	5b                   	pop    %rbx
  800a53:	41 5c                	pop    %r12
  800a55:	41 5d                	pop    %r13
  800a57:	41 5e                	pop    %r14
  800a59:	41 5f                	pop    %r15
  800a5b:	5d                   	pop    %rbp
  800a5c:	c3                   	retq   

0000000000800a5d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a5d:	55                   	push   %rbp
  800a5e:	48 89 e5             	mov    %rsp,%rbp
  800a61:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a65:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a69:	48 63 c6             	movslq %esi,%rax
  800a6c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a71:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a75:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a7c:	48 85 ff             	test   %rdi,%rdi
  800a7f:	74 2a                	je     800aab <vsnprintf+0x4e>
  800a81:	85 f6                	test   %esi,%esi
  800a83:	7e 26                	jle    800aab <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a85:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a89:	48 bf e5 02 80 00 00 	movabs $0x8002e5,%rdi
  800a90:	00 00 00 
  800a93:	48 b8 83 03 80 00 00 	movabs $0x800383,%rax
  800a9a:	00 00 00 
  800a9d:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800a9f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800aa3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800aa6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800aa9:	c9                   	leaveq 
  800aaa:	c3                   	retq   
    return -E_INVAL;
  800aab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ab0:	eb f7                	jmp    800aa9 <vsnprintf+0x4c>

0000000000800ab2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ab2:	55                   	push   %rbp
  800ab3:	48 89 e5             	mov    %rsp,%rbp
  800ab6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800abd:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ac4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800acb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ad2:	84 c0                	test   %al,%al
  800ad4:	74 20                	je     800af6 <snprintf+0x44>
  800ad6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ada:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800ade:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800ae2:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ae6:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800aea:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800aee:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800af2:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800af6:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800afd:	00 00 00 
  800b00:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b07:	00 00 00 
  800b0a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b0e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b15:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b1c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b23:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b2a:	48 b8 5d 0a 80 00 00 	movabs $0x800a5d,%rax
  800b31:	00 00 00 
  800b34:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b36:	c9                   	leaveq 
  800b37:	c3                   	retq   

0000000000800b38 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b38:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b3b:	74 17                	je     800b54 <strlen+0x1c>
  800b3d:	48 89 fa             	mov    %rdi,%rdx
  800b40:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b45:	29 f9                	sub    %edi,%ecx
    n++;
  800b47:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b4a:	48 83 c2 01          	add    $0x1,%rdx
  800b4e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b51:	75 f4                	jne    800b47 <strlen+0xf>
  800b53:	c3                   	retq   
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b59:	c3                   	retq   

0000000000800b5a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b5a:	48 85 f6             	test   %rsi,%rsi
  800b5d:	74 24                	je     800b83 <strnlen+0x29>
  800b5f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b62:	74 25                	je     800b89 <strnlen+0x2f>
  800b64:	48 01 fe             	add    %rdi,%rsi
  800b67:	48 89 fa             	mov    %rdi,%rdx
  800b6a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b6f:	29 f9                	sub    %edi,%ecx
    n++;
  800b71:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b74:	48 83 c2 01          	add    $0x1,%rdx
  800b78:	48 39 f2             	cmp    %rsi,%rdx
  800b7b:	74 11                	je     800b8e <strnlen+0x34>
  800b7d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b80:	75 ef                	jne    800b71 <strnlen+0x17>
  800b82:	c3                   	retq   
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	c3                   	retq   
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b8e:	c3                   	retq   

0000000000800b8f <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b8f:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800b9b:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800b9e:	48 83 c2 01          	add    $0x1,%rdx
  800ba2:	84 c9                	test   %cl,%cl
  800ba4:	75 f1                	jne    800b97 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800ba6:	c3                   	retq   

0000000000800ba7 <strcat>:

char *
strcat(char *dst, const char *src) {
  800ba7:	55                   	push   %rbp
  800ba8:	48 89 e5             	mov    %rsp,%rbp
  800bab:	41 54                	push   %r12
  800bad:	53                   	push   %rbx
  800bae:	48 89 fb             	mov    %rdi,%rbx
  800bb1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bb4:	48 b8 38 0b 80 00 00 	movabs $0x800b38,%rax
  800bbb:	00 00 00 
  800bbe:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bc0:	48 63 f8             	movslq %eax,%rdi
  800bc3:	48 01 df             	add    %rbx,%rdi
  800bc6:	4c 89 e6             	mov    %r12,%rsi
  800bc9:	48 b8 8f 0b 80 00 00 	movabs $0x800b8f,%rax
  800bd0:	00 00 00 
  800bd3:	ff d0                	callq  *%rax
  return dst;
}
  800bd5:	48 89 d8             	mov    %rbx,%rax
  800bd8:	5b                   	pop    %rbx
  800bd9:	41 5c                	pop    %r12
  800bdb:	5d                   	pop    %rbp
  800bdc:	c3                   	retq   

0000000000800bdd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bdd:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800be0:	48 85 d2             	test   %rdx,%rdx
  800be3:	74 1f                	je     800c04 <strncpy+0x27>
  800be5:	48 01 fa             	add    %rdi,%rdx
  800be8:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800beb:	48 83 c1 01          	add    $0x1,%rcx
  800bef:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bf3:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800bf7:	41 80 f8 01          	cmp    $0x1,%r8b
  800bfb:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800bff:	48 39 ca             	cmp    %rcx,%rdx
  800c02:	75 e7                	jne    800beb <strncpy+0xe>
  }
  return ret;
}
  800c04:	c3                   	retq   

0000000000800c05 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c05:	48 89 f8             	mov    %rdi,%rax
  800c08:	48 85 d2             	test   %rdx,%rdx
  800c0b:	74 36                	je     800c43 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c0d:	48 83 fa 01          	cmp    $0x1,%rdx
  800c11:	74 2d                	je     800c40 <strlcpy+0x3b>
  800c13:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c17:	45 84 c0             	test   %r8b,%r8b
  800c1a:	74 24                	je     800c40 <strlcpy+0x3b>
  800c1c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c20:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c25:	48 83 c0 01          	add    $0x1,%rax
  800c29:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c2d:	48 39 d1             	cmp    %rdx,%rcx
  800c30:	74 0e                	je     800c40 <strlcpy+0x3b>
  800c32:	48 83 c1 01          	add    $0x1,%rcx
  800c36:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c3b:	45 84 c0             	test   %r8b,%r8b
  800c3e:	75 e5                	jne    800c25 <strlcpy+0x20>
    *dst = '\0';
  800c40:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c43:	48 29 f8             	sub    %rdi,%rax
}
  800c46:	c3                   	retq   

0000000000800c47 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c47:	0f b6 07             	movzbl (%rdi),%eax
  800c4a:	84 c0                	test   %al,%al
  800c4c:	74 17                	je     800c65 <strcmp+0x1e>
  800c4e:	3a 06                	cmp    (%rsi),%al
  800c50:	75 13                	jne    800c65 <strcmp+0x1e>
    p++, q++;
  800c52:	48 83 c7 01          	add    $0x1,%rdi
  800c56:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c5a:	0f b6 07             	movzbl (%rdi),%eax
  800c5d:	84 c0                	test   %al,%al
  800c5f:	74 04                	je     800c65 <strcmp+0x1e>
  800c61:	3a 06                	cmp    (%rsi),%al
  800c63:	74 ed                	je     800c52 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c65:	0f b6 c0             	movzbl %al,%eax
  800c68:	0f b6 16             	movzbl (%rsi),%edx
  800c6b:	29 d0                	sub    %edx,%eax
}
  800c6d:	c3                   	retq   

0000000000800c6e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c6e:	48 85 d2             	test   %rdx,%rdx
  800c71:	74 2f                	je     800ca2 <strncmp+0x34>
  800c73:	0f b6 07             	movzbl (%rdi),%eax
  800c76:	84 c0                	test   %al,%al
  800c78:	74 1f                	je     800c99 <strncmp+0x2b>
  800c7a:	3a 06                	cmp    (%rsi),%al
  800c7c:	75 1b                	jne    800c99 <strncmp+0x2b>
  800c7e:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c81:	48 83 c7 01          	add    $0x1,%rdi
  800c85:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c89:	48 39 d7             	cmp    %rdx,%rdi
  800c8c:	74 1a                	je     800ca8 <strncmp+0x3a>
  800c8e:	0f b6 07             	movzbl (%rdi),%eax
  800c91:	84 c0                	test   %al,%al
  800c93:	74 04                	je     800c99 <strncmp+0x2b>
  800c95:	3a 06                	cmp    (%rsi),%al
  800c97:	74 e8                	je     800c81 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800c99:	0f b6 07             	movzbl (%rdi),%eax
  800c9c:	0f b6 16             	movzbl (%rsi),%edx
  800c9f:	29 d0                	sub    %edx,%eax
}
  800ca1:	c3                   	retq   
    return 0;
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca7:	c3                   	retq   
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cad:	c3                   	retq   

0000000000800cae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cae:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cb0:	0f b6 07             	movzbl (%rdi),%eax
  800cb3:	84 c0                	test   %al,%al
  800cb5:	74 1e                	je     800cd5 <strchr+0x27>
    if (*s == c)
  800cb7:	40 38 c6             	cmp    %al,%sil
  800cba:	74 1f                	je     800cdb <strchr+0x2d>
  for (; *s; s++)
  800cbc:	48 83 c7 01          	add    $0x1,%rdi
  800cc0:	0f b6 07             	movzbl (%rdi),%eax
  800cc3:	84 c0                	test   %al,%al
  800cc5:	74 08                	je     800ccf <strchr+0x21>
    if (*s == c)
  800cc7:	38 d0                	cmp    %dl,%al
  800cc9:	75 f1                	jne    800cbc <strchr+0xe>
  for (; *s; s++)
  800ccb:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cce:	c3                   	retq   
  return 0;
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	c3                   	retq   
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cda:	c3                   	retq   
    if (*s == c)
  800cdb:	48 89 f8             	mov    %rdi,%rax
  800cde:	c3                   	retq   

0000000000800cdf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cdf:	48 89 f8             	mov    %rdi,%rax
  800ce2:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800ce4:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800ce7:	40 38 f2             	cmp    %sil,%dl
  800cea:	74 13                	je     800cff <strfind+0x20>
  800cec:	84 d2                	test   %dl,%dl
  800cee:	74 0f                	je     800cff <strfind+0x20>
  for (; *s; s++)
  800cf0:	48 83 c0 01          	add    $0x1,%rax
  800cf4:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800cf7:	38 ca                	cmp    %cl,%dl
  800cf9:	74 04                	je     800cff <strfind+0x20>
  800cfb:	84 d2                	test   %dl,%dl
  800cfd:	75 f1                	jne    800cf0 <strfind+0x11>
      break;
  return (char *)s;
}
  800cff:	c3                   	retq   

0000000000800d00 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d00:	48 85 d2             	test   %rdx,%rdx
  800d03:	74 3a                	je     800d3f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d05:	48 89 f8             	mov    %rdi,%rax
  800d08:	48 09 d0             	or     %rdx,%rax
  800d0b:	a8 03                	test   $0x3,%al
  800d0d:	75 28                	jne    800d37 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d0f:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d13:	89 f0                	mov    %esi,%eax
  800d15:	c1 e0 08             	shl    $0x8,%eax
  800d18:	89 f1                	mov    %esi,%ecx
  800d1a:	c1 e1 18             	shl    $0x18,%ecx
  800d1d:	41 89 f0             	mov    %esi,%r8d
  800d20:	41 c1 e0 10          	shl    $0x10,%r8d
  800d24:	44 09 c1             	or     %r8d,%ecx
  800d27:	09 ce                	or     %ecx,%esi
  800d29:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d2b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d2f:	48 89 d1             	mov    %rdx,%rcx
  800d32:	fc                   	cld    
  800d33:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d35:	eb 08                	jmp    800d3f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d37:	89 f0                	mov    %esi,%eax
  800d39:	48 89 d1             	mov    %rdx,%rcx
  800d3c:	fc                   	cld    
  800d3d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d3f:	48 89 f8             	mov    %rdi,%rax
  800d42:	c3                   	retq   

0000000000800d43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d43:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d46:	48 39 fe             	cmp    %rdi,%rsi
  800d49:	73 40                	jae    800d8b <memmove+0x48>
  800d4b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d4f:	48 39 f9             	cmp    %rdi,%rcx
  800d52:	76 37                	jbe    800d8b <memmove+0x48>
    s += n;
    d += n;
  800d54:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d58:	48 89 fe             	mov    %rdi,%rsi
  800d5b:	48 09 d6             	or     %rdx,%rsi
  800d5e:	48 09 ce             	or     %rcx,%rsi
  800d61:	40 f6 c6 03          	test   $0x3,%sil
  800d65:	75 14                	jne    800d7b <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d67:	48 83 ef 04          	sub    $0x4,%rdi
  800d6b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d6f:	48 c1 ea 02          	shr    $0x2,%rdx
  800d73:	48 89 d1             	mov    %rdx,%rcx
  800d76:	fd                   	std    
  800d77:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d79:	eb 0e                	jmp    800d89 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d7b:	48 83 ef 01          	sub    $0x1,%rdi
  800d7f:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d83:	48 89 d1             	mov    %rdx,%rcx
  800d86:	fd                   	std    
  800d87:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d89:	fc                   	cld    
  800d8a:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d8b:	48 89 c1             	mov    %rax,%rcx
  800d8e:	48 09 d1             	or     %rdx,%rcx
  800d91:	48 09 f1             	or     %rsi,%rcx
  800d94:	f6 c1 03             	test   $0x3,%cl
  800d97:	75 0e                	jne    800da7 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800d99:	48 c1 ea 02          	shr    $0x2,%rdx
  800d9d:	48 89 d1             	mov    %rdx,%rcx
  800da0:	48 89 c7             	mov    %rax,%rdi
  800da3:	fc                   	cld    
  800da4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800da6:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800da7:	48 89 c7             	mov    %rax,%rdi
  800daa:	48 89 d1             	mov    %rdx,%rcx
  800dad:	fc                   	cld    
  800dae:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800db0:	c3                   	retq   

0000000000800db1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800db1:	55                   	push   %rbp
  800db2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800db5:	48 b8 43 0d 80 00 00 	movabs $0x800d43,%rax
  800dbc:	00 00 00 
  800dbf:	ff d0                	callq  *%rax
}
  800dc1:	5d                   	pop    %rbp
  800dc2:	c3                   	retq   

0000000000800dc3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dc3:	55                   	push   %rbp
  800dc4:	48 89 e5             	mov    %rsp,%rbp
  800dc7:	41 57                	push   %r15
  800dc9:	41 56                	push   %r14
  800dcb:	41 55                	push   %r13
  800dcd:	41 54                	push   %r12
  800dcf:	53                   	push   %rbx
  800dd0:	48 83 ec 08          	sub    $0x8,%rsp
  800dd4:	49 89 fe             	mov    %rdi,%r14
  800dd7:	49 89 f7             	mov    %rsi,%r15
  800dda:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800ddd:	48 89 f7             	mov    %rsi,%rdi
  800de0:	48 b8 38 0b 80 00 00 	movabs $0x800b38,%rax
  800de7:	00 00 00 
  800dea:	ff d0                	callq  *%rax
  800dec:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800def:	4c 89 ee             	mov    %r13,%rsi
  800df2:	4c 89 f7             	mov    %r14,%rdi
  800df5:	48 b8 5a 0b 80 00 00 	movabs $0x800b5a,%rax
  800dfc:	00 00 00 
  800dff:	ff d0                	callq  *%rax
  800e01:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e04:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e08:	4d 39 e5             	cmp    %r12,%r13
  800e0b:	74 26                	je     800e33 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e0d:	4c 89 e8             	mov    %r13,%rax
  800e10:	4c 29 e0             	sub    %r12,%rax
  800e13:	48 39 d8             	cmp    %rbx,%rax
  800e16:	76 2a                	jbe    800e42 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e18:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e1c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e20:	4c 89 fe             	mov    %r15,%rsi
  800e23:	48 b8 b1 0d 80 00 00 	movabs $0x800db1,%rax
  800e2a:	00 00 00 
  800e2d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e2f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e33:	48 83 c4 08          	add    $0x8,%rsp
  800e37:	5b                   	pop    %rbx
  800e38:	41 5c                	pop    %r12
  800e3a:	41 5d                	pop    %r13
  800e3c:	41 5e                	pop    %r14
  800e3e:	41 5f                	pop    %r15
  800e40:	5d                   	pop    %rbp
  800e41:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e42:	49 83 ed 01          	sub    $0x1,%r13
  800e46:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e4a:	4c 89 ea             	mov    %r13,%rdx
  800e4d:	4c 89 fe             	mov    %r15,%rsi
  800e50:	48 b8 b1 0d 80 00 00 	movabs $0x800db1,%rax
  800e57:	00 00 00 
  800e5a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e5c:	4d 01 ee             	add    %r13,%r14
  800e5f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e64:	eb c9                	jmp    800e2f <strlcat+0x6c>

0000000000800e66 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e66:	48 85 d2             	test   %rdx,%rdx
  800e69:	74 3a                	je     800ea5 <memcmp+0x3f>
    if (*s1 != *s2)
  800e6b:	0f b6 0f             	movzbl (%rdi),%ecx
  800e6e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e72:	44 38 c1             	cmp    %r8b,%cl
  800e75:	75 1d                	jne    800e94 <memcmp+0x2e>
  800e77:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e7c:	48 39 d0             	cmp    %rdx,%rax
  800e7f:	74 1e                	je     800e9f <memcmp+0x39>
    if (*s1 != *s2)
  800e81:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e85:	48 83 c0 01          	add    $0x1,%rax
  800e89:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e8f:	44 38 c1             	cmp    %r8b,%cl
  800e92:	74 e8                	je     800e7c <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e94:	0f b6 c1             	movzbl %cl,%eax
  800e97:	45 0f b6 c0          	movzbl %r8b,%r8d
  800e9b:	44 29 c0             	sub    %r8d,%eax
  800e9e:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea4:	c3                   	retq   
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eaa:	c3                   	retq   

0000000000800eab <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800eab:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800eaf:	48 39 c7             	cmp    %rax,%rdi
  800eb2:	73 19                	jae    800ecd <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800eb4:	89 f2                	mov    %esi,%edx
  800eb6:	40 38 37             	cmp    %sil,(%rdi)
  800eb9:	74 16                	je     800ed1 <memfind+0x26>
  for (; s < ends; s++)
  800ebb:	48 83 c7 01          	add    $0x1,%rdi
  800ebf:	48 39 f8             	cmp    %rdi,%rax
  800ec2:	74 08                	je     800ecc <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ec4:	38 17                	cmp    %dl,(%rdi)
  800ec6:	75 f3                	jne    800ebb <memfind+0x10>
  for (; s < ends; s++)
  800ec8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ecb:	c3                   	retq   
  800ecc:	c3                   	retq   
  for (; s < ends; s++)
  800ecd:	48 89 f8             	mov    %rdi,%rax
  800ed0:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed1:	48 89 f8             	mov    %rdi,%rax
  800ed4:	c3                   	retq   

0000000000800ed5 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ed5:	0f b6 07             	movzbl (%rdi),%eax
  800ed8:	3c 20                	cmp    $0x20,%al
  800eda:	74 04                	je     800ee0 <strtol+0xb>
  800edc:	3c 09                	cmp    $0x9,%al
  800ede:	75 0f                	jne    800eef <strtol+0x1a>
    s++;
  800ee0:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ee4:	0f b6 07             	movzbl (%rdi),%eax
  800ee7:	3c 20                	cmp    $0x20,%al
  800ee9:	74 f5                	je     800ee0 <strtol+0xb>
  800eeb:	3c 09                	cmp    $0x9,%al
  800eed:	74 f1                	je     800ee0 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800eef:	3c 2b                	cmp    $0x2b,%al
  800ef1:	74 2b                	je     800f1e <strtol+0x49>
  int neg  = 0;
  800ef3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800ef9:	3c 2d                	cmp    $0x2d,%al
  800efb:	74 2d                	je     800f2a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efd:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f03:	75 0f                	jne    800f14 <strtol+0x3f>
  800f05:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f08:	74 2c                	je     800f36 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f0a:	85 d2                	test   %edx,%edx
  800f0c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f11:	0f 44 d0             	cmove  %eax,%edx
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f19:	4c 63 d2             	movslq %edx,%r10
  800f1c:	eb 5c                	jmp    800f7a <strtol+0xa5>
    s++;
  800f1e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f22:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f28:	eb d3                	jmp    800efd <strtol+0x28>
    s++, neg = 1;
  800f2a:	48 83 c7 01          	add    $0x1,%rdi
  800f2e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f34:	eb c7                	jmp    800efd <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f36:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f3a:	74 0f                	je     800f4b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f3c:	85 d2                	test   %edx,%edx
  800f3e:	75 d4                	jne    800f14 <strtol+0x3f>
    s++, base = 8;
  800f40:	48 83 c7 01          	add    $0x1,%rdi
  800f44:	ba 08 00 00 00       	mov    $0x8,%edx
  800f49:	eb c9                	jmp    800f14 <strtol+0x3f>
    s += 2, base = 16;
  800f4b:	48 83 c7 02          	add    $0x2,%rdi
  800f4f:	ba 10 00 00 00       	mov    $0x10,%edx
  800f54:	eb be                	jmp    800f14 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f56:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f5a:	41 80 f8 19          	cmp    $0x19,%r8b
  800f5e:	77 2f                	ja     800f8f <strtol+0xba>
      dig = *s - 'a' + 10;
  800f60:	44 0f be c1          	movsbl %cl,%r8d
  800f64:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f68:	39 d1                	cmp    %edx,%ecx
  800f6a:	7d 37                	jge    800fa3 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f6c:	48 83 c7 01          	add    $0x1,%rdi
  800f70:	49 0f af c2          	imul   %r10,%rax
  800f74:	48 63 c9             	movslq %ecx,%rcx
  800f77:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f7a:	0f b6 0f             	movzbl (%rdi),%ecx
  800f7d:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f81:	41 80 f8 09          	cmp    $0x9,%r8b
  800f85:	77 cf                	ja     800f56 <strtol+0x81>
      dig = *s - '0';
  800f87:	0f be c9             	movsbl %cl,%ecx
  800f8a:	83 e9 30             	sub    $0x30,%ecx
  800f8d:	eb d9                	jmp    800f68 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f8f:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f93:	41 80 f8 19          	cmp    $0x19,%r8b
  800f97:	77 0a                	ja     800fa3 <strtol+0xce>
      dig = *s - 'A' + 10;
  800f99:	44 0f be c1          	movsbl %cl,%r8d
  800f9d:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fa1:	eb c5                	jmp    800f68 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fa3:	48 85 f6             	test   %rsi,%rsi
  800fa6:	74 03                	je     800fab <strtol+0xd6>
    *endptr = (char *)s;
  800fa8:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fab:	48 89 c2             	mov    %rax,%rdx
  800fae:	48 f7 da             	neg    %rdx
  800fb1:	45 85 c9             	test   %r9d,%r9d
  800fb4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fb8:	c3                   	retq   

0000000000800fb9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fb9:	55                   	push   %rbp
  800fba:	48 89 e5             	mov    %rsp,%rbp
  800fbd:	53                   	push   %rbx
  800fbe:	48 89 fa             	mov    %rdi,%rdx
  800fc1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc9:	48 89 c3             	mov    %rax,%rbx
  800fcc:	48 89 c7             	mov    %rax,%rdi
  800fcf:	48 89 c6             	mov    %rax,%rsi
  800fd2:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fd4:	5b                   	pop    %rbx
  800fd5:	5d                   	pop    %rbp
  800fd6:	c3                   	retq   

0000000000800fd7 <sys_cgetc>:

int
sys_cgetc(void) {
  800fd7:	55                   	push   %rbp
  800fd8:	48 89 e5             	mov    %rsp,%rbp
  800fdb:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe6:	48 89 ca             	mov    %rcx,%rdx
  800fe9:	48 89 cb             	mov    %rcx,%rbx
  800fec:	48 89 cf             	mov    %rcx,%rdi
  800fef:	48 89 ce             	mov    %rcx,%rsi
  800ff2:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ff4:	5b                   	pop    %rbx
  800ff5:	5d                   	pop    %rbp
  800ff6:	c3                   	retq   

0000000000800ff7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800ff7:	55                   	push   %rbp
  800ff8:	48 89 e5             	mov    %rsp,%rbp
  800ffb:	53                   	push   %rbx
  800ffc:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801000:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801003:	be 00 00 00 00       	mov    $0x0,%esi
  801008:	b8 03 00 00 00       	mov    $0x3,%eax
  80100d:	48 89 f1             	mov    %rsi,%rcx
  801010:	48 89 f3             	mov    %rsi,%rbx
  801013:	48 89 f7             	mov    %rsi,%rdi
  801016:	cd 30                	int    $0x30
  if (check && ret > 0)
  801018:	48 85 c0             	test   %rax,%rax
  80101b:	7f 07                	jg     801024 <sys_env_destroy+0x2d>
}
  80101d:	48 83 c4 08          	add    $0x8,%rsp
  801021:	5b                   	pop    %rbx
  801022:	5d                   	pop    %rbp
  801023:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801024:	49 89 c0             	mov    %rax,%r8
  801027:	b9 03 00 00 00       	mov    $0x3,%ecx
  80102c:	48 ba 70 15 80 00 00 	movabs $0x801570,%rdx
  801033:	00 00 00 
  801036:	be 22 00 00 00       	mov    $0x22,%esi
  80103b:	48 bf 8f 15 80 00 00 	movabs $0x80158f,%rdi
  801042:	00 00 00 
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
  80104a:	49 b9 77 10 80 00 00 	movabs $0x801077,%r9
  801051:	00 00 00 
  801054:	41 ff d1             	callq  *%r9

0000000000801057 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801057:	55                   	push   %rbp
  801058:	48 89 e5             	mov    %rsp,%rbp
  80105b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80105c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801061:	b8 02 00 00 00       	mov    $0x2,%eax
  801066:	48 89 ca             	mov    %rcx,%rdx
  801069:	48 89 cb             	mov    %rcx,%rbx
  80106c:	48 89 cf             	mov    %rcx,%rdi
  80106f:	48 89 ce             	mov    %rcx,%rsi
  801072:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801074:	5b                   	pop    %rbx
  801075:	5d                   	pop    %rbp
  801076:	c3                   	retq   

0000000000801077 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801077:	55                   	push   %rbp
  801078:	48 89 e5             	mov    %rsp,%rbp
  80107b:	41 56                	push   %r14
  80107d:	41 55                	push   %r13
  80107f:	41 54                	push   %r12
  801081:	53                   	push   %rbx
  801082:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801089:	49 89 fd             	mov    %rdi,%r13
  80108c:	41 89 f6             	mov    %esi,%r14d
  80108f:	49 89 d4             	mov    %rdx,%r12
  801092:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801099:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010a0:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010a7:	84 c0                	test   %al,%al
  8010a9:	74 26                	je     8010d1 <_panic+0x5a>
  8010ab:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010b2:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010b9:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010bd:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010c1:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010c5:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010c9:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010cd:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010d1:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010d8:	00 00 00 
  8010db:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010e2:	00 00 00 
  8010e5:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010e9:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010f0:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8010f7:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8010fe:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  801105:	00 00 00 
  801108:	48 8b 18             	mov    (%rax),%rbx
  80110b:	48 b8 57 10 80 00 00 	movabs $0x801057,%rax
  801112:	00 00 00 
  801115:	ff d0                	callq  *%rax
  801117:	45 89 f0             	mov    %r14d,%r8d
  80111a:	4c 89 e9             	mov    %r13,%rcx
  80111d:	48 89 da             	mov    %rbx,%rdx
  801120:	89 c6                	mov    %eax,%esi
  801122:	48 bf a0 15 80 00 00 	movabs $0x8015a0,%rdi
  801129:	00 00 00 
  80112c:	b8 00 00 00 00       	mov    $0x0,%eax
  801131:	48 bb c5 01 80 00 00 	movabs $0x8001c5,%rbx
  801138:	00 00 00 
  80113b:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80113d:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801144:	4c 89 e7             	mov    %r12,%rdi
  801147:	48 b8 5d 01 80 00 00 	movabs $0x80015d,%rax
  80114e:	00 00 00 
  801151:	ff d0                	callq  *%rax
  cprintf("\n");
  801153:	48 bf 8c 11 80 00 00 	movabs $0x80118c,%rdi
  80115a:	00 00 00 
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
  801162:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801164:	cc                   	int3   
  while (1)
  801165:	eb fd                	jmp    801164 <_panic+0xed>
  801167:	90                   	nop
