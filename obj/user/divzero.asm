
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
  800044:	48 bf 20 14 80 00 00 	movabs $0x801420,%rdi
  80004b:	00 00 00 
  80004e:	b8 00 00 00 00       	mov    $0x0,%eax
  800053:	48 ba e0 01 80 00 00 	movabs $0x8001e0,%rdx
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
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000ae:	48 b8 72 10 80 00 00 	movabs $0x801072,%rax
  8000b5:	00 00 00 
  8000b8:	ff d0                	callq  *%rax
  8000ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bf:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000c3:	48 c1 e0 05          	shl    $0x5,%rax
  8000c7:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000ce:	00 00 00 
  8000d1:	48 01 d0             	add    %rdx,%rax
  8000d4:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  8000db:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000de:	45 85 ed             	test   %r13d,%r13d
  8000e1:	7e 0d                	jle    8000f0 <libmain+0x8f>
    binaryname = argv[0];
  8000e3:	49 8b 06             	mov    (%r14),%rax
  8000e6:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000ed:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000f0:	4c 89 f6             	mov    %r14,%rsi
  8000f3:	44 89 ef             	mov    %r13d,%edi
  8000f6:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000fd:	00 00 00 
  800100:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800102:	48 b8 17 01 80 00 00 	movabs $0x800117,%rax
  800109:	00 00 00 
  80010c:	ff d0                	callq  *%rax
#endif
}
  80010e:	5b                   	pop    %rbx
  80010f:	41 5c                	pop    %r12
  800111:	41 5d                	pop    %r13
  800113:	41 5e                	pop    %r14
  800115:	5d                   	pop    %rbp
  800116:	c3                   	retq   

0000000000800117 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800117:	55                   	push   %rbp
  800118:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80011b:	bf 00 00 00 00       	mov    $0x0,%edi
  800120:	48 b8 12 10 80 00 00 	movabs $0x801012,%rax
  800127:	00 00 00 
  80012a:	ff d0                	callq  *%rax
}
  80012c:	5d                   	pop    %rbp
  80012d:	c3                   	retq   

000000000080012e <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80012e:	55                   	push   %rbp
  80012f:	48 89 e5             	mov    %rsp,%rbp
  800132:	53                   	push   %rbx
  800133:	48 83 ec 08          	sub    $0x8,%rsp
  800137:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80013a:	8b 06                	mov    (%rsi),%eax
  80013c:	8d 50 01             	lea    0x1(%rax),%edx
  80013f:	89 16                	mov    %edx,(%rsi)
  800141:	48 98                	cltq   
  800143:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800148:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80014e:	74 0b                	je     80015b <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800150:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800154:	48 83 c4 08          	add    $0x8,%rsp
  800158:	5b                   	pop    %rbx
  800159:	5d                   	pop    %rbp
  80015a:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80015b:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80015f:	be ff 00 00 00       	mov    $0xff,%esi
  800164:	48 b8 d4 0f 80 00 00 	movabs $0x800fd4,%rax
  80016b:	00 00 00 
  80016e:	ff d0                	callq  *%rax
    b->idx = 0;
  800170:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800176:	eb d8                	jmp    800150 <putch+0x22>

0000000000800178 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800178:	55                   	push   %rbp
  800179:	48 89 e5             	mov    %rsp,%rbp
  80017c:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800183:	48 89 fa             	mov    %rdi,%rdx
  800186:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800189:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800190:	00 00 00 
  b.cnt = 0;
  800193:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80019a:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80019d:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001a4:	48 bf 2e 01 80 00 00 	movabs $0x80012e,%rdi
  8001ab:	00 00 00 
  8001ae:	48 b8 9e 03 80 00 00 	movabs $0x80039e,%rax
  8001b5:	00 00 00 
  8001b8:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001ba:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001c1:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001c8:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001cc:	48 b8 d4 0f 80 00 00 	movabs $0x800fd4,%rax
  8001d3:	00 00 00 
  8001d6:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001de:	c9                   	leaveq 
  8001df:	c3                   	retq   

00000000008001e0 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001e0:	55                   	push   %rbp
  8001e1:	48 89 e5             	mov    %rsp,%rbp
  8001e4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001eb:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001f2:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001f9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800200:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800207:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80020e:	84 c0                	test   %al,%al
  800210:	74 20                	je     800232 <cprintf+0x52>
  800212:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800216:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80021a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80021e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800222:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800226:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80022a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80022e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800232:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800239:	00 00 00 
  80023c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800243:	00 00 00 
  800246:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80024a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800251:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800258:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80025f:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800266:	48 b8 78 01 80 00 00 	movabs $0x800178,%rax
  80026d:	00 00 00 
  800270:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800272:	c9                   	leaveq 
  800273:	c3                   	retq   

0000000000800274 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800274:	55                   	push   %rbp
  800275:	48 89 e5             	mov    %rsp,%rbp
  800278:	41 57                	push   %r15
  80027a:	41 56                	push   %r14
  80027c:	41 55                	push   %r13
  80027e:	41 54                	push   %r12
  800280:	53                   	push   %rbx
  800281:	48 83 ec 18          	sub    $0x18,%rsp
  800285:	49 89 fc             	mov    %rdi,%r12
  800288:	49 89 f5             	mov    %rsi,%r13
  80028b:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80028f:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800292:	41 89 cf             	mov    %ecx,%r15d
  800295:	49 39 d7             	cmp    %rdx,%r15
  800298:	76 45                	jbe    8002df <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80029a:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80029e:	85 db                	test   %ebx,%ebx
  8002a0:	7e 0e                	jle    8002b0 <printnum+0x3c>
      putch(padc, putdat);
  8002a2:	4c 89 ee             	mov    %r13,%rsi
  8002a5:	44 89 f7             	mov    %r14d,%edi
  8002a8:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002ab:	83 eb 01             	sub    $0x1,%ebx
  8002ae:	75 f2                	jne    8002a2 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002b0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b9:	49 f7 f7             	div    %r15
  8002bc:	48 b8 3b 14 80 00 00 	movabs $0x80143b,%rax
  8002c3:	00 00 00 
  8002c6:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002ca:	4c 89 ee             	mov    %r13,%rsi
  8002cd:	41 ff d4             	callq  *%r12
}
  8002d0:	48 83 c4 18          	add    $0x18,%rsp
  8002d4:	5b                   	pop    %rbx
  8002d5:	41 5c                	pop    %r12
  8002d7:	41 5d                	pop    %r13
  8002d9:	41 5e                	pop    %r14
  8002db:	41 5f                	pop    %r15
  8002dd:	5d                   	pop    %rbp
  8002de:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002df:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	49 f7 f7             	div    %r15
  8002eb:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002ef:	48 89 c2             	mov    %rax,%rdx
  8002f2:	48 b8 74 02 80 00 00 	movabs $0x800274,%rax
  8002f9:	00 00 00 
  8002fc:	ff d0                	callq  *%rax
  8002fe:	eb b0                	jmp    8002b0 <printnum+0x3c>

0000000000800300 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800300:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800304:	48 8b 06             	mov    (%rsi),%rax
  800307:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80030b:	73 0a                	jae    800317 <sprintputch+0x17>
    *b->buf++ = ch;
  80030d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800311:	48 89 16             	mov    %rdx,(%rsi)
  800314:	40 88 38             	mov    %dil,(%rax)
}
  800317:	c3                   	retq   

0000000000800318 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800318:	55                   	push   %rbp
  800319:	48 89 e5             	mov    %rsp,%rbp
  80031c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800323:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80032a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800331:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800338:	84 c0                	test   %al,%al
  80033a:	74 20                	je     80035c <printfmt+0x44>
  80033c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800340:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800344:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800348:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80034c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800350:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800354:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800358:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80035c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800363:	00 00 00 
  800366:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80036d:	00 00 00 
  800370:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800374:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80037b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800382:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800389:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800390:	48 b8 9e 03 80 00 00 	movabs $0x80039e,%rax
  800397:	00 00 00 
  80039a:	ff d0                	callq  *%rax
}
  80039c:	c9                   	leaveq 
  80039d:	c3                   	retq   

000000000080039e <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80039e:	55                   	push   %rbp
  80039f:	48 89 e5             	mov    %rsp,%rbp
  8003a2:	41 57                	push   %r15
  8003a4:	41 56                	push   %r14
  8003a6:	41 55                	push   %r13
  8003a8:	41 54                	push   %r12
  8003aa:	53                   	push   %rbx
  8003ab:	48 83 ec 48          	sub    $0x48,%rsp
  8003af:	49 89 fd             	mov    %rdi,%r13
  8003b2:	49 89 f7             	mov    %rsi,%r15
  8003b5:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003b8:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003bc:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003c0:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003c4:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003c8:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003cc:	41 0f b6 3e          	movzbl (%r14),%edi
  8003d0:	83 ff 25             	cmp    $0x25,%edi
  8003d3:	74 18                	je     8003ed <vprintfmt+0x4f>
      if (ch == '\0')
  8003d5:	85 ff                	test   %edi,%edi
  8003d7:	0f 84 8c 06 00 00    	je     800a69 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003dd:	4c 89 fe             	mov    %r15,%rsi
  8003e0:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003e3:	49 89 de             	mov    %rbx,%r14
  8003e6:	eb e0                	jmp    8003c8 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003e8:	49 89 de             	mov    %rbx,%r14
  8003eb:	eb db                	jmp    8003c8 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003ed:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003f1:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003f5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003fc:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800402:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80040b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800411:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800417:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80041c:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800421:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800425:	0f b6 13             	movzbl (%rbx),%edx
  800428:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 8b 05 00 00    	ja     8009be <vprintfmt+0x620>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	49 bb 20 15 80 00 00 	movabs $0x801520,%r11
  80043d:	00 00 00 
  800440:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800444:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800447:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80044b:	eb d4                	jmp    800421 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80044d:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800450:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800454:	eb cb                	jmp    800421 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800456:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800459:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80045d:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800461:	8d 50 d0             	lea    -0x30(%rax),%edx
  800464:	83 fa 09             	cmp    $0x9,%edx
  800467:	77 7e                	ja     8004e7 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800469:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80046d:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800471:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800476:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80047a:	8d 50 d0             	lea    -0x30(%rax),%edx
  80047d:	83 fa 09             	cmp    $0x9,%edx
  800480:	76 e7                	jbe    800469 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800482:	4c 89 f3             	mov    %r14,%rbx
  800485:	eb 19                	jmp    8004a0 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800487:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80048a:	83 f8 2f             	cmp    $0x2f,%eax
  80048d:	77 2a                	ja     8004b9 <vprintfmt+0x11b>
  80048f:	89 c2                	mov    %eax,%edx
  800491:	4c 01 d2             	add    %r10,%rdx
  800494:	83 c0 08             	add    $0x8,%eax
  800497:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80049a:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80049d:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004a0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004a4:	0f 89 77 ff ff ff    	jns    800421 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004aa:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004ae:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004b4:	e9 68 ff ff ff       	jmpq   800421 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004b9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004bd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004c1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004c5:	eb d3                	jmp    80049a <vprintfmt+0xfc>
        if (width < 0)
  8004c7:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004d0:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004d3:	4c 89 f3             	mov    %r14,%rbx
  8004d6:	e9 46 ff ff ff       	jmpq   800421 <vprintfmt+0x83>
  8004db:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004de:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004e2:	e9 3a ff ff ff       	jmpq   800421 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004e7:	4c 89 f3             	mov    %r14,%rbx
  8004ea:	eb b4                	jmp    8004a0 <vprintfmt+0x102>
        lflag++;
  8004ec:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004ef:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004f2:	e9 2a ff ff ff       	jmpq   800421 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004fa:	83 f8 2f             	cmp    $0x2f,%eax
  8004fd:	77 19                	ja     800518 <vprintfmt+0x17a>
  8004ff:	89 c2                	mov    %eax,%edx
  800501:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800505:	83 c0 08             	add    $0x8,%eax
  800508:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80050b:	4c 89 fe             	mov    %r15,%rsi
  80050e:	8b 3a                	mov    (%rdx),%edi
  800510:	41 ff d5             	callq  *%r13
        break;
  800513:	e9 b0 fe ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800518:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80051c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800520:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800524:	eb e5                	jmp    80050b <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800526:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800529:	83 f8 2f             	cmp    $0x2f,%eax
  80052c:	77 5b                	ja     800589 <vprintfmt+0x1eb>
  80052e:	89 c2                	mov    %eax,%edx
  800530:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800534:	83 c0 08             	add    $0x8,%eax
  800537:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80053a:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80053c:	89 c8                	mov    %ecx,%eax
  80053e:	c1 f8 1f             	sar    $0x1f,%eax
  800541:	31 c1                	xor    %eax,%ecx
  800543:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800545:	83 f9 0b             	cmp    $0xb,%ecx
  800548:	7f 4d                	jg     800597 <vprintfmt+0x1f9>
  80054a:	48 63 c1             	movslq %ecx,%rax
  80054d:	48 ba e0 17 80 00 00 	movabs $0x8017e0,%rdx
  800554:	00 00 00 
  800557:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80055b:	48 85 c0             	test   %rax,%rax
  80055e:	74 37                	je     800597 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800560:	48 89 c1             	mov    %rax,%rcx
  800563:	48 ba 5c 14 80 00 00 	movabs $0x80145c,%rdx
  80056a:	00 00 00 
  80056d:	4c 89 fe             	mov    %r15,%rsi
  800570:	4c 89 ef             	mov    %r13,%rdi
  800573:	b8 00 00 00 00       	mov    $0x0,%eax
  800578:	48 bb 18 03 80 00 00 	movabs $0x800318,%rbx
  80057f:	00 00 00 
  800582:	ff d3                	callq  *%rbx
  800584:	e9 3f fe ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800589:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80058d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800591:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800595:	eb a3                	jmp    80053a <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800597:	48 ba 53 14 80 00 00 	movabs $0x801453,%rdx
  80059e:	00 00 00 
  8005a1:	4c 89 fe             	mov    %r15,%rsi
  8005a4:	4c 89 ef             	mov    %r13,%rdi
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	48 bb 18 03 80 00 00 	movabs $0x800318,%rbx
  8005b3:	00 00 00 
  8005b6:	ff d3                	callq  *%rbx
  8005b8:	e9 0b fe ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005bd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005c0:	83 f8 2f             	cmp    $0x2f,%eax
  8005c3:	77 4b                	ja     800610 <vprintfmt+0x272>
  8005c5:	89 c2                	mov    %eax,%edx
  8005c7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005cb:	83 c0 08             	add    $0x8,%eax
  8005ce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d1:	48 8b 02             	mov    (%rdx),%rax
  8005d4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005d8:	48 85 c0             	test   %rax,%rax
  8005db:	0f 84 05 04 00 00    	je     8009e6 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005e1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005e5:	7e 06                	jle    8005ed <vprintfmt+0x24f>
  8005e7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005eb:	75 31                	jne    80061e <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ed:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005f1:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005f5:	0f b6 00             	movzbl (%rax),%eax
  8005f8:	0f be f8             	movsbl %al,%edi
  8005fb:	85 ff                	test   %edi,%edi
  8005fd:	0f 84 c3 00 00 00    	je     8006c6 <vprintfmt+0x328>
  800603:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800607:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80060b:	e9 85 00 00 00       	jmpq   800695 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800610:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800614:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800618:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80061c:	eb b3                	jmp    8005d1 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	49 63 f4             	movslq %r12d,%rsi
  800621:	48 89 c7             	mov    %rax,%rdi
  800624:	48 b8 75 0b 80 00 00 	movabs $0x800b75,%rax
  80062b:	00 00 00 
  80062e:	ff d0                	callq  *%rax
  800630:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800633:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800636:	85 f6                	test   %esi,%esi
  800638:	7e 22                	jle    80065c <vprintfmt+0x2be>
            putch(padc, putdat);
  80063a:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80063e:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800642:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800646:	4c 89 fe             	mov    %r15,%rsi
  800649:	89 df                	mov    %ebx,%edi
  80064b:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80064e:	41 83 ec 01          	sub    $0x1,%r12d
  800652:	75 f2                	jne    800646 <vprintfmt+0x2a8>
  800654:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800658:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800660:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800664:	0f b6 00             	movzbl (%rax),%eax
  800667:	0f be f8             	movsbl %al,%edi
  80066a:	85 ff                	test   %edi,%edi
  80066c:	0f 84 56 fd ff ff    	je     8003c8 <vprintfmt+0x2a>
  800672:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800676:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80067a:	eb 19                	jmp    800695 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80067c:	4c 89 fe             	mov    %r15,%rsi
  80067f:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800682:	41 83 ee 01          	sub    $0x1,%r14d
  800686:	48 83 c3 01          	add    $0x1,%rbx
  80068a:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80068e:	0f be f8             	movsbl %al,%edi
  800691:	85 ff                	test   %edi,%edi
  800693:	74 29                	je     8006be <vprintfmt+0x320>
  800695:	45 85 e4             	test   %r12d,%r12d
  800698:	78 06                	js     8006a0 <vprintfmt+0x302>
  80069a:	41 83 ec 01          	sub    $0x1,%r12d
  80069e:	78 48                	js     8006e8 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006a0:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006a4:	74 d6                	je     80067c <vprintfmt+0x2de>
  8006a6:	0f be c0             	movsbl %al,%eax
  8006a9:	83 e8 20             	sub    $0x20,%eax
  8006ac:	83 f8 5e             	cmp    $0x5e,%eax
  8006af:	76 cb                	jbe    80067c <vprintfmt+0x2de>
            putch('?', putdat);
  8006b1:	4c 89 fe             	mov    %r15,%rsi
  8006b4:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006b9:	41 ff d5             	callq  *%r13
  8006bc:	eb c4                	jmp    800682 <vprintfmt+0x2e4>
  8006be:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006c2:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006c6:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006c9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006cd:	0f 8e f5 fc ff ff    	jle    8003c8 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006d3:	4c 89 fe             	mov    %r15,%rsi
  8006d6:	bf 20 00 00 00       	mov    $0x20,%edi
  8006db:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006de:	83 eb 01             	sub    $0x1,%ebx
  8006e1:	75 f0                	jne    8006d3 <vprintfmt+0x335>
  8006e3:	e9 e0 fc ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
  8006e8:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006ec:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006f0:	eb d4                	jmp    8006c6 <vprintfmt+0x328>
  if (lflag >= 2)
  8006f2:	83 f9 01             	cmp    $0x1,%ecx
  8006f5:	7f 1d                	jg     800714 <vprintfmt+0x376>
  else if (lflag)
  8006f7:	85 c9                	test   %ecx,%ecx
  8006f9:	74 5e                	je     800759 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006fb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006fe:	83 f8 2f             	cmp    $0x2f,%eax
  800701:	77 48                	ja     80074b <vprintfmt+0x3ad>
  800703:	89 c2                	mov    %eax,%edx
  800705:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800709:	83 c0 08             	add    $0x8,%eax
  80070c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80070f:	48 8b 1a             	mov    (%rdx),%rbx
  800712:	eb 17                	jmp    80072b <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800714:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800717:	83 f8 2f             	cmp    $0x2f,%eax
  80071a:	77 21                	ja     80073d <vprintfmt+0x39f>
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800722:	83 c0 08             	add    $0x8,%eax
  800725:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800728:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80072b:	48 85 db             	test   %rbx,%rbx
  80072e:	78 50                	js     800780 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800730:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800733:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800738:	e9 b4 01 00 00       	jmpq   8008f1 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80073d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800741:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800745:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800749:	eb dd                	jmp    800728 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80074b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80074f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800753:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800757:	eb b6                	jmp    80070f <vprintfmt+0x371>
    return va_arg(*ap, int);
  800759:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80075c:	83 f8 2f             	cmp    $0x2f,%eax
  80075f:	77 11                	ja     800772 <vprintfmt+0x3d4>
  800761:	89 c2                	mov    %eax,%edx
  800763:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800767:	83 c0 08             	add    $0x8,%eax
  80076a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80076d:	48 63 1a             	movslq (%rdx),%rbx
  800770:	eb b9                	jmp    80072b <vprintfmt+0x38d>
  800772:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800776:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80077a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80077e:	eb ed                	jmp    80076d <vprintfmt+0x3cf>
          putch('-', putdat);
  800780:	4c 89 fe             	mov    %r15,%rsi
  800783:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800788:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80078b:	48 89 da             	mov    %rbx,%rdx
  80078e:	48 f7 da             	neg    %rdx
        base = 10;
  800791:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800796:	e9 56 01 00 00       	jmpq   8008f1 <vprintfmt+0x553>
  if (lflag >= 2)
  80079b:	83 f9 01             	cmp    $0x1,%ecx
  80079e:	7f 25                	jg     8007c5 <vprintfmt+0x427>
  else if (lflag)
  8007a0:	85 c9                	test   %ecx,%ecx
  8007a2:	74 5e                	je     800802 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007a4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007a7:	83 f8 2f             	cmp    $0x2f,%eax
  8007aa:	77 48                	ja     8007f4 <vprintfmt+0x456>
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007b2:	83 c0 08             	add    $0x8,%eax
  8007b5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007b8:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c0:	e9 2c 01 00 00       	jmpq   8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007c5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c8:	83 f8 2f             	cmp    $0x2f,%eax
  8007cb:	77 19                	ja     8007e6 <vprintfmt+0x448>
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d3:	83 c0 08             	add    $0x8,%eax
  8007d6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e1:	e9 0b 01 00 00       	jmpq   8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007e6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ea:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ee:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f2:	eb e5                	jmp    8007d9 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007f4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007f8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007fc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800800:	eb b6                	jmp    8007b8 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800802:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800805:	83 f8 2f             	cmp    $0x2f,%eax
  800808:	77 18                	ja     800822 <vprintfmt+0x484>
  80080a:	89 c2                	mov    %eax,%edx
  80080c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800810:	83 c0 08             	add    $0x8,%eax
  800813:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800816:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800818:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081d:	e9 cf 00 00 00       	jmpq   8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800822:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800826:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80082a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80082e:	eb e6                	jmp    800816 <vprintfmt+0x478>
  if (lflag >= 2)
  800830:	83 f9 01             	cmp    $0x1,%ecx
  800833:	7f 25                	jg     80085a <vprintfmt+0x4bc>
  else if (lflag)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 5b                	je     800894 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800839:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80083c:	83 f8 2f             	cmp    $0x2f,%eax
  80083f:	77 45                	ja     800886 <vprintfmt+0x4e8>
  800841:	89 c2                	mov    %eax,%edx
  800843:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800847:	83 c0 08             	add    $0x8,%eax
  80084a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80084d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800850:	b9 08 00 00 00       	mov    $0x8,%ecx
  800855:	e9 97 00 00 00       	jmpq   8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80085a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80085d:	83 f8 2f             	cmp    $0x2f,%eax
  800860:	77 16                	ja     800878 <vprintfmt+0x4da>
  800862:	89 c2                	mov    %eax,%edx
  800864:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800868:	83 c0 08             	add    $0x8,%eax
  80086b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80086e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800871:	b9 08 00 00 00       	mov    $0x8,%ecx
  800876:	eb 79                	jmp    8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800878:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800880:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800884:	eb e8                	jmp    80086e <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800886:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80088e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800892:	eb b9                	jmp    80084d <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800894:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800897:	83 f8 2f             	cmp    $0x2f,%eax
  80089a:	77 15                	ja     8008b1 <vprintfmt+0x513>
  80089c:	89 c2                	mov    %eax,%edx
  80089e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a2:	83 c0 08             	add    $0x8,%eax
  8008a5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a8:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008aa:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008af:	eb 40                	jmp    8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008b1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008bd:	eb e9                	jmp    8008a8 <vprintfmt+0x50a>
        putch('0', putdat);
  8008bf:	4c 89 fe             	mov    %r15,%rsi
  8008c2:	bf 30 00 00 00       	mov    $0x30,%edi
  8008c7:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008ca:	4c 89 fe             	mov    %r15,%rsi
  8008cd:	bf 78 00 00 00       	mov    $0x78,%edi
  8008d2:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008d5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d8:	83 f8 2f             	cmp    $0x2f,%eax
  8008db:	77 34                	ja     800911 <vprintfmt+0x573>
  8008dd:	89 c2                	mov    %eax,%edx
  8008df:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e3:	83 c0 08             	add    $0x8,%eax
  8008e6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008e9:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008ec:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008f1:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008f6:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008fa:	4c 89 fe             	mov    %r15,%rsi
  8008fd:	4c 89 ef             	mov    %r13,%rdi
  800900:	48 b8 74 02 80 00 00 	movabs $0x800274,%rax
  800907:	00 00 00 
  80090a:	ff d0                	callq  *%rax
        break;
  80090c:	e9 b7 fa ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800911:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800915:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800919:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091d:	eb ca                	jmp    8008e9 <vprintfmt+0x54b>
  if (lflag >= 2)
  80091f:	83 f9 01             	cmp    $0x1,%ecx
  800922:	7f 22                	jg     800946 <vprintfmt+0x5a8>
  else if (lflag)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 58                	je     800980 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800928:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092b:	83 f8 2f             	cmp    $0x2f,%eax
  80092e:	77 42                	ja     800972 <vprintfmt+0x5d4>
  800930:	89 c2                	mov    %eax,%edx
  800932:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800936:	83 c0 08             	add    $0x8,%eax
  800939:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80093f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800944:	eb ab                	jmp    8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800946:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800949:	83 f8 2f             	cmp    $0x2f,%eax
  80094c:	77 16                	ja     800964 <vprintfmt+0x5c6>
  80094e:	89 c2                	mov    %eax,%edx
  800950:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800954:	83 c0 08             	add    $0x8,%eax
  800957:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80095d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800962:	eb 8d                	jmp    8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800964:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800968:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800970:	eb e8                	jmp    80095a <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800972:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800976:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097e:	eb bc                	jmp    80093c <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800980:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800983:	83 f8 2f             	cmp    $0x2f,%eax
  800986:	77 18                	ja     8009a0 <vprintfmt+0x602>
  800988:	89 c2                	mov    %eax,%edx
  80098a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80098e:	83 c0 08             	add    $0x8,%eax
  800991:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800994:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800996:	b9 10 00 00 00       	mov    $0x10,%ecx
  80099b:	e9 51 ff ff ff       	jmpq   8008f1 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ac:	eb e6                	jmp    800994 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009ae:	4c 89 fe             	mov    %r15,%rsi
  8009b1:	bf 25 00 00 00       	mov    $0x25,%edi
  8009b6:	41 ff d5             	callq  *%r13
        break;
  8009b9:	e9 0a fa ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
        putch('%', putdat);
  8009be:	4c 89 fe             	mov    %r15,%rsi
  8009c1:	bf 25 00 00 00       	mov    $0x25,%edi
  8009c6:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009c9:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009cd:	0f 84 15 fa ff ff    	je     8003e8 <vprintfmt+0x4a>
  8009d3:	49 89 de             	mov    %rbx,%r14
  8009d6:	49 83 ee 01          	sub    $0x1,%r14
  8009da:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009df:	75 f5                	jne    8009d6 <vprintfmt+0x638>
  8009e1:	e9 e2 f9 ff ff       	jmpq   8003c8 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009e6:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009ea:	74 06                	je     8009f2 <vprintfmt+0x654>
  8009ec:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009f0:	7f 21                	jg     800a13 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f2:	bf 28 00 00 00       	mov    $0x28,%edi
  8009f7:	48 bb 4d 14 80 00 00 	movabs $0x80144d,%rbx
  8009fe:	00 00 00 
  800a01:	b8 28 00 00 00       	mov    $0x28,%eax
  800a06:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a0a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a0e:	e9 82 fc ff ff       	jmpq   800695 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a13:	49 63 f4             	movslq %r12d,%rsi
  800a16:	48 bf 4c 14 80 00 00 	movabs $0x80144c,%rdi
  800a1d:	00 00 00 
  800a20:	48 b8 75 0b 80 00 00 	movabs $0x800b75,%rax
  800a27:	00 00 00 
  800a2a:	ff d0                	callq  *%rax
  800a2c:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a2f:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a32:	48 be 4c 14 80 00 00 	movabs $0x80144c,%rsi
  800a39:	00 00 00 
  800a3c:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a40:	85 c0                	test   %eax,%eax
  800a42:	0f 8f f2 fb ff ff    	jg     80063a <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a48:	48 bb 4d 14 80 00 00 	movabs $0x80144d,%rbx
  800a4f:	00 00 00 
  800a52:	b8 28 00 00 00       	mov    $0x28,%eax
  800a57:	bf 28 00 00 00       	mov    $0x28,%edi
  800a5c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a60:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a64:	e9 2c fc ff ff       	jmpq   800695 <vprintfmt+0x2f7>
}
  800a69:	48 83 c4 48          	add    $0x48,%rsp
  800a6d:	5b                   	pop    %rbx
  800a6e:	41 5c                	pop    %r12
  800a70:	41 5d                	pop    %r13
  800a72:	41 5e                	pop    %r14
  800a74:	41 5f                	pop    %r15
  800a76:	5d                   	pop    %rbp
  800a77:	c3                   	retq   

0000000000800a78 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a78:	55                   	push   %rbp
  800a79:	48 89 e5             	mov    %rsp,%rbp
  800a7c:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a80:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a84:	48 63 c6             	movslq %esi,%rax
  800a87:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a8c:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a90:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a97:	48 85 ff             	test   %rdi,%rdi
  800a9a:	74 2a                	je     800ac6 <vsnprintf+0x4e>
  800a9c:	85 f6                	test   %esi,%esi
  800a9e:	7e 26                	jle    800ac6 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800aa0:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800aa4:	48 bf 00 03 80 00 00 	movabs $0x800300,%rdi
  800aab:	00 00 00 
  800aae:	48 b8 9e 03 80 00 00 	movabs $0x80039e,%rax
  800ab5:	00 00 00 
  800ab8:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800aba:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800abe:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ac1:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ac4:	c9                   	leaveq 
  800ac5:	c3                   	retq   
    return -E_INVAL;
  800ac6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800acb:	eb f7                	jmp    800ac4 <vsnprintf+0x4c>

0000000000800acd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800acd:	55                   	push   %rbp
  800ace:	48 89 e5             	mov    %rsp,%rbp
  800ad1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ad8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800adf:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ae6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800aed:	84 c0                	test   %al,%al
  800aef:	74 20                	je     800b11 <snprintf+0x44>
  800af1:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800af5:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800af9:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800afd:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b01:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b05:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b09:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b0d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b11:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b18:	00 00 00 
  800b1b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b22:	00 00 00 
  800b25:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b29:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b30:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b37:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b3e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b45:	48 b8 78 0a 80 00 00 	movabs $0x800a78,%rax
  800b4c:	00 00 00 
  800b4f:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b51:	c9                   	leaveq 
  800b52:	c3                   	retq   

0000000000800b53 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b53:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b56:	74 17                	je     800b6f <strlen+0x1c>
  800b58:	48 89 fa             	mov    %rdi,%rdx
  800b5b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b60:	29 f9                	sub    %edi,%ecx
    n++;
  800b62:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b65:	48 83 c2 01          	add    $0x1,%rdx
  800b69:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b6c:	75 f4                	jne    800b62 <strlen+0xf>
  800b6e:	c3                   	retq   
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b74:	c3                   	retq   

0000000000800b75 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b75:	48 85 f6             	test   %rsi,%rsi
  800b78:	74 24                	je     800b9e <strnlen+0x29>
  800b7a:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b7d:	74 25                	je     800ba4 <strnlen+0x2f>
  800b7f:	48 01 fe             	add    %rdi,%rsi
  800b82:	48 89 fa             	mov    %rdi,%rdx
  800b85:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b8a:	29 f9                	sub    %edi,%ecx
    n++;
  800b8c:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8f:	48 83 c2 01          	add    $0x1,%rdx
  800b93:	48 39 f2             	cmp    %rsi,%rdx
  800b96:	74 11                	je     800ba9 <strnlen+0x34>
  800b98:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b9b:	75 ef                	jne    800b8c <strnlen+0x17>
  800b9d:	c3                   	retq   
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	c3                   	retq   
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800ba9:	c3                   	retq   

0000000000800baa <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800baa:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bb6:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bb9:	48 83 c2 01          	add    $0x1,%rdx
  800bbd:	84 c9                	test   %cl,%cl
  800bbf:	75 f1                	jne    800bb2 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bc1:	c3                   	retq   

0000000000800bc2 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bc2:	55                   	push   %rbp
  800bc3:	48 89 e5             	mov    %rsp,%rbp
  800bc6:	41 54                	push   %r12
  800bc8:	53                   	push   %rbx
  800bc9:	48 89 fb             	mov    %rdi,%rbx
  800bcc:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bcf:	48 b8 53 0b 80 00 00 	movabs $0x800b53,%rax
  800bd6:	00 00 00 
  800bd9:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bdb:	48 63 f8             	movslq %eax,%rdi
  800bde:	48 01 df             	add    %rbx,%rdi
  800be1:	4c 89 e6             	mov    %r12,%rsi
  800be4:	48 b8 aa 0b 80 00 00 	movabs $0x800baa,%rax
  800beb:	00 00 00 
  800bee:	ff d0                	callq  *%rax
  return dst;
}
  800bf0:	48 89 d8             	mov    %rbx,%rax
  800bf3:	5b                   	pop    %rbx
  800bf4:	41 5c                	pop    %r12
  800bf6:	5d                   	pop    %rbp
  800bf7:	c3                   	retq   

0000000000800bf8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf8:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bfb:	48 85 d2             	test   %rdx,%rdx
  800bfe:	74 1f                	je     800c1f <strncpy+0x27>
  800c00:	48 01 fa             	add    %rdi,%rdx
  800c03:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c06:	48 83 c1 01          	add    $0x1,%rcx
  800c0a:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c0e:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c12:	41 80 f8 01          	cmp    $0x1,%r8b
  800c16:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c1a:	48 39 ca             	cmp    %rcx,%rdx
  800c1d:	75 e7                	jne    800c06 <strncpy+0xe>
  }
  return ret;
}
  800c1f:	c3                   	retq   

0000000000800c20 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c20:	48 89 f8             	mov    %rdi,%rax
  800c23:	48 85 d2             	test   %rdx,%rdx
  800c26:	74 36                	je     800c5e <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c28:	48 83 fa 01          	cmp    $0x1,%rdx
  800c2c:	74 2d                	je     800c5b <strlcpy+0x3b>
  800c2e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c32:	45 84 c0             	test   %r8b,%r8b
  800c35:	74 24                	je     800c5b <strlcpy+0x3b>
  800c37:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c3b:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c40:	48 83 c0 01          	add    $0x1,%rax
  800c44:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c48:	48 39 d1             	cmp    %rdx,%rcx
  800c4b:	74 0e                	je     800c5b <strlcpy+0x3b>
  800c4d:	48 83 c1 01          	add    $0x1,%rcx
  800c51:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c56:	45 84 c0             	test   %r8b,%r8b
  800c59:	75 e5                	jne    800c40 <strlcpy+0x20>
    *dst = '\0';
  800c5b:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c5e:	48 29 f8             	sub    %rdi,%rax
}
  800c61:	c3                   	retq   

0000000000800c62 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c62:	0f b6 07             	movzbl (%rdi),%eax
  800c65:	84 c0                	test   %al,%al
  800c67:	74 17                	je     800c80 <strcmp+0x1e>
  800c69:	3a 06                	cmp    (%rsi),%al
  800c6b:	75 13                	jne    800c80 <strcmp+0x1e>
    p++, q++;
  800c6d:	48 83 c7 01          	add    $0x1,%rdi
  800c71:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c75:	0f b6 07             	movzbl (%rdi),%eax
  800c78:	84 c0                	test   %al,%al
  800c7a:	74 04                	je     800c80 <strcmp+0x1e>
  800c7c:	3a 06                	cmp    (%rsi),%al
  800c7e:	74 ed                	je     800c6d <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c80:	0f b6 c0             	movzbl %al,%eax
  800c83:	0f b6 16             	movzbl (%rsi),%edx
  800c86:	29 d0                	sub    %edx,%eax
}
  800c88:	c3                   	retq   

0000000000800c89 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c89:	48 85 d2             	test   %rdx,%rdx
  800c8c:	74 2f                	je     800cbd <strncmp+0x34>
  800c8e:	0f b6 07             	movzbl (%rdi),%eax
  800c91:	84 c0                	test   %al,%al
  800c93:	74 1f                	je     800cb4 <strncmp+0x2b>
  800c95:	3a 06                	cmp    (%rsi),%al
  800c97:	75 1b                	jne    800cb4 <strncmp+0x2b>
  800c99:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c9c:	48 83 c7 01          	add    $0x1,%rdi
  800ca0:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ca4:	48 39 d7             	cmp    %rdx,%rdi
  800ca7:	74 1a                	je     800cc3 <strncmp+0x3a>
  800ca9:	0f b6 07             	movzbl (%rdi),%eax
  800cac:	84 c0                	test   %al,%al
  800cae:	74 04                	je     800cb4 <strncmp+0x2b>
  800cb0:	3a 06                	cmp    (%rsi),%al
  800cb2:	74 e8                	je     800c9c <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800cb4:	0f b6 07             	movzbl (%rdi),%eax
  800cb7:	0f b6 16             	movzbl (%rsi),%edx
  800cba:	29 d0                	sub    %edx,%eax
}
  800cbc:	c3                   	retq   
    return 0;
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	c3                   	retq   
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	c3                   	retq   

0000000000800cc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cc9:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ccb:	0f b6 07             	movzbl (%rdi),%eax
  800cce:	84 c0                	test   %al,%al
  800cd0:	74 1e                	je     800cf0 <strchr+0x27>
    if (*s == c)
  800cd2:	40 38 c6             	cmp    %al,%sil
  800cd5:	74 1f                	je     800cf6 <strchr+0x2d>
  for (; *s; s++)
  800cd7:	48 83 c7 01          	add    $0x1,%rdi
  800cdb:	0f b6 07             	movzbl (%rdi),%eax
  800cde:	84 c0                	test   %al,%al
  800ce0:	74 08                	je     800cea <strchr+0x21>
    if (*s == c)
  800ce2:	38 d0                	cmp    %dl,%al
  800ce4:	75 f1                	jne    800cd7 <strchr+0xe>
  for (; *s; s++)
  800ce6:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ce9:	c3                   	retq   
  return 0;
  800cea:	b8 00 00 00 00       	mov    $0x0,%eax
  800cef:	c3                   	retq   
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf5:	c3                   	retq   
    if (*s == c)
  800cf6:	48 89 f8             	mov    %rdi,%rax
  800cf9:	c3                   	retq   

0000000000800cfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cfa:	48 89 f8             	mov    %rdi,%rax
  800cfd:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cff:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d02:	40 38 f2             	cmp    %sil,%dl
  800d05:	74 13                	je     800d1a <strfind+0x20>
  800d07:	84 d2                	test   %dl,%dl
  800d09:	74 0f                	je     800d1a <strfind+0x20>
  for (; *s; s++)
  800d0b:	48 83 c0 01          	add    $0x1,%rax
  800d0f:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d12:	38 ca                	cmp    %cl,%dl
  800d14:	74 04                	je     800d1a <strfind+0x20>
  800d16:	84 d2                	test   %dl,%dl
  800d18:	75 f1                	jne    800d0b <strfind+0x11>
      break;
  return (char *)s;
}
  800d1a:	c3                   	retq   

0000000000800d1b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d1b:	48 85 d2             	test   %rdx,%rdx
  800d1e:	74 3a                	je     800d5a <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d20:	48 89 f8             	mov    %rdi,%rax
  800d23:	48 09 d0             	or     %rdx,%rax
  800d26:	a8 03                	test   $0x3,%al
  800d28:	75 28                	jne    800d52 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d2a:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d2e:	89 f0                	mov    %esi,%eax
  800d30:	c1 e0 08             	shl    $0x8,%eax
  800d33:	89 f1                	mov    %esi,%ecx
  800d35:	c1 e1 18             	shl    $0x18,%ecx
  800d38:	41 89 f0             	mov    %esi,%r8d
  800d3b:	41 c1 e0 10          	shl    $0x10,%r8d
  800d3f:	44 09 c1             	or     %r8d,%ecx
  800d42:	09 ce                	or     %ecx,%esi
  800d44:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d46:	48 c1 ea 02          	shr    $0x2,%rdx
  800d4a:	48 89 d1             	mov    %rdx,%rcx
  800d4d:	fc                   	cld    
  800d4e:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d50:	eb 08                	jmp    800d5a <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	48 89 d1             	mov    %rdx,%rcx
  800d57:	fc                   	cld    
  800d58:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d5a:	48 89 f8             	mov    %rdi,%rax
  800d5d:	c3                   	retq   

0000000000800d5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d5e:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d61:	48 39 fe             	cmp    %rdi,%rsi
  800d64:	73 40                	jae    800da6 <memmove+0x48>
  800d66:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d6a:	48 39 f9             	cmp    %rdi,%rcx
  800d6d:	76 37                	jbe    800da6 <memmove+0x48>
    s += n;
    d += n;
  800d6f:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d73:	48 89 fe             	mov    %rdi,%rsi
  800d76:	48 09 d6             	or     %rdx,%rsi
  800d79:	48 09 ce             	or     %rcx,%rsi
  800d7c:	40 f6 c6 03          	test   $0x3,%sil
  800d80:	75 14                	jne    800d96 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d82:	48 83 ef 04          	sub    $0x4,%rdi
  800d86:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d8a:	48 c1 ea 02          	shr    $0x2,%rdx
  800d8e:	48 89 d1             	mov    %rdx,%rcx
  800d91:	fd                   	std    
  800d92:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d94:	eb 0e                	jmp    800da4 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d96:	48 83 ef 01          	sub    $0x1,%rdi
  800d9a:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d9e:	48 89 d1             	mov    %rdx,%rcx
  800da1:	fd                   	std    
  800da2:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800da4:	fc                   	cld    
  800da5:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800da6:	48 89 c1             	mov    %rax,%rcx
  800da9:	48 09 d1             	or     %rdx,%rcx
  800dac:	48 09 f1             	or     %rsi,%rcx
  800daf:	f6 c1 03             	test   $0x3,%cl
  800db2:	75 0e                	jne    800dc2 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800db4:	48 c1 ea 02          	shr    $0x2,%rdx
  800db8:	48 89 d1             	mov    %rdx,%rcx
  800dbb:	48 89 c7             	mov    %rax,%rdi
  800dbe:	fc                   	cld    
  800dbf:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dc1:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800dc2:	48 89 c7             	mov    %rax,%rdi
  800dc5:	48 89 d1             	mov    %rdx,%rcx
  800dc8:	fc                   	cld    
  800dc9:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dcb:	c3                   	retq   

0000000000800dcc <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dcc:	55                   	push   %rbp
  800dcd:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dd0:	48 b8 5e 0d 80 00 00 	movabs $0x800d5e,%rax
  800dd7:	00 00 00 
  800dda:	ff d0                	callq  *%rax
}
  800ddc:	5d                   	pop    %rbp
  800ddd:	c3                   	retq   

0000000000800dde <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dde:	55                   	push   %rbp
  800ddf:	48 89 e5             	mov    %rsp,%rbp
  800de2:	41 57                	push   %r15
  800de4:	41 56                	push   %r14
  800de6:	41 55                	push   %r13
  800de8:	41 54                	push   %r12
  800dea:	53                   	push   %rbx
  800deb:	48 83 ec 08          	sub    $0x8,%rsp
  800def:	49 89 fe             	mov    %rdi,%r14
  800df2:	49 89 f7             	mov    %rsi,%r15
  800df5:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800df8:	48 89 f7             	mov    %rsi,%rdi
  800dfb:	48 b8 53 0b 80 00 00 	movabs $0x800b53,%rax
  800e02:	00 00 00 
  800e05:	ff d0                	callq  *%rax
  800e07:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e0a:	4c 89 ee             	mov    %r13,%rsi
  800e0d:	4c 89 f7             	mov    %r14,%rdi
  800e10:	48 b8 75 0b 80 00 00 	movabs $0x800b75,%rax
  800e17:	00 00 00 
  800e1a:	ff d0                	callq  *%rax
  800e1c:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e1f:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e23:	4d 39 e5             	cmp    %r12,%r13
  800e26:	74 26                	je     800e4e <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e28:	4c 89 e8             	mov    %r13,%rax
  800e2b:	4c 29 e0             	sub    %r12,%rax
  800e2e:	48 39 d8             	cmp    %rbx,%rax
  800e31:	76 2a                	jbe    800e5d <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e33:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e37:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e3b:	4c 89 fe             	mov    %r15,%rsi
  800e3e:	48 b8 cc 0d 80 00 00 	movabs $0x800dcc,%rax
  800e45:	00 00 00 
  800e48:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e4a:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e4e:	48 83 c4 08          	add    $0x8,%rsp
  800e52:	5b                   	pop    %rbx
  800e53:	41 5c                	pop    %r12
  800e55:	41 5d                	pop    %r13
  800e57:	41 5e                	pop    %r14
  800e59:	41 5f                	pop    %r15
  800e5b:	5d                   	pop    %rbp
  800e5c:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e5d:	49 83 ed 01          	sub    $0x1,%r13
  800e61:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e65:	4c 89 ea             	mov    %r13,%rdx
  800e68:	4c 89 fe             	mov    %r15,%rsi
  800e6b:	48 b8 cc 0d 80 00 00 	movabs $0x800dcc,%rax
  800e72:	00 00 00 
  800e75:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e77:	4d 01 ee             	add    %r13,%r14
  800e7a:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e7f:	eb c9                	jmp    800e4a <strlcat+0x6c>

0000000000800e81 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e81:	48 85 d2             	test   %rdx,%rdx
  800e84:	74 3a                	je     800ec0 <memcmp+0x3f>
    if (*s1 != *s2)
  800e86:	0f b6 0f             	movzbl (%rdi),%ecx
  800e89:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e8d:	44 38 c1             	cmp    %r8b,%cl
  800e90:	75 1d                	jne    800eaf <memcmp+0x2e>
  800e92:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e97:	48 39 d0             	cmp    %rdx,%rax
  800e9a:	74 1e                	je     800eba <memcmp+0x39>
    if (*s1 != *s2)
  800e9c:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ea0:	48 83 c0 01          	add    $0x1,%rax
  800ea4:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800eaa:	44 38 c1             	cmp    %r8b,%cl
  800ead:	74 e8                	je     800e97 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800eaf:	0f b6 c1             	movzbl %cl,%eax
  800eb2:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eb6:	44 29 c0             	sub    %r8d,%eax
  800eb9:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	c3                   	retq   
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec5:	c3                   	retq   

0000000000800ec6 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800ec6:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800eca:	48 39 c7             	cmp    %rax,%rdi
  800ecd:	73 19                	jae    800ee8 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ecf:	89 f2                	mov    %esi,%edx
  800ed1:	40 38 37             	cmp    %sil,(%rdi)
  800ed4:	74 16                	je     800eec <memfind+0x26>
  for (; s < ends; s++)
  800ed6:	48 83 c7 01          	add    $0x1,%rdi
  800eda:	48 39 f8             	cmp    %rdi,%rax
  800edd:	74 08                	je     800ee7 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800edf:	38 17                	cmp    %dl,(%rdi)
  800ee1:	75 f3                	jne    800ed6 <memfind+0x10>
  for (; s < ends; s++)
  800ee3:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ee6:	c3                   	retq   
  800ee7:	c3                   	retq   
  for (; s < ends; s++)
  800ee8:	48 89 f8             	mov    %rdi,%rax
  800eeb:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800eec:	48 89 f8             	mov    %rdi,%rax
  800eef:	c3                   	retq   

0000000000800ef0 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ef0:	0f b6 07             	movzbl (%rdi),%eax
  800ef3:	3c 20                	cmp    $0x20,%al
  800ef5:	74 04                	je     800efb <strtol+0xb>
  800ef7:	3c 09                	cmp    $0x9,%al
  800ef9:	75 0f                	jne    800f0a <strtol+0x1a>
    s++;
  800efb:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800eff:	0f b6 07             	movzbl (%rdi),%eax
  800f02:	3c 20                	cmp    $0x20,%al
  800f04:	74 f5                	je     800efb <strtol+0xb>
  800f06:	3c 09                	cmp    $0x9,%al
  800f08:	74 f1                	je     800efb <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f0a:	3c 2b                	cmp    $0x2b,%al
  800f0c:	74 2b                	je     800f39 <strtol+0x49>
  int neg  = 0;
  800f0e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f14:	3c 2d                	cmp    $0x2d,%al
  800f16:	74 2d                	je     800f45 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f18:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f1e:	75 0f                	jne    800f2f <strtol+0x3f>
  800f20:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f23:	74 2c                	je     800f51 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f25:	85 d2                	test   %edx,%edx
  800f27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2c:	0f 44 d0             	cmove  %eax,%edx
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f34:	4c 63 d2             	movslq %edx,%r10
  800f37:	eb 5c                	jmp    800f95 <strtol+0xa5>
    s++;
  800f39:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f3d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f43:	eb d3                	jmp    800f18 <strtol+0x28>
    s++, neg = 1;
  800f45:	48 83 c7 01          	add    $0x1,%rdi
  800f49:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f4f:	eb c7                	jmp    800f18 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f51:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f55:	74 0f                	je     800f66 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f57:	85 d2                	test   %edx,%edx
  800f59:	75 d4                	jne    800f2f <strtol+0x3f>
    s++, base = 8;
  800f5b:	48 83 c7 01          	add    $0x1,%rdi
  800f5f:	ba 08 00 00 00       	mov    $0x8,%edx
  800f64:	eb c9                	jmp    800f2f <strtol+0x3f>
    s += 2, base = 16;
  800f66:	48 83 c7 02          	add    $0x2,%rdi
  800f6a:	ba 10 00 00 00       	mov    $0x10,%edx
  800f6f:	eb be                	jmp    800f2f <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f71:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f75:	41 80 f8 19          	cmp    $0x19,%r8b
  800f79:	77 2f                	ja     800faa <strtol+0xba>
      dig = *s - 'a' + 10;
  800f7b:	44 0f be c1          	movsbl %cl,%r8d
  800f7f:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f83:	39 d1                	cmp    %edx,%ecx
  800f85:	7d 37                	jge    800fbe <strtol+0xce>
    s++, val = (val * base) + dig;
  800f87:	48 83 c7 01          	add    $0x1,%rdi
  800f8b:	49 0f af c2          	imul   %r10,%rax
  800f8f:	48 63 c9             	movslq %ecx,%rcx
  800f92:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f95:	0f b6 0f             	movzbl (%rdi),%ecx
  800f98:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f9c:	41 80 f8 09          	cmp    $0x9,%r8b
  800fa0:	77 cf                	ja     800f71 <strtol+0x81>
      dig = *s - '0';
  800fa2:	0f be c9             	movsbl %cl,%ecx
  800fa5:	83 e9 30             	sub    $0x30,%ecx
  800fa8:	eb d9                	jmp    800f83 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800faa:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fae:	41 80 f8 19          	cmp    $0x19,%r8b
  800fb2:	77 0a                	ja     800fbe <strtol+0xce>
      dig = *s - 'A' + 10;
  800fb4:	44 0f be c1          	movsbl %cl,%r8d
  800fb8:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fbc:	eb c5                	jmp    800f83 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fbe:	48 85 f6             	test   %rsi,%rsi
  800fc1:	74 03                	je     800fc6 <strtol+0xd6>
    *endptr = (char *)s;
  800fc3:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fc6:	48 89 c2             	mov    %rax,%rdx
  800fc9:	48 f7 da             	neg    %rdx
  800fcc:	45 85 c9             	test   %r9d,%r9d
  800fcf:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fd3:	c3                   	retq   

0000000000800fd4 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fd4:	55                   	push   %rbp
  800fd5:	48 89 e5             	mov    %rsp,%rbp
  800fd8:	53                   	push   %rbx
  800fd9:	48 89 fa             	mov    %rdi,%rdx
  800fdc:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe4:	48 89 c3             	mov    %rax,%rbx
  800fe7:	48 89 c7             	mov    %rax,%rdi
  800fea:	48 89 c6             	mov    %rax,%rsi
  800fed:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fef:	5b                   	pop    %rbx
  800ff0:	5d                   	pop    %rbp
  800ff1:	c3                   	retq   

0000000000800ff2 <sys_cgetc>:

int
sys_cgetc(void) {
  800ff2:	55                   	push   %rbp
  800ff3:	48 89 e5             	mov    %rsp,%rbp
  800ff6:	53                   	push   %rbx
  asm volatile("int %1\n"
  800ff7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffc:	b8 01 00 00 00       	mov    $0x1,%eax
  801001:	48 89 ca             	mov    %rcx,%rdx
  801004:	48 89 cb             	mov    %rcx,%rbx
  801007:	48 89 cf             	mov    %rcx,%rdi
  80100a:	48 89 ce             	mov    %rcx,%rsi
  80100d:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80100f:	5b                   	pop    %rbx
  801010:	5d                   	pop    %rbp
  801011:	c3                   	retq   

0000000000801012 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801012:	55                   	push   %rbp
  801013:	48 89 e5             	mov    %rsp,%rbp
  801016:	53                   	push   %rbx
  801017:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80101b:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80101e:	be 00 00 00 00       	mov    $0x0,%esi
  801023:	b8 03 00 00 00       	mov    $0x3,%eax
  801028:	48 89 f1             	mov    %rsi,%rcx
  80102b:	48 89 f3             	mov    %rsi,%rbx
  80102e:	48 89 f7             	mov    %rsi,%rdi
  801031:	cd 30                	int    $0x30
  if (check && ret > 0)
  801033:	48 85 c0             	test   %rax,%rax
  801036:	7f 07                	jg     80103f <sys_env_destroy+0x2d>
}
  801038:	48 83 c4 08          	add    $0x8,%rsp
  80103c:	5b                   	pop    %rbx
  80103d:	5d                   	pop    %rbp
  80103e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80103f:	49 89 c0             	mov    %rax,%r8
  801042:	b9 03 00 00 00       	mov    $0x3,%ecx
  801047:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  80104e:	00 00 00 
  801051:	be 22 00 00 00       	mov    $0x22,%esi
  801056:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  80105d:	00 00 00 
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
  801065:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  80106c:	00 00 00 
  80106f:	41 ff d1             	callq  *%r9

0000000000801072 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801072:	55                   	push   %rbp
  801073:	48 89 e5             	mov    %rsp,%rbp
  801076:	53                   	push   %rbx
  asm volatile("int %1\n"
  801077:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107c:	b8 02 00 00 00       	mov    $0x2,%eax
  801081:	48 89 ca             	mov    %rcx,%rdx
  801084:	48 89 cb             	mov    %rcx,%rbx
  801087:	48 89 cf             	mov    %rcx,%rdi
  80108a:	48 89 ce             	mov    %rcx,%rsi
  80108d:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80108f:	5b                   	pop    %rbx
  801090:	5d                   	pop    %rbp
  801091:	c3                   	retq   

0000000000801092 <sys_yield>:

void
sys_yield(void) {
  801092:	55                   	push   %rbp
  801093:	48 89 e5             	mov    %rsp,%rbp
  801096:	53                   	push   %rbx
  asm volatile("int %1\n"
  801097:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a1:	48 89 ca             	mov    %rcx,%rdx
  8010a4:	48 89 cb             	mov    %rcx,%rbx
  8010a7:	48 89 cf             	mov    %rcx,%rdi
  8010aa:	48 89 ce             	mov    %rcx,%rsi
  8010ad:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010af:	5b                   	pop    %rbx
  8010b0:	5d                   	pop    %rbp
  8010b1:	c3                   	retq   

00000000008010b2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010b2:	55                   	push   %rbp
  8010b3:	48 89 e5             	mov    %rsp,%rbp
  8010b6:	53                   	push   %rbx
  8010b7:	48 83 ec 08          	sub    $0x8,%rsp
  8010bb:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010be:	4c 63 c7             	movslq %edi,%r8
  8010c1:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010c4:	be 00 00 00 00       	mov    $0x0,%esi
  8010c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8010ce:	4c 89 c2             	mov    %r8,%rdx
  8010d1:	48 89 f7             	mov    %rsi,%rdi
  8010d4:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010d6:	48 85 c0             	test   %rax,%rax
  8010d9:	7f 07                	jg     8010e2 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8010db:	48 83 c4 08          	add    $0x8,%rsp
  8010df:	5b                   	pop    %rbx
  8010e0:	5d                   	pop    %rbp
  8010e1:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010e2:	49 89 c0             	mov    %rax,%r8
  8010e5:	b9 04 00 00 00       	mov    $0x4,%ecx
  8010ea:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  8010f1:	00 00 00 
  8010f4:	be 22 00 00 00       	mov    $0x22,%esi
  8010f9:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  801100:	00 00 00 
  801103:	b8 00 00 00 00       	mov    $0x0,%eax
  801108:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  80110f:	00 00 00 
  801112:	41 ff d1             	callq  *%r9

0000000000801115 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801115:	55                   	push   %rbp
  801116:	48 89 e5             	mov    %rsp,%rbp
  801119:	53                   	push   %rbx
  80111a:	48 83 ec 08          	sub    $0x8,%rsp
  80111e:	41 89 f9             	mov    %edi,%r9d
  801121:	49 89 f2             	mov    %rsi,%r10
  801124:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801127:	4d 63 c9             	movslq %r9d,%r9
  80112a:	48 63 da             	movslq %edx,%rbx
  80112d:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801130:	b8 05 00 00 00       	mov    $0x5,%eax
  801135:	4c 89 ca             	mov    %r9,%rdx
  801138:	4c 89 d1             	mov    %r10,%rcx
  80113b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80113d:	48 85 c0             	test   %rax,%rax
  801140:	7f 07                	jg     801149 <sys_page_map+0x34>
}
  801142:	48 83 c4 08          	add    $0x8,%rsp
  801146:	5b                   	pop    %rbx
  801147:	5d                   	pop    %rbp
  801148:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801149:	49 89 c0             	mov    %rax,%r8
  80114c:	b9 05 00 00 00       	mov    $0x5,%ecx
  801151:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  801158:	00 00 00 
  80115b:	be 22 00 00 00       	mov    $0x22,%esi
  801160:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  801167:	00 00 00 
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
  80116f:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  801176:	00 00 00 
  801179:	41 ff d1             	callq  *%r9

000000000080117c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80117c:	55                   	push   %rbp
  80117d:	48 89 e5             	mov    %rsp,%rbp
  801180:	53                   	push   %rbx
  801181:	48 83 ec 08          	sub    $0x8,%rsp
  801185:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801188:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80118b:	be 00 00 00 00       	mov    $0x0,%esi
  801190:	b8 06 00 00 00       	mov    $0x6,%eax
  801195:	48 89 f3             	mov    %rsi,%rbx
  801198:	48 89 f7             	mov    %rsi,%rdi
  80119b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80119d:	48 85 c0             	test   %rax,%rax
  8011a0:	7f 07                	jg     8011a9 <sys_page_unmap+0x2d>
}
  8011a2:	48 83 c4 08          	add    $0x8,%rsp
  8011a6:	5b                   	pop    %rbx
  8011a7:	5d                   	pop    %rbp
  8011a8:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011a9:	49 89 c0             	mov    %rax,%r8
  8011ac:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011b1:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  8011b8:	00 00 00 
  8011bb:	be 22 00 00 00       	mov    $0x22,%esi
  8011c0:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  8011c7:	00 00 00 
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cf:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  8011d6:	00 00 00 
  8011d9:	41 ff d1             	callq  *%r9

00000000008011dc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8011dc:	55                   	push   %rbp
  8011dd:	48 89 e5             	mov    %rsp,%rbp
  8011e0:	53                   	push   %rbx
  8011e1:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011e5:	48 63 d7             	movslq %edi,%rdx
  8011e8:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8011eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8011f5:	48 89 df             	mov    %rbx,%rdi
  8011f8:	48 89 de             	mov    %rbx,%rsi
  8011fb:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011fd:	48 85 c0             	test   %rax,%rax
  801200:	7f 07                	jg     801209 <sys_env_set_status+0x2d>
}
  801202:	48 83 c4 08          	add    $0x8,%rsp
  801206:	5b                   	pop    %rbx
  801207:	5d                   	pop    %rbp
  801208:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801209:	49 89 c0             	mov    %rax,%r8
  80120c:	b9 08 00 00 00       	mov    $0x8,%ecx
  801211:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  801218:	00 00 00 
  80121b:	be 22 00 00 00       	mov    $0x22,%esi
  801220:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  801227:	00 00 00 
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  801236:	00 00 00 
  801239:	41 ff d1             	callq  *%r9

000000000080123c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80123c:	55                   	push   %rbp
  80123d:	48 89 e5             	mov    %rsp,%rbp
  801240:	53                   	push   %rbx
  801241:	48 83 ec 08          	sub    $0x8,%rsp
  801245:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801248:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80124b:	be 00 00 00 00       	mov    $0x0,%esi
  801250:	b8 09 00 00 00       	mov    $0x9,%eax
  801255:	48 89 f3             	mov    %rsi,%rbx
  801258:	48 89 f7             	mov    %rsi,%rdi
  80125b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80125d:	48 85 c0             	test   %rax,%rax
  801260:	7f 07                	jg     801269 <sys_env_set_pgfault_upcall+0x2d>
}
  801262:	48 83 c4 08          	add    $0x8,%rsp
  801266:	5b                   	pop    %rbx
  801267:	5d                   	pop    %rbp
  801268:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801269:	49 89 c0             	mov    %rax,%r8
  80126c:	b9 09 00 00 00       	mov    $0x9,%ecx
  801271:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  801278:	00 00 00 
  80127b:	be 22 00 00 00       	mov    $0x22,%esi
  801280:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  801287:	00 00 00 
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
  80128f:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  801296:	00 00 00 
  801299:	41 ff d1             	callq  *%r9

000000000080129c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80129c:	55                   	push   %rbp
  80129d:	48 89 e5             	mov    %rsp,%rbp
  8012a0:	53                   	push   %rbx
  8012a1:	49 89 f0             	mov    %rsi,%r8
  8012a4:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8012a7:	48 63 d7             	movslq %edi,%rdx
  8012aa:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8012ad:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012b2:	be 00 00 00 00       	mov    $0x0,%esi
  8012b7:	4c 89 c1             	mov    %r8,%rcx
  8012ba:	cd 30                	int    $0x30
}
  8012bc:	5b                   	pop    %rbx
  8012bd:	5d                   	pop    %rbp
  8012be:	c3                   	retq   

00000000008012bf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012bf:	55                   	push   %rbp
  8012c0:	48 89 e5             	mov    %rsp,%rbp
  8012c3:	53                   	push   %rbx
  8012c4:	48 83 ec 08          	sub    $0x8,%rsp
  8012c8:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012cb:	be 00 00 00 00       	mov    $0x0,%esi
  8012d0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012d5:	48 89 f1             	mov    %rsi,%rcx
  8012d8:	48 89 f3             	mov    %rsi,%rbx
  8012db:	48 89 f7             	mov    %rsi,%rdi
  8012de:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012e0:	48 85 c0             	test   %rax,%rax
  8012e3:	7f 07                	jg     8012ec <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8012e5:	48 83 c4 08          	add    $0x8,%rsp
  8012e9:	5b                   	pop    %rbx
  8012ea:	5d                   	pop    %rbp
  8012eb:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012ec:	49 89 c0             	mov    %rax,%r8
  8012ef:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8012f4:	48 ba 40 18 80 00 00 	movabs $0x801840,%rdx
  8012fb:	00 00 00 
  8012fe:	be 22 00 00 00       	mov    $0x22,%esi
  801303:	48 bf 5f 18 80 00 00 	movabs $0x80185f,%rdi
  80130a:	00 00 00 
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
  801312:	49 b9 1f 13 80 00 00 	movabs $0x80131f,%r9
  801319:	00 00 00 
  80131c:	41 ff d1             	callq  *%r9

000000000080131f <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80131f:	55                   	push   %rbp
  801320:	48 89 e5             	mov    %rsp,%rbp
  801323:	41 56                	push   %r14
  801325:	41 55                	push   %r13
  801327:	41 54                	push   %r12
  801329:	53                   	push   %rbx
  80132a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801331:	49 89 fd             	mov    %rdi,%r13
  801334:	41 89 f6             	mov    %esi,%r14d
  801337:	49 89 d4             	mov    %rdx,%r12
  80133a:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801341:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801348:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80134f:	84 c0                	test   %al,%al
  801351:	74 26                	je     801379 <_panic+0x5a>
  801353:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80135a:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801361:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801365:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  801369:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80136d:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801371:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801375:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801379:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801380:	00 00 00 
  801383:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80138a:	00 00 00 
  80138d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801391:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801398:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80139f:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8013a6:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8013ad:	00 00 00 
  8013b0:	48 8b 18             	mov    (%rax),%rbx
  8013b3:	48 b8 72 10 80 00 00 	movabs $0x801072,%rax
  8013ba:	00 00 00 
  8013bd:	ff d0                	callq  *%rax
  8013bf:	45 89 f0             	mov    %r14d,%r8d
  8013c2:	4c 89 e9             	mov    %r13,%rcx
  8013c5:	48 89 da             	mov    %rbx,%rdx
  8013c8:	89 c6                	mov    %eax,%esi
  8013ca:	48 bf 70 18 80 00 00 	movabs $0x801870,%rdi
  8013d1:	00 00 00 
  8013d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d9:	48 bb e0 01 80 00 00 	movabs $0x8001e0,%rbx
  8013e0:	00 00 00 
  8013e3:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8013e5:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8013ec:	4c 89 e7             	mov    %r12,%rdi
  8013ef:	48 b8 78 01 80 00 00 	movabs $0x800178,%rax
  8013f6:	00 00 00 
  8013f9:	ff d0                	callq  *%rax
  cprintf("\n");
  8013fb:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  801402:	00 00 00 
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
  80140a:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80140c:	cc                   	int3   
  while (1)
  80140d:	eb fd                	jmp    80140c <_panic+0xed>
  80140f:	90                   	nop
