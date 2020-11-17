
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
  800033:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  80003a:	00 00 00 
  80003d:	b8 00 00 00 00       	mov    $0x0,%eax
  800042:	48 bb f9 01 80 00 00 	movabs $0x8001f9,%rbx
  800049:	00 00 00 
  80004c:	ff d3                	callq  *%rbx
  cprintf("i am environment %08x\n", thisenv->env_id);
  80004e:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  800055:	00 00 00 
  800058:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80005e:	48 bf ae 11 80 00 00 	movabs $0x8011ae,%rdi
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  8000c3:	48 b8 8b 10 80 00 00 	movabs $0x80108b,%rax
  8000ca:	00 00 00 
  8000cd:	ff d0                	callq  *%rax
  8000cf:	83 e0 1f             	and    $0x1f,%eax
  8000d2:	48 89 c2             	mov    %rax,%rdx
  8000d5:	48 c1 e2 05          	shl    $0x5,%rdx
  8000d9:	48 29 c2             	sub    %rax,%rdx
  8000dc:	48 89 d0             	mov    %rdx,%rax
  8000df:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000e6:	00 00 00 
  8000e9:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000ed:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000f4:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000f7:	45 85 ed             	test   %r13d,%r13d
  8000fa:	7e 0d                	jle    800109 <libmain+0x93>
    binaryname = argv[0];
  8000fc:	49 8b 06             	mov    (%r14),%rax
  8000ff:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800106:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800109:	4c 89 f6             	mov    %r14,%rsi
  80010c:	44 89 ef             	mov    %r13d,%edi
  80010f:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800116:	00 00 00 
  800119:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80011b:	48 b8 30 01 80 00 00 	movabs $0x800130,%rax
  800122:	00 00 00 
  800125:	ff d0                	callq  *%rax
#endif
}
  800127:	5b                   	pop    %rbx
  800128:	41 5c                	pop    %r12
  80012a:	41 5d                	pop    %r13
  80012c:	41 5e                	pop    %r14
  80012e:	5d                   	pop    %rbp
  80012f:	c3                   	retq   

0000000000800130 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800130:	55                   	push   %rbp
  800131:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800134:	bf 00 00 00 00       	mov    $0x0,%edi
  800139:	48 b8 2b 10 80 00 00 	movabs $0x80102b,%rax
  800140:	00 00 00 
  800143:	ff d0                	callq  *%rax
}
  800145:	5d                   	pop    %rbp
  800146:	c3                   	retq   

0000000000800147 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800147:	55                   	push   %rbp
  800148:	48 89 e5             	mov    %rsp,%rbp
  80014b:	53                   	push   %rbx
  80014c:	48 83 ec 08          	sub    $0x8,%rsp
  800150:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800153:	8b 06                	mov    (%rsi),%eax
  800155:	8d 50 01             	lea    0x1(%rax),%edx
  800158:	89 16                	mov    %edx,(%rsi)
  80015a:	48 98                	cltq   
  80015c:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800161:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800167:	74 0b                	je     800174 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800169:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80016d:	48 83 c4 08          	add    $0x8,%rsp
  800171:	5b                   	pop    %rbx
  800172:	5d                   	pop    %rbp
  800173:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800174:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800178:	be ff 00 00 00       	mov    $0xff,%esi
  80017d:	48 b8 ed 0f 80 00 00 	movabs $0x800fed,%rax
  800184:	00 00 00 
  800187:	ff d0                	callq  *%rax
    b->idx = 0;
  800189:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80018f:	eb d8                	jmp    800169 <putch+0x22>

0000000000800191 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800191:	55                   	push   %rbp
  800192:	48 89 e5             	mov    %rsp,%rbp
  800195:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80019c:	48 89 fa             	mov    %rdi,%rdx
  80019f:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8001a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8001a9:	00 00 00 
  b.cnt = 0;
  8001ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8001b3:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8001b6:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001bd:	48 bf 47 01 80 00 00 	movabs $0x800147,%rdi
  8001c4:	00 00 00 
  8001c7:	48 b8 b7 03 80 00 00 	movabs $0x8003b7,%rax
  8001ce:	00 00 00 
  8001d1:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001d3:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001da:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001e1:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001e5:	48 b8 ed 0f 80 00 00 	movabs $0x800fed,%rax
  8001ec:	00 00 00 
  8001ef:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001f7:	c9                   	leaveq 
  8001f8:	c3                   	retq   

00000000008001f9 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001f9:	55                   	push   %rbp
  8001fa:	48 89 e5             	mov    %rsp,%rbp
  8001fd:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800204:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80020b:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800212:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800219:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800220:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800227:	84 c0                	test   %al,%al
  800229:	74 20                	je     80024b <cprintf+0x52>
  80022b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80022f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800233:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800237:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80023b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80023f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800243:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800247:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80024b:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800252:	00 00 00 
  800255:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80025c:	00 00 00 
  80025f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800263:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80026a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800271:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800278:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80027f:	48 b8 91 01 80 00 00 	movabs $0x800191,%rax
  800286:	00 00 00 
  800289:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80028b:	c9                   	leaveq 
  80028c:	c3                   	retq   

000000000080028d <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80028d:	55                   	push   %rbp
  80028e:	48 89 e5             	mov    %rsp,%rbp
  800291:	41 57                	push   %r15
  800293:	41 56                	push   %r14
  800295:	41 55                	push   %r13
  800297:	41 54                	push   %r12
  800299:	53                   	push   %rbx
  80029a:	48 83 ec 18          	sub    $0x18,%rsp
  80029e:	49 89 fc             	mov    %rdi,%r12
  8002a1:	49 89 f5             	mov    %rsi,%r13
  8002a4:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8002a8:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8002ab:	41 89 cf             	mov    %ecx,%r15d
  8002ae:	49 39 d7             	cmp    %rdx,%r15
  8002b1:	76 45                	jbe    8002f8 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8002b3:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8002b7:	85 db                	test   %ebx,%ebx
  8002b9:	7e 0e                	jle    8002c9 <printnum+0x3c>
      putch(padc, putdat);
  8002bb:	4c 89 ee             	mov    %r13,%rsi
  8002be:	44 89 f7             	mov    %r14d,%edi
  8002c1:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	75 f2                	jne    8002bb <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002c9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	49 f7 f7             	div    %r15
  8002d5:	48 b8 cf 11 80 00 00 	movabs $0x8011cf,%rax
  8002dc:	00 00 00 
  8002df:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002e3:	4c 89 ee             	mov    %r13,%rsi
  8002e6:	41 ff d4             	callq  *%r12
}
  8002e9:	48 83 c4 18          	add    $0x18,%rsp
  8002ed:	5b                   	pop    %rbx
  8002ee:	41 5c                	pop    %r12
  8002f0:	41 5d                	pop    %r13
  8002f2:	41 5e                	pop    %r14
  8002f4:	41 5f                	pop    %r15
  8002f6:	5d                   	pop    %rbp
  8002f7:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800301:	49 f7 f7             	div    %r15
  800304:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800308:	48 89 c2             	mov    %rax,%rdx
  80030b:	48 b8 8d 02 80 00 00 	movabs $0x80028d,%rax
  800312:	00 00 00 
  800315:	ff d0                	callq  *%rax
  800317:	eb b0                	jmp    8002c9 <printnum+0x3c>

0000000000800319 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800319:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80031d:	48 8b 06             	mov    (%rsi),%rax
  800320:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800324:	73 0a                	jae    800330 <sprintputch+0x17>
    *b->buf++ = ch;
  800326:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80032a:	48 89 16             	mov    %rdx,(%rsi)
  80032d:	40 88 38             	mov    %dil,(%rax)
}
  800330:	c3                   	retq   

0000000000800331 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800331:	55                   	push   %rbp
  800332:	48 89 e5             	mov    %rsp,%rbp
  800335:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80033c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800343:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80034a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800351:	84 c0                	test   %al,%al
  800353:	74 20                	je     800375 <printfmt+0x44>
  800355:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800359:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80035d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800361:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800365:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800369:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80036d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800371:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800375:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80037c:	00 00 00 
  80037f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800386:	00 00 00 
  800389:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80038d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800394:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80039b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8003a2:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8003a9:	48 b8 b7 03 80 00 00 	movabs $0x8003b7,%rax
  8003b0:	00 00 00 
  8003b3:	ff d0                	callq  *%rax
}
  8003b5:	c9                   	leaveq 
  8003b6:	c3                   	retq   

00000000008003b7 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8003b7:	55                   	push   %rbp
  8003b8:	48 89 e5             	mov    %rsp,%rbp
  8003bb:	41 57                	push   %r15
  8003bd:	41 56                	push   %r14
  8003bf:	41 55                	push   %r13
  8003c1:	41 54                	push   %r12
  8003c3:	53                   	push   %rbx
  8003c4:	48 83 ec 48          	sub    $0x48,%rsp
  8003c8:	49 89 fd             	mov    %rdi,%r13
  8003cb:	49 89 f7             	mov    %rsi,%r15
  8003ce:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003d1:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003d5:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003d9:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003dd:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003e1:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003e5:	41 0f b6 3e          	movzbl (%r14),%edi
  8003e9:	83 ff 25             	cmp    $0x25,%edi
  8003ec:	74 18                	je     800406 <vprintfmt+0x4f>
      if (ch == '\0')
  8003ee:	85 ff                	test   %edi,%edi
  8003f0:	0f 84 8c 06 00 00    	je     800a82 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003f6:	4c 89 fe             	mov    %r15,%rsi
  8003f9:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003fc:	49 89 de             	mov    %rbx,%r14
  8003ff:	eb e0                	jmp    8003e1 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800401:	49 89 de             	mov    %rbx,%r14
  800404:	eb db                	jmp    8003e1 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800406:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80040a:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80040e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800415:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80041b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80041f:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800424:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80042a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800430:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800435:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80043a:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80043e:	0f b6 13             	movzbl (%rbx),%edx
  800441:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800444:	3c 55                	cmp    $0x55,%al
  800446:	0f 87 8b 05 00 00    	ja     8009d7 <vprintfmt+0x620>
  80044c:	0f b6 c0             	movzbl %al,%eax
  80044f:	49 bb 80 12 80 00 00 	movabs $0x801280,%r11
  800456:	00 00 00 
  800459:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80045d:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800460:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800464:	eb d4                	jmp    80043a <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800466:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800469:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80046d:	eb cb                	jmp    80043a <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80046f:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800472:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800476:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80047a:	8d 50 d0             	lea    -0x30(%rax),%edx
  80047d:	83 fa 09             	cmp    $0x9,%edx
  800480:	77 7e                	ja     800500 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800482:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800486:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80048a:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80048f:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800493:	8d 50 d0             	lea    -0x30(%rax),%edx
  800496:	83 fa 09             	cmp    $0x9,%edx
  800499:	76 e7                	jbe    800482 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80049b:	4c 89 f3             	mov    %r14,%rbx
  80049e:	eb 19                	jmp    8004b9 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8004a0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004a3:	83 f8 2f             	cmp    $0x2f,%eax
  8004a6:	77 2a                	ja     8004d2 <vprintfmt+0x11b>
  8004a8:	89 c2                	mov    %eax,%edx
  8004aa:	4c 01 d2             	add    %r10,%rdx
  8004ad:	83 c0 08             	add    $0x8,%eax
  8004b0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004b3:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8004b6:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004b9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004bd:	0f 89 77 ff ff ff    	jns    80043a <vprintfmt+0x83>
          width = precision, precision = -1;
  8004c3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004c7:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004cd:	e9 68 ff ff ff       	jmpq   80043a <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004d6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004da:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004de:	eb d3                	jmp    8004b3 <vprintfmt+0xfc>
        if (width < 0)
  8004e0:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004e9:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004ec:	4c 89 f3             	mov    %r14,%rbx
  8004ef:	e9 46 ff ff ff       	jmpq   80043a <vprintfmt+0x83>
  8004f4:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004f7:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004fb:	e9 3a ff ff ff       	jmpq   80043a <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800500:	4c 89 f3             	mov    %r14,%rbx
  800503:	eb b4                	jmp    8004b9 <vprintfmt+0x102>
        lflag++;
  800505:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800508:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80050b:	e9 2a ff ff ff       	jmpq   80043a <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800510:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800513:	83 f8 2f             	cmp    $0x2f,%eax
  800516:	77 19                	ja     800531 <vprintfmt+0x17a>
  800518:	89 c2                	mov    %eax,%edx
  80051a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80051e:	83 c0 08             	add    $0x8,%eax
  800521:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800524:	4c 89 fe             	mov    %r15,%rsi
  800527:	8b 3a                	mov    (%rdx),%edi
  800529:	41 ff d5             	callq  *%r13
        break;
  80052c:	e9 b0 fe ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800531:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800535:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800539:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80053d:	eb e5                	jmp    800524 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80053f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800542:	83 f8 2f             	cmp    $0x2f,%eax
  800545:	77 5b                	ja     8005a2 <vprintfmt+0x1eb>
  800547:	89 c2                	mov    %eax,%edx
  800549:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80054d:	83 c0 08             	add    $0x8,%eax
  800550:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800553:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800555:	89 c8                	mov    %ecx,%eax
  800557:	c1 f8 1f             	sar    $0x1f,%eax
  80055a:	31 c1                	xor    %eax,%ecx
  80055c:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055e:	83 f9 09             	cmp    $0x9,%ecx
  800561:	7f 4d                	jg     8005b0 <vprintfmt+0x1f9>
  800563:	48 63 c1             	movslq %ecx,%rax
  800566:	48 ba 40 15 80 00 00 	movabs $0x801540,%rdx
  80056d:	00 00 00 
  800570:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800574:	48 85 c0             	test   %rax,%rax
  800577:	74 37                	je     8005b0 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800579:	48 89 c1             	mov    %rax,%rcx
  80057c:	48 ba f0 11 80 00 00 	movabs $0x8011f0,%rdx
  800583:	00 00 00 
  800586:	4c 89 fe             	mov    %r15,%rsi
  800589:	4c 89 ef             	mov    %r13,%rdi
  80058c:	b8 00 00 00 00       	mov    $0x0,%eax
  800591:	48 bb 31 03 80 00 00 	movabs $0x800331,%rbx
  800598:	00 00 00 
  80059b:	ff d3                	callq  *%rbx
  80059d:	e9 3f fe ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8005a2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005a6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005ae:	eb a3                	jmp    800553 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8005b0:	48 ba e7 11 80 00 00 	movabs $0x8011e7,%rdx
  8005b7:	00 00 00 
  8005ba:	4c 89 fe             	mov    %r15,%rsi
  8005bd:	4c 89 ef             	mov    %r13,%rdi
  8005c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c5:	48 bb 31 03 80 00 00 	movabs $0x800331,%rbx
  8005cc:	00 00 00 
  8005cf:	ff d3                	callq  *%rbx
  8005d1:	e9 0b fe ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005d6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005d9:	83 f8 2f             	cmp    $0x2f,%eax
  8005dc:	77 4b                	ja     800629 <vprintfmt+0x272>
  8005de:	89 c2                	mov    %eax,%edx
  8005e0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005e4:	83 c0 08             	add    $0x8,%eax
  8005e7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005ea:	48 8b 02             	mov    (%rdx),%rax
  8005ed:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005f1:	48 85 c0             	test   %rax,%rax
  8005f4:	0f 84 05 04 00 00    	je     8009ff <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005fa:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005fe:	7e 06                	jle    800606 <vprintfmt+0x24f>
  800600:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800604:	75 31                	jne    800637 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80060a:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80060e:	0f b6 00             	movzbl (%rax),%eax
  800611:	0f be f8             	movsbl %al,%edi
  800614:	85 ff                	test   %edi,%edi
  800616:	0f 84 c3 00 00 00    	je     8006df <vprintfmt+0x328>
  80061c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800620:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800624:	e9 85 00 00 00       	jmpq   8006ae <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800629:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80062d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800631:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800635:	eb b3                	jmp    8005ea <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800637:	49 63 f4             	movslq %r12d,%rsi
  80063a:	48 89 c7             	mov    %rax,%rdi
  80063d:	48 b8 8e 0b 80 00 00 	movabs $0x800b8e,%rax
  800644:	00 00 00 
  800647:	ff d0                	callq  *%rax
  800649:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80064c:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80064f:	85 f6                	test   %esi,%esi
  800651:	7e 22                	jle    800675 <vprintfmt+0x2be>
            putch(padc, putdat);
  800653:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800657:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80065b:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80065f:	4c 89 fe             	mov    %r15,%rsi
  800662:	89 df                	mov    %ebx,%edi
  800664:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800667:	41 83 ec 01          	sub    $0x1,%r12d
  80066b:	75 f2                	jne    80065f <vprintfmt+0x2a8>
  80066d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800671:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800679:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80067d:	0f b6 00             	movzbl (%rax),%eax
  800680:	0f be f8             	movsbl %al,%edi
  800683:	85 ff                	test   %edi,%edi
  800685:	0f 84 56 fd ff ff    	je     8003e1 <vprintfmt+0x2a>
  80068b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80068f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800693:	eb 19                	jmp    8006ae <vprintfmt+0x2f7>
            putch(ch, putdat);
  800695:	4c 89 fe             	mov    %r15,%rsi
  800698:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069b:	41 83 ee 01          	sub    $0x1,%r14d
  80069f:	48 83 c3 01          	add    $0x1,%rbx
  8006a3:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8006a7:	0f be f8             	movsbl %al,%edi
  8006aa:	85 ff                	test   %edi,%edi
  8006ac:	74 29                	je     8006d7 <vprintfmt+0x320>
  8006ae:	45 85 e4             	test   %r12d,%r12d
  8006b1:	78 06                	js     8006b9 <vprintfmt+0x302>
  8006b3:	41 83 ec 01          	sub    $0x1,%r12d
  8006b7:	78 48                	js     800701 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006b9:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006bd:	74 d6                	je     800695 <vprintfmt+0x2de>
  8006bf:	0f be c0             	movsbl %al,%eax
  8006c2:	83 e8 20             	sub    $0x20,%eax
  8006c5:	83 f8 5e             	cmp    $0x5e,%eax
  8006c8:	76 cb                	jbe    800695 <vprintfmt+0x2de>
            putch('?', putdat);
  8006ca:	4c 89 fe             	mov    %r15,%rsi
  8006cd:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006d2:	41 ff d5             	callq  *%r13
  8006d5:	eb c4                	jmp    80069b <vprintfmt+0x2e4>
  8006d7:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006db:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006df:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006e2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006e6:	0f 8e f5 fc ff ff    	jle    8003e1 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006ec:	4c 89 fe             	mov    %r15,%rsi
  8006ef:	bf 20 00 00 00       	mov    $0x20,%edi
  8006f4:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006f7:	83 eb 01             	sub    $0x1,%ebx
  8006fa:	75 f0                	jne    8006ec <vprintfmt+0x335>
  8006fc:	e9 e0 fc ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
  800701:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800705:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800709:	eb d4                	jmp    8006df <vprintfmt+0x328>
  if (lflag >= 2)
  80070b:	83 f9 01             	cmp    $0x1,%ecx
  80070e:	7f 1d                	jg     80072d <vprintfmt+0x376>
  else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	74 5e                	je     800772 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800714:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800717:	83 f8 2f             	cmp    $0x2f,%eax
  80071a:	77 48                	ja     800764 <vprintfmt+0x3ad>
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800722:	83 c0 08             	add    $0x8,%eax
  800725:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800728:	48 8b 1a             	mov    (%rdx),%rbx
  80072b:	eb 17                	jmp    800744 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80072d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800730:	83 f8 2f             	cmp    $0x2f,%eax
  800733:	77 21                	ja     800756 <vprintfmt+0x39f>
  800735:	89 c2                	mov    %eax,%edx
  800737:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80073b:	83 c0 08             	add    $0x8,%eax
  80073e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800741:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800744:	48 85 db             	test   %rbx,%rbx
  800747:	78 50                	js     800799 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800749:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80074c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800751:	e9 b4 01 00 00       	jmpq   80090a <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800756:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80075a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80075e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800762:	eb dd                	jmp    800741 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800764:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800768:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80076c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800770:	eb b6                	jmp    800728 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800772:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800775:	83 f8 2f             	cmp    $0x2f,%eax
  800778:	77 11                	ja     80078b <vprintfmt+0x3d4>
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800780:	83 c0 08             	add    $0x8,%eax
  800783:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800786:	48 63 1a             	movslq (%rdx),%rbx
  800789:	eb b9                	jmp    800744 <vprintfmt+0x38d>
  80078b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80078f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800793:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800797:	eb ed                	jmp    800786 <vprintfmt+0x3cf>
          putch('-', putdat);
  800799:	4c 89 fe             	mov    %r15,%rsi
  80079c:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8007a1:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8007a4:	48 89 da             	mov    %rbx,%rdx
  8007a7:	48 f7 da             	neg    %rdx
        base = 10;
  8007aa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007af:	e9 56 01 00 00       	jmpq   80090a <vprintfmt+0x553>
  if (lflag >= 2)
  8007b4:	83 f9 01             	cmp    $0x1,%ecx
  8007b7:	7f 25                	jg     8007de <vprintfmt+0x427>
  else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	74 5e                	je     80081b <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007bd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c0:	83 f8 2f             	cmp    $0x2f,%eax
  8007c3:	77 48                	ja     80080d <vprintfmt+0x456>
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007cb:	83 c0 08             	add    $0x8,%eax
  8007ce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d1:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d9:	e9 2c 01 00 00       	jmpq   80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007de:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007e1:	83 f8 2f             	cmp    $0x2f,%eax
  8007e4:	77 19                	ja     8007ff <vprintfmt+0x448>
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ec:	83 c0 08             	add    $0x8,%eax
  8007ef:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007f2:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007fa:	e9 0b 01 00 00       	jmpq   80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800803:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800807:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80080b:	eb e5                	jmp    8007f2 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80080d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800811:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800815:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800819:	eb b6                	jmp    8007d1 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80081b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80081e:	83 f8 2f             	cmp    $0x2f,%eax
  800821:	77 18                	ja     80083b <vprintfmt+0x484>
  800823:	89 c2                	mov    %eax,%edx
  800825:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800829:	83 c0 08             	add    $0x8,%eax
  80082c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80082f:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800831:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800836:	e9 cf 00 00 00       	jmpq   80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80083b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80083f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800843:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800847:	eb e6                	jmp    80082f <vprintfmt+0x478>
  if (lflag >= 2)
  800849:	83 f9 01             	cmp    $0x1,%ecx
  80084c:	7f 25                	jg     800873 <vprintfmt+0x4bc>
  else if (lflag)
  80084e:	85 c9                	test   %ecx,%ecx
  800850:	74 5b                	je     8008ad <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800852:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800855:	83 f8 2f             	cmp    $0x2f,%eax
  800858:	77 45                	ja     80089f <vprintfmt+0x4e8>
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800860:	83 c0 08             	add    $0x8,%eax
  800863:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800866:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800869:	b9 08 00 00 00       	mov    $0x8,%ecx
  80086e:	e9 97 00 00 00       	jmpq   80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800873:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800876:	83 f8 2f             	cmp    $0x2f,%eax
  800879:	77 16                	ja     800891 <vprintfmt+0x4da>
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800881:	83 c0 08             	add    $0x8,%eax
  800884:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800887:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80088a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80088f:	eb 79                	jmp    80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800891:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800895:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800899:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80089d:	eb e8                	jmp    800887 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80089f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008a7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ab:	eb b9                	jmp    800866 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8008ad:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b0:	83 f8 2f             	cmp    $0x2f,%eax
  8008b3:	77 15                	ja     8008ca <vprintfmt+0x513>
  8008b5:	89 c2                	mov    %eax,%edx
  8008b7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008bb:	83 c0 08             	add    $0x8,%eax
  8008be:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c1:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008c3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008c8:	eb 40                	jmp    80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008ca:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ce:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d6:	eb e9                	jmp    8008c1 <vprintfmt+0x50a>
        putch('0', putdat);
  8008d8:	4c 89 fe             	mov    %r15,%rsi
  8008db:	bf 30 00 00 00       	mov    $0x30,%edi
  8008e0:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008e3:	4c 89 fe             	mov    %r15,%rsi
  8008e6:	bf 78 00 00 00       	mov    $0x78,%edi
  8008eb:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008ee:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f1:	83 f8 2f             	cmp    $0x2f,%eax
  8008f4:	77 34                	ja     80092a <vprintfmt+0x573>
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008fc:	83 c0 08             	add    $0x8,%eax
  8008ff:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800902:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800905:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  80090a:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  80090f:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800913:	4c 89 fe             	mov    %r15,%rsi
  800916:	4c 89 ef             	mov    %r13,%rdi
  800919:	48 b8 8d 02 80 00 00 	movabs $0x80028d,%rax
  800920:	00 00 00 
  800923:	ff d0                	callq  *%rax
        break;
  800925:	e9 b7 fa ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80092a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80092e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800932:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800936:	eb ca                	jmp    800902 <vprintfmt+0x54b>
  if (lflag >= 2)
  800938:	83 f9 01             	cmp    $0x1,%ecx
  80093b:	7f 22                	jg     80095f <vprintfmt+0x5a8>
  else if (lflag)
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	74 58                	je     800999 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800941:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800944:	83 f8 2f             	cmp    $0x2f,%eax
  800947:	77 42                	ja     80098b <vprintfmt+0x5d4>
  800949:	89 c2                	mov    %eax,%edx
  80094b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094f:	83 c0 08             	add    $0x8,%eax
  800952:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800955:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800958:	b9 10 00 00 00       	mov    $0x10,%ecx
  80095d:	eb ab                	jmp    80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80095f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800962:	83 f8 2f             	cmp    $0x2f,%eax
  800965:	77 16                	ja     80097d <vprintfmt+0x5c6>
  800967:	89 c2                	mov    %eax,%edx
  800969:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096d:	83 c0 08             	add    $0x8,%eax
  800970:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800973:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800976:	b9 10 00 00 00       	mov    $0x10,%ecx
  80097b:	eb 8d                	jmp    80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80097d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800981:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800985:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800989:	eb e8                	jmp    800973 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  80098b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80098f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800993:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800997:	eb bc                	jmp    800955 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800999:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099c:	83 f8 2f             	cmp    $0x2f,%eax
  80099f:	77 18                	ja     8009b9 <vprintfmt+0x602>
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a7:	83 c0 08             	add    $0x8,%eax
  8009aa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ad:	8b 12                	mov    (%rdx),%edx
        base = 16;
  8009af:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009b4:	e9 51 ff ff ff       	jmpq   80090a <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009b9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009bd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c5:	eb e6                	jmp    8009ad <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009c7:	4c 89 fe             	mov    %r15,%rsi
  8009ca:	bf 25 00 00 00       	mov    $0x25,%edi
  8009cf:	41 ff d5             	callq  *%r13
        break;
  8009d2:	e9 0a fa ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
        putch('%', putdat);
  8009d7:	4c 89 fe             	mov    %r15,%rsi
  8009da:	bf 25 00 00 00       	mov    $0x25,%edi
  8009df:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009e2:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009e6:	0f 84 15 fa ff ff    	je     800401 <vprintfmt+0x4a>
  8009ec:	49 89 de             	mov    %rbx,%r14
  8009ef:	49 83 ee 01          	sub    $0x1,%r14
  8009f3:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009f8:	75 f5                	jne    8009ef <vprintfmt+0x638>
  8009fa:	e9 e2 f9 ff ff       	jmpq   8003e1 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009ff:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a03:	74 06                	je     800a0b <vprintfmt+0x654>
  800a05:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a09:	7f 21                	jg     800a2c <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0b:	bf 28 00 00 00       	mov    $0x28,%edi
  800a10:	48 bb e1 11 80 00 00 	movabs $0x8011e1,%rbx
  800a17:	00 00 00 
  800a1a:	b8 28 00 00 00       	mov    $0x28,%eax
  800a1f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a23:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a27:	e9 82 fc ff ff       	jmpq   8006ae <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a2c:	49 63 f4             	movslq %r12d,%rsi
  800a2f:	48 bf e0 11 80 00 00 	movabs $0x8011e0,%rdi
  800a36:	00 00 00 
  800a39:	48 b8 8e 0b 80 00 00 	movabs $0x800b8e,%rax
  800a40:	00 00 00 
  800a43:	ff d0                	callq  *%rax
  800a45:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a48:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a4b:	48 be e0 11 80 00 00 	movabs $0x8011e0,%rsi
  800a52:	00 00 00 
  800a55:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	0f 8f f2 fb ff ff    	jg     800653 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a61:	48 bb e1 11 80 00 00 	movabs $0x8011e1,%rbx
  800a68:	00 00 00 
  800a6b:	b8 28 00 00 00       	mov    $0x28,%eax
  800a70:	bf 28 00 00 00       	mov    $0x28,%edi
  800a75:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a79:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a7d:	e9 2c fc ff ff       	jmpq   8006ae <vprintfmt+0x2f7>
}
  800a82:	48 83 c4 48          	add    $0x48,%rsp
  800a86:	5b                   	pop    %rbx
  800a87:	41 5c                	pop    %r12
  800a89:	41 5d                	pop    %r13
  800a8b:	41 5e                	pop    %r14
  800a8d:	41 5f                	pop    %r15
  800a8f:	5d                   	pop    %rbp
  800a90:	c3                   	retq   

0000000000800a91 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a91:	55                   	push   %rbp
  800a92:	48 89 e5             	mov    %rsp,%rbp
  800a95:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a99:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a9d:	48 63 c6             	movslq %esi,%rax
  800aa0:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800aa5:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800aa9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ab0:	48 85 ff             	test   %rdi,%rdi
  800ab3:	74 2a                	je     800adf <vsnprintf+0x4e>
  800ab5:	85 f6                	test   %esi,%esi
  800ab7:	7e 26                	jle    800adf <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ab9:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800abd:	48 bf 19 03 80 00 00 	movabs $0x800319,%rdi
  800ac4:	00 00 00 
  800ac7:	48 b8 b7 03 80 00 00 	movabs $0x8003b7,%rax
  800ace:	00 00 00 
  800ad1:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ad3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ad7:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ada:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800add:	c9                   	leaveq 
  800ade:	c3                   	retq   
    return -E_INVAL;
  800adf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae4:	eb f7                	jmp    800add <vsnprintf+0x4c>

0000000000800ae6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ae6:	55                   	push   %rbp
  800ae7:	48 89 e5             	mov    %rsp,%rbp
  800aea:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800af1:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800af8:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800aff:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800b06:	84 c0                	test   %al,%al
  800b08:	74 20                	je     800b2a <snprintf+0x44>
  800b0a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800b0e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800b12:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b16:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b1a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b1e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b22:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b26:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b2a:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b31:	00 00 00 
  800b34:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b3b:	00 00 00 
  800b3e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b42:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b49:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b50:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b57:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b5e:	48 b8 91 0a 80 00 00 	movabs $0x800a91,%rax
  800b65:	00 00 00 
  800b68:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b6a:	c9                   	leaveq 
  800b6b:	c3                   	retq   

0000000000800b6c <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b6c:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b6f:	74 17                	je     800b88 <strlen+0x1c>
  800b71:	48 89 fa             	mov    %rdi,%rdx
  800b74:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b79:	29 f9                	sub    %edi,%ecx
    n++;
  800b7b:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b7e:	48 83 c2 01          	add    $0x1,%rdx
  800b82:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b85:	75 f4                	jne    800b7b <strlen+0xf>
  800b87:	c3                   	retq   
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b8d:	c3                   	retq   

0000000000800b8e <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8e:	48 85 f6             	test   %rsi,%rsi
  800b91:	74 24                	je     800bb7 <strnlen+0x29>
  800b93:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b96:	74 25                	je     800bbd <strnlen+0x2f>
  800b98:	48 01 fe             	add    %rdi,%rsi
  800b9b:	48 89 fa             	mov    %rdi,%rdx
  800b9e:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ba3:	29 f9                	sub    %edi,%ecx
    n++;
  800ba5:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba8:	48 83 c2 01          	add    $0x1,%rdx
  800bac:	48 39 f2             	cmp    %rsi,%rdx
  800baf:	74 11                	je     800bc2 <strnlen+0x34>
  800bb1:	80 3a 00             	cmpb   $0x0,(%rdx)
  800bb4:	75 ef                	jne    800ba5 <strnlen+0x17>
  800bb6:	c3                   	retq   
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbc:	c3                   	retq   
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800bc2:	c3                   	retq   

0000000000800bc3 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800bc3:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bcf:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bd2:	48 83 c2 01          	add    $0x1,%rdx
  800bd6:	84 c9                	test   %cl,%cl
  800bd8:	75 f1                	jne    800bcb <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bda:	c3                   	retq   

0000000000800bdb <strcat>:

char *
strcat(char *dst, const char *src) {
  800bdb:	55                   	push   %rbp
  800bdc:	48 89 e5             	mov    %rsp,%rbp
  800bdf:	41 54                	push   %r12
  800be1:	53                   	push   %rbx
  800be2:	48 89 fb             	mov    %rdi,%rbx
  800be5:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800be8:	48 b8 6c 0b 80 00 00 	movabs $0x800b6c,%rax
  800bef:	00 00 00 
  800bf2:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bf4:	48 63 f8             	movslq %eax,%rdi
  800bf7:	48 01 df             	add    %rbx,%rdi
  800bfa:	4c 89 e6             	mov    %r12,%rsi
  800bfd:	48 b8 c3 0b 80 00 00 	movabs $0x800bc3,%rax
  800c04:	00 00 00 
  800c07:	ff d0                	callq  *%rax
  return dst;
}
  800c09:	48 89 d8             	mov    %rbx,%rax
  800c0c:	5b                   	pop    %rbx
  800c0d:	41 5c                	pop    %r12
  800c0f:	5d                   	pop    %rbp
  800c10:	c3                   	retq   

0000000000800c11 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c11:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c14:	48 85 d2             	test   %rdx,%rdx
  800c17:	74 1f                	je     800c38 <strncpy+0x27>
  800c19:	48 01 fa             	add    %rdi,%rdx
  800c1c:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c1f:	48 83 c1 01          	add    $0x1,%rcx
  800c23:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c27:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c2b:	41 80 f8 01          	cmp    $0x1,%r8b
  800c2f:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c33:	48 39 ca             	cmp    %rcx,%rdx
  800c36:	75 e7                	jne    800c1f <strncpy+0xe>
  }
  return ret;
}
  800c38:	c3                   	retq   

0000000000800c39 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c39:	48 89 f8             	mov    %rdi,%rax
  800c3c:	48 85 d2             	test   %rdx,%rdx
  800c3f:	74 36                	je     800c77 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c41:	48 83 fa 01          	cmp    $0x1,%rdx
  800c45:	74 2d                	je     800c74 <strlcpy+0x3b>
  800c47:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c4b:	45 84 c0             	test   %r8b,%r8b
  800c4e:	74 24                	je     800c74 <strlcpy+0x3b>
  800c50:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c54:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c59:	48 83 c0 01          	add    $0x1,%rax
  800c5d:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c61:	48 39 d1             	cmp    %rdx,%rcx
  800c64:	74 0e                	je     800c74 <strlcpy+0x3b>
  800c66:	48 83 c1 01          	add    $0x1,%rcx
  800c6a:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c6f:	45 84 c0             	test   %r8b,%r8b
  800c72:	75 e5                	jne    800c59 <strlcpy+0x20>
    *dst = '\0';
  800c74:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c77:	48 29 f8             	sub    %rdi,%rax
}
  800c7a:	c3                   	retq   

0000000000800c7b <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c7b:	0f b6 07             	movzbl (%rdi),%eax
  800c7e:	84 c0                	test   %al,%al
  800c80:	74 17                	je     800c99 <strcmp+0x1e>
  800c82:	3a 06                	cmp    (%rsi),%al
  800c84:	75 13                	jne    800c99 <strcmp+0x1e>
    p++, q++;
  800c86:	48 83 c7 01          	add    $0x1,%rdi
  800c8a:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c8e:	0f b6 07             	movzbl (%rdi),%eax
  800c91:	84 c0                	test   %al,%al
  800c93:	74 04                	je     800c99 <strcmp+0x1e>
  800c95:	3a 06                	cmp    (%rsi),%al
  800c97:	74 ed                	je     800c86 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c99:	0f b6 c0             	movzbl %al,%eax
  800c9c:	0f b6 16             	movzbl (%rsi),%edx
  800c9f:	29 d0                	sub    %edx,%eax
}
  800ca1:	c3                   	retq   

0000000000800ca2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800ca2:	48 85 d2             	test   %rdx,%rdx
  800ca5:	74 2f                	je     800cd6 <strncmp+0x34>
  800ca7:	0f b6 07             	movzbl (%rdi),%eax
  800caa:	84 c0                	test   %al,%al
  800cac:	74 1f                	je     800ccd <strncmp+0x2b>
  800cae:	3a 06                	cmp    (%rsi),%al
  800cb0:	75 1b                	jne    800ccd <strncmp+0x2b>
  800cb2:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800cb5:	48 83 c7 01          	add    $0x1,%rdi
  800cb9:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800cbd:	48 39 d7             	cmp    %rdx,%rdi
  800cc0:	74 1a                	je     800cdc <strncmp+0x3a>
  800cc2:	0f b6 07             	movzbl (%rdi),%eax
  800cc5:	84 c0                	test   %al,%al
  800cc7:	74 04                	je     800ccd <strncmp+0x2b>
  800cc9:	3a 06                	cmp    (%rsi),%al
  800ccb:	74 e8                	je     800cb5 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ccd:	0f b6 07             	movzbl (%rdi),%eax
  800cd0:	0f b6 16             	movzbl (%rsi),%edx
  800cd3:	29 d0                	sub    %edx,%eax
}
  800cd5:	c3                   	retq   
    return 0;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	c3                   	retq   
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	c3                   	retq   

0000000000800ce2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800ce2:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ce4:	0f b6 07             	movzbl (%rdi),%eax
  800ce7:	84 c0                	test   %al,%al
  800ce9:	74 1e                	je     800d09 <strchr+0x27>
    if (*s == c)
  800ceb:	40 38 c6             	cmp    %al,%sil
  800cee:	74 1f                	je     800d0f <strchr+0x2d>
  for (; *s; s++)
  800cf0:	48 83 c7 01          	add    $0x1,%rdi
  800cf4:	0f b6 07             	movzbl (%rdi),%eax
  800cf7:	84 c0                	test   %al,%al
  800cf9:	74 08                	je     800d03 <strchr+0x21>
    if (*s == c)
  800cfb:	38 d0                	cmp    %dl,%al
  800cfd:	75 f1                	jne    800cf0 <strchr+0xe>
  for (; *s; s++)
  800cff:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800d02:	c3                   	retq   
  return 0;
  800d03:	b8 00 00 00 00       	mov    $0x0,%eax
  800d08:	c3                   	retq   
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	c3                   	retq   
    if (*s == c)
  800d0f:	48 89 f8             	mov    %rdi,%rax
  800d12:	c3                   	retq   

0000000000800d13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800d13:	48 89 f8             	mov    %rdi,%rax
  800d16:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d18:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d1b:	40 38 f2             	cmp    %sil,%dl
  800d1e:	74 13                	je     800d33 <strfind+0x20>
  800d20:	84 d2                	test   %dl,%dl
  800d22:	74 0f                	je     800d33 <strfind+0x20>
  for (; *s; s++)
  800d24:	48 83 c0 01          	add    $0x1,%rax
  800d28:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d2b:	38 ca                	cmp    %cl,%dl
  800d2d:	74 04                	je     800d33 <strfind+0x20>
  800d2f:	84 d2                	test   %dl,%dl
  800d31:	75 f1                	jne    800d24 <strfind+0x11>
      break;
  return (char *)s;
}
  800d33:	c3                   	retq   

0000000000800d34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d34:	48 85 d2             	test   %rdx,%rdx
  800d37:	74 3a                	je     800d73 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d39:	48 89 f8             	mov    %rdi,%rax
  800d3c:	48 09 d0             	or     %rdx,%rax
  800d3f:	a8 03                	test   $0x3,%al
  800d41:	75 28                	jne    800d6b <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d43:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	c1 e0 08             	shl    $0x8,%eax
  800d4c:	89 f1                	mov    %esi,%ecx
  800d4e:	c1 e1 18             	shl    $0x18,%ecx
  800d51:	41 89 f0             	mov    %esi,%r8d
  800d54:	41 c1 e0 10          	shl    $0x10,%r8d
  800d58:	44 09 c1             	or     %r8d,%ecx
  800d5b:	09 ce                	or     %ecx,%esi
  800d5d:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d5f:	48 c1 ea 02          	shr    $0x2,%rdx
  800d63:	48 89 d1             	mov    %rdx,%rcx
  800d66:	fc                   	cld    
  800d67:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d69:	eb 08                	jmp    800d73 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d6b:	89 f0                	mov    %esi,%eax
  800d6d:	48 89 d1             	mov    %rdx,%rcx
  800d70:	fc                   	cld    
  800d71:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d73:	48 89 f8             	mov    %rdi,%rax
  800d76:	c3                   	retq   

0000000000800d77 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d77:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d7a:	48 39 fe             	cmp    %rdi,%rsi
  800d7d:	73 40                	jae    800dbf <memmove+0x48>
  800d7f:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d83:	48 39 f9             	cmp    %rdi,%rcx
  800d86:	76 37                	jbe    800dbf <memmove+0x48>
    s += n;
    d += n;
  800d88:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d8c:	48 89 fe             	mov    %rdi,%rsi
  800d8f:	48 09 d6             	or     %rdx,%rsi
  800d92:	48 09 ce             	or     %rcx,%rsi
  800d95:	40 f6 c6 03          	test   $0x3,%sil
  800d99:	75 14                	jne    800daf <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d9b:	48 83 ef 04          	sub    $0x4,%rdi
  800d9f:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800da3:	48 c1 ea 02          	shr    $0x2,%rdx
  800da7:	48 89 d1             	mov    %rdx,%rcx
  800daa:	fd                   	std    
  800dab:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dad:	eb 0e                	jmp    800dbd <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800daf:	48 83 ef 01          	sub    $0x1,%rdi
  800db3:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800db7:	48 89 d1             	mov    %rdx,%rcx
  800dba:	fd                   	std    
  800dbb:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800dbd:	fc                   	cld    
  800dbe:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800dbf:	48 89 c1             	mov    %rax,%rcx
  800dc2:	48 09 d1             	or     %rdx,%rcx
  800dc5:	48 09 f1             	or     %rsi,%rcx
  800dc8:	f6 c1 03             	test   $0x3,%cl
  800dcb:	75 0e                	jne    800ddb <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800dcd:	48 c1 ea 02          	shr    $0x2,%rdx
  800dd1:	48 89 d1             	mov    %rdx,%rcx
  800dd4:	48 89 c7             	mov    %rax,%rdi
  800dd7:	fc                   	cld    
  800dd8:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dda:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800ddb:	48 89 c7             	mov    %rax,%rdi
  800dde:	48 89 d1             	mov    %rdx,%rcx
  800de1:	fc                   	cld    
  800de2:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800de4:	c3                   	retq   

0000000000800de5 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800de5:	55                   	push   %rbp
  800de6:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800de9:	48 b8 77 0d 80 00 00 	movabs $0x800d77,%rax
  800df0:	00 00 00 
  800df3:	ff d0                	callq  *%rax
}
  800df5:	5d                   	pop    %rbp
  800df6:	c3                   	retq   

0000000000800df7 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800df7:	55                   	push   %rbp
  800df8:	48 89 e5             	mov    %rsp,%rbp
  800dfb:	41 57                	push   %r15
  800dfd:	41 56                	push   %r14
  800dff:	41 55                	push   %r13
  800e01:	41 54                	push   %r12
  800e03:	53                   	push   %rbx
  800e04:	48 83 ec 08          	sub    $0x8,%rsp
  800e08:	49 89 fe             	mov    %rdi,%r14
  800e0b:	49 89 f7             	mov    %rsi,%r15
  800e0e:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800e11:	48 89 f7             	mov    %rsi,%rdi
  800e14:	48 b8 6c 0b 80 00 00 	movabs $0x800b6c,%rax
  800e1b:	00 00 00 
  800e1e:	ff d0                	callq  *%rax
  800e20:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e23:	4c 89 ee             	mov    %r13,%rsi
  800e26:	4c 89 f7             	mov    %r14,%rdi
  800e29:	48 b8 8e 0b 80 00 00 	movabs $0x800b8e,%rax
  800e30:	00 00 00 
  800e33:	ff d0                	callq  *%rax
  800e35:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e38:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e3c:	4d 39 e5             	cmp    %r12,%r13
  800e3f:	74 26                	je     800e67 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e41:	4c 89 e8             	mov    %r13,%rax
  800e44:	4c 29 e0             	sub    %r12,%rax
  800e47:	48 39 d8             	cmp    %rbx,%rax
  800e4a:	76 2a                	jbe    800e76 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e4c:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e50:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e54:	4c 89 fe             	mov    %r15,%rsi
  800e57:	48 b8 e5 0d 80 00 00 	movabs $0x800de5,%rax
  800e5e:	00 00 00 
  800e61:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e63:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e67:	48 83 c4 08          	add    $0x8,%rsp
  800e6b:	5b                   	pop    %rbx
  800e6c:	41 5c                	pop    %r12
  800e6e:	41 5d                	pop    %r13
  800e70:	41 5e                	pop    %r14
  800e72:	41 5f                	pop    %r15
  800e74:	5d                   	pop    %rbp
  800e75:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e76:	49 83 ed 01          	sub    $0x1,%r13
  800e7a:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e7e:	4c 89 ea             	mov    %r13,%rdx
  800e81:	4c 89 fe             	mov    %r15,%rsi
  800e84:	48 b8 e5 0d 80 00 00 	movabs $0x800de5,%rax
  800e8b:	00 00 00 
  800e8e:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e90:	4d 01 ee             	add    %r13,%r14
  800e93:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e98:	eb c9                	jmp    800e63 <strlcat+0x6c>

0000000000800e9a <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e9a:	48 85 d2             	test   %rdx,%rdx
  800e9d:	74 3a                	je     800ed9 <memcmp+0x3f>
    if (*s1 != *s2)
  800e9f:	0f b6 0f             	movzbl (%rdi),%ecx
  800ea2:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ea6:	44 38 c1             	cmp    %r8b,%cl
  800ea9:	75 1d                	jne    800ec8 <memcmp+0x2e>
  800eab:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800eb0:	48 39 d0             	cmp    %rdx,%rax
  800eb3:	74 1e                	je     800ed3 <memcmp+0x39>
    if (*s1 != *s2)
  800eb5:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800eb9:	48 83 c0 01          	add    $0x1,%rax
  800ebd:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ec3:	44 38 c1             	cmp    %r8b,%cl
  800ec6:	74 e8                	je     800eb0 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ec8:	0f b6 c1             	movzbl %cl,%eax
  800ecb:	45 0f b6 c0          	movzbl %r8b,%r8d
  800ecf:	44 29 c0             	sub    %r8d,%eax
  800ed2:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	c3                   	retq   
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ede:	c3                   	retq   

0000000000800edf <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800edf:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ee3:	48 39 c7             	cmp    %rax,%rdi
  800ee6:	73 19                	jae    800f01 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	40 38 37             	cmp    %sil,(%rdi)
  800eed:	74 16                	je     800f05 <memfind+0x26>
  for (; s < ends; s++)
  800eef:	48 83 c7 01          	add    $0x1,%rdi
  800ef3:	48 39 f8             	cmp    %rdi,%rax
  800ef6:	74 08                	je     800f00 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ef8:	38 17                	cmp    %dl,(%rdi)
  800efa:	75 f3                	jne    800eef <memfind+0x10>
  for (; s < ends; s++)
  800efc:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800eff:	c3                   	retq   
  800f00:	c3                   	retq   
  for (; s < ends; s++)
  800f01:	48 89 f8             	mov    %rdi,%rax
  800f04:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800f05:	48 89 f8             	mov    %rdi,%rax
  800f08:	c3                   	retq   

0000000000800f09 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f09:	0f b6 07             	movzbl (%rdi),%eax
  800f0c:	3c 20                	cmp    $0x20,%al
  800f0e:	74 04                	je     800f14 <strtol+0xb>
  800f10:	3c 09                	cmp    $0x9,%al
  800f12:	75 0f                	jne    800f23 <strtol+0x1a>
    s++;
  800f14:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f18:	0f b6 07             	movzbl (%rdi),%eax
  800f1b:	3c 20                	cmp    $0x20,%al
  800f1d:	74 f5                	je     800f14 <strtol+0xb>
  800f1f:	3c 09                	cmp    $0x9,%al
  800f21:	74 f1                	je     800f14 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f23:	3c 2b                	cmp    $0x2b,%al
  800f25:	74 2b                	je     800f52 <strtol+0x49>
  int neg  = 0;
  800f27:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f2d:	3c 2d                	cmp    $0x2d,%al
  800f2f:	74 2d                	je     800f5e <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f31:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f37:	75 0f                	jne    800f48 <strtol+0x3f>
  800f39:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f3c:	74 2c                	je     800f6a <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f3e:	85 d2                	test   %edx,%edx
  800f40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f45:	0f 44 d0             	cmove  %eax,%edx
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f4d:	4c 63 d2             	movslq %edx,%r10
  800f50:	eb 5c                	jmp    800fae <strtol+0xa5>
    s++;
  800f52:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f56:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f5c:	eb d3                	jmp    800f31 <strtol+0x28>
    s++, neg = 1;
  800f5e:	48 83 c7 01          	add    $0x1,%rdi
  800f62:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f68:	eb c7                	jmp    800f31 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f6a:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f6e:	74 0f                	je     800f7f <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f70:	85 d2                	test   %edx,%edx
  800f72:	75 d4                	jne    800f48 <strtol+0x3f>
    s++, base = 8;
  800f74:	48 83 c7 01          	add    $0x1,%rdi
  800f78:	ba 08 00 00 00       	mov    $0x8,%edx
  800f7d:	eb c9                	jmp    800f48 <strtol+0x3f>
    s += 2, base = 16;
  800f7f:	48 83 c7 02          	add    $0x2,%rdi
  800f83:	ba 10 00 00 00       	mov    $0x10,%edx
  800f88:	eb be                	jmp    800f48 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f8a:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f8e:	41 80 f8 19          	cmp    $0x19,%r8b
  800f92:	77 2f                	ja     800fc3 <strtol+0xba>
      dig = *s - 'a' + 10;
  800f94:	44 0f be c1          	movsbl %cl,%r8d
  800f98:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f9c:	39 d1                	cmp    %edx,%ecx
  800f9e:	7d 37                	jge    800fd7 <strtol+0xce>
    s++, val = (val * base) + dig;
  800fa0:	48 83 c7 01          	add    $0x1,%rdi
  800fa4:	49 0f af c2          	imul   %r10,%rax
  800fa8:	48 63 c9             	movslq %ecx,%rcx
  800fab:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800fae:	0f b6 0f             	movzbl (%rdi),%ecx
  800fb1:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800fb5:	41 80 f8 09          	cmp    $0x9,%r8b
  800fb9:	77 cf                	ja     800f8a <strtol+0x81>
      dig = *s - '0';
  800fbb:	0f be c9             	movsbl %cl,%ecx
  800fbe:	83 e9 30             	sub    $0x30,%ecx
  800fc1:	eb d9                	jmp    800f9c <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fc3:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fc7:	41 80 f8 19          	cmp    $0x19,%r8b
  800fcb:	77 0a                	ja     800fd7 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fcd:	44 0f be c1          	movsbl %cl,%r8d
  800fd1:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fd5:	eb c5                	jmp    800f9c <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fd7:	48 85 f6             	test   %rsi,%rsi
  800fda:	74 03                	je     800fdf <strtol+0xd6>
    *endptr = (char *)s;
  800fdc:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fdf:	48 89 c2             	mov    %rax,%rdx
  800fe2:	48 f7 da             	neg    %rdx
  800fe5:	45 85 c9             	test   %r9d,%r9d
  800fe8:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fec:	c3                   	retq   

0000000000800fed <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fed:	55                   	push   %rbp
  800fee:	48 89 e5             	mov    %rsp,%rbp
  800ff1:	53                   	push   %rbx
  800ff2:	48 89 fa             	mov    %rdi,%rdx
  800ff5:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	48 89 c3             	mov    %rax,%rbx
  801000:	48 89 c7             	mov    %rax,%rdi
  801003:	48 89 c6             	mov    %rax,%rsi
  801006:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801008:	5b                   	pop    %rbx
  801009:	5d                   	pop    %rbp
  80100a:	c3                   	retq   

000000000080100b <sys_cgetc>:

int
sys_cgetc(void) {
  80100b:	55                   	push   %rbp
  80100c:	48 89 e5             	mov    %rsp,%rbp
  80100f:	53                   	push   %rbx
  asm volatile("int %1\n"
  801010:	b9 00 00 00 00       	mov    $0x0,%ecx
  801015:	b8 01 00 00 00       	mov    $0x1,%eax
  80101a:	48 89 ca             	mov    %rcx,%rdx
  80101d:	48 89 cb             	mov    %rcx,%rbx
  801020:	48 89 cf             	mov    %rcx,%rdi
  801023:	48 89 ce             	mov    %rcx,%rsi
  801026:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801028:	5b                   	pop    %rbx
  801029:	5d                   	pop    %rbp
  80102a:	c3                   	retq   

000000000080102b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80102b:	55                   	push   %rbp
  80102c:	48 89 e5             	mov    %rsp,%rbp
  80102f:	53                   	push   %rbx
  801030:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801034:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801037:	be 00 00 00 00       	mov    $0x0,%esi
  80103c:	b8 03 00 00 00       	mov    $0x3,%eax
  801041:	48 89 f1             	mov    %rsi,%rcx
  801044:	48 89 f3             	mov    %rsi,%rbx
  801047:	48 89 f7             	mov    %rsi,%rdi
  80104a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80104c:	48 85 c0             	test   %rax,%rax
  80104f:	7f 07                	jg     801058 <sys_env_destroy+0x2d>
}
  801051:	48 83 c4 08          	add    $0x8,%rsp
  801055:	5b                   	pop    %rbx
  801056:	5d                   	pop    %rbp
  801057:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801058:	49 89 c0             	mov    %rax,%r8
  80105b:	b9 03 00 00 00       	mov    $0x3,%ecx
  801060:	48 ba 90 15 80 00 00 	movabs $0x801590,%rdx
  801067:	00 00 00 
  80106a:	be 22 00 00 00       	mov    $0x22,%esi
  80106f:	48 bf af 15 80 00 00 	movabs $0x8015af,%rdi
  801076:	00 00 00 
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
  80107e:	49 b9 ab 10 80 00 00 	movabs $0x8010ab,%r9
  801085:	00 00 00 
  801088:	41 ff d1             	callq  *%r9

000000000080108b <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80108b:	55                   	push   %rbp
  80108c:	48 89 e5             	mov    %rsp,%rbp
  80108f:	53                   	push   %rbx
  asm volatile("int %1\n"
  801090:	b9 00 00 00 00       	mov    $0x0,%ecx
  801095:	b8 02 00 00 00       	mov    $0x2,%eax
  80109a:	48 89 ca             	mov    %rcx,%rdx
  80109d:	48 89 cb             	mov    %rcx,%rbx
  8010a0:	48 89 cf             	mov    %rcx,%rdi
  8010a3:	48 89 ce             	mov    %rcx,%rsi
  8010a6:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010a8:	5b                   	pop    %rbx
  8010a9:	5d                   	pop    %rbp
  8010aa:	c3                   	retq   

00000000008010ab <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8010ab:	55                   	push   %rbp
  8010ac:	48 89 e5             	mov    %rsp,%rbp
  8010af:	41 56                	push   %r14
  8010b1:	41 55                	push   %r13
  8010b3:	41 54                	push   %r12
  8010b5:	53                   	push   %rbx
  8010b6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8010bd:	49 89 fd             	mov    %rdi,%r13
  8010c0:	41 89 f6             	mov    %esi,%r14d
  8010c3:	49 89 d4             	mov    %rdx,%r12
  8010c6:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8010cd:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010d4:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010db:	84 c0                	test   %al,%al
  8010dd:	74 26                	je     801105 <_panic+0x5a>
  8010df:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010e6:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010ed:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010f1:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010f5:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010f9:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010fd:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801101:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801105:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80110c:	00 00 00 
  80110f:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801116:	00 00 00 
  801119:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80111d:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801124:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80112b:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801132:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  801139:	00 00 00 
  80113c:	48 8b 18             	mov    (%rax),%rbx
  80113f:	48 b8 8b 10 80 00 00 	movabs $0x80108b,%rax
  801146:	00 00 00 
  801149:	ff d0                	callq  *%rax
  80114b:	45 89 f0             	mov    %r14d,%r8d
  80114e:	4c 89 e9             	mov    %r13,%rcx
  801151:	48 89 da             	mov    %rbx,%rdx
  801154:	89 c6                	mov    %eax,%esi
  801156:	48 bf c0 15 80 00 00 	movabs $0x8015c0,%rdi
  80115d:	00 00 00 
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
  801165:	48 bb f9 01 80 00 00 	movabs $0x8001f9,%rbx
  80116c:	00 00 00 
  80116f:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801171:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801178:	4c 89 e7             	mov    %r12,%rdi
  80117b:	48 b8 91 01 80 00 00 	movabs $0x800191,%rax
  801182:	00 00 00 
  801185:	ff d0                	callq  *%rax
  cprintf("\n");
  801187:	48 bf ac 11 80 00 00 	movabs $0x8011ac,%rdi
  80118e:	00 00 00 
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801198:	cc                   	int3   
  while (1)
  801199:	eb fd                	jmp    801198 <_panic+0xed>
  80119b:	90                   	nop
