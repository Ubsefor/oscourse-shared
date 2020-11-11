
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
  800033:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  80003a:	00 00 00 
  80003d:	b8 00 00 00 00       	mov    $0x0,%eax
  800042:	48 ba 9f 01 80 00 00 	movabs $0x80019f,%rdx
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

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80009d:	45 85 ed             	test   %r13d,%r13d
  8000a0:	7e 0d                	jle    8000af <libmain+0x5f>
    binaryname = argv[0];
  8000a2:	49 8b 06             	mov    (%r14),%rax
  8000a5:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000ac:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000af:	4c 89 f6             	mov    %r14,%rsi
  8000b2:	44 89 ef             	mov    %r13d,%edi
  8000b5:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000bc:	00 00 00 
  8000bf:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000c1:	48 b8 d6 00 80 00 00 	movabs $0x8000d6,%rax
  8000c8:	00 00 00 
  8000cb:	ff d0                	callq  *%rax
#endif
}
  8000cd:	5b                   	pop    %rbx
  8000ce:	41 5c                	pop    %r12
  8000d0:	41 5d                	pop    %r13
  8000d2:	41 5e                	pop    %r14
  8000d4:	5d                   	pop    %rbp
  8000d5:	c3                   	retq   

00000000008000d6 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000d6:	55                   	push   %rbp
  8000d7:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000da:	bf 00 00 00 00       	mov    $0x0,%edi
  8000df:	48 b8 d1 0f 80 00 00 	movabs $0x800fd1,%rax
  8000e6:	00 00 00 
  8000e9:	ff d0                	callq  *%rax
}
  8000eb:	5d                   	pop    %rbp
  8000ec:	c3                   	retq   

00000000008000ed <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8000ed:	55                   	push   %rbp
  8000ee:	48 89 e5             	mov    %rsp,%rbp
  8000f1:	53                   	push   %rbx
  8000f2:	48 83 ec 08          	sub    $0x8,%rsp
  8000f6:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8000f9:	8b 06                	mov    (%rsi),%eax
  8000fb:	8d 50 01             	lea    0x1(%rax),%edx
  8000fe:	89 16                	mov    %edx,(%rsi)
  800100:	48 98                	cltq   
  800102:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800107:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80010d:	74 0b                	je     80011a <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80010f:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800113:	48 83 c4 08          	add    $0x8,%rsp
  800117:	5b                   	pop    %rbx
  800118:	5d                   	pop    %rbp
  800119:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80011a:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80011e:	be ff 00 00 00       	mov    $0xff,%esi
  800123:	48 b8 93 0f 80 00 00 	movabs $0x800f93,%rax
  80012a:	00 00 00 
  80012d:	ff d0                	callq  *%rax
    b->idx = 0;
  80012f:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800135:	eb d8                	jmp    80010f <putch+0x22>

0000000000800137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800137:	55                   	push   %rbp
  800138:	48 89 e5             	mov    %rsp,%rbp
  80013b:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800142:	48 89 fa             	mov    %rdi,%rdx
  800145:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80014f:	00 00 00 
  b.cnt = 0;
  800152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800159:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80015c:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800163:	48 bf ed 00 80 00 00 	movabs $0x8000ed,%rdi
  80016a:	00 00 00 
  80016d:	48 b8 5d 03 80 00 00 	movabs $0x80035d,%rax
  800174:	00 00 00 
  800177:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800179:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800180:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800187:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80018b:	48 b8 93 0f 80 00 00 	movabs $0x800f93,%rax
  800192:	00 00 00 
  800195:	ff d0                	callq  *%rax

  return b.cnt;
}
  800197:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80019d:	c9                   	leaveq 
  80019e:	c3                   	retq   

000000000080019f <cprintf>:

int
cprintf(const char *fmt, ...) {
  80019f:	55                   	push   %rbp
  8001a0:	48 89 e5             	mov    %rsp,%rbp
  8001a3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001aa:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001b1:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001b8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001bf:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001c6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001cd:	84 c0                	test   %al,%al
  8001cf:	74 20                	je     8001f1 <cprintf+0x52>
  8001d1:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8001d5:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8001d9:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8001dd:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8001e1:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8001e5:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8001e9:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8001ed:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8001f1:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8001f8:	00 00 00 
  8001fb:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800202:	00 00 00 
  800205:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800209:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800210:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800217:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80021e:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800225:	48 b8 37 01 80 00 00 	movabs $0x800137,%rax
  80022c:	00 00 00 
  80022f:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800231:	c9                   	leaveq 
  800232:	c3                   	retq   

0000000000800233 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800233:	55                   	push   %rbp
  800234:	48 89 e5             	mov    %rsp,%rbp
  800237:	41 57                	push   %r15
  800239:	41 56                	push   %r14
  80023b:	41 55                	push   %r13
  80023d:	41 54                	push   %r12
  80023f:	53                   	push   %rbx
  800240:	48 83 ec 18          	sub    $0x18,%rsp
  800244:	49 89 fc             	mov    %rdi,%r12
  800247:	49 89 f5             	mov    %rsi,%r13
  80024a:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80024e:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800251:	41 89 cf             	mov    %ecx,%r15d
  800254:	49 39 d7             	cmp    %rdx,%r15
  800257:	76 45                	jbe    80029e <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800259:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	7e 0e                	jle    80026f <printnum+0x3c>
      putch(padc, putdat);
  800261:	4c 89 ee             	mov    %r13,%rsi
  800264:	44 89 f7             	mov    %r14d,%edi
  800267:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80026a:	83 eb 01             	sub    $0x1,%ebx
  80026d:	75 f2                	jne    800261 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80026f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	49 f7 f7             	div    %r15
  80027b:	48 b8 6e 11 80 00 00 	movabs $0x80116e,%rax
  800282:	00 00 00 
  800285:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800289:	4c 89 ee             	mov    %r13,%rsi
  80028c:	41 ff d4             	callq  *%r12
}
  80028f:	48 83 c4 18          	add    $0x18,%rsp
  800293:	5b                   	pop    %rbx
  800294:	41 5c                	pop    %r12
  800296:	41 5d                	pop    %r13
  800298:	41 5e                	pop    %r14
  80029a:	41 5f                	pop    %r15
  80029c:	5d                   	pop    %rbp
  80029d:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80029e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	49 f7 f7             	div    %r15
  8002aa:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002ae:	48 89 c2             	mov    %rax,%rdx
  8002b1:	48 b8 33 02 80 00 00 	movabs $0x800233,%rax
  8002b8:	00 00 00 
  8002bb:	ff d0                	callq  *%rax
  8002bd:	eb b0                	jmp    80026f <printnum+0x3c>

00000000008002bf <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002bf:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002c3:	48 8b 06             	mov    (%rsi),%rax
  8002c6:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002ca:	73 0a                	jae    8002d6 <sprintputch+0x17>
    *b->buf++ = ch;
  8002cc:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8002d0:	48 89 16             	mov    %rdx,(%rsi)
  8002d3:	40 88 38             	mov    %dil,(%rax)
}
  8002d6:	c3                   	retq   

00000000008002d7 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8002d7:	55                   	push   %rbp
  8002d8:	48 89 e5             	mov    %rsp,%rbp
  8002db:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002e2:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002e9:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8002f0:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8002f7:	84 c0                	test   %al,%al
  8002f9:	74 20                	je     80031b <printfmt+0x44>
  8002fb:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8002ff:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800303:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800307:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80030b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80030f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800313:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800317:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80031b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800322:	00 00 00 
  800325:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80032c:	00 00 00 
  80032f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800333:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80033a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800341:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800348:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80034f:	48 b8 5d 03 80 00 00 	movabs $0x80035d,%rax
  800356:	00 00 00 
  800359:	ff d0                	callq  *%rax
}
  80035b:	c9                   	leaveq 
  80035c:	c3                   	retq   

000000000080035d <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80035d:	55                   	push   %rbp
  80035e:	48 89 e5             	mov    %rsp,%rbp
  800361:	41 57                	push   %r15
  800363:	41 56                	push   %r14
  800365:	41 55                	push   %r13
  800367:	41 54                	push   %r12
  800369:	53                   	push   %rbx
  80036a:	48 83 ec 48          	sub    $0x48,%rsp
  80036e:	49 89 fd             	mov    %rdi,%r13
  800371:	49 89 f7             	mov    %rsi,%r15
  800374:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800377:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80037b:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80037f:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800383:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800387:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80038b:	41 0f b6 3e          	movzbl (%r14),%edi
  80038f:	83 ff 25             	cmp    $0x25,%edi
  800392:	74 18                	je     8003ac <vprintfmt+0x4f>
      if (ch == '\0')
  800394:	85 ff                	test   %edi,%edi
  800396:	0f 84 8c 06 00 00    	je     800a28 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80039c:	4c 89 fe             	mov    %r15,%rsi
  80039f:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003a2:	49 89 de             	mov    %rbx,%r14
  8003a5:	eb e0                	jmp    800387 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003a7:	49 89 de             	mov    %rbx,%r14
  8003aa:	eb db                	jmp    800387 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003ac:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003b0:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003b4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003bb:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003c1:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003c5:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003ca:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8003d0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8003d6:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8003db:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8003e0:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8003e4:	0f b6 13             	movzbl (%rbx),%edx
  8003e7:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8003ea:	3c 55                	cmp    $0x55,%al
  8003ec:	0f 87 8b 05 00 00    	ja     80097d <vprintfmt+0x620>
  8003f2:	0f b6 c0             	movzbl %al,%eax
  8003f5:	49 bb 20 12 80 00 00 	movabs $0x801220,%r11
  8003fc:	00 00 00 
  8003ff:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800403:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800406:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80040a:	eb d4                	jmp    8003e0 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80040c:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80040f:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800413:	eb cb                	jmp    8003e0 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800415:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800418:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80041c:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800420:	8d 50 d0             	lea    -0x30(%rax),%edx
  800423:	83 fa 09             	cmp    $0x9,%edx
  800426:	77 7e                	ja     8004a6 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800428:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80042c:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800430:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800435:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800439:	8d 50 d0             	lea    -0x30(%rax),%edx
  80043c:	83 fa 09             	cmp    $0x9,%edx
  80043f:	76 e7                	jbe    800428 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800441:	4c 89 f3             	mov    %r14,%rbx
  800444:	eb 19                	jmp    80045f <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800446:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800449:	83 f8 2f             	cmp    $0x2f,%eax
  80044c:	77 2a                	ja     800478 <vprintfmt+0x11b>
  80044e:	89 c2                	mov    %eax,%edx
  800450:	4c 01 d2             	add    %r10,%rdx
  800453:	83 c0 08             	add    $0x8,%eax
  800456:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800459:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80045c:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80045f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800463:	0f 89 77 ff ff ff    	jns    8003e0 <vprintfmt+0x83>
          width = precision, precision = -1;
  800469:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80046d:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800473:	e9 68 ff ff ff       	jmpq   8003e0 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800478:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80047c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800480:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800484:	eb d3                	jmp    800459 <vprintfmt+0xfc>
        if (width < 0)
  800486:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800489:	85 c0                	test   %eax,%eax
  80048b:	41 0f 48 c0          	cmovs  %r8d,%eax
  80048f:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800492:	4c 89 f3             	mov    %r14,%rbx
  800495:	e9 46 ff ff ff       	jmpq   8003e0 <vprintfmt+0x83>
  80049a:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80049d:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004a1:	e9 3a ff ff ff       	jmpq   8003e0 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004a6:	4c 89 f3             	mov    %r14,%rbx
  8004a9:	eb b4                	jmp    80045f <vprintfmt+0x102>
        lflag++;
  8004ab:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004ae:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004b1:	e9 2a ff ff ff       	jmpq   8003e0 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004b9:	83 f8 2f             	cmp    $0x2f,%eax
  8004bc:	77 19                	ja     8004d7 <vprintfmt+0x17a>
  8004be:	89 c2                	mov    %eax,%edx
  8004c0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004c4:	83 c0 08             	add    $0x8,%eax
  8004c7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004ca:	4c 89 fe             	mov    %r15,%rsi
  8004cd:	8b 3a                	mov    (%rdx),%edi
  8004cf:	41 ff d5             	callq  *%r13
        break;
  8004d2:	e9 b0 fe ff ff       	jmpq   800387 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8004d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004e3:	eb e5                	jmp    8004ca <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8004e5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004e8:	83 f8 2f             	cmp    $0x2f,%eax
  8004eb:	77 5b                	ja     800548 <vprintfmt+0x1eb>
  8004ed:	89 c2                	mov    %eax,%edx
  8004ef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004f3:	83 c0 08             	add    $0x8,%eax
  8004f6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004f9:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8004fb:	89 c8                	mov    %ecx,%eax
  8004fd:	c1 f8 1f             	sar    $0x1f,%eax
  800500:	31 c1                	xor    %eax,%ecx
  800502:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800504:	83 f9 09             	cmp    $0x9,%ecx
  800507:	7f 4d                	jg     800556 <vprintfmt+0x1f9>
  800509:	48 63 c1             	movslq %ecx,%rax
  80050c:	48 ba e0 14 80 00 00 	movabs $0x8014e0,%rdx
  800513:	00 00 00 
  800516:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80051a:	48 85 c0             	test   %rax,%rax
  80051d:	74 37                	je     800556 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80051f:	48 89 c1             	mov    %rax,%rcx
  800522:	48 ba 8f 11 80 00 00 	movabs $0x80118f,%rdx
  800529:	00 00 00 
  80052c:	4c 89 fe             	mov    %r15,%rsi
  80052f:	4c 89 ef             	mov    %r13,%rdi
  800532:	b8 00 00 00 00       	mov    $0x0,%eax
  800537:	48 bb d7 02 80 00 00 	movabs $0x8002d7,%rbx
  80053e:	00 00 00 
  800541:	ff d3                	callq  *%rbx
  800543:	e9 3f fe ff ff       	jmpq   800387 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800548:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80054c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800550:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800554:	eb a3                	jmp    8004f9 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800556:	48 ba 86 11 80 00 00 	movabs $0x801186,%rdx
  80055d:	00 00 00 
  800560:	4c 89 fe             	mov    %r15,%rsi
  800563:	4c 89 ef             	mov    %r13,%rdi
  800566:	b8 00 00 00 00       	mov    $0x0,%eax
  80056b:	48 bb d7 02 80 00 00 	movabs $0x8002d7,%rbx
  800572:	00 00 00 
  800575:	ff d3                	callq  *%rbx
  800577:	e9 0b fe ff ff       	jmpq   800387 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80057c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80057f:	83 f8 2f             	cmp    $0x2f,%eax
  800582:	77 4b                	ja     8005cf <vprintfmt+0x272>
  800584:	89 c2                	mov    %eax,%edx
  800586:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80058a:	83 c0 08             	add    $0x8,%eax
  80058d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800590:	48 8b 02             	mov    (%rdx),%rax
  800593:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800597:	48 85 c0             	test   %rax,%rax
  80059a:	0f 84 05 04 00 00    	je     8009a5 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005a0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005a4:	7e 06                	jle    8005ac <vprintfmt+0x24f>
  8005a6:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005aa:	75 31                	jne    8005dd <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ac:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005b0:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005b4:	0f b6 00             	movzbl (%rax),%eax
  8005b7:	0f be f8             	movsbl %al,%edi
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	0f 84 c3 00 00 00    	je     800685 <vprintfmt+0x328>
  8005c2:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005c6:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005ca:	e9 85 00 00 00       	jmpq   800654 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005cf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005d3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005d7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005db:	eb b3                	jmp    800590 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8005dd:	49 63 f4             	movslq %r12d,%rsi
  8005e0:	48 89 c7             	mov    %rax,%rdi
  8005e3:	48 b8 34 0b 80 00 00 	movabs $0x800b34,%rax
  8005ea:	00 00 00 
  8005ed:	ff d0                	callq  *%rax
  8005ef:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8005f2:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8005f5:	85 f6                	test   %esi,%esi
  8005f7:	7e 22                	jle    80061b <vprintfmt+0x2be>
            putch(padc, putdat);
  8005f9:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8005fd:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800601:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800605:	4c 89 fe             	mov    %r15,%rsi
  800608:	89 df                	mov    %ebx,%edi
  80060a:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80060d:	41 83 ec 01          	sub    $0x1,%r12d
  800611:	75 f2                	jne    800605 <vprintfmt+0x2a8>
  800613:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800617:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80061f:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800623:	0f b6 00             	movzbl (%rax),%eax
  800626:	0f be f8             	movsbl %al,%edi
  800629:	85 ff                	test   %edi,%edi
  80062b:	0f 84 56 fd ff ff    	je     800387 <vprintfmt+0x2a>
  800631:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800635:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800639:	eb 19                	jmp    800654 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80063b:	4c 89 fe             	mov    %r15,%rsi
  80063e:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	41 83 ee 01          	sub    $0x1,%r14d
  800645:	48 83 c3 01          	add    $0x1,%rbx
  800649:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80064d:	0f be f8             	movsbl %al,%edi
  800650:	85 ff                	test   %edi,%edi
  800652:	74 29                	je     80067d <vprintfmt+0x320>
  800654:	45 85 e4             	test   %r12d,%r12d
  800657:	78 06                	js     80065f <vprintfmt+0x302>
  800659:	41 83 ec 01          	sub    $0x1,%r12d
  80065d:	78 48                	js     8006a7 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80065f:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800663:	74 d6                	je     80063b <vprintfmt+0x2de>
  800665:	0f be c0             	movsbl %al,%eax
  800668:	83 e8 20             	sub    $0x20,%eax
  80066b:	83 f8 5e             	cmp    $0x5e,%eax
  80066e:	76 cb                	jbe    80063b <vprintfmt+0x2de>
            putch('?', putdat);
  800670:	4c 89 fe             	mov    %r15,%rsi
  800673:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800678:	41 ff d5             	callq  *%r13
  80067b:	eb c4                	jmp    800641 <vprintfmt+0x2e4>
  80067d:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800681:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800685:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800688:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80068c:	0f 8e f5 fc ff ff    	jle    800387 <vprintfmt+0x2a>
          putch(' ', putdat);
  800692:	4c 89 fe             	mov    %r15,%rsi
  800695:	bf 20 00 00 00       	mov    $0x20,%edi
  80069a:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80069d:	83 eb 01             	sub    $0x1,%ebx
  8006a0:	75 f0                	jne    800692 <vprintfmt+0x335>
  8006a2:	e9 e0 fc ff ff       	jmpq   800387 <vprintfmt+0x2a>
  8006a7:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006ab:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006af:	eb d4                	jmp    800685 <vprintfmt+0x328>
  if (lflag >= 2)
  8006b1:	83 f9 01             	cmp    $0x1,%ecx
  8006b4:	7f 1d                	jg     8006d3 <vprintfmt+0x376>
  else if (lflag)
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	74 5e                	je     800718 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006ba:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006bd:	83 f8 2f             	cmp    $0x2f,%eax
  8006c0:	77 48                	ja     80070a <vprintfmt+0x3ad>
  8006c2:	89 c2                	mov    %eax,%edx
  8006c4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006c8:	83 c0 08             	add    $0x8,%eax
  8006cb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006ce:	48 8b 1a             	mov    (%rdx),%rbx
  8006d1:	eb 17                	jmp    8006ea <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8006d3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006d6:	83 f8 2f             	cmp    $0x2f,%eax
  8006d9:	77 21                	ja     8006fc <vprintfmt+0x39f>
  8006db:	89 c2                	mov    %eax,%edx
  8006dd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006e1:	83 c0 08             	add    $0x8,%eax
  8006e4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006e7:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8006ea:	48 85 db             	test   %rbx,%rbx
  8006ed:	78 50                	js     80073f <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8006ef:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8006f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f7:	e9 b4 01 00 00       	jmpq   8008b0 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8006fc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800700:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800704:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800708:	eb dd                	jmp    8006e7 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80070a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80070e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800712:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800716:	eb b6                	jmp    8006ce <vprintfmt+0x371>
    return va_arg(*ap, int);
  800718:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80071b:	83 f8 2f             	cmp    $0x2f,%eax
  80071e:	77 11                	ja     800731 <vprintfmt+0x3d4>
  800720:	89 c2                	mov    %eax,%edx
  800722:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800726:	83 c0 08             	add    $0x8,%eax
  800729:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80072c:	48 63 1a             	movslq (%rdx),%rbx
  80072f:	eb b9                	jmp    8006ea <vprintfmt+0x38d>
  800731:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800735:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800739:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073d:	eb ed                	jmp    80072c <vprintfmt+0x3cf>
          putch('-', putdat);
  80073f:	4c 89 fe             	mov    %r15,%rsi
  800742:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800747:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80074a:	48 89 da             	mov    %rbx,%rdx
  80074d:	48 f7 da             	neg    %rdx
        base = 10;
  800750:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800755:	e9 56 01 00 00       	jmpq   8008b0 <vprintfmt+0x553>
  if (lflag >= 2)
  80075a:	83 f9 01             	cmp    $0x1,%ecx
  80075d:	7f 25                	jg     800784 <vprintfmt+0x427>
  else if (lflag)
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 5e                	je     8007c1 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800763:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800766:	83 f8 2f             	cmp    $0x2f,%eax
  800769:	77 48                	ja     8007b3 <vprintfmt+0x456>
  80076b:	89 c2                	mov    %eax,%edx
  80076d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800771:	83 c0 08             	add    $0x8,%eax
  800774:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800777:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80077a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80077f:	e9 2c 01 00 00       	jmpq   8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800784:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800787:	83 f8 2f             	cmp    $0x2f,%eax
  80078a:	77 19                	ja     8007a5 <vprintfmt+0x448>
  80078c:	89 c2                	mov    %eax,%edx
  80078e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800792:	83 c0 08             	add    $0x8,%eax
  800795:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800798:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80079b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a0:	e9 0b 01 00 00       	jmpq   8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007a5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007a9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ad:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b1:	eb e5                	jmp    800798 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007b3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007b7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007bb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007bf:	eb b6                	jmp    800777 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007c1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c4:	83 f8 2f             	cmp    $0x2f,%eax
  8007c7:	77 18                	ja     8007e1 <vprintfmt+0x484>
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007cf:	83 c0 08             	add    $0x8,%eax
  8007d2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d5:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8007d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007dc:	e9 cf 00 00 00       	jmpq   8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8007e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007ed:	eb e6                	jmp    8007d5 <vprintfmt+0x478>
  if (lflag >= 2)
  8007ef:	83 f9 01             	cmp    $0x1,%ecx
  8007f2:	7f 25                	jg     800819 <vprintfmt+0x4bc>
  else if (lflag)
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 5b                	je     800853 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8007f8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007fb:	83 f8 2f             	cmp    $0x2f,%eax
  8007fe:	77 45                	ja     800845 <vprintfmt+0x4e8>
  800800:	89 c2                	mov    %eax,%edx
  800802:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800806:	83 c0 08             	add    $0x8,%eax
  800809:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80080c:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80080f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800814:	e9 97 00 00 00       	jmpq   8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800819:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80081c:	83 f8 2f             	cmp    $0x2f,%eax
  80081f:	77 16                	ja     800837 <vprintfmt+0x4da>
  800821:	89 c2                	mov    %eax,%edx
  800823:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800827:	83 c0 08             	add    $0x8,%eax
  80082a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80082d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800830:	b9 08 00 00 00       	mov    $0x8,%ecx
  800835:	eb 79                	jmp    8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800837:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80083b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80083f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800843:	eb e8                	jmp    80082d <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800845:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800849:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80084d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800851:	eb b9                	jmp    80080c <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800853:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800856:	83 f8 2f             	cmp    $0x2f,%eax
  800859:	77 15                	ja     800870 <vprintfmt+0x513>
  80085b:	89 c2                	mov    %eax,%edx
  80085d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800861:	83 c0 08             	add    $0x8,%eax
  800864:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800867:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800869:	b9 08 00 00 00       	mov    $0x8,%ecx
  80086e:	eb 40                	jmp    8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800870:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800874:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800878:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80087c:	eb e9                	jmp    800867 <vprintfmt+0x50a>
        putch('0', putdat);
  80087e:	4c 89 fe             	mov    %r15,%rsi
  800881:	bf 30 00 00 00       	mov    $0x30,%edi
  800886:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800889:	4c 89 fe             	mov    %r15,%rsi
  80088c:	bf 78 00 00 00       	mov    $0x78,%edi
  800891:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800894:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800897:	83 f8 2f             	cmp    $0x2f,%eax
  80089a:	77 34                	ja     8008d0 <vprintfmt+0x573>
  80089c:	89 c2                	mov    %eax,%edx
  80089e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a2:	83 c0 08             	add    $0x8,%eax
  8008a5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a8:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008ab:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008b0:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008b5:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008b9:	4c 89 fe             	mov    %r15,%rsi
  8008bc:	4c 89 ef             	mov    %r13,%rdi
  8008bf:	48 b8 33 02 80 00 00 	movabs $0x800233,%rax
  8008c6:	00 00 00 
  8008c9:	ff d0                	callq  *%rax
        break;
  8008cb:	e9 b7 fa ff ff       	jmpq   800387 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008d0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008dc:	eb ca                	jmp    8008a8 <vprintfmt+0x54b>
  if (lflag >= 2)
  8008de:	83 f9 01             	cmp    $0x1,%ecx
  8008e1:	7f 22                	jg     800905 <vprintfmt+0x5a8>
  else if (lflag)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 58                	je     80093f <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8008e7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ea:	83 f8 2f             	cmp    $0x2f,%eax
  8008ed:	77 42                	ja     800931 <vprintfmt+0x5d4>
  8008ef:	89 c2                	mov    %eax,%edx
  8008f1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f5:	83 c0 08             	add    $0x8,%eax
  8008f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fb:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008fe:	b9 10 00 00 00       	mov    $0x10,%ecx
  800903:	eb ab                	jmp    8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800905:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800908:	83 f8 2f             	cmp    $0x2f,%eax
  80090b:	77 16                	ja     800923 <vprintfmt+0x5c6>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800913:	83 c0 08             	add    $0x8,%eax
  800916:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800919:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80091c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800921:	eb 8d                	jmp    8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800923:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800927:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80092b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80092f:	eb e8                	jmp    800919 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800931:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800935:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800939:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80093d:	eb bc                	jmp    8008fb <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  80093f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800942:	83 f8 2f             	cmp    $0x2f,%eax
  800945:	77 18                	ja     80095f <vprintfmt+0x602>
  800947:	89 c2                	mov    %eax,%edx
  800949:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094d:	83 c0 08             	add    $0x8,%eax
  800950:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800953:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800955:	b9 10 00 00 00       	mov    $0x10,%ecx
  80095a:	e9 51 ff ff ff       	jmpq   8008b0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80095f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800963:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800967:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096b:	eb e6                	jmp    800953 <vprintfmt+0x5f6>
        putch(ch, putdat);
  80096d:	4c 89 fe             	mov    %r15,%rsi
  800970:	bf 25 00 00 00       	mov    $0x25,%edi
  800975:	41 ff d5             	callq  *%r13
        break;
  800978:	e9 0a fa ff ff       	jmpq   800387 <vprintfmt+0x2a>
        putch('%', putdat);
  80097d:	4c 89 fe             	mov    %r15,%rsi
  800980:	bf 25 00 00 00       	mov    $0x25,%edi
  800985:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800988:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  80098c:	0f 84 15 fa ff ff    	je     8003a7 <vprintfmt+0x4a>
  800992:	49 89 de             	mov    %rbx,%r14
  800995:	49 83 ee 01          	sub    $0x1,%r14
  800999:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  80099e:	75 f5                	jne    800995 <vprintfmt+0x638>
  8009a0:	e9 e2 f9 ff ff       	jmpq   800387 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009a5:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009a9:	74 06                	je     8009b1 <vprintfmt+0x654>
  8009ab:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009af:	7f 21                	jg     8009d2 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b1:	bf 28 00 00 00       	mov    $0x28,%edi
  8009b6:	48 bb 80 11 80 00 00 	movabs $0x801180,%rbx
  8009bd:	00 00 00 
  8009c0:	b8 28 00 00 00       	mov    $0x28,%eax
  8009c5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009c9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009cd:	e9 82 fc ff ff       	jmpq   800654 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009d2:	49 63 f4             	movslq %r12d,%rsi
  8009d5:	48 bf 7f 11 80 00 00 	movabs $0x80117f,%rdi
  8009dc:	00 00 00 
  8009df:	48 b8 34 0b 80 00 00 	movabs $0x800b34,%rax
  8009e6:	00 00 00 
  8009e9:	ff d0                	callq  *%rax
  8009eb:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8009ee:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  8009f1:	48 be 7f 11 80 00 00 	movabs $0x80117f,%rsi
  8009f8:	00 00 00 
  8009fb:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	0f 8f f2 fb ff ff    	jg     8005f9 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a07:	48 bb 80 11 80 00 00 	movabs $0x801180,%rbx
  800a0e:	00 00 00 
  800a11:	b8 28 00 00 00       	mov    $0x28,%eax
  800a16:	bf 28 00 00 00       	mov    $0x28,%edi
  800a1b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a1f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a23:	e9 2c fc ff ff       	jmpq   800654 <vprintfmt+0x2f7>
}
  800a28:	48 83 c4 48          	add    $0x48,%rsp
  800a2c:	5b                   	pop    %rbx
  800a2d:	41 5c                	pop    %r12
  800a2f:	41 5d                	pop    %r13
  800a31:	41 5e                	pop    %r14
  800a33:	41 5f                	pop    %r15
  800a35:	5d                   	pop    %rbp
  800a36:	c3                   	retq   

0000000000800a37 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a37:	55                   	push   %rbp
  800a38:	48 89 e5             	mov    %rsp,%rbp
  800a3b:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a3f:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a43:	48 63 c6             	movslq %esi,%rax
  800a46:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a4b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a4f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a56:	48 85 ff             	test   %rdi,%rdi
  800a59:	74 2a                	je     800a85 <vsnprintf+0x4e>
  800a5b:	85 f6                	test   %esi,%esi
  800a5d:	7e 26                	jle    800a85 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a5f:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a63:	48 bf bf 02 80 00 00 	movabs $0x8002bf,%rdi
  800a6a:	00 00 00 
  800a6d:	48 b8 5d 03 80 00 00 	movabs $0x80035d,%rax
  800a74:	00 00 00 
  800a77:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800a79:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800a7d:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800a80:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800a83:	c9                   	leaveq 
  800a84:	c3                   	retq   
    return -E_INVAL;
  800a85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a8a:	eb f7                	jmp    800a83 <vsnprintf+0x4c>

0000000000800a8c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800a8c:	55                   	push   %rbp
  800a8d:	48 89 e5             	mov    %rsp,%rbp
  800a90:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800a97:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800a9e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800aa5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800aac:	84 c0                	test   %al,%al
  800aae:	74 20                	je     800ad0 <snprintf+0x44>
  800ab0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ab4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800ab8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800abc:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ac0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ac4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ac8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800acc:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ad0:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ad7:	00 00 00 
  800ada:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ae1:	00 00 00 
  800ae4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800ae8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800aef:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800af6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800afd:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b04:	48 b8 37 0a 80 00 00 	movabs $0x800a37,%rax
  800b0b:	00 00 00 
  800b0e:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b10:	c9                   	leaveq 
  800b11:	c3                   	retq   

0000000000800b12 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b12:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b15:	74 17                	je     800b2e <strlen+0x1c>
  800b17:	48 89 fa             	mov    %rdi,%rdx
  800b1a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b1f:	29 f9                	sub    %edi,%ecx
    n++;
  800b21:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b24:	48 83 c2 01          	add    $0x1,%rdx
  800b28:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b2b:	75 f4                	jne    800b21 <strlen+0xf>
  800b2d:	c3                   	retq   
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b33:	c3                   	retq   

0000000000800b34 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	48 85 f6             	test   %rsi,%rsi
  800b37:	74 24                	je     800b5d <strnlen+0x29>
  800b39:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b3c:	74 25                	je     800b63 <strnlen+0x2f>
  800b3e:	48 01 fe             	add    %rdi,%rsi
  800b41:	48 89 fa             	mov    %rdi,%rdx
  800b44:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b49:	29 f9                	sub    %edi,%ecx
    n++;
  800b4b:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b4e:	48 83 c2 01          	add    $0x1,%rdx
  800b52:	48 39 f2             	cmp    %rsi,%rdx
  800b55:	74 11                	je     800b68 <strnlen+0x34>
  800b57:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b5a:	75 ef                	jne    800b4b <strnlen+0x17>
  800b5c:	c3                   	retq   
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b62:	c3                   	retq   
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b68:	c3                   	retq   

0000000000800b69 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b69:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800b75:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800b78:	48 83 c2 01          	add    $0x1,%rdx
  800b7c:	84 c9                	test   %cl,%cl
  800b7e:	75 f1                	jne    800b71 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800b80:	c3                   	retq   

0000000000800b81 <strcat>:

char *
strcat(char *dst, const char *src) {
  800b81:	55                   	push   %rbp
  800b82:	48 89 e5             	mov    %rsp,%rbp
  800b85:	41 54                	push   %r12
  800b87:	53                   	push   %rbx
  800b88:	48 89 fb             	mov    %rdi,%rbx
  800b8b:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800b8e:	48 b8 12 0b 80 00 00 	movabs $0x800b12,%rax
  800b95:	00 00 00 
  800b98:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800b9a:	48 63 f8             	movslq %eax,%rdi
  800b9d:	48 01 df             	add    %rbx,%rdi
  800ba0:	4c 89 e6             	mov    %r12,%rsi
  800ba3:	48 b8 69 0b 80 00 00 	movabs $0x800b69,%rax
  800baa:	00 00 00 
  800bad:	ff d0                	callq  *%rax
  return dst;
}
  800baf:	48 89 d8             	mov    %rbx,%rax
  800bb2:	5b                   	pop    %rbx
  800bb3:	41 5c                	pop    %r12
  800bb5:	5d                   	pop    %rbp
  800bb6:	c3                   	retq   

0000000000800bb7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bb7:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bba:	48 85 d2             	test   %rdx,%rdx
  800bbd:	74 1f                	je     800bde <strncpy+0x27>
  800bbf:	48 01 fa             	add    %rdi,%rdx
  800bc2:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bc5:	48 83 c1 01          	add    $0x1,%rcx
  800bc9:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bcd:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800bd1:	41 80 f8 01          	cmp    $0x1,%r8b
  800bd5:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800bd9:	48 39 ca             	cmp    %rcx,%rdx
  800bdc:	75 e7                	jne    800bc5 <strncpy+0xe>
  }
  return ret;
}
  800bde:	c3                   	retq   

0000000000800bdf <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800bdf:	48 89 f8             	mov    %rdi,%rax
  800be2:	48 85 d2             	test   %rdx,%rdx
  800be5:	74 36                	je     800c1d <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800be7:	48 83 fa 01          	cmp    $0x1,%rdx
  800beb:	74 2d                	je     800c1a <strlcpy+0x3b>
  800bed:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bf1:	45 84 c0             	test   %r8b,%r8b
  800bf4:	74 24                	je     800c1a <strlcpy+0x3b>
  800bf6:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800bfa:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800bff:	48 83 c0 01          	add    $0x1,%rax
  800c03:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c07:	48 39 d1             	cmp    %rdx,%rcx
  800c0a:	74 0e                	je     800c1a <strlcpy+0x3b>
  800c0c:	48 83 c1 01          	add    $0x1,%rcx
  800c10:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c15:	45 84 c0             	test   %r8b,%r8b
  800c18:	75 e5                	jne    800bff <strlcpy+0x20>
    *dst = '\0';
  800c1a:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c1d:	48 29 f8             	sub    %rdi,%rax
}
  800c20:	c3                   	retq   

0000000000800c21 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c21:	0f b6 07             	movzbl (%rdi),%eax
  800c24:	84 c0                	test   %al,%al
  800c26:	74 17                	je     800c3f <strcmp+0x1e>
  800c28:	3a 06                	cmp    (%rsi),%al
  800c2a:	75 13                	jne    800c3f <strcmp+0x1e>
    p++, q++;
  800c2c:	48 83 c7 01          	add    $0x1,%rdi
  800c30:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c34:	0f b6 07             	movzbl (%rdi),%eax
  800c37:	84 c0                	test   %al,%al
  800c39:	74 04                	je     800c3f <strcmp+0x1e>
  800c3b:	3a 06                	cmp    (%rsi),%al
  800c3d:	74 ed                	je     800c2c <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c3f:	0f b6 c0             	movzbl %al,%eax
  800c42:	0f b6 16             	movzbl (%rsi),%edx
  800c45:	29 d0                	sub    %edx,%eax
}
  800c47:	c3                   	retq   

0000000000800c48 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c48:	48 85 d2             	test   %rdx,%rdx
  800c4b:	74 2f                	je     800c7c <strncmp+0x34>
  800c4d:	0f b6 07             	movzbl (%rdi),%eax
  800c50:	84 c0                	test   %al,%al
  800c52:	74 1f                	je     800c73 <strncmp+0x2b>
  800c54:	3a 06                	cmp    (%rsi),%al
  800c56:	75 1b                	jne    800c73 <strncmp+0x2b>
  800c58:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c5b:	48 83 c7 01          	add    $0x1,%rdi
  800c5f:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c63:	48 39 d7             	cmp    %rdx,%rdi
  800c66:	74 1a                	je     800c82 <strncmp+0x3a>
  800c68:	0f b6 07             	movzbl (%rdi),%eax
  800c6b:	84 c0                	test   %al,%al
  800c6d:	74 04                	je     800c73 <strncmp+0x2b>
  800c6f:	3a 06                	cmp    (%rsi),%al
  800c71:	74 e8                	je     800c5b <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800c73:	0f b6 07             	movzbl (%rdi),%eax
  800c76:	0f b6 16             	movzbl (%rsi),%edx
  800c79:	29 d0                	sub    %edx,%eax
}
  800c7b:	c3                   	retq   
    return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c81:	c3                   	retq   
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	c3                   	retq   

0000000000800c88 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800c88:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800c8a:	0f b6 07             	movzbl (%rdi),%eax
  800c8d:	84 c0                	test   %al,%al
  800c8f:	74 1e                	je     800caf <strchr+0x27>
    if (*s == c)
  800c91:	40 38 c6             	cmp    %al,%sil
  800c94:	74 1f                	je     800cb5 <strchr+0x2d>
  for (; *s; s++)
  800c96:	48 83 c7 01          	add    $0x1,%rdi
  800c9a:	0f b6 07             	movzbl (%rdi),%eax
  800c9d:	84 c0                	test   %al,%al
  800c9f:	74 08                	je     800ca9 <strchr+0x21>
    if (*s == c)
  800ca1:	38 d0                	cmp    %dl,%al
  800ca3:	75 f1                	jne    800c96 <strchr+0xe>
  for (; *s; s++)
  800ca5:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ca8:	c3                   	retq   
  return 0;
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cae:	c3                   	retq   
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb4:	c3                   	retq   
    if (*s == c)
  800cb5:	48 89 f8             	mov    %rdi,%rax
  800cb8:	c3                   	retq   

0000000000800cb9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cb9:	48 89 f8             	mov    %rdi,%rax
  800cbc:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cbe:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cc1:	40 38 f2             	cmp    %sil,%dl
  800cc4:	74 13                	je     800cd9 <strfind+0x20>
  800cc6:	84 d2                	test   %dl,%dl
  800cc8:	74 0f                	je     800cd9 <strfind+0x20>
  for (; *s; s++)
  800cca:	48 83 c0 01          	add    $0x1,%rax
  800cce:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800cd1:	38 ca                	cmp    %cl,%dl
  800cd3:	74 04                	je     800cd9 <strfind+0x20>
  800cd5:	84 d2                	test   %dl,%dl
  800cd7:	75 f1                	jne    800cca <strfind+0x11>
      break;
  return (char *)s;
}
  800cd9:	c3                   	retq   

0000000000800cda <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800cda:	48 85 d2             	test   %rdx,%rdx
  800cdd:	74 3a                	je     800d19 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800cdf:	48 89 f8             	mov    %rdi,%rax
  800ce2:	48 09 d0             	or     %rdx,%rax
  800ce5:	a8 03                	test   $0x3,%al
  800ce7:	75 28                	jne    800d11 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ce9:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800ced:	89 f0                	mov    %esi,%eax
  800cef:	c1 e0 08             	shl    $0x8,%eax
  800cf2:	89 f1                	mov    %esi,%ecx
  800cf4:	c1 e1 18             	shl    $0x18,%ecx
  800cf7:	41 89 f0             	mov    %esi,%r8d
  800cfa:	41 c1 e0 10          	shl    $0x10,%r8d
  800cfe:	44 09 c1             	or     %r8d,%ecx
  800d01:	09 ce                	or     %ecx,%esi
  800d03:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d05:	48 c1 ea 02          	shr    $0x2,%rdx
  800d09:	48 89 d1             	mov    %rdx,%rcx
  800d0c:	fc                   	cld    
  800d0d:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d0f:	eb 08                	jmp    800d19 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	48 89 d1             	mov    %rdx,%rcx
  800d16:	fc                   	cld    
  800d17:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d19:	48 89 f8             	mov    %rdi,%rax
  800d1c:	c3                   	retq   

0000000000800d1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d1d:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d20:	48 39 fe             	cmp    %rdi,%rsi
  800d23:	73 40                	jae    800d65 <memmove+0x48>
  800d25:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d29:	48 39 f9             	cmp    %rdi,%rcx
  800d2c:	76 37                	jbe    800d65 <memmove+0x48>
    s += n;
    d += n;
  800d2e:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d32:	48 89 fe             	mov    %rdi,%rsi
  800d35:	48 09 d6             	or     %rdx,%rsi
  800d38:	48 09 ce             	or     %rcx,%rsi
  800d3b:	40 f6 c6 03          	test   $0x3,%sil
  800d3f:	75 14                	jne    800d55 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d41:	48 83 ef 04          	sub    $0x4,%rdi
  800d45:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d49:	48 c1 ea 02          	shr    $0x2,%rdx
  800d4d:	48 89 d1             	mov    %rdx,%rcx
  800d50:	fd                   	std    
  800d51:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d53:	eb 0e                	jmp    800d63 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d55:	48 83 ef 01          	sub    $0x1,%rdi
  800d59:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d5d:	48 89 d1             	mov    %rdx,%rcx
  800d60:	fd                   	std    
  800d61:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d63:	fc                   	cld    
  800d64:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d65:	48 89 c1             	mov    %rax,%rcx
  800d68:	48 09 d1             	or     %rdx,%rcx
  800d6b:	48 09 f1             	or     %rsi,%rcx
  800d6e:	f6 c1 03             	test   $0x3,%cl
  800d71:	75 0e                	jne    800d81 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800d73:	48 c1 ea 02          	shr    $0x2,%rdx
  800d77:	48 89 d1             	mov    %rdx,%rcx
  800d7a:	48 89 c7             	mov    %rax,%rdi
  800d7d:	fc                   	cld    
  800d7e:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d80:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800d81:	48 89 c7             	mov    %rax,%rdi
  800d84:	48 89 d1             	mov    %rdx,%rcx
  800d87:	fc                   	cld    
  800d88:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800d8a:	c3                   	retq   

0000000000800d8b <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800d8b:	55                   	push   %rbp
  800d8c:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800d8f:	48 b8 1d 0d 80 00 00 	movabs $0x800d1d,%rax
  800d96:	00 00 00 
  800d99:	ff d0                	callq  *%rax
}
  800d9b:	5d                   	pop    %rbp
  800d9c:	c3                   	retq   

0000000000800d9d <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800d9d:	55                   	push   %rbp
  800d9e:	48 89 e5             	mov    %rsp,%rbp
  800da1:	41 57                	push   %r15
  800da3:	41 56                	push   %r14
  800da5:	41 55                	push   %r13
  800da7:	41 54                	push   %r12
  800da9:	53                   	push   %rbx
  800daa:	48 83 ec 08          	sub    $0x8,%rsp
  800dae:	49 89 fe             	mov    %rdi,%r14
  800db1:	49 89 f7             	mov    %rsi,%r15
  800db4:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800db7:	48 89 f7             	mov    %rsi,%rdi
  800dba:	48 b8 12 0b 80 00 00 	movabs $0x800b12,%rax
  800dc1:	00 00 00 
  800dc4:	ff d0                	callq  *%rax
  800dc6:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dc9:	4c 89 ee             	mov    %r13,%rsi
  800dcc:	4c 89 f7             	mov    %r14,%rdi
  800dcf:	48 b8 34 0b 80 00 00 	movabs $0x800b34,%rax
  800dd6:	00 00 00 
  800dd9:	ff d0                	callq  *%rax
  800ddb:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800dde:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800de2:	4d 39 e5             	cmp    %r12,%r13
  800de5:	74 26                	je     800e0d <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800de7:	4c 89 e8             	mov    %r13,%rax
  800dea:	4c 29 e0             	sub    %r12,%rax
  800ded:	48 39 d8             	cmp    %rbx,%rax
  800df0:	76 2a                	jbe    800e1c <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800df2:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800df6:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800dfa:	4c 89 fe             	mov    %r15,%rsi
  800dfd:	48 b8 8b 0d 80 00 00 	movabs $0x800d8b,%rax
  800e04:	00 00 00 
  800e07:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e09:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e0d:	48 83 c4 08          	add    $0x8,%rsp
  800e11:	5b                   	pop    %rbx
  800e12:	41 5c                	pop    %r12
  800e14:	41 5d                	pop    %r13
  800e16:	41 5e                	pop    %r14
  800e18:	41 5f                	pop    %r15
  800e1a:	5d                   	pop    %rbp
  800e1b:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e1c:	49 83 ed 01          	sub    $0x1,%r13
  800e20:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e24:	4c 89 ea             	mov    %r13,%rdx
  800e27:	4c 89 fe             	mov    %r15,%rsi
  800e2a:	48 b8 8b 0d 80 00 00 	movabs $0x800d8b,%rax
  800e31:	00 00 00 
  800e34:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e36:	4d 01 ee             	add    %r13,%r14
  800e39:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e3e:	eb c9                	jmp    800e09 <strlcat+0x6c>

0000000000800e40 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e40:	48 85 d2             	test   %rdx,%rdx
  800e43:	74 3a                	je     800e7f <memcmp+0x3f>
    if (*s1 != *s2)
  800e45:	0f b6 0f             	movzbl (%rdi),%ecx
  800e48:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e4c:	44 38 c1             	cmp    %r8b,%cl
  800e4f:	75 1d                	jne    800e6e <memcmp+0x2e>
  800e51:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e56:	48 39 d0             	cmp    %rdx,%rax
  800e59:	74 1e                	je     800e79 <memcmp+0x39>
    if (*s1 != *s2)
  800e5b:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e5f:	48 83 c0 01          	add    $0x1,%rax
  800e63:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e69:	44 38 c1             	cmp    %r8b,%cl
  800e6c:	74 e8                	je     800e56 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e6e:	0f b6 c1             	movzbl %cl,%eax
  800e71:	45 0f b6 c0          	movzbl %r8b,%r8d
  800e75:	44 29 c0             	sub    %r8d,%eax
  800e78:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	c3                   	retq   
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e84:	c3                   	retq   

0000000000800e85 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800e85:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800e89:	48 39 c7             	cmp    %rax,%rdi
  800e8c:	73 19                	jae    800ea7 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800e8e:	89 f2                	mov    %esi,%edx
  800e90:	40 38 37             	cmp    %sil,(%rdi)
  800e93:	74 16                	je     800eab <memfind+0x26>
  for (; s < ends; s++)
  800e95:	48 83 c7 01          	add    $0x1,%rdi
  800e99:	48 39 f8             	cmp    %rdi,%rax
  800e9c:	74 08                	je     800ea6 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800e9e:	38 17                	cmp    %dl,(%rdi)
  800ea0:	75 f3                	jne    800e95 <memfind+0x10>
  for (; s < ends; s++)
  800ea2:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ea5:	c3                   	retq   
  800ea6:	c3                   	retq   
  for (; s < ends; s++)
  800ea7:	48 89 f8             	mov    %rdi,%rax
  800eaa:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800eab:	48 89 f8             	mov    %rdi,%rax
  800eae:	c3                   	retq   

0000000000800eaf <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800eaf:	0f b6 07             	movzbl (%rdi),%eax
  800eb2:	3c 20                	cmp    $0x20,%al
  800eb4:	74 04                	je     800eba <strtol+0xb>
  800eb6:	3c 09                	cmp    $0x9,%al
  800eb8:	75 0f                	jne    800ec9 <strtol+0x1a>
    s++;
  800eba:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ebe:	0f b6 07             	movzbl (%rdi),%eax
  800ec1:	3c 20                	cmp    $0x20,%al
  800ec3:	74 f5                	je     800eba <strtol+0xb>
  800ec5:	3c 09                	cmp    $0x9,%al
  800ec7:	74 f1                	je     800eba <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800ec9:	3c 2b                	cmp    $0x2b,%al
  800ecb:	74 2b                	je     800ef8 <strtol+0x49>
  int neg  = 0;
  800ecd:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800ed3:	3c 2d                	cmp    $0x2d,%al
  800ed5:	74 2d                	je     800f04 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed7:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800edd:	75 0f                	jne    800eee <strtol+0x3f>
  800edf:	80 3f 30             	cmpb   $0x30,(%rdi)
  800ee2:	74 2c                	je     800f10 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800ee4:	85 d2                	test   %edx,%edx
  800ee6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eeb:	0f 44 d0             	cmove  %eax,%edx
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800ef3:	4c 63 d2             	movslq %edx,%r10
  800ef6:	eb 5c                	jmp    800f54 <strtol+0xa5>
    s++;
  800ef8:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800efc:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f02:	eb d3                	jmp    800ed7 <strtol+0x28>
    s++, neg = 1;
  800f04:	48 83 c7 01          	add    $0x1,%rdi
  800f08:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f0e:	eb c7                	jmp    800ed7 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f10:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f14:	74 0f                	je     800f25 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f16:	85 d2                	test   %edx,%edx
  800f18:	75 d4                	jne    800eee <strtol+0x3f>
    s++, base = 8;
  800f1a:	48 83 c7 01          	add    $0x1,%rdi
  800f1e:	ba 08 00 00 00       	mov    $0x8,%edx
  800f23:	eb c9                	jmp    800eee <strtol+0x3f>
    s += 2, base = 16;
  800f25:	48 83 c7 02          	add    $0x2,%rdi
  800f29:	ba 10 00 00 00       	mov    $0x10,%edx
  800f2e:	eb be                	jmp    800eee <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f30:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f34:	41 80 f8 19          	cmp    $0x19,%r8b
  800f38:	77 2f                	ja     800f69 <strtol+0xba>
      dig = *s - 'a' + 10;
  800f3a:	44 0f be c1          	movsbl %cl,%r8d
  800f3e:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f42:	39 d1                	cmp    %edx,%ecx
  800f44:	7d 37                	jge    800f7d <strtol+0xce>
    s++, val = (val * base) + dig;
  800f46:	48 83 c7 01          	add    $0x1,%rdi
  800f4a:	49 0f af c2          	imul   %r10,%rax
  800f4e:	48 63 c9             	movslq %ecx,%rcx
  800f51:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f54:	0f b6 0f             	movzbl (%rdi),%ecx
  800f57:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f5b:	41 80 f8 09          	cmp    $0x9,%r8b
  800f5f:	77 cf                	ja     800f30 <strtol+0x81>
      dig = *s - '0';
  800f61:	0f be c9             	movsbl %cl,%ecx
  800f64:	83 e9 30             	sub    $0x30,%ecx
  800f67:	eb d9                	jmp    800f42 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f69:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f6d:	41 80 f8 19          	cmp    $0x19,%r8b
  800f71:	77 0a                	ja     800f7d <strtol+0xce>
      dig = *s - 'A' + 10;
  800f73:	44 0f be c1          	movsbl %cl,%r8d
  800f77:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800f7b:	eb c5                	jmp    800f42 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800f7d:	48 85 f6             	test   %rsi,%rsi
  800f80:	74 03                	je     800f85 <strtol+0xd6>
    *endptr = (char *)s;
  800f82:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800f85:	48 89 c2             	mov    %rax,%rdx
  800f88:	48 f7 da             	neg    %rdx
  800f8b:	45 85 c9             	test   %r9d,%r9d
  800f8e:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800f92:	c3                   	retq   

0000000000800f93 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800f93:	55                   	push   %rbp
  800f94:	48 89 e5             	mov    %rsp,%rbp
  800f97:	53                   	push   %rbx
  800f98:	48 89 fa             	mov    %rdi,%rdx
  800f9b:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa3:	48 89 c3             	mov    %rax,%rbx
  800fa6:	48 89 c7             	mov    %rax,%rdi
  800fa9:	48 89 c6             	mov    %rax,%rsi
  800fac:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fae:	5b                   	pop    %rbx
  800faf:	5d                   	pop    %rbp
  800fb0:	c3                   	retq   

0000000000800fb1 <sys_cgetc>:

int
sys_cgetc(void) {
  800fb1:	55                   	push   %rbp
  800fb2:	48 89 e5             	mov    %rsp,%rbp
  800fb5:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc0:	48 89 ca             	mov    %rcx,%rdx
  800fc3:	48 89 cb             	mov    %rcx,%rbx
  800fc6:	48 89 cf             	mov    %rcx,%rdi
  800fc9:	48 89 ce             	mov    %rcx,%rsi
  800fcc:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fce:	5b                   	pop    %rbx
  800fcf:	5d                   	pop    %rbp
  800fd0:	c3                   	retq   

0000000000800fd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800fd1:	55                   	push   %rbp
  800fd2:	48 89 e5             	mov    %rsp,%rbp
  800fd5:	53                   	push   %rbx
  800fd6:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fda:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800fdd:	be 00 00 00 00       	mov    $0x0,%esi
  800fe2:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe7:	48 89 f1             	mov    %rsi,%rcx
  800fea:	48 89 f3             	mov    %rsi,%rbx
  800fed:	48 89 f7             	mov    %rsi,%rdi
  800ff0:	cd 30                	int    $0x30
  if (check && ret > 0)
  800ff2:	48 85 c0             	test   %rax,%rax
  800ff5:	7f 07                	jg     800ffe <sys_env_destroy+0x2d>
}
  800ff7:	48 83 c4 08          	add    $0x8,%rsp
  800ffb:	5b                   	pop    %rbx
  800ffc:	5d                   	pop    %rbp
  800ffd:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800ffe:	49 89 c0             	mov    %rax,%r8
  801001:	b9 03 00 00 00       	mov    $0x3,%ecx
  801006:	48 ba 30 15 80 00 00 	movabs $0x801530,%rdx
  80100d:	00 00 00 
  801010:	be 22 00 00 00       	mov    $0x22,%esi
  801015:	48 bf 4f 15 80 00 00 	movabs $0x80154f,%rdi
  80101c:	00 00 00 
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  801024:	49 b9 51 10 80 00 00 	movabs $0x801051,%r9
  80102b:	00 00 00 
  80102e:	41 ff d1             	callq  *%r9

0000000000801031 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801031:	55                   	push   %rbp
  801032:	48 89 e5             	mov    %rsp,%rbp
  801035:	53                   	push   %rbx
  asm volatile("int %1\n"
  801036:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103b:	b8 02 00 00 00       	mov    $0x2,%eax
  801040:	48 89 ca             	mov    %rcx,%rdx
  801043:	48 89 cb             	mov    %rcx,%rbx
  801046:	48 89 cf             	mov    %rcx,%rdi
  801049:	48 89 ce             	mov    %rcx,%rsi
  80104c:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80104e:	5b                   	pop    %rbx
  80104f:	5d                   	pop    %rbp
  801050:	c3                   	retq   

0000000000801051 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801051:	55                   	push   %rbp
  801052:	48 89 e5             	mov    %rsp,%rbp
  801055:	41 56                	push   %r14
  801057:	41 55                	push   %r13
  801059:	41 54                	push   %r12
  80105b:	53                   	push   %rbx
  80105c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801063:	49 89 fd             	mov    %rdi,%r13
  801066:	41 89 f6             	mov    %esi,%r14d
  801069:	49 89 d4             	mov    %rdx,%r12
  80106c:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801073:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80107a:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801081:	84 c0                	test   %al,%al
  801083:	74 26                	je     8010ab <_panic+0x5a>
  801085:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80108c:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801093:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801097:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80109b:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80109f:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010a3:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010a7:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010ab:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010b2:	00 00 00 
  8010b5:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010bc:	00 00 00 
  8010bf:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010c3:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8010ca:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8010d1:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8010d8:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8010df:	00 00 00 
  8010e2:	48 8b 18             	mov    (%rax),%rbx
  8010e5:	48 b8 31 10 80 00 00 	movabs $0x801031,%rax
  8010ec:	00 00 00 
  8010ef:	ff d0                	callq  *%rax
  8010f1:	45 89 f0             	mov    %r14d,%r8d
  8010f4:	4c 89 e9             	mov    %r13,%rcx
  8010f7:	48 89 da             	mov    %rbx,%rdx
  8010fa:	89 c6                	mov    %eax,%esi
  8010fc:	48 bf 60 15 80 00 00 	movabs $0x801560,%rdi
  801103:	00 00 00 
  801106:	b8 00 00 00 00       	mov    $0x0,%eax
  80110b:	48 bb 9f 01 80 00 00 	movabs $0x80019f,%rbx
  801112:	00 00 00 
  801115:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801117:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80111e:	4c 89 e7             	mov    %r12,%rdi
  801121:	48 b8 37 01 80 00 00 	movabs $0x800137,%rax
  801128:	00 00 00 
  80112b:	ff d0                	callq  *%rax
  cprintf("\n");
  80112d:	48 bf 62 11 80 00 00 	movabs $0x801162,%rdi
  801134:	00 00 00 
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80113e:	cc                   	int3   
  while (1)
  80113f:	eb fd                	jmp    80113e <_panic+0xed>
  801141:	0f 1f 00             	nopl   (%rax)
