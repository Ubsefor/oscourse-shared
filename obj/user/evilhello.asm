
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
  80003d:	48 b8 1c 01 80 00 00 	movabs $0x80011c,%rax
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  800098:	48 b8 ba 01 80 00 00 	movabs $0x8001ba,%rax
  80009f:	00 00 00 
  8000a2:	ff d0                	callq  *%rax
  8000a4:	83 e0 1f             	and    $0x1f,%eax
  8000a7:	48 89 c2             	mov    %rax,%rdx
  8000aa:	48 c1 e2 05          	shl    $0x5,%rdx
  8000ae:	48 29 c2             	sub    %rax,%rdx
  8000b1:	48 89 d0             	mov    %rdx,%rax
  8000b4:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000bb:	00 00 00 
  8000be:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000c2:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000c9:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000cc:	45 85 ed             	test   %r13d,%r13d
  8000cf:	7e 0d                	jle    8000de <libmain+0x93>
    binaryname = argv[0];
  8000d1:	49 8b 06             	mov    (%r14),%rax
  8000d4:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000db:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000de:	4c 89 f6             	mov    %r14,%rsi
  8000e1:	44 89 ef             	mov    %r13d,%edi
  8000e4:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000eb:	00 00 00 
  8000ee:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f0:	48 b8 05 01 80 00 00 	movabs $0x800105,%rax
  8000f7:	00 00 00 
  8000fa:	ff d0                	callq  *%rax
#endif
}
  8000fc:	5b                   	pop    %rbx
  8000fd:	41 5c                	pop    %r12
  8000ff:	41 5d                	pop    %r13
  800101:	41 5e                	pop    %r14
  800103:	5d                   	pop    %rbp
  800104:	c3                   	retq   

0000000000800105 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800105:	55                   	push   %rbp
  800106:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800109:	bf 00 00 00 00       	mov    $0x0,%edi
  80010e:	48 b8 5a 01 80 00 00 	movabs $0x80015a,%rax
  800115:	00 00 00 
  800118:	ff d0                	callq  *%rax
}
  80011a:	5d                   	pop    %rbp
  80011b:	c3                   	retq   

000000000080011c <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80011c:	55                   	push   %rbp
  80011d:	48 89 e5             	mov    %rsp,%rbp
  800120:	53                   	push   %rbx
  800121:	48 89 fa             	mov    %rdi,%rdx
  800124:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800127:	b8 00 00 00 00       	mov    $0x0,%eax
  80012c:	48 89 c3             	mov    %rax,%rbx
  80012f:	48 89 c7             	mov    %rax,%rdi
  800132:	48 89 c6             	mov    %rax,%rsi
  800135:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800137:	5b                   	pop    %rbx
  800138:	5d                   	pop    %rbp
  800139:	c3                   	retq   

000000000080013a <sys_cgetc>:

int
sys_cgetc(void) {
  80013a:	55                   	push   %rbp
  80013b:	48 89 e5             	mov    %rsp,%rbp
  80013e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80013f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800144:	b8 01 00 00 00       	mov    $0x1,%eax
  800149:	48 89 ca             	mov    %rcx,%rdx
  80014c:	48 89 cb             	mov    %rcx,%rbx
  80014f:	48 89 cf             	mov    %rcx,%rdi
  800152:	48 89 ce             	mov    %rcx,%rsi
  800155:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800157:	5b                   	pop    %rbx
  800158:	5d                   	pop    %rbp
  800159:	c3                   	retq   

000000000080015a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80015a:	55                   	push   %rbp
  80015b:	48 89 e5             	mov    %rsp,%rbp
  80015e:	53                   	push   %rbx
  80015f:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800163:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800166:	be 00 00 00 00       	mov    $0x0,%esi
  80016b:	b8 03 00 00 00       	mov    $0x3,%eax
  800170:	48 89 f1             	mov    %rsi,%rcx
  800173:	48 89 f3             	mov    %rsi,%rbx
  800176:	48 89 f7             	mov    %rsi,%rdi
  800179:	cd 30                	int    $0x30
  if (check && ret > 0)
  80017b:	48 85 c0             	test   %rax,%rax
  80017e:	7f 07                	jg     800187 <sys_env_destroy+0x2d>
}
  800180:	48 83 c4 08          	add    $0x8,%rsp
  800184:	5b                   	pop    %rbx
  800185:	5d                   	pop    %rbp
  800186:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800187:	49 89 c0             	mov    %rax,%r8
  80018a:	b9 03 00 00 00       	mov    $0x3,%ecx
  80018f:	48 ba 90 11 80 00 00 	movabs $0x801190,%rdx
  800196:	00 00 00 
  800199:	be 22 00 00 00       	mov    $0x22,%esi
  80019e:	48 bf af 11 80 00 00 	movabs $0x8011af,%rdi
  8001a5:	00 00 00 
  8001a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ad:	49 b9 da 01 80 00 00 	movabs $0x8001da,%r9
  8001b4:	00 00 00 
  8001b7:	41 ff d1             	callq  *%r9

00000000008001ba <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001ba:	55                   	push   %rbp
  8001bb:	48 89 e5             	mov    %rsp,%rbp
  8001be:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8001c9:	48 89 ca             	mov    %rcx,%rdx
  8001cc:	48 89 cb             	mov    %rcx,%rbx
  8001cf:	48 89 cf             	mov    %rcx,%rdi
  8001d2:	48 89 ce             	mov    %rcx,%rsi
  8001d5:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001d7:	5b                   	pop    %rbx
  8001d8:	5d                   	pop    %rbp
  8001d9:	c3                   	retq   

00000000008001da <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001da:	55                   	push   %rbp
  8001db:	48 89 e5             	mov    %rsp,%rbp
  8001de:	41 56                	push   %r14
  8001e0:	41 55                	push   %r13
  8001e2:	41 54                	push   %r12
  8001e4:	53                   	push   %rbx
  8001e5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001ec:	49 89 fd             	mov    %rdi,%r13
  8001ef:	41 89 f6             	mov    %esi,%r14d
  8001f2:	49 89 d4             	mov    %rdx,%r12
  8001f5:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001fc:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800203:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80020a:	84 c0                	test   %al,%al
  80020c:	74 26                	je     800234 <_panic+0x5a>
  80020e:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800215:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80021c:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800220:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800224:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800228:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80022c:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800230:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800234:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80023b:	00 00 00 
  80023e:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800245:	00 00 00 
  800248:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80024c:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800253:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80025a:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800261:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800268:	00 00 00 
  80026b:	48 8b 18             	mov    (%rax),%rbx
  80026e:	48 b8 ba 01 80 00 00 	movabs $0x8001ba,%rax
  800275:	00 00 00 
  800278:	ff d0                	callq  *%rax
  80027a:	45 89 f0             	mov    %r14d,%r8d
  80027d:	4c 89 e9             	mov    %r13,%rcx
  800280:	48 89 da             	mov    %rbx,%rdx
  800283:	89 c6                	mov    %eax,%esi
  800285:	48 bf c0 11 80 00 00 	movabs $0x8011c0,%rdi
  80028c:	00 00 00 
  80028f:	b8 00 00 00 00       	mov    $0x0,%eax
  800294:	48 bb 7c 03 80 00 00 	movabs $0x80037c,%rbx
  80029b:	00 00 00 
  80029e:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8002a0:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002a7:	4c 89 e7             	mov    %r12,%rdi
  8002aa:	48 b8 14 03 80 00 00 	movabs $0x800314,%rax
  8002b1:	00 00 00 
  8002b4:	ff d0                	callq  *%rax
  cprintf("\n");
  8002b6:	48 bf e8 11 80 00 00 	movabs $0x8011e8,%rdi
  8002bd:	00 00 00 
  8002c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c5:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002c7:	cc                   	int3   
  while (1)
  8002c8:	eb fd                	jmp    8002c7 <_panic+0xed>

00000000008002ca <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002ca:	55                   	push   %rbp
  8002cb:	48 89 e5             	mov    %rsp,%rbp
  8002ce:	53                   	push   %rbx
  8002cf:	48 83 ec 08          	sub    $0x8,%rsp
  8002d3:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002d6:	8b 06                	mov    (%rsi),%eax
  8002d8:	8d 50 01             	lea    0x1(%rax),%edx
  8002db:	89 16                	mov    %edx,(%rsi)
  8002dd:	48 98                	cltq   
  8002df:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002e4:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002ea:	74 0b                	je     8002f7 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002ec:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002f0:	48 83 c4 08          	add    $0x8,%rsp
  8002f4:	5b                   	pop    %rbx
  8002f5:	5d                   	pop    %rbp
  8002f6:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002f7:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002fb:	be ff 00 00 00       	mov    $0xff,%esi
  800300:	48 b8 1c 01 80 00 00 	movabs $0x80011c,%rax
  800307:	00 00 00 
  80030a:	ff d0                	callq  *%rax
    b->idx = 0;
  80030c:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800312:	eb d8                	jmp    8002ec <putch+0x22>

0000000000800314 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800314:	55                   	push   %rbp
  800315:	48 89 e5             	mov    %rsp,%rbp
  800318:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80031f:	48 89 fa             	mov    %rdi,%rdx
  800322:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800325:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80032c:	00 00 00 
  b.cnt = 0;
  80032f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800336:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800339:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800340:	48 bf ca 02 80 00 00 	movabs $0x8002ca,%rdi
  800347:	00 00 00 
  80034a:	48 b8 3a 05 80 00 00 	movabs $0x80053a,%rax
  800351:	00 00 00 
  800354:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800356:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80035d:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800364:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800368:	48 b8 1c 01 80 00 00 	movabs $0x80011c,%rax
  80036f:	00 00 00 
  800372:	ff d0                	callq  *%rax

  return b.cnt;
}
  800374:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80037a:	c9                   	leaveq 
  80037b:	c3                   	retq   

000000000080037c <cprintf>:

int
cprintf(const char *fmt, ...) {
  80037c:	55                   	push   %rbp
  80037d:	48 89 e5             	mov    %rsp,%rbp
  800380:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800387:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80038e:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800395:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80039c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003a3:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003aa:	84 c0                	test   %al,%al
  8003ac:	74 20                	je     8003ce <cprintf+0x52>
  8003ae:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003b2:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003b6:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003ba:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003be:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003c2:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003c6:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003ca:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003ce:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003d5:	00 00 00 
  8003d8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003df:	00 00 00 
  8003e2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003e6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003ed:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003f4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003fb:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800402:	48 b8 14 03 80 00 00 	movabs $0x800314,%rax
  800409:	00 00 00 
  80040c:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80040e:	c9                   	leaveq 
  80040f:	c3                   	retq   

0000000000800410 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800410:	55                   	push   %rbp
  800411:	48 89 e5             	mov    %rsp,%rbp
  800414:	41 57                	push   %r15
  800416:	41 56                	push   %r14
  800418:	41 55                	push   %r13
  80041a:	41 54                	push   %r12
  80041c:	53                   	push   %rbx
  80041d:	48 83 ec 18          	sub    $0x18,%rsp
  800421:	49 89 fc             	mov    %rdi,%r12
  800424:	49 89 f5             	mov    %rsi,%r13
  800427:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80042b:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80042e:	41 89 cf             	mov    %ecx,%r15d
  800431:	49 39 d7             	cmp    %rdx,%r15
  800434:	76 45                	jbe    80047b <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800436:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80043a:	85 db                	test   %ebx,%ebx
  80043c:	7e 0e                	jle    80044c <printnum+0x3c>
      putch(padc, putdat);
  80043e:	4c 89 ee             	mov    %r13,%rsi
  800441:	44 89 f7             	mov    %r14d,%edi
  800444:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800447:	83 eb 01             	sub    $0x1,%ebx
  80044a:	75 f2                	jne    80043e <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80044c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800450:	ba 00 00 00 00       	mov    $0x0,%edx
  800455:	49 f7 f7             	div    %r15
  800458:	48 b8 ea 11 80 00 00 	movabs $0x8011ea,%rax
  80045f:	00 00 00 
  800462:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800466:	4c 89 ee             	mov    %r13,%rsi
  800469:	41 ff d4             	callq  *%r12
}
  80046c:	48 83 c4 18          	add    $0x18,%rsp
  800470:	5b                   	pop    %rbx
  800471:	41 5c                	pop    %r12
  800473:	41 5d                	pop    %r13
  800475:	41 5e                	pop    %r14
  800477:	41 5f                	pop    %r15
  800479:	5d                   	pop    %rbp
  80047a:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80047b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80047f:	ba 00 00 00 00       	mov    $0x0,%edx
  800484:	49 f7 f7             	div    %r15
  800487:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80048b:	48 89 c2             	mov    %rax,%rdx
  80048e:	48 b8 10 04 80 00 00 	movabs $0x800410,%rax
  800495:	00 00 00 
  800498:	ff d0                	callq  *%rax
  80049a:	eb b0                	jmp    80044c <printnum+0x3c>

000000000080049c <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80049c:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8004a0:	48 8b 06             	mov    (%rsi),%rax
  8004a3:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004a7:	73 0a                	jae    8004b3 <sprintputch+0x17>
    *b->buf++ = ch;
  8004a9:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004ad:	48 89 16             	mov    %rdx,(%rsi)
  8004b0:	40 88 38             	mov    %dil,(%rax)
}
  8004b3:	c3                   	retq   

00000000008004b4 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004b4:	55                   	push   %rbp
  8004b5:	48 89 e5             	mov    %rsp,%rbp
  8004b8:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004bf:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004c6:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004cd:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004d4:	84 c0                	test   %al,%al
  8004d6:	74 20                	je     8004f8 <printfmt+0x44>
  8004d8:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004dc:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004e0:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004e4:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004e8:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004ec:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004f0:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004f4:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004f8:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004ff:	00 00 00 
  800502:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800509:	00 00 00 
  80050c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800510:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800517:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80051e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800525:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80052c:	48 b8 3a 05 80 00 00 	movabs $0x80053a,%rax
  800533:	00 00 00 
  800536:	ff d0                	callq  *%rax
}
  800538:	c9                   	leaveq 
  800539:	c3                   	retq   

000000000080053a <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80053a:	55                   	push   %rbp
  80053b:	48 89 e5             	mov    %rsp,%rbp
  80053e:	41 57                	push   %r15
  800540:	41 56                	push   %r14
  800542:	41 55                	push   %r13
  800544:	41 54                	push   %r12
  800546:	53                   	push   %rbx
  800547:	48 83 ec 48          	sub    $0x48,%rsp
  80054b:	49 89 fd             	mov    %rdi,%r13
  80054e:	49 89 f7             	mov    %rsi,%r15
  800551:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800554:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800558:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80055c:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800560:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800564:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800568:	41 0f b6 3e          	movzbl (%r14),%edi
  80056c:	83 ff 25             	cmp    $0x25,%edi
  80056f:	74 18                	je     800589 <vprintfmt+0x4f>
      if (ch == '\0')
  800571:	85 ff                	test   %edi,%edi
  800573:	0f 84 8c 06 00 00    	je     800c05 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800579:	4c 89 fe             	mov    %r15,%rsi
  80057c:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80057f:	49 89 de             	mov    %rbx,%r14
  800582:	eb e0                	jmp    800564 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800584:	49 89 de             	mov    %rbx,%r14
  800587:	eb db                	jmp    800564 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800589:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80058d:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800591:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800598:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80059e:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005a7:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005ad:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005b3:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005b8:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005bd:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005c1:	0f b6 13             	movzbl (%rbx),%edx
  8005c4:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005c7:	3c 55                	cmp    $0x55,%al
  8005c9:	0f 87 8b 05 00 00    	ja     800b5a <vprintfmt+0x620>
  8005cf:	0f b6 c0             	movzbl %al,%eax
  8005d2:	49 bb a0 12 80 00 00 	movabs $0x8012a0,%r11
  8005d9:	00 00 00 
  8005dc:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005e0:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005e3:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005e7:	eb d4                	jmp    8005bd <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005e9:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005ec:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005f0:	eb cb                	jmp    8005bd <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005f2:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005f5:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005f9:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005fd:	8d 50 d0             	lea    -0x30(%rax),%edx
  800600:	83 fa 09             	cmp    $0x9,%edx
  800603:	77 7e                	ja     800683 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800605:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800609:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80060d:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800612:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800616:	8d 50 d0             	lea    -0x30(%rax),%edx
  800619:	83 fa 09             	cmp    $0x9,%edx
  80061c:	76 e7                	jbe    800605 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80061e:	4c 89 f3             	mov    %r14,%rbx
  800621:	eb 19                	jmp    80063c <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800623:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800626:	83 f8 2f             	cmp    $0x2f,%eax
  800629:	77 2a                	ja     800655 <vprintfmt+0x11b>
  80062b:	89 c2                	mov    %eax,%edx
  80062d:	4c 01 d2             	add    %r10,%rdx
  800630:	83 c0 08             	add    $0x8,%eax
  800633:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800636:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800639:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80063c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800640:	0f 89 77 ff ff ff    	jns    8005bd <vprintfmt+0x83>
          width = precision, precision = -1;
  800646:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80064a:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800650:	e9 68 ff ff ff       	jmpq   8005bd <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800655:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800659:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80065d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800661:	eb d3                	jmp    800636 <vprintfmt+0xfc>
        if (width < 0)
  800663:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800666:	85 c0                	test   %eax,%eax
  800668:	41 0f 48 c0          	cmovs  %r8d,%eax
  80066c:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80066f:	4c 89 f3             	mov    %r14,%rbx
  800672:	e9 46 ff ff ff       	jmpq   8005bd <vprintfmt+0x83>
  800677:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80067a:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80067e:	e9 3a ff ff ff       	jmpq   8005bd <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800683:	4c 89 f3             	mov    %r14,%rbx
  800686:	eb b4                	jmp    80063c <vprintfmt+0x102>
        lflag++;
  800688:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80068b:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80068e:	e9 2a ff ff ff       	jmpq   8005bd <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800693:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800696:	83 f8 2f             	cmp    $0x2f,%eax
  800699:	77 19                	ja     8006b4 <vprintfmt+0x17a>
  80069b:	89 c2                	mov    %eax,%edx
  80069d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006a1:	83 c0 08             	add    $0x8,%eax
  8006a4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006a7:	4c 89 fe             	mov    %r15,%rsi
  8006aa:	8b 3a                	mov    (%rdx),%edi
  8006ac:	41 ff d5             	callq  *%r13
        break;
  8006af:	e9 b0 fe ff ff       	jmpq   800564 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006b4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006b8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006bc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006c0:	eb e5                	jmp    8006a7 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006c2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006c5:	83 f8 2f             	cmp    $0x2f,%eax
  8006c8:	77 5b                	ja     800725 <vprintfmt+0x1eb>
  8006ca:	89 c2                	mov    %eax,%edx
  8006cc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006d0:	83 c0 08             	add    $0x8,%eax
  8006d3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006d6:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006d8:	89 c8                	mov    %ecx,%eax
  8006da:	c1 f8 1f             	sar    $0x1f,%eax
  8006dd:	31 c1                	xor    %eax,%ecx
  8006df:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e1:	83 f9 09             	cmp    $0x9,%ecx
  8006e4:	7f 4d                	jg     800733 <vprintfmt+0x1f9>
  8006e6:	48 63 c1             	movslq %ecx,%rax
  8006e9:	48 ba 60 15 80 00 00 	movabs $0x801560,%rdx
  8006f0:	00 00 00 
  8006f3:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006f7:	48 85 c0             	test   %rax,%rax
  8006fa:	74 37                	je     800733 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006fc:	48 89 c1             	mov    %rax,%rcx
  8006ff:	48 ba 0b 12 80 00 00 	movabs $0x80120b,%rdx
  800706:	00 00 00 
  800709:	4c 89 fe             	mov    %r15,%rsi
  80070c:	4c 89 ef             	mov    %r13,%rdi
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	48 bb b4 04 80 00 00 	movabs $0x8004b4,%rbx
  80071b:	00 00 00 
  80071e:	ff d3                	callq  *%rbx
  800720:	e9 3f fe ff ff       	jmpq   800564 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800725:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800729:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80072d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800731:	eb a3                	jmp    8006d6 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800733:	48 ba 02 12 80 00 00 	movabs $0x801202,%rdx
  80073a:	00 00 00 
  80073d:	4c 89 fe             	mov    %r15,%rsi
  800740:	4c 89 ef             	mov    %r13,%rdi
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	48 bb b4 04 80 00 00 	movabs $0x8004b4,%rbx
  80074f:	00 00 00 
  800752:	ff d3                	callq  *%rbx
  800754:	e9 0b fe ff ff       	jmpq   800564 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800759:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80075c:	83 f8 2f             	cmp    $0x2f,%eax
  80075f:	77 4b                	ja     8007ac <vprintfmt+0x272>
  800761:	89 c2                	mov    %eax,%edx
  800763:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800767:	83 c0 08             	add    $0x8,%eax
  80076a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80076d:	48 8b 02             	mov    (%rdx),%rax
  800770:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800774:	48 85 c0             	test   %rax,%rax
  800777:	0f 84 05 04 00 00    	je     800b82 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80077d:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800781:	7e 06                	jle    800789 <vprintfmt+0x24f>
  800783:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800787:	75 31                	jne    8007ba <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800789:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80078d:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800791:	0f b6 00             	movzbl (%rax),%eax
  800794:	0f be f8             	movsbl %al,%edi
  800797:	85 ff                	test   %edi,%edi
  800799:	0f 84 c3 00 00 00    	je     800862 <vprintfmt+0x328>
  80079f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007a3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007a7:	e9 85 00 00 00       	jmpq   800831 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007ac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007b0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007b4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b8:	eb b3                	jmp    80076d <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007ba:	49 63 f4             	movslq %r12d,%rsi
  8007bd:	48 89 c7             	mov    %rax,%rdi
  8007c0:	48 b8 11 0d 80 00 00 	movabs $0x800d11,%rax
  8007c7:	00 00 00 
  8007ca:	ff d0                	callq  *%rax
  8007cc:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007cf:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007d2:	85 f6                	test   %esi,%esi
  8007d4:	7e 22                	jle    8007f8 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007d6:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007da:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007de:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007e2:	4c 89 fe             	mov    %r15,%rsi
  8007e5:	89 df                	mov    %ebx,%edi
  8007e7:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007ea:	41 83 ec 01          	sub    $0x1,%r12d
  8007ee:	75 f2                	jne    8007e2 <vprintfmt+0x2a8>
  8007f0:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007f4:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007fc:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800800:	0f b6 00             	movzbl (%rax),%eax
  800803:	0f be f8             	movsbl %al,%edi
  800806:	85 ff                	test   %edi,%edi
  800808:	0f 84 56 fd ff ff    	je     800564 <vprintfmt+0x2a>
  80080e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800812:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800816:	eb 19                	jmp    800831 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800818:	4c 89 fe             	mov    %r15,%rsi
  80081b:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80081e:	41 83 ee 01          	sub    $0x1,%r14d
  800822:	48 83 c3 01          	add    $0x1,%rbx
  800826:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80082a:	0f be f8             	movsbl %al,%edi
  80082d:	85 ff                	test   %edi,%edi
  80082f:	74 29                	je     80085a <vprintfmt+0x320>
  800831:	45 85 e4             	test   %r12d,%r12d
  800834:	78 06                	js     80083c <vprintfmt+0x302>
  800836:	41 83 ec 01          	sub    $0x1,%r12d
  80083a:	78 48                	js     800884 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80083c:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800840:	74 d6                	je     800818 <vprintfmt+0x2de>
  800842:	0f be c0             	movsbl %al,%eax
  800845:	83 e8 20             	sub    $0x20,%eax
  800848:	83 f8 5e             	cmp    $0x5e,%eax
  80084b:	76 cb                	jbe    800818 <vprintfmt+0x2de>
            putch('?', putdat);
  80084d:	4c 89 fe             	mov    %r15,%rsi
  800850:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800855:	41 ff d5             	callq  *%r13
  800858:	eb c4                	jmp    80081e <vprintfmt+0x2e4>
  80085a:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80085e:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800862:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800865:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800869:	0f 8e f5 fc ff ff    	jle    800564 <vprintfmt+0x2a>
          putch(' ', putdat);
  80086f:	4c 89 fe             	mov    %r15,%rsi
  800872:	bf 20 00 00 00       	mov    $0x20,%edi
  800877:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80087a:	83 eb 01             	sub    $0x1,%ebx
  80087d:	75 f0                	jne    80086f <vprintfmt+0x335>
  80087f:	e9 e0 fc ff ff       	jmpq   800564 <vprintfmt+0x2a>
  800884:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800888:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80088c:	eb d4                	jmp    800862 <vprintfmt+0x328>
  if (lflag >= 2)
  80088e:	83 f9 01             	cmp    $0x1,%ecx
  800891:	7f 1d                	jg     8008b0 <vprintfmt+0x376>
  else if (lflag)
  800893:	85 c9                	test   %ecx,%ecx
  800895:	74 5e                	je     8008f5 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800897:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089a:	83 f8 2f             	cmp    $0x2f,%eax
  80089d:	77 48                	ja     8008e7 <vprintfmt+0x3ad>
  80089f:	89 c2                	mov    %eax,%edx
  8008a1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a5:	83 c0 08             	add    $0x8,%eax
  8008a8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ab:	48 8b 1a             	mov    (%rdx),%rbx
  8008ae:	eb 17                	jmp    8008c7 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008b0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b3:	83 f8 2f             	cmp    $0x2f,%eax
  8008b6:	77 21                	ja     8008d9 <vprintfmt+0x39f>
  8008b8:	89 c2                	mov    %eax,%edx
  8008ba:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008be:	83 c0 08             	add    $0x8,%eax
  8008c1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c4:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008c7:	48 85 db             	test   %rbx,%rbx
  8008ca:	78 50                	js     80091c <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008cc:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008d4:	e9 b4 01 00 00       	jmpq   800a8d <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e5:	eb dd                	jmp    8008c4 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008e7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008eb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ef:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008f3:	eb b6                	jmp    8008ab <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008f5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f8:	83 f8 2f             	cmp    $0x2f,%eax
  8008fb:	77 11                	ja     80090e <vprintfmt+0x3d4>
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800903:	83 c0 08             	add    $0x8,%eax
  800906:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800909:	48 63 1a             	movslq (%rdx),%rbx
  80090c:	eb b9                	jmp    8008c7 <vprintfmt+0x38d>
  80090e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800912:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800916:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091a:	eb ed                	jmp    800909 <vprintfmt+0x3cf>
          putch('-', putdat);
  80091c:	4c 89 fe             	mov    %r15,%rsi
  80091f:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800924:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800927:	48 89 da             	mov    %rbx,%rdx
  80092a:	48 f7 da             	neg    %rdx
        base = 10;
  80092d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800932:	e9 56 01 00 00       	jmpq   800a8d <vprintfmt+0x553>
  if (lflag >= 2)
  800937:	83 f9 01             	cmp    $0x1,%ecx
  80093a:	7f 25                	jg     800961 <vprintfmt+0x427>
  else if (lflag)
  80093c:	85 c9                	test   %ecx,%ecx
  80093e:	74 5e                	je     80099e <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800940:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800943:	83 f8 2f             	cmp    $0x2f,%eax
  800946:	77 48                	ja     800990 <vprintfmt+0x456>
  800948:	89 c2                	mov    %eax,%edx
  80094a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80094e:	83 c0 08             	add    $0x8,%eax
  800951:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800954:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800957:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80095c:	e9 2c 01 00 00       	jmpq   800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800961:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800964:	83 f8 2f             	cmp    $0x2f,%eax
  800967:	77 19                	ja     800982 <vprintfmt+0x448>
  800969:	89 c2                	mov    %eax,%edx
  80096b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096f:	83 c0 08             	add    $0x8,%eax
  800972:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800975:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800978:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80097d:	e9 0b 01 00 00       	jmpq   800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800982:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800986:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80098a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80098e:	eb e5                	jmp    800975 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800990:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800994:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800998:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099c:	eb b6                	jmp    800954 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80099e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a1:	83 f8 2f             	cmp    $0x2f,%eax
  8009a4:	77 18                	ja     8009be <vprintfmt+0x484>
  8009a6:	89 c2                	mov    %eax,%edx
  8009a8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ac:	83 c0 08             	add    $0x8,%eax
  8009af:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b2:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b9:	e9 cf 00 00 00       	jmpq   800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009be:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009c2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ca:	eb e6                	jmp    8009b2 <vprintfmt+0x478>
  if (lflag >= 2)
  8009cc:	83 f9 01             	cmp    $0x1,%ecx
  8009cf:	7f 25                	jg     8009f6 <vprintfmt+0x4bc>
  else if (lflag)
  8009d1:	85 c9                	test   %ecx,%ecx
  8009d3:	74 5b                	je     800a30 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009d5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d8:	83 f8 2f             	cmp    $0x2f,%eax
  8009db:	77 45                	ja     800a22 <vprintfmt+0x4e8>
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e3:	83 c0 08             	add    $0x8,%eax
  8009e6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e9:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009ec:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f1:	e9 97 00 00 00       	jmpq   800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f9:	83 f8 2f             	cmp    $0x2f,%eax
  8009fc:	77 16                	ja     800a14 <vprintfmt+0x4da>
  8009fe:	89 c2                	mov    %eax,%edx
  800a00:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a04:	83 c0 08             	add    $0x8,%eax
  800a07:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a0a:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a0d:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a12:	eb 79                	jmp    800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a14:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a18:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a20:	eb e8                	jmp    800a0a <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a22:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a26:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a2a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a2e:	eb b9                	jmp    8009e9 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a30:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a33:	83 f8 2f             	cmp    $0x2f,%eax
  800a36:	77 15                	ja     800a4d <vprintfmt+0x513>
  800a38:	89 c2                	mov    %eax,%edx
  800a3a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a3e:	83 c0 08             	add    $0x8,%eax
  800a41:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a44:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a46:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a4b:	eb 40                	jmp    800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a4d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a51:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a55:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a59:	eb e9                	jmp    800a44 <vprintfmt+0x50a>
        putch('0', putdat);
  800a5b:	4c 89 fe             	mov    %r15,%rsi
  800a5e:	bf 30 00 00 00       	mov    $0x30,%edi
  800a63:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a66:	4c 89 fe             	mov    %r15,%rsi
  800a69:	bf 78 00 00 00       	mov    $0x78,%edi
  800a6e:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a71:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a74:	83 f8 2f             	cmp    $0x2f,%eax
  800a77:	77 34                	ja     800aad <vprintfmt+0x573>
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a7f:	83 c0 08             	add    $0x8,%eax
  800a82:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a85:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a88:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a8d:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a92:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a96:	4c 89 fe             	mov    %r15,%rsi
  800a99:	4c 89 ef             	mov    %r13,%rdi
  800a9c:	48 b8 10 04 80 00 00 	movabs $0x800410,%rax
  800aa3:	00 00 00 
  800aa6:	ff d0                	callq  *%rax
        break;
  800aa8:	e9 b7 fa ff ff       	jmpq   800564 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800aad:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ab1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ab9:	eb ca                	jmp    800a85 <vprintfmt+0x54b>
  if (lflag >= 2)
  800abb:	83 f9 01             	cmp    $0x1,%ecx
  800abe:	7f 22                	jg     800ae2 <vprintfmt+0x5a8>
  else if (lflag)
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	74 58                	je     800b1c <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800ac4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ac7:	83 f8 2f             	cmp    $0x2f,%eax
  800aca:	77 42                	ja     800b0e <vprintfmt+0x5d4>
  800acc:	89 c2                	mov    %eax,%edx
  800ace:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad2:	83 c0 08             	add    $0x8,%eax
  800ad5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ad8:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800adb:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae0:	eb ab                	jmp    800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ae2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae5:	83 f8 2f             	cmp    $0x2f,%eax
  800ae8:	77 16                	ja     800b00 <vprintfmt+0x5c6>
  800aea:	89 c2                	mov    %eax,%edx
  800aec:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af0:	83 c0 08             	add    $0x8,%eax
  800af3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af6:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800af9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800afe:	eb 8d                	jmp    800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b00:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b04:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b08:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b0c:	eb e8                	jmp    800af6 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b0e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b12:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b16:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b1a:	eb bc                	jmp    800ad8 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b1c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1f:	83 f8 2f             	cmp    $0x2f,%eax
  800b22:	77 18                	ja     800b3c <vprintfmt+0x602>
  800b24:	89 c2                	mov    %eax,%edx
  800b26:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b2a:	83 c0 08             	add    $0x8,%eax
  800b2d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b30:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b32:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b37:	e9 51 ff ff ff       	jmpq   800a8d <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b3c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b40:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b44:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b48:	eb e6                	jmp    800b30 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b4a:	4c 89 fe             	mov    %r15,%rsi
  800b4d:	bf 25 00 00 00       	mov    $0x25,%edi
  800b52:	41 ff d5             	callq  *%r13
        break;
  800b55:	e9 0a fa ff ff       	jmpq   800564 <vprintfmt+0x2a>
        putch('%', putdat);
  800b5a:	4c 89 fe             	mov    %r15,%rsi
  800b5d:	bf 25 00 00 00       	mov    $0x25,%edi
  800b62:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b65:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b69:	0f 84 15 fa ff ff    	je     800584 <vprintfmt+0x4a>
  800b6f:	49 89 de             	mov    %rbx,%r14
  800b72:	49 83 ee 01          	sub    $0x1,%r14
  800b76:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b7b:	75 f5                	jne    800b72 <vprintfmt+0x638>
  800b7d:	e9 e2 f9 ff ff       	jmpq   800564 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b82:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b86:	74 06                	je     800b8e <vprintfmt+0x654>
  800b88:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b8c:	7f 21                	jg     800baf <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b8e:	bf 28 00 00 00       	mov    $0x28,%edi
  800b93:	48 bb fc 11 80 00 00 	movabs $0x8011fc,%rbx
  800b9a:	00 00 00 
  800b9d:	b8 28 00 00 00       	mov    $0x28,%eax
  800ba2:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ba6:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800baa:	e9 82 fc ff ff       	jmpq   800831 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800baf:	49 63 f4             	movslq %r12d,%rsi
  800bb2:	48 bf fb 11 80 00 00 	movabs $0x8011fb,%rdi
  800bb9:	00 00 00 
  800bbc:	48 b8 11 0d 80 00 00 	movabs $0x800d11,%rax
  800bc3:	00 00 00 
  800bc6:	ff d0                	callq  *%rax
  800bc8:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bcb:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bce:	48 be fb 11 80 00 00 	movabs $0x8011fb,%rsi
  800bd5:	00 00 00 
  800bd8:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	0f 8f f2 fb ff ff    	jg     8007d6 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800be4:	48 bb fc 11 80 00 00 	movabs $0x8011fc,%rbx
  800beb:	00 00 00 
  800bee:	b8 28 00 00 00       	mov    $0x28,%eax
  800bf3:	bf 28 00 00 00       	mov    $0x28,%edi
  800bf8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bfc:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c00:	e9 2c fc ff ff       	jmpq   800831 <vprintfmt+0x2f7>
}
  800c05:	48 83 c4 48          	add    $0x48,%rsp
  800c09:	5b                   	pop    %rbx
  800c0a:	41 5c                	pop    %r12
  800c0c:	41 5d                	pop    %r13
  800c0e:	41 5e                	pop    %r14
  800c10:	41 5f                	pop    %r15
  800c12:	5d                   	pop    %rbp
  800c13:	c3                   	retq   

0000000000800c14 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c14:	55                   	push   %rbp
  800c15:	48 89 e5             	mov    %rsp,%rbp
  800c18:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c1c:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c20:	48 63 c6             	movslq %esi,%rax
  800c23:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c28:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c2c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c33:	48 85 ff             	test   %rdi,%rdi
  800c36:	74 2a                	je     800c62 <vsnprintf+0x4e>
  800c38:	85 f6                	test   %esi,%esi
  800c3a:	7e 26                	jle    800c62 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c3c:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c40:	48 bf 9c 04 80 00 00 	movabs $0x80049c,%rdi
  800c47:	00 00 00 
  800c4a:	48 b8 3a 05 80 00 00 	movabs $0x80053a,%rax
  800c51:	00 00 00 
  800c54:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c56:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c5a:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c5d:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c60:	c9                   	leaveq 
  800c61:	c3                   	retq   
    return -E_INVAL;
  800c62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c67:	eb f7                	jmp    800c60 <vsnprintf+0x4c>

0000000000800c69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c69:	55                   	push   %rbp
  800c6a:	48 89 e5             	mov    %rsp,%rbp
  800c6d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c74:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c7b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c82:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c89:	84 c0                	test   %al,%al
  800c8b:	74 20                	je     800cad <snprintf+0x44>
  800c8d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c91:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c95:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c99:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c9d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ca1:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ca5:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ca9:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800cad:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800cb4:	00 00 00 
  800cb7:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800cbe:	00 00 00 
  800cc1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cc5:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800ccc:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cd3:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cda:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800ce1:	48 b8 14 0c 80 00 00 	movabs $0x800c14,%rax
  800ce8:	00 00 00 
  800ceb:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800ced:	c9                   	leaveq 
  800cee:	c3                   	retq   

0000000000800cef <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cef:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cf2:	74 17                	je     800d0b <strlen+0x1c>
  800cf4:	48 89 fa             	mov    %rdi,%rdx
  800cf7:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cfc:	29 f9                	sub    %edi,%ecx
    n++;
  800cfe:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d01:	48 83 c2 01          	add    $0x1,%rdx
  800d05:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d08:	75 f4                	jne    800cfe <strlen+0xf>
  800d0a:	c3                   	retq   
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d10:	c3                   	retq   

0000000000800d11 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d11:	48 85 f6             	test   %rsi,%rsi
  800d14:	74 24                	je     800d3a <strnlen+0x29>
  800d16:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d19:	74 25                	je     800d40 <strnlen+0x2f>
  800d1b:	48 01 fe             	add    %rdi,%rsi
  800d1e:	48 89 fa             	mov    %rdi,%rdx
  800d21:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d26:	29 f9                	sub    %edi,%ecx
    n++;
  800d28:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2b:	48 83 c2 01          	add    $0x1,%rdx
  800d2f:	48 39 f2             	cmp    %rsi,%rdx
  800d32:	74 11                	je     800d45 <strnlen+0x34>
  800d34:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d37:	75 ef                	jne    800d28 <strnlen+0x17>
  800d39:	c3                   	retq   
  800d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3f:	c3                   	retq   
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d45:	c3                   	retq   

0000000000800d46 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d46:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d49:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4e:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d52:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d55:	48 83 c2 01          	add    $0x1,%rdx
  800d59:	84 c9                	test   %cl,%cl
  800d5b:	75 f1                	jne    800d4e <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d5d:	c3                   	retq   

0000000000800d5e <strcat>:

char *
strcat(char *dst, const char *src) {
  800d5e:	55                   	push   %rbp
  800d5f:	48 89 e5             	mov    %rsp,%rbp
  800d62:	41 54                	push   %r12
  800d64:	53                   	push   %rbx
  800d65:	48 89 fb             	mov    %rdi,%rbx
  800d68:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d6b:	48 b8 ef 0c 80 00 00 	movabs $0x800cef,%rax
  800d72:	00 00 00 
  800d75:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d77:	48 63 f8             	movslq %eax,%rdi
  800d7a:	48 01 df             	add    %rbx,%rdi
  800d7d:	4c 89 e6             	mov    %r12,%rsi
  800d80:	48 b8 46 0d 80 00 00 	movabs $0x800d46,%rax
  800d87:	00 00 00 
  800d8a:	ff d0                	callq  *%rax
  return dst;
}
  800d8c:	48 89 d8             	mov    %rbx,%rax
  800d8f:	5b                   	pop    %rbx
  800d90:	41 5c                	pop    %r12
  800d92:	5d                   	pop    %rbp
  800d93:	c3                   	retq   

0000000000800d94 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d94:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d97:	48 85 d2             	test   %rdx,%rdx
  800d9a:	74 1f                	je     800dbb <strncpy+0x27>
  800d9c:	48 01 fa             	add    %rdi,%rdx
  800d9f:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800da2:	48 83 c1 01          	add    $0x1,%rcx
  800da6:	44 0f b6 06          	movzbl (%rsi),%r8d
  800daa:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800dae:	41 80 f8 01          	cmp    $0x1,%r8b
  800db2:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800db6:	48 39 ca             	cmp    %rcx,%rdx
  800db9:	75 e7                	jne    800da2 <strncpy+0xe>
  }
  return ret;
}
  800dbb:	c3                   	retq   

0000000000800dbc <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800dbc:	48 89 f8             	mov    %rdi,%rax
  800dbf:	48 85 d2             	test   %rdx,%rdx
  800dc2:	74 36                	je     800dfa <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800dc4:	48 83 fa 01          	cmp    $0x1,%rdx
  800dc8:	74 2d                	je     800df7 <strlcpy+0x3b>
  800dca:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dce:	45 84 c0             	test   %r8b,%r8b
  800dd1:	74 24                	je     800df7 <strlcpy+0x3b>
  800dd3:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dd7:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800ddc:	48 83 c0 01          	add    $0x1,%rax
  800de0:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800de4:	48 39 d1             	cmp    %rdx,%rcx
  800de7:	74 0e                	je     800df7 <strlcpy+0x3b>
  800de9:	48 83 c1 01          	add    $0x1,%rcx
  800ded:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800df2:	45 84 c0             	test   %r8b,%r8b
  800df5:	75 e5                	jne    800ddc <strlcpy+0x20>
    *dst = '\0';
  800df7:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dfa:	48 29 f8             	sub    %rdi,%rax
}
  800dfd:	c3                   	retq   

0000000000800dfe <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dfe:	0f b6 07             	movzbl (%rdi),%eax
  800e01:	84 c0                	test   %al,%al
  800e03:	74 17                	je     800e1c <strcmp+0x1e>
  800e05:	3a 06                	cmp    (%rsi),%al
  800e07:	75 13                	jne    800e1c <strcmp+0x1e>
    p++, q++;
  800e09:	48 83 c7 01          	add    $0x1,%rdi
  800e0d:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e11:	0f b6 07             	movzbl (%rdi),%eax
  800e14:	84 c0                	test   %al,%al
  800e16:	74 04                	je     800e1c <strcmp+0x1e>
  800e18:	3a 06                	cmp    (%rsi),%al
  800e1a:	74 ed                	je     800e09 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e1c:	0f b6 c0             	movzbl %al,%eax
  800e1f:	0f b6 16             	movzbl (%rsi),%edx
  800e22:	29 d0                	sub    %edx,%eax
}
  800e24:	c3                   	retq   

0000000000800e25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e25:	48 85 d2             	test   %rdx,%rdx
  800e28:	74 2f                	je     800e59 <strncmp+0x34>
  800e2a:	0f b6 07             	movzbl (%rdi),%eax
  800e2d:	84 c0                	test   %al,%al
  800e2f:	74 1f                	je     800e50 <strncmp+0x2b>
  800e31:	3a 06                	cmp    (%rsi),%al
  800e33:	75 1b                	jne    800e50 <strncmp+0x2b>
  800e35:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e38:	48 83 c7 01          	add    $0x1,%rdi
  800e3c:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e40:	48 39 d7             	cmp    %rdx,%rdi
  800e43:	74 1a                	je     800e5f <strncmp+0x3a>
  800e45:	0f b6 07             	movzbl (%rdi),%eax
  800e48:	84 c0                	test   %al,%al
  800e4a:	74 04                	je     800e50 <strncmp+0x2b>
  800e4c:	3a 06                	cmp    (%rsi),%al
  800e4e:	74 e8                	je     800e38 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e50:	0f b6 07             	movzbl (%rdi),%eax
  800e53:	0f b6 16             	movzbl (%rsi),%edx
  800e56:	29 d0                	sub    %edx,%eax
}
  800e58:	c3                   	retq   
    return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	c3                   	retq   
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	c3                   	retq   

0000000000800e65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e65:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e67:	0f b6 07             	movzbl (%rdi),%eax
  800e6a:	84 c0                	test   %al,%al
  800e6c:	74 1e                	je     800e8c <strchr+0x27>
    if (*s == c)
  800e6e:	40 38 c6             	cmp    %al,%sil
  800e71:	74 1f                	je     800e92 <strchr+0x2d>
  for (; *s; s++)
  800e73:	48 83 c7 01          	add    $0x1,%rdi
  800e77:	0f b6 07             	movzbl (%rdi),%eax
  800e7a:	84 c0                	test   %al,%al
  800e7c:	74 08                	je     800e86 <strchr+0x21>
    if (*s == c)
  800e7e:	38 d0                	cmp    %dl,%al
  800e80:	75 f1                	jne    800e73 <strchr+0xe>
  for (; *s; s++)
  800e82:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e85:	c3                   	retq   
  return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	c3                   	retq   
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e91:	c3                   	retq   
    if (*s == c)
  800e92:	48 89 f8             	mov    %rdi,%rax
  800e95:	c3                   	retq   

0000000000800e96 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e96:	48 89 f8             	mov    %rdi,%rax
  800e99:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e9b:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e9e:	40 38 f2             	cmp    %sil,%dl
  800ea1:	74 13                	je     800eb6 <strfind+0x20>
  800ea3:	84 d2                	test   %dl,%dl
  800ea5:	74 0f                	je     800eb6 <strfind+0x20>
  for (; *s; s++)
  800ea7:	48 83 c0 01          	add    $0x1,%rax
  800eab:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800eae:	38 ca                	cmp    %cl,%dl
  800eb0:	74 04                	je     800eb6 <strfind+0x20>
  800eb2:	84 d2                	test   %dl,%dl
  800eb4:	75 f1                	jne    800ea7 <strfind+0x11>
      break;
  return (char *)s;
}
  800eb6:	c3                   	retq   

0000000000800eb7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800eb7:	48 85 d2             	test   %rdx,%rdx
  800eba:	74 3a                	je     800ef6 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ebc:	48 89 f8             	mov    %rdi,%rax
  800ebf:	48 09 d0             	or     %rdx,%rax
  800ec2:	a8 03                	test   $0x3,%al
  800ec4:	75 28                	jne    800eee <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ec6:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800eca:	89 f0                	mov    %esi,%eax
  800ecc:	c1 e0 08             	shl    $0x8,%eax
  800ecf:	89 f1                	mov    %esi,%ecx
  800ed1:	c1 e1 18             	shl    $0x18,%ecx
  800ed4:	41 89 f0             	mov    %esi,%r8d
  800ed7:	41 c1 e0 10          	shl    $0x10,%r8d
  800edb:	44 09 c1             	or     %r8d,%ecx
  800ede:	09 ce                	or     %ecx,%esi
  800ee0:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ee2:	48 c1 ea 02          	shr    $0x2,%rdx
  800ee6:	48 89 d1             	mov    %rdx,%rcx
  800ee9:	fc                   	cld    
  800eea:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eec:	eb 08                	jmp    800ef6 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	48 89 d1             	mov    %rdx,%rcx
  800ef3:	fc                   	cld    
  800ef4:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ef6:	48 89 f8             	mov    %rdi,%rax
  800ef9:	c3                   	retq   

0000000000800efa <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800efa:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800efd:	48 39 fe             	cmp    %rdi,%rsi
  800f00:	73 40                	jae    800f42 <memmove+0x48>
  800f02:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f06:	48 39 f9             	cmp    %rdi,%rcx
  800f09:	76 37                	jbe    800f42 <memmove+0x48>
    s += n;
    d += n;
  800f0b:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f0f:	48 89 fe             	mov    %rdi,%rsi
  800f12:	48 09 d6             	or     %rdx,%rsi
  800f15:	48 09 ce             	or     %rcx,%rsi
  800f18:	40 f6 c6 03          	test   $0x3,%sil
  800f1c:	75 14                	jne    800f32 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f1e:	48 83 ef 04          	sub    $0x4,%rdi
  800f22:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f26:	48 c1 ea 02          	shr    $0x2,%rdx
  800f2a:	48 89 d1             	mov    %rdx,%rcx
  800f2d:	fd                   	std    
  800f2e:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f30:	eb 0e                	jmp    800f40 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f32:	48 83 ef 01          	sub    $0x1,%rdi
  800f36:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f3a:	48 89 d1             	mov    %rdx,%rcx
  800f3d:	fd                   	std    
  800f3e:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f40:	fc                   	cld    
  800f41:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f42:	48 89 c1             	mov    %rax,%rcx
  800f45:	48 09 d1             	or     %rdx,%rcx
  800f48:	48 09 f1             	or     %rsi,%rcx
  800f4b:	f6 c1 03             	test   $0x3,%cl
  800f4e:	75 0e                	jne    800f5e <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f50:	48 c1 ea 02          	shr    $0x2,%rdx
  800f54:	48 89 d1             	mov    %rdx,%rcx
  800f57:	48 89 c7             	mov    %rax,%rdi
  800f5a:	fc                   	cld    
  800f5b:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f5d:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f5e:	48 89 c7             	mov    %rax,%rdi
  800f61:	48 89 d1             	mov    %rdx,%rcx
  800f64:	fc                   	cld    
  800f65:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f67:	c3                   	retq   

0000000000800f68 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f68:	55                   	push   %rbp
  800f69:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f6c:	48 b8 fa 0e 80 00 00 	movabs $0x800efa,%rax
  800f73:	00 00 00 
  800f76:	ff d0                	callq  *%rax
}
  800f78:	5d                   	pop    %rbp
  800f79:	c3                   	retq   

0000000000800f7a <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f7a:	55                   	push   %rbp
  800f7b:	48 89 e5             	mov    %rsp,%rbp
  800f7e:	41 57                	push   %r15
  800f80:	41 56                	push   %r14
  800f82:	41 55                	push   %r13
  800f84:	41 54                	push   %r12
  800f86:	53                   	push   %rbx
  800f87:	48 83 ec 08          	sub    $0x8,%rsp
  800f8b:	49 89 fe             	mov    %rdi,%r14
  800f8e:	49 89 f7             	mov    %rsi,%r15
  800f91:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f94:	48 89 f7             	mov    %rsi,%rdi
  800f97:	48 b8 ef 0c 80 00 00 	movabs $0x800cef,%rax
  800f9e:	00 00 00 
  800fa1:	ff d0                	callq  *%rax
  800fa3:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800fa6:	4c 89 ee             	mov    %r13,%rsi
  800fa9:	4c 89 f7             	mov    %r14,%rdi
  800fac:	48 b8 11 0d 80 00 00 	movabs $0x800d11,%rax
  800fb3:	00 00 00 
  800fb6:	ff d0                	callq  *%rax
  800fb8:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fbb:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fbf:	4d 39 e5             	cmp    %r12,%r13
  800fc2:	74 26                	je     800fea <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fc4:	4c 89 e8             	mov    %r13,%rax
  800fc7:	4c 29 e0             	sub    %r12,%rax
  800fca:	48 39 d8             	cmp    %rbx,%rax
  800fcd:	76 2a                	jbe    800ff9 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fcf:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fd3:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fd7:	4c 89 fe             	mov    %r15,%rsi
  800fda:	48 b8 68 0f 80 00 00 	movabs $0x800f68,%rax
  800fe1:	00 00 00 
  800fe4:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fe6:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fea:	48 83 c4 08          	add    $0x8,%rsp
  800fee:	5b                   	pop    %rbx
  800fef:	41 5c                	pop    %r12
  800ff1:	41 5d                	pop    %r13
  800ff3:	41 5e                	pop    %r14
  800ff5:	41 5f                	pop    %r15
  800ff7:	5d                   	pop    %rbp
  800ff8:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800ff9:	49 83 ed 01          	sub    $0x1,%r13
  800ffd:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801001:	4c 89 ea             	mov    %r13,%rdx
  801004:	4c 89 fe             	mov    %r15,%rsi
  801007:	48 b8 68 0f 80 00 00 	movabs $0x800f68,%rax
  80100e:	00 00 00 
  801011:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801013:	4d 01 ee             	add    %r13,%r14
  801016:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80101b:	eb c9                	jmp    800fe6 <strlcat+0x6c>

000000000080101d <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80101d:	48 85 d2             	test   %rdx,%rdx
  801020:	74 3a                	je     80105c <memcmp+0x3f>
    if (*s1 != *s2)
  801022:	0f b6 0f             	movzbl (%rdi),%ecx
  801025:	44 0f b6 06          	movzbl (%rsi),%r8d
  801029:	44 38 c1             	cmp    %r8b,%cl
  80102c:	75 1d                	jne    80104b <memcmp+0x2e>
  80102e:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801033:	48 39 d0             	cmp    %rdx,%rax
  801036:	74 1e                	je     801056 <memcmp+0x39>
    if (*s1 != *s2)
  801038:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80103c:	48 83 c0 01          	add    $0x1,%rax
  801040:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801046:	44 38 c1             	cmp    %r8b,%cl
  801049:	74 e8                	je     801033 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80104b:	0f b6 c1             	movzbl %cl,%eax
  80104e:	45 0f b6 c0          	movzbl %r8b,%r8d
  801052:	44 29 c0             	sub    %r8d,%eax
  801055:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801056:	b8 00 00 00 00       	mov    $0x0,%eax
  80105b:	c3                   	retq   
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801061:	c3                   	retq   

0000000000801062 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801062:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801066:	48 39 c7             	cmp    %rax,%rdi
  801069:	73 19                	jae    801084 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80106b:	89 f2                	mov    %esi,%edx
  80106d:	40 38 37             	cmp    %sil,(%rdi)
  801070:	74 16                	je     801088 <memfind+0x26>
  for (; s < ends; s++)
  801072:	48 83 c7 01          	add    $0x1,%rdi
  801076:	48 39 f8             	cmp    %rdi,%rax
  801079:	74 08                	je     801083 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80107b:	38 17                	cmp    %dl,(%rdi)
  80107d:	75 f3                	jne    801072 <memfind+0x10>
  for (; s < ends; s++)
  80107f:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801082:	c3                   	retq   
  801083:	c3                   	retq   
  for (; s < ends; s++)
  801084:	48 89 f8             	mov    %rdi,%rax
  801087:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801088:	48 89 f8             	mov    %rdi,%rax
  80108b:	c3                   	retq   

000000000080108c <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80108c:	0f b6 07             	movzbl (%rdi),%eax
  80108f:	3c 20                	cmp    $0x20,%al
  801091:	74 04                	je     801097 <strtol+0xb>
  801093:	3c 09                	cmp    $0x9,%al
  801095:	75 0f                	jne    8010a6 <strtol+0x1a>
    s++;
  801097:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80109b:	0f b6 07             	movzbl (%rdi),%eax
  80109e:	3c 20                	cmp    $0x20,%al
  8010a0:	74 f5                	je     801097 <strtol+0xb>
  8010a2:	3c 09                	cmp    $0x9,%al
  8010a4:	74 f1                	je     801097 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010a6:	3c 2b                	cmp    $0x2b,%al
  8010a8:	74 2b                	je     8010d5 <strtol+0x49>
  int neg  = 0;
  8010aa:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010b0:	3c 2d                	cmp    $0x2d,%al
  8010b2:	74 2d                	je     8010e1 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b4:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010ba:	75 0f                	jne    8010cb <strtol+0x3f>
  8010bc:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010bf:	74 2c                	je     8010ed <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010c1:	85 d2                	test   %edx,%edx
  8010c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c8:	0f 44 d0             	cmove  %eax,%edx
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010d0:	4c 63 d2             	movslq %edx,%r10
  8010d3:	eb 5c                	jmp    801131 <strtol+0xa5>
    s++;
  8010d5:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010d9:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010df:	eb d3                	jmp    8010b4 <strtol+0x28>
    s++, neg = 1;
  8010e1:	48 83 c7 01          	add    $0x1,%rdi
  8010e5:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010eb:	eb c7                	jmp    8010b4 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ed:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010f1:	74 0f                	je     801102 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010f3:	85 d2                	test   %edx,%edx
  8010f5:	75 d4                	jne    8010cb <strtol+0x3f>
    s++, base = 8;
  8010f7:	48 83 c7 01          	add    $0x1,%rdi
  8010fb:	ba 08 00 00 00       	mov    $0x8,%edx
  801100:	eb c9                	jmp    8010cb <strtol+0x3f>
    s += 2, base = 16;
  801102:	48 83 c7 02          	add    $0x2,%rdi
  801106:	ba 10 00 00 00       	mov    $0x10,%edx
  80110b:	eb be                	jmp    8010cb <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80110d:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801111:	41 80 f8 19          	cmp    $0x19,%r8b
  801115:	77 2f                	ja     801146 <strtol+0xba>
      dig = *s - 'a' + 10;
  801117:	44 0f be c1          	movsbl %cl,%r8d
  80111b:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80111f:	39 d1                	cmp    %edx,%ecx
  801121:	7d 37                	jge    80115a <strtol+0xce>
    s++, val = (val * base) + dig;
  801123:	48 83 c7 01          	add    $0x1,%rdi
  801127:	49 0f af c2          	imul   %r10,%rax
  80112b:	48 63 c9             	movslq %ecx,%rcx
  80112e:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801131:	0f b6 0f             	movzbl (%rdi),%ecx
  801134:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801138:	41 80 f8 09          	cmp    $0x9,%r8b
  80113c:	77 cf                	ja     80110d <strtol+0x81>
      dig = *s - '0';
  80113e:	0f be c9             	movsbl %cl,%ecx
  801141:	83 e9 30             	sub    $0x30,%ecx
  801144:	eb d9                	jmp    80111f <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801146:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80114a:	41 80 f8 19          	cmp    $0x19,%r8b
  80114e:	77 0a                	ja     80115a <strtol+0xce>
      dig = *s - 'A' + 10;
  801150:	44 0f be c1          	movsbl %cl,%r8d
  801154:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801158:	eb c5                	jmp    80111f <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80115a:	48 85 f6             	test   %rsi,%rsi
  80115d:	74 03                	je     801162 <strtol+0xd6>
    *endptr = (char *)s;
  80115f:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801162:	48 89 c2             	mov    %rax,%rdx
  801165:	48 f7 da             	neg    %rdx
  801168:	45 85 c9             	test   %r9d,%r9d
  80116b:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80116f:	c3                   	retq   
