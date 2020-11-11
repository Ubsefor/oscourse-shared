
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
  80003a:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  800041:	00 00 00 
  800044:	b8 00 00 00 00       	mov    $0x0,%eax
  800049:	48 ba a6 01 80 00 00 	movabs $0x8001a6,%rdx
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

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000a4:	45 85 ed             	test   %r13d,%r13d
  8000a7:	7e 0d                	jle    8000b6 <libmain+0x5f>
    binaryname = argv[0];
  8000a9:	49 8b 06             	mov    (%r14),%rax
  8000ac:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000b3:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000b6:	4c 89 f6             	mov    %r14,%rsi
  8000b9:	44 89 ef             	mov    %r13d,%edi
  8000bc:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000c3:	00 00 00 
  8000c6:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000c8:	48 b8 dd 00 80 00 00 	movabs $0x8000dd,%rax
  8000cf:	00 00 00 
  8000d2:	ff d0                	callq  *%rax
#endif
}
  8000d4:	5b                   	pop    %rbx
  8000d5:	41 5c                	pop    %r12
  8000d7:	41 5d                	pop    %r13
  8000d9:	41 5e                	pop    %r14
  8000db:	5d                   	pop    %rbp
  8000dc:	c3                   	retq   

00000000008000dd <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000dd:	55                   	push   %rbp
  8000de:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8000e6:	48 b8 d8 0f 80 00 00 	movabs $0x800fd8,%rax
  8000ed:	00 00 00 
  8000f0:	ff d0                	callq  *%rax
}
  8000f2:	5d                   	pop    %rbp
  8000f3:	c3                   	retq   

00000000008000f4 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8000f4:	55                   	push   %rbp
  8000f5:	48 89 e5             	mov    %rsp,%rbp
  8000f8:	53                   	push   %rbx
  8000f9:	48 83 ec 08          	sub    $0x8,%rsp
  8000fd:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800100:	8b 06                	mov    (%rsi),%eax
  800102:	8d 50 01             	lea    0x1(%rax),%edx
  800105:	89 16                	mov    %edx,(%rsi)
  800107:	48 98                	cltq   
  800109:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80010e:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800114:	74 0b                	je     800121 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800116:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80011a:	48 83 c4 08          	add    $0x8,%rsp
  80011e:	5b                   	pop    %rbx
  80011f:	5d                   	pop    %rbp
  800120:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800121:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800125:	be ff 00 00 00       	mov    $0xff,%esi
  80012a:	48 b8 9a 0f 80 00 00 	movabs $0x800f9a,%rax
  800131:	00 00 00 
  800134:	ff d0                	callq  *%rax
    b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80013c:	eb d8                	jmp    800116 <putch+0x22>

000000000080013e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80013e:	55                   	push   %rbp
  80013f:	48 89 e5             	mov    %rsp,%rbp
  800142:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800149:	48 89 fa             	mov    %rdi,%rdx
  80014c:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800156:	00 00 00 
  b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800160:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800163:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80016a:	48 bf f4 00 80 00 00 	movabs $0x8000f4,%rdi
  800171:	00 00 00 
  800174:	48 b8 64 03 80 00 00 	movabs $0x800364,%rax
  80017b:	00 00 00 
  80017e:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800180:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800187:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80018e:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800192:	48 b8 9a 0f 80 00 00 	movabs $0x800f9a,%rax
  800199:	00 00 00 
  80019c:	ff d0                	callq  *%rax

  return b.cnt;
}
  80019e:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001a4:	c9                   	leaveq 
  8001a5:	c3                   	retq   

00000000008001a6 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001a6:	55                   	push   %rbp
  8001a7:	48 89 e5             	mov    %rsp,%rbp
  8001aa:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001b1:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001b8:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001bf:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001c6:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001cd:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001d4:	84 c0                	test   %al,%al
  8001d6:	74 20                	je     8001f8 <cprintf+0x52>
  8001d8:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8001dc:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8001e0:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8001e4:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8001e8:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8001ec:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8001f0:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8001f4:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8001f8:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8001ff:	00 00 00 
  800202:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800209:	00 00 00 
  80020c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800210:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800217:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80021e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800225:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80022c:	48 b8 3e 01 80 00 00 	movabs $0x80013e,%rax
  800233:	00 00 00 
  800236:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800238:	c9                   	leaveq 
  800239:	c3                   	retq   

000000000080023a <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80023a:	55                   	push   %rbp
  80023b:	48 89 e5             	mov    %rsp,%rbp
  80023e:	41 57                	push   %r15
  800240:	41 56                	push   %r14
  800242:	41 55                	push   %r13
  800244:	41 54                	push   %r12
  800246:	53                   	push   %rbx
  800247:	48 83 ec 18          	sub    $0x18,%rsp
  80024b:	49 89 fc             	mov    %rdi,%r12
  80024e:	49 89 f5             	mov    %rsi,%r13
  800251:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800255:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800258:	41 89 cf             	mov    %ecx,%r15d
  80025b:	49 39 d7             	cmp    %rdx,%r15
  80025e:	76 45                	jbe    8002a5 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800260:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7e 0e                	jle    800276 <printnum+0x3c>
      putch(padc, putdat);
  800268:	4c 89 ee             	mov    %r13,%rsi
  80026b:	44 89 f7             	mov    %r14d,%edi
  80026e:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800271:	83 eb 01             	sub    $0x1,%ebx
  800274:	75 f2                	jne    800268 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800276:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	49 f7 f7             	div    %r15
  800282:	48 b8 93 11 80 00 00 	movabs $0x801193,%rax
  800289:	00 00 00 
  80028c:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800290:	4c 89 ee             	mov    %r13,%rsi
  800293:	41 ff d4             	callq  *%r12
}
  800296:	48 83 c4 18          	add    $0x18,%rsp
  80029a:	5b                   	pop    %rbx
  80029b:	41 5c                	pop    %r12
  80029d:	41 5d                	pop    %r13
  80029f:	41 5e                	pop    %r14
  8002a1:	41 5f                	pop    %r15
  8002a3:	5d                   	pop    %rbp
  8002a4:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	49 f7 f7             	div    %r15
  8002b1:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002b5:	48 89 c2             	mov    %rax,%rdx
  8002b8:	48 b8 3a 02 80 00 00 	movabs $0x80023a,%rax
  8002bf:	00 00 00 
  8002c2:	ff d0                	callq  *%rax
  8002c4:	eb b0                	jmp    800276 <printnum+0x3c>

00000000008002c6 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002c6:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002ca:	48 8b 06             	mov    (%rsi),%rax
  8002cd:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002d1:	73 0a                	jae    8002dd <sprintputch+0x17>
    *b->buf++ = ch;
  8002d3:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8002d7:	48 89 16             	mov    %rdx,(%rsi)
  8002da:	40 88 38             	mov    %dil,(%rax)
}
  8002dd:	c3                   	retq   

00000000008002de <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8002de:	55                   	push   %rbp
  8002df:	48 89 e5             	mov    %rsp,%rbp
  8002e2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002e9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002f0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8002f7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8002fe:	84 c0                	test   %al,%al
  800300:	74 20                	je     800322 <printfmt+0x44>
  800302:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800306:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80030a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80030e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800312:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800316:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80031a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80031e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800322:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800329:	00 00 00 
  80032c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800333:	00 00 00 
  800336:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80033a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800341:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800348:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80034f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800356:	48 b8 64 03 80 00 00 	movabs $0x800364,%rax
  80035d:	00 00 00 
  800360:	ff d0                	callq  *%rax
}
  800362:	c9                   	leaveq 
  800363:	c3                   	retq   

0000000000800364 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800364:	55                   	push   %rbp
  800365:	48 89 e5             	mov    %rsp,%rbp
  800368:	41 57                	push   %r15
  80036a:	41 56                	push   %r14
  80036c:	41 55                	push   %r13
  80036e:	41 54                	push   %r12
  800370:	53                   	push   %rbx
  800371:	48 83 ec 48          	sub    $0x48,%rsp
  800375:	49 89 fd             	mov    %rdi,%r13
  800378:	49 89 f7             	mov    %rsi,%r15
  80037b:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80037e:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800382:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800386:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80038a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80038e:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800392:	41 0f b6 3e          	movzbl (%r14),%edi
  800396:	83 ff 25             	cmp    $0x25,%edi
  800399:	74 18                	je     8003b3 <vprintfmt+0x4f>
      if (ch == '\0')
  80039b:	85 ff                	test   %edi,%edi
  80039d:	0f 84 8c 06 00 00    	je     800a2f <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003a3:	4c 89 fe             	mov    %r15,%rsi
  8003a6:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003a9:	49 89 de             	mov    %rbx,%r14
  8003ac:	eb e0                	jmp    80038e <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003ae:	49 89 de             	mov    %rbx,%r14
  8003b1:	eb db                	jmp    80038e <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003b3:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003b7:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003bb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003c2:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003c8:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003cc:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003d1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8003d7:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8003dd:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8003e2:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8003e7:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8003eb:	0f b6 13             	movzbl (%rbx),%edx
  8003ee:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 8b 05 00 00    	ja     800984 <vprintfmt+0x620>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	49 bb 40 12 80 00 00 	movabs $0x801240,%r11
  800403:	00 00 00 
  800406:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80040a:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80040d:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800411:	eb d4                	jmp    8003e7 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800413:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800416:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80041a:	eb cb                	jmp    8003e7 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80041c:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80041f:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800423:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800427:	8d 50 d0             	lea    -0x30(%rax),%edx
  80042a:	83 fa 09             	cmp    $0x9,%edx
  80042d:	77 7e                	ja     8004ad <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80042f:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800433:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800437:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80043c:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800440:	8d 50 d0             	lea    -0x30(%rax),%edx
  800443:	83 fa 09             	cmp    $0x9,%edx
  800446:	76 e7                	jbe    80042f <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800448:	4c 89 f3             	mov    %r14,%rbx
  80044b:	eb 19                	jmp    800466 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80044d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800450:	83 f8 2f             	cmp    $0x2f,%eax
  800453:	77 2a                	ja     80047f <vprintfmt+0x11b>
  800455:	89 c2                	mov    %eax,%edx
  800457:	4c 01 d2             	add    %r10,%rdx
  80045a:	83 c0 08             	add    $0x8,%eax
  80045d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800460:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800463:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800466:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80046a:	0f 89 77 ff ff ff    	jns    8003e7 <vprintfmt+0x83>
          width = precision, precision = -1;
  800470:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800474:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80047a:	e9 68 ff ff ff       	jmpq   8003e7 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80047f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800483:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800487:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80048b:	eb d3                	jmp    800460 <vprintfmt+0xfc>
        if (width < 0)
  80048d:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800490:	85 c0                	test   %eax,%eax
  800492:	41 0f 48 c0          	cmovs  %r8d,%eax
  800496:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800499:	4c 89 f3             	mov    %r14,%rbx
  80049c:	e9 46 ff ff ff       	jmpq   8003e7 <vprintfmt+0x83>
  8004a1:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004a4:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004a8:	e9 3a ff ff ff       	jmpq   8003e7 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004ad:	4c 89 f3             	mov    %r14,%rbx
  8004b0:	eb b4                	jmp    800466 <vprintfmt+0x102>
        lflag++;
  8004b2:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004b5:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004b8:	e9 2a ff ff ff       	jmpq   8003e7 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004bd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004c0:	83 f8 2f             	cmp    $0x2f,%eax
  8004c3:	77 19                	ja     8004de <vprintfmt+0x17a>
  8004c5:	89 c2                	mov    %eax,%edx
  8004c7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004cb:	83 c0 08             	add    $0x8,%eax
  8004ce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004d1:	4c 89 fe             	mov    %r15,%rsi
  8004d4:	8b 3a                	mov    (%rdx),%edi
  8004d6:	41 ff d5             	callq  *%r13
        break;
  8004d9:	e9 b0 fe ff ff       	jmpq   80038e <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8004de:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004e2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004e6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004ea:	eb e5                	jmp    8004d1 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8004ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004ef:	83 f8 2f             	cmp    $0x2f,%eax
  8004f2:	77 5b                	ja     80054f <vprintfmt+0x1eb>
  8004f4:	89 c2                	mov    %eax,%edx
  8004f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004fa:	83 c0 08             	add    $0x8,%eax
  8004fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800500:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800502:	89 c8                	mov    %ecx,%eax
  800504:	c1 f8 1f             	sar    $0x1f,%eax
  800507:	31 c1                	xor    %eax,%ecx
  800509:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050b:	83 f9 09             	cmp    $0x9,%ecx
  80050e:	7f 4d                	jg     80055d <vprintfmt+0x1f9>
  800510:	48 63 c1             	movslq %ecx,%rax
  800513:	48 ba 00 15 80 00 00 	movabs $0x801500,%rdx
  80051a:	00 00 00 
  80051d:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800521:	48 85 c0             	test   %rax,%rax
  800524:	74 37                	je     80055d <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800526:	48 89 c1             	mov    %rax,%rcx
  800529:	48 ba b4 11 80 00 00 	movabs $0x8011b4,%rdx
  800530:	00 00 00 
  800533:	4c 89 fe             	mov    %r15,%rsi
  800536:	4c 89 ef             	mov    %r13,%rdi
  800539:	b8 00 00 00 00       	mov    $0x0,%eax
  80053e:	48 bb de 02 80 00 00 	movabs $0x8002de,%rbx
  800545:	00 00 00 
  800548:	ff d3                	callq  *%rbx
  80054a:	e9 3f fe ff ff       	jmpq   80038e <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80054f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800553:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800557:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80055b:	eb a3                	jmp    800500 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80055d:	48 ba ab 11 80 00 00 	movabs $0x8011ab,%rdx
  800564:	00 00 00 
  800567:	4c 89 fe             	mov    %r15,%rsi
  80056a:	4c 89 ef             	mov    %r13,%rdi
  80056d:	b8 00 00 00 00       	mov    $0x0,%eax
  800572:	48 bb de 02 80 00 00 	movabs $0x8002de,%rbx
  800579:	00 00 00 
  80057c:	ff d3                	callq  *%rbx
  80057e:	e9 0b fe ff ff       	jmpq   80038e <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800583:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800586:	83 f8 2f             	cmp    $0x2f,%eax
  800589:	77 4b                	ja     8005d6 <vprintfmt+0x272>
  80058b:	89 c2                	mov    %eax,%edx
  80058d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800591:	83 c0 08             	add    $0x8,%eax
  800594:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800597:	48 8b 02             	mov    (%rdx),%rax
  80059a:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80059e:	48 85 c0             	test   %rax,%rax
  8005a1:	0f 84 05 04 00 00    	je     8009ac <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005a7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005ab:	7e 06                	jle    8005b3 <vprintfmt+0x24f>
  8005ad:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005b1:	75 31                	jne    8005e4 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005b7:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005bb:	0f b6 00             	movzbl (%rax),%eax
  8005be:	0f be f8             	movsbl %al,%edi
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	0f 84 c3 00 00 00    	je     80068c <vprintfmt+0x328>
  8005c9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005cd:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005d1:	e9 85 00 00 00       	jmpq   80065b <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005d6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005da:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005de:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005e2:	eb b3                	jmp    800597 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	49 63 f4             	movslq %r12d,%rsi
  8005e7:	48 89 c7             	mov    %rax,%rdi
  8005ea:	48 b8 3b 0b 80 00 00 	movabs $0x800b3b,%rax
  8005f1:	00 00 00 
  8005f4:	ff d0                	callq  *%rax
  8005f6:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8005f9:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8005fc:	85 f6                	test   %esi,%esi
  8005fe:	7e 22                	jle    800622 <vprintfmt+0x2be>
            putch(padc, putdat);
  800600:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800604:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800608:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80060c:	4c 89 fe             	mov    %r15,%rsi
  80060f:	89 df                	mov    %ebx,%edi
  800611:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800614:	41 83 ec 01          	sub    $0x1,%r12d
  800618:	75 f2                	jne    80060c <vprintfmt+0x2a8>
  80061a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80061e:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800626:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80062a:	0f b6 00             	movzbl (%rax),%eax
  80062d:	0f be f8             	movsbl %al,%edi
  800630:	85 ff                	test   %edi,%edi
  800632:	0f 84 56 fd ff ff    	je     80038e <vprintfmt+0x2a>
  800638:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80063c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800640:	eb 19                	jmp    80065b <vprintfmt+0x2f7>
            putch(ch, putdat);
  800642:	4c 89 fe             	mov    %r15,%rsi
  800645:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	41 83 ee 01          	sub    $0x1,%r14d
  80064c:	48 83 c3 01          	add    $0x1,%rbx
  800650:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800654:	0f be f8             	movsbl %al,%edi
  800657:	85 ff                	test   %edi,%edi
  800659:	74 29                	je     800684 <vprintfmt+0x320>
  80065b:	45 85 e4             	test   %r12d,%r12d
  80065e:	78 06                	js     800666 <vprintfmt+0x302>
  800660:	41 83 ec 01          	sub    $0x1,%r12d
  800664:	78 48                	js     8006ae <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800666:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80066a:	74 d6                	je     800642 <vprintfmt+0x2de>
  80066c:	0f be c0             	movsbl %al,%eax
  80066f:	83 e8 20             	sub    $0x20,%eax
  800672:	83 f8 5e             	cmp    $0x5e,%eax
  800675:	76 cb                	jbe    800642 <vprintfmt+0x2de>
            putch('?', putdat);
  800677:	4c 89 fe             	mov    %r15,%rsi
  80067a:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80067f:	41 ff d5             	callq  *%r13
  800682:	eb c4                	jmp    800648 <vprintfmt+0x2e4>
  800684:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800688:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80068c:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80068f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800693:	0f 8e f5 fc ff ff    	jle    80038e <vprintfmt+0x2a>
          putch(' ', putdat);
  800699:	4c 89 fe             	mov    %r15,%rsi
  80069c:	bf 20 00 00 00       	mov    $0x20,%edi
  8006a1:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006a4:	83 eb 01             	sub    $0x1,%ebx
  8006a7:	75 f0                	jne    800699 <vprintfmt+0x335>
  8006a9:	e9 e0 fc ff ff       	jmpq   80038e <vprintfmt+0x2a>
  8006ae:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006b2:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006b6:	eb d4                	jmp    80068c <vprintfmt+0x328>
  if (lflag >= 2)
  8006b8:	83 f9 01             	cmp    $0x1,%ecx
  8006bb:	7f 1d                	jg     8006da <vprintfmt+0x376>
  else if (lflag)
  8006bd:	85 c9                	test   %ecx,%ecx
  8006bf:	74 5e                	je     80071f <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006c1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006c4:	83 f8 2f             	cmp    $0x2f,%eax
  8006c7:	77 48                	ja     800711 <vprintfmt+0x3ad>
  8006c9:	89 c2                	mov    %eax,%edx
  8006cb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006cf:	83 c0 08             	add    $0x8,%eax
  8006d2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006d5:	48 8b 1a             	mov    (%rdx),%rbx
  8006d8:	eb 17                	jmp    8006f1 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8006da:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006dd:	83 f8 2f             	cmp    $0x2f,%eax
  8006e0:	77 21                	ja     800703 <vprintfmt+0x39f>
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006e8:	83 c0 08             	add    $0x8,%eax
  8006eb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006ee:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8006f1:	48 85 db             	test   %rbx,%rbx
  8006f4:	78 50                	js     800746 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8006f6:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8006f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006fe:	e9 b4 01 00 00       	jmpq   8008b7 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800703:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800707:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80070b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80070f:	eb dd                	jmp    8006ee <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800711:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800715:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800719:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80071d:	eb b6                	jmp    8006d5 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80071f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800722:	83 f8 2f             	cmp    $0x2f,%eax
  800725:	77 11                	ja     800738 <vprintfmt+0x3d4>
  800727:	89 c2                	mov    %eax,%edx
  800729:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80072d:	83 c0 08             	add    $0x8,%eax
  800730:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800733:	48 63 1a             	movslq (%rdx),%rbx
  800736:	eb b9                	jmp    8006f1 <vprintfmt+0x38d>
  800738:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80073c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800740:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800744:	eb ed                	jmp    800733 <vprintfmt+0x3cf>
          putch('-', putdat);
  800746:	4c 89 fe             	mov    %r15,%rsi
  800749:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80074e:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800751:	48 89 da             	mov    %rbx,%rdx
  800754:	48 f7 da             	neg    %rdx
        base = 10;
  800757:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80075c:	e9 56 01 00 00       	jmpq   8008b7 <vprintfmt+0x553>
  if (lflag >= 2)
  800761:	83 f9 01             	cmp    $0x1,%ecx
  800764:	7f 25                	jg     80078b <vprintfmt+0x427>
  else if (lflag)
  800766:	85 c9                	test   %ecx,%ecx
  800768:	74 5e                	je     8007c8 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80076a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80076d:	83 f8 2f             	cmp    $0x2f,%eax
  800770:	77 48                	ja     8007ba <vprintfmt+0x456>
  800772:	89 c2                	mov    %eax,%edx
  800774:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800778:	83 c0 08             	add    $0x8,%eax
  80077b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80077e:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800781:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800786:	e9 2c 01 00 00       	jmpq   8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80078b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80078e:	83 f8 2f             	cmp    $0x2f,%eax
  800791:	77 19                	ja     8007ac <vprintfmt+0x448>
  800793:	89 c2                	mov    %eax,%edx
  800795:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800799:	83 c0 08             	add    $0x8,%eax
  80079c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80079f:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a7:	e9 0b 01 00 00       	jmpq   8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007ac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007b0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007b4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b8:	eb e5                	jmp    80079f <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007ba:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007be:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007c6:	eb b6                	jmp    80077e <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007cb:	83 f8 2f             	cmp    $0x2f,%eax
  8007ce:	77 18                	ja     8007e8 <vprintfmt+0x484>
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d6:	83 c0 08             	add    $0x8,%eax
  8007d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007dc:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8007de:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e3:	e9 cf 00 00 00       	jmpq   8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8007e8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ec:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007f0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f4:	eb e6                	jmp    8007dc <vprintfmt+0x478>
  if (lflag >= 2)
  8007f6:	83 f9 01             	cmp    $0x1,%ecx
  8007f9:	7f 25                	jg     800820 <vprintfmt+0x4bc>
  else if (lflag)
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	74 5b                	je     80085a <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8007ff:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800802:	83 f8 2f             	cmp    $0x2f,%eax
  800805:	77 45                	ja     80084c <vprintfmt+0x4e8>
  800807:	89 c2                	mov    %eax,%edx
  800809:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80080d:	83 c0 08             	add    $0x8,%eax
  800810:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800813:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800816:	b9 08 00 00 00       	mov    $0x8,%ecx
  80081b:	e9 97 00 00 00       	jmpq   8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800820:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800823:	83 f8 2f             	cmp    $0x2f,%eax
  800826:	77 16                	ja     80083e <vprintfmt+0x4da>
  800828:	89 c2                	mov    %eax,%edx
  80082a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80082e:	83 c0 08             	add    $0x8,%eax
  800831:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800834:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800837:	b9 08 00 00 00       	mov    $0x8,%ecx
  80083c:	eb 79                	jmp    8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80083e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800842:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800846:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80084a:	eb e8                	jmp    800834 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80084c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800850:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800854:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800858:	eb b9                	jmp    800813 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  80085a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80085d:	83 f8 2f             	cmp    $0x2f,%eax
  800860:	77 15                	ja     800877 <vprintfmt+0x513>
  800862:	89 c2                	mov    %eax,%edx
  800864:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800868:	83 c0 08             	add    $0x8,%eax
  80086b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80086e:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800870:	b9 08 00 00 00       	mov    $0x8,%ecx
  800875:	eb 40                	jmp    8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800877:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800883:	eb e9                	jmp    80086e <vprintfmt+0x50a>
        putch('0', putdat);
  800885:	4c 89 fe             	mov    %r15,%rsi
  800888:	bf 30 00 00 00       	mov    $0x30,%edi
  80088d:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800890:	4c 89 fe             	mov    %r15,%rsi
  800893:	bf 78 00 00 00       	mov    $0x78,%edi
  800898:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80089b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089e:	83 f8 2f             	cmp    $0x2f,%eax
  8008a1:	77 34                	ja     8008d7 <vprintfmt+0x573>
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a9:	83 c0 08             	add    $0x8,%eax
  8008ac:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008af:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008b2:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008b7:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008bc:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008c0:	4c 89 fe             	mov    %r15,%rsi
  8008c3:	4c 89 ef             	mov    %r13,%rdi
  8008c6:	48 b8 3a 02 80 00 00 	movabs $0x80023a,%rax
  8008cd:	00 00 00 
  8008d0:	ff d0                	callq  *%rax
        break;
  8008d2:	e9 b7 fa ff ff       	jmpq   80038e <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e3:	eb ca                	jmp    8008af <vprintfmt+0x54b>
  if (lflag >= 2)
  8008e5:	83 f9 01             	cmp    $0x1,%ecx
  8008e8:	7f 22                	jg     80090c <vprintfmt+0x5a8>
  else if (lflag)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 58                	je     800946 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8008ee:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f1:	83 f8 2f             	cmp    $0x2f,%eax
  8008f4:	77 42                	ja     800938 <vprintfmt+0x5d4>
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008fc:	83 c0 08             	add    $0x8,%eax
  8008ff:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800902:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800905:	b9 10 00 00 00       	mov    $0x10,%ecx
  80090a:	eb ab                	jmp    8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80090c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090f:	83 f8 2f             	cmp    $0x2f,%eax
  800912:	77 16                	ja     80092a <vprintfmt+0x5c6>
  800914:	89 c2                	mov    %eax,%edx
  800916:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091a:	83 c0 08             	add    $0x8,%eax
  80091d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800920:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800923:	b9 10 00 00 00       	mov    $0x10,%ecx
  800928:	eb 8d                	jmp    8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80092a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80092e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800932:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800936:	eb e8                	jmp    800920 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800938:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80093c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800940:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800944:	eb bc                	jmp    800902 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800946:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800949:	83 f8 2f             	cmp    $0x2f,%eax
  80094c:	77 18                	ja     800966 <vprintfmt+0x602>
  80094e:	89 c2                	mov    %eax,%edx
  800950:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800954:	83 c0 08             	add    $0x8,%eax
  800957:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095a:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80095c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800961:	e9 51 ff ff ff       	jmpq   8008b7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800966:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800972:	eb e6                	jmp    80095a <vprintfmt+0x5f6>
        putch(ch, putdat);
  800974:	4c 89 fe             	mov    %r15,%rsi
  800977:	bf 25 00 00 00       	mov    $0x25,%edi
  80097c:	41 ff d5             	callq  *%r13
        break;
  80097f:	e9 0a fa ff ff       	jmpq   80038e <vprintfmt+0x2a>
        putch('%', putdat);
  800984:	4c 89 fe             	mov    %r15,%rsi
  800987:	bf 25 00 00 00       	mov    $0x25,%edi
  80098c:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  80098f:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800993:	0f 84 15 fa ff ff    	je     8003ae <vprintfmt+0x4a>
  800999:	49 89 de             	mov    %rbx,%r14
  80099c:	49 83 ee 01          	sub    $0x1,%r14
  8009a0:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009a5:	75 f5                	jne    80099c <vprintfmt+0x638>
  8009a7:	e9 e2 f9 ff ff       	jmpq   80038e <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009ac:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009b0:	74 06                	je     8009b8 <vprintfmt+0x654>
  8009b2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009b6:	7f 21                	jg     8009d9 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b8:	bf 28 00 00 00       	mov    $0x28,%edi
  8009bd:	48 bb a5 11 80 00 00 	movabs $0x8011a5,%rbx
  8009c4:	00 00 00 
  8009c7:	b8 28 00 00 00       	mov    $0x28,%eax
  8009cc:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009d0:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009d4:	e9 82 fc ff ff       	jmpq   80065b <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009d9:	49 63 f4             	movslq %r12d,%rsi
  8009dc:	48 bf a4 11 80 00 00 	movabs $0x8011a4,%rdi
  8009e3:	00 00 00 
  8009e6:	48 b8 3b 0b 80 00 00 	movabs $0x800b3b,%rax
  8009ed:	00 00 00 
  8009f0:	ff d0                	callq  *%rax
  8009f2:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8009f5:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  8009f8:	48 be a4 11 80 00 00 	movabs $0x8011a4,%rsi
  8009ff:	00 00 00 
  800a02:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a06:	85 c0                	test   %eax,%eax
  800a08:	0f 8f f2 fb ff ff    	jg     800600 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0e:	48 bb a5 11 80 00 00 	movabs $0x8011a5,%rbx
  800a15:	00 00 00 
  800a18:	b8 28 00 00 00       	mov    $0x28,%eax
  800a1d:	bf 28 00 00 00       	mov    $0x28,%edi
  800a22:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a26:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a2a:	e9 2c fc ff ff       	jmpq   80065b <vprintfmt+0x2f7>
}
  800a2f:	48 83 c4 48          	add    $0x48,%rsp
  800a33:	5b                   	pop    %rbx
  800a34:	41 5c                	pop    %r12
  800a36:	41 5d                	pop    %r13
  800a38:	41 5e                	pop    %r14
  800a3a:	41 5f                	pop    %r15
  800a3c:	5d                   	pop    %rbp
  800a3d:	c3                   	retq   

0000000000800a3e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a3e:	55                   	push   %rbp
  800a3f:	48 89 e5             	mov    %rsp,%rbp
  800a42:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a46:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a4a:	48 63 c6             	movslq %esi,%rax
  800a4d:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a52:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a56:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a5d:	48 85 ff             	test   %rdi,%rdi
  800a60:	74 2a                	je     800a8c <vsnprintf+0x4e>
  800a62:	85 f6                	test   %esi,%esi
  800a64:	7e 26                	jle    800a8c <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a66:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a6a:	48 bf c6 02 80 00 00 	movabs $0x8002c6,%rdi
  800a71:	00 00 00 
  800a74:	48 b8 64 03 80 00 00 	movabs $0x800364,%rax
  800a7b:	00 00 00 
  800a7e:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800a80:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800a84:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800a87:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800a8a:	c9                   	leaveq 
  800a8b:	c3                   	retq   
    return -E_INVAL;
  800a8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a91:	eb f7                	jmp    800a8a <vsnprintf+0x4c>

0000000000800a93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800a93:	55                   	push   %rbp
  800a94:	48 89 e5             	mov    %rsp,%rbp
  800a97:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800a9e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800aa5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800aac:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ab3:	84 c0                	test   %al,%al
  800ab5:	74 20                	je     800ad7 <snprintf+0x44>
  800ab7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800abb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800abf:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800ac3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ac7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800acb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800acf:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ad3:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ad7:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ade:	00 00 00 
  800ae1:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ae8:	00 00 00 
  800aeb:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800aef:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800af6:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800afd:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b04:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b0b:	48 b8 3e 0a 80 00 00 	movabs $0x800a3e,%rax
  800b12:	00 00 00 
  800b15:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b17:	c9                   	leaveq 
  800b18:	c3                   	retq   

0000000000800b19 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b19:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b1c:	74 17                	je     800b35 <strlen+0x1c>
  800b1e:	48 89 fa             	mov    %rdi,%rdx
  800b21:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b26:	29 f9                	sub    %edi,%ecx
    n++;
  800b28:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b2b:	48 83 c2 01          	add    $0x1,%rdx
  800b2f:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b32:	75 f4                	jne    800b28 <strlen+0xf>
  800b34:	c3                   	retq   
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b3a:	c3                   	retq   

0000000000800b3b <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3b:	48 85 f6             	test   %rsi,%rsi
  800b3e:	74 24                	je     800b64 <strnlen+0x29>
  800b40:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b43:	74 25                	je     800b6a <strnlen+0x2f>
  800b45:	48 01 fe             	add    %rdi,%rsi
  800b48:	48 89 fa             	mov    %rdi,%rdx
  800b4b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b50:	29 f9                	sub    %edi,%ecx
    n++;
  800b52:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b55:	48 83 c2 01          	add    $0x1,%rdx
  800b59:	48 39 f2             	cmp    %rsi,%rdx
  800b5c:	74 11                	je     800b6f <strnlen+0x34>
  800b5e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b61:	75 ef                	jne    800b52 <strnlen+0x17>
  800b63:	c3                   	retq   
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	c3                   	retq   
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b6f:	c3                   	retq   

0000000000800b70 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b70:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800b7c:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800b7f:	48 83 c2 01          	add    $0x1,%rdx
  800b83:	84 c9                	test   %cl,%cl
  800b85:	75 f1                	jne    800b78 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800b87:	c3                   	retq   

0000000000800b88 <strcat>:

char *
strcat(char *dst, const char *src) {
  800b88:	55                   	push   %rbp
  800b89:	48 89 e5             	mov    %rsp,%rbp
  800b8c:	41 54                	push   %r12
  800b8e:	53                   	push   %rbx
  800b8f:	48 89 fb             	mov    %rdi,%rbx
  800b92:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800b95:	48 b8 19 0b 80 00 00 	movabs $0x800b19,%rax
  800b9c:	00 00 00 
  800b9f:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800ba1:	48 63 f8             	movslq %eax,%rdi
  800ba4:	48 01 df             	add    %rbx,%rdi
  800ba7:	4c 89 e6             	mov    %r12,%rsi
  800baa:	48 b8 70 0b 80 00 00 	movabs $0x800b70,%rax
  800bb1:	00 00 00 
  800bb4:	ff d0                	callq  *%rax
  return dst;
}
  800bb6:	48 89 d8             	mov    %rbx,%rax
  800bb9:	5b                   	pop    %rbx
  800bba:	41 5c                	pop    %r12
  800bbc:	5d                   	pop    %rbp
  800bbd:	c3                   	retq   

0000000000800bbe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bbe:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bc1:	48 85 d2             	test   %rdx,%rdx
  800bc4:	74 1f                	je     800be5 <strncpy+0x27>
  800bc6:	48 01 fa             	add    %rdi,%rdx
  800bc9:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bcc:	48 83 c1 01          	add    $0x1,%rcx
  800bd0:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bd4:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800bd8:	41 80 f8 01          	cmp    $0x1,%r8b
  800bdc:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800be0:	48 39 ca             	cmp    %rcx,%rdx
  800be3:	75 e7                	jne    800bcc <strncpy+0xe>
  }
  return ret;
}
  800be5:	c3                   	retq   

0000000000800be6 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800be6:	48 89 f8             	mov    %rdi,%rax
  800be9:	48 85 d2             	test   %rdx,%rdx
  800bec:	74 36                	je     800c24 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800bee:	48 83 fa 01          	cmp    $0x1,%rdx
  800bf2:	74 2d                	je     800c21 <strlcpy+0x3b>
  800bf4:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bf8:	45 84 c0             	test   %r8b,%r8b
  800bfb:	74 24                	je     800c21 <strlcpy+0x3b>
  800bfd:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c01:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c06:	48 83 c0 01          	add    $0x1,%rax
  800c0a:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c0e:	48 39 d1             	cmp    %rdx,%rcx
  800c11:	74 0e                	je     800c21 <strlcpy+0x3b>
  800c13:	48 83 c1 01          	add    $0x1,%rcx
  800c17:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c1c:	45 84 c0             	test   %r8b,%r8b
  800c1f:	75 e5                	jne    800c06 <strlcpy+0x20>
    *dst = '\0';
  800c21:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c24:	48 29 f8             	sub    %rdi,%rax
}
  800c27:	c3                   	retq   

0000000000800c28 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c28:	0f b6 07             	movzbl (%rdi),%eax
  800c2b:	84 c0                	test   %al,%al
  800c2d:	74 17                	je     800c46 <strcmp+0x1e>
  800c2f:	3a 06                	cmp    (%rsi),%al
  800c31:	75 13                	jne    800c46 <strcmp+0x1e>
    p++, q++;
  800c33:	48 83 c7 01          	add    $0x1,%rdi
  800c37:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c3b:	0f b6 07             	movzbl (%rdi),%eax
  800c3e:	84 c0                	test   %al,%al
  800c40:	74 04                	je     800c46 <strcmp+0x1e>
  800c42:	3a 06                	cmp    (%rsi),%al
  800c44:	74 ed                	je     800c33 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c46:	0f b6 c0             	movzbl %al,%eax
  800c49:	0f b6 16             	movzbl (%rsi),%edx
  800c4c:	29 d0                	sub    %edx,%eax
}
  800c4e:	c3                   	retq   

0000000000800c4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c4f:	48 85 d2             	test   %rdx,%rdx
  800c52:	74 2f                	je     800c83 <strncmp+0x34>
  800c54:	0f b6 07             	movzbl (%rdi),%eax
  800c57:	84 c0                	test   %al,%al
  800c59:	74 1f                	je     800c7a <strncmp+0x2b>
  800c5b:	3a 06                	cmp    (%rsi),%al
  800c5d:	75 1b                	jne    800c7a <strncmp+0x2b>
  800c5f:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c62:	48 83 c7 01          	add    $0x1,%rdi
  800c66:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c6a:	48 39 d7             	cmp    %rdx,%rdi
  800c6d:	74 1a                	je     800c89 <strncmp+0x3a>
  800c6f:	0f b6 07             	movzbl (%rdi),%eax
  800c72:	84 c0                	test   %al,%al
  800c74:	74 04                	je     800c7a <strncmp+0x2b>
  800c76:	3a 06                	cmp    (%rsi),%al
  800c78:	74 e8                	je     800c62 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800c7a:	0f b6 07             	movzbl (%rdi),%eax
  800c7d:	0f b6 16             	movzbl (%rsi),%edx
  800c80:	29 d0                	sub    %edx,%eax
}
  800c82:	c3                   	retq   
    return 0;
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
  800c88:	c3                   	retq   
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8e:	c3                   	retq   

0000000000800c8f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800c8f:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800c91:	0f b6 07             	movzbl (%rdi),%eax
  800c94:	84 c0                	test   %al,%al
  800c96:	74 1e                	je     800cb6 <strchr+0x27>
    if (*s == c)
  800c98:	40 38 c6             	cmp    %al,%sil
  800c9b:	74 1f                	je     800cbc <strchr+0x2d>
  for (; *s; s++)
  800c9d:	48 83 c7 01          	add    $0x1,%rdi
  800ca1:	0f b6 07             	movzbl (%rdi),%eax
  800ca4:	84 c0                	test   %al,%al
  800ca6:	74 08                	je     800cb0 <strchr+0x21>
    if (*s == c)
  800ca8:	38 d0                	cmp    %dl,%al
  800caa:	75 f1                	jne    800c9d <strchr+0xe>
  for (; *s; s++)
  800cac:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800caf:	c3                   	retq   
  return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb5:	c3                   	retq   
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbb:	c3                   	retq   
    if (*s == c)
  800cbc:	48 89 f8             	mov    %rdi,%rax
  800cbf:	c3                   	retq   

0000000000800cc0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cc0:	48 89 f8             	mov    %rdi,%rax
  800cc3:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cc5:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cc8:	40 38 f2             	cmp    %sil,%dl
  800ccb:	74 13                	je     800ce0 <strfind+0x20>
  800ccd:	84 d2                	test   %dl,%dl
  800ccf:	74 0f                	je     800ce0 <strfind+0x20>
  for (; *s; s++)
  800cd1:	48 83 c0 01          	add    $0x1,%rax
  800cd5:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800cd8:	38 ca                	cmp    %cl,%dl
  800cda:	74 04                	je     800ce0 <strfind+0x20>
  800cdc:	84 d2                	test   %dl,%dl
  800cde:	75 f1                	jne    800cd1 <strfind+0x11>
      break;
  return (char *)s;
}
  800ce0:	c3                   	retq   

0000000000800ce1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800ce1:	48 85 d2             	test   %rdx,%rdx
  800ce4:	74 3a                	je     800d20 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ce6:	48 89 f8             	mov    %rdi,%rax
  800ce9:	48 09 d0             	or     %rdx,%rax
  800cec:	a8 03                	test   $0x3,%al
  800cee:	75 28                	jne    800d18 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800cf0:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800cf4:	89 f0                	mov    %esi,%eax
  800cf6:	c1 e0 08             	shl    $0x8,%eax
  800cf9:	89 f1                	mov    %esi,%ecx
  800cfb:	c1 e1 18             	shl    $0x18,%ecx
  800cfe:	41 89 f0             	mov    %esi,%r8d
  800d01:	41 c1 e0 10          	shl    $0x10,%r8d
  800d05:	44 09 c1             	or     %r8d,%ecx
  800d08:	09 ce                	or     %ecx,%esi
  800d0a:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d0c:	48 c1 ea 02          	shr    $0x2,%rdx
  800d10:	48 89 d1             	mov    %rdx,%rcx
  800d13:	fc                   	cld    
  800d14:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d16:	eb 08                	jmp    800d20 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d18:	89 f0                	mov    %esi,%eax
  800d1a:	48 89 d1             	mov    %rdx,%rcx
  800d1d:	fc                   	cld    
  800d1e:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d20:	48 89 f8             	mov    %rdi,%rax
  800d23:	c3                   	retq   

0000000000800d24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d24:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d27:	48 39 fe             	cmp    %rdi,%rsi
  800d2a:	73 40                	jae    800d6c <memmove+0x48>
  800d2c:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d30:	48 39 f9             	cmp    %rdi,%rcx
  800d33:	76 37                	jbe    800d6c <memmove+0x48>
    s += n;
    d += n;
  800d35:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d39:	48 89 fe             	mov    %rdi,%rsi
  800d3c:	48 09 d6             	or     %rdx,%rsi
  800d3f:	48 09 ce             	or     %rcx,%rsi
  800d42:	40 f6 c6 03          	test   $0x3,%sil
  800d46:	75 14                	jne    800d5c <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d48:	48 83 ef 04          	sub    $0x4,%rdi
  800d4c:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d50:	48 c1 ea 02          	shr    $0x2,%rdx
  800d54:	48 89 d1             	mov    %rdx,%rcx
  800d57:	fd                   	std    
  800d58:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d5a:	eb 0e                	jmp    800d6a <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d5c:	48 83 ef 01          	sub    $0x1,%rdi
  800d60:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d64:	48 89 d1             	mov    %rdx,%rcx
  800d67:	fd                   	std    
  800d68:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d6a:	fc                   	cld    
  800d6b:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d6c:	48 89 c1             	mov    %rax,%rcx
  800d6f:	48 09 d1             	or     %rdx,%rcx
  800d72:	48 09 f1             	or     %rsi,%rcx
  800d75:	f6 c1 03             	test   $0x3,%cl
  800d78:	75 0e                	jne    800d88 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800d7a:	48 c1 ea 02          	shr    $0x2,%rdx
  800d7e:	48 89 d1             	mov    %rdx,%rcx
  800d81:	48 89 c7             	mov    %rax,%rdi
  800d84:	fc                   	cld    
  800d85:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d87:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800d88:	48 89 c7             	mov    %rax,%rdi
  800d8b:	48 89 d1             	mov    %rdx,%rcx
  800d8e:	fc                   	cld    
  800d8f:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800d91:	c3                   	retq   

0000000000800d92 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800d92:	55                   	push   %rbp
  800d93:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800d96:	48 b8 24 0d 80 00 00 	movabs $0x800d24,%rax
  800d9d:	00 00 00 
  800da0:	ff d0                	callq  *%rax
}
  800da2:	5d                   	pop    %rbp
  800da3:	c3                   	retq   

0000000000800da4 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800da4:	55                   	push   %rbp
  800da5:	48 89 e5             	mov    %rsp,%rbp
  800da8:	41 57                	push   %r15
  800daa:	41 56                	push   %r14
  800dac:	41 55                	push   %r13
  800dae:	41 54                	push   %r12
  800db0:	53                   	push   %rbx
  800db1:	48 83 ec 08          	sub    $0x8,%rsp
  800db5:	49 89 fe             	mov    %rdi,%r14
  800db8:	49 89 f7             	mov    %rsi,%r15
  800dbb:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800dbe:	48 89 f7             	mov    %rsi,%rdi
  800dc1:	48 b8 19 0b 80 00 00 	movabs $0x800b19,%rax
  800dc8:	00 00 00 
  800dcb:	ff d0                	callq  *%rax
  800dcd:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dd0:	4c 89 ee             	mov    %r13,%rsi
  800dd3:	4c 89 f7             	mov    %r14,%rdi
  800dd6:	48 b8 3b 0b 80 00 00 	movabs $0x800b3b,%rax
  800ddd:	00 00 00 
  800de0:	ff d0                	callq  *%rax
  800de2:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800de5:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800de9:	4d 39 e5             	cmp    %r12,%r13
  800dec:	74 26                	je     800e14 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800dee:	4c 89 e8             	mov    %r13,%rax
  800df1:	4c 29 e0             	sub    %r12,%rax
  800df4:	48 39 d8             	cmp    %rbx,%rax
  800df7:	76 2a                	jbe    800e23 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800df9:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800dfd:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e01:	4c 89 fe             	mov    %r15,%rsi
  800e04:	48 b8 92 0d 80 00 00 	movabs $0x800d92,%rax
  800e0b:	00 00 00 
  800e0e:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e10:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e14:	48 83 c4 08          	add    $0x8,%rsp
  800e18:	5b                   	pop    %rbx
  800e19:	41 5c                	pop    %r12
  800e1b:	41 5d                	pop    %r13
  800e1d:	41 5e                	pop    %r14
  800e1f:	41 5f                	pop    %r15
  800e21:	5d                   	pop    %rbp
  800e22:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e23:	49 83 ed 01          	sub    $0x1,%r13
  800e27:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e2b:	4c 89 ea             	mov    %r13,%rdx
  800e2e:	4c 89 fe             	mov    %r15,%rsi
  800e31:	48 b8 92 0d 80 00 00 	movabs $0x800d92,%rax
  800e38:	00 00 00 
  800e3b:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e3d:	4d 01 ee             	add    %r13,%r14
  800e40:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e45:	eb c9                	jmp    800e10 <strlcat+0x6c>

0000000000800e47 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e47:	48 85 d2             	test   %rdx,%rdx
  800e4a:	74 3a                	je     800e86 <memcmp+0x3f>
    if (*s1 != *s2)
  800e4c:	0f b6 0f             	movzbl (%rdi),%ecx
  800e4f:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e53:	44 38 c1             	cmp    %r8b,%cl
  800e56:	75 1d                	jne    800e75 <memcmp+0x2e>
  800e58:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e5d:	48 39 d0             	cmp    %rdx,%rax
  800e60:	74 1e                	je     800e80 <memcmp+0x39>
    if (*s1 != *s2)
  800e62:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e66:	48 83 c0 01          	add    $0x1,%rax
  800e6a:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e70:	44 38 c1             	cmp    %r8b,%cl
  800e73:	74 e8                	je     800e5d <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e75:	0f b6 c1             	movzbl %cl,%eax
  800e78:	45 0f b6 c0          	movzbl %r8b,%r8d
  800e7c:	44 29 c0             	sub    %r8d,%eax
  800e7f:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800e80:	b8 00 00 00 00       	mov    $0x0,%eax
  800e85:	c3                   	retq   
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8b:	c3                   	retq   

0000000000800e8c <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800e8c:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800e90:	48 39 c7             	cmp    %rax,%rdi
  800e93:	73 19                	jae    800eae <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800e95:	89 f2                	mov    %esi,%edx
  800e97:	40 38 37             	cmp    %sil,(%rdi)
  800e9a:	74 16                	je     800eb2 <memfind+0x26>
  for (; s < ends; s++)
  800e9c:	48 83 c7 01          	add    $0x1,%rdi
  800ea0:	48 39 f8             	cmp    %rdi,%rax
  800ea3:	74 08                	je     800ead <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ea5:	38 17                	cmp    %dl,(%rdi)
  800ea7:	75 f3                	jne    800e9c <memfind+0x10>
  for (; s < ends; s++)
  800ea9:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800eac:	c3                   	retq   
  800ead:	c3                   	retq   
  for (; s < ends; s++)
  800eae:	48 89 f8             	mov    %rdi,%rax
  800eb1:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800eb2:	48 89 f8             	mov    %rdi,%rax
  800eb5:	c3                   	retq   

0000000000800eb6 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800eb6:	0f b6 07             	movzbl (%rdi),%eax
  800eb9:	3c 20                	cmp    $0x20,%al
  800ebb:	74 04                	je     800ec1 <strtol+0xb>
  800ebd:	3c 09                	cmp    $0x9,%al
  800ebf:	75 0f                	jne    800ed0 <strtol+0x1a>
    s++;
  800ec1:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ec5:	0f b6 07             	movzbl (%rdi),%eax
  800ec8:	3c 20                	cmp    $0x20,%al
  800eca:	74 f5                	je     800ec1 <strtol+0xb>
  800ecc:	3c 09                	cmp    $0x9,%al
  800ece:	74 f1                	je     800ec1 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800ed0:	3c 2b                	cmp    $0x2b,%al
  800ed2:	74 2b                	je     800eff <strtol+0x49>
  int neg  = 0;
  800ed4:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800eda:	3c 2d                	cmp    $0x2d,%al
  800edc:	74 2d                	je     800f0b <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ede:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800ee4:	75 0f                	jne    800ef5 <strtol+0x3f>
  800ee6:	80 3f 30             	cmpb   $0x30,(%rdi)
  800ee9:	74 2c                	je     800f17 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800eeb:	85 d2                	test   %edx,%edx
  800eed:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef2:	0f 44 d0             	cmove  %eax,%edx
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800efa:	4c 63 d2             	movslq %edx,%r10
  800efd:	eb 5c                	jmp    800f5b <strtol+0xa5>
    s++;
  800eff:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f03:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f09:	eb d3                	jmp    800ede <strtol+0x28>
    s++, neg = 1;
  800f0b:	48 83 c7 01          	add    $0x1,%rdi
  800f0f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f15:	eb c7                	jmp    800ede <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f17:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f1b:	74 0f                	je     800f2c <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f1d:	85 d2                	test   %edx,%edx
  800f1f:	75 d4                	jne    800ef5 <strtol+0x3f>
    s++, base = 8;
  800f21:	48 83 c7 01          	add    $0x1,%rdi
  800f25:	ba 08 00 00 00       	mov    $0x8,%edx
  800f2a:	eb c9                	jmp    800ef5 <strtol+0x3f>
    s += 2, base = 16;
  800f2c:	48 83 c7 02          	add    $0x2,%rdi
  800f30:	ba 10 00 00 00       	mov    $0x10,%edx
  800f35:	eb be                	jmp    800ef5 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f37:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f3b:	41 80 f8 19          	cmp    $0x19,%r8b
  800f3f:	77 2f                	ja     800f70 <strtol+0xba>
      dig = *s - 'a' + 10;
  800f41:	44 0f be c1          	movsbl %cl,%r8d
  800f45:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f49:	39 d1                	cmp    %edx,%ecx
  800f4b:	7d 37                	jge    800f84 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f4d:	48 83 c7 01          	add    $0x1,%rdi
  800f51:	49 0f af c2          	imul   %r10,%rax
  800f55:	48 63 c9             	movslq %ecx,%rcx
  800f58:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f5b:	0f b6 0f             	movzbl (%rdi),%ecx
  800f5e:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f62:	41 80 f8 09          	cmp    $0x9,%r8b
  800f66:	77 cf                	ja     800f37 <strtol+0x81>
      dig = *s - '0';
  800f68:	0f be c9             	movsbl %cl,%ecx
  800f6b:	83 e9 30             	sub    $0x30,%ecx
  800f6e:	eb d9                	jmp    800f49 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f70:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f74:	41 80 f8 19          	cmp    $0x19,%r8b
  800f78:	77 0a                	ja     800f84 <strtol+0xce>
      dig = *s - 'A' + 10;
  800f7a:	44 0f be c1          	movsbl %cl,%r8d
  800f7e:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800f82:	eb c5                	jmp    800f49 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800f84:	48 85 f6             	test   %rsi,%rsi
  800f87:	74 03                	je     800f8c <strtol+0xd6>
    *endptr = (char *)s;
  800f89:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800f8c:	48 89 c2             	mov    %rax,%rdx
  800f8f:	48 f7 da             	neg    %rdx
  800f92:	45 85 c9             	test   %r9d,%r9d
  800f95:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800f99:	c3                   	retq   

0000000000800f9a <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800f9a:	55                   	push   %rbp
  800f9b:	48 89 e5             	mov    %rsp,%rbp
  800f9e:	53                   	push   %rbx
  800f9f:	48 89 fa             	mov    %rdi,%rdx
  800fa2:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800faa:	48 89 c3             	mov    %rax,%rbx
  800fad:	48 89 c7             	mov    %rax,%rdi
  800fb0:	48 89 c6             	mov    %rax,%rsi
  800fb3:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fb5:	5b                   	pop    %rbx
  800fb6:	5d                   	pop    %rbp
  800fb7:	c3                   	retq   

0000000000800fb8 <sys_cgetc>:

int
sys_cgetc(void) {
  800fb8:	55                   	push   %rbp
  800fb9:	48 89 e5             	mov    %rsp,%rbp
  800fbc:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc7:	48 89 ca             	mov    %rcx,%rdx
  800fca:	48 89 cb             	mov    %rcx,%rbx
  800fcd:	48 89 cf             	mov    %rcx,%rdi
  800fd0:	48 89 ce             	mov    %rcx,%rsi
  800fd3:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd5:	5b                   	pop    %rbx
  800fd6:	5d                   	pop    %rbp
  800fd7:	c3                   	retq   

0000000000800fd8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800fd8:	55                   	push   %rbp
  800fd9:	48 89 e5             	mov    %rsp,%rbp
  800fdc:	53                   	push   %rbx
  800fdd:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fe1:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800fe4:	be 00 00 00 00       	mov    $0x0,%esi
  800fe9:	b8 03 00 00 00       	mov    $0x3,%eax
  800fee:	48 89 f1             	mov    %rsi,%rcx
  800ff1:	48 89 f3             	mov    %rsi,%rbx
  800ff4:	48 89 f7             	mov    %rsi,%rdi
  800ff7:	cd 30                	int    $0x30
  if (check && ret > 0)
  800ff9:	48 85 c0             	test   %rax,%rax
  800ffc:	7f 07                	jg     801005 <sys_env_destroy+0x2d>
}
  800ffe:	48 83 c4 08          	add    $0x8,%rsp
  801002:	5b                   	pop    %rbx
  801003:	5d                   	pop    %rbp
  801004:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801005:	49 89 c0             	mov    %rax,%r8
  801008:	b9 03 00 00 00       	mov    $0x3,%ecx
  80100d:	48 ba 50 15 80 00 00 	movabs $0x801550,%rdx
  801014:	00 00 00 
  801017:	be 22 00 00 00       	mov    $0x22,%esi
  80101c:	48 bf 6f 15 80 00 00 	movabs $0x80156f,%rdi
  801023:	00 00 00 
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	49 b9 58 10 80 00 00 	movabs $0x801058,%r9
  801032:	00 00 00 
  801035:	41 ff d1             	callq  *%r9

0000000000801038 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801038:	55                   	push   %rbp
  801039:	48 89 e5             	mov    %rsp,%rbp
  80103c:	53                   	push   %rbx
  asm volatile("int %1\n"
  80103d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801042:	b8 02 00 00 00       	mov    $0x2,%eax
  801047:	48 89 ca             	mov    %rcx,%rdx
  80104a:	48 89 cb             	mov    %rcx,%rbx
  80104d:	48 89 cf             	mov    %rcx,%rdi
  801050:	48 89 ce             	mov    %rcx,%rsi
  801053:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801055:	5b                   	pop    %rbx
  801056:	5d                   	pop    %rbp
  801057:	c3                   	retq   

0000000000801058 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801058:	55                   	push   %rbp
  801059:	48 89 e5             	mov    %rsp,%rbp
  80105c:	41 56                	push   %r14
  80105e:	41 55                	push   %r13
  801060:	41 54                	push   %r12
  801062:	53                   	push   %rbx
  801063:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80106a:	49 89 fd             	mov    %rdi,%r13
  80106d:	41 89 f6             	mov    %esi,%r14d
  801070:	49 89 d4             	mov    %rdx,%r12
  801073:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80107a:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801081:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801088:	84 c0                	test   %al,%al
  80108a:	74 26                	je     8010b2 <_panic+0x5a>
  80108c:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  801093:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80109a:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80109e:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010a2:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010a6:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010aa:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010ae:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010b2:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010b9:	00 00 00 
  8010bc:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010c3:	00 00 00 
  8010c6:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010ca:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010d1:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8010d8:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8010df:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8010e6:	00 00 00 
  8010e9:	48 8b 18             	mov    (%rax),%rbx
  8010ec:	48 b8 38 10 80 00 00 	movabs $0x801038,%rax
  8010f3:	00 00 00 
  8010f6:	ff d0                	callq  *%rax
  8010f8:	45 89 f0             	mov    %r14d,%r8d
  8010fb:	4c 89 e9             	mov    %r13,%rcx
  8010fe:	48 89 da             	mov    %rbx,%rdx
  801101:	89 c6                	mov    %eax,%esi
  801103:	48 bf 80 15 80 00 00 	movabs $0x801580,%rdi
  80110a:	00 00 00 
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
  801112:	48 bb a6 01 80 00 00 	movabs $0x8001a6,%rbx
  801119:	00 00 00 
  80111c:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80111e:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801125:	4c 89 e7             	mov    %r12,%rdi
  801128:	48 b8 3e 01 80 00 00 	movabs $0x80013e,%rax
  80112f:	00 00 00 
  801132:	ff d0                	callq  *%rax
  cprintf("\n");
  801134:	48 bf a8 15 80 00 00 	movabs $0x8015a8,%rdi
  80113b:	00 00 00 
  80113e:	b8 00 00 00 00       	mov    $0x0,%eax
  801143:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801145:	cc                   	int3   
  while (1)
  801146:	eb fd                	jmp    801145 <_panic+0xed>
