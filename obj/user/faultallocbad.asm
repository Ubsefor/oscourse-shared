
obj/user/faultallocbad:     file format elf64-x86-64


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
  800023:	e8 e1 00 00 00       	callq  800109 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <handler>:
// doesn't work because we sys_cputs instead of cprintf (exercise: why?)

#include <inc/lib.h>

void
handler(struct UTrapframe *utf) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	53                   	push   %rbx
  80002f:	48 83 ec 08          	sub    $0x8,%rsp
  int r;
  void *addr = (void *)utf->utf_fault_va;
  800033:	48 8b 1f             	mov    (%rdi),%rbx

  cprintf("fault %lx\n", (unsigned long)addr);
  800036:	48 89 de             	mov    %rbx,%rsi
  800039:	48 bf c0 15 80 00 00 	movabs $0x8015c0,%rdi
  800040:	00 00 00 
  800043:	b8 00 00 00 00       	mov    $0x0,%eax
  800048:	48 ba 78 03 80 00 00 	movabs $0x800378,%rdx
  80004f:	00 00 00 
  800052:	ff d2                	callq  *%rdx
  if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	48 89 de             	mov    %rbx,%rsi
  800057:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  80005e:	ba 07 00 00 00       	mov    $0x7,%edx
  800063:	bf 00 00 00 00       	mov    $0x0,%edi
  800068:	48 b8 4a 12 80 00 00 	movabs $0x80124a,%rax
  80006f:	00 00 00 
  800072:	ff d0                	callq  *%rax
  800074:	85 c0                	test   %eax,%eax
  800076:	78 2e                	js     8000a6 <handler+0x7c>
                          PTE_P | PTE_U | PTE_W)) < 0)
    panic("allocating at %lx in page fault handler: %i", (unsigned long)addr, r);
  snprintf((char *)addr, 100, "this string was faulted in at %lx", (unsigned long)addr);
  800078:	48 89 d9             	mov    %rbx,%rcx
  80007b:	48 ba 10 16 80 00 00 	movabs $0x801610,%rdx
  800082:	00 00 00 
  800085:	be 64 00 00 00       	mov    $0x64,%esi
  80008a:	48 89 df             	mov    %rbx,%rdi
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
  800092:	49 b8 65 0c 80 00 00 	movabs $0x800c65,%r8
  800099:	00 00 00 
  80009c:	41 ff d0             	callq  *%r8
}
  80009f:	48 83 c4 08          	add    $0x8,%rsp
  8000a3:	5b                   	pop    %rbx
  8000a4:	5d                   	pop    %rbp
  8000a5:	c3                   	retq   
    panic("allocating at %lx in page fault handler: %i", (unsigned long)addr, r);
  8000a6:	41 89 c0             	mov    %eax,%r8d
  8000a9:	48 89 d9             	mov    %rbx,%rcx
  8000ac:	48 ba e0 15 80 00 00 	movabs $0x8015e0,%rdx
  8000b3:	00 00 00 
  8000b6:	be 0e 00 00 00       	mov    $0xe,%esi
  8000bb:	48 bf cb 15 80 00 00 	movabs $0x8015cb,%rdi
  8000c2:	00 00 00 
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  8000d1:	00 00 00 
  8000d4:	41 ff d1             	callq  *%r9

00000000008000d7 <umain>:

void
umain(int argc, char **argv) {
  8000d7:	55                   	push   %rbp
  8000d8:	48 89 e5             	mov    %rsp,%rbp
  set_pgfault_handler(handler);
  8000db:	48 bf 2a 00 80 00 00 	movabs $0x80002a,%rdi
  8000e2:	00 00 00 
  8000e5:	48 b8 b7 14 80 00 00 	movabs $0x8014b7,%rax
  8000ec:	00 00 00 
  8000ef:	ff d0                	callq  *%rax
  sys_cputs((char *)0xDEADBEEF, 4);
  8000f1:	be 04 00 00 00       	mov    $0x4,%esi
  8000f6:	bf ef be ad de       	mov    $0xdeadbeef,%edi
  8000fb:	48 b8 6c 11 80 00 00 	movabs $0x80116c,%rax
  800102:	00 00 00 
  800105:	ff d0                	callq  *%rax
}
  800107:	5d                   	pop    %rbp
  800108:	c3                   	retq   

0000000000800109 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800109:	55                   	push   %rbp
  80010a:	48 89 e5             	mov    %rsp,%rbp
  80010d:	41 56                	push   %r14
  80010f:	41 55                	push   %r13
  800111:	41 54                	push   %r12
  800113:	53                   	push   %rbx
  800114:	41 89 fd             	mov    %edi,%r13d
  800117:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80011a:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800121:	00 00 00 
  800124:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80012b:	00 00 00 
  80012e:	48 39 c2             	cmp    %rax,%rdx
  800131:	73 23                	jae    800156 <libmain+0x4d>
  800133:	48 89 d3             	mov    %rdx,%rbx
  800136:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80013a:	48 29 d0             	sub    %rdx,%rax
  80013d:	48 c1 e8 03          	shr    $0x3,%rax
  800141:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800146:	b8 00 00 00 00       	mov    $0x0,%eax
  80014b:	ff 13                	callq  *(%rbx)
    ctor++;
  80014d:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800151:	4c 39 e3             	cmp    %r12,%rbx
  800154:	75 f0                	jne    800146 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800156:	48 b8 0a 12 80 00 00 	movabs $0x80120a,%rax
  80015d:	00 00 00 
  800160:	ff d0                	callq  *%rax
  800162:	25 ff 03 00 00       	and    $0x3ff,%eax
  800167:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80016b:	48 c1 e0 05          	shl    $0x5,%rax
  80016f:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800176:	00 00 00 
  800179:	48 01 d0             	add    %rdx,%rax
  80017c:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  800183:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800186:	45 85 ed             	test   %r13d,%r13d
  800189:	7e 0d                	jle    800198 <libmain+0x8f>
    binaryname = argv[0];
  80018b:	49 8b 06             	mov    (%r14),%rax
  80018e:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800195:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800198:	4c 89 f6             	mov    %r14,%rsi
  80019b:	44 89 ef             	mov    %r13d,%edi
  80019e:	48 b8 d7 00 80 00 00 	movabs $0x8000d7,%rax
  8001a5:	00 00 00 
  8001a8:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8001aa:	48 b8 bf 01 80 00 00 	movabs $0x8001bf,%rax
  8001b1:	00 00 00 
  8001b4:	ff d0                	callq  *%rax
#endif
}
  8001b6:	5b                   	pop    %rbx
  8001b7:	41 5c                	pop    %r12
  8001b9:	41 5d                	pop    %r13
  8001bb:	41 5e                	pop    %r14
  8001bd:	5d                   	pop    %rbp
  8001be:	c3                   	retq   

00000000008001bf <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001bf:	55                   	push   %rbp
  8001c0:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8001c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8001c8:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  8001cf:	00 00 00 
  8001d2:	ff d0                	callq  *%rax
}
  8001d4:	5d                   	pop    %rbp
  8001d5:	c3                   	retq   

00000000008001d6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001d6:	55                   	push   %rbp
  8001d7:	48 89 e5             	mov    %rsp,%rbp
  8001da:	41 56                	push   %r14
  8001dc:	41 55                	push   %r13
  8001de:	41 54                	push   %r12
  8001e0:	53                   	push   %rbx
  8001e1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001e8:	49 89 fd             	mov    %rdi,%r13
  8001eb:	41 89 f6             	mov    %esi,%r14d
  8001ee:	49 89 d4             	mov    %rdx,%r12
  8001f1:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001f8:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001ff:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800206:	84 c0                	test   %al,%al
  800208:	74 26                	je     800230 <_panic+0x5a>
  80020a:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800211:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800218:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80021c:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800220:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800224:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800228:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80022c:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800230:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800237:	00 00 00 
  80023a:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800241:	00 00 00 
  800244:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800248:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80024f:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800256:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80025d:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800264:	00 00 00 
  800267:	48 8b 18             	mov    (%rax),%rbx
  80026a:	48 b8 0a 12 80 00 00 	movabs $0x80120a,%rax
  800271:	00 00 00 
  800274:	ff d0                	callq  *%rax
  800276:	45 89 f0             	mov    %r14d,%r8d
  800279:	4c 89 e9             	mov    %r13,%rcx
  80027c:	48 89 da             	mov    %rbx,%rdx
  80027f:	89 c6                	mov    %eax,%esi
  800281:	48 bf 40 16 80 00 00 	movabs $0x801640,%rdi
  800288:	00 00 00 
  80028b:	b8 00 00 00 00       	mov    $0x0,%eax
  800290:	48 bb 78 03 80 00 00 	movabs $0x800378,%rbx
  800297:	00 00 00 
  80029a:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80029c:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002a3:	4c 89 e7             	mov    %r12,%rdi
  8002a6:	48 b8 10 03 80 00 00 	movabs $0x800310,%rax
  8002ad:	00 00 00 
  8002b0:	ff d0                	callq  *%rax
  cprintf("\n");
  8002b2:	48 bf c9 15 80 00 00 	movabs $0x8015c9,%rdi
  8002b9:	00 00 00 
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c1:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002c3:	cc                   	int3   
  while (1)
  8002c4:	eb fd                	jmp    8002c3 <_panic+0xed>

00000000008002c6 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002c6:	55                   	push   %rbp
  8002c7:	48 89 e5             	mov    %rsp,%rbp
  8002ca:	53                   	push   %rbx
  8002cb:	48 83 ec 08          	sub    $0x8,%rsp
  8002cf:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002d2:	8b 06                	mov    (%rsi),%eax
  8002d4:	8d 50 01             	lea    0x1(%rax),%edx
  8002d7:	89 16                	mov    %edx,(%rsi)
  8002d9:	48 98                	cltq   
  8002db:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002e0:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002e6:	74 0b                	je     8002f3 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002e8:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002ec:	48 83 c4 08          	add    $0x8,%rsp
  8002f0:	5b                   	pop    %rbx
  8002f1:	5d                   	pop    %rbp
  8002f2:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002f3:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002f7:	be ff 00 00 00       	mov    $0xff,%esi
  8002fc:	48 b8 6c 11 80 00 00 	movabs $0x80116c,%rax
  800303:	00 00 00 
  800306:	ff d0                	callq  *%rax
    b->idx = 0;
  800308:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80030e:	eb d8                	jmp    8002e8 <putch+0x22>

0000000000800310 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800310:	55                   	push   %rbp
  800311:	48 89 e5             	mov    %rsp,%rbp
  800314:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80031b:	48 89 fa             	mov    %rdi,%rdx
  80031e:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800321:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800328:	00 00 00 
  b.cnt = 0;
  80032b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800332:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800335:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80033c:	48 bf c6 02 80 00 00 	movabs $0x8002c6,%rdi
  800343:	00 00 00 
  800346:	48 b8 36 05 80 00 00 	movabs $0x800536,%rax
  80034d:	00 00 00 
  800350:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800352:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800359:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800360:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800364:	48 b8 6c 11 80 00 00 	movabs $0x80116c,%rax
  80036b:	00 00 00 
  80036e:	ff d0                	callq  *%rax

  return b.cnt;
}
  800370:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800376:	c9                   	leaveq 
  800377:	c3                   	retq   

0000000000800378 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800378:	55                   	push   %rbp
  800379:	48 89 e5             	mov    %rsp,%rbp
  80037c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800383:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80038a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800391:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800398:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80039f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003a6:	84 c0                	test   %al,%al
  8003a8:	74 20                	je     8003ca <cprintf+0x52>
  8003aa:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003ae:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003b2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003b6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003ba:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003be:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003c2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003c6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003ca:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003d1:	00 00 00 
  8003d4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003db:	00 00 00 
  8003de:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003e2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003e9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003f0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003f7:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003fe:	48 b8 10 03 80 00 00 	movabs $0x800310,%rax
  800405:	00 00 00 
  800408:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80040a:	c9                   	leaveq 
  80040b:	c3                   	retq   

000000000080040c <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80040c:	55                   	push   %rbp
  80040d:	48 89 e5             	mov    %rsp,%rbp
  800410:	41 57                	push   %r15
  800412:	41 56                	push   %r14
  800414:	41 55                	push   %r13
  800416:	41 54                	push   %r12
  800418:	53                   	push   %rbx
  800419:	48 83 ec 18          	sub    $0x18,%rsp
  80041d:	49 89 fc             	mov    %rdi,%r12
  800420:	49 89 f5             	mov    %rsi,%r13
  800423:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800427:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80042a:	41 89 cf             	mov    %ecx,%r15d
  80042d:	49 39 d7             	cmp    %rdx,%r15
  800430:	76 45                	jbe    800477 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800432:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800436:	85 db                	test   %ebx,%ebx
  800438:	7e 0e                	jle    800448 <printnum+0x3c>
      putch(padc, putdat);
  80043a:	4c 89 ee             	mov    %r13,%rsi
  80043d:	44 89 f7             	mov    %r14d,%edi
  800440:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800443:	83 eb 01             	sub    $0x1,%ebx
  800446:	75 f2                	jne    80043a <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800448:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80044c:	ba 00 00 00 00       	mov    $0x0,%edx
  800451:	49 f7 f7             	div    %r15
  800454:	48 b8 63 16 80 00 00 	movabs $0x801663,%rax
  80045b:	00 00 00 
  80045e:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800462:	4c 89 ee             	mov    %r13,%rsi
  800465:	41 ff d4             	callq  *%r12
}
  800468:	48 83 c4 18          	add    $0x18,%rsp
  80046c:	5b                   	pop    %rbx
  80046d:	41 5c                	pop    %r12
  80046f:	41 5d                	pop    %r13
  800471:	41 5e                	pop    %r14
  800473:	41 5f                	pop    %r15
  800475:	5d                   	pop    %rbp
  800476:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800477:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	49 f7 f7             	div    %r15
  800483:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800487:	48 89 c2             	mov    %rax,%rdx
  80048a:	48 b8 0c 04 80 00 00 	movabs $0x80040c,%rax
  800491:	00 00 00 
  800494:	ff d0                	callq  *%rax
  800496:	eb b0                	jmp    800448 <printnum+0x3c>

0000000000800498 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800498:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80049c:	48 8b 06             	mov    (%rsi),%rax
  80049f:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004a3:	73 0a                	jae    8004af <sprintputch+0x17>
    *b->buf++ = ch;
  8004a5:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004a9:	48 89 16             	mov    %rdx,(%rsi)
  8004ac:	40 88 38             	mov    %dil,(%rax)
}
  8004af:	c3                   	retq   

00000000008004b0 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004b0:	55                   	push   %rbp
  8004b1:	48 89 e5             	mov    %rsp,%rbp
  8004b4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004bb:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004c2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004c9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004d0:	84 c0                	test   %al,%al
  8004d2:	74 20                	je     8004f4 <printfmt+0x44>
  8004d4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004d8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004dc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004e0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004e4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004e8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004ec:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004f0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004f4:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004fb:	00 00 00 
  8004fe:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800505:	00 00 00 
  800508:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80050c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800513:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80051a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800521:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800528:	48 b8 36 05 80 00 00 	movabs $0x800536,%rax
  80052f:	00 00 00 
  800532:	ff d0                	callq  *%rax
}
  800534:	c9                   	leaveq 
  800535:	c3                   	retq   

0000000000800536 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800536:	55                   	push   %rbp
  800537:	48 89 e5             	mov    %rsp,%rbp
  80053a:	41 57                	push   %r15
  80053c:	41 56                	push   %r14
  80053e:	41 55                	push   %r13
  800540:	41 54                	push   %r12
  800542:	53                   	push   %rbx
  800543:	48 83 ec 48          	sub    $0x48,%rsp
  800547:	49 89 fd             	mov    %rdi,%r13
  80054a:	49 89 f7             	mov    %rsi,%r15
  80054d:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800550:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800554:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800558:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80055c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800560:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800564:	41 0f b6 3e          	movzbl (%r14),%edi
  800568:	83 ff 25             	cmp    $0x25,%edi
  80056b:	74 18                	je     800585 <vprintfmt+0x4f>
      if (ch == '\0')
  80056d:	85 ff                	test   %edi,%edi
  80056f:	0f 84 8c 06 00 00    	je     800c01 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800575:	4c 89 fe             	mov    %r15,%rsi
  800578:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80057b:	49 89 de             	mov    %rbx,%r14
  80057e:	eb e0                	jmp    800560 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800580:	49 89 de             	mov    %rbx,%r14
  800583:	eb db                	jmp    800560 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800585:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800589:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80058d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800594:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80059a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80059e:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005a3:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005a9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005af:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005b4:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005b9:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005bd:	0f b6 13             	movzbl (%rbx),%edx
  8005c0:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005c3:	3c 55                	cmp    $0x55,%al
  8005c5:	0f 87 8b 05 00 00    	ja     800b56 <vprintfmt+0x620>
  8005cb:	0f b6 c0             	movzbl %al,%eax
  8005ce:	49 bb 40 17 80 00 00 	movabs $0x801740,%r11
  8005d5:	00 00 00 
  8005d8:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005dc:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005df:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005e3:	eb d4                	jmp    8005b9 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005e5:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005e8:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005ec:	eb cb                	jmp    8005b9 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005ee:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005f1:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005f5:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005f9:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005fc:	83 fa 09             	cmp    $0x9,%edx
  8005ff:	77 7e                	ja     80067f <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800601:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800605:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800609:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80060e:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800612:	8d 50 d0             	lea    -0x30(%rax),%edx
  800615:	83 fa 09             	cmp    $0x9,%edx
  800618:	76 e7                	jbe    800601 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80061a:	4c 89 f3             	mov    %r14,%rbx
  80061d:	eb 19                	jmp    800638 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80061f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800622:	83 f8 2f             	cmp    $0x2f,%eax
  800625:	77 2a                	ja     800651 <vprintfmt+0x11b>
  800627:	89 c2                	mov    %eax,%edx
  800629:	4c 01 d2             	add    %r10,%rdx
  80062c:	83 c0 08             	add    $0x8,%eax
  80062f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800632:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800635:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800638:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80063c:	0f 89 77 ff ff ff    	jns    8005b9 <vprintfmt+0x83>
          width = precision, precision = -1;
  800642:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800646:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80064c:	e9 68 ff ff ff       	jmpq   8005b9 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800651:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800655:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800659:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80065d:	eb d3                	jmp    800632 <vprintfmt+0xfc>
        if (width < 0)
  80065f:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800662:	85 c0                	test   %eax,%eax
  800664:	41 0f 48 c0          	cmovs  %r8d,%eax
  800668:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80066b:	4c 89 f3             	mov    %r14,%rbx
  80066e:	e9 46 ff ff ff       	jmpq   8005b9 <vprintfmt+0x83>
  800673:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800676:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80067a:	e9 3a ff ff ff       	jmpq   8005b9 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80067f:	4c 89 f3             	mov    %r14,%rbx
  800682:	eb b4                	jmp    800638 <vprintfmt+0x102>
        lflag++;
  800684:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800687:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80068a:	e9 2a ff ff ff       	jmpq   8005b9 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80068f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800692:	83 f8 2f             	cmp    $0x2f,%eax
  800695:	77 19                	ja     8006b0 <vprintfmt+0x17a>
  800697:	89 c2                	mov    %eax,%edx
  800699:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80069d:	83 c0 08             	add    $0x8,%eax
  8006a0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006a3:	4c 89 fe             	mov    %r15,%rsi
  8006a6:	8b 3a                	mov    (%rdx),%edi
  8006a8:	41 ff d5             	callq  *%r13
        break;
  8006ab:	e9 b0 fe ff ff       	jmpq   800560 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006b0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006b4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006b8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006bc:	eb e5                	jmp    8006a3 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006be:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006c1:	83 f8 2f             	cmp    $0x2f,%eax
  8006c4:	77 5b                	ja     800721 <vprintfmt+0x1eb>
  8006c6:	89 c2                	mov    %eax,%edx
  8006c8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006cc:	83 c0 08             	add    $0x8,%eax
  8006cf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006d2:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006d4:	89 c8                	mov    %ecx,%eax
  8006d6:	c1 f8 1f             	sar    $0x1f,%eax
  8006d9:	31 c1                	xor    %eax,%ecx
  8006db:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006dd:	83 f9 0b             	cmp    $0xb,%ecx
  8006e0:	7f 4d                	jg     80072f <vprintfmt+0x1f9>
  8006e2:	48 63 c1             	movslq %ecx,%rax
  8006e5:	48 ba 00 1a 80 00 00 	movabs $0x801a00,%rdx
  8006ec:	00 00 00 
  8006ef:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006f3:	48 85 c0             	test   %rax,%rax
  8006f6:	74 37                	je     80072f <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006f8:	48 89 c1             	mov    %rax,%rcx
  8006fb:	48 ba 84 16 80 00 00 	movabs $0x801684,%rdx
  800702:	00 00 00 
  800705:	4c 89 fe             	mov    %r15,%rsi
  800708:	4c 89 ef             	mov    %r13,%rdi
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
  800710:	48 bb b0 04 80 00 00 	movabs $0x8004b0,%rbx
  800717:	00 00 00 
  80071a:	ff d3                	callq  *%rbx
  80071c:	e9 3f fe ff ff       	jmpq   800560 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800721:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800725:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800729:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80072d:	eb a3                	jmp    8006d2 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80072f:	48 ba 7b 16 80 00 00 	movabs $0x80167b,%rdx
  800736:	00 00 00 
  800739:	4c 89 fe             	mov    %r15,%rsi
  80073c:	4c 89 ef             	mov    %r13,%rdi
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	48 bb b0 04 80 00 00 	movabs $0x8004b0,%rbx
  80074b:	00 00 00 
  80074e:	ff d3                	callq  *%rbx
  800750:	e9 0b fe ff ff       	jmpq   800560 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800755:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800758:	83 f8 2f             	cmp    $0x2f,%eax
  80075b:	77 4b                	ja     8007a8 <vprintfmt+0x272>
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800763:	83 c0 08             	add    $0x8,%eax
  800766:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800769:	48 8b 02             	mov    (%rdx),%rax
  80076c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800770:	48 85 c0             	test   %rax,%rax
  800773:	0f 84 05 04 00 00    	je     800b7e <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800779:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80077d:	7e 06                	jle    800785 <vprintfmt+0x24f>
  80077f:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800783:	75 31                	jne    8007b6 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800785:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800789:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80078d:	0f b6 00             	movzbl (%rax),%eax
  800790:	0f be f8             	movsbl %al,%edi
  800793:	85 ff                	test   %edi,%edi
  800795:	0f 84 c3 00 00 00    	je     80085e <vprintfmt+0x328>
  80079b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80079f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007a3:	e9 85 00 00 00       	jmpq   80082d <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007a8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007b0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b4:	eb b3                	jmp    800769 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007b6:	49 63 f4             	movslq %r12d,%rsi
  8007b9:	48 89 c7             	mov    %rax,%rdi
  8007bc:	48 b8 0d 0d 80 00 00 	movabs $0x800d0d,%rax
  8007c3:	00 00 00 
  8007c6:	ff d0                	callq  *%rax
  8007c8:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007cb:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007ce:	85 f6                	test   %esi,%esi
  8007d0:	7e 22                	jle    8007f4 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007d2:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007d6:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007da:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007de:	4c 89 fe             	mov    %r15,%rsi
  8007e1:	89 df                	mov    %ebx,%edi
  8007e3:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007e6:	41 83 ec 01          	sub    $0x1,%r12d
  8007ea:	75 f2                	jne    8007de <vprintfmt+0x2a8>
  8007ec:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007f0:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007f8:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007fc:	0f b6 00             	movzbl (%rax),%eax
  8007ff:	0f be f8             	movsbl %al,%edi
  800802:	85 ff                	test   %edi,%edi
  800804:	0f 84 56 fd ff ff    	je     800560 <vprintfmt+0x2a>
  80080a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80080e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800812:	eb 19                	jmp    80082d <vprintfmt+0x2f7>
            putch(ch, putdat);
  800814:	4c 89 fe             	mov    %r15,%rsi
  800817:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80081a:	41 83 ee 01          	sub    $0x1,%r14d
  80081e:	48 83 c3 01          	add    $0x1,%rbx
  800822:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800826:	0f be f8             	movsbl %al,%edi
  800829:	85 ff                	test   %edi,%edi
  80082b:	74 29                	je     800856 <vprintfmt+0x320>
  80082d:	45 85 e4             	test   %r12d,%r12d
  800830:	78 06                	js     800838 <vprintfmt+0x302>
  800832:	41 83 ec 01          	sub    $0x1,%r12d
  800836:	78 48                	js     800880 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800838:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80083c:	74 d6                	je     800814 <vprintfmt+0x2de>
  80083e:	0f be c0             	movsbl %al,%eax
  800841:	83 e8 20             	sub    $0x20,%eax
  800844:	83 f8 5e             	cmp    $0x5e,%eax
  800847:	76 cb                	jbe    800814 <vprintfmt+0x2de>
            putch('?', putdat);
  800849:	4c 89 fe             	mov    %r15,%rsi
  80084c:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800851:	41 ff d5             	callq  *%r13
  800854:	eb c4                	jmp    80081a <vprintfmt+0x2e4>
  800856:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80085a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80085e:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800861:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800865:	0f 8e f5 fc ff ff    	jle    800560 <vprintfmt+0x2a>
          putch(' ', putdat);
  80086b:	4c 89 fe             	mov    %r15,%rsi
  80086e:	bf 20 00 00 00       	mov    $0x20,%edi
  800873:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800876:	83 eb 01             	sub    $0x1,%ebx
  800879:	75 f0                	jne    80086b <vprintfmt+0x335>
  80087b:	e9 e0 fc ff ff       	jmpq   800560 <vprintfmt+0x2a>
  800880:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800884:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800888:	eb d4                	jmp    80085e <vprintfmt+0x328>
  if (lflag >= 2)
  80088a:	83 f9 01             	cmp    $0x1,%ecx
  80088d:	7f 1d                	jg     8008ac <vprintfmt+0x376>
  else if (lflag)
  80088f:	85 c9                	test   %ecx,%ecx
  800891:	74 5e                	je     8008f1 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800893:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800896:	83 f8 2f             	cmp    $0x2f,%eax
  800899:	77 48                	ja     8008e3 <vprintfmt+0x3ad>
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a1:	83 c0 08             	add    $0x8,%eax
  8008a4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a7:	48 8b 1a             	mov    (%rdx),%rbx
  8008aa:	eb 17                	jmp    8008c3 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008ac:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008af:	83 f8 2f             	cmp    $0x2f,%eax
  8008b2:	77 21                	ja     8008d5 <vprintfmt+0x39f>
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ba:	83 c0 08             	add    $0x8,%eax
  8008bd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c0:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008c3:	48 85 db             	test   %rbx,%rbx
  8008c6:	78 50                	js     800918 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008c8:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008d0:	e9 b4 01 00 00       	jmpq   800a89 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008d5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008dd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e1:	eb dd                	jmp    8008c0 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008e3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008eb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ef:	eb b6                	jmp    8008a7 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f4:	83 f8 2f             	cmp    $0x2f,%eax
  8008f7:	77 11                	ja     80090a <vprintfmt+0x3d4>
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ff:	83 c0 08             	add    $0x8,%eax
  800902:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800905:	48 63 1a             	movslq (%rdx),%rbx
  800908:	eb b9                	jmp    8008c3 <vprintfmt+0x38d>
  80090a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800912:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800916:	eb ed                	jmp    800905 <vprintfmt+0x3cf>
          putch('-', putdat);
  800918:	4c 89 fe             	mov    %r15,%rsi
  80091b:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800920:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800923:	48 89 da             	mov    %rbx,%rdx
  800926:	48 f7 da             	neg    %rdx
        base = 10;
  800929:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092e:	e9 56 01 00 00       	jmpq   800a89 <vprintfmt+0x553>
  if (lflag >= 2)
  800933:	83 f9 01             	cmp    $0x1,%ecx
  800936:	7f 25                	jg     80095d <vprintfmt+0x427>
  else if (lflag)
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	74 5e                	je     80099a <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80093c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093f:	83 f8 2f             	cmp    $0x2f,%eax
  800942:	77 48                	ja     80098c <vprintfmt+0x456>
  800944:	89 c2                	mov    %eax,%edx
  800946:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094a:	83 c0 08             	add    $0x8,%eax
  80094d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800950:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800953:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800958:	e9 2c 01 00 00       	jmpq   800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80095d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800960:	83 f8 2f             	cmp    $0x2f,%eax
  800963:	77 19                	ja     80097e <vprintfmt+0x448>
  800965:	89 c2                	mov    %eax,%edx
  800967:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096b:	83 c0 08             	add    $0x8,%eax
  80096e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800971:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800974:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800979:	e9 0b 01 00 00       	jmpq   800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80097e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800982:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800986:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80098a:	eb e5                	jmp    800971 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80098c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800990:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800994:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800998:	eb b6                	jmp    800950 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80099a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099d:	83 f8 2f             	cmp    $0x2f,%eax
  8009a0:	77 18                	ja     8009ba <vprintfmt+0x484>
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a8:	83 c0 08             	add    $0x8,%eax
  8009ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ae:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b5:	e9 cf 00 00 00       	jmpq   800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009ba:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009be:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c6:	eb e6                	jmp    8009ae <vprintfmt+0x478>
  if (lflag >= 2)
  8009c8:	83 f9 01             	cmp    $0x1,%ecx
  8009cb:	7f 25                	jg     8009f2 <vprintfmt+0x4bc>
  else if (lflag)
  8009cd:	85 c9                	test   %ecx,%ecx
  8009cf:	74 5b                	je     800a2c <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009d1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d4:	83 f8 2f             	cmp    $0x2f,%eax
  8009d7:	77 45                	ja     800a1e <vprintfmt+0x4e8>
  8009d9:	89 c2                	mov    %eax,%edx
  8009db:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009df:	83 c0 08             	add    $0x8,%eax
  8009e2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e5:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009e8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009ed:	e9 97 00 00 00       	jmpq   800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f5:	83 f8 2f             	cmp    $0x2f,%eax
  8009f8:	77 16                	ja     800a10 <vprintfmt+0x4da>
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a00:	83 c0 08             	add    $0x8,%eax
  800a03:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a06:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a09:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a0e:	eb 79                	jmp    800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a10:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a14:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a18:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a1c:	eb e8                	jmp    800a06 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a1e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a22:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a26:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a2a:	eb b9                	jmp    8009e5 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a2c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a2f:	83 f8 2f             	cmp    $0x2f,%eax
  800a32:	77 15                	ja     800a49 <vprintfmt+0x513>
  800a34:	89 c2                	mov    %eax,%edx
  800a36:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a3a:	83 c0 08             	add    $0x8,%eax
  800a3d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a40:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a42:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a47:	eb 40                	jmp    800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a49:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a4d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a51:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a55:	eb e9                	jmp    800a40 <vprintfmt+0x50a>
        putch('0', putdat);
  800a57:	4c 89 fe             	mov    %r15,%rsi
  800a5a:	bf 30 00 00 00       	mov    $0x30,%edi
  800a5f:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a62:	4c 89 fe             	mov    %r15,%rsi
  800a65:	bf 78 00 00 00       	mov    $0x78,%edi
  800a6a:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a6d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a70:	83 f8 2f             	cmp    $0x2f,%eax
  800a73:	77 34                	ja     800aa9 <vprintfmt+0x573>
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a7b:	83 c0 08             	add    $0x8,%eax
  800a7e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a81:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a84:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a89:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a8e:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a92:	4c 89 fe             	mov    %r15,%rsi
  800a95:	4c 89 ef             	mov    %r13,%rdi
  800a98:	48 b8 0c 04 80 00 00 	movabs $0x80040c,%rax
  800a9f:	00 00 00 
  800aa2:	ff d0                	callq  *%rax
        break;
  800aa4:	e9 b7 fa ff ff       	jmpq   800560 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800aa9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aad:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ab5:	eb ca                	jmp    800a81 <vprintfmt+0x54b>
  if (lflag >= 2)
  800ab7:	83 f9 01             	cmp    $0x1,%ecx
  800aba:	7f 22                	jg     800ade <vprintfmt+0x5a8>
  else if (lflag)
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	74 58                	je     800b18 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800ac0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ac3:	83 f8 2f             	cmp    $0x2f,%eax
  800ac6:	77 42                	ja     800b0a <vprintfmt+0x5d4>
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ace:	83 c0 08             	add    $0x8,%eax
  800ad1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ad4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ad7:	b9 10 00 00 00       	mov    $0x10,%ecx
  800adc:	eb ab                	jmp    800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ade:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae1:	83 f8 2f             	cmp    $0x2f,%eax
  800ae4:	77 16                	ja     800afc <vprintfmt+0x5c6>
  800ae6:	89 c2                	mov    %eax,%edx
  800ae8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aec:	83 c0 08             	add    $0x8,%eax
  800aef:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af2:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800af5:	b9 10 00 00 00       	mov    $0x10,%ecx
  800afa:	eb 8d                	jmp    800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800afc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b00:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b04:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b08:	eb e8                	jmp    800af2 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b0a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b0e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b12:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b16:	eb bc                	jmp    800ad4 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b18:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1b:	83 f8 2f             	cmp    $0x2f,%eax
  800b1e:	77 18                	ja     800b38 <vprintfmt+0x602>
  800b20:	89 c2                	mov    %eax,%edx
  800b22:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b26:	83 c0 08             	add    $0x8,%eax
  800b29:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2c:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b2e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b33:	e9 51 ff ff ff       	jmpq   800a89 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b38:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b3c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b40:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b44:	eb e6                	jmp    800b2c <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b46:	4c 89 fe             	mov    %r15,%rsi
  800b49:	bf 25 00 00 00       	mov    $0x25,%edi
  800b4e:	41 ff d5             	callq  *%r13
        break;
  800b51:	e9 0a fa ff ff       	jmpq   800560 <vprintfmt+0x2a>
        putch('%', putdat);
  800b56:	4c 89 fe             	mov    %r15,%rsi
  800b59:	bf 25 00 00 00       	mov    $0x25,%edi
  800b5e:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b61:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b65:	0f 84 15 fa ff ff    	je     800580 <vprintfmt+0x4a>
  800b6b:	49 89 de             	mov    %rbx,%r14
  800b6e:	49 83 ee 01          	sub    $0x1,%r14
  800b72:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b77:	75 f5                	jne    800b6e <vprintfmt+0x638>
  800b79:	e9 e2 f9 ff ff       	jmpq   800560 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b7e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b82:	74 06                	je     800b8a <vprintfmt+0x654>
  800b84:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b88:	7f 21                	jg     800bab <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b8a:	bf 28 00 00 00       	mov    $0x28,%edi
  800b8f:	48 bb 75 16 80 00 00 	movabs $0x801675,%rbx
  800b96:	00 00 00 
  800b99:	b8 28 00 00 00       	mov    $0x28,%eax
  800b9e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ba2:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800ba6:	e9 82 fc ff ff       	jmpq   80082d <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800bab:	49 63 f4             	movslq %r12d,%rsi
  800bae:	48 bf 74 16 80 00 00 	movabs $0x801674,%rdi
  800bb5:	00 00 00 
  800bb8:	48 b8 0d 0d 80 00 00 	movabs $0x800d0d,%rax
  800bbf:	00 00 00 
  800bc2:	ff d0                	callq  *%rax
  800bc4:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bc7:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bca:	48 be 74 16 80 00 00 	movabs $0x801674,%rsi
  800bd1:	00 00 00 
  800bd4:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	0f 8f f2 fb ff ff    	jg     8007d2 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800be0:	48 bb 75 16 80 00 00 	movabs $0x801675,%rbx
  800be7:	00 00 00 
  800bea:	b8 28 00 00 00       	mov    $0x28,%eax
  800bef:	bf 28 00 00 00       	mov    $0x28,%edi
  800bf4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bf8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bfc:	e9 2c fc ff ff       	jmpq   80082d <vprintfmt+0x2f7>
}
  800c01:	48 83 c4 48          	add    $0x48,%rsp
  800c05:	5b                   	pop    %rbx
  800c06:	41 5c                	pop    %r12
  800c08:	41 5d                	pop    %r13
  800c0a:	41 5e                	pop    %r14
  800c0c:	41 5f                	pop    %r15
  800c0e:	5d                   	pop    %rbp
  800c0f:	c3                   	retq   

0000000000800c10 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c10:	55                   	push   %rbp
  800c11:	48 89 e5             	mov    %rsp,%rbp
  800c14:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c18:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c1c:	48 63 c6             	movslq %esi,%rax
  800c1f:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c24:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c2f:	48 85 ff             	test   %rdi,%rdi
  800c32:	74 2a                	je     800c5e <vsnprintf+0x4e>
  800c34:	85 f6                	test   %esi,%esi
  800c36:	7e 26                	jle    800c5e <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c38:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c3c:	48 bf 98 04 80 00 00 	movabs $0x800498,%rdi
  800c43:	00 00 00 
  800c46:	48 b8 36 05 80 00 00 	movabs $0x800536,%rax
  800c4d:	00 00 00 
  800c50:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c52:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c56:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c59:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c5c:	c9                   	leaveq 
  800c5d:	c3                   	retq   
    return -E_INVAL;
  800c5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c63:	eb f7                	jmp    800c5c <vsnprintf+0x4c>

0000000000800c65 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c65:	55                   	push   %rbp
  800c66:	48 89 e5             	mov    %rsp,%rbp
  800c69:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c70:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c77:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c7e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c85:	84 c0                	test   %al,%al
  800c87:	74 20                	je     800ca9 <snprintf+0x44>
  800c89:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c8d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c91:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c95:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c99:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c9d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ca1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ca5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ca9:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800cb0:	00 00 00 
  800cb3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800cba:	00 00 00 
  800cbd:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cc1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cc8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800ccf:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cd6:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cdd:	48 b8 10 0c 80 00 00 	movabs $0x800c10,%rax
  800ce4:	00 00 00 
  800ce7:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800ce9:	c9                   	leaveq 
  800cea:	c3                   	retq   

0000000000800ceb <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800ceb:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cee:	74 17                	je     800d07 <strlen+0x1c>
  800cf0:	48 89 fa             	mov    %rdi,%rdx
  800cf3:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cf8:	29 f9                	sub    %edi,%ecx
    n++;
  800cfa:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cfd:	48 83 c2 01          	add    $0x1,%rdx
  800d01:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d04:	75 f4                	jne    800cfa <strlen+0xf>
  800d06:	c3                   	retq   
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d0c:	c3                   	retq   

0000000000800d0d <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0d:	48 85 f6             	test   %rsi,%rsi
  800d10:	74 24                	je     800d36 <strnlen+0x29>
  800d12:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d15:	74 25                	je     800d3c <strnlen+0x2f>
  800d17:	48 01 fe             	add    %rdi,%rsi
  800d1a:	48 89 fa             	mov    %rdi,%rdx
  800d1d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d22:	29 f9                	sub    %edi,%ecx
    n++;
  800d24:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d27:	48 83 c2 01          	add    $0x1,%rdx
  800d2b:	48 39 f2             	cmp    %rsi,%rdx
  800d2e:	74 11                	je     800d41 <strnlen+0x34>
  800d30:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d33:	75 ef                	jne    800d24 <strnlen+0x17>
  800d35:	c3                   	retq   
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3b:	c3                   	retq   
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d41:	c3                   	retq   

0000000000800d42 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d42:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d45:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4a:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d4e:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d51:	48 83 c2 01          	add    $0x1,%rdx
  800d55:	84 c9                	test   %cl,%cl
  800d57:	75 f1                	jne    800d4a <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d59:	c3                   	retq   

0000000000800d5a <strcat>:

char *
strcat(char *dst, const char *src) {
  800d5a:	55                   	push   %rbp
  800d5b:	48 89 e5             	mov    %rsp,%rbp
  800d5e:	41 54                	push   %r12
  800d60:	53                   	push   %rbx
  800d61:	48 89 fb             	mov    %rdi,%rbx
  800d64:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d67:	48 b8 eb 0c 80 00 00 	movabs $0x800ceb,%rax
  800d6e:	00 00 00 
  800d71:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d73:	48 63 f8             	movslq %eax,%rdi
  800d76:	48 01 df             	add    %rbx,%rdi
  800d79:	4c 89 e6             	mov    %r12,%rsi
  800d7c:	48 b8 42 0d 80 00 00 	movabs $0x800d42,%rax
  800d83:	00 00 00 
  800d86:	ff d0                	callq  *%rax
  return dst;
}
  800d88:	48 89 d8             	mov    %rbx,%rax
  800d8b:	5b                   	pop    %rbx
  800d8c:	41 5c                	pop    %r12
  800d8e:	5d                   	pop    %rbp
  800d8f:	c3                   	retq   

0000000000800d90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d90:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d93:	48 85 d2             	test   %rdx,%rdx
  800d96:	74 1f                	je     800db7 <strncpy+0x27>
  800d98:	48 01 fa             	add    %rdi,%rdx
  800d9b:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d9e:	48 83 c1 01          	add    $0x1,%rcx
  800da2:	44 0f b6 06          	movzbl (%rsi),%r8d
  800da6:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800daa:	41 80 f8 01          	cmp    $0x1,%r8b
  800dae:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800db2:	48 39 ca             	cmp    %rcx,%rdx
  800db5:	75 e7                	jne    800d9e <strncpy+0xe>
  }
  return ret;
}
  800db7:	c3                   	retq   

0000000000800db8 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800db8:	48 89 f8             	mov    %rdi,%rax
  800dbb:	48 85 d2             	test   %rdx,%rdx
  800dbe:	74 36                	je     800df6 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800dc0:	48 83 fa 01          	cmp    $0x1,%rdx
  800dc4:	74 2d                	je     800df3 <strlcpy+0x3b>
  800dc6:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dca:	45 84 c0             	test   %r8b,%r8b
  800dcd:	74 24                	je     800df3 <strlcpy+0x3b>
  800dcf:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dd3:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dd8:	48 83 c0 01          	add    $0x1,%rax
  800ddc:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800de0:	48 39 d1             	cmp    %rdx,%rcx
  800de3:	74 0e                	je     800df3 <strlcpy+0x3b>
  800de5:	48 83 c1 01          	add    $0x1,%rcx
  800de9:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dee:	45 84 c0             	test   %r8b,%r8b
  800df1:	75 e5                	jne    800dd8 <strlcpy+0x20>
    *dst = '\0';
  800df3:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800df6:	48 29 f8             	sub    %rdi,%rax
}
  800df9:	c3                   	retq   

0000000000800dfa <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dfa:	0f b6 07             	movzbl (%rdi),%eax
  800dfd:	84 c0                	test   %al,%al
  800dff:	74 17                	je     800e18 <strcmp+0x1e>
  800e01:	3a 06                	cmp    (%rsi),%al
  800e03:	75 13                	jne    800e18 <strcmp+0x1e>
    p++, q++;
  800e05:	48 83 c7 01          	add    $0x1,%rdi
  800e09:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e0d:	0f b6 07             	movzbl (%rdi),%eax
  800e10:	84 c0                	test   %al,%al
  800e12:	74 04                	je     800e18 <strcmp+0x1e>
  800e14:	3a 06                	cmp    (%rsi),%al
  800e16:	74 ed                	je     800e05 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e18:	0f b6 c0             	movzbl %al,%eax
  800e1b:	0f b6 16             	movzbl (%rsi),%edx
  800e1e:	29 d0                	sub    %edx,%eax
}
  800e20:	c3                   	retq   

0000000000800e21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e21:	48 85 d2             	test   %rdx,%rdx
  800e24:	74 2f                	je     800e55 <strncmp+0x34>
  800e26:	0f b6 07             	movzbl (%rdi),%eax
  800e29:	84 c0                	test   %al,%al
  800e2b:	74 1f                	je     800e4c <strncmp+0x2b>
  800e2d:	3a 06                	cmp    (%rsi),%al
  800e2f:	75 1b                	jne    800e4c <strncmp+0x2b>
  800e31:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e34:	48 83 c7 01          	add    $0x1,%rdi
  800e38:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e3c:	48 39 d7             	cmp    %rdx,%rdi
  800e3f:	74 1a                	je     800e5b <strncmp+0x3a>
  800e41:	0f b6 07             	movzbl (%rdi),%eax
  800e44:	84 c0                	test   %al,%al
  800e46:	74 04                	je     800e4c <strncmp+0x2b>
  800e48:	3a 06                	cmp    (%rsi),%al
  800e4a:	74 e8                	je     800e34 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e4c:	0f b6 07             	movzbl (%rdi),%eax
  800e4f:	0f b6 16             	movzbl (%rsi),%edx
  800e52:	29 d0                	sub    %edx,%eax
}
  800e54:	c3                   	retq   
    return 0;
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	c3                   	retq   
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	c3                   	retq   

0000000000800e61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e61:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e63:	0f b6 07             	movzbl (%rdi),%eax
  800e66:	84 c0                	test   %al,%al
  800e68:	74 1e                	je     800e88 <strchr+0x27>
    if (*s == c)
  800e6a:	40 38 c6             	cmp    %al,%sil
  800e6d:	74 1f                	je     800e8e <strchr+0x2d>
  for (; *s; s++)
  800e6f:	48 83 c7 01          	add    $0x1,%rdi
  800e73:	0f b6 07             	movzbl (%rdi),%eax
  800e76:	84 c0                	test   %al,%al
  800e78:	74 08                	je     800e82 <strchr+0x21>
    if (*s == c)
  800e7a:	38 d0                	cmp    %dl,%al
  800e7c:	75 f1                	jne    800e6f <strchr+0xe>
  for (; *s; s++)
  800e7e:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e81:	c3                   	retq   
  return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	c3                   	retq   
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	c3                   	retq   
    if (*s == c)
  800e8e:	48 89 f8             	mov    %rdi,%rax
  800e91:	c3                   	retq   

0000000000800e92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e92:	48 89 f8             	mov    %rdi,%rax
  800e95:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e97:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e9a:	40 38 f2             	cmp    %sil,%dl
  800e9d:	74 13                	je     800eb2 <strfind+0x20>
  800e9f:	84 d2                	test   %dl,%dl
  800ea1:	74 0f                	je     800eb2 <strfind+0x20>
  for (; *s; s++)
  800ea3:	48 83 c0 01          	add    $0x1,%rax
  800ea7:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800eaa:	38 ca                	cmp    %cl,%dl
  800eac:	74 04                	je     800eb2 <strfind+0x20>
  800eae:	84 d2                	test   %dl,%dl
  800eb0:	75 f1                	jne    800ea3 <strfind+0x11>
      break;
  return (char *)s;
}
  800eb2:	c3                   	retq   

0000000000800eb3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800eb3:	48 85 d2             	test   %rdx,%rdx
  800eb6:	74 3a                	je     800ef2 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eb8:	48 89 f8             	mov    %rdi,%rax
  800ebb:	48 09 d0             	or     %rdx,%rax
  800ebe:	a8 03                	test   $0x3,%al
  800ec0:	75 28                	jne    800eea <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ec2:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800ec6:	89 f0                	mov    %esi,%eax
  800ec8:	c1 e0 08             	shl    $0x8,%eax
  800ecb:	89 f1                	mov    %esi,%ecx
  800ecd:	c1 e1 18             	shl    $0x18,%ecx
  800ed0:	41 89 f0             	mov    %esi,%r8d
  800ed3:	41 c1 e0 10          	shl    $0x10,%r8d
  800ed7:	44 09 c1             	or     %r8d,%ecx
  800eda:	09 ce                	or     %ecx,%esi
  800edc:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ede:	48 c1 ea 02          	shr    $0x2,%rdx
  800ee2:	48 89 d1             	mov    %rdx,%rcx
  800ee5:	fc                   	cld    
  800ee6:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ee8:	eb 08                	jmp    800ef2 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	48 89 d1             	mov    %rdx,%rcx
  800eef:	fc                   	cld    
  800ef0:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ef2:	48 89 f8             	mov    %rdi,%rax
  800ef5:	c3                   	retq   

0000000000800ef6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ef6:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ef9:	48 39 fe             	cmp    %rdi,%rsi
  800efc:	73 40                	jae    800f3e <memmove+0x48>
  800efe:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f02:	48 39 f9             	cmp    %rdi,%rcx
  800f05:	76 37                	jbe    800f3e <memmove+0x48>
    s += n;
    d += n;
  800f07:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f0b:	48 89 fe             	mov    %rdi,%rsi
  800f0e:	48 09 d6             	or     %rdx,%rsi
  800f11:	48 09 ce             	or     %rcx,%rsi
  800f14:	40 f6 c6 03          	test   $0x3,%sil
  800f18:	75 14                	jne    800f2e <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f1a:	48 83 ef 04          	sub    $0x4,%rdi
  800f1e:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f22:	48 c1 ea 02          	shr    $0x2,%rdx
  800f26:	48 89 d1             	mov    %rdx,%rcx
  800f29:	fd                   	std    
  800f2a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f2c:	eb 0e                	jmp    800f3c <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f2e:	48 83 ef 01          	sub    $0x1,%rdi
  800f32:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f36:	48 89 d1             	mov    %rdx,%rcx
  800f39:	fd                   	std    
  800f3a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f3c:	fc                   	cld    
  800f3d:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f3e:	48 89 c1             	mov    %rax,%rcx
  800f41:	48 09 d1             	or     %rdx,%rcx
  800f44:	48 09 f1             	or     %rsi,%rcx
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 0e                	jne    800f5a <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f4c:	48 c1 ea 02          	shr    $0x2,%rdx
  800f50:	48 89 d1             	mov    %rdx,%rcx
  800f53:	48 89 c7             	mov    %rax,%rdi
  800f56:	fc                   	cld    
  800f57:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f59:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f5a:	48 89 c7             	mov    %rax,%rdi
  800f5d:	48 89 d1             	mov    %rdx,%rcx
  800f60:	fc                   	cld    
  800f61:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f63:	c3                   	retq   

0000000000800f64 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f64:	55                   	push   %rbp
  800f65:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f68:	48 b8 f6 0e 80 00 00 	movabs $0x800ef6,%rax
  800f6f:	00 00 00 
  800f72:	ff d0                	callq  *%rax
}
  800f74:	5d                   	pop    %rbp
  800f75:	c3                   	retq   

0000000000800f76 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f76:	55                   	push   %rbp
  800f77:	48 89 e5             	mov    %rsp,%rbp
  800f7a:	41 57                	push   %r15
  800f7c:	41 56                	push   %r14
  800f7e:	41 55                	push   %r13
  800f80:	41 54                	push   %r12
  800f82:	53                   	push   %rbx
  800f83:	48 83 ec 08          	sub    $0x8,%rsp
  800f87:	49 89 fe             	mov    %rdi,%r14
  800f8a:	49 89 f7             	mov    %rsi,%r15
  800f8d:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f90:	48 89 f7             	mov    %rsi,%rdi
  800f93:	48 b8 eb 0c 80 00 00 	movabs $0x800ceb,%rax
  800f9a:	00 00 00 
  800f9d:	ff d0                	callq  *%rax
  800f9f:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800fa2:	4c 89 ee             	mov    %r13,%rsi
  800fa5:	4c 89 f7             	mov    %r14,%rdi
  800fa8:	48 b8 0d 0d 80 00 00 	movabs $0x800d0d,%rax
  800faf:	00 00 00 
  800fb2:	ff d0                	callq  *%rax
  800fb4:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fb7:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fbb:	4d 39 e5             	cmp    %r12,%r13
  800fbe:	74 26                	je     800fe6 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fc0:	4c 89 e8             	mov    %r13,%rax
  800fc3:	4c 29 e0             	sub    %r12,%rax
  800fc6:	48 39 d8             	cmp    %rbx,%rax
  800fc9:	76 2a                	jbe    800ff5 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fcb:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fcf:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fd3:	4c 89 fe             	mov    %r15,%rsi
  800fd6:	48 b8 64 0f 80 00 00 	movabs $0x800f64,%rax
  800fdd:	00 00 00 
  800fe0:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fe2:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fe6:	48 83 c4 08          	add    $0x8,%rsp
  800fea:	5b                   	pop    %rbx
  800feb:	41 5c                	pop    %r12
  800fed:	41 5d                	pop    %r13
  800fef:	41 5e                	pop    %r14
  800ff1:	41 5f                	pop    %r15
  800ff3:	5d                   	pop    %rbp
  800ff4:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800ff5:	49 83 ed 01          	sub    $0x1,%r13
  800ff9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ffd:	4c 89 ea             	mov    %r13,%rdx
  801000:	4c 89 fe             	mov    %r15,%rsi
  801003:	48 b8 64 0f 80 00 00 	movabs $0x800f64,%rax
  80100a:	00 00 00 
  80100d:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80100f:	4d 01 ee             	add    %r13,%r14
  801012:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801017:	eb c9                	jmp    800fe2 <strlcat+0x6c>

0000000000801019 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801019:	48 85 d2             	test   %rdx,%rdx
  80101c:	74 3a                	je     801058 <memcmp+0x3f>
    if (*s1 != *s2)
  80101e:	0f b6 0f             	movzbl (%rdi),%ecx
  801021:	44 0f b6 06          	movzbl (%rsi),%r8d
  801025:	44 38 c1             	cmp    %r8b,%cl
  801028:	75 1d                	jne    801047 <memcmp+0x2e>
  80102a:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80102f:	48 39 d0             	cmp    %rdx,%rax
  801032:	74 1e                	je     801052 <memcmp+0x39>
    if (*s1 != *s2)
  801034:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801038:	48 83 c0 01          	add    $0x1,%rax
  80103c:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801042:	44 38 c1             	cmp    %r8b,%cl
  801045:	74 e8                	je     80102f <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801047:	0f b6 c1             	movzbl %cl,%eax
  80104a:	45 0f b6 c0          	movzbl %r8b,%r8d
  80104e:	44 29 c0             	sub    %r8d,%eax
  801051:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801052:	b8 00 00 00 00       	mov    $0x0,%eax
  801057:	c3                   	retq   
  801058:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80105d:	c3                   	retq   

000000000080105e <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80105e:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801062:	48 39 c7             	cmp    %rax,%rdi
  801065:	73 19                	jae    801080 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801067:	89 f2                	mov    %esi,%edx
  801069:	40 38 37             	cmp    %sil,(%rdi)
  80106c:	74 16                	je     801084 <memfind+0x26>
  for (; s < ends; s++)
  80106e:	48 83 c7 01          	add    $0x1,%rdi
  801072:	48 39 f8             	cmp    %rdi,%rax
  801075:	74 08                	je     80107f <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801077:	38 17                	cmp    %dl,(%rdi)
  801079:	75 f3                	jne    80106e <memfind+0x10>
  for (; s < ends; s++)
  80107b:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80107e:	c3                   	retq   
  80107f:	c3                   	retq   
  for (; s < ends; s++)
  801080:	48 89 f8             	mov    %rdi,%rax
  801083:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801084:	48 89 f8             	mov    %rdi,%rax
  801087:	c3                   	retq   

0000000000801088 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801088:	0f b6 07             	movzbl (%rdi),%eax
  80108b:	3c 20                	cmp    $0x20,%al
  80108d:	74 04                	je     801093 <strtol+0xb>
  80108f:	3c 09                	cmp    $0x9,%al
  801091:	75 0f                	jne    8010a2 <strtol+0x1a>
    s++;
  801093:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801097:	0f b6 07             	movzbl (%rdi),%eax
  80109a:	3c 20                	cmp    $0x20,%al
  80109c:	74 f5                	je     801093 <strtol+0xb>
  80109e:	3c 09                	cmp    $0x9,%al
  8010a0:	74 f1                	je     801093 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010a2:	3c 2b                	cmp    $0x2b,%al
  8010a4:	74 2b                	je     8010d1 <strtol+0x49>
  int neg  = 0;
  8010a6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010ac:	3c 2d                	cmp    $0x2d,%al
  8010ae:	74 2d                	je     8010dd <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b0:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010b6:	75 0f                	jne    8010c7 <strtol+0x3f>
  8010b8:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010bb:	74 2c                	je     8010e9 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010bd:	85 d2                	test   %edx,%edx
  8010bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c4:	0f 44 d0             	cmove  %eax,%edx
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010cc:	4c 63 d2             	movslq %edx,%r10
  8010cf:	eb 5c                	jmp    80112d <strtol+0xa5>
    s++;
  8010d1:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010d5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010db:	eb d3                	jmp    8010b0 <strtol+0x28>
    s++, neg = 1;
  8010dd:	48 83 c7 01          	add    $0x1,%rdi
  8010e1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010e7:	eb c7                	jmp    8010b0 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010e9:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010ed:	74 0f                	je     8010fe <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010ef:	85 d2                	test   %edx,%edx
  8010f1:	75 d4                	jne    8010c7 <strtol+0x3f>
    s++, base = 8;
  8010f3:	48 83 c7 01          	add    $0x1,%rdi
  8010f7:	ba 08 00 00 00       	mov    $0x8,%edx
  8010fc:	eb c9                	jmp    8010c7 <strtol+0x3f>
    s += 2, base = 16;
  8010fe:	48 83 c7 02          	add    $0x2,%rdi
  801102:	ba 10 00 00 00       	mov    $0x10,%edx
  801107:	eb be                	jmp    8010c7 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801109:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80110d:	41 80 f8 19          	cmp    $0x19,%r8b
  801111:	77 2f                	ja     801142 <strtol+0xba>
      dig = *s - 'a' + 10;
  801113:	44 0f be c1          	movsbl %cl,%r8d
  801117:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80111b:	39 d1                	cmp    %edx,%ecx
  80111d:	7d 37                	jge    801156 <strtol+0xce>
    s++, val = (val * base) + dig;
  80111f:	48 83 c7 01          	add    $0x1,%rdi
  801123:	49 0f af c2          	imul   %r10,%rax
  801127:	48 63 c9             	movslq %ecx,%rcx
  80112a:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80112d:	0f b6 0f             	movzbl (%rdi),%ecx
  801130:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801134:	41 80 f8 09          	cmp    $0x9,%r8b
  801138:	77 cf                	ja     801109 <strtol+0x81>
      dig = *s - '0';
  80113a:	0f be c9             	movsbl %cl,%ecx
  80113d:	83 e9 30             	sub    $0x30,%ecx
  801140:	eb d9                	jmp    80111b <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801142:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801146:	41 80 f8 19          	cmp    $0x19,%r8b
  80114a:	77 0a                	ja     801156 <strtol+0xce>
      dig = *s - 'A' + 10;
  80114c:	44 0f be c1          	movsbl %cl,%r8d
  801150:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801154:	eb c5                	jmp    80111b <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801156:	48 85 f6             	test   %rsi,%rsi
  801159:	74 03                	je     80115e <strtol+0xd6>
    *endptr = (char *)s;
  80115b:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80115e:	48 89 c2             	mov    %rax,%rdx
  801161:	48 f7 da             	neg    %rdx
  801164:	45 85 c9             	test   %r9d,%r9d
  801167:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80116b:	c3                   	retq   

000000000080116c <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80116c:	55                   	push   %rbp
  80116d:	48 89 e5             	mov    %rsp,%rbp
  801170:	53                   	push   %rbx
  801171:	48 89 fa             	mov    %rdi,%rdx
  801174:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801177:	b8 00 00 00 00       	mov    $0x0,%eax
  80117c:	48 89 c3             	mov    %rax,%rbx
  80117f:	48 89 c7             	mov    %rax,%rdi
  801182:	48 89 c6             	mov    %rax,%rsi
  801185:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801187:	5b                   	pop    %rbx
  801188:	5d                   	pop    %rbp
  801189:	c3                   	retq   

000000000080118a <sys_cgetc>:

int
sys_cgetc(void) {
  80118a:	55                   	push   %rbp
  80118b:	48 89 e5             	mov    %rsp,%rbp
  80118e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80118f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801194:	b8 01 00 00 00       	mov    $0x1,%eax
  801199:	48 89 ca             	mov    %rcx,%rdx
  80119c:	48 89 cb             	mov    %rcx,%rbx
  80119f:	48 89 cf             	mov    %rcx,%rdi
  8011a2:	48 89 ce             	mov    %rcx,%rsi
  8011a5:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011a7:	5b                   	pop    %rbx
  8011a8:	5d                   	pop    %rbp
  8011a9:	c3                   	retq   

00000000008011aa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8011aa:	55                   	push   %rbp
  8011ab:	48 89 e5             	mov    %rsp,%rbp
  8011ae:	53                   	push   %rbx
  8011af:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8011b3:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8011b6:	be 00 00 00 00       	mov    $0x0,%esi
  8011bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8011c0:	48 89 f1             	mov    %rsi,%rcx
  8011c3:	48 89 f3             	mov    %rsi,%rbx
  8011c6:	48 89 f7             	mov    %rsi,%rdi
  8011c9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011cb:	48 85 c0             	test   %rax,%rax
  8011ce:	7f 07                	jg     8011d7 <sys_env_destroy+0x2d>
}
  8011d0:	48 83 c4 08          	add    $0x8,%rsp
  8011d4:	5b                   	pop    %rbx
  8011d5:	5d                   	pop    %rbp
  8011d6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011d7:	49 89 c0             	mov    %rax,%r8
  8011da:	b9 03 00 00 00       	mov    $0x3,%ecx
  8011df:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  8011e6:	00 00 00 
  8011e9:	be 22 00 00 00       	mov    $0x22,%esi
  8011ee:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  8011f5:	00 00 00 
  8011f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fd:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  801204:	00 00 00 
  801207:	41 ff d1             	callq  *%r9

000000000080120a <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80120a:	55                   	push   %rbp
  80120b:	48 89 e5             	mov    %rsp,%rbp
  80120e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80120f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801214:	b8 02 00 00 00       	mov    $0x2,%eax
  801219:	48 89 ca             	mov    %rcx,%rdx
  80121c:	48 89 cb             	mov    %rcx,%rbx
  80121f:	48 89 cf             	mov    %rcx,%rdi
  801222:	48 89 ce             	mov    %rcx,%rsi
  801225:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801227:	5b                   	pop    %rbx
  801228:	5d                   	pop    %rbp
  801229:	c3                   	retq   

000000000080122a <sys_yield>:

void
sys_yield(void) {
  80122a:	55                   	push   %rbp
  80122b:	48 89 e5             	mov    %rsp,%rbp
  80122e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80122f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801234:	b8 0a 00 00 00       	mov    $0xa,%eax
  801239:	48 89 ca             	mov    %rcx,%rdx
  80123c:	48 89 cb             	mov    %rcx,%rbx
  80123f:	48 89 cf             	mov    %rcx,%rdi
  801242:	48 89 ce             	mov    %rcx,%rsi
  801245:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801247:	5b                   	pop    %rbx
  801248:	5d                   	pop    %rbp
  801249:	c3                   	retq   

000000000080124a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  80124a:	55                   	push   %rbp
  80124b:	48 89 e5             	mov    %rsp,%rbp
  80124e:	53                   	push   %rbx
  80124f:	48 83 ec 08          	sub    $0x8,%rsp
  801253:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801256:	4c 63 c7             	movslq %edi,%r8
  801259:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  80125c:	be 00 00 00 00       	mov    $0x0,%esi
  801261:	b8 04 00 00 00       	mov    $0x4,%eax
  801266:	4c 89 c2             	mov    %r8,%rdx
  801269:	48 89 f7             	mov    %rsi,%rdi
  80126c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80126e:	48 85 c0             	test   %rax,%rax
  801271:	7f 07                	jg     80127a <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  801273:	48 83 c4 08          	add    $0x8,%rsp
  801277:	5b                   	pop    %rbx
  801278:	5d                   	pop    %rbp
  801279:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80127a:	49 89 c0             	mov    %rax,%r8
  80127d:	b9 04 00 00 00       	mov    $0x4,%ecx
  801282:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801289:	00 00 00 
  80128c:	be 22 00 00 00       	mov    $0x22,%esi
  801291:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  801298:	00 00 00 
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a0:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  8012a7:	00 00 00 
  8012aa:	41 ff d1             	callq  *%r9

00000000008012ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8012ad:	55                   	push   %rbp
  8012ae:	48 89 e5             	mov    %rsp,%rbp
  8012b1:	53                   	push   %rbx
  8012b2:	48 83 ec 08          	sub    $0x8,%rsp
  8012b6:	41 89 f9             	mov    %edi,%r9d
  8012b9:	49 89 f2             	mov    %rsi,%r10
  8012bc:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8012bf:	4d 63 c9             	movslq %r9d,%r9
  8012c2:	48 63 da             	movslq %edx,%rbx
  8012c5:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8012c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8012cd:	4c 89 ca             	mov    %r9,%rdx
  8012d0:	4c 89 d1             	mov    %r10,%rcx
  8012d3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012d5:	48 85 c0             	test   %rax,%rax
  8012d8:	7f 07                	jg     8012e1 <sys_page_map+0x34>
}
  8012da:	48 83 c4 08          	add    $0x8,%rsp
  8012de:	5b                   	pop    %rbx
  8012df:	5d                   	pop    %rbp
  8012e0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012e1:	49 89 c0             	mov    %rax,%r8
  8012e4:	b9 05 00 00 00       	mov    $0x5,%ecx
  8012e9:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  8012f0:	00 00 00 
  8012f3:	be 22 00 00 00       	mov    $0x22,%esi
  8012f8:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  8012ff:	00 00 00 
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  80130e:	00 00 00 
  801311:	41 ff d1             	callq  *%r9

0000000000801314 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801314:	55                   	push   %rbp
  801315:	48 89 e5             	mov    %rsp,%rbp
  801318:	53                   	push   %rbx
  801319:	48 83 ec 08          	sub    $0x8,%rsp
  80131d:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801320:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801323:	be 00 00 00 00       	mov    $0x0,%esi
  801328:	b8 06 00 00 00       	mov    $0x6,%eax
  80132d:	48 89 f3             	mov    %rsi,%rbx
  801330:	48 89 f7             	mov    %rsi,%rdi
  801333:	cd 30                	int    $0x30
  if (check && ret > 0)
  801335:	48 85 c0             	test   %rax,%rax
  801338:	7f 07                	jg     801341 <sys_page_unmap+0x2d>
}
  80133a:	48 83 c4 08          	add    $0x8,%rsp
  80133e:	5b                   	pop    %rbx
  80133f:	5d                   	pop    %rbp
  801340:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801341:	49 89 c0             	mov    %rax,%r8
  801344:	b9 06 00 00 00       	mov    $0x6,%ecx
  801349:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801350:	00 00 00 
  801353:	be 22 00 00 00       	mov    $0x22,%esi
  801358:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  80135f:	00 00 00 
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  80136e:	00 00 00 
  801371:	41 ff d1             	callq  *%r9

0000000000801374 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  801374:	55                   	push   %rbp
  801375:	48 89 e5             	mov    %rsp,%rbp
  801378:	53                   	push   %rbx
  801379:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80137d:	48 63 d7             	movslq %edi,%rdx
  801380:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801383:	bb 00 00 00 00       	mov    $0x0,%ebx
  801388:	b8 08 00 00 00       	mov    $0x8,%eax
  80138d:	48 89 df             	mov    %rbx,%rdi
  801390:	48 89 de             	mov    %rbx,%rsi
  801393:	cd 30                	int    $0x30
  if (check && ret > 0)
  801395:	48 85 c0             	test   %rax,%rax
  801398:	7f 07                	jg     8013a1 <sys_env_set_status+0x2d>
}
  80139a:	48 83 c4 08          	add    $0x8,%rsp
  80139e:	5b                   	pop    %rbx
  80139f:	5d                   	pop    %rbp
  8013a0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013a1:	49 89 c0             	mov    %rax,%r8
  8013a4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8013a9:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  8013b0:	00 00 00 
  8013b3:	be 22 00 00 00       	mov    $0x22,%esi
  8013b8:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  8013bf:	00 00 00 
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c7:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  8013ce:	00 00 00 
  8013d1:	41 ff d1             	callq  *%r9

00000000008013d4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8013d4:	55                   	push   %rbp
  8013d5:	48 89 e5             	mov    %rsp,%rbp
  8013d8:	53                   	push   %rbx
  8013d9:	48 83 ec 08          	sub    $0x8,%rsp
  8013dd:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  8013e0:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8013e3:	be 00 00 00 00       	mov    $0x0,%esi
  8013e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8013ed:	48 89 f3             	mov    %rsi,%rbx
  8013f0:	48 89 f7             	mov    %rsi,%rdi
  8013f3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013f5:	48 85 c0             	test   %rax,%rax
  8013f8:	7f 07                	jg     801401 <sys_env_set_pgfault_upcall+0x2d>
}
  8013fa:	48 83 c4 08          	add    $0x8,%rsp
  8013fe:	5b                   	pop    %rbx
  8013ff:	5d                   	pop    %rbp
  801400:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801401:	49 89 c0             	mov    %rax,%r8
  801404:	b9 09 00 00 00       	mov    $0x9,%ecx
  801409:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801410:	00 00 00 
  801413:	be 22 00 00 00       	mov    $0x22,%esi
  801418:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  80141f:	00 00 00 
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
  801427:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  80142e:	00 00 00 
  801431:	41 ff d1             	callq  *%r9

0000000000801434 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801434:	55                   	push   %rbp
  801435:	48 89 e5             	mov    %rsp,%rbp
  801438:	53                   	push   %rbx
  801439:	49 89 f0             	mov    %rsi,%r8
  80143c:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  80143f:	48 63 d7             	movslq %edi,%rdx
  801442:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801445:	b8 0b 00 00 00       	mov    $0xb,%eax
  80144a:	be 00 00 00 00       	mov    $0x0,%esi
  80144f:	4c 89 c1             	mov    %r8,%rcx
  801452:	cd 30                	int    $0x30
}
  801454:	5b                   	pop    %rbx
  801455:	5d                   	pop    %rbp
  801456:	c3                   	retq   

0000000000801457 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801457:	55                   	push   %rbp
  801458:	48 89 e5             	mov    %rsp,%rbp
  80145b:	53                   	push   %rbx
  80145c:	48 83 ec 08          	sub    $0x8,%rsp
  801460:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801463:	be 00 00 00 00       	mov    $0x0,%esi
  801468:	b8 0c 00 00 00       	mov    $0xc,%eax
  80146d:	48 89 f1             	mov    %rsi,%rcx
  801470:	48 89 f3             	mov    %rsi,%rbx
  801473:	48 89 f7             	mov    %rsi,%rdi
  801476:	cd 30                	int    $0x30
  if (check && ret > 0)
  801478:	48 85 c0             	test   %rax,%rax
  80147b:	7f 07                	jg     801484 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80147d:	48 83 c4 08          	add    $0x8,%rsp
  801481:	5b                   	pop    %rbx
  801482:	5d                   	pop    %rbp
  801483:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801484:	49 89 c0             	mov    %rax,%r8
  801487:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80148c:	48 ba 60 1a 80 00 00 	movabs $0x801a60,%rdx
  801493:	00 00 00 
  801496:	be 22 00 00 00       	mov    $0x22,%esi
  80149b:	48 bf 80 1a 80 00 00 	movabs $0x801a80,%rdi
  8014a2:	00 00 00 
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014aa:	49 b9 d6 01 80 00 00 	movabs $0x8001d6,%r9
  8014b1:	00 00 00 
  8014b4:	41 ff d1             	callq  *%r9

00000000008014b7 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  8014b7:	55                   	push   %rbp
  8014b8:	48 89 e5             	mov    %rsp,%rbp
  8014bb:	41 54                	push   %r12
  8014bd:	53                   	push   %rbx
  8014be:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  8014c1:	48 b8 0a 12 80 00 00 	movabs $0x80120a,%rax
  8014c8:	00 00 00 
  8014cb:	ff d0                	callq  *%rax
  8014cd:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  8014cf:	48 b8 10 20 80 00 00 	movabs $0x802010,%rax
  8014d6:	00 00 00 
  8014d9:	48 83 38 00          	cmpq   $0x0,(%rax)
  8014dd:	74 2e                	je     80150d <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  8014df:	4c 89 e0             	mov    %r12,%rax
  8014e2:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  8014e9:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8014ec:	48 be 59 15 80 00 00 	movabs $0x801559,%rsi
  8014f3:	00 00 00 
  8014f6:	89 df                	mov    %ebx,%edi
  8014f8:	48 b8 d4 13 80 00 00 	movabs $0x8013d4,%rax
  8014ff:	00 00 00 
  801502:	ff d0                	callq  *%rax
  if (error < 0)
  801504:	85 c0                	test   %eax,%eax
  801506:	78 24                	js     80152c <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801508:	5b                   	pop    %rbx
  801509:	41 5c                	pop    %r12
  80150b:	5d                   	pop    %rbp
  80150c:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  80150d:	ba 02 00 00 00       	mov    $0x2,%edx
  801512:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801519:	00 00 00 
  80151c:	89 df                	mov    %ebx,%edi
  80151e:	48 b8 4a 12 80 00 00 	movabs $0x80124a,%rax
  801525:	00 00 00 
  801528:	ff d0                	callq  *%rax
  80152a:	eb b3                	jmp    8014df <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  80152c:	89 c1                	mov    %eax,%ecx
  80152e:	48 ba 8e 1a 80 00 00 	movabs $0x801a8e,%rdx
  801535:	00 00 00 
  801538:	be 2c 00 00 00       	mov    $0x2c,%esi
  80153d:	48 bf a6 1a 80 00 00 	movabs $0x801aa6,%rdi
  801544:	00 00 00 
  801547:	b8 00 00 00 00       	mov    $0x0,%eax
  80154c:	49 b8 d6 01 80 00 00 	movabs $0x8001d6,%r8
  801553:	00 00 00 
  801556:	41 ff d0             	callq  *%r8

0000000000801559 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801559:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  80155c:	48 a1 10 20 80 00 00 	movabs 0x802010,%rax
  801563:	00 00 00 
	call *%rax
  801566:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801568:	41 5f                	pop    %r15
	popq %r15
  80156a:	41 5f                	pop    %r15
	popq %r15
  80156c:	41 5f                	pop    %r15
	popq %r14
  80156e:	41 5e                	pop    %r14
	popq %r13
  801570:	41 5d                	pop    %r13
	popq %r12
  801572:	41 5c                	pop    %r12
	popq %r11
  801574:	41 5b                	pop    %r11
	popq %r10
  801576:	41 5a                	pop    %r10
	popq %r9
  801578:	41 59                	pop    %r9
	popq %r8
  80157a:	41 58                	pop    %r8
	popq %rsi
  80157c:	5e                   	pop    %rsi
	popq %rdi
  80157d:	5f                   	pop    %rdi
	popq %rbp
  80157e:	5d                   	pop    %rbp
	popq %rdx
  80157f:	5a                   	pop    %rdx
	popq %rcx
  801580:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801581:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801586:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  80158b:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  80158f:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801592:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801597:	5b                   	pop    %rbx
	popq %rax
  801598:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801599:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  80159d:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  80159e:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  8015a3:	c3                   	retq   
