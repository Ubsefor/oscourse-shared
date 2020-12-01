
obj/user/fairness:     file format elf64-x86-64


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
  800023:	e8 d1 00 00 00       	callq  8000f9 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// (user/idle is env 0).

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 56                	push   %r14
  800030:	41 55                	push   %r13
  800032:	41 54                	push   %r12
  800034:	53                   	push   %rbx
  800035:	48 83 ec 10          	sub    $0x10,%rsp
  envid_t who, id;

  id = sys_getenvid();
  800039:	48 b8 0a 11 80 00 00 	movabs $0x80110a,%rax
  800040:	00 00 00 
  800043:	ff d0                	callq  *%rax
  800045:	89 c3                	mov    %eax,%ebx

  if (thisenv == &envs[1]) {
  800047:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80004e:	00 00 00 
  800051:	48 b8 20 e1 22 3c 80 	movabs $0x803c22e120,%rax
  800058:	00 00 00 
  80005b:	48 39 02             	cmp    %rax,(%rdx)
  80005e:	74 58                	je     8000b8 <umain+0x8e>
    while (1) {
      ipc_recv(&who, 0, 0);
      cprintf("%x recv from %x\n", id, who);
    }
  } else {
    cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800060:	48 b8 e8 e1 22 3c 80 	movabs $0x803c22e1e8,%rax
  800067:	00 00 00 
  80006a:	8b 10                	mov    (%rax),%edx
  80006c:	89 de                	mov    %ebx,%esi
  80006e:	48 bf 51 16 80 00 00 	movabs $0x801651,%rdi
  800075:	00 00 00 
  800078:	b8 00 00 00 00       	mov    $0x0,%eax
  80007d:	48 b9 78 02 80 00 00 	movabs $0x800278,%rcx
  800084:	00 00 00 
  800087:	ff d1                	callq  *%rcx
    while (1)
      ipc_send(envs[1].env_id, 0, 0, 0);
  800089:	49 bc 00 e0 22 3c 80 	movabs $0x803c22e000,%r12
  800090:	00 00 00 
  800093:	48 bb 36 14 80 00 00 	movabs $0x801436,%rbx
  80009a:	00 00 00 
  80009d:	41 8b bc 24 e8 01 00 	mov    0x1e8(%r12),%edi
  8000a4:	00 
  8000a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000af:	be 00 00 00 00       	mov    $0x0,%esi
  8000b4:	ff d3                	callq  *%rbx
    while (1)
  8000b6:	eb e5                	jmp    80009d <umain+0x73>
      ipc_recv(&who, 0, 0);
  8000b8:	49 be b7 13 80 00 00 	movabs $0x8013b7,%r14
  8000bf:	00 00 00 
      cprintf("%x recv from %x\n", id, who);
  8000c2:	49 bd 40 16 80 00 00 	movabs $0x801640,%r13
  8000c9:	00 00 00 
  8000cc:	49 bc 78 02 80 00 00 	movabs $0x800278,%r12
  8000d3:	00 00 00 
      ipc_recv(&who, 0, 0);
  8000d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000db:	be 00 00 00 00       	mov    $0x0,%esi
  8000e0:	48 8d 7d dc          	lea    -0x24(%rbp),%rdi
  8000e4:	41 ff d6             	callq  *%r14
      cprintf("%x recv from %x\n", id, who);
  8000e7:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8000ea:	89 de                	mov    %ebx,%esi
  8000ec:	4c 89 ef             	mov    %r13,%rdi
  8000ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f4:	41 ff d4             	callq  *%r12
    while (1) {
  8000f7:	eb dd                	jmp    8000d6 <umain+0xac>

00000000008000f9 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  8000f9:	55                   	push   %rbp
  8000fa:	48 89 e5             	mov    %rsp,%rbp
  8000fd:	41 56                	push   %r14
  8000ff:	41 55                	push   %r13
  800101:	41 54                	push   %r12
  800103:	53                   	push   %rbx
  800104:	41 89 fd             	mov    %edi,%r13d
  800107:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80010a:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800111:	00 00 00 
  800114:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80011b:	00 00 00 
  80011e:	48 39 c2             	cmp    %rax,%rdx
  800121:	73 23                	jae    800146 <libmain+0x4d>
  800123:	48 89 d3             	mov    %rdx,%rbx
  800126:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80012a:	48 29 d0             	sub    %rdx,%rax
  80012d:	48 c1 e8 03          	shr    $0x3,%rax
  800131:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800136:	b8 00 00 00 00       	mov    $0x0,%eax
  80013b:	ff 13                	callq  *(%rbx)
    ctor++;
  80013d:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800141:	4c 39 e3             	cmp    %r12,%rbx
  800144:	75 f0                	jne    800136 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800146:	48 b8 0a 11 80 00 00 	movabs $0x80110a,%rax
  80014d:	00 00 00 
  800150:	ff d0                	callq  *%rax
  800152:	25 ff 03 00 00       	and    $0x3ff,%eax
  800157:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80015b:	48 c1 e0 05          	shl    $0x5,%rax
  80015f:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800166:	00 00 00 
  800169:	48 01 d0             	add    %rdx,%rax
  80016c:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  800173:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800176:	45 85 ed             	test   %r13d,%r13d
  800179:	7e 0d                	jle    800188 <libmain+0x8f>
    binaryname = argv[0];
  80017b:	49 8b 06             	mov    (%r14),%rax
  80017e:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800185:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800188:	4c 89 f6             	mov    %r14,%rsi
  80018b:	44 89 ef             	mov    %r13d,%edi
  80018e:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800195:	00 00 00 
  800198:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80019a:	48 b8 af 01 80 00 00 	movabs $0x8001af,%rax
  8001a1:	00 00 00 
  8001a4:	ff d0                	callq  *%rax
#endif
}
  8001a6:	5b                   	pop    %rbx
  8001a7:	41 5c                	pop    %r12
  8001a9:	41 5d                	pop    %r13
  8001ab:	41 5e                	pop    %r14
  8001ad:	5d                   	pop    %rbp
  8001ae:	c3                   	retq   

00000000008001af <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001af:	55                   	push   %rbp
  8001b0:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8001b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8001b8:	48 b8 aa 10 80 00 00 	movabs $0x8010aa,%rax
  8001bf:	00 00 00 
  8001c2:	ff d0                	callq  *%rax
}
  8001c4:	5d                   	pop    %rbp
  8001c5:	c3                   	retq   

00000000008001c6 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8001c6:	55                   	push   %rbp
  8001c7:	48 89 e5             	mov    %rsp,%rbp
  8001ca:	53                   	push   %rbx
  8001cb:	48 83 ec 08          	sub    $0x8,%rsp
  8001cf:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8001d2:	8b 06                	mov    (%rsi),%eax
  8001d4:	8d 50 01             	lea    0x1(%rax),%edx
  8001d7:	89 16                	mov    %edx,(%rsi)
  8001d9:	48 98                	cltq   
  8001db:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8001e0:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8001e6:	74 0b                	je     8001f3 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8001e8:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8001ec:	48 83 c4 08          	add    $0x8,%rsp
  8001f0:	5b                   	pop    %rbx
  8001f1:	5d                   	pop    %rbp
  8001f2:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8001f3:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8001f7:	be ff 00 00 00       	mov    $0xff,%esi
  8001fc:	48 b8 6c 10 80 00 00 	movabs $0x80106c,%rax
  800203:	00 00 00 
  800206:	ff d0                	callq  *%rax
    b->idx = 0;
  800208:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80020e:	eb d8                	jmp    8001e8 <putch+0x22>

0000000000800210 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800210:	55                   	push   %rbp
  800211:	48 89 e5             	mov    %rsp,%rbp
  800214:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80021b:	48 89 fa             	mov    %rdi,%rdx
  80021e:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800221:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800228:	00 00 00 
  b.cnt = 0;
  80022b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800232:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800235:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80023c:	48 bf c6 01 80 00 00 	movabs $0x8001c6,%rdi
  800243:	00 00 00 
  800246:	48 b8 36 04 80 00 00 	movabs $0x800436,%rax
  80024d:	00 00 00 
  800250:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800252:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800259:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800260:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800264:	48 b8 6c 10 80 00 00 	movabs $0x80106c,%rax
  80026b:	00 00 00 
  80026e:	ff d0                	callq  *%rax

  return b.cnt;
}
  800270:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800276:	c9                   	leaveq 
  800277:	c3                   	retq   

0000000000800278 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800278:	55                   	push   %rbp
  800279:	48 89 e5             	mov    %rsp,%rbp
  80027c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800283:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80028a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800291:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800298:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80029f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8002a6:	84 c0                	test   %al,%al
  8002a8:	74 20                	je     8002ca <cprintf+0x52>
  8002aa:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8002ae:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8002b2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8002b6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8002ba:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8002be:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8002c2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8002c6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8002ca:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8002d1:	00 00 00 
  8002d4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8002db:	00 00 00 
  8002de:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002e2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8002e9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8002f0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8002f7:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8002fe:	48 b8 10 02 80 00 00 	movabs $0x800210,%rax
  800305:	00 00 00 
  800308:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80030a:	c9                   	leaveq 
  80030b:	c3                   	retq   

000000000080030c <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80030c:	55                   	push   %rbp
  80030d:	48 89 e5             	mov    %rsp,%rbp
  800310:	41 57                	push   %r15
  800312:	41 56                	push   %r14
  800314:	41 55                	push   %r13
  800316:	41 54                	push   %r12
  800318:	53                   	push   %rbx
  800319:	48 83 ec 18          	sub    $0x18,%rsp
  80031d:	49 89 fc             	mov    %rdi,%r12
  800320:	49 89 f5             	mov    %rsi,%r13
  800323:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800327:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80032a:	41 89 cf             	mov    %ecx,%r15d
  80032d:	49 39 d7             	cmp    %rdx,%r15
  800330:	76 45                	jbe    800377 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800332:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800336:	85 db                	test   %ebx,%ebx
  800338:	7e 0e                	jle    800348 <printnum+0x3c>
      putch(padc, putdat);
  80033a:	4c 89 ee             	mov    %r13,%rsi
  80033d:	44 89 f7             	mov    %r14d,%edi
  800340:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800343:	83 eb 01             	sub    $0x1,%ebx
  800346:	75 f2                	jne    80033a <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800348:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	49 f7 f7             	div    %r15
  800354:	48 b8 72 16 80 00 00 	movabs $0x801672,%rax
  80035b:	00 00 00 
  80035e:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800362:	4c 89 ee             	mov    %r13,%rsi
  800365:	41 ff d4             	callq  *%r12
}
  800368:	48 83 c4 18          	add    $0x18,%rsp
  80036c:	5b                   	pop    %rbx
  80036d:	41 5c                	pop    %r12
  80036f:	41 5d                	pop    %r13
  800371:	41 5e                	pop    %r14
  800373:	41 5f                	pop    %r15
  800375:	5d                   	pop    %rbp
  800376:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800377:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	49 f7 f7             	div    %r15
  800383:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800387:	48 89 c2             	mov    %rax,%rdx
  80038a:	48 b8 0c 03 80 00 00 	movabs $0x80030c,%rax
  800391:	00 00 00 
  800394:	ff d0                	callq  *%rax
  800396:	eb b0                	jmp    800348 <printnum+0x3c>

0000000000800398 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800398:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80039c:	48 8b 06             	mov    (%rsi),%rax
  80039f:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8003a3:	73 0a                	jae    8003af <sprintputch+0x17>
    *b->buf++ = ch;
  8003a5:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8003a9:	48 89 16             	mov    %rdx,(%rsi)
  8003ac:	40 88 38             	mov    %dil,(%rax)
}
  8003af:	c3                   	retq   

00000000008003b0 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8003b0:	55                   	push   %rbp
  8003b1:	48 89 e5             	mov    %rsp,%rbp
  8003b4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003bb:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003c2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003c9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003d0:	84 c0                	test   %al,%al
  8003d2:	74 20                	je     8003f4 <printfmt+0x44>
  8003d4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003d8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003dc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003e0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003e4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003e8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003ec:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003f0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8003f4:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8003fb:	00 00 00 
  8003fe:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800405:	00 00 00 
  800408:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80040c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800413:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80041a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800421:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800428:	48 b8 36 04 80 00 00 	movabs $0x800436,%rax
  80042f:	00 00 00 
  800432:	ff d0                	callq  *%rax
}
  800434:	c9                   	leaveq 
  800435:	c3                   	retq   

0000000000800436 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800436:	55                   	push   %rbp
  800437:	48 89 e5             	mov    %rsp,%rbp
  80043a:	41 57                	push   %r15
  80043c:	41 56                	push   %r14
  80043e:	41 55                	push   %r13
  800440:	41 54                	push   %r12
  800442:	53                   	push   %rbx
  800443:	48 83 ec 48          	sub    $0x48,%rsp
  800447:	49 89 fd             	mov    %rdi,%r13
  80044a:	49 89 f7             	mov    %rsi,%r15
  80044d:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800450:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800454:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800458:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80045c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800460:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800464:	41 0f b6 3e          	movzbl (%r14),%edi
  800468:	83 ff 25             	cmp    $0x25,%edi
  80046b:	74 18                	je     800485 <vprintfmt+0x4f>
      if (ch == '\0')
  80046d:	85 ff                	test   %edi,%edi
  80046f:	0f 84 8c 06 00 00    	je     800b01 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800475:	4c 89 fe             	mov    %r15,%rsi
  800478:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80047b:	49 89 de             	mov    %rbx,%r14
  80047e:	eb e0                	jmp    800460 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800480:	49 89 de             	mov    %rbx,%r14
  800483:	eb db                	jmp    800460 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800485:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800489:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80048d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800494:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80049a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80049e:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8004a3:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8004a9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8004af:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8004b4:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8004b9:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8004bd:	0f b6 13             	movzbl (%rbx),%edx
  8004c0:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8004c3:	3c 55                	cmp    $0x55,%al
  8004c5:	0f 87 8b 05 00 00    	ja     800a56 <vprintfmt+0x620>
  8004cb:	0f b6 c0             	movzbl %al,%eax
  8004ce:	49 bb 40 17 80 00 00 	movabs $0x801740,%r11
  8004d5:	00 00 00 
  8004d8:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8004dc:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8004df:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8004e3:	eb d4                	jmp    8004b9 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004e5:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8004e8:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8004ec:	eb cb                	jmp    8004b9 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004ee:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8004f1:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8004f5:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8004f9:	8d 50 d0             	lea    -0x30(%rax),%edx
  8004fc:	83 fa 09             	cmp    $0x9,%edx
  8004ff:	77 7e                	ja     80057f <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800501:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800505:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800509:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80050e:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800512:	8d 50 d0             	lea    -0x30(%rax),%edx
  800515:	83 fa 09             	cmp    $0x9,%edx
  800518:	76 e7                	jbe    800501 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80051a:	4c 89 f3             	mov    %r14,%rbx
  80051d:	eb 19                	jmp    800538 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80051f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800522:	83 f8 2f             	cmp    $0x2f,%eax
  800525:	77 2a                	ja     800551 <vprintfmt+0x11b>
  800527:	89 c2                	mov    %eax,%edx
  800529:	4c 01 d2             	add    %r10,%rdx
  80052c:	83 c0 08             	add    $0x8,%eax
  80052f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800532:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800535:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800538:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80053c:	0f 89 77 ff ff ff    	jns    8004b9 <vprintfmt+0x83>
          width = precision, precision = -1;
  800542:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800546:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80054c:	e9 68 ff ff ff       	jmpq   8004b9 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800551:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800555:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800559:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80055d:	eb d3                	jmp    800532 <vprintfmt+0xfc>
        if (width < 0)
  80055f:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800562:	85 c0                	test   %eax,%eax
  800564:	41 0f 48 c0          	cmovs  %r8d,%eax
  800568:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80056b:	4c 89 f3             	mov    %r14,%rbx
  80056e:	e9 46 ff ff ff       	jmpq   8004b9 <vprintfmt+0x83>
  800573:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800576:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80057a:	e9 3a ff ff ff       	jmpq   8004b9 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80057f:	4c 89 f3             	mov    %r14,%rbx
  800582:	eb b4                	jmp    800538 <vprintfmt+0x102>
        lflag++;
  800584:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800587:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80058a:	e9 2a ff ff ff       	jmpq   8004b9 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80058f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800592:	83 f8 2f             	cmp    $0x2f,%eax
  800595:	77 19                	ja     8005b0 <vprintfmt+0x17a>
  800597:	89 c2                	mov    %eax,%edx
  800599:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80059d:	83 c0 08             	add    $0x8,%eax
  8005a0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005a3:	4c 89 fe             	mov    %r15,%rsi
  8005a6:	8b 3a                	mov    (%rdx),%edi
  8005a8:	41 ff d5             	callq  *%r13
        break;
  8005ab:	e9 b0 fe ff ff       	jmpq   800460 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8005b0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005b4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005b8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005bc:	eb e5                	jmp    8005a3 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8005be:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005c1:	83 f8 2f             	cmp    $0x2f,%eax
  8005c4:	77 5b                	ja     800621 <vprintfmt+0x1eb>
  8005c6:	89 c2                	mov    %eax,%edx
  8005c8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005cc:	83 c0 08             	add    $0x8,%eax
  8005cf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d2:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8005d4:	89 c8                	mov    %ecx,%eax
  8005d6:	c1 f8 1f             	sar    $0x1f,%eax
  8005d9:	31 c1                	xor    %eax,%ecx
  8005db:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005dd:	83 f9 0b             	cmp    $0xb,%ecx
  8005e0:	7f 4d                	jg     80062f <vprintfmt+0x1f9>
  8005e2:	48 63 c1             	movslq %ecx,%rax
  8005e5:	48 ba 00 1a 80 00 00 	movabs $0x801a00,%rdx
  8005ec:	00 00 00 
  8005ef:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8005f3:	48 85 c0             	test   %rax,%rax
  8005f6:	74 37                	je     80062f <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8005f8:	48 89 c1             	mov    %rax,%rcx
  8005fb:	48 ba 93 16 80 00 00 	movabs $0x801693,%rdx
  800602:	00 00 00 
  800605:	4c 89 fe             	mov    %r15,%rsi
  800608:	4c 89 ef             	mov    %r13,%rdi
  80060b:	b8 00 00 00 00       	mov    $0x0,%eax
  800610:	48 bb b0 03 80 00 00 	movabs $0x8003b0,%rbx
  800617:	00 00 00 
  80061a:	ff d3                	callq  *%rbx
  80061c:	e9 3f fe ff ff       	jmpq   800460 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800621:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800625:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800629:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80062d:	eb a3                	jmp    8005d2 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80062f:	48 ba 8a 16 80 00 00 	movabs $0x80168a,%rdx
  800636:	00 00 00 
  800639:	4c 89 fe             	mov    %r15,%rsi
  80063c:	4c 89 ef             	mov    %r13,%rdi
  80063f:	b8 00 00 00 00       	mov    $0x0,%eax
  800644:	48 bb b0 03 80 00 00 	movabs $0x8003b0,%rbx
  80064b:	00 00 00 
  80064e:	ff d3                	callq  *%rbx
  800650:	e9 0b fe ff ff       	jmpq   800460 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800655:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800658:	83 f8 2f             	cmp    $0x2f,%eax
  80065b:	77 4b                	ja     8006a8 <vprintfmt+0x272>
  80065d:	89 c2                	mov    %eax,%edx
  80065f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800663:	83 c0 08             	add    $0x8,%eax
  800666:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800669:	48 8b 02             	mov    (%rdx),%rax
  80066c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800670:	48 85 c0             	test   %rax,%rax
  800673:	0f 84 05 04 00 00    	je     800a7e <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800679:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80067d:	7e 06                	jle    800685 <vprintfmt+0x24f>
  80067f:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800683:	75 31                	jne    8006b6 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800685:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800689:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80068d:	0f b6 00             	movzbl (%rax),%eax
  800690:	0f be f8             	movsbl %al,%edi
  800693:	85 ff                	test   %edi,%edi
  800695:	0f 84 c3 00 00 00    	je     80075e <vprintfmt+0x328>
  80069b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80069f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8006a3:	e9 85 00 00 00       	jmpq   80072d <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8006a8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006ac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006b0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006b4:	eb b3                	jmp    800669 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8006b6:	49 63 f4             	movslq %r12d,%rsi
  8006b9:	48 89 c7             	mov    %rax,%rdi
  8006bc:	48 b8 0d 0c 80 00 00 	movabs $0x800c0d,%rax
  8006c3:	00 00 00 
  8006c6:	ff d0                	callq  *%rax
  8006c8:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8006cb:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8006ce:	85 f6                	test   %esi,%esi
  8006d0:	7e 22                	jle    8006f4 <vprintfmt+0x2be>
            putch(padc, putdat);
  8006d2:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8006d6:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8006da:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8006de:	4c 89 fe             	mov    %r15,%rsi
  8006e1:	89 df                	mov    %ebx,%edi
  8006e3:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8006e6:	41 83 ec 01          	sub    $0x1,%r12d
  8006ea:	75 f2                	jne    8006de <vprintfmt+0x2a8>
  8006ec:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8006f0:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8006f8:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8006fc:	0f b6 00             	movzbl (%rax),%eax
  8006ff:	0f be f8             	movsbl %al,%edi
  800702:	85 ff                	test   %edi,%edi
  800704:	0f 84 56 fd ff ff    	je     800460 <vprintfmt+0x2a>
  80070a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80070e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800712:	eb 19                	jmp    80072d <vprintfmt+0x2f7>
            putch(ch, putdat);
  800714:	4c 89 fe             	mov    %r15,%rsi
  800717:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	41 83 ee 01          	sub    $0x1,%r14d
  80071e:	48 83 c3 01          	add    $0x1,%rbx
  800722:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800726:	0f be f8             	movsbl %al,%edi
  800729:	85 ff                	test   %edi,%edi
  80072b:	74 29                	je     800756 <vprintfmt+0x320>
  80072d:	45 85 e4             	test   %r12d,%r12d
  800730:	78 06                	js     800738 <vprintfmt+0x302>
  800732:	41 83 ec 01          	sub    $0x1,%r12d
  800736:	78 48                	js     800780 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800738:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80073c:	74 d6                	je     800714 <vprintfmt+0x2de>
  80073e:	0f be c0             	movsbl %al,%eax
  800741:	83 e8 20             	sub    $0x20,%eax
  800744:	83 f8 5e             	cmp    $0x5e,%eax
  800747:	76 cb                	jbe    800714 <vprintfmt+0x2de>
            putch('?', putdat);
  800749:	4c 89 fe             	mov    %r15,%rsi
  80074c:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800751:	41 ff d5             	callq  *%r13
  800754:	eb c4                	jmp    80071a <vprintfmt+0x2e4>
  800756:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80075a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80075e:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800761:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800765:	0f 8e f5 fc ff ff    	jle    800460 <vprintfmt+0x2a>
          putch(' ', putdat);
  80076b:	4c 89 fe             	mov    %r15,%rsi
  80076e:	bf 20 00 00 00       	mov    $0x20,%edi
  800773:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800776:	83 eb 01             	sub    $0x1,%ebx
  800779:	75 f0                	jne    80076b <vprintfmt+0x335>
  80077b:	e9 e0 fc ff ff       	jmpq   800460 <vprintfmt+0x2a>
  800780:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800784:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800788:	eb d4                	jmp    80075e <vprintfmt+0x328>
  if (lflag >= 2)
  80078a:	83 f9 01             	cmp    $0x1,%ecx
  80078d:	7f 1d                	jg     8007ac <vprintfmt+0x376>
  else if (lflag)
  80078f:	85 c9                	test   %ecx,%ecx
  800791:	74 5e                	je     8007f1 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800793:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800796:	83 f8 2f             	cmp    $0x2f,%eax
  800799:	77 48                	ja     8007e3 <vprintfmt+0x3ad>
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a1:	83 c0 08             	add    $0x8,%eax
  8007a4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007a7:	48 8b 1a             	mov    (%rdx),%rbx
  8007aa:	eb 17                	jmp    8007c3 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8007ac:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007af:	83 f8 2f             	cmp    $0x2f,%eax
  8007b2:	77 21                	ja     8007d5 <vprintfmt+0x39f>
  8007b4:	89 c2                	mov    %eax,%edx
  8007b6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ba:	83 c0 08             	add    $0x8,%eax
  8007bd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007c0:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8007c3:	48 85 db             	test   %rbx,%rbx
  8007c6:	78 50                	js     800818 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8007c8:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8007cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d0:	e9 b4 01 00 00       	jmpq   800989 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8007d5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007d9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007dd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e1:	eb dd                	jmp    8007c0 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8007e3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007eb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007ef:	eb b6                	jmp    8007a7 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8007f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007f4:	83 f8 2f             	cmp    $0x2f,%eax
  8007f7:	77 11                	ja     80080a <vprintfmt+0x3d4>
  8007f9:	89 c2                	mov    %eax,%edx
  8007fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ff:	83 c0 08             	add    $0x8,%eax
  800802:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800805:	48 63 1a             	movslq (%rdx),%rbx
  800808:	eb b9                	jmp    8007c3 <vprintfmt+0x38d>
  80080a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80080e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800812:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800816:	eb ed                	jmp    800805 <vprintfmt+0x3cf>
          putch('-', putdat);
  800818:	4c 89 fe             	mov    %r15,%rsi
  80081b:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800820:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800823:	48 89 da             	mov    %rbx,%rdx
  800826:	48 f7 da             	neg    %rdx
        base = 10;
  800829:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082e:	e9 56 01 00 00       	jmpq   800989 <vprintfmt+0x553>
  if (lflag >= 2)
  800833:	83 f9 01             	cmp    $0x1,%ecx
  800836:	7f 25                	jg     80085d <vprintfmt+0x427>
  else if (lflag)
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	74 5e                	je     80089a <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80083c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80083f:	83 f8 2f             	cmp    $0x2f,%eax
  800842:	77 48                	ja     80088c <vprintfmt+0x456>
  800844:	89 c2                	mov    %eax,%edx
  800846:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80084a:	83 c0 08             	add    $0x8,%eax
  80084d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800850:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800853:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800858:	e9 2c 01 00 00       	jmpq   800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80085d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800860:	83 f8 2f             	cmp    $0x2f,%eax
  800863:	77 19                	ja     80087e <vprintfmt+0x448>
  800865:	89 c2                	mov    %eax,%edx
  800867:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80086b:	83 c0 08             	add    $0x8,%eax
  80086e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800871:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800874:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800879:	e9 0b 01 00 00       	jmpq   800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80087e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800882:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800886:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80088a:	eb e5                	jmp    800871 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80088c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800890:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800894:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800898:	eb b6                	jmp    800850 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80089a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089d:	83 f8 2f             	cmp    $0x2f,%eax
  8008a0:	77 18                	ja     8008ba <vprintfmt+0x484>
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a8:	83 c0 08             	add    $0x8,%eax
  8008ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ae:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8008b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008b5:	e9 cf 00 00 00       	jmpq   800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008ba:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008be:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c6:	eb e6                	jmp    8008ae <vprintfmt+0x478>
  if (lflag >= 2)
  8008c8:	83 f9 01             	cmp    $0x1,%ecx
  8008cb:	7f 25                	jg     8008f2 <vprintfmt+0x4bc>
  else if (lflag)
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	74 5b                	je     80092c <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8008d1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d4:	83 f8 2f             	cmp    $0x2f,%eax
  8008d7:	77 45                	ja     80091e <vprintfmt+0x4e8>
  8008d9:	89 c2                	mov    %eax,%edx
  8008db:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008df:	83 c0 08             	add    $0x8,%eax
  8008e2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008e5:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8008e8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008ed:	e9 97 00 00 00       	jmpq   800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008f2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f5:	83 f8 2f             	cmp    $0x2f,%eax
  8008f8:	77 16                	ja     800910 <vprintfmt+0x4da>
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800900:	83 c0 08             	add    $0x8,%eax
  800903:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800906:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800909:	b9 08 00 00 00       	mov    $0x8,%ecx
  80090e:	eb 79                	jmp    800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800910:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800914:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800918:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091c:	eb e8                	jmp    800906 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80091e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800922:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800926:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80092a:	eb b9                	jmp    8008e5 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  80092c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092f:	83 f8 2f             	cmp    $0x2f,%eax
  800932:	77 15                	ja     800949 <vprintfmt+0x513>
  800934:	89 c2                	mov    %eax,%edx
  800936:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093a:	83 c0 08             	add    $0x8,%eax
  80093d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800940:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800942:	b9 08 00 00 00       	mov    $0x8,%ecx
  800947:	eb 40                	jmp    800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800949:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800951:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800955:	eb e9                	jmp    800940 <vprintfmt+0x50a>
        putch('0', putdat);
  800957:	4c 89 fe             	mov    %r15,%rsi
  80095a:	bf 30 00 00 00       	mov    $0x30,%edi
  80095f:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800962:	4c 89 fe             	mov    %r15,%rsi
  800965:	bf 78 00 00 00       	mov    $0x78,%edi
  80096a:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80096d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800970:	83 f8 2f             	cmp    $0x2f,%eax
  800973:	77 34                	ja     8009a9 <vprintfmt+0x573>
  800975:	89 c2                	mov    %eax,%edx
  800977:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80097b:	83 c0 08             	add    $0x8,%eax
  80097e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800981:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800984:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800989:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  80098e:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800992:	4c 89 fe             	mov    %r15,%rsi
  800995:	4c 89 ef             	mov    %r13,%rdi
  800998:	48 b8 0c 03 80 00 00 	movabs $0x80030c,%rax
  80099f:	00 00 00 
  8009a2:	ff d0                	callq  *%rax
        break;
  8009a4:	e9 b7 fa ff ff       	jmpq   800460 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8009a9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ad:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b5:	eb ca                	jmp    800981 <vprintfmt+0x54b>
  if (lflag >= 2)
  8009b7:	83 f9 01             	cmp    $0x1,%ecx
  8009ba:	7f 22                	jg     8009de <vprintfmt+0x5a8>
  else if (lflag)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 58                	je     800a18 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8009c0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c3:	83 f8 2f             	cmp    $0x2f,%eax
  8009c6:	77 42                	ja     800a0a <vprintfmt+0x5d4>
  8009c8:	89 c2                	mov    %eax,%edx
  8009ca:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ce:	83 c0 08             	add    $0x8,%eax
  8009d1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009d7:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009dc:	eb ab                	jmp    800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009de:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e1:	83 f8 2f             	cmp    $0x2f,%eax
  8009e4:	77 16                	ja     8009fc <vprintfmt+0x5c6>
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ec:	83 c0 08             	add    $0x8,%eax
  8009ef:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f2:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009f5:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009fa:	eb 8d                	jmp    800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009fc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a00:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a04:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a08:	eb e8                	jmp    8009f2 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800a0a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a0e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a12:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a16:	eb bc                	jmp    8009d4 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800a18:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a1b:	83 f8 2f             	cmp    $0x2f,%eax
  800a1e:	77 18                	ja     800a38 <vprintfmt+0x602>
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a26:	83 c0 08             	add    $0x8,%eax
  800a29:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a2c:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800a2e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a33:	e9 51 ff ff ff       	jmpq   800989 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a38:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a3c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a40:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a44:	eb e6                	jmp    800a2c <vprintfmt+0x5f6>
        putch(ch, putdat);
  800a46:	4c 89 fe             	mov    %r15,%rsi
  800a49:	bf 25 00 00 00       	mov    $0x25,%edi
  800a4e:	41 ff d5             	callq  *%r13
        break;
  800a51:	e9 0a fa ff ff       	jmpq   800460 <vprintfmt+0x2a>
        putch('%', putdat);
  800a56:	4c 89 fe             	mov    %r15,%rsi
  800a59:	bf 25 00 00 00       	mov    $0x25,%edi
  800a5e:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800a61:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800a65:	0f 84 15 fa ff ff    	je     800480 <vprintfmt+0x4a>
  800a6b:	49 89 de             	mov    %rbx,%r14
  800a6e:	49 83 ee 01          	sub    $0x1,%r14
  800a72:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800a77:	75 f5                	jne    800a6e <vprintfmt+0x638>
  800a79:	e9 e2 f9 ff ff       	jmpq   800460 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800a7e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a82:	74 06                	je     800a8a <vprintfmt+0x654>
  800a84:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a88:	7f 21                	jg     800aab <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8a:	bf 28 00 00 00       	mov    $0x28,%edi
  800a8f:	48 bb 84 16 80 00 00 	movabs $0x801684,%rbx
  800a96:	00 00 00 
  800a99:	b8 28 00 00 00       	mov    $0x28,%eax
  800a9e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800aa2:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800aa6:	e9 82 fc ff ff       	jmpq   80072d <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800aab:	49 63 f4             	movslq %r12d,%rsi
  800aae:	48 bf 83 16 80 00 00 	movabs $0x801683,%rdi
  800ab5:	00 00 00 
  800ab8:	48 b8 0d 0c 80 00 00 	movabs $0x800c0d,%rax
  800abf:	00 00 00 
  800ac2:	ff d0                	callq  *%rax
  800ac4:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800ac7:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800aca:	48 be 83 16 80 00 00 	movabs $0x801683,%rsi
  800ad1:	00 00 00 
  800ad4:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	0f 8f f2 fb ff ff    	jg     8006d2 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ae0:	48 bb 84 16 80 00 00 	movabs $0x801684,%rbx
  800ae7:	00 00 00 
  800aea:	b8 28 00 00 00       	mov    $0x28,%eax
  800aef:	bf 28 00 00 00       	mov    $0x28,%edi
  800af4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800af8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800afc:	e9 2c fc ff ff       	jmpq   80072d <vprintfmt+0x2f7>
}
  800b01:	48 83 c4 48          	add    $0x48,%rsp
  800b05:	5b                   	pop    %rbx
  800b06:	41 5c                	pop    %r12
  800b08:	41 5d                	pop    %r13
  800b0a:	41 5e                	pop    %r14
  800b0c:	41 5f                	pop    %r15
  800b0e:	5d                   	pop    %rbp
  800b0f:	c3                   	retq   

0000000000800b10 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800b10:	55                   	push   %rbp
  800b11:	48 89 e5             	mov    %rsp,%rbp
  800b14:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800b18:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800b1c:	48 63 c6             	movslq %esi,%rax
  800b1f:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800b24:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800b28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800b2f:	48 85 ff             	test   %rdi,%rdi
  800b32:	74 2a                	je     800b5e <vsnprintf+0x4e>
  800b34:	85 f6                	test   %esi,%esi
  800b36:	7e 26                	jle    800b5e <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800b38:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800b3c:	48 bf 98 03 80 00 00 	movabs $0x800398,%rdi
  800b43:	00 00 00 
  800b46:	48 b8 36 04 80 00 00 	movabs $0x800436,%rax
  800b4d:	00 00 00 
  800b50:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800b52:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800b56:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800b59:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800b5c:	c9                   	leaveq 
  800b5d:	c3                   	retq   
    return -E_INVAL;
  800b5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b63:	eb f7                	jmp    800b5c <vsnprintf+0x4c>

0000000000800b65 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800b65:	55                   	push   %rbp
  800b66:	48 89 e5             	mov    %rsp,%rbp
  800b69:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800b70:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800b77:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800b7e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800b85:	84 c0                	test   %al,%al
  800b87:	74 20                	je     800ba9 <snprintf+0x44>
  800b89:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800b8d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800b91:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b95:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b99:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b9d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ba1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ba5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ba9:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800bb0:	00 00 00 
  800bb3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800bba:	00 00 00 
  800bbd:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800bc1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800bc8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800bcf:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800bd6:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800bdd:	48 b8 10 0b 80 00 00 	movabs $0x800b10,%rax
  800be4:	00 00 00 
  800be7:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800be9:	c9                   	leaveq 
  800bea:	c3                   	retq   

0000000000800beb <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800beb:	80 3f 00             	cmpb   $0x0,(%rdi)
  800bee:	74 17                	je     800c07 <strlen+0x1c>
  800bf0:	48 89 fa             	mov    %rdi,%rdx
  800bf3:	b9 01 00 00 00       	mov    $0x1,%ecx
  800bf8:	29 f9                	sub    %edi,%ecx
    n++;
  800bfa:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800bfd:	48 83 c2 01          	add    $0x1,%rdx
  800c01:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c04:	75 f4                	jne    800bfa <strlen+0xf>
  800c06:	c3                   	retq   
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c0c:	c3                   	retq   

0000000000800c0d <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c0d:	48 85 f6             	test   %rsi,%rsi
  800c10:	74 24                	je     800c36 <strnlen+0x29>
  800c12:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c15:	74 25                	je     800c3c <strnlen+0x2f>
  800c17:	48 01 fe             	add    %rdi,%rsi
  800c1a:	48 89 fa             	mov    %rdi,%rdx
  800c1d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c22:	29 f9                	sub    %edi,%ecx
    n++;
  800c24:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c27:	48 83 c2 01          	add    $0x1,%rdx
  800c2b:	48 39 f2             	cmp    %rsi,%rdx
  800c2e:	74 11                	je     800c41 <strnlen+0x34>
  800c30:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c33:	75 ef                	jne    800c24 <strnlen+0x17>
  800c35:	c3                   	retq   
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3b:	c3                   	retq   
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c41:	c3                   	retq   

0000000000800c42 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800c42:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800c45:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4a:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800c4e:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800c51:	48 83 c2 01          	add    $0x1,%rdx
  800c55:	84 c9                	test   %cl,%cl
  800c57:	75 f1                	jne    800c4a <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800c59:	c3                   	retq   

0000000000800c5a <strcat>:

char *
strcat(char *dst, const char *src) {
  800c5a:	55                   	push   %rbp
  800c5b:	48 89 e5             	mov    %rsp,%rbp
  800c5e:	41 54                	push   %r12
  800c60:	53                   	push   %rbx
  800c61:	48 89 fb             	mov    %rdi,%rbx
  800c64:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800c67:	48 b8 eb 0b 80 00 00 	movabs $0x800beb,%rax
  800c6e:	00 00 00 
  800c71:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800c73:	48 63 f8             	movslq %eax,%rdi
  800c76:	48 01 df             	add    %rbx,%rdi
  800c79:	4c 89 e6             	mov    %r12,%rsi
  800c7c:	48 b8 42 0c 80 00 00 	movabs $0x800c42,%rax
  800c83:	00 00 00 
  800c86:	ff d0                	callq  *%rax
  return dst;
}
  800c88:	48 89 d8             	mov    %rbx,%rax
  800c8b:	5b                   	pop    %rbx
  800c8c:	41 5c                	pop    %r12
  800c8e:	5d                   	pop    %rbp
  800c8f:	c3                   	retq   

0000000000800c90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c90:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c93:	48 85 d2             	test   %rdx,%rdx
  800c96:	74 1f                	je     800cb7 <strncpy+0x27>
  800c98:	48 01 fa             	add    %rdi,%rdx
  800c9b:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c9e:	48 83 c1 01          	add    $0x1,%rcx
  800ca2:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ca6:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800caa:	41 80 f8 01          	cmp    $0x1,%r8b
  800cae:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800cb2:	48 39 ca             	cmp    %rcx,%rdx
  800cb5:	75 e7                	jne    800c9e <strncpy+0xe>
  }
  return ret;
}
  800cb7:	c3                   	retq   

0000000000800cb8 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800cb8:	48 89 f8             	mov    %rdi,%rax
  800cbb:	48 85 d2             	test   %rdx,%rdx
  800cbe:	74 36                	je     800cf6 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800cc0:	48 83 fa 01          	cmp    $0x1,%rdx
  800cc4:	74 2d                	je     800cf3 <strlcpy+0x3b>
  800cc6:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cca:	45 84 c0             	test   %r8b,%r8b
  800ccd:	74 24                	je     800cf3 <strlcpy+0x3b>
  800ccf:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800cd3:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800cd8:	48 83 c0 01          	add    $0x1,%rax
  800cdc:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800ce0:	48 39 d1             	cmp    %rdx,%rcx
  800ce3:	74 0e                	je     800cf3 <strlcpy+0x3b>
  800ce5:	48 83 c1 01          	add    $0x1,%rcx
  800ce9:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800cee:	45 84 c0             	test   %r8b,%r8b
  800cf1:	75 e5                	jne    800cd8 <strlcpy+0x20>
    *dst = '\0';
  800cf3:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800cf6:	48 29 f8             	sub    %rdi,%rax
}
  800cf9:	c3                   	retq   

0000000000800cfa <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800cfa:	0f b6 07             	movzbl (%rdi),%eax
  800cfd:	84 c0                	test   %al,%al
  800cff:	74 17                	je     800d18 <strcmp+0x1e>
  800d01:	3a 06                	cmp    (%rsi),%al
  800d03:	75 13                	jne    800d18 <strcmp+0x1e>
    p++, q++;
  800d05:	48 83 c7 01          	add    $0x1,%rdi
  800d09:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800d0d:	0f b6 07             	movzbl (%rdi),%eax
  800d10:	84 c0                	test   %al,%al
  800d12:	74 04                	je     800d18 <strcmp+0x1e>
  800d14:	3a 06                	cmp    (%rsi),%al
  800d16:	74 ed                	je     800d05 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800d18:	0f b6 c0             	movzbl %al,%eax
  800d1b:	0f b6 16             	movzbl (%rsi),%edx
  800d1e:	29 d0                	sub    %edx,%eax
}
  800d20:	c3                   	retq   

0000000000800d21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800d21:	48 85 d2             	test   %rdx,%rdx
  800d24:	74 2f                	je     800d55 <strncmp+0x34>
  800d26:	0f b6 07             	movzbl (%rdi),%eax
  800d29:	84 c0                	test   %al,%al
  800d2b:	74 1f                	je     800d4c <strncmp+0x2b>
  800d2d:	3a 06                	cmp    (%rsi),%al
  800d2f:	75 1b                	jne    800d4c <strncmp+0x2b>
  800d31:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800d34:	48 83 c7 01          	add    $0x1,%rdi
  800d38:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800d3c:	48 39 d7             	cmp    %rdx,%rdi
  800d3f:	74 1a                	je     800d5b <strncmp+0x3a>
  800d41:	0f b6 07             	movzbl (%rdi),%eax
  800d44:	84 c0                	test   %al,%al
  800d46:	74 04                	je     800d4c <strncmp+0x2b>
  800d48:	3a 06                	cmp    (%rsi),%al
  800d4a:	74 e8                	je     800d34 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800d4c:	0f b6 07             	movzbl (%rdi),%eax
  800d4f:	0f b6 16             	movzbl (%rsi),%edx
  800d52:	29 d0                	sub    %edx,%eax
}
  800d54:	c3                   	retq   
    return 0;
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5a:	c3                   	retq   
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d60:	c3                   	retq   

0000000000800d61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800d61:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800d63:	0f b6 07             	movzbl (%rdi),%eax
  800d66:	84 c0                	test   %al,%al
  800d68:	74 1e                	je     800d88 <strchr+0x27>
    if (*s == c)
  800d6a:	40 38 c6             	cmp    %al,%sil
  800d6d:	74 1f                	je     800d8e <strchr+0x2d>
  for (; *s; s++)
  800d6f:	48 83 c7 01          	add    $0x1,%rdi
  800d73:	0f b6 07             	movzbl (%rdi),%eax
  800d76:	84 c0                	test   %al,%al
  800d78:	74 08                	je     800d82 <strchr+0x21>
    if (*s == c)
  800d7a:	38 d0                	cmp    %dl,%al
  800d7c:	75 f1                	jne    800d6f <strchr+0xe>
  for (; *s; s++)
  800d7e:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800d81:	c3                   	retq   
  return 0;
  800d82:	b8 00 00 00 00       	mov    $0x0,%eax
  800d87:	c3                   	retq   
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8d:	c3                   	retq   
    if (*s == c)
  800d8e:	48 89 f8             	mov    %rdi,%rax
  800d91:	c3                   	retq   

0000000000800d92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800d92:	48 89 f8             	mov    %rdi,%rax
  800d95:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d97:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d9a:	40 38 f2             	cmp    %sil,%dl
  800d9d:	74 13                	je     800db2 <strfind+0x20>
  800d9f:	84 d2                	test   %dl,%dl
  800da1:	74 0f                	je     800db2 <strfind+0x20>
  for (; *s; s++)
  800da3:	48 83 c0 01          	add    $0x1,%rax
  800da7:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800daa:	38 ca                	cmp    %cl,%dl
  800dac:	74 04                	je     800db2 <strfind+0x20>
  800dae:	84 d2                	test   %dl,%dl
  800db0:	75 f1                	jne    800da3 <strfind+0x11>
      break;
  return (char *)s;
}
  800db2:	c3                   	retq   

0000000000800db3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800db3:	48 85 d2             	test   %rdx,%rdx
  800db6:	74 3a                	je     800df2 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800db8:	48 89 f8             	mov    %rdi,%rax
  800dbb:	48 09 d0             	or     %rdx,%rax
  800dbe:	a8 03                	test   $0x3,%al
  800dc0:	75 28                	jne    800dea <memset+0x37>
    uint32_t k = c & 0xFFU;
  800dc2:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800dc6:	89 f0                	mov    %esi,%eax
  800dc8:	c1 e0 08             	shl    $0x8,%eax
  800dcb:	89 f1                	mov    %esi,%ecx
  800dcd:	c1 e1 18             	shl    $0x18,%ecx
  800dd0:	41 89 f0             	mov    %esi,%r8d
  800dd3:	41 c1 e0 10          	shl    $0x10,%r8d
  800dd7:	44 09 c1             	or     %r8d,%ecx
  800dda:	09 ce                	or     %ecx,%esi
  800ddc:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800dde:	48 c1 ea 02          	shr    $0x2,%rdx
  800de2:	48 89 d1             	mov    %rdx,%rcx
  800de5:	fc                   	cld    
  800de6:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800de8:	eb 08                	jmp    800df2 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800dea:	89 f0                	mov    %esi,%eax
  800dec:	48 89 d1             	mov    %rdx,%rcx
  800def:	fc                   	cld    
  800df0:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800df2:	48 89 f8             	mov    %rdi,%rax
  800df5:	c3                   	retq   

0000000000800df6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800df6:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800df9:	48 39 fe             	cmp    %rdi,%rsi
  800dfc:	73 40                	jae    800e3e <memmove+0x48>
  800dfe:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800e02:	48 39 f9             	cmp    %rdi,%rcx
  800e05:	76 37                	jbe    800e3e <memmove+0x48>
    s += n;
    d += n;
  800e07:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e0b:	48 89 fe             	mov    %rdi,%rsi
  800e0e:	48 09 d6             	or     %rdx,%rsi
  800e11:	48 09 ce             	or     %rcx,%rsi
  800e14:	40 f6 c6 03          	test   $0x3,%sil
  800e18:	75 14                	jne    800e2e <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800e1a:	48 83 ef 04          	sub    $0x4,%rdi
  800e1e:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800e22:	48 c1 ea 02          	shr    $0x2,%rdx
  800e26:	48 89 d1             	mov    %rdx,%rcx
  800e29:	fd                   	std    
  800e2a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e2c:	eb 0e                	jmp    800e3c <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800e2e:	48 83 ef 01          	sub    $0x1,%rdi
  800e32:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800e36:	48 89 d1             	mov    %rdx,%rcx
  800e39:	fd                   	std    
  800e3a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800e3c:	fc                   	cld    
  800e3d:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e3e:	48 89 c1             	mov    %rax,%rcx
  800e41:	48 09 d1             	or     %rdx,%rcx
  800e44:	48 09 f1             	or     %rsi,%rcx
  800e47:	f6 c1 03             	test   $0x3,%cl
  800e4a:	75 0e                	jne    800e5a <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800e4c:	48 c1 ea 02          	shr    $0x2,%rdx
  800e50:	48 89 d1             	mov    %rdx,%rcx
  800e53:	48 89 c7             	mov    %rax,%rdi
  800e56:	fc                   	cld    
  800e57:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e59:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800e5a:	48 89 c7             	mov    %rax,%rdi
  800e5d:	48 89 d1             	mov    %rdx,%rcx
  800e60:	fc                   	cld    
  800e61:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800e63:	c3                   	retq   

0000000000800e64 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800e64:	55                   	push   %rbp
  800e65:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800e68:	48 b8 f6 0d 80 00 00 	movabs $0x800df6,%rax
  800e6f:	00 00 00 
  800e72:	ff d0                	callq  *%rax
}
  800e74:	5d                   	pop    %rbp
  800e75:	c3                   	retq   

0000000000800e76 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800e76:	55                   	push   %rbp
  800e77:	48 89 e5             	mov    %rsp,%rbp
  800e7a:	41 57                	push   %r15
  800e7c:	41 56                	push   %r14
  800e7e:	41 55                	push   %r13
  800e80:	41 54                	push   %r12
  800e82:	53                   	push   %rbx
  800e83:	48 83 ec 08          	sub    $0x8,%rsp
  800e87:	49 89 fe             	mov    %rdi,%r14
  800e8a:	49 89 f7             	mov    %rsi,%r15
  800e8d:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800e90:	48 89 f7             	mov    %rsi,%rdi
  800e93:	48 b8 eb 0b 80 00 00 	movabs $0x800beb,%rax
  800e9a:	00 00 00 
  800e9d:	ff d0                	callq  *%rax
  800e9f:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800ea2:	4c 89 ee             	mov    %r13,%rsi
  800ea5:	4c 89 f7             	mov    %r14,%rdi
  800ea8:	48 b8 0d 0c 80 00 00 	movabs $0x800c0d,%rax
  800eaf:	00 00 00 
  800eb2:	ff d0                	callq  *%rax
  800eb4:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800eb7:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800ebb:	4d 39 e5             	cmp    %r12,%r13
  800ebe:	74 26                	je     800ee6 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800ec0:	4c 89 e8             	mov    %r13,%rax
  800ec3:	4c 29 e0             	sub    %r12,%rax
  800ec6:	48 39 d8             	cmp    %rbx,%rax
  800ec9:	76 2a                	jbe    800ef5 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800ecb:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800ecf:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ed3:	4c 89 fe             	mov    %r15,%rsi
  800ed6:	48 b8 64 0e 80 00 00 	movabs $0x800e64,%rax
  800edd:	00 00 00 
  800ee0:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800ee2:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800ee6:	48 83 c4 08          	add    $0x8,%rsp
  800eea:	5b                   	pop    %rbx
  800eeb:	41 5c                	pop    %r12
  800eed:	41 5d                	pop    %r13
  800eef:	41 5e                	pop    %r14
  800ef1:	41 5f                	pop    %r15
  800ef3:	5d                   	pop    %rbp
  800ef4:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800ef5:	49 83 ed 01          	sub    $0x1,%r13
  800ef9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800efd:	4c 89 ea             	mov    %r13,%rdx
  800f00:	4c 89 fe             	mov    %r15,%rsi
  800f03:	48 b8 64 0e 80 00 00 	movabs $0x800e64,%rax
  800f0a:	00 00 00 
  800f0d:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800f0f:	4d 01 ee             	add    %r13,%r14
  800f12:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800f17:	eb c9                	jmp    800ee2 <strlcat+0x6c>

0000000000800f19 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800f19:	48 85 d2             	test   %rdx,%rdx
  800f1c:	74 3a                	je     800f58 <memcmp+0x3f>
    if (*s1 != *s2)
  800f1e:	0f b6 0f             	movzbl (%rdi),%ecx
  800f21:	44 0f b6 06          	movzbl (%rsi),%r8d
  800f25:	44 38 c1             	cmp    %r8b,%cl
  800f28:	75 1d                	jne    800f47 <memcmp+0x2e>
  800f2a:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800f2f:	48 39 d0             	cmp    %rdx,%rax
  800f32:	74 1e                	je     800f52 <memcmp+0x39>
    if (*s1 != *s2)
  800f34:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800f38:	48 83 c0 01          	add    $0x1,%rax
  800f3c:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800f42:	44 38 c1             	cmp    %r8b,%cl
  800f45:	74 e8                	je     800f2f <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800f47:	0f b6 c1             	movzbl %cl,%eax
  800f4a:	45 0f b6 c0          	movzbl %r8b,%r8d
  800f4e:	44 29 c0             	sub    %r8d,%eax
  800f51:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
  800f57:	c3                   	retq   
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f5d:	c3                   	retq   

0000000000800f5e <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800f5e:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800f62:	48 39 c7             	cmp    %rax,%rdi
  800f65:	73 19                	jae    800f80 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f67:	89 f2                	mov    %esi,%edx
  800f69:	40 38 37             	cmp    %sil,(%rdi)
  800f6c:	74 16                	je     800f84 <memfind+0x26>
  for (; s < ends; s++)
  800f6e:	48 83 c7 01          	add    $0x1,%rdi
  800f72:	48 39 f8             	cmp    %rdi,%rax
  800f75:	74 08                	je     800f7f <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f77:	38 17                	cmp    %dl,(%rdi)
  800f79:	75 f3                	jne    800f6e <memfind+0x10>
  for (; s < ends; s++)
  800f7b:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800f7e:	c3                   	retq   
  800f7f:	c3                   	retq   
  for (; s < ends; s++)
  800f80:	48 89 f8             	mov    %rdi,%rax
  800f83:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800f84:	48 89 f8             	mov    %rdi,%rax
  800f87:	c3                   	retq   

0000000000800f88 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f88:	0f b6 07             	movzbl (%rdi),%eax
  800f8b:	3c 20                	cmp    $0x20,%al
  800f8d:	74 04                	je     800f93 <strtol+0xb>
  800f8f:	3c 09                	cmp    $0x9,%al
  800f91:	75 0f                	jne    800fa2 <strtol+0x1a>
    s++;
  800f93:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f97:	0f b6 07             	movzbl (%rdi),%eax
  800f9a:	3c 20                	cmp    $0x20,%al
  800f9c:	74 f5                	je     800f93 <strtol+0xb>
  800f9e:	3c 09                	cmp    $0x9,%al
  800fa0:	74 f1                	je     800f93 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800fa2:	3c 2b                	cmp    $0x2b,%al
  800fa4:	74 2b                	je     800fd1 <strtol+0x49>
  int neg  = 0;
  800fa6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800fac:	3c 2d                	cmp    $0x2d,%al
  800fae:	74 2d                	je     800fdd <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fb0:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800fb6:	75 0f                	jne    800fc7 <strtol+0x3f>
  800fb8:	80 3f 30             	cmpb   $0x30,(%rdi)
  800fbb:	74 2c                	je     800fe9 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800fbd:	85 d2                	test   %edx,%edx
  800fbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc4:	0f 44 d0             	cmove  %eax,%edx
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800fcc:	4c 63 d2             	movslq %edx,%r10
  800fcf:	eb 5c                	jmp    80102d <strtol+0xa5>
    s++;
  800fd1:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800fd5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800fdb:	eb d3                	jmp    800fb0 <strtol+0x28>
    s++, neg = 1;
  800fdd:	48 83 c7 01          	add    $0x1,%rdi
  800fe1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800fe7:	eb c7                	jmp    800fb0 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe9:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800fed:	74 0f                	je     800ffe <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800fef:	85 d2                	test   %edx,%edx
  800ff1:	75 d4                	jne    800fc7 <strtol+0x3f>
    s++, base = 8;
  800ff3:	48 83 c7 01          	add    $0x1,%rdi
  800ff7:	ba 08 00 00 00       	mov    $0x8,%edx
  800ffc:	eb c9                	jmp    800fc7 <strtol+0x3f>
    s += 2, base = 16;
  800ffe:	48 83 c7 02          	add    $0x2,%rdi
  801002:	ba 10 00 00 00       	mov    $0x10,%edx
  801007:	eb be                	jmp    800fc7 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801009:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80100d:	41 80 f8 19          	cmp    $0x19,%r8b
  801011:	77 2f                	ja     801042 <strtol+0xba>
      dig = *s - 'a' + 10;
  801013:	44 0f be c1          	movsbl %cl,%r8d
  801017:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80101b:	39 d1                	cmp    %edx,%ecx
  80101d:	7d 37                	jge    801056 <strtol+0xce>
    s++, val = (val * base) + dig;
  80101f:	48 83 c7 01          	add    $0x1,%rdi
  801023:	49 0f af c2          	imul   %r10,%rax
  801027:	48 63 c9             	movslq %ecx,%rcx
  80102a:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80102d:	0f b6 0f             	movzbl (%rdi),%ecx
  801030:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801034:	41 80 f8 09          	cmp    $0x9,%r8b
  801038:	77 cf                	ja     801009 <strtol+0x81>
      dig = *s - '0';
  80103a:	0f be c9             	movsbl %cl,%ecx
  80103d:	83 e9 30             	sub    $0x30,%ecx
  801040:	eb d9                	jmp    80101b <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801042:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801046:	41 80 f8 19          	cmp    $0x19,%r8b
  80104a:	77 0a                	ja     801056 <strtol+0xce>
      dig = *s - 'A' + 10;
  80104c:	44 0f be c1          	movsbl %cl,%r8d
  801050:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801054:	eb c5                	jmp    80101b <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801056:	48 85 f6             	test   %rsi,%rsi
  801059:	74 03                	je     80105e <strtol+0xd6>
    *endptr = (char *)s;
  80105b:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80105e:	48 89 c2             	mov    %rax,%rdx
  801061:	48 f7 da             	neg    %rdx
  801064:	45 85 c9             	test   %r9d,%r9d
  801067:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80106b:	c3                   	retq   

000000000080106c <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80106c:	55                   	push   %rbp
  80106d:	48 89 e5             	mov    %rsp,%rbp
  801070:	53                   	push   %rbx
  801071:	48 89 fa             	mov    %rdi,%rdx
  801074:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801077:	b8 00 00 00 00       	mov    $0x0,%eax
  80107c:	48 89 c3             	mov    %rax,%rbx
  80107f:	48 89 c7             	mov    %rax,%rdi
  801082:	48 89 c6             	mov    %rax,%rsi
  801085:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801087:	5b                   	pop    %rbx
  801088:	5d                   	pop    %rbp
  801089:	c3                   	retq   

000000000080108a <sys_cgetc>:

int
sys_cgetc(void) {
  80108a:	55                   	push   %rbp
  80108b:	48 89 e5             	mov    %rsp,%rbp
  80108e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80108f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801094:	b8 01 00 00 00       	mov    $0x1,%eax
  801099:	48 89 ca             	mov    %rcx,%rdx
  80109c:	48 89 cb             	mov    %rcx,%rbx
  80109f:	48 89 cf             	mov    %rcx,%rdi
  8010a2:	48 89 ce             	mov    %rcx,%rsi
  8010a5:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010a7:	5b                   	pop    %rbx
  8010a8:	5d                   	pop    %rbp
  8010a9:	c3                   	retq   

00000000008010aa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8010aa:	55                   	push   %rbp
  8010ab:	48 89 e5             	mov    %rsp,%rbp
  8010ae:	53                   	push   %rbx
  8010af:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010b3:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8010b6:	be 00 00 00 00       	mov    $0x0,%esi
  8010bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c0:	48 89 f1             	mov    %rsi,%rcx
  8010c3:	48 89 f3             	mov    %rsi,%rbx
  8010c6:	48 89 f7             	mov    %rsi,%rdi
  8010c9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010cb:	48 85 c0             	test   %rax,%rax
  8010ce:	7f 07                	jg     8010d7 <sys_env_destroy+0x2d>
}
  8010d0:	48 83 c4 08          	add    $0x8,%rsp
  8010d4:	5b                   	pop    %rbx
  8010d5:	5d                   	pop    %rbp
  8010d6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010d7:	49 89 c0             	mov    %rax,%r8
  8010da:	b9 03 00 00 00       	mov    $0x3,%ecx
  8010df:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  8010e6:	00 00 00 
  8010e9:	be 22 00 00 00       	mov    $0x22,%esi
  8010ee:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  8010f5:	00 00 00 
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  801104:	00 00 00 
  801107:	41 ff d1             	callq  *%r9

000000000080110a <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80110a:	55                   	push   %rbp
  80110b:	48 89 e5             	mov    %rsp,%rbp
  80110e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80110f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801114:	b8 02 00 00 00       	mov    $0x2,%eax
  801119:	48 89 ca             	mov    %rcx,%rdx
  80111c:	48 89 cb             	mov    %rcx,%rbx
  80111f:	48 89 cf             	mov    %rcx,%rdi
  801122:	48 89 ce             	mov    %rcx,%rsi
  801125:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801127:	5b                   	pop    %rbx
  801128:	5d                   	pop    %rbp
  801129:	c3                   	retq   

000000000080112a <sys_yield>:

void
sys_yield(void) {
  80112a:	55                   	push   %rbp
  80112b:	48 89 e5             	mov    %rsp,%rbp
  80112e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80112f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801134:	b8 0a 00 00 00       	mov    $0xa,%eax
  801139:	48 89 ca             	mov    %rcx,%rdx
  80113c:	48 89 cb             	mov    %rcx,%rbx
  80113f:	48 89 cf             	mov    %rcx,%rdi
  801142:	48 89 ce             	mov    %rcx,%rsi
  801145:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801147:	5b                   	pop    %rbx
  801148:	5d                   	pop    %rbp
  801149:	c3                   	retq   

000000000080114a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  80114a:	55                   	push   %rbp
  80114b:	48 89 e5             	mov    %rsp,%rbp
  80114e:	53                   	push   %rbx
  80114f:	48 83 ec 08          	sub    $0x8,%rsp
  801153:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801156:	4c 63 c7             	movslq %edi,%r8
  801159:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  80115c:	be 00 00 00 00       	mov    $0x0,%esi
  801161:	b8 04 00 00 00       	mov    $0x4,%eax
  801166:	4c 89 c2             	mov    %r8,%rdx
  801169:	48 89 f7             	mov    %rsi,%rdi
  80116c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80116e:	48 85 c0             	test   %rax,%rax
  801171:	7f 07                	jg     80117a <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  801173:	48 83 c4 08          	add    $0x8,%rsp
  801177:	5b                   	pop    %rbx
  801178:	5d                   	pop    %rbp
  801179:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80117a:	49 89 c0             	mov    %rax,%r8
  80117d:	b9 04 00 00 00       	mov    $0x4,%ecx
  801182:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801189:	00 00 00 
  80118c:	be 22 00 00 00       	mov    $0x22,%esi
  801191:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  801198:	00 00 00 
  80119b:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a0:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  8011a7:	00 00 00 
  8011aa:	41 ff d1             	callq  *%r9

00000000008011ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8011ad:	55                   	push   %rbp
  8011ae:	48 89 e5             	mov    %rsp,%rbp
  8011b1:	53                   	push   %rbx
  8011b2:	48 83 ec 08          	sub    $0x8,%rsp
  8011b6:	41 89 f9             	mov    %edi,%r9d
  8011b9:	49 89 f2             	mov    %rsi,%r10
  8011bc:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8011bf:	4d 63 c9             	movslq %r9d,%r9
  8011c2:	48 63 da             	movslq %edx,%rbx
  8011c5:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8011c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8011cd:	4c 89 ca             	mov    %r9,%rdx
  8011d0:	4c 89 d1             	mov    %r10,%rcx
  8011d3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011d5:	48 85 c0             	test   %rax,%rax
  8011d8:	7f 07                	jg     8011e1 <sys_page_map+0x34>
}
  8011da:	48 83 c4 08          	add    $0x8,%rsp
  8011de:	5b                   	pop    %rbx
  8011df:	5d                   	pop    %rbp
  8011e0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011e1:	49 89 c0             	mov    %rax,%r8
  8011e4:	b9 05 00 00 00       	mov    $0x5,%ecx
  8011e9:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  8011f0:	00 00 00 
  8011f3:	be 22 00 00 00       	mov    $0x22,%esi
  8011f8:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  8011ff:	00 00 00 
  801202:	b8 00 00 00 00       	mov    $0x0,%eax
  801207:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  80120e:	00 00 00 
  801211:	41 ff d1             	callq  *%r9

0000000000801214 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801214:	55                   	push   %rbp
  801215:	48 89 e5             	mov    %rsp,%rbp
  801218:	53                   	push   %rbx
  801219:	48 83 ec 08          	sub    $0x8,%rsp
  80121d:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801220:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801223:	be 00 00 00 00       	mov    $0x0,%esi
  801228:	b8 06 00 00 00       	mov    $0x6,%eax
  80122d:	48 89 f3             	mov    %rsi,%rbx
  801230:	48 89 f7             	mov    %rsi,%rdi
  801233:	cd 30                	int    $0x30
  if (check && ret > 0)
  801235:	48 85 c0             	test   %rax,%rax
  801238:	7f 07                	jg     801241 <sys_page_unmap+0x2d>
}
  80123a:	48 83 c4 08          	add    $0x8,%rsp
  80123e:	5b                   	pop    %rbx
  80123f:	5d                   	pop    %rbp
  801240:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801241:	49 89 c0             	mov    %rax,%r8
  801244:	b9 06 00 00 00       	mov    $0x6,%ecx
  801249:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801250:	00 00 00 
  801253:	be 22 00 00 00       	mov    $0x22,%esi
  801258:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  80125f:	00 00 00 
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  80126e:	00 00 00 
  801271:	41 ff d1             	callq  *%r9

0000000000801274 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  801274:	55                   	push   %rbp
  801275:	48 89 e5             	mov    %rsp,%rbp
  801278:	53                   	push   %rbx
  801279:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80127d:	48 63 d7             	movslq %edi,%rdx
  801280:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801283:	bb 00 00 00 00       	mov    $0x0,%ebx
  801288:	b8 08 00 00 00       	mov    $0x8,%eax
  80128d:	48 89 df             	mov    %rbx,%rdi
  801290:	48 89 de             	mov    %rbx,%rsi
  801293:	cd 30                	int    $0x30
  if (check && ret > 0)
  801295:	48 85 c0             	test   %rax,%rax
  801298:	7f 07                	jg     8012a1 <sys_env_set_status+0x2d>
}
  80129a:	48 83 c4 08          	add    $0x8,%rsp
  80129e:	5b                   	pop    %rbx
  80129f:	5d                   	pop    %rbp
  8012a0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012a1:	49 89 c0             	mov    %rax,%r8
  8012a4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8012a9:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  8012b0:	00 00 00 
  8012b3:	be 22 00 00 00       	mov    $0x22,%esi
  8012b8:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  8012bf:	00 00 00 
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  8012ce:	00 00 00 
  8012d1:	41 ff d1             	callq  *%r9

00000000008012d4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8012d4:	55                   	push   %rbp
  8012d5:	48 89 e5             	mov    %rsp,%rbp
  8012d8:	53                   	push   %rbx
  8012d9:	48 83 ec 08          	sub    $0x8,%rsp
  8012dd:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  8012e0:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8012e3:	be 00 00 00 00       	mov    $0x0,%esi
  8012e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8012ed:	48 89 f3             	mov    %rsi,%rbx
  8012f0:	48 89 f7             	mov    %rsi,%rdi
  8012f3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012f5:	48 85 c0             	test   %rax,%rax
  8012f8:	7f 07                	jg     801301 <sys_env_set_pgfault_upcall+0x2d>
}
  8012fa:	48 83 c4 08          	add    $0x8,%rsp
  8012fe:	5b                   	pop    %rbx
  8012ff:	5d                   	pop    %rbp
  801300:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801301:	49 89 c0             	mov    %rax,%r8
  801304:	b9 09 00 00 00       	mov    $0x9,%ecx
  801309:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801310:	00 00 00 
  801313:	be 22 00 00 00       	mov    $0x22,%esi
  801318:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  80131f:	00 00 00 
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  80132e:	00 00 00 
  801331:	41 ff d1             	callq  *%r9

0000000000801334 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801334:	55                   	push   %rbp
  801335:	48 89 e5             	mov    %rsp,%rbp
  801338:	53                   	push   %rbx
  801339:	49 89 f0             	mov    %rsi,%r8
  80133c:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  80133f:	48 63 d7             	movslq %edi,%rdx
  801342:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801345:	b8 0b 00 00 00       	mov    $0xb,%eax
  80134a:	be 00 00 00 00       	mov    $0x0,%esi
  80134f:	4c 89 c1             	mov    %r8,%rcx
  801352:	cd 30                	int    $0x30
}
  801354:	5b                   	pop    %rbx
  801355:	5d                   	pop    %rbp
  801356:	c3                   	retq   

0000000000801357 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801357:	55                   	push   %rbp
  801358:	48 89 e5             	mov    %rsp,%rbp
  80135b:	53                   	push   %rbx
  80135c:	48 83 ec 08          	sub    $0x8,%rsp
  801360:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801363:	be 00 00 00 00       	mov    $0x0,%esi
  801368:	b8 0c 00 00 00       	mov    $0xc,%eax
  80136d:	48 89 f1             	mov    %rsi,%rcx
  801370:	48 89 f3             	mov    %rsi,%rbx
  801373:	48 89 f7             	mov    %rsi,%rdi
  801376:	cd 30                	int    $0x30
  if (check && ret > 0)
  801378:	48 85 c0             	test   %rax,%rax
  80137b:	7f 07                	jg     801384 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80137d:	48 83 c4 08          	add    $0x8,%rsp
  801381:	5b                   	pop    %rbx
  801382:	5d                   	pop    %rbp
  801383:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801384:	49 89 c0             	mov    %rax,%r8
  801387:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80138c:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801393:	00 00 00 
  801396:	be 22 00 00 00       	mov    $0x22,%esi
  80139b:	48 bf 7f 1a 80 00 00 	movabs $0x801a7f,%rdi
  8013a2:	00 00 00 
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013aa:	49 b9 3c 15 80 00 00 	movabs $0x80153c,%r9
  8013b1:	00 00 00 
  8013b4:	41 ff d1             	callq  *%r9

00000000008013b7 <ipc_recv>:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store) {
  8013b7:	55                   	push   %rbp
  8013b8:	48 89 e5             	mov    %rsp,%rbp
  8013bb:	41 54                	push   %r12
  8013bd:	53                   	push   %rbx
  8013be:	49 89 fc             	mov    %rdi,%r12
  8013c1:	48 89 d3             	mov    %rdx,%rbx
  // LAB 9 code
  int r;

	if ((r = sys_ipc_recv(pg)) < 0) {
  8013c4:	48 89 f7             	mov    %rsi,%rdi
  8013c7:	48 b8 57 13 80 00 00 	movabs $0x801357,%rax
  8013ce:	00 00 00 
  8013d1:	ff d0                	callq  *%rax
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 45                	js     80141c <ipc_recv+0x65>
		if (perm_store) {
			*perm_store = 0;
		}
		return r;
	} else {
		if (from_env_store) {
  8013d7:	4d 85 e4             	test   %r12,%r12
  8013da:	74 14                	je     8013f0 <ipc_recv+0x39>
			*from_env_store = thisenv->env_ipc_from;
  8013dc:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  8013e3:	00 00 00 
  8013e6:	8b 80 14 01 00 00    	mov    0x114(%rax),%eax
  8013ec:	41 89 04 24          	mov    %eax,(%r12)
		}
		if (perm_store) {
  8013f0:	48 85 db             	test   %rbx,%rbx
  8013f3:	74 12                	je     801407 <ipc_recv+0x50>
			*perm_store = thisenv->env_ipc_perm;
  8013f5:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  8013fc:	00 00 00 
  8013ff:	8b 80 18 01 00 00    	mov    0x118(%rax),%eax
  801405:	89 03                	mov    %eax,(%rbx)
		}
#ifdef SANITIZE_USER_SHADOW_BASE
	  platform_asan_unpoison(pg, PGSIZE);
#endif
		return thisenv->env_ipc_value;
  801407:	48 a1 08 20 80 00 00 	movabs 0x802008,%rax
  80140e:	00 00 00 
  801411:	8b 80 10 01 00 00    	mov    0x110(%rax),%eax
	}
  // LAB 9 code end

  // return -1;
}
  801417:	5b                   	pop    %rbx
  801418:	41 5c                	pop    %r12
  80141a:	5d                   	pop    %rbp
  80141b:	c3                   	retq   
		if (from_env_store) {
  80141c:	4d 85 e4             	test   %r12,%r12
  80141f:	74 08                	je     801429 <ipc_recv+0x72>
			*from_env_store = 0;
  801421:	41 c7 04 24 00 00 00 	movl   $0x0,(%r12)
  801428:	00 
		if (perm_store) {
  801429:	48 85 db             	test   %rbx,%rbx
  80142c:	74 e9                	je     801417 <ipc_recv+0x60>
			*perm_store = 0;
  80142e:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  801434:	eb e1                	jmp    801417 <ipc_recv+0x60>

0000000000801436 <ipc_send>:
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm) {
  801436:	55                   	push   %rbp
  801437:	48 89 e5             	mov    %rsp,%rbp
  80143a:	41 57                	push   %r15
  80143c:	41 56                	push   %r14
  80143e:	41 55                	push   %r13
  801440:	41 54                	push   %r12
  801442:	53                   	push   %rbx
  801443:	48 83 ec 08          	sub    $0x8,%rsp
  801447:	41 89 ff             	mov    %edi,%r15d
  80144a:	41 89 f6             	mov    %esi,%r14d
  80144d:	48 89 d3             	mov    %rdx,%rbx
  801450:	41 89 cd             	mov    %ecx,%r13d
  // LAB 9 code
  int r;

  if (pg == NULL) {
    pg = (void *) UTOP;
  801453:	48 85 d2             	test   %rdx,%rdx
  801456:	48 b8 00 00 00 00 80 	movabs $0x8000000000,%rax
  80145d:	00 00 00 
  801460:	48 0f 44 d8          	cmove  %rax,%rbx
  }
  while ((r = sys_ipc_try_send(to_env, val, pg, perm))) {
  801464:	49 bc 34 13 80 00 00 	movabs $0x801334,%r12
  80146b:	00 00 00 
  80146e:	44 89 f6             	mov    %r14d,%esi
  801471:	44 89 e9             	mov    %r13d,%ecx
  801474:	48 89 da             	mov    %rbx,%rdx
  801477:	44 89 ff             	mov    %r15d,%edi
  80147a:	41 ff d4             	callq  *%r12
  80147d:	85 c0                	test   %eax,%eax
  80147f:	74 34                	je     8014b5 <ipc_send+0x7f>
	  if (r < 0 && r != -E_IPC_NOT_RECV) {
  801481:	79 eb                	jns    80146e <ipc_send+0x38>
  801483:	83 f8 f6             	cmp    $0xfffffff6,%eax
  801486:	74 e6                	je     80146e <ipc_send+0x38>
		  panic("ipc_send error: sys_ipc_try_send: %i\n", r);
  801488:	89 c1                	mov    %eax,%ecx
  80148a:	48 ba 90 1a 80 00 00 	movabs $0x801a90,%rdx
  801491:	00 00 00 
  801494:	be 46 00 00 00       	mov    $0x46,%esi
  801499:	48 bf b6 1a 80 00 00 	movabs $0x801ab6,%rdi
  8014a0:	00 00 00 
  8014a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a8:	49 b8 3c 15 80 00 00 	movabs $0x80153c,%r8
  8014af:	00 00 00 
  8014b2:	41 ff d0             	callq  *%r8
	  }
	  //sys_yield();
  }
  sys_yield();
  8014b5:	48 b8 2a 11 80 00 00 	movabs $0x80112a,%rax
  8014bc:	00 00 00 
  8014bf:	ff d0                	callq  *%rax
  // LAB 9 code end
}
  8014c1:	48 83 c4 08          	add    $0x8,%rsp
  8014c5:	5b                   	pop    %rbx
  8014c6:	41 5c                	pop    %r12
  8014c8:	41 5d                	pop    %r13
  8014ca:	41 5e                	pop    %r14
  8014cc:	41 5f                	pop    %r15
  8014ce:	5d                   	pop    %rbp
  8014cf:	c3                   	retq   

00000000008014d0 <ipc_find_env>:
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type) {
  int i;
  for (i = 0; i < NENV; i++)
    if (envs[i].env_type == type)
  8014d0:	a1 d0 e0 22 3c 80 00 	movabs 0x803c22e0d0,%eax
  8014d7:	00 00 
  8014d9:	39 c7                	cmp    %eax,%edi
  8014db:	74 38                	je     801515 <ipc_find_env+0x45>
  for (i = 0; i < NENV; i++)
  8014dd:	ba 01 00 00 00       	mov    $0x1,%edx
    if (envs[i].env_type == type)
  8014e2:	48 b9 00 e0 22 3c 80 	movabs $0x803c22e000,%rcx
  8014e9:	00 00 00 
  8014ec:	48 63 c2             	movslq %edx,%rax
  8014ef:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8014f3:	48 c1 e0 05          	shl    $0x5,%rax
  8014f7:	48 01 c8             	add    %rcx,%rax
  8014fa:	8b 80 d0 00 00 00    	mov    0xd0(%rax),%eax
  801500:	39 f8                	cmp    %edi,%eax
  801502:	74 16                	je     80151a <ipc_find_env+0x4a>
  for (i = 0; i < NENV; i++)
  801504:	83 c2 01             	add    $0x1,%edx
  801507:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80150d:	75 dd                	jne    8014ec <ipc_find_env+0x1c>
      return envs[i].env_id;
  return 0;
  80150f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801514:	c3                   	retq   
  for (i = 0; i < NENV; i++)
  801515:	ba 00 00 00 00       	mov    $0x0,%edx
      return envs[i].env_id;
  80151a:	48 63 d2             	movslq %edx,%rdx
  80151d:	48 8d 04 d2          	lea    (%rdx,%rdx,8),%rax
  801521:	48 c1 e0 05          	shl    $0x5,%rax
  801525:	48 89 c2             	mov    %rax,%rdx
  801528:	48 b8 00 e0 22 3c 80 	movabs $0x803c22e000,%rax
  80152f:	00 00 00 
  801532:	48 01 d0             	add    %rdx,%rax
  801535:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  80153b:	c3                   	retq   

000000000080153c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80153c:	55                   	push   %rbp
  80153d:	48 89 e5             	mov    %rsp,%rbp
  801540:	41 56                	push   %r14
  801542:	41 55                	push   %r13
  801544:	41 54                	push   %r12
  801546:	53                   	push   %rbx
  801547:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80154e:	49 89 fd             	mov    %rdi,%r13
  801551:	41 89 f6             	mov    %esi,%r14d
  801554:	49 89 d4             	mov    %rdx,%r12
  801557:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80155e:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801565:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80156c:	84 c0                	test   %al,%al
  80156e:	74 26                	je     801596 <_panic+0x5a>
  801570:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  801577:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80157e:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801582:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  801586:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80158a:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80158e:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801592:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801596:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80159d:	00 00 00 
  8015a0:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8015a7:	00 00 00 
  8015aa:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8015ae:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8015b5:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8015bc:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8015c3:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8015ca:	00 00 00 
  8015cd:	48 8b 18             	mov    (%rax),%rbx
  8015d0:	48 b8 0a 11 80 00 00 	movabs $0x80110a,%rax
  8015d7:	00 00 00 
  8015da:	ff d0                	callq  *%rax
  8015dc:	45 89 f0             	mov    %r14d,%r8d
  8015df:	4c 89 e9             	mov    %r13,%rcx
  8015e2:	48 89 da             	mov    %rbx,%rdx
  8015e5:	89 c6                	mov    %eax,%esi
  8015e7:	48 bf c0 1a 80 00 00 	movabs $0x801ac0,%rdi
  8015ee:	00 00 00 
  8015f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f6:	48 bb 78 02 80 00 00 	movabs $0x800278,%rbx
  8015fd:	00 00 00 
  801600:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801602:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801609:	4c 89 e7             	mov    %r12,%rdi
  80160c:	48 b8 10 02 80 00 00 	movabs $0x800210,%rax
  801613:	00 00 00 
  801616:	ff d0                	callq  *%rax
  cprintf("\n");
  801618:	48 bf 4f 16 80 00 00 	movabs $0x80164f,%rdi
  80161f:	00 00 00 
  801622:	b8 00 00 00 00       	mov    $0x0,%eax
  801627:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801629:	cc                   	int3   
  while (1)
  80162a:	eb fd                	jmp    801629 <_panic+0xed>
