
obj/user/faultwritekernel:     file format elf64-x86-64


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
  800023:	e8 13 00 00 00       	callq  80003b <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  *(volatile unsigned *)0x8040000000 = 0;
  80002a:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  800031:	00 00 00 
  800034:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
}
  80003a:	c3                   	retq   

000000000080003b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80003b:	55                   	push   %rbp
  80003c:	48 89 e5             	mov    %rsp,%rbp
  80003f:	41 56                	push   %r14
  800041:	41 55                	push   %r13
  800043:	41 54                	push   %r12
  800045:	53                   	push   %rbx
  800046:	41 89 fd             	mov    %edi,%r13d
  800049:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80004c:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800053:	00 00 00 
  800056:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80005d:	00 00 00 
  800060:	48 39 c2             	cmp    %rax,%rdx
  800063:	73 23                	jae    800088 <libmain+0x4d>
  800065:	48 89 d3             	mov    %rdx,%rbx
  800068:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80006c:	48 29 d0             	sub    %rdx,%rax
  80006f:	48 c1 e8 03          	shr    $0x3,%rax
  800073:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800078:	b8 00 00 00 00       	mov    $0x0,%eax
  80007d:	ff 13                	callq  *(%rbx)
    ctor++;
  80007f:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800083:	4c 39 e3             	cmp    %r12,%rbx
  800086:	75 f0                	jne    800078 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  800088:	48 b8 aa 01 80 00 00 	movabs $0x8001aa,%rax
  80008f:	00 00 00 
  800092:	ff d0                	callq  *%rax
  800094:	83 e0 1f             	and    $0x1f,%eax
  800097:	48 89 c2             	mov    %rax,%rdx
  80009a:	48 c1 e2 05          	shl    $0x5,%rdx
  80009e:	48 29 c2             	sub    %rax,%rdx
  8000a1:	48 89 d0             	mov    %rdx,%rax
  8000a4:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000ab:	00 00 00 
  8000ae:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000b2:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000b9:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000bc:	45 85 ed             	test   %r13d,%r13d
  8000bf:	7e 0d                	jle    8000ce <libmain+0x93>
    binaryname = argv[0];
  8000c1:	49 8b 06             	mov    (%r14),%rax
  8000c4:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000cb:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000ce:	4c 89 f6             	mov    %r14,%rsi
  8000d1:	44 89 ef             	mov    %r13d,%edi
  8000d4:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000db:	00 00 00 
  8000de:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000e0:	48 b8 f5 00 80 00 00 	movabs $0x8000f5,%rax
  8000e7:	00 00 00 
  8000ea:	ff d0                	callq  *%rax
#endif
}
  8000ec:	5b                   	pop    %rbx
  8000ed:	41 5c                	pop    %r12
  8000ef:	41 5d                	pop    %r13
  8000f1:	41 5e                	pop    %r14
  8000f3:	5d                   	pop    %rbp
  8000f4:	c3                   	retq   

00000000008000f5 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000f5:	55                   	push   %rbp
  8000f6:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8000fe:	48 b8 4a 01 80 00 00 	movabs $0x80014a,%rax
  800105:	00 00 00 
  800108:	ff d0                	callq  *%rax
}
  80010a:	5d                   	pop    %rbp
  80010b:	c3                   	retq   

000000000080010c <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80010c:	55                   	push   %rbp
  80010d:	48 89 e5             	mov    %rsp,%rbp
  800110:	53                   	push   %rbx
  800111:	48 89 fa             	mov    %rdi,%rdx
  800114:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800117:	b8 00 00 00 00       	mov    $0x0,%eax
  80011c:	48 89 c3             	mov    %rax,%rbx
  80011f:	48 89 c7             	mov    %rax,%rdi
  800122:	48 89 c6             	mov    %rax,%rsi
  800125:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800127:	5b                   	pop    %rbx
  800128:	5d                   	pop    %rbp
  800129:	c3                   	retq   

000000000080012a <sys_cgetc>:

int
sys_cgetc(void) {
  80012a:	55                   	push   %rbp
  80012b:	48 89 e5             	mov    %rsp,%rbp
  80012e:	53                   	push   %rbx
  asm volatile("int %1\n"
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800134:	b8 01 00 00 00       	mov    $0x1,%eax
  800139:	48 89 ca             	mov    %rcx,%rdx
  80013c:	48 89 cb             	mov    %rcx,%rbx
  80013f:	48 89 cf             	mov    %rcx,%rdi
  800142:	48 89 ce             	mov    %rcx,%rsi
  800145:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %rbx
  800148:	5d                   	pop    %rbp
  800149:	c3                   	retq   

000000000080014a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80014a:	55                   	push   %rbp
  80014b:	48 89 e5             	mov    %rsp,%rbp
  80014e:	53                   	push   %rbx
  80014f:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800153:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 03 00 00 00       	mov    $0x3,%eax
  800160:	48 89 f1             	mov    %rsi,%rcx
  800163:	48 89 f3             	mov    %rsi,%rbx
  800166:	48 89 f7             	mov    %rsi,%rdi
  800169:	cd 30                	int    $0x30
  if (check && ret > 0)
  80016b:	48 85 c0             	test   %rax,%rax
  80016e:	7f 07                	jg     800177 <sys_env_destroy+0x2d>
}
  800170:	48 83 c4 08          	add    $0x8,%rsp
  800174:	5b                   	pop    %rbx
  800175:	5d                   	pop    %rbp
  800176:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800177:	49 89 c0             	mov    %rax,%r8
  80017a:	b9 03 00 00 00       	mov    $0x3,%ecx
  80017f:	48 ba 70 11 80 00 00 	movabs $0x801170,%rdx
  800186:	00 00 00 
  800189:	be 22 00 00 00       	mov    $0x22,%esi
  80018e:	48 bf 8f 11 80 00 00 	movabs $0x80118f,%rdi
  800195:	00 00 00 
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
  80019d:	49 b9 ca 01 80 00 00 	movabs $0x8001ca,%r9
  8001a4:	00 00 00 
  8001a7:	41 ff d1             	callq  *%r9

00000000008001aa <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001aa:	55                   	push   %rbp
  8001ab:	48 89 e5             	mov    %rsp,%rbp
  8001ae:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b9:	48 89 ca             	mov    %rcx,%rdx
  8001bc:	48 89 cb             	mov    %rcx,%rbx
  8001bf:	48 89 cf             	mov    %rcx,%rdi
  8001c2:	48 89 ce             	mov    %rcx,%rsi
  8001c5:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001c7:	5b                   	pop    %rbx
  8001c8:	5d                   	pop    %rbp
  8001c9:	c3                   	retq   

00000000008001ca <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001ca:	55                   	push   %rbp
  8001cb:	48 89 e5             	mov    %rsp,%rbp
  8001ce:	41 56                	push   %r14
  8001d0:	41 55                	push   %r13
  8001d2:	41 54                	push   %r12
  8001d4:	53                   	push   %rbx
  8001d5:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001dc:	49 89 fd             	mov    %rdi,%r13
  8001df:	41 89 f6             	mov    %esi,%r14d
  8001e2:	49 89 d4             	mov    %rdx,%r12
  8001e5:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001ec:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001f3:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8001fa:	84 c0                	test   %al,%al
  8001fc:	74 26                	je     800224 <_panic+0x5a>
  8001fe:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800205:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80020c:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800210:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800214:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800218:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80021c:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800220:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800224:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80022b:	00 00 00 
  80022e:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800235:	00 00 00 
  800238:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80023c:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800243:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80024a:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800251:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800258:	00 00 00 
  80025b:	48 8b 18             	mov    (%rax),%rbx
  80025e:	48 b8 aa 01 80 00 00 	movabs $0x8001aa,%rax
  800265:	00 00 00 
  800268:	ff d0                	callq  *%rax
  80026a:	45 89 f0             	mov    %r14d,%r8d
  80026d:	4c 89 e9             	mov    %r13,%rcx
  800270:	48 89 da             	mov    %rbx,%rdx
  800273:	89 c6                	mov    %eax,%esi
  800275:	48 bf a0 11 80 00 00 	movabs $0x8011a0,%rdi
  80027c:	00 00 00 
  80027f:	b8 00 00 00 00       	mov    $0x0,%eax
  800284:	48 bb 6c 03 80 00 00 	movabs $0x80036c,%rbx
  80028b:	00 00 00 
  80028e:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800290:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800297:	4c 89 e7             	mov    %r12,%rdi
  80029a:	48 b8 04 03 80 00 00 	movabs $0x800304,%rax
  8002a1:	00 00 00 
  8002a4:	ff d0                	callq  *%rax
  cprintf("\n");
  8002a6:	48 bf c8 11 80 00 00 	movabs $0x8011c8,%rdi
  8002ad:	00 00 00 
  8002b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b5:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002b7:	cc                   	int3   
  while (1)
  8002b8:	eb fd                	jmp    8002b7 <_panic+0xed>

00000000008002ba <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002ba:	55                   	push   %rbp
  8002bb:	48 89 e5             	mov    %rsp,%rbp
  8002be:	53                   	push   %rbx
  8002bf:	48 83 ec 08          	sub    $0x8,%rsp
  8002c3:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002c6:	8b 06                	mov    (%rsi),%eax
  8002c8:	8d 50 01             	lea    0x1(%rax),%edx
  8002cb:	89 16                	mov    %edx,(%rsi)
  8002cd:	48 98                	cltq   
  8002cf:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002d4:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002da:	74 0b                	je     8002e7 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002dc:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002e0:	48 83 c4 08          	add    $0x8,%rsp
  8002e4:	5b                   	pop    %rbx
  8002e5:	5d                   	pop    %rbp
  8002e6:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002e7:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002eb:	be ff 00 00 00       	mov    $0xff,%esi
  8002f0:	48 b8 0c 01 80 00 00 	movabs $0x80010c,%rax
  8002f7:	00 00 00 
  8002fa:	ff d0                	callq  *%rax
    b->idx = 0;
  8002fc:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800302:	eb d8                	jmp    8002dc <putch+0x22>

0000000000800304 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800304:	55                   	push   %rbp
  800305:	48 89 e5             	mov    %rsp,%rbp
  800308:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80030f:	48 89 fa             	mov    %rdi,%rdx
  800312:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800315:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80031c:	00 00 00 
  b.cnt = 0;
  80031f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800326:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800329:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800330:	48 bf ba 02 80 00 00 	movabs $0x8002ba,%rdi
  800337:	00 00 00 
  80033a:	48 b8 2a 05 80 00 00 	movabs $0x80052a,%rax
  800341:	00 00 00 
  800344:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800346:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80034d:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800354:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800358:	48 b8 0c 01 80 00 00 	movabs $0x80010c,%rax
  80035f:	00 00 00 
  800362:	ff d0                	callq  *%rax

  return b.cnt;
}
  800364:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80036a:	c9                   	leaveq 
  80036b:	c3                   	retq   

000000000080036c <cprintf>:

int
cprintf(const char *fmt, ...) {
  80036c:	55                   	push   %rbp
  80036d:	48 89 e5             	mov    %rsp,%rbp
  800370:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800377:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80037e:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800385:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80038c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800393:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80039a:	84 c0                	test   %al,%al
  80039c:	74 20                	je     8003be <cprintf+0x52>
  80039e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003a2:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003a6:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003aa:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003ae:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003b2:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003b6:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003ba:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003be:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003c5:	00 00 00 
  8003c8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003cf:	00 00 00 
  8003d2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003d6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003dd:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003e4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003eb:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003f2:	48 b8 04 03 80 00 00 	movabs $0x800304,%rax
  8003f9:	00 00 00 
  8003fc:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8003fe:	c9                   	leaveq 
  8003ff:	c3                   	retq   

0000000000800400 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800400:	55                   	push   %rbp
  800401:	48 89 e5             	mov    %rsp,%rbp
  800404:	41 57                	push   %r15
  800406:	41 56                	push   %r14
  800408:	41 55                	push   %r13
  80040a:	41 54                	push   %r12
  80040c:	53                   	push   %rbx
  80040d:	48 83 ec 18          	sub    $0x18,%rsp
  800411:	49 89 fc             	mov    %rdi,%r12
  800414:	49 89 f5             	mov    %rsi,%r13
  800417:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80041b:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80041e:	41 89 cf             	mov    %ecx,%r15d
  800421:	49 39 d7             	cmp    %rdx,%r15
  800424:	76 45                	jbe    80046b <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800426:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80042a:	85 db                	test   %ebx,%ebx
  80042c:	7e 0e                	jle    80043c <printnum+0x3c>
      putch(padc, putdat);
  80042e:	4c 89 ee             	mov    %r13,%rsi
  800431:	44 89 f7             	mov    %r14d,%edi
  800434:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800437:	83 eb 01             	sub    $0x1,%ebx
  80043a:	75 f2                	jne    80042e <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80043c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	49 f7 f7             	div    %r15
  800448:	48 b8 ca 11 80 00 00 	movabs $0x8011ca,%rax
  80044f:	00 00 00 
  800452:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800456:	4c 89 ee             	mov    %r13,%rsi
  800459:	41 ff d4             	callq  *%r12
}
  80045c:	48 83 c4 18          	add    $0x18,%rsp
  800460:	5b                   	pop    %rbx
  800461:	41 5c                	pop    %r12
  800463:	41 5d                	pop    %r13
  800465:	41 5e                	pop    %r14
  800467:	41 5f                	pop    %r15
  800469:	5d                   	pop    %rbp
  80046a:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80046b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80046f:	ba 00 00 00 00       	mov    $0x0,%edx
  800474:	49 f7 f7             	div    %r15
  800477:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80047b:	48 89 c2             	mov    %rax,%rdx
  80047e:	48 b8 00 04 80 00 00 	movabs $0x800400,%rax
  800485:	00 00 00 
  800488:	ff d0                	callq  *%rax
  80048a:	eb b0                	jmp    80043c <printnum+0x3c>

000000000080048c <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80048c:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800490:	48 8b 06             	mov    (%rsi),%rax
  800493:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800497:	73 0a                	jae    8004a3 <sprintputch+0x17>
    *b->buf++ = ch;
  800499:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80049d:	48 89 16             	mov    %rdx,(%rsi)
  8004a0:	40 88 38             	mov    %dil,(%rax)
}
  8004a3:	c3                   	retq   

00000000008004a4 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004a4:	55                   	push   %rbp
  8004a5:	48 89 e5             	mov    %rsp,%rbp
  8004a8:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004af:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004b6:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004bd:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004c4:	84 c0                	test   %al,%al
  8004c6:	74 20                	je     8004e8 <printfmt+0x44>
  8004c8:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004cc:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004d0:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004d4:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004d8:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004dc:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004e0:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004e4:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004e8:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004ef:	00 00 00 
  8004f2:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004f9:	00 00 00 
  8004fc:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800500:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800507:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80050e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800515:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80051c:	48 b8 2a 05 80 00 00 	movabs $0x80052a,%rax
  800523:	00 00 00 
  800526:	ff d0                	callq  *%rax
}
  800528:	c9                   	leaveq 
  800529:	c3                   	retq   

000000000080052a <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80052a:	55                   	push   %rbp
  80052b:	48 89 e5             	mov    %rsp,%rbp
  80052e:	41 57                	push   %r15
  800530:	41 56                	push   %r14
  800532:	41 55                	push   %r13
  800534:	41 54                	push   %r12
  800536:	53                   	push   %rbx
  800537:	48 83 ec 48          	sub    $0x48,%rsp
  80053b:	49 89 fd             	mov    %rdi,%r13
  80053e:	49 89 f7             	mov    %rsi,%r15
  800541:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800544:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800548:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80054c:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800550:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800554:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800558:	41 0f b6 3e          	movzbl (%r14),%edi
  80055c:	83 ff 25             	cmp    $0x25,%edi
  80055f:	74 18                	je     800579 <vprintfmt+0x4f>
      if (ch == '\0')
  800561:	85 ff                	test   %edi,%edi
  800563:	0f 84 8c 06 00 00    	je     800bf5 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800569:	4c 89 fe             	mov    %r15,%rsi
  80056c:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80056f:	49 89 de             	mov    %rbx,%r14
  800572:	eb e0                	jmp    800554 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800574:	49 89 de             	mov    %rbx,%r14
  800577:	eb db                	jmp    800554 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800579:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80057d:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800581:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800588:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80058e:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800597:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80059d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005a3:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005a8:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005ad:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005b1:	0f b6 13             	movzbl (%rbx),%edx
  8005b4:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005b7:	3c 55                	cmp    $0x55,%al
  8005b9:	0f 87 8b 05 00 00    	ja     800b4a <vprintfmt+0x620>
  8005bf:	0f b6 c0             	movzbl %al,%eax
  8005c2:	49 bb 80 12 80 00 00 	movabs $0x801280,%r11
  8005c9:	00 00 00 
  8005cc:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005d0:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005d3:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005d7:	eb d4                	jmp    8005ad <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005d9:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005dc:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005e0:	eb cb                	jmp    8005ad <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005e2:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005e5:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005e9:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005ed:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005f0:	83 fa 09             	cmp    $0x9,%edx
  8005f3:	77 7e                	ja     800673 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8005f5:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8005f9:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8005fd:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800602:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800606:	8d 50 d0             	lea    -0x30(%rax),%edx
  800609:	83 fa 09             	cmp    $0x9,%edx
  80060c:	76 e7                	jbe    8005f5 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80060e:	4c 89 f3             	mov    %r14,%rbx
  800611:	eb 19                	jmp    80062c <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800613:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800616:	83 f8 2f             	cmp    $0x2f,%eax
  800619:	77 2a                	ja     800645 <vprintfmt+0x11b>
  80061b:	89 c2                	mov    %eax,%edx
  80061d:	4c 01 d2             	add    %r10,%rdx
  800620:	83 c0 08             	add    $0x8,%eax
  800623:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800626:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800629:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80062c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800630:	0f 89 77 ff ff ff    	jns    8005ad <vprintfmt+0x83>
          width = precision, precision = -1;
  800636:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80063a:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800640:	e9 68 ff ff ff       	jmpq   8005ad <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800645:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800649:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80064d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800651:	eb d3                	jmp    800626 <vprintfmt+0xfc>
        if (width < 0)
  800653:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800656:	85 c0                	test   %eax,%eax
  800658:	41 0f 48 c0          	cmovs  %r8d,%eax
  80065c:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80065f:	4c 89 f3             	mov    %r14,%rbx
  800662:	e9 46 ff ff ff       	jmpq   8005ad <vprintfmt+0x83>
  800667:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80066a:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80066e:	e9 3a ff ff ff       	jmpq   8005ad <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800673:	4c 89 f3             	mov    %r14,%rbx
  800676:	eb b4                	jmp    80062c <vprintfmt+0x102>
        lflag++;
  800678:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80067b:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80067e:	e9 2a ff ff ff       	jmpq   8005ad <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800683:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800686:	83 f8 2f             	cmp    $0x2f,%eax
  800689:	77 19                	ja     8006a4 <vprintfmt+0x17a>
  80068b:	89 c2                	mov    %eax,%edx
  80068d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800691:	83 c0 08             	add    $0x8,%eax
  800694:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800697:	4c 89 fe             	mov    %r15,%rsi
  80069a:	8b 3a                	mov    (%rdx),%edi
  80069c:	41 ff d5             	callq  *%r13
        break;
  80069f:	e9 b0 fe ff ff       	jmpq   800554 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006a4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006a8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006ac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006b0:	eb e5                	jmp    800697 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006b2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006b5:	83 f8 2f             	cmp    $0x2f,%eax
  8006b8:	77 5b                	ja     800715 <vprintfmt+0x1eb>
  8006ba:	89 c2                	mov    %eax,%edx
  8006bc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006c0:	83 c0 08             	add    $0x8,%eax
  8006c3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006c6:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006c8:	89 c8                	mov    %ecx,%eax
  8006ca:	c1 f8 1f             	sar    $0x1f,%eax
  8006cd:	31 c1                	xor    %eax,%ecx
  8006cf:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006d1:	83 f9 09             	cmp    $0x9,%ecx
  8006d4:	7f 4d                	jg     800723 <vprintfmt+0x1f9>
  8006d6:	48 63 c1             	movslq %ecx,%rax
  8006d9:	48 ba 40 15 80 00 00 	movabs $0x801540,%rdx
  8006e0:	00 00 00 
  8006e3:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006e7:	48 85 c0             	test   %rax,%rax
  8006ea:	74 37                	je     800723 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006ec:	48 89 c1             	mov    %rax,%rcx
  8006ef:	48 ba eb 11 80 00 00 	movabs $0x8011eb,%rdx
  8006f6:	00 00 00 
  8006f9:	4c 89 fe             	mov    %r15,%rsi
  8006fc:	4c 89 ef             	mov    %r13,%rdi
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	48 bb a4 04 80 00 00 	movabs $0x8004a4,%rbx
  80070b:	00 00 00 
  80070e:	ff d3                	callq  *%rbx
  800710:	e9 3f fe ff ff       	jmpq   800554 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800715:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800719:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80071d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800721:	eb a3                	jmp    8006c6 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800723:	48 ba e2 11 80 00 00 	movabs $0x8011e2,%rdx
  80072a:	00 00 00 
  80072d:	4c 89 fe             	mov    %r15,%rsi
  800730:	4c 89 ef             	mov    %r13,%rdi
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	48 bb a4 04 80 00 00 	movabs $0x8004a4,%rbx
  80073f:	00 00 00 
  800742:	ff d3                	callq  *%rbx
  800744:	e9 0b fe ff ff       	jmpq   800554 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800749:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80074c:	83 f8 2f             	cmp    $0x2f,%eax
  80074f:	77 4b                	ja     80079c <vprintfmt+0x272>
  800751:	89 c2                	mov    %eax,%edx
  800753:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800757:	83 c0 08             	add    $0x8,%eax
  80075a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80075d:	48 8b 02             	mov    (%rdx),%rax
  800760:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800764:	48 85 c0             	test   %rax,%rax
  800767:	0f 84 05 04 00 00    	je     800b72 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80076d:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800771:	7e 06                	jle    800779 <vprintfmt+0x24f>
  800773:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800777:	75 31                	jne    8007aa <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800779:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80077d:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800781:	0f b6 00             	movzbl (%rax),%eax
  800784:	0f be f8             	movsbl %al,%edi
  800787:	85 ff                	test   %edi,%edi
  800789:	0f 84 c3 00 00 00    	je     800852 <vprintfmt+0x328>
  80078f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800793:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800797:	e9 85 00 00 00       	jmpq   800821 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80079c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007a0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007a4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007a8:	eb b3                	jmp    80075d <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	49 63 f4             	movslq %r12d,%rsi
  8007ad:	48 89 c7             	mov    %rax,%rdi
  8007b0:	48 b8 01 0d 80 00 00 	movabs $0x800d01,%rax
  8007b7:	00 00 00 
  8007ba:	ff d0                	callq  *%rax
  8007bc:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007bf:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007c2:	85 f6                	test   %esi,%esi
  8007c4:	7e 22                	jle    8007e8 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007c6:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007ca:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007ce:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007d2:	4c 89 fe             	mov    %r15,%rsi
  8007d5:	89 df                	mov    %ebx,%edi
  8007d7:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007da:	41 83 ec 01          	sub    $0x1,%r12d
  8007de:	75 f2                	jne    8007d2 <vprintfmt+0x2a8>
  8007e0:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007e4:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007ec:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007f0:	0f b6 00             	movzbl (%rax),%eax
  8007f3:	0f be f8             	movsbl %al,%edi
  8007f6:	85 ff                	test   %edi,%edi
  8007f8:	0f 84 56 fd ff ff    	je     800554 <vprintfmt+0x2a>
  8007fe:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800802:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800806:	eb 19                	jmp    800821 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800808:	4c 89 fe             	mov    %r15,%rsi
  80080b:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080e:	41 83 ee 01          	sub    $0x1,%r14d
  800812:	48 83 c3 01          	add    $0x1,%rbx
  800816:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80081a:	0f be f8             	movsbl %al,%edi
  80081d:	85 ff                	test   %edi,%edi
  80081f:	74 29                	je     80084a <vprintfmt+0x320>
  800821:	45 85 e4             	test   %r12d,%r12d
  800824:	78 06                	js     80082c <vprintfmt+0x302>
  800826:	41 83 ec 01          	sub    $0x1,%r12d
  80082a:	78 48                	js     800874 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80082c:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800830:	74 d6                	je     800808 <vprintfmt+0x2de>
  800832:	0f be c0             	movsbl %al,%eax
  800835:	83 e8 20             	sub    $0x20,%eax
  800838:	83 f8 5e             	cmp    $0x5e,%eax
  80083b:	76 cb                	jbe    800808 <vprintfmt+0x2de>
            putch('?', putdat);
  80083d:	4c 89 fe             	mov    %r15,%rsi
  800840:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800845:	41 ff d5             	callq  *%r13
  800848:	eb c4                	jmp    80080e <vprintfmt+0x2e4>
  80084a:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80084e:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800852:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800855:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800859:	0f 8e f5 fc ff ff    	jle    800554 <vprintfmt+0x2a>
          putch(' ', putdat);
  80085f:	4c 89 fe             	mov    %r15,%rsi
  800862:	bf 20 00 00 00       	mov    $0x20,%edi
  800867:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80086a:	83 eb 01             	sub    $0x1,%ebx
  80086d:	75 f0                	jne    80085f <vprintfmt+0x335>
  80086f:	e9 e0 fc ff ff       	jmpq   800554 <vprintfmt+0x2a>
  800874:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800878:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80087c:	eb d4                	jmp    800852 <vprintfmt+0x328>
  if (lflag >= 2)
  80087e:	83 f9 01             	cmp    $0x1,%ecx
  800881:	7f 1d                	jg     8008a0 <vprintfmt+0x376>
  else if (lflag)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	74 5e                	je     8008e5 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800887:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80088a:	83 f8 2f             	cmp    $0x2f,%eax
  80088d:	77 48                	ja     8008d7 <vprintfmt+0x3ad>
  80088f:	89 c2                	mov    %eax,%edx
  800891:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800895:	83 c0 08             	add    $0x8,%eax
  800898:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80089b:	48 8b 1a             	mov    (%rdx),%rbx
  80089e:	eb 17                	jmp    8008b7 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008a0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008a3:	83 f8 2f             	cmp    $0x2f,%eax
  8008a6:	77 21                	ja     8008c9 <vprintfmt+0x39f>
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008ae:	83 c0 08             	add    $0x8,%eax
  8008b1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008b4:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008b7:	48 85 db             	test   %rbx,%rbx
  8008ba:	78 50                	js     80090c <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008bc:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008c4:	e9 b4 01 00 00       	jmpq   800a7d <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008c9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008cd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d5:	eb dd                	jmp    8008b4 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e3:	eb b6                	jmp    80089b <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008e5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008e8:	83 f8 2f             	cmp    $0x2f,%eax
  8008eb:	77 11                	ja     8008fe <vprintfmt+0x3d4>
  8008ed:	89 c2                	mov    %eax,%edx
  8008ef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008f3:	83 c0 08             	add    $0x8,%eax
  8008f6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008f9:	48 63 1a             	movslq (%rdx),%rbx
  8008fc:	eb b9                	jmp    8008b7 <vprintfmt+0x38d>
  8008fe:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800902:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800906:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80090a:	eb ed                	jmp    8008f9 <vprintfmt+0x3cf>
          putch('-', putdat);
  80090c:	4c 89 fe             	mov    %r15,%rsi
  80090f:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800914:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800917:	48 89 da             	mov    %rbx,%rdx
  80091a:	48 f7 da             	neg    %rdx
        base = 10;
  80091d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800922:	e9 56 01 00 00       	jmpq   800a7d <vprintfmt+0x553>
  if (lflag >= 2)
  800927:	83 f9 01             	cmp    $0x1,%ecx
  80092a:	7f 25                	jg     800951 <vprintfmt+0x427>
  else if (lflag)
  80092c:	85 c9                	test   %ecx,%ecx
  80092e:	74 5e                	je     80098e <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800930:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800933:	83 f8 2f             	cmp    $0x2f,%eax
  800936:	77 48                	ja     800980 <vprintfmt+0x456>
  800938:	89 c2                	mov    %eax,%edx
  80093a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093e:	83 c0 08             	add    $0x8,%eax
  800941:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800944:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800947:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80094c:	e9 2c 01 00 00       	jmpq   800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800951:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800954:	83 f8 2f             	cmp    $0x2f,%eax
  800957:	77 19                	ja     800972 <vprintfmt+0x448>
  800959:	89 c2                	mov    %eax,%edx
  80095b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095f:	83 c0 08             	add    $0x8,%eax
  800962:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800965:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800968:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80096d:	e9 0b 01 00 00       	jmpq   800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800972:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800976:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80097a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80097e:	eb e5                	jmp    800965 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800980:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800984:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800988:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80098c:	eb b6                	jmp    800944 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80098e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800991:	83 f8 2f             	cmp    $0x2f,%eax
  800994:	77 18                	ja     8009ae <vprintfmt+0x484>
  800996:	89 c2                	mov    %eax,%edx
  800998:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80099c:	83 c0 08             	add    $0x8,%eax
  80099f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009a2:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009a9:	e9 cf 00 00 00       	jmpq   800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009ae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009b2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ba:	eb e6                	jmp    8009a2 <vprintfmt+0x478>
  if (lflag >= 2)
  8009bc:	83 f9 01             	cmp    $0x1,%ecx
  8009bf:	7f 25                	jg     8009e6 <vprintfmt+0x4bc>
  else if (lflag)
  8009c1:	85 c9                	test   %ecx,%ecx
  8009c3:	74 5b                	je     800a20 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009c5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c8:	83 f8 2f             	cmp    $0x2f,%eax
  8009cb:	77 45                	ja     800a12 <vprintfmt+0x4e8>
  8009cd:	89 c2                	mov    %eax,%edx
  8009cf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d3:	83 c0 08             	add    $0x8,%eax
  8009d6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d9:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009dc:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009e1:	e9 97 00 00 00       	jmpq   800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009e6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e9:	83 f8 2f             	cmp    $0x2f,%eax
  8009ec:	77 16                	ja     800a04 <vprintfmt+0x4da>
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f4:	83 c0 08             	add    $0x8,%eax
  8009f7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009fa:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009fd:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a02:	eb 79                	jmp    800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a04:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a08:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a10:	eb e8                	jmp    8009fa <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a12:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a16:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a1e:	eb b9                	jmp    8009d9 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a20:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a23:	83 f8 2f             	cmp    $0x2f,%eax
  800a26:	77 15                	ja     800a3d <vprintfmt+0x513>
  800a28:	89 c2                	mov    %eax,%edx
  800a2a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a2e:	83 c0 08             	add    $0x8,%eax
  800a31:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a34:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a36:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a3b:	eb 40                	jmp    800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a3d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a41:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a45:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a49:	eb e9                	jmp    800a34 <vprintfmt+0x50a>
        putch('0', putdat);
  800a4b:	4c 89 fe             	mov    %r15,%rsi
  800a4e:	bf 30 00 00 00       	mov    $0x30,%edi
  800a53:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a56:	4c 89 fe             	mov    %r15,%rsi
  800a59:	bf 78 00 00 00       	mov    $0x78,%edi
  800a5e:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a61:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a64:	83 f8 2f             	cmp    $0x2f,%eax
  800a67:	77 34                	ja     800a9d <vprintfmt+0x573>
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a6f:	83 c0 08             	add    $0x8,%eax
  800a72:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a75:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a78:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a7d:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a82:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a86:	4c 89 fe             	mov    %r15,%rsi
  800a89:	4c 89 ef             	mov    %r13,%rdi
  800a8c:	48 b8 00 04 80 00 00 	movabs $0x800400,%rax
  800a93:	00 00 00 
  800a96:	ff d0                	callq  *%rax
        break;
  800a98:	e9 b7 fa ff ff       	jmpq   800554 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a9d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aa1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800aa5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800aa9:	eb ca                	jmp    800a75 <vprintfmt+0x54b>
  if (lflag >= 2)
  800aab:	83 f9 01             	cmp    $0x1,%ecx
  800aae:	7f 22                	jg     800ad2 <vprintfmt+0x5a8>
  else if (lflag)
  800ab0:	85 c9                	test   %ecx,%ecx
  800ab2:	74 58                	je     800b0c <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800ab4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ab7:	83 f8 2f             	cmp    $0x2f,%eax
  800aba:	77 42                	ja     800afe <vprintfmt+0x5d4>
  800abc:	89 c2                	mov    %eax,%edx
  800abe:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ac2:	83 c0 08             	add    $0x8,%eax
  800ac5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ac8:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800acb:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ad0:	eb ab                	jmp    800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ad2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ad5:	83 f8 2f             	cmp    $0x2f,%eax
  800ad8:	77 16                	ja     800af0 <vprintfmt+0x5c6>
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ae0:	83 c0 08             	add    $0x8,%eax
  800ae3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ae6:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ae9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800aee:	eb 8d                	jmp    800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800af0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800af4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800af8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800afc:	eb e8                	jmp    800ae6 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800afe:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b02:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b06:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b0a:	eb bc                	jmp    800ac8 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b0c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b0f:	83 f8 2f             	cmp    $0x2f,%eax
  800b12:	77 18                	ja     800b2c <vprintfmt+0x602>
  800b14:	89 c2                	mov    %eax,%edx
  800b16:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b1a:	83 c0 08             	add    $0x8,%eax
  800b1d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b20:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b22:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b27:	e9 51 ff ff ff       	jmpq   800a7d <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b2c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b30:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b34:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b38:	eb e6                	jmp    800b20 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b3a:	4c 89 fe             	mov    %r15,%rsi
  800b3d:	bf 25 00 00 00       	mov    $0x25,%edi
  800b42:	41 ff d5             	callq  *%r13
        break;
  800b45:	e9 0a fa ff ff       	jmpq   800554 <vprintfmt+0x2a>
        putch('%', putdat);
  800b4a:	4c 89 fe             	mov    %r15,%rsi
  800b4d:	bf 25 00 00 00       	mov    $0x25,%edi
  800b52:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b55:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b59:	0f 84 15 fa ff ff    	je     800574 <vprintfmt+0x4a>
  800b5f:	49 89 de             	mov    %rbx,%r14
  800b62:	49 83 ee 01          	sub    $0x1,%r14
  800b66:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b6b:	75 f5                	jne    800b62 <vprintfmt+0x638>
  800b6d:	e9 e2 f9 ff ff       	jmpq   800554 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b72:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b76:	74 06                	je     800b7e <vprintfmt+0x654>
  800b78:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b7c:	7f 21                	jg     800b9f <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b7e:	bf 28 00 00 00       	mov    $0x28,%edi
  800b83:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800b8a:	00 00 00 
  800b8d:	b8 28 00 00 00       	mov    $0x28,%eax
  800b92:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800b96:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800b9a:	e9 82 fc ff ff       	jmpq   800821 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800b9f:	49 63 f4             	movslq %r12d,%rsi
  800ba2:	48 bf db 11 80 00 00 	movabs $0x8011db,%rdi
  800ba9:	00 00 00 
  800bac:	48 b8 01 0d 80 00 00 	movabs $0x800d01,%rax
  800bb3:	00 00 00 
  800bb6:	ff d0                	callq  *%rax
  800bb8:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bbb:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bbe:	48 be db 11 80 00 00 	movabs $0x8011db,%rsi
  800bc5:	00 00 00 
  800bc8:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	0f 8f f2 fb ff ff    	jg     8007c6 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bd4:	48 bb dc 11 80 00 00 	movabs $0x8011dc,%rbx
  800bdb:	00 00 00 
  800bde:	b8 28 00 00 00       	mov    $0x28,%eax
  800be3:	bf 28 00 00 00       	mov    $0x28,%edi
  800be8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bec:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bf0:	e9 2c fc ff ff       	jmpq   800821 <vprintfmt+0x2f7>
}
  800bf5:	48 83 c4 48          	add    $0x48,%rsp
  800bf9:	5b                   	pop    %rbx
  800bfa:	41 5c                	pop    %r12
  800bfc:	41 5d                	pop    %r13
  800bfe:	41 5e                	pop    %r14
  800c00:	41 5f                	pop    %r15
  800c02:	5d                   	pop    %rbp
  800c03:	c3                   	retq   

0000000000800c04 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c04:	55                   	push   %rbp
  800c05:	48 89 e5             	mov    %rsp,%rbp
  800c08:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c0c:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c10:	48 63 c6             	movslq %esi,%rax
  800c13:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c18:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c1c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c23:	48 85 ff             	test   %rdi,%rdi
  800c26:	74 2a                	je     800c52 <vsnprintf+0x4e>
  800c28:	85 f6                	test   %esi,%esi
  800c2a:	7e 26                	jle    800c52 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c2c:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c30:	48 bf 8c 04 80 00 00 	movabs $0x80048c,%rdi
  800c37:	00 00 00 
  800c3a:	48 b8 2a 05 80 00 00 	movabs $0x80052a,%rax
  800c41:	00 00 00 
  800c44:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c46:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c4a:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c4d:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c50:	c9                   	leaveq 
  800c51:	c3                   	retq   
    return -E_INVAL;
  800c52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c57:	eb f7                	jmp    800c50 <vsnprintf+0x4c>

0000000000800c59 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c59:	55                   	push   %rbp
  800c5a:	48 89 e5             	mov    %rsp,%rbp
  800c5d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c64:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c6b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c72:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c79:	84 c0                	test   %al,%al
  800c7b:	74 20                	je     800c9d <snprintf+0x44>
  800c7d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c81:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c85:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c89:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c8d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c91:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800c95:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800c99:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800c9d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ca4:	00 00 00 
  800ca7:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800cae:	00 00 00 
  800cb1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cb5:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cbc:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cc3:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cca:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cd1:	48 b8 04 0c 80 00 00 	movabs $0x800c04,%rax
  800cd8:	00 00 00 
  800cdb:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cdd:	c9                   	leaveq 
  800cde:	c3                   	retq   

0000000000800cdf <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cdf:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ce2:	74 17                	je     800cfb <strlen+0x1c>
  800ce4:	48 89 fa             	mov    %rdi,%rdx
  800ce7:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cec:	29 f9                	sub    %edi,%ecx
    n++;
  800cee:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cf1:	48 83 c2 01          	add    $0x1,%rdx
  800cf5:	80 3a 00             	cmpb   $0x0,(%rdx)
  800cf8:	75 f4                	jne    800cee <strlen+0xf>
  800cfa:	c3                   	retq   
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d00:	c3                   	retq   

0000000000800d01 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d01:	48 85 f6             	test   %rsi,%rsi
  800d04:	74 24                	je     800d2a <strnlen+0x29>
  800d06:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d09:	74 25                	je     800d30 <strnlen+0x2f>
  800d0b:	48 01 fe             	add    %rdi,%rsi
  800d0e:	48 89 fa             	mov    %rdi,%rdx
  800d11:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d16:	29 f9                	sub    %edi,%ecx
    n++;
  800d18:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1b:	48 83 c2 01          	add    $0x1,%rdx
  800d1f:	48 39 f2             	cmp    %rsi,%rdx
  800d22:	74 11                	je     800d35 <strnlen+0x34>
  800d24:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d27:	75 ef                	jne    800d18 <strnlen+0x17>
  800d29:	c3                   	retq   
  800d2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2f:	c3                   	retq   
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d35:	c3                   	retq   

0000000000800d36 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d36:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d39:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3e:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d42:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d45:	48 83 c2 01          	add    $0x1,%rdx
  800d49:	84 c9                	test   %cl,%cl
  800d4b:	75 f1                	jne    800d3e <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d4d:	c3                   	retq   

0000000000800d4e <strcat>:

char *
strcat(char *dst, const char *src) {
  800d4e:	55                   	push   %rbp
  800d4f:	48 89 e5             	mov    %rsp,%rbp
  800d52:	41 54                	push   %r12
  800d54:	53                   	push   %rbx
  800d55:	48 89 fb             	mov    %rdi,%rbx
  800d58:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d5b:	48 b8 df 0c 80 00 00 	movabs $0x800cdf,%rax
  800d62:	00 00 00 
  800d65:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d67:	48 63 f8             	movslq %eax,%rdi
  800d6a:	48 01 df             	add    %rbx,%rdi
  800d6d:	4c 89 e6             	mov    %r12,%rsi
  800d70:	48 b8 36 0d 80 00 00 	movabs $0x800d36,%rax
  800d77:	00 00 00 
  800d7a:	ff d0                	callq  *%rax
  return dst;
}
  800d7c:	48 89 d8             	mov    %rbx,%rax
  800d7f:	5b                   	pop    %rbx
  800d80:	41 5c                	pop    %r12
  800d82:	5d                   	pop    %rbp
  800d83:	c3                   	retq   

0000000000800d84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d84:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d87:	48 85 d2             	test   %rdx,%rdx
  800d8a:	74 1f                	je     800dab <strncpy+0x27>
  800d8c:	48 01 fa             	add    %rdi,%rdx
  800d8f:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d92:	48 83 c1 01          	add    $0x1,%rcx
  800d96:	44 0f b6 06          	movzbl (%rsi),%r8d
  800d9a:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d9e:	41 80 f8 01          	cmp    $0x1,%r8b
  800da2:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800da6:	48 39 ca             	cmp    %rcx,%rdx
  800da9:	75 e7                	jne    800d92 <strncpy+0xe>
  }
  return ret;
}
  800dab:	c3                   	retq   

0000000000800dac <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800dac:	48 89 f8             	mov    %rdi,%rax
  800daf:	48 85 d2             	test   %rdx,%rdx
  800db2:	74 36                	je     800dea <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800db4:	48 83 fa 01          	cmp    $0x1,%rdx
  800db8:	74 2d                	je     800de7 <strlcpy+0x3b>
  800dba:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dbe:	45 84 c0             	test   %r8b,%r8b
  800dc1:	74 24                	je     800de7 <strlcpy+0x3b>
  800dc3:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dc7:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dcc:	48 83 c0 01          	add    $0x1,%rax
  800dd0:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800dd4:	48 39 d1             	cmp    %rdx,%rcx
  800dd7:	74 0e                	je     800de7 <strlcpy+0x3b>
  800dd9:	48 83 c1 01          	add    $0x1,%rcx
  800ddd:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800de2:	45 84 c0             	test   %r8b,%r8b
  800de5:	75 e5                	jne    800dcc <strlcpy+0x20>
    *dst = '\0';
  800de7:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dea:	48 29 f8             	sub    %rdi,%rax
}
  800ded:	c3                   	retq   

0000000000800dee <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800dee:	0f b6 07             	movzbl (%rdi),%eax
  800df1:	84 c0                	test   %al,%al
  800df3:	74 17                	je     800e0c <strcmp+0x1e>
  800df5:	3a 06                	cmp    (%rsi),%al
  800df7:	75 13                	jne    800e0c <strcmp+0x1e>
    p++, q++;
  800df9:	48 83 c7 01          	add    $0x1,%rdi
  800dfd:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e01:	0f b6 07             	movzbl (%rdi),%eax
  800e04:	84 c0                	test   %al,%al
  800e06:	74 04                	je     800e0c <strcmp+0x1e>
  800e08:	3a 06                	cmp    (%rsi),%al
  800e0a:	74 ed                	je     800df9 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e0c:	0f b6 c0             	movzbl %al,%eax
  800e0f:	0f b6 16             	movzbl (%rsi),%edx
  800e12:	29 d0                	sub    %edx,%eax
}
  800e14:	c3                   	retq   

0000000000800e15 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e15:	48 85 d2             	test   %rdx,%rdx
  800e18:	74 2f                	je     800e49 <strncmp+0x34>
  800e1a:	0f b6 07             	movzbl (%rdi),%eax
  800e1d:	84 c0                	test   %al,%al
  800e1f:	74 1f                	je     800e40 <strncmp+0x2b>
  800e21:	3a 06                	cmp    (%rsi),%al
  800e23:	75 1b                	jne    800e40 <strncmp+0x2b>
  800e25:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e28:	48 83 c7 01          	add    $0x1,%rdi
  800e2c:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e30:	48 39 d7             	cmp    %rdx,%rdi
  800e33:	74 1a                	je     800e4f <strncmp+0x3a>
  800e35:	0f b6 07             	movzbl (%rdi),%eax
  800e38:	84 c0                	test   %al,%al
  800e3a:	74 04                	je     800e40 <strncmp+0x2b>
  800e3c:	3a 06                	cmp    (%rsi),%al
  800e3e:	74 e8                	je     800e28 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e40:	0f b6 07             	movzbl (%rdi),%eax
  800e43:	0f b6 16             	movzbl (%rsi),%edx
  800e46:	29 d0                	sub    %edx,%eax
}
  800e48:	c3                   	retq   
    return 0;
  800e49:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4e:	c3                   	retq   
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	c3                   	retq   

0000000000800e55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e55:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e57:	0f b6 07             	movzbl (%rdi),%eax
  800e5a:	84 c0                	test   %al,%al
  800e5c:	74 1e                	je     800e7c <strchr+0x27>
    if (*s == c)
  800e5e:	40 38 c6             	cmp    %al,%sil
  800e61:	74 1f                	je     800e82 <strchr+0x2d>
  for (; *s; s++)
  800e63:	48 83 c7 01          	add    $0x1,%rdi
  800e67:	0f b6 07             	movzbl (%rdi),%eax
  800e6a:	84 c0                	test   %al,%al
  800e6c:	74 08                	je     800e76 <strchr+0x21>
    if (*s == c)
  800e6e:	38 d0                	cmp    %dl,%al
  800e70:	75 f1                	jne    800e63 <strchr+0xe>
  for (; *s; s++)
  800e72:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e75:	c3                   	retq   
  return 0;
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	c3                   	retq   
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e81:	c3                   	retq   
    if (*s == c)
  800e82:	48 89 f8             	mov    %rdi,%rax
  800e85:	c3                   	retq   

0000000000800e86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e86:	48 89 f8             	mov    %rdi,%rax
  800e89:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e8b:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e8e:	40 38 f2             	cmp    %sil,%dl
  800e91:	74 13                	je     800ea6 <strfind+0x20>
  800e93:	84 d2                	test   %dl,%dl
  800e95:	74 0f                	je     800ea6 <strfind+0x20>
  for (; *s; s++)
  800e97:	48 83 c0 01          	add    $0x1,%rax
  800e9b:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800e9e:	38 ca                	cmp    %cl,%dl
  800ea0:	74 04                	je     800ea6 <strfind+0x20>
  800ea2:	84 d2                	test   %dl,%dl
  800ea4:	75 f1                	jne    800e97 <strfind+0x11>
      break;
  return (char *)s;
}
  800ea6:	c3                   	retq   

0000000000800ea7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800ea7:	48 85 d2             	test   %rdx,%rdx
  800eaa:	74 3a                	je     800ee6 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eac:	48 89 f8             	mov    %rdi,%rax
  800eaf:	48 09 d0             	or     %rdx,%rax
  800eb2:	a8 03                	test   $0x3,%al
  800eb4:	75 28                	jne    800ede <memset+0x37>
    uint32_t k = c & 0xFFU;
  800eb6:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	c1 e0 08             	shl    $0x8,%eax
  800ebf:	89 f1                	mov    %esi,%ecx
  800ec1:	c1 e1 18             	shl    $0x18,%ecx
  800ec4:	41 89 f0             	mov    %esi,%r8d
  800ec7:	41 c1 e0 10          	shl    $0x10,%r8d
  800ecb:	44 09 c1             	or     %r8d,%ecx
  800ece:	09 ce                	or     %ecx,%esi
  800ed0:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ed2:	48 c1 ea 02          	shr    $0x2,%rdx
  800ed6:	48 89 d1             	mov    %rdx,%rcx
  800ed9:	fc                   	cld    
  800eda:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800edc:	eb 08                	jmp    800ee6 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ede:	89 f0                	mov    %esi,%eax
  800ee0:	48 89 d1             	mov    %rdx,%rcx
  800ee3:	fc                   	cld    
  800ee4:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ee6:	48 89 f8             	mov    %rdi,%rax
  800ee9:	c3                   	retq   

0000000000800eea <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800eea:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800eed:	48 39 fe             	cmp    %rdi,%rsi
  800ef0:	73 40                	jae    800f32 <memmove+0x48>
  800ef2:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800ef6:	48 39 f9             	cmp    %rdi,%rcx
  800ef9:	76 37                	jbe    800f32 <memmove+0x48>
    s += n;
    d += n;
  800efb:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800eff:	48 89 fe             	mov    %rdi,%rsi
  800f02:	48 09 d6             	or     %rdx,%rsi
  800f05:	48 09 ce             	or     %rcx,%rsi
  800f08:	40 f6 c6 03          	test   $0x3,%sil
  800f0c:	75 14                	jne    800f22 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f0e:	48 83 ef 04          	sub    $0x4,%rdi
  800f12:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f16:	48 c1 ea 02          	shr    $0x2,%rdx
  800f1a:	48 89 d1             	mov    %rdx,%rcx
  800f1d:	fd                   	std    
  800f1e:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f20:	eb 0e                	jmp    800f30 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f22:	48 83 ef 01          	sub    $0x1,%rdi
  800f26:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f2a:	48 89 d1             	mov    %rdx,%rcx
  800f2d:	fd                   	std    
  800f2e:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f30:	fc                   	cld    
  800f31:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f32:	48 89 c1             	mov    %rax,%rcx
  800f35:	48 09 d1             	or     %rdx,%rcx
  800f38:	48 09 f1             	or     %rsi,%rcx
  800f3b:	f6 c1 03             	test   $0x3,%cl
  800f3e:	75 0e                	jne    800f4e <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f40:	48 c1 ea 02          	shr    $0x2,%rdx
  800f44:	48 89 d1             	mov    %rdx,%rcx
  800f47:	48 89 c7             	mov    %rax,%rdi
  800f4a:	fc                   	cld    
  800f4b:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f4d:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f4e:	48 89 c7             	mov    %rax,%rdi
  800f51:	48 89 d1             	mov    %rdx,%rcx
  800f54:	fc                   	cld    
  800f55:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f57:	c3                   	retq   

0000000000800f58 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f58:	55                   	push   %rbp
  800f59:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f5c:	48 b8 ea 0e 80 00 00 	movabs $0x800eea,%rax
  800f63:	00 00 00 
  800f66:	ff d0                	callq  *%rax
}
  800f68:	5d                   	pop    %rbp
  800f69:	c3                   	retq   

0000000000800f6a <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f6a:	55                   	push   %rbp
  800f6b:	48 89 e5             	mov    %rsp,%rbp
  800f6e:	41 57                	push   %r15
  800f70:	41 56                	push   %r14
  800f72:	41 55                	push   %r13
  800f74:	41 54                	push   %r12
  800f76:	53                   	push   %rbx
  800f77:	48 83 ec 08          	sub    $0x8,%rsp
  800f7b:	49 89 fe             	mov    %rdi,%r14
  800f7e:	49 89 f7             	mov    %rsi,%r15
  800f81:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f84:	48 89 f7             	mov    %rsi,%rdi
  800f87:	48 b8 df 0c 80 00 00 	movabs $0x800cdf,%rax
  800f8e:	00 00 00 
  800f91:	ff d0                	callq  *%rax
  800f93:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800f96:	4c 89 ee             	mov    %r13,%rsi
  800f99:	4c 89 f7             	mov    %r14,%rdi
  800f9c:	48 b8 01 0d 80 00 00 	movabs $0x800d01,%rax
  800fa3:	00 00 00 
  800fa6:	ff d0                	callq  *%rax
  800fa8:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fab:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800faf:	4d 39 e5             	cmp    %r12,%r13
  800fb2:	74 26                	je     800fda <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fb4:	4c 89 e8             	mov    %r13,%rax
  800fb7:	4c 29 e0             	sub    %r12,%rax
  800fba:	48 39 d8             	cmp    %rbx,%rax
  800fbd:	76 2a                	jbe    800fe9 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fbf:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fc3:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fc7:	4c 89 fe             	mov    %r15,%rsi
  800fca:	48 b8 58 0f 80 00 00 	movabs $0x800f58,%rax
  800fd1:	00 00 00 
  800fd4:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fd6:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fda:	48 83 c4 08          	add    $0x8,%rsp
  800fde:	5b                   	pop    %rbx
  800fdf:	41 5c                	pop    %r12
  800fe1:	41 5d                	pop    %r13
  800fe3:	41 5e                	pop    %r14
  800fe5:	41 5f                	pop    %r15
  800fe7:	5d                   	pop    %rbp
  800fe8:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800fe9:	49 83 ed 01          	sub    $0x1,%r13
  800fed:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ff1:	4c 89 ea             	mov    %r13,%rdx
  800ff4:	4c 89 fe             	mov    %r15,%rsi
  800ff7:	48 b8 58 0f 80 00 00 	movabs $0x800f58,%rax
  800ffe:	00 00 00 
  801001:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801003:	4d 01 ee             	add    %r13,%r14
  801006:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80100b:	eb c9                	jmp    800fd6 <strlcat+0x6c>

000000000080100d <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80100d:	48 85 d2             	test   %rdx,%rdx
  801010:	74 3a                	je     80104c <memcmp+0x3f>
    if (*s1 != *s2)
  801012:	0f b6 0f             	movzbl (%rdi),%ecx
  801015:	44 0f b6 06          	movzbl (%rsi),%r8d
  801019:	44 38 c1             	cmp    %r8b,%cl
  80101c:	75 1d                	jne    80103b <memcmp+0x2e>
  80101e:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801023:	48 39 d0             	cmp    %rdx,%rax
  801026:	74 1e                	je     801046 <memcmp+0x39>
    if (*s1 != *s2)
  801028:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80102c:	48 83 c0 01          	add    $0x1,%rax
  801030:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801036:	44 38 c1             	cmp    %r8b,%cl
  801039:	74 e8                	je     801023 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80103b:	0f b6 c1             	movzbl %cl,%eax
  80103e:	45 0f b6 c0          	movzbl %r8b,%r8d
  801042:	44 29 c0             	sub    %r8d,%eax
  801045:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801046:	b8 00 00 00 00       	mov    $0x0,%eax
  80104b:	c3                   	retq   
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801051:	c3                   	retq   

0000000000801052 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801052:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801056:	48 39 c7             	cmp    %rax,%rdi
  801059:	73 19                	jae    801074 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80105b:	89 f2                	mov    %esi,%edx
  80105d:	40 38 37             	cmp    %sil,(%rdi)
  801060:	74 16                	je     801078 <memfind+0x26>
  for (; s < ends; s++)
  801062:	48 83 c7 01          	add    $0x1,%rdi
  801066:	48 39 f8             	cmp    %rdi,%rax
  801069:	74 08                	je     801073 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80106b:	38 17                	cmp    %dl,(%rdi)
  80106d:	75 f3                	jne    801062 <memfind+0x10>
  for (; s < ends; s++)
  80106f:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801072:	c3                   	retq   
  801073:	c3                   	retq   
  for (; s < ends; s++)
  801074:	48 89 f8             	mov    %rdi,%rax
  801077:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801078:	48 89 f8             	mov    %rdi,%rax
  80107b:	c3                   	retq   

000000000080107c <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80107c:	0f b6 07             	movzbl (%rdi),%eax
  80107f:	3c 20                	cmp    $0x20,%al
  801081:	74 04                	je     801087 <strtol+0xb>
  801083:	3c 09                	cmp    $0x9,%al
  801085:	75 0f                	jne    801096 <strtol+0x1a>
    s++;
  801087:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80108b:	0f b6 07             	movzbl (%rdi),%eax
  80108e:	3c 20                	cmp    $0x20,%al
  801090:	74 f5                	je     801087 <strtol+0xb>
  801092:	3c 09                	cmp    $0x9,%al
  801094:	74 f1                	je     801087 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801096:	3c 2b                	cmp    $0x2b,%al
  801098:	74 2b                	je     8010c5 <strtol+0x49>
  int neg  = 0;
  80109a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010a0:	3c 2d                	cmp    $0x2d,%al
  8010a2:	74 2d                	je     8010d1 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010a4:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010aa:	75 0f                	jne    8010bb <strtol+0x3f>
  8010ac:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010af:	74 2c                	je     8010dd <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010b1:	85 d2                	test   %edx,%edx
  8010b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010b8:	0f 44 d0             	cmove  %eax,%edx
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010c0:	4c 63 d2             	movslq %edx,%r10
  8010c3:	eb 5c                	jmp    801121 <strtol+0xa5>
    s++;
  8010c5:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010c9:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010cf:	eb d3                	jmp    8010a4 <strtol+0x28>
    s++, neg = 1;
  8010d1:	48 83 c7 01          	add    $0x1,%rdi
  8010d5:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010db:	eb c7                	jmp    8010a4 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010dd:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010e1:	74 0f                	je     8010f2 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010e3:	85 d2                	test   %edx,%edx
  8010e5:	75 d4                	jne    8010bb <strtol+0x3f>
    s++, base = 8;
  8010e7:	48 83 c7 01          	add    $0x1,%rdi
  8010eb:	ba 08 00 00 00       	mov    $0x8,%edx
  8010f0:	eb c9                	jmp    8010bb <strtol+0x3f>
    s += 2, base = 16;
  8010f2:	48 83 c7 02          	add    $0x2,%rdi
  8010f6:	ba 10 00 00 00       	mov    $0x10,%edx
  8010fb:	eb be                	jmp    8010bb <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8010fd:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801101:	41 80 f8 19          	cmp    $0x19,%r8b
  801105:	77 2f                	ja     801136 <strtol+0xba>
      dig = *s - 'a' + 10;
  801107:	44 0f be c1          	movsbl %cl,%r8d
  80110b:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80110f:	39 d1                	cmp    %edx,%ecx
  801111:	7d 37                	jge    80114a <strtol+0xce>
    s++, val = (val * base) + dig;
  801113:	48 83 c7 01          	add    $0x1,%rdi
  801117:	49 0f af c2          	imul   %r10,%rax
  80111b:	48 63 c9             	movslq %ecx,%rcx
  80111e:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801121:	0f b6 0f             	movzbl (%rdi),%ecx
  801124:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801128:	41 80 f8 09          	cmp    $0x9,%r8b
  80112c:	77 cf                	ja     8010fd <strtol+0x81>
      dig = *s - '0';
  80112e:	0f be c9             	movsbl %cl,%ecx
  801131:	83 e9 30             	sub    $0x30,%ecx
  801134:	eb d9                	jmp    80110f <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801136:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80113a:	41 80 f8 19          	cmp    $0x19,%r8b
  80113e:	77 0a                	ja     80114a <strtol+0xce>
      dig = *s - 'A' + 10;
  801140:	44 0f be c1          	movsbl %cl,%r8d
  801144:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801148:	eb c5                	jmp    80110f <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80114a:	48 85 f6             	test   %rsi,%rsi
  80114d:	74 03                	je     801152 <strtol+0xd6>
    *endptr = (char *)s;
  80114f:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801152:	48 89 c2             	mov    %rax,%rdx
  801155:	48 f7 da             	neg    %rdx
  801158:	45 85 c9             	test   %r9d,%r9d
  80115b:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80115f:	c3                   	retq   
