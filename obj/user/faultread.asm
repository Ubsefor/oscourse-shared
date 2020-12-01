
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
  800035:	48 bf 00 14 80 00 00 	movabs $0x801400,%rdi
  80003c:	00 00 00 
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
  800044:	48 ba d1 01 80 00 00 	movabs $0x8001d1,%rdx
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80009f:	48 b8 63 10 80 00 00 	movabs $0x801063,%rax
  8000a6:	00 00 00 
  8000a9:	ff d0                	callq  *%rax
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000b4:	48 c1 e0 05          	shl    $0x5,%rax
  8000b8:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000bf:	00 00 00 
  8000c2:	48 01 d0             	add    %rdx,%rax
  8000c5:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000cc:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000cf:	45 85 ed             	test   %r13d,%r13d
  8000d2:	7e 0d                	jle    8000e1 <libmain+0x8f>
    binaryname = argv[0];
  8000d4:	49 8b 06             	mov    (%r14),%rax
  8000d7:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000de:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e1:	4c 89 f6             	mov    %r14,%rsi
  8000e4:	44 89 ef             	mov    %r13d,%edi
  8000e7:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000ee:	00 00 00 
  8000f1:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f3:	48 b8 08 01 80 00 00 	movabs $0x800108,%rax
  8000fa:	00 00 00 
  8000fd:	ff d0                	callq  *%rax
#endif
}
  8000ff:	5b                   	pop    %rbx
  800100:	41 5c                	pop    %r12
  800102:	41 5d                	pop    %r13
  800104:	41 5e                	pop    %r14
  800106:	5d                   	pop    %rbp
  800107:	c3                   	retq   

0000000000800108 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800108:	55                   	push   %rbp
  800109:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80010c:	bf 00 00 00 00       	mov    $0x0,%edi
  800111:	48 b8 03 10 80 00 00 	movabs $0x801003,%rax
  800118:	00 00 00 
  80011b:	ff d0                	callq  *%rax
}
  80011d:	5d                   	pop    %rbp
  80011e:	c3                   	retq   

000000000080011f <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80011f:	55                   	push   %rbp
  800120:	48 89 e5             	mov    %rsp,%rbp
  800123:	53                   	push   %rbx
  800124:	48 83 ec 08          	sub    $0x8,%rsp
  800128:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80012b:	8b 06                	mov    (%rsi),%eax
  80012d:	8d 50 01             	lea    0x1(%rax),%edx
  800130:	89 16                	mov    %edx,(%rsi)
  800132:	48 98                	cltq   
  800134:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800139:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80013f:	74 0b                	je     80014c <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800141:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800145:	48 83 c4 08          	add    $0x8,%rsp
  800149:	5b                   	pop    %rbx
  80014a:	5d                   	pop    %rbp
  80014b:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80014c:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800150:	be ff 00 00 00       	mov    $0xff,%esi
  800155:	48 b8 c5 0f 80 00 00 	movabs $0x800fc5,%rax
  80015c:	00 00 00 
  80015f:	ff d0                	callq  *%rax
    b->idx = 0;
  800161:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800167:	eb d8                	jmp    800141 <putch+0x22>

0000000000800169 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800169:	55                   	push   %rbp
  80016a:	48 89 e5             	mov    %rsp,%rbp
  80016d:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800174:	48 89 fa             	mov    %rdi,%rdx
  800177:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80017a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800181:	00 00 00 
  b.cnt = 0;
  800184:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80018b:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80018e:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800195:	48 bf 1f 01 80 00 00 	movabs $0x80011f,%rdi
  80019c:	00 00 00 
  80019f:	48 b8 8f 03 80 00 00 	movabs $0x80038f,%rax
  8001a6:	00 00 00 
  8001a9:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001ab:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001b2:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001b9:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001bd:	48 b8 c5 0f 80 00 00 	movabs $0x800fc5,%rax
  8001c4:	00 00 00 
  8001c7:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001cf:	c9                   	leaveq 
  8001d0:	c3                   	retq   

00000000008001d1 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001d1:	55                   	push   %rbp
  8001d2:	48 89 e5             	mov    %rsp,%rbp
  8001d5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001dc:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001e3:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001ea:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001f1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001f8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001ff:	84 c0                	test   %al,%al
  800201:	74 20                	je     800223 <cprintf+0x52>
  800203:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800207:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80020b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80020f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800213:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800217:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80021b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80021f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800223:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80022a:	00 00 00 
  80022d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800234:	00 00 00 
  800237:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80023b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800242:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800249:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800250:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800257:	48 b8 69 01 80 00 00 	movabs $0x800169,%rax
  80025e:	00 00 00 
  800261:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800263:	c9                   	leaveq 
  800264:	c3                   	retq   

0000000000800265 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800265:	55                   	push   %rbp
  800266:	48 89 e5             	mov    %rsp,%rbp
  800269:	41 57                	push   %r15
  80026b:	41 56                	push   %r14
  80026d:	41 55                	push   %r13
  80026f:	41 54                	push   %r12
  800271:	53                   	push   %rbx
  800272:	48 83 ec 18          	sub    $0x18,%rsp
  800276:	49 89 fc             	mov    %rdi,%r12
  800279:	49 89 f5             	mov    %rsi,%r13
  80027c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800280:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800283:	41 89 cf             	mov    %ecx,%r15d
  800286:	49 39 d7             	cmp    %rdx,%r15
  800289:	76 45                	jbe    8002d0 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80028b:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7e 0e                	jle    8002a1 <printnum+0x3c>
      putch(padc, putdat);
  800293:	4c 89 ee             	mov    %r13,%rsi
  800296:	44 89 f7             	mov    %r14d,%edi
  800299:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	75 f2                	jne    800293 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002a1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002aa:	49 f7 f7             	div    %r15
  8002ad:	48 b8 28 14 80 00 00 	movabs $0x801428,%rax
  8002b4:	00 00 00 
  8002b7:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002bb:	4c 89 ee             	mov    %r13,%rsi
  8002be:	41 ff d4             	callq  *%r12
}
  8002c1:	48 83 c4 18          	add    $0x18,%rsp
  8002c5:	5b                   	pop    %rbx
  8002c6:	41 5c                	pop    %r12
  8002c8:	41 5d                	pop    %r13
  8002ca:	41 5e                	pop    %r14
  8002cc:	41 5f                	pop    %r15
  8002ce:	5d                   	pop    %rbp
  8002cf:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	49 f7 f7             	div    %r15
  8002dc:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002e0:	48 89 c2             	mov    %rax,%rdx
  8002e3:	48 b8 65 02 80 00 00 	movabs $0x800265,%rax
  8002ea:	00 00 00 
  8002ed:	ff d0                	callq  *%rax
  8002ef:	eb b0                	jmp    8002a1 <printnum+0x3c>

00000000008002f1 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002f1:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002f5:	48 8b 06             	mov    (%rsi),%rax
  8002f8:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002fc:	73 0a                	jae    800308 <sprintputch+0x17>
    *b->buf++ = ch;
  8002fe:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800302:	48 89 16             	mov    %rdx,(%rsi)
  800305:	40 88 38             	mov    %dil,(%rax)
}
  800308:	c3                   	retq   

0000000000800309 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800309:	55                   	push   %rbp
  80030a:	48 89 e5             	mov    %rsp,%rbp
  80030d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800314:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80031b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800322:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800329:	84 c0                	test   %al,%al
  80032b:	74 20                	je     80034d <printfmt+0x44>
  80032d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800331:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800335:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800339:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80033d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800341:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800345:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800349:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80034d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800354:	00 00 00 
  800357:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80035e:	00 00 00 
  800361:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800365:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80036c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800373:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80037a:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800381:	48 b8 8f 03 80 00 00 	movabs $0x80038f,%rax
  800388:	00 00 00 
  80038b:	ff d0                	callq  *%rax
}
  80038d:	c9                   	leaveq 
  80038e:	c3                   	retq   

000000000080038f <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80038f:	55                   	push   %rbp
  800390:	48 89 e5             	mov    %rsp,%rbp
  800393:	41 57                	push   %r15
  800395:	41 56                	push   %r14
  800397:	41 55                	push   %r13
  800399:	41 54                	push   %r12
  80039b:	53                   	push   %rbx
  80039c:	48 83 ec 48          	sub    $0x48,%rsp
  8003a0:	49 89 fd             	mov    %rdi,%r13
  8003a3:	49 89 f7             	mov    %rsi,%r15
  8003a6:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003a9:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003ad:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003b1:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003b5:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003b9:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003bd:	41 0f b6 3e          	movzbl (%r14),%edi
  8003c1:	83 ff 25             	cmp    $0x25,%edi
  8003c4:	74 18                	je     8003de <vprintfmt+0x4f>
      if (ch == '\0')
  8003c6:	85 ff                	test   %edi,%edi
  8003c8:	0f 84 8c 06 00 00    	je     800a5a <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003ce:	4c 89 fe             	mov    %r15,%rsi
  8003d1:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003d4:	49 89 de             	mov    %rbx,%r14
  8003d7:	eb e0                	jmp    8003b9 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003d9:	49 89 de             	mov    %rbx,%r14
  8003dc:	eb db                	jmp    8003b9 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003de:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003e2:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003e6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003ed:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003f3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003fc:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800402:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800408:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80040d:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800412:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800416:	0f b6 13             	movzbl (%rbx),%edx
  800419:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80041c:	3c 55                	cmp    $0x55,%al
  80041e:	0f 87 8b 05 00 00    	ja     8009af <vprintfmt+0x620>
  800424:	0f b6 c0             	movzbl %al,%eax
  800427:	49 bb 00 15 80 00 00 	movabs $0x801500,%r11
  80042e:	00 00 00 
  800431:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800435:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800438:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80043c:	eb d4                	jmp    800412 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80043e:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800441:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800445:	eb cb                	jmp    800412 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800447:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80044a:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80044e:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800452:	8d 50 d0             	lea    -0x30(%rax),%edx
  800455:	83 fa 09             	cmp    $0x9,%edx
  800458:	77 7e                	ja     8004d8 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80045a:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80045e:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800462:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800467:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80046b:	8d 50 d0             	lea    -0x30(%rax),%edx
  80046e:	83 fa 09             	cmp    $0x9,%edx
  800471:	76 e7                	jbe    80045a <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800473:	4c 89 f3             	mov    %r14,%rbx
  800476:	eb 19                	jmp    800491 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800478:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80047b:	83 f8 2f             	cmp    $0x2f,%eax
  80047e:	77 2a                	ja     8004aa <vprintfmt+0x11b>
  800480:	89 c2                	mov    %eax,%edx
  800482:	4c 01 d2             	add    %r10,%rdx
  800485:	83 c0 08             	add    $0x8,%eax
  800488:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80048b:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80048e:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800491:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800495:	0f 89 77 ff ff ff    	jns    800412 <vprintfmt+0x83>
          width = precision, precision = -1;
  80049b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80049f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004a5:	e9 68 ff ff ff       	jmpq   800412 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004aa:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004ae:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004b2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004b6:	eb d3                	jmp    80048b <vprintfmt+0xfc>
        if (width < 0)
  8004b8:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004c1:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004c4:	4c 89 f3             	mov    %r14,%rbx
  8004c7:	e9 46 ff ff ff       	jmpq   800412 <vprintfmt+0x83>
  8004cc:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004cf:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004d3:	e9 3a ff ff ff       	jmpq   800412 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004d8:	4c 89 f3             	mov    %r14,%rbx
  8004db:	eb b4                	jmp    800491 <vprintfmt+0x102>
        lflag++;
  8004dd:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004e0:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004e3:	e9 2a ff ff ff       	jmpq   800412 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004e8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004eb:	83 f8 2f             	cmp    $0x2f,%eax
  8004ee:	77 19                	ja     800509 <vprintfmt+0x17a>
  8004f0:	89 c2                	mov    %eax,%edx
  8004f2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004f6:	83 c0 08             	add    $0x8,%eax
  8004f9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004fc:	4c 89 fe             	mov    %r15,%rsi
  8004ff:	8b 3a                	mov    (%rdx),%edi
  800501:	41 ff d5             	callq  *%r13
        break;
  800504:	e9 b0 fe ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800509:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80050d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800511:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800515:	eb e5                	jmp    8004fc <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800517:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80051a:	83 f8 2f             	cmp    $0x2f,%eax
  80051d:	77 5b                	ja     80057a <vprintfmt+0x1eb>
  80051f:	89 c2                	mov    %eax,%edx
  800521:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800525:	83 c0 08             	add    $0x8,%eax
  800528:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80052b:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80052d:	89 c8                	mov    %ecx,%eax
  80052f:	c1 f8 1f             	sar    $0x1f,%eax
  800532:	31 c1                	xor    %eax,%ecx
  800534:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800536:	83 f9 0b             	cmp    $0xb,%ecx
  800539:	7f 4d                	jg     800588 <vprintfmt+0x1f9>
  80053b:	48 63 c1             	movslq %ecx,%rax
  80053e:	48 ba c0 17 80 00 00 	movabs $0x8017c0,%rdx
  800545:	00 00 00 
  800548:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80054c:	48 85 c0             	test   %rax,%rax
  80054f:	74 37                	je     800588 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800551:	48 89 c1             	mov    %rax,%rcx
  800554:	48 ba 49 14 80 00 00 	movabs $0x801449,%rdx
  80055b:	00 00 00 
  80055e:	4c 89 fe             	mov    %r15,%rsi
  800561:	4c 89 ef             	mov    %r13,%rdi
  800564:	b8 00 00 00 00       	mov    $0x0,%eax
  800569:	48 bb 09 03 80 00 00 	movabs $0x800309,%rbx
  800570:	00 00 00 
  800573:	ff d3                	callq  *%rbx
  800575:	e9 3f fe ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80057a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80057e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800582:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800586:	eb a3                	jmp    80052b <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800588:	48 ba 40 14 80 00 00 	movabs $0x801440,%rdx
  80058f:	00 00 00 
  800592:	4c 89 fe             	mov    %r15,%rsi
  800595:	4c 89 ef             	mov    %r13,%rdi
  800598:	b8 00 00 00 00       	mov    $0x0,%eax
  80059d:	48 bb 09 03 80 00 00 	movabs $0x800309,%rbx
  8005a4:	00 00 00 
  8005a7:	ff d3                	callq  *%rbx
  8005a9:	e9 0b fe ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005ae:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005b1:	83 f8 2f             	cmp    $0x2f,%eax
  8005b4:	77 4b                	ja     800601 <vprintfmt+0x272>
  8005b6:	89 c2                	mov    %eax,%edx
  8005b8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005bc:	83 c0 08             	add    $0x8,%eax
  8005bf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005c2:	48 8b 02             	mov    (%rdx),%rax
  8005c5:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005c9:	48 85 c0             	test   %rax,%rax
  8005cc:	0f 84 05 04 00 00    	je     8009d7 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005d2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005d6:	7e 06                	jle    8005de <vprintfmt+0x24f>
  8005d8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005dc:	75 31                	jne    80060f <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005de:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005e2:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005e6:	0f b6 00             	movzbl (%rax),%eax
  8005e9:	0f be f8             	movsbl %al,%edi
  8005ec:	85 ff                	test   %edi,%edi
  8005ee:	0f 84 c3 00 00 00    	je     8006b7 <vprintfmt+0x328>
  8005f4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005f8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005fc:	e9 85 00 00 00       	jmpq   800686 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800601:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800605:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800609:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80060d:	eb b3                	jmp    8005c2 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	49 63 f4             	movslq %r12d,%rsi
  800612:	48 89 c7             	mov    %rax,%rdi
  800615:	48 b8 66 0b 80 00 00 	movabs $0x800b66,%rax
  80061c:	00 00 00 
  80061f:	ff d0                	callq  *%rax
  800621:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800624:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800627:	85 f6                	test   %esi,%esi
  800629:	7e 22                	jle    80064d <vprintfmt+0x2be>
            putch(padc, putdat);
  80062b:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80062f:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800633:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800637:	4c 89 fe             	mov    %r15,%rsi
  80063a:	89 df                	mov    %ebx,%edi
  80063c:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	41 83 ec 01          	sub    $0x1,%r12d
  800643:	75 f2                	jne    800637 <vprintfmt+0x2a8>
  800645:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800649:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800651:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800655:	0f b6 00             	movzbl (%rax),%eax
  800658:	0f be f8             	movsbl %al,%edi
  80065b:	85 ff                	test   %edi,%edi
  80065d:	0f 84 56 fd ff ff    	je     8003b9 <vprintfmt+0x2a>
  800663:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800667:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80066b:	eb 19                	jmp    800686 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80066d:	4c 89 fe             	mov    %r15,%rsi
  800670:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800673:	41 83 ee 01          	sub    $0x1,%r14d
  800677:	48 83 c3 01          	add    $0x1,%rbx
  80067b:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80067f:	0f be f8             	movsbl %al,%edi
  800682:	85 ff                	test   %edi,%edi
  800684:	74 29                	je     8006af <vprintfmt+0x320>
  800686:	45 85 e4             	test   %r12d,%r12d
  800689:	78 06                	js     800691 <vprintfmt+0x302>
  80068b:	41 83 ec 01          	sub    $0x1,%r12d
  80068f:	78 48                	js     8006d9 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800691:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800695:	74 d6                	je     80066d <vprintfmt+0x2de>
  800697:	0f be c0             	movsbl %al,%eax
  80069a:	83 e8 20             	sub    $0x20,%eax
  80069d:	83 f8 5e             	cmp    $0x5e,%eax
  8006a0:	76 cb                	jbe    80066d <vprintfmt+0x2de>
            putch('?', putdat);
  8006a2:	4c 89 fe             	mov    %r15,%rsi
  8006a5:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006aa:	41 ff d5             	callq  *%r13
  8006ad:	eb c4                	jmp    800673 <vprintfmt+0x2e4>
  8006af:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006b3:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006b7:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006ba:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006be:	0f 8e f5 fc ff ff    	jle    8003b9 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006c4:	4c 89 fe             	mov    %r15,%rsi
  8006c7:	bf 20 00 00 00       	mov    $0x20,%edi
  8006cc:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006cf:	83 eb 01             	sub    $0x1,%ebx
  8006d2:	75 f0                	jne    8006c4 <vprintfmt+0x335>
  8006d4:	e9 e0 fc ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
  8006d9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006dd:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006e1:	eb d4                	jmp    8006b7 <vprintfmt+0x328>
  if (lflag >= 2)
  8006e3:	83 f9 01             	cmp    $0x1,%ecx
  8006e6:	7f 1d                	jg     800705 <vprintfmt+0x376>
  else if (lflag)
  8006e8:	85 c9                	test   %ecx,%ecx
  8006ea:	74 5e                	je     80074a <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006ef:	83 f8 2f             	cmp    $0x2f,%eax
  8006f2:	77 48                	ja     80073c <vprintfmt+0x3ad>
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006fa:	83 c0 08             	add    $0x8,%eax
  8006fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800700:	48 8b 1a             	mov    (%rdx),%rbx
  800703:	eb 17                	jmp    80071c <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800705:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800708:	83 f8 2f             	cmp    $0x2f,%eax
  80070b:	77 21                	ja     80072e <vprintfmt+0x39f>
  80070d:	89 c2                	mov    %eax,%edx
  80070f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800713:	83 c0 08             	add    $0x8,%eax
  800716:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800719:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80071c:	48 85 db             	test   %rbx,%rbx
  80071f:	78 50                	js     800771 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800721:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800724:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800729:	e9 b4 01 00 00       	jmpq   8008e2 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80072e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800732:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800736:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073a:	eb dd                	jmp    800719 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80073c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800740:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800744:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800748:	eb b6                	jmp    800700 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80074a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80074d:	83 f8 2f             	cmp    $0x2f,%eax
  800750:	77 11                	ja     800763 <vprintfmt+0x3d4>
  800752:	89 c2                	mov    %eax,%edx
  800754:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800758:	83 c0 08             	add    $0x8,%eax
  80075b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80075e:	48 63 1a             	movslq (%rdx),%rbx
  800761:	eb b9                	jmp    80071c <vprintfmt+0x38d>
  800763:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800767:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80076b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80076f:	eb ed                	jmp    80075e <vprintfmt+0x3cf>
          putch('-', putdat);
  800771:	4c 89 fe             	mov    %r15,%rsi
  800774:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800779:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80077c:	48 89 da             	mov    %rbx,%rdx
  80077f:	48 f7 da             	neg    %rdx
        base = 10;
  800782:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800787:	e9 56 01 00 00       	jmpq   8008e2 <vprintfmt+0x553>
  if (lflag >= 2)
  80078c:	83 f9 01             	cmp    $0x1,%ecx
  80078f:	7f 25                	jg     8007b6 <vprintfmt+0x427>
  else if (lflag)
  800791:	85 c9                	test   %ecx,%ecx
  800793:	74 5e                	je     8007f3 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800795:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800798:	83 f8 2f             	cmp    $0x2f,%eax
  80079b:	77 48                	ja     8007e5 <vprintfmt+0x456>
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a3:	83 c0 08             	add    $0x8,%eax
  8007a6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007a9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b1:	e9 2c 01 00 00       	jmpq   8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007b9:	83 f8 2f             	cmp    $0x2f,%eax
  8007bc:	77 19                	ja     8007d7 <vprintfmt+0x448>
  8007be:	89 c2                	mov    %eax,%edx
  8007c0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007c4:	83 c0 08             	add    $0x8,%eax
  8007c7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ca:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d2:	e9 0b 01 00 00       	jmpq   8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e3:	eb e5                	jmp    8007ca <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007e5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ed:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f1:	eb b6                	jmp    8007a9 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007f3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007f6:	83 f8 2f             	cmp    $0x2f,%eax
  8007f9:	77 18                	ja     800813 <vprintfmt+0x484>
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800801:	83 c0 08             	add    $0x8,%eax
  800804:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800807:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800809:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80080e:	e9 cf 00 00 00       	jmpq   8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800813:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800817:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80081b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80081f:	eb e6                	jmp    800807 <vprintfmt+0x478>
  if (lflag >= 2)
  800821:	83 f9 01             	cmp    $0x1,%ecx
  800824:	7f 25                	jg     80084b <vprintfmt+0x4bc>
  else if (lflag)
  800826:	85 c9                	test   %ecx,%ecx
  800828:	74 5b                	je     800885 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80082a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80082d:	83 f8 2f             	cmp    $0x2f,%eax
  800830:	77 45                	ja     800877 <vprintfmt+0x4e8>
  800832:	89 c2                	mov    %eax,%edx
  800834:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800838:	83 c0 08             	add    $0x8,%eax
  80083b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80083e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800841:	b9 08 00 00 00       	mov    $0x8,%ecx
  800846:	e9 97 00 00 00       	jmpq   8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80084b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80084e:	83 f8 2f             	cmp    $0x2f,%eax
  800851:	77 16                	ja     800869 <vprintfmt+0x4da>
  800853:	89 c2                	mov    %eax,%edx
  800855:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800859:	83 c0 08             	add    $0x8,%eax
  80085c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80085f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800862:	b9 08 00 00 00       	mov    $0x8,%ecx
  800867:	eb 79                	jmp    8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800869:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80086d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800871:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800875:	eb e8                	jmp    80085f <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800877:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800883:	eb b9                	jmp    80083e <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800885:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800888:	83 f8 2f             	cmp    $0x2f,%eax
  80088b:	77 15                	ja     8008a2 <vprintfmt+0x513>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800893:	83 c0 08             	add    $0x8,%eax
  800896:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800899:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80089b:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008a0:	eb 40                	jmp    8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008a2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ae:	eb e9                	jmp    800899 <vprintfmt+0x50a>
        putch('0', putdat);
  8008b0:	4c 89 fe             	mov    %r15,%rsi
  8008b3:	bf 30 00 00 00       	mov    $0x30,%edi
  8008b8:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008bb:	4c 89 fe             	mov    %r15,%rsi
  8008be:	bf 78 00 00 00       	mov    $0x78,%edi
  8008c3:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008c6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008c9:	83 f8 2f             	cmp    $0x2f,%eax
  8008cc:	77 34                	ja     800902 <vprintfmt+0x573>
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d4:	83 c0 08             	add    $0x8,%eax
  8008d7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008da:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008dd:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008e2:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008e7:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008eb:	4c 89 fe             	mov    %r15,%rsi
  8008ee:	4c 89 ef             	mov    %r13,%rdi
  8008f1:	48 b8 65 02 80 00 00 	movabs $0x800265,%rax
  8008f8:	00 00 00 
  8008fb:	ff d0                	callq  *%rax
        break;
  8008fd:	e9 b7 fa ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800902:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800906:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80090a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80090e:	eb ca                	jmp    8008da <vprintfmt+0x54b>
  if (lflag >= 2)
  800910:	83 f9 01             	cmp    $0x1,%ecx
  800913:	7f 22                	jg     800937 <vprintfmt+0x5a8>
  else if (lflag)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 58                	je     800971 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800919:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091c:	83 f8 2f             	cmp    $0x2f,%eax
  80091f:	77 42                	ja     800963 <vprintfmt+0x5d4>
  800921:	89 c2                	mov    %eax,%edx
  800923:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800927:	83 c0 08             	add    $0x8,%eax
  80092a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800930:	b9 10 00 00 00       	mov    $0x10,%ecx
  800935:	eb ab                	jmp    8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800937:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093a:	83 f8 2f             	cmp    $0x2f,%eax
  80093d:	77 16                	ja     800955 <vprintfmt+0x5c6>
  80093f:	89 c2                	mov    %eax,%edx
  800941:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800945:	83 c0 08             	add    $0x8,%eax
  800948:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80094e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800953:	eb 8d                	jmp    8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800955:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800959:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80095d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800961:	eb e8                	jmp    80094b <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800963:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800967:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096f:	eb bc                	jmp    80092d <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800971:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800974:	83 f8 2f             	cmp    $0x2f,%eax
  800977:	77 18                	ja     800991 <vprintfmt+0x602>
  800979:	89 c2                	mov    %eax,%edx
  80097b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80097f:	83 c0 08             	add    $0x8,%eax
  800982:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800985:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800987:	b9 10 00 00 00       	mov    $0x10,%ecx
  80098c:	e9 51 ff ff ff       	jmpq   8008e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800991:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800995:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800999:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099d:	eb e6                	jmp    800985 <vprintfmt+0x5f6>
        putch(ch, putdat);
  80099f:	4c 89 fe             	mov    %r15,%rsi
  8009a2:	bf 25 00 00 00       	mov    $0x25,%edi
  8009a7:	41 ff d5             	callq  *%r13
        break;
  8009aa:	e9 0a fa ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
        putch('%', putdat);
  8009af:	4c 89 fe             	mov    %r15,%rsi
  8009b2:	bf 25 00 00 00       	mov    $0x25,%edi
  8009b7:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009ba:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009be:	0f 84 15 fa ff ff    	je     8003d9 <vprintfmt+0x4a>
  8009c4:	49 89 de             	mov    %rbx,%r14
  8009c7:	49 83 ee 01          	sub    $0x1,%r14
  8009cb:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009d0:	75 f5                	jne    8009c7 <vprintfmt+0x638>
  8009d2:	e9 e2 f9 ff ff       	jmpq   8003b9 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009d7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009db:	74 06                	je     8009e3 <vprintfmt+0x654>
  8009dd:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009e1:	7f 21                	jg     800a04 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e3:	bf 28 00 00 00       	mov    $0x28,%edi
  8009e8:	48 bb 3a 14 80 00 00 	movabs $0x80143a,%rbx
  8009ef:	00 00 00 
  8009f2:	b8 28 00 00 00       	mov    $0x28,%eax
  8009f7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009fb:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009ff:	e9 82 fc ff ff       	jmpq   800686 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a04:	49 63 f4             	movslq %r12d,%rsi
  800a07:	48 bf 39 14 80 00 00 	movabs $0x801439,%rdi
  800a0e:	00 00 00 
  800a11:	48 b8 66 0b 80 00 00 	movabs $0x800b66,%rax
  800a18:	00 00 00 
  800a1b:	ff d0                	callq  *%rax
  800a1d:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a20:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a23:	48 be 39 14 80 00 00 	movabs $0x801439,%rsi
  800a2a:	00 00 00 
  800a2d:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a31:	85 c0                	test   %eax,%eax
  800a33:	0f 8f f2 fb ff ff    	jg     80062b <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a39:	48 bb 3a 14 80 00 00 	movabs $0x80143a,%rbx
  800a40:	00 00 00 
  800a43:	b8 28 00 00 00       	mov    $0x28,%eax
  800a48:	bf 28 00 00 00       	mov    $0x28,%edi
  800a4d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a51:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a55:	e9 2c fc ff ff       	jmpq   800686 <vprintfmt+0x2f7>
}
  800a5a:	48 83 c4 48          	add    $0x48,%rsp
  800a5e:	5b                   	pop    %rbx
  800a5f:	41 5c                	pop    %r12
  800a61:	41 5d                	pop    %r13
  800a63:	41 5e                	pop    %r14
  800a65:	41 5f                	pop    %r15
  800a67:	5d                   	pop    %rbp
  800a68:	c3                   	retq   

0000000000800a69 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a69:	55                   	push   %rbp
  800a6a:	48 89 e5             	mov    %rsp,%rbp
  800a6d:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a71:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a75:	48 63 c6             	movslq %esi,%rax
  800a78:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a7d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a88:	48 85 ff             	test   %rdi,%rdi
  800a8b:	74 2a                	je     800ab7 <vsnprintf+0x4e>
  800a8d:	85 f6                	test   %esi,%esi
  800a8f:	7e 26                	jle    800ab7 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a91:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a95:	48 bf f1 02 80 00 00 	movabs $0x8002f1,%rdi
  800a9c:	00 00 00 
  800a9f:	48 b8 8f 03 80 00 00 	movabs $0x80038f,%rax
  800aa6:	00 00 00 
  800aa9:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800aab:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800aaf:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ab2:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ab5:	c9                   	leaveq 
  800ab6:	c3                   	retq   
    return -E_INVAL;
  800ab7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800abc:	eb f7                	jmp    800ab5 <vsnprintf+0x4c>

0000000000800abe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800abe:	55                   	push   %rbp
  800abf:	48 89 e5             	mov    %rsp,%rbp
  800ac2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ac9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ad0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ad7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ade:	84 c0                	test   %al,%al
  800ae0:	74 20                	je     800b02 <snprintf+0x44>
  800ae2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ae6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800aea:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800aee:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800af2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800af6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800afa:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800afe:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b02:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b09:	00 00 00 
  800b0c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b13:	00 00 00 
  800b16:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b1a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b21:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b28:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b2f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b36:	48 b8 69 0a 80 00 00 	movabs $0x800a69,%rax
  800b3d:	00 00 00 
  800b40:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b42:	c9                   	leaveq 
  800b43:	c3                   	retq   

0000000000800b44 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b44:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b47:	74 17                	je     800b60 <strlen+0x1c>
  800b49:	48 89 fa             	mov    %rdi,%rdx
  800b4c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b51:	29 f9                	sub    %edi,%ecx
    n++;
  800b53:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b56:	48 83 c2 01          	add    $0x1,%rdx
  800b5a:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b5d:	75 f4                	jne    800b53 <strlen+0xf>
  800b5f:	c3                   	retq   
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b65:	c3                   	retq   

0000000000800b66 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b66:	48 85 f6             	test   %rsi,%rsi
  800b69:	74 24                	je     800b8f <strnlen+0x29>
  800b6b:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b6e:	74 25                	je     800b95 <strnlen+0x2f>
  800b70:	48 01 fe             	add    %rdi,%rsi
  800b73:	48 89 fa             	mov    %rdi,%rdx
  800b76:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b7b:	29 f9                	sub    %edi,%ecx
    n++;
  800b7d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b80:	48 83 c2 01          	add    $0x1,%rdx
  800b84:	48 39 f2             	cmp    %rsi,%rdx
  800b87:	74 11                	je     800b9a <strnlen+0x34>
  800b89:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b8c:	75 ef                	jne    800b7d <strnlen+0x17>
  800b8e:	c3                   	retq   
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	c3                   	retq   
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b9a:	c3                   	retq   

0000000000800b9b <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b9b:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800ba7:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800baa:	48 83 c2 01          	add    $0x1,%rdx
  800bae:	84 c9                	test   %cl,%cl
  800bb0:	75 f1                	jne    800ba3 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bb2:	c3                   	retq   

0000000000800bb3 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bb3:	55                   	push   %rbp
  800bb4:	48 89 e5             	mov    %rsp,%rbp
  800bb7:	41 54                	push   %r12
  800bb9:	53                   	push   %rbx
  800bba:	48 89 fb             	mov    %rdi,%rbx
  800bbd:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bc0:	48 b8 44 0b 80 00 00 	movabs $0x800b44,%rax
  800bc7:	00 00 00 
  800bca:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bcc:	48 63 f8             	movslq %eax,%rdi
  800bcf:	48 01 df             	add    %rbx,%rdi
  800bd2:	4c 89 e6             	mov    %r12,%rsi
  800bd5:	48 b8 9b 0b 80 00 00 	movabs $0x800b9b,%rax
  800bdc:	00 00 00 
  800bdf:	ff d0                	callq  *%rax
  return dst;
}
  800be1:	48 89 d8             	mov    %rbx,%rax
  800be4:	5b                   	pop    %rbx
  800be5:	41 5c                	pop    %r12
  800be7:	5d                   	pop    %rbp
  800be8:	c3                   	retq   

0000000000800be9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be9:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bec:	48 85 d2             	test   %rdx,%rdx
  800bef:	74 1f                	je     800c10 <strncpy+0x27>
  800bf1:	48 01 fa             	add    %rdi,%rdx
  800bf4:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bf7:	48 83 c1 01          	add    $0x1,%rcx
  800bfb:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bff:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c03:	41 80 f8 01          	cmp    $0x1,%r8b
  800c07:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c0b:	48 39 ca             	cmp    %rcx,%rdx
  800c0e:	75 e7                	jne    800bf7 <strncpy+0xe>
  }
  return ret;
}
  800c10:	c3                   	retq   

0000000000800c11 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c11:	48 89 f8             	mov    %rdi,%rax
  800c14:	48 85 d2             	test   %rdx,%rdx
  800c17:	74 36                	je     800c4f <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c19:	48 83 fa 01          	cmp    $0x1,%rdx
  800c1d:	74 2d                	je     800c4c <strlcpy+0x3b>
  800c1f:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c23:	45 84 c0             	test   %r8b,%r8b
  800c26:	74 24                	je     800c4c <strlcpy+0x3b>
  800c28:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c2c:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c31:	48 83 c0 01          	add    $0x1,%rax
  800c35:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c39:	48 39 d1             	cmp    %rdx,%rcx
  800c3c:	74 0e                	je     800c4c <strlcpy+0x3b>
  800c3e:	48 83 c1 01          	add    $0x1,%rcx
  800c42:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c47:	45 84 c0             	test   %r8b,%r8b
  800c4a:	75 e5                	jne    800c31 <strlcpy+0x20>
    *dst = '\0';
  800c4c:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c4f:	48 29 f8             	sub    %rdi,%rax
}
  800c52:	c3                   	retq   

0000000000800c53 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c53:	0f b6 07             	movzbl (%rdi),%eax
  800c56:	84 c0                	test   %al,%al
  800c58:	74 17                	je     800c71 <strcmp+0x1e>
  800c5a:	3a 06                	cmp    (%rsi),%al
  800c5c:	75 13                	jne    800c71 <strcmp+0x1e>
    p++, q++;
  800c5e:	48 83 c7 01          	add    $0x1,%rdi
  800c62:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c66:	0f b6 07             	movzbl (%rdi),%eax
  800c69:	84 c0                	test   %al,%al
  800c6b:	74 04                	je     800c71 <strcmp+0x1e>
  800c6d:	3a 06                	cmp    (%rsi),%al
  800c6f:	74 ed                	je     800c5e <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c71:	0f b6 c0             	movzbl %al,%eax
  800c74:	0f b6 16             	movzbl (%rsi),%edx
  800c77:	29 d0                	sub    %edx,%eax
}
  800c79:	c3                   	retq   

0000000000800c7a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c7a:	48 85 d2             	test   %rdx,%rdx
  800c7d:	74 2f                	je     800cae <strncmp+0x34>
  800c7f:	0f b6 07             	movzbl (%rdi),%eax
  800c82:	84 c0                	test   %al,%al
  800c84:	74 1f                	je     800ca5 <strncmp+0x2b>
  800c86:	3a 06                	cmp    (%rsi),%al
  800c88:	75 1b                	jne    800ca5 <strncmp+0x2b>
  800c8a:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c8d:	48 83 c7 01          	add    $0x1,%rdi
  800c91:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c95:	48 39 d7             	cmp    %rdx,%rdi
  800c98:	74 1a                	je     800cb4 <strncmp+0x3a>
  800c9a:	0f b6 07             	movzbl (%rdi),%eax
  800c9d:	84 c0                	test   %al,%al
  800c9f:	74 04                	je     800ca5 <strncmp+0x2b>
  800ca1:	3a 06                	cmp    (%rsi),%al
  800ca3:	74 e8                	je     800c8d <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ca5:	0f b6 07             	movzbl (%rdi),%eax
  800ca8:	0f b6 16             	movzbl (%rsi),%edx
  800cab:	29 d0                	sub    %edx,%eax
}
  800cad:	c3                   	retq   
    return 0;
  800cae:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb3:	c3                   	retq   
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb9:	c3                   	retq   

0000000000800cba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cba:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cbc:	0f b6 07             	movzbl (%rdi),%eax
  800cbf:	84 c0                	test   %al,%al
  800cc1:	74 1e                	je     800ce1 <strchr+0x27>
    if (*s == c)
  800cc3:	40 38 c6             	cmp    %al,%sil
  800cc6:	74 1f                	je     800ce7 <strchr+0x2d>
  for (; *s; s++)
  800cc8:	48 83 c7 01          	add    $0x1,%rdi
  800ccc:	0f b6 07             	movzbl (%rdi),%eax
  800ccf:	84 c0                	test   %al,%al
  800cd1:	74 08                	je     800cdb <strchr+0x21>
    if (*s == c)
  800cd3:	38 d0                	cmp    %dl,%al
  800cd5:	75 f1                	jne    800cc8 <strchr+0xe>
  for (; *s; s++)
  800cd7:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cda:	c3                   	retq   
  return 0;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	c3                   	retq   
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	c3                   	retq   
    if (*s == c)
  800ce7:	48 89 f8             	mov    %rdi,%rax
  800cea:	c3                   	retq   

0000000000800ceb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ceb:	48 89 f8             	mov    %rdi,%rax
  800cee:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cf0:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cf3:	40 38 f2             	cmp    %sil,%dl
  800cf6:	74 13                	je     800d0b <strfind+0x20>
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	74 0f                	je     800d0b <strfind+0x20>
  for (; *s; s++)
  800cfc:	48 83 c0 01          	add    $0x1,%rax
  800d00:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d03:	38 ca                	cmp    %cl,%dl
  800d05:	74 04                	je     800d0b <strfind+0x20>
  800d07:	84 d2                	test   %dl,%dl
  800d09:	75 f1                	jne    800cfc <strfind+0x11>
      break;
  return (char *)s;
}
  800d0b:	c3                   	retq   

0000000000800d0c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d0c:	48 85 d2             	test   %rdx,%rdx
  800d0f:	74 3a                	je     800d4b <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d11:	48 89 f8             	mov    %rdi,%rax
  800d14:	48 09 d0             	or     %rdx,%rax
  800d17:	a8 03                	test   $0x3,%al
  800d19:	75 28                	jne    800d43 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d1b:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d1f:	89 f0                	mov    %esi,%eax
  800d21:	c1 e0 08             	shl    $0x8,%eax
  800d24:	89 f1                	mov    %esi,%ecx
  800d26:	c1 e1 18             	shl    $0x18,%ecx
  800d29:	41 89 f0             	mov    %esi,%r8d
  800d2c:	41 c1 e0 10          	shl    $0x10,%r8d
  800d30:	44 09 c1             	or     %r8d,%ecx
  800d33:	09 ce                	or     %ecx,%esi
  800d35:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d37:	48 c1 ea 02          	shr    $0x2,%rdx
  800d3b:	48 89 d1             	mov    %rdx,%rcx
  800d3e:	fc                   	cld    
  800d3f:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d41:	eb 08                	jmp    800d4b <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d43:	89 f0                	mov    %esi,%eax
  800d45:	48 89 d1             	mov    %rdx,%rcx
  800d48:	fc                   	cld    
  800d49:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d4b:	48 89 f8             	mov    %rdi,%rax
  800d4e:	c3                   	retq   

0000000000800d4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d4f:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d52:	48 39 fe             	cmp    %rdi,%rsi
  800d55:	73 40                	jae    800d97 <memmove+0x48>
  800d57:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d5b:	48 39 f9             	cmp    %rdi,%rcx
  800d5e:	76 37                	jbe    800d97 <memmove+0x48>
    s += n;
    d += n;
  800d60:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d64:	48 89 fe             	mov    %rdi,%rsi
  800d67:	48 09 d6             	or     %rdx,%rsi
  800d6a:	48 09 ce             	or     %rcx,%rsi
  800d6d:	40 f6 c6 03          	test   $0x3,%sil
  800d71:	75 14                	jne    800d87 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d73:	48 83 ef 04          	sub    $0x4,%rdi
  800d77:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d7b:	48 c1 ea 02          	shr    $0x2,%rdx
  800d7f:	48 89 d1             	mov    %rdx,%rcx
  800d82:	fd                   	std    
  800d83:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d85:	eb 0e                	jmp    800d95 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d87:	48 83 ef 01          	sub    $0x1,%rdi
  800d8b:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d8f:	48 89 d1             	mov    %rdx,%rcx
  800d92:	fd                   	std    
  800d93:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d95:	fc                   	cld    
  800d96:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d97:	48 89 c1             	mov    %rax,%rcx
  800d9a:	48 09 d1             	or     %rdx,%rcx
  800d9d:	48 09 f1             	or     %rsi,%rcx
  800da0:	f6 c1 03             	test   $0x3,%cl
  800da3:	75 0e                	jne    800db3 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800da5:	48 c1 ea 02          	shr    $0x2,%rdx
  800da9:	48 89 d1             	mov    %rdx,%rcx
  800dac:	48 89 c7             	mov    %rax,%rdi
  800daf:	fc                   	cld    
  800db0:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800db2:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800db3:	48 89 c7             	mov    %rax,%rdi
  800db6:	48 89 d1             	mov    %rdx,%rcx
  800db9:	fc                   	cld    
  800dba:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dbc:	c3                   	retq   

0000000000800dbd <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dbd:	55                   	push   %rbp
  800dbe:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dc1:	48 b8 4f 0d 80 00 00 	movabs $0x800d4f,%rax
  800dc8:	00 00 00 
  800dcb:	ff d0                	callq  *%rax
}
  800dcd:	5d                   	pop    %rbp
  800dce:	c3                   	retq   

0000000000800dcf <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dcf:	55                   	push   %rbp
  800dd0:	48 89 e5             	mov    %rsp,%rbp
  800dd3:	41 57                	push   %r15
  800dd5:	41 56                	push   %r14
  800dd7:	41 55                	push   %r13
  800dd9:	41 54                	push   %r12
  800ddb:	53                   	push   %rbx
  800ddc:	48 83 ec 08          	sub    $0x8,%rsp
  800de0:	49 89 fe             	mov    %rdi,%r14
  800de3:	49 89 f7             	mov    %rsi,%r15
  800de6:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800de9:	48 89 f7             	mov    %rsi,%rdi
  800dec:	48 b8 44 0b 80 00 00 	movabs $0x800b44,%rax
  800df3:	00 00 00 
  800df6:	ff d0                	callq  *%rax
  800df8:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800dfb:	4c 89 ee             	mov    %r13,%rsi
  800dfe:	4c 89 f7             	mov    %r14,%rdi
  800e01:	48 b8 66 0b 80 00 00 	movabs $0x800b66,%rax
  800e08:	00 00 00 
  800e0b:	ff d0                	callq  *%rax
  800e0d:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e10:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e14:	4d 39 e5             	cmp    %r12,%r13
  800e17:	74 26                	je     800e3f <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e19:	4c 89 e8             	mov    %r13,%rax
  800e1c:	4c 29 e0             	sub    %r12,%rax
  800e1f:	48 39 d8             	cmp    %rbx,%rax
  800e22:	76 2a                	jbe    800e4e <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e24:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e28:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e2c:	4c 89 fe             	mov    %r15,%rsi
  800e2f:	48 b8 bd 0d 80 00 00 	movabs $0x800dbd,%rax
  800e36:	00 00 00 
  800e39:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e3b:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e3f:	48 83 c4 08          	add    $0x8,%rsp
  800e43:	5b                   	pop    %rbx
  800e44:	41 5c                	pop    %r12
  800e46:	41 5d                	pop    %r13
  800e48:	41 5e                	pop    %r14
  800e4a:	41 5f                	pop    %r15
  800e4c:	5d                   	pop    %rbp
  800e4d:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e4e:	49 83 ed 01          	sub    $0x1,%r13
  800e52:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e56:	4c 89 ea             	mov    %r13,%rdx
  800e59:	4c 89 fe             	mov    %r15,%rsi
  800e5c:	48 b8 bd 0d 80 00 00 	movabs $0x800dbd,%rax
  800e63:	00 00 00 
  800e66:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e68:	4d 01 ee             	add    %r13,%r14
  800e6b:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e70:	eb c9                	jmp    800e3b <strlcat+0x6c>

0000000000800e72 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e72:	48 85 d2             	test   %rdx,%rdx
  800e75:	74 3a                	je     800eb1 <memcmp+0x3f>
    if (*s1 != *s2)
  800e77:	0f b6 0f             	movzbl (%rdi),%ecx
  800e7a:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e7e:	44 38 c1             	cmp    %r8b,%cl
  800e81:	75 1d                	jne    800ea0 <memcmp+0x2e>
  800e83:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e88:	48 39 d0             	cmp    %rdx,%rax
  800e8b:	74 1e                	je     800eab <memcmp+0x39>
    if (*s1 != *s2)
  800e8d:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e91:	48 83 c0 01          	add    $0x1,%rax
  800e95:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e9b:	44 38 c1             	cmp    %r8b,%cl
  800e9e:	74 e8                	je     800e88 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ea0:	0f b6 c1             	movzbl %cl,%eax
  800ea3:	45 0f b6 c0          	movzbl %r8b,%r8d
  800ea7:	44 29 c0             	sub    %r8d,%eax
  800eaa:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	c3                   	retq   
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb6:	c3                   	retq   

0000000000800eb7 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800eb7:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800ebb:	48 39 c7             	cmp    %rax,%rdi
  800ebe:	73 19                	jae    800ed9 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	40 38 37             	cmp    %sil,(%rdi)
  800ec5:	74 16                	je     800edd <memfind+0x26>
  for (; s < ends; s++)
  800ec7:	48 83 c7 01          	add    $0x1,%rdi
  800ecb:	48 39 f8             	cmp    %rdi,%rax
  800ece:	74 08                	je     800ed8 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ed0:	38 17                	cmp    %dl,(%rdi)
  800ed2:	75 f3                	jne    800ec7 <memfind+0x10>
  for (; s < ends; s++)
  800ed4:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ed7:	c3                   	retq   
  800ed8:	c3                   	retq   
  for (; s < ends; s++)
  800ed9:	48 89 f8             	mov    %rdi,%rax
  800edc:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800edd:	48 89 f8             	mov    %rdi,%rax
  800ee0:	c3                   	retq   

0000000000800ee1 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800ee1:	0f b6 07             	movzbl (%rdi),%eax
  800ee4:	3c 20                	cmp    $0x20,%al
  800ee6:	74 04                	je     800eec <strtol+0xb>
  800ee8:	3c 09                	cmp    $0x9,%al
  800eea:	75 0f                	jne    800efb <strtol+0x1a>
    s++;
  800eec:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800ef0:	0f b6 07             	movzbl (%rdi),%eax
  800ef3:	3c 20                	cmp    $0x20,%al
  800ef5:	74 f5                	je     800eec <strtol+0xb>
  800ef7:	3c 09                	cmp    $0x9,%al
  800ef9:	74 f1                	je     800eec <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800efb:	3c 2b                	cmp    $0x2b,%al
  800efd:	74 2b                	je     800f2a <strtol+0x49>
  int neg  = 0;
  800eff:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f05:	3c 2d                	cmp    $0x2d,%al
  800f07:	74 2d                	je     800f36 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f09:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f0f:	75 0f                	jne    800f20 <strtol+0x3f>
  800f11:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f14:	74 2c                	je     800f42 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f16:	85 d2                	test   %edx,%edx
  800f18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1d:	0f 44 d0             	cmove  %eax,%edx
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f25:	4c 63 d2             	movslq %edx,%r10
  800f28:	eb 5c                	jmp    800f86 <strtol+0xa5>
    s++;
  800f2a:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f2e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f34:	eb d3                	jmp    800f09 <strtol+0x28>
    s++, neg = 1;
  800f36:	48 83 c7 01          	add    $0x1,%rdi
  800f3a:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f40:	eb c7                	jmp    800f09 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f42:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f46:	74 0f                	je     800f57 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f48:	85 d2                	test   %edx,%edx
  800f4a:	75 d4                	jne    800f20 <strtol+0x3f>
    s++, base = 8;
  800f4c:	48 83 c7 01          	add    $0x1,%rdi
  800f50:	ba 08 00 00 00       	mov    $0x8,%edx
  800f55:	eb c9                	jmp    800f20 <strtol+0x3f>
    s += 2, base = 16;
  800f57:	48 83 c7 02          	add    $0x2,%rdi
  800f5b:	ba 10 00 00 00       	mov    $0x10,%edx
  800f60:	eb be                	jmp    800f20 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f62:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f66:	41 80 f8 19          	cmp    $0x19,%r8b
  800f6a:	77 2f                	ja     800f9b <strtol+0xba>
      dig = *s - 'a' + 10;
  800f6c:	44 0f be c1          	movsbl %cl,%r8d
  800f70:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f74:	39 d1                	cmp    %edx,%ecx
  800f76:	7d 37                	jge    800faf <strtol+0xce>
    s++, val = (val * base) + dig;
  800f78:	48 83 c7 01          	add    $0x1,%rdi
  800f7c:	49 0f af c2          	imul   %r10,%rax
  800f80:	48 63 c9             	movslq %ecx,%rcx
  800f83:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f86:	0f b6 0f             	movzbl (%rdi),%ecx
  800f89:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f8d:	41 80 f8 09          	cmp    $0x9,%r8b
  800f91:	77 cf                	ja     800f62 <strtol+0x81>
      dig = *s - '0';
  800f93:	0f be c9             	movsbl %cl,%ecx
  800f96:	83 e9 30             	sub    $0x30,%ecx
  800f99:	eb d9                	jmp    800f74 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f9b:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f9f:	41 80 f8 19          	cmp    $0x19,%r8b
  800fa3:	77 0a                	ja     800faf <strtol+0xce>
      dig = *s - 'A' + 10;
  800fa5:	44 0f be c1          	movsbl %cl,%r8d
  800fa9:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fad:	eb c5                	jmp    800f74 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800faf:	48 85 f6             	test   %rsi,%rsi
  800fb2:	74 03                	je     800fb7 <strtol+0xd6>
    *endptr = (char *)s;
  800fb4:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fb7:	48 89 c2             	mov    %rax,%rdx
  800fba:	48 f7 da             	neg    %rdx
  800fbd:	45 85 c9             	test   %r9d,%r9d
  800fc0:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fc4:	c3                   	retq   

0000000000800fc5 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fc5:	55                   	push   %rbp
  800fc6:	48 89 e5             	mov    %rsp,%rbp
  800fc9:	53                   	push   %rbx
  800fca:	48 89 fa             	mov    %rdi,%rdx
  800fcd:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd5:	48 89 c3             	mov    %rax,%rbx
  800fd8:	48 89 c7             	mov    %rax,%rdi
  800fdb:	48 89 c6             	mov    %rax,%rsi
  800fde:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fe0:	5b                   	pop    %rbx
  800fe1:	5d                   	pop    %rbp
  800fe2:	c3                   	retq   

0000000000800fe3 <sys_cgetc>:

int
sys_cgetc(void) {
  800fe3:	55                   	push   %rbp
  800fe4:	48 89 e5             	mov    %rsp,%rbp
  800fe7:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fe8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff2:	48 89 ca             	mov    %rcx,%rdx
  800ff5:	48 89 cb             	mov    %rcx,%rbx
  800ff8:	48 89 cf             	mov    %rcx,%rdi
  800ffb:	48 89 ce             	mov    %rcx,%rsi
  800ffe:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801000:	5b                   	pop    %rbx
  801001:	5d                   	pop    %rbp
  801002:	c3                   	retq   

0000000000801003 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801003:	55                   	push   %rbp
  801004:	48 89 e5             	mov    %rsp,%rbp
  801007:	53                   	push   %rbx
  801008:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80100c:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80100f:	be 00 00 00 00       	mov    $0x0,%esi
  801014:	b8 03 00 00 00       	mov    $0x3,%eax
  801019:	48 89 f1             	mov    %rsi,%rcx
  80101c:	48 89 f3             	mov    %rsi,%rbx
  80101f:	48 89 f7             	mov    %rsi,%rdi
  801022:	cd 30                	int    $0x30
  if (check && ret > 0)
  801024:	48 85 c0             	test   %rax,%rax
  801027:	7f 07                	jg     801030 <sys_env_destroy+0x2d>
}
  801029:	48 83 c4 08          	add    $0x8,%rsp
  80102d:	5b                   	pop    %rbx
  80102e:	5d                   	pop    %rbp
  80102f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801030:	49 89 c0             	mov    %rax,%r8
  801033:	b9 03 00 00 00       	mov    $0x3,%ecx
  801038:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  80103f:	00 00 00 
  801042:	be 22 00 00 00       	mov    $0x22,%esi
  801047:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  80104e:	00 00 00 
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  80105d:	00 00 00 
  801060:	41 ff d1             	callq  *%r9

0000000000801063 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801063:	55                   	push   %rbp
  801064:	48 89 e5             	mov    %rsp,%rbp
  801067:	53                   	push   %rbx
  asm volatile("int %1\n"
  801068:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106d:	b8 02 00 00 00       	mov    $0x2,%eax
  801072:	48 89 ca             	mov    %rcx,%rdx
  801075:	48 89 cb             	mov    %rcx,%rbx
  801078:	48 89 cf             	mov    %rcx,%rdi
  80107b:	48 89 ce             	mov    %rcx,%rsi
  80107e:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801080:	5b                   	pop    %rbx
  801081:	5d                   	pop    %rbp
  801082:	c3                   	retq   

0000000000801083 <sys_yield>:

void
sys_yield(void) {
  801083:	55                   	push   %rbp
  801084:	48 89 e5             	mov    %rsp,%rbp
  801087:	53                   	push   %rbx
  asm volatile("int %1\n"
  801088:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801092:	48 89 ca             	mov    %rcx,%rdx
  801095:	48 89 cb             	mov    %rcx,%rbx
  801098:	48 89 cf             	mov    %rcx,%rdi
  80109b:	48 89 ce             	mov    %rcx,%rsi
  80109e:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010a0:	5b                   	pop    %rbx
  8010a1:	5d                   	pop    %rbp
  8010a2:	c3                   	retq   

00000000008010a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010a3:	55                   	push   %rbp
  8010a4:	48 89 e5             	mov    %rsp,%rbp
  8010a7:	53                   	push   %rbx
  8010a8:	48 83 ec 08          	sub    $0x8,%rsp
  8010ac:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010af:	4c 63 c7             	movslq %edi,%r8
  8010b2:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010b5:	be 00 00 00 00       	mov    $0x0,%esi
  8010ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8010bf:	4c 89 c2             	mov    %r8,%rdx
  8010c2:	48 89 f7             	mov    %rsi,%rdi
  8010c5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010c7:	48 85 c0             	test   %rax,%rax
  8010ca:	7f 07                	jg     8010d3 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8010cc:	48 83 c4 08          	add    $0x8,%rsp
  8010d0:	5b                   	pop    %rbx
  8010d1:	5d                   	pop    %rbp
  8010d2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010d3:	49 89 c0             	mov    %rax,%r8
  8010d6:	b9 04 00 00 00       	mov    $0x4,%ecx
  8010db:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  8010e2:	00 00 00 
  8010e5:	be 22 00 00 00       	mov    $0x22,%esi
  8010ea:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  8010f1:	00 00 00 
  8010f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f9:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  801100:	00 00 00 
  801103:	41 ff d1             	callq  *%r9

0000000000801106 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801106:	55                   	push   %rbp
  801107:	48 89 e5             	mov    %rsp,%rbp
  80110a:	53                   	push   %rbx
  80110b:	48 83 ec 08          	sub    $0x8,%rsp
  80110f:	41 89 f9             	mov    %edi,%r9d
  801112:	49 89 f2             	mov    %rsi,%r10
  801115:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801118:	4d 63 c9             	movslq %r9d,%r9
  80111b:	48 63 da             	movslq %edx,%rbx
  80111e:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801121:	b8 05 00 00 00       	mov    $0x5,%eax
  801126:	4c 89 ca             	mov    %r9,%rdx
  801129:	4c 89 d1             	mov    %r10,%rcx
  80112c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80112e:	48 85 c0             	test   %rax,%rax
  801131:	7f 07                	jg     80113a <sys_page_map+0x34>
}
  801133:	48 83 c4 08          	add    $0x8,%rsp
  801137:	5b                   	pop    %rbx
  801138:	5d                   	pop    %rbp
  801139:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80113a:	49 89 c0             	mov    %rax,%r8
  80113d:	b9 05 00 00 00       	mov    $0x5,%ecx
  801142:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  801149:	00 00 00 
  80114c:	be 22 00 00 00       	mov    $0x22,%esi
  801151:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801158:	00 00 00 
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
  801160:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  801167:	00 00 00 
  80116a:	41 ff d1             	callq  *%r9

000000000080116d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80116d:	55                   	push   %rbp
  80116e:	48 89 e5             	mov    %rsp,%rbp
  801171:	53                   	push   %rbx
  801172:	48 83 ec 08          	sub    $0x8,%rsp
  801176:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801179:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80117c:	be 00 00 00 00       	mov    $0x0,%esi
  801181:	b8 06 00 00 00       	mov    $0x6,%eax
  801186:	48 89 f3             	mov    %rsi,%rbx
  801189:	48 89 f7             	mov    %rsi,%rdi
  80118c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80118e:	48 85 c0             	test   %rax,%rax
  801191:	7f 07                	jg     80119a <sys_page_unmap+0x2d>
}
  801193:	48 83 c4 08          	add    $0x8,%rsp
  801197:	5b                   	pop    %rbx
  801198:	5d                   	pop    %rbp
  801199:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80119a:	49 89 c0             	mov    %rax,%r8
  80119d:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011a2:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  8011a9:	00 00 00 
  8011ac:	be 22 00 00 00       	mov    $0x22,%esi
  8011b1:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  8011b8:	00 00 00 
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c0:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  8011c7:	00 00 00 
  8011ca:	41 ff d1             	callq  *%r9

00000000008011cd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8011cd:	55                   	push   %rbp
  8011ce:	48 89 e5             	mov    %rsp,%rbp
  8011d1:	53                   	push   %rbx
  8011d2:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011d6:	48 63 d7             	movslq %edi,%rdx
  8011d9:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8011dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e6:	48 89 df             	mov    %rbx,%rdi
  8011e9:	48 89 de             	mov    %rbx,%rsi
  8011ec:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011ee:	48 85 c0             	test   %rax,%rax
  8011f1:	7f 07                	jg     8011fa <sys_env_set_status+0x2d>
}
  8011f3:	48 83 c4 08          	add    $0x8,%rsp
  8011f7:	5b                   	pop    %rbx
  8011f8:	5d                   	pop    %rbp
  8011f9:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011fa:	49 89 c0             	mov    %rax,%r8
  8011fd:	b9 08 00 00 00       	mov    $0x8,%ecx
  801202:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  801209:	00 00 00 
  80120c:	be 22 00 00 00       	mov    $0x22,%esi
  801211:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801218:	00 00 00 
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  801227:	00 00 00 
  80122a:	41 ff d1             	callq  *%r9

000000000080122d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80122d:	55                   	push   %rbp
  80122e:	48 89 e5             	mov    %rsp,%rbp
  801231:	53                   	push   %rbx
  801232:	48 83 ec 08          	sub    $0x8,%rsp
  801236:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801239:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80123c:	be 00 00 00 00       	mov    $0x0,%esi
  801241:	b8 09 00 00 00       	mov    $0x9,%eax
  801246:	48 89 f3             	mov    %rsi,%rbx
  801249:	48 89 f7             	mov    %rsi,%rdi
  80124c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80124e:	48 85 c0             	test   %rax,%rax
  801251:	7f 07                	jg     80125a <sys_env_set_pgfault_upcall+0x2d>
}
  801253:	48 83 c4 08          	add    $0x8,%rsp
  801257:	5b                   	pop    %rbx
  801258:	5d                   	pop    %rbp
  801259:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80125a:	49 89 c0             	mov    %rax,%r8
  80125d:	b9 09 00 00 00       	mov    $0x9,%ecx
  801262:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  801269:	00 00 00 
  80126c:	be 22 00 00 00       	mov    $0x22,%esi
  801271:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  801278:	00 00 00 
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
  801280:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  801287:	00 00 00 
  80128a:	41 ff d1             	callq  *%r9

000000000080128d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80128d:	55                   	push   %rbp
  80128e:	48 89 e5             	mov    %rsp,%rbp
  801291:	53                   	push   %rbx
  801292:	49 89 f0             	mov    %rsi,%r8
  801295:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801298:	48 63 d7             	movslq %edi,%rdx
  80129b:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  80129e:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012a3:	be 00 00 00 00       	mov    $0x0,%esi
  8012a8:	4c 89 c1             	mov    %r8,%rcx
  8012ab:	cd 30                	int    $0x30
}
  8012ad:	5b                   	pop    %rbx
  8012ae:	5d                   	pop    %rbp
  8012af:	c3                   	retq   

00000000008012b0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012b0:	55                   	push   %rbp
  8012b1:	48 89 e5             	mov    %rsp,%rbp
  8012b4:	53                   	push   %rbx
  8012b5:	48 83 ec 08          	sub    $0x8,%rsp
  8012b9:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012bc:	be 00 00 00 00       	mov    $0x0,%esi
  8012c1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012c6:	48 89 f1             	mov    %rsi,%rcx
  8012c9:	48 89 f3             	mov    %rsi,%rbx
  8012cc:	48 89 f7             	mov    %rsi,%rdi
  8012cf:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012d1:	48 85 c0             	test   %rax,%rax
  8012d4:	7f 07                	jg     8012dd <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8012d6:	48 83 c4 08          	add    $0x8,%rsp
  8012da:	5b                   	pop    %rbx
  8012db:	5d                   	pop    %rbp
  8012dc:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012dd:	49 89 c0             	mov    %rax,%r8
  8012e0:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8012e5:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  8012ec:	00 00 00 
  8012ef:	be 22 00 00 00       	mov    $0x22,%esi
  8012f4:	48 bf 3f 18 80 00 00 	movabs $0x80183f,%rdi
  8012fb:	00 00 00 
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	49 b9 10 13 80 00 00 	movabs $0x801310,%r9
  80130a:	00 00 00 
  80130d:	41 ff d1             	callq  *%r9

0000000000801310 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801310:	55                   	push   %rbp
  801311:	48 89 e5             	mov    %rsp,%rbp
  801314:	41 56                	push   %r14
  801316:	41 55                	push   %r13
  801318:	41 54                	push   %r12
  80131a:	53                   	push   %rbx
  80131b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801322:	49 89 fd             	mov    %rdi,%r13
  801325:	41 89 f6             	mov    %esi,%r14d
  801328:	49 89 d4             	mov    %rdx,%r12
  80132b:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801332:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801339:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801340:	84 c0                	test   %al,%al
  801342:	74 26                	je     80136a <_panic+0x5a>
  801344:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80134b:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801352:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801356:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80135a:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80135e:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801362:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801366:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80136a:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801371:	00 00 00 
  801374:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80137b:	00 00 00 
  80137e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801382:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801389:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801390:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801397:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80139e:	00 00 00 
  8013a1:	48 8b 18             	mov    (%rax),%rbx
  8013a4:	48 b8 63 10 80 00 00 	movabs $0x801063,%rax
  8013ab:	00 00 00 
  8013ae:	ff d0                	callq  *%rax
  8013b0:	45 89 f0             	mov    %r14d,%r8d
  8013b3:	4c 89 e9             	mov    %r13,%rcx
  8013b6:	48 89 da             	mov    %rbx,%rdx
  8013b9:	89 c6                	mov    %eax,%esi
  8013bb:	48 bf 50 18 80 00 00 	movabs $0x801850,%rdi
  8013c2:	00 00 00 
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ca:	48 bb d1 01 80 00 00 	movabs $0x8001d1,%rbx
  8013d1:	00 00 00 
  8013d4:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8013d6:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8013dd:	4c 89 e7             	mov    %r12,%rdi
  8013e0:	48 b8 69 01 80 00 00 	movabs $0x800169,%rax
  8013e7:	00 00 00 
  8013ea:	ff d0                	callq  *%rax
  cprintf("\n");
  8013ec:	48 bf 1c 14 80 00 00 	movabs $0x80141c,%rdi
  8013f3:	00 00 00 
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8013fd:	cc                   	int3   
  while (1)
  8013fe:	eb fd                	jmp    8013fd <_panic+0xed>
