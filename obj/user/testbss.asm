
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
  80002e:	48 bf 40 15 80 00 00 	movabs $0x801540,%rdi
  800035:	00 00 00 
  800038:	b8 00 00 00 00       	mov    $0x0,%eax
  80003d:	48 ba fe 03 80 00 00 	movabs $0x8003fe,%rdx
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
  8000da:	48 bf 88 15 80 00 00 	movabs $0x801588,%rdi
  8000e1:	00 00 00 
  8000e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e9:	48 ba fe 03 80 00 00 	movabs $0x8003fe,%rdx
  8000f0:	00 00 00 
  8000f3:	ff d2                	callq  *%rdx
  // Accessing via subscript operator ([]) will result in -Warray-bounds warning.
  *((volatile uint32_t *)bigarray + ARRAYSIZE + 0x800000) = 0;
  8000f5:	48 b8 20 20 c0 02 00 	movabs $0x2c02020,%rax
  8000fc:	00 00 00 
  8000ff:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  panic("SHOULD HAVE TRAPPED!!!");
  800105:	48 ba e7 15 80 00 00 	movabs $0x8015e7,%rdx
  80010c:	00 00 00 
  80010f:	be 1a 00 00 00       	mov    $0x1a,%esi
  800114:	48 bf d8 15 80 00 00 	movabs $0x8015d8,%rdi
  80011b:	00 00 00 
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	48 b9 5c 02 80 00 00 	movabs $0x80025c,%rcx
  80012a:	00 00 00 
  80012d:	ff d1                	callq  *%rcx
  for (i = 0; i < ARRAYSIZE; i++)
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
      panic("bigarray[%d] isn't cleared!\n", i);
  800134:	48 ba bb 15 80 00 00 	movabs $0x8015bb,%rdx
  80013b:	00 00 00 
  80013e:	be 10 00 00 00       	mov    $0x10,%esi
  800143:	48 bf d8 15 80 00 00 	movabs $0x8015d8,%rdi
  80014a:	00 00 00 
  80014d:	b8 00 00 00 00       	mov    $0x0,%eax
  800152:	49 b8 5c 02 80 00 00 	movabs $0x80025c,%r8
  800159:	00 00 00 
  80015c:	41 ff d0             	callq  *%r8
  for (i = 0; i < ARRAYSIZE; i++)
  80015f:	b9 00 00 00 00       	mov    $0x0,%ecx
      panic("bigarray[%d] didn't hold its value!\n", i);
  800164:	48 ba 60 15 80 00 00 	movabs $0x801560,%rdx
  80016b:	00 00 00 
  80016e:	be 15 00 00 00       	mov    $0x15,%esi
  800173:	48 bf d8 15 80 00 00 	movabs $0x8015d8,%rdi
  80017a:	00 00 00 
  80017d:	b8 00 00 00 00       	mov    $0x0,%eax
  800182:	49 b8 5c 02 80 00 00 	movabs $0x80025c,%r8
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8001dc:	48 b8 90 12 80 00 00 	movabs $0x801290,%rax
  8001e3:	00 00 00 
  8001e6:	ff d0                	callq  *%rax
  8001e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ed:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8001f1:	48 c1 e0 05          	shl    $0x5,%rax
  8001f5:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8001fc:	00 00 00 
  8001ff:	48 01 d0             	add    %rdx,%rax
  800202:	48 a3 20 20 c0 00 00 	movabs %rax,0xc02020
  800209:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80020c:	45 85 ed             	test   %r13d,%r13d
  80020f:	7e 0d                	jle    80021e <libmain+0x8f>
    binaryname = argv[0];
  800211:	49 8b 06             	mov    (%r14),%rax
  800214:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  80021b:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80021e:	4c 89 f6             	mov    %r14,%rsi
  800221:	44 89 ef             	mov    %r13d,%edi
  800224:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  80022b:	00 00 00 
  80022e:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800230:	48 b8 45 02 80 00 00 	movabs $0x800245,%rax
  800237:	00 00 00 
  80023a:	ff d0                	callq  *%rax
#endif
}
  80023c:	5b                   	pop    %rbx
  80023d:	41 5c                	pop    %r12
  80023f:	41 5d                	pop    %r13
  800241:	41 5e                	pop    %r14
  800243:	5d                   	pop    %rbp
  800244:	c3                   	retq   

0000000000800245 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800245:	55                   	push   %rbp
  800246:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800249:	bf 00 00 00 00       	mov    $0x0,%edi
  80024e:	48 b8 30 12 80 00 00 	movabs $0x801230,%rax
  800255:	00 00 00 
  800258:	ff d0                	callq  *%rax
}
  80025a:	5d                   	pop    %rbp
  80025b:	c3                   	retq   

000000000080025c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80025c:	55                   	push   %rbp
  80025d:	48 89 e5             	mov    %rsp,%rbp
  800260:	41 56                	push   %r14
  800262:	41 55                	push   %r13
  800264:	41 54                	push   %r12
  800266:	53                   	push   %rbx
  800267:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80026e:	49 89 fd             	mov    %rdi,%r13
  800271:	41 89 f6             	mov    %esi,%r14d
  800274:	49 89 d4             	mov    %rdx,%r12
  800277:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80027e:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800285:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80028c:	84 c0                	test   %al,%al
  80028e:	74 26                	je     8002b6 <_panic+0x5a>
  800290:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800297:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80029e:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8002a2:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8002a6:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8002aa:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8002ae:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8002b2:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8002b6:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8002bd:	00 00 00 
  8002c0:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8002c7:	00 00 00 
  8002ca:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002ce:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8002d5:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8002dc:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8002e3:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8002ea:	00 00 00 
  8002ed:	48 8b 18             	mov    (%rax),%rbx
  8002f0:	48 b8 90 12 80 00 00 	movabs $0x801290,%rax
  8002f7:	00 00 00 
  8002fa:	ff d0                	callq  *%rax
  8002fc:	45 89 f0             	mov    %r14d,%r8d
  8002ff:	4c 89 e9             	mov    %r13,%rcx
  800302:	48 89 da             	mov    %rbx,%rdx
  800305:	89 c6                	mov    %eax,%esi
  800307:	48 bf 08 16 80 00 00 	movabs $0x801608,%rdi
  80030e:	00 00 00 
  800311:	b8 00 00 00 00       	mov    $0x0,%eax
  800316:	48 bb fe 03 80 00 00 	movabs $0x8003fe,%rbx
  80031d:	00 00 00 
  800320:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800322:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800329:	4c 89 e7             	mov    %r12,%rdi
  80032c:	48 b8 96 03 80 00 00 	movabs $0x800396,%rax
  800333:	00 00 00 
  800336:	ff d0                	callq  *%rax
  cprintf("\n");
  800338:	48 bf d6 15 80 00 00 	movabs $0x8015d6,%rdi
  80033f:	00 00 00 
  800342:	b8 00 00 00 00       	mov    $0x0,%eax
  800347:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800349:	cc                   	int3   
  while (1)
  80034a:	eb fd                	jmp    800349 <_panic+0xed>

000000000080034c <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80034c:	55                   	push   %rbp
  80034d:	48 89 e5             	mov    %rsp,%rbp
  800350:	53                   	push   %rbx
  800351:	48 83 ec 08          	sub    $0x8,%rsp
  800355:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800358:	8b 06                	mov    (%rsi),%eax
  80035a:	8d 50 01             	lea    0x1(%rax),%edx
  80035d:	89 16                	mov    %edx,(%rsi)
  80035f:	48 98                	cltq   
  800361:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800366:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80036c:	74 0b                	je     800379 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80036e:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800372:	48 83 c4 08          	add    $0x8,%rsp
  800376:	5b                   	pop    %rbx
  800377:	5d                   	pop    %rbp
  800378:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800379:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80037d:	be ff 00 00 00       	mov    $0xff,%esi
  800382:	48 b8 f2 11 80 00 00 	movabs $0x8011f2,%rax
  800389:	00 00 00 
  80038c:	ff d0                	callq  *%rax
    b->idx = 0;
  80038e:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800394:	eb d8                	jmp    80036e <putch+0x22>

0000000000800396 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800396:	55                   	push   %rbp
  800397:	48 89 e5             	mov    %rsp,%rbp
  80039a:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8003a1:	48 89 fa             	mov    %rdi,%rdx
  8003a4:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8003a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8003ae:	00 00 00 
  b.cnt = 0;
  8003b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8003b8:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8003bb:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8003c2:	48 bf 4c 03 80 00 00 	movabs $0x80034c,%rdi
  8003c9:	00 00 00 
  8003cc:	48 b8 bc 05 80 00 00 	movabs $0x8005bc,%rax
  8003d3:	00 00 00 
  8003d6:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8003d8:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8003df:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8003e6:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8003ea:	48 b8 f2 11 80 00 00 	movabs $0x8011f2,%rax
  8003f1:	00 00 00 
  8003f4:	ff d0                	callq  *%rax

  return b.cnt;
}
  8003f6:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8003fc:	c9                   	leaveq 
  8003fd:	c3                   	retq   

00000000008003fe <cprintf>:

int
cprintf(const char *fmt, ...) {
  8003fe:	55                   	push   %rbp
  8003ff:	48 89 e5             	mov    %rsp,%rbp
  800402:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800409:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800410:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800417:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80041e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800425:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80042c:	84 c0                	test   %al,%al
  80042e:	74 20                	je     800450 <cprintf+0x52>
  800430:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800434:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800438:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80043c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800440:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800444:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800448:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80044c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800450:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800457:	00 00 00 
  80045a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800461:	00 00 00 
  800464:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800468:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80046f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800476:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80047d:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800484:	48 b8 96 03 80 00 00 	movabs $0x800396,%rax
  80048b:	00 00 00 
  80048e:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800490:	c9                   	leaveq 
  800491:	c3                   	retq   

0000000000800492 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800492:	55                   	push   %rbp
  800493:	48 89 e5             	mov    %rsp,%rbp
  800496:	41 57                	push   %r15
  800498:	41 56                	push   %r14
  80049a:	41 55                	push   %r13
  80049c:	41 54                	push   %r12
  80049e:	53                   	push   %rbx
  80049f:	48 83 ec 18          	sub    $0x18,%rsp
  8004a3:	49 89 fc             	mov    %rdi,%r12
  8004a6:	49 89 f5             	mov    %rsi,%r13
  8004a9:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8004ad:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8004b0:	41 89 cf             	mov    %ecx,%r15d
  8004b3:	49 39 d7             	cmp    %rdx,%r15
  8004b6:	76 45                	jbe    8004fd <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8004b8:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8004bc:	85 db                	test   %ebx,%ebx
  8004be:	7e 0e                	jle    8004ce <printnum+0x3c>
      putch(padc, putdat);
  8004c0:	4c 89 ee             	mov    %r13,%rsi
  8004c3:	44 89 f7             	mov    %r14d,%edi
  8004c6:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8004c9:	83 eb 01             	sub    $0x1,%ebx
  8004cc:	75 f2                	jne    8004c0 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8004ce:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d7:	49 f7 f7             	div    %r15
  8004da:	48 b8 2b 16 80 00 00 	movabs $0x80162b,%rax
  8004e1:	00 00 00 
  8004e4:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8004e8:	4c 89 ee             	mov    %r13,%rsi
  8004eb:	41 ff d4             	callq  *%r12
}
  8004ee:	48 83 c4 18          	add    $0x18,%rsp
  8004f2:	5b                   	pop    %rbx
  8004f3:	41 5c                	pop    %r12
  8004f5:	41 5d                	pop    %r13
  8004f7:	41 5e                	pop    %r14
  8004f9:	41 5f                	pop    %r15
  8004fb:	5d                   	pop    %rbp
  8004fc:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8004fd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
  800506:	49 f7 f7             	div    %r15
  800509:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80050d:	48 89 c2             	mov    %rax,%rdx
  800510:	48 b8 92 04 80 00 00 	movabs $0x800492,%rax
  800517:	00 00 00 
  80051a:	ff d0                	callq  *%rax
  80051c:	eb b0                	jmp    8004ce <printnum+0x3c>

000000000080051e <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80051e:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800522:	48 8b 06             	mov    (%rsi),%rax
  800525:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800529:	73 0a                	jae    800535 <sprintputch+0x17>
    *b->buf++ = ch;
  80052b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80052f:	48 89 16             	mov    %rdx,(%rsi)
  800532:	40 88 38             	mov    %dil,(%rax)
}
  800535:	c3                   	retq   

0000000000800536 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800536:	55                   	push   %rbp
  800537:	48 89 e5             	mov    %rsp,%rbp
  80053a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800541:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800548:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80054f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800556:	84 c0                	test   %al,%al
  800558:	74 20                	je     80057a <printfmt+0x44>
  80055a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80055e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800562:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800566:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80056a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80056e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800572:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800576:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80057a:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800581:	00 00 00 
  800584:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80058b:	00 00 00 
  80058e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800592:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800599:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8005a0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8005a7:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8005ae:	48 b8 bc 05 80 00 00 	movabs $0x8005bc,%rax
  8005b5:	00 00 00 
  8005b8:	ff d0                	callq  *%rax
}
  8005ba:	c9                   	leaveq 
  8005bb:	c3                   	retq   

00000000008005bc <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8005bc:	55                   	push   %rbp
  8005bd:	48 89 e5             	mov    %rsp,%rbp
  8005c0:	41 57                	push   %r15
  8005c2:	41 56                	push   %r14
  8005c4:	41 55                	push   %r13
  8005c6:	41 54                	push   %r12
  8005c8:	53                   	push   %rbx
  8005c9:	48 83 ec 48          	sub    $0x48,%rsp
  8005cd:	49 89 fd             	mov    %rdi,%r13
  8005d0:	49 89 f7             	mov    %rsi,%r15
  8005d3:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8005d6:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8005da:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8005de:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8005e2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005e6:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8005ea:	41 0f b6 3e          	movzbl (%r14),%edi
  8005ee:	83 ff 25             	cmp    $0x25,%edi
  8005f1:	74 18                	je     80060b <vprintfmt+0x4f>
      if (ch == '\0')
  8005f3:	85 ff                	test   %edi,%edi
  8005f5:	0f 84 8c 06 00 00    	je     800c87 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8005fb:	4c 89 fe             	mov    %r15,%rsi
  8005fe:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800601:	49 89 de             	mov    %rbx,%r14
  800604:	eb e0                	jmp    8005e6 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800606:	49 89 de             	mov    %rbx,%r14
  800609:	eb db                	jmp    8005e6 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80060b:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80060f:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800613:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80061a:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800620:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800624:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800629:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80062f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800635:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80063a:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80063f:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800643:	0f b6 13             	movzbl (%rbx),%edx
  800646:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800649:	3c 55                	cmp    $0x55,%al
  80064b:	0f 87 8b 05 00 00    	ja     800bdc <vprintfmt+0x620>
  800651:	0f b6 c0             	movzbl %al,%eax
  800654:	49 bb 00 17 80 00 00 	movabs $0x801700,%r11
  80065b:	00 00 00 
  80065e:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800662:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800665:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800669:	eb d4                	jmp    80063f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80066b:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80066e:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800672:	eb cb                	jmp    80063f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800674:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800677:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80067b:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80067f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800682:	83 fa 09             	cmp    $0x9,%edx
  800685:	77 7e                	ja     800705 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800687:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80068b:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80068f:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800694:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800698:	8d 50 d0             	lea    -0x30(%rax),%edx
  80069b:	83 fa 09             	cmp    $0x9,%edx
  80069e:	76 e7                	jbe    800687 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8006a0:	4c 89 f3             	mov    %r14,%rbx
  8006a3:	eb 19                	jmp    8006be <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8006a5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006a8:	83 f8 2f             	cmp    $0x2f,%eax
  8006ab:	77 2a                	ja     8006d7 <vprintfmt+0x11b>
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	4c 01 d2             	add    %r10,%rdx
  8006b2:	83 c0 08             	add    $0x8,%eax
  8006b5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006b8:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8006bb:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8006be:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006c2:	0f 89 77 ff ff ff    	jns    80063f <vprintfmt+0x83>
          width = precision, precision = -1;
  8006c8:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8006cc:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8006d2:	e9 68 ff ff ff       	jmpq   80063f <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8006d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e3:	eb d3                	jmp    8006b8 <vprintfmt+0xfc>
        if (width < 0)
  8006e5:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	41 0f 48 c0          	cmovs  %r8d,%eax
  8006ee:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8006f1:	4c 89 f3             	mov    %r14,%rbx
  8006f4:	e9 46 ff ff ff       	jmpq   80063f <vprintfmt+0x83>
  8006f9:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8006fc:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800700:	e9 3a ff ff ff       	jmpq   80063f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800705:	4c 89 f3             	mov    %r14,%rbx
  800708:	eb b4                	jmp    8006be <vprintfmt+0x102>
        lflag++;
  80070a:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80070d:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800710:	e9 2a ff ff ff       	jmpq   80063f <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800715:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800718:	83 f8 2f             	cmp    $0x2f,%eax
  80071b:	77 19                	ja     800736 <vprintfmt+0x17a>
  80071d:	89 c2                	mov    %eax,%edx
  80071f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800723:	83 c0 08             	add    $0x8,%eax
  800726:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800729:	4c 89 fe             	mov    %r15,%rsi
  80072c:	8b 3a                	mov    (%rdx),%edi
  80072e:	41 ff d5             	callq  *%r13
        break;
  800731:	e9 b0 fe ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800736:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80073a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80073e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800742:	eb e5                	jmp    800729 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800744:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800747:	83 f8 2f             	cmp    $0x2f,%eax
  80074a:	77 5b                	ja     8007a7 <vprintfmt+0x1eb>
  80074c:	89 c2                	mov    %eax,%edx
  80074e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800752:	83 c0 08             	add    $0x8,%eax
  800755:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800758:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80075a:	89 c8                	mov    %ecx,%eax
  80075c:	c1 f8 1f             	sar    $0x1f,%eax
  80075f:	31 c1                	xor    %eax,%ecx
  800761:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800763:	83 f9 0b             	cmp    $0xb,%ecx
  800766:	7f 4d                	jg     8007b5 <vprintfmt+0x1f9>
  800768:	48 63 c1             	movslq %ecx,%rax
  80076b:	48 ba c0 19 80 00 00 	movabs $0x8019c0,%rdx
  800772:	00 00 00 
  800775:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800779:	48 85 c0             	test   %rax,%rax
  80077c:	74 37                	je     8007b5 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80077e:	48 89 c1             	mov    %rax,%rcx
  800781:	48 ba 4c 16 80 00 00 	movabs $0x80164c,%rdx
  800788:	00 00 00 
  80078b:	4c 89 fe             	mov    %r15,%rsi
  80078e:	4c 89 ef             	mov    %r13,%rdi
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	48 bb 36 05 80 00 00 	movabs $0x800536,%rbx
  80079d:	00 00 00 
  8007a0:	ff d3                	callq  *%rbx
  8007a2:	e9 3f fe ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8007a7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007af:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b3:	eb a3                	jmp    800758 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8007b5:	48 ba 43 16 80 00 00 	movabs $0x801643,%rdx
  8007bc:	00 00 00 
  8007bf:	4c 89 fe             	mov    %r15,%rsi
  8007c2:	4c 89 ef             	mov    %r13,%rdi
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	48 bb 36 05 80 00 00 	movabs $0x800536,%rbx
  8007d1:	00 00 00 
  8007d4:	ff d3                	callq  *%rbx
  8007d6:	e9 0b fe ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8007db:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007de:	83 f8 2f             	cmp    $0x2f,%eax
  8007e1:	77 4b                	ja     80082e <vprintfmt+0x272>
  8007e3:	89 c2                	mov    %eax,%edx
  8007e5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007e9:	83 c0 08             	add    $0x8,%eax
  8007ec:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007ef:	48 8b 02             	mov    (%rdx),%rax
  8007f2:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8007f6:	48 85 c0             	test   %rax,%rax
  8007f9:	0f 84 05 04 00 00    	je     800c04 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8007ff:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800803:	7e 06                	jle    80080b <vprintfmt+0x24f>
  800805:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800809:	75 31                	jne    80083c <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80080f:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800813:	0f b6 00             	movzbl (%rax),%eax
  800816:	0f be f8             	movsbl %al,%edi
  800819:	85 ff                	test   %edi,%edi
  80081b:	0f 84 c3 00 00 00    	je     8008e4 <vprintfmt+0x328>
  800821:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800825:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800829:	e9 85 00 00 00       	jmpq   8008b3 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80082e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800832:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800836:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80083a:	eb b3                	jmp    8007ef <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80083c:	49 63 f4             	movslq %r12d,%rsi
  80083f:	48 89 c7             	mov    %rax,%rdi
  800842:	48 b8 93 0d 80 00 00 	movabs $0x800d93,%rax
  800849:	00 00 00 
  80084c:	ff d0                	callq  *%rax
  80084e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800851:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800854:	85 f6                	test   %esi,%esi
  800856:	7e 22                	jle    80087a <vprintfmt+0x2be>
            putch(padc, putdat);
  800858:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80085c:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800860:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800864:	4c 89 fe             	mov    %r15,%rsi
  800867:	89 df                	mov    %ebx,%edi
  800869:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80086c:	41 83 ec 01          	sub    $0x1,%r12d
  800870:	75 f2                	jne    800864 <vprintfmt+0x2a8>
  800872:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800876:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80087a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80087e:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800882:	0f b6 00             	movzbl (%rax),%eax
  800885:	0f be f8             	movsbl %al,%edi
  800888:	85 ff                	test   %edi,%edi
  80088a:	0f 84 56 fd ff ff    	je     8005e6 <vprintfmt+0x2a>
  800890:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800894:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800898:	eb 19                	jmp    8008b3 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80089a:	4c 89 fe             	mov    %r15,%rsi
  80089d:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a0:	41 83 ee 01          	sub    $0x1,%r14d
  8008a4:	48 83 c3 01          	add    $0x1,%rbx
  8008a8:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8008ac:	0f be f8             	movsbl %al,%edi
  8008af:	85 ff                	test   %edi,%edi
  8008b1:	74 29                	je     8008dc <vprintfmt+0x320>
  8008b3:	45 85 e4             	test   %r12d,%r12d
  8008b6:	78 06                	js     8008be <vprintfmt+0x302>
  8008b8:	41 83 ec 01          	sub    $0x1,%r12d
  8008bc:	78 48                	js     800906 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8008be:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8008c2:	74 d6                	je     80089a <vprintfmt+0x2de>
  8008c4:	0f be c0             	movsbl %al,%eax
  8008c7:	83 e8 20             	sub    $0x20,%eax
  8008ca:	83 f8 5e             	cmp    $0x5e,%eax
  8008cd:	76 cb                	jbe    80089a <vprintfmt+0x2de>
            putch('?', putdat);
  8008cf:	4c 89 fe             	mov    %r15,%rsi
  8008d2:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8008d7:	41 ff d5             	callq  *%r13
  8008da:	eb c4                	jmp    8008a0 <vprintfmt+0x2e4>
  8008dc:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008e0:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8008e4:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8008e7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008eb:	0f 8e f5 fc ff ff    	jle    8005e6 <vprintfmt+0x2a>
          putch(' ', putdat);
  8008f1:	4c 89 fe             	mov    %r15,%rsi
  8008f4:	bf 20 00 00 00       	mov    $0x20,%edi
  8008f9:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8008fc:	83 eb 01             	sub    $0x1,%ebx
  8008ff:	75 f0                	jne    8008f1 <vprintfmt+0x335>
  800901:	e9 e0 fc ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
  800906:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80090a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80090e:	eb d4                	jmp    8008e4 <vprintfmt+0x328>
  if (lflag >= 2)
  800910:	83 f9 01             	cmp    $0x1,%ecx
  800913:	7f 1d                	jg     800932 <vprintfmt+0x376>
  else if (lflag)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 5e                	je     800977 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800919:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091c:	83 f8 2f             	cmp    $0x2f,%eax
  80091f:	77 48                	ja     800969 <vprintfmt+0x3ad>
  800921:	89 c2                	mov    %eax,%edx
  800923:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800927:	83 c0 08             	add    $0x8,%eax
  80092a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092d:	48 8b 1a             	mov    (%rdx),%rbx
  800930:	eb 17                	jmp    800949 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800932:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800935:	83 f8 2f             	cmp    $0x2f,%eax
  800938:	77 21                	ja     80095b <vprintfmt+0x39f>
  80093a:	89 c2                	mov    %eax,%edx
  80093c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800940:	83 c0 08             	add    $0x8,%eax
  800943:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800946:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800949:	48 85 db             	test   %rbx,%rbx
  80094c:	78 50                	js     80099e <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80094e:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800951:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800956:	e9 b4 01 00 00       	jmpq   800b0f <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80095b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800963:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800967:	eb dd                	jmp    800946 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800969:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800971:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800975:	eb b6                	jmp    80092d <vprintfmt+0x371>
    return va_arg(*ap, int);
  800977:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80097a:	83 f8 2f             	cmp    $0x2f,%eax
  80097d:	77 11                	ja     800990 <vprintfmt+0x3d4>
  80097f:	89 c2                	mov    %eax,%edx
  800981:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800985:	83 c0 08             	add    $0x8,%eax
  800988:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80098b:	48 63 1a             	movslq (%rdx),%rbx
  80098e:	eb b9                	jmp    800949 <vprintfmt+0x38d>
  800990:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800994:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800998:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099c:	eb ed                	jmp    80098b <vprintfmt+0x3cf>
          putch('-', putdat);
  80099e:	4c 89 fe             	mov    %r15,%rsi
  8009a1:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8009a6:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8009a9:	48 89 da             	mov    %rbx,%rdx
  8009ac:	48 f7 da             	neg    %rdx
        base = 10;
  8009af:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b4:	e9 56 01 00 00       	jmpq   800b0f <vprintfmt+0x553>
  if (lflag >= 2)
  8009b9:	83 f9 01             	cmp    $0x1,%ecx
  8009bc:	7f 25                	jg     8009e3 <vprintfmt+0x427>
  else if (lflag)
  8009be:	85 c9                	test   %ecx,%ecx
  8009c0:	74 5e                	je     800a20 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8009c2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c5:	83 f8 2f             	cmp    $0x2f,%eax
  8009c8:	77 48                	ja     800a12 <vprintfmt+0x456>
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d0:	83 c0 08             	add    $0x8,%eax
  8009d3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d6:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009de:	e9 2c 01 00 00       	jmpq   800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e6:	83 f8 2f             	cmp    $0x2f,%eax
  8009e9:	77 19                	ja     800a04 <vprintfmt+0x448>
  8009eb:	89 c2                	mov    %eax,%edx
  8009ed:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f1:	83 c0 08             	add    $0x8,%eax
  8009f4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f7:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ff:	e9 0b 01 00 00       	jmpq   800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a04:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a08:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a10:	eb e5                	jmp    8009f7 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800a12:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a16:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a1e:	eb b6                	jmp    8009d6 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800a20:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a23:	83 f8 2f             	cmp    $0x2f,%eax
  800a26:	77 18                	ja     800a40 <vprintfmt+0x484>
  800a28:	89 c2                	mov    %eax,%edx
  800a2a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a2e:	83 c0 08             	add    $0x8,%eax
  800a31:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a34:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800a36:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a3b:	e9 cf 00 00 00       	jmpq   800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a40:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a44:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a48:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a4c:	eb e6                	jmp    800a34 <vprintfmt+0x478>
  if (lflag >= 2)
  800a4e:	83 f9 01             	cmp    $0x1,%ecx
  800a51:	7f 25                	jg     800a78 <vprintfmt+0x4bc>
  else if (lflag)
  800a53:	85 c9                	test   %ecx,%ecx
  800a55:	74 5b                	je     800ab2 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800a57:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a5a:	83 f8 2f             	cmp    $0x2f,%eax
  800a5d:	77 45                	ja     800aa4 <vprintfmt+0x4e8>
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a65:	83 c0 08             	add    $0x8,%eax
  800a68:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a6b:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a6e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a73:	e9 97 00 00 00       	jmpq   800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a78:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a7b:	83 f8 2f             	cmp    $0x2f,%eax
  800a7e:	77 16                	ja     800a96 <vprintfmt+0x4da>
  800a80:	89 c2                	mov    %eax,%edx
  800a82:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a86:	83 c0 08             	add    $0x8,%eax
  800a89:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a8c:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a8f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a94:	eb 79                	jmp    800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a96:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a9a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a9e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aa2:	eb e8                	jmp    800a8c <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800aa4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aa8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ab0:	eb b9                	jmp    800a6b <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800ab2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ab5:	83 f8 2f             	cmp    $0x2f,%eax
  800ab8:	77 15                	ja     800acf <vprintfmt+0x513>
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ac0:	83 c0 08             	add    $0x8,%eax
  800ac3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ac6:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800ac8:	b9 08 00 00 00       	mov    $0x8,%ecx
  800acd:	eb 40                	jmp    800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800acf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ad7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800adb:	eb e9                	jmp    800ac6 <vprintfmt+0x50a>
        putch('0', putdat);
  800add:	4c 89 fe             	mov    %r15,%rsi
  800ae0:	bf 30 00 00 00       	mov    $0x30,%edi
  800ae5:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800ae8:	4c 89 fe             	mov    %r15,%rsi
  800aeb:	bf 78 00 00 00       	mov    $0x78,%edi
  800af0:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800af3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800af6:	83 f8 2f             	cmp    $0x2f,%eax
  800af9:	77 34                	ja     800b2f <vprintfmt+0x573>
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b01:	83 c0 08             	add    $0x8,%eax
  800b04:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b07:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b0a:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800b0f:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800b14:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800b18:	4c 89 fe             	mov    %r15,%rsi
  800b1b:	4c 89 ef             	mov    %r13,%rdi
  800b1e:	48 b8 92 04 80 00 00 	movabs $0x800492,%rax
  800b25:	00 00 00 
  800b28:	ff d0                	callq  *%rax
        break;
  800b2a:	e9 b7 fa ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800b2f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b33:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b37:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b3b:	eb ca                	jmp    800b07 <vprintfmt+0x54b>
  if (lflag >= 2)
  800b3d:	83 f9 01             	cmp    $0x1,%ecx
  800b40:	7f 22                	jg     800b64 <vprintfmt+0x5a8>
  else if (lflag)
  800b42:	85 c9                	test   %ecx,%ecx
  800b44:	74 58                	je     800b9e <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800b46:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b49:	83 f8 2f             	cmp    $0x2f,%eax
  800b4c:	77 42                	ja     800b90 <vprintfmt+0x5d4>
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b54:	83 c0 08             	add    $0x8,%eax
  800b57:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b5a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b5d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b62:	eb ab                	jmp    800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b64:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b67:	83 f8 2f             	cmp    $0x2f,%eax
  800b6a:	77 16                	ja     800b82 <vprintfmt+0x5c6>
  800b6c:	89 c2                	mov    %eax,%edx
  800b6e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b72:	83 c0 08             	add    $0x8,%eax
  800b75:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b78:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b7b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b80:	eb 8d                	jmp    800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b82:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b86:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b8a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b8e:	eb e8                	jmp    800b78 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b90:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b94:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b98:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b9c:	eb bc                	jmp    800b5a <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b9e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ba1:	83 f8 2f             	cmp    $0x2f,%eax
  800ba4:	77 18                	ja     800bbe <vprintfmt+0x602>
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bac:	83 c0 08             	add    $0x8,%eax
  800baf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bb2:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800bb4:	b9 10 00 00 00       	mov    $0x10,%ecx
  800bb9:	e9 51 ff ff ff       	jmpq   800b0f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800bbe:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bc2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bc6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bca:	eb e6                	jmp    800bb2 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800bcc:	4c 89 fe             	mov    %r15,%rsi
  800bcf:	bf 25 00 00 00       	mov    $0x25,%edi
  800bd4:	41 ff d5             	callq  *%r13
        break;
  800bd7:	e9 0a fa ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
        putch('%', putdat);
  800bdc:	4c 89 fe             	mov    %r15,%rsi
  800bdf:	bf 25 00 00 00       	mov    $0x25,%edi
  800be4:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800be7:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800beb:	0f 84 15 fa ff ff    	je     800606 <vprintfmt+0x4a>
  800bf1:	49 89 de             	mov    %rbx,%r14
  800bf4:	49 83 ee 01          	sub    $0x1,%r14
  800bf8:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800bfd:	75 f5                	jne    800bf4 <vprintfmt+0x638>
  800bff:	e9 e2 f9 ff ff       	jmpq   8005e6 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800c04:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800c08:	74 06                	je     800c10 <vprintfmt+0x654>
  800c0a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800c0e:	7f 21                	jg     800c31 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c10:	bf 28 00 00 00       	mov    $0x28,%edi
  800c15:	48 bb 3d 16 80 00 00 	movabs $0x80163d,%rbx
  800c1c:	00 00 00 
  800c1f:	b8 28 00 00 00       	mov    $0x28,%eax
  800c24:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c28:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c2c:	e9 82 fc ff ff       	jmpq   8008b3 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800c31:	49 63 f4             	movslq %r12d,%rsi
  800c34:	48 bf 3c 16 80 00 00 	movabs $0x80163c,%rdi
  800c3b:	00 00 00 
  800c3e:	48 b8 93 0d 80 00 00 	movabs $0x800d93,%rax
  800c45:	00 00 00 
  800c48:	ff d0                	callq  *%rax
  800c4a:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800c4d:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800c50:	48 be 3c 16 80 00 00 	movabs $0x80163c,%rsi
  800c57:	00 00 00 
  800c5a:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	0f 8f f2 fb ff ff    	jg     800858 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c66:	48 bb 3d 16 80 00 00 	movabs $0x80163d,%rbx
  800c6d:	00 00 00 
  800c70:	b8 28 00 00 00       	mov    $0x28,%eax
  800c75:	bf 28 00 00 00       	mov    $0x28,%edi
  800c7a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c7e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c82:	e9 2c fc ff ff       	jmpq   8008b3 <vprintfmt+0x2f7>
}
  800c87:	48 83 c4 48          	add    $0x48,%rsp
  800c8b:	5b                   	pop    %rbx
  800c8c:	41 5c                	pop    %r12
  800c8e:	41 5d                	pop    %r13
  800c90:	41 5e                	pop    %r14
  800c92:	41 5f                	pop    %r15
  800c94:	5d                   	pop    %rbp
  800c95:	c3                   	retq   

0000000000800c96 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c96:	55                   	push   %rbp
  800c97:	48 89 e5             	mov    %rsp,%rbp
  800c9a:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c9e:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ca2:	48 63 c6             	movslq %esi,%rax
  800ca5:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800caa:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800cae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800cb5:	48 85 ff             	test   %rdi,%rdi
  800cb8:	74 2a                	je     800ce4 <vsnprintf+0x4e>
  800cba:	85 f6                	test   %esi,%esi
  800cbc:	7e 26                	jle    800ce4 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800cbe:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800cc2:	48 bf 1e 05 80 00 00 	movabs $0x80051e,%rdi
  800cc9:	00 00 00 
  800ccc:	48 b8 bc 05 80 00 00 	movabs $0x8005bc,%rax
  800cd3:	00 00 00 
  800cd6:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800cd8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800cdc:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800cdf:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ce2:	c9                   	leaveq 
  800ce3:	c3                   	retq   
    return -E_INVAL;
  800ce4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce9:	eb f7                	jmp    800ce2 <vsnprintf+0x4c>

0000000000800ceb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ceb:	55                   	push   %rbp
  800cec:	48 89 e5             	mov    %rsp,%rbp
  800cef:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800cf6:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800cfd:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800d04:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800d0b:	84 c0                	test   %al,%al
  800d0d:	74 20                	je     800d2f <snprintf+0x44>
  800d0f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800d13:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800d17:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800d1b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800d1f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800d23:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800d27:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800d2b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800d2f:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800d36:	00 00 00 
  800d39:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800d40:	00 00 00 
  800d43:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800d47:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800d4e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800d55:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800d5c:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800d63:	48 b8 96 0c 80 00 00 	movabs $0x800c96,%rax
  800d6a:	00 00 00 
  800d6d:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800d6f:	c9                   	leaveq 
  800d70:	c3                   	retq   

0000000000800d71 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800d71:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d74:	74 17                	je     800d8d <strlen+0x1c>
  800d76:	48 89 fa             	mov    %rdi,%rdx
  800d79:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d7e:	29 f9                	sub    %edi,%ecx
    n++;
  800d80:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d83:	48 83 c2 01          	add    $0x1,%rdx
  800d87:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d8a:	75 f4                	jne    800d80 <strlen+0xf>
  800d8c:	c3                   	retq   
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d92:	c3                   	retq   

0000000000800d93 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d93:	48 85 f6             	test   %rsi,%rsi
  800d96:	74 24                	je     800dbc <strnlen+0x29>
  800d98:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d9b:	74 25                	je     800dc2 <strnlen+0x2f>
  800d9d:	48 01 fe             	add    %rdi,%rsi
  800da0:	48 89 fa             	mov    %rdi,%rdx
  800da3:	b9 01 00 00 00       	mov    $0x1,%ecx
  800da8:	29 f9                	sub    %edi,%ecx
    n++;
  800daa:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dad:	48 83 c2 01          	add    $0x1,%rdx
  800db1:	48 39 f2             	cmp    %rsi,%rdx
  800db4:	74 11                	je     800dc7 <strnlen+0x34>
  800db6:	80 3a 00             	cmpb   $0x0,(%rdx)
  800db9:	75 ef                	jne    800daa <strnlen+0x17>
  800dbb:	c3                   	retq   
  800dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc1:	c3                   	retq   
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800dc7:	c3                   	retq   

0000000000800dc8 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800dc8:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800dd4:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800dd7:	48 83 c2 01          	add    $0x1,%rdx
  800ddb:	84 c9                	test   %cl,%cl
  800ddd:	75 f1                	jne    800dd0 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800ddf:	c3                   	retq   

0000000000800de0 <strcat>:

char *
strcat(char *dst, const char *src) {
  800de0:	55                   	push   %rbp
  800de1:	48 89 e5             	mov    %rsp,%rbp
  800de4:	41 54                	push   %r12
  800de6:	53                   	push   %rbx
  800de7:	48 89 fb             	mov    %rdi,%rbx
  800dea:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800ded:	48 b8 71 0d 80 00 00 	movabs $0x800d71,%rax
  800df4:	00 00 00 
  800df7:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800df9:	48 63 f8             	movslq %eax,%rdi
  800dfc:	48 01 df             	add    %rbx,%rdi
  800dff:	4c 89 e6             	mov    %r12,%rsi
  800e02:	48 b8 c8 0d 80 00 00 	movabs $0x800dc8,%rax
  800e09:	00 00 00 
  800e0c:	ff d0                	callq  *%rax
  return dst;
}
  800e0e:	48 89 d8             	mov    %rbx,%rax
  800e11:	5b                   	pop    %rbx
  800e12:	41 5c                	pop    %r12
  800e14:	5d                   	pop    %rbp
  800e15:	c3                   	retq   

0000000000800e16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e16:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800e19:	48 85 d2             	test   %rdx,%rdx
  800e1c:	74 1f                	je     800e3d <strncpy+0x27>
  800e1e:	48 01 fa             	add    %rdi,%rdx
  800e21:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800e24:	48 83 c1 01          	add    $0x1,%rcx
  800e28:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e2c:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800e30:	41 80 f8 01          	cmp    $0x1,%r8b
  800e34:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800e38:	48 39 ca             	cmp    %rcx,%rdx
  800e3b:	75 e7                	jne    800e24 <strncpy+0xe>
  }
  return ret;
}
  800e3d:	c3                   	retq   

0000000000800e3e <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800e3e:	48 89 f8             	mov    %rdi,%rax
  800e41:	48 85 d2             	test   %rdx,%rdx
  800e44:	74 36                	je     800e7c <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800e46:	48 83 fa 01          	cmp    $0x1,%rdx
  800e4a:	74 2d                	je     800e79 <strlcpy+0x3b>
  800e4c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e50:	45 84 c0             	test   %r8b,%r8b
  800e53:	74 24                	je     800e79 <strlcpy+0x3b>
  800e55:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800e59:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800e5e:	48 83 c0 01          	add    $0x1,%rax
  800e62:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800e66:	48 39 d1             	cmp    %rdx,%rcx
  800e69:	74 0e                	je     800e79 <strlcpy+0x3b>
  800e6b:	48 83 c1 01          	add    $0x1,%rcx
  800e6f:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800e74:	45 84 c0             	test   %r8b,%r8b
  800e77:	75 e5                	jne    800e5e <strlcpy+0x20>
    *dst = '\0';
  800e79:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800e7c:	48 29 f8             	sub    %rdi,%rax
}
  800e7f:	c3                   	retq   

0000000000800e80 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e80:	0f b6 07             	movzbl (%rdi),%eax
  800e83:	84 c0                	test   %al,%al
  800e85:	74 17                	je     800e9e <strcmp+0x1e>
  800e87:	3a 06                	cmp    (%rsi),%al
  800e89:	75 13                	jne    800e9e <strcmp+0x1e>
    p++, q++;
  800e8b:	48 83 c7 01          	add    $0x1,%rdi
  800e8f:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e93:	0f b6 07             	movzbl (%rdi),%eax
  800e96:	84 c0                	test   %al,%al
  800e98:	74 04                	je     800e9e <strcmp+0x1e>
  800e9a:	3a 06                	cmp    (%rsi),%al
  800e9c:	74 ed                	je     800e8b <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e9e:	0f b6 c0             	movzbl %al,%eax
  800ea1:	0f b6 16             	movzbl (%rsi),%edx
  800ea4:	29 d0                	sub    %edx,%eax
}
  800ea6:	c3                   	retq   

0000000000800ea7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800ea7:	48 85 d2             	test   %rdx,%rdx
  800eaa:	74 2f                	je     800edb <strncmp+0x34>
  800eac:	0f b6 07             	movzbl (%rdi),%eax
  800eaf:	84 c0                	test   %al,%al
  800eb1:	74 1f                	je     800ed2 <strncmp+0x2b>
  800eb3:	3a 06                	cmp    (%rsi),%al
  800eb5:	75 1b                	jne    800ed2 <strncmp+0x2b>
  800eb7:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800eba:	48 83 c7 01          	add    $0x1,%rdi
  800ebe:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ec2:	48 39 d7             	cmp    %rdx,%rdi
  800ec5:	74 1a                	je     800ee1 <strncmp+0x3a>
  800ec7:	0f b6 07             	movzbl (%rdi),%eax
  800eca:	84 c0                	test   %al,%al
  800ecc:	74 04                	je     800ed2 <strncmp+0x2b>
  800ece:	3a 06                	cmp    (%rsi),%al
  800ed0:	74 e8                	je     800eba <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ed2:	0f b6 07             	movzbl (%rdi),%eax
  800ed5:	0f b6 16             	movzbl (%rsi),%edx
  800ed8:	29 d0                	sub    %edx,%eax
}
  800eda:	c3                   	retq   
    return 0;
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee0:	c3                   	retq   
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	c3                   	retq   

0000000000800ee7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800ee7:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ee9:	0f b6 07             	movzbl (%rdi),%eax
  800eec:	84 c0                	test   %al,%al
  800eee:	74 1e                	je     800f0e <strchr+0x27>
    if (*s == c)
  800ef0:	40 38 c6             	cmp    %al,%sil
  800ef3:	74 1f                	je     800f14 <strchr+0x2d>
  for (; *s; s++)
  800ef5:	48 83 c7 01          	add    $0x1,%rdi
  800ef9:	0f b6 07             	movzbl (%rdi),%eax
  800efc:	84 c0                	test   %al,%al
  800efe:	74 08                	je     800f08 <strchr+0x21>
    if (*s == c)
  800f00:	38 d0                	cmp    %dl,%al
  800f02:	75 f1                	jne    800ef5 <strchr+0xe>
  for (; *s; s++)
  800f04:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800f07:	c3                   	retq   
  return 0;
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0d:	c3                   	retq   
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	c3                   	retq   
    if (*s == c)
  800f14:	48 89 f8             	mov    %rdi,%rax
  800f17:	c3                   	retq   

0000000000800f18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800f18:	48 89 f8             	mov    %rdi,%rax
  800f1b:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800f1d:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800f20:	40 38 f2             	cmp    %sil,%dl
  800f23:	74 13                	je     800f38 <strfind+0x20>
  800f25:	84 d2                	test   %dl,%dl
  800f27:	74 0f                	je     800f38 <strfind+0x20>
  for (; *s; s++)
  800f29:	48 83 c0 01          	add    $0x1,%rax
  800f2d:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800f30:	38 ca                	cmp    %cl,%dl
  800f32:	74 04                	je     800f38 <strfind+0x20>
  800f34:	84 d2                	test   %dl,%dl
  800f36:	75 f1                	jne    800f29 <strfind+0x11>
      break;
  return (char *)s;
}
  800f38:	c3                   	retq   

0000000000800f39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800f39:	48 85 d2             	test   %rdx,%rdx
  800f3c:	74 3a                	je     800f78 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f3e:	48 89 f8             	mov    %rdi,%rax
  800f41:	48 09 d0             	or     %rdx,%rax
  800f44:	a8 03                	test   $0x3,%al
  800f46:	75 28                	jne    800f70 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800f48:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800f4c:	89 f0                	mov    %esi,%eax
  800f4e:	c1 e0 08             	shl    $0x8,%eax
  800f51:	89 f1                	mov    %esi,%ecx
  800f53:	c1 e1 18             	shl    $0x18,%ecx
  800f56:	41 89 f0             	mov    %esi,%r8d
  800f59:	41 c1 e0 10          	shl    $0x10,%r8d
  800f5d:	44 09 c1             	or     %r8d,%ecx
  800f60:	09 ce                	or     %ecx,%esi
  800f62:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800f64:	48 c1 ea 02          	shr    $0x2,%rdx
  800f68:	48 89 d1             	mov    %rdx,%rcx
  800f6b:	fc                   	cld    
  800f6c:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f6e:	eb 08                	jmp    800f78 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	48 89 d1             	mov    %rdx,%rcx
  800f75:	fc                   	cld    
  800f76:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800f78:	48 89 f8             	mov    %rdi,%rax
  800f7b:	c3                   	retq   

0000000000800f7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800f7c:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f7f:	48 39 fe             	cmp    %rdi,%rsi
  800f82:	73 40                	jae    800fc4 <memmove+0x48>
  800f84:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f88:	48 39 f9             	cmp    %rdi,%rcx
  800f8b:	76 37                	jbe    800fc4 <memmove+0x48>
    s += n;
    d += n;
  800f8d:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f91:	48 89 fe             	mov    %rdi,%rsi
  800f94:	48 09 d6             	or     %rdx,%rsi
  800f97:	48 09 ce             	or     %rcx,%rsi
  800f9a:	40 f6 c6 03          	test   $0x3,%sil
  800f9e:	75 14                	jne    800fb4 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800fa0:	48 83 ef 04          	sub    $0x4,%rdi
  800fa4:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800fa8:	48 c1 ea 02          	shr    $0x2,%rdx
  800fac:	48 89 d1             	mov    %rdx,%rcx
  800faf:	fd                   	std    
  800fb0:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800fb2:	eb 0e                	jmp    800fc2 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800fb4:	48 83 ef 01          	sub    $0x1,%rdi
  800fb8:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800fbc:	48 89 d1             	mov    %rdx,%rcx
  800fbf:	fd                   	std    
  800fc0:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800fc2:	fc                   	cld    
  800fc3:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800fc4:	48 89 c1             	mov    %rax,%rcx
  800fc7:	48 09 d1             	or     %rdx,%rcx
  800fca:	48 09 f1             	or     %rsi,%rcx
  800fcd:	f6 c1 03             	test   $0x3,%cl
  800fd0:	75 0e                	jne    800fe0 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800fd2:	48 c1 ea 02          	shr    $0x2,%rdx
  800fd6:	48 89 d1             	mov    %rdx,%rcx
  800fd9:	48 89 c7             	mov    %rax,%rdi
  800fdc:	fc                   	cld    
  800fdd:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800fdf:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800fe0:	48 89 c7             	mov    %rax,%rdi
  800fe3:	48 89 d1             	mov    %rdx,%rcx
  800fe6:	fc                   	cld    
  800fe7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800fe9:	c3                   	retq   

0000000000800fea <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800fea:	55                   	push   %rbp
  800feb:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800fee:	48 b8 7c 0f 80 00 00 	movabs $0x800f7c,%rax
  800ff5:	00 00 00 
  800ff8:	ff d0                	callq  *%rax
}
  800ffa:	5d                   	pop    %rbp
  800ffb:	c3                   	retq   

0000000000800ffc <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800ffc:	55                   	push   %rbp
  800ffd:	48 89 e5             	mov    %rsp,%rbp
  801000:	41 57                	push   %r15
  801002:	41 56                	push   %r14
  801004:	41 55                	push   %r13
  801006:	41 54                	push   %r12
  801008:	53                   	push   %rbx
  801009:	48 83 ec 08          	sub    $0x8,%rsp
  80100d:	49 89 fe             	mov    %rdi,%r14
  801010:	49 89 f7             	mov    %rsi,%r15
  801013:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801016:	48 89 f7             	mov    %rsi,%rdi
  801019:	48 b8 71 0d 80 00 00 	movabs $0x800d71,%rax
  801020:	00 00 00 
  801023:	ff d0                	callq  *%rax
  801025:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801028:	4c 89 ee             	mov    %r13,%rsi
  80102b:	4c 89 f7             	mov    %r14,%rdi
  80102e:	48 b8 93 0d 80 00 00 	movabs $0x800d93,%rax
  801035:	00 00 00 
  801038:	ff d0                	callq  *%rax
  80103a:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80103d:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801041:	4d 39 e5             	cmp    %r12,%r13
  801044:	74 26                	je     80106c <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801046:	4c 89 e8             	mov    %r13,%rax
  801049:	4c 29 e0             	sub    %r12,%rax
  80104c:	48 39 d8             	cmp    %rbx,%rax
  80104f:	76 2a                	jbe    80107b <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801051:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801055:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801059:	4c 89 fe             	mov    %r15,%rsi
  80105c:	48 b8 ea 0f 80 00 00 	movabs $0x800fea,%rax
  801063:	00 00 00 
  801066:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801068:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80106c:	48 83 c4 08          	add    $0x8,%rsp
  801070:	5b                   	pop    %rbx
  801071:	41 5c                	pop    %r12
  801073:	41 5d                	pop    %r13
  801075:	41 5e                	pop    %r14
  801077:	41 5f                	pop    %r15
  801079:	5d                   	pop    %rbp
  80107a:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80107b:	49 83 ed 01          	sub    $0x1,%r13
  80107f:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801083:	4c 89 ea             	mov    %r13,%rdx
  801086:	4c 89 fe             	mov    %r15,%rsi
  801089:	48 b8 ea 0f 80 00 00 	movabs $0x800fea,%rax
  801090:	00 00 00 
  801093:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801095:	4d 01 ee             	add    %r13,%r14
  801098:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80109d:	eb c9                	jmp    801068 <strlcat+0x6c>

000000000080109f <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80109f:	48 85 d2             	test   %rdx,%rdx
  8010a2:	74 3a                	je     8010de <memcmp+0x3f>
    if (*s1 != *s2)
  8010a4:	0f b6 0f             	movzbl (%rdi),%ecx
  8010a7:	44 0f b6 06          	movzbl (%rsi),%r8d
  8010ab:	44 38 c1             	cmp    %r8b,%cl
  8010ae:	75 1d                	jne    8010cd <memcmp+0x2e>
  8010b0:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8010b5:	48 39 d0             	cmp    %rdx,%rax
  8010b8:	74 1e                	je     8010d8 <memcmp+0x39>
    if (*s1 != *s2)
  8010ba:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8010be:	48 83 c0 01          	add    $0x1,%rax
  8010c2:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8010c8:	44 38 c1             	cmp    %r8b,%cl
  8010cb:	74 e8                	je     8010b5 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8010cd:	0f b6 c1             	movzbl %cl,%eax
  8010d0:	45 0f b6 c0          	movzbl %r8b,%r8d
  8010d4:	44 29 c0             	sub    %r8d,%eax
  8010d7:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8010d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010dd:	c3                   	retq   
  8010de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e3:	c3                   	retq   

00000000008010e4 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8010e4:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8010e8:	48 39 c7             	cmp    %rax,%rdi
  8010eb:	73 19                	jae    801106 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010ed:	89 f2                	mov    %esi,%edx
  8010ef:	40 38 37             	cmp    %sil,(%rdi)
  8010f2:	74 16                	je     80110a <memfind+0x26>
  for (; s < ends; s++)
  8010f4:	48 83 c7 01          	add    $0x1,%rdi
  8010f8:	48 39 f8             	cmp    %rdi,%rax
  8010fb:	74 08                	je     801105 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010fd:	38 17                	cmp    %dl,(%rdi)
  8010ff:	75 f3                	jne    8010f4 <memfind+0x10>
  for (; s < ends; s++)
  801101:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801104:	c3                   	retq   
  801105:	c3                   	retq   
  for (; s < ends; s++)
  801106:	48 89 f8             	mov    %rdi,%rax
  801109:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80110a:	48 89 f8             	mov    %rdi,%rax
  80110d:	c3                   	retq   

000000000080110e <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80110e:	0f b6 07             	movzbl (%rdi),%eax
  801111:	3c 20                	cmp    $0x20,%al
  801113:	74 04                	je     801119 <strtol+0xb>
  801115:	3c 09                	cmp    $0x9,%al
  801117:	75 0f                	jne    801128 <strtol+0x1a>
    s++;
  801119:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80111d:	0f b6 07             	movzbl (%rdi),%eax
  801120:	3c 20                	cmp    $0x20,%al
  801122:	74 f5                	je     801119 <strtol+0xb>
  801124:	3c 09                	cmp    $0x9,%al
  801126:	74 f1                	je     801119 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801128:	3c 2b                	cmp    $0x2b,%al
  80112a:	74 2b                	je     801157 <strtol+0x49>
  int neg  = 0;
  80112c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801132:	3c 2d                	cmp    $0x2d,%al
  801134:	74 2d                	je     801163 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801136:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80113c:	75 0f                	jne    80114d <strtol+0x3f>
  80113e:	80 3f 30             	cmpb   $0x30,(%rdi)
  801141:	74 2c                	je     80116f <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801143:	85 d2                	test   %edx,%edx
  801145:	b8 0a 00 00 00       	mov    $0xa,%eax
  80114a:	0f 44 d0             	cmove  %eax,%edx
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801152:	4c 63 d2             	movslq %edx,%r10
  801155:	eb 5c                	jmp    8011b3 <strtol+0xa5>
    s++;
  801157:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80115b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801161:	eb d3                	jmp    801136 <strtol+0x28>
    s++, neg = 1;
  801163:	48 83 c7 01          	add    $0x1,%rdi
  801167:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80116d:	eb c7                	jmp    801136 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80116f:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801173:	74 0f                	je     801184 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801175:	85 d2                	test   %edx,%edx
  801177:	75 d4                	jne    80114d <strtol+0x3f>
    s++, base = 8;
  801179:	48 83 c7 01          	add    $0x1,%rdi
  80117d:	ba 08 00 00 00       	mov    $0x8,%edx
  801182:	eb c9                	jmp    80114d <strtol+0x3f>
    s += 2, base = 16;
  801184:	48 83 c7 02          	add    $0x2,%rdi
  801188:	ba 10 00 00 00       	mov    $0x10,%edx
  80118d:	eb be                	jmp    80114d <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80118f:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801193:	41 80 f8 19          	cmp    $0x19,%r8b
  801197:	77 2f                	ja     8011c8 <strtol+0xba>
      dig = *s - 'a' + 10;
  801199:	44 0f be c1          	movsbl %cl,%r8d
  80119d:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8011a1:	39 d1                	cmp    %edx,%ecx
  8011a3:	7d 37                	jge    8011dc <strtol+0xce>
    s++, val = (val * base) + dig;
  8011a5:	48 83 c7 01          	add    $0x1,%rdi
  8011a9:	49 0f af c2          	imul   %r10,%rax
  8011ad:	48 63 c9             	movslq %ecx,%rcx
  8011b0:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8011b3:	0f b6 0f             	movzbl (%rdi),%ecx
  8011b6:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8011ba:	41 80 f8 09          	cmp    $0x9,%r8b
  8011be:	77 cf                	ja     80118f <strtol+0x81>
      dig = *s - '0';
  8011c0:	0f be c9             	movsbl %cl,%ecx
  8011c3:	83 e9 30             	sub    $0x30,%ecx
  8011c6:	eb d9                	jmp    8011a1 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8011c8:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8011cc:	41 80 f8 19          	cmp    $0x19,%r8b
  8011d0:	77 0a                	ja     8011dc <strtol+0xce>
      dig = *s - 'A' + 10;
  8011d2:	44 0f be c1          	movsbl %cl,%r8d
  8011d6:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8011da:	eb c5                	jmp    8011a1 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8011dc:	48 85 f6             	test   %rsi,%rsi
  8011df:	74 03                	je     8011e4 <strtol+0xd6>
    *endptr = (char *)s;
  8011e1:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8011e4:	48 89 c2             	mov    %rax,%rdx
  8011e7:	48 f7 da             	neg    %rdx
  8011ea:	45 85 c9             	test   %r9d,%r9d
  8011ed:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8011f1:	c3                   	retq   

00000000008011f2 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8011f2:	55                   	push   %rbp
  8011f3:	48 89 e5             	mov    %rsp,%rbp
  8011f6:	53                   	push   %rbx
  8011f7:	48 89 fa             	mov    %rdi,%rdx
  8011fa:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	48 89 c3             	mov    %rax,%rbx
  801205:	48 89 c7             	mov    %rax,%rdi
  801208:	48 89 c6             	mov    %rax,%rsi
  80120b:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80120d:	5b                   	pop    %rbx
  80120e:	5d                   	pop    %rbp
  80120f:	c3                   	retq   

0000000000801210 <sys_cgetc>:

int
sys_cgetc(void) {
  801210:	55                   	push   %rbp
  801211:	48 89 e5             	mov    %rsp,%rbp
  801214:	53                   	push   %rbx
  asm volatile("int %1\n"
  801215:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121a:	b8 01 00 00 00       	mov    $0x1,%eax
  80121f:	48 89 ca             	mov    %rcx,%rdx
  801222:	48 89 cb             	mov    %rcx,%rbx
  801225:	48 89 cf             	mov    %rcx,%rdi
  801228:	48 89 ce             	mov    %rcx,%rsi
  80122b:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80122d:	5b                   	pop    %rbx
  80122e:	5d                   	pop    %rbp
  80122f:	c3                   	retq   

0000000000801230 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801230:	55                   	push   %rbp
  801231:	48 89 e5             	mov    %rsp,%rbp
  801234:	53                   	push   %rbx
  801235:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801239:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80123c:	be 00 00 00 00       	mov    $0x0,%esi
  801241:	b8 03 00 00 00       	mov    $0x3,%eax
  801246:	48 89 f1             	mov    %rsi,%rcx
  801249:	48 89 f3             	mov    %rsi,%rbx
  80124c:	48 89 f7             	mov    %rsi,%rdi
  80124f:	cd 30                	int    $0x30
  if (check && ret > 0)
  801251:	48 85 c0             	test   %rax,%rax
  801254:	7f 07                	jg     80125d <sys_env_destroy+0x2d>
}
  801256:	48 83 c4 08          	add    $0x8,%rsp
  80125a:	5b                   	pop    %rbx
  80125b:	5d                   	pop    %rbp
  80125c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80125d:	49 89 c0             	mov    %rax,%r8
  801260:	b9 03 00 00 00       	mov    $0x3,%ecx
  801265:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  80126c:	00 00 00 
  80126f:	be 22 00 00 00       	mov    $0x22,%esi
  801274:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  80127b:	00 00 00 
  80127e:	b8 00 00 00 00       	mov    $0x0,%eax
  801283:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  80128a:	00 00 00 
  80128d:	41 ff d1             	callq  *%r9

0000000000801290 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801290:	55                   	push   %rbp
  801291:	48 89 e5             	mov    %rsp,%rbp
  801294:	53                   	push   %rbx
  asm volatile("int %1\n"
  801295:	b9 00 00 00 00       	mov    $0x0,%ecx
  80129a:	b8 02 00 00 00       	mov    $0x2,%eax
  80129f:	48 89 ca             	mov    %rcx,%rdx
  8012a2:	48 89 cb             	mov    %rcx,%rbx
  8012a5:	48 89 cf             	mov    %rcx,%rdi
  8012a8:	48 89 ce             	mov    %rcx,%rsi
  8012ab:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012ad:	5b                   	pop    %rbx
  8012ae:	5d                   	pop    %rbp
  8012af:	c3                   	retq   

00000000008012b0 <sys_yield>:

void
sys_yield(void) {
  8012b0:	55                   	push   %rbp
  8012b1:	48 89 e5             	mov    %rsp,%rbp
  8012b4:	53                   	push   %rbx
  asm volatile("int %1\n"
  8012b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012bf:	48 89 ca             	mov    %rcx,%rdx
  8012c2:	48 89 cb             	mov    %rcx,%rbx
  8012c5:	48 89 cf             	mov    %rcx,%rdi
  8012c8:	48 89 ce             	mov    %rcx,%rsi
  8012cb:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012cd:	5b                   	pop    %rbx
  8012ce:	5d                   	pop    %rbp
  8012cf:	c3                   	retq   

00000000008012d0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8012d0:	55                   	push   %rbp
  8012d1:	48 89 e5             	mov    %rsp,%rbp
  8012d4:	53                   	push   %rbx
  8012d5:	48 83 ec 08          	sub    $0x8,%rsp
  8012d9:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8012dc:	4c 63 c7             	movslq %edi,%r8
  8012df:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8012e2:	be 00 00 00 00       	mov    $0x0,%esi
  8012e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8012ec:	4c 89 c2             	mov    %r8,%rdx
  8012ef:	48 89 f7             	mov    %rsi,%rdi
  8012f2:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012f4:	48 85 c0             	test   %rax,%rax
  8012f7:	7f 07                	jg     801300 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8012f9:	48 83 c4 08          	add    $0x8,%rsp
  8012fd:	5b                   	pop    %rbx
  8012fe:	5d                   	pop    %rbp
  8012ff:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801300:	49 89 c0             	mov    %rax,%r8
  801303:	b9 04 00 00 00       	mov    $0x4,%ecx
  801308:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  80130f:	00 00 00 
  801312:	be 22 00 00 00       	mov    $0x22,%esi
  801317:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  80131e:	00 00 00 
  801321:	b8 00 00 00 00       	mov    $0x0,%eax
  801326:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  80132d:	00 00 00 
  801330:	41 ff d1             	callq  *%r9

0000000000801333 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801333:	55                   	push   %rbp
  801334:	48 89 e5             	mov    %rsp,%rbp
  801337:	53                   	push   %rbx
  801338:	48 83 ec 08          	sub    $0x8,%rsp
  80133c:	41 89 f9             	mov    %edi,%r9d
  80133f:	49 89 f2             	mov    %rsi,%r10
  801342:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801345:	4d 63 c9             	movslq %r9d,%r9
  801348:	48 63 da             	movslq %edx,%rbx
  80134b:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80134e:	b8 05 00 00 00       	mov    $0x5,%eax
  801353:	4c 89 ca             	mov    %r9,%rdx
  801356:	4c 89 d1             	mov    %r10,%rcx
  801359:	cd 30                	int    $0x30
  if (check && ret > 0)
  80135b:	48 85 c0             	test   %rax,%rax
  80135e:	7f 07                	jg     801367 <sys_page_map+0x34>
}
  801360:	48 83 c4 08          	add    $0x8,%rsp
  801364:	5b                   	pop    %rbx
  801365:	5d                   	pop    %rbp
  801366:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801367:	49 89 c0             	mov    %rax,%r8
  80136a:	b9 05 00 00 00       	mov    $0x5,%ecx
  80136f:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  801376:	00 00 00 
  801379:	be 22 00 00 00       	mov    $0x22,%esi
  80137e:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  801385:	00 00 00 
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  801394:	00 00 00 
  801397:	41 ff d1             	callq  *%r9

000000000080139a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80139a:	55                   	push   %rbp
  80139b:	48 89 e5             	mov    %rsp,%rbp
  80139e:	53                   	push   %rbx
  80139f:	48 83 ec 08          	sub    $0x8,%rsp
  8013a3:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8013a6:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8013a9:	be 00 00 00 00       	mov    $0x0,%esi
  8013ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b3:	48 89 f3             	mov    %rsi,%rbx
  8013b6:	48 89 f7             	mov    %rsi,%rdi
  8013b9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013bb:	48 85 c0             	test   %rax,%rax
  8013be:	7f 07                	jg     8013c7 <sys_page_unmap+0x2d>
}
  8013c0:	48 83 c4 08          	add    $0x8,%rsp
  8013c4:	5b                   	pop    %rbx
  8013c5:	5d                   	pop    %rbp
  8013c6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013c7:	49 89 c0             	mov    %rax,%r8
  8013ca:	b9 06 00 00 00       	mov    $0x6,%ecx
  8013cf:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  8013d6:	00 00 00 
  8013d9:	be 22 00 00 00       	mov    $0x22,%esi
  8013de:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  8013e5:	00 00 00 
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ed:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  8013f4:	00 00 00 
  8013f7:	41 ff d1             	callq  *%r9

00000000008013fa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8013fa:	55                   	push   %rbp
  8013fb:	48 89 e5             	mov    %rsp,%rbp
  8013fe:	53                   	push   %rbx
  8013ff:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801403:	48 63 d7             	movslq %edi,%rdx
  801406:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801409:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140e:	b8 08 00 00 00       	mov    $0x8,%eax
  801413:	48 89 df             	mov    %rbx,%rdi
  801416:	48 89 de             	mov    %rbx,%rsi
  801419:	cd 30                	int    $0x30
  if (check && ret > 0)
  80141b:	48 85 c0             	test   %rax,%rax
  80141e:	7f 07                	jg     801427 <sys_env_set_status+0x2d>
}
  801420:	48 83 c4 08          	add    $0x8,%rsp
  801424:	5b                   	pop    %rbx
  801425:	5d                   	pop    %rbp
  801426:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801427:	49 89 c0             	mov    %rax,%r8
  80142a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80142f:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  801436:	00 00 00 
  801439:	be 22 00 00 00       	mov    $0x22,%esi
  80143e:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  801445:	00 00 00 
  801448:	b8 00 00 00 00       	mov    $0x0,%eax
  80144d:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  801454:	00 00 00 
  801457:	41 ff d1             	callq  *%r9

000000000080145a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80145a:	55                   	push   %rbp
  80145b:	48 89 e5             	mov    %rsp,%rbp
  80145e:	53                   	push   %rbx
  80145f:	48 83 ec 08          	sub    $0x8,%rsp
  801463:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801466:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801469:	be 00 00 00 00       	mov    $0x0,%esi
  80146e:	b8 09 00 00 00       	mov    $0x9,%eax
  801473:	48 89 f3             	mov    %rsi,%rbx
  801476:	48 89 f7             	mov    %rsi,%rdi
  801479:	cd 30                	int    $0x30
  if (check && ret > 0)
  80147b:	48 85 c0             	test   %rax,%rax
  80147e:	7f 07                	jg     801487 <sys_env_set_pgfault_upcall+0x2d>
}
  801480:	48 83 c4 08          	add    $0x8,%rsp
  801484:	5b                   	pop    %rbx
  801485:	5d                   	pop    %rbp
  801486:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801487:	49 89 c0             	mov    %rax,%r8
  80148a:	b9 09 00 00 00       	mov    $0x9,%ecx
  80148f:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  801496:	00 00 00 
  801499:	be 22 00 00 00       	mov    $0x22,%esi
  80149e:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  8014a5:	00 00 00 
  8014a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ad:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  8014b4:	00 00 00 
  8014b7:	41 ff d1             	callq  *%r9

00000000008014ba <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8014ba:	55                   	push   %rbp
  8014bb:	48 89 e5             	mov    %rsp,%rbp
  8014be:	53                   	push   %rbx
  8014bf:	49 89 f0             	mov    %rsi,%r8
  8014c2:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8014c5:	48 63 d7             	movslq %edi,%rdx
  8014c8:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8014cb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014d0:	be 00 00 00 00       	mov    $0x0,%esi
  8014d5:	4c 89 c1             	mov    %r8,%rcx
  8014d8:	cd 30                	int    $0x30
}
  8014da:	5b                   	pop    %rbx
  8014db:	5d                   	pop    %rbp
  8014dc:	c3                   	retq   

00000000008014dd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8014dd:	55                   	push   %rbp
  8014de:	48 89 e5             	mov    %rsp,%rbp
  8014e1:	53                   	push   %rbx
  8014e2:	48 83 ec 08          	sub    $0x8,%rsp
  8014e6:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8014e9:	be 00 00 00 00       	mov    $0x0,%esi
  8014ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014f3:	48 89 f1             	mov    %rsi,%rcx
  8014f6:	48 89 f3             	mov    %rsi,%rbx
  8014f9:	48 89 f7             	mov    %rsi,%rdi
  8014fc:	cd 30                	int    $0x30
  if (check && ret > 0)
  8014fe:	48 85 c0             	test   %rax,%rax
  801501:	7f 07                	jg     80150a <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  801503:	48 83 c4 08          	add    $0x8,%rsp
  801507:	5b                   	pop    %rbx
  801508:	5d                   	pop    %rbp
  801509:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80150a:	49 89 c0             	mov    %rax,%r8
  80150d:	b9 0c 00 00 00       	mov    $0xc,%ecx
  801512:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  801519:	00 00 00 
  80151c:	be 22 00 00 00       	mov    $0x22,%esi
  801521:	48 bf 40 1a 80 00 00 	movabs $0x801a40,%rdi
  801528:	00 00 00 
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
  801530:	49 b9 5c 02 80 00 00 	movabs $0x80025c,%r9
  801537:	00 00 00 
  80153a:	41 ff d1             	callq  *%r9
  80153d:	0f 1f 00             	nopl   (%rax)
