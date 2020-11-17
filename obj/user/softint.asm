
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  80007a:	48 b8 9c 01 80 00 00 	movabs $0x80019c,%rax
  800081:	00 00 00 
  800084:	ff d0                	callq  *%rax
  800086:	83 e0 1f             	and    $0x1f,%eax
  800089:	48 89 c2             	mov    %rax,%rdx
  80008c:	48 c1 e2 05          	shl    $0x5,%rdx
  800090:	48 29 c2             	sub    %rax,%rdx
  800093:	48 89 d0             	mov    %rdx,%rax
  800096:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80009d:	00 00 00 
  8000a0:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000a4:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000ab:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000ae:	45 85 ed             	test   %r13d,%r13d
  8000b1:	7e 0d                	jle    8000c0 <libmain+0x93>
    binaryname = argv[0];
  8000b3:	49 8b 06             	mov    (%r14),%rax
  8000b6:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000bd:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000c0:	4c 89 f6             	mov    %r14,%rsi
  8000c3:	44 89 ef             	mov    %r13d,%edi
  8000c6:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000cd:	00 00 00 
  8000d0:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000d2:	48 b8 e7 00 80 00 00 	movabs $0x8000e7,%rax
  8000d9:	00 00 00 
  8000dc:	ff d0                	callq  *%rax
#endif
}
  8000de:	5b                   	pop    %rbx
  8000df:	41 5c                	pop    %r12
  8000e1:	41 5d                	pop    %r13
  8000e3:	41 5e                	pop    %r14
  8000e5:	5d                   	pop    %rbp
  8000e6:	c3                   	retq   

00000000008000e7 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000e7:	55                   	push   %rbp
  8000e8:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f0:	48 b8 3c 01 80 00 00 	movabs $0x80013c,%rax
  8000f7:	00 00 00 
  8000fa:	ff d0                	callq  *%rax
}
  8000fc:	5d                   	pop    %rbp
  8000fd:	c3                   	retq   

00000000008000fe <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000fe:	55                   	push   %rbp
  8000ff:	48 89 e5             	mov    %rsp,%rbp
  800102:	53                   	push   %rbx
  800103:	48 89 fa             	mov    %rdi,%rdx
  800106:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800109:	b8 00 00 00 00       	mov    $0x0,%eax
  80010e:	48 89 c3             	mov    %rax,%rbx
  800111:	48 89 c7             	mov    %rax,%rdi
  800114:	48 89 c6             	mov    %rax,%rsi
  800117:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800119:	5b                   	pop    %rbx
  80011a:	5d                   	pop    %rbp
  80011b:	c3                   	retq   

000000000080011c <sys_cgetc>:

int
sys_cgetc(void) {
  80011c:	55                   	push   %rbp
  80011d:	48 89 e5             	mov    %rsp,%rbp
  800120:	53                   	push   %rbx
  asm volatile("int %1\n"
  800121:	b9 00 00 00 00       	mov    $0x0,%ecx
  800126:	b8 01 00 00 00       	mov    $0x1,%eax
  80012b:	48 89 ca             	mov    %rcx,%rdx
  80012e:	48 89 cb             	mov    %rcx,%rbx
  800131:	48 89 cf             	mov    %rcx,%rdi
  800134:	48 89 ce             	mov    %rcx,%rsi
  800137:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800139:	5b                   	pop    %rbx
  80013a:	5d                   	pop    %rbp
  80013b:	c3                   	retq   

000000000080013c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80013c:	55                   	push   %rbp
  80013d:	48 89 e5             	mov    %rsp,%rbp
  800140:	53                   	push   %rbx
  800141:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800145:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800148:	be 00 00 00 00       	mov    $0x0,%esi
  80014d:	b8 03 00 00 00       	mov    $0x3,%eax
  800152:	48 89 f1             	mov    %rsi,%rcx
  800155:	48 89 f3             	mov    %rsi,%rbx
  800158:	48 89 f7             	mov    %rsi,%rdi
  80015b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80015d:	48 85 c0             	test   %rax,%rax
  800160:	7f 07                	jg     800169 <sys_env_destroy+0x2d>
}
  800162:	48 83 c4 08          	add    $0x8,%rsp
  800166:	5b                   	pop    %rbx
  800167:	5d                   	pop    %rbp
  800168:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800169:	49 89 c0             	mov    %rax,%r8
  80016c:	b9 03 00 00 00       	mov    $0x3,%ecx
  800171:	48 ba 70 11 80 00 00 	movabs $0x801170,%rdx
  800178:	00 00 00 
  80017b:	be 22 00 00 00       	mov    $0x22,%esi
  800180:	48 bf 8f 11 80 00 00 	movabs $0x80118f,%rdi
  800187:	00 00 00 
  80018a:	b8 00 00 00 00       	mov    $0x0,%eax
  80018f:	49 b9 bc 01 80 00 00 	movabs $0x8001bc,%r9
  800196:	00 00 00 
  800199:	41 ff d1             	callq  *%r9

000000000080019c <sys_getenvid>:

envid_t
sys_getenvid(void) {
  80019c:	55                   	push   %rbp
  80019d:	48 89 e5             	mov    %rsp,%rbp
  8001a0:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8001ab:	48 89 ca             	mov    %rcx,%rdx
  8001ae:	48 89 cb             	mov    %rcx,%rbx
  8001b1:	48 89 cf             	mov    %rcx,%rdi
  8001b4:	48 89 ce             	mov    %rcx,%rsi
  8001b7:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001b9:	5b                   	pop    %rbx
  8001ba:	5d                   	pop    %rbp
  8001bb:	c3                   	retq   

00000000008001bc <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001bc:	55                   	push   %rbp
  8001bd:	48 89 e5             	mov    %rsp,%rbp
  8001c0:	41 56                	push   %r14
  8001c2:	41 55                	push   %r13
  8001c4:	41 54                	push   %r12
  8001c6:	53                   	push   %rbx
  8001c7:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001ce:	49 89 fd             	mov    %rdi,%r13
  8001d1:	41 89 f6             	mov    %esi,%r14d
  8001d4:	49 89 d4             	mov    %rdx,%r12
  8001d7:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001de:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001e5:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001ec:	84 c0                	test   %al,%al
  8001ee:	74 26                	je     800216 <_panic+0x5a>
  8001f0:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8001f7:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8001fe:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800202:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800206:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80020a:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80020e:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800212:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800216:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80021d:	00 00 00 
  800220:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800227:	00 00 00 
  80022a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80022e:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800235:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80023c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80024a:	00 00 00 
  80024d:	48 8b 18             	mov    (%rax),%rbx
  800250:	48 b8 9c 01 80 00 00 	movabs $0x80019c,%rax
  800257:	00 00 00 
  80025a:	ff d0                	callq  *%rax
  80025c:	45 89 f0             	mov    %r14d,%r8d
  80025f:	4c 89 e9             	mov    %r13,%rcx
  800262:	48 89 da             	mov    %rbx,%rdx
  800265:	89 c6                	mov    %eax,%esi
  800267:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  80026e:	00 00 00 
  800271:	b8 00 00 00 00       	mov    $0x0,%eax
  800276:	48 bb 5e 03 80 00 00 	movabs $0x80035e,%rbx
  80027d:	00 00 00 
  800280:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800282:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800289:	4c 89 e7             	mov    %r12,%rdi
  80028c:	48 b8 f6 02 80 00 00 	movabs $0x8002f6,%rax
  800293:	00 00 00 
  800296:	ff d0                	callq  *%rax
  cprintf("\n");
  800298:	48 bf c8 11 80 00 00 	movabs $0x8011c8,%rdi
  80029f:	00 00 00 
  8002a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a7:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002a9:	cc                   	int3   
  while (1)
  8002aa:	eb fd                	jmp    8002a9 <_panic+0xed>

00000000008002ac <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002ac:	55                   	push   %rbp
  8002ad:	48 89 e5             	mov    %rsp,%rbp
  8002b0:	53                   	push   %rbx
  8002b1:	48 83 ec 08          	sub    $0x8,%rsp
  8002b5:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002b8:	8b 06                	mov    (%rsi),%eax
  8002ba:	8d 50 01             	lea    0x1(%rax),%edx
  8002bd:	89 16                	mov    %edx,(%rsi)
  8002bf:	48 98                	cltq   
  8002c1:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002c6:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002cc:	74 0b                	je     8002d9 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002ce:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002d2:	48 83 c4 08          	add    $0x8,%rsp
  8002d6:	5b                   	pop    %rbx
  8002d7:	5d                   	pop    %rbp
  8002d8:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002d9:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002dd:	be ff 00 00 00       	mov    $0xff,%esi
  8002e2:	48 b8 fe 00 80 00 00 	movabs $0x8000fe,%rax
  8002e9:	00 00 00 
  8002ec:	ff d0                	callq  *%rax
    b->idx = 0;
  8002ee:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8002f4:	eb d8                	jmp    8002ce <putch+0x22>

00000000008002f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8002f6:	55                   	push   %rbp
  8002f7:	48 89 e5             	mov    %rsp,%rbp
  8002fa:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800301:	48 89 fa             	mov    %rdi,%rdx
  800304:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800307:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80030e:	00 00 00 
  b.cnt = 0;
  800311:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800318:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80031b:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800322:	48 bf ac 02 80 00 00 	movabs $0x8002ac,%rdi
  800329:	00 00 00 
  80032c:	48 b8 1c 05 80 00 00 	movabs $0x80051c,%rax
  800333:	00 00 00 
  800336:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800338:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80033f:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800346:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80034a:	48 b8 fe 00 80 00 00 	movabs $0x8000fe,%rax
  800351:	00 00 00 
  800354:	ff d0                	callq  *%rax

  return b.cnt;
}
  800356:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80035c:	c9                   	leaveq 
  80035d:	c3                   	retq   

000000000080035e <cprintf>:

int
cprintf(const char *fmt, ...) {
  80035e:	55                   	push   %rbp
  80035f:	48 89 e5             	mov    %rsp,%rbp
  800362:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800369:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800370:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800377:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80037e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800385:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80038c:	84 c0                	test   %al,%al
  80038e:	74 20                	je     8003b0 <cprintf+0x52>
  800390:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800394:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800398:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80039c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003a0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003a4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003a8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003ac:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003b0:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003b7:	00 00 00 
  8003ba:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003c1:	00 00 00 
  8003c4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003c8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003cf:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003d6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003dd:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003e4:	48 b8 f6 02 80 00 00 	movabs $0x8002f6,%rax
  8003eb:	00 00 00 
  8003ee:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003f0:	c9                   	leaveq 
  8003f1:	c3                   	retq   

00000000008003f2 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8003f2:	55                   	push   %rbp
  8003f3:	48 89 e5             	mov    %rsp,%rbp
  8003f6:	41 57                	push   %r15
  8003f8:	41 56                	push   %r14
  8003fa:	41 55                	push   %r13
  8003fc:	41 54                	push   %r12
  8003fe:	53                   	push   %rbx
  8003ff:	48 83 ec 18          	sub    $0x18,%rsp
  800403:	49 89 fc             	mov    %rdi,%r12
  800406:	49 89 f5             	mov    %rsi,%r13
  800409:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80040d:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800410:	41 89 cf             	mov    %ecx,%r15d
  800413:	49 39 d7             	cmp    %rdx,%r15
  800416:	76 45                	jbe    80045d <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800418:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80041c:	85 db                	test   %ebx,%ebx
  80041e:	7e 0e                	jle    80042e <printnum+0x3c>
      putch(padc, putdat);
  800420:	4c 89 ee             	mov    %r13,%rsi
  800423:	44 89 f7             	mov    %r14d,%edi
  800426:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800429:	83 eb 01             	sub    $0x1,%ebx
  80042c:	75 f2                	jne    800420 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80042e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800432:	ba 00 00 00 00       	mov    $0x0,%edx
  800437:	49 f7 f7             	div    %r15
  80043a:	48 b8 ca 11 80 00 00 	movabs $0x8011ca,%rax
  800441:	00 00 00 
  800444:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800448:	4c 89 ee             	mov    %r13,%rsi
  80044b:	41 ff d4             	callq  *%r12
}
  80044e:	48 83 c4 18          	add    $0x18,%rsp
  800452:	5b                   	pop    %rbx
  800453:	41 5c                	pop    %r12
  800455:	41 5d                	pop    %r13
  800457:	41 5e                	pop    %r14
  800459:	41 5f                	pop    %r15
  80045b:	5d                   	pop    %rbp
  80045c:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80045d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	49 f7 f7             	div    %r15
  800469:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80046d:	48 89 c2             	mov    %rax,%rdx
  800470:	48 b8 f2 03 80 00 00 	movabs $0x8003f2,%rax
  800477:	00 00 00 
  80047a:	ff d0                	callq  *%rax
  80047c:	eb b0                	jmp    80042e <printnum+0x3c>

000000000080047e <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80047e:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800482:	48 8b 06             	mov    (%rsi),%rax
  800485:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800489:	73 0a                	jae    800495 <sprintputch+0x17>
    *b->buf++ = ch;
  80048b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80048f:	48 89 16             	mov    %rdx,(%rsi)
  800492:	40 88 38             	mov    %dil,(%rax)
}
  800495:	c3                   	retq   

0000000000800496 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800496:	55                   	push   %rbp
  800497:	48 89 e5             	mov    %rsp,%rbp
  80049a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004a1:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004a8:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004af:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004b6:	84 c0                	test   %al,%al
  8004b8:	74 20                	je     8004da <printfmt+0x44>
  8004ba:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004be:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004c2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004c6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004ca:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004ce:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004d2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004d6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004da:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004e1:	00 00 00 
  8004e4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004eb:	00 00 00 
  8004ee:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004f2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004f9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800500:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800507:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80050e:	48 b8 1c 05 80 00 00 	movabs $0x80051c,%rax
  800515:	00 00 00 
  800518:	ff d0                	callq  *%rax
}
  80051a:	c9                   	leaveq 
  80051b:	c3                   	retq   

000000000080051c <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80051c:	55                   	push   %rbp
  80051d:	48 89 e5             	mov    %rsp,%rbp
  800520:	41 57                	push   %r15
  800522:	41 56                	push   %r14
  800524:	41 55                	push   %r13
  800526:	41 54                	push   %r12
  800528:	53                   	push   %rbx
  800529:	48 83 ec 48          	sub    $0x48,%rsp
  80052d:	49 89 fd             	mov    %rdi,%r13
  800530:	49 89 f7             	mov    %rsi,%r15
  800533:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800536:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80053a:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80053e:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800542:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800546:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80054a:	41 0f b6 3e          	movzbl (%r14),%edi
  80054e:	83 ff 25             	cmp    $0x25,%edi
  800551:	74 18                	je     80056b <vprintfmt+0x4f>
      if (ch == '\0')
  800553:	85 ff                	test   %edi,%edi
  800555:	0f 84 8c 06 00 00    	je     800be7 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80055b:	4c 89 fe             	mov    %r15,%rsi
  80055e:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800561:	49 89 de             	mov    %rbx,%r14
  800564:	eb e0                	jmp    800546 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800566:	49 89 de             	mov    %rbx,%r14
  800569:	eb db                	jmp    800546 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80056b:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80056f:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800573:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80057a:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800580:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800584:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800589:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80058f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800595:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80059a:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80059f:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005a3:	0f b6 13             	movzbl (%rbx),%edx
  8005a6:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005a9:	3c 55                	cmp    $0x55,%al
  8005ab:	0f 87 8b 05 00 00    	ja     800b3c <vprintfmt+0x620>
  8005b1:	0f b6 c0             	movzbl %al,%eax
  8005b4:	49 bb 80 12 80 00 00 	movabs $0x801280,%r11
  8005bb:	00 00 00 
  8005be:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005c2:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005c5:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005c9:	eb d4                	jmp    80059f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005cb:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005ce:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005d2:	eb cb                	jmp    80059f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005d4:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005d7:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005db:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005df:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005e2:	83 fa 09             	cmp    $0x9,%edx
  8005e5:	77 7e                	ja     800665 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005e7:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005eb:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005ef:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8005f4:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8005f8:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005fb:	83 fa 09             	cmp    $0x9,%edx
  8005fe:	76 e7                	jbe    8005e7 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800600:	4c 89 f3             	mov    %r14,%rbx
  800603:	eb 19                	jmp    80061e <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800605:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800608:	83 f8 2f             	cmp    $0x2f,%eax
  80060b:	77 2a                	ja     800637 <vprintfmt+0x11b>
  80060d:	89 c2                	mov    %eax,%edx
  80060f:	4c 01 d2             	add    %r10,%rdx
  800612:	83 c0 08             	add    $0x8,%eax
  800615:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800618:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80061b:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80061e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800622:	0f 89 77 ff ff ff    	jns    80059f <vprintfmt+0x83>
          width = precision, precision = -1;
  800628:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80062c:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800632:	e9 68 ff ff ff       	jmpq   80059f <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800637:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80063b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80063f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800643:	eb d3                	jmp    800618 <vprintfmt+0xfc>
        if (width < 0)
  800645:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800648:	85 c0                	test   %eax,%eax
  80064a:	41 0f 48 c0          	cmovs  %r8d,%eax
  80064e:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800651:	4c 89 f3             	mov    %r14,%rbx
  800654:	e9 46 ff ff ff       	jmpq   80059f <vprintfmt+0x83>
  800659:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80065c:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800660:	e9 3a ff ff ff       	jmpq   80059f <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800665:	4c 89 f3             	mov    %r14,%rbx
  800668:	eb b4                	jmp    80061e <vprintfmt+0x102>
        lflag++;
  80066a:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80066d:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800670:	e9 2a ff ff ff       	jmpq   80059f <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800675:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800678:	83 f8 2f             	cmp    $0x2f,%eax
  80067b:	77 19                	ja     800696 <vprintfmt+0x17a>
  80067d:	89 c2                	mov    %eax,%edx
  80067f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800683:	83 c0 08             	add    $0x8,%eax
  800686:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800689:	4c 89 fe             	mov    %r15,%rsi
  80068c:	8b 3a                	mov    (%rdx),%edi
  80068e:	41 ff d5             	callq  *%r13
        break;
  800691:	e9 b0 fe ff ff       	jmpq   800546 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800696:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80069a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80069e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006a2:	eb e5                	jmp    800689 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006a4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006a7:	83 f8 2f             	cmp    $0x2f,%eax
  8006aa:	77 5b                	ja     800707 <vprintfmt+0x1eb>
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006b2:	83 c0 08             	add    $0x8,%eax
  8006b5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006b8:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006ba:	89 c8                	mov    %ecx,%eax
  8006bc:	c1 f8 1f             	sar    $0x1f,%eax
  8006bf:	31 c1                	xor    %eax,%ecx
  8006c1:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c3:	83 f9 09             	cmp    $0x9,%ecx
  8006c6:	7f 4d                	jg     800715 <vprintfmt+0x1f9>
  8006c8:	48 63 c1             	movslq %ecx,%rax
  8006cb:	48 ba 40 15 80 00 00 	movabs $0x801540,%rdx
  8006d2:	00 00 00 
  8006d5:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006d9:	48 85 c0             	test   %rax,%rax
  8006dc:	74 37                	je     800715 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006de:	48 89 c1             	mov    %rax,%rcx
  8006e1:	48 ba eb 11 80 00 00 	movabs $0x8011eb,%rdx
  8006e8:	00 00 00 
  8006eb:	4c 89 fe             	mov    %r15,%rsi
  8006ee:	4c 89 ef             	mov    %r13,%rdi
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f6:	48 bb 96 04 80 00 00 	movabs $0x800496,%rbx
  8006fd:	00 00 00 
  800700:	ff d3                	callq  *%rbx
  800702:	e9 3f fe ff ff       	jmpq   800546 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800707:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80070b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80070f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800713:	eb a3                	jmp    8006b8 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800715:	48 ba e2 11 80 00 00 	movabs $0x8011e2,%rdx
  80071c:	00 00 00 
  80071f:	4c 89 fe             	mov    %r15,%rsi
  800722:	4c 89 ef             	mov    %r13,%rdi
  800725:	b8 00 00 00 00       	mov    $0x0,%eax
  80072a:	48 bb 96 04 80 00 00 	movabs $0x800496,%rbx
  800731:	00 00 00 
  800734:	ff d3                	callq  *%rbx
  800736:	e9 0b fe ff ff       	jmpq   800546 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80073b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80073e:	83 f8 2f             	cmp    $0x2f,%eax
  800741:	77 4b                	ja     80078e <vprintfmt+0x272>
  800743:	89 c2                	mov    %eax,%edx
  800745:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800749:	83 c0 08             	add    $0x8,%eax
  80074c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80074f:	48 8b 02             	mov    (%rdx),%rax
  800752:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800756:	48 85 c0             	test   %rax,%rax
  800759:	0f 84 05 04 00 00    	je     800b64 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80075f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800763:	7e 06                	jle    80076b <vprintfmt+0x24f>
  800765:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800769:	75 31                	jne    80079c <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80076f:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800773:	0f b6 00             	movzbl (%rax),%eax
  800776:	0f be f8             	movsbl %al,%edi
  800779:	85 ff                	test   %edi,%edi
  80077b:	0f 84 c3 00 00 00    	je     800844 <vprintfmt+0x328>
  800781:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800785:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800789:	e9 85 00 00 00       	jmpq   800813 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80078e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800792:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800796:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80079a:	eb b3                	jmp    80074f <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80079c:	49 63 f4             	movslq %r12d,%rsi
  80079f:	48 89 c7             	mov    %rax,%rdi
  8007a2:	48 b8 f3 0c 80 00 00 	movabs $0x800cf3,%rax
  8007a9:	00 00 00 
  8007ac:	ff d0                	callq  *%rax
  8007ae:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007b1:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007b4:	85 f6                	test   %esi,%esi
  8007b6:	7e 22                	jle    8007da <vprintfmt+0x2be>
            putch(padc, putdat);
  8007b8:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007bc:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007c0:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007c4:	4c 89 fe             	mov    %r15,%rsi
  8007c7:	89 df                	mov    %ebx,%edi
  8007c9:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007cc:	41 83 ec 01          	sub    $0x1,%r12d
  8007d0:	75 f2                	jne    8007c4 <vprintfmt+0x2a8>
  8007d2:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007d6:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007da:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007de:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007e2:	0f b6 00             	movzbl (%rax),%eax
  8007e5:	0f be f8             	movsbl %al,%edi
  8007e8:	85 ff                	test   %edi,%edi
  8007ea:	0f 84 56 fd ff ff    	je     800546 <vprintfmt+0x2a>
  8007f0:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007f4:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007f8:	eb 19                	jmp    800813 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8007fa:	4c 89 fe             	mov    %r15,%rsi
  8007fd:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800800:	41 83 ee 01          	sub    $0x1,%r14d
  800804:	48 83 c3 01          	add    $0x1,%rbx
  800808:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80080c:	0f be f8             	movsbl %al,%edi
  80080f:	85 ff                	test   %edi,%edi
  800811:	74 29                	je     80083c <vprintfmt+0x320>
  800813:	45 85 e4             	test   %r12d,%r12d
  800816:	78 06                	js     80081e <vprintfmt+0x302>
  800818:	41 83 ec 01          	sub    $0x1,%r12d
  80081c:	78 48                	js     800866 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80081e:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800822:	74 d6                	je     8007fa <vprintfmt+0x2de>
  800824:	0f be c0             	movsbl %al,%eax
  800827:	83 e8 20             	sub    $0x20,%eax
  80082a:	83 f8 5e             	cmp    $0x5e,%eax
  80082d:	76 cb                	jbe    8007fa <vprintfmt+0x2de>
            putch('?', putdat);
  80082f:	4c 89 fe             	mov    %r15,%rsi
  800832:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800837:	41 ff d5             	callq  *%r13
  80083a:	eb c4                	jmp    800800 <vprintfmt+0x2e4>
  80083c:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800840:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800844:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800847:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80084b:	0f 8e f5 fc ff ff    	jle    800546 <vprintfmt+0x2a>
          putch(' ', putdat);
  800851:	4c 89 fe             	mov    %r15,%rsi
  800854:	bf 20 00 00 00       	mov    $0x20,%edi
  800859:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80085c:	83 eb 01             	sub    $0x1,%ebx
  80085f:	75 f0                	jne    800851 <vprintfmt+0x335>
  800861:	e9 e0 fc ff ff       	jmpq   800546 <vprintfmt+0x2a>
  800866:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80086a:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80086e:	eb d4                	jmp    800844 <vprintfmt+0x328>
  if (lflag >= 2)
  800870:	83 f9 01             	cmp    $0x1,%ecx
  800873:	7f 1d                	jg     800892 <vprintfmt+0x376>
  else if (lflag)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 5e                	je     8008d7 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800879:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80087c:	83 f8 2f             	cmp    $0x2f,%eax
  80087f:	77 48                	ja     8008c9 <vprintfmt+0x3ad>
  800881:	89 c2                	mov    %eax,%edx
  800883:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800887:	83 c0 08             	add    $0x8,%eax
  80088a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80088d:	48 8b 1a             	mov    (%rdx),%rbx
  800890:	eb 17                	jmp    8008a9 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800892:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800895:	83 f8 2f             	cmp    $0x2f,%eax
  800898:	77 21                	ja     8008bb <vprintfmt+0x39f>
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a0:	83 c0 08             	add    $0x8,%eax
  8008a3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a6:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008a9:	48 85 db             	test   %rbx,%rbx
  8008ac:	78 50                	js     8008fe <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008ae:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008b6:	e9 b4 01 00 00       	jmpq   800a6f <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008bb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008bf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008c7:	eb dd                	jmp    8008a6 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008c9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008cd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d5:	eb b6                	jmp    80088d <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008d7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008da:	83 f8 2f             	cmp    $0x2f,%eax
  8008dd:	77 11                	ja     8008f0 <vprintfmt+0x3d4>
  8008df:	89 c2                	mov    %eax,%edx
  8008e1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e5:	83 c0 08             	add    $0x8,%eax
  8008e8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008eb:	48 63 1a             	movslq (%rdx),%rbx
  8008ee:	eb b9                	jmp    8008a9 <vprintfmt+0x38d>
  8008f0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008f4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008f8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008fc:	eb ed                	jmp    8008eb <vprintfmt+0x3cf>
          putch('-', putdat);
  8008fe:	4c 89 fe             	mov    %r15,%rsi
  800901:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800906:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800909:	48 89 da             	mov    %rbx,%rdx
  80090c:	48 f7 da             	neg    %rdx
        base = 10;
  80090f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800914:	e9 56 01 00 00       	jmpq   800a6f <vprintfmt+0x553>
  if (lflag >= 2)
  800919:	83 f9 01             	cmp    $0x1,%ecx
  80091c:	7f 25                	jg     800943 <vprintfmt+0x427>
  else if (lflag)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 5e                	je     800980 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800922:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800925:	83 f8 2f             	cmp    $0x2f,%eax
  800928:	77 48                	ja     800972 <vprintfmt+0x456>
  80092a:	89 c2                	mov    %eax,%edx
  80092c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800930:	83 c0 08             	add    $0x8,%eax
  800933:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800936:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800939:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80093e:	e9 2c 01 00 00       	jmpq   800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800943:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800946:	83 f8 2f             	cmp    $0x2f,%eax
  800949:	77 19                	ja     800964 <vprintfmt+0x448>
  80094b:	89 c2                	mov    %eax,%edx
  80094d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800951:	83 c0 08             	add    $0x8,%eax
  800954:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800957:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80095a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80095f:	e9 0b 01 00 00       	jmpq   800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800964:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800968:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800970:	eb e5                	jmp    800957 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800972:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800976:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097e:	eb b6                	jmp    800936 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800980:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800983:	83 f8 2f             	cmp    $0x2f,%eax
  800986:	77 18                	ja     8009a0 <vprintfmt+0x484>
  800988:	89 c2                	mov    %eax,%edx
  80098a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80098e:	83 c0 08             	add    $0x8,%eax
  800991:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800994:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800996:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80099b:	e9 cf 00 00 00       	jmpq   800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009a0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ac:	eb e6                	jmp    800994 <vprintfmt+0x478>
  if (lflag >= 2)
  8009ae:	83 f9 01             	cmp    $0x1,%ecx
  8009b1:	7f 25                	jg     8009d8 <vprintfmt+0x4bc>
  else if (lflag)
  8009b3:	85 c9                	test   %ecx,%ecx
  8009b5:	74 5b                	je     800a12 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009b7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ba:	83 f8 2f             	cmp    $0x2f,%eax
  8009bd:	77 45                	ja     800a04 <vprintfmt+0x4e8>
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009c5:	83 c0 08             	add    $0x8,%eax
  8009c8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009cb:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009ce:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009d3:	e9 97 00 00 00       	jmpq   800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009d8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009db:	83 f8 2f             	cmp    $0x2f,%eax
  8009de:	77 16                	ja     8009f6 <vprintfmt+0x4da>
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e6:	83 c0 08             	add    $0x8,%eax
  8009e9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ec:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009ef:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f4:	eb 79                	jmp    800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009fa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009fe:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a02:	eb e8                	jmp    8009ec <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a04:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a08:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a10:	eb b9                	jmp    8009cb <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a12:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a15:	83 f8 2f             	cmp    $0x2f,%eax
  800a18:	77 15                	ja     800a2f <vprintfmt+0x513>
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a20:	83 c0 08             	add    $0x8,%eax
  800a23:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a26:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a28:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a2d:	eb 40                	jmp    800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a2f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a33:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a37:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a3b:	eb e9                	jmp    800a26 <vprintfmt+0x50a>
        putch('0', putdat);
  800a3d:	4c 89 fe             	mov    %r15,%rsi
  800a40:	bf 30 00 00 00       	mov    $0x30,%edi
  800a45:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a48:	4c 89 fe             	mov    %r15,%rsi
  800a4b:	bf 78 00 00 00       	mov    $0x78,%edi
  800a50:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a53:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a56:	83 f8 2f             	cmp    $0x2f,%eax
  800a59:	77 34                	ja     800a8f <vprintfmt+0x573>
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a61:	83 c0 08             	add    $0x8,%eax
  800a64:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a67:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a6a:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a6f:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a74:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a78:	4c 89 fe             	mov    %r15,%rsi
  800a7b:	4c 89 ef             	mov    %r13,%rdi
  800a7e:	48 b8 f2 03 80 00 00 	movabs $0x8003f2,%rax
  800a85:	00 00 00 
  800a88:	ff d0                	callq  *%rax
        break;
  800a8a:	e9 b7 fa ff ff       	jmpq   800546 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a8f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a93:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a97:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a9b:	eb ca                	jmp    800a67 <vprintfmt+0x54b>
  if (lflag >= 2)
  800a9d:	83 f9 01             	cmp    $0x1,%ecx
  800aa0:	7f 22                	jg     800ac4 <vprintfmt+0x5a8>
  else if (lflag)
  800aa2:	85 c9                	test   %ecx,%ecx
  800aa4:	74 58                	je     800afe <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800aa6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aa9:	83 f8 2f             	cmp    $0x2f,%eax
  800aac:	77 42                	ja     800af0 <vprintfmt+0x5d4>
  800aae:	89 c2                	mov    %eax,%edx
  800ab0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ab4:	83 c0 08             	add    $0x8,%eax
  800ab7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aba:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800abd:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ac2:	eb ab                	jmp    800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ac4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ac7:	83 f8 2f             	cmp    $0x2f,%eax
  800aca:	77 16                	ja     800ae2 <vprintfmt+0x5c6>
  800acc:	89 c2                	mov    %eax,%edx
  800ace:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad2:	83 c0 08             	add    $0x8,%eax
  800ad5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ad8:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800adb:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae0:	eb 8d                	jmp    800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ae2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ae6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aea:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aee:	eb e8                	jmp    800ad8 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800af0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800af4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800afc:	eb bc                	jmp    800aba <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800afe:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b01:	83 f8 2f             	cmp    $0x2f,%eax
  800b04:	77 18                	ja     800b1e <vprintfmt+0x602>
  800b06:	89 c2                	mov    %eax,%edx
  800b08:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b0c:	83 c0 08             	add    $0x8,%eax
  800b0f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b12:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b14:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b19:	e9 51 ff ff ff       	jmpq   800a6f <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b1e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b22:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b26:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b2a:	eb e6                	jmp    800b12 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b2c:	4c 89 fe             	mov    %r15,%rsi
  800b2f:	bf 25 00 00 00       	mov    $0x25,%edi
  800b34:	41 ff d5             	callq  *%r13
        break;
  800b37:	e9 0a fa ff ff       	jmpq   800546 <vprintfmt+0x2a>
        putch('%', putdat);
  800b3c:	4c 89 fe             	mov    %r15,%rsi
  800b3f:	bf 25 00 00 00       	mov    $0x25,%edi
  800b44:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b47:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b4b:	0f 84 15 fa ff ff    	je     800566 <vprintfmt+0x4a>
  800b51:	49 89 de             	mov    %rbx,%r14
  800b54:	49 83 ee 01          	sub    $0x1,%r14
  800b58:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b5d:	75 f5                	jne    800b54 <vprintfmt+0x638>
  800b5f:	e9 e2 f9 ff ff       	jmpq   800546 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b64:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b68:	74 06                	je     800b70 <vprintfmt+0x654>
  800b6a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b6e:	7f 21                	jg     800b91 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b70:	bf 28 00 00 00       	mov    $0x28,%edi
  800b75:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800b7c:	00 00 00 
  800b7f:	b8 28 00 00 00       	mov    $0x28,%eax
  800b84:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b88:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b8c:	e9 82 fc ff ff       	jmpq   800813 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b91:	49 63 f4             	movslq %r12d,%rsi
  800b94:	48 bf db 11 80 00 00 	movabs $0x8011db,%rdi
  800b9b:	00 00 00 
  800b9e:	48 b8 f3 0c 80 00 00 	movabs $0x800cf3,%rax
  800ba5:	00 00 00 
  800ba8:	ff d0                	callq  *%rax
  800baa:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bad:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bb0:	48 be db 11 80 00 00 	movabs $0x8011db,%rsi
  800bb7:	00 00 00 
  800bba:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	0f 8f f2 fb ff ff    	jg     8007b8 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc6:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800bcd:	00 00 00 
  800bd0:	b8 28 00 00 00       	mov    $0x28,%eax
  800bd5:	bf 28 00 00 00       	mov    $0x28,%edi
  800bda:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bde:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800be2:	e9 2c fc ff ff       	jmpq   800813 <vprintfmt+0x2f7>
}
  800be7:	48 83 c4 48          	add    $0x48,%rsp
  800beb:	5b                   	pop    %rbx
  800bec:	41 5c                	pop    %r12
  800bee:	41 5d                	pop    %r13
  800bf0:	41 5e                	pop    %r14
  800bf2:	41 5f                	pop    %r15
  800bf4:	5d                   	pop    %rbp
  800bf5:	c3                   	retq   

0000000000800bf6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800bf6:	55                   	push   %rbp
  800bf7:	48 89 e5             	mov    %rsp,%rbp
  800bfa:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800bfe:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c02:	48 63 c6             	movslq %esi,%rax
  800c05:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c0a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c0e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c15:	48 85 ff             	test   %rdi,%rdi
  800c18:	74 2a                	je     800c44 <vsnprintf+0x4e>
  800c1a:	85 f6                	test   %esi,%esi
  800c1c:	7e 26                	jle    800c44 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c1e:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c22:	48 bf 7e 04 80 00 00 	movabs $0x80047e,%rdi
  800c29:	00 00 00 
  800c2c:	48 b8 1c 05 80 00 00 	movabs $0x80051c,%rax
  800c33:	00 00 00 
  800c36:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c38:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c3c:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c3f:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c42:	c9                   	leaveq 
  800c43:	c3                   	retq   
    return -E_INVAL;
  800c44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c49:	eb f7                	jmp    800c42 <vsnprintf+0x4c>

0000000000800c4b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c4b:	55                   	push   %rbp
  800c4c:	48 89 e5             	mov    %rsp,%rbp
  800c4f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c56:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c5d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c64:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c6b:	84 c0                	test   %al,%al
  800c6d:	74 20                	je     800c8f <snprintf+0x44>
  800c6f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c73:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c77:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c7b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c7f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c83:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c87:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c8b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c8f:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800c96:	00 00 00 
  800c99:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800ca0:	00 00 00 
  800ca3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800ca7:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cae:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cb5:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cbc:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cc3:	48 b8 f6 0b 80 00 00 	movabs $0x800bf6,%rax
  800cca:	00 00 00 
  800ccd:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800ccf:	c9                   	leaveq 
  800cd0:	c3                   	retq   

0000000000800cd1 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cd1:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cd4:	74 17                	je     800ced <strlen+0x1c>
  800cd6:	48 89 fa             	mov    %rdi,%rdx
  800cd9:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cde:	29 f9                	sub    %edi,%ecx
    n++;
  800ce0:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800ce3:	48 83 c2 01          	add    $0x1,%rdx
  800ce7:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cea:	75 f4                	jne    800ce0 <strlen+0xf>
  800cec:	c3                   	retq   
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800cf2:	c3                   	retq   

0000000000800cf3 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf3:	48 85 f6             	test   %rsi,%rsi
  800cf6:	74 24                	je     800d1c <strnlen+0x29>
  800cf8:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cfb:	74 25                	je     800d22 <strnlen+0x2f>
  800cfd:	48 01 fe             	add    %rdi,%rsi
  800d00:	48 89 fa             	mov    %rdi,%rdx
  800d03:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d08:	29 f9                	sub    %edi,%ecx
    n++;
  800d0a:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0d:	48 83 c2 01          	add    $0x1,%rdx
  800d11:	48 39 f2             	cmp    %rsi,%rdx
  800d14:	74 11                	je     800d27 <strnlen+0x34>
  800d16:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d19:	75 ef                	jne    800d0a <strnlen+0x17>
  800d1b:	c3                   	retq   
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d21:	c3                   	retq   
  800d22:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d27:	c3                   	retq   

0000000000800d28 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d28:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d34:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d37:	48 83 c2 01          	add    $0x1,%rdx
  800d3b:	84 c9                	test   %cl,%cl
  800d3d:	75 f1                	jne    800d30 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d3f:	c3                   	retq   

0000000000800d40 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d40:	55                   	push   %rbp
  800d41:	48 89 e5             	mov    %rsp,%rbp
  800d44:	41 54                	push   %r12
  800d46:	53                   	push   %rbx
  800d47:	48 89 fb             	mov    %rdi,%rbx
  800d4a:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d4d:	48 b8 d1 0c 80 00 00 	movabs $0x800cd1,%rax
  800d54:	00 00 00 
  800d57:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d59:	48 63 f8             	movslq %eax,%rdi
  800d5c:	48 01 df             	add    %rbx,%rdi
  800d5f:	4c 89 e6             	mov    %r12,%rsi
  800d62:	48 b8 28 0d 80 00 00 	movabs $0x800d28,%rax
  800d69:	00 00 00 
  800d6c:	ff d0                	callq  *%rax
  return dst;
}
  800d6e:	48 89 d8             	mov    %rbx,%rax
  800d71:	5b                   	pop    %rbx
  800d72:	41 5c                	pop    %r12
  800d74:	5d                   	pop    %rbp
  800d75:	c3                   	retq   

0000000000800d76 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d76:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d79:	48 85 d2             	test   %rdx,%rdx
  800d7c:	74 1f                	je     800d9d <strncpy+0x27>
  800d7e:	48 01 fa             	add    %rdi,%rdx
  800d81:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d84:	48 83 c1 01          	add    $0x1,%rcx
  800d88:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d8c:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d90:	41 80 f8 01          	cmp    $0x1,%r8b
  800d94:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800d98:	48 39 ca             	cmp    %rcx,%rdx
  800d9b:	75 e7                	jne    800d84 <strncpy+0xe>
  }
  return ret;
}
  800d9d:	c3                   	retq   

0000000000800d9e <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800d9e:	48 89 f8             	mov    %rdi,%rax
  800da1:	48 85 d2             	test   %rdx,%rdx
  800da4:	74 36                	je     800ddc <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800da6:	48 83 fa 01          	cmp    $0x1,%rdx
  800daa:	74 2d                	je     800dd9 <strlcpy+0x3b>
  800dac:	44 0f b6 06          	movzbl (%rsi),%r8d
  800db0:	45 84 c0             	test   %r8b,%r8b
  800db3:	74 24                	je     800dd9 <strlcpy+0x3b>
  800db5:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800db9:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dbe:	48 83 c0 01          	add    $0x1,%rax
  800dc2:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800dc6:	48 39 d1             	cmp    %rdx,%rcx
  800dc9:	74 0e                	je     800dd9 <strlcpy+0x3b>
  800dcb:	48 83 c1 01          	add    $0x1,%rcx
  800dcf:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800dd4:	45 84 c0             	test   %r8b,%r8b
  800dd7:	75 e5                	jne    800dbe <strlcpy+0x20>
    *dst = '\0';
  800dd9:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800ddc:	48 29 f8             	sub    %rdi,%rax
}
  800ddf:	c3                   	retq   

0000000000800de0 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800de0:	0f b6 07             	movzbl (%rdi),%eax
  800de3:	84 c0                	test   %al,%al
  800de5:	74 17                	je     800dfe <strcmp+0x1e>
  800de7:	3a 06                	cmp    (%rsi),%al
  800de9:	75 13                	jne    800dfe <strcmp+0x1e>
    p++, q++;
  800deb:	48 83 c7 01          	add    $0x1,%rdi
  800def:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800df3:	0f b6 07             	movzbl (%rdi),%eax
  800df6:	84 c0                	test   %al,%al
  800df8:	74 04                	je     800dfe <strcmp+0x1e>
  800dfa:	3a 06                	cmp    (%rsi),%al
  800dfc:	74 ed                	je     800deb <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800dfe:	0f b6 c0             	movzbl %al,%eax
  800e01:	0f b6 16             	movzbl (%rsi),%edx
  800e04:	29 d0                	sub    %edx,%eax
}
  800e06:	c3                   	retq   

0000000000800e07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e07:	48 85 d2             	test   %rdx,%rdx
  800e0a:	74 2f                	je     800e3b <strncmp+0x34>
  800e0c:	0f b6 07             	movzbl (%rdi),%eax
  800e0f:	84 c0                	test   %al,%al
  800e11:	74 1f                	je     800e32 <strncmp+0x2b>
  800e13:	3a 06                	cmp    (%rsi),%al
  800e15:	75 1b                	jne    800e32 <strncmp+0x2b>
  800e17:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e1a:	48 83 c7 01          	add    $0x1,%rdi
  800e1e:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e22:	48 39 d7             	cmp    %rdx,%rdi
  800e25:	74 1a                	je     800e41 <strncmp+0x3a>
  800e27:	0f b6 07             	movzbl (%rdi),%eax
  800e2a:	84 c0                	test   %al,%al
  800e2c:	74 04                	je     800e32 <strncmp+0x2b>
  800e2e:	3a 06                	cmp    (%rsi),%al
  800e30:	74 e8                	je     800e1a <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e32:	0f b6 07             	movzbl (%rdi),%eax
  800e35:	0f b6 16             	movzbl (%rsi),%edx
  800e38:	29 d0                	sub    %edx,%eax
}
  800e3a:	c3                   	retq   
    return 0;
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e40:	c3                   	retq   
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	c3                   	retq   

0000000000800e47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e47:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e49:	0f b6 07             	movzbl (%rdi),%eax
  800e4c:	84 c0                	test   %al,%al
  800e4e:	74 1e                	je     800e6e <strchr+0x27>
    if (*s == c)
  800e50:	40 38 c6             	cmp    %al,%sil
  800e53:	74 1f                	je     800e74 <strchr+0x2d>
  for (; *s; s++)
  800e55:	48 83 c7 01          	add    $0x1,%rdi
  800e59:	0f b6 07             	movzbl (%rdi),%eax
  800e5c:	84 c0                	test   %al,%al
  800e5e:	74 08                	je     800e68 <strchr+0x21>
    if (*s == c)
  800e60:	38 d0                	cmp    %dl,%al
  800e62:	75 f1                	jne    800e55 <strchr+0xe>
  for (; *s; s++)
  800e64:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e67:	c3                   	retq   
  return 0;
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6d:	c3                   	retq   
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	c3                   	retq   
    if (*s == c)
  800e74:	48 89 f8             	mov    %rdi,%rax
  800e77:	c3                   	retq   

0000000000800e78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e78:	48 89 f8             	mov    %rdi,%rax
  800e7b:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e7d:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e80:	40 38 f2             	cmp    %sil,%dl
  800e83:	74 13                	je     800e98 <strfind+0x20>
  800e85:	84 d2                	test   %dl,%dl
  800e87:	74 0f                	je     800e98 <strfind+0x20>
  for (; *s; s++)
  800e89:	48 83 c0 01          	add    $0x1,%rax
  800e8d:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e90:	38 ca                	cmp    %cl,%dl
  800e92:	74 04                	je     800e98 <strfind+0x20>
  800e94:	84 d2                	test   %dl,%dl
  800e96:	75 f1                	jne    800e89 <strfind+0x11>
      break;
  return (char *)s;
}
  800e98:	c3                   	retq   

0000000000800e99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800e99:	48 85 d2             	test   %rdx,%rdx
  800e9c:	74 3a                	je     800ed8 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800e9e:	48 89 f8             	mov    %rdi,%rax
  800ea1:	48 09 d0             	or     %rdx,%rax
  800ea4:	a8 03                	test   $0x3,%al
  800ea6:	75 28                	jne    800ed0 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ea8:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800eac:	89 f0                	mov    %esi,%eax
  800eae:	c1 e0 08             	shl    $0x8,%eax
  800eb1:	89 f1                	mov    %esi,%ecx
  800eb3:	c1 e1 18             	shl    $0x18,%ecx
  800eb6:	41 89 f0             	mov    %esi,%r8d
  800eb9:	41 c1 e0 10          	shl    $0x10,%r8d
  800ebd:	44 09 c1             	or     %r8d,%ecx
  800ec0:	09 ce                	or     %ecx,%esi
  800ec2:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ec4:	48 c1 ea 02          	shr    $0x2,%rdx
  800ec8:	48 89 d1             	mov    %rdx,%rcx
  800ecb:	fc                   	cld    
  800ecc:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ece:	eb 08                	jmp    800ed8 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ed0:	89 f0                	mov    %esi,%eax
  800ed2:	48 89 d1             	mov    %rdx,%rcx
  800ed5:	fc                   	cld    
  800ed6:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ed8:	48 89 f8             	mov    %rdi,%rax
  800edb:	c3                   	retq   

0000000000800edc <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800edc:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800edf:	48 39 fe             	cmp    %rdi,%rsi
  800ee2:	73 40                	jae    800f24 <memmove+0x48>
  800ee4:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ee8:	48 39 f9             	cmp    %rdi,%rcx
  800eeb:	76 37                	jbe    800f24 <memmove+0x48>
    s += n;
    d += n;
  800eed:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800ef1:	48 89 fe             	mov    %rdi,%rsi
  800ef4:	48 09 d6             	or     %rdx,%rsi
  800ef7:	48 09 ce             	or     %rcx,%rsi
  800efa:	40 f6 c6 03          	test   $0x3,%sil
  800efe:	75 14                	jne    800f14 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f00:	48 83 ef 04          	sub    $0x4,%rdi
  800f04:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f08:	48 c1 ea 02          	shr    $0x2,%rdx
  800f0c:	48 89 d1             	mov    %rdx,%rcx
  800f0f:	fd                   	std    
  800f10:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f12:	eb 0e                	jmp    800f22 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f14:	48 83 ef 01          	sub    $0x1,%rdi
  800f18:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f1c:	48 89 d1             	mov    %rdx,%rcx
  800f1f:	fd                   	std    
  800f20:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f22:	fc                   	cld    
  800f23:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f24:	48 89 c1             	mov    %rax,%rcx
  800f27:	48 09 d1             	or     %rdx,%rcx
  800f2a:	48 09 f1             	or     %rsi,%rcx
  800f2d:	f6 c1 03             	test   $0x3,%cl
  800f30:	75 0e                	jne    800f40 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f32:	48 c1 ea 02          	shr    $0x2,%rdx
  800f36:	48 89 d1             	mov    %rdx,%rcx
  800f39:	48 89 c7             	mov    %rax,%rdi
  800f3c:	fc                   	cld    
  800f3d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f3f:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f40:	48 89 c7             	mov    %rax,%rdi
  800f43:	48 89 d1             	mov    %rdx,%rcx
  800f46:	fc                   	cld    
  800f47:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f49:	c3                   	retq   

0000000000800f4a <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f4a:	55                   	push   %rbp
  800f4b:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f4e:	48 b8 dc 0e 80 00 00 	movabs $0x800edc,%rax
  800f55:	00 00 00 
  800f58:	ff d0                	callq  *%rax
}
  800f5a:	5d                   	pop    %rbp
  800f5b:	c3                   	retq   

0000000000800f5c <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f5c:	55                   	push   %rbp
  800f5d:	48 89 e5             	mov    %rsp,%rbp
  800f60:	41 57                	push   %r15
  800f62:	41 56                	push   %r14
  800f64:	41 55                	push   %r13
  800f66:	41 54                	push   %r12
  800f68:	53                   	push   %rbx
  800f69:	48 83 ec 08          	sub    $0x8,%rsp
  800f6d:	49 89 fe             	mov    %rdi,%r14
  800f70:	49 89 f7             	mov    %rsi,%r15
  800f73:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f76:	48 89 f7             	mov    %rsi,%rdi
  800f79:	48 b8 d1 0c 80 00 00 	movabs $0x800cd1,%rax
  800f80:	00 00 00 
  800f83:	ff d0                	callq  *%rax
  800f85:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f88:	4c 89 ee             	mov    %r13,%rsi
  800f8b:	4c 89 f7             	mov    %r14,%rdi
  800f8e:	48 b8 f3 0c 80 00 00 	movabs $0x800cf3,%rax
  800f95:	00 00 00 
  800f98:	ff d0                	callq  *%rax
  800f9a:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800f9d:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fa1:	4d 39 e5             	cmp    %r12,%r13
  800fa4:	74 26                	je     800fcc <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fa6:	4c 89 e8             	mov    %r13,%rax
  800fa9:	4c 29 e0             	sub    %r12,%rax
  800fac:	48 39 d8             	cmp    %rbx,%rax
  800faf:	76 2a                	jbe    800fdb <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fb1:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fb5:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fb9:	4c 89 fe             	mov    %r15,%rsi
  800fbc:	48 b8 4a 0f 80 00 00 	movabs $0x800f4a,%rax
  800fc3:	00 00 00 
  800fc6:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fc8:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fcc:	48 83 c4 08          	add    $0x8,%rsp
  800fd0:	5b                   	pop    %rbx
  800fd1:	41 5c                	pop    %r12
  800fd3:	41 5d                	pop    %r13
  800fd5:	41 5e                	pop    %r14
  800fd7:	41 5f                	pop    %r15
  800fd9:	5d                   	pop    %rbp
  800fda:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fdb:	49 83 ed 01          	sub    $0x1,%r13
  800fdf:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fe3:	4c 89 ea             	mov    %r13,%rdx
  800fe6:	4c 89 fe             	mov    %r15,%rsi
  800fe9:	48 b8 4a 0f 80 00 00 	movabs $0x800f4a,%rax
  800ff0:	00 00 00 
  800ff3:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800ff5:	4d 01 ee             	add    %r13,%r14
  800ff8:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800ffd:	eb c9                	jmp    800fc8 <strlcat+0x6c>

0000000000800fff <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800fff:	48 85 d2             	test   %rdx,%rdx
  801002:	74 3a                	je     80103e <memcmp+0x3f>
    if (*s1 != *s2)
  801004:	0f b6 0f             	movzbl (%rdi),%ecx
  801007:	44 0f b6 06          	movzbl (%rsi),%r8d
  80100b:	44 38 c1             	cmp    %r8b,%cl
  80100e:	75 1d                	jne    80102d <memcmp+0x2e>
  801010:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801015:	48 39 d0             	cmp    %rdx,%rax
  801018:	74 1e                	je     801038 <memcmp+0x39>
    if (*s1 != *s2)
  80101a:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80101e:	48 83 c0 01          	add    $0x1,%rax
  801022:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801028:	44 38 c1             	cmp    %r8b,%cl
  80102b:	74 e8                	je     801015 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80102d:	0f b6 c1             	movzbl %cl,%eax
  801030:	45 0f b6 c0          	movzbl %r8b,%r8d
  801034:	44 29 c0             	sub    %r8d,%eax
  801037:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	c3                   	retq   
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801043:	c3                   	retq   

0000000000801044 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801044:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801048:	48 39 c7             	cmp    %rax,%rdi
  80104b:	73 19                	jae    801066 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80104d:	89 f2                	mov    %esi,%edx
  80104f:	40 38 37             	cmp    %sil,(%rdi)
  801052:	74 16                	je     80106a <memfind+0x26>
  for (; s < ends; s++)
  801054:	48 83 c7 01          	add    $0x1,%rdi
  801058:	48 39 f8             	cmp    %rdi,%rax
  80105b:	74 08                	je     801065 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80105d:	38 17                	cmp    %dl,(%rdi)
  80105f:	75 f3                	jne    801054 <memfind+0x10>
  for (; s < ends; s++)
  801061:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801064:	c3                   	retq   
  801065:	c3                   	retq   
  for (; s < ends; s++)
  801066:	48 89 f8             	mov    %rdi,%rax
  801069:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80106a:	48 89 f8             	mov    %rdi,%rax
  80106d:	c3                   	retq   

000000000080106e <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80106e:	0f b6 07             	movzbl (%rdi),%eax
  801071:	3c 20                	cmp    $0x20,%al
  801073:	74 04                	je     801079 <strtol+0xb>
  801075:	3c 09                	cmp    $0x9,%al
  801077:	75 0f                	jne    801088 <strtol+0x1a>
    s++;
  801079:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80107d:	0f b6 07             	movzbl (%rdi),%eax
  801080:	3c 20                	cmp    $0x20,%al
  801082:	74 f5                	je     801079 <strtol+0xb>
  801084:	3c 09                	cmp    $0x9,%al
  801086:	74 f1                	je     801079 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801088:	3c 2b                	cmp    $0x2b,%al
  80108a:	74 2b                	je     8010b7 <strtol+0x49>
  int neg  = 0;
  80108c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801092:	3c 2d                	cmp    $0x2d,%al
  801094:	74 2d                	je     8010c3 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801096:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80109c:	75 0f                	jne    8010ad <strtol+0x3f>
  80109e:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010a1:	74 2c                	je     8010cf <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010a3:	85 d2                	test   %edx,%edx
  8010a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010aa:	0f 44 d0             	cmove  %eax,%edx
  8010ad:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010b2:	4c 63 d2             	movslq %edx,%r10
  8010b5:	eb 5c                	jmp    801113 <strtol+0xa5>
    s++;
  8010b7:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010bb:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010c1:	eb d3                	jmp    801096 <strtol+0x28>
    s++, neg = 1;
  8010c3:	48 83 c7 01          	add    $0x1,%rdi
  8010c7:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010cd:	eb c7                	jmp    801096 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010cf:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010d3:	74 0f                	je     8010e4 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010d5:	85 d2                	test   %edx,%edx
  8010d7:	75 d4                	jne    8010ad <strtol+0x3f>
    s++, base = 8;
  8010d9:	48 83 c7 01          	add    $0x1,%rdi
  8010dd:	ba 08 00 00 00       	mov    $0x8,%edx
  8010e2:	eb c9                	jmp    8010ad <strtol+0x3f>
    s += 2, base = 16;
  8010e4:	48 83 c7 02          	add    $0x2,%rdi
  8010e8:	ba 10 00 00 00       	mov    $0x10,%edx
  8010ed:	eb be                	jmp    8010ad <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010ef:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8010f3:	41 80 f8 19          	cmp    $0x19,%r8b
  8010f7:	77 2f                	ja     801128 <strtol+0xba>
      dig = *s - 'a' + 10;
  8010f9:	44 0f be c1          	movsbl %cl,%r8d
  8010fd:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801101:	39 d1                	cmp    %edx,%ecx
  801103:	7d 37                	jge    80113c <strtol+0xce>
    s++, val = (val * base) + dig;
  801105:	48 83 c7 01          	add    $0x1,%rdi
  801109:	49 0f af c2          	imul   %r10,%rax
  80110d:	48 63 c9             	movslq %ecx,%rcx
  801110:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801113:	0f b6 0f             	movzbl (%rdi),%ecx
  801116:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80111a:	41 80 f8 09          	cmp    $0x9,%r8b
  80111e:	77 cf                	ja     8010ef <strtol+0x81>
      dig = *s - '0';
  801120:	0f be c9             	movsbl %cl,%ecx
  801123:	83 e9 30             	sub    $0x30,%ecx
  801126:	eb d9                	jmp    801101 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801128:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80112c:	41 80 f8 19          	cmp    $0x19,%r8b
  801130:	77 0a                	ja     80113c <strtol+0xce>
      dig = *s - 'A' + 10;
  801132:	44 0f be c1          	movsbl %cl,%r8d
  801136:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80113a:	eb c5                	jmp    801101 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80113c:	48 85 f6             	test   %rsi,%rsi
  80113f:	74 03                	je     801144 <strtol+0xd6>
    *endptr = (char *)s;
  801141:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801144:	48 89 c2             	mov    %rax,%rdx
  801147:	48 f7 da             	neg    %rdx
  80114a:	45 85 c9             	test   %r9d,%r9d
  80114d:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801151:	c3                   	retq   
  801152:	66 90                	xchg   %ax,%ax
