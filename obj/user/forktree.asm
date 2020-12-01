
obj/user/forktree:     file format elf64-x86-64


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
  800023:	e8 fe 00 00 00       	callq  800126 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <forktree>:
    exit();
  }
}

void
forktree(const char *cur) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 54                	push   %r12
  800030:	53                   	push   %rbx
  800031:	48 89 fb             	mov    %rdi,%rbx
  cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800034:	48 b8 37 11 80 00 00 	movabs $0x801137,%rax
  80003b:	00 00 00 
  80003e:	ff d0                	callq  *%rax
  800040:	48 89 da             	mov    %rbx,%rdx
  800043:	89 c6                	mov    %eax,%esi
  800045:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  80004c:	00 00 00 
  80004f:	b8 00 00 00 00       	mov    $0x0,%eax
  800054:	48 b9 a5 02 80 00 00 	movabs $0x8002a5,%rcx
  80005b:	00 00 00 
  80005e:	ff d1                	callq  *%rcx

  forkchild(cur, '0');
  800060:	be 30 00 00 00       	mov    $0x30,%esi
  800065:	48 89 df             	mov    %rbx,%rdi
  800068:	49 bc 85 00 80 00 00 	movabs $0x800085,%r12
  80006f:	00 00 00 
  800072:	41 ff d4             	callq  *%r12
  forkchild(cur, '1');
  800075:	be 31 00 00 00       	mov    $0x31,%esi
  80007a:	48 89 df             	mov    %rbx,%rdi
  80007d:	41 ff d4             	callq  *%r12
}
  800080:	5b                   	pop    %rbx
  800081:	41 5c                	pop    %r12
  800083:	5d                   	pop    %rbp
  800084:	c3                   	retq   

0000000000800085 <forkchild>:
forkchild(const char *cur, char branch) {
  800085:	55                   	push   %rbp
  800086:	48 89 e5             	mov    %rsp,%rbp
  800089:	41 54                	push   %r12
  80008b:	53                   	push   %rbx
  80008c:	48 83 ec 10          	sub    $0x10,%rsp
  800090:	48 89 fb             	mov    %rdi,%rbx
  800093:	41 89 f4             	mov    %esi,%r12d
  if (strlen(cur) >= DEPTH)
  800096:	48 b8 18 0c 80 00 00 	movabs $0x800c18,%rax
  80009d:	00 00 00 
  8000a0:	ff d0                	callq  *%rax
  8000a2:	83 f8 02             	cmp    $0x2,%eax
  8000a5:	7e 09                	jle    8000b0 <forkchild+0x2b>
}
  8000a7:	48 83 c4 10          	add    $0x10,%rsp
  8000ab:	5b                   	pop    %rbx
  8000ac:	41 5c                	pop    %r12
  8000ae:	5d                   	pop    %rbp
  8000af:	c3                   	retq   
  snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8000b0:	45 0f be c4          	movsbl %r12b,%r8d
  8000b4:	48 89 d9             	mov    %rbx,%rcx
  8000b7:	48 ba 91 1a 80 00 00 	movabs $0x801a91,%rdx
  8000be:	00 00 00 
  8000c1:	be 04 00 00 00       	mov    $0x4,%esi
  8000c6:	48 8d 7d ec          	lea    -0x14(%rbp),%rdi
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	49 b9 92 0b 80 00 00 	movabs $0x800b92,%r9
  8000d6:	00 00 00 
  8000d9:	41 ff d1             	callq  *%r9
  if (fork() == 0) {
  8000dc:	48 b8 65 15 80 00 00 	movabs $0x801565,%rax
  8000e3:	00 00 00 
  8000e6:	ff d0                	callq  *%rax
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	75 bb                	jne    8000a7 <forkchild+0x22>
    forktree(nxt);
  8000ec:	48 8d 7d ec          	lea    -0x14(%rbp),%rdi
  8000f0:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f7:	00 00 00 
  8000fa:	ff d0                	callq  *%rax
    exit();
  8000fc:	48 b8 dc 01 80 00 00 	movabs $0x8001dc,%rax
  800103:	00 00 00 
  800106:	ff d0                	callq  *%rax
  800108:	eb 9d                	jmp    8000a7 <forkchild+0x22>

000000000080010a <umain>:

void
umain(int argc, char **argv) {
  80010a:	55                   	push   %rbp
  80010b:	48 89 e5             	mov    %rsp,%rbp
  forktree("");
  80010e:	48 bf 90 1a 80 00 00 	movabs $0x801a90,%rdi
  800115:	00 00 00 
  800118:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  80011f:	00 00 00 
  800122:	ff d0                	callq  *%rax
}
  800124:	5d                   	pop    %rbp
  800125:	c3                   	retq   

0000000000800126 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800126:	55                   	push   %rbp
  800127:	48 89 e5             	mov    %rsp,%rbp
  80012a:	41 56                	push   %r14
  80012c:	41 55                	push   %r13
  80012e:	41 54                	push   %r12
  800130:	53                   	push   %rbx
  800131:	41 89 fd             	mov    %edi,%r13d
  800134:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800137:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  80013e:	00 00 00 
  800141:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  800148:	00 00 00 
  80014b:	48 39 c2             	cmp    %rax,%rdx
  80014e:	73 23                	jae    800173 <libmain+0x4d>
  800150:	48 89 d3             	mov    %rdx,%rbx
  800153:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800157:	48 29 d0             	sub    %rdx,%rax
  80015a:	48 c1 e8 03          	shr    $0x3,%rax
  80015e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800163:	b8 00 00 00 00       	mov    $0x0,%eax
  800168:	ff 13                	callq  *(%rbx)
    ctor++;
  80016a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80016e:	4c 39 e3             	cmp    %r12,%rbx
  800171:	75 f0                	jne    800163 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800173:	48 b8 37 11 80 00 00 	movabs $0x801137,%rax
  80017a:	00 00 00 
  80017d:	ff d0                	callq  *%rax
  80017f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800184:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800188:	48 c1 e0 05          	shl    $0x5,%rax
  80018c:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800193:	00 00 00 
  800196:	48 01 d0             	add    %rdx,%rax
  800199:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  8001a0:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8001a3:	45 85 ed             	test   %r13d,%r13d
  8001a6:	7e 0d                	jle    8001b5 <libmain+0x8f>
    binaryname = argv[0];
  8001a8:	49 8b 06             	mov    (%r14),%rax
  8001ab:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  8001b2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8001b5:	4c 89 f6             	mov    %r14,%rsi
  8001b8:	44 89 ef             	mov    %r13d,%edi
  8001bb:	48 b8 0a 01 80 00 00 	movabs $0x80010a,%rax
  8001c2:	00 00 00 
  8001c5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8001c7:	48 b8 dc 01 80 00 00 	movabs $0x8001dc,%rax
  8001ce:	00 00 00 
  8001d1:	ff d0                	callq  *%rax
#endif
}
  8001d3:	5b                   	pop    %rbx
  8001d4:	41 5c                	pop    %r12
  8001d6:	41 5d                	pop    %r13
  8001d8:	41 5e                	pop    %r14
  8001da:	5d                   	pop    %rbp
  8001db:	c3                   	retq   

00000000008001dc <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001dc:	55                   	push   %rbp
  8001dd:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8001e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8001e5:	48 b8 d7 10 80 00 00 	movabs $0x8010d7,%rax
  8001ec:	00 00 00 
  8001ef:	ff d0                	callq  *%rax
}
  8001f1:	5d                   	pop    %rbp
  8001f2:	c3                   	retq   

00000000008001f3 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8001f3:	55                   	push   %rbp
  8001f4:	48 89 e5             	mov    %rsp,%rbp
  8001f7:	53                   	push   %rbx
  8001f8:	48 83 ec 08          	sub    $0x8,%rsp
  8001fc:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8001ff:	8b 06                	mov    (%rsi),%eax
  800201:	8d 50 01             	lea    0x1(%rax),%edx
  800204:	89 16                	mov    %edx,(%rsi)
  800206:	48 98                	cltq   
  800208:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80020d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800213:	74 0b                	je     800220 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800215:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800219:	48 83 c4 08          	add    $0x8,%rsp
  80021d:	5b                   	pop    %rbx
  80021e:	5d                   	pop    %rbp
  80021f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800220:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800224:	be ff 00 00 00       	mov    $0xff,%esi
  800229:	48 b8 99 10 80 00 00 	movabs $0x801099,%rax
  800230:	00 00 00 
  800233:	ff d0                	callq  *%rax
    b->idx = 0;
  800235:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80023b:	eb d8                	jmp    800215 <putch+0x22>

000000000080023d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80023d:	55                   	push   %rbp
  80023e:	48 89 e5             	mov    %rsp,%rbp
  800241:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800248:	48 89 fa             	mov    %rdi,%rdx
  80024b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80024e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800255:	00 00 00 
  b.cnt = 0;
  800258:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80025f:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800262:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800269:	48 bf f3 01 80 00 00 	movabs $0x8001f3,%rdi
  800270:	00 00 00 
  800273:	48 b8 63 04 80 00 00 	movabs $0x800463,%rax
  80027a:	00 00 00 
  80027d:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80027f:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800286:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80028d:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800291:	48 b8 99 10 80 00 00 	movabs $0x801099,%rax
  800298:	00 00 00 
  80029b:	ff d0                	callq  *%rax

  return b.cnt;
}
  80029d:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8002a3:	c9                   	leaveq 
  8002a4:	c3                   	retq   

00000000008002a5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8002a5:	55                   	push   %rbp
  8002a6:	48 89 e5             	mov    %rsp,%rbp
  8002a9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002b0:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8002b7:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8002be:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002c5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8002cc:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8002d3:	84 c0                	test   %al,%al
  8002d5:	74 20                	je     8002f7 <cprintf+0x52>
  8002d7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8002db:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8002df:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8002e3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8002e7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8002eb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8002ef:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8002f3:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8002f7:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8002fe:	00 00 00 
  800301:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800308:	00 00 00 
  80030b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80030f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800316:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80031d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800324:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80032b:	48 b8 3d 02 80 00 00 	movabs $0x80023d,%rax
  800332:	00 00 00 
  800335:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800337:	c9                   	leaveq 
  800338:	c3                   	retq   

0000000000800339 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800339:	55                   	push   %rbp
  80033a:	48 89 e5             	mov    %rsp,%rbp
  80033d:	41 57                	push   %r15
  80033f:	41 56                	push   %r14
  800341:	41 55                	push   %r13
  800343:	41 54                	push   %r12
  800345:	53                   	push   %rbx
  800346:	48 83 ec 18          	sub    $0x18,%rsp
  80034a:	49 89 fc             	mov    %rdi,%r12
  80034d:	49 89 f5             	mov    %rsi,%r13
  800350:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800354:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800357:	41 89 cf             	mov    %ecx,%r15d
  80035a:	49 39 d7             	cmp    %rdx,%r15
  80035d:	76 45                	jbe    8003a4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80035f:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800363:	85 db                	test   %ebx,%ebx
  800365:	7e 0e                	jle    800375 <printnum+0x3c>
      putch(padc, putdat);
  800367:	4c 89 ee             	mov    %r13,%rsi
  80036a:	44 89 f7             	mov    %r14d,%edi
  80036d:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800370:	83 eb 01             	sub    $0x1,%ebx
  800373:	75 f2                	jne    800367 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800375:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	49 f7 f7             	div    %r15
  800381:	48 b8 a0 1a 80 00 00 	movabs $0x801aa0,%rax
  800388:	00 00 00 
  80038b:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80038f:	4c 89 ee             	mov    %r13,%rsi
  800392:	41 ff d4             	callq  *%r12
}
  800395:	48 83 c4 18          	add    $0x18,%rsp
  800399:	5b                   	pop    %rbx
  80039a:	41 5c                	pop    %r12
  80039c:	41 5d                	pop    %r13
  80039e:	41 5e                	pop    %r14
  8003a0:	41 5f                	pop    %r15
  8003a2:	5d                   	pop    %rbp
  8003a3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	49 f7 f7             	div    %r15
  8003b0:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8003b4:	48 89 c2             	mov    %rax,%rdx
  8003b7:	48 b8 39 03 80 00 00 	movabs $0x800339,%rax
  8003be:	00 00 00 
  8003c1:	ff d0                	callq  *%rax
  8003c3:	eb b0                	jmp    800375 <printnum+0x3c>

00000000008003c5 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8003c5:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8003c9:	48 8b 06             	mov    (%rsi),%rax
  8003cc:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8003d0:	73 0a                	jae    8003dc <sprintputch+0x17>
    *b->buf++ = ch;
  8003d2:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8003d6:	48 89 16             	mov    %rdx,(%rsi)
  8003d9:	40 88 38             	mov    %dil,(%rax)
}
  8003dc:	c3                   	retq   

00000000008003dd <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8003dd:	55                   	push   %rbp
  8003de:	48 89 e5             	mov    %rsp,%rbp
  8003e1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003e8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003ef:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003f6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003fd:	84 c0                	test   %al,%al
  8003ff:	74 20                	je     800421 <printfmt+0x44>
  800401:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800405:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800409:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80040d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800411:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800415:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800419:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80041d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800421:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800428:	00 00 00 
  80042b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800432:	00 00 00 
  800435:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800439:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800440:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800447:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80044e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800455:	48 b8 63 04 80 00 00 	movabs $0x800463,%rax
  80045c:	00 00 00 
  80045f:	ff d0                	callq  *%rax
}
  800461:	c9                   	leaveq 
  800462:	c3                   	retq   

0000000000800463 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800463:	55                   	push   %rbp
  800464:	48 89 e5             	mov    %rsp,%rbp
  800467:	41 57                	push   %r15
  800469:	41 56                	push   %r14
  80046b:	41 55                	push   %r13
  80046d:	41 54                	push   %r12
  80046f:	53                   	push   %rbx
  800470:	48 83 ec 48          	sub    $0x48,%rsp
  800474:	49 89 fd             	mov    %rdi,%r13
  800477:	49 89 f7             	mov    %rsi,%r15
  80047a:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80047d:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800481:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800485:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800489:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80048d:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800491:	41 0f b6 3e          	movzbl (%r14),%edi
  800495:	83 ff 25             	cmp    $0x25,%edi
  800498:	74 18                	je     8004b2 <vprintfmt+0x4f>
      if (ch == '\0')
  80049a:	85 ff                	test   %edi,%edi
  80049c:	0f 84 8c 06 00 00    	je     800b2e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8004a2:	4c 89 fe             	mov    %r15,%rsi
  8004a5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8004a8:	49 89 de             	mov    %rbx,%r14
  8004ab:	eb e0                	jmp    80048d <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8004ad:	49 89 de             	mov    %rbx,%r14
  8004b0:	eb db                	jmp    80048d <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8004b2:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8004b6:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8004ba:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8004c1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8004c7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8004cb:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8004d0:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8004d6:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8004dc:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8004e1:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8004e6:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8004ea:	0f b6 13             	movzbl (%rbx),%edx
  8004ed:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8004f0:	3c 55                	cmp    $0x55,%al
  8004f2:	0f 87 8b 05 00 00    	ja     800a83 <vprintfmt+0x620>
  8004f8:	0f b6 c0             	movzbl %al,%eax
  8004fb:	49 bb 80 1b 80 00 00 	movabs $0x801b80,%r11
  800502:	00 00 00 
  800505:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800509:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80050c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800510:	eb d4                	jmp    8004e6 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800512:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800515:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800519:	eb cb                	jmp    8004e6 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80051b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80051e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800522:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800526:	8d 50 d0             	lea    -0x30(%rax),%edx
  800529:	83 fa 09             	cmp    $0x9,%edx
  80052c:	77 7e                	ja     8005ac <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80052e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800532:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800536:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80053b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80053f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800542:	83 fa 09             	cmp    $0x9,%edx
  800545:	76 e7                	jbe    80052e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800547:	4c 89 f3             	mov    %r14,%rbx
  80054a:	eb 19                	jmp    800565 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80054c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80054f:	83 f8 2f             	cmp    $0x2f,%eax
  800552:	77 2a                	ja     80057e <vprintfmt+0x11b>
  800554:	89 c2                	mov    %eax,%edx
  800556:	4c 01 d2             	add    %r10,%rdx
  800559:	83 c0 08             	add    $0x8,%eax
  80055c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80055f:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800562:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800565:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800569:	0f 89 77 ff ff ff    	jns    8004e6 <vprintfmt+0x83>
          width = precision, precision = -1;
  80056f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800573:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800579:	e9 68 ff ff ff       	jmpq   8004e6 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80057e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800582:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800586:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80058a:	eb d3                	jmp    80055f <vprintfmt+0xfc>
        if (width < 0)
  80058c:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	41 0f 48 c0          	cmovs  %r8d,%eax
  800595:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800598:	4c 89 f3             	mov    %r14,%rbx
  80059b:	e9 46 ff ff ff       	jmpq   8004e6 <vprintfmt+0x83>
  8005a0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8005a3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8005a7:	e9 3a ff ff ff       	jmpq   8004e6 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005ac:	4c 89 f3             	mov    %r14,%rbx
  8005af:	eb b4                	jmp    800565 <vprintfmt+0x102>
        lflag++;
  8005b1:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8005b4:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8005b7:	e9 2a ff ff ff       	jmpq   8004e6 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8005bc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005bf:	83 f8 2f             	cmp    $0x2f,%eax
  8005c2:	77 19                	ja     8005dd <vprintfmt+0x17a>
  8005c4:	89 c2                	mov    %eax,%edx
  8005c6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005ca:	83 c0 08             	add    $0x8,%eax
  8005cd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d0:	4c 89 fe             	mov    %r15,%rsi
  8005d3:	8b 3a                	mov    (%rdx),%edi
  8005d5:	41 ff d5             	callq  *%r13
        break;
  8005d8:	e9 b0 fe ff ff       	jmpq   80048d <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8005dd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005e1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005e5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005e9:	eb e5                	jmp    8005d0 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8005eb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005ee:	83 f8 2f             	cmp    $0x2f,%eax
  8005f1:	77 5b                	ja     80064e <vprintfmt+0x1eb>
  8005f3:	89 c2                	mov    %eax,%edx
  8005f5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005f9:	83 c0 08             	add    $0x8,%eax
  8005fc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005ff:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800601:	89 c8                	mov    %ecx,%eax
  800603:	c1 f8 1f             	sar    $0x1f,%eax
  800606:	31 c1                	xor    %eax,%ecx
  800608:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060a:	83 f9 0b             	cmp    $0xb,%ecx
  80060d:	7f 4d                	jg     80065c <vprintfmt+0x1f9>
  80060f:	48 63 c1             	movslq %ecx,%rax
  800612:	48 ba 40 1e 80 00 00 	movabs $0x801e40,%rdx
  800619:	00 00 00 
  80061c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800620:	48 85 c0             	test   %rax,%rax
  800623:	74 37                	je     80065c <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800625:	48 89 c1             	mov    %rax,%rcx
  800628:	48 ba c1 1a 80 00 00 	movabs $0x801ac1,%rdx
  80062f:	00 00 00 
  800632:	4c 89 fe             	mov    %r15,%rsi
  800635:	4c 89 ef             	mov    %r13,%rdi
  800638:	b8 00 00 00 00       	mov    $0x0,%eax
  80063d:	48 bb dd 03 80 00 00 	movabs $0x8003dd,%rbx
  800644:	00 00 00 
  800647:	ff d3                	callq  *%rbx
  800649:	e9 3f fe ff ff       	jmpq   80048d <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80064e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800652:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800656:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80065a:	eb a3                	jmp    8005ff <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80065c:	48 ba b8 1a 80 00 00 	movabs $0x801ab8,%rdx
  800663:	00 00 00 
  800666:	4c 89 fe             	mov    %r15,%rsi
  800669:	4c 89 ef             	mov    %r13,%rdi
  80066c:	b8 00 00 00 00       	mov    $0x0,%eax
  800671:	48 bb dd 03 80 00 00 	movabs $0x8003dd,%rbx
  800678:	00 00 00 
  80067b:	ff d3                	callq  *%rbx
  80067d:	e9 0b fe ff ff       	jmpq   80048d <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800682:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800685:	83 f8 2f             	cmp    $0x2f,%eax
  800688:	77 4b                	ja     8006d5 <vprintfmt+0x272>
  80068a:	89 c2                	mov    %eax,%edx
  80068c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800690:	83 c0 08             	add    $0x8,%eax
  800693:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800696:	48 8b 02             	mov    (%rdx),%rax
  800699:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80069d:	48 85 c0             	test   %rax,%rax
  8006a0:	0f 84 05 04 00 00    	je     800aab <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8006a6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006aa:	7e 06                	jle    8006b2 <vprintfmt+0x24f>
  8006ac:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8006b0:	75 31                	jne    8006e3 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8006b6:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8006ba:	0f b6 00             	movzbl (%rax),%eax
  8006bd:	0f be f8             	movsbl %al,%edi
  8006c0:	85 ff                	test   %edi,%edi
  8006c2:	0f 84 c3 00 00 00    	je     80078b <vprintfmt+0x328>
  8006c8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8006cc:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8006d0:	e9 85 00 00 00       	jmpq   80075a <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8006d5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006d9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006dd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e1:	eb b3                	jmp    800696 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	49 63 f4             	movslq %r12d,%rsi
  8006e6:	48 89 c7             	mov    %rax,%rdi
  8006e9:	48 b8 3a 0c 80 00 00 	movabs $0x800c3a,%rax
  8006f0:	00 00 00 
  8006f3:	ff d0                	callq  *%rax
  8006f5:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8006f8:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8006fb:	85 f6                	test   %esi,%esi
  8006fd:	7e 22                	jle    800721 <vprintfmt+0x2be>
            putch(padc, putdat);
  8006ff:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800703:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800707:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80070b:	4c 89 fe             	mov    %r15,%rsi
  80070e:	89 df                	mov    %ebx,%edi
  800710:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800713:	41 83 ec 01          	sub    $0x1,%r12d
  800717:	75 f2                	jne    80070b <vprintfmt+0x2a8>
  800719:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80071d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800721:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800725:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800729:	0f b6 00             	movzbl (%rax),%eax
  80072c:	0f be f8             	movsbl %al,%edi
  80072f:	85 ff                	test   %edi,%edi
  800731:	0f 84 56 fd ff ff    	je     80048d <vprintfmt+0x2a>
  800737:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80073b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80073f:	eb 19                	jmp    80075a <vprintfmt+0x2f7>
            putch(ch, putdat);
  800741:	4c 89 fe             	mov    %r15,%rsi
  800744:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800747:	41 83 ee 01          	sub    $0x1,%r14d
  80074b:	48 83 c3 01          	add    $0x1,%rbx
  80074f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800753:	0f be f8             	movsbl %al,%edi
  800756:	85 ff                	test   %edi,%edi
  800758:	74 29                	je     800783 <vprintfmt+0x320>
  80075a:	45 85 e4             	test   %r12d,%r12d
  80075d:	78 06                	js     800765 <vprintfmt+0x302>
  80075f:	41 83 ec 01          	sub    $0x1,%r12d
  800763:	78 48                	js     8007ad <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800765:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800769:	74 d6                	je     800741 <vprintfmt+0x2de>
  80076b:	0f be c0             	movsbl %al,%eax
  80076e:	83 e8 20             	sub    $0x20,%eax
  800771:	83 f8 5e             	cmp    $0x5e,%eax
  800774:	76 cb                	jbe    800741 <vprintfmt+0x2de>
            putch('?', putdat);
  800776:	4c 89 fe             	mov    %r15,%rsi
  800779:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80077e:	41 ff d5             	callq  *%r13
  800781:	eb c4                	jmp    800747 <vprintfmt+0x2e4>
  800783:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800787:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80078b:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80078e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800792:	0f 8e f5 fc ff ff    	jle    80048d <vprintfmt+0x2a>
          putch(' ', putdat);
  800798:	4c 89 fe             	mov    %r15,%rsi
  80079b:	bf 20 00 00 00       	mov    $0x20,%edi
  8007a0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8007a3:	83 eb 01             	sub    $0x1,%ebx
  8007a6:	75 f0                	jne    800798 <vprintfmt+0x335>
  8007a8:	e9 e0 fc ff ff       	jmpq   80048d <vprintfmt+0x2a>
  8007ad:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8007b1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8007b5:	eb d4                	jmp    80078b <vprintfmt+0x328>
  if (lflag >= 2)
  8007b7:	83 f9 01             	cmp    $0x1,%ecx
  8007ba:	7f 1d                	jg     8007d9 <vprintfmt+0x376>
  else if (lflag)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	74 5e                	je     80081e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8007c0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c3:	83 f8 2f             	cmp    $0x2f,%eax
  8007c6:	77 48                	ja     800810 <vprintfmt+0x3ad>
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ce:	83 c0 08             	add    $0x8,%eax
  8007d1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d4:	48 8b 1a             	mov    (%rdx),%rbx
  8007d7:	eb 17                	jmp    8007f0 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8007d9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007dc:	83 f8 2f             	cmp    $0x2f,%eax
  8007df:	77 21                	ja     800802 <vprintfmt+0x39f>
  8007e1:	89 c2                	mov    %eax,%edx
  8007e3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007e7:	83 c0 08             	add    $0x8,%eax
  8007ea:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ed:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8007f0:	48 85 db             	test   %rbx,%rbx
  8007f3:	78 50                	js     800845 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8007f5:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8007f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007fd:	e9 b4 01 00 00       	jmpq   8009b6 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800802:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800806:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80080a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80080e:	eb dd                	jmp    8007ed <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800810:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800814:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800818:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80081c:	eb b6                	jmp    8007d4 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80081e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800821:	83 f8 2f             	cmp    $0x2f,%eax
  800824:	77 11                	ja     800837 <vprintfmt+0x3d4>
  800826:	89 c2                	mov    %eax,%edx
  800828:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80082c:	83 c0 08             	add    $0x8,%eax
  80082f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800832:	48 63 1a             	movslq (%rdx),%rbx
  800835:	eb b9                	jmp    8007f0 <vprintfmt+0x38d>
  800837:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80083b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80083f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800843:	eb ed                	jmp    800832 <vprintfmt+0x3cf>
          putch('-', putdat);
  800845:	4c 89 fe             	mov    %r15,%rsi
  800848:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80084d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800850:	48 89 da             	mov    %rbx,%rdx
  800853:	48 f7 da             	neg    %rdx
        base = 10;
  800856:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80085b:	e9 56 01 00 00       	jmpq   8009b6 <vprintfmt+0x553>
  if (lflag >= 2)
  800860:	83 f9 01             	cmp    $0x1,%ecx
  800863:	7f 25                	jg     80088a <vprintfmt+0x427>
  else if (lflag)
  800865:	85 c9                	test   %ecx,%ecx
  800867:	74 5e                	je     8008c7 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800869:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80086c:	83 f8 2f             	cmp    $0x2f,%eax
  80086f:	77 48                	ja     8008b9 <vprintfmt+0x456>
  800871:	89 c2                	mov    %eax,%edx
  800873:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800877:	83 c0 08             	add    $0x8,%eax
  80087a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80087d:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800880:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800885:	e9 2c 01 00 00       	jmpq   8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80088a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80088d:	83 f8 2f             	cmp    $0x2f,%eax
  800890:	77 19                	ja     8008ab <vprintfmt+0x448>
  800892:	89 c2                	mov    %eax,%edx
  800894:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800898:	83 c0 08             	add    $0x8,%eax
  80089b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80089e:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8008a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008a6:	e9 0b 01 00 00       	jmpq   8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008ab:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008af:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b7:	eb e5                	jmp    80089e <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8008b9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008bd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c5:	eb b6                	jmp    80087d <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8008c7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ca:	83 f8 2f             	cmp    $0x2f,%eax
  8008cd:	77 18                	ja     8008e7 <vprintfmt+0x484>
  8008cf:	89 c2                	mov    %eax,%edx
  8008d1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d5:	83 c0 08             	add    $0x8,%eax
  8008d8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008db:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8008dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008e2:	e9 cf 00 00 00       	jmpq   8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008e7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008eb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ef:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008f3:	eb e6                	jmp    8008db <vprintfmt+0x478>
  if (lflag >= 2)
  8008f5:	83 f9 01             	cmp    $0x1,%ecx
  8008f8:	7f 25                	jg     80091f <vprintfmt+0x4bc>
  else if (lflag)
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 5b                	je     800959 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8008fe:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800901:	83 f8 2f             	cmp    $0x2f,%eax
  800904:	77 45                	ja     80094b <vprintfmt+0x4e8>
  800906:	89 c2                	mov    %eax,%edx
  800908:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80090c:	83 c0 08             	add    $0x8,%eax
  80090f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800912:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800915:	b9 08 00 00 00       	mov    $0x8,%ecx
  80091a:	e9 97 00 00 00       	jmpq   8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80091f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800922:	83 f8 2f             	cmp    $0x2f,%eax
  800925:	77 16                	ja     80093d <vprintfmt+0x4da>
  800927:	89 c2                	mov    %eax,%edx
  800929:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092d:	83 c0 08             	add    $0x8,%eax
  800930:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800933:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800936:	b9 08 00 00 00       	mov    $0x8,%ecx
  80093b:	eb 79                	jmp    8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80093d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800941:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800945:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800949:	eb e8                	jmp    800933 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80094b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800953:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800957:	eb b9                	jmp    800912 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800959:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095c:	83 f8 2f             	cmp    $0x2f,%eax
  80095f:	77 15                	ja     800976 <vprintfmt+0x513>
  800961:	89 c2                	mov    %eax,%edx
  800963:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800967:	83 c0 08             	add    $0x8,%eax
  80096a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80096d:	8b 12                	mov    (%rdx),%edx
        base = 8;
  80096f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800974:	eb 40                	jmp    8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800976:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800982:	eb e9                	jmp    80096d <vprintfmt+0x50a>
        putch('0', putdat);
  800984:	4c 89 fe             	mov    %r15,%rsi
  800987:	bf 30 00 00 00       	mov    $0x30,%edi
  80098c:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  80098f:	4c 89 fe             	mov    %r15,%rsi
  800992:	bf 78 00 00 00       	mov    $0x78,%edi
  800997:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80099a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099d:	83 f8 2f             	cmp    $0x2f,%eax
  8009a0:	77 34                	ja     8009d6 <vprintfmt+0x573>
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a8:	83 c0 08             	add    $0x8,%eax
  8009ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ae:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009b1:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8009b6:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8009bb:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8009bf:	4c 89 fe             	mov    %r15,%rsi
  8009c2:	4c 89 ef             	mov    %r13,%rdi
  8009c5:	48 b8 39 03 80 00 00 	movabs $0x800339,%rax
  8009cc:	00 00 00 
  8009cf:	ff d0                	callq  *%rax
        break;
  8009d1:	e9 b7 fa ff ff       	jmpq   80048d <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8009d6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009da:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009de:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e2:	eb ca                	jmp    8009ae <vprintfmt+0x54b>
  if (lflag >= 2)
  8009e4:	83 f9 01             	cmp    $0x1,%ecx
  8009e7:	7f 22                	jg     800a0b <vprintfmt+0x5a8>
  else if (lflag)
  8009e9:	85 c9                	test   %ecx,%ecx
  8009eb:	74 58                	je     800a45 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8009ed:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f0:	83 f8 2f             	cmp    $0x2f,%eax
  8009f3:	77 42                	ja     800a37 <vprintfmt+0x5d4>
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009fb:	83 c0 08             	add    $0x8,%eax
  8009fe:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a01:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a04:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a09:	eb ab                	jmp    8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a0b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a0e:	83 f8 2f             	cmp    $0x2f,%eax
  800a11:	77 16                	ja     800a29 <vprintfmt+0x5c6>
  800a13:	89 c2                	mov    %eax,%edx
  800a15:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a19:	83 c0 08             	add    $0x8,%eax
  800a1c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a1f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a22:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a27:	eb 8d                	jmp    8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a29:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a2d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a31:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a35:	eb e8                	jmp    800a1f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800a37:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a3b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a3f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a43:	eb bc                	jmp    800a01 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800a45:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a48:	83 f8 2f             	cmp    $0x2f,%eax
  800a4b:	77 18                	ja     800a65 <vprintfmt+0x602>
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a53:	83 c0 08             	add    $0x8,%eax
  800a56:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a59:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800a5b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a60:	e9 51 ff ff ff       	jmpq   8009b6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a65:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a69:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a6d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a71:	eb e6                	jmp    800a59 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800a73:	4c 89 fe             	mov    %r15,%rsi
  800a76:	bf 25 00 00 00       	mov    $0x25,%edi
  800a7b:	41 ff d5             	callq  *%r13
        break;
  800a7e:	e9 0a fa ff ff       	jmpq   80048d <vprintfmt+0x2a>
        putch('%', putdat);
  800a83:	4c 89 fe             	mov    %r15,%rsi
  800a86:	bf 25 00 00 00       	mov    $0x25,%edi
  800a8b:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800a8e:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800a92:	0f 84 15 fa ff ff    	je     8004ad <vprintfmt+0x4a>
  800a98:	49 89 de             	mov    %rbx,%r14
  800a9b:	49 83 ee 01          	sub    $0x1,%r14
  800a9f:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800aa4:	75 f5                	jne    800a9b <vprintfmt+0x638>
  800aa6:	e9 e2 f9 ff ff       	jmpq   80048d <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800aab:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800aaf:	74 06                	je     800ab7 <vprintfmt+0x654>
  800ab1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800ab5:	7f 21                	jg     800ad8 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab7:	bf 28 00 00 00       	mov    $0x28,%edi
  800abc:	48 bb b2 1a 80 00 00 	movabs $0x801ab2,%rbx
  800ac3:	00 00 00 
  800ac6:	b8 28 00 00 00       	mov    $0x28,%eax
  800acb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800acf:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800ad3:	e9 82 fc ff ff       	jmpq   80075a <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800ad8:	49 63 f4             	movslq %r12d,%rsi
  800adb:	48 bf b1 1a 80 00 00 	movabs $0x801ab1,%rdi
  800ae2:	00 00 00 
  800ae5:	48 b8 3a 0c 80 00 00 	movabs $0x800c3a,%rax
  800aec:	00 00 00 
  800aef:	ff d0                	callq  *%rax
  800af1:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800af4:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800af7:	48 be b1 1a 80 00 00 	movabs $0x801ab1,%rsi
  800afe:	00 00 00 
  800b01:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b05:	85 c0                	test   %eax,%eax
  800b07:	0f 8f f2 fb ff ff    	jg     8006ff <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b0d:	48 bb b2 1a 80 00 00 	movabs $0x801ab2,%rbx
  800b14:	00 00 00 
  800b17:	b8 28 00 00 00       	mov    $0x28,%eax
  800b1c:	bf 28 00 00 00       	mov    $0x28,%edi
  800b21:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b25:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b29:	e9 2c fc ff ff       	jmpq   80075a <vprintfmt+0x2f7>
}
  800b2e:	48 83 c4 48          	add    $0x48,%rsp
  800b32:	5b                   	pop    %rbx
  800b33:	41 5c                	pop    %r12
  800b35:	41 5d                	pop    %r13
  800b37:	41 5e                	pop    %r14
  800b39:	41 5f                	pop    %r15
  800b3b:	5d                   	pop    %rbp
  800b3c:	c3                   	retq   

0000000000800b3d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800b3d:	55                   	push   %rbp
  800b3e:	48 89 e5             	mov    %rsp,%rbp
  800b41:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800b45:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800b49:	48 63 c6             	movslq %esi,%rax
  800b4c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800b51:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800b55:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800b5c:	48 85 ff             	test   %rdi,%rdi
  800b5f:	74 2a                	je     800b8b <vsnprintf+0x4e>
  800b61:	85 f6                	test   %esi,%esi
  800b63:	7e 26                	jle    800b8b <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800b65:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800b69:	48 bf c5 03 80 00 00 	movabs $0x8003c5,%rdi
  800b70:	00 00 00 
  800b73:	48 b8 63 04 80 00 00 	movabs $0x800463,%rax
  800b7a:	00 00 00 
  800b7d:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800b7f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800b83:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800b86:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800b89:	c9                   	leaveq 
  800b8a:	c3                   	retq   
    return -E_INVAL;
  800b8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b90:	eb f7                	jmp    800b89 <vsnprintf+0x4c>

0000000000800b92 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800b92:	55                   	push   %rbp
  800b93:	48 89 e5             	mov    %rsp,%rbp
  800b96:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800b9d:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ba4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800bab:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800bb2:	84 c0                	test   %al,%al
  800bb4:	74 20                	je     800bd6 <snprintf+0x44>
  800bb6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800bba:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800bbe:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800bc2:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800bc6:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800bca:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800bce:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800bd2:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800bd6:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800bdd:	00 00 00 
  800be0:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800be7:	00 00 00 
  800bea:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800bee:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800bf5:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800bfc:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c03:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c0a:	48 b8 3d 0b 80 00 00 	movabs $0x800b3d,%rax
  800c11:	00 00 00 
  800c14:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800c16:	c9                   	leaveq 
  800c17:	c3                   	retq   

0000000000800c18 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800c18:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c1b:	74 17                	je     800c34 <strlen+0x1c>
  800c1d:	48 89 fa             	mov    %rdi,%rdx
  800c20:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c25:	29 f9                	sub    %edi,%ecx
    n++;
  800c27:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800c2a:	48 83 c2 01          	add    $0x1,%rdx
  800c2e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c31:	75 f4                	jne    800c27 <strlen+0xf>
  800c33:	c3                   	retq   
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c39:	c3                   	retq   

0000000000800c3a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3a:	48 85 f6             	test   %rsi,%rsi
  800c3d:	74 24                	je     800c63 <strnlen+0x29>
  800c3f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c42:	74 25                	je     800c69 <strnlen+0x2f>
  800c44:	48 01 fe             	add    %rdi,%rsi
  800c47:	48 89 fa             	mov    %rdi,%rdx
  800c4a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c4f:	29 f9                	sub    %edi,%ecx
    n++;
  800c51:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c54:	48 83 c2 01          	add    $0x1,%rdx
  800c58:	48 39 f2             	cmp    %rsi,%rdx
  800c5b:	74 11                	je     800c6e <strnlen+0x34>
  800c5d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c60:	75 ef                	jne    800c51 <strnlen+0x17>
  800c62:	c3                   	retq   
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	c3                   	retq   
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c6e:	c3                   	retq   

0000000000800c6f <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800c6f:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800c72:	ba 00 00 00 00       	mov    $0x0,%edx
  800c77:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800c7b:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800c7e:	48 83 c2 01          	add    $0x1,%rdx
  800c82:	84 c9                	test   %cl,%cl
  800c84:	75 f1                	jne    800c77 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800c86:	c3                   	retq   

0000000000800c87 <strcat>:

char *
strcat(char *dst, const char *src) {
  800c87:	55                   	push   %rbp
  800c88:	48 89 e5             	mov    %rsp,%rbp
  800c8b:	41 54                	push   %r12
  800c8d:	53                   	push   %rbx
  800c8e:	48 89 fb             	mov    %rdi,%rbx
  800c91:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800c94:	48 b8 18 0c 80 00 00 	movabs $0x800c18,%rax
  800c9b:	00 00 00 
  800c9e:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800ca0:	48 63 f8             	movslq %eax,%rdi
  800ca3:	48 01 df             	add    %rbx,%rdi
  800ca6:	4c 89 e6             	mov    %r12,%rsi
  800ca9:	48 b8 6f 0c 80 00 00 	movabs $0x800c6f,%rax
  800cb0:	00 00 00 
  800cb3:	ff d0                	callq  *%rax
  return dst;
}
  800cb5:	48 89 d8             	mov    %rbx,%rax
  800cb8:	5b                   	pop    %rbx
  800cb9:	41 5c                	pop    %r12
  800cbb:	5d                   	pop    %rbp
  800cbc:	c3                   	retq   

0000000000800cbd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cbd:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800cc0:	48 85 d2             	test   %rdx,%rdx
  800cc3:	74 1f                	je     800ce4 <strncpy+0x27>
  800cc5:	48 01 fa             	add    %rdi,%rdx
  800cc8:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800ccb:	48 83 c1 01          	add    $0x1,%rcx
  800ccf:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cd3:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800cd7:	41 80 f8 01          	cmp    $0x1,%r8b
  800cdb:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800cdf:	48 39 ca             	cmp    %rcx,%rdx
  800ce2:	75 e7                	jne    800ccb <strncpy+0xe>
  }
  return ret;
}
  800ce4:	c3                   	retq   

0000000000800ce5 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800ce5:	48 89 f8             	mov    %rdi,%rax
  800ce8:	48 85 d2             	test   %rdx,%rdx
  800ceb:	74 36                	je     800d23 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800ced:	48 83 fa 01          	cmp    $0x1,%rdx
  800cf1:	74 2d                	je     800d20 <strlcpy+0x3b>
  800cf3:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cf7:	45 84 c0             	test   %r8b,%r8b
  800cfa:	74 24                	je     800d20 <strlcpy+0x3b>
  800cfc:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d00:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d05:	48 83 c0 01          	add    $0x1,%rax
  800d09:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d0d:	48 39 d1             	cmp    %rdx,%rcx
  800d10:	74 0e                	je     800d20 <strlcpy+0x3b>
  800d12:	48 83 c1 01          	add    $0x1,%rcx
  800d16:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800d1b:	45 84 c0             	test   %r8b,%r8b
  800d1e:	75 e5                	jne    800d05 <strlcpy+0x20>
    *dst = '\0';
  800d20:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800d23:	48 29 f8             	sub    %rdi,%rax
}
  800d26:	c3                   	retq   

0000000000800d27 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800d27:	0f b6 07             	movzbl (%rdi),%eax
  800d2a:	84 c0                	test   %al,%al
  800d2c:	74 17                	je     800d45 <strcmp+0x1e>
  800d2e:	3a 06                	cmp    (%rsi),%al
  800d30:	75 13                	jne    800d45 <strcmp+0x1e>
    p++, q++;
  800d32:	48 83 c7 01          	add    $0x1,%rdi
  800d36:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800d3a:	0f b6 07             	movzbl (%rdi),%eax
  800d3d:	84 c0                	test   %al,%al
  800d3f:	74 04                	je     800d45 <strcmp+0x1e>
  800d41:	3a 06                	cmp    (%rsi),%al
  800d43:	74 ed                	je     800d32 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800d45:	0f b6 c0             	movzbl %al,%eax
  800d48:	0f b6 16             	movzbl (%rsi),%edx
  800d4b:	29 d0                	sub    %edx,%eax
}
  800d4d:	c3                   	retq   

0000000000800d4e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800d4e:	48 85 d2             	test   %rdx,%rdx
  800d51:	74 2f                	je     800d82 <strncmp+0x34>
  800d53:	0f b6 07             	movzbl (%rdi),%eax
  800d56:	84 c0                	test   %al,%al
  800d58:	74 1f                	je     800d79 <strncmp+0x2b>
  800d5a:	3a 06                	cmp    (%rsi),%al
  800d5c:	75 1b                	jne    800d79 <strncmp+0x2b>
  800d5e:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800d61:	48 83 c7 01          	add    $0x1,%rdi
  800d65:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800d69:	48 39 d7             	cmp    %rdx,%rdi
  800d6c:	74 1a                	je     800d88 <strncmp+0x3a>
  800d6e:	0f b6 07             	movzbl (%rdi),%eax
  800d71:	84 c0                	test   %al,%al
  800d73:	74 04                	je     800d79 <strncmp+0x2b>
  800d75:	3a 06                	cmp    (%rsi),%al
  800d77:	74 e8                	je     800d61 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800d79:	0f b6 07             	movzbl (%rdi),%eax
  800d7c:	0f b6 16             	movzbl (%rsi),%edx
  800d7f:	29 d0                	sub    %edx,%eax
}
  800d81:	c3                   	retq   
    return 0;
  800d82:	b8 00 00 00 00       	mov    $0x0,%eax
  800d87:	c3                   	retq   
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8d:	c3                   	retq   

0000000000800d8e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800d8e:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800d90:	0f b6 07             	movzbl (%rdi),%eax
  800d93:	84 c0                	test   %al,%al
  800d95:	74 1e                	je     800db5 <strchr+0x27>
    if (*s == c)
  800d97:	40 38 c6             	cmp    %al,%sil
  800d9a:	74 1f                	je     800dbb <strchr+0x2d>
  for (; *s; s++)
  800d9c:	48 83 c7 01          	add    $0x1,%rdi
  800da0:	0f b6 07             	movzbl (%rdi),%eax
  800da3:	84 c0                	test   %al,%al
  800da5:	74 08                	je     800daf <strchr+0x21>
    if (*s == c)
  800da7:	38 d0                	cmp    %dl,%al
  800da9:	75 f1                	jne    800d9c <strchr+0xe>
  for (; *s; s++)
  800dab:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800dae:	c3                   	retq   
  return 0;
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	c3                   	retq   
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dba:	c3                   	retq   
    if (*s == c)
  800dbb:	48 89 f8             	mov    %rdi,%rax
  800dbe:	c3                   	retq   

0000000000800dbf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800dbf:	48 89 f8             	mov    %rdi,%rax
  800dc2:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800dc4:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800dc7:	40 38 f2             	cmp    %sil,%dl
  800dca:	74 13                	je     800ddf <strfind+0x20>
  800dcc:	84 d2                	test   %dl,%dl
  800dce:	74 0f                	je     800ddf <strfind+0x20>
  for (; *s; s++)
  800dd0:	48 83 c0 01          	add    $0x1,%rax
  800dd4:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800dd7:	38 ca                	cmp    %cl,%dl
  800dd9:	74 04                	je     800ddf <strfind+0x20>
  800ddb:	84 d2                	test   %dl,%dl
  800ddd:	75 f1                	jne    800dd0 <strfind+0x11>
      break;
  return (char *)s;
}
  800ddf:	c3                   	retq   

0000000000800de0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800de0:	48 85 d2             	test   %rdx,%rdx
  800de3:	74 3a                	je     800e1f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800de5:	48 89 f8             	mov    %rdi,%rax
  800de8:	48 09 d0             	or     %rdx,%rax
  800deb:	a8 03                	test   $0x3,%al
  800ded:	75 28                	jne    800e17 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800def:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800df3:	89 f0                	mov    %esi,%eax
  800df5:	c1 e0 08             	shl    $0x8,%eax
  800df8:	89 f1                	mov    %esi,%ecx
  800dfa:	c1 e1 18             	shl    $0x18,%ecx
  800dfd:	41 89 f0             	mov    %esi,%r8d
  800e00:	41 c1 e0 10          	shl    $0x10,%r8d
  800e04:	44 09 c1             	or     %r8d,%ecx
  800e07:	09 ce                	or     %ecx,%esi
  800e09:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e0b:	48 c1 ea 02          	shr    $0x2,%rdx
  800e0f:	48 89 d1             	mov    %rdx,%rcx
  800e12:	fc                   	cld    
  800e13:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e15:	eb 08                	jmp    800e1f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	48 89 d1             	mov    %rdx,%rcx
  800e1c:	fc                   	cld    
  800e1d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800e1f:	48 89 f8             	mov    %rdi,%rax
  800e22:	c3                   	retq   

0000000000800e23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800e23:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800e26:	48 39 fe             	cmp    %rdi,%rsi
  800e29:	73 40                	jae    800e6b <memmove+0x48>
  800e2b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800e2f:	48 39 f9             	cmp    %rdi,%rcx
  800e32:	76 37                	jbe    800e6b <memmove+0x48>
    s += n;
    d += n;
  800e34:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e38:	48 89 fe             	mov    %rdi,%rsi
  800e3b:	48 09 d6             	or     %rdx,%rsi
  800e3e:	48 09 ce             	or     %rcx,%rsi
  800e41:	40 f6 c6 03          	test   $0x3,%sil
  800e45:	75 14                	jne    800e5b <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800e47:	48 83 ef 04          	sub    $0x4,%rdi
  800e4b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800e4f:	48 c1 ea 02          	shr    $0x2,%rdx
  800e53:	48 89 d1             	mov    %rdx,%rcx
  800e56:	fd                   	std    
  800e57:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e59:	eb 0e                	jmp    800e69 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800e5b:	48 83 ef 01          	sub    $0x1,%rdi
  800e5f:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800e63:	48 89 d1             	mov    %rdx,%rcx
  800e66:	fd                   	std    
  800e67:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800e69:	fc                   	cld    
  800e6a:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e6b:	48 89 c1             	mov    %rax,%rcx
  800e6e:	48 09 d1             	or     %rdx,%rcx
  800e71:	48 09 f1             	or     %rsi,%rcx
  800e74:	f6 c1 03             	test   $0x3,%cl
  800e77:	75 0e                	jne    800e87 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800e79:	48 c1 ea 02          	shr    $0x2,%rdx
  800e7d:	48 89 d1             	mov    %rdx,%rcx
  800e80:	48 89 c7             	mov    %rax,%rdi
  800e83:	fc                   	cld    
  800e84:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e86:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800e87:	48 89 c7             	mov    %rax,%rdi
  800e8a:	48 89 d1             	mov    %rdx,%rcx
  800e8d:	fc                   	cld    
  800e8e:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800e90:	c3                   	retq   

0000000000800e91 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800e91:	55                   	push   %rbp
  800e92:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800e95:	48 b8 23 0e 80 00 00 	movabs $0x800e23,%rax
  800e9c:	00 00 00 
  800e9f:	ff d0                	callq  *%rax
}
  800ea1:	5d                   	pop    %rbp
  800ea2:	c3                   	retq   

0000000000800ea3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800ea3:	55                   	push   %rbp
  800ea4:	48 89 e5             	mov    %rsp,%rbp
  800ea7:	41 57                	push   %r15
  800ea9:	41 56                	push   %r14
  800eab:	41 55                	push   %r13
  800ead:	41 54                	push   %r12
  800eaf:	53                   	push   %rbx
  800eb0:	48 83 ec 08          	sub    $0x8,%rsp
  800eb4:	49 89 fe             	mov    %rdi,%r14
  800eb7:	49 89 f7             	mov    %rsi,%r15
  800eba:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800ebd:	48 89 f7             	mov    %rsi,%rdi
  800ec0:	48 b8 18 0c 80 00 00 	movabs $0x800c18,%rax
  800ec7:	00 00 00 
  800eca:	ff d0                	callq  *%rax
  800ecc:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800ecf:	4c 89 ee             	mov    %r13,%rsi
  800ed2:	4c 89 f7             	mov    %r14,%rdi
  800ed5:	48 b8 3a 0c 80 00 00 	movabs $0x800c3a,%rax
  800edc:	00 00 00 
  800edf:	ff d0                	callq  *%rax
  800ee1:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800ee4:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800ee8:	4d 39 e5             	cmp    %r12,%r13
  800eeb:	74 26                	je     800f13 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800eed:	4c 89 e8             	mov    %r13,%rax
  800ef0:	4c 29 e0             	sub    %r12,%rax
  800ef3:	48 39 d8             	cmp    %rbx,%rax
  800ef6:	76 2a                	jbe    800f22 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800ef8:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800efc:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f00:	4c 89 fe             	mov    %r15,%rsi
  800f03:	48 b8 91 0e 80 00 00 	movabs $0x800e91,%rax
  800f0a:	00 00 00 
  800f0d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f0f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800f13:	48 83 c4 08          	add    $0x8,%rsp
  800f17:	5b                   	pop    %rbx
  800f18:	41 5c                	pop    %r12
  800f1a:	41 5d                	pop    %r13
  800f1c:	41 5e                	pop    %r14
  800f1e:	41 5f                	pop    %r15
  800f20:	5d                   	pop    %rbp
  800f21:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800f22:	49 83 ed 01          	sub    $0x1,%r13
  800f26:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f2a:	4c 89 ea             	mov    %r13,%rdx
  800f2d:	4c 89 fe             	mov    %r15,%rsi
  800f30:	48 b8 91 0e 80 00 00 	movabs $0x800e91,%rax
  800f37:	00 00 00 
  800f3a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800f3c:	4d 01 ee             	add    %r13,%r14
  800f3f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800f44:	eb c9                	jmp    800f0f <strlcat+0x6c>

0000000000800f46 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800f46:	48 85 d2             	test   %rdx,%rdx
  800f49:	74 3a                	je     800f85 <memcmp+0x3f>
    if (*s1 != *s2)
  800f4b:	0f b6 0f             	movzbl (%rdi),%ecx
  800f4e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800f52:	44 38 c1             	cmp    %r8b,%cl
  800f55:	75 1d                	jne    800f74 <memcmp+0x2e>
  800f57:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800f5c:	48 39 d0             	cmp    %rdx,%rax
  800f5f:	74 1e                	je     800f7f <memcmp+0x39>
    if (*s1 != *s2)
  800f61:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800f65:	48 83 c0 01          	add    $0x1,%rax
  800f69:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800f6f:	44 38 c1             	cmp    %r8b,%cl
  800f72:	74 e8                	je     800f5c <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800f74:	0f b6 c1             	movzbl %cl,%eax
  800f77:	45 0f b6 c0          	movzbl %r8b,%r8d
  800f7b:	44 29 c0             	sub    %r8d,%eax
  800f7e:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800f7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f84:	c3                   	retq   
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f8a:	c3                   	retq   

0000000000800f8b <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800f8b:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800f8f:	48 39 c7             	cmp    %rax,%rdi
  800f92:	73 19                	jae    800fad <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f94:	89 f2                	mov    %esi,%edx
  800f96:	40 38 37             	cmp    %sil,(%rdi)
  800f99:	74 16                	je     800fb1 <memfind+0x26>
  for (; s < ends; s++)
  800f9b:	48 83 c7 01          	add    $0x1,%rdi
  800f9f:	48 39 f8             	cmp    %rdi,%rax
  800fa2:	74 08                	je     800fac <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800fa4:	38 17                	cmp    %dl,(%rdi)
  800fa6:	75 f3                	jne    800f9b <memfind+0x10>
  for (; s < ends; s++)
  800fa8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800fab:	c3                   	retq   
  800fac:	c3                   	retq   
  for (; s < ends; s++)
  800fad:	48 89 f8             	mov    %rdi,%rax
  800fb0:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800fb1:	48 89 f8             	mov    %rdi,%rax
  800fb4:	c3                   	retq   

0000000000800fb5 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800fb5:	0f b6 07             	movzbl (%rdi),%eax
  800fb8:	3c 20                	cmp    $0x20,%al
  800fba:	74 04                	je     800fc0 <strtol+0xb>
  800fbc:	3c 09                	cmp    $0x9,%al
  800fbe:	75 0f                	jne    800fcf <strtol+0x1a>
    s++;
  800fc0:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800fc4:	0f b6 07             	movzbl (%rdi),%eax
  800fc7:	3c 20                	cmp    $0x20,%al
  800fc9:	74 f5                	je     800fc0 <strtol+0xb>
  800fcb:	3c 09                	cmp    $0x9,%al
  800fcd:	74 f1                	je     800fc0 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800fcf:	3c 2b                	cmp    $0x2b,%al
  800fd1:	74 2b                	je     800ffe <strtol+0x49>
  int neg  = 0;
  800fd3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800fd9:	3c 2d                	cmp    $0x2d,%al
  800fdb:	74 2d                	je     80100a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fdd:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800fe3:	75 0f                	jne    800ff4 <strtol+0x3f>
  800fe5:	80 3f 30             	cmpb   $0x30,(%rdi)
  800fe8:	74 2c                	je     801016 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800fea:	85 d2                	test   %edx,%edx
  800fec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ff1:	0f 44 d0             	cmove  %eax,%edx
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800ff9:	4c 63 d2             	movslq %edx,%r10
  800ffc:	eb 5c                	jmp    80105a <strtol+0xa5>
    s++;
  800ffe:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801002:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801008:	eb d3                	jmp    800fdd <strtol+0x28>
    s++, neg = 1;
  80100a:	48 83 c7 01          	add    $0x1,%rdi
  80100e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801014:	eb c7                	jmp    800fdd <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801016:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80101a:	74 0f                	je     80102b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80101c:	85 d2                	test   %edx,%edx
  80101e:	75 d4                	jne    800ff4 <strtol+0x3f>
    s++, base = 8;
  801020:	48 83 c7 01          	add    $0x1,%rdi
  801024:	ba 08 00 00 00       	mov    $0x8,%edx
  801029:	eb c9                	jmp    800ff4 <strtol+0x3f>
    s += 2, base = 16;
  80102b:	48 83 c7 02          	add    $0x2,%rdi
  80102f:	ba 10 00 00 00       	mov    $0x10,%edx
  801034:	eb be                	jmp    800ff4 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801036:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80103a:	41 80 f8 19          	cmp    $0x19,%r8b
  80103e:	77 2f                	ja     80106f <strtol+0xba>
      dig = *s - 'a' + 10;
  801040:	44 0f be c1          	movsbl %cl,%r8d
  801044:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801048:	39 d1                	cmp    %edx,%ecx
  80104a:	7d 37                	jge    801083 <strtol+0xce>
    s++, val = (val * base) + dig;
  80104c:	48 83 c7 01          	add    $0x1,%rdi
  801050:	49 0f af c2          	imul   %r10,%rax
  801054:	48 63 c9             	movslq %ecx,%rcx
  801057:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80105a:	0f b6 0f             	movzbl (%rdi),%ecx
  80105d:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801061:	41 80 f8 09          	cmp    $0x9,%r8b
  801065:	77 cf                	ja     801036 <strtol+0x81>
      dig = *s - '0';
  801067:	0f be c9             	movsbl %cl,%ecx
  80106a:	83 e9 30             	sub    $0x30,%ecx
  80106d:	eb d9                	jmp    801048 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80106f:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801073:	41 80 f8 19          	cmp    $0x19,%r8b
  801077:	77 0a                	ja     801083 <strtol+0xce>
      dig = *s - 'A' + 10;
  801079:	44 0f be c1          	movsbl %cl,%r8d
  80107d:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801081:	eb c5                	jmp    801048 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801083:	48 85 f6             	test   %rsi,%rsi
  801086:	74 03                	je     80108b <strtol+0xd6>
    *endptr = (char *)s;
  801088:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80108b:	48 89 c2             	mov    %rax,%rdx
  80108e:	48 f7 da             	neg    %rdx
  801091:	45 85 c9             	test   %r9d,%r9d
  801094:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801098:	c3                   	retq   

0000000000801099 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  801099:	55                   	push   %rbp
  80109a:	48 89 e5             	mov    %rsp,%rbp
  80109d:	53                   	push   %rbx
  80109e:	48 89 fa             	mov    %rdi,%rdx
  8010a1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8010a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a9:	48 89 c3             	mov    %rax,%rbx
  8010ac:	48 89 c7             	mov    %rax,%rdi
  8010af:	48 89 c6             	mov    %rax,%rsi
  8010b2:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8010b4:	5b                   	pop    %rbx
  8010b5:	5d                   	pop    %rbp
  8010b6:	c3                   	retq   

00000000008010b7 <sys_cgetc>:

int
sys_cgetc(void) {
  8010b7:	55                   	push   %rbp
  8010b8:	48 89 e5             	mov    %rsp,%rbp
  8010bb:	53                   	push   %rbx
  asm volatile("int %1\n"
  8010bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c6:	48 89 ca             	mov    %rcx,%rdx
  8010c9:	48 89 cb             	mov    %rcx,%rbx
  8010cc:	48 89 cf             	mov    %rcx,%rdi
  8010cf:	48 89 ce             	mov    %rcx,%rsi
  8010d2:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010d4:	5b                   	pop    %rbx
  8010d5:	5d                   	pop    %rbp
  8010d6:	c3                   	retq   

00000000008010d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8010d7:	55                   	push   %rbp
  8010d8:	48 89 e5             	mov    %rsp,%rbp
  8010db:	53                   	push   %rbx
  8010dc:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010e0:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8010e3:	be 00 00 00 00       	mov    $0x0,%esi
  8010e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8010ed:	48 89 f1             	mov    %rsi,%rcx
  8010f0:	48 89 f3             	mov    %rsi,%rbx
  8010f3:	48 89 f7             	mov    %rsi,%rdi
  8010f6:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010f8:	48 85 c0             	test   %rax,%rax
  8010fb:	7f 07                	jg     801104 <sys_env_destroy+0x2d>
}
  8010fd:	48 83 c4 08          	add    $0x8,%rsp
  801101:	5b                   	pop    %rbx
  801102:	5d                   	pop    %rbp
  801103:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801104:	49 89 c0             	mov    %rax,%r8
  801107:	b9 03 00 00 00       	mov    $0x3,%ecx
  80110c:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  801113:	00 00 00 
  801116:	be 22 00 00 00       	mov    $0x22,%esi
  80111b:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  801122:	00 00 00 
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
  80112a:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  801131:	00 00 00 
  801134:	41 ff d1             	callq  *%r9

0000000000801137 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801137:	55                   	push   %rbp
  801138:	48 89 e5             	mov    %rsp,%rbp
  80113b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80113c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801141:	b8 02 00 00 00       	mov    $0x2,%eax
  801146:	48 89 ca             	mov    %rcx,%rdx
  801149:	48 89 cb             	mov    %rcx,%rbx
  80114c:	48 89 cf             	mov    %rcx,%rdi
  80114f:	48 89 ce             	mov    %rcx,%rsi
  801152:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801154:	5b                   	pop    %rbx
  801155:	5d                   	pop    %rbp
  801156:	c3                   	retq   

0000000000801157 <sys_yield>:

void
sys_yield(void) {
  801157:	55                   	push   %rbp
  801158:	48 89 e5             	mov    %rsp,%rbp
  80115b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80115c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801161:	b8 0a 00 00 00       	mov    $0xa,%eax
  801166:	48 89 ca             	mov    %rcx,%rdx
  801169:	48 89 cb             	mov    %rcx,%rbx
  80116c:	48 89 cf             	mov    %rcx,%rdi
  80116f:	48 89 ce             	mov    %rcx,%rsi
  801172:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801174:	5b                   	pop    %rbx
  801175:	5d                   	pop    %rbp
  801176:	c3                   	retq   

0000000000801177 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  801177:	55                   	push   %rbp
  801178:	48 89 e5             	mov    %rsp,%rbp
  80117b:	53                   	push   %rbx
  80117c:	48 83 ec 08          	sub    $0x8,%rsp
  801180:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801183:	4c 63 c7             	movslq %edi,%r8
  801186:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  801189:	be 00 00 00 00       	mov    $0x0,%esi
  80118e:	b8 04 00 00 00       	mov    $0x4,%eax
  801193:	4c 89 c2             	mov    %r8,%rdx
  801196:	48 89 f7             	mov    %rsi,%rdi
  801199:	cd 30                	int    $0x30
  if (check && ret > 0)
  80119b:	48 85 c0             	test   %rax,%rax
  80119e:	7f 07                	jg     8011a7 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8011a0:	48 83 c4 08          	add    $0x8,%rsp
  8011a4:	5b                   	pop    %rbx
  8011a5:	5d                   	pop    %rbp
  8011a6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011a7:	49 89 c0             	mov    %rax,%r8
  8011aa:	b9 04 00 00 00       	mov    $0x4,%ecx
  8011af:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  8011b6:	00 00 00 
  8011b9:	be 22 00 00 00       	mov    $0x22,%esi
  8011be:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  8011c5:	00 00 00 
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cd:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  8011d4:	00 00 00 
  8011d7:	41 ff d1             	callq  *%r9

00000000008011da <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8011da:	55                   	push   %rbp
  8011db:	48 89 e5             	mov    %rsp,%rbp
  8011de:	53                   	push   %rbx
  8011df:	48 83 ec 08          	sub    $0x8,%rsp
  8011e3:	41 89 f9             	mov    %edi,%r9d
  8011e6:	49 89 f2             	mov    %rsi,%r10
  8011e9:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8011ec:	4d 63 c9             	movslq %r9d,%r9
  8011ef:	48 63 da             	movslq %edx,%rbx
  8011f2:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8011f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8011fa:	4c 89 ca             	mov    %r9,%rdx
  8011fd:	4c 89 d1             	mov    %r10,%rcx
  801200:	cd 30                	int    $0x30
  if (check && ret > 0)
  801202:	48 85 c0             	test   %rax,%rax
  801205:	7f 07                	jg     80120e <sys_page_map+0x34>
}
  801207:	48 83 c4 08          	add    $0x8,%rsp
  80120b:	5b                   	pop    %rbx
  80120c:	5d                   	pop    %rbp
  80120d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80120e:	49 89 c0             	mov    %rax,%r8
  801211:	b9 05 00 00 00       	mov    $0x5,%ecx
  801216:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  80121d:	00 00 00 
  801220:	be 22 00 00 00       	mov    $0x22,%esi
  801225:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  80122c:	00 00 00 
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
  801234:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  80123b:	00 00 00 
  80123e:	41 ff d1             	callq  *%r9

0000000000801241 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801241:	55                   	push   %rbp
  801242:	48 89 e5             	mov    %rsp,%rbp
  801245:	53                   	push   %rbx
  801246:	48 83 ec 08          	sub    $0x8,%rsp
  80124a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  80124d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801250:	be 00 00 00 00       	mov    $0x0,%esi
  801255:	b8 06 00 00 00       	mov    $0x6,%eax
  80125a:	48 89 f3             	mov    %rsi,%rbx
  80125d:	48 89 f7             	mov    %rsi,%rdi
  801260:	cd 30                	int    $0x30
  if (check && ret > 0)
  801262:	48 85 c0             	test   %rax,%rax
  801265:	7f 07                	jg     80126e <sys_page_unmap+0x2d>
}
  801267:	48 83 c4 08          	add    $0x8,%rsp
  80126b:	5b                   	pop    %rbx
  80126c:	5d                   	pop    %rbp
  80126d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80126e:	49 89 c0             	mov    %rax,%r8
  801271:	b9 06 00 00 00       	mov    $0x6,%ecx
  801276:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  80127d:	00 00 00 
  801280:	be 22 00 00 00       	mov    $0x22,%esi
  801285:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  80128c:	00 00 00 
  80128f:	b8 00 00 00 00       	mov    $0x0,%eax
  801294:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  80129b:	00 00 00 
  80129e:	41 ff d1             	callq  *%r9

00000000008012a1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8012a1:	55                   	push   %rbp
  8012a2:	48 89 e5             	mov    %rsp,%rbp
  8012a5:	53                   	push   %rbx
  8012a6:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8012aa:	48 63 d7             	movslq %edi,%rdx
  8012ad:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8012ba:	48 89 df             	mov    %rbx,%rdi
  8012bd:	48 89 de             	mov    %rbx,%rsi
  8012c0:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012c2:	48 85 c0             	test   %rax,%rax
  8012c5:	7f 07                	jg     8012ce <sys_env_set_status+0x2d>
}
  8012c7:	48 83 c4 08          	add    $0x8,%rsp
  8012cb:	5b                   	pop    %rbx
  8012cc:	5d                   	pop    %rbp
  8012cd:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012ce:	49 89 c0             	mov    %rax,%r8
  8012d1:	b9 08 00 00 00       	mov    $0x8,%ecx
  8012d6:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  8012dd:	00 00 00 
  8012e0:	be 22 00 00 00       	mov    $0x22,%esi
  8012e5:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  8012ec:	00 00 00 
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f4:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  8012fb:	00 00 00 
  8012fe:	41 ff d1             	callq  *%r9

0000000000801301 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801301:	55                   	push   %rbp
  801302:	48 89 e5             	mov    %rsp,%rbp
  801305:	53                   	push   %rbx
  801306:	48 83 ec 08          	sub    $0x8,%rsp
  80130a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80130d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801310:	be 00 00 00 00       	mov    $0x0,%esi
  801315:	b8 09 00 00 00       	mov    $0x9,%eax
  80131a:	48 89 f3             	mov    %rsi,%rbx
  80131d:	48 89 f7             	mov    %rsi,%rdi
  801320:	cd 30                	int    $0x30
  if (check && ret > 0)
  801322:	48 85 c0             	test   %rax,%rax
  801325:	7f 07                	jg     80132e <sys_env_set_pgfault_upcall+0x2d>
}
  801327:	48 83 c4 08          	add    $0x8,%rsp
  80132b:	5b                   	pop    %rbx
  80132c:	5d                   	pop    %rbp
  80132d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80132e:	49 89 c0             	mov    %rax,%r8
  801331:	b9 09 00 00 00       	mov    $0x9,%ecx
  801336:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  80133d:	00 00 00 
  801340:	be 22 00 00 00       	mov    $0x22,%esi
  801345:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  80134c:	00 00 00 
  80134f:	b8 00 00 00 00       	mov    $0x0,%eax
  801354:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  80135b:	00 00 00 
  80135e:	41 ff d1             	callq  *%r9

0000000000801361 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801361:	55                   	push   %rbp
  801362:	48 89 e5             	mov    %rsp,%rbp
  801365:	53                   	push   %rbx
  801366:	49 89 f0             	mov    %rsi,%r8
  801369:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  80136c:	48 63 d7             	movslq %edi,%rdx
  80136f:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801372:	b8 0b 00 00 00       	mov    $0xb,%eax
  801377:	be 00 00 00 00       	mov    $0x0,%esi
  80137c:	4c 89 c1             	mov    %r8,%rcx
  80137f:	cd 30                	int    $0x30
}
  801381:	5b                   	pop    %rbx
  801382:	5d                   	pop    %rbp
  801383:	c3                   	retq   

0000000000801384 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801384:	55                   	push   %rbp
  801385:	48 89 e5             	mov    %rsp,%rbp
  801388:	53                   	push   %rbx
  801389:	48 83 ec 08          	sub    $0x8,%rsp
  80138d:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801390:	be 00 00 00 00       	mov    $0x0,%esi
  801395:	b8 0c 00 00 00       	mov    $0xc,%eax
  80139a:	48 89 f1             	mov    %rsi,%rcx
  80139d:	48 89 f3             	mov    %rsi,%rbx
  8013a0:	48 89 f7             	mov    %rsi,%rdi
  8013a3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013a5:	48 85 c0             	test   %rax,%rax
  8013a8:	7f 07                	jg     8013b1 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8013aa:	48 83 c4 08          	add    $0x8,%rsp
  8013ae:	5b                   	pop    %rbx
  8013af:	5d                   	pop    %rbp
  8013b0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013b1:	49 89 c0             	mov    %rax,%r8
  8013b4:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8013b9:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  8013c0:	00 00 00 
  8013c3:	be 22 00 00 00       	mov    $0x22,%esi
  8013c8:	48 bf bf 1e 80 00 00 	movabs $0x801ebf,%rdi
  8013cf:	00 00 00 
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d7:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  8013de:	00 00 00 
  8013e1:	41 ff d1             	callq  *%r9

00000000008013e4 <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  8013e4:	55                   	push   %rbp
  8013e5:	48 89 e5             	mov    %rsp,%rbp
  8013e8:	53                   	push   %rbx
  8013e9:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  8013ed:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  8013f0:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  8013f4:	41 f6 c0 02          	test   $0x2,%r8b
  8013f8:	0f 84 b2 00 00 00    	je     8014b0 <pgfault+0xcc>
  8013fe:	48 89 da             	mov    %rbx,%rdx
  801401:	48 c1 ea 0c          	shr    $0xc,%rdx
  801405:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80140c:	01 00 00 
  80140f:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801413:	f6 c4 08             	test   $0x8,%ah
  801416:	0f 84 94 00 00 00    	je     8014b0 <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  80141c:	ba 02 00 00 00       	mov    $0x2,%edx
  801421:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801426:	bf 00 00 00 00       	mov    $0x0,%edi
  80142b:	48 b8 77 11 80 00 00 	movabs $0x801177,%rax
  801432:	00 00 00 
  801435:	ff d0                	callq  *%rax
  801437:	85 c0                	test   %eax,%eax
  801439:	0f 88 9f 00 00 00    	js     8014de <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80143f:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  801446:	ba 00 10 00 00       	mov    $0x1000,%edx
  80144b:	48 89 de             	mov    %rbx,%rsi
  80144e:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  801453:	48 b8 23 0e 80 00 00 	movabs $0x800e23,%rax
  80145a:	00 00 00 
  80145d:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  80145f:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  801465:	48 89 d9             	mov    %rbx,%rcx
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801472:	bf 00 00 00 00       	mov    $0x0,%edi
  801477:	48 b8 da 11 80 00 00 	movabs $0x8011da,%rax
  80147e:	00 00 00 
  801481:	ff d0                	callq  *%rax
  801483:	85 c0                	test   %eax,%eax
  801485:	0f 88 80 00 00 00    	js     80150b <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  80148b:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801490:	bf 00 00 00 00       	mov    $0x0,%edi
  801495:	48 b8 41 12 80 00 00 	movabs $0x801241,%rax
  80149c:	00 00 00 
  80149f:	ff d0                	callq  *%rax
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	0f 88 8f 00 00 00    	js     801538 <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  8014a9:	48 83 c4 08          	add    $0x8,%rsp
  8014ad:	5b                   	pop    %rbx
  8014ae:	5d                   	pop    %rbp
  8014af:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  8014b0:	48 89 d9             	mov    %rbx,%rcx
  8014b3:	48 ba d0 1e 80 00 00 	movabs $0x801ed0,%rdx
  8014ba:	00 00 00 
  8014bd:	be 21 00 00 00       	mov    $0x21,%esi
  8014c2:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  8014c9:	00 00 00 
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d1:	49 b9 a3 18 80 00 00 	movabs $0x8018a3,%r9
  8014d8:	00 00 00 
  8014db:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  8014de:	89 c1                	mov    %eax,%ecx
  8014e0:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  8014e7:	00 00 00 
  8014ea:	be 2f 00 00 00       	mov    $0x2f,%esi
  8014ef:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  8014f6:	00 00 00 
  8014f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fe:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  801505:	00 00 00 
  801508:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  80150b:	89 c1                	mov    %eax,%ecx
  80150d:	48 ba 28 1f 80 00 00 	movabs $0x801f28,%rdx
  801514:	00 00 00 
  801517:	be 39 00 00 00       	mov    $0x39,%esi
  80151c:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  801523:	00 00 00 
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  801532:	00 00 00 
  801535:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  801538:	89 c1                	mov    %eax,%ecx
  80153a:	48 ba 50 1f 80 00 00 	movabs $0x801f50,%rdx
  801541:	00 00 00 
  801544:	be 3d 00 00 00       	mov    $0x3d,%esi
  801549:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  801550:	00 00 00 
  801553:	b8 00 00 00 00       	mov    $0x0,%eax
  801558:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  80155f:	00 00 00 
  801562:	41 ff d0             	callq  *%r8

0000000000801565 <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  801565:	55                   	push   %rbp
  801566:	48 89 e5             	mov    %rsp,%rbp
  801569:	41 57                	push   %r15
  80156b:	41 56                	push   %r14
  80156d:	41 55                	push   %r13
  80156f:	41 54                	push   %r12
  801571:	53                   	push   %rbx
  801572:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  801576:	48 bf e4 13 80 00 00 	movabs $0x8013e4,%rdi
  80157d:	00 00 00 
  801580:	48 b8 93 19 80 00 00 	movabs $0x801993,%rax
  801587:	00 00 00 
  80158a:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  80158c:	b8 07 00 00 00       	mov    $0x7,%eax
  801591:	cd 30                	int    $0x30
  801593:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  801596:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 38                	js     8015d5 <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  80159d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8015a6:	74 5a                	je     801602 <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8015a8:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  8015af:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8015b2:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8015b9:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8015bc:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  8015c3:	01 00 00 
  8015c6:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  8015cd:	01 00 00 
  8015d0:	e9 2c 01 00 00       	jmpq   801701 <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  8015d5:	89 c1                	mov    %eax,%ecx
  8015d7:	48 ba f7 1f 80 00 00 	movabs $0x801ff7,%rdx
  8015de:	00 00 00 
  8015e1:	be 82 00 00 00       	mov    $0x82,%esi
  8015e6:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  8015ed:	00 00 00 
  8015f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f5:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  8015fc:	00 00 00 
  8015ff:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  801602:	48 b8 37 11 80 00 00 	movabs $0x801137,%rax
  801609:	00 00 00 
  80160c:	ff d0                	callq  *%rax
  80160e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801613:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  801617:	48 c1 e0 05          	shl    $0x5,%rax
  80161b:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  801622:	00 00 00 
  801625:	48 01 d0             	add    %rdx,%rax
  801628:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  80162f:	00 00 00 
		return 0;
  801632:	e9 9d 01 00 00       	jmpq   8017d4 <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  801637:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80163e:	01 00 00 
  801641:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801645:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  801649:	48 b8 37 11 80 00 00 	movabs $0x801137,%rax
  801650:	00 00 00 
  801653:	ff d0                	callq  *%rax
  801655:	89 c7                	mov    %eax,%edi
  801657:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  80165a:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80165e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801664:	74 57                	je     8016bd <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  801666:	81 e2 05 06 00 00    	and    $0x605,%edx
  80166c:	48 89 d0             	mov    %rdx,%rax
  80166f:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801672:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  801676:	48 c1 e6 0c          	shl    $0xc,%rsi
  80167a:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80167e:	41 89 c0             	mov    %eax,%r8d
  801681:	48 89 f1             	mov    %rsi,%rcx
  801684:	8b 55 c0             	mov    -0x40(%rbp),%edx
  801687:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  80168b:	48 b8 da 11 80 00 00 	movabs $0x8011da,%rax
  801692:	00 00 00 
  801695:	ff d0                	callq  *%rax
    if (r < 0) {
  801697:	85 c0                	test   %eax,%eax
  801699:	0f 88 ce 01 00 00    	js     80186d <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  80169f:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8016a3:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8016a7:	48 89 f1             	mov    %rsi,%rcx
  8016aa:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8016ad:	89 fa                	mov    %edi,%edx
  8016af:	48 b8 da 11 80 00 00 	movabs $0x8011da,%rax
  8016b6:	00 00 00 
  8016b9:	ff d0                	callq  *%rax
  8016bb:	eb 28                	jmp    8016e5 <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8016bd:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8016c1:	48 c1 e6 0c          	shl    $0xc,%rsi
  8016c5:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8016c9:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  8016d0:	48 89 f1             	mov    %rsi,%rcx
  8016d3:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8016d6:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8016d9:	48 b8 da 11 80 00 00 	movabs $0x8011da,%rax
  8016e0:	00 00 00 
  8016e3:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	0f 89 80 00 00 00    	jns    80176d <fork+0x208>
  8016ed:	89 45 c0             	mov    %eax,-0x40(%rbp)
  8016f0:	e9 df 00 00 00       	jmpq   8017d4 <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8016f5:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8016fc:	4c 39 eb             	cmp    %r13,%rbx
  8016ff:	74 75                	je     801776 <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801701:	48 89 d8             	mov    %rbx,%rax
  801704:	48 c1 e8 27          	shr    $0x27,%rax
  801708:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  80170c:	a8 01                	test   $0x1,%al
  80170e:	74 e5                	je     8016f5 <fork+0x190>
  801710:	48 89 d8             	mov    %rbx,%rax
  801713:	48 c1 e8 1e          	shr    $0x1e,%rax
  801717:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  80171b:	a8 01                	test   $0x1,%al
  80171d:	74 d6                	je     8016f5 <fork+0x190>
  80171f:	48 89 d8             	mov    %rbx,%rax
  801722:	48 c1 e8 15          	shr    $0x15,%rax
  801726:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  80172a:	a8 01                	test   $0x1,%al
  80172c:	74 c7                	je     8016f5 <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  80172e:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  801735:	00 00 00 
  801738:	48 39 c3             	cmp    %rax,%rbx
  80173b:	77 b8                	ja     8016f5 <fork+0x190>
  80173d:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  801744:	48 39 c3             	cmp    %rax,%rbx
  801747:	74 ac                	je     8016f5 <fork+0x190>
  801749:	48 89 d8             	mov    %rbx,%rax
  80174c:	48 c1 e8 0c          	shr    $0xc,%rax
  801750:	48 89 c1             	mov    %rax,%rcx
  801753:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  801757:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80175e:	01 00 00 
  801761:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801765:	a8 01                	test   $0x1,%al
  801767:	0f 85 ca fe ff ff    	jne    801637 <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  80176d:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801774:	eb 8b                	jmp    801701 <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  801776:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  80177d:	00 00 00 
  801780:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  801787:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  80178a:	48 b8 01 13 80 00 00 	movabs $0x801301,%rax
  801791:	00 00 00 
  801794:	ff d0                	callq  *%rax
  801796:	85 c0                	test   %eax,%eax
  801798:	78 4c                	js     8017e6 <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  80179a:	ba 02 00 00 00       	mov    $0x2,%edx
  80179f:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8017a6:	00 00 00 
  8017a9:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8017ac:	48 b8 77 11 80 00 00 	movabs $0x801177,%rax
  8017b3:	00 00 00 
  8017b6:	ff d0                	callq  *%rax
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 57                	js     801813 <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  8017bc:	be 02 00 00 00       	mov    $0x2,%esi
  8017c1:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8017c4:	48 b8 a1 12 80 00 00 	movabs $0x8012a1,%rax
  8017cb:	00 00 00 
  8017ce:	ff d0                	callq  *%rax
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 6c                	js     801840 <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  8017d4:	8b 45 c0             	mov    -0x40(%rbp),%eax
  8017d7:	48 83 c4 28          	add    $0x28,%rsp
  8017db:	5b                   	pop    %rbx
  8017dc:	41 5c                	pop    %r12
  8017de:	41 5d                	pop    %r13
  8017e0:	41 5e                	pop    %r14
  8017e2:	41 5f                	pop    %r15
  8017e4:	5d                   	pop    %rbp
  8017e5:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  8017e6:	89 c1                	mov    %eax,%ecx
  8017e8:	48 ba 78 1f 80 00 00 	movabs $0x801f78,%rdx
  8017ef:	00 00 00 
  8017f2:	be a7 00 00 00       	mov    $0xa7,%esi
  8017f7:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  8017fe:	00 00 00 
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
  801806:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  80180d:	00 00 00 
  801810:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  801813:	89 c1                	mov    %eax,%ecx
  801815:	48 ba a8 1f 80 00 00 	movabs $0x801fa8,%rdx
  80181c:	00 00 00 
  80181f:	be aa 00 00 00       	mov    $0xaa,%esi
  801824:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  80182b:	00 00 00 
  80182e:	b8 00 00 00 00       	mov    $0x0,%eax
  801833:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  80183a:	00 00 00 
  80183d:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  801840:	89 c1                	mov    %eax,%ecx
  801842:	48 ba c8 1f 80 00 00 	movabs $0x801fc8,%rdx
  801849:	00 00 00 
  80184c:	be bd 00 00 00       	mov    $0xbd,%esi
  801851:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  801858:	00 00 00 
  80185b:	b8 00 00 00 00       	mov    $0x0,%eax
  801860:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  801867:	00 00 00 
  80186a:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  80186d:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801870:	e9 5f ff ff ff       	jmpq   8017d4 <fork+0x26f>

0000000000801875 <sfork>:

// Challenge!
int
sfork(void) {
  801875:	55                   	push   %rbp
  801876:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  801879:	48 ba 07 20 80 00 00 	movabs $0x802007,%rdx
  801880:	00 00 00 
  801883:	be c9 00 00 00       	mov    $0xc9,%esi
  801888:	48 bf ec 1f 80 00 00 	movabs $0x801fec,%rdi
  80188f:	00 00 00 
  801892:	b8 00 00 00 00       	mov    $0x0,%eax
  801897:	48 b9 a3 18 80 00 00 	movabs $0x8018a3,%rcx
  80189e:	00 00 00 
  8018a1:	ff d1                	callq  *%rcx

00000000008018a3 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8018a3:	55                   	push   %rbp
  8018a4:	48 89 e5             	mov    %rsp,%rbp
  8018a7:	41 56                	push   %r14
  8018a9:	41 55                	push   %r13
  8018ab:	41 54                	push   %r12
  8018ad:	53                   	push   %rbx
  8018ae:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8018b5:	49 89 fd             	mov    %rdi,%r13
  8018b8:	41 89 f6             	mov    %esi,%r14d
  8018bb:	49 89 d4             	mov    %rdx,%r12
  8018be:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8018c5:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8018cc:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8018d3:	84 c0                	test   %al,%al
  8018d5:	74 26                	je     8018fd <_panic+0x5a>
  8018d7:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8018de:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8018e5:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8018e9:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8018ed:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8018f1:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8018f5:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8018f9:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8018fd:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801904:	00 00 00 
  801907:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80190e:	00 00 00 
  801911:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801915:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80191c:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801923:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80192a:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  801931:	00 00 00 
  801934:	48 8b 18             	mov    (%rax),%rbx
  801937:	48 b8 37 11 80 00 00 	movabs $0x801137,%rax
  80193e:	00 00 00 
  801941:	ff d0                	callq  *%rax
  801943:	45 89 f0             	mov    %r14d,%r8d
  801946:	4c 89 e9             	mov    %r13,%rcx
  801949:	48 89 da             	mov    %rbx,%rdx
  80194c:	89 c6                	mov    %eax,%esi
  80194e:	48 bf 20 20 80 00 00 	movabs $0x802020,%rdi
  801955:	00 00 00 
  801958:	b8 00 00 00 00       	mov    $0x0,%eax
  80195d:	48 bb a5 02 80 00 00 	movabs $0x8002a5,%rbx
  801964:	00 00 00 
  801967:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801969:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801970:	4c 89 e7             	mov    %r12,%rdi
  801973:	48 b8 3d 02 80 00 00 	movabs $0x80023d,%rax
  80197a:	00 00 00 
  80197d:	ff d0                	callq  *%rax
  cprintf("\n");
  80197f:	48 bf 8f 1a 80 00 00 	movabs $0x801a8f,%rdi
  801986:	00 00 00 
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
  80198e:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801990:	cc                   	int3   
  while (1)
  801991:	eb fd                	jmp    801990 <_panic+0xed>

0000000000801993 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801993:	55                   	push   %rbp
  801994:	48 89 e5             	mov    %rsp,%rbp
  801997:	41 54                	push   %r12
  801999:	53                   	push   %rbx
  80199a:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  80199d:	48 b8 37 11 80 00 00 	movabs $0x801137,%rax
  8019a4:	00 00 00 
  8019a7:	ff d0                	callq  *%rax
  8019a9:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  8019ab:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  8019b2:	00 00 00 
  8019b5:	48 83 38 00          	cmpq   $0x0,(%rax)
  8019b9:	74 2e                	je     8019e9 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  8019bb:	4c 89 e0             	mov    %r12,%rax
  8019be:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  8019c5:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8019c8:	48 be 35 1a 80 00 00 	movabs $0x801a35,%rsi
  8019cf:	00 00 00 
  8019d2:	89 df                	mov    %ebx,%edi
  8019d4:	48 b8 01 13 80 00 00 	movabs $0x801301,%rax
  8019db:	00 00 00 
  8019de:	ff d0                	callq  *%rax
  if (error < 0)
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 24                	js     801a08 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  8019e4:	5b                   	pop    %rbx
  8019e5:	41 5c                	pop    %r12
  8019e7:	5d                   	pop    %rbp
  8019e8:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  8019e9:	ba 02 00 00 00       	mov    $0x2,%edx
  8019ee:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8019f5:	00 00 00 
  8019f8:	89 df                	mov    %ebx,%edi
  8019fa:	48 b8 77 11 80 00 00 	movabs $0x801177,%rax
  801a01:	00 00 00 
  801a04:	ff d0                	callq  *%rax
  801a06:	eb b3                	jmp    8019bb <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801a08:	89 c1                	mov    %eax,%ecx
  801a0a:	48 ba 48 20 80 00 00 	movabs $0x802048,%rdx
  801a11:	00 00 00 
  801a14:	be 2c 00 00 00       	mov    $0x2c,%esi
  801a19:	48 bf 60 20 80 00 00 	movabs $0x802060,%rdi
  801a20:	00 00 00 
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
  801a28:	49 b8 a3 18 80 00 00 	movabs $0x8018a3,%r8
  801a2f:	00 00 00 
  801a32:	41 ff d0             	callq  *%r8

0000000000801a35 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801a35:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801a38:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  801a3f:	00 00 00 
	call *%rax
  801a42:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801a44:	41 5f                	pop    %r15
	popq %r15
  801a46:	41 5f                	pop    %r15
	popq %r15
  801a48:	41 5f                	pop    %r15
	popq %r14
  801a4a:	41 5e                	pop    %r14
	popq %r13
  801a4c:	41 5d                	pop    %r13
	popq %r12
  801a4e:	41 5c                	pop    %r12
	popq %r11
  801a50:	41 5b                	pop    %r11
	popq %r10
  801a52:	41 5a                	pop    %r10
	popq %r9
  801a54:	41 59                	pop    %r9
	popq %r8
  801a56:	41 58                	pop    %r8
	popq %rsi
  801a58:	5e                   	pop    %rsi
	popq %rdi
  801a59:	5f                   	pop    %rdi
	popq %rbp
  801a5a:	5d                   	pop    %rbp
	popq %rdx
  801a5b:	5a                   	pop    %rdx
	popq %rcx
  801a5c:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801a5d:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801a62:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801a67:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801a6b:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801a6e:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801a73:	5b                   	pop    %rbx
	popq %rax
  801a74:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801a75:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801a79:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801a7a:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801a7f:	c3                   	retq   
