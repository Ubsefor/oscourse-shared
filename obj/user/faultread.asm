
obj/user/faultread:     file format elf64-x86-64


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
  800023:	e8 2a 00 00 00       	callq  800052 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// buggy program - faults with a read from location zero

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  cprintf("I read %08x from location 0!\n", *(volatile unsigned *)0);
  80002e:	8b 34 25 00 00 00 00 	mov    0x0,%esi
  800035:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  80003c:	00 00 00 
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
  800044:	48 ba a1 01 80 00 00 	movabs $0x8001a1,%rdx
  80004b:	00 00 00 
  80004e:	ff d2                	callq  *%rdx
}
  800050:	5d                   	pop    %rbp
  800051:	c3                   	retq   

0000000000800052 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800052:	55                   	push   %rbp
  800053:	48 89 e5             	mov    %rsp,%rbp
  800056:	41 56                	push   %r14
  800058:	41 55                	push   %r13
  80005a:	41 54                	push   %r12
  80005c:	53                   	push   %rbx
  80005d:	41 89 fd             	mov    %edi,%r13d
  800060:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800063:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80006a:	00 00 00 
  80006d:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800074:	00 00 00 
  800077:	48 39 c2             	cmp    %rax,%rdx
  80007a:	73 23                	jae    80009f <libmain+0x4d>
  80007c:	48 89 d3             	mov    %rdx,%rbx
  80007f:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800083:	48 29 d0             	sub    %rdx,%rax
  800086:	48 c1 e8 03          	shr    $0x3,%rax
  80008a:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
  800094:	ff 13                	callq  *(%rbx)
    ctor++;
  800096:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80009a:	4c 39 e3             	cmp    %r12,%rbx
  80009d:	75 f0                	jne    80008f <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80009f:	45 85 ed             	test   %r13d,%r13d
  8000a2:	7e 0d                	jle    8000b1 <libmain+0x5f>
    binaryname = argv[0];
  8000a4:	49 8b 06             	mov    (%r14),%rax
  8000a7:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000ae:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000b1:	4c 89 f6             	mov    %r14,%rsi
  8000b4:	44 89 ef             	mov    %r13d,%edi
  8000b7:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000be:	00 00 00 
  8000c1:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000c3:	48 b8 d8 00 80 00 00 	movabs $0x8000d8,%rax
  8000ca:	00 00 00 
  8000cd:	ff d0                	callq  *%rax
#endif
}
  8000cf:	5b                   	pop    %rbx
  8000d0:	41 5c                	pop    %r12
  8000d2:	41 5d                	pop    %r13
  8000d4:	41 5e                	pop    %r14
  8000d6:	5d                   	pop    %rbp
  8000d7:	c3                   	retq   

00000000008000d8 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000d8:	55                   	push   %rbp
  8000d9:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8000e1:	48 b8 d3 0f 80 00 00 	movabs $0x800fd3,%rax
  8000e8:	00 00 00 
  8000eb:	ff d0                	callq  *%rax
}
  8000ed:	5d                   	pop    %rbp
  8000ee:	c3                   	retq   

00000000008000ef <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8000ef:	55                   	push   %rbp
  8000f0:	48 89 e5             	mov    %rsp,%rbp
  8000f3:	53                   	push   %rbx
  8000f4:	48 83 ec 08          	sub    $0x8,%rsp
  8000f8:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8000fb:	8b 06                	mov    (%rsi),%eax
  8000fd:	8d 50 01             	lea    0x1(%rax),%edx
  800100:	89 16                	mov    %edx,(%rsi)
  800102:	48 98                	cltq   
  800104:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800109:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80010f:	74 0b                	je     80011c <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800115:	48 83 c4 08          	add    $0x8,%rsp
  800119:	5b                   	pop    %rbx
  80011a:	5d                   	pop    %rbp
  80011b:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80011c:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800120:	be ff 00 00 00       	mov    $0xff,%esi
  800125:	48 b8 95 0f 80 00 00 	movabs $0x800f95,%rax
  80012c:	00 00 00 
  80012f:	ff d0                	callq  *%rax
    b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800137:	eb d8                	jmp    800111 <putch+0x22>

0000000000800139 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800139:	55                   	push   %rbp
  80013a:	48 89 e5             	mov    %rsp,%rbp
  80013d:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800144:	48 89 fa             	mov    %rdi,%rdx
  800147:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80014a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800151:	00 00 00 
  b.cnt = 0;
  800154:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80015b:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80015e:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800165:	48 bf ef 00 80 00 00 	movabs $0x8000ef,%rdi
  80016c:	00 00 00 
  80016f:	48 b8 5f 03 80 00 00 	movabs $0x80035f,%rax
  800176:	00 00 00 
  800179:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80017b:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800182:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800189:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80018d:	48 b8 95 0f 80 00 00 	movabs $0x800f95,%rax
  800194:	00 00 00 
  800197:	ff d0                	callq  *%rax

  return b.cnt;
}
  800199:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80019f:	c9                   	leaveq 
  8001a0:	c3                   	retq   

00000000008001a1 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001a1:	55                   	push   %rbp
  8001a2:	48 89 e5             	mov    %rsp,%rbp
  8001a5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001ac:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001b3:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001ba:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001c1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001c8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001cf:	84 c0                	test   %al,%al
  8001d1:	74 20                	je     8001f3 <cprintf+0x52>
  8001d3:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8001d7:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8001db:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8001df:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8001e3:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8001e7:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8001eb:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8001ef:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8001f3:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8001fa:	00 00 00 
  8001fd:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800204:	00 00 00 
  800207:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80020b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800212:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800219:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800220:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800227:	48 b8 39 01 80 00 00 	movabs $0x800139,%rax
  80022e:	00 00 00 
  800231:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800233:	c9                   	leaveq 
  800234:	c3                   	retq   

0000000000800235 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800235:	55                   	push   %rbp
  800236:	48 89 e5             	mov    %rsp,%rbp
  800239:	41 57                	push   %r15
  80023b:	41 56                	push   %r14
  80023d:	41 55                	push   %r13
  80023f:	41 54                	push   %r12
  800241:	53                   	push   %rbx
  800242:	48 83 ec 18          	sub    $0x18,%rsp
  800246:	49 89 fc             	mov    %rdi,%r12
  800249:	49 89 f5             	mov    %rsi,%r13
  80024c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800250:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800253:	41 89 cf             	mov    %ecx,%r15d
  800256:	49 39 d7             	cmp    %rdx,%r15
  800259:	76 45                	jbe    8002a0 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80025b:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80025f:	85 db                	test   %ebx,%ebx
  800261:	7e 0e                	jle    800271 <printnum+0x3c>
      putch(padc, putdat);
  800263:	4c 89 ee             	mov    %r13,%rsi
  800266:	44 89 f7             	mov    %r14d,%edi
  800269:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80026c:	83 eb 01             	sub    $0x1,%ebx
  80026f:	75 f2                	jne    800263 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800271:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	49 f7 f7             	div    %r15
  80027d:	48 b8 88 11 80 00 00 	movabs $0x801188,%rax
  800284:	00 00 00 
  800287:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80028b:	4c 89 ee             	mov    %r13,%rsi
  80028e:	41 ff d4             	callq  *%r12
}
  800291:	48 83 c4 18          	add    $0x18,%rsp
  800295:	5b                   	pop    %rbx
  800296:	41 5c                	pop    %r12
  800298:	41 5d                	pop    %r13
  80029a:	41 5e                	pop    %r14
  80029c:	41 5f                	pop    %r15
  80029e:	5d                   	pop    %rbp
  80029f:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a9:	49 f7 f7             	div    %r15
  8002ac:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002b0:	48 89 c2             	mov    %rax,%rdx
  8002b3:	48 b8 35 02 80 00 00 	movabs $0x800235,%rax
  8002ba:	00 00 00 
  8002bd:	ff d0                	callq  *%rax
  8002bf:	eb b0                	jmp    800271 <printnum+0x3c>

00000000008002c1 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002c1:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002c5:	48 8b 06             	mov    (%rsi),%rax
  8002c8:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002cc:	73 0a                	jae    8002d8 <sprintputch+0x17>
    *b->buf++ = ch;
  8002ce:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8002d2:	48 89 16             	mov    %rdx,(%rsi)
  8002d5:	40 88 38             	mov    %dil,(%rax)
}
  8002d8:	c3                   	retq   

00000000008002d9 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8002d9:	55                   	push   %rbp
  8002da:	48 89 e5             	mov    %rsp,%rbp
  8002dd:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002e4:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002eb:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8002f2:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8002f9:	84 c0                	test   %al,%al
  8002fb:	74 20                	je     80031d <printfmt+0x44>
  8002fd:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800301:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800305:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800309:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80030d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800311:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800315:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800319:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80031d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800324:	00 00 00 
  800327:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80032e:	00 00 00 
  800331:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800335:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80033c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800343:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80034a:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800351:	48 b8 5f 03 80 00 00 	movabs $0x80035f,%rax
  800358:	00 00 00 
  80035b:	ff d0                	callq  *%rax
}
  80035d:	c9                   	leaveq 
  80035e:	c3                   	retq   

000000000080035f <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80035f:	55                   	push   %rbp
  800360:	48 89 e5             	mov    %rsp,%rbp
  800363:	41 57                	push   %r15
  800365:	41 56                	push   %r14
  800367:	41 55                	push   %r13
  800369:	41 54                	push   %r12
  80036b:	53                   	push   %rbx
  80036c:	48 83 ec 48          	sub    $0x48,%rsp
  800370:	49 89 fd             	mov    %rdi,%r13
  800373:	49 89 f7             	mov    %rsi,%r15
  800376:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800379:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80037d:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800381:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800385:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800389:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80038d:	41 0f b6 3e          	movzbl (%r14),%edi
  800391:	83 ff 25             	cmp    $0x25,%edi
  800394:	74 18                	je     8003ae <vprintfmt+0x4f>
      if (ch == '\0')
  800396:	85 ff                	test   %edi,%edi
  800398:	0f 84 8c 06 00 00    	je     800a2a <vprintfmt+0x6cb>
      putch(ch, putdat);
  80039e:	4c 89 fe             	mov    %r15,%rsi
  8003a1:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003a4:	49 89 de             	mov    %rbx,%r14
  8003a7:	eb e0                	jmp    800389 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003a9:	49 89 de             	mov    %rbx,%r14
  8003ac:	eb db                	jmp    800389 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003ae:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003b2:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003b6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003bd:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003c3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003c7:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003cc:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8003d2:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8003d8:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8003dd:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8003e2:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8003e6:	0f b6 13             	movzbl (%rbx),%edx
  8003e9:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8003ec:	3c 55                	cmp    $0x55,%al
  8003ee:	0f 87 8b 05 00 00    	ja     80097f <vprintfmt+0x620>
  8003f4:	0f b6 c0             	movzbl %al,%eax
  8003f7:	49 bb 40 12 80 00 00 	movabs $0x801240,%r11
  8003fe:	00 00 00 
  800401:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800405:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800408:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80040c:	eb d4                	jmp    8003e2 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80040e:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800411:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800415:	eb cb                	jmp    8003e2 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800417:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80041a:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80041e:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800422:	8d 50 d0             	lea    -0x30(%rax),%edx
  800425:	83 fa 09             	cmp    $0x9,%edx
  800428:	77 7e                	ja     8004a8 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80042a:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80042e:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800432:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800437:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80043b:	8d 50 d0             	lea    -0x30(%rax),%edx
  80043e:	83 fa 09             	cmp    $0x9,%edx
  800441:	76 e7                	jbe    80042a <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800443:	4c 89 f3             	mov    %r14,%rbx
  800446:	eb 19                	jmp    800461 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800448:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80044b:	83 f8 2f             	cmp    $0x2f,%eax
  80044e:	77 2a                	ja     80047a <vprintfmt+0x11b>
  800450:	89 c2                	mov    %eax,%edx
  800452:	4c 01 d2             	add    %r10,%rdx
  800455:	83 c0 08             	add    $0x8,%eax
  800458:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80045b:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80045e:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800461:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800465:	0f 89 77 ff ff ff    	jns    8003e2 <vprintfmt+0x83>
          width = precision, precision = -1;
  80046b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80046f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800475:	e9 68 ff ff ff       	jmpq   8003e2 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80047a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80047e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800482:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800486:	eb d3                	jmp    80045b <vprintfmt+0xfc>
        if (width < 0)
  800488:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	41 0f 48 c0          	cmovs  %r8d,%eax
  800491:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800494:	4c 89 f3             	mov    %r14,%rbx
  800497:	e9 46 ff ff ff       	jmpq   8003e2 <vprintfmt+0x83>
  80049c:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80049f:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004a3:	e9 3a ff ff ff       	jmpq   8003e2 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004a8:	4c 89 f3             	mov    %r14,%rbx
  8004ab:	eb b4                	jmp    800461 <vprintfmt+0x102>
        lflag++;
  8004ad:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004b0:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004b3:	e9 2a ff ff ff       	jmpq   8003e2 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004b8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004bb:	83 f8 2f             	cmp    $0x2f,%eax
  8004be:	77 19                	ja     8004d9 <vprintfmt+0x17a>
  8004c0:	89 c2                	mov    %eax,%edx
  8004c2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004c6:	83 c0 08             	add    $0x8,%eax
  8004c9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004cc:	4c 89 fe             	mov    %r15,%rsi
  8004cf:	8b 3a                	mov    (%rdx),%edi
  8004d1:	41 ff d5             	callq  *%r13
        break;
  8004d4:	e9 b0 fe ff ff       	jmpq   800389 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8004d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004e5:	eb e5                	jmp    8004cc <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8004e7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004ea:	83 f8 2f             	cmp    $0x2f,%eax
  8004ed:	77 5b                	ja     80054a <vprintfmt+0x1eb>
  8004ef:	89 c2                	mov    %eax,%edx
  8004f1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004f5:	83 c0 08             	add    $0x8,%eax
  8004f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004fb:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8004fd:	89 c8                	mov    %ecx,%eax
  8004ff:	c1 f8 1f             	sar    $0x1f,%eax
  800502:	31 c1                	xor    %eax,%ecx
  800504:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800506:	83 f9 09             	cmp    $0x9,%ecx
  800509:	7f 4d                	jg     800558 <vprintfmt+0x1f9>
  80050b:	48 63 c1             	movslq %ecx,%rax
  80050e:	48 ba 00 15 80 00 00 	movabs $0x801500,%rdx
  800515:	00 00 00 
  800518:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80051c:	48 85 c0             	test   %rax,%rax
  80051f:	74 37                	je     800558 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800521:	48 89 c1             	mov    %rax,%rcx
  800524:	48 ba a9 11 80 00 00 	movabs $0x8011a9,%rdx
  80052b:	00 00 00 
  80052e:	4c 89 fe             	mov    %r15,%rsi
  800531:	4c 89 ef             	mov    %r13,%rdi
  800534:	b8 00 00 00 00       	mov    $0x0,%eax
  800539:	48 bb d9 02 80 00 00 	movabs $0x8002d9,%rbx
  800540:	00 00 00 
  800543:	ff d3                	callq  *%rbx
  800545:	e9 3f fe ff ff       	jmpq   800389 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80054a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80054e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800552:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800556:	eb a3                	jmp    8004fb <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800558:	48 ba a0 11 80 00 00 	movabs $0x8011a0,%rdx
  80055f:	00 00 00 
  800562:	4c 89 fe             	mov    %r15,%rsi
  800565:	4c 89 ef             	mov    %r13,%rdi
  800568:	b8 00 00 00 00       	mov    $0x0,%eax
  80056d:	48 bb d9 02 80 00 00 	movabs $0x8002d9,%rbx
  800574:	00 00 00 
  800577:	ff d3                	callq  *%rbx
  800579:	e9 0b fe ff ff       	jmpq   800389 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80057e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800581:	83 f8 2f             	cmp    $0x2f,%eax
  800584:	77 4b                	ja     8005d1 <vprintfmt+0x272>
  800586:	89 c2                	mov    %eax,%edx
  800588:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80058c:	83 c0 08             	add    $0x8,%eax
  80058f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800592:	48 8b 02             	mov    (%rdx),%rax
  800595:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800599:	48 85 c0             	test   %rax,%rax
  80059c:	0f 84 05 04 00 00    	je     8009a7 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005a2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005a6:	7e 06                	jle    8005ae <vprintfmt+0x24f>
  8005a8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005ac:	75 31                	jne    8005df <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005b2:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005b6:	0f b6 00             	movzbl (%rax),%eax
  8005b9:	0f be f8             	movsbl %al,%edi
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	0f 84 c3 00 00 00    	je     800687 <vprintfmt+0x328>
  8005c4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005c8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005cc:	e9 85 00 00 00       	jmpq   800656 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005d1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005d5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005d9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005dd:	eb b3                	jmp    800592 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	49 63 f4             	movslq %r12d,%rsi
  8005e2:	48 89 c7             	mov    %rax,%rdi
  8005e5:	48 b8 36 0b 80 00 00 	movabs $0x800b36,%rax
  8005ec:	00 00 00 
  8005ef:	ff d0                	callq  *%rax
  8005f1:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8005f4:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8005f7:	85 f6                	test   %esi,%esi
  8005f9:	7e 22                	jle    80061d <vprintfmt+0x2be>
            putch(padc, putdat);
  8005fb:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8005ff:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800603:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800607:	4c 89 fe             	mov    %r15,%rsi
  80060a:	89 df                	mov    %ebx,%edi
  80060c:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	41 83 ec 01          	sub    $0x1,%r12d
  800613:	75 f2                	jne    800607 <vprintfmt+0x2a8>
  800615:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800619:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800621:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800625:	0f b6 00             	movzbl (%rax),%eax
  800628:	0f be f8             	movsbl %al,%edi
  80062b:	85 ff                	test   %edi,%edi
  80062d:	0f 84 56 fd ff ff    	je     800389 <vprintfmt+0x2a>
  800633:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800637:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80063b:	eb 19                	jmp    800656 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80063d:	4c 89 fe             	mov    %r15,%rsi
  800640:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800643:	41 83 ee 01          	sub    $0x1,%r14d
  800647:	48 83 c3 01          	add    $0x1,%rbx
  80064b:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80064f:	0f be f8             	movsbl %al,%edi
  800652:	85 ff                	test   %edi,%edi
  800654:	74 29                	je     80067f <vprintfmt+0x320>
  800656:	45 85 e4             	test   %r12d,%r12d
  800659:	78 06                	js     800661 <vprintfmt+0x302>
  80065b:	41 83 ec 01          	sub    $0x1,%r12d
  80065f:	78 48                	js     8006a9 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800661:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800665:	74 d6                	je     80063d <vprintfmt+0x2de>
  800667:	0f be c0             	movsbl %al,%eax
  80066a:	83 e8 20             	sub    $0x20,%eax
  80066d:	83 f8 5e             	cmp    $0x5e,%eax
  800670:	76 cb                	jbe    80063d <vprintfmt+0x2de>
            putch('?', putdat);
  800672:	4c 89 fe             	mov    %r15,%rsi
  800675:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80067a:	41 ff d5             	callq  *%r13
  80067d:	eb c4                	jmp    800643 <vprintfmt+0x2e4>
  80067f:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800683:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800687:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80068a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80068e:	0f 8e f5 fc ff ff    	jle    800389 <vprintfmt+0x2a>
          putch(' ', putdat);
  800694:	4c 89 fe             	mov    %r15,%rsi
  800697:	bf 20 00 00 00       	mov    $0x20,%edi
  80069c:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80069f:	83 eb 01             	sub    $0x1,%ebx
  8006a2:	75 f0                	jne    800694 <vprintfmt+0x335>
  8006a4:	e9 e0 fc ff ff       	jmpq   800389 <vprintfmt+0x2a>
  8006a9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006ad:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006b1:	eb d4                	jmp    800687 <vprintfmt+0x328>
  if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7f 1d                	jg     8006d5 <vprintfmt+0x376>
  else if (lflag)
  8006b8:	85 c9                	test   %ecx,%ecx
  8006ba:	74 5e                	je     80071a <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006bc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006bf:	83 f8 2f             	cmp    $0x2f,%eax
  8006c2:	77 48                	ja     80070c <vprintfmt+0x3ad>
  8006c4:	89 c2                	mov    %eax,%edx
  8006c6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006ca:	83 c0 08             	add    $0x8,%eax
  8006cd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006d0:	48 8b 1a             	mov    (%rdx),%rbx
  8006d3:	eb 17                	jmp    8006ec <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8006d5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006d8:	83 f8 2f             	cmp    $0x2f,%eax
  8006db:	77 21                	ja     8006fe <vprintfmt+0x39f>
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006e3:	83 c0 08             	add    $0x8,%eax
  8006e6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006e9:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8006ec:	48 85 db             	test   %rbx,%rbx
  8006ef:	78 50                	js     800741 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8006f1:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8006f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f9:	e9 b4 01 00 00       	jmpq   8008b2 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8006fe:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800702:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800706:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80070a:	eb dd                	jmp    8006e9 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80070c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800710:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800714:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800718:	eb b6                	jmp    8006d0 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80071a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80071d:	83 f8 2f             	cmp    $0x2f,%eax
  800720:	77 11                	ja     800733 <vprintfmt+0x3d4>
  800722:	89 c2                	mov    %eax,%edx
  800724:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800728:	83 c0 08             	add    $0x8,%eax
  80072b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80072e:	48 63 1a             	movslq (%rdx),%rbx
  800731:	eb b9                	jmp    8006ec <vprintfmt+0x38d>
  800733:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800737:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80073b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073f:	eb ed                	jmp    80072e <vprintfmt+0x3cf>
          putch('-', putdat);
  800741:	4c 89 fe             	mov    %r15,%rsi
  800744:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800749:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80074c:	48 89 da             	mov    %rbx,%rdx
  80074f:	48 f7 da             	neg    %rdx
        base = 10;
  800752:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800757:	e9 56 01 00 00       	jmpq   8008b2 <vprintfmt+0x553>
  if (lflag >= 2)
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7f 25                	jg     800786 <vprintfmt+0x427>
  else if (lflag)
  800761:	85 c9                	test   %ecx,%ecx
  800763:	74 5e                	je     8007c3 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800765:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800768:	83 f8 2f             	cmp    $0x2f,%eax
  80076b:	77 48                	ja     8007b5 <vprintfmt+0x456>
  80076d:	89 c2                	mov    %eax,%edx
  80076f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800773:	83 c0 08             	add    $0x8,%eax
  800776:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800779:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80077c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800781:	e9 2c 01 00 00       	jmpq   8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800786:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800789:	83 f8 2f             	cmp    $0x2f,%eax
  80078c:	77 19                	ja     8007a7 <vprintfmt+0x448>
  80078e:	89 c2                	mov    %eax,%edx
  800790:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800794:	83 c0 08             	add    $0x8,%eax
  800797:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80079a:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80079d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a2:	e9 0b 01 00 00       	jmpq   8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007a7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007af:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b3:	eb e5                	jmp    80079a <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007b5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007b9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007bd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007c1:	eb b6                	jmp    800779 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007c3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c6:	83 f8 2f             	cmp    $0x2f,%eax
  8007c9:	77 18                	ja     8007e3 <vprintfmt+0x484>
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d1:	83 c0 08             	add    $0x8,%eax
  8007d4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d7:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8007d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007de:	e9 cf 00 00 00       	jmpq   8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8007e3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007eb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007ef:	eb e6                	jmp    8007d7 <vprintfmt+0x478>
  if (lflag >= 2)
  8007f1:	83 f9 01             	cmp    $0x1,%ecx
  8007f4:	7f 25                	jg     80081b <vprintfmt+0x4bc>
  else if (lflag)
  8007f6:	85 c9                	test   %ecx,%ecx
  8007f8:	74 5b                	je     800855 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8007fa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007fd:	83 f8 2f             	cmp    $0x2f,%eax
  800800:	77 45                	ja     800847 <vprintfmt+0x4e8>
  800802:	89 c2                	mov    %eax,%edx
  800804:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800808:	83 c0 08             	add    $0x8,%eax
  80080b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80080e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800811:	b9 08 00 00 00       	mov    $0x8,%ecx
  800816:	e9 97 00 00 00       	jmpq   8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80081b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80081e:	83 f8 2f             	cmp    $0x2f,%eax
  800821:	77 16                	ja     800839 <vprintfmt+0x4da>
  800823:	89 c2                	mov    %eax,%edx
  800825:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800829:	83 c0 08             	add    $0x8,%eax
  80082c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80082f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800832:	b9 08 00 00 00       	mov    $0x8,%ecx
  800837:	eb 79                	jmp    8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800839:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80083d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800841:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800845:	eb e8                	jmp    80082f <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800847:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80084b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80084f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800853:	eb b9                	jmp    80080e <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800855:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800858:	83 f8 2f             	cmp    $0x2f,%eax
  80085b:	77 15                	ja     800872 <vprintfmt+0x513>
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800863:	83 c0 08             	add    $0x8,%eax
  800866:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800869:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80086b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800870:	eb 40                	jmp    8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800872:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800876:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80087e:	eb e9                	jmp    800869 <vprintfmt+0x50a>
        putch('0', putdat);
  800880:	4c 89 fe             	mov    %r15,%rsi
  800883:	bf 30 00 00 00       	mov    $0x30,%edi
  800888:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  80088b:	4c 89 fe             	mov    %r15,%rsi
  80088e:	bf 78 00 00 00       	mov    $0x78,%edi
  800893:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800896:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800899:	83 f8 2f             	cmp    $0x2f,%eax
  80089c:	77 34                	ja     8008d2 <vprintfmt+0x573>
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a4:	83 c0 08             	add    $0x8,%eax
  8008a7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008aa:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008ad:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008b2:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008b7:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008bb:	4c 89 fe             	mov    %r15,%rsi
  8008be:	4c 89 ef             	mov    %r13,%rdi
  8008c1:	48 b8 35 02 80 00 00 	movabs $0x800235,%rax
  8008c8:	00 00 00 
  8008cb:	ff d0                	callq  *%rax
        break;
  8008cd:	e9 b7 fa ff ff       	jmpq   800389 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008da:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008de:	eb ca                	jmp    8008aa <vprintfmt+0x54b>
  if (lflag >= 2)
  8008e0:	83 f9 01             	cmp    $0x1,%ecx
  8008e3:	7f 22                	jg     800907 <vprintfmt+0x5a8>
  else if (lflag)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 58                	je     800941 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8008e9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ec:	83 f8 2f             	cmp    $0x2f,%eax
  8008ef:	77 42                	ja     800933 <vprintfmt+0x5d4>
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f7:	83 c0 08             	add    $0x8,%eax
  8008fa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fd:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800900:	b9 10 00 00 00       	mov    $0x10,%ecx
  800905:	eb ab                	jmp    8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800907:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090a:	83 f8 2f             	cmp    $0x2f,%eax
  80090d:	77 16                	ja     800925 <vprintfmt+0x5c6>
  80090f:	89 c2                	mov    %eax,%edx
  800911:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800915:	83 c0 08             	add    $0x8,%eax
  800918:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80091b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80091e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800923:	eb 8d                	jmp    8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800925:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800929:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80092d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800931:	eb e8                	jmp    80091b <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800933:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800937:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80093f:	eb bc                	jmp    8008fd <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800941:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800944:	83 f8 2f             	cmp    $0x2f,%eax
  800947:	77 18                	ja     800961 <vprintfmt+0x602>
  800949:	89 c2                	mov    %eax,%edx
  80094b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094f:	83 c0 08             	add    $0x8,%eax
  800952:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800955:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800957:	b9 10 00 00 00       	mov    $0x10,%ecx
  80095c:	e9 51 ff ff ff       	jmpq   8008b2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800961:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800965:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800969:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096d:	eb e6                	jmp    800955 <vprintfmt+0x5f6>
        putch(ch, putdat);
  80096f:	4c 89 fe             	mov    %r15,%rsi
  800972:	bf 25 00 00 00       	mov    $0x25,%edi
  800977:	41 ff d5             	callq  *%r13
        break;
  80097a:	e9 0a fa ff ff       	jmpq   800389 <vprintfmt+0x2a>
        putch('%', putdat);
  80097f:	4c 89 fe             	mov    %r15,%rsi
  800982:	bf 25 00 00 00       	mov    $0x25,%edi
  800987:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  80098a:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  80098e:	0f 84 15 fa ff ff    	je     8003a9 <vprintfmt+0x4a>
  800994:	49 89 de             	mov    %rbx,%r14
  800997:	49 83 ee 01          	sub    $0x1,%r14
  80099b:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009a0:	75 f5                	jne    800997 <vprintfmt+0x638>
  8009a2:	e9 e2 f9 ff ff       	jmpq   800389 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009a7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009ab:	74 06                	je     8009b3 <vprintfmt+0x654>
  8009ad:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009b1:	7f 21                	jg     8009d4 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b3:	bf 28 00 00 00       	mov    $0x28,%edi
  8009b8:	48 bb 9a 11 80 00 00 	movabs $0x80119a,%rbx
  8009bf:	00 00 00 
  8009c2:	b8 28 00 00 00       	mov    $0x28,%eax
  8009c7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009cb:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009cf:	e9 82 fc ff ff       	jmpq   800656 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009d4:	49 63 f4             	movslq %r12d,%rsi
  8009d7:	48 bf 99 11 80 00 00 	movabs $0x801199,%rdi
  8009de:	00 00 00 
  8009e1:	48 b8 36 0b 80 00 00 	movabs $0x800b36,%rax
  8009e8:	00 00 00 
  8009eb:	ff d0                	callq  *%rax
  8009ed:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8009f0:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  8009f3:	48 be 99 11 80 00 00 	movabs $0x801199,%rsi
  8009fa:	00 00 00 
  8009fd:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a01:	85 c0                	test   %eax,%eax
  800a03:	0f 8f f2 fb ff ff    	jg     8005fb <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a09:	48 bb 9a 11 80 00 00 	movabs $0x80119a,%rbx
  800a10:	00 00 00 
  800a13:	b8 28 00 00 00       	mov    $0x28,%eax
  800a18:	bf 28 00 00 00       	mov    $0x28,%edi
  800a1d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a21:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a25:	e9 2c fc ff ff       	jmpq   800656 <vprintfmt+0x2f7>
}
  800a2a:	48 83 c4 48          	add    $0x48,%rsp
  800a2e:	5b                   	pop    %rbx
  800a2f:	41 5c                	pop    %r12
  800a31:	41 5d                	pop    %r13
  800a33:	41 5e                	pop    %r14
  800a35:	41 5f                	pop    %r15
  800a37:	5d                   	pop    %rbp
  800a38:	c3                   	retq   

0000000000800a39 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a39:	55                   	push   %rbp
  800a3a:	48 89 e5             	mov    %rsp,%rbp
  800a3d:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a41:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a45:	48 63 c6             	movslq %esi,%rax
  800a48:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a4d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a51:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a58:	48 85 ff             	test   %rdi,%rdi
  800a5b:	74 2a                	je     800a87 <vsnprintf+0x4e>
  800a5d:	85 f6                	test   %esi,%esi
  800a5f:	7e 26                	jle    800a87 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a61:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a65:	48 bf c1 02 80 00 00 	movabs $0x8002c1,%rdi
  800a6c:	00 00 00 
  800a6f:	48 b8 5f 03 80 00 00 	movabs $0x80035f,%rax
  800a76:	00 00 00 
  800a79:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800a7b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800a7f:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800a82:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800a85:	c9                   	leaveq 
  800a86:	c3                   	retq   
    return -E_INVAL;
  800a87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a8c:	eb f7                	jmp    800a85 <vsnprintf+0x4c>

0000000000800a8e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800a8e:	55                   	push   %rbp
  800a8f:	48 89 e5             	mov    %rsp,%rbp
  800a92:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800a99:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800aa0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800aa7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800aae:	84 c0                	test   %al,%al
  800ab0:	74 20                	je     800ad2 <snprintf+0x44>
  800ab2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ab6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800aba:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800abe:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ac2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ac6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800aca:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ace:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ad2:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ad9:	00 00 00 
  800adc:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ae3:	00 00 00 
  800ae6:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800aea:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800af1:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800af8:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800aff:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b06:	48 b8 39 0a 80 00 00 	movabs $0x800a39,%rax
  800b0d:	00 00 00 
  800b10:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b12:	c9                   	leaveq 
  800b13:	c3                   	retq   

0000000000800b14 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b14:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b17:	74 17                	je     800b30 <strlen+0x1c>
  800b19:	48 89 fa             	mov    %rdi,%rdx
  800b1c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b21:	29 f9                	sub    %edi,%ecx
    n++;
  800b23:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b26:	48 83 c2 01          	add    $0x1,%rdx
  800b2a:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b2d:	75 f4                	jne    800b23 <strlen+0xf>
  800b2f:	c3                   	retq   
  800b30:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b35:	c3                   	retq   

0000000000800b36 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b36:	48 85 f6             	test   %rsi,%rsi
  800b39:	74 24                	je     800b5f <strnlen+0x29>
  800b3b:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b3e:	74 25                	je     800b65 <strnlen+0x2f>
  800b40:	48 01 fe             	add    %rdi,%rsi
  800b43:	48 89 fa             	mov    %rdi,%rdx
  800b46:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b4b:	29 f9                	sub    %edi,%ecx
    n++;
  800b4d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b50:	48 83 c2 01          	add    $0x1,%rdx
  800b54:	48 39 f2             	cmp    %rsi,%rdx
  800b57:	74 11                	je     800b6a <strnlen+0x34>
  800b59:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b5c:	75 ef                	jne    800b4d <strnlen+0x17>
  800b5e:	c3                   	retq   
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b64:	c3                   	retq   
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b6a:	c3                   	retq   

0000000000800b6b <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b6b:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800b77:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800b7a:	48 83 c2 01          	add    $0x1,%rdx
  800b7e:	84 c9                	test   %cl,%cl
  800b80:	75 f1                	jne    800b73 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800b82:	c3                   	retq   

0000000000800b83 <strcat>:

char *
strcat(char *dst, const char *src) {
  800b83:	55                   	push   %rbp
  800b84:	48 89 e5             	mov    %rsp,%rbp
  800b87:	41 54                	push   %r12
  800b89:	53                   	push   %rbx
  800b8a:	48 89 fb             	mov    %rdi,%rbx
  800b8d:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800b90:	48 b8 14 0b 80 00 00 	movabs $0x800b14,%rax
  800b97:	00 00 00 
  800b9a:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800b9c:	48 63 f8             	movslq %eax,%rdi
  800b9f:	48 01 df             	add    %rbx,%rdi
  800ba2:	4c 89 e6             	mov    %r12,%rsi
  800ba5:	48 b8 6b 0b 80 00 00 	movabs $0x800b6b,%rax
  800bac:	00 00 00 
  800baf:	ff d0                	callq  *%rax
  return dst;
}
  800bb1:	48 89 d8             	mov    %rbx,%rax
  800bb4:	5b                   	pop    %rbx
  800bb5:	41 5c                	pop    %r12
  800bb7:	5d                   	pop    %rbp
  800bb8:	c3                   	retq   

0000000000800bb9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bb9:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bbc:	48 85 d2             	test   %rdx,%rdx
  800bbf:	74 1f                	je     800be0 <strncpy+0x27>
  800bc1:	48 01 fa             	add    %rdi,%rdx
  800bc4:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bc7:	48 83 c1 01          	add    $0x1,%rcx
  800bcb:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bcf:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800bd3:	41 80 f8 01          	cmp    $0x1,%r8b
  800bd7:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800bdb:	48 39 ca             	cmp    %rcx,%rdx
  800bde:	75 e7                	jne    800bc7 <strncpy+0xe>
  }
  return ret;
}
  800be0:	c3                   	retq   

0000000000800be1 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800be1:	48 89 f8             	mov    %rdi,%rax
  800be4:	48 85 d2             	test   %rdx,%rdx
  800be7:	74 36                	je     800c1f <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800be9:	48 83 fa 01          	cmp    $0x1,%rdx
  800bed:	74 2d                	je     800c1c <strlcpy+0x3b>
  800bef:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bf3:	45 84 c0             	test   %r8b,%r8b
  800bf6:	74 24                	je     800c1c <strlcpy+0x3b>
  800bf8:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800bfc:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c01:	48 83 c0 01          	add    $0x1,%rax
  800c05:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c09:	48 39 d1             	cmp    %rdx,%rcx
  800c0c:	74 0e                	je     800c1c <strlcpy+0x3b>
  800c0e:	48 83 c1 01          	add    $0x1,%rcx
  800c12:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c17:	45 84 c0             	test   %r8b,%r8b
  800c1a:	75 e5                	jne    800c01 <strlcpy+0x20>
    *dst = '\0';
  800c1c:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c1f:	48 29 f8             	sub    %rdi,%rax
}
  800c22:	c3                   	retq   

0000000000800c23 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c23:	0f b6 07             	movzbl (%rdi),%eax
  800c26:	84 c0                	test   %al,%al
  800c28:	74 17                	je     800c41 <strcmp+0x1e>
  800c2a:	3a 06                	cmp    (%rsi),%al
  800c2c:	75 13                	jne    800c41 <strcmp+0x1e>
    p++, q++;
  800c2e:	48 83 c7 01          	add    $0x1,%rdi
  800c32:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c36:	0f b6 07             	movzbl (%rdi),%eax
  800c39:	84 c0                	test   %al,%al
  800c3b:	74 04                	je     800c41 <strcmp+0x1e>
  800c3d:	3a 06                	cmp    (%rsi),%al
  800c3f:	74 ed                	je     800c2e <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c41:	0f b6 c0             	movzbl %al,%eax
  800c44:	0f b6 16             	movzbl (%rsi),%edx
  800c47:	29 d0                	sub    %edx,%eax
}
  800c49:	c3                   	retq   

0000000000800c4a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c4a:	48 85 d2             	test   %rdx,%rdx
  800c4d:	74 2f                	je     800c7e <strncmp+0x34>
  800c4f:	0f b6 07             	movzbl (%rdi),%eax
  800c52:	84 c0                	test   %al,%al
  800c54:	74 1f                	je     800c75 <strncmp+0x2b>
  800c56:	3a 06                	cmp    (%rsi),%al
  800c58:	75 1b                	jne    800c75 <strncmp+0x2b>
  800c5a:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c5d:	48 83 c7 01          	add    $0x1,%rdi
  800c61:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c65:	48 39 d7             	cmp    %rdx,%rdi
  800c68:	74 1a                	je     800c84 <strncmp+0x3a>
  800c6a:	0f b6 07             	movzbl (%rdi),%eax
  800c6d:	84 c0                	test   %al,%al
  800c6f:	74 04                	je     800c75 <strncmp+0x2b>
  800c71:	3a 06                	cmp    (%rsi),%al
  800c73:	74 e8                	je     800c5d <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800c75:	0f b6 07             	movzbl (%rdi),%eax
  800c78:	0f b6 16             	movzbl (%rsi),%edx
  800c7b:	29 d0                	sub    %edx,%eax
}
  800c7d:	c3                   	retq   
    return 0;
  800c7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c83:	c3                   	retq   
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
  800c89:	c3                   	retq   

0000000000800c8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800c8a:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800c8c:	0f b6 07             	movzbl (%rdi),%eax
  800c8f:	84 c0                	test   %al,%al
  800c91:	74 1e                	je     800cb1 <strchr+0x27>
    if (*s == c)
  800c93:	40 38 c6             	cmp    %al,%sil
  800c96:	74 1f                	je     800cb7 <strchr+0x2d>
  for (; *s; s++)
  800c98:	48 83 c7 01          	add    $0x1,%rdi
  800c9c:	0f b6 07             	movzbl (%rdi),%eax
  800c9f:	84 c0                	test   %al,%al
  800ca1:	74 08                	je     800cab <strchr+0x21>
    if (*s == c)
  800ca3:	38 d0                	cmp    %dl,%al
  800ca5:	75 f1                	jne    800c98 <strchr+0xe>
  for (; *s; s++)
  800ca7:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800caa:	c3                   	retq   
  return 0;
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb0:	c3                   	retq   
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	c3                   	retq   
    if (*s == c)
  800cb7:	48 89 f8             	mov    %rdi,%rax
  800cba:	c3                   	retq   

0000000000800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cbb:	48 89 f8             	mov    %rdi,%rax
  800cbe:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cc0:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cc3:	40 38 f2             	cmp    %sil,%dl
  800cc6:	74 13                	je     800cdb <strfind+0x20>
  800cc8:	84 d2                	test   %dl,%dl
  800cca:	74 0f                	je     800cdb <strfind+0x20>
  for (; *s; s++)
  800ccc:	48 83 c0 01          	add    $0x1,%rax
  800cd0:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800cd3:	38 ca                	cmp    %cl,%dl
  800cd5:	74 04                	je     800cdb <strfind+0x20>
  800cd7:	84 d2                	test   %dl,%dl
  800cd9:	75 f1                	jne    800ccc <strfind+0x11>
      break;
  return (char *)s;
}
  800cdb:	c3                   	retq   

0000000000800cdc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800cdc:	48 85 d2             	test   %rdx,%rdx
  800cdf:	74 3a                	je     800d1b <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ce1:	48 89 f8             	mov    %rdi,%rax
  800ce4:	48 09 d0             	or     %rdx,%rax
  800ce7:	a8 03                	test   $0x3,%al
  800ce9:	75 28                	jne    800d13 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ceb:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800cef:	89 f0                	mov    %esi,%eax
  800cf1:	c1 e0 08             	shl    $0x8,%eax
  800cf4:	89 f1                	mov    %esi,%ecx
  800cf6:	c1 e1 18             	shl    $0x18,%ecx
  800cf9:	41 89 f0             	mov    %esi,%r8d
  800cfc:	41 c1 e0 10          	shl    $0x10,%r8d
  800d00:	44 09 c1             	or     %r8d,%ecx
  800d03:	09 ce                	or     %ecx,%esi
  800d05:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d07:	48 c1 ea 02          	shr    $0x2,%rdx
  800d0b:	48 89 d1             	mov    %rdx,%rcx
  800d0e:	fc                   	cld    
  800d0f:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d11:	eb 08                	jmp    800d1b <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d13:	89 f0                	mov    %esi,%eax
  800d15:	48 89 d1             	mov    %rdx,%rcx
  800d18:	fc                   	cld    
  800d19:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d1b:	48 89 f8             	mov    %rdi,%rax
  800d1e:	c3                   	retq   

0000000000800d1f <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d1f:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d22:	48 39 fe             	cmp    %rdi,%rsi
  800d25:	73 40                	jae    800d67 <memmove+0x48>
  800d27:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d2b:	48 39 f9             	cmp    %rdi,%rcx
  800d2e:	76 37                	jbe    800d67 <memmove+0x48>
    s += n;
    d += n;
  800d30:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d34:	48 89 fe             	mov    %rdi,%rsi
  800d37:	48 09 d6             	or     %rdx,%rsi
  800d3a:	48 09 ce             	or     %rcx,%rsi
  800d3d:	40 f6 c6 03          	test   $0x3,%sil
  800d41:	75 14                	jne    800d57 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d43:	48 83 ef 04          	sub    $0x4,%rdi
  800d47:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d4b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d4f:	48 89 d1             	mov    %rdx,%rcx
  800d52:	fd                   	std    
  800d53:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d55:	eb 0e                	jmp    800d65 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d57:	48 83 ef 01          	sub    $0x1,%rdi
  800d5b:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d5f:	48 89 d1             	mov    %rdx,%rcx
  800d62:	fd                   	std    
  800d63:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d65:	fc                   	cld    
  800d66:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d67:	48 89 c1             	mov    %rax,%rcx
  800d6a:	48 09 d1             	or     %rdx,%rcx
  800d6d:	48 09 f1             	or     %rsi,%rcx
  800d70:	f6 c1 03             	test   $0x3,%cl
  800d73:	75 0e                	jne    800d83 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800d75:	48 c1 ea 02          	shr    $0x2,%rdx
  800d79:	48 89 d1             	mov    %rdx,%rcx
  800d7c:	48 89 c7             	mov    %rax,%rdi
  800d7f:	fc                   	cld    
  800d80:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d82:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800d83:	48 89 c7             	mov    %rax,%rdi
  800d86:	48 89 d1             	mov    %rdx,%rcx
  800d89:	fc                   	cld    
  800d8a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800d8c:	c3                   	retq   

0000000000800d8d <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800d8d:	55                   	push   %rbp
  800d8e:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800d91:	48 b8 1f 0d 80 00 00 	movabs $0x800d1f,%rax
  800d98:	00 00 00 
  800d9b:	ff d0                	callq  *%rax
}
  800d9d:	5d                   	pop    %rbp
  800d9e:	c3                   	retq   

0000000000800d9f <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800d9f:	55                   	push   %rbp
  800da0:	48 89 e5             	mov    %rsp,%rbp
  800da3:	41 57                	push   %r15
  800da5:	41 56                	push   %r14
  800da7:	41 55                	push   %r13
  800da9:	41 54                	push   %r12
  800dab:	53                   	push   %rbx
  800dac:	48 83 ec 08          	sub    $0x8,%rsp
  800db0:	49 89 fe             	mov    %rdi,%r14
  800db3:	49 89 f7             	mov    %rsi,%r15
  800db6:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800db9:	48 89 f7             	mov    %rsi,%rdi
  800dbc:	48 b8 14 0b 80 00 00 	movabs $0x800b14,%rax
  800dc3:	00 00 00 
  800dc6:	ff d0                	callq  *%rax
  800dc8:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dcb:	4c 89 ee             	mov    %r13,%rsi
  800dce:	4c 89 f7             	mov    %r14,%rdi
  800dd1:	48 b8 36 0b 80 00 00 	movabs $0x800b36,%rax
  800dd8:	00 00 00 
  800ddb:	ff d0                	callq  *%rax
  800ddd:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800de0:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800de4:	4d 39 e5             	cmp    %r12,%r13
  800de7:	74 26                	je     800e0f <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800de9:	4c 89 e8             	mov    %r13,%rax
  800dec:	4c 29 e0             	sub    %r12,%rax
  800def:	48 39 d8             	cmp    %rbx,%rax
  800df2:	76 2a                	jbe    800e1e <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800df4:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800df8:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800dfc:	4c 89 fe             	mov    %r15,%rsi
  800dff:	48 b8 8d 0d 80 00 00 	movabs $0x800d8d,%rax
  800e06:	00 00 00 
  800e09:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e0b:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e0f:	48 83 c4 08          	add    $0x8,%rsp
  800e13:	5b                   	pop    %rbx
  800e14:	41 5c                	pop    %r12
  800e16:	41 5d                	pop    %r13
  800e18:	41 5e                	pop    %r14
  800e1a:	41 5f                	pop    %r15
  800e1c:	5d                   	pop    %rbp
  800e1d:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e1e:	49 83 ed 01          	sub    $0x1,%r13
  800e22:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e26:	4c 89 ea             	mov    %r13,%rdx
  800e29:	4c 89 fe             	mov    %r15,%rsi
  800e2c:	48 b8 8d 0d 80 00 00 	movabs $0x800d8d,%rax
  800e33:	00 00 00 
  800e36:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e38:	4d 01 ee             	add    %r13,%r14
  800e3b:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e40:	eb c9                	jmp    800e0b <strlcat+0x6c>

0000000000800e42 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e42:	48 85 d2             	test   %rdx,%rdx
  800e45:	74 3a                	je     800e81 <memcmp+0x3f>
    if (*s1 != *s2)
  800e47:	0f b6 0f             	movzbl (%rdi),%ecx
  800e4a:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e4e:	44 38 c1             	cmp    %r8b,%cl
  800e51:	75 1d                	jne    800e70 <memcmp+0x2e>
  800e53:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e58:	48 39 d0             	cmp    %rdx,%rax
  800e5b:	74 1e                	je     800e7b <memcmp+0x39>
    if (*s1 != *s2)
  800e5d:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e61:	48 83 c0 01          	add    $0x1,%rax
  800e65:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e6b:	44 38 c1             	cmp    %r8b,%cl
  800e6e:	74 e8                	je     800e58 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e70:	0f b6 c1             	movzbl %cl,%eax
  800e73:	45 0f b6 c0          	movzbl %r8b,%r8d
  800e77:	44 29 c0             	sub    %r8d,%eax
  800e7a:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	c3                   	retq   
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e86:	c3                   	retq   

0000000000800e87 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800e87:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800e8b:	48 39 c7             	cmp    %rax,%rdi
  800e8e:	73 19                	jae    800ea9 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800e90:	89 f2                	mov    %esi,%edx
  800e92:	40 38 37             	cmp    %sil,(%rdi)
  800e95:	74 16                	je     800ead <memfind+0x26>
  for (; s < ends; s++)
  800e97:	48 83 c7 01          	add    $0x1,%rdi
  800e9b:	48 39 f8             	cmp    %rdi,%rax
  800e9e:	74 08                	je     800ea8 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ea0:	38 17                	cmp    %dl,(%rdi)
  800ea2:	75 f3                	jne    800e97 <memfind+0x10>
  for (; s < ends; s++)
  800ea4:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ea7:	c3                   	retq   
  800ea8:	c3                   	retq   
  for (; s < ends; s++)
  800ea9:	48 89 f8             	mov    %rdi,%rax
  800eac:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ead:	48 89 f8             	mov    %rdi,%rax
  800eb0:	c3                   	retq   

0000000000800eb1 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800eb1:	0f b6 07             	movzbl (%rdi),%eax
  800eb4:	3c 20                	cmp    $0x20,%al
  800eb6:	74 04                	je     800ebc <strtol+0xb>
  800eb8:	3c 09                	cmp    $0x9,%al
  800eba:	75 0f                	jne    800ecb <strtol+0x1a>
    s++;
  800ebc:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ec0:	0f b6 07             	movzbl (%rdi),%eax
  800ec3:	3c 20                	cmp    $0x20,%al
  800ec5:	74 f5                	je     800ebc <strtol+0xb>
  800ec7:	3c 09                	cmp    $0x9,%al
  800ec9:	74 f1                	je     800ebc <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800ecb:	3c 2b                	cmp    $0x2b,%al
  800ecd:	74 2b                	je     800efa <strtol+0x49>
  int neg  = 0;
  800ecf:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800ed5:	3c 2d                	cmp    $0x2d,%al
  800ed7:	74 2d                	je     800f06 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed9:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800edf:	75 0f                	jne    800ef0 <strtol+0x3f>
  800ee1:	80 3f 30             	cmpb   $0x30,(%rdi)
  800ee4:	74 2c                	je     800f12 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800ee6:	85 d2                	test   %edx,%edx
  800ee8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eed:	0f 44 d0             	cmove  %eax,%edx
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800ef5:	4c 63 d2             	movslq %edx,%r10
  800ef8:	eb 5c                	jmp    800f56 <strtol+0xa5>
    s++;
  800efa:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800efe:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f04:	eb d3                	jmp    800ed9 <strtol+0x28>
    s++, neg = 1;
  800f06:	48 83 c7 01          	add    $0x1,%rdi
  800f0a:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f10:	eb c7                	jmp    800ed9 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f12:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f16:	74 0f                	je     800f27 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f18:	85 d2                	test   %edx,%edx
  800f1a:	75 d4                	jne    800ef0 <strtol+0x3f>
    s++, base = 8;
  800f1c:	48 83 c7 01          	add    $0x1,%rdi
  800f20:	ba 08 00 00 00       	mov    $0x8,%edx
  800f25:	eb c9                	jmp    800ef0 <strtol+0x3f>
    s += 2, base = 16;
  800f27:	48 83 c7 02          	add    $0x2,%rdi
  800f2b:	ba 10 00 00 00       	mov    $0x10,%edx
  800f30:	eb be                	jmp    800ef0 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f32:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f36:	41 80 f8 19          	cmp    $0x19,%r8b
  800f3a:	77 2f                	ja     800f6b <strtol+0xba>
      dig = *s - 'a' + 10;
  800f3c:	44 0f be c1          	movsbl %cl,%r8d
  800f40:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f44:	39 d1                	cmp    %edx,%ecx
  800f46:	7d 37                	jge    800f7f <strtol+0xce>
    s++, val = (val * base) + dig;
  800f48:	48 83 c7 01          	add    $0x1,%rdi
  800f4c:	49 0f af c2          	imul   %r10,%rax
  800f50:	48 63 c9             	movslq %ecx,%rcx
  800f53:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f56:	0f b6 0f             	movzbl (%rdi),%ecx
  800f59:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f5d:	41 80 f8 09          	cmp    $0x9,%r8b
  800f61:	77 cf                	ja     800f32 <strtol+0x81>
      dig = *s - '0';
  800f63:	0f be c9             	movsbl %cl,%ecx
  800f66:	83 e9 30             	sub    $0x30,%ecx
  800f69:	eb d9                	jmp    800f44 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f6b:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f6f:	41 80 f8 19          	cmp    $0x19,%r8b
  800f73:	77 0a                	ja     800f7f <strtol+0xce>
      dig = *s - 'A' + 10;
  800f75:	44 0f be c1          	movsbl %cl,%r8d
  800f79:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800f7d:	eb c5                	jmp    800f44 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800f7f:	48 85 f6             	test   %rsi,%rsi
  800f82:	74 03                	je     800f87 <strtol+0xd6>
    *endptr = (char *)s;
  800f84:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800f87:	48 89 c2             	mov    %rax,%rdx
  800f8a:	48 f7 da             	neg    %rdx
  800f8d:	45 85 c9             	test   %r9d,%r9d
  800f90:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800f94:	c3                   	retq   

0000000000800f95 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800f95:	55                   	push   %rbp
  800f96:	48 89 e5             	mov    %rsp,%rbp
  800f99:	53                   	push   %rbx
  800f9a:	48 89 fa             	mov    %rdi,%rdx
  800f9d:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa5:	48 89 c3             	mov    %rax,%rbx
  800fa8:	48 89 c7             	mov    %rax,%rdi
  800fab:	48 89 c6             	mov    %rax,%rsi
  800fae:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fb0:	5b                   	pop    %rbx
  800fb1:	5d                   	pop    %rbp
  800fb2:	c3                   	retq   

0000000000800fb3 <sys_cgetc>:

int
sys_cgetc(void) {
  800fb3:	55                   	push   %rbp
  800fb4:	48 89 e5             	mov    %rsp,%rbp
  800fb7:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc2:	48 89 ca             	mov    %rcx,%rdx
  800fc5:	48 89 cb             	mov    %rcx,%rbx
  800fc8:	48 89 cf             	mov    %rcx,%rdi
  800fcb:	48 89 ce             	mov    %rcx,%rsi
  800fce:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd0:	5b                   	pop    %rbx
  800fd1:	5d                   	pop    %rbp
  800fd2:	c3                   	retq   

0000000000800fd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800fd3:	55                   	push   %rbp
  800fd4:	48 89 e5             	mov    %rsp,%rbp
  800fd7:	53                   	push   %rbx
  800fd8:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fdc:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800fdf:	be 00 00 00 00       	mov    $0x0,%esi
  800fe4:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe9:	48 89 f1             	mov    %rsi,%rcx
  800fec:	48 89 f3             	mov    %rsi,%rbx
  800fef:	48 89 f7             	mov    %rsi,%rdi
  800ff2:	cd 30                	int    $0x30
  if (check && ret > 0)
  800ff4:	48 85 c0             	test   %rax,%rax
  800ff7:	7f 07                	jg     801000 <sys_env_destroy+0x2d>
}
  800ff9:	48 83 c4 08          	add    $0x8,%rsp
  800ffd:	5b                   	pop    %rbx
  800ffe:	5d                   	pop    %rbp
  800fff:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801000:	49 89 c0             	mov    %rax,%r8
  801003:	b9 03 00 00 00       	mov    $0x3,%ecx
  801008:	48 ba 50 15 80 00 00 	movabs $0x801550,%rdx
  80100f:	00 00 00 
  801012:	be 22 00 00 00       	mov    $0x22,%esi
  801017:	48 bf 6f 15 80 00 00 	movabs $0x80156f,%rdi
  80101e:	00 00 00 
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	49 b9 53 10 80 00 00 	movabs $0x801053,%r9
  80102d:	00 00 00 
  801030:	41 ff d1             	callq  *%r9

0000000000801033 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801033:	55                   	push   %rbp
  801034:	48 89 e5             	mov    %rsp,%rbp
  801037:	53                   	push   %rbx
  asm volatile("int %1\n"
  801038:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103d:	b8 02 00 00 00       	mov    $0x2,%eax
  801042:	48 89 ca             	mov    %rcx,%rdx
  801045:	48 89 cb             	mov    %rcx,%rbx
  801048:	48 89 cf             	mov    %rcx,%rdi
  80104b:	48 89 ce             	mov    %rcx,%rsi
  80104e:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801050:	5b                   	pop    %rbx
  801051:	5d                   	pop    %rbp
  801052:	c3                   	retq   

0000000000801053 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801053:	55                   	push   %rbp
  801054:	48 89 e5             	mov    %rsp,%rbp
  801057:	41 56                	push   %r14
  801059:	41 55                	push   %r13
  80105b:	41 54                	push   %r12
  80105d:	53                   	push   %rbx
  80105e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801065:	49 89 fd             	mov    %rdi,%r13
  801068:	41 89 f6             	mov    %esi,%r14d
  80106b:	49 89 d4             	mov    %rdx,%r12
  80106e:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801075:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80107c:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801083:	84 c0                	test   %al,%al
  801085:	74 26                	je     8010ad <_panic+0x5a>
  801087:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80108e:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801095:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801099:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80109d:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010a1:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010a5:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010a9:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010ad:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010b4:	00 00 00 
  8010b7:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010be:	00 00 00 
  8010c1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010c5:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010cc:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8010d3:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8010da:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8010e1:	00 00 00 
  8010e4:	48 8b 18             	mov    (%rax),%rbx
  8010e7:	48 b8 33 10 80 00 00 	movabs $0x801033,%rax
  8010ee:	00 00 00 
  8010f1:	ff d0                	callq  *%rax
  8010f3:	45 89 f0             	mov    %r14d,%r8d
  8010f6:	4c 89 e9             	mov    %r13,%rcx
  8010f9:	48 89 da             	mov    %rbx,%rdx
  8010fc:	89 c6                	mov    %eax,%esi
  8010fe:	48 bf 80 15 80 00 00 	movabs $0x801580,%rdi
  801105:	00 00 00 
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	48 bb a1 01 80 00 00 	movabs $0x8001a1,%rbx
  801114:	00 00 00 
  801117:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801119:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801120:	4c 89 e7             	mov    %r12,%rdi
  801123:	48 b8 39 01 80 00 00 	movabs $0x800139,%rax
  80112a:	00 00 00 
  80112d:	ff d0                	callq  *%rax
  cprintf("\n");
  80112f:	48 bf 7c 11 80 00 00 	movabs $0x80117c,%rdi
  801136:	00 00 00 
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801140:	cc                   	int3   
  while (1)
  801141:	eb fd                	jmp    801140 <_panic+0xed>
  801143:	90                   	nop
