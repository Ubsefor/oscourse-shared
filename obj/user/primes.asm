
obj/user/primes:     file format elf64-x86-64


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
  800023:	e8 54 01 00 00       	callq  80017c <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <primeproc>:
// of main and user/idle.

#include <inc/lib.h>

unsigned
primeproc(void) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 57                	push   %r15
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	48 83 ec 18          	sub    $0x18,%rsp
  int i, id, p;
  envid_t envid;

  // fetch a prime from our left neighbor
top:
  p = ipc_recv(&envid, 0, 0);
  80003b:	49 bf e9 19 80 00 00 	movabs $0x8019e9,%r15
  800042:	00 00 00 
  cprintf("%d ", p);
  800045:	49 be eb 03 80 00 00 	movabs $0x8003eb,%r14
  80004c:	00 00 00 

  // fork a right neighbor to continue the chain
  if ((id = fork()) < 0)
  80004f:	49 bc ab 16 80 00 00 	movabs $0x8016ab,%r12
  800056:	00 00 00 
  p = ipc_recv(&envid, 0, 0);
  800059:	ba 00 00 00 00       	mov    $0x0,%edx
  80005e:	be 00 00 00 00       	mov    $0x0,%esi
  800063:	48 8d 7d cc          	lea    -0x34(%rbp),%rdi
  800067:	41 ff d7             	callq  *%r15
  80006a:	89 c3                	mov    %eax,%ebx
  cprintf("%d ", p);
  80006c:	89 c6                	mov    %eax,%esi
  80006e:	48 bf 60 1c 80 00 00 	movabs $0x801c60,%rdi
  800075:	00 00 00 
  800078:	b8 00 00 00 00       	mov    $0x0,%eax
  80007d:	41 ff d6             	callq  *%r14
  if ((id = fork()) < 0)
  800080:	41 ff d4             	callq  *%r12
  800083:	41 89 c5             	mov    %eax,%r13d
  800086:	85 c0                	test   %eax,%eax
  800088:	78 18                	js     8000a2 <primeproc+0x78>
    panic("fork: %i", id);
  if (id == 0)
  80008a:	74 cd                	je     800059 <primeproc+0x2f>
    goto top;

  // filter out multiples of our prime
  while (1) {
    i = ipc_recv(&envid, 0, 0);
  80008c:	49 bc e9 19 80 00 00 	movabs $0x8019e9,%r12
  800093:	00 00 00 
    if (i % p)
      ipc_send(id, i, 0, 0);
  800096:	49 be 68 1a 80 00 00 	movabs $0x801a68,%r14
  80009d:	00 00 00 
  8000a0:	eb 3d                	jmp    8000df <primeproc+0xb5>
    panic("fork: %i", id);
  8000a2:	89 c1                	mov    %eax,%ecx
  8000a4:	48 ba 64 1c 80 00 00 	movabs $0x801c64,%rdx
  8000ab:	00 00 00 
  8000ae:	be 19 00 00 00       	mov    $0x19,%esi
  8000b3:	48 bf 6d 1c 80 00 00 	movabs $0x801c6d,%rdi
  8000ba:	00 00 00 
  8000bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c2:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  8000c9:	00 00 00 
  8000cc:	41 ff d0             	callq  *%r8
      ipc_send(id, i, 0, 0);
  8000cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	44 89 ef             	mov    %r13d,%edi
  8000dc:	41 ff d6             	callq  *%r14
    i = ipc_recv(&envid, 0, 0);
  8000df:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e4:	be 00 00 00 00       	mov    $0x0,%esi
  8000e9:	48 8d 7d cc          	lea    -0x34(%rbp),%rdi
  8000ed:	41 ff d4             	callq  *%r12
  8000f0:	89 c6                	mov    %eax,%esi
    if (i % p)
  8000f2:	99                   	cltd   
  8000f3:	f7 fb                	idiv   %ebx
  8000f5:	85 d2                	test   %edx,%edx
  8000f7:	74 e6                	je     8000df <primeproc+0xb5>
  8000f9:	eb d4                	jmp    8000cf <primeproc+0xa5>

00000000008000fb <umain>:
  }
}

void
umain(int argc, char **argv) {
  8000fb:	55                   	push   %rbp
  8000fc:	48 89 e5             	mov    %rsp,%rbp
  8000ff:	41 55                	push   %r13
  800101:	41 54                	push   %r12
  800103:	53                   	push   %rbx
  800104:	48 83 ec 08          	sub    $0x8,%rsp
  int i, id;

  // fork the first prime process in the chain
  if ((id = fork()) < 0)
  800108:	48 b8 ab 16 80 00 00 	movabs $0x8016ab,%rax
  80010f:	00 00 00 
  800112:	ff d0                	callq  *%rax
  800114:	41 89 c4             	mov    %eax,%r12d
  800117:	85 c0                	test   %eax,%eax
  800119:	78 28                	js     800143 <umain+0x48>
    panic("fork: %i", id);
  if (id == 0)
    primeproc();

  // feed all the integers through
  for (i = 2;; i++)
  80011b:	bb 02 00 00 00       	mov    $0x2,%ebx
    ipc_send(id, i, 0, 0);
  800120:	49 bd 68 1a 80 00 00 	movabs $0x801a68,%r13
  800127:	00 00 00 
  if (id == 0)
  80012a:	74 44                	je     800170 <umain+0x75>
    ipc_send(id, i, 0, 0);
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	89 de                	mov    %ebx,%esi
  800138:	44 89 e7             	mov    %r12d,%edi
  80013b:	41 ff d5             	callq  *%r13
  for (i = 2;; i++)
  80013e:	83 c3 01             	add    $0x1,%ebx
  800141:	eb e9                	jmp    80012c <umain+0x31>
    panic("fork: %i", id);
  800143:	89 c1                	mov    %eax,%ecx
  800145:	48 ba 64 1c 80 00 00 	movabs $0x801c64,%rdx
  80014c:	00 00 00 
  80014f:	be 2b 00 00 00       	mov    $0x2b,%esi
  800154:	48 bf 6d 1c 80 00 00 	movabs $0x801c6d,%rdi
  80015b:	00 00 00 
  80015e:	b8 00 00 00 00       	mov    $0x0,%eax
  800163:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  80016a:	00 00 00 
  80016d:	41 ff d0             	callq  *%r8
    primeproc();
  800170:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800177:	00 00 00 
  80017a:	ff d0                	callq  *%rax

000000000080017c <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80017c:	55                   	push   %rbp
  80017d:	48 89 e5             	mov    %rsp,%rbp
  800180:	41 56                	push   %r14
  800182:	41 55                	push   %r13
  800184:	41 54                	push   %r12
  800186:	53                   	push   %rbx
  800187:	41 89 fd             	mov    %edi,%r13d
  80018a:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80018d:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  800194:	00 00 00 
  800197:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  80019e:	00 00 00 
  8001a1:	48 39 c2             	cmp    %rax,%rdx
  8001a4:	73 23                	jae    8001c9 <libmain+0x4d>
  8001a6:	48 89 d3             	mov    %rdx,%rbx
  8001a9:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  8001ad:	48 29 d0             	sub    %rdx,%rax
  8001b0:	48 c1 e8 03          	shr    $0x3,%rax
  8001b4:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8001b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8001be:	ff 13                	callq  *(%rbx)
    ctor++;
  8001c0:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8001c4:	4c 39 e3             	cmp    %r12,%rbx
  8001c7:	75 f0                	jne    8001b9 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8001c9:	48 b8 7d 12 80 00 00 	movabs $0x80127d,%rax
  8001d0:	00 00 00 
  8001d3:	ff d0                	callq  *%rax
  8001d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001da:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8001de:	48 c1 e0 05          	shl    $0x5,%rax
  8001e2:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8001e9:	00 00 00 
  8001ec:	48 01 d0             	add    %rdx,%rax
  8001ef:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  8001f6:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8001f9:	45 85 ed             	test   %r13d,%r13d
  8001fc:	7e 0d                	jle    80020b <libmain+0x8f>
    binaryname = argv[0];
  8001fe:	49 8b 06             	mov    (%r14),%rax
  800201:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  800208:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80020b:	4c 89 f6             	mov    %r14,%rsi
  80020e:	44 89 ef             	mov    %r13d,%edi
  800211:	48 b8 fb 00 80 00 00 	movabs $0x8000fb,%rax
  800218:	00 00 00 
  80021b:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80021d:	48 b8 32 02 80 00 00 	movabs $0x800232,%rax
  800224:	00 00 00 
  800227:	ff d0                	callq  *%rax
#endif
}
  800229:	5b                   	pop    %rbx
  80022a:	41 5c                	pop    %r12
  80022c:	41 5d                	pop    %r13
  80022e:	41 5e                	pop    %r14
  800230:	5d                   	pop    %rbp
  800231:	c3                   	retq   

0000000000800232 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800232:	55                   	push   %rbp
  800233:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800236:	bf 00 00 00 00       	mov    $0x0,%edi
  80023b:	48 b8 1d 12 80 00 00 	movabs $0x80121d,%rax
  800242:	00 00 00 
  800245:	ff d0                	callq  *%rax
}
  800247:	5d                   	pop    %rbp
  800248:	c3                   	retq   

0000000000800249 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800249:	55                   	push   %rbp
  80024a:	48 89 e5             	mov    %rsp,%rbp
  80024d:	41 56                	push   %r14
  80024f:	41 55                	push   %r13
  800251:	41 54                	push   %r12
  800253:	53                   	push   %rbx
  800254:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80025b:	49 89 fd             	mov    %rdi,%r13
  80025e:	41 89 f6             	mov    %esi,%r14d
  800261:	49 89 d4             	mov    %rdx,%r12
  800264:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80026b:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800272:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800279:	84 c0                	test   %al,%al
  80027b:	74 26                	je     8002a3 <_panic+0x5a>
  80027d:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800284:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80028b:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80028f:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800293:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800297:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80029b:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80029f:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8002a3:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8002aa:	00 00 00 
  8002ad:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8002b4:	00 00 00 
  8002b7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002bb:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8002c2:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8002c9:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d0:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  8002d7:	00 00 00 
  8002da:	48 8b 18             	mov    (%rax),%rbx
  8002dd:	48 b8 7d 12 80 00 00 	movabs $0x80127d,%rax
  8002e4:	00 00 00 
  8002e7:	ff d0                	callq  *%rax
  8002e9:	45 89 f0             	mov    %r14d,%r8d
  8002ec:	4c 89 e9             	mov    %r13,%rcx
  8002ef:	48 89 da             	mov    %rbx,%rdx
  8002f2:	89 c6                	mov    %eax,%esi
  8002f4:	48 bf 88 1c 80 00 00 	movabs $0x801c88,%rdi
  8002fb:	00 00 00 
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	48 bb eb 03 80 00 00 	movabs $0x8003eb,%rbx
  80030a:	00 00 00 
  80030d:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80030f:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800316:	4c 89 e7             	mov    %r12,%rdi
  800319:	48 b8 83 03 80 00 00 	movabs $0x800383,%rax
  800320:	00 00 00 
  800323:	ff d0                	callq  *%rax
  cprintf("\n");
  800325:	48 bf 05 22 80 00 00 	movabs $0x802205,%rdi
  80032c:	00 00 00 
  80032f:	b8 00 00 00 00       	mov    $0x0,%eax
  800334:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800336:	cc                   	int3   
  while (1)
  800337:	eb fd                	jmp    800336 <_panic+0xed>

0000000000800339 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800339:	55                   	push   %rbp
  80033a:	48 89 e5             	mov    %rsp,%rbp
  80033d:	53                   	push   %rbx
  80033e:	48 83 ec 08          	sub    $0x8,%rsp
  800342:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800345:	8b 06                	mov    (%rsi),%eax
  800347:	8d 50 01             	lea    0x1(%rax),%edx
  80034a:	89 16                	mov    %edx,(%rsi)
  80034c:	48 98                	cltq   
  80034e:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800353:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800359:	74 0b                	je     800366 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80035b:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80035f:	48 83 c4 08          	add    $0x8,%rsp
  800363:	5b                   	pop    %rbx
  800364:	5d                   	pop    %rbp
  800365:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800366:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80036a:	be ff 00 00 00       	mov    $0xff,%esi
  80036f:	48 b8 df 11 80 00 00 	movabs $0x8011df,%rax
  800376:	00 00 00 
  800379:	ff d0                	callq  *%rax
    b->idx = 0;
  80037b:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800381:	eb d8                	jmp    80035b <putch+0x22>

0000000000800383 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800383:	55                   	push   %rbp
  800384:	48 89 e5             	mov    %rsp,%rbp
  800387:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80038e:	48 89 fa             	mov    %rdi,%rdx
  800391:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800394:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80039b:	00 00 00 
  b.cnt = 0;
  80039e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8003a5:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8003a8:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8003af:	48 bf 39 03 80 00 00 	movabs $0x800339,%rdi
  8003b6:	00 00 00 
  8003b9:	48 b8 a9 05 80 00 00 	movabs $0x8005a9,%rax
  8003c0:	00 00 00 
  8003c3:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8003c5:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8003cc:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8003d3:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8003d7:	48 b8 df 11 80 00 00 	movabs $0x8011df,%rax
  8003de:	00 00 00 
  8003e1:	ff d0                	callq  *%rax

  return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8003e9:	c9                   	leaveq 
  8003ea:	c3                   	retq   

00000000008003eb <cprintf>:

int
cprintf(const char *fmt, ...) {
  8003eb:	55                   	push   %rbp
  8003ec:	48 89 e5             	mov    %rsp,%rbp
  8003ef:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003f6:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8003fd:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800404:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80040b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800412:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800419:	84 c0                	test   %al,%al
  80041b:	74 20                	je     80043d <cprintf+0x52>
  80041d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800421:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800425:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800429:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80042d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800431:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800435:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800439:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80043d:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800444:	00 00 00 
  800447:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80044e:	00 00 00 
  800451:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800455:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80045c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800463:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80046a:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800471:	48 b8 83 03 80 00 00 	movabs $0x800383,%rax
  800478:	00 00 00 
  80047b:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80047d:	c9                   	leaveq 
  80047e:	c3                   	retq   

000000000080047f <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80047f:	55                   	push   %rbp
  800480:	48 89 e5             	mov    %rsp,%rbp
  800483:	41 57                	push   %r15
  800485:	41 56                	push   %r14
  800487:	41 55                	push   %r13
  800489:	41 54                	push   %r12
  80048b:	53                   	push   %rbx
  80048c:	48 83 ec 18          	sub    $0x18,%rsp
  800490:	49 89 fc             	mov    %rdi,%r12
  800493:	49 89 f5             	mov    %rsi,%r13
  800496:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80049a:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80049d:	41 89 cf             	mov    %ecx,%r15d
  8004a0:	49 39 d7             	cmp    %rdx,%r15
  8004a3:	76 45                	jbe    8004ea <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8004a5:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	7e 0e                	jle    8004bb <printnum+0x3c>
      putch(padc, putdat);
  8004ad:	4c 89 ee             	mov    %r13,%rsi
  8004b0:	44 89 f7             	mov    %r14d,%edi
  8004b3:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8004b6:	83 eb 01             	sub    $0x1,%ebx
  8004b9:	75 f2                	jne    8004ad <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8004bb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c4:	49 f7 f7             	div    %r15
  8004c7:	48 b8 ab 1c 80 00 00 	movabs $0x801cab,%rax
  8004ce:	00 00 00 
  8004d1:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8004d5:	4c 89 ee             	mov    %r13,%rsi
  8004d8:	41 ff d4             	callq  *%r12
}
  8004db:	48 83 c4 18          	add    $0x18,%rsp
  8004df:	5b                   	pop    %rbx
  8004e0:	41 5c                	pop    %r12
  8004e2:	41 5d                	pop    %r13
  8004e4:	41 5e                	pop    %r14
  8004e6:	41 5f                	pop    %r15
  8004e8:	5d                   	pop    %rbp
  8004e9:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ea:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f3:	49 f7 f7             	div    %r15
  8004f6:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8004fa:	48 89 c2             	mov    %rax,%rdx
  8004fd:	48 b8 7f 04 80 00 00 	movabs $0x80047f,%rax
  800504:	00 00 00 
  800507:	ff d0                	callq  *%rax
  800509:	eb b0                	jmp    8004bb <printnum+0x3c>

000000000080050b <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80050b:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80050f:	48 8b 06             	mov    (%rsi),%rax
  800512:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800516:	73 0a                	jae    800522 <sprintputch+0x17>
    *b->buf++ = ch;
  800518:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80051c:	48 89 16             	mov    %rdx,(%rsi)
  80051f:	40 88 38             	mov    %dil,(%rax)
}
  800522:	c3                   	retq   

0000000000800523 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800523:	55                   	push   %rbp
  800524:	48 89 e5             	mov    %rsp,%rbp
  800527:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80052e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800535:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80053c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800543:	84 c0                	test   %al,%al
  800545:	74 20                	je     800567 <printfmt+0x44>
  800547:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80054b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80054f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800553:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800557:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80055b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80055f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800563:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800567:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80056e:	00 00 00 
  800571:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800578:	00 00 00 
  80057b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80057f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800586:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80058d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800594:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80059b:	48 b8 a9 05 80 00 00 	movabs $0x8005a9,%rax
  8005a2:	00 00 00 
  8005a5:	ff d0                	callq  *%rax
}
  8005a7:	c9                   	leaveq 
  8005a8:	c3                   	retq   

00000000008005a9 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8005a9:	55                   	push   %rbp
  8005aa:	48 89 e5             	mov    %rsp,%rbp
  8005ad:	41 57                	push   %r15
  8005af:	41 56                	push   %r14
  8005b1:	41 55                	push   %r13
  8005b3:	41 54                	push   %r12
  8005b5:	53                   	push   %rbx
  8005b6:	48 83 ec 48          	sub    $0x48,%rsp
  8005ba:	49 89 fd             	mov    %rdi,%r13
  8005bd:	49 89 f7             	mov    %rsi,%r15
  8005c0:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8005c3:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8005c7:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8005cb:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8005cf:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005d3:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8005d7:	41 0f b6 3e          	movzbl (%r14),%edi
  8005db:	83 ff 25             	cmp    $0x25,%edi
  8005de:	74 18                	je     8005f8 <vprintfmt+0x4f>
      if (ch == '\0')
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	0f 84 8c 06 00 00    	je     800c74 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8005e8:	4c 89 fe             	mov    %r15,%rsi
  8005eb:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005ee:	49 89 de             	mov    %rbx,%r14
  8005f1:	eb e0                	jmp    8005d3 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8005f3:	49 89 de             	mov    %rbx,%r14
  8005f6:	eb db                	jmp    8005d3 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8005f8:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8005fc:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800600:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800607:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80060d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800616:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80061c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800622:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800627:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80062c:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800630:	0f b6 13             	movzbl (%rbx),%edx
  800633:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800636:	3c 55                	cmp    $0x55,%al
  800638:	0f 87 8b 05 00 00    	ja     800bc9 <vprintfmt+0x620>
  80063e:	0f b6 c0             	movzbl %al,%eax
  800641:	49 bb 80 1d 80 00 00 	movabs $0x801d80,%r11
  800648:	00 00 00 
  80064b:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80064f:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800652:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800656:	eb d4                	jmp    80062c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800658:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80065b:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80065f:	eb cb                	jmp    80062c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800661:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800664:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800668:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80066c:	8d 50 d0             	lea    -0x30(%rax),%edx
  80066f:	83 fa 09             	cmp    $0x9,%edx
  800672:	77 7e                	ja     8006f2 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800674:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800678:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80067c:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800681:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800685:	8d 50 d0             	lea    -0x30(%rax),%edx
  800688:	83 fa 09             	cmp    $0x9,%edx
  80068b:	76 e7                	jbe    800674 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80068d:	4c 89 f3             	mov    %r14,%rbx
  800690:	eb 19                	jmp    8006ab <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800692:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800695:	83 f8 2f             	cmp    $0x2f,%eax
  800698:	77 2a                	ja     8006c4 <vprintfmt+0x11b>
  80069a:	89 c2                	mov    %eax,%edx
  80069c:	4c 01 d2             	add    %r10,%rdx
  80069f:	83 c0 08             	add    $0x8,%eax
  8006a2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006a5:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8006a8:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8006ab:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006af:	0f 89 77 ff ff ff    	jns    80062c <vprintfmt+0x83>
          width = precision, precision = -1;
  8006b5:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8006b9:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8006bf:	e9 68 ff ff ff       	jmpq   80062c <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8006c4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006c8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006cc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006d0:	eb d3                	jmp    8006a5 <vprintfmt+0xfc>
        if (width < 0)
  8006d2:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	41 0f 48 c0          	cmovs  %r8d,%eax
  8006db:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8006de:	4c 89 f3             	mov    %r14,%rbx
  8006e1:	e9 46 ff ff ff       	jmpq   80062c <vprintfmt+0x83>
  8006e6:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8006e9:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8006ed:	e9 3a ff ff ff       	jmpq   80062c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8006f2:	4c 89 f3             	mov    %r14,%rbx
  8006f5:	eb b4                	jmp    8006ab <vprintfmt+0x102>
        lflag++;
  8006f7:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8006fa:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8006fd:	e9 2a ff ff ff       	jmpq   80062c <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800702:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800705:	83 f8 2f             	cmp    $0x2f,%eax
  800708:	77 19                	ja     800723 <vprintfmt+0x17a>
  80070a:	89 c2                	mov    %eax,%edx
  80070c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800710:	83 c0 08             	add    $0x8,%eax
  800713:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800716:	4c 89 fe             	mov    %r15,%rsi
  800719:	8b 3a                	mov    (%rdx),%edi
  80071b:	41 ff d5             	callq  *%r13
        break;
  80071e:	e9 b0 fe ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800723:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800727:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80072b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80072f:	eb e5                	jmp    800716 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800731:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800734:	83 f8 2f             	cmp    $0x2f,%eax
  800737:	77 5b                	ja     800794 <vprintfmt+0x1eb>
  800739:	89 c2                	mov    %eax,%edx
  80073b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80073f:	83 c0 08             	add    $0x8,%eax
  800742:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800745:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800747:	89 c8                	mov    %ecx,%eax
  800749:	c1 f8 1f             	sar    $0x1f,%eax
  80074c:	31 c1                	xor    %eax,%ecx
  80074e:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800750:	83 f9 0b             	cmp    $0xb,%ecx
  800753:	7f 4d                	jg     8007a2 <vprintfmt+0x1f9>
  800755:	48 63 c1             	movslq %ecx,%rax
  800758:	48 ba 40 20 80 00 00 	movabs $0x802040,%rdx
  80075f:	00 00 00 
  800762:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800766:	48 85 c0             	test   %rax,%rax
  800769:	74 37                	je     8007a2 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80076b:	48 89 c1             	mov    %rax,%rcx
  80076e:	48 ba cc 1c 80 00 00 	movabs $0x801ccc,%rdx
  800775:	00 00 00 
  800778:	4c 89 fe             	mov    %r15,%rsi
  80077b:	4c 89 ef             	mov    %r13,%rdi
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	48 bb 23 05 80 00 00 	movabs $0x800523,%rbx
  80078a:	00 00 00 
  80078d:	ff d3                	callq  *%rbx
  80078f:	e9 3f fe ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800794:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800798:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80079c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007a0:	eb a3                	jmp    800745 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8007a2:	48 ba c3 1c 80 00 00 	movabs $0x801cc3,%rdx
  8007a9:	00 00 00 
  8007ac:	4c 89 fe             	mov    %r15,%rsi
  8007af:	4c 89 ef             	mov    %r13,%rdi
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	48 bb 23 05 80 00 00 	movabs $0x800523,%rbx
  8007be:	00 00 00 
  8007c1:	ff d3                	callq  *%rbx
  8007c3:	e9 0b fe ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8007c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007cb:	83 f8 2f             	cmp    $0x2f,%eax
  8007ce:	77 4b                	ja     80081b <vprintfmt+0x272>
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007d6:	83 c0 08             	add    $0x8,%eax
  8007d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007dc:	48 8b 02             	mov    (%rdx),%rax
  8007df:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8007e3:	48 85 c0             	test   %rax,%rax
  8007e6:	0f 84 05 04 00 00    	je     800bf1 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8007ec:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8007f0:	7e 06                	jle    8007f8 <vprintfmt+0x24f>
  8007f2:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8007f6:	75 31                	jne    800829 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007fc:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800800:	0f b6 00             	movzbl (%rax),%eax
  800803:	0f be f8             	movsbl %al,%edi
  800806:	85 ff                	test   %edi,%edi
  800808:	0f 84 c3 00 00 00    	je     8008d1 <vprintfmt+0x328>
  80080e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800812:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800816:	e9 85 00 00 00       	jmpq   8008a0 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80081b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80081f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800823:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800827:	eb b3                	jmp    8007dc <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800829:	49 63 f4             	movslq %r12d,%rsi
  80082c:	48 89 c7             	mov    %rax,%rdi
  80082f:	48 b8 80 0d 80 00 00 	movabs $0x800d80,%rax
  800836:	00 00 00 
  800839:	ff d0                	callq  *%rax
  80083b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80083e:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800841:	85 f6                	test   %esi,%esi
  800843:	7e 22                	jle    800867 <vprintfmt+0x2be>
            putch(padc, putdat);
  800845:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800849:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80084d:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800851:	4c 89 fe             	mov    %r15,%rsi
  800854:	89 df                	mov    %ebx,%edi
  800856:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800859:	41 83 ec 01          	sub    $0x1,%r12d
  80085d:	75 f2                	jne    800851 <vprintfmt+0x2a8>
  80085f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800863:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800867:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80086b:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80086f:	0f b6 00             	movzbl (%rax),%eax
  800872:	0f be f8             	movsbl %al,%edi
  800875:	85 ff                	test   %edi,%edi
  800877:	0f 84 56 fd ff ff    	je     8005d3 <vprintfmt+0x2a>
  80087d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800881:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800885:	eb 19                	jmp    8008a0 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800887:	4c 89 fe             	mov    %r15,%rsi
  80088a:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088d:	41 83 ee 01          	sub    $0x1,%r14d
  800891:	48 83 c3 01          	add    $0x1,%rbx
  800895:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800899:	0f be f8             	movsbl %al,%edi
  80089c:	85 ff                	test   %edi,%edi
  80089e:	74 29                	je     8008c9 <vprintfmt+0x320>
  8008a0:	45 85 e4             	test   %r12d,%r12d
  8008a3:	78 06                	js     8008ab <vprintfmt+0x302>
  8008a5:	41 83 ec 01          	sub    $0x1,%r12d
  8008a9:	78 48                	js     8008f3 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8008ab:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8008af:	74 d6                	je     800887 <vprintfmt+0x2de>
  8008b1:	0f be c0             	movsbl %al,%eax
  8008b4:	83 e8 20             	sub    $0x20,%eax
  8008b7:	83 f8 5e             	cmp    $0x5e,%eax
  8008ba:	76 cb                	jbe    800887 <vprintfmt+0x2de>
            putch('?', putdat);
  8008bc:	4c 89 fe             	mov    %r15,%rsi
  8008bf:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8008c4:	41 ff d5             	callq  *%r13
  8008c7:	eb c4                	jmp    80088d <vprintfmt+0x2e4>
  8008c9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008cd:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8008d1:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8008d4:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008d8:	0f 8e f5 fc ff ff    	jle    8005d3 <vprintfmt+0x2a>
          putch(' ', putdat);
  8008de:	4c 89 fe             	mov    %r15,%rsi
  8008e1:	bf 20 00 00 00       	mov    $0x20,%edi
  8008e6:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8008e9:	83 eb 01             	sub    $0x1,%ebx
  8008ec:	75 f0                	jne    8008de <vprintfmt+0x335>
  8008ee:	e9 e0 fc ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
  8008f3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008f7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8008fb:	eb d4                	jmp    8008d1 <vprintfmt+0x328>
  if (lflag >= 2)
  8008fd:	83 f9 01             	cmp    $0x1,%ecx
  800900:	7f 1d                	jg     80091f <vprintfmt+0x376>
  else if (lflag)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 5e                	je     800964 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800906:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800909:	83 f8 2f             	cmp    $0x2f,%eax
  80090c:	77 48                	ja     800956 <vprintfmt+0x3ad>
  80090e:	89 c2                	mov    %eax,%edx
  800910:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800914:	83 c0 08             	add    $0x8,%eax
  800917:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80091a:	48 8b 1a             	mov    (%rdx),%rbx
  80091d:	eb 17                	jmp    800936 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80091f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800922:	83 f8 2f             	cmp    $0x2f,%eax
  800925:	77 21                	ja     800948 <vprintfmt+0x39f>
  800927:	89 c2                	mov    %eax,%edx
  800929:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092d:	83 c0 08             	add    $0x8,%eax
  800930:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800933:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800936:	48 85 db             	test   %rbx,%rbx
  800939:	78 50                	js     80098b <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80093b:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80093e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800943:	e9 b4 01 00 00       	jmpq   800afc <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800948:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800950:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800954:	eb dd                	jmp    800933 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800956:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80095e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800962:	eb b6                	jmp    80091a <vprintfmt+0x371>
    return va_arg(*ap, int);
  800964:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800967:	83 f8 2f             	cmp    $0x2f,%eax
  80096a:	77 11                	ja     80097d <vprintfmt+0x3d4>
  80096c:	89 c2                	mov    %eax,%edx
  80096e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800972:	83 c0 08             	add    $0x8,%eax
  800975:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800978:	48 63 1a             	movslq (%rdx),%rbx
  80097b:	eb b9                	jmp    800936 <vprintfmt+0x38d>
  80097d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800981:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800985:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800989:	eb ed                	jmp    800978 <vprintfmt+0x3cf>
          putch('-', putdat);
  80098b:	4c 89 fe             	mov    %r15,%rsi
  80098e:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800993:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800996:	48 89 da             	mov    %rbx,%rdx
  800999:	48 f7 da             	neg    %rdx
        base = 10;
  80099c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009a1:	e9 56 01 00 00       	jmpq   800afc <vprintfmt+0x553>
  if (lflag >= 2)
  8009a6:	83 f9 01             	cmp    $0x1,%ecx
  8009a9:	7f 25                	jg     8009d0 <vprintfmt+0x427>
  else if (lflag)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 5e                	je     800a0d <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8009af:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b2:	83 f8 2f             	cmp    $0x2f,%eax
  8009b5:	77 48                	ja     8009ff <vprintfmt+0x456>
  8009b7:	89 c2                	mov    %eax,%edx
  8009b9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009bd:	83 c0 08             	add    $0x8,%eax
  8009c0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009c3:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009cb:	e9 2c 01 00 00       	jmpq   800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009d0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d3:	83 f8 2f             	cmp    $0x2f,%eax
  8009d6:	77 19                	ja     8009f1 <vprintfmt+0x448>
  8009d8:	89 c2                	mov    %eax,%edx
  8009da:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009de:	83 c0 08             	add    $0x8,%eax
  8009e1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e4:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ec:	e9 0b 01 00 00       	jmpq   800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009f9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009fd:	eb e5                	jmp    8009e4 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8009ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a03:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a0b:	eb b6                	jmp    8009c3 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800a0d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a10:	83 f8 2f             	cmp    $0x2f,%eax
  800a13:	77 18                	ja     800a2d <vprintfmt+0x484>
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a1b:	83 c0 08             	add    $0x8,%eax
  800a1e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a21:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800a23:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a28:	e9 cf 00 00 00       	jmpq   800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a2d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a31:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a35:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a39:	eb e6                	jmp    800a21 <vprintfmt+0x478>
  if (lflag >= 2)
  800a3b:	83 f9 01             	cmp    $0x1,%ecx
  800a3e:	7f 25                	jg     800a65 <vprintfmt+0x4bc>
  else if (lflag)
  800a40:	85 c9                	test   %ecx,%ecx
  800a42:	74 5b                	je     800a9f <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800a44:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a47:	83 f8 2f             	cmp    $0x2f,%eax
  800a4a:	77 45                	ja     800a91 <vprintfmt+0x4e8>
  800a4c:	89 c2                	mov    %eax,%edx
  800a4e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a52:	83 c0 08             	add    $0x8,%eax
  800a55:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a58:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a5b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a60:	e9 97 00 00 00       	jmpq   800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a65:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a68:	83 f8 2f             	cmp    $0x2f,%eax
  800a6b:	77 16                	ja     800a83 <vprintfmt+0x4da>
  800a6d:	89 c2                	mov    %eax,%edx
  800a6f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a73:	83 c0 08             	add    $0x8,%eax
  800a76:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a79:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a7c:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a81:	eb 79                	jmp    800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a83:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a87:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a8b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a8f:	eb e8                	jmp    800a79 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a91:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a95:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a99:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a9d:	eb b9                	jmp    800a58 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a9f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aa2:	83 f8 2f             	cmp    $0x2f,%eax
  800aa5:	77 15                	ja     800abc <vprintfmt+0x513>
  800aa7:	89 c2                	mov    %eax,%edx
  800aa9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aad:	83 c0 08             	add    $0x8,%eax
  800ab0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ab3:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800ab5:	b9 08 00 00 00       	mov    $0x8,%ecx
  800aba:	eb 40                	jmp    800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800abc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ac0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ac4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ac8:	eb e9                	jmp    800ab3 <vprintfmt+0x50a>
        putch('0', putdat);
  800aca:	4c 89 fe             	mov    %r15,%rsi
  800acd:	bf 30 00 00 00       	mov    $0x30,%edi
  800ad2:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800ad5:	4c 89 fe             	mov    %r15,%rsi
  800ad8:	bf 78 00 00 00       	mov    $0x78,%edi
  800add:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ae0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae3:	83 f8 2f             	cmp    $0x2f,%eax
  800ae6:	77 34                	ja     800b1c <vprintfmt+0x573>
  800ae8:	89 c2                	mov    %eax,%edx
  800aea:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aee:	83 c0 08             	add    $0x8,%eax
  800af1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800af7:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800afc:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800b01:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800b05:	4c 89 fe             	mov    %r15,%rsi
  800b08:	4c 89 ef             	mov    %r13,%rdi
  800b0b:	48 b8 7f 04 80 00 00 	movabs $0x80047f,%rax
  800b12:	00 00 00 
  800b15:	ff d0                	callq  *%rax
        break;
  800b17:	e9 b7 fa ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800b1c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b20:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b24:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b28:	eb ca                	jmp    800af4 <vprintfmt+0x54b>
  if (lflag >= 2)
  800b2a:	83 f9 01             	cmp    $0x1,%ecx
  800b2d:	7f 22                	jg     800b51 <vprintfmt+0x5a8>
  else if (lflag)
  800b2f:	85 c9                	test   %ecx,%ecx
  800b31:	74 58                	je     800b8b <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800b33:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b36:	83 f8 2f             	cmp    $0x2f,%eax
  800b39:	77 42                	ja     800b7d <vprintfmt+0x5d4>
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b41:	83 c0 08             	add    $0x8,%eax
  800b44:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b47:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b4a:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b4f:	eb ab                	jmp    800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b51:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b54:	83 f8 2f             	cmp    $0x2f,%eax
  800b57:	77 16                	ja     800b6f <vprintfmt+0x5c6>
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b5f:	83 c0 08             	add    $0x8,%eax
  800b62:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b65:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b68:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b6d:	eb 8d                	jmp    800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b6f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b73:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b77:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b7b:	eb e8                	jmp    800b65 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b7d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b81:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b85:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b89:	eb bc                	jmp    800b47 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b8b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b8e:	83 f8 2f             	cmp    $0x2f,%eax
  800b91:	77 18                	ja     800bab <vprintfmt+0x602>
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b99:	83 c0 08             	add    $0x8,%eax
  800b9c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b9f:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800ba1:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ba6:	e9 51 ff ff ff       	jmpq   800afc <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800bab:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800baf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bb3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bb7:	eb e6                	jmp    800b9f <vprintfmt+0x5f6>
        putch(ch, putdat);
  800bb9:	4c 89 fe             	mov    %r15,%rsi
  800bbc:	bf 25 00 00 00       	mov    $0x25,%edi
  800bc1:	41 ff d5             	callq  *%r13
        break;
  800bc4:	e9 0a fa ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
        putch('%', putdat);
  800bc9:	4c 89 fe             	mov    %r15,%rsi
  800bcc:	bf 25 00 00 00       	mov    $0x25,%edi
  800bd1:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800bd4:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800bd8:	0f 84 15 fa ff ff    	je     8005f3 <vprintfmt+0x4a>
  800bde:	49 89 de             	mov    %rbx,%r14
  800be1:	49 83 ee 01          	sub    $0x1,%r14
  800be5:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800bea:	75 f5                	jne    800be1 <vprintfmt+0x638>
  800bec:	e9 e2 f9 ff ff       	jmpq   8005d3 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800bf1:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800bf5:	74 06                	je     800bfd <vprintfmt+0x654>
  800bf7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800bfb:	7f 21                	jg     800c1e <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bfd:	bf 28 00 00 00       	mov    $0x28,%edi
  800c02:	48 bb bd 1c 80 00 00 	movabs $0x801cbd,%rbx
  800c09:	00 00 00 
  800c0c:	b8 28 00 00 00       	mov    $0x28,%eax
  800c11:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c15:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c19:	e9 82 fc ff ff       	jmpq   8008a0 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800c1e:	49 63 f4             	movslq %r12d,%rsi
  800c21:	48 bf bc 1c 80 00 00 	movabs $0x801cbc,%rdi
  800c28:	00 00 00 
  800c2b:	48 b8 80 0d 80 00 00 	movabs $0x800d80,%rax
  800c32:	00 00 00 
  800c35:	ff d0                	callq  *%rax
  800c37:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800c3a:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800c3d:	48 be bc 1c 80 00 00 	movabs $0x801cbc,%rsi
  800c44:	00 00 00 
  800c47:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	0f 8f f2 fb ff ff    	jg     800845 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c53:	48 bb bd 1c 80 00 00 	movabs $0x801cbd,%rbx
  800c5a:	00 00 00 
  800c5d:	b8 28 00 00 00       	mov    $0x28,%eax
  800c62:	bf 28 00 00 00       	mov    $0x28,%edi
  800c67:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c6b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c6f:	e9 2c fc ff ff       	jmpq   8008a0 <vprintfmt+0x2f7>
}
  800c74:	48 83 c4 48          	add    $0x48,%rsp
  800c78:	5b                   	pop    %rbx
  800c79:	41 5c                	pop    %r12
  800c7b:	41 5d                	pop    %r13
  800c7d:	41 5e                	pop    %r14
  800c7f:	41 5f                	pop    %r15
  800c81:	5d                   	pop    %rbp
  800c82:	c3                   	retq   

0000000000800c83 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c83:	55                   	push   %rbp
  800c84:	48 89 e5             	mov    %rsp,%rbp
  800c87:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c8b:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c8f:	48 63 c6             	movslq %esi,%rax
  800c92:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c97:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ca2:	48 85 ff             	test   %rdi,%rdi
  800ca5:	74 2a                	je     800cd1 <vsnprintf+0x4e>
  800ca7:	85 f6                	test   %esi,%esi
  800ca9:	7e 26                	jle    800cd1 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800cab:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800caf:	48 bf 0b 05 80 00 00 	movabs $0x80050b,%rdi
  800cb6:	00 00 00 
  800cb9:	48 b8 a9 05 80 00 00 	movabs $0x8005a9,%rax
  800cc0:	00 00 00 
  800cc3:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800cc5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800cc9:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ccc:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ccf:	c9                   	leaveq 
  800cd0:	c3                   	retq   
    return -E_INVAL;
  800cd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cd6:	eb f7                	jmp    800ccf <vsnprintf+0x4c>

0000000000800cd8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800cd8:	55                   	push   %rbp
  800cd9:	48 89 e5             	mov    %rsp,%rbp
  800cdc:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ce3:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800cea:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800cf1:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800cf8:	84 c0                	test   %al,%al
  800cfa:	74 20                	je     800d1c <snprintf+0x44>
  800cfc:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800d00:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800d04:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800d08:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800d0c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800d10:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800d14:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800d18:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800d1c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800d23:	00 00 00 
  800d26:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800d2d:	00 00 00 
  800d30:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800d34:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800d3b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800d42:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800d49:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800d50:	48 b8 83 0c 80 00 00 	movabs $0x800c83,%rax
  800d57:	00 00 00 
  800d5a:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800d5c:	c9                   	leaveq 
  800d5d:	c3                   	retq   

0000000000800d5e <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800d5e:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d61:	74 17                	je     800d7a <strlen+0x1c>
  800d63:	48 89 fa             	mov    %rdi,%rdx
  800d66:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d6b:	29 f9                	sub    %edi,%ecx
    n++;
  800d6d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d70:	48 83 c2 01          	add    $0x1,%rdx
  800d74:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d77:	75 f4                	jne    800d6d <strlen+0xf>
  800d79:	c3                   	retq   
  800d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d7f:	c3                   	retq   

0000000000800d80 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d80:	48 85 f6             	test   %rsi,%rsi
  800d83:	74 24                	je     800da9 <strnlen+0x29>
  800d85:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d88:	74 25                	je     800daf <strnlen+0x2f>
  800d8a:	48 01 fe             	add    %rdi,%rsi
  800d8d:	48 89 fa             	mov    %rdi,%rdx
  800d90:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d95:	29 f9                	sub    %edi,%ecx
    n++;
  800d97:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d9a:	48 83 c2 01          	add    $0x1,%rdx
  800d9e:	48 39 f2             	cmp    %rsi,%rdx
  800da1:	74 11                	je     800db4 <strnlen+0x34>
  800da3:	80 3a 00             	cmpb   $0x0,(%rdx)
  800da6:	75 ef                	jne    800d97 <strnlen+0x17>
  800da8:	c3                   	retq   
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dae:	c3                   	retq   
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800db4:	c3                   	retq   

0000000000800db5 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800db5:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800db8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbd:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800dc1:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800dc4:	48 83 c2 01          	add    $0x1,%rdx
  800dc8:	84 c9                	test   %cl,%cl
  800dca:	75 f1                	jne    800dbd <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800dcc:	c3                   	retq   

0000000000800dcd <strcat>:

char *
strcat(char *dst, const char *src) {
  800dcd:	55                   	push   %rbp
  800dce:	48 89 e5             	mov    %rsp,%rbp
  800dd1:	41 54                	push   %r12
  800dd3:	53                   	push   %rbx
  800dd4:	48 89 fb             	mov    %rdi,%rbx
  800dd7:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800dda:	48 b8 5e 0d 80 00 00 	movabs $0x800d5e,%rax
  800de1:	00 00 00 
  800de4:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800de6:	48 63 f8             	movslq %eax,%rdi
  800de9:	48 01 df             	add    %rbx,%rdi
  800dec:	4c 89 e6             	mov    %r12,%rsi
  800def:	48 b8 b5 0d 80 00 00 	movabs $0x800db5,%rax
  800df6:	00 00 00 
  800df9:	ff d0                	callq  *%rax
  return dst;
}
  800dfb:	48 89 d8             	mov    %rbx,%rax
  800dfe:	5b                   	pop    %rbx
  800dff:	41 5c                	pop    %r12
  800e01:	5d                   	pop    %rbp
  800e02:	c3                   	retq   

0000000000800e03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e03:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800e06:	48 85 d2             	test   %rdx,%rdx
  800e09:	74 1f                	je     800e2a <strncpy+0x27>
  800e0b:	48 01 fa             	add    %rdi,%rdx
  800e0e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800e11:	48 83 c1 01          	add    $0x1,%rcx
  800e15:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e19:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800e1d:	41 80 f8 01          	cmp    $0x1,%r8b
  800e21:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800e25:	48 39 ca             	cmp    %rcx,%rdx
  800e28:	75 e7                	jne    800e11 <strncpy+0xe>
  }
  return ret;
}
  800e2a:	c3                   	retq   

0000000000800e2b <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800e2b:	48 89 f8             	mov    %rdi,%rax
  800e2e:	48 85 d2             	test   %rdx,%rdx
  800e31:	74 36                	je     800e69 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800e33:	48 83 fa 01          	cmp    $0x1,%rdx
  800e37:	74 2d                	je     800e66 <strlcpy+0x3b>
  800e39:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e3d:	45 84 c0             	test   %r8b,%r8b
  800e40:	74 24                	je     800e66 <strlcpy+0x3b>
  800e42:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800e46:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800e4b:	48 83 c0 01          	add    $0x1,%rax
  800e4f:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800e53:	48 39 d1             	cmp    %rdx,%rcx
  800e56:	74 0e                	je     800e66 <strlcpy+0x3b>
  800e58:	48 83 c1 01          	add    $0x1,%rcx
  800e5c:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800e61:	45 84 c0             	test   %r8b,%r8b
  800e64:	75 e5                	jne    800e4b <strlcpy+0x20>
    *dst = '\0';
  800e66:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800e69:	48 29 f8             	sub    %rdi,%rax
}
  800e6c:	c3                   	retq   

0000000000800e6d <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e6d:	0f b6 07             	movzbl (%rdi),%eax
  800e70:	84 c0                	test   %al,%al
  800e72:	74 17                	je     800e8b <strcmp+0x1e>
  800e74:	3a 06                	cmp    (%rsi),%al
  800e76:	75 13                	jne    800e8b <strcmp+0x1e>
    p++, q++;
  800e78:	48 83 c7 01          	add    $0x1,%rdi
  800e7c:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e80:	0f b6 07             	movzbl (%rdi),%eax
  800e83:	84 c0                	test   %al,%al
  800e85:	74 04                	je     800e8b <strcmp+0x1e>
  800e87:	3a 06                	cmp    (%rsi),%al
  800e89:	74 ed                	je     800e78 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e8b:	0f b6 c0             	movzbl %al,%eax
  800e8e:	0f b6 16             	movzbl (%rsi),%edx
  800e91:	29 d0                	sub    %edx,%eax
}
  800e93:	c3                   	retq   

0000000000800e94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e94:	48 85 d2             	test   %rdx,%rdx
  800e97:	74 2f                	je     800ec8 <strncmp+0x34>
  800e99:	0f b6 07             	movzbl (%rdi),%eax
  800e9c:	84 c0                	test   %al,%al
  800e9e:	74 1f                	je     800ebf <strncmp+0x2b>
  800ea0:	3a 06                	cmp    (%rsi),%al
  800ea2:	75 1b                	jne    800ebf <strncmp+0x2b>
  800ea4:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800ea7:	48 83 c7 01          	add    $0x1,%rdi
  800eab:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800eaf:	48 39 d7             	cmp    %rdx,%rdi
  800eb2:	74 1a                	je     800ece <strncmp+0x3a>
  800eb4:	0f b6 07             	movzbl (%rdi),%eax
  800eb7:	84 c0                	test   %al,%al
  800eb9:	74 04                	je     800ebf <strncmp+0x2b>
  800ebb:	3a 06                	cmp    (%rsi),%al
  800ebd:	74 e8                	je     800ea7 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ebf:	0f b6 07             	movzbl (%rdi),%eax
  800ec2:	0f b6 16             	movzbl (%rsi),%edx
  800ec5:	29 d0                	sub    %edx,%eax
}
  800ec7:	c3                   	retq   
    return 0;
  800ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecd:	c3                   	retq   
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	c3                   	retq   

0000000000800ed4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800ed4:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ed6:	0f b6 07             	movzbl (%rdi),%eax
  800ed9:	84 c0                	test   %al,%al
  800edb:	74 1e                	je     800efb <strchr+0x27>
    if (*s == c)
  800edd:	40 38 c6             	cmp    %al,%sil
  800ee0:	74 1f                	je     800f01 <strchr+0x2d>
  for (; *s; s++)
  800ee2:	48 83 c7 01          	add    $0x1,%rdi
  800ee6:	0f b6 07             	movzbl (%rdi),%eax
  800ee9:	84 c0                	test   %al,%al
  800eeb:	74 08                	je     800ef5 <strchr+0x21>
    if (*s == c)
  800eed:	38 d0                	cmp    %dl,%al
  800eef:	75 f1                	jne    800ee2 <strchr+0xe>
  for (; *s; s++)
  800ef1:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ef4:	c3                   	retq   
  return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	c3                   	retq   
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	c3                   	retq   
    if (*s == c)
  800f01:	48 89 f8             	mov    %rdi,%rax
  800f04:	c3                   	retq   

0000000000800f05 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800f05:	48 89 f8             	mov    %rdi,%rax
  800f08:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800f0a:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800f0d:	40 38 f2             	cmp    %sil,%dl
  800f10:	74 13                	je     800f25 <strfind+0x20>
  800f12:	84 d2                	test   %dl,%dl
  800f14:	74 0f                	je     800f25 <strfind+0x20>
  for (; *s; s++)
  800f16:	48 83 c0 01          	add    $0x1,%rax
  800f1a:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800f1d:	38 ca                	cmp    %cl,%dl
  800f1f:	74 04                	je     800f25 <strfind+0x20>
  800f21:	84 d2                	test   %dl,%dl
  800f23:	75 f1                	jne    800f16 <strfind+0x11>
      break;
  return (char *)s;
}
  800f25:	c3                   	retq   

0000000000800f26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800f26:	48 85 d2             	test   %rdx,%rdx
  800f29:	74 3a                	je     800f65 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f2b:	48 89 f8             	mov    %rdi,%rax
  800f2e:	48 09 d0             	or     %rdx,%rax
  800f31:	a8 03                	test   $0x3,%al
  800f33:	75 28                	jne    800f5d <memset+0x37>
    uint32_t k = c & 0xFFU;
  800f35:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800f39:	89 f0                	mov    %esi,%eax
  800f3b:	c1 e0 08             	shl    $0x8,%eax
  800f3e:	89 f1                	mov    %esi,%ecx
  800f40:	c1 e1 18             	shl    $0x18,%ecx
  800f43:	41 89 f0             	mov    %esi,%r8d
  800f46:	41 c1 e0 10          	shl    $0x10,%r8d
  800f4a:	44 09 c1             	or     %r8d,%ecx
  800f4d:	09 ce                	or     %ecx,%esi
  800f4f:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800f51:	48 c1 ea 02          	shr    $0x2,%rdx
  800f55:	48 89 d1             	mov    %rdx,%rcx
  800f58:	fc                   	cld    
  800f59:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f5b:	eb 08                	jmp    800f65 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800f5d:	89 f0                	mov    %esi,%eax
  800f5f:	48 89 d1             	mov    %rdx,%rcx
  800f62:	fc                   	cld    
  800f63:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800f65:	48 89 f8             	mov    %rdi,%rax
  800f68:	c3                   	retq   

0000000000800f69 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800f69:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f6c:	48 39 fe             	cmp    %rdi,%rsi
  800f6f:	73 40                	jae    800fb1 <memmove+0x48>
  800f71:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f75:	48 39 f9             	cmp    %rdi,%rcx
  800f78:	76 37                	jbe    800fb1 <memmove+0x48>
    s += n;
    d += n;
  800f7a:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f7e:	48 89 fe             	mov    %rdi,%rsi
  800f81:	48 09 d6             	or     %rdx,%rsi
  800f84:	48 09 ce             	or     %rcx,%rsi
  800f87:	40 f6 c6 03          	test   $0x3,%sil
  800f8b:	75 14                	jne    800fa1 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f8d:	48 83 ef 04          	sub    $0x4,%rdi
  800f91:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f95:	48 c1 ea 02          	shr    $0x2,%rdx
  800f99:	48 89 d1             	mov    %rdx,%rcx
  800f9c:	fd                   	std    
  800f9d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f9f:	eb 0e                	jmp    800faf <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800fa1:	48 83 ef 01          	sub    $0x1,%rdi
  800fa5:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800fa9:	48 89 d1             	mov    %rdx,%rcx
  800fac:	fd                   	std    
  800fad:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800faf:	fc                   	cld    
  800fb0:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800fb1:	48 89 c1             	mov    %rax,%rcx
  800fb4:	48 09 d1             	or     %rdx,%rcx
  800fb7:	48 09 f1             	or     %rsi,%rcx
  800fba:	f6 c1 03             	test   $0x3,%cl
  800fbd:	75 0e                	jne    800fcd <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800fbf:	48 c1 ea 02          	shr    $0x2,%rdx
  800fc3:	48 89 d1             	mov    %rdx,%rcx
  800fc6:	48 89 c7             	mov    %rax,%rdi
  800fc9:	fc                   	cld    
  800fca:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800fcc:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800fcd:	48 89 c7             	mov    %rax,%rdi
  800fd0:	48 89 d1             	mov    %rdx,%rcx
  800fd3:	fc                   	cld    
  800fd4:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800fd6:	c3                   	retq   

0000000000800fd7 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800fd7:	55                   	push   %rbp
  800fd8:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800fdb:	48 b8 69 0f 80 00 00 	movabs $0x800f69,%rax
  800fe2:	00 00 00 
  800fe5:	ff d0                	callq  *%rax
}
  800fe7:	5d                   	pop    %rbp
  800fe8:	c3                   	retq   

0000000000800fe9 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800fe9:	55                   	push   %rbp
  800fea:	48 89 e5             	mov    %rsp,%rbp
  800fed:	41 57                	push   %r15
  800fef:	41 56                	push   %r14
  800ff1:	41 55                	push   %r13
  800ff3:	41 54                	push   %r12
  800ff5:	53                   	push   %rbx
  800ff6:	48 83 ec 08          	sub    $0x8,%rsp
  800ffa:	49 89 fe             	mov    %rdi,%r14
  800ffd:	49 89 f7             	mov    %rsi,%r15
  801000:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801003:	48 89 f7             	mov    %rsi,%rdi
  801006:	48 b8 5e 0d 80 00 00 	movabs $0x800d5e,%rax
  80100d:	00 00 00 
  801010:	ff d0                	callq  *%rax
  801012:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801015:	4c 89 ee             	mov    %r13,%rsi
  801018:	4c 89 f7             	mov    %r14,%rdi
  80101b:	48 b8 80 0d 80 00 00 	movabs $0x800d80,%rax
  801022:	00 00 00 
  801025:	ff d0                	callq  *%rax
  801027:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80102a:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80102e:	4d 39 e5             	cmp    %r12,%r13
  801031:	74 26                	je     801059 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801033:	4c 89 e8             	mov    %r13,%rax
  801036:	4c 29 e0             	sub    %r12,%rax
  801039:	48 39 d8             	cmp    %rbx,%rax
  80103c:	76 2a                	jbe    801068 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  80103e:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801042:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801046:	4c 89 fe             	mov    %r15,%rsi
  801049:	48 b8 d7 0f 80 00 00 	movabs $0x800fd7,%rax
  801050:	00 00 00 
  801053:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801055:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801059:	48 83 c4 08          	add    $0x8,%rsp
  80105d:	5b                   	pop    %rbx
  80105e:	41 5c                	pop    %r12
  801060:	41 5d                	pop    %r13
  801062:	41 5e                	pop    %r14
  801064:	41 5f                	pop    %r15
  801066:	5d                   	pop    %rbp
  801067:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801068:	49 83 ed 01          	sub    $0x1,%r13
  80106c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801070:	4c 89 ea             	mov    %r13,%rdx
  801073:	4c 89 fe             	mov    %r15,%rsi
  801076:	48 b8 d7 0f 80 00 00 	movabs $0x800fd7,%rax
  80107d:	00 00 00 
  801080:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801082:	4d 01 ee             	add    %r13,%r14
  801085:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80108a:	eb c9                	jmp    801055 <strlcat+0x6c>

000000000080108c <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80108c:	48 85 d2             	test   %rdx,%rdx
  80108f:	74 3a                	je     8010cb <memcmp+0x3f>
    if (*s1 != *s2)
  801091:	0f b6 0f             	movzbl (%rdi),%ecx
  801094:	44 0f b6 06          	movzbl (%rsi),%r8d
  801098:	44 38 c1             	cmp    %r8b,%cl
  80109b:	75 1d                	jne    8010ba <memcmp+0x2e>
  80109d:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8010a2:	48 39 d0             	cmp    %rdx,%rax
  8010a5:	74 1e                	je     8010c5 <memcmp+0x39>
    if (*s1 != *s2)
  8010a7:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8010ab:	48 83 c0 01          	add    $0x1,%rax
  8010af:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8010b5:	44 38 c1             	cmp    %r8b,%cl
  8010b8:	74 e8                	je     8010a2 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8010ba:	0f b6 c1             	movzbl %cl,%eax
  8010bd:	45 0f b6 c0          	movzbl %r8b,%r8d
  8010c1:	44 29 c0             	sub    %r8d,%eax
  8010c4:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8010c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ca:	c3                   	retq   
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d0:	c3                   	retq   

00000000008010d1 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8010d1:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8010d5:	48 39 c7             	cmp    %rax,%rdi
  8010d8:	73 19                	jae    8010f3 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010da:	89 f2                	mov    %esi,%edx
  8010dc:	40 38 37             	cmp    %sil,(%rdi)
  8010df:	74 16                	je     8010f7 <memfind+0x26>
  for (; s < ends; s++)
  8010e1:	48 83 c7 01          	add    $0x1,%rdi
  8010e5:	48 39 f8             	cmp    %rdi,%rax
  8010e8:	74 08                	je     8010f2 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010ea:	38 17                	cmp    %dl,(%rdi)
  8010ec:	75 f3                	jne    8010e1 <memfind+0x10>
  for (; s < ends; s++)
  8010ee:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8010f1:	c3                   	retq   
  8010f2:	c3                   	retq   
  for (; s < ends; s++)
  8010f3:	48 89 f8             	mov    %rdi,%rax
  8010f6:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8010f7:	48 89 f8             	mov    %rdi,%rax
  8010fa:	c3                   	retq   

00000000008010fb <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8010fb:	0f b6 07             	movzbl (%rdi),%eax
  8010fe:	3c 20                	cmp    $0x20,%al
  801100:	74 04                	je     801106 <strtol+0xb>
  801102:	3c 09                	cmp    $0x9,%al
  801104:	75 0f                	jne    801115 <strtol+0x1a>
    s++;
  801106:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80110a:	0f b6 07             	movzbl (%rdi),%eax
  80110d:	3c 20                	cmp    $0x20,%al
  80110f:	74 f5                	je     801106 <strtol+0xb>
  801111:	3c 09                	cmp    $0x9,%al
  801113:	74 f1                	je     801106 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801115:	3c 2b                	cmp    $0x2b,%al
  801117:	74 2b                	je     801144 <strtol+0x49>
  int neg  = 0;
  801119:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80111f:	3c 2d                	cmp    $0x2d,%al
  801121:	74 2d                	je     801150 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801123:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801129:	75 0f                	jne    80113a <strtol+0x3f>
  80112b:	80 3f 30             	cmpb   $0x30,(%rdi)
  80112e:	74 2c                	je     80115c <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801130:	85 d2                	test   %edx,%edx
  801132:	b8 0a 00 00 00       	mov    $0xa,%eax
  801137:	0f 44 d0             	cmove  %eax,%edx
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80113f:	4c 63 d2             	movslq %edx,%r10
  801142:	eb 5c                	jmp    8011a0 <strtol+0xa5>
    s++;
  801144:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801148:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80114e:	eb d3                	jmp    801123 <strtol+0x28>
    s++, neg = 1;
  801150:	48 83 c7 01          	add    $0x1,%rdi
  801154:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80115a:	eb c7                	jmp    801123 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80115c:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801160:	74 0f                	je     801171 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801162:	85 d2                	test   %edx,%edx
  801164:	75 d4                	jne    80113a <strtol+0x3f>
    s++, base = 8;
  801166:	48 83 c7 01          	add    $0x1,%rdi
  80116a:	ba 08 00 00 00       	mov    $0x8,%edx
  80116f:	eb c9                	jmp    80113a <strtol+0x3f>
    s += 2, base = 16;
  801171:	48 83 c7 02          	add    $0x2,%rdi
  801175:	ba 10 00 00 00       	mov    $0x10,%edx
  80117a:	eb be                	jmp    80113a <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80117c:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801180:	41 80 f8 19          	cmp    $0x19,%r8b
  801184:	77 2f                	ja     8011b5 <strtol+0xba>
      dig = *s - 'a' + 10;
  801186:	44 0f be c1          	movsbl %cl,%r8d
  80118a:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80118e:	39 d1                	cmp    %edx,%ecx
  801190:	7d 37                	jge    8011c9 <strtol+0xce>
    s++, val = (val * base) + dig;
  801192:	48 83 c7 01          	add    $0x1,%rdi
  801196:	49 0f af c2          	imul   %r10,%rax
  80119a:	48 63 c9             	movslq %ecx,%rcx
  80119d:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8011a0:	0f b6 0f             	movzbl (%rdi),%ecx
  8011a3:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8011a7:	41 80 f8 09          	cmp    $0x9,%r8b
  8011ab:	77 cf                	ja     80117c <strtol+0x81>
      dig = *s - '0';
  8011ad:	0f be c9             	movsbl %cl,%ecx
  8011b0:	83 e9 30             	sub    $0x30,%ecx
  8011b3:	eb d9                	jmp    80118e <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8011b5:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8011b9:	41 80 f8 19          	cmp    $0x19,%r8b
  8011bd:	77 0a                	ja     8011c9 <strtol+0xce>
      dig = *s - 'A' + 10;
  8011bf:	44 0f be c1          	movsbl %cl,%r8d
  8011c3:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8011c7:	eb c5                	jmp    80118e <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8011c9:	48 85 f6             	test   %rsi,%rsi
  8011cc:	74 03                	je     8011d1 <strtol+0xd6>
    *endptr = (char *)s;
  8011ce:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8011d1:	48 89 c2             	mov    %rax,%rdx
  8011d4:	48 f7 da             	neg    %rdx
  8011d7:	45 85 c9             	test   %r9d,%r9d
  8011da:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8011de:	c3                   	retq   

00000000008011df <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8011df:	55                   	push   %rbp
  8011e0:	48 89 e5             	mov    %rsp,%rbp
  8011e3:	53                   	push   %rbx
  8011e4:	48 89 fa             	mov    %rdi,%rdx
  8011e7:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ef:	48 89 c3             	mov    %rax,%rbx
  8011f2:	48 89 c7             	mov    %rax,%rdi
  8011f5:	48 89 c6             	mov    %rax,%rsi
  8011f8:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8011fa:	5b                   	pop    %rbx
  8011fb:	5d                   	pop    %rbp
  8011fc:	c3                   	retq   

00000000008011fd <sys_cgetc>:

int
sys_cgetc(void) {
  8011fd:	55                   	push   %rbp
  8011fe:	48 89 e5             	mov    %rsp,%rbp
  801201:	53                   	push   %rbx
  asm volatile("int %1\n"
  801202:	b9 00 00 00 00       	mov    $0x0,%ecx
  801207:	b8 01 00 00 00       	mov    $0x1,%eax
  80120c:	48 89 ca             	mov    %rcx,%rdx
  80120f:	48 89 cb             	mov    %rcx,%rbx
  801212:	48 89 cf             	mov    %rcx,%rdi
  801215:	48 89 ce             	mov    %rcx,%rsi
  801218:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80121a:	5b                   	pop    %rbx
  80121b:	5d                   	pop    %rbp
  80121c:	c3                   	retq   

000000000080121d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80121d:	55                   	push   %rbp
  80121e:	48 89 e5             	mov    %rsp,%rbp
  801221:	53                   	push   %rbx
  801222:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801226:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801229:	be 00 00 00 00       	mov    $0x0,%esi
  80122e:	b8 03 00 00 00       	mov    $0x3,%eax
  801233:	48 89 f1             	mov    %rsi,%rcx
  801236:	48 89 f3             	mov    %rsi,%rbx
  801239:	48 89 f7             	mov    %rsi,%rdi
  80123c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80123e:	48 85 c0             	test   %rax,%rax
  801241:	7f 07                	jg     80124a <sys_env_destroy+0x2d>
}
  801243:	48 83 c4 08          	add    $0x8,%rsp
  801247:	5b                   	pop    %rbx
  801248:	5d                   	pop    %rbp
  801249:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80124a:	49 89 c0             	mov    %rax,%r8
  80124d:	b9 03 00 00 00       	mov    $0x3,%ecx
  801252:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  801259:	00 00 00 
  80125c:	be 22 00 00 00       	mov    $0x22,%esi
  801261:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  801268:	00 00 00 
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  801277:	00 00 00 
  80127a:	41 ff d1             	callq  *%r9

000000000080127d <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80127d:	55                   	push   %rbp
  80127e:	48 89 e5             	mov    %rsp,%rbp
  801281:	53                   	push   %rbx
  asm volatile("int %1\n"
  801282:	b9 00 00 00 00       	mov    $0x0,%ecx
  801287:	b8 02 00 00 00       	mov    $0x2,%eax
  80128c:	48 89 ca             	mov    %rcx,%rdx
  80128f:	48 89 cb             	mov    %rcx,%rbx
  801292:	48 89 cf             	mov    %rcx,%rdi
  801295:	48 89 ce             	mov    %rcx,%rsi
  801298:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80129a:	5b                   	pop    %rbx
  80129b:	5d                   	pop    %rbp
  80129c:	c3                   	retq   

000000000080129d <sys_yield>:

void
sys_yield(void) {
  80129d:	55                   	push   %rbp
  80129e:	48 89 e5             	mov    %rsp,%rbp
  8012a1:	53                   	push   %rbx
  asm volatile("int %1\n"
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012ac:	48 89 ca             	mov    %rcx,%rdx
  8012af:	48 89 cb             	mov    %rcx,%rbx
  8012b2:	48 89 cf             	mov    %rcx,%rdi
  8012b5:	48 89 ce             	mov    %rcx,%rsi
  8012b8:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012ba:	5b                   	pop    %rbx
  8012bb:	5d                   	pop    %rbp
  8012bc:	c3                   	retq   

00000000008012bd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8012bd:	55                   	push   %rbp
  8012be:	48 89 e5             	mov    %rsp,%rbp
  8012c1:	53                   	push   %rbx
  8012c2:	48 83 ec 08          	sub    $0x8,%rsp
  8012c6:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8012c9:	4c 63 c7             	movslq %edi,%r8
  8012cc:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8012cf:	be 00 00 00 00       	mov    $0x0,%esi
  8012d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8012d9:	4c 89 c2             	mov    %r8,%rdx
  8012dc:	48 89 f7             	mov    %rsi,%rdi
  8012df:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012e1:	48 85 c0             	test   %rax,%rax
  8012e4:	7f 07                	jg     8012ed <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8012e6:	48 83 c4 08          	add    $0x8,%rsp
  8012ea:	5b                   	pop    %rbx
  8012eb:	5d                   	pop    %rbp
  8012ec:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012ed:	49 89 c0             	mov    %rax,%r8
  8012f0:	b9 04 00 00 00       	mov    $0x4,%ecx
  8012f5:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  8012fc:	00 00 00 
  8012ff:	be 22 00 00 00       	mov    $0x22,%esi
  801304:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  80130b:	00 00 00 
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  80131a:	00 00 00 
  80131d:	41 ff d1             	callq  *%r9

0000000000801320 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801320:	55                   	push   %rbp
  801321:	48 89 e5             	mov    %rsp,%rbp
  801324:	53                   	push   %rbx
  801325:	48 83 ec 08          	sub    $0x8,%rsp
  801329:	41 89 f9             	mov    %edi,%r9d
  80132c:	49 89 f2             	mov    %rsi,%r10
  80132f:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801332:	4d 63 c9             	movslq %r9d,%r9
  801335:	48 63 da             	movslq %edx,%rbx
  801338:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80133b:	b8 05 00 00 00       	mov    $0x5,%eax
  801340:	4c 89 ca             	mov    %r9,%rdx
  801343:	4c 89 d1             	mov    %r10,%rcx
  801346:	cd 30                	int    $0x30
  if (check && ret > 0)
  801348:	48 85 c0             	test   %rax,%rax
  80134b:	7f 07                	jg     801354 <sys_page_map+0x34>
}
  80134d:	48 83 c4 08          	add    $0x8,%rsp
  801351:	5b                   	pop    %rbx
  801352:	5d                   	pop    %rbp
  801353:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801354:	49 89 c0             	mov    %rax,%r8
  801357:	b9 05 00 00 00       	mov    $0x5,%ecx
  80135c:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  801363:	00 00 00 
  801366:	be 22 00 00 00       	mov    $0x22,%esi
  80136b:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  801372:	00 00 00 
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
  80137a:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  801381:	00 00 00 
  801384:	41 ff d1             	callq  *%r9

0000000000801387 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801387:	55                   	push   %rbp
  801388:	48 89 e5             	mov    %rsp,%rbp
  80138b:	53                   	push   %rbx
  80138c:	48 83 ec 08          	sub    $0x8,%rsp
  801390:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801393:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801396:	be 00 00 00 00       	mov    $0x0,%esi
  80139b:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a0:	48 89 f3             	mov    %rsi,%rbx
  8013a3:	48 89 f7             	mov    %rsi,%rdi
  8013a6:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013a8:	48 85 c0             	test   %rax,%rax
  8013ab:	7f 07                	jg     8013b4 <sys_page_unmap+0x2d>
}
  8013ad:	48 83 c4 08          	add    $0x8,%rsp
  8013b1:	5b                   	pop    %rbx
  8013b2:	5d                   	pop    %rbp
  8013b3:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013b4:	49 89 c0             	mov    %rax,%r8
  8013b7:	b9 06 00 00 00       	mov    $0x6,%ecx
  8013bc:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  8013c3:	00 00 00 
  8013c6:	be 22 00 00 00       	mov    $0x22,%esi
  8013cb:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  8013d2:	00 00 00 
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  8013e1:	00 00 00 
  8013e4:	41 ff d1             	callq  *%r9

00000000008013e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8013e7:	55                   	push   %rbp
  8013e8:	48 89 e5             	mov    %rsp,%rbp
  8013eb:	53                   	push   %rbx
  8013ec:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8013f0:	48 63 d7             	movslq %edi,%rdx
  8013f3:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8013f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801400:	48 89 df             	mov    %rbx,%rdi
  801403:	48 89 de             	mov    %rbx,%rsi
  801406:	cd 30                	int    $0x30
  if (check && ret > 0)
  801408:	48 85 c0             	test   %rax,%rax
  80140b:	7f 07                	jg     801414 <sys_env_set_status+0x2d>
}
  80140d:	48 83 c4 08          	add    $0x8,%rsp
  801411:	5b                   	pop    %rbx
  801412:	5d                   	pop    %rbp
  801413:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801414:	49 89 c0             	mov    %rax,%r8
  801417:	b9 08 00 00 00       	mov    $0x8,%ecx
  80141c:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  801423:	00 00 00 
  801426:	be 22 00 00 00       	mov    $0x22,%esi
  80142b:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  801432:	00 00 00 
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  801441:	00 00 00 
  801444:	41 ff d1             	callq  *%r9

0000000000801447 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801447:	55                   	push   %rbp
  801448:	48 89 e5             	mov    %rsp,%rbp
  80144b:	53                   	push   %rbx
  80144c:	48 83 ec 08          	sub    $0x8,%rsp
  801450:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801453:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801456:	be 00 00 00 00       	mov    $0x0,%esi
  80145b:	b8 09 00 00 00       	mov    $0x9,%eax
  801460:	48 89 f3             	mov    %rsi,%rbx
  801463:	48 89 f7             	mov    %rsi,%rdi
  801466:	cd 30                	int    $0x30
  if (check && ret > 0)
  801468:	48 85 c0             	test   %rax,%rax
  80146b:	7f 07                	jg     801474 <sys_env_set_pgfault_upcall+0x2d>
}
  80146d:	48 83 c4 08          	add    $0x8,%rsp
  801471:	5b                   	pop    %rbx
  801472:	5d                   	pop    %rbp
  801473:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801474:	49 89 c0             	mov    %rax,%r8
  801477:	b9 09 00 00 00       	mov    $0x9,%ecx
  80147c:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  801483:	00 00 00 
  801486:	be 22 00 00 00       	mov    $0x22,%esi
  80148b:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  801492:	00 00 00 
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  8014a1:	00 00 00 
  8014a4:	41 ff d1             	callq  *%r9

00000000008014a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8014a7:	55                   	push   %rbp
  8014a8:	48 89 e5             	mov    %rsp,%rbp
  8014ab:	53                   	push   %rbx
  8014ac:	49 89 f0             	mov    %rsi,%r8
  8014af:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8014b2:	48 63 d7             	movslq %edi,%rdx
  8014b5:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8014b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014bd:	be 00 00 00 00       	mov    $0x0,%esi
  8014c2:	4c 89 c1             	mov    %r8,%rcx
  8014c5:	cd 30                	int    $0x30
}
  8014c7:	5b                   	pop    %rbx
  8014c8:	5d                   	pop    %rbp
  8014c9:	c3                   	retq   

00000000008014ca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8014ca:	55                   	push   %rbp
  8014cb:	48 89 e5             	mov    %rsp,%rbp
  8014ce:	53                   	push   %rbx
  8014cf:	48 83 ec 08          	sub    $0x8,%rsp
  8014d3:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8014d6:	be 00 00 00 00       	mov    $0x0,%esi
  8014db:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014e0:	48 89 f1             	mov    %rsi,%rcx
  8014e3:	48 89 f3             	mov    %rsi,%rbx
  8014e6:	48 89 f7             	mov    %rsi,%rdi
  8014e9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8014eb:	48 85 c0             	test   %rax,%rax
  8014ee:	7f 07                	jg     8014f7 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8014f0:	48 83 c4 08          	add    $0x8,%rsp
  8014f4:	5b                   	pop    %rbx
  8014f5:	5d                   	pop    %rbp
  8014f6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8014f7:	49 89 c0             	mov    %rax,%r8
  8014fa:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8014ff:	48 ba a0 20 80 00 00 	movabs $0x8020a0,%rdx
  801506:	00 00 00 
  801509:	be 22 00 00 00       	mov    $0x22,%esi
  80150e:	48 bf bf 20 80 00 00 	movabs $0x8020bf,%rdi
  801515:	00 00 00 
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  801524:	00 00 00 
  801527:	41 ff d1             	callq  *%r9

000000000080152a <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  80152a:	55                   	push   %rbp
  80152b:	48 89 e5             	mov    %rsp,%rbp
  80152e:	53                   	push   %rbx
  80152f:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  801533:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  801536:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  80153a:	41 f6 c0 02          	test   $0x2,%r8b
  80153e:	0f 84 b2 00 00 00    	je     8015f6 <pgfault+0xcc>
  801544:	48 89 da             	mov    %rbx,%rdx
  801547:	48 c1 ea 0c          	shr    $0xc,%rdx
  80154b:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801552:	01 00 00 
  801555:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801559:	f6 c4 08             	test   $0x8,%ah
  80155c:	0f 84 94 00 00 00    	je     8015f6 <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  801562:	ba 02 00 00 00       	mov    $0x2,%edx
  801567:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  80156c:	bf 00 00 00 00       	mov    $0x0,%edi
  801571:	48 b8 bd 12 80 00 00 	movabs $0x8012bd,%rax
  801578:	00 00 00 
  80157b:	ff d0                	callq  *%rax
  80157d:	85 c0                	test   %eax,%eax
  80157f:	0f 88 9f 00 00 00    	js     801624 <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801585:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  80158c:	ba 00 10 00 00       	mov    $0x1000,%edx
  801591:	48 89 de             	mov    %rbx,%rsi
  801594:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  801599:	48 b8 69 0f 80 00 00 	movabs $0x800f69,%rax
  8015a0:	00 00 00 
  8015a3:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  8015a5:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  8015ab:	48 89 d9             	mov    %rbx,%rcx
  8015ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b3:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8015b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8015bd:	48 b8 20 13 80 00 00 	movabs $0x801320,%rax
  8015c4:	00 00 00 
  8015c7:	ff d0                	callq  *%rax
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	0f 88 80 00 00 00    	js     801651 <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  8015d1:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8015d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8015db:	48 b8 87 13 80 00 00 	movabs $0x801387,%rax
  8015e2:	00 00 00 
  8015e5:	ff d0                	callq  *%rax
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	0f 88 8f 00 00 00    	js     80167e <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  8015ef:	48 83 c4 08          	add    $0x8,%rsp
  8015f3:	5b                   	pop    %rbx
  8015f4:	5d                   	pop    %rbp
  8015f5:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  8015f6:	48 89 d9             	mov    %rbx,%rcx
  8015f9:	48 ba d0 20 80 00 00 	movabs $0x8020d0,%rdx
  801600:	00 00 00 
  801603:	be 21 00 00 00       	mov    $0x21,%esi
  801608:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  80160f:	00 00 00 
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
  801617:	49 b9 49 02 80 00 00 	movabs $0x800249,%r9
  80161e:	00 00 00 
  801621:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  801624:	89 c1                	mov    %eax,%ecx
  801626:	48 ba 00 21 80 00 00 	movabs $0x802100,%rdx
  80162d:	00 00 00 
  801630:	be 2f 00 00 00       	mov    $0x2f,%esi
  801635:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  80163c:	00 00 00 
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
  801644:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  80164b:	00 00 00 
  80164e:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  801651:	89 c1                	mov    %eax,%ecx
  801653:	48 ba 28 21 80 00 00 	movabs $0x802128,%rdx
  80165a:	00 00 00 
  80165d:	be 39 00 00 00       	mov    $0x39,%esi
  801662:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  801669:	00 00 00 
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
  801671:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  801678:	00 00 00 
  80167b:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  80167e:	89 c1                	mov    %eax,%ecx
  801680:	48 ba 50 21 80 00 00 	movabs $0x802150,%rdx
  801687:	00 00 00 
  80168a:	be 3d 00 00 00       	mov    $0x3d,%esi
  80168f:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  801696:	00 00 00 
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
  80169e:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  8016a5:	00 00 00 
  8016a8:	41 ff d0             	callq  *%r8

00000000008016ab <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  8016ab:	55                   	push   %rbp
  8016ac:	48 89 e5             	mov    %rsp,%rbp
  8016af:	41 57                	push   %r15
  8016b1:	41 56                	push   %r14
  8016b3:	41 55                	push   %r13
  8016b5:	41 54                	push   %r12
  8016b7:	53                   	push   %rbx
  8016b8:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  8016bc:	48 bf 2a 15 80 00 00 	movabs $0x80152a,%rdi
  8016c3:	00 00 00 
  8016c6:	48 b8 6e 1b 80 00 00 	movabs $0x801b6e,%rax
  8016cd:	00 00 00 
  8016d0:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  8016d2:	b8 07 00 00 00       	mov    $0x7,%eax
  8016d7:	cd 30                	int    $0x30
  8016d9:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  8016dc:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 38                	js     80171b <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  8016e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e8:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8016ec:	74 5a                	je     801748 <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8016ee:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  8016f5:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8016f8:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8016ff:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801702:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  801709:	01 00 00 
  80170c:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  801713:	01 00 00 
  801716:	e9 2c 01 00 00       	jmpq   801847 <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  80171b:	89 c1                	mov    %eax,%ecx
  80171d:	48 ba f7 21 80 00 00 	movabs $0x8021f7,%rdx
  801724:	00 00 00 
  801727:	be 82 00 00 00       	mov    $0x82,%esi
  80172c:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  801733:	00 00 00 
  801736:	b8 00 00 00 00       	mov    $0x0,%eax
  80173b:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  801742:	00 00 00 
  801745:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  801748:	48 b8 7d 12 80 00 00 	movabs $0x80127d,%rax
  80174f:	00 00 00 
  801752:	ff d0                	callq  *%rax
  801754:	25 ff 03 00 00       	and    $0x3ff,%eax
  801759:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80175d:	48 c1 e0 05          	shl    $0x5,%rax
  801761:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  801768:	00 00 00 
  80176b:	48 01 d0             	add    %rdx,%rax
  80176e:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  801775:	00 00 00 
		return 0;
  801778:	e9 9d 01 00 00       	jmpq   80191a <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  80177d:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801784:	01 00 00 
  801787:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  80178b:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  80178f:	48 b8 7d 12 80 00 00 	movabs $0x80127d,%rax
  801796:	00 00 00 
  801799:	ff d0                	callq  *%rax
  80179b:	89 c7                	mov    %eax,%edi
  80179d:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  8017a0:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8017a4:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8017aa:	74 57                	je     801803 <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  8017ac:	81 e2 05 06 00 00    	and    $0x605,%edx
  8017b2:	48 89 d0             	mov    %rdx,%rax
  8017b5:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8017b8:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8017bc:	48 c1 e6 0c          	shl    $0xc,%rsi
  8017c0:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8017c4:	41 89 c0             	mov    %eax,%r8d
  8017c7:	48 89 f1             	mov    %rsi,%rcx
  8017ca:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8017cd:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  8017d1:	48 b8 20 13 80 00 00 	movabs $0x801320,%rax
  8017d8:	00 00 00 
  8017db:	ff d0                	callq  *%rax
    if (r < 0) {
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	0f 88 ce 01 00 00    	js     8019b3 <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  8017e5:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8017e9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8017ed:	48 89 f1             	mov    %rsi,%rcx
  8017f0:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8017f3:	89 fa                	mov    %edi,%edx
  8017f5:	48 b8 20 13 80 00 00 	movabs $0x801320,%rax
  8017fc:	00 00 00 
  8017ff:	ff d0                	callq  *%rax
  801801:	eb 28                	jmp    80182b <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801803:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  801807:	48 c1 e6 0c          	shl    $0xc,%rsi
  80180b:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  80180f:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  801816:	48 89 f1             	mov    %rsi,%rcx
  801819:	8b 55 c0             	mov    -0x40(%rbp),%edx
  80181c:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  80181f:	48 b8 20 13 80 00 00 	movabs $0x801320,%rax
  801826:	00 00 00 
  801829:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  80182b:	85 c0                	test   %eax,%eax
  80182d:	0f 89 80 00 00 00    	jns    8018b3 <fork+0x208>
  801833:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801836:	e9 df 00 00 00       	jmpq   80191a <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  80183b:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801842:	4c 39 eb             	cmp    %r13,%rbx
  801845:	74 75                	je     8018bc <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801847:	48 89 d8             	mov    %rbx,%rax
  80184a:	48 c1 e8 27          	shr    $0x27,%rax
  80184e:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  801852:	a8 01                	test   $0x1,%al
  801854:	74 e5                	je     80183b <fork+0x190>
  801856:	48 89 d8             	mov    %rbx,%rax
  801859:	48 c1 e8 1e          	shr    $0x1e,%rax
  80185d:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  801861:	a8 01                	test   $0x1,%al
  801863:	74 d6                	je     80183b <fork+0x190>
  801865:	48 89 d8             	mov    %rbx,%rax
  801868:	48 c1 e8 15          	shr    $0x15,%rax
  80186c:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  801870:	a8 01                	test   $0x1,%al
  801872:	74 c7                	je     80183b <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  801874:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  80187b:	00 00 00 
  80187e:	48 39 c3             	cmp    %rax,%rbx
  801881:	77 b8                	ja     80183b <fork+0x190>
  801883:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  80188a:	48 39 c3             	cmp    %rax,%rbx
  80188d:	74 ac                	je     80183b <fork+0x190>
  80188f:	48 89 d8             	mov    %rbx,%rax
  801892:	48 c1 e8 0c          	shr    $0xc,%rax
  801896:	48 89 c1             	mov    %rax,%rcx
  801899:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  80189d:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8018a4:	01 00 00 
  8018a7:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  8018ab:	a8 01                	test   $0x1,%al
  8018ad:	0f 85 ca fe ff ff    	jne    80177d <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8018b3:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8018ba:	eb 8b                	jmp    801847 <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  8018bc:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  8018c3:	00 00 00 
  8018c6:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  8018cd:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8018d0:	48 b8 47 14 80 00 00 	movabs $0x801447,%rax
  8018d7:	00 00 00 
  8018da:	ff d0                	callq  *%rax
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 4c                	js     80192c <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  8018e0:	ba 02 00 00 00       	mov    $0x2,%edx
  8018e5:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8018ec:	00 00 00 
  8018ef:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8018f2:	48 b8 bd 12 80 00 00 	movabs $0x8012bd,%rax
  8018f9:	00 00 00 
  8018fc:	ff d0                	callq  *%rax
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 57                	js     801959 <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  801902:	be 02 00 00 00       	mov    $0x2,%esi
  801907:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  80190a:	48 b8 e7 13 80 00 00 	movabs $0x8013e7,%rax
  801911:	00 00 00 
  801914:	ff d0                	callq  *%rax
  801916:	85 c0                	test   %eax,%eax
  801918:	78 6c                	js     801986 <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  80191a:	8b 45 c0             	mov    -0x40(%rbp),%eax
  80191d:	48 83 c4 28          	add    $0x28,%rsp
  801921:	5b                   	pop    %rbx
  801922:	41 5c                	pop    %r12
  801924:	41 5d                	pop    %r13
  801926:	41 5e                	pop    %r14
  801928:	41 5f                	pop    %r15
  80192a:	5d                   	pop    %rbp
  80192b:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  80192c:	89 c1                	mov    %eax,%ecx
  80192e:	48 ba 78 21 80 00 00 	movabs $0x802178,%rdx
  801935:	00 00 00 
  801938:	be a7 00 00 00       	mov    $0xa7,%esi
  80193d:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  801944:	00 00 00 
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  801953:	00 00 00 
  801956:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  801959:	89 c1                	mov    %eax,%ecx
  80195b:	48 ba a8 21 80 00 00 	movabs $0x8021a8,%rdx
  801962:	00 00 00 
  801965:	be aa 00 00 00       	mov    $0xaa,%esi
  80196a:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  801971:	00 00 00 
  801974:	b8 00 00 00 00       	mov    $0x0,%eax
  801979:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  801980:	00 00 00 
  801983:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  801986:	89 c1                	mov    %eax,%ecx
  801988:	48 ba c8 21 80 00 00 	movabs $0x8021c8,%rdx
  80198f:	00 00 00 
  801992:	be bd 00 00 00       	mov    $0xbd,%esi
  801997:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  80199e:	00 00 00 
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a6:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  8019ad:	00 00 00 
  8019b0:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8019b3:	89 45 c0             	mov    %eax,-0x40(%rbp)
  8019b6:	e9 5f ff ff ff       	jmpq   80191a <fork+0x26f>

00000000008019bb <sfork>:

// Challenge!
int
sfork(void) {
  8019bb:	55                   	push   %rbp
  8019bc:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  8019bf:	48 ba 07 22 80 00 00 	movabs $0x802207,%rdx
  8019c6:	00 00 00 
  8019c9:	be c9 00 00 00       	mov    $0xc9,%esi
  8019ce:	48 bf ec 21 80 00 00 	movabs $0x8021ec,%rdi
  8019d5:	00 00 00 
  8019d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dd:	48 b9 49 02 80 00 00 	movabs $0x800249,%rcx
  8019e4:	00 00 00 
  8019e7:	ff d1                	callq  *%rcx

00000000008019e9 <ipc_recv>:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store) {
  8019e9:	55                   	push   %rbp
  8019ea:	48 89 e5             	mov    %rsp,%rbp
  8019ed:	41 54                	push   %r12
  8019ef:	53                   	push   %rbx
  8019f0:	49 89 fc             	mov    %rdi,%r12
  8019f3:	48 89 d3             	mov    %rdx,%rbx
  // LAB 9 code
  int r;

	if ((r = sys_ipc_recv(pg)) < 0) {
  8019f6:	48 89 f7             	mov    %rsi,%rdi
  8019f9:	48 b8 ca 14 80 00 00 	movabs $0x8014ca,%rax
  801a00:	00 00 00 
  801a03:	ff d0                	callq  *%rax
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 45                	js     801a4e <ipc_recv+0x65>
		if (perm_store) {
			*perm_store = 0;
		}
		return r;
	} else {
		if (from_env_store) {
  801a09:	4d 85 e4             	test   %r12,%r12
  801a0c:	74 14                	je     801a22 <ipc_recv+0x39>
			*from_env_store = thisenv->env_ipc_from;
  801a0e:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  801a15:	00 00 00 
  801a18:	8b 80 14 01 00 00    	mov    0x114(%rax),%eax
  801a1e:	41 89 04 24          	mov    %eax,(%r12)
		}
		if (perm_store) {
  801a22:	48 85 db             	test   %rbx,%rbx
  801a25:	74 12                	je     801a39 <ipc_recv+0x50>
			*perm_store = thisenv->env_ipc_perm;
  801a27:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  801a2e:	00 00 00 
  801a31:	8b 80 18 01 00 00    	mov    0x118(%rax),%eax
  801a37:	89 03                	mov    %eax,(%rbx)
		}
#ifdef SANITIZE_USER_SHADOW_BASE
	  platform_asan_unpoison(pg, PGSIZE);
#endif
		return thisenv->env_ipc_value;
  801a39:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  801a40:	00 00 00 
  801a43:	8b 80 10 01 00 00    	mov    0x110(%rax),%eax
	}
  // LAB 9 code end

  // return -1;
}
  801a49:	5b                   	pop    %rbx
  801a4a:	41 5c                	pop    %r12
  801a4c:	5d                   	pop    %rbp
  801a4d:	c3                   	retq   
		if (from_env_store) {
  801a4e:	4d 85 e4             	test   %r12,%r12
  801a51:	74 08                	je     801a5b <ipc_recv+0x72>
			*from_env_store = 0;
  801a53:	41 c7 04 24 00 00 00 	movl   $0x0,(%r12)
  801a5a:	00 
		if (perm_store) {
  801a5b:	48 85 db             	test   %rbx,%rbx
  801a5e:	74 e9                	je     801a49 <ipc_recv+0x60>
			*perm_store = 0;
  801a60:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  801a66:	eb e1                	jmp    801a49 <ipc_recv+0x60>

0000000000801a68 <ipc_send>:
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm) {
  801a68:	55                   	push   %rbp
  801a69:	48 89 e5             	mov    %rsp,%rbp
  801a6c:	41 57                	push   %r15
  801a6e:	41 56                	push   %r14
  801a70:	41 55                	push   %r13
  801a72:	41 54                	push   %r12
  801a74:	53                   	push   %rbx
  801a75:	48 83 ec 08          	sub    $0x8,%rsp
  801a79:	41 89 ff             	mov    %edi,%r15d
  801a7c:	41 89 f6             	mov    %esi,%r14d
  801a7f:	48 89 d3             	mov    %rdx,%rbx
  801a82:	41 89 cd             	mov    %ecx,%r13d
  // LAB 9 code
  int r;

  if (pg == NULL) {
    pg = (void *) UTOP;
  801a85:	48 85 d2             	test   %rdx,%rdx
  801a88:	48 b8 00 00 00 00 80 	movabs $0x8000000000,%rax
  801a8f:	00 00 00 
  801a92:	48 0f 44 d8          	cmove  %rax,%rbx
  }
  while ((r = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a96:	49 bc a7 14 80 00 00 	movabs $0x8014a7,%r12
  801a9d:	00 00 00 
  801aa0:	44 89 f6             	mov    %r14d,%esi
  801aa3:	44 89 e9             	mov    %r13d,%ecx
  801aa6:	48 89 da             	mov    %rbx,%rdx
  801aa9:	44 89 ff             	mov    %r15d,%edi
  801aac:	41 ff d4             	callq  *%r12
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	74 34                	je     801ae7 <ipc_send+0x7f>
	  if (r < 0 && r != -E_IPC_NOT_RECV) {
  801ab3:	79 eb                	jns    801aa0 <ipc_send+0x38>
  801ab5:	83 f8 f6             	cmp    $0xfffffff6,%eax
  801ab8:	74 e6                	je     801aa0 <ipc_send+0x38>
		  panic("ipc_send error: sys_ipc_try_send: %i\n", r);
  801aba:	89 c1                	mov    %eax,%ecx
  801abc:	48 ba 20 22 80 00 00 	movabs $0x802220,%rdx
  801ac3:	00 00 00 
  801ac6:	be 46 00 00 00       	mov    $0x46,%esi
  801acb:	48 bf 48 22 80 00 00 	movabs $0x802248,%rdi
  801ad2:	00 00 00 
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ada:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  801ae1:	00 00 00 
  801ae4:	41 ff d0             	callq  *%r8
	  }
	  //sys_yield();
  }
  sys_yield();
  801ae7:	48 b8 9d 12 80 00 00 	movabs $0x80129d,%rax
  801aee:	00 00 00 
  801af1:	ff d0                	callq  *%rax
  // LAB 9 code end
}
  801af3:	48 83 c4 08          	add    $0x8,%rsp
  801af7:	5b                   	pop    %rbx
  801af8:	41 5c                	pop    %r12
  801afa:	41 5d                	pop    %r13
  801afc:	41 5e                	pop    %r14
  801afe:	41 5f                	pop    %r15
  801b00:	5d                   	pop    %rbp
  801b01:	c3                   	retq   

0000000000801b02 <ipc_find_env>:
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type) {
  int i;
  for (i = 0; i < NENV; i++)
    if (envs[i].env_type == type)
  801b02:	a1 d0 e0 22 3c 80 00 	movabs 0x803c22e0d0,%eax
  801b09:	00 00 
  801b0b:	39 c7                	cmp    %eax,%edi
  801b0d:	74 38                	je     801b47 <ipc_find_env+0x45>
  for (i = 0; i < NENV; i++)
  801b0f:	ba 01 00 00 00       	mov    $0x1,%edx
    if (envs[i].env_type == type)
  801b14:	48 b9 00 e0 22 3c 80 	movabs $0x803c22e000,%rcx
  801b1b:	00 00 00 
  801b1e:	48 63 c2             	movslq %edx,%rax
  801b21:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  801b25:	48 c1 e0 05          	shl    $0x5,%rax
  801b29:	48 01 c8             	add    %rcx,%rax
  801b2c:	8b 80 d0 00 00 00    	mov    0xd0(%rax),%eax
  801b32:	39 f8                	cmp    %edi,%eax
  801b34:	74 16                	je     801b4c <ipc_find_env+0x4a>
  for (i = 0; i < NENV; i++)
  801b36:	83 c2 01             	add    $0x1,%edx
  801b39:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b3f:	75 dd                	jne    801b1e <ipc_find_env+0x1c>
      return envs[i].env_id;
  return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b46:	c3                   	retq   
  for (i = 0; i < NENV; i++)
  801b47:	ba 00 00 00 00       	mov    $0x0,%edx
      return envs[i].env_id;
  801b4c:	48 63 d2             	movslq %edx,%rdx
  801b4f:	48 8d 04 d2          	lea    (%rdx,%rdx,8),%rax
  801b53:	48 c1 e0 05          	shl    $0x5,%rax
  801b57:	48 89 c2             	mov    %rax,%rdx
  801b5a:	48 b8 00 e0 22 3c 80 	movabs $0x803c22e000,%rax
  801b61:	00 00 00 
  801b64:	48 01 d0             	add    %rdx,%rax
  801b67:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  801b6d:	c3                   	retq   

0000000000801b6e <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801b6e:	55                   	push   %rbp
  801b6f:	48 89 e5             	mov    %rsp,%rbp
  801b72:	41 54                	push   %r12
  801b74:	53                   	push   %rbx
  801b75:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  801b78:	48 b8 7d 12 80 00 00 	movabs $0x80127d,%rax
  801b7f:	00 00 00 
  801b82:	ff d0                	callq  *%rax
  801b84:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  801b86:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  801b8d:	00 00 00 
  801b90:	48 83 38 00          	cmpq   $0x0,(%rax)
  801b94:	74 2e                	je     801bc4 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801b96:	4c 89 e0             	mov    %r12,%rax
  801b99:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  801ba0:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801ba3:	48 be 10 1c 80 00 00 	movabs $0x801c10,%rsi
  801baa:	00 00 00 
  801bad:	89 df                	mov    %ebx,%edi
  801baf:	48 b8 47 14 80 00 00 	movabs $0x801447,%rax
  801bb6:	00 00 00 
  801bb9:	ff d0                	callq  *%rax
  if (error < 0)
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 24                	js     801be3 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801bbf:	5b                   	pop    %rbx
  801bc0:	41 5c                	pop    %r12
  801bc2:	5d                   	pop    %rbp
  801bc3:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  801bc4:	ba 02 00 00 00       	mov    $0x2,%edx
  801bc9:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801bd0:	00 00 00 
  801bd3:	89 df                	mov    %ebx,%edi
  801bd5:	48 b8 bd 12 80 00 00 	movabs $0x8012bd,%rax
  801bdc:	00 00 00 
  801bdf:	ff d0                	callq  *%rax
  801be1:	eb b3                	jmp    801b96 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801be3:	89 c1                	mov    %eax,%ecx
  801be5:	48 ba 52 22 80 00 00 	movabs $0x802252,%rdx
  801bec:	00 00 00 
  801bef:	be 2c 00 00 00       	mov    $0x2c,%esi
  801bf4:	48 bf 6a 22 80 00 00 	movabs $0x80226a,%rdi
  801bfb:	00 00 00 
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801c03:	49 b8 49 02 80 00 00 	movabs $0x800249,%r8
  801c0a:	00 00 00 
  801c0d:	41 ff d0             	callq  *%r8

0000000000801c10 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801c10:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801c13:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  801c1a:	00 00 00 
	call *%rax
  801c1d:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801c1f:	41 5f                	pop    %r15
	popq %r15
  801c21:	41 5f                	pop    %r15
	popq %r15
  801c23:	41 5f                	pop    %r15
	popq %r14
  801c25:	41 5e                	pop    %r14
	popq %r13
  801c27:	41 5d                	pop    %r13
	popq %r12
  801c29:	41 5c                	pop    %r12
	popq %r11
  801c2b:	41 5b                	pop    %r11
	popq %r10
  801c2d:	41 5a                	pop    %r10
	popq %r9
  801c2f:	41 59                	pop    %r9
	popq %r8
  801c31:	41 58                	pop    %r8
	popq %rsi
  801c33:	5e                   	pop    %rsi
	popq %rdi
  801c34:	5f                   	pop    %rdi
	popq %rbp
  801c35:	5d                   	pop    %rbp
	popq %rdx
  801c36:	5a                   	pop    %rdx
	popq %rcx
  801c37:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801c38:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801c3d:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801c42:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801c46:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801c49:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801c4e:	5b                   	pop    %rbx
	popq %rax
  801c4f:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801c50:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801c54:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801c55:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801c5a:	c3                   	retq   
  801c5b:	90                   	nop
