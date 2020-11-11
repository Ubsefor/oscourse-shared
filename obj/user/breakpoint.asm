
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

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800079:	45 85 ed             	test   %r13d,%r13d
  80007c:	7e 0d                	jle    80008b <libmain+0x5f>
    binaryname = argv[0];
  80007e:	49 8b 06             	mov    (%r14),%rax
  800081:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800088:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80008b:	4c 89 f6             	mov    %r14,%rsi
  80008e:	44 89 ef             	mov    %r13d,%edi
  800091:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800098:	00 00 00 
  80009b:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80009d:	48 b8 b2 00 80 00 00 	movabs $0x8000b2,%rax
  8000a4:	00 00 00 
  8000a7:	ff d0                	callq  *%rax
#endif
}
  8000a9:	5b                   	pop    %rbx
  8000aa:	41 5c                	pop    %r12
  8000ac:	41 5d                	pop    %r13
  8000ae:	41 5e                	pop    %r14
  8000b0:	5d                   	pop    %rbp
  8000b1:	c3                   	retq   

00000000008000b2 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000b2:	55                   	push   %rbp
  8000b3:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8000bb:	48 b8 07 01 80 00 00 	movabs $0x800107,%rax
  8000c2:	00 00 00 
  8000c5:	ff d0                	callq  *%rax
}
  8000c7:	5d                   	pop    %rbp
  8000c8:	c3                   	retq   

00000000008000c9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000c9:	55                   	push   %rbp
  8000ca:	48 89 e5             	mov    %rsp,%rbp
  8000cd:	53                   	push   %rbx
  8000ce:	48 89 fa             	mov    %rdi,%rdx
  8000d1:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d9:	48 89 c3             	mov    %rax,%rbx
  8000dc:	48 89 c7             	mov    %rax,%rdi
  8000df:	48 89 c6             	mov    %rax,%rsi
  8000e2:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8000e4:	5b                   	pop    %rbx
  8000e5:	5d                   	pop    %rbp
  8000e6:	c3                   	retq   

00000000008000e7 <sys_cgetc>:

int
sys_cgetc(void) {
  8000e7:	55                   	push   %rbp
  8000e8:	48 89 e5             	mov    %rsp,%rbp
  8000eb:	53                   	push   %rbx
  asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	48 89 ca             	mov    %rcx,%rdx
  8000f9:	48 89 cb             	mov    %rcx,%rbx
  8000fc:	48 89 cf             	mov    %rcx,%rdi
  8000ff:	48 89 ce             	mov    %rcx,%rsi
  800102:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800104:	5b                   	pop    %rbx
  800105:	5d                   	pop    %rbp
  800106:	c3                   	retq   

0000000000800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800107:	55                   	push   %rbp
  800108:	48 89 e5             	mov    %rsp,%rbp
  80010b:	53                   	push   %rbx
  80010c:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800110:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800113:	be 00 00 00 00       	mov    $0x0,%esi
  800118:	b8 03 00 00 00       	mov    $0x3,%eax
  80011d:	48 89 f1             	mov    %rsi,%rcx
  800120:	48 89 f3             	mov    %rsi,%rbx
  800123:	48 89 f7             	mov    %rsi,%rdi
  800126:	cd 30                	int    $0x30
  if (check && ret > 0)
  800128:	48 85 c0             	test   %rax,%rax
  80012b:	7f 07                	jg     800134 <sys_env_destroy+0x2d>
}
  80012d:	48 83 c4 08          	add    $0x8,%rsp
  800131:	5b                   	pop    %rbx
  800132:	5d                   	pop    %rbp
  800133:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800134:	49 89 c0             	mov    %rax,%r8
  800137:	b9 03 00 00 00       	mov    $0x3,%ecx
  80013c:	48 ba 30 11 80 00 00 	movabs $0x801130,%rdx
  800143:	00 00 00 
  800146:	be 22 00 00 00       	mov    $0x22,%esi
  80014b:	48 bf 4f 11 80 00 00 	movabs $0x80114f,%rdi
  800152:	00 00 00 
  800155:	b8 00 00 00 00       	mov    $0x0,%eax
  80015a:	49 b9 87 01 80 00 00 	movabs $0x800187,%r9
  800161:	00 00 00 
  800164:	41 ff d1             	callq  *%r9

0000000000800167 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800167:	55                   	push   %rbp
  800168:	48 89 e5             	mov    %rsp,%rbp
  80016b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80016c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800171:	b8 02 00 00 00       	mov    $0x2,%eax
  800176:	48 89 ca             	mov    %rcx,%rdx
  800179:	48 89 cb             	mov    %rcx,%rbx
  80017c:	48 89 cf             	mov    %rcx,%rdi
  80017f:	48 89 ce             	mov    %rcx,%rsi
  800182:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %rbx
  800185:	5d                   	pop    %rbp
  800186:	c3                   	retq   

0000000000800187 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800187:	55                   	push   %rbp
  800188:	48 89 e5             	mov    %rsp,%rbp
  80018b:	41 56                	push   %r14
  80018d:	41 55                	push   %r13
  80018f:	41 54                	push   %r12
  800191:	53                   	push   %rbx
  800192:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800199:	49 89 fd             	mov    %rdi,%r13
  80019c:	41 89 f6             	mov    %esi,%r14d
  80019f:	49 89 d4             	mov    %rdx,%r12
  8001a2:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001a9:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001b0:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001b7:	84 c0                	test   %al,%al
  8001b9:	74 26                	je     8001e1 <_panic+0x5a>
  8001bb:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001c2:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001c9:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001cd:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001d1:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001d5:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001d9:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001dd:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8001e1:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8001e8:	00 00 00 
  8001eb:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8001f2:	00 00 00 
  8001f5:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8001f9:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800200:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800207:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80020e:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800215:	00 00 00 
  800218:	48 8b 18             	mov    (%rax),%rbx
  80021b:	48 b8 67 01 80 00 00 	movabs $0x800167,%rax
  800222:	00 00 00 
  800225:	ff d0                	callq  *%rax
  800227:	45 89 f0             	mov    %r14d,%r8d
  80022a:	4c 89 e9             	mov    %r13,%rcx
  80022d:	48 89 da             	mov    %rbx,%rdx
  800230:	89 c6                	mov    %eax,%esi
  800232:	48 bf 60 11 80 00 00 	movabs $0x801160,%rdi
  800239:	00 00 00 
  80023c:	b8 00 00 00 00       	mov    $0x0,%eax
  800241:	48 bb 29 03 80 00 00 	movabs $0x800329,%rbx
  800248:	00 00 00 
  80024b:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80024d:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800254:	4c 89 e7             	mov    %r12,%rdi
  800257:	48 b8 c1 02 80 00 00 	movabs $0x8002c1,%rax
  80025e:	00 00 00 
  800261:	ff d0                	callq  *%rax
  cprintf("\n");
  800263:	48 bf 88 11 80 00 00 	movabs $0x801188,%rdi
  80026a:	00 00 00 
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
  800272:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800274:	cc                   	int3   
  while (1)
  800275:	eb fd                	jmp    800274 <_panic+0xed>

0000000000800277 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800277:	55                   	push   %rbp
  800278:	48 89 e5             	mov    %rsp,%rbp
  80027b:	53                   	push   %rbx
  80027c:	48 83 ec 08          	sub    $0x8,%rsp
  800280:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800283:	8b 06                	mov    (%rsi),%eax
  800285:	8d 50 01             	lea    0x1(%rax),%edx
  800288:	89 16                	mov    %edx,(%rsi)
  80028a:	48 98                	cltq   
  80028c:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800291:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800297:	74 0b                	je     8002a4 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800299:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80029d:	48 83 c4 08          	add    $0x8,%rsp
  8002a1:	5b                   	pop    %rbx
  8002a2:	5d                   	pop    %rbp
  8002a3:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002a4:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002a8:	be ff 00 00 00       	mov    $0xff,%esi
  8002ad:	48 b8 c9 00 80 00 00 	movabs $0x8000c9,%rax
  8002b4:	00 00 00 
  8002b7:	ff d0                	callq  *%rax
    b->idx = 0;
  8002b9:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002bf:	eb d8                	jmp    800299 <putch+0x22>

00000000008002c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002c1:	55                   	push   %rbp
  8002c2:	48 89 e5             	mov    %rsp,%rbp
  8002c5:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002cc:	48 89 fa             	mov    %rdi,%rdx
  8002cf:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002d9:	00 00 00 
  b.cnt = 0;
  8002dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002e3:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8002e6:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8002ed:	48 bf 77 02 80 00 00 	movabs $0x800277,%rdi
  8002f4:	00 00 00 
  8002f7:	48 b8 e7 04 80 00 00 	movabs $0x8004e7,%rax
  8002fe:	00 00 00 
  800301:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800303:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80030a:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800311:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800315:	48 b8 c9 00 80 00 00 	movabs $0x8000c9,%rax
  80031c:	00 00 00 
  80031f:	ff d0                	callq  *%rax

  return b.cnt;
}
  800321:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800327:	c9                   	leaveq 
  800328:	c3                   	retq   

0000000000800329 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800329:	55                   	push   %rbp
  80032a:	48 89 e5             	mov    %rsp,%rbp
  80032d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800334:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80033b:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800342:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800349:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800350:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800357:	84 c0                	test   %al,%al
  800359:	74 20                	je     80037b <cprintf+0x52>
  80035b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80035f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800363:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800367:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80036b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80036f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800373:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800377:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80037b:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800382:	00 00 00 
  800385:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80038c:	00 00 00 
  80038f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800393:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80039a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003a1:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003a8:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003af:	48 b8 c1 02 80 00 00 	movabs $0x8002c1,%rax
  8003b6:	00 00 00 
  8003b9:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003bb:	c9                   	leaveq 
  8003bc:	c3                   	retq   

00000000008003bd <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003bd:	55                   	push   %rbp
  8003be:	48 89 e5             	mov    %rsp,%rbp
  8003c1:	41 57                	push   %r15
  8003c3:	41 56                	push   %r14
  8003c5:	41 55                	push   %r13
  8003c7:	41 54                	push   %r12
  8003c9:	53                   	push   %rbx
  8003ca:	48 83 ec 18          	sub    $0x18,%rsp
  8003ce:	49 89 fc             	mov    %rdi,%r12
  8003d1:	49 89 f5             	mov    %rsi,%r13
  8003d4:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003d8:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003db:	41 89 cf             	mov    %ecx,%r15d
  8003de:	49 39 d7             	cmp    %rdx,%r15
  8003e1:	76 45                	jbe    800428 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003e3:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8003e7:	85 db                	test   %ebx,%ebx
  8003e9:	7e 0e                	jle    8003f9 <printnum+0x3c>
      putch(padc, putdat);
  8003eb:	4c 89 ee             	mov    %r13,%rsi
  8003ee:	44 89 f7             	mov    %r14d,%edi
  8003f1:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8003f4:	83 eb 01             	sub    $0x1,%ebx
  8003f7:	75 f2                	jne    8003eb <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8003f9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800402:	49 f7 f7             	div    %r15
  800405:	48 b8 8a 11 80 00 00 	movabs $0x80118a,%rax
  80040c:	00 00 00 
  80040f:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800413:	4c 89 ee             	mov    %r13,%rsi
  800416:	41 ff d4             	callq  *%r12
}
  800419:	48 83 c4 18          	add    $0x18,%rsp
  80041d:	5b                   	pop    %rbx
  80041e:	41 5c                	pop    %r12
  800420:	41 5d                	pop    %r13
  800422:	41 5e                	pop    %r14
  800424:	41 5f                	pop    %r15
  800426:	5d                   	pop    %rbp
  800427:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800428:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042c:	ba 00 00 00 00       	mov    $0x0,%edx
  800431:	49 f7 f7             	div    %r15
  800434:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800438:	48 89 c2             	mov    %rax,%rdx
  80043b:	48 b8 bd 03 80 00 00 	movabs $0x8003bd,%rax
  800442:	00 00 00 
  800445:	ff d0                	callq  *%rax
  800447:	eb b0                	jmp    8003f9 <printnum+0x3c>

0000000000800449 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800449:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80044d:	48 8b 06             	mov    (%rsi),%rax
  800450:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800454:	73 0a                	jae    800460 <sprintputch+0x17>
    *b->buf++ = ch;
  800456:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80045a:	48 89 16             	mov    %rdx,(%rsi)
  80045d:	40 88 38             	mov    %dil,(%rax)
}
  800460:	c3                   	retq   

0000000000800461 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800461:	55                   	push   %rbp
  800462:	48 89 e5             	mov    %rsp,%rbp
  800465:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80046c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800473:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80047a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800481:	84 c0                	test   %al,%al
  800483:	74 20                	je     8004a5 <printfmt+0x44>
  800485:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800489:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80048d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800491:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800495:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800499:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80049d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004a1:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004a5:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004ac:	00 00 00 
  8004af:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004b6:	00 00 00 
  8004b9:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004bd:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004c4:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004cb:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004d2:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004d9:	48 b8 e7 04 80 00 00 	movabs $0x8004e7,%rax
  8004e0:	00 00 00 
  8004e3:	ff d0                	callq  *%rax
}
  8004e5:	c9                   	leaveq 
  8004e6:	c3                   	retq   

00000000008004e7 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8004e7:	55                   	push   %rbp
  8004e8:	48 89 e5             	mov    %rsp,%rbp
  8004eb:	41 57                	push   %r15
  8004ed:	41 56                	push   %r14
  8004ef:	41 55                	push   %r13
  8004f1:	41 54                	push   %r12
  8004f3:	53                   	push   %rbx
  8004f4:	48 83 ec 48          	sub    $0x48,%rsp
  8004f8:	49 89 fd             	mov    %rdi,%r13
  8004fb:	49 89 f7             	mov    %rsi,%r15
  8004fe:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800501:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800505:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800509:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80050d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800511:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800515:	41 0f b6 3e          	movzbl (%r14),%edi
  800519:	83 ff 25             	cmp    $0x25,%edi
  80051c:	74 18                	je     800536 <vprintfmt+0x4f>
      if (ch == '\0')
  80051e:	85 ff                	test   %edi,%edi
  800520:	0f 84 8c 06 00 00    	je     800bb2 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800526:	4c 89 fe             	mov    %r15,%rsi
  800529:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80052c:	49 89 de             	mov    %rbx,%r14
  80052f:	eb e0                	jmp    800511 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800531:	49 89 de             	mov    %rbx,%r14
  800534:	eb db                	jmp    800511 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800536:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80053a:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80053e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800545:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80054b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80054f:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800554:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80055a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800560:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800565:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80056a:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80056e:	0f b6 13             	movzbl (%rbx),%edx
  800571:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800574:	3c 55                	cmp    $0x55,%al
  800576:	0f 87 8b 05 00 00    	ja     800b07 <vprintfmt+0x620>
  80057c:	0f b6 c0             	movzbl %al,%eax
  80057f:	49 bb 40 12 80 00 00 	movabs $0x801240,%r11
  800586:	00 00 00 
  800589:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80058d:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800590:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800594:	eb d4                	jmp    80056a <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800596:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800599:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80059d:	eb cb                	jmp    80056a <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80059f:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005a2:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005a6:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005aa:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005ad:	83 fa 09             	cmp    $0x9,%edx
  8005b0:	77 7e                	ja     800630 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005b2:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005b6:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005ba:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005bf:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005c3:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005c6:	83 fa 09             	cmp    $0x9,%edx
  8005c9:	76 e7                	jbe    8005b2 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005cb:	4c 89 f3             	mov    %r14,%rbx
  8005ce:	eb 19                	jmp    8005e9 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005d0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005d3:	83 f8 2f             	cmp    $0x2f,%eax
  8005d6:	77 2a                	ja     800602 <vprintfmt+0x11b>
  8005d8:	89 c2                	mov    %eax,%edx
  8005da:	4c 01 d2             	add    %r10,%rdx
  8005dd:	83 c0 08             	add    $0x8,%eax
  8005e0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005e3:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8005e6:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8005e9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005ed:	0f 89 77 ff ff ff    	jns    80056a <vprintfmt+0x83>
          width = precision, precision = -1;
  8005f3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8005f7:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8005fd:	e9 68 ff ff ff       	jmpq   80056a <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800602:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800606:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80060a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80060e:	eb d3                	jmp    8005e3 <vprintfmt+0xfc>
        if (width < 0)
  800610:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	41 0f 48 c0          	cmovs  %r8d,%eax
  800619:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80061c:	4c 89 f3             	mov    %r14,%rbx
  80061f:	e9 46 ff ff ff       	jmpq   80056a <vprintfmt+0x83>
  800624:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800627:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80062b:	e9 3a ff ff ff       	jmpq   80056a <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800630:	4c 89 f3             	mov    %r14,%rbx
  800633:	eb b4                	jmp    8005e9 <vprintfmt+0x102>
        lflag++;
  800635:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800638:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80063b:	e9 2a ff ff ff       	jmpq   80056a <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800640:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800643:	83 f8 2f             	cmp    $0x2f,%eax
  800646:	77 19                	ja     800661 <vprintfmt+0x17a>
  800648:	89 c2                	mov    %eax,%edx
  80064a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80064e:	83 c0 08             	add    $0x8,%eax
  800651:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800654:	4c 89 fe             	mov    %r15,%rsi
  800657:	8b 3a                	mov    (%rdx),%edi
  800659:	41 ff d5             	callq  *%r13
        break;
  80065c:	e9 b0 fe ff ff       	jmpq   800511 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800661:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800665:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800669:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80066d:	eb e5                	jmp    800654 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80066f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800672:	83 f8 2f             	cmp    $0x2f,%eax
  800675:	77 5b                	ja     8006d2 <vprintfmt+0x1eb>
  800677:	89 c2                	mov    %eax,%edx
  800679:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80067d:	83 c0 08             	add    $0x8,%eax
  800680:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800683:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800685:	89 c8                	mov    %ecx,%eax
  800687:	c1 f8 1f             	sar    $0x1f,%eax
  80068a:	31 c1                	xor    %eax,%ecx
  80068c:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068e:	83 f9 09             	cmp    $0x9,%ecx
  800691:	7f 4d                	jg     8006e0 <vprintfmt+0x1f9>
  800693:	48 63 c1             	movslq %ecx,%rax
  800696:	48 ba 00 15 80 00 00 	movabs $0x801500,%rdx
  80069d:	00 00 00 
  8006a0:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006a4:	48 85 c0             	test   %rax,%rax
  8006a7:	74 37                	je     8006e0 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006a9:	48 89 c1             	mov    %rax,%rcx
  8006ac:	48 ba ab 11 80 00 00 	movabs $0x8011ab,%rdx
  8006b3:	00 00 00 
  8006b6:	4c 89 fe             	mov    %r15,%rsi
  8006b9:	4c 89 ef             	mov    %r13,%rdi
  8006bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c1:	48 bb 61 04 80 00 00 	movabs $0x800461,%rbx
  8006c8:	00 00 00 
  8006cb:	ff d3                	callq  *%rbx
  8006cd:	e9 3f fe ff ff       	jmpq   800511 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006d6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006da:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006de:	eb a3                	jmp    800683 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006e0:	48 ba a2 11 80 00 00 	movabs $0x8011a2,%rdx
  8006e7:	00 00 00 
  8006ea:	4c 89 fe             	mov    %r15,%rsi
  8006ed:	4c 89 ef             	mov    %r13,%rdi
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	48 bb 61 04 80 00 00 	movabs $0x800461,%rbx
  8006fc:	00 00 00 
  8006ff:	ff d3                	callq  *%rbx
  800701:	e9 0b fe ff ff       	jmpq   800511 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800706:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800709:	83 f8 2f             	cmp    $0x2f,%eax
  80070c:	77 4b                	ja     800759 <vprintfmt+0x272>
  80070e:	89 c2                	mov    %eax,%edx
  800710:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800714:	83 c0 08             	add    $0x8,%eax
  800717:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80071a:	48 8b 02             	mov    (%rdx),%rax
  80071d:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800721:	48 85 c0             	test   %rax,%rax
  800724:	0f 84 05 04 00 00    	je     800b2f <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80072a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80072e:	7e 06                	jle    800736 <vprintfmt+0x24f>
  800730:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800734:	75 31                	jne    800767 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800736:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80073a:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80073e:	0f b6 00             	movzbl (%rax),%eax
  800741:	0f be f8             	movsbl %al,%edi
  800744:	85 ff                	test   %edi,%edi
  800746:	0f 84 c3 00 00 00    	je     80080f <vprintfmt+0x328>
  80074c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800750:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800754:	e9 85 00 00 00       	jmpq   8007de <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800759:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80075d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800761:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800765:	eb b3                	jmp    80071a <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800767:	49 63 f4             	movslq %r12d,%rsi
  80076a:	48 89 c7             	mov    %rax,%rdi
  80076d:	48 b8 be 0c 80 00 00 	movabs $0x800cbe,%rax
  800774:	00 00 00 
  800777:	ff d0                	callq  *%rax
  800779:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80077c:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80077f:	85 f6                	test   %esi,%esi
  800781:	7e 22                	jle    8007a5 <vprintfmt+0x2be>
            putch(padc, putdat);
  800783:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800787:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  80078b:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80078f:	4c 89 fe             	mov    %r15,%rsi
  800792:	89 df                	mov    %ebx,%edi
  800794:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800797:	41 83 ec 01          	sub    $0x1,%r12d
  80079b:	75 f2                	jne    80078f <vprintfmt+0x2a8>
  80079d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007a1:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a5:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007a9:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007ad:	0f b6 00             	movzbl (%rax),%eax
  8007b0:	0f be f8             	movsbl %al,%edi
  8007b3:	85 ff                	test   %edi,%edi
  8007b5:	0f 84 56 fd ff ff    	je     800511 <vprintfmt+0x2a>
  8007bb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007bf:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007c3:	eb 19                	jmp    8007de <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007c5:	4c 89 fe             	mov    %r15,%rsi
  8007c8:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cb:	41 83 ee 01          	sub    $0x1,%r14d
  8007cf:	48 83 c3 01          	add    $0x1,%rbx
  8007d3:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007d7:	0f be f8             	movsbl %al,%edi
  8007da:	85 ff                	test   %edi,%edi
  8007dc:	74 29                	je     800807 <vprintfmt+0x320>
  8007de:	45 85 e4             	test   %r12d,%r12d
  8007e1:	78 06                	js     8007e9 <vprintfmt+0x302>
  8007e3:	41 83 ec 01          	sub    $0x1,%r12d
  8007e7:	78 48                	js     800831 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8007e9:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8007ed:	74 d6                	je     8007c5 <vprintfmt+0x2de>
  8007ef:	0f be c0             	movsbl %al,%eax
  8007f2:	83 e8 20             	sub    $0x20,%eax
  8007f5:	83 f8 5e             	cmp    $0x5e,%eax
  8007f8:	76 cb                	jbe    8007c5 <vprintfmt+0x2de>
            putch('?', putdat);
  8007fa:	4c 89 fe             	mov    %r15,%rsi
  8007fd:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800802:	41 ff d5             	callq  *%r13
  800805:	eb c4                	jmp    8007cb <vprintfmt+0x2e4>
  800807:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80080b:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80080f:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800812:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800816:	0f 8e f5 fc ff ff    	jle    800511 <vprintfmt+0x2a>
          putch(' ', putdat);
  80081c:	4c 89 fe             	mov    %r15,%rsi
  80081f:	bf 20 00 00 00       	mov    $0x20,%edi
  800824:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800827:	83 eb 01             	sub    $0x1,%ebx
  80082a:	75 f0                	jne    80081c <vprintfmt+0x335>
  80082c:	e9 e0 fc ff ff       	jmpq   800511 <vprintfmt+0x2a>
  800831:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800835:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800839:	eb d4                	jmp    80080f <vprintfmt+0x328>
  if (lflag >= 2)
  80083b:	83 f9 01             	cmp    $0x1,%ecx
  80083e:	7f 1d                	jg     80085d <vprintfmt+0x376>
  else if (lflag)
  800840:	85 c9                	test   %ecx,%ecx
  800842:	74 5e                	je     8008a2 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800844:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800847:	83 f8 2f             	cmp    $0x2f,%eax
  80084a:	77 48                	ja     800894 <vprintfmt+0x3ad>
  80084c:	89 c2                	mov    %eax,%edx
  80084e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800852:	83 c0 08             	add    $0x8,%eax
  800855:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800858:	48 8b 1a             	mov    (%rdx),%rbx
  80085b:	eb 17                	jmp    800874 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80085d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800860:	83 f8 2f             	cmp    $0x2f,%eax
  800863:	77 21                	ja     800886 <vprintfmt+0x39f>
  800865:	89 c2                	mov    %eax,%edx
  800867:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80086b:	83 c0 08             	add    $0x8,%eax
  80086e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800871:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800874:	48 85 db             	test   %rbx,%rbx
  800877:	78 50                	js     8008c9 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800879:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80087c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800881:	e9 b4 01 00 00       	jmpq   800a3a <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800886:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80088a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80088e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800892:	eb dd                	jmp    800871 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800894:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800898:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80089c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a0:	eb b6                	jmp    800858 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008a2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008a5:	83 f8 2f             	cmp    $0x2f,%eax
  8008a8:	77 11                	ja     8008bb <vprintfmt+0x3d4>
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b0:	83 c0 08             	add    $0x8,%eax
  8008b3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008b6:	48 63 1a             	movslq (%rdx),%rbx
  8008b9:	eb b9                	jmp    800874 <vprintfmt+0x38d>
  8008bb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008bf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c7:	eb ed                	jmp    8008b6 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008c9:	4c 89 fe             	mov    %r15,%rsi
  8008cc:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008d1:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008d4:	48 89 da             	mov    %rbx,%rdx
  8008d7:	48 f7 da             	neg    %rdx
        base = 10;
  8008da:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008df:	e9 56 01 00 00       	jmpq   800a3a <vprintfmt+0x553>
  if (lflag >= 2)
  8008e4:	83 f9 01             	cmp    $0x1,%ecx
  8008e7:	7f 25                	jg     80090e <vprintfmt+0x427>
  else if (lflag)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 5e                	je     80094b <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8008ed:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f0:	83 f8 2f             	cmp    $0x2f,%eax
  8008f3:	77 48                	ja     80093d <vprintfmt+0x456>
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008fb:	83 c0 08             	add    $0x8,%eax
  8008fe:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800901:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800904:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800909:	e9 2c 01 00 00       	jmpq   800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80090e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800911:	83 f8 2f             	cmp    $0x2f,%eax
  800914:	77 19                	ja     80092f <vprintfmt+0x448>
  800916:	89 c2                	mov    %eax,%edx
  800918:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091c:	83 c0 08             	add    $0x8,%eax
  80091f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800922:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800925:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092a:	e9 0b 01 00 00       	jmpq   800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80092f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800933:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800937:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80093b:	eb e5                	jmp    800922 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80093d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800941:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800945:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800949:	eb b6                	jmp    800901 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80094b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094e:	83 f8 2f             	cmp    $0x2f,%eax
  800951:	77 18                	ja     80096b <vprintfmt+0x484>
  800953:	89 c2                	mov    %eax,%edx
  800955:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800959:	83 c0 08             	add    $0x8,%eax
  80095c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095f:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800961:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800966:	e9 cf 00 00 00       	jmpq   800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80096b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800973:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800977:	eb e6                	jmp    80095f <vprintfmt+0x478>
  if (lflag >= 2)
  800979:	83 f9 01             	cmp    $0x1,%ecx
  80097c:	7f 25                	jg     8009a3 <vprintfmt+0x4bc>
  else if (lflag)
  80097e:	85 c9                	test   %ecx,%ecx
  800980:	74 5b                	je     8009dd <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800982:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800985:	83 f8 2f             	cmp    $0x2f,%eax
  800988:	77 45                	ja     8009cf <vprintfmt+0x4e8>
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800990:	83 c0 08             	add    $0x8,%eax
  800993:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800996:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800999:	b9 08 00 00 00       	mov    $0x8,%ecx
  80099e:	e9 97 00 00 00       	jmpq   800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009a3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a6:	83 f8 2f             	cmp    $0x2f,%eax
  8009a9:	77 16                	ja     8009c1 <vprintfmt+0x4da>
  8009ab:	89 c2                	mov    %eax,%edx
  8009ad:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009b1:	83 c0 08             	add    $0x8,%eax
  8009b4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b7:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009ba:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009bf:	eb 79                	jmp    800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009c1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009c5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009cd:	eb e8                	jmp    8009b7 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009cf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009d7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009db:	eb b9                	jmp    800996 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009dd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e0:	83 f8 2f             	cmp    $0x2f,%eax
  8009e3:	77 15                	ja     8009fa <vprintfmt+0x513>
  8009e5:	89 c2                	mov    %eax,%edx
  8009e7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009eb:	83 c0 08             	add    $0x8,%eax
  8009ee:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f1:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8009f3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f8:	eb 40                	jmp    800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009fa:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009fe:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a02:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a06:	eb e9                	jmp    8009f1 <vprintfmt+0x50a>
        putch('0', putdat);
  800a08:	4c 89 fe             	mov    %r15,%rsi
  800a0b:	bf 30 00 00 00       	mov    $0x30,%edi
  800a10:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a13:	4c 89 fe             	mov    %r15,%rsi
  800a16:	bf 78 00 00 00       	mov    $0x78,%edi
  800a1b:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a1e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a21:	83 f8 2f             	cmp    $0x2f,%eax
  800a24:	77 34                	ja     800a5a <vprintfmt+0x573>
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a2c:	83 c0 08             	add    $0x8,%eax
  800a2f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a32:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a35:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a3a:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a3f:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a43:	4c 89 fe             	mov    %r15,%rsi
  800a46:	4c 89 ef             	mov    %r13,%rdi
  800a49:	48 b8 bd 03 80 00 00 	movabs $0x8003bd,%rax
  800a50:	00 00 00 
  800a53:	ff d0                	callq  *%rax
        break;
  800a55:	e9 b7 fa ff ff       	jmpq   800511 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a5a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a5e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a62:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a66:	eb ca                	jmp    800a32 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a68:	83 f9 01             	cmp    $0x1,%ecx
  800a6b:	7f 22                	jg     800a8f <vprintfmt+0x5a8>
  else if (lflag)
  800a6d:	85 c9                	test   %ecx,%ecx
  800a6f:	74 58                	je     800ac9 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a71:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a74:	83 f8 2f             	cmp    $0x2f,%eax
  800a77:	77 42                	ja     800abb <vprintfmt+0x5d4>
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a7f:	83 c0 08             	add    $0x8,%eax
  800a82:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a85:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a88:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a8d:	eb ab                	jmp    800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a8f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a92:	83 f8 2f             	cmp    $0x2f,%eax
  800a95:	77 16                	ja     800aad <vprintfmt+0x5c6>
  800a97:	89 c2                	mov    %eax,%edx
  800a99:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a9d:	83 c0 08             	add    $0x8,%eax
  800aa0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aa3:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aa6:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aab:	eb 8d                	jmp    800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800aad:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ab1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ab9:	eb e8                	jmp    800aa3 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800abb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800abf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ac3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ac7:	eb bc                	jmp    800a85 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ac9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800acc:	83 f8 2f             	cmp    $0x2f,%eax
  800acf:	77 18                	ja     800ae9 <vprintfmt+0x602>
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad7:	83 c0 08             	add    $0x8,%eax
  800ada:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800add:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800adf:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae4:	e9 51 ff ff ff       	jmpq   800a3a <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800ae9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aed:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800af5:	eb e6                	jmp    800add <vprintfmt+0x5f6>
        putch(ch, putdat);
  800af7:	4c 89 fe             	mov    %r15,%rsi
  800afa:	bf 25 00 00 00       	mov    $0x25,%edi
  800aff:	41 ff d5             	callq  *%r13
        break;
  800b02:	e9 0a fa ff ff       	jmpq   800511 <vprintfmt+0x2a>
        putch('%', putdat);
  800b07:	4c 89 fe             	mov    %r15,%rsi
  800b0a:	bf 25 00 00 00       	mov    $0x25,%edi
  800b0f:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b12:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b16:	0f 84 15 fa ff ff    	je     800531 <vprintfmt+0x4a>
  800b1c:	49 89 de             	mov    %rbx,%r14
  800b1f:	49 83 ee 01          	sub    $0x1,%r14
  800b23:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b28:	75 f5                	jne    800b1f <vprintfmt+0x638>
  800b2a:	e9 e2 f9 ff ff       	jmpq   800511 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b2f:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b33:	74 06                	je     800b3b <vprintfmt+0x654>
  800b35:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b39:	7f 21                	jg     800b5c <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b3b:	bf 28 00 00 00       	mov    $0x28,%edi
  800b40:	48 bb 9c 11 80 00 00 	movabs $0x80119c,%rbx
  800b47:	00 00 00 
  800b4a:	b8 28 00 00 00       	mov    $0x28,%eax
  800b4f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b53:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b57:	e9 82 fc ff ff       	jmpq   8007de <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b5c:	49 63 f4             	movslq %r12d,%rsi
  800b5f:	48 bf 9b 11 80 00 00 	movabs $0x80119b,%rdi
  800b66:	00 00 00 
  800b69:	48 b8 be 0c 80 00 00 	movabs $0x800cbe,%rax
  800b70:	00 00 00 
  800b73:	ff d0                	callq  *%rax
  800b75:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b78:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b7b:	48 be 9b 11 80 00 00 	movabs $0x80119b,%rsi
  800b82:	00 00 00 
  800b85:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	0f 8f f2 fb ff ff    	jg     800783 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b91:	48 bb 9c 11 80 00 00 	movabs $0x80119c,%rbx
  800b98:	00 00 00 
  800b9b:	b8 28 00 00 00       	mov    $0x28,%eax
  800ba0:	bf 28 00 00 00       	mov    $0x28,%edi
  800ba5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ba9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bad:	e9 2c fc ff ff       	jmpq   8007de <vprintfmt+0x2f7>
}
  800bb2:	48 83 c4 48          	add    $0x48,%rsp
  800bb6:	5b                   	pop    %rbx
  800bb7:	41 5c                	pop    %r12
  800bb9:	41 5d                	pop    %r13
  800bbb:	41 5e                	pop    %r14
  800bbd:	41 5f                	pop    %r15
  800bbf:	5d                   	pop    %rbp
  800bc0:	c3                   	retq   

0000000000800bc1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bc1:	55                   	push   %rbp
  800bc2:	48 89 e5             	mov    %rsp,%rbp
  800bc5:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bc9:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bcd:	48 63 c6             	movslq %esi,%rax
  800bd0:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bd5:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bd9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800be0:	48 85 ff             	test   %rdi,%rdi
  800be3:	74 2a                	je     800c0f <vsnprintf+0x4e>
  800be5:	85 f6                	test   %esi,%esi
  800be7:	7e 26                	jle    800c0f <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800be9:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800bed:	48 bf 49 04 80 00 00 	movabs $0x800449,%rdi
  800bf4:	00 00 00 
  800bf7:	48 b8 e7 04 80 00 00 	movabs $0x8004e7,%rax
  800bfe:	00 00 00 
  800c01:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c03:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c07:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c0a:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c0d:	c9                   	leaveq 
  800c0e:	c3                   	retq   
    return -E_INVAL;
  800c0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c14:	eb f7                	jmp    800c0d <vsnprintf+0x4c>

0000000000800c16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c16:	55                   	push   %rbp
  800c17:	48 89 e5             	mov    %rsp,%rbp
  800c1a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c21:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c28:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c2f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c36:	84 c0                	test   %al,%al
  800c38:	74 20                	je     800c5a <snprintf+0x44>
  800c3a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c3e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c42:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c46:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c4a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c4e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c52:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c56:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c5a:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c61:	00 00 00 
  800c64:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c6b:	00 00 00 
  800c6e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c72:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c79:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c80:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800c87:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800c8e:	48 b8 c1 0b 80 00 00 	movabs $0x800bc1,%rax
  800c95:	00 00 00 
  800c98:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800c9a:	c9                   	leaveq 
  800c9b:	c3                   	retq   

0000000000800c9c <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800c9c:	80 3f 00             	cmpb   $0x0,(%rdi)
  800c9f:	74 17                	je     800cb8 <strlen+0x1c>
  800ca1:	48 89 fa             	mov    %rdi,%rdx
  800ca4:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ca9:	29 f9                	sub    %edi,%ecx
    n++;
  800cab:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cae:	48 83 c2 01          	add    $0x1,%rdx
  800cb2:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cb5:	75 f4                	jne    800cab <strlen+0xf>
  800cb7:	c3                   	retq   
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cbd:	c3                   	retq   

0000000000800cbe <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbe:	48 85 f6             	test   %rsi,%rsi
  800cc1:	74 24                	je     800ce7 <strnlen+0x29>
  800cc3:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cc6:	74 25                	je     800ced <strnlen+0x2f>
  800cc8:	48 01 fe             	add    %rdi,%rsi
  800ccb:	48 89 fa             	mov    %rdi,%rdx
  800cce:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cd3:	29 f9                	sub    %edi,%ecx
    n++;
  800cd5:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	48 83 c2 01          	add    $0x1,%rdx
  800cdc:	48 39 f2             	cmp    %rsi,%rdx
  800cdf:	74 11                	je     800cf2 <strnlen+0x34>
  800ce1:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ce4:	75 ef                	jne    800cd5 <strnlen+0x17>
  800ce6:	c3                   	retq   
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cec:	c3                   	retq   
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cf2:	c3                   	retq   

0000000000800cf3 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800cf3:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800cf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfb:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800cff:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d02:	48 83 c2 01          	add    $0x1,%rdx
  800d06:	84 c9                	test   %cl,%cl
  800d08:	75 f1                	jne    800cfb <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d0a:	c3                   	retq   

0000000000800d0b <strcat>:

char *
strcat(char *dst, const char *src) {
  800d0b:	55                   	push   %rbp
  800d0c:	48 89 e5             	mov    %rsp,%rbp
  800d0f:	41 54                	push   %r12
  800d11:	53                   	push   %rbx
  800d12:	48 89 fb             	mov    %rdi,%rbx
  800d15:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d18:	48 b8 9c 0c 80 00 00 	movabs $0x800c9c,%rax
  800d1f:	00 00 00 
  800d22:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d24:	48 63 f8             	movslq %eax,%rdi
  800d27:	48 01 df             	add    %rbx,%rdi
  800d2a:	4c 89 e6             	mov    %r12,%rsi
  800d2d:	48 b8 f3 0c 80 00 00 	movabs $0x800cf3,%rax
  800d34:	00 00 00 
  800d37:	ff d0                	callq  *%rax
  return dst;
}
  800d39:	48 89 d8             	mov    %rbx,%rax
  800d3c:	5b                   	pop    %rbx
  800d3d:	41 5c                	pop    %r12
  800d3f:	5d                   	pop    %rbp
  800d40:	c3                   	retq   

0000000000800d41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d41:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d44:	48 85 d2             	test   %rdx,%rdx
  800d47:	74 1f                	je     800d68 <strncpy+0x27>
  800d49:	48 01 fa             	add    %rdi,%rdx
  800d4c:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d4f:	48 83 c1 01          	add    $0x1,%rcx
  800d53:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d57:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d5b:	41 80 f8 01          	cmp    $0x1,%r8b
  800d5f:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d63:	48 39 ca             	cmp    %rcx,%rdx
  800d66:	75 e7                	jne    800d4f <strncpy+0xe>
  }
  return ret;
}
  800d68:	c3                   	retq   

0000000000800d69 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d69:	48 89 f8             	mov    %rdi,%rax
  800d6c:	48 85 d2             	test   %rdx,%rdx
  800d6f:	74 36                	je     800da7 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d71:	48 83 fa 01          	cmp    $0x1,%rdx
  800d75:	74 2d                	je     800da4 <strlcpy+0x3b>
  800d77:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d7b:	45 84 c0             	test   %r8b,%r8b
  800d7e:	74 24                	je     800da4 <strlcpy+0x3b>
  800d80:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d84:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800d89:	48 83 c0 01          	add    $0x1,%rax
  800d8d:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800d91:	48 39 d1             	cmp    %rdx,%rcx
  800d94:	74 0e                	je     800da4 <strlcpy+0x3b>
  800d96:	48 83 c1 01          	add    $0x1,%rcx
  800d9a:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800d9f:	45 84 c0             	test   %r8b,%r8b
  800da2:	75 e5                	jne    800d89 <strlcpy+0x20>
    *dst = '\0';
  800da4:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800da7:	48 29 f8             	sub    %rdi,%rax
}
  800daa:	c3                   	retq   

0000000000800dab <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dab:	0f b6 07             	movzbl (%rdi),%eax
  800dae:	84 c0                	test   %al,%al
  800db0:	74 17                	je     800dc9 <strcmp+0x1e>
  800db2:	3a 06                	cmp    (%rsi),%al
  800db4:	75 13                	jne    800dc9 <strcmp+0x1e>
    p++, q++;
  800db6:	48 83 c7 01          	add    $0x1,%rdi
  800dba:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dbe:	0f b6 07             	movzbl (%rdi),%eax
  800dc1:	84 c0                	test   %al,%al
  800dc3:	74 04                	je     800dc9 <strcmp+0x1e>
  800dc5:	3a 06                	cmp    (%rsi),%al
  800dc7:	74 ed                	je     800db6 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dc9:	0f b6 c0             	movzbl %al,%eax
  800dcc:	0f b6 16             	movzbl (%rsi),%edx
  800dcf:	29 d0                	sub    %edx,%eax
}
  800dd1:	c3                   	retq   

0000000000800dd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800dd2:	48 85 d2             	test   %rdx,%rdx
  800dd5:	74 2f                	je     800e06 <strncmp+0x34>
  800dd7:	0f b6 07             	movzbl (%rdi),%eax
  800dda:	84 c0                	test   %al,%al
  800ddc:	74 1f                	je     800dfd <strncmp+0x2b>
  800dde:	3a 06                	cmp    (%rsi),%al
  800de0:	75 1b                	jne    800dfd <strncmp+0x2b>
  800de2:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800de5:	48 83 c7 01          	add    $0x1,%rdi
  800de9:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800ded:	48 39 d7             	cmp    %rdx,%rdi
  800df0:	74 1a                	je     800e0c <strncmp+0x3a>
  800df2:	0f b6 07             	movzbl (%rdi),%eax
  800df5:	84 c0                	test   %al,%al
  800df7:	74 04                	je     800dfd <strncmp+0x2b>
  800df9:	3a 06                	cmp    (%rsi),%al
  800dfb:	74 e8                	je     800de5 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800dfd:	0f b6 07             	movzbl (%rdi),%eax
  800e00:	0f b6 16             	movzbl (%rsi),%edx
  800e03:	29 d0                	sub    %edx,%eax
}
  800e05:	c3                   	retq   
    return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	c3                   	retq   
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e11:	c3                   	retq   

0000000000800e12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e12:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e14:	0f b6 07             	movzbl (%rdi),%eax
  800e17:	84 c0                	test   %al,%al
  800e19:	74 1e                	je     800e39 <strchr+0x27>
    if (*s == c)
  800e1b:	40 38 c6             	cmp    %al,%sil
  800e1e:	74 1f                	je     800e3f <strchr+0x2d>
  for (; *s; s++)
  800e20:	48 83 c7 01          	add    $0x1,%rdi
  800e24:	0f b6 07             	movzbl (%rdi),%eax
  800e27:	84 c0                	test   %al,%al
  800e29:	74 08                	je     800e33 <strchr+0x21>
    if (*s == c)
  800e2b:	38 d0                	cmp    %dl,%al
  800e2d:	75 f1                	jne    800e20 <strchr+0xe>
  for (; *s; s++)
  800e2f:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e32:	c3                   	retq   
  return 0;
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
  800e38:	c3                   	retq   
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	c3                   	retq   
    if (*s == c)
  800e3f:	48 89 f8             	mov    %rdi,%rax
  800e42:	c3                   	retq   

0000000000800e43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e43:	48 89 f8             	mov    %rdi,%rax
  800e46:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e48:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e4b:	40 38 f2             	cmp    %sil,%dl
  800e4e:	74 13                	je     800e63 <strfind+0x20>
  800e50:	84 d2                	test   %dl,%dl
  800e52:	74 0f                	je     800e63 <strfind+0x20>
  for (; *s; s++)
  800e54:	48 83 c0 01          	add    $0x1,%rax
  800e58:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e5b:	38 ca                	cmp    %cl,%dl
  800e5d:	74 04                	je     800e63 <strfind+0x20>
  800e5f:	84 d2                	test   %dl,%dl
  800e61:	75 f1                	jne    800e54 <strfind+0x11>
      break;
  return (char *)s;
}
  800e63:	c3                   	retq   

0000000000800e64 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e64:	48 85 d2             	test   %rdx,%rdx
  800e67:	74 3a                	je     800ea3 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e69:	48 89 f8             	mov    %rdi,%rax
  800e6c:	48 09 d0             	or     %rdx,%rax
  800e6f:	a8 03                	test   $0x3,%al
  800e71:	75 28                	jne    800e9b <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e73:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e77:	89 f0                	mov    %esi,%eax
  800e79:	c1 e0 08             	shl    $0x8,%eax
  800e7c:	89 f1                	mov    %esi,%ecx
  800e7e:	c1 e1 18             	shl    $0x18,%ecx
  800e81:	41 89 f0             	mov    %esi,%r8d
  800e84:	41 c1 e0 10          	shl    $0x10,%r8d
  800e88:	44 09 c1             	or     %r8d,%ecx
  800e8b:	09 ce                	or     %ecx,%esi
  800e8d:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800e8f:	48 c1 ea 02          	shr    $0x2,%rdx
  800e93:	48 89 d1             	mov    %rdx,%rcx
  800e96:	fc                   	cld    
  800e97:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e99:	eb 08                	jmp    800ea3 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800e9b:	89 f0                	mov    %esi,%eax
  800e9d:	48 89 d1             	mov    %rdx,%rcx
  800ea0:	fc                   	cld    
  800ea1:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ea3:	48 89 f8             	mov    %rdi,%rax
  800ea6:	c3                   	retq   

0000000000800ea7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ea7:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800eaa:	48 39 fe             	cmp    %rdi,%rsi
  800ead:	73 40                	jae    800eef <memmove+0x48>
  800eaf:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800eb3:	48 39 f9             	cmp    %rdi,%rcx
  800eb6:	76 37                	jbe    800eef <memmove+0x48>
    s += n;
    d += n;
  800eb8:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ebc:	48 89 fe             	mov    %rdi,%rsi
  800ebf:	48 09 d6             	or     %rdx,%rsi
  800ec2:	48 09 ce             	or     %rcx,%rsi
  800ec5:	40 f6 c6 03          	test   $0x3,%sil
  800ec9:	75 14                	jne    800edf <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800ecb:	48 83 ef 04          	sub    $0x4,%rdi
  800ecf:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ed3:	48 c1 ea 02          	shr    $0x2,%rdx
  800ed7:	48 89 d1             	mov    %rdx,%rcx
  800eda:	fd                   	std    
  800edb:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800edd:	eb 0e                	jmp    800eed <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800edf:	48 83 ef 01          	sub    $0x1,%rdi
  800ee3:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800ee7:	48 89 d1             	mov    %rdx,%rcx
  800eea:	fd                   	std    
  800eeb:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800eed:	fc                   	cld    
  800eee:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800eef:	48 89 c1             	mov    %rax,%rcx
  800ef2:	48 09 d1             	or     %rdx,%rcx
  800ef5:	48 09 f1             	or     %rsi,%rcx
  800ef8:	f6 c1 03             	test   $0x3,%cl
  800efb:	75 0e                	jne    800f0b <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800efd:	48 c1 ea 02          	shr    $0x2,%rdx
  800f01:	48 89 d1             	mov    %rdx,%rcx
  800f04:	48 89 c7             	mov    %rax,%rdi
  800f07:	fc                   	cld    
  800f08:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f0a:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f0b:	48 89 c7             	mov    %rax,%rdi
  800f0e:	48 89 d1             	mov    %rdx,%rcx
  800f11:	fc                   	cld    
  800f12:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f14:	c3                   	retq   

0000000000800f15 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f15:	55                   	push   %rbp
  800f16:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f19:	48 b8 a7 0e 80 00 00 	movabs $0x800ea7,%rax
  800f20:	00 00 00 
  800f23:	ff d0                	callq  *%rax
}
  800f25:	5d                   	pop    %rbp
  800f26:	c3                   	retq   

0000000000800f27 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f27:	55                   	push   %rbp
  800f28:	48 89 e5             	mov    %rsp,%rbp
  800f2b:	41 57                	push   %r15
  800f2d:	41 56                	push   %r14
  800f2f:	41 55                	push   %r13
  800f31:	41 54                	push   %r12
  800f33:	53                   	push   %rbx
  800f34:	48 83 ec 08          	sub    $0x8,%rsp
  800f38:	49 89 fe             	mov    %rdi,%r14
  800f3b:	49 89 f7             	mov    %rsi,%r15
  800f3e:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f41:	48 89 f7             	mov    %rsi,%rdi
  800f44:	48 b8 9c 0c 80 00 00 	movabs $0x800c9c,%rax
  800f4b:	00 00 00 
  800f4e:	ff d0                	callq  *%rax
  800f50:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f53:	4c 89 ee             	mov    %r13,%rsi
  800f56:	4c 89 f7             	mov    %r14,%rdi
  800f59:	48 b8 be 0c 80 00 00 	movabs $0x800cbe,%rax
  800f60:	00 00 00 
  800f63:	ff d0                	callq  *%rax
  800f65:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f68:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f6c:	4d 39 e5             	cmp    %r12,%r13
  800f6f:	74 26                	je     800f97 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f71:	4c 89 e8             	mov    %r13,%rax
  800f74:	4c 29 e0             	sub    %r12,%rax
  800f77:	48 39 d8             	cmp    %rbx,%rax
  800f7a:	76 2a                	jbe    800fa6 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f7c:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f80:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f84:	4c 89 fe             	mov    %r15,%rsi
  800f87:	48 b8 15 0f 80 00 00 	movabs $0x800f15,%rax
  800f8e:	00 00 00 
  800f91:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800f93:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800f97:	48 83 c4 08          	add    $0x8,%rsp
  800f9b:	5b                   	pop    %rbx
  800f9c:	41 5c                	pop    %r12
  800f9e:	41 5d                	pop    %r13
  800fa0:	41 5e                	pop    %r14
  800fa2:	41 5f                	pop    %r15
  800fa4:	5d                   	pop    %rbp
  800fa5:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fa6:	49 83 ed 01          	sub    $0x1,%r13
  800faa:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fae:	4c 89 ea             	mov    %r13,%rdx
  800fb1:	4c 89 fe             	mov    %r15,%rsi
  800fb4:	48 b8 15 0f 80 00 00 	movabs $0x800f15,%rax
  800fbb:	00 00 00 
  800fbe:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fc0:	4d 01 ee             	add    %r13,%r14
  800fc3:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fc8:	eb c9                	jmp    800f93 <strlcat+0x6c>

0000000000800fca <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fca:	48 85 d2             	test   %rdx,%rdx
  800fcd:	74 3a                	je     801009 <memcmp+0x3f>
    if (*s1 != *s2)
  800fcf:	0f b6 0f             	movzbl (%rdi),%ecx
  800fd2:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fd6:	44 38 c1             	cmp    %r8b,%cl
  800fd9:	75 1d                	jne    800ff8 <memcmp+0x2e>
  800fdb:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fe0:	48 39 d0             	cmp    %rdx,%rax
  800fe3:	74 1e                	je     801003 <memcmp+0x39>
    if (*s1 != *s2)
  800fe5:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800fe9:	48 83 c0 01          	add    $0x1,%rax
  800fed:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800ff3:	44 38 c1             	cmp    %r8b,%cl
  800ff6:	74 e8                	je     800fe0 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800ff8:	0f b6 c1             	movzbl %cl,%eax
  800ffb:	45 0f b6 c0          	movzbl %r8b,%r8d
  800fff:	44 29 c0             	sub    %r8d,%eax
  801002:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	c3                   	retq   
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100e:	c3                   	retq   

000000000080100f <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80100f:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801013:	48 39 c7             	cmp    %rax,%rdi
  801016:	73 19                	jae    801031 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801018:	89 f2                	mov    %esi,%edx
  80101a:	40 38 37             	cmp    %sil,(%rdi)
  80101d:	74 16                	je     801035 <memfind+0x26>
  for (; s < ends; s++)
  80101f:	48 83 c7 01          	add    $0x1,%rdi
  801023:	48 39 f8             	cmp    %rdi,%rax
  801026:	74 08                	je     801030 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801028:	38 17                	cmp    %dl,(%rdi)
  80102a:	75 f3                	jne    80101f <memfind+0x10>
  for (; s < ends; s++)
  80102c:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80102f:	c3                   	retq   
  801030:	c3                   	retq   
  for (; s < ends; s++)
  801031:	48 89 f8             	mov    %rdi,%rax
  801034:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801035:	48 89 f8             	mov    %rdi,%rax
  801038:	c3                   	retq   

0000000000801039 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801039:	0f b6 07             	movzbl (%rdi),%eax
  80103c:	3c 20                	cmp    $0x20,%al
  80103e:	74 04                	je     801044 <strtol+0xb>
  801040:	3c 09                	cmp    $0x9,%al
  801042:	75 0f                	jne    801053 <strtol+0x1a>
    s++;
  801044:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801048:	0f b6 07             	movzbl (%rdi),%eax
  80104b:	3c 20                	cmp    $0x20,%al
  80104d:	74 f5                	je     801044 <strtol+0xb>
  80104f:	3c 09                	cmp    $0x9,%al
  801051:	74 f1                	je     801044 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801053:	3c 2b                	cmp    $0x2b,%al
  801055:	74 2b                	je     801082 <strtol+0x49>
  int neg  = 0;
  801057:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80105d:	3c 2d                	cmp    $0x2d,%al
  80105f:	74 2d                	je     80108e <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801061:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801067:	75 0f                	jne    801078 <strtol+0x3f>
  801069:	80 3f 30             	cmpb   $0x30,(%rdi)
  80106c:	74 2c                	je     80109a <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80106e:	85 d2                	test   %edx,%edx
  801070:	b8 0a 00 00 00       	mov    $0xa,%eax
  801075:	0f 44 d0             	cmove  %eax,%edx
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80107d:	4c 63 d2             	movslq %edx,%r10
  801080:	eb 5c                	jmp    8010de <strtol+0xa5>
    s++;
  801082:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801086:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80108c:	eb d3                	jmp    801061 <strtol+0x28>
    s++, neg = 1;
  80108e:	48 83 c7 01          	add    $0x1,%rdi
  801092:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801098:	eb c7                	jmp    801061 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80109a:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80109e:	74 0f                	je     8010af <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010a0:	85 d2                	test   %edx,%edx
  8010a2:	75 d4                	jne    801078 <strtol+0x3f>
    s++, base = 8;
  8010a4:	48 83 c7 01          	add    $0x1,%rdi
  8010a8:	ba 08 00 00 00       	mov    $0x8,%edx
  8010ad:	eb c9                	jmp    801078 <strtol+0x3f>
    s += 2, base = 16;
  8010af:	48 83 c7 02          	add    $0x2,%rdi
  8010b3:	ba 10 00 00 00       	mov    $0x10,%edx
  8010b8:	eb be                	jmp    801078 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010ba:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010be:	41 80 f8 19          	cmp    $0x19,%r8b
  8010c2:	77 2f                	ja     8010f3 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010c4:	44 0f be c1          	movsbl %cl,%r8d
  8010c8:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010cc:	39 d1                	cmp    %edx,%ecx
  8010ce:	7d 37                	jge    801107 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010d0:	48 83 c7 01          	add    $0x1,%rdi
  8010d4:	49 0f af c2          	imul   %r10,%rax
  8010d8:	48 63 c9             	movslq %ecx,%rcx
  8010db:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010de:	0f b6 0f             	movzbl (%rdi),%ecx
  8010e1:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010e5:	41 80 f8 09          	cmp    $0x9,%r8b
  8010e9:	77 cf                	ja     8010ba <strtol+0x81>
      dig = *s - '0';
  8010eb:	0f be c9             	movsbl %cl,%ecx
  8010ee:	83 e9 30             	sub    $0x30,%ecx
  8010f1:	eb d9                	jmp    8010cc <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8010f3:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8010f7:	41 80 f8 19          	cmp    $0x19,%r8b
  8010fb:	77 0a                	ja     801107 <strtol+0xce>
      dig = *s - 'A' + 10;
  8010fd:	44 0f be c1          	movsbl %cl,%r8d
  801101:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801105:	eb c5                	jmp    8010cc <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801107:	48 85 f6             	test   %rsi,%rsi
  80110a:	74 03                	je     80110f <strtol+0xd6>
    *endptr = (char *)s;
  80110c:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80110f:	48 89 c2             	mov    %rax,%rdx
  801112:	48 f7 da             	neg    %rdx
  801115:	45 85 c9             	test   %r9d,%r9d
  801118:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80111c:	c3                   	retq   
  80111d:	0f 1f 00             	nopl   (%rax)
