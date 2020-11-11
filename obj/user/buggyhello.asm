
obj/user/buggyhello:     file format elf64-x86-64


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
  800023:	e8 1e 00 00 00       	callq  800046 <libmain>
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
  sys_cputs((char *)1, 1);
  80002e:	be 01 00 00 00       	mov    $0x1,%esi
  800033:	bf 01 00 00 00       	mov    $0x1,%edi
  800038:	48 b8 e3 00 80 00 00 	movabs $0x8000e3,%rax
  80003f:	00 00 00 
  800042:	ff d0                	callq  *%rax
}
  800044:	5d                   	pop    %rbp
  800045:	c3                   	retq   

0000000000800046 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800046:	55                   	push   %rbp
  800047:	48 89 e5             	mov    %rsp,%rbp
  80004a:	41 56                	push   %r14
  80004c:	41 55                	push   %r13
  80004e:	41 54                	push   %r12
  800050:	53                   	push   %rbx
  800051:	41 89 fd             	mov    %edi,%r13d
  800054:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800057:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80005e:	00 00 00 
  800061:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800068:	00 00 00 
  80006b:	48 39 c2             	cmp    %rax,%rdx
  80006e:	73 23                	jae    800093 <libmain+0x4d>
  800070:	48 89 d3             	mov    %rdx,%rbx
  800073:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800077:	48 29 d0             	sub    %rdx,%rax
  80007a:	48 c1 e8 03          	shr    $0x3,%rax
  80007e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
  800088:	ff 13                	callq  *(%rbx)
    ctor++;
  80008a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80008e:	4c 39 e3             	cmp    %r12,%rbx
  800091:	75 f0                	jne    800083 <libmain+0x3d>

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800093:	45 85 ed             	test   %r13d,%r13d
  800096:	7e 0d                	jle    8000a5 <libmain+0x5f>
    binaryname = argv[0];
  800098:	49 8b 06             	mov    (%r14),%rax
  80009b:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000a2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000a5:	4c 89 f6             	mov    %r14,%rsi
  8000a8:	44 89 ef             	mov    %r13d,%edi
  8000ab:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000b2:	00 00 00 
  8000b5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000b7:	48 b8 cc 00 80 00 00 	movabs $0x8000cc,%rax
  8000be:	00 00 00 
  8000c1:	ff d0                	callq  *%rax
#endif
}
  8000c3:	5b                   	pop    %rbx
  8000c4:	41 5c                	pop    %r12
  8000c6:	41 5d                	pop    %r13
  8000c8:	41 5e                	pop    %r14
  8000ca:	5d                   	pop    %rbp
  8000cb:	c3                   	retq   

00000000008000cc <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000cc:	55                   	push   %rbp
  8000cd:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8000d5:	48 b8 21 01 80 00 00 	movabs $0x800121,%rax
  8000dc:	00 00 00 
  8000df:	ff d0                	callq  *%rax
}
  8000e1:	5d                   	pop    %rbp
  8000e2:	c3                   	retq   

00000000008000e3 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000e3:	55                   	push   %rbp
  8000e4:	48 89 e5             	mov    %rsp,%rbp
  8000e7:	53                   	push   %rbx
  8000e8:	48 89 fa             	mov    %rdi,%rdx
  8000eb:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8000ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f3:	48 89 c3             	mov    %rax,%rbx
  8000f6:	48 89 c7             	mov    %rax,%rdi
  8000f9:	48 89 c6             	mov    %rax,%rsi
  8000fc:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8000fe:	5b                   	pop    %rbx
  8000ff:	5d                   	pop    %rbp
  800100:	c3                   	retq   

0000000000800101 <sys_cgetc>:

int
sys_cgetc(void) {
  800101:	55                   	push   %rbp
  800102:	48 89 e5             	mov    %rsp,%rbp
  800105:	53                   	push   %rbx
  asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	b8 01 00 00 00       	mov    $0x1,%eax
  800110:	48 89 ca             	mov    %rcx,%rdx
  800113:	48 89 cb             	mov    %rcx,%rbx
  800116:	48 89 cf             	mov    %rcx,%rdi
  800119:	48 89 ce             	mov    %rcx,%rsi
  80011c:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011e:	5b                   	pop    %rbx
  80011f:	5d                   	pop    %rbp
  800120:	c3                   	retq   

0000000000800121 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800121:	55                   	push   %rbp
  800122:	48 89 e5             	mov    %rsp,%rbp
  800125:	53                   	push   %rbx
  800126:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80012a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80012d:	be 00 00 00 00       	mov    $0x0,%esi
  800132:	b8 03 00 00 00       	mov    $0x3,%eax
  800137:	48 89 f1             	mov    %rsi,%rcx
  80013a:	48 89 f3             	mov    %rsi,%rbx
  80013d:	48 89 f7             	mov    %rsi,%rdi
  800140:	cd 30                	int    $0x30
  if (check && ret > 0)
  800142:	48 85 c0             	test   %rax,%rax
  800145:	7f 07                	jg     80014e <sys_env_destroy+0x2d>
}
  800147:	48 83 c4 08          	add    $0x8,%rsp
  80014b:	5b                   	pop    %rbx
  80014c:	5d                   	pop    %rbp
  80014d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80014e:	49 89 c0             	mov    %rax,%r8
  800151:	b9 03 00 00 00       	mov    $0x3,%ecx
  800156:	48 ba 50 11 80 00 00 	movabs $0x801150,%rdx
  80015d:	00 00 00 
  800160:	be 22 00 00 00       	mov    $0x22,%esi
  800165:	48 bf 6f 11 80 00 00 	movabs $0x80116f,%rdi
  80016c:	00 00 00 
  80016f:	b8 00 00 00 00       	mov    $0x0,%eax
  800174:	49 b9 a1 01 80 00 00 	movabs $0x8001a1,%r9
  80017b:	00 00 00 
  80017e:	41 ff d1             	callq  *%r9

0000000000800181 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800181:	55                   	push   %rbp
  800182:	48 89 e5             	mov    %rsp,%rbp
  800185:	53                   	push   %rbx
  asm volatile("int %1\n"
  800186:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018b:	b8 02 00 00 00       	mov    $0x2,%eax
  800190:	48 89 ca             	mov    %rcx,%rdx
  800193:	48 89 cb             	mov    %rcx,%rbx
  800196:	48 89 cf             	mov    %rcx,%rdi
  800199:	48 89 ce             	mov    %rcx,%rsi
  80019c:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019e:	5b                   	pop    %rbx
  80019f:	5d                   	pop    %rbp
  8001a0:	c3                   	retq   

00000000008001a1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001a1:	55                   	push   %rbp
  8001a2:	48 89 e5             	mov    %rsp,%rbp
  8001a5:	41 56                	push   %r14
  8001a7:	41 55                	push   %r13
  8001a9:	41 54                	push   %r12
  8001ab:	53                   	push   %rbx
  8001ac:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001b3:	49 89 fd             	mov    %rdi,%r13
  8001b6:	41 89 f6             	mov    %esi,%r14d
  8001b9:	49 89 d4             	mov    %rdx,%r12
  8001bc:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001c3:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001ca:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001d1:	84 c0                	test   %al,%al
  8001d3:	74 26                	je     8001fb <_panic+0x5a>
  8001d5:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001dc:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001e3:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8001e7:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8001eb:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8001ef:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8001f3:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8001f7:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8001fb:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800202:	00 00 00 
  800205:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80020c:	00 00 00 
  80020f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800213:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80021a:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800221:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800228:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80022f:	00 00 00 
  800232:	48 8b 18             	mov    (%rax),%rbx
  800235:	48 b8 81 01 80 00 00 	movabs $0x800181,%rax
  80023c:	00 00 00 
  80023f:	ff d0                	callq  *%rax
  800241:	45 89 f0             	mov    %r14d,%r8d
  800244:	4c 89 e9             	mov    %r13,%rcx
  800247:	48 89 da             	mov    %rbx,%rdx
  80024a:	89 c6                	mov    %eax,%esi
  80024c:	48 bf 80 11 80 00 00 	movabs $0x801180,%rdi
  800253:	00 00 00 
  800256:	b8 00 00 00 00       	mov    $0x0,%eax
  80025b:	48 bb 43 03 80 00 00 	movabs $0x800343,%rbx
  800262:	00 00 00 
  800265:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800267:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80026e:	4c 89 e7             	mov    %r12,%rdi
  800271:	48 b8 db 02 80 00 00 	movabs $0x8002db,%rax
  800278:	00 00 00 
  80027b:	ff d0                	callq  *%rax
  cprintf("\n");
  80027d:	48 bf a8 11 80 00 00 	movabs $0x8011a8,%rdi
  800284:	00 00 00 
  800287:	b8 00 00 00 00       	mov    $0x0,%eax
  80028c:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80028e:	cc                   	int3   
  while (1)
  80028f:	eb fd                	jmp    80028e <_panic+0xed>

0000000000800291 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800291:	55                   	push   %rbp
  800292:	48 89 e5             	mov    %rsp,%rbp
  800295:	53                   	push   %rbx
  800296:	48 83 ec 08          	sub    $0x8,%rsp
  80029a:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80029d:	8b 06                	mov    (%rsi),%eax
  80029f:	8d 50 01             	lea    0x1(%rax),%edx
  8002a2:	89 16                	mov    %edx,(%rsi)
  8002a4:	48 98                	cltq   
  8002a6:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002ab:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002b1:	74 0b                	je     8002be <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002b3:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002b7:	48 83 c4 08          	add    $0x8,%rsp
  8002bb:	5b                   	pop    %rbx
  8002bc:	5d                   	pop    %rbp
  8002bd:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002be:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002c2:	be ff 00 00 00       	mov    $0xff,%esi
  8002c7:	48 b8 e3 00 80 00 00 	movabs $0x8000e3,%rax
  8002ce:	00 00 00 
  8002d1:	ff d0                	callq  *%rax
    b->idx = 0;
  8002d3:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002d9:	eb d8                	jmp    8002b3 <putch+0x22>

00000000008002db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002db:	55                   	push   %rbp
  8002dc:	48 89 e5             	mov    %rsp,%rbp
  8002df:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8002e6:	48 89 fa             	mov    %rdi,%rdx
  8002e9:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8002ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8002f3:	00 00 00 
  b.cnt = 0;
  8002f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8002fd:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800300:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800307:	48 bf 91 02 80 00 00 	movabs $0x800291,%rdi
  80030e:	00 00 00 
  800311:	48 b8 01 05 80 00 00 	movabs $0x800501,%rax
  800318:	00 00 00 
  80031b:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80031d:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800324:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80032b:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80032f:	48 b8 e3 00 80 00 00 	movabs $0x8000e3,%rax
  800336:	00 00 00 
  800339:	ff d0                	callq  *%rax

  return b.cnt;
}
  80033b:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800341:	c9                   	leaveq 
  800342:	c3                   	retq   

0000000000800343 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800343:	55                   	push   %rbp
  800344:	48 89 e5             	mov    %rsp,%rbp
  800347:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80034e:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800355:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80035c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800363:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80036a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800371:	84 c0                	test   %al,%al
  800373:	74 20                	je     800395 <cprintf+0x52>
  800375:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800379:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80037d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800381:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800385:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800389:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80038d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800391:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800395:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80039c:	00 00 00 
  80039f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003a6:	00 00 00 
  8003a9:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003ad:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003b4:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003bb:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003c2:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003c9:	48 b8 db 02 80 00 00 	movabs $0x8002db,%rax
  8003d0:	00 00 00 
  8003d3:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003d5:	c9                   	leaveq 
  8003d6:	c3                   	retq   

00000000008003d7 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003d7:	55                   	push   %rbp
  8003d8:	48 89 e5             	mov    %rsp,%rbp
  8003db:	41 57                	push   %r15
  8003dd:	41 56                	push   %r14
  8003df:	41 55                	push   %r13
  8003e1:	41 54                	push   %r12
  8003e3:	53                   	push   %rbx
  8003e4:	48 83 ec 18          	sub    $0x18,%rsp
  8003e8:	49 89 fc             	mov    %rdi,%r12
  8003eb:	49 89 f5             	mov    %rsi,%r13
  8003ee:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8003f2:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8003f5:	41 89 cf             	mov    %ecx,%r15d
  8003f8:	49 39 d7             	cmp    %rdx,%r15
  8003fb:	76 45                	jbe    800442 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8003fd:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800401:	85 db                	test   %ebx,%ebx
  800403:	7e 0e                	jle    800413 <printnum+0x3c>
      putch(padc, putdat);
  800405:	4c 89 ee             	mov    %r13,%rsi
  800408:	44 89 f7             	mov    %r14d,%edi
  80040b:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80040e:	83 eb 01             	sub    $0x1,%ebx
  800411:	75 f2                	jne    800405 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800413:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800417:	ba 00 00 00 00       	mov    $0x0,%edx
  80041c:	49 f7 f7             	div    %r15
  80041f:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  800426:	00 00 00 
  800429:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80042d:	4c 89 ee             	mov    %r13,%rsi
  800430:	41 ff d4             	callq  *%r12
}
  800433:	48 83 c4 18          	add    $0x18,%rsp
  800437:	5b                   	pop    %rbx
  800438:	41 5c                	pop    %r12
  80043a:	41 5d                	pop    %r13
  80043c:	41 5e                	pop    %r14
  80043e:	41 5f                	pop    %r15
  800440:	5d                   	pop    %rbp
  800441:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800442:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800446:	ba 00 00 00 00       	mov    $0x0,%edx
  80044b:	49 f7 f7             	div    %r15
  80044e:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800452:	48 89 c2             	mov    %rax,%rdx
  800455:	48 b8 d7 03 80 00 00 	movabs $0x8003d7,%rax
  80045c:	00 00 00 
  80045f:	ff d0                	callq  *%rax
  800461:	eb b0                	jmp    800413 <printnum+0x3c>

0000000000800463 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800463:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800467:	48 8b 06             	mov    (%rsi),%rax
  80046a:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80046e:	73 0a                	jae    80047a <sprintputch+0x17>
    *b->buf++ = ch;
  800470:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800474:	48 89 16             	mov    %rdx,(%rsi)
  800477:	40 88 38             	mov    %dil,(%rax)
}
  80047a:	c3                   	retq   

000000000080047b <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80047b:	55                   	push   %rbp
  80047c:	48 89 e5             	mov    %rsp,%rbp
  80047f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800486:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80048d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800494:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80049b:	84 c0                	test   %al,%al
  80049d:	74 20                	je     8004bf <printfmt+0x44>
  80049f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004a3:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004a7:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004ab:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004af:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004b3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004b7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004bb:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004bf:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004c6:	00 00 00 
  8004c9:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004d0:	00 00 00 
  8004d3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004d7:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004de:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004e5:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8004ec:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004f3:	48 b8 01 05 80 00 00 	movabs $0x800501,%rax
  8004fa:	00 00 00 
  8004fd:	ff d0                	callq  *%rax
}
  8004ff:	c9                   	leaveq 
  800500:	c3                   	retq   

0000000000800501 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800501:	55                   	push   %rbp
  800502:	48 89 e5             	mov    %rsp,%rbp
  800505:	41 57                	push   %r15
  800507:	41 56                	push   %r14
  800509:	41 55                	push   %r13
  80050b:	41 54                	push   %r12
  80050d:	53                   	push   %rbx
  80050e:	48 83 ec 48          	sub    $0x48,%rsp
  800512:	49 89 fd             	mov    %rdi,%r13
  800515:	49 89 f7             	mov    %rsi,%r15
  800518:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80051b:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80051f:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800523:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800527:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80052b:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80052f:	41 0f b6 3e          	movzbl (%r14),%edi
  800533:	83 ff 25             	cmp    $0x25,%edi
  800536:	74 18                	je     800550 <vprintfmt+0x4f>
      if (ch == '\0')
  800538:	85 ff                	test   %edi,%edi
  80053a:	0f 84 8c 06 00 00    	je     800bcc <vprintfmt+0x6cb>
      putch(ch, putdat);
  800540:	4c 89 fe             	mov    %r15,%rsi
  800543:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800546:	49 89 de             	mov    %rbx,%r14
  800549:	eb e0                	jmp    80052b <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80054b:	49 89 de             	mov    %rbx,%r14
  80054e:	eb db                	jmp    80052b <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800550:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800554:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800558:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80055f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800565:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800569:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80056e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800574:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80057a:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80057f:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800584:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800588:	0f b6 13             	movzbl (%rbx),%edx
  80058b:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80058e:	3c 55                	cmp    $0x55,%al
  800590:	0f 87 8b 05 00 00    	ja     800b21 <vprintfmt+0x620>
  800596:	0f b6 c0             	movzbl %al,%eax
  800599:	49 bb 60 12 80 00 00 	movabs $0x801260,%r11
  8005a0:	00 00 00 
  8005a3:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005a7:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005aa:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005ae:	eb d4                	jmp    800584 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005b0:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005b3:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005b7:	eb cb                	jmp    800584 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005b9:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005bc:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005c0:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005c4:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005c7:	83 fa 09             	cmp    $0x9,%edx
  8005ca:	77 7e                	ja     80064a <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005cc:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005d0:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005d4:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005d9:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005dd:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005e0:	83 fa 09             	cmp    $0x9,%edx
  8005e3:	76 e7                	jbe    8005cc <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8005e5:	4c 89 f3             	mov    %r14,%rbx
  8005e8:	eb 19                	jmp    800603 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8005ea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005ed:	83 f8 2f             	cmp    $0x2f,%eax
  8005f0:	77 2a                	ja     80061c <vprintfmt+0x11b>
  8005f2:	89 c2                	mov    %eax,%edx
  8005f4:	4c 01 d2             	add    %r10,%rdx
  8005f7:	83 c0 08             	add    $0x8,%eax
  8005fa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005fd:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800600:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800603:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800607:	0f 89 77 ff ff ff    	jns    800584 <vprintfmt+0x83>
          width = precision, precision = -1;
  80060d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800611:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800617:	e9 68 ff ff ff       	jmpq   800584 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80061c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800620:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800624:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800628:	eb d3                	jmp    8005fd <vprintfmt+0xfc>
        if (width < 0)
  80062a:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80062d:	85 c0                	test   %eax,%eax
  80062f:	41 0f 48 c0          	cmovs  %r8d,%eax
  800633:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800636:	4c 89 f3             	mov    %r14,%rbx
  800639:	e9 46 ff ff ff       	jmpq   800584 <vprintfmt+0x83>
  80063e:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800641:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800645:	e9 3a ff ff ff       	jmpq   800584 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80064a:	4c 89 f3             	mov    %r14,%rbx
  80064d:	eb b4                	jmp    800603 <vprintfmt+0x102>
        lflag++;
  80064f:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800652:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800655:	e9 2a ff ff ff       	jmpq   800584 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80065a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80065d:	83 f8 2f             	cmp    $0x2f,%eax
  800660:	77 19                	ja     80067b <vprintfmt+0x17a>
  800662:	89 c2                	mov    %eax,%edx
  800664:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800668:	83 c0 08             	add    $0x8,%eax
  80066b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80066e:	4c 89 fe             	mov    %r15,%rsi
  800671:	8b 3a                	mov    (%rdx),%edi
  800673:	41 ff d5             	callq  *%r13
        break;
  800676:	e9 b0 fe ff ff       	jmpq   80052b <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80067b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80067f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800683:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800687:	eb e5                	jmp    80066e <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800689:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80068c:	83 f8 2f             	cmp    $0x2f,%eax
  80068f:	77 5b                	ja     8006ec <vprintfmt+0x1eb>
  800691:	89 c2                	mov    %eax,%edx
  800693:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800697:	83 c0 08             	add    $0x8,%eax
  80069a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80069d:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80069f:	89 c8                	mov    %ecx,%eax
  8006a1:	c1 f8 1f             	sar    $0x1f,%eax
  8006a4:	31 c1                	xor    %eax,%ecx
  8006a6:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a8:	83 f9 09             	cmp    $0x9,%ecx
  8006ab:	7f 4d                	jg     8006fa <vprintfmt+0x1f9>
  8006ad:	48 63 c1             	movslq %ecx,%rax
  8006b0:	48 ba 20 15 80 00 00 	movabs $0x801520,%rdx
  8006b7:	00 00 00 
  8006ba:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006be:	48 85 c0             	test   %rax,%rax
  8006c1:	74 37                	je     8006fa <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006c3:	48 89 c1             	mov    %rax,%rcx
  8006c6:	48 ba cb 11 80 00 00 	movabs $0x8011cb,%rdx
  8006cd:	00 00 00 
  8006d0:	4c 89 fe             	mov    %r15,%rsi
  8006d3:	4c 89 ef             	mov    %r13,%rdi
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006db:	48 bb 7b 04 80 00 00 	movabs $0x80047b,%rbx
  8006e2:	00 00 00 
  8006e5:	ff d3                	callq  *%rbx
  8006e7:	e9 3f fe ff ff       	jmpq   80052b <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8006ec:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006f0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006f4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006f8:	eb a3                	jmp    80069d <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8006fa:	48 ba c2 11 80 00 00 	movabs $0x8011c2,%rdx
  800701:	00 00 00 
  800704:	4c 89 fe             	mov    %r15,%rsi
  800707:	4c 89 ef             	mov    %r13,%rdi
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	48 bb 7b 04 80 00 00 	movabs $0x80047b,%rbx
  800716:	00 00 00 
  800719:	ff d3                	callq  *%rbx
  80071b:	e9 0b fe ff ff       	jmpq   80052b <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800720:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800723:	83 f8 2f             	cmp    $0x2f,%eax
  800726:	77 4b                	ja     800773 <vprintfmt+0x272>
  800728:	89 c2                	mov    %eax,%edx
  80072a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80072e:	83 c0 08             	add    $0x8,%eax
  800731:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800734:	48 8b 02             	mov    (%rdx),%rax
  800737:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80073b:	48 85 c0             	test   %rax,%rax
  80073e:	0f 84 05 04 00 00    	je     800b49 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800744:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800748:	7e 06                	jle    800750 <vprintfmt+0x24f>
  80074a:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80074e:	75 31                	jne    800781 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800750:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800754:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800758:	0f b6 00             	movzbl (%rax),%eax
  80075b:	0f be f8             	movsbl %al,%edi
  80075e:	85 ff                	test   %edi,%edi
  800760:	0f 84 c3 00 00 00    	je     800829 <vprintfmt+0x328>
  800766:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80076a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80076e:	e9 85 00 00 00       	jmpq   8007f8 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800773:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800777:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80077b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80077f:	eb b3                	jmp    800734 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800781:	49 63 f4             	movslq %r12d,%rsi
  800784:	48 89 c7             	mov    %rax,%rdi
  800787:	48 b8 d8 0c 80 00 00 	movabs $0x800cd8,%rax
  80078e:	00 00 00 
  800791:	ff d0                	callq  *%rax
  800793:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800796:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800799:	85 f6                	test   %esi,%esi
  80079b:	7e 22                	jle    8007bf <vprintfmt+0x2be>
            putch(padc, putdat);
  80079d:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007a1:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007a5:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007a9:	4c 89 fe             	mov    %r15,%rsi
  8007ac:	89 df                	mov    %ebx,%edi
  8007ae:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007b1:	41 83 ec 01          	sub    $0x1,%r12d
  8007b5:	75 f2                	jne    8007a9 <vprintfmt+0x2a8>
  8007b7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007bb:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007bf:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007c3:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007c7:	0f b6 00             	movzbl (%rax),%eax
  8007ca:	0f be f8             	movsbl %al,%edi
  8007cd:	85 ff                	test   %edi,%edi
  8007cf:	0f 84 56 fd ff ff    	je     80052b <vprintfmt+0x2a>
  8007d5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007d9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007dd:	eb 19                	jmp    8007f8 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007df:	4c 89 fe             	mov    %r15,%rsi
  8007e2:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e5:	41 83 ee 01          	sub    $0x1,%r14d
  8007e9:	48 83 c3 01          	add    $0x1,%rbx
  8007ed:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8007f1:	0f be f8             	movsbl %al,%edi
  8007f4:	85 ff                	test   %edi,%edi
  8007f6:	74 29                	je     800821 <vprintfmt+0x320>
  8007f8:	45 85 e4             	test   %r12d,%r12d
  8007fb:	78 06                	js     800803 <vprintfmt+0x302>
  8007fd:	41 83 ec 01          	sub    $0x1,%r12d
  800801:	78 48                	js     80084b <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800803:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800807:	74 d6                	je     8007df <vprintfmt+0x2de>
  800809:	0f be c0             	movsbl %al,%eax
  80080c:	83 e8 20             	sub    $0x20,%eax
  80080f:	83 f8 5e             	cmp    $0x5e,%eax
  800812:	76 cb                	jbe    8007df <vprintfmt+0x2de>
            putch('?', putdat);
  800814:	4c 89 fe             	mov    %r15,%rsi
  800817:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80081c:	41 ff d5             	callq  *%r13
  80081f:	eb c4                	jmp    8007e5 <vprintfmt+0x2e4>
  800821:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800825:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800829:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80082c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800830:	0f 8e f5 fc ff ff    	jle    80052b <vprintfmt+0x2a>
          putch(' ', putdat);
  800836:	4c 89 fe             	mov    %r15,%rsi
  800839:	bf 20 00 00 00       	mov    $0x20,%edi
  80083e:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800841:	83 eb 01             	sub    $0x1,%ebx
  800844:	75 f0                	jne    800836 <vprintfmt+0x335>
  800846:	e9 e0 fc ff ff       	jmpq   80052b <vprintfmt+0x2a>
  80084b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80084f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800853:	eb d4                	jmp    800829 <vprintfmt+0x328>
  if (lflag >= 2)
  800855:	83 f9 01             	cmp    $0x1,%ecx
  800858:	7f 1d                	jg     800877 <vprintfmt+0x376>
  else if (lflag)
  80085a:	85 c9                	test   %ecx,%ecx
  80085c:	74 5e                	je     8008bc <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80085e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800861:	83 f8 2f             	cmp    $0x2f,%eax
  800864:	77 48                	ja     8008ae <vprintfmt+0x3ad>
  800866:	89 c2                	mov    %eax,%edx
  800868:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80086c:	83 c0 08             	add    $0x8,%eax
  80086f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800872:	48 8b 1a             	mov    (%rdx),%rbx
  800875:	eb 17                	jmp    80088e <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800877:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80087a:	83 f8 2f             	cmp    $0x2f,%eax
  80087d:	77 21                	ja     8008a0 <vprintfmt+0x39f>
  80087f:	89 c2                	mov    %eax,%edx
  800881:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800885:	83 c0 08             	add    $0x8,%eax
  800888:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80088b:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80088e:	48 85 db             	test   %rbx,%rbx
  800891:	78 50                	js     8008e3 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800893:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800896:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80089b:	e9 b4 01 00 00       	jmpq   800a54 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008a0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008a8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ac:	eb dd                	jmp    80088b <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008ae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008b2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008b6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ba:	eb b6                	jmp    800872 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008bc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008bf:	83 f8 2f             	cmp    $0x2f,%eax
  8008c2:	77 11                	ja     8008d5 <vprintfmt+0x3d4>
  8008c4:	89 c2                	mov    %eax,%edx
  8008c6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ca:	83 c0 08             	add    $0x8,%eax
  8008cd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008d0:	48 63 1a             	movslq (%rdx),%rbx
  8008d3:	eb b9                	jmp    80088e <vprintfmt+0x38d>
  8008d5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008dd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e1:	eb ed                	jmp    8008d0 <vprintfmt+0x3cf>
          putch('-', putdat);
  8008e3:	4c 89 fe             	mov    %r15,%rsi
  8008e6:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8008eb:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8008ee:	48 89 da             	mov    %rbx,%rdx
  8008f1:	48 f7 da             	neg    %rdx
        base = 10;
  8008f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008f9:	e9 56 01 00 00       	jmpq   800a54 <vprintfmt+0x553>
  if (lflag >= 2)
  8008fe:	83 f9 01             	cmp    $0x1,%ecx
  800901:	7f 25                	jg     800928 <vprintfmt+0x427>
  else if (lflag)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 5e                	je     800965 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800907:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090a:	83 f8 2f             	cmp    $0x2f,%eax
  80090d:	77 48                	ja     800957 <vprintfmt+0x456>
  80090f:	89 c2                	mov    %eax,%edx
  800911:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800915:	83 c0 08             	add    $0x8,%eax
  800918:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80091b:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80091e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800923:	e9 2c 01 00 00       	jmpq   800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800928:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092b:	83 f8 2f             	cmp    $0x2f,%eax
  80092e:	77 19                	ja     800949 <vprintfmt+0x448>
  800930:	89 c2                	mov    %eax,%edx
  800932:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800936:	83 c0 08             	add    $0x8,%eax
  800939:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093c:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80093f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800944:	e9 0b 01 00 00       	jmpq   800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800949:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800951:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800955:	eb e5                	jmp    80093c <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800957:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80095b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80095f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800963:	eb b6                	jmp    80091b <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800965:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800968:	83 f8 2f             	cmp    $0x2f,%eax
  80096b:	77 18                	ja     800985 <vprintfmt+0x484>
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800973:	83 c0 08             	add    $0x8,%eax
  800976:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800979:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80097b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800980:	e9 cf 00 00 00       	jmpq   800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800985:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800989:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80098d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800991:	eb e6                	jmp    800979 <vprintfmt+0x478>
  if (lflag >= 2)
  800993:	83 f9 01             	cmp    $0x1,%ecx
  800996:	7f 25                	jg     8009bd <vprintfmt+0x4bc>
  else if (lflag)
  800998:	85 c9                	test   %ecx,%ecx
  80099a:	74 5b                	je     8009f7 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80099c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099f:	83 f8 2f             	cmp    $0x2f,%eax
  8009a2:	77 45                	ja     8009e9 <vprintfmt+0x4e8>
  8009a4:	89 c2                	mov    %eax,%edx
  8009a6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009aa:	83 c0 08             	add    $0x8,%eax
  8009ad:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b0:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009b3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009b8:	e9 97 00 00 00       	jmpq   800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009bd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c0:	83 f8 2f             	cmp    $0x2f,%eax
  8009c3:	77 16                	ja     8009db <vprintfmt+0x4da>
  8009c5:	89 c2                	mov    %eax,%edx
  8009c7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009cb:	83 c0 08             	add    $0x8,%eax
  8009ce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d1:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009d4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009d9:	eb 79                	jmp    800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009db:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009df:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009e3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e7:	eb e8                	jmp    8009d1 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8009e9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ed:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009f1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009f5:	eb b9                	jmp    8009b0 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8009f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009fa:	83 f8 2f             	cmp    $0x2f,%eax
  8009fd:	77 15                	ja     800a14 <vprintfmt+0x513>
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a05:	83 c0 08             	add    $0x8,%eax
  800a08:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a0b:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a0d:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a12:	eb 40                	jmp    800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a14:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a18:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a20:	eb e9                	jmp    800a0b <vprintfmt+0x50a>
        putch('0', putdat);
  800a22:	4c 89 fe             	mov    %r15,%rsi
  800a25:	bf 30 00 00 00       	mov    $0x30,%edi
  800a2a:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a2d:	4c 89 fe             	mov    %r15,%rsi
  800a30:	bf 78 00 00 00       	mov    $0x78,%edi
  800a35:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a38:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a3b:	83 f8 2f             	cmp    $0x2f,%eax
  800a3e:	77 34                	ja     800a74 <vprintfmt+0x573>
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a46:	83 c0 08             	add    $0x8,%eax
  800a49:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a4c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a4f:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a54:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a59:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a5d:	4c 89 fe             	mov    %r15,%rsi
  800a60:	4c 89 ef             	mov    %r13,%rdi
  800a63:	48 b8 d7 03 80 00 00 	movabs $0x8003d7,%rax
  800a6a:	00 00 00 
  800a6d:	ff d0                	callq  *%rax
        break;
  800a6f:	e9 b7 fa ff ff       	jmpq   80052b <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a74:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a78:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a7c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a80:	eb ca                	jmp    800a4c <vprintfmt+0x54b>
  if (lflag >= 2)
  800a82:	83 f9 01             	cmp    $0x1,%ecx
  800a85:	7f 22                	jg     800aa9 <vprintfmt+0x5a8>
  else if (lflag)
  800a87:	85 c9                	test   %ecx,%ecx
  800a89:	74 58                	je     800ae3 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800a8b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a8e:	83 f8 2f             	cmp    $0x2f,%eax
  800a91:	77 42                	ja     800ad5 <vprintfmt+0x5d4>
  800a93:	89 c2                	mov    %eax,%edx
  800a95:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a99:	83 c0 08             	add    $0x8,%eax
  800a9c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a9f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800aa2:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aa7:	eb ab                	jmp    800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800aa9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aac:	83 f8 2f             	cmp    $0x2f,%eax
  800aaf:	77 16                	ja     800ac7 <vprintfmt+0x5c6>
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ab7:	83 c0 08             	add    $0x8,%eax
  800aba:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800abd:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ac0:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ac5:	eb 8d                	jmp    800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ac7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800acb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800acf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ad3:	eb e8                	jmp    800abd <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800ad5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800add:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ae1:	eb bc                	jmp    800a9f <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800ae3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae6:	83 f8 2f             	cmp    $0x2f,%eax
  800ae9:	77 18                	ja     800b03 <vprintfmt+0x602>
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af1:	83 c0 08             	add    $0x8,%eax
  800af4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af7:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800af9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800afe:	e9 51 ff ff ff       	jmpq   800a54 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b03:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b07:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b0b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b0f:	eb e6                	jmp    800af7 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b11:	4c 89 fe             	mov    %r15,%rsi
  800b14:	bf 25 00 00 00       	mov    $0x25,%edi
  800b19:	41 ff d5             	callq  *%r13
        break;
  800b1c:	e9 0a fa ff ff       	jmpq   80052b <vprintfmt+0x2a>
        putch('%', putdat);
  800b21:	4c 89 fe             	mov    %r15,%rsi
  800b24:	bf 25 00 00 00       	mov    $0x25,%edi
  800b29:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b2c:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b30:	0f 84 15 fa ff ff    	je     80054b <vprintfmt+0x4a>
  800b36:	49 89 de             	mov    %rbx,%r14
  800b39:	49 83 ee 01          	sub    $0x1,%r14
  800b3d:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b42:	75 f5                	jne    800b39 <vprintfmt+0x638>
  800b44:	e9 e2 f9 ff ff       	jmpq   80052b <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b49:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b4d:	74 06                	je     800b55 <vprintfmt+0x654>
  800b4f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b53:	7f 21                	jg     800b76 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b55:	bf 28 00 00 00       	mov    $0x28,%edi
  800b5a:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800b61:	00 00 00 
  800b64:	b8 28 00 00 00       	mov    $0x28,%eax
  800b69:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b6d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b71:	e9 82 fc ff ff       	jmpq   8007f8 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b76:	49 63 f4             	movslq %r12d,%rsi
  800b79:	48 bf bb 11 80 00 00 	movabs $0x8011bb,%rdi
  800b80:	00 00 00 
  800b83:	48 b8 d8 0c 80 00 00 	movabs $0x800cd8,%rax
  800b8a:	00 00 00 
  800b8d:	ff d0                	callq  *%rax
  800b8f:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800b92:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800b95:	48 be bb 11 80 00 00 	movabs $0x8011bb,%rsi
  800b9c:	00 00 00 
  800b9f:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	0f 8f f2 fb ff ff    	jg     80079d <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bab:	48 bb bc 11 80 00 00 	movabs $0x8011bc,%rbx
  800bb2:	00 00 00 
  800bb5:	b8 28 00 00 00       	mov    $0x28,%eax
  800bba:	bf 28 00 00 00       	mov    $0x28,%edi
  800bbf:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bc3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bc7:	e9 2c fc ff ff       	jmpq   8007f8 <vprintfmt+0x2f7>
}
  800bcc:	48 83 c4 48          	add    $0x48,%rsp
  800bd0:	5b                   	pop    %rbx
  800bd1:	41 5c                	pop    %r12
  800bd3:	41 5d                	pop    %r13
  800bd5:	41 5e                	pop    %r14
  800bd7:	41 5f                	pop    %r15
  800bd9:	5d                   	pop    %rbp
  800bda:	c3                   	retq   

0000000000800bdb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bdb:	55                   	push   %rbp
  800bdc:	48 89 e5             	mov    %rsp,%rbp
  800bdf:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800be3:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800be7:	48 63 c6             	movslq %esi,%rax
  800bea:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800bef:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800bf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800bfa:	48 85 ff             	test   %rdi,%rdi
  800bfd:	74 2a                	je     800c29 <vsnprintf+0x4e>
  800bff:	85 f6                	test   %esi,%esi
  800c01:	7e 26                	jle    800c29 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c03:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c07:	48 bf 63 04 80 00 00 	movabs $0x800463,%rdi
  800c0e:	00 00 00 
  800c11:	48 b8 01 05 80 00 00 	movabs $0x800501,%rax
  800c18:	00 00 00 
  800c1b:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c1d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c21:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c24:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c27:	c9                   	leaveq 
  800c28:	c3                   	retq   
    return -E_INVAL;
  800c29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c2e:	eb f7                	jmp    800c27 <vsnprintf+0x4c>

0000000000800c30 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c30:	55                   	push   %rbp
  800c31:	48 89 e5             	mov    %rsp,%rbp
  800c34:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c3b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c42:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c49:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c50:	84 c0                	test   %al,%al
  800c52:	74 20                	je     800c74 <snprintf+0x44>
  800c54:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c58:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c5c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c60:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c64:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c68:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c6c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c70:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c74:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c7b:	00 00 00 
  800c7e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800c85:	00 00 00 
  800c88:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800c8c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800c93:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800c9a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800ca1:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800ca8:	48 b8 db 0b 80 00 00 	movabs $0x800bdb,%rax
  800caf:	00 00 00 
  800cb2:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cb4:	c9                   	leaveq 
  800cb5:	c3                   	retq   

0000000000800cb6 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cb6:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cb9:	74 17                	je     800cd2 <strlen+0x1c>
  800cbb:	48 89 fa             	mov    %rdi,%rdx
  800cbe:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cc3:	29 f9                	sub    %edi,%ecx
    n++;
  800cc5:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cc8:	48 83 c2 01          	add    $0x1,%rdx
  800ccc:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ccf:	75 f4                	jne    800cc5 <strlen+0xf>
  800cd1:	c3                   	retq   
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cd7:	c3                   	retq   

0000000000800cd8 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	48 85 f6             	test   %rsi,%rsi
  800cdb:	74 24                	je     800d01 <strnlen+0x29>
  800cdd:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ce0:	74 25                	je     800d07 <strnlen+0x2f>
  800ce2:	48 01 fe             	add    %rdi,%rsi
  800ce5:	48 89 fa             	mov    %rdi,%rdx
  800ce8:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ced:	29 f9                	sub    %edi,%ecx
    n++;
  800cef:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf2:	48 83 c2 01          	add    $0x1,%rdx
  800cf6:	48 39 f2             	cmp    %rsi,%rdx
  800cf9:	74 11                	je     800d0c <strnlen+0x34>
  800cfb:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cfe:	75 ef                	jne    800cef <strnlen+0x17>
  800d00:	c3                   	retq   
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	c3                   	retq   
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d0c:	c3                   	retq   

0000000000800d0d <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d0d:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d19:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d1c:	48 83 c2 01          	add    $0x1,%rdx
  800d20:	84 c9                	test   %cl,%cl
  800d22:	75 f1                	jne    800d15 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d24:	c3                   	retq   

0000000000800d25 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d25:	55                   	push   %rbp
  800d26:	48 89 e5             	mov    %rsp,%rbp
  800d29:	41 54                	push   %r12
  800d2b:	53                   	push   %rbx
  800d2c:	48 89 fb             	mov    %rdi,%rbx
  800d2f:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d32:	48 b8 b6 0c 80 00 00 	movabs $0x800cb6,%rax
  800d39:	00 00 00 
  800d3c:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d3e:	48 63 f8             	movslq %eax,%rdi
  800d41:	48 01 df             	add    %rbx,%rdi
  800d44:	4c 89 e6             	mov    %r12,%rsi
  800d47:	48 b8 0d 0d 80 00 00 	movabs $0x800d0d,%rax
  800d4e:	00 00 00 
  800d51:	ff d0                	callq  *%rax
  return dst;
}
  800d53:	48 89 d8             	mov    %rbx,%rax
  800d56:	5b                   	pop    %rbx
  800d57:	41 5c                	pop    %r12
  800d59:	5d                   	pop    %rbp
  800d5a:	c3                   	retq   

0000000000800d5b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d5b:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d5e:	48 85 d2             	test   %rdx,%rdx
  800d61:	74 1f                	je     800d82 <strncpy+0x27>
  800d63:	48 01 fa             	add    %rdi,%rdx
  800d66:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d69:	48 83 c1 01          	add    $0x1,%rcx
  800d6d:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d71:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d75:	41 80 f8 01          	cmp    $0x1,%r8b
  800d79:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d7d:	48 39 ca             	cmp    %rcx,%rdx
  800d80:	75 e7                	jne    800d69 <strncpy+0xe>
  }
  return ret;
}
  800d82:	c3                   	retq   

0000000000800d83 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d83:	48 89 f8             	mov    %rdi,%rax
  800d86:	48 85 d2             	test   %rdx,%rdx
  800d89:	74 36                	je     800dc1 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800d8b:	48 83 fa 01          	cmp    $0x1,%rdx
  800d8f:	74 2d                	je     800dbe <strlcpy+0x3b>
  800d91:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d95:	45 84 c0             	test   %r8b,%r8b
  800d98:	74 24                	je     800dbe <strlcpy+0x3b>
  800d9a:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800d9e:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800da3:	48 83 c0 01          	add    $0x1,%rax
  800da7:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800dab:	48 39 d1             	cmp    %rdx,%rcx
  800dae:	74 0e                	je     800dbe <strlcpy+0x3b>
  800db0:	48 83 c1 01          	add    $0x1,%rcx
  800db4:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800db9:	45 84 c0             	test   %r8b,%r8b
  800dbc:	75 e5                	jne    800da3 <strlcpy+0x20>
    *dst = '\0';
  800dbe:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dc1:	48 29 f8             	sub    %rdi,%rax
}
  800dc4:	c3                   	retq   

0000000000800dc5 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dc5:	0f b6 07             	movzbl (%rdi),%eax
  800dc8:	84 c0                	test   %al,%al
  800dca:	74 17                	je     800de3 <strcmp+0x1e>
  800dcc:	3a 06                	cmp    (%rsi),%al
  800dce:	75 13                	jne    800de3 <strcmp+0x1e>
    p++, q++;
  800dd0:	48 83 c7 01          	add    $0x1,%rdi
  800dd4:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800dd8:	0f b6 07             	movzbl (%rdi),%eax
  800ddb:	84 c0                	test   %al,%al
  800ddd:	74 04                	je     800de3 <strcmp+0x1e>
  800ddf:	3a 06                	cmp    (%rsi),%al
  800de1:	74 ed                	je     800dd0 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800de3:	0f b6 c0             	movzbl %al,%eax
  800de6:	0f b6 16             	movzbl (%rsi),%edx
  800de9:	29 d0                	sub    %edx,%eax
}
  800deb:	c3                   	retq   

0000000000800dec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800dec:	48 85 d2             	test   %rdx,%rdx
  800def:	74 2f                	je     800e20 <strncmp+0x34>
  800df1:	0f b6 07             	movzbl (%rdi),%eax
  800df4:	84 c0                	test   %al,%al
  800df6:	74 1f                	je     800e17 <strncmp+0x2b>
  800df8:	3a 06                	cmp    (%rsi),%al
  800dfa:	75 1b                	jne    800e17 <strncmp+0x2b>
  800dfc:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800dff:	48 83 c7 01          	add    $0x1,%rdi
  800e03:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e07:	48 39 d7             	cmp    %rdx,%rdi
  800e0a:	74 1a                	je     800e26 <strncmp+0x3a>
  800e0c:	0f b6 07             	movzbl (%rdi),%eax
  800e0f:	84 c0                	test   %al,%al
  800e11:	74 04                	je     800e17 <strncmp+0x2b>
  800e13:	3a 06                	cmp    (%rsi),%al
  800e15:	74 e8                	je     800dff <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e17:	0f b6 07             	movzbl (%rdi),%eax
  800e1a:	0f b6 16             	movzbl (%rsi),%edx
  800e1d:	29 d0                	sub    %edx,%eax
}
  800e1f:	c3                   	retq   
    return 0;
  800e20:	b8 00 00 00 00       	mov    $0x0,%eax
  800e25:	c3                   	retq   
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2b:	c3                   	retq   

0000000000800e2c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e2c:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e2e:	0f b6 07             	movzbl (%rdi),%eax
  800e31:	84 c0                	test   %al,%al
  800e33:	74 1e                	je     800e53 <strchr+0x27>
    if (*s == c)
  800e35:	40 38 c6             	cmp    %al,%sil
  800e38:	74 1f                	je     800e59 <strchr+0x2d>
  for (; *s; s++)
  800e3a:	48 83 c7 01          	add    $0x1,%rdi
  800e3e:	0f b6 07             	movzbl (%rdi),%eax
  800e41:	84 c0                	test   %al,%al
  800e43:	74 08                	je     800e4d <strchr+0x21>
    if (*s == c)
  800e45:	38 d0                	cmp    %dl,%al
  800e47:	75 f1                	jne    800e3a <strchr+0xe>
  for (; *s; s++)
  800e49:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e4c:	c3                   	retq   
  return 0;
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e52:	c3                   	retq   
  800e53:	b8 00 00 00 00       	mov    $0x0,%eax
  800e58:	c3                   	retq   
    if (*s == c)
  800e59:	48 89 f8             	mov    %rdi,%rax
  800e5c:	c3                   	retq   

0000000000800e5d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e5d:	48 89 f8             	mov    %rdi,%rax
  800e60:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e62:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e65:	40 38 f2             	cmp    %sil,%dl
  800e68:	74 13                	je     800e7d <strfind+0x20>
  800e6a:	84 d2                	test   %dl,%dl
  800e6c:	74 0f                	je     800e7d <strfind+0x20>
  for (; *s; s++)
  800e6e:	48 83 c0 01          	add    $0x1,%rax
  800e72:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e75:	38 ca                	cmp    %cl,%dl
  800e77:	74 04                	je     800e7d <strfind+0x20>
  800e79:	84 d2                	test   %dl,%dl
  800e7b:	75 f1                	jne    800e6e <strfind+0x11>
      break;
  return (char *)s;
}
  800e7d:	c3                   	retq   

0000000000800e7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e7e:	48 85 d2             	test   %rdx,%rdx
  800e81:	74 3a                	je     800ebd <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e83:	48 89 f8             	mov    %rdi,%rax
  800e86:	48 09 d0             	or     %rdx,%rax
  800e89:	a8 03                	test   $0x3,%al
  800e8b:	75 28                	jne    800eb5 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800e8d:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	c1 e0 08             	shl    $0x8,%eax
  800e96:	89 f1                	mov    %esi,%ecx
  800e98:	c1 e1 18             	shl    $0x18,%ecx
  800e9b:	41 89 f0             	mov    %esi,%r8d
  800e9e:	41 c1 e0 10          	shl    $0x10,%r8d
  800ea2:	44 09 c1             	or     %r8d,%ecx
  800ea5:	09 ce                	or     %ecx,%esi
  800ea7:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ea9:	48 c1 ea 02          	shr    $0x2,%rdx
  800ead:	48 89 d1             	mov    %rdx,%rcx
  800eb0:	fc                   	cld    
  800eb1:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eb3:	eb 08                	jmp    800ebd <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800eb5:	89 f0                	mov    %esi,%eax
  800eb7:	48 89 d1             	mov    %rdx,%rcx
  800eba:	fc                   	cld    
  800ebb:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ebd:	48 89 f8             	mov    %rdi,%rax
  800ec0:	c3                   	retq   

0000000000800ec1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ec1:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ec4:	48 39 fe             	cmp    %rdi,%rsi
  800ec7:	73 40                	jae    800f09 <memmove+0x48>
  800ec9:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ecd:	48 39 f9             	cmp    %rdi,%rcx
  800ed0:	76 37                	jbe    800f09 <memmove+0x48>
    s += n;
    d += n;
  800ed2:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ed6:	48 89 fe             	mov    %rdi,%rsi
  800ed9:	48 09 d6             	or     %rdx,%rsi
  800edc:	48 09 ce             	or     %rcx,%rsi
  800edf:	40 f6 c6 03          	test   $0x3,%sil
  800ee3:	75 14                	jne    800ef9 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800ee5:	48 83 ef 04          	sub    $0x4,%rdi
  800ee9:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800eed:	48 c1 ea 02          	shr    $0x2,%rdx
  800ef1:	48 89 d1             	mov    %rdx,%rcx
  800ef4:	fd                   	std    
  800ef5:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800ef7:	eb 0e                	jmp    800f07 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800ef9:	48 83 ef 01          	sub    $0x1,%rdi
  800efd:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f01:	48 89 d1             	mov    %rdx,%rcx
  800f04:	fd                   	std    
  800f05:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f07:	fc                   	cld    
  800f08:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f09:	48 89 c1             	mov    %rax,%rcx
  800f0c:	48 09 d1             	or     %rdx,%rcx
  800f0f:	48 09 f1             	or     %rsi,%rcx
  800f12:	f6 c1 03             	test   $0x3,%cl
  800f15:	75 0e                	jne    800f25 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f17:	48 c1 ea 02          	shr    $0x2,%rdx
  800f1b:	48 89 d1             	mov    %rdx,%rcx
  800f1e:	48 89 c7             	mov    %rax,%rdi
  800f21:	fc                   	cld    
  800f22:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f24:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f25:	48 89 c7             	mov    %rax,%rdi
  800f28:	48 89 d1             	mov    %rdx,%rcx
  800f2b:	fc                   	cld    
  800f2c:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f2e:	c3                   	retq   

0000000000800f2f <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f2f:	55                   	push   %rbp
  800f30:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f33:	48 b8 c1 0e 80 00 00 	movabs $0x800ec1,%rax
  800f3a:	00 00 00 
  800f3d:	ff d0                	callq  *%rax
}
  800f3f:	5d                   	pop    %rbp
  800f40:	c3                   	retq   

0000000000800f41 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f41:	55                   	push   %rbp
  800f42:	48 89 e5             	mov    %rsp,%rbp
  800f45:	41 57                	push   %r15
  800f47:	41 56                	push   %r14
  800f49:	41 55                	push   %r13
  800f4b:	41 54                	push   %r12
  800f4d:	53                   	push   %rbx
  800f4e:	48 83 ec 08          	sub    $0x8,%rsp
  800f52:	49 89 fe             	mov    %rdi,%r14
  800f55:	49 89 f7             	mov    %rsi,%r15
  800f58:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f5b:	48 89 f7             	mov    %rsi,%rdi
  800f5e:	48 b8 b6 0c 80 00 00 	movabs $0x800cb6,%rax
  800f65:	00 00 00 
  800f68:	ff d0                	callq  *%rax
  800f6a:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f6d:	4c 89 ee             	mov    %r13,%rsi
  800f70:	4c 89 f7             	mov    %r14,%rdi
  800f73:	48 b8 d8 0c 80 00 00 	movabs $0x800cd8,%rax
  800f7a:	00 00 00 
  800f7d:	ff d0                	callq  *%rax
  800f7f:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f82:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800f86:	4d 39 e5             	cmp    %r12,%r13
  800f89:	74 26                	je     800fb1 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800f8b:	4c 89 e8             	mov    %r13,%rax
  800f8e:	4c 29 e0             	sub    %r12,%rax
  800f91:	48 39 d8             	cmp    %rbx,%rax
  800f94:	76 2a                	jbe    800fc0 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800f96:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800f9a:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800f9e:	4c 89 fe             	mov    %r15,%rsi
  800fa1:	48 b8 2f 0f 80 00 00 	movabs $0x800f2f,%rax
  800fa8:	00 00 00 
  800fab:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fad:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fb1:	48 83 c4 08          	add    $0x8,%rsp
  800fb5:	5b                   	pop    %rbx
  800fb6:	41 5c                	pop    %r12
  800fb8:	41 5d                	pop    %r13
  800fba:	41 5e                	pop    %r14
  800fbc:	41 5f                	pop    %r15
  800fbe:	5d                   	pop    %rbp
  800fbf:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fc0:	49 83 ed 01          	sub    $0x1,%r13
  800fc4:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fc8:	4c 89 ea             	mov    %r13,%rdx
  800fcb:	4c 89 fe             	mov    %r15,%rsi
  800fce:	48 b8 2f 0f 80 00 00 	movabs $0x800f2f,%rax
  800fd5:	00 00 00 
  800fd8:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800fda:	4d 01 ee             	add    %r13,%r14
  800fdd:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800fe2:	eb c9                	jmp    800fad <strlcat+0x6c>

0000000000800fe4 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fe4:	48 85 d2             	test   %rdx,%rdx
  800fe7:	74 3a                	je     801023 <memcmp+0x3f>
    if (*s1 != *s2)
  800fe9:	0f b6 0f             	movzbl (%rdi),%ecx
  800fec:	44 0f b6 06          	movzbl (%rsi),%r8d
  800ff0:	44 38 c1             	cmp    %r8b,%cl
  800ff3:	75 1d                	jne    801012 <memcmp+0x2e>
  800ff5:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800ffa:	48 39 d0             	cmp    %rdx,%rax
  800ffd:	74 1e                	je     80101d <memcmp+0x39>
    if (*s1 != *s2)
  800fff:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801003:	48 83 c0 01          	add    $0x1,%rax
  801007:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  80100d:	44 38 c1             	cmp    %r8b,%cl
  801010:	74 e8                	je     800ffa <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801012:	0f b6 c1             	movzbl %cl,%eax
  801015:	45 0f b6 c0          	movzbl %r8b,%r8d
  801019:	44 29 c0             	sub    %r8d,%eax
  80101c:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
  801022:	c3                   	retq   
  801023:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801028:	c3                   	retq   

0000000000801029 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801029:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80102d:	48 39 c7             	cmp    %rax,%rdi
  801030:	73 19                	jae    80104b <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801032:	89 f2                	mov    %esi,%edx
  801034:	40 38 37             	cmp    %sil,(%rdi)
  801037:	74 16                	je     80104f <memfind+0x26>
  for (; s < ends; s++)
  801039:	48 83 c7 01          	add    $0x1,%rdi
  80103d:	48 39 f8             	cmp    %rdi,%rax
  801040:	74 08                	je     80104a <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801042:	38 17                	cmp    %dl,(%rdi)
  801044:	75 f3                	jne    801039 <memfind+0x10>
  for (; s < ends; s++)
  801046:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801049:	c3                   	retq   
  80104a:	c3                   	retq   
  for (; s < ends; s++)
  80104b:	48 89 f8             	mov    %rdi,%rax
  80104e:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80104f:	48 89 f8             	mov    %rdi,%rax
  801052:	c3                   	retq   

0000000000801053 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801053:	0f b6 07             	movzbl (%rdi),%eax
  801056:	3c 20                	cmp    $0x20,%al
  801058:	74 04                	je     80105e <strtol+0xb>
  80105a:	3c 09                	cmp    $0x9,%al
  80105c:	75 0f                	jne    80106d <strtol+0x1a>
    s++;
  80105e:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801062:	0f b6 07             	movzbl (%rdi),%eax
  801065:	3c 20                	cmp    $0x20,%al
  801067:	74 f5                	je     80105e <strtol+0xb>
  801069:	3c 09                	cmp    $0x9,%al
  80106b:	74 f1                	je     80105e <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80106d:	3c 2b                	cmp    $0x2b,%al
  80106f:	74 2b                	je     80109c <strtol+0x49>
  int neg  = 0;
  801071:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801077:	3c 2d                	cmp    $0x2d,%al
  801079:	74 2d                	je     8010a8 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80107b:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801081:	75 0f                	jne    801092 <strtol+0x3f>
  801083:	80 3f 30             	cmpb   $0x30,(%rdi)
  801086:	74 2c                	je     8010b4 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801088:	85 d2                	test   %edx,%edx
  80108a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108f:	0f 44 d0             	cmove  %eax,%edx
  801092:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801097:	4c 63 d2             	movslq %edx,%r10
  80109a:	eb 5c                	jmp    8010f8 <strtol+0xa5>
    s++;
  80109c:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010a0:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010a6:	eb d3                	jmp    80107b <strtol+0x28>
    s++, neg = 1;
  8010a8:	48 83 c7 01          	add    $0x1,%rdi
  8010ac:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010b2:	eb c7                	jmp    80107b <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b4:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010b8:	74 0f                	je     8010c9 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010ba:	85 d2                	test   %edx,%edx
  8010bc:	75 d4                	jne    801092 <strtol+0x3f>
    s++, base = 8;
  8010be:	48 83 c7 01          	add    $0x1,%rdi
  8010c2:	ba 08 00 00 00       	mov    $0x8,%edx
  8010c7:	eb c9                	jmp    801092 <strtol+0x3f>
    s += 2, base = 16;
  8010c9:	48 83 c7 02          	add    $0x2,%rdi
  8010cd:	ba 10 00 00 00       	mov    $0x10,%edx
  8010d2:	eb be                	jmp    801092 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010d4:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010d8:	41 80 f8 19          	cmp    $0x19,%r8b
  8010dc:	77 2f                	ja     80110d <strtol+0xba>
      dig = *s - 'a' + 10;
  8010de:	44 0f be c1          	movsbl %cl,%r8d
  8010e2:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8010e6:	39 d1                	cmp    %edx,%ecx
  8010e8:	7d 37                	jge    801121 <strtol+0xce>
    s++, val = (val * base) + dig;
  8010ea:	48 83 c7 01          	add    $0x1,%rdi
  8010ee:	49 0f af c2          	imul   %r10,%rax
  8010f2:	48 63 c9             	movslq %ecx,%rcx
  8010f5:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8010f8:	0f b6 0f             	movzbl (%rdi),%ecx
  8010fb:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8010ff:	41 80 f8 09          	cmp    $0x9,%r8b
  801103:	77 cf                	ja     8010d4 <strtol+0x81>
      dig = *s - '0';
  801105:	0f be c9             	movsbl %cl,%ecx
  801108:	83 e9 30             	sub    $0x30,%ecx
  80110b:	eb d9                	jmp    8010e6 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80110d:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801111:	41 80 f8 19          	cmp    $0x19,%r8b
  801115:	77 0a                	ja     801121 <strtol+0xce>
      dig = *s - 'A' + 10;
  801117:	44 0f be c1          	movsbl %cl,%r8d
  80111b:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80111f:	eb c5                	jmp    8010e6 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801121:	48 85 f6             	test   %rsi,%rsi
  801124:	74 03                	je     801129 <strtol+0xd6>
    *endptr = (char *)s;
  801126:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801129:	48 89 c2             	mov    %rax,%rdx
  80112c:	48 f7 da             	neg    %rdx
  80112f:	45 85 c9             	test   %r9d,%r9d
  801132:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801136:	c3                   	retq   
  801137:	90                   	nop
