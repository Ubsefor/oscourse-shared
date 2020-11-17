
obj/user/testbss:     file format elf64-x86-64


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
  800023:	e8 67 01 00 00       	callq  80018f <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#define ARRAYSIZE (1024 * 1024)

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  int i;

  cprintf("Making sure bss works right...\n");
  80002e:	48 bf c0 12 80 00 00 	movabs $0x8012c0,%rdi
  800035:	00 00 00 
  800038:	b8 00 00 00 00       	mov    $0x0,%eax
  80003d:	48 ba 02 04 80 00 00 	movabs $0x800402,%rdx
  800044:	00 00 00 
  800047:	ff d2                	callq  *%rdx
  for (i = 0; i < ARRAYSIZE; i++)
    if (bigarray[i] != 0)
  800049:	48 b8 20 20 80 00 00 	movabs $0x802020,%rax
  800050:	00 00 00 
  800053:	83 38 00             	cmpl   $0x0,(%rax)
  800056:	0f 85 d3 00 00 00    	jne    80012f <umain+0x105>
  80005c:	b8 01 00 00 00       	mov    $0x1,%eax
  800061:	48 ba 20 20 80 00 00 	movabs $0x802020,%rdx
  800068:	00 00 00 
  80006b:	89 c1                	mov    %eax,%ecx
  80006d:	83 3c 82 00          	cmpl   $0x0,(%rdx,%rax,4)
  800071:	0f 85 bd 00 00 00    	jne    800134 <umain+0x10a>
  for (i = 0; i < ARRAYSIZE; i++)
  800077:	48 83 c0 01          	add    $0x1,%rax
  80007b:	48 3d 00 00 10 00    	cmp    $0x100000,%rax
  800081:	75 e8                	jne    80006b <umain+0x41>
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
      panic("bigarray[%d] isn't cleared!\n", i);
  for (i = 0; i < ARRAYSIZE; i++)
    bigarray[i] = i;
  800088:	48 ba 20 20 80 00 00 	movabs $0x802020,%rdx
  80008f:	00 00 00 
  800092:	89 04 82             	mov    %eax,(%rdx,%rax,4)
  for (i = 0; i < ARRAYSIZE; i++)
  800095:	48 83 c0 01          	add    $0x1,%rax
  800099:	48 3d 00 00 10 00    	cmp    $0x100000,%rax
  80009f:	75 f1                	jne    800092 <umain+0x68>
  for (i = 0; i < ARRAYSIZE; i++)
    if (bigarray[i] != i)
  8000a1:	48 b8 20 20 80 00 00 	movabs $0x802020,%rax
  8000a8:	00 00 00 
  8000ab:	83 38 00             	cmpl   $0x0,(%rax)
  8000ae:	0f 85 ab 00 00 00    	jne    80015f <umain+0x135>
  8000b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b9:	48 ba 20 20 80 00 00 	movabs $0x802020,%rdx
  8000c0:	00 00 00 
  8000c3:	89 c1                	mov    %eax,%ecx
  8000c5:	39 04 82             	cmp    %eax,(%rdx,%rax,4)
  8000c8:	0f 85 96 00 00 00    	jne    800164 <umain+0x13a>
  for (i = 0; i < ARRAYSIZE; i++)
  8000ce:	48 83 c0 01          	add    $0x1,%rax
  8000d2:	48 3d 00 00 10 00    	cmp    $0x100000,%rax
  8000d8:	75 e9                	jne    8000c3 <umain+0x99>
      panic("bigarray[%d] didn't hold its value!\n", i);

  cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000da:	48 bf 08 13 80 00 00 	movabs $0x801308,%rdi
  8000e1:	00 00 00 
  8000e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e9:	48 ba 02 04 80 00 00 	movabs $0x800402,%rdx
  8000f0:	00 00 00 
  8000f3:	ff d2                	callq  *%rdx
  // Accessing via subscript operator ([]) will result in -Warray-bounds warning.
  *((volatile uint32_t *)bigarray + ARRAYSIZE + 0x800000) = 0;
  8000f5:	48 b8 20 20 c0 02 00 	movabs $0x2c02020,%rax
  8000fc:	00 00 00 
  8000ff:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  panic("SHOULD HAVE TRAPPED!!!");
  800105:	48 ba 67 13 80 00 00 	movabs $0x801367,%rdx
  80010c:	00 00 00 
  80010f:	be 1a 00 00 00       	mov    $0x1a,%esi
  800114:	48 bf 58 13 80 00 00 	movabs $0x801358,%rdi
  80011b:	00 00 00 
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	48 b9 60 02 80 00 00 	movabs $0x800260,%rcx
  80012a:	00 00 00 
  80012d:	ff d1                	callq  *%rcx
  for (i = 0; i < ARRAYSIZE; i++)
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
      panic("bigarray[%d] isn't cleared!\n", i);
  800134:	48 ba 3b 13 80 00 00 	movabs $0x80133b,%rdx
  80013b:	00 00 00 
  80013e:	be 10 00 00 00       	mov    $0x10,%esi
  800143:	48 bf 58 13 80 00 00 	movabs $0x801358,%rdi
  80014a:	00 00 00 
  80014d:	b8 00 00 00 00       	mov    $0x0,%eax
  800152:	49 b8 60 02 80 00 00 	movabs $0x800260,%r8
  800159:	00 00 00 
  80015c:	41 ff d0             	callq  *%r8
  for (i = 0; i < ARRAYSIZE; i++)
  80015f:	b9 00 00 00 00       	mov    $0x0,%ecx
      panic("bigarray[%d] didn't hold its value!\n", i);
  800164:	48 ba e0 12 80 00 00 	movabs $0x8012e0,%rdx
  80016b:	00 00 00 
  80016e:	be 15 00 00 00       	mov    $0x15,%esi
  800173:	48 bf 58 13 80 00 00 	movabs $0x801358,%rdi
  80017a:	00 00 00 
  80017d:	b8 00 00 00 00       	mov    $0x0,%eax
  800182:	49 b8 60 02 80 00 00 	movabs $0x800260,%r8
  800189:	00 00 00 
  80018c:	41 ff d0             	callq  *%r8

000000000080018f <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80018f:	55                   	push   %rbp
  800190:	48 89 e5             	mov    %rsp,%rbp
  800193:	41 56                	push   %r14
  800195:	41 55                	push   %r13
  800197:	41 54                	push   %r12
  800199:	53                   	push   %rbx
  80019a:	41 89 fd             	mov    %edi,%r13d
  80019d:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  8001a0:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  8001a7:	00 00 00 
  8001aa:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  8001b1:	00 00 00 
  8001b4:	48 39 c2             	cmp    %rax,%rdx
  8001b7:	73 23                	jae    8001dc <libmain+0x4d>
  8001b9:	48 89 d3             	mov    %rdx,%rbx
  8001bc:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  8001c0:	48 29 d0             	sub    %rdx,%rax
  8001c3:	48 c1 e8 03          	shr    $0x3,%rax
  8001c7:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8001cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d1:	ff 13                	callq  *(%rbx)
    ctor++;
  8001d3:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8001d7:	4c 39 e3             	cmp    %r12,%rbx
  8001da:	75 f0                	jne    8001cc <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  8001dc:	48 b8 94 12 80 00 00 	movabs $0x801294,%rax
  8001e3:	00 00 00 
  8001e6:	ff d0                	callq  *%rax
  8001e8:	83 e0 1f             	and    $0x1f,%eax
  8001eb:	48 89 c2             	mov    %rax,%rdx
  8001ee:	48 c1 e2 05          	shl    $0x5,%rdx
  8001f2:	48 29 c2             	sub    %rax,%rdx
  8001f5:	48 89 d0             	mov    %rdx,%rax
  8001f8:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8001ff:	00 00 00 
  800202:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  800206:	48 a3 20 20 c0 00 00 	movabs %rax,0xc02020
  80020d:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800210:	45 85 ed             	test   %r13d,%r13d
  800213:	7e 0d                	jle    800222 <libmain+0x93>
    binaryname = argv[0];
  800215:	49 8b 06             	mov    (%r14),%rax
  800218:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  80021f:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800222:	4c 89 f6             	mov    %r14,%rsi
  800225:	44 89 ef             	mov    %r13d,%edi
  800228:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  80022f:	00 00 00 
  800232:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800234:	48 b8 49 02 80 00 00 	movabs $0x800249,%rax
  80023b:	00 00 00 
  80023e:	ff d0                	callq  *%rax
#endif
}
  800240:	5b                   	pop    %rbx
  800241:	41 5c                	pop    %r12
  800243:	41 5d                	pop    %r13
  800245:	41 5e                	pop    %r14
  800247:	5d                   	pop    %rbp
  800248:	c3                   	retq   

0000000000800249 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800249:	55                   	push   %rbp
  80024a:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80024d:	bf 00 00 00 00       	mov    $0x0,%edi
  800252:	48 b8 34 12 80 00 00 	movabs $0x801234,%rax
  800259:	00 00 00 
  80025c:	ff d0                	callq  *%rax
}
  80025e:	5d                   	pop    %rbp
  80025f:	c3                   	retq   

0000000000800260 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800260:	55                   	push   %rbp
  800261:	48 89 e5             	mov    %rsp,%rbp
  800264:	41 56                	push   %r14
  800266:	41 55                	push   %r13
  800268:	41 54                	push   %r12
  80026a:	53                   	push   %rbx
  80026b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800272:	49 89 fd             	mov    %rdi,%r13
  800275:	41 89 f6             	mov    %esi,%r14d
  800278:	49 89 d4             	mov    %rdx,%r12
  80027b:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800282:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800289:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800290:	84 c0                	test   %al,%al
  800292:	74 26                	je     8002ba <_panic+0x5a>
  800294:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80029b:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8002a2:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8002a6:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8002aa:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8002ae:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8002b2:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8002b6:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8002ba:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8002c1:	00 00 00 
  8002c4:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8002cb:	00 00 00 
  8002ce:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002d2:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8002d9:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8002e0:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8002e7:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8002ee:	00 00 00 
  8002f1:	48 8b 18             	mov    (%rax),%rbx
  8002f4:	48 b8 94 12 80 00 00 	movabs $0x801294,%rax
  8002fb:	00 00 00 
  8002fe:	ff d0                	callq  *%rax
  800300:	45 89 f0             	mov    %r14d,%r8d
  800303:	4c 89 e9             	mov    %r13,%rcx
  800306:	48 89 da             	mov    %rbx,%rdx
  800309:	89 c6                	mov    %eax,%esi
  80030b:	48 bf 88 13 80 00 00 	movabs $0x801388,%rdi
  800312:	00 00 00 
  800315:	b8 00 00 00 00       	mov    $0x0,%eax
  80031a:	48 bb 02 04 80 00 00 	movabs $0x800402,%rbx
  800321:	00 00 00 
  800324:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800326:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80032d:	4c 89 e7             	mov    %r12,%rdi
  800330:	48 b8 9a 03 80 00 00 	movabs $0x80039a,%rax
  800337:	00 00 00 
  80033a:	ff d0                	callq  *%rax
  cprintf("\n");
  80033c:	48 bf 56 13 80 00 00 	movabs $0x801356,%rdi
  800343:	00 00 00 
  800346:	b8 00 00 00 00       	mov    $0x0,%eax
  80034b:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80034d:	cc                   	int3   
  while (1)
  80034e:	eb fd                	jmp    80034d <_panic+0xed>

0000000000800350 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800350:	55                   	push   %rbp
  800351:	48 89 e5             	mov    %rsp,%rbp
  800354:	53                   	push   %rbx
  800355:	48 83 ec 08          	sub    $0x8,%rsp
  800359:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80035c:	8b 06                	mov    (%rsi),%eax
  80035e:	8d 50 01             	lea    0x1(%rax),%edx
  800361:	89 16                	mov    %edx,(%rsi)
  800363:	48 98                	cltq   
  800365:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80036a:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800370:	74 0b                	je     80037d <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800372:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800376:	48 83 c4 08          	add    $0x8,%rsp
  80037a:	5b                   	pop    %rbx
  80037b:	5d                   	pop    %rbp
  80037c:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80037d:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800381:	be ff 00 00 00       	mov    $0xff,%esi
  800386:	48 b8 f6 11 80 00 00 	movabs $0x8011f6,%rax
  80038d:	00 00 00 
  800390:	ff d0                	callq  *%rax
    b->idx = 0;
  800392:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800398:	eb d8                	jmp    800372 <putch+0x22>

000000000080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80039a:	55                   	push   %rbp
  80039b:	48 89 e5             	mov    %rsp,%rbp
  80039e:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8003a5:	48 89 fa             	mov    %rdi,%rdx
  8003a8:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8003ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8003b2:	00 00 00 
  b.cnt = 0;
  8003b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8003bc:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8003bf:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8003c6:	48 bf 50 03 80 00 00 	movabs $0x800350,%rdi
  8003cd:	00 00 00 
  8003d0:	48 b8 c0 05 80 00 00 	movabs $0x8005c0,%rax
  8003d7:	00 00 00 
  8003da:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8003dc:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8003e3:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8003ea:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8003ee:	48 b8 f6 11 80 00 00 	movabs $0x8011f6,%rax
  8003f5:	00 00 00 
  8003f8:	ff d0                	callq  *%rax

  return b.cnt;
}
  8003fa:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800400:	c9                   	leaveq 
  800401:	c3                   	retq   

0000000000800402 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800402:	55                   	push   %rbp
  800403:	48 89 e5             	mov    %rsp,%rbp
  800406:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80040d:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800414:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80041b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800422:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800429:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800430:	84 c0                	test   %al,%al
  800432:	74 20                	je     800454 <cprintf+0x52>
  800434:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800438:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80043c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800440:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800444:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800448:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80044c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800450:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800454:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80045b:	00 00 00 
  80045e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800465:	00 00 00 
  800468:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80046c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800473:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80047a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800481:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800488:	48 b8 9a 03 80 00 00 	movabs $0x80039a,%rax
  80048f:	00 00 00 
  800492:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800494:	c9                   	leaveq 
  800495:	c3                   	retq   

0000000000800496 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800496:	55                   	push   %rbp
  800497:	48 89 e5             	mov    %rsp,%rbp
  80049a:	41 57                	push   %r15
  80049c:	41 56                	push   %r14
  80049e:	41 55                	push   %r13
  8004a0:	41 54                	push   %r12
  8004a2:	53                   	push   %rbx
  8004a3:	48 83 ec 18          	sub    $0x18,%rsp
  8004a7:	49 89 fc             	mov    %rdi,%r12
  8004aa:	49 89 f5             	mov    %rsi,%r13
  8004ad:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8004b1:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8004b4:	41 89 cf             	mov    %ecx,%r15d
  8004b7:	49 39 d7             	cmp    %rdx,%r15
  8004ba:	76 45                	jbe    800501 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8004bc:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8004c0:	85 db                	test   %ebx,%ebx
  8004c2:	7e 0e                	jle    8004d2 <printnum+0x3c>
      putch(padc, putdat);
  8004c4:	4c 89 ee             	mov    %r13,%rsi
  8004c7:	44 89 f7             	mov    %r14d,%edi
  8004ca:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8004cd:	83 eb 01             	sub    $0x1,%ebx
  8004d0:	75 f2                	jne    8004c4 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8004d2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004db:	49 f7 f7             	div    %r15
  8004de:	48 b8 ab 13 80 00 00 	movabs $0x8013ab,%rax
  8004e5:	00 00 00 
  8004e8:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8004ec:	4c 89 ee             	mov    %r13,%rsi
  8004ef:	41 ff d4             	callq  *%r12
}
  8004f2:	48 83 c4 18          	add    $0x18,%rsp
  8004f6:	5b                   	pop    %rbx
  8004f7:	41 5c                	pop    %r12
  8004f9:	41 5d                	pop    %r13
  8004fb:	41 5e                	pop    %r14
  8004fd:	41 5f                	pop    %r15
  8004ff:	5d                   	pop    %rbp
  800500:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800501:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
  80050a:	49 f7 f7             	div    %r15
  80050d:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800511:	48 89 c2             	mov    %rax,%rdx
  800514:	48 b8 96 04 80 00 00 	movabs $0x800496,%rax
  80051b:	00 00 00 
  80051e:	ff d0                	callq  *%rax
  800520:	eb b0                	jmp    8004d2 <printnum+0x3c>

0000000000800522 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800522:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800526:	48 8b 06             	mov    (%rsi),%rax
  800529:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80052d:	73 0a                	jae    800539 <sprintputch+0x17>
    *b->buf++ = ch;
  80052f:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800533:	48 89 16             	mov    %rdx,(%rsi)
  800536:	40 88 38             	mov    %dil,(%rax)
}
  800539:	c3                   	retq   

000000000080053a <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80053a:	55                   	push   %rbp
  80053b:	48 89 e5             	mov    %rsp,%rbp
  80053e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800545:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80054c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800553:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80055a:	84 c0                	test   %al,%al
  80055c:	74 20                	je     80057e <printfmt+0x44>
  80055e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800562:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800566:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80056a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80056e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800572:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800576:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80057a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80057e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800585:	00 00 00 
  800588:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80058f:	00 00 00 
  800592:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800596:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80059d:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8005a4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8005ab:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8005b2:	48 b8 c0 05 80 00 00 	movabs $0x8005c0,%rax
  8005b9:	00 00 00 
  8005bc:	ff d0                	callq  *%rax
}
  8005be:	c9                   	leaveq 
  8005bf:	c3                   	retq   

00000000008005c0 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8005c0:	55                   	push   %rbp
  8005c1:	48 89 e5             	mov    %rsp,%rbp
  8005c4:	41 57                	push   %r15
  8005c6:	41 56                	push   %r14
  8005c8:	41 55                	push   %r13
  8005ca:	41 54                	push   %r12
  8005cc:	53                   	push   %rbx
  8005cd:	48 83 ec 48          	sub    $0x48,%rsp
  8005d1:	49 89 fd             	mov    %rdi,%r13
  8005d4:	49 89 f7             	mov    %rsi,%r15
  8005d7:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8005da:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8005de:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8005e2:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8005e6:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005ea:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8005ee:	41 0f b6 3e          	movzbl (%r14),%edi
  8005f2:	83 ff 25             	cmp    $0x25,%edi
  8005f5:	74 18                	je     80060f <vprintfmt+0x4f>
      if (ch == '\0')
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	0f 84 8c 06 00 00    	je     800c8b <vprintfmt+0x6cb>
      putch(ch, putdat);
  8005ff:	4c 89 fe             	mov    %r15,%rsi
  800602:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800605:	49 89 de             	mov    %rbx,%r14
  800608:	eb e0                	jmp    8005ea <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80060a:	49 89 de             	mov    %rbx,%r14
  80060d:	eb db                	jmp    8005ea <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80060f:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800613:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800617:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80061e:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800624:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80062d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800633:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800639:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80063e:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800643:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800647:	0f b6 13             	movzbl (%rbx),%edx
  80064a:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80064d:	3c 55                	cmp    $0x55,%al
  80064f:	0f 87 8b 05 00 00    	ja     800be0 <vprintfmt+0x620>
  800655:	0f b6 c0             	movzbl %al,%eax
  800658:	49 bb 60 14 80 00 00 	movabs $0x801460,%r11
  80065f:	00 00 00 
  800662:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800666:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800669:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80066d:	eb d4                	jmp    800643 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80066f:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800672:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800676:	eb cb                	jmp    800643 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800678:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80067b:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80067f:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800683:	8d 50 d0             	lea    -0x30(%rax),%edx
  800686:	83 fa 09             	cmp    $0x9,%edx
  800689:	77 7e                	ja     800709 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80068b:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80068f:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800693:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800698:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80069c:	8d 50 d0             	lea    -0x30(%rax),%edx
  80069f:	83 fa 09             	cmp    $0x9,%edx
  8006a2:	76 e7                	jbe    80068b <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8006a4:	4c 89 f3             	mov    %r14,%rbx
  8006a7:	eb 19                	jmp    8006c2 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8006a9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006ac:	83 f8 2f             	cmp    $0x2f,%eax
  8006af:	77 2a                	ja     8006db <vprintfmt+0x11b>
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	4c 01 d2             	add    %r10,%rdx
  8006b6:	83 c0 08             	add    $0x8,%eax
  8006b9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006bc:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8006bf:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8006c2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006c6:	0f 89 77 ff ff ff    	jns    800643 <vprintfmt+0x83>
          width = precision, precision = -1;
  8006cc:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8006d0:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8006d6:	e9 68 ff ff ff       	jmpq   800643 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8006db:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006df:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006e3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e7:	eb d3                	jmp    8006bc <vprintfmt+0xfc>
        if (width < 0)
  8006e9:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	41 0f 48 c0          	cmovs  %r8d,%eax
  8006f2:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8006f5:	4c 89 f3             	mov    %r14,%rbx
  8006f8:	e9 46 ff ff ff       	jmpq   800643 <vprintfmt+0x83>
  8006fd:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800700:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800704:	e9 3a ff ff ff       	jmpq   800643 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800709:	4c 89 f3             	mov    %r14,%rbx
  80070c:	eb b4                	jmp    8006c2 <vprintfmt+0x102>
        lflag++;
  80070e:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800711:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800714:	e9 2a ff ff ff       	jmpq   800643 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800719:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80071c:	83 f8 2f             	cmp    $0x2f,%eax
  80071f:	77 19                	ja     80073a <vprintfmt+0x17a>
  800721:	89 c2                	mov    %eax,%edx
  800723:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800727:	83 c0 08             	add    $0x8,%eax
  80072a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80072d:	4c 89 fe             	mov    %r15,%rsi
  800730:	8b 3a                	mov    (%rdx),%edi
  800732:	41 ff d5             	callq  *%r13
        break;
  800735:	e9 b0 fe ff ff       	jmpq   8005ea <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80073a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80073e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800742:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800746:	eb e5                	jmp    80072d <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800748:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80074b:	83 f8 2f             	cmp    $0x2f,%eax
  80074e:	77 5b                	ja     8007ab <vprintfmt+0x1eb>
  800750:	89 c2                	mov    %eax,%edx
  800752:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800756:	83 c0 08             	add    $0x8,%eax
  800759:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80075c:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80075e:	89 c8                	mov    %ecx,%eax
  800760:	c1 f8 1f             	sar    $0x1f,%eax
  800763:	31 c1                	xor    %eax,%ecx
  800765:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800767:	83 f9 09             	cmp    $0x9,%ecx
  80076a:	7f 4d                	jg     8007b9 <vprintfmt+0x1f9>
  80076c:	48 63 c1             	movslq %ecx,%rax
  80076f:	48 ba 20 17 80 00 00 	movabs $0x801720,%rdx
  800776:	00 00 00 
  800779:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80077d:	48 85 c0             	test   %rax,%rax
  800780:	74 37                	je     8007b9 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800782:	48 89 c1             	mov    %rax,%rcx
  800785:	48 ba cc 13 80 00 00 	movabs $0x8013cc,%rdx
  80078c:	00 00 00 
  80078f:	4c 89 fe             	mov    %r15,%rsi
  800792:	4c 89 ef             	mov    %r13,%rdi
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	48 bb 3a 05 80 00 00 	movabs $0x80053a,%rbx
  8007a1:	00 00 00 
  8007a4:	ff d3                	callq  *%rbx
  8007a6:	e9 3f fe ff ff       	jmpq   8005ea <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8007ab:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007af:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007b3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b7:	eb a3                	jmp    80075c <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8007b9:	48 ba c3 13 80 00 00 	movabs $0x8013c3,%rdx
  8007c0:	00 00 00 
  8007c3:	4c 89 fe             	mov    %r15,%rsi
  8007c6:	4c 89 ef             	mov    %r13,%rdi
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ce:	48 bb 3a 05 80 00 00 	movabs $0x80053a,%rbx
  8007d5:	00 00 00 
  8007d8:	ff d3                	callq  *%rbx
  8007da:	e9 0b fe ff ff       	jmpq   8005ea <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8007df:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007e2:	83 f8 2f             	cmp    $0x2f,%eax
  8007e5:	77 4b                	ja     800832 <vprintfmt+0x272>
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ed:	83 c0 08             	add    $0x8,%eax
  8007f0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007f3:	48 8b 02             	mov    (%rdx),%rax
  8007f6:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8007fa:	48 85 c0             	test   %rax,%rax
  8007fd:	0f 84 05 04 00 00    	je     800c08 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800803:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800807:	7e 06                	jle    80080f <vprintfmt+0x24f>
  800809:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80080d:	75 31                	jne    800840 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800813:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800817:	0f b6 00             	movzbl (%rax),%eax
  80081a:	0f be f8             	movsbl %al,%edi
  80081d:	85 ff                	test   %edi,%edi
  80081f:	0f 84 c3 00 00 00    	je     8008e8 <vprintfmt+0x328>
  800825:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800829:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80082d:	e9 85 00 00 00       	jmpq   8008b7 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800832:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800836:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80083a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80083e:	eb b3                	jmp    8007f3 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800840:	49 63 f4             	movslq %r12d,%rsi
  800843:	48 89 c7             	mov    %rax,%rdi
  800846:	48 b8 97 0d 80 00 00 	movabs $0x800d97,%rax
  80084d:	00 00 00 
  800850:	ff d0                	callq  *%rax
  800852:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800855:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800858:	85 f6                	test   %esi,%esi
  80085a:	7e 22                	jle    80087e <vprintfmt+0x2be>
            putch(padc, putdat);
  80085c:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800860:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800864:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800868:	4c 89 fe             	mov    %r15,%rsi
  80086b:	89 df                	mov    %ebx,%edi
  80086d:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800870:	41 83 ec 01          	sub    $0x1,%r12d
  800874:	75 f2                	jne    800868 <vprintfmt+0x2a8>
  800876:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80087a:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80087e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800882:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800886:	0f b6 00             	movzbl (%rax),%eax
  800889:	0f be f8             	movsbl %al,%edi
  80088c:	85 ff                	test   %edi,%edi
  80088e:	0f 84 56 fd ff ff    	je     8005ea <vprintfmt+0x2a>
  800894:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800898:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80089c:	eb 19                	jmp    8008b7 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80089e:	4c 89 fe             	mov    %r15,%rsi
  8008a1:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a4:	41 83 ee 01          	sub    $0x1,%r14d
  8008a8:	48 83 c3 01          	add    $0x1,%rbx
  8008ac:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8008b0:	0f be f8             	movsbl %al,%edi
  8008b3:	85 ff                	test   %edi,%edi
  8008b5:	74 29                	je     8008e0 <vprintfmt+0x320>
  8008b7:	45 85 e4             	test   %r12d,%r12d
  8008ba:	78 06                	js     8008c2 <vprintfmt+0x302>
  8008bc:	41 83 ec 01          	sub    $0x1,%r12d
  8008c0:	78 48                	js     80090a <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8008c2:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8008c6:	74 d6                	je     80089e <vprintfmt+0x2de>
  8008c8:	0f be c0             	movsbl %al,%eax
  8008cb:	83 e8 20             	sub    $0x20,%eax
  8008ce:	83 f8 5e             	cmp    $0x5e,%eax
  8008d1:	76 cb                	jbe    80089e <vprintfmt+0x2de>
            putch('?', putdat);
  8008d3:	4c 89 fe             	mov    %r15,%rsi
  8008d6:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8008db:	41 ff d5             	callq  *%r13
  8008de:	eb c4                	jmp    8008a4 <vprintfmt+0x2e4>
  8008e0:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008e4:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8008e8:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8008eb:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008ef:	0f 8e f5 fc ff ff    	jle    8005ea <vprintfmt+0x2a>
          putch(' ', putdat);
  8008f5:	4c 89 fe             	mov    %r15,%rsi
  8008f8:	bf 20 00 00 00       	mov    $0x20,%edi
  8008fd:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800900:	83 eb 01             	sub    $0x1,%ebx
  800903:	75 f0                	jne    8008f5 <vprintfmt+0x335>
  800905:	e9 e0 fc ff ff       	jmpq   8005ea <vprintfmt+0x2a>
  80090a:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80090e:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800912:	eb d4                	jmp    8008e8 <vprintfmt+0x328>
  if (lflag >= 2)
  800914:	83 f9 01             	cmp    $0x1,%ecx
  800917:	7f 1d                	jg     800936 <vprintfmt+0x376>
  else if (lflag)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 5e                	je     80097b <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80091d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800920:	83 f8 2f             	cmp    $0x2f,%eax
  800923:	77 48                	ja     80096d <vprintfmt+0x3ad>
  800925:	89 c2                	mov    %eax,%edx
  800927:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092b:	83 c0 08             	add    $0x8,%eax
  80092e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800931:	48 8b 1a             	mov    (%rdx),%rbx
  800934:	eb 17                	jmp    80094d <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800936:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800939:	83 f8 2f             	cmp    $0x2f,%eax
  80093c:	77 21                	ja     80095f <vprintfmt+0x39f>
  80093e:	89 c2                	mov    %eax,%edx
  800940:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800944:	83 c0 08             	add    $0x8,%eax
  800947:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094a:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80094d:	48 85 db             	test   %rbx,%rbx
  800950:	78 50                	js     8009a2 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800952:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800955:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80095a:	e9 b4 01 00 00       	jmpq   800b13 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80095f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800963:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800967:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096b:	eb dd                	jmp    80094a <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80096d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800971:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800975:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800979:	eb b6                	jmp    800931 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80097b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80097e:	83 f8 2f             	cmp    $0x2f,%eax
  800981:	77 11                	ja     800994 <vprintfmt+0x3d4>
  800983:	89 c2                	mov    %eax,%edx
  800985:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800989:	83 c0 08             	add    $0x8,%eax
  80098c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80098f:	48 63 1a             	movslq (%rdx),%rbx
  800992:	eb b9                	jmp    80094d <vprintfmt+0x38d>
  800994:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800998:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a0:	eb ed                	jmp    80098f <vprintfmt+0x3cf>
          putch('-', putdat);
  8009a2:	4c 89 fe             	mov    %r15,%rsi
  8009a5:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8009aa:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8009ad:	48 89 da             	mov    %rbx,%rdx
  8009b0:	48 f7 da             	neg    %rdx
        base = 10;
  8009b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b8:	e9 56 01 00 00       	jmpq   800b13 <vprintfmt+0x553>
  if (lflag >= 2)
  8009bd:	83 f9 01             	cmp    $0x1,%ecx
  8009c0:	7f 25                	jg     8009e7 <vprintfmt+0x427>
  else if (lflag)
  8009c2:	85 c9                	test   %ecx,%ecx
  8009c4:	74 5e                	je     800a24 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8009c6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c9:	83 f8 2f             	cmp    $0x2f,%eax
  8009cc:	77 48                	ja     800a16 <vprintfmt+0x456>
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d4:	83 c0 08             	add    $0x8,%eax
  8009d7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009da:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009e2:	e9 2c 01 00 00       	jmpq   800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ea:	83 f8 2f             	cmp    $0x2f,%eax
  8009ed:	77 19                	ja     800a08 <vprintfmt+0x448>
  8009ef:	89 c2                	mov    %eax,%edx
  8009f1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f5:	83 c0 08             	add    $0x8,%eax
  8009f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009fb:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a03:	e9 0b 01 00 00       	jmpq   800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a08:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a0c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a10:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a14:	eb e5                	jmp    8009fb <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800a16:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a1a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a22:	eb b6                	jmp    8009da <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800a24:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a27:	83 f8 2f             	cmp    $0x2f,%eax
  800a2a:	77 18                	ja     800a44 <vprintfmt+0x484>
  800a2c:	89 c2                	mov    %eax,%edx
  800a2e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a32:	83 c0 08             	add    $0x8,%eax
  800a35:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a38:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800a3a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a3f:	e9 cf 00 00 00       	jmpq   800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a44:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a48:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a4c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a50:	eb e6                	jmp    800a38 <vprintfmt+0x478>
  if (lflag >= 2)
  800a52:	83 f9 01             	cmp    $0x1,%ecx
  800a55:	7f 25                	jg     800a7c <vprintfmt+0x4bc>
  else if (lflag)
  800a57:	85 c9                	test   %ecx,%ecx
  800a59:	74 5b                	je     800ab6 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800a5b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a5e:	83 f8 2f             	cmp    $0x2f,%eax
  800a61:	77 45                	ja     800aa8 <vprintfmt+0x4e8>
  800a63:	89 c2                	mov    %eax,%edx
  800a65:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a69:	83 c0 08             	add    $0x8,%eax
  800a6c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a6f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a72:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a77:	e9 97 00 00 00       	jmpq   800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a7c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a7f:	83 f8 2f             	cmp    $0x2f,%eax
  800a82:	77 16                	ja     800a9a <vprintfmt+0x4da>
  800a84:	89 c2                	mov    %eax,%edx
  800a86:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a8a:	83 c0 08             	add    $0x8,%eax
  800a8d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a90:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a93:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a98:	eb 79                	jmp    800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a9a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a9e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aa2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aa6:	eb e8                	jmp    800a90 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800aa8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ab4:	eb b9                	jmp    800a6f <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800ab6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ab9:	83 f8 2f             	cmp    $0x2f,%eax
  800abc:	77 15                	ja     800ad3 <vprintfmt+0x513>
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ac4:	83 c0 08             	add    $0x8,%eax
  800ac7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aca:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800acc:	b9 08 00 00 00       	mov    $0x8,%ecx
  800ad1:	eb 40                	jmp    800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800ad3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800adb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800adf:	eb e9                	jmp    800aca <vprintfmt+0x50a>
        putch('0', putdat);
  800ae1:	4c 89 fe             	mov    %r15,%rsi
  800ae4:	bf 30 00 00 00       	mov    $0x30,%edi
  800ae9:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800aec:	4c 89 fe             	mov    %r15,%rsi
  800aef:	bf 78 00 00 00       	mov    $0x78,%edi
  800af4:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800af7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800afa:	83 f8 2f             	cmp    $0x2f,%eax
  800afd:	77 34                	ja     800b33 <vprintfmt+0x573>
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b05:	83 c0 08             	add    $0x8,%eax
  800b08:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b0b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b0e:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800b13:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800b18:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800b1c:	4c 89 fe             	mov    %r15,%rsi
  800b1f:	4c 89 ef             	mov    %r13,%rdi
  800b22:	48 b8 96 04 80 00 00 	movabs $0x800496,%rax
  800b29:	00 00 00 
  800b2c:	ff d0                	callq  *%rax
        break;
  800b2e:	e9 b7 fa ff ff       	jmpq   8005ea <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800b33:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b37:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b3b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b3f:	eb ca                	jmp    800b0b <vprintfmt+0x54b>
  if (lflag >= 2)
  800b41:	83 f9 01             	cmp    $0x1,%ecx
  800b44:	7f 22                	jg     800b68 <vprintfmt+0x5a8>
  else if (lflag)
  800b46:	85 c9                	test   %ecx,%ecx
  800b48:	74 58                	je     800ba2 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800b4a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b4d:	83 f8 2f             	cmp    $0x2f,%eax
  800b50:	77 42                	ja     800b94 <vprintfmt+0x5d4>
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b58:	83 c0 08             	add    $0x8,%eax
  800b5b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b5e:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b61:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b66:	eb ab                	jmp    800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b68:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b6b:	83 f8 2f             	cmp    $0x2f,%eax
  800b6e:	77 16                	ja     800b86 <vprintfmt+0x5c6>
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b76:	83 c0 08             	add    $0x8,%eax
  800b79:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b7c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b7f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b84:	eb 8d                	jmp    800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b86:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b8a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b8e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b92:	eb e8                	jmp    800b7c <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b94:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b98:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b9c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ba0:	eb bc                	jmp    800b5e <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ba2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ba5:	83 f8 2f             	cmp    $0x2f,%eax
  800ba8:	77 18                	ja     800bc2 <vprintfmt+0x602>
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bb0:	83 c0 08             	add    $0x8,%eax
  800bb3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bb6:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800bb8:	b9 10 00 00 00       	mov    $0x10,%ecx
  800bbd:	e9 51 ff ff ff       	jmpq   800b13 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800bc2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bc6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bca:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bce:	eb e6                	jmp    800bb6 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800bd0:	4c 89 fe             	mov    %r15,%rsi
  800bd3:	bf 25 00 00 00       	mov    $0x25,%edi
  800bd8:	41 ff d5             	callq  *%r13
        break;
  800bdb:	e9 0a fa ff ff       	jmpq   8005ea <vprintfmt+0x2a>
        putch('%', putdat);
  800be0:	4c 89 fe             	mov    %r15,%rsi
  800be3:	bf 25 00 00 00       	mov    $0x25,%edi
  800be8:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800beb:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800bef:	0f 84 15 fa ff ff    	je     80060a <vprintfmt+0x4a>
  800bf5:	49 89 de             	mov    %rbx,%r14
  800bf8:	49 83 ee 01          	sub    $0x1,%r14
  800bfc:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800c01:	75 f5                	jne    800bf8 <vprintfmt+0x638>
  800c03:	e9 e2 f9 ff ff       	jmpq   8005ea <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800c08:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800c0c:	74 06                	je     800c14 <vprintfmt+0x654>
  800c0e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800c12:	7f 21                	jg     800c35 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c14:	bf 28 00 00 00       	mov    $0x28,%edi
  800c19:	48 bb bd 13 80 00 00 	movabs $0x8013bd,%rbx
  800c20:	00 00 00 
  800c23:	b8 28 00 00 00       	mov    $0x28,%eax
  800c28:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c2c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c30:	e9 82 fc ff ff       	jmpq   8008b7 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800c35:	49 63 f4             	movslq %r12d,%rsi
  800c38:	48 bf bc 13 80 00 00 	movabs $0x8013bc,%rdi
  800c3f:	00 00 00 
  800c42:	48 b8 97 0d 80 00 00 	movabs $0x800d97,%rax
  800c49:	00 00 00 
  800c4c:	ff d0                	callq  *%rax
  800c4e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800c51:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800c54:	48 be bc 13 80 00 00 	movabs $0x8013bc,%rsi
  800c5b:	00 00 00 
  800c5e:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	0f 8f f2 fb ff ff    	jg     80085c <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c6a:	48 bb bd 13 80 00 00 	movabs $0x8013bd,%rbx
  800c71:	00 00 00 
  800c74:	b8 28 00 00 00       	mov    $0x28,%eax
  800c79:	bf 28 00 00 00       	mov    $0x28,%edi
  800c7e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c82:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c86:	e9 2c fc ff ff       	jmpq   8008b7 <vprintfmt+0x2f7>
}
  800c8b:	48 83 c4 48          	add    $0x48,%rsp
  800c8f:	5b                   	pop    %rbx
  800c90:	41 5c                	pop    %r12
  800c92:	41 5d                	pop    %r13
  800c94:	41 5e                	pop    %r14
  800c96:	41 5f                	pop    %r15
  800c98:	5d                   	pop    %rbp
  800c99:	c3                   	retq   

0000000000800c9a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c9a:	55                   	push   %rbp
  800c9b:	48 89 e5             	mov    %rsp,%rbp
  800c9e:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ca2:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ca6:	48 63 c6             	movslq %esi,%rax
  800ca9:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800cae:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800cb2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800cb9:	48 85 ff             	test   %rdi,%rdi
  800cbc:	74 2a                	je     800ce8 <vsnprintf+0x4e>
  800cbe:	85 f6                	test   %esi,%esi
  800cc0:	7e 26                	jle    800ce8 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800cc2:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800cc6:	48 bf 22 05 80 00 00 	movabs $0x800522,%rdi
  800ccd:	00 00 00 
  800cd0:	48 b8 c0 05 80 00 00 	movabs $0x8005c0,%rax
  800cd7:	00 00 00 
  800cda:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800cdc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ce0:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ce3:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ce6:	c9                   	leaveq 
  800ce7:	c3                   	retq   
    return -E_INVAL;
  800ce8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ced:	eb f7                	jmp    800ce6 <vsnprintf+0x4c>

0000000000800cef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800cef:	55                   	push   %rbp
  800cf0:	48 89 e5             	mov    %rsp,%rbp
  800cf3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800cfa:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800d01:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800d08:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800d0f:	84 c0                	test   %al,%al
  800d11:	74 20                	je     800d33 <snprintf+0x44>
  800d13:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800d17:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800d1b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800d1f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800d23:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800d27:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800d2b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800d2f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800d33:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800d3a:	00 00 00 
  800d3d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800d44:	00 00 00 
  800d47:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800d4b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800d52:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800d59:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800d60:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800d67:	48 b8 9a 0c 80 00 00 	movabs $0x800c9a,%rax
  800d6e:	00 00 00 
  800d71:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800d73:	c9                   	leaveq 
  800d74:	c3                   	retq   

0000000000800d75 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800d75:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d78:	74 17                	je     800d91 <strlen+0x1c>
  800d7a:	48 89 fa             	mov    %rdi,%rdx
  800d7d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d82:	29 f9                	sub    %edi,%ecx
    n++;
  800d84:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d87:	48 83 c2 01          	add    $0x1,%rdx
  800d8b:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d8e:	75 f4                	jne    800d84 <strlen+0xf>
  800d90:	c3                   	retq   
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d96:	c3                   	retq   

0000000000800d97 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d97:	48 85 f6             	test   %rsi,%rsi
  800d9a:	74 24                	je     800dc0 <strnlen+0x29>
  800d9c:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d9f:	74 25                	je     800dc6 <strnlen+0x2f>
  800da1:	48 01 fe             	add    %rdi,%rsi
  800da4:	48 89 fa             	mov    %rdi,%rdx
  800da7:	b9 01 00 00 00       	mov    $0x1,%ecx
  800dac:	29 f9                	sub    %edi,%ecx
    n++;
  800dae:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800db1:	48 83 c2 01          	add    $0x1,%rdx
  800db5:	48 39 f2             	cmp    %rsi,%rdx
  800db8:	74 11                	je     800dcb <strnlen+0x34>
  800dba:	80 3a 00             	cmpb   $0x0,(%rdx)
  800dbd:	75 ef                	jne    800dae <strnlen+0x17>
  800dbf:	c3                   	retq   
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc5:	c3                   	retq   
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800dcb:	c3                   	retq   

0000000000800dcc <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800dcc:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd4:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800dd8:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800ddb:	48 83 c2 01          	add    $0x1,%rdx
  800ddf:	84 c9                	test   %cl,%cl
  800de1:	75 f1                	jne    800dd4 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800de3:	c3                   	retq   

0000000000800de4 <strcat>:

char *
strcat(char *dst, const char *src) {
  800de4:	55                   	push   %rbp
  800de5:	48 89 e5             	mov    %rsp,%rbp
  800de8:	41 54                	push   %r12
  800dea:	53                   	push   %rbx
  800deb:	48 89 fb             	mov    %rdi,%rbx
  800dee:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800df1:	48 b8 75 0d 80 00 00 	movabs $0x800d75,%rax
  800df8:	00 00 00 
  800dfb:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800dfd:	48 63 f8             	movslq %eax,%rdi
  800e00:	48 01 df             	add    %rbx,%rdi
  800e03:	4c 89 e6             	mov    %r12,%rsi
  800e06:	48 b8 cc 0d 80 00 00 	movabs $0x800dcc,%rax
  800e0d:	00 00 00 
  800e10:	ff d0                	callq  *%rax
  return dst;
}
  800e12:	48 89 d8             	mov    %rbx,%rax
  800e15:	5b                   	pop    %rbx
  800e16:	41 5c                	pop    %r12
  800e18:	5d                   	pop    %rbp
  800e19:	c3                   	retq   

0000000000800e1a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e1a:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800e1d:	48 85 d2             	test   %rdx,%rdx
  800e20:	74 1f                	je     800e41 <strncpy+0x27>
  800e22:	48 01 fa             	add    %rdi,%rdx
  800e25:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800e28:	48 83 c1 01          	add    $0x1,%rcx
  800e2c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e30:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800e34:	41 80 f8 01          	cmp    $0x1,%r8b
  800e38:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800e3c:	48 39 ca             	cmp    %rcx,%rdx
  800e3f:	75 e7                	jne    800e28 <strncpy+0xe>
  }
  return ret;
}
  800e41:	c3                   	retq   

0000000000800e42 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800e42:	48 89 f8             	mov    %rdi,%rax
  800e45:	48 85 d2             	test   %rdx,%rdx
  800e48:	74 36                	je     800e80 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800e4a:	48 83 fa 01          	cmp    $0x1,%rdx
  800e4e:	74 2d                	je     800e7d <strlcpy+0x3b>
  800e50:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e54:	45 84 c0             	test   %r8b,%r8b
  800e57:	74 24                	je     800e7d <strlcpy+0x3b>
  800e59:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800e5d:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800e62:	48 83 c0 01          	add    $0x1,%rax
  800e66:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800e6a:	48 39 d1             	cmp    %rdx,%rcx
  800e6d:	74 0e                	je     800e7d <strlcpy+0x3b>
  800e6f:	48 83 c1 01          	add    $0x1,%rcx
  800e73:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800e78:	45 84 c0             	test   %r8b,%r8b
  800e7b:	75 e5                	jne    800e62 <strlcpy+0x20>
    *dst = '\0';
  800e7d:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800e80:	48 29 f8             	sub    %rdi,%rax
}
  800e83:	c3                   	retq   

0000000000800e84 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e84:	0f b6 07             	movzbl (%rdi),%eax
  800e87:	84 c0                	test   %al,%al
  800e89:	74 17                	je     800ea2 <strcmp+0x1e>
  800e8b:	3a 06                	cmp    (%rsi),%al
  800e8d:	75 13                	jne    800ea2 <strcmp+0x1e>
    p++, q++;
  800e8f:	48 83 c7 01          	add    $0x1,%rdi
  800e93:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e97:	0f b6 07             	movzbl (%rdi),%eax
  800e9a:	84 c0                	test   %al,%al
  800e9c:	74 04                	je     800ea2 <strcmp+0x1e>
  800e9e:	3a 06                	cmp    (%rsi),%al
  800ea0:	74 ed                	je     800e8f <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800ea2:	0f b6 c0             	movzbl %al,%eax
  800ea5:	0f b6 16             	movzbl (%rsi),%edx
  800ea8:	29 d0                	sub    %edx,%eax
}
  800eaa:	c3                   	retq   

0000000000800eab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800eab:	48 85 d2             	test   %rdx,%rdx
  800eae:	74 2f                	je     800edf <strncmp+0x34>
  800eb0:	0f b6 07             	movzbl (%rdi),%eax
  800eb3:	84 c0                	test   %al,%al
  800eb5:	74 1f                	je     800ed6 <strncmp+0x2b>
  800eb7:	3a 06                	cmp    (%rsi),%al
  800eb9:	75 1b                	jne    800ed6 <strncmp+0x2b>
  800ebb:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800ebe:	48 83 c7 01          	add    $0x1,%rdi
  800ec2:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ec6:	48 39 d7             	cmp    %rdx,%rdi
  800ec9:	74 1a                	je     800ee5 <strncmp+0x3a>
  800ecb:	0f b6 07             	movzbl (%rdi),%eax
  800ece:	84 c0                	test   %al,%al
  800ed0:	74 04                	je     800ed6 <strncmp+0x2b>
  800ed2:	3a 06                	cmp    (%rsi),%al
  800ed4:	74 e8                	je     800ebe <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ed6:	0f b6 07             	movzbl (%rdi),%eax
  800ed9:	0f b6 16             	movzbl (%rsi),%edx
  800edc:	29 d0                	sub    %edx,%eax
}
  800ede:	c3                   	retq   
    return 0;
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	c3                   	retq   
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eea:	c3                   	retq   

0000000000800eeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800eeb:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800eed:	0f b6 07             	movzbl (%rdi),%eax
  800ef0:	84 c0                	test   %al,%al
  800ef2:	74 1e                	je     800f12 <strchr+0x27>
    if (*s == c)
  800ef4:	40 38 c6             	cmp    %al,%sil
  800ef7:	74 1f                	je     800f18 <strchr+0x2d>
  for (; *s; s++)
  800ef9:	48 83 c7 01          	add    $0x1,%rdi
  800efd:	0f b6 07             	movzbl (%rdi),%eax
  800f00:	84 c0                	test   %al,%al
  800f02:	74 08                	je     800f0c <strchr+0x21>
    if (*s == c)
  800f04:	38 d0                	cmp    %dl,%al
  800f06:	75 f1                	jne    800ef9 <strchr+0xe>
  for (; *s; s++)
  800f08:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800f0b:	c3                   	retq   
  return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f11:	c3                   	retq   
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	c3                   	retq   
    if (*s == c)
  800f18:	48 89 f8             	mov    %rdi,%rax
  800f1b:	c3                   	retq   

0000000000800f1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800f1c:	48 89 f8             	mov    %rdi,%rax
  800f1f:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800f21:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800f24:	40 38 f2             	cmp    %sil,%dl
  800f27:	74 13                	je     800f3c <strfind+0x20>
  800f29:	84 d2                	test   %dl,%dl
  800f2b:	74 0f                	je     800f3c <strfind+0x20>
  for (; *s; s++)
  800f2d:	48 83 c0 01          	add    $0x1,%rax
  800f31:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800f34:	38 ca                	cmp    %cl,%dl
  800f36:	74 04                	je     800f3c <strfind+0x20>
  800f38:	84 d2                	test   %dl,%dl
  800f3a:	75 f1                	jne    800f2d <strfind+0x11>
      break;
  return (char *)s;
}
  800f3c:	c3                   	retq   

0000000000800f3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800f3d:	48 85 d2             	test   %rdx,%rdx
  800f40:	74 3a                	je     800f7c <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f42:	48 89 f8             	mov    %rdi,%rax
  800f45:	48 09 d0             	or     %rdx,%rax
  800f48:	a8 03                	test   $0x3,%al
  800f4a:	75 28                	jne    800f74 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800f4c:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800f50:	89 f0                	mov    %esi,%eax
  800f52:	c1 e0 08             	shl    $0x8,%eax
  800f55:	89 f1                	mov    %esi,%ecx
  800f57:	c1 e1 18             	shl    $0x18,%ecx
  800f5a:	41 89 f0             	mov    %esi,%r8d
  800f5d:	41 c1 e0 10          	shl    $0x10,%r8d
  800f61:	44 09 c1             	or     %r8d,%ecx
  800f64:	09 ce                	or     %ecx,%esi
  800f66:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800f68:	48 c1 ea 02          	shr    $0x2,%rdx
  800f6c:	48 89 d1             	mov    %rdx,%rcx
  800f6f:	fc                   	cld    
  800f70:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f72:	eb 08                	jmp    800f7c <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800f74:	89 f0                	mov    %esi,%eax
  800f76:	48 89 d1             	mov    %rdx,%rcx
  800f79:	fc                   	cld    
  800f7a:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800f7c:	48 89 f8             	mov    %rdi,%rax
  800f7f:	c3                   	retq   

0000000000800f80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800f80:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f83:	48 39 fe             	cmp    %rdi,%rsi
  800f86:	73 40                	jae    800fc8 <memmove+0x48>
  800f88:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f8c:	48 39 f9             	cmp    %rdi,%rcx
  800f8f:	76 37                	jbe    800fc8 <memmove+0x48>
    s += n;
    d += n;
  800f91:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f95:	48 89 fe             	mov    %rdi,%rsi
  800f98:	48 09 d6             	or     %rdx,%rsi
  800f9b:	48 09 ce             	or     %rcx,%rsi
  800f9e:	40 f6 c6 03          	test   $0x3,%sil
  800fa2:	75 14                	jne    800fb8 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800fa4:	48 83 ef 04          	sub    $0x4,%rdi
  800fa8:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800fac:	48 c1 ea 02          	shr    $0x2,%rdx
  800fb0:	48 89 d1             	mov    %rdx,%rcx
  800fb3:	fd                   	std    
  800fb4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800fb6:	eb 0e                	jmp    800fc6 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800fb8:	48 83 ef 01          	sub    $0x1,%rdi
  800fbc:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800fc0:	48 89 d1             	mov    %rdx,%rcx
  800fc3:	fd                   	std    
  800fc4:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800fc6:	fc                   	cld    
  800fc7:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800fc8:	48 89 c1             	mov    %rax,%rcx
  800fcb:	48 09 d1             	or     %rdx,%rcx
  800fce:	48 09 f1             	or     %rsi,%rcx
  800fd1:	f6 c1 03             	test   $0x3,%cl
  800fd4:	75 0e                	jne    800fe4 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800fd6:	48 c1 ea 02          	shr    $0x2,%rdx
  800fda:	48 89 d1             	mov    %rdx,%rcx
  800fdd:	48 89 c7             	mov    %rax,%rdi
  800fe0:	fc                   	cld    
  800fe1:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800fe3:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800fe4:	48 89 c7             	mov    %rax,%rdi
  800fe7:	48 89 d1             	mov    %rdx,%rcx
  800fea:	fc                   	cld    
  800feb:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800fed:	c3                   	retq   

0000000000800fee <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800fee:	55                   	push   %rbp
  800fef:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800ff2:	48 b8 80 0f 80 00 00 	movabs $0x800f80,%rax
  800ff9:	00 00 00 
  800ffc:	ff d0                	callq  *%rax
}
  800ffe:	5d                   	pop    %rbp
  800fff:	c3                   	retq   

0000000000801000 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801000:	55                   	push   %rbp
  801001:	48 89 e5             	mov    %rsp,%rbp
  801004:	41 57                	push   %r15
  801006:	41 56                	push   %r14
  801008:	41 55                	push   %r13
  80100a:	41 54                	push   %r12
  80100c:	53                   	push   %rbx
  80100d:	48 83 ec 08          	sub    $0x8,%rsp
  801011:	49 89 fe             	mov    %rdi,%r14
  801014:	49 89 f7             	mov    %rsi,%r15
  801017:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  80101a:	48 89 f7             	mov    %rsi,%rdi
  80101d:	48 b8 75 0d 80 00 00 	movabs $0x800d75,%rax
  801024:	00 00 00 
  801027:	ff d0                	callq  *%rax
  801029:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  80102c:	4c 89 ee             	mov    %r13,%rsi
  80102f:	4c 89 f7             	mov    %r14,%rdi
  801032:	48 b8 97 0d 80 00 00 	movabs $0x800d97,%rax
  801039:	00 00 00 
  80103c:	ff d0                	callq  *%rax
  80103e:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801041:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801045:	4d 39 e5             	cmp    %r12,%r13
  801048:	74 26                	je     801070 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  80104a:	4c 89 e8             	mov    %r13,%rax
  80104d:	4c 29 e0             	sub    %r12,%rax
  801050:	48 39 d8             	cmp    %rbx,%rax
  801053:	76 2a                	jbe    80107f <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801055:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801059:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80105d:	4c 89 fe             	mov    %r15,%rsi
  801060:	48 b8 ee 0f 80 00 00 	movabs $0x800fee,%rax
  801067:	00 00 00 
  80106a:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80106c:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801070:	48 83 c4 08          	add    $0x8,%rsp
  801074:	5b                   	pop    %rbx
  801075:	41 5c                	pop    %r12
  801077:	41 5d                	pop    %r13
  801079:	41 5e                	pop    %r14
  80107b:	41 5f                	pop    %r15
  80107d:	5d                   	pop    %rbp
  80107e:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80107f:	49 83 ed 01          	sub    $0x1,%r13
  801083:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801087:	4c 89 ea             	mov    %r13,%rdx
  80108a:	4c 89 fe             	mov    %r15,%rsi
  80108d:	48 b8 ee 0f 80 00 00 	movabs $0x800fee,%rax
  801094:	00 00 00 
  801097:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801099:	4d 01 ee             	add    %r13,%r14
  80109c:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8010a1:	eb c9                	jmp    80106c <strlcat+0x6c>

00000000008010a3 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8010a3:	48 85 d2             	test   %rdx,%rdx
  8010a6:	74 3a                	je     8010e2 <memcmp+0x3f>
    if (*s1 != *s2)
  8010a8:	0f b6 0f             	movzbl (%rdi),%ecx
  8010ab:	44 0f b6 06          	movzbl (%rsi),%r8d
  8010af:	44 38 c1             	cmp    %r8b,%cl
  8010b2:	75 1d                	jne    8010d1 <memcmp+0x2e>
  8010b4:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8010b9:	48 39 d0             	cmp    %rdx,%rax
  8010bc:	74 1e                	je     8010dc <memcmp+0x39>
    if (*s1 != *s2)
  8010be:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8010c2:	48 83 c0 01          	add    $0x1,%rax
  8010c6:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8010cc:	44 38 c1             	cmp    %r8b,%cl
  8010cf:	74 e8                	je     8010b9 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8010d1:	0f b6 c1             	movzbl %cl,%eax
  8010d4:	45 0f b6 c0          	movzbl %r8b,%r8d
  8010d8:	44 29 c0             	sub    %r8d,%eax
  8010db:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	c3                   	retq   
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e7:	c3                   	retq   

00000000008010e8 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8010e8:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8010ec:	48 39 c7             	cmp    %rax,%rdi
  8010ef:	73 19                	jae    80110a <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010f1:	89 f2                	mov    %esi,%edx
  8010f3:	40 38 37             	cmp    %sil,(%rdi)
  8010f6:	74 16                	je     80110e <memfind+0x26>
  for (; s < ends; s++)
  8010f8:	48 83 c7 01          	add    $0x1,%rdi
  8010fc:	48 39 f8             	cmp    %rdi,%rax
  8010ff:	74 08                	je     801109 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801101:	38 17                	cmp    %dl,(%rdi)
  801103:	75 f3                	jne    8010f8 <memfind+0x10>
  for (; s < ends; s++)
  801105:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801108:	c3                   	retq   
  801109:	c3                   	retq   
  for (; s < ends; s++)
  80110a:	48 89 f8             	mov    %rdi,%rax
  80110d:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80110e:	48 89 f8             	mov    %rdi,%rax
  801111:	c3                   	retq   

0000000000801112 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801112:	0f b6 07             	movzbl (%rdi),%eax
  801115:	3c 20                	cmp    $0x20,%al
  801117:	74 04                	je     80111d <strtol+0xb>
  801119:	3c 09                	cmp    $0x9,%al
  80111b:	75 0f                	jne    80112c <strtol+0x1a>
    s++;
  80111d:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801121:	0f b6 07             	movzbl (%rdi),%eax
  801124:	3c 20                	cmp    $0x20,%al
  801126:	74 f5                	je     80111d <strtol+0xb>
  801128:	3c 09                	cmp    $0x9,%al
  80112a:	74 f1                	je     80111d <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80112c:	3c 2b                	cmp    $0x2b,%al
  80112e:	74 2b                	je     80115b <strtol+0x49>
  int neg  = 0;
  801130:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801136:	3c 2d                	cmp    $0x2d,%al
  801138:	74 2d                	je     801167 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80113a:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801140:	75 0f                	jne    801151 <strtol+0x3f>
  801142:	80 3f 30             	cmpb   $0x30,(%rdi)
  801145:	74 2c                	je     801173 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801147:	85 d2                	test   %edx,%edx
  801149:	b8 0a 00 00 00       	mov    $0xa,%eax
  80114e:	0f 44 d0             	cmove  %eax,%edx
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801156:	4c 63 d2             	movslq %edx,%r10
  801159:	eb 5c                	jmp    8011b7 <strtol+0xa5>
    s++;
  80115b:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80115f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801165:	eb d3                	jmp    80113a <strtol+0x28>
    s++, neg = 1;
  801167:	48 83 c7 01          	add    $0x1,%rdi
  80116b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801171:	eb c7                	jmp    80113a <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801173:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801177:	74 0f                	je     801188 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801179:	85 d2                	test   %edx,%edx
  80117b:	75 d4                	jne    801151 <strtol+0x3f>
    s++, base = 8;
  80117d:	48 83 c7 01          	add    $0x1,%rdi
  801181:	ba 08 00 00 00       	mov    $0x8,%edx
  801186:	eb c9                	jmp    801151 <strtol+0x3f>
    s += 2, base = 16;
  801188:	48 83 c7 02          	add    $0x2,%rdi
  80118c:	ba 10 00 00 00       	mov    $0x10,%edx
  801191:	eb be                	jmp    801151 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801193:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801197:	41 80 f8 19          	cmp    $0x19,%r8b
  80119b:	77 2f                	ja     8011cc <strtol+0xba>
      dig = *s - 'a' + 10;
  80119d:	44 0f be c1          	movsbl %cl,%r8d
  8011a1:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8011a5:	39 d1                	cmp    %edx,%ecx
  8011a7:	7d 37                	jge    8011e0 <strtol+0xce>
    s++, val = (val * base) + dig;
  8011a9:	48 83 c7 01          	add    $0x1,%rdi
  8011ad:	49 0f af c2          	imul   %r10,%rax
  8011b1:	48 63 c9             	movslq %ecx,%rcx
  8011b4:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8011b7:	0f b6 0f             	movzbl (%rdi),%ecx
  8011ba:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8011be:	41 80 f8 09          	cmp    $0x9,%r8b
  8011c2:	77 cf                	ja     801193 <strtol+0x81>
      dig = *s - '0';
  8011c4:	0f be c9             	movsbl %cl,%ecx
  8011c7:	83 e9 30             	sub    $0x30,%ecx
  8011ca:	eb d9                	jmp    8011a5 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8011cc:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8011d0:	41 80 f8 19          	cmp    $0x19,%r8b
  8011d4:	77 0a                	ja     8011e0 <strtol+0xce>
      dig = *s - 'A' + 10;
  8011d6:	44 0f be c1          	movsbl %cl,%r8d
  8011da:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8011de:	eb c5                	jmp    8011a5 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8011e0:	48 85 f6             	test   %rsi,%rsi
  8011e3:	74 03                	je     8011e8 <strtol+0xd6>
    *endptr = (char *)s;
  8011e5:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8011e8:	48 89 c2             	mov    %rax,%rdx
  8011eb:	48 f7 da             	neg    %rdx
  8011ee:	45 85 c9             	test   %r9d,%r9d
  8011f1:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8011f5:	c3                   	retq   

00000000008011f6 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8011f6:	55                   	push   %rbp
  8011f7:	48 89 e5             	mov    %rsp,%rbp
  8011fa:	53                   	push   %rbx
  8011fb:	48 89 fa             	mov    %rdi,%rdx
  8011fe:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801201:	b8 00 00 00 00       	mov    $0x0,%eax
  801206:	48 89 c3             	mov    %rax,%rbx
  801209:	48 89 c7             	mov    %rax,%rdi
  80120c:	48 89 c6             	mov    %rax,%rsi
  80120f:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801211:	5b                   	pop    %rbx
  801212:	5d                   	pop    %rbp
  801213:	c3                   	retq   

0000000000801214 <sys_cgetc>:

int
sys_cgetc(void) {
  801214:	55                   	push   %rbp
  801215:	48 89 e5             	mov    %rsp,%rbp
  801218:	53                   	push   %rbx
  asm volatile("int %1\n"
  801219:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121e:	b8 01 00 00 00       	mov    $0x1,%eax
  801223:	48 89 ca             	mov    %rcx,%rdx
  801226:	48 89 cb             	mov    %rcx,%rbx
  801229:	48 89 cf             	mov    %rcx,%rdi
  80122c:	48 89 ce             	mov    %rcx,%rsi
  80122f:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801231:	5b                   	pop    %rbx
  801232:	5d                   	pop    %rbp
  801233:	c3                   	retq   

0000000000801234 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801234:	55                   	push   %rbp
  801235:	48 89 e5             	mov    %rsp,%rbp
  801238:	53                   	push   %rbx
  801239:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80123d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801240:	be 00 00 00 00       	mov    $0x0,%esi
  801245:	b8 03 00 00 00       	mov    $0x3,%eax
  80124a:	48 89 f1             	mov    %rsi,%rcx
  80124d:	48 89 f3             	mov    %rsi,%rbx
  801250:	48 89 f7             	mov    %rsi,%rdi
  801253:	cd 30                	int    $0x30
  if (check && ret > 0)
  801255:	48 85 c0             	test   %rax,%rax
  801258:	7f 07                	jg     801261 <sys_env_destroy+0x2d>
}
  80125a:	48 83 c4 08          	add    $0x8,%rsp
  80125e:	5b                   	pop    %rbx
  80125f:	5d                   	pop    %rbp
  801260:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801261:	49 89 c0             	mov    %rax,%r8
  801264:	b9 03 00 00 00       	mov    $0x3,%ecx
  801269:	48 ba 70 17 80 00 00 	movabs $0x801770,%rdx
  801270:	00 00 00 
  801273:	be 22 00 00 00       	mov    $0x22,%esi
  801278:	48 bf 90 17 80 00 00 	movabs $0x801790,%rdi
  80127f:	00 00 00 
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	49 b9 60 02 80 00 00 	movabs $0x800260,%r9
  80128e:	00 00 00 
  801291:	41 ff d1             	callq  *%r9

0000000000801294 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801294:	55                   	push   %rbp
  801295:	48 89 e5             	mov    %rsp,%rbp
  801298:	53                   	push   %rbx
  asm volatile("int %1\n"
  801299:	b9 00 00 00 00       	mov    $0x0,%ecx
  80129e:	b8 02 00 00 00       	mov    $0x2,%eax
  8012a3:	48 89 ca             	mov    %rcx,%rdx
  8012a6:	48 89 cb             	mov    %rcx,%rbx
  8012a9:	48 89 cf             	mov    %rcx,%rdi
  8012ac:	48 89 ce             	mov    %rcx,%rsi
  8012af:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012b1:	5b                   	pop    %rbx
  8012b2:	5d                   	pop    %rbp
  8012b3:	c3                   	retq   
