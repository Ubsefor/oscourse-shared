
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
  800045:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  80004c:	00 00 00 
  80004f:	b8 00 00 00 00       	mov    $0x0,%eax
  800054:	48 ba e5 01 80 00 00 	movabs $0x8001e5,%rdx
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  8000af:	48 b8 77 10 80 00 00 	movabs $0x801077,%rax
  8000b6:	00 00 00 
  8000b9:	ff d0                	callq  *%rax
  8000bb:	83 e0 1f             	and    $0x1f,%eax
  8000be:	48 89 c2             	mov    %rax,%rdx
  8000c1:	48 c1 e2 05          	shl    $0x5,%rdx
  8000c5:	48 29 c2             	sub    %rax,%rdx
  8000c8:	48 89 d0             	mov    %rdx,%rax
  8000cb:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000d2:	00 00 00 
  8000d5:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000d9:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000e0:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000e3:	45 85 ed             	test   %r13d,%r13d
  8000e6:	7e 0d                	jle    8000f5 <libmain+0x93>
    binaryname = argv[0];
  8000e8:	49 8b 06             	mov    (%r14),%rax
  8000eb:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000f2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000f5:	4c 89 f6             	mov    %r14,%rsi
  8000f8:	44 89 ef             	mov    %r13d,%edi
  8000fb:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800102:	00 00 00 
  800105:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800107:	48 b8 1c 01 80 00 00 	movabs $0x80011c,%rax
  80010e:	00 00 00 
  800111:	ff d0                	callq  *%rax
#endif
}
  800113:	5b                   	pop    %rbx
  800114:	41 5c                	pop    %r12
  800116:	41 5d                	pop    %r13
  800118:	41 5e                	pop    %r14
  80011a:	5d                   	pop    %rbp
  80011b:	c3                   	retq   

000000000080011c <exit>:

#include <inc/lib.h>

void
exit(void) {
  80011c:	55                   	push   %rbp
  80011d:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800120:	bf 00 00 00 00       	mov    $0x0,%edi
  800125:	48 b8 17 10 80 00 00 	movabs $0x801017,%rax
  80012c:	00 00 00 
  80012f:	ff d0                	callq  *%rax
}
  800131:	5d                   	pop    %rbp
  800132:	c3                   	retq   

0000000000800133 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800133:	55                   	push   %rbp
  800134:	48 89 e5             	mov    %rsp,%rbp
  800137:	53                   	push   %rbx
  800138:	48 83 ec 08          	sub    $0x8,%rsp
  80013c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80013f:	8b 06                	mov    (%rsi),%eax
  800141:	8d 50 01             	lea    0x1(%rax),%edx
  800144:	89 16                	mov    %edx,(%rsi)
  800146:	48 98                	cltq   
  800148:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80014d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800153:	74 0b                	je     800160 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800155:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800159:	48 83 c4 08          	add    $0x8,%rsp
  80015d:	5b                   	pop    %rbx
  80015e:	5d                   	pop    %rbp
  80015f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800160:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800164:	be ff 00 00 00       	mov    $0xff,%esi
  800169:	48 b8 d9 0f 80 00 00 	movabs $0x800fd9,%rax
  800170:	00 00 00 
  800173:	ff d0                	callq  *%rax
    b->idx = 0;
  800175:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80017b:	eb d8                	jmp    800155 <putch+0x22>

000000000080017d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80017d:	55                   	push   %rbp
  80017e:	48 89 e5             	mov    %rsp,%rbp
  800181:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800188:	48 89 fa             	mov    %rdi,%rdx
  80018b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80018e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800195:	00 00 00 
  b.cnt = 0;
  800198:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80019f:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8001a2:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001a9:	48 bf 33 01 80 00 00 	movabs $0x800133,%rdi
  8001b0:	00 00 00 
  8001b3:	48 b8 a3 03 80 00 00 	movabs $0x8003a3,%rax
  8001ba:	00 00 00 
  8001bd:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001bf:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001c6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001cd:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001d1:	48 b8 d9 0f 80 00 00 	movabs $0x800fd9,%rax
  8001d8:	00 00 00 
  8001db:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001dd:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001e3:	c9                   	leaveq 
  8001e4:	c3                   	retq   

00000000008001e5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001e5:	55                   	push   %rbp
  8001e6:	48 89 e5             	mov    %rsp,%rbp
  8001e9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001f0:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001f7:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001fe:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800205:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80020c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800213:	84 c0                	test   %al,%al
  800215:	74 20                	je     800237 <cprintf+0x52>
  800217:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80021b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80021f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800223:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800227:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80022b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80022f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800233:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800237:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80023e:	00 00 00 
  800241:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800248:	00 00 00 
  80024b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80024f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800256:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80025d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800264:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80026b:	48 b8 7d 01 80 00 00 	movabs $0x80017d,%rax
  800272:	00 00 00 
  800275:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800277:	c9                   	leaveq 
  800278:	c3                   	retq   

0000000000800279 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800279:	55                   	push   %rbp
  80027a:	48 89 e5             	mov    %rsp,%rbp
  80027d:	41 57                	push   %r15
  80027f:	41 56                	push   %r14
  800281:	41 55                	push   %r13
  800283:	41 54                	push   %r12
  800285:	53                   	push   %rbx
  800286:	48 83 ec 18          	sub    $0x18,%rsp
  80028a:	49 89 fc             	mov    %rdi,%r12
  80028d:	49 89 f5             	mov    %rsi,%r13
  800290:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800294:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800297:	41 89 cf             	mov    %ecx,%r15d
  80029a:	49 39 d7             	cmp    %rdx,%r15
  80029d:	76 45                	jbe    8002e4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80029f:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7e 0e                	jle    8002b5 <printnum+0x3c>
      putch(padc, putdat);
  8002a7:	4c 89 ee             	mov    %r13,%rsi
  8002aa:	44 89 f7             	mov    %r14d,%edi
  8002ad:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	75 f2                	jne    8002a7 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002b5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	49 f7 f7             	div    %r15
  8002c1:	48 b8 ae 11 80 00 00 	movabs $0x8011ae,%rax
  8002c8:	00 00 00 
  8002cb:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002cf:	4c 89 ee             	mov    %r13,%rsi
  8002d2:	41 ff d4             	callq  *%r12
}
  8002d5:	48 83 c4 18          	add    $0x18,%rsp
  8002d9:	5b                   	pop    %rbx
  8002da:	41 5c                	pop    %r12
  8002dc:	41 5d                	pop    %r13
  8002de:	41 5e                	pop    %r14
  8002e0:	41 5f                	pop    %r15
  8002e2:	5d                   	pop    %rbp
  8002e3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ed:	49 f7 f7             	div    %r15
  8002f0:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002f4:	48 89 c2             	mov    %rax,%rdx
  8002f7:	48 b8 79 02 80 00 00 	movabs $0x800279,%rax
  8002fe:	00 00 00 
  800301:	ff d0                	callq  *%rax
  800303:	eb b0                	jmp    8002b5 <printnum+0x3c>

0000000000800305 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800305:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800309:	48 8b 06             	mov    (%rsi),%rax
  80030c:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800310:	73 0a                	jae    80031c <sprintputch+0x17>
    *b->buf++ = ch;
  800312:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800316:	48 89 16             	mov    %rdx,(%rsi)
  800319:	40 88 38             	mov    %dil,(%rax)
}
  80031c:	c3                   	retq   

000000000080031d <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80031d:	55                   	push   %rbp
  80031e:	48 89 e5             	mov    %rsp,%rbp
  800321:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800328:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80032f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800336:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80033d:	84 c0                	test   %al,%al
  80033f:	74 20                	je     800361 <printfmt+0x44>
  800341:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800345:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800349:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80034d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800351:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800355:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800359:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80035d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800361:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800368:	00 00 00 
  80036b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800372:	00 00 00 
  800375:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800379:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800380:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800387:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80038e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800395:	48 b8 a3 03 80 00 00 	movabs $0x8003a3,%rax
  80039c:	00 00 00 
  80039f:	ff d0                	callq  *%rax
}
  8003a1:	c9                   	leaveq 
  8003a2:	c3                   	retq   

00000000008003a3 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8003a3:	55                   	push   %rbp
  8003a4:	48 89 e5             	mov    %rsp,%rbp
  8003a7:	41 57                	push   %r15
  8003a9:	41 56                	push   %r14
  8003ab:	41 55                	push   %r13
  8003ad:	41 54                	push   %r12
  8003af:	53                   	push   %rbx
  8003b0:	48 83 ec 48          	sub    $0x48,%rsp
  8003b4:	49 89 fd             	mov    %rdi,%r13
  8003b7:	49 89 f7             	mov    %rsi,%r15
  8003ba:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003bd:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003c1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003c5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003c9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003cd:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003d1:	41 0f b6 3e          	movzbl (%r14),%edi
  8003d5:	83 ff 25             	cmp    $0x25,%edi
  8003d8:	74 18                	je     8003f2 <vprintfmt+0x4f>
      if (ch == '\0')
  8003da:	85 ff                	test   %edi,%edi
  8003dc:	0f 84 8c 06 00 00    	je     800a6e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003e2:	4c 89 fe             	mov    %r15,%rsi
  8003e5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003e8:	49 89 de             	mov    %rbx,%r14
  8003eb:	eb e0                	jmp    8003cd <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003ed:	49 89 de             	mov    %rbx,%r14
  8003f0:	eb db                	jmp    8003cd <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003f2:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003f6:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003fa:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800401:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800407:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800410:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800416:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80041c:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800421:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800426:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80042a:	0f b6 13             	movzbl (%rbx),%edx
  80042d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800430:	3c 55                	cmp    $0x55,%al
  800432:	0f 87 8b 05 00 00    	ja     8009c3 <vprintfmt+0x620>
  800438:	0f b6 c0             	movzbl %al,%eax
  80043b:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800442:	00 00 00 
  800445:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800449:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80044c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800450:	eb d4                	jmp    800426 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800452:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800455:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800459:	eb cb                	jmp    800426 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80045b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80045e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800462:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800466:	8d 50 d0             	lea    -0x30(%rax),%edx
  800469:	83 fa 09             	cmp    $0x9,%edx
  80046c:	77 7e                	ja     8004ec <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80046e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800472:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800476:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80047b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80047f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800482:	83 fa 09             	cmp    $0x9,%edx
  800485:	76 e7                	jbe    80046e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800487:	4c 89 f3             	mov    %r14,%rbx
  80048a:	eb 19                	jmp    8004a5 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80048c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80048f:	83 f8 2f             	cmp    $0x2f,%eax
  800492:	77 2a                	ja     8004be <vprintfmt+0x11b>
  800494:	89 c2                	mov    %eax,%edx
  800496:	4c 01 d2             	add    %r10,%rdx
  800499:	83 c0 08             	add    $0x8,%eax
  80049c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80049f:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8004a2:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004a5:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004a9:	0f 89 77 ff ff ff    	jns    800426 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004af:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004b3:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004b9:	e9 68 ff ff ff       	jmpq   800426 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004be:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004c2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004c6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004ca:	eb d3                	jmp    80049f <vprintfmt+0xfc>
        if (width < 0)
  8004cc:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004d5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004d8:	4c 89 f3             	mov    %r14,%rbx
  8004db:	e9 46 ff ff ff       	jmpq   800426 <vprintfmt+0x83>
  8004e0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004e3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004e7:	e9 3a ff ff ff       	jmpq   800426 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004ec:	4c 89 f3             	mov    %r14,%rbx
  8004ef:	eb b4                	jmp    8004a5 <vprintfmt+0x102>
        lflag++;
  8004f1:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004f4:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004f7:	e9 2a ff ff ff       	jmpq   800426 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004fc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004ff:	83 f8 2f             	cmp    $0x2f,%eax
  800502:	77 19                	ja     80051d <vprintfmt+0x17a>
  800504:	89 c2                	mov    %eax,%edx
  800506:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80050a:	83 c0 08             	add    $0x8,%eax
  80050d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800510:	4c 89 fe             	mov    %r15,%rsi
  800513:	8b 3a                	mov    (%rdx),%edi
  800515:	41 ff d5             	callq  *%r13
        break;
  800518:	e9 b0 fe ff ff       	jmpq   8003cd <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80051d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800521:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800525:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800529:	eb e5                	jmp    800510 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80052b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80052e:	83 f8 2f             	cmp    $0x2f,%eax
  800531:	77 5b                	ja     80058e <vprintfmt+0x1eb>
  800533:	89 c2                	mov    %eax,%edx
  800535:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800539:	83 c0 08             	add    $0x8,%eax
  80053c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80053f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800541:	89 c8                	mov    %ecx,%eax
  800543:	c1 f8 1f             	sar    $0x1f,%eax
  800546:	31 c1                	xor    %eax,%ecx
  800548:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054a:	83 f9 09             	cmp    $0x9,%ecx
  80054d:	7f 4d                	jg     80059c <vprintfmt+0x1f9>
  80054f:	48 63 c1             	movslq %ecx,%rax
  800552:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  800559:	00 00 00 
  80055c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800560:	48 85 c0             	test   %rax,%rax
  800563:	74 37                	je     80059c <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800565:	48 89 c1             	mov    %rax,%rcx
  800568:	48 ba cf 11 80 00 00 	movabs $0x8011cf,%rdx
  80056f:	00 00 00 
  800572:	4c 89 fe             	mov    %r15,%rsi
  800575:	4c 89 ef             	mov    %r13,%rdi
  800578:	b8 00 00 00 00       	mov    $0x0,%eax
  80057d:	48 bb 1d 03 80 00 00 	movabs $0x80031d,%rbx
  800584:	00 00 00 
  800587:	ff d3                	callq  *%rbx
  800589:	e9 3f fe ff ff       	jmpq   8003cd <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80058e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800592:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800596:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80059a:	eb a3                	jmp    80053f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80059c:	48 ba c6 11 80 00 00 	movabs $0x8011c6,%rdx
  8005a3:	00 00 00 
  8005a6:	4c 89 fe             	mov    %r15,%rsi
  8005a9:	4c 89 ef             	mov    %r13,%rdi
  8005ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b1:	48 bb 1d 03 80 00 00 	movabs $0x80031d,%rbx
  8005b8:	00 00 00 
  8005bb:	ff d3                	callq  *%rbx
  8005bd:	e9 0b fe ff ff       	jmpq   8003cd <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005c2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005c5:	83 f8 2f             	cmp    $0x2f,%eax
  8005c8:	77 4b                	ja     800615 <vprintfmt+0x272>
  8005ca:	89 c2                	mov    %eax,%edx
  8005cc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005d0:	83 c0 08             	add    $0x8,%eax
  8005d3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d6:	48 8b 02             	mov    (%rdx),%rax
  8005d9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005dd:	48 85 c0             	test   %rax,%rax
  8005e0:	0f 84 05 04 00 00    	je     8009eb <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005e6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005ea:	7e 06                	jle    8005f2 <vprintfmt+0x24f>
  8005ec:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005f0:	75 31                	jne    800623 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005f6:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005fa:	0f b6 00             	movzbl (%rax),%eax
  8005fd:	0f be f8             	movsbl %al,%edi
  800600:	85 ff                	test   %edi,%edi
  800602:	0f 84 c3 00 00 00    	je     8006cb <vprintfmt+0x328>
  800608:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80060c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800610:	e9 85 00 00 00       	jmpq   80069a <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800615:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800619:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80061d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800621:	eb b3                	jmp    8005d6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800623:	49 63 f4             	movslq %r12d,%rsi
  800626:	48 89 c7             	mov    %rax,%rdi
  800629:	48 b8 7a 0b 80 00 00 	movabs $0x800b7a,%rax
  800630:	00 00 00 
  800633:	ff d0                	callq  *%rax
  800635:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800638:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80063b:	85 f6                	test   %esi,%esi
  80063d:	7e 22                	jle    800661 <vprintfmt+0x2be>
            putch(padc, putdat);
  80063f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800643:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800647:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80064b:	4c 89 fe             	mov    %r15,%rsi
  80064e:	89 df                	mov    %ebx,%edi
  800650:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800653:	41 83 ec 01          	sub    $0x1,%r12d
  800657:	75 f2                	jne    80064b <vprintfmt+0x2a8>
  800659:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80065d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800661:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800665:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800669:	0f b6 00             	movzbl (%rax),%eax
  80066c:	0f be f8             	movsbl %al,%edi
  80066f:	85 ff                	test   %edi,%edi
  800671:	0f 84 56 fd ff ff    	je     8003cd <vprintfmt+0x2a>
  800677:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80067b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80067f:	eb 19                	jmp    80069a <vprintfmt+0x2f7>
            putch(ch, putdat);
  800681:	4c 89 fe             	mov    %r15,%rsi
  800684:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800687:	41 83 ee 01          	sub    $0x1,%r14d
  80068b:	48 83 c3 01          	add    $0x1,%rbx
  80068f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800693:	0f be f8             	movsbl %al,%edi
  800696:	85 ff                	test   %edi,%edi
  800698:	74 29                	je     8006c3 <vprintfmt+0x320>
  80069a:	45 85 e4             	test   %r12d,%r12d
  80069d:	78 06                	js     8006a5 <vprintfmt+0x302>
  80069f:	41 83 ec 01          	sub    $0x1,%r12d
  8006a3:	78 48                	js     8006ed <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006a5:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006a9:	74 d6                	je     800681 <vprintfmt+0x2de>
  8006ab:	0f be c0             	movsbl %al,%eax
  8006ae:	83 e8 20             	sub    $0x20,%eax
  8006b1:	83 f8 5e             	cmp    $0x5e,%eax
  8006b4:	76 cb                	jbe    800681 <vprintfmt+0x2de>
            putch('?', putdat);
  8006b6:	4c 89 fe             	mov    %r15,%rsi
  8006b9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006be:	41 ff d5             	callq  *%r13
  8006c1:	eb c4                	jmp    800687 <vprintfmt+0x2e4>
  8006c3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006c7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006cb:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006ce:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006d2:	0f 8e f5 fc ff ff    	jle    8003cd <vprintfmt+0x2a>
          putch(' ', putdat);
  8006d8:	4c 89 fe             	mov    %r15,%rsi
  8006db:	bf 20 00 00 00       	mov    $0x20,%edi
  8006e0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006e3:	83 eb 01             	sub    $0x1,%ebx
  8006e6:	75 f0                	jne    8006d8 <vprintfmt+0x335>
  8006e8:	e9 e0 fc ff ff       	jmpq   8003cd <vprintfmt+0x2a>
  8006ed:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006f1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006f5:	eb d4                	jmp    8006cb <vprintfmt+0x328>
  if (lflag >= 2)
  8006f7:	83 f9 01             	cmp    $0x1,%ecx
  8006fa:	7f 1d                	jg     800719 <vprintfmt+0x376>
  else if (lflag)
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	74 5e                	je     80075e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800700:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800703:	83 f8 2f             	cmp    $0x2f,%eax
  800706:	77 48                	ja     800750 <vprintfmt+0x3ad>
  800708:	89 c2                	mov    %eax,%edx
  80070a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80070e:	83 c0 08             	add    $0x8,%eax
  800711:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800714:	48 8b 1a             	mov    (%rdx),%rbx
  800717:	eb 17                	jmp    800730 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800719:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80071c:	83 f8 2f             	cmp    $0x2f,%eax
  80071f:	77 21                	ja     800742 <vprintfmt+0x39f>
  800721:	89 c2                	mov    %eax,%edx
  800723:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800727:	83 c0 08             	add    $0x8,%eax
  80072a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80072d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800730:	48 85 db             	test   %rbx,%rbx
  800733:	78 50                	js     800785 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800735:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800738:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073d:	e9 b4 01 00 00       	jmpq   8008f6 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800742:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800746:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80074a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074e:	eb dd                	jmp    80072d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800750:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800754:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800758:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80075c:	eb b6                	jmp    800714 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80075e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800761:	83 f8 2f             	cmp    $0x2f,%eax
  800764:	77 11                	ja     800777 <vprintfmt+0x3d4>
  800766:	89 c2                	mov    %eax,%edx
  800768:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80076c:	83 c0 08             	add    $0x8,%eax
  80076f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800772:	48 63 1a             	movslq (%rdx),%rbx
  800775:	eb b9                	jmp    800730 <vprintfmt+0x38d>
  800777:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80077b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80077f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800783:	eb ed                	jmp    800772 <vprintfmt+0x3cf>
          putch('-', putdat);
  800785:	4c 89 fe             	mov    %r15,%rsi
  800788:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80078d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800790:	48 89 da             	mov    %rbx,%rdx
  800793:	48 f7 da             	neg    %rdx
        base = 10;
  800796:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80079b:	e9 56 01 00 00       	jmpq   8008f6 <vprintfmt+0x553>
  if (lflag >= 2)
  8007a0:	83 f9 01             	cmp    $0x1,%ecx
  8007a3:	7f 25                	jg     8007ca <vprintfmt+0x427>
  else if (lflag)
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	74 5e                	je     800807 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007a9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007ac:	83 f8 2f             	cmp    $0x2f,%eax
  8007af:	77 48                	ja     8007f9 <vprintfmt+0x456>
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007b7:	83 c0 08             	add    $0x8,%eax
  8007ba:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007bd:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c5:	e9 2c 01 00 00       	jmpq   8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007ca:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007cd:	83 f8 2f             	cmp    $0x2f,%eax
  8007d0:	77 19                	ja     8007eb <vprintfmt+0x448>
  8007d2:	89 c2                	mov    %eax,%edx
  8007d4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d8:	83 c0 08             	add    $0x8,%eax
  8007db:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007de:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e6:	e9 0b 01 00 00       	jmpq   8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007eb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ef:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007f3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f7:	eb e5                	jmp    8007de <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007f9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007fd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800801:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800805:	eb b6                	jmp    8007bd <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800807:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80080a:	83 f8 2f             	cmp    $0x2f,%eax
  80080d:	77 18                	ja     800827 <vprintfmt+0x484>
  80080f:	89 c2                	mov    %eax,%edx
  800811:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800815:	83 c0 08             	add    $0x8,%eax
  800818:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80081b:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80081d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800822:	e9 cf 00 00 00       	jmpq   8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800827:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80082b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80082f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800833:	eb e6                	jmp    80081b <vprintfmt+0x478>
  if (lflag >= 2)
  800835:	83 f9 01             	cmp    $0x1,%ecx
  800838:	7f 25                	jg     80085f <vprintfmt+0x4bc>
  else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 5b                	je     800899 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80083e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800841:	83 f8 2f             	cmp    $0x2f,%eax
  800844:	77 45                	ja     80088b <vprintfmt+0x4e8>
  800846:	89 c2                	mov    %eax,%edx
  800848:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80084c:	83 c0 08             	add    $0x8,%eax
  80084f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800852:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800855:	b9 08 00 00 00       	mov    $0x8,%ecx
  80085a:	e9 97 00 00 00       	jmpq   8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80085f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800862:	83 f8 2f             	cmp    $0x2f,%eax
  800865:	77 16                	ja     80087d <vprintfmt+0x4da>
  800867:	89 c2                	mov    %eax,%edx
  800869:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80086d:	83 c0 08             	add    $0x8,%eax
  800870:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800873:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800876:	b9 08 00 00 00       	mov    $0x8,%ecx
  80087b:	eb 79                	jmp    8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80087d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800881:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800885:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800889:	eb e8                	jmp    800873 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80088b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800893:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800897:	eb b9                	jmp    800852 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800899:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089c:	83 f8 2f             	cmp    $0x2f,%eax
  80089f:	77 15                	ja     8008b6 <vprintfmt+0x513>
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a7:	83 c0 08             	add    $0x8,%eax
  8008aa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ad:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008af:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008b4:	eb 40                	jmp    8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008b6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ba:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008be:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c2:	eb e9                	jmp    8008ad <vprintfmt+0x50a>
        putch('0', putdat);
  8008c4:	4c 89 fe             	mov    %r15,%rsi
  8008c7:	bf 30 00 00 00       	mov    $0x30,%edi
  8008cc:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008cf:	4c 89 fe             	mov    %r15,%rsi
  8008d2:	bf 78 00 00 00       	mov    $0x78,%edi
  8008d7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008da:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008dd:	83 f8 2f             	cmp    $0x2f,%eax
  8008e0:	77 34                	ja     800916 <vprintfmt+0x573>
  8008e2:	89 c2                	mov    %eax,%edx
  8008e4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e8:	83 c0 08             	add    $0x8,%eax
  8008eb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ee:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008f1:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008f6:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008fb:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008ff:	4c 89 fe             	mov    %r15,%rsi
  800902:	4c 89 ef             	mov    %r13,%rdi
  800905:	48 b8 79 02 80 00 00 	movabs $0x800279,%rax
  80090c:	00 00 00 
  80090f:	ff d0                	callq  *%rax
        break;
  800911:	e9 b7 fa ff ff       	jmpq   8003cd <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800916:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80091a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800922:	eb ca                	jmp    8008ee <vprintfmt+0x54b>
  if (lflag >= 2)
  800924:	83 f9 01             	cmp    $0x1,%ecx
  800927:	7f 22                	jg     80094b <vprintfmt+0x5a8>
  else if (lflag)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 58                	je     800985 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80092d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800930:	83 f8 2f             	cmp    $0x2f,%eax
  800933:	77 42                	ja     800977 <vprintfmt+0x5d4>
  800935:	89 c2                	mov    %eax,%edx
  800937:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093b:	83 c0 08             	add    $0x8,%eax
  80093e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800941:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800944:	b9 10 00 00 00       	mov    $0x10,%ecx
  800949:	eb ab                	jmp    8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80094b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094e:	83 f8 2f             	cmp    $0x2f,%eax
  800951:	77 16                	ja     800969 <vprintfmt+0x5c6>
  800953:	89 c2                	mov    %eax,%edx
  800955:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800959:	83 c0 08             	add    $0x8,%eax
  80095c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800962:	b9 10 00 00 00       	mov    $0x10,%ecx
  800967:	eb 8d                	jmp    8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800969:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800971:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800975:	eb e8                	jmp    80095f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800977:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800983:	eb bc                	jmp    800941 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800985:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800988:	83 f8 2f             	cmp    $0x2f,%eax
  80098b:	77 18                	ja     8009a5 <vprintfmt+0x602>
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800993:	83 c0 08             	add    $0x8,%eax
  800996:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800999:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80099b:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009a0:	e9 51 ff ff ff       	jmpq   8008f6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ad:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b1:	eb e6                	jmp    800999 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009b3:	4c 89 fe             	mov    %r15,%rsi
  8009b6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009bb:	41 ff d5             	callq  *%r13
        break;
  8009be:	e9 0a fa ff ff       	jmpq   8003cd <vprintfmt+0x2a>
        putch('%', putdat);
  8009c3:	4c 89 fe             	mov    %r15,%rsi
  8009c6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009cb:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009ce:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009d2:	0f 84 15 fa ff ff    	je     8003ed <vprintfmt+0x4a>
  8009d8:	49 89 de             	mov    %rbx,%r14
  8009db:	49 83 ee 01          	sub    $0x1,%r14
  8009df:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009e4:	75 f5                	jne    8009db <vprintfmt+0x638>
  8009e6:	e9 e2 f9 ff ff       	jmpq   8003cd <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009eb:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009ef:	74 06                	je     8009f7 <vprintfmt+0x654>
  8009f1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009f5:	7f 21                	jg     800a18 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f7:	bf 28 00 00 00       	mov    $0x28,%edi
  8009fc:	48 bb c0 11 80 00 00 	movabs $0x8011c0,%rbx
  800a03:	00 00 00 
  800a06:	b8 28 00 00 00       	mov    $0x28,%eax
  800a0b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a0f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a13:	e9 82 fc ff ff       	jmpq   80069a <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a18:	49 63 f4             	movslq %r12d,%rsi
  800a1b:	48 bf bf 11 80 00 00 	movabs $0x8011bf,%rdi
  800a22:	00 00 00 
  800a25:	48 b8 7a 0b 80 00 00 	movabs $0x800b7a,%rax
  800a2c:	00 00 00 
  800a2f:	ff d0                	callq  *%rax
  800a31:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a34:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a37:	48 be bf 11 80 00 00 	movabs $0x8011bf,%rsi
  800a3e:	00 00 00 
  800a41:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	0f 8f f2 fb ff ff    	jg     80063f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4d:	48 bb c0 11 80 00 00 	movabs $0x8011c0,%rbx
  800a54:	00 00 00 
  800a57:	b8 28 00 00 00       	mov    $0x28,%eax
  800a5c:	bf 28 00 00 00       	mov    $0x28,%edi
  800a61:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a65:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a69:	e9 2c fc ff ff       	jmpq   80069a <vprintfmt+0x2f7>
}
  800a6e:	48 83 c4 48          	add    $0x48,%rsp
  800a72:	5b                   	pop    %rbx
  800a73:	41 5c                	pop    %r12
  800a75:	41 5d                	pop    %r13
  800a77:	41 5e                	pop    %r14
  800a79:	41 5f                	pop    %r15
  800a7b:	5d                   	pop    %rbp
  800a7c:	c3                   	retq   

0000000000800a7d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a7d:	55                   	push   %rbp
  800a7e:	48 89 e5             	mov    %rsp,%rbp
  800a81:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a85:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a89:	48 63 c6             	movslq %esi,%rax
  800a8c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a91:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a95:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a9c:	48 85 ff             	test   %rdi,%rdi
  800a9f:	74 2a                	je     800acb <vsnprintf+0x4e>
  800aa1:	85 f6                	test   %esi,%esi
  800aa3:	7e 26                	jle    800acb <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800aa5:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800aa9:	48 bf 05 03 80 00 00 	movabs $0x800305,%rdi
  800ab0:	00 00 00 
  800ab3:	48 b8 a3 03 80 00 00 	movabs $0x8003a3,%rax
  800aba:	00 00 00 
  800abd:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800abf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ac3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ac6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ac9:	c9                   	leaveq 
  800aca:	c3                   	retq   
    return -E_INVAL;
  800acb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad0:	eb f7                	jmp    800ac9 <vsnprintf+0x4c>

0000000000800ad2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ad2:	55                   	push   %rbp
  800ad3:	48 89 e5             	mov    %rsp,%rbp
  800ad6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800add:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ae4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800aeb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800af2:	84 c0                	test   %al,%al
  800af4:	74 20                	je     800b16 <snprintf+0x44>
  800af6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800afa:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800afe:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b02:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b06:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b0a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b0e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b12:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b16:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b1d:	00 00 00 
  800b20:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b27:	00 00 00 
  800b2a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b2e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b35:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b3c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b43:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b4a:	48 b8 7d 0a 80 00 00 	movabs $0x800a7d,%rax
  800b51:	00 00 00 
  800b54:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b56:	c9                   	leaveq 
  800b57:	c3                   	retq   

0000000000800b58 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b58:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b5b:	74 17                	je     800b74 <strlen+0x1c>
  800b5d:	48 89 fa             	mov    %rdi,%rdx
  800b60:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b65:	29 f9                	sub    %edi,%ecx
    n++;
  800b67:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b6a:	48 83 c2 01          	add    $0x1,%rdx
  800b6e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b71:	75 f4                	jne    800b67 <strlen+0xf>
  800b73:	c3                   	retq   
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b79:	c3                   	retq   

0000000000800b7a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7a:	48 85 f6             	test   %rsi,%rsi
  800b7d:	74 24                	je     800ba3 <strnlen+0x29>
  800b7f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b82:	74 25                	je     800ba9 <strnlen+0x2f>
  800b84:	48 01 fe             	add    %rdi,%rsi
  800b87:	48 89 fa             	mov    %rdi,%rdx
  800b8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b8f:	29 f9                	sub    %edi,%ecx
    n++;
  800b91:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b94:	48 83 c2 01          	add    $0x1,%rdx
  800b98:	48 39 f2             	cmp    %rsi,%rdx
  800b9b:	74 11                	je     800bae <strnlen+0x34>
  800b9d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ba0:	75 ef                	jne    800b91 <strnlen+0x17>
  800ba2:	c3                   	retq   
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	c3                   	retq   
  800ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800bae:	c3                   	retq   

0000000000800baf <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800baf:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bbb:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bbe:	48 83 c2 01          	add    $0x1,%rdx
  800bc2:	84 c9                	test   %cl,%cl
  800bc4:	75 f1                	jne    800bb7 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bc6:	c3                   	retq   

0000000000800bc7 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bc7:	55                   	push   %rbp
  800bc8:	48 89 e5             	mov    %rsp,%rbp
  800bcb:	41 54                	push   %r12
  800bcd:	53                   	push   %rbx
  800bce:	48 89 fb             	mov    %rdi,%rbx
  800bd1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bd4:	48 b8 58 0b 80 00 00 	movabs $0x800b58,%rax
  800bdb:	00 00 00 
  800bde:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800be0:	48 63 f8             	movslq %eax,%rdi
  800be3:	48 01 df             	add    %rbx,%rdi
  800be6:	4c 89 e6             	mov    %r12,%rsi
  800be9:	48 b8 af 0b 80 00 00 	movabs $0x800baf,%rax
  800bf0:	00 00 00 
  800bf3:	ff d0                	callq  *%rax
  return dst;
}
  800bf5:	48 89 d8             	mov    %rbx,%rax
  800bf8:	5b                   	pop    %rbx
  800bf9:	41 5c                	pop    %r12
  800bfb:	5d                   	pop    %rbp
  800bfc:	c3                   	retq   

0000000000800bfd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bfd:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c00:	48 85 d2             	test   %rdx,%rdx
  800c03:	74 1f                	je     800c24 <strncpy+0x27>
  800c05:	48 01 fa             	add    %rdi,%rdx
  800c08:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c0b:	48 83 c1 01          	add    $0x1,%rcx
  800c0f:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c13:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c17:	41 80 f8 01          	cmp    $0x1,%r8b
  800c1b:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c1f:	48 39 ca             	cmp    %rcx,%rdx
  800c22:	75 e7                	jne    800c0b <strncpy+0xe>
  }
  return ret;
}
  800c24:	c3                   	retq   

0000000000800c25 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c25:	48 89 f8             	mov    %rdi,%rax
  800c28:	48 85 d2             	test   %rdx,%rdx
  800c2b:	74 36                	je     800c63 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c2d:	48 83 fa 01          	cmp    $0x1,%rdx
  800c31:	74 2d                	je     800c60 <strlcpy+0x3b>
  800c33:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c37:	45 84 c0             	test   %r8b,%r8b
  800c3a:	74 24                	je     800c60 <strlcpy+0x3b>
  800c3c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c40:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c45:	48 83 c0 01          	add    $0x1,%rax
  800c49:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c4d:	48 39 d1             	cmp    %rdx,%rcx
  800c50:	74 0e                	je     800c60 <strlcpy+0x3b>
  800c52:	48 83 c1 01          	add    $0x1,%rcx
  800c56:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c5b:	45 84 c0             	test   %r8b,%r8b
  800c5e:	75 e5                	jne    800c45 <strlcpy+0x20>
    *dst = '\0';
  800c60:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c63:	48 29 f8             	sub    %rdi,%rax
}
  800c66:	c3                   	retq   

0000000000800c67 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c67:	0f b6 07             	movzbl (%rdi),%eax
  800c6a:	84 c0                	test   %al,%al
  800c6c:	74 17                	je     800c85 <strcmp+0x1e>
  800c6e:	3a 06                	cmp    (%rsi),%al
  800c70:	75 13                	jne    800c85 <strcmp+0x1e>
    p++, q++;
  800c72:	48 83 c7 01          	add    $0x1,%rdi
  800c76:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c7a:	0f b6 07             	movzbl (%rdi),%eax
  800c7d:	84 c0                	test   %al,%al
  800c7f:	74 04                	je     800c85 <strcmp+0x1e>
  800c81:	3a 06                	cmp    (%rsi),%al
  800c83:	74 ed                	je     800c72 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c85:	0f b6 c0             	movzbl %al,%eax
  800c88:	0f b6 16             	movzbl (%rsi),%edx
  800c8b:	29 d0                	sub    %edx,%eax
}
  800c8d:	c3                   	retq   

0000000000800c8e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c8e:	48 85 d2             	test   %rdx,%rdx
  800c91:	74 2f                	je     800cc2 <strncmp+0x34>
  800c93:	0f b6 07             	movzbl (%rdi),%eax
  800c96:	84 c0                	test   %al,%al
  800c98:	74 1f                	je     800cb9 <strncmp+0x2b>
  800c9a:	3a 06                	cmp    (%rsi),%al
  800c9c:	75 1b                	jne    800cb9 <strncmp+0x2b>
  800c9e:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800ca1:	48 83 c7 01          	add    $0x1,%rdi
  800ca5:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ca9:	48 39 d7             	cmp    %rdx,%rdi
  800cac:	74 1a                	je     800cc8 <strncmp+0x3a>
  800cae:	0f b6 07             	movzbl (%rdi),%eax
  800cb1:	84 c0                	test   %al,%al
  800cb3:	74 04                	je     800cb9 <strncmp+0x2b>
  800cb5:	3a 06                	cmp    (%rsi),%al
  800cb7:	74 e8                	je     800ca1 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800cb9:	0f b6 07             	movzbl (%rdi),%eax
  800cbc:	0f b6 16             	movzbl (%rsi),%edx
  800cbf:	29 d0                	sub    %edx,%eax
}
  800cc1:	c3                   	retq   
    return 0;
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	c3                   	retq   
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccd:	c3                   	retq   

0000000000800cce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cce:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cd0:	0f b6 07             	movzbl (%rdi),%eax
  800cd3:	84 c0                	test   %al,%al
  800cd5:	74 1e                	je     800cf5 <strchr+0x27>
    if (*s == c)
  800cd7:	40 38 c6             	cmp    %al,%sil
  800cda:	74 1f                	je     800cfb <strchr+0x2d>
  for (; *s; s++)
  800cdc:	48 83 c7 01          	add    $0x1,%rdi
  800ce0:	0f b6 07             	movzbl (%rdi),%eax
  800ce3:	84 c0                	test   %al,%al
  800ce5:	74 08                	je     800cef <strchr+0x21>
    if (*s == c)
  800ce7:	38 d0                	cmp    %dl,%al
  800ce9:	75 f1                	jne    800cdc <strchr+0xe>
  for (; *s; s++)
  800ceb:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cee:	c3                   	retq   
  return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	c3                   	retq   
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	c3                   	retq   
    if (*s == c)
  800cfb:	48 89 f8             	mov    %rdi,%rax
  800cfe:	c3                   	retq   

0000000000800cff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cff:	48 89 f8             	mov    %rdi,%rax
  800d02:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d04:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d07:	40 38 f2             	cmp    %sil,%dl
  800d0a:	74 13                	je     800d1f <strfind+0x20>
  800d0c:	84 d2                	test   %dl,%dl
  800d0e:	74 0f                	je     800d1f <strfind+0x20>
  for (; *s; s++)
  800d10:	48 83 c0 01          	add    $0x1,%rax
  800d14:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d17:	38 ca                	cmp    %cl,%dl
  800d19:	74 04                	je     800d1f <strfind+0x20>
  800d1b:	84 d2                	test   %dl,%dl
  800d1d:	75 f1                	jne    800d10 <strfind+0x11>
      break;
  return (char *)s;
}
  800d1f:	c3                   	retq   

0000000000800d20 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d20:	48 85 d2             	test   %rdx,%rdx
  800d23:	74 3a                	je     800d5f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d25:	48 89 f8             	mov    %rdi,%rax
  800d28:	48 09 d0             	or     %rdx,%rax
  800d2b:	a8 03                	test   $0x3,%al
  800d2d:	75 28                	jne    800d57 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d2f:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d33:	89 f0                	mov    %esi,%eax
  800d35:	c1 e0 08             	shl    $0x8,%eax
  800d38:	89 f1                	mov    %esi,%ecx
  800d3a:	c1 e1 18             	shl    $0x18,%ecx
  800d3d:	41 89 f0             	mov    %esi,%r8d
  800d40:	41 c1 e0 10          	shl    $0x10,%r8d
  800d44:	44 09 c1             	or     %r8d,%ecx
  800d47:	09 ce                	or     %ecx,%esi
  800d49:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d4b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d4f:	48 89 d1             	mov    %rdx,%rcx
  800d52:	fc                   	cld    
  800d53:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d55:	eb 08                	jmp    800d5f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d57:	89 f0                	mov    %esi,%eax
  800d59:	48 89 d1             	mov    %rdx,%rcx
  800d5c:	fc                   	cld    
  800d5d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d5f:	48 89 f8             	mov    %rdi,%rax
  800d62:	c3                   	retq   

0000000000800d63 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d63:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d66:	48 39 fe             	cmp    %rdi,%rsi
  800d69:	73 40                	jae    800dab <memmove+0x48>
  800d6b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d6f:	48 39 f9             	cmp    %rdi,%rcx
  800d72:	76 37                	jbe    800dab <memmove+0x48>
    s += n;
    d += n;
  800d74:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d78:	48 89 fe             	mov    %rdi,%rsi
  800d7b:	48 09 d6             	or     %rdx,%rsi
  800d7e:	48 09 ce             	or     %rcx,%rsi
  800d81:	40 f6 c6 03          	test   $0x3,%sil
  800d85:	75 14                	jne    800d9b <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d87:	48 83 ef 04          	sub    $0x4,%rdi
  800d8b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d8f:	48 c1 ea 02          	shr    $0x2,%rdx
  800d93:	48 89 d1             	mov    %rdx,%rcx
  800d96:	fd                   	std    
  800d97:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d99:	eb 0e                	jmp    800da9 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d9b:	48 83 ef 01          	sub    $0x1,%rdi
  800d9f:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800da3:	48 89 d1             	mov    %rdx,%rcx
  800da6:	fd                   	std    
  800da7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800da9:	fc                   	cld    
  800daa:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800dab:	48 89 c1             	mov    %rax,%rcx
  800dae:	48 09 d1             	or     %rdx,%rcx
  800db1:	48 09 f1             	or     %rsi,%rcx
  800db4:	f6 c1 03             	test   $0x3,%cl
  800db7:	75 0e                	jne    800dc7 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800db9:	48 c1 ea 02          	shr    $0x2,%rdx
  800dbd:	48 89 d1             	mov    %rdx,%rcx
  800dc0:	48 89 c7             	mov    %rax,%rdi
  800dc3:	fc                   	cld    
  800dc4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dc6:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800dc7:	48 89 c7             	mov    %rax,%rdi
  800dca:	48 89 d1             	mov    %rdx,%rcx
  800dcd:	fc                   	cld    
  800dce:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dd0:	c3                   	retq   

0000000000800dd1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dd1:	55                   	push   %rbp
  800dd2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dd5:	48 b8 63 0d 80 00 00 	movabs $0x800d63,%rax
  800ddc:	00 00 00 
  800ddf:	ff d0                	callq  *%rax
}
  800de1:	5d                   	pop    %rbp
  800de2:	c3                   	retq   

0000000000800de3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800de3:	55                   	push   %rbp
  800de4:	48 89 e5             	mov    %rsp,%rbp
  800de7:	41 57                	push   %r15
  800de9:	41 56                	push   %r14
  800deb:	41 55                	push   %r13
  800ded:	41 54                	push   %r12
  800def:	53                   	push   %rbx
  800df0:	48 83 ec 08          	sub    $0x8,%rsp
  800df4:	49 89 fe             	mov    %rdi,%r14
  800df7:	49 89 f7             	mov    %rsi,%r15
  800dfa:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800dfd:	48 89 f7             	mov    %rsi,%rdi
  800e00:	48 b8 58 0b 80 00 00 	movabs $0x800b58,%rax
  800e07:	00 00 00 
  800e0a:	ff d0                	callq  *%rax
  800e0c:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e0f:	4c 89 ee             	mov    %r13,%rsi
  800e12:	4c 89 f7             	mov    %r14,%rdi
  800e15:	48 b8 7a 0b 80 00 00 	movabs $0x800b7a,%rax
  800e1c:	00 00 00 
  800e1f:	ff d0                	callq  *%rax
  800e21:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e24:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e28:	4d 39 e5             	cmp    %r12,%r13
  800e2b:	74 26                	je     800e53 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e2d:	4c 89 e8             	mov    %r13,%rax
  800e30:	4c 29 e0             	sub    %r12,%rax
  800e33:	48 39 d8             	cmp    %rbx,%rax
  800e36:	76 2a                	jbe    800e62 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e38:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e3c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e40:	4c 89 fe             	mov    %r15,%rsi
  800e43:	48 b8 d1 0d 80 00 00 	movabs $0x800dd1,%rax
  800e4a:	00 00 00 
  800e4d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e4f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e53:	48 83 c4 08          	add    $0x8,%rsp
  800e57:	5b                   	pop    %rbx
  800e58:	41 5c                	pop    %r12
  800e5a:	41 5d                	pop    %r13
  800e5c:	41 5e                	pop    %r14
  800e5e:	41 5f                	pop    %r15
  800e60:	5d                   	pop    %rbp
  800e61:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e62:	49 83 ed 01          	sub    $0x1,%r13
  800e66:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e6a:	4c 89 ea             	mov    %r13,%rdx
  800e6d:	4c 89 fe             	mov    %r15,%rsi
  800e70:	48 b8 d1 0d 80 00 00 	movabs $0x800dd1,%rax
  800e77:	00 00 00 
  800e7a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e7c:	4d 01 ee             	add    %r13,%r14
  800e7f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e84:	eb c9                	jmp    800e4f <strlcat+0x6c>

0000000000800e86 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e86:	48 85 d2             	test   %rdx,%rdx
  800e89:	74 3a                	je     800ec5 <memcmp+0x3f>
    if (*s1 != *s2)
  800e8b:	0f b6 0f             	movzbl (%rdi),%ecx
  800e8e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e92:	44 38 c1             	cmp    %r8b,%cl
  800e95:	75 1d                	jne    800eb4 <memcmp+0x2e>
  800e97:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e9c:	48 39 d0             	cmp    %rdx,%rax
  800e9f:	74 1e                	je     800ebf <memcmp+0x39>
    if (*s1 != *s2)
  800ea1:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ea5:	48 83 c0 01          	add    $0x1,%rax
  800ea9:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800eaf:	44 38 c1             	cmp    %r8b,%cl
  800eb2:	74 e8                	je     800e9c <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800eb4:	0f b6 c1             	movzbl %cl,%eax
  800eb7:	45 0f b6 c0          	movzbl %r8b,%r8d
  800ebb:	44 29 c0             	sub    %r8d,%eax
  800ebe:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	c3                   	retq   
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eca:	c3                   	retq   

0000000000800ecb <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800ecb:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ecf:	48 39 c7             	cmp    %rax,%rdi
  800ed2:	73 19                	jae    800eed <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed4:	89 f2                	mov    %esi,%edx
  800ed6:	40 38 37             	cmp    %sil,(%rdi)
  800ed9:	74 16                	je     800ef1 <memfind+0x26>
  for (; s < ends; s++)
  800edb:	48 83 c7 01          	add    $0x1,%rdi
  800edf:	48 39 f8             	cmp    %rdi,%rax
  800ee2:	74 08                	je     800eec <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee4:	38 17                	cmp    %dl,(%rdi)
  800ee6:	75 f3                	jne    800edb <memfind+0x10>
  for (; s < ends; s++)
  800ee8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800eeb:	c3                   	retq   
  800eec:	c3                   	retq   
  for (; s < ends; s++)
  800eed:	48 89 f8             	mov    %rdi,%rax
  800ef0:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ef1:	48 89 f8             	mov    %rdi,%rax
  800ef4:	c3                   	retq   

0000000000800ef5 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ef5:	0f b6 07             	movzbl (%rdi),%eax
  800ef8:	3c 20                	cmp    $0x20,%al
  800efa:	74 04                	je     800f00 <strtol+0xb>
  800efc:	3c 09                	cmp    $0x9,%al
  800efe:	75 0f                	jne    800f0f <strtol+0x1a>
    s++;
  800f00:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f04:	0f b6 07             	movzbl (%rdi),%eax
  800f07:	3c 20                	cmp    $0x20,%al
  800f09:	74 f5                	je     800f00 <strtol+0xb>
  800f0b:	3c 09                	cmp    $0x9,%al
  800f0d:	74 f1                	je     800f00 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f0f:	3c 2b                	cmp    $0x2b,%al
  800f11:	74 2b                	je     800f3e <strtol+0x49>
  int neg  = 0;
  800f13:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f19:	3c 2d                	cmp    $0x2d,%al
  800f1b:	74 2d                	je     800f4a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1d:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f23:	75 0f                	jne    800f34 <strtol+0x3f>
  800f25:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f28:	74 2c                	je     800f56 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f2a:	85 d2                	test   %edx,%edx
  800f2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f31:	0f 44 d0             	cmove  %eax,%edx
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f39:	4c 63 d2             	movslq %edx,%r10
  800f3c:	eb 5c                	jmp    800f9a <strtol+0xa5>
    s++;
  800f3e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f42:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f48:	eb d3                	jmp    800f1d <strtol+0x28>
    s++, neg = 1;
  800f4a:	48 83 c7 01          	add    $0x1,%rdi
  800f4e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f54:	eb c7                	jmp    800f1d <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f56:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f5a:	74 0f                	je     800f6b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f5c:	85 d2                	test   %edx,%edx
  800f5e:	75 d4                	jne    800f34 <strtol+0x3f>
    s++, base = 8;
  800f60:	48 83 c7 01          	add    $0x1,%rdi
  800f64:	ba 08 00 00 00       	mov    $0x8,%edx
  800f69:	eb c9                	jmp    800f34 <strtol+0x3f>
    s += 2, base = 16;
  800f6b:	48 83 c7 02          	add    $0x2,%rdi
  800f6f:	ba 10 00 00 00       	mov    $0x10,%edx
  800f74:	eb be                	jmp    800f34 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f76:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f7a:	41 80 f8 19          	cmp    $0x19,%r8b
  800f7e:	77 2f                	ja     800faf <strtol+0xba>
      dig = *s - 'a' + 10;
  800f80:	44 0f be c1          	movsbl %cl,%r8d
  800f84:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f88:	39 d1                	cmp    %edx,%ecx
  800f8a:	7d 37                	jge    800fc3 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f8c:	48 83 c7 01          	add    $0x1,%rdi
  800f90:	49 0f af c2          	imul   %r10,%rax
  800f94:	48 63 c9             	movslq %ecx,%rcx
  800f97:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f9a:	0f b6 0f             	movzbl (%rdi),%ecx
  800f9d:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800fa1:	41 80 f8 09          	cmp    $0x9,%r8b
  800fa5:	77 cf                	ja     800f76 <strtol+0x81>
      dig = *s - '0';
  800fa7:	0f be c9             	movsbl %cl,%ecx
  800faa:	83 e9 30             	sub    $0x30,%ecx
  800fad:	eb d9                	jmp    800f88 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800faf:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fb3:	41 80 f8 19          	cmp    $0x19,%r8b
  800fb7:	77 0a                	ja     800fc3 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fb9:	44 0f be c1          	movsbl %cl,%r8d
  800fbd:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fc1:	eb c5                	jmp    800f88 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fc3:	48 85 f6             	test   %rsi,%rsi
  800fc6:	74 03                	je     800fcb <strtol+0xd6>
    *endptr = (char *)s;
  800fc8:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fcb:	48 89 c2             	mov    %rax,%rdx
  800fce:	48 f7 da             	neg    %rdx
  800fd1:	45 85 c9             	test   %r9d,%r9d
  800fd4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fd8:	c3                   	retq   

0000000000800fd9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fd9:	55                   	push   %rbp
  800fda:	48 89 e5             	mov    %rsp,%rbp
  800fdd:	53                   	push   %rbx
  800fde:	48 89 fa             	mov    %rdi,%rdx
  800fe1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	48 89 c3             	mov    %rax,%rbx
  800fec:	48 89 c7             	mov    %rax,%rdi
  800fef:	48 89 c6             	mov    %rax,%rsi
  800ff2:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800ff4:	5b                   	pop    %rbx
  800ff5:	5d                   	pop    %rbp
  800ff6:	c3                   	retq   

0000000000800ff7 <sys_cgetc>:

int
sys_cgetc(void) {
  800ff7:	55                   	push   %rbp
  800ff8:	48 89 e5             	mov    %rsp,%rbp
  800ffb:	53                   	push   %rbx
  asm volatile("int %1\n"
  800ffc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801001:	b8 01 00 00 00       	mov    $0x1,%eax
  801006:	48 89 ca             	mov    %rcx,%rdx
  801009:	48 89 cb             	mov    %rcx,%rbx
  80100c:	48 89 cf             	mov    %rcx,%rdi
  80100f:	48 89 ce             	mov    %rcx,%rsi
  801012:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801014:	5b                   	pop    %rbx
  801015:	5d                   	pop    %rbp
  801016:	c3                   	retq   

0000000000801017 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801017:	55                   	push   %rbp
  801018:	48 89 e5             	mov    %rsp,%rbp
  80101b:	53                   	push   %rbx
  80101c:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801020:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801023:	be 00 00 00 00       	mov    $0x0,%esi
  801028:	b8 03 00 00 00       	mov    $0x3,%eax
  80102d:	48 89 f1             	mov    %rsi,%rcx
  801030:	48 89 f3             	mov    %rsi,%rbx
  801033:	48 89 f7             	mov    %rsi,%rdi
  801036:	cd 30                	int    $0x30
  if (check && ret > 0)
  801038:	48 85 c0             	test   %rax,%rax
  80103b:	7f 07                	jg     801044 <sys_env_destroy+0x2d>
}
  80103d:	48 83 c4 08          	add    $0x8,%rsp
  801041:	5b                   	pop    %rbx
  801042:	5d                   	pop    %rbp
  801043:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801044:	49 89 c0             	mov    %rax,%r8
  801047:	b9 03 00 00 00       	mov    $0x3,%ecx
  80104c:	48 ba 70 15 80 00 00 	movabs $0x801570,%rdx
  801053:	00 00 00 
  801056:	be 22 00 00 00       	mov    $0x22,%esi
  80105b:	48 bf 8f 15 80 00 00 	movabs $0x80158f,%rdi
  801062:	00 00 00 
  801065:	b8 00 00 00 00       	mov    $0x0,%eax
  80106a:	49 b9 97 10 80 00 00 	movabs $0x801097,%r9
  801071:	00 00 00 
  801074:	41 ff d1             	callq  *%r9

0000000000801077 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801077:	55                   	push   %rbp
  801078:	48 89 e5             	mov    %rsp,%rbp
  80107b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80107c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801081:	b8 02 00 00 00       	mov    $0x2,%eax
  801086:	48 89 ca             	mov    %rcx,%rdx
  801089:	48 89 cb             	mov    %rcx,%rbx
  80108c:	48 89 cf             	mov    %rcx,%rdi
  80108f:	48 89 ce             	mov    %rcx,%rsi
  801092:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801094:	5b                   	pop    %rbx
  801095:	5d                   	pop    %rbp
  801096:	c3                   	retq   

0000000000801097 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801097:	55                   	push   %rbp
  801098:	48 89 e5             	mov    %rsp,%rbp
  80109b:	41 56                	push   %r14
  80109d:	41 55                	push   %r13
  80109f:	41 54                	push   %r12
  8010a1:	53                   	push   %rbx
  8010a2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8010a9:	49 89 fd             	mov    %rdi,%r13
  8010ac:	41 89 f6             	mov    %esi,%r14d
  8010af:	49 89 d4             	mov    %rdx,%r12
  8010b2:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8010b9:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010c0:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010c7:	84 c0                	test   %al,%al
  8010c9:	74 26                	je     8010f1 <_panic+0x5a>
  8010cb:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010d2:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010d9:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010dd:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010e1:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010e5:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010e9:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010ed:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010f1:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010f8:	00 00 00 
  8010fb:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801102:	00 00 00 
  801105:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801109:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801110:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801117:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80111e:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  801125:	00 00 00 
  801128:	48 8b 18             	mov    (%rax),%rbx
  80112b:	48 b8 77 10 80 00 00 	movabs $0x801077,%rax
  801132:	00 00 00 
  801135:	ff d0                	callq  *%rax
  801137:	45 89 f0             	mov    %r14d,%r8d
  80113a:	4c 89 e9             	mov    %r13,%rcx
  80113d:	48 89 da             	mov    %rbx,%rdx
  801140:	89 c6                	mov    %eax,%esi
  801142:	48 bf a0 15 80 00 00 	movabs $0x8015a0,%rdi
  801149:	00 00 00 
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
  801151:	48 bb e5 01 80 00 00 	movabs $0x8001e5,%rbx
  801158:	00 00 00 
  80115b:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80115d:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801164:	4c 89 e7             	mov    %r12,%rdi
  801167:	48 b8 7d 01 80 00 00 	movabs $0x80017d,%rax
  80116e:	00 00 00 
  801171:	ff d0                	callq  *%rax
  cprintf("\n");
  801173:	48 bf a2 11 80 00 00 	movabs $0x8011a2,%rdi
  80117a:	00 00 00 
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
  801182:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801184:	cc                   	int3   
  while (1)
  801185:	eb fd                	jmp    801184 <_panic+0xed>
  801187:	90                   	nop
