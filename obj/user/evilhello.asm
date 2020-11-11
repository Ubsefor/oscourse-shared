
obj/user/evilhello:     file format elf64-x86-64


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
  800023:	e8 23 00 00 00       	callq  80004b <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// kernel should destroy user environment in response

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  // try to print the kernel entry point as a string!  mua ha ha!
  sys_cputs((char *)0x804020000c, 100);
  80002e:	be 64 00 00 00       	mov    $0x64,%esi
  800033:	48 bf 0c 00 20 40 80 	movabs $0x804020000c,%rdi
  80003a:	00 00 00 
  80003d:	48 b8 e8 00 80 00 00 	movabs $0x8000e8,%rax
  800044:	00 00 00 
  800047:	ff d0                	callq  *%rax
}
  800049:	5d                   	pop    %rbp
  80004a:	c3                   	retq   

000000000080004b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80004b:	55                   	push   %rbp
  80004c:	48 89 e5             	mov    %rsp,%rbp
  80004f:	41 56                	push   %r14
  800051:	41 55                	push   %r13
  800053:	41 54                	push   %r12
  800055:	53                   	push   %rbx
  800056:	41 89 fd             	mov    %edi,%r13d
  800059:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80005c:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800063:	00 00 00 
  800066:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80006d:	00 00 00 
  800070:	48 39 c2             	cmp    %rax,%rdx
  800073:	73 23                	jae    800098 <libmain+0x4d>
  800075:	48 89 d3             	mov    %rdx,%rbx
  800078:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80007c:	48 29 d0             	sub    %rdx,%rax
  80007f:	48 c1 e8 03          	shr    $0x3,%rax
  800083:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800088:	b8 00 00 00 00       	mov    $0x0,%eax
  80008d:	ff 13                	callq  *(%rbx)
    ctor++;
  80008f:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800093:	4c 39 e3             	cmp    %r12,%rbx
  800096:	75 f0                	jne    800088 <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800098:	45 85 ed             	test   %r13d,%r13d
  80009b:	7e 0d                	jle    8000aa <libmain+0x5f>
    binaryname = argv[0];
  80009d:	49 8b 06             	mov    (%r14),%rax
  8000a0:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000a7:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000aa:	4c 89 f6             	mov    %r14,%rsi
  8000ad:	44 89 ef             	mov    %r13d,%edi
  8000b0:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000b7:	00 00 00 
  8000ba:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000bc:	48 b8 d1 00 80 00 00 	movabs $0x8000d1,%rax
  8000c3:	00 00 00 
  8000c6:	ff d0                	callq  *%rax
#endif
}
  8000c8:	5b                   	pop    %rbx
  8000c9:	41 5c                	pop    %r12
  8000cb:	41 5d                	pop    %r13
  8000cd:	41 5e                	pop    %r14
  8000cf:	5d                   	pop    %rbp
  8000d0:	c3                   	retq   

00000000008000d1 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000d1:	55                   	push   %rbp
  8000d2:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000d5:	bf 00 00 00 00       	mov    $0x0,%edi
  8000da:	48 b8 26 01 80 00 00 	movabs $0x800126,%rax
  8000e1:	00 00 00 
  8000e4:	ff d0                	callq  *%rax
}
  8000e6:	5d                   	pop    %rbp
  8000e7:	c3                   	retq   

00000000008000e8 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000e8:	55                   	push   %rbp
  8000e9:	48 89 e5             	mov    %rsp,%rbp
  8000ec:	53                   	push   %rbx
  8000ed:	48 89 fa             	mov    %rdi,%rdx
  8000f0:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f8:	48 89 c3             	mov    %rax,%rbx
  8000fb:	48 89 c7             	mov    %rax,%rdi
  8000fe:	48 89 c6             	mov    %rax,%rsi
  800101:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800103:	5b                   	pop    %rbx
  800104:	5d                   	pop    %rbp
  800105:	c3                   	retq   

0000000000800106 <sys_cgetc>:

int
sys_cgetc(void) {
  800106:	55                   	push   %rbp
  800107:	48 89 e5             	mov    %rsp,%rbp
  80010a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 01 00 00 00       	mov    $0x1,%eax
  800115:	48 89 ca             	mov    %rcx,%rdx
  800118:	48 89 cb             	mov    %rcx,%rbx
  80011b:	48 89 cf             	mov    %rcx,%rdi
  80011e:	48 89 ce             	mov    %rcx,%rsi
  800121:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800123:	5b                   	pop    %rbx
  800124:	5d                   	pop    %rbp
  800125:	c3                   	retq   

0000000000800126 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800126:	55                   	push   %rbp
  800127:	48 89 e5             	mov    %rsp,%rbp
  80012a:	53                   	push   %rbx
  80012b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80012f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800132:	be 00 00 00 00       	mov    $0x0,%esi
  800137:	b8 03 00 00 00       	mov    $0x3,%eax
  80013c:	48 89 f1             	mov    %rsi,%rcx
  80013f:	48 89 f3             	mov    %rsi,%rbx
  800142:	48 89 f7             	mov    %rsi,%rdi
  800145:	cd 30                	int    $0x30
  if (check && ret > 0)
  800147:	48 85 c0             	test   %rax,%rax
  80014a:	7f 07                	jg     800153 <sys_env_destroy+0x2d>
}
  80014c:	48 83 c4 08          	add    $0x8,%rsp
  800150:	5b                   	pop    %rbx
  800151:	5d                   	pop    %rbp
  800152:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800153:	49 89 c0             	mov    %rax,%r8
  800156:	b9 03 00 00 00       	mov    $0x3,%ecx
  80015b:	48 ba 50 11 80 00 00 	movabs $0x801150,%rdx
  800162:	00 00 00 
  800165:	be 22 00 00 00       	mov    $0x22,%esi
  80016a:	48 bf 6f 11 80 00 00 	movabs $0x80116f,%rdi
  800171:	00 00 00 
  800174:	b8 00 00 00 00       	mov    $0x0,%eax
  800179:	49 b9 a6 01 80 00 00 	movabs $0x8001a6,%r9
  800180:	00 00 00 
  800183:	41 ff d1             	callq  *%r9

0000000000800186 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800186:	55                   	push   %rbp
  800187:	48 89 e5             	mov    %rsp,%rbp
  80018a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80018b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800190:	b8 02 00 00 00       	mov    $0x2,%eax
  800195:	48 89 ca             	mov    %rcx,%rdx
  800198:	48 89 cb             	mov    %rcx,%rbx
  80019b:	48 89 cf             	mov    %rcx,%rdi
  80019e:	48 89 ce             	mov    %rcx,%rsi
  8001a1:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001a3:	5b                   	pop    %rbx
  8001a4:	5d                   	pop    %rbp
  8001a5:	c3                   	retq   

00000000008001a6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001a6:	55                   	push   %rbp
  8001a7:	48 89 e5             	mov    %rsp,%rbp
  8001aa:	41 56                	push   %r14
  8001ac:	41 55                	push   %r13
  8001ae:	41 54                	push   %r12
  8001b0:	53                   	push   %rbx
  8001b1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001b8:	49 89 fd             	mov    %rdi,%r13
  8001bb:	41 89 f6             	mov    %esi,%r14d
  8001be:	49 89 d4             	mov    %rdx,%r12
  8001c1:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001c8:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001cf:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001d6:	84 c0                	test   %al,%al
  8001d8:	74 26                	je     800200 <_panic+0x5a>
  8001da:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001e1:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001e8:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001ec:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001f0:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001f4:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001f8:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001fc:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800200:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800207:	00 00 00 
  80020a:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800211:	00 00 00 
  800214:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800218:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80021f:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800226:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80022d:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800234:	00 00 00 
  800237:	48 8b 18             	mov    (%rax),%rbx
  80023a:	48 b8 86 01 80 00 00 	movabs $0x800186,%rax
  800241:	00 00 00 
  800244:	ff d0                	callq  *%rax
  800246:	45 89 f0             	mov    %r14d,%r8d
  800249:	4c 89 e9             	mov    %r13,%rcx
  80024c:	48 89 da             	mov    %rbx,%rdx
  80024f:	89 c6                	mov    %eax,%esi
  800251:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  800258:	00 00 00 
  80025b:	b8 00 00 00 00       	mov    $0x0,%eax
  800260:	48 bb 48 03 80 00 00 	movabs $0x800348,%rbx
  800267:	00 00 00 
  80026a:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80026c:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800273:	4c 89 e7             	mov    %r12,%rdi
  800276:	48 b8 e0 02 80 00 00 	movabs $0x8002e0,%rax
  80027d:	00 00 00 
  800280:	ff d0                	callq  *%rax
  cprintf("\n");
  800282:	48 bf a8 11 80 00 00 	movabs $0x8011a8,%rdi
  800289:	00 00 00 
  80028c:	b8 00 00 00 00       	mov    $0x0,%eax
  800291:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800293:	cc                   	int3   
  while (1)
  800294:	eb fd                	jmp    800293 <_panic+0xed>

0000000000800296 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800296:	55                   	push   %rbp
  800297:	48 89 e5             	mov    %rsp,%rbp
  80029a:	53                   	push   %rbx
  80029b:	48 83 ec 08          	sub    $0x8,%rsp
  80029f:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002a2:	8b 06                	mov    (%rsi),%eax
  8002a4:	8d 50 01             	lea    0x1(%rax),%edx
  8002a7:	89 16                	mov    %edx,(%rsi)
  8002a9:	48 98                	cltq   
  8002ab:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002b0:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002b6:	74 0b                	je     8002c3 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002b8:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002bc:	48 83 c4 08          	add    $0x8,%rsp
  8002c0:	5b                   	pop    %rbx
  8002c1:	5d                   	pop    %rbp
  8002c2:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002c3:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002c7:	be ff 00 00 00       	mov    $0xff,%esi
  8002cc:	48 b8 e8 00 80 00 00 	movabs $0x8000e8,%rax
  8002d3:	00 00 00 
  8002d6:	ff d0                	callq  *%rax
    b->idx = 0;
  8002d8:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002de:	eb d8                	jmp    8002b8 <putch+0x22>

00000000008002e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002e0:	55                   	push   %rbp
  8002e1:	48 89 e5             	mov    %rsp,%rbp
  8002e4:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002eb:	48 89 fa             	mov    %rdi,%rdx
  8002ee:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002f8:	00 00 00 
  b.cnt = 0;
  8002fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800302:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800305:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80030c:	48 bf 96 02 80 00 00 	movabs $0x800296,%rdi
  800313:	00 00 00 
  800316:	48 b8 06 05 80 00 00 	movabs $0x800506,%rax
  80031d:	00 00 00 
  800320:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800322:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800329:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800330:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800334:	48 b8 e8 00 80 00 00 	movabs $0x8000e8,%rax
  80033b:	00 00 00 
  80033e:	ff d0                	callq  *%rax

  return b.cnt;
}
  800340:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800346:	c9                   	leaveq 
  800347:	c3                   	retq   

0000000000800348 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800348:	55                   	push   %rbp
  800349:	48 89 e5             	mov    %rsp,%rbp
  80034c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800353:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80035a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800361:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800368:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80036f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800376:	84 c0                	test   %al,%al
  800378:	74 20                	je     80039a <cprintf+0x52>
  80037a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80037e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800382:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800386:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80038a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80038e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800392:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800396:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80039a:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003a1:	00 00 00 
  8003a4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003ab:	00 00 00 
  8003ae:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003b2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003b9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003c0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003c7:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003ce:	48 b8 e0 02 80 00 00 	movabs $0x8002e0,%rax
  8003d5:	00 00 00 
  8003d8:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003da:	c9                   	leaveq 
  8003db:	c3                   	retq   

00000000008003dc <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003dc:	55                   	push   %rbp
  8003dd:	48 89 e5             	mov    %rsp,%rbp
  8003e0:	41 57                	push   %r15
  8003e2:	41 56                	push   %r14
  8003e4:	41 55                	push   %r13
  8003e6:	41 54                	push   %r12
  8003e8:	53                   	push   %rbx
  8003e9:	48 83 ec 18          	sub    $0x18,%rsp
  8003ed:	49 89 fc             	mov    %rdi,%r12
  8003f0:	49 89 f5             	mov    %rsi,%r13
  8003f3:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003f7:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003fa:	41 89 cf             	mov    %ecx,%r15d
  8003fd:	49 39 d7             	cmp    %rdx,%r15
  800400:	76 45                	jbe    800447 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800402:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800406:	85 db                	test   %ebx,%ebx
  800408:	7e 0e                	jle    800418 <printnum+0x3c>
      putch(padc, putdat);
  80040a:	4c 89 ee             	mov    %r13,%rsi
  80040d:	44 89 f7             	mov    %r14d,%edi
  800410:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800413:	83 eb 01             	sub    $0x1,%ebx
  800416:	75 f2                	jne    80040a <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800418:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80041c:	ba 00 00 00 00       	mov    $0x0,%edx
  800421:	49 f7 f7             	div    %r15
  800424:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  80042b:	00 00 00 
  80042e:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800432:	4c 89 ee             	mov    %r13,%rsi
  800435:	41 ff d4             	callq  *%r12
}
  800438:	48 83 c4 18          	add    $0x18,%rsp
  80043c:	5b                   	pop    %rbx
  80043d:	41 5c                	pop    %r12
  80043f:	41 5d                	pop    %r13
  800441:	41 5e                	pop    %r14
  800443:	41 5f                	pop    %r15
  800445:	5d                   	pop    %rbp
  800446:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800447:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	49 f7 f7             	div    %r15
  800453:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800457:	48 89 c2             	mov    %rax,%rdx
  80045a:	48 b8 dc 03 80 00 00 	movabs $0x8003dc,%rax
  800461:	00 00 00 
  800464:	ff d0                	callq  *%rax
  800466:	eb b0                	jmp    800418 <printnum+0x3c>

0000000000800468 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800468:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80046c:	48 8b 06             	mov    (%rsi),%rax
  80046f:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800473:	73 0a                	jae    80047f <sprintputch+0x17>
    *b->buf++ = ch;
  800475:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800479:	48 89 16             	mov    %rdx,(%rsi)
  80047c:	40 88 38             	mov    %dil,(%rax)
}
  80047f:	c3                   	retq   

0000000000800480 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800480:	55                   	push   %rbp
  800481:	48 89 e5             	mov    %rsp,%rbp
  800484:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80048b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800492:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800499:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004a0:	84 c0                	test   %al,%al
  8004a2:	74 20                	je     8004c4 <printfmt+0x44>
  8004a4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004a8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004ac:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004b0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004b4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004b8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004bc:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004c0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004c4:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004cb:	00 00 00 
  8004ce:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004d5:	00 00 00 
  8004d8:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004dc:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004e3:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004ea:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004f1:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004f8:	48 b8 06 05 80 00 00 	movabs $0x800506,%rax
  8004ff:	00 00 00 
  800502:	ff d0                	callq  *%rax
}
  800504:	c9                   	leaveq 
  800505:	c3                   	retq   

0000000000800506 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800506:	55                   	push   %rbp
  800507:	48 89 e5             	mov    %rsp,%rbp
  80050a:	41 57                	push   %r15
  80050c:	41 56                	push   %r14
  80050e:	41 55                	push   %r13
  800510:	41 54                	push   %r12
  800512:	53                   	push   %rbx
  800513:	48 83 ec 48          	sub    $0x48,%rsp
  800517:	49 89 fd             	mov    %rdi,%r13
  80051a:	49 89 f7             	mov    %rsi,%r15
  80051d:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800520:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800524:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800528:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80052c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800530:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800534:	41 0f b6 3e          	movzbl (%r14),%edi
  800538:	83 ff 25             	cmp    $0x25,%edi
  80053b:	74 18                	je     800555 <vprintfmt+0x4f>
      if (ch == '\0')
  80053d:	85 ff                	test   %edi,%edi
  80053f:	0f 84 8c 06 00 00    	je     800bd1 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800545:	4c 89 fe             	mov    %r15,%rsi
  800548:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80054b:	49 89 de             	mov    %rbx,%r14
  80054e:	eb e0                	jmp    800530 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800550:	49 89 de             	mov    %rbx,%r14
  800553:	eb db                	jmp    800530 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800555:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800559:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80055d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800564:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80056a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800573:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800579:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80057f:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800584:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800589:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80058d:	0f b6 13             	movzbl (%rbx),%edx
  800590:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800593:	3c 55                	cmp    $0x55,%al
  800595:	0f 87 8b 05 00 00    	ja     800b26 <vprintfmt+0x620>
  80059b:	0f b6 c0             	movzbl %al,%eax
  80059e:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  8005a5:	00 00 00 
  8005a8:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005ac:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005af:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005b3:	eb d4                	jmp    800589 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005b5:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005b8:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005bc:	eb cb                	jmp    800589 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005be:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005c1:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005c5:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005c9:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005cc:	83 fa 09             	cmp    $0x9,%edx
  8005cf:	77 7e                	ja     80064f <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005d1:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005d5:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005d9:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005de:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005e2:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005e5:	83 fa 09             	cmp    $0x9,%edx
  8005e8:	76 e7                	jbe    8005d1 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005ea:	4c 89 f3             	mov    %r14,%rbx
  8005ed:	eb 19                	jmp    800608 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005ef:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005f2:	83 f8 2f             	cmp    $0x2f,%eax
  8005f5:	77 2a                	ja     800621 <vprintfmt+0x11b>
  8005f7:	89 c2                	mov    %eax,%edx
  8005f9:	4c 01 d2             	add    %r10,%rdx
  8005fc:	83 c0 08             	add    $0x8,%eax
  8005ff:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800602:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800605:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800608:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80060c:	0f 89 77 ff ff ff    	jns    800589 <vprintfmt+0x83>
          width = precision, precision = -1;
  800612:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800616:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80061c:	e9 68 ff ff ff       	jmpq   800589 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800621:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800625:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800629:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80062d:	eb d3                	jmp    800602 <vprintfmt+0xfc>
        if (width < 0)
  80062f:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800632:	85 c0                	test   %eax,%eax
  800634:	41 0f 48 c0          	cmovs  %r8d,%eax
  800638:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80063b:	4c 89 f3             	mov    %r14,%rbx
  80063e:	e9 46 ff ff ff       	jmpq   800589 <vprintfmt+0x83>
  800643:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800646:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80064a:	e9 3a ff ff ff       	jmpq   800589 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80064f:	4c 89 f3             	mov    %r14,%rbx
  800652:	eb b4                	jmp    800608 <vprintfmt+0x102>
        lflag++;
  800654:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800657:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80065a:	e9 2a ff ff ff       	jmpq   800589 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80065f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800662:	83 f8 2f             	cmp    $0x2f,%eax
  800665:	77 19                	ja     800680 <vprintfmt+0x17a>
  800667:	89 c2                	mov    %eax,%edx
  800669:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80066d:	83 c0 08             	add    $0x8,%eax
  800670:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800673:	4c 89 fe             	mov    %r15,%rsi
  800676:	8b 3a                	mov    (%rdx),%edi
  800678:	41 ff d5             	callq  *%r13
        break;
  80067b:	e9 b0 fe ff ff       	jmpq   800530 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800680:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800684:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800688:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80068c:	eb e5                	jmp    800673 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80068e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800691:	83 f8 2f             	cmp    $0x2f,%eax
  800694:	77 5b                	ja     8006f1 <vprintfmt+0x1eb>
  800696:	89 c2                	mov    %eax,%edx
  800698:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80069c:	83 c0 08             	add    $0x8,%eax
  80069f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006a2:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006a4:	89 c8                	mov    %ecx,%eax
  8006a6:	c1 f8 1f             	sar    $0x1f,%eax
  8006a9:	31 c1                	xor    %eax,%ecx
  8006ab:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ad:	83 f9 09             	cmp    $0x9,%ecx
  8006b0:	7f 4d                	jg     8006ff <vprintfmt+0x1f9>
  8006b2:	48 63 c1             	movslq %ecx,%rax
  8006b5:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  8006bc:	00 00 00 
  8006bf:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006c3:	48 85 c0             	test   %rax,%rax
  8006c6:	74 37                	je     8006ff <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006c8:	48 89 c1             	mov    %rax,%rcx
  8006cb:	48 ba cb 11 80 00 00 	movabs $0x8011cb,%rdx
  8006d2:	00 00 00 
  8006d5:	4c 89 fe             	mov    %r15,%rsi
  8006d8:	4c 89 ef             	mov    %r13,%rdi
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e0:	48 bb 80 04 80 00 00 	movabs $0x800480,%rbx
  8006e7:	00 00 00 
  8006ea:	ff d3                	callq  *%rbx
  8006ec:	e9 3f fe ff ff       	jmpq   800530 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006f1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006f5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006f9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006fd:	eb a3                	jmp    8006a2 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006ff:	48 ba c2 11 80 00 00 	movabs $0x8011c2,%rdx
  800706:	00 00 00 
  800709:	4c 89 fe             	mov    %r15,%rsi
  80070c:	4c 89 ef             	mov    %r13,%rdi
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	48 bb 80 04 80 00 00 	movabs $0x800480,%rbx
  80071b:	00 00 00 
  80071e:	ff d3                	callq  *%rbx
  800720:	e9 0b fe ff ff       	jmpq   800530 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800725:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800728:	83 f8 2f             	cmp    $0x2f,%eax
  80072b:	77 4b                	ja     800778 <vprintfmt+0x272>
  80072d:	89 c2                	mov    %eax,%edx
  80072f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800733:	83 c0 08             	add    $0x8,%eax
  800736:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800739:	48 8b 02             	mov    (%rdx),%rax
  80073c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800740:	48 85 c0             	test   %rax,%rax
  800743:	0f 84 05 04 00 00    	je     800b4e <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800749:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80074d:	7e 06                	jle    800755 <vprintfmt+0x24f>
  80074f:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800753:	75 31                	jne    800786 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800755:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800759:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80075d:	0f b6 00             	movzbl (%rax),%eax
  800760:	0f be f8             	movsbl %al,%edi
  800763:	85 ff                	test   %edi,%edi
  800765:	0f 84 c3 00 00 00    	je     80082e <vprintfmt+0x328>
  80076b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80076f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800773:	e9 85 00 00 00       	jmpq   8007fd <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800778:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80077c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800780:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800784:	eb b3                	jmp    800739 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800786:	49 63 f4             	movslq %r12d,%rsi
  800789:	48 89 c7             	mov    %rax,%rdi
  80078c:	48 b8 dd 0c 80 00 00 	movabs $0x800cdd,%rax
  800793:	00 00 00 
  800796:	ff d0                	callq  *%rax
  800798:	29 45 ac             	sub    %eax,-0x54(%rbp)
  80079b:	8b 75 ac             	mov    -0x54(%rbp),%esi
  80079e:	85 f6                	test   %esi,%esi
  8007a0:	7e 22                	jle    8007c4 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007a2:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007a6:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007aa:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007ae:	4c 89 fe             	mov    %r15,%rsi
  8007b1:	89 df                	mov    %ebx,%edi
  8007b3:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007b6:	41 83 ec 01          	sub    $0x1,%r12d
  8007ba:	75 f2                	jne    8007ae <vprintfmt+0x2a8>
  8007bc:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007c0:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007c8:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007cc:	0f b6 00             	movzbl (%rax),%eax
  8007cf:	0f be f8             	movsbl %al,%edi
  8007d2:	85 ff                	test   %edi,%edi
  8007d4:	0f 84 56 fd ff ff    	je     800530 <vprintfmt+0x2a>
  8007da:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007de:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007e2:	eb 19                	jmp    8007fd <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007e4:	4c 89 fe             	mov    %r15,%rsi
  8007e7:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ea:	41 83 ee 01          	sub    $0x1,%r14d
  8007ee:	48 83 c3 01          	add    $0x1,%rbx
  8007f2:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007f6:	0f be f8             	movsbl %al,%edi
  8007f9:	85 ff                	test   %edi,%edi
  8007fb:	74 29                	je     800826 <vprintfmt+0x320>
  8007fd:	45 85 e4             	test   %r12d,%r12d
  800800:	78 06                	js     800808 <vprintfmt+0x302>
  800802:	41 83 ec 01          	sub    $0x1,%r12d
  800806:	78 48                	js     800850 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800808:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80080c:	74 d6                	je     8007e4 <vprintfmt+0x2de>
  80080e:	0f be c0             	movsbl %al,%eax
  800811:	83 e8 20             	sub    $0x20,%eax
  800814:	83 f8 5e             	cmp    $0x5e,%eax
  800817:	76 cb                	jbe    8007e4 <vprintfmt+0x2de>
            putch('?', putdat);
  800819:	4c 89 fe             	mov    %r15,%rsi
  80081c:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800821:	41 ff d5             	callq  *%r13
  800824:	eb c4                	jmp    8007ea <vprintfmt+0x2e4>
  800826:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80082a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80082e:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800831:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800835:	0f 8e f5 fc ff ff    	jle    800530 <vprintfmt+0x2a>
          putch(' ', putdat);
  80083b:	4c 89 fe             	mov    %r15,%rsi
  80083e:	bf 20 00 00 00       	mov    $0x20,%edi
  800843:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800846:	83 eb 01             	sub    $0x1,%ebx
  800849:	75 f0                	jne    80083b <vprintfmt+0x335>
  80084b:	e9 e0 fc ff ff       	jmpq   800530 <vprintfmt+0x2a>
  800850:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800854:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800858:	eb d4                	jmp    80082e <vprintfmt+0x328>
  if (lflag >= 2)
  80085a:	83 f9 01             	cmp    $0x1,%ecx
  80085d:	7f 1d                	jg     80087c <vprintfmt+0x376>
  else if (lflag)
  80085f:	85 c9                	test   %ecx,%ecx
  800861:	74 5e                	je     8008c1 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800863:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800866:	83 f8 2f             	cmp    $0x2f,%eax
  800869:	77 48                	ja     8008b3 <vprintfmt+0x3ad>
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800871:	83 c0 08             	add    $0x8,%eax
  800874:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800877:	48 8b 1a             	mov    (%rdx),%rbx
  80087a:	eb 17                	jmp    800893 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80087c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80087f:	83 f8 2f             	cmp    $0x2f,%eax
  800882:	77 21                	ja     8008a5 <vprintfmt+0x39f>
  800884:	89 c2                	mov    %eax,%edx
  800886:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80088a:	83 c0 08             	add    $0x8,%eax
  80088d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800890:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800893:	48 85 db             	test   %rbx,%rbx
  800896:	78 50                	js     8008e8 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800898:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80089b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008a0:	e9 b4 01 00 00       	jmpq   800a59 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008a5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ad:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008b1:	eb dd                	jmp    800890 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008b3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008bb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008bf:	eb b6                	jmp    800877 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008c1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008c4:	83 f8 2f             	cmp    $0x2f,%eax
  8008c7:	77 11                	ja     8008da <vprintfmt+0x3d4>
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008cf:	83 c0 08             	add    $0x8,%eax
  8008d2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008d5:	48 63 1a             	movslq (%rdx),%rbx
  8008d8:	eb b9                	jmp    800893 <vprintfmt+0x38d>
  8008da:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008de:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e6:	eb ed                	jmp    8008d5 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008e8:	4c 89 fe             	mov    %r15,%rsi
  8008eb:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008f0:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008f3:	48 89 da             	mov    %rbx,%rdx
  8008f6:	48 f7 da             	neg    %rdx
        base = 10;
  8008f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008fe:	e9 56 01 00 00       	jmpq   800a59 <vprintfmt+0x553>
  if (lflag >= 2)
  800903:	83 f9 01             	cmp    $0x1,%ecx
  800906:	7f 25                	jg     80092d <vprintfmt+0x427>
  else if (lflag)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 5e                	je     80096a <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80090c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090f:	83 f8 2f             	cmp    $0x2f,%eax
  800912:	77 48                	ja     80095c <vprintfmt+0x456>
  800914:	89 c2                	mov    %eax,%edx
  800916:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091a:	83 c0 08             	add    $0x8,%eax
  80091d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800920:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800923:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800928:	e9 2c 01 00 00       	jmpq   800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80092d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800930:	83 f8 2f             	cmp    $0x2f,%eax
  800933:	77 19                	ja     80094e <vprintfmt+0x448>
  800935:	89 c2                	mov    %eax,%edx
  800937:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093b:	83 c0 08             	add    $0x8,%eax
  80093e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800941:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800944:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800949:	e9 0b 01 00 00       	jmpq   800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80094e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800952:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800956:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80095a:	eb e5                	jmp    800941 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80095c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800960:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800964:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800968:	eb b6                	jmp    800920 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80096a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80096d:	83 f8 2f             	cmp    $0x2f,%eax
  800970:	77 18                	ja     80098a <vprintfmt+0x484>
  800972:	89 c2                	mov    %eax,%edx
  800974:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800978:	83 c0 08             	add    $0x8,%eax
  80097b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80097e:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800980:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800985:	e9 cf 00 00 00       	jmpq   800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80098a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80098e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800992:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800996:	eb e6                	jmp    80097e <vprintfmt+0x478>
  if (lflag >= 2)
  800998:	83 f9 01             	cmp    $0x1,%ecx
  80099b:	7f 25                	jg     8009c2 <vprintfmt+0x4bc>
  else if (lflag)
  80099d:	85 c9                	test   %ecx,%ecx
  80099f:	74 5b                	je     8009fc <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009a1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a4:	83 f8 2f             	cmp    $0x2f,%eax
  8009a7:	77 45                	ja     8009ee <vprintfmt+0x4e8>
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009af:	83 c0 08             	add    $0x8,%eax
  8009b2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b5:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009b8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009bd:	e9 97 00 00 00       	jmpq   800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009c2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c5:	83 f8 2f             	cmp    $0x2f,%eax
  8009c8:	77 16                	ja     8009e0 <vprintfmt+0x4da>
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d0:	83 c0 08             	add    $0x8,%eax
  8009d3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d6:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009d9:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009de:	eb 79                	jmp    800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009e4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009e8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ec:	eb e8                	jmp    8009d6 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009ee:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009f6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009fa:	eb b9                	jmp    8009b5 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009fc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ff:	83 f8 2f             	cmp    $0x2f,%eax
  800a02:	77 15                	ja     800a19 <vprintfmt+0x513>
  800a04:	89 c2                	mov    %eax,%edx
  800a06:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a0a:	83 c0 08             	add    $0x8,%eax
  800a0d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a10:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a12:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a17:	eb 40                	jmp    800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a19:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a1d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a21:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a25:	eb e9                	jmp    800a10 <vprintfmt+0x50a>
        putch('0', putdat);
  800a27:	4c 89 fe             	mov    %r15,%rsi
  800a2a:	bf 30 00 00 00       	mov    $0x30,%edi
  800a2f:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a32:	4c 89 fe             	mov    %r15,%rsi
  800a35:	bf 78 00 00 00       	mov    $0x78,%edi
  800a3a:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a3d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a40:	83 f8 2f             	cmp    $0x2f,%eax
  800a43:	77 34                	ja     800a79 <vprintfmt+0x573>
  800a45:	89 c2                	mov    %eax,%edx
  800a47:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a4b:	83 c0 08             	add    $0x8,%eax
  800a4e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a51:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a54:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a59:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a5e:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a62:	4c 89 fe             	mov    %r15,%rsi
  800a65:	4c 89 ef             	mov    %r13,%rdi
  800a68:	48 b8 dc 03 80 00 00 	movabs $0x8003dc,%rax
  800a6f:	00 00 00 
  800a72:	ff d0                	callq  *%rax
        break;
  800a74:	e9 b7 fa ff ff       	jmpq   800530 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a79:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a7d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a81:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a85:	eb ca                	jmp    800a51 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a87:	83 f9 01             	cmp    $0x1,%ecx
  800a8a:	7f 22                	jg     800aae <vprintfmt+0x5a8>
  else if (lflag)
  800a8c:	85 c9                	test   %ecx,%ecx
  800a8e:	74 58                	je     800ae8 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a90:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a93:	83 f8 2f             	cmp    $0x2f,%eax
  800a96:	77 42                	ja     800ada <vprintfmt+0x5d4>
  800a98:	89 c2                	mov    %eax,%edx
  800a9a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a9e:	83 c0 08             	add    $0x8,%eax
  800aa1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aa4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aa7:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aac:	eb ab                	jmp    800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800aae:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ab1:	83 f8 2f             	cmp    $0x2f,%eax
  800ab4:	77 16                	ja     800acc <vprintfmt+0x5c6>
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800abc:	83 c0 08             	add    $0x8,%eax
  800abf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ac2:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ac5:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aca:	eb 8d                	jmp    800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800acc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ad4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ad8:	eb e8                	jmp    800ac2 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800ada:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ade:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ae2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ae6:	eb bc                	jmp    800aa4 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ae8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aeb:	83 f8 2f             	cmp    $0x2f,%eax
  800aee:	77 18                	ja     800b08 <vprintfmt+0x602>
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af6:	83 c0 08             	add    $0x8,%eax
  800af9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800afc:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800afe:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b03:	e9 51 ff ff ff       	jmpq   800a59 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b08:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b0c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b10:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b14:	eb e6                	jmp    800afc <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b16:	4c 89 fe             	mov    %r15,%rsi
  800b19:	bf 25 00 00 00       	mov    $0x25,%edi
  800b1e:	41 ff d5             	callq  *%r13
        break;
  800b21:	e9 0a fa ff ff       	jmpq   800530 <vprintfmt+0x2a>
        putch('%', putdat);
  800b26:	4c 89 fe             	mov    %r15,%rsi
  800b29:	bf 25 00 00 00       	mov    $0x25,%edi
  800b2e:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b31:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b35:	0f 84 15 fa ff ff    	je     800550 <vprintfmt+0x4a>
  800b3b:	49 89 de             	mov    %rbx,%r14
  800b3e:	49 83 ee 01          	sub    $0x1,%r14
  800b42:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b47:	75 f5                	jne    800b3e <vprintfmt+0x638>
  800b49:	e9 e2 f9 ff ff       	jmpq   800530 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b4e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b52:	74 06                	je     800b5a <vprintfmt+0x654>
  800b54:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b58:	7f 21                	jg     800b7b <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b5a:	bf 28 00 00 00       	mov    $0x28,%edi
  800b5f:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800b66:	00 00 00 
  800b69:	b8 28 00 00 00       	mov    $0x28,%eax
  800b6e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b72:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b76:	e9 82 fc ff ff       	jmpq   8007fd <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b7b:	49 63 f4             	movslq %r12d,%rsi
  800b7e:	48 bf bb 11 80 00 00 	movabs $0x8011bb,%rdi
  800b85:	00 00 00 
  800b88:	48 b8 dd 0c 80 00 00 	movabs $0x800cdd,%rax
  800b8f:	00 00 00 
  800b92:	ff d0                	callq  *%rax
  800b94:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b97:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b9a:	48 be bb 11 80 00 00 	movabs $0x8011bb,%rsi
  800ba1:	00 00 00 
  800ba4:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	0f 8f f2 fb ff ff    	jg     8007a2 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb0:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800bb7:	00 00 00 
  800bba:	b8 28 00 00 00       	mov    $0x28,%eax
  800bbf:	bf 28 00 00 00       	mov    $0x28,%edi
  800bc4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bc8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bcc:	e9 2c fc ff ff       	jmpq   8007fd <vprintfmt+0x2f7>
}
  800bd1:	48 83 c4 48          	add    $0x48,%rsp
  800bd5:	5b                   	pop    %rbx
  800bd6:	41 5c                	pop    %r12
  800bd8:	41 5d                	pop    %r13
  800bda:	41 5e                	pop    %r14
  800bdc:	41 5f                	pop    %r15
  800bde:	5d                   	pop    %rbp
  800bdf:	c3                   	retq   

0000000000800be0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800be0:	55                   	push   %rbp
  800be1:	48 89 e5             	mov    %rsp,%rbp
  800be4:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800be8:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800bec:	48 63 c6             	movslq %esi,%rax
  800bef:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bf4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bf8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800bff:	48 85 ff             	test   %rdi,%rdi
  800c02:	74 2a                	je     800c2e <vsnprintf+0x4e>
  800c04:	85 f6                	test   %esi,%esi
  800c06:	7e 26                	jle    800c2e <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c08:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c0c:	48 bf 68 04 80 00 00 	movabs $0x800468,%rdi
  800c13:	00 00 00 
  800c16:	48 b8 06 05 80 00 00 	movabs $0x800506,%rax
  800c1d:	00 00 00 
  800c20:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c22:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c26:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c29:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c2c:	c9                   	leaveq 
  800c2d:	c3                   	retq   
    return -E_INVAL;
  800c2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c33:	eb f7                	jmp    800c2c <vsnprintf+0x4c>

0000000000800c35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c35:	55                   	push   %rbp
  800c36:	48 89 e5             	mov    %rsp,%rbp
  800c39:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c40:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c47:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c4e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c55:	84 c0                	test   %al,%al
  800c57:	74 20                	je     800c79 <snprintf+0x44>
  800c59:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c5d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c61:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c65:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c69:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c6d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c71:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c75:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c79:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c80:	00 00 00 
  800c83:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c8a:	00 00 00 
  800c8d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c91:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c98:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c9f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800ca6:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cad:	48 b8 e0 0b 80 00 00 	movabs $0x800be0,%rax
  800cb4:	00 00 00 
  800cb7:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cb9:	c9                   	leaveq 
  800cba:	c3                   	retq   

0000000000800cbb <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cbb:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cbe:	74 17                	je     800cd7 <strlen+0x1c>
  800cc0:	48 89 fa             	mov    %rdi,%rdx
  800cc3:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cc8:	29 f9                	sub    %edi,%ecx
    n++;
  800cca:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800ccd:	48 83 c2 01          	add    $0x1,%rdx
  800cd1:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cd4:	75 f4                	jne    800cca <strlen+0xf>
  800cd6:	c3                   	retq   
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cdc:	c3                   	retq   

0000000000800cdd <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdd:	48 85 f6             	test   %rsi,%rsi
  800ce0:	74 24                	je     800d06 <strnlen+0x29>
  800ce2:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ce5:	74 25                	je     800d0c <strnlen+0x2f>
  800ce7:	48 01 fe             	add    %rdi,%rsi
  800cea:	48 89 fa             	mov    %rdi,%rdx
  800ced:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cf2:	29 f9                	sub    %edi,%ecx
    n++;
  800cf4:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf7:	48 83 c2 01          	add    $0x1,%rdx
  800cfb:	48 39 f2             	cmp    %rsi,%rdx
  800cfe:	74 11                	je     800d11 <strnlen+0x34>
  800d00:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d03:	75 ef                	jne    800cf4 <strnlen+0x17>
  800d05:	c3                   	retq   
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0b:	c3                   	retq   
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d11:	c3                   	retq   

0000000000800d12 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d12:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d15:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1a:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d1e:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d21:	48 83 c2 01          	add    $0x1,%rdx
  800d25:	84 c9                	test   %cl,%cl
  800d27:	75 f1                	jne    800d1a <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d29:	c3                   	retq   

0000000000800d2a <strcat>:

char *
strcat(char *dst, const char *src) {
  800d2a:	55                   	push   %rbp
  800d2b:	48 89 e5             	mov    %rsp,%rbp
  800d2e:	41 54                	push   %r12
  800d30:	53                   	push   %rbx
  800d31:	48 89 fb             	mov    %rdi,%rbx
  800d34:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d37:	48 b8 bb 0c 80 00 00 	movabs $0x800cbb,%rax
  800d3e:	00 00 00 
  800d41:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d43:	48 63 f8             	movslq %eax,%rdi
  800d46:	48 01 df             	add    %rbx,%rdi
  800d49:	4c 89 e6             	mov    %r12,%rsi
  800d4c:	48 b8 12 0d 80 00 00 	movabs $0x800d12,%rax
  800d53:	00 00 00 
  800d56:	ff d0                	callq  *%rax
  return dst;
}
  800d58:	48 89 d8             	mov    %rbx,%rax
  800d5b:	5b                   	pop    %rbx
  800d5c:	41 5c                	pop    %r12
  800d5e:	5d                   	pop    %rbp
  800d5f:	c3                   	retq   

0000000000800d60 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d60:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d63:	48 85 d2             	test   %rdx,%rdx
  800d66:	74 1f                	je     800d87 <strncpy+0x27>
  800d68:	48 01 fa             	add    %rdi,%rdx
  800d6b:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d6e:	48 83 c1 01          	add    $0x1,%rcx
  800d72:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d76:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d7a:	41 80 f8 01          	cmp    $0x1,%r8b
  800d7e:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d82:	48 39 ca             	cmp    %rcx,%rdx
  800d85:	75 e7                	jne    800d6e <strncpy+0xe>
  }
  return ret;
}
  800d87:	c3                   	retq   

0000000000800d88 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d88:	48 89 f8             	mov    %rdi,%rax
  800d8b:	48 85 d2             	test   %rdx,%rdx
  800d8e:	74 36                	je     800dc6 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d90:	48 83 fa 01          	cmp    $0x1,%rdx
  800d94:	74 2d                	je     800dc3 <strlcpy+0x3b>
  800d96:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d9a:	45 84 c0             	test   %r8b,%r8b
  800d9d:	74 24                	je     800dc3 <strlcpy+0x3b>
  800d9f:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800da3:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800da8:	48 83 c0 01          	add    $0x1,%rax
  800dac:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800db0:	48 39 d1             	cmp    %rdx,%rcx
  800db3:	74 0e                	je     800dc3 <strlcpy+0x3b>
  800db5:	48 83 c1 01          	add    $0x1,%rcx
  800db9:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dbe:	45 84 c0             	test   %r8b,%r8b
  800dc1:	75 e5                	jne    800da8 <strlcpy+0x20>
    *dst = '\0';
  800dc3:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dc6:	48 29 f8             	sub    %rdi,%rax
}
  800dc9:	c3                   	retq   

0000000000800dca <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dca:	0f b6 07             	movzbl (%rdi),%eax
  800dcd:	84 c0                	test   %al,%al
  800dcf:	74 17                	je     800de8 <strcmp+0x1e>
  800dd1:	3a 06                	cmp    (%rsi),%al
  800dd3:	75 13                	jne    800de8 <strcmp+0x1e>
    p++, q++;
  800dd5:	48 83 c7 01          	add    $0x1,%rdi
  800dd9:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800ddd:	0f b6 07             	movzbl (%rdi),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 04                	je     800de8 <strcmp+0x1e>
  800de4:	3a 06                	cmp    (%rsi),%al
  800de6:	74 ed                	je     800dd5 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800de8:	0f b6 c0             	movzbl %al,%eax
  800deb:	0f b6 16             	movzbl (%rsi),%edx
  800dee:	29 d0                	sub    %edx,%eax
}
  800df0:	c3                   	retq   

0000000000800df1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800df1:	48 85 d2             	test   %rdx,%rdx
  800df4:	74 2f                	je     800e25 <strncmp+0x34>
  800df6:	0f b6 07             	movzbl (%rdi),%eax
  800df9:	84 c0                	test   %al,%al
  800dfb:	74 1f                	je     800e1c <strncmp+0x2b>
  800dfd:	3a 06                	cmp    (%rsi),%al
  800dff:	75 1b                	jne    800e1c <strncmp+0x2b>
  800e01:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e04:	48 83 c7 01          	add    $0x1,%rdi
  800e08:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e0c:	48 39 d7             	cmp    %rdx,%rdi
  800e0f:	74 1a                	je     800e2b <strncmp+0x3a>
  800e11:	0f b6 07             	movzbl (%rdi),%eax
  800e14:	84 c0                	test   %al,%al
  800e16:	74 04                	je     800e1c <strncmp+0x2b>
  800e18:	3a 06                	cmp    (%rsi),%al
  800e1a:	74 e8                	je     800e04 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e1c:	0f b6 07             	movzbl (%rdi),%eax
  800e1f:	0f b6 16             	movzbl (%rsi),%edx
  800e22:	29 d0                	sub    %edx,%eax
}
  800e24:	c3                   	retq   
    return 0;
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2a:	c3                   	retq   
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e30:	c3                   	retq   

0000000000800e31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e31:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e33:	0f b6 07             	movzbl (%rdi),%eax
  800e36:	84 c0                	test   %al,%al
  800e38:	74 1e                	je     800e58 <strchr+0x27>
    if (*s == c)
  800e3a:	40 38 c6             	cmp    %al,%sil
  800e3d:	74 1f                	je     800e5e <strchr+0x2d>
  for (; *s; s++)
  800e3f:	48 83 c7 01          	add    $0x1,%rdi
  800e43:	0f b6 07             	movzbl (%rdi),%eax
  800e46:	84 c0                	test   %al,%al
  800e48:	74 08                	je     800e52 <strchr+0x21>
    if (*s == c)
  800e4a:	38 d0                	cmp    %dl,%al
  800e4c:	75 f1                	jne    800e3f <strchr+0xe>
  for (; *s; s++)
  800e4e:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e51:	c3                   	retq   
  return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	c3                   	retq   
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5d:	c3                   	retq   
    if (*s == c)
  800e5e:	48 89 f8             	mov    %rdi,%rax
  800e61:	c3                   	retq   

0000000000800e62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e62:	48 89 f8             	mov    %rdi,%rax
  800e65:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e67:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e6a:	40 38 f2             	cmp    %sil,%dl
  800e6d:	74 13                	je     800e82 <strfind+0x20>
  800e6f:	84 d2                	test   %dl,%dl
  800e71:	74 0f                	je     800e82 <strfind+0x20>
  for (; *s; s++)
  800e73:	48 83 c0 01          	add    $0x1,%rax
  800e77:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e7a:	38 ca                	cmp    %cl,%dl
  800e7c:	74 04                	je     800e82 <strfind+0x20>
  800e7e:	84 d2                	test   %dl,%dl
  800e80:	75 f1                	jne    800e73 <strfind+0x11>
      break;
  return (char *)s;
}
  800e82:	c3                   	retq   

0000000000800e83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e83:	48 85 d2             	test   %rdx,%rdx
  800e86:	74 3a                	je     800ec2 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e88:	48 89 f8             	mov    %rdi,%rax
  800e8b:	48 09 d0             	or     %rdx,%rax
  800e8e:	a8 03                	test   $0x3,%al
  800e90:	75 28                	jne    800eba <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e92:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e96:	89 f0                	mov    %esi,%eax
  800e98:	c1 e0 08             	shl    $0x8,%eax
  800e9b:	89 f1                	mov    %esi,%ecx
  800e9d:	c1 e1 18             	shl    $0x18,%ecx
  800ea0:	41 89 f0             	mov    %esi,%r8d
  800ea3:	41 c1 e0 10          	shl    $0x10,%r8d
  800ea7:	44 09 c1             	or     %r8d,%ecx
  800eaa:	09 ce                	or     %ecx,%esi
  800eac:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800eae:	48 c1 ea 02          	shr    $0x2,%rdx
  800eb2:	48 89 d1             	mov    %rdx,%rcx
  800eb5:	fc                   	cld    
  800eb6:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eb8:	eb 08                	jmp    800ec2 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	48 89 d1             	mov    %rdx,%rcx
  800ebf:	fc                   	cld    
  800ec0:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ec2:	48 89 f8             	mov    %rdi,%rax
  800ec5:	c3                   	retq   

0000000000800ec6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ec6:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ec9:	48 39 fe             	cmp    %rdi,%rsi
  800ecc:	73 40                	jae    800f0e <memmove+0x48>
  800ece:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ed2:	48 39 f9             	cmp    %rdi,%rcx
  800ed5:	76 37                	jbe    800f0e <memmove+0x48>
    s += n;
    d += n;
  800ed7:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800edb:	48 89 fe             	mov    %rdi,%rsi
  800ede:	48 09 d6             	or     %rdx,%rsi
  800ee1:	48 09 ce             	or     %rcx,%rsi
  800ee4:	40 f6 c6 03          	test   $0x3,%sil
  800ee8:	75 14                	jne    800efe <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800eea:	48 83 ef 04          	sub    $0x4,%rdi
  800eee:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800ef2:	48 c1 ea 02          	shr    $0x2,%rdx
  800ef6:	48 89 d1             	mov    %rdx,%rcx
  800ef9:	fd                   	std    
  800efa:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800efc:	eb 0e                	jmp    800f0c <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800efe:	48 83 ef 01          	sub    $0x1,%rdi
  800f02:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f06:	48 89 d1             	mov    %rdx,%rcx
  800f09:	fd                   	std    
  800f0a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f0c:	fc                   	cld    
  800f0d:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f0e:	48 89 c1             	mov    %rax,%rcx
  800f11:	48 09 d1             	or     %rdx,%rcx
  800f14:	48 09 f1             	or     %rsi,%rcx
  800f17:	f6 c1 03             	test   $0x3,%cl
  800f1a:	75 0e                	jne    800f2a <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f1c:	48 c1 ea 02          	shr    $0x2,%rdx
  800f20:	48 89 d1             	mov    %rdx,%rcx
  800f23:	48 89 c7             	mov    %rax,%rdi
  800f26:	fc                   	cld    
  800f27:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f29:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f2a:	48 89 c7             	mov    %rax,%rdi
  800f2d:	48 89 d1             	mov    %rdx,%rcx
  800f30:	fc                   	cld    
  800f31:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f33:	c3                   	retq   

0000000000800f34 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f34:	55                   	push   %rbp
  800f35:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f38:	48 b8 c6 0e 80 00 00 	movabs $0x800ec6,%rax
  800f3f:	00 00 00 
  800f42:	ff d0                	callq  *%rax
}
  800f44:	5d                   	pop    %rbp
  800f45:	c3                   	retq   

0000000000800f46 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f46:	55                   	push   %rbp
  800f47:	48 89 e5             	mov    %rsp,%rbp
  800f4a:	41 57                	push   %r15
  800f4c:	41 56                	push   %r14
  800f4e:	41 55                	push   %r13
  800f50:	41 54                	push   %r12
  800f52:	53                   	push   %rbx
  800f53:	48 83 ec 08          	sub    $0x8,%rsp
  800f57:	49 89 fe             	mov    %rdi,%r14
  800f5a:	49 89 f7             	mov    %rsi,%r15
  800f5d:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f60:	48 89 f7             	mov    %rsi,%rdi
  800f63:	48 b8 bb 0c 80 00 00 	movabs $0x800cbb,%rax
  800f6a:	00 00 00 
  800f6d:	ff d0                	callq  *%rax
  800f6f:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f72:	4c 89 ee             	mov    %r13,%rsi
  800f75:	4c 89 f7             	mov    %r14,%rdi
  800f78:	48 b8 dd 0c 80 00 00 	movabs $0x800cdd,%rax
  800f7f:	00 00 00 
  800f82:	ff d0                	callq  *%rax
  800f84:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f87:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f8b:	4d 39 e5             	cmp    %r12,%r13
  800f8e:	74 26                	je     800fb6 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f90:	4c 89 e8             	mov    %r13,%rax
  800f93:	4c 29 e0             	sub    %r12,%rax
  800f96:	48 39 d8             	cmp    %rbx,%rax
  800f99:	76 2a                	jbe    800fc5 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f9b:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f9f:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fa3:	4c 89 fe             	mov    %r15,%rsi
  800fa6:	48 b8 34 0f 80 00 00 	movabs $0x800f34,%rax
  800fad:	00 00 00 
  800fb0:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fb2:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fb6:	48 83 c4 08          	add    $0x8,%rsp
  800fba:	5b                   	pop    %rbx
  800fbb:	41 5c                	pop    %r12
  800fbd:	41 5d                	pop    %r13
  800fbf:	41 5e                	pop    %r14
  800fc1:	41 5f                	pop    %r15
  800fc3:	5d                   	pop    %rbp
  800fc4:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fc5:	49 83 ed 01          	sub    $0x1,%r13
  800fc9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fcd:	4c 89 ea             	mov    %r13,%rdx
  800fd0:	4c 89 fe             	mov    %r15,%rsi
  800fd3:	48 b8 34 0f 80 00 00 	movabs $0x800f34,%rax
  800fda:	00 00 00 
  800fdd:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fdf:	4d 01 ee             	add    %r13,%r14
  800fe2:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fe7:	eb c9                	jmp    800fb2 <strlcat+0x6c>

0000000000800fe9 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fe9:	48 85 d2             	test   %rdx,%rdx
  800fec:	74 3a                	je     801028 <memcmp+0x3f>
    if (*s1 != *s2)
  800fee:	0f b6 0f             	movzbl (%rdi),%ecx
  800ff1:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ff5:	44 38 c1             	cmp    %r8b,%cl
  800ff8:	75 1d                	jne    801017 <memcmp+0x2e>
  800ffa:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800fff:	48 39 d0             	cmp    %rdx,%rax
  801002:	74 1e                	je     801022 <memcmp+0x39>
    if (*s1 != *s2)
  801004:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801008:	48 83 c0 01          	add    $0x1,%rax
  80100c:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801012:	44 38 c1             	cmp    %r8b,%cl
  801015:	74 e8                	je     800fff <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801017:	0f b6 c1             	movzbl %cl,%eax
  80101a:	45 0f b6 c0          	movzbl %r8b,%r8d
  80101e:	44 29 c0             	sub    %r8d,%eax
  801021:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801022:	b8 00 00 00 00       	mov    $0x0,%eax
  801027:	c3                   	retq   
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102d:	c3                   	retq   

000000000080102e <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80102e:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801032:	48 39 c7             	cmp    %rax,%rdi
  801035:	73 19                	jae    801050 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801037:	89 f2                	mov    %esi,%edx
  801039:	40 38 37             	cmp    %sil,(%rdi)
  80103c:	74 16                	je     801054 <memfind+0x26>
  for (; s < ends; s++)
  80103e:	48 83 c7 01          	add    $0x1,%rdi
  801042:	48 39 f8             	cmp    %rdi,%rax
  801045:	74 08                	je     80104f <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801047:	38 17                	cmp    %dl,(%rdi)
  801049:	75 f3                	jne    80103e <memfind+0x10>
  for (; s < ends; s++)
  80104b:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80104e:	c3                   	retq   
  80104f:	c3                   	retq   
  for (; s < ends; s++)
  801050:	48 89 f8             	mov    %rdi,%rax
  801053:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801054:	48 89 f8             	mov    %rdi,%rax
  801057:	c3                   	retq   

0000000000801058 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801058:	0f b6 07             	movzbl (%rdi),%eax
  80105b:	3c 20                	cmp    $0x20,%al
  80105d:	74 04                	je     801063 <strtol+0xb>
  80105f:	3c 09                	cmp    $0x9,%al
  801061:	75 0f                	jne    801072 <strtol+0x1a>
    s++;
  801063:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801067:	0f b6 07             	movzbl (%rdi),%eax
  80106a:	3c 20                	cmp    $0x20,%al
  80106c:	74 f5                	je     801063 <strtol+0xb>
  80106e:	3c 09                	cmp    $0x9,%al
  801070:	74 f1                	je     801063 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801072:	3c 2b                	cmp    $0x2b,%al
  801074:	74 2b                	je     8010a1 <strtol+0x49>
  int neg  = 0;
  801076:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80107c:	3c 2d                	cmp    $0x2d,%al
  80107e:	74 2d                	je     8010ad <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801080:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801086:	75 0f                	jne    801097 <strtol+0x3f>
  801088:	80 3f 30             	cmpb   $0x30,(%rdi)
  80108b:	74 2c                	je     8010b9 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80108d:	85 d2                	test   %edx,%edx
  80108f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801094:	0f 44 d0             	cmove  %eax,%edx
  801097:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80109c:	4c 63 d2             	movslq %edx,%r10
  80109f:	eb 5c                	jmp    8010fd <strtol+0xa5>
    s++;
  8010a1:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010a5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010ab:	eb d3                	jmp    801080 <strtol+0x28>
    s++, neg = 1;
  8010ad:	48 83 c7 01          	add    $0x1,%rdi
  8010b1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010b7:	eb c7                	jmp    801080 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b9:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010bd:	74 0f                	je     8010ce <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010bf:	85 d2                	test   %edx,%edx
  8010c1:	75 d4                	jne    801097 <strtol+0x3f>
    s++, base = 8;
  8010c3:	48 83 c7 01          	add    $0x1,%rdi
  8010c7:	ba 08 00 00 00       	mov    $0x8,%edx
  8010cc:	eb c9                	jmp    801097 <strtol+0x3f>
    s += 2, base = 16;
  8010ce:	48 83 c7 02          	add    $0x2,%rdi
  8010d2:	ba 10 00 00 00       	mov    $0x10,%edx
  8010d7:	eb be                	jmp    801097 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010d9:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010dd:	41 80 f8 19          	cmp    $0x19,%r8b
  8010e1:	77 2f                	ja     801112 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010e3:	44 0f be c1          	movsbl %cl,%r8d
  8010e7:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010eb:	39 d1                	cmp    %edx,%ecx
  8010ed:	7d 37                	jge    801126 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010ef:	48 83 c7 01          	add    $0x1,%rdi
  8010f3:	49 0f af c2          	imul   %r10,%rax
  8010f7:	48 63 c9             	movslq %ecx,%rcx
  8010fa:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010fd:	0f b6 0f             	movzbl (%rdi),%ecx
  801100:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801104:	41 80 f8 09          	cmp    $0x9,%r8b
  801108:	77 cf                	ja     8010d9 <strtol+0x81>
      dig = *s - '0';
  80110a:	0f be c9             	movsbl %cl,%ecx
  80110d:	83 e9 30             	sub    $0x30,%ecx
  801110:	eb d9                	jmp    8010eb <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801112:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801116:	41 80 f8 19          	cmp    $0x19,%r8b
  80111a:	77 0a                	ja     801126 <strtol+0xce>
      dig = *s - 'A' + 10;
  80111c:	44 0f be c1          	movsbl %cl,%r8d
  801120:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801124:	eb c5                	jmp    8010eb <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801126:	48 85 f6             	test   %rsi,%rsi
  801129:	74 03                	je     80112e <strtol+0xd6>
    *endptr = (char *)s;
  80112b:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80112e:	48 89 c2             	mov    %rax,%rdx
  801131:	48 f7 da             	neg    %rdx
  801134:	45 85 c9             	test   %r9d,%r9d
  801137:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80113b:	c3                   	retq   
