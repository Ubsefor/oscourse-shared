
obj/user/pingpongs:     file format elf64-x86-64


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
  800023:	e8 5c 01 00 00       	callq  800184 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#include <inc/lib.h>

uint32_t val;

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 57                	push   %r15
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	48 83 ec 18          	sub    $0x18,%rsp
  envid_t who;
  uint32_t i;

  i = 0;
  if ((who = sfork()) != 0) {
  80003b:	48 b8 d3 18 80 00 00 	movabs $0x8018d3,%rax
  800042:	00 00 00 
  800045:	ff d0                	callq  *%rax
  800047:	89 45 cc             	mov    %eax,-0x34(%rbp)
  80004a:	85 c0                	test   %eax,%eax
  80004c:	0f 85 b8 00 00 00    	jne    80010a <umain+0xe0>
    ipc_send(who, 0, 0, 0);
  }

  while (1) {
    ipc_recv(&who, 0, 0);
    cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800052:	48 bb 08 30 80 00 00 	movabs $0x803008,%rbx
  800059:	00 00 00 
    ipc_recv(&who, 0, 0);
  80005c:	ba 00 00 00 00       	mov    $0x0,%edx
  800061:	be 00 00 00 00       	mov    $0x0,%esi
  800066:	48 8d 7d cc          	lea    -0x34(%rbp),%rdi
  80006a:	48 b8 01 19 80 00 00 	movabs $0x801901,%rax
  800071:	00 00 00 
  800074:	ff d0                	callq  *%rax
    cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800076:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  80007d:	00 00 00 
  800080:	4c 8b 20             	mov    (%rax),%r12
  800083:	45 8b bc 24 c8 00 00 	mov    0xc8(%r12),%r15d
  80008a:	00 
  80008b:	44 8b 75 cc          	mov    -0x34(%rbp),%r14d
  80008f:	44 8b 2b             	mov    (%rbx),%r13d
  800092:	48 b8 95 11 80 00 00 	movabs $0x801195,%rax
  800099:	00 00 00 
  80009c:	ff d0                	callq  *%rax
  80009e:	45 89 f9             	mov    %r15d,%r9d
  8000a1:	4d 89 e0             	mov    %r12,%r8
  8000a4:	44 89 f1             	mov    %r14d,%ecx
  8000a7:	44 89 ea             	mov    %r13d,%edx
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	48 bf b0 1c 80 00 00 	movabs $0x801cb0,%rdi
  8000b3:	00 00 00 
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	49 ba 03 03 80 00 00 	movabs $0x800303,%r10
  8000c2:	00 00 00 
  8000c5:	41 ff d2             	callq  *%r10
    if (val == 10)
  8000c8:	8b 03                	mov    (%rbx),%eax
  8000ca:	83 f8 0a             	cmp    $0xa,%eax
  8000cd:	74 2c                	je     8000fb <umain+0xd1>
      return;
    ++val;
  8000cf:	83 c0 01             	add    $0x1,%eax
  8000d2:	89 03                	mov    %eax,(%rbx)
    ipc_send(who, 0, 0, 0);
  8000d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000de:	be 00 00 00 00       	mov    $0x0,%esi
  8000e3:	8b 7d cc             	mov    -0x34(%rbp),%edi
  8000e6:	48 b8 80 19 80 00 00 	movabs $0x801980,%rax
  8000ed:	00 00 00 
  8000f0:	ff d0                	callq  *%rax
    if (val == 10)
  8000f2:	83 3b 0a             	cmpl   $0xa,(%rbx)
  8000f5:	0f 85 61 ff ff ff    	jne    80005c <umain+0x32>
      return;
  }
}
  8000fb:	48 83 c4 18          	add    $0x18,%rsp
  8000ff:	5b                   	pop    %rbx
  800100:	41 5c                	pop    %r12
  800102:	41 5d                	pop    %r13
  800104:	41 5e                	pop    %r14
  800106:	41 5f                	pop    %r15
  800108:	5d                   	pop    %rbp
  800109:	c3                   	retq   
    cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  80010a:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  800111:	00 00 00 
  800114:	48 8b 18             	mov    (%rax),%rbx
  800117:	49 bc 95 11 80 00 00 	movabs $0x801195,%r12
  80011e:	00 00 00 
  800121:	41 ff d4             	callq  *%r12
  800124:	48 89 da             	mov    %rbx,%rdx
  800127:	89 c6                	mov    %eax,%esi
  800129:	48 bf 80 1c 80 00 00 	movabs $0x801c80,%rdi
  800130:	00 00 00 
  800133:	b8 00 00 00 00       	mov    $0x0,%eax
  800138:	48 bb 03 03 80 00 00 	movabs $0x800303,%rbx
  80013f:	00 00 00 
  800142:	ff d3                	callq  *%rbx
    cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800144:	44 8b 6d cc          	mov    -0x34(%rbp),%r13d
  800148:	41 ff d4             	callq  *%r12
  80014b:	44 89 ea             	mov    %r13d,%edx
  80014e:	89 c6                	mov    %eax,%esi
  800150:	48 bf 9a 1c 80 00 00 	movabs $0x801c9a,%rdi
  800157:	00 00 00 
  80015a:	b8 00 00 00 00       	mov    $0x0,%eax
  80015f:	ff d3                	callq  *%rbx
    ipc_send(who, 0, 0, 0);
  800161:	b9 00 00 00 00       	mov    $0x0,%ecx
  800166:	ba 00 00 00 00       	mov    $0x0,%edx
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	8b 7d cc             	mov    -0x34(%rbp),%edi
  800173:	48 b8 80 19 80 00 00 	movabs $0x801980,%rax
  80017a:	00 00 00 
  80017d:	ff d0                	callq  *%rax
  80017f:	e9 ce fe ff ff       	jmpq   800052 <umain+0x28>

0000000000800184 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800184:	55                   	push   %rbp
  800185:	48 89 e5             	mov    %rsp,%rbp
  800188:	41 56                	push   %r14
  80018a:	41 55                	push   %r13
  80018c:	41 54                	push   %r12
  80018e:	53                   	push   %rbx
  80018f:	41 89 fd             	mov    %edi,%r13d
  800192:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800195:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  80019c:	00 00 00 
  80019f:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  8001a6:	00 00 00 
  8001a9:	48 39 c2             	cmp    %rax,%rdx
  8001ac:	73 23                	jae    8001d1 <libmain+0x4d>
  8001ae:	48 89 d3             	mov    %rdx,%rbx
  8001b1:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  8001b5:	48 29 d0             	sub    %rdx,%rax
  8001b8:	48 c1 e8 03          	shr    $0x3,%rax
  8001bc:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8001c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c6:	ff 13                	callq  *(%rbx)
    ctor++;
  8001c8:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8001cc:	4c 39 e3             	cmp    %r12,%rbx
  8001cf:	75 f0                	jne    8001c1 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8001d1:	48 b8 95 11 80 00 00 	movabs $0x801195,%rax
  8001d8:	00 00 00 
  8001db:	ff d0                	callq  *%rax
  8001dd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e2:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8001e6:	48 c1 e0 05          	shl    $0x5,%rax
  8001ea:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8001f1:	00 00 00 
  8001f4:	48 01 d0             	add    %rdx,%rax
  8001f7:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  8001fe:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800201:	45 85 ed             	test   %r13d,%r13d
  800204:	7e 0d                	jle    800213 <libmain+0x8f>
    binaryname = argv[0];
  800206:	49 8b 06             	mov    (%r14),%rax
  800209:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  800210:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800213:	4c 89 f6             	mov    %r14,%rsi
  800216:	44 89 ef             	mov    %r13d,%edi
  800219:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800220:	00 00 00 
  800223:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800225:	48 b8 3a 02 80 00 00 	movabs $0x80023a,%rax
  80022c:	00 00 00 
  80022f:	ff d0                	callq  *%rax
#endif
}
  800231:	5b                   	pop    %rbx
  800232:	41 5c                	pop    %r12
  800234:	41 5d                	pop    %r13
  800236:	41 5e                	pop    %r14
  800238:	5d                   	pop    %rbp
  800239:	c3                   	retq   

000000000080023a <exit>:

#include <inc/lib.h>

void
exit(void) {
  80023a:	55                   	push   %rbp
  80023b:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80023e:	bf 00 00 00 00       	mov    $0x0,%edi
  800243:	48 b8 35 11 80 00 00 	movabs $0x801135,%rax
  80024a:	00 00 00 
  80024d:	ff d0                	callq  *%rax
}
  80024f:	5d                   	pop    %rbp
  800250:	c3                   	retq   

0000000000800251 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800251:	55                   	push   %rbp
  800252:	48 89 e5             	mov    %rsp,%rbp
  800255:	53                   	push   %rbx
  800256:	48 83 ec 08          	sub    $0x8,%rsp
  80025a:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80025d:	8b 06                	mov    (%rsi),%eax
  80025f:	8d 50 01             	lea    0x1(%rax),%edx
  800262:	89 16                	mov    %edx,(%rsi)
  800264:	48 98                	cltq   
  800266:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80026b:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800271:	74 0b                	je     80027e <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800273:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800277:	48 83 c4 08          	add    $0x8,%rsp
  80027b:	5b                   	pop    %rbx
  80027c:	5d                   	pop    %rbp
  80027d:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80027e:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800282:	be ff 00 00 00       	mov    $0xff,%esi
  800287:	48 b8 f7 10 80 00 00 	movabs $0x8010f7,%rax
  80028e:	00 00 00 
  800291:	ff d0                	callq  *%rax
    b->idx = 0;
  800293:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800299:	eb d8                	jmp    800273 <putch+0x22>

000000000080029b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80029b:	55                   	push   %rbp
  80029c:	48 89 e5             	mov    %rsp,%rbp
  80029f:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002a6:	48 89 fa             	mov    %rdi,%rdx
  8002a9:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002b3:	00 00 00 
  b.cnt = 0;
  8002b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002bd:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8002c0:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8002c7:	48 bf 51 02 80 00 00 	movabs $0x800251,%rdi
  8002ce:	00 00 00 
  8002d1:	48 b8 c1 04 80 00 00 	movabs $0x8004c1,%rax
  8002d8:	00 00 00 
  8002db:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8002dd:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8002e4:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8002eb:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8002ef:	48 b8 f7 10 80 00 00 	movabs $0x8010f7,%rax
  8002f6:	00 00 00 
  8002f9:	ff d0                	callq  *%rax

  return b.cnt;
}
  8002fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800301:	c9                   	leaveq 
  800302:	c3                   	retq   

0000000000800303 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800303:	55                   	push   %rbp
  800304:	48 89 e5             	mov    %rsp,%rbp
  800307:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80030e:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800315:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80031c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800323:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80032a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800331:	84 c0                	test   %al,%al
  800333:	74 20                	je     800355 <cprintf+0x52>
  800335:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800339:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80033d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800341:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800345:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800349:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80034d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800351:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800355:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80035c:	00 00 00 
  80035f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800366:	00 00 00 
  800369:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80036d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800374:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80037b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800382:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800389:	48 b8 9b 02 80 00 00 	movabs $0x80029b,%rax
  800390:	00 00 00 
  800393:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800395:	c9                   	leaveq 
  800396:	c3                   	retq   

0000000000800397 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800397:	55                   	push   %rbp
  800398:	48 89 e5             	mov    %rsp,%rbp
  80039b:	41 57                	push   %r15
  80039d:	41 56                	push   %r14
  80039f:	41 55                	push   %r13
  8003a1:	41 54                	push   %r12
  8003a3:	53                   	push   %rbx
  8003a4:	48 83 ec 18          	sub    $0x18,%rsp
  8003a8:	49 89 fc             	mov    %rdi,%r12
  8003ab:	49 89 f5             	mov    %rsi,%r13
  8003ae:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003b2:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003b5:	41 89 cf             	mov    %ecx,%r15d
  8003b8:	49 39 d7             	cmp    %rdx,%r15
  8003bb:	76 45                	jbe    800402 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003bd:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 0e                	jle    8003d3 <printnum+0x3c>
      putch(padc, putdat);
  8003c5:	4c 89 ee             	mov    %r13,%rsi
  8003c8:	44 89 f7             	mov    %r14d,%edi
  8003cb:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8003ce:	83 eb 01             	sub    $0x1,%ebx
  8003d1:	75 f2                	jne    8003c5 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8003d3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	49 f7 f7             	div    %r15
  8003df:	48 b8 e0 1c 80 00 00 	movabs $0x801ce0,%rax
  8003e6:	00 00 00 
  8003e9:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8003ed:	4c 89 ee             	mov    %r13,%rsi
  8003f0:	41 ff d4             	callq  *%r12
}
  8003f3:	48 83 c4 18          	add    $0x18,%rsp
  8003f7:	5b                   	pop    %rbx
  8003f8:	41 5c                	pop    %r12
  8003fa:	41 5d                	pop    %r13
  8003fc:	41 5e                	pop    %r14
  8003fe:	41 5f                	pop    %r15
  800400:	5d                   	pop    %rbp
  800401:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800402:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
  80040b:	49 f7 f7             	div    %r15
  80040e:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800412:	48 89 c2             	mov    %rax,%rdx
  800415:	48 b8 97 03 80 00 00 	movabs $0x800397,%rax
  80041c:	00 00 00 
  80041f:	ff d0                	callq  *%rax
  800421:	eb b0                	jmp    8003d3 <printnum+0x3c>

0000000000800423 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800423:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800427:	48 8b 06             	mov    (%rsi),%rax
  80042a:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80042e:	73 0a                	jae    80043a <sprintputch+0x17>
    *b->buf++ = ch;
  800430:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800434:	48 89 16             	mov    %rdx,(%rsi)
  800437:	40 88 38             	mov    %dil,(%rax)
}
  80043a:	c3                   	retq   

000000000080043b <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80043b:	55                   	push   %rbp
  80043c:	48 89 e5             	mov    %rsp,%rbp
  80043f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800446:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80044d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800454:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80045b:	84 c0                	test   %al,%al
  80045d:	74 20                	je     80047f <printfmt+0x44>
  80045f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800463:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800467:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80046b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80046f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800473:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800477:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80047b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80047f:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800486:	00 00 00 
  800489:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800490:	00 00 00 
  800493:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800497:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80049e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004a5:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004ac:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004b3:	48 b8 c1 04 80 00 00 	movabs $0x8004c1,%rax
  8004ba:	00 00 00 
  8004bd:	ff d0                	callq  *%rax
}
  8004bf:	c9                   	leaveq 
  8004c0:	c3                   	retq   

00000000008004c1 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8004c1:	55                   	push   %rbp
  8004c2:	48 89 e5             	mov    %rsp,%rbp
  8004c5:	41 57                	push   %r15
  8004c7:	41 56                	push   %r14
  8004c9:	41 55                	push   %r13
  8004cb:	41 54                	push   %r12
  8004cd:	53                   	push   %rbx
  8004ce:	48 83 ec 48          	sub    $0x48,%rsp
  8004d2:	49 89 fd             	mov    %rdi,%r13
  8004d5:	49 89 f7             	mov    %rsi,%r15
  8004d8:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8004db:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8004df:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8004e3:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8004e7:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8004eb:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8004ef:	41 0f b6 3e          	movzbl (%r14),%edi
  8004f3:	83 ff 25             	cmp    $0x25,%edi
  8004f6:	74 18                	je     800510 <vprintfmt+0x4f>
      if (ch == '\0')
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	0f 84 8c 06 00 00    	je     800b8c <vprintfmt+0x6cb>
      putch(ch, putdat);
  800500:	4c 89 fe             	mov    %r15,%rsi
  800503:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800506:	49 89 de             	mov    %rbx,%r14
  800509:	eb e0                	jmp    8004eb <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80050b:	49 89 de             	mov    %rbx,%r14
  80050e:	eb db                	jmp    8004eb <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800510:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800514:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800518:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80051f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800525:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800529:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80052e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800534:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80053a:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80053f:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800544:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800548:	0f b6 13             	movzbl (%rbx),%edx
  80054b:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80054e:	3c 55                	cmp    $0x55,%al
  800550:	0f 87 8b 05 00 00    	ja     800ae1 <vprintfmt+0x620>
  800556:	0f b6 c0             	movzbl %al,%eax
  800559:	49 bb c0 1d 80 00 00 	movabs $0x801dc0,%r11
  800560:	00 00 00 
  800563:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800567:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80056a:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80056e:	eb d4                	jmp    800544 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800570:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800573:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800577:	eb cb                	jmp    800544 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800579:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80057c:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800580:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800584:	8d 50 d0             	lea    -0x30(%rax),%edx
  800587:	83 fa 09             	cmp    $0x9,%edx
  80058a:	77 7e                	ja     80060a <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80058c:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800590:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800594:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800599:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80059d:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005a0:	83 fa 09             	cmp    $0x9,%edx
  8005a3:	76 e7                	jbe    80058c <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005a5:	4c 89 f3             	mov    %r14,%rbx
  8005a8:	eb 19                	jmp    8005c3 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005aa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005ad:	83 f8 2f             	cmp    $0x2f,%eax
  8005b0:	77 2a                	ja     8005dc <vprintfmt+0x11b>
  8005b2:	89 c2                	mov    %eax,%edx
  8005b4:	4c 01 d2             	add    %r10,%rdx
  8005b7:	83 c0 08             	add    $0x8,%eax
  8005ba:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005bd:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8005c0:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8005c3:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005c7:	0f 89 77 ff ff ff    	jns    800544 <vprintfmt+0x83>
          width = precision, precision = -1;
  8005cd:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8005d1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8005d7:	e9 68 ff ff ff       	jmpq   800544 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8005dc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005e0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005e4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005e8:	eb d3                	jmp    8005bd <vprintfmt+0xfc>
        if (width < 0)
  8005ea:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	41 0f 48 c0          	cmovs  %r8d,%eax
  8005f3:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8005f6:	4c 89 f3             	mov    %r14,%rbx
  8005f9:	e9 46 ff ff ff       	jmpq   800544 <vprintfmt+0x83>
  8005fe:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800601:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800605:	e9 3a ff ff ff       	jmpq   800544 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80060a:	4c 89 f3             	mov    %r14,%rbx
  80060d:	eb b4                	jmp    8005c3 <vprintfmt+0x102>
        lflag++;
  80060f:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800612:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800615:	e9 2a ff ff ff       	jmpq   800544 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80061a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80061d:	83 f8 2f             	cmp    $0x2f,%eax
  800620:	77 19                	ja     80063b <vprintfmt+0x17a>
  800622:	89 c2                	mov    %eax,%edx
  800624:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800628:	83 c0 08             	add    $0x8,%eax
  80062b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80062e:	4c 89 fe             	mov    %r15,%rsi
  800631:	8b 3a                	mov    (%rdx),%edi
  800633:	41 ff d5             	callq  *%r13
        break;
  800636:	e9 b0 fe ff ff       	jmpq   8004eb <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80063b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80063f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800643:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800647:	eb e5                	jmp    80062e <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800649:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80064c:	83 f8 2f             	cmp    $0x2f,%eax
  80064f:	77 5b                	ja     8006ac <vprintfmt+0x1eb>
  800651:	89 c2                	mov    %eax,%edx
  800653:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800657:	83 c0 08             	add    $0x8,%eax
  80065a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80065d:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80065f:	89 c8                	mov    %ecx,%eax
  800661:	c1 f8 1f             	sar    $0x1f,%eax
  800664:	31 c1                	xor    %eax,%ecx
  800666:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800668:	83 f9 0b             	cmp    $0xb,%ecx
  80066b:	7f 4d                	jg     8006ba <vprintfmt+0x1f9>
  80066d:	48 63 c1             	movslq %ecx,%rax
  800670:	48 ba 80 20 80 00 00 	movabs $0x802080,%rdx
  800677:	00 00 00 
  80067a:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80067e:	48 85 c0             	test   %rax,%rax
  800681:	74 37                	je     8006ba <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800683:	48 89 c1             	mov    %rax,%rcx
  800686:	48 ba 01 1d 80 00 00 	movabs $0x801d01,%rdx
  80068d:	00 00 00 
  800690:	4c 89 fe             	mov    %r15,%rsi
  800693:	4c 89 ef             	mov    %r13,%rdi
  800696:	b8 00 00 00 00       	mov    $0x0,%eax
  80069b:	48 bb 3b 04 80 00 00 	movabs $0x80043b,%rbx
  8006a2:	00 00 00 
  8006a5:	ff d3                	callq  *%rbx
  8006a7:	e9 3f fe ff ff       	jmpq   8004eb <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006ac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006b0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006b4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006b8:	eb a3                	jmp    80065d <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006ba:	48 ba f8 1c 80 00 00 	movabs $0x801cf8,%rdx
  8006c1:	00 00 00 
  8006c4:	4c 89 fe             	mov    %r15,%rsi
  8006c7:	4c 89 ef             	mov    %r13,%rdi
  8006ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cf:	48 bb 3b 04 80 00 00 	movabs $0x80043b,%rbx
  8006d6:	00 00 00 
  8006d9:	ff d3                	callq  *%rbx
  8006db:	e9 0b fe ff ff       	jmpq   8004eb <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8006e0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006e3:	83 f8 2f             	cmp    $0x2f,%eax
  8006e6:	77 4b                	ja     800733 <vprintfmt+0x272>
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006ee:	83 c0 08             	add    $0x8,%eax
  8006f1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006f4:	48 8b 02             	mov    (%rdx),%rax
  8006f7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8006fb:	48 85 c0             	test   %rax,%rax
  8006fe:	0f 84 05 04 00 00    	je     800b09 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800704:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800708:	7e 06                	jle    800710 <vprintfmt+0x24f>
  80070a:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80070e:	75 31                	jne    800741 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800710:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800714:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800718:	0f b6 00             	movzbl (%rax),%eax
  80071b:	0f be f8             	movsbl %al,%edi
  80071e:	85 ff                	test   %edi,%edi
  800720:	0f 84 c3 00 00 00    	je     8007e9 <vprintfmt+0x328>
  800726:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80072a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80072e:	e9 85 00 00 00       	jmpq   8007b8 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800733:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800737:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80073b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80073f:	eb b3                	jmp    8006f4 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800741:	49 63 f4             	movslq %r12d,%rsi
  800744:	48 89 c7             	mov    %rax,%rdi
  800747:	48 b8 98 0c 80 00 00 	movabs $0x800c98,%rax
  80074e:	00 00 00 
  800751:	ff d0                	callq  *%rax
  800753:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800756:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800759:	85 f6                	test   %esi,%esi
  80075b:	7e 22                	jle    80077f <vprintfmt+0x2be>
            putch(padc, putdat);
  80075d:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800761:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800765:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800769:	4c 89 fe             	mov    %r15,%rsi
  80076c:	89 df                	mov    %ebx,%edi
  80076e:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800771:	41 83 ec 01          	sub    $0x1,%r12d
  800775:	75 f2                	jne    800769 <vprintfmt+0x2a8>
  800777:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80077b:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800783:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800787:	0f b6 00             	movzbl (%rax),%eax
  80078a:	0f be f8             	movsbl %al,%edi
  80078d:	85 ff                	test   %edi,%edi
  80078f:	0f 84 56 fd ff ff    	je     8004eb <vprintfmt+0x2a>
  800795:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800799:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80079d:	eb 19                	jmp    8007b8 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80079f:	4c 89 fe             	mov    %r15,%rsi
  8007a2:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a5:	41 83 ee 01          	sub    $0x1,%r14d
  8007a9:	48 83 c3 01          	add    $0x1,%rbx
  8007ad:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007b1:	0f be f8             	movsbl %al,%edi
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	74 29                	je     8007e1 <vprintfmt+0x320>
  8007b8:	45 85 e4             	test   %r12d,%r12d
  8007bb:	78 06                	js     8007c3 <vprintfmt+0x302>
  8007bd:	41 83 ec 01          	sub    $0x1,%r12d
  8007c1:	78 48                	js     80080b <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8007c3:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8007c7:	74 d6                	je     80079f <vprintfmt+0x2de>
  8007c9:	0f be c0             	movsbl %al,%eax
  8007cc:	83 e8 20             	sub    $0x20,%eax
  8007cf:	83 f8 5e             	cmp    $0x5e,%eax
  8007d2:	76 cb                	jbe    80079f <vprintfmt+0x2de>
            putch('?', putdat);
  8007d4:	4c 89 fe             	mov    %r15,%rsi
  8007d7:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8007dc:	41 ff d5             	callq  *%r13
  8007df:	eb c4                	jmp    8007a5 <vprintfmt+0x2e4>
  8007e1:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8007e5:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8007e9:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8007ec:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8007f0:	0f 8e f5 fc ff ff    	jle    8004eb <vprintfmt+0x2a>
          putch(' ', putdat);
  8007f6:	4c 89 fe             	mov    %r15,%rsi
  8007f9:	bf 20 00 00 00       	mov    $0x20,%edi
  8007fe:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800801:	83 eb 01             	sub    $0x1,%ebx
  800804:	75 f0                	jne    8007f6 <vprintfmt+0x335>
  800806:	e9 e0 fc ff ff       	jmpq   8004eb <vprintfmt+0x2a>
  80080b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80080f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800813:	eb d4                	jmp    8007e9 <vprintfmt+0x328>
  if (lflag >= 2)
  800815:	83 f9 01             	cmp    $0x1,%ecx
  800818:	7f 1d                	jg     800837 <vprintfmt+0x376>
  else if (lflag)
  80081a:	85 c9                	test   %ecx,%ecx
  80081c:	74 5e                	je     80087c <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80081e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800821:	83 f8 2f             	cmp    $0x2f,%eax
  800824:	77 48                	ja     80086e <vprintfmt+0x3ad>
  800826:	89 c2                	mov    %eax,%edx
  800828:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80082c:	83 c0 08             	add    $0x8,%eax
  80082f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800832:	48 8b 1a             	mov    (%rdx),%rbx
  800835:	eb 17                	jmp    80084e <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800837:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80083a:	83 f8 2f             	cmp    $0x2f,%eax
  80083d:	77 21                	ja     800860 <vprintfmt+0x39f>
  80083f:	89 c2                	mov    %eax,%edx
  800841:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800845:	83 c0 08             	add    $0x8,%eax
  800848:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80084b:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80084e:	48 85 db             	test   %rbx,%rbx
  800851:	78 50                	js     8008a3 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800853:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800856:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80085b:	e9 b4 01 00 00       	jmpq   800a14 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800860:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800864:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800868:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80086c:	eb dd                	jmp    80084b <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80086e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800872:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800876:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80087a:	eb b6                	jmp    800832 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80087c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80087f:	83 f8 2f             	cmp    $0x2f,%eax
  800882:	77 11                	ja     800895 <vprintfmt+0x3d4>
  800884:	89 c2                	mov    %eax,%edx
  800886:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80088a:	83 c0 08             	add    $0x8,%eax
  80088d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800890:	48 63 1a             	movslq (%rdx),%rbx
  800893:	eb b9                	jmp    80084e <vprintfmt+0x38d>
  800895:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800899:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80089d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a1:	eb ed                	jmp    800890 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008a3:	4c 89 fe             	mov    %r15,%rsi
  8008a6:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008ab:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008ae:	48 89 da             	mov    %rbx,%rdx
  8008b1:	48 f7 da             	neg    %rdx
        base = 10;
  8008b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008b9:	e9 56 01 00 00       	jmpq   800a14 <vprintfmt+0x553>
  if (lflag >= 2)
  8008be:	83 f9 01             	cmp    $0x1,%ecx
  8008c1:	7f 25                	jg     8008e8 <vprintfmt+0x427>
  else if (lflag)
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	74 5e                	je     800925 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8008c7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ca:	83 f8 2f             	cmp    $0x2f,%eax
  8008cd:	77 48                	ja     800917 <vprintfmt+0x456>
  8008cf:	89 c2                	mov    %eax,%edx
  8008d1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d5:	83 c0 08             	add    $0x8,%eax
  8008d8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008db:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8008de:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008e3:	e9 2c 01 00 00       	jmpq   800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008e8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008eb:	83 f8 2f             	cmp    $0x2f,%eax
  8008ee:	77 19                	ja     800909 <vprintfmt+0x448>
  8008f0:	89 c2                	mov    %eax,%edx
  8008f2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f6:	83 c0 08             	add    $0x8,%eax
  8008f9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fc:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8008ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800904:	e9 0b 01 00 00       	jmpq   800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800909:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800911:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800915:	eb e5                	jmp    8008fc <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800917:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80091b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800923:	eb b6                	jmp    8008db <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800925:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800928:	83 f8 2f             	cmp    $0x2f,%eax
  80092b:	77 18                	ja     800945 <vprintfmt+0x484>
  80092d:	89 c2                	mov    %eax,%edx
  80092f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800933:	83 c0 08             	add    $0x8,%eax
  800936:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800939:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80093b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800940:	e9 cf 00 00 00       	jmpq   800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800945:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800949:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800951:	eb e6                	jmp    800939 <vprintfmt+0x478>
  if (lflag >= 2)
  800953:	83 f9 01             	cmp    $0x1,%ecx
  800956:	7f 25                	jg     80097d <vprintfmt+0x4bc>
  else if (lflag)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 5b                	je     8009b7 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80095c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095f:	83 f8 2f             	cmp    $0x2f,%eax
  800962:	77 45                	ja     8009a9 <vprintfmt+0x4e8>
  800964:	89 c2                	mov    %eax,%edx
  800966:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096a:	83 c0 08             	add    $0x8,%eax
  80096d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800970:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800973:	b9 08 00 00 00       	mov    $0x8,%ecx
  800978:	e9 97 00 00 00       	jmpq   800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80097d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800980:	83 f8 2f             	cmp    $0x2f,%eax
  800983:	77 16                	ja     80099b <vprintfmt+0x4da>
  800985:	89 c2                	mov    %eax,%edx
  800987:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80098b:	83 c0 08             	add    $0x8,%eax
  80098e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800991:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800994:	b9 08 00 00 00       	mov    $0x8,%ecx
  800999:	eb 79                	jmp    800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80099b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80099f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a7:	eb e8                	jmp    800991 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009a9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ad:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b5:	eb b9                	jmp    800970 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009b7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ba:	83 f8 2f             	cmp    $0x2f,%eax
  8009bd:	77 15                	ja     8009d4 <vprintfmt+0x513>
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c5:	83 c0 08             	add    $0x8,%eax
  8009c8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009cb:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8009cd:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009d2:	eb 40                	jmp    800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009d4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009dc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e0:	eb e9                	jmp    8009cb <vprintfmt+0x50a>
        putch('0', putdat);
  8009e2:	4c 89 fe             	mov    %r15,%rsi
  8009e5:	bf 30 00 00 00       	mov    $0x30,%edi
  8009ea:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8009ed:	4c 89 fe             	mov    %r15,%rsi
  8009f0:	bf 78 00 00 00       	mov    $0x78,%edi
  8009f5:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8009f8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009fb:	83 f8 2f             	cmp    $0x2f,%eax
  8009fe:	77 34                	ja     800a34 <vprintfmt+0x573>
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a06:	83 c0 08             	add    $0x8,%eax
  800a09:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a0c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a0f:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a14:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a19:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a1d:	4c 89 fe             	mov    %r15,%rsi
  800a20:	4c 89 ef             	mov    %r13,%rdi
  800a23:	48 b8 97 03 80 00 00 	movabs $0x800397,%rax
  800a2a:	00 00 00 
  800a2d:	ff d0                	callq  *%rax
        break;
  800a2f:	e9 b7 fa ff ff       	jmpq   8004eb <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a34:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a38:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a3c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a40:	eb ca                	jmp    800a0c <vprintfmt+0x54b>
  if (lflag >= 2)
  800a42:	83 f9 01             	cmp    $0x1,%ecx
  800a45:	7f 22                	jg     800a69 <vprintfmt+0x5a8>
  else if (lflag)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 58                	je     800aa3 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a4b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a4e:	83 f8 2f             	cmp    $0x2f,%eax
  800a51:	77 42                	ja     800a95 <vprintfmt+0x5d4>
  800a53:	89 c2                	mov    %eax,%edx
  800a55:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a59:	83 c0 08             	add    $0x8,%eax
  800a5c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a5f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a62:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a67:	eb ab                	jmp    800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a69:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a6c:	83 f8 2f             	cmp    $0x2f,%eax
  800a6f:	77 16                	ja     800a87 <vprintfmt+0x5c6>
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a77:	83 c0 08             	add    $0x8,%eax
  800a7a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a7d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a80:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a85:	eb 8d                	jmp    800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a87:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a8b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a8f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a93:	eb e8                	jmp    800a7d <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800a95:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a99:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a9d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aa1:	eb bc                	jmp    800a5f <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800aa3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aa6:	83 f8 2f             	cmp    $0x2f,%eax
  800aa9:	77 18                	ja     800ac3 <vprintfmt+0x602>
  800aab:	89 c2                	mov    %eax,%edx
  800aad:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ab1:	83 c0 08             	add    $0x8,%eax
  800ab4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ab7:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800ab9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800abe:	e9 51 ff ff ff       	jmpq   800a14 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800ac3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ac7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800acb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800acf:	eb e6                	jmp    800ab7 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800ad1:	4c 89 fe             	mov    %r15,%rsi
  800ad4:	bf 25 00 00 00       	mov    $0x25,%edi
  800ad9:	41 ff d5             	callq  *%r13
        break;
  800adc:	e9 0a fa ff ff       	jmpq   8004eb <vprintfmt+0x2a>
        putch('%', putdat);
  800ae1:	4c 89 fe             	mov    %r15,%rsi
  800ae4:	bf 25 00 00 00       	mov    $0x25,%edi
  800ae9:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800aec:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800af0:	0f 84 15 fa ff ff    	je     80050b <vprintfmt+0x4a>
  800af6:	49 89 de             	mov    %rbx,%r14
  800af9:	49 83 ee 01          	sub    $0x1,%r14
  800afd:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b02:	75 f5                	jne    800af9 <vprintfmt+0x638>
  800b04:	e9 e2 f9 ff ff       	jmpq   8004eb <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b09:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b0d:	74 06                	je     800b15 <vprintfmt+0x654>
  800b0f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b13:	7f 21                	jg     800b36 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b15:	bf 28 00 00 00       	mov    $0x28,%edi
  800b1a:	48 bb f2 1c 80 00 00 	movabs $0x801cf2,%rbx
  800b21:	00 00 00 
  800b24:	b8 28 00 00 00       	mov    $0x28,%eax
  800b29:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b2d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b31:	e9 82 fc ff ff       	jmpq   8007b8 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b36:	49 63 f4             	movslq %r12d,%rsi
  800b39:	48 bf f1 1c 80 00 00 	movabs $0x801cf1,%rdi
  800b40:	00 00 00 
  800b43:	48 b8 98 0c 80 00 00 	movabs $0x800c98,%rax
  800b4a:	00 00 00 
  800b4d:	ff d0                	callq  *%rax
  800b4f:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b52:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b55:	48 be f1 1c 80 00 00 	movabs $0x801cf1,%rsi
  800b5c:	00 00 00 
  800b5f:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	0f 8f f2 fb ff ff    	jg     80075d <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b6b:	48 bb f2 1c 80 00 00 	movabs $0x801cf2,%rbx
  800b72:	00 00 00 
  800b75:	b8 28 00 00 00       	mov    $0x28,%eax
  800b7a:	bf 28 00 00 00       	mov    $0x28,%edi
  800b7f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b83:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b87:	e9 2c fc ff ff       	jmpq   8007b8 <vprintfmt+0x2f7>
}
  800b8c:	48 83 c4 48          	add    $0x48,%rsp
  800b90:	5b                   	pop    %rbx
  800b91:	41 5c                	pop    %r12
  800b93:	41 5d                	pop    %r13
  800b95:	41 5e                	pop    %r14
  800b97:	41 5f                	pop    %r15
  800b99:	5d                   	pop    %rbp
  800b9a:	c3                   	retq   

0000000000800b9b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800b9b:	55                   	push   %rbp
  800b9c:	48 89 e5             	mov    %rsp,%rbp
  800b9f:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ba3:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ba7:	48 63 c6             	movslq %esi,%rax
  800baa:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800baf:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800bba:	48 85 ff             	test   %rdi,%rdi
  800bbd:	74 2a                	je     800be9 <vsnprintf+0x4e>
  800bbf:	85 f6                	test   %esi,%esi
  800bc1:	7e 26                	jle    800be9 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800bc3:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800bc7:	48 bf 23 04 80 00 00 	movabs $0x800423,%rdi
  800bce:	00 00 00 
  800bd1:	48 b8 c1 04 80 00 00 	movabs $0x8004c1,%rax
  800bd8:	00 00 00 
  800bdb:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800bdd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800be1:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800be4:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800be7:	c9                   	leaveq 
  800be8:	c3                   	retq   
    return -E_INVAL;
  800be9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bee:	eb f7                	jmp    800be7 <vsnprintf+0x4c>

0000000000800bf0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800bf0:	55                   	push   %rbp
  800bf1:	48 89 e5             	mov    %rsp,%rbp
  800bf4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800bfb:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c02:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c09:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c10:	84 c0                	test   %al,%al
  800c12:	74 20                	je     800c34 <snprintf+0x44>
  800c14:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c18:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c1c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c20:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c24:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c28:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c2c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c30:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c34:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c3b:	00 00 00 
  800c3e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c45:	00 00 00 
  800c48:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c4c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c53:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c5a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c61:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c68:	48 b8 9b 0b 80 00 00 	movabs $0x800b9b,%rax
  800c6f:	00 00 00 
  800c72:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800c74:	c9                   	leaveq 
  800c75:	c3                   	retq   

0000000000800c76 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800c76:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c79:	74 17                	je     800c92 <strlen+0x1c>
  800c7b:	48 89 fa             	mov    %rdi,%rdx
  800c7e:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c83:	29 f9                	sub    %edi,%ecx
    n++;
  800c85:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800c88:	48 83 c2 01          	add    $0x1,%rdx
  800c8c:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c8f:	75 f4                	jne    800c85 <strlen+0xf>
  800c91:	c3                   	retq   
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c97:	c3                   	retq   

0000000000800c98 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c98:	48 85 f6             	test   %rsi,%rsi
  800c9b:	74 24                	je     800cc1 <strnlen+0x29>
  800c9d:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ca0:	74 25                	je     800cc7 <strnlen+0x2f>
  800ca2:	48 01 fe             	add    %rdi,%rsi
  800ca5:	48 89 fa             	mov    %rdi,%rdx
  800ca8:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cad:	29 f9                	sub    %edi,%ecx
    n++;
  800caf:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb2:	48 83 c2 01          	add    $0x1,%rdx
  800cb6:	48 39 f2             	cmp    %rsi,%rdx
  800cb9:	74 11                	je     800ccc <strnlen+0x34>
  800cbb:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cbe:	75 ef                	jne    800caf <strnlen+0x17>
  800cc0:	c3                   	retq   
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	c3                   	retq   
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800ccc:	c3                   	retq   

0000000000800ccd <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800ccd:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800cd9:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800cdc:	48 83 c2 01          	add    $0x1,%rdx
  800ce0:	84 c9                	test   %cl,%cl
  800ce2:	75 f1                	jne    800cd5 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800ce4:	c3                   	retq   

0000000000800ce5 <strcat>:

char *
strcat(char *dst, const char *src) {
  800ce5:	55                   	push   %rbp
  800ce6:	48 89 e5             	mov    %rsp,%rbp
  800ce9:	41 54                	push   %r12
  800ceb:	53                   	push   %rbx
  800cec:	48 89 fb             	mov    %rdi,%rbx
  800cef:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800cf2:	48 b8 76 0c 80 00 00 	movabs $0x800c76,%rax
  800cf9:	00 00 00 
  800cfc:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800cfe:	48 63 f8             	movslq %eax,%rdi
  800d01:	48 01 df             	add    %rbx,%rdi
  800d04:	4c 89 e6             	mov    %r12,%rsi
  800d07:	48 b8 cd 0c 80 00 00 	movabs $0x800ccd,%rax
  800d0e:	00 00 00 
  800d11:	ff d0                	callq  *%rax
  return dst;
}
  800d13:	48 89 d8             	mov    %rbx,%rax
  800d16:	5b                   	pop    %rbx
  800d17:	41 5c                	pop    %r12
  800d19:	5d                   	pop    %rbp
  800d1a:	c3                   	retq   

0000000000800d1b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d1b:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d1e:	48 85 d2             	test   %rdx,%rdx
  800d21:	74 1f                	je     800d42 <strncpy+0x27>
  800d23:	48 01 fa             	add    %rdi,%rdx
  800d26:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d29:	48 83 c1 01          	add    $0x1,%rcx
  800d2d:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d31:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d35:	41 80 f8 01          	cmp    $0x1,%r8b
  800d39:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d3d:	48 39 ca             	cmp    %rcx,%rdx
  800d40:	75 e7                	jne    800d29 <strncpy+0xe>
  }
  return ret;
}
  800d42:	c3                   	retq   

0000000000800d43 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d43:	48 89 f8             	mov    %rdi,%rax
  800d46:	48 85 d2             	test   %rdx,%rdx
  800d49:	74 36                	je     800d81 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d4b:	48 83 fa 01          	cmp    $0x1,%rdx
  800d4f:	74 2d                	je     800d7e <strlcpy+0x3b>
  800d51:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d55:	45 84 c0             	test   %r8b,%r8b
  800d58:	74 24                	je     800d7e <strlcpy+0x3b>
  800d5a:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d5e:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d63:	48 83 c0 01          	add    $0x1,%rax
  800d67:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d6b:	48 39 d1             	cmp    %rdx,%rcx
  800d6e:	74 0e                	je     800d7e <strlcpy+0x3b>
  800d70:	48 83 c1 01          	add    $0x1,%rcx
  800d74:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800d79:	45 84 c0             	test   %r8b,%r8b
  800d7c:	75 e5                	jne    800d63 <strlcpy+0x20>
    *dst = '\0';
  800d7e:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800d81:	48 29 f8             	sub    %rdi,%rax
}
  800d84:	c3                   	retq   

0000000000800d85 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800d85:	0f b6 07             	movzbl (%rdi),%eax
  800d88:	84 c0                	test   %al,%al
  800d8a:	74 17                	je     800da3 <strcmp+0x1e>
  800d8c:	3a 06                	cmp    (%rsi),%al
  800d8e:	75 13                	jne    800da3 <strcmp+0x1e>
    p++, q++;
  800d90:	48 83 c7 01          	add    $0x1,%rdi
  800d94:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800d98:	0f b6 07             	movzbl (%rdi),%eax
  800d9b:	84 c0                	test   %al,%al
  800d9d:	74 04                	je     800da3 <strcmp+0x1e>
  800d9f:	3a 06                	cmp    (%rsi),%al
  800da1:	74 ed                	je     800d90 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800da3:	0f b6 c0             	movzbl %al,%eax
  800da6:	0f b6 16             	movzbl (%rsi),%edx
  800da9:	29 d0                	sub    %edx,%eax
}
  800dab:	c3                   	retq   

0000000000800dac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800dac:	48 85 d2             	test   %rdx,%rdx
  800daf:	74 2f                	je     800de0 <strncmp+0x34>
  800db1:	0f b6 07             	movzbl (%rdi),%eax
  800db4:	84 c0                	test   %al,%al
  800db6:	74 1f                	je     800dd7 <strncmp+0x2b>
  800db8:	3a 06                	cmp    (%rsi),%al
  800dba:	75 1b                	jne    800dd7 <strncmp+0x2b>
  800dbc:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800dbf:	48 83 c7 01          	add    $0x1,%rdi
  800dc3:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800dc7:	48 39 d7             	cmp    %rdx,%rdi
  800dca:	74 1a                	je     800de6 <strncmp+0x3a>
  800dcc:	0f b6 07             	movzbl (%rdi),%eax
  800dcf:	84 c0                	test   %al,%al
  800dd1:	74 04                	je     800dd7 <strncmp+0x2b>
  800dd3:	3a 06                	cmp    (%rsi),%al
  800dd5:	74 e8                	je     800dbf <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800dd7:	0f b6 07             	movzbl (%rdi),%eax
  800dda:	0f b6 16             	movzbl (%rsi),%edx
  800ddd:	29 d0                	sub    %edx,%eax
}
  800ddf:	c3                   	retq   
    return 0;
  800de0:	b8 00 00 00 00       	mov    $0x0,%eax
  800de5:	c3                   	retq   
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
  800deb:	c3                   	retq   

0000000000800dec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800dec:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800dee:	0f b6 07             	movzbl (%rdi),%eax
  800df1:	84 c0                	test   %al,%al
  800df3:	74 1e                	je     800e13 <strchr+0x27>
    if (*s == c)
  800df5:	40 38 c6             	cmp    %al,%sil
  800df8:	74 1f                	je     800e19 <strchr+0x2d>
  for (; *s; s++)
  800dfa:	48 83 c7 01          	add    $0x1,%rdi
  800dfe:	0f b6 07             	movzbl (%rdi),%eax
  800e01:	84 c0                	test   %al,%al
  800e03:	74 08                	je     800e0d <strchr+0x21>
    if (*s == c)
  800e05:	38 d0                	cmp    %dl,%al
  800e07:	75 f1                	jne    800dfa <strchr+0xe>
  for (; *s; s++)
  800e09:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e0c:	c3                   	retq   
  return 0;
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e12:	c3                   	retq   
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	c3                   	retq   
    if (*s == c)
  800e19:	48 89 f8             	mov    %rdi,%rax
  800e1c:	c3                   	retq   

0000000000800e1d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e1d:	48 89 f8             	mov    %rdi,%rax
  800e20:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e22:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e25:	40 38 f2             	cmp    %sil,%dl
  800e28:	74 13                	je     800e3d <strfind+0x20>
  800e2a:	84 d2                	test   %dl,%dl
  800e2c:	74 0f                	je     800e3d <strfind+0x20>
  for (; *s; s++)
  800e2e:	48 83 c0 01          	add    $0x1,%rax
  800e32:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e35:	38 ca                	cmp    %cl,%dl
  800e37:	74 04                	je     800e3d <strfind+0x20>
  800e39:	84 d2                	test   %dl,%dl
  800e3b:	75 f1                	jne    800e2e <strfind+0x11>
      break;
  return (char *)s;
}
  800e3d:	c3                   	retq   

0000000000800e3e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e3e:	48 85 d2             	test   %rdx,%rdx
  800e41:	74 3a                	je     800e7d <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e43:	48 89 f8             	mov    %rdi,%rax
  800e46:	48 09 d0             	or     %rdx,%rax
  800e49:	a8 03                	test   $0x3,%al
  800e4b:	75 28                	jne    800e75 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e4d:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e51:	89 f0                	mov    %esi,%eax
  800e53:	c1 e0 08             	shl    $0x8,%eax
  800e56:	89 f1                	mov    %esi,%ecx
  800e58:	c1 e1 18             	shl    $0x18,%ecx
  800e5b:	41 89 f0             	mov    %esi,%r8d
  800e5e:	41 c1 e0 10          	shl    $0x10,%r8d
  800e62:	44 09 c1             	or     %r8d,%ecx
  800e65:	09 ce                	or     %ecx,%esi
  800e67:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e69:	48 c1 ea 02          	shr    $0x2,%rdx
  800e6d:	48 89 d1             	mov    %rdx,%rcx
  800e70:	fc                   	cld    
  800e71:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e73:	eb 08                	jmp    800e7d <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800e75:	89 f0                	mov    %esi,%eax
  800e77:	48 89 d1             	mov    %rdx,%rcx
  800e7a:	fc                   	cld    
  800e7b:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800e7d:	48 89 f8             	mov    %rdi,%rax
  800e80:	c3                   	retq   

0000000000800e81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800e81:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800e84:	48 39 fe             	cmp    %rdi,%rsi
  800e87:	73 40                	jae    800ec9 <memmove+0x48>
  800e89:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800e8d:	48 39 f9             	cmp    %rdi,%rcx
  800e90:	76 37                	jbe    800ec9 <memmove+0x48>
    s += n;
    d += n;
  800e92:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e96:	48 89 fe             	mov    %rdi,%rsi
  800e99:	48 09 d6             	or     %rdx,%rsi
  800e9c:	48 09 ce             	or     %rcx,%rsi
  800e9f:	40 f6 c6 03          	test   $0x3,%sil
  800ea3:	75 14                	jne    800eb9 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800ea5:	48 83 ef 04          	sub    $0x4,%rdi
  800ea9:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ead:	48 c1 ea 02          	shr    $0x2,%rdx
  800eb1:	48 89 d1             	mov    %rdx,%rcx
  800eb4:	fd                   	std    
  800eb5:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800eb7:	eb 0e                	jmp    800ec7 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800eb9:	48 83 ef 01          	sub    $0x1,%rdi
  800ebd:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800ec1:	48 89 d1             	mov    %rdx,%rcx
  800ec4:	fd                   	std    
  800ec5:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800ec7:	fc                   	cld    
  800ec8:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ec9:	48 89 c1             	mov    %rax,%rcx
  800ecc:	48 09 d1             	or     %rdx,%rcx
  800ecf:	48 09 f1             	or     %rsi,%rcx
  800ed2:	f6 c1 03             	test   $0x3,%cl
  800ed5:	75 0e                	jne    800ee5 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ed7:	48 c1 ea 02          	shr    $0x2,%rdx
  800edb:	48 89 d1             	mov    %rdx,%rcx
  800ede:	48 89 c7             	mov    %rax,%rdi
  800ee1:	fc                   	cld    
  800ee2:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800ee4:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800ee5:	48 89 c7             	mov    %rax,%rdi
  800ee8:	48 89 d1             	mov    %rdx,%rcx
  800eeb:	fc                   	cld    
  800eec:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800eee:	c3                   	retq   

0000000000800eef <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800eef:	55                   	push   %rbp
  800ef0:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800ef3:	48 b8 81 0e 80 00 00 	movabs $0x800e81,%rax
  800efa:	00 00 00 
  800efd:	ff d0                	callq  *%rax
}
  800eff:	5d                   	pop    %rbp
  800f00:	c3                   	retq   

0000000000800f01 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f01:	55                   	push   %rbp
  800f02:	48 89 e5             	mov    %rsp,%rbp
  800f05:	41 57                	push   %r15
  800f07:	41 56                	push   %r14
  800f09:	41 55                	push   %r13
  800f0b:	41 54                	push   %r12
  800f0d:	53                   	push   %rbx
  800f0e:	48 83 ec 08          	sub    $0x8,%rsp
  800f12:	49 89 fe             	mov    %rdi,%r14
  800f15:	49 89 f7             	mov    %rsi,%r15
  800f18:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f1b:	48 89 f7             	mov    %rsi,%rdi
  800f1e:	48 b8 76 0c 80 00 00 	movabs $0x800c76,%rax
  800f25:	00 00 00 
  800f28:	ff d0                	callq  *%rax
  800f2a:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f2d:	4c 89 ee             	mov    %r13,%rsi
  800f30:	4c 89 f7             	mov    %r14,%rdi
  800f33:	48 b8 98 0c 80 00 00 	movabs $0x800c98,%rax
  800f3a:	00 00 00 
  800f3d:	ff d0                	callq  *%rax
  800f3f:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f42:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f46:	4d 39 e5             	cmp    %r12,%r13
  800f49:	74 26                	je     800f71 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f4b:	4c 89 e8             	mov    %r13,%rax
  800f4e:	4c 29 e0             	sub    %r12,%rax
  800f51:	48 39 d8             	cmp    %rbx,%rax
  800f54:	76 2a                	jbe    800f80 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f56:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f5a:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f5e:	4c 89 fe             	mov    %r15,%rsi
  800f61:	48 b8 ef 0e 80 00 00 	movabs $0x800eef,%rax
  800f68:	00 00 00 
  800f6b:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f6d:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800f71:	48 83 c4 08          	add    $0x8,%rsp
  800f75:	5b                   	pop    %rbx
  800f76:	41 5c                	pop    %r12
  800f78:	41 5d                	pop    %r13
  800f7a:	41 5e                	pop    %r14
  800f7c:	41 5f                	pop    %r15
  800f7e:	5d                   	pop    %rbp
  800f7f:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800f80:	49 83 ed 01          	sub    $0x1,%r13
  800f84:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f88:	4c 89 ea             	mov    %r13,%rdx
  800f8b:	4c 89 fe             	mov    %r15,%rsi
  800f8e:	48 b8 ef 0e 80 00 00 	movabs $0x800eef,%rax
  800f95:	00 00 00 
  800f98:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800f9a:	4d 01 ee             	add    %r13,%r14
  800f9d:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fa2:	eb c9                	jmp    800f6d <strlcat+0x6c>

0000000000800fa4 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fa4:	48 85 d2             	test   %rdx,%rdx
  800fa7:	74 3a                	je     800fe3 <memcmp+0x3f>
    if (*s1 != *s2)
  800fa9:	0f b6 0f             	movzbl (%rdi),%ecx
  800fac:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fb0:	44 38 c1             	cmp    %r8b,%cl
  800fb3:	75 1d                	jne    800fd2 <memcmp+0x2e>
  800fb5:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fba:	48 39 d0             	cmp    %rdx,%rax
  800fbd:	74 1e                	je     800fdd <memcmp+0x39>
    if (*s1 != *s2)
  800fbf:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800fc3:	48 83 c0 01          	add    $0x1,%rax
  800fc7:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800fcd:	44 38 c1             	cmp    %r8b,%cl
  800fd0:	74 e8                	je     800fba <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800fd2:	0f b6 c1             	movzbl %cl,%eax
  800fd5:	45 0f b6 c0          	movzbl %r8b,%r8d
  800fd9:	44 29 c0             	sub    %r8d,%eax
  800fdc:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe2:	c3                   	retq   
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe8:	c3                   	retq   

0000000000800fe9 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800fe9:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800fed:	48 39 c7             	cmp    %rax,%rdi
  800ff0:	73 19                	jae    80100b <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	40 38 37             	cmp    %sil,(%rdi)
  800ff7:	74 16                	je     80100f <memfind+0x26>
  for (; s < ends; s++)
  800ff9:	48 83 c7 01          	add    $0x1,%rdi
  800ffd:	48 39 f8             	cmp    %rdi,%rax
  801000:	74 08                	je     80100a <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801002:	38 17                	cmp    %dl,(%rdi)
  801004:	75 f3                	jne    800ff9 <memfind+0x10>
  for (; s < ends; s++)
  801006:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801009:	c3                   	retq   
  80100a:	c3                   	retq   
  for (; s < ends; s++)
  80100b:	48 89 f8             	mov    %rdi,%rax
  80100e:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80100f:	48 89 f8             	mov    %rdi,%rax
  801012:	c3                   	retq   

0000000000801013 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801013:	0f b6 07             	movzbl (%rdi),%eax
  801016:	3c 20                	cmp    $0x20,%al
  801018:	74 04                	je     80101e <strtol+0xb>
  80101a:	3c 09                	cmp    $0x9,%al
  80101c:	75 0f                	jne    80102d <strtol+0x1a>
    s++;
  80101e:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801022:	0f b6 07             	movzbl (%rdi),%eax
  801025:	3c 20                	cmp    $0x20,%al
  801027:	74 f5                	je     80101e <strtol+0xb>
  801029:	3c 09                	cmp    $0x9,%al
  80102b:	74 f1                	je     80101e <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80102d:	3c 2b                	cmp    $0x2b,%al
  80102f:	74 2b                	je     80105c <strtol+0x49>
  int neg  = 0;
  801031:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801037:	3c 2d                	cmp    $0x2d,%al
  801039:	74 2d                	je     801068 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80103b:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801041:	75 0f                	jne    801052 <strtol+0x3f>
  801043:	80 3f 30             	cmpb   $0x30,(%rdi)
  801046:	74 2c                	je     801074 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801048:	85 d2                	test   %edx,%edx
  80104a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104f:	0f 44 d0             	cmove  %eax,%edx
  801052:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801057:	4c 63 d2             	movslq %edx,%r10
  80105a:	eb 5c                	jmp    8010b8 <strtol+0xa5>
    s++;
  80105c:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801060:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801066:	eb d3                	jmp    80103b <strtol+0x28>
    s++, neg = 1;
  801068:	48 83 c7 01          	add    $0x1,%rdi
  80106c:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801072:	eb c7                	jmp    80103b <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801074:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801078:	74 0f                	je     801089 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80107a:	85 d2                	test   %edx,%edx
  80107c:	75 d4                	jne    801052 <strtol+0x3f>
    s++, base = 8;
  80107e:	48 83 c7 01          	add    $0x1,%rdi
  801082:	ba 08 00 00 00       	mov    $0x8,%edx
  801087:	eb c9                	jmp    801052 <strtol+0x3f>
    s += 2, base = 16;
  801089:	48 83 c7 02          	add    $0x2,%rdi
  80108d:	ba 10 00 00 00       	mov    $0x10,%edx
  801092:	eb be                	jmp    801052 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801094:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801098:	41 80 f8 19          	cmp    $0x19,%r8b
  80109c:	77 2f                	ja     8010cd <strtol+0xba>
      dig = *s - 'a' + 10;
  80109e:	44 0f be c1          	movsbl %cl,%r8d
  8010a2:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010a6:	39 d1                	cmp    %edx,%ecx
  8010a8:	7d 37                	jge    8010e1 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010aa:	48 83 c7 01          	add    $0x1,%rdi
  8010ae:	49 0f af c2          	imul   %r10,%rax
  8010b2:	48 63 c9             	movslq %ecx,%rcx
  8010b5:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010b8:	0f b6 0f             	movzbl (%rdi),%ecx
  8010bb:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010bf:	41 80 f8 09          	cmp    $0x9,%r8b
  8010c3:	77 cf                	ja     801094 <strtol+0x81>
      dig = *s - '0';
  8010c5:	0f be c9             	movsbl %cl,%ecx
  8010c8:	83 e9 30             	sub    $0x30,%ecx
  8010cb:	eb d9                	jmp    8010a6 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8010cd:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8010d1:	41 80 f8 19          	cmp    $0x19,%r8b
  8010d5:	77 0a                	ja     8010e1 <strtol+0xce>
      dig = *s - 'A' + 10;
  8010d7:	44 0f be c1          	movsbl %cl,%r8d
  8010db:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8010df:	eb c5                	jmp    8010a6 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8010e1:	48 85 f6             	test   %rsi,%rsi
  8010e4:	74 03                	je     8010e9 <strtol+0xd6>
    *endptr = (char *)s;
  8010e6:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8010e9:	48 89 c2             	mov    %rax,%rdx
  8010ec:	48 f7 da             	neg    %rdx
  8010ef:	45 85 c9             	test   %r9d,%r9d
  8010f2:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8010f6:	c3                   	retq   

00000000008010f7 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8010f7:	55                   	push   %rbp
  8010f8:	48 89 e5             	mov    %rsp,%rbp
  8010fb:	53                   	push   %rbx
  8010fc:	48 89 fa             	mov    %rdi,%rdx
  8010ff:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801102:	b8 00 00 00 00       	mov    $0x0,%eax
  801107:	48 89 c3             	mov    %rax,%rbx
  80110a:	48 89 c7             	mov    %rax,%rdi
  80110d:	48 89 c6             	mov    %rax,%rsi
  801110:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801112:	5b                   	pop    %rbx
  801113:	5d                   	pop    %rbp
  801114:	c3                   	retq   

0000000000801115 <sys_cgetc>:

int
sys_cgetc(void) {
  801115:	55                   	push   %rbp
  801116:	48 89 e5             	mov    %rsp,%rbp
  801119:	53                   	push   %rbx
  asm volatile("int %1\n"
  80111a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111f:	b8 01 00 00 00       	mov    $0x1,%eax
  801124:	48 89 ca             	mov    %rcx,%rdx
  801127:	48 89 cb             	mov    %rcx,%rbx
  80112a:	48 89 cf             	mov    %rcx,%rdi
  80112d:	48 89 ce             	mov    %rcx,%rsi
  801130:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801132:	5b                   	pop    %rbx
  801133:	5d                   	pop    %rbp
  801134:	c3                   	retq   

0000000000801135 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801135:	55                   	push   %rbp
  801136:	48 89 e5             	mov    %rsp,%rbp
  801139:	53                   	push   %rbx
  80113a:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80113e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801141:	be 00 00 00 00       	mov    $0x0,%esi
  801146:	b8 03 00 00 00       	mov    $0x3,%eax
  80114b:	48 89 f1             	mov    %rsi,%rcx
  80114e:	48 89 f3             	mov    %rsi,%rbx
  801151:	48 89 f7             	mov    %rsi,%rdi
  801154:	cd 30                	int    $0x30
  if (check && ret > 0)
  801156:	48 85 c0             	test   %rax,%rax
  801159:	7f 07                	jg     801162 <sys_env_destroy+0x2d>
}
  80115b:	48 83 c4 08          	add    $0x8,%rsp
  80115f:	5b                   	pop    %rbx
  801160:	5d                   	pop    %rbp
  801161:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801162:	49 89 c0             	mov    %rax,%r8
  801165:	b9 03 00 00 00       	mov    $0x3,%ecx
  80116a:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  801171:	00 00 00 
  801174:	be 22 00 00 00       	mov    $0x22,%esi
  801179:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  801180:	00 00 00 
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
  801188:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  80118f:	00 00 00 
  801192:	41 ff d1             	callq  *%r9

0000000000801195 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801195:	55                   	push   %rbp
  801196:	48 89 e5             	mov    %rsp,%rbp
  801199:	53                   	push   %rbx
  asm volatile("int %1\n"
  80119a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80119f:	b8 02 00 00 00       	mov    $0x2,%eax
  8011a4:	48 89 ca             	mov    %rcx,%rdx
  8011a7:	48 89 cb             	mov    %rcx,%rbx
  8011aa:	48 89 cf             	mov    %rcx,%rdi
  8011ad:	48 89 ce             	mov    %rcx,%rsi
  8011b0:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011b2:	5b                   	pop    %rbx
  8011b3:	5d                   	pop    %rbp
  8011b4:	c3                   	retq   

00000000008011b5 <sys_yield>:

void
sys_yield(void) {
  8011b5:	55                   	push   %rbp
  8011b6:	48 89 e5             	mov    %rsp,%rbp
  8011b9:	53                   	push   %rbx
  asm volatile("int %1\n"
  8011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011c4:	48 89 ca             	mov    %rcx,%rdx
  8011c7:	48 89 cb             	mov    %rcx,%rbx
  8011ca:	48 89 cf             	mov    %rcx,%rdi
  8011cd:	48 89 ce             	mov    %rcx,%rsi
  8011d0:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011d2:	5b                   	pop    %rbx
  8011d3:	5d                   	pop    %rbp
  8011d4:	c3                   	retq   

00000000008011d5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8011d5:	55                   	push   %rbp
  8011d6:	48 89 e5             	mov    %rsp,%rbp
  8011d9:	53                   	push   %rbx
  8011da:	48 83 ec 08          	sub    $0x8,%rsp
  8011de:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8011e1:	4c 63 c7             	movslq %edi,%r8
  8011e4:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8011e7:	be 00 00 00 00       	mov    $0x0,%esi
  8011ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f1:	4c 89 c2             	mov    %r8,%rdx
  8011f4:	48 89 f7             	mov    %rsi,%rdi
  8011f7:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011f9:	48 85 c0             	test   %rax,%rax
  8011fc:	7f 07                	jg     801205 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8011fe:	48 83 c4 08          	add    $0x8,%rsp
  801202:	5b                   	pop    %rbx
  801203:	5d                   	pop    %rbp
  801204:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801205:	49 89 c0             	mov    %rax,%r8
  801208:	b9 04 00 00 00       	mov    $0x4,%ecx
  80120d:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  801214:	00 00 00 
  801217:	be 22 00 00 00       	mov    $0x22,%esi
  80121c:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  801223:	00 00 00 
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
  80122b:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  801232:	00 00 00 
  801235:	41 ff d1             	callq  *%r9

0000000000801238 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801238:	55                   	push   %rbp
  801239:	48 89 e5             	mov    %rsp,%rbp
  80123c:	53                   	push   %rbx
  80123d:	48 83 ec 08          	sub    $0x8,%rsp
  801241:	41 89 f9             	mov    %edi,%r9d
  801244:	49 89 f2             	mov    %rsi,%r10
  801247:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80124a:	4d 63 c9             	movslq %r9d,%r9
  80124d:	48 63 da             	movslq %edx,%rbx
  801250:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801253:	b8 05 00 00 00       	mov    $0x5,%eax
  801258:	4c 89 ca             	mov    %r9,%rdx
  80125b:	4c 89 d1             	mov    %r10,%rcx
  80125e:	cd 30                	int    $0x30
  if (check && ret > 0)
  801260:	48 85 c0             	test   %rax,%rax
  801263:	7f 07                	jg     80126c <sys_page_map+0x34>
}
  801265:	48 83 c4 08          	add    $0x8,%rsp
  801269:	5b                   	pop    %rbx
  80126a:	5d                   	pop    %rbp
  80126b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80126c:	49 89 c0             	mov    %rax,%r8
  80126f:	b9 05 00 00 00       	mov    $0x5,%ecx
  801274:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  80127b:	00 00 00 
  80127e:	be 22 00 00 00       	mov    $0x22,%esi
  801283:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  80128a:	00 00 00 
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  801299:	00 00 00 
  80129c:	41 ff d1             	callq  *%r9

000000000080129f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80129f:	55                   	push   %rbp
  8012a0:	48 89 e5             	mov    %rsp,%rbp
  8012a3:	53                   	push   %rbx
  8012a4:	48 83 ec 08          	sub    $0x8,%rsp
  8012a8:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8012ab:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8012ae:	be 00 00 00 00       	mov    $0x0,%esi
  8012b3:	b8 06 00 00 00       	mov    $0x6,%eax
  8012b8:	48 89 f3             	mov    %rsi,%rbx
  8012bb:	48 89 f7             	mov    %rsi,%rdi
  8012be:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012c0:	48 85 c0             	test   %rax,%rax
  8012c3:	7f 07                	jg     8012cc <sys_page_unmap+0x2d>
}
  8012c5:	48 83 c4 08          	add    $0x8,%rsp
  8012c9:	5b                   	pop    %rbx
  8012ca:	5d                   	pop    %rbp
  8012cb:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012cc:	49 89 c0             	mov    %rax,%r8
  8012cf:	b9 06 00 00 00       	mov    $0x6,%ecx
  8012d4:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  8012db:	00 00 00 
  8012de:	be 22 00 00 00       	mov    $0x22,%esi
  8012e3:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  8012ea:	00 00 00 
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  8012f9:	00 00 00 
  8012fc:	41 ff d1             	callq  *%r9

00000000008012ff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8012ff:	55                   	push   %rbp
  801300:	48 89 e5             	mov    %rsp,%rbp
  801303:	53                   	push   %rbx
  801304:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801308:	48 63 d7             	movslq %edi,%rdx
  80130b:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801313:	b8 08 00 00 00       	mov    $0x8,%eax
  801318:	48 89 df             	mov    %rbx,%rdi
  80131b:	48 89 de             	mov    %rbx,%rsi
  80131e:	cd 30                	int    $0x30
  if (check && ret > 0)
  801320:	48 85 c0             	test   %rax,%rax
  801323:	7f 07                	jg     80132c <sys_env_set_status+0x2d>
}
  801325:	48 83 c4 08          	add    $0x8,%rsp
  801329:	5b                   	pop    %rbx
  80132a:	5d                   	pop    %rbp
  80132b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80132c:	49 89 c0             	mov    %rax,%r8
  80132f:	b9 08 00 00 00       	mov    $0x8,%ecx
  801334:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  80133b:	00 00 00 
  80133e:	be 22 00 00 00       	mov    $0x22,%esi
  801343:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  80134a:	00 00 00 
  80134d:	b8 00 00 00 00       	mov    $0x0,%eax
  801352:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  801359:	00 00 00 
  80135c:	41 ff d1             	callq  *%r9

000000000080135f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80135f:	55                   	push   %rbp
  801360:	48 89 e5             	mov    %rsp,%rbp
  801363:	53                   	push   %rbx
  801364:	48 83 ec 08          	sub    $0x8,%rsp
  801368:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80136b:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80136e:	be 00 00 00 00       	mov    $0x0,%esi
  801373:	b8 09 00 00 00       	mov    $0x9,%eax
  801378:	48 89 f3             	mov    %rsi,%rbx
  80137b:	48 89 f7             	mov    %rsi,%rdi
  80137e:	cd 30                	int    $0x30
  if (check && ret > 0)
  801380:	48 85 c0             	test   %rax,%rax
  801383:	7f 07                	jg     80138c <sys_env_set_pgfault_upcall+0x2d>
}
  801385:	48 83 c4 08          	add    $0x8,%rsp
  801389:	5b                   	pop    %rbx
  80138a:	5d                   	pop    %rbp
  80138b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80138c:	49 89 c0             	mov    %rax,%r8
  80138f:	b9 09 00 00 00       	mov    $0x9,%ecx
  801394:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  80139b:	00 00 00 
  80139e:	be 22 00 00 00       	mov    $0x22,%esi
  8013a3:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  8013aa:	00 00 00 
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b2:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  8013b9:	00 00 00 
  8013bc:	41 ff d1             	callq  *%r9

00000000008013bf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8013bf:	55                   	push   %rbp
  8013c0:	48 89 e5             	mov    %rsp,%rbp
  8013c3:	53                   	push   %rbx
  8013c4:	49 89 f0             	mov    %rsi,%r8
  8013c7:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8013ca:	48 63 d7             	movslq %edi,%rdx
  8013cd:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8013d0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013d5:	be 00 00 00 00       	mov    $0x0,%esi
  8013da:	4c 89 c1             	mov    %r8,%rcx
  8013dd:	cd 30                	int    $0x30
}
  8013df:	5b                   	pop    %rbx
  8013e0:	5d                   	pop    %rbp
  8013e1:	c3                   	retq   

00000000008013e2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8013e2:	55                   	push   %rbp
  8013e3:	48 89 e5             	mov    %rsp,%rbp
  8013e6:	53                   	push   %rbx
  8013e7:	48 83 ec 08          	sub    $0x8,%rsp
  8013eb:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8013ee:	be 00 00 00 00       	mov    $0x0,%esi
  8013f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013f8:	48 89 f1             	mov    %rsi,%rcx
  8013fb:	48 89 f3             	mov    %rsi,%rbx
  8013fe:	48 89 f7             	mov    %rsi,%rdi
  801401:	cd 30                	int    $0x30
  if (check && ret > 0)
  801403:	48 85 c0             	test   %rax,%rax
  801406:	7f 07                	jg     80140f <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  801408:	48 83 c4 08          	add    $0x8,%rsp
  80140c:	5b                   	pop    %rbx
  80140d:	5d                   	pop    %rbp
  80140e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80140f:	49 89 c0             	mov    %rax,%r8
  801412:	b9 0c 00 00 00       	mov    $0xc,%ecx
  801417:	48 ba e0 20 80 00 00 	movabs $0x8020e0,%rdx
  80141e:	00 00 00 
  801421:	be 22 00 00 00       	mov    $0x22,%esi
  801426:	48 bf ff 20 80 00 00 	movabs $0x8020ff,%rdi
  80142d:	00 00 00 
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  80143c:	00 00 00 
  80143f:	41 ff d1             	callq  *%r9

0000000000801442 <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  801442:	55                   	push   %rbp
  801443:	48 89 e5             	mov    %rsp,%rbp
  801446:	53                   	push   %rbx
  801447:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  80144b:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  80144e:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  801452:	41 f6 c0 02          	test   $0x2,%r8b
  801456:	0f 84 b2 00 00 00    	je     80150e <pgfault+0xcc>
  80145c:	48 89 da             	mov    %rbx,%rdx
  80145f:	48 c1 ea 0c          	shr    $0xc,%rdx
  801463:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80146a:	01 00 00 
  80146d:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801471:	f6 c4 08             	test   $0x8,%ah
  801474:	0f 84 94 00 00 00    	je     80150e <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  80147a:	ba 02 00 00 00       	mov    $0x2,%edx
  80147f:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801484:	bf 00 00 00 00       	mov    $0x0,%edi
  801489:	48 b8 d5 11 80 00 00 	movabs $0x8011d5,%rax
  801490:	00 00 00 
  801493:	ff d0                	callq  *%rax
  801495:	85 c0                	test   %eax,%eax
  801497:	0f 88 9f 00 00 00    	js     80153c <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80149d:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  8014a4:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014a9:	48 89 de             	mov    %rbx,%rsi
  8014ac:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  8014b1:	48 b8 81 0e 80 00 00 	movabs $0x800e81,%rax
  8014b8:	00 00 00 
  8014bb:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  8014bd:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  8014c3:	48 89 d9             	mov    %rbx,%rcx
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8014d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8014d5:	48 b8 38 12 80 00 00 	movabs $0x801238,%rax
  8014dc:	00 00 00 
  8014df:	ff d0                	callq  *%rax
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	0f 88 80 00 00 00    	js     801569 <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  8014e9:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8014ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8014f3:	48 b8 9f 12 80 00 00 	movabs $0x80129f,%rax
  8014fa:	00 00 00 
  8014fd:	ff d0                	callq  *%rax
  8014ff:	85 c0                	test   %eax,%eax
  801501:	0f 88 8f 00 00 00    	js     801596 <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  801507:	48 83 c4 08          	add    $0x8,%rsp
  80150b:	5b                   	pop    %rbx
  80150c:	5d                   	pop    %rbp
  80150d:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  80150e:	48 89 d9             	mov    %rbx,%rcx
  801511:	48 ba 10 21 80 00 00 	movabs $0x802110,%rdx
  801518:	00 00 00 
  80151b:	be 21 00 00 00       	mov    $0x21,%esi
  801520:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  801527:	00 00 00 
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
  80152f:	49 b9 86 1a 80 00 00 	movabs $0x801a86,%r9
  801536:	00 00 00 
  801539:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  80153c:	89 c1                	mov    %eax,%ecx
  80153e:	48 ba 40 21 80 00 00 	movabs $0x802140,%rdx
  801545:	00 00 00 
  801548:	be 2f 00 00 00       	mov    $0x2f,%esi
  80154d:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  801554:	00 00 00 
  801557:	b8 00 00 00 00       	mov    $0x0,%eax
  80155c:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  801563:	00 00 00 
  801566:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  801569:	89 c1                	mov    %eax,%ecx
  80156b:	48 ba 68 21 80 00 00 	movabs $0x802168,%rdx
  801572:	00 00 00 
  801575:	be 39 00 00 00       	mov    $0x39,%esi
  80157a:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  801581:	00 00 00 
  801584:	b8 00 00 00 00       	mov    $0x0,%eax
  801589:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  801590:	00 00 00 
  801593:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  801596:	89 c1                	mov    %eax,%ecx
  801598:	48 ba 90 21 80 00 00 	movabs $0x802190,%rdx
  80159f:	00 00 00 
  8015a2:	be 3d 00 00 00       	mov    $0x3d,%esi
  8015a7:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  8015ae:	00 00 00 
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b6:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  8015bd:	00 00 00 
  8015c0:	41 ff d0             	callq  *%r8

00000000008015c3 <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  8015c3:	55                   	push   %rbp
  8015c4:	48 89 e5             	mov    %rsp,%rbp
  8015c7:	41 57                	push   %r15
  8015c9:	41 56                	push   %r14
  8015cb:	41 55                	push   %r13
  8015cd:	41 54                	push   %r12
  8015cf:	53                   	push   %rbx
  8015d0:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  8015d4:	48 bf 42 14 80 00 00 	movabs $0x801442,%rdi
  8015db:	00 00 00 
  8015de:	48 b8 76 1b 80 00 00 	movabs $0x801b76,%rax
  8015e5:	00 00 00 
  8015e8:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  8015ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8015ef:	cd 30                	int    $0x30
  8015f1:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  8015f4:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 38                	js     801633 <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  8015fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801600:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  801604:	74 5a                	je     801660 <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801606:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  80160d:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801610:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  801617:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  80161a:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  801621:	01 00 00 
  801624:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  80162b:	01 00 00 
  80162e:	e9 2c 01 00 00       	jmpq   80175f <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  801633:	89 c1                	mov    %eax,%ecx
  801635:	48 ba 37 22 80 00 00 	movabs $0x802237,%rdx
  80163c:	00 00 00 
  80163f:	be 82 00 00 00       	mov    $0x82,%esi
  801644:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  80164b:	00 00 00 
  80164e:	b8 00 00 00 00       	mov    $0x0,%eax
  801653:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  80165a:	00 00 00 
  80165d:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  801660:	48 b8 95 11 80 00 00 	movabs $0x801195,%rax
  801667:	00 00 00 
  80166a:	ff d0                	callq  *%rax
  80166c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801671:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  801675:	48 c1 e0 05          	shl    $0x5,%rax
  801679:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  801680:	00 00 00 
  801683:	48 01 d0             	add    %rdx,%rax
  801686:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  80168d:	00 00 00 
		return 0;
  801690:	e9 9d 01 00 00       	jmpq   801832 <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  801695:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80169c:	01 00 00 
  80169f:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  8016a3:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  8016a7:	48 b8 95 11 80 00 00 	movabs $0x801195,%rax
  8016ae:	00 00 00 
  8016b1:	ff d0                	callq  *%rax
  8016b3:	89 c7                	mov    %eax,%edi
  8016b5:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  8016b8:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8016bc:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8016c2:	74 57                	je     80171b <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  8016c4:	81 e2 05 06 00 00    	and    $0x605,%edx
  8016ca:	48 89 d0             	mov    %rdx,%rax
  8016cd:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8016d0:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8016d4:	48 c1 e6 0c          	shl    $0xc,%rsi
  8016d8:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8016dc:	41 89 c0             	mov    %eax,%r8d
  8016df:	48 89 f1             	mov    %rsi,%rcx
  8016e2:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8016e5:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  8016e9:	48 b8 38 12 80 00 00 	movabs $0x801238,%rax
  8016f0:	00 00 00 
  8016f3:	ff d0                	callq  *%rax
    if (r < 0) {
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	0f 88 ce 01 00 00    	js     8018cb <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  8016fd:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  801701:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  801705:	48 89 f1             	mov    %rsi,%rcx
  801708:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  80170b:	89 fa                	mov    %edi,%edx
  80170d:	48 b8 38 12 80 00 00 	movabs $0x801238,%rax
  801714:	00 00 00 
  801717:	ff d0                	callq  *%rax
  801719:	eb 28                	jmp    801743 <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  80171b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80171f:	48 c1 e6 0c          	shl    $0xc,%rsi
  801723:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  801727:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  80172e:	48 89 f1             	mov    %rsi,%rcx
  801731:	8b 55 c0             	mov    -0x40(%rbp),%edx
  801734:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  801737:	48 b8 38 12 80 00 00 	movabs $0x801238,%rax
  80173e:	00 00 00 
  801741:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  801743:	85 c0                	test   %eax,%eax
  801745:	0f 89 80 00 00 00    	jns    8017cb <fork+0x208>
  80174b:	89 45 c0             	mov    %eax,-0x40(%rbp)
  80174e:	e9 df 00 00 00       	jmpq   801832 <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801753:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  80175a:	4c 39 eb             	cmp    %r13,%rbx
  80175d:	74 75                	je     8017d4 <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  80175f:	48 89 d8             	mov    %rbx,%rax
  801762:	48 c1 e8 27          	shr    $0x27,%rax
  801766:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  80176a:	a8 01                	test   $0x1,%al
  80176c:	74 e5                	je     801753 <fork+0x190>
  80176e:	48 89 d8             	mov    %rbx,%rax
  801771:	48 c1 e8 1e          	shr    $0x1e,%rax
  801775:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  801779:	a8 01                	test   $0x1,%al
  80177b:	74 d6                	je     801753 <fork+0x190>
  80177d:	48 89 d8             	mov    %rbx,%rax
  801780:	48 c1 e8 15          	shr    $0x15,%rax
  801784:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  801788:	a8 01                	test   $0x1,%al
  80178a:	74 c7                	je     801753 <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  80178c:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  801793:	00 00 00 
  801796:	48 39 c3             	cmp    %rax,%rbx
  801799:	77 b8                	ja     801753 <fork+0x190>
  80179b:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  8017a2:	48 39 c3             	cmp    %rax,%rbx
  8017a5:	74 ac                	je     801753 <fork+0x190>
  8017a7:	48 89 d8             	mov    %rbx,%rax
  8017aa:	48 c1 e8 0c          	shr    $0xc,%rax
  8017ae:	48 89 c1             	mov    %rax,%rcx
  8017b1:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8017b5:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8017bc:	01 00 00 
  8017bf:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  8017c3:	a8 01                	test   $0x1,%al
  8017c5:	0f 85 ca fe ff ff    	jne    801695 <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8017cb:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8017d2:	eb 8b                	jmp    80175f <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  8017d4:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  8017db:	00 00 00 
  8017de:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  8017e5:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8017e8:	48 b8 5f 13 80 00 00 	movabs $0x80135f,%rax
  8017ef:	00 00 00 
  8017f2:	ff d0                	callq  *%rax
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 4c                	js     801844 <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  8017f8:	ba 02 00 00 00       	mov    $0x2,%edx
  8017fd:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801804:	00 00 00 
  801807:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  80180a:	48 b8 d5 11 80 00 00 	movabs $0x8011d5,%rax
  801811:	00 00 00 
  801814:	ff d0                	callq  *%rax
  801816:	85 c0                	test   %eax,%eax
  801818:	78 57                	js     801871 <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  80181a:	be 02 00 00 00       	mov    $0x2,%esi
  80181f:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  801822:	48 b8 ff 12 80 00 00 	movabs $0x8012ff,%rax
  801829:	00 00 00 
  80182c:	ff d0                	callq  *%rax
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 6c                	js     80189e <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  801832:	8b 45 c0             	mov    -0x40(%rbp),%eax
  801835:	48 83 c4 28          	add    $0x28,%rsp
  801839:	5b                   	pop    %rbx
  80183a:	41 5c                	pop    %r12
  80183c:	41 5d                	pop    %r13
  80183e:	41 5e                	pop    %r14
  801840:	41 5f                	pop    %r15
  801842:	5d                   	pop    %rbp
  801843:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  801844:	89 c1                	mov    %eax,%ecx
  801846:	48 ba b8 21 80 00 00 	movabs $0x8021b8,%rdx
  80184d:	00 00 00 
  801850:	be a7 00 00 00       	mov    $0xa7,%esi
  801855:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  80185c:	00 00 00 
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  80186b:	00 00 00 
  80186e:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  801871:	89 c1                	mov    %eax,%ecx
  801873:	48 ba e8 21 80 00 00 	movabs $0x8021e8,%rdx
  80187a:	00 00 00 
  80187d:	be aa 00 00 00       	mov    $0xaa,%esi
  801882:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  801889:	00 00 00 
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
  801891:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  801898:	00 00 00 
  80189b:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  80189e:	89 c1                	mov    %eax,%ecx
  8018a0:	48 ba 08 22 80 00 00 	movabs $0x802208,%rdx
  8018a7:	00 00 00 
  8018aa:	be bd 00 00 00       	mov    $0xbd,%esi
  8018af:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  8018b6:	00 00 00 
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018be:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  8018c5:	00 00 00 
  8018c8:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8018cb:	89 45 c0             	mov    %eax,-0x40(%rbp)
  8018ce:	e9 5f ff ff ff       	jmpq   801832 <fork+0x26f>

00000000008018d3 <sfork>:

// Challenge!
int
sfork(void) {
  8018d3:	55                   	push   %rbp
  8018d4:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  8018d7:	48 ba 47 22 80 00 00 	movabs $0x802247,%rdx
  8018de:	00 00 00 
  8018e1:	be c9 00 00 00       	mov    $0xc9,%esi
  8018e6:	48 bf 2c 22 80 00 00 	movabs $0x80222c,%rdi
  8018ed:	00 00 00 
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f5:	48 b9 86 1a 80 00 00 	movabs $0x801a86,%rcx
  8018fc:	00 00 00 
  8018ff:	ff d1                	callq  *%rcx

0000000000801901 <ipc_recv>:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store) {
  801901:	55                   	push   %rbp
  801902:	48 89 e5             	mov    %rsp,%rbp
  801905:	41 54                	push   %r12
  801907:	53                   	push   %rbx
  801908:	49 89 fc             	mov    %rdi,%r12
  80190b:	48 89 d3             	mov    %rdx,%rbx
  // LAB 9 code
  int r;

	if ((r = sys_ipc_recv(pg)) < 0) {
  80190e:	48 89 f7             	mov    %rsi,%rdi
  801911:	48 b8 e2 13 80 00 00 	movabs $0x8013e2,%rax
  801918:	00 00 00 
  80191b:	ff d0                	callq  *%rax
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 45                	js     801966 <ipc_recv+0x65>
		if (perm_store) {
			*perm_store = 0;
		}
		return r;
	} else {
		if (from_env_store) {
  801921:	4d 85 e4             	test   %r12,%r12
  801924:	74 14                	je     80193a <ipc_recv+0x39>
			*from_env_store = thisenv->env_ipc_from;
  801926:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  80192d:	00 00 00 
  801930:	8b 80 14 01 00 00    	mov    0x114(%rax),%eax
  801936:	41 89 04 24          	mov    %eax,(%r12)
		}
		if (perm_store) {
  80193a:	48 85 db             	test   %rbx,%rbx
  80193d:	74 12                	je     801951 <ipc_recv+0x50>
			*perm_store = thisenv->env_ipc_perm;
  80193f:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  801946:	00 00 00 
  801949:	8b 80 18 01 00 00    	mov    0x118(%rax),%eax
  80194f:	89 03                	mov    %eax,(%rbx)
		}
#ifdef SANITIZE_USER_SHADOW_BASE
	  platform_asan_unpoison(pg, PGSIZE);
#endif
		return thisenv->env_ipc_value;
  801951:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  801958:	00 00 00 
  80195b:	8b 80 10 01 00 00    	mov    0x110(%rax),%eax
	}
  // LAB 9 code end

  // return -1;
}
  801961:	5b                   	pop    %rbx
  801962:	41 5c                	pop    %r12
  801964:	5d                   	pop    %rbp
  801965:	c3                   	retq   
		if (from_env_store) {
  801966:	4d 85 e4             	test   %r12,%r12
  801969:	74 08                	je     801973 <ipc_recv+0x72>
			*from_env_store = 0;
  80196b:	41 c7 04 24 00 00 00 	movl   $0x0,(%r12)
  801972:	00 
		if (perm_store) {
  801973:	48 85 db             	test   %rbx,%rbx
  801976:	74 e9                	je     801961 <ipc_recv+0x60>
			*perm_store = 0;
  801978:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80197e:	eb e1                	jmp    801961 <ipc_recv+0x60>

0000000000801980 <ipc_send>:
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm) {
  801980:	55                   	push   %rbp
  801981:	48 89 e5             	mov    %rsp,%rbp
  801984:	41 57                	push   %r15
  801986:	41 56                	push   %r14
  801988:	41 55                	push   %r13
  80198a:	41 54                	push   %r12
  80198c:	53                   	push   %rbx
  80198d:	48 83 ec 08          	sub    $0x8,%rsp
  801991:	41 89 ff             	mov    %edi,%r15d
  801994:	41 89 f6             	mov    %esi,%r14d
  801997:	48 89 d3             	mov    %rdx,%rbx
  80199a:	41 89 cd             	mov    %ecx,%r13d
  // LAB 9 code
  int r;

  if (pg == NULL) {
    pg = (void *) UTOP;
  80199d:	48 85 d2             	test   %rdx,%rdx
  8019a0:	48 b8 00 00 00 00 80 	movabs $0x8000000000,%rax
  8019a7:	00 00 00 
  8019aa:	48 0f 44 d8          	cmove  %rax,%rbx
  }
  while ((r = sys_ipc_try_send(to_env, val, pg, perm))) {
  8019ae:	49 bc bf 13 80 00 00 	movabs $0x8013bf,%r12
  8019b5:	00 00 00 
  8019b8:	44 89 f6             	mov    %r14d,%esi
  8019bb:	44 89 e9             	mov    %r13d,%ecx
  8019be:	48 89 da             	mov    %rbx,%rdx
  8019c1:	44 89 ff             	mov    %r15d,%edi
  8019c4:	41 ff d4             	callq  *%r12
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	74 34                	je     8019ff <ipc_send+0x7f>
	  if (r < 0 && r != -E_IPC_NOT_RECV) {
  8019cb:	79 eb                	jns    8019b8 <ipc_send+0x38>
  8019cd:	83 f8 f6             	cmp    $0xfffffff6,%eax
  8019d0:	74 e6                	je     8019b8 <ipc_send+0x38>
		  panic("ipc_send error: sys_ipc_try_send: %i\n", r);
  8019d2:	89 c1                	mov    %eax,%ecx
  8019d4:	48 ba 60 22 80 00 00 	movabs $0x802260,%rdx
  8019db:	00 00 00 
  8019de:	be 46 00 00 00       	mov    $0x46,%esi
  8019e3:	48 bf 86 22 80 00 00 	movabs $0x802286,%rdi
  8019ea:	00 00 00 
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f2:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  8019f9:	00 00 00 
  8019fc:	41 ff d0             	callq  *%r8
	  }
	  //sys_yield();
  }
  sys_yield();
  8019ff:	48 b8 b5 11 80 00 00 	movabs $0x8011b5,%rax
  801a06:	00 00 00 
  801a09:	ff d0                	callq  *%rax
  // LAB 9 code end
}
  801a0b:	48 83 c4 08          	add    $0x8,%rsp
  801a0f:	5b                   	pop    %rbx
  801a10:	41 5c                	pop    %r12
  801a12:	41 5d                	pop    %r13
  801a14:	41 5e                	pop    %r14
  801a16:	41 5f                	pop    %r15
  801a18:	5d                   	pop    %rbp
  801a19:	c3                   	retq   

0000000000801a1a <ipc_find_env>:
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type) {
  int i;
  for (i = 0; i < NENV; i++)
    if (envs[i].env_type == type)
  801a1a:	a1 d0 e0 22 3c 80 00 	movabs 0x803c22e0d0,%eax
  801a21:	00 00 
  801a23:	39 c7                	cmp    %eax,%edi
  801a25:	74 38                	je     801a5f <ipc_find_env+0x45>
  for (i = 0; i < NENV; i++)
  801a27:	ba 01 00 00 00       	mov    $0x1,%edx
    if (envs[i].env_type == type)
  801a2c:	48 b9 00 e0 22 3c 80 	movabs $0x803c22e000,%rcx
  801a33:	00 00 00 
  801a36:	48 63 c2             	movslq %edx,%rax
  801a39:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  801a3d:	48 c1 e0 05          	shl    $0x5,%rax
  801a41:	48 01 c8             	add    %rcx,%rax
  801a44:	8b 80 d0 00 00 00    	mov    0xd0(%rax),%eax
  801a4a:	39 f8                	cmp    %edi,%eax
  801a4c:	74 16                	je     801a64 <ipc_find_env+0x4a>
  for (i = 0; i < NENV; i++)
  801a4e:	83 c2 01             	add    $0x1,%edx
  801a51:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801a57:	75 dd                	jne    801a36 <ipc_find_env+0x1c>
      return envs[i].env_id;
  return 0;
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5e:	c3                   	retq   
  for (i = 0; i < NENV; i++)
  801a5f:	ba 00 00 00 00       	mov    $0x0,%edx
      return envs[i].env_id;
  801a64:	48 63 d2             	movslq %edx,%rdx
  801a67:	48 8d 04 d2          	lea    (%rdx,%rdx,8),%rax
  801a6b:	48 c1 e0 05          	shl    $0x5,%rax
  801a6f:	48 89 c2             	mov    %rax,%rdx
  801a72:	48 b8 00 e0 22 3c 80 	movabs $0x803c22e000,%rax
  801a79:	00 00 00 
  801a7c:	48 01 d0             	add    %rdx,%rax
  801a7f:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  801a85:	c3                   	retq   

0000000000801a86 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801a86:	55                   	push   %rbp
  801a87:	48 89 e5             	mov    %rsp,%rbp
  801a8a:	41 56                	push   %r14
  801a8c:	41 55                	push   %r13
  801a8e:	41 54                	push   %r12
  801a90:	53                   	push   %rbx
  801a91:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801a98:	49 89 fd             	mov    %rdi,%r13
  801a9b:	41 89 f6             	mov    %esi,%r14d
  801a9e:	49 89 d4             	mov    %rdx,%r12
  801aa1:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801aa8:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801aaf:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801ab6:	84 c0                	test   %al,%al
  801ab8:	74 26                	je     801ae0 <_panic+0x5a>
  801aba:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  801ac1:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801ac8:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801acc:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  801ad0:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  801ad4:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801ad8:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801adc:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801ae0:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801ae7:	00 00 00 
  801aea:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801af1:	00 00 00 
  801af4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801af8:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801aff:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801b06:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801b0d:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  801b14:	00 00 00 
  801b17:	48 8b 18             	mov    (%rax),%rbx
  801b1a:	48 b8 95 11 80 00 00 	movabs $0x801195,%rax
  801b21:	00 00 00 
  801b24:	ff d0                	callq  *%rax
  801b26:	45 89 f0             	mov    %r14d,%r8d
  801b29:	4c 89 e9             	mov    %r13,%rcx
  801b2c:	48 89 da             	mov    %rbx,%rdx
  801b2f:	89 c6                	mov    %eax,%esi
  801b31:	48 bf 90 22 80 00 00 	movabs $0x802290,%rdi
  801b38:	00 00 00 
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b40:	48 bb 03 03 80 00 00 	movabs $0x800303,%rbx
  801b47:	00 00 00 
  801b4a:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801b4c:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801b53:	4c 89 e7             	mov    %r12,%rdi
  801b56:	48 b8 9b 02 80 00 00 	movabs $0x80029b,%rax
  801b5d:	00 00 00 
  801b60:	ff d0                	callq  *%rax
  cprintf("\n");
  801b62:	48 bf 45 22 80 00 00 	movabs $0x802245,%rdi
  801b69:	00 00 00 
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b71:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801b73:	cc                   	int3   
  while (1)
  801b74:	eb fd                	jmp    801b73 <_panic+0xed>

0000000000801b76 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801b76:	55                   	push   %rbp
  801b77:	48 89 e5             	mov    %rsp,%rbp
  801b7a:	41 54                	push   %r12
  801b7c:	53                   	push   %rbx
  801b7d:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  801b80:	48 b8 95 11 80 00 00 	movabs $0x801195,%rax
  801b87:	00 00 00 
  801b8a:	ff d0                	callq  *%rax
  801b8c:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  801b8e:	48 b8 18 30 80 00 00 	movabs $0x803018,%rax
  801b95:	00 00 00 
  801b98:	48 83 38 00          	cmpq   $0x0,(%rax)
  801b9c:	74 2e                	je     801bcc <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801b9e:	4c 89 e0             	mov    %r12,%rax
  801ba1:	48 a3 18 30 80 00 00 	movabs %rax,0x803018
  801ba8:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801bab:	48 be 18 1c 80 00 00 	movabs $0x801c18,%rsi
  801bb2:	00 00 00 
  801bb5:	89 df                	mov    %ebx,%edi
  801bb7:	48 b8 5f 13 80 00 00 	movabs $0x80135f,%rax
  801bbe:	00 00 00 
  801bc1:	ff d0                	callq  *%rax
  if (error < 0)
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	78 24                	js     801beb <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801bc7:	5b                   	pop    %rbx
  801bc8:	41 5c                	pop    %r12
  801bca:	5d                   	pop    %rbp
  801bcb:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  801bcc:	ba 02 00 00 00       	mov    $0x2,%edx
  801bd1:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801bd8:	00 00 00 
  801bdb:	89 df                	mov    %ebx,%edi
  801bdd:	48 b8 d5 11 80 00 00 	movabs $0x8011d5,%rax
  801be4:	00 00 00 
  801be7:	ff d0                	callq  *%rax
  801be9:	eb b3                	jmp    801b9e <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801beb:	89 c1                	mov    %eax,%ecx
  801bed:	48 ba b8 22 80 00 00 	movabs $0x8022b8,%rdx
  801bf4:	00 00 00 
  801bf7:	be 2c 00 00 00       	mov    $0x2c,%esi
  801bfc:	48 bf d0 22 80 00 00 	movabs $0x8022d0,%rdi
  801c03:	00 00 00 
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	49 b8 86 1a 80 00 00 	movabs $0x801a86,%r8
  801c12:	00 00 00 
  801c15:	41 ff d0             	callq  *%r8

0000000000801c18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801c18:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801c1b:	48 a1 18 30 80 00 00 	movabs 0x803018,%rax
  801c22:	00 00 00 
	call *%rax
  801c25:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801c27:	41 5f                	pop    %r15
	popq %r15
  801c29:	41 5f                	pop    %r15
	popq %r15
  801c2b:	41 5f                	pop    %r15
	popq %r14
  801c2d:	41 5e                	pop    %r14
	popq %r13
  801c2f:	41 5d                	pop    %r13
	popq %r12
  801c31:	41 5c                	pop    %r12
	popq %r11
  801c33:	41 5b                	pop    %r11
	popq %r10
  801c35:	41 5a                	pop    %r10
	popq %r9
  801c37:	41 59                	pop    %r9
	popq %r8
  801c39:	41 58                	pop    %r8
	popq %rsi
  801c3b:	5e                   	pop    %rsi
	popq %rdi
  801c3c:	5f                   	pop    %rdi
	popq %rbp
  801c3d:	5d                   	pop    %rbp
	popq %rdx
  801c3e:	5a                   	pop    %rdx
	popq %rcx
  801c3f:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801c40:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801c45:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801c4a:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801c4e:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801c51:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801c56:	5b                   	pop    %rbx
	popq %rax
  801c57:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801c58:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801c5c:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801c5d:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801c62:	c3                   	retq   
  801c63:	90                   	nop
