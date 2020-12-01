
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
  800045:	48 bf 20 14 80 00 00 	movabs $0x801420,%rdi
  80004c:	00 00 00 
  80004f:	b8 00 00 00 00       	mov    $0x0,%eax
  800054:	48 ba e1 01 80 00 00 	movabs $0x8001e1,%rdx
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000af:	48 b8 73 10 80 00 00 	movabs $0x801073,%rax
  8000b6:	00 00 00 
  8000b9:	ff d0                	callq  *%rax
  8000bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c0:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000c4:	48 c1 e0 05          	shl    $0x5,%rax
  8000c8:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000cf:	00 00 00 
  8000d2:	48 01 d0             	add    %rdx,%rax
  8000d5:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000dc:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000df:	45 85 ed             	test   %r13d,%r13d
  8000e2:	7e 0d                	jle    8000f1 <libmain+0x8f>
    binaryname = argv[0];
  8000e4:	49 8b 06             	mov    (%r14),%rax
  8000e7:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000ee:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000f1:	4c 89 f6             	mov    %r14,%rsi
  8000f4:	44 89 ef             	mov    %r13d,%edi
  8000f7:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000fe:	00 00 00 
  800101:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800103:	48 b8 18 01 80 00 00 	movabs $0x800118,%rax
  80010a:	00 00 00 
  80010d:	ff d0                	callq  *%rax
#endif
}
  80010f:	5b                   	pop    %rbx
  800110:	41 5c                	pop    %r12
  800112:	41 5d                	pop    %r13
  800114:	41 5e                	pop    %r14
  800116:	5d                   	pop    %rbp
  800117:	c3                   	retq   

0000000000800118 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800118:	55                   	push   %rbp
  800119:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80011c:	bf 00 00 00 00       	mov    $0x0,%edi
  800121:	48 b8 13 10 80 00 00 	movabs $0x801013,%rax
  800128:	00 00 00 
  80012b:	ff d0                	callq  *%rax
}
  80012d:	5d                   	pop    %rbp
  80012e:	c3                   	retq   

000000000080012f <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80012f:	55                   	push   %rbp
  800130:	48 89 e5             	mov    %rsp,%rbp
  800133:	53                   	push   %rbx
  800134:	48 83 ec 08          	sub    $0x8,%rsp
  800138:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80013b:	8b 06                	mov    (%rsi),%eax
  80013d:	8d 50 01             	lea    0x1(%rax),%edx
  800140:	89 16                	mov    %edx,(%rsi)
  800142:	48 98                	cltq   
  800144:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800149:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80014f:	74 0b                	je     80015c <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800151:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800155:	48 83 c4 08          	add    $0x8,%rsp
  800159:	5b                   	pop    %rbx
  80015a:	5d                   	pop    %rbp
  80015b:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80015c:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800160:	be ff 00 00 00       	mov    $0xff,%esi
  800165:	48 b8 d5 0f 80 00 00 	movabs $0x800fd5,%rax
  80016c:	00 00 00 
  80016f:	ff d0                	callq  *%rax
    b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800177:	eb d8                	jmp    800151 <putch+0x22>

0000000000800179 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800179:	55                   	push   %rbp
  80017a:	48 89 e5             	mov    %rsp,%rbp
  80017d:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800184:	48 89 fa             	mov    %rdi,%rdx
  800187:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80018a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800191:	00 00 00 
  b.cnt = 0;
  800194:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80019b:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80019e:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001a5:	48 bf 2f 01 80 00 00 	movabs $0x80012f,%rdi
  8001ac:	00 00 00 
  8001af:	48 b8 9f 03 80 00 00 	movabs $0x80039f,%rax
  8001b6:	00 00 00 
  8001b9:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001bb:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001c2:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001c9:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001cd:	48 b8 d5 0f 80 00 00 	movabs $0x800fd5,%rax
  8001d4:	00 00 00 
  8001d7:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001d9:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001df:	c9                   	leaveq 
  8001e0:	c3                   	retq   

00000000008001e1 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001e1:	55                   	push   %rbp
  8001e2:	48 89 e5             	mov    %rsp,%rbp
  8001e5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001ec:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001f3:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001fa:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800201:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800208:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80020f:	84 c0                	test   %al,%al
  800211:	74 20                	je     800233 <cprintf+0x52>
  800213:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800217:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80021b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80021f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800223:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800227:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80022b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80022f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800233:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80023a:	00 00 00 
  80023d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800244:	00 00 00 
  800247:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80024b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800252:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800259:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800260:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800267:	48 b8 79 01 80 00 00 	movabs $0x800179,%rax
  80026e:	00 00 00 
  800271:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800273:	c9                   	leaveq 
  800274:	c3                   	retq   

0000000000800275 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800275:	55                   	push   %rbp
  800276:	48 89 e5             	mov    %rsp,%rbp
  800279:	41 57                	push   %r15
  80027b:	41 56                	push   %r14
  80027d:	41 55                	push   %r13
  80027f:	41 54                	push   %r12
  800281:	53                   	push   %rbx
  800282:	48 83 ec 18          	sub    $0x18,%rsp
  800286:	49 89 fc             	mov    %rdi,%r12
  800289:	49 89 f5             	mov    %rsi,%r13
  80028c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800290:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800293:	41 89 cf             	mov    %ecx,%r15d
  800296:	49 39 d7             	cmp    %rdx,%r15
  800299:	76 45                	jbe    8002e0 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80029b:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7e 0e                	jle    8002b1 <printnum+0x3c>
      putch(padc, putdat);
  8002a3:	4c 89 ee             	mov    %r13,%rsi
  8002a6:	44 89 f7             	mov    %r14d,%edi
  8002a9:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002ac:	83 eb 01             	sub    $0x1,%ebx
  8002af:	75 f2                	jne    8002a3 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002b1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	49 f7 f7             	div    %r15
  8002bd:	48 b8 2e 14 80 00 00 	movabs $0x80142e,%rax
  8002c4:	00 00 00 
  8002c7:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002cb:	4c 89 ee             	mov    %r13,%rsi
  8002ce:	41 ff d4             	callq  *%r12
}
  8002d1:	48 83 c4 18          	add    $0x18,%rsp
  8002d5:	5b                   	pop    %rbx
  8002d6:	41 5c                	pop    %r12
  8002d8:	41 5d                	pop    %r13
  8002da:	41 5e                	pop    %r14
  8002dc:	41 5f                	pop    %r15
  8002de:	5d                   	pop    %rbp
  8002df:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e9:	49 f7 f7             	div    %r15
  8002ec:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002f0:	48 89 c2             	mov    %rax,%rdx
  8002f3:	48 b8 75 02 80 00 00 	movabs $0x800275,%rax
  8002fa:	00 00 00 
  8002fd:	ff d0                	callq  *%rax
  8002ff:	eb b0                	jmp    8002b1 <printnum+0x3c>

0000000000800301 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800301:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800305:	48 8b 06             	mov    (%rsi),%rax
  800308:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80030c:	73 0a                	jae    800318 <sprintputch+0x17>
    *b->buf++ = ch;
  80030e:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800312:	48 89 16             	mov    %rdx,(%rsi)
  800315:	40 88 38             	mov    %dil,(%rax)
}
  800318:	c3                   	retq   

0000000000800319 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800319:	55                   	push   %rbp
  80031a:	48 89 e5             	mov    %rsp,%rbp
  80031d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800324:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80032b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800332:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800339:	84 c0                	test   %al,%al
  80033b:	74 20                	je     80035d <printfmt+0x44>
  80033d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800341:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800345:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800349:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80034d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800351:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800355:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800359:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80035d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800364:	00 00 00 
  800367:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80036e:	00 00 00 
  800371:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800375:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80037c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800383:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80038a:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800391:	48 b8 9f 03 80 00 00 	movabs $0x80039f,%rax
  800398:	00 00 00 
  80039b:	ff d0                	callq  *%rax
}
  80039d:	c9                   	leaveq 
  80039e:	c3                   	retq   

000000000080039f <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80039f:	55                   	push   %rbp
  8003a0:	48 89 e5             	mov    %rsp,%rbp
  8003a3:	41 57                	push   %r15
  8003a5:	41 56                	push   %r14
  8003a7:	41 55                	push   %r13
  8003a9:	41 54                	push   %r12
  8003ab:	53                   	push   %rbx
  8003ac:	48 83 ec 48          	sub    $0x48,%rsp
  8003b0:	49 89 fd             	mov    %rdi,%r13
  8003b3:	49 89 f7             	mov    %rsi,%r15
  8003b6:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003b9:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003bd:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003c1:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003c5:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003c9:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003cd:	41 0f b6 3e          	movzbl (%r14),%edi
  8003d1:	83 ff 25             	cmp    $0x25,%edi
  8003d4:	74 18                	je     8003ee <vprintfmt+0x4f>
      if (ch == '\0')
  8003d6:	85 ff                	test   %edi,%edi
  8003d8:	0f 84 8c 06 00 00    	je     800a6a <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003de:	4c 89 fe             	mov    %r15,%rsi
  8003e1:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003e4:	49 89 de             	mov    %rbx,%r14
  8003e7:	eb e0                	jmp    8003c9 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003e9:	49 89 de             	mov    %rbx,%r14
  8003ec:	eb db                	jmp    8003c9 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003ee:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003f2:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003f6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003fd:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800403:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80040c:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800412:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800418:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80041d:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800422:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800426:	0f b6 13             	movzbl (%rbx),%edx
  800429:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80042c:	3c 55                	cmp    $0x55,%al
  80042e:	0f 87 8b 05 00 00    	ja     8009bf <vprintfmt+0x620>
  800434:	0f b6 c0             	movzbl %al,%eax
  800437:	49 bb 00 15 80 00 00 	movabs $0x801500,%r11
  80043e:	00 00 00 
  800441:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800445:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800448:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80044c:	eb d4                	jmp    800422 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80044e:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800451:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800455:	eb cb                	jmp    800422 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800457:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80045a:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80045e:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800462:	8d 50 d0             	lea    -0x30(%rax),%edx
  800465:	83 fa 09             	cmp    $0x9,%edx
  800468:	77 7e                	ja     8004e8 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80046a:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80046e:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800472:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800477:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80047b:	8d 50 d0             	lea    -0x30(%rax),%edx
  80047e:	83 fa 09             	cmp    $0x9,%edx
  800481:	76 e7                	jbe    80046a <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800483:	4c 89 f3             	mov    %r14,%rbx
  800486:	eb 19                	jmp    8004a1 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800488:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80048b:	83 f8 2f             	cmp    $0x2f,%eax
  80048e:	77 2a                	ja     8004ba <vprintfmt+0x11b>
  800490:	89 c2                	mov    %eax,%edx
  800492:	4c 01 d2             	add    %r10,%rdx
  800495:	83 c0 08             	add    $0x8,%eax
  800498:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80049b:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80049e:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004a1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004a5:	0f 89 77 ff ff ff    	jns    800422 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004ab:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004af:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004b5:	e9 68 ff ff ff       	jmpq   800422 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004ba:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004be:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004c6:	eb d3                	jmp    80049b <vprintfmt+0xfc>
        if (width < 0)
  8004c8:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004d1:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004d4:	4c 89 f3             	mov    %r14,%rbx
  8004d7:	e9 46 ff ff ff       	jmpq   800422 <vprintfmt+0x83>
  8004dc:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004df:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004e3:	e9 3a ff ff ff       	jmpq   800422 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004e8:	4c 89 f3             	mov    %r14,%rbx
  8004eb:	eb b4                	jmp    8004a1 <vprintfmt+0x102>
        lflag++;
  8004ed:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004f0:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004f3:	e9 2a ff ff ff       	jmpq   800422 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004f8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004fb:	83 f8 2f             	cmp    $0x2f,%eax
  8004fe:	77 19                	ja     800519 <vprintfmt+0x17a>
  800500:	89 c2                	mov    %eax,%edx
  800502:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800506:	83 c0 08             	add    $0x8,%eax
  800509:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80050c:	4c 89 fe             	mov    %r15,%rsi
  80050f:	8b 3a                	mov    (%rdx),%edi
  800511:	41 ff d5             	callq  *%r13
        break;
  800514:	e9 b0 fe ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800519:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80051d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800521:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800525:	eb e5                	jmp    80050c <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800527:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80052a:	83 f8 2f             	cmp    $0x2f,%eax
  80052d:	77 5b                	ja     80058a <vprintfmt+0x1eb>
  80052f:	89 c2                	mov    %eax,%edx
  800531:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800535:	83 c0 08             	add    $0x8,%eax
  800538:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80053b:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80053d:	89 c8                	mov    %ecx,%eax
  80053f:	c1 f8 1f             	sar    $0x1f,%eax
  800542:	31 c1                	xor    %eax,%ecx
  800544:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 f9 0b             	cmp    $0xb,%ecx
  800549:	7f 4d                	jg     800598 <vprintfmt+0x1f9>
  80054b:	48 63 c1             	movslq %ecx,%rax
  80054e:	48 ba c0 17 80 00 00 	movabs $0x8017c0,%rdx
  800555:	00 00 00 
  800558:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80055c:	48 85 c0             	test   %rax,%rax
  80055f:	74 37                	je     800598 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800561:	48 89 c1             	mov    %rax,%rcx
  800564:	48 ba 4f 14 80 00 00 	movabs $0x80144f,%rdx
  80056b:	00 00 00 
  80056e:	4c 89 fe             	mov    %r15,%rsi
  800571:	4c 89 ef             	mov    %r13,%rdi
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
  800579:	48 bb 19 03 80 00 00 	movabs $0x800319,%rbx
  800580:	00 00 00 
  800583:	ff d3                	callq  *%rbx
  800585:	e9 3f fe ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80058a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80058e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800592:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800596:	eb a3                	jmp    80053b <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800598:	48 ba 46 14 80 00 00 	movabs $0x801446,%rdx
  80059f:	00 00 00 
  8005a2:	4c 89 fe             	mov    %r15,%rsi
  8005a5:	4c 89 ef             	mov    %r13,%rdi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	48 bb 19 03 80 00 00 	movabs $0x800319,%rbx
  8005b4:	00 00 00 
  8005b7:	ff d3                	callq  *%rbx
  8005b9:	e9 0b fe ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005be:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005c1:	83 f8 2f             	cmp    $0x2f,%eax
  8005c4:	77 4b                	ja     800611 <vprintfmt+0x272>
  8005c6:	89 c2                	mov    %eax,%edx
  8005c8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005cc:	83 c0 08             	add    $0x8,%eax
  8005cf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d2:	48 8b 02             	mov    (%rdx),%rax
  8005d5:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005d9:	48 85 c0             	test   %rax,%rax
  8005dc:	0f 84 05 04 00 00    	je     8009e7 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005e2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005e6:	7e 06                	jle    8005ee <vprintfmt+0x24f>
  8005e8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005ec:	75 31                	jne    80061f <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ee:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005f2:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005f6:	0f b6 00             	movzbl (%rax),%eax
  8005f9:	0f be f8             	movsbl %al,%edi
  8005fc:	85 ff                	test   %edi,%edi
  8005fe:	0f 84 c3 00 00 00    	je     8006c7 <vprintfmt+0x328>
  800604:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800608:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80060c:	e9 85 00 00 00       	jmpq   800696 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800611:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800615:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800619:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80061d:	eb b3                	jmp    8005d2 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	49 63 f4             	movslq %r12d,%rsi
  800622:	48 89 c7             	mov    %rax,%rdi
  800625:	48 b8 76 0b 80 00 00 	movabs $0x800b76,%rax
  80062c:	00 00 00 
  80062f:	ff d0                	callq  *%rax
  800631:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800634:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800637:	85 f6                	test   %esi,%esi
  800639:	7e 22                	jle    80065d <vprintfmt+0x2be>
            putch(padc, putdat);
  80063b:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80063f:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800643:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800647:	4c 89 fe             	mov    %r15,%rsi
  80064a:	89 df                	mov    %ebx,%edi
  80064c:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	41 83 ec 01          	sub    $0x1,%r12d
  800653:	75 f2                	jne    800647 <vprintfmt+0x2a8>
  800655:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800659:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800661:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800665:	0f b6 00             	movzbl (%rax),%eax
  800668:	0f be f8             	movsbl %al,%edi
  80066b:	85 ff                	test   %edi,%edi
  80066d:	0f 84 56 fd ff ff    	je     8003c9 <vprintfmt+0x2a>
  800673:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800677:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80067b:	eb 19                	jmp    800696 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80067d:	4c 89 fe             	mov    %r15,%rsi
  800680:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800683:	41 83 ee 01          	sub    $0x1,%r14d
  800687:	48 83 c3 01          	add    $0x1,%rbx
  80068b:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80068f:	0f be f8             	movsbl %al,%edi
  800692:	85 ff                	test   %edi,%edi
  800694:	74 29                	je     8006bf <vprintfmt+0x320>
  800696:	45 85 e4             	test   %r12d,%r12d
  800699:	78 06                	js     8006a1 <vprintfmt+0x302>
  80069b:	41 83 ec 01          	sub    $0x1,%r12d
  80069f:	78 48                	js     8006e9 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006a1:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006a5:	74 d6                	je     80067d <vprintfmt+0x2de>
  8006a7:	0f be c0             	movsbl %al,%eax
  8006aa:	83 e8 20             	sub    $0x20,%eax
  8006ad:	83 f8 5e             	cmp    $0x5e,%eax
  8006b0:	76 cb                	jbe    80067d <vprintfmt+0x2de>
            putch('?', putdat);
  8006b2:	4c 89 fe             	mov    %r15,%rsi
  8006b5:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006ba:	41 ff d5             	callq  *%r13
  8006bd:	eb c4                	jmp    800683 <vprintfmt+0x2e4>
  8006bf:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006c3:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006c7:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006ca:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006ce:	0f 8e f5 fc ff ff    	jle    8003c9 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006d4:	4c 89 fe             	mov    %r15,%rsi
  8006d7:	bf 20 00 00 00       	mov    $0x20,%edi
  8006dc:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006df:	83 eb 01             	sub    $0x1,%ebx
  8006e2:	75 f0                	jne    8006d4 <vprintfmt+0x335>
  8006e4:	e9 e0 fc ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
  8006e9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006ed:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006f1:	eb d4                	jmp    8006c7 <vprintfmt+0x328>
  if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7f 1d                	jg     800715 <vprintfmt+0x376>
  else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 5e                	je     80075a <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006fc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006ff:	83 f8 2f             	cmp    $0x2f,%eax
  800702:	77 48                	ja     80074c <vprintfmt+0x3ad>
  800704:	89 c2                	mov    %eax,%edx
  800706:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80070a:	83 c0 08             	add    $0x8,%eax
  80070d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800710:	48 8b 1a             	mov    (%rdx),%rbx
  800713:	eb 17                	jmp    80072c <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800715:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800718:	83 f8 2f             	cmp    $0x2f,%eax
  80071b:	77 21                	ja     80073e <vprintfmt+0x39f>
  80071d:	89 c2                	mov    %eax,%edx
  80071f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800723:	83 c0 08             	add    $0x8,%eax
  800726:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800729:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80072c:	48 85 db             	test   %rbx,%rbx
  80072f:	78 50                	js     800781 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800731:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800734:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800739:	e9 b4 01 00 00       	jmpq   8008f2 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80073e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800742:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800746:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074a:	eb dd                	jmp    800729 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80074c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800750:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800754:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800758:	eb b6                	jmp    800710 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80075a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80075d:	83 f8 2f             	cmp    $0x2f,%eax
  800760:	77 11                	ja     800773 <vprintfmt+0x3d4>
  800762:	89 c2                	mov    %eax,%edx
  800764:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800768:	83 c0 08             	add    $0x8,%eax
  80076b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80076e:	48 63 1a             	movslq (%rdx),%rbx
  800771:	eb b9                	jmp    80072c <vprintfmt+0x38d>
  800773:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800777:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80077b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80077f:	eb ed                	jmp    80076e <vprintfmt+0x3cf>
          putch('-', putdat);
  800781:	4c 89 fe             	mov    %r15,%rsi
  800784:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800789:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80078c:	48 89 da             	mov    %rbx,%rdx
  80078f:	48 f7 da             	neg    %rdx
        base = 10;
  800792:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800797:	e9 56 01 00 00       	jmpq   8008f2 <vprintfmt+0x553>
  if (lflag >= 2)
  80079c:	83 f9 01             	cmp    $0x1,%ecx
  80079f:	7f 25                	jg     8007c6 <vprintfmt+0x427>
  else if (lflag)
  8007a1:	85 c9                	test   %ecx,%ecx
  8007a3:	74 5e                	je     800803 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007a5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007a8:	83 f8 2f             	cmp    $0x2f,%eax
  8007ab:	77 48                	ja     8007f5 <vprintfmt+0x456>
  8007ad:	89 c2                	mov    %eax,%edx
  8007af:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007b3:	83 c0 08             	add    $0x8,%eax
  8007b6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007b9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c1:	e9 2c 01 00 00       	jmpq   8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007c6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c9:	83 f8 2f             	cmp    $0x2f,%eax
  8007cc:	77 19                	ja     8007e7 <vprintfmt+0x448>
  8007ce:	89 c2                	mov    %eax,%edx
  8007d0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d4:	83 c0 08             	add    $0x8,%eax
  8007d7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007da:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e2:	e9 0b 01 00 00       	jmpq   8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007e7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007eb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ef:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f3:	eb e5                	jmp    8007da <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007f5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007f9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007fd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800801:	eb b6                	jmp    8007b9 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800803:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800806:	83 f8 2f             	cmp    $0x2f,%eax
  800809:	77 18                	ja     800823 <vprintfmt+0x484>
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800811:	83 c0 08             	add    $0x8,%eax
  800814:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800817:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800819:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081e:	e9 cf 00 00 00       	jmpq   8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800823:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800827:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80082b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80082f:	eb e6                	jmp    800817 <vprintfmt+0x478>
  if (lflag >= 2)
  800831:	83 f9 01             	cmp    $0x1,%ecx
  800834:	7f 25                	jg     80085b <vprintfmt+0x4bc>
  else if (lflag)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	74 5b                	je     800895 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80083a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80083d:	83 f8 2f             	cmp    $0x2f,%eax
  800840:	77 45                	ja     800887 <vprintfmt+0x4e8>
  800842:	89 c2                	mov    %eax,%edx
  800844:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800848:	83 c0 08             	add    $0x8,%eax
  80084b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80084e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800851:	b9 08 00 00 00       	mov    $0x8,%ecx
  800856:	e9 97 00 00 00       	jmpq   8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80085b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80085e:	83 f8 2f             	cmp    $0x2f,%eax
  800861:	77 16                	ja     800879 <vprintfmt+0x4da>
  800863:	89 c2                	mov    %eax,%edx
  800865:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800869:	83 c0 08             	add    $0x8,%eax
  80086c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80086f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800872:	b9 08 00 00 00       	mov    $0x8,%ecx
  800877:	eb 79                	jmp    8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800879:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800881:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800885:	eb e8                	jmp    80086f <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800887:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80088f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800893:	eb b9                	jmp    80084e <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800895:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800898:	83 f8 2f             	cmp    $0x2f,%eax
  80089b:	77 15                	ja     8008b2 <vprintfmt+0x513>
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a3:	83 c0 08             	add    $0x8,%eax
  8008a6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a9:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008ab:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008b0:	eb 40                	jmp    8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008b2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ba:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008be:	eb e9                	jmp    8008a9 <vprintfmt+0x50a>
        putch('0', putdat);
  8008c0:	4c 89 fe             	mov    %r15,%rsi
  8008c3:	bf 30 00 00 00       	mov    $0x30,%edi
  8008c8:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008cb:	4c 89 fe             	mov    %r15,%rsi
  8008ce:	bf 78 00 00 00       	mov    $0x78,%edi
  8008d3:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008d6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d9:	83 f8 2f             	cmp    $0x2f,%eax
  8008dc:	77 34                	ja     800912 <vprintfmt+0x573>
  8008de:	89 c2                	mov    %eax,%edx
  8008e0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e4:	83 c0 08             	add    $0x8,%eax
  8008e7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ea:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008ed:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008f2:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008f7:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008fb:	4c 89 fe             	mov    %r15,%rsi
  8008fe:	4c 89 ef             	mov    %r13,%rdi
  800901:	48 b8 75 02 80 00 00 	movabs $0x800275,%rax
  800908:	00 00 00 
  80090b:	ff d0                	callq  *%rax
        break;
  80090d:	e9 b7 fa ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800912:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800916:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091e:	eb ca                	jmp    8008ea <vprintfmt+0x54b>
  if (lflag >= 2)
  800920:	83 f9 01             	cmp    $0x1,%ecx
  800923:	7f 22                	jg     800947 <vprintfmt+0x5a8>
  else if (lflag)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 58                	je     800981 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800929:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092c:	83 f8 2f             	cmp    $0x2f,%eax
  80092f:	77 42                	ja     800973 <vprintfmt+0x5d4>
  800931:	89 c2                	mov    %eax,%edx
  800933:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800937:	83 c0 08             	add    $0x8,%eax
  80093a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800940:	b9 10 00 00 00       	mov    $0x10,%ecx
  800945:	eb ab                	jmp    8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800947:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094a:	83 f8 2f             	cmp    $0x2f,%eax
  80094d:	77 16                	ja     800965 <vprintfmt+0x5c6>
  80094f:	89 c2                	mov    %eax,%edx
  800951:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800955:	83 c0 08             	add    $0x8,%eax
  800958:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80095e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800963:	eb 8d                	jmp    8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800965:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800969:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800971:	eb e8                	jmp    80095b <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800973:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800977:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097f:	eb bc                	jmp    80093d <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800981:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800984:	83 f8 2f             	cmp    $0x2f,%eax
  800987:	77 18                	ja     8009a1 <vprintfmt+0x602>
  800989:	89 c2                	mov    %eax,%edx
  80098b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80098f:	83 c0 08             	add    $0x8,%eax
  800992:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800995:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800997:	b9 10 00 00 00       	mov    $0x10,%ecx
  80099c:	e9 51 ff ff ff       	jmpq   8008f2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ad:	eb e6                	jmp    800995 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009af:	4c 89 fe             	mov    %r15,%rsi
  8009b2:	bf 25 00 00 00       	mov    $0x25,%edi
  8009b7:	41 ff d5             	callq  *%r13
        break;
  8009ba:	e9 0a fa ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
        putch('%', putdat);
  8009bf:	4c 89 fe             	mov    %r15,%rsi
  8009c2:	bf 25 00 00 00       	mov    $0x25,%edi
  8009c7:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009ca:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009ce:	0f 84 15 fa ff ff    	je     8003e9 <vprintfmt+0x4a>
  8009d4:	49 89 de             	mov    %rbx,%r14
  8009d7:	49 83 ee 01          	sub    $0x1,%r14
  8009db:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009e0:	75 f5                	jne    8009d7 <vprintfmt+0x638>
  8009e2:	e9 e2 f9 ff ff       	jmpq   8003c9 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009e7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009eb:	74 06                	je     8009f3 <vprintfmt+0x654>
  8009ed:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009f1:	7f 21                	jg     800a14 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f3:	bf 28 00 00 00       	mov    $0x28,%edi
  8009f8:	48 bb 40 14 80 00 00 	movabs $0x801440,%rbx
  8009ff:	00 00 00 
  800a02:	b8 28 00 00 00       	mov    $0x28,%eax
  800a07:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a0b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a0f:	e9 82 fc ff ff       	jmpq   800696 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a14:	49 63 f4             	movslq %r12d,%rsi
  800a17:	48 bf 3f 14 80 00 00 	movabs $0x80143f,%rdi
  800a1e:	00 00 00 
  800a21:	48 b8 76 0b 80 00 00 	movabs $0x800b76,%rax
  800a28:	00 00 00 
  800a2b:	ff d0                	callq  *%rax
  800a2d:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a30:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a33:	48 be 3f 14 80 00 00 	movabs $0x80143f,%rsi
  800a3a:	00 00 00 
  800a3d:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a41:	85 c0                	test   %eax,%eax
  800a43:	0f 8f f2 fb ff ff    	jg     80063b <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a49:	48 bb 40 14 80 00 00 	movabs $0x801440,%rbx
  800a50:	00 00 00 
  800a53:	b8 28 00 00 00       	mov    $0x28,%eax
  800a58:	bf 28 00 00 00       	mov    $0x28,%edi
  800a5d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a61:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a65:	e9 2c fc ff ff       	jmpq   800696 <vprintfmt+0x2f7>
}
  800a6a:	48 83 c4 48          	add    $0x48,%rsp
  800a6e:	5b                   	pop    %rbx
  800a6f:	41 5c                	pop    %r12
  800a71:	41 5d                	pop    %r13
  800a73:	41 5e                	pop    %r14
  800a75:	41 5f                	pop    %r15
  800a77:	5d                   	pop    %rbp
  800a78:	c3                   	retq   

0000000000800a79 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a79:	55                   	push   %rbp
  800a7a:	48 89 e5             	mov    %rsp,%rbp
  800a7d:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a81:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a85:	48 63 c6             	movslq %esi,%rax
  800a88:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a8d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a98:	48 85 ff             	test   %rdi,%rdi
  800a9b:	74 2a                	je     800ac7 <vsnprintf+0x4e>
  800a9d:	85 f6                	test   %esi,%esi
  800a9f:	7e 26                	jle    800ac7 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800aa1:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800aa5:	48 bf 01 03 80 00 00 	movabs $0x800301,%rdi
  800aac:	00 00 00 
  800aaf:	48 b8 9f 03 80 00 00 	movabs $0x80039f,%rax
  800ab6:	00 00 00 
  800ab9:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800abb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800abf:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ac2:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ac5:	c9                   	leaveq 
  800ac6:	c3                   	retq   
    return -E_INVAL;
  800ac7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800acc:	eb f7                	jmp    800ac5 <vsnprintf+0x4c>

0000000000800ace <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ace:	55                   	push   %rbp
  800acf:	48 89 e5             	mov    %rsp,%rbp
  800ad2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ad9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ae0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ae7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800aee:	84 c0                	test   %al,%al
  800af0:	74 20                	je     800b12 <snprintf+0x44>
  800af2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800af6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800afa:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800afe:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b02:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b06:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b0a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b0e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b12:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b19:	00 00 00 
  800b1c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b23:	00 00 00 
  800b26:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b2a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b31:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b38:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b3f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b46:	48 b8 79 0a 80 00 00 	movabs $0x800a79,%rax
  800b4d:	00 00 00 
  800b50:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b52:	c9                   	leaveq 
  800b53:	c3                   	retq   

0000000000800b54 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b54:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b57:	74 17                	je     800b70 <strlen+0x1c>
  800b59:	48 89 fa             	mov    %rdi,%rdx
  800b5c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b61:	29 f9                	sub    %edi,%ecx
    n++;
  800b63:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b66:	48 83 c2 01          	add    $0x1,%rdx
  800b6a:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b6d:	75 f4                	jne    800b63 <strlen+0xf>
  800b6f:	c3                   	retq   
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b75:	c3                   	retq   

0000000000800b76 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b76:	48 85 f6             	test   %rsi,%rsi
  800b79:	74 24                	je     800b9f <strnlen+0x29>
  800b7b:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b7e:	74 25                	je     800ba5 <strnlen+0x2f>
  800b80:	48 01 fe             	add    %rdi,%rsi
  800b83:	48 89 fa             	mov    %rdi,%rdx
  800b86:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b8b:	29 f9                	sub    %edi,%ecx
    n++;
  800b8d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b90:	48 83 c2 01          	add    $0x1,%rdx
  800b94:	48 39 f2             	cmp    %rsi,%rdx
  800b97:	74 11                	je     800baa <strnlen+0x34>
  800b99:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b9c:	75 ef                	jne    800b8d <strnlen+0x17>
  800b9e:	c3                   	retq   
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	c3                   	retq   
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800baa:	c3                   	retq   

0000000000800bab <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800bab:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bb7:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bba:	48 83 c2 01          	add    $0x1,%rdx
  800bbe:	84 c9                	test   %cl,%cl
  800bc0:	75 f1                	jne    800bb3 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bc2:	c3                   	retq   

0000000000800bc3 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bc3:	55                   	push   %rbp
  800bc4:	48 89 e5             	mov    %rsp,%rbp
  800bc7:	41 54                	push   %r12
  800bc9:	53                   	push   %rbx
  800bca:	48 89 fb             	mov    %rdi,%rbx
  800bcd:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bd0:	48 b8 54 0b 80 00 00 	movabs $0x800b54,%rax
  800bd7:	00 00 00 
  800bda:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bdc:	48 63 f8             	movslq %eax,%rdi
  800bdf:	48 01 df             	add    %rbx,%rdi
  800be2:	4c 89 e6             	mov    %r12,%rsi
  800be5:	48 b8 ab 0b 80 00 00 	movabs $0x800bab,%rax
  800bec:	00 00 00 
  800bef:	ff d0                	callq  *%rax
  return dst;
}
  800bf1:	48 89 d8             	mov    %rbx,%rax
  800bf4:	5b                   	pop    %rbx
  800bf5:	41 5c                	pop    %r12
  800bf7:	5d                   	pop    %rbp
  800bf8:	c3                   	retq   

0000000000800bf9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf9:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bfc:	48 85 d2             	test   %rdx,%rdx
  800bff:	74 1f                	je     800c20 <strncpy+0x27>
  800c01:	48 01 fa             	add    %rdi,%rdx
  800c04:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c07:	48 83 c1 01          	add    $0x1,%rcx
  800c0b:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c0f:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c13:	41 80 f8 01          	cmp    $0x1,%r8b
  800c17:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c1b:	48 39 ca             	cmp    %rcx,%rdx
  800c1e:	75 e7                	jne    800c07 <strncpy+0xe>
  }
  return ret;
}
  800c20:	c3                   	retq   

0000000000800c21 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c21:	48 89 f8             	mov    %rdi,%rax
  800c24:	48 85 d2             	test   %rdx,%rdx
  800c27:	74 36                	je     800c5f <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c29:	48 83 fa 01          	cmp    $0x1,%rdx
  800c2d:	74 2d                	je     800c5c <strlcpy+0x3b>
  800c2f:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c33:	45 84 c0             	test   %r8b,%r8b
  800c36:	74 24                	je     800c5c <strlcpy+0x3b>
  800c38:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c3c:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c41:	48 83 c0 01          	add    $0x1,%rax
  800c45:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c49:	48 39 d1             	cmp    %rdx,%rcx
  800c4c:	74 0e                	je     800c5c <strlcpy+0x3b>
  800c4e:	48 83 c1 01          	add    $0x1,%rcx
  800c52:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c57:	45 84 c0             	test   %r8b,%r8b
  800c5a:	75 e5                	jne    800c41 <strlcpy+0x20>
    *dst = '\0';
  800c5c:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c5f:	48 29 f8             	sub    %rdi,%rax
}
  800c62:	c3                   	retq   

0000000000800c63 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c63:	0f b6 07             	movzbl (%rdi),%eax
  800c66:	84 c0                	test   %al,%al
  800c68:	74 17                	je     800c81 <strcmp+0x1e>
  800c6a:	3a 06                	cmp    (%rsi),%al
  800c6c:	75 13                	jne    800c81 <strcmp+0x1e>
    p++, q++;
  800c6e:	48 83 c7 01          	add    $0x1,%rdi
  800c72:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c76:	0f b6 07             	movzbl (%rdi),%eax
  800c79:	84 c0                	test   %al,%al
  800c7b:	74 04                	je     800c81 <strcmp+0x1e>
  800c7d:	3a 06                	cmp    (%rsi),%al
  800c7f:	74 ed                	je     800c6e <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c81:	0f b6 c0             	movzbl %al,%eax
  800c84:	0f b6 16             	movzbl (%rsi),%edx
  800c87:	29 d0                	sub    %edx,%eax
}
  800c89:	c3                   	retq   

0000000000800c8a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c8a:	48 85 d2             	test   %rdx,%rdx
  800c8d:	74 2f                	je     800cbe <strncmp+0x34>
  800c8f:	0f b6 07             	movzbl (%rdi),%eax
  800c92:	84 c0                	test   %al,%al
  800c94:	74 1f                	je     800cb5 <strncmp+0x2b>
  800c96:	3a 06                	cmp    (%rsi),%al
  800c98:	75 1b                	jne    800cb5 <strncmp+0x2b>
  800c9a:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c9d:	48 83 c7 01          	add    $0x1,%rdi
  800ca1:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ca5:	48 39 d7             	cmp    %rdx,%rdi
  800ca8:	74 1a                	je     800cc4 <strncmp+0x3a>
  800caa:	0f b6 07             	movzbl (%rdi),%eax
  800cad:	84 c0                	test   %al,%al
  800caf:	74 04                	je     800cb5 <strncmp+0x2b>
  800cb1:	3a 06                	cmp    (%rsi),%al
  800cb3:	74 e8                	je     800c9d <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800cb5:	0f b6 07             	movzbl (%rdi),%eax
  800cb8:	0f b6 16             	movzbl (%rsi),%edx
  800cbb:	29 d0                	sub    %edx,%eax
}
  800cbd:	c3                   	retq   
    return 0;
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc3:	c3                   	retq   
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc9:	c3                   	retq   

0000000000800cca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cca:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ccc:	0f b6 07             	movzbl (%rdi),%eax
  800ccf:	84 c0                	test   %al,%al
  800cd1:	74 1e                	je     800cf1 <strchr+0x27>
    if (*s == c)
  800cd3:	40 38 c6             	cmp    %al,%sil
  800cd6:	74 1f                	je     800cf7 <strchr+0x2d>
  for (; *s; s++)
  800cd8:	48 83 c7 01          	add    $0x1,%rdi
  800cdc:	0f b6 07             	movzbl (%rdi),%eax
  800cdf:	84 c0                	test   %al,%al
  800ce1:	74 08                	je     800ceb <strchr+0x21>
    if (*s == c)
  800ce3:	38 d0                	cmp    %dl,%al
  800ce5:	75 f1                	jne    800cd8 <strchr+0xe>
  for (; *s; s++)
  800ce7:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cea:	c3                   	retq   
  return 0;
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf0:	c3                   	retq   
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	c3                   	retq   
    if (*s == c)
  800cf7:	48 89 f8             	mov    %rdi,%rax
  800cfa:	c3                   	retq   

0000000000800cfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cfb:	48 89 f8             	mov    %rdi,%rax
  800cfe:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d00:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d03:	40 38 f2             	cmp    %sil,%dl
  800d06:	74 13                	je     800d1b <strfind+0x20>
  800d08:	84 d2                	test   %dl,%dl
  800d0a:	74 0f                	je     800d1b <strfind+0x20>
  for (; *s; s++)
  800d0c:	48 83 c0 01          	add    $0x1,%rax
  800d10:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d13:	38 ca                	cmp    %cl,%dl
  800d15:	74 04                	je     800d1b <strfind+0x20>
  800d17:	84 d2                	test   %dl,%dl
  800d19:	75 f1                	jne    800d0c <strfind+0x11>
      break;
  return (char *)s;
}
  800d1b:	c3                   	retq   

0000000000800d1c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d1c:	48 85 d2             	test   %rdx,%rdx
  800d1f:	74 3a                	je     800d5b <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d21:	48 89 f8             	mov    %rdi,%rax
  800d24:	48 09 d0             	or     %rdx,%rax
  800d27:	a8 03                	test   $0x3,%al
  800d29:	75 28                	jne    800d53 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d2b:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	c1 e0 08             	shl    $0x8,%eax
  800d34:	89 f1                	mov    %esi,%ecx
  800d36:	c1 e1 18             	shl    $0x18,%ecx
  800d39:	41 89 f0             	mov    %esi,%r8d
  800d3c:	41 c1 e0 10          	shl    $0x10,%r8d
  800d40:	44 09 c1             	or     %r8d,%ecx
  800d43:	09 ce                	or     %ecx,%esi
  800d45:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d47:	48 c1 ea 02          	shr    $0x2,%rdx
  800d4b:	48 89 d1             	mov    %rdx,%rcx
  800d4e:	fc                   	cld    
  800d4f:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d51:	eb 08                	jmp    800d5b <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d53:	89 f0                	mov    %esi,%eax
  800d55:	48 89 d1             	mov    %rdx,%rcx
  800d58:	fc                   	cld    
  800d59:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d5b:	48 89 f8             	mov    %rdi,%rax
  800d5e:	c3                   	retq   

0000000000800d5f <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d5f:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d62:	48 39 fe             	cmp    %rdi,%rsi
  800d65:	73 40                	jae    800da7 <memmove+0x48>
  800d67:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d6b:	48 39 f9             	cmp    %rdi,%rcx
  800d6e:	76 37                	jbe    800da7 <memmove+0x48>
    s += n;
    d += n;
  800d70:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d74:	48 89 fe             	mov    %rdi,%rsi
  800d77:	48 09 d6             	or     %rdx,%rsi
  800d7a:	48 09 ce             	or     %rcx,%rsi
  800d7d:	40 f6 c6 03          	test   $0x3,%sil
  800d81:	75 14                	jne    800d97 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d83:	48 83 ef 04          	sub    $0x4,%rdi
  800d87:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d8b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d8f:	48 89 d1             	mov    %rdx,%rcx
  800d92:	fd                   	std    
  800d93:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d95:	eb 0e                	jmp    800da5 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d97:	48 83 ef 01          	sub    $0x1,%rdi
  800d9b:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d9f:	48 89 d1             	mov    %rdx,%rcx
  800da2:	fd                   	std    
  800da3:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800da5:	fc                   	cld    
  800da6:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800da7:	48 89 c1             	mov    %rax,%rcx
  800daa:	48 09 d1             	or     %rdx,%rcx
  800dad:	48 09 f1             	or     %rsi,%rcx
  800db0:	f6 c1 03             	test   $0x3,%cl
  800db3:	75 0e                	jne    800dc3 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800db5:	48 c1 ea 02          	shr    $0x2,%rdx
  800db9:	48 89 d1             	mov    %rdx,%rcx
  800dbc:	48 89 c7             	mov    %rax,%rdi
  800dbf:	fc                   	cld    
  800dc0:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dc2:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800dc3:	48 89 c7             	mov    %rax,%rdi
  800dc6:	48 89 d1             	mov    %rdx,%rcx
  800dc9:	fc                   	cld    
  800dca:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dcc:	c3                   	retq   

0000000000800dcd <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dcd:	55                   	push   %rbp
  800dce:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dd1:	48 b8 5f 0d 80 00 00 	movabs $0x800d5f,%rax
  800dd8:	00 00 00 
  800ddb:	ff d0                	callq  *%rax
}
  800ddd:	5d                   	pop    %rbp
  800dde:	c3                   	retq   

0000000000800ddf <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800ddf:	55                   	push   %rbp
  800de0:	48 89 e5             	mov    %rsp,%rbp
  800de3:	41 57                	push   %r15
  800de5:	41 56                	push   %r14
  800de7:	41 55                	push   %r13
  800de9:	41 54                	push   %r12
  800deb:	53                   	push   %rbx
  800dec:	48 83 ec 08          	sub    $0x8,%rsp
  800df0:	49 89 fe             	mov    %rdi,%r14
  800df3:	49 89 f7             	mov    %rsi,%r15
  800df6:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800df9:	48 89 f7             	mov    %rsi,%rdi
  800dfc:	48 b8 54 0b 80 00 00 	movabs $0x800b54,%rax
  800e03:	00 00 00 
  800e06:	ff d0                	callq  *%rax
  800e08:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e0b:	4c 89 ee             	mov    %r13,%rsi
  800e0e:	4c 89 f7             	mov    %r14,%rdi
  800e11:	48 b8 76 0b 80 00 00 	movabs $0x800b76,%rax
  800e18:	00 00 00 
  800e1b:	ff d0                	callq  *%rax
  800e1d:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e20:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e24:	4d 39 e5             	cmp    %r12,%r13
  800e27:	74 26                	je     800e4f <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e29:	4c 89 e8             	mov    %r13,%rax
  800e2c:	4c 29 e0             	sub    %r12,%rax
  800e2f:	48 39 d8             	cmp    %rbx,%rax
  800e32:	76 2a                	jbe    800e5e <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e34:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e38:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e3c:	4c 89 fe             	mov    %r15,%rsi
  800e3f:	48 b8 cd 0d 80 00 00 	movabs $0x800dcd,%rax
  800e46:	00 00 00 
  800e49:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e4b:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e4f:	48 83 c4 08          	add    $0x8,%rsp
  800e53:	5b                   	pop    %rbx
  800e54:	41 5c                	pop    %r12
  800e56:	41 5d                	pop    %r13
  800e58:	41 5e                	pop    %r14
  800e5a:	41 5f                	pop    %r15
  800e5c:	5d                   	pop    %rbp
  800e5d:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e5e:	49 83 ed 01          	sub    $0x1,%r13
  800e62:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e66:	4c 89 ea             	mov    %r13,%rdx
  800e69:	4c 89 fe             	mov    %r15,%rsi
  800e6c:	48 b8 cd 0d 80 00 00 	movabs $0x800dcd,%rax
  800e73:	00 00 00 
  800e76:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e78:	4d 01 ee             	add    %r13,%r14
  800e7b:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e80:	eb c9                	jmp    800e4b <strlcat+0x6c>

0000000000800e82 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e82:	48 85 d2             	test   %rdx,%rdx
  800e85:	74 3a                	je     800ec1 <memcmp+0x3f>
    if (*s1 != *s2)
  800e87:	0f b6 0f             	movzbl (%rdi),%ecx
  800e8a:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e8e:	44 38 c1             	cmp    %r8b,%cl
  800e91:	75 1d                	jne    800eb0 <memcmp+0x2e>
  800e93:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e98:	48 39 d0             	cmp    %rdx,%rax
  800e9b:	74 1e                	je     800ebb <memcmp+0x39>
    if (*s1 != *s2)
  800e9d:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ea1:	48 83 c0 01          	add    $0x1,%rax
  800ea5:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800eab:	44 38 c1             	cmp    %r8b,%cl
  800eae:	74 e8                	je     800e98 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800eb0:	0f b6 c1             	movzbl %cl,%eax
  800eb3:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eb7:	44 29 c0             	sub    %r8d,%eax
  800eba:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	c3                   	retq   
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec6:	c3                   	retq   

0000000000800ec7 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800ec7:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ecb:	48 39 c7             	cmp    %rax,%rdi
  800ece:	73 19                	jae    800ee9 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed0:	89 f2                	mov    %esi,%edx
  800ed2:	40 38 37             	cmp    %sil,(%rdi)
  800ed5:	74 16                	je     800eed <memfind+0x26>
  for (; s < ends; s++)
  800ed7:	48 83 c7 01          	add    $0x1,%rdi
  800edb:	48 39 f8             	cmp    %rdi,%rax
  800ede:	74 08                	je     800ee8 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee0:	38 17                	cmp    %dl,(%rdi)
  800ee2:	75 f3                	jne    800ed7 <memfind+0x10>
  for (; s < ends; s++)
  800ee4:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ee7:	c3                   	retq   
  800ee8:	c3                   	retq   
  for (; s < ends; s++)
  800ee9:	48 89 f8             	mov    %rdi,%rax
  800eec:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800eed:	48 89 f8             	mov    %rdi,%rax
  800ef0:	c3                   	retq   

0000000000800ef1 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ef1:	0f b6 07             	movzbl (%rdi),%eax
  800ef4:	3c 20                	cmp    $0x20,%al
  800ef6:	74 04                	je     800efc <strtol+0xb>
  800ef8:	3c 09                	cmp    $0x9,%al
  800efa:	75 0f                	jne    800f0b <strtol+0x1a>
    s++;
  800efc:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f00:	0f b6 07             	movzbl (%rdi),%eax
  800f03:	3c 20                	cmp    $0x20,%al
  800f05:	74 f5                	je     800efc <strtol+0xb>
  800f07:	3c 09                	cmp    $0x9,%al
  800f09:	74 f1                	je     800efc <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f0b:	3c 2b                	cmp    $0x2b,%al
  800f0d:	74 2b                	je     800f3a <strtol+0x49>
  int neg  = 0;
  800f0f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f15:	3c 2d                	cmp    $0x2d,%al
  800f17:	74 2d                	je     800f46 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f19:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f1f:	75 0f                	jne    800f30 <strtol+0x3f>
  800f21:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f24:	74 2c                	je     800f52 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f26:	85 d2                	test   %edx,%edx
  800f28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2d:	0f 44 d0             	cmove  %eax,%edx
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f35:	4c 63 d2             	movslq %edx,%r10
  800f38:	eb 5c                	jmp    800f96 <strtol+0xa5>
    s++;
  800f3a:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f3e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f44:	eb d3                	jmp    800f19 <strtol+0x28>
    s++, neg = 1;
  800f46:	48 83 c7 01          	add    $0x1,%rdi
  800f4a:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f50:	eb c7                	jmp    800f19 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f52:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f56:	74 0f                	je     800f67 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f58:	85 d2                	test   %edx,%edx
  800f5a:	75 d4                	jne    800f30 <strtol+0x3f>
    s++, base = 8;
  800f5c:	48 83 c7 01          	add    $0x1,%rdi
  800f60:	ba 08 00 00 00       	mov    $0x8,%edx
  800f65:	eb c9                	jmp    800f30 <strtol+0x3f>
    s += 2, base = 16;
  800f67:	48 83 c7 02          	add    $0x2,%rdi
  800f6b:	ba 10 00 00 00       	mov    $0x10,%edx
  800f70:	eb be                	jmp    800f30 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f72:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f76:	41 80 f8 19          	cmp    $0x19,%r8b
  800f7a:	77 2f                	ja     800fab <strtol+0xba>
      dig = *s - 'a' + 10;
  800f7c:	44 0f be c1          	movsbl %cl,%r8d
  800f80:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f84:	39 d1                	cmp    %edx,%ecx
  800f86:	7d 37                	jge    800fbf <strtol+0xce>
    s++, val = (val * base) + dig;
  800f88:	48 83 c7 01          	add    $0x1,%rdi
  800f8c:	49 0f af c2          	imul   %r10,%rax
  800f90:	48 63 c9             	movslq %ecx,%rcx
  800f93:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f96:	0f b6 0f             	movzbl (%rdi),%ecx
  800f99:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f9d:	41 80 f8 09          	cmp    $0x9,%r8b
  800fa1:	77 cf                	ja     800f72 <strtol+0x81>
      dig = *s - '0';
  800fa3:	0f be c9             	movsbl %cl,%ecx
  800fa6:	83 e9 30             	sub    $0x30,%ecx
  800fa9:	eb d9                	jmp    800f84 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fab:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800faf:	41 80 f8 19          	cmp    $0x19,%r8b
  800fb3:	77 0a                	ja     800fbf <strtol+0xce>
      dig = *s - 'A' + 10;
  800fb5:	44 0f be c1          	movsbl %cl,%r8d
  800fb9:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fbd:	eb c5                	jmp    800f84 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fbf:	48 85 f6             	test   %rsi,%rsi
  800fc2:	74 03                	je     800fc7 <strtol+0xd6>
    *endptr = (char *)s;
  800fc4:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fc7:	48 89 c2             	mov    %rax,%rdx
  800fca:	48 f7 da             	neg    %rdx
  800fcd:	45 85 c9             	test   %r9d,%r9d
  800fd0:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fd4:	c3                   	retq   

0000000000800fd5 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fd5:	55                   	push   %rbp
  800fd6:	48 89 e5             	mov    %rsp,%rbp
  800fd9:	53                   	push   %rbx
  800fda:	48 89 fa             	mov    %rdi,%rdx
  800fdd:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	48 89 c3             	mov    %rax,%rbx
  800fe8:	48 89 c7             	mov    %rax,%rdi
  800feb:	48 89 c6             	mov    %rax,%rsi
  800fee:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800ff0:	5b                   	pop    %rbx
  800ff1:	5d                   	pop    %rbp
  800ff2:	c3                   	retq   

0000000000800ff3 <sys_cgetc>:

int
sys_cgetc(void) {
  800ff3:	55                   	push   %rbp
  800ff4:	48 89 e5             	mov    %rsp,%rbp
  800ff7:	53                   	push   %rbx
  asm volatile("int %1\n"
  800ff8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  801002:	48 89 ca             	mov    %rcx,%rdx
  801005:	48 89 cb             	mov    %rcx,%rbx
  801008:	48 89 cf             	mov    %rcx,%rdi
  80100b:	48 89 ce             	mov    %rcx,%rsi
  80100e:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801010:	5b                   	pop    %rbx
  801011:	5d                   	pop    %rbp
  801012:	c3                   	retq   

0000000000801013 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801013:	55                   	push   %rbp
  801014:	48 89 e5             	mov    %rsp,%rbp
  801017:	53                   	push   %rbx
  801018:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80101c:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80101f:	be 00 00 00 00       	mov    $0x0,%esi
  801024:	b8 03 00 00 00       	mov    $0x3,%eax
  801029:	48 89 f1             	mov    %rsi,%rcx
  80102c:	48 89 f3             	mov    %rsi,%rbx
  80102f:	48 89 f7             	mov    %rsi,%rdi
  801032:	cd 30                	int    $0x30
  if (check && ret > 0)
  801034:	48 85 c0             	test   %rax,%rax
  801037:	7f 07                	jg     801040 <sys_env_destroy+0x2d>
}
  801039:	48 83 c4 08          	add    $0x8,%rsp
  80103d:	5b                   	pop    %rbx
  80103e:	5d                   	pop    %rbp
  80103f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801040:	49 89 c0             	mov    %rax,%r8
  801043:	b9 03 00 00 00       	mov    $0x3,%ecx
  801048:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  80104f:	00 00 00 
  801052:	be 22 00 00 00       	mov    $0x22,%esi
  801057:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  80105e:	00 00 00 
  801061:	b8 00 00 00 00       	mov    $0x0,%eax
  801066:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  80106d:	00 00 00 
  801070:	41 ff d1             	callq  *%r9

0000000000801073 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801073:	55                   	push   %rbp
  801074:	48 89 e5             	mov    %rsp,%rbp
  801077:	53                   	push   %rbx
  asm volatile("int %1\n"
  801078:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107d:	b8 02 00 00 00       	mov    $0x2,%eax
  801082:	48 89 ca             	mov    %rcx,%rdx
  801085:	48 89 cb             	mov    %rcx,%rbx
  801088:	48 89 cf             	mov    %rcx,%rdi
  80108b:	48 89 ce             	mov    %rcx,%rsi
  80108e:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801090:	5b                   	pop    %rbx
  801091:	5d                   	pop    %rbp
  801092:	c3                   	retq   

0000000000801093 <sys_yield>:

void
sys_yield(void) {
  801093:	55                   	push   %rbp
  801094:	48 89 e5             	mov    %rsp,%rbp
  801097:	53                   	push   %rbx
  asm volatile("int %1\n"
  801098:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a2:	48 89 ca             	mov    %rcx,%rdx
  8010a5:	48 89 cb             	mov    %rcx,%rbx
  8010a8:	48 89 cf             	mov    %rcx,%rdi
  8010ab:	48 89 ce             	mov    %rcx,%rsi
  8010ae:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010b0:	5b                   	pop    %rbx
  8010b1:	5d                   	pop    %rbp
  8010b2:	c3                   	retq   

00000000008010b3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010b3:	55                   	push   %rbp
  8010b4:	48 89 e5             	mov    %rsp,%rbp
  8010b7:	53                   	push   %rbx
  8010b8:	48 83 ec 08          	sub    $0x8,%rsp
  8010bc:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010bf:	4c 63 c7             	movslq %edi,%r8
  8010c2:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010c5:	be 00 00 00 00       	mov    $0x0,%esi
  8010ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8010cf:	4c 89 c2             	mov    %r8,%rdx
  8010d2:	48 89 f7             	mov    %rsi,%rdi
  8010d5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010d7:	48 85 c0             	test   %rax,%rax
  8010da:	7f 07                	jg     8010e3 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8010dc:	48 83 c4 08          	add    $0x8,%rsp
  8010e0:	5b                   	pop    %rbx
  8010e1:	5d                   	pop    %rbp
  8010e2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010e3:	49 89 c0             	mov    %rax,%r8
  8010e6:	b9 04 00 00 00       	mov    $0x4,%ecx
  8010eb:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  8010f2:	00 00 00 
  8010f5:	be 22 00 00 00       	mov    $0x22,%esi
  8010fa:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801101:	00 00 00 
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
  801109:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  801110:	00 00 00 
  801113:	41 ff d1             	callq  *%r9

0000000000801116 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801116:	55                   	push   %rbp
  801117:	48 89 e5             	mov    %rsp,%rbp
  80111a:	53                   	push   %rbx
  80111b:	48 83 ec 08          	sub    $0x8,%rsp
  80111f:	41 89 f9             	mov    %edi,%r9d
  801122:	49 89 f2             	mov    %rsi,%r10
  801125:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801128:	4d 63 c9             	movslq %r9d,%r9
  80112b:	48 63 da             	movslq %edx,%rbx
  80112e:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801131:	b8 05 00 00 00       	mov    $0x5,%eax
  801136:	4c 89 ca             	mov    %r9,%rdx
  801139:	4c 89 d1             	mov    %r10,%rcx
  80113c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80113e:	48 85 c0             	test   %rax,%rax
  801141:	7f 07                	jg     80114a <sys_page_map+0x34>
}
  801143:	48 83 c4 08          	add    $0x8,%rsp
  801147:	5b                   	pop    %rbx
  801148:	5d                   	pop    %rbp
  801149:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80114a:	49 89 c0             	mov    %rax,%r8
  80114d:	b9 05 00 00 00       	mov    $0x5,%ecx
  801152:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  801159:	00 00 00 
  80115c:	be 22 00 00 00       	mov    $0x22,%esi
  801161:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801168:	00 00 00 
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  801177:	00 00 00 
  80117a:	41 ff d1             	callq  *%r9

000000000080117d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80117d:	55                   	push   %rbp
  80117e:	48 89 e5             	mov    %rsp,%rbp
  801181:	53                   	push   %rbx
  801182:	48 83 ec 08          	sub    $0x8,%rsp
  801186:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801189:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80118c:	be 00 00 00 00       	mov    $0x0,%esi
  801191:	b8 06 00 00 00       	mov    $0x6,%eax
  801196:	48 89 f3             	mov    %rsi,%rbx
  801199:	48 89 f7             	mov    %rsi,%rdi
  80119c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80119e:	48 85 c0             	test   %rax,%rax
  8011a1:	7f 07                	jg     8011aa <sys_page_unmap+0x2d>
}
  8011a3:	48 83 c4 08          	add    $0x8,%rsp
  8011a7:	5b                   	pop    %rbx
  8011a8:	5d                   	pop    %rbp
  8011a9:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011aa:	49 89 c0             	mov    %rax,%r8
  8011ad:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011b2:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  8011b9:	00 00 00 
  8011bc:	be 22 00 00 00       	mov    $0x22,%esi
  8011c1:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  8011c8:	00 00 00 
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  8011d7:	00 00 00 
  8011da:	41 ff d1             	callq  *%r9

00000000008011dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8011dd:	55                   	push   %rbp
  8011de:	48 89 e5             	mov    %rsp,%rbp
  8011e1:	53                   	push   %rbx
  8011e2:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011e6:	48 63 d7             	movslq %edi,%rdx
  8011e9:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8011ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8011f6:	48 89 df             	mov    %rbx,%rdi
  8011f9:	48 89 de             	mov    %rbx,%rsi
  8011fc:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011fe:	48 85 c0             	test   %rax,%rax
  801201:	7f 07                	jg     80120a <sys_env_set_status+0x2d>
}
  801203:	48 83 c4 08          	add    $0x8,%rsp
  801207:	5b                   	pop    %rbx
  801208:	5d                   	pop    %rbp
  801209:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80120a:	49 89 c0             	mov    %rax,%r8
  80120d:	b9 08 00 00 00       	mov    $0x8,%ecx
  801212:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  801219:	00 00 00 
  80121c:	be 22 00 00 00       	mov    $0x22,%esi
  801221:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801228:	00 00 00 
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
  801230:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  801237:	00 00 00 
  80123a:	41 ff d1             	callq  *%r9

000000000080123d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80123d:	55                   	push   %rbp
  80123e:	48 89 e5             	mov    %rsp,%rbp
  801241:	53                   	push   %rbx
  801242:	48 83 ec 08          	sub    $0x8,%rsp
  801246:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801249:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80124c:	be 00 00 00 00       	mov    $0x0,%esi
  801251:	b8 09 00 00 00       	mov    $0x9,%eax
  801256:	48 89 f3             	mov    %rsi,%rbx
  801259:	48 89 f7             	mov    %rsi,%rdi
  80125c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80125e:	48 85 c0             	test   %rax,%rax
  801261:	7f 07                	jg     80126a <sys_env_set_pgfault_upcall+0x2d>
}
  801263:	48 83 c4 08          	add    $0x8,%rsp
  801267:	5b                   	pop    %rbx
  801268:	5d                   	pop    %rbp
  801269:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80126a:	49 89 c0             	mov    %rax,%r8
  80126d:	b9 09 00 00 00       	mov    $0x9,%ecx
  801272:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  801279:	00 00 00 
  80127c:	be 22 00 00 00       	mov    $0x22,%esi
  801281:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801288:	00 00 00 
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  801297:	00 00 00 
  80129a:	41 ff d1             	callq  *%r9

000000000080129d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80129d:	55                   	push   %rbp
  80129e:	48 89 e5             	mov    %rsp,%rbp
  8012a1:	53                   	push   %rbx
  8012a2:	49 89 f0             	mov    %rsi,%r8
  8012a5:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8012a8:	48 63 d7             	movslq %edi,%rdx
  8012ab:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8012ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012b3:	be 00 00 00 00       	mov    $0x0,%esi
  8012b8:	4c 89 c1             	mov    %r8,%rcx
  8012bb:	cd 30                	int    $0x30
}
  8012bd:	5b                   	pop    %rbx
  8012be:	5d                   	pop    %rbp
  8012bf:	c3                   	retq   

00000000008012c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012c0:	55                   	push   %rbp
  8012c1:	48 89 e5             	mov    %rsp,%rbp
  8012c4:	53                   	push   %rbx
  8012c5:	48 83 ec 08          	sub    $0x8,%rsp
  8012c9:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012cc:	be 00 00 00 00       	mov    $0x0,%esi
  8012d1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012d6:	48 89 f1             	mov    %rsi,%rcx
  8012d9:	48 89 f3             	mov    %rsi,%rbx
  8012dc:	48 89 f7             	mov    %rsi,%rdi
  8012df:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012e1:	48 85 c0             	test   %rax,%rax
  8012e4:	7f 07                	jg     8012ed <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8012e6:	48 83 c4 08          	add    $0x8,%rsp
  8012ea:	5b                   	pop    %rbx
  8012eb:	5d                   	pop    %rbp
  8012ec:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012ed:	49 89 c0             	mov    %rax,%r8
  8012f0:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8012f5:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  8012fc:	00 00 00 
  8012ff:	be 22 00 00 00       	mov    $0x22,%esi
  801304:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  80130b:	00 00 00 
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	49 b9 20 13 80 00 00 	movabs $0x801320,%r9
  80131a:	00 00 00 
  80131d:	41 ff d1             	callq  *%r9

0000000000801320 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801320:	55                   	push   %rbp
  801321:	48 89 e5             	mov    %rsp,%rbp
  801324:	41 56                	push   %r14
  801326:	41 55                	push   %r13
  801328:	41 54                	push   %r12
  80132a:	53                   	push   %rbx
  80132b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801332:	49 89 fd             	mov    %rdi,%r13
  801335:	41 89 f6             	mov    %esi,%r14d
  801338:	49 89 d4             	mov    %rdx,%r12
  80133b:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801342:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801349:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801350:	84 c0                	test   %al,%al
  801352:	74 26                	je     80137a <_panic+0x5a>
  801354:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80135b:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801362:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801366:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80136a:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80136e:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801372:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801376:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80137a:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801381:	00 00 00 
  801384:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80138b:	00 00 00 
  80138e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801392:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801399:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8013a0:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8013a7:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8013ae:	00 00 00 
  8013b1:	48 8b 18             	mov    (%rax),%rbx
  8013b4:	48 b8 73 10 80 00 00 	movabs $0x801073,%rax
  8013bb:	00 00 00 
  8013be:	ff d0                	callq  *%rax
  8013c0:	45 89 f0             	mov    %r14d,%r8d
  8013c3:	4c 89 e9             	mov    %r13,%rcx
  8013c6:	48 89 da             	mov    %rbx,%rdx
  8013c9:	89 c6                	mov    %eax,%esi
  8013cb:	48 bf 50 18 80 00 00 	movabs $0x801850,%rdi
  8013d2:	00 00 00 
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	48 bb e1 01 80 00 00 	movabs $0x8001e1,%rbx
  8013e1:	00 00 00 
  8013e4:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8013e6:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8013ed:	4c 89 e7             	mov    %r12,%rdi
  8013f0:	48 b8 79 01 80 00 00 	movabs $0x800179,%rax
  8013f7:	00 00 00 
  8013fa:	ff d0                	callq  *%rax
  cprintf("\n");
  8013fc:	48 bf 22 14 80 00 00 	movabs $0x801422,%rdi
  801403:	00 00 00 
  801406:	b8 00 00 00 00       	mov    $0x0,%eax
  80140b:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80140d:	cc                   	int3   
  while (1)
  80140e:	eb fd                	jmp    80140d <_panic+0xed>
