
obj/user/signedoverflow:     file format elf64-x86-64


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
  800023:	e8 28 00 00 00       	callq  800050 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
//Test for UBSAN support - signed integer overflow

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  //Creating a 32-bit integer variable with the maximum integer value it can contain
  int a = 2147483647;
  //Trying to add 1 to the "a" variable and print its contents (which causes undefined behavior).
  //The "cprintf" function is sanitized by UBSAN because lib/Makefrag accesses the USER_SAN_CFLAGS variable.
  cprintf("%d\n", a + 1);
  80002e:	be 00 00 00 80       	mov    $0x80000000,%esi
  800033:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  80003a:	00 00 00 
  80003d:	b8 00 00 00 00       	mov    $0x0,%eax
  800042:	48 ba d3 01 80 00 00 	movabs $0x8001d3,%rdx
  800049:	00 00 00 
  80004c:	ff d2                	callq  *%rdx
}
  80004e:	5d                   	pop    %rbp
  80004f:	c3                   	retq   

0000000000800050 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800050:	55                   	push   %rbp
  800051:	48 89 e5             	mov    %rsp,%rbp
  800054:	41 56                	push   %r14
  800056:	41 55                	push   %r13
  800058:	41 54                	push   %r12
  80005a:	53                   	push   %rbx
  80005b:	41 89 fd             	mov    %edi,%r13d
  80005e:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800061:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800068:	00 00 00 
  80006b:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800072:	00 00 00 
  800075:	48 39 c2             	cmp    %rax,%rdx
  800078:	73 23                	jae    80009d <libmain+0x4d>
  80007a:	48 89 d3             	mov    %rdx,%rbx
  80007d:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800081:	48 29 d0             	sub    %rdx,%rax
  800084:	48 c1 e8 03          	shr    $0x3,%rax
  800088:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
  800092:	ff 13                	callq  *(%rbx)
    ctor++;
  800094:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800098:	4c 39 e3             	cmp    %r12,%rbx
  80009b:	75 f0                	jne    80008d <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  80009d:	48 b8 65 10 80 00 00 	movabs $0x801065,%rax
  8000a4:	00 00 00 
  8000a7:	ff d0                	callq  *%rax
  8000a9:	83 e0 1f             	and    $0x1f,%eax
  8000ac:	48 89 c2             	mov    %rax,%rdx
  8000af:	48 c1 e2 05          	shl    $0x5,%rdx
  8000b3:	48 29 c2             	sub    %rax,%rdx
  8000b6:	48 89 d0             	mov    %rdx,%rax
  8000b9:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000c0:	00 00 00 
  8000c3:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000c7:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000ce:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000d1:	45 85 ed             	test   %r13d,%r13d
  8000d4:	7e 0d                	jle    8000e3 <libmain+0x93>
    binaryname = argv[0];
  8000d6:	49 8b 06             	mov    (%r14),%rax
  8000d9:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000e0:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e3:	4c 89 f6             	mov    %r14,%rsi
  8000e6:	44 89 ef             	mov    %r13d,%edi
  8000e9:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f0:	00 00 00 
  8000f3:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f5:	48 b8 0a 01 80 00 00 	movabs $0x80010a,%rax
  8000fc:	00 00 00 
  8000ff:	ff d0                	callq  *%rax
#endif
}
  800101:	5b                   	pop    %rbx
  800102:	41 5c                	pop    %r12
  800104:	41 5d                	pop    %r13
  800106:	41 5e                	pop    %r14
  800108:	5d                   	pop    %rbp
  800109:	c3                   	retq   

000000000080010a <exit>:

#include <inc/lib.h>

void
exit(void) {
  80010a:	55                   	push   %rbp
  80010b:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80010e:	bf 00 00 00 00       	mov    $0x0,%edi
  800113:	48 b8 05 10 80 00 00 	movabs $0x801005,%rax
  80011a:	00 00 00 
  80011d:	ff d0                	callq  *%rax
}
  80011f:	5d                   	pop    %rbp
  800120:	c3                   	retq   

0000000000800121 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800121:	55                   	push   %rbp
  800122:	48 89 e5             	mov    %rsp,%rbp
  800125:	53                   	push   %rbx
  800126:	48 83 ec 08          	sub    $0x8,%rsp
  80012a:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80012d:	8b 06                	mov    (%rsi),%eax
  80012f:	8d 50 01             	lea    0x1(%rax),%edx
  800132:	89 16                	mov    %edx,(%rsi)
  800134:	48 98                	cltq   
  800136:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80013b:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800141:	74 0b                	je     80014e <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800143:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800147:	48 83 c4 08          	add    $0x8,%rsp
  80014b:	5b                   	pop    %rbx
  80014c:	5d                   	pop    %rbp
  80014d:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80014e:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800152:	be ff 00 00 00       	mov    $0xff,%esi
  800157:	48 b8 c7 0f 80 00 00 	movabs $0x800fc7,%rax
  80015e:	00 00 00 
  800161:	ff d0                	callq  *%rax
    b->idx = 0;
  800163:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800169:	eb d8                	jmp    800143 <putch+0x22>

000000000080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80016b:	55                   	push   %rbp
  80016c:	48 89 e5             	mov    %rsp,%rbp
  80016f:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800176:	48 89 fa             	mov    %rdi,%rdx
  800179:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80017c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800183:	00 00 00 
  b.cnt = 0;
  800186:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80018d:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800190:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800197:	48 bf 21 01 80 00 00 	movabs $0x800121,%rdi
  80019e:	00 00 00 
  8001a1:	48 b8 91 03 80 00 00 	movabs $0x800391,%rax
  8001a8:	00 00 00 
  8001ab:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001ad:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001b4:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001bb:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001bf:	48 b8 c7 0f 80 00 00 	movabs $0x800fc7,%rax
  8001c6:	00 00 00 
  8001c9:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001d1:	c9                   	leaveq 
  8001d2:	c3                   	retq   

00000000008001d3 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001d3:	55                   	push   %rbp
  8001d4:	48 89 e5             	mov    %rsp,%rbp
  8001d7:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001de:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001e5:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001ec:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001f3:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001fa:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800201:	84 c0                	test   %al,%al
  800203:	74 20                	je     800225 <cprintf+0x52>
  800205:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800209:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80020d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800211:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800215:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800219:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80021d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800221:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800225:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80022c:	00 00 00 
  80022f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800236:	00 00 00 
  800239:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80023d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800244:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80024b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800252:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800259:	48 b8 6b 01 80 00 00 	movabs $0x80016b,%rax
  800260:	00 00 00 
  800263:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800265:	c9                   	leaveq 
  800266:	c3                   	retq   

0000000000800267 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800267:	55                   	push   %rbp
  800268:	48 89 e5             	mov    %rsp,%rbp
  80026b:	41 57                	push   %r15
  80026d:	41 56                	push   %r14
  80026f:	41 55                	push   %r13
  800271:	41 54                	push   %r12
  800273:	53                   	push   %rbx
  800274:	48 83 ec 18          	sub    $0x18,%rsp
  800278:	49 89 fc             	mov    %rdi,%r12
  80027b:	49 89 f5             	mov    %rsi,%r13
  80027e:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800282:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800285:	41 89 cf             	mov    %ecx,%r15d
  800288:	49 39 d7             	cmp    %rdx,%r15
  80028b:	76 45                	jbe    8002d2 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80028d:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800291:	85 db                	test   %ebx,%ebx
  800293:	7e 0e                	jle    8002a3 <printnum+0x3c>
      putch(padc, putdat);
  800295:	4c 89 ee             	mov    %r13,%rsi
  800298:	44 89 f7             	mov    %r14d,%edi
  80029b:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80029e:	83 eb 01             	sub    $0x1,%ebx
  8002a1:	75 f2                	jne    800295 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002a3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ac:	49 f7 f7             	div    %r15
  8002af:	48 b8 8e 11 80 00 00 	movabs $0x80118e,%rax
  8002b6:	00 00 00 
  8002b9:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002bd:	4c 89 ee             	mov    %r13,%rsi
  8002c0:	41 ff d4             	callq  *%r12
}
  8002c3:	48 83 c4 18          	add    $0x18,%rsp
  8002c7:	5b                   	pop    %rbx
  8002c8:	41 5c                	pop    %r12
  8002ca:	41 5d                	pop    %r13
  8002cc:	41 5e                	pop    %r14
  8002ce:	41 5f                	pop    %r15
  8002d0:	5d                   	pop    %rbp
  8002d1:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002db:	49 f7 f7             	div    %r15
  8002de:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002e2:	48 89 c2             	mov    %rax,%rdx
  8002e5:	48 b8 67 02 80 00 00 	movabs $0x800267,%rax
  8002ec:	00 00 00 
  8002ef:	ff d0                	callq  *%rax
  8002f1:	eb b0                	jmp    8002a3 <printnum+0x3c>

00000000008002f3 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002f3:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002f7:	48 8b 06             	mov    (%rsi),%rax
  8002fa:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002fe:	73 0a                	jae    80030a <sprintputch+0x17>
    *b->buf++ = ch;
  800300:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800304:	48 89 16             	mov    %rdx,(%rsi)
  800307:	40 88 38             	mov    %dil,(%rax)
}
  80030a:	c3                   	retq   

000000000080030b <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80030b:	55                   	push   %rbp
  80030c:	48 89 e5             	mov    %rsp,%rbp
  80030f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800316:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80031d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800324:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80032b:	84 c0                	test   %al,%al
  80032d:	74 20                	je     80034f <printfmt+0x44>
  80032f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800333:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800337:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80033b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80033f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800343:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800347:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80034b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80034f:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800356:	00 00 00 
  800359:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800360:	00 00 00 
  800363:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800367:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80036e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800375:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80037c:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800383:	48 b8 91 03 80 00 00 	movabs $0x800391,%rax
  80038a:	00 00 00 
  80038d:	ff d0                	callq  *%rax
}
  80038f:	c9                   	leaveq 
  800390:	c3                   	retq   

0000000000800391 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800391:	55                   	push   %rbp
  800392:	48 89 e5             	mov    %rsp,%rbp
  800395:	41 57                	push   %r15
  800397:	41 56                	push   %r14
  800399:	41 55                	push   %r13
  80039b:	41 54                	push   %r12
  80039d:	53                   	push   %rbx
  80039e:	48 83 ec 48          	sub    $0x48,%rsp
  8003a2:	49 89 fd             	mov    %rdi,%r13
  8003a5:	49 89 f7             	mov    %rsi,%r15
  8003a8:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003ab:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003af:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003b3:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003b7:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003bb:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003bf:	41 0f b6 3e          	movzbl (%r14),%edi
  8003c3:	83 ff 25             	cmp    $0x25,%edi
  8003c6:	74 18                	je     8003e0 <vprintfmt+0x4f>
      if (ch == '\0')
  8003c8:	85 ff                	test   %edi,%edi
  8003ca:	0f 84 8c 06 00 00    	je     800a5c <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003d0:	4c 89 fe             	mov    %r15,%rsi
  8003d3:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003d6:	49 89 de             	mov    %rbx,%r14
  8003d9:	eb e0                	jmp    8003bb <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003db:	49 89 de             	mov    %rbx,%r14
  8003de:	eb db                	jmp    8003bb <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003e0:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003e4:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003e8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003ef:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003f5:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003fe:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800404:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80040a:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80040f:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800414:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800418:	0f b6 13             	movzbl (%rbx),%edx
  80041b:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80041e:	3c 55                	cmp    $0x55,%al
  800420:	0f 87 8b 05 00 00    	ja     8009b1 <vprintfmt+0x620>
  800426:	0f b6 c0             	movzbl %al,%eax
  800429:	49 bb 40 12 80 00 00 	movabs $0x801240,%r11
  800430:	00 00 00 
  800433:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800437:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80043a:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80043e:	eb d4                	jmp    800414 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800440:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800443:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800447:	eb cb                	jmp    800414 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800449:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80044c:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800450:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800454:	8d 50 d0             	lea    -0x30(%rax),%edx
  800457:	83 fa 09             	cmp    $0x9,%edx
  80045a:	77 7e                	ja     8004da <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80045c:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800460:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800464:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800469:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80046d:	8d 50 d0             	lea    -0x30(%rax),%edx
  800470:	83 fa 09             	cmp    $0x9,%edx
  800473:	76 e7                	jbe    80045c <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800475:	4c 89 f3             	mov    %r14,%rbx
  800478:	eb 19                	jmp    800493 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80047a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80047d:	83 f8 2f             	cmp    $0x2f,%eax
  800480:	77 2a                	ja     8004ac <vprintfmt+0x11b>
  800482:	89 c2                	mov    %eax,%edx
  800484:	4c 01 d2             	add    %r10,%rdx
  800487:	83 c0 08             	add    $0x8,%eax
  80048a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80048d:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800490:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800493:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800497:	0f 89 77 ff ff ff    	jns    800414 <vprintfmt+0x83>
          width = precision, precision = -1;
  80049d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004a1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004a7:	e9 68 ff ff ff       	jmpq   800414 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004ac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004b0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004b4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004b8:	eb d3                	jmp    80048d <vprintfmt+0xfc>
        if (width < 0)
  8004ba:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004c3:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004c6:	4c 89 f3             	mov    %r14,%rbx
  8004c9:	e9 46 ff ff ff       	jmpq   800414 <vprintfmt+0x83>
  8004ce:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004d1:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004d5:	e9 3a ff ff ff       	jmpq   800414 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004da:	4c 89 f3             	mov    %r14,%rbx
  8004dd:	eb b4                	jmp    800493 <vprintfmt+0x102>
        lflag++;
  8004df:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004e2:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004e5:	e9 2a ff ff ff       	jmpq   800414 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004ea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004ed:	83 f8 2f             	cmp    $0x2f,%eax
  8004f0:	77 19                	ja     80050b <vprintfmt+0x17a>
  8004f2:	89 c2                	mov    %eax,%edx
  8004f4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004f8:	83 c0 08             	add    $0x8,%eax
  8004fb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004fe:	4c 89 fe             	mov    %r15,%rsi
  800501:	8b 3a                	mov    (%rdx),%edi
  800503:	41 ff d5             	callq  *%r13
        break;
  800506:	e9 b0 fe ff ff       	jmpq   8003bb <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80050b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80050f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800513:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800517:	eb e5                	jmp    8004fe <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800519:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80051c:	83 f8 2f             	cmp    $0x2f,%eax
  80051f:	77 5b                	ja     80057c <vprintfmt+0x1eb>
  800521:	89 c2                	mov    %eax,%edx
  800523:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800527:	83 c0 08             	add    $0x8,%eax
  80052a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80052d:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80052f:	89 c8                	mov    %ecx,%eax
  800531:	c1 f8 1f             	sar    $0x1f,%eax
  800534:	31 c1                	xor    %eax,%ecx
  800536:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800538:	83 f9 09             	cmp    $0x9,%ecx
  80053b:	7f 4d                	jg     80058a <vprintfmt+0x1f9>
  80053d:	48 63 c1             	movslq %ecx,%rax
  800540:	48 ba 00 15 80 00 00 	movabs $0x801500,%rdx
  800547:	00 00 00 
  80054a:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80054e:	48 85 c0             	test   %rax,%rax
  800551:	74 37                	je     80058a <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800553:	48 89 c1             	mov    %rax,%rcx
  800556:	48 ba af 11 80 00 00 	movabs $0x8011af,%rdx
  80055d:	00 00 00 
  800560:	4c 89 fe             	mov    %r15,%rsi
  800563:	4c 89 ef             	mov    %r13,%rdi
  800566:	b8 00 00 00 00       	mov    $0x0,%eax
  80056b:	48 bb 0b 03 80 00 00 	movabs $0x80030b,%rbx
  800572:	00 00 00 
  800575:	ff d3                	callq  *%rbx
  800577:	e9 3f fe ff ff       	jmpq   8003bb <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80057c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800580:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800584:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800588:	eb a3                	jmp    80052d <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80058a:	48 ba a6 11 80 00 00 	movabs $0x8011a6,%rdx
  800591:	00 00 00 
  800594:	4c 89 fe             	mov    %r15,%rsi
  800597:	4c 89 ef             	mov    %r13,%rdi
  80059a:	b8 00 00 00 00       	mov    $0x0,%eax
  80059f:	48 bb 0b 03 80 00 00 	movabs $0x80030b,%rbx
  8005a6:	00 00 00 
  8005a9:	ff d3                	callq  *%rbx
  8005ab:	e9 0b fe ff ff       	jmpq   8003bb <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005b0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005b3:	83 f8 2f             	cmp    $0x2f,%eax
  8005b6:	77 4b                	ja     800603 <vprintfmt+0x272>
  8005b8:	89 c2                	mov    %eax,%edx
  8005ba:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005be:	83 c0 08             	add    $0x8,%eax
  8005c1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005c4:	48 8b 02             	mov    (%rdx),%rax
  8005c7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005cb:	48 85 c0             	test   %rax,%rax
  8005ce:	0f 84 05 04 00 00    	je     8009d9 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005d4:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005d8:	7e 06                	jle    8005e0 <vprintfmt+0x24f>
  8005da:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005de:	75 31                	jne    800611 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e0:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005e4:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005e8:	0f b6 00             	movzbl (%rax),%eax
  8005eb:	0f be f8             	movsbl %al,%edi
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	0f 84 c3 00 00 00    	je     8006b9 <vprintfmt+0x328>
  8005f6:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005fa:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005fe:	e9 85 00 00 00       	jmpq   800688 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800603:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800607:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80060b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80060f:	eb b3                	jmp    8005c4 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800611:	49 63 f4             	movslq %r12d,%rsi
  800614:	48 89 c7             	mov    %rax,%rdi
  800617:	48 b8 68 0b 80 00 00 	movabs $0x800b68,%rax
  80061e:	00 00 00 
  800621:	ff d0                	callq  *%rax
  800623:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800626:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800629:	85 f6                	test   %esi,%esi
  80062b:	7e 22                	jle    80064f <vprintfmt+0x2be>
            putch(padc, putdat);
  80062d:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800631:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800635:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800639:	4c 89 fe             	mov    %r15,%rsi
  80063c:	89 df                	mov    %ebx,%edi
  80063e:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800641:	41 83 ec 01          	sub    $0x1,%r12d
  800645:	75 f2                	jne    800639 <vprintfmt+0x2a8>
  800647:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80064b:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800653:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800657:	0f b6 00             	movzbl (%rax),%eax
  80065a:	0f be f8             	movsbl %al,%edi
  80065d:	85 ff                	test   %edi,%edi
  80065f:	0f 84 56 fd ff ff    	je     8003bb <vprintfmt+0x2a>
  800665:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800669:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80066d:	eb 19                	jmp    800688 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80066f:	4c 89 fe             	mov    %r15,%rsi
  800672:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	41 83 ee 01          	sub    $0x1,%r14d
  800679:	48 83 c3 01          	add    $0x1,%rbx
  80067d:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800681:	0f be f8             	movsbl %al,%edi
  800684:	85 ff                	test   %edi,%edi
  800686:	74 29                	je     8006b1 <vprintfmt+0x320>
  800688:	45 85 e4             	test   %r12d,%r12d
  80068b:	78 06                	js     800693 <vprintfmt+0x302>
  80068d:	41 83 ec 01          	sub    $0x1,%r12d
  800691:	78 48                	js     8006db <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800693:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800697:	74 d6                	je     80066f <vprintfmt+0x2de>
  800699:	0f be c0             	movsbl %al,%eax
  80069c:	83 e8 20             	sub    $0x20,%eax
  80069f:	83 f8 5e             	cmp    $0x5e,%eax
  8006a2:	76 cb                	jbe    80066f <vprintfmt+0x2de>
            putch('?', putdat);
  8006a4:	4c 89 fe             	mov    %r15,%rsi
  8006a7:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006ac:	41 ff d5             	callq  *%r13
  8006af:	eb c4                	jmp    800675 <vprintfmt+0x2e4>
  8006b1:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006b5:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006b9:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006bc:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006c0:	0f 8e f5 fc ff ff    	jle    8003bb <vprintfmt+0x2a>
          putch(' ', putdat);
  8006c6:	4c 89 fe             	mov    %r15,%rsi
  8006c9:	bf 20 00 00 00       	mov    $0x20,%edi
  8006ce:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006d1:	83 eb 01             	sub    $0x1,%ebx
  8006d4:	75 f0                	jne    8006c6 <vprintfmt+0x335>
  8006d6:	e9 e0 fc ff ff       	jmpq   8003bb <vprintfmt+0x2a>
  8006db:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006df:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006e3:	eb d4                	jmp    8006b9 <vprintfmt+0x328>
  if (lflag >= 2)
  8006e5:	83 f9 01             	cmp    $0x1,%ecx
  8006e8:	7f 1d                	jg     800707 <vprintfmt+0x376>
  else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	74 5e                	je     80074c <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006ee:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006f1:	83 f8 2f             	cmp    $0x2f,%eax
  8006f4:	77 48                	ja     80073e <vprintfmt+0x3ad>
  8006f6:	89 c2                	mov    %eax,%edx
  8006f8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006fc:	83 c0 08             	add    $0x8,%eax
  8006ff:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800702:	48 8b 1a             	mov    (%rdx),%rbx
  800705:	eb 17                	jmp    80071e <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800707:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80070a:	83 f8 2f             	cmp    $0x2f,%eax
  80070d:	77 21                	ja     800730 <vprintfmt+0x39f>
  80070f:	89 c2                	mov    %eax,%edx
  800711:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800715:	83 c0 08             	add    $0x8,%eax
  800718:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80071b:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80071e:	48 85 db             	test   %rbx,%rbx
  800721:	78 50                	js     800773 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800723:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800726:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072b:	e9 b4 01 00 00       	jmpq   8008e4 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800730:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800734:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800738:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073c:	eb dd                	jmp    80071b <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80073e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800742:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800746:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074a:	eb b6                	jmp    800702 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80074c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80074f:	83 f8 2f             	cmp    $0x2f,%eax
  800752:	77 11                	ja     800765 <vprintfmt+0x3d4>
  800754:	89 c2                	mov    %eax,%edx
  800756:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80075a:	83 c0 08             	add    $0x8,%eax
  80075d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800760:	48 63 1a             	movslq (%rdx),%rbx
  800763:	eb b9                	jmp    80071e <vprintfmt+0x38d>
  800765:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800769:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80076d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800771:	eb ed                	jmp    800760 <vprintfmt+0x3cf>
          putch('-', putdat);
  800773:	4c 89 fe             	mov    %r15,%rsi
  800776:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80077b:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80077e:	48 89 da             	mov    %rbx,%rdx
  800781:	48 f7 da             	neg    %rdx
        base = 10;
  800784:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800789:	e9 56 01 00 00       	jmpq   8008e4 <vprintfmt+0x553>
  if (lflag >= 2)
  80078e:	83 f9 01             	cmp    $0x1,%ecx
  800791:	7f 25                	jg     8007b8 <vprintfmt+0x427>
  else if (lflag)
  800793:	85 c9                	test   %ecx,%ecx
  800795:	74 5e                	je     8007f5 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800797:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80079a:	83 f8 2f             	cmp    $0x2f,%eax
  80079d:	77 48                	ja     8007e7 <vprintfmt+0x456>
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a5:	83 c0 08             	add    $0x8,%eax
  8007a8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ab:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b3:	e9 2c 01 00 00       	jmpq   8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007b8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007bb:	83 f8 2f             	cmp    $0x2f,%eax
  8007be:	77 19                	ja     8007d9 <vprintfmt+0x448>
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007c6:	83 c0 08             	add    $0x8,%eax
  8007c9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007cc:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d4:	e9 0b 01 00 00       	jmpq   8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e5:	eb e5                	jmp    8007cc <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007e7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007eb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ef:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f3:	eb b6                	jmp    8007ab <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007f5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007f8:	83 f8 2f             	cmp    $0x2f,%eax
  8007fb:	77 18                	ja     800815 <vprintfmt+0x484>
  8007fd:	89 c2                	mov    %eax,%edx
  8007ff:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800803:	83 c0 08             	add    $0x8,%eax
  800806:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800809:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800810:	e9 cf 00 00 00       	jmpq   8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800815:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800819:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80081d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800821:	eb e6                	jmp    800809 <vprintfmt+0x478>
  if (lflag >= 2)
  800823:	83 f9 01             	cmp    $0x1,%ecx
  800826:	7f 25                	jg     80084d <vprintfmt+0x4bc>
  else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 5b                	je     800887 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80082c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80082f:	83 f8 2f             	cmp    $0x2f,%eax
  800832:	77 45                	ja     800879 <vprintfmt+0x4e8>
  800834:	89 c2                	mov    %eax,%edx
  800836:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80083a:	83 c0 08             	add    $0x8,%eax
  80083d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800840:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800843:	b9 08 00 00 00       	mov    $0x8,%ecx
  800848:	e9 97 00 00 00       	jmpq   8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80084d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800850:	83 f8 2f             	cmp    $0x2f,%eax
  800853:	77 16                	ja     80086b <vprintfmt+0x4da>
  800855:	89 c2                	mov    %eax,%edx
  800857:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80085b:	83 c0 08             	add    $0x8,%eax
  80085e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800861:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800864:	b9 08 00 00 00       	mov    $0x8,%ecx
  800869:	eb 79                	jmp    8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80086b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80086f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800873:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800877:	eb e8                	jmp    800861 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800879:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800881:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800885:	eb b9                	jmp    800840 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800887:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80088a:	83 f8 2f             	cmp    $0x2f,%eax
  80088d:	77 15                	ja     8008a4 <vprintfmt+0x513>
  80088f:	89 c2                	mov    %eax,%edx
  800891:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800895:	83 c0 08             	add    $0x8,%eax
  800898:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80089b:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80089d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008a2:	eb 40                	jmp    8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008a4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b0:	eb e9                	jmp    80089b <vprintfmt+0x50a>
        putch('0', putdat);
  8008b2:	4c 89 fe             	mov    %r15,%rsi
  8008b5:	bf 30 00 00 00       	mov    $0x30,%edi
  8008ba:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008bd:	4c 89 fe             	mov    %r15,%rsi
  8008c0:	bf 78 00 00 00       	mov    $0x78,%edi
  8008c5:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008cb:	83 f8 2f             	cmp    $0x2f,%eax
  8008ce:	77 34                	ja     800904 <vprintfmt+0x573>
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d6:	83 c0 08             	add    $0x8,%eax
  8008d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008dc:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008df:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008e4:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008e9:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008ed:	4c 89 fe             	mov    %r15,%rsi
  8008f0:	4c 89 ef             	mov    %r13,%rdi
  8008f3:	48 b8 67 02 80 00 00 	movabs $0x800267,%rax
  8008fa:	00 00 00 
  8008fd:	ff d0                	callq  *%rax
        break;
  8008ff:	e9 b7 fa ff ff       	jmpq   8003bb <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800904:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800908:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80090c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800910:	eb ca                	jmp    8008dc <vprintfmt+0x54b>
  if (lflag >= 2)
  800912:	83 f9 01             	cmp    $0x1,%ecx
  800915:	7f 22                	jg     800939 <vprintfmt+0x5a8>
  else if (lflag)
  800917:	85 c9                	test   %ecx,%ecx
  800919:	74 58                	je     800973 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80091b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091e:	83 f8 2f             	cmp    $0x2f,%eax
  800921:	77 42                	ja     800965 <vprintfmt+0x5d4>
  800923:	89 c2                	mov    %eax,%edx
  800925:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800929:	83 c0 08             	add    $0x8,%eax
  80092c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800932:	b9 10 00 00 00       	mov    $0x10,%ecx
  800937:	eb ab                	jmp    8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800939:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093c:	83 f8 2f             	cmp    $0x2f,%eax
  80093f:	77 16                	ja     800957 <vprintfmt+0x5c6>
  800941:	89 c2                	mov    %eax,%edx
  800943:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800947:	83 c0 08             	add    $0x8,%eax
  80094a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800950:	b9 10 00 00 00       	mov    $0x10,%ecx
  800955:	eb 8d                	jmp    8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800957:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80095f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800963:	eb e8                	jmp    80094d <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800965:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800969:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800971:	eb bc                	jmp    80092f <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800973:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800976:	83 f8 2f             	cmp    $0x2f,%eax
  800979:	77 18                	ja     800993 <vprintfmt+0x602>
  80097b:	89 c2                	mov    %eax,%edx
  80097d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800981:	83 c0 08             	add    $0x8,%eax
  800984:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800987:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800989:	b9 10 00 00 00       	mov    $0x10,%ecx
  80098e:	e9 51 ff ff ff       	jmpq   8008e4 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800993:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800997:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099f:	eb e6                	jmp    800987 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009a1:	4c 89 fe             	mov    %r15,%rsi
  8009a4:	bf 25 00 00 00       	mov    $0x25,%edi
  8009a9:	41 ff d5             	callq  *%r13
        break;
  8009ac:	e9 0a fa ff ff       	jmpq   8003bb <vprintfmt+0x2a>
        putch('%', putdat);
  8009b1:	4c 89 fe             	mov    %r15,%rsi
  8009b4:	bf 25 00 00 00       	mov    $0x25,%edi
  8009b9:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009bc:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009c0:	0f 84 15 fa ff ff    	je     8003db <vprintfmt+0x4a>
  8009c6:	49 89 de             	mov    %rbx,%r14
  8009c9:	49 83 ee 01          	sub    $0x1,%r14
  8009cd:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009d2:	75 f5                	jne    8009c9 <vprintfmt+0x638>
  8009d4:	e9 e2 f9 ff ff       	jmpq   8003bb <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009d9:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009dd:	74 06                	je     8009e5 <vprintfmt+0x654>
  8009df:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009e3:	7f 21                	jg     800a06 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e5:	bf 28 00 00 00       	mov    $0x28,%edi
  8009ea:	48 bb a0 11 80 00 00 	movabs $0x8011a0,%rbx
  8009f1:	00 00 00 
  8009f4:	b8 28 00 00 00       	mov    $0x28,%eax
  8009f9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009fd:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a01:	e9 82 fc ff ff       	jmpq   800688 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a06:	49 63 f4             	movslq %r12d,%rsi
  800a09:	48 bf 9f 11 80 00 00 	movabs $0x80119f,%rdi
  800a10:	00 00 00 
  800a13:	48 b8 68 0b 80 00 00 	movabs $0x800b68,%rax
  800a1a:	00 00 00 
  800a1d:	ff d0                	callq  *%rax
  800a1f:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a22:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a25:	48 be 9f 11 80 00 00 	movabs $0x80119f,%rsi
  800a2c:	00 00 00 
  800a2f:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	85 c0                	test   %eax,%eax
  800a35:	0f 8f f2 fb ff ff    	jg     80062d <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3b:	48 bb a0 11 80 00 00 	movabs $0x8011a0,%rbx
  800a42:	00 00 00 
  800a45:	b8 28 00 00 00       	mov    $0x28,%eax
  800a4a:	bf 28 00 00 00       	mov    $0x28,%edi
  800a4f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a53:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a57:	e9 2c fc ff ff       	jmpq   800688 <vprintfmt+0x2f7>
}
  800a5c:	48 83 c4 48          	add    $0x48,%rsp
  800a60:	5b                   	pop    %rbx
  800a61:	41 5c                	pop    %r12
  800a63:	41 5d                	pop    %r13
  800a65:	41 5e                	pop    %r14
  800a67:	41 5f                	pop    %r15
  800a69:	5d                   	pop    %rbp
  800a6a:	c3                   	retq   

0000000000800a6b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a6b:	55                   	push   %rbp
  800a6c:	48 89 e5             	mov    %rsp,%rbp
  800a6f:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a73:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a77:	48 63 c6             	movslq %esi,%rax
  800a7a:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a7f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a8a:	48 85 ff             	test   %rdi,%rdi
  800a8d:	74 2a                	je     800ab9 <vsnprintf+0x4e>
  800a8f:	85 f6                	test   %esi,%esi
  800a91:	7e 26                	jle    800ab9 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a93:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a97:	48 bf f3 02 80 00 00 	movabs $0x8002f3,%rdi
  800a9e:	00 00 00 
  800aa1:	48 b8 91 03 80 00 00 	movabs $0x800391,%rax
  800aa8:	00 00 00 
  800aab:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800aad:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ab1:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ab4:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ab7:	c9                   	leaveq 
  800ab8:	c3                   	retq   
    return -E_INVAL;
  800ab9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800abe:	eb f7                	jmp    800ab7 <vsnprintf+0x4c>

0000000000800ac0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ac0:	55                   	push   %rbp
  800ac1:	48 89 e5             	mov    %rsp,%rbp
  800ac4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800acb:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ad2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ad9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ae0:	84 c0                	test   %al,%al
  800ae2:	74 20                	je     800b04 <snprintf+0x44>
  800ae4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ae8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800aec:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800af0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800af4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800af8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800afc:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b00:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b04:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b0b:	00 00 00 
  800b0e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b15:	00 00 00 
  800b18:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b1c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b23:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b2a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b31:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b38:	48 b8 6b 0a 80 00 00 	movabs $0x800a6b,%rax
  800b3f:	00 00 00 
  800b42:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b44:	c9                   	leaveq 
  800b45:	c3                   	retq   

0000000000800b46 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b46:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b49:	74 17                	je     800b62 <strlen+0x1c>
  800b4b:	48 89 fa             	mov    %rdi,%rdx
  800b4e:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b53:	29 f9                	sub    %edi,%ecx
    n++;
  800b55:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b58:	48 83 c2 01          	add    $0x1,%rdx
  800b5c:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b5f:	75 f4                	jne    800b55 <strlen+0xf>
  800b61:	c3                   	retq   
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b67:	c3                   	retq   

0000000000800b68 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b68:	48 85 f6             	test   %rsi,%rsi
  800b6b:	74 24                	je     800b91 <strnlen+0x29>
  800b6d:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b70:	74 25                	je     800b97 <strnlen+0x2f>
  800b72:	48 01 fe             	add    %rdi,%rsi
  800b75:	48 89 fa             	mov    %rdi,%rdx
  800b78:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b7d:	29 f9                	sub    %edi,%ecx
    n++;
  800b7f:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b82:	48 83 c2 01          	add    $0x1,%rdx
  800b86:	48 39 f2             	cmp    %rsi,%rdx
  800b89:	74 11                	je     800b9c <strnlen+0x34>
  800b8b:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b8e:	75 ef                	jne    800b7f <strnlen+0x17>
  800b90:	c3                   	retq   
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	c3                   	retq   
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b9c:	c3                   	retq   

0000000000800b9d <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b9d:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800ba9:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bac:	48 83 c2 01          	add    $0x1,%rdx
  800bb0:	84 c9                	test   %cl,%cl
  800bb2:	75 f1                	jne    800ba5 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bb4:	c3                   	retq   

0000000000800bb5 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bb5:	55                   	push   %rbp
  800bb6:	48 89 e5             	mov    %rsp,%rbp
  800bb9:	41 54                	push   %r12
  800bbb:	53                   	push   %rbx
  800bbc:	48 89 fb             	mov    %rdi,%rbx
  800bbf:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bc2:	48 b8 46 0b 80 00 00 	movabs $0x800b46,%rax
  800bc9:	00 00 00 
  800bcc:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bce:	48 63 f8             	movslq %eax,%rdi
  800bd1:	48 01 df             	add    %rbx,%rdi
  800bd4:	4c 89 e6             	mov    %r12,%rsi
  800bd7:	48 b8 9d 0b 80 00 00 	movabs $0x800b9d,%rax
  800bde:	00 00 00 
  800be1:	ff d0                	callq  *%rax
  return dst;
}
  800be3:	48 89 d8             	mov    %rbx,%rax
  800be6:	5b                   	pop    %rbx
  800be7:	41 5c                	pop    %r12
  800be9:	5d                   	pop    %rbp
  800bea:	c3                   	retq   

0000000000800beb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800beb:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bee:	48 85 d2             	test   %rdx,%rdx
  800bf1:	74 1f                	je     800c12 <strncpy+0x27>
  800bf3:	48 01 fa             	add    %rdi,%rdx
  800bf6:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bf9:	48 83 c1 01          	add    $0x1,%rcx
  800bfd:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c01:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c05:	41 80 f8 01          	cmp    $0x1,%r8b
  800c09:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c0d:	48 39 ca             	cmp    %rcx,%rdx
  800c10:	75 e7                	jne    800bf9 <strncpy+0xe>
  }
  return ret;
}
  800c12:	c3                   	retq   

0000000000800c13 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c13:	48 89 f8             	mov    %rdi,%rax
  800c16:	48 85 d2             	test   %rdx,%rdx
  800c19:	74 36                	je     800c51 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c1b:	48 83 fa 01          	cmp    $0x1,%rdx
  800c1f:	74 2d                	je     800c4e <strlcpy+0x3b>
  800c21:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c25:	45 84 c0             	test   %r8b,%r8b
  800c28:	74 24                	je     800c4e <strlcpy+0x3b>
  800c2a:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c2e:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c33:	48 83 c0 01          	add    $0x1,%rax
  800c37:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c3b:	48 39 d1             	cmp    %rdx,%rcx
  800c3e:	74 0e                	je     800c4e <strlcpy+0x3b>
  800c40:	48 83 c1 01          	add    $0x1,%rcx
  800c44:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c49:	45 84 c0             	test   %r8b,%r8b
  800c4c:	75 e5                	jne    800c33 <strlcpy+0x20>
    *dst = '\0';
  800c4e:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c51:	48 29 f8             	sub    %rdi,%rax
}
  800c54:	c3                   	retq   

0000000000800c55 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c55:	0f b6 07             	movzbl (%rdi),%eax
  800c58:	84 c0                	test   %al,%al
  800c5a:	74 17                	je     800c73 <strcmp+0x1e>
  800c5c:	3a 06                	cmp    (%rsi),%al
  800c5e:	75 13                	jne    800c73 <strcmp+0x1e>
    p++, q++;
  800c60:	48 83 c7 01          	add    $0x1,%rdi
  800c64:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c68:	0f b6 07             	movzbl (%rdi),%eax
  800c6b:	84 c0                	test   %al,%al
  800c6d:	74 04                	je     800c73 <strcmp+0x1e>
  800c6f:	3a 06                	cmp    (%rsi),%al
  800c71:	74 ed                	je     800c60 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c73:	0f b6 c0             	movzbl %al,%eax
  800c76:	0f b6 16             	movzbl (%rsi),%edx
  800c79:	29 d0                	sub    %edx,%eax
}
  800c7b:	c3                   	retq   

0000000000800c7c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c7c:	48 85 d2             	test   %rdx,%rdx
  800c7f:	74 2f                	je     800cb0 <strncmp+0x34>
  800c81:	0f b6 07             	movzbl (%rdi),%eax
  800c84:	84 c0                	test   %al,%al
  800c86:	74 1f                	je     800ca7 <strncmp+0x2b>
  800c88:	3a 06                	cmp    (%rsi),%al
  800c8a:	75 1b                	jne    800ca7 <strncmp+0x2b>
  800c8c:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c8f:	48 83 c7 01          	add    $0x1,%rdi
  800c93:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c97:	48 39 d7             	cmp    %rdx,%rdi
  800c9a:	74 1a                	je     800cb6 <strncmp+0x3a>
  800c9c:	0f b6 07             	movzbl (%rdi),%eax
  800c9f:	84 c0                	test   %al,%al
  800ca1:	74 04                	je     800ca7 <strncmp+0x2b>
  800ca3:	3a 06                	cmp    (%rsi),%al
  800ca5:	74 e8                	je     800c8f <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ca7:	0f b6 07             	movzbl (%rdi),%eax
  800caa:	0f b6 16             	movzbl (%rsi),%edx
  800cad:	29 d0                	sub    %edx,%eax
}
  800caf:	c3                   	retq   
    return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb5:	c3                   	retq   
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbb:	c3                   	retq   

0000000000800cbc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cbc:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cbe:	0f b6 07             	movzbl (%rdi),%eax
  800cc1:	84 c0                	test   %al,%al
  800cc3:	74 1e                	je     800ce3 <strchr+0x27>
    if (*s == c)
  800cc5:	40 38 c6             	cmp    %al,%sil
  800cc8:	74 1f                	je     800ce9 <strchr+0x2d>
  for (; *s; s++)
  800cca:	48 83 c7 01          	add    $0x1,%rdi
  800cce:	0f b6 07             	movzbl (%rdi),%eax
  800cd1:	84 c0                	test   %al,%al
  800cd3:	74 08                	je     800cdd <strchr+0x21>
    if (*s == c)
  800cd5:	38 d0                	cmp    %dl,%al
  800cd7:	75 f1                	jne    800cca <strchr+0xe>
  for (; *s; s++)
  800cd9:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cdc:	c3                   	retq   
  return 0;
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce2:	c3                   	retq   
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce8:	c3                   	retq   
    if (*s == c)
  800ce9:	48 89 f8             	mov    %rdi,%rax
  800cec:	c3                   	retq   

0000000000800ced <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ced:	48 89 f8             	mov    %rdi,%rax
  800cf0:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cf2:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cf5:	40 38 f2             	cmp    %sil,%dl
  800cf8:	74 13                	je     800d0d <strfind+0x20>
  800cfa:	84 d2                	test   %dl,%dl
  800cfc:	74 0f                	je     800d0d <strfind+0x20>
  for (; *s; s++)
  800cfe:	48 83 c0 01          	add    $0x1,%rax
  800d02:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d05:	38 ca                	cmp    %cl,%dl
  800d07:	74 04                	je     800d0d <strfind+0x20>
  800d09:	84 d2                	test   %dl,%dl
  800d0b:	75 f1                	jne    800cfe <strfind+0x11>
      break;
  return (char *)s;
}
  800d0d:	c3                   	retq   

0000000000800d0e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d0e:	48 85 d2             	test   %rdx,%rdx
  800d11:	74 3a                	je     800d4d <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d13:	48 89 f8             	mov    %rdi,%rax
  800d16:	48 09 d0             	or     %rdx,%rax
  800d19:	a8 03                	test   $0x3,%al
  800d1b:	75 28                	jne    800d45 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d1d:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	c1 e0 08             	shl    $0x8,%eax
  800d26:	89 f1                	mov    %esi,%ecx
  800d28:	c1 e1 18             	shl    $0x18,%ecx
  800d2b:	41 89 f0             	mov    %esi,%r8d
  800d2e:	41 c1 e0 10          	shl    $0x10,%r8d
  800d32:	44 09 c1             	or     %r8d,%ecx
  800d35:	09 ce                	or     %ecx,%esi
  800d37:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d39:	48 c1 ea 02          	shr    $0x2,%rdx
  800d3d:	48 89 d1             	mov    %rdx,%rcx
  800d40:	fc                   	cld    
  800d41:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d43:	eb 08                	jmp    800d4d <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d45:	89 f0                	mov    %esi,%eax
  800d47:	48 89 d1             	mov    %rdx,%rcx
  800d4a:	fc                   	cld    
  800d4b:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d4d:	48 89 f8             	mov    %rdi,%rax
  800d50:	c3                   	retq   

0000000000800d51 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d51:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d54:	48 39 fe             	cmp    %rdi,%rsi
  800d57:	73 40                	jae    800d99 <memmove+0x48>
  800d59:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d5d:	48 39 f9             	cmp    %rdi,%rcx
  800d60:	76 37                	jbe    800d99 <memmove+0x48>
    s += n;
    d += n;
  800d62:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d66:	48 89 fe             	mov    %rdi,%rsi
  800d69:	48 09 d6             	or     %rdx,%rsi
  800d6c:	48 09 ce             	or     %rcx,%rsi
  800d6f:	40 f6 c6 03          	test   $0x3,%sil
  800d73:	75 14                	jne    800d89 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d75:	48 83 ef 04          	sub    $0x4,%rdi
  800d79:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d7d:	48 c1 ea 02          	shr    $0x2,%rdx
  800d81:	48 89 d1             	mov    %rdx,%rcx
  800d84:	fd                   	std    
  800d85:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d87:	eb 0e                	jmp    800d97 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d89:	48 83 ef 01          	sub    $0x1,%rdi
  800d8d:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d91:	48 89 d1             	mov    %rdx,%rcx
  800d94:	fd                   	std    
  800d95:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d97:	fc                   	cld    
  800d98:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d99:	48 89 c1             	mov    %rax,%rcx
  800d9c:	48 09 d1             	or     %rdx,%rcx
  800d9f:	48 09 f1             	or     %rsi,%rcx
  800da2:	f6 c1 03             	test   $0x3,%cl
  800da5:	75 0e                	jne    800db5 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800da7:	48 c1 ea 02          	shr    $0x2,%rdx
  800dab:	48 89 d1             	mov    %rdx,%rcx
  800dae:	48 89 c7             	mov    %rax,%rdi
  800db1:	fc                   	cld    
  800db2:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800db4:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800db5:	48 89 c7             	mov    %rax,%rdi
  800db8:	48 89 d1             	mov    %rdx,%rcx
  800dbb:	fc                   	cld    
  800dbc:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dbe:	c3                   	retq   

0000000000800dbf <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dbf:	55                   	push   %rbp
  800dc0:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dc3:	48 b8 51 0d 80 00 00 	movabs $0x800d51,%rax
  800dca:	00 00 00 
  800dcd:	ff d0                	callq  *%rax
}
  800dcf:	5d                   	pop    %rbp
  800dd0:	c3                   	retq   

0000000000800dd1 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dd1:	55                   	push   %rbp
  800dd2:	48 89 e5             	mov    %rsp,%rbp
  800dd5:	41 57                	push   %r15
  800dd7:	41 56                	push   %r14
  800dd9:	41 55                	push   %r13
  800ddb:	41 54                	push   %r12
  800ddd:	53                   	push   %rbx
  800dde:	48 83 ec 08          	sub    $0x8,%rsp
  800de2:	49 89 fe             	mov    %rdi,%r14
  800de5:	49 89 f7             	mov    %rsi,%r15
  800de8:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800deb:	48 89 f7             	mov    %rsi,%rdi
  800dee:	48 b8 46 0b 80 00 00 	movabs $0x800b46,%rax
  800df5:	00 00 00 
  800df8:	ff d0                	callq  *%rax
  800dfa:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dfd:	4c 89 ee             	mov    %r13,%rsi
  800e00:	4c 89 f7             	mov    %r14,%rdi
  800e03:	48 b8 68 0b 80 00 00 	movabs $0x800b68,%rax
  800e0a:	00 00 00 
  800e0d:	ff d0                	callq  *%rax
  800e0f:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e12:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e16:	4d 39 e5             	cmp    %r12,%r13
  800e19:	74 26                	je     800e41 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e1b:	4c 89 e8             	mov    %r13,%rax
  800e1e:	4c 29 e0             	sub    %r12,%rax
  800e21:	48 39 d8             	cmp    %rbx,%rax
  800e24:	76 2a                	jbe    800e50 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e26:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e2a:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e2e:	4c 89 fe             	mov    %r15,%rsi
  800e31:	48 b8 bf 0d 80 00 00 	movabs $0x800dbf,%rax
  800e38:	00 00 00 
  800e3b:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e3d:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e41:	48 83 c4 08          	add    $0x8,%rsp
  800e45:	5b                   	pop    %rbx
  800e46:	41 5c                	pop    %r12
  800e48:	41 5d                	pop    %r13
  800e4a:	41 5e                	pop    %r14
  800e4c:	41 5f                	pop    %r15
  800e4e:	5d                   	pop    %rbp
  800e4f:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e50:	49 83 ed 01          	sub    $0x1,%r13
  800e54:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e58:	4c 89 ea             	mov    %r13,%rdx
  800e5b:	4c 89 fe             	mov    %r15,%rsi
  800e5e:	48 b8 bf 0d 80 00 00 	movabs $0x800dbf,%rax
  800e65:	00 00 00 
  800e68:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e6a:	4d 01 ee             	add    %r13,%r14
  800e6d:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e72:	eb c9                	jmp    800e3d <strlcat+0x6c>

0000000000800e74 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e74:	48 85 d2             	test   %rdx,%rdx
  800e77:	74 3a                	je     800eb3 <memcmp+0x3f>
    if (*s1 != *s2)
  800e79:	0f b6 0f             	movzbl (%rdi),%ecx
  800e7c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e80:	44 38 c1             	cmp    %r8b,%cl
  800e83:	75 1d                	jne    800ea2 <memcmp+0x2e>
  800e85:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e8a:	48 39 d0             	cmp    %rdx,%rax
  800e8d:	74 1e                	je     800ead <memcmp+0x39>
    if (*s1 != *s2)
  800e8f:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e93:	48 83 c0 01          	add    $0x1,%rax
  800e97:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e9d:	44 38 c1             	cmp    %r8b,%cl
  800ea0:	74 e8                	je     800e8a <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ea2:	0f b6 c1             	movzbl %cl,%eax
  800ea5:	45 0f b6 c0          	movzbl %r8b,%r8d
  800ea9:	44 29 c0             	sub    %r8d,%eax
  800eac:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ead:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb2:	c3                   	retq   
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb8:	c3                   	retq   

0000000000800eb9 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800eb9:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ebd:	48 39 c7             	cmp    %rax,%rdi
  800ec0:	73 19                	jae    800edb <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	40 38 37             	cmp    %sil,(%rdi)
  800ec7:	74 16                	je     800edf <memfind+0x26>
  for (; s < ends; s++)
  800ec9:	48 83 c7 01          	add    $0x1,%rdi
  800ecd:	48 39 f8             	cmp    %rdi,%rax
  800ed0:	74 08                	je     800eda <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed2:	38 17                	cmp    %dl,(%rdi)
  800ed4:	75 f3                	jne    800ec9 <memfind+0x10>
  for (; s < ends; s++)
  800ed6:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ed9:	c3                   	retq   
  800eda:	c3                   	retq   
  for (; s < ends; s++)
  800edb:	48 89 f8             	mov    %rdi,%rax
  800ede:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800edf:	48 89 f8             	mov    %rdi,%rax
  800ee2:	c3                   	retq   

0000000000800ee3 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ee3:	0f b6 07             	movzbl (%rdi),%eax
  800ee6:	3c 20                	cmp    $0x20,%al
  800ee8:	74 04                	je     800eee <strtol+0xb>
  800eea:	3c 09                	cmp    $0x9,%al
  800eec:	75 0f                	jne    800efd <strtol+0x1a>
    s++;
  800eee:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ef2:	0f b6 07             	movzbl (%rdi),%eax
  800ef5:	3c 20                	cmp    $0x20,%al
  800ef7:	74 f5                	je     800eee <strtol+0xb>
  800ef9:	3c 09                	cmp    $0x9,%al
  800efb:	74 f1                	je     800eee <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800efd:	3c 2b                	cmp    $0x2b,%al
  800eff:	74 2b                	je     800f2c <strtol+0x49>
  int neg  = 0;
  800f01:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f07:	3c 2d                	cmp    $0x2d,%al
  800f09:	74 2d                	je     800f38 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0b:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f11:	75 0f                	jne    800f22 <strtol+0x3f>
  800f13:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f16:	74 2c                	je     800f44 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f18:	85 d2                	test   %edx,%edx
  800f1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1f:	0f 44 d0             	cmove  %eax,%edx
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f27:	4c 63 d2             	movslq %edx,%r10
  800f2a:	eb 5c                	jmp    800f88 <strtol+0xa5>
    s++;
  800f2c:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f30:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f36:	eb d3                	jmp    800f0b <strtol+0x28>
    s++, neg = 1;
  800f38:	48 83 c7 01          	add    $0x1,%rdi
  800f3c:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f42:	eb c7                	jmp    800f0b <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f44:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f48:	74 0f                	je     800f59 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f4a:	85 d2                	test   %edx,%edx
  800f4c:	75 d4                	jne    800f22 <strtol+0x3f>
    s++, base = 8;
  800f4e:	48 83 c7 01          	add    $0x1,%rdi
  800f52:	ba 08 00 00 00       	mov    $0x8,%edx
  800f57:	eb c9                	jmp    800f22 <strtol+0x3f>
    s += 2, base = 16;
  800f59:	48 83 c7 02          	add    $0x2,%rdi
  800f5d:	ba 10 00 00 00       	mov    $0x10,%edx
  800f62:	eb be                	jmp    800f22 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f64:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f68:	41 80 f8 19          	cmp    $0x19,%r8b
  800f6c:	77 2f                	ja     800f9d <strtol+0xba>
      dig = *s - 'a' + 10;
  800f6e:	44 0f be c1          	movsbl %cl,%r8d
  800f72:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f76:	39 d1                	cmp    %edx,%ecx
  800f78:	7d 37                	jge    800fb1 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f7a:	48 83 c7 01          	add    $0x1,%rdi
  800f7e:	49 0f af c2          	imul   %r10,%rax
  800f82:	48 63 c9             	movslq %ecx,%rcx
  800f85:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f88:	0f b6 0f             	movzbl (%rdi),%ecx
  800f8b:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f8f:	41 80 f8 09          	cmp    $0x9,%r8b
  800f93:	77 cf                	ja     800f64 <strtol+0x81>
      dig = *s - '0';
  800f95:	0f be c9             	movsbl %cl,%ecx
  800f98:	83 e9 30             	sub    $0x30,%ecx
  800f9b:	eb d9                	jmp    800f76 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f9d:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fa1:	41 80 f8 19          	cmp    $0x19,%r8b
  800fa5:	77 0a                	ja     800fb1 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fa7:	44 0f be c1          	movsbl %cl,%r8d
  800fab:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800faf:	eb c5                	jmp    800f76 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fb1:	48 85 f6             	test   %rsi,%rsi
  800fb4:	74 03                	je     800fb9 <strtol+0xd6>
    *endptr = (char *)s;
  800fb6:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fb9:	48 89 c2             	mov    %rax,%rdx
  800fbc:	48 f7 da             	neg    %rdx
  800fbf:	45 85 c9             	test   %r9d,%r9d
  800fc2:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fc6:	c3                   	retq   

0000000000800fc7 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fc7:	55                   	push   %rbp
  800fc8:	48 89 e5             	mov    %rsp,%rbp
  800fcb:	53                   	push   %rbx
  800fcc:	48 89 fa             	mov    %rdi,%rdx
  800fcf:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd7:	48 89 c3             	mov    %rax,%rbx
  800fda:	48 89 c7             	mov    %rax,%rdi
  800fdd:	48 89 c6             	mov    %rax,%rsi
  800fe0:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fe2:	5b                   	pop    %rbx
  800fe3:	5d                   	pop    %rbp
  800fe4:	c3                   	retq   

0000000000800fe5 <sys_cgetc>:

int
sys_cgetc(void) {
  800fe5:	55                   	push   %rbp
  800fe6:	48 89 e5             	mov    %rsp,%rbp
  800fe9:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fef:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff4:	48 89 ca             	mov    %rcx,%rdx
  800ff7:	48 89 cb             	mov    %rcx,%rbx
  800ffa:	48 89 cf             	mov    %rcx,%rdi
  800ffd:	48 89 ce             	mov    %rcx,%rsi
  801000:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801002:	5b                   	pop    %rbx
  801003:	5d                   	pop    %rbp
  801004:	c3                   	retq   

0000000000801005 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801005:	55                   	push   %rbp
  801006:	48 89 e5             	mov    %rsp,%rbp
  801009:	53                   	push   %rbx
  80100a:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80100e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801011:	be 00 00 00 00       	mov    $0x0,%esi
  801016:	b8 03 00 00 00       	mov    $0x3,%eax
  80101b:	48 89 f1             	mov    %rsi,%rcx
  80101e:	48 89 f3             	mov    %rsi,%rbx
  801021:	48 89 f7             	mov    %rsi,%rdi
  801024:	cd 30                	int    $0x30
  if (check && ret > 0)
  801026:	48 85 c0             	test   %rax,%rax
  801029:	7f 07                	jg     801032 <sys_env_destroy+0x2d>
}
  80102b:	48 83 c4 08          	add    $0x8,%rsp
  80102f:	5b                   	pop    %rbx
  801030:	5d                   	pop    %rbp
  801031:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801032:	49 89 c0             	mov    %rax,%r8
  801035:	b9 03 00 00 00       	mov    $0x3,%ecx
  80103a:	48 ba 50 15 80 00 00 	movabs $0x801550,%rdx
  801041:	00 00 00 
  801044:	be 22 00 00 00       	mov    $0x22,%esi
  801049:	48 bf 6f 15 80 00 00 	movabs $0x80156f,%rdi
  801050:	00 00 00 
  801053:	b8 00 00 00 00       	mov    $0x0,%eax
  801058:	49 b9 85 10 80 00 00 	movabs $0x801085,%r9
  80105f:	00 00 00 
  801062:	41 ff d1             	callq  *%r9

0000000000801065 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801065:	55                   	push   %rbp
  801066:	48 89 e5             	mov    %rsp,%rbp
  801069:	53                   	push   %rbx
  asm volatile("int %1\n"
  80106a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106f:	b8 02 00 00 00       	mov    $0x2,%eax
  801074:	48 89 ca             	mov    %rcx,%rdx
  801077:	48 89 cb             	mov    %rcx,%rbx
  80107a:	48 89 cf             	mov    %rcx,%rdi
  80107d:	48 89 ce             	mov    %rcx,%rsi
  801080:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801082:	5b                   	pop    %rbx
  801083:	5d                   	pop    %rbp
  801084:	c3                   	retq   

0000000000801085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801085:	55                   	push   %rbp
  801086:	48 89 e5             	mov    %rsp,%rbp
  801089:	41 56                	push   %r14
  80108b:	41 55                	push   %r13
  80108d:	41 54                	push   %r12
  80108f:	53                   	push   %rbx
  801090:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801097:	49 89 fd             	mov    %rdi,%r13
  80109a:	41 89 f6             	mov    %esi,%r14d
  80109d:	49 89 d4             	mov    %rdx,%r12
  8010a0:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8010a7:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010ae:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010b5:	84 c0                	test   %al,%al
  8010b7:	74 26                	je     8010df <_panic+0x5a>
  8010b9:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010c0:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010c7:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010cb:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010cf:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010d3:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010d7:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010db:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010df:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010e6:	00 00 00 
  8010e9:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010f0:	00 00 00 
  8010f3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010f7:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010fe:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801105:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80110c:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  801113:	00 00 00 
  801116:	48 8b 18             	mov    (%rax),%rbx
  801119:	48 b8 65 10 80 00 00 	movabs $0x801065,%rax
  801120:	00 00 00 
  801123:	ff d0                	callq  *%rax
  801125:	45 89 f0             	mov    %r14d,%r8d
  801128:	4c 89 e9             	mov    %r13,%rcx
  80112b:	48 89 da             	mov    %rbx,%rdx
  80112e:	89 c6                	mov    %eax,%esi
  801130:	48 bf 80 15 80 00 00 	movabs $0x801580,%rdi
  801137:	00 00 00 
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
  80113f:	48 bb d3 01 80 00 00 	movabs $0x8001d3,%rbx
  801146:	00 00 00 
  801149:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80114b:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801152:	4c 89 e7             	mov    %r12,%rdi
  801155:	48 b8 6b 01 80 00 00 	movabs $0x80016b,%rax
  80115c:	00 00 00 
  80115f:	ff d0                	callq  *%rax
  cprintf("\n");
  801161:	48 bf 82 11 80 00 00 	movabs $0x801182,%rdi
  801168:	00 00 00 
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801172:	cc                   	int3   
  while (1)
  801173:	eb fd                	jmp    801172 <_panic+0xed>
  801175:	0f 1f 00             	nopl   (%rax)
