
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
  80002e:	48 bf 80 12 80 00 00 	movabs $0x801280,%rdi
  800035:	00 00 00 
  800038:	b8 00 00 00 00       	mov    $0x0,%eax
  80003d:	48 ba ce 03 80 00 00 	movabs $0x8003ce,%rdx
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
  8000da:	48 bf c8 12 80 00 00 	movabs $0x8012c8,%rdi
  8000e1:	00 00 00 
  8000e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e9:	48 ba ce 03 80 00 00 	movabs $0x8003ce,%rdx
  8000f0:	00 00 00 
  8000f3:	ff d2                	callq  *%rdx
  // Accessing via subscript operator ([]) will result in -Warray-bounds warning.
  *((volatile uint32_t *)bigarray + ARRAYSIZE + 0x800000) = 0;
  8000f5:	48 b8 20 20 c0 02 00 	movabs $0x2c02020,%rax
  8000fc:	00 00 00 
  8000ff:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  panic("SHOULD HAVE TRAPPED!!!");
  800105:	48 ba 27 13 80 00 00 	movabs $0x801327,%rdx
  80010c:	00 00 00 
  80010f:	be 1a 00 00 00       	mov    $0x1a,%esi
  800114:	48 bf 18 13 80 00 00 	movabs $0x801318,%rdi
  80011b:	00 00 00 
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	48 b9 2c 02 80 00 00 	movabs $0x80022c,%rcx
  80012a:	00 00 00 
  80012d:	ff d1                	callq  *%rcx
  for (i = 0; i < ARRAYSIZE; i++)
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
      panic("bigarray[%d] isn't cleared!\n", i);
  800134:	48 ba fb 12 80 00 00 	movabs $0x8012fb,%rdx
  80013b:	00 00 00 
  80013e:	be 10 00 00 00       	mov    $0x10,%esi
  800143:	48 bf 18 13 80 00 00 	movabs $0x801318,%rdi
  80014a:	00 00 00 
  80014d:	b8 00 00 00 00       	mov    $0x0,%eax
  800152:	49 b8 2c 02 80 00 00 	movabs $0x80022c,%r8
  800159:	00 00 00 
  80015c:	41 ff d0             	callq  *%r8
  for (i = 0; i < ARRAYSIZE; i++)
  80015f:	b9 00 00 00 00       	mov    $0x0,%ecx
      panic("bigarray[%d] didn't hold its value!\n", i);
  800164:	48 ba a0 12 80 00 00 	movabs $0x8012a0,%rdx
  80016b:	00 00 00 
  80016e:	be 15 00 00 00       	mov    $0x15,%esi
  800173:	48 bf 18 13 80 00 00 	movabs $0x801318,%rdi
  80017a:	00 00 00 
  80017d:	b8 00 00 00 00       	mov    $0x0,%eax
  800182:	49 b8 2c 02 80 00 00 	movabs $0x80022c,%r8
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

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8001dc:	45 85 ed             	test   %r13d,%r13d
  8001df:	7e 0d                	jle    8001ee <libmain+0x5f>
    binaryname = argv[0];
  8001e1:	49 8b 06             	mov    (%r14),%rax
  8001e4:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8001eb:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8001ee:	4c 89 f6             	mov    %r14,%rsi
  8001f1:	44 89 ef             	mov    %r13d,%edi
  8001f4:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8001fb:	00 00 00 
  8001fe:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800200:	48 b8 15 02 80 00 00 	movabs $0x800215,%rax
  800207:	00 00 00 
  80020a:	ff d0                	callq  *%rax
#endif
}
  80020c:	5b                   	pop    %rbx
  80020d:	41 5c                	pop    %r12
  80020f:	41 5d                	pop    %r13
  800211:	41 5e                	pop    %r14
  800213:	5d                   	pop    %rbp
  800214:	c3                   	retq   

0000000000800215 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800215:	55                   	push   %rbp
  800216:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800219:	bf 00 00 00 00       	mov    $0x0,%edi
  80021e:	48 b8 00 12 80 00 00 	movabs $0x801200,%rax
  800225:	00 00 00 
  800228:	ff d0                	callq  *%rax
}
  80022a:	5d                   	pop    %rbp
  80022b:	c3                   	retq   

000000000080022c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80022c:	55                   	push   %rbp
  80022d:	48 89 e5             	mov    %rsp,%rbp
  800230:	41 56                	push   %r14
  800232:	41 55                	push   %r13
  800234:	41 54                	push   %r12
  800236:	53                   	push   %rbx
  800237:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80023e:	49 89 fd             	mov    %rdi,%r13
  800241:	41 89 f6             	mov    %esi,%r14d
  800244:	49 89 d4             	mov    %rdx,%r12
  800247:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80024e:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800255:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80025c:	84 c0                	test   %al,%al
  80025e:	74 26                	je     800286 <_panic+0x5a>
  800260:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800267:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80026e:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800272:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800276:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80027a:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80027e:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800282:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800286:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80028d:	00 00 00 
  800290:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800297:	00 00 00 
  80029a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80029e:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8002a5:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8002ac:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b3:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8002ba:	00 00 00 
  8002bd:	48 8b 18             	mov    (%rax),%rbx
  8002c0:	48 b8 60 12 80 00 00 	movabs $0x801260,%rax
  8002c7:	00 00 00 
  8002ca:	ff d0                	callq  *%rax
  8002cc:	45 89 f0             	mov    %r14d,%r8d
  8002cf:	4c 89 e9             	mov    %r13,%rcx
  8002d2:	48 89 da             	mov    %rbx,%rdx
  8002d5:	89 c6                	mov    %eax,%esi
  8002d7:	48 bf 48 13 80 00 00 	movabs $0x801348,%rdi
  8002de:	00 00 00 
  8002e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e6:	48 bb ce 03 80 00 00 	movabs $0x8003ce,%rbx
  8002ed:	00 00 00 
  8002f0:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8002f2:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002f9:	4c 89 e7             	mov    %r12,%rdi
  8002fc:	48 b8 66 03 80 00 00 	movabs $0x800366,%rax
  800303:	00 00 00 
  800306:	ff d0                	callq  *%rax
  cprintf("\n");
  800308:	48 bf 16 13 80 00 00 	movabs $0x801316,%rdi
  80030f:	00 00 00 
  800312:	b8 00 00 00 00       	mov    $0x0,%eax
  800317:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800319:	cc                   	int3   
  while (1)
  80031a:	eb fd                	jmp    800319 <_panic+0xed>

000000000080031c <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80031c:	55                   	push   %rbp
  80031d:	48 89 e5             	mov    %rsp,%rbp
  800320:	53                   	push   %rbx
  800321:	48 83 ec 08          	sub    $0x8,%rsp
  800325:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800328:	8b 06                	mov    (%rsi),%eax
  80032a:	8d 50 01             	lea    0x1(%rax),%edx
  80032d:	89 16                	mov    %edx,(%rsi)
  80032f:	48 98                	cltq   
  800331:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800336:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80033c:	74 0b                	je     800349 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80033e:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800342:	48 83 c4 08          	add    $0x8,%rsp
  800346:	5b                   	pop    %rbx
  800347:	5d                   	pop    %rbp
  800348:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800349:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80034d:	be ff 00 00 00       	mov    $0xff,%esi
  800352:	48 b8 c2 11 80 00 00 	movabs $0x8011c2,%rax
  800359:	00 00 00 
  80035c:	ff d0                	callq  *%rax
    b->idx = 0;
  80035e:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800364:	eb d8                	jmp    80033e <putch+0x22>

0000000000800366 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800366:	55                   	push   %rbp
  800367:	48 89 e5             	mov    %rsp,%rbp
  80036a:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800371:	48 89 fa             	mov    %rdi,%rdx
  800374:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800377:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80037e:	00 00 00 
  b.cnt = 0;
  800381:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800388:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80038b:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800392:	48 bf 1c 03 80 00 00 	movabs $0x80031c,%rdi
  800399:	00 00 00 
  80039c:	48 b8 8c 05 80 00 00 	movabs $0x80058c,%rax
  8003a3:	00 00 00 
  8003a6:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8003a8:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8003af:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8003b6:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8003ba:	48 b8 c2 11 80 00 00 	movabs $0x8011c2,%rax
  8003c1:	00 00 00 
  8003c4:	ff d0                	callq  *%rax

  return b.cnt;
}
  8003c6:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8003cc:	c9                   	leaveq 
  8003cd:	c3                   	retq   

00000000008003ce <cprintf>:

int
cprintf(const char *fmt, ...) {
  8003ce:	55                   	push   %rbp
  8003cf:	48 89 e5             	mov    %rsp,%rbp
  8003d2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003d9:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8003e0:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8003e7:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003ee:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003f5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003fc:	84 c0                	test   %al,%al
  8003fe:	74 20                	je     800420 <cprintf+0x52>
  800400:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800404:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800408:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80040c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800410:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800414:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800418:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80041c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800420:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800427:	00 00 00 
  80042a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800431:	00 00 00 
  800434:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800438:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80043f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800446:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80044d:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800454:	48 b8 66 03 80 00 00 	movabs $0x800366,%rax
  80045b:	00 00 00 
  80045e:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800460:	c9                   	leaveq 
  800461:	c3                   	retq   

0000000000800462 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800462:	55                   	push   %rbp
  800463:	48 89 e5             	mov    %rsp,%rbp
  800466:	41 57                	push   %r15
  800468:	41 56                	push   %r14
  80046a:	41 55                	push   %r13
  80046c:	41 54                	push   %r12
  80046e:	53                   	push   %rbx
  80046f:	48 83 ec 18          	sub    $0x18,%rsp
  800473:	49 89 fc             	mov    %rdi,%r12
  800476:	49 89 f5             	mov    %rsi,%r13
  800479:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80047d:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800480:	41 89 cf             	mov    %ecx,%r15d
  800483:	49 39 d7             	cmp    %rdx,%r15
  800486:	76 45                	jbe    8004cd <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800488:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7e 0e                	jle    80049e <printnum+0x3c>
      putch(padc, putdat);
  800490:	4c 89 ee             	mov    %r13,%rsi
  800493:	44 89 f7             	mov    %r14d,%edi
  800496:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800499:	83 eb 01             	sub    $0x1,%ebx
  80049c:	75 f2                	jne    800490 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80049e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	49 f7 f7             	div    %r15
  8004aa:	48 b8 6b 13 80 00 00 	movabs $0x80136b,%rax
  8004b1:	00 00 00 
  8004b4:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8004b8:	4c 89 ee             	mov    %r13,%rsi
  8004bb:	41 ff d4             	callq  *%r12
}
  8004be:	48 83 c4 18          	add    $0x18,%rsp
  8004c2:	5b                   	pop    %rbx
  8004c3:	41 5c                	pop    %r12
  8004c5:	41 5d                	pop    %r13
  8004c7:	41 5e                	pop    %r14
  8004c9:	41 5f                	pop    %r15
  8004cb:	5d                   	pop    %rbp
  8004cc:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8004cd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	49 f7 f7             	div    %r15
  8004d9:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8004dd:	48 89 c2             	mov    %rax,%rdx
  8004e0:	48 b8 62 04 80 00 00 	movabs $0x800462,%rax
  8004e7:	00 00 00 
  8004ea:	ff d0                	callq  *%rax
  8004ec:	eb b0                	jmp    80049e <printnum+0x3c>

00000000008004ee <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8004ee:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8004f2:	48 8b 06             	mov    (%rsi),%rax
  8004f5:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004f9:	73 0a                	jae    800505 <sprintputch+0x17>
    *b->buf++ = ch;
  8004fb:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004ff:	48 89 16             	mov    %rdx,(%rsi)
  800502:	40 88 38             	mov    %dil,(%rax)
}
  800505:	c3                   	retq   

0000000000800506 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800506:	55                   	push   %rbp
  800507:	48 89 e5             	mov    %rsp,%rbp
  80050a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800511:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800518:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80051f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800526:	84 c0                	test   %al,%al
  800528:	74 20                	je     80054a <printfmt+0x44>
  80052a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80052e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800532:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800536:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80053a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80053e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800542:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800546:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80054a:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800551:	00 00 00 
  800554:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80055b:	00 00 00 
  80055e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800562:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800569:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800570:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800577:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80057e:	48 b8 8c 05 80 00 00 	movabs $0x80058c,%rax
  800585:	00 00 00 
  800588:	ff d0                	callq  *%rax
}
  80058a:	c9                   	leaveq 
  80058b:	c3                   	retq   

000000000080058c <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80058c:	55                   	push   %rbp
  80058d:	48 89 e5             	mov    %rsp,%rbp
  800590:	41 57                	push   %r15
  800592:	41 56                	push   %r14
  800594:	41 55                	push   %r13
  800596:	41 54                	push   %r12
  800598:	53                   	push   %rbx
  800599:	48 83 ec 48          	sub    $0x48,%rsp
  80059d:	49 89 fd             	mov    %rdi,%r13
  8005a0:	49 89 f7             	mov    %rsi,%r15
  8005a3:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8005a6:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8005aa:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8005ae:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8005b2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005b6:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8005ba:	41 0f b6 3e          	movzbl (%r14),%edi
  8005be:	83 ff 25             	cmp    $0x25,%edi
  8005c1:	74 18                	je     8005db <vprintfmt+0x4f>
      if (ch == '\0')
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	0f 84 8c 06 00 00    	je     800c57 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8005cb:	4c 89 fe             	mov    %r15,%rsi
  8005ce:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005d1:	49 89 de             	mov    %rbx,%r14
  8005d4:	eb e0                	jmp    8005b6 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8005d6:	49 89 de             	mov    %rbx,%r14
  8005d9:	eb db                	jmp    8005b6 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8005db:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8005df:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8005e3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8005ea:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8005f0:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005f9:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005ff:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800605:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80060a:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80060f:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800613:	0f b6 13             	movzbl (%rbx),%edx
  800616:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800619:	3c 55                	cmp    $0x55,%al
  80061b:	0f 87 8b 05 00 00    	ja     800bac <vprintfmt+0x620>
  800621:	0f b6 c0             	movzbl %al,%eax
  800624:	49 bb 20 14 80 00 00 	movabs $0x801420,%r11
  80062b:	00 00 00 
  80062e:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800632:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800635:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800639:	eb d4                	jmp    80060f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80063b:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80063e:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800642:	eb cb                	jmp    80060f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800644:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800647:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80064b:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80064f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800652:	83 fa 09             	cmp    $0x9,%edx
  800655:	77 7e                	ja     8006d5 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800657:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80065b:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80065f:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800664:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800668:	8d 50 d0             	lea    -0x30(%rax),%edx
  80066b:	83 fa 09             	cmp    $0x9,%edx
  80066e:	76 e7                	jbe    800657 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800670:	4c 89 f3             	mov    %r14,%rbx
  800673:	eb 19                	jmp    80068e <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800675:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800678:	83 f8 2f             	cmp    $0x2f,%eax
  80067b:	77 2a                	ja     8006a7 <vprintfmt+0x11b>
  80067d:	89 c2                	mov    %eax,%edx
  80067f:	4c 01 d2             	add    %r10,%rdx
  800682:	83 c0 08             	add    $0x8,%eax
  800685:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800688:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80068b:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80068e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800692:	0f 89 77 ff ff ff    	jns    80060f <vprintfmt+0x83>
          width = precision, precision = -1;
  800698:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80069c:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8006a2:	e9 68 ff ff ff       	jmpq   80060f <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8006a7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006ab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006af:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006b3:	eb d3                	jmp    800688 <vprintfmt+0xfc>
        if (width < 0)
  8006b5:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	41 0f 48 c0          	cmovs  %r8d,%eax
  8006be:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8006c1:	4c 89 f3             	mov    %r14,%rbx
  8006c4:	e9 46 ff ff ff       	jmpq   80060f <vprintfmt+0x83>
  8006c9:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8006cc:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8006d0:	e9 3a ff ff ff       	jmpq   80060f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8006d5:	4c 89 f3             	mov    %r14,%rbx
  8006d8:	eb b4                	jmp    80068e <vprintfmt+0x102>
        lflag++;
  8006da:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8006dd:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8006e0:	e9 2a ff ff ff       	jmpq   80060f <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8006e5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006e8:	83 f8 2f             	cmp    $0x2f,%eax
  8006eb:	77 19                	ja     800706 <vprintfmt+0x17a>
  8006ed:	89 c2                	mov    %eax,%edx
  8006ef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006f3:	83 c0 08             	add    $0x8,%eax
  8006f6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006f9:	4c 89 fe             	mov    %r15,%rsi
  8006fc:	8b 3a                	mov    (%rdx),%edi
  8006fe:	41 ff d5             	callq  *%r13
        break;
  800701:	e9 b0 fe ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800706:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80070a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80070e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800712:	eb e5                	jmp    8006f9 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800714:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800717:	83 f8 2f             	cmp    $0x2f,%eax
  80071a:	77 5b                	ja     800777 <vprintfmt+0x1eb>
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800722:	83 c0 08             	add    $0x8,%eax
  800725:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800728:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80072a:	89 c8                	mov    %ecx,%eax
  80072c:	c1 f8 1f             	sar    $0x1f,%eax
  80072f:	31 c1                	xor    %eax,%ecx
  800731:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800733:	83 f9 09             	cmp    $0x9,%ecx
  800736:	7f 4d                	jg     800785 <vprintfmt+0x1f9>
  800738:	48 63 c1             	movslq %ecx,%rax
  80073b:	48 ba e0 16 80 00 00 	movabs $0x8016e0,%rdx
  800742:	00 00 00 
  800745:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800749:	48 85 c0             	test   %rax,%rax
  80074c:	74 37                	je     800785 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80074e:	48 89 c1             	mov    %rax,%rcx
  800751:	48 ba 8c 13 80 00 00 	movabs $0x80138c,%rdx
  800758:	00 00 00 
  80075b:	4c 89 fe             	mov    %r15,%rsi
  80075e:	4c 89 ef             	mov    %r13,%rdi
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	48 bb 06 05 80 00 00 	movabs $0x800506,%rbx
  80076d:	00 00 00 
  800770:	ff d3                	callq  *%rbx
  800772:	e9 3f fe ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800777:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80077b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80077f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800783:	eb a3                	jmp    800728 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800785:	48 ba 83 13 80 00 00 	movabs $0x801383,%rdx
  80078c:	00 00 00 
  80078f:	4c 89 fe             	mov    %r15,%rsi
  800792:	4c 89 ef             	mov    %r13,%rdi
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	48 bb 06 05 80 00 00 	movabs $0x800506,%rbx
  8007a1:	00 00 00 
  8007a4:	ff d3                	callq  *%rbx
  8007a6:	e9 0b fe ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8007ab:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007ae:	83 f8 2f             	cmp    $0x2f,%eax
  8007b1:	77 4b                	ja     8007fe <vprintfmt+0x272>
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007b9:	83 c0 08             	add    $0x8,%eax
  8007bc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007bf:	48 8b 02             	mov    (%rdx),%rax
  8007c2:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8007c6:	48 85 c0             	test   %rax,%rax
  8007c9:	0f 84 05 04 00 00    	je     800bd4 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8007cf:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8007d3:	7e 06                	jle    8007db <vprintfmt+0x24f>
  8007d5:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8007d9:	75 31                	jne    80080c <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007db:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007df:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007e3:	0f b6 00             	movzbl (%rax),%eax
  8007e6:	0f be f8             	movsbl %al,%edi
  8007e9:	85 ff                	test   %edi,%edi
  8007eb:	0f 84 c3 00 00 00    	je     8008b4 <vprintfmt+0x328>
  8007f1:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007f5:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007f9:	e9 85 00 00 00       	jmpq   800883 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007fe:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800802:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800806:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80080a:	eb b3                	jmp    8007bf <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80080c:	49 63 f4             	movslq %r12d,%rsi
  80080f:	48 89 c7             	mov    %rax,%rdi
  800812:	48 b8 63 0d 80 00 00 	movabs $0x800d63,%rax
  800819:	00 00 00 
  80081c:	ff d0                	callq  *%rax
  80081e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800821:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800824:	85 f6                	test   %esi,%esi
  800826:	7e 22                	jle    80084a <vprintfmt+0x2be>
            putch(padc, putdat);
  800828:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80082c:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800830:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800834:	4c 89 fe             	mov    %r15,%rsi
  800837:	89 df                	mov    %ebx,%edi
  800839:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80083c:	41 83 ec 01          	sub    $0x1,%r12d
  800840:	75 f2                	jne    800834 <vprintfmt+0x2a8>
  800842:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800846:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80084a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80084e:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800852:	0f b6 00             	movzbl (%rax),%eax
  800855:	0f be f8             	movsbl %al,%edi
  800858:	85 ff                	test   %edi,%edi
  80085a:	0f 84 56 fd ff ff    	je     8005b6 <vprintfmt+0x2a>
  800860:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800864:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800868:	eb 19                	jmp    800883 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80086a:	4c 89 fe             	mov    %r15,%rsi
  80086d:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800870:	41 83 ee 01          	sub    $0x1,%r14d
  800874:	48 83 c3 01          	add    $0x1,%rbx
  800878:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80087c:	0f be f8             	movsbl %al,%edi
  80087f:	85 ff                	test   %edi,%edi
  800881:	74 29                	je     8008ac <vprintfmt+0x320>
  800883:	45 85 e4             	test   %r12d,%r12d
  800886:	78 06                	js     80088e <vprintfmt+0x302>
  800888:	41 83 ec 01          	sub    $0x1,%r12d
  80088c:	78 48                	js     8008d6 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80088e:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800892:	74 d6                	je     80086a <vprintfmt+0x2de>
  800894:	0f be c0             	movsbl %al,%eax
  800897:	83 e8 20             	sub    $0x20,%eax
  80089a:	83 f8 5e             	cmp    $0x5e,%eax
  80089d:	76 cb                	jbe    80086a <vprintfmt+0x2de>
            putch('?', putdat);
  80089f:	4c 89 fe             	mov    %r15,%rsi
  8008a2:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8008a7:	41 ff d5             	callq  *%r13
  8008aa:	eb c4                	jmp    800870 <vprintfmt+0x2e4>
  8008ac:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008b0:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8008b4:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8008b7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008bb:	0f 8e f5 fc ff ff    	jle    8005b6 <vprintfmt+0x2a>
          putch(' ', putdat);
  8008c1:	4c 89 fe             	mov    %r15,%rsi
  8008c4:	bf 20 00 00 00       	mov    $0x20,%edi
  8008c9:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8008cc:	83 eb 01             	sub    $0x1,%ebx
  8008cf:	75 f0                	jne    8008c1 <vprintfmt+0x335>
  8008d1:	e9 e0 fc ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
  8008d6:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008da:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8008de:	eb d4                	jmp    8008b4 <vprintfmt+0x328>
  if (lflag >= 2)
  8008e0:	83 f9 01             	cmp    $0x1,%ecx
  8008e3:	7f 1d                	jg     800902 <vprintfmt+0x376>
  else if (lflag)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 5e                	je     800947 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8008e9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ec:	83 f8 2f             	cmp    $0x2f,%eax
  8008ef:	77 48                	ja     800939 <vprintfmt+0x3ad>
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f7:	83 c0 08             	add    $0x8,%eax
  8008fa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fd:	48 8b 1a             	mov    (%rdx),%rbx
  800900:	eb 17                	jmp    800919 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800902:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800905:	83 f8 2f             	cmp    $0x2f,%eax
  800908:	77 21                	ja     80092b <vprintfmt+0x39f>
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800910:	83 c0 08             	add    $0x8,%eax
  800913:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800916:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800919:	48 85 db             	test   %rbx,%rbx
  80091c:	78 50                	js     80096e <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80091e:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800921:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800926:	e9 b4 01 00 00       	jmpq   800adf <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80092b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80092f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800933:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800937:	eb dd                	jmp    800916 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800939:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80093d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800941:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800945:	eb b6                	jmp    8008fd <vprintfmt+0x371>
    return va_arg(*ap, int);
  800947:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094a:	83 f8 2f             	cmp    $0x2f,%eax
  80094d:	77 11                	ja     800960 <vprintfmt+0x3d4>
  80094f:	89 c2                	mov    %eax,%edx
  800951:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800955:	83 c0 08             	add    $0x8,%eax
  800958:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095b:	48 63 1a             	movslq (%rdx),%rbx
  80095e:	eb b9                	jmp    800919 <vprintfmt+0x38d>
  800960:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800964:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800968:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096c:	eb ed                	jmp    80095b <vprintfmt+0x3cf>
          putch('-', putdat);
  80096e:	4c 89 fe             	mov    %r15,%rsi
  800971:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800976:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800979:	48 89 da             	mov    %rbx,%rdx
  80097c:	48 f7 da             	neg    %rdx
        base = 10;
  80097f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800984:	e9 56 01 00 00       	jmpq   800adf <vprintfmt+0x553>
  if (lflag >= 2)
  800989:	83 f9 01             	cmp    $0x1,%ecx
  80098c:	7f 25                	jg     8009b3 <vprintfmt+0x427>
  else if (lflag)
  80098e:	85 c9                	test   %ecx,%ecx
  800990:	74 5e                	je     8009f0 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800992:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800995:	83 f8 2f             	cmp    $0x2f,%eax
  800998:	77 48                	ja     8009e2 <vprintfmt+0x456>
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a0:	83 c0 08             	add    $0x8,%eax
  8009a3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009a6:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ae:	e9 2c 01 00 00       	jmpq   800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009b3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b6:	83 f8 2f             	cmp    $0x2f,%eax
  8009b9:	77 19                	ja     8009d4 <vprintfmt+0x448>
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c1:	83 c0 08             	add    $0x8,%eax
  8009c4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009c7:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009cf:	e9 0b 01 00 00       	jmpq   800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009d4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009dc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e0:	eb e5                	jmp    8009c7 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8009e2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009e6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ea:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ee:	eb b6                	jmp    8009a6 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8009f0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f3:	83 f8 2f             	cmp    $0x2f,%eax
  8009f6:	77 18                	ja     800a10 <vprintfmt+0x484>
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009fe:	83 c0 08             	add    $0x8,%eax
  800a01:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a04:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800a06:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a0b:	e9 cf 00 00 00       	jmpq   800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a10:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a14:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a18:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a1c:	eb e6                	jmp    800a04 <vprintfmt+0x478>
  if (lflag >= 2)
  800a1e:	83 f9 01             	cmp    $0x1,%ecx
  800a21:	7f 25                	jg     800a48 <vprintfmt+0x4bc>
  else if (lflag)
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	74 5b                	je     800a82 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800a27:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a2a:	83 f8 2f             	cmp    $0x2f,%eax
  800a2d:	77 45                	ja     800a74 <vprintfmt+0x4e8>
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a35:	83 c0 08             	add    $0x8,%eax
  800a38:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a3b:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a3e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a43:	e9 97 00 00 00       	jmpq   800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a48:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a4b:	83 f8 2f             	cmp    $0x2f,%eax
  800a4e:	77 16                	ja     800a66 <vprintfmt+0x4da>
  800a50:	89 c2                	mov    %eax,%edx
  800a52:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a56:	83 c0 08             	add    $0x8,%eax
  800a59:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a5c:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a5f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a64:	eb 79                	jmp    800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a66:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a6a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a6e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a72:	eb e8                	jmp    800a5c <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a74:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a78:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a7c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a80:	eb b9                	jmp    800a3b <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a82:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a85:	83 f8 2f             	cmp    $0x2f,%eax
  800a88:	77 15                	ja     800a9f <vprintfmt+0x513>
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a90:	83 c0 08             	add    $0x8,%eax
  800a93:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a96:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a98:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a9d:	eb 40                	jmp    800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a9f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aa3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aa7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aab:	eb e9                	jmp    800a96 <vprintfmt+0x50a>
        putch('0', putdat);
  800aad:	4c 89 fe             	mov    %r15,%rsi
  800ab0:	bf 30 00 00 00       	mov    $0x30,%edi
  800ab5:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800ab8:	4c 89 fe             	mov    %r15,%rsi
  800abb:	bf 78 00 00 00       	mov    $0x78,%edi
  800ac0:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ac3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ac6:	83 f8 2f             	cmp    $0x2f,%eax
  800ac9:	77 34                	ja     800aff <vprintfmt+0x573>
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad1:	83 c0 08             	add    $0x8,%eax
  800ad4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ad7:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ada:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800adf:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800ae4:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800ae8:	4c 89 fe             	mov    %r15,%rsi
  800aeb:	4c 89 ef             	mov    %r13,%rdi
  800aee:	48 b8 62 04 80 00 00 	movabs $0x800462,%rax
  800af5:	00 00 00 
  800af8:	ff d0                	callq  *%rax
        break;
  800afa:	e9 b7 fa ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800aff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b03:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b0b:	eb ca                	jmp    800ad7 <vprintfmt+0x54b>
  if (lflag >= 2)
  800b0d:	83 f9 01             	cmp    $0x1,%ecx
  800b10:	7f 22                	jg     800b34 <vprintfmt+0x5a8>
  else if (lflag)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 58                	je     800b6e <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800b16:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b19:	83 f8 2f             	cmp    $0x2f,%eax
  800b1c:	77 42                	ja     800b60 <vprintfmt+0x5d4>
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b24:	83 c0 08             	add    $0x8,%eax
  800b27:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b2d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b32:	eb ab                	jmp    800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b34:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b37:	83 f8 2f             	cmp    $0x2f,%eax
  800b3a:	77 16                	ja     800b52 <vprintfmt+0x5c6>
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b42:	83 c0 08             	add    $0x8,%eax
  800b45:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b48:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b4b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b50:	eb 8d                	jmp    800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b52:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b56:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b5a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b5e:	eb e8                	jmp    800b48 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b60:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b64:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b68:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b6c:	eb bc                	jmp    800b2a <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b6e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b71:	83 f8 2f             	cmp    $0x2f,%eax
  800b74:	77 18                	ja     800b8e <vprintfmt+0x602>
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b7c:	83 c0 08             	add    $0x8,%eax
  800b7f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b82:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b84:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b89:	e9 51 ff ff ff       	jmpq   800adf <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b8e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b92:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b96:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b9a:	eb e6                	jmp    800b82 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b9c:	4c 89 fe             	mov    %r15,%rsi
  800b9f:	bf 25 00 00 00       	mov    $0x25,%edi
  800ba4:	41 ff d5             	callq  *%r13
        break;
  800ba7:	e9 0a fa ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
        putch('%', putdat);
  800bac:	4c 89 fe             	mov    %r15,%rsi
  800baf:	bf 25 00 00 00       	mov    $0x25,%edi
  800bb4:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800bb7:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800bbb:	0f 84 15 fa ff ff    	je     8005d6 <vprintfmt+0x4a>
  800bc1:	49 89 de             	mov    %rbx,%r14
  800bc4:	49 83 ee 01          	sub    $0x1,%r14
  800bc8:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800bcd:	75 f5                	jne    800bc4 <vprintfmt+0x638>
  800bcf:	e9 e2 f9 ff ff       	jmpq   8005b6 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800bd4:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800bd8:	74 06                	je     800be0 <vprintfmt+0x654>
  800bda:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800bde:	7f 21                	jg     800c01 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800be0:	bf 28 00 00 00       	mov    $0x28,%edi
  800be5:	48 bb 7d 13 80 00 00 	movabs $0x80137d,%rbx
  800bec:	00 00 00 
  800bef:	b8 28 00 00 00       	mov    $0x28,%eax
  800bf4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bf8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bfc:	e9 82 fc ff ff       	jmpq   800883 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800c01:	49 63 f4             	movslq %r12d,%rsi
  800c04:	48 bf 7c 13 80 00 00 	movabs $0x80137c,%rdi
  800c0b:	00 00 00 
  800c0e:	48 b8 63 0d 80 00 00 	movabs $0x800d63,%rax
  800c15:	00 00 00 
  800c18:	ff d0                	callq  *%rax
  800c1a:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800c1d:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800c20:	48 be 7c 13 80 00 00 	movabs $0x80137c,%rsi
  800c27:	00 00 00 
  800c2a:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	0f 8f f2 fb ff ff    	jg     800828 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c36:	48 bb 7d 13 80 00 00 	movabs $0x80137d,%rbx
  800c3d:	00 00 00 
  800c40:	b8 28 00 00 00       	mov    $0x28,%eax
  800c45:	bf 28 00 00 00       	mov    $0x28,%edi
  800c4a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c4e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c52:	e9 2c fc ff ff       	jmpq   800883 <vprintfmt+0x2f7>
}
  800c57:	48 83 c4 48          	add    $0x48,%rsp
  800c5b:	5b                   	pop    %rbx
  800c5c:	41 5c                	pop    %r12
  800c5e:	41 5d                	pop    %r13
  800c60:	41 5e                	pop    %r14
  800c62:	41 5f                	pop    %r15
  800c64:	5d                   	pop    %rbp
  800c65:	c3                   	retq   

0000000000800c66 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c66:	55                   	push   %rbp
  800c67:	48 89 e5             	mov    %rsp,%rbp
  800c6a:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c6e:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c72:	48 63 c6             	movslq %esi,%rax
  800c75:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c7a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c7e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c85:	48 85 ff             	test   %rdi,%rdi
  800c88:	74 2a                	je     800cb4 <vsnprintf+0x4e>
  800c8a:	85 f6                	test   %esi,%esi
  800c8c:	7e 26                	jle    800cb4 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c8e:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c92:	48 bf ee 04 80 00 00 	movabs $0x8004ee,%rdi
  800c99:	00 00 00 
  800c9c:	48 b8 8c 05 80 00 00 	movabs $0x80058c,%rax
  800ca3:	00 00 00 
  800ca6:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ca8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800cac:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800caf:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800cb2:	c9                   	leaveq 
  800cb3:	c3                   	retq   
    return -E_INVAL;
  800cb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cb9:	eb f7                	jmp    800cb2 <vsnprintf+0x4c>

0000000000800cbb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800cbb:	55                   	push   %rbp
  800cbc:	48 89 e5             	mov    %rsp,%rbp
  800cbf:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800cc6:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ccd:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800cd4:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800cdb:	84 c0                	test   %al,%al
  800cdd:	74 20                	je     800cff <snprintf+0x44>
  800cdf:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ce3:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800ce7:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800ceb:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800cef:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800cf3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800cf7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800cfb:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800cff:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800d06:	00 00 00 
  800d09:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800d10:	00 00 00 
  800d13:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800d17:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800d1e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800d25:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800d2c:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800d33:	48 b8 66 0c 80 00 00 	movabs $0x800c66,%rax
  800d3a:	00 00 00 
  800d3d:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800d3f:	c9                   	leaveq 
  800d40:	c3                   	retq   

0000000000800d41 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800d41:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d44:	74 17                	je     800d5d <strlen+0x1c>
  800d46:	48 89 fa             	mov    %rdi,%rdx
  800d49:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d4e:	29 f9                	sub    %edi,%ecx
    n++;
  800d50:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d53:	48 83 c2 01          	add    $0x1,%rdx
  800d57:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d5a:	75 f4                	jne    800d50 <strlen+0xf>
  800d5c:	c3                   	retq   
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d62:	c3                   	retq   

0000000000800d63 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d63:	48 85 f6             	test   %rsi,%rsi
  800d66:	74 24                	je     800d8c <strnlen+0x29>
  800d68:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d6b:	74 25                	je     800d92 <strnlen+0x2f>
  800d6d:	48 01 fe             	add    %rdi,%rsi
  800d70:	48 89 fa             	mov    %rdi,%rdx
  800d73:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d78:	29 f9                	sub    %edi,%ecx
    n++;
  800d7a:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d7d:	48 83 c2 01          	add    $0x1,%rdx
  800d81:	48 39 f2             	cmp    %rsi,%rdx
  800d84:	74 11                	je     800d97 <strnlen+0x34>
  800d86:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d89:	75 ef                	jne    800d7a <strnlen+0x17>
  800d8b:	c3                   	retq   
  800d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d91:	c3                   	retq   
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d97:	c3                   	retq   

0000000000800d98 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d98:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800da4:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800da7:	48 83 c2 01          	add    $0x1,%rdx
  800dab:	84 c9                	test   %cl,%cl
  800dad:	75 f1                	jne    800da0 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800daf:	c3                   	retq   

0000000000800db0 <strcat>:

char *
strcat(char *dst, const char *src) {
  800db0:	55                   	push   %rbp
  800db1:	48 89 e5             	mov    %rsp,%rbp
  800db4:	41 54                	push   %r12
  800db6:	53                   	push   %rbx
  800db7:	48 89 fb             	mov    %rdi,%rbx
  800dba:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800dbd:	48 b8 41 0d 80 00 00 	movabs $0x800d41,%rax
  800dc4:	00 00 00 
  800dc7:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800dc9:	48 63 f8             	movslq %eax,%rdi
  800dcc:	48 01 df             	add    %rbx,%rdi
  800dcf:	4c 89 e6             	mov    %r12,%rsi
  800dd2:	48 b8 98 0d 80 00 00 	movabs $0x800d98,%rax
  800dd9:	00 00 00 
  800ddc:	ff d0                	callq  *%rax
  return dst;
}
  800dde:	48 89 d8             	mov    %rbx,%rax
  800de1:	5b                   	pop    %rbx
  800de2:	41 5c                	pop    %r12
  800de4:	5d                   	pop    %rbp
  800de5:	c3                   	retq   

0000000000800de6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800de6:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800de9:	48 85 d2             	test   %rdx,%rdx
  800dec:	74 1f                	je     800e0d <strncpy+0x27>
  800dee:	48 01 fa             	add    %rdi,%rdx
  800df1:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800df4:	48 83 c1 01          	add    $0x1,%rcx
  800df8:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dfc:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800e00:	41 80 f8 01          	cmp    $0x1,%r8b
  800e04:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800e08:	48 39 ca             	cmp    %rcx,%rdx
  800e0b:	75 e7                	jne    800df4 <strncpy+0xe>
  }
  return ret;
}
  800e0d:	c3                   	retq   

0000000000800e0e <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800e0e:	48 89 f8             	mov    %rdi,%rax
  800e11:	48 85 d2             	test   %rdx,%rdx
  800e14:	74 36                	je     800e4c <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800e16:	48 83 fa 01          	cmp    $0x1,%rdx
  800e1a:	74 2d                	je     800e49 <strlcpy+0x3b>
  800e1c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e20:	45 84 c0             	test   %r8b,%r8b
  800e23:	74 24                	je     800e49 <strlcpy+0x3b>
  800e25:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800e29:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800e2e:	48 83 c0 01          	add    $0x1,%rax
  800e32:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800e36:	48 39 d1             	cmp    %rdx,%rcx
  800e39:	74 0e                	je     800e49 <strlcpy+0x3b>
  800e3b:	48 83 c1 01          	add    $0x1,%rcx
  800e3f:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800e44:	45 84 c0             	test   %r8b,%r8b
  800e47:	75 e5                	jne    800e2e <strlcpy+0x20>
    *dst = '\0';
  800e49:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800e4c:	48 29 f8             	sub    %rdi,%rax
}
  800e4f:	c3                   	retq   

0000000000800e50 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e50:	0f b6 07             	movzbl (%rdi),%eax
  800e53:	84 c0                	test   %al,%al
  800e55:	74 17                	je     800e6e <strcmp+0x1e>
  800e57:	3a 06                	cmp    (%rsi),%al
  800e59:	75 13                	jne    800e6e <strcmp+0x1e>
    p++, q++;
  800e5b:	48 83 c7 01          	add    $0x1,%rdi
  800e5f:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e63:	0f b6 07             	movzbl (%rdi),%eax
  800e66:	84 c0                	test   %al,%al
  800e68:	74 04                	je     800e6e <strcmp+0x1e>
  800e6a:	3a 06                	cmp    (%rsi),%al
  800e6c:	74 ed                	je     800e5b <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e6e:	0f b6 c0             	movzbl %al,%eax
  800e71:	0f b6 16             	movzbl (%rsi),%edx
  800e74:	29 d0                	sub    %edx,%eax
}
  800e76:	c3                   	retq   

0000000000800e77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e77:	48 85 d2             	test   %rdx,%rdx
  800e7a:	74 2f                	je     800eab <strncmp+0x34>
  800e7c:	0f b6 07             	movzbl (%rdi),%eax
  800e7f:	84 c0                	test   %al,%al
  800e81:	74 1f                	je     800ea2 <strncmp+0x2b>
  800e83:	3a 06                	cmp    (%rsi),%al
  800e85:	75 1b                	jne    800ea2 <strncmp+0x2b>
  800e87:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e8a:	48 83 c7 01          	add    $0x1,%rdi
  800e8e:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e92:	48 39 d7             	cmp    %rdx,%rdi
  800e95:	74 1a                	je     800eb1 <strncmp+0x3a>
  800e97:	0f b6 07             	movzbl (%rdi),%eax
  800e9a:	84 c0                	test   %al,%al
  800e9c:	74 04                	je     800ea2 <strncmp+0x2b>
  800e9e:	3a 06                	cmp    (%rsi),%al
  800ea0:	74 e8                	je     800e8a <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ea2:	0f b6 07             	movzbl (%rdi),%eax
  800ea5:	0f b6 16             	movzbl (%rsi),%edx
  800ea8:	29 d0                	sub    %edx,%eax
}
  800eaa:	c3                   	retq   
    return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	c3                   	retq   
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	c3                   	retq   

0000000000800eb7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800eb7:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800eb9:	0f b6 07             	movzbl (%rdi),%eax
  800ebc:	84 c0                	test   %al,%al
  800ebe:	74 1e                	je     800ede <strchr+0x27>
    if (*s == c)
  800ec0:	40 38 c6             	cmp    %al,%sil
  800ec3:	74 1f                	je     800ee4 <strchr+0x2d>
  for (; *s; s++)
  800ec5:	48 83 c7 01          	add    $0x1,%rdi
  800ec9:	0f b6 07             	movzbl (%rdi),%eax
  800ecc:	84 c0                	test   %al,%al
  800ece:	74 08                	je     800ed8 <strchr+0x21>
    if (*s == c)
  800ed0:	38 d0                	cmp    %dl,%al
  800ed2:	75 f1                	jne    800ec5 <strchr+0xe>
  for (; *s; s++)
  800ed4:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ed7:	c3                   	retq   
  return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	c3                   	retq   
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	c3                   	retq   
    if (*s == c)
  800ee4:	48 89 f8             	mov    %rdi,%rax
  800ee7:	c3                   	retq   

0000000000800ee8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ee8:	48 89 f8             	mov    %rdi,%rax
  800eeb:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800eed:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800ef0:	40 38 f2             	cmp    %sil,%dl
  800ef3:	74 13                	je     800f08 <strfind+0x20>
  800ef5:	84 d2                	test   %dl,%dl
  800ef7:	74 0f                	je     800f08 <strfind+0x20>
  for (; *s; s++)
  800ef9:	48 83 c0 01          	add    $0x1,%rax
  800efd:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800f00:	38 ca                	cmp    %cl,%dl
  800f02:	74 04                	je     800f08 <strfind+0x20>
  800f04:	84 d2                	test   %dl,%dl
  800f06:	75 f1                	jne    800ef9 <strfind+0x11>
      break;
  return (char *)s;
}
  800f08:	c3                   	retq   

0000000000800f09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800f09:	48 85 d2             	test   %rdx,%rdx
  800f0c:	74 3a                	je     800f48 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f0e:	48 89 f8             	mov    %rdi,%rax
  800f11:	48 09 d0             	or     %rdx,%rax
  800f14:	a8 03                	test   $0x3,%al
  800f16:	75 28                	jne    800f40 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800f18:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800f1c:	89 f0                	mov    %esi,%eax
  800f1e:	c1 e0 08             	shl    $0x8,%eax
  800f21:	89 f1                	mov    %esi,%ecx
  800f23:	c1 e1 18             	shl    $0x18,%ecx
  800f26:	41 89 f0             	mov    %esi,%r8d
  800f29:	41 c1 e0 10          	shl    $0x10,%r8d
  800f2d:	44 09 c1             	or     %r8d,%ecx
  800f30:	09 ce                	or     %ecx,%esi
  800f32:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800f34:	48 c1 ea 02          	shr    $0x2,%rdx
  800f38:	48 89 d1             	mov    %rdx,%rcx
  800f3b:	fc                   	cld    
  800f3c:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f3e:	eb 08                	jmp    800f48 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	48 89 d1             	mov    %rdx,%rcx
  800f45:	fc                   	cld    
  800f46:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800f48:	48 89 f8             	mov    %rdi,%rax
  800f4b:	c3                   	retq   

0000000000800f4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800f4c:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f4f:	48 39 fe             	cmp    %rdi,%rsi
  800f52:	73 40                	jae    800f94 <memmove+0x48>
  800f54:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f58:	48 39 f9             	cmp    %rdi,%rcx
  800f5b:	76 37                	jbe    800f94 <memmove+0x48>
    s += n;
    d += n;
  800f5d:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f61:	48 89 fe             	mov    %rdi,%rsi
  800f64:	48 09 d6             	or     %rdx,%rsi
  800f67:	48 09 ce             	or     %rcx,%rsi
  800f6a:	40 f6 c6 03          	test   $0x3,%sil
  800f6e:	75 14                	jne    800f84 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f70:	48 83 ef 04          	sub    $0x4,%rdi
  800f74:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f78:	48 c1 ea 02          	shr    $0x2,%rdx
  800f7c:	48 89 d1             	mov    %rdx,%rcx
  800f7f:	fd                   	std    
  800f80:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f82:	eb 0e                	jmp    800f92 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f84:	48 83 ef 01          	sub    $0x1,%rdi
  800f88:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f8c:	48 89 d1             	mov    %rdx,%rcx
  800f8f:	fd                   	std    
  800f90:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f92:	fc                   	cld    
  800f93:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f94:	48 89 c1             	mov    %rax,%rcx
  800f97:	48 09 d1             	or     %rdx,%rcx
  800f9a:	48 09 f1             	or     %rsi,%rcx
  800f9d:	f6 c1 03             	test   $0x3,%cl
  800fa0:	75 0e                	jne    800fb0 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800fa2:	48 c1 ea 02          	shr    $0x2,%rdx
  800fa6:	48 89 d1             	mov    %rdx,%rcx
  800fa9:	48 89 c7             	mov    %rax,%rdi
  800fac:	fc                   	cld    
  800fad:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800faf:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800fb0:	48 89 c7             	mov    %rax,%rdi
  800fb3:	48 89 d1             	mov    %rdx,%rcx
  800fb6:	fc                   	cld    
  800fb7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800fb9:	c3                   	retq   

0000000000800fba <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800fba:	55                   	push   %rbp
  800fbb:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800fbe:	48 b8 4c 0f 80 00 00 	movabs $0x800f4c,%rax
  800fc5:	00 00 00 
  800fc8:	ff d0                	callq  *%rax
}
  800fca:	5d                   	pop    %rbp
  800fcb:	c3                   	retq   

0000000000800fcc <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800fcc:	55                   	push   %rbp
  800fcd:	48 89 e5             	mov    %rsp,%rbp
  800fd0:	41 57                	push   %r15
  800fd2:	41 56                	push   %r14
  800fd4:	41 55                	push   %r13
  800fd6:	41 54                	push   %r12
  800fd8:	53                   	push   %rbx
  800fd9:	48 83 ec 08          	sub    $0x8,%rsp
  800fdd:	49 89 fe             	mov    %rdi,%r14
  800fe0:	49 89 f7             	mov    %rsi,%r15
  800fe3:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800fe6:	48 89 f7             	mov    %rsi,%rdi
  800fe9:	48 b8 41 0d 80 00 00 	movabs $0x800d41,%rax
  800ff0:	00 00 00 
  800ff3:	ff d0                	callq  *%rax
  800ff5:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800ff8:	4c 89 ee             	mov    %r13,%rsi
  800ffb:	4c 89 f7             	mov    %r14,%rdi
  800ffe:	48 b8 63 0d 80 00 00 	movabs $0x800d63,%rax
  801005:	00 00 00 
  801008:	ff d0                	callq  *%rax
  80100a:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80100d:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801011:	4d 39 e5             	cmp    %r12,%r13
  801014:	74 26                	je     80103c <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801016:	4c 89 e8             	mov    %r13,%rax
  801019:	4c 29 e0             	sub    %r12,%rax
  80101c:	48 39 d8             	cmp    %rbx,%rax
  80101f:	76 2a                	jbe    80104b <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801021:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801025:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801029:	4c 89 fe             	mov    %r15,%rsi
  80102c:	48 b8 ba 0f 80 00 00 	movabs $0x800fba,%rax
  801033:	00 00 00 
  801036:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801038:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80103c:	48 83 c4 08          	add    $0x8,%rsp
  801040:	5b                   	pop    %rbx
  801041:	41 5c                	pop    %r12
  801043:	41 5d                	pop    %r13
  801045:	41 5e                	pop    %r14
  801047:	41 5f                	pop    %r15
  801049:	5d                   	pop    %rbp
  80104a:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80104b:	49 83 ed 01          	sub    $0x1,%r13
  80104f:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801053:	4c 89 ea             	mov    %r13,%rdx
  801056:	4c 89 fe             	mov    %r15,%rsi
  801059:	48 b8 ba 0f 80 00 00 	movabs $0x800fba,%rax
  801060:	00 00 00 
  801063:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801065:	4d 01 ee             	add    %r13,%r14
  801068:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80106d:	eb c9                	jmp    801038 <strlcat+0x6c>

000000000080106f <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80106f:	48 85 d2             	test   %rdx,%rdx
  801072:	74 3a                	je     8010ae <memcmp+0x3f>
    if (*s1 != *s2)
  801074:	0f b6 0f             	movzbl (%rdi),%ecx
  801077:	44 0f b6 06          	movzbl (%rsi),%r8d
  80107b:	44 38 c1             	cmp    %r8b,%cl
  80107e:	75 1d                	jne    80109d <memcmp+0x2e>
  801080:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801085:	48 39 d0             	cmp    %rdx,%rax
  801088:	74 1e                	je     8010a8 <memcmp+0x39>
    if (*s1 != *s2)
  80108a:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80108e:	48 83 c0 01          	add    $0x1,%rax
  801092:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801098:	44 38 c1             	cmp    %r8b,%cl
  80109b:	74 e8                	je     801085 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80109d:	0f b6 c1             	movzbl %cl,%eax
  8010a0:	45 0f b6 c0          	movzbl %r8b,%r8d
  8010a4:	44 29 c0             	sub    %r8d,%eax
  8010a7:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	c3                   	retq   
  8010ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b3:	c3                   	retq   

00000000008010b4 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8010b4:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8010b8:	48 39 c7             	cmp    %rax,%rdi
  8010bb:	73 19                	jae    8010d6 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010bd:	89 f2                	mov    %esi,%edx
  8010bf:	40 38 37             	cmp    %sil,(%rdi)
  8010c2:	74 16                	je     8010da <memfind+0x26>
  for (; s < ends; s++)
  8010c4:	48 83 c7 01          	add    $0x1,%rdi
  8010c8:	48 39 f8             	cmp    %rdi,%rax
  8010cb:	74 08                	je     8010d5 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010cd:	38 17                	cmp    %dl,(%rdi)
  8010cf:	75 f3                	jne    8010c4 <memfind+0x10>
  for (; s < ends; s++)
  8010d1:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8010d4:	c3                   	retq   
  8010d5:	c3                   	retq   
  for (; s < ends; s++)
  8010d6:	48 89 f8             	mov    %rdi,%rax
  8010d9:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8010da:	48 89 f8             	mov    %rdi,%rax
  8010dd:	c3                   	retq   

00000000008010de <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8010de:	0f b6 07             	movzbl (%rdi),%eax
  8010e1:	3c 20                	cmp    $0x20,%al
  8010e3:	74 04                	je     8010e9 <strtol+0xb>
  8010e5:	3c 09                	cmp    $0x9,%al
  8010e7:	75 0f                	jne    8010f8 <strtol+0x1a>
    s++;
  8010e9:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  8010ed:	0f b6 07             	movzbl (%rdi),%eax
  8010f0:	3c 20                	cmp    $0x20,%al
  8010f2:	74 f5                	je     8010e9 <strtol+0xb>
  8010f4:	3c 09                	cmp    $0x9,%al
  8010f6:	74 f1                	je     8010e9 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010f8:	3c 2b                	cmp    $0x2b,%al
  8010fa:	74 2b                	je     801127 <strtol+0x49>
  int neg  = 0;
  8010fc:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801102:	3c 2d                	cmp    $0x2d,%al
  801104:	74 2d                	je     801133 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801106:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80110c:	75 0f                	jne    80111d <strtol+0x3f>
  80110e:	80 3f 30             	cmpb   $0x30,(%rdi)
  801111:	74 2c                	je     80113f <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801113:	85 d2                	test   %edx,%edx
  801115:	b8 0a 00 00 00       	mov    $0xa,%eax
  80111a:	0f 44 d0             	cmove  %eax,%edx
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801122:	4c 63 d2             	movslq %edx,%r10
  801125:	eb 5c                	jmp    801183 <strtol+0xa5>
    s++;
  801127:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80112b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801131:	eb d3                	jmp    801106 <strtol+0x28>
    s++, neg = 1;
  801133:	48 83 c7 01          	add    $0x1,%rdi
  801137:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80113d:	eb c7                	jmp    801106 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80113f:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801143:	74 0f                	je     801154 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801145:	85 d2                	test   %edx,%edx
  801147:	75 d4                	jne    80111d <strtol+0x3f>
    s++, base = 8;
  801149:	48 83 c7 01          	add    $0x1,%rdi
  80114d:	ba 08 00 00 00       	mov    $0x8,%edx
  801152:	eb c9                	jmp    80111d <strtol+0x3f>
    s += 2, base = 16;
  801154:	48 83 c7 02          	add    $0x2,%rdi
  801158:	ba 10 00 00 00       	mov    $0x10,%edx
  80115d:	eb be                	jmp    80111d <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80115f:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801163:	41 80 f8 19          	cmp    $0x19,%r8b
  801167:	77 2f                	ja     801198 <strtol+0xba>
      dig = *s - 'a' + 10;
  801169:	44 0f be c1          	movsbl %cl,%r8d
  80116d:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801171:	39 d1                	cmp    %edx,%ecx
  801173:	7d 37                	jge    8011ac <strtol+0xce>
    s++, val = (val * base) + dig;
  801175:	48 83 c7 01          	add    $0x1,%rdi
  801179:	49 0f af c2          	imul   %r10,%rax
  80117d:	48 63 c9             	movslq %ecx,%rcx
  801180:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801183:	0f b6 0f             	movzbl (%rdi),%ecx
  801186:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80118a:	41 80 f8 09          	cmp    $0x9,%r8b
  80118e:	77 cf                	ja     80115f <strtol+0x81>
      dig = *s - '0';
  801190:	0f be c9             	movsbl %cl,%ecx
  801193:	83 e9 30             	sub    $0x30,%ecx
  801196:	eb d9                	jmp    801171 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801198:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80119c:	41 80 f8 19          	cmp    $0x19,%r8b
  8011a0:	77 0a                	ja     8011ac <strtol+0xce>
      dig = *s - 'A' + 10;
  8011a2:	44 0f be c1          	movsbl %cl,%r8d
  8011a6:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8011aa:	eb c5                	jmp    801171 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8011ac:	48 85 f6             	test   %rsi,%rsi
  8011af:	74 03                	je     8011b4 <strtol+0xd6>
    *endptr = (char *)s;
  8011b1:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8011b4:	48 89 c2             	mov    %rax,%rdx
  8011b7:	48 f7 da             	neg    %rdx
  8011ba:	45 85 c9             	test   %r9d,%r9d
  8011bd:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8011c1:	c3                   	retq   

00000000008011c2 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8011c2:	55                   	push   %rbp
  8011c3:	48 89 e5             	mov    %rsp,%rbp
  8011c6:	53                   	push   %rbx
  8011c7:	48 89 fa             	mov    %rdi,%rdx
  8011ca:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	48 89 c3             	mov    %rax,%rbx
  8011d5:	48 89 c7             	mov    %rax,%rdi
  8011d8:	48 89 c6             	mov    %rax,%rsi
  8011db:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8011dd:	5b                   	pop    %rbx
  8011de:	5d                   	pop    %rbp
  8011df:	c3                   	retq   

00000000008011e0 <sys_cgetc>:

int
sys_cgetc(void) {
  8011e0:	55                   	push   %rbp
  8011e1:	48 89 e5             	mov    %rsp,%rbp
  8011e4:	53                   	push   %rbx
  asm volatile("int %1\n"
  8011e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ef:	48 89 ca             	mov    %rcx,%rdx
  8011f2:	48 89 cb             	mov    %rcx,%rbx
  8011f5:	48 89 cf             	mov    %rcx,%rdi
  8011f8:	48 89 ce             	mov    %rcx,%rsi
  8011fb:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011fd:	5b                   	pop    %rbx
  8011fe:	5d                   	pop    %rbp
  8011ff:	c3                   	retq   

0000000000801200 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801200:	55                   	push   %rbp
  801201:	48 89 e5             	mov    %rsp,%rbp
  801204:	53                   	push   %rbx
  801205:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801209:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80120c:	be 00 00 00 00       	mov    $0x0,%esi
  801211:	b8 03 00 00 00       	mov    $0x3,%eax
  801216:	48 89 f1             	mov    %rsi,%rcx
  801219:	48 89 f3             	mov    %rsi,%rbx
  80121c:	48 89 f7             	mov    %rsi,%rdi
  80121f:	cd 30                	int    $0x30
  if (check && ret > 0)
  801221:	48 85 c0             	test   %rax,%rax
  801224:	7f 07                	jg     80122d <sys_env_destroy+0x2d>
}
  801226:	48 83 c4 08          	add    $0x8,%rsp
  80122a:	5b                   	pop    %rbx
  80122b:	5d                   	pop    %rbp
  80122c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80122d:	49 89 c0             	mov    %rax,%r8
  801230:	b9 03 00 00 00       	mov    $0x3,%ecx
  801235:	48 ba 30 17 80 00 00 	movabs $0x801730,%rdx
  80123c:	00 00 00 
  80123f:	be 22 00 00 00       	mov    $0x22,%esi
  801244:	48 bf 50 17 80 00 00 	movabs $0x801750,%rdi
  80124b:	00 00 00 
  80124e:	b8 00 00 00 00       	mov    $0x0,%eax
  801253:	49 b9 2c 02 80 00 00 	movabs $0x80022c,%r9
  80125a:	00 00 00 
  80125d:	41 ff d1             	callq  *%r9

0000000000801260 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801260:	55                   	push   %rbp
  801261:	48 89 e5             	mov    %rsp,%rbp
  801264:	53                   	push   %rbx
  asm volatile("int %1\n"
  801265:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126a:	b8 02 00 00 00       	mov    $0x2,%eax
  80126f:	48 89 ca             	mov    %rcx,%rdx
  801272:	48 89 cb             	mov    %rcx,%rbx
  801275:	48 89 cf             	mov    %rcx,%rdi
  801278:	48 89 ce             	mov    %rcx,%rsi
  80127b:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80127d:	5b                   	pop    %rbx
  80127e:	5d                   	pop    %rbp
  80127f:	c3                   	retq   
