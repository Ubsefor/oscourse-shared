
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
  800033:	48 bf 40 14 80 00 00 	movabs $0x801440,%rdi
  80003a:	00 00 00 
  80003d:	b8 00 00 00 00       	mov    $0x0,%eax
  800042:	48 bb f5 01 80 00 00 	movabs $0x8001f5,%rbx
  800049:	00 00 00 
  80004c:	ff d3                	callq  *%rbx
  cprintf("i am environment %08x\n", thisenv->env_id);
  80004e:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  800055:	00 00 00 
  800058:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80005e:	48 bf 4e 14 80 00 00 	movabs $0x80144e,%rdi
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000c3:	48 b8 87 10 80 00 00 	movabs $0x801087,%rax
  8000ca:	00 00 00 
  8000cd:	ff d0                	callq  *%rax
  8000cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d4:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000d8:	48 c1 e0 05          	shl    $0x5,%rax
  8000dc:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000e3:	00 00 00 
  8000e6:	48 01 d0             	add    %rdx,%rax
  8000e9:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000f0:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000f3:	45 85 ed             	test   %r13d,%r13d
  8000f6:	7e 0d                	jle    800105 <libmain+0x8f>
    binaryname = argv[0];
  8000f8:	49 8b 06             	mov    (%r14),%rax
  8000fb:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800102:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800105:	4c 89 f6             	mov    %r14,%rsi
  800108:	44 89 ef             	mov    %r13d,%edi
  80010b:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800112:	00 00 00 
  800115:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800117:	48 b8 2c 01 80 00 00 	movabs $0x80012c,%rax
  80011e:	00 00 00 
  800121:	ff d0                	callq  *%rax
#endif
}
  800123:	5b                   	pop    %rbx
  800124:	41 5c                	pop    %r12
  800126:	41 5d                	pop    %r13
  800128:	41 5e                	pop    %r14
  80012a:	5d                   	pop    %rbp
  80012b:	c3                   	retq   

000000000080012c <exit>:

#include <inc/lib.h>

void
exit(void) {
  80012c:	55                   	push   %rbp
  80012d:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800130:	bf 00 00 00 00       	mov    $0x0,%edi
  800135:	48 b8 27 10 80 00 00 	movabs $0x801027,%rax
  80013c:	00 00 00 
  80013f:	ff d0                	callq  *%rax
}
  800141:	5d                   	pop    %rbp
  800142:	c3                   	retq   

0000000000800143 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800143:	55                   	push   %rbp
  800144:	48 89 e5             	mov    %rsp,%rbp
  800147:	53                   	push   %rbx
  800148:	48 83 ec 08          	sub    $0x8,%rsp
  80014c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80014f:	8b 06                	mov    (%rsi),%eax
  800151:	8d 50 01             	lea    0x1(%rax),%edx
  800154:	89 16                	mov    %edx,(%rsi)
  800156:	48 98                	cltq   
  800158:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80015d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800163:	74 0b                	je     800170 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800165:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800169:	48 83 c4 08          	add    $0x8,%rsp
  80016d:	5b                   	pop    %rbx
  80016e:	5d                   	pop    %rbp
  80016f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800170:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800174:	be ff 00 00 00       	mov    $0xff,%esi
  800179:	48 b8 e9 0f 80 00 00 	movabs $0x800fe9,%rax
  800180:	00 00 00 
  800183:	ff d0                	callq  *%rax
    b->idx = 0;
  800185:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80018b:	eb d8                	jmp    800165 <putch+0x22>

000000000080018d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80018d:	55                   	push   %rbp
  80018e:	48 89 e5             	mov    %rsp,%rbp
  800191:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800198:	48 89 fa             	mov    %rdi,%rdx
  80019b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80019e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8001a5:	00 00 00 
  b.cnt = 0;
  8001a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8001af:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8001b2:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001b9:	48 bf 43 01 80 00 00 	movabs $0x800143,%rdi
  8001c0:	00 00 00 
  8001c3:	48 b8 b3 03 80 00 00 	movabs $0x8003b3,%rax
  8001ca:	00 00 00 
  8001cd:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001cf:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001d6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001dd:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001e1:	48 b8 e9 0f 80 00 00 	movabs $0x800fe9,%rax
  8001e8:	00 00 00 
  8001eb:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001f3:	c9                   	leaveq 
  8001f4:	c3                   	retq   

00000000008001f5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001f5:	55                   	push   %rbp
  8001f6:	48 89 e5             	mov    %rsp,%rbp
  8001f9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800200:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800207:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80020e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800215:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80021c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800223:	84 c0                	test   %al,%al
  800225:	74 20                	je     800247 <cprintf+0x52>
  800227:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80022b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80022f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800233:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800237:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80023b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80023f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800243:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800247:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80024e:	00 00 00 
  800251:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800258:	00 00 00 
  80025b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80025f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800266:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80026d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800274:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80027b:	48 b8 8d 01 80 00 00 	movabs $0x80018d,%rax
  800282:	00 00 00 
  800285:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800287:	c9                   	leaveq 
  800288:	c3                   	retq   

0000000000800289 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800289:	55                   	push   %rbp
  80028a:	48 89 e5             	mov    %rsp,%rbp
  80028d:	41 57                	push   %r15
  80028f:	41 56                	push   %r14
  800291:	41 55                	push   %r13
  800293:	41 54                	push   %r12
  800295:	53                   	push   %rbx
  800296:	48 83 ec 18          	sub    $0x18,%rsp
  80029a:	49 89 fc             	mov    %rdi,%r12
  80029d:	49 89 f5             	mov    %rsi,%r13
  8002a0:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8002a4:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8002a7:	41 89 cf             	mov    %ecx,%r15d
  8002aa:	49 39 d7             	cmp    %rdx,%r15
  8002ad:	76 45                	jbe    8002f4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8002af:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8002b3:	85 db                	test   %ebx,%ebx
  8002b5:	7e 0e                	jle    8002c5 <printnum+0x3c>
      putch(padc, putdat);
  8002b7:	4c 89 ee             	mov    %r13,%rsi
  8002ba:	44 89 f7             	mov    %r14d,%edi
  8002bd:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002c0:	83 eb 01             	sub    $0x1,%ebx
  8002c3:	75 f2                	jne    8002b7 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002c5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	49 f7 f7             	div    %r15
  8002d1:	48 b8 6f 14 80 00 00 	movabs $0x80146f,%rax
  8002d8:	00 00 00 
  8002db:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002df:	4c 89 ee             	mov    %r13,%rsi
  8002e2:	41 ff d4             	callq  *%r12
}
  8002e5:	48 83 c4 18          	add    $0x18,%rsp
  8002e9:	5b                   	pop    %rbx
  8002ea:	41 5c                	pop    %r12
  8002ec:	41 5d                	pop    %r13
  8002ee:	41 5e                	pop    %r14
  8002f0:	41 5f                	pop    %r15
  8002f2:	5d                   	pop    %rbp
  8002f3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	49 f7 f7             	div    %r15
  800300:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800304:	48 89 c2             	mov    %rax,%rdx
  800307:	48 b8 89 02 80 00 00 	movabs $0x800289,%rax
  80030e:	00 00 00 
  800311:	ff d0                	callq  *%rax
  800313:	eb b0                	jmp    8002c5 <printnum+0x3c>

0000000000800315 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800315:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800319:	48 8b 06             	mov    (%rsi),%rax
  80031c:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800320:	73 0a                	jae    80032c <sprintputch+0x17>
    *b->buf++ = ch;
  800322:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800326:	48 89 16             	mov    %rdx,(%rsi)
  800329:	40 88 38             	mov    %dil,(%rax)
}
  80032c:	c3                   	retq   

000000000080032d <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80032d:	55                   	push   %rbp
  80032e:	48 89 e5             	mov    %rsp,%rbp
  800331:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800338:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80033f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800346:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80034d:	84 c0                	test   %al,%al
  80034f:	74 20                	je     800371 <printfmt+0x44>
  800351:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800355:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800359:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80035d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800361:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800365:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800369:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80036d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800371:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800378:	00 00 00 
  80037b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800382:	00 00 00 
  800385:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800389:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800390:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800397:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80039e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8003a5:	48 b8 b3 03 80 00 00 	movabs $0x8003b3,%rax
  8003ac:	00 00 00 
  8003af:	ff d0                	callq  *%rax
}
  8003b1:	c9                   	leaveq 
  8003b2:	c3                   	retq   

00000000008003b3 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8003b3:	55                   	push   %rbp
  8003b4:	48 89 e5             	mov    %rsp,%rbp
  8003b7:	41 57                	push   %r15
  8003b9:	41 56                	push   %r14
  8003bb:	41 55                	push   %r13
  8003bd:	41 54                	push   %r12
  8003bf:	53                   	push   %rbx
  8003c0:	48 83 ec 48          	sub    $0x48,%rsp
  8003c4:	49 89 fd             	mov    %rdi,%r13
  8003c7:	49 89 f7             	mov    %rsi,%r15
  8003ca:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003cd:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003d1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003d5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003d9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003dd:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003e1:	41 0f b6 3e          	movzbl (%r14),%edi
  8003e5:	83 ff 25             	cmp    $0x25,%edi
  8003e8:	74 18                	je     800402 <vprintfmt+0x4f>
      if (ch == '\0')
  8003ea:	85 ff                	test   %edi,%edi
  8003ec:	0f 84 8c 06 00 00    	je     800a7e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003f2:	4c 89 fe             	mov    %r15,%rsi
  8003f5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003f8:	49 89 de             	mov    %rbx,%r14
  8003fb:	eb e0                	jmp    8003dd <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003fd:	49 89 de             	mov    %rbx,%r14
  800400:	eb db                	jmp    8003dd <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800402:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800406:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80040a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800411:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800417:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80041b:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800420:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800426:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80042c:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800431:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800436:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80043a:	0f b6 13             	movzbl (%rbx),%edx
  80043d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800440:	3c 55                	cmp    $0x55,%al
  800442:	0f 87 8b 05 00 00    	ja     8009d3 <vprintfmt+0x620>
  800448:	0f b6 c0             	movzbl %al,%eax
  80044b:	49 bb 40 15 80 00 00 	movabs $0x801540,%r11
  800452:	00 00 00 
  800455:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800459:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80045c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800460:	eb d4                	jmp    800436 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800462:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800465:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800469:	eb cb                	jmp    800436 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80046b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80046e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800472:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800476:	8d 50 d0             	lea    -0x30(%rax),%edx
  800479:	83 fa 09             	cmp    $0x9,%edx
  80047c:	77 7e                	ja     8004fc <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80047e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800482:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800486:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80048b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80048f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800492:	83 fa 09             	cmp    $0x9,%edx
  800495:	76 e7                	jbe    80047e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800497:	4c 89 f3             	mov    %r14,%rbx
  80049a:	eb 19                	jmp    8004b5 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80049c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80049f:	83 f8 2f             	cmp    $0x2f,%eax
  8004a2:	77 2a                	ja     8004ce <vprintfmt+0x11b>
  8004a4:	89 c2                	mov    %eax,%edx
  8004a6:	4c 01 d2             	add    %r10,%rdx
  8004a9:	83 c0 08             	add    $0x8,%eax
  8004ac:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004af:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8004b2:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004b5:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004b9:	0f 89 77 ff ff ff    	jns    800436 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004bf:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004c3:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004c9:	e9 68 ff ff ff       	jmpq   800436 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004ce:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004d2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004d6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004da:	eb d3                	jmp    8004af <vprintfmt+0xfc>
        if (width < 0)
  8004dc:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004e5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004e8:	4c 89 f3             	mov    %r14,%rbx
  8004eb:	e9 46 ff ff ff       	jmpq   800436 <vprintfmt+0x83>
  8004f0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004f3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004f7:	e9 3a ff ff ff       	jmpq   800436 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004fc:	4c 89 f3             	mov    %r14,%rbx
  8004ff:	eb b4                	jmp    8004b5 <vprintfmt+0x102>
        lflag++;
  800501:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800504:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800507:	e9 2a ff ff ff       	jmpq   800436 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80050c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80050f:	83 f8 2f             	cmp    $0x2f,%eax
  800512:	77 19                	ja     80052d <vprintfmt+0x17a>
  800514:	89 c2                	mov    %eax,%edx
  800516:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80051a:	83 c0 08             	add    $0x8,%eax
  80051d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800520:	4c 89 fe             	mov    %r15,%rsi
  800523:	8b 3a                	mov    (%rdx),%edi
  800525:	41 ff d5             	callq  *%r13
        break;
  800528:	e9 b0 fe ff ff       	jmpq   8003dd <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80052d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800531:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800535:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800539:	eb e5                	jmp    800520 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80053b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80053e:	83 f8 2f             	cmp    $0x2f,%eax
  800541:	77 5b                	ja     80059e <vprintfmt+0x1eb>
  800543:	89 c2                	mov    %eax,%edx
  800545:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800549:	83 c0 08             	add    $0x8,%eax
  80054c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80054f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800551:	89 c8                	mov    %ecx,%eax
  800553:	c1 f8 1f             	sar    $0x1f,%eax
  800556:	31 c1                	xor    %eax,%ecx
  800558:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f9 0b             	cmp    $0xb,%ecx
  80055d:	7f 4d                	jg     8005ac <vprintfmt+0x1f9>
  80055f:	48 63 c1             	movslq %ecx,%rax
  800562:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  800569:	00 00 00 
  80056c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800570:	48 85 c0             	test   %rax,%rax
  800573:	74 37                	je     8005ac <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800575:	48 89 c1             	mov    %rax,%rcx
  800578:	48 ba 90 14 80 00 00 	movabs $0x801490,%rdx
  80057f:	00 00 00 
  800582:	4c 89 fe             	mov    %r15,%rsi
  800585:	4c 89 ef             	mov    %r13,%rdi
  800588:	b8 00 00 00 00       	mov    $0x0,%eax
  80058d:	48 bb 2d 03 80 00 00 	movabs $0x80032d,%rbx
  800594:	00 00 00 
  800597:	ff d3                	callq  *%rbx
  800599:	e9 3f fe ff ff       	jmpq   8003dd <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80059e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005a2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005a6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005aa:	eb a3                	jmp    80054f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8005ac:	48 ba 87 14 80 00 00 	movabs $0x801487,%rdx
  8005b3:	00 00 00 
  8005b6:	4c 89 fe             	mov    %r15,%rsi
  8005b9:	4c 89 ef             	mov    %r13,%rdi
  8005bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c1:	48 bb 2d 03 80 00 00 	movabs $0x80032d,%rbx
  8005c8:	00 00 00 
  8005cb:	ff d3                	callq  *%rbx
  8005cd:	e9 0b fe ff ff       	jmpq   8003dd <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005d2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005d5:	83 f8 2f             	cmp    $0x2f,%eax
  8005d8:	77 4b                	ja     800625 <vprintfmt+0x272>
  8005da:	89 c2                	mov    %eax,%edx
  8005dc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005e0:	83 c0 08             	add    $0x8,%eax
  8005e3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005e6:	48 8b 02             	mov    (%rdx),%rax
  8005e9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005ed:	48 85 c0             	test   %rax,%rax
  8005f0:	0f 84 05 04 00 00    	je     8009fb <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005f6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005fa:	7e 06                	jle    800602 <vprintfmt+0x24f>
  8005fc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800600:	75 31                	jne    800633 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800602:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800606:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80060a:	0f b6 00             	movzbl (%rax),%eax
  80060d:	0f be f8             	movsbl %al,%edi
  800610:	85 ff                	test   %edi,%edi
  800612:	0f 84 c3 00 00 00    	je     8006db <vprintfmt+0x328>
  800618:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80061c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800620:	e9 85 00 00 00       	jmpq   8006aa <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800625:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800629:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80062d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800631:	eb b3                	jmp    8005e6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800633:	49 63 f4             	movslq %r12d,%rsi
  800636:	48 89 c7             	mov    %rax,%rdi
  800639:	48 b8 8a 0b 80 00 00 	movabs $0x800b8a,%rax
  800640:	00 00 00 
  800643:	ff d0                	callq  *%rax
  800645:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800648:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80064b:	85 f6                	test   %esi,%esi
  80064d:	7e 22                	jle    800671 <vprintfmt+0x2be>
            putch(padc, putdat);
  80064f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800653:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800657:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80065b:	4c 89 fe             	mov    %r15,%rsi
  80065e:	89 df                	mov    %ebx,%edi
  800660:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800663:	41 83 ec 01          	sub    $0x1,%r12d
  800667:	75 f2                	jne    80065b <vprintfmt+0x2a8>
  800669:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80066d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800671:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800675:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800679:	0f b6 00             	movzbl (%rax),%eax
  80067c:	0f be f8             	movsbl %al,%edi
  80067f:	85 ff                	test   %edi,%edi
  800681:	0f 84 56 fd ff ff    	je     8003dd <vprintfmt+0x2a>
  800687:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80068b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80068f:	eb 19                	jmp    8006aa <vprintfmt+0x2f7>
            putch(ch, putdat);
  800691:	4c 89 fe             	mov    %r15,%rsi
  800694:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800697:	41 83 ee 01          	sub    $0x1,%r14d
  80069b:	48 83 c3 01          	add    $0x1,%rbx
  80069f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8006a3:	0f be f8             	movsbl %al,%edi
  8006a6:	85 ff                	test   %edi,%edi
  8006a8:	74 29                	je     8006d3 <vprintfmt+0x320>
  8006aa:	45 85 e4             	test   %r12d,%r12d
  8006ad:	78 06                	js     8006b5 <vprintfmt+0x302>
  8006af:	41 83 ec 01          	sub    $0x1,%r12d
  8006b3:	78 48                	js     8006fd <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006b5:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006b9:	74 d6                	je     800691 <vprintfmt+0x2de>
  8006bb:	0f be c0             	movsbl %al,%eax
  8006be:	83 e8 20             	sub    $0x20,%eax
  8006c1:	83 f8 5e             	cmp    $0x5e,%eax
  8006c4:	76 cb                	jbe    800691 <vprintfmt+0x2de>
            putch('?', putdat);
  8006c6:	4c 89 fe             	mov    %r15,%rsi
  8006c9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006ce:	41 ff d5             	callq  *%r13
  8006d1:	eb c4                	jmp    800697 <vprintfmt+0x2e4>
  8006d3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006d7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006db:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006de:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006e2:	0f 8e f5 fc ff ff    	jle    8003dd <vprintfmt+0x2a>
          putch(' ', putdat);
  8006e8:	4c 89 fe             	mov    %r15,%rsi
  8006eb:	bf 20 00 00 00       	mov    $0x20,%edi
  8006f0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006f3:	83 eb 01             	sub    $0x1,%ebx
  8006f6:	75 f0                	jne    8006e8 <vprintfmt+0x335>
  8006f8:	e9 e0 fc ff ff       	jmpq   8003dd <vprintfmt+0x2a>
  8006fd:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800701:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800705:	eb d4                	jmp    8006db <vprintfmt+0x328>
  if (lflag >= 2)
  800707:	83 f9 01             	cmp    $0x1,%ecx
  80070a:	7f 1d                	jg     800729 <vprintfmt+0x376>
  else if (lflag)
  80070c:	85 c9                	test   %ecx,%ecx
  80070e:	74 5e                	je     80076e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800710:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800713:	83 f8 2f             	cmp    $0x2f,%eax
  800716:	77 48                	ja     800760 <vprintfmt+0x3ad>
  800718:	89 c2                	mov    %eax,%edx
  80071a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80071e:	83 c0 08             	add    $0x8,%eax
  800721:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800724:	48 8b 1a             	mov    (%rdx),%rbx
  800727:	eb 17                	jmp    800740 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800729:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80072c:	83 f8 2f             	cmp    $0x2f,%eax
  80072f:	77 21                	ja     800752 <vprintfmt+0x39f>
  800731:	89 c2                	mov    %eax,%edx
  800733:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800737:	83 c0 08             	add    $0x8,%eax
  80073a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80073d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800740:	48 85 db             	test   %rbx,%rbx
  800743:	78 50                	js     800795 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800745:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800748:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074d:	e9 b4 01 00 00       	jmpq   800906 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800752:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800756:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80075a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80075e:	eb dd                	jmp    80073d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800760:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800764:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800768:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80076c:	eb b6                	jmp    800724 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80076e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800771:	83 f8 2f             	cmp    $0x2f,%eax
  800774:	77 11                	ja     800787 <vprintfmt+0x3d4>
  800776:	89 c2                	mov    %eax,%edx
  800778:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80077c:	83 c0 08             	add    $0x8,%eax
  80077f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800782:	48 63 1a             	movslq (%rdx),%rbx
  800785:	eb b9                	jmp    800740 <vprintfmt+0x38d>
  800787:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80078b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80078f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800793:	eb ed                	jmp    800782 <vprintfmt+0x3cf>
          putch('-', putdat);
  800795:	4c 89 fe             	mov    %r15,%rsi
  800798:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80079d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8007a0:	48 89 da             	mov    %rbx,%rdx
  8007a3:	48 f7 da             	neg    %rdx
        base = 10;
  8007a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ab:	e9 56 01 00 00       	jmpq   800906 <vprintfmt+0x553>
  if (lflag >= 2)
  8007b0:	83 f9 01             	cmp    $0x1,%ecx
  8007b3:	7f 25                	jg     8007da <vprintfmt+0x427>
  else if (lflag)
  8007b5:	85 c9                	test   %ecx,%ecx
  8007b7:	74 5e                	je     800817 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007b9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007bc:	83 f8 2f             	cmp    $0x2f,%eax
  8007bf:	77 48                	ja     800809 <vprintfmt+0x456>
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007c7:	83 c0 08             	add    $0x8,%eax
  8007ca:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007cd:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d5:	e9 2c 01 00 00       	jmpq   800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007da:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007dd:	83 f8 2f             	cmp    $0x2f,%eax
  8007e0:	77 19                	ja     8007fb <vprintfmt+0x448>
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007e8:	83 c0 08             	add    $0x8,%eax
  8007eb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ee:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007f6:	e9 0b 01 00 00       	jmpq   800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007fb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800803:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800807:	eb e5                	jmp    8007ee <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800809:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80080d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800811:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800815:	eb b6                	jmp    8007cd <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800817:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80081a:	83 f8 2f             	cmp    $0x2f,%eax
  80081d:	77 18                	ja     800837 <vprintfmt+0x484>
  80081f:	89 c2                	mov    %eax,%edx
  800821:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800825:	83 c0 08             	add    $0x8,%eax
  800828:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80082b:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80082d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800832:	e9 cf 00 00 00       	jmpq   800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800837:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80083b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80083f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800843:	eb e6                	jmp    80082b <vprintfmt+0x478>
  if (lflag >= 2)
  800845:	83 f9 01             	cmp    $0x1,%ecx
  800848:	7f 25                	jg     80086f <vprintfmt+0x4bc>
  else if (lflag)
  80084a:	85 c9                	test   %ecx,%ecx
  80084c:	74 5b                	je     8008a9 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80084e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800851:	83 f8 2f             	cmp    $0x2f,%eax
  800854:	77 45                	ja     80089b <vprintfmt+0x4e8>
  800856:	89 c2                	mov    %eax,%edx
  800858:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80085c:	83 c0 08             	add    $0x8,%eax
  80085f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800862:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800865:	b9 08 00 00 00       	mov    $0x8,%ecx
  80086a:	e9 97 00 00 00       	jmpq   800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80086f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800872:	83 f8 2f             	cmp    $0x2f,%eax
  800875:	77 16                	ja     80088d <vprintfmt+0x4da>
  800877:	89 c2                	mov    %eax,%edx
  800879:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80087d:	83 c0 08             	add    $0x8,%eax
  800880:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800883:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800886:	b9 08 00 00 00       	mov    $0x8,%ecx
  80088b:	eb 79                	jmp    800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80088d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800891:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800895:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800899:	eb e8                	jmp    800883 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80089b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80089f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008a3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a7:	eb b9                	jmp    800862 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8008a9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ac:	83 f8 2f             	cmp    $0x2f,%eax
  8008af:	77 15                	ja     8008c6 <vprintfmt+0x513>
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b7:	83 c0 08             	add    $0x8,%eax
  8008ba:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008bd:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008bf:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008c4:	eb 40                	jmp    800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008c6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ca:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ce:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d2:	eb e9                	jmp    8008bd <vprintfmt+0x50a>
        putch('0', putdat);
  8008d4:	4c 89 fe             	mov    %r15,%rsi
  8008d7:	bf 30 00 00 00       	mov    $0x30,%edi
  8008dc:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008df:	4c 89 fe             	mov    %r15,%rsi
  8008e2:	bf 78 00 00 00       	mov    $0x78,%edi
  8008e7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008ea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ed:	83 f8 2f             	cmp    $0x2f,%eax
  8008f0:	77 34                	ja     800926 <vprintfmt+0x573>
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f8:	83 c0 08             	add    $0x8,%eax
  8008fb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fe:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800901:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800906:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  80090b:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  80090f:	4c 89 fe             	mov    %r15,%rsi
  800912:	4c 89 ef             	mov    %r13,%rdi
  800915:	48 b8 89 02 80 00 00 	movabs $0x800289,%rax
  80091c:	00 00 00 
  80091f:	ff d0                	callq  *%rax
        break;
  800921:	e9 b7 fa ff ff       	jmpq   8003dd <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800926:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80092a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80092e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800932:	eb ca                	jmp    8008fe <vprintfmt+0x54b>
  if (lflag >= 2)
  800934:	83 f9 01             	cmp    $0x1,%ecx
  800937:	7f 22                	jg     80095b <vprintfmt+0x5a8>
  else if (lflag)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 58                	je     800995 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80093d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800940:	83 f8 2f             	cmp    $0x2f,%eax
  800943:	77 42                	ja     800987 <vprintfmt+0x5d4>
  800945:	89 c2                	mov    %eax,%edx
  800947:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094b:	83 c0 08             	add    $0x8,%eax
  80094e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800951:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800954:	b9 10 00 00 00       	mov    $0x10,%ecx
  800959:	eb ab                	jmp    800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80095b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095e:	83 f8 2f             	cmp    $0x2f,%eax
  800961:	77 16                	ja     800979 <vprintfmt+0x5c6>
  800963:	89 c2                	mov    %eax,%edx
  800965:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800969:	83 c0 08             	add    $0x8,%eax
  80096c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80096f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800972:	b9 10 00 00 00       	mov    $0x10,%ecx
  800977:	eb 8d                	jmp    800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800979:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800981:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800985:	eb e8                	jmp    80096f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800987:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80098b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80098f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800993:	eb bc                	jmp    800951 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800995:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800998:	83 f8 2f             	cmp    $0x2f,%eax
  80099b:	77 18                	ja     8009b5 <vprintfmt+0x602>
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a3:	83 c0 08             	add    $0x8,%eax
  8009a6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009a9:	8b 12                	mov    (%rdx),%edx
        base = 16;
  8009ab:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009b0:	e9 51 ff ff ff       	jmpq   800906 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009b5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009b9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009bd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c1:	eb e6                	jmp    8009a9 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009c3:	4c 89 fe             	mov    %r15,%rsi
  8009c6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009cb:	41 ff d5             	callq  *%r13
        break;
  8009ce:	e9 0a fa ff ff       	jmpq   8003dd <vprintfmt+0x2a>
        putch('%', putdat);
  8009d3:	4c 89 fe             	mov    %r15,%rsi
  8009d6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009db:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009de:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009e2:	0f 84 15 fa ff ff    	je     8003fd <vprintfmt+0x4a>
  8009e8:	49 89 de             	mov    %rbx,%r14
  8009eb:	49 83 ee 01          	sub    $0x1,%r14
  8009ef:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009f4:	75 f5                	jne    8009eb <vprintfmt+0x638>
  8009f6:	e9 e2 f9 ff ff       	jmpq   8003dd <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009fb:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009ff:	74 06                	je     800a07 <vprintfmt+0x654>
  800a01:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a05:	7f 21                	jg     800a28 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a07:	bf 28 00 00 00       	mov    $0x28,%edi
  800a0c:	48 bb 81 14 80 00 00 	movabs $0x801481,%rbx
  800a13:	00 00 00 
  800a16:	b8 28 00 00 00       	mov    $0x28,%eax
  800a1b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a1f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a23:	e9 82 fc ff ff       	jmpq   8006aa <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a28:	49 63 f4             	movslq %r12d,%rsi
  800a2b:	48 bf 80 14 80 00 00 	movabs $0x801480,%rdi
  800a32:	00 00 00 
  800a35:	48 b8 8a 0b 80 00 00 	movabs $0x800b8a,%rax
  800a3c:	00 00 00 
  800a3f:	ff d0                	callq  *%rax
  800a41:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a44:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a47:	48 be 80 14 80 00 00 	movabs $0x801480,%rsi
  800a4e:	00 00 00 
  800a51:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a55:	85 c0                	test   %eax,%eax
  800a57:	0f 8f f2 fb ff ff    	jg     80064f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5d:	48 bb 81 14 80 00 00 	movabs $0x801481,%rbx
  800a64:	00 00 00 
  800a67:	b8 28 00 00 00       	mov    $0x28,%eax
  800a6c:	bf 28 00 00 00       	mov    $0x28,%edi
  800a71:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a75:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a79:	e9 2c fc ff ff       	jmpq   8006aa <vprintfmt+0x2f7>
}
  800a7e:	48 83 c4 48          	add    $0x48,%rsp
  800a82:	5b                   	pop    %rbx
  800a83:	41 5c                	pop    %r12
  800a85:	41 5d                	pop    %r13
  800a87:	41 5e                	pop    %r14
  800a89:	41 5f                	pop    %r15
  800a8b:	5d                   	pop    %rbp
  800a8c:	c3                   	retq   

0000000000800a8d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a8d:	55                   	push   %rbp
  800a8e:	48 89 e5             	mov    %rsp,%rbp
  800a91:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a95:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a99:	48 63 c6             	movslq %esi,%rax
  800a9c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800aa1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800aa5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800aac:	48 85 ff             	test   %rdi,%rdi
  800aaf:	74 2a                	je     800adb <vsnprintf+0x4e>
  800ab1:	85 f6                	test   %esi,%esi
  800ab3:	7e 26                	jle    800adb <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ab5:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800ab9:	48 bf 15 03 80 00 00 	movabs $0x800315,%rdi
  800ac0:	00 00 00 
  800ac3:	48 b8 b3 03 80 00 00 	movabs $0x8003b3,%rax
  800aca:	00 00 00 
  800acd:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800acf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ad3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ad6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ad9:	c9                   	leaveq 
  800ada:	c3                   	retq   
    return -E_INVAL;
  800adb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae0:	eb f7                	jmp    800ad9 <vsnprintf+0x4c>

0000000000800ae2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ae2:	55                   	push   %rbp
  800ae3:	48 89 e5             	mov    %rsp,%rbp
  800ae6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800aed:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800af4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800afb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800b02:	84 c0                	test   %al,%al
  800b04:	74 20                	je     800b26 <snprintf+0x44>
  800b06:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800b0a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800b0e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b12:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b16:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b1a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b1e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b22:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b26:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b2d:	00 00 00 
  800b30:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b37:	00 00 00 
  800b3a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b3e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b45:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b4c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b53:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b5a:	48 b8 8d 0a 80 00 00 	movabs $0x800a8d,%rax
  800b61:	00 00 00 
  800b64:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b66:	c9                   	leaveq 
  800b67:	c3                   	retq   

0000000000800b68 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b68:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b6b:	74 17                	je     800b84 <strlen+0x1c>
  800b6d:	48 89 fa             	mov    %rdi,%rdx
  800b70:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b75:	29 f9                	sub    %edi,%ecx
    n++;
  800b77:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b7a:	48 83 c2 01          	add    $0x1,%rdx
  800b7e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b81:	75 f4                	jne    800b77 <strlen+0xf>
  800b83:	c3                   	retq   
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b89:	c3                   	retq   

0000000000800b8a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8a:	48 85 f6             	test   %rsi,%rsi
  800b8d:	74 24                	je     800bb3 <strnlen+0x29>
  800b8f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b92:	74 25                	je     800bb9 <strnlen+0x2f>
  800b94:	48 01 fe             	add    %rdi,%rsi
  800b97:	48 89 fa             	mov    %rdi,%rdx
  800b9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b9f:	29 f9                	sub    %edi,%ecx
    n++;
  800ba1:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba4:	48 83 c2 01          	add    $0x1,%rdx
  800ba8:	48 39 f2             	cmp    %rsi,%rdx
  800bab:	74 11                	je     800bbe <strnlen+0x34>
  800bad:	80 3a 00             	cmpb   $0x0,(%rdx)
  800bb0:	75 ef                	jne    800ba1 <strnlen+0x17>
  800bb2:	c3                   	retq   
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	c3                   	retq   
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800bbe:	c3                   	retq   

0000000000800bbf <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800bbf:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bcb:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bce:	48 83 c2 01          	add    $0x1,%rdx
  800bd2:	84 c9                	test   %cl,%cl
  800bd4:	75 f1                	jne    800bc7 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bd6:	c3                   	retq   

0000000000800bd7 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bd7:	55                   	push   %rbp
  800bd8:	48 89 e5             	mov    %rsp,%rbp
  800bdb:	41 54                	push   %r12
  800bdd:	53                   	push   %rbx
  800bde:	48 89 fb             	mov    %rdi,%rbx
  800be1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800be4:	48 b8 68 0b 80 00 00 	movabs $0x800b68,%rax
  800beb:	00 00 00 
  800bee:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bf0:	48 63 f8             	movslq %eax,%rdi
  800bf3:	48 01 df             	add    %rbx,%rdi
  800bf6:	4c 89 e6             	mov    %r12,%rsi
  800bf9:	48 b8 bf 0b 80 00 00 	movabs $0x800bbf,%rax
  800c00:	00 00 00 
  800c03:	ff d0                	callq  *%rax
  return dst;
}
  800c05:	48 89 d8             	mov    %rbx,%rax
  800c08:	5b                   	pop    %rbx
  800c09:	41 5c                	pop    %r12
  800c0b:	5d                   	pop    %rbp
  800c0c:	c3                   	retq   

0000000000800c0d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c0d:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c10:	48 85 d2             	test   %rdx,%rdx
  800c13:	74 1f                	je     800c34 <strncpy+0x27>
  800c15:	48 01 fa             	add    %rdi,%rdx
  800c18:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c1b:	48 83 c1 01          	add    $0x1,%rcx
  800c1f:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c23:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c27:	41 80 f8 01          	cmp    $0x1,%r8b
  800c2b:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c2f:	48 39 ca             	cmp    %rcx,%rdx
  800c32:	75 e7                	jne    800c1b <strncpy+0xe>
  }
  return ret;
}
  800c34:	c3                   	retq   

0000000000800c35 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c35:	48 89 f8             	mov    %rdi,%rax
  800c38:	48 85 d2             	test   %rdx,%rdx
  800c3b:	74 36                	je     800c73 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c3d:	48 83 fa 01          	cmp    $0x1,%rdx
  800c41:	74 2d                	je     800c70 <strlcpy+0x3b>
  800c43:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c47:	45 84 c0             	test   %r8b,%r8b
  800c4a:	74 24                	je     800c70 <strlcpy+0x3b>
  800c4c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c50:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c55:	48 83 c0 01          	add    $0x1,%rax
  800c59:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c5d:	48 39 d1             	cmp    %rdx,%rcx
  800c60:	74 0e                	je     800c70 <strlcpy+0x3b>
  800c62:	48 83 c1 01          	add    $0x1,%rcx
  800c66:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c6b:	45 84 c0             	test   %r8b,%r8b
  800c6e:	75 e5                	jne    800c55 <strlcpy+0x20>
    *dst = '\0';
  800c70:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c73:	48 29 f8             	sub    %rdi,%rax
}
  800c76:	c3                   	retq   

0000000000800c77 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c77:	0f b6 07             	movzbl (%rdi),%eax
  800c7a:	84 c0                	test   %al,%al
  800c7c:	74 17                	je     800c95 <strcmp+0x1e>
  800c7e:	3a 06                	cmp    (%rsi),%al
  800c80:	75 13                	jne    800c95 <strcmp+0x1e>
    p++, q++;
  800c82:	48 83 c7 01          	add    $0x1,%rdi
  800c86:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c8a:	0f b6 07             	movzbl (%rdi),%eax
  800c8d:	84 c0                	test   %al,%al
  800c8f:	74 04                	je     800c95 <strcmp+0x1e>
  800c91:	3a 06                	cmp    (%rsi),%al
  800c93:	74 ed                	je     800c82 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	0f b6 16             	movzbl (%rsi),%edx
  800c9b:	29 d0                	sub    %edx,%eax
}
  800c9d:	c3                   	retq   

0000000000800c9e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c9e:	48 85 d2             	test   %rdx,%rdx
  800ca1:	74 2f                	je     800cd2 <strncmp+0x34>
  800ca3:	0f b6 07             	movzbl (%rdi),%eax
  800ca6:	84 c0                	test   %al,%al
  800ca8:	74 1f                	je     800cc9 <strncmp+0x2b>
  800caa:	3a 06                	cmp    (%rsi),%al
  800cac:	75 1b                	jne    800cc9 <strncmp+0x2b>
  800cae:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800cb1:	48 83 c7 01          	add    $0x1,%rdi
  800cb5:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800cb9:	48 39 d7             	cmp    %rdx,%rdi
  800cbc:	74 1a                	je     800cd8 <strncmp+0x3a>
  800cbe:	0f b6 07             	movzbl (%rdi),%eax
  800cc1:	84 c0                	test   %al,%al
  800cc3:	74 04                	je     800cc9 <strncmp+0x2b>
  800cc5:	3a 06                	cmp    (%rsi),%al
  800cc7:	74 e8                	je     800cb1 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800cc9:	0f b6 07             	movzbl (%rdi),%eax
  800ccc:	0f b6 16             	movzbl (%rsi),%edx
  800ccf:	29 d0                	sub    %edx,%eax
}
  800cd1:	c3                   	retq   
    return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	c3                   	retq   
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdd:	c3                   	retq   

0000000000800cde <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cde:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ce0:	0f b6 07             	movzbl (%rdi),%eax
  800ce3:	84 c0                	test   %al,%al
  800ce5:	74 1e                	je     800d05 <strchr+0x27>
    if (*s == c)
  800ce7:	40 38 c6             	cmp    %al,%sil
  800cea:	74 1f                	je     800d0b <strchr+0x2d>
  for (; *s; s++)
  800cec:	48 83 c7 01          	add    $0x1,%rdi
  800cf0:	0f b6 07             	movzbl (%rdi),%eax
  800cf3:	84 c0                	test   %al,%al
  800cf5:	74 08                	je     800cff <strchr+0x21>
    if (*s == c)
  800cf7:	38 d0                	cmp    %dl,%al
  800cf9:	75 f1                	jne    800cec <strchr+0xe>
  for (; *s; s++)
  800cfb:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cfe:	c3                   	retq   
  return 0;
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
  800d04:	c3                   	retq   
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	c3                   	retq   
    if (*s == c)
  800d0b:	48 89 f8             	mov    %rdi,%rax
  800d0e:	c3                   	retq   

0000000000800d0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800d0f:	48 89 f8             	mov    %rdi,%rax
  800d12:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d14:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d17:	40 38 f2             	cmp    %sil,%dl
  800d1a:	74 13                	je     800d2f <strfind+0x20>
  800d1c:	84 d2                	test   %dl,%dl
  800d1e:	74 0f                	je     800d2f <strfind+0x20>
  for (; *s; s++)
  800d20:	48 83 c0 01          	add    $0x1,%rax
  800d24:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d27:	38 ca                	cmp    %cl,%dl
  800d29:	74 04                	je     800d2f <strfind+0x20>
  800d2b:	84 d2                	test   %dl,%dl
  800d2d:	75 f1                	jne    800d20 <strfind+0x11>
      break;
  return (char *)s;
}
  800d2f:	c3                   	retq   

0000000000800d30 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d30:	48 85 d2             	test   %rdx,%rdx
  800d33:	74 3a                	je     800d6f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d35:	48 89 f8             	mov    %rdi,%rax
  800d38:	48 09 d0             	or     %rdx,%rax
  800d3b:	a8 03                	test   $0x3,%al
  800d3d:	75 28                	jne    800d67 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d3f:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d43:	89 f0                	mov    %esi,%eax
  800d45:	c1 e0 08             	shl    $0x8,%eax
  800d48:	89 f1                	mov    %esi,%ecx
  800d4a:	c1 e1 18             	shl    $0x18,%ecx
  800d4d:	41 89 f0             	mov    %esi,%r8d
  800d50:	41 c1 e0 10          	shl    $0x10,%r8d
  800d54:	44 09 c1             	or     %r8d,%ecx
  800d57:	09 ce                	or     %ecx,%esi
  800d59:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d5b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d5f:	48 89 d1             	mov    %rdx,%rcx
  800d62:	fc                   	cld    
  800d63:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d65:	eb 08                	jmp    800d6f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d67:	89 f0                	mov    %esi,%eax
  800d69:	48 89 d1             	mov    %rdx,%rcx
  800d6c:	fc                   	cld    
  800d6d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d6f:	48 89 f8             	mov    %rdi,%rax
  800d72:	c3                   	retq   

0000000000800d73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d73:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d76:	48 39 fe             	cmp    %rdi,%rsi
  800d79:	73 40                	jae    800dbb <memmove+0x48>
  800d7b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d7f:	48 39 f9             	cmp    %rdi,%rcx
  800d82:	76 37                	jbe    800dbb <memmove+0x48>
    s += n;
    d += n;
  800d84:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d88:	48 89 fe             	mov    %rdi,%rsi
  800d8b:	48 09 d6             	or     %rdx,%rsi
  800d8e:	48 09 ce             	or     %rcx,%rsi
  800d91:	40 f6 c6 03          	test   $0x3,%sil
  800d95:	75 14                	jne    800dab <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d97:	48 83 ef 04          	sub    $0x4,%rdi
  800d9b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d9f:	48 c1 ea 02          	shr    $0x2,%rdx
  800da3:	48 89 d1             	mov    %rdx,%rcx
  800da6:	fd                   	std    
  800da7:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800da9:	eb 0e                	jmp    800db9 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800dab:	48 83 ef 01          	sub    $0x1,%rdi
  800daf:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800db3:	48 89 d1             	mov    %rdx,%rcx
  800db6:	fd                   	std    
  800db7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800db9:	fc                   	cld    
  800dba:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800dbb:	48 89 c1             	mov    %rax,%rcx
  800dbe:	48 09 d1             	or     %rdx,%rcx
  800dc1:	48 09 f1             	or     %rsi,%rcx
  800dc4:	f6 c1 03             	test   $0x3,%cl
  800dc7:	75 0e                	jne    800dd7 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800dc9:	48 c1 ea 02          	shr    $0x2,%rdx
  800dcd:	48 89 d1             	mov    %rdx,%rcx
  800dd0:	48 89 c7             	mov    %rax,%rdi
  800dd3:	fc                   	cld    
  800dd4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dd6:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800dd7:	48 89 c7             	mov    %rax,%rdi
  800dda:	48 89 d1             	mov    %rdx,%rcx
  800ddd:	fc                   	cld    
  800dde:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800de0:	c3                   	retq   

0000000000800de1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800de1:	55                   	push   %rbp
  800de2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800de5:	48 b8 73 0d 80 00 00 	movabs $0x800d73,%rax
  800dec:	00 00 00 
  800def:	ff d0                	callq  *%rax
}
  800df1:	5d                   	pop    %rbp
  800df2:	c3                   	retq   

0000000000800df3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800df3:	55                   	push   %rbp
  800df4:	48 89 e5             	mov    %rsp,%rbp
  800df7:	41 57                	push   %r15
  800df9:	41 56                	push   %r14
  800dfb:	41 55                	push   %r13
  800dfd:	41 54                	push   %r12
  800dff:	53                   	push   %rbx
  800e00:	48 83 ec 08          	sub    $0x8,%rsp
  800e04:	49 89 fe             	mov    %rdi,%r14
  800e07:	49 89 f7             	mov    %rsi,%r15
  800e0a:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800e0d:	48 89 f7             	mov    %rsi,%rdi
  800e10:	48 b8 68 0b 80 00 00 	movabs $0x800b68,%rax
  800e17:	00 00 00 
  800e1a:	ff d0                	callq  *%rax
  800e1c:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e1f:	4c 89 ee             	mov    %r13,%rsi
  800e22:	4c 89 f7             	mov    %r14,%rdi
  800e25:	48 b8 8a 0b 80 00 00 	movabs $0x800b8a,%rax
  800e2c:	00 00 00 
  800e2f:	ff d0                	callq  *%rax
  800e31:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e34:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e38:	4d 39 e5             	cmp    %r12,%r13
  800e3b:	74 26                	je     800e63 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e3d:	4c 89 e8             	mov    %r13,%rax
  800e40:	4c 29 e0             	sub    %r12,%rax
  800e43:	48 39 d8             	cmp    %rbx,%rax
  800e46:	76 2a                	jbe    800e72 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e48:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e4c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e50:	4c 89 fe             	mov    %r15,%rsi
  800e53:	48 b8 e1 0d 80 00 00 	movabs $0x800de1,%rax
  800e5a:	00 00 00 
  800e5d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e5f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e63:	48 83 c4 08          	add    $0x8,%rsp
  800e67:	5b                   	pop    %rbx
  800e68:	41 5c                	pop    %r12
  800e6a:	41 5d                	pop    %r13
  800e6c:	41 5e                	pop    %r14
  800e6e:	41 5f                	pop    %r15
  800e70:	5d                   	pop    %rbp
  800e71:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e72:	49 83 ed 01          	sub    $0x1,%r13
  800e76:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e7a:	4c 89 ea             	mov    %r13,%rdx
  800e7d:	4c 89 fe             	mov    %r15,%rsi
  800e80:	48 b8 e1 0d 80 00 00 	movabs $0x800de1,%rax
  800e87:	00 00 00 
  800e8a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e8c:	4d 01 ee             	add    %r13,%r14
  800e8f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e94:	eb c9                	jmp    800e5f <strlcat+0x6c>

0000000000800e96 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e96:	48 85 d2             	test   %rdx,%rdx
  800e99:	74 3a                	je     800ed5 <memcmp+0x3f>
    if (*s1 != *s2)
  800e9b:	0f b6 0f             	movzbl (%rdi),%ecx
  800e9e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ea2:	44 38 c1             	cmp    %r8b,%cl
  800ea5:	75 1d                	jne    800ec4 <memcmp+0x2e>
  800ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800eac:	48 39 d0             	cmp    %rdx,%rax
  800eaf:	74 1e                	je     800ecf <memcmp+0x39>
    if (*s1 != *s2)
  800eb1:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800eb5:	48 83 c0 01          	add    $0x1,%rax
  800eb9:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ebf:	44 38 c1             	cmp    %r8b,%cl
  800ec2:	74 e8                	je     800eac <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ec4:	0f b6 c1             	movzbl %cl,%eax
  800ec7:	45 0f b6 c0          	movzbl %r8b,%r8d
  800ecb:	44 29 c0             	sub    %r8d,%eax
  800ece:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	c3                   	retq   
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eda:	c3                   	retq   

0000000000800edb <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800edb:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800edf:	48 39 c7             	cmp    %rax,%rdi
  800ee2:	73 19                	jae    800efd <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee4:	89 f2                	mov    %esi,%edx
  800ee6:	40 38 37             	cmp    %sil,(%rdi)
  800ee9:	74 16                	je     800f01 <memfind+0x26>
  for (; s < ends; s++)
  800eeb:	48 83 c7 01          	add    $0x1,%rdi
  800eef:	48 39 f8             	cmp    %rdi,%rax
  800ef2:	74 08                	je     800efc <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ef4:	38 17                	cmp    %dl,(%rdi)
  800ef6:	75 f3                	jne    800eeb <memfind+0x10>
  for (; s < ends; s++)
  800ef8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800efb:	c3                   	retq   
  800efc:	c3                   	retq   
  for (; s < ends; s++)
  800efd:	48 89 f8             	mov    %rdi,%rax
  800f00:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800f01:	48 89 f8             	mov    %rdi,%rax
  800f04:	c3                   	retq   

0000000000800f05 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f05:	0f b6 07             	movzbl (%rdi),%eax
  800f08:	3c 20                	cmp    $0x20,%al
  800f0a:	74 04                	je     800f10 <strtol+0xb>
  800f0c:	3c 09                	cmp    $0x9,%al
  800f0e:	75 0f                	jne    800f1f <strtol+0x1a>
    s++;
  800f10:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f14:	0f b6 07             	movzbl (%rdi),%eax
  800f17:	3c 20                	cmp    $0x20,%al
  800f19:	74 f5                	je     800f10 <strtol+0xb>
  800f1b:	3c 09                	cmp    $0x9,%al
  800f1d:	74 f1                	je     800f10 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f1f:	3c 2b                	cmp    $0x2b,%al
  800f21:	74 2b                	je     800f4e <strtol+0x49>
  int neg  = 0;
  800f23:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f29:	3c 2d                	cmp    $0x2d,%al
  800f2b:	74 2d                	je     800f5a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f2d:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f33:	75 0f                	jne    800f44 <strtol+0x3f>
  800f35:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f38:	74 2c                	je     800f66 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f3a:	85 d2                	test   %edx,%edx
  800f3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f41:	0f 44 d0             	cmove  %eax,%edx
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f49:	4c 63 d2             	movslq %edx,%r10
  800f4c:	eb 5c                	jmp    800faa <strtol+0xa5>
    s++;
  800f4e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f52:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f58:	eb d3                	jmp    800f2d <strtol+0x28>
    s++, neg = 1;
  800f5a:	48 83 c7 01          	add    $0x1,%rdi
  800f5e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f64:	eb c7                	jmp    800f2d <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f66:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f6a:	74 0f                	je     800f7b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f6c:	85 d2                	test   %edx,%edx
  800f6e:	75 d4                	jne    800f44 <strtol+0x3f>
    s++, base = 8;
  800f70:	48 83 c7 01          	add    $0x1,%rdi
  800f74:	ba 08 00 00 00       	mov    $0x8,%edx
  800f79:	eb c9                	jmp    800f44 <strtol+0x3f>
    s += 2, base = 16;
  800f7b:	48 83 c7 02          	add    $0x2,%rdi
  800f7f:	ba 10 00 00 00       	mov    $0x10,%edx
  800f84:	eb be                	jmp    800f44 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f86:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f8a:	41 80 f8 19          	cmp    $0x19,%r8b
  800f8e:	77 2f                	ja     800fbf <strtol+0xba>
      dig = *s - 'a' + 10;
  800f90:	44 0f be c1          	movsbl %cl,%r8d
  800f94:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f98:	39 d1                	cmp    %edx,%ecx
  800f9a:	7d 37                	jge    800fd3 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f9c:	48 83 c7 01          	add    $0x1,%rdi
  800fa0:	49 0f af c2          	imul   %r10,%rax
  800fa4:	48 63 c9             	movslq %ecx,%rcx
  800fa7:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800faa:	0f b6 0f             	movzbl (%rdi),%ecx
  800fad:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800fb1:	41 80 f8 09          	cmp    $0x9,%r8b
  800fb5:	77 cf                	ja     800f86 <strtol+0x81>
      dig = *s - '0';
  800fb7:	0f be c9             	movsbl %cl,%ecx
  800fba:	83 e9 30             	sub    $0x30,%ecx
  800fbd:	eb d9                	jmp    800f98 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fbf:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fc3:	41 80 f8 19          	cmp    $0x19,%r8b
  800fc7:	77 0a                	ja     800fd3 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fc9:	44 0f be c1          	movsbl %cl,%r8d
  800fcd:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fd1:	eb c5                	jmp    800f98 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fd3:	48 85 f6             	test   %rsi,%rsi
  800fd6:	74 03                	je     800fdb <strtol+0xd6>
    *endptr = (char *)s;
  800fd8:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fdb:	48 89 c2             	mov    %rax,%rdx
  800fde:	48 f7 da             	neg    %rdx
  800fe1:	45 85 c9             	test   %r9d,%r9d
  800fe4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fe8:	c3                   	retq   

0000000000800fe9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fe9:	55                   	push   %rbp
  800fea:	48 89 e5             	mov    %rsp,%rbp
  800fed:	53                   	push   %rbx
  800fee:	48 89 fa             	mov    %rdi,%rdx
  800ff1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff9:	48 89 c3             	mov    %rax,%rbx
  800ffc:	48 89 c7             	mov    %rax,%rdi
  800fff:	48 89 c6             	mov    %rax,%rsi
  801002:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801004:	5b                   	pop    %rbx
  801005:	5d                   	pop    %rbp
  801006:	c3                   	retq   

0000000000801007 <sys_cgetc>:

int
sys_cgetc(void) {
  801007:	55                   	push   %rbp
  801008:	48 89 e5             	mov    %rsp,%rbp
  80100b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80100c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801011:	b8 01 00 00 00       	mov    $0x1,%eax
  801016:	48 89 ca             	mov    %rcx,%rdx
  801019:	48 89 cb             	mov    %rcx,%rbx
  80101c:	48 89 cf             	mov    %rcx,%rdi
  80101f:	48 89 ce             	mov    %rcx,%rsi
  801022:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801024:	5b                   	pop    %rbx
  801025:	5d                   	pop    %rbp
  801026:	c3                   	retq   

0000000000801027 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801027:	55                   	push   %rbp
  801028:	48 89 e5             	mov    %rsp,%rbp
  80102b:	53                   	push   %rbx
  80102c:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801030:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801033:	be 00 00 00 00       	mov    $0x0,%esi
  801038:	b8 03 00 00 00       	mov    $0x3,%eax
  80103d:	48 89 f1             	mov    %rsi,%rcx
  801040:	48 89 f3             	mov    %rsi,%rbx
  801043:	48 89 f7             	mov    %rsi,%rdi
  801046:	cd 30                	int    $0x30
  if (check && ret > 0)
  801048:	48 85 c0             	test   %rax,%rax
  80104b:	7f 07                	jg     801054 <sys_env_destroy+0x2d>
}
  80104d:	48 83 c4 08          	add    $0x8,%rsp
  801051:	5b                   	pop    %rbx
  801052:	5d                   	pop    %rbp
  801053:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801054:	49 89 c0             	mov    %rax,%r8
  801057:	b9 03 00 00 00       	mov    $0x3,%ecx
  80105c:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  801063:	00 00 00 
  801066:	be 22 00 00 00       	mov    $0x22,%esi
  80106b:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  801072:	00 00 00 
  801075:	b8 00 00 00 00       	mov    $0x0,%eax
  80107a:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  801081:	00 00 00 
  801084:	41 ff d1             	callq  *%r9

0000000000801087 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801087:	55                   	push   %rbp
  801088:	48 89 e5             	mov    %rsp,%rbp
  80108b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80108c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801091:	b8 02 00 00 00       	mov    $0x2,%eax
  801096:	48 89 ca             	mov    %rcx,%rdx
  801099:	48 89 cb             	mov    %rcx,%rbx
  80109c:	48 89 cf             	mov    %rcx,%rdi
  80109f:	48 89 ce             	mov    %rcx,%rsi
  8010a2:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010a4:	5b                   	pop    %rbx
  8010a5:	5d                   	pop    %rbp
  8010a6:	c3                   	retq   

00000000008010a7 <sys_yield>:

void
sys_yield(void) {
  8010a7:	55                   	push   %rbp
  8010a8:	48 89 e5             	mov    %rsp,%rbp
  8010ab:	53                   	push   %rbx
  asm volatile("int %1\n"
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010b6:	48 89 ca             	mov    %rcx,%rdx
  8010b9:	48 89 cb             	mov    %rcx,%rbx
  8010bc:	48 89 cf             	mov    %rcx,%rdi
  8010bf:	48 89 ce             	mov    %rcx,%rsi
  8010c2:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010c4:	5b                   	pop    %rbx
  8010c5:	5d                   	pop    %rbp
  8010c6:	c3                   	retq   

00000000008010c7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010c7:	55                   	push   %rbp
  8010c8:	48 89 e5             	mov    %rsp,%rbp
  8010cb:	53                   	push   %rbx
  8010cc:	48 83 ec 08          	sub    $0x8,%rsp
  8010d0:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010d3:	4c 63 c7             	movslq %edi,%r8
  8010d6:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010d9:	be 00 00 00 00       	mov    $0x0,%esi
  8010de:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e3:	4c 89 c2             	mov    %r8,%rdx
  8010e6:	48 89 f7             	mov    %rsi,%rdi
  8010e9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010eb:	48 85 c0             	test   %rax,%rax
  8010ee:	7f 07                	jg     8010f7 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8010f0:	48 83 c4 08          	add    $0x8,%rsp
  8010f4:	5b                   	pop    %rbx
  8010f5:	5d                   	pop    %rbp
  8010f6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010f7:	49 89 c0             	mov    %rax,%r8
  8010fa:	b9 04 00 00 00       	mov    $0x4,%ecx
  8010ff:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  801106:	00 00 00 
  801109:	be 22 00 00 00       	mov    $0x22,%esi
  80110e:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  801115:	00 00 00 
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  801124:	00 00 00 
  801127:	41 ff d1             	callq  *%r9

000000000080112a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80112a:	55                   	push   %rbp
  80112b:	48 89 e5             	mov    %rsp,%rbp
  80112e:	53                   	push   %rbx
  80112f:	48 83 ec 08          	sub    $0x8,%rsp
  801133:	41 89 f9             	mov    %edi,%r9d
  801136:	49 89 f2             	mov    %rsi,%r10
  801139:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80113c:	4d 63 c9             	movslq %r9d,%r9
  80113f:	48 63 da             	movslq %edx,%rbx
  801142:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801145:	b8 05 00 00 00       	mov    $0x5,%eax
  80114a:	4c 89 ca             	mov    %r9,%rdx
  80114d:	4c 89 d1             	mov    %r10,%rcx
  801150:	cd 30                	int    $0x30
  if (check && ret > 0)
  801152:	48 85 c0             	test   %rax,%rax
  801155:	7f 07                	jg     80115e <sys_page_map+0x34>
}
  801157:	48 83 c4 08          	add    $0x8,%rsp
  80115b:	5b                   	pop    %rbx
  80115c:	5d                   	pop    %rbp
  80115d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80115e:	49 89 c0             	mov    %rax,%r8
  801161:	b9 05 00 00 00       	mov    $0x5,%ecx
  801166:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  80116d:	00 00 00 
  801170:	be 22 00 00 00       	mov    $0x22,%esi
  801175:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  80117c:	00 00 00 
  80117f:	b8 00 00 00 00       	mov    $0x0,%eax
  801184:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  80118b:	00 00 00 
  80118e:	41 ff d1             	callq  *%r9

0000000000801191 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801191:	55                   	push   %rbp
  801192:	48 89 e5             	mov    %rsp,%rbp
  801195:	53                   	push   %rbx
  801196:	48 83 ec 08          	sub    $0x8,%rsp
  80119a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  80119d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8011a0:	be 00 00 00 00       	mov    $0x0,%esi
  8011a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8011aa:	48 89 f3             	mov    %rsi,%rbx
  8011ad:	48 89 f7             	mov    %rsi,%rdi
  8011b0:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011b2:	48 85 c0             	test   %rax,%rax
  8011b5:	7f 07                	jg     8011be <sys_page_unmap+0x2d>
}
  8011b7:	48 83 c4 08          	add    $0x8,%rsp
  8011bb:	5b                   	pop    %rbx
  8011bc:	5d                   	pop    %rbp
  8011bd:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011be:	49 89 c0             	mov    %rax,%r8
  8011c1:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011c6:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  8011cd:	00 00 00 
  8011d0:	be 22 00 00 00       	mov    $0x22,%esi
  8011d5:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  8011dc:	00 00 00 
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e4:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  8011eb:	00 00 00 
  8011ee:	41 ff d1             	callq  *%r9

00000000008011f1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8011f1:	55                   	push   %rbp
  8011f2:	48 89 e5             	mov    %rsp,%rbp
  8011f5:	53                   	push   %rbx
  8011f6:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011fa:	48 63 d7             	movslq %edi,%rdx
  8011fd:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801200:	bb 00 00 00 00       	mov    $0x0,%ebx
  801205:	b8 08 00 00 00       	mov    $0x8,%eax
  80120a:	48 89 df             	mov    %rbx,%rdi
  80120d:	48 89 de             	mov    %rbx,%rsi
  801210:	cd 30                	int    $0x30
  if (check && ret > 0)
  801212:	48 85 c0             	test   %rax,%rax
  801215:	7f 07                	jg     80121e <sys_env_set_status+0x2d>
}
  801217:	48 83 c4 08          	add    $0x8,%rsp
  80121b:	5b                   	pop    %rbx
  80121c:	5d                   	pop    %rbp
  80121d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80121e:	49 89 c0             	mov    %rax,%r8
  801221:	b9 08 00 00 00       	mov    $0x8,%ecx
  801226:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  80122d:	00 00 00 
  801230:	be 22 00 00 00       	mov    $0x22,%esi
  801235:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  80123c:	00 00 00 
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  80124b:	00 00 00 
  80124e:	41 ff d1             	callq  *%r9

0000000000801251 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801251:	55                   	push   %rbp
  801252:	48 89 e5             	mov    %rsp,%rbp
  801255:	53                   	push   %rbx
  801256:	48 83 ec 08          	sub    $0x8,%rsp
  80125a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80125d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801260:	be 00 00 00 00       	mov    $0x0,%esi
  801265:	b8 09 00 00 00       	mov    $0x9,%eax
  80126a:	48 89 f3             	mov    %rsi,%rbx
  80126d:	48 89 f7             	mov    %rsi,%rdi
  801270:	cd 30                	int    $0x30
  if (check && ret > 0)
  801272:	48 85 c0             	test   %rax,%rax
  801275:	7f 07                	jg     80127e <sys_env_set_pgfault_upcall+0x2d>
}
  801277:	48 83 c4 08          	add    $0x8,%rsp
  80127b:	5b                   	pop    %rbx
  80127c:	5d                   	pop    %rbp
  80127d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80127e:	49 89 c0             	mov    %rax,%r8
  801281:	b9 09 00 00 00       	mov    $0x9,%ecx
  801286:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  80128d:	00 00 00 
  801290:	be 22 00 00 00       	mov    $0x22,%esi
  801295:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  80129c:	00 00 00 
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  8012ab:	00 00 00 
  8012ae:	41 ff d1             	callq  *%r9

00000000008012b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8012b1:	55                   	push   %rbp
  8012b2:	48 89 e5             	mov    %rsp,%rbp
  8012b5:	53                   	push   %rbx
  8012b6:	49 89 f0             	mov    %rsi,%r8
  8012b9:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8012bc:	48 63 d7             	movslq %edi,%rdx
  8012bf:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8012c2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012c7:	be 00 00 00 00       	mov    $0x0,%esi
  8012cc:	4c 89 c1             	mov    %r8,%rcx
  8012cf:	cd 30                	int    $0x30
}
  8012d1:	5b                   	pop    %rbx
  8012d2:	5d                   	pop    %rbp
  8012d3:	c3                   	retq   

00000000008012d4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012d4:	55                   	push   %rbp
  8012d5:	48 89 e5             	mov    %rsp,%rbp
  8012d8:	53                   	push   %rbx
  8012d9:	48 83 ec 08          	sub    $0x8,%rsp
  8012dd:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012e0:	be 00 00 00 00       	mov    $0x0,%esi
  8012e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012ea:	48 89 f1             	mov    %rsi,%rcx
  8012ed:	48 89 f3             	mov    %rsi,%rbx
  8012f0:	48 89 f7             	mov    %rsi,%rdi
  8012f3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012f5:	48 85 c0             	test   %rax,%rax
  8012f8:	7f 07                	jg     801301 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8012fa:	48 83 c4 08          	add    $0x8,%rsp
  8012fe:	5b                   	pop    %rbx
  8012ff:	5d                   	pop    %rbp
  801300:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801301:	49 89 c0             	mov    %rax,%r8
  801304:	b9 0c 00 00 00       	mov    $0xc,%ecx
  801309:	48 ba 60 18 80 00 00 	movabs $0x801860,%rdx
  801310:	00 00 00 
  801313:	be 22 00 00 00       	mov    $0x22,%esi
  801318:	48 bf 7f 18 80 00 00 	movabs $0x80187f,%rdi
  80131f:	00 00 00 
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	49 b9 34 13 80 00 00 	movabs $0x801334,%r9
  80132e:	00 00 00 
  801331:	41 ff d1             	callq  *%r9

0000000000801334 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801334:	55                   	push   %rbp
  801335:	48 89 e5             	mov    %rsp,%rbp
  801338:	41 56                	push   %r14
  80133a:	41 55                	push   %r13
  80133c:	41 54                	push   %r12
  80133e:	53                   	push   %rbx
  80133f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801346:	49 89 fd             	mov    %rdi,%r13
  801349:	41 89 f6             	mov    %esi,%r14d
  80134c:	49 89 d4             	mov    %rdx,%r12
  80134f:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801356:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80135d:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801364:	84 c0                	test   %al,%al
  801366:	74 26                	je     80138e <_panic+0x5a>
  801368:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80136f:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801376:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80137a:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80137e:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  801382:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801386:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80138a:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80138e:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801395:	00 00 00 
  801398:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80139f:	00 00 00 
  8013a2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8013a6:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8013ad:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8013b4:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8013bb:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8013c2:	00 00 00 
  8013c5:	48 8b 18             	mov    (%rax),%rbx
  8013c8:	48 b8 87 10 80 00 00 	movabs $0x801087,%rax
  8013cf:	00 00 00 
  8013d2:	ff d0                	callq  *%rax
  8013d4:	45 89 f0             	mov    %r14d,%r8d
  8013d7:	4c 89 e9             	mov    %r13,%rcx
  8013da:	48 89 da             	mov    %rbx,%rdx
  8013dd:	89 c6                	mov    %eax,%esi
  8013df:	48 bf 90 18 80 00 00 	movabs $0x801890,%rdi
  8013e6:	00 00 00 
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ee:	48 bb f5 01 80 00 00 	movabs $0x8001f5,%rbx
  8013f5:	00 00 00 
  8013f8:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8013fa:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801401:	4c 89 e7             	mov    %r12,%rdi
  801404:	48 b8 8d 01 80 00 00 	movabs $0x80018d,%rax
  80140b:	00 00 00 
  80140e:	ff d0                	callq  *%rax
  cprintf("\n");
  801410:	48 bf 4c 14 80 00 00 	movabs $0x80144c,%rdi
  801417:	00 00 00 
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801421:	cc                   	int3   
  while (1)
  801422:	eb fd                	jmp    801421 <_panic+0xed>
