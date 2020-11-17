
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
  800038:	48 b8 17 01 80 00 00 	movabs $0x800117,%rax
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
  }

  // set thisenv to point at our Env structure in envs[].
  // LAB 8: Your code here.
  thisenv = &envs[ENVX(sys_getenvid())];
  800093:	48 b8 b5 01 80 00 00 	movabs $0x8001b5,%rax
  80009a:	00 00 00 
  80009d:	ff d0                	callq  *%rax
  80009f:	83 e0 1f             	and    $0x1f,%eax
  8000a2:	48 89 c2             	mov    %rax,%rdx
  8000a5:	48 c1 e2 05          	shl    $0x5,%rdx
  8000a9:	48 29 c2             	sub    %rax,%rdx
  8000ac:	48 89 d0             	mov    %rdx,%rax
  8000af:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000b6:	00 00 00 
  8000b9:	48 8d 04 c2          	lea    (%rdx,%rax,8),%rax
  8000bd:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000c4:	00 00 00 

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000c7:	45 85 ed             	test   %r13d,%r13d
  8000ca:	7e 0d                	jle    8000d9 <libmain+0x93>
    binaryname = argv[0];
  8000cc:	49 8b 06             	mov    (%r14),%rax
  8000cf:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000d6:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000d9:	4c 89 f6             	mov    %r14,%rsi
  8000dc:	44 89 ef             	mov    %r13d,%edi
  8000df:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000e6:	00 00 00 
  8000e9:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000eb:	48 b8 00 01 80 00 00 	movabs $0x800100,%rax
  8000f2:	00 00 00 
  8000f5:	ff d0                	callq  *%rax
#endif
}
  8000f7:	5b                   	pop    %rbx
  8000f8:	41 5c                	pop    %r12
  8000fa:	41 5d                	pop    %r13
  8000fc:	41 5e                	pop    %r14
  8000fe:	5d                   	pop    %rbp
  8000ff:	c3                   	retq   

0000000000800100 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800100:	55                   	push   %rbp
  800101:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800104:	bf 00 00 00 00       	mov    $0x0,%edi
  800109:	48 b8 55 01 80 00 00 	movabs $0x800155,%rax
  800110:	00 00 00 
  800113:	ff d0                	callq  *%rax
}
  800115:	5d                   	pop    %rbp
  800116:	c3                   	retq   

0000000000800117 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800117:	55                   	push   %rbp
  800118:	48 89 e5             	mov    %rsp,%rbp
  80011b:	53                   	push   %rbx
  80011c:	48 89 fa             	mov    %rdi,%rdx
  80011f:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800122:	b8 00 00 00 00       	mov    $0x0,%eax
  800127:	48 89 c3             	mov    %rax,%rbx
  80012a:	48 89 c7             	mov    %rax,%rdi
  80012d:	48 89 c6             	mov    %rax,%rsi
  800130:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800132:	5b                   	pop    %rbx
  800133:	5d                   	pop    %rbp
  800134:	c3                   	retq   

0000000000800135 <sys_cgetc>:

int
sys_cgetc(void) {
  800135:	55                   	push   %rbp
  800136:	48 89 e5             	mov    %rsp,%rbp
  800139:	53                   	push   %rbx
  asm volatile("int %1\n"
  80013a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013f:	b8 01 00 00 00       	mov    $0x1,%eax
  800144:	48 89 ca             	mov    %rcx,%rdx
  800147:	48 89 cb             	mov    %rcx,%rbx
  80014a:	48 89 cf             	mov    %rcx,%rdi
  80014d:	48 89 ce             	mov    %rcx,%rsi
  800150:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800152:	5b                   	pop    %rbx
  800153:	5d                   	pop    %rbp
  800154:	c3                   	retq   

0000000000800155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800155:	55                   	push   %rbp
  800156:	48 89 e5             	mov    %rsp,%rbp
  800159:	53                   	push   %rbx
  80015a:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800161:	be 00 00 00 00       	mov    $0x0,%esi
  800166:	b8 03 00 00 00       	mov    $0x3,%eax
  80016b:	48 89 f1             	mov    %rsi,%rcx
  80016e:	48 89 f3             	mov    %rsi,%rbx
  800171:	48 89 f7             	mov    %rsi,%rdi
  800174:	cd 30                	int    $0x30
  if (check && ret > 0)
  800176:	48 85 c0             	test   %rax,%rax
  800179:	7f 07                	jg     800182 <sys_env_destroy+0x2d>
}
  80017b:	48 83 c4 08          	add    $0x8,%rsp
  80017f:	5b                   	pop    %rbx
  800180:	5d                   	pop    %rbp
  800181:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800182:	49 89 c0             	mov    %rax,%r8
  800185:	b9 03 00 00 00       	mov    $0x3,%ecx
  80018a:	48 ba 90 11 80 00 00 	movabs $0x801190,%rdx
  800191:	00 00 00 
  800194:	be 22 00 00 00       	mov    $0x22,%esi
  800199:	48 bf af 11 80 00 00 	movabs $0x8011af,%rdi
  8001a0:	00 00 00 
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a8:	49 b9 d5 01 80 00 00 	movabs $0x8001d5,%r9
  8001af:	00 00 00 
  8001b2:	41 ff d1             	callq  *%r9

00000000008001b5 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001b5:	55                   	push   %rbp
  8001b6:	48 89 e5             	mov    %rsp,%rbp
  8001b9:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8001c4:	48 89 ca             	mov    %rcx,%rdx
  8001c7:	48 89 cb             	mov    %rcx,%rbx
  8001ca:	48 89 cf             	mov    %rcx,%rdi
  8001cd:	48 89 ce             	mov    %rcx,%rsi
  8001d0:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001d2:	5b                   	pop    %rbx
  8001d3:	5d                   	pop    %rbp
  8001d4:	c3                   	retq   

00000000008001d5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8001d5:	55                   	push   %rbp
  8001d6:	48 89 e5             	mov    %rsp,%rbp
  8001d9:	41 56                	push   %r14
  8001db:	41 55                	push   %r13
  8001dd:	41 54                	push   %r12
  8001df:	53                   	push   %rbx
  8001e0:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001e7:	49 89 fd             	mov    %rdi,%r13
  8001ea:	41 89 f6             	mov    %esi,%r14d
  8001ed:	49 89 d4             	mov    %rdx,%r12
  8001f0:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8001f7:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8001fe:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800205:	84 c0                	test   %al,%al
  800207:	74 26                	je     80022f <_panic+0x5a>
  800209:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800210:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800217:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80021b:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80021f:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800223:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800227:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80022b:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80022f:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800236:	00 00 00 
  800239:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800240:	00 00 00 
  800243:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800247:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  80024e:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800255:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80025c:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800263:	00 00 00 
  800266:	48 8b 18             	mov    (%rax),%rbx
  800269:	48 b8 b5 01 80 00 00 	movabs $0x8001b5,%rax
  800270:	00 00 00 
  800273:	ff d0                	callq  *%rax
  800275:	45 89 f0             	mov    %r14d,%r8d
  800278:	4c 89 e9             	mov    %r13,%rcx
  80027b:	48 89 da             	mov    %rbx,%rdx
  80027e:	89 c6                	mov    %eax,%esi
  800280:	48 bf c0 11 80 00 00 	movabs $0x8011c0,%rdi
  800287:	00 00 00 
  80028a:	b8 00 00 00 00       	mov    $0x0,%eax
  80028f:	48 bb 77 03 80 00 00 	movabs $0x800377,%rbx
  800296:	00 00 00 
  800299:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80029b:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8002a2:	4c 89 e7             	mov    %r12,%rdi
  8002a5:	48 b8 0f 03 80 00 00 	movabs $0x80030f,%rax
  8002ac:	00 00 00 
  8002af:	ff d0                	callq  *%rax
  cprintf("\n");
  8002b1:	48 bf e8 11 80 00 00 	movabs $0x8011e8,%rdi
  8002b8:	00 00 00 
  8002bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c0:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8002c2:	cc                   	int3   
  while (1)
  8002c3:	eb fd                	jmp    8002c2 <_panic+0xed>

00000000008002c5 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8002c5:	55                   	push   %rbp
  8002c6:	48 89 e5             	mov    %rsp,%rbp
  8002c9:	53                   	push   %rbx
  8002ca:	48 83 ec 08          	sub    $0x8,%rsp
  8002ce:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8002d1:	8b 06                	mov    (%rsi),%eax
  8002d3:	8d 50 01             	lea    0x1(%rax),%edx
  8002d6:	89 16                	mov    %edx,(%rsi)
  8002d8:	48 98                	cltq   
  8002da:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8002df:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8002e5:	74 0b                	je     8002f2 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8002e7:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8002eb:	48 83 c4 08          	add    $0x8,%rsp
  8002ef:	5b                   	pop    %rbx
  8002f0:	5d                   	pop    %rbp
  8002f1:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8002f2:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8002f6:	be ff 00 00 00       	mov    $0xff,%esi
  8002fb:	48 b8 17 01 80 00 00 	movabs $0x800117,%rax
  800302:	00 00 00 
  800305:	ff d0                	callq  *%rax
    b->idx = 0;
  800307:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80030d:	eb d8                	jmp    8002e7 <putch+0x22>

000000000080030f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80030f:	55                   	push   %rbp
  800310:	48 89 e5             	mov    %rsp,%rbp
  800313:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80031a:	48 89 fa             	mov    %rdi,%rdx
  80031d:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800320:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800327:	00 00 00 
  b.cnt = 0;
  80032a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800331:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800334:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80033b:	48 bf c5 02 80 00 00 	movabs $0x8002c5,%rdi
  800342:	00 00 00 
  800345:	48 b8 35 05 80 00 00 	movabs $0x800535,%rax
  80034c:	00 00 00 
  80034f:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800351:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800358:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80035f:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800363:	48 b8 17 01 80 00 00 	movabs $0x800117,%rax
  80036a:	00 00 00 
  80036d:	ff d0                	callq  *%rax

  return b.cnt;
}
  80036f:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800375:	c9                   	leaveq 
  800376:	c3                   	retq   

0000000000800377 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800377:	55                   	push   %rbp
  800378:	48 89 e5             	mov    %rsp,%rbp
  80037b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800382:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800389:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800390:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800397:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80039e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8003a5:	84 c0                	test   %al,%al
  8003a7:	74 20                	je     8003c9 <cprintf+0x52>
  8003a9:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8003ad:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8003b1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8003b5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8003b9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8003bd:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8003c1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8003c5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003c9:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8003d0:	00 00 00 
  8003d3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8003da:	00 00 00 
  8003dd:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8003e1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8003e8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8003ef:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8003f6:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8003fd:	48 b8 0f 03 80 00 00 	movabs $0x80030f,%rax
  800404:	00 00 00 
  800407:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800409:	c9                   	leaveq 
  80040a:	c3                   	retq   

000000000080040b <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80040b:	55                   	push   %rbp
  80040c:	48 89 e5             	mov    %rsp,%rbp
  80040f:	41 57                	push   %r15
  800411:	41 56                	push   %r14
  800413:	41 55                	push   %r13
  800415:	41 54                	push   %r12
  800417:	53                   	push   %rbx
  800418:	48 83 ec 18          	sub    $0x18,%rsp
  80041c:	49 89 fc             	mov    %rdi,%r12
  80041f:	49 89 f5             	mov    %rsi,%r13
  800422:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800426:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800429:	41 89 cf             	mov    %ecx,%r15d
  80042c:	49 39 d7             	cmp    %rdx,%r15
  80042f:	76 45                	jbe    800476 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800431:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800435:	85 db                	test   %ebx,%ebx
  800437:	7e 0e                	jle    800447 <printnum+0x3c>
      putch(padc, putdat);
  800439:	4c 89 ee             	mov    %r13,%rsi
  80043c:	44 89 f7             	mov    %r14d,%edi
  80043f:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800442:	83 eb 01             	sub    $0x1,%ebx
  800445:	75 f2                	jne    800439 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800447:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	49 f7 f7             	div    %r15
  800453:	48 b8 ea 11 80 00 00 	movabs $0x8011ea,%rax
  80045a:	00 00 00 
  80045d:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800461:	4c 89 ee             	mov    %r13,%rsi
  800464:	41 ff d4             	callq  *%r12
}
  800467:	48 83 c4 18          	add    $0x18,%rsp
  80046b:	5b                   	pop    %rbx
  80046c:	41 5c                	pop    %r12
  80046e:	41 5d                	pop    %r13
  800470:	41 5e                	pop    %r14
  800472:	41 5f                	pop    %r15
  800474:	5d                   	pop    %rbp
  800475:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800476:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80047a:	ba 00 00 00 00       	mov    $0x0,%edx
  80047f:	49 f7 f7             	div    %r15
  800482:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800486:	48 89 c2             	mov    %rax,%rdx
  800489:	48 b8 0b 04 80 00 00 	movabs $0x80040b,%rax
  800490:	00 00 00 
  800493:	ff d0                	callq  *%rax
  800495:	eb b0                	jmp    800447 <printnum+0x3c>

0000000000800497 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800497:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80049b:	48 8b 06             	mov    (%rsi),%rax
  80049e:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8004a2:	73 0a                	jae    8004ae <sprintputch+0x17>
    *b->buf++ = ch;
  8004a4:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004a8:	48 89 16             	mov    %rdx,(%rsi)
  8004ab:	40 88 38             	mov    %dil,(%rax)
}
  8004ae:	c3                   	retq   

00000000008004af <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8004af:	55                   	push   %rbp
  8004b0:	48 89 e5             	mov    %rsp,%rbp
  8004b3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004ba:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004c1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004c8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004cf:	84 c0                	test   %al,%al
  8004d1:	74 20                	je     8004f3 <printfmt+0x44>
  8004d3:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004d7:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004db:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004df:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004e3:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004e7:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004eb:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004ef:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8004f3:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004fa:	00 00 00 
  8004fd:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800504:	00 00 00 
  800507:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80050b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800512:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800519:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800520:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800527:	48 b8 35 05 80 00 00 	movabs $0x800535,%rax
  80052e:	00 00 00 
  800531:	ff d0                	callq  *%rax
}
  800533:	c9                   	leaveq 
  800534:	c3                   	retq   

0000000000800535 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800535:	55                   	push   %rbp
  800536:	48 89 e5             	mov    %rsp,%rbp
  800539:	41 57                	push   %r15
  80053b:	41 56                	push   %r14
  80053d:	41 55                	push   %r13
  80053f:	41 54                	push   %r12
  800541:	53                   	push   %rbx
  800542:	48 83 ec 48          	sub    $0x48,%rsp
  800546:	49 89 fd             	mov    %rdi,%r13
  800549:	49 89 f7             	mov    %rsi,%r15
  80054c:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80054f:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800553:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  800557:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80055b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80055f:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800563:	41 0f b6 3e          	movzbl (%r14),%edi
  800567:	83 ff 25             	cmp    $0x25,%edi
  80056a:	74 18                	je     800584 <vprintfmt+0x4f>
      if (ch == '\0')
  80056c:	85 ff                	test   %edi,%edi
  80056e:	0f 84 8c 06 00 00    	je     800c00 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800574:	4c 89 fe             	mov    %r15,%rsi
  800577:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80057a:	49 89 de             	mov    %rbx,%r14
  80057d:	eb e0                	jmp    80055f <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80057f:	49 89 de             	mov    %rbx,%r14
  800582:	eb db                	jmp    80055f <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800584:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800588:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80058c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800593:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800599:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80059d:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8005a2:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8005a8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8005ae:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8005b3:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8005b8:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8005bc:	0f b6 13             	movzbl (%rbx),%edx
  8005bf:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8005c2:	3c 55                	cmp    $0x55,%al
  8005c4:	0f 87 8b 05 00 00    	ja     800b55 <vprintfmt+0x620>
  8005ca:	0f b6 c0             	movzbl %al,%eax
  8005cd:	49 bb a0 12 80 00 00 	movabs $0x8012a0,%r11
  8005d4:	00 00 00 
  8005d7:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8005db:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8005de:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8005e2:	eb d4                	jmp    8005b8 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005e4:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8005e7:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8005eb:	eb cb                	jmp    8005b8 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8005ed:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8005f0:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8005f4:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8005f8:	8d 50 d0             	lea    -0x30(%rax),%edx
  8005fb:	83 fa 09             	cmp    $0x9,%edx
  8005fe:	77 7e                	ja     80067e <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800600:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800604:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800608:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80060d:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800611:	8d 50 d0             	lea    -0x30(%rax),%edx
  800614:	83 fa 09             	cmp    $0x9,%edx
  800617:	76 e7                	jbe    800600 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800619:	4c 89 f3             	mov    %r14,%rbx
  80061c:	eb 19                	jmp    800637 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80061e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800621:	83 f8 2f             	cmp    $0x2f,%eax
  800624:	77 2a                	ja     800650 <vprintfmt+0x11b>
  800626:	89 c2                	mov    %eax,%edx
  800628:	4c 01 d2             	add    %r10,%rdx
  80062b:	83 c0 08             	add    $0x8,%eax
  80062e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800631:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800634:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  800637:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80063b:	0f 89 77 ff ff ff    	jns    8005b8 <vprintfmt+0x83>
          width = precision, precision = -1;
  800641:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800645:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80064b:	e9 68 ff ff ff       	jmpq   8005b8 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800650:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800654:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800658:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80065c:	eb d3                	jmp    800631 <vprintfmt+0xfc>
        if (width < 0)
  80065e:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800661:	85 c0                	test   %eax,%eax
  800663:	41 0f 48 c0          	cmovs  %r8d,%eax
  800667:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80066a:	4c 89 f3             	mov    %r14,%rbx
  80066d:	e9 46 ff ff ff       	jmpq   8005b8 <vprintfmt+0x83>
  800672:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800675:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800679:	e9 3a ff ff ff       	jmpq   8005b8 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80067e:	4c 89 f3             	mov    %r14,%rbx
  800681:	eb b4                	jmp    800637 <vprintfmt+0x102>
        lflag++;
  800683:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800686:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800689:	e9 2a ff ff ff       	jmpq   8005b8 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80068e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800691:	83 f8 2f             	cmp    $0x2f,%eax
  800694:	77 19                	ja     8006af <vprintfmt+0x17a>
  800696:	89 c2                	mov    %eax,%edx
  800698:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80069c:	83 c0 08             	add    $0x8,%eax
  80069f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006a2:	4c 89 fe             	mov    %r15,%rsi
  8006a5:	8b 3a                	mov    (%rdx),%edi
  8006a7:	41 ff d5             	callq  *%r13
        break;
  8006aa:	e9 b0 fe ff ff       	jmpq   80055f <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8006af:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8006b3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8006b7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8006bb:	eb e5                	jmp    8006a2 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8006bd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006c0:	83 f8 2f             	cmp    $0x2f,%eax
  8006c3:	77 5b                	ja     800720 <vprintfmt+0x1eb>
  8006c5:	89 c2                	mov    %eax,%edx
  8006c7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006cb:	83 c0 08             	add    $0x8,%eax
  8006ce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006d1:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8006d3:	89 c8                	mov    %ecx,%eax
  8006d5:	c1 f8 1f             	sar    $0x1f,%eax
  8006d8:	31 c1                	xor    %eax,%ecx
  8006da:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006dc:	83 f9 09             	cmp    $0x9,%ecx
  8006df:	7f 4d                	jg     80072e <vprintfmt+0x1f9>
  8006e1:	48 63 c1             	movslq %ecx,%rax
  8006e4:	48 ba 60 15 80 00 00 	movabs $0x801560,%rdx
  8006eb:	00 00 00 
  8006ee:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8006f2:	48 85 c0             	test   %rax,%rax
  8006f5:	74 37                	je     80072e <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8006f7:	48 89 c1             	mov    %rax,%rcx
  8006fa:	48 ba 0b 12 80 00 00 	movabs $0x80120b,%rdx
  800701:	00 00 00 
  800704:	4c 89 fe             	mov    %r15,%rsi
  800707:	4c 89 ef             	mov    %r13,%rdi
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	48 bb af 04 80 00 00 	movabs $0x8004af,%rbx
  800716:	00 00 00 
  800719:	ff d3                	callq  *%rbx
  80071b:	e9 3f fe ff ff       	jmpq   80055f <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800720:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800724:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800728:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80072c:	eb a3                	jmp    8006d1 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80072e:	48 ba 02 12 80 00 00 	movabs $0x801202,%rdx
  800735:	00 00 00 
  800738:	4c 89 fe             	mov    %r15,%rsi
  80073b:	4c 89 ef             	mov    %r13,%rdi
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	48 bb af 04 80 00 00 	movabs $0x8004af,%rbx
  80074a:	00 00 00 
  80074d:	ff d3                	callq  *%rbx
  80074f:	e9 0b fe ff ff       	jmpq   80055f <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800754:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800757:	83 f8 2f             	cmp    $0x2f,%eax
  80075a:	77 4b                	ja     8007a7 <vprintfmt+0x272>
  80075c:	89 c2                	mov    %eax,%edx
  80075e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800762:	83 c0 08             	add    $0x8,%eax
  800765:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800768:	48 8b 02             	mov    (%rdx),%rax
  80076b:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80076f:	48 85 c0             	test   %rax,%rax
  800772:	0f 84 05 04 00 00    	je     800b7d <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800778:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80077c:	7e 06                	jle    800784 <vprintfmt+0x24f>
  80077e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800782:	75 31                	jne    8007b5 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800784:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800788:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80078c:	0f b6 00             	movzbl (%rax),%eax
  80078f:	0f be f8             	movsbl %al,%edi
  800792:	85 ff                	test   %edi,%edi
  800794:	0f 84 c3 00 00 00    	je     80085d <vprintfmt+0x328>
  80079a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80079e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8007a2:	e9 85 00 00 00       	jmpq   80082c <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8007a7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007ab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007af:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007b3:	eb b3                	jmp    800768 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8007b5:	49 63 f4             	movslq %r12d,%rsi
  8007b8:	48 89 c7             	mov    %rax,%rdi
  8007bb:	48 b8 0c 0d 80 00 00 	movabs $0x800d0c,%rax
  8007c2:	00 00 00 
  8007c5:	ff d0                	callq  *%rax
  8007c7:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8007ca:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8007cd:	85 f6                	test   %esi,%esi
  8007cf:	7e 22                	jle    8007f3 <vprintfmt+0x2be>
            putch(padc, putdat);
  8007d1:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8007d5:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8007d9:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8007dd:	4c 89 fe             	mov    %r15,%rsi
  8007e0:	89 df                	mov    %ebx,%edi
  8007e2:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8007e5:	41 83 ec 01          	sub    $0x1,%r12d
  8007e9:	75 f2                	jne    8007dd <vprintfmt+0x2a8>
  8007eb:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8007ef:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8007f7:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8007fb:	0f b6 00             	movzbl (%rax),%eax
  8007fe:	0f be f8             	movsbl %al,%edi
  800801:	85 ff                	test   %edi,%edi
  800803:	0f 84 56 fd ff ff    	je     80055f <vprintfmt+0x2a>
  800809:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80080d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800811:	eb 19                	jmp    80082c <vprintfmt+0x2f7>
            putch(ch, putdat);
  800813:	4c 89 fe             	mov    %r15,%rsi
  800816:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800819:	41 83 ee 01          	sub    $0x1,%r14d
  80081d:	48 83 c3 01          	add    $0x1,%rbx
  800821:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800825:	0f be f8             	movsbl %al,%edi
  800828:	85 ff                	test   %edi,%edi
  80082a:	74 29                	je     800855 <vprintfmt+0x320>
  80082c:	45 85 e4             	test   %r12d,%r12d
  80082f:	78 06                	js     800837 <vprintfmt+0x302>
  800831:	41 83 ec 01          	sub    $0x1,%r12d
  800835:	78 48                	js     80087f <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800837:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80083b:	74 d6                	je     800813 <vprintfmt+0x2de>
  80083d:	0f be c0             	movsbl %al,%eax
  800840:	83 e8 20             	sub    $0x20,%eax
  800843:	83 f8 5e             	cmp    $0x5e,%eax
  800846:	76 cb                	jbe    800813 <vprintfmt+0x2de>
            putch('?', putdat);
  800848:	4c 89 fe             	mov    %r15,%rsi
  80084b:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800850:	41 ff d5             	callq  *%r13
  800853:	eb c4                	jmp    800819 <vprintfmt+0x2e4>
  800855:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800859:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80085d:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800860:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800864:	0f 8e f5 fc ff ff    	jle    80055f <vprintfmt+0x2a>
          putch(' ', putdat);
  80086a:	4c 89 fe             	mov    %r15,%rsi
  80086d:	bf 20 00 00 00       	mov    $0x20,%edi
  800872:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800875:	83 eb 01             	sub    $0x1,%ebx
  800878:	75 f0                	jne    80086a <vprintfmt+0x335>
  80087a:	e9 e0 fc ff ff       	jmpq   80055f <vprintfmt+0x2a>
  80087f:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800883:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800887:	eb d4                	jmp    80085d <vprintfmt+0x328>
  if (lflag >= 2)
  800889:	83 f9 01             	cmp    $0x1,%ecx
  80088c:	7f 1d                	jg     8008ab <vprintfmt+0x376>
  else if (lflag)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 5e                	je     8008f0 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800892:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800895:	83 f8 2f             	cmp    $0x2f,%eax
  800898:	77 48                	ja     8008e2 <vprintfmt+0x3ad>
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008a0:	83 c0 08             	add    $0x8,%eax
  8008a3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a6:	48 8b 1a             	mov    (%rdx),%rbx
  8008a9:	eb 17                	jmp    8008c2 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8008ab:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008ae:	83 f8 2f             	cmp    $0x2f,%eax
  8008b1:	77 21                	ja     8008d4 <vprintfmt+0x39f>
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008b9:	83 c0 08             	add    $0x8,%eax
  8008bc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008bf:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8008c2:	48 85 db             	test   %rbx,%rbx
  8008c5:	78 50                	js     800917 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8008c7:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8008ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008cf:	e9 b4 01 00 00       	jmpq   800a88 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8008d4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008dc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e0:	eb dd                	jmp    8008bf <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8008e2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008ea:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ee:	eb b6                	jmp    8008a6 <vprintfmt+0x371>
    return va_arg(*ap, int);
  8008f0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008f3:	83 f8 2f             	cmp    $0x2f,%eax
  8008f6:	77 11                	ja     800909 <vprintfmt+0x3d4>
  8008f8:	89 c2                	mov    %eax,%edx
  8008fa:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008fe:	83 c0 08             	add    $0x8,%eax
  800901:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800904:	48 63 1a             	movslq (%rdx),%rbx
  800907:	eb b9                	jmp    8008c2 <vprintfmt+0x38d>
  800909:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80090d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800911:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800915:	eb ed                	jmp    800904 <vprintfmt+0x3cf>
          putch('-', putdat);
  800917:	4c 89 fe             	mov    %r15,%rsi
  80091a:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80091f:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800922:	48 89 da             	mov    %rbx,%rdx
  800925:	48 f7 da             	neg    %rdx
        base = 10;
  800928:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80092d:	e9 56 01 00 00       	jmpq   800a88 <vprintfmt+0x553>
  if (lflag >= 2)
  800932:	83 f9 01             	cmp    $0x1,%ecx
  800935:	7f 25                	jg     80095c <vprintfmt+0x427>
  else if (lflag)
  800937:	85 c9                	test   %ecx,%ecx
  800939:	74 5e                	je     800999 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80093b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093e:	83 f8 2f             	cmp    $0x2f,%eax
  800941:	77 48                	ja     80098b <vprintfmt+0x456>
  800943:	89 c2                	mov    %eax,%edx
  800945:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800949:	83 c0 08             	add    $0x8,%eax
  80094c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094f:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800952:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800957:	e9 2c 01 00 00       	jmpq   800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80095c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80095f:	83 f8 2f             	cmp    $0x2f,%eax
  800962:	77 19                	ja     80097d <vprintfmt+0x448>
  800964:	89 c2                	mov    %eax,%edx
  800966:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80096a:	83 c0 08             	add    $0x8,%eax
  80096d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800970:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800973:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800978:	e9 0b 01 00 00       	jmpq   800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80097d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800981:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800985:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800989:	eb e5                	jmp    800970 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80098b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80098f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800993:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800997:	eb b6                	jmp    80094f <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800999:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099c:	83 f8 2f             	cmp    $0x2f,%eax
  80099f:	77 18                	ja     8009b9 <vprintfmt+0x484>
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a7:	83 c0 08             	add    $0x8,%eax
  8009aa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009ad:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8009af:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b4:	e9 cf 00 00 00       	jmpq   800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8009b9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009bd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c5:	eb e6                	jmp    8009ad <vprintfmt+0x478>
  if (lflag >= 2)
  8009c7:	83 f9 01             	cmp    $0x1,%ecx
  8009ca:	7f 25                	jg     8009f1 <vprintfmt+0x4bc>
  else if (lflag)
  8009cc:	85 c9                	test   %ecx,%ecx
  8009ce:	74 5b                	je     800a2b <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8009d0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d3:	83 f8 2f             	cmp    $0x2f,%eax
  8009d6:	77 45                	ja     800a1d <vprintfmt+0x4e8>
  8009d8:	89 c2                	mov    %eax,%edx
  8009da:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009de:	83 c0 08             	add    $0x8,%eax
  8009e1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e4:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8009e7:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009ec:	e9 97 00 00 00       	jmpq   800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8009f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f4:	83 f8 2f             	cmp    $0x2f,%eax
  8009f7:	77 16                	ja     800a0f <vprintfmt+0x4da>
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009ff:	83 c0 08             	add    $0x8,%eax
  800a02:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a05:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800a08:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a0d:	eb 79                	jmp    800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800a0f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a13:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a17:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a1b:	eb e8                	jmp    800a05 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800a1d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a21:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a25:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a29:	eb b9                	jmp    8009e4 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800a2b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a2e:	83 f8 2f             	cmp    $0x2f,%eax
  800a31:	77 15                	ja     800a48 <vprintfmt+0x513>
  800a33:	89 c2                	mov    %eax,%edx
  800a35:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a39:	83 c0 08             	add    $0x8,%eax
  800a3c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a3f:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800a41:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a46:	eb 40                	jmp    800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800a48:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a4c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a50:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a54:	eb e9                	jmp    800a3f <vprintfmt+0x50a>
        putch('0', putdat);
  800a56:	4c 89 fe             	mov    %r15,%rsi
  800a59:	bf 30 00 00 00       	mov    $0x30,%edi
  800a5e:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800a61:	4c 89 fe             	mov    %r15,%rsi
  800a64:	bf 78 00 00 00       	mov    $0x78,%edi
  800a69:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800a6c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a6f:	83 f8 2f             	cmp    $0x2f,%eax
  800a72:	77 34                	ja     800aa8 <vprintfmt+0x573>
  800a74:	89 c2                	mov    %eax,%edx
  800a76:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a7a:	83 c0 08             	add    $0x8,%eax
  800a7d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a80:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800a83:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800a88:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800a8d:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800a91:	4c 89 fe             	mov    %r15,%rsi
  800a94:	4c 89 ef             	mov    %r13,%rdi
  800a97:	48 b8 0b 04 80 00 00 	movabs $0x80040b,%rax
  800a9e:	00 00 00 
  800aa1:	ff d0                	callq  *%rax
        break;
  800aa3:	e9 b7 fa ff ff       	jmpq   80055f <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800aa8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ab0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ab4:	eb ca                	jmp    800a80 <vprintfmt+0x54b>
  if (lflag >= 2)
  800ab6:	83 f9 01             	cmp    $0x1,%ecx
  800ab9:	7f 22                	jg     800add <vprintfmt+0x5a8>
  else if (lflag)
  800abb:	85 c9                	test   %ecx,%ecx
  800abd:	74 58                	je     800b17 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800abf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ac2:	83 f8 2f             	cmp    $0x2f,%eax
  800ac5:	77 42                	ja     800b09 <vprintfmt+0x5d4>
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800acd:	83 c0 08             	add    $0x8,%eax
  800ad0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ad3:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ad6:	b9 10 00 00 00       	mov    $0x10,%ecx
  800adb:	eb ab                	jmp    800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800add:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae0:	83 f8 2f             	cmp    $0x2f,%eax
  800ae3:	77 16                	ja     800afb <vprintfmt+0x5c6>
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aeb:	83 c0 08             	add    $0x8,%eax
  800aee:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af1:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800af4:	b9 10 00 00 00       	mov    $0x10,%ecx
  800af9:	eb 8d                	jmp    800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800afb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800aff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b03:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b07:	eb e8                	jmp    800af1 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800b09:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b0d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b11:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b15:	eb bc                	jmp    800ad3 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800b17:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1a:	83 f8 2f             	cmp    $0x2f,%eax
  800b1d:	77 18                	ja     800b37 <vprintfmt+0x602>
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b25:	83 c0 08             	add    $0x8,%eax
  800b28:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2b:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800b2d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b32:	e9 51 ff ff ff       	jmpq   800a88 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800b37:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b3b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b3f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b43:	eb e6                	jmp    800b2b <vprintfmt+0x5f6>
        putch(ch, putdat);
  800b45:	4c 89 fe             	mov    %r15,%rsi
  800b48:	bf 25 00 00 00       	mov    $0x25,%edi
  800b4d:	41 ff d5             	callq  *%r13
        break;
  800b50:	e9 0a fa ff ff       	jmpq   80055f <vprintfmt+0x2a>
        putch('%', putdat);
  800b55:	4c 89 fe             	mov    %r15,%rsi
  800b58:	bf 25 00 00 00       	mov    $0x25,%edi
  800b5d:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800b60:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800b64:	0f 84 15 fa ff ff    	je     80057f <vprintfmt+0x4a>
  800b6a:	49 89 de             	mov    %rbx,%r14
  800b6d:	49 83 ee 01          	sub    $0x1,%r14
  800b71:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800b76:	75 f5                	jne    800b6d <vprintfmt+0x638>
  800b78:	e9 e2 f9 ff ff       	jmpq   80055f <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800b7d:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800b81:	74 06                	je     800b89 <vprintfmt+0x654>
  800b83:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b87:	7f 21                	jg     800baa <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b89:	bf 28 00 00 00       	mov    $0x28,%edi
  800b8e:	48 bb fc 11 80 00 00 	movabs $0x8011fc,%rbx
  800b95:	00 00 00 
  800b98:	b8 28 00 00 00       	mov    $0x28,%eax
  800b9d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ba1:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800ba5:	e9 82 fc ff ff       	jmpq   80082c <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800baa:	49 63 f4             	movslq %r12d,%rsi
  800bad:	48 bf fb 11 80 00 00 	movabs $0x8011fb,%rdi
  800bb4:	00 00 00 
  800bb7:	48 b8 0c 0d 80 00 00 	movabs $0x800d0c,%rax
  800bbe:	00 00 00 
  800bc1:	ff d0                	callq  *%rax
  800bc3:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800bc6:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800bc9:	48 be fb 11 80 00 00 	movabs $0x8011fb,%rsi
  800bd0:	00 00 00 
  800bd3:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	0f 8f f2 fb ff ff    	jg     8007d1 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bdf:	48 bb fc 11 80 00 00 	movabs $0x8011fc,%rbx
  800be6:	00 00 00 
  800be9:	b8 28 00 00 00       	mov    $0x28,%eax
  800bee:	bf 28 00 00 00       	mov    $0x28,%edi
  800bf3:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800bf7:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800bfb:	e9 2c fc ff ff       	jmpq   80082c <vprintfmt+0x2f7>
}
  800c00:	48 83 c4 48          	add    $0x48,%rsp
  800c04:	5b                   	pop    %rbx
  800c05:	41 5c                	pop    %r12
  800c07:	41 5d                	pop    %r13
  800c09:	41 5e                	pop    %r14
  800c0b:	41 5f                	pop    %r15
  800c0d:	5d                   	pop    %rbp
  800c0e:	c3                   	retq   

0000000000800c0f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800c0f:	55                   	push   %rbp
  800c10:	48 89 e5             	mov    %rsp,%rbp
  800c13:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800c17:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800c1b:	48 63 c6             	movslq %esi,%rax
  800c1e:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800c23:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800c27:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800c2e:	48 85 ff             	test   %rdi,%rdi
  800c31:	74 2a                	je     800c5d <vsnprintf+0x4e>
  800c33:	85 f6                	test   %esi,%esi
  800c35:	7e 26                	jle    800c5d <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800c37:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800c3b:	48 bf 97 04 80 00 00 	movabs $0x800497,%rdi
  800c42:	00 00 00 
  800c45:	48 b8 35 05 80 00 00 	movabs $0x800535,%rax
  800c4c:	00 00 00 
  800c4f:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800c51:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800c55:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800c58:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800c5b:	c9                   	leaveq 
  800c5c:	c3                   	retq   
    return -E_INVAL;
  800c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c62:	eb f7                	jmp    800c5b <vsnprintf+0x4c>

0000000000800c64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800c64:	55                   	push   %rbp
  800c65:	48 89 e5             	mov    %rsp,%rbp
  800c68:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800c6f:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800c76:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800c7d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800c84:	84 c0                	test   %al,%al
  800c86:	74 20                	je     800ca8 <snprintf+0x44>
  800c88:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800c8c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800c90:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800c94:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800c98:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800c9c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ca0:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800ca4:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800ca8:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800caf:	00 00 00 
  800cb2:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800cb9:	00 00 00 
  800cbc:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800cc0:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800cc7:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800cce:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800cd5:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800cdc:	48 b8 0f 0c 80 00 00 	movabs $0x800c0f,%rax
  800ce3:	00 00 00 
  800ce6:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800ce8:	c9                   	leaveq 
  800ce9:	c3                   	retq   

0000000000800cea <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800cea:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ced:	74 17                	je     800d06 <strlen+0x1c>
  800cef:	48 89 fa             	mov    %rdi,%rdx
  800cf2:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cf7:	29 f9                	sub    %edi,%ecx
    n++;
  800cf9:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800cfc:	48 83 c2 01          	add    $0x1,%rdx
  800d00:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d03:	75 f4                	jne    800cf9 <strlen+0xf>
  800d05:	c3                   	retq   
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d0b:	c3                   	retq   

0000000000800d0c <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0c:	48 85 f6             	test   %rsi,%rsi
  800d0f:	74 24                	je     800d35 <strnlen+0x29>
  800d11:	80 3f 00             	cmpb   $0x0,(%rdi)
  800d14:	74 25                	je     800d3b <strnlen+0x2f>
  800d16:	48 01 fe             	add    %rdi,%rsi
  800d19:	48 89 fa             	mov    %rdi,%rdx
  800d1c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d21:	29 f9                	sub    %edi,%ecx
    n++;
  800d23:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d26:	48 83 c2 01          	add    $0x1,%rdx
  800d2a:	48 39 f2             	cmp    %rsi,%rdx
  800d2d:	74 11                	je     800d40 <strnlen+0x34>
  800d2f:	80 3a 00             	cmpb   $0x0,(%rdx)
  800d32:	75 ef                	jne    800d23 <strnlen+0x17>
  800d34:	c3                   	retq   
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	c3                   	retq   
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800d40:	c3                   	retq   

0000000000800d41 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800d41:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
  800d49:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800d4d:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800d50:	48 83 c2 01          	add    $0x1,%rdx
  800d54:	84 c9                	test   %cl,%cl
  800d56:	75 f1                	jne    800d49 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800d58:	c3                   	retq   

0000000000800d59 <strcat>:

char *
strcat(char *dst, const char *src) {
  800d59:	55                   	push   %rbp
  800d5a:	48 89 e5             	mov    %rsp,%rbp
  800d5d:	41 54                	push   %r12
  800d5f:	53                   	push   %rbx
  800d60:	48 89 fb             	mov    %rdi,%rbx
  800d63:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800d66:	48 b8 ea 0c 80 00 00 	movabs $0x800cea,%rax
  800d6d:	00 00 00 
  800d70:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800d72:	48 63 f8             	movslq %eax,%rdi
  800d75:	48 01 df             	add    %rbx,%rdi
  800d78:	4c 89 e6             	mov    %r12,%rsi
  800d7b:	48 b8 41 0d 80 00 00 	movabs $0x800d41,%rax
  800d82:	00 00 00 
  800d85:	ff d0                	callq  *%rax
  return dst;
}
  800d87:	48 89 d8             	mov    %rbx,%rax
  800d8a:	5b                   	pop    %rbx
  800d8b:	41 5c                	pop    %r12
  800d8d:	5d                   	pop    %rbp
  800d8e:	c3                   	retq   

0000000000800d8f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d8f:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d92:	48 85 d2             	test   %rdx,%rdx
  800d95:	74 1f                	je     800db6 <strncpy+0x27>
  800d97:	48 01 fa             	add    %rdi,%rdx
  800d9a:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800d9d:	48 83 c1 01          	add    $0x1,%rcx
  800da1:	44 0f b6 06          	movzbl (%rsi),%r8d
  800da5:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800da9:	41 80 f8 01          	cmp    $0x1,%r8b
  800dad:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800db1:	48 39 ca             	cmp    %rcx,%rdx
  800db4:	75 e7                	jne    800d9d <strncpy+0xe>
  }
  return ret;
}
  800db6:	c3                   	retq   

0000000000800db7 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800db7:	48 89 f8             	mov    %rdi,%rax
  800dba:	48 85 d2             	test   %rdx,%rdx
  800dbd:	74 36                	je     800df5 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800dbf:	48 83 fa 01          	cmp    $0x1,%rdx
  800dc3:	74 2d                	je     800df2 <strlcpy+0x3b>
  800dc5:	44 0f b6 06          	movzbl (%rsi),%r8d
  800dc9:	45 84 c0             	test   %r8b,%r8b
  800dcc:	74 24                	je     800df2 <strlcpy+0x3b>
  800dce:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800dd2:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800dd7:	48 83 c0 01          	add    $0x1,%rax
  800ddb:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800ddf:	48 39 d1             	cmp    %rdx,%rcx
  800de2:	74 0e                	je     800df2 <strlcpy+0x3b>
  800de4:	48 83 c1 01          	add    $0x1,%rcx
  800de8:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800ded:	45 84 c0             	test   %r8b,%r8b
  800df0:	75 e5                	jne    800dd7 <strlcpy+0x20>
    *dst = '\0';
  800df2:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800df5:	48 29 f8             	sub    %rdi,%rax
}
  800df8:	c3                   	retq   

0000000000800df9 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800df9:	0f b6 07             	movzbl (%rdi),%eax
  800dfc:	84 c0                	test   %al,%al
  800dfe:	74 17                	je     800e17 <strcmp+0x1e>
  800e00:	3a 06                	cmp    (%rsi),%al
  800e02:	75 13                	jne    800e17 <strcmp+0x1e>
    p++, q++;
  800e04:	48 83 c7 01          	add    $0x1,%rdi
  800e08:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800e0c:	0f b6 07             	movzbl (%rdi),%eax
  800e0f:	84 c0                	test   %al,%al
  800e11:	74 04                	je     800e17 <strcmp+0x1e>
  800e13:	3a 06                	cmp    (%rsi),%al
  800e15:	74 ed                	je     800e04 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800e17:	0f b6 c0             	movzbl %al,%eax
  800e1a:	0f b6 16             	movzbl (%rsi),%edx
  800e1d:	29 d0                	sub    %edx,%eax
}
  800e1f:	c3                   	retq   

0000000000800e20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800e20:	48 85 d2             	test   %rdx,%rdx
  800e23:	74 2f                	je     800e54 <strncmp+0x34>
  800e25:	0f b6 07             	movzbl (%rdi),%eax
  800e28:	84 c0                	test   %al,%al
  800e2a:	74 1f                	je     800e4b <strncmp+0x2b>
  800e2c:	3a 06                	cmp    (%rsi),%al
  800e2e:	75 1b                	jne    800e4b <strncmp+0x2b>
  800e30:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800e33:	48 83 c7 01          	add    $0x1,%rdi
  800e37:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800e3b:	48 39 d7             	cmp    %rdx,%rdi
  800e3e:	74 1a                	je     800e5a <strncmp+0x3a>
  800e40:	0f b6 07             	movzbl (%rdi),%eax
  800e43:	84 c0                	test   %al,%al
  800e45:	74 04                	je     800e4b <strncmp+0x2b>
  800e47:	3a 06                	cmp    (%rsi),%al
  800e49:	74 e8                	je     800e33 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e4b:	0f b6 07             	movzbl (%rdi),%eax
  800e4e:	0f b6 16             	movzbl (%rsi),%edx
  800e51:	29 d0                	sub    %edx,%eax
}
  800e53:	c3                   	retq   
    return 0;
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
  800e59:	c3                   	retq   
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	c3                   	retq   

0000000000800e60 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800e60:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800e62:	0f b6 07             	movzbl (%rdi),%eax
  800e65:	84 c0                	test   %al,%al
  800e67:	74 1e                	je     800e87 <strchr+0x27>
    if (*s == c)
  800e69:	40 38 c6             	cmp    %al,%sil
  800e6c:	74 1f                	je     800e8d <strchr+0x2d>
  for (; *s; s++)
  800e6e:	48 83 c7 01          	add    $0x1,%rdi
  800e72:	0f b6 07             	movzbl (%rdi),%eax
  800e75:	84 c0                	test   %al,%al
  800e77:	74 08                	je     800e81 <strchr+0x21>
    if (*s == c)
  800e79:	38 d0                	cmp    %dl,%al
  800e7b:	75 f1                	jne    800e6e <strchr+0xe>
  for (; *s; s++)
  800e7d:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800e80:	c3                   	retq   
  return 0;
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	c3                   	retq   
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	c3                   	retq   
    if (*s == c)
  800e8d:	48 89 f8             	mov    %rdi,%rax
  800e90:	c3                   	retq   

0000000000800e91 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800e91:	48 89 f8             	mov    %rdi,%rax
  800e94:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800e96:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800e99:	40 38 f2             	cmp    %sil,%dl
  800e9c:	74 13                	je     800eb1 <strfind+0x20>
  800e9e:	84 d2                	test   %dl,%dl
  800ea0:	74 0f                	je     800eb1 <strfind+0x20>
  for (; *s; s++)
  800ea2:	48 83 c0 01          	add    $0x1,%rax
  800ea6:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800ea9:	38 ca                	cmp    %cl,%dl
  800eab:	74 04                	je     800eb1 <strfind+0x20>
  800ead:	84 d2                	test   %dl,%dl
  800eaf:	75 f1                	jne    800ea2 <strfind+0x11>
      break;
  return (char *)s;
}
  800eb1:	c3                   	retq   

0000000000800eb2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800eb2:	48 85 d2             	test   %rdx,%rdx
  800eb5:	74 3a                	je     800ef1 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800eb7:	48 89 f8             	mov    %rdi,%rax
  800eba:	48 09 d0             	or     %rdx,%rax
  800ebd:	a8 03                	test   $0x3,%al
  800ebf:	75 28                	jne    800ee9 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800ec1:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800ec5:	89 f0                	mov    %esi,%eax
  800ec7:	c1 e0 08             	shl    $0x8,%eax
  800eca:	89 f1                	mov    %esi,%ecx
  800ecc:	c1 e1 18             	shl    $0x18,%ecx
  800ecf:	41 89 f0             	mov    %esi,%r8d
  800ed2:	41 c1 e0 10          	shl    $0x10,%r8d
  800ed6:	44 09 c1             	or     %r8d,%ecx
  800ed9:	09 ce                	or     %ecx,%esi
  800edb:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800edd:	48 c1 ea 02          	shr    $0x2,%rdx
  800ee1:	48 89 d1             	mov    %rdx,%rcx
  800ee4:	fc                   	cld    
  800ee5:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800ee7:	eb 08                	jmp    800ef1 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	48 89 d1             	mov    %rdx,%rcx
  800eee:	fc                   	cld    
  800eef:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800ef1:	48 89 f8             	mov    %rdi,%rax
  800ef4:	c3                   	retq   

0000000000800ef5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800ef5:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ef8:	48 39 fe             	cmp    %rdi,%rsi
  800efb:	73 40                	jae    800f3d <memmove+0x48>
  800efd:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800f01:	48 39 f9             	cmp    %rdi,%rcx
  800f04:	76 37                	jbe    800f3d <memmove+0x48>
    s += n;
    d += n;
  800f06:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f0a:	48 89 fe             	mov    %rdi,%rsi
  800f0d:	48 09 d6             	or     %rdx,%rsi
  800f10:	48 09 ce             	or     %rcx,%rsi
  800f13:	40 f6 c6 03          	test   $0x3,%sil
  800f17:	75 14                	jne    800f2d <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800f19:	48 83 ef 04          	sub    $0x4,%rdi
  800f1d:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800f21:	48 c1 ea 02          	shr    $0x2,%rdx
  800f25:	48 89 d1             	mov    %rdx,%rcx
  800f28:	fd                   	std    
  800f29:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f2b:	eb 0e                	jmp    800f3b <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800f2d:	48 83 ef 01          	sub    $0x1,%rdi
  800f31:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800f35:	48 89 d1             	mov    %rdx,%rcx
  800f38:	fd                   	std    
  800f39:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800f3b:	fc                   	cld    
  800f3c:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800f3d:	48 89 c1             	mov    %rax,%rcx
  800f40:	48 09 d1             	or     %rdx,%rcx
  800f43:	48 09 f1             	or     %rsi,%rcx
  800f46:	f6 c1 03             	test   $0x3,%cl
  800f49:	75 0e                	jne    800f59 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800f4b:	48 c1 ea 02          	shr    $0x2,%rdx
  800f4f:	48 89 d1             	mov    %rdx,%rcx
  800f52:	48 89 c7             	mov    %rax,%rdi
  800f55:	fc                   	cld    
  800f56:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800f58:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800f59:	48 89 c7             	mov    %rax,%rdi
  800f5c:	48 89 d1             	mov    %rdx,%rcx
  800f5f:	fc                   	cld    
  800f60:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800f62:	c3                   	retq   

0000000000800f63 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800f63:	55                   	push   %rbp
  800f64:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800f67:	48 b8 f5 0e 80 00 00 	movabs $0x800ef5,%rax
  800f6e:	00 00 00 
  800f71:	ff d0                	callq  *%rax
}
  800f73:	5d                   	pop    %rbp
  800f74:	c3                   	retq   

0000000000800f75 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800f75:	55                   	push   %rbp
  800f76:	48 89 e5             	mov    %rsp,%rbp
  800f79:	41 57                	push   %r15
  800f7b:	41 56                	push   %r14
  800f7d:	41 55                	push   %r13
  800f7f:	41 54                	push   %r12
  800f81:	53                   	push   %rbx
  800f82:	48 83 ec 08          	sub    $0x8,%rsp
  800f86:	49 89 fe             	mov    %rdi,%r14
  800f89:	49 89 f7             	mov    %rsi,%r15
  800f8c:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800f8f:	48 89 f7             	mov    %rsi,%rdi
  800f92:	48 b8 ea 0c 80 00 00 	movabs $0x800cea,%rax
  800f99:	00 00 00 
  800f9c:	ff d0                	callq  *%rax
  800f9e:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800fa1:	4c 89 ee             	mov    %r13,%rsi
  800fa4:	4c 89 f7             	mov    %r14,%rdi
  800fa7:	48 b8 0c 0d 80 00 00 	movabs $0x800d0c,%rax
  800fae:	00 00 00 
  800fb1:	ff d0                	callq  *%rax
  800fb3:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800fb6:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800fba:	4d 39 e5             	cmp    %r12,%r13
  800fbd:	74 26                	je     800fe5 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800fbf:	4c 89 e8             	mov    %r13,%rax
  800fc2:	4c 29 e0             	sub    %r12,%rax
  800fc5:	48 39 d8             	cmp    %rbx,%rax
  800fc8:	76 2a                	jbe    800ff4 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800fca:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800fce:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800fd2:	4c 89 fe             	mov    %r15,%rsi
  800fd5:	48 b8 63 0f 80 00 00 	movabs $0x800f63,%rax
  800fdc:	00 00 00 
  800fdf:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800fe1:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800fe5:	48 83 c4 08          	add    $0x8,%rsp
  800fe9:	5b                   	pop    %rbx
  800fea:	41 5c                	pop    %r12
  800fec:	41 5d                	pop    %r13
  800fee:	41 5e                	pop    %r14
  800ff0:	41 5f                	pop    %r15
  800ff2:	5d                   	pop    %rbp
  800ff3:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800ff4:	49 83 ed 01          	sub    $0x1,%r13
  800ff8:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800ffc:	4c 89 ea             	mov    %r13,%rdx
  800fff:	4c 89 fe             	mov    %r15,%rsi
  801002:	48 b8 63 0f 80 00 00 	movabs $0x800f63,%rax
  801009:	00 00 00 
  80100c:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80100e:	4d 01 ee             	add    %r13,%r14
  801011:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801016:	eb c9                	jmp    800fe1 <strlcat+0x6c>

0000000000801018 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801018:	48 85 d2             	test   %rdx,%rdx
  80101b:	74 3a                	je     801057 <memcmp+0x3f>
    if (*s1 != *s2)
  80101d:	0f b6 0f             	movzbl (%rdi),%ecx
  801020:	44 0f b6 06          	movzbl (%rsi),%r8d
  801024:	44 38 c1             	cmp    %r8b,%cl
  801027:	75 1d                	jne    801046 <memcmp+0x2e>
  801029:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80102e:	48 39 d0             	cmp    %rdx,%rax
  801031:	74 1e                	je     801051 <memcmp+0x39>
    if (*s1 != *s2)
  801033:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801037:	48 83 c0 01          	add    $0x1,%rax
  80103b:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801041:	44 38 c1             	cmp    %r8b,%cl
  801044:	74 e8                	je     80102e <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801046:	0f b6 c1             	movzbl %cl,%eax
  801049:	45 0f b6 c0          	movzbl %r8b,%r8d
  80104d:	44 29 c0             	sub    %r8d,%eax
  801050:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	c3                   	retq   
  801057:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80105c:	c3                   	retq   

000000000080105d <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80105d:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801061:	48 39 c7             	cmp    %rax,%rdi
  801064:	73 19                	jae    80107f <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801066:	89 f2                	mov    %esi,%edx
  801068:	40 38 37             	cmp    %sil,(%rdi)
  80106b:	74 16                	je     801083 <memfind+0x26>
  for (; s < ends; s++)
  80106d:	48 83 c7 01          	add    $0x1,%rdi
  801071:	48 39 f8             	cmp    %rdi,%rax
  801074:	74 08                	je     80107e <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801076:	38 17                	cmp    %dl,(%rdi)
  801078:	75 f3                	jne    80106d <memfind+0x10>
  for (; s < ends; s++)
  80107a:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80107d:	c3                   	retq   
  80107e:	c3                   	retq   
  for (; s < ends; s++)
  80107f:	48 89 f8             	mov    %rdi,%rax
  801082:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801083:	48 89 f8             	mov    %rdi,%rax
  801086:	c3                   	retq   

0000000000801087 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801087:	0f b6 07             	movzbl (%rdi),%eax
  80108a:	3c 20                	cmp    $0x20,%al
  80108c:	74 04                	je     801092 <strtol+0xb>
  80108e:	3c 09                	cmp    $0x9,%al
  801090:	75 0f                	jne    8010a1 <strtol+0x1a>
    s++;
  801092:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801096:	0f b6 07             	movzbl (%rdi),%eax
  801099:	3c 20                	cmp    $0x20,%al
  80109b:	74 f5                	je     801092 <strtol+0xb>
  80109d:	3c 09                	cmp    $0x9,%al
  80109f:	74 f1                	je     801092 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8010a1:	3c 2b                	cmp    $0x2b,%al
  8010a3:	74 2b                	je     8010d0 <strtol+0x49>
  int neg  = 0;
  8010a5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8010ab:	3c 2d                	cmp    $0x2d,%al
  8010ad:	74 2d                	je     8010dc <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010af:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8010b5:	75 0f                	jne    8010c6 <strtol+0x3f>
  8010b7:	80 3f 30             	cmpb   $0x30,(%rdi)
  8010ba:	74 2c                	je     8010e8 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8010bc:	85 d2                	test   %edx,%edx
  8010be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c3:	0f 44 d0             	cmove  %eax,%edx
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8010cb:	4c 63 d2             	movslq %edx,%r10
  8010ce:	eb 5c                	jmp    80112c <strtol+0xa5>
    s++;
  8010d0:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8010d4:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8010da:	eb d3                	jmp    8010af <strtol+0x28>
    s++, neg = 1;
  8010dc:	48 83 c7 01          	add    $0x1,%rdi
  8010e0:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8010e6:	eb c7                	jmp    8010af <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010e8:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8010ec:	74 0f                	je     8010fd <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8010ee:	85 d2                	test   %edx,%edx
  8010f0:	75 d4                	jne    8010c6 <strtol+0x3f>
    s++, base = 8;
  8010f2:	48 83 c7 01          	add    $0x1,%rdi
  8010f6:	ba 08 00 00 00       	mov    $0x8,%edx
  8010fb:	eb c9                	jmp    8010c6 <strtol+0x3f>
    s += 2, base = 16;
  8010fd:	48 83 c7 02          	add    $0x2,%rdi
  801101:	ba 10 00 00 00       	mov    $0x10,%edx
  801106:	eb be                	jmp    8010c6 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801108:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80110c:	41 80 f8 19          	cmp    $0x19,%r8b
  801110:	77 2f                	ja     801141 <strtol+0xba>
      dig = *s - 'a' + 10;
  801112:	44 0f be c1          	movsbl %cl,%r8d
  801116:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80111a:	39 d1                	cmp    %edx,%ecx
  80111c:	7d 37                	jge    801155 <strtol+0xce>
    s++, val = (val * base) + dig;
  80111e:	48 83 c7 01          	add    $0x1,%rdi
  801122:	49 0f af c2          	imul   %r10,%rax
  801126:	48 63 c9             	movslq %ecx,%rcx
  801129:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80112c:	0f b6 0f             	movzbl (%rdi),%ecx
  80112f:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801133:	41 80 f8 09          	cmp    $0x9,%r8b
  801137:	77 cf                	ja     801108 <strtol+0x81>
      dig = *s - '0';
  801139:	0f be c9             	movsbl %cl,%ecx
  80113c:	83 e9 30             	sub    $0x30,%ecx
  80113f:	eb d9                	jmp    80111a <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801141:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801145:	41 80 f8 19          	cmp    $0x19,%r8b
  801149:	77 0a                	ja     801155 <strtol+0xce>
      dig = *s - 'A' + 10;
  80114b:	44 0f be c1          	movsbl %cl,%r8d
  80114f:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801153:	eb c5                	jmp    80111a <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801155:	48 85 f6             	test   %rsi,%rsi
  801158:	74 03                	je     80115d <strtol+0xd6>
    *endptr = (char *)s;
  80115a:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80115d:	48 89 c2             	mov    %rax,%rdx
  801160:	48 f7 da             	neg    %rdx
  801163:	45 85 c9             	test   %r9d,%r9d
  801166:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80116a:	c3                   	retq   
  80116b:	90                   	nop
