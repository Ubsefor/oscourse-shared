
obj/user/pingpong:     file format elf64-x86-64


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
  800023:	e8 02 01 00 00       	callq  80012a <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// Only need to start one of these -- splits into two with fork.

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
  800037:	48 83 ec 18          	sub    $0x18,%rsp
  envid_t who;

  if ((who = fork()) != 0) {
  80003b:	48 b8 69 15 80 00 00 	movabs $0x801569,%rax
  800042:	00 00 00 
  800045:	ff d0                	callq  *%rax
  800047:	89 45 cc             	mov    %eax,-0x34(%rbp)
  80004a:	85 c0                	test   %eax,%eax
  80004c:	0f 85 88 00 00 00    	jne    8000da <umain+0xb0>
    cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
    ipc_send(who, 0, 0, 0);
  }

  while (1) {
    uint32_t i = ipc_recv(&who, 0, 0);
  800052:	49 bf a7 18 80 00 00 	movabs $0x8018a7,%r15
  800059:	00 00 00 
    cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005c:	49 be 3b 11 80 00 00 	movabs $0x80113b,%r14
  800063:	00 00 00 
  800066:	49 bd a9 02 80 00 00 	movabs $0x8002a9,%r13
  80006d:	00 00 00 
    uint32_t i = ipc_recv(&who, 0, 0);
  800070:	ba 00 00 00 00       	mov    $0x0,%edx
  800075:	be 00 00 00 00       	mov    $0x0,%esi
  80007a:	48 8d 7d cc          	lea    -0x34(%rbp),%rdi
  80007e:	41 ff d7             	callq  *%r15
  800081:	89 c3                	mov    %eax,%ebx
    cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800083:	44 8b 65 cc          	mov    -0x34(%rbp),%r12d
  800087:	41 ff d6             	callq  *%r14
  80008a:	44 89 e1             	mov    %r12d,%ecx
  80008d:	89 da                	mov    %ebx,%edx
  80008f:	89 c6                	mov    %eax,%esi
  800091:	48 bf 36 1c 80 00 00 	movabs $0x801c36,%rdi
  800098:	00 00 00 
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	41 ff d5             	callq  *%r13
    if (i == 10)
  8000a3:	83 fb 0a             	cmp    $0xa,%ebx
  8000a6:	74 23                	je     8000cb <umain+0xa1>
      return;
    i++;
  8000a8:	83 c3 01             	add    $0x1,%ebx
    ipc_send(who, i, 0, 0);
  8000ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b5:	89 de                	mov    %ebx,%esi
  8000b7:	8b 7d cc             	mov    -0x34(%rbp),%edi
  8000ba:	48 b8 26 19 80 00 00 	movabs $0x801926,%rax
  8000c1:	00 00 00 
  8000c4:	ff d0                	callq  *%rax
    if (i == 10)
  8000c6:	83 fb 0a             	cmp    $0xa,%ebx
  8000c9:	75 a5                	jne    800070 <umain+0x46>
      return;
  }
}
  8000cb:	48 83 c4 18          	add    $0x18,%rsp
  8000cf:	5b                   	pop    %rbx
  8000d0:	41 5c                	pop    %r12
  8000d2:	41 5d                	pop    %r13
  8000d4:	41 5e                	pop    %r14
  8000d6:	41 5f                	pop    %r15
  8000d8:	5d                   	pop    %rbp
  8000d9:	c3                   	retq   
  8000da:	89 c3                	mov    %eax,%ebx
    cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000dc:	48 b8 3b 11 80 00 00 	movabs $0x80113b,%rax
  8000e3:	00 00 00 
  8000e6:	ff d0                	callq  *%rax
  8000e8:	89 da                	mov    %ebx,%edx
  8000ea:	89 c6                	mov    %eax,%esi
  8000ec:	48 bf 20 1c 80 00 00 	movabs $0x801c20,%rdi
  8000f3:	00 00 00 
  8000f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fb:	48 b9 a9 02 80 00 00 	movabs $0x8002a9,%rcx
  800102:	00 00 00 
  800105:	ff d1                	callq  *%rcx
    ipc_send(who, 0, 0, 0);
  800107:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010c:	ba 00 00 00 00       	mov    $0x0,%edx
  800111:	be 00 00 00 00       	mov    $0x0,%esi
  800116:	8b 7d cc             	mov    -0x34(%rbp),%edi
  800119:	48 b8 26 19 80 00 00 	movabs $0x801926,%rax
  800120:	00 00 00 
  800123:	ff d0                	callq  *%rax
  800125:	e9 28 ff ff ff       	jmpq   800052 <umain+0x28>

000000000080012a <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80012a:	55                   	push   %rbp
  80012b:	48 89 e5             	mov    %rsp,%rbp
  80012e:	41 56                	push   %r14
  800130:	41 55                	push   %r13
  800132:	41 54                	push   %r12
  800134:	53                   	push   %rbx
  800135:	41 89 fd             	mov    %edi,%r13d
  800138:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80013b:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  800142:	00 00 00 
  800145:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  80014c:	00 00 00 
  80014f:	48 39 c2             	cmp    %rax,%rdx
  800152:	73 23                	jae    800177 <libmain+0x4d>
  800154:	48 89 d3             	mov    %rdx,%rbx
  800157:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80015b:	48 29 d0             	sub    %rdx,%rax
  80015e:	48 c1 e8 03          	shr    $0x3,%rax
  800162:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800167:	b8 00 00 00 00       	mov    $0x0,%eax
  80016c:	ff 13                	callq  *(%rbx)
    ctor++;
  80016e:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800172:	4c 39 e3             	cmp    %r12,%rbx
  800175:	75 f0                	jne    800167 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800177:	48 b8 3b 11 80 00 00 	movabs $0x80113b,%rax
  80017e:	00 00 00 
  800181:	ff d0                	callq  *%rax
  800183:	25 ff 03 00 00       	and    $0x3ff,%eax
  800188:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80018c:	48 c1 e0 05          	shl    $0x5,%rax
  800190:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800197:	00 00 00 
  80019a:	48 01 d0             	add    %rdx,%rax
  80019d:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  8001a4:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8001a7:	45 85 ed             	test   %r13d,%r13d
  8001aa:	7e 0d                	jle    8001b9 <libmain+0x8f>
    binaryname = argv[0];
  8001ac:	49 8b 06             	mov    (%r14),%rax
  8001af:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  8001b6:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8001b9:	4c 89 f6             	mov    %r14,%rsi
  8001bc:	44 89 ef             	mov    %r13d,%edi
  8001bf:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8001c6:	00 00 00 
  8001c9:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8001cb:	48 b8 e0 01 80 00 00 	movabs $0x8001e0,%rax
  8001d2:	00 00 00 
  8001d5:	ff d0                	callq  *%rax
#endif
}
  8001d7:	5b                   	pop    %rbx
  8001d8:	41 5c                	pop    %r12
  8001da:	41 5d                	pop    %r13
  8001dc:	41 5e                	pop    %r14
  8001de:	5d                   	pop    %rbp
  8001df:	c3                   	retq   

00000000008001e0 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001e0:	55                   	push   %rbp
  8001e1:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8001e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8001e9:	48 b8 db 10 80 00 00 	movabs $0x8010db,%rax
  8001f0:	00 00 00 
  8001f3:	ff d0                	callq  *%rax
}
  8001f5:	5d                   	pop    %rbp
  8001f6:	c3                   	retq   

00000000008001f7 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8001f7:	55                   	push   %rbp
  8001f8:	48 89 e5             	mov    %rsp,%rbp
  8001fb:	53                   	push   %rbx
  8001fc:	48 83 ec 08          	sub    $0x8,%rsp
  800200:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800203:	8b 06                	mov    (%rsi),%eax
  800205:	8d 50 01             	lea    0x1(%rax),%edx
  800208:	89 16                	mov    %edx,(%rsi)
  80020a:	48 98                	cltq   
  80020c:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800211:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800217:	74 0b                	je     800224 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800219:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80021d:	48 83 c4 08          	add    $0x8,%rsp
  800221:	5b                   	pop    %rbx
  800222:	5d                   	pop    %rbp
  800223:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800224:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800228:	be ff 00 00 00       	mov    $0xff,%esi
  80022d:	48 b8 9d 10 80 00 00 	movabs $0x80109d,%rax
  800234:	00 00 00 
  800237:	ff d0                	callq  *%rax
    b->idx = 0;
  800239:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80023f:	eb d8                	jmp    800219 <putch+0x22>

0000000000800241 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800241:	55                   	push   %rbp
  800242:	48 89 e5             	mov    %rsp,%rbp
  800245:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80024c:	48 89 fa             	mov    %rdi,%rdx
  80024f:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800252:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800259:	00 00 00 
  b.cnt = 0;
  80025c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800263:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800266:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80026d:	48 bf f7 01 80 00 00 	movabs $0x8001f7,%rdi
  800274:	00 00 00 
  800277:	48 b8 67 04 80 00 00 	movabs $0x800467,%rax
  80027e:	00 00 00 
  800281:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800283:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80028a:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800291:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800295:	48 b8 9d 10 80 00 00 	movabs $0x80109d,%rax
  80029c:	00 00 00 
  80029f:	ff d0                	callq  *%rax

  return b.cnt;
}
  8002a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8002a7:	c9                   	leaveq 
  8002a8:	c3                   	retq   

00000000008002a9 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8002a9:	55                   	push   %rbp
  8002aa:	48 89 e5             	mov    %rsp,%rbp
  8002ad:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8002b4:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8002bb:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8002c2:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8002c9:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8002d0:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8002d7:	84 c0                	test   %al,%al
  8002d9:	74 20                	je     8002fb <cprintf+0x52>
  8002db:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8002df:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8002e3:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8002e7:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8002eb:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8002ef:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8002f3:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8002f7:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8002fb:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800302:	00 00 00 
  800305:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80030c:	00 00 00 
  80030f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800313:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80031a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800321:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800328:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80032f:	48 b8 41 02 80 00 00 	movabs $0x800241,%rax
  800336:	00 00 00 
  800339:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80033b:	c9                   	leaveq 
  80033c:	c3                   	retq   

000000000080033d <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80033d:	55                   	push   %rbp
  80033e:	48 89 e5             	mov    %rsp,%rbp
  800341:	41 57                	push   %r15
  800343:	41 56                	push   %r14
  800345:	41 55                	push   %r13
  800347:	41 54                	push   %r12
  800349:	53                   	push   %rbx
  80034a:	48 83 ec 18          	sub    $0x18,%rsp
  80034e:	49 89 fc             	mov    %rdi,%r12
  800351:	49 89 f5             	mov    %rsi,%r13
  800354:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800358:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80035b:	41 89 cf             	mov    %ecx,%r15d
  80035e:	49 39 d7             	cmp    %rdx,%r15
  800361:	76 45                	jbe    8003a8 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800363:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800367:	85 db                	test   %ebx,%ebx
  800369:	7e 0e                	jle    800379 <printnum+0x3c>
      putch(padc, putdat);
  80036b:	4c 89 ee             	mov    %r13,%rsi
  80036e:	44 89 f7             	mov    %r14d,%edi
  800371:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800374:	83 eb 01             	sub    $0x1,%ebx
  800377:	75 f2                	jne    80036b <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800379:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	49 f7 f7             	div    %r15
  800385:	48 b8 53 1c 80 00 00 	movabs $0x801c53,%rax
  80038c:	00 00 00 
  80038f:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800393:	4c 89 ee             	mov    %r13,%rsi
  800396:	41 ff d4             	callq  *%r12
}
  800399:	48 83 c4 18          	add    $0x18,%rsp
  80039d:	5b                   	pop    %rbx
  80039e:	41 5c                	pop    %r12
  8003a0:	41 5d                	pop    %r13
  8003a2:	41 5e                	pop    %r14
  8003a4:	41 5f                	pop    %r15
  8003a6:	5d                   	pop    %rbp
  8003a7:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	49 f7 f7             	div    %r15
  8003b4:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8003b8:	48 89 c2             	mov    %rax,%rdx
  8003bb:	48 b8 3d 03 80 00 00 	movabs $0x80033d,%rax
  8003c2:	00 00 00 
  8003c5:	ff d0                	callq  *%rax
  8003c7:	eb b0                	jmp    800379 <printnum+0x3c>

00000000008003c9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8003c9:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8003cd:	48 8b 06             	mov    (%rsi),%rax
  8003d0:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8003d4:	73 0a                	jae    8003e0 <sprintputch+0x17>
    *b->buf++ = ch;
  8003d6:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8003da:	48 89 16             	mov    %rdx,(%rsi)
  8003dd:	40 88 38             	mov    %dil,(%rax)
}
  8003e0:	c3                   	retq   

00000000008003e1 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8003e1:	55                   	push   %rbp
  8003e2:	48 89 e5             	mov    %rsp,%rbp
  8003e5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003ec:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003f3:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003fa:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800401:	84 c0                	test   %al,%al
  800403:	74 20                	je     800425 <printfmt+0x44>
  800405:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800409:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80040d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800411:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800415:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800419:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80041d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800421:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800425:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80042c:	00 00 00 
  80042f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800436:	00 00 00 
  800439:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80043d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800444:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80044b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800452:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800459:	48 b8 67 04 80 00 00 	movabs $0x800467,%rax
  800460:	00 00 00 
  800463:	ff d0                	callq  *%rax
}
  800465:	c9                   	leaveq 
  800466:	c3                   	retq   

0000000000800467 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800467:	55                   	push   %rbp
  800468:	48 89 e5             	mov    %rsp,%rbp
  80046b:	41 57                	push   %r15
  80046d:	41 56                	push   %r14
  80046f:	41 55                	push   %r13
  800471:	41 54                	push   %r12
  800473:	53                   	push   %rbx
  800474:	48 83 ec 48          	sub    $0x48,%rsp
  800478:	49 89 fd             	mov    %rdi,%r13
  80047b:	49 89 f7             	mov    %rsi,%r15
  80047e:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800481:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800485:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800489:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80048d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800491:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800495:	41 0f b6 3e          	movzbl (%r14),%edi
  800499:	83 ff 25             	cmp    $0x25,%edi
  80049c:	74 18                	je     8004b6 <vprintfmt+0x4f>
      if (ch == '\0')
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	0f 84 8c 06 00 00    	je     800b32 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8004a6:	4c 89 fe             	mov    %r15,%rsi
  8004a9:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8004ac:	49 89 de             	mov    %rbx,%r14
  8004af:	eb e0                	jmp    800491 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8004b1:	49 89 de             	mov    %rbx,%r14
  8004b4:	eb db                	jmp    800491 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8004b6:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8004ba:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8004be:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8004c5:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8004cb:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8004cf:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8004d4:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8004da:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8004e0:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8004e5:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8004ea:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8004ee:	0f b6 13             	movzbl (%rbx),%edx
  8004f1:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8004f4:	3c 55                	cmp    $0x55,%al
  8004f6:	0f 87 8b 05 00 00    	ja     800a87 <vprintfmt+0x620>
  8004fc:	0f b6 c0             	movzbl %al,%eax
  8004ff:	49 bb 20 1d 80 00 00 	movabs $0x801d20,%r11
  800506:	00 00 00 
  800509:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80050d:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800510:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800514:	eb d4                	jmp    8004ea <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800516:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800519:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80051d:	eb cb                	jmp    8004ea <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80051f:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800522:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800526:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80052a:	8d 50 d0             	lea    -0x30(%rax),%edx
  80052d:	83 fa 09             	cmp    $0x9,%edx
  800530:	77 7e                	ja     8005b0 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800532:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800536:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80053a:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80053f:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800543:	8d 50 d0             	lea    -0x30(%rax),%edx
  800546:	83 fa 09             	cmp    $0x9,%edx
  800549:	76 e7                	jbe    800532 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80054b:	4c 89 f3             	mov    %r14,%rbx
  80054e:	eb 19                	jmp    800569 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800550:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800553:	83 f8 2f             	cmp    $0x2f,%eax
  800556:	77 2a                	ja     800582 <vprintfmt+0x11b>
  800558:	89 c2                	mov    %eax,%edx
  80055a:	4c 01 d2             	add    %r10,%rdx
  80055d:	83 c0 08             	add    $0x8,%eax
  800560:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800563:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800566:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800569:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80056d:	0f 89 77 ff ff ff    	jns    8004ea <vprintfmt+0x83>
          width = precision, precision = -1;
  800573:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800577:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80057d:	e9 68 ff ff ff       	jmpq   8004ea <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800582:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800586:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80058a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80058e:	eb d3                	jmp    800563 <vprintfmt+0xfc>
        if (width < 0)
  800590:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	41 0f 48 c0          	cmovs  %r8d,%eax
  800599:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80059c:	4c 89 f3             	mov    %r14,%rbx
  80059f:	e9 46 ff ff ff       	jmpq   8004ea <vprintfmt+0x83>
  8005a4:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8005a7:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8005ab:	e9 3a ff ff ff       	jmpq   8004ea <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005b0:	4c 89 f3             	mov    %r14,%rbx
  8005b3:	eb b4                	jmp    800569 <vprintfmt+0x102>
        lflag++;
  8005b5:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8005b8:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8005bb:	e9 2a ff ff ff       	jmpq   8004ea <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8005c0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005c3:	83 f8 2f             	cmp    $0x2f,%eax
  8005c6:	77 19                	ja     8005e1 <vprintfmt+0x17a>
  8005c8:	89 c2                	mov    %eax,%edx
  8005ca:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005ce:	83 c0 08             	add    $0x8,%eax
  8005d1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005d4:	4c 89 fe             	mov    %r15,%rsi
  8005d7:	8b 3a                	mov    (%rdx),%edi
  8005d9:	41 ff d5             	callq  *%r13
        break;
  8005dc:	e9 b0 fe ff ff       	jmpq   800491 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8005e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8005e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8005e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8005ed:	eb e5                	jmp    8005d4 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8005ef:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005f2:	83 f8 2f             	cmp    $0x2f,%eax
  8005f5:	77 5b                	ja     800652 <vprintfmt+0x1eb>
  8005f7:	89 c2                	mov    %eax,%edx
  8005f9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005fd:	83 c0 08             	add    $0x8,%eax
  800600:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800603:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800605:	89 c8                	mov    %ecx,%eax
  800607:	c1 f8 1f             	sar    $0x1f,%eax
  80060a:	31 c1                	xor    %eax,%ecx
  80060c:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060e:	83 f9 0b             	cmp    $0xb,%ecx
  800611:	7f 4d                	jg     800660 <vprintfmt+0x1f9>
  800613:	48 63 c1             	movslq %ecx,%rax
  800616:	48 ba e0 1f 80 00 00 	movabs $0x801fe0,%rdx
  80061d:	00 00 00 
  800620:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800624:	48 85 c0             	test   %rax,%rax
  800627:	74 37                	je     800660 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800629:	48 89 c1             	mov    %rax,%rcx
  80062c:	48 ba 74 1c 80 00 00 	movabs $0x801c74,%rdx
  800633:	00 00 00 
  800636:	4c 89 fe             	mov    %r15,%rsi
  800639:	4c 89 ef             	mov    %r13,%rdi
  80063c:	b8 00 00 00 00       	mov    $0x0,%eax
  800641:	48 bb e1 03 80 00 00 	movabs $0x8003e1,%rbx
  800648:	00 00 00 
  80064b:	ff d3                	callq  *%rbx
  80064d:	e9 3f fe ff ff       	jmpq   800491 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800652:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800656:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80065a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80065e:	eb a3                	jmp    800603 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800660:	48 ba 6b 1c 80 00 00 	movabs $0x801c6b,%rdx
  800667:	00 00 00 
  80066a:	4c 89 fe             	mov    %r15,%rsi
  80066d:	4c 89 ef             	mov    %r13,%rdi
  800670:	b8 00 00 00 00       	mov    $0x0,%eax
  800675:	48 bb e1 03 80 00 00 	movabs $0x8003e1,%rbx
  80067c:	00 00 00 
  80067f:	ff d3                	callq  *%rbx
  800681:	e9 0b fe ff ff       	jmpq   800491 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800686:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800689:	83 f8 2f             	cmp    $0x2f,%eax
  80068c:	77 4b                	ja     8006d9 <vprintfmt+0x272>
  80068e:	89 c2                	mov    %eax,%edx
  800690:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800694:	83 c0 08             	add    $0x8,%eax
  800697:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80069a:	48 8b 02             	mov    (%rdx),%rax
  80069d:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8006a1:	48 85 c0             	test   %rax,%rax
  8006a4:	0f 84 05 04 00 00    	je     800aaf <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8006aa:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006ae:	7e 06                	jle    8006b6 <vprintfmt+0x24f>
  8006b0:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8006b4:	75 31                	jne    8006e7 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8006ba:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8006be:	0f b6 00             	movzbl (%rax),%eax
  8006c1:	0f be f8             	movsbl %al,%edi
  8006c4:	85 ff                	test   %edi,%edi
  8006c6:	0f 84 c3 00 00 00    	je     80078f <vprintfmt+0x328>
  8006cc:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8006d0:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8006d4:	e9 85 00 00 00       	jmpq   80075e <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8006d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e5:	eb b3                	jmp    80069a <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8006e7:	49 63 f4             	movslq %r12d,%rsi
  8006ea:	48 89 c7             	mov    %rax,%rdi
  8006ed:	48 b8 3e 0c 80 00 00 	movabs $0x800c3e,%rax
  8006f4:	00 00 00 
  8006f7:	ff d0                	callq  *%rax
  8006f9:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8006fc:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8006ff:	85 f6                	test   %esi,%esi
  800701:	7e 22                	jle    800725 <vprintfmt+0x2be>
            putch(padc, putdat);
  800703:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800707:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80070b:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80070f:	4c 89 fe             	mov    %r15,%rsi
  800712:	89 df                	mov    %ebx,%edi
  800714:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800717:	41 83 ec 01          	sub    $0x1,%r12d
  80071b:	75 f2                	jne    80070f <vprintfmt+0x2a8>
  80071d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800721:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800725:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800729:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80072d:	0f b6 00             	movzbl (%rax),%eax
  800730:	0f be f8             	movsbl %al,%edi
  800733:	85 ff                	test   %edi,%edi
  800735:	0f 84 56 fd ff ff    	je     800491 <vprintfmt+0x2a>
  80073b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80073f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800743:	eb 19                	jmp    80075e <vprintfmt+0x2f7>
            putch(ch, putdat);
  800745:	4c 89 fe             	mov    %r15,%rsi
  800748:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074b:	41 83 ee 01          	sub    $0x1,%r14d
  80074f:	48 83 c3 01          	add    $0x1,%rbx
  800753:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800757:	0f be f8             	movsbl %al,%edi
  80075a:	85 ff                	test   %edi,%edi
  80075c:	74 29                	je     800787 <vprintfmt+0x320>
  80075e:	45 85 e4             	test   %r12d,%r12d
  800761:	78 06                	js     800769 <vprintfmt+0x302>
  800763:	41 83 ec 01          	sub    $0x1,%r12d
  800767:	78 48                	js     8007b1 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800769:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80076d:	74 d6                	je     800745 <vprintfmt+0x2de>
  80076f:	0f be c0             	movsbl %al,%eax
  800772:	83 e8 20             	sub    $0x20,%eax
  800775:	83 f8 5e             	cmp    $0x5e,%eax
  800778:	76 cb                	jbe    800745 <vprintfmt+0x2de>
            putch('?', putdat);
  80077a:	4c 89 fe             	mov    %r15,%rsi
  80077d:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800782:	41 ff d5             	callq  *%r13
  800785:	eb c4                	jmp    80074b <vprintfmt+0x2e4>
  800787:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80078b:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80078f:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800792:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800796:	0f 8e f5 fc ff ff    	jle    800491 <vprintfmt+0x2a>
          putch(' ', putdat);
  80079c:	4c 89 fe             	mov    %r15,%rsi
  80079f:	bf 20 00 00 00       	mov    $0x20,%edi
  8007a4:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8007a7:	83 eb 01             	sub    $0x1,%ebx
  8007aa:	75 f0                	jne    80079c <vprintfmt+0x335>
  8007ac:	e9 e0 fc ff ff       	jmpq   800491 <vprintfmt+0x2a>
  8007b1:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8007b5:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8007b9:	eb d4                	jmp    80078f <vprintfmt+0x328>
  if (lflag >= 2)
  8007bb:	83 f9 01             	cmp    $0x1,%ecx
  8007be:	7f 1d                	jg     8007dd <vprintfmt+0x376>
  else if (lflag)
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	74 5e                	je     800822 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8007c4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007c7:	83 f8 2f             	cmp    $0x2f,%eax
  8007ca:	77 48                	ja     800814 <vprintfmt+0x3ad>
  8007cc:	89 c2                	mov    %eax,%edx
  8007ce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d2:	83 c0 08             	add    $0x8,%eax
  8007d5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007d8:	48 8b 1a             	mov    (%rdx),%rbx
  8007db:	eb 17                	jmp    8007f4 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8007dd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007e0:	83 f8 2f             	cmp    $0x2f,%eax
  8007e3:	77 21                	ja     800806 <vprintfmt+0x39f>
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007eb:	83 c0 08             	add    $0x8,%eax
  8007ee:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007f1:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8007f4:	48 85 db             	test   %rbx,%rbx
  8007f7:	78 50                	js     800849 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8007f9:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8007fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800801:	e9 b4 01 00 00       	jmpq   8009ba <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800806:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80080a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80080e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800812:	eb dd                	jmp    8007f1 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800814:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800818:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80081c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800820:	eb b6                	jmp    8007d8 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800822:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800825:	83 f8 2f             	cmp    $0x2f,%eax
  800828:	77 11                	ja     80083b <vprintfmt+0x3d4>
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800830:	83 c0 08             	add    $0x8,%eax
  800833:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800836:	48 63 1a             	movslq (%rdx),%rbx
  800839:	eb b9                	jmp    8007f4 <vprintfmt+0x38d>
  80083b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80083f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800843:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800847:	eb ed                	jmp    800836 <vprintfmt+0x3cf>
          putch('-', putdat);
  800849:	4c 89 fe             	mov    %r15,%rsi
  80084c:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800851:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800854:	48 89 da             	mov    %rbx,%rdx
  800857:	48 f7 da             	neg    %rdx
        base = 10;
  80085a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80085f:	e9 56 01 00 00       	jmpq   8009ba <vprintfmt+0x553>
  if (lflag >= 2)
  800864:	83 f9 01             	cmp    $0x1,%ecx
  800867:	7f 25                	jg     80088e <vprintfmt+0x427>
  else if (lflag)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 5e                	je     8008cb <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80086d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800870:	83 f8 2f             	cmp    $0x2f,%eax
  800873:	77 48                	ja     8008bd <vprintfmt+0x456>
  800875:	89 c2                	mov    %eax,%edx
  800877:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80087b:	83 c0 08             	add    $0x8,%eax
  80087e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800881:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800884:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800889:	e9 2c 01 00 00       	jmpq   8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80088e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800891:	83 f8 2f             	cmp    $0x2f,%eax
  800894:	77 19                	ja     8008af <vprintfmt+0x448>
  800896:	89 c2                	mov    %eax,%edx
  800898:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80089c:	83 c0 08             	add    $0x8,%eax
  80089f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a2:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8008a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008aa:	e9 0b 01 00 00       	jmpq   8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8008af:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008bb:	eb e5                	jmp    8008a2 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8008bd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c9:	eb b6                	jmp    800881 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8008cb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ce:	83 f8 2f             	cmp    $0x2f,%eax
  8008d1:	77 18                	ja     8008eb <vprintfmt+0x484>
  8008d3:	89 c2                	mov    %eax,%edx
  8008d5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d9:	83 c0 08             	add    $0x8,%eax
  8008dc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008df:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8008e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008e6:	e9 cf 00 00 00       	jmpq   8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008eb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ef:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008f3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008f7:	eb e6                	jmp    8008df <vprintfmt+0x478>
  if (lflag >= 2)
  8008f9:	83 f9 01             	cmp    $0x1,%ecx
  8008fc:	7f 25                	jg     800923 <vprintfmt+0x4bc>
  else if (lflag)
  8008fe:	85 c9                	test   %ecx,%ecx
  800900:	74 5b                	je     80095d <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800902:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800905:	83 f8 2f             	cmp    $0x2f,%eax
  800908:	77 45                	ja     80094f <vprintfmt+0x4e8>
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800910:	83 c0 08             	add    $0x8,%eax
  800913:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800916:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800919:	b9 08 00 00 00       	mov    $0x8,%ecx
  80091e:	e9 97 00 00 00       	jmpq   8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800923:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800926:	83 f8 2f             	cmp    $0x2f,%eax
  800929:	77 16                	ja     800941 <vprintfmt+0x4da>
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800931:	83 c0 08             	add    $0x8,%eax
  800934:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800937:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80093a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80093f:	eb 79                	jmp    8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800941:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800945:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800949:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094d:	eb e8                	jmp    800937 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80094f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800953:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800957:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80095b:	eb b9                	jmp    800916 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  80095d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800960:	83 f8 2f             	cmp    $0x2f,%eax
  800963:	77 15                	ja     80097a <vprintfmt+0x513>
  800965:	89 c2                	mov    %eax,%edx
  800967:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096b:	83 c0 08             	add    $0x8,%eax
  80096e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800971:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800973:	b9 08 00 00 00       	mov    $0x8,%ecx
  800978:	eb 40                	jmp    8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80097a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800982:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800986:	eb e9                	jmp    800971 <vprintfmt+0x50a>
        putch('0', putdat);
  800988:	4c 89 fe             	mov    %r15,%rsi
  80098b:	bf 30 00 00 00       	mov    $0x30,%edi
  800990:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800993:	4c 89 fe             	mov    %r15,%rsi
  800996:	bf 78 00 00 00       	mov    $0x78,%edi
  80099b:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80099e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a1:	83 f8 2f             	cmp    $0x2f,%eax
  8009a4:	77 34                	ja     8009da <vprintfmt+0x573>
  8009a6:	89 c2                	mov    %eax,%edx
  8009a8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ac:	83 c0 08             	add    $0x8,%eax
  8009af:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b2:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8009b5:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8009ba:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8009bf:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8009c3:	4c 89 fe             	mov    %r15,%rsi
  8009c6:	4c 89 ef             	mov    %r13,%rdi
  8009c9:	48 b8 3d 03 80 00 00 	movabs $0x80033d,%rax
  8009d0:	00 00 00 
  8009d3:	ff d0                	callq  *%rax
        break;
  8009d5:	e9 b7 fa ff ff       	jmpq   800491 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8009da:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009de:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009e2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e6:	eb ca                	jmp    8009b2 <vprintfmt+0x54b>
  if (lflag >= 2)
  8009e8:	83 f9 01             	cmp    $0x1,%ecx
  8009eb:	7f 22                	jg     800a0f <vprintfmt+0x5a8>
  else if (lflag)
  8009ed:	85 c9                	test   %ecx,%ecx
  8009ef:	74 58                	je     800a49 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8009f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f4:	83 f8 2f             	cmp    $0x2f,%eax
  8009f7:	77 42                	ja     800a3b <vprintfmt+0x5d4>
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ff:	83 c0 08             	add    $0x8,%eax
  800a02:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a05:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a08:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a0d:	eb ab                	jmp    8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a0f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a12:	83 f8 2f             	cmp    $0x2f,%eax
  800a15:	77 16                	ja     800a2d <vprintfmt+0x5c6>
  800a17:	89 c2                	mov    %eax,%edx
  800a19:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a1d:	83 c0 08             	add    $0x8,%eax
  800a20:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a23:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a26:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a2b:	eb 8d                	jmp    8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a2d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a31:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a35:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a39:	eb e8                	jmp    800a23 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800a3b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a3f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a43:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a47:	eb bc                	jmp    800a05 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800a49:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a4c:	83 f8 2f             	cmp    $0x2f,%eax
  800a4f:	77 18                	ja     800a69 <vprintfmt+0x602>
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a57:	83 c0 08             	add    $0x8,%eax
  800a5a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a5d:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800a5f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a64:	e9 51 ff ff ff       	jmpq   8009ba <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a69:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a6d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a71:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a75:	eb e6                	jmp    800a5d <vprintfmt+0x5f6>
        putch(ch, putdat);
  800a77:	4c 89 fe             	mov    %r15,%rsi
  800a7a:	bf 25 00 00 00       	mov    $0x25,%edi
  800a7f:	41 ff d5             	callq  *%r13
        break;
  800a82:	e9 0a fa ff ff       	jmpq   800491 <vprintfmt+0x2a>
        putch('%', putdat);
  800a87:	4c 89 fe             	mov    %r15,%rsi
  800a8a:	bf 25 00 00 00       	mov    $0x25,%edi
  800a8f:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800a92:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800a96:	0f 84 15 fa ff ff    	je     8004b1 <vprintfmt+0x4a>
  800a9c:	49 89 de             	mov    %rbx,%r14
  800a9f:	49 83 ee 01          	sub    $0x1,%r14
  800aa3:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800aa8:	75 f5                	jne    800a9f <vprintfmt+0x638>
  800aaa:	e9 e2 f9 ff ff       	jmpq   800491 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800aaf:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800ab3:	74 06                	je     800abb <vprintfmt+0x654>
  800ab5:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800ab9:	7f 21                	jg     800adc <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800abb:	bf 28 00 00 00       	mov    $0x28,%edi
  800ac0:	48 bb 65 1c 80 00 00 	movabs $0x801c65,%rbx
  800ac7:	00 00 00 
  800aca:	b8 28 00 00 00       	mov    $0x28,%eax
  800acf:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ad3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800ad7:	e9 82 fc ff ff       	jmpq   80075e <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800adc:	49 63 f4             	movslq %r12d,%rsi
  800adf:	48 bf 64 1c 80 00 00 	movabs $0x801c64,%rdi
  800ae6:	00 00 00 
  800ae9:	48 b8 3e 0c 80 00 00 	movabs $0x800c3e,%rax
  800af0:	00 00 00 
  800af3:	ff d0                	callq  *%rax
  800af5:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800af8:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800afb:	48 be 64 1c 80 00 00 	movabs $0x801c64,%rsi
  800b02:	00 00 00 
  800b05:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	0f 8f f2 fb ff ff    	jg     800703 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b11:	48 bb 65 1c 80 00 00 	movabs $0x801c65,%rbx
  800b18:	00 00 00 
  800b1b:	b8 28 00 00 00       	mov    $0x28,%eax
  800b20:	bf 28 00 00 00       	mov    $0x28,%edi
  800b25:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b29:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b2d:	e9 2c fc ff ff       	jmpq   80075e <vprintfmt+0x2f7>
}
  800b32:	48 83 c4 48          	add    $0x48,%rsp
  800b36:	5b                   	pop    %rbx
  800b37:	41 5c                	pop    %r12
  800b39:	41 5d                	pop    %r13
  800b3b:	41 5e                	pop    %r14
  800b3d:	41 5f                	pop    %r15
  800b3f:	5d                   	pop    %rbp
  800b40:	c3                   	retq   

0000000000800b41 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800b41:	55                   	push   %rbp
  800b42:	48 89 e5             	mov    %rsp,%rbp
  800b45:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800b49:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800b4d:	48 63 c6             	movslq %esi,%rax
  800b50:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800b55:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800b59:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800b60:	48 85 ff             	test   %rdi,%rdi
  800b63:	74 2a                	je     800b8f <vsnprintf+0x4e>
  800b65:	85 f6                	test   %esi,%esi
  800b67:	7e 26                	jle    800b8f <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800b69:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800b6d:	48 bf c9 03 80 00 00 	movabs $0x8003c9,%rdi
  800b74:	00 00 00 
  800b77:	48 b8 67 04 80 00 00 	movabs $0x800467,%rax
  800b7e:	00 00 00 
  800b81:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800b83:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800b87:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800b8a:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800b8d:	c9                   	leaveq 
  800b8e:	c3                   	retq   
    return -E_INVAL;
  800b8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b94:	eb f7                	jmp    800b8d <vsnprintf+0x4c>

0000000000800b96 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800b96:	55                   	push   %rbp
  800b97:	48 89 e5             	mov    %rsp,%rbp
  800b9a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ba1:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ba8:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800baf:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800bb6:	84 c0                	test   %al,%al
  800bb8:	74 20                	je     800bda <snprintf+0x44>
  800bba:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800bbe:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800bc2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800bc6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800bca:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800bce:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800bd2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800bd6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800bda:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800be1:	00 00 00 
  800be4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800beb:	00 00 00 
  800bee:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800bf2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800bf9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c00:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c07:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c0e:	48 b8 41 0b 80 00 00 	movabs $0x800b41,%rax
  800c15:	00 00 00 
  800c18:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800c1a:	c9                   	leaveq 
  800c1b:	c3                   	retq   

0000000000800c1c <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800c1c:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c1f:	74 17                	je     800c38 <strlen+0x1c>
  800c21:	48 89 fa             	mov    %rdi,%rdx
  800c24:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c29:	29 f9                	sub    %edi,%ecx
    n++;
  800c2b:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800c2e:	48 83 c2 01          	add    $0x1,%rdx
  800c32:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c35:	75 f4                	jne    800c2b <strlen+0xf>
  800c37:	c3                   	retq   
  800c38:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c3d:	c3                   	retq   

0000000000800c3e <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3e:	48 85 f6             	test   %rsi,%rsi
  800c41:	74 24                	je     800c67 <strnlen+0x29>
  800c43:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c46:	74 25                	je     800c6d <strnlen+0x2f>
  800c48:	48 01 fe             	add    %rdi,%rsi
  800c4b:	48 89 fa             	mov    %rdi,%rdx
  800c4e:	b9 01 00 00 00       	mov    $0x1,%ecx
  800c53:	29 f9                	sub    %edi,%ecx
    n++;
  800c55:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c58:	48 83 c2 01          	add    $0x1,%rdx
  800c5c:	48 39 f2             	cmp    %rsi,%rdx
  800c5f:	74 11                	je     800c72 <strnlen+0x34>
  800c61:	80 3a 00             	cmpb   $0x0,(%rdx)
  800c64:	75 ef                	jne    800c55 <strnlen+0x17>
  800c66:	c3                   	retq   
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	c3                   	retq   
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800c72:	c3                   	retq   

0000000000800c73 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800c73:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800c7f:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800c82:	48 83 c2 01          	add    $0x1,%rdx
  800c86:	84 c9                	test   %cl,%cl
  800c88:	75 f1                	jne    800c7b <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800c8a:	c3                   	retq   

0000000000800c8b <strcat>:

char *
strcat(char *dst, const char *src) {
  800c8b:	55                   	push   %rbp
  800c8c:	48 89 e5             	mov    %rsp,%rbp
  800c8f:	41 54                	push   %r12
  800c91:	53                   	push   %rbx
  800c92:	48 89 fb             	mov    %rdi,%rbx
  800c95:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800c98:	48 b8 1c 0c 80 00 00 	movabs $0x800c1c,%rax
  800c9f:	00 00 00 
  800ca2:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800ca4:	48 63 f8             	movslq %eax,%rdi
  800ca7:	48 01 df             	add    %rbx,%rdi
  800caa:	4c 89 e6             	mov    %r12,%rsi
  800cad:	48 b8 73 0c 80 00 00 	movabs $0x800c73,%rax
  800cb4:	00 00 00 
  800cb7:	ff d0                	callq  *%rax
  return dst;
}
  800cb9:	48 89 d8             	mov    %rbx,%rax
  800cbc:	5b                   	pop    %rbx
  800cbd:	41 5c                	pop    %r12
  800cbf:	5d                   	pop    %rbp
  800cc0:	c3                   	retq   

0000000000800cc1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc1:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800cc4:	48 85 d2             	test   %rdx,%rdx
  800cc7:	74 1f                	je     800ce8 <strncpy+0x27>
  800cc9:	48 01 fa             	add    %rdi,%rdx
  800ccc:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800ccf:	48 83 c1 01          	add    $0x1,%rcx
  800cd3:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cd7:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800cdb:	41 80 f8 01          	cmp    $0x1,%r8b
  800cdf:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800ce3:	48 39 ca             	cmp    %rcx,%rdx
  800ce6:	75 e7                	jne    800ccf <strncpy+0xe>
  }
  return ret;
}
  800ce8:	c3                   	retq   

0000000000800ce9 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800ce9:	48 89 f8             	mov    %rdi,%rax
  800cec:	48 85 d2             	test   %rdx,%rdx
  800cef:	74 36                	je     800d27 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800cf1:	48 83 fa 01          	cmp    $0x1,%rdx
  800cf5:	74 2d                	je     800d24 <strlcpy+0x3b>
  800cf7:	44 0f b6 06          	movzbl (%rsi),%r8d
  800cfb:	45 84 c0             	test   %r8b,%r8b
  800cfe:	74 24                	je     800d24 <strlcpy+0x3b>
  800d00:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d04:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d09:	48 83 c0 01          	add    $0x1,%rax
  800d0d:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d11:	48 39 d1             	cmp    %rdx,%rcx
  800d14:	74 0e                	je     800d24 <strlcpy+0x3b>
  800d16:	48 83 c1 01          	add    $0x1,%rcx
  800d1a:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800d1f:	45 84 c0             	test   %r8b,%r8b
  800d22:	75 e5                	jne    800d09 <strlcpy+0x20>
    *dst = '\0';
  800d24:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800d27:	48 29 f8             	sub    %rdi,%rax
}
  800d2a:	c3                   	retq   

0000000000800d2b <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800d2b:	0f b6 07             	movzbl (%rdi),%eax
  800d2e:	84 c0                	test   %al,%al
  800d30:	74 17                	je     800d49 <strcmp+0x1e>
  800d32:	3a 06                	cmp    (%rsi),%al
  800d34:	75 13                	jne    800d49 <strcmp+0x1e>
    p++, q++;
  800d36:	48 83 c7 01          	add    $0x1,%rdi
  800d3a:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800d3e:	0f b6 07             	movzbl (%rdi),%eax
  800d41:	84 c0                	test   %al,%al
  800d43:	74 04                	je     800d49 <strcmp+0x1e>
  800d45:	3a 06                	cmp    (%rsi),%al
  800d47:	74 ed                	je     800d36 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800d49:	0f b6 c0             	movzbl %al,%eax
  800d4c:	0f b6 16             	movzbl (%rsi),%edx
  800d4f:	29 d0                	sub    %edx,%eax
}
  800d51:	c3                   	retq   

0000000000800d52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800d52:	48 85 d2             	test   %rdx,%rdx
  800d55:	74 2f                	je     800d86 <strncmp+0x34>
  800d57:	0f b6 07             	movzbl (%rdi),%eax
  800d5a:	84 c0                	test   %al,%al
  800d5c:	74 1f                	je     800d7d <strncmp+0x2b>
  800d5e:	3a 06                	cmp    (%rsi),%al
  800d60:	75 1b                	jne    800d7d <strncmp+0x2b>
  800d62:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800d65:	48 83 c7 01          	add    $0x1,%rdi
  800d69:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800d6d:	48 39 d7             	cmp    %rdx,%rdi
  800d70:	74 1a                	je     800d8c <strncmp+0x3a>
  800d72:	0f b6 07             	movzbl (%rdi),%eax
  800d75:	84 c0                	test   %al,%al
  800d77:	74 04                	je     800d7d <strncmp+0x2b>
  800d79:	3a 06                	cmp    (%rsi),%al
  800d7b:	74 e8                	je     800d65 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800d7d:	0f b6 07             	movzbl (%rdi),%eax
  800d80:	0f b6 16             	movzbl (%rsi),%edx
  800d83:	29 d0                	sub    %edx,%eax
}
  800d85:	c3                   	retq   
    return 0;
  800d86:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8b:	c3                   	retq   
  800d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d91:	c3                   	retq   

0000000000800d92 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800d92:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800d94:	0f b6 07             	movzbl (%rdi),%eax
  800d97:	84 c0                	test   %al,%al
  800d99:	74 1e                	je     800db9 <strchr+0x27>
    if (*s == c)
  800d9b:	40 38 c6             	cmp    %al,%sil
  800d9e:	74 1f                	je     800dbf <strchr+0x2d>
  for (; *s; s++)
  800da0:	48 83 c7 01          	add    $0x1,%rdi
  800da4:	0f b6 07             	movzbl (%rdi),%eax
  800da7:	84 c0                	test   %al,%al
  800da9:	74 08                	je     800db3 <strchr+0x21>
    if (*s == c)
  800dab:	38 d0                	cmp    %dl,%al
  800dad:	75 f1                	jne    800da0 <strchr+0xe>
  for (; *s; s++)
  800daf:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800db2:	c3                   	retq   
  return 0;
  800db3:	b8 00 00 00 00       	mov    $0x0,%eax
  800db8:	c3                   	retq   
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	c3                   	retq   
    if (*s == c)
  800dbf:	48 89 f8             	mov    %rdi,%rax
  800dc2:	c3                   	retq   

0000000000800dc3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800dc3:	48 89 f8             	mov    %rdi,%rax
  800dc6:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800dc8:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800dcb:	40 38 f2             	cmp    %sil,%dl
  800dce:	74 13                	je     800de3 <strfind+0x20>
  800dd0:	84 d2                	test   %dl,%dl
  800dd2:	74 0f                	je     800de3 <strfind+0x20>
  for (; *s; s++)
  800dd4:	48 83 c0 01          	add    $0x1,%rax
  800dd8:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800ddb:	38 ca                	cmp    %cl,%dl
  800ddd:	74 04                	je     800de3 <strfind+0x20>
  800ddf:	84 d2                	test   %dl,%dl
  800de1:	75 f1                	jne    800dd4 <strfind+0x11>
      break;
  return (char *)s;
}
  800de3:	c3                   	retq   

0000000000800de4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800de4:	48 85 d2             	test   %rdx,%rdx
  800de7:	74 3a                	je     800e23 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800de9:	48 89 f8             	mov    %rdi,%rax
  800dec:	48 09 d0             	or     %rdx,%rax
  800def:	a8 03                	test   $0x3,%al
  800df1:	75 28                	jne    800e1b <memset+0x37>
    uint32_t k = c & 0xFFU;
  800df3:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800df7:	89 f0                	mov    %esi,%eax
  800df9:	c1 e0 08             	shl    $0x8,%eax
  800dfc:	89 f1                	mov    %esi,%ecx
  800dfe:	c1 e1 18             	shl    $0x18,%ecx
  800e01:	41 89 f0             	mov    %esi,%r8d
  800e04:	41 c1 e0 10          	shl    $0x10,%r8d
  800e08:	44 09 c1             	or     %r8d,%ecx
  800e0b:	09 ce                	or     %ecx,%esi
  800e0d:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e0f:	48 c1 ea 02          	shr    $0x2,%rdx
  800e13:	48 89 d1             	mov    %rdx,%rcx
  800e16:	fc                   	cld    
  800e17:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e19:	eb 08                	jmp    800e23 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800e1b:	89 f0                	mov    %esi,%eax
  800e1d:	48 89 d1             	mov    %rdx,%rcx
  800e20:	fc                   	cld    
  800e21:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800e23:	48 89 f8             	mov    %rdi,%rax
  800e26:	c3                   	retq   

0000000000800e27 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800e27:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800e2a:	48 39 fe             	cmp    %rdi,%rsi
  800e2d:	73 40                	jae    800e6f <memmove+0x48>
  800e2f:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800e33:	48 39 f9             	cmp    %rdi,%rcx
  800e36:	76 37                	jbe    800e6f <memmove+0x48>
    s += n;
    d += n;
  800e38:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e3c:	48 89 fe             	mov    %rdi,%rsi
  800e3f:	48 09 d6             	or     %rdx,%rsi
  800e42:	48 09 ce             	or     %rcx,%rsi
  800e45:	40 f6 c6 03          	test   $0x3,%sil
  800e49:	75 14                	jne    800e5f <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800e4b:	48 83 ef 04          	sub    $0x4,%rdi
  800e4f:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800e53:	48 c1 ea 02          	shr    $0x2,%rdx
  800e57:	48 89 d1             	mov    %rdx,%rcx
  800e5a:	fd                   	std    
  800e5b:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e5d:	eb 0e                	jmp    800e6d <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800e5f:	48 83 ef 01          	sub    $0x1,%rdi
  800e63:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800e67:	48 89 d1             	mov    %rdx,%rcx
  800e6a:	fd                   	std    
  800e6b:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800e6d:	fc                   	cld    
  800e6e:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800e6f:	48 89 c1             	mov    %rax,%rcx
  800e72:	48 09 d1             	or     %rdx,%rcx
  800e75:	48 09 f1             	or     %rsi,%rcx
  800e78:	f6 c1 03             	test   $0x3,%cl
  800e7b:	75 0e                	jne    800e8b <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800e7d:	48 c1 ea 02          	shr    $0x2,%rdx
  800e81:	48 89 d1             	mov    %rdx,%rcx
  800e84:	48 89 c7             	mov    %rax,%rdi
  800e87:	fc                   	cld    
  800e88:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800e8a:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800e8b:	48 89 c7             	mov    %rax,%rdi
  800e8e:	48 89 d1             	mov    %rdx,%rcx
  800e91:	fc                   	cld    
  800e92:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800e94:	c3                   	retq   

0000000000800e95 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800e95:	55                   	push   %rbp
  800e96:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800e99:	48 b8 27 0e 80 00 00 	movabs $0x800e27,%rax
  800ea0:	00 00 00 
  800ea3:	ff d0                	callq  *%rax
}
  800ea5:	5d                   	pop    %rbp
  800ea6:	c3                   	retq   

0000000000800ea7 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800ea7:	55                   	push   %rbp
  800ea8:	48 89 e5             	mov    %rsp,%rbp
  800eab:	41 57                	push   %r15
  800ead:	41 56                	push   %r14
  800eaf:	41 55                	push   %r13
  800eb1:	41 54                	push   %r12
  800eb3:	53                   	push   %rbx
  800eb4:	48 83 ec 08          	sub    $0x8,%rsp
  800eb8:	49 89 fe             	mov    %rdi,%r14
  800ebb:	49 89 f7             	mov    %rsi,%r15
  800ebe:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800ec1:	48 89 f7             	mov    %rsi,%rdi
  800ec4:	48 b8 1c 0c 80 00 00 	movabs $0x800c1c,%rax
  800ecb:	00 00 00 
  800ece:	ff d0                	callq  *%rax
  800ed0:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800ed3:	4c 89 ee             	mov    %r13,%rsi
  800ed6:	4c 89 f7             	mov    %r14,%rdi
  800ed9:	48 b8 3e 0c 80 00 00 	movabs $0x800c3e,%rax
  800ee0:	00 00 00 
  800ee3:	ff d0                	callq  *%rax
  800ee5:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800ee8:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800eec:	4d 39 e5             	cmp    %r12,%r13
  800eef:	74 26                	je     800f17 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800ef1:	4c 89 e8             	mov    %r13,%rax
  800ef4:	4c 29 e0             	sub    %r12,%rax
  800ef7:	48 39 d8             	cmp    %rbx,%rax
  800efa:	76 2a                	jbe    800f26 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800efc:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f00:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f04:	4c 89 fe             	mov    %r15,%rsi
  800f07:	48 b8 95 0e 80 00 00 	movabs $0x800e95,%rax
  800f0e:	00 00 00 
  800f11:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f13:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800f17:	48 83 c4 08          	add    $0x8,%rsp
  800f1b:	5b                   	pop    %rbx
  800f1c:	41 5c                	pop    %r12
  800f1e:	41 5d                	pop    %r13
  800f20:	41 5e                	pop    %r14
  800f22:	41 5f                	pop    %r15
  800f24:	5d                   	pop    %rbp
  800f25:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800f26:	49 83 ed 01          	sub    $0x1,%r13
  800f2a:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f2e:	4c 89 ea             	mov    %r13,%rdx
  800f31:	4c 89 fe             	mov    %r15,%rsi
  800f34:	48 b8 95 0e 80 00 00 	movabs $0x800e95,%rax
  800f3b:	00 00 00 
  800f3e:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800f40:	4d 01 ee             	add    %r13,%r14
  800f43:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800f48:	eb c9                	jmp    800f13 <strlcat+0x6c>

0000000000800f4a <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800f4a:	48 85 d2             	test   %rdx,%rdx
  800f4d:	74 3a                	je     800f89 <memcmp+0x3f>
    if (*s1 != *s2)
  800f4f:	0f b6 0f             	movzbl (%rdi),%ecx
  800f52:	44 0f b6 06          	movzbl (%rsi),%r8d
  800f56:	44 38 c1             	cmp    %r8b,%cl
  800f59:	75 1d                	jne    800f78 <memcmp+0x2e>
  800f5b:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800f60:	48 39 d0             	cmp    %rdx,%rax
  800f63:	74 1e                	je     800f83 <memcmp+0x39>
    if (*s1 != *s2)
  800f65:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800f69:	48 83 c0 01          	add    $0x1,%rax
  800f6d:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800f73:	44 38 c1             	cmp    %r8b,%cl
  800f76:	74 e8                	je     800f60 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800f78:	0f b6 c1             	movzbl %cl,%eax
  800f7b:	45 0f b6 c0          	movzbl %r8b,%r8d
  800f7f:	44 29 c0             	sub    %r8d,%eax
  800f82:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800f83:	b8 00 00 00 00       	mov    $0x0,%eax
  800f88:	c3                   	retq   
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f8e:	c3                   	retq   

0000000000800f8f <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800f8f:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800f93:	48 39 c7             	cmp    %rax,%rdi
  800f96:	73 19                	jae    800fb1 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	40 38 37             	cmp    %sil,(%rdi)
  800f9d:	74 16                	je     800fb5 <memfind+0x26>
  for (; s < ends; s++)
  800f9f:	48 83 c7 01          	add    $0x1,%rdi
  800fa3:	48 39 f8             	cmp    %rdi,%rax
  800fa6:	74 08                	je     800fb0 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800fa8:	38 17                	cmp    %dl,(%rdi)
  800faa:	75 f3                	jne    800f9f <memfind+0x10>
  for (; s < ends; s++)
  800fac:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800faf:	c3                   	retq   
  800fb0:	c3                   	retq   
  for (; s < ends; s++)
  800fb1:	48 89 f8             	mov    %rdi,%rax
  800fb4:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800fb5:	48 89 f8             	mov    %rdi,%rax
  800fb8:	c3                   	retq   

0000000000800fb9 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800fb9:	0f b6 07             	movzbl (%rdi),%eax
  800fbc:	3c 20                	cmp    $0x20,%al
  800fbe:	74 04                	je     800fc4 <strtol+0xb>
  800fc0:	3c 09                	cmp    $0x9,%al
  800fc2:	75 0f                	jne    800fd3 <strtol+0x1a>
    s++;
  800fc4:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800fc8:	0f b6 07             	movzbl (%rdi),%eax
  800fcb:	3c 20                	cmp    $0x20,%al
  800fcd:	74 f5                	je     800fc4 <strtol+0xb>
  800fcf:	3c 09                	cmp    $0x9,%al
  800fd1:	74 f1                	je     800fc4 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800fd3:	3c 2b                	cmp    $0x2b,%al
  800fd5:	74 2b                	je     801002 <strtol+0x49>
  int neg  = 0;
  800fd7:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800fdd:	3c 2d                	cmp    $0x2d,%al
  800fdf:	74 2d                	je     80100e <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe1:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800fe7:	75 0f                	jne    800ff8 <strtol+0x3f>
  800fe9:	80 3f 30             	cmpb   $0x30,(%rdi)
  800fec:	74 2c                	je     80101a <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800fee:	85 d2                	test   %edx,%edx
  800ff0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ff5:	0f 44 d0             	cmove  %eax,%edx
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800ffd:	4c 63 d2             	movslq %edx,%r10
  801000:	eb 5c                	jmp    80105e <strtol+0xa5>
    s++;
  801002:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801006:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80100c:	eb d3                	jmp    800fe1 <strtol+0x28>
    s++, neg = 1;
  80100e:	48 83 c7 01          	add    $0x1,%rdi
  801012:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801018:	eb c7                	jmp    800fe1 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80101a:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80101e:	74 0f                	je     80102f <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801020:	85 d2                	test   %edx,%edx
  801022:	75 d4                	jne    800ff8 <strtol+0x3f>
    s++, base = 8;
  801024:	48 83 c7 01          	add    $0x1,%rdi
  801028:	ba 08 00 00 00       	mov    $0x8,%edx
  80102d:	eb c9                	jmp    800ff8 <strtol+0x3f>
    s += 2, base = 16;
  80102f:	48 83 c7 02          	add    $0x2,%rdi
  801033:	ba 10 00 00 00       	mov    $0x10,%edx
  801038:	eb be                	jmp    800ff8 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80103a:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80103e:	41 80 f8 19          	cmp    $0x19,%r8b
  801042:	77 2f                	ja     801073 <strtol+0xba>
      dig = *s - 'a' + 10;
  801044:	44 0f be c1          	movsbl %cl,%r8d
  801048:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80104c:	39 d1                	cmp    %edx,%ecx
  80104e:	7d 37                	jge    801087 <strtol+0xce>
    s++, val = (val * base) + dig;
  801050:	48 83 c7 01          	add    $0x1,%rdi
  801054:	49 0f af c2          	imul   %r10,%rax
  801058:	48 63 c9             	movslq %ecx,%rcx
  80105b:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80105e:	0f b6 0f             	movzbl (%rdi),%ecx
  801061:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801065:	41 80 f8 09          	cmp    $0x9,%r8b
  801069:	77 cf                	ja     80103a <strtol+0x81>
      dig = *s - '0';
  80106b:	0f be c9             	movsbl %cl,%ecx
  80106e:	83 e9 30             	sub    $0x30,%ecx
  801071:	eb d9                	jmp    80104c <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801073:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801077:	41 80 f8 19          	cmp    $0x19,%r8b
  80107b:	77 0a                	ja     801087 <strtol+0xce>
      dig = *s - 'A' + 10;
  80107d:	44 0f be c1          	movsbl %cl,%r8d
  801081:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801085:	eb c5                	jmp    80104c <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801087:	48 85 f6             	test   %rsi,%rsi
  80108a:	74 03                	je     80108f <strtol+0xd6>
    *endptr = (char *)s;
  80108c:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80108f:	48 89 c2             	mov    %rax,%rdx
  801092:	48 f7 da             	neg    %rdx
  801095:	45 85 c9             	test   %r9d,%r9d
  801098:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80109c:	c3                   	retq   

000000000080109d <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80109d:	55                   	push   %rbp
  80109e:	48 89 e5             	mov    %rsp,%rbp
  8010a1:	53                   	push   %rbx
  8010a2:	48 89 fa             	mov    %rdi,%rdx
  8010a5:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	48 89 c3             	mov    %rax,%rbx
  8010b0:	48 89 c7             	mov    %rax,%rdi
  8010b3:	48 89 c6             	mov    %rax,%rsi
  8010b6:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8010b8:	5b                   	pop    %rbx
  8010b9:	5d                   	pop    %rbp
  8010ba:	c3                   	retq   

00000000008010bb <sys_cgetc>:

int
sys_cgetc(void) {
  8010bb:	55                   	push   %rbp
  8010bc:	48 89 e5             	mov    %rsp,%rbp
  8010bf:	53                   	push   %rbx
  asm volatile("int %1\n"
  8010c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ca:	48 89 ca             	mov    %rcx,%rdx
  8010cd:	48 89 cb             	mov    %rcx,%rbx
  8010d0:	48 89 cf             	mov    %rcx,%rdi
  8010d3:	48 89 ce             	mov    %rcx,%rsi
  8010d6:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010d8:	5b                   	pop    %rbx
  8010d9:	5d                   	pop    %rbp
  8010da:	c3                   	retq   

00000000008010db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8010db:	55                   	push   %rbp
  8010dc:	48 89 e5             	mov    %rsp,%rbp
  8010df:	53                   	push   %rbx
  8010e0:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010e4:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8010e7:	be 00 00 00 00       	mov    $0x0,%esi
  8010ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f1:	48 89 f1             	mov    %rsi,%rcx
  8010f4:	48 89 f3             	mov    %rsi,%rbx
  8010f7:	48 89 f7             	mov    %rsi,%rdi
  8010fa:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010fc:	48 85 c0             	test   %rax,%rax
  8010ff:	7f 07                	jg     801108 <sys_env_destroy+0x2d>
}
  801101:	48 83 c4 08          	add    $0x8,%rsp
  801105:	5b                   	pop    %rbx
  801106:	5d                   	pop    %rbp
  801107:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801108:	49 89 c0             	mov    %rax,%r8
  80110b:	b9 03 00 00 00       	mov    $0x3,%ecx
  801110:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  801117:	00 00 00 
  80111a:	be 22 00 00 00       	mov    $0x22,%esi
  80111f:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  801126:	00 00 00 
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
  80112e:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  801135:	00 00 00 
  801138:	41 ff d1             	callq  *%r9

000000000080113b <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80113b:	55                   	push   %rbp
  80113c:	48 89 e5             	mov    %rsp,%rbp
  80113f:	53                   	push   %rbx
  asm volatile("int %1\n"
  801140:	b9 00 00 00 00       	mov    $0x0,%ecx
  801145:	b8 02 00 00 00       	mov    $0x2,%eax
  80114a:	48 89 ca             	mov    %rcx,%rdx
  80114d:	48 89 cb             	mov    %rcx,%rbx
  801150:	48 89 cf             	mov    %rcx,%rdi
  801153:	48 89 ce             	mov    %rcx,%rsi
  801156:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801158:	5b                   	pop    %rbx
  801159:	5d                   	pop    %rbp
  80115a:	c3                   	retq   

000000000080115b <sys_yield>:

void
sys_yield(void) {
  80115b:	55                   	push   %rbp
  80115c:	48 89 e5             	mov    %rsp,%rbp
  80115f:	53                   	push   %rbx
  asm volatile("int %1\n"
  801160:	b9 00 00 00 00       	mov    $0x0,%ecx
  801165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80116a:	48 89 ca             	mov    %rcx,%rdx
  80116d:	48 89 cb             	mov    %rcx,%rbx
  801170:	48 89 cf             	mov    %rcx,%rdi
  801173:	48 89 ce             	mov    %rcx,%rsi
  801176:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801178:	5b                   	pop    %rbx
  801179:	5d                   	pop    %rbp
  80117a:	c3                   	retq   

000000000080117b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  80117b:	55                   	push   %rbp
  80117c:	48 89 e5             	mov    %rsp,%rbp
  80117f:	53                   	push   %rbx
  801180:	48 83 ec 08          	sub    $0x8,%rsp
  801184:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801187:	4c 63 c7             	movslq %edi,%r8
  80118a:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  80118d:	be 00 00 00 00       	mov    $0x0,%esi
  801192:	b8 04 00 00 00       	mov    $0x4,%eax
  801197:	4c 89 c2             	mov    %r8,%rdx
  80119a:	48 89 f7             	mov    %rsi,%rdi
  80119d:	cd 30                	int    $0x30
  if (check && ret > 0)
  80119f:	48 85 c0             	test   %rax,%rax
  8011a2:	7f 07                	jg     8011ab <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8011a4:	48 83 c4 08          	add    $0x8,%rsp
  8011a8:	5b                   	pop    %rbx
  8011a9:	5d                   	pop    %rbp
  8011aa:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011ab:	49 89 c0             	mov    %rax,%r8
  8011ae:	b9 04 00 00 00       	mov    $0x4,%ecx
  8011b3:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  8011ba:	00 00 00 
  8011bd:	be 22 00 00 00       	mov    $0x22,%esi
  8011c2:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  8011c9:	00 00 00 
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d1:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  8011d8:	00 00 00 
  8011db:	41 ff d1             	callq  *%r9

00000000008011de <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8011de:	55                   	push   %rbp
  8011df:	48 89 e5             	mov    %rsp,%rbp
  8011e2:	53                   	push   %rbx
  8011e3:	48 83 ec 08          	sub    $0x8,%rsp
  8011e7:	41 89 f9             	mov    %edi,%r9d
  8011ea:	49 89 f2             	mov    %rsi,%r10
  8011ed:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8011f0:	4d 63 c9             	movslq %r9d,%r9
  8011f3:	48 63 da             	movslq %edx,%rbx
  8011f6:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8011f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8011fe:	4c 89 ca             	mov    %r9,%rdx
  801201:	4c 89 d1             	mov    %r10,%rcx
  801204:	cd 30                	int    $0x30
  if (check && ret > 0)
  801206:	48 85 c0             	test   %rax,%rax
  801209:	7f 07                	jg     801212 <sys_page_map+0x34>
}
  80120b:	48 83 c4 08          	add    $0x8,%rsp
  80120f:	5b                   	pop    %rbx
  801210:	5d                   	pop    %rbp
  801211:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801212:	49 89 c0             	mov    %rax,%r8
  801215:	b9 05 00 00 00       	mov    $0x5,%ecx
  80121a:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  801221:	00 00 00 
  801224:	be 22 00 00 00       	mov    $0x22,%esi
  801229:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  801230:	00 00 00 
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  80123f:	00 00 00 
  801242:	41 ff d1             	callq  *%r9

0000000000801245 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801245:	55                   	push   %rbp
  801246:	48 89 e5             	mov    %rsp,%rbp
  801249:	53                   	push   %rbx
  80124a:	48 83 ec 08          	sub    $0x8,%rsp
  80124e:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801251:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801254:	be 00 00 00 00       	mov    $0x0,%esi
  801259:	b8 06 00 00 00       	mov    $0x6,%eax
  80125e:	48 89 f3             	mov    %rsi,%rbx
  801261:	48 89 f7             	mov    %rsi,%rdi
  801264:	cd 30                	int    $0x30
  if (check && ret > 0)
  801266:	48 85 c0             	test   %rax,%rax
  801269:	7f 07                	jg     801272 <sys_page_unmap+0x2d>
}
  80126b:	48 83 c4 08          	add    $0x8,%rsp
  80126f:	5b                   	pop    %rbx
  801270:	5d                   	pop    %rbp
  801271:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801272:	49 89 c0             	mov    %rax,%r8
  801275:	b9 06 00 00 00       	mov    $0x6,%ecx
  80127a:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  801281:	00 00 00 
  801284:	be 22 00 00 00       	mov    $0x22,%esi
  801289:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  801290:	00 00 00 
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
  801298:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  80129f:	00 00 00 
  8012a2:	41 ff d1             	callq  *%r9

00000000008012a5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8012a5:	55                   	push   %rbp
  8012a6:	48 89 e5             	mov    %rsp,%rbp
  8012a9:	53                   	push   %rbx
  8012aa:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8012ae:	48 63 d7             	movslq %edi,%rdx
  8012b1:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8012b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8012be:	48 89 df             	mov    %rbx,%rdi
  8012c1:	48 89 de             	mov    %rbx,%rsi
  8012c4:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012c6:	48 85 c0             	test   %rax,%rax
  8012c9:	7f 07                	jg     8012d2 <sys_env_set_status+0x2d>
}
  8012cb:	48 83 c4 08          	add    $0x8,%rsp
  8012cf:	5b                   	pop    %rbx
  8012d0:	5d                   	pop    %rbp
  8012d1:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012d2:	49 89 c0             	mov    %rax,%r8
  8012d5:	b9 08 00 00 00       	mov    $0x8,%ecx
  8012da:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  8012e1:	00 00 00 
  8012e4:	be 22 00 00 00       	mov    $0x22,%esi
  8012e9:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  8012f0:	00 00 00 
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f8:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  8012ff:	00 00 00 
  801302:	41 ff d1             	callq  *%r9

0000000000801305 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801305:	55                   	push   %rbp
  801306:	48 89 e5             	mov    %rsp,%rbp
  801309:	53                   	push   %rbx
  80130a:	48 83 ec 08          	sub    $0x8,%rsp
  80130e:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801311:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801314:	be 00 00 00 00       	mov    $0x0,%esi
  801319:	b8 09 00 00 00       	mov    $0x9,%eax
  80131e:	48 89 f3             	mov    %rsi,%rbx
  801321:	48 89 f7             	mov    %rsi,%rdi
  801324:	cd 30                	int    $0x30
  if (check && ret > 0)
  801326:	48 85 c0             	test   %rax,%rax
  801329:	7f 07                	jg     801332 <sys_env_set_pgfault_upcall+0x2d>
}
  80132b:	48 83 c4 08          	add    $0x8,%rsp
  80132f:	5b                   	pop    %rbx
  801330:	5d                   	pop    %rbp
  801331:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801332:	49 89 c0             	mov    %rax,%r8
  801335:	b9 09 00 00 00       	mov    $0x9,%ecx
  80133a:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  801341:	00 00 00 
  801344:	be 22 00 00 00       	mov    $0x22,%esi
  801349:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  801350:	00 00 00 
  801353:	b8 00 00 00 00       	mov    $0x0,%eax
  801358:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  80135f:	00 00 00 
  801362:	41 ff d1             	callq  *%r9

0000000000801365 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801365:	55                   	push   %rbp
  801366:	48 89 e5             	mov    %rsp,%rbp
  801369:	53                   	push   %rbx
  80136a:	49 89 f0             	mov    %rsi,%r8
  80136d:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801370:	48 63 d7             	movslq %edi,%rdx
  801373:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801376:	b8 0b 00 00 00       	mov    $0xb,%eax
  80137b:	be 00 00 00 00       	mov    $0x0,%esi
  801380:	4c 89 c1             	mov    %r8,%rcx
  801383:	cd 30                	int    $0x30
}
  801385:	5b                   	pop    %rbx
  801386:	5d                   	pop    %rbp
  801387:	c3                   	retq   

0000000000801388 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801388:	55                   	push   %rbp
  801389:	48 89 e5             	mov    %rsp,%rbp
  80138c:	53                   	push   %rbx
  80138d:	48 83 ec 08          	sub    $0x8,%rsp
  801391:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801394:	be 00 00 00 00       	mov    $0x0,%esi
  801399:	b8 0c 00 00 00       	mov    $0xc,%eax
  80139e:	48 89 f1             	mov    %rsi,%rcx
  8013a1:	48 89 f3             	mov    %rsi,%rbx
  8013a4:	48 89 f7             	mov    %rsi,%rdi
  8013a7:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013a9:	48 85 c0             	test   %rax,%rax
  8013ac:	7f 07                	jg     8013b5 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8013ae:	48 83 c4 08          	add    $0x8,%rsp
  8013b2:	5b                   	pop    %rbx
  8013b3:	5d                   	pop    %rbp
  8013b4:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013b5:	49 89 c0             	mov    %rax,%r8
  8013b8:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8013bd:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  8013c4:	00 00 00 
  8013c7:	be 22 00 00 00       	mov    $0x22,%esi
  8013cc:	48 bf 5f 20 80 00 00 	movabs $0x80205f,%rdi
  8013d3:	00 00 00 
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013db:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  8013e2:	00 00 00 
  8013e5:	41 ff d1             	callq  *%r9

00000000008013e8 <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  8013e8:	55                   	push   %rbp
  8013e9:	48 89 e5             	mov    %rsp,%rbp
  8013ec:	53                   	push   %rbx
  8013ed:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  8013f1:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  8013f4:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  8013f8:	41 f6 c0 02          	test   $0x2,%r8b
  8013fc:	0f 84 b2 00 00 00    	je     8014b4 <pgfault+0xcc>
  801402:	48 89 da             	mov    %rbx,%rdx
  801405:	48 c1 ea 0c          	shr    $0xc,%rdx
  801409:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801410:	01 00 00 
  801413:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801417:	f6 c4 08             	test   $0x8,%ah
  80141a:	0f 84 94 00 00 00    	je     8014b4 <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  801420:	ba 02 00 00 00       	mov    $0x2,%edx
  801425:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  80142a:	bf 00 00 00 00       	mov    $0x0,%edi
  80142f:	48 b8 7b 11 80 00 00 	movabs $0x80117b,%rax
  801436:	00 00 00 
  801439:	ff d0                	callq  *%rax
  80143b:	85 c0                	test   %eax,%eax
  80143d:	0f 88 9f 00 00 00    	js     8014e2 <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801443:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  80144a:	ba 00 10 00 00       	mov    $0x1000,%edx
  80144f:	48 89 de             	mov    %rbx,%rsi
  801452:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  801457:	48 b8 27 0e 80 00 00 	movabs $0x800e27,%rax
  80145e:	00 00 00 
  801461:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  801463:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  801469:	48 89 d9             	mov    %rbx,%rcx
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801476:	bf 00 00 00 00       	mov    $0x0,%edi
  80147b:	48 b8 de 11 80 00 00 	movabs $0x8011de,%rax
  801482:	00 00 00 
  801485:	ff d0                	callq  *%rax
  801487:	85 c0                	test   %eax,%eax
  801489:	0f 88 80 00 00 00    	js     80150f <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  80148f:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801494:	bf 00 00 00 00       	mov    $0x0,%edi
  801499:	48 b8 45 12 80 00 00 	movabs $0x801245,%rax
  8014a0:	00 00 00 
  8014a3:	ff d0                	callq  *%rax
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	0f 88 8f 00 00 00    	js     80153c <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  8014ad:	48 83 c4 08          	add    $0x8,%rsp
  8014b1:	5b                   	pop    %rbx
  8014b2:	5d                   	pop    %rbp
  8014b3:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  8014b4:	48 89 d9             	mov    %rbx,%rcx
  8014b7:	48 ba 70 20 80 00 00 	movabs $0x802070,%rdx
  8014be:	00 00 00 
  8014c1:	be 21 00 00 00       	mov    $0x21,%esi
  8014c6:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  8014cd:	00 00 00 
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d5:	49 b9 2c 1a 80 00 00 	movabs $0x801a2c,%r9
  8014dc:	00 00 00 
  8014df:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  8014e2:	89 c1                	mov    %eax,%ecx
  8014e4:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  8014eb:	00 00 00 
  8014ee:	be 2f 00 00 00       	mov    $0x2f,%esi
  8014f3:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  8014fa:	00 00 00 
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801502:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  801509:	00 00 00 
  80150c:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  80150f:	89 c1                	mov    %eax,%ecx
  801511:	48 ba c8 20 80 00 00 	movabs $0x8020c8,%rdx
  801518:	00 00 00 
  80151b:	be 39 00 00 00       	mov    $0x39,%esi
  801520:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  801527:	00 00 00 
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
  80152f:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  801536:	00 00 00 
  801539:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  80153c:	89 c1                	mov    %eax,%ecx
  80153e:	48 ba f0 20 80 00 00 	movabs $0x8020f0,%rdx
  801545:	00 00 00 
  801548:	be 3d 00 00 00       	mov    $0x3d,%esi
  80154d:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  801554:	00 00 00 
  801557:	b8 00 00 00 00       	mov    $0x0,%eax
  80155c:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  801563:	00 00 00 
  801566:	41 ff d0             	callq  *%r8

0000000000801569 <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  801569:	55                   	push   %rbp
  80156a:	48 89 e5             	mov    %rsp,%rbp
  80156d:	41 57                	push   %r15
  80156f:	41 56                	push   %r14
  801571:	41 55                	push   %r13
  801573:	41 54                	push   %r12
  801575:	53                   	push   %rbx
  801576:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  80157a:	48 bf e8 13 80 00 00 	movabs $0x8013e8,%rdi
  801581:	00 00 00 
  801584:	48 b8 1c 1b 80 00 00 	movabs $0x801b1c,%rax
  80158b:	00 00 00 
  80158e:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  801590:	b8 07 00 00 00       	mov    $0x7,%eax
  801595:	cd 30                	int    $0x30
  801597:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  80159a:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 38                	js     8015d9 <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  8015a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a6:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8015aa:	74 5a                	je     801606 <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8015ac:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  8015b3:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8015b6:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8015bd:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8015c0:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  8015c7:	01 00 00 
  8015ca:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  8015d1:	01 00 00 
  8015d4:	e9 2c 01 00 00       	jmpq   801705 <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  8015d9:	89 c1                	mov    %eax,%ecx
  8015db:	48 ba 97 21 80 00 00 	movabs $0x802197,%rdx
  8015e2:	00 00 00 
  8015e5:	be 82 00 00 00       	mov    $0x82,%esi
  8015ea:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  8015f1:	00 00 00 
  8015f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f9:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  801600:	00 00 00 
  801603:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  801606:	48 b8 3b 11 80 00 00 	movabs $0x80113b,%rax
  80160d:	00 00 00 
  801610:	ff d0                	callq  *%rax
  801612:	25 ff 03 00 00       	and    $0x3ff,%eax
  801617:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80161b:	48 c1 e0 05          	shl    $0x5,%rax
  80161f:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  801626:	00 00 00 
  801629:	48 01 d0             	add    %rdx,%rax
  80162c:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  801633:	00 00 00 
		return 0;
  801636:	e9 9d 01 00 00       	jmpq   8017d8 <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  80163b:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801642:	01 00 00 
  801645:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801649:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  80164d:	48 b8 3b 11 80 00 00 	movabs $0x80113b,%rax
  801654:	00 00 00 
  801657:	ff d0                	callq  *%rax
  801659:	89 c7                	mov    %eax,%edi
  80165b:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  80165e:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  801662:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801668:	74 57                	je     8016c1 <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  80166a:	81 e2 05 06 00 00    	and    $0x605,%edx
  801670:	48 89 d0             	mov    %rdx,%rax
  801673:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801676:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80167a:	48 c1 e6 0c          	shl    $0xc,%rsi
  80167e:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  801682:	41 89 c0             	mov    %eax,%r8d
  801685:	48 89 f1             	mov    %rsi,%rcx
  801688:	8b 55 c0             	mov    -0x40(%rbp),%edx
  80168b:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  80168f:	48 b8 de 11 80 00 00 	movabs $0x8011de,%rax
  801696:	00 00 00 
  801699:	ff d0                	callq  *%rax
    if (r < 0) {
  80169b:	85 c0                	test   %eax,%eax
  80169d:	0f 88 ce 01 00 00    	js     801871 <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  8016a3:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8016a7:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8016ab:	48 89 f1             	mov    %rsi,%rcx
  8016ae:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8016b1:	89 fa                	mov    %edi,%edx
  8016b3:	48 b8 de 11 80 00 00 	movabs $0x8011de,%rax
  8016ba:	00 00 00 
  8016bd:	ff d0                	callq  *%rax
  8016bf:	eb 28                	jmp    8016e9 <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8016c1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8016c5:	48 c1 e6 0c          	shl    $0xc,%rsi
  8016c9:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8016cd:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  8016d4:	48 89 f1             	mov    %rsi,%rcx
  8016d7:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8016da:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8016dd:	48 b8 de 11 80 00 00 	movabs $0x8011de,%rax
  8016e4:	00 00 00 
  8016e7:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	0f 89 80 00 00 00    	jns    801771 <fork+0x208>
  8016f1:	89 45 c0             	mov    %eax,-0x40(%rbp)
  8016f4:	e9 df 00 00 00       	jmpq   8017d8 <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8016f9:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801700:	4c 39 eb             	cmp    %r13,%rbx
  801703:	74 75                	je     80177a <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801705:	48 89 d8             	mov    %rbx,%rax
  801708:	48 c1 e8 27          	shr    $0x27,%rax
  80170c:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  801710:	a8 01                	test   $0x1,%al
  801712:	74 e5                	je     8016f9 <fork+0x190>
  801714:	48 89 d8             	mov    %rbx,%rax
  801717:	48 c1 e8 1e          	shr    $0x1e,%rax
  80171b:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  80171f:	a8 01                	test   $0x1,%al
  801721:	74 d6                	je     8016f9 <fork+0x190>
  801723:	48 89 d8             	mov    %rbx,%rax
  801726:	48 c1 e8 15          	shr    $0x15,%rax
  80172a:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  80172e:	a8 01                	test   $0x1,%al
  801730:	74 c7                	je     8016f9 <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  801732:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  801739:	00 00 00 
  80173c:	48 39 c3             	cmp    %rax,%rbx
  80173f:	77 b8                	ja     8016f9 <fork+0x190>
  801741:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  801748:	48 39 c3             	cmp    %rax,%rbx
  80174b:	74 ac                	je     8016f9 <fork+0x190>
  80174d:	48 89 d8             	mov    %rbx,%rax
  801750:	48 c1 e8 0c          	shr    $0xc,%rax
  801754:	48 89 c1             	mov    %rax,%rcx
  801757:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  80175b:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801762:	01 00 00 
  801765:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801769:	a8 01                	test   $0x1,%al
  80176b:	0f 85 ca fe ff ff    	jne    80163b <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801771:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801778:	eb 8b                	jmp    801705 <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  80177a:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  801781:	00 00 00 
  801784:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  80178b:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  80178e:	48 b8 05 13 80 00 00 	movabs $0x801305,%rax
  801795:	00 00 00 
  801798:	ff d0                	callq  *%rax
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 4c                	js     8017ea <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  80179e:	ba 02 00 00 00       	mov    $0x2,%edx
  8017a3:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8017aa:	00 00 00 
  8017ad:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8017b0:	48 b8 7b 11 80 00 00 	movabs $0x80117b,%rax
  8017b7:	00 00 00 
  8017ba:	ff d0                	callq  *%rax
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 57                	js     801817 <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  8017c0:	be 02 00 00 00       	mov    $0x2,%esi
  8017c5:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8017c8:	48 b8 a5 12 80 00 00 	movabs $0x8012a5,%rax
  8017cf:	00 00 00 
  8017d2:	ff d0                	callq  *%rax
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 6c                	js     801844 <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  8017d8:	8b 45 c0             	mov    -0x40(%rbp),%eax
  8017db:	48 83 c4 28          	add    $0x28,%rsp
  8017df:	5b                   	pop    %rbx
  8017e0:	41 5c                	pop    %r12
  8017e2:	41 5d                	pop    %r13
  8017e4:	41 5e                	pop    %r14
  8017e6:	41 5f                	pop    %r15
  8017e8:	5d                   	pop    %rbp
  8017e9:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  8017ea:	89 c1                	mov    %eax,%ecx
  8017ec:	48 ba 18 21 80 00 00 	movabs $0x802118,%rdx
  8017f3:	00 00 00 
  8017f6:	be a7 00 00 00       	mov    $0xa7,%esi
  8017fb:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  801802:	00 00 00 
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
  80180a:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  801811:	00 00 00 
  801814:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  801817:	89 c1                	mov    %eax,%ecx
  801819:	48 ba 48 21 80 00 00 	movabs $0x802148,%rdx
  801820:	00 00 00 
  801823:	be aa 00 00 00       	mov    $0xaa,%esi
  801828:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  80182f:	00 00 00 
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
  801837:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  80183e:	00 00 00 
  801841:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  801844:	89 c1                	mov    %eax,%ecx
  801846:	48 ba 68 21 80 00 00 	movabs $0x802168,%rdx
  80184d:	00 00 00 
  801850:	be bd 00 00 00       	mov    $0xbd,%esi
  801855:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  80185c:	00 00 00 
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  80186b:	00 00 00 
  80186e:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801871:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801874:	e9 5f ff ff ff       	jmpq   8017d8 <fork+0x26f>

0000000000801879 <sfork>:

// Challenge!
int
sfork(void) {
  801879:	55                   	push   %rbp
  80187a:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  80187d:	48 ba a7 21 80 00 00 	movabs $0x8021a7,%rdx
  801884:	00 00 00 
  801887:	be c9 00 00 00       	mov    $0xc9,%esi
  80188c:	48 bf 8c 21 80 00 00 	movabs $0x80218c,%rdi
  801893:	00 00 00 
  801896:	b8 00 00 00 00       	mov    $0x0,%eax
  80189b:	48 b9 2c 1a 80 00 00 	movabs $0x801a2c,%rcx
  8018a2:	00 00 00 
  8018a5:	ff d1                	callq  *%rcx

00000000008018a7 <ipc_recv>:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store) {
  8018a7:	55                   	push   %rbp
  8018a8:	48 89 e5             	mov    %rsp,%rbp
  8018ab:	41 54                	push   %r12
  8018ad:	53                   	push   %rbx
  8018ae:	49 89 fc             	mov    %rdi,%r12
  8018b1:	48 89 d3             	mov    %rdx,%rbx
  // LAB 9 code
  int r;

	if ((r = sys_ipc_recv(pg)) < 0) {
  8018b4:	48 89 f7             	mov    %rsi,%rdi
  8018b7:	48 b8 88 13 80 00 00 	movabs $0x801388,%rax
  8018be:	00 00 00 
  8018c1:	ff d0                	callq  *%rax
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 45                	js     80190c <ipc_recv+0x65>
		if (perm_store) {
			*perm_store = 0;
		}
		return r;
	} else {
		if (from_env_store) {
  8018c7:	4d 85 e4             	test   %r12,%r12
  8018ca:	74 14                	je     8018e0 <ipc_recv+0x39>
			*from_env_store = thisenv->env_ipc_from;
  8018cc:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  8018d3:	00 00 00 
  8018d6:	8b 80 14 01 00 00    	mov    0x114(%rax),%eax
  8018dc:	41 89 04 24          	mov    %eax,(%r12)
		}
		if (perm_store) {
  8018e0:	48 85 db             	test   %rbx,%rbx
  8018e3:	74 12                	je     8018f7 <ipc_recv+0x50>
			*perm_store = thisenv->env_ipc_perm;
  8018e5:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  8018ec:	00 00 00 
  8018ef:	8b 80 18 01 00 00    	mov    0x118(%rax),%eax
  8018f5:	89 03                	mov    %eax,(%rbx)
		}
#ifdef SANITIZE_USER_SHADOW_BASE
	  platform_asan_unpoison(pg, PGSIZE);
#endif
		return thisenv->env_ipc_value;
  8018f7:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  8018fe:	00 00 00 
  801901:	8b 80 10 01 00 00    	mov    0x110(%rax),%eax
	}
  // LAB 9 code end

  // return -1;
}
  801907:	5b                   	pop    %rbx
  801908:	41 5c                	pop    %r12
  80190a:	5d                   	pop    %rbp
  80190b:	c3                   	retq   
		if (from_env_store) {
  80190c:	4d 85 e4             	test   %r12,%r12
  80190f:	74 08                	je     801919 <ipc_recv+0x72>
			*from_env_store = 0;
  801911:	41 c7 04 24 00 00 00 	movl   $0x0,(%r12)
  801918:	00 
		if (perm_store) {
  801919:	48 85 db             	test   %rbx,%rbx
  80191c:	74 e9                	je     801907 <ipc_recv+0x60>
			*perm_store = 0;
  80191e:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  801924:	eb e1                	jmp    801907 <ipc_recv+0x60>

0000000000801926 <ipc_send>:
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm) {
  801926:	55                   	push   %rbp
  801927:	48 89 e5             	mov    %rsp,%rbp
  80192a:	41 57                	push   %r15
  80192c:	41 56                	push   %r14
  80192e:	41 55                	push   %r13
  801930:	41 54                	push   %r12
  801932:	53                   	push   %rbx
  801933:	48 83 ec 08          	sub    $0x8,%rsp
  801937:	41 89 ff             	mov    %edi,%r15d
  80193a:	41 89 f6             	mov    %esi,%r14d
  80193d:	48 89 d3             	mov    %rdx,%rbx
  801940:	41 89 cd             	mov    %ecx,%r13d
  // LAB 9 code
  int r;

  if (pg == NULL) {
    pg = (void *) UTOP;
  801943:	48 85 d2             	test   %rdx,%rdx
  801946:	48 b8 00 00 00 00 80 	movabs $0x8000000000,%rax
  80194d:	00 00 00 
  801950:	48 0f 44 d8          	cmove  %rax,%rbx
  }
  while ((r = sys_ipc_try_send(to_env, val, pg, perm))) {
  801954:	49 bc 65 13 80 00 00 	movabs $0x801365,%r12
  80195b:	00 00 00 
  80195e:	44 89 f6             	mov    %r14d,%esi
  801961:	44 89 e9             	mov    %r13d,%ecx
  801964:	48 89 da             	mov    %rbx,%rdx
  801967:	44 89 ff             	mov    %r15d,%edi
  80196a:	41 ff d4             	callq  *%r12
  80196d:	85 c0                	test   %eax,%eax
  80196f:	74 34                	je     8019a5 <ipc_send+0x7f>
	  if (r < 0 && r != -E_IPC_NOT_RECV) {
  801971:	79 eb                	jns    80195e <ipc_send+0x38>
  801973:	83 f8 f6             	cmp    $0xfffffff6,%eax
  801976:	74 e6                	je     80195e <ipc_send+0x38>
		  panic("ipc_send error: sys_ipc_try_send: %i\n", r);
  801978:	89 c1                	mov    %eax,%ecx
  80197a:	48 ba c0 21 80 00 00 	movabs $0x8021c0,%rdx
  801981:	00 00 00 
  801984:	be 46 00 00 00       	mov    $0x46,%esi
  801989:	48 bf e6 21 80 00 00 	movabs $0x8021e6,%rdi
  801990:	00 00 00 
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  80199f:	00 00 00 
  8019a2:	41 ff d0             	callq  *%r8
	  }
	  //sys_yield();
  }
  sys_yield();
  8019a5:	48 b8 5b 11 80 00 00 	movabs $0x80115b,%rax
  8019ac:	00 00 00 
  8019af:	ff d0                	callq  *%rax
  // LAB 9 code end
}
  8019b1:	48 83 c4 08          	add    $0x8,%rsp
  8019b5:	5b                   	pop    %rbx
  8019b6:	41 5c                	pop    %r12
  8019b8:	41 5d                	pop    %r13
  8019ba:	41 5e                	pop    %r14
  8019bc:	41 5f                	pop    %r15
  8019be:	5d                   	pop    %rbp
  8019bf:	c3                   	retq   

00000000008019c0 <ipc_find_env>:
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type) {
  int i;
  for (i = 0; i < NENV; i++)
    if (envs[i].env_type == type)
  8019c0:	a1 d0 e0 22 3c 80 00 	movabs 0x803c22e0d0,%eax
  8019c7:	00 00 
  8019c9:	39 c7                	cmp    %eax,%edi
  8019cb:	74 38                	je     801a05 <ipc_find_env+0x45>
  for (i = 0; i < NENV; i++)
  8019cd:	ba 01 00 00 00       	mov    $0x1,%edx
    if (envs[i].env_type == type)
  8019d2:	48 b9 00 e0 22 3c 80 	movabs $0x803c22e000,%rcx
  8019d9:	00 00 00 
  8019dc:	48 63 c2             	movslq %edx,%rax
  8019df:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8019e3:	48 c1 e0 05          	shl    $0x5,%rax
  8019e7:	48 01 c8             	add    %rcx,%rax
  8019ea:	8b 80 d0 00 00 00    	mov    0xd0(%rax),%eax
  8019f0:	39 f8                	cmp    %edi,%eax
  8019f2:	74 16                	je     801a0a <ipc_find_env+0x4a>
  for (i = 0; i < NENV; i++)
  8019f4:	83 c2 01             	add    $0x1,%edx
  8019f7:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8019fd:	75 dd                	jne    8019dc <ipc_find_env+0x1c>
      return envs[i].env_id;
  return 0;
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a04:	c3                   	retq   
  for (i = 0; i < NENV; i++)
  801a05:	ba 00 00 00 00       	mov    $0x0,%edx
      return envs[i].env_id;
  801a0a:	48 63 d2             	movslq %edx,%rdx
  801a0d:	48 8d 04 d2          	lea    (%rdx,%rdx,8),%rax
  801a11:	48 c1 e0 05          	shl    $0x5,%rax
  801a15:	48 89 c2             	mov    %rax,%rdx
  801a18:	48 b8 00 e0 22 3c 80 	movabs $0x803c22e000,%rax
  801a1f:	00 00 00 
  801a22:	48 01 d0             	add    %rdx,%rax
  801a25:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  801a2b:	c3                   	retq   

0000000000801a2c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  801a2c:	55                   	push   %rbp
  801a2d:	48 89 e5             	mov    %rsp,%rbp
  801a30:	41 56                	push   %r14
  801a32:	41 55                	push   %r13
  801a34:	41 54                	push   %r12
  801a36:	53                   	push   %rbx
  801a37:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801a3e:	49 89 fd             	mov    %rdi,%r13
  801a41:	41 89 f6             	mov    %esi,%r14d
  801a44:	49 89 d4             	mov    %rdx,%r12
  801a47:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801a4e:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801a55:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  801a5c:	84 c0                	test   %al,%al
  801a5e:	74 26                	je     801a86 <_panic+0x5a>
  801a60:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  801a67:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801a6e:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801a72:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  801a76:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  801a7a:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801a7e:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801a82:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801a86:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  801a8d:	00 00 00 
  801a90:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801a97:	00 00 00 
  801a9a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801a9e:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801aa5:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  801aac:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab3:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  801aba:	00 00 00 
  801abd:	48 8b 18             	mov    (%rax),%rbx
  801ac0:	48 b8 3b 11 80 00 00 	movabs $0x80113b,%rax
  801ac7:	00 00 00 
  801aca:	ff d0                	callq  *%rax
  801acc:	45 89 f0             	mov    %r14d,%r8d
  801acf:	4c 89 e9             	mov    %r13,%rcx
  801ad2:	48 89 da             	mov    %rbx,%rdx
  801ad5:	89 c6                	mov    %eax,%esi
  801ad7:	48 bf f0 21 80 00 00 	movabs $0x8021f0,%rdi
  801ade:	00 00 00 
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae6:	48 bb a9 02 80 00 00 	movabs $0x8002a9,%rbx
  801aed:	00 00 00 
  801af0:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801af2:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  801af9:	4c 89 e7             	mov    %r12,%rdi
  801afc:	48 b8 41 02 80 00 00 	movabs $0x800241,%rax
  801b03:	00 00 00 
  801b06:	ff d0                	callq  *%rax
  cprintf("\n");
  801b08:	48 bf a5 21 80 00 00 	movabs $0x8021a5,%rdi
  801b0f:	00 00 00 
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
  801b17:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  801b19:	cc                   	int3   
  while (1)
  801b1a:	eb fd                	jmp    801b19 <_panic+0xed>

0000000000801b1c <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801b1c:	55                   	push   %rbp
  801b1d:	48 89 e5             	mov    %rsp,%rbp
  801b20:	41 54                	push   %r12
  801b22:	53                   	push   %rbx
  801b23:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  801b26:	48 b8 3b 11 80 00 00 	movabs $0x80113b,%rax
  801b2d:	00 00 00 
  801b30:	ff d0                	callq  *%rax
  801b32:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  801b34:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  801b3b:	00 00 00 
  801b3e:	48 83 38 00          	cmpq   $0x0,(%rax)
  801b42:	74 2e                	je     801b72 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801b44:	4c 89 e0             	mov    %r12,%rax
  801b47:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  801b4e:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801b51:	48 be be 1b 80 00 00 	movabs $0x801bbe,%rsi
  801b58:	00 00 00 
  801b5b:	89 df                	mov    %ebx,%edi
  801b5d:	48 b8 05 13 80 00 00 	movabs $0x801305,%rax
  801b64:	00 00 00 
  801b67:	ff d0                	callq  *%rax
  if (error < 0)
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 24                	js     801b91 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801b6d:	5b                   	pop    %rbx
  801b6e:	41 5c                	pop    %r12
  801b70:	5d                   	pop    %rbp
  801b71:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  801b72:	ba 02 00 00 00       	mov    $0x2,%edx
  801b77:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801b7e:	00 00 00 
  801b81:	89 df                	mov    %ebx,%edi
  801b83:	48 b8 7b 11 80 00 00 	movabs $0x80117b,%rax
  801b8a:	00 00 00 
  801b8d:	ff d0                	callq  *%rax
  801b8f:	eb b3                	jmp    801b44 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801b91:	89 c1                	mov    %eax,%ecx
  801b93:	48 ba 18 22 80 00 00 	movabs $0x802218,%rdx
  801b9a:	00 00 00 
  801b9d:	be 2c 00 00 00       	mov    $0x2c,%esi
  801ba2:	48 bf 30 22 80 00 00 	movabs $0x802230,%rdi
  801ba9:	00 00 00 
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	49 b8 2c 1a 80 00 00 	movabs $0x801a2c,%r8
  801bb8:	00 00 00 
  801bbb:	41 ff d0             	callq  *%r8

0000000000801bbe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801bbe:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801bc1:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  801bc8:	00 00 00 
	call *%rax
  801bcb:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801bcd:	41 5f                	pop    %r15
	popq %r15
  801bcf:	41 5f                	pop    %r15
	popq %r15
  801bd1:	41 5f                	pop    %r15
	popq %r14
  801bd3:	41 5e                	pop    %r14
	popq %r13
  801bd5:	41 5d                	pop    %r13
	popq %r12
  801bd7:	41 5c                	pop    %r12
	popq %r11
  801bd9:	41 5b                	pop    %r11
	popq %r10
  801bdb:	41 5a                	pop    %r10
	popq %r9
  801bdd:	41 59                	pop    %r9
	popq %r8
  801bdf:	41 58                	pop    %r8
	popq %rsi
  801be1:	5e                   	pop    %rsi
	popq %rdi
  801be2:	5f                   	pop    %rdi
	popq %rbp
  801be3:	5d                   	pop    %rbp
	popq %rdx
  801be4:	5a                   	pop    %rdx
	popq %rcx
  801be5:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801be6:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801beb:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801bf0:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801bf4:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801bf7:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801bfc:	5b                   	pop    %rbx
	popq %rax
  801bfd:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801bfe:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801c02:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801c03:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801c08:	c3                   	retq   
  801c09:	0f 1f 00             	nopl   (%rax)
