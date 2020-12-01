
obj/user/faultalloc:     file format elf64-x86-64


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
  800023:	e8 0b 01 00 00       	callq  800133 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <handler>:
// test user-level fault handler -- alloc pages to fix faults

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
  800039:	48 bf e0 15 80 00 00 	movabs $0x8015e0,%rdi
  800040:	00 00 00 
  800043:	b8 00 00 00 00       	mov    $0x0,%eax
  800048:	48 ba a2 03 80 00 00 	movabs $0x8003a2,%rdx
  80004f:	00 00 00 
  800052:	ff d2                	callq  *%rdx
  if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  800054:	48 89 de             	mov    %rbx,%rsi
  800057:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  80005e:	ba 07 00 00 00       	mov    $0x7,%edx
  800063:	bf 00 00 00 00       	mov    $0x0,%edi
  800068:	48 b8 74 12 80 00 00 	movabs $0x801274,%rax
  80006f:	00 00 00 
  800072:	ff d0                	callq  *%rax
  800074:	85 c0                	test   %eax,%eax
  800076:	78 2e                	js     8000a6 <handler+0x7c>
    panic("allocating at %lx in page fault handler: %i", (unsigned long)addr, r);
  }
  snprintf((char *)addr, 100, "this string was faulted in at %lx", (unsigned long)addr);
  800078:	48 89 d9             	mov    %rbx,%rcx
  80007b:	48 ba 38 16 80 00 00 	movabs $0x801638,%rdx
  800082:	00 00 00 
  800085:	be 64 00 00 00       	mov    $0x64,%esi
  80008a:	48 89 df             	mov    %rbx,%rdi
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
  800092:	49 b8 8f 0c 80 00 00 	movabs $0x800c8f,%r8
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
  8000ac:	48 ba 08 16 80 00 00 	movabs $0x801608,%rdx
  8000b3:	00 00 00 
  8000b6:	be 0c 00 00 00       	mov    $0xc,%esi
  8000bb:	48 bf eb 15 80 00 00 	movabs $0x8015eb,%rdi
  8000c2:	00 00 00 
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  8000d1:	00 00 00 
  8000d4:	41 ff d1             	callq  *%r9

00000000008000d7 <umain>:

void
umain(int argc, char **argv) {
  8000d7:	55                   	push   %rbp
  8000d8:	48 89 e5             	mov    %rsp,%rbp
  8000db:	53                   	push   %rbx
  8000dc:	48 83 ec 08          	sub    $0x8,%rsp
  set_pgfault_handler(handler);
  8000e0:	48 bf 2a 00 80 00 00 	movabs $0x80002a,%rdi
  8000e7:	00 00 00 
  8000ea:	48 b8 e1 14 80 00 00 	movabs $0x8014e1,%rax
  8000f1:	00 00 00 
  8000f4:	ff d0                	callq  *%rax
  cprintf("%s\n", (char *)0xBeefDead);
  8000f6:	be ad de ef be       	mov    $0xbeefdead,%esi
  8000fb:	48 bf fd 15 80 00 00 	movabs $0x8015fd,%rdi
  800102:	00 00 00 
  800105:	b8 00 00 00 00       	mov    $0x0,%eax
  80010a:	48 bb a2 03 80 00 00 	movabs $0x8003a2,%rbx
  800111:	00 00 00 
  800114:	ff d3                	callq  *%rbx
  cprintf("%s\n", (char *)0xCafeBffe);
  800116:	be fe bf fe ca       	mov    $0xcafebffe,%esi
  80011b:	48 bf fd 15 80 00 00 	movabs $0x8015fd,%rdi
  800122:	00 00 00 
  800125:	b8 00 00 00 00       	mov    $0x0,%eax
  80012a:	ff d3                	callq  *%rbx
}
  80012c:	48 83 c4 08          	add    $0x8,%rsp
  800130:	5b                   	pop    %rbx
  800131:	5d                   	pop    %rbp
  800132:	c3                   	retq   

0000000000800133 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800133:	55                   	push   %rbp
  800134:	48 89 e5             	mov    %rsp,%rbp
  800137:	41 56                	push   %r14
  800139:	41 55                	push   %r13
  80013b:	41 54                	push   %r12
  80013d:	53                   	push   %rbx
  80013e:	41 89 fd             	mov    %edi,%r13d
  800141:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800144:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80014b:	00 00 00 
  80014e:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800155:	00 00 00 
  800158:	48 39 c2             	cmp    %rax,%rdx
  80015b:	73 23                	jae    800180 <libmain+0x4d>
  80015d:	48 89 d3             	mov    %rdx,%rbx
  800160:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800164:	48 29 d0             	sub    %rdx,%rax
  800167:	48 c1 e8 03          	shr    $0x3,%rax
  80016b:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800170:	b8 00 00 00 00       	mov    $0x0,%eax
  800175:	ff 13                	callq  *(%rbx)
    ctor++;
  800177:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80017b:	4c 39 e3             	cmp    %r12,%rbx
  80017e:	75 f0                	jne    800170 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800180:	48 b8 34 12 80 00 00 	movabs $0x801234,%rax
  800187:	00 00 00 
  80018a:	ff d0                	callq  *%rax
  80018c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800191:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800195:	48 c1 e0 05          	shl    $0x5,%rax
  800199:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8001a0:	00 00 00 
  8001a3:	48 01 d0             	add    %rdx,%rax
  8001a6:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8001ad:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8001b0:	45 85 ed             	test   %r13d,%r13d
  8001b3:	7e 0d                	jle    8001c2 <libmain+0x8f>
    binaryname = argv[0];
  8001b5:	49 8b 06             	mov    (%r14),%rax
  8001b8:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8001bf:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8001c2:	4c 89 f6             	mov    %r14,%rsi
  8001c5:	44 89 ef             	mov    %r13d,%edi
  8001c8:	48 b8 d7 00 80 00 00 	movabs $0x8000d7,%rax
  8001cf:	00 00 00 
  8001d2:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8001d4:	48 b8 e9 01 80 00 00 	movabs $0x8001e9,%rax
  8001db:	00 00 00 
  8001de:	ff d0                	callq  *%rax
#endif
}
  8001e0:	5b                   	pop    %rbx
  8001e1:	41 5c                	pop    %r12
  8001e3:	41 5d                	pop    %r13
  8001e5:	41 5e                	pop    %r14
  8001e7:	5d                   	pop    %rbp
  8001e8:	c3                   	retq   

00000000008001e9 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001e9:	55                   	push   %rbp
  8001ea:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8001ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f2:	48 b8 d4 11 80 00 00 	movabs $0x8011d4,%rax
  8001f9:	00 00 00 
  8001fc:	ff d0                	callq  *%rax
}
  8001fe:	5d                   	pop    %rbp
  8001ff:	c3                   	retq   

0000000000800200 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800200:	55                   	push   %rbp
  800201:	48 89 e5             	mov    %rsp,%rbp
  800204:	41 56                	push   %r14
  800206:	41 55                	push   %r13
  800208:	41 54                	push   %r12
  80020a:	53                   	push   %rbx
  80020b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800212:	49 89 fd             	mov    %rdi,%r13
  800215:	41 89 f6             	mov    %esi,%r14d
  800218:	49 89 d4             	mov    %rdx,%r12
  80021b:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800222:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800229:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800230:	84 c0                	test   %al,%al
  800232:	74 26                	je     80025a <_panic+0x5a>
  800234:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80023b:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800242:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800246:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80024a:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80024e:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800252:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800256:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80025a:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800261:	00 00 00 
  800264:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80026b:	00 00 00 
  80026e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800272:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800279:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800280:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800287:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80028e:	00 00 00 
  800291:	48 8b 18             	mov    (%rax),%rbx
  800294:	48 b8 34 12 80 00 00 	movabs $0x801234,%rax
  80029b:	00 00 00 
  80029e:	ff d0                	callq  *%rax
  8002a0:	45 89 f0             	mov    %r14d,%r8d
  8002a3:	4c 89 e9             	mov    %r13,%rcx
  8002a6:	48 89 da             	mov    %rbx,%rdx
  8002a9:	89 c6                	mov    %eax,%esi
  8002ab:	48 bf 68 16 80 00 00 	movabs $0x801668,%rdi
  8002b2:	00 00 00 
  8002b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ba:	48 bb a2 03 80 00 00 	movabs $0x8003a2,%rbx
  8002c1:	00 00 00 
  8002c4:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8002c6:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002cd:	4c 89 e7             	mov    %r12,%rdi
  8002d0:	48 b8 3a 03 80 00 00 	movabs $0x80033a,%rax
  8002d7:	00 00 00 
  8002da:	ff d0                	callq  *%rax
  cprintf("\n");
  8002dc:	48 bf ff 15 80 00 00 	movabs $0x8015ff,%rdi
  8002e3:	00 00 00 
  8002e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002eb:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002ed:	cc                   	int3   
  while (1)
  8002ee:	eb fd                	jmp    8002ed <_panic+0xed>

00000000008002f0 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002f0:	55                   	push   %rbp
  8002f1:	48 89 e5             	mov    %rsp,%rbp
  8002f4:	53                   	push   %rbx
  8002f5:	48 83 ec 08          	sub    $0x8,%rsp
  8002f9:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002fc:	8b 06                	mov    (%rsi),%eax
  8002fe:	8d 50 01             	lea    0x1(%rax),%edx
  800301:	89 16                	mov    %edx,(%rsi)
  800303:	48 98                	cltq   
  800305:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80030a:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800310:	74 0b                	je     80031d <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800312:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800316:	48 83 c4 08          	add    $0x8,%rsp
  80031a:	5b                   	pop    %rbx
  80031b:	5d                   	pop    %rbp
  80031c:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80031d:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800321:	be ff 00 00 00       	mov    $0xff,%esi
  800326:	48 b8 96 11 80 00 00 	movabs $0x801196,%rax
  80032d:	00 00 00 
  800330:	ff d0                	callq  *%rax
    b->idx = 0;
  800332:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800338:	eb d8                	jmp    800312 <putch+0x22>

000000000080033a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80033a:	55                   	push   %rbp
  80033b:	48 89 e5             	mov    %rsp,%rbp
  80033e:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800345:	48 89 fa             	mov    %rdi,%rdx
  800348:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80034b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800352:	00 00 00 
  b.cnt = 0;
  800355:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80035c:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80035f:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800366:	48 bf f0 02 80 00 00 	movabs $0x8002f0,%rdi
  80036d:	00 00 00 
  800370:	48 b8 60 05 80 00 00 	movabs $0x800560,%rax
  800377:	00 00 00 
  80037a:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80037c:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800383:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80038a:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80038e:	48 b8 96 11 80 00 00 	movabs $0x801196,%rax
  800395:	00 00 00 
  800398:	ff d0                	callq  *%rax

  return b.cnt;
}
  80039a:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8003a0:	c9                   	leaveq 
  8003a1:	c3                   	retq   

00000000008003a2 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8003a2:	55                   	push   %rbp
  8003a3:	48 89 e5             	mov    %rsp,%rbp
  8003a6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003ad:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8003b4:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8003bb:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003c2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003c9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003d0:	84 c0                	test   %al,%al
  8003d2:	74 20                	je     8003f4 <cprintf+0x52>
  8003d4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003d8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003dc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003e0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003e4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003e8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003ec:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003f0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003f4:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003fb:	00 00 00 
  8003fe:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800405:	00 00 00 
  800408:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80040c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800413:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80041a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800421:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800428:	48 b8 3a 03 80 00 00 	movabs $0x80033a,%rax
  80042f:	00 00 00 
  800432:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800434:	c9                   	leaveq 
  800435:	c3                   	retq   

0000000000800436 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800436:	55                   	push   %rbp
  800437:	48 89 e5             	mov    %rsp,%rbp
  80043a:	41 57                	push   %r15
  80043c:	41 56                	push   %r14
  80043e:	41 55                	push   %r13
  800440:	41 54                	push   %r12
  800442:	53                   	push   %rbx
  800443:	48 83 ec 18          	sub    $0x18,%rsp
  800447:	49 89 fc             	mov    %rdi,%r12
  80044a:	49 89 f5             	mov    %rsi,%r13
  80044d:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800451:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800454:	41 89 cf             	mov    %ecx,%r15d
  800457:	49 39 d7             	cmp    %rdx,%r15
  80045a:	76 45                	jbe    8004a1 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80045c:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800460:	85 db                	test   %ebx,%ebx
  800462:	7e 0e                	jle    800472 <printnum+0x3c>
      putch(padc, putdat);
  800464:	4c 89 ee             	mov    %r13,%rsi
  800467:	44 89 f7             	mov    %r14d,%edi
  80046a:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80046d:	83 eb 01             	sub    $0x1,%ebx
  800470:	75 f2                	jne    800464 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800472:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800476:	ba 00 00 00 00       	mov    $0x0,%edx
  80047b:	49 f7 f7             	div    %r15
  80047e:	48 b8 8b 16 80 00 00 	movabs $0x80168b,%rax
  800485:	00 00 00 
  800488:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80048c:	4c 89 ee             	mov    %r13,%rsi
  80048f:	41 ff d4             	callq  *%r12
}
  800492:	48 83 c4 18          	add    $0x18,%rsp
  800496:	5b                   	pop    %rbx
  800497:	41 5c                	pop    %r12
  800499:	41 5d                	pop    %r13
  80049b:	41 5e                	pop    %r14
  80049d:	41 5f                	pop    %r15
  80049f:	5d                   	pop    %rbp
  8004a0:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	49 f7 f7             	div    %r15
  8004ad:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8004b1:	48 89 c2             	mov    %rax,%rdx
  8004b4:	48 b8 36 04 80 00 00 	movabs $0x800436,%rax
  8004bb:	00 00 00 
  8004be:	ff d0                	callq  *%rax
  8004c0:	eb b0                	jmp    800472 <printnum+0x3c>

00000000008004c2 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8004c2:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8004c6:	48 8b 06             	mov    (%rsi),%rax
  8004c9:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004cd:	73 0a                	jae    8004d9 <sprintputch+0x17>
    *b->buf++ = ch;
  8004cf:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004d3:	48 89 16             	mov    %rdx,(%rsi)
  8004d6:	40 88 38             	mov    %dil,(%rax)
}
  8004d9:	c3                   	retq   

00000000008004da <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004da:	55                   	push   %rbp
  8004db:	48 89 e5             	mov    %rsp,%rbp
  8004de:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004e5:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004ec:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004f3:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004fa:	84 c0                	test   %al,%al
  8004fc:	74 20                	je     80051e <printfmt+0x44>
  8004fe:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800502:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800506:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80050a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80050e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800512:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800516:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80051a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80051e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800525:	00 00 00 
  800528:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80052f:	00 00 00 
  800532:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800536:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80053d:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800544:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80054b:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800552:	48 b8 60 05 80 00 00 	movabs $0x800560,%rax
  800559:	00 00 00 
  80055c:	ff d0                	callq  *%rax
}
  80055e:	c9                   	leaveq 
  80055f:	c3                   	retq   

0000000000800560 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800560:	55                   	push   %rbp
  800561:	48 89 e5             	mov    %rsp,%rbp
  800564:	41 57                	push   %r15
  800566:	41 56                	push   %r14
  800568:	41 55                	push   %r13
  80056a:	41 54                	push   %r12
  80056c:	53                   	push   %rbx
  80056d:	48 83 ec 48          	sub    $0x48,%rsp
  800571:	49 89 fd             	mov    %rdi,%r13
  800574:	49 89 f7             	mov    %rsi,%r15
  800577:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80057a:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80057e:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800582:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800586:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80058a:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80058e:	41 0f b6 3e          	movzbl (%r14),%edi
  800592:	83 ff 25             	cmp    $0x25,%edi
  800595:	74 18                	je     8005af <vprintfmt+0x4f>
      if (ch == '\0')
  800597:	85 ff                	test   %edi,%edi
  800599:	0f 84 8c 06 00 00    	je     800c2b <vprintfmt+0x6cb>
      putch(ch, putdat);
  80059f:	4c 89 fe             	mov    %r15,%rsi
  8005a2:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005a5:	49 89 de             	mov    %rbx,%r14
  8005a8:	eb e0                	jmp    80058a <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8005aa:	49 89 de             	mov    %rbx,%r14
  8005ad:	eb db                	jmp    80058a <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8005af:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8005b3:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8005b7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8005be:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8005c4:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005cd:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005d3:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005d9:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005de:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005e3:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005e7:	0f b6 13             	movzbl (%rbx),%edx
  8005ea:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005ed:	3c 55                	cmp    $0x55,%al
  8005ef:	0f 87 8b 05 00 00    	ja     800b80 <vprintfmt+0x620>
  8005f5:	0f b6 c0             	movzbl %al,%eax
  8005f8:	49 bb 60 17 80 00 00 	movabs $0x801760,%r11
  8005ff:	00 00 00 
  800602:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800606:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800609:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80060d:	eb d4                	jmp    8005e3 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80060f:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800612:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800616:	eb cb                	jmp    8005e3 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800618:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80061b:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80061f:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800623:	8d 50 d0             	lea    -0x30(%rax),%edx
  800626:	83 fa 09             	cmp    $0x9,%edx
  800629:	77 7e                	ja     8006a9 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80062b:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80062f:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800633:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800638:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80063c:	8d 50 d0             	lea    -0x30(%rax),%edx
  80063f:	83 fa 09             	cmp    $0x9,%edx
  800642:	76 e7                	jbe    80062b <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800644:	4c 89 f3             	mov    %r14,%rbx
  800647:	eb 19                	jmp    800662 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800649:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80064c:	83 f8 2f             	cmp    $0x2f,%eax
  80064f:	77 2a                	ja     80067b <vprintfmt+0x11b>
  800651:	89 c2                	mov    %eax,%edx
  800653:	4c 01 d2             	add    %r10,%rdx
  800656:	83 c0 08             	add    $0x8,%eax
  800659:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80065c:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80065f:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800662:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800666:	0f 89 77 ff ff ff    	jns    8005e3 <vprintfmt+0x83>
          width = precision, precision = -1;
  80066c:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800670:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800676:	e9 68 ff ff ff       	jmpq   8005e3 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80067b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80067f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800683:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800687:	eb d3                	jmp    80065c <vprintfmt+0xfc>
        if (width < 0)
  800689:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	41 0f 48 c0          	cmovs  %r8d,%eax
  800692:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800695:	4c 89 f3             	mov    %r14,%rbx
  800698:	e9 46 ff ff ff       	jmpq   8005e3 <vprintfmt+0x83>
  80069d:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8006a0:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8006a4:	e9 3a ff ff ff       	jmpq   8005e3 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8006a9:	4c 89 f3             	mov    %r14,%rbx
  8006ac:	eb b4                	jmp    800662 <vprintfmt+0x102>
        lflag++;
  8006ae:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8006b1:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8006b4:	e9 2a ff ff ff       	jmpq   8005e3 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8006b9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006bc:	83 f8 2f             	cmp    $0x2f,%eax
  8006bf:	77 19                	ja     8006da <vprintfmt+0x17a>
  8006c1:	89 c2                	mov    %eax,%edx
  8006c3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006c7:	83 c0 08             	add    $0x8,%eax
  8006ca:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006cd:	4c 89 fe             	mov    %r15,%rsi
  8006d0:	8b 3a                	mov    (%rdx),%edi
  8006d2:	41 ff d5             	callq  *%r13
        break;
  8006d5:	e9 b0 fe ff ff       	jmpq   80058a <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006da:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006de:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006e2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e6:	eb e5                	jmp    8006cd <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006e8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006eb:	83 f8 2f             	cmp    $0x2f,%eax
  8006ee:	77 5b                	ja     80074b <vprintfmt+0x1eb>
  8006f0:	89 c2                	mov    %eax,%edx
  8006f2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006f6:	83 c0 08             	add    $0x8,%eax
  8006f9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006fc:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006fe:	89 c8                	mov    %ecx,%eax
  800700:	c1 f8 1f             	sar    $0x1f,%eax
  800703:	31 c1                	xor    %eax,%ecx
  800705:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800707:	83 f9 0b             	cmp    $0xb,%ecx
  80070a:	7f 4d                	jg     800759 <vprintfmt+0x1f9>
  80070c:	48 63 c1             	movslq %ecx,%rax
  80070f:	48 ba 20 1a 80 00 00 	movabs $0x801a20,%rdx
  800716:	00 00 00 
  800719:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80071d:	48 85 c0             	test   %rax,%rax
  800720:	74 37                	je     800759 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800722:	48 89 c1             	mov    %rax,%rcx
  800725:	48 ba ac 16 80 00 00 	movabs $0x8016ac,%rdx
  80072c:	00 00 00 
  80072f:	4c 89 fe             	mov    %r15,%rsi
  800732:	4c 89 ef             	mov    %r13,%rdi
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	48 bb da 04 80 00 00 	movabs $0x8004da,%rbx
  800741:	00 00 00 
  800744:	ff d3                	callq  *%rbx
  800746:	e9 3f fe ff ff       	jmpq   80058a <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80074b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80074f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800753:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800757:	eb a3                	jmp    8006fc <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800759:	48 ba a3 16 80 00 00 	movabs $0x8016a3,%rdx
  800760:	00 00 00 
  800763:	4c 89 fe             	mov    %r15,%rsi
  800766:	4c 89 ef             	mov    %r13,%rdi
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
  80076e:	48 bb da 04 80 00 00 	movabs $0x8004da,%rbx
  800775:	00 00 00 
  800778:	ff d3                	callq  *%rbx
  80077a:	e9 0b fe ff ff       	jmpq   80058a <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80077f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800782:	83 f8 2f             	cmp    $0x2f,%eax
  800785:	77 4b                	ja     8007d2 <vprintfmt+0x272>
  800787:	89 c2                	mov    %eax,%edx
  800789:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80078d:	83 c0 08             	add    $0x8,%eax
  800790:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800793:	48 8b 02             	mov    (%rdx),%rax
  800796:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80079a:	48 85 c0             	test   %rax,%rax
  80079d:	0f 84 05 04 00 00    	je     800ba8 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8007a3:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8007a7:	7e 06                	jle    8007af <vprintfmt+0x24f>
  8007a9:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8007ad:	75 31                	jne    8007e0 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007af:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007b3:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007b7:	0f b6 00             	movzbl (%rax),%eax
  8007ba:	0f be f8             	movsbl %al,%edi
  8007bd:	85 ff                	test   %edi,%edi
  8007bf:	0f 84 c3 00 00 00    	je     800888 <vprintfmt+0x328>
  8007c5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007c9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007cd:	e9 85 00 00 00       	jmpq   800857 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007d6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007da:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007de:	eb b3                	jmp    800793 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007e0:	49 63 f4             	movslq %r12d,%rsi
  8007e3:	48 89 c7             	mov    %rax,%rdi
  8007e6:	48 b8 37 0d 80 00 00 	movabs $0x800d37,%rax
  8007ed:	00 00 00 
  8007f0:	ff d0                	callq  *%rax
  8007f2:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007f5:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007f8:	85 f6                	test   %esi,%esi
  8007fa:	7e 22                	jle    80081e <vprintfmt+0x2be>
            putch(padc, putdat);
  8007fc:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800800:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800804:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800808:	4c 89 fe             	mov    %r15,%rsi
  80080b:	89 df                	mov    %ebx,%edi
  80080d:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800810:	41 83 ec 01          	sub    $0x1,%r12d
  800814:	75 f2                	jne    800808 <vprintfmt+0x2a8>
  800816:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80081a:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80081e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800822:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800826:	0f b6 00             	movzbl (%rax),%eax
  800829:	0f be f8             	movsbl %al,%edi
  80082c:	85 ff                	test   %edi,%edi
  80082e:	0f 84 56 fd ff ff    	je     80058a <vprintfmt+0x2a>
  800834:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800838:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80083c:	eb 19                	jmp    800857 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80083e:	4c 89 fe             	mov    %r15,%rsi
  800841:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800844:	41 83 ee 01          	sub    $0x1,%r14d
  800848:	48 83 c3 01          	add    $0x1,%rbx
  80084c:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800850:	0f be f8             	movsbl %al,%edi
  800853:	85 ff                	test   %edi,%edi
  800855:	74 29                	je     800880 <vprintfmt+0x320>
  800857:	45 85 e4             	test   %r12d,%r12d
  80085a:	78 06                	js     800862 <vprintfmt+0x302>
  80085c:	41 83 ec 01          	sub    $0x1,%r12d
  800860:	78 48                	js     8008aa <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800862:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800866:	74 d6                	je     80083e <vprintfmt+0x2de>
  800868:	0f be c0             	movsbl %al,%eax
  80086b:	83 e8 20             	sub    $0x20,%eax
  80086e:	83 f8 5e             	cmp    $0x5e,%eax
  800871:	76 cb                	jbe    80083e <vprintfmt+0x2de>
            putch('?', putdat);
  800873:	4c 89 fe             	mov    %r15,%rsi
  800876:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80087b:	41 ff d5             	callq  *%r13
  80087e:	eb c4                	jmp    800844 <vprintfmt+0x2e4>
  800880:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800884:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800888:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80088b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80088f:	0f 8e f5 fc ff ff    	jle    80058a <vprintfmt+0x2a>
          putch(' ', putdat);
  800895:	4c 89 fe             	mov    %r15,%rsi
  800898:	bf 20 00 00 00       	mov    $0x20,%edi
  80089d:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8008a0:	83 eb 01             	sub    $0x1,%ebx
  8008a3:	75 f0                	jne    800895 <vprintfmt+0x335>
  8008a5:	e9 e0 fc ff ff       	jmpq   80058a <vprintfmt+0x2a>
  8008aa:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008ae:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8008b2:	eb d4                	jmp    800888 <vprintfmt+0x328>
  if (lflag >= 2)
  8008b4:	83 f9 01             	cmp    $0x1,%ecx
  8008b7:	7f 1d                	jg     8008d6 <vprintfmt+0x376>
  else if (lflag)
  8008b9:	85 c9                	test   %ecx,%ecx
  8008bb:	74 5e                	je     80091b <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8008bd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008c0:	83 f8 2f             	cmp    $0x2f,%eax
  8008c3:	77 48                	ja     80090d <vprintfmt+0x3ad>
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008cb:	83 c0 08             	add    $0x8,%eax
  8008ce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008d1:	48 8b 1a             	mov    (%rdx),%rbx
  8008d4:	eb 17                	jmp    8008ed <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008d6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d9:	83 f8 2f             	cmp    $0x2f,%eax
  8008dc:	77 21                	ja     8008ff <vprintfmt+0x39f>
  8008de:	89 c2                	mov    %eax,%edx
  8008e0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e4:	83 c0 08             	add    $0x8,%eax
  8008e7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ea:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008ed:	48 85 db             	test   %rbx,%rbx
  8008f0:	78 50                	js     800942 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008f2:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008fa:	e9 b4 01 00 00       	jmpq   800ab3 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800903:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800907:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80090b:	eb dd                	jmp    8008ea <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80090d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800911:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800915:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800919:	eb b6                	jmp    8008d1 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80091b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091e:	83 f8 2f             	cmp    $0x2f,%eax
  800921:	77 11                	ja     800934 <vprintfmt+0x3d4>
  800923:	89 c2                	mov    %eax,%edx
  800925:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800929:	83 c0 08             	add    $0x8,%eax
  80092c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092f:	48 63 1a             	movslq (%rdx),%rbx
  800932:	eb b9                	jmp    8008ed <vprintfmt+0x38d>
  800934:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800938:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800940:	eb ed                	jmp    80092f <vprintfmt+0x3cf>
          putch('-', putdat);
  800942:	4c 89 fe             	mov    %r15,%rsi
  800945:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80094a:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80094d:	48 89 da             	mov    %rbx,%rdx
  800950:	48 f7 da             	neg    %rdx
        base = 10;
  800953:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800958:	e9 56 01 00 00       	jmpq   800ab3 <vprintfmt+0x553>
  if (lflag >= 2)
  80095d:	83 f9 01             	cmp    $0x1,%ecx
  800960:	7f 25                	jg     800987 <vprintfmt+0x427>
  else if (lflag)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 5e                	je     8009c4 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800966:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800969:	83 f8 2f             	cmp    $0x2f,%eax
  80096c:	77 48                	ja     8009b6 <vprintfmt+0x456>
  80096e:	89 c2                	mov    %eax,%edx
  800970:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800974:	83 c0 08             	add    $0x8,%eax
  800977:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80097a:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80097d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800982:	e9 2c 01 00 00       	jmpq   800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800987:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80098a:	83 f8 2f             	cmp    $0x2f,%eax
  80098d:	77 19                	ja     8009a8 <vprintfmt+0x448>
  80098f:	89 c2                	mov    %eax,%edx
  800991:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800995:	83 c0 08             	add    $0x8,%eax
  800998:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80099b:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80099e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009a3:	e9 0b 01 00 00       	jmpq   800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009a8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b4:	eb e5                	jmp    80099b <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8009b6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ba:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009be:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c2:	eb b6                	jmp    80097a <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8009c4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c7:	83 f8 2f             	cmp    $0x2f,%eax
  8009ca:	77 18                	ja     8009e4 <vprintfmt+0x484>
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d2:	83 c0 08             	add    $0x8,%eax
  8009d5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d8:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009da:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009df:	e9 cf 00 00 00       	jmpq   800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009e4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009e8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ec:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009f0:	eb e6                	jmp    8009d8 <vprintfmt+0x478>
  if (lflag >= 2)
  8009f2:	83 f9 01             	cmp    $0x1,%ecx
  8009f5:	7f 25                	jg     800a1c <vprintfmt+0x4bc>
  else if (lflag)
  8009f7:	85 c9                	test   %ecx,%ecx
  8009f9:	74 5b                	je     800a56 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009fb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009fe:	83 f8 2f             	cmp    $0x2f,%eax
  800a01:	77 45                	ja     800a48 <vprintfmt+0x4e8>
  800a03:	89 c2                	mov    %eax,%edx
  800a05:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a09:	83 c0 08             	add    $0x8,%eax
  800a0c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a0f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a12:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a17:	e9 97 00 00 00       	jmpq   800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a1c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a1f:	83 f8 2f             	cmp    $0x2f,%eax
  800a22:	77 16                	ja     800a3a <vprintfmt+0x4da>
  800a24:	89 c2                	mov    %eax,%edx
  800a26:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a2a:	83 c0 08             	add    $0x8,%eax
  800a2d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a30:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a33:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a38:	eb 79                	jmp    800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a3a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a3e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a42:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a46:	eb e8                	jmp    800a30 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a48:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a4c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a50:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a54:	eb b9                	jmp    800a0f <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a56:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a59:	83 f8 2f             	cmp    $0x2f,%eax
  800a5c:	77 15                	ja     800a73 <vprintfmt+0x513>
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a64:	83 c0 08             	add    $0x8,%eax
  800a67:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a6a:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a6c:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a71:	eb 40                	jmp    800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a73:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a77:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a7b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a7f:	eb e9                	jmp    800a6a <vprintfmt+0x50a>
        putch('0', putdat);
  800a81:	4c 89 fe             	mov    %r15,%rsi
  800a84:	bf 30 00 00 00       	mov    $0x30,%edi
  800a89:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a8c:	4c 89 fe             	mov    %r15,%rsi
  800a8f:	bf 78 00 00 00       	mov    $0x78,%edi
  800a94:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a97:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a9a:	83 f8 2f             	cmp    $0x2f,%eax
  800a9d:	77 34                	ja     800ad3 <vprintfmt+0x573>
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aa5:	83 c0 08             	add    $0x8,%eax
  800aa8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aab:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aae:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800ab3:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800ab8:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800abc:	4c 89 fe             	mov    %r15,%rsi
  800abf:	4c 89 ef             	mov    %r13,%rdi
  800ac2:	48 b8 36 04 80 00 00 	movabs $0x800436,%rax
  800ac9:	00 00 00 
  800acc:	ff d0                	callq  *%rax
        break;
  800ace:	e9 b7 fa ff ff       	jmpq   80058a <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ad3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800adb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800adf:	eb ca                	jmp    800aab <vprintfmt+0x54b>
  if (lflag >= 2)
  800ae1:	83 f9 01             	cmp    $0x1,%ecx
  800ae4:	7f 22                	jg     800b08 <vprintfmt+0x5a8>
  else if (lflag)
  800ae6:	85 c9                	test   %ecx,%ecx
  800ae8:	74 58                	je     800b42 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800aea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aed:	83 f8 2f             	cmp    $0x2f,%eax
  800af0:	77 42                	ja     800b34 <vprintfmt+0x5d4>
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af8:	83 c0 08             	add    $0x8,%eax
  800afb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800afe:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b01:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b06:	eb ab                	jmp    800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b08:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b0b:	83 f8 2f             	cmp    $0x2f,%eax
  800b0e:	77 16                	ja     800b26 <vprintfmt+0x5c6>
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b16:	83 c0 08             	add    $0x8,%eax
  800b19:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b1c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b1f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b24:	eb 8d                	jmp    800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b26:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b2a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b2e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b32:	eb e8                	jmp    800b1c <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b34:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b38:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b3c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b40:	eb bc                	jmp    800afe <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b42:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b45:	83 f8 2f             	cmp    $0x2f,%eax
  800b48:	77 18                	ja     800b62 <vprintfmt+0x602>
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b50:	83 c0 08             	add    $0x8,%eax
  800b53:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b56:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b58:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b5d:	e9 51 ff ff ff       	jmpq   800ab3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b62:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b66:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b6a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b6e:	eb e6                	jmp    800b56 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b70:	4c 89 fe             	mov    %r15,%rsi
  800b73:	bf 25 00 00 00       	mov    $0x25,%edi
  800b78:	41 ff d5             	callq  *%r13
        break;
  800b7b:	e9 0a fa ff ff       	jmpq   80058a <vprintfmt+0x2a>
        putch('%', putdat);
  800b80:	4c 89 fe             	mov    %r15,%rsi
  800b83:	bf 25 00 00 00       	mov    $0x25,%edi
  800b88:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b8b:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b8f:	0f 84 15 fa ff ff    	je     8005aa <vprintfmt+0x4a>
  800b95:	49 89 de             	mov    %rbx,%r14
  800b98:	49 83 ee 01          	sub    $0x1,%r14
  800b9c:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800ba1:	75 f5                	jne    800b98 <vprintfmt+0x638>
  800ba3:	e9 e2 f9 ff ff       	jmpq   80058a <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800ba8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800bac:	74 06                	je     800bb4 <vprintfmt+0x654>
  800bae:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800bb2:	7f 21                	jg     800bd5 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb4:	bf 28 00 00 00       	mov    $0x28,%edi
  800bb9:	48 bb 9d 16 80 00 00 	movabs $0x80169d,%rbx
  800bc0:	00 00 00 
  800bc3:	b8 28 00 00 00       	mov    $0x28,%eax
  800bc8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bcc:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bd0:	e9 82 fc ff ff       	jmpq   800857 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800bd5:	49 63 f4             	movslq %r12d,%rsi
  800bd8:	48 bf 9c 16 80 00 00 	movabs $0x80169c,%rdi
  800bdf:	00 00 00 
  800be2:	48 b8 37 0d 80 00 00 	movabs $0x800d37,%rax
  800be9:	00 00 00 
  800bec:	ff d0                	callq  *%rax
  800bee:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bf1:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bf4:	48 be 9c 16 80 00 00 	movabs $0x80169c,%rsi
  800bfb:	00 00 00 
  800bfe:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	0f 8f f2 fb ff ff    	jg     8007fc <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c0a:	48 bb 9d 16 80 00 00 	movabs $0x80169d,%rbx
  800c11:	00 00 00 
  800c14:	b8 28 00 00 00       	mov    $0x28,%eax
  800c19:	bf 28 00 00 00       	mov    $0x28,%edi
  800c1e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c22:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c26:	e9 2c fc ff ff       	jmpq   800857 <vprintfmt+0x2f7>
}
  800c2b:	48 83 c4 48          	add    $0x48,%rsp
  800c2f:	5b                   	pop    %rbx
  800c30:	41 5c                	pop    %r12
  800c32:	41 5d                	pop    %r13
  800c34:	41 5e                	pop    %r14
  800c36:	41 5f                	pop    %r15
  800c38:	5d                   	pop    %rbp
  800c39:	c3                   	retq   

0000000000800c3a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c3a:	55                   	push   %rbp
  800c3b:	48 89 e5             	mov    %rsp,%rbp
  800c3e:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c42:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c46:	48 63 c6             	movslq %esi,%rax
  800c49:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c4e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c52:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c59:	48 85 ff             	test   %rdi,%rdi
  800c5c:	74 2a                	je     800c88 <vsnprintf+0x4e>
  800c5e:	85 f6                	test   %esi,%esi
  800c60:	7e 26                	jle    800c88 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c62:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c66:	48 bf c2 04 80 00 00 	movabs $0x8004c2,%rdi
  800c6d:	00 00 00 
  800c70:	48 b8 60 05 80 00 00 	movabs $0x800560,%rax
  800c77:	00 00 00 
  800c7a:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c7c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c80:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c83:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c86:	c9                   	leaveq 
  800c87:	c3                   	retq   
    return -E_INVAL;
  800c88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c8d:	eb f7                	jmp    800c86 <vsnprintf+0x4c>

0000000000800c8f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c8f:	55                   	push   %rbp
  800c90:	48 89 e5             	mov    %rsp,%rbp
  800c93:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c9a:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ca1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ca8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800caf:	84 c0                	test   %al,%al
  800cb1:	74 20                	je     800cd3 <snprintf+0x44>
  800cb3:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800cb7:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800cbb:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800cbf:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800cc3:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800cc7:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ccb:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ccf:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800cd3:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800cda:	00 00 00 
  800cdd:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ce4:	00 00 00 
  800ce7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800ceb:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cf2:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cf9:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800d00:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800d07:	48 b8 3a 0c 80 00 00 	movabs $0x800c3a,%rax
  800d0e:	00 00 00 
  800d11:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800d13:	c9                   	leaveq 
  800d14:	c3                   	retq   

0000000000800d15 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800d15:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d18:	74 17                	je     800d31 <strlen+0x1c>
  800d1a:	48 89 fa             	mov    %rdi,%rdx
  800d1d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d22:	29 f9                	sub    %edi,%ecx
    n++;
  800d24:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d27:	48 83 c2 01          	add    $0x1,%rdx
  800d2b:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d2e:	75 f4                	jne    800d24 <strlen+0xf>
  800d30:	c3                   	retq   
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d36:	c3                   	retq   

0000000000800d37 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d37:	48 85 f6             	test   %rsi,%rsi
  800d3a:	74 24                	je     800d60 <strnlen+0x29>
  800d3c:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d3f:	74 25                	je     800d66 <strnlen+0x2f>
  800d41:	48 01 fe             	add    %rdi,%rsi
  800d44:	48 89 fa             	mov    %rdi,%rdx
  800d47:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d4c:	29 f9                	sub    %edi,%ecx
    n++;
  800d4e:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d51:	48 83 c2 01          	add    $0x1,%rdx
  800d55:	48 39 f2             	cmp    %rsi,%rdx
  800d58:	74 11                	je     800d6b <strnlen+0x34>
  800d5a:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d5d:	75 ef                	jne    800d4e <strnlen+0x17>
  800d5f:	c3                   	retq   
  800d60:	b8 00 00 00 00       	mov    $0x0,%eax
  800d65:	c3                   	retq   
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d6b:	c3                   	retq   

0000000000800d6c <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d6c:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d78:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d7b:	48 83 c2 01          	add    $0x1,%rdx
  800d7f:	84 c9                	test   %cl,%cl
  800d81:	75 f1                	jne    800d74 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d83:	c3                   	retq   

0000000000800d84 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d84:	55                   	push   %rbp
  800d85:	48 89 e5             	mov    %rsp,%rbp
  800d88:	41 54                	push   %r12
  800d8a:	53                   	push   %rbx
  800d8b:	48 89 fb             	mov    %rdi,%rbx
  800d8e:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d91:	48 b8 15 0d 80 00 00 	movabs $0x800d15,%rax
  800d98:	00 00 00 
  800d9b:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d9d:	48 63 f8             	movslq %eax,%rdi
  800da0:	48 01 df             	add    %rbx,%rdi
  800da3:	4c 89 e6             	mov    %r12,%rsi
  800da6:	48 b8 6c 0d 80 00 00 	movabs $0x800d6c,%rax
  800dad:	00 00 00 
  800db0:	ff d0                	callq  *%rax
  return dst;
}
  800db2:	48 89 d8             	mov    %rbx,%rax
  800db5:	5b                   	pop    %rbx
  800db6:	41 5c                	pop    %r12
  800db8:	5d                   	pop    %rbp
  800db9:	c3                   	retq   

0000000000800dba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dba:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800dbd:	48 85 d2             	test   %rdx,%rdx
  800dc0:	74 1f                	je     800de1 <strncpy+0x27>
  800dc2:	48 01 fa             	add    %rdi,%rdx
  800dc5:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800dc8:	48 83 c1 01          	add    $0x1,%rcx
  800dcc:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dd0:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800dd4:	41 80 f8 01          	cmp    $0x1,%r8b
  800dd8:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800ddc:	48 39 ca             	cmp    %rcx,%rdx
  800ddf:	75 e7                	jne    800dc8 <strncpy+0xe>
  }
  return ret;
}
  800de1:	c3                   	retq   

0000000000800de2 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800de2:	48 89 f8             	mov    %rdi,%rax
  800de5:	48 85 d2             	test   %rdx,%rdx
  800de8:	74 36                	je     800e20 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800dea:	48 83 fa 01          	cmp    $0x1,%rdx
  800dee:	74 2d                	je     800e1d <strlcpy+0x3b>
  800df0:	44 0f b6 06          	movzbl (%rsi),%r8d
  800df4:	45 84 c0             	test   %r8b,%r8b
  800df7:	74 24                	je     800e1d <strlcpy+0x3b>
  800df9:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dfd:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800e02:	48 83 c0 01          	add    $0x1,%rax
  800e06:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800e0a:	48 39 d1             	cmp    %rdx,%rcx
  800e0d:	74 0e                	je     800e1d <strlcpy+0x3b>
  800e0f:	48 83 c1 01          	add    $0x1,%rcx
  800e13:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800e18:	45 84 c0             	test   %r8b,%r8b
  800e1b:	75 e5                	jne    800e02 <strlcpy+0x20>
    *dst = '\0';
  800e1d:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800e20:	48 29 f8             	sub    %rdi,%rax
}
  800e23:	c3                   	retq   

0000000000800e24 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e24:	0f b6 07             	movzbl (%rdi),%eax
  800e27:	84 c0                	test   %al,%al
  800e29:	74 17                	je     800e42 <strcmp+0x1e>
  800e2b:	3a 06                	cmp    (%rsi),%al
  800e2d:	75 13                	jne    800e42 <strcmp+0x1e>
    p++, q++;
  800e2f:	48 83 c7 01          	add    $0x1,%rdi
  800e33:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e37:	0f b6 07             	movzbl (%rdi),%eax
  800e3a:	84 c0                	test   %al,%al
  800e3c:	74 04                	je     800e42 <strcmp+0x1e>
  800e3e:	3a 06                	cmp    (%rsi),%al
  800e40:	74 ed                	je     800e2f <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e42:	0f b6 c0             	movzbl %al,%eax
  800e45:	0f b6 16             	movzbl (%rsi),%edx
  800e48:	29 d0                	sub    %edx,%eax
}
  800e4a:	c3                   	retq   

0000000000800e4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e4b:	48 85 d2             	test   %rdx,%rdx
  800e4e:	74 2f                	je     800e7f <strncmp+0x34>
  800e50:	0f b6 07             	movzbl (%rdi),%eax
  800e53:	84 c0                	test   %al,%al
  800e55:	74 1f                	je     800e76 <strncmp+0x2b>
  800e57:	3a 06                	cmp    (%rsi),%al
  800e59:	75 1b                	jne    800e76 <strncmp+0x2b>
  800e5b:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e5e:	48 83 c7 01          	add    $0x1,%rdi
  800e62:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e66:	48 39 d7             	cmp    %rdx,%rdi
  800e69:	74 1a                	je     800e85 <strncmp+0x3a>
  800e6b:	0f b6 07             	movzbl (%rdi),%eax
  800e6e:	84 c0                	test   %al,%al
  800e70:	74 04                	je     800e76 <strncmp+0x2b>
  800e72:	3a 06                	cmp    (%rsi),%al
  800e74:	74 e8                	je     800e5e <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e76:	0f b6 07             	movzbl (%rdi),%eax
  800e79:	0f b6 16             	movzbl (%rsi),%edx
  800e7c:	29 d0                	sub    %edx,%eax
}
  800e7e:	c3                   	retq   
    return 0;
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	c3                   	retq   
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8a:	c3                   	retq   

0000000000800e8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e8b:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e8d:	0f b6 07             	movzbl (%rdi),%eax
  800e90:	84 c0                	test   %al,%al
  800e92:	74 1e                	je     800eb2 <strchr+0x27>
    if (*s == c)
  800e94:	40 38 c6             	cmp    %al,%sil
  800e97:	74 1f                	je     800eb8 <strchr+0x2d>
  for (; *s; s++)
  800e99:	48 83 c7 01          	add    $0x1,%rdi
  800e9d:	0f b6 07             	movzbl (%rdi),%eax
  800ea0:	84 c0                	test   %al,%al
  800ea2:	74 08                	je     800eac <strchr+0x21>
    if (*s == c)
  800ea4:	38 d0                	cmp    %dl,%al
  800ea6:	75 f1                	jne    800e99 <strchr+0xe>
  for (; *s; s++)
  800ea8:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800eab:	c3                   	retq   
  return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	c3                   	retq   
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	c3                   	retq   
    if (*s == c)
  800eb8:	48 89 f8             	mov    %rdi,%rax
  800ebb:	c3                   	retq   

0000000000800ebc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ebc:	48 89 f8             	mov    %rdi,%rax
  800ebf:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800ec1:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800ec4:	40 38 f2             	cmp    %sil,%dl
  800ec7:	74 13                	je     800edc <strfind+0x20>
  800ec9:	84 d2                	test   %dl,%dl
  800ecb:	74 0f                	je     800edc <strfind+0x20>
  for (; *s; s++)
  800ecd:	48 83 c0 01          	add    $0x1,%rax
  800ed1:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800ed4:	38 ca                	cmp    %cl,%dl
  800ed6:	74 04                	je     800edc <strfind+0x20>
  800ed8:	84 d2                	test   %dl,%dl
  800eda:	75 f1                	jne    800ecd <strfind+0x11>
      break;
  return (char *)s;
}
  800edc:	c3                   	retq   

0000000000800edd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800edd:	48 85 d2             	test   %rdx,%rdx
  800ee0:	74 3a                	je     800f1c <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ee2:	48 89 f8             	mov    %rdi,%rax
  800ee5:	48 09 d0             	or     %rdx,%rax
  800ee8:	a8 03                	test   $0x3,%al
  800eea:	75 28                	jne    800f14 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800eec:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	c1 e0 08             	shl    $0x8,%eax
  800ef5:	89 f1                	mov    %esi,%ecx
  800ef7:	c1 e1 18             	shl    $0x18,%ecx
  800efa:	41 89 f0             	mov    %esi,%r8d
  800efd:	41 c1 e0 10          	shl    $0x10,%r8d
  800f01:	44 09 c1             	or     %r8d,%ecx
  800f04:	09 ce                	or     %ecx,%esi
  800f06:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800f08:	48 c1 ea 02          	shr    $0x2,%rdx
  800f0c:	48 89 d1             	mov    %rdx,%rcx
  800f0f:	fc                   	cld    
  800f10:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f12:	eb 08                	jmp    800f1c <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800f14:	89 f0                	mov    %esi,%eax
  800f16:	48 89 d1             	mov    %rdx,%rcx
  800f19:	fc                   	cld    
  800f1a:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800f1c:	48 89 f8             	mov    %rdi,%rax
  800f1f:	c3                   	retq   

0000000000800f20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800f20:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f23:	48 39 fe             	cmp    %rdi,%rsi
  800f26:	73 40                	jae    800f68 <memmove+0x48>
  800f28:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f2c:	48 39 f9             	cmp    %rdi,%rcx
  800f2f:	76 37                	jbe    800f68 <memmove+0x48>
    s += n;
    d += n;
  800f31:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f35:	48 89 fe             	mov    %rdi,%rsi
  800f38:	48 09 d6             	or     %rdx,%rsi
  800f3b:	48 09 ce             	or     %rcx,%rsi
  800f3e:	40 f6 c6 03          	test   $0x3,%sil
  800f42:	75 14                	jne    800f58 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f44:	48 83 ef 04          	sub    $0x4,%rdi
  800f48:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f4c:	48 c1 ea 02          	shr    $0x2,%rdx
  800f50:	48 89 d1             	mov    %rdx,%rcx
  800f53:	fd                   	std    
  800f54:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f56:	eb 0e                	jmp    800f66 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f58:	48 83 ef 01          	sub    $0x1,%rdi
  800f5c:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f60:	48 89 d1             	mov    %rdx,%rcx
  800f63:	fd                   	std    
  800f64:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f66:	fc                   	cld    
  800f67:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f68:	48 89 c1             	mov    %rax,%rcx
  800f6b:	48 09 d1             	or     %rdx,%rcx
  800f6e:	48 09 f1             	or     %rsi,%rcx
  800f71:	f6 c1 03             	test   $0x3,%cl
  800f74:	75 0e                	jne    800f84 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f76:	48 c1 ea 02          	shr    $0x2,%rdx
  800f7a:	48 89 d1             	mov    %rdx,%rcx
  800f7d:	48 89 c7             	mov    %rax,%rdi
  800f80:	fc                   	cld    
  800f81:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f83:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f84:	48 89 c7             	mov    %rax,%rdi
  800f87:	48 89 d1             	mov    %rdx,%rcx
  800f8a:	fc                   	cld    
  800f8b:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f8d:	c3                   	retq   

0000000000800f8e <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f8e:	55                   	push   %rbp
  800f8f:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f92:	48 b8 20 0f 80 00 00 	movabs $0x800f20,%rax
  800f99:	00 00 00 
  800f9c:	ff d0                	callq  *%rax
}
  800f9e:	5d                   	pop    %rbp
  800f9f:	c3                   	retq   

0000000000800fa0 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800fa0:	55                   	push   %rbp
  800fa1:	48 89 e5             	mov    %rsp,%rbp
  800fa4:	41 57                	push   %r15
  800fa6:	41 56                	push   %r14
  800fa8:	41 55                	push   %r13
  800faa:	41 54                	push   %r12
  800fac:	53                   	push   %rbx
  800fad:	48 83 ec 08          	sub    $0x8,%rsp
  800fb1:	49 89 fe             	mov    %rdi,%r14
  800fb4:	49 89 f7             	mov    %rsi,%r15
  800fb7:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800fba:	48 89 f7             	mov    %rsi,%rdi
  800fbd:	48 b8 15 0d 80 00 00 	movabs $0x800d15,%rax
  800fc4:	00 00 00 
  800fc7:	ff d0                	callq  *%rax
  800fc9:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800fcc:	4c 89 ee             	mov    %r13,%rsi
  800fcf:	4c 89 f7             	mov    %r14,%rdi
  800fd2:	48 b8 37 0d 80 00 00 	movabs $0x800d37,%rax
  800fd9:	00 00 00 
  800fdc:	ff d0                	callq  *%rax
  800fde:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fe1:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fe5:	4d 39 e5             	cmp    %r12,%r13
  800fe8:	74 26                	je     801010 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fea:	4c 89 e8             	mov    %r13,%rax
  800fed:	4c 29 e0             	sub    %r12,%rax
  800ff0:	48 39 d8             	cmp    %rbx,%rax
  800ff3:	76 2a                	jbe    80101f <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800ff5:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800ff9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ffd:	4c 89 fe             	mov    %r15,%rsi
  801000:	48 b8 8e 0f 80 00 00 	movabs $0x800f8e,%rax
  801007:	00 00 00 
  80100a:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80100c:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801010:	48 83 c4 08          	add    $0x8,%rsp
  801014:	5b                   	pop    %rbx
  801015:	41 5c                	pop    %r12
  801017:	41 5d                	pop    %r13
  801019:	41 5e                	pop    %r14
  80101b:	41 5f                	pop    %r15
  80101d:	5d                   	pop    %rbp
  80101e:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80101f:	49 83 ed 01          	sub    $0x1,%r13
  801023:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801027:	4c 89 ea             	mov    %r13,%rdx
  80102a:	4c 89 fe             	mov    %r15,%rsi
  80102d:	48 b8 8e 0f 80 00 00 	movabs $0x800f8e,%rax
  801034:	00 00 00 
  801037:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801039:	4d 01 ee             	add    %r13,%r14
  80103c:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801041:	eb c9                	jmp    80100c <strlcat+0x6c>

0000000000801043 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801043:	48 85 d2             	test   %rdx,%rdx
  801046:	74 3a                	je     801082 <memcmp+0x3f>
    if (*s1 != *s2)
  801048:	0f b6 0f             	movzbl (%rdi),%ecx
  80104b:	44 0f b6 06          	movzbl (%rsi),%r8d
  80104f:	44 38 c1             	cmp    %r8b,%cl
  801052:	75 1d                	jne    801071 <memcmp+0x2e>
  801054:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801059:	48 39 d0             	cmp    %rdx,%rax
  80105c:	74 1e                	je     80107c <memcmp+0x39>
    if (*s1 != *s2)
  80105e:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801062:	48 83 c0 01          	add    $0x1,%rax
  801066:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  80106c:	44 38 c1             	cmp    %r8b,%cl
  80106f:	74 e8                	je     801059 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801071:	0f b6 c1             	movzbl %cl,%eax
  801074:	45 0f b6 c0          	movzbl %r8b,%r8d
  801078:	44 29 c0             	sub    %r8d,%eax
  80107b:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	c3                   	retq   
  801082:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801087:	c3                   	retq   

0000000000801088 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801088:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80108c:	48 39 c7             	cmp    %rax,%rdi
  80108f:	73 19                	jae    8010aa <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801091:	89 f2                	mov    %esi,%edx
  801093:	40 38 37             	cmp    %sil,(%rdi)
  801096:	74 16                	je     8010ae <memfind+0x26>
  for (; s < ends; s++)
  801098:	48 83 c7 01          	add    $0x1,%rdi
  80109c:	48 39 f8             	cmp    %rdi,%rax
  80109f:	74 08                	je     8010a9 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010a1:	38 17                	cmp    %dl,(%rdi)
  8010a3:	75 f3                	jne    801098 <memfind+0x10>
  for (; s < ends; s++)
  8010a5:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8010a8:	c3                   	retq   
  8010a9:	c3                   	retq   
  for (; s < ends; s++)
  8010aa:	48 89 f8             	mov    %rdi,%rax
  8010ad:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8010ae:	48 89 f8             	mov    %rdi,%rax
  8010b1:	c3                   	retq   

00000000008010b2 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8010b2:	0f b6 07             	movzbl (%rdi),%eax
  8010b5:	3c 20                	cmp    $0x20,%al
  8010b7:	74 04                	je     8010bd <strtol+0xb>
  8010b9:	3c 09                	cmp    $0x9,%al
  8010bb:	75 0f                	jne    8010cc <strtol+0x1a>
    s++;
  8010bd:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  8010c1:	0f b6 07             	movzbl (%rdi),%eax
  8010c4:	3c 20                	cmp    $0x20,%al
  8010c6:	74 f5                	je     8010bd <strtol+0xb>
  8010c8:	3c 09                	cmp    $0x9,%al
  8010ca:	74 f1                	je     8010bd <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010cc:	3c 2b                	cmp    $0x2b,%al
  8010ce:	74 2b                	je     8010fb <strtol+0x49>
  int neg  = 0;
  8010d0:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010d6:	3c 2d                	cmp    $0x2d,%al
  8010d8:	74 2d                	je     801107 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010da:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010e0:	75 0f                	jne    8010f1 <strtol+0x3f>
  8010e2:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010e5:	74 2c                	je     801113 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010e7:	85 d2                	test   %edx,%edx
  8010e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ee:	0f 44 d0             	cmove  %eax,%edx
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010f6:	4c 63 d2             	movslq %edx,%r10
  8010f9:	eb 5c                	jmp    801157 <strtol+0xa5>
    s++;
  8010fb:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010ff:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801105:	eb d3                	jmp    8010da <strtol+0x28>
    s++, neg = 1;
  801107:	48 83 c7 01          	add    $0x1,%rdi
  80110b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801111:	eb c7                	jmp    8010da <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801113:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801117:	74 0f                	je     801128 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801119:	85 d2                	test   %edx,%edx
  80111b:	75 d4                	jne    8010f1 <strtol+0x3f>
    s++, base = 8;
  80111d:	48 83 c7 01          	add    $0x1,%rdi
  801121:	ba 08 00 00 00       	mov    $0x8,%edx
  801126:	eb c9                	jmp    8010f1 <strtol+0x3f>
    s += 2, base = 16;
  801128:	48 83 c7 02          	add    $0x2,%rdi
  80112c:	ba 10 00 00 00       	mov    $0x10,%edx
  801131:	eb be                	jmp    8010f1 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801133:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801137:	41 80 f8 19          	cmp    $0x19,%r8b
  80113b:	77 2f                	ja     80116c <strtol+0xba>
      dig = *s - 'a' + 10;
  80113d:	44 0f be c1          	movsbl %cl,%r8d
  801141:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801145:	39 d1                	cmp    %edx,%ecx
  801147:	7d 37                	jge    801180 <strtol+0xce>
    s++, val = (val * base) + dig;
  801149:	48 83 c7 01          	add    $0x1,%rdi
  80114d:	49 0f af c2          	imul   %r10,%rax
  801151:	48 63 c9             	movslq %ecx,%rcx
  801154:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801157:	0f b6 0f             	movzbl (%rdi),%ecx
  80115a:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80115e:	41 80 f8 09          	cmp    $0x9,%r8b
  801162:	77 cf                	ja     801133 <strtol+0x81>
      dig = *s - '0';
  801164:	0f be c9             	movsbl %cl,%ecx
  801167:	83 e9 30             	sub    $0x30,%ecx
  80116a:	eb d9                	jmp    801145 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80116c:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801170:	41 80 f8 19          	cmp    $0x19,%r8b
  801174:	77 0a                	ja     801180 <strtol+0xce>
      dig = *s - 'A' + 10;
  801176:	44 0f be c1          	movsbl %cl,%r8d
  80117a:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80117e:	eb c5                	jmp    801145 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801180:	48 85 f6             	test   %rsi,%rsi
  801183:	74 03                	je     801188 <strtol+0xd6>
    *endptr = (char *)s;
  801185:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801188:	48 89 c2             	mov    %rax,%rdx
  80118b:	48 f7 da             	neg    %rdx
  80118e:	45 85 c9             	test   %r9d,%r9d
  801191:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801195:	c3                   	retq   

0000000000801196 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  801196:	55                   	push   %rbp
  801197:	48 89 e5             	mov    %rsp,%rbp
  80119a:	53                   	push   %rbx
  80119b:	48 89 fa             	mov    %rdi,%rdx
  80119e:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a6:	48 89 c3             	mov    %rax,%rbx
  8011a9:	48 89 c7             	mov    %rax,%rdi
  8011ac:	48 89 c6             	mov    %rax,%rsi
  8011af:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8011b1:	5b                   	pop    %rbx
  8011b2:	5d                   	pop    %rbp
  8011b3:	c3                   	retq   

00000000008011b4 <sys_cgetc>:

int
sys_cgetc(void) {
  8011b4:	55                   	push   %rbp
  8011b5:	48 89 e5             	mov    %rsp,%rbp
  8011b8:	53                   	push   %rbx
  asm volatile("int %1\n"
  8011b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011be:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c3:	48 89 ca             	mov    %rcx,%rdx
  8011c6:	48 89 cb             	mov    %rcx,%rbx
  8011c9:	48 89 cf             	mov    %rcx,%rdi
  8011cc:	48 89 ce             	mov    %rcx,%rsi
  8011cf:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011d1:	5b                   	pop    %rbx
  8011d2:	5d                   	pop    %rbp
  8011d3:	c3                   	retq   

00000000008011d4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8011d4:	55                   	push   %rbp
  8011d5:	48 89 e5             	mov    %rsp,%rbp
  8011d8:	53                   	push   %rbx
  8011d9:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8011dd:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8011e0:	be 00 00 00 00       	mov    $0x0,%esi
  8011e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8011ea:	48 89 f1             	mov    %rsi,%rcx
  8011ed:	48 89 f3             	mov    %rsi,%rbx
  8011f0:	48 89 f7             	mov    %rsi,%rdi
  8011f3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011f5:	48 85 c0             	test   %rax,%rax
  8011f8:	7f 07                	jg     801201 <sys_env_destroy+0x2d>
}
  8011fa:	48 83 c4 08          	add    $0x8,%rsp
  8011fe:	5b                   	pop    %rbx
  8011ff:	5d                   	pop    %rbp
  801200:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801201:	49 89 c0             	mov    %rax,%r8
  801204:	b9 03 00 00 00       	mov    $0x3,%ecx
  801209:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  801210:	00 00 00 
  801213:	be 22 00 00 00       	mov    $0x22,%esi
  801218:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  80121f:	00 00 00 
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  80122e:	00 00 00 
  801231:	41 ff d1             	callq  *%r9

0000000000801234 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801234:	55                   	push   %rbp
  801235:	48 89 e5             	mov    %rsp,%rbp
  801238:	53                   	push   %rbx
  asm volatile("int %1\n"
  801239:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123e:	b8 02 00 00 00       	mov    $0x2,%eax
  801243:	48 89 ca             	mov    %rcx,%rdx
  801246:	48 89 cb             	mov    %rcx,%rbx
  801249:	48 89 cf             	mov    %rcx,%rdi
  80124c:	48 89 ce             	mov    %rcx,%rsi
  80124f:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801251:	5b                   	pop    %rbx
  801252:	5d                   	pop    %rbp
  801253:	c3                   	retq   

0000000000801254 <sys_yield>:

void
sys_yield(void) {
  801254:	55                   	push   %rbp
  801255:	48 89 e5             	mov    %rsp,%rbp
  801258:	53                   	push   %rbx
  asm volatile("int %1\n"
  801259:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801263:	48 89 ca             	mov    %rcx,%rdx
  801266:	48 89 cb             	mov    %rcx,%rbx
  801269:	48 89 cf             	mov    %rcx,%rdi
  80126c:	48 89 ce             	mov    %rcx,%rsi
  80126f:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801271:	5b                   	pop    %rbx
  801272:	5d                   	pop    %rbp
  801273:	c3                   	retq   

0000000000801274 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  801274:	55                   	push   %rbp
  801275:	48 89 e5             	mov    %rsp,%rbp
  801278:	53                   	push   %rbx
  801279:	48 83 ec 08          	sub    $0x8,%rsp
  80127d:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801280:	4c 63 c7             	movslq %edi,%r8
  801283:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  801286:	be 00 00 00 00       	mov    $0x0,%esi
  80128b:	b8 04 00 00 00       	mov    $0x4,%eax
  801290:	4c 89 c2             	mov    %r8,%rdx
  801293:	48 89 f7             	mov    %rsi,%rdi
  801296:	cd 30                	int    $0x30
  if (check && ret > 0)
  801298:	48 85 c0             	test   %rax,%rax
  80129b:	7f 07                	jg     8012a4 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80129d:	48 83 c4 08          	add    $0x8,%rsp
  8012a1:	5b                   	pop    %rbx
  8012a2:	5d                   	pop    %rbp
  8012a3:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012a4:	49 89 c0             	mov    %rax,%r8
  8012a7:	b9 04 00 00 00       	mov    $0x4,%ecx
  8012ac:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  8012b3:	00 00 00 
  8012b6:	be 22 00 00 00       	mov    $0x22,%esi
  8012bb:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  8012c2:	00 00 00 
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ca:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  8012d1:	00 00 00 
  8012d4:	41 ff d1             	callq  *%r9

00000000008012d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8012d7:	55                   	push   %rbp
  8012d8:	48 89 e5             	mov    %rsp,%rbp
  8012db:	53                   	push   %rbx
  8012dc:	48 83 ec 08          	sub    $0x8,%rsp
  8012e0:	41 89 f9             	mov    %edi,%r9d
  8012e3:	49 89 f2             	mov    %rsi,%r10
  8012e6:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8012e9:	4d 63 c9             	movslq %r9d,%r9
  8012ec:	48 63 da             	movslq %edx,%rbx
  8012ef:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8012f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8012f7:	4c 89 ca             	mov    %r9,%rdx
  8012fa:	4c 89 d1             	mov    %r10,%rcx
  8012fd:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012ff:	48 85 c0             	test   %rax,%rax
  801302:	7f 07                	jg     80130b <sys_page_map+0x34>
}
  801304:	48 83 c4 08          	add    $0x8,%rsp
  801308:	5b                   	pop    %rbx
  801309:	5d                   	pop    %rbp
  80130a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80130b:	49 89 c0             	mov    %rax,%r8
  80130e:	b9 05 00 00 00       	mov    $0x5,%ecx
  801313:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  80131a:	00 00 00 
  80131d:	be 22 00 00 00       	mov    $0x22,%esi
  801322:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  801329:	00 00 00 
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
  801331:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  801338:	00 00 00 
  80133b:	41 ff d1             	callq  *%r9

000000000080133e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80133e:	55                   	push   %rbp
  80133f:	48 89 e5             	mov    %rsp,%rbp
  801342:	53                   	push   %rbx
  801343:	48 83 ec 08          	sub    $0x8,%rsp
  801347:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  80134a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80134d:	be 00 00 00 00       	mov    $0x0,%esi
  801352:	b8 06 00 00 00       	mov    $0x6,%eax
  801357:	48 89 f3             	mov    %rsi,%rbx
  80135a:	48 89 f7             	mov    %rsi,%rdi
  80135d:	cd 30                	int    $0x30
  if (check && ret > 0)
  80135f:	48 85 c0             	test   %rax,%rax
  801362:	7f 07                	jg     80136b <sys_page_unmap+0x2d>
}
  801364:	48 83 c4 08          	add    $0x8,%rsp
  801368:	5b                   	pop    %rbx
  801369:	5d                   	pop    %rbp
  80136a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80136b:	49 89 c0             	mov    %rax,%r8
  80136e:	b9 06 00 00 00       	mov    $0x6,%ecx
  801373:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  80137a:	00 00 00 
  80137d:	be 22 00 00 00       	mov    $0x22,%esi
  801382:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  801389:	00 00 00 
  80138c:	b8 00 00 00 00       	mov    $0x0,%eax
  801391:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  801398:	00 00 00 
  80139b:	41 ff d1             	callq  *%r9

000000000080139e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  80139e:	55                   	push   %rbp
  80139f:	48 89 e5             	mov    %rsp,%rbp
  8013a2:	53                   	push   %rbx
  8013a3:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8013a7:	48 63 d7             	movslq %edi,%rdx
  8013aa:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8013ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8013b7:	48 89 df             	mov    %rbx,%rdi
  8013ba:	48 89 de             	mov    %rbx,%rsi
  8013bd:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013bf:	48 85 c0             	test   %rax,%rax
  8013c2:	7f 07                	jg     8013cb <sys_env_set_status+0x2d>
}
  8013c4:	48 83 c4 08          	add    $0x8,%rsp
  8013c8:	5b                   	pop    %rbx
  8013c9:	5d                   	pop    %rbp
  8013ca:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013cb:	49 89 c0             	mov    %rax,%r8
  8013ce:	b9 08 00 00 00       	mov    $0x8,%ecx
  8013d3:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  8013da:	00 00 00 
  8013dd:	be 22 00 00 00       	mov    $0x22,%esi
  8013e2:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  8013e9:	00 00 00 
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f1:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  8013f8:	00 00 00 
  8013fb:	41 ff d1             	callq  *%r9

00000000008013fe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8013fe:	55                   	push   %rbp
  8013ff:	48 89 e5             	mov    %rsp,%rbp
  801402:	53                   	push   %rbx
  801403:	48 83 ec 08          	sub    $0x8,%rsp
  801407:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80140a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80140d:	be 00 00 00 00       	mov    $0x0,%esi
  801412:	b8 09 00 00 00       	mov    $0x9,%eax
  801417:	48 89 f3             	mov    %rsi,%rbx
  80141a:	48 89 f7             	mov    %rsi,%rdi
  80141d:	cd 30                	int    $0x30
  if (check && ret > 0)
  80141f:	48 85 c0             	test   %rax,%rax
  801422:	7f 07                	jg     80142b <sys_env_set_pgfault_upcall+0x2d>
}
  801424:	48 83 c4 08          	add    $0x8,%rsp
  801428:	5b                   	pop    %rbx
  801429:	5d                   	pop    %rbp
  80142a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80142b:	49 89 c0             	mov    %rax,%r8
  80142e:	b9 09 00 00 00       	mov    $0x9,%ecx
  801433:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  80143a:	00 00 00 
  80143d:	be 22 00 00 00       	mov    $0x22,%esi
  801442:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  801449:	00 00 00 
  80144c:	b8 00 00 00 00       	mov    $0x0,%eax
  801451:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  801458:	00 00 00 
  80145b:	41 ff d1             	callq  *%r9

000000000080145e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80145e:	55                   	push   %rbp
  80145f:	48 89 e5             	mov    %rsp,%rbp
  801462:	53                   	push   %rbx
  801463:	49 89 f0             	mov    %rsi,%r8
  801466:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801469:	48 63 d7             	movslq %edi,%rdx
  80146c:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  80146f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801474:	be 00 00 00 00       	mov    $0x0,%esi
  801479:	4c 89 c1             	mov    %r8,%rcx
  80147c:	cd 30                	int    $0x30
}
  80147e:	5b                   	pop    %rbx
  80147f:	5d                   	pop    %rbp
  801480:	c3                   	retq   

0000000000801481 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801481:	55                   	push   %rbp
  801482:	48 89 e5             	mov    %rsp,%rbp
  801485:	53                   	push   %rbx
  801486:	48 83 ec 08          	sub    $0x8,%rsp
  80148a:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  80148d:	be 00 00 00 00       	mov    $0x0,%esi
  801492:	b8 0c 00 00 00       	mov    $0xc,%eax
  801497:	48 89 f1             	mov    %rsi,%rcx
  80149a:	48 89 f3             	mov    %rsi,%rbx
  80149d:	48 89 f7             	mov    %rsi,%rdi
  8014a0:	cd 30                	int    $0x30
  if (check && ret > 0)
  8014a2:	48 85 c0             	test   %rax,%rax
  8014a5:	7f 07                	jg     8014ae <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8014a7:	48 83 c4 08          	add    $0x8,%rsp
  8014ab:	5b                   	pop    %rbx
  8014ac:	5d                   	pop    %rbp
  8014ad:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8014ae:	49 89 c0             	mov    %rax,%r8
  8014b1:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8014b6:	48 ba 80 1a 80 00 00 	movabs $0x801a80,%rdx
  8014bd:	00 00 00 
  8014c0:	be 22 00 00 00       	mov    $0x22,%esi
  8014c5:	48 bf a0 1a 80 00 00 	movabs $0x801aa0,%rdi
  8014cc:	00 00 00 
  8014cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d4:	49 b9 00 02 80 00 00 	movabs $0x800200,%r9
  8014db:	00 00 00 
  8014de:	41 ff d1             	callq  *%r9

00000000008014e1 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  8014e1:	55                   	push   %rbp
  8014e2:	48 89 e5             	mov    %rsp,%rbp
  8014e5:	41 54                	push   %r12
  8014e7:	53                   	push   %rbx
  8014e8:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  8014eb:	48 b8 34 12 80 00 00 	movabs $0x801234,%rax
  8014f2:	00 00 00 
  8014f5:	ff d0                	callq  *%rax
  8014f7:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  8014f9:	48 b8 10 20 80 00 00 	movabs $0x802010,%rax
  801500:	00 00 00 
  801503:	48 83 38 00          	cmpq   $0x0,(%rax)
  801507:	74 2e                	je     801537 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801509:	4c 89 e0             	mov    %r12,%rax
  80150c:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  801513:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801516:	48 be 83 15 80 00 00 	movabs $0x801583,%rsi
  80151d:	00 00 00 
  801520:	89 df                	mov    %ebx,%edi
  801522:	48 b8 fe 13 80 00 00 	movabs $0x8013fe,%rax
  801529:	00 00 00 
  80152c:	ff d0                	callq  *%rax
  if (error < 0)
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 24                	js     801556 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801532:	5b                   	pop    %rbx
  801533:	41 5c                	pop    %r12
  801535:	5d                   	pop    %rbp
  801536:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  801537:	ba 02 00 00 00       	mov    $0x2,%edx
  80153c:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801543:	00 00 00 
  801546:	89 df                	mov    %ebx,%edi
  801548:	48 b8 74 12 80 00 00 	movabs $0x801274,%rax
  80154f:	00 00 00 
  801552:	ff d0                	callq  *%rax
  801554:	eb b3                	jmp    801509 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801556:	89 c1                	mov    %eax,%ecx
  801558:	48 ba ae 1a 80 00 00 	movabs $0x801aae,%rdx
  80155f:	00 00 00 
  801562:	be 2c 00 00 00       	mov    $0x2c,%esi
  801567:	48 bf c6 1a 80 00 00 	movabs $0x801ac6,%rdi
  80156e:	00 00 00 
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
  801576:	49 b8 00 02 80 00 00 	movabs $0x800200,%r8
  80157d:	00 00 00 
  801580:	41 ff d0             	callq  *%r8

0000000000801583 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801583:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801586:	48 a1 10 20 80 00 00 	movabs 0x802010,%rax
  80158d:	00 00 00 
	call *%rax
  801590:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801592:	41 5f                	pop    %r15
	popq %r15
  801594:	41 5f                	pop    %r15
	popq %r15
  801596:	41 5f                	pop    %r15
	popq %r14
  801598:	41 5e                	pop    %r14
	popq %r13
  80159a:	41 5d                	pop    %r13
	popq %r12
  80159c:	41 5c                	pop    %r12
	popq %r11
  80159e:	41 5b                	pop    %r11
	popq %r10
  8015a0:	41 5a                	pop    %r10
	popq %r9
  8015a2:	41 59                	pop    %r9
	popq %r8
  8015a4:	41 58                	pop    %r8
	popq %rsi
  8015a6:	5e                   	pop    %rsi
	popq %rdi
  8015a7:	5f                   	pop    %rdi
	popq %rbp
  8015a8:	5d                   	pop    %rbp
	popq %rdx
  8015a9:	5a                   	pop    %rdx
	popq %rcx
  8015aa:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  8015ab:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  8015b0:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  8015b5:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  8015b9:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  8015bc:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  8015c1:	5b                   	pop    %rbx
	popq %rax
  8015c2:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  8015c3:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  8015c7:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  8015c8:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  8015cd:	c3                   	retq   
  8015ce:	66 90                	xchg   %ax,%ax
