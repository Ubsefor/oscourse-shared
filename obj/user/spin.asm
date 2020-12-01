
obj/user/spin:     file format elf64-x86-64


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
  800023:	e8 bc 00 00 00       	callq  8000e4 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// Let it run for a couple time slices, then kill it.

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 55                	push   %r13
  800030:	41 54                	push   %r12
  800032:	53                   	push   %rbx
  800033:	48 83 ec 08          	sub    $0x8,%rsp
  envid_t env;

  cprintf("I am the parent.  Forking the child...\n");
  800037:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  80003e:	00 00 00 
  800041:	b8 00 00 00 00       	mov    $0x0,%eax
  800046:	48 ba 63 02 80 00 00 	movabs $0x800263,%rdx
  80004d:	00 00 00 
  800050:	ff d2                	callq  *%rdx
  if ((env = fork()) == 0) {
  800052:	48 b8 23 15 80 00 00 	movabs $0x801523,%rax
  800059:	00 00 00 
  80005c:	ff d0                	callq  *%rax
  80005e:	85 c0                	test   %eax,%eax
  800060:	75 1d                	jne    80007f <umain+0x55>
    cprintf("I am the child.  Spinning...\n");
  800062:	48 bf b8 1a 80 00 00 	movabs $0x801ab8,%rdi
  800069:	00 00 00 
  80006c:	b8 00 00 00 00       	mov    $0x0,%eax
  800071:	48 ba 63 02 80 00 00 	movabs $0x800263,%rdx
  800078:	00 00 00 
  80007b:	ff d2                	callq  *%rdx
    while (1)
  80007d:	eb fe                	jmp    80007d <umain+0x53>
  80007f:	41 89 c4             	mov    %eax,%r12d
      /* do nothing */;
  }

  cprintf("I am the parent.  Running the child...\n");
  800082:	48 bf 68 1a 80 00 00 	movabs $0x801a68,%rdi
  800089:	00 00 00 
  80008c:	b8 00 00 00 00       	mov    $0x0,%eax
  800091:	49 bd 63 02 80 00 00 	movabs $0x800263,%r13
  800098:	00 00 00 
  80009b:	41 ff d5             	callq  *%r13
  sys_yield();
  80009e:	48 bb 15 11 80 00 00 	movabs $0x801115,%rbx
  8000a5:	00 00 00 
  8000a8:	ff d3                	callq  *%rbx
  sys_yield();
  8000aa:	ff d3                	callq  *%rbx
  sys_yield();
  8000ac:	ff d3                	callq  *%rbx
  sys_yield();
  8000ae:	ff d3                	callq  *%rbx
  sys_yield();
  8000b0:	ff d3                	callq  *%rbx
  sys_yield();
  8000b2:	ff d3                	callq  *%rbx
  sys_yield();
  8000b4:	ff d3                	callq  *%rbx
  sys_yield();
  8000b6:	ff d3                	callq  *%rbx

  cprintf("I am the parent.  Killing the child...\n");
  8000b8:	48 bf 90 1a 80 00 00 	movabs $0x801a90,%rdi
  8000bf:	00 00 00 
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	41 ff d5             	callq  *%r13
  sys_env_destroy(env);
  8000ca:	44 89 e7             	mov    %r12d,%edi
  8000cd:	48 b8 95 10 80 00 00 	movabs $0x801095,%rax
  8000d4:	00 00 00 
  8000d7:	ff d0                	callq  *%rax
}
  8000d9:	48 83 c4 08          	add    $0x8,%rsp
  8000dd:	5b                   	pop    %rbx
  8000de:	41 5c                	pop    %r12
  8000e0:	41 5d                	pop    %r13
  8000e2:	5d                   	pop    %rbp
  8000e3:	c3                   	retq   

00000000008000e4 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  8000e4:	55                   	push   %rbp
  8000e5:	48 89 e5             	mov    %rsp,%rbp
  8000e8:	41 56                	push   %r14
  8000ea:	41 55                	push   %r13
  8000ec:	41 54                	push   %r12
  8000ee:	53                   	push   %rbx
  8000ef:	41 89 fd             	mov    %edi,%r13d
  8000f2:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  8000f5:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  8000fc:	00 00 00 
  8000ff:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  800106:	00 00 00 
  800109:	48 39 c2             	cmp    %rax,%rdx
  80010c:	73 23                	jae    800131 <libmain+0x4d>
  80010e:	48 89 d3             	mov    %rdx,%rbx
  800111:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800115:	48 29 d0             	sub    %rdx,%rax
  800118:	48 c1 e8 03          	shr    $0x3,%rax
  80011c:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800121:	b8 00 00 00 00       	mov    $0x0,%eax
  800126:	ff 13                	callq  *(%rbx)
    ctor++;
  800128:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80012c:	4c 39 e3             	cmp    %r12,%rbx
  80012f:	75 f0                	jne    800121 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800131:	48 b8 f5 10 80 00 00 	movabs $0x8010f5,%rax
  800138:	00 00 00 
  80013b:	ff d0                	callq  *%rax
  80013d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800142:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800146:	48 c1 e0 05          	shl    $0x5,%rax
  80014a:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800151:	00 00 00 
  800154:	48 01 d0             	add    %rdx,%rax
  800157:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  80015e:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800161:	45 85 ed             	test   %r13d,%r13d
  800164:	7e 0d                	jle    800173 <libmain+0x8f>
    binaryname = argv[0];
  800166:	49 8b 06             	mov    (%r14),%rax
  800169:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  800170:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800173:	4c 89 f6             	mov    %r14,%rsi
  800176:	44 89 ef             	mov    %r13d,%edi
  800179:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800180:	00 00 00 
  800183:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800185:	48 b8 9a 01 80 00 00 	movabs $0x80019a,%rax
  80018c:	00 00 00 
  80018f:	ff d0                	callq  *%rax
#endif
}
  800191:	5b                   	pop    %rbx
  800192:	41 5c                	pop    %r12
  800194:	41 5d                	pop    %r13
  800196:	41 5e                	pop    %r14
  800198:	5d                   	pop    %rbp
  800199:	c3                   	retq   

000000000080019a <exit>:

#include <inc/lib.h>

void
exit(void) {
  80019a:	55                   	push   %rbp
  80019b:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80019e:	bf 00 00 00 00       	mov    $0x0,%edi
  8001a3:	48 b8 95 10 80 00 00 	movabs $0x801095,%rax
  8001aa:	00 00 00 
  8001ad:	ff d0                	callq  *%rax
}
  8001af:	5d                   	pop    %rbp
  8001b0:	c3                   	retq   

00000000008001b1 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8001b1:	55                   	push   %rbp
  8001b2:	48 89 e5             	mov    %rsp,%rbp
  8001b5:	53                   	push   %rbx
  8001b6:	48 83 ec 08          	sub    $0x8,%rsp
  8001ba:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8001bd:	8b 06                	mov    (%rsi),%eax
  8001bf:	8d 50 01             	lea    0x1(%rax),%edx
  8001c2:	89 16                	mov    %edx,(%rsi)
  8001c4:	48 98                	cltq   
  8001c6:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8001cb:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8001d1:	74 0b                	je     8001de <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8001d3:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8001d7:	48 83 c4 08          	add    $0x8,%rsp
  8001db:	5b                   	pop    %rbx
  8001dc:	5d                   	pop    %rbp
  8001dd:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8001de:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8001e2:	be ff 00 00 00       	mov    $0xff,%esi
  8001e7:	48 b8 57 10 80 00 00 	movabs $0x801057,%rax
  8001ee:	00 00 00 
  8001f1:	ff d0                	callq  *%rax
    b->idx = 0;
  8001f3:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8001f9:	eb d8                	jmp    8001d3 <putch+0x22>

00000000008001fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8001fb:	55                   	push   %rbp
  8001fc:	48 89 e5             	mov    %rsp,%rbp
  8001ff:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800206:	48 89 fa             	mov    %rdi,%rdx
  800209:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800213:	00 00 00 
  b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80021d:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800220:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800227:	48 bf b1 01 80 00 00 	movabs $0x8001b1,%rdi
  80022e:	00 00 00 
  800231:	48 b8 21 04 80 00 00 	movabs $0x800421,%rax
  800238:	00 00 00 
  80023b:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80023d:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800244:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80024b:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80024f:	48 b8 57 10 80 00 00 	movabs $0x801057,%rax
  800256:	00 00 00 
  800259:	ff d0                	callq  *%rax

  return b.cnt;
}
  80025b:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800261:	c9                   	leaveq 
  800262:	c3                   	retq   

0000000000800263 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800263:	55                   	push   %rbp
  800264:	48 89 e5             	mov    %rsp,%rbp
  800267:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80026e:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800275:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80027c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800283:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80028a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800291:	84 c0                	test   %al,%al
  800293:	74 20                	je     8002b5 <cprintf+0x52>
  800295:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800299:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80029d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8002a1:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8002a5:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8002a9:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8002ad:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8002b1:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8002b5:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8002bc:	00 00 00 
  8002bf:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8002c6:	00 00 00 
  8002c9:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002cd:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8002d4:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8002db:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8002e2:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8002e9:	48 b8 fb 01 80 00 00 	movabs $0x8001fb,%rax
  8002f0:	00 00 00 
  8002f3:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8002f5:	c9                   	leaveq 
  8002f6:	c3                   	retq   

00000000008002f7 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8002f7:	55                   	push   %rbp
  8002f8:	48 89 e5             	mov    %rsp,%rbp
  8002fb:	41 57                	push   %r15
  8002fd:	41 56                	push   %r14
  8002ff:	41 55                	push   %r13
  800301:	41 54                	push   %r12
  800303:	53                   	push   %rbx
  800304:	48 83 ec 18          	sub    $0x18,%rsp
  800308:	49 89 fc             	mov    %rdi,%r12
  80030b:	49 89 f5             	mov    %rsi,%r13
  80030e:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800312:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800315:	41 89 cf             	mov    %ecx,%r15d
  800318:	49 39 d7             	cmp    %rdx,%r15
  80031b:	76 45                	jbe    800362 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80031d:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800321:	85 db                	test   %ebx,%ebx
  800323:	7e 0e                	jle    800333 <printnum+0x3c>
      putch(padc, putdat);
  800325:	4c 89 ee             	mov    %r13,%rsi
  800328:	44 89 f7             	mov    %r14d,%edi
  80032b:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80032e:	83 eb 01             	sub    $0x1,%ebx
  800331:	75 f2                	jne    800325 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800333:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800337:	ba 00 00 00 00       	mov    $0x0,%edx
  80033c:	49 f7 f7             	div    %r15
  80033f:	48 b8 e0 1a 80 00 00 	movabs $0x801ae0,%rax
  800346:	00 00 00 
  800349:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80034d:	4c 89 ee             	mov    %r13,%rsi
  800350:	41 ff d4             	callq  *%r12
}
  800353:	48 83 c4 18          	add    $0x18,%rsp
  800357:	5b                   	pop    %rbx
  800358:	41 5c                	pop    %r12
  80035a:	41 5d                	pop    %r13
  80035c:	41 5e                	pop    %r14
  80035e:	41 5f                	pop    %r15
  800360:	5d                   	pop    %rbp
  800361:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800362:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800366:	ba 00 00 00 00       	mov    $0x0,%edx
  80036b:	49 f7 f7             	div    %r15
  80036e:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800372:	48 89 c2             	mov    %rax,%rdx
  800375:	48 b8 f7 02 80 00 00 	movabs $0x8002f7,%rax
  80037c:	00 00 00 
  80037f:	ff d0                	callq  *%rax
  800381:	eb b0                	jmp    800333 <printnum+0x3c>

0000000000800383 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800383:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800387:	48 8b 06             	mov    (%rsi),%rax
  80038a:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80038e:	73 0a                	jae    80039a <sprintputch+0x17>
    *b->buf++ = ch;
  800390:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800394:	48 89 16             	mov    %rdx,(%rsi)
  800397:	40 88 38             	mov    %dil,(%rax)
}
  80039a:	c3                   	retq   

000000000080039b <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80039b:	55                   	push   %rbp
  80039c:	48 89 e5             	mov    %rsp,%rbp
  80039f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003a6:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003ad:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003b4:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003bb:	84 c0                	test   %al,%al
  8003bd:	74 20                	je     8003df <printfmt+0x44>
  8003bf:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003c3:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003c7:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003cb:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003cf:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003d3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003d7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003db:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8003df:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8003e6:	00 00 00 
  8003e9:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003f0:	00 00 00 
  8003f3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003f7:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003fe:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800405:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80040c:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800413:	48 b8 21 04 80 00 00 	movabs $0x800421,%rax
  80041a:	00 00 00 
  80041d:	ff d0                	callq  *%rax
}
  80041f:	c9                   	leaveq 
  800420:	c3                   	retq   

0000000000800421 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800421:	55                   	push   %rbp
  800422:	48 89 e5             	mov    %rsp,%rbp
  800425:	41 57                	push   %r15
  800427:	41 56                	push   %r14
  800429:	41 55                	push   %r13
  80042b:	41 54                	push   %r12
  80042d:	53                   	push   %rbx
  80042e:	48 83 ec 48          	sub    $0x48,%rsp
  800432:	49 89 fd             	mov    %rdi,%r13
  800435:	49 89 f7             	mov    %rsi,%r15
  800438:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80043b:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80043f:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800443:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800447:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80044b:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80044f:	41 0f b6 3e          	movzbl (%r14),%edi
  800453:	83 ff 25             	cmp    $0x25,%edi
  800456:	74 18                	je     800470 <vprintfmt+0x4f>
      if (ch == '\0')
  800458:	85 ff                	test   %edi,%edi
  80045a:	0f 84 8c 06 00 00    	je     800aec <vprintfmt+0x6cb>
      putch(ch, putdat);
  800460:	4c 89 fe             	mov    %r15,%rsi
  800463:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800466:	49 89 de             	mov    %rbx,%r14
  800469:	eb e0                	jmp    80044b <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80046b:	49 89 de             	mov    %rbx,%r14
  80046e:	eb db                	jmp    80044b <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800470:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800474:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800478:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80047f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800485:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800489:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80048e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800494:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80049a:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80049f:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8004a4:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8004a8:	0f b6 13             	movzbl (%rbx),%edx
  8004ab:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 8b 05 00 00    	ja     800a41 <vprintfmt+0x620>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	49 bb c0 1b 80 00 00 	movabs $0x801bc0,%r11
  8004c0:	00 00 00 
  8004c3:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8004c7:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8004ca:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8004ce:	eb d4                	jmp    8004a4 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004d0:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8004d3:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8004d7:	eb cb                	jmp    8004a4 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004d9:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8004dc:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8004e0:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8004e4:	8d 50 d0             	lea    -0x30(%rax),%edx
  8004e7:	83 fa 09             	cmp    $0x9,%edx
  8004ea:	77 7e                	ja     80056a <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8004ec:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8004f0:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8004f4:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8004f9:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8004fd:	8d 50 d0             	lea    -0x30(%rax),%edx
  800500:	83 fa 09             	cmp    $0x9,%edx
  800503:	76 e7                	jbe    8004ec <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800505:	4c 89 f3             	mov    %r14,%rbx
  800508:	eb 19                	jmp    800523 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80050a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80050d:	83 f8 2f             	cmp    $0x2f,%eax
  800510:	77 2a                	ja     80053c <vprintfmt+0x11b>
  800512:	89 c2                	mov    %eax,%edx
  800514:	4c 01 d2             	add    %r10,%rdx
  800517:	83 c0 08             	add    $0x8,%eax
  80051a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80051d:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800520:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800523:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800527:	0f 89 77 ff ff ff    	jns    8004a4 <vprintfmt+0x83>
          width = precision, precision = -1;
  80052d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800531:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800537:	e9 68 ff ff ff       	jmpq   8004a4 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80053c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800540:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800544:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800548:	eb d3                	jmp    80051d <vprintfmt+0xfc>
        if (width < 0)
  80054a:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80054d:	85 c0                	test   %eax,%eax
  80054f:	41 0f 48 c0          	cmovs  %r8d,%eax
  800553:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800556:	4c 89 f3             	mov    %r14,%rbx
  800559:	e9 46 ff ff ff       	jmpq   8004a4 <vprintfmt+0x83>
  80055e:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800561:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800565:	e9 3a ff ff ff       	jmpq   8004a4 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80056a:	4c 89 f3             	mov    %r14,%rbx
  80056d:	eb b4                	jmp    800523 <vprintfmt+0x102>
        lflag++;
  80056f:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800572:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800575:	e9 2a ff ff ff       	jmpq   8004a4 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80057a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80057d:	83 f8 2f             	cmp    $0x2f,%eax
  800580:	77 19                	ja     80059b <vprintfmt+0x17a>
  800582:	89 c2                	mov    %eax,%edx
  800584:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800588:	83 c0 08             	add    $0x8,%eax
  80058b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80058e:	4c 89 fe             	mov    %r15,%rsi
  800591:	8b 3a                	mov    (%rdx),%edi
  800593:	41 ff d5             	callq  *%r13
        break;
  800596:	e9 b0 fe ff ff       	jmpq   80044b <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80059b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80059f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005a3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005a7:	eb e5                	jmp    80058e <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8005a9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005ac:	83 f8 2f             	cmp    $0x2f,%eax
  8005af:	77 5b                	ja     80060c <vprintfmt+0x1eb>
  8005b1:	89 c2                	mov    %eax,%edx
  8005b3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005b7:	83 c0 08             	add    $0x8,%eax
  8005ba:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005bd:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8005bf:	89 c8                	mov    %ecx,%eax
  8005c1:	c1 f8 1f             	sar    $0x1f,%eax
  8005c4:	31 c1                	xor    %eax,%ecx
  8005c6:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c8:	83 f9 0b             	cmp    $0xb,%ecx
  8005cb:	7f 4d                	jg     80061a <vprintfmt+0x1f9>
  8005cd:	48 63 c1             	movslq %ecx,%rax
  8005d0:	48 ba 80 1e 80 00 00 	movabs $0x801e80,%rdx
  8005d7:	00 00 00 
  8005da:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8005de:	48 85 c0             	test   %rax,%rax
  8005e1:	74 37                	je     80061a <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8005e3:	48 89 c1             	mov    %rax,%rcx
  8005e6:	48 ba 01 1b 80 00 00 	movabs $0x801b01,%rdx
  8005ed:	00 00 00 
  8005f0:	4c 89 fe             	mov    %r15,%rsi
  8005f3:	4c 89 ef             	mov    %r13,%rdi
  8005f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fb:	48 bb 9b 03 80 00 00 	movabs $0x80039b,%rbx
  800602:	00 00 00 
  800605:	ff d3                	callq  *%rbx
  800607:	e9 3f fe ff ff       	jmpq   80044b <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80060c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800610:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800614:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800618:	eb a3                	jmp    8005bd <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80061a:	48 ba f8 1a 80 00 00 	movabs $0x801af8,%rdx
  800621:	00 00 00 
  800624:	4c 89 fe             	mov    %r15,%rsi
  800627:	4c 89 ef             	mov    %r13,%rdi
  80062a:	b8 00 00 00 00       	mov    $0x0,%eax
  80062f:	48 bb 9b 03 80 00 00 	movabs $0x80039b,%rbx
  800636:	00 00 00 
  800639:	ff d3                	callq  *%rbx
  80063b:	e9 0b fe ff ff       	jmpq   80044b <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800640:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800643:	83 f8 2f             	cmp    $0x2f,%eax
  800646:	77 4b                	ja     800693 <vprintfmt+0x272>
  800648:	89 c2                	mov    %eax,%edx
  80064a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80064e:	83 c0 08             	add    $0x8,%eax
  800651:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800654:	48 8b 02             	mov    (%rdx),%rax
  800657:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80065b:	48 85 c0             	test   %rax,%rax
  80065e:	0f 84 05 04 00 00    	je     800a69 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800664:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800668:	7e 06                	jle    800670 <vprintfmt+0x24f>
  80066a:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80066e:	75 31                	jne    8006a1 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800674:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800678:	0f b6 00             	movzbl (%rax),%eax
  80067b:	0f be f8             	movsbl %al,%edi
  80067e:	85 ff                	test   %edi,%edi
  800680:	0f 84 c3 00 00 00    	je     800749 <vprintfmt+0x328>
  800686:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80068a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80068e:	e9 85 00 00 00       	jmpq   800718 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800693:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800697:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80069b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80069f:	eb b3                	jmp    800654 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	49 63 f4             	movslq %r12d,%rsi
  8006a4:	48 89 c7             	mov    %rax,%rdi
  8006a7:	48 b8 f8 0b 80 00 00 	movabs $0x800bf8,%rax
  8006ae:	00 00 00 
  8006b1:	ff d0                	callq  *%rax
  8006b3:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8006b6:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8006b9:	85 f6                	test   %esi,%esi
  8006bb:	7e 22                	jle    8006df <vprintfmt+0x2be>
            putch(padc, putdat);
  8006bd:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8006c1:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8006c5:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8006c9:	4c 89 fe             	mov    %r15,%rsi
  8006cc:	89 df                	mov    %ebx,%edi
  8006ce:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	41 83 ec 01          	sub    $0x1,%r12d
  8006d5:	75 f2                	jne    8006c9 <vprintfmt+0x2a8>
  8006d7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8006db:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006df:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8006e3:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8006e7:	0f b6 00             	movzbl (%rax),%eax
  8006ea:	0f be f8             	movsbl %al,%edi
  8006ed:	85 ff                	test   %edi,%edi
  8006ef:	0f 84 56 fd ff ff    	je     80044b <vprintfmt+0x2a>
  8006f5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8006f9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8006fd:	eb 19                	jmp    800718 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8006ff:	4c 89 fe             	mov    %r15,%rsi
  800702:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800705:	41 83 ee 01          	sub    $0x1,%r14d
  800709:	48 83 c3 01          	add    $0x1,%rbx
  80070d:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800711:	0f be f8             	movsbl %al,%edi
  800714:	85 ff                	test   %edi,%edi
  800716:	74 29                	je     800741 <vprintfmt+0x320>
  800718:	45 85 e4             	test   %r12d,%r12d
  80071b:	78 06                	js     800723 <vprintfmt+0x302>
  80071d:	41 83 ec 01          	sub    $0x1,%r12d
  800721:	78 48                	js     80076b <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800723:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800727:	74 d6                	je     8006ff <vprintfmt+0x2de>
  800729:	0f be c0             	movsbl %al,%eax
  80072c:	83 e8 20             	sub    $0x20,%eax
  80072f:	83 f8 5e             	cmp    $0x5e,%eax
  800732:	76 cb                	jbe    8006ff <vprintfmt+0x2de>
            putch('?', putdat);
  800734:	4c 89 fe             	mov    %r15,%rsi
  800737:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80073c:	41 ff d5             	callq  *%r13
  80073f:	eb c4                	jmp    800705 <vprintfmt+0x2e4>
  800741:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800745:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800749:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80074c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800750:	0f 8e f5 fc ff ff    	jle    80044b <vprintfmt+0x2a>
          putch(' ', putdat);
  800756:	4c 89 fe             	mov    %r15,%rsi
  800759:	bf 20 00 00 00       	mov    $0x20,%edi
  80075e:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800761:	83 eb 01             	sub    $0x1,%ebx
  800764:	75 f0                	jne    800756 <vprintfmt+0x335>
  800766:	e9 e0 fc ff ff       	jmpq   80044b <vprintfmt+0x2a>
  80076b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80076f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800773:	eb d4                	jmp    800749 <vprintfmt+0x328>
  if (lflag >= 2)
  800775:	83 f9 01             	cmp    $0x1,%ecx
  800778:	7f 1d                	jg     800797 <vprintfmt+0x376>
  else if (lflag)
  80077a:	85 c9                	test   %ecx,%ecx
  80077c:	74 5e                	je     8007dc <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80077e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800781:	83 f8 2f             	cmp    $0x2f,%eax
  800784:	77 48                	ja     8007ce <vprintfmt+0x3ad>
  800786:	89 c2                	mov    %eax,%edx
  800788:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80078c:	83 c0 08             	add    $0x8,%eax
  80078f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800792:	48 8b 1a             	mov    (%rdx),%rbx
  800795:	eb 17                	jmp    8007ae <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800797:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80079a:	83 f8 2f             	cmp    $0x2f,%eax
  80079d:	77 21                	ja     8007c0 <vprintfmt+0x39f>
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a5:	83 c0 08             	add    $0x8,%eax
  8007a8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ab:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8007ae:	48 85 db             	test   %rbx,%rbx
  8007b1:	78 50                	js     800803 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8007b3:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8007b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007bb:	e9 b4 01 00 00       	jmpq   800974 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8007c0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007c4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007c8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007cc:	eb dd                	jmp    8007ab <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8007ce:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007d2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007d6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007da:	eb b6                	jmp    800792 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8007dc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007df:	83 f8 2f             	cmp    $0x2f,%eax
  8007e2:	77 11                	ja     8007f5 <vprintfmt+0x3d4>
  8007e4:	89 c2                	mov    %eax,%edx
  8007e6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ea:	83 c0 08             	add    $0x8,%eax
  8007ed:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007f0:	48 63 1a             	movslq (%rdx),%rbx
  8007f3:	eb b9                	jmp    8007ae <vprintfmt+0x38d>
  8007f5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007f9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007fd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800801:	eb ed                	jmp    8007f0 <vprintfmt+0x3cf>
          putch('-', putdat);
  800803:	4c 89 fe             	mov    %r15,%rsi
  800806:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80080b:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80080e:	48 89 da             	mov    %rbx,%rdx
  800811:	48 f7 da             	neg    %rdx
        base = 10;
  800814:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800819:	e9 56 01 00 00       	jmpq   800974 <vprintfmt+0x553>
  if (lflag >= 2)
  80081e:	83 f9 01             	cmp    $0x1,%ecx
  800821:	7f 25                	jg     800848 <vprintfmt+0x427>
  else if (lflag)
  800823:	85 c9                	test   %ecx,%ecx
  800825:	74 5e                	je     800885 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800827:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80082a:	83 f8 2f             	cmp    $0x2f,%eax
  80082d:	77 48                	ja     800877 <vprintfmt+0x456>
  80082f:	89 c2                	mov    %eax,%edx
  800831:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800835:	83 c0 08             	add    $0x8,%eax
  800838:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80083b:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80083e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800843:	e9 2c 01 00 00       	jmpq   800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800848:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80084b:	83 f8 2f             	cmp    $0x2f,%eax
  80084e:	77 19                	ja     800869 <vprintfmt+0x448>
  800850:	89 c2                	mov    %eax,%edx
  800852:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800856:	83 c0 08             	add    $0x8,%eax
  800859:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80085c:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80085f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800864:	e9 0b 01 00 00       	jmpq   800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800869:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80086d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800871:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800875:	eb e5                	jmp    80085c <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800877:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80087b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800883:	eb b6                	jmp    80083b <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800885:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800888:	83 f8 2f             	cmp    $0x2f,%eax
  80088b:	77 18                	ja     8008a5 <vprintfmt+0x484>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800893:	83 c0 08             	add    $0x8,%eax
  800896:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800899:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80089b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008a0:	e9 cf 00 00 00       	jmpq   800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008a5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ad:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b1:	eb e6                	jmp    800899 <vprintfmt+0x478>
  if (lflag >= 2)
  8008b3:	83 f9 01             	cmp    $0x1,%ecx
  8008b6:	7f 25                	jg     8008dd <vprintfmt+0x4bc>
  else if (lflag)
  8008b8:	85 c9                	test   %ecx,%ecx
  8008ba:	74 5b                	je     800917 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8008bc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008bf:	83 f8 2f             	cmp    $0x2f,%eax
  8008c2:	77 45                	ja     800909 <vprintfmt+0x4e8>
  8008c4:	89 c2                	mov    %eax,%edx
  8008c6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ca:	83 c0 08             	add    $0x8,%eax
  8008cd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008d0:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8008d3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008d8:	e9 97 00 00 00       	jmpq   800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008dd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008e0:	83 f8 2f             	cmp    $0x2f,%eax
  8008e3:	77 16                	ja     8008fb <vprintfmt+0x4da>
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008eb:	83 c0 08             	add    $0x8,%eax
  8008ee:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008f1:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8008f4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008f9:	eb 79                	jmp    800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008fb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800903:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800907:	eb e8                	jmp    8008f1 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800909:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800911:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800915:	eb b9                	jmp    8008d0 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800917:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091a:	83 f8 2f             	cmp    $0x2f,%eax
  80091d:	77 15                	ja     800934 <vprintfmt+0x513>
  80091f:	89 c2                	mov    %eax,%edx
  800921:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800925:	83 c0 08             	add    $0x8,%eax
  800928:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092b:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80092d:	b9 08 00 00 00       	mov    $0x8,%ecx
  800932:	eb 40                	jmp    800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800934:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800938:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800940:	eb e9                	jmp    80092b <vprintfmt+0x50a>
        putch('0', putdat);
  800942:	4c 89 fe             	mov    %r15,%rsi
  800945:	bf 30 00 00 00       	mov    $0x30,%edi
  80094a:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  80094d:	4c 89 fe             	mov    %r15,%rsi
  800950:	bf 78 00 00 00       	mov    $0x78,%edi
  800955:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800958:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095b:	83 f8 2f             	cmp    $0x2f,%eax
  80095e:	77 34                	ja     800994 <vprintfmt+0x573>
  800960:	89 c2                	mov    %eax,%edx
  800962:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800966:	83 c0 08             	add    $0x8,%eax
  800969:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80096c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80096f:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800974:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800979:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  80097d:	4c 89 fe             	mov    %r15,%rsi
  800980:	4c 89 ef             	mov    %r13,%rdi
  800983:	48 b8 f7 02 80 00 00 	movabs $0x8002f7,%rax
  80098a:	00 00 00 
  80098d:	ff d0                	callq  *%rax
        break;
  80098f:	e9 b7 fa ff ff       	jmpq   80044b <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800994:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800998:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a0:	eb ca                	jmp    80096c <vprintfmt+0x54b>
  if (lflag >= 2)
  8009a2:	83 f9 01             	cmp    $0x1,%ecx
  8009a5:	7f 22                	jg     8009c9 <vprintfmt+0x5a8>
  else if (lflag)
  8009a7:	85 c9                	test   %ecx,%ecx
  8009a9:	74 58                	je     800a03 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8009ab:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ae:	83 f8 2f             	cmp    $0x2f,%eax
  8009b1:	77 42                	ja     8009f5 <vprintfmt+0x5d4>
  8009b3:	89 c2                	mov    %eax,%edx
  8009b5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009b9:	83 c0 08             	add    $0x8,%eax
  8009bc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009bf:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009c2:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009c7:	eb ab                	jmp    800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009c9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009cc:	83 f8 2f             	cmp    $0x2f,%eax
  8009cf:	77 16                	ja     8009e7 <vprintfmt+0x5c6>
  8009d1:	89 c2                	mov    %eax,%edx
  8009d3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d7:	83 c0 08             	add    $0x8,%eax
  8009da:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009dd:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009e0:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009e5:	eb 8d                	jmp    800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009eb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ef:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009f3:	eb e8                	jmp    8009dd <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  8009f5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009fd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a01:	eb bc                	jmp    8009bf <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800a03:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a06:	83 f8 2f             	cmp    $0x2f,%eax
  800a09:	77 18                	ja     800a23 <vprintfmt+0x602>
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a11:	83 c0 08             	add    $0x8,%eax
  800a14:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a17:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800a19:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a1e:	e9 51 ff ff ff       	jmpq   800974 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a23:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a27:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a2b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a2f:	eb e6                	jmp    800a17 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800a31:	4c 89 fe             	mov    %r15,%rsi
  800a34:	bf 25 00 00 00       	mov    $0x25,%edi
  800a39:	41 ff d5             	callq  *%r13
        break;
  800a3c:	e9 0a fa ff ff       	jmpq   80044b <vprintfmt+0x2a>
        putch('%', putdat);
  800a41:	4c 89 fe             	mov    %r15,%rsi
  800a44:	bf 25 00 00 00       	mov    $0x25,%edi
  800a49:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800a4c:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800a50:	0f 84 15 fa ff ff    	je     80046b <vprintfmt+0x4a>
  800a56:	49 89 de             	mov    %rbx,%r14
  800a59:	49 83 ee 01          	sub    $0x1,%r14
  800a5d:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800a62:	75 f5                	jne    800a59 <vprintfmt+0x638>
  800a64:	e9 e2 f9 ff ff       	jmpq   80044b <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800a69:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a6d:	74 06                	je     800a75 <vprintfmt+0x654>
  800a6f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a73:	7f 21                	jg     800a96 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a75:	bf 28 00 00 00       	mov    $0x28,%edi
  800a7a:	48 bb f2 1a 80 00 00 	movabs $0x801af2,%rbx
  800a81:	00 00 00 
  800a84:	b8 28 00 00 00       	mov    $0x28,%eax
  800a89:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a8d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a91:	e9 82 fc ff ff       	jmpq   800718 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a96:	49 63 f4             	movslq %r12d,%rsi
  800a99:	48 bf f1 1a 80 00 00 	movabs $0x801af1,%rdi
  800aa0:	00 00 00 
  800aa3:	48 b8 f8 0b 80 00 00 	movabs $0x800bf8,%rax
  800aaa:	00 00 00 
  800aad:	ff d0                	callq  *%rax
  800aaf:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800ab2:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800ab5:	48 be f1 1a 80 00 00 	movabs $0x801af1,%rsi
  800abc:	00 00 00 
  800abf:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	0f 8f f2 fb ff ff    	jg     8006bd <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800acb:	48 bb f2 1a 80 00 00 	movabs $0x801af2,%rbx
  800ad2:	00 00 00 
  800ad5:	b8 28 00 00 00       	mov    $0x28,%eax
  800ada:	bf 28 00 00 00       	mov    $0x28,%edi
  800adf:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ae3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800ae7:	e9 2c fc ff ff       	jmpq   800718 <vprintfmt+0x2f7>
}
  800aec:	48 83 c4 48          	add    $0x48,%rsp
  800af0:	5b                   	pop    %rbx
  800af1:	41 5c                	pop    %r12
  800af3:	41 5d                	pop    %r13
  800af5:	41 5e                	pop    %r14
  800af7:	41 5f                	pop    %r15
  800af9:	5d                   	pop    %rbp
  800afa:	c3                   	retq   

0000000000800afb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800afb:	55                   	push   %rbp
  800afc:	48 89 e5             	mov    %rsp,%rbp
  800aff:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800b03:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800b07:	48 63 c6             	movslq %esi,%rax
  800b0a:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800b0f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800b13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800b1a:	48 85 ff             	test   %rdi,%rdi
  800b1d:	74 2a                	je     800b49 <vsnprintf+0x4e>
  800b1f:	85 f6                	test   %esi,%esi
  800b21:	7e 26                	jle    800b49 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800b23:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800b27:	48 bf 83 03 80 00 00 	movabs $0x800383,%rdi
  800b2e:	00 00 00 
  800b31:	48 b8 21 04 80 00 00 	movabs $0x800421,%rax
  800b38:	00 00 00 
  800b3b:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800b3d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800b41:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800b44:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800b47:	c9                   	leaveq 
  800b48:	c3                   	retq   
    return -E_INVAL;
  800b49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b4e:	eb f7                	jmp    800b47 <vsnprintf+0x4c>

0000000000800b50 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800b50:	55                   	push   %rbp
  800b51:	48 89 e5             	mov    %rsp,%rbp
  800b54:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800b5b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800b62:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800b69:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800b70:	84 c0                	test   %al,%al
  800b72:	74 20                	je     800b94 <snprintf+0x44>
  800b74:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800b78:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800b7c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b80:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b84:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b88:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b8c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b90:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b94:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b9b:	00 00 00 
  800b9e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ba5:	00 00 00 
  800ba8:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800bac:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800bb3:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800bba:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800bc1:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800bc8:	48 b8 fb 0a 80 00 00 	movabs $0x800afb,%rax
  800bcf:	00 00 00 
  800bd2:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800bd4:	c9                   	leaveq 
  800bd5:	c3                   	retq   

0000000000800bd6 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800bd6:	80 3f 00             	cmpb   $0x0,(%rdi)
  800bd9:	74 17                	je     800bf2 <strlen+0x1c>
  800bdb:	48 89 fa             	mov    %rdi,%rdx
  800bde:	b9 01 00 00 00       	mov    $0x1,%ecx
  800be3:	29 f9                	sub    %edi,%ecx
    n++;
  800be5:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800be8:	48 83 c2 01          	add    $0x1,%rdx
  800bec:	80 3a 00             	cmpb   $0x0,(%rdx)
  800bef:	75 f4                	jne    800be5 <strlen+0xf>
  800bf1:	c3                   	retq   
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800bf7:	c3                   	retq   

0000000000800bf8 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf8:	48 85 f6             	test   %rsi,%rsi
  800bfb:	74 24                	je     800c21 <strnlen+0x29>
  800bfd:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c00:	74 25                	je     800c27 <strnlen+0x2f>
  800c02:	48 01 fe             	add    %rdi,%rsi
  800c05:	48 89 fa             	mov    %rdi,%rdx
  800c08:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c0d:	29 f9                	sub    %edi,%ecx
    n++;
  800c0f:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c12:	48 83 c2 01          	add    $0x1,%rdx
  800c16:	48 39 f2             	cmp    %rsi,%rdx
  800c19:	74 11                	je     800c2c <strnlen+0x34>
  800c1b:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c1e:	75 ef                	jne    800c0f <strnlen+0x17>
  800c20:	c3                   	retq   
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	c3                   	retq   
  800c27:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c2c:	c3                   	retq   

0000000000800c2d <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800c2d:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800c30:	ba 00 00 00 00       	mov    $0x0,%edx
  800c35:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800c39:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800c3c:	48 83 c2 01          	add    $0x1,%rdx
  800c40:	84 c9                	test   %cl,%cl
  800c42:	75 f1                	jne    800c35 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800c44:	c3                   	retq   

0000000000800c45 <strcat>:

char *
strcat(char *dst, const char *src) {
  800c45:	55                   	push   %rbp
  800c46:	48 89 e5             	mov    %rsp,%rbp
  800c49:	41 54                	push   %r12
  800c4b:	53                   	push   %rbx
  800c4c:	48 89 fb             	mov    %rdi,%rbx
  800c4f:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800c52:	48 b8 d6 0b 80 00 00 	movabs $0x800bd6,%rax
  800c59:	00 00 00 
  800c5c:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800c5e:	48 63 f8             	movslq %eax,%rdi
  800c61:	48 01 df             	add    %rbx,%rdi
  800c64:	4c 89 e6             	mov    %r12,%rsi
  800c67:	48 b8 2d 0c 80 00 00 	movabs $0x800c2d,%rax
  800c6e:	00 00 00 
  800c71:	ff d0                	callq  *%rax
  return dst;
}
  800c73:	48 89 d8             	mov    %rbx,%rax
  800c76:	5b                   	pop    %rbx
  800c77:	41 5c                	pop    %r12
  800c79:	5d                   	pop    %rbp
  800c7a:	c3                   	retq   

0000000000800c7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c7b:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c7e:	48 85 d2             	test   %rdx,%rdx
  800c81:	74 1f                	je     800ca2 <strncpy+0x27>
  800c83:	48 01 fa             	add    %rdi,%rdx
  800c86:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c89:	48 83 c1 01          	add    $0x1,%rcx
  800c8d:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c91:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c95:	41 80 f8 01          	cmp    $0x1,%r8b
  800c99:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c9d:	48 39 ca             	cmp    %rcx,%rdx
  800ca0:	75 e7                	jne    800c89 <strncpy+0xe>
  }
  return ret;
}
  800ca2:	c3                   	retq   

0000000000800ca3 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800ca3:	48 89 f8             	mov    %rdi,%rax
  800ca6:	48 85 d2             	test   %rdx,%rdx
  800ca9:	74 36                	je     800ce1 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800cab:	48 83 fa 01          	cmp    $0x1,%rdx
  800caf:	74 2d                	je     800cde <strlcpy+0x3b>
  800cb1:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cb5:	45 84 c0             	test   %r8b,%r8b
  800cb8:	74 24                	je     800cde <strlcpy+0x3b>
  800cba:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800cbe:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800cc3:	48 83 c0 01          	add    $0x1,%rax
  800cc7:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800ccb:	48 39 d1             	cmp    %rdx,%rcx
  800cce:	74 0e                	je     800cde <strlcpy+0x3b>
  800cd0:	48 83 c1 01          	add    $0x1,%rcx
  800cd4:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800cd9:	45 84 c0             	test   %r8b,%r8b
  800cdc:	75 e5                	jne    800cc3 <strlcpy+0x20>
    *dst = '\0';
  800cde:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800ce1:	48 29 f8             	sub    %rdi,%rax
}
  800ce4:	c3                   	retq   

0000000000800ce5 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800ce5:	0f b6 07             	movzbl (%rdi),%eax
  800ce8:	84 c0                	test   %al,%al
  800cea:	74 17                	je     800d03 <strcmp+0x1e>
  800cec:	3a 06                	cmp    (%rsi),%al
  800cee:	75 13                	jne    800d03 <strcmp+0x1e>
    p++, q++;
  800cf0:	48 83 c7 01          	add    $0x1,%rdi
  800cf4:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800cf8:	0f b6 07             	movzbl (%rdi),%eax
  800cfb:	84 c0                	test   %al,%al
  800cfd:	74 04                	je     800d03 <strcmp+0x1e>
  800cff:	3a 06                	cmp    (%rsi),%al
  800d01:	74 ed                	je     800cf0 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800d03:	0f b6 c0             	movzbl %al,%eax
  800d06:	0f b6 16             	movzbl (%rsi),%edx
  800d09:	29 d0                	sub    %edx,%eax
}
  800d0b:	c3                   	retq   

0000000000800d0c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800d0c:	48 85 d2             	test   %rdx,%rdx
  800d0f:	74 2f                	je     800d40 <strncmp+0x34>
  800d11:	0f b6 07             	movzbl (%rdi),%eax
  800d14:	84 c0                	test   %al,%al
  800d16:	74 1f                	je     800d37 <strncmp+0x2b>
  800d18:	3a 06                	cmp    (%rsi),%al
  800d1a:	75 1b                	jne    800d37 <strncmp+0x2b>
  800d1c:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800d1f:	48 83 c7 01          	add    $0x1,%rdi
  800d23:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800d27:	48 39 d7             	cmp    %rdx,%rdi
  800d2a:	74 1a                	je     800d46 <strncmp+0x3a>
  800d2c:	0f b6 07             	movzbl (%rdi),%eax
  800d2f:	84 c0                	test   %al,%al
  800d31:	74 04                	je     800d37 <strncmp+0x2b>
  800d33:	3a 06                	cmp    (%rsi),%al
  800d35:	74 e8                	je     800d1f <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800d37:	0f b6 07             	movzbl (%rdi),%eax
  800d3a:	0f b6 16             	movzbl (%rsi),%edx
  800d3d:	29 d0                	sub    %edx,%eax
}
  800d3f:	c3                   	retq   
    return 0;
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  800d45:	c3                   	retq   
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4b:	c3                   	retq   

0000000000800d4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800d4c:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800d4e:	0f b6 07             	movzbl (%rdi),%eax
  800d51:	84 c0                	test   %al,%al
  800d53:	74 1e                	je     800d73 <strchr+0x27>
    if (*s == c)
  800d55:	40 38 c6             	cmp    %al,%sil
  800d58:	74 1f                	je     800d79 <strchr+0x2d>
  for (; *s; s++)
  800d5a:	48 83 c7 01          	add    $0x1,%rdi
  800d5e:	0f b6 07             	movzbl (%rdi),%eax
  800d61:	84 c0                	test   %al,%al
  800d63:	74 08                	je     800d6d <strchr+0x21>
    if (*s == c)
  800d65:	38 d0                	cmp    %dl,%al
  800d67:	75 f1                	jne    800d5a <strchr+0xe>
  for (; *s; s++)
  800d69:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800d6c:	c3                   	retq   
  return 0;
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d72:	c3                   	retq   
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	c3                   	retq   
    if (*s == c)
  800d79:	48 89 f8             	mov    %rdi,%rax
  800d7c:	c3                   	retq   

0000000000800d7d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800d7d:	48 89 f8             	mov    %rdi,%rax
  800d80:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d82:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d85:	40 38 f2             	cmp    %sil,%dl
  800d88:	74 13                	je     800d9d <strfind+0x20>
  800d8a:	84 d2                	test   %dl,%dl
  800d8c:	74 0f                	je     800d9d <strfind+0x20>
  for (; *s; s++)
  800d8e:	48 83 c0 01          	add    $0x1,%rax
  800d92:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d95:	38 ca                	cmp    %cl,%dl
  800d97:	74 04                	je     800d9d <strfind+0x20>
  800d99:	84 d2                	test   %dl,%dl
  800d9b:	75 f1                	jne    800d8e <strfind+0x11>
      break;
  return (char *)s;
}
  800d9d:	c3                   	retq   

0000000000800d9e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d9e:	48 85 d2             	test   %rdx,%rdx
  800da1:	74 3a                	je     800ddd <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800da3:	48 89 f8             	mov    %rdi,%rax
  800da6:	48 09 d0             	or     %rdx,%rax
  800da9:	a8 03                	test   $0x3,%al
  800dab:	75 28                	jne    800dd5 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800dad:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800db1:	89 f0                	mov    %esi,%eax
  800db3:	c1 e0 08             	shl    $0x8,%eax
  800db6:	89 f1                	mov    %esi,%ecx
  800db8:	c1 e1 18             	shl    $0x18,%ecx
  800dbb:	41 89 f0             	mov    %esi,%r8d
  800dbe:	41 c1 e0 10          	shl    $0x10,%r8d
  800dc2:	44 09 c1             	or     %r8d,%ecx
  800dc5:	09 ce                	or     %ecx,%esi
  800dc7:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800dc9:	48 c1 ea 02          	shr    $0x2,%rdx
  800dcd:	48 89 d1             	mov    %rdx,%rcx
  800dd0:	fc                   	cld    
  800dd1:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800dd3:	eb 08                	jmp    800ddd <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800dd5:	89 f0                	mov    %esi,%eax
  800dd7:	48 89 d1             	mov    %rdx,%rcx
  800dda:	fc                   	cld    
  800ddb:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ddd:	48 89 f8             	mov    %rdi,%rax
  800de0:	c3                   	retq   

0000000000800de1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800de1:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800de4:	48 39 fe             	cmp    %rdi,%rsi
  800de7:	73 40                	jae    800e29 <memmove+0x48>
  800de9:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ded:	48 39 f9             	cmp    %rdi,%rcx
  800df0:	76 37                	jbe    800e29 <memmove+0x48>
    s += n;
    d += n;
  800df2:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800df6:	48 89 fe             	mov    %rdi,%rsi
  800df9:	48 09 d6             	or     %rdx,%rsi
  800dfc:	48 09 ce             	or     %rcx,%rsi
  800dff:	40 f6 c6 03          	test   $0x3,%sil
  800e03:	75 14                	jne    800e19 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800e05:	48 83 ef 04          	sub    $0x4,%rdi
  800e09:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800e0d:	48 c1 ea 02          	shr    $0x2,%rdx
  800e11:	48 89 d1             	mov    %rdx,%rcx
  800e14:	fd                   	std    
  800e15:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e17:	eb 0e                	jmp    800e27 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800e19:	48 83 ef 01          	sub    $0x1,%rdi
  800e1d:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800e21:	48 89 d1             	mov    %rdx,%rcx
  800e24:	fd                   	std    
  800e25:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800e27:	fc                   	cld    
  800e28:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e29:	48 89 c1             	mov    %rax,%rcx
  800e2c:	48 09 d1             	or     %rdx,%rcx
  800e2f:	48 09 f1             	or     %rsi,%rcx
  800e32:	f6 c1 03             	test   $0x3,%cl
  800e35:	75 0e                	jne    800e45 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800e37:	48 c1 ea 02          	shr    $0x2,%rdx
  800e3b:	48 89 d1             	mov    %rdx,%rcx
  800e3e:	48 89 c7             	mov    %rax,%rdi
  800e41:	fc                   	cld    
  800e42:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e44:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800e45:	48 89 c7             	mov    %rax,%rdi
  800e48:	48 89 d1             	mov    %rdx,%rcx
  800e4b:	fc                   	cld    
  800e4c:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800e4e:	c3                   	retq   

0000000000800e4f <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800e4f:	55                   	push   %rbp
  800e50:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800e53:	48 b8 e1 0d 80 00 00 	movabs $0x800de1,%rax
  800e5a:	00 00 00 
  800e5d:	ff d0                	callq  *%rax
}
  800e5f:	5d                   	pop    %rbp
  800e60:	c3                   	retq   

0000000000800e61 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800e61:	55                   	push   %rbp
  800e62:	48 89 e5             	mov    %rsp,%rbp
  800e65:	41 57                	push   %r15
  800e67:	41 56                	push   %r14
  800e69:	41 55                	push   %r13
  800e6b:	41 54                	push   %r12
  800e6d:	53                   	push   %rbx
  800e6e:	48 83 ec 08          	sub    $0x8,%rsp
  800e72:	49 89 fe             	mov    %rdi,%r14
  800e75:	49 89 f7             	mov    %rsi,%r15
  800e78:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800e7b:	48 89 f7             	mov    %rsi,%rdi
  800e7e:	48 b8 d6 0b 80 00 00 	movabs $0x800bd6,%rax
  800e85:	00 00 00 
  800e88:	ff d0                	callq  *%rax
  800e8a:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e8d:	4c 89 ee             	mov    %r13,%rsi
  800e90:	4c 89 f7             	mov    %r14,%rdi
  800e93:	48 b8 f8 0b 80 00 00 	movabs $0x800bf8,%rax
  800e9a:	00 00 00 
  800e9d:	ff d0                	callq  *%rax
  800e9f:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800ea2:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800ea6:	4d 39 e5             	cmp    %r12,%r13
  800ea9:	74 26                	je     800ed1 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800eab:	4c 89 e8             	mov    %r13,%rax
  800eae:	4c 29 e0             	sub    %r12,%rax
  800eb1:	48 39 d8             	cmp    %rbx,%rax
  800eb4:	76 2a                	jbe    800ee0 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800eb6:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800eba:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ebe:	4c 89 fe             	mov    %r15,%rsi
  800ec1:	48 b8 4f 0e 80 00 00 	movabs $0x800e4f,%rax
  800ec8:	00 00 00 
  800ecb:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800ecd:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800ed1:	48 83 c4 08          	add    $0x8,%rsp
  800ed5:	5b                   	pop    %rbx
  800ed6:	41 5c                	pop    %r12
  800ed8:	41 5d                	pop    %r13
  800eda:	41 5e                	pop    %r14
  800edc:	41 5f                	pop    %r15
  800ede:	5d                   	pop    %rbp
  800edf:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800ee0:	49 83 ed 01          	sub    $0x1,%r13
  800ee4:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ee8:	4c 89 ea             	mov    %r13,%rdx
  800eeb:	4c 89 fe             	mov    %r15,%rsi
  800eee:	48 b8 4f 0e 80 00 00 	movabs $0x800e4f,%rax
  800ef5:	00 00 00 
  800ef8:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800efa:	4d 01 ee             	add    %r13,%r14
  800efd:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800f02:	eb c9                	jmp    800ecd <strlcat+0x6c>

0000000000800f04 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800f04:	48 85 d2             	test   %rdx,%rdx
  800f07:	74 3a                	je     800f43 <memcmp+0x3f>
    if (*s1 != *s2)
  800f09:	0f b6 0f             	movzbl (%rdi),%ecx
  800f0c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800f10:	44 38 c1             	cmp    %r8b,%cl
  800f13:	75 1d                	jne    800f32 <memcmp+0x2e>
  800f15:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800f1a:	48 39 d0             	cmp    %rdx,%rax
  800f1d:	74 1e                	je     800f3d <memcmp+0x39>
    if (*s1 != *s2)
  800f1f:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800f23:	48 83 c0 01          	add    $0x1,%rax
  800f27:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800f2d:	44 38 c1             	cmp    %r8b,%cl
  800f30:	74 e8                	je     800f1a <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800f32:	0f b6 c1             	movzbl %cl,%eax
  800f35:	45 0f b6 c0          	movzbl %r8b,%r8d
  800f39:	44 29 c0             	sub    %r8d,%eax
  800f3c:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	c3                   	retq   
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f48:	c3                   	retq   

0000000000800f49 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800f49:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800f4d:	48 39 c7             	cmp    %rax,%rdi
  800f50:	73 19                	jae    800f6b <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f52:	89 f2                	mov    %esi,%edx
  800f54:	40 38 37             	cmp    %sil,(%rdi)
  800f57:	74 16                	je     800f6f <memfind+0x26>
  for (; s < ends; s++)
  800f59:	48 83 c7 01          	add    $0x1,%rdi
  800f5d:	48 39 f8             	cmp    %rdi,%rax
  800f60:	74 08                	je     800f6a <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f62:	38 17                	cmp    %dl,(%rdi)
  800f64:	75 f3                	jne    800f59 <memfind+0x10>
  for (; s < ends; s++)
  800f66:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800f69:	c3                   	retq   
  800f6a:	c3                   	retq   
  for (; s < ends; s++)
  800f6b:	48 89 f8             	mov    %rdi,%rax
  800f6e:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800f6f:	48 89 f8             	mov    %rdi,%rax
  800f72:	c3                   	retq   

0000000000800f73 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f73:	0f b6 07             	movzbl (%rdi),%eax
  800f76:	3c 20                	cmp    $0x20,%al
  800f78:	74 04                	je     800f7e <strtol+0xb>
  800f7a:	3c 09                	cmp    $0x9,%al
  800f7c:	75 0f                	jne    800f8d <strtol+0x1a>
    s++;
  800f7e:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f82:	0f b6 07             	movzbl (%rdi),%eax
  800f85:	3c 20                	cmp    $0x20,%al
  800f87:	74 f5                	je     800f7e <strtol+0xb>
  800f89:	3c 09                	cmp    $0x9,%al
  800f8b:	74 f1                	je     800f7e <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f8d:	3c 2b                	cmp    $0x2b,%al
  800f8f:	74 2b                	je     800fbc <strtol+0x49>
  int neg  = 0;
  800f91:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f97:	3c 2d                	cmp    $0x2d,%al
  800f99:	74 2d                	je     800fc8 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f9b:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800fa1:	75 0f                	jne    800fb2 <strtol+0x3f>
  800fa3:	80 3f 30             	cmpb   $0x30,(%rdi)
  800fa6:	74 2c                	je     800fd4 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800fa8:	85 d2                	test   %edx,%edx
  800faa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800faf:	0f 44 d0             	cmove  %eax,%edx
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800fb7:	4c 63 d2             	movslq %edx,%r10
  800fba:	eb 5c                	jmp    801018 <strtol+0xa5>
    s++;
  800fbc:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800fc0:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800fc6:	eb d3                	jmp    800f9b <strtol+0x28>
    s++, neg = 1;
  800fc8:	48 83 c7 01          	add    $0x1,%rdi
  800fcc:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800fd2:	eb c7                	jmp    800f9b <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd4:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800fd8:	74 0f                	je     800fe9 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800fda:	85 d2                	test   %edx,%edx
  800fdc:	75 d4                	jne    800fb2 <strtol+0x3f>
    s++, base = 8;
  800fde:	48 83 c7 01          	add    $0x1,%rdi
  800fe2:	ba 08 00 00 00       	mov    $0x8,%edx
  800fe7:	eb c9                	jmp    800fb2 <strtol+0x3f>
    s += 2, base = 16;
  800fe9:	48 83 c7 02          	add    $0x2,%rdi
  800fed:	ba 10 00 00 00       	mov    $0x10,%edx
  800ff2:	eb be                	jmp    800fb2 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800ff4:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800ff8:	41 80 f8 19          	cmp    $0x19,%r8b
  800ffc:	77 2f                	ja     80102d <strtol+0xba>
      dig = *s - 'a' + 10;
  800ffe:	44 0f be c1          	movsbl %cl,%r8d
  801002:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801006:	39 d1                	cmp    %edx,%ecx
  801008:	7d 37                	jge    801041 <strtol+0xce>
    s++, val = (val * base) + dig;
  80100a:	48 83 c7 01          	add    $0x1,%rdi
  80100e:	49 0f af c2          	imul   %r10,%rax
  801012:	48 63 c9             	movslq %ecx,%rcx
  801015:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801018:	0f b6 0f             	movzbl (%rdi),%ecx
  80101b:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80101f:	41 80 f8 09          	cmp    $0x9,%r8b
  801023:	77 cf                	ja     800ff4 <strtol+0x81>
      dig = *s - '0';
  801025:	0f be c9             	movsbl %cl,%ecx
  801028:	83 e9 30             	sub    $0x30,%ecx
  80102b:	eb d9                	jmp    801006 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80102d:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801031:	41 80 f8 19          	cmp    $0x19,%r8b
  801035:	77 0a                	ja     801041 <strtol+0xce>
      dig = *s - 'A' + 10;
  801037:	44 0f be c1          	movsbl %cl,%r8d
  80103b:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80103f:	eb c5                	jmp    801006 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801041:	48 85 f6             	test   %rsi,%rsi
  801044:	74 03                	je     801049 <strtol+0xd6>
    *endptr = (char *)s;
  801046:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801049:	48 89 c2             	mov    %rax,%rdx
  80104c:	48 f7 da             	neg    %rdx
  80104f:	45 85 c9             	test   %r9d,%r9d
  801052:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801056:	c3                   	retq   

0000000000801057 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  801057:	55                   	push   %rbp
  801058:	48 89 e5             	mov    %rsp,%rbp
  80105b:	53                   	push   %rbx
  80105c:	48 89 fa             	mov    %rdi,%rdx
  80105f:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	48 89 c3             	mov    %rax,%rbx
  80106a:	48 89 c7             	mov    %rax,%rdi
  80106d:	48 89 c6             	mov    %rax,%rsi
  801070:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801072:	5b                   	pop    %rbx
  801073:	5d                   	pop    %rbp
  801074:	c3                   	retq   

0000000000801075 <sys_cgetc>:

int
sys_cgetc(void) {
  801075:	55                   	push   %rbp
  801076:	48 89 e5             	mov    %rsp,%rbp
  801079:	53                   	push   %rbx
  asm volatile("int %1\n"
  80107a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107f:	b8 01 00 00 00       	mov    $0x1,%eax
  801084:	48 89 ca             	mov    %rcx,%rdx
  801087:	48 89 cb             	mov    %rcx,%rbx
  80108a:	48 89 cf             	mov    %rcx,%rdi
  80108d:	48 89 ce             	mov    %rcx,%rsi
  801090:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801092:	5b                   	pop    %rbx
  801093:	5d                   	pop    %rbp
  801094:	c3                   	retq   

0000000000801095 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801095:	55                   	push   %rbp
  801096:	48 89 e5             	mov    %rsp,%rbp
  801099:	53                   	push   %rbx
  80109a:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80109e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8010a1:	be 00 00 00 00       	mov    $0x0,%esi
  8010a6:	b8 03 00 00 00       	mov    $0x3,%eax
  8010ab:	48 89 f1             	mov    %rsi,%rcx
  8010ae:	48 89 f3             	mov    %rsi,%rbx
  8010b1:	48 89 f7             	mov    %rsi,%rdi
  8010b4:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010b6:	48 85 c0             	test   %rax,%rax
  8010b9:	7f 07                	jg     8010c2 <sys_env_destroy+0x2d>
}
  8010bb:	48 83 c4 08          	add    $0x8,%rsp
  8010bf:	5b                   	pop    %rbx
  8010c0:	5d                   	pop    %rbp
  8010c1:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010c2:	49 89 c0             	mov    %rax,%r8
  8010c5:	b9 03 00 00 00       	mov    $0x3,%ecx
  8010ca:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  8010d1:	00 00 00 
  8010d4:	be 22 00 00 00       	mov    $0x22,%esi
  8010d9:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  8010e0:	00 00 00 
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e8:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  8010ef:	00 00 00 
  8010f2:	41 ff d1             	callq  *%r9

00000000008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8010f5:	55                   	push   %rbp
  8010f6:	48 89 e5             	mov    %rsp,%rbp
  8010f9:	53                   	push   %rbx
  asm volatile("int %1\n"
  8010fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801104:	48 89 ca             	mov    %rcx,%rdx
  801107:	48 89 cb             	mov    %rcx,%rbx
  80110a:	48 89 cf             	mov    %rcx,%rdi
  80110d:	48 89 ce             	mov    %rcx,%rsi
  801110:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801112:	5b                   	pop    %rbx
  801113:	5d                   	pop    %rbp
  801114:	c3                   	retq   

0000000000801115 <sys_yield>:

void
sys_yield(void) {
  801115:	55                   	push   %rbp
  801116:	48 89 e5             	mov    %rsp,%rbp
  801119:	53                   	push   %rbx
  asm volatile("int %1\n"
  80111a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801124:	48 89 ca             	mov    %rcx,%rdx
  801127:	48 89 cb             	mov    %rcx,%rbx
  80112a:	48 89 cf             	mov    %rcx,%rdi
  80112d:	48 89 ce             	mov    %rcx,%rsi
  801130:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801132:	5b                   	pop    %rbx
  801133:	5d                   	pop    %rbp
  801134:	c3                   	retq   

0000000000801135 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  801135:	55                   	push   %rbp
  801136:	48 89 e5             	mov    %rsp,%rbp
  801139:	53                   	push   %rbx
  80113a:	48 83 ec 08          	sub    $0x8,%rsp
  80113e:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801141:	4c 63 c7             	movslq %edi,%r8
  801144:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  801147:	be 00 00 00 00       	mov    $0x0,%esi
  80114c:	b8 04 00 00 00       	mov    $0x4,%eax
  801151:	4c 89 c2             	mov    %r8,%rdx
  801154:	48 89 f7             	mov    %rsi,%rdi
  801157:	cd 30                	int    $0x30
  if (check && ret > 0)
  801159:	48 85 c0             	test   %rax,%rax
  80115c:	7f 07                	jg     801165 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80115e:	48 83 c4 08          	add    $0x8,%rsp
  801162:	5b                   	pop    %rbx
  801163:	5d                   	pop    %rbp
  801164:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801165:	49 89 c0             	mov    %rax,%r8
  801168:	b9 04 00 00 00       	mov    $0x4,%ecx
  80116d:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  801174:	00 00 00 
  801177:	be 22 00 00 00       	mov    $0x22,%esi
  80117c:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  801183:	00 00 00 
  801186:	b8 00 00 00 00       	mov    $0x0,%eax
  80118b:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  801192:	00 00 00 
  801195:	41 ff d1             	callq  *%r9

0000000000801198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801198:	55                   	push   %rbp
  801199:	48 89 e5             	mov    %rsp,%rbp
  80119c:	53                   	push   %rbx
  80119d:	48 83 ec 08          	sub    $0x8,%rsp
  8011a1:	41 89 f9             	mov    %edi,%r9d
  8011a4:	49 89 f2             	mov    %rsi,%r10
  8011a7:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8011aa:	4d 63 c9             	movslq %r9d,%r9
  8011ad:	48 63 da             	movslq %edx,%rbx
  8011b0:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8011b3:	b8 05 00 00 00       	mov    $0x5,%eax
  8011b8:	4c 89 ca             	mov    %r9,%rdx
  8011bb:	4c 89 d1             	mov    %r10,%rcx
  8011be:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011c0:	48 85 c0             	test   %rax,%rax
  8011c3:	7f 07                	jg     8011cc <sys_page_map+0x34>
}
  8011c5:	48 83 c4 08          	add    $0x8,%rsp
  8011c9:	5b                   	pop    %rbx
  8011ca:	5d                   	pop    %rbp
  8011cb:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011cc:	49 89 c0             	mov    %rax,%r8
  8011cf:	b9 05 00 00 00       	mov    $0x5,%ecx
  8011d4:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  8011db:	00 00 00 
  8011de:	be 22 00 00 00       	mov    $0x22,%esi
  8011e3:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  8011ea:	00 00 00 
  8011ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f2:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  8011f9:	00 00 00 
  8011fc:	41 ff d1             	callq  *%r9

00000000008011ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8011ff:	55                   	push   %rbp
  801200:	48 89 e5             	mov    %rsp,%rbp
  801203:	53                   	push   %rbx
  801204:	48 83 ec 08          	sub    $0x8,%rsp
  801208:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  80120b:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80120e:	be 00 00 00 00       	mov    $0x0,%esi
  801213:	b8 06 00 00 00       	mov    $0x6,%eax
  801218:	48 89 f3             	mov    %rsi,%rbx
  80121b:	48 89 f7             	mov    %rsi,%rdi
  80121e:	cd 30                	int    $0x30
  if (check && ret > 0)
  801220:	48 85 c0             	test   %rax,%rax
  801223:	7f 07                	jg     80122c <sys_page_unmap+0x2d>
}
  801225:	48 83 c4 08          	add    $0x8,%rsp
  801229:	5b                   	pop    %rbx
  80122a:	5d                   	pop    %rbp
  80122b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80122c:	49 89 c0             	mov    %rax,%r8
  80122f:	b9 06 00 00 00       	mov    $0x6,%ecx
  801234:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  80123b:	00 00 00 
  80123e:	be 22 00 00 00       	mov    $0x22,%esi
  801243:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  80124a:	00 00 00 
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  801259:	00 00 00 
  80125c:	41 ff d1             	callq  *%r9

000000000080125f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  80125f:	55                   	push   %rbp
  801260:	48 89 e5             	mov    %rsp,%rbp
  801263:	53                   	push   %rbx
  801264:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801268:	48 63 d7             	movslq %edi,%rdx
  80126b:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80126e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801273:	b8 08 00 00 00       	mov    $0x8,%eax
  801278:	48 89 df             	mov    %rbx,%rdi
  80127b:	48 89 de             	mov    %rbx,%rsi
  80127e:	cd 30                	int    $0x30
  if (check && ret > 0)
  801280:	48 85 c0             	test   %rax,%rax
  801283:	7f 07                	jg     80128c <sys_env_set_status+0x2d>
}
  801285:	48 83 c4 08          	add    $0x8,%rsp
  801289:	5b                   	pop    %rbx
  80128a:	5d                   	pop    %rbp
  80128b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80128c:	49 89 c0             	mov    %rax,%r8
  80128f:	b9 08 00 00 00       	mov    $0x8,%ecx
  801294:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  80129b:	00 00 00 
  80129e:	be 22 00 00 00       	mov    $0x22,%esi
  8012a3:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  8012aa:	00 00 00 
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  8012b9:	00 00 00 
  8012bc:	41 ff d1             	callq  *%r9

00000000008012bf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8012bf:	55                   	push   %rbp
  8012c0:	48 89 e5             	mov    %rsp,%rbp
  8012c3:	53                   	push   %rbx
  8012c4:	48 83 ec 08          	sub    $0x8,%rsp
  8012c8:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  8012cb:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8012ce:	be 00 00 00 00       	mov    $0x0,%esi
  8012d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8012d8:	48 89 f3             	mov    %rsi,%rbx
  8012db:	48 89 f7             	mov    %rsi,%rdi
  8012de:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012e0:	48 85 c0             	test   %rax,%rax
  8012e3:	7f 07                	jg     8012ec <sys_env_set_pgfault_upcall+0x2d>
}
  8012e5:	48 83 c4 08          	add    $0x8,%rsp
  8012e9:	5b                   	pop    %rbx
  8012ea:	5d                   	pop    %rbp
  8012eb:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012ec:	49 89 c0             	mov    %rax,%r8
  8012ef:	b9 09 00 00 00       	mov    $0x9,%ecx
  8012f4:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  8012fb:	00 00 00 
  8012fe:	be 22 00 00 00       	mov    $0x22,%esi
  801303:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  80130a:	00 00 00 
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
  801312:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  801319:	00 00 00 
  80131c:	41 ff d1             	callq  *%r9

000000000080131f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80131f:	55                   	push   %rbp
  801320:	48 89 e5             	mov    %rsp,%rbp
  801323:	53                   	push   %rbx
  801324:	49 89 f0             	mov    %rsi,%r8
  801327:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  80132a:	48 63 d7             	movslq %edi,%rdx
  80132d:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801330:	b8 0b 00 00 00       	mov    $0xb,%eax
  801335:	be 00 00 00 00       	mov    $0x0,%esi
  80133a:	4c 89 c1             	mov    %r8,%rcx
  80133d:	cd 30                	int    $0x30
}
  80133f:	5b                   	pop    %rbx
  801340:	5d                   	pop    %rbp
  801341:	c3                   	retq   

0000000000801342 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801342:	55                   	push   %rbp
  801343:	48 89 e5             	mov    %rsp,%rbp
  801346:	53                   	push   %rbx
  801347:	48 83 ec 08          	sub    $0x8,%rsp
  80134b:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  80134e:	be 00 00 00 00       	mov    $0x0,%esi
  801353:	b8 0c 00 00 00       	mov    $0xc,%eax
  801358:	48 89 f1             	mov    %rsi,%rcx
  80135b:	48 89 f3             	mov    %rsi,%rbx
  80135e:	48 89 f7             	mov    %rsi,%rdi
  801361:	cd 30                	int    $0x30
  if (check && ret > 0)
  801363:	48 85 c0             	test   %rax,%rax
  801366:	7f 07                	jg     80136f <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  801368:	48 83 c4 08          	add    $0x8,%rsp
  80136c:	5b                   	pop    %rbx
  80136d:	5d                   	pop    %rbp
  80136e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80136f:	49 89 c0             	mov    %rax,%r8
  801372:	b9 0c 00 00 00       	mov    $0xc,%ecx
  801377:	48 ba e0 1e 80 00 00 	movabs $0x801ee0,%rdx
  80137e:	00 00 00 
  801381:	be 22 00 00 00       	mov    $0x22,%esi
  801386:	48 bf ff 1e 80 00 00 	movabs $0x801eff,%rdi
  80138d:	00 00 00 
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
  801395:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  80139c:	00 00 00 
  80139f:	41 ff d1             	callq  *%r9

00000000008013a2 <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  8013a2:	55                   	push   %rbp
  8013a3:	48 89 e5             	mov    %rsp,%rbp
  8013a6:	53                   	push   %rbx
  8013a7:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  8013ab:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  8013ae:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  8013b2:	41 f6 c0 02          	test   $0x2,%r8b
  8013b6:	0f 84 b2 00 00 00    	je     80146e <pgfault+0xcc>
  8013bc:	48 89 da             	mov    %rbx,%rdx
  8013bf:	48 c1 ea 0c          	shr    $0xc,%rdx
  8013c3:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8013ca:	01 00 00 
  8013cd:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8013d1:	f6 c4 08             	test   $0x8,%ah
  8013d4:	0f 84 94 00 00 00    	je     80146e <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  8013da:	ba 02 00 00 00       	mov    $0x2,%edx
  8013df:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8013e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013e9:	48 b8 35 11 80 00 00 	movabs $0x801135,%rax
  8013f0:	00 00 00 
  8013f3:	ff d0                	callq  *%rax
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	0f 88 9f 00 00 00    	js     80149c <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8013fd:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  801404:	ba 00 10 00 00       	mov    $0x1000,%edx
  801409:	48 89 de             	mov    %rbx,%rsi
  80140c:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  801411:	48 b8 e1 0d 80 00 00 	movabs $0x800de1,%rax
  801418:	00 00 00 
  80141b:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  80141d:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  801423:	48 89 d9             	mov    %rbx,%rcx
  801426:	ba 00 00 00 00       	mov    $0x0,%edx
  80142b:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801430:	bf 00 00 00 00       	mov    $0x0,%edi
  801435:	48 b8 98 11 80 00 00 	movabs $0x801198,%rax
  80143c:	00 00 00 
  80143f:	ff d0                	callq  *%rax
  801441:	85 c0                	test   %eax,%eax
  801443:	0f 88 80 00 00 00    	js     8014c9 <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  801449:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  80144e:	bf 00 00 00 00       	mov    $0x0,%edi
  801453:	48 b8 ff 11 80 00 00 	movabs $0x8011ff,%rax
  80145a:	00 00 00 
  80145d:	ff d0                	callq  *%rax
  80145f:	85 c0                	test   %eax,%eax
  801461:	0f 88 8f 00 00 00    	js     8014f6 <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  801467:	48 83 c4 08          	add    $0x8,%rsp
  80146b:	5b                   	pop    %rbx
  80146c:	5d                   	pop    %rbp
  80146d:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  80146e:	48 89 d9             	mov    %rbx,%rcx
  801471:	48 ba 10 1f 80 00 00 	movabs $0x801f10,%rdx
  801478:	00 00 00 
  80147b:	be 21 00 00 00       	mov    $0x21,%esi
  801480:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  801487:	00 00 00 
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
  80148f:	49 b9 61 18 80 00 00 	movabs $0x801861,%r9
  801496:	00 00 00 
  801499:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  80149c:	89 c1                	mov    %eax,%ecx
  80149e:	48 ba 40 1f 80 00 00 	movabs $0x801f40,%rdx
  8014a5:	00 00 00 
  8014a8:	be 2f 00 00 00       	mov    $0x2f,%esi
  8014ad:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  8014b4:	00 00 00 
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bc:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  8014c3:	00 00 00 
  8014c6:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  8014c9:	89 c1                	mov    %eax,%ecx
  8014cb:	48 ba 68 1f 80 00 00 	movabs $0x801f68,%rdx
  8014d2:	00 00 00 
  8014d5:	be 39 00 00 00       	mov    $0x39,%esi
  8014da:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  8014e1:	00 00 00 
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e9:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  8014f0:	00 00 00 
  8014f3:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  8014f6:	89 c1                	mov    %eax,%ecx
  8014f8:	48 ba 90 1f 80 00 00 	movabs $0x801f90,%rdx
  8014ff:	00 00 00 
  801502:	be 3d 00 00 00       	mov    $0x3d,%esi
  801507:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  80150e:	00 00 00 
  801511:	b8 00 00 00 00       	mov    $0x0,%eax
  801516:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  80151d:	00 00 00 
  801520:	41 ff d0             	callq  *%r8

0000000000801523 <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  801523:	55                   	push   %rbp
  801524:	48 89 e5             	mov    %rsp,%rbp
  801527:	41 57                	push   %r15
  801529:	41 56                	push   %r14
  80152b:	41 55                	push   %r13
  80152d:	41 54                	push   %r12
  80152f:	53                   	push   %rbx
  801530:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  801534:	48 bf a2 13 80 00 00 	movabs $0x8013a2,%rdi
  80153b:	00 00 00 
  80153e:	48 b8 51 19 80 00 00 	movabs $0x801951,%rax
  801545:	00 00 00 
  801548:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  80154a:	b8 07 00 00 00       	mov    $0x7,%eax
  80154f:	cd 30                	int    $0x30
  801551:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  801554:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  801557:	85 c0                	test   %eax,%eax
  801559:	78 38                	js     801593 <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  80155b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801560:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  801564:	74 5a                	je     8015c0 <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801566:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  80156d:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801570:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  801577:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  80157a:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  801581:	01 00 00 
  801584:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  80158b:	01 00 00 
  80158e:	e9 2c 01 00 00       	jmpq   8016bf <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  801593:	89 c1                	mov    %eax,%ecx
  801595:	48 ba 37 20 80 00 00 	movabs $0x802037,%rdx
  80159c:	00 00 00 
  80159f:	be 82 00 00 00       	mov    $0x82,%esi
  8015a4:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  8015ab:	00 00 00 
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b3:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  8015ba:	00 00 00 
  8015bd:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  8015c0:	48 b8 f5 10 80 00 00 	movabs $0x8010f5,%rax
  8015c7:	00 00 00 
  8015ca:	ff d0                	callq  *%rax
  8015cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015d1:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8015d5:	48 c1 e0 05          	shl    $0x5,%rax
  8015d9:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8015e0:	00 00 00 
  8015e3:	48 01 d0             	add    %rdx,%rax
  8015e6:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  8015ed:	00 00 00 
		return 0;
  8015f0:	e9 9d 01 00 00       	jmpq   801792 <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  8015f5:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8015fc:	01 00 00 
  8015ff:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801603:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  801607:	48 b8 f5 10 80 00 00 	movabs $0x8010f5,%rax
  80160e:	00 00 00 
  801611:	ff d0                	callq  *%rax
  801613:	89 c7                	mov    %eax,%edi
  801615:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  801618:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80161c:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801622:	74 57                	je     80167b <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  801624:	81 e2 05 06 00 00    	and    $0x605,%edx
  80162a:	48 89 d0             	mov    %rdx,%rax
  80162d:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801630:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  801634:	48 c1 e6 0c          	shl    $0xc,%rsi
  801638:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80163c:	41 89 c0             	mov    %eax,%r8d
  80163f:	48 89 f1             	mov    %rsi,%rcx
  801642:	8b 55 c0             	mov    -0x40(%rbp),%edx
  801645:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  801649:	48 b8 98 11 80 00 00 	movabs $0x801198,%rax
  801650:	00 00 00 
  801653:	ff d0                	callq  *%rax
    if (r < 0) {
  801655:	85 c0                	test   %eax,%eax
  801657:	0f 88 ce 01 00 00    	js     80182b <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  80165d:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  801661:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  801665:	48 89 f1             	mov    %rsi,%rcx
  801668:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  80166b:	89 fa                	mov    %edi,%edx
  80166d:	48 b8 98 11 80 00 00 	movabs $0x801198,%rax
  801674:	00 00 00 
  801677:	ff d0                	callq  *%rax
  801679:	eb 28                	jmp    8016a3 <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  80167b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80167f:	48 c1 e6 0c          	shl    $0xc,%rsi
  801683:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  801687:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  80168e:	48 89 f1             	mov    %rsi,%rcx
  801691:	8b 55 c0             	mov    -0x40(%rbp),%edx
  801694:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  801697:	48 b8 98 11 80 00 00 	movabs $0x801198,%rax
  80169e:	00 00 00 
  8016a1:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	0f 89 80 00 00 00    	jns    80172b <fork+0x208>
  8016ab:	89 45 c0             	mov    %eax,-0x40(%rbp)
  8016ae:	e9 df 00 00 00       	jmpq   801792 <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8016b3:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8016ba:	4c 39 eb             	cmp    %r13,%rbx
  8016bd:	74 75                	je     801734 <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8016bf:	48 89 d8             	mov    %rbx,%rax
  8016c2:	48 c1 e8 27          	shr    $0x27,%rax
  8016c6:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  8016ca:	a8 01                	test   $0x1,%al
  8016cc:	74 e5                	je     8016b3 <fork+0x190>
  8016ce:	48 89 d8             	mov    %rbx,%rax
  8016d1:	48 c1 e8 1e          	shr    $0x1e,%rax
  8016d5:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  8016d9:	a8 01                	test   $0x1,%al
  8016db:	74 d6                	je     8016b3 <fork+0x190>
  8016dd:	48 89 d8             	mov    %rbx,%rax
  8016e0:	48 c1 e8 15          	shr    $0x15,%rax
  8016e4:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  8016e8:	a8 01                	test   $0x1,%al
  8016ea:	74 c7                	je     8016b3 <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  8016ec:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  8016f3:	00 00 00 
  8016f6:	48 39 c3             	cmp    %rax,%rbx
  8016f9:	77 b8                	ja     8016b3 <fork+0x190>
  8016fb:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  801702:	48 39 c3             	cmp    %rax,%rbx
  801705:	74 ac                	je     8016b3 <fork+0x190>
  801707:	48 89 d8             	mov    %rbx,%rax
  80170a:	48 c1 e8 0c          	shr    $0xc,%rax
  80170e:	48 89 c1             	mov    %rax,%rcx
  801711:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  801715:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80171c:	01 00 00 
  80171f:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801723:	a8 01                	test   $0x1,%al
  801725:	0f 85 ca fe ff ff    	jne    8015f5 <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  80172b:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801732:	eb 8b                	jmp    8016bf <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  801734:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  80173b:	00 00 00 
  80173e:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  801745:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  801748:	48 b8 bf 12 80 00 00 	movabs $0x8012bf,%rax
  80174f:	00 00 00 
  801752:	ff d0                	callq  *%rax
  801754:	85 c0                	test   %eax,%eax
  801756:	78 4c                	js     8017a4 <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  801758:	ba 02 00 00 00       	mov    $0x2,%edx
  80175d:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801764:	00 00 00 
  801767:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  80176a:	48 b8 35 11 80 00 00 	movabs $0x801135,%rax
  801771:	00 00 00 
  801774:	ff d0                	callq  *%rax
  801776:	85 c0                	test   %eax,%eax
  801778:	78 57                	js     8017d1 <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  80177a:	be 02 00 00 00       	mov    $0x2,%esi
  80177f:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  801782:	48 b8 5f 12 80 00 00 	movabs $0x80125f,%rax
  801789:	00 00 00 
  80178c:	ff d0                	callq  *%rax
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 6c                	js     8017fe <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  801792:	8b 45 c0             	mov    -0x40(%rbp),%eax
  801795:	48 83 c4 28          	add    $0x28,%rsp
  801799:	5b                   	pop    %rbx
  80179a:	41 5c                	pop    %r12
  80179c:	41 5d                	pop    %r13
  80179e:	41 5e                	pop    %r14
  8017a0:	41 5f                	pop    %r15
  8017a2:	5d                   	pop    %rbp
  8017a3:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  8017a4:	89 c1                	mov    %eax,%ecx
  8017a6:	48 ba b8 1f 80 00 00 	movabs $0x801fb8,%rdx
  8017ad:	00 00 00 
  8017b0:	be a7 00 00 00       	mov    $0xa7,%esi
  8017b5:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  8017bc:	00 00 00 
  8017bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c4:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  8017cb:	00 00 00 
  8017ce:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  8017d1:	89 c1                	mov    %eax,%ecx
  8017d3:	48 ba e8 1f 80 00 00 	movabs $0x801fe8,%rdx
  8017da:	00 00 00 
  8017dd:	be aa 00 00 00       	mov    $0xaa,%esi
  8017e2:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  8017e9:	00 00 00 
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f1:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  8017f8:	00 00 00 
  8017fb:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  8017fe:	89 c1                	mov    %eax,%ecx
  801800:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  801807:	00 00 00 
  80180a:	be bd 00 00 00       	mov    $0xbd,%esi
  80180f:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  801816:	00 00 00 
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
  80181e:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  801825:	00 00 00 
  801828:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  80182b:	89 45 c0             	mov    %eax,-0x40(%rbp)
  80182e:	e9 5f ff ff ff       	jmpq   801792 <fork+0x26f>

0000000000801833 <sfork>:

// Challenge!
int
sfork(void) {
  801833:	55                   	push   %rbp
  801834:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  801837:	48 ba 47 20 80 00 00 	movabs $0x802047,%rdx
  80183e:	00 00 00 
  801841:	be c9 00 00 00       	mov    $0xc9,%esi
  801846:	48 bf 2c 20 80 00 00 	movabs $0x80202c,%rdi
  80184d:	00 00 00 
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
  801855:	48 b9 61 18 80 00 00 	movabs $0x801861,%rcx
  80185c:	00 00 00 
  80185f:	ff d1                	callq  *%rcx

0000000000801861 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801861:	55                   	push   %rbp
  801862:	48 89 e5             	mov    %rsp,%rbp
  801865:	41 56                	push   %r14
  801867:	41 55                	push   %r13
  801869:	41 54                	push   %r12
  80186b:	53                   	push   %rbx
  80186c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801873:	49 89 fd             	mov    %rdi,%r13
  801876:	41 89 f6             	mov    %esi,%r14d
  801879:	49 89 d4             	mov    %rdx,%r12
  80187c:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801883:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80188a:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801891:	84 c0                	test   %al,%al
  801893:	74 26                	je     8018bb <_panic+0x5a>
  801895:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80189c:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8018a3:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8018a7:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8018ab:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8018af:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8018b3:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8018b7:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8018bb:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8018c2:	00 00 00 
  8018c5:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8018cc:	00 00 00 
  8018cf:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8018d3:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8018da:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8018e1:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8018e8:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  8018ef:	00 00 00 
  8018f2:	48 8b 18             	mov    (%rax),%rbx
  8018f5:	48 b8 f5 10 80 00 00 	movabs $0x8010f5,%rax
  8018fc:	00 00 00 
  8018ff:	ff d0                	callq  *%rax
  801901:	45 89 f0             	mov    %r14d,%r8d
  801904:	4c 89 e9             	mov    %r13,%rcx
  801907:	48 89 da             	mov    %rbx,%rdx
  80190a:	89 c6                	mov    %eax,%esi
  80190c:	48 bf 60 20 80 00 00 	movabs $0x802060,%rdi
  801913:	00 00 00 
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
  80191b:	48 bb 63 02 80 00 00 	movabs $0x800263,%rbx
  801922:	00 00 00 
  801925:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801927:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80192e:	4c 89 e7             	mov    %r12,%rdi
  801931:	48 b8 fb 01 80 00 00 	movabs $0x8001fb,%rax
  801938:	00 00 00 
  80193b:	ff d0                	callq  *%rax
  cprintf("\n");
  80193d:	48 bf d4 1a 80 00 00 	movabs $0x801ad4,%rdi
  801944:	00 00 00 
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80194e:	cc                   	int3   
  while (1)
  80194f:	eb fd                	jmp    80194e <_panic+0xed>

0000000000801951 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801951:	55                   	push   %rbp
  801952:	48 89 e5             	mov    %rsp,%rbp
  801955:	41 54                	push   %r12
  801957:	53                   	push   %rbx
  801958:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  80195b:	48 b8 f5 10 80 00 00 	movabs $0x8010f5,%rax
  801962:	00 00 00 
  801965:	ff d0                	callq  *%rax
  801967:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  801969:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  801970:	00 00 00 
  801973:	48 83 38 00          	cmpq   $0x0,(%rax)
  801977:	74 2e                	je     8019a7 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801979:	4c 89 e0             	mov    %r12,%rax
  80197c:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  801983:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801986:	48 be f3 19 80 00 00 	movabs $0x8019f3,%rsi
  80198d:	00 00 00 
  801990:	89 df                	mov    %ebx,%edi
  801992:	48 b8 bf 12 80 00 00 	movabs $0x8012bf,%rax
  801999:	00 00 00 
  80199c:	ff d0                	callq  *%rax
  if (error < 0)
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 24                	js     8019c6 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  8019a2:	5b                   	pop    %rbx
  8019a3:	41 5c                	pop    %r12
  8019a5:	5d                   	pop    %rbp
  8019a6:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  8019a7:	ba 02 00 00 00       	mov    $0x2,%edx
  8019ac:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8019b3:	00 00 00 
  8019b6:	89 df                	mov    %ebx,%edi
  8019b8:	48 b8 35 11 80 00 00 	movabs $0x801135,%rax
  8019bf:	00 00 00 
  8019c2:	ff d0                	callq  *%rax
  8019c4:	eb b3                	jmp    801979 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  8019c6:	89 c1                	mov    %eax,%ecx
  8019c8:	48 ba 88 20 80 00 00 	movabs $0x802088,%rdx
  8019cf:	00 00 00 
  8019d2:	be 2c 00 00 00       	mov    $0x2c,%esi
  8019d7:	48 bf a0 20 80 00 00 	movabs $0x8020a0,%rdi
  8019de:	00 00 00 
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e6:	49 b8 61 18 80 00 00 	movabs $0x801861,%r8
  8019ed:	00 00 00 
  8019f0:	41 ff d0             	callq  *%r8

00000000008019f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  8019f3:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  8019f6:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  8019fd:	00 00 00 
	call *%rax
  801a00:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801a02:	41 5f                	pop    %r15
	popq %r15
  801a04:	41 5f                	pop    %r15
	popq %r15
  801a06:	41 5f                	pop    %r15
	popq %r14
  801a08:	41 5e                	pop    %r14
	popq %r13
  801a0a:	41 5d                	pop    %r13
	popq %r12
  801a0c:	41 5c                	pop    %r12
	popq %r11
  801a0e:	41 5b                	pop    %r11
	popq %r10
  801a10:	41 5a                	pop    %r10
	popq %r9
  801a12:	41 59                	pop    %r9
	popq %r8
  801a14:	41 58                	pop    %r8
	popq %rsi
  801a16:	5e                   	pop    %rsi
	popq %rdi
  801a17:	5f                   	pop    %rdi
	popq %rbp
  801a18:	5d                   	pop    %rbp
	popq %rdx
  801a19:	5a                   	pop    %rdx
	popq %rcx
  801a1a:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801a1b:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801a20:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801a25:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801a29:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801a2c:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801a31:	5b                   	pop    %rbx
	popq %rax
  801a32:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801a33:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801a37:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801a38:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801a3d:	c3                   	retq   
  801a3e:	66 90                	xchg   %ax,%ax
