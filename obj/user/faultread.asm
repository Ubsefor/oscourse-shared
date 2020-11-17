
obj/user/faultread:     file format elf64-x86-64


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
  800023:	e8 2a 00 00 00       	callq  800052 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// buggy program - faults with a read from location zero

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  cprintf("I read %08x from location 0!\n", *(volatile unsigned *)0);
  80002e:	8b 34 25 00 00 00 00 	mov    0x0,%esi
  800035:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  80003c:	00 00 00 
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
  800044:	48 ba d5 01 80 00 00 	movabs $0x8001d5,%rdx
  80004b:	00 00 00 
  80004e:	ff d2                	callq  *%rdx
}
  800050:	5d                   	pop    %rbp
  800051:	c3                   	retq   

0000000000800052 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800052:	55                   	push   %rbp
  800053:	48 89 e5             	mov    %rsp,%rbp
  800056:	41 56                	push   %r14
  800058:	41 55                	push   %r13
  80005a:	41 54                	push   %r12
  80005c:	53                   	push   %rbx
  80005d:	41 89 fd             	mov    %edi,%r13d
  800060:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800063:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80006a:	00 00 00 
  80006d:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800074:	00 00 00 
  800077:	48 39 c2             	cmp    %rax,%rdx
  80007a:	73 23                	jae    80009f <libmain+0x4d>
  80007c:	48 89 d3             	mov    %rdx,%rbx
  80007f:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800083:	48 29 d0             	sub    %rdx,%rax
  800086:	48 c1 e8 03          	shr    $0x3,%rax
  80008a:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
  800094:	ff 13                	callq  *(%rbx)
    ctor++;
  800096:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80009a:	4c 39 e3             	cmp    %r12,%rbx
  80009d:	75 f0                	jne    80008f <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  80009f:	48 b8 67 10 80 00 00 	movabs $0x801067,%rax
  8000a6:	00 00 00 
  8000a9:	ff d0                	callq  *%rax
  8000ab:	83 e0 1f             	and    $0x1f,%eax
  8000ae:	48 89 c2             	mov    %rax,%rdx
  8000b1:	48 c1 e2 05          	shl    $0x5,%rdx
  8000b5:	48 29 c2             	sub    %rax,%rdx
  8000b8:	48 89 d0             	mov    %rdx,%rax
  8000bb:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000c2:	00 00 00 
  8000c5:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000c9:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000d0:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000d3:	45 85 ed             	test   %r13d,%r13d
  8000d6:	7e 0d                	jle    8000e5 <libmain+0x93>
    binaryname = argv[0];
  8000d8:	49 8b 06             	mov    (%r14),%rax
  8000db:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000e2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e5:	4c 89 f6             	mov    %r14,%rsi
  8000e8:	44 89 ef             	mov    %r13d,%edi
  8000eb:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f2:	00 00 00 
  8000f5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f7:	48 b8 0c 01 80 00 00 	movabs $0x80010c,%rax
  8000fe:	00 00 00 
  800101:	ff d0                	callq  *%rax
#endif
}
  800103:	5b                   	pop    %rbx
  800104:	41 5c                	pop    %r12
  800106:	41 5d                	pop    %r13
  800108:	41 5e                	pop    %r14
  80010a:	5d                   	pop    %rbp
  80010b:	c3                   	retq   

000000000080010c <exit>:

#include <inc/lib.h>

void
exit(void) {
  80010c:	55                   	push   %rbp
  80010d:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800110:	bf 00 00 00 00       	mov    $0x0,%edi
  800115:	48 b8 07 10 80 00 00 	movabs $0x801007,%rax
  80011c:	00 00 00 
  80011f:	ff d0                	callq  *%rax
}
  800121:	5d                   	pop    %rbp
  800122:	c3                   	retq   

0000000000800123 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800123:	55                   	push   %rbp
  800124:	48 89 e5             	mov    %rsp,%rbp
  800127:	53                   	push   %rbx
  800128:	48 83 ec 08          	sub    $0x8,%rsp
  80012c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80012f:	8b 06                	mov    (%rsi),%eax
  800131:	8d 50 01             	lea    0x1(%rax),%edx
  800134:	89 16                	mov    %edx,(%rsi)
  800136:	48 98                	cltq   
  800138:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80013d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800143:	74 0b                	je     800150 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800145:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800149:	48 83 c4 08          	add    $0x8,%rsp
  80014d:	5b                   	pop    %rbx
  80014e:	5d                   	pop    %rbp
  80014f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800150:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800154:	be ff 00 00 00       	mov    $0xff,%esi
  800159:	48 b8 c9 0f 80 00 00 	movabs $0x800fc9,%rax
  800160:	00 00 00 
  800163:	ff d0                	callq  *%rax
    b->idx = 0;
  800165:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80016b:	eb d8                	jmp    800145 <putch+0x22>

000000000080016d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80016d:	55                   	push   %rbp
  80016e:	48 89 e5             	mov    %rsp,%rbp
  800171:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800178:	48 89 fa             	mov    %rdi,%rdx
  80017b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80017e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800185:	00 00 00 
  b.cnt = 0;
  800188:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80018f:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800192:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800199:	48 bf 23 01 80 00 00 	movabs $0x800123,%rdi
  8001a0:	00 00 00 
  8001a3:	48 b8 93 03 80 00 00 	movabs $0x800393,%rax
  8001aa:	00 00 00 
  8001ad:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001af:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001b6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001bd:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001c1:	48 b8 c9 0f 80 00 00 	movabs $0x800fc9,%rax
  8001c8:	00 00 00 
  8001cb:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001d3:	c9                   	leaveq 
  8001d4:	c3                   	retq   

00000000008001d5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001d5:	55                   	push   %rbp
  8001d6:	48 89 e5             	mov    %rsp,%rbp
  8001d9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001e0:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001e7:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001ee:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001f5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001fc:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800203:	84 c0                	test   %al,%al
  800205:	74 20                	je     800227 <cprintf+0x52>
  800207:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80020b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80020f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800213:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800217:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80021b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80021f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800223:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800227:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80022e:	00 00 00 
  800231:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800238:	00 00 00 
  80023b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80023f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800246:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80024d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800254:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80025b:	48 b8 6d 01 80 00 00 	movabs $0x80016d,%rax
  800262:	00 00 00 
  800265:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800267:	c9                   	leaveq 
  800268:	c3                   	retq   

0000000000800269 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800269:	55                   	push   %rbp
  80026a:	48 89 e5             	mov    %rsp,%rbp
  80026d:	41 57                	push   %r15
  80026f:	41 56                	push   %r14
  800271:	41 55                	push   %r13
  800273:	41 54                	push   %r12
  800275:	53                   	push   %rbx
  800276:	48 83 ec 18          	sub    $0x18,%rsp
  80027a:	49 89 fc             	mov    %rdi,%r12
  80027d:	49 89 f5             	mov    %rsi,%r13
  800280:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800284:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800287:	41 89 cf             	mov    %ecx,%r15d
  80028a:	49 39 d7             	cmp    %rdx,%r15
  80028d:	76 45                	jbe    8002d4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80028f:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800293:	85 db                	test   %ebx,%ebx
  800295:	7e 0e                	jle    8002a5 <printnum+0x3c>
      putch(padc, putdat);
  800297:	4c 89 ee             	mov    %r13,%rsi
  80029a:	44 89 f7             	mov    %r14d,%edi
  80029d:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	75 f2                	jne    800297 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002a5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	49 f7 f7             	div    %r15
  8002b1:	48 b8 a8 11 80 00 00 	movabs $0x8011a8,%rax
  8002b8:	00 00 00 
  8002bb:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002bf:	4c 89 ee             	mov    %r13,%rsi
  8002c2:	41 ff d4             	callq  *%r12
}
  8002c5:	48 83 c4 18          	add    $0x18,%rsp
  8002c9:	5b                   	pop    %rbx
  8002ca:	41 5c                	pop    %r12
  8002cc:	41 5d                	pop    %r13
  8002ce:	41 5e                	pop    %r14
  8002d0:	41 5f                	pop    %r15
  8002d2:	5d                   	pop    %rbp
  8002d3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	49 f7 f7             	div    %r15
  8002e0:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002e4:	48 89 c2             	mov    %rax,%rdx
  8002e7:	48 b8 69 02 80 00 00 	movabs $0x800269,%rax
  8002ee:	00 00 00 
  8002f1:	ff d0                	callq  *%rax
  8002f3:	eb b0                	jmp    8002a5 <printnum+0x3c>

00000000008002f5 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002f5:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002f9:	48 8b 06             	mov    (%rsi),%rax
  8002fc:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800300:	73 0a                	jae    80030c <sprintputch+0x17>
    *b->buf++ = ch;
  800302:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800306:	48 89 16             	mov    %rdx,(%rsi)
  800309:	40 88 38             	mov    %dil,(%rax)
}
  80030c:	c3                   	retq   

000000000080030d <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80030d:	55                   	push   %rbp
  80030e:	48 89 e5             	mov    %rsp,%rbp
  800311:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800318:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80031f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800326:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80032d:	84 c0                	test   %al,%al
  80032f:	74 20                	je     800351 <printfmt+0x44>
  800331:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800335:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800339:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80033d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800341:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800345:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800349:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80034d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800351:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800358:	00 00 00 
  80035b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800362:	00 00 00 
  800365:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800369:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800370:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800377:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80037e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800385:	48 b8 93 03 80 00 00 	movabs $0x800393,%rax
  80038c:	00 00 00 
  80038f:	ff d0                	callq  *%rax
}
  800391:	c9                   	leaveq 
  800392:	c3                   	retq   

0000000000800393 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800393:	55                   	push   %rbp
  800394:	48 89 e5             	mov    %rsp,%rbp
  800397:	41 57                	push   %r15
  800399:	41 56                	push   %r14
  80039b:	41 55                	push   %r13
  80039d:	41 54                	push   %r12
  80039f:	53                   	push   %rbx
  8003a0:	48 83 ec 48          	sub    $0x48,%rsp
  8003a4:	49 89 fd             	mov    %rdi,%r13
  8003a7:	49 89 f7             	mov    %rsi,%r15
  8003aa:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003ad:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003b1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003b5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003b9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003bd:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003c1:	41 0f b6 3e          	movzbl (%r14),%edi
  8003c5:	83 ff 25             	cmp    $0x25,%edi
  8003c8:	74 18                	je     8003e2 <vprintfmt+0x4f>
      if (ch == '\0')
  8003ca:	85 ff                	test   %edi,%edi
  8003cc:	0f 84 8c 06 00 00    	je     800a5e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003d2:	4c 89 fe             	mov    %r15,%rsi
  8003d5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003d8:	49 89 de             	mov    %rbx,%r14
  8003db:	eb e0                	jmp    8003bd <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003dd:	49 89 de             	mov    %rbx,%r14
  8003e0:	eb db                	jmp    8003bd <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003e2:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003e6:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003ea:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003f1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003f7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003fb:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800400:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800406:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80040c:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800411:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800416:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80041a:	0f b6 13             	movzbl (%rbx),%edx
  80041d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800420:	3c 55                	cmp    $0x55,%al
  800422:	0f 87 8b 05 00 00    	ja     8009b3 <vprintfmt+0x620>
  800428:	0f b6 c0             	movzbl %al,%eax
  80042b:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800432:	00 00 00 
  800435:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800439:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80043c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800440:	eb d4                	jmp    800416 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800442:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800445:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800449:	eb cb                	jmp    800416 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80044b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80044e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800452:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800456:	8d 50 d0             	lea    -0x30(%rax),%edx
  800459:	83 fa 09             	cmp    $0x9,%edx
  80045c:	77 7e                	ja     8004dc <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80045e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800462:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800466:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80046b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80046f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800472:	83 fa 09             	cmp    $0x9,%edx
  800475:	76 e7                	jbe    80045e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800477:	4c 89 f3             	mov    %r14,%rbx
  80047a:	eb 19                	jmp    800495 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80047c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80047f:	83 f8 2f             	cmp    $0x2f,%eax
  800482:	77 2a                	ja     8004ae <vprintfmt+0x11b>
  800484:	89 c2                	mov    %eax,%edx
  800486:	4c 01 d2             	add    %r10,%rdx
  800489:	83 c0 08             	add    $0x8,%eax
  80048c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80048f:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800492:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800495:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800499:	0f 89 77 ff ff ff    	jns    800416 <vprintfmt+0x83>
          width = precision, precision = -1;
  80049f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004a3:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004a9:	e9 68 ff ff ff       	jmpq   800416 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004ae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004b2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004b6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004ba:	eb d3                	jmp    80048f <vprintfmt+0xfc>
        if (width < 0)
  8004bc:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004c5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004c8:	4c 89 f3             	mov    %r14,%rbx
  8004cb:	e9 46 ff ff ff       	jmpq   800416 <vprintfmt+0x83>
  8004d0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004d3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004d7:	e9 3a ff ff ff       	jmpq   800416 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004dc:	4c 89 f3             	mov    %r14,%rbx
  8004df:	eb b4                	jmp    800495 <vprintfmt+0x102>
        lflag++;
  8004e1:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004e4:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004e7:	e9 2a ff ff ff       	jmpq   800416 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004ef:	83 f8 2f             	cmp    $0x2f,%eax
  8004f2:	77 19                	ja     80050d <vprintfmt+0x17a>
  8004f4:	89 c2                	mov    %eax,%edx
  8004f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004fa:	83 c0 08             	add    $0x8,%eax
  8004fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800500:	4c 89 fe             	mov    %r15,%rsi
  800503:	8b 3a                	mov    (%rdx),%edi
  800505:	41 ff d5             	callq  *%r13
        break;
  800508:	e9 b0 fe ff ff       	jmpq   8003bd <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80050d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800511:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800515:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800519:	eb e5                	jmp    800500 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80051b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80051e:	83 f8 2f             	cmp    $0x2f,%eax
  800521:	77 5b                	ja     80057e <vprintfmt+0x1eb>
  800523:	89 c2                	mov    %eax,%edx
  800525:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800529:	83 c0 08             	add    $0x8,%eax
  80052c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80052f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800531:	89 c8                	mov    %ecx,%eax
  800533:	c1 f8 1f             	sar    $0x1f,%eax
  800536:	31 c1                	xor    %eax,%ecx
  800538:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053a:	83 f9 09             	cmp    $0x9,%ecx
  80053d:	7f 4d                	jg     80058c <vprintfmt+0x1f9>
  80053f:	48 63 c1             	movslq %ecx,%rax
  800542:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  800549:	00 00 00 
  80054c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800550:	48 85 c0             	test   %rax,%rax
  800553:	74 37                	je     80058c <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800555:	48 89 c1             	mov    %rax,%rcx
  800558:	48 ba c9 11 80 00 00 	movabs $0x8011c9,%rdx
  80055f:	00 00 00 
  800562:	4c 89 fe             	mov    %r15,%rsi
  800565:	4c 89 ef             	mov    %r13,%rdi
  800568:	b8 00 00 00 00       	mov    $0x0,%eax
  80056d:	48 bb 0d 03 80 00 00 	movabs $0x80030d,%rbx
  800574:	00 00 00 
  800577:	ff d3                	callq  *%rbx
  800579:	e9 3f fe ff ff       	jmpq   8003bd <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80057e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800582:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800586:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80058a:	eb a3                	jmp    80052f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80058c:	48 ba c0 11 80 00 00 	movabs $0x8011c0,%rdx
  800593:	00 00 00 
  800596:	4c 89 fe             	mov    %r15,%rsi
  800599:	4c 89 ef             	mov    %r13,%rdi
  80059c:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a1:	48 bb 0d 03 80 00 00 	movabs $0x80030d,%rbx
  8005a8:	00 00 00 
  8005ab:	ff d3                	callq  *%rbx
  8005ad:	e9 0b fe ff ff       	jmpq   8003bd <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005b2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005b5:	83 f8 2f             	cmp    $0x2f,%eax
  8005b8:	77 4b                	ja     800605 <vprintfmt+0x272>
  8005ba:	89 c2                	mov    %eax,%edx
  8005bc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005c0:	83 c0 08             	add    $0x8,%eax
  8005c3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005c6:	48 8b 02             	mov    (%rdx),%rax
  8005c9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005cd:	48 85 c0             	test   %rax,%rax
  8005d0:	0f 84 05 04 00 00    	je     8009db <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005d6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005da:	7e 06                	jle    8005e2 <vprintfmt+0x24f>
  8005dc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005e0:	75 31                	jne    800613 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005e6:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005ea:	0f b6 00             	movzbl (%rax),%eax
  8005ed:	0f be f8             	movsbl %al,%edi
  8005f0:	85 ff                	test   %edi,%edi
  8005f2:	0f 84 c3 00 00 00    	je     8006bb <vprintfmt+0x328>
  8005f8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005fc:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800600:	e9 85 00 00 00       	jmpq   80068a <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800605:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800609:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80060d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800611:	eb b3                	jmp    8005c6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800613:	49 63 f4             	movslq %r12d,%rsi
  800616:	48 89 c7             	mov    %rax,%rdi
  800619:	48 b8 6a 0b 80 00 00 	movabs $0x800b6a,%rax
  800620:	00 00 00 
  800623:	ff d0                	callq  *%rax
  800625:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800628:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80062b:	85 f6                	test   %esi,%esi
  80062d:	7e 22                	jle    800651 <vprintfmt+0x2be>
            putch(padc, putdat);
  80062f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800633:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800637:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80063b:	4c 89 fe             	mov    %r15,%rsi
  80063e:	89 df                	mov    %ebx,%edi
  800640:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800643:	41 83 ec 01          	sub    $0x1,%r12d
  800647:	75 f2                	jne    80063b <vprintfmt+0x2a8>
  800649:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80064d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800651:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800655:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800659:	0f b6 00             	movzbl (%rax),%eax
  80065c:	0f be f8             	movsbl %al,%edi
  80065f:	85 ff                	test   %edi,%edi
  800661:	0f 84 56 fd ff ff    	je     8003bd <vprintfmt+0x2a>
  800667:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80066b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80066f:	eb 19                	jmp    80068a <vprintfmt+0x2f7>
            putch(ch, putdat);
  800671:	4c 89 fe             	mov    %r15,%rsi
  800674:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800677:	41 83 ee 01          	sub    $0x1,%r14d
  80067b:	48 83 c3 01          	add    $0x1,%rbx
  80067f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800683:	0f be f8             	movsbl %al,%edi
  800686:	85 ff                	test   %edi,%edi
  800688:	74 29                	je     8006b3 <vprintfmt+0x320>
  80068a:	45 85 e4             	test   %r12d,%r12d
  80068d:	78 06                	js     800695 <vprintfmt+0x302>
  80068f:	41 83 ec 01          	sub    $0x1,%r12d
  800693:	78 48                	js     8006dd <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800695:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800699:	74 d6                	je     800671 <vprintfmt+0x2de>
  80069b:	0f be c0             	movsbl %al,%eax
  80069e:	83 e8 20             	sub    $0x20,%eax
  8006a1:	83 f8 5e             	cmp    $0x5e,%eax
  8006a4:	76 cb                	jbe    800671 <vprintfmt+0x2de>
            putch('?', putdat);
  8006a6:	4c 89 fe             	mov    %r15,%rsi
  8006a9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006ae:	41 ff d5             	callq  *%r13
  8006b1:	eb c4                	jmp    800677 <vprintfmt+0x2e4>
  8006b3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006b7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006bb:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006be:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006c2:	0f 8e f5 fc ff ff    	jle    8003bd <vprintfmt+0x2a>
          putch(' ', putdat);
  8006c8:	4c 89 fe             	mov    %r15,%rsi
  8006cb:	bf 20 00 00 00       	mov    $0x20,%edi
  8006d0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006d3:	83 eb 01             	sub    $0x1,%ebx
  8006d6:	75 f0                	jne    8006c8 <vprintfmt+0x335>
  8006d8:	e9 e0 fc ff ff       	jmpq   8003bd <vprintfmt+0x2a>
  8006dd:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006e1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006e5:	eb d4                	jmp    8006bb <vprintfmt+0x328>
  if (lflag >= 2)
  8006e7:	83 f9 01             	cmp    $0x1,%ecx
  8006ea:	7f 1d                	jg     800709 <vprintfmt+0x376>
  else if (lflag)
  8006ec:	85 c9                	test   %ecx,%ecx
  8006ee:	74 5e                	je     80074e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006f0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006f3:	83 f8 2f             	cmp    $0x2f,%eax
  8006f6:	77 48                	ja     800740 <vprintfmt+0x3ad>
  8006f8:	89 c2                	mov    %eax,%edx
  8006fa:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006fe:	83 c0 08             	add    $0x8,%eax
  800701:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800704:	48 8b 1a             	mov    (%rdx),%rbx
  800707:	eb 17                	jmp    800720 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800709:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80070c:	83 f8 2f             	cmp    $0x2f,%eax
  80070f:	77 21                	ja     800732 <vprintfmt+0x39f>
  800711:	89 c2                	mov    %eax,%edx
  800713:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800717:	83 c0 08             	add    $0x8,%eax
  80071a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80071d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800720:	48 85 db             	test   %rbx,%rbx
  800723:	78 50                	js     800775 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800725:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800728:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072d:	e9 b4 01 00 00       	jmpq   8008e6 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800732:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800736:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80073a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073e:	eb dd                	jmp    80071d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800740:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800744:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800748:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80074c:	eb b6                	jmp    800704 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80074e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800751:	83 f8 2f             	cmp    $0x2f,%eax
  800754:	77 11                	ja     800767 <vprintfmt+0x3d4>
  800756:	89 c2                	mov    %eax,%edx
  800758:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80075c:	83 c0 08             	add    $0x8,%eax
  80075f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800762:	48 63 1a             	movslq (%rdx),%rbx
  800765:	eb b9                	jmp    800720 <vprintfmt+0x38d>
  800767:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80076b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80076f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800773:	eb ed                	jmp    800762 <vprintfmt+0x3cf>
          putch('-', putdat);
  800775:	4c 89 fe             	mov    %r15,%rsi
  800778:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80077d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800780:	48 89 da             	mov    %rbx,%rdx
  800783:	48 f7 da             	neg    %rdx
        base = 10;
  800786:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078b:	e9 56 01 00 00       	jmpq   8008e6 <vprintfmt+0x553>
  if (lflag >= 2)
  800790:	83 f9 01             	cmp    $0x1,%ecx
  800793:	7f 25                	jg     8007ba <vprintfmt+0x427>
  else if (lflag)
  800795:	85 c9                	test   %ecx,%ecx
  800797:	74 5e                	je     8007f7 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800799:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80079c:	83 f8 2f             	cmp    $0x2f,%eax
  80079f:	77 48                	ja     8007e9 <vprintfmt+0x456>
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a7:	83 c0 08             	add    $0x8,%eax
  8007aa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ad:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b5:	e9 2c 01 00 00       	jmpq   8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007ba:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007bd:	83 f8 2f             	cmp    $0x2f,%eax
  8007c0:	77 19                	ja     8007db <vprintfmt+0x448>
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007c8:	83 c0 08             	add    $0x8,%eax
  8007cb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ce:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d6:	e9 0b 01 00 00       	jmpq   8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007db:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007df:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e7:	eb e5                	jmp    8007ce <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007e9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ed:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007f1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f5:	eb b6                	jmp    8007ad <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007fa:	83 f8 2f             	cmp    $0x2f,%eax
  8007fd:	77 18                	ja     800817 <vprintfmt+0x484>
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800805:	83 c0 08             	add    $0x8,%eax
  800808:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80080b:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80080d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800812:	e9 cf 00 00 00       	jmpq   8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800817:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80081b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80081f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800823:	eb e6                	jmp    80080b <vprintfmt+0x478>
  if (lflag >= 2)
  800825:	83 f9 01             	cmp    $0x1,%ecx
  800828:	7f 25                	jg     80084f <vprintfmt+0x4bc>
  else if (lflag)
  80082a:	85 c9                	test   %ecx,%ecx
  80082c:	74 5b                	je     800889 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80082e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800831:	83 f8 2f             	cmp    $0x2f,%eax
  800834:	77 45                	ja     80087b <vprintfmt+0x4e8>
  800836:	89 c2                	mov    %eax,%edx
  800838:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80083c:	83 c0 08             	add    $0x8,%eax
  80083f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800842:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800845:	b9 08 00 00 00       	mov    $0x8,%ecx
  80084a:	e9 97 00 00 00       	jmpq   8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80084f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800852:	83 f8 2f             	cmp    $0x2f,%eax
  800855:	77 16                	ja     80086d <vprintfmt+0x4da>
  800857:	89 c2                	mov    %eax,%edx
  800859:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80085d:	83 c0 08             	add    $0x8,%eax
  800860:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800863:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800866:	b9 08 00 00 00       	mov    $0x8,%ecx
  80086b:	eb 79                	jmp    8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80086d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800871:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800875:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800879:	eb e8                	jmp    800863 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80087b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800883:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800887:	eb b9                	jmp    800842 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800889:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80088c:	83 f8 2f             	cmp    $0x2f,%eax
  80088f:	77 15                	ja     8008a6 <vprintfmt+0x513>
  800891:	89 c2                	mov    %eax,%edx
  800893:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800897:	83 c0 08             	add    $0x8,%eax
  80089a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80089d:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80089f:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008a4:	eb 40                	jmp    8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008a6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008aa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b2:	eb e9                	jmp    80089d <vprintfmt+0x50a>
        putch('0', putdat);
  8008b4:	4c 89 fe             	mov    %r15,%rsi
  8008b7:	bf 30 00 00 00       	mov    $0x30,%edi
  8008bc:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008bf:	4c 89 fe             	mov    %r15,%rsi
  8008c2:	bf 78 00 00 00       	mov    $0x78,%edi
  8008c7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008ca:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008cd:	83 f8 2f             	cmp    $0x2f,%eax
  8008d0:	77 34                	ja     800906 <vprintfmt+0x573>
  8008d2:	89 c2                	mov    %eax,%edx
  8008d4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d8:	83 c0 08             	add    $0x8,%eax
  8008db:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008de:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008e1:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008e6:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008eb:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008ef:	4c 89 fe             	mov    %r15,%rsi
  8008f2:	4c 89 ef             	mov    %r13,%rdi
  8008f5:	48 b8 69 02 80 00 00 	movabs $0x800269,%rax
  8008fc:	00 00 00 
  8008ff:	ff d0                	callq  *%rax
        break;
  800901:	e9 b7 fa ff ff       	jmpq   8003bd <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800906:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80090e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800912:	eb ca                	jmp    8008de <vprintfmt+0x54b>
  if (lflag >= 2)
  800914:	83 f9 01             	cmp    $0x1,%ecx
  800917:	7f 22                	jg     80093b <vprintfmt+0x5a8>
  else if (lflag)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 58                	je     800975 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80091d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800920:	83 f8 2f             	cmp    $0x2f,%eax
  800923:	77 42                	ja     800967 <vprintfmt+0x5d4>
  800925:	89 c2                	mov    %eax,%edx
  800927:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092b:	83 c0 08             	add    $0x8,%eax
  80092e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800931:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800934:	b9 10 00 00 00       	mov    $0x10,%ecx
  800939:	eb ab                	jmp    8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80093b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093e:	83 f8 2f             	cmp    $0x2f,%eax
  800941:	77 16                	ja     800959 <vprintfmt+0x5c6>
  800943:	89 c2                	mov    %eax,%edx
  800945:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800949:	83 c0 08             	add    $0x8,%eax
  80094c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800952:	b9 10 00 00 00       	mov    $0x10,%ecx
  800957:	eb 8d                	jmp    8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800959:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800961:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800965:	eb e8                	jmp    80094f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800967:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800973:	eb bc                	jmp    800931 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800975:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800978:	83 f8 2f             	cmp    $0x2f,%eax
  80097b:	77 18                	ja     800995 <vprintfmt+0x602>
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800983:	83 c0 08             	add    $0x8,%eax
  800986:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800989:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80098b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800990:	e9 51 ff ff ff       	jmpq   8008e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800995:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800999:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a1:	eb e6                	jmp    800989 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009a3:	4c 89 fe             	mov    %r15,%rsi
  8009a6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009ab:	41 ff d5             	callq  *%r13
        break;
  8009ae:	e9 0a fa ff ff       	jmpq   8003bd <vprintfmt+0x2a>
        putch('%', putdat);
  8009b3:	4c 89 fe             	mov    %r15,%rsi
  8009b6:	bf 25 00 00 00       	mov    $0x25,%edi
  8009bb:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009be:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009c2:	0f 84 15 fa ff ff    	je     8003dd <vprintfmt+0x4a>
  8009c8:	49 89 de             	mov    %rbx,%r14
  8009cb:	49 83 ee 01          	sub    $0x1,%r14
  8009cf:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009d4:	75 f5                	jne    8009cb <vprintfmt+0x638>
  8009d6:	e9 e2 f9 ff ff       	jmpq   8003bd <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009db:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009df:	74 06                	je     8009e7 <vprintfmt+0x654>
  8009e1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009e5:	7f 21                	jg     800a08 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e7:	bf 28 00 00 00       	mov    $0x28,%edi
  8009ec:	48 bb ba 11 80 00 00 	movabs $0x8011ba,%rbx
  8009f3:	00 00 00 
  8009f6:	b8 28 00 00 00       	mov    $0x28,%eax
  8009fb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009ff:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a03:	e9 82 fc ff ff       	jmpq   80068a <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a08:	49 63 f4             	movslq %r12d,%rsi
  800a0b:	48 bf b9 11 80 00 00 	movabs $0x8011b9,%rdi
  800a12:	00 00 00 
  800a15:	48 b8 6a 0b 80 00 00 	movabs $0x800b6a,%rax
  800a1c:	00 00 00 
  800a1f:	ff d0                	callq  *%rax
  800a21:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a24:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a27:	48 be b9 11 80 00 00 	movabs $0x8011b9,%rsi
  800a2e:	00 00 00 
  800a31:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a35:	85 c0                	test   %eax,%eax
  800a37:	0f 8f f2 fb ff ff    	jg     80062f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3d:	48 bb ba 11 80 00 00 	movabs $0x8011ba,%rbx
  800a44:	00 00 00 
  800a47:	b8 28 00 00 00       	mov    $0x28,%eax
  800a4c:	bf 28 00 00 00       	mov    $0x28,%edi
  800a51:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a55:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a59:	e9 2c fc ff ff       	jmpq   80068a <vprintfmt+0x2f7>
}
  800a5e:	48 83 c4 48          	add    $0x48,%rsp
  800a62:	5b                   	pop    %rbx
  800a63:	41 5c                	pop    %r12
  800a65:	41 5d                	pop    %r13
  800a67:	41 5e                	pop    %r14
  800a69:	41 5f                	pop    %r15
  800a6b:	5d                   	pop    %rbp
  800a6c:	c3                   	retq   

0000000000800a6d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a6d:	55                   	push   %rbp
  800a6e:	48 89 e5             	mov    %rsp,%rbp
  800a71:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a75:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a79:	48 63 c6             	movslq %esi,%rax
  800a7c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a81:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a85:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a8c:	48 85 ff             	test   %rdi,%rdi
  800a8f:	74 2a                	je     800abb <vsnprintf+0x4e>
  800a91:	85 f6                	test   %esi,%esi
  800a93:	7e 26                	jle    800abb <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a95:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a99:	48 bf f5 02 80 00 00 	movabs $0x8002f5,%rdi
  800aa0:	00 00 00 
  800aa3:	48 b8 93 03 80 00 00 	movabs $0x800393,%rax
  800aaa:	00 00 00 
  800aad:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800aaf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ab3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ab6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ab9:	c9                   	leaveq 
  800aba:	c3                   	retq   
    return -E_INVAL;
  800abb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac0:	eb f7                	jmp    800ab9 <vsnprintf+0x4c>

0000000000800ac2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ac2:	55                   	push   %rbp
  800ac3:	48 89 e5             	mov    %rsp,%rbp
  800ac6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800acd:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ad4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800adb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ae2:	84 c0                	test   %al,%al
  800ae4:	74 20                	je     800b06 <snprintf+0x44>
  800ae6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800aea:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800aee:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800af2:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800af6:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800afa:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800afe:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b02:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b06:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b0d:	00 00 00 
  800b10:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b17:	00 00 00 
  800b1a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b1e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b25:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b2c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b33:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b3a:	48 b8 6d 0a 80 00 00 	movabs $0x800a6d,%rax
  800b41:	00 00 00 
  800b44:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b46:	c9                   	leaveq 
  800b47:	c3                   	retq   

0000000000800b48 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b48:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b4b:	74 17                	je     800b64 <strlen+0x1c>
  800b4d:	48 89 fa             	mov    %rdi,%rdx
  800b50:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b55:	29 f9                	sub    %edi,%ecx
    n++;
  800b57:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b5a:	48 83 c2 01          	add    $0x1,%rdx
  800b5e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b61:	75 f4                	jne    800b57 <strlen+0xf>
  800b63:	c3                   	retq   
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b69:	c3                   	retq   

0000000000800b6a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b6a:	48 85 f6             	test   %rsi,%rsi
  800b6d:	74 24                	je     800b93 <strnlen+0x29>
  800b6f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b72:	74 25                	je     800b99 <strnlen+0x2f>
  800b74:	48 01 fe             	add    %rdi,%rsi
  800b77:	48 89 fa             	mov    %rdi,%rdx
  800b7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b7f:	29 f9                	sub    %edi,%ecx
    n++;
  800b81:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b84:	48 83 c2 01          	add    $0x1,%rdx
  800b88:	48 39 f2             	cmp    %rsi,%rdx
  800b8b:	74 11                	je     800b9e <strnlen+0x34>
  800b8d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b90:	75 ef                	jne    800b81 <strnlen+0x17>
  800b92:	c3                   	retq   
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	c3                   	retq   
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b9e:	c3                   	retq   

0000000000800b9f <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b9f:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bab:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bae:	48 83 c2 01          	add    $0x1,%rdx
  800bb2:	84 c9                	test   %cl,%cl
  800bb4:	75 f1                	jne    800ba7 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bb6:	c3                   	retq   

0000000000800bb7 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bb7:	55                   	push   %rbp
  800bb8:	48 89 e5             	mov    %rsp,%rbp
  800bbb:	41 54                	push   %r12
  800bbd:	53                   	push   %rbx
  800bbe:	48 89 fb             	mov    %rdi,%rbx
  800bc1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bc4:	48 b8 48 0b 80 00 00 	movabs $0x800b48,%rax
  800bcb:	00 00 00 
  800bce:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bd0:	48 63 f8             	movslq %eax,%rdi
  800bd3:	48 01 df             	add    %rbx,%rdi
  800bd6:	4c 89 e6             	mov    %r12,%rsi
  800bd9:	48 b8 9f 0b 80 00 00 	movabs $0x800b9f,%rax
  800be0:	00 00 00 
  800be3:	ff d0                	callq  *%rax
  return dst;
}
  800be5:	48 89 d8             	mov    %rbx,%rax
  800be8:	5b                   	pop    %rbx
  800be9:	41 5c                	pop    %r12
  800beb:	5d                   	pop    %rbp
  800bec:	c3                   	retq   

0000000000800bed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bed:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bf0:	48 85 d2             	test   %rdx,%rdx
  800bf3:	74 1f                	je     800c14 <strncpy+0x27>
  800bf5:	48 01 fa             	add    %rdi,%rdx
  800bf8:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bfb:	48 83 c1 01          	add    $0x1,%rcx
  800bff:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c03:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c07:	41 80 f8 01          	cmp    $0x1,%r8b
  800c0b:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c0f:	48 39 ca             	cmp    %rcx,%rdx
  800c12:	75 e7                	jne    800bfb <strncpy+0xe>
  }
  return ret;
}
  800c14:	c3                   	retq   

0000000000800c15 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c15:	48 89 f8             	mov    %rdi,%rax
  800c18:	48 85 d2             	test   %rdx,%rdx
  800c1b:	74 36                	je     800c53 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c1d:	48 83 fa 01          	cmp    $0x1,%rdx
  800c21:	74 2d                	je     800c50 <strlcpy+0x3b>
  800c23:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c27:	45 84 c0             	test   %r8b,%r8b
  800c2a:	74 24                	je     800c50 <strlcpy+0x3b>
  800c2c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c30:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c35:	48 83 c0 01          	add    $0x1,%rax
  800c39:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c3d:	48 39 d1             	cmp    %rdx,%rcx
  800c40:	74 0e                	je     800c50 <strlcpy+0x3b>
  800c42:	48 83 c1 01          	add    $0x1,%rcx
  800c46:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c4b:	45 84 c0             	test   %r8b,%r8b
  800c4e:	75 e5                	jne    800c35 <strlcpy+0x20>
    *dst = '\0';
  800c50:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c53:	48 29 f8             	sub    %rdi,%rax
}
  800c56:	c3                   	retq   

0000000000800c57 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c57:	0f b6 07             	movzbl (%rdi),%eax
  800c5a:	84 c0                	test   %al,%al
  800c5c:	74 17                	je     800c75 <strcmp+0x1e>
  800c5e:	3a 06                	cmp    (%rsi),%al
  800c60:	75 13                	jne    800c75 <strcmp+0x1e>
    p++, q++;
  800c62:	48 83 c7 01          	add    $0x1,%rdi
  800c66:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c6a:	0f b6 07             	movzbl (%rdi),%eax
  800c6d:	84 c0                	test   %al,%al
  800c6f:	74 04                	je     800c75 <strcmp+0x1e>
  800c71:	3a 06                	cmp    (%rsi),%al
  800c73:	74 ed                	je     800c62 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c75:	0f b6 c0             	movzbl %al,%eax
  800c78:	0f b6 16             	movzbl (%rsi),%edx
  800c7b:	29 d0                	sub    %edx,%eax
}
  800c7d:	c3                   	retq   

0000000000800c7e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c7e:	48 85 d2             	test   %rdx,%rdx
  800c81:	74 2f                	je     800cb2 <strncmp+0x34>
  800c83:	0f b6 07             	movzbl (%rdi),%eax
  800c86:	84 c0                	test   %al,%al
  800c88:	74 1f                	je     800ca9 <strncmp+0x2b>
  800c8a:	3a 06                	cmp    (%rsi),%al
  800c8c:	75 1b                	jne    800ca9 <strncmp+0x2b>
  800c8e:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c91:	48 83 c7 01          	add    $0x1,%rdi
  800c95:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c99:	48 39 d7             	cmp    %rdx,%rdi
  800c9c:	74 1a                	je     800cb8 <strncmp+0x3a>
  800c9e:	0f b6 07             	movzbl (%rdi),%eax
  800ca1:	84 c0                	test   %al,%al
  800ca3:	74 04                	je     800ca9 <strncmp+0x2b>
  800ca5:	3a 06                	cmp    (%rsi),%al
  800ca7:	74 e8                	je     800c91 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ca9:	0f b6 07             	movzbl (%rdi),%eax
  800cac:	0f b6 16             	movzbl (%rsi),%edx
  800caf:	29 d0                	sub    %edx,%eax
}
  800cb1:	c3                   	retq   
    return 0;
  800cb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb7:	c3                   	retq   
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbd:	c3                   	retq   

0000000000800cbe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cbe:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cc0:	0f b6 07             	movzbl (%rdi),%eax
  800cc3:	84 c0                	test   %al,%al
  800cc5:	74 1e                	je     800ce5 <strchr+0x27>
    if (*s == c)
  800cc7:	40 38 c6             	cmp    %al,%sil
  800cca:	74 1f                	je     800ceb <strchr+0x2d>
  for (; *s; s++)
  800ccc:	48 83 c7 01          	add    $0x1,%rdi
  800cd0:	0f b6 07             	movzbl (%rdi),%eax
  800cd3:	84 c0                	test   %al,%al
  800cd5:	74 08                	je     800cdf <strchr+0x21>
    if (*s == c)
  800cd7:	38 d0                	cmp    %dl,%al
  800cd9:	75 f1                	jne    800ccc <strchr+0xe>
  for (; *s; s++)
  800cdb:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cde:	c3                   	retq   
  return 0;
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	c3                   	retq   
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cea:	c3                   	retq   
    if (*s == c)
  800ceb:	48 89 f8             	mov    %rdi,%rax
  800cee:	c3                   	retq   

0000000000800cef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800cef:	48 89 f8             	mov    %rdi,%rax
  800cf2:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cf4:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cf7:	40 38 f2             	cmp    %sil,%dl
  800cfa:	74 13                	je     800d0f <strfind+0x20>
  800cfc:	84 d2                	test   %dl,%dl
  800cfe:	74 0f                	je     800d0f <strfind+0x20>
  for (; *s; s++)
  800d00:	48 83 c0 01          	add    $0x1,%rax
  800d04:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d07:	38 ca                	cmp    %cl,%dl
  800d09:	74 04                	je     800d0f <strfind+0x20>
  800d0b:	84 d2                	test   %dl,%dl
  800d0d:	75 f1                	jne    800d00 <strfind+0x11>
      break;
  return (char *)s;
}
  800d0f:	c3                   	retq   

0000000000800d10 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d10:	48 85 d2             	test   %rdx,%rdx
  800d13:	74 3a                	je     800d4f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d15:	48 89 f8             	mov    %rdi,%rax
  800d18:	48 09 d0             	or     %rdx,%rax
  800d1b:	a8 03                	test   $0x3,%al
  800d1d:	75 28                	jne    800d47 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d1f:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d23:	89 f0                	mov    %esi,%eax
  800d25:	c1 e0 08             	shl    $0x8,%eax
  800d28:	89 f1                	mov    %esi,%ecx
  800d2a:	c1 e1 18             	shl    $0x18,%ecx
  800d2d:	41 89 f0             	mov    %esi,%r8d
  800d30:	41 c1 e0 10          	shl    $0x10,%r8d
  800d34:	44 09 c1             	or     %r8d,%ecx
  800d37:	09 ce                	or     %ecx,%esi
  800d39:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d3b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d3f:	48 89 d1             	mov    %rdx,%rcx
  800d42:	fc                   	cld    
  800d43:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d45:	eb 08                	jmp    800d4f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	48 89 d1             	mov    %rdx,%rcx
  800d4c:	fc                   	cld    
  800d4d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d4f:	48 89 f8             	mov    %rdi,%rax
  800d52:	c3                   	retq   

0000000000800d53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d53:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d56:	48 39 fe             	cmp    %rdi,%rsi
  800d59:	73 40                	jae    800d9b <memmove+0x48>
  800d5b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d5f:	48 39 f9             	cmp    %rdi,%rcx
  800d62:	76 37                	jbe    800d9b <memmove+0x48>
    s += n;
    d += n;
  800d64:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d68:	48 89 fe             	mov    %rdi,%rsi
  800d6b:	48 09 d6             	or     %rdx,%rsi
  800d6e:	48 09 ce             	or     %rcx,%rsi
  800d71:	40 f6 c6 03          	test   $0x3,%sil
  800d75:	75 14                	jne    800d8b <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d77:	48 83 ef 04          	sub    $0x4,%rdi
  800d7b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d7f:	48 c1 ea 02          	shr    $0x2,%rdx
  800d83:	48 89 d1             	mov    %rdx,%rcx
  800d86:	fd                   	std    
  800d87:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d89:	eb 0e                	jmp    800d99 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d8b:	48 83 ef 01          	sub    $0x1,%rdi
  800d8f:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d93:	48 89 d1             	mov    %rdx,%rcx
  800d96:	fd                   	std    
  800d97:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d99:	fc                   	cld    
  800d9a:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d9b:	48 89 c1             	mov    %rax,%rcx
  800d9e:	48 09 d1             	or     %rdx,%rcx
  800da1:	48 09 f1             	or     %rsi,%rcx
  800da4:	f6 c1 03             	test   $0x3,%cl
  800da7:	75 0e                	jne    800db7 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800da9:	48 c1 ea 02          	shr    $0x2,%rdx
  800dad:	48 89 d1             	mov    %rdx,%rcx
  800db0:	48 89 c7             	mov    %rax,%rdi
  800db3:	fc                   	cld    
  800db4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800db6:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800db7:	48 89 c7             	mov    %rax,%rdi
  800dba:	48 89 d1             	mov    %rdx,%rcx
  800dbd:	fc                   	cld    
  800dbe:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dc0:	c3                   	retq   

0000000000800dc1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dc1:	55                   	push   %rbp
  800dc2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dc5:	48 b8 53 0d 80 00 00 	movabs $0x800d53,%rax
  800dcc:	00 00 00 
  800dcf:	ff d0                	callq  *%rax
}
  800dd1:	5d                   	pop    %rbp
  800dd2:	c3                   	retq   

0000000000800dd3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dd3:	55                   	push   %rbp
  800dd4:	48 89 e5             	mov    %rsp,%rbp
  800dd7:	41 57                	push   %r15
  800dd9:	41 56                	push   %r14
  800ddb:	41 55                	push   %r13
  800ddd:	41 54                	push   %r12
  800ddf:	53                   	push   %rbx
  800de0:	48 83 ec 08          	sub    $0x8,%rsp
  800de4:	49 89 fe             	mov    %rdi,%r14
  800de7:	49 89 f7             	mov    %rsi,%r15
  800dea:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800ded:	48 89 f7             	mov    %rsi,%rdi
  800df0:	48 b8 48 0b 80 00 00 	movabs $0x800b48,%rax
  800df7:	00 00 00 
  800dfa:	ff d0                	callq  *%rax
  800dfc:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dff:	4c 89 ee             	mov    %r13,%rsi
  800e02:	4c 89 f7             	mov    %r14,%rdi
  800e05:	48 b8 6a 0b 80 00 00 	movabs $0x800b6a,%rax
  800e0c:	00 00 00 
  800e0f:	ff d0                	callq  *%rax
  800e11:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e14:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e18:	4d 39 e5             	cmp    %r12,%r13
  800e1b:	74 26                	je     800e43 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e1d:	4c 89 e8             	mov    %r13,%rax
  800e20:	4c 29 e0             	sub    %r12,%rax
  800e23:	48 39 d8             	cmp    %rbx,%rax
  800e26:	76 2a                	jbe    800e52 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e28:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e2c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e30:	4c 89 fe             	mov    %r15,%rsi
  800e33:	48 b8 c1 0d 80 00 00 	movabs $0x800dc1,%rax
  800e3a:	00 00 00 
  800e3d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e3f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e43:	48 83 c4 08          	add    $0x8,%rsp
  800e47:	5b                   	pop    %rbx
  800e48:	41 5c                	pop    %r12
  800e4a:	41 5d                	pop    %r13
  800e4c:	41 5e                	pop    %r14
  800e4e:	41 5f                	pop    %r15
  800e50:	5d                   	pop    %rbp
  800e51:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e52:	49 83 ed 01          	sub    $0x1,%r13
  800e56:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e5a:	4c 89 ea             	mov    %r13,%rdx
  800e5d:	4c 89 fe             	mov    %r15,%rsi
  800e60:	48 b8 c1 0d 80 00 00 	movabs $0x800dc1,%rax
  800e67:	00 00 00 
  800e6a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e6c:	4d 01 ee             	add    %r13,%r14
  800e6f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e74:	eb c9                	jmp    800e3f <strlcat+0x6c>

0000000000800e76 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e76:	48 85 d2             	test   %rdx,%rdx
  800e79:	74 3a                	je     800eb5 <memcmp+0x3f>
    if (*s1 != *s2)
  800e7b:	0f b6 0f             	movzbl (%rdi),%ecx
  800e7e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e82:	44 38 c1             	cmp    %r8b,%cl
  800e85:	75 1d                	jne    800ea4 <memcmp+0x2e>
  800e87:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e8c:	48 39 d0             	cmp    %rdx,%rax
  800e8f:	74 1e                	je     800eaf <memcmp+0x39>
    if (*s1 != *s2)
  800e91:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e95:	48 83 c0 01          	add    $0x1,%rax
  800e99:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e9f:	44 38 c1             	cmp    %r8b,%cl
  800ea2:	74 e8                	je     800e8c <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ea4:	0f b6 c1             	movzbl %cl,%eax
  800ea7:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eab:	44 29 c0             	sub    %r8d,%eax
  800eae:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	c3                   	retq   
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eba:	c3                   	retq   

0000000000800ebb <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800ebb:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ebf:	48 39 c7             	cmp    %rax,%rdi
  800ec2:	73 19                	jae    800edd <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ec4:	89 f2                	mov    %esi,%edx
  800ec6:	40 38 37             	cmp    %sil,(%rdi)
  800ec9:	74 16                	je     800ee1 <memfind+0x26>
  for (; s < ends; s++)
  800ecb:	48 83 c7 01          	add    $0x1,%rdi
  800ecf:	48 39 f8             	cmp    %rdi,%rax
  800ed2:	74 08                	je     800edc <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed4:	38 17                	cmp    %dl,(%rdi)
  800ed6:	75 f3                	jne    800ecb <memfind+0x10>
  for (; s < ends; s++)
  800ed8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800edb:	c3                   	retq   
  800edc:	c3                   	retq   
  for (; s < ends; s++)
  800edd:	48 89 f8             	mov    %rdi,%rax
  800ee0:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800ee1:	48 89 f8             	mov    %rdi,%rax
  800ee4:	c3                   	retq   

0000000000800ee5 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ee5:	0f b6 07             	movzbl (%rdi),%eax
  800ee8:	3c 20                	cmp    $0x20,%al
  800eea:	74 04                	je     800ef0 <strtol+0xb>
  800eec:	3c 09                	cmp    $0x9,%al
  800eee:	75 0f                	jne    800eff <strtol+0x1a>
    s++;
  800ef0:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ef4:	0f b6 07             	movzbl (%rdi),%eax
  800ef7:	3c 20                	cmp    $0x20,%al
  800ef9:	74 f5                	je     800ef0 <strtol+0xb>
  800efb:	3c 09                	cmp    $0x9,%al
  800efd:	74 f1                	je     800ef0 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800eff:	3c 2b                	cmp    $0x2b,%al
  800f01:	74 2b                	je     800f2e <strtol+0x49>
  int neg  = 0;
  800f03:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f09:	3c 2d                	cmp    $0x2d,%al
  800f0b:	74 2d                	je     800f3a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0d:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f13:	75 0f                	jne    800f24 <strtol+0x3f>
  800f15:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f18:	74 2c                	je     800f46 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f1a:	85 d2                	test   %edx,%edx
  800f1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f21:	0f 44 d0             	cmove  %eax,%edx
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f29:	4c 63 d2             	movslq %edx,%r10
  800f2c:	eb 5c                	jmp    800f8a <strtol+0xa5>
    s++;
  800f2e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f32:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f38:	eb d3                	jmp    800f0d <strtol+0x28>
    s++, neg = 1;
  800f3a:	48 83 c7 01          	add    $0x1,%rdi
  800f3e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f44:	eb c7                	jmp    800f0d <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f46:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f4a:	74 0f                	je     800f5b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f4c:	85 d2                	test   %edx,%edx
  800f4e:	75 d4                	jne    800f24 <strtol+0x3f>
    s++, base = 8;
  800f50:	48 83 c7 01          	add    $0x1,%rdi
  800f54:	ba 08 00 00 00       	mov    $0x8,%edx
  800f59:	eb c9                	jmp    800f24 <strtol+0x3f>
    s += 2, base = 16;
  800f5b:	48 83 c7 02          	add    $0x2,%rdi
  800f5f:	ba 10 00 00 00       	mov    $0x10,%edx
  800f64:	eb be                	jmp    800f24 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f66:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f6a:	41 80 f8 19          	cmp    $0x19,%r8b
  800f6e:	77 2f                	ja     800f9f <strtol+0xba>
      dig = *s - 'a' + 10;
  800f70:	44 0f be c1          	movsbl %cl,%r8d
  800f74:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f78:	39 d1                	cmp    %edx,%ecx
  800f7a:	7d 37                	jge    800fb3 <strtol+0xce>
    s++, val = (val * base) + dig;
  800f7c:	48 83 c7 01          	add    $0x1,%rdi
  800f80:	49 0f af c2          	imul   %r10,%rax
  800f84:	48 63 c9             	movslq %ecx,%rcx
  800f87:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f8a:	0f b6 0f             	movzbl (%rdi),%ecx
  800f8d:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f91:	41 80 f8 09          	cmp    $0x9,%r8b
  800f95:	77 cf                	ja     800f66 <strtol+0x81>
      dig = *s - '0';
  800f97:	0f be c9             	movsbl %cl,%ecx
  800f9a:	83 e9 30             	sub    $0x30,%ecx
  800f9d:	eb d9                	jmp    800f78 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f9f:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fa3:	41 80 f8 19          	cmp    $0x19,%r8b
  800fa7:	77 0a                	ja     800fb3 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fa9:	44 0f be c1          	movsbl %cl,%r8d
  800fad:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fb1:	eb c5                	jmp    800f78 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fb3:	48 85 f6             	test   %rsi,%rsi
  800fb6:	74 03                	je     800fbb <strtol+0xd6>
    *endptr = (char *)s;
  800fb8:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fbb:	48 89 c2             	mov    %rax,%rdx
  800fbe:	48 f7 da             	neg    %rdx
  800fc1:	45 85 c9             	test   %r9d,%r9d
  800fc4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fc8:	c3                   	retq   

0000000000800fc9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fc9:	55                   	push   %rbp
  800fca:	48 89 e5             	mov    %rsp,%rbp
  800fcd:	53                   	push   %rbx
  800fce:	48 89 fa             	mov    %rdi,%rdx
  800fd1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	48 89 c3             	mov    %rax,%rbx
  800fdc:	48 89 c7             	mov    %rax,%rdi
  800fdf:	48 89 c6             	mov    %rax,%rsi
  800fe2:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fe4:	5b                   	pop    %rbx
  800fe5:	5d                   	pop    %rbp
  800fe6:	c3                   	retq   

0000000000800fe7 <sys_cgetc>:

int
sys_cgetc(void) {
  800fe7:	55                   	push   %rbp
  800fe8:	48 89 e5             	mov    %rsp,%rbp
  800feb:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff6:	48 89 ca             	mov    %rcx,%rdx
  800ff9:	48 89 cb             	mov    %rcx,%rbx
  800ffc:	48 89 cf             	mov    %rcx,%rdi
  800fff:	48 89 ce             	mov    %rcx,%rsi
  801002:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801004:	5b                   	pop    %rbx
  801005:	5d                   	pop    %rbp
  801006:	c3                   	retq   

0000000000801007 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801007:	55                   	push   %rbp
  801008:	48 89 e5             	mov    %rsp,%rbp
  80100b:	53                   	push   %rbx
  80100c:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801010:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801013:	be 00 00 00 00       	mov    $0x0,%esi
  801018:	b8 03 00 00 00       	mov    $0x3,%eax
  80101d:	48 89 f1             	mov    %rsi,%rcx
  801020:	48 89 f3             	mov    %rsi,%rbx
  801023:	48 89 f7             	mov    %rsi,%rdi
  801026:	cd 30                	int    $0x30
  if (check && ret > 0)
  801028:	48 85 c0             	test   %rax,%rax
  80102b:	7f 07                	jg     801034 <sys_env_destroy+0x2d>
}
  80102d:	48 83 c4 08          	add    $0x8,%rsp
  801031:	5b                   	pop    %rbx
  801032:	5d                   	pop    %rbp
  801033:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801034:	49 89 c0             	mov    %rax,%r8
  801037:	b9 03 00 00 00       	mov    $0x3,%ecx
  80103c:	48 ba 70 15 80 00 00 	movabs $0x801570,%rdx
  801043:	00 00 00 
  801046:	be 22 00 00 00       	mov    $0x22,%esi
  80104b:	48 bf 8f 15 80 00 00 	movabs $0x80158f,%rdi
  801052:	00 00 00 
  801055:	b8 00 00 00 00       	mov    $0x0,%eax
  80105a:	49 b9 87 10 80 00 00 	movabs $0x801087,%r9
  801061:	00 00 00 
  801064:	41 ff d1             	callq  *%r9

0000000000801067 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801067:	55                   	push   %rbp
  801068:	48 89 e5             	mov    %rsp,%rbp
  80106b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80106c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801071:	b8 02 00 00 00       	mov    $0x2,%eax
  801076:	48 89 ca             	mov    %rcx,%rdx
  801079:	48 89 cb             	mov    %rcx,%rbx
  80107c:	48 89 cf             	mov    %rcx,%rdi
  80107f:	48 89 ce             	mov    %rcx,%rsi
  801082:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801084:	5b                   	pop    %rbx
  801085:	5d                   	pop    %rbp
  801086:	c3                   	retq   

0000000000801087 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801087:	55                   	push   %rbp
  801088:	48 89 e5             	mov    %rsp,%rbp
  80108b:	41 56                	push   %r14
  80108d:	41 55                	push   %r13
  80108f:	41 54                	push   %r12
  801091:	53                   	push   %rbx
  801092:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801099:	49 89 fd             	mov    %rdi,%r13
  80109c:	41 89 f6             	mov    %esi,%r14d
  80109f:	49 89 d4             	mov    %rdx,%r12
  8010a2:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8010a9:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8010b0:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8010b7:	84 c0                	test   %al,%al
  8010b9:	74 26                	je     8010e1 <_panic+0x5a>
  8010bb:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8010c2:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8010c9:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8010cd:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8010d1:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8010d5:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8010d9:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8010dd:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8010e1:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8010e8:	00 00 00 
  8010eb:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8010f2:	00 00 00 
  8010f5:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010f9:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801100:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801107:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80110e:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  801115:	00 00 00 
  801118:	48 8b 18             	mov    (%rax),%rbx
  80111b:	48 b8 67 10 80 00 00 	movabs $0x801067,%rax
  801122:	00 00 00 
  801125:	ff d0                	callq  *%rax
  801127:	45 89 f0             	mov    %r14d,%r8d
  80112a:	4c 89 e9             	mov    %r13,%rcx
  80112d:	48 89 da             	mov    %rbx,%rdx
  801130:	89 c6                	mov    %eax,%esi
  801132:	48 bf a0 15 80 00 00 	movabs $0x8015a0,%rdi
  801139:	00 00 00 
  80113c:	b8 00 00 00 00       	mov    $0x0,%eax
  801141:	48 bb d5 01 80 00 00 	movabs $0x8001d5,%rbx
  801148:	00 00 00 
  80114b:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80114d:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801154:	4c 89 e7             	mov    %r12,%rdi
  801157:	48 b8 6d 01 80 00 00 	movabs $0x80016d,%rax
  80115e:	00 00 00 
  801161:	ff d0                	callq  *%rax
  cprintf("\n");
  801163:	48 bf 9c 11 80 00 00 	movabs $0x80119c,%rdi
  80116a:	00 00 00 
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
  801172:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801174:	cc                   	int3   
  while (1)
  801175:	eb fd                	jmp    801174 <_panic+0xed>
  801177:	90                   	nop
