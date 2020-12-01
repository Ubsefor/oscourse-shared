
obj/user/stresssched:     file format elf64-x86-64


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
  800023:	e8 1e 01 00 00       	callq  800146 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#include <inc/lib.h>

volatile int counter;

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 55                	push   %r13
  800030:	41 54                	push   %r12
  800032:	53                   	push   %rbx
  800033:	48 83 ec 08          	sub    $0x8,%rsp
  int i, j;
  envid_t parent = sys_getenvid();
  800037:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  80003e:	00 00 00 
  800041:	ff d0                	callq  *%rax
  800043:	41 89 c5             	mov    %eax,%r13d

  // Fork several environments
  for (i = 0; i < 20; i++)
  800046:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (fork() == 0)
  80004b:	49 bc 75 16 80 00 00 	movabs $0x801675,%r12
  800052:	00 00 00 
  800055:	41 ff d4             	callq  *%r12
  800058:	85 c0                	test   %eax,%eax
  80005a:	74 19                	je     800075 <umain+0x4b>
  for (i = 0; i < 20; i++)
  80005c:	83 c3 01             	add    $0x1,%ebx
  80005f:	83 fb 14             	cmp    $0x14,%ebx
  800062:	75 f1                	jne    800055 <umain+0x2b>
      break;
  if (i == 20) {
    sys_yield();
  800064:	48 b8 67 12 80 00 00 	movabs $0x801267,%rax
  80006b:	00 00 00 
  80006e:	ff d0                	callq  *%rax
    return;
  800070:	e9 8f 00 00 00       	jmpq   800104 <umain+0xda>
  if (i == 20) {
  800075:	83 fb 14             	cmp    $0x14,%ebx
  800078:	74 ea                	je     800064 <umain+0x3a>
  }

  // Wait for the parent to finish forking
  while (envs[ENVX(parent)].env_status != ENV_FREE)
  80007a:	44 89 e8             	mov    %r13d,%eax
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	48 63 d0             	movslq %eax,%rdx
  800085:	48 8d 14 d2          	lea    (%rdx,%rdx,8),%rdx
  800089:	48 89 d1             	mov    %rdx,%rcx
  80008c:	48 c1 e1 05          	shl    $0x5,%rcx
  800090:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800097:	00 00 00 
  80009a:	48 01 ca             	add    %rcx,%rdx
  80009d:	8b 92 d4 00 00 00    	mov    0xd4(%rdx),%edx
  8000a3:	85 d2                	test   %edx,%edx
  8000a5:	74 19                	je     8000c0 <umain+0x96>
  8000a7:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000ae:	00 00 00 
  8000b1:	48 01 ca             	add    %rcx,%rdx
    asm volatile("pause");
  8000b4:	f3 90                	pause  
  while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000b6:	8b 82 d4 00 00 00    	mov    0xd4(%rdx),%eax
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 f4                	jne    8000b4 <umain+0x8a>
  for (i = 0; i < 20; i++)
  8000c0:	41 bc 0a 00 00 00    	mov    $0xa,%r12d

  // Check that one environment doesn't run on two CPUs at once
  for (i = 0; i < 10; i++) {
    sys_yield();
  8000c6:	49 bd 67 12 80 00 00 	movabs $0x801267,%r13
  8000cd:	00 00 00 
    for (j = 0; j < 10000; j++)
      counter++;
  8000d0:	48 bb 08 30 80 00 00 	movabs $0x803008,%rbx
  8000d7:	00 00 00 
    sys_yield();
  8000da:	41 ff d5             	callq  *%r13
  8000dd:	ba 10 27 00 00       	mov    $0x2710,%edx
      counter++;
  8000e2:	8b 03                	mov    (%rbx),%eax
  8000e4:	83 c0 01             	add    $0x1,%eax
  8000e7:	89 03                	mov    %eax,(%rbx)
    for (j = 0; j < 10000; j++)
  8000e9:	83 ea 01             	sub    $0x1,%edx
  8000ec:	75 f4                	jne    8000e2 <umain+0xb8>
  for (i = 0; i < 10; i++) {
  8000ee:	41 83 ec 01          	sub    $0x1,%r12d
  8000f2:	75 e6                	jne    8000da <umain+0xb0>
  }

  if (counter != 10 * 10000)
  8000f4:	a1 08 30 80 00 00 00 	movabs 0x803008,%eax
  8000fb:	00 00 
  8000fd:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  800102:	75 0b                	jne    80010f <umain+0xe5>
    panic("ran on two CPUs at once (counter is %d)", counter);

  // Check that we see environments running on different CPUs
  //cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
}
  800104:	48 83 c4 08          	add    $0x8,%rsp
  800108:	5b                   	pop    %rbx
  800109:	41 5c                	pop    %r12
  80010b:	41 5d                	pop    %r13
  80010d:	5d                   	pop    %rbp
  80010e:	c3                   	retq   
    panic("ran on two CPUs at once (counter is %d)", counter);
  80010f:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  800116:	00 00 00 
  800119:	8b 08                	mov    (%rax),%ecx
  80011b:	48 ba a0 1a 80 00 00 	movabs $0x801aa0,%rdx
  800122:	00 00 00 
  800125:	be 1f 00 00 00       	mov    $0x1f,%esi
  80012a:	48 bf c8 1a 80 00 00 	movabs $0x801ac8,%rdi
  800131:	00 00 00 
  800134:	b8 00 00 00 00       	mov    $0x0,%eax
  800139:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  800140:	00 00 00 
  800143:	41 ff d0             	callq  *%r8

0000000000800146 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800146:	55                   	push   %rbp
  800147:	48 89 e5             	mov    %rsp,%rbp
  80014a:	41 56                	push   %r14
  80014c:	41 55                	push   %r13
  80014e:	41 54                	push   %r12
  800150:	53                   	push   %rbx
  800151:	41 89 fd             	mov    %edi,%r13d
  800154:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800157:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  80015e:	00 00 00 
  800161:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  800168:	00 00 00 
  80016b:	48 39 c2             	cmp    %rax,%rdx
  80016e:	73 23                	jae    800193 <libmain+0x4d>
  800170:	48 89 d3             	mov    %rdx,%rbx
  800173:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800177:	48 29 d0             	sub    %rdx,%rax
  80017a:	48 c1 e8 03          	shr    $0x3,%rax
  80017e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800183:	b8 00 00 00 00       	mov    $0x0,%eax
  800188:	ff 13                	callq  *(%rbx)
    ctor++;
  80018a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80018e:	4c 39 e3             	cmp    %r12,%rbx
  800191:	75 f0                	jne    800183 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800193:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  80019a:	00 00 00 
  80019d:	ff d0                	callq  *%rax
  80019f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001a4:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8001a8:	48 c1 e0 05          	shl    $0x5,%rax
  8001ac:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8001b3:	00 00 00 
  8001b6:	48 01 d0             	add    %rdx,%rax
  8001b9:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  8001c0:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8001c3:	45 85 ed             	test   %r13d,%r13d
  8001c6:	7e 0d                	jle    8001d5 <libmain+0x8f>
    binaryname = argv[0];
  8001c8:	49 8b 06             	mov    (%r14),%rax
  8001cb:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  8001d2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8001d5:	4c 89 f6             	mov    %r14,%rsi
  8001d8:	44 89 ef             	mov    %r13d,%edi
  8001db:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8001e2:	00 00 00 
  8001e5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8001e7:	48 b8 fc 01 80 00 00 	movabs $0x8001fc,%rax
  8001ee:	00 00 00 
  8001f1:	ff d0                	callq  *%rax
#endif
}
  8001f3:	5b                   	pop    %rbx
  8001f4:	41 5c                	pop    %r12
  8001f6:	41 5d                	pop    %r13
  8001f8:	41 5e                	pop    %r14
  8001fa:	5d                   	pop    %rbp
  8001fb:	c3                   	retq   

00000000008001fc <exit>:

#include <inc/lib.h>

void
exit(void) {
  8001fc:	55                   	push   %rbp
  8001fd:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800200:	bf 00 00 00 00       	mov    $0x0,%edi
  800205:	48 b8 e7 11 80 00 00 	movabs $0x8011e7,%rax
  80020c:	00 00 00 
  80020f:	ff d0                	callq  *%rax
}
  800211:	5d                   	pop    %rbp
  800212:	c3                   	retq   

0000000000800213 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800213:	55                   	push   %rbp
  800214:	48 89 e5             	mov    %rsp,%rbp
  800217:	41 56                	push   %r14
  800219:	41 55                	push   %r13
  80021b:	41 54                	push   %r12
  80021d:	53                   	push   %rbx
  80021e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800225:	49 89 fd             	mov    %rdi,%r13
  800228:	41 89 f6             	mov    %esi,%r14d
  80022b:	49 89 d4             	mov    %rdx,%r12
  80022e:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800235:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80023c:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800243:	84 c0                	test   %al,%al
  800245:	74 26                	je     80026d <_panic+0x5a>
  800247:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80024e:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800255:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800259:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80025d:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800261:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800265:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800269:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80026d:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800274:	00 00 00 
  800277:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80027e:	00 00 00 
  800281:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800285:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80028c:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800293:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80029a:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  8002a1:	00 00 00 
  8002a4:	48 8b 18             	mov    (%rax),%rbx
  8002a7:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  8002ae:	00 00 00 
  8002b1:	ff d0                	callq  *%rax
  8002b3:	45 89 f0             	mov    %r14d,%r8d
  8002b6:	4c 89 e9             	mov    %r13,%rcx
  8002b9:	48 89 da             	mov    %rbx,%rdx
  8002bc:	89 c6                	mov    %eax,%esi
  8002be:	48 bf e8 1a 80 00 00 	movabs $0x801ae8,%rdi
  8002c5:	00 00 00 
  8002c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cd:	48 bb b5 03 80 00 00 	movabs $0x8003b5,%rbx
  8002d4:	00 00 00 
  8002d7:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8002d9:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002e0:	4c 89 e7             	mov    %r12,%rdi
  8002e3:	48 b8 4d 03 80 00 00 	movabs $0x80034d,%rax
  8002ea:	00 00 00 
  8002ed:	ff d0                	callq  *%rax
  cprintf("\n");
  8002ef:	48 bf 69 20 80 00 00 	movabs $0x802069,%rdi
  8002f6:	00 00 00 
  8002f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fe:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800300:	cc                   	int3   
  while (1)
  800301:	eb fd                	jmp    800300 <_panic+0xed>

0000000000800303 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800303:	55                   	push   %rbp
  800304:	48 89 e5             	mov    %rsp,%rbp
  800307:	53                   	push   %rbx
  800308:	48 83 ec 08          	sub    $0x8,%rsp
  80030c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80030f:	8b 06                	mov    (%rsi),%eax
  800311:	8d 50 01             	lea    0x1(%rax),%edx
  800314:	89 16                	mov    %edx,(%rsi)
  800316:	48 98                	cltq   
  800318:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80031d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800323:	74 0b                	je     800330 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800325:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800329:	48 83 c4 08          	add    $0x8,%rsp
  80032d:	5b                   	pop    %rbx
  80032e:	5d                   	pop    %rbp
  80032f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800330:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800334:	be ff 00 00 00       	mov    $0xff,%esi
  800339:	48 b8 a9 11 80 00 00 	movabs $0x8011a9,%rax
  800340:	00 00 00 
  800343:	ff d0                	callq  *%rax
    b->idx = 0;
  800345:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80034b:	eb d8                	jmp    800325 <putch+0x22>

000000000080034d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80034d:	55                   	push   %rbp
  80034e:	48 89 e5             	mov    %rsp,%rbp
  800351:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800358:	48 89 fa             	mov    %rdi,%rdx
  80035b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80035e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800365:	00 00 00 
  b.cnt = 0;
  800368:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80036f:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800372:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800379:	48 bf 03 03 80 00 00 	movabs $0x800303,%rdi
  800380:	00 00 00 
  800383:	48 b8 73 05 80 00 00 	movabs $0x800573,%rax
  80038a:	00 00 00 
  80038d:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80038f:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800396:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80039d:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8003a1:	48 b8 a9 11 80 00 00 	movabs $0x8011a9,%rax
  8003a8:	00 00 00 
  8003ab:	ff d0                	callq  *%rax

  return b.cnt;
}
  8003ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8003b3:	c9                   	leaveq 
  8003b4:	c3                   	retq   

00000000008003b5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8003b5:	55                   	push   %rbp
  8003b6:	48 89 e5             	mov    %rsp,%rbp
  8003b9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003c0:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8003c7:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8003ce:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8003d5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003dc:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003e3:	84 c0                	test   %al,%al
  8003e5:	74 20                	je     800407 <cprintf+0x52>
  8003e7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003eb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003ef:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003f3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003f7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003fb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003ff:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800403:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800407:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80040e:	00 00 00 
  800411:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800418:	00 00 00 
  80041b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80041f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800426:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80042d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800434:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80043b:	48 b8 4d 03 80 00 00 	movabs $0x80034d,%rax
  800442:	00 00 00 
  800445:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800447:	c9                   	leaveq 
  800448:	c3                   	retq   

0000000000800449 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800449:	55                   	push   %rbp
  80044a:	48 89 e5             	mov    %rsp,%rbp
  80044d:	41 57                	push   %r15
  80044f:	41 56                	push   %r14
  800451:	41 55                	push   %r13
  800453:	41 54                	push   %r12
  800455:	53                   	push   %rbx
  800456:	48 83 ec 18          	sub    $0x18,%rsp
  80045a:	49 89 fc             	mov    %rdi,%r12
  80045d:	49 89 f5             	mov    %rsi,%r13
  800460:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800464:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800467:	41 89 cf             	mov    %ecx,%r15d
  80046a:	49 39 d7             	cmp    %rdx,%r15
  80046d:	76 45                	jbe    8004b4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80046f:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800473:	85 db                	test   %ebx,%ebx
  800475:	7e 0e                	jle    800485 <printnum+0x3c>
      putch(padc, putdat);
  800477:	4c 89 ee             	mov    %r13,%rsi
  80047a:	44 89 f7             	mov    %r14d,%edi
  80047d:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800480:	83 eb 01             	sub    $0x1,%ebx
  800483:	75 f2                	jne    800477 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800485:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
  80048e:	49 f7 f7             	div    %r15
  800491:	48 b8 0b 1b 80 00 00 	movabs $0x801b0b,%rax
  800498:	00 00 00 
  80049b:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80049f:	4c 89 ee             	mov    %r13,%rsi
  8004a2:	41 ff d4             	callq  *%r12
}
  8004a5:	48 83 c4 18          	add    $0x18,%rsp
  8004a9:	5b                   	pop    %rbx
  8004aa:	41 5c                	pop    %r12
  8004ac:	41 5d                	pop    %r13
  8004ae:	41 5e                	pop    %r14
  8004b0:	41 5f                	pop    %r15
  8004b2:	5d                   	pop    %rbp
  8004b3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8004b4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bd:	49 f7 f7             	div    %r15
  8004c0:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8004c4:	48 89 c2             	mov    %rax,%rdx
  8004c7:	48 b8 49 04 80 00 00 	movabs $0x800449,%rax
  8004ce:	00 00 00 
  8004d1:	ff d0                	callq  *%rax
  8004d3:	eb b0                	jmp    800485 <printnum+0x3c>

00000000008004d5 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8004d5:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8004d9:	48 8b 06             	mov    (%rsi),%rax
  8004dc:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004e0:	73 0a                	jae    8004ec <sprintputch+0x17>
    *b->buf++ = ch;
  8004e2:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004e6:	48 89 16             	mov    %rdx,(%rsi)
  8004e9:	40 88 38             	mov    %dil,(%rax)
}
  8004ec:	c3                   	retq   

00000000008004ed <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004ed:	55                   	push   %rbp
  8004ee:	48 89 e5             	mov    %rsp,%rbp
  8004f1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004f8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004ff:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800506:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80050d:	84 c0                	test   %al,%al
  80050f:	74 20                	je     800531 <printfmt+0x44>
  800511:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800515:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800519:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80051d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800521:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800525:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800529:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80052d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800531:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800538:	00 00 00 
  80053b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800542:	00 00 00 
  800545:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800549:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800550:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800557:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80055e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800565:	48 b8 73 05 80 00 00 	movabs $0x800573,%rax
  80056c:	00 00 00 
  80056f:	ff d0                	callq  *%rax
}
  800571:	c9                   	leaveq 
  800572:	c3                   	retq   

0000000000800573 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800573:	55                   	push   %rbp
  800574:	48 89 e5             	mov    %rsp,%rbp
  800577:	41 57                	push   %r15
  800579:	41 56                	push   %r14
  80057b:	41 55                	push   %r13
  80057d:	41 54                	push   %r12
  80057f:	53                   	push   %rbx
  800580:	48 83 ec 48          	sub    $0x48,%rsp
  800584:	49 89 fd             	mov    %rdi,%r13
  800587:	49 89 f7             	mov    %rsi,%r15
  80058a:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80058d:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800591:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800595:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800599:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80059d:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8005a1:	41 0f b6 3e          	movzbl (%r14),%edi
  8005a5:	83 ff 25             	cmp    $0x25,%edi
  8005a8:	74 18                	je     8005c2 <vprintfmt+0x4f>
      if (ch == '\0')
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	0f 84 8c 06 00 00    	je     800c3e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8005b2:	4c 89 fe             	mov    %r15,%rsi
  8005b5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8005b8:	49 89 de             	mov    %rbx,%r14
  8005bb:	eb e0                	jmp    80059d <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8005bd:	49 89 de             	mov    %rbx,%r14
  8005c0:	eb db                	jmp    80059d <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8005c2:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8005c6:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8005ca:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8005d1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8005d7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005e0:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005e6:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005ec:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005f1:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005f6:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005fa:	0f b6 13             	movzbl (%rbx),%edx
  8005fd:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800600:	3c 55                	cmp    $0x55,%al
  800602:	0f 87 8b 05 00 00    	ja     800b93 <vprintfmt+0x620>
  800608:	0f b6 c0             	movzbl %al,%eax
  80060b:	49 bb e0 1b 80 00 00 	movabs $0x801be0,%r11
  800612:	00 00 00 
  800615:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800619:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80061c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800620:	eb d4                	jmp    8005f6 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800622:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800625:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800629:	eb cb                	jmp    8005f6 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80062b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80062e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800632:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800636:	8d 50 d0             	lea    -0x30(%rax),%edx
  800639:	83 fa 09             	cmp    $0x9,%edx
  80063c:	77 7e                	ja     8006bc <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80063e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800642:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800646:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80064b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80064f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800652:	83 fa 09             	cmp    $0x9,%edx
  800655:	76 e7                	jbe    80063e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800657:	4c 89 f3             	mov    %r14,%rbx
  80065a:	eb 19                	jmp    800675 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80065c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80065f:	83 f8 2f             	cmp    $0x2f,%eax
  800662:	77 2a                	ja     80068e <vprintfmt+0x11b>
  800664:	89 c2                	mov    %eax,%edx
  800666:	4c 01 d2             	add    %r10,%rdx
  800669:	83 c0 08             	add    $0x8,%eax
  80066c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80066f:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800672:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800675:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800679:	0f 89 77 ff ff ff    	jns    8005f6 <vprintfmt+0x83>
          width = precision, precision = -1;
  80067f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800683:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800689:	e9 68 ff ff ff       	jmpq   8005f6 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80068e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800692:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800696:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80069a:	eb d3                	jmp    80066f <vprintfmt+0xfc>
        if (width < 0)
  80069c:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8006a5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8006a8:	4c 89 f3             	mov    %r14,%rbx
  8006ab:	e9 46 ff ff ff       	jmpq   8005f6 <vprintfmt+0x83>
  8006b0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8006b3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8006b7:	e9 3a ff ff ff       	jmpq   8005f6 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8006bc:	4c 89 f3             	mov    %r14,%rbx
  8006bf:	eb b4                	jmp    800675 <vprintfmt+0x102>
        lflag++;
  8006c1:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8006c4:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8006c7:	e9 2a ff ff ff       	jmpq   8005f6 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8006cc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006cf:	83 f8 2f             	cmp    $0x2f,%eax
  8006d2:	77 19                	ja     8006ed <vprintfmt+0x17a>
  8006d4:	89 c2                	mov    %eax,%edx
  8006d6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006da:	83 c0 08             	add    $0x8,%eax
  8006dd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006e0:	4c 89 fe             	mov    %r15,%rsi
  8006e3:	8b 3a                	mov    (%rdx),%edi
  8006e5:	41 ff d5             	callq  *%r13
        break;
  8006e8:	e9 b0 fe ff ff       	jmpq   80059d <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006ed:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006f1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006f5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006f9:	eb e5                	jmp    8006e0 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006fb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006fe:	83 f8 2f             	cmp    $0x2f,%eax
  800701:	77 5b                	ja     80075e <vprintfmt+0x1eb>
  800703:	89 c2                	mov    %eax,%edx
  800705:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800709:	83 c0 08             	add    $0x8,%eax
  80070c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80070f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800711:	89 c8                	mov    %ecx,%eax
  800713:	c1 f8 1f             	sar    $0x1f,%eax
  800716:	31 c1                	xor    %eax,%ecx
  800718:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80071a:	83 f9 0b             	cmp    $0xb,%ecx
  80071d:	7f 4d                	jg     80076c <vprintfmt+0x1f9>
  80071f:	48 63 c1             	movslq %ecx,%rax
  800722:	48 ba a0 1e 80 00 00 	movabs $0x801ea0,%rdx
  800729:	00 00 00 
  80072c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800730:	48 85 c0             	test   %rax,%rax
  800733:	74 37                	je     80076c <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800735:	48 89 c1             	mov    %rax,%rcx
  800738:	48 ba 2c 1b 80 00 00 	movabs $0x801b2c,%rdx
  80073f:	00 00 00 
  800742:	4c 89 fe             	mov    %r15,%rsi
  800745:	4c 89 ef             	mov    %r13,%rdi
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	48 bb ed 04 80 00 00 	movabs $0x8004ed,%rbx
  800754:	00 00 00 
  800757:	ff d3                	callq  *%rbx
  800759:	e9 3f fe ff ff       	jmpq   80059d <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80075e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800762:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800766:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80076a:	eb a3                	jmp    80070f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80076c:	48 ba 23 1b 80 00 00 	movabs $0x801b23,%rdx
  800773:	00 00 00 
  800776:	4c 89 fe             	mov    %r15,%rsi
  800779:	4c 89 ef             	mov    %r13,%rdi
  80077c:	b8 00 00 00 00       	mov    $0x0,%eax
  800781:	48 bb ed 04 80 00 00 	movabs $0x8004ed,%rbx
  800788:	00 00 00 
  80078b:	ff d3                	callq  *%rbx
  80078d:	e9 0b fe ff ff       	jmpq   80059d <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800792:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800795:	83 f8 2f             	cmp    $0x2f,%eax
  800798:	77 4b                	ja     8007e5 <vprintfmt+0x272>
  80079a:	89 c2                	mov    %eax,%edx
  80079c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a0:	83 c0 08             	add    $0x8,%eax
  8007a3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007a6:	48 8b 02             	mov    (%rdx),%rax
  8007a9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8007ad:	48 85 c0             	test   %rax,%rax
  8007b0:	0f 84 05 04 00 00    	je     800bbb <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8007b6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8007ba:	7e 06                	jle    8007c2 <vprintfmt+0x24f>
  8007bc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8007c0:	75 31                	jne    8007f3 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007c6:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007ca:	0f b6 00             	movzbl (%rax),%eax
  8007cd:	0f be f8             	movsbl %al,%edi
  8007d0:	85 ff                	test   %edi,%edi
  8007d2:	0f 84 c3 00 00 00    	je     80089b <vprintfmt+0x328>
  8007d8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007dc:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007e0:	e9 85 00 00 00       	jmpq   80086a <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007e5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007ed:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007f1:	eb b3                	jmp    8007a6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007f3:	49 63 f4             	movslq %r12d,%rsi
  8007f6:	48 89 c7             	mov    %rax,%rdi
  8007f9:	48 b8 4a 0d 80 00 00 	movabs $0x800d4a,%rax
  800800:	00 00 00 
  800803:	ff d0                	callq  *%rax
  800805:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800808:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80080b:	85 f6                	test   %esi,%esi
  80080d:	7e 22                	jle    800831 <vprintfmt+0x2be>
            putch(padc, putdat);
  80080f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800813:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800817:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80081b:	4c 89 fe             	mov    %r15,%rsi
  80081e:	89 df                	mov    %ebx,%edi
  800820:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800823:	41 83 ec 01          	sub    $0x1,%r12d
  800827:	75 f2                	jne    80081b <vprintfmt+0x2a8>
  800829:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80082d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800831:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800835:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800839:	0f b6 00             	movzbl (%rax),%eax
  80083c:	0f be f8             	movsbl %al,%edi
  80083f:	85 ff                	test   %edi,%edi
  800841:	0f 84 56 fd ff ff    	je     80059d <vprintfmt+0x2a>
  800847:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80084b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80084f:	eb 19                	jmp    80086a <vprintfmt+0x2f7>
            putch(ch, putdat);
  800851:	4c 89 fe             	mov    %r15,%rsi
  800854:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800857:	41 83 ee 01          	sub    $0x1,%r14d
  80085b:	48 83 c3 01          	add    $0x1,%rbx
  80085f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800863:	0f be f8             	movsbl %al,%edi
  800866:	85 ff                	test   %edi,%edi
  800868:	74 29                	je     800893 <vprintfmt+0x320>
  80086a:	45 85 e4             	test   %r12d,%r12d
  80086d:	78 06                	js     800875 <vprintfmt+0x302>
  80086f:	41 83 ec 01          	sub    $0x1,%r12d
  800873:	78 48                	js     8008bd <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800875:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800879:	74 d6                	je     800851 <vprintfmt+0x2de>
  80087b:	0f be c0             	movsbl %al,%eax
  80087e:	83 e8 20             	sub    $0x20,%eax
  800881:	83 f8 5e             	cmp    $0x5e,%eax
  800884:	76 cb                	jbe    800851 <vprintfmt+0x2de>
            putch('?', putdat);
  800886:	4c 89 fe             	mov    %r15,%rsi
  800889:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80088e:	41 ff d5             	callq  *%r13
  800891:	eb c4                	jmp    800857 <vprintfmt+0x2e4>
  800893:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800897:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80089b:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80089e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008a2:	0f 8e f5 fc ff ff    	jle    80059d <vprintfmt+0x2a>
          putch(' ', putdat);
  8008a8:	4c 89 fe             	mov    %r15,%rsi
  8008ab:	bf 20 00 00 00       	mov    $0x20,%edi
  8008b0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8008b3:	83 eb 01             	sub    $0x1,%ebx
  8008b6:	75 f0                	jne    8008a8 <vprintfmt+0x335>
  8008b8:	e9 e0 fc ff ff       	jmpq   80059d <vprintfmt+0x2a>
  8008bd:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8008c1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8008c5:	eb d4                	jmp    80089b <vprintfmt+0x328>
  if (lflag >= 2)
  8008c7:	83 f9 01             	cmp    $0x1,%ecx
  8008ca:	7f 1d                	jg     8008e9 <vprintfmt+0x376>
  else if (lflag)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 5e                	je     80092e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8008d0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d3:	83 f8 2f             	cmp    $0x2f,%eax
  8008d6:	77 48                	ja     800920 <vprintfmt+0x3ad>
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008de:	83 c0 08             	add    $0x8,%eax
  8008e1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008e4:	48 8b 1a             	mov    (%rdx),%rbx
  8008e7:	eb 17                	jmp    800900 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008e9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ec:	83 f8 2f             	cmp    $0x2f,%eax
  8008ef:	77 21                	ja     800912 <vprintfmt+0x39f>
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f7:	83 c0 08             	add    $0x8,%eax
  8008fa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008fd:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800900:	48 85 db             	test   %rbx,%rbx
  800903:	78 50                	js     800955 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800905:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800908:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090d:	e9 b4 01 00 00       	jmpq   800ac6 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800912:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800916:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091e:	eb dd                	jmp    8008fd <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800920:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800924:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800928:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80092c:	eb b6                	jmp    8008e4 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80092e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800931:	83 f8 2f             	cmp    $0x2f,%eax
  800934:	77 11                	ja     800947 <vprintfmt+0x3d4>
  800936:	89 c2                	mov    %eax,%edx
  800938:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093c:	83 c0 08             	add    $0x8,%eax
  80093f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800942:	48 63 1a             	movslq (%rdx),%rbx
  800945:	eb b9                	jmp    800900 <vprintfmt+0x38d>
  800947:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800953:	eb ed                	jmp    800942 <vprintfmt+0x3cf>
          putch('-', putdat);
  800955:	4c 89 fe             	mov    %r15,%rsi
  800958:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80095d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800960:	48 89 da             	mov    %rbx,%rdx
  800963:	48 f7 da             	neg    %rdx
        base = 10;
  800966:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80096b:	e9 56 01 00 00       	jmpq   800ac6 <vprintfmt+0x553>
  if (lflag >= 2)
  800970:	83 f9 01             	cmp    $0x1,%ecx
  800973:	7f 25                	jg     80099a <vprintfmt+0x427>
  else if (lflag)
  800975:	85 c9                	test   %ecx,%ecx
  800977:	74 5e                	je     8009d7 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800979:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80097c:	83 f8 2f             	cmp    $0x2f,%eax
  80097f:	77 48                	ja     8009c9 <vprintfmt+0x456>
  800981:	89 c2                	mov    %eax,%edx
  800983:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800987:	83 c0 08             	add    $0x8,%eax
  80098a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80098d:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800990:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800995:	e9 2c 01 00 00       	jmpq   800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80099a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099d:	83 f8 2f             	cmp    $0x2f,%eax
  8009a0:	77 19                	ja     8009bb <vprintfmt+0x448>
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a8:	83 c0 08             	add    $0x8,%eax
  8009ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ae:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8009b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b6:	e9 0b 01 00 00       	jmpq   800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009bb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009bf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c7:	eb e5                	jmp    8009ae <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8009c9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009cd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009d1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009d5:	eb b6                	jmp    80098d <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8009d7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009da:	83 f8 2f             	cmp    $0x2f,%eax
  8009dd:	77 18                	ja     8009f7 <vprintfmt+0x484>
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e5:	83 c0 08             	add    $0x8,%eax
  8009e8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009eb:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f2:	e9 cf 00 00 00       	jmpq   800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009f7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009fb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ff:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a03:	eb e6                	jmp    8009eb <vprintfmt+0x478>
  if (lflag >= 2)
  800a05:	83 f9 01             	cmp    $0x1,%ecx
  800a08:	7f 25                	jg     800a2f <vprintfmt+0x4bc>
  else if (lflag)
  800a0a:	85 c9                	test   %ecx,%ecx
  800a0c:	74 5b                	je     800a69 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800a0e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a11:	83 f8 2f             	cmp    $0x2f,%eax
  800a14:	77 45                	ja     800a5b <vprintfmt+0x4e8>
  800a16:	89 c2                	mov    %eax,%edx
  800a18:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a1c:	83 c0 08             	add    $0x8,%eax
  800a1f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a22:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a25:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a2a:	e9 97 00 00 00       	jmpq   800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a2f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a32:	83 f8 2f             	cmp    $0x2f,%eax
  800a35:	77 16                	ja     800a4d <vprintfmt+0x4da>
  800a37:	89 c2                	mov    %eax,%edx
  800a39:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a3d:	83 c0 08             	add    $0x8,%eax
  800a40:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a43:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a46:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a4b:	eb 79                	jmp    800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a4d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a51:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a55:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a59:	eb e8                	jmp    800a43 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a5b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a5f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a63:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a67:	eb b9                	jmp    800a22 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a69:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a6c:	83 f8 2f             	cmp    $0x2f,%eax
  800a6f:	77 15                	ja     800a86 <vprintfmt+0x513>
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a77:	83 c0 08             	add    $0x8,%eax
  800a7a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a7d:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a7f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a84:	eb 40                	jmp    800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a86:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a8a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a8e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a92:	eb e9                	jmp    800a7d <vprintfmt+0x50a>
        putch('0', putdat);
  800a94:	4c 89 fe             	mov    %r15,%rsi
  800a97:	bf 30 00 00 00       	mov    $0x30,%edi
  800a9c:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a9f:	4c 89 fe             	mov    %r15,%rsi
  800aa2:	bf 78 00 00 00       	mov    $0x78,%edi
  800aa7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800aaa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aad:	83 f8 2f             	cmp    $0x2f,%eax
  800ab0:	77 34                	ja     800ae6 <vprintfmt+0x573>
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ab8:	83 c0 08             	add    $0x8,%eax
  800abb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800abe:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ac1:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800ac6:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800acb:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800acf:	4c 89 fe             	mov    %r15,%rsi
  800ad2:	4c 89 ef             	mov    %r13,%rdi
  800ad5:	48 b8 49 04 80 00 00 	movabs $0x800449,%rax
  800adc:	00 00 00 
  800adf:	ff d0                	callq  *%rax
        break;
  800ae1:	e9 b7 fa ff ff       	jmpq   80059d <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ae6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aea:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aee:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800af2:	eb ca                	jmp    800abe <vprintfmt+0x54b>
  if (lflag >= 2)
  800af4:	83 f9 01             	cmp    $0x1,%ecx
  800af7:	7f 22                	jg     800b1b <vprintfmt+0x5a8>
  else if (lflag)
  800af9:	85 c9                	test   %ecx,%ecx
  800afb:	74 58                	je     800b55 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800afd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b00:	83 f8 2f             	cmp    $0x2f,%eax
  800b03:	77 42                	ja     800b47 <vprintfmt+0x5d4>
  800b05:	89 c2                	mov    %eax,%edx
  800b07:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b0b:	83 c0 08             	add    $0x8,%eax
  800b0e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b11:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b14:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b19:	eb ab                	jmp    800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b1b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1e:	83 f8 2f             	cmp    $0x2f,%eax
  800b21:	77 16                	ja     800b39 <vprintfmt+0x5c6>
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b29:	83 c0 08             	add    $0x8,%eax
  800b2c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800b32:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b37:	eb 8d                	jmp    800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b39:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b3d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b41:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b45:	eb e8                	jmp    800b2f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b47:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b4b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b4f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b53:	eb bc                	jmp    800b11 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b55:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b58:	83 f8 2f             	cmp    $0x2f,%eax
  800b5b:	77 18                	ja     800b75 <vprintfmt+0x602>
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b63:	83 c0 08             	add    $0x8,%eax
  800b66:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b69:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b6b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b70:	e9 51 ff ff ff       	jmpq   800ac6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b75:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b79:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b7d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b81:	eb e6                	jmp    800b69 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b83:	4c 89 fe             	mov    %r15,%rsi
  800b86:	bf 25 00 00 00       	mov    $0x25,%edi
  800b8b:	41 ff d5             	callq  *%r13
        break;
  800b8e:	e9 0a fa ff ff       	jmpq   80059d <vprintfmt+0x2a>
        putch('%', putdat);
  800b93:	4c 89 fe             	mov    %r15,%rsi
  800b96:	bf 25 00 00 00       	mov    $0x25,%edi
  800b9b:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b9e:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800ba2:	0f 84 15 fa ff ff    	je     8005bd <vprintfmt+0x4a>
  800ba8:	49 89 de             	mov    %rbx,%r14
  800bab:	49 83 ee 01          	sub    $0x1,%r14
  800baf:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800bb4:	75 f5                	jne    800bab <vprintfmt+0x638>
  800bb6:	e9 e2 f9 ff ff       	jmpq   80059d <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800bbb:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800bbf:	74 06                	je     800bc7 <vprintfmt+0x654>
  800bc1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800bc5:	7f 21                	jg     800be8 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc7:	bf 28 00 00 00       	mov    $0x28,%edi
  800bcc:	48 bb 1d 1b 80 00 00 	movabs $0x801b1d,%rbx
  800bd3:	00 00 00 
  800bd6:	b8 28 00 00 00       	mov    $0x28,%eax
  800bdb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bdf:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800be3:	e9 82 fc ff ff       	jmpq   80086a <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800be8:	49 63 f4             	movslq %r12d,%rsi
  800beb:	48 bf 1c 1b 80 00 00 	movabs $0x801b1c,%rdi
  800bf2:	00 00 00 
  800bf5:	48 b8 4a 0d 80 00 00 	movabs $0x800d4a,%rax
  800bfc:	00 00 00 
  800bff:	ff d0                	callq  *%rax
  800c01:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800c04:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800c07:	48 be 1c 1b 80 00 00 	movabs $0x801b1c,%rsi
  800c0e:	00 00 00 
  800c11:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	0f 8f f2 fb ff ff    	jg     80080f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c1d:	48 bb 1d 1b 80 00 00 	movabs $0x801b1d,%rbx
  800c24:	00 00 00 
  800c27:	b8 28 00 00 00       	mov    $0x28,%eax
  800c2c:	bf 28 00 00 00       	mov    $0x28,%edi
  800c31:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800c35:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c39:	e9 2c fc ff ff       	jmpq   80086a <vprintfmt+0x2f7>
}
  800c3e:	48 83 c4 48          	add    $0x48,%rsp
  800c42:	5b                   	pop    %rbx
  800c43:	41 5c                	pop    %r12
  800c45:	41 5d                	pop    %r13
  800c47:	41 5e                	pop    %r14
  800c49:	41 5f                	pop    %r15
  800c4b:	5d                   	pop    %rbp
  800c4c:	c3                   	retq   

0000000000800c4d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c4d:	55                   	push   %rbp
  800c4e:	48 89 e5             	mov    %rsp,%rbp
  800c51:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c55:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c59:	48 63 c6             	movslq %esi,%rax
  800c5c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c61:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c65:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c6c:	48 85 ff             	test   %rdi,%rdi
  800c6f:	74 2a                	je     800c9b <vsnprintf+0x4e>
  800c71:	85 f6                	test   %esi,%esi
  800c73:	7e 26                	jle    800c9b <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c75:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c79:	48 bf d5 04 80 00 00 	movabs $0x8004d5,%rdi
  800c80:	00 00 00 
  800c83:	48 b8 73 05 80 00 00 	movabs $0x800573,%rax
  800c8a:	00 00 00 
  800c8d:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c8f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c93:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c96:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c99:	c9                   	leaveq 
  800c9a:	c3                   	retq   
    return -E_INVAL;
  800c9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ca0:	eb f7                	jmp    800c99 <vsnprintf+0x4c>

0000000000800ca2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ca2:	55                   	push   %rbp
  800ca3:	48 89 e5             	mov    %rsp,%rbp
  800ca6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800cad:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800cb4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800cbb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800cc2:	84 c0                	test   %al,%al
  800cc4:	74 20                	je     800ce6 <snprintf+0x44>
  800cc6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800cca:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800cce:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800cd2:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800cd6:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800cda:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800cde:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ce2:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ce6:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ced:	00 00 00 
  800cf0:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800cf7:	00 00 00 
  800cfa:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cfe:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800d05:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800d0c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800d13:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800d1a:	48 b8 4d 0c 80 00 00 	movabs $0x800c4d,%rax
  800d21:	00 00 00 
  800d24:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800d26:	c9                   	leaveq 
  800d27:	c3                   	retq   

0000000000800d28 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800d28:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d2b:	74 17                	je     800d44 <strlen+0x1c>
  800d2d:	48 89 fa             	mov    %rdi,%rdx
  800d30:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d35:	29 f9                	sub    %edi,%ecx
    n++;
  800d37:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d3a:	48 83 c2 01          	add    $0x1,%rdx
  800d3e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d41:	75 f4                	jne    800d37 <strlen+0xf>
  800d43:	c3                   	retq   
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d49:	c3                   	retq   

0000000000800d4a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4a:	48 85 f6             	test   %rsi,%rsi
  800d4d:	74 24                	je     800d73 <strnlen+0x29>
  800d4f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d52:	74 25                	je     800d79 <strnlen+0x2f>
  800d54:	48 01 fe             	add    %rdi,%rsi
  800d57:	48 89 fa             	mov    %rdi,%rdx
  800d5a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d5f:	29 f9                	sub    %edi,%ecx
    n++;
  800d61:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d64:	48 83 c2 01          	add    $0x1,%rdx
  800d68:	48 39 f2             	cmp    %rsi,%rdx
  800d6b:	74 11                	je     800d7e <strnlen+0x34>
  800d6d:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d70:	75 ef                	jne    800d61 <strnlen+0x17>
  800d72:	c3                   	retq   
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	c3                   	retq   
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d7e:	c3                   	retq   

0000000000800d7f <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d7f:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d8b:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d8e:	48 83 c2 01          	add    $0x1,%rdx
  800d92:	84 c9                	test   %cl,%cl
  800d94:	75 f1                	jne    800d87 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d96:	c3                   	retq   

0000000000800d97 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d97:	55                   	push   %rbp
  800d98:	48 89 e5             	mov    %rsp,%rbp
  800d9b:	41 54                	push   %r12
  800d9d:	53                   	push   %rbx
  800d9e:	48 89 fb             	mov    %rdi,%rbx
  800da1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800da4:	48 b8 28 0d 80 00 00 	movabs $0x800d28,%rax
  800dab:	00 00 00 
  800dae:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800db0:	48 63 f8             	movslq %eax,%rdi
  800db3:	48 01 df             	add    %rbx,%rdi
  800db6:	4c 89 e6             	mov    %r12,%rsi
  800db9:	48 b8 7f 0d 80 00 00 	movabs $0x800d7f,%rax
  800dc0:	00 00 00 
  800dc3:	ff d0                	callq  *%rax
  return dst;
}
  800dc5:	48 89 d8             	mov    %rbx,%rax
  800dc8:	5b                   	pop    %rbx
  800dc9:	41 5c                	pop    %r12
  800dcb:	5d                   	pop    %rbp
  800dcc:	c3                   	retq   

0000000000800dcd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dcd:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800dd0:	48 85 d2             	test   %rdx,%rdx
  800dd3:	74 1f                	je     800df4 <strncpy+0x27>
  800dd5:	48 01 fa             	add    %rdi,%rdx
  800dd8:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800ddb:	48 83 c1 01          	add    $0x1,%rcx
  800ddf:	44 0f b6 06          	movzbl (%rsi),%r8d
  800de3:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800de7:	41 80 f8 01          	cmp    $0x1,%r8b
  800deb:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800def:	48 39 ca             	cmp    %rcx,%rdx
  800df2:	75 e7                	jne    800ddb <strncpy+0xe>
  }
  return ret;
}
  800df4:	c3                   	retq   

0000000000800df5 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800df5:	48 89 f8             	mov    %rdi,%rax
  800df8:	48 85 d2             	test   %rdx,%rdx
  800dfb:	74 36                	je     800e33 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800dfd:	48 83 fa 01          	cmp    $0x1,%rdx
  800e01:	74 2d                	je     800e30 <strlcpy+0x3b>
  800e03:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e07:	45 84 c0             	test   %r8b,%r8b
  800e0a:	74 24                	je     800e30 <strlcpy+0x3b>
  800e0c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800e10:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800e15:	48 83 c0 01          	add    $0x1,%rax
  800e19:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800e1d:	48 39 d1             	cmp    %rdx,%rcx
  800e20:	74 0e                	je     800e30 <strlcpy+0x3b>
  800e22:	48 83 c1 01          	add    $0x1,%rcx
  800e26:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800e2b:	45 84 c0             	test   %r8b,%r8b
  800e2e:	75 e5                	jne    800e15 <strlcpy+0x20>
    *dst = '\0';
  800e30:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800e33:	48 29 f8             	sub    %rdi,%rax
}
  800e36:	c3                   	retq   

0000000000800e37 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e37:	0f b6 07             	movzbl (%rdi),%eax
  800e3a:	84 c0                	test   %al,%al
  800e3c:	74 17                	je     800e55 <strcmp+0x1e>
  800e3e:	3a 06                	cmp    (%rsi),%al
  800e40:	75 13                	jne    800e55 <strcmp+0x1e>
    p++, q++;
  800e42:	48 83 c7 01          	add    $0x1,%rdi
  800e46:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e4a:	0f b6 07             	movzbl (%rdi),%eax
  800e4d:	84 c0                	test   %al,%al
  800e4f:	74 04                	je     800e55 <strcmp+0x1e>
  800e51:	3a 06                	cmp    (%rsi),%al
  800e53:	74 ed                	je     800e42 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e55:	0f b6 c0             	movzbl %al,%eax
  800e58:	0f b6 16             	movzbl (%rsi),%edx
  800e5b:	29 d0                	sub    %edx,%eax
}
  800e5d:	c3                   	retq   

0000000000800e5e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e5e:	48 85 d2             	test   %rdx,%rdx
  800e61:	74 2f                	je     800e92 <strncmp+0x34>
  800e63:	0f b6 07             	movzbl (%rdi),%eax
  800e66:	84 c0                	test   %al,%al
  800e68:	74 1f                	je     800e89 <strncmp+0x2b>
  800e6a:	3a 06                	cmp    (%rsi),%al
  800e6c:	75 1b                	jne    800e89 <strncmp+0x2b>
  800e6e:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e71:	48 83 c7 01          	add    $0x1,%rdi
  800e75:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e79:	48 39 d7             	cmp    %rdx,%rdi
  800e7c:	74 1a                	je     800e98 <strncmp+0x3a>
  800e7e:	0f b6 07             	movzbl (%rdi),%eax
  800e81:	84 c0                	test   %al,%al
  800e83:	74 04                	je     800e89 <strncmp+0x2b>
  800e85:	3a 06                	cmp    (%rsi),%al
  800e87:	74 e8                	je     800e71 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e89:	0f b6 07             	movzbl (%rdi),%eax
  800e8c:	0f b6 16             	movzbl (%rsi),%edx
  800e8f:	29 d0                	sub    %edx,%eax
}
  800e91:	c3                   	retq   
    return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	c3                   	retq   
  800e98:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9d:	c3                   	retq   

0000000000800e9e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e9e:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800ea0:	0f b6 07             	movzbl (%rdi),%eax
  800ea3:	84 c0                	test   %al,%al
  800ea5:	74 1e                	je     800ec5 <strchr+0x27>
    if (*s == c)
  800ea7:	40 38 c6             	cmp    %al,%sil
  800eaa:	74 1f                	je     800ecb <strchr+0x2d>
  for (; *s; s++)
  800eac:	48 83 c7 01          	add    $0x1,%rdi
  800eb0:	0f b6 07             	movzbl (%rdi),%eax
  800eb3:	84 c0                	test   %al,%al
  800eb5:	74 08                	je     800ebf <strchr+0x21>
    if (*s == c)
  800eb7:	38 d0                	cmp    %dl,%al
  800eb9:	75 f1                	jne    800eac <strchr+0xe>
  for (; *s; s++)
  800ebb:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800ebe:	c3                   	retq   
  return 0;
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	c3                   	retq   
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	c3                   	retq   
    if (*s == c)
  800ecb:	48 89 f8             	mov    %rdi,%rax
  800ece:	c3                   	retq   

0000000000800ecf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ecf:	48 89 f8             	mov    %rdi,%rax
  800ed2:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800ed4:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800ed7:	40 38 f2             	cmp    %sil,%dl
  800eda:	74 13                	je     800eef <strfind+0x20>
  800edc:	84 d2                	test   %dl,%dl
  800ede:	74 0f                	je     800eef <strfind+0x20>
  for (; *s; s++)
  800ee0:	48 83 c0 01          	add    $0x1,%rax
  800ee4:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800ee7:	38 ca                	cmp    %cl,%dl
  800ee9:	74 04                	je     800eef <strfind+0x20>
  800eeb:	84 d2                	test   %dl,%dl
  800eed:	75 f1                	jne    800ee0 <strfind+0x11>
      break;
  return (char *)s;
}
  800eef:	c3                   	retq   

0000000000800ef0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800ef0:	48 85 d2             	test   %rdx,%rdx
  800ef3:	74 3a                	je     800f2f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ef5:	48 89 f8             	mov    %rdi,%rax
  800ef8:	48 09 d0             	or     %rdx,%rax
  800efb:	a8 03                	test   $0x3,%al
  800efd:	75 28                	jne    800f27 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800eff:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	c1 e0 08             	shl    $0x8,%eax
  800f08:	89 f1                	mov    %esi,%ecx
  800f0a:	c1 e1 18             	shl    $0x18,%ecx
  800f0d:	41 89 f0             	mov    %esi,%r8d
  800f10:	41 c1 e0 10          	shl    $0x10,%r8d
  800f14:	44 09 c1             	or     %r8d,%ecx
  800f17:	09 ce                	or     %ecx,%esi
  800f19:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800f1b:	48 c1 ea 02          	shr    $0x2,%rdx
  800f1f:	48 89 d1             	mov    %rdx,%rcx
  800f22:	fc                   	cld    
  800f23:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800f25:	eb 08                	jmp    800f2f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800f27:	89 f0                	mov    %esi,%eax
  800f29:	48 89 d1             	mov    %rdx,%rcx
  800f2c:	fc                   	cld    
  800f2d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800f2f:	48 89 f8             	mov    %rdi,%rax
  800f32:	c3                   	retq   

0000000000800f33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800f33:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f36:	48 39 fe             	cmp    %rdi,%rsi
  800f39:	73 40                	jae    800f7b <memmove+0x48>
  800f3b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f3f:	48 39 f9             	cmp    %rdi,%rcx
  800f42:	76 37                	jbe    800f7b <memmove+0x48>
    s += n;
    d += n;
  800f44:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f48:	48 89 fe             	mov    %rdi,%rsi
  800f4b:	48 09 d6             	or     %rdx,%rsi
  800f4e:	48 09 ce             	or     %rcx,%rsi
  800f51:	40 f6 c6 03          	test   $0x3,%sil
  800f55:	75 14                	jne    800f6b <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f57:	48 83 ef 04          	sub    $0x4,%rdi
  800f5b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f5f:	48 c1 ea 02          	shr    $0x2,%rdx
  800f63:	48 89 d1             	mov    %rdx,%rcx
  800f66:	fd                   	std    
  800f67:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f69:	eb 0e                	jmp    800f79 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f6b:	48 83 ef 01          	sub    $0x1,%rdi
  800f6f:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f73:	48 89 d1             	mov    %rdx,%rcx
  800f76:	fd                   	std    
  800f77:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f79:	fc                   	cld    
  800f7a:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f7b:	48 89 c1             	mov    %rax,%rcx
  800f7e:	48 09 d1             	or     %rdx,%rcx
  800f81:	48 09 f1             	or     %rsi,%rcx
  800f84:	f6 c1 03             	test   $0x3,%cl
  800f87:	75 0e                	jne    800f97 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f89:	48 c1 ea 02          	shr    $0x2,%rdx
  800f8d:	48 89 d1             	mov    %rdx,%rcx
  800f90:	48 89 c7             	mov    %rax,%rdi
  800f93:	fc                   	cld    
  800f94:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f96:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f97:	48 89 c7             	mov    %rax,%rdi
  800f9a:	48 89 d1             	mov    %rdx,%rcx
  800f9d:	fc                   	cld    
  800f9e:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800fa0:	c3                   	retq   

0000000000800fa1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800fa1:	55                   	push   %rbp
  800fa2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800fa5:	48 b8 33 0f 80 00 00 	movabs $0x800f33,%rax
  800fac:	00 00 00 
  800faf:	ff d0                	callq  *%rax
}
  800fb1:	5d                   	pop    %rbp
  800fb2:	c3                   	retq   

0000000000800fb3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800fb3:	55                   	push   %rbp
  800fb4:	48 89 e5             	mov    %rsp,%rbp
  800fb7:	41 57                	push   %r15
  800fb9:	41 56                	push   %r14
  800fbb:	41 55                	push   %r13
  800fbd:	41 54                	push   %r12
  800fbf:	53                   	push   %rbx
  800fc0:	48 83 ec 08          	sub    $0x8,%rsp
  800fc4:	49 89 fe             	mov    %rdi,%r14
  800fc7:	49 89 f7             	mov    %rsi,%r15
  800fca:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800fcd:	48 89 f7             	mov    %rsi,%rdi
  800fd0:	48 b8 28 0d 80 00 00 	movabs $0x800d28,%rax
  800fd7:	00 00 00 
  800fda:	ff d0                	callq  *%rax
  800fdc:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800fdf:	4c 89 ee             	mov    %r13,%rsi
  800fe2:	4c 89 f7             	mov    %r14,%rdi
  800fe5:	48 b8 4a 0d 80 00 00 	movabs $0x800d4a,%rax
  800fec:	00 00 00 
  800fef:	ff d0                	callq  *%rax
  800ff1:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800ff4:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800ff8:	4d 39 e5             	cmp    %r12,%r13
  800ffb:	74 26                	je     801023 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800ffd:	4c 89 e8             	mov    %r13,%rax
  801000:	4c 29 e0             	sub    %r12,%rax
  801003:	48 39 d8             	cmp    %rbx,%rax
  801006:	76 2a                	jbe    801032 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801008:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  80100c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801010:	4c 89 fe             	mov    %r15,%rsi
  801013:	48 b8 a1 0f 80 00 00 	movabs $0x800fa1,%rax
  80101a:	00 00 00 
  80101d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80101f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801023:	48 83 c4 08          	add    $0x8,%rsp
  801027:	5b                   	pop    %rbx
  801028:	41 5c                	pop    %r12
  80102a:	41 5d                	pop    %r13
  80102c:	41 5e                	pop    %r14
  80102e:	41 5f                	pop    %r15
  801030:	5d                   	pop    %rbp
  801031:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801032:	49 83 ed 01          	sub    $0x1,%r13
  801036:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80103a:	4c 89 ea             	mov    %r13,%rdx
  80103d:	4c 89 fe             	mov    %r15,%rsi
  801040:	48 b8 a1 0f 80 00 00 	movabs $0x800fa1,%rax
  801047:	00 00 00 
  80104a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80104c:	4d 01 ee             	add    %r13,%r14
  80104f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801054:	eb c9                	jmp    80101f <strlcat+0x6c>

0000000000801056 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801056:	48 85 d2             	test   %rdx,%rdx
  801059:	74 3a                	je     801095 <memcmp+0x3f>
    if (*s1 != *s2)
  80105b:	0f b6 0f             	movzbl (%rdi),%ecx
  80105e:	44 0f b6 06          	movzbl (%rsi),%r8d
  801062:	44 38 c1             	cmp    %r8b,%cl
  801065:	75 1d                	jne    801084 <memcmp+0x2e>
  801067:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80106c:	48 39 d0             	cmp    %rdx,%rax
  80106f:	74 1e                	je     80108f <memcmp+0x39>
    if (*s1 != *s2)
  801071:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801075:	48 83 c0 01          	add    $0x1,%rax
  801079:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  80107f:	44 38 c1             	cmp    %r8b,%cl
  801082:	74 e8                	je     80106c <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801084:	0f b6 c1             	movzbl %cl,%eax
  801087:	45 0f b6 c0          	movzbl %r8b,%r8d
  80108b:	44 29 c0             	sub    %r8d,%eax
  80108e:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80108f:	b8 00 00 00 00       	mov    $0x0,%eax
  801094:	c3                   	retq   
  801095:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80109a:	c3                   	retq   

000000000080109b <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80109b:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80109f:	48 39 c7             	cmp    %rax,%rdi
  8010a2:	73 19                	jae    8010bd <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010a4:	89 f2                	mov    %esi,%edx
  8010a6:	40 38 37             	cmp    %sil,(%rdi)
  8010a9:	74 16                	je     8010c1 <memfind+0x26>
  for (; s < ends; s++)
  8010ab:	48 83 c7 01          	add    $0x1,%rdi
  8010af:	48 39 f8             	cmp    %rdi,%rax
  8010b2:	74 08                	je     8010bc <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8010b4:	38 17                	cmp    %dl,(%rdi)
  8010b6:	75 f3                	jne    8010ab <memfind+0x10>
  for (; s < ends; s++)
  8010b8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8010bb:	c3                   	retq   
  8010bc:	c3                   	retq   
  for (; s < ends; s++)
  8010bd:	48 89 f8             	mov    %rdi,%rax
  8010c0:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8010c1:	48 89 f8             	mov    %rdi,%rax
  8010c4:	c3                   	retq   

00000000008010c5 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8010c5:	0f b6 07             	movzbl (%rdi),%eax
  8010c8:	3c 20                	cmp    $0x20,%al
  8010ca:	74 04                	je     8010d0 <strtol+0xb>
  8010cc:	3c 09                	cmp    $0x9,%al
  8010ce:	75 0f                	jne    8010df <strtol+0x1a>
    s++;
  8010d0:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  8010d4:	0f b6 07             	movzbl (%rdi),%eax
  8010d7:	3c 20                	cmp    $0x20,%al
  8010d9:	74 f5                	je     8010d0 <strtol+0xb>
  8010db:	3c 09                	cmp    $0x9,%al
  8010dd:	74 f1                	je     8010d0 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010df:	3c 2b                	cmp    $0x2b,%al
  8010e1:	74 2b                	je     80110e <strtol+0x49>
  int neg  = 0;
  8010e3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010e9:	3c 2d                	cmp    $0x2d,%al
  8010eb:	74 2d                	je     80111a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ed:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010f3:	75 0f                	jne    801104 <strtol+0x3f>
  8010f5:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010f8:	74 2c                	je     801126 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010fa:	85 d2                	test   %edx,%edx
  8010fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  801101:	0f 44 d0             	cmove  %eax,%edx
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801109:	4c 63 d2             	movslq %edx,%r10
  80110c:	eb 5c                	jmp    80116a <strtol+0xa5>
    s++;
  80110e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801112:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801118:	eb d3                	jmp    8010ed <strtol+0x28>
    s++, neg = 1;
  80111a:	48 83 c7 01          	add    $0x1,%rdi
  80111e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801124:	eb c7                	jmp    8010ed <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801126:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80112a:	74 0f                	je     80113b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80112c:	85 d2                	test   %edx,%edx
  80112e:	75 d4                	jne    801104 <strtol+0x3f>
    s++, base = 8;
  801130:	48 83 c7 01          	add    $0x1,%rdi
  801134:	ba 08 00 00 00       	mov    $0x8,%edx
  801139:	eb c9                	jmp    801104 <strtol+0x3f>
    s += 2, base = 16;
  80113b:	48 83 c7 02          	add    $0x2,%rdi
  80113f:	ba 10 00 00 00       	mov    $0x10,%edx
  801144:	eb be                	jmp    801104 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801146:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80114a:	41 80 f8 19          	cmp    $0x19,%r8b
  80114e:	77 2f                	ja     80117f <strtol+0xba>
      dig = *s - 'a' + 10;
  801150:	44 0f be c1          	movsbl %cl,%r8d
  801154:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801158:	39 d1                	cmp    %edx,%ecx
  80115a:	7d 37                	jge    801193 <strtol+0xce>
    s++, val = (val * base) + dig;
  80115c:	48 83 c7 01          	add    $0x1,%rdi
  801160:	49 0f af c2          	imul   %r10,%rax
  801164:	48 63 c9             	movslq %ecx,%rcx
  801167:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80116a:	0f b6 0f             	movzbl (%rdi),%ecx
  80116d:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801171:	41 80 f8 09          	cmp    $0x9,%r8b
  801175:	77 cf                	ja     801146 <strtol+0x81>
      dig = *s - '0';
  801177:	0f be c9             	movsbl %cl,%ecx
  80117a:	83 e9 30             	sub    $0x30,%ecx
  80117d:	eb d9                	jmp    801158 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80117f:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801183:	41 80 f8 19          	cmp    $0x19,%r8b
  801187:	77 0a                	ja     801193 <strtol+0xce>
      dig = *s - 'A' + 10;
  801189:	44 0f be c1          	movsbl %cl,%r8d
  80118d:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801191:	eb c5                	jmp    801158 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801193:	48 85 f6             	test   %rsi,%rsi
  801196:	74 03                	je     80119b <strtol+0xd6>
    *endptr = (char *)s;
  801198:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80119b:	48 89 c2             	mov    %rax,%rdx
  80119e:	48 f7 da             	neg    %rdx
  8011a1:	45 85 c9             	test   %r9d,%r9d
  8011a4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8011a8:	c3                   	retq   

00000000008011a9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8011a9:	55                   	push   %rbp
  8011aa:	48 89 e5             	mov    %rsp,%rbp
  8011ad:	53                   	push   %rbx
  8011ae:	48 89 fa             	mov    %rdi,%rdx
  8011b1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b9:	48 89 c3             	mov    %rax,%rbx
  8011bc:	48 89 c7             	mov    %rax,%rdi
  8011bf:	48 89 c6             	mov    %rax,%rsi
  8011c2:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8011c4:	5b                   	pop    %rbx
  8011c5:	5d                   	pop    %rbp
  8011c6:	c3                   	retq   

00000000008011c7 <sys_cgetc>:

int
sys_cgetc(void) {
  8011c7:	55                   	push   %rbp
  8011c8:	48 89 e5             	mov    %rsp,%rbp
  8011cb:	53                   	push   %rbx
  asm volatile("int %1\n"
  8011cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d6:	48 89 ca             	mov    %rcx,%rdx
  8011d9:	48 89 cb             	mov    %rcx,%rbx
  8011dc:	48 89 cf             	mov    %rcx,%rdi
  8011df:	48 89 ce             	mov    %rcx,%rsi
  8011e2:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011e4:	5b                   	pop    %rbx
  8011e5:	5d                   	pop    %rbp
  8011e6:	c3                   	retq   

00000000008011e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8011e7:	55                   	push   %rbp
  8011e8:	48 89 e5             	mov    %rsp,%rbp
  8011eb:	53                   	push   %rbx
  8011ec:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8011f0:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8011f3:	be 00 00 00 00       	mov    $0x0,%esi
  8011f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8011fd:	48 89 f1             	mov    %rsi,%rcx
  801200:	48 89 f3             	mov    %rsi,%rbx
  801203:	48 89 f7             	mov    %rsi,%rdi
  801206:	cd 30                	int    $0x30
  if (check && ret > 0)
  801208:	48 85 c0             	test   %rax,%rax
  80120b:	7f 07                	jg     801214 <sys_env_destroy+0x2d>
}
  80120d:	48 83 c4 08          	add    $0x8,%rsp
  801211:	5b                   	pop    %rbx
  801212:	5d                   	pop    %rbp
  801213:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801214:	49 89 c0             	mov    %rax,%r8
  801217:	b9 03 00 00 00       	mov    $0x3,%ecx
  80121c:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  801223:	00 00 00 
  801226:	be 22 00 00 00       	mov    $0x22,%esi
  80122b:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  801232:	00 00 00 
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  801241:	00 00 00 
  801244:	41 ff d1             	callq  *%r9

0000000000801247 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801247:	55                   	push   %rbp
  801248:	48 89 e5             	mov    %rsp,%rbp
  80124b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80124c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801251:	b8 02 00 00 00       	mov    $0x2,%eax
  801256:	48 89 ca             	mov    %rcx,%rdx
  801259:	48 89 cb             	mov    %rcx,%rbx
  80125c:	48 89 cf             	mov    %rcx,%rdi
  80125f:	48 89 ce             	mov    %rcx,%rsi
  801262:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801264:	5b                   	pop    %rbx
  801265:	5d                   	pop    %rbp
  801266:	c3                   	retq   

0000000000801267 <sys_yield>:

void
sys_yield(void) {
  801267:	55                   	push   %rbp
  801268:	48 89 e5             	mov    %rsp,%rbp
  80126b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80126c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801271:	b8 0a 00 00 00       	mov    $0xa,%eax
  801276:	48 89 ca             	mov    %rcx,%rdx
  801279:	48 89 cb             	mov    %rcx,%rbx
  80127c:	48 89 cf             	mov    %rcx,%rdi
  80127f:	48 89 ce             	mov    %rcx,%rsi
  801282:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801284:	5b                   	pop    %rbx
  801285:	5d                   	pop    %rbp
  801286:	c3                   	retq   

0000000000801287 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  801287:	55                   	push   %rbp
  801288:	48 89 e5             	mov    %rsp,%rbp
  80128b:	53                   	push   %rbx
  80128c:	48 83 ec 08          	sub    $0x8,%rsp
  801290:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801293:	4c 63 c7             	movslq %edi,%r8
  801296:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  801299:	be 00 00 00 00       	mov    $0x0,%esi
  80129e:	b8 04 00 00 00       	mov    $0x4,%eax
  8012a3:	4c 89 c2             	mov    %r8,%rdx
  8012a6:	48 89 f7             	mov    %rsi,%rdi
  8012a9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012ab:	48 85 c0             	test   %rax,%rax
  8012ae:	7f 07                	jg     8012b7 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8012b0:	48 83 c4 08          	add    $0x8,%rsp
  8012b4:	5b                   	pop    %rbx
  8012b5:	5d                   	pop    %rbp
  8012b6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012b7:	49 89 c0             	mov    %rax,%r8
  8012ba:	b9 04 00 00 00       	mov    $0x4,%ecx
  8012bf:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  8012c6:	00 00 00 
  8012c9:	be 22 00 00 00       	mov    $0x22,%esi
  8012ce:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  8012d5:	00 00 00 
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dd:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  8012e4:	00 00 00 
  8012e7:	41 ff d1             	callq  *%r9

00000000008012ea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8012ea:	55                   	push   %rbp
  8012eb:	48 89 e5             	mov    %rsp,%rbp
  8012ee:	53                   	push   %rbx
  8012ef:	48 83 ec 08          	sub    $0x8,%rsp
  8012f3:	41 89 f9             	mov    %edi,%r9d
  8012f6:	49 89 f2             	mov    %rsi,%r10
  8012f9:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8012fc:	4d 63 c9             	movslq %r9d,%r9
  8012ff:	48 63 da             	movslq %edx,%rbx
  801302:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801305:	b8 05 00 00 00       	mov    $0x5,%eax
  80130a:	4c 89 ca             	mov    %r9,%rdx
  80130d:	4c 89 d1             	mov    %r10,%rcx
  801310:	cd 30                	int    $0x30
  if (check && ret > 0)
  801312:	48 85 c0             	test   %rax,%rax
  801315:	7f 07                	jg     80131e <sys_page_map+0x34>
}
  801317:	48 83 c4 08          	add    $0x8,%rsp
  80131b:	5b                   	pop    %rbx
  80131c:	5d                   	pop    %rbp
  80131d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80131e:	49 89 c0             	mov    %rax,%r8
  801321:	b9 05 00 00 00       	mov    $0x5,%ecx
  801326:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  80132d:	00 00 00 
  801330:	be 22 00 00 00       	mov    $0x22,%esi
  801335:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  80133c:	00 00 00 
  80133f:	b8 00 00 00 00       	mov    $0x0,%eax
  801344:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  80134b:	00 00 00 
  80134e:	41 ff d1             	callq  *%r9

0000000000801351 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801351:	55                   	push   %rbp
  801352:	48 89 e5             	mov    %rsp,%rbp
  801355:	53                   	push   %rbx
  801356:	48 83 ec 08          	sub    $0x8,%rsp
  80135a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  80135d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801360:	be 00 00 00 00       	mov    $0x0,%esi
  801365:	b8 06 00 00 00       	mov    $0x6,%eax
  80136a:	48 89 f3             	mov    %rsi,%rbx
  80136d:	48 89 f7             	mov    %rsi,%rdi
  801370:	cd 30                	int    $0x30
  if (check && ret > 0)
  801372:	48 85 c0             	test   %rax,%rax
  801375:	7f 07                	jg     80137e <sys_page_unmap+0x2d>
}
  801377:	48 83 c4 08          	add    $0x8,%rsp
  80137b:	5b                   	pop    %rbx
  80137c:	5d                   	pop    %rbp
  80137d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80137e:	49 89 c0             	mov    %rax,%r8
  801381:	b9 06 00 00 00       	mov    $0x6,%ecx
  801386:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  80138d:	00 00 00 
  801390:	be 22 00 00 00       	mov    $0x22,%esi
  801395:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  80139c:	00 00 00 
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a4:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  8013ab:	00 00 00 
  8013ae:	41 ff d1             	callq  *%r9

00000000008013b1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8013b1:	55                   	push   %rbp
  8013b2:	48 89 e5             	mov    %rsp,%rbp
  8013b5:	53                   	push   %rbx
  8013b6:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8013ba:	48 63 d7             	movslq %edi,%rdx
  8013bd:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8013c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8013ca:	48 89 df             	mov    %rbx,%rdi
  8013cd:	48 89 de             	mov    %rbx,%rsi
  8013d0:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013d2:	48 85 c0             	test   %rax,%rax
  8013d5:	7f 07                	jg     8013de <sys_env_set_status+0x2d>
}
  8013d7:	48 83 c4 08          	add    $0x8,%rsp
  8013db:	5b                   	pop    %rbx
  8013dc:	5d                   	pop    %rbp
  8013dd:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013de:	49 89 c0             	mov    %rax,%r8
  8013e1:	b9 08 00 00 00       	mov    $0x8,%ecx
  8013e6:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  8013ed:	00 00 00 
  8013f0:	be 22 00 00 00       	mov    $0x22,%esi
  8013f5:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  8013fc:	00 00 00 
  8013ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801404:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  80140b:	00 00 00 
  80140e:	41 ff d1             	callq  *%r9

0000000000801411 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801411:	55                   	push   %rbp
  801412:	48 89 e5             	mov    %rsp,%rbp
  801415:	53                   	push   %rbx
  801416:	48 83 ec 08          	sub    $0x8,%rsp
  80141a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80141d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801420:	be 00 00 00 00       	mov    $0x0,%esi
  801425:	b8 09 00 00 00       	mov    $0x9,%eax
  80142a:	48 89 f3             	mov    %rsi,%rbx
  80142d:	48 89 f7             	mov    %rsi,%rdi
  801430:	cd 30                	int    $0x30
  if (check && ret > 0)
  801432:	48 85 c0             	test   %rax,%rax
  801435:	7f 07                	jg     80143e <sys_env_set_pgfault_upcall+0x2d>
}
  801437:	48 83 c4 08          	add    $0x8,%rsp
  80143b:	5b                   	pop    %rbx
  80143c:	5d                   	pop    %rbp
  80143d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80143e:	49 89 c0             	mov    %rax,%r8
  801441:	b9 09 00 00 00       	mov    $0x9,%ecx
  801446:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  80144d:	00 00 00 
  801450:	be 22 00 00 00       	mov    $0x22,%esi
  801455:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  80145c:	00 00 00 
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
  801464:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  80146b:	00 00 00 
  80146e:	41 ff d1             	callq  *%r9

0000000000801471 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801471:	55                   	push   %rbp
  801472:	48 89 e5             	mov    %rsp,%rbp
  801475:	53                   	push   %rbx
  801476:	49 89 f0             	mov    %rsi,%r8
  801479:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  80147c:	48 63 d7             	movslq %edi,%rdx
  80147f:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801482:	b8 0b 00 00 00       	mov    $0xb,%eax
  801487:	be 00 00 00 00       	mov    $0x0,%esi
  80148c:	4c 89 c1             	mov    %r8,%rcx
  80148f:	cd 30                	int    $0x30
}
  801491:	5b                   	pop    %rbx
  801492:	5d                   	pop    %rbp
  801493:	c3                   	retq   

0000000000801494 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801494:	55                   	push   %rbp
  801495:	48 89 e5             	mov    %rsp,%rbp
  801498:	53                   	push   %rbx
  801499:	48 83 ec 08          	sub    $0x8,%rsp
  80149d:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8014a0:	be 00 00 00 00       	mov    $0x0,%esi
  8014a5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014aa:	48 89 f1             	mov    %rsi,%rcx
  8014ad:	48 89 f3             	mov    %rsi,%rbx
  8014b0:	48 89 f7             	mov    %rsi,%rdi
  8014b3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8014b5:	48 85 c0             	test   %rax,%rax
  8014b8:	7f 07                	jg     8014c1 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8014ba:	48 83 c4 08          	add    $0x8,%rsp
  8014be:	5b                   	pop    %rbx
  8014bf:	5d                   	pop    %rbp
  8014c0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8014c1:	49 89 c0             	mov    %rax,%r8
  8014c4:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8014c9:	48 ba 00 1f 80 00 00 	movabs $0x801f00,%rdx
  8014d0:	00 00 00 
  8014d3:	be 22 00 00 00       	mov    $0x22,%esi
  8014d8:	48 bf 1f 1f 80 00 00 	movabs $0x801f1f,%rdi
  8014df:	00 00 00 
  8014e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e7:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  8014ee:	00 00 00 
  8014f1:	41 ff d1             	callq  *%r9

00000000008014f4 <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  8014f4:	55                   	push   %rbp
  8014f5:	48 89 e5             	mov    %rsp,%rbp
  8014f8:	53                   	push   %rbx
  8014f9:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  8014fd:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  801500:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  801504:	41 f6 c0 02          	test   $0x2,%r8b
  801508:	0f 84 b2 00 00 00    	je     8015c0 <pgfault+0xcc>
  80150e:	48 89 da             	mov    %rbx,%rdx
  801511:	48 c1 ea 0c          	shr    $0xc,%rdx
  801515:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80151c:	01 00 00 
  80151f:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801523:	f6 c4 08             	test   $0x8,%ah
  801526:	0f 84 94 00 00 00    	je     8015c0 <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  80152c:	ba 02 00 00 00       	mov    $0x2,%edx
  801531:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801536:	bf 00 00 00 00       	mov    $0x0,%edi
  80153b:	48 b8 87 12 80 00 00 	movabs $0x801287,%rax
  801542:	00 00 00 
  801545:	ff d0                	callq  *%rax
  801547:	85 c0                	test   %eax,%eax
  801549:	0f 88 9f 00 00 00    	js     8015ee <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80154f:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  801556:	ba 00 10 00 00       	mov    $0x1000,%edx
  80155b:	48 89 de             	mov    %rbx,%rsi
  80155e:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  801563:	48 b8 33 0f 80 00 00 	movabs $0x800f33,%rax
  80156a:	00 00 00 
  80156d:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  80156f:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  801575:	48 89 d9             	mov    %rbx,%rcx
  801578:	ba 00 00 00 00       	mov    $0x0,%edx
  80157d:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801582:	bf 00 00 00 00       	mov    $0x0,%edi
  801587:	48 b8 ea 12 80 00 00 	movabs $0x8012ea,%rax
  80158e:	00 00 00 
  801591:	ff d0                	callq  *%rax
  801593:	85 c0                	test   %eax,%eax
  801595:	0f 88 80 00 00 00    	js     80161b <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  80159b:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8015a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8015a5:	48 b8 51 13 80 00 00 	movabs $0x801351,%rax
  8015ac:	00 00 00 
  8015af:	ff d0                	callq  *%rax
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	0f 88 8f 00 00 00    	js     801648 <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  8015b9:	48 83 c4 08          	add    $0x8,%rsp
  8015bd:	5b                   	pop    %rbx
  8015be:	5d                   	pop    %rbp
  8015bf:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  8015c0:	48 89 d9             	mov    %rbx,%rcx
  8015c3:	48 ba 30 1f 80 00 00 	movabs $0x801f30,%rdx
  8015ca:	00 00 00 
  8015cd:	be 21 00 00 00       	mov    $0x21,%esi
  8015d2:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  8015d9:	00 00 00 
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e1:	49 b9 13 02 80 00 00 	movabs $0x800213,%r9
  8015e8:	00 00 00 
  8015eb:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  8015ee:	89 c1                	mov    %eax,%ecx
  8015f0:	48 ba 60 1f 80 00 00 	movabs $0x801f60,%rdx
  8015f7:	00 00 00 
  8015fa:	be 2f 00 00 00       	mov    $0x2f,%esi
  8015ff:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  801606:	00 00 00 
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
  80160e:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  801615:	00 00 00 
  801618:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  80161b:	89 c1                	mov    %eax,%ecx
  80161d:	48 ba 88 1f 80 00 00 	movabs $0x801f88,%rdx
  801624:	00 00 00 
  801627:	be 39 00 00 00       	mov    $0x39,%esi
  80162c:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  801633:	00 00 00 
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
  80163b:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  801642:	00 00 00 
  801645:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  801648:	89 c1                	mov    %eax,%ecx
  80164a:	48 ba b0 1f 80 00 00 	movabs $0x801fb0,%rdx
  801651:	00 00 00 
  801654:	be 3d 00 00 00       	mov    $0x3d,%esi
  801659:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  801660:	00 00 00 
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
  801668:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  80166f:	00 00 00 
  801672:	41 ff d0             	callq  *%r8

0000000000801675 <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  801675:	55                   	push   %rbp
  801676:	48 89 e5             	mov    %rsp,%rbp
  801679:	41 57                	push   %r15
  80167b:	41 56                	push   %r14
  80167d:	41 55                	push   %r13
  80167f:	41 54                	push   %r12
  801681:	53                   	push   %rbx
  801682:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  801686:	48 bf f4 14 80 00 00 	movabs $0x8014f4,%rdi
  80168d:	00 00 00 
  801690:	48 b8 b3 19 80 00 00 	movabs $0x8019b3,%rax
  801697:	00 00 00 
  80169a:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  80169c:	b8 07 00 00 00       	mov    $0x7,%eax
  8016a1:	cd 30                	int    $0x30
  8016a3:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  8016a6:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 38                	js     8016e5 <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  8016ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8016b6:	74 5a                	je     801712 <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8016b8:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  8016bf:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8016c2:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8016c9:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8016cc:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  8016d3:	01 00 00 
  8016d6:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  8016dd:	01 00 00 
  8016e0:	e9 2c 01 00 00       	jmpq   801811 <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  8016e5:	89 c1                	mov    %eax,%ecx
  8016e7:	48 ba 5b 20 80 00 00 	movabs $0x80205b,%rdx
  8016ee:	00 00 00 
  8016f1:	be 82 00 00 00       	mov    $0x82,%esi
  8016f6:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  8016fd:	00 00 00 
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
  801705:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  80170c:	00 00 00 
  80170f:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  801712:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  801719:	00 00 00 
  80171c:	ff d0                	callq  *%rax
  80171e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801723:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  801727:	48 c1 e0 05          	shl    $0x5,%rax
  80172b:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  801732:	00 00 00 
  801735:	48 01 d0             	add    %rdx,%rax
  801738:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  80173f:	00 00 00 
		return 0;
  801742:	e9 9d 01 00 00       	jmpq   8018e4 <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  801747:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80174e:	01 00 00 
  801751:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801755:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  801759:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  801760:	00 00 00 
  801763:	ff d0                	callq  *%rax
  801765:	89 c7                	mov    %eax,%edi
  801767:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  80176a:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80176e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801774:	74 57                	je     8017cd <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  801776:	81 e2 05 06 00 00    	and    $0x605,%edx
  80177c:	48 89 d0             	mov    %rdx,%rax
  80177f:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801782:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  801786:	48 c1 e6 0c          	shl    $0xc,%rsi
  80178a:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80178e:	41 89 c0             	mov    %eax,%r8d
  801791:	48 89 f1             	mov    %rsi,%rcx
  801794:	8b 55 c0             	mov    -0x40(%rbp),%edx
  801797:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  80179b:	48 b8 ea 12 80 00 00 	movabs $0x8012ea,%rax
  8017a2:	00 00 00 
  8017a5:	ff d0                	callq  *%rax
    if (r < 0) {
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	0f 88 ce 01 00 00    	js     80197d <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  8017af:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8017b3:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8017b7:	48 89 f1             	mov    %rsi,%rcx
  8017ba:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8017bd:	89 fa                	mov    %edi,%edx
  8017bf:	48 b8 ea 12 80 00 00 	movabs $0x8012ea,%rax
  8017c6:	00 00 00 
  8017c9:	ff d0                	callq  *%rax
  8017cb:	eb 28                	jmp    8017f5 <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8017cd:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8017d1:	48 c1 e6 0c          	shl    $0xc,%rsi
  8017d5:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8017d9:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  8017e0:	48 89 f1             	mov    %rsi,%rcx
  8017e3:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8017e6:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8017e9:	48 b8 ea 12 80 00 00 	movabs $0x8012ea,%rax
  8017f0:	00 00 00 
  8017f3:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	0f 89 80 00 00 00    	jns    80187d <fork+0x208>
  8017fd:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801800:	e9 df 00 00 00       	jmpq   8018e4 <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801805:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  80180c:	4c 39 eb             	cmp    %r13,%rbx
  80180f:	74 75                	je     801886 <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801811:	48 89 d8             	mov    %rbx,%rax
  801814:	48 c1 e8 27          	shr    $0x27,%rax
  801818:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  80181c:	a8 01                	test   $0x1,%al
  80181e:	74 e5                	je     801805 <fork+0x190>
  801820:	48 89 d8             	mov    %rbx,%rax
  801823:	48 c1 e8 1e          	shr    $0x1e,%rax
  801827:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  80182b:	a8 01                	test   $0x1,%al
  80182d:	74 d6                	je     801805 <fork+0x190>
  80182f:	48 89 d8             	mov    %rbx,%rax
  801832:	48 c1 e8 15          	shr    $0x15,%rax
  801836:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  80183a:	a8 01                	test   $0x1,%al
  80183c:	74 c7                	je     801805 <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  80183e:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  801845:	00 00 00 
  801848:	48 39 c3             	cmp    %rax,%rbx
  80184b:	77 b8                	ja     801805 <fork+0x190>
  80184d:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  801854:	48 39 c3             	cmp    %rax,%rbx
  801857:	74 ac                	je     801805 <fork+0x190>
  801859:	48 89 d8             	mov    %rbx,%rax
  80185c:	48 c1 e8 0c          	shr    $0xc,%rax
  801860:	48 89 c1             	mov    %rax,%rcx
  801863:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  801867:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80186e:	01 00 00 
  801871:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801875:	a8 01                	test   $0x1,%al
  801877:	0f 85 ca fe ff ff    	jne    801747 <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  80187d:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801884:	eb 8b                	jmp    801811 <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  801886:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  80188d:	00 00 00 
  801890:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  801897:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  80189a:	48 b8 11 14 80 00 00 	movabs $0x801411,%rax
  8018a1:	00 00 00 
  8018a4:	ff d0                	callq  *%rax
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 4c                	js     8018f6 <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  8018aa:	ba 02 00 00 00       	mov    $0x2,%edx
  8018af:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8018b6:	00 00 00 
  8018b9:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8018bc:	48 b8 87 12 80 00 00 	movabs $0x801287,%rax
  8018c3:	00 00 00 
  8018c6:	ff d0                	callq  *%rax
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 57                	js     801923 <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  8018cc:	be 02 00 00 00       	mov    $0x2,%esi
  8018d1:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  8018d4:	48 b8 b1 13 80 00 00 	movabs $0x8013b1,%rax
  8018db:	00 00 00 
  8018de:	ff d0                	callq  *%rax
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 6c                	js     801950 <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  8018e4:	8b 45 c0             	mov    -0x40(%rbp),%eax
  8018e7:	48 83 c4 28          	add    $0x28,%rsp
  8018eb:	5b                   	pop    %rbx
  8018ec:	41 5c                	pop    %r12
  8018ee:	41 5d                	pop    %r13
  8018f0:	41 5e                	pop    %r14
  8018f2:	41 5f                	pop    %r15
  8018f4:	5d                   	pop    %rbp
  8018f5:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  8018f6:	89 c1                	mov    %eax,%ecx
  8018f8:	48 ba d8 1f 80 00 00 	movabs $0x801fd8,%rdx
  8018ff:	00 00 00 
  801902:	be a7 00 00 00       	mov    $0xa7,%esi
  801907:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  80190e:	00 00 00 
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
  801916:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  80191d:	00 00 00 
  801920:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  801923:	89 c1                	mov    %eax,%ecx
  801925:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80192c:	00 00 00 
  80192f:	be aa 00 00 00       	mov    $0xaa,%esi
  801934:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  80193b:	00 00 00 
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
  801943:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  80194a:	00 00 00 
  80194d:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  801950:	89 c1                	mov    %eax,%ecx
  801952:	48 ba 28 20 80 00 00 	movabs $0x802028,%rdx
  801959:	00 00 00 
  80195c:	be bd 00 00 00       	mov    $0xbd,%esi
  801961:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  801968:	00 00 00 
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
  801970:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  801977:	00 00 00 
  80197a:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  80197d:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801980:	e9 5f ff ff ff       	jmpq   8018e4 <fork+0x26f>

0000000000801985 <sfork>:

// Challenge!
int
sfork(void) {
  801985:	55                   	push   %rbp
  801986:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  801989:	48 ba 6b 20 80 00 00 	movabs $0x80206b,%rdx
  801990:	00 00 00 
  801993:	be c9 00 00 00       	mov    $0xc9,%esi
  801998:	48 bf 50 20 80 00 00 	movabs $0x802050,%rdi
  80199f:	00 00 00 
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a7:	48 b9 13 02 80 00 00 	movabs $0x800213,%rcx
  8019ae:	00 00 00 
  8019b1:	ff d1                	callq  *%rcx

00000000008019b3 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  8019b3:	55                   	push   %rbp
  8019b4:	48 89 e5             	mov    %rsp,%rbp
  8019b7:	41 54                	push   %r12
  8019b9:	53                   	push   %rbx
  8019ba:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  8019bd:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  8019c4:	00 00 00 
  8019c7:	ff d0                	callq  *%rax
  8019c9:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  8019cb:	48 b8 18 30 80 00 00 	movabs $0x803018,%rax
  8019d2:	00 00 00 
  8019d5:	48 83 38 00          	cmpq   $0x0,(%rax)
  8019d9:	74 2e                	je     801a09 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  8019db:	4c 89 e0             	mov    %r12,%rax
  8019de:	48 a3 18 30 80 00 00 	movabs %rax,0x803018
  8019e5:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8019e8:	48 be 55 1a 80 00 00 	movabs $0x801a55,%rsi
  8019ef:	00 00 00 
  8019f2:	89 df                	mov    %ebx,%edi
  8019f4:	48 b8 11 14 80 00 00 	movabs $0x801411,%rax
  8019fb:	00 00 00 
  8019fe:	ff d0                	callq  *%rax
  if (error < 0)
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 24                	js     801a28 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801a04:	5b                   	pop    %rbx
  801a05:	41 5c                	pop    %r12
  801a07:	5d                   	pop    %rbp
  801a08:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  801a09:	ba 02 00 00 00       	mov    $0x2,%edx
  801a0e:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801a15:	00 00 00 
  801a18:	89 df                	mov    %ebx,%edi
  801a1a:	48 b8 87 12 80 00 00 	movabs $0x801287,%rax
  801a21:	00 00 00 
  801a24:	ff d0                	callq  *%rax
  801a26:	eb b3                	jmp    8019db <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801a28:	89 c1                	mov    %eax,%ecx
  801a2a:	48 ba 81 20 80 00 00 	movabs $0x802081,%rdx
  801a31:	00 00 00 
  801a34:	be 2c 00 00 00       	mov    $0x2c,%esi
  801a39:	48 bf 99 20 80 00 00 	movabs $0x802099,%rdi
  801a40:	00 00 00 
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	49 b8 13 02 80 00 00 	movabs $0x800213,%r8
  801a4f:	00 00 00 
  801a52:	41 ff d0             	callq  *%r8

0000000000801a55 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801a55:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801a58:	48 a1 18 30 80 00 00 	movabs 0x803018,%rax
  801a5f:	00 00 00 
	call *%rax
  801a62:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801a64:	41 5f                	pop    %r15
	popq %r15
  801a66:	41 5f                	pop    %r15
	popq %r15
  801a68:	41 5f                	pop    %r15
	popq %r14
  801a6a:	41 5e                	pop    %r14
	popq %r13
  801a6c:	41 5d                	pop    %r13
	popq %r12
  801a6e:	41 5c                	pop    %r12
	popq %r11
  801a70:	41 5b                	pop    %r11
	popq %r10
  801a72:	41 5a                	pop    %r10
	popq %r9
  801a74:	41 59                	pop    %r9
	popq %r8
  801a76:	41 58                	pop    %r8
	popq %rsi
  801a78:	5e                   	pop    %rsi
	popq %rdi
  801a79:	5f                   	pop    %rdi
	popq %rbp
  801a7a:	5d                   	pop    %rbp
	popq %rdx
  801a7b:	5a                   	pop    %rdx
	popq %rcx
  801a7c:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801a7d:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801a82:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801a87:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801a8b:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801a8e:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801a93:	5b                   	pop    %rbx
	popq %rax
  801a94:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801a95:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801a99:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801a9a:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801a9f:	c3                   	retq   
