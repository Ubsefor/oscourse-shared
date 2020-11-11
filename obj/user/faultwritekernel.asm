
obj/user/faultwritekernel:     file format elf64-x86-64


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
  800023:	e8 13 00 00 00       	callq  80003b <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  *(volatile unsigned *)0x8040000000 = 0;
  80002a:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  800031:	00 00 00 
  800034:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
}
  80003a:	c3                   	retq   

000000000080003b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80003b:	55                   	push   %rbp
  80003c:	48 89 e5             	mov    %rsp,%rbp
  80003f:	41 56                	push   %r14
  800041:	41 55                	push   %r13
  800043:	41 54                	push   %r12
  800045:	53                   	push   %rbx
  800046:	41 89 fd             	mov    %edi,%r13d
  800049:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80004c:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800053:	00 00 00 
  800056:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80005d:	00 00 00 
  800060:	48 39 c2             	cmp    %rax,%rdx
  800063:	73 23                	jae    800088 <libmain+0x4d>
  800065:	48 89 d3             	mov    %rdx,%rbx
  800068:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80006c:	48 29 d0             	sub    %rdx,%rax
  80006f:	48 c1 e8 03          	shr    $0x3,%rax
  800073:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800078:	b8 00 00 00 00       	mov    $0x0,%eax
  80007d:	ff 13                	callq  *(%rbx)
    ctor++;
  80007f:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800083:	4c 39 e3             	cmp    %r12,%rbx
  800086:	75 f0                	jne    800078 <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800088:	45 85 ed             	test   %r13d,%r13d
  80008b:	7e 0d                	jle    80009a <libmain+0x5f>
    binaryname = argv[0];
  80008d:	49 8b 06             	mov    (%r14),%rax
  800090:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800097:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80009a:	4c 89 f6             	mov    %r14,%rsi
  80009d:	44 89 ef             	mov    %r13d,%edi
  8000a0:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000a7:	00 00 00 
  8000aa:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000ac:	48 b8 c1 00 80 00 00 	movabs $0x8000c1,%rax
  8000b3:	00 00 00 
  8000b6:	ff d0                	callq  *%rax
#endif
}
  8000b8:	5b                   	pop    %rbx
  8000b9:	41 5c                	pop    %r12
  8000bb:	41 5d                	pop    %r13
  8000bd:	41 5e                	pop    %r14
  8000bf:	5d                   	pop    %rbp
  8000c0:	c3                   	retq   

00000000008000c1 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000c1:	55                   	push   %rbp
  8000c2:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8000ca:	48 b8 16 01 80 00 00 	movabs $0x800116,%rax
  8000d1:	00 00 00 
  8000d4:	ff d0                	callq  *%rax
}
  8000d6:	5d                   	pop    %rbp
  8000d7:	c3                   	retq   

00000000008000d8 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000d8:	55                   	push   %rbp
  8000d9:	48 89 e5             	mov    %rsp,%rbp
  8000dc:	53                   	push   %rbx
  8000dd:	48 89 fa             	mov    %rdi,%rdx
  8000e0:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e8:	48 89 c3             	mov    %rax,%rbx
  8000eb:	48 89 c7             	mov    %rax,%rdi
  8000ee:	48 89 c6             	mov    %rax,%rsi
  8000f1:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8000f3:	5b                   	pop    %rbx
  8000f4:	5d                   	pop    %rbp
  8000f5:	c3                   	retq   

00000000008000f6 <sys_cgetc>:

int
sys_cgetc(void) {
  8000f6:	55                   	push   %rbp
  8000f7:	48 89 e5             	mov    %rsp,%rbp
  8000fa:	53                   	push   %rbx
  asm volatile("int %1\n"
  8000fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800100:	b8 01 00 00 00       	mov    $0x1,%eax
  800105:	48 89 ca             	mov    %rcx,%rdx
  800108:	48 89 cb             	mov    %rcx,%rbx
  80010b:	48 89 cf             	mov    %rcx,%rdi
  80010e:	48 89 ce             	mov    %rcx,%rsi
  800111:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800113:	5b                   	pop    %rbx
  800114:	5d                   	pop    %rbp
  800115:	c3                   	retq   

0000000000800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800116:	55                   	push   %rbp
  800117:	48 89 e5             	mov    %rsp,%rbp
  80011a:	53                   	push   %rbx
  80011b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80011f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800122:	be 00 00 00 00       	mov    $0x0,%esi
  800127:	b8 03 00 00 00       	mov    $0x3,%eax
  80012c:	48 89 f1             	mov    %rsi,%rcx
  80012f:	48 89 f3             	mov    %rsi,%rbx
  800132:	48 89 f7             	mov    %rsi,%rdi
  800135:	cd 30                	int    $0x30
  if (check && ret > 0)
  800137:	48 85 c0             	test   %rax,%rax
  80013a:	7f 07                	jg     800143 <sys_env_destroy+0x2d>
}
  80013c:	48 83 c4 08          	add    $0x8,%rsp
  800140:	5b                   	pop    %rbx
  800141:	5d                   	pop    %rbp
  800142:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800143:	49 89 c0             	mov    %rax,%r8
  800146:	b9 03 00 00 00       	mov    $0x3,%ecx
  80014b:	48 ba 50 11 80 00 00 	movabs $0x801150,%rdx
  800152:	00 00 00 
  800155:	be 22 00 00 00       	mov    $0x22,%esi
  80015a:	48 bf 6f 11 80 00 00 	movabs $0x80116f,%rdi
  800161:	00 00 00 
  800164:	b8 00 00 00 00       	mov    $0x0,%eax
  800169:	49 b9 96 01 80 00 00 	movabs $0x800196,%r9
  800170:	00 00 00 
  800173:	41 ff d1             	callq  *%r9

0000000000800176 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800176:	55                   	push   %rbp
  800177:	48 89 e5             	mov    %rsp,%rbp
  80017a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	48 89 ca             	mov    %rcx,%rdx
  800188:	48 89 cb             	mov    %rcx,%rbx
  80018b:	48 89 cf             	mov    %rcx,%rdi
  80018e:	48 89 ce             	mov    %rcx,%rsi
  800191:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800193:	5b                   	pop    %rbx
  800194:	5d                   	pop    %rbp
  800195:	c3                   	retq   

0000000000800196 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800196:	55                   	push   %rbp
  800197:	48 89 e5             	mov    %rsp,%rbp
  80019a:	41 56                	push   %r14
  80019c:	41 55                	push   %r13
  80019e:	41 54                	push   %r12
  8001a0:	53                   	push   %rbx
  8001a1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001a8:	49 89 fd             	mov    %rdi,%r13
  8001ab:	41 89 f6             	mov    %esi,%r14d
  8001ae:	49 89 d4             	mov    %rdx,%r12
  8001b1:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001b8:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001bf:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001c6:	84 c0                	test   %al,%al
  8001c8:	74 26                	je     8001f0 <_panic+0x5a>
  8001ca:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001d1:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001d8:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001dc:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001e0:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001e4:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001e8:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001ec:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8001f0:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8001f7:	00 00 00 
  8001fa:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800201:	00 00 00 
  800204:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800208:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80020f:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800216:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80021d:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800224:	00 00 00 
  800227:	48 8b 18             	mov    (%rax),%rbx
  80022a:	48 b8 76 01 80 00 00 	movabs $0x800176,%rax
  800231:	00 00 00 
  800234:	ff d0                	callq  *%rax
  800236:	45 89 f0             	mov    %r14d,%r8d
  800239:	4c 89 e9             	mov    %r13,%rcx
  80023c:	48 89 da             	mov    %rbx,%rdx
  80023f:	89 c6                	mov    %eax,%esi
  800241:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  800248:	00 00 00 
  80024b:	b8 00 00 00 00       	mov    $0x0,%eax
  800250:	48 bb 38 03 80 00 00 	movabs $0x800338,%rbx
  800257:	00 00 00 
  80025a:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80025c:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800263:	4c 89 e7             	mov    %r12,%rdi
  800266:	48 b8 d0 02 80 00 00 	movabs $0x8002d0,%rax
  80026d:	00 00 00 
  800270:	ff d0                	callq  *%rax
  cprintf("\n");
  800272:	48 bf a8 11 80 00 00 	movabs $0x8011a8,%rdi
  800279:	00 00 00 
  80027c:	b8 00 00 00 00       	mov    $0x0,%eax
  800281:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800283:	cc                   	int3   
  while (1)
  800284:	eb fd                	jmp    800283 <_panic+0xed>

0000000000800286 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800286:	55                   	push   %rbp
  800287:	48 89 e5             	mov    %rsp,%rbp
  80028a:	53                   	push   %rbx
  80028b:	48 83 ec 08          	sub    $0x8,%rsp
  80028f:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800292:	8b 06                	mov    (%rsi),%eax
  800294:	8d 50 01             	lea    0x1(%rax),%edx
  800297:	89 16                	mov    %edx,(%rsi)
  800299:	48 98                	cltq   
  80029b:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002a0:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002a6:	74 0b                	je     8002b3 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002a8:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002ac:	48 83 c4 08          	add    $0x8,%rsp
  8002b0:	5b                   	pop    %rbx
  8002b1:	5d                   	pop    %rbp
  8002b2:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002b3:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002b7:	be ff 00 00 00       	mov    $0xff,%esi
  8002bc:	48 b8 d8 00 80 00 00 	movabs $0x8000d8,%rax
  8002c3:	00 00 00 
  8002c6:	ff d0                	callq  *%rax
    b->idx = 0;
  8002c8:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002ce:	eb d8                	jmp    8002a8 <putch+0x22>

00000000008002d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002d0:	55                   	push   %rbp
  8002d1:	48 89 e5             	mov    %rsp,%rbp
  8002d4:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002db:	48 89 fa             	mov    %rdi,%rdx
  8002de:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002e8:	00 00 00 
  b.cnt = 0;
  8002eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002f2:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8002f5:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8002fc:	48 bf 86 02 80 00 00 	movabs $0x800286,%rdi
  800303:	00 00 00 
  800306:	48 b8 f6 04 80 00 00 	movabs $0x8004f6,%rax
  80030d:	00 00 00 
  800310:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800312:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800319:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800320:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800324:	48 b8 d8 00 80 00 00 	movabs $0x8000d8,%rax
  80032b:	00 00 00 
  80032e:	ff d0                	callq  *%rax

  return b.cnt;
}
  800330:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800336:	c9                   	leaveq 
  800337:	c3                   	retq   

0000000000800338 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800338:	55                   	push   %rbp
  800339:	48 89 e5             	mov    %rsp,%rbp
  80033c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800343:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80034a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800351:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800358:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80035f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800366:	84 c0                	test   %al,%al
  800368:	74 20                	je     80038a <cprintf+0x52>
  80036a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80036e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800372:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800376:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80037a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80037e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800382:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800386:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80038a:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800391:	00 00 00 
  800394:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80039b:	00 00 00 
  80039e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003a2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003a9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003b0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003b7:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003be:	48 b8 d0 02 80 00 00 	movabs $0x8002d0,%rax
  8003c5:	00 00 00 
  8003c8:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003ca:	c9                   	leaveq 
  8003cb:	c3                   	retq   

00000000008003cc <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003cc:	55                   	push   %rbp
  8003cd:	48 89 e5             	mov    %rsp,%rbp
  8003d0:	41 57                	push   %r15
  8003d2:	41 56                	push   %r14
  8003d4:	41 55                	push   %r13
  8003d6:	41 54                	push   %r12
  8003d8:	53                   	push   %rbx
  8003d9:	48 83 ec 18          	sub    $0x18,%rsp
  8003dd:	49 89 fc             	mov    %rdi,%r12
  8003e0:	49 89 f5             	mov    %rsi,%r13
  8003e3:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003e7:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003ea:	41 89 cf             	mov    %ecx,%r15d
  8003ed:	49 39 d7             	cmp    %rdx,%r15
  8003f0:	76 45                	jbe    800437 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003f2:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8003f6:	85 db                	test   %ebx,%ebx
  8003f8:	7e 0e                	jle    800408 <printnum+0x3c>
      putch(padc, putdat);
  8003fa:	4c 89 ee             	mov    %r13,%rsi
  8003fd:	44 89 f7             	mov    %r14d,%edi
  800400:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800403:	83 eb 01             	sub    $0x1,%ebx
  800406:	75 f2                	jne    8003fa <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800408:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80040c:	ba 00 00 00 00       	mov    $0x0,%edx
  800411:	49 f7 f7             	div    %r15
  800414:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  80041b:	00 00 00 
  80041e:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800422:	4c 89 ee             	mov    %r13,%rsi
  800425:	41 ff d4             	callq  *%r12
}
  800428:	48 83 c4 18          	add    $0x18,%rsp
  80042c:	5b                   	pop    %rbx
  80042d:	41 5c                	pop    %r12
  80042f:	41 5d                	pop    %r13
  800431:	41 5e                	pop    %r14
  800433:	41 5f                	pop    %r15
  800435:	5d                   	pop    %rbp
  800436:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800437:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	49 f7 f7             	div    %r15
  800443:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800447:	48 89 c2             	mov    %rax,%rdx
  80044a:	48 b8 cc 03 80 00 00 	movabs $0x8003cc,%rax
  800451:	00 00 00 
  800454:	ff d0                	callq  *%rax
  800456:	eb b0                	jmp    800408 <printnum+0x3c>

0000000000800458 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800458:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80045c:	48 8b 06             	mov    (%rsi),%rax
  80045f:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800463:	73 0a                	jae    80046f <sprintputch+0x17>
    *b->buf++ = ch;
  800465:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800469:	48 89 16             	mov    %rdx,(%rsi)
  80046c:	40 88 38             	mov    %dil,(%rax)
}
  80046f:	c3                   	retq   

0000000000800470 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800470:	55                   	push   %rbp
  800471:	48 89 e5             	mov    %rsp,%rbp
  800474:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80047b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800482:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800489:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800490:	84 c0                	test   %al,%al
  800492:	74 20                	je     8004b4 <printfmt+0x44>
  800494:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800498:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80049c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004a0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004a4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004a8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004ac:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004b0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004b4:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004bb:	00 00 00 
  8004be:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004c5:	00 00 00 
  8004c8:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004cc:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004d3:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004da:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004e1:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004e8:	48 b8 f6 04 80 00 00 	movabs $0x8004f6,%rax
  8004ef:	00 00 00 
  8004f2:	ff d0                	callq  *%rax
}
  8004f4:	c9                   	leaveq 
  8004f5:	c3                   	retq   

00000000008004f6 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8004f6:	55                   	push   %rbp
  8004f7:	48 89 e5             	mov    %rsp,%rbp
  8004fa:	41 57                	push   %r15
  8004fc:	41 56                	push   %r14
  8004fe:	41 55                	push   %r13
  800500:	41 54                	push   %r12
  800502:	53                   	push   %rbx
  800503:	48 83 ec 48          	sub    $0x48,%rsp
  800507:	49 89 fd             	mov    %rdi,%r13
  80050a:	49 89 f7             	mov    %rsi,%r15
  80050d:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800510:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800514:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800518:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80051c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800520:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800524:	41 0f b6 3e          	movzbl (%r14),%edi
  800528:	83 ff 25             	cmp    $0x25,%edi
  80052b:	74 18                	je     800545 <vprintfmt+0x4f>
      if (ch == '\0')
  80052d:	85 ff                	test   %edi,%edi
  80052f:	0f 84 8c 06 00 00    	je     800bc1 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800535:	4c 89 fe             	mov    %r15,%rsi
  800538:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80053b:	49 89 de             	mov    %rbx,%r14
  80053e:	eb e0                	jmp    800520 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800540:	49 89 de             	mov    %rbx,%r14
  800543:	eb db                	jmp    800520 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800545:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800549:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80054d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800554:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80055a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800563:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800569:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80056f:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800574:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800579:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80057d:	0f b6 13             	movzbl (%rbx),%edx
  800580:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800583:	3c 55                	cmp    $0x55,%al
  800585:	0f 87 8b 05 00 00    	ja     800b16 <vprintfmt+0x620>
  80058b:	0f b6 c0             	movzbl %al,%eax
  80058e:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  800595:	00 00 00 
  800598:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80059c:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80059f:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005a3:	eb d4                	jmp    800579 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005a5:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005a8:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005ac:	eb cb                	jmp    800579 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005ae:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005b1:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005b5:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005b9:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005bc:	83 fa 09             	cmp    $0x9,%edx
  8005bf:	77 7e                	ja     80063f <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005c1:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005c5:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005c9:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005ce:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005d2:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005d5:	83 fa 09             	cmp    $0x9,%edx
  8005d8:	76 e7                	jbe    8005c1 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005da:	4c 89 f3             	mov    %r14,%rbx
  8005dd:	eb 19                	jmp    8005f8 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005df:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005e2:	83 f8 2f             	cmp    $0x2f,%eax
  8005e5:	77 2a                	ja     800611 <vprintfmt+0x11b>
  8005e7:	89 c2                	mov    %eax,%edx
  8005e9:	4c 01 d2             	add    %r10,%rdx
  8005ec:	83 c0 08             	add    $0x8,%eax
  8005ef:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005f2:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8005f5:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8005f8:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005fc:	0f 89 77 ff ff ff    	jns    800579 <vprintfmt+0x83>
          width = precision, precision = -1;
  800602:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800606:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80060c:	e9 68 ff ff ff       	jmpq   800579 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800611:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800615:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800619:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80061d:	eb d3                	jmp    8005f2 <vprintfmt+0xfc>
        if (width < 0)
  80061f:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800622:	85 c0                	test   %eax,%eax
  800624:	41 0f 48 c0          	cmovs  %r8d,%eax
  800628:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80062b:	4c 89 f3             	mov    %r14,%rbx
  80062e:	e9 46 ff ff ff       	jmpq   800579 <vprintfmt+0x83>
  800633:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800636:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80063a:	e9 3a ff ff ff       	jmpq   800579 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80063f:	4c 89 f3             	mov    %r14,%rbx
  800642:	eb b4                	jmp    8005f8 <vprintfmt+0x102>
        lflag++;
  800644:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800647:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80064a:	e9 2a ff ff ff       	jmpq   800579 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80064f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800652:	83 f8 2f             	cmp    $0x2f,%eax
  800655:	77 19                	ja     800670 <vprintfmt+0x17a>
  800657:	89 c2                	mov    %eax,%edx
  800659:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80065d:	83 c0 08             	add    $0x8,%eax
  800660:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800663:	4c 89 fe             	mov    %r15,%rsi
  800666:	8b 3a                	mov    (%rdx),%edi
  800668:	41 ff d5             	callq  *%r13
        break;
  80066b:	e9 b0 fe ff ff       	jmpq   800520 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800670:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800674:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800678:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80067c:	eb e5                	jmp    800663 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80067e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800681:	83 f8 2f             	cmp    $0x2f,%eax
  800684:	77 5b                	ja     8006e1 <vprintfmt+0x1eb>
  800686:	89 c2                	mov    %eax,%edx
  800688:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80068c:	83 c0 08             	add    $0x8,%eax
  80068f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800692:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800694:	89 c8                	mov    %ecx,%eax
  800696:	c1 f8 1f             	sar    $0x1f,%eax
  800699:	31 c1                	xor    %eax,%ecx
  80069b:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069d:	83 f9 09             	cmp    $0x9,%ecx
  8006a0:	7f 4d                	jg     8006ef <vprintfmt+0x1f9>
  8006a2:	48 63 c1             	movslq %ecx,%rax
  8006a5:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  8006ac:	00 00 00 
  8006af:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006b3:	48 85 c0             	test   %rax,%rax
  8006b6:	74 37                	je     8006ef <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006b8:	48 89 c1             	mov    %rax,%rcx
  8006bb:	48 ba cb 11 80 00 00 	movabs $0x8011cb,%rdx
  8006c2:	00 00 00 
  8006c5:	4c 89 fe             	mov    %r15,%rsi
  8006c8:	4c 89 ef             	mov    %r13,%rdi
  8006cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d0:	48 bb 70 04 80 00 00 	movabs $0x800470,%rbx
  8006d7:	00 00 00 
  8006da:	ff d3                	callq  *%rbx
  8006dc:	e9 3f fe ff ff       	jmpq   800520 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006ed:	eb a3                	jmp    800692 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006ef:	48 ba c2 11 80 00 00 	movabs $0x8011c2,%rdx
  8006f6:	00 00 00 
  8006f9:	4c 89 fe             	mov    %r15,%rsi
  8006fc:	4c 89 ef             	mov    %r13,%rdi
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	48 bb 70 04 80 00 00 	movabs $0x800470,%rbx
  80070b:	00 00 00 
  80070e:	ff d3                	callq  *%rbx
  800710:	e9 0b fe ff ff       	jmpq   800520 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800715:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800718:	83 f8 2f             	cmp    $0x2f,%eax
  80071b:	77 4b                	ja     800768 <vprintfmt+0x272>
  80071d:	89 c2                	mov    %eax,%edx
  80071f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800723:	83 c0 08             	add    $0x8,%eax
  800726:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800729:	48 8b 02             	mov    (%rdx),%rax
  80072c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800730:	48 85 c0             	test   %rax,%rax
  800733:	0f 84 05 04 00 00    	je     800b3e <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800739:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80073d:	7e 06                	jle    800745 <vprintfmt+0x24f>
  80073f:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800743:	75 31                	jne    800776 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800745:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800749:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80074d:	0f b6 00             	movzbl (%rax),%eax
  800750:	0f be f8             	movsbl %al,%edi
  800753:	85 ff                	test   %edi,%edi
  800755:	0f 84 c3 00 00 00    	je     80081e <vprintfmt+0x328>
  80075b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80075f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800763:	e9 85 00 00 00       	jmpq   8007ed <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800768:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80076c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800770:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800774:	eb b3                	jmp    800729 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800776:	49 63 f4             	movslq %r12d,%rsi
  800779:	48 89 c7             	mov    %rax,%rdi
  80077c:	48 b8 cd 0c 80 00 00 	movabs $0x800ccd,%rax
  800783:	00 00 00 
  800786:	ff d0                	callq  *%rax
  800788:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80078b:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80078e:	85 f6                	test   %esi,%esi
  800790:	7e 22                	jle    8007b4 <vprintfmt+0x2be>
            putch(padc, putdat);
  800792:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800796:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80079a:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80079e:	4c 89 fe             	mov    %r15,%rsi
  8007a1:	89 df                	mov    %ebx,%edi
  8007a3:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007a6:	41 83 ec 01          	sub    $0x1,%r12d
  8007aa:	75 f2                	jne    80079e <vprintfmt+0x2a8>
  8007ac:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007b0:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007b8:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007bc:	0f b6 00             	movzbl (%rax),%eax
  8007bf:	0f be f8             	movsbl %al,%edi
  8007c2:	85 ff                	test   %edi,%edi
  8007c4:	0f 84 56 fd ff ff    	je     800520 <vprintfmt+0x2a>
  8007ca:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007ce:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007d2:	eb 19                	jmp    8007ed <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007d4:	4c 89 fe             	mov    %r15,%rsi
  8007d7:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007da:	41 83 ee 01          	sub    $0x1,%r14d
  8007de:	48 83 c3 01          	add    $0x1,%rbx
  8007e2:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007e6:	0f be f8             	movsbl %al,%edi
  8007e9:	85 ff                	test   %edi,%edi
  8007eb:	74 29                	je     800816 <vprintfmt+0x320>
  8007ed:	45 85 e4             	test   %r12d,%r12d
  8007f0:	78 06                	js     8007f8 <vprintfmt+0x302>
  8007f2:	41 83 ec 01          	sub    $0x1,%r12d
  8007f6:	78 48                	js     800840 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8007f8:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8007fc:	74 d6                	je     8007d4 <vprintfmt+0x2de>
  8007fe:	0f be c0             	movsbl %al,%eax
  800801:	83 e8 20             	sub    $0x20,%eax
  800804:	83 f8 5e             	cmp    $0x5e,%eax
  800807:	76 cb                	jbe    8007d4 <vprintfmt+0x2de>
            putch('?', putdat);
  800809:	4c 89 fe             	mov    %r15,%rsi
  80080c:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800811:	41 ff d5             	callq  *%r13
  800814:	eb c4                	jmp    8007da <vprintfmt+0x2e4>
  800816:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80081a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80081e:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800821:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800825:	0f 8e f5 fc ff ff    	jle    800520 <vprintfmt+0x2a>
          putch(' ', putdat);
  80082b:	4c 89 fe             	mov    %r15,%rsi
  80082e:	bf 20 00 00 00       	mov    $0x20,%edi
  800833:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800836:	83 eb 01             	sub    $0x1,%ebx
  800839:	75 f0                	jne    80082b <vprintfmt+0x335>
  80083b:	e9 e0 fc ff ff       	jmpq   800520 <vprintfmt+0x2a>
  800840:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800844:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800848:	eb d4                	jmp    80081e <vprintfmt+0x328>
  if (lflag >= 2)
  80084a:	83 f9 01             	cmp    $0x1,%ecx
  80084d:	7f 1d                	jg     80086c <vprintfmt+0x376>
  else if (lflag)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	74 5e                	je     8008b1 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800853:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800856:	83 f8 2f             	cmp    $0x2f,%eax
  800859:	77 48                	ja     8008a3 <vprintfmt+0x3ad>
  80085b:	89 c2                	mov    %eax,%edx
  80085d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800861:	83 c0 08             	add    $0x8,%eax
  800864:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800867:	48 8b 1a             	mov    (%rdx),%rbx
  80086a:	eb 17                	jmp    800883 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80086c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80086f:	83 f8 2f             	cmp    $0x2f,%eax
  800872:	77 21                	ja     800895 <vprintfmt+0x39f>
  800874:	89 c2                	mov    %eax,%edx
  800876:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80087a:	83 c0 08             	add    $0x8,%eax
  80087d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800880:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800883:	48 85 db             	test   %rbx,%rbx
  800886:	78 50                	js     8008d8 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800888:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80088b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800890:	e9 b4 01 00 00       	jmpq   800a49 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800895:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800899:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80089d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a1:	eb dd                	jmp    800880 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008a3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ab:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008af:	eb b6                	jmp    800867 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008b1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b4:	83 f8 2f             	cmp    $0x2f,%eax
  8008b7:	77 11                	ja     8008ca <vprintfmt+0x3d4>
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008bf:	83 c0 08             	add    $0x8,%eax
  8008c2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c5:	48 63 1a             	movslq (%rdx),%rbx
  8008c8:	eb b9                	jmp    800883 <vprintfmt+0x38d>
  8008ca:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ce:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d6:	eb ed                	jmp    8008c5 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008d8:	4c 89 fe             	mov    %r15,%rsi
  8008db:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008e0:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008e3:	48 89 da             	mov    %rbx,%rdx
  8008e6:	48 f7 da             	neg    %rdx
        base = 10;
  8008e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008ee:	e9 56 01 00 00       	jmpq   800a49 <vprintfmt+0x553>
  if (lflag >= 2)
  8008f3:	83 f9 01             	cmp    $0x1,%ecx
  8008f6:	7f 25                	jg     80091d <vprintfmt+0x427>
  else if (lflag)
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 5e                	je     80095a <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8008fc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ff:	83 f8 2f             	cmp    $0x2f,%eax
  800902:	77 48                	ja     80094c <vprintfmt+0x456>
  800904:	89 c2                	mov    %eax,%edx
  800906:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80090a:	83 c0 08             	add    $0x8,%eax
  80090d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800910:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800913:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800918:	e9 2c 01 00 00       	jmpq   800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80091d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800920:	83 f8 2f             	cmp    $0x2f,%eax
  800923:	77 19                	ja     80093e <vprintfmt+0x448>
  800925:	89 c2                	mov    %eax,%edx
  800927:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092b:	83 c0 08             	add    $0x8,%eax
  80092e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800931:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800934:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800939:	e9 0b 01 00 00       	jmpq   800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80093e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800942:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800946:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094a:	eb e5                	jmp    800931 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80094c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800950:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800954:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800958:	eb b6                	jmp    800910 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80095a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095d:	83 f8 2f             	cmp    $0x2f,%eax
  800960:	77 18                	ja     80097a <vprintfmt+0x484>
  800962:	89 c2                	mov    %eax,%edx
  800964:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800968:	83 c0 08             	add    $0x8,%eax
  80096b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80096e:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800970:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800975:	e9 cf 00 00 00       	jmpq   800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80097a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800982:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800986:	eb e6                	jmp    80096e <vprintfmt+0x478>
  if (lflag >= 2)
  800988:	83 f9 01             	cmp    $0x1,%ecx
  80098b:	7f 25                	jg     8009b2 <vprintfmt+0x4bc>
  else if (lflag)
  80098d:	85 c9                	test   %ecx,%ecx
  80098f:	74 5b                	je     8009ec <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800991:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800994:	83 f8 2f             	cmp    $0x2f,%eax
  800997:	77 45                	ja     8009de <vprintfmt+0x4e8>
  800999:	89 c2                	mov    %eax,%edx
  80099b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80099f:	83 c0 08             	add    $0x8,%eax
  8009a2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009a5:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009a8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009ad:	e9 97 00 00 00       	jmpq   800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009b2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b5:	83 f8 2f             	cmp    $0x2f,%eax
  8009b8:	77 16                	ja     8009d0 <vprintfmt+0x4da>
  8009ba:	89 c2                	mov    %eax,%edx
  8009bc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c0:	83 c0 08             	add    $0x8,%eax
  8009c3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009c6:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009c9:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009ce:	eb 79                	jmp    800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009d0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009d8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009dc:	eb e8                	jmp    8009c6 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009de:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009e2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009e6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ea:	eb b9                	jmp    8009a5 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ef:	83 f8 2f             	cmp    $0x2f,%eax
  8009f2:	77 15                	ja     800a09 <vprintfmt+0x513>
  8009f4:	89 c2                	mov    %eax,%edx
  8009f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009fa:	83 c0 08             	add    $0x8,%eax
  8009fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a00:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a02:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a07:	eb 40                	jmp    800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a09:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a0d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a11:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a15:	eb e9                	jmp    800a00 <vprintfmt+0x50a>
        putch('0', putdat);
  800a17:	4c 89 fe             	mov    %r15,%rsi
  800a1a:	bf 30 00 00 00       	mov    $0x30,%edi
  800a1f:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a22:	4c 89 fe             	mov    %r15,%rsi
  800a25:	bf 78 00 00 00       	mov    $0x78,%edi
  800a2a:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a2d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a30:	83 f8 2f             	cmp    $0x2f,%eax
  800a33:	77 34                	ja     800a69 <vprintfmt+0x573>
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a3b:	83 c0 08             	add    $0x8,%eax
  800a3e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a41:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a44:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a49:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a4e:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a52:	4c 89 fe             	mov    %r15,%rsi
  800a55:	4c 89 ef             	mov    %r13,%rdi
  800a58:	48 b8 cc 03 80 00 00 	movabs $0x8003cc,%rax
  800a5f:	00 00 00 
  800a62:	ff d0                	callq  *%rax
        break;
  800a64:	e9 b7 fa ff ff       	jmpq   800520 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a69:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a6d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a71:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a75:	eb ca                	jmp    800a41 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a77:	83 f9 01             	cmp    $0x1,%ecx
  800a7a:	7f 22                	jg     800a9e <vprintfmt+0x5a8>
  else if (lflag)
  800a7c:	85 c9                	test   %ecx,%ecx
  800a7e:	74 58                	je     800ad8 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a80:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a83:	83 f8 2f             	cmp    $0x2f,%eax
  800a86:	77 42                	ja     800aca <vprintfmt+0x5d4>
  800a88:	89 c2                	mov    %eax,%edx
  800a8a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a8e:	83 c0 08             	add    $0x8,%eax
  800a91:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a94:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a97:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a9c:	eb ab                	jmp    800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a9e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aa1:	83 f8 2f             	cmp    $0x2f,%eax
  800aa4:	77 16                	ja     800abc <vprintfmt+0x5c6>
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aac:	83 c0 08             	add    $0x8,%eax
  800aaf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ab2:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ab5:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aba:	eb 8d                	jmp    800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800abc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ac0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ac4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ac8:	eb e8                	jmp    800ab2 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800aca:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ace:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ad2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ad6:	eb bc                	jmp    800a94 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ad8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800adb:	83 f8 2f             	cmp    $0x2f,%eax
  800ade:	77 18                	ja     800af8 <vprintfmt+0x602>
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ae6:	83 c0 08             	add    $0x8,%eax
  800ae9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aec:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800aee:	b9 10 00 00 00       	mov    $0x10,%ecx
  800af3:	e9 51 ff ff ff       	jmpq   800a49 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800af8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800afc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b00:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b04:	eb e6                	jmp    800aec <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b06:	4c 89 fe             	mov    %r15,%rsi
  800b09:	bf 25 00 00 00       	mov    $0x25,%edi
  800b0e:	41 ff d5             	callq  *%r13
        break;
  800b11:	e9 0a fa ff ff       	jmpq   800520 <vprintfmt+0x2a>
        putch('%', putdat);
  800b16:	4c 89 fe             	mov    %r15,%rsi
  800b19:	bf 25 00 00 00       	mov    $0x25,%edi
  800b1e:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b21:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b25:	0f 84 15 fa ff ff    	je     800540 <vprintfmt+0x4a>
  800b2b:	49 89 de             	mov    %rbx,%r14
  800b2e:	49 83 ee 01          	sub    $0x1,%r14
  800b32:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b37:	75 f5                	jne    800b2e <vprintfmt+0x638>
  800b39:	e9 e2 f9 ff ff       	jmpq   800520 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b3e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b42:	74 06                	je     800b4a <vprintfmt+0x654>
  800b44:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b48:	7f 21                	jg     800b6b <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b4a:	bf 28 00 00 00       	mov    $0x28,%edi
  800b4f:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800b56:	00 00 00 
  800b59:	b8 28 00 00 00       	mov    $0x28,%eax
  800b5e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b62:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b66:	e9 82 fc ff ff       	jmpq   8007ed <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b6b:	49 63 f4             	movslq %r12d,%rsi
  800b6e:	48 bf bb 11 80 00 00 	movabs $0x8011bb,%rdi
  800b75:	00 00 00 
  800b78:	48 b8 cd 0c 80 00 00 	movabs $0x800ccd,%rax
  800b7f:	00 00 00 
  800b82:	ff d0                	callq  *%rax
  800b84:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b87:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b8a:	48 be bb 11 80 00 00 	movabs $0x8011bb,%rsi
  800b91:	00 00 00 
  800b94:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	0f 8f f2 fb ff ff    	jg     800792 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ba0:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800ba7:	00 00 00 
  800baa:	b8 28 00 00 00       	mov    $0x28,%eax
  800baf:	bf 28 00 00 00       	mov    $0x28,%edi
  800bb4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bb8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bbc:	e9 2c fc ff ff       	jmpq   8007ed <vprintfmt+0x2f7>
}
  800bc1:	48 83 c4 48          	add    $0x48,%rsp
  800bc5:	5b                   	pop    %rbx
  800bc6:	41 5c                	pop    %r12
  800bc8:	41 5d                	pop    %r13
  800bca:	41 5e                	pop    %r14
  800bcc:	41 5f                	pop    %r15
  800bce:	5d                   	pop    %rbp
  800bcf:	c3                   	retq   

0000000000800bd0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bd0:	55                   	push   %rbp
  800bd1:	48 89 e5             	mov    %rsp,%rbp
  800bd4:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bd8:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bdc:	48 63 c6             	movslq %esi,%rax
  800bdf:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800be4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800be8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800bef:	48 85 ff             	test   %rdi,%rdi
  800bf2:	74 2a                	je     800c1e <vsnprintf+0x4e>
  800bf4:	85 f6                	test   %esi,%esi
  800bf6:	7e 26                	jle    800c1e <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800bf8:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800bfc:	48 bf 58 04 80 00 00 	movabs $0x800458,%rdi
  800c03:	00 00 00 
  800c06:	48 b8 f6 04 80 00 00 	movabs $0x8004f6,%rax
  800c0d:	00 00 00 
  800c10:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c12:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c16:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c19:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c1c:	c9                   	leaveq 
  800c1d:	c3                   	retq   
    return -E_INVAL;
  800c1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c23:	eb f7                	jmp    800c1c <vsnprintf+0x4c>

0000000000800c25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c25:	55                   	push   %rbp
  800c26:	48 89 e5             	mov    %rsp,%rbp
  800c29:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c30:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c37:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c3e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c45:	84 c0                	test   %al,%al
  800c47:	74 20                	je     800c69 <snprintf+0x44>
  800c49:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c4d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c51:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c55:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c59:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c5d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c61:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c65:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c69:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c70:	00 00 00 
  800c73:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c7a:	00 00 00 
  800c7d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c81:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c88:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c8f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c96:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c9d:	48 b8 d0 0b 80 00 00 	movabs $0x800bd0,%rax
  800ca4:	00 00 00 
  800ca7:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800ca9:	c9                   	leaveq 
  800caa:	c3                   	retq   

0000000000800cab <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cab:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cae:	74 17                	je     800cc7 <strlen+0x1c>
  800cb0:	48 89 fa             	mov    %rdi,%rdx
  800cb3:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cb8:	29 f9                	sub    %edi,%ecx
    n++;
  800cba:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cbd:	48 83 c2 01          	add    $0x1,%rdx
  800cc1:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cc4:	75 f4                	jne    800cba <strlen+0xf>
  800cc6:	c3                   	retq   
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800ccc:	c3                   	retq   

0000000000800ccd <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ccd:	48 85 f6             	test   %rsi,%rsi
  800cd0:	74 24                	je     800cf6 <strnlen+0x29>
  800cd2:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cd5:	74 25                	je     800cfc <strnlen+0x2f>
  800cd7:	48 01 fe             	add    %rdi,%rsi
  800cda:	48 89 fa             	mov    %rdi,%rdx
  800cdd:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ce2:	29 f9                	sub    %edi,%ecx
    n++;
  800ce4:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce7:	48 83 c2 01          	add    $0x1,%rdx
  800ceb:	48 39 f2             	cmp    %rsi,%rdx
  800cee:	74 11                	je     800d01 <strnlen+0x34>
  800cf0:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cf3:	75 ef                	jne    800ce4 <strnlen+0x17>
  800cf5:	c3                   	retq   
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfb:	c3                   	retq   
  800cfc:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d01:	c3                   	retq   

0000000000800d02 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d02:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d05:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0a:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d0e:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d11:	48 83 c2 01          	add    $0x1,%rdx
  800d15:	84 c9                	test   %cl,%cl
  800d17:	75 f1                	jne    800d0a <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d19:	c3                   	retq   

0000000000800d1a <strcat>:

char *
strcat(char *dst, const char *src) {
  800d1a:	55                   	push   %rbp
  800d1b:	48 89 e5             	mov    %rsp,%rbp
  800d1e:	41 54                	push   %r12
  800d20:	53                   	push   %rbx
  800d21:	48 89 fb             	mov    %rdi,%rbx
  800d24:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d27:	48 b8 ab 0c 80 00 00 	movabs $0x800cab,%rax
  800d2e:	00 00 00 
  800d31:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d33:	48 63 f8             	movslq %eax,%rdi
  800d36:	48 01 df             	add    %rbx,%rdi
  800d39:	4c 89 e6             	mov    %r12,%rsi
  800d3c:	48 b8 02 0d 80 00 00 	movabs $0x800d02,%rax
  800d43:	00 00 00 
  800d46:	ff d0                	callq  *%rax
  return dst;
}
  800d48:	48 89 d8             	mov    %rbx,%rax
  800d4b:	5b                   	pop    %rbx
  800d4c:	41 5c                	pop    %r12
  800d4e:	5d                   	pop    %rbp
  800d4f:	c3                   	retq   

0000000000800d50 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d50:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d53:	48 85 d2             	test   %rdx,%rdx
  800d56:	74 1f                	je     800d77 <strncpy+0x27>
  800d58:	48 01 fa             	add    %rdi,%rdx
  800d5b:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d5e:	48 83 c1 01          	add    $0x1,%rcx
  800d62:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d66:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d6a:	41 80 f8 01          	cmp    $0x1,%r8b
  800d6e:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d72:	48 39 ca             	cmp    %rcx,%rdx
  800d75:	75 e7                	jne    800d5e <strncpy+0xe>
  }
  return ret;
}
  800d77:	c3                   	retq   

0000000000800d78 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d78:	48 89 f8             	mov    %rdi,%rax
  800d7b:	48 85 d2             	test   %rdx,%rdx
  800d7e:	74 36                	je     800db6 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d80:	48 83 fa 01          	cmp    $0x1,%rdx
  800d84:	74 2d                	je     800db3 <strlcpy+0x3b>
  800d86:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d8a:	45 84 c0             	test   %r8b,%r8b
  800d8d:	74 24                	je     800db3 <strlcpy+0x3b>
  800d8f:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d93:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d98:	48 83 c0 01          	add    $0x1,%rax
  800d9c:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800da0:	48 39 d1             	cmp    %rdx,%rcx
  800da3:	74 0e                	je     800db3 <strlcpy+0x3b>
  800da5:	48 83 c1 01          	add    $0x1,%rcx
  800da9:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dae:	45 84 c0             	test   %r8b,%r8b
  800db1:	75 e5                	jne    800d98 <strlcpy+0x20>
    *dst = '\0';
  800db3:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800db6:	48 29 f8             	sub    %rdi,%rax
}
  800db9:	c3                   	retq   

0000000000800dba <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dba:	0f b6 07             	movzbl (%rdi),%eax
  800dbd:	84 c0                	test   %al,%al
  800dbf:	74 17                	je     800dd8 <strcmp+0x1e>
  800dc1:	3a 06                	cmp    (%rsi),%al
  800dc3:	75 13                	jne    800dd8 <strcmp+0x1e>
    p++, q++;
  800dc5:	48 83 c7 01          	add    $0x1,%rdi
  800dc9:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dcd:	0f b6 07             	movzbl (%rdi),%eax
  800dd0:	84 c0                	test   %al,%al
  800dd2:	74 04                	je     800dd8 <strcmp+0x1e>
  800dd4:	3a 06                	cmp    (%rsi),%al
  800dd6:	74 ed                	je     800dc5 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dd8:	0f b6 c0             	movzbl %al,%eax
  800ddb:	0f b6 16             	movzbl (%rsi),%edx
  800dde:	29 d0                	sub    %edx,%eax
}
  800de0:	c3                   	retq   

0000000000800de1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800de1:	48 85 d2             	test   %rdx,%rdx
  800de4:	74 2f                	je     800e15 <strncmp+0x34>
  800de6:	0f b6 07             	movzbl (%rdi),%eax
  800de9:	84 c0                	test   %al,%al
  800deb:	74 1f                	je     800e0c <strncmp+0x2b>
  800ded:	3a 06                	cmp    (%rsi),%al
  800def:	75 1b                	jne    800e0c <strncmp+0x2b>
  800df1:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800df4:	48 83 c7 01          	add    $0x1,%rdi
  800df8:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800dfc:	48 39 d7             	cmp    %rdx,%rdi
  800dff:	74 1a                	je     800e1b <strncmp+0x3a>
  800e01:	0f b6 07             	movzbl (%rdi),%eax
  800e04:	84 c0                	test   %al,%al
  800e06:	74 04                	je     800e0c <strncmp+0x2b>
  800e08:	3a 06                	cmp    (%rsi),%al
  800e0a:	74 e8                	je     800df4 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e0c:	0f b6 07             	movzbl (%rdi),%eax
  800e0f:	0f b6 16             	movzbl (%rsi),%edx
  800e12:	29 d0                	sub    %edx,%eax
}
  800e14:	c3                   	retq   
    return 0;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1a:	c3                   	retq   
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	c3                   	retq   

0000000000800e21 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e21:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e23:	0f b6 07             	movzbl (%rdi),%eax
  800e26:	84 c0                	test   %al,%al
  800e28:	74 1e                	je     800e48 <strchr+0x27>
    if (*s == c)
  800e2a:	40 38 c6             	cmp    %al,%sil
  800e2d:	74 1f                	je     800e4e <strchr+0x2d>
  for (; *s; s++)
  800e2f:	48 83 c7 01          	add    $0x1,%rdi
  800e33:	0f b6 07             	movzbl (%rdi),%eax
  800e36:	84 c0                	test   %al,%al
  800e38:	74 08                	je     800e42 <strchr+0x21>
    if (*s == c)
  800e3a:	38 d0                	cmp    %dl,%al
  800e3c:	75 f1                	jne    800e2f <strchr+0xe>
  for (; *s; s++)
  800e3e:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e41:	c3                   	retq   
  return 0;
  800e42:	b8 00 00 00 00       	mov    $0x0,%eax
  800e47:	c3                   	retq   
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4d:	c3                   	retq   
    if (*s == c)
  800e4e:	48 89 f8             	mov    %rdi,%rax
  800e51:	c3                   	retq   

0000000000800e52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e52:	48 89 f8             	mov    %rdi,%rax
  800e55:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e57:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e5a:	40 38 f2             	cmp    %sil,%dl
  800e5d:	74 13                	je     800e72 <strfind+0x20>
  800e5f:	84 d2                	test   %dl,%dl
  800e61:	74 0f                	je     800e72 <strfind+0x20>
  for (; *s; s++)
  800e63:	48 83 c0 01          	add    $0x1,%rax
  800e67:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e6a:	38 ca                	cmp    %cl,%dl
  800e6c:	74 04                	je     800e72 <strfind+0x20>
  800e6e:	84 d2                	test   %dl,%dl
  800e70:	75 f1                	jne    800e63 <strfind+0x11>
      break;
  return (char *)s;
}
  800e72:	c3                   	retq   

0000000000800e73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e73:	48 85 d2             	test   %rdx,%rdx
  800e76:	74 3a                	je     800eb2 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e78:	48 89 f8             	mov    %rdi,%rax
  800e7b:	48 09 d0             	or     %rdx,%rax
  800e7e:	a8 03                	test   $0x3,%al
  800e80:	75 28                	jne    800eaa <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e82:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e86:	89 f0                	mov    %esi,%eax
  800e88:	c1 e0 08             	shl    $0x8,%eax
  800e8b:	89 f1                	mov    %esi,%ecx
  800e8d:	c1 e1 18             	shl    $0x18,%ecx
  800e90:	41 89 f0             	mov    %esi,%r8d
  800e93:	41 c1 e0 10          	shl    $0x10,%r8d
  800e97:	44 09 c1             	or     %r8d,%ecx
  800e9a:	09 ce                	or     %ecx,%esi
  800e9c:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e9e:	48 c1 ea 02          	shr    $0x2,%rdx
  800ea2:	48 89 d1             	mov    %rdx,%rcx
  800ea5:	fc                   	cld    
  800ea6:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ea8:	eb 08                	jmp    800eb2 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800eaa:	89 f0                	mov    %esi,%eax
  800eac:	48 89 d1             	mov    %rdx,%rcx
  800eaf:	fc                   	cld    
  800eb0:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800eb2:	48 89 f8             	mov    %rdi,%rax
  800eb5:	c3                   	retq   

0000000000800eb6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800eb6:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800eb9:	48 39 fe             	cmp    %rdi,%rsi
  800ebc:	73 40                	jae    800efe <memmove+0x48>
  800ebe:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ec2:	48 39 f9             	cmp    %rdi,%rcx
  800ec5:	76 37                	jbe    800efe <memmove+0x48>
    s += n;
    d += n;
  800ec7:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ecb:	48 89 fe             	mov    %rdi,%rsi
  800ece:	48 09 d6             	or     %rdx,%rsi
  800ed1:	48 09 ce             	or     %rcx,%rsi
  800ed4:	40 f6 c6 03          	test   $0x3,%sil
  800ed8:	75 14                	jne    800eee <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800eda:	48 83 ef 04          	sub    $0x4,%rdi
  800ede:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ee2:	48 c1 ea 02          	shr    $0x2,%rdx
  800ee6:	48 89 d1             	mov    %rdx,%rcx
  800ee9:	fd                   	std    
  800eea:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800eec:	eb 0e                	jmp    800efc <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800eee:	48 83 ef 01          	sub    $0x1,%rdi
  800ef2:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800ef6:	48 89 d1             	mov    %rdx,%rcx
  800ef9:	fd                   	std    
  800efa:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800efc:	fc                   	cld    
  800efd:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800efe:	48 89 c1             	mov    %rax,%rcx
  800f01:	48 09 d1             	or     %rdx,%rcx
  800f04:	48 09 f1             	or     %rsi,%rcx
  800f07:	f6 c1 03             	test   $0x3,%cl
  800f0a:	75 0e                	jne    800f1a <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f0c:	48 c1 ea 02          	shr    $0x2,%rdx
  800f10:	48 89 d1             	mov    %rdx,%rcx
  800f13:	48 89 c7             	mov    %rax,%rdi
  800f16:	fc                   	cld    
  800f17:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f19:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f1a:	48 89 c7             	mov    %rax,%rdi
  800f1d:	48 89 d1             	mov    %rdx,%rcx
  800f20:	fc                   	cld    
  800f21:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f23:	c3                   	retq   

0000000000800f24 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f24:	55                   	push   %rbp
  800f25:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f28:	48 b8 b6 0e 80 00 00 	movabs $0x800eb6,%rax
  800f2f:	00 00 00 
  800f32:	ff d0                	callq  *%rax
}
  800f34:	5d                   	pop    %rbp
  800f35:	c3                   	retq   

0000000000800f36 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f36:	55                   	push   %rbp
  800f37:	48 89 e5             	mov    %rsp,%rbp
  800f3a:	41 57                	push   %r15
  800f3c:	41 56                	push   %r14
  800f3e:	41 55                	push   %r13
  800f40:	41 54                	push   %r12
  800f42:	53                   	push   %rbx
  800f43:	48 83 ec 08          	sub    $0x8,%rsp
  800f47:	49 89 fe             	mov    %rdi,%r14
  800f4a:	49 89 f7             	mov    %rsi,%r15
  800f4d:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f50:	48 89 f7             	mov    %rsi,%rdi
  800f53:	48 b8 ab 0c 80 00 00 	movabs $0x800cab,%rax
  800f5a:	00 00 00 
  800f5d:	ff d0                	callq  *%rax
  800f5f:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f62:	4c 89 ee             	mov    %r13,%rsi
  800f65:	4c 89 f7             	mov    %r14,%rdi
  800f68:	48 b8 cd 0c 80 00 00 	movabs $0x800ccd,%rax
  800f6f:	00 00 00 
  800f72:	ff d0                	callq  *%rax
  800f74:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f77:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f7b:	4d 39 e5             	cmp    %r12,%r13
  800f7e:	74 26                	je     800fa6 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f80:	4c 89 e8             	mov    %r13,%rax
  800f83:	4c 29 e0             	sub    %r12,%rax
  800f86:	48 39 d8             	cmp    %rbx,%rax
  800f89:	76 2a                	jbe    800fb5 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f8b:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f8f:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f93:	4c 89 fe             	mov    %r15,%rsi
  800f96:	48 b8 24 0f 80 00 00 	movabs $0x800f24,%rax
  800f9d:	00 00 00 
  800fa0:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fa2:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fa6:	48 83 c4 08          	add    $0x8,%rsp
  800faa:	5b                   	pop    %rbx
  800fab:	41 5c                	pop    %r12
  800fad:	41 5d                	pop    %r13
  800faf:	41 5e                	pop    %r14
  800fb1:	41 5f                	pop    %r15
  800fb3:	5d                   	pop    %rbp
  800fb4:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fb5:	49 83 ed 01          	sub    $0x1,%r13
  800fb9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fbd:	4c 89 ea             	mov    %r13,%rdx
  800fc0:	4c 89 fe             	mov    %r15,%rsi
  800fc3:	48 b8 24 0f 80 00 00 	movabs $0x800f24,%rax
  800fca:	00 00 00 
  800fcd:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fcf:	4d 01 ee             	add    %r13,%r14
  800fd2:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fd7:	eb c9                	jmp    800fa2 <strlcat+0x6c>

0000000000800fd9 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fd9:	48 85 d2             	test   %rdx,%rdx
  800fdc:	74 3a                	je     801018 <memcmp+0x3f>
    if (*s1 != *s2)
  800fde:	0f b6 0f             	movzbl (%rdi),%ecx
  800fe1:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fe5:	44 38 c1             	cmp    %r8b,%cl
  800fe8:	75 1d                	jne    801007 <memcmp+0x2e>
  800fea:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fef:	48 39 d0             	cmp    %rdx,%rax
  800ff2:	74 1e                	je     801012 <memcmp+0x39>
    if (*s1 != *s2)
  800ff4:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800ff8:	48 83 c0 01          	add    $0x1,%rax
  800ffc:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801002:	44 38 c1             	cmp    %r8b,%cl
  801005:	74 e8                	je     800fef <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801007:	0f b6 c1             	movzbl %cl,%eax
  80100a:	45 0f b6 c0          	movzbl %r8b,%r8d
  80100e:	44 29 c0             	sub    %r8d,%eax
  801011:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
  801017:	c3                   	retq   
  801018:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80101d:	c3                   	retq   

000000000080101e <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80101e:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801022:	48 39 c7             	cmp    %rax,%rdi
  801025:	73 19                	jae    801040 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801027:	89 f2                	mov    %esi,%edx
  801029:	40 38 37             	cmp    %sil,(%rdi)
  80102c:	74 16                	je     801044 <memfind+0x26>
  for (; s < ends; s++)
  80102e:	48 83 c7 01          	add    $0x1,%rdi
  801032:	48 39 f8             	cmp    %rdi,%rax
  801035:	74 08                	je     80103f <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801037:	38 17                	cmp    %dl,(%rdi)
  801039:	75 f3                	jne    80102e <memfind+0x10>
  for (; s < ends; s++)
  80103b:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80103e:	c3                   	retq   
  80103f:	c3                   	retq   
  for (; s < ends; s++)
  801040:	48 89 f8             	mov    %rdi,%rax
  801043:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801044:	48 89 f8             	mov    %rdi,%rax
  801047:	c3                   	retq   

0000000000801048 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801048:	0f b6 07             	movzbl (%rdi),%eax
  80104b:	3c 20                	cmp    $0x20,%al
  80104d:	74 04                	je     801053 <strtol+0xb>
  80104f:	3c 09                	cmp    $0x9,%al
  801051:	75 0f                	jne    801062 <strtol+0x1a>
    s++;
  801053:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801057:	0f b6 07             	movzbl (%rdi),%eax
  80105a:	3c 20                	cmp    $0x20,%al
  80105c:	74 f5                	je     801053 <strtol+0xb>
  80105e:	3c 09                	cmp    $0x9,%al
  801060:	74 f1                	je     801053 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801062:	3c 2b                	cmp    $0x2b,%al
  801064:	74 2b                	je     801091 <strtol+0x49>
  int neg  = 0;
  801066:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80106c:	3c 2d                	cmp    $0x2d,%al
  80106e:	74 2d                	je     80109d <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801070:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801076:	75 0f                	jne    801087 <strtol+0x3f>
  801078:	80 3f 30             	cmpb   $0x30,(%rdi)
  80107b:	74 2c                	je     8010a9 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80107d:	85 d2                	test   %edx,%edx
  80107f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801084:	0f 44 d0             	cmove  %eax,%edx
  801087:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80108c:	4c 63 d2             	movslq %edx,%r10
  80108f:	eb 5c                	jmp    8010ed <strtol+0xa5>
    s++;
  801091:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801095:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80109b:	eb d3                	jmp    801070 <strtol+0x28>
    s++, neg = 1;
  80109d:	48 83 c7 01          	add    $0x1,%rdi
  8010a1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010a7:	eb c7                	jmp    801070 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010a9:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010ad:	74 0f                	je     8010be <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010af:	85 d2                	test   %edx,%edx
  8010b1:	75 d4                	jne    801087 <strtol+0x3f>
    s++, base = 8;
  8010b3:	48 83 c7 01          	add    $0x1,%rdi
  8010b7:	ba 08 00 00 00       	mov    $0x8,%edx
  8010bc:	eb c9                	jmp    801087 <strtol+0x3f>
    s += 2, base = 16;
  8010be:	48 83 c7 02          	add    $0x2,%rdi
  8010c2:	ba 10 00 00 00       	mov    $0x10,%edx
  8010c7:	eb be                	jmp    801087 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010c9:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010cd:	41 80 f8 19          	cmp    $0x19,%r8b
  8010d1:	77 2f                	ja     801102 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010d3:	44 0f be c1          	movsbl %cl,%r8d
  8010d7:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010db:	39 d1                	cmp    %edx,%ecx
  8010dd:	7d 37                	jge    801116 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010df:	48 83 c7 01          	add    $0x1,%rdi
  8010e3:	49 0f af c2          	imul   %r10,%rax
  8010e7:	48 63 c9             	movslq %ecx,%rcx
  8010ea:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010ed:	0f b6 0f             	movzbl (%rdi),%ecx
  8010f0:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010f4:	41 80 f8 09          	cmp    $0x9,%r8b
  8010f8:	77 cf                	ja     8010c9 <strtol+0x81>
      dig = *s - '0';
  8010fa:	0f be c9             	movsbl %cl,%ecx
  8010fd:	83 e9 30             	sub    $0x30,%ecx
  801100:	eb d9                	jmp    8010db <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801102:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801106:	41 80 f8 19          	cmp    $0x19,%r8b
  80110a:	77 0a                	ja     801116 <strtol+0xce>
      dig = *s - 'A' + 10;
  80110c:	44 0f be c1          	movsbl %cl,%r8d
  801110:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801114:	eb c5                	jmp    8010db <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801116:	48 85 f6             	test   %rsi,%rsi
  801119:	74 03                	je     80111e <strtol+0xd6>
    *endptr = (char *)s;
  80111b:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80111e:	48 89 c2             	mov    %rax,%rdx
  801121:	48 f7 da             	neg    %rdx
  801124:	45 85 c9             	test   %r9d,%r9d
  801127:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80112b:	c3                   	retq   
