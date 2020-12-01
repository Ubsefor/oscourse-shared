
obj/user/faultdie:     file format elf64-x86-64


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
  800023:	e8 6d 00 00 00       	callq  800095 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <handler>:
// test user-level fault handler -- just exit when we fault

#include <inc/lib.h>

void
handler(struct UTrapframe *utf) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  void *addr   = (void *)utf->utf_fault_va;
  uint64_t err = utf->utf_err;
  cprintf("i faulted at va %lx, err %x\n",
  80002e:	8b 57 08             	mov    0x8(%rdi),%edx
  800031:	83 e2 07             	and    $0x7,%edx
  800034:	48 8b 37             	mov    (%rdi),%rsi
  800037:	48 bf 40 15 80 00 00 	movabs $0x801540,%rdi
  80003e:	00 00 00 
  800041:	b8 00 00 00 00       	mov    $0x0,%eax
  800046:	48 b9 14 02 80 00 00 	movabs $0x800214,%rcx
  80004d:	00 00 00 
  800050:	ff d1                	callq  *%rcx
          (unsigned long)addr, (unsigned)(err & 7));
  sys_env_destroy(sys_getenvid());
  800052:	48 b8 a6 10 80 00 00 	movabs $0x8010a6,%rax
  800059:	00 00 00 
  80005c:	ff d0                	callq  *%rax
  80005e:	89 c7                	mov    %eax,%edi
  800060:	48 b8 46 10 80 00 00 	movabs $0x801046,%rax
  800067:	00 00 00 
  80006a:	ff d0                	callq  *%rax
}
  80006c:	5d                   	pop    %rbp
  80006d:	c3                   	retq   

000000000080006e <umain>:

void
umain(int argc, char **argv) {
  80006e:	55                   	push   %rbp
  80006f:	48 89 e5             	mov    %rsp,%rbp
  set_pgfault_handler(handler);
  800072:	48 bf 2a 00 80 00 00 	movabs $0x80002a,%rdi
  800079:	00 00 00 
  80007c:	48 b8 53 13 80 00 00 	movabs $0x801353,%rax
  800083:	00 00 00 
  800086:	ff d0                	callq  *%rax
  *(volatile int *)0xDeadBeef = 0;
  800088:	b8 ef be ad de       	mov    $0xdeadbeef,%eax
  80008d:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
}
  800093:	5d                   	pop    %rbp
  800094:	c3                   	retq   

0000000000800095 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800095:	55                   	push   %rbp
  800096:	48 89 e5             	mov    %rsp,%rbp
  800099:	41 56                	push   %r14
  80009b:	41 55                	push   %r13
  80009d:	41 54                	push   %r12
  80009f:	53                   	push   %rbx
  8000a0:	41 89 fd             	mov    %edi,%r13d
  8000a3:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  8000a6:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  8000ad:	00 00 00 
  8000b0:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  8000b7:	00 00 00 
  8000ba:	48 39 c2             	cmp    %rax,%rdx
  8000bd:	73 23                	jae    8000e2 <libmain+0x4d>
  8000bf:	48 89 d3             	mov    %rdx,%rbx
  8000c2:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  8000c6:	48 29 d0             	sub    %rdx,%rax
  8000c9:	48 c1 e8 03          	shr    $0x3,%rax
  8000cd:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8000d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d7:	ff 13                	callq  *(%rbx)
    ctor++;
  8000d9:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8000dd:	4c 39 e3             	cmp    %r12,%rbx
  8000e0:	75 f0                	jne    8000d2 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000e2:	48 b8 a6 10 80 00 00 	movabs $0x8010a6,%rax
  8000e9:	00 00 00 
  8000ec:	ff d0                	callq  *%rax
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000f7:	48 c1 e0 05          	shl    $0x5,%rax
  8000fb:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800102:	00 00 00 
  800105:	48 01 d0             	add    %rdx,%rax
  800108:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  80010f:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800112:	45 85 ed             	test   %r13d,%r13d
  800115:	7e 0d                	jle    800124 <libmain+0x8f>
    binaryname = argv[0];
  800117:	49 8b 06             	mov    (%r14),%rax
  80011a:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800121:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800124:	4c 89 f6             	mov    %r14,%rsi
  800127:	44 89 ef             	mov    %r13d,%edi
  80012a:	48 b8 6e 00 80 00 00 	movabs $0x80006e,%rax
  800131:	00 00 00 
  800134:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800136:	48 b8 4b 01 80 00 00 	movabs $0x80014b,%rax
  80013d:	00 00 00 
  800140:	ff d0                	callq  *%rax
#endif
}
  800142:	5b                   	pop    %rbx
  800143:	41 5c                	pop    %r12
  800145:	41 5d                	pop    %r13
  800147:	41 5e                	pop    %r14
  800149:	5d                   	pop    %rbp
  80014a:	c3                   	retq   

000000000080014b <exit>:

#include <inc/lib.h>

void
exit(void) {
  80014b:	55                   	push   %rbp
  80014c:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80014f:	bf 00 00 00 00       	mov    $0x0,%edi
  800154:	48 b8 46 10 80 00 00 	movabs $0x801046,%rax
  80015b:	00 00 00 
  80015e:	ff d0                	callq  *%rax
}
  800160:	5d                   	pop    %rbp
  800161:	c3                   	retq   

0000000000800162 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800162:	55                   	push   %rbp
  800163:	48 89 e5             	mov    %rsp,%rbp
  800166:	53                   	push   %rbx
  800167:	48 83 ec 08          	sub    $0x8,%rsp
  80016b:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80016e:	8b 06                	mov    (%rsi),%eax
  800170:	8d 50 01             	lea    0x1(%rax),%edx
  800173:	89 16                	mov    %edx,(%rsi)
  800175:	48 98                	cltq   
  800177:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80017c:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800182:	74 0b                	je     80018f <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800184:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800188:	48 83 c4 08          	add    $0x8,%rsp
  80018c:	5b                   	pop    %rbx
  80018d:	5d                   	pop    %rbp
  80018e:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80018f:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800193:	be ff 00 00 00       	mov    $0xff,%esi
  800198:	48 b8 08 10 80 00 00 	movabs $0x801008,%rax
  80019f:	00 00 00 
  8001a2:	ff d0                	callq  *%rax
    b->idx = 0;
  8001a4:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8001aa:	eb d8                	jmp    800184 <putch+0x22>

00000000008001ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8001ac:	55                   	push   %rbp
  8001ad:	48 89 e5             	mov    %rsp,%rbp
  8001b0:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8001b7:	48 89 fa             	mov    %rdi,%rdx
  8001ba:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8001c4:	00 00 00 
  b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8001ce:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8001d1:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8001d8:	48 bf 62 01 80 00 00 	movabs $0x800162,%rdi
  8001df:	00 00 00 
  8001e2:	48 b8 d2 03 80 00 00 	movabs $0x8003d2,%rax
  8001e9:	00 00 00 
  8001ec:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001ee:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001f5:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001fc:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800200:	48 b8 08 10 80 00 00 	movabs $0x801008,%rax
  800207:	00 00 00 
  80020a:	ff d0                	callq  *%rax

  return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800212:	c9                   	leaveq 
  800213:	c3                   	retq   

0000000000800214 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800214:	55                   	push   %rbp
  800215:	48 89 e5             	mov    %rsp,%rbp
  800218:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80021f:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800226:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80022d:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800234:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80023b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800242:	84 c0                	test   %al,%al
  800244:	74 20                	je     800266 <cprintf+0x52>
  800246:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80024a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80024e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800252:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800256:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80025a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80025e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800262:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800266:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80026d:	00 00 00 
  800270:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800277:	00 00 00 
  80027a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80027e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800285:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80028c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800293:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80029a:	48 b8 ac 01 80 00 00 	movabs $0x8001ac,%rax
  8002a1:	00 00 00 
  8002a4:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8002a6:	c9                   	leaveq 
  8002a7:	c3                   	retq   

00000000008002a8 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8002a8:	55                   	push   %rbp
  8002a9:	48 89 e5             	mov    %rsp,%rbp
  8002ac:	41 57                	push   %r15
  8002ae:	41 56                	push   %r14
  8002b0:	41 55                	push   %r13
  8002b2:	41 54                	push   %r12
  8002b4:	53                   	push   %rbx
  8002b5:	48 83 ec 18          	sub    $0x18,%rsp
  8002b9:	49 89 fc             	mov    %rdi,%r12
  8002bc:	49 89 f5             	mov    %rsi,%r13
  8002bf:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8002c3:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8002c6:	41 89 cf             	mov    %ecx,%r15d
  8002c9:	49 39 d7             	cmp    %rdx,%r15
  8002cc:	76 45                	jbe    800313 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8002ce:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8002d2:	85 db                	test   %ebx,%ebx
  8002d4:	7e 0e                	jle    8002e4 <printnum+0x3c>
      putch(padc, putdat);
  8002d6:	4c 89 ee             	mov    %r13,%rsi
  8002d9:	44 89 f7             	mov    %r14d,%edi
  8002dc:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8002df:	83 eb 01             	sub    $0x1,%ebx
  8002e2:	75 f2                	jne    8002d6 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8002e4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ed:	49 f7 f7             	div    %r15
  8002f0:	48 b8 67 15 80 00 00 	movabs $0x801567,%rax
  8002f7:	00 00 00 
  8002fa:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002fe:	4c 89 ee             	mov    %r13,%rsi
  800301:	41 ff d4             	callq  *%r12
}
  800304:	48 83 c4 18          	add    $0x18,%rsp
  800308:	5b                   	pop    %rbx
  800309:	41 5c                	pop    %r12
  80030b:	41 5d                	pop    %r13
  80030d:	41 5e                	pop    %r14
  80030f:	41 5f                	pop    %r15
  800311:	5d                   	pop    %rbp
  800312:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800313:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	49 f7 f7             	div    %r15
  80031f:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800323:	48 89 c2             	mov    %rax,%rdx
  800326:	48 b8 a8 02 80 00 00 	movabs $0x8002a8,%rax
  80032d:	00 00 00 
  800330:	ff d0                	callq  *%rax
  800332:	eb b0                	jmp    8002e4 <printnum+0x3c>

0000000000800334 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800334:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800338:	48 8b 06             	mov    (%rsi),%rax
  80033b:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80033f:	73 0a                	jae    80034b <sprintputch+0x17>
    *b->buf++ = ch;
  800341:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800345:	48 89 16             	mov    %rdx,(%rsi)
  800348:	40 88 38             	mov    %dil,(%rax)
}
  80034b:	c3                   	retq   

000000000080034c <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80034c:	55                   	push   %rbp
  80034d:	48 89 e5             	mov    %rsp,%rbp
  800350:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800357:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80035e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800365:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80036c:	84 c0                	test   %al,%al
  80036e:	74 20                	je     800390 <printfmt+0x44>
  800370:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800374:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800378:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80037c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800380:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800384:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800388:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80038c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800390:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800397:	00 00 00 
  80039a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003a1:	00 00 00 
  8003a4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003a8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003af:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003b6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8003bd:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8003c4:	48 b8 d2 03 80 00 00 	movabs $0x8003d2,%rax
  8003cb:	00 00 00 
  8003ce:	ff d0                	callq  *%rax
}
  8003d0:	c9                   	leaveq 
  8003d1:	c3                   	retq   

00000000008003d2 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8003d2:	55                   	push   %rbp
  8003d3:	48 89 e5             	mov    %rsp,%rbp
  8003d6:	41 57                	push   %r15
  8003d8:	41 56                	push   %r14
  8003da:	41 55                	push   %r13
  8003dc:	41 54                	push   %r12
  8003de:	53                   	push   %rbx
  8003df:	48 83 ec 48          	sub    $0x48,%rsp
  8003e3:	49 89 fd             	mov    %rdi,%r13
  8003e6:	49 89 f7             	mov    %rsi,%r15
  8003e9:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003ec:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003f0:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003f4:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003f8:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003fc:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800400:	41 0f b6 3e          	movzbl (%r14),%edi
  800404:	83 ff 25             	cmp    $0x25,%edi
  800407:	74 18                	je     800421 <vprintfmt+0x4f>
      if (ch == '\0')
  800409:	85 ff                	test   %edi,%edi
  80040b:	0f 84 8c 06 00 00    	je     800a9d <vprintfmt+0x6cb>
      putch(ch, putdat);
  800411:	4c 89 fe             	mov    %r15,%rsi
  800414:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800417:	49 89 de             	mov    %rbx,%r14
  80041a:	eb e0                	jmp    8003fc <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80041c:	49 89 de             	mov    %rbx,%r14
  80041f:	eb db                	jmp    8003fc <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800421:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800425:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800429:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800430:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800436:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80043a:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80043f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800445:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80044b:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800450:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800455:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800459:	0f b6 13             	movzbl (%rbx),%edx
  80045c:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80045f:	3c 55                	cmp    $0x55,%al
  800461:	0f 87 8b 05 00 00    	ja     8009f2 <vprintfmt+0x620>
  800467:	0f b6 c0             	movzbl %al,%eax
  80046a:	49 bb 40 16 80 00 00 	movabs $0x801640,%r11
  800471:	00 00 00 
  800474:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800478:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80047b:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80047f:	eb d4                	jmp    800455 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800481:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800484:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800488:	eb cb                	jmp    800455 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80048a:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80048d:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800491:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800495:	8d 50 d0             	lea    -0x30(%rax),%edx
  800498:	83 fa 09             	cmp    $0x9,%edx
  80049b:	77 7e                	ja     80051b <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80049d:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8004a1:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8004a5:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8004aa:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8004ae:	8d 50 d0             	lea    -0x30(%rax),%edx
  8004b1:	83 fa 09             	cmp    $0x9,%edx
  8004b4:	76 e7                	jbe    80049d <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8004b6:	4c 89 f3             	mov    %r14,%rbx
  8004b9:	eb 19                	jmp    8004d4 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8004bb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004be:	83 f8 2f             	cmp    $0x2f,%eax
  8004c1:	77 2a                	ja     8004ed <vprintfmt+0x11b>
  8004c3:	89 c2                	mov    %eax,%edx
  8004c5:	4c 01 d2             	add    %r10,%rdx
  8004c8:	83 c0 08             	add    $0x8,%eax
  8004cb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004ce:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8004d1:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8004d4:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004d8:	0f 89 77 ff ff ff    	jns    800455 <vprintfmt+0x83>
          width = precision, precision = -1;
  8004de:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8004e2:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004e8:	e9 68 ff ff ff       	jmpq   800455 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004ed:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004f1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004f5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004f9:	eb d3                	jmp    8004ce <vprintfmt+0xfc>
        if (width < 0)
  8004fb:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004fe:	85 c0                	test   %eax,%eax
  800500:	41 0f 48 c0          	cmovs  %r8d,%eax
  800504:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800507:	4c 89 f3             	mov    %r14,%rbx
  80050a:	e9 46 ff ff ff       	jmpq   800455 <vprintfmt+0x83>
  80050f:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800512:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800516:	e9 3a ff ff ff       	jmpq   800455 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80051b:	4c 89 f3             	mov    %r14,%rbx
  80051e:	eb b4                	jmp    8004d4 <vprintfmt+0x102>
        lflag++;
  800520:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800523:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800526:	e9 2a ff ff ff       	jmpq   800455 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80052b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80052e:	83 f8 2f             	cmp    $0x2f,%eax
  800531:	77 19                	ja     80054c <vprintfmt+0x17a>
  800533:	89 c2                	mov    %eax,%edx
  800535:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800539:	83 c0 08             	add    $0x8,%eax
  80053c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80053f:	4c 89 fe             	mov    %r15,%rsi
  800542:	8b 3a                	mov    (%rdx),%edi
  800544:	41 ff d5             	callq  *%r13
        break;
  800547:	e9 b0 fe ff ff       	jmpq   8003fc <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80054c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800550:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800554:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800558:	eb e5                	jmp    80053f <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80055a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80055d:	83 f8 2f             	cmp    $0x2f,%eax
  800560:	77 5b                	ja     8005bd <vprintfmt+0x1eb>
  800562:	89 c2                	mov    %eax,%edx
  800564:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800568:	83 c0 08             	add    $0x8,%eax
  80056b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80056e:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800570:	89 c8                	mov    %ecx,%eax
  800572:	c1 f8 1f             	sar    $0x1f,%eax
  800575:	31 c1                	xor    %eax,%ecx
  800577:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800579:	83 f9 0b             	cmp    $0xb,%ecx
  80057c:	7f 4d                	jg     8005cb <vprintfmt+0x1f9>
  80057e:	48 63 c1             	movslq %ecx,%rax
  800581:	48 ba 00 19 80 00 00 	movabs $0x801900,%rdx
  800588:	00 00 00 
  80058b:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80058f:	48 85 c0             	test   %rax,%rax
  800592:	74 37                	je     8005cb <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800594:	48 89 c1             	mov    %rax,%rcx
  800597:	48 ba 88 15 80 00 00 	movabs $0x801588,%rdx
  80059e:	00 00 00 
  8005a1:	4c 89 fe             	mov    %r15,%rsi
  8005a4:	4c 89 ef             	mov    %r13,%rdi
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	48 bb 4c 03 80 00 00 	movabs $0x80034c,%rbx
  8005b3:	00 00 00 
  8005b6:	ff d3                	callq  *%rbx
  8005b8:	e9 3f fe ff ff       	jmpq   8003fc <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8005bd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005c1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005c5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005c9:	eb a3                	jmp    80056e <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8005cb:	48 ba 7f 15 80 00 00 	movabs $0x80157f,%rdx
  8005d2:	00 00 00 
  8005d5:	4c 89 fe             	mov    %r15,%rsi
  8005d8:	4c 89 ef             	mov    %r13,%rdi
  8005db:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e0:	48 bb 4c 03 80 00 00 	movabs $0x80034c,%rbx
  8005e7:	00 00 00 
  8005ea:	ff d3                	callq  *%rbx
  8005ec:	e9 0b fe ff ff       	jmpq   8003fc <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005f4:	83 f8 2f             	cmp    $0x2f,%eax
  8005f7:	77 4b                	ja     800644 <vprintfmt+0x272>
  8005f9:	89 c2                	mov    %eax,%edx
  8005fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005ff:	83 c0 08             	add    $0x8,%eax
  800602:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800605:	48 8b 02             	mov    (%rdx),%rax
  800608:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80060c:	48 85 c0             	test   %rax,%rax
  80060f:	0f 84 05 04 00 00    	je     800a1a <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800615:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800619:	7e 06                	jle    800621 <vprintfmt+0x24f>
  80061b:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80061f:	75 31                	jne    800652 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800621:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800625:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800629:	0f b6 00             	movzbl (%rax),%eax
  80062c:	0f be f8             	movsbl %al,%edi
  80062f:	85 ff                	test   %edi,%edi
  800631:	0f 84 c3 00 00 00    	je     8006fa <vprintfmt+0x328>
  800637:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80063b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80063f:	e9 85 00 00 00       	jmpq   8006c9 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800644:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800648:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80064c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800650:	eb b3                	jmp    800605 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800652:	49 63 f4             	movslq %r12d,%rsi
  800655:	48 89 c7             	mov    %rax,%rdi
  800658:	48 b8 a9 0b 80 00 00 	movabs $0x800ba9,%rax
  80065f:	00 00 00 
  800662:	ff d0                	callq  *%rax
  800664:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800667:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80066a:	85 f6                	test   %esi,%esi
  80066c:	7e 22                	jle    800690 <vprintfmt+0x2be>
            putch(padc, putdat);
  80066e:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800672:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800676:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80067a:	4c 89 fe             	mov    %r15,%rsi
  80067d:	89 df                	mov    %ebx,%edi
  80067f:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800682:	41 83 ec 01          	sub    $0x1,%r12d
  800686:	75 f2                	jne    80067a <vprintfmt+0x2a8>
  800688:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80068c:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800690:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800694:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800698:	0f b6 00             	movzbl (%rax),%eax
  80069b:	0f be f8             	movsbl %al,%edi
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	0f 84 56 fd ff ff    	je     8003fc <vprintfmt+0x2a>
  8006a6:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8006aa:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8006ae:	eb 19                	jmp    8006c9 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8006b0:	4c 89 fe             	mov    %r15,%rsi
  8006b3:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	41 83 ee 01          	sub    $0x1,%r14d
  8006ba:	48 83 c3 01          	add    $0x1,%rbx
  8006be:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8006c2:	0f be f8             	movsbl %al,%edi
  8006c5:	85 ff                	test   %edi,%edi
  8006c7:	74 29                	je     8006f2 <vprintfmt+0x320>
  8006c9:	45 85 e4             	test   %r12d,%r12d
  8006cc:	78 06                	js     8006d4 <vprintfmt+0x302>
  8006ce:	41 83 ec 01          	sub    $0x1,%r12d
  8006d2:	78 48                	js     80071c <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8006d4:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8006d8:	74 d6                	je     8006b0 <vprintfmt+0x2de>
  8006da:	0f be c0             	movsbl %al,%eax
  8006dd:	83 e8 20             	sub    $0x20,%eax
  8006e0:	83 f8 5e             	cmp    $0x5e,%eax
  8006e3:	76 cb                	jbe    8006b0 <vprintfmt+0x2de>
            putch('?', putdat);
  8006e5:	4c 89 fe             	mov    %r15,%rsi
  8006e8:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006ed:	41 ff d5             	callq  *%r13
  8006f0:	eb c4                	jmp    8006b6 <vprintfmt+0x2e4>
  8006f2:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006f6:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006fa:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006fd:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800701:	0f 8e f5 fc ff ff    	jle    8003fc <vprintfmt+0x2a>
          putch(' ', putdat);
  800707:	4c 89 fe             	mov    %r15,%rsi
  80070a:	bf 20 00 00 00       	mov    $0x20,%edi
  80070f:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800712:	83 eb 01             	sub    $0x1,%ebx
  800715:	75 f0                	jne    800707 <vprintfmt+0x335>
  800717:	e9 e0 fc ff ff       	jmpq   8003fc <vprintfmt+0x2a>
  80071c:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800720:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800724:	eb d4                	jmp    8006fa <vprintfmt+0x328>
  if (lflag >= 2)
  800726:	83 f9 01             	cmp    $0x1,%ecx
  800729:	7f 1d                	jg     800748 <vprintfmt+0x376>
  else if (lflag)
  80072b:	85 c9                	test   %ecx,%ecx
  80072d:	74 5e                	je     80078d <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80072f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800732:	83 f8 2f             	cmp    $0x2f,%eax
  800735:	77 48                	ja     80077f <vprintfmt+0x3ad>
  800737:	89 c2                	mov    %eax,%edx
  800739:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80073d:	83 c0 08             	add    $0x8,%eax
  800740:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800743:	48 8b 1a             	mov    (%rdx),%rbx
  800746:	eb 17                	jmp    80075f <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800748:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80074b:	83 f8 2f             	cmp    $0x2f,%eax
  80074e:	77 21                	ja     800771 <vprintfmt+0x39f>
  800750:	89 c2                	mov    %eax,%edx
  800752:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800756:	83 c0 08             	add    $0x8,%eax
  800759:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80075c:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80075f:	48 85 db             	test   %rbx,%rbx
  800762:	78 50                	js     8007b4 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800764:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800767:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80076c:	e9 b4 01 00 00       	jmpq   800925 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800771:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800775:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800779:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80077d:	eb dd                	jmp    80075c <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80077f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800783:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800787:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80078b:	eb b6                	jmp    800743 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80078d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800790:	83 f8 2f             	cmp    $0x2f,%eax
  800793:	77 11                	ja     8007a6 <vprintfmt+0x3d4>
  800795:	89 c2                	mov    %eax,%edx
  800797:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80079b:	83 c0 08             	add    $0x8,%eax
  80079e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007a1:	48 63 1a             	movslq (%rdx),%rbx
  8007a4:	eb b9                	jmp    80075f <vprintfmt+0x38d>
  8007a6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007aa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b2:	eb ed                	jmp    8007a1 <vprintfmt+0x3cf>
          putch('-', putdat);
  8007b4:	4c 89 fe             	mov    %r15,%rsi
  8007b7:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8007bc:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8007bf:	48 89 da             	mov    %rbx,%rdx
  8007c2:	48 f7 da             	neg    %rdx
        base = 10;
  8007c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ca:	e9 56 01 00 00       	jmpq   800925 <vprintfmt+0x553>
  if (lflag >= 2)
  8007cf:	83 f9 01             	cmp    $0x1,%ecx
  8007d2:	7f 25                	jg     8007f9 <vprintfmt+0x427>
  else if (lflag)
  8007d4:	85 c9                	test   %ecx,%ecx
  8007d6:	74 5e                	je     800836 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8007d8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007db:	83 f8 2f             	cmp    $0x2f,%eax
  8007de:	77 48                	ja     800828 <vprintfmt+0x456>
  8007e0:	89 c2                	mov    %eax,%edx
  8007e2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007e6:	83 c0 08             	add    $0x8,%eax
  8007e9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ec:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007f4:	e9 2c 01 00 00       	jmpq   800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007f9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007fc:	83 f8 2f             	cmp    $0x2f,%eax
  8007ff:	77 19                	ja     80081a <vprintfmt+0x448>
  800801:	89 c2                	mov    %eax,%edx
  800803:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800807:	83 c0 08             	add    $0x8,%eax
  80080a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80080d:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800810:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800815:	e9 0b 01 00 00       	jmpq   800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80081a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80081e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800822:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800826:	eb e5                	jmp    80080d <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800828:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80082c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800830:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800834:	eb b6                	jmp    8007ec <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800836:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800839:	83 f8 2f             	cmp    $0x2f,%eax
  80083c:	77 18                	ja     800856 <vprintfmt+0x484>
  80083e:	89 c2                	mov    %eax,%edx
  800840:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800844:	83 c0 08             	add    $0x8,%eax
  800847:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80084a:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80084c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800851:	e9 cf 00 00 00       	jmpq   800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800856:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80085a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80085e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800862:	eb e6                	jmp    80084a <vprintfmt+0x478>
  if (lflag >= 2)
  800864:	83 f9 01             	cmp    $0x1,%ecx
  800867:	7f 25                	jg     80088e <vprintfmt+0x4bc>
  else if (lflag)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 5b                	je     8008c8 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80086d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800870:	83 f8 2f             	cmp    $0x2f,%eax
  800873:	77 45                	ja     8008ba <vprintfmt+0x4e8>
  800875:	89 c2                	mov    %eax,%edx
  800877:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80087b:	83 c0 08             	add    $0x8,%eax
  80087e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800881:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800884:	b9 08 00 00 00       	mov    $0x8,%ecx
  800889:	e9 97 00 00 00       	jmpq   800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80088e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800891:	83 f8 2f             	cmp    $0x2f,%eax
  800894:	77 16                	ja     8008ac <vprintfmt+0x4da>
  800896:	89 c2                	mov    %eax,%edx
  800898:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80089c:	83 c0 08             	add    $0x8,%eax
  80089f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a2:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8008a5:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008aa:	eb 79                	jmp    800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008ac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b8:	eb e8                	jmp    8008a2 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8008ba:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008be:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c6:	eb b9                	jmp    800881 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8008c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008cb:	83 f8 2f             	cmp    $0x2f,%eax
  8008ce:	77 15                	ja     8008e5 <vprintfmt+0x513>
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d6:	83 c0 08             	add    $0x8,%eax
  8008d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008dc:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8008de:	b9 08 00 00 00       	mov    $0x8,%ecx
  8008e3:	eb 40                	jmp    800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008e5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ed:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008f1:	eb e9                	jmp    8008dc <vprintfmt+0x50a>
        putch('0', putdat);
  8008f3:	4c 89 fe             	mov    %r15,%rsi
  8008f6:	bf 30 00 00 00       	mov    $0x30,%edi
  8008fb:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008fe:	4c 89 fe             	mov    %r15,%rsi
  800901:	bf 78 00 00 00       	mov    $0x78,%edi
  800906:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800909:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090c:	83 f8 2f             	cmp    $0x2f,%eax
  80090f:	77 34                	ja     800945 <vprintfmt+0x573>
  800911:	89 c2                	mov    %eax,%edx
  800913:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800917:	83 c0 08             	add    $0x8,%eax
  80091a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80091d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800920:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800925:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  80092a:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  80092e:	4c 89 fe             	mov    %r15,%rsi
  800931:	4c 89 ef             	mov    %r13,%rdi
  800934:	48 b8 a8 02 80 00 00 	movabs $0x8002a8,%rax
  80093b:	00 00 00 
  80093e:	ff d0                	callq  *%rax
        break;
  800940:	e9 b7 fa ff ff       	jmpq   8003fc <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800945:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800949:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800951:	eb ca                	jmp    80091d <vprintfmt+0x54b>
  if (lflag >= 2)
  800953:	83 f9 01             	cmp    $0x1,%ecx
  800956:	7f 22                	jg     80097a <vprintfmt+0x5a8>
  else if (lflag)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 58                	je     8009b4 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80095c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095f:	83 f8 2f             	cmp    $0x2f,%eax
  800962:	77 42                	ja     8009a6 <vprintfmt+0x5d4>
  800964:	89 c2                	mov    %eax,%edx
  800966:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096a:	83 c0 08             	add    $0x8,%eax
  80096d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800970:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800973:	b9 10 00 00 00       	mov    $0x10,%ecx
  800978:	eb ab                	jmp    800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80097a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80097d:	83 f8 2f             	cmp    $0x2f,%eax
  800980:	77 16                	ja     800998 <vprintfmt+0x5c6>
  800982:	89 c2                	mov    %eax,%edx
  800984:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800988:	83 c0 08             	add    $0x8,%eax
  80098b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80098e:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800991:	b9 10 00 00 00       	mov    $0x10,%ecx
  800996:	eb 8d                	jmp    800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800998:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80099c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a4:	eb e8                	jmp    80098e <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  8009a6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009aa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b2:	eb bc                	jmp    800970 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  8009b4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b7:	83 f8 2f             	cmp    $0x2f,%eax
  8009ba:	77 18                	ja     8009d4 <vprintfmt+0x602>
  8009bc:	89 c2                	mov    %eax,%edx
  8009be:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c2:	83 c0 08             	add    $0x8,%eax
  8009c5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009c8:	8b 12                	mov    (%rdx),%edx
        base = 16;
  8009ca:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009cf:	e9 51 ff ff ff       	jmpq   800925 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009d4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009dc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e0:	eb e6                	jmp    8009c8 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8009e2:	4c 89 fe             	mov    %r15,%rsi
  8009e5:	bf 25 00 00 00       	mov    $0x25,%edi
  8009ea:	41 ff d5             	callq  *%r13
        break;
  8009ed:	e9 0a fa ff ff       	jmpq   8003fc <vprintfmt+0x2a>
        putch('%', putdat);
  8009f2:	4c 89 fe             	mov    %r15,%rsi
  8009f5:	bf 25 00 00 00       	mov    $0x25,%edi
  8009fa:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009fd:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800a01:	0f 84 15 fa ff ff    	je     80041c <vprintfmt+0x4a>
  800a07:	49 89 de             	mov    %rbx,%r14
  800a0a:	49 83 ee 01          	sub    $0x1,%r14
  800a0e:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800a13:	75 f5                	jne    800a0a <vprintfmt+0x638>
  800a15:	e9 e2 f9 ff ff       	jmpq   8003fc <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800a1a:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a1e:	74 06                	je     800a26 <vprintfmt+0x654>
  800a20:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a24:	7f 21                	jg     800a47 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a26:	bf 28 00 00 00       	mov    $0x28,%edi
  800a2b:	48 bb 79 15 80 00 00 	movabs $0x801579,%rbx
  800a32:	00 00 00 
  800a35:	b8 28 00 00 00       	mov    $0x28,%eax
  800a3a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a3e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a42:	e9 82 fc ff ff       	jmpq   8006c9 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a47:	49 63 f4             	movslq %r12d,%rsi
  800a4a:	48 bf 78 15 80 00 00 	movabs $0x801578,%rdi
  800a51:	00 00 00 
  800a54:	48 b8 a9 0b 80 00 00 	movabs $0x800ba9,%rax
  800a5b:	00 00 00 
  800a5e:	ff d0                	callq  *%rax
  800a60:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a63:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a66:	48 be 78 15 80 00 00 	movabs $0x801578,%rsi
  800a6d:	00 00 00 
  800a70:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a74:	85 c0                	test   %eax,%eax
  800a76:	0f 8f f2 fb ff ff    	jg     80066e <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7c:	48 bb 79 15 80 00 00 	movabs $0x801579,%rbx
  800a83:	00 00 00 
  800a86:	b8 28 00 00 00       	mov    $0x28,%eax
  800a8b:	bf 28 00 00 00       	mov    $0x28,%edi
  800a90:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a94:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a98:	e9 2c fc ff ff       	jmpq   8006c9 <vprintfmt+0x2f7>
}
  800a9d:	48 83 c4 48          	add    $0x48,%rsp
  800aa1:	5b                   	pop    %rbx
  800aa2:	41 5c                	pop    %r12
  800aa4:	41 5d                	pop    %r13
  800aa6:	41 5e                	pop    %r14
  800aa8:	41 5f                	pop    %r15
  800aaa:	5d                   	pop    %rbp
  800aab:	c3                   	retq   

0000000000800aac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800aac:	55                   	push   %rbp
  800aad:	48 89 e5             	mov    %rsp,%rbp
  800ab0:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ab4:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ab8:	48 63 c6             	movslq %esi,%rax
  800abb:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800ac0:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800ac4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800acb:	48 85 ff             	test   %rdi,%rdi
  800ace:	74 2a                	je     800afa <vsnprintf+0x4e>
  800ad0:	85 f6                	test   %esi,%esi
  800ad2:	7e 26                	jle    800afa <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ad4:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800ad8:	48 bf 34 03 80 00 00 	movabs $0x800334,%rdi
  800adf:	00 00 00 
  800ae2:	48 b8 d2 03 80 00 00 	movabs $0x8003d2,%rax
  800ae9:	00 00 00 
  800aec:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800aee:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800af2:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800af5:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800af8:	c9                   	leaveq 
  800af9:	c3                   	retq   
    return -E_INVAL;
  800afa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aff:	eb f7                	jmp    800af8 <vsnprintf+0x4c>

0000000000800b01 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800b01:	55                   	push   %rbp
  800b02:	48 89 e5             	mov    %rsp,%rbp
  800b05:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800b0c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800b13:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800b1a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800b21:	84 c0                	test   %al,%al
  800b23:	74 20                	je     800b45 <snprintf+0x44>
  800b25:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800b29:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800b2d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800b31:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800b35:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800b39:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800b3d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800b41:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b45:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b4c:	00 00 00 
  800b4f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b56:	00 00 00 
  800b59:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b5d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b64:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b6b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b72:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b79:	48 b8 ac 0a 80 00 00 	movabs $0x800aac,%rax
  800b80:	00 00 00 
  800b83:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b85:	c9                   	leaveq 
  800b86:	c3                   	retq   

0000000000800b87 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b87:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b8a:	74 17                	je     800ba3 <strlen+0x1c>
  800b8c:	48 89 fa             	mov    %rdi,%rdx
  800b8f:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b94:	29 f9                	sub    %edi,%ecx
    n++;
  800b96:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b99:	48 83 c2 01          	add    $0x1,%rdx
  800b9d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ba0:	75 f4                	jne    800b96 <strlen+0xf>
  800ba2:	c3                   	retq   
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800ba8:	c3                   	retq   

0000000000800ba9 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba9:	48 85 f6             	test   %rsi,%rsi
  800bac:	74 24                	je     800bd2 <strnlen+0x29>
  800bae:	80 3f 00             	cmpb   $0x0,(%rdi)
  800bb1:	74 25                	je     800bd8 <strnlen+0x2f>
  800bb3:	48 01 fe             	add    %rdi,%rsi
  800bb6:	48 89 fa             	mov    %rdi,%rdx
  800bb9:	b9 01 00 00 00       	mov    $0x1,%ecx
  800bbe:	29 f9                	sub    %edi,%ecx
    n++;
  800bc0:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc3:	48 83 c2 01          	add    $0x1,%rdx
  800bc7:	48 39 f2             	cmp    %rsi,%rdx
  800bca:	74 11                	je     800bdd <strnlen+0x34>
  800bcc:	80 3a 00             	cmpb   $0x0,(%rdx)
  800bcf:	75 ef                	jne    800bc0 <strnlen+0x17>
  800bd1:	c3                   	retq   
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	c3                   	retq   
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800bdd:	c3                   	retq   

0000000000800bde <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800bde:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800bea:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800bed:	48 83 c2 01          	add    $0x1,%rdx
  800bf1:	84 c9                	test   %cl,%cl
  800bf3:	75 f1                	jne    800be6 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bf5:	c3                   	retq   

0000000000800bf6 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bf6:	55                   	push   %rbp
  800bf7:	48 89 e5             	mov    %rsp,%rbp
  800bfa:	41 54                	push   %r12
  800bfc:	53                   	push   %rbx
  800bfd:	48 89 fb             	mov    %rdi,%rbx
  800c00:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800c03:	48 b8 87 0b 80 00 00 	movabs $0x800b87,%rax
  800c0a:	00 00 00 
  800c0d:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800c0f:	48 63 f8             	movslq %eax,%rdi
  800c12:	48 01 df             	add    %rbx,%rdi
  800c15:	4c 89 e6             	mov    %r12,%rsi
  800c18:	48 b8 de 0b 80 00 00 	movabs $0x800bde,%rax
  800c1f:	00 00 00 
  800c22:	ff d0                	callq  *%rax
  return dst;
}
  800c24:	48 89 d8             	mov    %rbx,%rax
  800c27:	5b                   	pop    %rbx
  800c28:	41 5c                	pop    %r12
  800c2a:	5d                   	pop    %rbp
  800c2b:	c3                   	retq   

0000000000800c2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c2c:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800c2f:	48 85 d2             	test   %rdx,%rdx
  800c32:	74 1f                	je     800c53 <strncpy+0x27>
  800c34:	48 01 fa             	add    %rdi,%rdx
  800c37:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800c3a:	48 83 c1 01          	add    $0x1,%rcx
  800c3e:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c42:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c46:	41 80 f8 01          	cmp    $0x1,%r8b
  800c4a:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c4e:	48 39 ca             	cmp    %rcx,%rdx
  800c51:	75 e7                	jne    800c3a <strncpy+0xe>
  }
  return ret;
}
  800c53:	c3                   	retq   

0000000000800c54 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c54:	48 89 f8             	mov    %rdi,%rax
  800c57:	48 85 d2             	test   %rdx,%rdx
  800c5a:	74 36                	je     800c92 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c5c:	48 83 fa 01          	cmp    $0x1,%rdx
  800c60:	74 2d                	je     800c8f <strlcpy+0x3b>
  800c62:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c66:	45 84 c0             	test   %r8b,%r8b
  800c69:	74 24                	je     800c8f <strlcpy+0x3b>
  800c6b:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c6f:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c74:	48 83 c0 01          	add    $0x1,%rax
  800c78:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c7c:	48 39 d1             	cmp    %rdx,%rcx
  800c7f:	74 0e                	je     800c8f <strlcpy+0x3b>
  800c81:	48 83 c1 01          	add    $0x1,%rcx
  800c85:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c8a:	45 84 c0             	test   %r8b,%r8b
  800c8d:	75 e5                	jne    800c74 <strlcpy+0x20>
    *dst = '\0';
  800c8f:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c92:	48 29 f8             	sub    %rdi,%rax
}
  800c95:	c3                   	retq   

0000000000800c96 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c96:	0f b6 07             	movzbl (%rdi),%eax
  800c99:	84 c0                	test   %al,%al
  800c9b:	74 17                	je     800cb4 <strcmp+0x1e>
  800c9d:	3a 06                	cmp    (%rsi),%al
  800c9f:	75 13                	jne    800cb4 <strcmp+0x1e>
    p++, q++;
  800ca1:	48 83 c7 01          	add    $0x1,%rdi
  800ca5:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800ca9:	0f b6 07             	movzbl (%rdi),%eax
  800cac:	84 c0                	test   %al,%al
  800cae:	74 04                	je     800cb4 <strcmp+0x1e>
  800cb0:	3a 06                	cmp    (%rsi),%al
  800cb2:	74 ed                	je     800ca1 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800cb4:	0f b6 c0             	movzbl %al,%eax
  800cb7:	0f b6 16             	movzbl (%rsi),%edx
  800cba:	29 d0                	sub    %edx,%eax
}
  800cbc:	c3                   	retq   

0000000000800cbd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800cbd:	48 85 d2             	test   %rdx,%rdx
  800cc0:	74 2f                	je     800cf1 <strncmp+0x34>
  800cc2:	0f b6 07             	movzbl (%rdi),%eax
  800cc5:	84 c0                	test   %al,%al
  800cc7:	74 1f                	je     800ce8 <strncmp+0x2b>
  800cc9:	3a 06                	cmp    (%rsi),%al
  800ccb:	75 1b                	jne    800ce8 <strncmp+0x2b>
  800ccd:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800cd0:	48 83 c7 01          	add    $0x1,%rdi
  800cd4:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800cd8:	48 39 d7             	cmp    %rdx,%rdi
  800cdb:	74 1a                	je     800cf7 <strncmp+0x3a>
  800cdd:	0f b6 07             	movzbl (%rdi),%eax
  800ce0:	84 c0                	test   %al,%al
  800ce2:	74 04                	je     800ce8 <strncmp+0x2b>
  800ce4:	3a 06                	cmp    (%rsi),%al
  800ce6:	74 e8                	je     800cd0 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ce8:	0f b6 07             	movzbl (%rdi),%eax
  800ceb:	0f b6 16             	movzbl (%rsi),%edx
  800cee:	29 d0                	sub    %edx,%eax
}
  800cf0:	c3                   	retq   
    return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	c3                   	retq   
  800cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfc:	c3                   	retq   

0000000000800cfd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cfd:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cff:	0f b6 07             	movzbl (%rdi),%eax
  800d02:	84 c0                	test   %al,%al
  800d04:	74 1e                	je     800d24 <strchr+0x27>
    if (*s == c)
  800d06:	40 38 c6             	cmp    %al,%sil
  800d09:	74 1f                	je     800d2a <strchr+0x2d>
  for (; *s; s++)
  800d0b:	48 83 c7 01          	add    $0x1,%rdi
  800d0f:	0f b6 07             	movzbl (%rdi),%eax
  800d12:	84 c0                	test   %al,%al
  800d14:	74 08                	je     800d1e <strchr+0x21>
    if (*s == c)
  800d16:	38 d0                	cmp    %dl,%al
  800d18:	75 f1                	jne    800d0b <strchr+0xe>
  for (; *s; s++)
  800d1a:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800d1d:	c3                   	retq   
  return 0;
  800d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d23:	c3                   	retq   
  800d24:	b8 00 00 00 00       	mov    $0x0,%eax
  800d29:	c3                   	retq   
    if (*s == c)
  800d2a:	48 89 f8             	mov    %rdi,%rax
  800d2d:	c3                   	retq   

0000000000800d2e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800d2e:	48 89 f8             	mov    %rdi,%rax
  800d31:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800d33:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800d36:	40 38 f2             	cmp    %sil,%dl
  800d39:	74 13                	je     800d4e <strfind+0x20>
  800d3b:	84 d2                	test   %dl,%dl
  800d3d:	74 0f                	je     800d4e <strfind+0x20>
  for (; *s; s++)
  800d3f:	48 83 c0 01          	add    $0x1,%rax
  800d43:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d46:	38 ca                	cmp    %cl,%dl
  800d48:	74 04                	je     800d4e <strfind+0x20>
  800d4a:	84 d2                	test   %dl,%dl
  800d4c:	75 f1                	jne    800d3f <strfind+0x11>
      break;
  return (char *)s;
}
  800d4e:	c3                   	retq   

0000000000800d4f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d4f:	48 85 d2             	test   %rdx,%rdx
  800d52:	74 3a                	je     800d8e <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d54:	48 89 f8             	mov    %rdi,%rax
  800d57:	48 09 d0             	or     %rdx,%rax
  800d5a:	a8 03                	test   $0x3,%al
  800d5c:	75 28                	jne    800d86 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d5e:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d62:	89 f0                	mov    %esi,%eax
  800d64:	c1 e0 08             	shl    $0x8,%eax
  800d67:	89 f1                	mov    %esi,%ecx
  800d69:	c1 e1 18             	shl    $0x18,%ecx
  800d6c:	41 89 f0             	mov    %esi,%r8d
  800d6f:	41 c1 e0 10          	shl    $0x10,%r8d
  800d73:	44 09 c1             	or     %r8d,%ecx
  800d76:	09 ce                	or     %ecx,%esi
  800d78:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d7a:	48 c1 ea 02          	shr    $0x2,%rdx
  800d7e:	48 89 d1             	mov    %rdx,%rcx
  800d81:	fc                   	cld    
  800d82:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d84:	eb 08                	jmp    800d8e <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	48 89 d1             	mov    %rdx,%rcx
  800d8b:	fc                   	cld    
  800d8c:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d8e:	48 89 f8             	mov    %rdi,%rax
  800d91:	c3                   	retq   

0000000000800d92 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d92:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d95:	48 39 fe             	cmp    %rdi,%rsi
  800d98:	73 40                	jae    800dda <memmove+0x48>
  800d9a:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d9e:	48 39 f9             	cmp    %rdi,%rcx
  800da1:	76 37                	jbe    800dda <memmove+0x48>
    s += n;
    d += n;
  800da3:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800da7:	48 89 fe             	mov    %rdi,%rsi
  800daa:	48 09 d6             	or     %rdx,%rsi
  800dad:	48 09 ce             	or     %rcx,%rsi
  800db0:	40 f6 c6 03          	test   $0x3,%sil
  800db4:	75 14                	jne    800dca <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800db6:	48 83 ef 04          	sub    $0x4,%rdi
  800dba:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800dbe:	48 c1 ea 02          	shr    $0x2,%rdx
  800dc2:	48 89 d1             	mov    %rdx,%rcx
  800dc5:	fd                   	std    
  800dc6:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800dc8:	eb 0e                	jmp    800dd8 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800dca:	48 83 ef 01          	sub    $0x1,%rdi
  800dce:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800dd2:	48 89 d1             	mov    %rdx,%rcx
  800dd5:	fd                   	std    
  800dd6:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800dd8:	fc                   	cld    
  800dd9:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800dda:	48 89 c1             	mov    %rax,%rcx
  800ddd:	48 09 d1             	or     %rdx,%rcx
  800de0:	48 09 f1             	or     %rsi,%rcx
  800de3:	f6 c1 03             	test   $0x3,%cl
  800de6:	75 0e                	jne    800df6 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800de8:	48 c1 ea 02          	shr    $0x2,%rdx
  800dec:	48 89 d1             	mov    %rdx,%rcx
  800def:	48 89 c7             	mov    %rax,%rdi
  800df2:	fc                   	cld    
  800df3:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800df5:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800df6:	48 89 c7             	mov    %rax,%rdi
  800df9:	48 89 d1             	mov    %rdx,%rcx
  800dfc:	fc                   	cld    
  800dfd:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dff:	c3                   	retq   

0000000000800e00 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800e00:	55                   	push   %rbp
  800e01:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800e04:	48 b8 92 0d 80 00 00 	movabs $0x800d92,%rax
  800e0b:	00 00 00 
  800e0e:	ff d0                	callq  *%rax
}
  800e10:	5d                   	pop    %rbp
  800e11:	c3                   	retq   

0000000000800e12 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800e12:	55                   	push   %rbp
  800e13:	48 89 e5             	mov    %rsp,%rbp
  800e16:	41 57                	push   %r15
  800e18:	41 56                	push   %r14
  800e1a:	41 55                	push   %r13
  800e1c:	41 54                	push   %r12
  800e1e:	53                   	push   %rbx
  800e1f:	48 83 ec 08          	sub    $0x8,%rsp
  800e23:	49 89 fe             	mov    %rdi,%r14
  800e26:	49 89 f7             	mov    %rsi,%r15
  800e29:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800e2c:	48 89 f7             	mov    %rsi,%rdi
  800e2f:	48 b8 87 0b 80 00 00 	movabs $0x800b87,%rax
  800e36:	00 00 00 
  800e39:	ff d0                	callq  *%rax
  800e3b:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800e3e:	4c 89 ee             	mov    %r13,%rsi
  800e41:	4c 89 f7             	mov    %r14,%rdi
  800e44:	48 b8 a9 0b 80 00 00 	movabs $0x800ba9,%rax
  800e4b:	00 00 00 
  800e4e:	ff d0                	callq  *%rax
  800e50:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e53:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e57:	4d 39 e5             	cmp    %r12,%r13
  800e5a:	74 26                	je     800e82 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e5c:	4c 89 e8             	mov    %r13,%rax
  800e5f:	4c 29 e0             	sub    %r12,%rax
  800e62:	48 39 d8             	cmp    %rbx,%rax
  800e65:	76 2a                	jbe    800e91 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e67:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e6b:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e6f:	4c 89 fe             	mov    %r15,%rsi
  800e72:	48 b8 00 0e 80 00 00 	movabs $0x800e00,%rax
  800e79:	00 00 00 
  800e7c:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e7e:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e82:	48 83 c4 08          	add    $0x8,%rsp
  800e86:	5b                   	pop    %rbx
  800e87:	41 5c                	pop    %r12
  800e89:	41 5d                	pop    %r13
  800e8b:	41 5e                	pop    %r14
  800e8d:	41 5f                	pop    %r15
  800e8f:	5d                   	pop    %rbp
  800e90:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e91:	49 83 ed 01          	sub    $0x1,%r13
  800e95:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e99:	4c 89 ea             	mov    %r13,%rdx
  800e9c:	4c 89 fe             	mov    %r15,%rsi
  800e9f:	48 b8 00 0e 80 00 00 	movabs $0x800e00,%rax
  800ea6:	00 00 00 
  800ea9:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800eab:	4d 01 ee             	add    %r13,%r14
  800eae:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800eb3:	eb c9                	jmp    800e7e <strlcat+0x6c>

0000000000800eb5 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800eb5:	48 85 d2             	test   %rdx,%rdx
  800eb8:	74 3a                	je     800ef4 <memcmp+0x3f>
    if (*s1 != *s2)
  800eba:	0f b6 0f             	movzbl (%rdi),%ecx
  800ebd:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ec1:	44 38 c1             	cmp    %r8b,%cl
  800ec4:	75 1d                	jne    800ee3 <memcmp+0x2e>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800ecb:	48 39 d0             	cmp    %rdx,%rax
  800ece:	74 1e                	je     800eee <memcmp+0x39>
    if (*s1 != *s2)
  800ed0:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ed4:	48 83 c0 01          	add    $0x1,%rax
  800ed8:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ede:	44 38 c1             	cmp    %r8b,%cl
  800ee1:	74 e8                	je     800ecb <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ee3:	0f b6 c1             	movzbl %cl,%eax
  800ee6:	45 0f b6 c0          	movzbl %r8b,%r8d
  800eea:	44 29 c0             	sub    %r8d,%eax
  800eed:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	c3                   	retq   
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef9:	c3                   	retq   

0000000000800efa <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800efa:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800efe:	48 39 c7             	cmp    %rax,%rdi
  800f01:	73 19                	jae    800f1c <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f03:	89 f2                	mov    %esi,%edx
  800f05:	40 38 37             	cmp    %sil,(%rdi)
  800f08:	74 16                	je     800f20 <memfind+0x26>
  for (; s < ends; s++)
  800f0a:	48 83 c7 01          	add    $0x1,%rdi
  800f0e:	48 39 f8             	cmp    %rdi,%rax
  800f11:	74 08                	je     800f1b <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f13:	38 17                	cmp    %dl,(%rdi)
  800f15:	75 f3                	jne    800f0a <memfind+0x10>
  for (; s < ends; s++)
  800f17:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800f1a:	c3                   	retq   
  800f1b:	c3                   	retq   
  for (; s < ends; s++)
  800f1c:	48 89 f8             	mov    %rdi,%rax
  800f1f:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800f20:	48 89 f8             	mov    %rdi,%rax
  800f23:	c3                   	retq   

0000000000800f24 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f24:	0f b6 07             	movzbl (%rdi),%eax
  800f27:	3c 20                	cmp    $0x20,%al
  800f29:	74 04                	je     800f2f <strtol+0xb>
  800f2b:	3c 09                	cmp    $0x9,%al
  800f2d:	75 0f                	jne    800f3e <strtol+0x1a>
    s++;
  800f2f:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800f33:	0f b6 07             	movzbl (%rdi),%eax
  800f36:	3c 20                	cmp    $0x20,%al
  800f38:	74 f5                	je     800f2f <strtol+0xb>
  800f3a:	3c 09                	cmp    $0x9,%al
  800f3c:	74 f1                	je     800f2f <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800f3e:	3c 2b                	cmp    $0x2b,%al
  800f40:	74 2b                	je     800f6d <strtol+0x49>
  int neg  = 0;
  800f42:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f48:	3c 2d                	cmp    $0x2d,%al
  800f4a:	74 2d                	je     800f79 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f4c:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f52:	75 0f                	jne    800f63 <strtol+0x3f>
  800f54:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f57:	74 2c                	je     800f85 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f59:	85 d2                	test   %edx,%edx
  800f5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f60:	0f 44 d0             	cmove  %eax,%edx
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f68:	4c 63 d2             	movslq %edx,%r10
  800f6b:	eb 5c                	jmp    800fc9 <strtol+0xa5>
    s++;
  800f6d:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f71:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f77:	eb d3                	jmp    800f4c <strtol+0x28>
    s++, neg = 1;
  800f79:	48 83 c7 01          	add    $0x1,%rdi
  800f7d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f83:	eb c7                	jmp    800f4c <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f85:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f89:	74 0f                	je     800f9a <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f8b:	85 d2                	test   %edx,%edx
  800f8d:	75 d4                	jne    800f63 <strtol+0x3f>
    s++, base = 8;
  800f8f:	48 83 c7 01          	add    $0x1,%rdi
  800f93:	ba 08 00 00 00       	mov    $0x8,%edx
  800f98:	eb c9                	jmp    800f63 <strtol+0x3f>
    s += 2, base = 16;
  800f9a:	48 83 c7 02          	add    $0x2,%rdi
  800f9e:	ba 10 00 00 00       	mov    $0x10,%edx
  800fa3:	eb be                	jmp    800f63 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800fa5:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800fa9:	41 80 f8 19          	cmp    $0x19,%r8b
  800fad:	77 2f                	ja     800fde <strtol+0xba>
      dig = *s - 'a' + 10;
  800faf:	44 0f be c1          	movsbl %cl,%r8d
  800fb3:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800fb7:	39 d1                	cmp    %edx,%ecx
  800fb9:	7d 37                	jge    800ff2 <strtol+0xce>
    s++, val = (val * base) + dig;
  800fbb:	48 83 c7 01          	add    $0x1,%rdi
  800fbf:	49 0f af c2          	imul   %r10,%rax
  800fc3:	48 63 c9             	movslq %ecx,%rcx
  800fc6:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800fc9:	0f b6 0f             	movzbl (%rdi),%ecx
  800fcc:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800fd0:	41 80 f8 09          	cmp    $0x9,%r8b
  800fd4:	77 cf                	ja     800fa5 <strtol+0x81>
      dig = *s - '0';
  800fd6:	0f be c9             	movsbl %cl,%ecx
  800fd9:	83 e9 30             	sub    $0x30,%ecx
  800fdc:	eb d9                	jmp    800fb7 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800fde:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800fe2:	41 80 f8 19          	cmp    $0x19,%r8b
  800fe6:	77 0a                	ja     800ff2 <strtol+0xce>
      dig = *s - 'A' + 10;
  800fe8:	44 0f be c1          	movsbl %cl,%r8d
  800fec:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800ff0:	eb c5                	jmp    800fb7 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800ff2:	48 85 f6             	test   %rsi,%rsi
  800ff5:	74 03                	je     800ffa <strtol+0xd6>
    *endptr = (char *)s;
  800ff7:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800ffa:	48 89 c2             	mov    %rax,%rdx
  800ffd:	48 f7 da             	neg    %rdx
  801000:	45 85 c9             	test   %r9d,%r9d
  801003:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801007:	c3                   	retq   

0000000000801008 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  801008:	55                   	push   %rbp
  801009:	48 89 e5             	mov    %rsp,%rbp
  80100c:	53                   	push   %rbx
  80100d:	48 89 fa             	mov    %rdi,%rdx
  801010:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
  801018:	48 89 c3             	mov    %rax,%rbx
  80101b:	48 89 c7             	mov    %rax,%rdi
  80101e:	48 89 c6             	mov    %rax,%rsi
  801021:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801023:	5b                   	pop    %rbx
  801024:	5d                   	pop    %rbp
  801025:	c3                   	retq   

0000000000801026 <sys_cgetc>:

int
sys_cgetc(void) {
  801026:	55                   	push   %rbp
  801027:	48 89 e5             	mov    %rsp,%rbp
  80102a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80102b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801030:	b8 01 00 00 00       	mov    $0x1,%eax
  801035:	48 89 ca             	mov    %rcx,%rdx
  801038:	48 89 cb             	mov    %rcx,%rbx
  80103b:	48 89 cf             	mov    %rcx,%rdi
  80103e:	48 89 ce             	mov    %rcx,%rsi
  801041:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801043:	5b                   	pop    %rbx
  801044:	5d                   	pop    %rbp
  801045:	c3                   	retq   

0000000000801046 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801046:	55                   	push   %rbp
  801047:	48 89 e5             	mov    %rsp,%rbp
  80104a:	53                   	push   %rbx
  80104b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80104f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801052:	be 00 00 00 00       	mov    $0x0,%esi
  801057:	b8 03 00 00 00       	mov    $0x3,%eax
  80105c:	48 89 f1             	mov    %rsi,%rcx
  80105f:	48 89 f3             	mov    %rsi,%rbx
  801062:	48 89 f7             	mov    %rsi,%rdi
  801065:	cd 30                	int    $0x30
  if (check && ret > 0)
  801067:	48 85 c0             	test   %rax,%rax
  80106a:	7f 07                	jg     801073 <sys_env_destroy+0x2d>
}
  80106c:	48 83 c4 08          	add    $0x8,%rsp
  801070:	5b                   	pop    %rbx
  801071:	5d                   	pop    %rbp
  801072:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801073:	49 89 c0             	mov    %rax,%r8
  801076:	b9 03 00 00 00       	mov    $0x3,%ecx
  80107b:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  801082:	00 00 00 
  801085:	be 22 00 00 00       	mov    $0x22,%esi
  80108a:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  801091:	00 00 00 
  801094:	b8 00 00 00 00       	mov    $0x0,%eax
  801099:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  8010a0:	00 00 00 
  8010a3:	41 ff d1             	callq  *%r9

00000000008010a6 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8010a6:	55                   	push   %rbp
  8010a7:	48 89 e5             	mov    %rsp,%rbp
  8010aa:	53                   	push   %rbx
  asm volatile("int %1\n"
  8010ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010b5:	48 89 ca             	mov    %rcx,%rdx
  8010b8:	48 89 cb             	mov    %rcx,%rbx
  8010bb:	48 89 cf             	mov    %rcx,%rdi
  8010be:	48 89 ce             	mov    %rcx,%rsi
  8010c1:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010c3:	5b                   	pop    %rbx
  8010c4:	5d                   	pop    %rbp
  8010c5:	c3                   	retq   

00000000008010c6 <sys_yield>:

void
sys_yield(void) {
  8010c6:	55                   	push   %rbp
  8010c7:	48 89 e5             	mov    %rsp,%rbp
  8010ca:	53                   	push   %rbx
  asm volatile("int %1\n"
  8010cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010d5:	48 89 ca             	mov    %rcx,%rdx
  8010d8:	48 89 cb             	mov    %rcx,%rbx
  8010db:	48 89 cf             	mov    %rcx,%rdi
  8010de:	48 89 ce             	mov    %rcx,%rsi
  8010e1:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e3:	5b                   	pop    %rbx
  8010e4:	5d                   	pop    %rbp
  8010e5:	c3                   	retq   

00000000008010e6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010e6:	55                   	push   %rbp
  8010e7:	48 89 e5             	mov    %rsp,%rbp
  8010ea:	53                   	push   %rbx
  8010eb:	48 83 ec 08          	sub    $0x8,%rsp
  8010ef:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010f2:	4c 63 c7             	movslq %edi,%r8
  8010f5:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010f8:	be 00 00 00 00       	mov    $0x0,%esi
  8010fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801102:	4c 89 c2             	mov    %r8,%rdx
  801105:	48 89 f7             	mov    %rsi,%rdi
  801108:	cd 30                	int    $0x30
  if (check && ret > 0)
  80110a:	48 85 c0             	test   %rax,%rax
  80110d:	7f 07                	jg     801116 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80110f:	48 83 c4 08          	add    $0x8,%rsp
  801113:	5b                   	pop    %rbx
  801114:	5d                   	pop    %rbp
  801115:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801116:	49 89 c0             	mov    %rax,%r8
  801119:	b9 04 00 00 00       	mov    $0x4,%ecx
  80111e:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  801125:	00 00 00 
  801128:	be 22 00 00 00       	mov    $0x22,%esi
  80112d:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  801134:	00 00 00 
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  801143:	00 00 00 
  801146:	41 ff d1             	callq  *%r9

0000000000801149 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801149:	55                   	push   %rbp
  80114a:	48 89 e5             	mov    %rsp,%rbp
  80114d:	53                   	push   %rbx
  80114e:	48 83 ec 08          	sub    $0x8,%rsp
  801152:	41 89 f9             	mov    %edi,%r9d
  801155:	49 89 f2             	mov    %rsi,%r10
  801158:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80115b:	4d 63 c9             	movslq %r9d,%r9
  80115e:	48 63 da             	movslq %edx,%rbx
  801161:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801164:	b8 05 00 00 00       	mov    $0x5,%eax
  801169:	4c 89 ca             	mov    %r9,%rdx
  80116c:	4c 89 d1             	mov    %r10,%rcx
  80116f:	cd 30                	int    $0x30
  if (check && ret > 0)
  801171:	48 85 c0             	test   %rax,%rax
  801174:	7f 07                	jg     80117d <sys_page_map+0x34>
}
  801176:	48 83 c4 08          	add    $0x8,%rsp
  80117a:	5b                   	pop    %rbx
  80117b:	5d                   	pop    %rbp
  80117c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80117d:	49 89 c0             	mov    %rax,%r8
  801180:	b9 05 00 00 00       	mov    $0x5,%ecx
  801185:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  80118c:	00 00 00 
  80118f:	be 22 00 00 00       	mov    $0x22,%esi
  801194:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  80119b:	00 00 00 
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  8011aa:	00 00 00 
  8011ad:	41 ff d1             	callq  *%r9

00000000008011b0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8011b0:	55                   	push   %rbp
  8011b1:	48 89 e5             	mov    %rsp,%rbp
  8011b4:	53                   	push   %rbx
  8011b5:	48 83 ec 08          	sub    $0x8,%rsp
  8011b9:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8011bc:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8011bf:	be 00 00 00 00       	mov    $0x0,%esi
  8011c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8011c9:	48 89 f3             	mov    %rsi,%rbx
  8011cc:	48 89 f7             	mov    %rsi,%rdi
  8011cf:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011d1:	48 85 c0             	test   %rax,%rax
  8011d4:	7f 07                	jg     8011dd <sys_page_unmap+0x2d>
}
  8011d6:	48 83 c4 08          	add    $0x8,%rsp
  8011da:	5b                   	pop    %rbx
  8011db:	5d                   	pop    %rbp
  8011dc:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011dd:	49 89 c0             	mov    %rax,%r8
  8011e0:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011e5:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  8011ec:	00 00 00 
  8011ef:	be 22 00 00 00       	mov    $0x22,%esi
  8011f4:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  8011fb:	00 00 00 
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801203:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  80120a:	00 00 00 
  80120d:	41 ff d1             	callq  *%r9

0000000000801210 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  801210:	55                   	push   %rbp
  801211:	48 89 e5             	mov    %rsp,%rbp
  801214:	53                   	push   %rbx
  801215:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801219:	48 63 d7             	movslq %edi,%rdx
  80121c:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801224:	b8 08 00 00 00       	mov    $0x8,%eax
  801229:	48 89 df             	mov    %rbx,%rdi
  80122c:	48 89 de             	mov    %rbx,%rsi
  80122f:	cd 30                	int    $0x30
  if (check && ret > 0)
  801231:	48 85 c0             	test   %rax,%rax
  801234:	7f 07                	jg     80123d <sys_env_set_status+0x2d>
}
  801236:	48 83 c4 08          	add    $0x8,%rsp
  80123a:	5b                   	pop    %rbx
  80123b:	5d                   	pop    %rbp
  80123c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80123d:	49 89 c0             	mov    %rax,%r8
  801240:	b9 08 00 00 00       	mov    $0x8,%ecx
  801245:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  80124c:	00 00 00 
  80124f:	be 22 00 00 00       	mov    $0x22,%esi
  801254:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  80125b:	00 00 00 
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  80126a:	00 00 00 
  80126d:	41 ff d1             	callq  *%r9

0000000000801270 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801270:	55                   	push   %rbp
  801271:	48 89 e5             	mov    %rsp,%rbp
  801274:	53                   	push   %rbx
  801275:	48 83 ec 08          	sub    $0x8,%rsp
  801279:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80127c:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80127f:	be 00 00 00 00       	mov    $0x0,%esi
  801284:	b8 09 00 00 00       	mov    $0x9,%eax
  801289:	48 89 f3             	mov    %rsi,%rbx
  80128c:	48 89 f7             	mov    %rsi,%rdi
  80128f:	cd 30                	int    $0x30
  if (check && ret > 0)
  801291:	48 85 c0             	test   %rax,%rax
  801294:	7f 07                	jg     80129d <sys_env_set_pgfault_upcall+0x2d>
}
  801296:	48 83 c4 08          	add    $0x8,%rsp
  80129a:	5b                   	pop    %rbx
  80129b:	5d                   	pop    %rbp
  80129c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80129d:	49 89 c0             	mov    %rax,%r8
  8012a0:	b9 09 00 00 00       	mov    $0x9,%ecx
  8012a5:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  8012ac:	00 00 00 
  8012af:	be 22 00 00 00       	mov    $0x22,%esi
  8012b4:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  8012bb:	00 00 00 
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c3:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  8012ca:	00 00 00 
  8012cd:	41 ff d1             	callq  *%r9

00000000008012d0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8012d0:	55                   	push   %rbp
  8012d1:	48 89 e5             	mov    %rsp,%rbp
  8012d4:	53                   	push   %rbx
  8012d5:	49 89 f0             	mov    %rsi,%r8
  8012d8:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8012db:	48 63 d7             	movslq %edi,%rdx
  8012de:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8012e1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012e6:	be 00 00 00 00       	mov    $0x0,%esi
  8012eb:	4c 89 c1             	mov    %r8,%rcx
  8012ee:	cd 30                	int    $0x30
}
  8012f0:	5b                   	pop    %rbx
  8012f1:	5d                   	pop    %rbp
  8012f2:	c3                   	retq   

00000000008012f3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012f3:	55                   	push   %rbp
  8012f4:	48 89 e5             	mov    %rsp,%rbp
  8012f7:	53                   	push   %rbx
  8012f8:	48 83 ec 08          	sub    $0x8,%rsp
  8012fc:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012ff:	be 00 00 00 00       	mov    $0x0,%esi
  801304:	b8 0c 00 00 00       	mov    $0xc,%eax
  801309:	48 89 f1             	mov    %rsi,%rcx
  80130c:	48 89 f3             	mov    %rsi,%rbx
  80130f:	48 89 f7             	mov    %rsi,%rdi
  801312:	cd 30                	int    $0x30
  if (check && ret > 0)
  801314:	48 85 c0             	test   %rax,%rax
  801317:	7f 07                	jg     801320 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  801319:	48 83 c4 08          	add    $0x8,%rsp
  80131d:	5b                   	pop    %rbx
  80131e:	5d                   	pop    %rbp
  80131f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801320:	49 89 c0             	mov    %rax,%r8
  801323:	b9 0c 00 00 00       	mov    $0xc,%ecx
  801328:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  80132f:	00 00 00 
  801332:	be 22 00 00 00       	mov    $0x22,%esi
  801337:	48 bf 7f 19 80 00 00 	movabs $0x80197f,%rdi
  80133e:	00 00 00 
  801341:	b8 00 00 00 00       	mov    $0x0,%eax
  801346:	49 b9 40 14 80 00 00 	movabs $0x801440,%r9
  80134d:	00 00 00 
  801350:	41 ff d1             	callq  *%r9

0000000000801353 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801353:	55                   	push   %rbp
  801354:	48 89 e5             	mov    %rsp,%rbp
  801357:	41 54                	push   %r12
  801359:	53                   	push   %rbx
  80135a:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  80135d:	48 b8 a6 10 80 00 00 	movabs $0x8010a6,%rax
  801364:	00 00 00 
  801367:	ff d0                	callq  *%rax
  801369:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  80136b:	48 b8 10 20 80 00 00 	movabs $0x802010,%rax
  801372:	00 00 00 
  801375:	48 83 38 00          	cmpq   $0x0,(%rax)
  801379:	74 2e                	je     8013a9 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  80137b:	4c 89 e0             	mov    %r12,%rax
  80137e:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  801385:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801388:	48 be f5 13 80 00 00 	movabs $0x8013f5,%rsi
  80138f:	00 00 00 
  801392:	89 df                	mov    %ebx,%edi
  801394:	48 b8 70 12 80 00 00 	movabs $0x801270,%rax
  80139b:	00 00 00 
  80139e:	ff d0                	callq  *%rax
  if (error < 0)
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 24                	js     8013c8 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  8013a4:	5b                   	pop    %rbx
  8013a5:	41 5c                	pop    %r12
  8013a7:	5d                   	pop    %rbp
  8013a8:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  8013a9:	ba 02 00 00 00       	mov    $0x2,%edx
  8013ae:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8013b5:	00 00 00 
  8013b8:	89 df                	mov    %ebx,%edi
  8013ba:	48 b8 e6 10 80 00 00 	movabs $0x8010e6,%rax
  8013c1:	00 00 00 
  8013c4:	ff d0                	callq  *%rax
  8013c6:	eb b3                	jmp    80137b <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  8013c8:	89 c1                	mov    %eax,%ecx
  8013ca:	48 ba 8d 19 80 00 00 	movabs $0x80198d,%rdx
  8013d1:	00 00 00 
  8013d4:	be 2c 00 00 00       	mov    $0x2c,%esi
  8013d9:	48 bf a5 19 80 00 00 	movabs $0x8019a5,%rdi
  8013e0:	00 00 00 
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e8:	49 b8 40 14 80 00 00 	movabs $0x801440,%r8
  8013ef:	00 00 00 
  8013f2:	41 ff d0             	callq  *%r8

00000000008013f5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  8013f5:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  8013f8:	48 a1 10 20 80 00 00 	movabs 0x802010,%rax
  8013ff:	00 00 00 
	call *%rax
  801402:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801404:	41 5f                	pop    %r15
	popq %r15
  801406:	41 5f                	pop    %r15
	popq %r15
  801408:	41 5f                	pop    %r15
	popq %r14
  80140a:	41 5e                	pop    %r14
	popq %r13
  80140c:	41 5d                	pop    %r13
	popq %r12
  80140e:	41 5c                	pop    %r12
	popq %r11
  801410:	41 5b                	pop    %r11
	popq %r10
  801412:	41 5a                	pop    %r10
	popq %r9
  801414:	41 59                	pop    %r9
	popq %r8
  801416:	41 58                	pop    %r8
	popq %rsi
  801418:	5e                   	pop    %rsi
	popq %rdi
  801419:	5f                   	pop    %rdi
	popq %rbp
  80141a:	5d                   	pop    %rbp
	popq %rdx
  80141b:	5a                   	pop    %rdx
	popq %rcx
  80141c:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  80141d:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801422:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801427:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  80142b:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  80142e:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801433:	5b                   	pop    %rbx
	popq %rax
  801434:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801435:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801439:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  80143a:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  80143f:	c3                   	retq   

0000000000801440 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801440:	55                   	push   %rbp
  801441:	48 89 e5             	mov    %rsp,%rbp
  801444:	41 56                	push   %r14
  801446:	41 55                	push   %r13
  801448:	41 54                	push   %r12
  80144a:	53                   	push   %rbx
  80144b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801452:	49 89 fd             	mov    %rdi,%r13
  801455:	41 89 f6             	mov    %esi,%r14d
  801458:	49 89 d4             	mov    %rdx,%r12
  80145b:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801462:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801469:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801470:	84 c0                	test   %al,%al
  801472:	74 26                	je     80149a <_panic+0x5a>
  801474:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80147b:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801482:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801486:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80148a:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80148e:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801492:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801496:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80149a:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8014a1:	00 00 00 
  8014a4:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8014ab:	00 00 00 
  8014ae:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8014b2:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8014b9:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8014c0:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8014c7:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8014ce:	00 00 00 
  8014d1:	48 8b 18             	mov    (%rax),%rbx
  8014d4:	48 b8 a6 10 80 00 00 	movabs $0x8010a6,%rax
  8014db:	00 00 00 
  8014de:	ff d0                	callq  *%rax
  8014e0:	45 89 f0             	mov    %r14d,%r8d
  8014e3:	4c 89 e9             	mov    %r13,%rcx
  8014e6:	48 89 da             	mov    %rbx,%rdx
  8014e9:	89 c6                	mov    %eax,%esi
  8014eb:	48 bf b8 19 80 00 00 	movabs $0x8019b8,%rdi
  8014f2:	00 00 00 
  8014f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fa:	48 bb 14 02 80 00 00 	movabs $0x800214,%rbx
  801501:	00 00 00 
  801504:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801506:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80150d:	4c 89 e7             	mov    %r12,%rdi
  801510:	48 b8 ac 01 80 00 00 	movabs $0x8001ac,%rax
  801517:	00 00 00 
  80151a:	ff d0                	callq  *%rax
  cprintf("\n");
  80151c:	48 bf 5b 15 80 00 00 	movabs $0x80155b,%rdi
  801523:	00 00 00 
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80152d:	cc                   	int3   
  while (1)
  80152e:	eb fd                	jmp    80152d <_panic+0xed>
