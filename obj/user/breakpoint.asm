
obj/user/breakpoint:     file format elf64-x86-64


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
  800023:	e8 04 00 00 00       	callq  80002c <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  asm volatile("int $3");
  80002a:	cc                   	int3   
}
  80002b:	c3                   	retq   

000000000080002c <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80002c:	55                   	push   %rbp
  80002d:	48 89 e5             	mov    %rsp,%rbp
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	41 89 fd             	mov    %edi,%r13d
  80003a:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80003d:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800044:	00 00 00 
  800047:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80004e:	00 00 00 
  800051:	48 39 c2             	cmp    %rax,%rdx
  800054:	73 23                	jae    800079 <libmain+0x4d>
  800056:	48 89 d3             	mov    %rdx,%rbx
  800059:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80005d:	48 29 d0             	sub    %rdx,%rax
  800060:	48 c1 e8 03          	shr    $0x3,%rax
  800064:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
  80006e:	ff 13                	callq  *(%rbx)
    ctor++;
  800070:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800074:	4c 39 e3             	cmp    %r12,%rbx
  800077:	75 f0                	jne    800069 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  800079:	48 b8 9b 01 80 00 00 	movabs $0x80019b,%rax
  800080:	00 00 00 
  800083:	ff d0                	callq  *%rax
  800085:	83 e0 1f             	and    $0x1f,%eax
  800088:	48 89 c2             	mov    %rax,%rdx
  80008b:	48 c1 e2 05          	shl    $0x5,%rdx
  80008f:	48 29 c2             	sub    %rax,%rdx
  800092:	48 89 d0             	mov    %rdx,%rax
  800095:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80009c:	00 00 00 
  80009f:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000a3:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000aa:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000ad:	45 85 ed             	test   %r13d,%r13d
  8000b0:	7e 0d                	jle    8000bf <libmain+0x93>
    binaryname = argv[0];
  8000b2:	49 8b 06             	mov    (%r14),%rax
  8000b5:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000bc:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000bf:	4c 89 f6             	mov    %r14,%rsi
  8000c2:	44 89 ef             	mov    %r13d,%edi
  8000c5:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000cc:	00 00 00 
  8000cf:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000d1:	48 b8 e6 00 80 00 00 	movabs $0x8000e6,%rax
  8000d8:	00 00 00 
  8000db:	ff d0                	callq  *%rax
#endif
}
  8000dd:	5b                   	pop    %rbx
  8000de:	41 5c                	pop    %r12
  8000e0:	41 5d                	pop    %r13
  8000e2:	41 5e                	pop    %r14
  8000e4:	5d                   	pop    %rbp
  8000e5:	c3                   	retq   

00000000008000e6 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000e6:	55                   	push   %rbp
  8000e7:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8000ef:	48 b8 3b 01 80 00 00 	movabs $0x80013b,%rax
  8000f6:	00 00 00 
  8000f9:	ff d0                	callq  *%rax
}
  8000fb:	5d                   	pop    %rbp
  8000fc:	c3                   	retq   

00000000008000fd <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000fd:	55                   	push   %rbp
  8000fe:	48 89 e5             	mov    %rsp,%rbp
  800101:	53                   	push   %rbx
  800102:	48 89 fa             	mov    %rdi,%rdx
  800105:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	48 89 c3             	mov    %rax,%rbx
  800110:	48 89 c7             	mov    %rax,%rdi
  800113:	48 89 c6             	mov    %rax,%rsi
  800116:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800118:	5b                   	pop    %rbx
  800119:	5d                   	pop    %rbp
  80011a:	c3                   	retq   

000000000080011b <sys_cgetc>:

int
sys_cgetc(void) {
  80011b:	55                   	push   %rbp
  80011c:	48 89 e5             	mov    %rsp,%rbp
  80011f:	53                   	push   %rbx
  asm volatile("int %1\n"
  800120:	b9 00 00 00 00       	mov    $0x0,%ecx
  800125:	b8 01 00 00 00       	mov    $0x1,%eax
  80012a:	48 89 ca             	mov    %rcx,%rdx
  80012d:	48 89 cb             	mov    %rcx,%rbx
  800130:	48 89 cf             	mov    %rcx,%rdi
  800133:	48 89 ce             	mov    %rcx,%rsi
  800136:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %rbx
  800139:	5d                   	pop    %rbp
  80013a:	c3                   	retq   

000000000080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80013b:	55                   	push   %rbp
  80013c:	48 89 e5             	mov    %rsp,%rbp
  80013f:	53                   	push   %rbx
  800140:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800144:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800147:	be 00 00 00 00       	mov    $0x0,%esi
  80014c:	b8 03 00 00 00       	mov    $0x3,%eax
  800151:	48 89 f1             	mov    %rsi,%rcx
  800154:	48 89 f3             	mov    %rsi,%rbx
  800157:	48 89 f7             	mov    %rsi,%rdi
  80015a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80015c:	48 85 c0             	test   %rax,%rax
  80015f:	7f 07                	jg     800168 <sys_env_destroy+0x2d>
}
  800161:	48 83 c4 08          	add    $0x8,%rsp
  800165:	5b                   	pop    %rbx
  800166:	5d                   	pop    %rbp
  800167:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800168:	49 89 c0             	mov    %rax,%r8
  80016b:	b9 03 00 00 00       	mov    $0x3,%ecx
  800170:	48 ba 70 11 80 00 00 	movabs $0x801170,%rdx
  800177:	00 00 00 
  80017a:	be 22 00 00 00       	mov    $0x22,%esi
  80017f:	48 bf 8f 11 80 00 00 	movabs $0x80118f,%rdi
  800186:	00 00 00 
  800189:	b8 00 00 00 00       	mov    $0x0,%eax
  80018e:	49 b9 bb 01 80 00 00 	movabs $0x8001bb,%r9
  800195:	00 00 00 
  800198:	41 ff d1             	callq  *%r9

000000000080019b <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80019b:	55                   	push   %rbp
  80019c:	48 89 e5             	mov    %rsp,%rbp
  80019f:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8001aa:	48 89 ca             	mov    %rcx,%rdx
  8001ad:	48 89 cb             	mov    %rcx,%rbx
  8001b0:	48 89 cf             	mov    %rcx,%rdi
  8001b3:	48 89 ce             	mov    %rcx,%rsi
  8001b6:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001b8:	5b                   	pop    %rbx
  8001b9:	5d                   	pop    %rbp
  8001ba:	c3                   	retq   

00000000008001bb <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001bb:	55                   	push   %rbp
  8001bc:	48 89 e5             	mov    %rsp,%rbp
  8001bf:	41 56                	push   %r14
  8001c1:	41 55                	push   %r13
  8001c3:	41 54                	push   %r12
  8001c5:	53                   	push   %rbx
  8001c6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001cd:	49 89 fd             	mov    %rdi,%r13
  8001d0:	41 89 f6             	mov    %esi,%r14d
  8001d3:	49 89 d4             	mov    %rdx,%r12
  8001d6:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001dd:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001e4:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001eb:	84 c0                	test   %al,%al
  8001ed:	74 26                	je     800215 <_panic+0x5a>
  8001ef:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001f6:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001fd:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800201:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800205:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800209:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80020d:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800211:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800215:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80021c:	00 00 00 
  80021f:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800226:	00 00 00 
  800229:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80022d:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800234:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80023b:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800242:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800249:	00 00 00 
  80024c:	48 8b 18             	mov    (%rax),%rbx
  80024f:	48 b8 9b 01 80 00 00 	movabs $0x80019b,%rax
  800256:	00 00 00 
  800259:	ff d0                	callq  *%rax
  80025b:	45 89 f0             	mov    %r14d,%r8d
  80025e:	4c 89 e9             	mov    %r13,%rcx
  800261:	48 89 da             	mov    %rbx,%rdx
  800264:	89 c6                	mov    %eax,%esi
  800266:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  80026d:	00 00 00 
  800270:	b8 00 00 00 00       	mov    $0x0,%eax
  800275:	48 bb 5d 03 80 00 00 	movabs $0x80035d,%rbx
  80027c:	00 00 00 
  80027f:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800281:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800288:	4c 89 e7             	mov    %r12,%rdi
  80028b:	48 b8 f5 02 80 00 00 	movabs $0x8002f5,%rax
  800292:	00 00 00 
  800295:	ff d0                	callq  *%rax
  cprintf("\n");
  800297:	48 bf c8 11 80 00 00 	movabs $0x8011c8,%rdi
  80029e:	00 00 00 
  8002a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a6:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002a8:	cc                   	int3   
  while (1)
  8002a9:	eb fd                	jmp    8002a8 <_panic+0xed>

00000000008002ab <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002ab:	55                   	push   %rbp
  8002ac:	48 89 e5             	mov    %rsp,%rbp
  8002af:	53                   	push   %rbx
  8002b0:	48 83 ec 08          	sub    $0x8,%rsp
  8002b4:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002b7:	8b 06                	mov    (%rsi),%eax
  8002b9:	8d 50 01             	lea    0x1(%rax),%edx
  8002bc:	89 16                	mov    %edx,(%rsi)
  8002be:	48 98                	cltq   
  8002c0:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002c5:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002cb:	74 0b                	je     8002d8 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002cd:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002d1:	48 83 c4 08          	add    $0x8,%rsp
  8002d5:	5b                   	pop    %rbx
  8002d6:	5d                   	pop    %rbp
  8002d7:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002d8:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002dc:	be ff 00 00 00       	mov    $0xff,%esi
  8002e1:	48 b8 fd 00 80 00 00 	movabs $0x8000fd,%rax
  8002e8:	00 00 00 
  8002eb:	ff d0                	callq  *%rax
    b->idx = 0;
  8002ed:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002f3:	eb d8                	jmp    8002cd <putch+0x22>

00000000008002f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002f5:	55                   	push   %rbp
  8002f6:	48 89 e5             	mov    %rsp,%rbp
  8002f9:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800300:	48 89 fa             	mov    %rdi,%rdx
  800303:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800306:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80030d:	00 00 00 
  b.cnt = 0;
  800310:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800317:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80031a:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800321:	48 bf ab 02 80 00 00 	movabs $0x8002ab,%rdi
  800328:	00 00 00 
  80032b:	48 b8 1b 05 80 00 00 	movabs $0x80051b,%rax
  800332:	00 00 00 
  800335:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800337:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80033e:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800345:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800349:	48 b8 fd 00 80 00 00 	movabs $0x8000fd,%rax
  800350:	00 00 00 
  800353:	ff d0                	callq  *%rax

  return b.cnt;
}
  800355:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80035b:	c9                   	leaveq 
  80035c:	c3                   	retq   

000000000080035d <cprintf>:

int
cprintf(const char *fmt, ...) {
  80035d:	55                   	push   %rbp
  80035e:	48 89 e5             	mov    %rsp,%rbp
  800361:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800368:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80036f:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800376:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80037d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800384:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80038b:	84 c0                	test   %al,%al
  80038d:	74 20                	je     8003af <cprintf+0x52>
  80038f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800393:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800397:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80039b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80039f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003a3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003a7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003ab:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003af:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003b6:	00 00 00 
  8003b9:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003c0:	00 00 00 
  8003c3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003c7:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003ce:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003d5:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003dc:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003e3:	48 b8 f5 02 80 00 00 	movabs $0x8002f5,%rax
  8003ea:	00 00 00 
  8003ed:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003ef:	c9                   	leaveq 
  8003f0:	c3                   	retq   

00000000008003f1 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003f1:	55                   	push   %rbp
  8003f2:	48 89 e5             	mov    %rsp,%rbp
  8003f5:	41 57                	push   %r15
  8003f7:	41 56                	push   %r14
  8003f9:	41 55                	push   %r13
  8003fb:	41 54                	push   %r12
  8003fd:	53                   	push   %rbx
  8003fe:	48 83 ec 18          	sub    $0x18,%rsp
  800402:	49 89 fc             	mov    %rdi,%r12
  800405:	49 89 f5             	mov    %rsi,%r13
  800408:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80040c:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80040f:	41 89 cf             	mov    %ecx,%r15d
  800412:	49 39 d7             	cmp    %rdx,%r15
  800415:	76 45                	jbe    80045c <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800417:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80041b:	85 db                	test   %ebx,%ebx
  80041d:	7e 0e                	jle    80042d <printnum+0x3c>
      putch(padc, putdat);
  80041f:	4c 89 ee             	mov    %r13,%rsi
  800422:	44 89 f7             	mov    %r14d,%edi
  800425:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800428:	83 eb 01             	sub    $0x1,%ebx
  80042b:	75 f2                	jne    80041f <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80042d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	49 f7 f7             	div    %r15
  800439:	48 b8 ca 11 80 00 00 	movabs $0x8011ca,%rax
  800440:	00 00 00 
  800443:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800447:	4c 89 ee             	mov    %r13,%rsi
  80044a:	41 ff d4             	callq  *%r12
}
  80044d:	48 83 c4 18          	add    $0x18,%rsp
  800451:	5b                   	pop    %rbx
  800452:	41 5c                	pop    %r12
  800454:	41 5d                	pop    %r13
  800456:	41 5e                	pop    %r14
  800458:	41 5f                	pop    %r15
  80045a:	5d                   	pop    %rbp
  80045b:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80045c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800460:	ba 00 00 00 00       	mov    $0x0,%edx
  800465:	49 f7 f7             	div    %r15
  800468:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80046c:	48 89 c2             	mov    %rax,%rdx
  80046f:	48 b8 f1 03 80 00 00 	movabs $0x8003f1,%rax
  800476:	00 00 00 
  800479:	ff d0                	callq  *%rax
  80047b:	eb b0                	jmp    80042d <printnum+0x3c>

000000000080047d <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80047d:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800481:	48 8b 06             	mov    (%rsi),%rax
  800484:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800488:	73 0a                	jae    800494 <sprintputch+0x17>
    *b->buf++ = ch;
  80048a:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80048e:	48 89 16             	mov    %rdx,(%rsi)
  800491:	40 88 38             	mov    %dil,(%rax)
}
  800494:	c3                   	retq   

0000000000800495 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800495:	55                   	push   %rbp
  800496:	48 89 e5             	mov    %rsp,%rbp
  800499:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004a0:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004a7:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004ae:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004b5:	84 c0                	test   %al,%al
  8004b7:	74 20                	je     8004d9 <printfmt+0x44>
  8004b9:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004bd:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004c1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004c5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004c9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004cd:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004d1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004d5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004d9:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004e0:	00 00 00 
  8004e3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004ea:	00 00 00 
  8004ed:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004f1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004f8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004ff:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800506:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80050d:	48 b8 1b 05 80 00 00 	movabs $0x80051b,%rax
  800514:	00 00 00 
  800517:	ff d0                	callq  *%rax
}
  800519:	c9                   	leaveq 
  80051a:	c3                   	retq   

000000000080051b <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80051b:	55                   	push   %rbp
  80051c:	48 89 e5             	mov    %rsp,%rbp
  80051f:	41 57                	push   %r15
  800521:	41 56                	push   %r14
  800523:	41 55                	push   %r13
  800525:	41 54                	push   %r12
  800527:	53                   	push   %rbx
  800528:	48 83 ec 48          	sub    $0x48,%rsp
  80052c:	49 89 fd             	mov    %rdi,%r13
  80052f:	49 89 f7             	mov    %rsi,%r15
  800532:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800535:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800539:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80053d:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800541:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800545:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800549:	41 0f b6 3e          	movzbl (%r14),%edi
  80054d:	83 ff 25             	cmp    $0x25,%edi
  800550:	74 18                	je     80056a <vprintfmt+0x4f>
      if (ch == '\0')
  800552:	85 ff                	test   %edi,%edi
  800554:	0f 84 8c 06 00 00    	je     800be6 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80055a:	4c 89 fe             	mov    %r15,%rsi
  80055d:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800560:	49 89 de             	mov    %rbx,%r14
  800563:	eb e0                	jmp    800545 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800565:	49 89 de             	mov    %rbx,%r14
  800568:	eb db                	jmp    800545 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80056a:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80056e:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800572:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800579:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80057f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800583:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800588:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80058e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800594:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800599:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80059e:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005a2:	0f b6 13             	movzbl (%rbx),%edx
  8005a5:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005a8:	3c 55                	cmp    $0x55,%al
  8005aa:	0f 87 8b 05 00 00    	ja     800b3b <vprintfmt+0x620>
  8005b0:	0f b6 c0             	movzbl %al,%eax
  8005b3:	49 bb 80 12 80 00 00 	movabs $0x801280,%r11
  8005ba:	00 00 00 
  8005bd:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005c1:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005c4:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005c8:	eb d4                	jmp    80059e <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005ca:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005cd:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005d1:	eb cb                	jmp    80059e <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005d3:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005d6:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005da:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005de:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005e1:	83 fa 09             	cmp    $0x9,%edx
  8005e4:	77 7e                	ja     800664 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005e6:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005ea:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005ee:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005f3:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005f7:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005fa:	83 fa 09             	cmp    $0x9,%edx
  8005fd:	76 e7                	jbe    8005e6 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005ff:	4c 89 f3             	mov    %r14,%rbx
  800602:	eb 19                	jmp    80061d <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800604:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800607:	83 f8 2f             	cmp    $0x2f,%eax
  80060a:	77 2a                	ja     800636 <vprintfmt+0x11b>
  80060c:	89 c2                	mov    %eax,%edx
  80060e:	4c 01 d2             	add    %r10,%rdx
  800611:	83 c0 08             	add    $0x8,%eax
  800614:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800617:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80061a:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80061d:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800621:	0f 89 77 ff ff ff    	jns    80059e <vprintfmt+0x83>
          width = precision, precision = -1;
  800627:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80062b:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800631:	e9 68 ff ff ff       	jmpq   80059e <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800636:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80063a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80063e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800642:	eb d3                	jmp    800617 <vprintfmt+0xfc>
        if (width < 0)
  800644:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800647:	85 c0                	test   %eax,%eax
  800649:	41 0f 48 c0          	cmovs  %r8d,%eax
  80064d:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800650:	4c 89 f3             	mov    %r14,%rbx
  800653:	e9 46 ff ff ff       	jmpq   80059e <vprintfmt+0x83>
  800658:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80065b:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80065f:	e9 3a ff ff ff       	jmpq   80059e <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800664:	4c 89 f3             	mov    %r14,%rbx
  800667:	eb b4                	jmp    80061d <vprintfmt+0x102>
        lflag++;
  800669:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80066c:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80066f:	e9 2a ff ff ff       	jmpq   80059e <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800674:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800677:	83 f8 2f             	cmp    $0x2f,%eax
  80067a:	77 19                	ja     800695 <vprintfmt+0x17a>
  80067c:	89 c2                	mov    %eax,%edx
  80067e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800682:	83 c0 08             	add    $0x8,%eax
  800685:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800688:	4c 89 fe             	mov    %r15,%rsi
  80068b:	8b 3a                	mov    (%rdx),%edi
  80068d:	41 ff d5             	callq  *%r13
        break;
  800690:	e9 b0 fe ff ff       	jmpq   800545 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800695:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800699:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80069d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006a1:	eb e5                	jmp    800688 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006a3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006a6:	83 f8 2f             	cmp    $0x2f,%eax
  8006a9:	77 5b                	ja     800706 <vprintfmt+0x1eb>
  8006ab:	89 c2                	mov    %eax,%edx
  8006ad:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006b1:	83 c0 08             	add    $0x8,%eax
  8006b4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006b7:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006b9:	89 c8                	mov    %ecx,%eax
  8006bb:	c1 f8 1f             	sar    $0x1f,%eax
  8006be:	31 c1                	xor    %eax,%ecx
  8006c0:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c2:	83 f9 09             	cmp    $0x9,%ecx
  8006c5:	7f 4d                	jg     800714 <vprintfmt+0x1f9>
  8006c7:	48 63 c1             	movslq %ecx,%rax
  8006ca:	48 ba 40 15 80 00 00 	movabs $0x801540,%rdx
  8006d1:	00 00 00 
  8006d4:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006d8:	48 85 c0             	test   %rax,%rax
  8006db:	74 37                	je     800714 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006dd:	48 89 c1             	mov    %rax,%rcx
  8006e0:	48 ba eb 11 80 00 00 	movabs $0x8011eb,%rdx
  8006e7:	00 00 00 
  8006ea:	4c 89 fe             	mov    %r15,%rsi
  8006ed:	4c 89 ef             	mov    %r13,%rdi
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	48 bb 95 04 80 00 00 	movabs $0x800495,%rbx
  8006fc:	00 00 00 
  8006ff:	ff d3                	callq  *%rbx
  800701:	e9 3f fe ff ff       	jmpq   800545 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800706:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80070a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80070e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800712:	eb a3                	jmp    8006b7 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800714:	48 ba e2 11 80 00 00 	movabs $0x8011e2,%rdx
  80071b:	00 00 00 
  80071e:	4c 89 fe             	mov    %r15,%rsi
  800721:	4c 89 ef             	mov    %r13,%rdi
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	48 bb 95 04 80 00 00 	movabs $0x800495,%rbx
  800730:	00 00 00 
  800733:	ff d3                	callq  *%rbx
  800735:	e9 0b fe ff ff       	jmpq   800545 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80073a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80073d:	83 f8 2f             	cmp    $0x2f,%eax
  800740:	77 4b                	ja     80078d <vprintfmt+0x272>
  800742:	89 c2                	mov    %eax,%edx
  800744:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800748:	83 c0 08             	add    $0x8,%eax
  80074b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80074e:	48 8b 02             	mov    (%rdx),%rax
  800751:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800755:	48 85 c0             	test   %rax,%rax
  800758:	0f 84 05 04 00 00    	je     800b63 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80075e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800762:	7e 06                	jle    80076a <vprintfmt+0x24f>
  800764:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800768:	75 31                	jne    80079b <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80076e:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800772:	0f b6 00             	movzbl (%rax),%eax
  800775:	0f be f8             	movsbl %al,%edi
  800778:	85 ff                	test   %edi,%edi
  80077a:	0f 84 c3 00 00 00    	je     800843 <vprintfmt+0x328>
  800780:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800784:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800788:	e9 85 00 00 00       	jmpq   800812 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80078d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800791:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800795:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800799:	eb b3                	jmp    80074e <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80079b:	49 63 f4             	movslq %r12d,%rsi
  80079e:	48 89 c7             	mov    %rax,%rdi
  8007a1:	48 b8 f2 0c 80 00 00 	movabs $0x800cf2,%rax
  8007a8:	00 00 00 
  8007ab:	ff d0                	callq  *%rax
  8007ad:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007b0:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007b3:	85 f6                	test   %esi,%esi
  8007b5:	7e 22                	jle    8007d9 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007b7:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007bb:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007bf:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007c3:	4c 89 fe             	mov    %r15,%rsi
  8007c6:	89 df                	mov    %ebx,%edi
  8007c8:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007cb:	41 83 ec 01          	sub    $0x1,%r12d
  8007cf:	75 f2                	jne    8007c3 <vprintfmt+0x2a8>
  8007d1:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007d5:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d9:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007dd:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007e1:	0f b6 00             	movzbl (%rax),%eax
  8007e4:	0f be f8             	movsbl %al,%edi
  8007e7:	85 ff                	test   %edi,%edi
  8007e9:	0f 84 56 fd ff ff    	je     800545 <vprintfmt+0x2a>
  8007ef:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007f3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007f7:	eb 19                	jmp    800812 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007f9:	4c 89 fe             	mov    %r15,%rsi
  8007fc:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ff:	41 83 ee 01          	sub    $0x1,%r14d
  800803:	48 83 c3 01          	add    $0x1,%rbx
  800807:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80080b:	0f be f8             	movsbl %al,%edi
  80080e:	85 ff                	test   %edi,%edi
  800810:	74 29                	je     80083b <vprintfmt+0x320>
  800812:	45 85 e4             	test   %r12d,%r12d
  800815:	78 06                	js     80081d <vprintfmt+0x302>
  800817:	41 83 ec 01          	sub    $0x1,%r12d
  80081b:	78 48                	js     800865 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80081d:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800821:	74 d6                	je     8007f9 <vprintfmt+0x2de>
  800823:	0f be c0             	movsbl %al,%eax
  800826:	83 e8 20             	sub    $0x20,%eax
  800829:	83 f8 5e             	cmp    $0x5e,%eax
  80082c:	76 cb                	jbe    8007f9 <vprintfmt+0x2de>
            putch('?', putdat);
  80082e:	4c 89 fe             	mov    %r15,%rsi
  800831:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800836:	41 ff d5             	callq  *%r13
  800839:	eb c4                	jmp    8007ff <vprintfmt+0x2e4>
  80083b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80083f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800843:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800846:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80084a:	0f 8e f5 fc ff ff    	jle    800545 <vprintfmt+0x2a>
          putch(' ', putdat);
  800850:	4c 89 fe             	mov    %r15,%rsi
  800853:	bf 20 00 00 00       	mov    $0x20,%edi
  800858:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80085b:	83 eb 01             	sub    $0x1,%ebx
  80085e:	75 f0                	jne    800850 <vprintfmt+0x335>
  800860:	e9 e0 fc ff ff       	jmpq   800545 <vprintfmt+0x2a>
  800865:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800869:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80086d:	eb d4                	jmp    800843 <vprintfmt+0x328>
  if (lflag >= 2)
  80086f:	83 f9 01             	cmp    $0x1,%ecx
  800872:	7f 1d                	jg     800891 <vprintfmt+0x376>
  else if (lflag)
  800874:	85 c9                	test   %ecx,%ecx
  800876:	74 5e                	je     8008d6 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800878:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80087b:	83 f8 2f             	cmp    $0x2f,%eax
  80087e:	77 48                	ja     8008c8 <vprintfmt+0x3ad>
  800880:	89 c2                	mov    %eax,%edx
  800882:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800886:	83 c0 08             	add    $0x8,%eax
  800889:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80088c:	48 8b 1a             	mov    (%rdx),%rbx
  80088f:	eb 17                	jmp    8008a8 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800891:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800894:	83 f8 2f             	cmp    $0x2f,%eax
  800897:	77 21                	ja     8008ba <vprintfmt+0x39f>
  800899:	89 c2                	mov    %eax,%edx
  80089b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80089f:	83 c0 08             	add    $0x8,%eax
  8008a2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a5:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008a8:	48 85 db             	test   %rbx,%rbx
  8008ab:	78 50                	js     8008fd <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008ad:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008b5:	e9 b4 01 00 00       	jmpq   800a6e <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008ba:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008be:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c6:	eb dd                	jmp    8008a5 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008c8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008cc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d4:	eb b6                	jmp    80088c <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008d6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d9:	83 f8 2f             	cmp    $0x2f,%eax
  8008dc:	77 11                	ja     8008ef <vprintfmt+0x3d4>
  8008de:	89 c2                	mov    %eax,%edx
  8008e0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e4:	83 c0 08             	add    $0x8,%eax
  8008e7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ea:	48 63 1a             	movslq (%rdx),%rbx
  8008ed:	eb b9                	jmp    8008a8 <vprintfmt+0x38d>
  8008ef:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008f3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008f7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008fb:	eb ed                	jmp    8008ea <vprintfmt+0x3cf>
          putch('-', putdat);
  8008fd:	4c 89 fe             	mov    %r15,%rsi
  800900:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800905:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800908:	48 89 da             	mov    %rbx,%rdx
  80090b:	48 f7 da             	neg    %rdx
        base = 10;
  80090e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800913:	e9 56 01 00 00       	jmpq   800a6e <vprintfmt+0x553>
  if (lflag >= 2)
  800918:	83 f9 01             	cmp    $0x1,%ecx
  80091b:	7f 25                	jg     800942 <vprintfmt+0x427>
  else if (lflag)
  80091d:	85 c9                	test   %ecx,%ecx
  80091f:	74 5e                	je     80097f <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800921:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800924:	83 f8 2f             	cmp    $0x2f,%eax
  800927:	77 48                	ja     800971 <vprintfmt+0x456>
  800929:	89 c2                	mov    %eax,%edx
  80092b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092f:	83 c0 08             	add    $0x8,%eax
  800932:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800935:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800938:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80093d:	e9 2c 01 00 00       	jmpq   800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800942:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800945:	83 f8 2f             	cmp    $0x2f,%eax
  800948:	77 19                	ja     800963 <vprintfmt+0x448>
  80094a:	89 c2                	mov    %eax,%edx
  80094c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800950:	83 c0 08             	add    $0x8,%eax
  800953:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800956:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800959:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80095e:	e9 0b 01 00 00       	jmpq   800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800963:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800967:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096f:	eb e5                	jmp    800956 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800971:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800975:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800979:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097d:	eb b6                	jmp    800935 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80097f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800982:	83 f8 2f             	cmp    $0x2f,%eax
  800985:	77 18                	ja     80099f <vprintfmt+0x484>
  800987:	89 c2                	mov    %eax,%edx
  800989:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80098d:	83 c0 08             	add    $0x8,%eax
  800990:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800993:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800995:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80099a:	e9 cf 00 00 00       	jmpq   800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80099f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ab:	eb e6                	jmp    800993 <vprintfmt+0x478>
  if (lflag >= 2)
  8009ad:	83 f9 01             	cmp    $0x1,%ecx
  8009b0:	7f 25                	jg     8009d7 <vprintfmt+0x4bc>
  else if (lflag)
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	74 5b                	je     800a11 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009b9:	83 f8 2f             	cmp    $0x2f,%eax
  8009bc:	77 45                	ja     800a03 <vprintfmt+0x4e8>
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c4:	83 c0 08             	add    $0x8,%eax
  8009c7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ca:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009cd:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009d2:	e9 97 00 00 00       	jmpq   800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009d7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009da:	83 f8 2f             	cmp    $0x2f,%eax
  8009dd:	77 16                	ja     8009f5 <vprintfmt+0x4da>
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e5:	83 c0 08             	add    $0x8,%eax
  8009e8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009eb:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009ee:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f3:	eb 79                	jmp    800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009fd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a01:	eb e8                	jmp    8009eb <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a03:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a07:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a0b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a0f:	eb b9                	jmp    8009ca <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a11:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a14:	83 f8 2f             	cmp    $0x2f,%eax
  800a17:	77 15                	ja     800a2e <vprintfmt+0x513>
  800a19:	89 c2                	mov    %eax,%edx
  800a1b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a1f:	83 c0 08             	add    $0x8,%eax
  800a22:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a25:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a27:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a2c:	eb 40                	jmp    800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a2e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a32:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a36:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a3a:	eb e9                	jmp    800a25 <vprintfmt+0x50a>
        putch('0', putdat);
  800a3c:	4c 89 fe             	mov    %r15,%rsi
  800a3f:	bf 30 00 00 00       	mov    $0x30,%edi
  800a44:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a47:	4c 89 fe             	mov    %r15,%rsi
  800a4a:	bf 78 00 00 00       	mov    $0x78,%edi
  800a4f:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a52:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a55:	83 f8 2f             	cmp    $0x2f,%eax
  800a58:	77 34                	ja     800a8e <vprintfmt+0x573>
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a60:	83 c0 08             	add    $0x8,%eax
  800a63:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a66:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a69:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a6e:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a73:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a77:	4c 89 fe             	mov    %r15,%rsi
  800a7a:	4c 89 ef             	mov    %r13,%rdi
  800a7d:	48 b8 f1 03 80 00 00 	movabs $0x8003f1,%rax
  800a84:	00 00 00 
  800a87:	ff d0                	callq  *%rax
        break;
  800a89:	e9 b7 fa ff ff       	jmpq   800545 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a8e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a92:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a96:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a9a:	eb ca                	jmp    800a66 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a9c:	83 f9 01             	cmp    $0x1,%ecx
  800a9f:	7f 22                	jg     800ac3 <vprintfmt+0x5a8>
  else if (lflag)
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 58                	je     800afd <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800aa5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aa8:	83 f8 2f             	cmp    $0x2f,%eax
  800aab:	77 42                	ja     800aef <vprintfmt+0x5d4>
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ab3:	83 c0 08             	add    $0x8,%eax
  800ab6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ab9:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800abc:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ac1:	eb ab                	jmp    800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ac3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ac6:	83 f8 2f             	cmp    $0x2f,%eax
  800ac9:	77 16                	ja     800ae1 <vprintfmt+0x5c6>
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad1:	83 c0 08             	add    $0x8,%eax
  800ad4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ad7:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ada:	b9 10 00 00 00       	mov    $0x10,%ecx
  800adf:	eb 8d                	jmp    800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ae1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ae5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ae9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aed:	eb e8                	jmp    800ad7 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800aef:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800af3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800afb:	eb bc                	jmp    800ab9 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800afd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b00:	83 f8 2f             	cmp    $0x2f,%eax
  800b03:	77 18                	ja     800b1d <vprintfmt+0x602>
  800b05:	89 c2                	mov    %eax,%edx
  800b07:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b0b:	83 c0 08             	add    $0x8,%eax
  800b0e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b11:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b13:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b18:	e9 51 ff ff ff       	jmpq   800a6e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b1d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b21:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b25:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b29:	eb e6                	jmp    800b11 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b2b:	4c 89 fe             	mov    %r15,%rsi
  800b2e:	bf 25 00 00 00       	mov    $0x25,%edi
  800b33:	41 ff d5             	callq  *%r13
        break;
  800b36:	e9 0a fa ff ff       	jmpq   800545 <vprintfmt+0x2a>
        putch('%', putdat);
  800b3b:	4c 89 fe             	mov    %r15,%rsi
  800b3e:	bf 25 00 00 00       	mov    $0x25,%edi
  800b43:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b46:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b4a:	0f 84 15 fa ff ff    	je     800565 <vprintfmt+0x4a>
  800b50:	49 89 de             	mov    %rbx,%r14
  800b53:	49 83 ee 01          	sub    $0x1,%r14
  800b57:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b5c:	75 f5                	jne    800b53 <vprintfmt+0x638>
  800b5e:	e9 e2 f9 ff ff       	jmpq   800545 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b63:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b67:	74 06                	je     800b6f <vprintfmt+0x654>
  800b69:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b6d:	7f 21                	jg     800b90 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b6f:	bf 28 00 00 00       	mov    $0x28,%edi
  800b74:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800b7b:	00 00 00 
  800b7e:	b8 28 00 00 00       	mov    $0x28,%eax
  800b83:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b87:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b8b:	e9 82 fc ff ff       	jmpq   800812 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b90:	49 63 f4             	movslq %r12d,%rsi
  800b93:	48 bf db 11 80 00 00 	movabs $0x8011db,%rdi
  800b9a:	00 00 00 
  800b9d:	48 b8 f2 0c 80 00 00 	movabs $0x800cf2,%rax
  800ba4:	00 00 00 
  800ba7:	ff d0                	callq  *%rax
  800ba9:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bac:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800baf:	48 be db 11 80 00 00 	movabs $0x8011db,%rsi
  800bb6:	00 00 00 
  800bb9:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	0f 8f f2 fb ff ff    	jg     8007b7 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc5:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800bcc:	00 00 00 
  800bcf:	b8 28 00 00 00       	mov    $0x28,%eax
  800bd4:	bf 28 00 00 00       	mov    $0x28,%edi
  800bd9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bdd:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800be1:	e9 2c fc ff ff       	jmpq   800812 <vprintfmt+0x2f7>
}
  800be6:	48 83 c4 48          	add    $0x48,%rsp
  800bea:	5b                   	pop    %rbx
  800beb:	41 5c                	pop    %r12
  800bed:	41 5d                	pop    %r13
  800bef:	41 5e                	pop    %r14
  800bf1:	41 5f                	pop    %r15
  800bf3:	5d                   	pop    %rbp
  800bf4:	c3                   	retq   

0000000000800bf5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bf5:	55                   	push   %rbp
  800bf6:	48 89 e5             	mov    %rsp,%rbp
  800bf9:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bfd:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c01:	48 63 c6             	movslq %esi,%rax
  800c04:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c09:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c0d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c14:	48 85 ff             	test   %rdi,%rdi
  800c17:	74 2a                	je     800c43 <vsnprintf+0x4e>
  800c19:	85 f6                	test   %esi,%esi
  800c1b:	7e 26                	jle    800c43 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c1d:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c21:	48 bf 7d 04 80 00 00 	movabs $0x80047d,%rdi
  800c28:	00 00 00 
  800c2b:	48 b8 1b 05 80 00 00 	movabs $0x80051b,%rax
  800c32:	00 00 00 
  800c35:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c37:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c3b:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c3e:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c41:	c9                   	leaveq 
  800c42:	c3                   	retq   
    return -E_INVAL;
  800c43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c48:	eb f7                	jmp    800c41 <vsnprintf+0x4c>

0000000000800c4a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c4a:	55                   	push   %rbp
  800c4b:	48 89 e5             	mov    %rsp,%rbp
  800c4e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c55:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c5c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c63:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c6a:	84 c0                	test   %al,%al
  800c6c:	74 20                	je     800c8e <snprintf+0x44>
  800c6e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c72:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c76:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c7a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c7e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c82:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c86:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c8a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c8e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c95:	00 00 00 
  800c98:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c9f:	00 00 00 
  800ca2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800ca6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cad:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cb4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cbb:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cc2:	48 b8 f5 0b 80 00 00 	movabs $0x800bf5,%rax
  800cc9:	00 00 00 
  800ccc:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cce:	c9                   	leaveq 
  800ccf:	c3                   	retq   

0000000000800cd0 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cd0:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cd3:	74 17                	je     800cec <strlen+0x1c>
  800cd5:	48 89 fa             	mov    %rdi,%rdx
  800cd8:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cdd:	29 f9                	sub    %edi,%ecx
    n++;
  800cdf:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800ce2:	48 83 c2 01          	add    $0x1,%rdx
  800ce6:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ce9:	75 f4                	jne    800cdf <strlen+0xf>
  800ceb:	c3                   	retq   
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cf1:	c3                   	retq   

0000000000800cf2 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf2:	48 85 f6             	test   %rsi,%rsi
  800cf5:	74 24                	je     800d1b <strnlen+0x29>
  800cf7:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cfa:	74 25                	je     800d21 <strnlen+0x2f>
  800cfc:	48 01 fe             	add    %rdi,%rsi
  800cff:	48 89 fa             	mov    %rdi,%rdx
  800d02:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d07:	29 f9                	sub    %edi,%ecx
    n++;
  800d09:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0c:	48 83 c2 01          	add    $0x1,%rdx
  800d10:	48 39 f2             	cmp    %rsi,%rdx
  800d13:	74 11                	je     800d26 <strnlen+0x34>
  800d15:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d18:	75 ef                	jne    800d09 <strnlen+0x17>
  800d1a:	c3                   	retq   
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	c3                   	retq   
  800d21:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d26:	c3                   	retq   

0000000000800d27 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d27:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d33:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d36:	48 83 c2 01          	add    $0x1,%rdx
  800d3a:	84 c9                	test   %cl,%cl
  800d3c:	75 f1                	jne    800d2f <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d3e:	c3                   	retq   

0000000000800d3f <strcat>:

char *
strcat(char *dst, const char *src) {
  800d3f:	55                   	push   %rbp
  800d40:	48 89 e5             	mov    %rsp,%rbp
  800d43:	41 54                	push   %r12
  800d45:	53                   	push   %rbx
  800d46:	48 89 fb             	mov    %rdi,%rbx
  800d49:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d4c:	48 b8 d0 0c 80 00 00 	movabs $0x800cd0,%rax
  800d53:	00 00 00 
  800d56:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d58:	48 63 f8             	movslq %eax,%rdi
  800d5b:	48 01 df             	add    %rbx,%rdi
  800d5e:	4c 89 e6             	mov    %r12,%rsi
  800d61:	48 b8 27 0d 80 00 00 	movabs $0x800d27,%rax
  800d68:	00 00 00 
  800d6b:	ff d0                	callq  *%rax
  return dst;
}
  800d6d:	48 89 d8             	mov    %rbx,%rax
  800d70:	5b                   	pop    %rbx
  800d71:	41 5c                	pop    %r12
  800d73:	5d                   	pop    %rbp
  800d74:	c3                   	retq   

0000000000800d75 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d75:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d78:	48 85 d2             	test   %rdx,%rdx
  800d7b:	74 1f                	je     800d9c <strncpy+0x27>
  800d7d:	48 01 fa             	add    %rdi,%rdx
  800d80:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d83:	48 83 c1 01          	add    $0x1,%rcx
  800d87:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d8b:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d8f:	41 80 f8 01          	cmp    $0x1,%r8b
  800d93:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d97:	48 39 ca             	cmp    %rcx,%rdx
  800d9a:	75 e7                	jne    800d83 <strncpy+0xe>
  }
  return ret;
}
  800d9c:	c3                   	retq   

0000000000800d9d <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d9d:	48 89 f8             	mov    %rdi,%rax
  800da0:	48 85 d2             	test   %rdx,%rdx
  800da3:	74 36                	je     800ddb <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800da5:	48 83 fa 01          	cmp    $0x1,%rdx
  800da9:	74 2d                	je     800dd8 <strlcpy+0x3b>
  800dab:	44 0f b6 06          	movzbl (%rsi),%r8d
  800daf:	45 84 c0             	test   %r8b,%r8b
  800db2:	74 24                	je     800dd8 <strlcpy+0x3b>
  800db4:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800db8:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dbd:	48 83 c0 01          	add    $0x1,%rax
  800dc1:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800dc5:	48 39 d1             	cmp    %rdx,%rcx
  800dc8:	74 0e                	je     800dd8 <strlcpy+0x3b>
  800dca:	48 83 c1 01          	add    $0x1,%rcx
  800dce:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dd3:	45 84 c0             	test   %r8b,%r8b
  800dd6:	75 e5                	jne    800dbd <strlcpy+0x20>
    *dst = '\0';
  800dd8:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800ddb:	48 29 f8             	sub    %rdi,%rax
}
  800dde:	c3                   	retq   

0000000000800ddf <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800ddf:	0f b6 07             	movzbl (%rdi),%eax
  800de2:	84 c0                	test   %al,%al
  800de4:	74 17                	je     800dfd <strcmp+0x1e>
  800de6:	3a 06                	cmp    (%rsi),%al
  800de8:	75 13                	jne    800dfd <strcmp+0x1e>
    p++, q++;
  800dea:	48 83 c7 01          	add    $0x1,%rdi
  800dee:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800df2:	0f b6 07             	movzbl (%rdi),%eax
  800df5:	84 c0                	test   %al,%al
  800df7:	74 04                	je     800dfd <strcmp+0x1e>
  800df9:	3a 06                	cmp    (%rsi),%al
  800dfb:	74 ed                	je     800dea <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dfd:	0f b6 c0             	movzbl %al,%eax
  800e00:	0f b6 16             	movzbl (%rsi),%edx
  800e03:	29 d0                	sub    %edx,%eax
}
  800e05:	c3                   	retq   

0000000000800e06 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e06:	48 85 d2             	test   %rdx,%rdx
  800e09:	74 2f                	je     800e3a <strncmp+0x34>
  800e0b:	0f b6 07             	movzbl (%rdi),%eax
  800e0e:	84 c0                	test   %al,%al
  800e10:	74 1f                	je     800e31 <strncmp+0x2b>
  800e12:	3a 06                	cmp    (%rsi),%al
  800e14:	75 1b                	jne    800e31 <strncmp+0x2b>
  800e16:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e19:	48 83 c7 01          	add    $0x1,%rdi
  800e1d:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e21:	48 39 d7             	cmp    %rdx,%rdi
  800e24:	74 1a                	je     800e40 <strncmp+0x3a>
  800e26:	0f b6 07             	movzbl (%rdi),%eax
  800e29:	84 c0                	test   %al,%al
  800e2b:	74 04                	je     800e31 <strncmp+0x2b>
  800e2d:	3a 06                	cmp    (%rsi),%al
  800e2f:	74 e8                	je     800e19 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e31:	0f b6 07             	movzbl (%rdi),%eax
  800e34:	0f b6 16             	movzbl (%rsi),%edx
  800e37:	29 d0                	sub    %edx,%eax
}
  800e39:	c3                   	retq   
    return 0;
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3f:	c3                   	retq   
  800e40:	b8 00 00 00 00       	mov    $0x0,%eax
  800e45:	c3                   	retq   

0000000000800e46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e46:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e48:	0f b6 07             	movzbl (%rdi),%eax
  800e4b:	84 c0                	test   %al,%al
  800e4d:	74 1e                	je     800e6d <strchr+0x27>
    if (*s == c)
  800e4f:	40 38 c6             	cmp    %al,%sil
  800e52:	74 1f                	je     800e73 <strchr+0x2d>
  for (; *s; s++)
  800e54:	48 83 c7 01          	add    $0x1,%rdi
  800e58:	0f b6 07             	movzbl (%rdi),%eax
  800e5b:	84 c0                	test   %al,%al
  800e5d:	74 08                	je     800e67 <strchr+0x21>
    if (*s == c)
  800e5f:	38 d0                	cmp    %dl,%al
  800e61:	75 f1                	jne    800e54 <strchr+0xe>
  for (; *s; s++)
  800e63:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e66:	c3                   	retq   
  return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	c3                   	retq   
  800e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e72:	c3                   	retq   
    if (*s == c)
  800e73:	48 89 f8             	mov    %rdi,%rax
  800e76:	c3                   	retq   

0000000000800e77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e77:	48 89 f8             	mov    %rdi,%rax
  800e7a:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e7c:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e7f:	40 38 f2             	cmp    %sil,%dl
  800e82:	74 13                	je     800e97 <strfind+0x20>
  800e84:	84 d2                	test   %dl,%dl
  800e86:	74 0f                	je     800e97 <strfind+0x20>
  for (; *s; s++)
  800e88:	48 83 c0 01          	add    $0x1,%rax
  800e8c:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e8f:	38 ca                	cmp    %cl,%dl
  800e91:	74 04                	je     800e97 <strfind+0x20>
  800e93:	84 d2                	test   %dl,%dl
  800e95:	75 f1                	jne    800e88 <strfind+0x11>
      break;
  return (char *)s;
}
  800e97:	c3                   	retq   

0000000000800e98 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e98:	48 85 d2             	test   %rdx,%rdx
  800e9b:	74 3a                	je     800ed7 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e9d:	48 89 f8             	mov    %rdi,%rax
  800ea0:	48 09 d0             	or     %rdx,%rax
  800ea3:	a8 03                	test   $0x3,%al
  800ea5:	75 28                	jne    800ecf <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ea7:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800eab:	89 f0                	mov    %esi,%eax
  800ead:	c1 e0 08             	shl    $0x8,%eax
  800eb0:	89 f1                	mov    %esi,%ecx
  800eb2:	c1 e1 18             	shl    $0x18,%ecx
  800eb5:	41 89 f0             	mov    %esi,%r8d
  800eb8:	41 c1 e0 10          	shl    $0x10,%r8d
  800ebc:	44 09 c1             	or     %r8d,%ecx
  800ebf:	09 ce                	or     %ecx,%esi
  800ec1:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ec3:	48 c1 ea 02          	shr    $0x2,%rdx
  800ec7:	48 89 d1             	mov    %rdx,%rcx
  800eca:	fc                   	cld    
  800ecb:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ecd:	eb 08                	jmp    800ed7 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ecf:	89 f0                	mov    %esi,%eax
  800ed1:	48 89 d1             	mov    %rdx,%rcx
  800ed4:	fc                   	cld    
  800ed5:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ed7:	48 89 f8             	mov    %rdi,%rax
  800eda:	c3                   	retq   

0000000000800edb <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800edb:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ede:	48 39 fe             	cmp    %rdi,%rsi
  800ee1:	73 40                	jae    800f23 <memmove+0x48>
  800ee3:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ee7:	48 39 f9             	cmp    %rdi,%rcx
  800eea:	76 37                	jbe    800f23 <memmove+0x48>
    s += n;
    d += n;
  800eec:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ef0:	48 89 fe             	mov    %rdi,%rsi
  800ef3:	48 09 d6             	or     %rdx,%rsi
  800ef6:	48 09 ce             	or     %rcx,%rsi
  800ef9:	40 f6 c6 03          	test   $0x3,%sil
  800efd:	75 14                	jne    800f13 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800eff:	48 83 ef 04          	sub    $0x4,%rdi
  800f03:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f07:	48 c1 ea 02          	shr    $0x2,%rdx
  800f0b:	48 89 d1             	mov    %rdx,%rcx
  800f0e:	fd                   	std    
  800f0f:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f11:	eb 0e                	jmp    800f21 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f13:	48 83 ef 01          	sub    $0x1,%rdi
  800f17:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f1b:	48 89 d1             	mov    %rdx,%rcx
  800f1e:	fd                   	std    
  800f1f:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f21:	fc                   	cld    
  800f22:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f23:	48 89 c1             	mov    %rax,%rcx
  800f26:	48 09 d1             	or     %rdx,%rcx
  800f29:	48 09 f1             	or     %rsi,%rcx
  800f2c:	f6 c1 03             	test   $0x3,%cl
  800f2f:	75 0e                	jne    800f3f <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f31:	48 c1 ea 02          	shr    $0x2,%rdx
  800f35:	48 89 d1             	mov    %rdx,%rcx
  800f38:	48 89 c7             	mov    %rax,%rdi
  800f3b:	fc                   	cld    
  800f3c:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f3e:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f3f:	48 89 c7             	mov    %rax,%rdi
  800f42:	48 89 d1             	mov    %rdx,%rcx
  800f45:	fc                   	cld    
  800f46:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f48:	c3                   	retq   

0000000000800f49 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f49:	55                   	push   %rbp
  800f4a:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f4d:	48 b8 db 0e 80 00 00 	movabs $0x800edb,%rax
  800f54:	00 00 00 
  800f57:	ff d0                	callq  *%rax
}
  800f59:	5d                   	pop    %rbp
  800f5a:	c3                   	retq   

0000000000800f5b <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f5b:	55                   	push   %rbp
  800f5c:	48 89 e5             	mov    %rsp,%rbp
  800f5f:	41 57                	push   %r15
  800f61:	41 56                	push   %r14
  800f63:	41 55                	push   %r13
  800f65:	41 54                	push   %r12
  800f67:	53                   	push   %rbx
  800f68:	48 83 ec 08          	sub    $0x8,%rsp
  800f6c:	49 89 fe             	mov    %rdi,%r14
  800f6f:	49 89 f7             	mov    %rsi,%r15
  800f72:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f75:	48 89 f7             	mov    %rsi,%rdi
  800f78:	48 b8 d0 0c 80 00 00 	movabs $0x800cd0,%rax
  800f7f:	00 00 00 
  800f82:	ff d0                	callq  *%rax
  800f84:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f87:	4c 89 ee             	mov    %r13,%rsi
  800f8a:	4c 89 f7             	mov    %r14,%rdi
  800f8d:	48 b8 f2 0c 80 00 00 	movabs $0x800cf2,%rax
  800f94:	00 00 00 
  800f97:	ff d0                	callq  *%rax
  800f99:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f9c:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fa0:	4d 39 e5             	cmp    %r12,%r13
  800fa3:	74 26                	je     800fcb <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fa5:	4c 89 e8             	mov    %r13,%rax
  800fa8:	4c 29 e0             	sub    %r12,%rax
  800fab:	48 39 d8             	cmp    %rbx,%rax
  800fae:	76 2a                	jbe    800fda <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fb0:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fb4:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fb8:	4c 89 fe             	mov    %r15,%rsi
  800fbb:	48 b8 49 0f 80 00 00 	movabs $0x800f49,%rax
  800fc2:	00 00 00 
  800fc5:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fc7:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fcb:	48 83 c4 08          	add    $0x8,%rsp
  800fcf:	5b                   	pop    %rbx
  800fd0:	41 5c                	pop    %r12
  800fd2:	41 5d                	pop    %r13
  800fd4:	41 5e                	pop    %r14
  800fd6:	41 5f                	pop    %r15
  800fd8:	5d                   	pop    %rbp
  800fd9:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fda:	49 83 ed 01          	sub    $0x1,%r13
  800fde:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fe2:	4c 89 ea             	mov    %r13,%rdx
  800fe5:	4c 89 fe             	mov    %r15,%rsi
  800fe8:	48 b8 49 0f 80 00 00 	movabs $0x800f49,%rax
  800fef:	00 00 00 
  800ff2:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800ff4:	4d 01 ee             	add    %r13,%r14
  800ff7:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800ffc:	eb c9                	jmp    800fc7 <strlcat+0x6c>

0000000000800ffe <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800ffe:	48 85 d2             	test   %rdx,%rdx
  801001:	74 3a                	je     80103d <memcmp+0x3f>
    if (*s1 != *s2)
  801003:	0f b6 0f             	movzbl (%rdi),%ecx
  801006:	44 0f b6 06          	movzbl (%rsi),%r8d
  80100a:	44 38 c1             	cmp    %r8b,%cl
  80100d:	75 1d                	jne    80102c <memcmp+0x2e>
  80100f:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801014:	48 39 d0             	cmp    %rdx,%rax
  801017:	74 1e                	je     801037 <memcmp+0x39>
    if (*s1 != *s2)
  801019:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80101d:	48 83 c0 01          	add    $0x1,%rax
  801021:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801027:	44 38 c1             	cmp    %r8b,%cl
  80102a:	74 e8                	je     801014 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80102c:	0f b6 c1             	movzbl %cl,%eax
  80102f:	45 0f b6 c0          	movzbl %r8b,%r8d
  801033:	44 29 c0             	sub    %r8d,%eax
  801036:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801037:	b8 00 00 00 00       	mov    $0x0,%eax
  80103c:	c3                   	retq   
  80103d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801042:	c3                   	retq   

0000000000801043 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801043:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801047:	48 39 c7             	cmp    %rax,%rdi
  80104a:	73 19                	jae    801065 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80104c:	89 f2                	mov    %esi,%edx
  80104e:	40 38 37             	cmp    %sil,(%rdi)
  801051:	74 16                	je     801069 <memfind+0x26>
  for (; s < ends; s++)
  801053:	48 83 c7 01          	add    $0x1,%rdi
  801057:	48 39 f8             	cmp    %rdi,%rax
  80105a:	74 08                	je     801064 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80105c:	38 17                	cmp    %dl,(%rdi)
  80105e:	75 f3                	jne    801053 <memfind+0x10>
  for (; s < ends; s++)
  801060:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801063:	c3                   	retq   
  801064:	c3                   	retq   
  for (; s < ends; s++)
  801065:	48 89 f8             	mov    %rdi,%rax
  801068:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801069:	48 89 f8             	mov    %rdi,%rax
  80106c:	c3                   	retq   

000000000080106d <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80106d:	0f b6 07             	movzbl (%rdi),%eax
  801070:	3c 20                	cmp    $0x20,%al
  801072:	74 04                	je     801078 <strtol+0xb>
  801074:	3c 09                	cmp    $0x9,%al
  801076:	75 0f                	jne    801087 <strtol+0x1a>
    s++;
  801078:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80107c:	0f b6 07             	movzbl (%rdi),%eax
  80107f:	3c 20                	cmp    $0x20,%al
  801081:	74 f5                	je     801078 <strtol+0xb>
  801083:	3c 09                	cmp    $0x9,%al
  801085:	74 f1                	je     801078 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801087:	3c 2b                	cmp    $0x2b,%al
  801089:	74 2b                	je     8010b6 <strtol+0x49>
  int neg  = 0;
  80108b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801091:	3c 2d                	cmp    $0x2d,%al
  801093:	74 2d                	je     8010c2 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801095:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80109b:	75 0f                	jne    8010ac <strtol+0x3f>
  80109d:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010a0:	74 2c                	je     8010ce <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010a2:	85 d2                	test   %edx,%edx
  8010a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a9:	0f 44 d0             	cmove  %eax,%edx
  8010ac:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010b1:	4c 63 d2             	movslq %edx,%r10
  8010b4:	eb 5c                	jmp    801112 <strtol+0xa5>
    s++;
  8010b6:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010ba:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010c0:	eb d3                	jmp    801095 <strtol+0x28>
    s++, neg = 1;
  8010c2:	48 83 c7 01          	add    $0x1,%rdi
  8010c6:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010cc:	eb c7                	jmp    801095 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ce:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010d2:	74 0f                	je     8010e3 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010d4:	85 d2                	test   %edx,%edx
  8010d6:	75 d4                	jne    8010ac <strtol+0x3f>
    s++, base = 8;
  8010d8:	48 83 c7 01          	add    $0x1,%rdi
  8010dc:	ba 08 00 00 00       	mov    $0x8,%edx
  8010e1:	eb c9                	jmp    8010ac <strtol+0x3f>
    s += 2, base = 16;
  8010e3:	48 83 c7 02          	add    $0x2,%rdi
  8010e7:	ba 10 00 00 00       	mov    $0x10,%edx
  8010ec:	eb be                	jmp    8010ac <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010ee:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010f2:	41 80 f8 19          	cmp    $0x19,%r8b
  8010f6:	77 2f                	ja     801127 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010f8:	44 0f be c1          	movsbl %cl,%r8d
  8010fc:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801100:	39 d1                	cmp    %edx,%ecx
  801102:	7d 37                	jge    80113b <strtol+0xce>
    s++, val = (val * base) + dig;
  801104:	48 83 c7 01          	add    $0x1,%rdi
  801108:	49 0f af c2          	imul   %r10,%rax
  80110c:	48 63 c9             	movslq %ecx,%rcx
  80110f:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801112:	0f b6 0f             	movzbl (%rdi),%ecx
  801115:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801119:	41 80 f8 09          	cmp    $0x9,%r8b
  80111d:	77 cf                	ja     8010ee <strtol+0x81>
      dig = *s - '0';
  80111f:	0f be c9             	movsbl %cl,%ecx
  801122:	83 e9 30             	sub    $0x30,%ecx
  801125:	eb d9                	jmp    801100 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801127:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80112b:	41 80 f8 19          	cmp    $0x19,%r8b
  80112f:	77 0a                	ja     80113b <strtol+0xce>
      dig = *s - 'A' + 10;
  801131:	44 0f be c1          	movsbl %cl,%r8d
  801135:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801139:	eb c5                	jmp    801100 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80113b:	48 85 f6             	test   %rsi,%rsi
  80113e:	74 03                	je     801143 <strtol+0xd6>
    *endptr = (char *)s;
  801140:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801143:	48 89 c2             	mov    %rax,%rdx
  801146:	48 f7 da             	neg    %rdx
  801149:	45 85 c9             	test   %r9d,%r9d
  80114c:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801150:	c3                   	retq   
  801151:	0f 1f 00             	nopl   (%rax)
