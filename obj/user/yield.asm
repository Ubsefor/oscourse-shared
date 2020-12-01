
obj/user/yield:     file format elf64-x86-64


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
  800023:	e8 c6 00 00 00       	callq  8000ee <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// yield the processor to other environments

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 57                	push   %r15
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  800042:	00 00 00 
  800045:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80004b:	48 bf a0 14 80 00 00 	movabs $0x8014a0,%rdi
  800052:	00 00 00 
  800055:	b8 00 00 00 00       	mov    $0x0,%eax
  80005a:	48 ba 6d 02 80 00 00 	movabs $0x80026d,%rdx
  800061:	00 00 00 
  800064:	ff d2                	callq  *%rdx
  for (i = 0; i < 5; i++) {
  800066:	bb 00 00 00 00       	mov    $0x0,%ebx
    sys_yield();
  80006b:	49 bf 1f 11 80 00 00 	movabs $0x80111f,%r15
  800072:	00 00 00 
    cprintf("Back in environment %08x, iteration %d.\n",
            thisenv->env_id, i);
  800075:	49 be 08 20 80 00 00 	movabs $0x802008,%r14
  80007c:	00 00 00 
    cprintf("Back in environment %08x, iteration %d.\n",
  80007f:	49 bd c0 14 80 00 00 	movabs $0x8014c0,%r13
  800086:	00 00 00 
  800089:	49 bc 6d 02 80 00 00 	movabs $0x80026d,%r12
  800090:	00 00 00 
    sys_yield();
  800093:	41 ff d7             	callq  *%r15
            thisenv->env_id, i);
  800096:	49 8b 06             	mov    (%r14),%rax
    cprintf("Back in environment %08x, iteration %d.\n",
  800099:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80009f:	89 da                	mov    %ebx,%edx
  8000a1:	4c 89 ef             	mov    %r13,%rdi
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	41 ff d4             	callq  *%r12
  for (i = 0; i < 5; i++) {
  8000ac:	83 c3 01             	add    $0x1,%ebx
  8000af:	83 fb 05             	cmp    $0x5,%ebx
  8000b2:	75 df                	jne    800093 <umain+0x69>
  }
  cprintf("All done in environment %08x.\n", thisenv->env_id);
  8000b4:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  8000bb:	00 00 00 
  8000be:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8000c4:	48 bf f0 14 80 00 00 	movabs $0x8014f0,%rdi
  8000cb:	00 00 00 
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	48 ba 6d 02 80 00 00 	movabs $0x80026d,%rdx
  8000da:	00 00 00 
  8000dd:	ff d2                	callq  *%rdx
}
  8000df:	48 83 c4 08          	add    $0x8,%rsp
  8000e3:	5b                   	pop    %rbx
  8000e4:	41 5c                	pop    %r12
  8000e6:	41 5d                	pop    %r13
  8000e8:	41 5e                	pop    %r14
  8000ea:	41 5f                	pop    %r15
  8000ec:	5d                   	pop    %rbp
  8000ed:	c3                   	retq   

00000000008000ee <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  8000ee:	55                   	push   %rbp
  8000ef:	48 89 e5             	mov    %rsp,%rbp
  8000f2:	41 56                	push   %r14
  8000f4:	41 55                	push   %r13
  8000f6:	41 54                	push   %r12
  8000f8:	53                   	push   %rbx
  8000f9:	41 89 fd             	mov    %edi,%r13d
  8000fc:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  8000ff:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800106:	00 00 00 
  800109:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800110:	00 00 00 
  800113:	48 39 c2             	cmp    %rax,%rdx
  800116:	73 23                	jae    80013b <libmain+0x4d>
  800118:	48 89 d3             	mov    %rdx,%rbx
  80011b:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80011f:	48 29 d0             	sub    %rdx,%rax
  800122:	48 c1 e8 03          	shr    $0x3,%rax
  800126:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80012b:	b8 00 00 00 00       	mov    $0x0,%eax
  800130:	ff 13                	callq  *(%rbx)
    ctor++;
  800132:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800136:	4c 39 e3             	cmp    %r12,%rbx
  800139:	75 f0                	jne    80012b <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80013b:	48 b8 ff 10 80 00 00 	movabs $0x8010ff,%rax
  800142:	00 00 00 
  800145:	ff d0                	callq  *%rax
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800150:	48 c1 e0 05          	shl    $0x5,%rax
  800154:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80015b:	00 00 00 
  80015e:	48 01 d0             	add    %rdx,%rax
  800161:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  800168:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80016b:	45 85 ed             	test   %r13d,%r13d
  80016e:	7e 0d                	jle    80017d <libmain+0x8f>
    binaryname = argv[0];
  800170:	49 8b 06             	mov    (%r14),%rax
  800173:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  80017a:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80017d:	4c 89 f6             	mov    %r14,%rsi
  800180:	44 89 ef             	mov    %r13d,%edi
  800183:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  80018a:	00 00 00 
  80018d:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80018f:	48 b8 a4 01 80 00 00 	movabs $0x8001a4,%rax
  800196:	00 00 00 
  800199:	ff d0                	callq  *%rax
#endif
}
  80019b:	5b                   	pop    %rbx
  80019c:	41 5c                	pop    %r12
  80019e:	41 5d                	pop    %r13
  8001a0:	41 5e                	pop    %r14
  8001a2:	5d                   	pop    %rbp
  8001a3:	c3                   	retq   

00000000008001a4 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001a4:	55                   	push   %rbp
  8001a5:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8001a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ad:	48 b8 9f 10 80 00 00 	movabs $0x80109f,%rax
  8001b4:	00 00 00 
  8001b7:	ff d0                	callq  *%rax
}
  8001b9:	5d                   	pop    %rbp
  8001ba:	c3                   	retq   

00000000008001bb <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8001bb:	55                   	push   %rbp
  8001bc:	48 89 e5             	mov    %rsp,%rbp
  8001bf:	53                   	push   %rbx
  8001c0:	48 83 ec 08          	sub    $0x8,%rsp
  8001c4:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8001c7:	8b 06                	mov    (%rsi),%eax
  8001c9:	8d 50 01             	lea    0x1(%rax),%edx
  8001cc:	89 16                	mov    %edx,(%rsi)
  8001ce:	48 98                	cltq   
  8001d0:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8001d5:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8001db:	74 0b                	je     8001e8 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8001dd:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8001e1:	48 83 c4 08          	add    $0x8,%rsp
  8001e5:	5b                   	pop    %rbx
  8001e6:	5d                   	pop    %rbp
  8001e7:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8001e8:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8001ec:	be ff 00 00 00       	mov    $0xff,%esi
  8001f1:	48 b8 61 10 80 00 00 	movabs $0x801061,%rax
  8001f8:	00 00 00 
  8001fb:	ff d0                	callq  *%rax
    b->idx = 0;
  8001fd:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800203:	eb d8                	jmp    8001dd <putch+0x22>

0000000000800205 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800205:	55                   	push   %rbp
  800206:	48 89 e5             	mov    %rsp,%rbp
  800209:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800210:	48 89 fa             	mov    %rdi,%rdx
  800213:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800216:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80021d:	00 00 00 
  b.cnt = 0;
  800220:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800227:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80022a:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800231:	48 bf bb 01 80 00 00 	movabs $0x8001bb,%rdi
  800238:	00 00 00 
  80023b:	48 b8 2b 04 80 00 00 	movabs $0x80042b,%rax
  800242:	00 00 00 
  800245:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800247:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80024e:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800255:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800259:	48 b8 61 10 80 00 00 	movabs $0x801061,%rax
  800260:	00 00 00 
  800263:	ff d0                	callq  *%rax

  return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80026b:	c9                   	leaveq 
  80026c:	c3                   	retq   

000000000080026d <cprintf>:

int
cprintf(const char *fmt, ...) {
  80026d:	55                   	push   %rbp
  80026e:	48 89 e5             	mov    %rsp,%rbp
  800271:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800278:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80027f:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800286:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80028d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800294:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80029b:	84 c0                	test   %al,%al
  80029d:	74 20                	je     8002bf <cprintf+0x52>
  80029f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8002a3:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8002a7:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8002ab:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8002af:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8002b3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8002b7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8002bb:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8002bf:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8002c6:	00 00 00 
  8002c9:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8002d0:	00 00 00 
  8002d3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002d7:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8002de:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8002e5:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8002ec:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8002f3:	48 b8 05 02 80 00 00 	movabs $0x800205,%rax
  8002fa:	00 00 00 
  8002fd:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8002ff:	c9                   	leaveq 
  800300:	c3                   	retq   

0000000000800301 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800301:	55                   	push   %rbp
  800302:	48 89 e5             	mov    %rsp,%rbp
  800305:	41 57                	push   %r15
  800307:	41 56                	push   %r14
  800309:	41 55                	push   %r13
  80030b:	41 54                	push   %r12
  80030d:	53                   	push   %rbx
  80030e:	48 83 ec 18          	sub    $0x18,%rsp
  800312:	49 89 fc             	mov    %rdi,%r12
  800315:	49 89 f5             	mov    %rsi,%r13
  800318:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80031c:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80031f:	41 89 cf             	mov    %ecx,%r15d
  800322:	49 39 d7             	cmp    %rdx,%r15
  800325:	76 45                	jbe    80036c <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800327:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80032b:	85 db                	test   %ebx,%ebx
  80032d:	7e 0e                	jle    80033d <printnum+0x3c>
      putch(padc, putdat);
  80032f:	4c 89 ee             	mov    %r13,%rsi
  800332:	44 89 f7             	mov    %r14d,%edi
  800335:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800338:	83 eb 01             	sub    $0x1,%ebx
  80033b:	75 f2                	jne    80032f <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80033d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
  800346:	49 f7 f7             	div    %r15
  800349:	48 b8 19 15 80 00 00 	movabs $0x801519,%rax
  800350:	00 00 00 
  800353:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800357:	4c 89 ee             	mov    %r13,%rsi
  80035a:	41 ff d4             	callq  *%r12
}
  80035d:	48 83 c4 18          	add    $0x18,%rsp
  800361:	5b                   	pop    %rbx
  800362:	41 5c                	pop    %r12
  800364:	41 5d                	pop    %r13
  800366:	41 5e                	pop    %r14
  800368:	41 5f                	pop    %r15
  80036a:	5d                   	pop    %rbp
  80036b:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80036c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	49 f7 f7             	div    %r15
  800378:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80037c:	48 89 c2             	mov    %rax,%rdx
  80037f:	48 b8 01 03 80 00 00 	movabs $0x800301,%rax
  800386:	00 00 00 
  800389:	ff d0                	callq  *%rax
  80038b:	eb b0                	jmp    80033d <printnum+0x3c>

000000000080038d <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80038d:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800391:	48 8b 06             	mov    (%rsi),%rax
  800394:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800398:	73 0a                	jae    8003a4 <sprintputch+0x17>
    *b->buf++ = ch;
  80039a:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80039e:	48 89 16             	mov    %rdx,(%rsi)
  8003a1:	40 88 38             	mov    %dil,(%rax)
}
  8003a4:	c3                   	retq   

00000000008003a5 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8003a5:	55                   	push   %rbp
  8003a6:	48 89 e5             	mov    %rsp,%rbp
  8003a9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003b0:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003b7:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003be:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003c5:	84 c0                	test   %al,%al
  8003c7:	74 20                	je     8003e9 <printfmt+0x44>
  8003c9:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003cd:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003d1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003d5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003d9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003dd:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003e1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003e5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8003e9:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8003f0:	00 00 00 
  8003f3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003fa:	00 00 00 
  8003fd:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800401:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800408:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80040f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800416:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80041d:	48 b8 2b 04 80 00 00 	movabs $0x80042b,%rax
  800424:	00 00 00 
  800427:	ff d0                	callq  *%rax
}
  800429:	c9                   	leaveq 
  80042a:	c3                   	retq   

000000000080042b <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80042b:	55                   	push   %rbp
  80042c:	48 89 e5             	mov    %rsp,%rbp
  80042f:	41 57                	push   %r15
  800431:	41 56                	push   %r14
  800433:	41 55                	push   %r13
  800435:	41 54                	push   %r12
  800437:	53                   	push   %rbx
  800438:	48 83 ec 48          	sub    $0x48,%rsp
  80043c:	49 89 fd             	mov    %rdi,%r13
  80043f:	49 89 f7             	mov    %rsi,%r15
  800442:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800445:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800449:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80044d:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800451:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800455:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800459:	41 0f b6 3e          	movzbl (%r14),%edi
  80045d:	83 ff 25             	cmp    $0x25,%edi
  800460:	74 18                	je     80047a <vprintfmt+0x4f>
      if (ch == '\0')
  800462:	85 ff                	test   %edi,%edi
  800464:	0f 84 8c 06 00 00    	je     800af6 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80046a:	4c 89 fe             	mov    %r15,%rsi
  80046d:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800470:	49 89 de             	mov    %rbx,%r14
  800473:	eb e0                	jmp    800455 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800475:	49 89 de             	mov    %rbx,%r14
  800478:	eb db                	jmp    800455 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80047a:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80047e:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800482:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800489:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80048f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800493:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800498:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80049e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8004a4:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8004a9:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8004ae:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8004b2:	0f b6 13             	movzbl (%rbx),%edx
  8004b5:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8004b8:	3c 55                	cmp    $0x55,%al
  8004ba:	0f 87 8b 05 00 00    	ja     800a4b <vprintfmt+0x620>
  8004c0:	0f b6 c0             	movzbl %al,%eax
  8004c3:	49 bb 00 16 80 00 00 	movabs $0x801600,%r11
  8004ca:	00 00 00 
  8004cd:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8004d1:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8004d4:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8004d8:	eb d4                	jmp    8004ae <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004da:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8004dd:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8004e1:	eb cb                	jmp    8004ae <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004e3:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8004e6:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8004ea:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8004ee:	8d 50 d0             	lea    -0x30(%rax),%edx
  8004f1:	83 fa 09             	cmp    $0x9,%edx
  8004f4:	77 7e                	ja     800574 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8004f6:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8004fa:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8004fe:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800503:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800507:	8d 50 d0             	lea    -0x30(%rax),%edx
  80050a:	83 fa 09             	cmp    $0x9,%edx
  80050d:	76 e7                	jbe    8004f6 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80050f:	4c 89 f3             	mov    %r14,%rbx
  800512:	eb 19                	jmp    80052d <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800514:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800517:	83 f8 2f             	cmp    $0x2f,%eax
  80051a:	77 2a                	ja     800546 <vprintfmt+0x11b>
  80051c:	89 c2                	mov    %eax,%edx
  80051e:	4c 01 d2             	add    %r10,%rdx
  800521:	83 c0 08             	add    $0x8,%eax
  800524:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800527:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80052a:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80052d:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800531:	0f 89 77 ff ff ff    	jns    8004ae <vprintfmt+0x83>
          width = precision, precision = -1;
  800537:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80053b:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800541:	e9 68 ff ff ff       	jmpq   8004ae <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800546:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80054a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80054e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800552:	eb d3                	jmp    800527 <vprintfmt+0xfc>
        if (width < 0)
  800554:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800557:	85 c0                	test   %eax,%eax
  800559:	41 0f 48 c0          	cmovs  %r8d,%eax
  80055d:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800560:	4c 89 f3             	mov    %r14,%rbx
  800563:	e9 46 ff ff ff       	jmpq   8004ae <vprintfmt+0x83>
  800568:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80056b:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80056f:	e9 3a ff ff ff       	jmpq   8004ae <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800574:	4c 89 f3             	mov    %r14,%rbx
  800577:	eb b4                	jmp    80052d <vprintfmt+0x102>
        lflag++;
  800579:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80057c:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80057f:	e9 2a ff ff ff       	jmpq   8004ae <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800584:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800587:	83 f8 2f             	cmp    $0x2f,%eax
  80058a:	77 19                	ja     8005a5 <vprintfmt+0x17a>
  80058c:	89 c2                	mov    %eax,%edx
  80058e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800592:	83 c0 08             	add    $0x8,%eax
  800595:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800598:	4c 89 fe             	mov    %r15,%rsi
  80059b:	8b 3a                	mov    (%rdx),%edi
  80059d:	41 ff d5             	callq  *%r13
        break;
  8005a0:	e9 b0 fe ff ff       	jmpq   800455 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8005a5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005a9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005ad:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005b1:	eb e5                	jmp    800598 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8005b3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005b6:	83 f8 2f             	cmp    $0x2f,%eax
  8005b9:	77 5b                	ja     800616 <vprintfmt+0x1eb>
  8005bb:	89 c2                	mov    %eax,%edx
  8005bd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005c1:	83 c0 08             	add    $0x8,%eax
  8005c4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005c7:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8005c9:	89 c8                	mov    %ecx,%eax
  8005cb:	c1 f8 1f             	sar    $0x1f,%eax
  8005ce:	31 c1                	xor    %eax,%ecx
  8005d0:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d2:	83 f9 0b             	cmp    $0xb,%ecx
  8005d5:	7f 4d                	jg     800624 <vprintfmt+0x1f9>
  8005d7:	48 63 c1             	movslq %ecx,%rax
  8005da:	48 ba c0 18 80 00 00 	movabs $0x8018c0,%rdx
  8005e1:	00 00 00 
  8005e4:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8005e8:	48 85 c0             	test   %rax,%rax
  8005eb:	74 37                	je     800624 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8005ed:	48 89 c1             	mov    %rax,%rcx
  8005f0:	48 ba 3a 15 80 00 00 	movabs $0x80153a,%rdx
  8005f7:	00 00 00 
  8005fa:	4c 89 fe             	mov    %r15,%rsi
  8005fd:	4c 89 ef             	mov    %r13,%rdi
  800600:	b8 00 00 00 00       	mov    $0x0,%eax
  800605:	48 bb a5 03 80 00 00 	movabs $0x8003a5,%rbx
  80060c:	00 00 00 
  80060f:	ff d3                	callq  *%rbx
  800611:	e9 3f fe ff ff       	jmpq   800455 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800616:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80061a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80061e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800622:	eb a3                	jmp    8005c7 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800624:	48 ba 31 15 80 00 00 	movabs $0x801531,%rdx
  80062b:	00 00 00 
  80062e:	4c 89 fe             	mov    %r15,%rsi
  800631:	4c 89 ef             	mov    %r13,%rdi
  800634:	b8 00 00 00 00       	mov    $0x0,%eax
  800639:	48 bb a5 03 80 00 00 	movabs $0x8003a5,%rbx
  800640:	00 00 00 
  800643:	ff d3                	callq  *%rbx
  800645:	e9 0b fe ff ff       	jmpq   800455 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80064a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80064d:	83 f8 2f             	cmp    $0x2f,%eax
  800650:	77 4b                	ja     80069d <vprintfmt+0x272>
  800652:	89 c2                	mov    %eax,%edx
  800654:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800658:	83 c0 08             	add    $0x8,%eax
  80065b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80065e:	48 8b 02             	mov    (%rdx),%rax
  800661:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800665:	48 85 c0             	test   %rax,%rax
  800668:	0f 84 05 04 00 00    	je     800a73 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80066e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800672:	7e 06                	jle    80067a <vprintfmt+0x24f>
  800674:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800678:	75 31                	jne    8006ab <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80067e:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800682:	0f b6 00             	movzbl (%rax),%eax
  800685:	0f be f8             	movsbl %al,%edi
  800688:	85 ff                	test   %edi,%edi
  80068a:	0f 84 c3 00 00 00    	je     800753 <vprintfmt+0x328>
  800690:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800694:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800698:	e9 85 00 00 00       	jmpq   800722 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80069d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006a1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006a5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006a9:	eb b3                	jmp    80065e <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	49 63 f4             	movslq %r12d,%rsi
  8006ae:	48 89 c7             	mov    %rax,%rdi
  8006b1:	48 b8 02 0c 80 00 00 	movabs $0x800c02,%rax
  8006b8:	00 00 00 
  8006bb:	ff d0                	callq  *%rax
  8006bd:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8006c0:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8006c3:	85 f6                	test   %esi,%esi
  8006c5:	7e 22                	jle    8006e9 <vprintfmt+0x2be>
            putch(padc, putdat);
  8006c7:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8006cb:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8006cf:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8006d3:	4c 89 fe             	mov    %r15,%rsi
  8006d6:	89 df                	mov    %ebx,%edi
  8006d8:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8006db:	41 83 ec 01          	sub    $0x1,%r12d
  8006df:	75 f2                	jne    8006d3 <vprintfmt+0x2a8>
  8006e1:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8006e5:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e9:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8006ed:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8006f1:	0f b6 00             	movzbl (%rax),%eax
  8006f4:	0f be f8             	movsbl %al,%edi
  8006f7:	85 ff                	test   %edi,%edi
  8006f9:	0f 84 56 fd ff ff    	je     800455 <vprintfmt+0x2a>
  8006ff:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800703:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800707:	eb 19                	jmp    800722 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800709:	4c 89 fe             	mov    %r15,%rsi
  80070c:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070f:	41 83 ee 01          	sub    $0x1,%r14d
  800713:	48 83 c3 01          	add    $0x1,%rbx
  800717:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80071b:	0f be f8             	movsbl %al,%edi
  80071e:	85 ff                	test   %edi,%edi
  800720:	74 29                	je     80074b <vprintfmt+0x320>
  800722:	45 85 e4             	test   %r12d,%r12d
  800725:	78 06                	js     80072d <vprintfmt+0x302>
  800727:	41 83 ec 01          	sub    $0x1,%r12d
  80072b:	78 48                	js     800775 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80072d:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800731:	74 d6                	je     800709 <vprintfmt+0x2de>
  800733:	0f be c0             	movsbl %al,%eax
  800736:	83 e8 20             	sub    $0x20,%eax
  800739:	83 f8 5e             	cmp    $0x5e,%eax
  80073c:	76 cb                	jbe    800709 <vprintfmt+0x2de>
            putch('?', putdat);
  80073e:	4c 89 fe             	mov    %r15,%rsi
  800741:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800746:	41 ff d5             	callq  *%r13
  800749:	eb c4                	jmp    80070f <vprintfmt+0x2e4>
  80074b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80074f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800753:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800756:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80075a:	0f 8e f5 fc ff ff    	jle    800455 <vprintfmt+0x2a>
          putch(' ', putdat);
  800760:	4c 89 fe             	mov    %r15,%rsi
  800763:	bf 20 00 00 00       	mov    $0x20,%edi
  800768:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80076b:	83 eb 01             	sub    $0x1,%ebx
  80076e:	75 f0                	jne    800760 <vprintfmt+0x335>
  800770:	e9 e0 fc ff ff       	jmpq   800455 <vprintfmt+0x2a>
  800775:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800779:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80077d:	eb d4                	jmp    800753 <vprintfmt+0x328>
  if (lflag >= 2)
  80077f:	83 f9 01             	cmp    $0x1,%ecx
  800782:	7f 1d                	jg     8007a1 <vprintfmt+0x376>
  else if (lflag)
  800784:	85 c9                	test   %ecx,%ecx
  800786:	74 5e                	je     8007e6 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800788:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80078b:	83 f8 2f             	cmp    $0x2f,%eax
  80078e:	77 48                	ja     8007d8 <vprintfmt+0x3ad>
  800790:	89 c2                	mov    %eax,%edx
  800792:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800796:	83 c0 08             	add    $0x8,%eax
  800799:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80079c:	48 8b 1a             	mov    (%rdx),%rbx
  80079f:	eb 17                	jmp    8007b8 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8007a1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007a4:	83 f8 2f             	cmp    $0x2f,%eax
  8007a7:	77 21                	ja     8007ca <vprintfmt+0x39f>
  8007a9:	89 c2                	mov    %eax,%edx
  8007ab:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007af:	83 c0 08             	add    $0x8,%eax
  8007b2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007b5:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8007b8:	48 85 db             	test   %rbx,%rbx
  8007bb:	78 50                	js     80080d <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8007bd:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8007c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c5:	e9 b4 01 00 00       	jmpq   80097e <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8007ca:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ce:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007d2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007d6:	eb dd                	jmp    8007b5 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8007d8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007dc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007e0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e4:	eb b6                	jmp    80079c <vprintfmt+0x371>
    return va_arg(*ap, int);
  8007e6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007e9:	83 f8 2f             	cmp    $0x2f,%eax
  8007ec:	77 11                	ja     8007ff <vprintfmt+0x3d4>
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007f4:	83 c0 08             	add    $0x8,%eax
  8007f7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007fa:	48 63 1a             	movslq (%rdx),%rbx
  8007fd:	eb b9                	jmp    8007b8 <vprintfmt+0x38d>
  8007ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800803:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800807:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80080b:	eb ed                	jmp    8007fa <vprintfmt+0x3cf>
          putch('-', putdat);
  80080d:	4c 89 fe             	mov    %r15,%rsi
  800810:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800815:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800818:	48 89 da             	mov    %rbx,%rdx
  80081b:	48 f7 da             	neg    %rdx
        base = 10;
  80081e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800823:	e9 56 01 00 00       	jmpq   80097e <vprintfmt+0x553>
  if (lflag >= 2)
  800828:	83 f9 01             	cmp    $0x1,%ecx
  80082b:	7f 25                	jg     800852 <vprintfmt+0x427>
  else if (lflag)
  80082d:	85 c9                	test   %ecx,%ecx
  80082f:	74 5e                	je     80088f <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800831:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800834:	83 f8 2f             	cmp    $0x2f,%eax
  800837:	77 48                	ja     800881 <vprintfmt+0x456>
  800839:	89 c2                	mov    %eax,%edx
  80083b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80083f:	83 c0 08             	add    $0x8,%eax
  800842:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800845:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800848:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80084d:	e9 2c 01 00 00       	jmpq   80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800852:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800855:	83 f8 2f             	cmp    $0x2f,%eax
  800858:	77 19                	ja     800873 <vprintfmt+0x448>
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800860:	83 c0 08             	add    $0x8,%eax
  800863:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800866:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800869:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80086e:	e9 0b 01 00 00       	jmpq   80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800873:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800877:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80087f:	eb e5                	jmp    800866 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800881:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800885:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800889:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80088d:	eb b6                	jmp    800845 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80088f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800892:	83 f8 2f             	cmp    $0x2f,%eax
  800895:	77 18                	ja     8008af <vprintfmt+0x484>
  800897:	89 c2                	mov    %eax,%edx
  800899:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80089d:	83 c0 08             	add    $0x8,%eax
  8008a0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a3:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8008a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008aa:	e9 cf 00 00 00       	jmpq   80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008af:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008bb:	eb e6                	jmp    8008a3 <vprintfmt+0x478>
  if (lflag >= 2)
  8008bd:	83 f9 01             	cmp    $0x1,%ecx
  8008c0:	7f 25                	jg     8008e7 <vprintfmt+0x4bc>
  else if (lflag)
  8008c2:	85 c9                	test   %ecx,%ecx
  8008c4:	74 5b                	je     800921 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8008c6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008c9:	83 f8 2f             	cmp    $0x2f,%eax
  8008cc:	77 45                	ja     800913 <vprintfmt+0x4e8>
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d4:	83 c0 08             	add    $0x8,%eax
  8008d7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008da:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8008dd:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008e2:	e9 97 00 00 00       	jmpq   80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008e7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ea:	83 f8 2f             	cmp    $0x2f,%eax
  8008ed:	77 16                	ja     800905 <vprintfmt+0x4da>
  8008ef:	89 c2                	mov    %eax,%edx
  8008f1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f5:	83 c0 08             	add    $0x8,%eax
  8008f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fb:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8008fe:	b9 08 00 00 00       	mov    $0x8,%ecx
  800903:	eb 79                	jmp    80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800905:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800909:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80090d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800911:	eb e8                	jmp    8008fb <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800913:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800917:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091f:	eb b9                	jmp    8008da <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800921:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800924:	83 f8 2f             	cmp    $0x2f,%eax
  800927:	77 15                	ja     80093e <vprintfmt+0x513>
  800929:	89 c2                	mov    %eax,%edx
  80092b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092f:	83 c0 08             	add    $0x8,%eax
  800932:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800935:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800937:	b9 08 00 00 00       	mov    $0x8,%ecx
  80093c:	eb 40                	jmp    80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80093e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800942:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800946:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094a:	eb e9                	jmp    800935 <vprintfmt+0x50a>
        putch('0', putdat);
  80094c:	4c 89 fe             	mov    %r15,%rsi
  80094f:	bf 30 00 00 00       	mov    $0x30,%edi
  800954:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800957:	4c 89 fe             	mov    %r15,%rsi
  80095a:	bf 78 00 00 00       	mov    $0x78,%edi
  80095f:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800962:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800965:	83 f8 2f             	cmp    $0x2f,%eax
  800968:	77 34                	ja     80099e <vprintfmt+0x573>
  80096a:	89 c2                	mov    %eax,%edx
  80096c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800970:	83 c0 08             	add    $0x8,%eax
  800973:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800976:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800979:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  80097e:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800983:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800987:	4c 89 fe             	mov    %r15,%rsi
  80098a:	4c 89 ef             	mov    %r13,%rdi
  80098d:	48 b8 01 03 80 00 00 	movabs $0x800301,%rax
  800994:	00 00 00 
  800997:	ff d0                	callq  *%rax
        break;
  800999:	e9 b7 fa ff ff       	jmpq   800455 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80099e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009aa:	eb ca                	jmp    800976 <vprintfmt+0x54b>
  if (lflag >= 2)
  8009ac:	83 f9 01             	cmp    $0x1,%ecx
  8009af:	7f 22                	jg     8009d3 <vprintfmt+0x5a8>
  else if (lflag)
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	74 58                	je     800a0d <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8009b5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b8:	83 f8 2f             	cmp    $0x2f,%eax
  8009bb:	77 42                	ja     8009ff <vprintfmt+0x5d4>
  8009bd:	89 c2                	mov    %eax,%edx
  8009bf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c3:	83 c0 08             	add    $0x8,%eax
  8009c6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009c9:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009cc:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009d1:	eb ab                	jmp    80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009d3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d6:	83 f8 2f             	cmp    $0x2f,%eax
  8009d9:	77 16                	ja     8009f1 <vprintfmt+0x5c6>
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e1:	83 c0 08             	add    $0x8,%eax
  8009e4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e7:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009ea:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009ef:	eb 8d                	jmp    80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009f9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009fd:	eb e8                	jmp    8009e7 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  8009ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a03:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a0b:	eb bc                	jmp    8009c9 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800a0d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a10:	83 f8 2f             	cmp    $0x2f,%eax
  800a13:	77 18                	ja     800a2d <vprintfmt+0x602>
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a1b:	83 c0 08             	add    $0x8,%eax
  800a1e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a21:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800a23:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a28:	e9 51 ff ff ff       	jmpq   80097e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a2d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a31:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a35:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a39:	eb e6                	jmp    800a21 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800a3b:	4c 89 fe             	mov    %r15,%rsi
  800a3e:	bf 25 00 00 00       	mov    $0x25,%edi
  800a43:	41 ff d5             	callq  *%r13
        break;
  800a46:	e9 0a fa ff ff       	jmpq   800455 <vprintfmt+0x2a>
        putch('%', putdat);
  800a4b:	4c 89 fe             	mov    %r15,%rsi
  800a4e:	bf 25 00 00 00       	mov    $0x25,%edi
  800a53:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800a56:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800a5a:	0f 84 15 fa ff ff    	je     800475 <vprintfmt+0x4a>
  800a60:	49 89 de             	mov    %rbx,%r14
  800a63:	49 83 ee 01          	sub    $0x1,%r14
  800a67:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800a6c:	75 f5                	jne    800a63 <vprintfmt+0x638>
  800a6e:	e9 e2 f9 ff ff       	jmpq   800455 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800a73:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a77:	74 06                	je     800a7f <vprintfmt+0x654>
  800a79:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a7d:	7f 21                	jg     800aa0 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7f:	bf 28 00 00 00       	mov    $0x28,%edi
  800a84:	48 bb 2b 15 80 00 00 	movabs $0x80152b,%rbx
  800a8b:	00 00 00 
  800a8e:	b8 28 00 00 00       	mov    $0x28,%eax
  800a93:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a97:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a9b:	e9 82 fc ff ff       	jmpq   800722 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800aa0:	49 63 f4             	movslq %r12d,%rsi
  800aa3:	48 bf 2a 15 80 00 00 	movabs $0x80152a,%rdi
  800aaa:	00 00 00 
  800aad:	48 b8 02 0c 80 00 00 	movabs $0x800c02,%rax
  800ab4:	00 00 00 
  800ab7:	ff d0                	callq  *%rax
  800ab9:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800abc:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800abf:	48 be 2a 15 80 00 00 	movabs $0x80152a,%rsi
  800ac6:	00 00 00 
  800ac9:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800acd:	85 c0                	test   %eax,%eax
  800acf:	0f 8f f2 fb ff ff    	jg     8006c7 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ad5:	48 bb 2b 15 80 00 00 	movabs $0x80152b,%rbx
  800adc:	00 00 00 
  800adf:	b8 28 00 00 00       	mov    $0x28,%eax
  800ae4:	bf 28 00 00 00       	mov    $0x28,%edi
  800ae9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800aed:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800af1:	e9 2c fc ff ff       	jmpq   800722 <vprintfmt+0x2f7>
}
  800af6:	48 83 c4 48          	add    $0x48,%rsp
  800afa:	5b                   	pop    %rbx
  800afb:	41 5c                	pop    %r12
  800afd:	41 5d                	pop    %r13
  800aff:	41 5e                	pop    %r14
  800b01:	41 5f                	pop    %r15
  800b03:	5d                   	pop    %rbp
  800b04:	c3                   	retq   

0000000000800b05 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800b05:	55                   	push   %rbp
  800b06:	48 89 e5             	mov    %rsp,%rbp
  800b09:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800b0d:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800b11:	48 63 c6             	movslq %esi,%rax
  800b14:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800b19:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800b1d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800b24:	48 85 ff             	test   %rdi,%rdi
  800b27:	74 2a                	je     800b53 <vsnprintf+0x4e>
  800b29:	85 f6                	test   %esi,%esi
  800b2b:	7e 26                	jle    800b53 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800b2d:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800b31:	48 bf 8d 03 80 00 00 	movabs $0x80038d,%rdi
  800b38:	00 00 00 
  800b3b:	48 b8 2b 04 80 00 00 	movabs $0x80042b,%rax
  800b42:	00 00 00 
  800b45:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800b47:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800b4b:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800b4e:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800b51:	c9                   	leaveq 
  800b52:	c3                   	retq   
    return -E_INVAL;
  800b53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b58:	eb f7                	jmp    800b51 <vsnprintf+0x4c>

0000000000800b5a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800b5a:	55                   	push   %rbp
  800b5b:	48 89 e5             	mov    %rsp,%rbp
  800b5e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800b65:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800b6c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800b73:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800b7a:	84 c0                	test   %al,%al
  800b7c:	74 20                	je     800b9e <snprintf+0x44>
  800b7e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800b82:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800b86:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b8a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b8e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b92:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b96:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b9a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b9e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ba5:	00 00 00 
  800ba8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800baf:	00 00 00 
  800bb2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800bb6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800bbd:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800bc4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800bcb:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800bd2:	48 b8 05 0b 80 00 00 	movabs $0x800b05,%rax
  800bd9:	00 00 00 
  800bdc:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800bde:	c9                   	leaveq 
  800bdf:	c3                   	retq   

0000000000800be0 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800be0:	80 3f 00             	cmpb   $0x0,(%rdi)
  800be3:	74 17                	je     800bfc <strlen+0x1c>
  800be5:	48 89 fa             	mov    %rdi,%rdx
  800be8:	b9 01 00 00 00       	mov    $0x1,%ecx
  800bed:	29 f9                	sub    %edi,%ecx
    n++;
  800bef:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800bf2:	48 83 c2 01          	add    $0x1,%rdx
  800bf6:	80 3a 00             	cmpb   $0x0,(%rdx)
  800bf9:	75 f4                	jne    800bef <strlen+0xf>
  800bfb:	c3                   	retq   
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c01:	c3                   	retq   

0000000000800c02 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c02:	48 85 f6             	test   %rsi,%rsi
  800c05:	74 24                	je     800c2b <strnlen+0x29>
  800c07:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c0a:	74 25                	je     800c31 <strnlen+0x2f>
  800c0c:	48 01 fe             	add    %rdi,%rsi
  800c0f:	48 89 fa             	mov    %rdi,%rdx
  800c12:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c17:	29 f9                	sub    %edi,%ecx
    n++;
  800c19:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c1c:	48 83 c2 01          	add    $0x1,%rdx
  800c20:	48 39 f2             	cmp    %rsi,%rdx
  800c23:	74 11                	je     800c36 <strnlen+0x34>
  800c25:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c28:	75 ef                	jne    800c19 <strnlen+0x17>
  800c2a:	c3                   	retq   
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	c3                   	retq   
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c36:	c3                   	retq   

0000000000800c37 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800c37:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800c43:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800c46:	48 83 c2 01          	add    $0x1,%rdx
  800c4a:	84 c9                	test   %cl,%cl
  800c4c:	75 f1                	jne    800c3f <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800c4e:	c3                   	retq   

0000000000800c4f <strcat>:

char *
strcat(char *dst, const char *src) {
  800c4f:	55                   	push   %rbp
  800c50:	48 89 e5             	mov    %rsp,%rbp
  800c53:	41 54                	push   %r12
  800c55:	53                   	push   %rbx
  800c56:	48 89 fb             	mov    %rdi,%rbx
  800c59:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800c5c:	48 b8 e0 0b 80 00 00 	movabs $0x800be0,%rax
  800c63:	00 00 00 
  800c66:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800c68:	48 63 f8             	movslq %eax,%rdi
  800c6b:	48 01 df             	add    %rbx,%rdi
  800c6e:	4c 89 e6             	mov    %r12,%rsi
  800c71:	48 b8 37 0c 80 00 00 	movabs $0x800c37,%rax
  800c78:	00 00 00 
  800c7b:	ff d0                	callq  *%rax
  return dst;
}
  800c7d:	48 89 d8             	mov    %rbx,%rax
  800c80:	5b                   	pop    %rbx
  800c81:	41 5c                	pop    %r12
  800c83:	5d                   	pop    %rbp
  800c84:	c3                   	retq   

0000000000800c85 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c85:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c88:	48 85 d2             	test   %rdx,%rdx
  800c8b:	74 1f                	je     800cac <strncpy+0x27>
  800c8d:	48 01 fa             	add    %rdi,%rdx
  800c90:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c93:	48 83 c1 01          	add    $0x1,%rcx
  800c97:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c9b:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c9f:	41 80 f8 01          	cmp    $0x1,%r8b
  800ca3:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800ca7:	48 39 ca             	cmp    %rcx,%rdx
  800caa:	75 e7                	jne    800c93 <strncpy+0xe>
  }
  return ret;
}
  800cac:	c3                   	retq   

0000000000800cad <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800cad:	48 89 f8             	mov    %rdi,%rax
  800cb0:	48 85 d2             	test   %rdx,%rdx
  800cb3:	74 36                	je     800ceb <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800cb5:	48 83 fa 01          	cmp    $0x1,%rdx
  800cb9:	74 2d                	je     800ce8 <strlcpy+0x3b>
  800cbb:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cbf:	45 84 c0             	test   %r8b,%r8b
  800cc2:	74 24                	je     800ce8 <strlcpy+0x3b>
  800cc4:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800cc8:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800ccd:	48 83 c0 01          	add    $0x1,%rax
  800cd1:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800cd5:	48 39 d1             	cmp    %rdx,%rcx
  800cd8:	74 0e                	je     800ce8 <strlcpy+0x3b>
  800cda:	48 83 c1 01          	add    $0x1,%rcx
  800cde:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800ce3:	45 84 c0             	test   %r8b,%r8b
  800ce6:	75 e5                	jne    800ccd <strlcpy+0x20>
    *dst = '\0';
  800ce8:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800ceb:	48 29 f8             	sub    %rdi,%rax
}
  800cee:	c3                   	retq   

0000000000800cef <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800cef:	0f b6 07             	movzbl (%rdi),%eax
  800cf2:	84 c0                	test   %al,%al
  800cf4:	74 17                	je     800d0d <strcmp+0x1e>
  800cf6:	3a 06                	cmp    (%rsi),%al
  800cf8:	75 13                	jne    800d0d <strcmp+0x1e>
    p++, q++;
  800cfa:	48 83 c7 01          	add    $0x1,%rdi
  800cfe:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800d02:	0f b6 07             	movzbl (%rdi),%eax
  800d05:	84 c0                	test   %al,%al
  800d07:	74 04                	je     800d0d <strcmp+0x1e>
  800d09:	3a 06                	cmp    (%rsi),%al
  800d0b:	74 ed                	je     800cfa <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800d0d:	0f b6 c0             	movzbl %al,%eax
  800d10:	0f b6 16             	movzbl (%rsi),%edx
  800d13:	29 d0                	sub    %edx,%eax
}
  800d15:	c3                   	retq   

0000000000800d16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800d16:	48 85 d2             	test   %rdx,%rdx
  800d19:	74 2f                	je     800d4a <strncmp+0x34>
  800d1b:	0f b6 07             	movzbl (%rdi),%eax
  800d1e:	84 c0                	test   %al,%al
  800d20:	74 1f                	je     800d41 <strncmp+0x2b>
  800d22:	3a 06                	cmp    (%rsi),%al
  800d24:	75 1b                	jne    800d41 <strncmp+0x2b>
  800d26:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800d29:	48 83 c7 01          	add    $0x1,%rdi
  800d2d:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800d31:	48 39 d7             	cmp    %rdx,%rdi
  800d34:	74 1a                	je     800d50 <strncmp+0x3a>
  800d36:	0f b6 07             	movzbl (%rdi),%eax
  800d39:	84 c0                	test   %al,%al
  800d3b:	74 04                	je     800d41 <strncmp+0x2b>
  800d3d:	3a 06                	cmp    (%rsi),%al
  800d3f:	74 e8                	je     800d29 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800d41:	0f b6 07             	movzbl (%rdi),%eax
  800d44:	0f b6 16             	movzbl (%rsi),%edx
  800d47:	29 d0                	sub    %edx,%eax
}
  800d49:	c3                   	retq   
    return 0;
  800d4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4f:	c3                   	retq   
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
  800d55:	c3                   	retq   

0000000000800d56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800d56:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800d58:	0f b6 07             	movzbl (%rdi),%eax
  800d5b:	84 c0                	test   %al,%al
  800d5d:	74 1e                	je     800d7d <strchr+0x27>
    if (*s == c)
  800d5f:	40 38 c6             	cmp    %al,%sil
  800d62:	74 1f                	je     800d83 <strchr+0x2d>
  for (; *s; s++)
  800d64:	48 83 c7 01          	add    $0x1,%rdi
  800d68:	0f b6 07             	movzbl (%rdi),%eax
  800d6b:	84 c0                	test   %al,%al
  800d6d:	74 08                	je     800d77 <strchr+0x21>
    if (*s == c)
  800d6f:	38 d0                	cmp    %dl,%al
  800d71:	75 f1                	jne    800d64 <strchr+0xe>
  for (; *s; s++)
  800d73:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800d76:	c3                   	retq   
  return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7c:	c3                   	retq   
  800d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d82:	c3                   	retq   
    if (*s == c)
  800d83:	48 89 f8             	mov    %rdi,%rax
  800d86:	c3                   	retq   

0000000000800d87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800d87:	48 89 f8             	mov    %rdi,%rax
  800d8a:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d8c:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d8f:	40 38 f2             	cmp    %sil,%dl
  800d92:	74 13                	je     800da7 <strfind+0x20>
  800d94:	84 d2                	test   %dl,%dl
  800d96:	74 0f                	je     800da7 <strfind+0x20>
  for (; *s; s++)
  800d98:	48 83 c0 01          	add    $0x1,%rax
  800d9c:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d9f:	38 ca                	cmp    %cl,%dl
  800da1:	74 04                	je     800da7 <strfind+0x20>
  800da3:	84 d2                	test   %dl,%dl
  800da5:	75 f1                	jne    800d98 <strfind+0x11>
      break;
  return (char *)s;
}
  800da7:	c3                   	retq   

0000000000800da8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800da8:	48 85 d2             	test   %rdx,%rdx
  800dab:	74 3a                	je     800de7 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800dad:	48 89 f8             	mov    %rdi,%rax
  800db0:	48 09 d0             	or     %rdx,%rax
  800db3:	a8 03                	test   $0x3,%al
  800db5:	75 28                	jne    800ddf <memset+0x37>
    uint32_t k = c & 0xFFU;
  800db7:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	c1 e0 08             	shl    $0x8,%eax
  800dc0:	89 f1                	mov    %esi,%ecx
  800dc2:	c1 e1 18             	shl    $0x18,%ecx
  800dc5:	41 89 f0             	mov    %esi,%r8d
  800dc8:	41 c1 e0 10          	shl    $0x10,%r8d
  800dcc:	44 09 c1             	or     %r8d,%ecx
  800dcf:	09 ce                	or     %ecx,%esi
  800dd1:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800dd3:	48 c1 ea 02          	shr    $0x2,%rdx
  800dd7:	48 89 d1             	mov    %rdx,%rcx
  800dda:	fc                   	cld    
  800ddb:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ddd:	eb 08                	jmp    800de7 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ddf:	89 f0                	mov    %esi,%eax
  800de1:	48 89 d1             	mov    %rdx,%rcx
  800de4:	fc                   	cld    
  800de5:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800de7:	48 89 f8             	mov    %rdi,%rax
  800dea:	c3                   	retq   

0000000000800deb <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800deb:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800dee:	48 39 fe             	cmp    %rdi,%rsi
  800df1:	73 40                	jae    800e33 <memmove+0x48>
  800df3:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800df7:	48 39 f9             	cmp    %rdi,%rcx
  800dfa:	76 37                	jbe    800e33 <memmove+0x48>
    s += n;
    d += n;
  800dfc:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e00:	48 89 fe             	mov    %rdi,%rsi
  800e03:	48 09 d6             	or     %rdx,%rsi
  800e06:	48 09 ce             	or     %rcx,%rsi
  800e09:	40 f6 c6 03          	test   $0x3,%sil
  800e0d:	75 14                	jne    800e23 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800e0f:	48 83 ef 04          	sub    $0x4,%rdi
  800e13:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800e17:	48 c1 ea 02          	shr    $0x2,%rdx
  800e1b:	48 89 d1             	mov    %rdx,%rcx
  800e1e:	fd                   	std    
  800e1f:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e21:	eb 0e                	jmp    800e31 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800e23:	48 83 ef 01          	sub    $0x1,%rdi
  800e27:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800e2b:	48 89 d1             	mov    %rdx,%rcx
  800e2e:	fd                   	std    
  800e2f:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800e31:	fc                   	cld    
  800e32:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e33:	48 89 c1             	mov    %rax,%rcx
  800e36:	48 09 d1             	or     %rdx,%rcx
  800e39:	48 09 f1             	or     %rsi,%rcx
  800e3c:	f6 c1 03             	test   $0x3,%cl
  800e3f:	75 0e                	jne    800e4f <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800e41:	48 c1 ea 02          	shr    $0x2,%rdx
  800e45:	48 89 d1             	mov    %rdx,%rcx
  800e48:	48 89 c7             	mov    %rax,%rdi
  800e4b:	fc                   	cld    
  800e4c:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e4e:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800e4f:	48 89 c7             	mov    %rax,%rdi
  800e52:	48 89 d1             	mov    %rdx,%rcx
  800e55:	fc                   	cld    
  800e56:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800e58:	c3                   	retq   

0000000000800e59 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800e59:	55                   	push   %rbp
  800e5a:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800e5d:	48 b8 eb 0d 80 00 00 	movabs $0x800deb,%rax
  800e64:	00 00 00 
  800e67:	ff d0                	callq  *%rax
}
  800e69:	5d                   	pop    %rbp
  800e6a:	c3                   	retq   

0000000000800e6b <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800e6b:	55                   	push   %rbp
  800e6c:	48 89 e5             	mov    %rsp,%rbp
  800e6f:	41 57                	push   %r15
  800e71:	41 56                	push   %r14
  800e73:	41 55                	push   %r13
  800e75:	41 54                	push   %r12
  800e77:	53                   	push   %rbx
  800e78:	48 83 ec 08          	sub    $0x8,%rsp
  800e7c:	49 89 fe             	mov    %rdi,%r14
  800e7f:	49 89 f7             	mov    %rsi,%r15
  800e82:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800e85:	48 89 f7             	mov    %rsi,%rdi
  800e88:	48 b8 e0 0b 80 00 00 	movabs $0x800be0,%rax
  800e8f:	00 00 00 
  800e92:	ff d0                	callq  *%rax
  800e94:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e97:	4c 89 ee             	mov    %r13,%rsi
  800e9a:	4c 89 f7             	mov    %r14,%rdi
  800e9d:	48 b8 02 0c 80 00 00 	movabs $0x800c02,%rax
  800ea4:	00 00 00 
  800ea7:	ff d0                	callq  *%rax
  800ea9:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800eac:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800eb0:	4d 39 e5             	cmp    %r12,%r13
  800eb3:	74 26                	je     800edb <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800eb5:	4c 89 e8             	mov    %r13,%rax
  800eb8:	4c 29 e0             	sub    %r12,%rax
  800ebb:	48 39 d8             	cmp    %rbx,%rax
  800ebe:	76 2a                	jbe    800eea <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800ec0:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800ec4:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ec8:	4c 89 fe             	mov    %r15,%rsi
  800ecb:	48 b8 59 0e 80 00 00 	movabs $0x800e59,%rax
  800ed2:	00 00 00 
  800ed5:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800ed7:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800edb:	48 83 c4 08          	add    $0x8,%rsp
  800edf:	5b                   	pop    %rbx
  800ee0:	41 5c                	pop    %r12
  800ee2:	41 5d                	pop    %r13
  800ee4:	41 5e                	pop    %r14
  800ee6:	41 5f                	pop    %r15
  800ee8:	5d                   	pop    %rbp
  800ee9:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800eea:	49 83 ed 01          	sub    $0x1,%r13
  800eee:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ef2:	4c 89 ea             	mov    %r13,%rdx
  800ef5:	4c 89 fe             	mov    %r15,%rsi
  800ef8:	48 b8 59 0e 80 00 00 	movabs $0x800e59,%rax
  800eff:	00 00 00 
  800f02:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800f04:	4d 01 ee             	add    %r13,%r14
  800f07:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800f0c:	eb c9                	jmp    800ed7 <strlcat+0x6c>

0000000000800f0e <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800f0e:	48 85 d2             	test   %rdx,%rdx
  800f11:	74 3a                	je     800f4d <memcmp+0x3f>
    if (*s1 != *s2)
  800f13:	0f b6 0f             	movzbl (%rdi),%ecx
  800f16:	44 0f b6 06          	movzbl (%rsi),%r8d
  800f1a:	44 38 c1             	cmp    %r8b,%cl
  800f1d:	75 1d                	jne    800f3c <memcmp+0x2e>
  800f1f:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800f24:	48 39 d0             	cmp    %rdx,%rax
  800f27:	74 1e                	je     800f47 <memcmp+0x39>
    if (*s1 != *s2)
  800f29:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800f2d:	48 83 c0 01          	add    $0x1,%rax
  800f31:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800f37:	44 38 c1             	cmp    %r8b,%cl
  800f3a:	74 e8                	je     800f24 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800f3c:	0f b6 c1             	movzbl %cl,%eax
  800f3f:	45 0f b6 c0          	movzbl %r8b,%r8d
  800f43:	44 29 c0             	sub    %r8d,%eax
  800f46:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4c:	c3                   	retq   
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f52:	c3                   	retq   

0000000000800f53 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800f53:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800f57:	48 39 c7             	cmp    %rax,%rdi
  800f5a:	73 19                	jae    800f75 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f5c:	89 f2                	mov    %esi,%edx
  800f5e:	40 38 37             	cmp    %sil,(%rdi)
  800f61:	74 16                	je     800f79 <memfind+0x26>
  for (; s < ends; s++)
  800f63:	48 83 c7 01          	add    $0x1,%rdi
  800f67:	48 39 f8             	cmp    %rdi,%rax
  800f6a:	74 08                	je     800f74 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f6c:	38 17                	cmp    %dl,(%rdi)
  800f6e:	75 f3                	jne    800f63 <memfind+0x10>
  for (; s < ends; s++)
  800f70:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800f73:	c3                   	retq   
  800f74:	c3                   	retq   
  for (; s < ends; s++)
  800f75:	48 89 f8             	mov    %rdi,%rax
  800f78:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800f79:	48 89 f8             	mov    %rdi,%rax
  800f7c:	c3                   	retq   

0000000000800f7d <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f7d:	0f b6 07             	movzbl (%rdi),%eax
  800f80:	3c 20                	cmp    $0x20,%al
  800f82:	74 04                	je     800f88 <strtol+0xb>
  800f84:	3c 09                	cmp    $0x9,%al
  800f86:	75 0f                	jne    800f97 <strtol+0x1a>
    s++;
  800f88:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f8c:	0f b6 07             	movzbl (%rdi),%eax
  800f8f:	3c 20                	cmp    $0x20,%al
  800f91:	74 f5                	je     800f88 <strtol+0xb>
  800f93:	3c 09                	cmp    $0x9,%al
  800f95:	74 f1                	je     800f88 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f97:	3c 2b                	cmp    $0x2b,%al
  800f99:	74 2b                	je     800fc6 <strtol+0x49>
  int neg  = 0;
  800f9b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800fa1:	3c 2d                	cmp    $0x2d,%al
  800fa3:	74 2d                	je     800fd2 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fa5:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800fab:	75 0f                	jne    800fbc <strtol+0x3f>
  800fad:	80 3f 30             	cmpb   $0x30,(%rdi)
  800fb0:	74 2c                	je     800fde <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800fb2:	85 d2                	test   %edx,%edx
  800fb4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fb9:	0f 44 d0             	cmove  %eax,%edx
  800fbc:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800fc1:	4c 63 d2             	movslq %edx,%r10
  800fc4:	eb 5c                	jmp    801022 <strtol+0xa5>
    s++;
  800fc6:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800fca:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800fd0:	eb d3                	jmp    800fa5 <strtol+0x28>
    s++, neg = 1;
  800fd2:	48 83 c7 01          	add    $0x1,%rdi
  800fd6:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800fdc:	eb c7                	jmp    800fa5 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fde:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800fe2:	74 0f                	je     800ff3 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800fe4:	85 d2                	test   %edx,%edx
  800fe6:	75 d4                	jne    800fbc <strtol+0x3f>
    s++, base = 8;
  800fe8:	48 83 c7 01          	add    $0x1,%rdi
  800fec:	ba 08 00 00 00       	mov    $0x8,%edx
  800ff1:	eb c9                	jmp    800fbc <strtol+0x3f>
    s += 2, base = 16;
  800ff3:	48 83 c7 02          	add    $0x2,%rdi
  800ff7:	ba 10 00 00 00       	mov    $0x10,%edx
  800ffc:	eb be                	jmp    800fbc <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800ffe:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801002:	41 80 f8 19          	cmp    $0x19,%r8b
  801006:	77 2f                	ja     801037 <strtol+0xba>
      dig = *s - 'a' + 10;
  801008:	44 0f be c1          	movsbl %cl,%r8d
  80100c:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801010:	39 d1                	cmp    %edx,%ecx
  801012:	7d 37                	jge    80104b <strtol+0xce>
    s++, val = (val * base) + dig;
  801014:	48 83 c7 01          	add    $0x1,%rdi
  801018:	49 0f af c2          	imul   %r10,%rax
  80101c:	48 63 c9             	movslq %ecx,%rcx
  80101f:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801022:	0f b6 0f             	movzbl (%rdi),%ecx
  801025:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801029:	41 80 f8 09          	cmp    $0x9,%r8b
  80102d:	77 cf                	ja     800ffe <strtol+0x81>
      dig = *s - '0';
  80102f:	0f be c9             	movsbl %cl,%ecx
  801032:	83 e9 30             	sub    $0x30,%ecx
  801035:	eb d9                	jmp    801010 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801037:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80103b:	41 80 f8 19          	cmp    $0x19,%r8b
  80103f:	77 0a                	ja     80104b <strtol+0xce>
      dig = *s - 'A' + 10;
  801041:	44 0f be c1          	movsbl %cl,%r8d
  801045:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801049:	eb c5                	jmp    801010 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80104b:	48 85 f6             	test   %rsi,%rsi
  80104e:	74 03                	je     801053 <strtol+0xd6>
    *endptr = (char *)s;
  801050:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801053:	48 89 c2             	mov    %rax,%rdx
  801056:	48 f7 da             	neg    %rdx
  801059:	45 85 c9             	test   %r9d,%r9d
  80105c:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801060:	c3                   	retq   

0000000000801061 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  801061:	55                   	push   %rbp
  801062:	48 89 e5             	mov    %rsp,%rbp
  801065:	53                   	push   %rbx
  801066:	48 89 fa             	mov    %rdi,%rdx
  801069:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
  801071:	48 89 c3             	mov    %rax,%rbx
  801074:	48 89 c7             	mov    %rax,%rdi
  801077:	48 89 c6             	mov    %rax,%rsi
  80107a:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80107c:	5b                   	pop    %rbx
  80107d:	5d                   	pop    %rbp
  80107e:	c3                   	retq   

000000000080107f <sys_cgetc>:

int
sys_cgetc(void) {
  80107f:	55                   	push   %rbp
  801080:	48 89 e5             	mov    %rsp,%rbp
  801083:	53                   	push   %rbx
  asm volatile("int %1\n"
  801084:	b9 00 00 00 00       	mov    $0x0,%ecx
  801089:	b8 01 00 00 00       	mov    $0x1,%eax
  80108e:	48 89 ca             	mov    %rcx,%rdx
  801091:	48 89 cb             	mov    %rcx,%rbx
  801094:	48 89 cf             	mov    %rcx,%rdi
  801097:	48 89 ce             	mov    %rcx,%rsi
  80109a:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80109c:	5b                   	pop    %rbx
  80109d:	5d                   	pop    %rbp
  80109e:	c3                   	retq   

000000000080109f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80109f:	55                   	push   %rbp
  8010a0:	48 89 e5             	mov    %rsp,%rbp
  8010a3:	53                   	push   %rbx
  8010a4:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010a8:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8010ab:	be 00 00 00 00       	mov    $0x0,%esi
  8010b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b5:	48 89 f1             	mov    %rsi,%rcx
  8010b8:	48 89 f3             	mov    %rsi,%rbx
  8010bb:	48 89 f7             	mov    %rsi,%rdi
  8010be:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010c0:	48 85 c0             	test   %rax,%rax
  8010c3:	7f 07                	jg     8010cc <sys_env_destroy+0x2d>
}
  8010c5:	48 83 c4 08          	add    $0x8,%rsp
  8010c9:	5b                   	pop    %rbx
  8010ca:	5d                   	pop    %rbp
  8010cb:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010cc:	49 89 c0             	mov    %rax,%r8
  8010cf:	b9 03 00 00 00       	mov    $0x3,%ecx
  8010d4:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  8010db:	00 00 00 
  8010de:	be 22 00 00 00       	mov    $0x22,%esi
  8010e3:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  8010ea:	00 00 00 
  8010ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f2:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  8010f9:	00 00 00 
  8010fc:	41 ff d1             	callq  *%r9

00000000008010ff <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8010ff:	55                   	push   %rbp
  801100:	48 89 e5             	mov    %rsp,%rbp
  801103:	53                   	push   %rbx
  asm volatile("int %1\n"
  801104:	b9 00 00 00 00       	mov    $0x0,%ecx
  801109:	b8 02 00 00 00       	mov    $0x2,%eax
  80110e:	48 89 ca             	mov    %rcx,%rdx
  801111:	48 89 cb             	mov    %rcx,%rbx
  801114:	48 89 cf             	mov    %rcx,%rdi
  801117:	48 89 ce             	mov    %rcx,%rsi
  80111a:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80111c:	5b                   	pop    %rbx
  80111d:	5d                   	pop    %rbp
  80111e:	c3                   	retq   

000000000080111f <sys_yield>:

void
sys_yield(void) {
  80111f:	55                   	push   %rbp
  801120:	48 89 e5             	mov    %rsp,%rbp
  801123:	53                   	push   %rbx
  asm volatile("int %1\n"
  801124:	b9 00 00 00 00       	mov    $0x0,%ecx
  801129:	b8 0a 00 00 00       	mov    $0xa,%eax
  80112e:	48 89 ca             	mov    %rcx,%rdx
  801131:	48 89 cb             	mov    %rcx,%rbx
  801134:	48 89 cf             	mov    %rcx,%rdi
  801137:	48 89 ce             	mov    %rcx,%rsi
  80113a:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80113c:	5b                   	pop    %rbx
  80113d:	5d                   	pop    %rbp
  80113e:	c3                   	retq   

000000000080113f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  80113f:	55                   	push   %rbp
  801140:	48 89 e5             	mov    %rsp,%rbp
  801143:	53                   	push   %rbx
  801144:	48 83 ec 08          	sub    $0x8,%rsp
  801148:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  80114b:	4c 63 c7             	movslq %edi,%r8
  80114e:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  801151:	be 00 00 00 00       	mov    $0x0,%esi
  801156:	b8 04 00 00 00       	mov    $0x4,%eax
  80115b:	4c 89 c2             	mov    %r8,%rdx
  80115e:	48 89 f7             	mov    %rsi,%rdi
  801161:	cd 30                	int    $0x30
  if (check && ret > 0)
  801163:	48 85 c0             	test   %rax,%rax
  801166:	7f 07                	jg     80116f <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  801168:	48 83 c4 08          	add    $0x8,%rsp
  80116c:	5b                   	pop    %rbx
  80116d:	5d                   	pop    %rbp
  80116e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80116f:	49 89 c0             	mov    %rax,%r8
  801172:	b9 04 00 00 00       	mov    $0x4,%ecx
  801177:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  80117e:	00 00 00 
  801181:	be 22 00 00 00       	mov    $0x22,%esi
  801186:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  80118d:	00 00 00 
  801190:	b8 00 00 00 00       	mov    $0x0,%eax
  801195:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  80119c:	00 00 00 
  80119f:	41 ff d1             	callq  *%r9

00000000008011a2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8011a2:	55                   	push   %rbp
  8011a3:	48 89 e5             	mov    %rsp,%rbp
  8011a6:	53                   	push   %rbx
  8011a7:	48 83 ec 08          	sub    $0x8,%rsp
  8011ab:	41 89 f9             	mov    %edi,%r9d
  8011ae:	49 89 f2             	mov    %rsi,%r10
  8011b1:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8011b4:	4d 63 c9             	movslq %r9d,%r9
  8011b7:	48 63 da             	movslq %edx,%rbx
  8011ba:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8011bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8011c2:	4c 89 ca             	mov    %r9,%rdx
  8011c5:	4c 89 d1             	mov    %r10,%rcx
  8011c8:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011ca:	48 85 c0             	test   %rax,%rax
  8011cd:	7f 07                	jg     8011d6 <sys_page_map+0x34>
}
  8011cf:	48 83 c4 08          	add    $0x8,%rsp
  8011d3:	5b                   	pop    %rbx
  8011d4:	5d                   	pop    %rbp
  8011d5:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011d6:	49 89 c0             	mov    %rax,%r8
  8011d9:	b9 05 00 00 00       	mov    $0x5,%ecx
  8011de:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  8011e5:	00 00 00 
  8011e8:	be 22 00 00 00       	mov    $0x22,%esi
  8011ed:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  8011f4:	00 00 00 
  8011f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fc:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  801203:	00 00 00 
  801206:	41 ff d1             	callq  *%r9

0000000000801209 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801209:	55                   	push   %rbp
  80120a:	48 89 e5             	mov    %rsp,%rbp
  80120d:	53                   	push   %rbx
  80120e:	48 83 ec 08          	sub    $0x8,%rsp
  801212:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801215:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801218:	be 00 00 00 00       	mov    $0x0,%esi
  80121d:	b8 06 00 00 00       	mov    $0x6,%eax
  801222:	48 89 f3             	mov    %rsi,%rbx
  801225:	48 89 f7             	mov    %rsi,%rdi
  801228:	cd 30                	int    $0x30
  if (check && ret > 0)
  80122a:	48 85 c0             	test   %rax,%rax
  80122d:	7f 07                	jg     801236 <sys_page_unmap+0x2d>
}
  80122f:	48 83 c4 08          	add    $0x8,%rsp
  801233:	5b                   	pop    %rbx
  801234:	5d                   	pop    %rbp
  801235:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801236:	49 89 c0             	mov    %rax,%r8
  801239:	b9 06 00 00 00       	mov    $0x6,%ecx
  80123e:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  801245:	00 00 00 
  801248:	be 22 00 00 00       	mov    $0x22,%esi
  80124d:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  801254:	00 00 00 
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  801263:	00 00 00 
  801266:	41 ff d1             	callq  *%r9

0000000000801269 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  801269:	55                   	push   %rbp
  80126a:	48 89 e5             	mov    %rsp,%rbp
  80126d:	53                   	push   %rbx
  80126e:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801272:	48 63 d7             	movslq %edi,%rdx
  801275:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127d:	b8 08 00 00 00       	mov    $0x8,%eax
  801282:	48 89 df             	mov    %rbx,%rdi
  801285:	48 89 de             	mov    %rbx,%rsi
  801288:	cd 30                	int    $0x30
  if (check && ret > 0)
  80128a:	48 85 c0             	test   %rax,%rax
  80128d:	7f 07                	jg     801296 <sys_env_set_status+0x2d>
}
  80128f:	48 83 c4 08          	add    $0x8,%rsp
  801293:	5b                   	pop    %rbx
  801294:	5d                   	pop    %rbp
  801295:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801296:	49 89 c0             	mov    %rax,%r8
  801299:	b9 08 00 00 00       	mov    $0x8,%ecx
  80129e:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  8012a5:	00 00 00 
  8012a8:	be 22 00 00 00       	mov    $0x22,%esi
  8012ad:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  8012b4:	00 00 00 
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bc:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  8012c3:	00 00 00 
  8012c6:	41 ff d1             	callq  *%r9

00000000008012c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8012c9:	55                   	push   %rbp
  8012ca:	48 89 e5             	mov    %rsp,%rbp
  8012cd:	53                   	push   %rbx
  8012ce:	48 83 ec 08          	sub    $0x8,%rsp
  8012d2:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  8012d5:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8012d8:	be 00 00 00 00       	mov    $0x0,%esi
  8012dd:	b8 09 00 00 00       	mov    $0x9,%eax
  8012e2:	48 89 f3             	mov    %rsi,%rbx
  8012e5:	48 89 f7             	mov    %rsi,%rdi
  8012e8:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012ea:	48 85 c0             	test   %rax,%rax
  8012ed:	7f 07                	jg     8012f6 <sys_env_set_pgfault_upcall+0x2d>
}
  8012ef:	48 83 c4 08          	add    $0x8,%rsp
  8012f3:	5b                   	pop    %rbx
  8012f4:	5d                   	pop    %rbp
  8012f5:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012f6:	49 89 c0             	mov    %rax,%r8
  8012f9:	b9 09 00 00 00       	mov    $0x9,%ecx
  8012fe:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  801305:	00 00 00 
  801308:	be 22 00 00 00       	mov    $0x22,%esi
  80130d:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  801314:	00 00 00 
  801317:	b8 00 00 00 00       	mov    $0x0,%eax
  80131c:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  801323:	00 00 00 
  801326:	41 ff d1             	callq  *%r9

0000000000801329 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801329:	55                   	push   %rbp
  80132a:	48 89 e5             	mov    %rsp,%rbp
  80132d:	53                   	push   %rbx
  80132e:	49 89 f0             	mov    %rsi,%r8
  801331:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801334:	48 63 d7             	movslq %edi,%rdx
  801337:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  80133a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80133f:	be 00 00 00 00       	mov    $0x0,%esi
  801344:	4c 89 c1             	mov    %r8,%rcx
  801347:	cd 30                	int    $0x30
}
  801349:	5b                   	pop    %rbx
  80134a:	5d                   	pop    %rbp
  80134b:	c3                   	retq   

000000000080134c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  80134c:	55                   	push   %rbp
  80134d:	48 89 e5             	mov    %rsp,%rbp
  801350:	53                   	push   %rbx
  801351:	48 83 ec 08          	sub    $0x8,%rsp
  801355:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801358:	be 00 00 00 00       	mov    $0x0,%esi
  80135d:	b8 0c 00 00 00       	mov    $0xc,%eax
  801362:	48 89 f1             	mov    %rsi,%rcx
  801365:	48 89 f3             	mov    %rsi,%rbx
  801368:	48 89 f7             	mov    %rsi,%rdi
  80136b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80136d:	48 85 c0             	test   %rax,%rax
  801370:	7f 07                	jg     801379 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  801372:	48 83 c4 08          	add    $0x8,%rsp
  801376:	5b                   	pop    %rbx
  801377:	5d                   	pop    %rbp
  801378:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801379:	49 89 c0             	mov    %rax,%r8
  80137c:	b9 0c 00 00 00       	mov    $0xc,%ecx
  801381:	48 ba 20 19 80 00 00 	movabs $0x801920,%rdx
  801388:	00 00 00 
  80138b:	be 22 00 00 00       	mov    $0x22,%esi
  801390:	48 bf 3f 19 80 00 00 	movabs $0x80193f,%rdi
  801397:	00 00 00 
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	49 b9 ac 13 80 00 00 	movabs $0x8013ac,%r9
  8013a6:	00 00 00 
  8013a9:	41 ff d1             	callq  *%r9

00000000008013ac <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8013ac:	55                   	push   %rbp
  8013ad:	48 89 e5             	mov    %rsp,%rbp
  8013b0:	41 56                	push   %r14
  8013b2:	41 55                	push   %r13
  8013b4:	41 54                	push   %r12
  8013b6:	53                   	push   %rbx
  8013b7:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8013be:	49 89 fd             	mov    %rdi,%r13
  8013c1:	41 89 f6             	mov    %esi,%r14d
  8013c4:	49 89 d4             	mov    %rdx,%r12
  8013c7:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8013ce:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8013d5:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8013dc:	84 c0                	test   %al,%al
  8013de:	74 26                	je     801406 <_panic+0x5a>
  8013e0:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8013e7:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8013ee:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8013f2:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8013f6:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8013fa:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8013fe:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801402:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801406:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80140d:	00 00 00 
  801410:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801417:	00 00 00 
  80141a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80141e:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801425:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80142c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801433:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80143a:	00 00 00 
  80143d:	48 8b 18             	mov    (%rax),%rbx
  801440:	48 b8 ff 10 80 00 00 	movabs $0x8010ff,%rax
  801447:	00 00 00 
  80144a:	ff d0                	callq  *%rax
  80144c:	45 89 f0             	mov    %r14d,%r8d
  80144f:	4c 89 e9             	mov    %r13,%rcx
  801452:	48 89 da             	mov    %rbx,%rdx
  801455:	89 c6                	mov    %eax,%esi
  801457:	48 bf 50 19 80 00 00 	movabs $0x801950,%rdi
  80145e:	00 00 00 
  801461:	b8 00 00 00 00       	mov    $0x0,%eax
  801466:	48 bb 6d 02 80 00 00 	movabs $0x80026d,%rbx
  80146d:	00 00 00 
  801470:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801472:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801479:	4c 89 e7             	mov    %r12,%rdi
  80147c:	48 b8 05 02 80 00 00 	movabs $0x800205,%rax
  801483:	00 00 00 
  801486:	ff d0                	callq  *%rax
  cprintf("\n");
  801488:	48 bf 78 19 80 00 00 	movabs $0x801978,%rdi
  80148f:	00 00 00 
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
  801497:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801499:	cc                   	int3   
  while (1)
  80149a:	eb fd                	jmp    801499 <_panic+0xed>
