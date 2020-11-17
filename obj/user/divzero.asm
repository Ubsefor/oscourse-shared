
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
  800044:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  80004b:	00 00 00 
  80004e:	b8 00 00 00 00       	mov    $0x0,%eax
  800053:	48 ba e4 01 80 00 00 	movabs $0x8001e4,%rdx
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
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  8000ae:	48 b8 76 10 80 00 00 	movabs $0x801076,%rax
  8000b5:	00 00 00 
  8000b8:	ff d0                	callq  *%rax
  8000ba:	83 e0 1f             	and    $0x1f,%eax
  8000bd:	48 89 c2             	mov    %rax,%rdx
  8000c0:	48 c1 e2 05          	shl    $0x5,%rdx
  8000c4:	48 29 c2             	sub    %rax,%rdx
  8000c7:	48 89 d0             	mov    %rdx,%rax
  8000ca:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000d1:	00 00 00 
  8000d4:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000d8:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  8000df:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000e2:	45 85 ed             	test   %r13d,%r13d
  8000e5:	7e 0d                	jle    8000f4 <libmain+0x93>
    binaryname = argv[0];
  8000e7:	49 8b 06             	mov    (%r14),%rax
  8000ea:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000f1:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000f4:	4c 89 f6             	mov    %r14,%rsi
  8000f7:	44 89 ef             	mov    %r13d,%edi
  8000fa:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800101:	00 00 00 
  800104:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800106:	48 b8 1b 01 80 00 00 	movabs $0x80011b,%rax
  80010d:	00 00 00 
  800110:	ff d0                	callq  *%rax
#endif
}
  800112:	5b                   	pop    %rbx
  800113:	41 5c                	pop    %r12
  800115:	41 5d                	pop    %r13
  800117:	41 5e                	pop    %r14
  800119:	5d                   	pop    %rbp
  80011a:	c3                   	retq   

000000000080011b <exit>:

#include <inc/lib.h>

void
exit(void) {
  80011b:	55                   	push   %rbp
  80011c:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80011f:	bf 00 00 00 00       	mov    $0x0,%edi
  800124:	48 b8 16 10 80 00 00 	movabs $0x801016,%rax
  80012b:	00 00 00 
  80012e:	ff d0                	callq  *%rax
}
  800130:	5d                   	pop    %rbp
  800131:	c3                   	retq   

0000000000800132 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800132:	55                   	push   %rbp
  800133:	48 89 e5             	mov    %rsp,%rbp
  800136:	53                   	push   %rbx
  800137:	48 83 ec 08          	sub    $0x8,%rsp
  80013b:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80013e:	8b 06                	mov    (%rsi),%eax
  800140:	8d 50 01             	lea    0x1(%rax),%edx
  800143:	89 16                	mov    %edx,(%rsi)
  800145:	48 98                	cltq   
  800147:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80014c:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800152:	74 0b                	je     80015f <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800154:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800158:	48 83 c4 08          	add    $0x8,%rsp
  80015c:	5b                   	pop    %rbx
  80015d:	5d                   	pop    %rbp
  80015e:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80015f:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800163:	be ff 00 00 00       	mov    $0xff,%esi
  800168:	48 b8 d8 0f 80 00 00 	movabs $0x800fd8,%rax
  80016f:	00 00 00 
  800172:	ff d0                	callq  *%rax
    b->idx = 0;
  800174:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80017a:	eb d8                	jmp    800154 <putch+0x22>

000000000080017c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80017c:	55                   	push   %rbp
  80017d:	48 89 e5             	mov    %rsp,%rbp
  800180:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800187:	48 89 fa             	mov    %rdi,%rdx
  80018a:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80018d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800194:	00 00 00 
  b.cnt = 0;
  800197:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80019e:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8001a1:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001a8:	48 bf 32 01 80 00 00 	movabs $0x800132,%rdi
  8001af:	00 00 00 
  8001b2:	48 b8 a2 03 80 00 00 	movabs $0x8003a2,%rax
  8001b9:	00 00 00 
  8001bc:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001be:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001c5:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001cc:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001d0:	48 b8 d8 0f 80 00 00 	movabs $0x800fd8,%rax
  8001d7:	00 00 00 
  8001da:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001e2:	c9                   	leaveq 
  8001e3:	c3                   	retq   

00000000008001e4 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001e4:	55                   	push   %rbp
  8001e5:	48 89 e5             	mov    %rsp,%rbp
  8001e8:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001ef:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001f6:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001fd:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800204:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80020b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800212:	84 c0                	test   %al,%al
  800214:	74 20                	je     800236 <cprintf+0x52>
  800216:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80021a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80021e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800222:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800226:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80022a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80022e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800232:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800236:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80023d:	00 00 00 
  800240:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800247:	00 00 00 
  80024a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80024e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800255:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80025c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800263:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80026a:	48 b8 7c 01 80 00 00 	movabs $0x80017c,%rax
  800271:	00 00 00 
  800274:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800276:	c9                   	leaveq 
  800277:	c3                   	retq   

0000000000800278 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800278:	55                   	push   %rbp
  800279:	48 89 e5             	mov    %rsp,%rbp
  80027c:	41 57                	push   %r15
  80027e:	41 56                	push   %r14
  800280:	41 55                	push   %r13
  800282:	41 54                	push   %r12
  800284:	53                   	push   %rbx
  800285:	48 83 ec 18          	sub    $0x18,%rsp
  800289:	49 89 fc             	mov    %rdi,%r12
  80028c:	49 89 f5             	mov    %rsi,%r13
  80028f:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800293:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800296:	41 89 cf             	mov    %ecx,%r15d
  800299:	49 39 d7             	cmp    %rdx,%r15
  80029c:	76 45                	jbe    8002e3 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80029e:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8002a2:	85 db                	test   %ebx,%ebx
  8002a4:	7e 0e                	jle    8002b4 <printnum+0x3c>
      putch(padc, putdat);
  8002a6:	4c 89 ee             	mov    %r13,%rsi
  8002a9:	44 89 f7             	mov    %r14d,%edi
  8002ac:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	75 f2                	jne    8002a6 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002b4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bd:	49 f7 f7             	div    %r15
  8002c0:	48 b8 bb 11 80 00 00 	movabs $0x8011bb,%rax
  8002c7:	00 00 00 
  8002ca:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002ce:	4c 89 ee             	mov    %r13,%rsi
  8002d1:	41 ff d4             	callq  *%r12
}
  8002d4:	48 83 c4 18          	add    $0x18,%rsp
  8002d8:	5b                   	pop    %rbx
  8002d9:	41 5c                	pop    %r12
  8002db:	41 5d                	pop    %r13
  8002dd:	41 5e                	pop    %r14
  8002df:	41 5f                	pop    %r15
  8002e1:	5d                   	pop    %rbp
  8002e2:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	49 f7 f7             	div    %r15
  8002ef:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002f3:	48 89 c2             	mov    %rax,%rdx
  8002f6:	48 b8 78 02 80 00 00 	movabs $0x800278,%rax
  8002fd:	00 00 00 
  800300:	ff d0                	callq  *%rax
  800302:	eb b0                	jmp    8002b4 <printnum+0x3c>

0000000000800304 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800304:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800308:	48 8b 06             	mov    (%rsi),%rax
  80030b:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80030f:	73 0a                	jae    80031b <sprintputch+0x17>
    *b->buf++ = ch;
  800311:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800315:	48 89 16             	mov    %rdx,(%rsi)
  800318:	40 88 38             	mov    %dil,(%rax)
}
  80031b:	c3                   	retq   

000000000080031c <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80031c:	55                   	push   %rbp
  80031d:	48 89 e5             	mov    %rsp,%rbp
  800320:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800327:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80032e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800335:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80033c:	84 c0                	test   %al,%al
  80033e:	74 20                	je     800360 <printfmt+0x44>
  800340:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800344:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800348:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80034c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800350:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800354:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800358:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80035c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800360:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800367:	00 00 00 
  80036a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800371:	00 00 00 
  800374:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800378:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80037f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800386:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80038d:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800394:	48 b8 a2 03 80 00 00 	movabs $0x8003a2,%rax
  80039b:	00 00 00 
  80039e:	ff d0                	callq  *%rax
}
  8003a0:	c9                   	leaveq 
  8003a1:	c3                   	retq   

00000000008003a2 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8003a2:	55                   	push   %rbp
  8003a3:	48 89 e5             	mov    %rsp,%rbp
  8003a6:	41 57                	push   %r15
  8003a8:	41 56                	push   %r14
  8003aa:	41 55                	push   %r13
  8003ac:	41 54                	push   %r12
  8003ae:	53                   	push   %rbx
  8003af:	48 83 ec 48          	sub    $0x48,%rsp
  8003b3:	49 89 fd             	mov    %rdi,%r13
  8003b6:	49 89 f7             	mov    %rsi,%r15
  8003b9:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003bc:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003c0:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003c4:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003c8:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003cc:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003d0:	41 0f b6 3e          	movzbl (%r14),%edi
  8003d4:	83 ff 25             	cmp    $0x25,%edi
  8003d7:	74 18                	je     8003f1 <vprintfmt+0x4f>
      if (ch == '\0')
  8003d9:	85 ff                	test   %edi,%edi
  8003db:	0f 84 8c 06 00 00    	je     800a6d <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003e1:	4c 89 fe             	mov    %r15,%rsi
  8003e4:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003e7:	49 89 de             	mov    %rbx,%r14
  8003ea:	eb e0                	jmp    8003cc <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003ec:	49 89 de             	mov    %rbx,%r14
  8003ef:	eb db                	jmp    8003cc <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003f1:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003f5:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003f9:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800400:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800406:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80040a:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80040f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800415:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80041b:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800420:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800425:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800429:	0f b6 13             	movzbl (%rbx),%edx
  80042c:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80042f:	3c 55                	cmp    $0x55,%al
  800431:	0f 87 8b 05 00 00    	ja     8009c2 <vprintfmt+0x620>
  800437:	0f b6 c0             	movzbl %al,%eax
  80043a:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800441:	00 00 00 
  800444:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800448:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80044b:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80044f:	eb d4                	jmp    800425 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800451:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800454:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800458:	eb cb                	jmp    800425 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80045a:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80045d:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800461:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800465:	8d 50 d0             	lea    -0x30(%rax),%edx
  800468:	83 fa 09             	cmp    $0x9,%edx
  80046b:	77 7e                	ja     8004eb <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80046d:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800471:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800475:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80047a:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80047e:	8d 50 d0             	lea    -0x30(%rax),%edx
  800481:	83 fa 09             	cmp    $0x9,%edx
  800484:	76 e7                	jbe    80046d <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800486:	4c 89 f3             	mov    %r14,%rbx
  800489:	eb 19                	jmp    8004a4 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80048b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80048e:	83 f8 2f             	cmp    $0x2f,%eax
  800491:	77 2a                	ja     8004bd <vprintfmt+0x11b>
  800493:	89 c2                	mov    %eax,%edx
  800495:	4c 01 d2             	add    %r10,%rdx
  800498:	83 c0 08             	add    $0x8,%eax
  80049b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80049e:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8004a1:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004a4:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004a8:	0f 89 77 ff ff ff    	jns    800425 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004ae:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004b2:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004b8:	e9 68 ff ff ff       	jmpq   800425 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004bd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004c1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004c5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004c9:	eb d3                	jmp    80049e <vprintfmt+0xfc>
        if (width < 0)
  8004cb:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004d4:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004d7:	4c 89 f3             	mov    %r14,%rbx
  8004da:	e9 46 ff ff ff       	jmpq   800425 <vprintfmt+0x83>
  8004df:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004e2:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004e6:	e9 3a ff ff ff       	jmpq   800425 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004eb:	4c 89 f3             	mov    %r14,%rbx
  8004ee:	eb b4                	jmp    8004a4 <vprintfmt+0x102>
        lflag++;
  8004f0:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004f3:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004f6:	e9 2a ff ff ff       	jmpq   800425 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004fb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004fe:	83 f8 2f             	cmp    $0x2f,%eax
  800501:	77 19                	ja     80051c <vprintfmt+0x17a>
  800503:	89 c2                	mov    %eax,%edx
  800505:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800509:	83 c0 08             	add    $0x8,%eax
  80050c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80050f:	4c 89 fe             	mov    %r15,%rsi
  800512:	8b 3a                	mov    (%rdx),%edi
  800514:	41 ff d5             	callq  *%r13
        break;
  800517:	e9 b0 fe ff ff       	jmpq   8003cc <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80051c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800520:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800524:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800528:	eb e5                	jmp    80050f <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80052a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80052d:	83 f8 2f             	cmp    $0x2f,%eax
  800530:	77 5b                	ja     80058d <vprintfmt+0x1eb>
  800532:	89 c2                	mov    %eax,%edx
  800534:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800538:	83 c0 08             	add    $0x8,%eax
  80053b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80053e:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800540:	89 c8                	mov    %ecx,%eax
  800542:	c1 f8 1f             	sar    $0x1f,%eax
  800545:	31 c1                	xor    %eax,%ecx
  800547:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800549:	83 f9 09             	cmp    $0x9,%ecx
  80054c:	7f 4d                	jg     80059b <vprintfmt+0x1f9>
  80054e:	48 63 c1             	movslq %ecx,%rax
  800551:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  800558:	00 00 00 
  80055b:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80055f:	48 85 c0             	test   %rax,%rax
  800562:	74 37                	je     80059b <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800564:	48 89 c1             	mov    %rax,%rcx
  800567:	48 ba dc 11 80 00 00 	movabs $0x8011dc,%rdx
  80056e:	00 00 00 
  800571:	4c 89 fe             	mov    %r15,%rsi
  800574:	4c 89 ef             	mov    %r13,%rdi
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	48 bb 1c 03 80 00 00 	movabs $0x80031c,%rbx
  800583:	00 00 00 
  800586:	ff d3                	callq  *%rbx
  800588:	e9 3f fe ff ff       	jmpq   8003cc <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80058d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800591:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800595:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800599:	eb a3                	jmp    80053e <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80059b:	48 ba d3 11 80 00 00 	movabs $0x8011d3,%rdx
  8005a2:	00 00 00 
  8005a5:	4c 89 fe             	mov    %r15,%rsi
  8005a8:	4c 89 ef             	mov    %r13,%rdi
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	48 bb 1c 03 80 00 00 	movabs $0x80031c,%rbx
  8005b7:	00 00 00 
  8005ba:	ff d3                	callq  *%rbx
  8005bc:	e9 0b fe ff ff       	jmpq   8003cc <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005c1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005c4:	83 f8 2f             	cmp    $0x2f,%eax
  8005c7:	77 4b                	ja     800614 <vprintfmt+0x272>
  8005c9:	89 c2                	mov    %eax,%edx
  8005cb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005cf:	83 c0 08             	add    $0x8,%eax
  8005d2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d5:	48 8b 02             	mov    (%rdx),%rax
  8005d8:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005dc:	48 85 c0             	test   %rax,%rax
  8005df:	0f 84 05 04 00 00    	je     8009ea <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005e5:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005e9:	7e 06                	jle    8005f1 <vprintfmt+0x24f>
  8005eb:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005ef:	75 31                	jne    800622 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f1:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005f5:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005f9:	0f b6 00             	movzbl (%rax),%eax
  8005fc:	0f be f8             	movsbl %al,%edi
  8005ff:	85 ff                	test   %edi,%edi
  800601:	0f 84 c3 00 00 00    	je     8006ca <vprintfmt+0x328>
  800607:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80060b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80060f:	e9 85 00 00 00       	jmpq   800699 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800614:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800618:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80061c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800620:	eb b3                	jmp    8005d5 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800622:	49 63 f4             	movslq %r12d,%rsi
  800625:	48 89 c7             	mov    %rax,%rdi
  800628:	48 b8 79 0b 80 00 00 	movabs $0x800b79,%rax
  80062f:	00 00 00 
  800632:	ff d0                	callq  *%rax
  800634:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800637:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80063a:	85 f6                	test   %esi,%esi
  80063c:	7e 22                	jle    800660 <vprintfmt+0x2be>
            putch(padc, putdat);
  80063e:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800642:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800646:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80064a:	4c 89 fe             	mov    %r15,%rsi
  80064d:	89 df                	mov    %ebx,%edi
  80064f:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800652:	41 83 ec 01          	sub    $0x1,%r12d
  800656:	75 f2                	jne    80064a <vprintfmt+0x2a8>
  800658:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80065c:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800664:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800668:	0f b6 00             	movzbl (%rax),%eax
  80066b:	0f be f8             	movsbl %al,%edi
  80066e:	85 ff                	test   %edi,%edi
  800670:	0f 84 56 fd ff ff    	je     8003cc <vprintfmt+0x2a>
  800676:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80067a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80067e:	eb 19                	jmp    800699 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800680:	4c 89 fe             	mov    %r15,%rsi
  800683:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800686:	41 83 ee 01          	sub    $0x1,%r14d
  80068a:	48 83 c3 01          	add    $0x1,%rbx
  80068e:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800692:	0f be f8             	movsbl %al,%edi
  800695:	85 ff                	test   %edi,%edi
  800697:	74 29                	je     8006c2 <vprintfmt+0x320>
  800699:	45 85 e4             	test   %r12d,%r12d
  80069c:	78 06                	js     8006a4 <vprintfmt+0x302>
  80069e:	41 83 ec 01          	sub    $0x1,%r12d
  8006a2:	78 48                	js     8006ec <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006a4:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006a8:	74 d6                	je     800680 <vprintfmt+0x2de>
  8006aa:	0f be c0             	movsbl %al,%eax
  8006ad:	83 e8 20             	sub    $0x20,%eax
  8006b0:	83 f8 5e             	cmp    $0x5e,%eax
  8006b3:	76 cb                	jbe    800680 <vprintfmt+0x2de>
            putch('?', putdat);
  8006b5:	4c 89 fe             	mov    %r15,%rsi
  8006b8:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006bd:	41 ff d5             	callq  *%r13
  8006c0:	eb c4                	jmp    800686 <vprintfmt+0x2e4>
  8006c2:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006c6:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006ca:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006cd:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006d1:	0f 8e f5 fc ff ff    	jle    8003cc <vprintfmt+0x2a>
          putch(' ', putdat);
  8006d7:	4c 89 fe             	mov    %r15,%rsi
  8006da:	bf 20 00 00 00       	mov    $0x20,%edi
  8006df:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006e2:	83 eb 01             	sub    $0x1,%ebx
  8006e5:	75 f0                	jne    8006d7 <vprintfmt+0x335>
  8006e7:	e9 e0 fc ff ff       	jmpq   8003cc <vprintfmt+0x2a>
  8006ec:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006f0:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006f4:	eb d4                	jmp    8006ca <vprintfmt+0x328>
  if (lflag >= 2)
  8006f6:	83 f9 01             	cmp    $0x1,%ecx
  8006f9:	7f 1d                	jg     800718 <vprintfmt+0x376>
  else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	74 5e                	je     80075d <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006ff:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800702:	83 f8 2f             	cmp    $0x2f,%eax
  800705:	77 48                	ja     80074f <vprintfmt+0x3ad>
  800707:	89 c2                	mov    %eax,%edx
  800709:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80070d:	83 c0 08             	add    $0x8,%eax
  800710:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800713:	48 8b 1a             	mov    (%rdx),%rbx
  800716:	eb 17                	jmp    80072f <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800718:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80071b:	83 f8 2f             	cmp    $0x2f,%eax
  80071e:	77 21                	ja     800741 <vprintfmt+0x39f>
  800720:	89 c2                	mov    %eax,%edx
  800722:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800726:	83 c0 08             	add    $0x8,%eax
  800729:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80072c:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80072f:	48 85 db             	test   %rbx,%rbx
  800732:	78 50                	js     800784 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800734:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800737:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073c:	e9 b4 01 00 00       	jmpq   8008f5 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800741:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800745:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800749:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074d:	eb dd                	jmp    80072c <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80074f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800753:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800757:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80075b:	eb b6                	jmp    800713 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80075d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800760:	83 f8 2f             	cmp    $0x2f,%eax
  800763:	77 11                	ja     800776 <vprintfmt+0x3d4>
  800765:	89 c2                	mov    %eax,%edx
  800767:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80076b:	83 c0 08             	add    $0x8,%eax
  80076e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800771:	48 63 1a             	movslq (%rdx),%rbx
  800774:	eb b9                	jmp    80072f <vprintfmt+0x38d>
  800776:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80077a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80077e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800782:	eb ed                	jmp    800771 <vprintfmt+0x3cf>
          putch('-', putdat);
  800784:	4c 89 fe             	mov    %r15,%rsi
  800787:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80078c:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80078f:	48 89 da             	mov    %rbx,%rdx
  800792:	48 f7 da             	neg    %rdx
        base = 10;
  800795:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80079a:	e9 56 01 00 00       	jmpq   8008f5 <vprintfmt+0x553>
  if (lflag >= 2)
  80079f:	83 f9 01             	cmp    $0x1,%ecx
  8007a2:	7f 25                	jg     8007c9 <vprintfmt+0x427>
  else if (lflag)
  8007a4:	85 c9                	test   %ecx,%ecx
  8007a6:	74 5e                	je     800806 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007a8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007ab:	83 f8 2f             	cmp    $0x2f,%eax
  8007ae:	77 48                	ja     8007f8 <vprintfmt+0x456>
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007b6:	83 c0 08             	add    $0x8,%eax
  8007b9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007bc:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c4:	e9 2c 01 00 00       	jmpq   8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007c9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007cc:	83 f8 2f             	cmp    $0x2f,%eax
  8007cf:	77 19                	ja     8007ea <vprintfmt+0x448>
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d7:	83 c0 08             	add    $0x8,%eax
  8007da:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007dd:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e5:	e9 0b 01 00 00       	jmpq   8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007ea:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ee:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007f2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f6:	eb e5                	jmp    8007dd <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007f8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007fc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800800:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800804:	eb b6                	jmp    8007bc <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800806:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800809:	83 f8 2f             	cmp    $0x2f,%eax
  80080c:	77 18                	ja     800826 <vprintfmt+0x484>
  80080e:	89 c2                	mov    %eax,%edx
  800810:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800814:	83 c0 08             	add    $0x8,%eax
  800817:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80081a:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800821:	e9 cf 00 00 00       	jmpq   8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800826:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80082a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80082e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800832:	eb e6                	jmp    80081a <vprintfmt+0x478>
  if (lflag >= 2)
  800834:	83 f9 01             	cmp    $0x1,%ecx
  800837:	7f 25                	jg     80085e <vprintfmt+0x4bc>
  else if (lflag)
  800839:	85 c9                	test   %ecx,%ecx
  80083b:	74 5b                	je     800898 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80083d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800840:	83 f8 2f             	cmp    $0x2f,%eax
  800843:	77 45                	ja     80088a <vprintfmt+0x4e8>
  800845:	89 c2                	mov    %eax,%edx
  800847:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80084b:	83 c0 08             	add    $0x8,%eax
  80084e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800851:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800854:	b9 08 00 00 00       	mov    $0x8,%ecx
  800859:	e9 97 00 00 00       	jmpq   8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80085e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800861:	83 f8 2f             	cmp    $0x2f,%eax
  800864:	77 16                	ja     80087c <vprintfmt+0x4da>
  800866:	89 c2                	mov    %eax,%edx
  800868:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80086c:	83 c0 08             	add    $0x8,%eax
  80086f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800872:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800875:	b9 08 00 00 00       	mov    $0x8,%ecx
  80087a:	eb 79                	jmp    8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80087c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800880:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800884:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800888:	eb e8                	jmp    800872 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80088a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800892:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800896:	eb b9                	jmp    800851 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800898:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089b:	83 f8 2f             	cmp    $0x2f,%eax
  80089e:	77 15                	ja     8008b5 <vprintfmt+0x513>
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a6:	83 c0 08             	add    $0x8,%eax
  8008a9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ac:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008ae:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008b3:	eb 40                	jmp    8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008b5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008bd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c1:	eb e9                	jmp    8008ac <vprintfmt+0x50a>
        putch('0', putdat);
  8008c3:	4c 89 fe             	mov    %r15,%rsi
  8008c6:	bf 30 00 00 00       	mov    $0x30,%edi
  8008cb:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008ce:	4c 89 fe             	mov    %r15,%rsi
  8008d1:	bf 78 00 00 00       	mov    $0x78,%edi
  8008d6:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008d9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008dc:	83 f8 2f             	cmp    $0x2f,%eax
  8008df:	77 34                	ja     800915 <vprintfmt+0x573>
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e7:	83 c0 08             	add    $0x8,%eax
  8008ea:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ed:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008f0:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008f5:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008fa:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008fe:	4c 89 fe             	mov    %r15,%rsi
  800901:	4c 89 ef             	mov    %r13,%rdi
  800904:	48 b8 78 02 80 00 00 	movabs $0x800278,%rax
  80090b:	00 00 00 
  80090e:	ff d0                	callq  *%rax
        break;
  800910:	e9 b7 fa ff ff       	jmpq   8003cc <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800915:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800919:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800921:	eb ca                	jmp    8008ed <vprintfmt+0x54b>
  if (lflag >= 2)
  800923:	83 f9 01             	cmp    $0x1,%ecx
  800926:	7f 22                	jg     80094a <vprintfmt+0x5a8>
  else if (lflag)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 58                	je     800984 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80092c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092f:	83 f8 2f             	cmp    $0x2f,%eax
  800932:	77 42                	ja     800976 <vprintfmt+0x5d4>
  800934:	89 c2                	mov    %eax,%edx
  800936:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093a:	83 c0 08             	add    $0x8,%eax
  80093d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800940:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800943:	b9 10 00 00 00       	mov    $0x10,%ecx
  800948:	eb ab                	jmp    8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80094a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094d:	83 f8 2f             	cmp    $0x2f,%eax
  800950:	77 16                	ja     800968 <vprintfmt+0x5c6>
  800952:	89 c2                	mov    %eax,%edx
  800954:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800958:	83 c0 08             	add    $0x8,%eax
  80095b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095e:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800961:	b9 10 00 00 00       	mov    $0x10,%ecx
  800966:	eb 8d                	jmp    8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800968:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800970:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800974:	eb e8                	jmp    80095e <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800976:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800982:	eb bc                	jmp    800940 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800984:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800987:	83 f8 2f             	cmp    $0x2f,%eax
  80098a:	77 18                	ja     8009a4 <vprintfmt+0x602>
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800992:	83 c0 08             	add    $0x8,%eax
  800995:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800998:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80099a:	b9 10 00 00 00       	mov    $0x10,%ecx
  80099f:	e9 51 ff ff ff       	jmpq   8008f5 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b0:	eb e6                	jmp    800998 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009b2:	4c 89 fe             	mov    %r15,%rsi
  8009b5:	bf 25 00 00 00       	mov    $0x25,%edi
  8009ba:	41 ff d5             	callq  *%r13
        break;
  8009bd:	e9 0a fa ff ff       	jmpq   8003cc <vprintfmt+0x2a>
        putch('%', putdat);
  8009c2:	4c 89 fe             	mov    %r15,%rsi
  8009c5:	bf 25 00 00 00       	mov    $0x25,%edi
  8009ca:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009cd:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009d1:	0f 84 15 fa ff ff    	je     8003ec <vprintfmt+0x4a>
  8009d7:	49 89 de             	mov    %rbx,%r14
  8009da:	49 83 ee 01          	sub    $0x1,%r14
  8009de:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009e3:	75 f5                	jne    8009da <vprintfmt+0x638>
  8009e5:	e9 e2 f9 ff ff       	jmpq   8003cc <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009ea:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009ee:	74 06                	je     8009f6 <vprintfmt+0x654>
  8009f0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009f4:	7f 21                	jg     800a17 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f6:	bf 28 00 00 00       	mov    $0x28,%edi
  8009fb:	48 bb cd 11 80 00 00 	movabs $0x8011cd,%rbx
  800a02:	00 00 00 
  800a05:	b8 28 00 00 00       	mov    $0x28,%eax
  800a0a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a0e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a12:	e9 82 fc ff ff       	jmpq   800699 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a17:	49 63 f4             	movslq %r12d,%rsi
  800a1a:	48 bf cc 11 80 00 00 	movabs $0x8011cc,%rdi
  800a21:	00 00 00 
  800a24:	48 b8 79 0b 80 00 00 	movabs $0x800b79,%rax
  800a2b:	00 00 00 
  800a2e:	ff d0                	callq  *%rax
  800a30:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a33:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a36:	48 be cc 11 80 00 00 	movabs $0x8011cc,%rsi
  800a3d:	00 00 00 
  800a40:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a44:	85 c0                	test   %eax,%eax
  800a46:	0f 8f f2 fb ff ff    	jg     80063e <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4c:	48 bb cd 11 80 00 00 	movabs $0x8011cd,%rbx
  800a53:	00 00 00 
  800a56:	b8 28 00 00 00       	mov    $0x28,%eax
  800a5b:	bf 28 00 00 00       	mov    $0x28,%edi
  800a60:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a64:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a68:	e9 2c fc ff ff       	jmpq   800699 <vprintfmt+0x2f7>
}
  800a6d:	48 83 c4 48          	add    $0x48,%rsp
  800a71:	5b                   	pop    %rbx
  800a72:	41 5c                	pop    %r12
  800a74:	41 5d                	pop    %r13
  800a76:	41 5e                	pop    %r14
  800a78:	41 5f                	pop    %r15
  800a7a:	5d                   	pop    %rbp
  800a7b:	c3                   	retq   

0000000000800a7c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a7c:	55                   	push   %rbp
  800a7d:	48 89 e5             	mov    %rsp,%rbp
  800a80:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a84:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a88:	48 63 c6             	movslq %esi,%rax
  800a8b:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a90:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a9b:	48 85 ff             	test   %rdi,%rdi
  800a9e:	74 2a                	je     800aca <vsnprintf+0x4e>
  800aa0:	85 f6                	test   %esi,%esi
  800aa2:	7e 26                	jle    800aca <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800aa4:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800aa8:	48 bf 04 03 80 00 00 	movabs $0x800304,%rdi
  800aaf:	00 00 00 
  800ab2:	48 b8 a2 03 80 00 00 	movabs $0x8003a2,%rax
  800ab9:	00 00 00 
  800abc:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800abe:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ac2:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ac5:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ac8:	c9                   	leaveq 
  800ac9:	c3                   	retq   
    return -E_INVAL;
  800aca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800acf:	eb f7                	jmp    800ac8 <vsnprintf+0x4c>

0000000000800ad1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ad1:	55                   	push   %rbp
  800ad2:	48 89 e5             	mov    %rsp,%rbp
  800ad5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800adc:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ae3:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800aea:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800af1:	84 c0                	test   %al,%al
  800af3:	74 20                	je     800b15 <snprintf+0x44>
  800af5:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800af9:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800afd:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b01:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b05:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b09:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b0d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b11:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b15:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b1c:	00 00 00 
  800b1f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b26:	00 00 00 
  800b29:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b2d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b34:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b3b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b42:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b49:	48 b8 7c 0a 80 00 00 	movabs $0x800a7c,%rax
  800b50:	00 00 00 
  800b53:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b55:	c9                   	leaveq 
  800b56:	c3                   	retq   

0000000000800b57 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b57:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b5a:	74 17                	je     800b73 <strlen+0x1c>
  800b5c:	48 89 fa             	mov    %rdi,%rdx
  800b5f:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b64:	29 f9                	sub    %edi,%ecx
    n++;
  800b66:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b69:	48 83 c2 01          	add    $0x1,%rdx
  800b6d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b70:	75 f4                	jne    800b66 <strlen+0xf>
  800b72:	c3                   	retq   
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b78:	c3                   	retq   

0000000000800b79 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b79:	48 85 f6             	test   %rsi,%rsi
  800b7c:	74 24                	je     800ba2 <strnlen+0x29>
  800b7e:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b81:	74 25                	je     800ba8 <strnlen+0x2f>
  800b83:	48 01 fe             	add    %rdi,%rsi
  800b86:	48 89 fa             	mov    %rdi,%rdx
  800b89:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b8e:	29 f9                	sub    %edi,%ecx
    n++;
  800b90:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b93:	48 83 c2 01          	add    $0x1,%rdx
  800b97:	48 39 f2             	cmp    %rsi,%rdx
  800b9a:	74 11                	je     800bad <strnlen+0x34>
  800b9c:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b9f:	75 ef                	jne    800b90 <strnlen+0x17>
  800ba1:	c3                   	retq   
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	c3                   	retq   
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800bad:	c3                   	retq   

0000000000800bae <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800bae:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bba:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bbd:	48 83 c2 01          	add    $0x1,%rdx
  800bc1:	84 c9                	test   %cl,%cl
  800bc3:	75 f1                	jne    800bb6 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bc5:	c3                   	retq   

0000000000800bc6 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bc6:	55                   	push   %rbp
  800bc7:	48 89 e5             	mov    %rsp,%rbp
  800bca:	41 54                	push   %r12
  800bcc:	53                   	push   %rbx
  800bcd:	48 89 fb             	mov    %rdi,%rbx
  800bd0:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bd3:	48 b8 57 0b 80 00 00 	movabs $0x800b57,%rax
  800bda:	00 00 00 
  800bdd:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bdf:	48 63 f8             	movslq %eax,%rdi
  800be2:	48 01 df             	add    %rbx,%rdi
  800be5:	4c 89 e6             	mov    %r12,%rsi
  800be8:	48 b8 ae 0b 80 00 00 	movabs $0x800bae,%rax
  800bef:	00 00 00 
  800bf2:	ff d0                	callq  *%rax
  return dst;
}
  800bf4:	48 89 d8             	mov    %rbx,%rax
  800bf7:	5b                   	pop    %rbx
  800bf8:	41 5c                	pop    %r12
  800bfa:	5d                   	pop    %rbp
  800bfb:	c3                   	retq   

0000000000800bfc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bfc:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bff:	48 85 d2             	test   %rdx,%rdx
  800c02:	74 1f                	je     800c23 <strncpy+0x27>
  800c04:	48 01 fa             	add    %rdi,%rdx
  800c07:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c0a:	48 83 c1 01          	add    $0x1,%rcx
  800c0e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c12:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c16:	41 80 f8 01          	cmp    $0x1,%r8b
  800c1a:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c1e:	48 39 ca             	cmp    %rcx,%rdx
  800c21:	75 e7                	jne    800c0a <strncpy+0xe>
  }
  return ret;
}
  800c23:	c3                   	retq   

0000000000800c24 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c24:	48 89 f8             	mov    %rdi,%rax
  800c27:	48 85 d2             	test   %rdx,%rdx
  800c2a:	74 36                	je     800c62 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c2c:	48 83 fa 01          	cmp    $0x1,%rdx
  800c30:	74 2d                	je     800c5f <strlcpy+0x3b>
  800c32:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c36:	45 84 c0             	test   %r8b,%r8b
  800c39:	74 24                	je     800c5f <strlcpy+0x3b>
  800c3b:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c3f:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c44:	48 83 c0 01          	add    $0x1,%rax
  800c48:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c4c:	48 39 d1             	cmp    %rdx,%rcx
  800c4f:	74 0e                	je     800c5f <strlcpy+0x3b>
  800c51:	48 83 c1 01          	add    $0x1,%rcx
  800c55:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c5a:	45 84 c0             	test   %r8b,%r8b
  800c5d:	75 e5                	jne    800c44 <strlcpy+0x20>
    *dst = '\0';
  800c5f:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c62:	48 29 f8             	sub    %rdi,%rax
}
  800c65:	c3                   	retq   

0000000000800c66 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c66:	0f b6 07             	movzbl (%rdi),%eax
  800c69:	84 c0                	test   %al,%al
  800c6b:	74 17                	je     800c84 <strcmp+0x1e>
  800c6d:	3a 06                	cmp    (%rsi),%al
  800c6f:	75 13                	jne    800c84 <strcmp+0x1e>
    p++, q++;
  800c71:	48 83 c7 01          	add    $0x1,%rdi
  800c75:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c79:	0f b6 07             	movzbl (%rdi),%eax
  800c7c:	84 c0                	test   %al,%al
  800c7e:	74 04                	je     800c84 <strcmp+0x1e>
  800c80:	3a 06                	cmp    (%rsi),%al
  800c82:	74 ed                	je     800c71 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c84:	0f b6 c0             	movzbl %al,%eax
  800c87:	0f b6 16             	movzbl (%rsi),%edx
  800c8a:	29 d0                	sub    %edx,%eax
}
  800c8c:	c3                   	retq   

0000000000800c8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c8d:	48 85 d2             	test   %rdx,%rdx
  800c90:	74 2f                	je     800cc1 <strncmp+0x34>
  800c92:	0f b6 07             	movzbl (%rdi),%eax
  800c95:	84 c0                	test   %al,%al
  800c97:	74 1f                	je     800cb8 <strncmp+0x2b>
  800c99:	3a 06                	cmp    (%rsi),%al
  800c9b:	75 1b                	jne    800cb8 <strncmp+0x2b>
  800c9d:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800ca0:	48 83 c7 01          	add    $0x1,%rdi
  800ca4:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ca8:	48 39 d7             	cmp    %rdx,%rdi
  800cab:	74 1a                	je     800cc7 <strncmp+0x3a>
  800cad:	0f b6 07             	movzbl (%rdi),%eax
  800cb0:	84 c0                	test   %al,%al
  800cb2:	74 04                	je     800cb8 <strncmp+0x2b>
  800cb4:	3a 06                	cmp    (%rsi),%al
  800cb6:	74 e8                	je     800ca0 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800cb8:	0f b6 07             	movzbl (%rdi),%eax
  800cbb:	0f b6 16             	movzbl (%rsi),%edx
  800cbe:	29 d0                	sub    %edx,%eax
}
  800cc0:	c3                   	retq   
    return 0;
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	c3                   	retq   
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccc:	c3                   	retq   

0000000000800ccd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800ccd:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ccf:	0f b6 07             	movzbl (%rdi),%eax
  800cd2:	84 c0                	test   %al,%al
  800cd4:	74 1e                	je     800cf4 <strchr+0x27>
    if (*s == c)
  800cd6:	40 38 c6             	cmp    %al,%sil
  800cd9:	74 1f                	je     800cfa <strchr+0x2d>
  for (; *s; s++)
  800cdb:	48 83 c7 01          	add    $0x1,%rdi
  800cdf:	0f b6 07             	movzbl (%rdi),%eax
  800ce2:	84 c0                	test   %al,%al
  800ce4:	74 08                	je     800cee <strchr+0x21>
    if (*s == c)
  800ce6:	38 d0                	cmp    %dl,%al
  800ce8:	75 f1                	jne    800cdb <strchr+0xe>
  for (; *s; s++)
  800cea:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ced:	c3                   	retq   
  return 0;
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf3:	c3                   	retq   
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf9:	c3                   	retq   
    if (*s == c)
  800cfa:	48 89 f8             	mov    %rdi,%rax
  800cfd:	c3                   	retq   

0000000000800cfe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cfe:	48 89 f8             	mov    %rdi,%rax
  800d01:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d03:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d06:	40 38 f2             	cmp    %sil,%dl
  800d09:	74 13                	je     800d1e <strfind+0x20>
  800d0b:	84 d2                	test   %dl,%dl
  800d0d:	74 0f                	je     800d1e <strfind+0x20>
  for (; *s; s++)
  800d0f:	48 83 c0 01          	add    $0x1,%rax
  800d13:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d16:	38 ca                	cmp    %cl,%dl
  800d18:	74 04                	je     800d1e <strfind+0x20>
  800d1a:	84 d2                	test   %dl,%dl
  800d1c:	75 f1                	jne    800d0f <strfind+0x11>
      break;
  return (char *)s;
}
  800d1e:	c3                   	retq   

0000000000800d1f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d1f:	48 85 d2             	test   %rdx,%rdx
  800d22:	74 3a                	je     800d5e <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d24:	48 89 f8             	mov    %rdi,%rax
  800d27:	48 09 d0             	or     %rdx,%rax
  800d2a:	a8 03                	test   $0x3,%al
  800d2c:	75 28                	jne    800d56 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d2e:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d32:	89 f0                	mov    %esi,%eax
  800d34:	c1 e0 08             	shl    $0x8,%eax
  800d37:	89 f1                	mov    %esi,%ecx
  800d39:	c1 e1 18             	shl    $0x18,%ecx
  800d3c:	41 89 f0             	mov    %esi,%r8d
  800d3f:	41 c1 e0 10          	shl    $0x10,%r8d
  800d43:	44 09 c1             	or     %r8d,%ecx
  800d46:	09 ce                	or     %ecx,%esi
  800d48:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d4a:	48 c1 ea 02          	shr    $0x2,%rdx
  800d4e:	48 89 d1             	mov    %rdx,%rcx
  800d51:	fc                   	cld    
  800d52:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d54:	eb 08                	jmp    800d5e <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d56:	89 f0                	mov    %esi,%eax
  800d58:	48 89 d1             	mov    %rdx,%rcx
  800d5b:	fc                   	cld    
  800d5c:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d5e:	48 89 f8             	mov    %rdi,%rax
  800d61:	c3                   	retq   

0000000000800d62 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d62:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d65:	48 39 fe             	cmp    %rdi,%rsi
  800d68:	73 40                	jae    800daa <memmove+0x48>
  800d6a:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d6e:	48 39 f9             	cmp    %rdi,%rcx
  800d71:	76 37                	jbe    800daa <memmove+0x48>
    s += n;
    d += n;
  800d73:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d77:	48 89 fe             	mov    %rdi,%rsi
  800d7a:	48 09 d6             	or     %rdx,%rsi
  800d7d:	48 09 ce             	or     %rcx,%rsi
  800d80:	40 f6 c6 03          	test   $0x3,%sil
  800d84:	75 14                	jne    800d9a <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d86:	48 83 ef 04          	sub    $0x4,%rdi
  800d8a:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d8e:	48 c1 ea 02          	shr    $0x2,%rdx
  800d92:	48 89 d1             	mov    %rdx,%rcx
  800d95:	fd                   	std    
  800d96:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d98:	eb 0e                	jmp    800da8 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d9a:	48 83 ef 01          	sub    $0x1,%rdi
  800d9e:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800da2:	48 89 d1             	mov    %rdx,%rcx
  800da5:	fd                   	std    
  800da6:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800da8:	fc                   	cld    
  800da9:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800daa:	48 89 c1             	mov    %rax,%rcx
  800dad:	48 09 d1             	or     %rdx,%rcx
  800db0:	48 09 f1             	or     %rsi,%rcx
  800db3:	f6 c1 03             	test   $0x3,%cl
  800db6:	75 0e                	jne    800dc6 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800db8:	48 c1 ea 02          	shr    $0x2,%rdx
  800dbc:	48 89 d1             	mov    %rdx,%rcx
  800dbf:	48 89 c7             	mov    %rax,%rdi
  800dc2:	fc                   	cld    
  800dc3:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dc5:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800dc6:	48 89 c7             	mov    %rax,%rdi
  800dc9:	48 89 d1             	mov    %rdx,%rcx
  800dcc:	fc                   	cld    
  800dcd:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dcf:	c3                   	retq   

0000000000800dd0 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dd0:	55                   	push   %rbp
  800dd1:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dd4:	48 b8 62 0d 80 00 00 	movabs $0x800d62,%rax
  800ddb:	00 00 00 
  800dde:	ff d0                	callq  *%rax
}
  800de0:	5d                   	pop    %rbp
  800de1:	c3                   	retq   

0000000000800de2 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800de2:	55                   	push   %rbp
  800de3:	48 89 e5             	mov    %rsp,%rbp
  800de6:	41 57                	push   %r15
  800de8:	41 56                	push   %r14
  800dea:	41 55                	push   %r13
  800dec:	41 54                	push   %r12
  800dee:	53                   	push   %rbx
  800def:	48 83 ec 08          	sub    $0x8,%rsp
  800df3:	49 89 fe             	mov    %rdi,%r14
  800df6:	49 89 f7             	mov    %rsi,%r15
  800df9:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800dfc:	48 89 f7             	mov    %rsi,%rdi
  800dff:	48 b8 57 0b 80 00 00 	movabs $0x800b57,%rax
  800e06:	00 00 00 
  800e09:	ff d0                	callq  *%rax
  800e0b:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e0e:	4c 89 ee             	mov    %r13,%rsi
  800e11:	4c 89 f7             	mov    %r14,%rdi
  800e14:	48 b8 79 0b 80 00 00 	movabs $0x800b79,%rax
  800e1b:	00 00 00 
  800e1e:	ff d0                	callq  *%rax
  800e20:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e23:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e27:	4d 39 e5             	cmp    %r12,%r13
  800e2a:	74 26                	je     800e52 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e2c:	4c 89 e8             	mov    %r13,%rax
  800e2f:	4c 29 e0             	sub    %r12,%rax
  800e32:	48 39 d8             	cmp    %rbx,%rax
  800e35:	76 2a                	jbe    800e61 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e37:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e3b:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e3f:	4c 89 fe             	mov    %r15,%rsi
  800e42:	48 b8 d0 0d 80 00 00 	movabs $0x800dd0,%rax
  800e49:	00 00 00 
  800e4c:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e4e:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e52:	48 83 c4 08          	add    $0x8,%rsp
  800e56:	5b                   	pop    %rbx
  800e57:	41 5c                	pop    %r12
  800e59:	41 5d                	pop    %r13
  800e5b:	41 5e                	pop    %r14
  800e5d:	41 5f                	pop    %r15
  800e5f:	5d                   	pop    %rbp
  800e60:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e61:	49 83 ed 01          	sub    $0x1,%r13
  800e65:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e69:	4c 89 ea             	mov    %r13,%rdx
  800e6c:	4c 89 fe             	mov    %r15,%rsi
  800e6f:	48 b8 d0 0d 80 00 00 	movabs $0x800dd0,%rax
  800e76:	00 00 00 
  800e79:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e7b:	4d 01 ee             	add    %r13,%r14
  800e7e:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e83:	eb c9                	jmp    800e4e <strlcat+0x6c>

0000000000800e85 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e85:	48 85 d2             	test   %rdx,%rdx
  800e88:	74 3a                	je     800ec4 <memcmp+0x3f>
    if (*s1 != *s2)
  800e8a:	0f b6 0f             	movzbl (%rdi),%ecx
  800e8d:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e91:	44 38 c1             	cmp    %r8b,%cl
  800e94:	75 1d                	jne    800eb3 <memcmp+0x2e>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e9b:	48 39 d0             	cmp    %rdx,%rax
  800e9e:	74 1e                	je     800ebe <memcmp+0x39>
    if (*s1 != *s2)
  800ea0:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ea4:	48 83 c0 01          	add    $0x1,%rax
  800ea8:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800eae:	44 38 c1             	cmp    %r8b,%cl
  800eb1:	74 e8                	je     800e9b <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800eb3:	0f b6 c1             	movzbl %cl,%eax
  800eb6:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eba:	44 29 c0             	sub    %r8d,%eax
  800ebd:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	c3                   	retq   
  800ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec9:	c3                   	retq   

0000000000800eca <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800eca:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ece:	48 39 c7             	cmp    %rax,%rdi
  800ed1:	73 19                	jae    800eec <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed3:	89 f2                	mov    %esi,%edx
  800ed5:	40 38 37             	cmp    %sil,(%rdi)
  800ed8:	74 16                	je     800ef0 <memfind+0x26>
  for (; s < ends; s++)
  800eda:	48 83 c7 01          	add    $0x1,%rdi
  800ede:	48 39 f8             	cmp    %rdi,%rax
  800ee1:	74 08                	je     800eeb <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee3:	38 17                	cmp    %dl,(%rdi)
  800ee5:	75 f3                	jne    800eda <memfind+0x10>
  for (; s < ends; s++)
  800ee7:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800eea:	c3                   	retq   
  800eeb:	c3                   	retq   
  for (; s < ends; s++)
  800eec:	48 89 f8             	mov    %rdi,%rax
  800eef:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ef0:	48 89 f8             	mov    %rdi,%rax
  800ef3:	c3                   	retq   

0000000000800ef4 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ef4:	0f b6 07             	movzbl (%rdi),%eax
  800ef7:	3c 20                	cmp    $0x20,%al
  800ef9:	74 04                	je     800eff <strtol+0xb>
  800efb:	3c 09                	cmp    $0x9,%al
  800efd:	75 0f                	jne    800f0e <strtol+0x1a>
    s++;
  800eff:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f03:	0f b6 07             	movzbl (%rdi),%eax
  800f06:	3c 20                	cmp    $0x20,%al
  800f08:	74 f5                	je     800eff <strtol+0xb>
  800f0a:	3c 09                	cmp    $0x9,%al
  800f0c:	74 f1                	je     800eff <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f0e:	3c 2b                	cmp    $0x2b,%al
  800f10:	74 2b                	je     800f3d <strtol+0x49>
  int neg  = 0;
  800f12:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f18:	3c 2d                	cmp    $0x2d,%al
  800f1a:	74 2d                	je     800f49 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1c:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f22:	75 0f                	jne    800f33 <strtol+0x3f>
  800f24:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f27:	74 2c                	je     800f55 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f29:	85 d2                	test   %edx,%edx
  800f2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f30:	0f 44 d0             	cmove  %eax,%edx
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f38:	4c 63 d2             	movslq %edx,%r10
  800f3b:	eb 5c                	jmp    800f99 <strtol+0xa5>
    s++;
  800f3d:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f41:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f47:	eb d3                	jmp    800f1c <strtol+0x28>
    s++, neg = 1;
  800f49:	48 83 c7 01          	add    $0x1,%rdi
  800f4d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f53:	eb c7                	jmp    800f1c <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f55:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f59:	74 0f                	je     800f6a <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f5b:	85 d2                	test   %edx,%edx
  800f5d:	75 d4                	jne    800f33 <strtol+0x3f>
    s++, base = 8;
  800f5f:	48 83 c7 01          	add    $0x1,%rdi
  800f63:	ba 08 00 00 00       	mov    $0x8,%edx
  800f68:	eb c9                	jmp    800f33 <strtol+0x3f>
    s += 2, base = 16;
  800f6a:	48 83 c7 02          	add    $0x2,%rdi
  800f6e:	ba 10 00 00 00       	mov    $0x10,%edx
  800f73:	eb be                	jmp    800f33 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f75:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f79:	41 80 f8 19          	cmp    $0x19,%r8b
  800f7d:	77 2f                	ja     800fae <strtol+0xba>
      dig = *s - 'a' + 10;
  800f7f:	44 0f be c1          	movsbl %cl,%r8d
  800f83:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f87:	39 d1                	cmp    %edx,%ecx
  800f89:	7d 37                	jge    800fc2 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f8b:	48 83 c7 01          	add    $0x1,%rdi
  800f8f:	49 0f af c2          	imul   %r10,%rax
  800f93:	48 63 c9             	movslq %ecx,%rcx
  800f96:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f99:	0f b6 0f             	movzbl (%rdi),%ecx
  800f9c:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800fa0:	41 80 f8 09          	cmp    $0x9,%r8b
  800fa4:	77 cf                	ja     800f75 <strtol+0x81>
      dig = *s - '0';
  800fa6:	0f be c9             	movsbl %cl,%ecx
  800fa9:	83 e9 30             	sub    $0x30,%ecx
  800fac:	eb d9                	jmp    800f87 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fae:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fb2:	41 80 f8 19          	cmp    $0x19,%r8b
  800fb6:	77 0a                	ja     800fc2 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fb8:	44 0f be c1          	movsbl %cl,%r8d
  800fbc:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fc0:	eb c5                	jmp    800f87 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fc2:	48 85 f6             	test   %rsi,%rsi
  800fc5:	74 03                	je     800fca <strtol+0xd6>
    *endptr = (char *)s;
  800fc7:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fca:	48 89 c2             	mov    %rax,%rdx
  800fcd:	48 f7 da             	neg    %rdx
  800fd0:	45 85 c9             	test   %r9d,%r9d
  800fd3:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fd7:	c3                   	retq   

0000000000800fd8 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fd8:	55                   	push   %rbp
  800fd9:	48 89 e5             	mov    %rsp,%rbp
  800fdc:	53                   	push   %rbx
  800fdd:	48 89 fa             	mov    %rdi,%rdx
  800fe0:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	48 89 c3             	mov    %rax,%rbx
  800feb:	48 89 c7             	mov    %rax,%rdi
  800fee:	48 89 c6             	mov    %rax,%rsi
  800ff1:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800ff3:	5b                   	pop    %rbx
  800ff4:	5d                   	pop    %rbp
  800ff5:	c3                   	retq   

0000000000800ff6 <sys_cgetc>:

int
sys_cgetc(void) {
  800ff6:	55                   	push   %rbp
  800ff7:	48 89 e5             	mov    %rsp,%rbp
  800ffa:	53                   	push   %rbx
  asm volatile("int %1\n"
  800ffb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801000:	b8 01 00 00 00       	mov    $0x1,%eax
  801005:	48 89 ca             	mov    %rcx,%rdx
  801008:	48 89 cb             	mov    %rcx,%rbx
  80100b:	48 89 cf             	mov    %rcx,%rdi
  80100e:	48 89 ce             	mov    %rcx,%rsi
  801011:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801013:	5b                   	pop    %rbx
  801014:	5d                   	pop    %rbp
  801015:	c3                   	retq   

0000000000801016 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801016:	55                   	push   %rbp
  801017:	48 89 e5             	mov    %rsp,%rbp
  80101a:	53                   	push   %rbx
  80101b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80101f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801022:	be 00 00 00 00       	mov    $0x0,%esi
  801027:	b8 03 00 00 00       	mov    $0x3,%eax
  80102c:	48 89 f1             	mov    %rsi,%rcx
  80102f:	48 89 f3             	mov    %rsi,%rbx
  801032:	48 89 f7             	mov    %rsi,%rdi
  801035:	cd 30                	int    $0x30
  if (check && ret > 0)
  801037:	48 85 c0             	test   %rax,%rax
  80103a:	7f 07                	jg     801043 <sys_env_destroy+0x2d>
}
  80103c:	48 83 c4 08          	add    $0x8,%rsp
  801040:	5b                   	pop    %rbx
  801041:	5d                   	pop    %rbp
  801042:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801043:	49 89 c0             	mov    %rax,%r8
  801046:	b9 03 00 00 00       	mov    $0x3,%ecx
  80104b:	48 ba 70 15 80 00 00 	movabs $0x801570,%rdx
  801052:	00 00 00 
  801055:	be 22 00 00 00       	mov    $0x22,%esi
  80105a:	48 bf 8f 15 80 00 00 	movabs $0x80158f,%rdi
  801061:	00 00 00 
  801064:	b8 00 00 00 00       	mov    $0x0,%eax
  801069:	49 b9 96 10 80 00 00 	movabs $0x801096,%r9
  801070:	00 00 00 
  801073:	41 ff d1             	callq  *%r9

0000000000801076 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801076:	55                   	push   %rbp
  801077:	48 89 e5             	mov    %rsp,%rbp
  80107a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80107b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801080:	b8 02 00 00 00       	mov    $0x2,%eax
  801085:	48 89 ca             	mov    %rcx,%rdx
  801088:	48 89 cb             	mov    %rcx,%rbx
  80108b:	48 89 cf             	mov    %rcx,%rdi
  80108e:	48 89 ce             	mov    %rcx,%rsi
  801091:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801093:	5b                   	pop    %rbx
  801094:	5d                   	pop    %rbp
  801095:	c3                   	retq   

0000000000801096 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801096:	55                   	push   %rbp
  801097:	48 89 e5             	mov    %rsp,%rbp
  80109a:	41 56                	push   %r14
  80109c:	41 55                	push   %r13
  80109e:	41 54                	push   %r12
  8010a0:	53                   	push   %rbx
  8010a1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8010a8:	49 89 fd             	mov    %rdi,%r13
  8010ab:	41 89 f6             	mov    %esi,%r14d
  8010ae:	49 89 d4             	mov    %rdx,%r12
  8010b1:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8010b8:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010bf:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010c6:	84 c0                	test   %al,%al
  8010c8:	74 26                	je     8010f0 <_panic+0x5a>
  8010ca:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010d1:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010d8:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010dc:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010e0:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010e4:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010e8:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010ec:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010f0:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010f7:	00 00 00 
  8010fa:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801101:	00 00 00 
  801104:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801108:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80110f:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801116:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80111d:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  801124:	00 00 00 
  801127:	48 8b 18             	mov    (%rax),%rbx
  80112a:	48 b8 76 10 80 00 00 	movabs $0x801076,%rax
  801131:	00 00 00 
  801134:	ff d0                	callq  *%rax
  801136:	45 89 f0             	mov    %r14d,%r8d
  801139:	4c 89 e9             	mov    %r13,%rcx
  80113c:	48 89 da             	mov    %rbx,%rdx
  80113f:	89 c6                	mov    %eax,%esi
  801141:	48 bf a0 15 80 00 00 	movabs $0x8015a0,%rdi
  801148:	00 00 00 
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
  801150:	48 bb e4 01 80 00 00 	movabs $0x8001e4,%rbx
  801157:	00 00 00 
  80115a:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80115c:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801163:	4c 89 e7             	mov    %r12,%rdi
  801166:	48 b8 7c 01 80 00 00 	movabs $0x80017c,%rax
  80116d:	00 00 00 
  801170:	ff d0                	callq  *%rax
  cprintf("\n");
  801172:	48 bf af 11 80 00 00 	movabs $0x8011af,%rdi
  801179:	00 00 00 
  80117c:	b8 00 00 00 00       	mov    $0x0,%eax
  801181:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801183:	cc                   	int3   
  while (1)
  801184:	eb fd                	jmp    801183 <_panic+0xed>
  801186:	66 90                	xchg   %ax,%ax
