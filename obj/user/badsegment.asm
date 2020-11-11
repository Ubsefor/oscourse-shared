
obj/user/badsegment:     file format elf64-x86-64


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
  800023:	e8 09 00 00 00       	callq  800031 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv) {
  // Try to load the kernel's TSS selector into the DS register.
  asm volatile("movw $0x38,%ax; movw %ax,%ds");
  80002a:	66 b8 38 00          	mov    $0x38,%ax
  80002e:	8e d8                	mov    %eax,%ds
}
  800030:	c3                   	retq   

0000000000800031 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800031:	55                   	push   %rbp
  800032:	48 89 e5             	mov    %rsp,%rbp
  800035:	41 56                	push   %r14
  800037:	41 55                	push   %r13
  800039:	41 54                	push   %r12
  80003b:	53                   	push   %rbx
  80003c:	41 89 fd             	mov    %edi,%r13d
  80003f:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800042:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800049:	00 00 00 
  80004c:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800053:	00 00 00 
  800056:	48 39 c2             	cmp    %rax,%rdx
  800059:	73 23                	jae    80007e <libmain+0x4d>
  80005b:	48 89 d3             	mov    %rdx,%rbx
  80005e:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800062:	48 29 d0             	sub    %rdx,%rax
  800065:	48 c1 e8 03          	shr    $0x3,%rax
  800069:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80006e:	b8 00 00 00 00       	mov    $0x0,%eax
  800073:	ff 13                	callq  *(%rbx)
    ctor++;
  800075:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800079:	4c 39 e3             	cmp    %r12,%rbx
  80007c:	75 f0                	jne    80006e <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80007e:	45 85 ed             	test   %r13d,%r13d
  800081:	7e 0d                	jle    800090 <libmain+0x5f>
    binaryname = argv[0];
  800083:	49 8b 06             	mov    (%r14),%rax
  800086:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  80008d:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800090:	4c 89 f6             	mov    %r14,%rsi
  800093:	44 89 ef             	mov    %r13d,%edi
  800096:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  80009d:	00 00 00 
  8000a0:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000a2:	48 b8 b7 00 80 00 00 	movabs $0x8000b7,%rax
  8000a9:	00 00 00 
  8000ac:	ff d0                	callq  *%rax
#endif
}
  8000ae:	5b                   	pop    %rbx
  8000af:	41 5c                	pop    %r12
  8000b1:	41 5d                	pop    %r13
  8000b3:	41 5e                	pop    %r14
  8000b5:	5d                   	pop    %rbp
  8000b6:	c3                   	retq   

00000000008000b7 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000b7:	55                   	push   %rbp
  8000b8:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8000c0:	48 b8 0c 01 80 00 00 	movabs $0x80010c,%rax
  8000c7:	00 00 00 
  8000ca:	ff d0                	callq  *%rax
}
  8000cc:	5d                   	pop    %rbp
  8000cd:	c3                   	retq   

00000000008000ce <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000ce:	55                   	push   %rbp
  8000cf:	48 89 e5             	mov    %rsp,%rbp
  8000d2:	53                   	push   %rbx
  8000d3:	48 89 fa             	mov    %rdi,%rdx
  8000d6:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000de:	48 89 c3             	mov    %rax,%rbx
  8000e1:	48 89 c7             	mov    %rax,%rdi
  8000e4:	48 89 c6             	mov    %rax,%rsi
  8000e7:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8000e9:	5b                   	pop    %rbx
  8000ea:	5d                   	pop    %rbp
  8000eb:	c3                   	retq   

00000000008000ec <sys_cgetc>:

int
sys_cgetc(void) {
  8000ec:	55                   	push   %rbp
  8000ed:	48 89 e5             	mov    %rsp,%rbp
  8000f0:	53                   	push   %rbx
  asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fb:	48 89 ca             	mov    %rcx,%rdx
  8000fe:	48 89 cb             	mov    %rcx,%rbx
  800101:	48 89 cf             	mov    %rcx,%rdi
  800104:	48 89 ce             	mov    %rcx,%rsi
  800107:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800109:	5b                   	pop    %rbx
  80010a:	5d                   	pop    %rbp
  80010b:	c3                   	retq   

000000000080010c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80010c:	55                   	push   %rbp
  80010d:	48 89 e5             	mov    %rsp,%rbp
  800110:	53                   	push   %rbx
  800111:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800115:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800118:	be 00 00 00 00       	mov    $0x0,%esi
  80011d:	b8 03 00 00 00       	mov    $0x3,%eax
  800122:	48 89 f1             	mov    %rsi,%rcx
  800125:	48 89 f3             	mov    %rsi,%rbx
  800128:	48 89 f7             	mov    %rsi,%rdi
  80012b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80012d:	48 85 c0             	test   %rax,%rax
  800130:	7f 07                	jg     800139 <sys_env_destroy+0x2d>
}
  800132:	48 83 c4 08          	add    $0x8,%rsp
  800136:	5b                   	pop    %rbx
  800137:	5d                   	pop    %rbp
  800138:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800139:	49 89 c0             	mov    %rax,%r8
  80013c:	b9 03 00 00 00       	mov    $0x3,%ecx
  800141:	48 ba 50 11 80 00 00 	movabs $0x801150,%rdx
  800148:	00 00 00 
  80014b:	be 22 00 00 00       	mov    $0x22,%esi
  800150:	48 bf 6f 11 80 00 00 	movabs $0x80116f,%rdi
  800157:	00 00 00 
  80015a:	b8 00 00 00 00       	mov    $0x0,%eax
  80015f:	49 b9 8c 01 80 00 00 	movabs $0x80018c,%r9
  800166:	00 00 00 
  800169:	41 ff d1             	callq  *%r9

000000000080016c <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80016c:	55                   	push   %rbp
  80016d:	48 89 e5             	mov    %rsp,%rbp
  800170:	53                   	push   %rbx
  asm volatile("int %1\n"
  800171:	b9 00 00 00 00       	mov    $0x0,%ecx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	48 89 ca             	mov    %rcx,%rdx
  80017e:	48 89 cb             	mov    %rcx,%rbx
  800181:	48 89 cf             	mov    %rcx,%rdi
  800184:	48 89 ce             	mov    %rcx,%rsi
  800187:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800189:	5b                   	pop    %rbx
  80018a:	5d                   	pop    %rbp
  80018b:	c3                   	retq   

000000000080018c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80018c:	55                   	push   %rbp
  80018d:	48 89 e5             	mov    %rsp,%rbp
  800190:	41 56                	push   %r14
  800192:	41 55                	push   %r13
  800194:	41 54                	push   %r12
  800196:	53                   	push   %rbx
  800197:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80019e:	49 89 fd             	mov    %rdi,%r13
  8001a1:	41 89 f6             	mov    %esi,%r14d
  8001a4:	49 89 d4             	mov    %rdx,%r12
  8001a7:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001ae:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001b5:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001bc:	84 c0                	test   %al,%al
  8001be:	74 26                	je     8001e6 <_panic+0x5a>
  8001c0:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001c7:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001ce:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001d2:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001d6:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001da:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001de:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001e2:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8001e6:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8001ed:	00 00 00 
  8001f0:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8001f7:	00 00 00 
  8001fa:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8001fe:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800205:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80020c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800213:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80021a:	00 00 00 
  80021d:	48 8b 18             	mov    (%rax),%rbx
  800220:	48 b8 6c 01 80 00 00 	movabs $0x80016c,%rax
  800227:	00 00 00 
  80022a:	ff d0                	callq  *%rax
  80022c:	45 89 f0             	mov    %r14d,%r8d
  80022f:	4c 89 e9             	mov    %r13,%rcx
  800232:	48 89 da             	mov    %rbx,%rdx
  800235:	89 c6                	mov    %eax,%esi
  800237:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  80023e:	00 00 00 
  800241:	b8 00 00 00 00       	mov    $0x0,%eax
  800246:	48 bb 2e 03 80 00 00 	movabs $0x80032e,%rbx
  80024d:	00 00 00 
  800250:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800252:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800259:	4c 89 e7             	mov    %r12,%rdi
  80025c:	48 b8 c6 02 80 00 00 	movabs $0x8002c6,%rax
  800263:	00 00 00 
  800266:	ff d0                	callq  *%rax
  cprintf("\n");
  800268:	48 bf a8 11 80 00 00 	movabs $0x8011a8,%rdi
  80026f:	00 00 00 
  800272:	b8 00 00 00 00       	mov    $0x0,%eax
  800277:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800279:	cc                   	int3   
  while (1)
  80027a:	eb fd                	jmp    800279 <_panic+0xed>

000000000080027c <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80027c:	55                   	push   %rbp
  80027d:	48 89 e5             	mov    %rsp,%rbp
  800280:	53                   	push   %rbx
  800281:	48 83 ec 08          	sub    $0x8,%rsp
  800285:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800288:	8b 06                	mov    (%rsi),%eax
  80028a:	8d 50 01             	lea    0x1(%rax),%edx
  80028d:	89 16                	mov    %edx,(%rsi)
  80028f:	48 98                	cltq   
  800291:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800296:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80029c:	74 0b                	je     8002a9 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80029e:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002a2:	48 83 c4 08          	add    $0x8,%rsp
  8002a6:	5b                   	pop    %rbx
  8002a7:	5d                   	pop    %rbp
  8002a8:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002a9:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002ad:	be ff 00 00 00       	mov    $0xff,%esi
  8002b2:	48 b8 ce 00 80 00 00 	movabs $0x8000ce,%rax
  8002b9:	00 00 00 
  8002bc:	ff d0                	callq  *%rax
    b->idx = 0;
  8002be:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002c4:	eb d8                	jmp    80029e <putch+0x22>

00000000008002c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002c6:	55                   	push   %rbp
  8002c7:	48 89 e5             	mov    %rsp,%rbp
  8002ca:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002d1:	48 89 fa             	mov    %rdi,%rdx
  8002d4:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002de:	00 00 00 
  b.cnt = 0;
  8002e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002e8:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8002eb:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8002f2:	48 bf 7c 02 80 00 00 	movabs $0x80027c,%rdi
  8002f9:	00 00 00 
  8002fc:	48 b8 ec 04 80 00 00 	movabs $0x8004ec,%rax
  800303:	00 00 00 
  800306:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800308:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80030f:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800316:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80031a:	48 b8 ce 00 80 00 00 	movabs $0x8000ce,%rax
  800321:	00 00 00 
  800324:	ff d0                	callq  *%rax

  return b.cnt;
}
  800326:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80032c:	c9                   	leaveq 
  80032d:	c3                   	retq   

000000000080032e <cprintf>:

int
cprintf(const char *fmt, ...) {
  80032e:	55                   	push   %rbp
  80032f:	48 89 e5             	mov    %rsp,%rbp
  800332:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800339:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800340:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800347:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80034e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800355:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80035c:	84 c0                	test   %al,%al
  80035e:	74 20                	je     800380 <cprintf+0x52>
  800360:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800364:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800368:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80036c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800370:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800374:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800378:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80037c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800380:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800387:	00 00 00 
  80038a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800391:	00 00 00 
  800394:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800398:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80039f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003a6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003ad:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003b4:	48 b8 c6 02 80 00 00 	movabs $0x8002c6,%rax
  8003bb:	00 00 00 
  8003be:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003c0:	c9                   	leaveq 
  8003c1:	c3                   	retq   

00000000008003c2 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003c2:	55                   	push   %rbp
  8003c3:	48 89 e5             	mov    %rsp,%rbp
  8003c6:	41 57                	push   %r15
  8003c8:	41 56                	push   %r14
  8003ca:	41 55                	push   %r13
  8003cc:	41 54                	push   %r12
  8003ce:	53                   	push   %rbx
  8003cf:	48 83 ec 18          	sub    $0x18,%rsp
  8003d3:	49 89 fc             	mov    %rdi,%r12
  8003d6:	49 89 f5             	mov    %rsi,%r13
  8003d9:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003dd:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003e0:	41 89 cf             	mov    %ecx,%r15d
  8003e3:	49 39 d7             	cmp    %rdx,%r15
  8003e6:	76 45                	jbe    80042d <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003e8:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8003ec:	85 db                	test   %ebx,%ebx
  8003ee:	7e 0e                	jle    8003fe <printnum+0x3c>
      putch(padc, putdat);
  8003f0:	4c 89 ee             	mov    %r13,%rsi
  8003f3:	44 89 f7             	mov    %r14d,%edi
  8003f6:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8003f9:	83 eb 01             	sub    $0x1,%ebx
  8003fc:	75 f2                	jne    8003f0 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8003fe:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
  800407:	49 f7 f7             	div    %r15
  80040a:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  800411:	00 00 00 
  800414:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800418:	4c 89 ee             	mov    %r13,%rsi
  80041b:	41 ff d4             	callq  *%r12
}
  80041e:	48 83 c4 18          	add    $0x18,%rsp
  800422:	5b                   	pop    %rbx
  800423:	41 5c                	pop    %r12
  800425:	41 5d                	pop    %r13
  800427:	41 5e                	pop    %r14
  800429:	41 5f                	pop    %r15
  80042b:	5d                   	pop    %rbp
  80042c:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80042d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	49 f7 f7             	div    %r15
  800439:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80043d:	48 89 c2             	mov    %rax,%rdx
  800440:	48 b8 c2 03 80 00 00 	movabs $0x8003c2,%rax
  800447:	00 00 00 
  80044a:	ff d0                	callq  *%rax
  80044c:	eb b0                	jmp    8003fe <printnum+0x3c>

000000000080044e <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80044e:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800452:	48 8b 06             	mov    (%rsi),%rax
  800455:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800459:	73 0a                	jae    800465 <sprintputch+0x17>
    *b->buf++ = ch;
  80045b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80045f:	48 89 16             	mov    %rdx,(%rsi)
  800462:	40 88 38             	mov    %dil,(%rax)
}
  800465:	c3                   	retq   

0000000000800466 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800466:	55                   	push   %rbp
  800467:	48 89 e5             	mov    %rsp,%rbp
  80046a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800471:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800478:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80047f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800486:	84 c0                	test   %al,%al
  800488:	74 20                	je     8004aa <printfmt+0x44>
  80048a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80048e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800492:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800496:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80049a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80049e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004a2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004a6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004aa:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004b1:	00 00 00 
  8004b4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004bb:	00 00 00 
  8004be:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004c2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004c9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004d0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004d7:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004de:	48 b8 ec 04 80 00 00 	movabs $0x8004ec,%rax
  8004e5:	00 00 00 
  8004e8:	ff d0                	callq  *%rax
}
  8004ea:	c9                   	leaveq 
  8004eb:	c3                   	retq   

00000000008004ec <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8004ec:	55                   	push   %rbp
  8004ed:	48 89 e5             	mov    %rsp,%rbp
  8004f0:	41 57                	push   %r15
  8004f2:	41 56                	push   %r14
  8004f4:	41 55                	push   %r13
  8004f6:	41 54                	push   %r12
  8004f8:	53                   	push   %rbx
  8004f9:	48 83 ec 48          	sub    $0x48,%rsp
  8004fd:	49 89 fd             	mov    %rdi,%r13
  800500:	49 89 f7             	mov    %rsi,%r15
  800503:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800506:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80050a:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80050e:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800512:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800516:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80051a:	41 0f b6 3e          	movzbl (%r14),%edi
  80051e:	83 ff 25             	cmp    $0x25,%edi
  800521:	74 18                	je     80053b <vprintfmt+0x4f>
      if (ch == '\0')
  800523:	85 ff                	test   %edi,%edi
  800525:	0f 84 8c 06 00 00    	je     800bb7 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80052b:	4c 89 fe             	mov    %r15,%rsi
  80052e:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800531:	49 89 de             	mov    %rbx,%r14
  800534:	eb e0                	jmp    800516 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800536:	49 89 de             	mov    %rbx,%r14
  800539:	eb db                	jmp    800516 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80053b:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80053f:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800543:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80054a:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800550:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800554:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800559:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80055f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800565:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80056a:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80056f:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800573:	0f b6 13             	movzbl (%rbx),%edx
  800576:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800579:	3c 55                	cmp    $0x55,%al
  80057b:	0f 87 8b 05 00 00    	ja     800b0c <vprintfmt+0x620>
  800581:	0f b6 c0             	movzbl %al,%eax
  800584:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  80058b:	00 00 00 
  80058e:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800592:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800595:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800599:	eb d4                	jmp    80056f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80059b:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80059e:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005a2:	eb cb                	jmp    80056f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005a4:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005a7:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005ab:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005af:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005b2:	83 fa 09             	cmp    $0x9,%edx
  8005b5:	77 7e                	ja     800635 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005b7:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005bb:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005bf:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005c4:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005c8:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005cb:	83 fa 09             	cmp    $0x9,%edx
  8005ce:	76 e7                	jbe    8005b7 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005d0:	4c 89 f3             	mov    %r14,%rbx
  8005d3:	eb 19                	jmp    8005ee <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005d5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005d8:	83 f8 2f             	cmp    $0x2f,%eax
  8005db:	77 2a                	ja     800607 <vprintfmt+0x11b>
  8005dd:	89 c2                	mov    %eax,%edx
  8005df:	4c 01 d2             	add    %r10,%rdx
  8005e2:	83 c0 08             	add    $0x8,%eax
  8005e5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005e8:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8005eb:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8005ee:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005f2:	0f 89 77 ff ff ff    	jns    80056f <vprintfmt+0x83>
          width = precision, precision = -1;
  8005f8:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8005fc:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800602:	e9 68 ff ff ff       	jmpq   80056f <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800607:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80060b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80060f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800613:	eb d3                	jmp    8005e8 <vprintfmt+0xfc>
        if (width < 0)
  800615:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800618:	85 c0                	test   %eax,%eax
  80061a:	41 0f 48 c0          	cmovs  %r8d,%eax
  80061e:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800621:	4c 89 f3             	mov    %r14,%rbx
  800624:	e9 46 ff ff ff       	jmpq   80056f <vprintfmt+0x83>
  800629:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80062c:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800630:	e9 3a ff ff ff       	jmpq   80056f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800635:	4c 89 f3             	mov    %r14,%rbx
  800638:	eb b4                	jmp    8005ee <vprintfmt+0x102>
        lflag++;
  80063a:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80063d:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800640:	e9 2a ff ff ff       	jmpq   80056f <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800645:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800648:	83 f8 2f             	cmp    $0x2f,%eax
  80064b:	77 19                	ja     800666 <vprintfmt+0x17a>
  80064d:	89 c2                	mov    %eax,%edx
  80064f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800653:	83 c0 08             	add    $0x8,%eax
  800656:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800659:	4c 89 fe             	mov    %r15,%rsi
  80065c:	8b 3a                	mov    (%rdx),%edi
  80065e:	41 ff d5             	callq  *%r13
        break;
  800661:	e9 b0 fe ff ff       	jmpq   800516 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800666:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80066a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80066e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800672:	eb e5                	jmp    800659 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800674:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800677:	83 f8 2f             	cmp    $0x2f,%eax
  80067a:	77 5b                	ja     8006d7 <vprintfmt+0x1eb>
  80067c:	89 c2                	mov    %eax,%edx
  80067e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800682:	83 c0 08             	add    $0x8,%eax
  800685:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800688:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80068a:	89 c8                	mov    %ecx,%eax
  80068c:	c1 f8 1f             	sar    $0x1f,%eax
  80068f:	31 c1                	xor    %eax,%ecx
  800691:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800693:	83 f9 09             	cmp    $0x9,%ecx
  800696:	7f 4d                	jg     8006e5 <vprintfmt+0x1f9>
  800698:	48 63 c1             	movslq %ecx,%rax
  80069b:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  8006a2:	00 00 00 
  8006a5:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006a9:	48 85 c0             	test   %rax,%rax
  8006ac:	74 37                	je     8006e5 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006ae:	48 89 c1             	mov    %rax,%rcx
  8006b1:	48 ba cb 11 80 00 00 	movabs $0x8011cb,%rdx
  8006b8:	00 00 00 
  8006bb:	4c 89 fe             	mov    %r15,%rsi
  8006be:	4c 89 ef             	mov    %r13,%rdi
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c6:	48 bb 66 04 80 00 00 	movabs $0x800466,%rbx
  8006cd:	00 00 00 
  8006d0:	ff d3                	callq  *%rbx
  8006d2:	e9 3f fe ff ff       	jmpq   800516 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006e3:	eb a3                	jmp    800688 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006e5:	48 ba c2 11 80 00 00 	movabs $0x8011c2,%rdx
  8006ec:	00 00 00 
  8006ef:	4c 89 fe             	mov    %r15,%rsi
  8006f2:	4c 89 ef             	mov    %r13,%rdi
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	48 bb 66 04 80 00 00 	movabs $0x800466,%rbx
  800701:	00 00 00 
  800704:	ff d3                	callq  *%rbx
  800706:	e9 0b fe ff ff       	jmpq   800516 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80070b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80070e:	83 f8 2f             	cmp    $0x2f,%eax
  800711:	77 4b                	ja     80075e <vprintfmt+0x272>
  800713:	89 c2                	mov    %eax,%edx
  800715:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800719:	83 c0 08             	add    $0x8,%eax
  80071c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80071f:	48 8b 02             	mov    (%rdx),%rax
  800722:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800726:	48 85 c0             	test   %rax,%rax
  800729:	0f 84 05 04 00 00    	je     800b34 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80072f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800733:	7e 06                	jle    80073b <vprintfmt+0x24f>
  800735:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800739:	75 31                	jne    80076c <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80073f:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800743:	0f b6 00             	movzbl (%rax),%eax
  800746:	0f be f8             	movsbl %al,%edi
  800749:	85 ff                	test   %edi,%edi
  80074b:	0f 84 c3 00 00 00    	je     800814 <vprintfmt+0x328>
  800751:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800755:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800759:	e9 85 00 00 00       	jmpq   8007e3 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80075e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800762:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800766:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80076a:	eb b3                	jmp    80071f <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80076c:	49 63 f4             	movslq %r12d,%rsi
  80076f:	48 89 c7             	mov    %rax,%rdi
  800772:	48 b8 c3 0c 80 00 00 	movabs $0x800cc3,%rax
  800779:	00 00 00 
  80077c:	ff d0                	callq  *%rax
  80077e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800781:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800784:	85 f6                	test   %esi,%esi
  800786:	7e 22                	jle    8007aa <vprintfmt+0x2be>
            putch(padc, putdat);
  800788:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80078c:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800790:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800794:	4c 89 fe             	mov    %r15,%rsi
  800797:	89 df                	mov    %ebx,%edi
  800799:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80079c:	41 83 ec 01          	sub    $0x1,%r12d
  8007a0:	75 f2                	jne    800794 <vprintfmt+0x2a8>
  8007a2:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007a6:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007aa:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007ae:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007b2:	0f b6 00             	movzbl (%rax),%eax
  8007b5:	0f be f8             	movsbl %al,%edi
  8007b8:	85 ff                	test   %edi,%edi
  8007ba:	0f 84 56 fd ff ff    	je     800516 <vprintfmt+0x2a>
  8007c0:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007c4:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007c8:	eb 19                	jmp    8007e3 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007ca:	4c 89 fe             	mov    %r15,%rsi
  8007cd:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d0:	41 83 ee 01          	sub    $0x1,%r14d
  8007d4:	48 83 c3 01          	add    $0x1,%rbx
  8007d8:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007dc:	0f be f8             	movsbl %al,%edi
  8007df:	85 ff                	test   %edi,%edi
  8007e1:	74 29                	je     80080c <vprintfmt+0x320>
  8007e3:	45 85 e4             	test   %r12d,%r12d
  8007e6:	78 06                	js     8007ee <vprintfmt+0x302>
  8007e8:	41 83 ec 01          	sub    $0x1,%r12d
  8007ec:	78 48                	js     800836 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8007ee:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8007f2:	74 d6                	je     8007ca <vprintfmt+0x2de>
  8007f4:	0f be c0             	movsbl %al,%eax
  8007f7:	83 e8 20             	sub    $0x20,%eax
  8007fa:	83 f8 5e             	cmp    $0x5e,%eax
  8007fd:	76 cb                	jbe    8007ca <vprintfmt+0x2de>
            putch('?', putdat);
  8007ff:	4c 89 fe             	mov    %r15,%rsi
  800802:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800807:	41 ff d5             	callq  *%r13
  80080a:	eb c4                	jmp    8007d0 <vprintfmt+0x2e4>
  80080c:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800810:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800814:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800817:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80081b:	0f 8e f5 fc ff ff    	jle    800516 <vprintfmt+0x2a>
          putch(' ', putdat);
  800821:	4c 89 fe             	mov    %r15,%rsi
  800824:	bf 20 00 00 00       	mov    $0x20,%edi
  800829:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80082c:	83 eb 01             	sub    $0x1,%ebx
  80082f:	75 f0                	jne    800821 <vprintfmt+0x335>
  800831:	e9 e0 fc ff ff       	jmpq   800516 <vprintfmt+0x2a>
  800836:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80083a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80083e:	eb d4                	jmp    800814 <vprintfmt+0x328>
  if (lflag >= 2)
  800840:	83 f9 01             	cmp    $0x1,%ecx
  800843:	7f 1d                	jg     800862 <vprintfmt+0x376>
  else if (lflag)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 5e                	je     8008a7 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800849:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80084c:	83 f8 2f             	cmp    $0x2f,%eax
  80084f:	77 48                	ja     800899 <vprintfmt+0x3ad>
  800851:	89 c2                	mov    %eax,%edx
  800853:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800857:	83 c0 08             	add    $0x8,%eax
  80085a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80085d:	48 8b 1a             	mov    (%rdx),%rbx
  800860:	eb 17                	jmp    800879 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800862:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800865:	83 f8 2f             	cmp    $0x2f,%eax
  800868:	77 21                	ja     80088b <vprintfmt+0x39f>
  80086a:	89 c2                	mov    %eax,%edx
  80086c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800870:	83 c0 08             	add    $0x8,%eax
  800873:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800876:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800879:	48 85 db             	test   %rbx,%rbx
  80087c:	78 50                	js     8008ce <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80087e:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800881:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800886:	e9 b4 01 00 00       	jmpq   800a3f <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80088b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800893:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800897:	eb dd                	jmp    800876 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800899:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80089d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008a1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a5:	eb b6                	jmp    80085d <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008a7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008aa:	83 f8 2f             	cmp    $0x2f,%eax
  8008ad:	77 11                	ja     8008c0 <vprintfmt+0x3d4>
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b5:	83 c0 08             	add    $0x8,%eax
  8008b8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008bb:	48 63 1a             	movslq (%rdx),%rbx
  8008be:	eb b9                	jmp    800879 <vprintfmt+0x38d>
  8008c0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008cc:	eb ed                	jmp    8008bb <vprintfmt+0x3cf>
          putch('-', putdat);
  8008ce:	4c 89 fe             	mov    %r15,%rsi
  8008d1:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008d6:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008d9:	48 89 da             	mov    %rbx,%rdx
  8008dc:	48 f7 da             	neg    %rdx
        base = 10;
  8008df:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008e4:	e9 56 01 00 00       	jmpq   800a3f <vprintfmt+0x553>
  if (lflag >= 2)
  8008e9:	83 f9 01             	cmp    $0x1,%ecx
  8008ec:	7f 25                	jg     800913 <vprintfmt+0x427>
  else if (lflag)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 5e                	je     800950 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8008f2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f5:	83 f8 2f             	cmp    $0x2f,%eax
  8008f8:	77 48                	ja     800942 <vprintfmt+0x456>
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800900:	83 c0 08             	add    $0x8,%eax
  800903:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800906:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090e:	e9 2c 01 00 00       	jmpq   800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800913:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800916:	83 f8 2f             	cmp    $0x2f,%eax
  800919:	77 19                	ja     800934 <vprintfmt+0x448>
  80091b:	89 c2                	mov    %eax,%edx
  80091d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800921:	83 c0 08             	add    $0x8,%eax
  800924:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800927:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80092a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092f:	e9 0b 01 00 00       	jmpq   800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800934:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800938:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800940:	eb e5                	jmp    800927 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800942:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800946:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094e:	eb b6                	jmp    800906 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800950:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800953:	83 f8 2f             	cmp    $0x2f,%eax
  800956:	77 18                	ja     800970 <vprintfmt+0x484>
  800958:	89 c2                	mov    %eax,%edx
  80095a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095e:	83 c0 08             	add    $0x8,%eax
  800961:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800964:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800966:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80096b:	e9 cf 00 00 00       	jmpq   800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800970:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800974:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800978:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097c:	eb e6                	jmp    800964 <vprintfmt+0x478>
  if (lflag >= 2)
  80097e:	83 f9 01             	cmp    $0x1,%ecx
  800981:	7f 25                	jg     8009a8 <vprintfmt+0x4bc>
  else if (lflag)
  800983:	85 c9                	test   %ecx,%ecx
  800985:	74 5b                	je     8009e2 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800987:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80098a:	83 f8 2f             	cmp    $0x2f,%eax
  80098d:	77 45                	ja     8009d4 <vprintfmt+0x4e8>
  80098f:	89 c2                	mov    %eax,%edx
  800991:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800995:	83 c0 08             	add    $0x8,%eax
  800998:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80099b:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80099e:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009a3:	e9 97 00 00 00       	jmpq   800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009a8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ab:	83 f8 2f             	cmp    $0x2f,%eax
  8009ae:	77 16                	ja     8009c6 <vprintfmt+0x4da>
  8009b0:	89 c2                	mov    %eax,%edx
  8009b2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009b6:	83 c0 08             	add    $0x8,%eax
  8009b9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009bc:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009bf:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009c4:	eb 79                	jmp    800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009c6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ca:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ce:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009d2:	eb e8                	jmp    8009bc <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009d4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009dc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e0:	eb b9                	jmp    80099b <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009e2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e5:	83 f8 2f             	cmp    $0x2f,%eax
  8009e8:	77 15                	ja     8009ff <vprintfmt+0x513>
  8009ea:	89 c2                	mov    %eax,%edx
  8009ec:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f0:	83 c0 08             	add    $0x8,%eax
  8009f3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f6:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8009f8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009fd:	eb 40                	jmp    800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a03:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a0b:	eb e9                	jmp    8009f6 <vprintfmt+0x50a>
        putch('0', putdat);
  800a0d:	4c 89 fe             	mov    %r15,%rsi
  800a10:	bf 30 00 00 00       	mov    $0x30,%edi
  800a15:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a18:	4c 89 fe             	mov    %r15,%rsi
  800a1b:	bf 78 00 00 00       	mov    $0x78,%edi
  800a20:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a23:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a26:	83 f8 2f             	cmp    $0x2f,%eax
  800a29:	77 34                	ja     800a5f <vprintfmt+0x573>
  800a2b:	89 c2                	mov    %eax,%edx
  800a2d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a31:	83 c0 08             	add    $0x8,%eax
  800a34:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a37:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a3a:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a3f:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a44:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a48:	4c 89 fe             	mov    %r15,%rsi
  800a4b:	4c 89 ef             	mov    %r13,%rdi
  800a4e:	48 b8 c2 03 80 00 00 	movabs $0x8003c2,%rax
  800a55:	00 00 00 
  800a58:	ff d0                	callq  *%rax
        break;
  800a5a:	e9 b7 fa ff ff       	jmpq   800516 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a5f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a63:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a67:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a6b:	eb ca                	jmp    800a37 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a6d:	83 f9 01             	cmp    $0x1,%ecx
  800a70:	7f 22                	jg     800a94 <vprintfmt+0x5a8>
  else if (lflag)
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	74 58                	je     800ace <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a76:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a79:	83 f8 2f             	cmp    $0x2f,%eax
  800a7c:	77 42                	ja     800ac0 <vprintfmt+0x5d4>
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a84:	83 c0 08             	add    $0x8,%eax
  800a87:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a8a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a8d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a92:	eb ab                	jmp    800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a94:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a97:	83 f8 2f             	cmp    $0x2f,%eax
  800a9a:	77 16                	ja     800ab2 <vprintfmt+0x5c6>
  800a9c:	89 c2                	mov    %eax,%edx
  800a9e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aa2:	83 c0 08             	add    $0x8,%eax
  800aa5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aa8:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aab:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ab0:	eb 8d                	jmp    800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ab2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ab6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aba:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800abe:	eb e8                	jmp    800aa8 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800ac0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ac4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ac8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800acc:	eb bc                	jmp    800a8a <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ace:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ad1:	83 f8 2f             	cmp    $0x2f,%eax
  800ad4:	77 18                	ja     800aee <vprintfmt+0x602>
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800adc:	83 c0 08             	add    $0x8,%eax
  800adf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ae2:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800ae4:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae9:	e9 51 ff ff ff       	jmpq   800a3f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800aee:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800af2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800afa:	eb e6                	jmp    800ae2 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800afc:	4c 89 fe             	mov    %r15,%rsi
  800aff:	bf 25 00 00 00       	mov    $0x25,%edi
  800b04:	41 ff d5             	callq  *%r13
        break;
  800b07:	e9 0a fa ff ff       	jmpq   800516 <vprintfmt+0x2a>
        putch('%', putdat);
  800b0c:	4c 89 fe             	mov    %r15,%rsi
  800b0f:	bf 25 00 00 00       	mov    $0x25,%edi
  800b14:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b17:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b1b:	0f 84 15 fa ff ff    	je     800536 <vprintfmt+0x4a>
  800b21:	49 89 de             	mov    %rbx,%r14
  800b24:	49 83 ee 01          	sub    $0x1,%r14
  800b28:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b2d:	75 f5                	jne    800b24 <vprintfmt+0x638>
  800b2f:	e9 e2 f9 ff ff       	jmpq   800516 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b34:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b38:	74 06                	je     800b40 <vprintfmt+0x654>
  800b3a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b3e:	7f 21                	jg     800b61 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b40:	bf 28 00 00 00       	mov    $0x28,%edi
  800b45:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800b4c:	00 00 00 
  800b4f:	b8 28 00 00 00       	mov    $0x28,%eax
  800b54:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b58:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b5c:	e9 82 fc ff ff       	jmpq   8007e3 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b61:	49 63 f4             	movslq %r12d,%rsi
  800b64:	48 bf bb 11 80 00 00 	movabs $0x8011bb,%rdi
  800b6b:	00 00 00 
  800b6e:	48 b8 c3 0c 80 00 00 	movabs $0x800cc3,%rax
  800b75:	00 00 00 
  800b78:	ff d0                	callq  *%rax
  800b7a:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b7d:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b80:	48 be bb 11 80 00 00 	movabs $0x8011bb,%rsi
  800b87:	00 00 00 
  800b8a:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	0f 8f f2 fb ff ff    	jg     800788 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b96:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800b9d:	00 00 00 
  800ba0:	b8 28 00 00 00       	mov    $0x28,%eax
  800ba5:	bf 28 00 00 00       	mov    $0x28,%edi
  800baa:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bae:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bb2:	e9 2c fc ff ff       	jmpq   8007e3 <vprintfmt+0x2f7>
}
  800bb7:	48 83 c4 48          	add    $0x48,%rsp
  800bbb:	5b                   	pop    %rbx
  800bbc:	41 5c                	pop    %r12
  800bbe:	41 5d                	pop    %r13
  800bc0:	41 5e                	pop    %r14
  800bc2:	41 5f                	pop    %r15
  800bc4:	5d                   	pop    %rbp
  800bc5:	c3                   	retq   

0000000000800bc6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bc6:	55                   	push   %rbp
  800bc7:	48 89 e5             	mov    %rsp,%rbp
  800bca:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bce:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bd2:	48 63 c6             	movslq %esi,%rax
  800bd5:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bda:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bde:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800be5:	48 85 ff             	test   %rdi,%rdi
  800be8:	74 2a                	je     800c14 <vsnprintf+0x4e>
  800bea:	85 f6                	test   %esi,%esi
  800bec:	7e 26                	jle    800c14 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800bee:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800bf2:	48 bf 4e 04 80 00 00 	movabs $0x80044e,%rdi
  800bf9:	00 00 00 
  800bfc:	48 b8 ec 04 80 00 00 	movabs $0x8004ec,%rax
  800c03:	00 00 00 
  800c06:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c08:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c0c:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c0f:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c12:	c9                   	leaveq 
  800c13:	c3                   	retq   
    return -E_INVAL;
  800c14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c19:	eb f7                	jmp    800c12 <vsnprintf+0x4c>

0000000000800c1b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c1b:	55                   	push   %rbp
  800c1c:	48 89 e5             	mov    %rsp,%rbp
  800c1f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c26:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c2d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c34:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c3b:	84 c0                	test   %al,%al
  800c3d:	74 20                	je     800c5f <snprintf+0x44>
  800c3f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c43:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c47:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c4b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c4f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c53:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c57:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c5b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c5f:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c66:	00 00 00 
  800c69:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c70:	00 00 00 
  800c73:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c77:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c7e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c85:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c8c:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c93:	48 b8 c6 0b 80 00 00 	movabs $0x800bc6,%rax
  800c9a:	00 00 00 
  800c9d:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800c9f:	c9                   	leaveq 
  800ca0:	c3                   	retq   

0000000000800ca1 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800ca1:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ca4:	74 17                	je     800cbd <strlen+0x1c>
  800ca6:	48 89 fa             	mov    %rdi,%rdx
  800ca9:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cae:	29 f9                	sub    %edi,%ecx
    n++;
  800cb0:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cb3:	48 83 c2 01          	add    $0x1,%rdx
  800cb7:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cba:	75 f4                	jne    800cb0 <strlen+0xf>
  800cbc:	c3                   	retq   
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cc2:	c3                   	retq   

0000000000800cc3 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc3:	48 85 f6             	test   %rsi,%rsi
  800cc6:	74 24                	je     800cec <strnlen+0x29>
  800cc8:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ccb:	74 25                	je     800cf2 <strnlen+0x2f>
  800ccd:	48 01 fe             	add    %rdi,%rsi
  800cd0:	48 89 fa             	mov    %rdi,%rdx
  800cd3:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cd8:	29 f9                	sub    %edi,%ecx
    n++;
  800cda:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdd:	48 83 c2 01          	add    $0x1,%rdx
  800ce1:	48 39 f2             	cmp    %rsi,%rdx
  800ce4:	74 11                	je     800cf7 <strnlen+0x34>
  800ce6:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ce9:	75 ef                	jne    800cda <strnlen+0x17>
  800ceb:	c3                   	retq   
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	c3                   	retq   
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cf7:	c3                   	retq   

0000000000800cf8 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800cf8:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d04:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d07:	48 83 c2 01          	add    $0x1,%rdx
  800d0b:	84 c9                	test   %cl,%cl
  800d0d:	75 f1                	jne    800d00 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d0f:	c3                   	retq   

0000000000800d10 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d10:	55                   	push   %rbp
  800d11:	48 89 e5             	mov    %rsp,%rbp
  800d14:	41 54                	push   %r12
  800d16:	53                   	push   %rbx
  800d17:	48 89 fb             	mov    %rdi,%rbx
  800d1a:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d1d:	48 b8 a1 0c 80 00 00 	movabs $0x800ca1,%rax
  800d24:	00 00 00 
  800d27:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d29:	48 63 f8             	movslq %eax,%rdi
  800d2c:	48 01 df             	add    %rbx,%rdi
  800d2f:	4c 89 e6             	mov    %r12,%rsi
  800d32:	48 b8 f8 0c 80 00 00 	movabs $0x800cf8,%rax
  800d39:	00 00 00 
  800d3c:	ff d0                	callq  *%rax
  return dst;
}
  800d3e:	48 89 d8             	mov    %rbx,%rax
  800d41:	5b                   	pop    %rbx
  800d42:	41 5c                	pop    %r12
  800d44:	5d                   	pop    %rbp
  800d45:	c3                   	retq   

0000000000800d46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d46:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d49:	48 85 d2             	test   %rdx,%rdx
  800d4c:	74 1f                	je     800d6d <strncpy+0x27>
  800d4e:	48 01 fa             	add    %rdi,%rdx
  800d51:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d54:	48 83 c1 01          	add    $0x1,%rcx
  800d58:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d5c:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d60:	41 80 f8 01          	cmp    $0x1,%r8b
  800d64:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d68:	48 39 ca             	cmp    %rcx,%rdx
  800d6b:	75 e7                	jne    800d54 <strncpy+0xe>
  }
  return ret;
}
  800d6d:	c3                   	retq   

0000000000800d6e <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d6e:	48 89 f8             	mov    %rdi,%rax
  800d71:	48 85 d2             	test   %rdx,%rdx
  800d74:	74 36                	je     800dac <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d76:	48 83 fa 01          	cmp    $0x1,%rdx
  800d7a:	74 2d                	je     800da9 <strlcpy+0x3b>
  800d7c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d80:	45 84 c0             	test   %r8b,%r8b
  800d83:	74 24                	je     800da9 <strlcpy+0x3b>
  800d85:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d89:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d8e:	48 83 c0 01          	add    $0x1,%rax
  800d92:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d96:	48 39 d1             	cmp    %rdx,%rcx
  800d99:	74 0e                	je     800da9 <strlcpy+0x3b>
  800d9b:	48 83 c1 01          	add    $0x1,%rcx
  800d9f:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800da4:	45 84 c0             	test   %r8b,%r8b
  800da7:	75 e5                	jne    800d8e <strlcpy+0x20>
    *dst = '\0';
  800da9:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dac:	48 29 f8             	sub    %rdi,%rax
}
  800daf:	c3                   	retq   

0000000000800db0 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800db0:	0f b6 07             	movzbl (%rdi),%eax
  800db3:	84 c0                	test   %al,%al
  800db5:	74 17                	je     800dce <strcmp+0x1e>
  800db7:	3a 06                	cmp    (%rsi),%al
  800db9:	75 13                	jne    800dce <strcmp+0x1e>
    p++, q++;
  800dbb:	48 83 c7 01          	add    $0x1,%rdi
  800dbf:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dc3:	0f b6 07             	movzbl (%rdi),%eax
  800dc6:	84 c0                	test   %al,%al
  800dc8:	74 04                	je     800dce <strcmp+0x1e>
  800dca:	3a 06                	cmp    (%rsi),%al
  800dcc:	74 ed                	je     800dbb <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dce:	0f b6 c0             	movzbl %al,%eax
  800dd1:	0f b6 16             	movzbl (%rsi),%edx
  800dd4:	29 d0                	sub    %edx,%eax
}
  800dd6:	c3                   	retq   

0000000000800dd7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800dd7:	48 85 d2             	test   %rdx,%rdx
  800dda:	74 2f                	je     800e0b <strncmp+0x34>
  800ddc:	0f b6 07             	movzbl (%rdi),%eax
  800ddf:	84 c0                	test   %al,%al
  800de1:	74 1f                	je     800e02 <strncmp+0x2b>
  800de3:	3a 06                	cmp    (%rsi),%al
  800de5:	75 1b                	jne    800e02 <strncmp+0x2b>
  800de7:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800dea:	48 83 c7 01          	add    $0x1,%rdi
  800dee:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800df2:	48 39 d7             	cmp    %rdx,%rdi
  800df5:	74 1a                	je     800e11 <strncmp+0x3a>
  800df7:	0f b6 07             	movzbl (%rdi),%eax
  800dfa:	84 c0                	test   %al,%al
  800dfc:	74 04                	je     800e02 <strncmp+0x2b>
  800dfe:	3a 06                	cmp    (%rsi),%al
  800e00:	74 e8                	je     800dea <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e02:	0f b6 07             	movzbl (%rdi),%eax
  800e05:	0f b6 16             	movzbl (%rsi),%edx
  800e08:	29 d0                	sub    %edx,%eax
}
  800e0a:	c3                   	retq   
    return 0;
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e10:	c3                   	retq   
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
  800e16:	c3                   	retq   

0000000000800e17 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e17:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e19:	0f b6 07             	movzbl (%rdi),%eax
  800e1c:	84 c0                	test   %al,%al
  800e1e:	74 1e                	je     800e3e <strchr+0x27>
    if (*s == c)
  800e20:	40 38 c6             	cmp    %al,%sil
  800e23:	74 1f                	je     800e44 <strchr+0x2d>
  for (; *s; s++)
  800e25:	48 83 c7 01          	add    $0x1,%rdi
  800e29:	0f b6 07             	movzbl (%rdi),%eax
  800e2c:	84 c0                	test   %al,%al
  800e2e:	74 08                	je     800e38 <strchr+0x21>
    if (*s == c)
  800e30:	38 d0                	cmp    %dl,%al
  800e32:	75 f1                	jne    800e25 <strchr+0xe>
  for (; *s; s++)
  800e34:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e37:	c3                   	retq   
  return 0;
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3d:	c3                   	retq   
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e43:	c3                   	retq   
    if (*s == c)
  800e44:	48 89 f8             	mov    %rdi,%rax
  800e47:	c3                   	retq   

0000000000800e48 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e48:	48 89 f8             	mov    %rdi,%rax
  800e4b:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e4d:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e50:	40 38 f2             	cmp    %sil,%dl
  800e53:	74 13                	je     800e68 <strfind+0x20>
  800e55:	84 d2                	test   %dl,%dl
  800e57:	74 0f                	je     800e68 <strfind+0x20>
  for (; *s; s++)
  800e59:	48 83 c0 01          	add    $0x1,%rax
  800e5d:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e60:	38 ca                	cmp    %cl,%dl
  800e62:	74 04                	je     800e68 <strfind+0x20>
  800e64:	84 d2                	test   %dl,%dl
  800e66:	75 f1                	jne    800e59 <strfind+0x11>
      break;
  return (char *)s;
}
  800e68:	c3                   	retq   

0000000000800e69 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e69:	48 85 d2             	test   %rdx,%rdx
  800e6c:	74 3a                	je     800ea8 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e6e:	48 89 f8             	mov    %rdi,%rax
  800e71:	48 09 d0             	or     %rdx,%rax
  800e74:	a8 03                	test   $0x3,%al
  800e76:	75 28                	jne    800ea0 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e78:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e7c:	89 f0                	mov    %esi,%eax
  800e7e:	c1 e0 08             	shl    $0x8,%eax
  800e81:	89 f1                	mov    %esi,%ecx
  800e83:	c1 e1 18             	shl    $0x18,%ecx
  800e86:	41 89 f0             	mov    %esi,%r8d
  800e89:	41 c1 e0 10          	shl    $0x10,%r8d
  800e8d:	44 09 c1             	or     %r8d,%ecx
  800e90:	09 ce                	or     %ecx,%esi
  800e92:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e94:	48 c1 ea 02          	shr    $0x2,%rdx
  800e98:	48 89 d1             	mov    %rdx,%rcx
  800e9b:	fc                   	cld    
  800e9c:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e9e:	eb 08                	jmp    800ea8 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ea0:	89 f0                	mov    %esi,%eax
  800ea2:	48 89 d1             	mov    %rdx,%rcx
  800ea5:	fc                   	cld    
  800ea6:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ea8:	48 89 f8             	mov    %rdi,%rax
  800eab:	c3                   	retq   

0000000000800eac <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800eac:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800eaf:	48 39 fe             	cmp    %rdi,%rsi
  800eb2:	73 40                	jae    800ef4 <memmove+0x48>
  800eb4:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800eb8:	48 39 f9             	cmp    %rdi,%rcx
  800ebb:	76 37                	jbe    800ef4 <memmove+0x48>
    s += n;
    d += n;
  800ebd:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ec1:	48 89 fe             	mov    %rdi,%rsi
  800ec4:	48 09 d6             	or     %rdx,%rsi
  800ec7:	48 09 ce             	or     %rcx,%rsi
  800eca:	40 f6 c6 03          	test   $0x3,%sil
  800ece:	75 14                	jne    800ee4 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800ed0:	48 83 ef 04          	sub    $0x4,%rdi
  800ed4:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ed8:	48 c1 ea 02          	shr    $0x2,%rdx
  800edc:	48 89 d1             	mov    %rdx,%rcx
  800edf:	fd                   	std    
  800ee0:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800ee2:	eb 0e                	jmp    800ef2 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800ee4:	48 83 ef 01          	sub    $0x1,%rdi
  800ee8:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800eec:	48 89 d1             	mov    %rdx,%rcx
  800eef:	fd                   	std    
  800ef0:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800ef2:	fc                   	cld    
  800ef3:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ef4:	48 89 c1             	mov    %rax,%rcx
  800ef7:	48 09 d1             	or     %rdx,%rcx
  800efa:	48 09 f1             	or     %rsi,%rcx
  800efd:	f6 c1 03             	test   $0x3,%cl
  800f00:	75 0e                	jne    800f10 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f02:	48 c1 ea 02          	shr    $0x2,%rdx
  800f06:	48 89 d1             	mov    %rdx,%rcx
  800f09:	48 89 c7             	mov    %rax,%rdi
  800f0c:	fc                   	cld    
  800f0d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f0f:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f10:	48 89 c7             	mov    %rax,%rdi
  800f13:	48 89 d1             	mov    %rdx,%rcx
  800f16:	fc                   	cld    
  800f17:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f19:	c3                   	retq   

0000000000800f1a <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f1a:	55                   	push   %rbp
  800f1b:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f1e:	48 b8 ac 0e 80 00 00 	movabs $0x800eac,%rax
  800f25:	00 00 00 
  800f28:	ff d0                	callq  *%rax
}
  800f2a:	5d                   	pop    %rbp
  800f2b:	c3                   	retq   

0000000000800f2c <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f2c:	55                   	push   %rbp
  800f2d:	48 89 e5             	mov    %rsp,%rbp
  800f30:	41 57                	push   %r15
  800f32:	41 56                	push   %r14
  800f34:	41 55                	push   %r13
  800f36:	41 54                	push   %r12
  800f38:	53                   	push   %rbx
  800f39:	48 83 ec 08          	sub    $0x8,%rsp
  800f3d:	49 89 fe             	mov    %rdi,%r14
  800f40:	49 89 f7             	mov    %rsi,%r15
  800f43:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f46:	48 89 f7             	mov    %rsi,%rdi
  800f49:	48 b8 a1 0c 80 00 00 	movabs $0x800ca1,%rax
  800f50:	00 00 00 
  800f53:	ff d0                	callq  *%rax
  800f55:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f58:	4c 89 ee             	mov    %r13,%rsi
  800f5b:	4c 89 f7             	mov    %r14,%rdi
  800f5e:	48 b8 c3 0c 80 00 00 	movabs $0x800cc3,%rax
  800f65:	00 00 00 
  800f68:	ff d0                	callq  *%rax
  800f6a:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f6d:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f71:	4d 39 e5             	cmp    %r12,%r13
  800f74:	74 26                	je     800f9c <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f76:	4c 89 e8             	mov    %r13,%rax
  800f79:	4c 29 e0             	sub    %r12,%rax
  800f7c:	48 39 d8             	cmp    %rbx,%rax
  800f7f:	76 2a                	jbe    800fab <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f81:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f85:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f89:	4c 89 fe             	mov    %r15,%rsi
  800f8c:	48 b8 1a 0f 80 00 00 	movabs $0x800f1a,%rax
  800f93:	00 00 00 
  800f96:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f98:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800f9c:	48 83 c4 08          	add    $0x8,%rsp
  800fa0:	5b                   	pop    %rbx
  800fa1:	41 5c                	pop    %r12
  800fa3:	41 5d                	pop    %r13
  800fa5:	41 5e                	pop    %r14
  800fa7:	41 5f                	pop    %r15
  800fa9:	5d                   	pop    %rbp
  800faa:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fab:	49 83 ed 01          	sub    $0x1,%r13
  800faf:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fb3:	4c 89 ea             	mov    %r13,%rdx
  800fb6:	4c 89 fe             	mov    %r15,%rsi
  800fb9:	48 b8 1a 0f 80 00 00 	movabs $0x800f1a,%rax
  800fc0:	00 00 00 
  800fc3:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fc5:	4d 01 ee             	add    %r13,%r14
  800fc8:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fcd:	eb c9                	jmp    800f98 <strlcat+0x6c>

0000000000800fcf <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fcf:	48 85 d2             	test   %rdx,%rdx
  800fd2:	74 3a                	je     80100e <memcmp+0x3f>
    if (*s1 != *s2)
  800fd4:	0f b6 0f             	movzbl (%rdi),%ecx
  800fd7:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fdb:	44 38 c1             	cmp    %r8b,%cl
  800fde:	75 1d                	jne    800ffd <memcmp+0x2e>
  800fe0:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fe5:	48 39 d0             	cmp    %rdx,%rax
  800fe8:	74 1e                	je     801008 <memcmp+0x39>
    if (*s1 != *s2)
  800fea:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800fee:	48 83 c0 01          	add    $0x1,%rax
  800ff2:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ff8:	44 38 c1             	cmp    %r8b,%cl
  800ffb:	74 e8                	je     800fe5 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ffd:	0f b6 c1             	movzbl %cl,%eax
  801000:	45 0f b6 c0          	movzbl %r8b,%r8d
  801004:	44 29 c0             	sub    %r8d,%eax
  801007:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801008:	b8 00 00 00 00       	mov    $0x0,%eax
  80100d:	c3                   	retq   
  80100e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801013:	c3                   	retq   

0000000000801014 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801014:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801018:	48 39 c7             	cmp    %rax,%rdi
  80101b:	73 19                	jae    801036 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80101d:	89 f2                	mov    %esi,%edx
  80101f:	40 38 37             	cmp    %sil,(%rdi)
  801022:	74 16                	je     80103a <memfind+0x26>
  for (; s < ends; s++)
  801024:	48 83 c7 01          	add    $0x1,%rdi
  801028:	48 39 f8             	cmp    %rdi,%rax
  80102b:	74 08                	je     801035 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80102d:	38 17                	cmp    %dl,(%rdi)
  80102f:	75 f3                	jne    801024 <memfind+0x10>
  for (; s < ends; s++)
  801031:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801034:	c3                   	retq   
  801035:	c3                   	retq   
  for (; s < ends; s++)
  801036:	48 89 f8             	mov    %rdi,%rax
  801039:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80103a:	48 89 f8             	mov    %rdi,%rax
  80103d:	c3                   	retq   

000000000080103e <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80103e:	0f b6 07             	movzbl (%rdi),%eax
  801041:	3c 20                	cmp    $0x20,%al
  801043:	74 04                	je     801049 <strtol+0xb>
  801045:	3c 09                	cmp    $0x9,%al
  801047:	75 0f                	jne    801058 <strtol+0x1a>
    s++;
  801049:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80104d:	0f b6 07             	movzbl (%rdi),%eax
  801050:	3c 20                	cmp    $0x20,%al
  801052:	74 f5                	je     801049 <strtol+0xb>
  801054:	3c 09                	cmp    $0x9,%al
  801056:	74 f1                	je     801049 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801058:	3c 2b                	cmp    $0x2b,%al
  80105a:	74 2b                	je     801087 <strtol+0x49>
  int neg  = 0;
  80105c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801062:	3c 2d                	cmp    $0x2d,%al
  801064:	74 2d                	je     801093 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801066:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80106c:	75 0f                	jne    80107d <strtol+0x3f>
  80106e:	80 3f 30             	cmpb   $0x30,(%rdi)
  801071:	74 2c                	je     80109f <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801073:	85 d2                	test   %edx,%edx
  801075:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107a:	0f 44 d0             	cmove  %eax,%edx
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801082:	4c 63 d2             	movslq %edx,%r10
  801085:	eb 5c                	jmp    8010e3 <strtol+0xa5>
    s++;
  801087:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80108b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801091:	eb d3                	jmp    801066 <strtol+0x28>
    s++, neg = 1;
  801093:	48 83 c7 01          	add    $0x1,%rdi
  801097:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80109d:	eb c7                	jmp    801066 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80109f:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010a3:	74 0f                	je     8010b4 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010a5:	85 d2                	test   %edx,%edx
  8010a7:	75 d4                	jne    80107d <strtol+0x3f>
    s++, base = 8;
  8010a9:	48 83 c7 01          	add    $0x1,%rdi
  8010ad:	ba 08 00 00 00       	mov    $0x8,%edx
  8010b2:	eb c9                	jmp    80107d <strtol+0x3f>
    s += 2, base = 16;
  8010b4:	48 83 c7 02          	add    $0x2,%rdi
  8010b8:	ba 10 00 00 00       	mov    $0x10,%edx
  8010bd:	eb be                	jmp    80107d <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010bf:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010c3:	41 80 f8 19          	cmp    $0x19,%r8b
  8010c7:	77 2f                	ja     8010f8 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010c9:	44 0f be c1          	movsbl %cl,%r8d
  8010cd:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010d1:	39 d1                	cmp    %edx,%ecx
  8010d3:	7d 37                	jge    80110c <strtol+0xce>
    s++, val = (val * base) + dig;
  8010d5:	48 83 c7 01          	add    $0x1,%rdi
  8010d9:	49 0f af c2          	imul   %r10,%rax
  8010dd:	48 63 c9             	movslq %ecx,%rcx
  8010e0:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010e3:	0f b6 0f             	movzbl (%rdi),%ecx
  8010e6:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010ea:	41 80 f8 09          	cmp    $0x9,%r8b
  8010ee:	77 cf                	ja     8010bf <strtol+0x81>
      dig = *s - '0';
  8010f0:	0f be c9             	movsbl %cl,%ecx
  8010f3:	83 e9 30             	sub    $0x30,%ecx
  8010f6:	eb d9                	jmp    8010d1 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8010f8:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8010fc:	41 80 f8 19          	cmp    $0x19,%r8b
  801100:	77 0a                	ja     80110c <strtol+0xce>
      dig = *s - 'A' + 10;
  801102:	44 0f be c1          	movsbl %cl,%r8d
  801106:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80110a:	eb c5                	jmp    8010d1 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80110c:	48 85 f6             	test   %rsi,%rsi
  80110f:	74 03                	je     801114 <strtol+0xd6>
    *endptr = (char *)s;
  801111:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801114:	48 89 c2             	mov    %rax,%rdx
  801117:	48 f7 da             	neg    %rdx
  80111a:	45 85 c9             	test   %r9d,%r9d
  80111d:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801121:	c3                   	retq   
  801122:	66 90                	xchg   %ax,%ax
