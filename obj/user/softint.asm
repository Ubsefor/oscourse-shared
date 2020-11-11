
obj/user/softint:     file format elf64-x86-64


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
  800023:	e8 05 00 00 00       	callq  80002d <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  asm volatile("int $14"); // page fault
  80002a:	cd 0e                	int    $0xe
}
  80002c:	c3                   	retq   

000000000080002d <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80002d:	55                   	push   %rbp
  80002e:	48 89 e5             	mov    %rsp,%rbp
  800031:	41 56                	push   %r14
  800033:	41 55                	push   %r13
  800035:	41 54                	push   %r12
  800037:	53                   	push   %rbx
  800038:	41 89 fd             	mov    %edi,%r13d
  80003b:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80003e:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800045:	00 00 00 
  800048:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80004f:	00 00 00 
  800052:	48 39 c2             	cmp    %rax,%rdx
  800055:	73 23                	jae    80007a <libmain+0x4d>
  800057:	48 89 d3             	mov    %rdx,%rbx
  80005a:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80005e:	48 29 d0             	sub    %rdx,%rax
  800061:	48 c1 e8 03          	shr    $0x3,%rax
  800065:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80006a:	b8 00 00 00 00       	mov    $0x0,%eax
  80006f:	ff 13                	callq  *(%rbx)
    ctor++;
  800071:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800075:	4c 39 e3             	cmp    %r12,%rbx
  800078:	75 f0                	jne    80006a <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80007a:	45 85 ed             	test   %r13d,%r13d
  80007d:	7e 0d                	jle    80008c <libmain+0x5f>
    binaryname = argv[0];
  80007f:	49 8b 06             	mov    (%r14),%rax
  800082:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800089:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80008c:	4c 89 f6             	mov    %r14,%rsi
  80008f:	44 89 ef             	mov    %r13d,%edi
  800092:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800099:	00 00 00 
  80009c:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80009e:	48 b8 b3 00 80 00 00 	movabs $0x8000b3,%rax
  8000a5:	00 00 00 
  8000a8:	ff d0                	callq  *%rax
#endif
}
  8000aa:	5b                   	pop    %rbx
  8000ab:	41 5c                	pop    %r12
  8000ad:	41 5d                	pop    %r13
  8000af:	41 5e                	pop    %r14
  8000b1:	5d                   	pop    %rbp
  8000b2:	c3                   	retq   

00000000008000b3 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000b3:	55                   	push   %rbp
  8000b4:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8000bc:	48 b8 08 01 80 00 00 	movabs $0x800108,%rax
  8000c3:	00 00 00 
  8000c6:	ff d0                	callq  *%rax
}
  8000c8:	5d                   	pop    %rbp
  8000c9:	c3                   	retq   

00000000008000ca <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000ca:	55                   	push   %rbp
  8000cb:	48 89 e5             	mov    %rsp,%rbp
  8000ce:	53                   	push   %rbx
  8000cf:	48 89 fa             	mov    %rdi,%rdx
  8000d2:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000da:	48 89 c3             	mov    %rax,%rbx
  8000dd:	48 89 c7             	mov    %rax,%rdi
  8000e0:	48 89 c6             	mov    %rax,%rsi
  8000e3:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8000e5:	5b                   	pop    %rbx
  8000e6:	5d                   	pop    %rbp
  8000e7:	c3                   	retq   

00000000008000e8 <sys_cgetc>:

int
sys_cgetc(void) {
  8000e8:	55                   	push   %rbp
  8000e9:	48 89 e5             	mov    %rsp,%rbp
  8000ec:	53                   	push   %rbx
  asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f7:	48 89 ca             	mov    %rcx,%rdx
  8000fa:	48 89 cb             	mov    %rcx,%rbx
  8000fd:	48 89 cf             	mov    %rcx,%rdi
  800100:	48 89 ce             	mov    %rcx,%rsi
  800103:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800105:	5b                   	pop    %rbx
  800106:	5d                   	pop    %rbp
  800107:	c3                   	retq   

0000000000800108 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800108:	55                   	push   %rbp
  800109:	48 89 e5             	mov    %rsp,%rbp
  80010c:	53                   	push   %rbx
  80010d:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800111:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800114:	be 00 00 00 00       	mov    $0x0,%esi
  800119:	b8 03 00 00 00       	mov    $0x3,%eax
  80011e:	48 89 f1             	mov    %rsi,%rcx
  800121:	48 89 f3             	mov    %rsi,%rbx
  800124:	48 89 f7             	mov    %rsi,%rdi
  800127:	cd 30                	int    $0x30
  if (check && ret > 0)
  800129:	48 85 c0             	test   %rax,%rax
  80012c:	7f 07                	jg     800135 <sys_env_destroy+0x2d>
}
  80012e:	48 83 c4 08          	add    $0x8,%rsp
  800132:	5b                   	pop    %rbx
  800133:	5d                   	pop    %rbp
  800134:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800135:	49 89 c0             	mov    %rax,%r8
  800138:	b9 03 00 00 00       	mov    $0x3,%ecx
  80013d:	48 ba 30 11 80 00 00 	movabs $0x801130,%rdx
  800144:	00 00 00 
  800147:	be 22 00 00 00       	mov    $0x22,%esi
  80014c:	48 bf 4f 11 80 00 00 	movabs $0x80114f,%rdi
  800153:	00 00 00 
  800156:	b8 00 00 00 00       	mov    $0x0,%eax
  80015b:	49 b9 88 01 80 00 00 	movabs $0x800188,%r9
  800162:	00 00 00 
  800165:	41 ff d1             	callq  *%r9

0000000000800168 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800168:	55                   	push   %rbp
  800169:	48 89 e5             	mov    %rsp,%rbp
  80016c:	53                   	push   %rbx
  asm volatile("int %1\n"
  80016d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800172:	b8 02 00 00 00       	mov    $0x2,%eax
  800177:	48 89 ca             	mov    %rcx,%rdx
  80017a:	48 89 cb             	mov    %rcx,%rbx
  80017d:	48 89 cf             	mov    %rcx,%rdi
  800180:	48 89 ce             	mov    %rcx,%rsi
  800183:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %rbx
  800186:	5d                   	pop    %rbp
  800187:	c3                   	retq   

0000000000800188 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800188:	55                   	push   %rbp
  800189:	48 89 e5             	mov    %rsp,%rbp
  80018c:	41 56                	push   %r14
  80018e:	41 55                	push   %r13
  800190:	41 54                	push   %r12
  800192:	53                   	push   %rbx
  800193:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80019a:	49 89 fd             	mov    %rdi,%r13
  80019d:	41 89 f6             	mov    %esi,%r14d
  8001a0:	49 89 d4             	mov    %rdx,%r12
  8001a3:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001aa:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001b1:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001b8:	84 c0                	test   %al,%al
  8001ba:	74 26                	je     8001e2 <_panic+0x5a>
  8001bc:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001c3:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001ca:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001ce:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001d2:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001d6:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001da:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001de:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8001e2:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8001e9:	00 00 00 
  8001ec:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8001f3:	00 00 00 
  8001f6:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8001fa:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800201:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800208:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80020f:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800216:	00 00 00 
  800219:	48 8b 18             	mov    (%rax),%rbx
  80021c:	48 b8 68 01 80 00 00 	movabs $0x800168,%rax
  800223:	00 00 00 
  800226:	ff d0                	callq  *%rax
  800228:	45 89 f0             	mov    %r14d,%r8d
  80022b:	4c 89 e9             	mov    %r13,%rcx
  80022e:	48 89 da             	mov    %rbx,%rdx
  800231:	89 c6                	mov    %eax,%esi
  800233:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  80023a:	00 00 00 
  80023d:	b8 00 00 00 00       	mov    $0x0,%eax
  800242:	48 bb 2a 03 80 00 00 	movabs $0x80032a,%rbx
  800249:	00 00 00 
  80024c:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80024e:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800255:	4c 89 e7             	mov    %r12,%rdi
  800258:	48 b8 c2 02 80 00 00 	movabs $0x8002c2,%rax
  80025f:	00 00 00 
  800262:	ff d0                	callq  *%rax
  cprintf("\n");
  800264:	48 bf 88 11 80 00 00 	movabs $0x801188,%rdi
  80026b:	00 00 00 
  80026e:	b8 00 00 00 00       	mov    $0x0,%eax
  800273:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800275:	cc                   	int3   
  while (1)
  800276:	eb fd                	jmp    800275 <_panic+0xed>

0000000000800278 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800278:	55                   	push   %rbp
  800279:	48 89 e5             	mov    %rsp,%rbp
  80027c:	53                   	push   %rbx
  80027d:	48 83 ec 08          	sub    $0x8,%rsp
  800281:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800284:	8b 06                	mov    (%rsi),%eax
  800286:	8d 50 01             	lea    0x1(%rax),%edx
  800289:	89 16                	mov    %edx,(%rsi)
  80028b:	48 98                	cltq   
  80028d:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800292:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800298:	74 0b                	je     8002a5 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80029a:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80029e:	48 83 c4 08          	add    $0x8,%rsp
  8002a2:	5b                   	pop    %rbx
  8002a3:	5d                   	pop    %rbp
  8002a4:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002a5:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002a9:	be ff 00 00 00       	mov    $0xff,%esi
  8002ae:	48 b8 ca 00 80 00 00 	movabs $0x8000ca,%rax
  8002b5:	00 00 00 
  8002b8:	ff d0                	callq  *%rax
    b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002c0:	eb d8                	jmp    80029a <putch+0x22>

00000000008002c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002c2:	55                   	push   %rbp
  8002c3:	48 89 e5             	mov    %rsp,%rbp
  8002c6:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002cd:	48 89 fa             	mov    %rdi,%rdx
  8002d0:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002da:	00 00 00 
  b.cnt = 0;
  8002dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002e4:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8002e7:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8002ee:	48 bf 78 02 80 00 00 	movabs $0x800278,%rdi
  8002f5:	00 00 00 
  8002f8:	48 b8 e8 04 80 00 00 	movabs $0x8004e8,%rax
  8002ff:	00 00 00 
  800302:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800304:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80030b:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800312:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800316:	48 b8 ca 00 80 00 00 	movabs $0x8000ca,%rax
  80031d:	00 00 00 
  800320:	ff d0                	callq  *%rax

  return b.cnt;
}
  800322:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800328:	c9                   	leaveq 
  800329:	c3                   	retq   

000000000080032a <cprintf>:

int
cprintf(const char *fmt, ...) {
  80032a:	55                   	push   %rbp
  80032b:	48 89 e5             	mov    %rsp,%rbp
  80032e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800335:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80033c:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800343:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80034a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800351:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800358:	84 c0                	test   %al,%al
  80035a:	74 20                	je     80037c <cprintf+0x52>
  80035c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800360:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800364:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800368:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80036c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800370:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800374:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800378:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80037c:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800383:	00 00 00 
  800386:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80038d:	00 00 00 
  800390:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800394:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80039b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003a2:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003a9:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003b0:	48 b8 c2 02 80 00 00 	movabs $0x8002c2,%rax
  8003b7:	00 00 00 
  8003ba:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003bc:	c9                   	leaveq 
  8003bd:	c3                   	retq   

00000000008003be <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003be:	55                   	push   %rbp
  8003bf:	48 89 e5             	mov    %rsp,%rbp
  8003c2:	41 57                	push   %r15
  8003c4:	41 56                	push   %r14
  8003c6:	41 55                	push   %r13
  8003c8:	41 54                	push   %r12
  8003ca:	53                   	push   %rbx
  8003cb:	48 83 ec 18          	sub    $0x18,%rsp
  8003cf:	49 89 fc             	mov    %rdi,%r12
  8003d2:	49 89 f5             	mov    %rsi,%r13
  8003d5:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003d9:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003dc:	41 89 cf             	mov    %ecx,%r15d
  8003df:	49 39 d7             	cmp    %rdx,%r15
  8003e2:	76 45                	jbe    800429 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003e4:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8003e8:	85 db                	test   %ebx,%ebx
  8003ea:	7e 0e                	jle    8003fa <printnum+0x3c>
      putch(padc, putdat);
  8003ec:	4c 89 ee             	mov    %r13,%rsi
  8003ef:	44 89 f7             	mov    %r14d,%edi
  8003f2:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8003f5:	83 eb 01             	sub    $0x1,%ebx
  8003f8:	75 f2                	jne    8003ec <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8003fa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800403:	49 f7 f7             	div    %r15
  800406:	48 b8 8a 11 80 00 00 	movabs $0x80118a,%rax
  80040d:	00 00 00 
  800410:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800414:	4c 89 ee             	mov    %r13,%rsi
  800417:	41 ff d4             	callq  *%r12
}
  80041a:	48 83 c4 18          	add    $0x18,%rsp
  80041e:	5b                   	pop    %rbx
  80041f:	41 5c                	pop    %r12
  800421:	41 5d                	pop    %r13
  800423:	41 5e                	pop    %r14
  800425:	41 5f                	pop    %r15
  800427:	5d                   	pop    %rbp
  800428:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800429:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	49 f7 f7             	div    %r15
  800435:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800439:	48 89 c2             	mov    %rax,%rdx
  80043c:	48 b8 be 03 80 00 00 	movabs $0x8003be,%rax
  800443:	00 00 00 
  800446:	ff d0                	callq  *%rax
  800448:	eb b0                	jmp    8003fa <printnum+0x3c>

000000000080044a <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80044a:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80044e:	48 8b 06             	mov    (%rsi),%rax
  800451:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800455:	73 0a                	jae    800461 <sprintputch+0x17>
    *b->buf++ = ch;
  800457:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80045b:	48 89 16             	mov    %rdx,(%rsi)
  80045e:	40 88 38             	mov    %dil,(%rax)
}
  800461:	c3                   	retq   

0000000000800462 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800462:	55                   	push   %rbp
  800463:	48 89 e5             	mov    %rsp,%rbp
  800466:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80046d:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800474:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80047b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800482:	84 c0                	test   %al,%al
  800484:	74 20                	je     8004a6 <printfmt+0x44>
  800486:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80048a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80048e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800492:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800496:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80049a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80049e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004a2:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004a6:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004ad:	00 00 00 
  8004b0:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004b7:	00 00 00 
  8004ba:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004be:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004c5:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004cc:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004d3:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004da:	48 b8 e8 04 80 00 00 	movabs $0x8004e8,%rax
  8004e1:	00 00 00 
  8004e4:	ff d0                	callq  *%rax
}
  8004e6:	c9                   	leaveq 
  8004e7:	c3                   	retq   

00000000008004e8 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8004e8:	55                   	push   %rbp
  8004e9:	48 89 e5             	mov    %rsp,%rbp
  8004ec:	41 57                	push   %r15
  8004ee:	41 56                	push   %r14
  8004f0:	41 55                	push   %r13
  8004f2:	41 54                	push   %r12
  8004f4:	53                   	push   %rbx
  8004f5:	48 83 ec 48          	sub    $0x48,%rsp
  8004f9:	49 89 fd             	mov    %rdi,%r13
  8004fc:	49 89 f7             	mov    %rsi,%r15
  8004ff:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800502:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800506:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80050a:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80050e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800512:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800516:	41 0f b6 3e          	movzbl (%r14),%edi
  80051a:	83 ff 25             	cmp    $0x25,%edi
  80051d:	74 18                	je     800537 <vprintfmt+0x4f>
      if (ch == '\0')
  80051f:	85 ff                	test   %edi,%edi
  800521:	0f 84 8c 06 00 00    	je     800bb3 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800527:	4c 89 fe             	mov    %r15,%rsi
  80052a:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80052d:	49 89 de             	mov    %rbx,%r14
  800530:	eb e0                	jmp    800512 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800532:	49 89 de             	mov    %rbx,%r14
  800535:	eb db                	jmp    800512 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800537:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80053b:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80053f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800546:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80054c:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800550:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800555:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80055b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800561:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800566:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80056b:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80056f:	0f b6 13             	movzbl (%rbx),%edx
  800572:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800575:	3c 55                	cmp    $0x55,%al
  800577:	0f 87 8b 05 00 00    	ja     800b08 <vprintfmt+0x620>
  80057d:	0f b6 c0             	movzbl %al,%eax
  800580:	49 bb 40 12 80 00 00 	movabs $0x801240,%r11
  800587:	00 00 00 
  80058a:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80058e:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800591:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800595:	eb d4                	jmp    80056b <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800597:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80059a:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80059e:	eb cb                	jmp    80056b <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005a0:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005a3:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005a7:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005ab:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005ae:	83 fa 09             	cmp    $0x9,%edx
  8005b1:	77 7e                	ja     800631 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005b3:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005b7:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005bb:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005c0:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005c4:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005c7:	83 fa 09             	cmp    $0x9,%edx
  8005ca:	76 e7                	jbe    8005b3 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005cc:	4c 89 f3             	mov    %r14,%rbx
  8005cf:	eb 19                	jmp    8005ea <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005d1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005d4:	83 f8 2f             	cmp    $0x2f,%eax
  8005d7:	77 2a                	ja     800603 <vprintfmt+0x11b>
  8005d9:	89 c2                	mov    %eax,%edx
  8005db:	4c 01 d2             	add    %r10,%rdx
  8005de:	83 c0 08             	add    $0x8,%eax
  8005e1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005e4:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8005e7:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8005ea:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005ee:	0f 89 77 ff ff ff    	jns    80056b <vprintfmt+0x83>
          width = precision, precision = -1;
  8005f4:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8005f8:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8005fe:	e9 68 ff ff ff       	jmpq   80056b <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800603:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800607:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80060b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80060f:	eb d3                	jmp    8005e4 <vprintfmt+0xfc>
        if (width < 0)
  800611:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800614:	85 c0                	test   %eax,%eax
  800616:	41 0f 48 c0          	cmovs  %r8d,%eax
  80061a:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80061d:	4c 89 f3             	mov    %r14,%rbx
  800620:	e9 46 ff ff ff       	jmpq   80056b <vprintfmt+0x83>
  800625:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800628:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80062c:	e9 3a ff ff ff       	jmpq   80056b <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800631:	4c 89 f3             	mov    %r14,%rbx
  800634:	eb b4                	jmp    8005ea <vprintfmt+0x102>
        lflag++;
  800636:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800639:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80063c:	e9 2a ff ff ff       	jmpq   80056b <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800641:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800644:	83 f8 2f             	cmp    $0x2f,%eax
  800647:	77 19                	ja     800662 <vprintfmt+0x17a>
  800649:	89 c2                	mov    %eax,%edx
  80064b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80064f:	83 c0 08             	add    $0x8,%eax
  800652:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800655:	4c 89 fe             	mov    %r15,%rsi
  800658:	8b 3a                	mov    (%rdx),%edi
  80065a:	41 ff d5             	callq  *%r13
        break;
  80065d:	e9 b0 fe ff ff       	jmpq   800512 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800662:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800666:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80066a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80066e:	eb e5                	jmp    800655 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800670:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800673:	83 f8 2f             	cmp    $0x2f,%eax
  800676:	77 5b                	ja     8006d3 <vprintfmt+0x1eb>
  800678:	89 c2                	mov    %eax,%edx
  80067a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80067e:	83 c0 08             	add    $0x8,%eax
  800681:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800684:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800686:	89 c8                	mov    %ecx,%eax
  800688:	c1 f8 1f             	sar    $0x1f,%eax
  80068b:	31 c1                	xor    %eax,%ecx
  80068d:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068f:	83 f9 09             	cmp    $0x9,%ecx
  800692:	7f 4d                	jg     8006e1 <vprintfmt+0x1f9>
  800694:	48 63 c1             	movslq %ecx,%rax
  800697:	48 ba 00 15 80 00 00 	movabs $0x801500,%rdx
  80069e:	00 00 00 
  8006a1:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006a5:	48 85 c0             	test   %rax,%rax
  8006a8:	74 37                	je     8006e1 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006aa:	48 89 c1             	mov    %rax,%rcx
  8006ad:	48 ba ab 11 80 00 00 	movabs $0x8011ab,%rdx
  8006b4:	00 00 00 
  8006b7:	4c 89 fe             	mov    %r15,%rsi
  8006ba:	4c 89 ef             	mov    %r13,%rdi
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c2:	48 bb 62 04 80 00 00 	movabs $0x800462,%rbx
  8006c9:	00 00 00 
  8006cc:	ff d3                	callq  *%rbx
  8006ce:	e9 3f fe ff ff       	jmpq   800512 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006d3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006d7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006db:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006df:	eb a3                	jmp    800684 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006e1:	48 ba a2 11 80 00 00 	movabs $0x8011a2,%rdx
  8006e8:	00 00 00 
  8006eb:	4c 89 fe             	mov    %r15,%rsi
  8006ee:	4c 89 ef             	mov    %r13,%rdi
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f6:	48 bb 62 04 80 00 00 	movabs $0x800462,%rbx
  8006fd:	00 00 00 
  800700:	ff d3                	callq  *%rbx
  800702:	e9 0b fe ff ff       	jmpq   800512 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800707:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80070a:	83 f8 2f             	cmp    $0x2f,%eax
  80070d:	77 4b                	ja     80075a <vprintfmt+0x272>
  80070f:	89 c2                	mov    %eax,%edx
  800711:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800715:	83 c0 08             	add    $0x8,%eax
  800718:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80071b:	48 8b 02             	mov    (%rdx),%rax
  80071e:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800722:	48 85 c0             	test   %rax,%rax
  800725:	0f 84 05 04 00 00    	je     800b30 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80072b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80072f:	7e 06                	jle    800737 <vprintfmt+0x24f>
  800731:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800735:	75 31                	jne    800768 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800737:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80073b:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80073f:	0f b6 00             	movzbl (%rax),%eax
  800742:	0f be f8             	movsbl %al,%edi
  800745:	85 ff                	test   %edi,%edi
  800747:	0f 84 c3 00 00 00    	je     800810 <vprintfmt+0x328>
  80074d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800751:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800755:	e9 85 00 00 00       	jmpq   8007df <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80075a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80075e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800762:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800766:	eb b3                	jmp    80071b <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800768:	49 63 f4             	movslq %r12d,%rsi
  80076b:	48 89 c7             	mov    %rax,%rdi
  80076e:	48 b8 bf 0c 80 00 00 	movabs $0x800cbf,%rax
  800775:	00 00 00 
  800778:	ff d0                	callq  *%rax
  80077a:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80077d:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800780:	85 f6                	test   %esi,%esi
  800782:	7e 22                	jle    8007a6 <vprintfmt+0x2be>
            putch(padc, putdat);
  800784:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800788:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80078c:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800790:	4c 89 fe             	mov    %r15,%rsi
  800793:	89 df                	mov    %ebx,%edi
  800795:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800798:	41 83 ec 01          	sub    $0x1,%r12d
  80079c:	75 f2                	jne    800790 <vprintfmt+0x2a8>
  80079e:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007a2:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a6:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007aa:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007ae:	0f b6 00             	movzbl (%rax),%eax
  8007b1:	0f be f8             	movsbl %al,%edi
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	0f 84 56 fd ff ff    	je     800512 <vprintfmt+0x2a>
  8007bc:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007c0:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007c4:	eb 19                	jmp    8007df <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007c6:	4c 89 fe             	mov    %r15,%rsi
  8007c9:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cc:	41 83 ee 01          	sub    $0x1,%r14d
  8007d0:	48 83 c3 01          	add    $0x1,%rbx
  8007d4:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007d8:	0f be f8             	movsbl %al,%edi
  8007db:	85 ff                	test   %edi,%edi
  8007dd:	74 29                	je     800808 <vprintfmt+0x320>
  8007df:	45 85 e4             	test   %r12d,%r12d
  8007e2:	78 06                	js     8007ea <vprintfmt+0x302>
  8007e4:	41 83 ec 01          	sub    $0x1,%r12d
  8007e8:	78 48                	js     800832 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8007ea:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8007ee:	74 d6                	je     8007c6 <vprintfmt+0x2de>
  8007f0:	0f be c0             	movsbl %al,%eax
  8007f3:	83 e8 20             	sub    $0x20,%eax
  8007f6:	83 f8 5e             	cmp    $0x5e,%eax
  8007f9:	76 cb                	jbe    8007c6 <vprintfmt+0x2de>
            putch('?', putdat);
  8007fb:	4c 89 fe             	mov    %r15,%rsi
  8007fe:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800803:	41 ff d5             	callq  *%r13
  800806:	eb c4                	jmp    8007cc <vprintfmt+0x2e4>
  800808:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80080c:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800810:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800813:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800817:	0f 8e f5 fc ff ff    	jle    800512 <vprintfmt+0x2a>
          putch(' ', putdat);
  80081d:	4c 89 fe             	mov    %r15,%rsi
  800820:	bf 20 00 00 00       	mov    $0x20,%edi
  800825:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800828:	83 eb 01             	sub    $0x1,%ebx
  80082b:	75 f0                	jne    80081d <vprintfmt+0x335>
  80082d:	e9 e0 fc ff ff       	jmpq   800512 <vprintfmt+0x2a>
  800832:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800836:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80083a:	eb d4                	jmp    800810 <vprintfmt+0x328>
  if (lflag >= 2)
  80083c:	83 f9 01             	cmp    $0x1,%ecx
  80083f:	7f 1d                	jg     80085e <vprintfmt+0x376>
  else if (lflag)
  800841:	85 c9                	test   %ecx,%ecx
  800843:	74 5e                	je     8008a3 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800845:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800848:	83 f8 2f             	cmp    $0x2f,%eax
  80084b:	77 48                	ja     800895 <vprintfmt+0x3ad>
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800853:	83 c0 08             	add    $0x8,%eax
  800856:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800859:	48 8b 1a             	mov    (%rdx),%rbx
  80085c:	eb 17                	jmp    800875 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80085e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800861:	83 f8 2f             	cmp    $0x2f,%eax
  800864:	77 21                	ja     800887 <vprintfmt+0x39f>
  800866:	89 c2                	mov    %eax,%edx
  800868:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80086c:	83 c0 08             	add    $0x8,%eax
  80086f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800872:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800875:	48 85 db             	test   %rbx,%rbx
  800878:	78 50                	js     8008ca <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80087a:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80087d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800882:	e9 b4 01 00 00       	jmpq   800a3b <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800887:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80088f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800893:	eb dd                	jmp    800872 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800895:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800899:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80089d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a1:	eb b6                	jmp    800859 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008a3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008a6:	83 f8 2f             	cmp    $0x2f,%eax
  8008a9:	77 11                	ja     8008bc <vprintfmt+0x3d4>
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b1:	83 c0 08             	add    $0x8,%eax
  8008b4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008b7:	48 63 1a             	movslq (%rdx),%rbx
  8008ba:	eb b9                	jmp    800875 <vprintfmt+0x38d>
  8008bc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c8:	eb ed                	jmp    8008b7 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008ca:	4c 89 fe             	mov    %r15,%rsi
  8008cd:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008d2:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008d5:	48 89 da             	mov    %rbx,%rdx
  8008d8:	48 f7 da             	neg    %rdx
        base = 10;
  8008db:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008e0:	e9 56 01 00 00       	jmpq   800a3b <vprintfmt+0x553>
  if (lflag >= 2)
  8008e5:	83 f9 01             	cmp    $0x1,%ecx
  8008e8:	7f 25                	jg     80090f <vprintfmt+0x427>
  else if (lflag)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 5e                	je     80094c <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8008ee:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f1:	83 f8 2f             	cmp    $0x2f,%eax
  8008f4:	77 48                	ja     80093e <vprintfmt+0x456>
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008fc:	83 c0 08             	add    $0x8,%eax
  8008ff:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800902:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800905:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090a:	e9 2c 01 00 00       	jmpq   800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80090f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800912:	83 f8 2f             	cmp    $0x2f,%eax
  800915:	77 19                	ja     800930 <vprintfmt+0x448>
  800917:	89 c2                	mov    %eax,%edx
  800919:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091d:	83 c0 08             	add    $0x8,%eax
  800920:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800923:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800926:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092b:	e9 0b 01 00 00       	jmpq   800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800930:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800934:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800938:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80093c:	eb e5                	jmp    800923 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80093e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800942:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800946:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094a:	eb b6                	jmp    800902 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80094c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094f:	83 f8 2f             	cmp    $0x2f,%eax
  800952:	77 18                	ja     80096c <vprintfmt+0x484>
  800954:	89 c2                	mov    %eax,%edx
  800956:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095a:	83 c0 08             	add    $0x8,%eax
  80095d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800960:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800962:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800967:	e9 cf 00 00 00       	jmpq   800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80096c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800970:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800974:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800978:	eb e6                	jmp    800960 <vprintfmt+0x478>
  if (lflag >= 2)
  80097a:	83 f9 01             	cmp    $0x1,%ecx
  80097d:	7f 25                	jg     8009a4 <vprintfmt+0x4bc>
  else if (lflag)
  80097f:	85 c9                	test   %ecx,%ecx
  800981:	74 5b                	je     8009de <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800983:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800986:	83 f8 2f             	cmp    $0x2f,%eax
  800989:	77 45                	ja     8009d0 <vprintfmt+0x4e8>
  80098b:	89 c2                	mov    %eax,%edx
  80098d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800991:	83 c0 08             	add    $0x8,%eax
  800994:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800997:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80099a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80099f:	e9 97 00 00 00       	jmpq   800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009a4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a7:	83 f8 2f             	cmp    $0x2f,%eax
  8009aa:	77 16                	ja     8009c2 <vprintfmt+0x4da>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009b2:	83 c0 08             	add    $0x8,%eax
  8009b5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b8:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009bb:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009c0:	eb 79                	jmp    800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009c2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009c6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ca:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ce:	eb e8                	jmp    8009b8 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009d0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009d8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009dc:	eb b9                	jmp    800997 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009de:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e1:	83 f8 2f             	cmp    $0x2f,%eax
  8009e4:	77 15                	ja     8009fb <vprintfmt+0x513>
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ec:	83 c0 08             	add    $0x8,%eax
  8009ef:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f2:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8009f4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f9:	eb 40                	jmp    800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009fb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a03:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a07:	eb e9                	jmp    8009f2 <vprintfmt+0x50a>
        putch('0', putdat);
  800a09:	4c 89 fe             	mov    %r15,%rsi
  800a0c:	bf 30 00 00 00       	mov    $0x30,%edi
  800a11:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a14:	4c 89 fe             	mov    %r15,%rsi
  800a17:	bf 78 00 00 00       	mov    $0x78,%edi
  800a1c:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a1f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a22:	83 f8 2f             	cmp    $0x2f,%eax
  800a25:	77 34                	ja     800a5b <vprintfmt+0x573>
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a2d:	83 c0 08             	add    $0x8,%eax
  800a30:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a33:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a3b:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a40:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a44:	4c 89 fe             	mov    %r15,%rsi
  800a47:	4c 89 ef             	mov    %r13,%rdi
  800a4a:	48 b8 be 03 80 00 00 	movabs $0x8003be,%rax
  800a51:	00 00 00 
  800a54:	ff d0                	callq  *%rax
        break;
  800a56:	e9 b7 fa ff ff       	jmpq   800512 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a5b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a5f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a63:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a67:	eb ca                	jmp    800a33 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a69:	83 f9 01             	cmp    $0x1,%ecx
  800a6c:	7f 22                	jg     800a90 <vprintfmt+0x5a8>
  else if (lflag)
  800a6e:	85 c9                	test   %ecx,%ecx
  800a70:	74 58                	je     800aca <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a72:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a75:	83 f8 2f             	cmp    $0x2f,%eax
  800a78:	77 42                	ja     800abc <vprintfmt+0x5d4>
  800a7a:	89 c2                	mov    %eax,%edx
  800a7c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a80:	83 c0 08             	add    $0x8,%eax
  800a83:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a86:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a89:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a8e:	eb ab                	jmp    800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a90:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a93:	83 f8 2f             	cmp    $0x2f,%eax
  800a96:	77 16                	ja     800aae <vprintfmt+0x5c6>
  800a98:	89 c2                	mov    %eax,%edx
  800a9a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a9e:	83 c0 08             	add    $0x8,%eax
  800aa1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aa4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aa7:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aac:	eb 8d                	jmp    800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800aae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ab2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aba:	eb e8                	jmp    800aa4 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800abc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ac0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ac4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ac8:	eb bc                	jmp    800a86 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800aca:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800acd:	83 f8 2f             	cmp    $0x2f,%eax
  800ad0:	77 18                	ja     800aea <vprintfmt+0x602>
  800ad2:	89 c2                	mov    %eax,%edx
  800ad4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad8:	83 c0 08             	add    $0x8,%eax
  800adb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ade:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800ae0:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae5:	e9 51 ff ff ff       	jmpq   800a3b <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800aea:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aee:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800af6:	eb e6                	jmp    800ade <vprintfmt+0x5f6>
        putch(ch, putdat);
  800af8:	4c 89 fe             	mov    %r15,%rsi
  800afb:	bf 25 00 00 00       	mov    $0x25,%edi
  800b00:	41 ff d5             	callq  *%r13
        break;
  800b03:	e9 0a fa ff ff       	jmpq   800512 <vprintfmt+0x2a>
        putch('%', putdat);
  800b08:	4c 89 fe             	mov    %r15,%rsi
  800b0b:	bf 25 00 00 00       	mov    $0x25,%edi
  800b10:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b13:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b17:	0f 84 15 fa ff ff    	je     800532 <vprintfmt+0x4a>
  800b1d:	49 89 de             	mov    %rbx,%r14
  800b20:	49 83 ee 01          	sub    $0x1,%r14
  800b24:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b29:	75 f5                	jne    800b20 <vprintfmt+0x638>
  800b2b:	e9 e2 f9 ff ff       	jmpq   800512 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b30:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b34:	74 06                	je     800b3c <vprintfmt+0x654>
  800b36:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b3a:	7f 21                	jg     800b5d <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b3c:	bf 28 00 00 00       	mov    $0x28,%edi
  800b41:	48 bb 9c 11 80 00 00 	movabs $0x80119c,%rbx
  800b48:	00 00 00 
  800b4b:	b8 28 00 00 00       	mov    $0x28,%eax
  800b50:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b54:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b58:	e9 82 fc ff ff       	jmpq   8007df <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b5d:	49 63 f4             	movslq %r12d,%rsi
  800b60:	48 bf 9b 11 80 00 00 	movabs $0x80119b,%rdi
  800b67:	00 00 00 
  800b6a:	48 b8 bf 0c 80 00 00 	movabs $0x800cbf,%rax
  800b71:	00 00 00 
  800b74:	ff d0                	callq  *%rax
  800b76:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b79:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b7c:	48 be 9b 11 80 00 00 	movabs $0x80119b,%rsi
  800b83:	00 00 00 
  800b86:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	0f 8f f2 fb ff ff    	jg     800784 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b92:	48 bb 9c 11 80 00 00 	movabs $0x80119c,%rbx
  800b99:	00 00 00 
  800b9c:	b8 28 00 00 00       	mov    $0x28,%eax
  800ba1:	bf 28 00 00 00       	mov    $0x28,%edi
  800ba6:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800baa:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bae:	e9 2c fc ff ff       	jmpq   8007df <vprintfmt+0x2f7>
}
  800bb3:	48 83 c4 48          	add    $0x48,%rsp
  800bb7:	5b                   	pop    %rbx
  800bb8:	41 5c                	pop    %r12
  800bba:	41 5d                	pop    %r13
  800bbc:	41 5e                	pop    %r14
  800bbe:	41 5f                	pop    %r15
  800bc0:	5d                   	pop    %rbp
  800bc1:	c3                   	retq   

0000000000800bc2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bc2:	55                   	push   %rbp
  800bc3:	48 89 e5             	mov    %rsp,%rbp
  800bc6:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bca:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bce:	48 63 c6             	movslq %esi,%rax
  800bd1:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bd6:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800be1:	48 85 ff             	test   %rdi,%rdi
  800be4:	74 2a                	je     800c10 <vsnprintf+0x4e>
  800be6:	85 f6                	test   %esi,%esi
  800be8:	7e 26                	jle    800c10 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800bea:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800bee:	48 bf 4a 04 80 00 00 	movabs $0x80044a,%rdi
  800bf5:	00 00 00 
  800bf8:	48 b8 e8 04 80 00 00 	movabs $0x8004e8,%rax
  800bff:	00 00 00 
  800c02:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c04:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c08:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c0b:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c0e:	c9                   	leaveq 
  800c0f:	c3                   	retq   
    return -E_INVAL;
  800c10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c15:	eb f7                	jmp    800c0e <vsnprintf+0x4c>

0000000000800c17 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c17:	55                   	push   %rbp
  800c18:	48 89 e5             	mov    %rsp,%rbp
  800c1b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c22:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c29:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c30:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c37:	84 c0                	test   %al,%al
  800c39:	74 20                	je     800c5b <snprintf+0x44>
  800c3b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c3f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c43:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c47:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c4b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c4f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c53:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c57:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c5b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c62:	00 00 00 
  800c65:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c6c:	00 00 00 
  800c6f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c73:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c7a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c81:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c88:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c8f:	48 b8 c2 0b 80 00 00 	movabs $0x800bc2,%rax
  800c96:	00 00 00 
  800c99:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800c9b:	c9                   	leaveq 
  800c9c:	c3                   	retq   

0000000000800c9d <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800c9d:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ca0:	74 17                	je     800cb9 <strlen+0x1c>
  800ca2:	48 89 fa             	mov    %rdi,%rdx
  800ca5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800caa:	29 f9                	sub    %edi,%ecx
    n++;
  800cac:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800caf:	48 83 c2 01          	add    $0x1,%rdx
  800cb3:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cb6:	75 f4                	jne    800cac <strlen+0xf>
  800cb8:	c3                   	retq   
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cbe:	c3                   	retq   

0000000000800cbf <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbf:	48 85 f6             	test   %rsi,%rsi
  800cc2:	74 24                	je     800ce8 <strnlen+0x29>
  800cc4:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cc7:	74 25                	je     800cee <strnlen+0x2f>
  800cc9:	48 01 fe             	add    %rdi,%rsi
  800ccc:	48 89 fa             	mov    %rdi,%rdx
  800ccf:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cd4:	29 f9                	sub    %edi,%ecx
    n++;
  800cd6:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd9:	48 83 c2 01          	add    $0x1,%rdx
  800cdd:	48 39 f2             	cmp    %rsi,%rdx
  800ce0:	74 11                	je     800cf3 <strnlen+0x34>
  800ce2:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ce5:	75 ef                	jne    800cd6 <strnlen+0x17>
  800ce7:	c3                   	retq   
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ced:	c3                   	retq   
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cf3:	c3                   	retq   

0000000000800cf4 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800cf4:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfc:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d00:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d03:	48 83 c2 01          	add    $0x1,%rdx
  800d07:	84 c9                	test   %cl,%cl
  800d09:	75 f1                	jne    800cfc <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d0b:	c3                   	retq   

0000000000800d0c <strcat>:

char *
strcat(char *dst, const char *src) {
  800d0c:	55                   	push   %rbp
  800d0d:	48 89 e5             	mov    %rsp,%rbp
  800d10:	41 54                	push   %r12
  800d12:	53                   	push   %rbx
  800d13:	48 89 fb             	mov    %rdi,%rbx
  800d16:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d19:	48 b8 9d 0c 80 00 00 	movabs $0x800c9d,%rax
  800d20:	00 00 00 
  800d23:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d25:	48 63 f8             	movslq %eax,%rdi
  800d28:	48 01 df             	add    %rbx,%rdi
  800d2b:	4c 89 e6             	mov    %r12,%rsi
  800d2e:	48 b8 f4 0c 80 00 00 	movabs $0x800cf4,%rax
  800d35:	00 00 00 
  800d38:	ff d0                	callq  *%rax
  return dst;
}
  800d3a:	48 89 d8             	mov    %rbx,%rax
  800d3d:	5b                   	pop    %rbx
  800d3e:	41 5c                	pop    %r12
  800d40:	5d                   	pop    %rbp
  800d41:	c3                   	retq   

0000000000800d42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d42:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d45:	48 85 d2             	test   %rdx,%rdx
  800d48:	74 1f                	je     800d69 <strncpy+0x27>
  800d4a:	48 01 fa             	add    %rdi,%rdx
  800d4d:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d50:	48 83 c1 01          	add    $0x1,%rcx
  800d54:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d58:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d5c:	41 80 f8 01          	cmp    $0x1,%r8b
  800d60:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d64:	48 39 ca             	cmp    %rcx,%rdx
  800d67:	75 e7                	jne    800d50 <strncpy+0xe>
  }
  return ret;
}
  800d69:	c3                   	retq   

0000000000800d6a <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d6a:	48 89 f8             	mov    %rdi,%rax
  800d6d:	48 85 d2             	test   %rdx,%rdx
  800d70:	74 36                	je     800da8 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d72:	48 83 fa 01          	cmp    $0x1,%rdx
  800d76:	74 2d                	je     800da5 <strlcpy+0x3b>
  800d78:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d7c:	45 84 c0             	test   %r8b,%r8b
  800d7f:	74 24                	je     800da5 <strlcpy+0x3b>
  800d81:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d85:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d8a:	48 83 c0 01          	add    $0x1,%rax
  800d8e:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d92:	48 39 d1             	cmp    %rdx,%rcx
  800d95:	74 0e                	je     800da5 <strlcpy+0x3b>
  800d97:	48 83 c1 01          	add    $0x1,%rcx
  800d9b:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800da0:	45 84 c0             	test   %r8b,%r8b
  800da3:	75 e5                	jne    800d8a <strlcpy+0x20>
    *dst = '\0';
  800da5:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800da8:	48 29 f8             	sub    %rdi,%rax
}
  800dab:	c3                   	retq   

0000000000800dac <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dac:	0f b6 07             	movzbl (%rdi),%eax
  800daf:	84 c0                	test   %al,%al
  800db1:	74 17                	je     800dca <strcmp+0x1e>
  800db3:	3a 06                	cmp    (%rsi),%al
  800db5:	75 13                	jne    800dca <strcmp+0x1e>
    p++, q++;
  800db7:	48 83 c7 01          	add    $0x1,%rdi
  800dbb:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dbf:	0f b6 07             	movzbl (%rdi),%eax
  800dc2:	84 c0                	test   %al,%al
  800dc4:	74 04                	je     800dca <strcmp+0x1e>
  800dc6:	3a 06                	cmp    (%rsi),%al
  800dc8:	74 ed                	je     800db7 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dca:	0f b6 c0             	movzbl %al,%eax
  800dcd:	0f b6 16             	movzbl (%rsi),%edx
  800dd0:	29 d0                	sub    %edx,%eax
}
  800dd2:	c3                   	retq   

0000000000800dd3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800dd3:	48 85 d2             	test   %rdx,%rdx
  800dd6:	74 2f                	je     800e07 <strncmp+0x34>
  800dd8:	0f b6 07             	movzbl (%rdi),%eax
  800ddb:	84 c0                	test   %al,%al
  800ddd:	74 1f                	je     800dfe <strncmp+0x2b>
  800ddf:	3a 06                	cmp    (%rsi),%al
  800de1:	75 1b                	jne    800dfe <strncmp+0x2b>
  800de3:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800de6:	48 83 c7 01          	add    $0x1,%rdi
  800dea:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800dee:	48 39 d7             	cmp    %rdx,%rdi
  800df1:	74 1a                	je     800e0d <strncmp+0x3a>
  800df3:	0f b6 07             	movzbl (%rdi),%eax
  800df6:	84 c0                	test   %al,%al
  800df8:	74 04                	je     800dfe <strncmp+0x2b>
  800dfa:	3a 06                	cmp    (%rsi),%al
  800dfc:	74 e8                	je     800de6 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800dfe:	0f b6 07             	movzbl (%rdi),%eax
  800e01:	0f b6 16             	movzbl (%rsi),%edx
  800e04:	29 d0                	sub    %edx,%eax
}
  800e06:	c3                   	retq   
    return 0;
  800e07:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0c:	c3                   	retq   
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e12:	c3                   	retq   

0000000000800e13 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e13:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e15:	0f b6 07             	movzbl (%rdi),%eax
  800e18:	84 c0                	test   %al,%al
  800e1a:	74 1e                	je     800e3a <strchr+0x27>
    if (*s == c)
  800e1c:	40 38 c6             	cmp    %al,%sil
  800e1f:	74 1f                	je     800e40 <strchr+0x2d>
  for (; *s; s++)
  800e21:	48 83 c7 01          	add    $0x1,%rdi
  800e25:	0f b6 07             	movzbl (%rdi),%eax
  800e28:	84 c0                	test   %al,%al
  800e2a:	74 08                	je     800e34 <strchr+0x21>
    if (*s == c)
  800e2c:	38 d0                	cmp    %dl,%al
  800e2e:	75 f1                	jne    800e21 <strchr+0xe>
  for (; *s; s++)
  800e30:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e33:	c3                   	retq   
  return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	c3                   	retq   
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3f:	c3                   	retq   
    if (*s == c)
  800e40:	48 89 f8             	mov    %rdi,%rax
  800e43:	c3                   	retq   

0000000000800e44 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e44:	48 89 f8             	mov    %rdi,%rax
  800e47:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e49:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e4c:	40 38 f2             	cmp    %sil,%dl
  800e4f:	74 13                	je     800e64 <strfind+0x20>
  800e51:	84 d2                	test   %dl,%dl
  800e53:	74 0f                	je     800e64 <strfind+0x20>
  for (; *s; s++)
  800e55:	48 83 c0 01          	add    $0x1,%rax
  800e59:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e5c:	38 ca                	cmp    %cl,%dl
  800e5e:	74 04                	je     800e64 <strfind+0x20>
  800e60:	84 d2                	test   %dl,%dl
  800e62:	75 f1                	jne    800e55 <strfind+0x11>
      break;
  return (char *)s;
}
  800e64:	c3                   	retq   

0000000000800e65 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e65:	48 85 d2             	test   %rdx,%rdx
  800e68:	74 3a                	je     800ea4 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e6a:	48 89 f8             	mov    %rdi,%rax
  800e6d:	48 09 d0             	or     %rdx,%rax
  800e70:	a8 03                	test   $0x3,%al
  800e72:	75 28                	jne    800e9c <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e74:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e78:	89 f0                	mov    %esi,%eax
  800e7a:	c1 e0 08             	shl    $0x8,%eax
  800e7d:	89 f1                	mov    %esi,%ecx
  800e7f:	c1 e1 18             	shl    $0x18,%ecx
  800e82:	41 89 f0             	mov    %esi,%r8d
  800e85:	41 c1 e0 10          	shl    $0x10,%r8d
  800e89:	44 09 c1             	or     %r8d,%ecx
  800e8c:	09 ce                	or     %ecx,%esi
  800e8e:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e90:	48 c1 ea 02          	shr    $0x2,%rdx
  800e94:	48 89 d1             	mov    %rdx,%rcx
  800e97:	fc                   	cld    
  800e98:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e9a:	eb 08                	jmp    800ea4 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800e9c:	89 f0                	mov    %esi,%eax
  800e9e:	48 89 d1             	mov    %rdx,%rcx
  800ea1:	fc                   	cld    
  800ea2:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ea4:	48 89 f8             	mov    %rdi,%rax
  800ea7:	c3                   	retq   

0000000000800ea8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ea8:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800eab:	48 39 fe             	cmp    %rdi,%rsi
  800eae:	73 40                	jae    800ef0 <memmove+0x48>
  800eb0:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800eb4:	48 39 f9             	cmp    %rdi,%rcx
  800eb7:	76 37                	jbe    800ef0 <memmove+0x48>
    s += n;
    d += n;
  800eb9:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ebd:	48 89 fe             	mov    %rdi,%rsi
  800ec0:	48 09 d6             	or     %rdx,%rsi
  800ec3:	48 09 ce             	or     %rcx,%rsi
  800ec6:	40 f6 c6 03          	test   $0x3,%sil
  800eca:	75 14                	jne    800ee0 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800ecc:	48 83 ef 04          	sub    $0x4,%rdi
  800ed0:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ed4:	48 c1 ea 02          	shr    $0x2,%rdx
  800ed8:	48 89 d1             	mov    %rdx,%rcx
  800edb:	fd                   	std    
  800edc:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800ede:	eb 0e                	jmp    800eee <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800ee0:	48 83 ef 01          	sub    $0x1,%rdi
  800ee4:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800ee8:	48 89 d1             	mov    %rdx,%rcx
  800eeb:	fd                   	std    
  800eec:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800eee:	fc                   	cld    
  800eef:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ef0:	48 89 c1             	mov    %rax,%rcx
  800ef3:	48 09 d1             	or     %rdx,%rcx
  800ef6:	48 09 f1             	or     %rsi,%rcx
  800ef9:	f6 c1 03             	test   $0x3,%cl
  800efc:	75 0e                	jne    800f0c <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800efe:	48 c1 ea 02          	shr    $0x2,%rdx
  800f02:	48 89 d1             	mov    %rdx,%rcx
  800f05:	48 89 c7             	mov    %rax,%rdi
  800f08:	fc                   	cld    
  800f09:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f0b:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f0c:	48 89 c7             	mov    %rax,%rdi
  800f0f:	48 89 d1             	mov    %rdx,%rcx
  800f12:	fc                   	cld    
  800f13:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f15:	c3                   	retq   

0000000000800f16 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f16:	55                   	push   %rbp
  800f17:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f1a:	48 b8 a8 0e 80 00 00 	movabs $0x800ea8,%rax
  800f21:	00 00 00 
  800f24:	ff d0                	callq  *%rax
}
  800f26:	5d                   	pop    %rbp
  800f27:	c3                   	retq   

0000000000800f28 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f28:	55                   	push   %rbp
  800f29:	48 89 e5             	mov    %rsp,%rbp
  800f2c:	41 57                	push   %r15
  800f2e:	41 56                	push   %r14
  800f30:	41 55                	push   %r13
  800f32:	41 54                	push   %r12
  800f34:	53                   	push   %rbx
  800f35:	48 83 ec 08          	sub    $0x8,%rsp
  800f39:	49 89 fe             	mov    %rdi,%r14
  800f3c:	49 89 f7             	mov    %rsi,%r15
  800f3f:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f42:	48 89 f7             	mov    %rsi,%rdi
  800f45:	48 b8 9d 0c 80 00 00 	movabs $0x800c9d,%rax
  800f4c:	00 00 00 
  800f4f:	ff d0                	callq  *%rax
  800f51:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f54:	4c 89 ee             	mov    %r13,%rsi
  800f57:	4c 89 f7             	mov    %r14,%rdi
  800f5a:	48 b8 bf 0c 80 00 00 	movabs $0x800cbf,%rax
  800f61:	00 00 00 
  800f64:	ff d0                	callq  *%rax
  800f66:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f69:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f6d:	4d 39 e5             	cmp    %r12,%r13
  800f70:	74 26                	je     800f98 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f72:	4c 89 e8             	mov    %r13,%rax
  800f75:	4c 29 e0             	sub    %r12,%rax
  800f78:	48 39 d8             	cmp    %rbx,%rax
  800f7b:	76 2a                	jbe    800fa7 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f7d:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f81:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f85:	4c 89 fe             	mov    %r15,%rsi
  800f88:	48 b8 16 0f 80 00 00 	movabs $0x800f16,%rax
  800f8f:	00 00 00 
  800f92:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f94:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800f98:	48 83 c4 08          	add    $0x8,%rsp
  800f9c:	5b                   	pop    %rbx
  800f9d:	41 5c                	pop    %r12
  800f9f:	41 5d                	pop    %r13
  800fa1:	41 5e                	pop    %r14
  800fa3:	41 5f                	pop    %r15
  800fa5:	5d                   	pop    %rbp
  800fa6:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fa7:	49 83 ed 01          	sub    $0x1,%r13
  800fab:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800faf:	4c 89 ea             	mov    %r13,%rdx
  800fb2:	4c 89 fe             	mov    %r15,%rsi
  800fb5:	48 b8 16 0f 80 00 00 	movabs $0x800f16,%rax
  800fbc:	00 00 00 
  800fbf:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fc1:	4d 01 ee             	add    %r13,%r14
  800fc4:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fc9:	eb c9                	jmp    800f94 <strlcat+0x6c>

0000000000800fcb <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fcb:	48 85 d2             	test   %rdx,%rdx
  800fce:	74 3a                	je     80100a <memcmp+0x3f>
    if (*s1 != *s2)
  800fd0:	0f b6 0f             	movzbl (%rdi),%ecx
  800fd3:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fd7:	44 38 c1             	cmp    %r8b,%cl
  800fda:	75 1d                	jne    800ff9 <memcmp+0x2e>
  800fdc:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fe1:	48 39 d0             	cmp    %rdx,%rax
  800fe4:	74 1e                	je     801004 <memcmp+0x39>
    if (*s1 != *s2)
  800fe6:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800fea:	48 83 c0 01          	add    $0x1,%rax
  800fee:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ff4:	44 38 c1             	cmp    %r8b,%cl
  800ff7:	74 e8                	je     800fe1 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ff9:	0f b6 c1             	movzbl %cl,%eax
  800ffc:	45 0f b6 c0          	movzbl %r8b,%r8d
  801000:	44 29 c0             	sub    %r8d,%eax
  801003:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801004:	b8 00 00 00 00       	mov    $0x0,%eax
  801009:	c3                   	retq   
  80100a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100f:	c3                   	retq   

0000000000801010 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801010:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801014:	48 39 c7             	cmp    %rax,%rdi
  801017:	73 19                	jae    801032 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801019:	89 f2                	mov    %esi,%edx
  80101b:	40 38 37             	cmp    %sil,(%rdi)
  80101e:	74 16                	je     801036 <memfind+0x26>
  for (; s < ends; s++)
  801020:	48 83 c7 01          	add    $0x1,%rdi
  801024:	48 39 f8             	cmp    %rdi,%rax
  801027:	74 08                	je     801031 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801029:	38 17                	cmp    %dl,(%rdi)
  80102b:	75 f3                	jne    801020 <memfind+0x10>
  for (; s < ends; s++)
  80102d:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801030:	c3                   	retq   
  801031:	c3                   	retq   
  for (; s < ends; s++)
  801032:	48 89 f8             	mov    %rdi,%rax
  801035:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801036:	48 89 f8             	mov    %rdi,%rax
  801039:	c3                   	retq   

000000000080103a <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80103a:	0f b6 07             	movzbl (%rdi),%eax
  80103d:	3c 20                	cmp    $0x20,%al
  80103f:	74 04                	je     801045 <strtol+0xb>
  801041:	3c 09                	cmp    $0x9,%al
  801043:	75 0f                	jne    801054 <strtol+0x1a>
    s++;
  801045:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801049:	0f b6 07             	movzbl (%rdi),%eax
  80104c:	3c 20                	cmp    $0x20,%al
  80104e:	74 f5                	je     801045 <strtol+0xb>
  801050:	3c 09                	cmp    $0x9,%al
  801052:	74 f1                	je     801045 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801054:	3c 2b                	cmp    $0x2b,%al
  801056:	74 2b                	je     801083 <strtol+0x49>
  int neg  = 0;
  801058:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80105e:	3c 2d                	cmp    $0x2d,%al
  801060:	74 2d                	je     80108f <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801062:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801068:	75 0f                	jne    801079 <strtol+0x3f>
  80106a:	80 3f 30             	cmpb   $0x30,(%rdi)
  80106d:	74 2c                	je     80109b <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80106f:	85 d2                	test   %edx,%edx
  801071:	b8 0a 00 00 00       	mov    $0xa,%eax
  801076:	0f 44 d0             	cmove  %eax,%edx
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80107e:	4c 63 d2             	movslq %edx,%r10
  801081:	eb 5c                	jmp    8010df <strtol+0xa5>
    s++;
  801083:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801087:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80108d:	eb d3                	jmp    801062 <strtol+0x28>
    s++, neg = 1;
  80108f:	48 83 c7 01          	add    $0x1,%rdi
  801093:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801099:	eb c7                	jmp    801062 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80109b:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80109f:	74 0f                	je     8010b0 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010a1:	85 d2                	test   %edx,%edx
  8010a3:	75 d4                	jne    801079 <strtol+0x3f>
    s++, base = 8;
  8010a5:	48 83 c7 01          	add    $0x1,%rdi
  8010a9:	ba 08 00 00 00       	mov    $0x8,%edx
  8010ae:	eb c9                	jmp    801079 <strtol+0x3f>
    s += 2, base = 16;
  8010b0:	48 83 c7 02          	add    $0x2,%rdi
  8010b4:	ba 10 00 00 00       	mov    $0x10,%edx
  8010b9:	eb be                	jmp    801079 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010bb:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010bf:	41 80 f8 19          	cmp    $0x19,%r8b
  8010c3:	77 2f                	ja     8010f4 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010c5:	44 0f be c1          	movsbl %cl,%r8d
  8010c9:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010cd:	39 d1                	cmp    %edx,%ecx
  8010cf:	7d 37                	jge    801108 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010d1:	48 83 c7 01          	add    $0x1,%rdi
  8010d5:	49 0f af c2          	imul   %r10,%rax
  8010d9:	48 63 c9             	movslq %ecx,%rcx
  8010dc:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010df:	0f b6 0f             	movzbl (%rdi),%ecx
  8010e2:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010e6:	41 80 f8 09          	cmp    $0x9,%r8b
  8010ea:	77 cf                	ja     8010bb <strtol+0x81>
      dig = *s - '0';
  8010ec:	0f be c9             	movsbl %cl,%ecx
  8010ef:	83 e9 30             	sub    $0x30,%ecx
  8010f2:	eb d9                	jmp    8010cd <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8010f4:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8010f8:	41 80 f8 19          	cmp    $0x19,%r8b
  8010fc:	77 0a                	ja     801108 <strtol+0xce>
      dig = *s - 'A' + 10;
  8010fe:	44 0f be c1          	movsbl %cl,%r8d
  801102:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801106:	eb c5                	jmp    8010cd <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801108:	48 85 f6             	test   %rsi,%rsi
  80110b:	74 03                	je     801110 <strtol+0xd6>
    *endptr = (char *)s;
  80110d:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801110:	48 89 c2             	mov    %rax,%rdx
  801113:	48 f7 da             	neg    %rdx
  801116:	45 85 c9             	test   %r9d,%r9d
  801119:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80111d:	c3                   	retq   
  80111e:	66 90                	xchg   %ax,%ax
