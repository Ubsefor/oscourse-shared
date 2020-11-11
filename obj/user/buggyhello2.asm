
obj/user/buggyhello2:     file format elf64-x86-64


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
  800023:	e8 26 00 00 00       	callq  80004e <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#include <inc/lib.h>

const char *hello = "hello, world\n";

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  sys_cputs(hello, 1024 * 1024);
  80002e:	be 00 00 10 00       	mov    $0x100000,%esi
  800033:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80003a:	00 00 00 
  80003d:	48 8b 38             	mov    (%rax),%rdi
  800040:	48 b8 eb 00 80 00 00 	movabs $0x8000eb,%rax
  800047:	00 00 00 
  80004a:	ff d0                	callq  *%rax
}
  80004c:	5d                   	pop    %rbp
  80004d:	c3                   	retq   

000000000080004e <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80004e:	55                   	push   %rbp
  80004f:	48 89 e5             	mov    %rsp,%rbp
  800052:	41 56                	push   %r14
  800054:	41 55                	push   %r13
  800056:	41 54                	push   %r12
  800058:	53                   	push   %rbx
  800059:	41 89 fd             	mov    %edi,%r13d
  80005c:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80005f:	48 ba 10 20 80 00 00 	movabs $0x802010,%rdx
  800066:	00 00 00 
  800069:	48 b8 10 20 80 00 00 	movabs $0x802010,%rax
  800070:	00 00 00 
  800073:	48 39 c2             	cmp    %rax,%rdx
  800076:	73 23                	jae    80009b <libmain+0x4d>
  800078:	48 89 d3             	mov    %rdx,%rbx
  80007b:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80007f:	48 29 d0             	sub    %rdx,%rax
  800082:	48 c1 e8 03          	shr    $0x3,%rax
  800086:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80008b:	b8 00 00 00 00       	mov    $0x0,%eax
  800090:	ff 13                	callq  *(%rbx)
    ctor++;
  800092:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800096:	4c 39 e3             	cmp    %r12,%rbx
  800099:	75 f0                	jne    80008b <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80009b:	45 85 ed             	test   %r13d,%r13d
  80009e:	7e 0d                	jle    8000ad <libmain+0x5f>
    binaryname = argv[0];
  8000a0:	49 8b 06             	mov    (%r14),%rax
  8000a3:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000aa:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000ad:	4c 89 f6             	mov    %r14,%rsi
  8000b0:	44 89 ef             	mov    %r13d,%edi
  8000b3:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000ba:	00 00 00 
  8000bd:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000bf:	48 b8 d4 00 80 00 00 	movabs $0x8000d4,%rax
  8000c6:	00 00 00 
  8000c9:	ff d0                	callq  *%rax
#endif
}
  8000cb:	5b                   	pop    %rbx
  8000cc:	41 5c                	pop    %r12
  8000ce:	41 5d                	pop    %r13
  8000d0:	41 5e                	pop    %r14
  8000d2:	5d                   	pop    %rbp
  8000d3:	c3                   	retq   

00000000008000d4 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000d4:	55                   	push   %rbp
  8000d5:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8000dd:	48 b8 29 01 80 00 00 	movabs $0x800129,%rax
  8000e4:	00 00 00 
  8000e7:	ff d0                	callq  *%rax
}
  8000e9:	5d                   	pop    %rbp
  8000ea:	c3                   	retq   

00000000008000eb <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000eb:	55                   	push   %rbp
  8000ec:	48 89 e5             	mov    %rsp,%rbp
  8000ef:	53                   	push   %rbx
  8000f0:	48 89 fa             	mov    %rdi,%rdx
  8000f3:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fb:	48 89 c3             	mov    %rax,%rbx
  8000fe:	48 89 c7             	mov    %rax,%rdi
  800101:	48 89 c6             	mov    %rax,%rsi
  800104:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800106:	5b                   	pop    %rbx
  800107:	5d                   	pop    %rbp
  800108:	c3                   	retq   

0000000000800109 <sys_cgetc>:

int
sys_cgetc(void) {
  800109:	55                   	push   %rbp
  80010a:	48 89 e5             	mov    %rsp,%rbp
  80010d:	53                   	push   %rbx
  asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	b8 01 00 00 00       	mov    $0x1,%eax
  800118:	48 89 ca             	mov    %rcx,%rdx
  80011b:	48 89 cb             	mov    %rcx,%rbx
  80011e:	48 89 cf             	mov    %rcx,%rdi
  800121:	48 89 ce             	mov    %rcx,%rsi
  800124:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800126:	5b                   	pop    %rbx
  800127:	5d                   	pop    %rbp
  800128:	c3                   	retq   

0000000000800129 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800129:	55                   	push   %rbp
  80012a:	48 89 e5             	mov    %rsp,%rbp
  80012d:	53                   	push   %rbx
  80012e:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800132:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800135:	be 00 00 00 00       	mov    $0x0,%esi
  80013a:	b8 03 00 00 00       	mov    $0x3,%eax
  80013f:	48 89 f1             	mov    %rsi,%rcx
  800142:	48 89 f3             	mov    %rsi,%rbx
  800145:	48 89 f7             	mov    %rsi,%rdi
  800148:	cd 30                	int    $0x30
  if (check && ret > 0)
  80014a:	48 85 c0             	test   %rax,%rax
  80014d:	7f 07                	jg     800156 <sys_env_destroy+0x2d>
}
  80014f:	48 83 c4 08          	add    $0x8,%rsp
  800153:	5b                   	pop    %rbx
  800154:	5d                   	pop    %rbp
  800155:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800156:	49 89 c0             	mov    %rax,%r8
  800159:	b9 03 00 00 00       	mov    $0x3,%ecx
  80015e:	48 ba 58 11 80 00 00 	movabs $0x801158,%rdx
  800165:	00 00 00 
  800168:	be 22 00 00 00       	mov    $0x22,%esi
  80016d:	48 bf 77 11 80 00 00 	movabs $0x801177,%rdi
  800174:	00 00 00 
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	49 b9 a9 01 80 00 00 	movabs $0x8001a9,%r9
  800183:	00 00 00 
  800186:	41 ff d1             	callq  *%r9

0000000000800189 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800189:	55                   	push   %rbp
  80018a:	48 89 e5             	mov    %rsp,%rbp
  80018d:	53                   	push   %rbx
  asm volatile("int %1\n"
  80018e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800193:	b8 02 00 00 00       	mov    $0x2,%eax
  800198:	48 89 ca             	mov    %rcx,%rdx
  80019b:	48 89 cb             	mov    %rcx,%rbx
  80019e:	48 89 cf             	mov    %rcx,%rdi
  8001a1:	48 89 ce             	mov    %rcx,%rsi
  8001a4:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001a6:	5b                   	pop    %rbx
  8001a7:	5d                   	pop    %rbp
  8001a8:	c3                   	retq   

00000000008001a9 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001a9:	55                   	push   %rbp
  8001aa:	48 89 e5             	mov    %rsp,%rbp
  8001ad:	41 56                	push   %r14
  8001af:	41 55                	push   %r13
  8001b1:	41 54                	push   %r12
  8001b3:	53                   	push   %rbx
  8001b4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001bb:	49 89 fd             	mov    %rdi,%r13
  8001be:	41 89 f6             	mov    %esi,%r14d
  8001c1:	49 89 d4             	mov    %rdx,%r12
  8001c4:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001cb:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001d2:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001d9:	84 c0                	test   %al,%al
  8001db:	74 26                	je     800203 <_panic+0x5a>
  8001dd:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001e4:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001eb:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001ef:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001f3:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001f7:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001fb:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001ff:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800203:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80020a:	00 00 00 
  80020d:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800214:	00 00 00 
  800217:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80021b:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800222:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800229:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800230:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800237:	00 00 00 
  80023a:	48 8b 18             	mov    (%rax),%rbx
  80023d:	48 b8 89 01 80 00 00 	movabs $0x800189,%rax
  800244:	00 00 00 
  800247:	ff d0                	callq  *%rax
  800249:	45 89 f0             	mov    %r14d,%r8d
  80024c:	4c 89 e9             	mov    %r13,%rcx
  80024f:	48 89 da             	mov    %rbx,%rdx
  800252:	89 c6                	mov    %eax,%esi
  800254:	48 bf 88 11 80 00 00 	movabs $0x801188,%rdi
  80025b:	00 00 00 
  80025e:	b8 00 00 00 00       	mov    $0x0,%eax
  800263:	48 bb 4b 03 80 00 00 	movabs $0x80034b,%rbx
  80026a:	00 00 00 
  80026d:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80026f:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800276:	4c 89 e7             	mov    %r12,%rdi
  800279:	48 b8 e3 02 80 00 00 	movabs $0x8002e3,%rax
  800280:	00 00 00 
  800283:	ff d0                	callq  *%rax
  cprintf("\n");
  800285:	48 bf 4c 11 80 00 00 	movabs $0x80114c,%rdi
  80028c:	00 00 00 
  80028f:	b8 00 00 00 00       	mov    $0x0,%eax
  800294:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800296:	cc                   	int3   
  while (1)
  800297:	eb fd                	jmp    800296 <_panic+0xed>

0000000000800299 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800299:	55                   	push   %rbp
  80029a:	48 89 e5             	mov    %rsp,%rbp
  80029d:	53                   	push   %rbx
  80029e:	48 83 ec 08          	sub    $0x8,%rsp
  8002a2:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002a5:	8b 06                	mov    (%rsi),%eax
  8002a7:	8d 50 01             	lea    0x1(%rax),%edx
  8002aa:	89 16                	mov    %edx,(%rsi)
  8002ac:	48 98                	cltq   
  8002ae:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002b3:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002b9:	74 0b                	je     8002c6 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002bb:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002bf:	48 83 c4 08          	add    $0x8,%rsp
  8002c3:	5b                   	pop    %rbx
  8002c4:	5d                   	pop    %rbp
  8002c5:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002c6:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002ca:	be ff 00 00 00       	mov    $0xff,%esi
  8002cf:	48 b8 eb 00 80 00 00 	movabs $0x8000eb,%rax
  8002d6:	00 00 00 
  8002d9:	ff d0                	callq  *%rax
    b->idx = 0;
  8002db:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002e1:	eb d8                	jmp    8002bb <putch+0x22>

00000000008002e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002e3:	55                   	push   %rbp
  8002e4:	48 89 e5             	mov    %rsp,%rbp
  8002e7:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002ee:	48 89 fa             	mov    %rdi,%rdx
  8002f1:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002fb:	00 00 00 
  b.cnt = 0;
  8002fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800305:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800308:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80030f:	48 bf 99 02 80 00 00 	movabs $0x800299,%rdi
  800316:	00 00 00 
  800319:	48 b8 09 05 80 00 00 	movabs $0x800509,%rax
  800320:	00 00 00 
  800323:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800325:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80032c:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800333:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800337:	48 b8 eb 00 80 00 00 	movabs $0x8000eb,%rax
  80033e:	00 00 00 
  800341:	ff d0                	callq  *%rax

  return b.cnt;
}
  800343:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800349:	c9                   	leaveq 
  80034a:	c3                   	retq   

000000000080034b <cprintf>:

int
cprintf(const char *fmt, ...) {
  80034b:	55                   	push   %rbp
  80034c:	48 89 e5             	mov    %rsp,%rbp
  80034f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800356:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80035d:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800364:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80036b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800372:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800379:	84 c0                	test   %al,%al
  80037b:	74 20                	je     80039d <cprintf+0x52>
  80037d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800381:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800385:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800389:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80038d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800391:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800395:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800399:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80039d:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003a4:	00 00 00 
  8003a7:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003ae:	00 00 00 
  8003b1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003b5:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003bc:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003c3:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003ca:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003d1:	48 b8 e3 02 80 00 00 	movabs $0x8002e3,%rax
  8003d8:	00 00 00 
  8003db:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003dd:	c9                   	leaveq 
  8003de:	c3                   	retq   

00000000008003df <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003df:	55                   	push   %rbp
  8003e0:	48 89 e5             	mov    %rsp,%rbp
  8003e3:	41 57                	push   %r15
  8003e5:	41 56                	push   %r14
  8003e7:	41 55                	push   %r13
  8003e9:	41 54                	push   %r12
  8003eb:	53                   	push   %rbx
  8003ec:	48 83 ec 18          	sub    $0x18,%rsp
  8003f0:	49 89 fc             	mov    %rdi,%r12
  8003f3:	49 89 f5             	mov    %rsi,%r13
  8003f6:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003fa:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003fd:	41 89 cf             	mov    %ecx,%r15d
  800400:	49 39 d7             	cmp    %rdx,%r15
  800403:	76 45                	jbe    80044a <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800405:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800409:	85 db                	test   %ebx,%ebx
  80040b:	7e 0e                	jle    80041b <printnum+0x3c>
      putch(padc, putdat);
  80040d:	4c 89 ee             	mov    %r13,%rsi
  800410:	44 89 f7             	mov    %r14d,%edi
  800413:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800416:	83 eb 01             	sub    $0x1,%ebx
  800419:	75 f2                	jne    80040d <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80041b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80041f:	ba 00 00 00 00       	mov    $0x0,%edx
  800424:	49 f7 f7             	div    %r15
  800427:	48 b8 b0 11 80 00 00 	movabs $0x8011b0,%rax
  80042e:	00 00 00 
  800431:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800435:	4c 89 ee             	mov    %r13,%rsi
  800438:	41 ff d4             	callq  *%r12
}
  80043b:	48 83 c4 18          	add    $0x18,%rsp
  80043f:	5b                   	pop    %rbx
  800440:	41 5c                	pop    %r12
  800442:	41 5d                	pop    %r13
  800444:	41 5e                	pop    %r14
  800446:	41 5f                	pop    %r15
  800448:	5d                   	pop    %rbp
  800449:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80044a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80044e:	ba 00 00 00 00       	mov    $0x0,%edx
  800453:	49 f7 f7             	div    %r15
  800456:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80045a:	48 89 c2             	mov    %rax,%rdx
  80045d:	48 b8 df 03 80 00 00 	movabs $0x8003df,%rax
  800464:	00 00 00 
  800467:	ff d0                	callq  *%rax
  800469:	eb b0                	jmp    80041b <printnum+0x3c>

000000000080046b <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80046b:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80046f:	48 8b 06             	mov    (%rsi),%rax
  800472:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800476:	73 0a                	jae    800482 <sprintputch+0x17>
    *b->buf++ = ch;
  800478:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80047c:	48 89 16             	mov    %rdx,(%rsi)
  80047f:	40 88 38             	mov    %dil,(%rax)
}
  800482:	c3                   	retq   

0000000000800483 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800483:	55                   	push   %rbp
  800484:	48 89 e5             	mov    %rsp,%rbp
  800487:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80048e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800495:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80049c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004a3:	84 c0                	test   %al,%al
  8004a5:	74 20                	je     8004c7 <printfmt+0x44>
  8004a7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004ab:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004af:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004b3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004b7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004bb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004bf:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004c3:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004c7:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004ce:	00 00 00 
  8004d1:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004d8:	00 00 00 
  8004db:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004df:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004e6:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004ed:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004f4:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004fb:	48 b8 09 05 80 00 00 	movabs $0x800509,%rax
  800502:	00 00 00 
  800505:	ff d0                	callq  *%rax
}
  800507:	c9                   	leaveq 
  800508:	c3                   	retq   

0000000000800509 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800509:	55                   	push   %rbp
  80050a:	48 89 e5             	mov    %rsp,%rbp
  80050d:	41 57                	push   %r15
  80050f:	41 56                	push   %r14
  800511:	41 55                	push   %r13
  800513:	41 54                	push   %r12
  800515:	53                   	push   %rbx
  800516:	48 83 ec 48          	sub    $0x48,%rsp
  80051a:	49 89 fd             	mov    %rdi,%r13
  80051d:	49 89 f7             	mov    %rsi,%r15
  800520:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800523:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800527:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80052b:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80052f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800533:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800537:	41 0f b6 3e          	movzbl (%r14),%edi
  80053b:	83 ff 25             	cmp    $0x25,%edi
  80053e:	74 18                	je     800558 <vprintfmt+0x4f>
      if (ch == '\0')
  800540:	85 ff                	test   %edi,%edi
  800542:	0f 84 8c 06 00 00    	je     800bd4 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800548:	4c 89 fe             	mov    %r15,%rsi
  80054b:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80054e:	49 89 de             	mov    %rbx,%r14
  800551:	eb e0                	jmp    800533 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800553:	49 89 de             	mov    %rbx,%r14
  800556:	eb db                	jmp    800533 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800558:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80055c:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800560:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800567:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80056d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800571:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800576:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80057c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800582:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800587:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80058c:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800590:	0f b6 13             	movzbl (%rbx),%edx
  800593:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800596:	3c 55                	cmp    $0x55,%al
  800598:	0f 87 8b 05 00 00    	ja     800b29 <vprintfmt+0x620>
  80059e:	0f b6 c0             	movzbl %al,%eax
  8005a1:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  8005a8:	00 00 00 
  8005ab:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005af:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005b2:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005b6:	eb d4                	jmp    80058c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005b8:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005bb:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005bf:	eb cb                	jmp    80058c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005c1:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005c4:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005c8:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005cc:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 7e                	ja     800652 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005d4:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005d8:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005dc:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005e1:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005e5:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005e8:	83 fa 09             	cmp    $0x9,%edx
  8005eb:	76 e7                	jbe    8005d4 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005ed:	4c 89 f3             	mov    %r14,%rbx
  8005f0:	eb 19                	jmp    80060b <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005f2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005f5:	83 f8 2f             	cmp    $0x2f,%eax
  8005f8:	77 2a                	ja     800624 <vprintfmt+0x11b>
  8005fa:	89 c2                	mov    %eax,%edx
  8005fc:	4c 01 d2             	add    %r10,%rdx
  8005ff:	83 c0 08             	add    $0x8,%eax
  800602:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800605:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800608:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80060b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80060f:	0f 89 77 ff ff ff    	jns    80058c <vprintfmt+0x83>
          width = precision, precision = -1;
  800615:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800619:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80061f:	e9 68 ff ff ff       	jmpq   80058c <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800624:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800628:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80062c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800630:	eb d3                	jmp    800605 <vprintfmt+0xfc>
        if (width < 0)
  800632:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800635:	85 c0                	test   %eax,%eax
  800637:	41 0f 48 c0          	cmovs  %r8d,%eax
  80063b:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80063e:	4c 89 f3             	mov    %r14,%rbx
  800641:	e9 46 ff ff ff       	jmpq   80058c <vprintfmt+0x83>
  800646:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800649:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80064d:	e9 3a ff ff ff       	jmpq   80058c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800652:	4c 89 f3             	mov    %r14,%rbx
  800655:	eb b4                	jmp    80060b <vprintfmt+0x102>
        lflag++;
  800657:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80065a:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80065d:	e9 2a ff ff ff       	jmpq   80058c <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800662:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800665:	83 f8 2f             	cmp    $0x2f,%eax
  800668:	77 19                	ja     800683 <vprintfmt+0x17a>
  80066a:	89 c2                	mov    %eax,%edx
  80066c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800670:	83 c0 08             	add    $0x8,%eax
  800673:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800676:	4c 89 fe             	mov    %r15,%rsi
  800679:	8b 3a                	mov    (%rdx),%edi
  80067b:	41 ff d5             	callq  *%r13
        break;
  80067e:	e9 b0 fe ff ff       	jmpq   800533 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800683:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800687:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80068b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80068f:	eb e5                	jmp    800676 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800691:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800694:	83 f8 2f             	cmp    $0x2f,%eax
  800697:	77 5b                	ja     8006f4 <vprintfmt+0x1eb>
  800699:	89 c2                	mov    %eax,%edx
  80069b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80069f:	83 c0 08             	add    $0x8,%eax
  8006a2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006a5:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006a7:	89 c8                	mov    %ecx,%eax
  8006a9:	c1 f8 1f             	sar    $0x1f,%eax
  8006ac:	31 c1                	xor    %eax,%ecx
  8006ae:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b0:	83 f9 09             	cmp    $0x9,%ecx
  8006b3:	7f 4d                	jg     800702 <vprintfmt+0x1f9>
  8006b5:	48 63 c1             	movslq %ecx,%rax
  8006b8:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  8006bf:	00 00 00 
  8006c2:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006c6:	48 85 c0             	test   %rax,%rax
  8006c9:	74 37                	je     800702 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006cb:	48 89 c1             	mov    %rax,%rcx
  8006ce:	48 ba d1 11 80 00 00 	movabs $0x8011d1,%rdx
  8006d5:	00 00 00 
  8006d8:	4c 89 fe             	mov    %r15,%rsi
  8006db:	4c 89 ef             	mov    %r13,%rdi
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	48 bb 83 04 80 00 00 	movabs $0x800483,%rbx
  8006ea:	00 00 00 
  8006ed:	ff d3                	callq  *%rbx
  8006ef:	e9 3f fe ff ff       	jmpq   800533 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006f4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006f8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006fc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800700:	eb a3                	jmp    8006a5 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800702:	48 ba c8 11 80 00 00 	movabs $0x8011c8,%rdx
  800709:	00 00 00 
  80070c:	4c 89 fe             	mov    %r15,%rsi
  80070f:	4c 89 ef             	mov    %r13,%rdi
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	48 bb 83 04 80 00 00 	movabs $0x800483,%rbx
  80071e:	00 00 00 
  800721:	ff d3                	callq  *%rbx
  800723:	e9 0b fe ff ff       	jmpq   800533 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800728:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80072b:	83 f8 2f             	cmp    $0x2f,%eax
  80072e:	77 4b                	ja     80077b <vprintfmt+0x272>
  800730:	89 c2                	mov    %eax,%edx
  800732:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800736:	83 c0 08             	add    $0x8,%eax
  800739:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80073c:	48 8b 02             	mov    (%rdx),%rax
  80073f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800743:	48 85 c0             	test   %rax,%rax
  800746:	0f 84 05 04 00 00    	je     800b51 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80074c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800750:	7e 06                	jle    800758 <vprintfmt+0x24f>
  800752:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800756:	75 31                	jne    800789 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800758:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80075c:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800760:	0f b6 00             	movzbl (%rax),%eax
  800763:	0f be f8             	movsbl %al,%edi
  800766:	85 ff                	test   %edi,%edi
  800768:	0f 84 c3 00 00 00    	je     800831 <vprintfmt+0x328>
  80076e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800772:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800776:	e9 85 00 00 00       	jmpq   800800 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80077b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80077f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800783:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800787:	eb b3                	jmp    80073c <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800789:	49 63 f4             	movslq %r12d,%rsi
  80078c:	48 89 c7             	mov    %rax,%rdi
  80078f:	48 b8 e0 0c 80 00 00 	movabs $0x800ce0,%rax
  800796:	00 00 00 
  800799:	ff d0                	callq  *%rax
  80079b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80079e:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007a1:	85 f6                	test   %esi,%esi
  8007a3:	7e 22                	jle    8007c7 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007a5:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007a9:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007ad:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007b1:	4c 89 fe             	mov    %r15,%rsi
  8007b4:	89 df                	mov    %ebx,%edi
  8007b6:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007b9:	41 83 ec 01          	sub    $0x1,%r12d
  8007bd:	75 f2                	jne    8007b1 <vprintfmt+0x2a8>
  8007bf:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007c3:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007cb:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007cf:	0f b6 00             	movzbl (%rax),%eax
  8007d2:	0f be f8             	movsbl %al,%edi
  8007d5:	85 ff                	test   %edi,%edi
  8007d7:	0f 84 56 fd ff ff    	je     800533 <vprintfmt+0x2a>
  8007dd:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007e1:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007e5:	eb 19                	jmp    800800 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007e7:	4c 89 fe             	mov    %r15,%rsi
  8007ea:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ed:	41 83 ee 01          	sub    $0x1,%r14d
  8007f1:	48 83 c3 01          	add    $0x1,%rbx
  8007f5:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007f9:	0f be f8             	movsbl %al,%edi
  8007fc:	85 ff                	test   %edi,%edi
  8007fe:	74 29                	je     800829 <vprintfmt+0x320>
  800800:	45 85 e4             	test   %r12d,%r12d
  800803:	78 06                	js     80080b <vprintfmt+0x302>
  800805:	41 83 ec 01          	sub    $0x1,%r12d
  800809:	78 48                	js     800853 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80080b:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80080f:	74 d6                	je     8007e7 <vprintfmt+0x2de>
  800811:	0f be c0             	movsbl %al,%eax
  800814:	83 e8 20             	sub    $0x20,%eax
  800817:	83 f8 5e             	cmp    $0x5e,%eax
  80081a:	76 cb                	jbe    8007e7 <vprintfmt+0x2de>
            putch('?', putdat);
  80081c:	4c 89 fe             	mov    %r15,%rsi
  80081f:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800824:	41 ff d5             	callq  *%r13
  800827:	eb c4                	jmp    8007ed <vprintfmt+0x2e4>
  800829:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80082d:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800831:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800834:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800838:	0f 8e f5 fc ff ff    	jle    800533 <vprintfmt+0x2a>
          putch(' ', putdat);
  80083e:	4c 89 fe             	mov    %r15,%rsi
  800841:	bf 20 00 00 00       	mov    $0x20,%edi
  800846:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800849:	83 eb 01             	sub    $0x1,%ebx
  80084c:	75 f0                	jne    80083e <vprintfmt+0x335>
  80084e:	e9 e0 fc ff ff       	jmpq   800533 <vprintfmt+0x2a>
  800853:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800857:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80085b:	eb d4                	jmp    800831 <vprintfmt+0x328>
  if (lflag >= 2)
  80085d:	83 f9 01             	cmp    $0x1,%ecx
  800860:	7f 1d                	jg     80087f <vprintfmt+0x376>
  else if (lflag)
  800862:	85 c9                	test   %ecx,%ecx
  800864:	74 5e                	je     8008c4 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800866:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800869:	83 f8 2f             	cmp    $0x2f,%eax
  80086c:	77 48                	ja     8008b6 <vprintfmt+0x3ad>
  80086e:	89 c2                	mov    %eax,%edx
  800870:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800874:	83 c0 08             	add    $0x8,%eax
  800877:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80087a:	48 8b 1a             	mov    (%rdx),%rbx
  80087d:	eb 17                	jmp    800896 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80087f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800882:	83 f8 2f             	cmp    $0x2f,%eax
  800885:	77 21                	ja     8008a8 <vprintfmt+0x39f>
  800887:	89 c2                	mov    %eax,%edx
  800889:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80088d:	83 c0 08             	add    $0x8,%eax
  800890:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800893:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800896:	48 85 db             	test   %rbx,%rbx
  800899:	78 50                	js     8008eb <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80089b:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80089e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008a3:	e9 b4 01 00 00       	jmpq   800a5c <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008a8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b4:	eb dd                	jmp    800893 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008b6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ba:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008be:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c2:	eb b6                	jmp    80087a <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008c4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008c7:	83 f8 2f             	cmp    $0x2f,%eax
  8008ca:	77 11                	ja     8008dd <vprintfmt+0x3d4>
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d2:	83 c0 08             	add    $0x8,%eax
  8008d5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008d8:	48 63 1a             	movslq (%rdx),%rbx
  8008db:	eb b9                	jmp    800896 <vprintfmt+0x38d>
  8008dd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e9:	eb ed                	jmp    8008d8 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008eb:	4c 89 fe             	mov    %r15,%rsi
  8008ee:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008f3:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008f6:	48 89 da             	mov    %rbx,%rdx
  8008f9:	48 f7 da             	neg    %rdx
        base = 10;
  8008fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800901:	e9 56 01 00 00       	jmpq   800a5c <vprintfmt+0x553>
  if (lflag >= 2)
  800906:	83 f9 01             	cmp    $0x1,%ecx
  800909:	7f 25                	jg     800930 <vprintfmt+0x427>
  else if (lflag)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 5e                	je     80096d <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80090f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800912:	83 f8 2f             	cmp    $0x2f,%eax
  800915:	77 48                	ja     80095f <vprintfmt+0x456>
  800917:	89 c2                	mov    %eax,%edx
  800919:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091d:	83 c0 08             	add    $0x8,%eax
  800920:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800923:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800926:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092b:	e9 2c 01 00 00       	jmpq   800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800930:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800933:	83 f8 2f             	cmp    $0x2f,%eax
  800936:	77 19                	ja     800951 <vprintfmt+0x448>
  800938:	89 c2                	mov    %eax,%edx
  80093a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093e:	83 c0 08             	add    $0x8,%eax
  800941:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800944:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800947:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80094c:	e9 0b 01 00 00       	jmpq   800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800951:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800955:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800959:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80095d:	eb e5                	jmp    800944 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80095f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800963:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800967:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096b:	eb b6                	jmp    800923 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80096d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800970:	83 f8 2f             	cmp    $0x2f,%eax
  800973:	77 18                	ja     80098d <vprintfmt+0x484>
  800975:	89 c2                	mov    %eax,%edx
  800977:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80097b:	83 c0 08             	add    $0x8,%eax
  80097e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800981:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800983:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800988:	e9 cf 00 00 00       	jmpq   800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80098d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800991:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800995:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800999:	eb e6                	jmp    800981 <vprintfmt+0x478>
  if (lflag >= 2)
  80099b:	83 f9 01             	cmp    $0x1,%ecx
  80099e:	7f 25                	jg     8009c5 <vprintfmt+0x4bc>
  else if (lflag)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 5b                	je     8009ff <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009a4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a7:	83 f8 2f             	cmp    $0x2f,%eax
  8009aa:	77 45                	ja     8009f1 <vprintfmt+0x4e8>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009b2:	83 c0 08             	add    $0x8,%eax
  8009b5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b8:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009bb:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009c0:	e9 97 00 00 00       	jmpq   800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009c5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c8:	83 f8 2f             	cmp    $0x2f,%eax
  8009cb:	77 16                	ja     8009e3 <vprintfmt+0x4da>
  8009cd:	89 c2                	mov    %eax,%edx
  8009cf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d3:	83 c0 08             	add    $0x8,%eax
  8009d6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d9:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009dc:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009e1:	eb 79                	jmp    800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009e7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009eb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ef:	eb e8                	jmp    8009d9 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009f1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009f9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009fd:	eb b9                	jmp    8009b8 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009ff:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a02:	83 f8 2f             	cmp    $0x2f,%eax
  800a05:	77 15                	ja     800a1c <vprintfmt+0x513>
  800a07:	89 c2                	mov    %eax,%edx
  800a09:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a0d:	83 c0 08             	add    $0x8,%eax
  800a10:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a13:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a15:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a1a:	eb 40                	jmp    800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a1c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a20:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a24:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a28:	eb e9                	jmp    800a13 <vprintfmt+0x50a>
        putch('0', putdat);
  800a2a:	4c 89 fe             	mov    %r15,%rsi
  800a2d:	bf 30 00 00 00       	mov    $0x30,%edi
  800a32:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a35:	4c 89 fe             	mov    %r15,%rsi
  800a38:	bf 78 00 00 00       	mov    $0x78,%edi
  800a3d:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a40:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a43:	83 f8 2f             	cmp    $0x2f,%eax
  800a46:	77 34                	ja     800a7c <vprintfmt+0x573>
  800a48:	89 c2                	mov    %eax,%edx
  800a4a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a4e:	83 c0 08             	add    $0x8,%eax
  800a51:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a54:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a57:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a5c:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a61:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a65:	4c 89 fe             	mov    %r15,%rsi
  800a68:	4c 89 ef             	mov    %r13,%rdi
  800a6b:	48 b8 df 03 80 00 00 	movabs $0x8003df,%rax
  800a72:	00 00 00 
  800a75:	ff d0                	callq  *%rax
        break;
  800a77:	e9 b7 fa ff ff       	jmpq   800533 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a7c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a80:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a84:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a88:	eb ca                	jmp    800a54 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a8a:	83 f9 01             	cmp    $0x1,%ecx
  800a8d:	7f 22                	jg     800ab1 <vprintfmt+0x5a8>
  else if (lflag)
  800a8f:	85 c9                	test   %ecx,%ecx
  800a91:	74 58                	je     800aeb <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a93:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a96:	83 f8 2f             	cmp    $0x2f,%eax
  800a99:	77 42                	ja     800add <vprintfmt+0x5d4>
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aa1:	83 c0 08             	add    $0x8,%eax
  800aa4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aa7:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aaa:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aaf:	eb ab                	jmp    800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ab1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ab4:	83 f8 2f             	cmp    $0x2f,%eax
  800ab7:	77 16                	ja     800acf <vprintfmt+0x5c6>
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800abf:	83 c0 08             	add    $0x8,%eax
  800ac2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ac5:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ac8:	b9 10 00 00 00       	mov    $0x10,%ecx
  800acd:	eb 8d                	jmp    800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800acf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ad7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800adb:	eb e8                	jmp    800ac5 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800add:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ae1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ae5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ae9:	eb bc                	jmp    800aa7 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800aeb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aee:	83 f8 2f             	cmp    $0x2f,%eax
  800af1:	77 18                	ja     800b0b <vprintfmt+0x602>
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af9:	83 c0 08             	add    $0x8,%eax
  800afc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aff:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b01:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b06:	e9 51 ff ff ff       	jmpq   800a5c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b0b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b0f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b13:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b17:	eb e6                	jmp    800aff <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b19:	4c 89 fe             	mov    %r15,%rsi
  800b1c:	bf 25 00 00 00       	mov    $0x25,%edi
  800b21:	41 ff d5             	callq  *%r13
        break;
  800b24:	e9 0a fa ff ff       	jmpq   800533 <vprintfmt+0x2a>
        putch('%', putdat);
  800b29:	4c 89 fe             	mov    %r15,%rsi
  800b2c:	bf 25 00 00 00       	mov    $0x25,%edi
  800b31:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b34:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b38:	0f 84 15 fa ff ff    	je     800553 <vprintfmt+0x4a>
  800b3e:	49 89 de             	mov    %rbx,%r14
  800b41:	49 83 ee 01          	sub    $0x1,%r14
  800b45:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b4a:	75 f5                	jne    800b41 <vprintfmt+0x638>
  800b4c:	e9 e2 f9 ff ff       	jmpq   800533 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b51:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b55:	74 06                	je     800b5d <vprintfmt+0x654>
  800b57:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b5b:	7f 21                	jg     800b7e <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b5d:	bf 28 00 00 00       	mov    $0x28,%edi
  800b62:	48 bb c2 11 80 00 00 	movabs $0x8011c2,%rbx
  800b69:	00 00 00 
  800b6c:	b8 28 00 00 00       	mov    $0x28,%eax
  800b71:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b75:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b79:	e9 82 fc ff ff       	jmpq   800800 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b7e:	49 63 f4             	movslq %r12d,%rsi
  800b81:	48 bf c1 11 80 00 00 	movabs $0x8011c1,%rdi
  800b88:	00 00 00 
  800b8b:	48 b8 e0 0c 80 00 00 	movabs $0x800ce0,%rax
  800b92:	00 00 00 
  800b95:	ff d0                	callq  *%rax
  800b97:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b9a:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b9d:	48 be c1 11 80 00 00 	movabs $0x8011c1,%rsi
  800ba4:	00 00 00 
  800ba7:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	0f 8f f2 fb ff ff    	jg     8007a5 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb3:	48 bb c2 11 80 00 00 	movabs $0x8011c2,%rbx
  800bba:	00 00 00 
  800bbd:	b8 28 00 00 00       	mov    $0x28,%eax
  800bc2:	bf 28 00 00 00       	mov    $0x28,%edi
  800bc7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bcb:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bcf:	e9 2c fc ff ff       	jmpq   800800 <vprintfmt+0x2f7>
}
  800bd4:	48 83 c4 48          	add    $0x48,%rsp
  800bd8:	5b                   	pop    %rbx
  800bd9:	41 5c                	pop    %r12
  800bdb:	41 5d                	pop    %r13
  800bdd:	41 5e                	pop    %r14
  800bdf:	41 5f                	pop    %r15
  800be1:	5d                   	pop    %rbp
  800be2:	c3                   	retq   

0000000000800be3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800be3:	55                   	push   %rbp
  800be4:	48 89 e5             	mov    %rsp,%rbp
  800be7:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800beb:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bef:	48 63 c6             	movslq %esi,%rax
  800bf2:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bf7:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bfb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c02:	48 85 ff             	test   %rdi,%rdi
  800c05:	74 2a                	je     800c31 <vsnprintf+0x4e>
  800c07:	85 f6                	test   %esi,%esi
  800c09:	7e 26                	jle    800c31 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c0b:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c0f:	48 bf 6b 04 80 00 00 	movabs $0x80046b,%rdi
  800c16:	00 00 00 
  800c19:	48 b8 09 05 80 00 00 	movabs $0x800509,%rax
  800c20:	00 00 00 
  800c23:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c25:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c29:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c2c:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c2f:	c9                   	leaveq 
  800c30:	c3                   	retq   
    return -E_INVAL;
  800c31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c36:	eb f7                	jmp    800c2f <vsnprintf+0x4c>

0000000000800c38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c38:	55                   	push   %rbp
  800c39:	48 89 e5             	mov    %rsp,%rbp
  800c3c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c43:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c4a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c51:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c58:	84 c0                	test   %al,%al
  800c5a:	74 20                	je     800c7c <snprintf+0x44>
  800c5c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c60:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c64:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c68:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c6c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c70:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c74:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c78:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c7c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c83:	00 00 00 
  800c86:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c8d:	00 00 00 
  800c90:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c94:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c9b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800ca2:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800ca9:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cb0:	48 b8 e3 0b 80 00 00 	movabs $0x800be3,%rax
  800cb7:	00 00 00 
  800cba:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cbc:	c9                   	leaveq 
  800cbd:	c3                   	retq   

0000000000800cbe <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cbe:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cc1:	74 17                	je     800cda <strlen+0x1c>
  800cc3:	48 89 fa             	mov    %rdi,%rdx
  800cc6:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ccb:	29 f9                	sub    %edi,%ecx
    n++;
  800ccd:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cd0:	48 83 c2 01          	add    $0x1,%rdx
  800cd4:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cd7:	75 f4                	jne    800ccd <strlen+0xf>
  800cd9:	c3                   	retq   
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cdf:	c3                   	retq   

0000000000800ce0 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce0:	48 85 f6             	test   %rsi,%rsi
  800ce3:	74 24                	je     800d09 <strnlen+0x29>
  800ce5:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ce8:	74 25                	je     800d0f <strnlen+0x2f>
  800cea:	48 01 fe             	add    %rdi,%rsi
  800ced:	48 89 fa             	mov    %rdi,%rdx
  800cf0:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cf5:	29 f9                	sub    %edi,%ecx
    n++;
  800cf7:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cfa:	48 83 c2 01          	add    $0x1,%rdx
  800cfe:	48 39 f2             	cmp    %rsi,%rdx
  800d01:	74 11                	je     800d14 <strnlen+0x34>
  800d03:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d06:	75 ef                	jne    800cf7 <strnlen+0x17>
  800d08:	c3                   	retq   
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	c3                   	retq   
  800d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d14:	c3                   	retq   

0000000000800d15 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d15:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1d:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d21:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d24:	48 83 c2 01          	add    $0x1,%rdx
  800d28:	84 c9                	test   %cl,%cl
  800d2a:	75 f1                	jne    800d1d <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d2c:	c3                   	retq   

0000000000800d2d <strcat>:

char *
strcat(char *dst, const char *src) {
  800d2d:	55                   	push   %rbp
  800d2e:	48 89 e5             	mov    %rsp,%rbp
  800d31:	41 54                	push   %r12
  800d33:	53                   	push   %rbx
  800d34:	48 89 fb             	mov    %rdi,%rbx
  800d37:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d3a:	48 b8 be 0c 80 00 00 	movabs $0x800cbe,%rax
  800d41:	00 00 00 
  800d44:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d46:	48 63 f8             	movslq %eax,%rdi
  800d49:	48 01 df             	add    %rbx,%rdi
  800d4c:	4c 89 e6             	mov    %r12,%rsi
  800d4f:	48 b8 15 0d 80 00 00 	movabs $0x800d15,%rax
  800d56:	00 00 00 
  800d59:	ff d0                	callq  *%rax
  return dst;
}
  800d5b:	48 89 d8             	mov    %rbx,%rax
  800d5e:	5b                   	pop    %rbx
  800d5f:	41 5c                	pop    %r12
  800d61:	5d                   	pop    %rbp
  800d62:	c3                   	retq   

0000000000800d63 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d63:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d66:	48 85 d2             	test   %rdx,%rdx
  800d69:	74 1f                	je     800d8a <strncpy+0x27>
  800d6b:	48 01 fa             	add    %rdi,%rdx
  800d6e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d71:	48 83 c1 01          	add    $0x1,%rcx
  800d75:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d79:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d7d:	41 80 f8 01          	cmp    $0x1,%r8b
  800d81:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d85:	48 39 ca             	cmp    %rcx,%rdx
  800d88:	75 e7                	jne    800d71 <strncpy+0xe>
  }
  return ret;
}
  800d8a:	c3                   	retq   

0000000000800d8b <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d8b:	48 89 f8             	mov    %rdi,%rax
  800d8e:	48 85 d2             	test   %rdx,%rdx
  800d91:	74 36                	je     800dc9 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d93:	48 83 fa 01          	cmp    $0x1,%rdx
  800d97:	74 2d                	je     800dc6 <strlcpy+0x3b>
  800d99:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d9d:	45 84 c0             	test   %r8b,%r8b
  800da0:	74 24                	je     800dc6 <strlcpy+0x3b>
  800da2:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800da6:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dab:	48 83 c0 01          	add    $0x1,%rax
  800daf:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800db3:	48 39 d1             	cmp    %rdx,%rcx
  800db6:	74 0e                	je     800dc6 <strlcpy+0x3b>
  800db8:	48 83 c1 01          	add    $0x1,%rcx
  800dbc:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dc1:	45 84 c0             	test   %r8b,%r8b
  800dc4:	75 e5                	jne    800dab <strlcpy+0x20>
    *dst = '\0';
  800dc6:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dc9:	48 29 f8             	sub    %rdi,%rax
}
  800dcc:	c3                   	retq   

0000000000800dcd <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dcd:	0f b6 07             	movzbl (%rdi),%eax
  800dd0:	84 c0                	test   %al,%al
  800dd2:	74 17                	je     800deb <strcmp+0x1e>
  800dd4:	3a 06                	cmp    (%rsi),%al
  800dd6:	75 13                	jne    800deb <strcmp+0x1e>
    p++, q++;
  800dd8:	48 83 c7 01          	add    $0x1,%rdi
  800ddc:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800de0:	0f b6 07             	movzbl (%rdi),%eax
  800de3:	84 c0                	test   %al,%al
  800de5:	74 04                	je     800deb <strcmp+0x1e>
  800de7:	3a 06                	cmp    (%rsi),%al
  800de9:	74 ed                	je     800dd8 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800deb:	0f b6 c0             	movzbl %al,%eax
  800dee:	0f b6 16             	movzbl (%rsi),%edx
  800df1:	29 d0                	sub    %edx,%eax
}
  800df3:	c3                   	retq   

0000000000800df4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800df4:	48 85 d2             	test   %rdx,%rdx
  800df7:	74 2f                	je     800e28 <strncmp+0x34>
  800df9:	0f b6 07             	movzbl (%rdi),%eax
  800dfc:	84 c0                	test   %al,%al
  800dfe:	74 1f                	je     800e1f <strncmp+0x2b>
  800e00:	3a 06                	cmp    (%rsi),%al
  800e02:	75 1b                	jne    800e1f <strncmp+0x2b>
  800e04:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e07:	48 83 c7 01          	add    $0x1,%rdi
  800e0b:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e0f:	48 39 d7             	cmp    %rdx,%rdi
  800e12:	74 1a                	je     800e2e <strncmp+0x3a>
  800e14:	0f b6 07             	movzbl (%rdi),%eax
  800e17:	84 c0                	test   %al,%al
  800e19:	74 04                	je     800e1f <strncmp+0x2b>
  800e1b:	3a 06                	cmp    (%rsi),%al
  800e1d:	74 e8                	je     800e07 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e1f:	0f b6 07             	movzbl (%rdi),%eax
  800e22:	0f b6 16             	movzbl (%rsi),%edx
  800e25:	29 d0                	sub    %edx,%eax
}
  800e27:	c3                   	retq   
    return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2d:	c3                   	retq   
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	c3                   	retq   

0000000000800e34 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e34:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e36:	0f b6 07             	movzbl (%rdi),%eax
  800e39:	84 c0                	test   %al,%al
  800e3b:	74 1e                	je     800e5b <strchr+0x27>
    if (*s == c)
  800e3d:	40 38 c6             	cmp    %al,%sil
  800e40:	74 1f                	je     800e61 <strchr+0x2d>
  for (; *s; s++)
  800e42:	48 83 c7 01          	add    $0x1,%rdi
  800e46:	0f b6 07             	movzbl (%rdi),%eax
  800e49:	84 c0                	test   %al,%al
  800e4b:	74 08                	je     800e55 <strchr+0x21>
    if (*s == c)
  800e4d:	38 d0                	cmp    %dl,%al
  800e4f:	75 f1                	jne    800e42 <strchr+0xe>
  for (; *s; s++)
  800e51:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e54:	c3                   	retq   
  return 0;
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	c3                   	retq   
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	c3                   	retq   
    if (*s == c)
  800e61:	48 89 f8             	mov    %rdi,%rax
  800e64:	c3                   	retq   

0000000000800e65 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e65:	48 89 f8             	mov    %rdi,%rax
  800e68:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e6a:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e6d:	40 38 f2             	cmp    %sil,%dl
  800e70:	74 13                	je     800e85 <strfind+0x20>
  800e72:	84 d2                	test   %dl,%dl
  800e74:	74 0f                	je     800e85 <strfind+0x20>
  for (; *s; s++)
  800e76:	48 83 c0 01          	add    $0x1,%rax
  800e7a:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e7d:	38 ca                	cmp    %cl,%dl
  800e7f:	74 04                	je     800e85 <strfind+0x20>
  800e81:	84 d2                	test   %dl,%dl
  800e83:	75 f1                	jne    800e76 <strfind+0x11>
      break;
  return (char *)s;
}
  800e85:	c3                   	retq   

0000000000800e86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e86:	48 85 d2             	test   %rdx,%rdx
  800e89:	74 3a                	je     800ec5 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e8b:	48 89 f8             	mov    %rdi,%rax
  800e8e:	48 09 d0             	or     %rdx,%rax
  800e91:	a8 03                	test   $0x3,%al
  800e93:	75 28                	jne    800ebd <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e95:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	c1 e0 08             	shl    $0x8,%eax
  800e9e:	89 f1                	mov    %esi,%ecx
  800ea0:	c1 e1 18             	shl    $0x18,%ecx
  800ea3:	41 89 f0             	mov    %esi,%r8d
  800ea6:	41 c1 e0 10          	shl    $0x10,%r8d
  800eaa:	44 09 c1             	or     %r8d,%ecx
  800ead:	09 ce                	or     %ecx,%esi
  800eaf:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800eb1:	48 c1 ea 02          	shr    $0x2,%rdx
  800eb5:	48 89 d1             	mov    %rdx,%rcx
  800eb8:	fc                   	cld    
  800eb9:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ebb:	eb 08                	jmp    800ec5 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ebd:	89 f0                	mov    %esi,%eax
  800ebf:	48 89 d1             	mov    %rdx,%rcx
  800ec2:	fc                   	cld    
  800ec3:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ec5:	48 89 f8             	mov    %rdi,%rax
  800ec8:	c3                   	retq   

0000000000800ec9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ec9:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ecc:	48 39 fe             	cmp    %rdi,%rsi
  800ecf:	73 40                	jae    800f11 <memmove+0x48>
  800ed1:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ed5:	48 39 f9             	cmp    %rdi,%rcx
  800ed8:	76 37                	jbe    800f11 <memmove+0x48>
    s += n;
    d += n;
  800eda:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ede:	48 89 fe             	mov    %rdi,%rsi
  800ee1:	48 09 d6             	or     %rdx,%rsi
  800ee4:	48 09 ce             	or     %rcx,%rsi
  800ee7:	40 f6 c6 03          	test   $0x3,%sil
  800eeb:	75 14                	jne    800f01 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800eed:	48 83 ef 04          	sub    $0x4,%rdi
  800ef1:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ef5:	48 c1 ea 02          	shr    $0x2,%rdx
  800ef9:	48 89 d1             	mov    %rdx,%rcx
  800efc:	fd                   	std    
  800efd:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800eff:	eb 0e                	jmp    800f0f <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f01:	48 83 ef 01          	sub    $0x1,%rdi
  800f05:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f09:	48 89 d1             	mov    %rdx,%rcx
  800f0c:	fd                   	std    
  800f0d:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f0f:	fc                   	cld    
  800f10:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f11:	48 89 c1             	mov    %rax,%rcx
  800f14:	48 09 d1             	or     %rdx,%rcx
  800f17:	48 09 f1             	or     %rsi,%rcx
  800f1a:	f6 c1 03             	test   $0x3,%cl
  800f1d:	75 0e                	jne    800f2d <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f1f:	48 c1 ea 02          	shr    $0x2,%rdx
  800f23:	48 89 d1             	mov    %rdx,%rcx
  800f26:	48 89 c7             	mov    %rax,%rdi
  800f29:	fc                   	cld    
  800f2a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f2c:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f2d:	48 89 c7             	mov    %rax,%rdi
  800f30:	48 89 d1             	mov    %rdx,%rcx
  800f33:	fc                   	cld    
  800f34:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f36:	c3                   	retq   

0000000000800f37 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f37:	55                   	push   %rbp
  800f38:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f3b:	48 b8 c9 0e 80 00 00 	movabs $0x800ec9,%rax
  800f42:	00 00 00 
  800f45:	ff d0                	callq  *%rax
}
  800f47:	5d                   	pop    %rbp
  800f48:	c3                   	retq   

0000000000800f49 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f49:	55                   	push   %rbp
  800f4a:	48 89 e5             	mov    %rsp,%rbp
  800f4d:	41 57                	push   %r15
  800f4f:	41 56                	push   %r14
  800f51:	41 55                	push   %r13
  800f53:	41 54                	push   %r12
  800f55:	53                   	push   %rbx
  800f56:	48 83 ec 08          	sub    $0x8,%rsp
  800f5a:	49 89 fe             	mov    %rdi,%r14
  800f5d:	49 89 f7             	mov    %rsi,%r15
  800f60:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f63:	48 89 f7             	mov    %rsi,%rdi
  800f66:	48 b8 be 0c 80 00 00 	movabs $0x800cbe,%rax
  800f6d:	00 00 00 
  800f70:	ff d0                	callq  *%rax
  800f72:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f75:	4c 89 ee             	mov    %r13,%rsi
  800f78:	4c 89 f7             	mov    %r14,%rdi
  800f7b:	48 b8 e0 0c 80 00 00 	movabs $0x800ce0,%rax
  800f82:	00 00 00 
  800f85:	ff d0                	callq  *%rax
  800f87:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f8a:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f8e:	4d 39 e5             	cmp    %r12,%r13
  800f91:	74 26                	je     800fb9 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f93:	4c 89 e8             	mov    %r13,%rax
  800f96:	4c 29 e0             	sub    %r12,%rax
  800f99:	48 39 d8             	cmp    %rbx,%rax
  800f9c:	76 2a                	jbe    800fc8 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f9e:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fa2:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fa6:	4c 89 fe             	mov    %r15,%rsi
  800fa9:	48 b8 37 0f 80 00 00 	movabs $0x800f37,%rax
  800fb0:	00 00 00 
  800fb3:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fb5:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fb9:	48 83 c4 08          	add    $0x8,%rsp
  800fbd:	5b                   	pop    %rbx
  800fbe:	41 5c                	pop    %r12
  800fc0:	41 5d                	pop    %r13
  800fc2:	41 5e                	pop    %r14
  800fc4:	41 5f                	pop    %r15
  800fc6:	5d                   	pop    %rbp
  800fc7:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fc8:	49 83 ed 01          	sub    $0x1,%r13
  800fcc:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fd0:	4c 89 ea             	mov    %r13,%rdx
  800fd3:	4c 89 fe             	mov    %r15,%rsi
  800fd6:	48 b8 37 0f 80 00 00 	movabs $0x800f37,%rax
  800fdd:	00 00 00 
  800fe0:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fe2:	4d 01 ee             	add    %r13,%r14
  800fe5:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fea:	eb c9                	jmp    800fb5 <strlcat+0x6c>

0000000000800fec <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fec:	48 85 d2             	test   %rdx,%rdx
  800fef:	74 3a                	je     80102b <memcmp+0x3f>
    if (*s1 != *s2)
  800ff1:	0f b6 0f             	movzbl (%rdi),%ecx
  800ff4:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ff8:	44 38 c1             	cmp    %r8b,%cl
  800ffb:	75 1d                	jne    80101a <memcmp+0x2e>
  800ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801002:	48 39 d0             	cmp    %rdx,%rax
  801005:	74 1e                	je     801025 <memcmp+0x39>
    if (*s1 != *s2)
  801007:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80100b:	48 83 c0 01          	add    $0x1,%rax
  80100f:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801015:	44 38 c1             	cmp    %r8b,%cl
  801018:	74 e8                	je     801002 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80101a:	0f b6 c1             	movzbl %cl,%eax
  80101d:	45 0f b6 c0          	movzbl %r8b,%r8d
  801021:	44 29 c0             	sub    %r8d,%eax
  801024:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801025:	b8 00 00 00 00       	mov    $0x0,%eax
  80102a:	c3                   	retq   
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801030:	c3                   	retq   

0000000000801031 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801031:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801035:	48 39 c7             	cmp    %rax,%rdi
  801038:	73 19                	jae    801053 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80103a:	89 f2                	mov    %esi,%edx
  80103c:	40 38 37             	cmp    %sil,(%rdi)
  80103f:	74 16                	je     801057 <memfind+0x26>
  for (; s < ends; s++)
  801041:	48 83 c7 01          	add    $0x1,%rdi
  801045:	48 39 f8             	cmp    %rdi,%rax
  801048:	74 08                	je     801052 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80104a:	38 17                	cmp    %dl,(%rdi)
  80104c:	75 f3                	jne    801041 <memfind+0x10>
  for (; s < ends; s++)
  80104e:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801051:	c3                   	retq   
  801052:	c3                   	retq   
  for (; s < ends; s++)
  801053:	48 89 f8             	mov    %rdi,%rax
  801056:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801057:	48 89 f8             	mov    %rdi,%rax
  80105a:	c3                   	retq   

000000000080105b <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80105b:	0f b6 07             	movzbl (%rdi),%eax
  80105e:	3c 20                	cmp    $0x20,%al
  801060:	74 04                	je     801066 <strtol+0xb>
  801062:	3c 09                	cmp    $0x9,%al
  801064:	75 0f                	jne    801075 <strtol+0x1a>
    s++;
  801066:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80106a:	0f b6 07             	movzbl (%rdi),%eax
  80106d:	3c 20                	cmp    $0x20,%al
  80106f:	74 f5                	je     801066 <strtol+0xb>
  801071:	3c 09                	cmp    $0x9,%al
  801073:	74 f1                	je     801066 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801075:	3c 2b                	cmp    $0x2b,%al
  801077:	74 2b                	je     8010a4 <strtol+0x49>
  int neg  = 0;
  801079:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80107f:	3c 2d                	cmp    $0x2d,%al
  801081:	74 2d                	je     8010b0 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801083:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801089:	75 0f                	jne    80109a <strtol+0x3f>
  80108b:	80 3f 30             	cmpb   $0x30,(%rdi)
  80108e:	74 2c                	je     8010bc <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801090:	85 d2                	test   %edx,%edx
  801092:	b8 0a 00 00 00       	mov    $0xa,%eax
  801097:	0f 44 d0             	cmove  %eax,%edx
  80109a:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80109f:	4c 63 d2             	movslq %edx,%r10
  8010a2:	eb 5c                	jmp    801100 <strtol+0xa5>
    s++;
  8010a4:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010a8:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010ae:	eb d3                	jmp    801083 <strtol+0x28>
    s++, neg = 1;
  8010b0:	48 83 c7 01          	add    $0x1,%rdi
  8010b4:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010ba:	eb c7                	jmp    801083 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010bc:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010c0:	74 0f                	je     8010d1 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010c2:	85 d2                	test   %edx,%edx
  8010c4:	75 d4                	jne    80109a <strtol+0x3f>
    s++, base = 8;
  8010c6:	48 83 c7 01          	add    $0x1,%rdi
  8010ca:	ba 08 00 00 00       	mov    $0x8,%edx
  8010cf:	eb c9                	jmp    80109a <strtol+0x3f>
    s += 2, base = 16;
  8010d1:	48 83 c7 02          	add    $0x2,%rdi
  8010d5:	ba 10 00 00 00       	mov    $0x10,%edx
  8010da:	eb be                	jmp    80109a <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010dc:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010e0:	41 80 f8 19          	cmp    $0x19,%r8b
  8010e4:	77 2f                	ja     801115 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010e6:	44 0f be c1          	movsbl %cl,%r8d
  8010ea:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010ee:	39 d1                	cmp    %edx,%ecx
  8010f0:	7d 37                	jge    801129 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010f2:	48 83 c7 01          	add    $0x1,%rdi
  8010f6:	49 0f af c2          	imul   %r10,%rax
  8010fa:	48 63 c9             	movslq %ecx,%rcx
  8010fd:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801100:	0f b6 0f             	movzbl (%rdi),%ecx
  801103:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801107:	41 80 f8 09          	cmp    $0x9,%r8b
  80110b:	77 cf                	ja     8010dc <strtol+0x81>
      dig = *s - '0';
  80110d:	0f be c9             	movsbl %cl,%ecx
  801110:	83 e9 30             	sub    $0x30,%ecx
  801113:	eb d9                	jmp    8010ee <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801115:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801119:	41 80 f8 19          	cmp    $0x19,%r8b
  80111d:	77 0a                	ja     801129 <strtol+0xce>
      dig = *s - 'A' + 10;
  80111f:	44 0f be c1          	movsbl %cl,%r8d
  801123:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801127:	eb c5                	jmp    8010ee <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801129:	48 85 f6             	test   %rsi,%rsi
  80112c:	74 03                	je     801131 <strtol+0xd6>
    *endptr = (char *)s;
  80112e:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801131:	48 89 c2             	mov    %rax,%rdx
  801134:	48 f7 da             	neg    %rdx
  801137:	45 85 c9             	test   %r9d,%r9d
  80113a:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80113e:	c3                   	retq   
  80113f:	90                   	nop
