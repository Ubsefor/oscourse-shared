
obj/user/bounds:     file format elf64-x86-64


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
  800023:	e8 3a 00 00 00       	callq  800062 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
//Test for UBSAN support - accessing array element with an out-of-borders index

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	48 83 ec 10          	sub    $0x10,%rsp
  int a[4] = {0};
  //Trying to print the value of the fifth element of the array (which causes undefined behavior).
  //The "cprintf" function is sanitized by UBSAN because lib/Makefrag accesses the USER_SAN_CFLAGS variable.
  //The access operator ([]) is not used because it will trigger -Warray-bounds option of Clang,
  //which will make this test unrunnable because of -Werror flag which is specified in GNUmakefile.
  cprintf("%d\n", *(a + 5));
  800032:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  800039:	00 
  80003a:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  800041:	00 
  800042:	8b 75 04             	mov    0x4(%rbp),%esi
  800045:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  80004c:	00 00 00 
  80004f:	b8 00 00 00 00       	mov    $0x0,%eax
  800054:	48 ba b1 01 80 00 00 	movabs $0x8001b1,%rdx
  80005b:	00 00 00 
  80005e:	ff d2                	callq  *%rdx
}
  800060:	c9                   	leaveq 
  800061:	c3                   	retq   

0000000000800062 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800062:	55                   	push   %rbp
  800063:	48 89 e5             	mov    %rsp,%rbp
  800066:	41 56                	push   %r14
  800068:	41 55                	push   %r13
  80006a:	41 54                	push   %r12
  80006c:	53                   	push   %rbx
  80006d:	41 89 fd             	mov    %edi,%r13d
  800070:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800073:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80007a:	00 00 00 
  80007d:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800084:	00 00 00 
  800087:	48 39 c2             	cmp    %rax,%rdx
  80008a:	73 23                	jae    8000af <libmain+0x4d>
  80008c:	48 89 d3             	mov    %rdx,%rbx
  80008f:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800093:	48 29 d0             	sub    %rdx,%rax
  800096:	48 c1 e8 03          	shr    $0x3,%rax
  80009a:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	ff 13                	callq  *(%rbx)
    ctor++;
  8000a6:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8000aa:	4c 39 e3             	cmp    %r12,%rbx
  8000ad:	75 f0                	jne    80009f <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000af:	45 85 ed             	test   %r13d,%r13d
  8000b2:	7e 0d                	jle    8000c1 <libmain+0x5f>
    binaryname = argv[0];
  8000b4:	49 8b 06             	mov    (%r14),%rax
  8000b7:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000be:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000c1:	4c 89 f6             	mov    %r14,%rsi
  8000c4:	44 89 ef             	mov    %r13d,%edi
  8000c7:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000ce:	00 00 00 
  8000d1:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000d3:	48 b8 e8 00 80 00 00 	movabs $0x8000e8,%rax
  8000da:	00 00 00 
  8000dd:	ff d0                	callq  *%rax
#endif
}
  8000df:	5b                   	pop    %rbx
  8000e0:	41 5c                	pop    %r12
  8000e2:	41 5d                	pop    %r13
  8000e4:	41 5e                	pop    %r14
  8000e6:	5d                   	pop    %rbp
  8000e7:	c3                   	retq   

00000000008000e8 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000e8:	55                   	push   %rbp
  8000e9:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f1:	48 b8 e3 0f 80 00 00 	movabs $0x800fe3,%rax
  8000f8:	00 00 00 
  8000fb:	ff d0                	callq  *%rax
}
  8000fd:	5d                   	pop    %rbp
  8000fe:	c3                   	retq   

00000000008000ff <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8000ff:	55                   	push   %rbp
  800100:	48 89 e5             	mov    %rsp,%rbp
  800103:	53                   	push   %rbx
  800104:	48 83 ec 08          	sub    $0x8,%rsp
  800108:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80010b:	8b 06                	mov    (%rsi),%eax
  80010d:	8d 50 01             	lea    0x1(%rax),%edx
  800110:	89 16                	mov    %edx,(%rsi)
  800112:	48 98                	cltq   
  800114:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800119:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80011f:	74 0b                	je     80012c <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800121:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800125:	48 83 c4 08          	add    $0x8,%rsp
  800129:	5b                   	pop    %rbx
  80012a:	5d                   	pop    %rbp
  80012b:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80012c:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800130:	be ff 00 00 00       	mov    $0xff,%esi
  800135:	48 b8 a5 0f 80 00 00 	movabs $0x800fa5,%rax
  80013c:	00 00 00 
  80013f:	ff d0                	callq  *%rax
    b->idx = 0;
  800141:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800147:	eb d8                	jmp    800121 <putch+0x22>

0000000000800149 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800149:	55                   	push   %rbp
  80014a:	48 89 e5             	mov    %rsp,%rbp
  80014d:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800154:	48 89 fa             	mov    %rdi,%rdx
  800157:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800161:	00 00 00 
  b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80016b:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80016e:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800175:	48 bf ff 00 80 00 00 	movabs $0x8000ff,%rdi
  80017c:	00 00 00 
  80017f:	48 b8 6f 03 80 00 00 	movabs $0x80036f,%rax
  800186:	00 00 00 
  800189:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80018b:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800192:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800199:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80019d:	48 b8 a5 0f 80 00 00 	movabs $0x800fa5,%rax
  8001a4:	00 00 00 
  8001a7:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001af:	c9                   	leaveq 
  8001b0:	c3                   	retq   

00000000008001b1 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001b1:	55                   	push   %rbp
  8001b2:	48 89 e5             	mov    %rsp,%rbp
  8001b5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001bc:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001c3:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001ca:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001d1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001d8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001df:	84 c0                	test   %al,%al
  8001e1:	74 20                	je     800203 <cprintf+0x52>
  8001e3:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8001e7:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8001eb:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8001ef:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8001f3:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8001f7:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8001fb:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8001ff:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800203:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80020a:	00 00 00 
  80020d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800214:	00 00 00 
  800217:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80021b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800222:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800229:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800230:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800237:	48 b8 49 01 80 00 00 	movabs $0x800149,%rax
  80023e:	00 00 00 
  800241:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800243:	c9                   	leaveq 
  800244:	c3                   	retq   

0000000000800245 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800245:	55                   	push   %rbp
  800246:	48 89 e5             	mov    %rsp,%rbp
  800249:	41 57                	push   %r15
  80024b:	41 56                	push   %r14
  80024d:	41 55                	push   %r13
  80024f:	41 54                	push   %r12
  800251:	53                   	push   %rbx
  800252:	48 83 ec 18          	sub    $0x18,%rsp
  800256:	49 89 fc             	mov    %rdi,%r12
  800259:	49 89 f5             	mov    %rsi,%r13
  80025c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800260:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800263:	41 89 cf             	mov    %ecx,%r15d
  800266:	49 39 d7             	cmp    %rdx,%r15
  800269:	76 45                	jbe    8002b0 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80026b:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80026f:	85 db                	test   %ebx,%ebx
  800271:	7e 0e                	jle    800281 <printnum+0x3c>
      putch(padc, putdat);
  800273:	4c 89 ee             	mov    %r13,%rsi
  800276:	44 89 f7             	mov    %r14d,%edi
  800279:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	75 f2                	jne    800273 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800281:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
  80028a:	49 f7 f7             	div    %r15
  80028d:	48 b8 6e 11 80 00 00 	movabs $0x80116e,%rax
  800294:	00 00 00 
  800297:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80029b:	4c 89 ee             	mov    %r13,%rsi
  80029e:	41 ff d4             	callq  *%r12
}
  8002a1:	48 83 c4 18          	add    $0x18,%rsp
  8002a5:	5b                   	pop    %rbx
  8002a6:	41 5c                	pop    %r12
  8002a8:	41 5d                	pop    %r13
  8002aa:	41 5e                	pop    %r14
  8002ac:	41 5f                	pop    %r15
  8002ae:	5d                   	pop    %rbp
  8002af:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b9:	49 f7 f7             	div    %r15
  8002bc:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002c0:	48 89 c2             	mov    %rax,%rdx
  8002c3:	48 b8 45 02 80 00 00 	movabs $0x800245,%rax
  8002ca:	00 00 00 
  8002cd:	ff d0                	callq  *%rax
  8002cf:	eb b0                	jmp    800281 <printnum+0x3c>

00000000008002d1 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002d1:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002d5:	48 8b 06             	mov    (%rsi),%rax
  8002d8:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002dc:	73 0a                	jae    8002e8 <sprintputch+0x17>
    *b->buf++ = ch;
  8002de:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8002e2:	48 89 16             	mov    %rdx,(%rsi)
  8002e5:	40 88 38             	mov    %dil,(%rax)
}
  8002e8:	c3                   	retq   

00000000008002e9 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8002e9:	55                   	push   %rbp
  8002ea:	48 89 e5             	mov    %rsp,%rbp
  8002ed:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002f4:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002fb:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800302:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800309:	84 c0                	test   %al,%al
  80030b:	74 20                	je     80032d <printfmt+0x44>
  80030d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800311:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800315:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800319:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80031d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800321:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800325:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800329:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80032d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800334:	00 00 00 
  800337:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80033e:	00 00 00 
  800341:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800345:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80034c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800353:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80035a:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800361:	48 b8 6f 03 80 00 00 	movabs $0x80036f,%rax
  800368:	00 00 00 
  80036b:	ff d0                	callq  *%rax
}
  80036d:	c9                   	leaveq 
  80036e:	c3                   	retq   

000000000080036f <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80036f:	55                   	push   %rbp
  800370:	48 89 e5             	mov    %rsp,%rbp
  800373:	41 57                	push   %r15
  800375:	41 56                	push   %r14
  800377:	41 55                	push   %r13
  800379:	41 54                	push   %r12
  80037b:	53                   	push   %rbx
  80037c:	48 83 ec 48          	sub    $0x48,%rsp
  800380:	49 89 fd             	mov    %rdi,%r13
  800383:	49 89 f7             	mov    %rsi,%r15
  800386:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800389:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80038d:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800391:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800395:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800399:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80039d:	41 0f b6 3e          	movzbl (%r14),%edi
  8003a1:	83 ff 25             	cmp    $0x25,%edi
  8003a4:	74 18                	je     8003be <vprintfmt+0x4f>
      if (ch == '\0')
  8003a6:	85 ff                	test   %edi,%edi
  8003a8:	0f 84 8c 06 00 00    	je     800a3a <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003ae:	4c 89 fe             	mov    %r15,%rsi
  8003b1:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003b4:	49 89 de             	mov    %rbx,%r14
  8003b7:	eb e0                	jmp    800399 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003b9:	49 89 de             	mov    %rbx,%r14
  8003bc:	eb db                	jmp    800399 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003be:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003c2:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003c6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003cd:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003d3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003d7:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003dc:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8003e2:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8003e8:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8003ed:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8003f2:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8003f6:	0f b6 13             	movzbl (%rbx),%edx
  8003f9:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8003fc:	3c 55                	cmp    $0x55,%al
  8003fe:	0f 87 8b 05 00 00    	ja     80098f <vprintfmt+0x620>
  800404:	0f b6 c0             	movzbl %al,%eax
  800407:	49 bb 20 12 80 00 00 	movabs $0x801220,%r11
  80040e:	00 00 00 
  800411:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800415:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800418:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80041c:	eb d4                	jmp    8003f2 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80041e:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800421:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800425:	eb cb                	jmp    8003f2 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800427:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80042a:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80042e:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800432:	8d 50 d0             	lea    -0x30(%rax),%edx
  800435:	83 fa 09             	cmp    $0x9,%edx
  800438:	77 7e                	ja     8004b8 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80043a:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80043e:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800442:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800447:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80044b:	8d 50 d0             	lea    -0x30(%rax),%edx
  80044e:	83 fa 09             	cmp    $0x9,%edx
  800451:	76 e7                	jbe    80043a <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800453:	4c 89 f3             	mov    %r14,%rbx
  800456:	eb 19                	jmp    800471 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800458:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80045b:	83 f8 2f             	cmp    $0x2f,%eax
  80045e:	77 2a                	ja     80048a <vprintfmt+0x11b>
  800460:	89 c2                	mov    %eax,%edx
  800462:	4c 01 d2             	add    %r10,%rdx
  800465:	83 c0 08             	add    $0x8,%eax
  800468:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80046b:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80046e:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800471:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800475:	0f 89 77 ff ff ff    	jns    8003f2 <vprintfmt+0x83>
          width = precision, precision = -1;
  80047b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80047f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800485:	e9 68 ff ff ff       	jmpq   8003f2 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80048a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80048e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800492:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800496:	eb d3                	jmp    80046b <vprintfmt+0xfc>
        if (width < 0)
  800498:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004a1:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004a4:	4c 89 f3             	mov    %r14,%rbx
  8004a7:	e9 46 ff ff ff       	jmpq   8003f2 <vprintfmt+0x83>
  8004ac:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004af:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004b3:	e9 3a ff ff ff       	jmpq   8003f2 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004b8:	4c 89 f3             	mov    %r14,%rbx
  8004bb:	eb b4                	jmp    800471 <vprintfmt+0x102>
        lflag++;
  8004bd:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004c0:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004c3:	e9 2a ff ff ff       	jmpq   8003f2 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004cb:	83 f8 2f             	cmp    $0x2f,%eax
  8004ce:	77 19                	ja     8004e9 <vprintfmt+0x17a>
  8004d0:	89 c2                	mov    %eax,%edx
  8004d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004d6:	83 c0 08             	add    $0x8,%eax
  8004d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004dc:	4c 89 fe             	mov    %r15,%rsi
  8004df:	8b 3a                	mov    (%rdx),%edi
  8004e1:	41 ff d5             	callq  *%r13
        break;
  8004e4:	e9 b0 fe ff ff       	jmpq   800399 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8004e9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004ed:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004f1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004f5:	eb e5                	jmp    8004dc <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8004f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004fa:	83 f8 2f             	cmp    $0x2f,%eax
  8004fd:	77 5b                	ja     80055a <vprintfmt+0x1eb>
  8004ff:	89 c2                	mov    %eax,%edx
  800501:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800505:	83 c0 08             	add    $0x8,%eax
  800508:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80050b:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80050d:	89 c8                	mov    %ecx,%eax
  80050f:	c1 f8 1f             	sar    $0x1f,%eax
  800512:	31 c1                	xor    %eax,%ecx
  800514:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800516:	83 f9 09             	cmp    $0x9,%ecx
  800519:	7f 4d                	jg     800568 <vprintfmt+0x1f9>
  80051b:	48 63 c1             	movslq %ecx,%rax
  80051e:	48 ba e0 14 80 00 00 	movabs $0x8014e0,%rdx
  800525:	00 00 00 
  800528:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80052c:	48 85 c0             	test   %rax,%rax
  80052f:	74 37                	je     800568 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800531:	48 89 c1             	mov    %rax,%rcx
  800534:	48 ba 8f 11 80 00 00 	movabs $0x80118f,%rdx
  80053b:	00 00 00 
  80053e:	4c 89 fe             	mov    %r15,%rsi
  800541:	4c 89 ef             	mov    %r13,%rdi
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	48 bb e9 02 80 00 00 	movabs $0x8002e9,%rbx
  800550:	00 00 00 
  800553:	ff d3                	callq  *%rbx
  800555:	e9 3f fe ff ff       	jmpq   800399 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80055a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80055e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800562:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800566:	eb a3                	jmp    80050b <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800568:	48 ba 86 11 80 00 00 	movabs $0x801186,%rdx
  80056f:	00 00 00 
  800572:	4c 89 fe             	mov    %r15,%rsi
  800575:	4c 89 ef             	mov    %r13,%rdi
  800578:	b8 00 00 00 00       	mov    $0x0,%eax
  80057d:	48 bb e9 02 80 00 00 	movabs $0x8002e9,%rbx
  800584:	00 00 00 
  800587:	ff d3                	callq  *%rbx
  800589:	e9 0b fe ff ff       	jmpq   800399 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80058e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800591:	83 f8 2f             	cmp    $0x2f,%eax
  800594:	77 4b                	ja     8005e1 <vprintfmt+0x272>
  800596:	89 c2                	mov    %eax,%edx
  800598:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80059c:	83 c0 08             	add    $0x8,%eax
  80059f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005a2:	48 8b 02             	mov    (%rdx),%rax
  8005a5:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005a9:	48 85 c0             	test   %rax,%rax
  8005ac:	0f 84 05 04 00 00    	je     8009b7 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005b2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005b6:	7e 06                	jle    8005be <vprintfmt+0x24f>
  8005b8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005bc:	75 31                	jne    8005ef <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005c2:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005c6:	0f b6 00             	movzbl (%rax),%eax
  8005c9:	0f be f8             	movsbl %al,%edi
  8005cc:	85 ff                	test   %edi,%edi
  8005ce:	0f 84 c3 00 00 00    	je     800697 <vprintfmt+0x328>
  8005d4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005d8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005dc:	e9 85 00 00 00       	jmpq   800666 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005ed:	eb b3                	jmp    8005a2 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	49 63 f4             	movslq %r12d,%rsi
  8005f2:	48 89 c7             	mov    %rax,%rdi
  8005f5:	48 b8 46 0b 80 00 00 	movabs $0x800b46,%rax
  8005fc:	00 00 00 
  8005ff:	ff d0                	callq  *%rax
  800601:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800604:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800607:	85 f6                	test   %esi,%esi
  800609:	7e 22                	jle    80062d <vprintfmt+0x2be>
            putch(padc, putdat);
  80060b:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80060f:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800613:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800617:	4c 89 fe             	mov    %r15,%rsi
  80061a:	89 df                	mov    %ebx,%edi
  80061c:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	41 83 ec 01          	sub    $0x1,%r12d
  800623:	75 f2                	jne    800617 <vprintfmt+0x2a8>
  800625:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800629:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800631:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800635:	0f b6 00             	movzbl (%rax),%eax
  800638:	0f be f8             	movsbl %al,%edi
  80063b:	85 ff                	test   %edi,%edi
  80063d:	0f 84 56 fd ff ff    	je     800399 <vprintfmt+0x2a>
  800643:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800647:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80064b:	eb 19                	jmp    800666 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80064d:	4c 89 fe             	mov    %r15,%rsi
  800650:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800653:	41 83 ee 01          	sub    $0x1,%r14d
  800657:	48 83 c3 01          	add    $0x1,%rbx
  80065b:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80065f:	0f be f8             	movsbl %al,%edi
  800662:	85 ff                	test   %edi,%edi
  800664:	74 29                	je     80068f <vprintfmt+0x320>
  800666:	45 85 e4             	test   %r12d,%r12d
  800669:	78 06                	js     800671 <vprintfmt+0x302>
  80066b:	41 83 ec 01          	sub    $0x1,%r12d
  80066f:	78 48                	js     8006b9 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800671:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800675:	74 d6                	je     80064d <vprintfmt+0x2de>
  800677:	0f be c0             	movsbl %al,%eax
  80067a:	83 e8 20             	sub    $0x20,%eax
  80067d:	83 f8 5e             	cmp    $0x5e,%eax
  800680:	76 cb                	jbe    80064d <vprintfmt+0x2de>
            putch('?', putdat);
  800682:	4c 89 fe             	mov    %r15,%rsi
  800685:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80068a:	41 ff d5             	callq  *%r13
  80068d:	eb c4                	jmp    800653 <vprintfmt+0x2e4>
  80068f:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800693:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800697:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80069a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80069e:	0f 8e f5 fc ff ff    	jle    800399 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006a4:	4c 89 fe             	mov    %r15,%rsi
  8006a7:	bf 20 00 00 00       	mov    $0x20,%edi
  8006ac:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006af:	83 eb 01             	sub    $0x1,%ebx
  8006b2:	75 f0                	jne    8006a4 <vprintfmt+0x335>
  8006b4:	e9 e0 fc ff ff       	jmpq   800399 <vprintfmt+0x2a>
  8006b9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006bd:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006c1:	eb d4                	jmp    800697 <vprintfmt+0x328>
  if (lflag >= 2)
  8006c3:	83 f9 01             	cmp    $0x1,%ecx
  8006c6:	7f 1d                	jg     8006e5 <vprintfmt+0x376>
  else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	74 5e                	je     80072a <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006cc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006cf:	83 f8 2f             	cmp    $0x2f,%eax
  8006d2:	77 48                	ja     80071c <vprintfmt+0x3ad>
  8006d4:	89 c2                	mov    %eax,%edx
  8006d6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006da:	83 c0 08             	add    $0x8,%eax
  8006dd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006e0:	48 8b 1a             	mov    (%rdx),%rbx
  8006e3:	eb 17                	jmp    8006fc <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8006e5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006e8:	83 f8 2f             	cmp    $0x2f,%eax
  8006eb:	77 21                	ja     80070e <vprintfmt+0x39f>
  8006ed:	89 c2                	mov    %eax,%edx
  8006ef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006f3:	83 c0 08             	add    $0x8,%eax
  8006f6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006f9:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8006fc:	48 85 db             	test   %rbx,%rbx
  8006ff:	78 50                	js     800751 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800701:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800704:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800709:	e9 b4 01 00 00       	jmpq   8008c2 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80070e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800712:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800716:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80071a:	eb dd                	jmp    8006f9 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80071c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800720:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800724:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800728:	eb b6                	jmp    8006e0 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80072a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80072d:	83 f8 2f             	cmp    $0x2f,%eax
  800730:	77 11                	ja     800743 <vprintfmt+0x3d4>
  800732:	89 c2                	mov    %eax,%edx
  800734:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800738:	83 c0 08             	add    $0x8,%eax
  80073b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80073e:	48 63 1a             	movslq (%rdx),%rbx
  800741:	eb b9                	jmp    8006fc <vprintfmt+0x38d>
  800743:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800747:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80074b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074f:	eb ed                	jmp    80073e <vprintfmt+0x3cf>
          putch('-', putdat);
  800751:	4c 89 fe             	mov    %r15,%rsi
  800754:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800759:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80075c:	48 89 da             	mov    %rbx,%rdx
  80075f:	48 f7 da             	neg    %rdx
        base = 10;
  800762:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800767:	e9 56 01 00 00       	jmpq   8008c2 <vprintfmt+0x553>
  if (lflag >= 2)
  80076c:	83 f9 01             	cmp    $0x1,%ecx
  80076f:	7f 25                	jg     800796 <vprintfmt+0x427>
  else if (lflag)
  800771:	85 c9                	test   %ecx,%ecx
  800773:	74 5e                	je     8007d3 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800775:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800778:	83 f8 2f             	cmp    $0x2f,%eax
  80077b:	77 48                	ja     8007c5 <vprintfmt+0x456>
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800783:	83 c0 08             	add    $0x8,%eax
  800786:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800789:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80078c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800791:	e9 2c 01 00 00       	jmpq   8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800796:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800799:	83 f8 2f             	cmp    $0x2f,%eax
  80079c:	77 19                	ja     8007b7 <vprintfmt+0x448>
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a4:	83 c0 08             	add    $0x8,%eax
  8007a7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007aa:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b2:	e9 0b 01 00 00       	jmpq   8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007b7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007bb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007bf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007c3:	eb e5                	jmp    8007aa <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007c5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007c9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007cd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007d1:	eb b6                	jmp    800789 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007d3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007d6:	83 f8 2f             	cmp    $0x2f,%eax
  8007d9:	77 18                	ja     8007f3 <vprintfmt+0x484>
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007e1:	83 c0 08             	add    $0x8,%eax
  8007e4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007e7:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8007e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ee:	e9 cf 00 00 00       	jmpq   8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8007f3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007f7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007fb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007ff:	eb e6                	jmp    8007e7 <vprintfmt+0x478>
  if (lflag >= 2)
  800801:	83 f9 01             	cmp    $0x1,%ecx
  800804:	7f 25                	jg     80082b <vprintfmt+0x4bc>
  else if (lflag)
  800806:	85 c9                	test   %ecx,%ecx
  800808:	74 5b                	je     800865 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80080a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80080d:	83 f8 2f             	cmp    $0x2f,%eax
  800810:	77 45                	ja     800857 <vprintfmt+0x4e8>
  800812:	89 c2                	mov    %eax,%edx
  800814:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800818:	83 c0 08             	add    $0x8,%eax
  80081b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80081e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800821:	b9 08 00 00 00       	mov    $0x8,%ecx
  800826:	e9 97 00 00 00       	jmpq   8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80082b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80082e:	83 f8 2f             	cmp    $0x2f,%eax
  800831:	77 16                	ja     800849 <vprintfmt+0x4da>
  800833:	89 c2                	mov    %eax,%edx
  800835:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800839:	83 c0 08             	add    $0x8,%eax
  80083c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80083f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800842:	b9 08 00 00 00       	mov    $0x8,%ecx
  800847:	eb 79                	jmp    8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800849:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80084d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800851:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800855:	eb e8                	jmp    80083f <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800857:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80085b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80085f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800863:	eb b9                	jmp    80081e <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800865:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800868:	83 f8 2f             	cmp    $0x2f,%eax
  80086b:	77 15                	ja     800882 <vprintfmt+0x513>
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800873:	83 c0 08             	add    $0x8,%eax
  800876:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800879:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80087b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800880:	eb 40                	jmp    8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800882:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800886:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80088a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80088e:	eb e9                	jmp    800879 <vprintfmt+0x50a>
        putch('0', putdat);
  800890:	4c 89 fe             	mov    %r15,%rsi
  800893:	bf 30 00 00 00       	mov    $0x30,%edi
  800898:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  80089b:	4c 89 fe             	mov    %r15,%rsi
  80089e:	bf 78 00 00 00       	mov    $0x78,%edi
  8008a3:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008a6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008a9:	83 f8 2f             	cmp    $0x2f,%eax
  8008ac:	77 34                	ja     8008e2 <vprintfmt+0x573>
  8008ae:	89 c2                	mov    %eax,%edx
  8008b0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b4:	83 c0 08             	add    $0x8,%eax
  8008b7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ba:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008bd:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008c2:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008c7:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008cb:	4c 89 fe             	mov    %r15,%rsi
  8008ce:	4c 89 ef             	mov    %r13,%rdi
  8008d1:	48 b8 45 02 80 00 00 	movabs $0x800245,%rax
  8008d8:	00 00 00 
  8008db:	ff d0                	callq  *%rax
        break;
  8008dd:	e9 b7 fa ff ff       	jmpq   800399 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008e2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ea:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ee:	eb ca                	jmp    8008ba <vprintfmt+0x54b>
  if (lflag >= 2)
  8008f0:	83 f9 01             	cmp    $0x1,%ecx
  8008f3:	7f 22                	jg     800917 <vprintfmt+0x5a8>
  else if (lflag)
  8008f5:	85 c9                	test   %ecx,%ecx
  8008f7:	74 58                	je     800951 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8008f9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008fc:	83 f8 2f             	cmp    $0x2f,%eax
  8008ff:	77 42                	ja     800943 <vprintfmt+0x5d4>
  800901:	89 c2                	mov    %eax,%edx
  800903:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800907:	83 c0 08             	add    $0x8,%eax
  80090a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80090d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800910:	b9 10 00 00 00       	mov    $0x10,%ecx
  800915:	eb ab                	jmp    8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800917:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091a:	83 f8 2f             	cmp    $0x2f,%eax
  80091d:	77 16                	ja     800935 <vprintfmt+0x5c6>
  80091f:	89 c2                	mov    %eax,%edx
  800921:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800925:	83 c0 08             	add    $0x8,%eax
  800928:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80092e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800933:	eb 8d                	jmp    8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800935:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800939:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800941:	eb e8                	jmp    80092b <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800943:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800947:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094f:	eb bc                	jmp    80090d <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800951:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800954:	83 f8 2f             	cmp    $0x2f,%eax
  800957:	77 18                	ja     800971 <vprintfmt+0x602>
  800959:	89 c2                	mov    %eax,%edx
  80095b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095f:	83 c0 08             	add    $0x8,%eax
  800962:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800965:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800967:	b9 10 00 00 00       	mov    $0x10,%ecx
  80096c:	e9 51 ff ff ff       	jmpq   8008c2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800971:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800975:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800979:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097d:	eb e6                	jmp    800965 <vprintfmt+0x5f6>
        putch(ch, putdat);
  80097f:	4c 89 fe             	mov    %r15,%rsi
  800982:	bf 25 00 00 00       	mov    $0x25,%edi
  800987:	41 ff d5             	callq  *%r13
        break;
  80098a:	e9 0a fa ff ff       	jmpq   800399 <vprintfmt+0x2a>
        putch('%', putdat);
  80098f:	4c 89 fe             	mov    %r15,%rsi
  800992:	bf 25 00 00 00       	mov    $0x25,%edi
  800997:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  80099a:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  80099e:	0f 84 15 fa ff ff    	je     8003b9 <vprintfmt+0x4a>
  8009a4:	49 89 de             	mov    %rbx,%r14
  8009a7:	49 83 ee 01          	sub    $0x1,%r14
  8009ab:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009b0:	75 f5                	jne    8009a7 <vprintfmt+0x638>
  8009b2:	e9 e2 f9 ff ff       	jmpq   800399 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009b7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009bb:	74 06                	je     8009c3 <vprintfmt+0x654>
  8009bd:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009c1:	7f 21                	jg     8009e4 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c3:	bf 28 00 00 00       	mov    $0x28,%edi
  8009c8:	48 bb 80 11 80 00 00 	movabs $0x801180,%rbx
  8009cf:	00 00 00 
  8009d2:	b8 28 00 00 00       	mov    $0x28,%eax
  8009d7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009db:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009df:	e9 82 fc ff ff       	jmpq   800666 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009e4:	49 63 f4             	movslq %r12d,%rsi
  8009e7:	48 bf 7f 11 80 00 00 	movabs $0x80117f,%rdi
  8009ee:	00 00 00 
  8009f1:	48 b8 46 0b 80 00 00 	movabs $0x800b46,%rax
  8009f8:	00 00 00 
  8009fb:	ff d0                	callq  *%rax
  8009fd:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a00:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a03:	48 be 7f 11 80 00 00 	movabs $0x80117f,%rsi
  800a0a:	00 00 00 
  800a0d:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a11:	85 c0                	test   %eax,%eax
  800a13:	0f 8f f2 fb ff ff    	jg     80060b <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a19:	48 bb 80 11 80 00 00 	movabs $0x801180,%rbx
  800a20:	00 00 00 
  800a23:	b8 28 00 00 00       	mov    $0x28,%eax
  800a28:	bf 28 00 00 00       	mov    $0x28,%edi
  800a2d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a31:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a35:	e9 2c fc ff ff       	jmpq   800666 <vprintfmt+0x2f7>
}
  800a3a:	48 83 c4 48          	add    $0x48,%rsp
  800a3e:	5b                   	pop    %rbx
  800a3f:	41 5c                	pop    %r12
  800a41:	41 5d                	pop    %r13
  800a43:	41 5e                	pop    %r14
  800a45:	41 5f                	pop    %r15
  800a47:	5d                   	pop    %rbp
  800a48:	c3                   	retq   

0000000000800a49 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a49:	55                   	push   %rbp
  800a4a:	48 89 e5             	mov    %rsp,%rbp
  800a4d:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a51:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a55:	48 63 c6             	movslq %esi,%rax
  800a58:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a5d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a61:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a68:	48 85 ff             	test   %rdi,%rdi
  800a6b:	74 2a                	je     800a97 <vsnprintf+0x4e>
  800a6d:	85 f6                	test   %esi,%esi
  800a6f:	7e 26                	jle    800a97 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a71:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a75:	48 bf d1 02 80 00 00 	movabs $0x8002d1,%rdi
  800a7c:	00 00 00 
  800a7f:	48 b8 6f 03 80 00 00 	movabs $0x80036f,%rax
  800a86:	00 00 00 
  800a89:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800a8b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800a8f:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800a92:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800a95:	c9                   	leaveq 
  800a96:	c3                   	retq   
    return -E_INVAL;
  800a97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a9c:	eb f7                	jmp    800a95 <vsnprintf+0x4c>

0000000000800a9e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800a9e:	55                   	push   %rbp
  800a9f:	48 89 e5             	mov    %rsp,%rbp
  800aa2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800aa9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ab0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ab7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800abe:	84 c0                	test   %al,%al
  800ac0:	74 20                	je     800ae2 <snprintf+0x44>
  800ac2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ac6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800aca:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800ace:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ad2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ad6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ada:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ade:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ae2:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ae9:	00 00 00 
  800aec:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800af3:	00 00 00 
  800af6:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800afa:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b01:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b08:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b0f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b16:	48 b8 49 0a 80 00 00 	movabs $0x800a49,%rax
  800b1d:	00 00 00 
  800b20:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b22:	c9                   	leaveq 
  800b23:	c3                   	retq   

0000000000800b24 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b24:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b27:	74 17                	je     800b40 <strlen+0x1c>
  800b29:	48 89 fa             	mov    %rdi,%rdx
  800b2c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b31:	29 f9                	sub    %edi,%ecx
    n++;
  800b33:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b36:	48 83 c2 01          	add    $0x1,%rdx
  800b3a:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b3d:	75 f4                	jne    800b33 <strlen+0xf>
  800b3f:	c3                   	retq   
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b45:	c3                   	retq   

0000000000800b46 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b46:	48 85 f6             	test   %rsi,%rsi
  800b49:	74 24                	je     800b6f <strnlen+0x29>
  800b4b:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b4e:	74 25                	je     800b75 <strnlen+0x2f>
  800b50:	48 01 fe             	add    %rdi,%rsi
  800b53:	48 89 fa             	mov    %rdi,%rdx
  800b56:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b5b:	29 f9                	sub    %edi,%ecx
    n++;
  800b5d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b60:	48 83 c2 01          	add    $0x1,%rdx
  800b64:	48 39 f2             	cmp    %rsi,%rdx
  800b67:	74 11                	je     800b7a <strnlen+0x34>
  800b69:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b6c:	75 ef                	jne    800b5d <strnlen+0x17>
  800b6e:	c3                   	retq   
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b74:	c3                   	retq   
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b7a:	c3                   	retq   

0000000000800b7b <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b7b:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800b87:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800b8a:	48 83 c2 01          	add    $0x1,%rdx
  800b8e:	84 c9                	test   %cl,%cl
  800b90:	75 f1                	jne    800b83 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800b92:	c3                   	retq   

0000000000800b93 <strcat>:

char *
strcat(char *dst, const char *src) {
  800b93:	55                   	push   %rbp
  800b94:	48 89 e5             	mov    %rsp,%rbp
  800b97:	41 54                	push   %r12
  800b99:	53                   	push   %rbx
  800b9a:	48 89 fb             	mov    %rdi,%rbx
  800b9d:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800ba0:	48 b8 24 0b 80 00 00 	movabs $0x800b24,%rax
  800ba7:	00 00 00 
  800baa:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bac:	48 63 f8             	movslq %eax,%rdi
  800baf:	48 01 df             	add    %rbx,%rdi
  800bb2:	4c 89 e6             	mov    %r12,%rsi
  800bb5:	48 b8 7b 0b 80 00 00 	movabs $0x800b7b,%rax
  800bbc:	00 00 00 
  800bbf:	ff d0                	callq  *%rax
  return dst;
}
  800bc1:	48 89 d8             	mov    %rbx,%rax
  800bc4:	5b                   	pop    %rbx
  800bc5:	41 5c                	pop    %r12
  800bc7:	5d                   	pop    %rbp
  800bc8:	c3                   	retq   

0000000000800bc9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc9:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bcc:	48 85 d2             	test   %rdx,%rdx
  800bcf:	74 1f                	je     800bf0 <strncpy+0x27>
  800bd1:	48 01 fa             	add    %rdi,%rdx
  800bd4:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bd7:	48 83 c1 01          	add    $0x1,%rcx
  800bdb:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bdf:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800be3:	41 80 f8 01          	cmp    $0x1,%r8b
  800be7:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800beb:	48 39 ca             	cmp    %rcx,%rdx
  800bee:	75 e7                	jne    800bd7 <strncpy+0xe>
  }
  return ret;
}
  800bf0:	c3                   	retq   

0000000000800bf1 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800bf1:	48 89 f8             	mov    %rdi,%rax
  800bf4:	48 85 d2             	test   %rdx,%rdx
  800bf7:	74 36                	je     800c2f <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800bf9:	48 83 fa 01          	cmp    $0x1,%rdx
  800bfd:	74 2d                	je     800c2c <strlcpy+0x3b>
  800bff:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c03:	45 84 c0             	test   %r8b,%r8b
  800c06:	74 24                	je     800c2c <strlcpy+0x3b>
  800c08:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c0c:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c11:	48 83 c0 01          	add    $0x1,%rax
  800c15:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c19:	48 39 d1             	cmp    %rdx,%rcx
  800c1c:	74 0e                	je     800c2c <strlcpy+0x3b>
  800c1e:	48 83 c1 01          	add    $0x1,%rcx
  800c22:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c27:	45 84 c0             	test   %r8b,%r8b
  800c2a:	75 e5                	jne    800c11 <strlcpy+0x20>
    *dst = '\0';
  800c2c:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c2f:	48 29 f8             	sub    %rdi,%rax
}
  800c32:	c3                   	retq   

0000000000800c33 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c33:	0f b6 07             	movzbl (%rdi),%eax
  800c36:	84 c0                	test   %al,%al
  800c38:	74 17                	je     800c51 <strcmp+0x1e>
  800c3a:	3a 06                	cmp    (%rsi),%al
  800c3c:	75 13                	jne    800c51 <strcmp+0x1e>
    p++, q++;
  800c3e:	48 83 c7 01          	add    $0x1,%rdi
  800c42:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c46:	0f b6 07             	movzbl (%rdi),%eax
  800c49:	84 c0                	test   %al,%al
  800c4b:	74 04                	je     800c51 <strcmp+0x1e>
  800c4d:	3a 06                	cmp    (%rsi),%al
  800c4f:	74 ed                	je     800c3e <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c51:	0f b6 c0             	movzbl %al,%eax
  800c54:	0f b6 16             	movzbl (%rsi),%edx
  800c57:	29 d0                	sub    %edx,%eax
}
  800c59:	c3                   	retq   

0000000000800c5a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c5a:	48 85 d2             	test   %rdx,%rdx
  800c5d:	74 2f                	je     800c8e <strncmp+0x34>
  800c5f:	0f b6 07             	movzbl (%rdi),%eax
  800c62:	84 c0                	test   %al,%al
  800c64:	74 1f                	je     800c85 <strncmp+0x2b>
  800c66:	3a 06                	cmp    (%rsi),%al
  800c68:	75 1b                	jne    800c85 <strncmp+0x2b>
  800c6a:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c6d:	48 83 c7 01          	add    $0x1,%rdi
  800c71:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c75:	48 39 d7             	cmp    %rdx,%rdi
  800c78:	74 1a                	je     800c94 <strncmp+0x3a>
  800c7a:	0f b6 07             	movzbl (%rdi),%eax
  800c7d:	84 c0                	test   %al,%al
  800c7f:	74 04                	je     800c85 <strncmp+0x2b>
  800c81:	3a 06                	cmp    (%rsi),%al
  800c83:	74 e8                	je     800c6d <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800c85:	0f b6 07             	movzbl (%rdi),%eax
  800c88:	0f b6 16             	movzbl (%rsi),%edx
  800c8b:	29 d0                	sub    %edx,%eax
}
  800c8d:	c3                   	retq   
    return 0;
  800c8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c93:	c3                   	retq   
  800c94:	b8 00 00 00 00       	mov    $0x0,%eax
  800c99:	c3                   	retq   

0000000000800c9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800c9a:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800c9c:	0f b6 07             	movzbl (%rdi),%eax
  800c9f:	84 c0                	test   %al,%al
  800ca1:	74 1e                	je     800cc1 <strchr+0x27>
    if (*s == c)
  800ca3:	40 38 c6             	cmp    %al,%sil
  800ca6:	74 1f                	je     800cc7 <strchr+0x2d>
  for (; *s; s++)
  800ca8:	48 83 c7 01          	add    $0x1,%rdi
  800cac:	0f b6 07             	movzbl (%rdi),%eax
  800caf:	84 c0                	test   %al,%al
  800cb1:	74 08                	je     800cbb <strchr+0x21>
    if (*s == c)
  800cb3:	38 d0                	cmp    %dl,%al
  800cb5:	75 f1                	jne    800ca8 <strchr+0xe>
  for (; *s; s++)
  800cb7:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cba:	c3                   	retq   
  return 0;
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc0:	c3                   	retq   
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	c3                   	retq   
    if (*s == c)
  800cc7:	48 89 f8             	mov    %rdi,%rax
  800cca:	c3                   	retq   

0000000000800ccb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ccb:	48 89 f8             	mov    %rdi,%rax
  800cce:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cd0:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cd3:	40 38 f2             	cmp    %sil,%dl
  800cd6:	74 13                	je     800ceb <strfind+0x20>
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	74 0f                	je     800ceb <strfind+0x20>
  for (; *s; s++)
  800cdc:	48 83 c0 01          	add    $0x1,%rax
  800ce0:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800ce3:	38 ca                	cmp    %cl,%dl
  800ce5:	74 04                	je     800ceb <strfind+0x20>
  800ce7:	84 d2                	test   %dl,%dl
  800ce9:	75 f1                	jne    800cdc <strfind+0x11>
      break;
  return (char *)s;
}
  800ceb:	c3                   	retq   

0000000000800cec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800cec:	48 85 d2             	test   %rdx,%rdx
  800cef:	74 3a                	je     800d2b <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800cf1:	48 89 f8             	mov    %rdi,%rax
  800cf4:	48 09 d0             	or     %rdx,%rax
  800cf7:	a8 03                	test   $0x3,%al
  800cf9:	75 28                	jne    800d23 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800cfb:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800cff:	89 f0                	mov    %esi,%eax
  800d01:	c1 e0 08             	shl    $0x8,%eax
  800d04:	89 f1                	mov    %esi,%ecx
  800d06:	c1 e1 18             	shl    $0x18,%ecx
  800d09:	41 89 f0             	mov    %esi,%r8d
  800d0c:	41 c1 e0 10          	shl    $0x10,%r8d
  800d10:	44 09 c1             	or     %r8d,%ecx
  800d13:	09 ce                	or     %ecx,%esi
  800d15:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d17:	48 c1 ea 02          	shr    $0x2,%rdx
  800d1b:	48 89 d1             	mov    %rdx,%rcx
  800d1e:	fc                   	cld    
  800d1f:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d21:	eb 08                	jmp    800d2b <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d23:	89 f0                	mov    %esi,%eax
  800d25:	48 89 d1             	mov    %rdx,%rcx
  800d28:	fc                   	cld    
  800d29:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d2b:	48 89 f8             	mov    %rdi,%rax
  800d2e:	c3                   	retq   

0000000000800d2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d2f:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d32:	48 39 fe             	cmp    %rdi,%rsi
  800d35:	73 40                	jae    800d77 <memmove+0x48>
  800d37:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d3b:	48 39 f9             	cmp    %rdi,%rcx
  800d3e:	76 37                	jbe    800d77 <memmove+0x48>
    s += n;
    d += n;
  800d40:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d44:	48 89 fe             	mov    %rdi,%rsi
  800d47:	48 09 d6             	or     %rdx,%rsi
  800d4a:	48 09 ce             	or     %rcx,%rsi
  800d4d:	40 f6 c6 03          	test   $0x3,%sil
  800d51:	75 14                	jne    800d67 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d53:	48 83 ef 04          	sub    $0x4,%rdi
  800d57:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d5b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d5f:	48 89 d1             	mov    %rdx,%rcx
  800d62:	fd                   	std    
  800d63:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d65:	eb 0e                	jmp    800d75 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d67:	48 83 ef 01          	sub    $0x1,%rdi
  800d6b:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d6f:	48 89 d1             	mov    %rdx,%rcx
  800d72:	fd                   	std    
  800d73:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d75:	fc                   	cld    
  800d76:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d77:	48 89 c1             	mov    %rax,%rcx
  800d7a:	48 09 d1             	or     %rdx,%rcx
  800d7d:	48 09 f1             	or     %rsi,%rcx
  800d80:	f6 c1 03             	test   $0x3,%cl
  800d83:	75 0e                	jne    800d93 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800d85:	48 c1 ea 02          	shr    $0x2,%rdx
  800d89:	48 89 d1             	mov    %rdx,%rcx
  800d8c:	48 89 c7             	mov    %rax,%rdi
  800d8f:	fc                   	cld    
  800d90:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d92:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800d93:	48 89 c7             	mov    %rax,%rdi
  800d96:	48 89 d1             	mov    %rdx,%rcx
  800d99:	fc                   	cld    
  800d9a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800d9c:	c3                   	retq   

0000000000800d9d <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800d9d:	55                   	push   %rbp
  800d9e:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800da1:	48 b8 2f 0d 80 00 00 	movabs $0x800d2f,%rax
  800da8:	00 00 00 
  800dab:	ff d0                	callq  *%rax
}
  800dad:	5d                   	pop    %rbp
  800dae:	c3                   	retq   

0000000000800daf <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800daf:	55                   	push   %rbp
  800db0:	48 89 e5             	mov    %rsp,%rbp
  800db3:	41 57                	push   %r15
  800db5:	41 56                	push   %r14
  800db7:	41 55                	push   %r13
  800db9:	41 54                	push   %r12
  800dbb:	53                   	push   %rbx
  800dbc:	48 83 ec 08          	sub    $0x8,%rsp
  800dc0:	49 89 fe             	mov    %rdi,%r14
  800dc3:	49 89 f7             	mov    %rsi,%r15
  800dc6:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800dc9:	48 89 f7             	mov    %rsi,%rdi
  800dcc:	48 b8 24 0b 80 00 00 	movabs $0x800b24,%rax
  800dd3:	00 00 00 
  800dd6:	ff d0                	callq  *%rax
  800dd8:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800ddb:	4c 89 ee             	mov    %r13,%rsi
  800dde:	4c 89 f7             	mov    %r14,%rdi
  800de1:	48 b8 46 0b 80 00 00 	movabs $0x800b46,%rax
  800de8:	00 00 00 
  800deb:	ff d0                	callq  *%rax
  800ded:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800df0:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800df4:	4d 39 e5             	cmp    %r12,%r13
  800df7:	74 26                	je     800e1f <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800df9:	4c 89 e8             	mov    %r13,%rax
  800dfc:	4c 29 e0             	sub    %r12,%rax
  800dff:	48 39 d8             	cmp    %rbx,%rax
  800e02:	76 2a                	jbe    800e2e <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e04:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e08:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e0c:	4c 89 fe             	mov    %r15,%rsi
  800e0f:	48 b8 9d 0d 80 00 00 	movabs $0x800d9d,%rax
  800e16:	00 00 00 
  800e19:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e1b:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e1f:	48 83 c4 08          	add    $0x8,%rsp
  800e23:	5b                   	pop    %rbx
  800e24:	41 5c                	pop    %r12
  800e26:	41 5d                	pop    %r13
  800e28:	41 5e                	pop    %r14
  800e2a:	41 5f                	pop    %r15
  800e2c:	5d                   	pop    %rbp
  800e2d:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e2e:	49 83 ed 01          	sub    $0x1,%r13
  800e32:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e36:	4c 89 ea             	mov    %r13,%rdx
  800e39:	4c 89 fe             	mov    %r15,%rsi
  800e3c:	48 b8 9d 0d 80 00 00 	movabs $0x800d9d,%rax
  800e43:	00 00 00 
  800e46:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e48:	4d 01 ee             	add    %r13,%r14
  800e4b:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e50:	eb c9                	jmp    800e1b <strlcat+0x6c>

0000000000800e52 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e52:	48 85 d2             	test   %rdx,%rdx
  800e55:	74 3a                	je     800e91 <memcmp+0x3f>
    if (*s1 != *s2)
  800e57:	0f b6 0f             	movzbl (%rdi),%ecx
  800e5a:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e5e:	44 38 c1             	cmp    %r8b,%cl
  800e61:	75 1d                	jne    800e80 <memcmp+0x2e>
  800e63:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e68:	48 39 d0             	cmp    %rdx,%rax
  800e6b:	74 1e                	je     800e8b <memcmp+0x39>
    if (*s1 != *s2)
  800e6d:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e71:	48 83 c0 01          	add    $0x1,%rax
  800e75:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e7b:	44 38 c1             	cmp    %r8b,%cl
  800e7e:	74 e8                	je     800e68 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e80:	0f b6 c1             	movzbl %cl,%eax
  800e83:	45 0f b6 c0          	movzbl %r8b,%r8d
  800e87:	44 29 c0             	sub    %r8d,%eax
  800e8a:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	c3                   	retq   
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e96:	c3                   	retq   

0000000000800e97 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800e97:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800e9b:	48 39 c7             	cmp    %rax,%rdi
  800e9e:	73 19                	jae    800eb9 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ea0:	89 f2                	mov    %esi,%edx
  800ea2:	40 38 37             	cmp    %sil,(%rdi)
  800ea5:	74 16                	je     800ebd <memfind+0x26>
  for (; s < ends; s++)
  800ea7:	48 83 c7 01          	add    $0x1,%rdi
  800eab:	48 39 f8             	cmp    %rdi,%rax
  800eae:	74 08                	je     800eb8 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800eb0:	38 17                	cmp    %dl,(%rdi)
  800eb2:	75 f3                	jne    800ea7 <memfind+0x10>
  for (; s < ends; s++)
  800eb4:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800eb7:	c3                   	retq   
  800eb8:	c3                   	retq   
  for (; s < ends; s++)
  800eb9:	48 89 f8             	mov    %rdi,%rax
  800ebc:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ebd:	48 89 f8             	mov    %rdi,%rax
  800ec0:	c3                   	retq   

0000000000800ec1 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ec1:	0f b6 07             	movzbl (%rdi),%eax
  800ec4:	3c 20                	cmp    $0x20,%al
  800ec6:	74 04                	je     800ecc <strtol+0xb>
  800ec8:	3c 09                	cmp    $0x9,%al
  800eca:	75 0f                	jne    800edb <strtol+0x1a>
    s++;
  800ecc:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ed0:	0f b6 07             	movzbl (%rdi),%eax
  800ed3:	3c 20                	cmp    $0x20,%al
  800ed5:	74 f5                	je     800ecc <strtol+0xb>
  800ed7:	3c 09                	cmp    $0x9,%al
  800ed9:	74 f1                	je     800ecc <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800edb:	3c 2b                	cmp    $0x2b,%al
  800edd:	74 2b                	je     800f0a <strtol+0x49>
  int neg  = 0;
  800edf:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800ee5:	3c 2d                	cmp    $0x2d,%al
  800ee7:	74 2d                	je     800f16 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee9:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800eef:	75 0f                	jne    800f00 <strtol+0x3f>
  800ef1:	80 3f 30             	cmpb   $0x30,(%rdi)
  800ef4:	74 2c                	je     800f22 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800ef6:	85 d2                	test   %edx,%edx
  800ef8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efd:	0f 44 d0             	cmove  %eax,%edx
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f05:	4c 63 d2             	movslq %edx,%r10
  800f08:	eb 5c                	jmp    800f66 <strtol+0xa5>
    s++;
  800f0a:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f0e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f14:	eb d3                	jmp    800ee9 <strtol+0x28>
    s++, neg = 1;
  800f16:	48 83 c7 01          	add    $0x1,%rdi
  800f1a:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f20:	eb c7                	jmp    800ee9 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f22:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f26:	74 0f                	je     800f37 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f28:	85 d2                	test   %edx,%edx
  800f2a:	75 d4                	jne    800f00 <strtol+0x3f>
    s++, base = 8;
  800f2c:	48 83 c7 01          	add    $0x1,%rdi
  800f30:	ba 08 00 00 00       	mov    $0x8,%edx
  800f35:	eb c9                	jmp    800f00 <strtol+0x3f>
    s += 2, base = 16;
  800f37:	48 83 c7 02          	add    $0x2,%rdi
  800f3b:	ba 10 00 00 00       	mov    $0x10,%edx
  800f40:	eb be                	jmp    800f00 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f42:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f46:	41 80 f8 19          	cmp    $0x19,%r8b
  800f4a:	77 2f                	ja     800f7b <strtol+0xba>
      dig = *s - 'a' + 10;
  800f4c:	44 0f be c1          	movsbl %cl,%r8d
  800f50:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f54:	39 d1                	cmp    %edx,%ecx
  800f56:	7d 37                	jge    800f8f <strtol+0xce>
    s++, val = (val * base) + dig;
  800f58:	48 83 c7 01          	add    $0x1,%rdi
  800f5c:	49 0f af c2          	imul   %r10,%rax
  800f60:	48 63 c9             	movslq %ecx,%rcx
  800f63:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f66:	0f b6 0f             	movzbl (%rdi),%ecx
  800f69:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f6d:	41 80 f8 09          	cmp    $0x9,%r8b
  800f71:	77 cf                	ja     800f42 <strtol+0x81>
      dig = *s - '0';
  800f73:	0f be c9             	movsbl %cl,%ecx
  800f76:	83 e9 30             	sub    $0x30,%ecx
  800f79:	eb d9                	jmp    800f54 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f7b:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f7f:	41 80 f8 19          	cmp    $0x19,%r8b
  800f83:	77 0a                	ja     800f8f <strtol+0xce>
      dig = *s - 'A' + 10;
  800f85:	44 0f be c1          	movsbl %cl,%r8d
  800f89:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800f8d:	eb c5                	jmp    800f54 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800f8f:	48 85 f6             	test   %rsi,%rsi
  800f92:	74 03                	je     800f97 <strtol+0xd6>
    *endptr = (char *)s;
  800f94:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800f97:	48 89 c2             	mov    %rax,%rdx
  800f9a:	48 f7 da             	neg    %rdx
  800f9d:	45 85 c9             	test   %r9d,%r9d
  800fa0:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fa4:	c3                   	retq   

0000000000800fa5 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fa5:	55                   	push   %rbp
  800fa6:	48 89 e5             	mov    %rsp,%rbp
  800fa9:	53                   	push   %rbx
  800faa:	48 89 fa             	mov    %rdi,%rdx
  800fad:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb5:	48 89 c3             	mov    %rax,%rbx
  800fb8:	48 89 c7             	mov    %rax,%rdi
  800fbb:	48 89 c6             	mov    %rax,%rsi
  800fbe:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fc0:	5b                   	pop    %rbx
  800fc1:	5d                   	pop    %rbp
  800fc2:	c3                   	retq   

0000000000800fc3 <sys_cgetc>:

int
sys_cgetc(void) {
  800fc3:	55                   	push   %rbp
  800fc4:	48 89 e5             	mov    %rsp,%rbp
  800fc7:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd2:	48 89 ca             	mov    %rcx,%rdx
  800fd5:	48 89 cb             	mov    %rcx,%rbx
  800fd8:	48 89 cf             	mov    %rcx,%rdi
  800fdb:	48 89 ce             	mov    %rcx,%rsi
  800fde:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fe0:	5b                   	pop    %rbx
  800fe1:	5d                   	pop    %rbp
  800fe2:	c3                   	retq   

0000000000800fe3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800fe3:	55                   	push   %rbp
  800fe4:	48 89 e5             	mov    %rsp,%rbp
  800fe7:	53                   	push   %rbx
  800fe8:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fec:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800fef:	be 00 00 00 00       	mov    $0x0,%esi
  800ff4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff9:	48 89 f1             	mov    %rsi,%rcx
  800ffc:	48 89 f3             	mov    %rsi,%rbx
  800fff:	48 89 f7             	mov    %rsi,%rdi
  801002:	cd 30                	int    $0x30
  if (check && ret > 0)
  801004:	48 85 c0             	test   %rax,%rax
  801007:	7f 07                	jg     801010 <sys_env_destroy+0x2d>
}
  801009:	48 83 c4 08          	add    $0x8,%rsp
  80100d:	5b                   	pop    %rbx
  80100e:	5d                   	pop    %rbp
  80100f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801010:	49 89 c0             	mov    %rax,%r8
  801013:	b9 03 00 00 00       	mov    $0x3,%ecx
  801018:	48 ba 30 15 80 00 00 	movabs $0x801530,%rdx
  80101f:	00 00 00 
  801022:	be 22 00 00 00       	mov    $0x22,%esi
  801027:	48 bf 4f 15 80 00 00 	movabs $0x80154f,%rdi
  80102e:	00 00 00 
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
  801036:	49 b9 63 10 80 00 00 	movabs $0x801063,%r9
  80103d:	00 00 00 
  801040:	41 ff d1             	callq  *%r9

0000000000801043 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801043:	55                   	push   %rbp
  801044:	48 89 e5             	mov    %rsp,%rbp
  801047:	53                   	push   %rbx
  asm volatile("int %1\n"
  801048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104d:	b8 02 00 00 00       	mov    $0x2,%eax
  801052:	48 89 ca             	mov    %rcx,%rdx
  801055:	48 89 cb             	mov    %rcx,%rbx
  801058:	48 89 cf             	mov    %rcx,%rdi
  80105b:	48 89 ce             	mov    %rcx,%rsi
  80105e:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801060:	5b                   	pop    %rbx
  801061:	5d                   	pop    %rbp
  801062:	c3                   	retq   

0000000000801063 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801063:	55                   	push   %rbp
  801064:	48 89 e5             	mov    %rsp,%rbp
  801067:	41 56                	push   %r14
  801069:	41 55                	push   %r13
  80106b:	41 54                	push   %r12
  80106d:	53                   	push   %rbx
  80106e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801075:	49 89 fd             	mov    %rdi,%r13
  801078:	41 89 f6             	mov    %esi,%r14d
  80107b:	49 89 d4             	mov    %rdx,%r12
  80107e:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801085:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80108c:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801093:	84 c0                	test   %al,%al
  801095:	74 26                	je     8010bd <_panic+0x5a>
  801097:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80109e:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010a5:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010a9:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010ad:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010b1:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010b5:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010b9:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010bd:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010c4:	00 00 00 
  8010c7:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010ce:	00 00 00 
  8010d1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010d5:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010dc:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8010e3:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ea:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8010f1:	00 00 00 
  8010f4:	48 8b 18             	mov    (%rax),%rbx
  8010f7:	48 b8 43 10 80 00 00 	movabs $0x801043,%rax
  8010fe:	00 00 00 
  801101:	ff d0                	callq  *%rax
  801103:	45 89 f0             	mov    %r14d,%r8d
  801106:	4c 89 e9             	mov    %r13,%rcx
  801109:	48 89 da             	mov    %rbx,%rdx
  80110c:	89 c6                	mov    %eax,%esi
  80110e:	48 bf 60 15 80 00 00 	movabs $0x801560,%rdi
  801115:	00 00 00 
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	48 bb b1 01 80 00 00 	movabs $0x8001b1,%rbx
  801124:	00 00 00 
  801127:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801129:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801130:	4c 89 e7             	mov    %r12,%rdi
  801133:	48 b8 49 01 80 00 00 	movabs $0x800149,%rax
  80113a:	00 00 00 
  80113d:	ff d0                	callq  *%rax
  cprintf("\n");
  80113f:	48 bf 62 11 80 00 00 	movabs $0x801162,%rdi
  801146:	00 00 00 
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801150:	cc                   	int3   
  while (1)
  801151:	eb fd                	jmp    801150 <_panic+0xed>
  801153:	90                   	nop
