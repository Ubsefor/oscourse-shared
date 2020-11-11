
obj/user/divzero:     file format elf64-x86-64


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
  800023:	e8 39 00 00 00       	callq  800061 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#include <inc/lib.h>

volatile int zero;

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  cprintf("1337/0 is %08x!\n", 1337 / zero);
  80002e:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800035:	00 00 00 
  800038:	8b 08                	mov    (%rax),%ecx
  80003a:	b8 39 05 00 00       	mov    $0x539,%eax
  80003f:	99                   	cltd   
  800040:	f7 f9                	idiv   %ecx
  800042:	89 c6                	mov    %eax,%esi
  800044:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  80004b:	00 00 00 
  80004e:	b8 00 00 00 00       	mov    $0x0,%eax
  800053:	48 ba b0 01 80 00 00 	movabs $0x8001b0,%rdx
  80005a:	00 00 00 
  80005d:	ff d2                	callq  *%rdx
}
  80005f:	5d                   	pop    %rbp
  800060:	c3                   	retq   

0000000000800061 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800061:	55                   	push   %rbp
  800062:	48 89 e5             	mov    %rsp,%rbp
  800065:	41 56                	push   %r14
  800067:	41 55                	push   %r13
  800069:	41 54                	push   %r12
  80006b:	53                   	push   %rbx
  80006c:	41 89 fd             	mov    %edi,%r13d
  80006f:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800072:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800079:	00 00 00 
  80007c:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800083:	00 00 00 
  800086:	48 39 c2             	cmp    %rax,%rdx
  800089:	73 23                	jae    8000ae <libmain+0x4d>
  80008b:	48 89 d3             	mov    %rdx,%rbx
  80008e:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800092:	48 29 d0             	sub    %rdx,%rax
  800095:	48 c1 e8 03          	shr    $0x3,%rax
  800099:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	ff 13                	callq  *(%rbx)
    ctor++;
  8000a5:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8000a9:	4c 39 e3             	cmp    %r12,%rbx
  8000ac:	75 f0                	jne    80009e <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000ae:	45 85 ed             	test   %r13d,%r13d
  8000b1:	7e 0d                	jle    8000c0 <libmain+0x5f>
    binaryname = argv[0];
  8000b3:	49 8b 06             	mov    (%r14),%rax
  8000b6:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000bd:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000c0:	4c 89 f6             	mov    %r14,%rsi
  8000c3:	44 89 ef             	mov    %r13d,%edi
  8000c6:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000cd:	00 00 00 
  8000d0:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000d2:	48 b8 e7 00 80 00 00 	movabs $0x8000e7,%rax
  8000d9:	00 00 00 
  8000dc:	ff d0                	callq  *%rax
#endif
}
  8000de:	5b                   	pop    %rbx
  8000df:	41 5c                	pop    %r12
  8000e1:	41 5d                	pop    %r13
  8000e3:	41 5e                	pop    %r14
  8000e5:	5d                   	pop    %rbp
  8000e6:	c3                   	retq   

00000000008000e7 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000e7:	55                   	push   %rbp
  8000e8:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f0:	48 b8 e2 0f 80 00 00 	movabs $0x800fe2,%rax
  8000f7:	00 00 00 
  8000fa:	ff d0                	callq  *%rax
}
  8000fc:	5d                   	pop    %rbp
  8000fd:	c3                   	retq   

00000000008000fe <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8000fe:	55                   	push   %rbp
  8000ff:	48 89 e5             	mov    %rsp,%rbp
  800102:	53                   	push   %rbx
  800103:	48 83 ec 08          	sub    $0x8,%rsp
  800107:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80010a:	8b 06                	mov    (%rsi),%eax
  80010c:	8d 50 01             	lea    0x1(%rax),%edx
  80010f:	89 16                	mov    %edx,(%rsi)
  800111:	48 98                	cltq   
  800113:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800118:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80011e:	74 0b                	je     80012b <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800120:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800124:	48 83 c4 08          	add    $0x8,%rsp
  800128:	5b                   	pop    %rbx
  800129:	5d                   	pop    %rbp
  80012a:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80012b:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80012f:	be ff 00 00 00       	mov    $0xff,%esi
  800134:	48 b8 a4 0f 80 00 00 	movabs $0x800fa4,%rax
  80013b:	00 00 00 
  80013e:	ff d0                	callq  *%rax
    b->idx = 0;
  800140:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800146:	eb d8                	jmp    800120 <putch+0x22>

0000000000800148 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800148:	55                   	push   %rbp
  800149:	48 89 e5             	mov    %rsp,%rbp
  80014c:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800153:	48 89 fa             	mov    %rdi,%rdx
  800156:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800159:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800160:	00 00 00 
  b.cnt = 0;
  800163:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80016a:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80016d:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800174:	48 bf fe 00 80 00 00 	movabs $0x8000fe,%rdi
  80017b:	00 00 00 
  80017e:	48 b8 6e 03 80 00 00 	movabs $0x80036e,%rax
  800185:	00 00 00 
  800188:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80018a:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800191:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800198:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80019c:	48 b8 a4 0f 80 00 00 	movabs $0x800fa4,%rax
  8001a3:	00 00 00 
  8001a6:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001ae:	c9                   	leaveq 
  8001af:	c3                   	retq   

00000000008001b0 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001b0:	55                   	push   %rbp
  8001b1:	48 89 e5             	mov    %rsp,%rbp
  8001b4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001bb:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001c2:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001c9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001d0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001d7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001de:	84 c0                	test   %al,%al
  8001e0:	74 20                	je     800202 <cprintf+0x52>
  8001e2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8001e6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8001ea:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8001ee:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8001f2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8001f6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8001fa:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8001fe:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800202:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800209:	00 00 00 
  80020c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800213:	00 00 00 
  800216:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80021a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800221:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800228:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80022f:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800236:	48 b8 48 01 80 00 00 	movabs $0x800148,%rax
  80023d:	00 00 00 
  800240:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800242:	c9                   	leaveq 
  800243:	c3                   	retq   

0000000000800244 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800244:	55                   	push   %rbp
  800245:	48 89 e5             	mov    %rsp,%rbp
  800248:	41 57                	push   %r15
  80024a:	41 56                	push   %r14
  80024c:	41 55                	push   %r13
  80024e:	41 54                	push   %r12
  800250:	53                   	push   %rbx
  800251:	48 83 ec 18          	sub    $0x18,%rsp
  800255:	49 89 fc             	mov    %rdi,%r12
  800258:	49 89 f5             	mov    %rsi,%r13
  80025b:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80025f:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800262:	41 89 cf             	mov    %ecx,%r15d
  800265:	49 39 d7             	cmp    %rdx,%r15
  800268:	76 45                	jbe    8002af <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80026a:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80026e:	85 db                	test   %ebx,%ebx
  800270:	7e 0e                	jle    800280 <printnum+0x3c>
      putch(padc, putdat);
  800272:	4c 89 ee             	mov    %r13,%rsi
  800275:	44 89 f7             	mov    %r14d,%edi
  800278:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80027b:	83 eb 01             	sub    $0x1,%ebx
  80027e:	75 f2                	jne    800272 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800280:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800284:	ba 00 00 00 00       	mov    $0x0,%edx
  800289:	49 f7 f7             	div    %r15
  80028c:	48 b8 7b 11 80 00 00 	movabs $0x80117b,%rax
  800293:	00 00 00 
  800296:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80029a:	4c 89 ee             	mov    %r13,%rsi
  80029d:	41 ff d4             	callq  *%r12
}
  8002a0:	48 83 c4 18          	add    $0x18,%rsp
  8002a4:	5b                   	pop    %rbx
  8002a5:	41 5c                	pop    %r12
  8002a7:	41 5d                	pop    %r13
  8002a9:	41 5e                	pop    %r14
  8002ab:	41 5f                	pop    %r15
  8002ad:	5d                   	pop    %rbp
  8002ae:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002af:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b8:	49 f7 f7             	div    %r15
  8002bb:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002bf:	48 89 c2             	mov    %rax,%rdx
  8002c2:	48 b8 44 02 80 00 00 	movabs $0x800244,%rax
  8002c9:	00 00 00 
  8002cc:	ff d0                	callq  *%rax
  8002ce:	eb b0                	jmp    800280 <printnum+0x3c>

00000000008002d0 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002d0:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002d4:	48 8b 06             	mov    (%rsi),%rax
  8002d7:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x17>
    *b->buf++ = ch;
  8002dd:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8002e1:	48 89 16             	mov    %rdx,(%rsi)
  8002e4:	40 88 38             	mov    %dil,(%rax)
}
  8002e7:	c3                   	retq   

00000000008002e8 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8002e8:	55                   	push   %rbp
  8002e9:	48 89 e5             	mov    %rsp,%rbp
  8002ec:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002f3:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002fa:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800301:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800308:	84 c0                	test   %al,%al
  80030a:	74 20                	je     80032c <printfmt+0x44>
  80030c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800310:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800314:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800318:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80031c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800320:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800324:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800328:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80032c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800333:	00 00 00 
  800336:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80033d:	00 00 00 
  800340:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800344:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80034b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800352:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800359:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800360:	48 b8 6e 03 80 00 00 	movabs $0x80036e,%rax
  800367:	00 00 00 
  80036a:	ff d0                	callq  *%rax
}
  80036c:	c9                   	leaveq 
  80036d:	c3                   	retq   

000000000080036e <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80036e:	55                   	push   %rbp
  80036f:	48 89 e5             	mov    %rsp,%rbp
  800372:	41 57                	push   %r15
  800374:	41 56                	push   %r14
  800376:	41 55                	push   %r13
  800378:	41 54                	push   %r12
  80037a:	53                   	push   %rbx
  80037b:	48 83 ec 48          	sub    $0x48,%rsp
  80037f:	49 89 fd             	mov    %rdi,%r13
  800382:	49 89 f7             	mov    %rsi,%r15
  800385:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800388:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80038c:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800390:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800394:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800398:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80039c:	41 0f b6 3e          	movzbl (%r14),%edi
  8003a0:	83 ff 25             	cmp    $0x25,%edi
  8003a3:	74 18                	je     8003bd <vprintfmt+0x4f>
      if (ch == '\0')
  8003a5:	85 ff                	test   %edi,%edi
  8003a7:	0f 84 8c 06 00 00    	je     800a39 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003ad:	4c 89 fe             	mov    %r15,%rsi
  8003b0:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003b3:	49 89 de             	mov    %rbx,%r14
  8003b6:	eb e0                	jmp    800398 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003b8:	49 89 de             	mov    %rbx,%r14
  8003bb:	eb db                	jmp    800398 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003bd:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003c1:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003c5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003cc:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003d2:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003db:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8003e1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8003e7:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8003ec:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8003f1:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8003f5:	0f b6 13             	movzbl (%rbx),%edx
  8003f8:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8003fb:	3c 55                	cmp    $0x55,%al
  8003fd:	0f 87 8b 05 00 00    	ja     80098e <vprintfmt+0x620>
  800403:	0f b6 c0             	movzbl %al,%eax
  800406:	49 bb 20 12 80 00 00 	movabs $0x801220,%r11
  80040d:	00 00 00 
  800410:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800414:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800417:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80041b:	eb d4                	jmp    8003f1 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80041d:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800420:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800424:	eb cb                	jmp    8003f1 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800426:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800429:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80042d:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800431:	8d 50 d0             	lea    -0x30(%rax),%edx
  800434:	83 fa 09             	cmp    $0x9,%edx
  800437:	77 7e                	ja     8004b7 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800439:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80043d:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800441:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800446:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80044a:	8d 50 d0             	lea    -0x30(%rax),%edx
  80044d:	83 fa 09             	cmp    $0x9,%edx
  800450:	76 e7                	jbe    800439 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800452:	4c 89 f3             	mov    %r14,%rbx
  800455:	eb 19                	jmp    800470 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800457:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80045a:	83 f8 2f             	cmp    $0x2f,%eax
  80045d:	77 2a                	ja     800489 <vprintfmt+0x11b>
  80045f:	89 c2                	mov    %eax,%edx
  800461:	4c 01 d2             	add    %r10,%rdx
  800464:	83 c0 08             	add    $0x8,%eax
  800467:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80046a:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80046d:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800470:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800474:	0f 89 77 ff ff ff    	jns    8003f1 <vprintfmt+0x83>
          width = precision, precision = -1;
  80047a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80047e:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800484:	e9 68 ff ff ff       	jmpq   8003f1 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800489:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80048d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800491:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800495:	eb d3                	jmp    80046a <vprintfmt+0xfc>
        if (width < 0)
  800497:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80049a:	85 c0                	test   %eax,%eax
  80049c:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004a0:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004a3:	4c 89 f3             	mov    %r14,%rbx
  8004a6:	e9 46 ff ff ff       	jmpq   8003f1 <vprintfmt+0x83>
  8004ab:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004ae:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004b2:	e9 3a ff ff ff       	jmpq   8003f1 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004b7:	4c 89 f3             	mov    %r14,%rbx
  8004ba:	eb b4                	jmp    800470 <vprintfmt+0x102>
        lflag++;
  8004bc:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004bf:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004c2:	e9 2a ff ff ff       	jmpq   8003f1 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004c7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004ca:	83 f8 2f             	cmp    $0x2f,%eax
  8004cd:	77 19                	ja     8004e8 <vprintfmt+0x17a>
  8004cf:	89 c2                	mov    %eax,%edx
  8004d1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004d5:	83 c0 08             	add    $0x8,%eax
  8004d8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004db:	4c 89 fe             	mov    %r15,%rsi
  8004de:	8b 3a                	mov    (%rdx),%edi
  8004e0:	41 ff d5             	callq  *%r13
        break;
  8004e3:	e9 b0 fe ff ff       	jmpq   800398 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8004e8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004ec:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004f0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004f4:	eb e5                	jmp    8004db <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8004f6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004f9:	83 f8 2f             	cmp    $0x2f,%eax
  8004fc:	77 5b                	ja     800559 <vprintfmt+0x1eb>
  8004fe:	89 c2                	mov    %eax,%edx
  800500:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800504:	83 c0 08             	add    $0x8,%eax
  800507:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80050a:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80050c:	89 c8                	mov    %ecx,%eax
  80050e:	c1 f8 1f             	sar    $0x1f,%eax
  800511:	31 c1                	xor    %eax,%ecx
  800513:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800515:	83 f9 09             	cmp    $0x9,%ecx
  800518:	7f 4d                	jg     800567 <vprintfmt+0x1f9>
  80051a:	48 63 c1             	movslq %ecx,%rax
  80051d:	48 ba e0 14 80 00 00 	movabs $0x8014e0,%rdx
  800524:	00 00 00 
  800527:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80052b:	48 85 c0             	test   %rax,%rax
  80052e:	74 37                	je     800567 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800530:	48 89 c1             	mov    %rax,%rcx
  800533:	48 ba 9c 11 80 00 00 	movabs $0x80119c,%rdx
  80053a:	00 00 00 
  80053d:	4c 89 fe             	mov    %r15,%rsi
  800540:	4c 89 ef             	mov    %r13,%rdi
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	48 bb e8 02 80 00 00 	movabs $0x8002e8,%rbx
  80054f:	00 00 00 
  800552:	ff d3                	callq  *%rbx
  800554:	e9 3f fe ff ff       	jmpq   800398 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800559:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80055d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800561:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800565:	eb a3                	jmp    80050a <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800567:	48 ba 93 11 80 00 00 	movabs $0x801193,%rdx
  80056e:	00 00 00 
  800571:	4c 89 fe             	mov    %r15,%rsi
  800574:	4c 89 ef             	mov    %r13,%rdi
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	48 bb e8 02 80 00 00 	movabs $0x8002e8,%rbx
  800583:	00 00 00 
  800586:	ff d3                	callq  *%rbx
  800588:	e9 0b fe ff ff       	jmpq   800398 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80058d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800590:	83 f8 2f             	cmp    $0x2f,%eax
  800593:	77 4b                	ja     8005e0 <vprintfmt+0x272>
  800595:	89 c2                	mov    %eax,%edx
  800597:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80059b:	83 c0 08             	add    $0x8,%eax
  80059e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005a1:	48 8b 02             	mov    (%rdx),%rax
  8005a4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005a8:	48 85 c0             	test   %rax,%rax
  8005ab:	0f 84 05 04 00 00    	je     8009b6 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005b1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005b5:	7e 06                	jle    8005bd <vprintfmt+0x24f>
  8005b7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005bb:	75 31                	jne    8005ee <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bd:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005c1:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005c5:	0f b6 00             	movzbl (%rax),%eax
  8005c8:	0f be f8             	movsbl %al,%edi
  8005cb:	85 ff                	test   %edi,%edi
  8005cd:	0f 84 c3 00 00 00    	je     800696 <vprintfmt+0x328>
  8005d3:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005d7:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005db:	e9 85 00 00 00       	jmpq   800665 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005e0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005e4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005e8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005ec:	eb b3                	jmp    8005a1 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8005ee:	49 63 f4             	movslq %r12d,%rsi
  8005f1:	48 89 c7             	mov    %rax,%rdi
  8005f4:	48 b8 45 0b 80 00 00 	movabs $0x800b45,%rax
  8005fb:	00 00 00 
  8005fe:	ff d0                	callq  *%rax
  800600:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800603:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800606:	85 f6                	test   %esi,%esi
  800608:	7e 22                	jle    80062c <vprintfmt+0x2be>
            putch(padc, putdat);
  80060a:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80060e:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800612:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800616:	4c 89 fe             	mov    %r15,%rsi
  800619:	89 df                	mov    %ebx,%edi
  80061b:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	41 83 ec 01          	sub    $0x1,%r12d
  800622:	75 f2                	jne    800616 <vprintfmt+0x2a8>
  800624:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800628:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800630:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800634:	0f b6 00             	movzbl (%rax),%eax
  800637:	0f be f8             	movsbl %al,%edi
  80063a:	85 ff                	test   %edi,%edi
  80063c:	0f 84 56 fd ff ff    	je     800398 <vprintfmt+0x2a>
  800642:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800646:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80064a:	eb 19                	jmp    800665 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80064c:	4c 89 fe             	mov    %r15,%rsi
  80064f:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800652:	41 83 ee 01          	sub    $0x1,%r14d
  800656:	48 83 c3 01          	add    $0x1,%rbx
  80065a:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80065e:	0f be f8             	movsbl %al,%edi
  800661:	85 ff                	test   %edi,%edi
  800663:	74 29                	je     80068e <vprintfmt+0x320>
  800665:	45 85 e4             	test   %r12d,%r12d
  800668:	78 06                	js     800670 <vprintfmt+0x302>
  80066a:	41 83 ec 01          	sub    $0x1,%r12d
  80066e:	78 48                	js     8006b8 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800670:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800674:	74 d6                	je     80064c <vprintfmt+0x2de>
  800676:	0f be c0             	movsbl %al,%eax
  800679:	83 e8 20             	sub    $0x20,%eax
  80067c:	83 f8 5e             	cmp    $0x5e,%eax
  80067f:	76 cb                	jbe    80064c <vprintfmt+0x2de>
            putch('?', putdat);
  800681:	4c 89 fe             	mov    %r15,%rsi
  800684:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800689:	41 ff d5             	callq  *%r13
  80068c:	eb c4                	jmp    800652 <vprintfmt+0x2e4>
  80068e:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800692:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800696:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800699:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80069d:	0f 8e f5 fc ff ff    	jle    800398 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006a3:	4c 89 fe             	mov    %r15,%rsi
  8006a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8006ab:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006ae:	83 eb 01             	sub    $0x1,%ebx
  8006b1:	75 f0                	jne    8006a3 <vprintfmt+0x335>
  8006b3:	e9 e0 fc ff ff       	jmpq   800398 <vprintfmt+0x2a>
  8006b8:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006bc:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006c0:	eb d4                	jmp    800696 <vprintfmt+0x328>
  if (lflag >= 2)
  8006c2:	83 f9 01             	cmp    $0x1,%ecx
  8006c5:	7f 1d                	jg     8006e4 <vprintfmt+0x376>
  else if (lflag)
  8006c7:	85 c9                	test   %ecx,%ecx
  8006c9:	74 5e                	je     800729 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006cb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006ce:	83 f8 2f             	cmp    $0x2f,%eax
  8006d1:	77 48                	ja     80071b <vprintfmt+0x3ad>
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006d9:	83 c0 08             	add    $0x8,%eax
  8006dc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006df:	48 8b 1a             	mov    (%rdx),%rbx
  8006e2:	eb 17                	jmp    8006fb <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8006e4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006e7:	83 f8 2f             	cmp    $0x2f,%eax
  8006ea:	77 21                	ja     80070d <vprintfmt+0x39f>
  8006ec:	89 c2                	mov    %eax,%edx
  8006ee:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006f2:	83 c0 08             	add    $0x8,%eax
  8006f5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006f8:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8006fb:	48 85 db             	test   %rbx,%rbx
  8006fe:	78 50                	js     800750 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800700:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800703:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800708:	e9 b4 01 00 00       	jmpq   8008c1 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80070d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800711:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800715:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800719:	eb dd                	jmp    8006f8 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80071b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80071f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800723:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800727:	eb b6                	jmp    8006df <vprintfmt+0x371>
    return va_arg(*ap, int);
  800729:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80072c:	83 f8 2f             	cmp    $0x2f,%eax
  80072f:	77 11                	ja     800742 <vprintfmt+0x3d4>
  800731:	89 c2                	mov    %eax,%edx
  800733:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800737:	83 c0 08             	add    $0x8,%eax
  80073a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80073d:	48 63 1a             	movslq (%rdx),%rbx
  800740:	eb b9                	jmp    8006fb <vprintfmt+0x38d>
  800742:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800746:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80074a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074e:	eb ed                	jmp    80073d <vprintfmt+0x3cf>
          putch('-', putdat);
  800750:	4c 89 fe             	mov    %r15,%rsi
  800753:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800758:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80075b:	48 89 da             	mov    %rbx,%rdx
  80075e:	48 f7 da             	neg    %rdx
        base = 10;
  800761:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800766:	e9 56 01 00 00       	jmpq   8008c1 <vprintfmt+0x553>
  if (lflag >= 2)
  80076b:	83 f9 01             	cmp    $0x1,%ecx
  80076e:	7f 25                	jg     800795 <vprintfmt+0x427>
  else if (lflag)
  800770:	85 c9                	test   %ecx,%ecx
  800772:	74 5e                	je     8007d2 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800774:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800777:	83 f8 2f             	cmp    $0x2f,%eax
  80077a:	77 48                	ja     8007c4 <vprintfmt+0x456>
  80077c:	89 c2                	mov    %eax,%edx
  80077e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800782:	83 c0 08             	add    $0x8,%eax
  800785:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800788:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80078b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800790:	e9 2c 01 00 00       	jmpq   8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800795:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800798:	83 f8 2f             	cmp    $0x2f,%eax
  80079b:	77 19                	ja     8007b6 <vprintfmt+0x448>
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a3:	83 c0 08             	add    $0x8,%eax
  8007a6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007a9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b1:	e9 0b 01 00 00       	jmpq   8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007b6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ba:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007be:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007c2:	eb e5                	jmp    8007a9 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007c4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007c8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007cc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007d0:	eb b6                	jmp    800788 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007d2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007d5:	83 f8 2f             	cmp    $0x2f,%eax
  8007d8:	77 18                	ja     8007f2 <vprintfmt+0x484>
  8007da:	89 c2                	mov    %eax,%edx
  8007dc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007e0:	83 c0 08             	add    $0x8,%eax
  8007e3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007e6:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8007e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ed:	e9 cf 00 00 00       	jmpq   8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8007f2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007f6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007fa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007fe:	eb e6                	jmp    8007e6 <vprintfmt+0x478>
  if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7f 25                	jg     80082a <vprintfmt+0x4bc>
  else if (lflag)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 5b                	je     800864 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800809:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80080c:	83 f8 2f             	cmp    $0x2f,%eax
  80080f:	77 45                	ja     800856 <vprintfmt+0x4e8>
  800811:	89 c2                	mov    %eax,%edx
  800813:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800817:	83 c0 08             	add    $0x8,%eax
  80081a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80081d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800820:	b9 08 00 00 00       	mov    $0x8,%ecx
  800825:	e9 97 00 00 00       	jmpq   8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80082a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80082d:	83 f8 2f             	cmp    $0x2f,%eax
  800830:	77 16                	ja     800848 <vprintfmt+0x4da>
  800832:	89 c2                	mov    %eax,%edx
  800834:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800838:	83 c0 08             	add    $0x8,%eax
  80083b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80083e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800841:	b9 08 00 00 00       	mov    $0x8,%ecx
  800846:	eb 79                	jmp    8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800848:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80084c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800850:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800854:	eb e8                	jmp    80083e <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800856:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80085a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80085e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800862:	eb b9                	jmp    80081d <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800864:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800867:	83 f8 2f             	cmp    $0x2f,%eax
  80086a:	77 15                	ja     800881 <vprintfmt+0x513>
  80086c:	89 c2                	mov    %eax,%edx
  80086e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800872:	83 c0 08             	add    $0x8,%eax
  800875:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800878:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80087a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80087f:	eb 40                	jmp    8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800881:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800885:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800889:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80088d:	eb e9                	jmp    800878 <vprintfmt+0x50a>
        putch('0', putdat);
  80088f:	4c 89 fe             	mov    %r15,%rsi
  800892:	bf 30 00 00 00       	mov    $0x30,%edi
  800897:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  80089a:	4c 89 fe             	mov    %r15,%rsi
  80089d:	bf 78 00 00 00       	mov    $0x78,%edi
  8008a2:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008a5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008a8:	83 f8 2f             	cmp    $0x2f,%eax
  8008ab:	77 34                	ja     8008e1 <vprintfmt+0x573>
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b3:	83 c0 08             	add    $0x8,%eax
  8008b6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008b9:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008bc:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008c1:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008c6:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008ca:	4c 89 fe             	mov    %r15,%rsi
  8008cd:	4c 89 ef             	mov    %r13,%rdi
  8008d0:	48 b8 44 02 80 00 00 	movabs $0x800244,%rax
  8008d7:	00 00 00 
  8008da:	ff d0                	callq  *%rax
        break;
  8008dc:	e9 b7 fa ff ff       	jmpq   800398 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ed:	eb ca                	jmp    8008b9 <vprintfmt+0x54b>
  if (lflag >= 2)
  8008ef:	83 f9 01             	cmp    $0x1,%ecx
  8008f2:	7f 22                	jg     800916 <vprintfmt+0x5a8>
  else if (lflag)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 58                	je     800950 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8008f8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008fb:	83 f8 2f             	cmp    $0x2f,%eax
  8008fe:	77 42                	ja     800942 <vprintfmt+0x5d4>
  800900:	89 c2                	mov    %eax,%edx
  800902:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800906:	83 c0 08             	add    $0x8,%eax
  800909:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80090c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80090f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800914:	eb ab                	jmp    8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800916:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800919:	83 f8 2f             	cmp    $0x2f,%eax
  80091c:	77 16                	ja     800934 <vprintfmt+0x5c6>
  80091e:	89 c2                	mov    %eax,%edx
  800920:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800924:	83 c0 08             	add    $0x8,%eax
  800927:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80092d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800932:	eb 8d                	jmp    8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800934:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800938:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800940:	eb e8                	jmp    80092a <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800942:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800946:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094e:	eb bc                	jmp    80090c <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800950:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800953:	83 f8 2f             	cmp    $0x2f,%eax
  800956:	77 18                	ja     800970 <vprintfmt+0x602>
  800958:	89 c2                	mov    %eax,%edx
  80095a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095e:	83 c0 08             	add    $0x8,%eax
  800961:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800964:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800966:	b9 10 00 00 00       	mov    $0x10,%ecx
  80096b:	e9 51 ff ff ff       	jmpq   8008c1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800970:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800974:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800978:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097c:	eb e6                	jmp    800964 <vprintfmt+0x5f6>
        putch(ch, putdat);
  80097e:	4c 89 fe             	mov    %r15,%rsi
  800981:	bf 25 00 00 00       	mov    $0x25,%edi
  800986:	41 ff d5             	callq  *%r13
        break;
  800989:	e9 0a fa ff ff       	jmpq   800398 <vprintfmt+0x2a>
        putch('%', putdat);
  80098e:	4c 89 fe             	mov    %r15,%rsi
  800991:	bf 25 00 00 00       	mov    $0x25,%edi
  800996:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800999:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  80099d:	0f 84 15 fa ff ff    	je     8003b8 <vprintfmt+0x4a>
  8009a3:	49 89 de             	mov    %rbx,%r14
  8009a6:	49 83 ee 01          	sub    $0x1,%r14
  8009aa:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009af:	75 f5                	jne    8009a6 <vprintfmt+0x638>
  8009b1:	e9 e2 f9 ff ff       	jmpq   800398 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009b6:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009ba:	74 06                	je     8009c2 <vprintfmt+0x654>
  8009bc:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009c0:	7f 21                	jg     8009e3 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c2:	bf 28 00 00 00       	mov    $0x28,%edi
  8009c7:	48 bb 8d 11 80 00 00 	movabs $0x80118d,%rbx
  8009ce:	00 00 00 
  8009d1:	b8 28 00 00 00       	mov    $0x28,%eax
  8009d6:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009da:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009de:	e9 82 fc ff ff       	jmpq   800665 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009e3:	49 63 f4             	movslq %r12d,%rsi
  8009e6:	48 bf 8c 11 80 00 00 	movabs $0x80118c,%rdi
  8009ed:	00 00 00 
  8009f0:	48 b8 45 0b 80 00 00 	movabs $0x800b45,%rax
  8009f7:	00 00 00 
  8009fa:	ff d0                	callq  *%rax
  8009fc:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8009ff:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a02:	48 be 8c 11 80 00 00 	movabs $0x80118c,%rsi
  800a09:	00 00 00 
  800a0c:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a10:	85 c0                	test   %eax,%eax
  800a12:	0f 8f f2 fb ff ff    	jg     80060a <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a18:	48 bb 8d 11 80 00 00 	movabs $0x80118d,%rbx
  800a1f:	00 00 00 
  800a22:	b8 28 00 00 00       	mov    $0x28,%eax
  800a27:	bf 28 00 00 00       	mov    $0x28,%edi
  800a2c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a30:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a34:	e9 2c fc ff ff       	jmpq   800665 <vprintfmt+0x2f7>
}
  800a39:	48 83 c4 48          	add    $0x48,%rsp
  800a3d:	5b                   	pop    %rbx
  800a3e:	41 5c                	pop    %r12
  800a40:	41 5d                	pop    %r13
  800a42:	41 5e                	pop    %r14
  800a44:	41 5f                	pop    %r15
  800a46:	5d                   	pop    %rbp
  800a47:	c3                   	retq   

0000000000800a48 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a48:	55                   	push   %rbp
  800a49:	48 89 e5             	mov    %rsp,%rbp
  800a4c:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a50:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a54:	48 63 c6             	movslq %esi,%rax
  800a57:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a5c:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a67:	48 85 ff             	test   %rdi,%rdi
  800a6a:	74 2a                	je     800a96 <vsnprintf+0x4e>
  800a6c:	85 f6                	test   %esi,%esi
  800a6e:	7e 26                	jle    800a96 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a70:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a74:	48 bf d0 02 80 00 00 	movabs $0x8002d0,%rdi
  800a7b:	00 00 00 
  800a7e:	48 b8 6e 03 80 00 00 	movabs $0x80036e,%rax
  800a85:	00 00 00 
  800a88:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800a8a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800a8e:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800a91:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800a94:	c9                   	leaveq 
  800a95:	c3                   	retq   
    return -E_INVAL;
  800a96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a9b:	eb f7                	jmp    800a94 <vsnprintf+0x4c>

0000000000800a9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800a9d:	55                   	push   %rbp
  800a9e:	48 89 e5             	mov    %rsp,%rbp
  800aa1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800aa8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800aaf:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ab6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800abd:	84 c0                	test   %al,%al
  800abf:	74 20                	je     800ae1 <snprintf+0x44>
  800ac1:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ac5:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800ac9:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800acd:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ad1:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ad5:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ad9:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800add:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ae1:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ae8:	00 00 00 
  800aeb:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800af2:	00 00 00 
  800af5:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800af9:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b00:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b07:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b0e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b15:	48 b8 48 0a 80 00 00 	movabs $0x800a48,%rax
  800b1c:	00 00 00 
  800b1f:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b21:	c9                   	leaveq 
  800b22:	c3                   	retq   

0000000000800b23 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b23:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b26:	74 17                	je     800b3f <strlen+0x1c>
  800b28:	48 89 fa             	mov    %rdi,%rdx
  800b2b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b30:	29 f9                	sub    %edi,%ecx
    n++;
  800b32:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b35:	48 83 c2 01          	add    $0x1,%rdx
  800b39:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b3c:	75 f4                	jne    800b32 <strlen+0xf>
  800b3e:	c3                   	retq   
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b44:	c3                   	retq   

0000000000800b45 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b45:	48 85 f6             	test   %rsi,%rsi
  800b48:	74 24                	je     800b6e <strnlen+0x29>
  800b4a:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b4d:	74 25                	je     800b74 <strnlen+0x2f>
  800b4f:	48 01 fe             	add    %rdi,%rsi
  800b52:	48 89 fa             	mov    %rdi,%rdx
  800b55:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b5a:	29 f9                	sub    %edi,%ecx
    n++;
  800b5c:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b5f:	48 83 c2 01          	add    $0x1,%rdx
  800b63:	48 39 f2             	cmp    %rsi,%rdx
  800b66:	74 11                	je     800b79 <strnlen+0x34>
  800b68:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b6b:	75 ef                	jne    800b5c <strnlen+0x17>
  800b6d:	c3                   	retq   
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b73:	c3                   	retq   
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b79:	c3                   	retq   

0000000000800b7a <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b7a:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800b86:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800b89:	48 83 c2 01          	add    $0x1,%rdx
  800b8d:	84 c9                	test   %cl,%cl
  800b8f:	75 f1                	jne    800b82 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800b91:	c3                   	retq   

0000000000800b92 <strcat>:

char *
strcat(char *dst, const char *src) {
  800b92:	55                   	push   %rbp
  800b93:	48 89 e5             	mov    %rsp,%rbp
  800b96:	41 54                	push   %r12
  800b98:	53                   	push   %rbx
  800b99:	48 89 fb             	mov    %rdi,%rbx
  800b9c:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800b9f:	48 b8 23 0b 80 00 00 	movabs $0x800b23,%rax
  800ba6:	00 00 00 
  800ba9:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bab:	48 63 f8             	movslq %eax,%rdi
  800bae:	48 01 df             	add    %rbx,%rdi
  800bb1:	4c 89 e6             	mov    %r12,%rsi
  800bb4:	48 b8 7a 0b 80 00 00 	movabs $0x800b7a,%rax
  800bbb:	00 00 00 
  800bbe:	ff d0                	callq  *%rax
  return dst;
}
  800bc0:	48 89 d8             	mov    %rbx,%rax
  800bc3:	5b                   	pop    %rbx
  800bc4:	41 5c                	pop    %r12
  800bc6:	5d                   	pop    %rbp
  800bc7:	c3                   	retq   

0000000000800bc8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc8:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bcb:	48 85 d2             	test   %rdx,%rdx
  800bce:	74 1f                	je     800bef <strncpy+0x27>
  800bd0:	48 01 fa             	add    %rdi,%rdx
  800bd3:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bd6:	48 83 c1 01          	add    $0x1,%rcx
  800bda:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bde:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800be2:	41 80 f8 01          	cmp    $0x1,%r8b
  800be6:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800bea:	48 39 ca             	cmp    %rcx,%rdx
  800bed:	75 e7                	jne    800bd6 <strncpy+0xe>
  }
  return ret;
}
  800bef:	c3                   	retq   

0000000000800bf0 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800bf0:	48 89 f8             	mov    %rdi,%rax
  800bf3:	48 85 d2             	test   %rdx,%rdx
  800bf6:	74 36                	je     800c2e <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800bf8:	48 83 fa 01          	cmp    $0x1,%rdx
  800bfc:	74 2d                	je     800c2b <strlcpy+0x3b>
  800bfe:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c02:	45 84 c0             	test   %r8b,%r8b
  800c05:	74 24                	je     800c2b <strlcpy+0x3b>
  800c07:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c0b:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c10:	48 83 c0 01          	add    $0x1,%rax
  800c14:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c18:	48 39 d1             	cmp    %rdx,%rcx
  800c1b:	74 0e                	je     800c2b <strlcpy+0x3b>
  800c1d:	48 83 c1 01          	add    $0x1,%rcx
  800c21:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c26:	45 84 c0             	test   %r8b,%r8b
  800c29:	75 e5                	jne    800c10 <strlcpy+0x20>
    *dst = '\0';
  800c2b:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c2e:	48 29 f8             	sub    %rdi,%rax
}
  800c31:	c3                   	retq   

0000000000800c32 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c32:	0f b6 07             	movzbl (%rdi),%eax
  800c35:	84 c0                	test   %al,%al
  800c37:	74 17                	je     800c50 <strcmp+0x1e>
  800c39:	3a 06                	cmp    (%rsi),%al
  800c3b:	75 13                	jne    800c50 <strcmp+0x1e>
    p++, q++;
  800c3d:	48 83 c7 01          	add    $0x1,%rdi
  800c41:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c45:	0f b6 07             	movzbl (%rdi),%eax
  800c48:	84 c0                	test   %al,%al
  800c4a:	74 04                	je     800c50 <strcmp+0x1e>
  800c4c:	3a 06                	cmp    (%rsi),%al
  800c4e:	74 ed                	je     800c3d <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c50:	0f b6 c0             	movzbl %al,%eax
  800c53:	0f b6 16             	movzbl (%rsi),%edx
  800c56:	29 d0                	sub    %edx,%eax
}
  800c58:	c3                   	retq   

0000000000800c59 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c59:	48 85 d2             	test   %rdx,%rdx
  800c5c:	74 2f                	je     800c8d <strncmp+0x34>
  800c5e:	0f b6 07             	movzbl (%rdi),%eax
  800c61:	84 c0                	test   %al,%al
  800c63:	74 1f                	je     800c84 <strncmp+0x2b>
  800c65:	3a 06                	cmp    (%rsi),%al
  800c67:	75 1b                	jne    800c84 <strncmp+0x2b>
  800c69:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c6c:	48 83 c7 01          	add    $0x1,%rdi
  800c70:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c74:	48 39 d7             	cmp    %rdx,%rdi
  800c77:	74 1a                	je     800c93 <strncmp+0x3a>
  800c79:	0f b6 07             	movzbl (%rdi),%eax
  800c7c:	84 c0                	test   %al,%al
  800c7e:	74 04                	je     800c84 <strncmp+0x2b>
  800c80:	3a 06                	cmp    (%rsi),%al
  800c82:	74 e8                	je     800c6c <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800c84:	0f b6 07             	movzbl (%rdi),%eax
  800c87:	0f b6 16             	movzbl (%rsi),%edx
  800c8a:	29 d0                	sub    %edx,%eax
}
  800c8c:	c3                   	retq   
    return 0;
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c92:	c3                   	retq   
  800c93:	b8 00 00 00 00       	mov    $0x0,%eax
  800c98:	c3                   	retq   

0000000000800c99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800c99:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800c9b:	0f b6 07             	movzbl (%rdi),%eax
  800c9e:	84 c0                	test   %al,%al
  800ca0:	74 1e                	je     800cc0 <strchr+0x27>
    if (*s == c)
  800ca2:	40 38 c6             	cmp    %al,%sil
  800ca5:	74 1f                	je     800cc6 <strchr+0x2d>
  for (; *s; s++)
  800ca7:	48 83 c7 01          	add    $0x1,%rdi
  800cab:	0f b6 07             	movzbl (%rdi),%eax
  800cae:	84 c0                	test   %al,%al
  800cb0:	74 08                	je     800cba <strchr+0x21>
    if (*s == c)
  800cb2:	38 d0                	cmp    %dl,%al
  800cb4:	75 f1                	jne    800ca7 <strchr+0xe>
  for (; *s; s++)
  800cb6:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cb9:	c3                   	retq   
  return 0;
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbf:	c3                   	retq   
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc5:	c3                   	retq   
    if (*s == c)
  800cc6:	48 89 f8             	mov    %rdi,%rax
  800cc9:	c3                   	retq   

0000000000800cca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cca:	48 89 f8             	mov    %rdi,%rax
  800ccd:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800ccf:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cd2:	40 38 f2             	cmp    %sil,%dl
  800cd5:	74 13                	je     800cea <strfind+0x20>
  800cd7:	84 d2                	test   %dl,%dl
  800cd9:	74 0f                	je     800cea <strfind+0x20>
  for (; *s; s++)
  800cdb:	48 83 c0 01          	add    $0x1,%rax
  800cdf:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800ce2:	38 ca                	cmp    %cl,%dl
  800ce4:	74 04                	je     800cea <strfind+0x20>
  800ce6:	84 d2                	test   %dl,%dl
  800ce8:	75 f1                	jne    800cdb <strfind+0x11>
      break;
  return (char *)s;
}
  800cea:	c3                   	retq   

0000000000800ceb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800ceb:	48 85 d2             	test   %rdx,%rdx
  800cee:	74 3a                	je     800d2a <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800cf0:	48 89 f8             	mov    %rdi,%rax
  800cf3:	48 09 d0             	or     %rdx,%rax
  800cf6:	a8 03                	test   $0x3,%al
  800cf8:	75 28                	jne    800d22 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800cfa:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800cfe:	89 f0                	mov    %esi,%eax
  800d00:	c1 e0 08             	shl    $0x8,%eax
  800d03:	89 f1                	mov    %esi,%ecx
  800d05:	c1 e1 18             	shl    $0x18,%ecx
  800d08:	41 89 f0             	mov    %esi,%r8d
  800d0b:	41 c1 e0 10          	shl    $0x10,%r8d
  800d0f:	44 09 c1             	or     %r8d,%ecx
  800d12:	09 ce                	or     %ecx,%esi
  800d14:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d16:	48 c1 ea 02          	shr    $0x2,%rdx
  800d1a:	48 89 d1             	mov    %rdx,%rcx
  800d1d:	fc                   	cld    
  800d1e:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d20:	eb 08                	jmp    800d2a <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d22:	89 f0                	mov    %esi,%eax
  800d24:	48 89 d1             	mov    %rdx,%rcx
  800d27:	fc                   	cld    
  800d28:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d2a:	48 89 f8             	mov    %rdi,%rax
  800d2d:	c3                   	retq   

0000000000800d2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d2e:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d31:	48 39 fe             	cmp    %rdi,%rsi
  800d34:	73 40                	jae    800d76 <memmove+0x48>
  800d36:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d3a:	48 39 f9             	cmp    %rdi,%rcx
  800d3d:	76 37                	jbe    800d76 <memmove+0x48>
    s += n;
    d += n;
  800d3f:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d43:	48 89 fe             	mov    %rdi,%rsi
  800d46:	48 09 d6             	or     %rdx,%rsi
  800d49:	48 09 ce             	or     %rcx,%rsi
  800d4c:	40 f6 c6 03          	test   $0x3,%sil
  800d50:	75 14                	jne    800d66 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d52:	48 83 ef 04          	sub    $0x4,%rdi
  800d56:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d5a:	48 c1 ea 02          	shr    $0x2,%rdx
  800d5e:	48 89 d1             	mov    %rdx,%rcx
  800d61:	fd                   	std    
  800d62:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d64:	eb 0e                	jmp    800d74 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d66:	48 83 ef 01          	sub    $0x1,%rdi
  800d6a:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d6e:	48 89 d1             	mov    %rdx,%rcx
  800d71:	fd                   	std    
  800d72:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d74:	fc                   	cld    
  800d75:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d76:	48 89 c1             	mov    %rax,%rcx
  800d79:	48 09 d1             	or     %rdx,%rcx
  800d7c:	48 09 f1             	or     %rsi,%rcx
  800d7f:	f6 c1 03             	test   $0x3,%cl
  800d82:	75 0e                	jne    800d92 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800d84:	48 c1 ea 02          	shr    $0x2,%rdx
  800d88:	48 89 d1             	mov    %rdx,%rcx
  800d8b:	48 89 c7             	mov    %rax,%rdi
  800d8e:	fc                   	cld    
  800d8f:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d91:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800d92:	48 89 c7             	mov    %rax,%rdi
  800d95:	48 89 d1             	mov    %rdx,%rcx
  800d98:	fc                   	cld    
  800d99:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800d9b:	c3                   	retq   

0000000000800d9c <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800d9c:	55                   	push   %rbp
  800d9d:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800da0:	48 b8 2e 0d 80 00 00 	movabs $0x800d2e,%rax
  800da7:	00 00 00 
  800daa:	ff d0                	callq  *%rax
}
  800dac:	5d                   	pop    %rbp
  800dad:	c3                   	retq   

0000000000800dae <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dae:	55                   	push   %rbp
  800daf:	48 89 e5             	mov    %rsp,%rbp
  800db2:	41 57                	push   %r15
  800db4:	41 56                	push   %r14
  800db6:	41 55                	push   %r13
  800db8:	41 54                	push   %r12
  800dba:	53                   	push   %rbx
  800dbb:	48 83 ec 08          	sub    $0x8,%rsp
  800dbf:	49 89 fe             	mov    %rdi,%r14
  800dc2:	49 89 f7             	mov    %rsi,%r15
  800dc5:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800dc8:	48 89 f7             	mov    %rsi,%rdi
  800dcb:	48 b8 23 0b 80 00 00 	movabs $0x800b23,%rax
  800dd2:	00 00 00 
  800dd5:	ff d0                	callq  *%rax
  800dd7:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dda:	4c 89 ee             	mov    %r13,%rsi
  800ddd:	4c 89 f7             	mov    %r14,%rdi
  800de0:	48 b8 45 0b 80 00 00 	movabs $0x800b45,%rax
  800de7:	00 00 00 
  800dea:	ff d0                	callq  *%rax
  800dec:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800def:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800df3:	4d 39 e5             	cmp    %r12,%r13
  800df6:	74 26                	je     800e1e <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800df8:	4c 89 e8             	mov    %r13,%rax
  800dfb:	4c 29 e0             	sub    %r12,%rax
  800dfe:	48 39 d8             	cmp    %rbx,%rax
  800e01:	76 2a                	jbe    800e2d <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e03:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e07:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e0b:	4c 89 fe             	mov    %r15,%rsi
  800e0e:	48 b8 9c 0d 80 00 00 	movabs $0x800d9c,%rax
  800e15:	00 00 00 
  800e18:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e1a:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e1e:	48 83 c4 08          	add    $0x8,%rsp
  800e22:	5b                   	pop    %rbx
  800e23:	41 5c                	pop    %r12
  800e25:	41 5d                	pop    %r13
  800e27:	41 5e                	pop    %r14
  800e29:	41 5f                	pop    %r15
  800e2b:	5d                   	pop    %rbp
  800e2c:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e2d:	49 83 ed 01          	sub    $0x1,%r13
  800e31:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e35:	4c 89 ea             	mov    %r13,%rdx
  800e38:	4c 89 fe             	mov    %r15,%rsi
  800e3b:	48 b8 9c 0d 80 00 00 	movabs $0x800d9c,%rax
  800e42:	00 00 00 
  800e45:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e47:	4d 01 ee             	add    %r13,%r14
  800e4a:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e4f:	eb c9                	jmp    800e1a <strlcat+0x6c>

0000000000800e51 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e51:	48 85 d2             	test   %rdx,%rdx
  800e54:	74 3a                	je     800e90 <memcmp+0x3f>
    if (*s1 != *s2)
  800e56:	0f b6 0f             	movzbl (%rdi),%ecx
  800e59:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e5d:	44 38 c1             	cmp    %r8b,%cl
  800e60:	75 1d                	jne    800e7f <memcmp+0x2e>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e67:	48 39 d0             	cmp    %rdx,%rax
  800e6a:	74 1e                	je     800e8a <memcmp+0x39>
    if (*s1 != *s2)
  800e6c:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e70:	48 83 c0 01          	add    $0x1,%rax
  800e74:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e7a:	44 38 c1             	cmp    %r8b,%cl
  800e7d:	74 e8                	je     800e67 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e7f:	0f b6 c1             	movzbl %cl,%eax
  800e82:	45 0f b6 c0          	movzbl %r8b,%r8d
  800e86:	44 29 c0             	sub    %r8d,%eax
  800e89:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8f:	c3                   	retq   
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e95:	c3                   	retq   

0000000000800e96 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800e96:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800e9a:	48 39 c7             	cmp    %rax,%rdi
  800e9d:	73 19                	jae    800eb8 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800e9f:	89 f2                	mov    %esi,%edx
  800ea1:	40 38 37             	cmp    %sil,(%rdi)
  800ea4:	74 16                	je     800ebc <memfind+0x26>
  for (; s < ends; s++)
  800ea6:	48 83 c7 01          	add    $0x1,%rdi
  800eaa:	48 39 f8             	cmp    %rdi,%rax
  800ead:	74 08                	je     800eb7 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800eaf:	38 17                	cmp    %dl,(%rdi)
  800eb1:	75 f3                	jne    800ea6 <memfind+0x10>
  for (; s < ends; s++)
  800eb3:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800eb6:	c3                   	retq   
  800eb7:	c3                   	retq   
  for (; s < ends; s++)
  800eb8:	48 89 f8             	mov    %rdi,%rax
  800ebb:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ebc:	48 89 f8             	mov    %rdi,%rax
  800ebf:	c3                   	retq   

0000000000800ec0 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ec0:	0f b6 07             	movzbl (%rdi),%eax
  800ec3:	3c 20                	cmp    $0x20,%al
  800ec5:	74 04                	je     800ecb <strtol+0xb>
  800ec7:	3c 09                	cmp    $0x9,%al
  800ec9:	75 0f                	jne    800eda <strtol+0x1a>
    s++;
  800ecb:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ecf:	0f b6 07             	movzbl (%rdi),%eax
  800ed2:	3c 20                	cmp    $0x20,%al
  800ed4:	74 f5                	je     800ecb <strtol+0xb>
  800ed6:	3c 09                	cmp    $0x9,%al
  800ed8:	74 f1                	je     800ecb <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800eda:	3c 2b                	cmp    $0x2b,%al
  800edc:	74 2b                	je     800f09 <strtol+0x49>
  int neg  = 0;
  800ede:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800ee4:	3c 2d                	cmp    $0x2d,%al
  800ee6:	74 2d                	je     800f15 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee8:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800eee:	75 0f                	jne    800eff <strtol+0x3f>
  800ef0:	80 3f 30             	cmpb   $0x30,(%rdi)
  800ef3:	74 2c                	je     800f21 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800ef5:	85 d2                	test   %edx,%edx
  800ef7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efc:	0f 44 d0             	cmove  %eax,%edx
  800eff:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f04:	4c 63 d2             	movslq %edx,%r10
  800f07:	eb 5c                	jmp    800f65 <strtol+0xa5>
    s++;
  800f09:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f0d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f13:	eb d3                	jmp    800ee8 <strtol+0x28>
    s++, neg = 1;
  800f15:	48 83 c7 01          	add    $0x1,%rdi
  800f19:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f1f:	eb c7                	jmp    800ee8 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f21:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f25:	74 0f                	je     800f36 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f27:	85 d2                	test   %edx,%edx
  800f29:	75 d4                	jne    800eff <strtol+0x3f>
    s++, base = 8;
  800f2b:	48 83 c7 01          	add    $0x1,%rdi
  800f2f:	ba 08 00 00 00       	mov    $0x8,%edx
  800f34:	eb c9                	jmp    800eff <strtol+0x3f>
    s += 2, base = 16;
  800f36:	48 83 c7 02          	add    $0x2,%rdi
  800f3a:	ba 10 00 00 00       	mov    $0x10,%edx
  800f3f:	eb be                	jmp    800eff <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f41:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f45:	41 80 f8 19          	cmp    $0x19,%r8b
  800f49:	77 2f                	ja     800f7a <strtol+0xba>
      dig = *s - 'a' + 10;
  800f4b:	44 0f be c1          	movsbl %cl,%r8d
  800f4f:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f53:	39 d1                	cmp    %edx,%ecx
  800f55:	7d 37                	jge    800f8e <strtol+0xce>
    s++, val = (val * base) + dig;
  800f57:	48 83 c7 01          	add    $0x1,%rdi
  800f5b:	49 0f af c2          	imul   %r10,%rax
  800f5f:	48 63 c9             	movslq %ecx,%rcx
  800f62:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f65:	0f b6 0f             	movzbl (%rdi),%ecx
  800f68:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f6c:	41 80 f8 09          	cmp    $0x9,%r8b
  800f70:	77 cf                	ja     800f41 <strtol+0x81>
      dig = *s - '0';
  800f72:	0f be c9             	movsbl %cl,%ecx
  800f75:	83 e9 30             	sub    $0x30,%ecx
  800f78:	eb d9                	jmp    800f53 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f7a:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f7e:	41 80 f8 19          	cmp    $0x19,%r8b
  800f82:	77 0a                	ja     800f8e <strtol+0xce>
      dig = *s - 'A' + 10;
  800f84:	44 0f be c1          	movsbl %cl,%r8d
  800f88:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800f8c:	eb c5                	jmp    800f53 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800f8e:	48 85 f6             	test   %rsi,%rsi
  800f91:	74 03                	je     800f96 <strtol+0xd6>
    *endptr = (char *)s;
  800f93:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800f96:	48 89 c2             	mov    %rax,%rdx
  800f99:	48 f7 da             	neg    %rdx
  800f9c:	45 85 c9             	test   %r9d,%r9d
  800f9f:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fa3:	c3                   	retq   

0000000000800fa4 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fa4:	55                   	push   %rbp
  800fa5:	48 89 e5             	mov    %rsp,%rbp
  800fa8:	53                   	push   %rbx
  800fa9:	48 89 fa             	mov    %rdi,%rdx
  800fac:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800faf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb4:	48 89 c3             	mov    %rax,%rbx
  800fb7:	48 89 c7             	mov    %rax,%rdi
  800fba:	48 89 c6             	mov    %rax,%rsi
  800fbd:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fbf:	5b                   	pop    %rbx
  800fc0:	5d                   	pop    %rbp
  800fc1:	c3                   	retq   

0000000000800fc2 <sys_cgetc>:

int
sys_cgetc(void) {
  800fc2:	55                   	push   %rbp
  800fc3:	48 89 e5             	mov    %rsp,%rbp
  800fc6:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd1:	48 89 ca             	mov    %rcx,%rdx
  800fd4:	48 89 cb             	mov    %rcx,%rbx
  800fd7:	48 89 cf             	mov    %rcx,%rdi
  800fda:	48 89 ce             	mov    %rcx,%rsi
  800fdd:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fdf:	5b                   	pop    %rbx
  800fe0:	5d                   	pop    %rbp
  800fe1:	c3                   	retq   

0000000000800fe2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800fe2:	55                   	push   %rbp
  800fe3:	48 89 e5             	mov    %rsp,%rbp
  800fe6:	53                   	push   %rbx
  800fe7:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800feb:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800fee:	be 00 00 00 00       	mov    $0x0,%esi
  800ff3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff8:	48 89 f1             	mov    %rsi,%rcx
  800ffb:	48 89 f3             	mov    %rsi,%rbx
  800ffe:	48 89 f7             	mov    %rsi,%rdi
  801001:	cd 30                	int    $0x30
  if (check && ret > 0)
  801003:	48 85 c0             	test   %rax,%rax
  801006:	7f 07                	jg     80100f <sys_env_destroy+0x2d>
}
  801008:	48 83 c4 08          	add    $0x8,%rsp
  80100c:	5b                   	pop    %rbx
  80100d:	5d                   	pop    %rbp
  80100e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80100f:	49 89 c0             	mov    %rax,%r8
  801012:	b9 03 00 00 00       	mov    $0x3,%ecx
  801017:	48 ba 30 15 80 00 00 	movabs $0x801530,%rdx
  80101e:	00 00 00 
  801021:	be 22 00 00 00       	mov    $0x22,%esi
  801026:	48 bf 4f 15 80 00 00 	movabs $0x80154f,%rdi
  80102d:	00 00 00 
  801030:	b8 00 00 00 00       	mov    $0x0,%eax
  801035:	49 b9 62 10 80 00 00 	movabs $0x801062,%r9
  80103c:	00 00 00 
  80103f:	41 ff d1             	callq  *%r9

0000000000801042 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801042:	55                   	push   %rbp
  801043:	48 89 e5             	mov    %rsp,%rbp
  801046:	53                   	push   %rbx
  asm volatile("int %1\n"
  801047:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104c:	b8 02 00 00 00       	mov    $0x2,%eax
  801051:	48 89 ca             	mov    %rcx,%rdx
  801054:	48 89 cb             	mov    %rcx,%rbx
  801057:	48 89 cf             	mov    %rcx,%rdi
  80105a:	48 89 ce             	mov    %rcx,%rsi
  80105d:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80105f:	5b                   	pop    %rbx
  801060:	5d                   	pop    %rbp
  801061:	c3                   	retq   

0000000000801062 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801062:	55                   	push   %rbp
  801063:	48 89 e5             	mov    %rsp,%rbp
  801066:	41 56                	push   %r14
  801068:	41 55                	push   %r13
  80106a:	41 54                	push   %r12
  80106c:	53                   	push   %rbx
  80106d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801074:	49 89 fd             	mov    %rdi,%r13
  801077:	41 89 f6             	mov    %esi,%r14d
  80107a:	49 89 d4             	mov    %rdx,%r12
  80107d:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801084:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80108b:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801092:	84 c0                	test   %al,%al
  801094:	74 26                	je     8010bc <_panic+0x5a>
  801096:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80109d:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010a4:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010a8:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010ac:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010b0:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010b4:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010b8:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010bc:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010c3:	00 00 00 
  8010c6:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010cd:	00 00 00 
  8010d0:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010d4:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010db:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8010e2:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8010e9:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8010f0:	00 00 00 
  8010f3:	48 8b 18             	mov    (%rax),%rbx
  8010f6:	48 b8 42 10 80 00 00 	movabs $0x801042,%rax
  8010fd:	00 00 00 
  801100:	ff d0                	callq  *%rax
  801102:	45 89 f0             	mov    %r14d,%r8d
  801105:	4c 89 e9             	mov    %r13,%rcx
  801108:	48 89 da             	mov    %rbx,%rdx
  80110b:	89 c6                	mov    %eax,%esi
  80110d:	48 bf 60 15 80 00 00 	movabs $0x801560,%rdi
  801114:	00 00 00 
  801117:	b8 00 00 00 00       	mov    $0x0,%eax
  80111c:	48 bb b0 01 80 00 00 	movabs $0x8001b0,%rbx
  801123:	00 00 00 
  801126:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801128:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80112f:	4c 89 e7             	mov    %r12,%rdi
  801132:	48 b8 48 01 80 00 00 	movabs $0x800148,%rax
  801139:	00 00 00 
  80113c:	ff d0                	callq  *%rax
  cprintf("\n");
  80113e:	48 bf 6f 11 80 00 00 	movabs $0x80116f,%rdi
  801145:	00 00 00 
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80114f:	cc                   	int3   
  while (1)
  801150:	eb fd                	jmp    80114f <_panic+0xed>
  801152:	66 90                	xchg   %ax,%ax
