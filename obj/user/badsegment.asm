
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  80007e:	48 b8 a0 01 80 00 00 	movabs $0x8001a0,%rax
  800085:	00 00 00 
  800088:	ff d0                	callq  *%rax
  80008a:	83 e0 1f             	and    $0x1f,%eax
  80008d:	48 89 c2             	mov    %rax,%rdx
  800090:	48 c1 e2 05          	shl    $0x5,%rdx
  800094:	48 29 c2             	sub    %rax,%rdx
  800097:	48 89 d0             	mov    %rdx,%rax
  80009a:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000a1:	00 00 00 
  8000a4:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000a8:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000af:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000b2:	45 85 ed             	test   %r13d,%r13d
  8000b5:	7e 0d                	jle    8000c4 <libmain+0x93>
    binaryname = argv[0];
  8000b7:	49 8b 06             	mov    (%r14),%rax
  8000ba:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000c1:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000c4:	4c 89 f6             	mov    %r14,%rsi
  8000c7:	44 89 ef             	mov    %r13d,%edi
  8000ca:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000d1:	00 00 00 
  8000d4:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000d6:	48 b8 eb 00 80 00 00 	movabs $0x8000eb,%rax
  8000dd:	00 00 00 
  8000e0:	ff d0                	callq  *%rax
#endif
}
  8000e2:	5b                   	pop    %rbx
  8000e3:	41 5c                	pop    %r12
  8000e5:	41 5d                	pop    %r13
  8000e7:	41 5e                	pop    %r14
  8000e9:	5d                   	pop    %rbp
  8000ea:	c3                   	retq   

00000000008000eb <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000eb:	55                   	push   %rbp
  8000ec:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f4:	48 b8 40 01 80 00 00 	movabs $0x800140,%rax
  8000fb:	00 00 00 
  8000fe:	ff d0                	callq  *%rax
}
  800100:	5d                   	pop    %rbp
  800101:	c3                   	retq   

0000000000800102 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800102:	55                   	push   %rbp
  800103:	48 89 e5             	mov    %rsp,%rbp
  800106:	53                   	push   %rbx
  800107:	48 89 fa             	mov    %rdi,%rdx
  80010a:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80010d:	b8 00 00 00 00       	mov    $0x0,%eax
  800112:	48 89 c3             	mov    %rax,%rbx
  800115:	48 89 c7             	mov    %rax,%rdi
  800118:	48 89 c6             	mov    %rax,%rsi
  80011b:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80011d:	5b                   	pop    %rbx
  80011e:	5d                   	pop    %rbp
  80011f:	c3                   	retq   

0000000000800120 <sys_cgetc>:

int
sys_cgetc(void) {
  800120:	55                   	push   %rbp
  800121:	48 89 e5             	mov    %rsp,%rbp
  800124:	53                   	push   %rbx
  asm volatile("int %1\n"
  800125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012a:	b8 01 00 00 00       	mov    $0x1,%eax
  80012f:	48 89 ca             	mov    %rcx,%rdx
  800132:	48 89 cb             	mov    %rcx,%rbx
  800135:	48 89 cf             	mov    %rcx,%rdi
  800138:	48 89 ce             	mov    %rcx,%rsi
  80013b:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80013d:	5b                   	pop    %rbx
  80013e:	5d                   	pop    %rbp
  80013f:	c3                   	retq   

0000000000800140 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800140:	55                   	push   %rbp
  800141:	48 89 e5             	mov    %rsp,%rbp
  800144:	53                   	push   %rbx
  800145:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800149:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80014c:	be 00 00 00 00       	mov    $0x0,%esi
  800151:	b8 03 00 00 00       	mov    $0x3,%eax
  800156:	48 89 f1             	mov    %rsi,%rcx
  800159:	48 89 f3             	mov    %rsi,%rbx
  80015c:	48 89 f7             	mov    %rsi,%rdi
  80015f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800161:	48 85 c0             	test   %rax,%rax
  800164:	7f 07                	jg     80016d <sys_env_destroy+0x2d>
}
  800166:	48 83 c4 08          	add    $0x8,%rsp
  80016a:	5b                   	pop    %rbx
  80016b:	5d                   	pop    %rbp
  80016c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80016d:	49 89 c0             	mov    %rax,%r8
  800170:	b9 03 00 00 00       	mov    $0x3,%ecx
  800175:	48 ba 70 11 80 00 00 	movabs $0x801170,%rdx
  80017c:	00 00 00 
  80017f:	be 22 00 00 00       	mov    $0x22,%esi
  800184:	48 bf 8f 11 80 00 00 	movabs $0x80118f,%rdi
  80018b:	00 00 00 
  80018e:	b8 00 00 00 00       	mov    $0x0,%eax
  800193:	49 b9 c0 01 80 00 00 	movabs $0x8001c0,%r9
  80019a:	00 00 00 
  80019d:	41 ff d1             	callq  *%r9

00000000008001a0 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001a0:	55                   	push   %rbp
  8001a1:	48 89 e5             	mov    %rsp,%rbp
  8001a4:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8001af:	48 89 ca             	mov    %rcx,%rdx
  8001b2:	48 89 cb             	mov    %rcx,%rbx
  8001b5:	48 89 cf             	mov    %rcx,%rdi
  8001b8:	48 89 ce             	mov    %rcx,%rsi
  8001bb:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001bd:	5b                   	pop    %rbx
  8001be:	5d                   	pop    %rbp
  8001bf:	c3                   	retq   

00000000008001c0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001c0:	55                   	push   %rbp
  8001c1:	48 89 e5             	mov    %rsp,%rbp
  8001c4:	41 56                	push   %r14
  8001c6:	41 55                	push   %r13
  8001c8:	41 54                	push   %r12
  8001ca:	53                   	push   %rbx
  8001cb:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001d2:	49 89 fd             	mov    %rdi,%r13
  8001d5:	41 89 f6             	mov    %esi,%r14d
  8001d8:	49 89 d4             	mov    %rdx,%r12
  8001db:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001e2:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001e9:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001f0:	84 c0                	test   %al,%al
  8001f2:	74 26                	je     80021a <_panic+0x5a>
  8001f4:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001fb:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800202:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800206:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80020a:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80020e:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800212:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800216:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80021a:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800221:	00 00 00 
  800224:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  80022b:	00 00 00 
  80022e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800232:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800239:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800240:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800247:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80024e:	00 00 00 
  800251:	48 8b 18             	mov    (%rax),%rbx
  800254:	48 b8 a0 01 80 00 00 	movabs $0x8001a0,%rax
  80025b:	00 00 00 
  80025e:	ff d0                	callq  *%rax
  800260:	45 89 f0             	mov    %r14d,%r8d
  800263:	4c 89 e9             	mov    %r13,%rcx
  800266:	48 89 da             	mov    %rbx,%rdx
  800269:	89 c6                	mov    %eax,%esi
  80026b:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  800272:	00 00 00 
  800275:	b8 00 00 00 00       	mov    $0x0,%eax
  80027a:	48 bb 62 03 80 00 00 	movabs $0x800362,%rbx
  800281:	00 00 00 
  800284:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800286:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80028d:	4c 89 e7             	mov    %r12,%rdi
  800290:	48 b8 fa 02 80 00 00 	movabs $0x8002fa,%rax
  800297:	00 00 00 
  80029a:	ff d0                	callq  *%rax
  cprintf("\n");
  80029c:	48 bf c8 11 80 00 00 	movabs $0x8011c8,%rdi
  8002a3:	00 00 00 
  8002a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ab:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002ad:	cc                   	int3   
  while (1)
  8002ae:	eb fd                	jmp    8002ad <_panic+0xed>

00000000008002b0 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002b0:	55                   	push   %rbp
  8002b1:	48 89 e5             	mov    %rsp,%rbp
  8002b4:	53                   	push   %rbx
  8002b5:	48 83 ec 08          	sub    $0x8,%rsp
  8002b9:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002bc:	8b 06                	mov    (%rsi),%eax
  8002be:	8d 50 01             	lea    0x1(%rax),%edx
  8002c1:	89 16                	mov    %edx,(%rsi)
  8002c3:	48 98                	cltq   
  8002c5:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002ca:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002d0:	74 0b                	je     8002dd <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002d2:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002d6:	48 83 c4 08          	add    $0x8,%rsp
  8002da:	5b                   	pop    %rbx
  8002db:	5d                   	pop    %rbp
  8002dc:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002dd:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002e1:	be ff 00 00 00       	mov    $0xff,%esi
  8002e6:	48 b8 02 01 80 00 00 	movabs $0x800102,%rax
  8002ed:	00 00 00 
  8002f0:	ff d0                	callq  *%rax
    b->idx = 0;
  8002f2:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002f8:	eb d8                	jmp    8002d2 <putch+0x22>

00000000008002fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002fa:	55                   	push   %rbp
  8002fb:	48 89 e5             	mov    %rsp,%rbp
  8002fe:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800305:	48 89 fa             	mov    %rdi,%rdx
  800308:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80030b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800312:	00 00 00 
  b.cnt = 0;
  800315:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80031c:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80031f:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800326:	48 bf b0 02 80 00 00 	movabs $0x8002b0,%rdi
  80032d:	00 00 00 
  800330:	48 b8 20 05 80 00 00 	movabs $0x800520,%rax
  800337:	00 00 00 
  80033a:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  80033c:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800343:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80034a:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80034e:	48 b8 02 01 80 00 00 	movabs $0x800102,%rax
  800355:	00 00 00 
  800358:	ff d0                	callq  *%rax

  return b.cnt;
}
  80035a:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800360:	c9                   	leaveq 
  800361:	c3                   	retq   

0000000000800362 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800362:	55                   	push   %rbp
  800363:	48 89 e5             	mov    %rsp,%rbp
  800366:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80036d:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800374:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80037b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800382:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800389:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800390:	84 c0                	test   %al,%al
  800392:	74 20                	je     8003b4 <cprintf+0x52>
  800394:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800398:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80039c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003a0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003a4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003a8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003ac:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003b0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003b4:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003bb:	00 00 00 
  8003be:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003c5:	00 00 00 
  8003c8:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003cc:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003d3:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003da:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003e1:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003e8:	48 b8 fa 02 80 00 00 	movabs $0x8002fa,%rax
  8003ef:	00 00 00 
  8003f2:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003f4:	c9                   	leaveq 
  8003f5:	c3                   	retq   

00000000008003f6 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003f6:	55                   	push   %rbp
  8003f7:	48 89 e5             	mov    %rsp,%rbp
  8003fa:	41 57                	push   %r15
  8003fc:	41 56                	push   %r14
  8003fe:	41 55                	push   %r13
  800400:	41 54                	push   %r12
  800402:	53                   	push   %rbx
  800403:	48 83 ec 18          	sub    $0x18,%rsp
  800407:	49 89 fc             	mov    %rdi,%r12
  80040a:	49 89 f5             	mov    %rsi,%r13
  80040d:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800411:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800414:	41 89 cf             	mov    %ecx,%r15d
  800417:	49 39 d7             	cmp    %rdx,%r15
  80041a:	76 45                	jbe    800461 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80041c:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800420:	85 db                	test   %ebx,%ebx
  800422:	7e 0e                	jle    800432 <printnum+0x3c>
      putch(padc, putdat);
  800424:	4c 89 ee             	mov    %r13,%rsi
  800427:	44 89 f7             	mov    %r14d,%edi
  80042a:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80042d:	83 eb 01             	sub    $0x1,%ebx
  800430:	75 f2                	jne    800424 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800432:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800436:	ba 00 00 00 00       	mov    $0x0,%edx
  80043b:	49 f7 f7             	div    %r15
  80043e:	48 b8 ca 11 80 00 00 	movabs $0x8011ca,%rax
  800445:	00 00 00 
  800448:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80044c:	4c 89 ee             	mov    %r13,%rsi
  80044f:	41 ff d4             	callq  *%r12
}
  800452:	48 83 c4 18          	add    $0x18,%rsp
  800456:	5b                   	pop    %rbx
  800457:	41 5c                	pop    %r12
  800459:	41 5d                	pop    %r13
  80045b:	41 5e                	pop    %r14
  80045d:	41 5f                	pop    %r15
  80045f:	5d                   	pop    %rbp
  800460:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800461:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
  80046a:	49 f7 f7             	div    %r15
  80046d:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800471:	48 89 c2             	mov    %rax,%rdx
  800474:	48 b8 f6 03 80 00 00 	movabs $0x8003f6,%rax
  80047b:	00 00 00 
  80047e:	ff d0                	callq  *%rax
  800480:	eb b0                	jmp    800432 <printnum+0x3c>

0000000000800482 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800482:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800486:	48 8b 06             	mov    (%rsi),%rax
  800489:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80048d:	73 0a                	jae    800499 <sprintputch+0x17>
    *b->buf++ = ch;
  80048f:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800493:	48 89 16             	mov    %rdx,(%rsi)
  800496:	40 88 38             	mov    %dil,(%rax)
}
  800499:	c3                   	retq   

000000000080049a <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80049a:	55                   	push   %rbp
  80049b:	48 89 e5             	mov    %rsp,%rbp
  80049e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004a5:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004ac:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004b3:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004ba:	84 c0                	test   %al,%al
  8004bc:	74 20                	je     8004de <printfmt+0x44>
  8004be:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004c2:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004c6:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004ca:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004ce:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004d2:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004d6:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004da:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004de:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004e5:	00 00 00 
  8004e8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004ef:	00 00 00 
  8004f2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004f6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004fd:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800504:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80050b:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800512:	48 b8 20 05 80 00 00 	movabs $0x800520,%rax
  800519:	00 00 00 
  80051c:	ff d0                	callq  *%rax
}
  80051e:	c9                   	leaveq 
  80051f:	c3                   	retq   

0000000000800520 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800520:	55                   	push   %rbp
  800521:	48 89 e5             	mov    %rsp,%rbp
  800524:	41 57                	push   %r15
  800526:	41 56                	push   %r14
  800528:	41 55                	push   %r13
  80052a:	41 54                	push   %r12
  80052c:	53                   	push   %rbx
  80052d:	48 83 ec 48          	sub    $0x48,%rsp
  800531:	49 89 fd             	mov    %rdi,%r13
  800534:	49 89 f7             	mov    %rsi,%r15
  800537:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80053a:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80053e:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800542:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800546:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80054a:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80054e:	41 0f b6 3e          	movzbl (%r14),%edi
  800552:	83 ff 25             	cmp    $0x25,%edi
  800555:	74 18                	je     80056f <vprintfmt+0x4f>
      if (ch == '\0')
  800557:	85 ff                	test   %edi,%edi
  800559:	0f 84 8c 06 00 00    	je     800beb <vprintfmt+0x6cb>
      putch(ch, putdat);
  80055f:	4c 89 fe             	mov    %r15,%rsi
  800562:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800565:	49 89 de             	mov    %rbx,%r14
  800568:	eb e0                	jmp    80054a <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80056a:	49 89 de             	mov    %rbx,%r14
  80056d:	eb db                	jmp    80054a <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80056f:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800573:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800577:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80057e:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800584:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800588:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80058d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800593:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800599:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80059e:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005a3:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005a7:	0f b6 13             	movzbl (%rbx),%edx
  8005aa:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005ad:	3c 55                	cmp    $0x55,%al
  8005af:	0f 87 8b 05 00 00    	ja     800b40 <vprintfmt+0x620>
  8005b5:	0f b6 c0             	movzbl %al,%eax
  8005b8:	49 bb 80 12 80 00 00 	movabs $0x801280,%r11
  8005bf:	00 00 00 
  8005c2:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005c6:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005c9:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005cd:	eb d4                	jmp    8005a3 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005cf:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005d2:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005d6:	eb cb                	jmp    8005a3 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005d8:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005db:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005df:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005e3:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005e6:	83 fa 09             	cmp    $0x9,%edx
  8005e9:	77 7e                	ja     800669 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005eb:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005ef:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005f3:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005f8:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005fc:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005ff:	83 fa 09             	cmp    $0x9,%edx
  800602:	76 e7                	jbe    8005eb <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800604:	4c 89 f3             	mov    %r14,%rbx
  800607:	eb 19                	jmp    800622 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800609:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80060c:	83 f8 2f             	cmp    $0x2f,%eax
  80060f:	77 2a                	ja     80063b <vprintfmt+0x11b>
  800611:	89 c2                	mov    %eax,%edx
  800613:	4c 01 d2             	add    %r10,%rdx
  800616:	83 c0 08             	add    $0x8,%eax
  800619:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80061c:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80061f:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800622:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800626:	0f 89 77 ff ff ff    	jns    8005a3 <vprintfmt+0x83>
          width = precision, precision = -1;
  80062c:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800630:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800636:	e9 68 ff ff ff       	jmpq   8005a3 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80063b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80063f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800643:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800647:	eb d3                	jmp    80061c <vprintfmt+0xfc>
        if (width < 0)
  800649:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80064c:	85 c0                	test   %eax,%eax
  80064e:	41 0f 48 c0          	cmovs  %r8d,%eax
  800652:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800655:	4c 89 f3             	mov    %r14,%rbx
  800658:	e9 46 ff ff ff       	jmpq   8005a3 <vprintfmt+0x83>
  80065d:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800660:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800664:	e9 3a ff ff ff       	jmpq   8005a3 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800669:	4c 89 f3             	mov    %r14,%rbx
  80066c:	eb b4                	jmp    800622 <vprintfmt+0x102>
        lflag++;
  80066e:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800671:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800674:	e9 2a ff ff ff       	jmpq   8005a3 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800679:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80067c:	83 f8 2f             	cmp    $0x2f,%eax
  80067f:	77 19                	ja     80069a <vprintfmt+0x17a>
  800681:	89 c2                	mov    %eax,%edx
  800683:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800687:	83 c0 08             	add    $0x8,%eax
  80068a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80068d:	4c 89 fe             	mov    %r15,%rsi
  800690:	8b 3a                	mov    (%rdx),%edi
  800692:	41 ff d5             	callq  *%r13
        break;
  800695:	e9 b0 fe ff ff       	jmpq   80054a <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80069a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80069e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006a2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006a6:	eb e5                	jmp    80068d <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006a8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006ab:	83 f8 2f             	cmp    $0x2f,%eax
  8006ae:	77 5b                	ja     80070b <vprintfmt+0x1eb>
  8006b0:	89 c2                	mov    %eax,%edx
  8006b2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006b6:	83 c0 08             	add    $0x8,%eax
  8006b9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006bc:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006be:	89 c8                	mov    %ecx,%eax
  8006c0:	c1 f8 1f             	sar    $0x1f,%eax
  8006c3:	31 c1                	xor    %eax,%ecx
  8006c5:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c7:	83 f9 09             	cmp    $0x9,%ecx
  8006ca:	7f 4d                	jg     800719 <vprintfmt+0x1f9>
  8006cc:	48 63 c1             	movslq %ecx,%rax
  8006cf:	48 ba 40 15 80 00 00 	movabs $0x801540,%rdx
  8006d6:	00 00 00 
  8006d9:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006dd:	48 85 c0             	test   %rax,%rax
  8006e0:	74 37                	je     800719 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006e2:	48 89 c1             	mov    %rax,%rcx
  8006e5:	48 ba eb 11 80 00 00 	movabs $0x8011eb,%rdx
  8006ec:	00 00 00 
  8006ef:	4c 89 fe             	mov    %r15,%rsi
  8006f2:	4c 89 ef             	mov    %r13,%rdi
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	48 bb 9a 04 80 00 00 	movabs $0x80049a,%rbx
  800701:	00 00 00 
  800704:	ff d3                	callq  *%rbx
  800706:	e9 3f fe ff ff       	jmpq   80054a <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80070b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80070f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800713:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800717:	eb a3                	jmp    8006bc <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800719:	48 ba e2 11 80 00 00 	movabs $0x8011e2,%rdx
  800720:	00 00 00 
  800723:	4c 89 fe             	mov    %r15,%rsi
  800726:	4c 89 ef             	mov    %r13,%rdi
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	48 bb 9a 04 80 00 00 	movabs $0x80049a,%rbx
  800735:	00 00 00 
  800738:	ff d3                	callq  *%rbx
  80073a:	e9 0b fe ff ff       	jmpq   80054a <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80073f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800742:	83 f8 2f             	cmp    $0x2f,%eax
  800745:	77 4b                	ja     800792 <vprintfmt+0x272>
  800747:	89 c2                	mov    %eax,%edx
  800749:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80074d:	83 c0 08             	add    $0x8,%eax
  800750:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800753:	48 8b 02             	mov    (%rdx),%rax
  800756:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80075a:	48 85 c0             	test   %rax,%rax
  80075d:	0f 84 05 04 00 00    	je     800b68 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800763:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800767:	7e 06                	jle    80076f <vprintfmt+0x24f>
  800769:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80076d:	75 31                	jne    8007a0 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800773:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800777:	0f b6 00             	movzbl (%rax),%eax
  80077a:	0f be f8             	movsbl %al,%edi
  80077d:	85 ff                	test   %edi,%edi
  80077f:	0f 84 c3 00 00 00    	je     800848 <vprintfmt+0x328>
  800785:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800789:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80078d:	e9 85 00 00 00       	jmpq   800817 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800792:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800796:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80079a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80079e:	eb b3                	jmp    800753 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007a0:	49 63 f4             	movslq %r12d,%rsi
  8007a3:	48 89 c7             	mov    %rax,%rdi
  8007a6:	48 b8 f7 0c 80 00 00 	movabs $0x800cf7,%rax
  8007ad:	00 00 00 
  8007b0:	ff d0                	callq  *%rax
  8007b2:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007b5:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007b8:	85 f6                	test   %esi,%esi
  8007ba:	7e 22                	jle    8007de <vprintfmt+0x2be>
            putch(padc, putdat);
  8007bc:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007c0:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007c4:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007c8:	4c 89 fe             	mov    %r15,%rsi
  8007cb:	89 df                	mov    %ebx,%edi
  8007cd:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007d0:	41 83 ec 01          	sub    $0x1,%r12d
  8007d4:	75 f2                	jne    8007c8 <vprintfmt+0x2a8>
  8007d6:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007da:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007de:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007e2:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007e6:	0f b6 00             	movzbl (%rax),%eax
  8007e9:	0f be f8             	movsbl %al,%edi
  8007ec:	85 ff                	test   %edi,%edi
  8007ee:	0f 84 56 fd ff ff    	je     80054a <vprintfmt+0x2a>
  8007f4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007f8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007fc:	eb 19                	jmp    800817 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007fe:	4c 89 fe             	mov    %r15,%rsi
  800801:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800804:	41 83 ee 01          	sub    $0x1,%r14d
  800808:	48 83 c3 01          	add    $0x1,%rbx
  80080c:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800810:	0f be f8             	movsbl %al,%edi
  800813:	85 ff                	test   %edi,%edi
  800815:	74 29                	je     800840 <vprintfmt+0x320>
  800817:	45 85 e4             	test   %r12d,%r12d
  80081a:	78 06                	js     800822 <vprintfmt+0x302>
  80081c:	41 83 ec 01          	sub    $0x1,%r12d
  800820:	78 48                	js     80086a <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800822:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800826:	74 d6                	je     8007fe <vprintfmt+0x2de>
  800828:	0f be c0             	movsbl %al,%eax
  80082b:	83 e8 20             	sub    $0x20,%eax
  80082e:	83 f8 5e             	cmp    $0x5e,%eax
  800831:	76 cb                	jbe    8007fe <vprintfmt+0x2de>
            putch('?', putdat);
  800833:	4c 89 fe             	mov    %r15,%rsi
  800836:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80083b:	41 ff d5             	callq  *%r13
  80083e:	eb c4                	jmp    800804 <vprintfmt+0x2e4>
  800840:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800844:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800848:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80084b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80084f:	0f 8e f5 fc ff ff    	jle    80054a <vprintfmt+0x2a>
          putch(' ', putdat);
  800855:	4c 89 fe             	mov    %r15,%rsi
  800858:	bf 20 00 00 00       	mov    $0x20,%edi
  80085d:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800860:	83 eb 01             	sub    $0x1,%ebx
  800863:	75 f0                	jne    800855 <vprintfmt+0x335>
  800865:	e9 e0 fc ff ff       	jmpq   80054a <vprintfmt+0x2a>
  80086a:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80086e:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800872:	eb d4                	jmp    800848 <vprintfmt+0x328>
  if (lflag >= 2)
  800874:	83 f9 01             	cmp    $0x1,%ecx
  800877:	7f 1d                	jg     800896 <vprintfmt+0x376>
  else if (lflag)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 5e                	je     8008db <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80087d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800880:	83 f8 2f             	cmp    $0x2f,%eax
  800883:	77 48                	ja     8008cd <vprintfmt+0x3ad>
  800885:	89 c2                	mov    %eax,%edx
  800887:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80088b:	83 c0 08             	add    $0x8,%eax
  80088e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800891:	48 8b 1a             	mov    (%rdx),%rbx
  800894:	eb 17                	jmp    8008ad <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800896:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800899:	83 f8 2f             	cmp    $0x2f,%eax
  80089c:	77 21                	ja     8008bf <vprintfmt+0x39f>
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a4:	83 c0 08             	add    $0x8,%eax
  8008a7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008aa:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008ad:	48 85 db             	test   %rbx,%rbx
  8008b0:	78 50                	js     800902 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008b2:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008ba:	e9 b4 01 00 00       	jmpq   800a73 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008bf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008cb:	eb dd                	jmp    8008aa <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008cd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d9:	eb b6                	jmp    800891 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008db:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008de:	83 f8 2f             	cmp    $0x2f,%eax
  8008e1:	77 11                	ja     8008f4 <vprintfmt+0x3d4>
  8008e3:	89 c2                	mov    %eax,%edx
  8008e5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e9:	83 c0 08             	add    $0x8,%eax
  8008ec:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ef:	48 63 1a             	movslq (%rdx),%rbx
  8008f2:	eb b9                	jmp    8008ad <vprintfmt+0x38d>
  8008f4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008f8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008fc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800900:	eb ed                	jmp    8008ef <vprintfmt+0x3cf>
          putch('-', putdat);
  800902:	4c 89 fe             	mov    %r15,%rsi
  800905:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80090a:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80090d:	48 89 da             	mov    %rbx,%rdx
  800910:	48 f7 da             	neg    %rdx
        base = 10;
  800913:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800918:	e9 56 01 00 00       	jmpq   800a73 <vprintfmt+0x553>
  if (lflag >= 2)
  80091d:	83 f9 01             	cmp    $0x1,%ecx
  800920:	7f 25                	jg     800947 <vprintfmt+0x427>
  else if (lflag)
  800922:	85 c9                	test   %ecx,%ecx
  800924:	74 5e                	je     800984 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800926:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800929:	83 f8 2f             	cmp    $0x2f,%eax
  80092c:	77 48                	ja     800976 <vprintfmt+0x456>
  80092e:	89 c2                	mov    %eax,%edx
  800930:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800934:	83 c0 08             	add    $0x8,%eax
  800937:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093a:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80093d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800942:	e9 2c 01 00 00       	jmpq   800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800947:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094a:	83 f8 2f             	cmp    $0x2f,%eax
  80094d:	77 19                	ja     800968 <vprintfmt+0x448>
  80094f:	89 c2                	mov    %eax,%edx
  800951:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800955:	83 c0 08             	add    $0x8,%eax
  800958:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095b:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80095e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800963:	e9 0b 01 00 00       	jmpq   800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800968:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800970:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800974:	eb e5                	jmp    80095b <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800976:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80097a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800982:	eb b6                	jmp    80093a <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800984:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800987:	83 f8 2f             	cmp    $0x2f,%eax
  80098a:	77 18                	ja     8009a4 <vprintfmt+0x484>
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800992:	83 c0 08             	add    $0x8,%eax
  800995:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800998:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80099a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80099f:	e9 cf 00 00 00       	jmpq   800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009ac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b0:	eb e6                	jmp    800998 <vprintfmt+0x478>
  if (lflag >= 2)
  8009b2:	83 f9 01             	cmp    $0x1,%ecx
  8009b5:	7f 25                	jg     8009dc <vprintfmt+0x4bc>
  else if (lflag)
  8009b7:	85 c9                	test   %ecx,%ecx
  8009b9:	74 5b                	je     800a16 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009bb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009be:	83 f8 2f             	cmp    $0x2f,%eax
  8009c1:	77 45                	ja     800a08 <vprintfmt+0x4e8>
  8009c3:	89 c2                	mov    %eax,%edx
  8009c5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c9:	83 c0 08             	add    $0x8,%eax
  8009cc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009cf:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009d2:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009d7:	e9 97 00 00 00       	jmpq   800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009dc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009df:	83 f8 2f             	cmp    $0x2f,%eax
  8009e2:	77 16                	ja     8009fa <vprintfmt+0x4da>
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ea:	83 c0 08             	add    $0x8,%eax
  8009ed:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f0:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009f3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f8:	eb 79                	jmp    800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009fa:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009fe:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a02:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a06:	eb e8                	jmp    8009f0 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a08:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a0c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a10:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a14:	eb b9                	jmp    8009cf <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a16:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a19:	83 f8 2f             	cmp    $0x2f,%eax
  800a1c:	77 15                	ja     800a33 <vprintfmt+0x513>
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a24:	83 c0 08             	add    $0x8,%eax
  800a27:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a2a:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a2c:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a31:	eb 40                	jmp    800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a33:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a37:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a3b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a3f:	eb e9                	jmp    800a2a <vprintfmt+0x50a>
        putch('0', putdat);
  800a41:	4c 89 fe             	mov    %r15,%rsi
  800a44:	bf 30 00 00 00       	mov    $0x30,%edi
  800a49:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a4c:	4c 89 fe             	mov    %r15,%rsi
  800a4f:	bf 78 00 00 00       	mov    $0x78,%edi
  800a54:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a57:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a5a:	83 f8 2f             	cmp    $0x2f,%eax
  800a5d:	77 34                	ja     800a93 <vprintfmt+0x573>
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a65:	83 c0 08             	add    $0x8,%eax
  800a68:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a6b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a6e:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a73:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a78:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a7c:	4c 89 fe             	mov    %r15,%rsi
  800a7f:	4c 89 ef             	mov    %r13,%rdi
  800a82:	48 b8 f6 03 80 00 00 	movabs $0x8003f6,%rax
  800a89:	00 00 00 
  800a8c:	ff d0                	callq  *%rax
        break;
  800a8e:	e9 b7 fa ff ff       	jmpq   80054a <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a93:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a97:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a9b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a9f:	eb ca                	jmp    800a6b <vprintfmt+0x54b>
  if (lflag >= 2)
  800aa1:	83 f9 01             	cmp    $0x1,%ecx
  800aa4:	7f 22                	jg     800ac8 <vprintfmt+0x5a8>
  else if (lflag)
  800aa6:	85 c9                	test   %ecx,%ecx
  800aa8:	74 58                	je     800b02 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800aaa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aad:	83 f8 2f             	cmp    $0x2f,%eax
  800ab0:	77 42                	ja     800af4 <vprintfmt+0x5d4>
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ab8:	83 c0 08             	add    $0x8,%eax
  800abb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800abe:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ac1:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ac6:	eb ab                	jmp    800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ac8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800acb:	83 f8 2f             	cmp    $0x2f,%eax
  800ace:	77 16                	ja     800ae6 <vprintfmt+0x5c6>
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad6:	83 c0 08             	add    $0x8,%eax
  800ad9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800adc:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800adf:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae4:	eb 8d                	jmp    800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ae6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aea:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aee:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800af2:	eb e8                	jmp    800adc <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800af4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800af8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800afc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b00:	eb bc                	jmp    800abe <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b02:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b05:	83 f8 2f             	cmp    $0x2f,%eax
  800b08:	77 18                	ja     800b22 <vprintfmt+0x602>
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b10:	83 c0 08             	add    $0x8,%eax
  800b13:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b16:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b18:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b1d:	e9 51 ff ff ff       	jmpq   800a73 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b22:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b26:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b2a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b2e:	eb e6                	jmp    800b16 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b30:	4c 89 fe             	mov    %r15,%rsi
  800b33:	bf 25 00 00 00       	mov    $0x25,%edi
  800b38:	41 ff d5             	callq  *%r13
        break;
  800b3b:	e9 0a fa ff ff       	jmpq   80054a <vprintfmt+0x2a>
        putch('%', putdat);
  800b40:	4c 89 fe             	mov    %r15,%rsi
  800b43:	bf 25 00 00 00       	mov    $0x25,%edi
  800b48:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b4b:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b4f:	0f 84 15 fa ff ff    	je     80056a <vprintfmt+0x4a>
  800b55:	49 89 de             	mov    %rbx,%r14
  800b58:	49 83 ee 01          	sub    $0x1,%r14
  800b5c:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b61:	75 f5                	jne    800b58 <vprintfmt+0x638>
  800b63:	e9 e2 f9 ff ff       	jmpq   80054a <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b68:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b6c:	74 06                	je     800b74 <vprintfmt+0x654>
  800b6e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b72:	7f 21                	jg     800b95 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b74:	bf 28 00 00 00       	mov    $0x28,%edi
  800b79:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800b80:	00 00 00 
  800b83:	b8 28 00 00 00       	mov    $0x28,%eax
  800b88:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b8c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b90:	e9 82 fc ff ff       	jmpq   800817 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b95:	49 63 f4             	movslq %r12d,%rsi
  800b98:	48 bf db 11 80 00 00 	movabs $0x8011db,%rdi
  800b9f:	00 00 00 
  800ba2:	48 b8 f7 0c 80 00 00 	movabs $0x800cf7,%rax
  800ba9:	00 00 00 
  800bac:	ff d0                	callq  *%rax
  800bae:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bb1:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bb4:	48 be db 11 80 00 00 	movabs $0x8011db,%rsi
  800bbb:	00 00 00 
  800bbe:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	0f 8f f2 fb ff ff    	jg     8007bc <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bca:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800bd1:	00 00 00 
  800bd4:	b8 28 00 00 00       	mov    $0x28,%eax
  800bd9:	bf 28 00 00 00       	mov    $0x28,%edi
  800bde:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800be2:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800be6:	e9 2c fc ff ff       	jmpq   800817 <vprintfmt+0x2f7>
}
  800beb:	48 83 c4 48          	add    $0x48,%rsp
  800bef:	5b                   	pop    %rbx
  800bf0:	41 5c                	pop    %r12
  800bf2:	41 5d                	pop    %r13
  800bf4:	41 5e                	pop    %r14
  800bf6:	41 5f                	pop    %r15
  800bf8:	5d                   	pop    %rbp
  800bf9:	c3                   	retq   

0000000000800bfa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bfa:	55                   	push   %rbp
  800bfb:	48 89 e5             	mov    %rsp,%rbp
  800bfe:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c02:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c06:	48 63 c6             	movslq %esi,%rax
  800c09:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c0e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c19:	48 85 ff             	test   %rdi,%rdi
  800c1c:	74 2a                	je     800c48 <vsnprintf+0x4e>
  800c1e:	85 f6                	test   %esi,%esi
  800c20:	7e 26                	jle    800c48 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c22:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c26:	48 bf 82 04 80 00 00 	movabs $0x800482,%rdi
  800c2d:	00 00 00 
  800c30:	48 b8 20 05 80 00 00 	movabs $0x800520,%rax
  800c37:	00 00 00 
  800c3a:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c3c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c40:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c43:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c46:	c9                   	leaveq 
  800c47:	c3                   	retq   
    return -E_INVAL;
  800c48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c4d:	eb f7                	jmp    800c46 <vsnprintf+0x4c>

0000000000800c4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c4f:	55                   	push   %rbp
  800c50:	48 89 e5             	mov    %rsp,%rbp
  800c53:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c5a:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c61:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c68:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c6f:	84 c0                	test   %al,%al
  800c71:	74 20                	je     800c93 <snprintf+0x44>
  800c73:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c77:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c7b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c7f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c83:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c87:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c8b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c8f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c93:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c9a:	00 00 00 
  800c9d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ca4:	00 00 00 
  800ca7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cab:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cb2:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cb9:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cc0:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cc7:	48 b8 fa 0b 80 00 00 	movabs $0x800bfa,%rax
  800cce:	00 00 00 
  800cd1:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cd3:	c9                   	leaveq 
  800cd4:	c3                   	retq   

0000000000800cd5 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cd5:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cd8:	74 17                	je     800cf1 <strlen+0x1c>
  800cda:	48 89 fa             	mov    %rdi,%rdx
  800cdd:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ce2:	29 f9                	sub    %edi,%ecx
    n++;
  800ce4:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800ce7:	48 83 c2 01          	add    $0x1,%rdx
  800ceb:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cee:	75 f4                	jne    800ce4 <strlen+0xf>
  800cf0:	c3                   	retq   
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cf6:	c3                   	retq   

0000000000800cf7 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf7:	48 85 f6             	test   %rsi,%rsi
  800cfa:	74 24                	je     800d20 <strnlen+0x29>
  800cfc:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cff:	74 25                	je     800d26 <strnlen+0x2f>
  800d01:	48 01 fe             	add    %rdi,%rsi
  800d04:	48 89 fa             	mov    %rdi,%rdx
  800d07:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d0c:	29 f9                	sub    %edi,%ecx
    n++;
  800d0e:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d11:	48 83 c2 01          	add    $0x1,%rdx
  800d15:	48 39 f2             	cmp    %rsi,%rdx
  800d18:	74 11                	je     800d2b <strnlen+0x34>
  800d1a:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d1d:	75 ef                	jne    800d0e <strnlen+0x17>
  800d1f:	c3                   	retq   
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
  800d25:	c3                   	retq   
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d2b:	c3                   	retq   

0000000000800d2c <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d2c:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d34:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d38:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d3b:	48 83 c2 01          	add    $0x1,%rdx
  800d3f:	84 c9                	test   %cl,%cl
  800d41:	75 f1                	jne    800d34 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d43:	c3                   	retq   

0000000000800d44 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d44:	55                   	push   %rbp
  800d45:	48 89 e5             	mov    %rsp,%rbp
  800d48:	41 54                	push   %r12
  800d4a:	53                   	push   %rbx
  800d4b:	48 89 fb             	mov    %rdi,%rbx
  800d4e:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d51:	48 b8 d5 0c 80 00 00 	movabs $0x800cd5,%rax
  800d58:	00 00 00 
  800d5b:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d5d:	48 63 f8             	movslq %eax,%rdi
  800d60:	48 01 df             	add    %rbx,%rdi
  800d63:	4c 89 e6             	mov    %r12,%rsi
  800d66:	48 b8 2c 0d 80 00 00 	movabs $0x800d2c,%rax
  800d6d:	00 00 00 
  800d70:	ff d0                	callq  *%rax
  return dst;
}
  800d72:	48 89 d8             	mov    %rbx,%rax
  800d75:	5b                   	pop    %rbx
  800d76:	41 5c                	pop    %r12
  800d78:	5d                   	pop    %rbp
  800d79:	c3                   	retq   

0000000000800d7a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d7a:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d7d:	48 85 d2             	test   %rdx,%rdx
  800d80:	74 1f                	je     800da1 <strncpy+0x27>
  800d82:	48 01 fa             	add    %rdi,%rdx
  800d85:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d88:	48 83 c1 01          	add    $0x1,%rcx
  800d8c:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d90:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d94:	41 80 f8 01          	cmp    $0x1,%r8b
  800d98:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d9c:	48 39 ca             	cmp    %rcx,%rdx
  800d9f:	75 e7                	jne    800d88 <strncpy+0xe>
  }
  return ret;
}
  800da1:	c3                   	retq   

0000000000800da2 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800da2:	48 89 f8             	mov    %rdi,%rax
  800da5:	48 85 d2             	test   %rdx,%rdx
  800da8:	74 36                	je     800de0 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800daa:	48 83 fa 01          	cmp    $0x1,%rdx
  800dae:	74 2d                	je     800ddd <strlcpy+0x3b>
  800db0:	44 0f b6 06          	movzbl (%rsi),%r8d
  800db4:	45 84 c0             	test   %r8b,%r8b
  800db7:	74 24                	je     800ddd <strlcpy+0x3b>
  800db9:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dbd:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dc2:	48 83 c0 01          	add    $0x1,%rax
  800dc6:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800dca:	48 39 d1             	cmp    %rdx,%rcx
  800dcd:	74 0e                	je     800ddd <strlcpy+0x3b>
  800dcf:	48 83 c1 01          	add    $0x1,%rcx
  800dd3:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dd8:	45 84 c0             	test   %r8b,%r8b
  800ddb:	75 e5                	jne    800dc2 <strlcpy+0x20>
    *dst = '\0';
  800ddd:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800de0:	48 29 f8             	sub    %rdi,%rax
}
  800de3:	c3                   	retq   

0000000000800de4 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800de4:	0f b6 07             	movzbl (%rdi),%eax
  800de7:	84 c0                	test   %al,%al
  800de9:	74 17                	je     800e02 <strcmp+0x1e>
  800deb:	3a 06                	cmp    (%rsi),%al
  800ded:	75 13                	jne    800e02 <strcmp+0x1e>
    p++, q++;
  800def:	48 83 c7 01          	add    $0x1,%rdi
  800df3:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800df7:	0f b6 07             	movzbl (%rdi),%eax
  800dfa:	84 c0                	test   %al,%al
  800dfc:	74 04                	je     800e02 <strcmp+0x1e>
  800dfe:	3a 06                	cmp    (%rsi),%al
  800e00:	74 ed                	je     800def <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e02:	0f b6 c0             	movzbl %al,%eax
  800e05:	0f b6 16             	movzbl (%rsi),%edx
  800e08:	29 d0                	sub    %edx,%eax
}
  800e0a:	c3                   	retq   

0000000000800e0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e0b:	48 85 d2             	test   %rdx,%rdx
  800e0e:	74 2f                	je     800e3f <strncmp+0x34>
  800e10:	0f b6 07             	movzbl (%rdi),%eax
  800e13:	84 c0                	test   %al,%al
  800e15:	74 1f                	je     800e36 <strncmp+0x2b>
  800e17:	3a 06                	cmp    (%rsi),%al
  800e19:	75 1b                	jne    800e36 <strncmp+0x2b>
  800e1b:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e1e:	48 83 c7 01          	add    $0x1,%rdi
  800e22:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e26:	48 39 d7             	cmp    %rdx,%rdi
  800e29:	74 1a                	je     800e45 <strncmp+0x3a>
  800e2b:	0f b6 07             	movzbl (%rdi),%eax
  800e2e:	84 c0                	test   %al,%al
  800e30:	74 04                	je     800e36 <strncmp+0x2b>
  800e32:	3a 06                	cmp    (%rsi),%al
  800e34:	74 e8                	je     800e1e <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e36:	0f b6 07             	movzbl (%rdi),%eax
  800e39:	0f b6 16             	movzbl (%rsi),%edx
  800e3c:	29 d0                	sub    %edx,%eax
}
  800e3e:	c3                   	retq   
    return 0;
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e44:	c3                   	retq   
  800e45:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4a:	c3                   	retq   

0000000000800e4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e4b:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e4d:	0f b6 07             	movzbl (%rdi),%eax
  800e50:	84 c0                	test   %al,%al
  800e52:	74 1e                	je     800e72 <strchr+0x27>
    if (*s == c)
  800e54:	40 38 c6             	cmp    %al,%sil
  800e57:	74 1f                	je     800e78 <strchr+0x2d>
  for (; *s; s++)
  800e59:	48 83 c7 01          	add    $0x1,%rdi
  800e5d:	0f b6 07             	movzbl (%rdi),%eax
  800e60:	84 c0                	test   %al,%al
  800e62:	74 08                	je     800e6c <strchr+0x21>
    if (*s == c)
  800e64:	38 d0                	cmp    %dl,%al
  800e66:	75 f1                	jne    800e59 <strchr+0xe>
  for (; *s; s++)
  800e68:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e6b:	c3                   	retq   
  return 0;
  800e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e71:	c3                   	retq   
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	c3                   	retq   
    if (*s == c)
  800e78:	48 89 f8             	mov    %rdi,%rax
  800e7b:	c3                   	retq   

0000000000800e7c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e7c:	48 89 f8             	mov    %rdi,%rax
  800e7f:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e81:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e84:	40 38 f2             	cmp    %sil,%dl
  800e87:	74 13                	je     800e9c <strfind+0x20>
  800e89:	84 d2                	test   %dl,%dl
  800e8b:	74 0f                	je     800e9c <strfind+0x20>
  for (; *s; s++)
  800e8d:	48 83 c0 01          	add    $0x1,%rax
  800e91:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e94:	38 ca                	cmp    %cl,%dl
  800e96:	74 04                	je     800e9c <strfind+0x20>
  800e98:	84 d2                	test   %dl,%dl
  800e9a:	75 f1                	jne    800e8d <strfind+0x11>
      break;
  return (char *)s;
}
  800e9c:	c3                   	retq   

0000000000800e9d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e9d:	48 85 d2             	test   %rdx,%rdx
  800ea0:	74 3a                	je     800edc <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ea2:	48 89 f8             	mov    %rdi,%rax
  800ea5:	48 09 d0             	or     %rdx,%rax
  800ea8:	a8 03                	test   $0x3,%al
  800eaa:	75 28                	jne    800ed4 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800eac:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800eb0:	89 f0                	mov    %esi,%eax
  800eb2:	c1 e0 08             	shl    $0x8,%eax
  800eb5:	89 f1                	mov    %esi,%ecx
  800eb7:	c1 e1 18             	shl    $0x18,%ecx
  800eba:	41 89 f0             	mov    %esi,%r8d
  800ebd:	41 c1 e0 10          	shl    $0x10,%r8d
  800ec1:	44 09 c1             	or     %r8d,%ecx
  800ec4:	09 ce                	or     %ecx,%esi
  800ec6:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ec8:	48 c1 ea 02          	shr    $0x2,%rdx
  800ecc:	48 89 d1             	mov    %rdx,%rcx
  800ecf:	fc                   	cld    
  800ed0:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ed2:	eb 08                	jmp    800edc <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ed4:	89 f0                	mov    %esi,%eax
  800ed6:	48 89 d1             	mov    %rdx,%rcx
  800ed9:	fc                   	cld    
  800eda:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800edc:	48 89 f8             	mov    %rdi,%rax
  800edf:	c3                   	retq   

0000000000800ee0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ee0:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ee3:	48 39 fe             	cmp    %rdi,%rsi
  800ee6:	73 40                	jae    800f28 <memmove+0x48>
  800ee8:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800eec:	48 39 f9             	cmp    %rdi,%rcx
  800eef:	76 37                	jbe    800f28 <memmove+0x48>
    s += n;
    d += n;
  800ef1:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ef5:	48 89 fe             	mov    %rdi,%rsi
  800ef8:	48 09 d6             	or     %rdx,%rsi
  800efb:	48 09 ce             	or     %rcx,%rsi
  800efe:	40 f6 c6 03          	test   $0x3,%sil
  800f02:	75 14                	jne    800f18 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f04:	48 83 ef 04          	sub    $0x4,%rdi
  800f08:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f0c:	48 c1 ea 02          	shr    $0x2,%rdx
  800f10:	48 89 d1             	mov    %rdx,%rcx
  800f13:	fd                   	std    
  800f14:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f16:	eb 0e                	jmp    800f26 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f18:	48 83 ef 01          	sub    $0x1,%rdi
  800f1c:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f20:	48 89 d1             	mov    %rdx,%rcx
  800f23:	fd                   	std    
  800f24:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f26:	fc                   	cld    
  800f27:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f28:	48 89 c1             	mov    %rax,%rcx
  800f2b:	48 09 d1             	or     %rdx,%rcx
  800f2e:	48 09 f1             	or     %rsi,%rcx
  800f31:	f6 c1 03             	test   $0x3,%cl
  800f34:	75 0e                	jne    800f44 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f36:	48 c1 ea 02          	shr    $0x2,%rdx
  800f3a:	48 89 d1             	mov    %rdx,%rcx
  800f3d:	48 89 c7             	mov    %rax,%rdi
  800f40:	fc                   	cld    
  800f41:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f43:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f44:	48 89 c7             	mov    %rax,%rdi
  800f47:	48 89 d1             	mov    %rdx,%rcx
  800f4a:	fc                   	cld    
  800f4b:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f4d:	c3                   	retq   

0000000000800f4e <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f4e:	55                   	push   %rbp
  800f4f:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f52:	48 b8 e0 0e 80 00 00 	movabs $0x800ee0,%rax
  800f59:	00 00 00 
  800f5c:	ff d0                	callq  *%rax
}
  800f5e:	5d                   	pop    %rbp
  800f5f:	c3                   	retq   

0000000000800f60 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f60:	55                   	push   %rbp
  800f61:	48 89 e5             	mov    %rsp,%rbp
  800f64:	41 57                	push   %r15
  800f66:	41 56                	push   %r14
  800f68:	41 55                	push   %r13
  800f6a:	41 54                	push   %r12
  800f6c:	53                   	push   %rbx
  800f6d:	48 83 ec 08          	sub    $0x8,%rsp
  800f71:	49 89 fe             	mov    %rdi,%r14
  800f74:	49 89 f7             	mov    %rsi,%r15
  800f77:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f7a:	48 89 f7             	mov    %rsi,%rdi
  800f7d:	48 b8 d5 0c 80 00 00 	movabs $0x800cd5,%rax
  800f84:	00 00 00 
  800f87:	ff d0                	callq  *%rax
  800f89:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f8c:	4c 89 ee             	mov    %r13,%rsi
  800f8f:	4c 89 f7             	mov    %r14,%rdi
  800f92:	48 b8 f7 0c 80 00 00 	movabs $0x800cf7,%rax
  800f99:	00 00 00 
  800f9c:	ff d0                	callq  *%rax
  800f9e:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fa1:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fa5:	4d 39 e5             	cmp    %r12,%r13
  800fa8:	74 26                	je     800fd0 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800faa:	4c 89 e8             	mov    %r13,%rax
  800fad:	4c 29 e0             	sub    %r12,%rax
  800fb0:	48 39 d8             	cmp    %rbx,%rax
  800fb3:	76 2a                	jbe    800fdf <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fb5:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fb9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fbd:	4c 89 fe             	mov    %r15,%rsi
  800fc0:	48 b8 4e 0f 80 00 00 	movabs $0x800f4e,%rax
  800fc7:	00 00 00 
  800fca:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fcc:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fd0:	48 83 c4 08          	add    $0x8,%rsp
  800fd4:	5b                   	pop    %rbx
  800fd5:	41 5c                	pop    %r12
  800fd7:	41 5d                	pop    %r13
  800fd9:	41 5e                	pop    %r14
  800fdb:	41 5f                	pop    %r15
  800fdd:	5d                   	pop    %rbp
  800fde:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fdf:	49 83 ed 01          	sub    $0x1,%r13
  800fe3:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fe7:	4c 89 ea             	mov    %r13,%rdx
  800fea:	4c 89 fe             	mov    %r15,%rsi
  800fed:	48 b8 4e 0f 80 00 00 	movabs $0x800f4e,%rax
  800ff4:	00 00 00 
  800ff7:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800ff9:	4d 01 ee             	add    %r13,%r14
  800ffc:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801001:	eb c9                	jmp    800fcc <strlcat+0x6c>

0000000000801003 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801003:	48 85 d2             	test   %rdx,%rdx
  801006:	74 3a                	je     801042 <memcmp+0x3f>
    if (*s1 != *s2)
  801008:	0f b6 0f             	movzbl (%rdi),%ecx
  80100b:	44 0f b6 06          	movzbl (%rsi),%r8d
  80100f:	44 38 c1             	cmp    %r8b,%cl
  801012:	75 1d                	jne    801031 <memcmp+0x2e>
  801014:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801019:	48 39 d0             	cmp    %rdx,%rax
  80101c:	74 1e                	je     80103c <memcmp+0x39>
    if (*s1 != *s2)
  80101e:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801022:	48 83 c0 01          	add    $0x1,%rax
  801026:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  80102c:	44 38 c1             	cmp    %r8b,%cl
  80102f:	74 e8                	je     801019 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801031:	0f b6 c1             	movzbl %cl,%eax
  801034:	45 0f b6 c0          	movzbl %r8b,%r8d
  801038:	44 29 c0             	sub    %r8d,%eax
  80103b:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	c3                   	retq   
  801042:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801047:	c3                   	retq   

0000000000801048 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801048:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80104c:	48 39 c7             	cmp    %rax,%rdi
  80104f:	73 19                	jae    80106a <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801051:	89 f2                	mov    %esi,%edx
  801053:	40 38 37             	cmp    %sil,(%rdi)
  801056:	74 16                	je     80106e <memfind+0x26>
  for (; s < ends; s++)
  801058:	48 83 c7 01          	add    $0x1,%rdi
  80105c:	48 39 f8             	cmp    %rdi,%rax
  80105f:	74 08                	je     801069 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801061:	38 17                	cmp    %dl,(%rdi)
  801063:	75 f3                	jne    801058 <memfind+0x10>
  for (; s < ends; s++)
  801065:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801068:	c3                   	retq   
  801069:	c3                   	retq   
  for (; s < ends; s++)
  80106a:	48 89 f8             	mov    %rdi,%rax
  80106d:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80106e:	48 89 f8             	mov    %rdi,%rax
  801071:	c3                   	retq   

0000000000801072 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801072:	0f b6 07             	movzbl (%rdi),%eax
  801075:	3c 20                	cmp    $0x20,%al
  801077:	74 04                	je     80107d <strtol+0xb>
  801079:	3c 09                	cmp    $0x9,%al
  80107b:	75 0f                	jne    80108c <strtol+0x1a>
    s++;
  80107d:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801081:	0f b6 07             	movzbl (%rdi),%eax
  801084:	3c 20                	cmp    $0x20,%al
  801086:	74 f5                	je     80107d <strtol+0xb>
  801088:	3c 09                	cmp    $0x9,%al
  80108a:	74 f1                	je     80107d <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80108c:	3c 2b                	cmp    $0x2b,%al
  80108e:	74 2b                	je     8010bb <strtol+0x49>
  int neg  = 0;
  801090:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801096:	3c 2d                	cmp    $0x2d,%al
  801098:	74 2d                	je     8010c7 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80109a:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010a0:	75 0f                	jne    8010b1 <strtol+0x3f>
  8010a2:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010a5:	74 2c                	je     8010d3 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010a7:	85 d2                	test   %edx,%edx
  8010a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ae:	0f 44 d0             	cmove  %eax,%edx
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010b6:	4c 63 d2             	movslq %edx,%r10
  8010b9:	eb 5c                	jmp    801117 <strtol+0xa5>
    s++;
  8010bb:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010bf:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010c5:	eb d3                	jmp    80109a <strtol+0x28>
    s++, neg = 1;
  8010c7:	48 83 c7 01          	add    $0x1,%rdi
  8010cb:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010d1:	eb c7                	jmp    80109a <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010d3:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010d7:	74 0f                	je     8010e8 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010d9:	85 d2                	test   %edx,%edx
  8010db:	75 d4                	jne    8010b1 <strtol+0x3f>
    s++, base = 8;
  8010dd:	48 83 c7 01          	add    $0x1,%rdi
  8010e1:	ba 08 00 00 00       	mov    $0x8,%edx
  8010e6:	eb c9                	jmp    8010b1 <strtol+0x3f>
    s += 2, base = 16;
  8010e8:	48 83 c7 02          	add    $0x2,%rdi
  8010ec:	ba 10 00 00 00       	mov    $0x10,%edx
  8010f1:	eb be                	jmp    8010b1 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010f3:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010f7:	41 80 f8 19          	cmp    $0x19,%r8b
  8010fb:	77 2f                	ja     80112c <strtol+0xba>
      dig = *s - 'a' + 10;
  8010fd:	44 0f be c1          	movsbl %cl,%r8d
  801101:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801105:	39 d1                	cmp    %edx,%ecx
  801107:	7d 37                	jge    801140 <strtol+0xce>
    s++, val = (val * base) + dig;
  801109:	48 83 c7 01          	add    $0x1,%rdi
  80110d:	49 0f af c2          	imul   %r10,%rax
  801111:	48 63 c9             	movslq %ecx,%rcx
  801114:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801117:	0f b6 0f             	movzbl (%rdi),%ecx
  80111a:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80111e:	41 80 f8 09          	cmp    $0x9,%r8b
  801122:	77 cf                	ja     8010f3 <strtol+0x81>
      dig = *s - '0';
  801124:	0f be c9             	movsbl %cl,%ecx
  801127:	83 e9 30             	sub    $0x30,%ecx
  80112a:	eb d9                	jmp    801105 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80112c:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801130:	41 80 f8 19          	cmp    $0x19,%r8b
  801134:	77 0a                	ja     801140 <strtol+0xce>
      dig = *s - 'A' + 10;
  801136:	44 0f be c1          	movsbl %cl,%r8d
  80113a:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80113e:	eb c5                	jmp    801105 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801140:	48 85 f6             	test   %rsi,%rsi
  801143:	74 03                	je     801148 <strtol+0xd6>
    *endptr = (char *)s;
  801145:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801148:	48 89 c2             	mov    %rax,%rdx
  80114b:	48 f7 da             	neg    %rdx
  80114e:	45 85 c9             	test   %r9d,%r9d
  801151:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801155:	c3                   	retq   
  801156:	66 90                	xchg   %ax,%ax
