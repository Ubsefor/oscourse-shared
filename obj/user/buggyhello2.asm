
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
  800040:	48 b8 1f 01 80 00 00 	movabs $0x80011f,%rax
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  80009b:	48 b8 bd 01 80 00 00 	movabs $0x8001bd,%rax
  8000a2:	00 00 00 
  8000a5:	ff d0                	callq  *%rax
  8000a7:	83 e0 1f             	and    $0x1f,%eax
  8000aa:	48 89 c2             	mov    %rax,%rdx
  8000ad:	48 c1 e2 05          	shl    $0x5,%rdx
  8000b1:	48 29 c2             	sub    %rax,%rdx
  8000b4:	48 89 d0             	mov    %rdx,%rax
  8000b7:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000be:	00 00 00 
  8000c1:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000c5:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  8000cc:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000cf:	45 85 ed             	test   %r13d,%r13d
  8000d2:	7e 0d                	jle    8000e1 <libmain+0x93>
    binaryname = argv[0];
  8000d4:	49 8b 06             	mov    (%r14),%rax
  8000d7:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000de:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e1:	4c 89 f6             	mov    %r14,%rsi
  8000e4:	44 89 ef             	mov    %r13d,%edi
  8000e7:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000ee:	00 00 00 
  8000f1:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f3:	48 b8 08 01 80 00 00 	movabs $0x800108,%rax
  8000fa:	00 00 00 
  8000fd:	ff d0                	callq  *%rax
#endif
}
  8000ff:	5b                   	pop    %rbx
  800100:	41 5c                	pop    %r12
  800102:	41 5d                	pop    %r13
  800104:	41 5e                	pop    %r14
  800106:	5d                   	pop    %rbp
  800107:	c3                   	retq   

0000000000800108 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800108:	55                   	push   %rbp
  800109:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80010c:	bf 00 00 00 00       	mov    $0x0,%edi
  800111:	48 b8 5d 01 80 00 00 	movabs $0x80015d,%rax
  800118:	00 00 00 
  80011b:	ff d0                	callq  *%rax
}
  80011d:	5d                   	pop    %rbp
  80011e:	c3                   	retq   

000000000080011f <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80011f:	55                   	push   %rbp
  800120:	48 89 e5             	mov    %rsp,%rbp
  800123:	53                   	push   %rbx
  800124:	48 89 fa             	mov    %rdi,%rdx
  800127:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80012a:	b8 00 00 00 00       	mov    $0x0,%eax
  80012f:	48 89 c3             	mov    %rax,%rbx
  800132:	48 89 c7             	mov    %rax,%rdi
  800135:	48 89 c6             	mov    %rax,%rsi
  800138:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80013a:	5b                   	pop    %rbx
  80013b:	5d                   	pop    %rbp
  80013c:	c3                   	retq   

000000000080013d <sys_cgetc>:

int
sys_cgetc(void) {
  80013d:	55                   	push   %rbp
  80013e:	48 89 e5             	mov    %rsp,%rbp
  800141:	53                   	push   %rbx
  asm volatile("int %1\n"
  800142:	b9 00 00 00 00       	mov    $0x0,%ecx
  800147:	b8 01 00 00 00       	mov    $0x1,%eax
  80014c:	48 89 ca             	mov    %rcx,%rdx
  80014f:	48 89 cb             	mov    %rcx,%rbx
  800152:	48 89 cf             	mov    %rcx,%rdi
  800155:	48 89 ce             	mov    %rcx,%rsi
  800158:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %rbx
  80015b:	5d                   	pop    %rbp
  80015c:	c3                   	retq   

000000000080015d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80015d:	55                   	push   %rbp
  80015e:	48 89 e5             	mov    %rsp,%rbp
  800161:	53                   	push   %rbx
  800162:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800166:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800169:	be 00 00 00 00       	mov    $0x0,%esi
  80016e:	b8 03 00 00 00       	mov    $0x3,%eax
  800173:	48 89 f1             	mov    %rsi,%rcx
  800176:	48 89 f3             	mov    %rsi,%rbx
  800179:	48 89 f7             	mov    %rsi,%rdi
  80017c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80017e:	48 85 c0             	test   %rax,%rax
  800181:	7f 07                	jg     80018a <sys_env_destroy+0x2d>
}
  800183:	48 83 c4 08          	add    $0x8,%rsp
  800187:	5b                   	pop    %rbx
  800188:	5d                   	pop    %rbp
  800189:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80018a:	49 89 c0             	mov    %rax,%r8
  80018d:	b9 03 00 00 00       	mov    $0x3,%ecx
  800192:	48 ba 98 11 80 00 00 	movabs $0x801198,%rdx
  800199:	00 00 00 
  80019c:	be 22 00 00 00       	mov    $0x22,%esi
  8001a1:	48 bf b7 11 80 00 00 	movabs $0x8011b7,%rdi
  8001a8:	00 00 00 
  8001ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b0:	49 b9 dd 01 80 00 00 	movabs $0x8001dd,%r9
  8001b7:	00 00 00 
  8001ba:	41 ff d1             	callq  *%r9

00000000008001bd <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001bd:	55                   	push   %rbp
  8001be:	48 89 e5             	mov    %rsp,%rbp
  8001c1:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8001cc:	48 89 ca             	mov    %rcx,%rdx
  8001cf:	48 89 cb             	mov    %rcx,%rbx
  8001d2:	48 89 cf             	mov    %rcx,%rdi
  8001d5:	48 89 ce             	mov    %rcx,%rsi
  8001d8:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001da:	5b                   	pop    %rbx
  8001db:	5d                   	pop    %rbp
  8001dc:	c3                   	retq   

00000000008001dd <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001dd:	55                   	push   %rbp
  8001de:	48 89 e5             	mov    %rsp,%rbp
  8001e1:	41 56                	push   %r14
  8001e3:	41 55                	push   %r13
  8001e5:	41 54                	push   %r12
  8001e7:	53                   	push   %rbx
  8001e8:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001ef:	49 89 fd             	mov    %rdi,%r13
  8001f2:	41 89 f6             	mov    %esi,%r14d
  8001f5:	49 89 d4             	mov    %rdx,%r12
  8001f8:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001ff:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800206:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80020d:	84 c0                	test   %al,%al
  80020f:	74 26                	je     800237 <_panic+0x5a>
  800211:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800218:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80021f:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800223:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800227:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80022b:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80022f:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800233:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800237:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80023e:	00 00 00 
  800241:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800248:	00 00 00 
  80024b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80024f:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800256:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80025d:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800264:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80026b:	00 00 00 
  80026e:	48 8b 18             	mov    (%rax),%rbx
  800271:	48 b8 bd 01 80 00 00 	movabs $0x8001bd,%rax
  800278:	00 00 00 
  80027b:	ff d0                	callq  *%rax
  80027d:	45 89 f0             	mov    %r14d,%r8d
  800280:	4c 89 e9             	mov    %r13,%rcx
  800283:	48 89 da             	mov    %rbx,%rdx
  800286:	89 c6                	mov    %eax,%esi
  800288:	48 bf c8 11 80 00 00 	movabs $0x8011c8,%rdi
  80028f:	00 00 00 
  800292:	b8 00 00 00 00       	mov    $0x0,%eax
  800297:	48 bb 7f 03 80 00 00 	movabs $0x80037f,%rbx
  80029e:	00 00 00 
  8002a1:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8002a3:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002aa:	4c 89 e7             	mov    %r12,%rdi
  8002ad:	48 b8 17 03 80 00 00 	movabs $0x800317,%rax
  8002b4:	00 00 00 
  8002b7:	ff d0                	callq  *%rax
  cprintf("\n");
  8002b9:	48 bf 8c 11 80 00 00 	movabs $0x80118c,%rdi
  8002c0:	00 00 00 
  8002c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c8:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002ca:	cc                   	int3   
  while (1)
  8002cb:	eb fd                	jmp    8002ca <_panic+0xed>

00000000008002cd <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002cd:	55                   	push   %rbp
  8002ce:	48 89 e5             	mov    %rsp,%rbp
  8002d1:	53                   	push   %rbx
  8002d2:	48 83 ec 08          	sub    $0x8,%rsp
  8002d6:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002d9:	8b 06                	mov    (%rsi),%eax
  8002db:	8d 50 01             	lea    0x1(%rax),%edx
  8002de:	89 16                	mov    %edx,(%rsi)
  8002e0:	48 98                	cltq   
  8002e2:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002e7:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002ed:	74 0b                	je     8002fa <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002ef:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002f3:	48 83 c4 08          	add    $0x8,%rsp
  8002f7:	5b                   	pop    %rbx
  8002f8:	5d                   	pop    %rbp
  8002f9:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002fa:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002fe:	be ff 00 00 00       	mov    $0xff,%esi
  800303:	48 b8 1f 01 80 00 00 	movabs $0x80011f,%rax
  80030a:	00 00 00 
  80030d:	ff d0                	callq  *%rax
    b->idx = 0;
  80030f:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800315:	eb d8                	jmp    8002ef <putch+0x22>

0000000000800317 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800317:	55                   	push   %rbp
  800318:	48 89 e5             	mov    %rsp,%rbp
  80031b:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800322:	48 89 fa             	mov    %rdi,%rdx
  800325:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800328:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80032f:	00 00 00 
  b.cnt = 0;
  800332:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800339:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80033c:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800343:	48 bf cd 02 80 00 00 	movabs $0x8002cd,%rdi
  80034a:	00 00 00 
  80034d:	48 b8 3d 05 80 00 00 	movabs $0x80053d,%rax
  800354:	00 00 00 
  800357:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800359:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800360:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800367:	48 8d 78 08          	lea    0x8(%rax),%rdi
  80036b:	48 b8 1f 01 80 00 00 	movabs $0x80011f,%rax
  800372:	00 00 00 
  800375:	ff d0                	callq  *%rax

  return b.cnt;
}
  800377:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80037d:	c9                   	leaveq 
  80037e:	c3                   	retq   

000000000080037f <cprintf>:

int
cprintf(const char *fmt, ...) {
  80037f:	55                   	push   %rbp
  800380:	48 89 e5             	mov    %rsp,%rbp
  800383:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80038a:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800391:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800398:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80039f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8003a6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003ad:	84 c0                	test   %al,%al
  8003af:	74 20                	je     8003d1 <cprintf+0x52>
  8003b1:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003b5:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003b9:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003bd:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003c1:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003c5:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003c9:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003cd:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003d1:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003d8:	00 00 00 
  8003db:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003e2:	00 00 00 
  8003e5:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003e9:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003f0:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003f7:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003fe:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800405:	48 b8 17 03 80 00 00 	movabs $0x800317,%rax
  80040c:	00 00 00 
  80040f:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800411:	c9                   	leaveq 
  800412:	c3                   	retq   

0000000000800413 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800413:	55                   	push   %rbp
  800414:	48 89 e5             	mov    %rsp,%rbp
  800417:	41 57                	push   %r15
  800419:	41 56                	push   %r14
  80041b:	41 55                	push   %r13
  80041d:	41 54                	push   %r12
  80041f:	53                   	push   %rbx
  800420:	48 83 ec 18          	sub    $0x18,%rsp
  800424:	49 89 fc             	mov    %rdi,%r12
  800427:	49 89 f5             	mov    %rsi,%r13
  80042a:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80042e:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800431:	41 89 cf             	mov    %ecx,%r15d
  800434:	49 39 d7             	cmp    %rdx,%r15
  800437:	76 45                	jbe    80047e <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800439:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80043d:	85 db                	test   %ebx,%ebx
  80043f:	7e 0e                	jle    80044f <printnum+0x3c>
      putch(padc, putdat);
  800441:	4c 89 ee             	mov    %r13,%rsi
  800444:	44 89 f7             	mov    %r14d,%edi
  800447:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80044a:	83 eb 01             	sub    $0x1,%ebx
  80044d:	75 f2                	jne    800441 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80044f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800453:	ba 00 00 00 00       	mov    $0x0,%edx
  800458:	49 f7 f7             	div    %r15
  80045b:	48 b8 f0 11 80 00 00 	movabs $0x8011f0,%rax
  800462:	00 00 00 
  800465:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800469:	4c 89 ee             	mov    %r13,%rsi
  80046c:	41 ff d4             	callq  *%r12
}
  80046f:	48 83 c4 18          	add    $0x18,%rsp
  800473:	5b                   	pop    %rbx
  800474:	41 5c                	pop    %r12
  800476:	41 5d                	pop    %r13
  800478:	41 5e                	pop    %r14
  80047a:	41 5f                	pop    %r15
  80047c:	5d                   	pop    %rbp
  80047d:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80047e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800482:	ba 00 00 00 00       	mov    $0x0,%edx
  800487:	49 f7 f7             	div    %r15
  80048a:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80048e:	48 89 c2             	mov    %rax,%rdx
  800491:	48 b8 13 04 80 00 00 	movabs $0x800413,%rax
  800498:	00 00 00 
  80049b:	ff d0                	callq  *%rax
  80049d:	eb b0                	jmp    80044f <printnum+0x3c>

000000000080049f <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80049f:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8004a3:	48 8b 06             	mov    (%rsi),%rax
  8004a6:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004aa:	73 0a                	jae    8004b6 <sprintputch+0x17>
    *b->buf++ = ch;
  8004ac:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004b0:	48 89 16             	mov    %rdx,(%rsi)
  8004b3:	40 88 38             	mov    %dil,(%rax)
}
  8004b6:	c3                   	retq   

00000000008004b7 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004b7:	55                   	push   %rbp
  8004b8:	48 89 e5             	mov    %rsp,%rbp
  8004bb:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004c2:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004c9:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004d0:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004d7:	84 c0                	test   %al,%al
  8004d9:	74 20                	je     8004fb <printfmt+0x44>
  8004db:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004df:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004e3:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004e7:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004eb:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004ef:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004f3:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004f7:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004fb:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800502:	00 00 00 
  800505:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80050c:	00 00 00 
  80050f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800513:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80051a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800521:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800528:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80052f:	48 b8 3d 05 80 00 00 	movabs $0x80053d,%rax
  800536:	00 00 00 
  800539:	ff d0                	callq  *%rax
}
  80053b:	c9                   	leaveq 
  80053c:	c3                   	retq   

000000000080053d <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80053d:	55                   	push   %rbp
  80053e:	48 89 e5             	mov    %rsp,%rbp
  800541:	41 57                	push   %r15
  800543:	41 56                	push   %r14
  800545:	41 55                	push   %r13
  800547:	41 54                	push   %r12
  800549:	53                   	push   %rbx
  80054a:	48 83 ec 48          	sub    $0x48,%rsp
  80054e:	49 89 fd             	mov    %rdi,%r13
  800551:	49 89 f7             	mov    %rsi,%r15
  800554:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800557:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80055b:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80055f:	48 8b 41 10          	mov    0x10(%rcx),%rax
  800563:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800567:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80056b:	41 0f b6 3e          	movzbl (%r14),%edi
  80056f:	83 ff 25             	cmp    $0x25,%edi
  800572:	74 18                	je     80058c <vprintfmt+0x4f>
      if (ch == '\0')
  800574:	85 ff                	test   %edi,%edi
  800576:	0f 84 8c 06 00 00    	je     800c08 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80057c:	4c 89 fe             	mov    %r15,%rsi
  80057f:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800582:	49 89 de             	mov    %rbx,%r14
  800585:	eb e0                	jmp    800567 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800587:	49 89 de             	mov    %rbx,%r14
  80058a:	eb db                	jmp    800567 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80058c:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800590:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800594:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80059b:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8005a1:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8005a5:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005aa:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005b0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005b6:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005bb:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005c0:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005c4:	0f b6 13             	movzbl (%rbx),%edx
  8005c7:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005ca:	3c 55                	cmp    $0x55,%al
  8005cc:	0f 87 8b 05 00 00    	ja     800b5d <vprintfmt+0x620>
  8005d2:	0f b6 c0             	movzbl %al,%eax
  8005d5:	49 bb a0 12 80 00 00 	movabs $0x8012a0,%r11
  8005dc:	00 00 00 
  8005df:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005e3:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005e6:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005ea:	eb d4                	jmp    8005c0 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005ec:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005ef:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005f3:	eb cb                	jmp    8005c0 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005f5:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005f8:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005fc:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800600:	8d 50 d0             	lea    -0x30(%rax),%edx
  800603:	83 fa 09             	cmp    $0x9,%edx
  800606:	77 7e                	ja     800686 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800608:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80060c:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800610:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800615:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800619:	8d 50 d0             	lea    -0x30(%rax),%edx
  80061c:	83 fa 09             	cmp    $0x9,%edx
  80061f:	76 e7                	jbe    800608 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800621:	4c 89 f3             	mov    %r14,%rbx
  800624:	eb 19                	jmp    80063f <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800626:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800629:	83 f8 2f             	cmp    $0x2f,%eax
  80062c:	77 2a                	ja     800658 <vprintfmt+0x11b>
  80062e:	89 c2                	mov    %eax,%edx
  800630:	4c 01 d2             	add    %r10,%rdx
  800633:	83 c0 08             	add    $0x8,%eax
  800636:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800639:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80063c:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80063f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800643:	0f 89 77 ff ff ff    	jns    8005c0 <vprintfmt+0x83>
          width = precision, precision = -1;
  800649:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80064d:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800653:	e9 68 ff ff ff       	jmpq   8005c0 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800658:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80065c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800660:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800664:	eb d3                	jmp    800639 <vprintfmt+0xfc>
        if (width < 0)
  800666:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800669:	85 c0                	test   %eax,%eax
  80066b:	41 0f 48 c0          	cmovs  %r8d,%eax
  80066f:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800672:	4c 89 f3             	mov    %r14,%rbx
  800675:	e9 46 ff ff ff       	jmpq   8005c0 <vprintfmt+0x83>
  80067a:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80067d:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800681:	e9 3a ff ff ff       	jmpq   8005c0 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800686:	4c 89 f3             	mov    %r14,%rbx
  800689:	eb b4                	jmp    80063f <vprintfmt+0x102>
        lflag++;
  80068b:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80068e:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800691:	e9 2a ff ff ff       	jmpq   8005c0 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800696:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800699:	83 f8 2f             	cmp    $0x2f,%eax
  80069c:	77 19                	ja     8006b7 <vprintfmt+0x17a>
  80069e:	89 c2                	mov    %eax,%edx
  8006a0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006a4:	83 c0 08             	add    $0x8,%eax
  8006a7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006aa:	4c 89 fe             	mov    %r15,%rsi
  8006ad:	8b 3a                	mov    (%rdx),%edi
  8006af:	41 ff d5             	callq  *%r13
        break;
  8006b2:	e9 b0 fe ff ff       	jmpq   800567 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006b7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006bb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006bf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006c3:	eb e5                	jmp    8006aa <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006c5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006c8:	83 f8 2f             	cmp    $0x2f,%eax
  8006cb:	77 5b                	ja     800728 <vprintfmt+0x1eb>
  8006cd:	89 c2                	mov    %eax,%edx
  8006cf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006d3:	83 c0 08             	add    $0x8,%eax
  8006d6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006d9:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006db:	89 c8                	mov    %ecx,%eax
  8006dd:	c1 f8 1f             	sar    $0x1f,%eax
  8006e0:	31 c1                	xor    %eax,%ecx
  8006e2:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e4:	83 f9 09             	cmp    $0x9,%ecx
  8006e7:	7f 4d                	jg     800736 <vprintfmt+0x1f9>
  8006e9:	48 63 c1             	movslq %ecx,%rax
  8006ec:	48 ba 60 15 80 00 00 	movabs $0x801560,%rdx
  8006f3:	00 00 00 
  8006f6:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006fa:	48 85 c0             	test   %rax,%rax
  8006fd:	74 37                	je     800736 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006ff:	48 89 c1             	mov    %rax,%rcx
  800702:	48 ba 11 12 80 00 00 	movabs $0x801211,%rdx
  800709:	00 00 00 
  80070c:	4c 89 fe             	mov    %r15,%rsi
  80070f:	4c 89 ef             	mov    %r13,%rdi
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	48 bb b7 04 80 00 00 	movabs $0x8004b7,%rbx
  80071e:	00 00 00 
  800721:	ff d3                	callq  *%rbx
  800723:	e9 3f fe ff ff       	jmpq   800567 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800728:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80072c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800730:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800734:	eb a3                	jmp    8006d9 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800736:	48 ba 08 12 80 00 00 	movabs $0x801208,%rdx
  80073d:	00 00 00 
  800740:	4c 89 fe             	mov    %r15,%rsi
  800743:	4c 89 ef             	mov    %r13,%rdi
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	48 bb b7 04 80 00 00 	movabs $0x8004b7,%rbx
  800752:	00 00 00 
  800755:	ff d3                	callq  *%rbx
  800757:	e9 0b fe ff ff       	jmpq   800567 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80075c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80075f:	83 f8 2f             	cmp    $0x2f,%eax
  800762:	77 4b                	ja     8007af <vprintfmt+0x272>
  800764:	89 c2                	mov    %eax,%edx
  800766:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80076a:	83 c0 08             	add    $0x8,%eax
  80076d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800770:	48 8b 02             	mov    (%rdx),%rax
  800773:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800777:	48 85 c0             	test   %rax,%rax
  80077a:	0f 84 05 04 00 00    	je     800b85 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800780:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800784:	7e 06                	jle    80078c <vprintfmt+0x24f>
  800786:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80078a:	75 31                	jne    8007bd <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800790:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800794:	0f b6 00             	movzbl (%rax),%eax
  800797:	0f be f8             	movsbl %al,%edi
  80079a:	85 ff                	test   %edi,%edi
  80079c:	0f 84 c3 00 00 00    	je     800865 <vprintfmt+0x328>
  8007a2:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8007a6:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007aa:	e9 85 00 00 00       	jmpq   800834 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007af:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007b3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007b7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007bb:	eb b3                	jmp    800770 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007bd:	49 63 f4             	movslq %r12d,%rsi
  8007c0:	48 89 c7             	mov    %rax,%rdi
  8007c3:	48 b8 14 0d 80 00 00 	movabs $0x800d14,%rax
  8007ca:	00 00 00 
  8007cd:	ff d0                	callq  *%rax
  8007cf:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007d2:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007d5:	85 f6                	test   %esi,%esi
  8007d7:	7e 22                	jle    8007fb <vprintfmt+0x2be>
            putch(padc, putdat);
  8007d9:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007dd:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007e1:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007e5:	4c 89 fe             	mov    %r15,%rsi
  8007e8:	89 df                	mov    %ebx,%edi
  8007ea:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007ed:	41 83 ec 01          	sub    $0x1,%r12d
  8007f1:	75 f2                	jne    8007e5 <vprintfmt+0x2a8>
  8007f3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007f7:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fb:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007ff:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800803:	0f b6 00             	movzbl (%rax),%eax
  800806:	0f be f8             	movsbl %al,%edi
  800809:	85 ff                	test   %edi,%edi
  80080b:	0f 84 56 fd ff ff    	je     800567 <vprintfmt+0x2a>
  800811:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800815:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800819:	eb 19                	jmp    800834 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80081b:	4c 89 fe             	mov    %r15,%rsi
  80081e:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800821:	41 83 ee 01          	sub    $0x1,%r14d
  800825:	48 83 c3 01          	add    $0x1,%rbx
  800829:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80082d:	0f be f8             	movsbl %al,%edi
  800830:	85 ff                	test   %edi,%edi
  800832:	74 29                	je     80085d <vprintfmt+0x320>
  800834:	45 85 e4             	test   %r12d,%r12d
  800837:	78 06                	js     80083f <vprintfmt+0x302>
  800839:	41 83 ec 01          	sub    $0x1,%r12d
  80083d:	78 48                	js     800887 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80083f:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800843:	74 d6                	je     80081b <vprintfmt+0x2de>
  800845:	0f be c0             	movsbl %al,%eax
  800848:	83 e8 20             	sub    $0x20,%eax
  80084b:	83 f8 5e             	cmp    $0x5e,%eax
  80084e:	76 cb                	jbe    80081b <vprintfmt+0x2de>
            putch('?', putdat);
  800850:	4c 89 fe             	mov    %r15,%rsi
  800853:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800858:	41 ff d5             	callq  *%r13
  80085b:	eb c4                	jmp    800821 <vprintfmt+0x2e4>
  80085d:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800861:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800865:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800868:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80086c:	0f 8e f5 fc ff ff    	jle    800567 <vprintfmt+0x2a>
          putch(' ', putdat);
  800872:	4c 89 fe             	mov    %r15,%rsi
  800875:	bf 20 00 00 00       	mov    $0x20,%edi
  80087a:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80087d:	83 eb 01             	sub    $0x1,%ebx
  800880:	75 f0                	jne    800872 <vprintfmt+0x335>
  800882:	e9 e0 fc ff ff       	jmpq   800567 <vprintfmt+0x2a>
  800887:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80088b:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80088f:	eb d4                	jmp    800865 <vprintfmt+0x328>
  if (lflag >= 2)
  800891:	83 f9 01             	cmp    $0x1,%ecx
  800894:	7f 1d                	jg     8008b3 <vprintfmt+0x376>
  else if (lflag)
  800896:	85 c9                	test   %ecx,%ecx
  800898:	74 5e                	je     8008f8 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80089a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089d:	83 f8 2f             	cmp    $0x2f,%eax
  8008a0:	77 48                	ja     8008ea <vprintfmt+0x3ad>
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a8:	83 c0 08             	add    $0x8,%eax
  8008ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ae:	48 8b 1a             	mov    (%rdx),%rbx
  8008b1:	eb 17                	jmp    8008ca <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008b3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b6:	83 f8 2f             	cmp    $0x2f,%eax
  8008b9:	77 21                	ja     8008dc <vprintfmt+0x39f>
  8008bb:	89 c2                	mov    %eax,%edx
  8008bd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008c1:	83 c0 08             	add    $0x8,%eax
  8008c4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c7:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008ca:	48 85 db             	test   %rbx,%rbx
  8008cd:	78 50                	js     80091f <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008cf:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008d7:	e9 b4 01 00 00       	jmpq   800a90 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008dc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e8:	eb dd                	jmp    8008c7 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008ea:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ee:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008f2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008f6:	eb b6                	jmp    8008ae <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008f8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008fb:	83 f8 2f             	cmp    $0x2f,%eax
  8008fe:	77 11                	ja     800911 <vprintfmt+0x3d4>
  800900:	89 c2                	mov    %eax,%edx
  800902:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800906:	83 c0 08             	add    $0x8,%eax
  800909:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80090c:	48 63 1a             	movslq (%rdx),%rbx
  80090f:	eb b9                	jmp    8008ca <vprintfmt+0x38d>
  800911:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800915:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800919:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091d:	eb ed                	jmp    80090c <vprintfmt+0x3cf>
          putch('-', putdat);
  80091f:	4c 89 fe             	mov    %r15,%rsi
  800922:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800927:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80092a:	48 89 da             	mov    %rbx,%rdx
  80092d:	48 f7 da             	neg    %rdx
        base = 10;
  800930:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800935:	e9 56 01 00 00       	jmpq   800a90 <vprintfmt+0x553>
  if (lflag >= 2)
  80093a:	83 f9 01             	cmp    $0x1,%ecx
  80093d:	7f 25                	jg     800964 <vprintfmt+0x427>
  else if (lflag)
  80093f:	85 c9                	test   %ecx,%ecx
  800941:	74 5e                	je     8009a1 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800943:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800946:	83 f8 2f             	cmp    $0x2f,%eax
  800949:	77 48                	ja     800993 <vprintfmt+0x456>
  80094b:	89 c2                	mov    %eax,%edx
  80094d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800951:	83 c0 08             	add    $0x8,%eax
  800954:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800957:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80095a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80095f:	e9 2c 01 00 00       	jmpq   800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800964:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800967:	83 f8 2f             	cmp    $0x2f,%eax
  80096a:	77 19                	ja     800985 <vprintfmt+0x448>
  80096c:	89 c2                	mov    %eax,%edx
  80096e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800972:	83 c0 08             	add    $0x8,%eax
  800975:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800978:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80097b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800980:	e9 0b 01 00 00       	jmpq   800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800985:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800989:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80098d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800991:	eb e5                	jmp    800978 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800993:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800997:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099f:	eb b6                	jmp    800957 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8009a1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a4:	83 f8 2f             	cmp    $0x2f,%eax
  8009a7:	77 18                	ja     8009c1 <vprintfmt+0x484>
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009af:	83 c0 08             	add    $0x8,%eax
  8009b2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b5:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009bc:	e9 cf 00 00 00       	jmpq   800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009c1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009c5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009cd:	eb e6                	jmp    8009b5 <vprintfmt+0x478>
  if (lflag >= 2)
  8009cf:	83 f9 01             	cmp    $0x1,%ecx
  8009d2:	7f 25                	jg     8009f9 <vprintfmt+0x4bc>
  else if (lflag)
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	74 5b                	je     800a33 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009d8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009db:	83 f8 2f             	cmp    $0x2f,%eax
  8009de:	77 45                	ja     800a25 <vprintfmt+0x4e8>
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e6:	83 c0 08             	add    $0x8,%eax
  8009e9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ec:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009ef:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f4:	e9 97 00 00 00       	jmpq   800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009fc:	83 f8 2f             	cmp    $0x2f,%eax
  8009ff:	77 16                	ja     800a17 <vprintfmt+0x4da>
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a07:	83 c0 08             	add    $0x8,%eax
  800a0a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a0d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a10:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a15:	eb 79                	jmp    800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a17:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a1b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a23:	eb e8                	jmp    800a0d <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a25:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a29:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a2d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a31:	eb b9                	jmp    8009ec <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a33:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a36:	83 f8 2f             	cmp    $0x2f,%eax
  800a39:	77 15                	ja     800a50 <vprintfmt+0x513>
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a41:	83 c0 08             	add    $0x8,%eax
  800a44:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a47:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a49:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a4e:	eb 40                	jmp    800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a50:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a54:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a58:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a5c:	eb e9                	jmp    800a47 <vprintfmt+0x50a>
        putch('0', putdat);
  800a5e:	4c 89 fe             	mov    %r15,%rsi
  800a61:	bf 30 00 00 00       	mov    $0x30,%edi
  800a66:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a69:	4c 89 fe             	mov    %r15,%rsi
  800a6c:	bf 78 00 00 00       	mov    $0x78,%edi
  800a71:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a74:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a77:	83 f8 2f             	cmp    $0x2f,%eax
  800a7a:	77 34                	ja     800ab0 <vprintfmt+0x573>
  800a7c:	89 c2                	mov    %eax,%edx
  800a7e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a82:	83 c0 08             	add    $0x8,%eax
  800a85:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a88:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a8b:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a90:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a95:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a99:	4c 89 fe             	mov    %r15,%rsi
  800a9c:	4c 89 ef             	mov    %r13,%rdi
  800a9f:	48 b8 13 04 80 00 00 	movabs $0x800413,%rax
  800aa6:	00 00 00 
  800aa9:	ff d0                	callq  *%rax
        break;
  800aab:	e9 b7 fa ff ff       	jmpq   800567 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ab0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ab4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800abc:	eb ca                	jmp    800a88 <vprintfmt+0x54b>
  if (lflag >= 2)
  800abe:	83 f9 01             	cmp    $0x1,%ecx
  800ac1:	7f 22                	jg     800ae5 <vprintfmt+0x5a8>
  else if (lflag)
  800ac3:	85 c9                	test   %ecx,%ecx
  800ac5:	74 58                	je     800b1f <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800ac7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aca:	83 f8 2f             	cmp    $0x2f,%eax
  800acd:	77 42                	ja     800b11 <vprintfmt+0x5d4>
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ad5:	83 c0 08             	add    $0x8,%eax
  800ad8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800adb:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ade:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ae3:	eb ab                	jmp    800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ae5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae8:	83 f8 2f             	cmp    $0x2f,%eax
  800aeb:	77 16                	ja     800b03 <vprintfmt+0x5c6>
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af3:	83 c0 08             	add    $0x8,%eax
  800af6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af9:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800afc:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b01:	eb 8d                	jmp    800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b03:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b07:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b0b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b0f:	eb e8                	jmp    800af9 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b11:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b15:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b19:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b1d:	eb bc                	jmp    800adb <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b1f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b22:	83 f8 2f             	cmp    $0x2f,%eax
  800b25:	77 18                	ja     800b3f <vprintfmt+0x602>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b2d:	83 c0 08             	add    $0x8,%eax
  800b30:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b33:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b35:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b3a:	e9 51 ff ff ff       	jmpq   800a90 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b3f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b43:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b47:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b4b:	eb e6                	jmp    800b33 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b4d:	4c 89 fe             	mov    %r15,%rsi
  800b50:	bf 25 00 00 00       	mov    $0x25,%edi
  800b55:	41 ff d5             	callq  *%r13
        break;
  800b58:	e9 0a fa ff ff       	jmpq   800567 <vprintfmt+0x2a>
        putch('%', putdat);
  800b5d:	4c 89 fe             	mov    %r15,%rsi
  800b60:	bf 25 00 00 00       	mov    $0x25,%edi
  800b65:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b68:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b6c:	0f 84 15 fa ff ff    	je     800587 <vprintfmt+0x4a>
  800b72:	49 89 de             	mov    %rbx,%r14
  800b75:	49 83 ee 01          	sub    $0x1,%r14
  800b79:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b7e:	75 f5                	jne    800b75 <vprintfmt+0x638>
  800b80:	e9 e2 f9 ff ff       	jmpq   800567 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b85:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b89:	74 06                	je     800b91 <vprintfmt+0x654>
  800b8b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b8f:	7f 21                	jg     800bb2 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b91:	bf 28 00 00 00       	mov    $0x28,%edi
  800b96:	48 bb 02 12 80 00 00 	movabs $0x801202,%rbx
  800b9d:	00 00 00 
  800ba0:	b8 28 00 00 00       	mov    $0x28,%eax
  800ba5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ba9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bad:	e9 82 fc ff ff       	jmpq   800834 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800bb2:	49 63 f4             	movslq %r12d,%rsi
  800bb5:	48 bf 01 12 80 00 00 	movabs $0x801201,%rdi
  800bbc:	00 00 00 
  800bbf:	48 b8 14 0d 80 00 00 	movabs $0x800d14,%rax
  800bc6:	00 00 00 
  800bc9:	ff d0                	callq  *%rax
  800bcb:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bce:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bd1:	48 be 01 12 80 00 00 	movabs $0x801201,%rsi
  800bd8:	00 00 00 
  800bdb:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	0f 8f f2 fb ff ff    	jg     8007d9 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800be7:	48 bb 02 12 80 00 00 	movabs $0x801202,%rbx
  800bee:	00 00 00 
  800bf1:	b8 28 00 00 00       	mov    $0x28,%eax
  800bf6:	bf 28 00 00 00       	mov    $0x28,%edi
  800bfb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bff:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800c03:	e9 2c fc ff ff       	jmpq   800834 <vprintfmt+0x2f7>
}
  800c08:	48 83 c4 48          	add    $0x48,%rsp
  800c0c:	5b                   	pop    %rbx
  800c0d:	41 5c                	pop    %r12
  800c0f:	41 5d                	pop    %r13
  800c11:	41 5e                	pop    %r14
  800c13:	41 5f                	pop    %r15
  800c15:	5d                   	pop    %rbp
  800c16:	c3                   	retq   

0000000000800c17 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c17:	55                   	push   %rbp
  800c18:	48 89 e5             	mov    %rsp,%rbp
  800c1b:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c1f:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c23:	48 63 c6             	movslq %esi,%rax
  800c26:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c2b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c2f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c36:	48 85 ff             	test   %rdi,%rdi
  800c39:	74 2a                	je     800c65 <vsnprintf+0x4e>
  800c3b:	85 f6                	test   %esi,%esi
  800c3d:	7e 26                	jle    800c65 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c3f:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c43:	48 bf 9f 04 80 00 00 	movabs $0x80049f,%rdi
  800c4a:	00 00 00 
  800c4d:	48 b8 3d 05 80 00 00 	movabs $0x80053d,%rax
  800c54:	00 00 00 
  800c57:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c59:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c5d:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c60:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c63:	c9                   	leaveq 
  800c64:	c3                   	retq   
    return -E_INVAL;
  800c65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c6a:	eb f7                	jmp    800c63 <vsnprintf+0x4c>

0000000000800c6c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c6c:	55                   	push   %rbp
  800c6d:	48 89 e5             	mov    %rsp,%rbp
  800c70:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c77:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c7e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c85:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c8c:	84 c0                	test   %al,%al
  800c8e:	74 20                	je     800cb0 <snprintf+0x44>
  800c90:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c94:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c98:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c9c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800ca0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ca4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ca8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800cac:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800cb0:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800cb7:	00 00 00 
  800cba:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800cc1:	00 00 00 
  800cc4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cc8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800ccf:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cd6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cdd:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800ce4:	48 b8 17 0c 80 00 00 	movabs $0x800c17,%rax
  800ceb:	00 00 00 
  800cee:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800cf0:	c9                   	leaveq 
  800cf1:	c3                   	retq   

0000000000800cf2 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cf2:	80 3f 00             	cmpb   $0x0,(%rdi)
  800cf5:	74 17                	je     800d0e <strlen+0x1c>
  800cf7:	48 89 fa             	mov    %rdi,%rdx
  800cfa:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cff:	29 f9                	sub    %edi,%ecx
    n++;
  800d01:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800d04:	48 83 c2 01          	add    $0x1,%rdx
  800d08:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d0b:	75 f4                	jne    800d01 <strlen+0xf>
  800d0d:	c3                   	retq   
  800d0e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d13:	c3                   	retq   

0000000000800d14 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d14:	48 85 f6             	test   %rsi,%rsi
  800d17:	74 24                	je     800d3d <strnlen+0x29>
  800d19:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d1c:	74 25                	je     800d43 <strnlen+0x2f>
  800d1e:	48 01 fe             	add    %rdi,%rsi
  800d21:	48 89 fa             	mov    %rdi,%rdx
  800d24:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d29:	29 f9                	sub    %edi,%ecx
    n++;
  800d2b:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2e:	48 83 c2 01          	add    $0x1,%rdx
  800d32:	48 39 f2             	cmp    %rsi,%rdx
  800d35:	74 11                	je     800d48 <strnlen+0x34>
  800d37:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d3a:	75 ef                	jne    800d2b <strnlen+0x17>
  800d3c:	c3                   	retq   
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d42:	c3                   	retq   
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d48:	c3                   	retq   

0000000000800d49 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d49:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d51:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d55:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d58:	48 83 c2 01          	add    $0x1,%rdx
  800d5c:	84 c9                	test   %cl,%cl
  800d5e:	75 f1                	jne    800d51 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d60:	c3                   	retq   

0000000000800d61 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d61:	55                   	push   %rbp
  800d62:	48 89 e5             	mov    %rsp,%rbp
  800d65:	41 54                	push   %r12
  800d67:	53                   	push   %rbx
  800d68:	48 89 fb             	mov    %rdi,%rbx
  800d6b:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d6e:	48 b8 f2 0c 80 00 00 	movabs $0x800cf2,%rax
  800d75:	00 00 00 
  800d78:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d7a:	48 63 f8             	movslq %eax,%rdi
  800d7d:	48 01 df             	add    %rbx,%rdi
  800d80:	4c 89 e6             	mov    %r12,%rsi
  800d83:	48 b8 49 0d 80 00 00 	movabs $0x800d49,%rax
  800d8a:	00 00 00 
  800d8d:	ff d0                	callq  *%rax
  return dst;
}
  800d8f:	48 89 d8             	mov    %rbx,%rax
  800d92:	5b                   	pop    %rbx
  800d93:	41 5c                	pop    %r12
  800d95:	5d                   	pop    %rbp
  800d96:	c3                   	retq   

0000000000800d97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d97:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d9a:	48 85 d2             	test   %rdx,%rdx
  800d9d:	74 1f                	je     800dbe <strncpy+0x27>
  800d9f:	48 01 fa             	add    %rdi,%rdx
  800da2:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800da5:	48 83 c1 01          	add    $0x1,%rcx
  800da9:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dad:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800db1:	41 80 f8 01          	cmp    $0x1,%r8b
  800db5:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800db9:	48 39 ca             	cmp    %rcx,%rdx
  800dbc:	75 e7                	jne    800da5 <strncpy+0xe>
  }
  return ret;
}
  800dbe:	c3                   	retq   

0000000000800dbf <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800dbf:	48 89 f8             	mov    %rdi,%rax
  800dc2:	48 85 d2             	test   %rdx,%rdx
  800dc5:	74 36                	je     800dfd <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800dc7:	48 83 fa 01          	cmp    $0x1,%rdx
  800dcb:	74 2d                	je     800dfa <strlcpy+0x3b>
  800dcd:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dd1:	45 84 c0             	test   %r8b,%r8b
  800dd4:	74 24                	je     800dfa <strlcpy+0x3b>
  800dd6:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dda:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800ddf:	48 83 c0 01          	add    $0x1,%rax
  800de3:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800de7:	48 39 d1             	cmp    %rdx,%rcx
  800dea:	74 0e                	je     800dfa <strlcpy+0x3b>
  800dec:	48 83 c1 01          	add    $0x1,%rcx
  800df0:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800df5:	45 84 c0             	test   %r8b,%r8b
  800df8:	75 e5                	jne    800ddf <strlcpy+0x20>
    *dst = '\0';
  800dfa:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800dfd:	48 29 f8             	sub    %rdi,%rax
}
  800e00:	c3                   	retq   

0000000000800e01 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800e01:	0f b6 07             	movzbl (%rdi),%eax
  800e04:	84 c0                	test   %al,%al
  800e06:	74 17                	je     800e1f <strcmp+0x1e>
  800e08:	3a 06                	cmp    (%rsi),%al
  800e0a:	75 13                	jne    800e1f <strcmp+0x1e>
    p++, q++;
  800e0c:	48 83 c7 01          	add    $0x1,%rdi
  800e10:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e14:	0f b6 07             	movzbl (%rdi),%eax
  800e17:	84 c0                	test   %al,%al
  800e19:	74 04                	je     800e1f <strcmp+0x1e>
  800e1b:	3a 06                	cmp    (%rsi),%al
  800e1d:	74 ed                	je     800e0c <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e1f:	0f b6 c0             	movzbl %al,%eax
  800e22:	0f b6 16             	movzbl (%rsi),%edx
  800e25:	29 d0                	sub    %edx,%eax
}
  800e27:	c3                   	retq   

0000000000800e28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e28:	48 85 d2             	test   %rdx,%rdx
  800e2b:	74 2f                	je     800e5c <strncmp+0x34>
  800e2d:	0f b6 07             	movzbl (%rdi),%eax
  800e30:	84 c0                	test   %al,%al
  800e32:	74 1f                	je     800e53 <strncmp+0x2b>
  800e34:	3a 06                	cmp    (%rsi),%al
  800e36:	75 1b                	jne    800e53 <strncmp+0x2b>
  800e38:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e3b:	48 83 c7 01          	add    $0x1,%rdi
  800e3f:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e43:	48 39 d7             	cmp    %rdx,%rdi
  800e46:	74 1a                	je     800e62 <strncmp+0x3a>
  800e48:	0f b6 07             	movzbl (%rdi),%eax
  800e4b:	84 c0                	test   %al,%al
  800e4d:	74 04                	je     800e53 <strncmp+0x2b>
  800e4f:	3a 06                	cmp    (%rsi),%al
  800e51:	74 e8                	je     800e3b <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e53:	0f b6 07             	movzbl (%rdi),%eax
  800e56:	0f b6 16             	movzbl (%rsi),%edx
  800e59:	29 d0                	sub    %edx,%eax
}
  800e5b:	c3                   	retq   
    return 0;
  800e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e61:	c3                   	retq   
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	c3                   	retq   

0000000000800e68 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e68:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e6a:	0f b6 07             	movzbl (%rdi),%eax
  800e6d:	84 c0                	test   %al,%al
  800e6f:	74 1e                	je     800e8f <strchr+0x27>
    if (*s == c)
  800e71:	40 38 c6             	cmp    %al,%sil
  800e74:	74 1f                	je     800e95 <strchr+0x2d>
  for (; *s; s++)
  800e76:	48 83 c7 01          	add    $0x1,%rdi
  800e7a:	0f b6 07             	movzbl (%rdi),%eax
  800e7d:	84 c0                	test   %al,%al
  800e7f:	74 08                	je     800e89 <strchr+0x21>
    if (*s == c)
  800e81:	38 d0                	cmp    %dl,%al
  800e83:	75 f1                	jne    800e76 <strchr+0xe>
  for (; *s; s++)
  800e85:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e88:	c3                   	retq   
  return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	c3                   	retq   
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	c3                   	retq   
    if (*s == c)
  800e95:	48 89 f8             	mov    %rdi,%rax
  800e98:	c3                   	retq   

0000000000800e99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e99:	48 89 f8             	mov    %rdi,%rax
  800e9c:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e9e:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800ea1:	40 38 f2             	cmp    %sil,%dl
  800ea4:	74 13                	je     800eb9 <strfind+0x20>
  800ea6:	84 d2                	test   %dl,%dl
  800ea8:	74 0f                	je     800eb9 <strfind+0x20>
  for (; *s; s++)
  800eaa:	48 83 c0 01          	add    $0x1,%rax
  800eae:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800eb1:	38 ca                	cmp    %cl,%dl
  800eb3:	74 04                	je     800eb9 <strfind+0x20>
  800eb5:	84 d2                	test   %dl,%dl
  800eb7:	75 f1                	jne    800eaa <strfind+0x11>
      break;
  return (char *)s;
}
  800eb9:	c3                   	retq   

0000000000800eba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800eba:	48 85 d2             	test   %rdx,%rdx
  800ebd:	74 3a                	je     800ef9 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ebf:	48 89 f8             	mov    %rdi,%rax
  800ec2:	48 09 d0             	or     %rdx,%rax
  800ec5:	a8 03                	test   $0x3,%al
  800ec7:	75 28                	jne    800ef1 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ec9:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800ecd:	89 f0                	mov    %esi,%eax
  800ecf:	c1 e0 08             	shl    $0x8,%eax
  800ed2:	89 f1                	mov    %esi,%ecx
  800ed4:	c1 e1 18             	shl    $0x18,%ecx
  800ed7:	41 89 f0             	mov    %esi,%r8d
  800eda:	41 c1 e0 10          	shl    $0x10,%r8d
  800ede:	44 09 c1             	or     %r8d,%ecx
  800ee1:	09 ce                	or     %ecx,%esi
  800ee3:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800ee5:	48 c1 ea 02          	shr    $0x2,%rdx
  800ee9:	48 89 d1             	mov    %rdx,%rcx
  800eec:	fc                   	cld    
  800eed:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eef:	eb 08                	jmp    800ef9 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	48 89 d1             	mov    %rdx,%rcx
  800ef6:	fc                   	cld    
  800ef7:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ef9:	48 89 f8             	mov    %rdi,%rax
  800efc:	c3                   	retq   

0000000000800efd <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800efd:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800f00:	48 39 fe             	cmp    %rdi,%rsi
  800f03:	73 40                	jae    800f45 <memmove+0x48>
  800f05:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f09:	48 39 f9             	cmp    %rdi,%rcx
  800f0c:	76 37                	jbe    800f45 <memmove+0x48>
    s += n;
    d += n;
  800f0e:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f12:	48 89 fe             	mov    %rdi,%rsi
  800f15:	48 09 d6             	or     %rdx,%rsi
  800f18:	48 09 ce             	or     %rcx,%rsi
  800f1b:	40 f6 c6 03          	test   $0x3,%sil
  800f1f:	75 14                	jne    800f35 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f21:	48 83 ef 04          	sub    $0x4,%rdi
  800f25:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f29:	48 c1 ea 02          	shr    $0x2,%rdx
  800f2d:	48 89 d1             	mov    %rdx,%rcx
  800f30:	fd                   	std    
  800f31:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f33:	eb 0e                	jmp    800f43 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f35:	48 83 ef 01          	sub    $0x1,%rdi
  800f39:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f3d:	48 89 d1             	mov    %rdx,%rcx
  800f40:	fd                   	std    
  800f41:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f43:	fc                   	cld    
  800f44:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f45:	48 89 c1             	mov    %rax,%rcx
  800f48:	48 09 d1             	or     %rdx,%rcx
  800f4b:	48 09 f1             	or     %rsi,%rcx
  800f4e:	f6 c1 03             	test   $0x3,%cl
  800f51:	75 0e                	jne    800f61 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f53:	48 c1 ea 02          	shr    $0x2,%rdx
  800f57:	48 89 d1             	mov    %rdx,%rcx
  800f5a:	48 89 c7             	mov    %rax,%rdi
  800f5d:	fc                   	cld    
  800f5e:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f60:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f61:	48 89 c7             	mov    %rax,%rdi
  800f64:	48 89 d1             	mov    %rdx,%rcx
  800f67:	fc                   	cld    
  800f68:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f6a:	c3                   	retq   

0000000000800f6b <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f6b:	55                   	push   %rbp
  800f6c:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f6f:	48 b8 fd 0e 80 00 00 	movabs $0x800efd,%rax
  800f76:	00 00 00 
  800f79:	ff d0                	callq  *%rax
}
  800f7b:	5d                   	pop    %rbp
  800f7c:	c3                   	retq   

0000000000800f7d <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f7d:	55                   	push   %rbp
  800f7e:	48 89 e5             	mov    %rsp,%rbp
  800f81:	41 57                	push   %r15
  800f83:	41 56                	push   %r14
  800f85:	41 55                	push   %r13
  800f87:	41 54                	push   %r12
  800f89:	53                   	push   %rbx
  800f8a:	48 83 ec 08          	sub    $0x8,%rsp
  800f8e:	49 89 fe             	mov    %rdi,%r14
  800f91:	49 89 f7             	mov    %rsi,%r15
  800f94:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f97:	48 89 f7             	mov    %rsi,%rdi
  800f9a:	48 b8 f2 0c 80 00 00 	movabs $0x800cf2,%rax
  800fa1:	00 00 00 
  800fa4:	ff d0                	callq  *%rax
  800fa6:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800fa9:	4c 89 ee             	mov    %r13,%rsi
  800fac:	4c 89 f7             	mov    %r14,%rdi
  800faf:	48 b8 14 0d 80 00 00 	movabs $0x800d14,%rax
  800fb6:	00 00 00 
  800fb9:	ff d0                	callq  *%rax
  800fbb:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fbe:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fc2:	4d 39 e5             	cmp    %r12,%r13
  800fc5:	74 26                	je     800fed <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fc7:	4c 89 e8             	mov    %r13,%rax
  800fca:	4c 29 e0             	sub    %r12,%rax
  800fcd:	48 39 d8             	cmp    %rbx,%rax
  800fd0:	76 2a                	jbe    800ffc <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fd2:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fd6:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fda:	4c 89 fe             	mov    %r15,%rsi
  800fdd:	48 b8 6b 0f 80 00 00 	movabs $0x800f6b,%rax
  800fe4:	00 00 00 
  800fe7:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fe9:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fed:	48 83 c4 08          	add    $0x8,%rsp
  800ff1:	5b                   	pop    %rbx
  800ff2:	41 5c                	pop    %r12
  800ff4:	41 5d                	pop    %r13
  800ff6:	41 5e                	pop    %r14
  800ff8:	41 5f                	pop    %r15
  800ffa:	5d                   	pop    %rbp
  800ffb:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800ffc:	49 83 ed 01          	sub    $0x1,%r13
  801000:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801004:	4c 89 ea             	mov    %r13,%rdx
  801007:	4c 89 fe             	mov    %r15,%rsi
  80100a:	48 b8 6b 0f 80 00 00 	movabs $0x800f6b,%rax
  801011:	00 00 00 
  801014:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801016:	4d 01 ee             	add    %r13,%r14
  801019:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80101e:	eb c9                	jmp    800fe9 <strlcat+0x6c>

0000000000801020 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801020:	48 85 d2             	test   %rdx,%rdx
  801023:	74 3a                	je     80105f <memcmp+0x3f>
    if (*s1 != *s2)
  801025:	0f b6 0f             	movzbl (%rdi),%ecx
  801028:	44 0f b6 06          	movzbl (%rsi),%r8d
  80102c:	44 38 c1             	cmp    %r8b,%cl
  80102f:	75 1d                	jne    80104e <memcmp+0x2e>
  801031:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801036:	48 39 d0             	cmp    %rdx,%rax
  801039:	74 1e                	je     801059 <memcmp+0x39>
    if (*s1 != *s2)
  80103b:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80103f:	48 83 c0 01          	add    $0x1,%rax
  801043:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801049:	44 38 c1             	cmp    %r8b,%cl
  80104c:	74 e8                	je     801036 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80104e:	0f b6 c1             	movzbl %cl,%eax
  801051:	45 0f b6 c0          	movzbl %r8b,%r8d
  801055:	44 29 c0             	sub    %r8d,%eax
  801058:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801059:	b8 00 00 00 00       	mov    $0x0,%eax
  80105e:	c3                   	retq   
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801064:	c3                   	retq   

0000000000801065 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801065:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801069:	48 39 c7             	cmp    %rax,%rdi
  80106c:	73 19                	jae    801087 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80106e:	89 f2                	mov    %esi,%edx
  801070:	40 38 37             	cmp    %sil,(%rdi)
  801073:	74 16                	je     80108b <memfind+0x26>
  for (; s < ends; s++)
  801075:	48 83 c7 01          	add    $0x1,%rdi
  801079:	48 39 f8             	cmp    %rdi,%rax
  80107c:	74 08                	je     801086 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80107e:	38 17                	cmp    %dl,(%rdi)
  801080:	75 f3                	jne    801075 <memfind+0x10>
  for (; s < ends; s++)
  801082:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801085:	c3                   	retq   
  801086:	c3                   	retq   
  for (; s < ends; s++)
  801087:	48 89 f8             	mov    %rdi,%rax
  80108a:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80108b:	48 89 f8             	mov    %rdi,%rax
  80108e:	c3                   	retq   

000000000080108f <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80108f:	0f b6 07             	movzbl (%rdi),%eax
  801092:	3c 20                	cmp    $0x20,%al
  801094:	74 04                	je     80109a <strtol+0xb>
  801096:	3c 09                	cmp    $0x9,%al
  801098:	75 0f                	jne    8010a9 <strtol+0x1a>
    s++;
  80109a:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80109e:	0f b6 07             	movzbl (%rdi),%eax
  8010a1:	3c 20                	cmp    $0x20,%al
  8010a3:	74 f5                	je     80109a <strtol+0xb>
  8010a5:	3c 09                	cmp    $0x9,%al
  8010a7:	74 f1                	je     80109a <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010a9:	3c 2b                	cmp    $0x2b,%al
  8010ab:	74 2b                	je     8010d8 <strtol+0x49>
  int neg  = 0;
  8010ad:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010b3:	3c 2d                	cmp    $0x2d,%al
  8010b5:	74 2d                	je     8010e4 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b7:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010bd:	75 0f                	jne    8010ce <strtol+0x3f>
  8010bf:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010c2:	74 2c                	je     8010f0 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010c4:	85 d2                	test   %edx,%edx
  8010c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010cb:	0f 44 d0             	cmove  %eax,%edx
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010d3:	4c 63 d2             	movslq %edx,%r10
  8010d6:	eb 5c                	jmp    801134 <strtol+0xa5>
    s++;
  8010d8:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010dc:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010e2:	eb d3                	jmp    8010b7 <strtol+0x28>
    s++, neg = 1;
  8010e4:	48 83 c7 01          	add    $0x1,%rdi
  8010e8:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010ee:	eb c7                	jmp    8010b7 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010f0:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010f4:	74 0f                	je     801105 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010f6:	85 d2                	test   %edx,%edx
  8010f8:	75 d4                	jne    8010ce <strtol+0x3f>
    s++, base = 8;
  8010fa:	48 83 c7 01          	add    $0x1,%rdi
  8010fe:	ba 08 00 00 00       	mov    $0x8,%edx
  801103:	eb c9                	jmp    8010ce <strtol+0x3f>
    s += 2, base = 16;
  801105:	48 83 c7 02          	add    $0x2,%rdi
  801109:	ba 10 00 00 00       	mov    $0x10,%edx
  80110e:	eb be                	jmp    8010ce <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801110:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801114:	41 80 f8 19          	cmp    $0x19,%r8b
  801118:	77 2f                	ja     801149 <strtol+0xba>
      dig = *s - 'a' + 10;
  80111a:	44 0f be c1          	movsbl %cl,%r8d
  80111e:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801122:	39 d1                	cmp    %edx,%ecx
  801124:	7d 37                	jge    80115d <strtol+0xce>
    s++, val = (val * base) + dig;
  801126:	48 83 c7 01          	add    $0x1,%rdi
  80112a:	49 0f af c2          	imul   %r10,%rax
  80112e:	48 63 c9             	movslq %ecx,%rcx
  801131:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801134:	0f b6 0f             	movzbl (%rdi),%ecx
  801137:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80113b:	41 80 f8 09          	cmp    $0x9,%r8b
  80113f:	77 cf                	ja     801110 <strtol+0x81>
      dig = *s - '0';
  801141:	0f be c9             	movsbl %cl,%ecx
  801144:	83 e9 30             	sub    $0x30,%ecx
  801147:	eb d9                	jmp    801122 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801149:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80114d:	41 80 f8 19          	cmp    $0x19,%r8b
  801151:	77 0a                	ja     80115d <strtol+0xce>
      dig = *s - 'A' + 10;
  801153:	44 0f be c1          	movsbl %cl,%r8d
  801157:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80115b:	eb c5                	jmp    801122 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80115d:	48 85 f6             	test   %rsi,%rsi
  801160:	74 03                	je     801165 <strtol+0xd6>
    *endptr = (char *)s;
  801162:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801165:	48 89 c2             	mov    %rax,%rdx
  801168:	48 f7 da             	neg    %rdx
  80116b:	45 85 c9             	test   %r9d,%r9d
  80116e:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801172:	c3                   	retq   
  801173:	90                   	nop
