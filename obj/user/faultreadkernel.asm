
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
  80003a:	48 bf 20 14 80 00 00 	movabs $0x801420,%rdi
  800041:	00 00 00 
  800044:	b8 00 00 00 00       	mov    $0x0,%eax
  800049:	48 ba d6 01 80 00 00 	movabs $0x8001d6,%rdx
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000a4:	48 b8 68 10 80 00 00 	movabs $0x801068,%rax
  8000ab:	00 00 00 
  8000ae:	ff d0                	callq  *%rax
  8000b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b5:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000b9:	48 c1 e0 05          	shl    $0x5,%rax
  8000bd:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000c4:	00 00 00 
  8000c7:	48 01 d0             	add    %rdx,%rax
  8000ca:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000d1:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000d4:	45 85 ed             	test   %r13d,%r13d
  8000d7:	7e 0d                	jle    8000e6 <libmain+0x8f>
    binaryname = argv[0];
  8000d9:	49 8b 06             	mov    (%r14),%rax
  8000dc:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000e3:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e6:	4c 89 f6             	mov    %r14,%rsi
  8000e9:	44 89 ef             	mov    %r13d,%edi
  8000ec:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f3:	00 00 00 
  8000f6:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f8:	48 b8 0d 01 80 00 00 	movabs $0x80010d,%rax
  8000ff:	00 00 00 
  800102:	ff d0                	callq  *%rax
#endif
}
  800104:	5b                   	pop    %rbx
  800105:	41 5c                	pop    %r12
  800107:	41 5d                	pop    %r13
  800109:	41 5e                	pop    %r14
  80010b:	5d                   	pop    %rbp
  80010c:	c3                   	retq   

000000000080010d <exit>:

#include <inc/lib.h>

void
exit(void) {
  80010d:	55                   	push   %rbp
  80010e:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800111:	bf 00 00 00 00       	mov    $0x0,%edi
  800116:	48 b8 08 10 80 00 00 	movabs $0x801008,%rax
  80011d:	00 00 00 
  800120:	ff d0                	callq  *%rax
}
  800122:	5d                   	pop    %rbp
  800123:	c3                   	retq   

0000000000800124 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800124:	55                   	push   %rbp
  800125:	48 89 e5             	mov    %rsp,%rbp
  800128:	53                   	push   %rbx
  800129:	48 83 ec 08          	sub    $0x8,%rsp
  80012d:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800130:	8b 06                	mov    (%rsi),%eax
  800132:	8d 50 01             	lea    0x1(%rax),%edx
  800135:	89 16                	mov    %edx,(%rsi)
  800137:	48 98                	cltq   
  800139:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80013e:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800144:	74 0b                	je     800151 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80014a:	48 83 c4 08          	add    $0x8,%rsp
  80014e:	5b                   	pop    %rbx
  80014f:	5d                   	pop    %rbp
  800150:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800151:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800155:	be ff 00 00 00       	mov    $0xff,%esi
  80015a:	48 b8 ca 0f 80 00 00 	movabs $0x800fca,%rax
  800161:	00 00 00 
  800164:	ff d0                	callq  *%rax
    b->idx = 0;
  800166:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80016c:	eb d8                	jmp    800146 <putch+0x22>

000000000080016e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80016e:	55                   	push   %rbp
  80016f:	48 89 e5             	mov    %rsp,%rbp
  800172:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800179:	48 89 fa             	mov    %rdi,%rdx
  80017c:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80017f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800186:	00 00 00 
  b.cnt = 0;
  800189:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800190:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800193:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80019a:	48 bf 24 01 80 00 00 	movabs $0x800124,%rdi
  8001a1:	00 00 00 
  8001a4:	48 b8 94 03 80 00 00 	movabs $0x800394,%rax
  8001ab:	00 00 00 
  8001ae:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001b0:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001b7:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001be:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001c2:	48 b8 ca 0f 80 00 00 	movabs $0x800fca,%rax
  8001c9:	00 00 00 
  8001cc:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001d4:	c9                   	leaveq 
  8001d5:	c3                   	retq   

00000000008001d6 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001d6:	55                   	push   %rbp
  8001d7:	48 89 e5             	mov    %rsp,%rbp
  8001da:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001e1:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001e8:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001ef:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001f6:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001fd:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800204:	84 c0                	test   %al,%al
  800206:	74 20                	je     800228 <cprintf+0x52>
  800208:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80020c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800210:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800214:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800218:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80021c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800220:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800224:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800228:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80022f:	00 00 00 
  800232:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800239:	00 00 00 
  80023c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800240:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800247:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80024e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800255:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80025c:	48 b8 6e 01 80 00 00 	movabs $0x80016e,%rax
  800263:	00 00 00 
  800266:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800268:	c9                   	leaveq 
  800269:	c3                   	retq   

000000000080026a <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80026a:	55                   	push   %rbp
  80026b:	48 89 e5             	mov    %rsp,%rbp
  80026e:	41 57                	push   %r15
  800270:	41 56                	push   %r14
  800272:	41 55                	push   %r13
  800274:	41 54                	push   %r12
  800276:	53                   	push   %rbx
  800277:	48 83 ec 18          	sub    $0x18,%rsp
  80027b:	49 89 fc             	mov    %rdi,%r12
  80027e:	49 89 f5             	mov    %rsi,%r13
  800281:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800285:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800288:	41 89 cf             	mov    %ecx,%r15d
  80028b:	49 39 d7             	cmp    %rdx,%r15
  80028e:	76 45                	jbe    8002d5 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800290:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7e 0e                	jle    8002a6 <printnum+0x3c>
      putch(padc, putdat);
  800298:	4c 89 ee             	mov    %r13,%rsi
  80029b:	44 89 f7             	mov    %r14d,%edi
  80029e:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	75 f2                	jne    800298 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002a6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002af:	49 f7 f7             	div    %r15
  8002b2:	48 b8 53 14 80 00 00 	movabs $0x801453,%rax
  8002b9:	00 00 00 
  8002bc:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002c0:	4c 89 ee             	mov    %r13,%rsi
  8002c3:	41 ff d4             	callq  *%r12
}
  8002c6:	48 83 c4 18          	add    $0x18,%rsp
  8002ca:	5b                   	pop    %rbx
  8002cb:	41 5c                	pop    %r12
  8002cd:	41 5d                	pop    %r13
  8002cf:	41 5e                	pop    %r14
  8002d1:	41 5f                	pop    %r15
  8002d3:	5d                   	pop    %rbp
  8002d4:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	49 f7 f7             	div    %r15
  8002e1:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002e5:	48 89 c2             	mov    %rax,%rdx
  8002e8:	48 b8 6a 02 80 00 00 	movabs $0x80026a,%rax
  8002ef:	00 00 00 
  8002f2:	ff d0                	callq  *%rax
  8002f4:	eb b0                	jmp    8002a6 <printnum+0x3c>

00000000008002f6 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002f6:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002fa:	48 8b 06             	mov    (%rsi),%rax
  8002fd:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800301:	73 0a                	jae    80030d <sprintputch+0x17>
    *b->buf++ = ch;
  800303:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800307:	48 89 16             	mov    %rdx,(%rsi)
  80030a:	40 88 38             	mov    %dil,(%rax)
}
  80030d:	c3                   	retq   

000000000080030e <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80030e:	55                   	push   %rbp
  80030f:	48 89 e5             	mov    %rsp,%rbp
  800312:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800319:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800320:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800327:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80032e:	84 c0                	test   %al,%al
  800330:	74 20                	je     800352 <printfmt+0x44>
  800332:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800336:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80033a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80033e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800342:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800346:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80034a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80034e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800352:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800359:	00 00 00 
  80035c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800363:	00 00 00 
  800366:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80036a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800371:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800378:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80037f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800386:	48 b8 94 03 80 00 00 	movabs $0x800394,%rax
  80038d:	00 00 00 
  800390:	ff d0                	callq  *%rax
}
  800392:	c9                   	leaveq 
  800393:	c3                   	retq   

0000000000800394 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800394:	55                   	push   %rbp
  800395:	48 89 e5             	mov    %rsp,%rbp
  800398:	41 57                	push   %r15
  80039a:	41 56                	push   %r14
  80039c:	41 55                	push   %r13
  80039e:	41 54                	push   %r12
  8003a0:	53                   	push   %rbx
  8003a1:	48 83 ec 48          	sub    $0x48,%rsp
  8003a5:	49 89 fd             	mov    %rdi,%r13
  8003a8:	49 89 f7             	mov    %rsi,%r15
  8003ab:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003ae:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003b2:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003b6:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003ba:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003be:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003c2:	41 0f b6 3e          	movzbl (%r14),%edi
  8003c6:	83 ff 25             	cmp    $0x25,%edi
  8003c9:	74 18                	je     8003e3 <vprintfmt+0x4f>
      if (ch == '\0')
  8003cb:	85 ff                	test   %edi,%edi
  8003cd:	0f 84 8c 06 00 00    	je     800a5f <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003d3:	4c 89 fe             	mov    %r15,%rsi
  8003d6:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003d9:	49 89 de             	mov    %rbx,%r14
  8003dc:	eb e0                	jmp    8003be <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003de:	49 89 de             	mov    %rbx,%r14
  8003e1:	eb db                	jmp    8003be <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003e3:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003e7:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003eb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003f2:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003f8:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003fc:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800401:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800407:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80040d:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800412:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800417:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80041b:	0f b6 13             	movzbl (%rbx),%edx
  80041e:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800421:	3c 55                	cmp    $0x55,%al
  800423:	0f 87 8b 05 00 00    	ja     8009b4 <vprintfmt+0x620>
  800429:	0f b6 c0             	movzbl %al,%eax
  80042c:	49 bb 20 15 80 00 00 	movabs $0x801520,%r11
  800433:	00 00 00 
  800436:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80043a:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80043d:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800441:	eb d4                	jmp    800417 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800443:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800446:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80044a:	eb cb                	jmp    800417 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80044c:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80044f:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800453:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800457:	8d 50 d0             	lea    -0x30(%rax),%edx
  80045a:	83 fa 09             	cmp    $0x9,%edx
  80045d:	77 7e                	ja     8004dd <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80045f:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800463:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800467:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80046c:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800470:	8d 50 d0             	lea    -0x30(%rax),%edx
  800473:	83 fa 09             	cmp    $0x9,%edx
  800476:	76 e7                	jbe    80045f <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800478:	4c 89 f3             	mov    %r14,%rbx
  80047b:	eb 19                	jmp    800496 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80047d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800480:	83 f8 2f             	cmp    $0x2f,%eax
  800483:	77 2a                	ja     8004af <vprintfmt+0x11b>
  800485:	89 c2                	mov    %eax,%edx
  800487:	4c 01 d2             	add    %r10,%rdx
  80048a:	83 c0 08             	add    $0x8,%eax
  80048d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800490:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800493:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800496:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80049a:	0f 89 77 ff ff ff    	jns    800417 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004a0:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004a4:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004aa:	e9 68 ff ff ff       	jmpq   800417 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004af:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004b3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004b7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004bb:	eb d3                	jmp    800490 <vprintfmt+0xfc>
        if (width < 0)
  8004bd:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004c6:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004c9:	4c 89 f3             	mov    %r14,%rbx
  8004cc:	e9 46 ff ff ff       	jmpq   800417 <vprintfmt+0x83>
  8004d1:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004d4:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004d8:	e9 3a ff ff ff       	jmpq   800417 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004dd:	4c 89 f3             	mov    %r14,%rbx
  8004e0:	eb b4                	jmp    800496 <vprintfmt+0x102>
        lflag++;
  8004e2:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004e5:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004e8:	e9 2a ff ff ff       	jmpq   800417 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004ed:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004f0:	83 f8 2f             	cmp    $0x2f,%eax
  8004f3:	77 19                	ja     80050e <vprintfmt+0x17a>
  8004f5:	89 c2                	mov    %eax,%edx
  8004f7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004fb:	83 c0 08             	add    $0x8,%eax
  8004fe:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800501:	4c 89 fe             	mov    %r15,%rsi
  800504:	8b 3a                	mov    (%rdx),%edi
  800506:	41 ff d5             	callq  *%r13
        break;
  800509:	e9 b0 fe ff ff       	jmpq   8003be <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80050e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800512:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800516:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80051a:	eb e5                	jmp    800501 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80051c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80051f:	83 f8 2f             	cmp    $0x2f,%eax
  800522:	77 5b                	ja     80057f <vprintfmt+0x1eb>
  800524:	89 c2                	mov    %eax,%edx
  800526:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80052a:	83 c0 08             	add    $0x8,%eax
  80052d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800530:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800532:	89 c8                	mov    %ecx,%eax
  800534:	c1 f8 1f             	sar    $0x1f,%eax
  800537:	31 c1                	xor    %eax,%ecx
  800539:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053b:	83 f9 0b             	cmp    $0xb,%ecx
  80053e:	7f 4d                	jg     80058d <vprintfmt+0x1f9>
  800540:	48 63 c1             	movslq %ecx,%rax
  800543:	48 ba e0 17 80 00 00 	movabs $0x8017e0,%rdx
  80054a:	00 00 00 
  80054d:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800551:	48 85 c0             	test   %rax,%rax
  800554:	74 37                	je     80058d <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800556:	48 89 c1             	mov    %rax,%rcx
  800559:	48 ba 74 14 80 00 00 	movabs $0x801474,%rdx
  800560:	00 00 00 
  800563:	4c 89 fe             	mov    %r15,%rsi
  800566:	4c 89 ef             	mov    %r13,%rdi
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
  80056e:	48 bb 0e 03 80 00 00 	movabs $0x80030e,%rbx
  800575:	00 00 00 
  800578:	ff d3                	callq  *%rbx
  80057a:	e9 3f fe ff ff       	jmpq   8003be <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80057f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800583:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800587:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80058b:	eb a3                	jmp    800530 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80058d:	48 ba 6b 14 80 00 00 	movabs $0x80146b,%rdx
  800594:	00 00 00 
  800597:	4c 89 fe             	mov    %r15,%rsi
  80059a:	4c 89 ef             	mov    %r13,%rdi
  80059d:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a2:	48 bb 0e 03 80 00 00 	movabs $0x80030e,%rbx
  8005a9:	00 00 00 
  8005ac:	ff d3                	callq  *%rbx
  8005ae:	e9 0b fe ff ff       	jmpq   8003be <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005b3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005b6:	83 f8 2f             	cmp    $0x2f,%eax
  8005b9:	77 4b                	ja     800606 <vprintfmt+0x272>
  8005bb:	89 c2                	mov    %eax,%edx
  8005bd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005c1:	83 c0 08             	add    $0x8,%eax
  8005c4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005c7:	48 8b 02             	mov    (%rdx),%rax
  8005ca:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005ce:	48 85 c0             	test   %rax,%rax
  8005d1:	0f 84 05 04 00 00    	je     8009dc <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005d7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005db:	7e 06                	jle    8005e3 <vprintfmt+0x24f>
  8005dd:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005e1:	75 31                	jne    800614 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005e7:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005eb:	0f b6 00             	movzbl (%rax),%eax
  8005ee:	0f be f8             	movsbl %al,%edi
  8005f1:	85 ff                	test   %edi,%edi
  8005f3:	0f 84 c3 00 00 00    	je     8006bc <vprintfmt+0x328>
  8005f9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005fd:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800601:	e9 85 00 00 00       	jmpq   80068b <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800606:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80060a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80060e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800612:	eb b3                	jmp    8005c7 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800614:	49 63 f4             	movslq %r12d,%rsi
  800617:	48 89 c7             	mov    %rax,%rdi
  80061a:	48 b8 6b 0b 80 00 00 	movabs $0x800b6b,%rax
  800621:	00 00 00 
  800624:	ff d0                	callq  *%rax
  800626:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800629:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80062c:	85 f6                	test   %esi,%esi
  80062e:	7e 22                	jle    800652 <vprintfmt+0x2be>
            putch(padc, putdat);
  800630:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800634:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800638:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80063c:	4c 89 fe             	mov    %r15,%rsi
  80063f:	89 df                	mov    %ebx,%edi
  800641:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800644:	41 83 ec 01          	sub    $0x1,%r12d
  800648:	75 f2                	jne    80063c <vprintfmt+0x2a8>
  80064a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80064e:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800652:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800656:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80065a:	0f b6 00             	movzbl (%rax),%eax
  80065d:	0f be f8             	movsbl %al,%edi
  800660:	85 ff                	test   %edi,%edi
  800662:	0f 84 56 fd ff ff    	je     8003be <vprintfmt+0x2a>
  800668:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80066c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800670:	eb 19                	jmp    80068b <vprintfmt+0x2f7>
            putch(ch, putdat);
  800672:	4c 89 fe             	mov    %r15,%rsi
  800675:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800678:	41 83 ee 01          	sub    $0x1,%r14d
  80067c:	48 83 c3 01          	add    $0x1,%rbx
  800680:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800684:	0f be f8             	movsbl %al,%edi
  800687:	85 ff                	test   %edi,%edi
  800689:	74 29                	je     8006b4 <vprintfmt+0x320>
  80068b:	45 85 e4             	test   %r12d,%r12d
  80068e:	78 06                	js     800696 <vprintfmt+0x302>
  800690:	41 83 ec 01          	sub    $0x1,%r12d
  800694:	78 48                	js     8006de <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800696:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80069a:	74 d6                	je     800672 <vprintfmt+0x2de>
  80069c:	0f be c0             	movsbl %al,%eax
  80069f:	83 e8 20             	sub    $0x20,%eax
  8006a2:	83 f8 5e             	cmp    $0x5e,%eax
  8006a5:	76 cb                	jbe    800672 <vprintfmt+0x2de>
            putch('?', putdat);
  8006a7:	4c 89 fe             	mov    %r15,%rsi
  8006aa:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006af:	41 ff d5             	callq  *%r13
  8006b2:	eb c4                	jmp    800678 <vprintfmt+0x2e4>
  8006b4:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006b8:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006bc:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006bf:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006c3:	0f 8e f5 fc ff ff    	jle    8003be <vprintfmt+0x2a>
          putch(' ', putdat);
  8006c9:	4c 89 fe             	mov    %r15,%rsi
  8006cc:	bf 20 00 00 00       	mov    $0x20,%edi
  8006d1:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006d4:	83 eb 01             	sub    $0x1,%ebx
  8006d7:	75 f0                	jne    8006c9 <vprintfmt+0x335>
  8006d9:	e9 e0 fc ff ff       	jmpq   8003be <vprintfmt+0x2a>
  8006de:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006e2:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006e6:	eb d4                	jmp    8006bc <vprintfmt+0x328>
  if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	7f 1d                	jg     80070a <vprintfmt+0x376>
  else if (lflag)
  8006ed:	85 c9                	test   %ecx,%ecx
  8006ef:	74 5e                	je     80074f <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006f4:	83 f8 2f             	cmp    $0x2f,%eax
  8006f7:	77 48                	ja     800741 <vprintfmt+0x3ad>
  8006f9:	89 c2                	mov    %eax,%edx
  8006fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006ff:	83 c0 08             	add    $0x8,%eax
  800702:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800705:	48 8b 1a             	mov    (%rdx),%rbx
  800708:	eb 17                	jmp    800721 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80070a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80070d:	83 f8 2f             	cmp    $0x2f,%eax
  800710:	77 21                	ja     800733 <vprintfmt+0x39f>
  800712:	89 c2                	mov    %eax,%edx
  800714:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800718:	83 c0 08             	add    $0x8,%eax
  80071b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80071e:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800721:	48 85 db             	test   %rbx,%rbx
  800724:	78 50                	js     800776 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800726:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800729:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072e:	e9 b4 01 00 00       	jmpq   8008e7 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800733:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800737:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80073b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073f:	eb dd                	jmp    80071e <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800741:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800745:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800749:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074d:	eb b6                	jmp    800705 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80074f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800752:	83 f8 2f             	cmp    $0x2f,%eax
  800755:	77 11                	ja     800768 <vprintfmt+0x3d4>
  800757:	89 c2                	mov    %eax,%edx
  800759:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80075d:	83 c0 08             	add    $0x8,%eax
  800760:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800763:	48 63 1a             	movslq (%rdx),%rbx
  800766:	eb b9                	jmp    800721 <vprintfmt+0x38d>
  800768:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80076c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800770:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800774:	eb ed                	jmp    800763 <vprintfmt+0x3cf>
          putch('-', putdat);
  800776:	4c 89 fe             	mov    %r15,%rsi
  800779:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80077e:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800781:	48 89 da             	mov    %rbx,%rdx
  800784:	48 f7 da             	neg    %rdx
        base = 10;
  800787:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078c:	e9 56 01 00 00       	jmpq   8008e7 <vprintfmt+0x553>
  if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7f 25                	jg     8007bb <vprintfmt+0x427>
  else if (lflag)
  800796:	85 c9                	test   %ecx,%ecx
  800798:	74 5e                	je     8007f8 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80079a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80079d:	83 f8 2f             	cmp    $0x2f,%eax
  8007a0:	77 48                	ja     8007ea <vprintfmt+0x456>
  8007a2:	89 c2                	mov    %eax,%edx
  8007a4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a8:	83 c0 08             	add    $0x8,%eax
  8007ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ae:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b6:	e9 2c 01 00 00       	jmpq   8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007bb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007be:	83 f8 2f             	cmp    $0x2f,%eax
  8007c1:	77 19                	ja     8007dc <vprintfmt+0x448>
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007c9:	83 c0 08             	add    $0x8,%eax
  8007cc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007cf:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d7:	e9 0b 01 00 00       	jmpq   8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007dc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e8:	eb e5                	jmp    8007cf <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007ea:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ee:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007f2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f6:	eb b6                	jmp    8007ae <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007f8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007fb:	83 f8 2f             	cmp    $0x2f,%eax
  8007fe:	77 18                	ja     800818 <vprintfmt+0x484>
  800800:	89 c2                	mov    %eax,%edx
  800802:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800806:	83 c0 08             	add    $0x8,%eax
  800809:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80080c:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80080e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800813:	e9 cf 00 00 00       	jmpq   8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800818:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80081c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800820:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800824:	eb e6                	jmp    80080c <vprintfmt+0x478>
  if (lflag >= 2)
  800826:	83 f9 01             	cmp    $0x1,%ecx
  800829:	7f 25                	jg     800850 <vprintfmt+0x4bc>
  else if (lflag)
  80082b:	85 c9                	test   %ecx,%ecx
  80082d:	74 5b                	je     80088a <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80082f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800832:	83 f8 2f             	cmp    $0x2f,%eax
  800835:	77 45                	ja     80087c <vprintfmt+0x4e8>
  800837:	89 c2                	mov    %eax,%edx
  800839:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80083d:	83 c0 08             	add    $0x8,%eax
  800840:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800843:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800846:	b9 08 00 00 00       	mov    $0x8,%ecx
  80084b:	e9 97 00 00 00       	jmpq   8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800850:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800853:	83 f8 2f             	cmp    $0x2f,%eax
  800856:	77 16                	ja     80086e <vprintfmt+0x4da>
  800858:	89 c2                	mov    %eax,%edx
  80085a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80085e:	83 c0 08             	add    $0x8,%eax
  800861:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800864:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800867:	b9 08 00 00 00       	mov    $0x8,%ecx
  80086c:	eb 79                	jmp    8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80086e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800872:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800876:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80087a:	eb e8                	jmp    800864 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80087c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800880:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800884:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800888:	eb b9                	jmp    800843 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  80088a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80088d:	83 f8 2f             	cmp    $0x2f,%eax
  800890:	77 15                	ja     8008a7 <vprintfmt+0x513>
  800892:	89 c2                	mov    %eax,%edx
  800894:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800898:	83 c0 08             	add    $0x8,%eax
  80089b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80089e:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008a0:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008a5:	eb 40                	jmp    8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008a7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008af:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b3:	eb e9                	jmp    80089e <vprintfmt+0x50a>
        putch('0', putdat);
  8008b5:	4c 89 fe             	mov    %r15,%rsi
  8008b8:	bf 30 00 00 00       	mov    $0x30,%edi
  8008bd:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008c0:	4c 89 fe             	mov    %r15,%rsi
  8008c3:	bf 78 00 00 00       	mov    $0x78,%edi
  8008c8:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008cb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ce:	83 f8 2f             	cmp    $0x2f,%eax
  8008d1:	77 34                	ja     800907 <vprintfmt+0x573>
  8008d3:	89 c2                	mov    %eax,%edx
  8008d5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d9:	83 c0 08             	add    $0x8,%eax
  8008dc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008df:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008e2:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008e7:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008ec:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008f0:	4c 89 fe             	mov    %r15,%rsi
  8008f3:	4c 89 ef             	mov    %r13,%rdi
  8008f6:	48 b8 6a 02 80 00 00 	movabs $0x80026a,%rax
  8008fd:	00 00 00 
  800900:	ff d0                	callq  *%rax
        break;
  800902:	e9 b7 fa ff ff       	jmpq   8003be <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800907:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80090f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800913:	eb ca                	jmp    8008df <vprintfmt+0x54b>
  if (lflag >= 2)
  800915:	83 f9 01             	cmp    $0x1,%ecx
  800918:	7f 22                	jg     80093c <vprintfmt+0x5a8>
  else if (lflag)
  80091a:	85 c9                	test   %ecx,%ecx
  80091c:	74 58                	je     800976 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80091e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800921:	83 f8 2f             	cmp    $0x2f,%eax
  800924:	77 42                	ja     800968 <vprintfmt+0x5d4>
  800926:	89 c2                	mov    %eax,%edx
  800928:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092c:	83 c0 08             	add    $0x8,%eax
  80092f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800932:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800935:	b9 10 00 00 00       	mov    $0x10,%ecx
  80093a:	eb ab                	jmp    8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80093c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093f:	83 f8 2f             	cmp    $0x2f,%eax
  800942:	77 16                	ja     80095a <vprintfmt+0x5c6>
  800944:	89 c2                	mov    %eax,%edx
  800946:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094a:	83 c0 08             	add    $0x8,%eax
  80094d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800950:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800953:	b9 10 00 00 00       	mov    $0x10,%ecx
  800958:	eb 8d                	jmp    8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80095a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800962:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800966:	eb e8                	jmp    800950 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800968:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800970:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800974:	eb bc                	jmp    800932 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800976:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800979:	83 f8 2f             	cmp    $0x2f,%eax
  80097c:	77 18                	ja     800996 <vprintfmt+0x602>
  80097e:	89 c2                	mov    %eax,%edx
  800980:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800984:	83 c0 08             	add    $0x8,%eax
  800987:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80098a:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80098c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800991:	e9 51 ff ff ff       	jmpq   8008e7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800996:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80099a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a2:	eb e6                	jmp    80098a <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009a4:	4c 89 fe             	mov    %r15,%rsi
  8009a7:	bf 25 00 00 00       	mov    $0x25,%edi
  8009ac:	41 ff d5             	callq  *%r13
        break;
  8009af:	e9 0a fa ff ff       	jmpq   8003be <vprintfmt+0x2a>
        putch('%', putdat);
  8009b4:	4c 89 fe             	mov    %r15,%rsi
  8009b7:	bf 25 00 00 00       	mov    $0x25,%edi
  8009bc:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009c3:	0f 84 15 fa ff ff    	je     8003de <vprintfmt+0x4a>
  8009c9:	49 89 de             	mov    %rbx,%r14
  8009cc:	49 83 ee 01          	sub    $0x1,%r14
  8009d0:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009d5:	75 f5                	jne    8009cc <vprintfmt+0x638>
  8009d7:	e9 e2 f9 ff ff       	jmpq   8003be <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009dc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009e0:	74 06                	je     8009e8 <vprintfmt+0x654>
  8009e2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009e6:	7f 21                	jg     800a09 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e8:	bf 28 00 00 00       	mov    $0x28,%edi
  8009ed:	48 bb 65 14 80 00 00 	movabs $0x801465,%rbx
  8009f4:	00 00 00 
  8009f7:	b8 28 00 00 00       	mov    $0x28,%eax
  8009fc:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a00:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a04:	e9 82 fc ff ff       	jmpq   80068b <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a09:	49 63 f4             	movslq %r12d,%rsi
  800a0c:	48 bf 64 14 80 00 00 	movabs $0x801464,%rdi
  800a13:	00 00 00 
  800a16:	48 b8 6b 0b 80 00 00 	movabs $0x800b6b,%rax
  800a1d:	00 00 00 
  800a20:	ff d0                	callq  *%rax
  800a22:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a25:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a28:	48 be 64 14 80 00 00 	movabs $0x801464,%rsi
  800a2f:	00 00 00 
  800a32:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a36:	85 c0                	test   %eax,%eax
  800a38:	0f 8f f2 fb ff ff    	jg     800630 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3e:	48 bb 65 14 80 00 00 	movabs $0x801465,%rbx
  800a45:	00 00 00 
  800a48:	b8 28 00 00 00       	mov    $0x28,%eax
  800a4d:	bf 28 00 00 00       	mov    $0x28,%edi
  800a52:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a56:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a5a:	e9 2c fc ff ff       	jmpq   80068b <vprintfmt+0x2f7>
}
  800a5f:	48 83 c4 48          	add    $0x48,%rsp
  800a63:	5b                   	pop    %rbx
  800a64:	41 5c                	pop    %r12
  800a66:	41 5d                	pop    %r13
  800a68:	41 5e                	pop    %r14
  800a6a:	41 5f                	pop    %r15
  800a6c:	5d                   	pop    %rbp
  800a6d:	c3                   	retq   

0000000000800a6e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a6e:	55                   	push   %rbp
  800a6f:	48 89 e5             	mov    %rsp,%rbp
  800a72:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a76:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a7a:	48 63 c6             	movslq %esi,%rax
  800a7d:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a82:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a86:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a8d:	48 85 ff             	test   %rdi,%rdi
  800a90:	74 2a                	je     800abc <vsnprintf+0x4e>
  800a92:	85 f6                	test   %esi,%esi
  800a94:	7e 26                	jle    800abc <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a96:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a9a:	48 bf f6 02 80 00 00 	movabs $0x8002f6,%rdi
  800aa1:	00 00 00 
  800aa4:	48 b8 94 03 80 00 00 	movabs $0x800394,%rax
  800aab:	00 00 00 
  800aae:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ab0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ab4:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ab7:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800aba:	c9                   	leaveq 
  800abb:	c3                   	retq   
    return -E_INVAL;
  800abc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac1:	eb f7                	jmp    800aba <vsnprintf+0x4c>

0000000000800ac3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ac3:	55                   	push   %rbp
  800ac4:	48 89 e5             	mov    %rsp,%rbp
  800ac7:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ace:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ad5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800adc:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ae3:	84 c0                	test   %al,%al
  800ae5:	74 20                	je     800b07 <snprintf+0x44>
  800ae7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800aeb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800aef:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800af3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800af7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800afb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800aff:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b03:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b07:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b0e:	00 00 00 
  800b11:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b18:	00 00 00 
  800b1b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b1f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b26:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b2d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b34:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b3b:	48 b8 6e 0a 80 00 00 	movabs $0x800a6e,%rax
  800b42:	00 00 00 
  800b45:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b47:	c9                   	leaveq 
  800b48:	c3                   	retq   

0000000000800b49 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b49:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b4c:	74 17                	je     800b65 <strlen+0x1c>
  800b4e:	48 89 fa             	mov    %rdi,%rdx
  800b51:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b56:	29 f9                	sub    %edi,%ecx
    n++;
  800b58:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b5b:	48 83 c2 01          	add    $0x1,%rdx
  800b5f:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b62:	75 f4                	jne    800b58 <strlen+0xf>
  800b64:	c3                   	retq   
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b6a:	c3                   	retq   

0000000000800b6b <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b6b:	48 85 f6             	test   %rsi,%rsi
  800b6e:	74 24                	je     800b94 <strnlen+0x29>
  800b70:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b73:	74 25                	je     800b9a <strnlen+0x2f>
  800b75:	48 01 fe             	add    %rdi,%rsi
  800b78:	48 89 fa             	mov    %rdi,%rdx
  800b7b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b80:	29 f9                	sub    %edi,%ecx
    n++;
  800b82:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b85:	48 83 c2 01          	add    $0x1,%rdx
  800b89:	48 39 f2             	cmp    %rsi,%rdx
  800b8c:	74 11                	je     800b9f <strnlen+0x34>
  800b8e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b91:	75 ef                	jne    800b82 <strnlen+0x17>
  800b93:	c3                   	retq   
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	c3                   	retq   
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b9f:	c3                   	retq   

0000000000800ba0 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800ba0:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bac:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800baf:	48 83 c2 01          	add    $0x1,%rdx
  800bb3:	84 c9                	test   %cl,%cl
  800bb5:	75 f1                	jne    800ba8 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bb7:	c3                   	retq   

0000000000800bb8 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bb8:	55                   	push   %rbp
  800bb9:	48 89 e5             	mov    %rsp,%rbp
  800bbc:	41 54                	push   %r12
  800bbe:	53                   	push   %rbx
  800bbf:	48 89 fb             	mov    %rdi,%rbx
  800bc2:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bc5:	48 b8 49 0b 80 00 00 	movabs $0x800b49,%rax
  800bcc:	00 00 00 
  800bcf:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bd1:	48 63 f8             	movslq %eax,%rdi
  800bd4:	48 01 df             	add    %rbx,%rdi
  800bd7:	4c 89 e6             	mov    %r12,%rsi
  800bda:	48 b8 a0 0b 80 00 00 	movabs $0x800ba0,%rax
  800be1:	00 00 00 
  800be4:	ff d0                	callq  *%rax
  return dst;
}
  800be6:	48 89 d8             	mov    %rbx,%rax
  800be9:	5b                   	pop    %rbx
  800bea:	41 5c                	pop    %r12
  800bec:	5d                   	pop    %rbp
  800bed:	c3                   	retq   

0000000000800bee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bee:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bf1:	48 85 d2             	test   %rdx,%rdx
  800bf4:	74 1f                	je     800c15 <strncpy+0x27>
  800bf6:	48 01 fa             	add    %rdi,%rdx
  800bf9:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bfc:	48 83 c1 01          	add    $0x1,%rcx
  800c00:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c04:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c08:	41 80 f8 01          	cmp    $0x1,%r8b
  800c0c:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c10:	48 39 ca             	cmp    %rcx,%rdx
  800c13:	75 e7                	jne    800bfc <strncpy+0xe>
  }
  return ret;
}
  800c15:	c3                   	retq   

0000000000800c16 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c16:	48 89 f8             	mov    %rdi,%rax
  800c19:	48 85 d2             	test   %rdx,%rdx
  800c1c:	74 36                	je     800c54 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c1e:	48 83 fa 01          	cmp    $0x1,%rdx
  800c22:	74 2d                	je     800c51 <strlcpy+0x3b>
  800c24:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c28:	45 84 c0             	test   %r8b,%r8b
  800c2b:	74 24                	je     800c51 <strlcpy+0x3b>
  800c2d:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c31:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c36:	48 83 c0 01          	add    $0x1,%rax
  800c3a:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c3e:	48 39 d1             	cmp    %rdx,%rcx
  800c41:	74 0e                	je     800c51 <strlcpy+0x3b>
  800c43:	48 83 c1 01          	add    $0x1,%rcx
  800c47:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c4c:	45 84 c0             	test   %r8b,%r8b
  800c4f:	75 e5                	jne    800c36 <strlcpy+0x20>
    *dst = '\0';
  800c51:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c54:	48 29 f8             	sub    %rdi,%rax
}
  800c57:	c3                   	retq   

0000000000800c58 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c58:	0f b6 07             	movzbl (%rdi),%eax
  800c5b:	84 c0                	test   %al,%al
  800c5d:	74 17                	je     800c76 <strcmp+0x1e>
  800c5f:	3a 06                	cmp    (%rsi),%al
  800c61:	75 13                	jne    800c76 <strcmp+0x1e>
    p++, q++;
  800c63:	48 83 c7 01          	add    $0x1,%rdi
  800c67:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c6b:	0f b6 07             	movzbl (%rdi),%eax
  800c6e:	84 c0                	test   %al,%al
  800c70:	74 04                	je     800c76 <strcmp+0x1e>
  800c72:	3a 06                	cmp    (%rsi),%al
  800c74:	74 ed                	je     800c63 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c76:	0f b6 c0             	movzbl %al,%eax
  800c79:	0f b6 16             	movzbl (%rsi),%edx
  800c7c:	29 d0                	sub    %edx,%eax
}
  800c7e:	c3                   	retq   

0000000000800c7f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c7f:	48 85 d2             	test   %rdx,%rdx
  800c82:	74 2f                	je     800cb3 <strncmp+0x34>
  800c84:	0f b6 07             	movzbl (%rdi),%eax
  800c87:	84 c0                	test   %al,%al
  800c89:	74 1f                	je     800caa <strncmp+0x2b>
  800c8b:	3a 06                	cmp    (%rsi),%al
  800c8d:	75 1b                	jne    800caa <strncmp+0x2b>
  800c8f:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c92:	48 83 c7 01          	add    $0x1,%rdi
  800c96:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c9a:	48 39 d7             	cmp    %rdx,%rdi
  800c9d:	74 1a                	je     800cb9 <strncmp+0x3a>
  800c9f:	0f b6 07             	movzbl (%rdi),%eax
  800ca2:	84 c0                	test   %al,%al
  800ca4:	74 04                	je     800caa <strncmp+0x2b>
  800ca6:	3a 06                	cmp    (%rsi),%al
  800ca8:	74 e8                	je     800c92 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800caa:	0f b6 07             	movzbl (%rdi),%eax
  800cad:	0f b6 16             	movzbl (%rsi),%edx
  800cb0:	29 d0                	sub    %edx,%eax
}
  800cb2:	c3                   	retq   
    return 0;
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	c3                   	retq   
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbe:	c3                   	retq   

0000000000800cbf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cbf:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cc1:	0f b6 07             	movzbl (%rdi),%eax
  800cc4:	84 c0                	test   %al,%al
  800cc6:	74 1e                	je     800ce6 <strchr+0x27>
    if (*s == c)
  800cc8:	40 38 c6             	cmp    %al,%sil
  800ccb:	74 1f                	je     800cec <strchr+0x2d>
  for (; *s; s++)
  800ccd:	48 83 c7 01          	add    $0x1,%rdi
  800cd1:	0f b6 07             	movzbl (%rdi),%eax
  800cd4:	84 c0                	test   %al,%al
  800cd6:	74 08                	je     800ce0 <strchr+0x21>
    if (*s == c)
  800cd8:	38 d0                	cmp    %dl,%al
  800cda:	75 f1                	jne    800ccd <strchr+0xe>
  for (; *s; s++)
  800cdc:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cdf:	c3                   	retq   
  return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce5:	c3                   	retq   
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	c3                   	retq   
    if (*s == c)
  800cec:	48 89 f8             	mov    %rdi,%rax
  800cef:	c3                   	retq   

0000000000800cf0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cf0:	48 89 f8             	mov    %rdi,%rax
  800cf3:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cf5:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cf8:	40 38 f2             	cmp    %sil,%dl
  800cfb:	74 13                	je     800d10 <strfind+0x20>
  800cfd:	84 d2                	test   %dl,%dl
  800cff:	74 0f                	je     800d10 <strfind+0x20>
  for (; *s; s++)
  800d01:	48 83 c0 01          	add    $0x1,%rax
  800d05:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d08:	38 ca                	cmp    %cl,%dl
  800d0a:	74 04                	je     800d10 <strfind+0x20>
  800d0c:	84 d2                	test   %dl,%dl
  800d0e:	75 f1                	jne    800d01 <strfind+0x11>
      break;
  return (char *)s;
}
  800d10:	c3                   	retq   

0000000000800d11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d11:	48 85 d2             	test   %rdx,%rdx
  800d14:	74 3a                	je     800d50 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d16:	48 89 f8             	mov    %rdi,%rax
  800d19:	48 09 d0             	or     %rdx,%rax
  800d1c:	a8 03                	test   $0x3,%al
  800d1e:	75 28                	jne    800d48 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d20:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d24:	89 f0                	mov    %esi,%eax
  800d26:	c1 e0 08             	shl    $0x8,%eax
  800d29:	89 f1                	mov    %esi,%ecx
  800d2b:	c1 e1 18             	shl    $0x18,%ecx
  800d2e:	41 89 f0             	mov    %esi,%r8d
  800d31:	41 c1 e0 10          	shl    $0x10,%r8d
  800d35:	44 09 c1             	or     %r8d,%ecx
  800d38:	09 ce                	or     %ecx,%esi
  800d3a:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d3c:	48 c1 ea 02          	shr    $0x2,%rdx
  800d40:	48 89 d1             	mov    %rdx,%rcx
  800d43:	fc                   	cld    
  800d44:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d46:	eb 08                	jmp    800d50 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d48:	89 f0                	mov    %esi,%eax
  800d4a:	48 89 d1             	mov    %rdx,%rcx
  800d4d:	fc                   	cld    
  800d4e:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d50:	48 89 f8             	mov    %rdi,%rax
  800d53:	c3                   	retq   

0000000000800d54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d54:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d57:	48 39 fe             	cmp    %rdi,%rsi
  800d5a:	73 40                	jae    800d9c <memmove+0x48>
  800d5c:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d60:	48 39 f9             	cmp    %rdi,%rcx
  800d63:	76 37                	jbe    800d9c <memmove+0x48>
    s += n;
    d += n;
  800d65:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d69:	48 89 fe             	mov    %rdi,%rsi
  800d6c:	48 09 d6             	or     %rdx,%rsi
  800d6f:	48 09 ce             	or     %rcx,%rsi
  800d72:	40 f6 c6 03          	test   $0x3,%sil
  800d76:	75 14                	jne    800d8c <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d78:	48 83 ef 04          	sub    $0x4,%rdi
  800d7c:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d80:	48 c1 ea 02          	shr    $0x2,%rdx
  800d84:	48 89 d1             	mov    %rdx,%rcx
  800d87:	fd                   	std    
  800d88:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d8a:	eb 0e                	jmp    800d9a <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d8c:	48 83 ef 01          	sub    $0x1,%rdi
  800d90:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d94:	48 89 d1             	mov    %rdx,%rcx
  800d97:	fd                   	std    
  800d98:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d9a:	fc                   	cld    
  800d9b:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d9c:	48 89 c1             	mov    %rax,%rcx
  800d9f:	48 09 d1             	or     %rdx,%rcx
  800da2:	48 09 f1             	or     %rsi,%rcx
  800da5:	f6 c1 03             	test   $0x3,%cl
  800da8:	75 0e                	jne    800db8 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800daa:	48 c1 ea 02          	shr    $0x2,%rdx
  800dae:	48 89 d1             	mov    %rdx,%rcx
  800db1:	48 89 c7             	mov    %rax,%rdi
  800db4:	fc                   	cld    
  800db5:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800db7:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800db8:	48 89 c7             	mov    %rax,%rdi
  800dbb:	48 89 d1             	mov    %rdx,%rcx
  800dbe:	fc                   	cld    
  800dbf:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dc1:	c3                   	retq   

0000000000800dc2 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dc2:	55                   	push   %rbp
  800dc3:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dc6:	48 b8 54 0d 80 00 00 	movabs $0x800d54,%rax
  800dcd:	00 00 00 
  800dd0:	ff d0                	callq  *%rax
}
  800dd2:	5d                   	pop    %rbp
  800dd3:	c3                   	retq   

0000000000800dd4 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dd4:	55                   	push   %rbp
  800dd5:	48 89 e5             	mov    %rsp,%rbp
  800dd8:	41 57                	push   %r15
  800dda:	41 56                	push   %r14
  800ddc:	41 55                	push   %r13
  800dde:	41 54                	push   %r12
  800de0:	53                   	push   %rbx
  800de1:	48 83 ec 08          	sub    $0x8,%rsp
  800de5:	49 89 fe             	mov    %rdi,%r14
  800de8:	49 89 f7             	mov    %rsi,%r15
  800deb:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800dee:	48 89 f7             	mov    %rsi,%rdi
  800df1:	48 b8 49 0b 80 00 00 	movabs $0x800b49,%rax
  800df8:	00 00 00 
  800dfb:	ff d0                	callq  *%rax
  800dfd:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e00:	4c 89 ee             	mov    %r13,%rsi
  800e03:	4c 89 f7             	mov    %r14,%rdi
  800e06:	48 b8 6b 0b 80 00 00 	movabs $0x800b6b,%rax
  800e0d:	00 00 00 
  800e10:	ff d0                	callq  *%rax
  800e12:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e15:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e19:	4d 39 e5             	cmp    %r12,%r13
  800e1c:	74 26                	je     800e44 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e1e:	4c 89 e8             	mov    %r13,%rax
  800e21:	4c 29 e0             	sub    %r12,%rax
  800e24:	48 39 d8             	cmp    %rbx,%rax
  800e27:	76 2a                	jbe    800e53 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e29:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e2d:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e31:	4c 89 fe             	mov    %r15,%rsi
  800e34:	48 b8 c2 0d 80 00 00 	movabs $0x800dc2,%rax
  800e3b:	00 00 00 
  800e3e:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e40:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e44:	48 83 c4 08          	add    $0x8,%rsp
  800e48:	5b                   	pop    %rbx
  800e49:	41 5c                	pop    %r12
  800e4b:	41 5d                	pop    %r13
  800e4d:	41 5e                	pop    %r14
  800e4f:	41 5f                	pop    %r15
  800e51:	5d                   	pop    %rbp
  800e52:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e53:	49 83 ed 01          	sub    $0x1,%r13
  800e57:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e5b:	4c 89 ea             	mov    %r13,%rdx
  800e5e:	4c 89 fe             	mov    %r15,%rsi
  800e61:	48 b8 c2 0d 80 00 00 	movabs $0x800dc2,%rax
  800e68:	00 00 00 
  800e6b:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e6d:	4d 01 ee             	add    %r13,%r14
  800e70:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e75:	eb c9                	jmp    800e40 <strlcat+0x6c>

0000000000800e77 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e77:	48 85 d2             	test   %rdx,%rdx
  800e7a:	74 3a                	je     800eb6 <memcmp+0x3f>
    if (*s1 != *s2)
  800e7c:	0f b6 0f             	movzbl (%rdi),%ecx
  800e7f:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e83:	44 38 c1             	cmp    %r8b,%cl
  800e86:	75 1d                	jne    800ea5 <memcmp+0x2e>
  800e88:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e8d:	48 39 d0             	cmp    %rdx,%rax
  800e90:	74 1e                	je     800eb0 <memcmp+0x39>
    if (*s1 != *s2)
  800e92:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e96:	48 83 c0 01          	add    $0x1,%rax
  800e9a:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ea0:	44 38 c1             	cmp    %r8b,%cl
  800ea3:	74 e8                	je     800e8d <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ea5:	0f b6 c1             	movzbl %cl,%eax
  800ea8:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eac:	44 29 c0             	sub    %r8d,%eax
  800eaf:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	c3                   	retq   
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebb:	c3                   	retq   

0000000000800ebc <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800ebc:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ec0:	48 39 c7             	cmp    %rax,%rdi
  800ec3:	73 19                	jae    800ede <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ec5:	89 f2                	mov    %esi,%edx
  800ec7:	40 38 37             	cmp    %sil,(%rdi)
  800eca:	74 16                	je     800ee2 <memfind+0x26>
  for (; s < ends; s++)
  800ecc:	48 83 c7 01          	add    $0x1,%rdi
  800ed0:	48 39 f8             	cmp    %rdi,%rax
  800ed3:	74 08                	je     800edd <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed5:	38 17                	cmp    %dl,(%rdi)
  800ed7:	75 f3                	jne    800ecc <memfind+0x10>
  for (; s < ends; s++)
  800ed9:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800edc:	c3                   	retq   
  800edd:	c3                   	retq   
  for (; s < ends; s++)
  800ede:	48 89 f8             	mov    %rdi,%rax
  800ee1:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee2:	48 89 f8             	mov    %rdi,%rax
  800ee5:	c3                   	retq   

0000000000800ee6 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ee6:	0f b6 07             	movzbl (%rdi),%eax
  800ee9:	3c 20                	cmp    $0x20,%al
  800eeb:	74 04                	je     800ef1 <strtol+0xb>
  800eed:	3c 09                	cmp    $0x9,%al
  800eef:	75 0f                	jne    800f00 <strtol+0x1a>
    s++;
  800ef1:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ef5:	0f b6 07             	movzbl (%rdi),%eax
  800ef8:	3c 20                	cmp    $0x20,%al
  800efa:	74 f5                	je     800ef1 <strtol+0xb>
  800efc:	3c 09                	cmp    $0x9,%al
  800efe:	74 f1                	je     800ef1 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f00:	3c 2b                	cmp    $0x2b,%al
  800f02:	74 2b                	je     800f2f <strtol+0x49>
  int neg  = 0;
  800f04:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f0a:	3c 2d                	cmp    $0x2d,%al
  800f0c:	74 2d                	je     800f3b <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0e:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f14:	75 0f                	jne    800f25 <strtol+0x3f>
  800f16:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f19:	74 2c                	je     800f47 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f1b:	85 d2                	test   %edx,%edx
  800f1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f22:	0f 44 d0             	cmove  %eax,%edx
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f2a:	4c 63 d2             	movslq %edx,%r10
  800f2d:	eb 5c                	jmp    800f8b <strtol+0xa5>
    s++;
  800f2f:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f33:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f39:	eb d3                	jmp    800f0e <strtol+0x28>
    s++, neg = 1;
  800f3b:	48 83 c7 01          	add    $0x1,%rdi
  800f3f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f45:	eb c7                	jmp    800f0e <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f47:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f4b:	74 0f                	je     800f5c <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f4d:	85 d2                	test   %edx,%edx
  800f4f:	75 d4                	jne    800f25 <strtol+0x3f>
    s++, base = 8;
  800f51:	48 83 c7 01          	add    $0x1,%rdi
  800f55:	ba 08 00 00 00       	mov    $0x8,%edx
  800f5a:	eb c9                	jmp    800f25 <strtol+0x3f>
    s += 2, base = 16;
  800f5c:	48 83 c7 02          	add    $0x2,%rdi
  800f60:	ba 10 00 00 00       	mov    $0x10,%edx
  800f65:	eb be                	jmp    800f25 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f67:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f6b:	41 80 f8 19          	cmp    $0x19,%r8b
  800f6f:	77 2f                	ja     800fa0 <strtol+0xba>
      dig = *s - 'a' + 10;
  800f71:	44 0f be c1          	movsbl %cl,%r8d
  800f75:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f79:	39 d1                	cmp    %edx,%ecx
  800f7b:	7d 37                	jge    800fb4 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f7d:	48 83 c7 01          	add    $0x1,%rdi
  800f81:	49 0f af c2          	imul   %r10,%rax
  800f85:	48 63 c9             	movslq %ecx,%rcx
  800f88:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f8b:	0f b6 0f             	movzbl (%rdi),%ecx
  800f8e:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f92:	41 80 f8 09          	cmp    $0x9,%r8b
  800f96:	77 cf                	ja     800f67 <strtol+0x81>
      dig = *s - '0';
  800f98:	0f be c9             	movsbl %cl,%ecx
  800f9b:	83 e9 30             	sub    $0x30,%ecx
  800f9e:	eb d9                	jmp    800f79 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fa0:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fa4:	41 80 f8 19          	cmp    $0x19,%r8b
  800fa8:	77 0a                	ja     800fb4 <strtol+0xce>
      dig = *s - 'A' + 10;
  800faa:	44 0f be c1          	movsbl %cl,%r8d
  800fae:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fb2:	eb c5                	jmp    800f79 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fb4:	48 85 f6             	test   %rsi,%rsi
  800fb7:	74 03                	je     800fbc <strtol+0xd6>
    *endptr = (char *)s;
  800fb9:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fbc:	48 89 c2             	mov    %rax,%rdx
  800fbf:	48 f7 da             	neg    %rdx
  800fc2:	45 85 c9             	test   %r9d,%r9d
  800fc5:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fc9:	c3                   	retq   

0000000000800fca <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fca:	55                   	push   %rbp
  800fcb:	48 89 e5             	mov    %rsp,%rbp
  800fce:	53                   	push   %rbx
  800fcf:	48 89 fa             	mov    %rdi,%rdx
  800fd2:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fda:	48 89 c3             	mov    %rax,%rbx
  800fdd:	48 89 c7             	mov    %rax,%rdi
  800fe0:	48 89 c6             	mov    %rax,%rsi
  800fe3:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fe5:	5b                   	pop    %rbx
  800fe6:	5d                   	pop    %rbp
  800fe7:	c3                   	retq   

0000000000800fe8 <sys_cgetc>:

int
sys_cgetc(void) {
  800fe8:	55                   	push   %rbp
  800fe9:	48 89 e5             	mov    %rsp,%rbp
  800fec:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff7:	48 89 ca             	mov    %rcx,%rdx
  800ffa:	48 89 cb             	mov    %rcx,%rbx
  800ffd:	48 89 cf             	mov    %rcx,%rdi
  801000:	48 89 ce             	mov    %rcx,%rsi
  801003:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801005:	5b                   	pop    %rbx
  801006:	5d                   	pop    %rbp
  801007:	c3                   	retq   

0000000000801008 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801008:	55                   	push   %rbp
  801009:	48 89 e5             	mov    %rsp,%rbp
  80100c:	53                   	push   %rbx
  80100d:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801011:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801014:	be 00 00 00 00       	mov    $0x0,%esi
  801019:	b8 03 00 00 00       	mov    $0x3,%eax
  80101e:	48 89 f1             	mov    %rsi,%rcx
  801021:	48 89 f3             	mov    %rsi,%rbx
  801024:	48 89 f7             	mov    %rsi,%rdi
  801027:	cd 30                	int    $0x30
  if (check && ret > 0)
  801029:	48 85 c0             	test   %rax,%rax
  80102c:	7f 07                	jg     801035 <sys_env_destroy+0x2d>
}
  80102e:	48 83 c4 08          	add    $0x8,%rsp
  801032:	5b                   	pop    %rbx
  801033:	5d                   	pop    %rbp
  801034:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801035:	49 89 c0             	mov    %rax,%r8
  801038:	b9 03 00 00 00       	mov    $0x3,%ecx
  80103d:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  801044:	00 00 00 
  801047:	be 22 00 00 00       	mov    $0x22,%esi
  80104c:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  801053:	00 00 00 
  801056:	b8 00 00 00 00       	mov    $0x0,%eax
  80105b:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  801062:	00 00 00 
  801065:	41 ff d1             	callq  *%r9

0000000000801068 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801068:	55                   	push   %rbp
  801069:	48 89 e5             	mov    %rsp,%rbp
  80106c:	53                   	push   %rbx
  asm volatile("int %1\n"
  80106d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801072:	b8 02 00 00 00       	mov    $0x2,%eax
  801077:	48 89 ca             	mov    %rcx,%rdx
  80107a:	48 89 cb             	mov    %rcx,%rbx
  80107d:	48 89 cf             	mov    %rcx,%rdi
  801080:	48 89 ce             	mov    %rcx,%rsi
  801083:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801085:	5b                   	pop    %rbx
  801086:	5d                   	pop    %rbp
  801087:	c3                   	retq   

0000000000801088 <sys_yield>:

void
sys_yield(void) {
  801088:	55                   	push   %rbp
  801089:	48 89 e5             	mov    %rsp,%rbp
  80108c:	53                   	push   %rbx
  asm volatile("int %1\n"
  80108d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801092:	b8 0a 00 00 00       	mov    $0xa,%eax
  801097:	48 89 ca             	mov    %rcx,%rdx
  80109a:	48 89 cb             	mov    %rcx,%rbx
  80109d:	48 89 cf             	mov    %rcx,%rdi
  8010a0:	48 89 ce             	mov    %rcx,%rsi
  8010a3:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010a5:	5b                   	pop    %rbx
  8010a6:	5d                   	pop    %rbp
  8010a7:	c3                   	retq   

00000000008010a8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010a8:	55                   	push   %rbp
  8010a9:	48 89 e5             	mov    %rsp,%rbp
  8010ac:	53                   	push   %rbx
  8010ad:	48 83 ec 08          	sub    $0x8,%rsp
  8010b1:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010b4:	4c 63 c7             	movslq %edi,%r8
  8010b7:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010ba:	be 00 00 00 00       	mov    $0x0,%esi
  8010bf:	b8 04 00 00 00       	mov    $0x4,%eax
  8010c4:	4c 89 c2             	mov    %r8,%rdx
  8010c7:	48 89 f7             	mov    %rsi,%rdi
  8010ca:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010cc:	48 85 c0             	test   %rax,%rax
  8010cf:	7f 07                	jg     8010d8 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8010d1:	48 83 c4 08          	add    $0x8,%rsp
  8010d5:	5b                   	pop    %rbx
  8010d6:	5d                   	pop    %rbp
  8010d7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010d8:	49 89 c0             	mov    %rax,%r8
  8010db:	b9 04 00 00 00       	mov    $0x4,%ecx
  8010e0:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  8010e7:	00 00 00 
  8010ea:	be 22 00 00 00       	mov    $0x22,%esi
  8010ef:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  8010f6:	00 00 00 
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fe:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  801105:	00 00 00 
  801108:	41 ff d1             	callq  *%r9

000000000080110b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80110b:	55                   	push   %rbp
  80110c:	48 89 e5             	mov    %rsp,%rbp
  80110f:	53                   	push   %rbx
  801110:	48 83 ec 08          	sub    $0x8,%rsp
  801114:	41 89 f9             	mov    %edi,%r9d
  801117:	49 89 f2             	mov    %rsi,%r10
  80111a:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80111d:	4d 63 c9             	movslq %r9d,%r9
  801120:	48 63 da             	movslq %edx,%rbx
  801123:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801126:	b8 05 00 00 00       	mov    $0x5,%eax
  80112b:	4c 89 ca             	mov    %r9,%rdx
  80112e:	4c 89 d1             	mov    %r10,%rcx
  801131:	cd 30                	int    $0x30
  if (check && ret > 0)
  801133:	48 85 c0             	test   %rax,%rax
  801136:	7f 07                	jg     80113f <sys_page_map+0x34>
}
  801138:	48 83 c4 08          	add    $0x8,%rsp
  80113c:	5b                   	pop    %rbx
  80113d:	5d                   	pop    %rbp
  80113e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80113f:	49 89 c0             	mov    %rax,%r8
  801142:	b9 05 00 00 00       	mov    $0x5,%ecx
  801147:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  80114e:	00 00 00 
  801151:	be 22 00 00 00       	mov    $0x22,%esi
  801156:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  80115d:	00 00 00 
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
  801165:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  80116c:	00 00 00 
  80116f:	41 ff d1             	callq  *%r9

0000000000801172 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801172:	55                   	push   %rbp
  801173:	48 89 e5             	mov    %rsp,%rbp
  801176:	53                   	push   %rbx
  801177:	48 83 ec 08          	sub    $0x8,%rsp
  80117b:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  80117e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801181:	be 00 00 00 00       	mov    $0x0,%esi
  801186:	b8 06 00 00 00       	mov    $0x6,%eax
  80118b:	48 89 f3             	mov    %rsi,%rbx
  80118e:	48 89 f7             	mov    %rsi,%rdi
  801191:	cd 30                	int    $0x30
  if (check && ret > 0)
  801193:	48 85 c0             	test   %rax,%rax
  801196:	7f 07                	jg     80119f <sys_page_unmap+0x2d>
}
  801198:	48 83 c4 08          	add    $0x8,%rsp
  80119c:	5b                   	pop    %rbx
  80119d:	5d                   	pop    %rbp
  80119e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80119f:	49 89 c0             	mov    %rax,%r8
  8011a2:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011a7:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  8011ae:	00 00 00 
  8011b1:	be 22 00 00 00       	mov    $0x22,%esi
  8011b6:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  8011bd:	00 00 00 
  8011c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c5:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  8011cc:	00 00 00 
  8011cf:	41 ff d1             	callq  *%r9

00000000008011d2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8011d2:	55                   	push   %rbp
  8011d3:	48 89 e5             	mov    %rsp,%rbp
  8011d6:	53                   	push   %rbx
  8011d7:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011db:	48 63 d7             	movslq %edi,%rdx
  8011de:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8011e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8011eb:	48 89 df             	mov    %rbx,%rdi
  8011ee:	48 89 de             	mov    %rbx,%rsi
  8011f1:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011f3:	48 85 c0             	test   %rax,%rax
  8011f6:	7f 07                	jg     8011ff <sys_env_set_status+0x2d>
}
  8011f8:	48 83 c4 08          	add    $0x8,%rsp
  8011fc:	5b                   	pop    %rbx
  8011fd:	5d                   	pop    %rbp
  8011fe:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011ff:	49 89 c0             	mov    %rax,%r8
  801202:	b9 08 00 00 00       	mov    $0x8,%ecx
  801207:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  80120e:	00 00 00 
  801211:	be 22 00 00 00       	mov    $0x22,%esi
  801216:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  80121d:	00 00 00 
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
  801225:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  80122c:	00 00 00 
  80122f:	41 ff d1             	callq  *%r9

0000000000801232 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801232:	55                   	push   %rbp
  801233:	48 89 e5             	mov    %rsp,%rbp
  801236:	53                   	push   %rbx
  801237:	48 83 ec 08          	sub    $0x8,%rsp
  80123b:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80123e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801241:	be 00 00 00 00       	mov    $0x0,%esi
  801246:	b8 09 00 00 00       	mov    $0x9,%eax
  80124b:	48 89 f3             	mov    %rsi,%rbx
  80124e:	48 89 f7             	mov    %rsi,%rdi
  801251:	cd 30                	int    $0x30
  if (check && ret > 0)
  801253:	48 85 c0             	test   %rax,%rax
  801256:	7f 07                	jg     80125f <sys_env_set_pgfault_upcall+0x2d>
}
  801258:	48 83 c4 08          	add    $0x8,%rsp
  80125c:	5b                   	pop    %rbx
  80125d:	5d                   	pop    %rbp
  80125e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80125f:	49 89 c0             	mov    %rax,%r8
  801262:	b9 09 00 00 00       	mov    $0x9,%ecx
  801267:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  80126e:	00 00 00 
  801271:	be 22 00 00 00       	mov    $0x22,%esi
  801276:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  80127d:	00 00 00 
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  80128c:	00 00 00 
  80128f:	41 ff d1             	callq  *%r9

0000000000801292 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801292:	55                   	push   %rbp
  801293:	48 89 e5             	mov    %rsp,%rbp
  801296:	53                   	push   %rbx
  801297:	49 89 f0             	mov    %rsi,%r8
  80129a:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  80129d:	48 63 d7             	movslq %edi,%rdx
  8012a0:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8012a3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012a8:	be 00 00 00 00       	mov    $0x0,%esi
  8012ad:	4c 89 c1             	mov    %r8,%rcx
  8012b0:	cd 30                	int    $0x30
}
  8012b2:	5b                   	pop    %rbx
  8012b3:	5d                   	pop    %rbp
  8012b4:	c3                   	retq   

00000000008012b5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012b5:	55                   	push   %rbp
  8012b6:	48 89 e5             	mov    %rsp,%rbp
  8012b9:	53                   	push   %rbx
  8012ba:	48 83 ec 08          	sub    $0x8,%rsp
  8012be:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012c1:	be 00 00 00 00       	mov    $0x0,%esi
  8012c6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012cb:	48 89 f1             	mov    %rsi,%rcx
  8012ce:	48 89 f3             	mov    %rsi,%rbx
  8012d1:	48 89 f7             	mov    %rsi,%rdi
  8012d4:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012d6:	48 85 c0             	test   %rax,%rax
  8012d9:	7f 07                	jg     8012e2 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8012db:	48 83 c4 08          	add    $0x8,%rsp
  8012df:	5b                   	pop    %rbx
  8012e0:	5d                   	pop    %rbp
  8012e1:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012e2:	49 89 c0             	mov    %rax,%r8
  8012e5:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8012ea:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  8012f1:	00 00 00 
  8012f4:	be 22 00 00 00       	mov    $0x22,%esi
  8012f9:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  801300:	00 00 00 
  801303:	b8 00 00 00 00       	mov    $0x0,%eax
  801308:	49 b9 15 13 80 00 00 	movabs $0x801315,%r9
  80130f:	00 00 00 
  801312:	41 ff d1             	callq  *%r9

0000000000801315 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801315:	55                   	push   %rbp
  801316:	48 89 e5             	mov    %rsp,%rbp
  801319:	41 56                	push   %r14
  80131b:	41 55                	push   %r13
  80131d:	41 54                	push   %r12
  80131f:	53                   	push   %rbx
  801320:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801327:	49 89 fd             	mov    %rdi,%r13
  80132a:	41 89 f6             	mov    %esi,%r14d
  80132d:	49 89 d4             	mov    %rdx,%r12
  801330:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801337:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80133e:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801345:	84 c0                	test   %al,%al
  801347:	74 26                	je     80136f <_panic+0x5a>
  801349:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  801350:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801357:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80135b:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80135f:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  801363:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801367:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80136b:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80136f:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801376:	00 00 00 
  801379:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801380:	00 00 00 
  801383:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801387:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80138e:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801395:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80139c:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8013a3:	00 00 00 
  8013a6:	48 8b 18             	mov    (%rax),%rbx
  8013a9:	48 b8 68 10 80 00 00 	movabs $0x801068,%rax
  8013b0:	00 00 00 
  8013b3:	ff d0                	callq  *%rax
  8013b5:	45 89 f0             	mov    %r14d,%r8d
  8013b8:	4c 89 e9             	mov    %r13,%rcx
  8013bb:	48 89 da             	mov    %rbx,%rdx
  8013be:	89 c6                	mov    %eax,%esi
  8013c0:	48 bf 70 18 80 00 00 	movabs $0x801870,%rdi
  8013c7:	00 00 00 
  8013ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cf:	48 bb d6 01 80 00 00 	movabs $0x8001d6,%rbx
  8013d6:	00 00 00 
  8013d9:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8013db:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8013e2:	4c 89 e7             	mov    %r12,%rdi
  8013e5:	48 b8 6e 01 80 00 00 	movabs $0x80016e,%rax
  8013ec:	00 00 00 
  8013ef:	ff d0                	callq  *%rax
  cprintf("\n");
  8013f1:	48 bf 98 18 80 00 00 	movabs $0x801898,%rdi
  8013f8:	00 00 00 
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801400:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801402:	cc                   	int3   
  while (1)
  801403:	eb fd                	jmp    801402 <_panic+0xed>
  801405:	0f 1f 00             	nopl   (%rax)
