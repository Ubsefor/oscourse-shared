
obj/user/dumbfork:     file format elf64-x86-64


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
  800023:	e8 d3 02 00 00       	callq  8002fb <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <duppage>:
    sys_yield();
  }
}

void
duppage(envid_t dstenv, void *addr) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 54                	push   %r12
  800030:	53                   	push   %rbx
  800031:	41 89 fc             	mov    %edi,%r12d
  800034:	48 89 f3             	mov    %rsi,%rbx
  int r;

  // This is NOT what you should do in your fork.
  if ((r = sys_page_alloc(dstenv, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800037:	ba 07 00 00 00       	mov    $0x7,%edx
  80003c:	48 b8 3c 14 80 00 00 	movabs $0x80143c,%rax
  800043:	00 00 00 
  800046:	ff d0                	callq  *%rax
  800048:	85 c0                	test   %eax,%eax
  80004a:	78 5e                	js     8000aa <duppage+0x80>
    panic("sys_page_alloc: %i", r);
  if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80004c:	41 b8 07 00 00 00    	mov    $0x7,%r8d
  800052:	b9 00 00 40 00       	mov    $0x400000,%ecx
  800057:	ba 00 00 00 00       	mov    $0x0,%edx
  80005c:	48 89 de             	mov    %rbx,%rsi
  80005f:	44 89 e7             	mov    %r12d,%edi
  800062:	48 b8 9f 14 80 00 00 	movabs $0x80149f,%rax
  800069:	00 00 00 
  80006c:	ff d0                	callq  *%rax
  80006e:	85 c0                	test   %eax,%eax
  800070:	78 65                	js     8000d7 <duppage+0xad>
    panic("sys_page_map: %i", r);
  memmove(UTEMP, addr, PGSIZE);
  800072:	ba 00 10 00 00       	mov    $0x1000,%edx
  800077:	48 89 de             	mov    %rbx,%rsi
  80007a:	bf 00 00 40 00       	mov    $0x400000,%edi
  80007f:	48 b8 e8 10 80 00 00 	movabs $0x8010e8,%rax
  800086:	00 00 00 
  800089:	ff d0                	callq  *%rax
  if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80008b:	be 00 00 40 00       	mov    $0x400000,%esi
  800090:	bf 00 00 00 00       	mov    $0x0,%edi
  800095:	48 b8 06 15 80 00 00 	movabs $0x801506,%rax
  80009c:	00 00 00 
  80009f:	ff d0                	callq  *%rax
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	78 5f                	js     800104 <duppage+0xda>
    panic("sys_page_unmap: %i", r);
}
  8000a5:	5b                   	pop    %rbx
  8000a6:	41 5c                	pop    %r12
  8000a8:	5d                   	pop    %rbp
  8000a9:	c3                   	retq   
    panic("sys_page_alloc: %i", r);
  8000aa:	89 c1                	mov    %eax,%ecx
  8000ac:	48 ba c0 16 80 00 00 	movabs $0x8016c0,%rdx
  8000b3:	00 00 00 
  8000b6:	be 1e 00 00 00       	mov    $0x1e,%esi
  8000bb:	48 bf d3 16 80 00 00 	movabs $0x8016d3,%rdi
  8000c2:	00 00 00 
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	49 b8 c8 03 80 00 00 	movabs $0x8003c8,%r8
  8000d1:	00 00 00 
  8000d4:	41 ff d0             	callq  *%r8
    panic("sys_page_map: %i", r);
  8000d7:	89 c1                	mov    %eax,%ecx
  8000d9:	48 ba e3 16 80 00 00 	movabs $0x8016e3,%rdx
  8000e0:	00 00 00 
  8000e3:	be 20 00 00 00       	mov    $0x20,%esi
  8000e8:	48 bf d3 16 80 00 00 	movabs $0x8016d3,%rdi
  8000ef:	00 00 00 
  8000f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f7:	49 b8 c8 03 80 00 00 	movabs $0x8003c8,%r8
  8000fe:	00 00 00 
  800101:	41 ff d0             	callq  *%r8
    panic("sys_page_unmap: %i", r);
  800104:	89 c1                	mov    %eax,%ecx
  800106:	48 ba f4 16 80 00 00 	movabs $0x8016f4,%rdx
  80010d:	00 00 00 
  800110:	be 23 00 00 00       	mov    $0x23,%esi
  800115:	48 bf d3 16 80 00 00 	movabs $0x8016d3,%rdi
  80011c:	00 00 00 
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	49 b8 c8 03 80 00 00 	movabs $0x8003c8,%r8
  80012b:	00 00 00 
  80012e:	41 ff d0             	callq  *%r8

0000000000800131 <dumbfork>:

envid_t
dumbfork(void) {
  800131:	55                   	push   %rbp
  800132:	48 89 e5             	mov    %rsp,%rbp
  800135:	41 56                	push   %r14
  800137:	41 55                	push   %r13
  800139:	41 54                	push   %r12
  80013b:	53                   	push   %rbx
  80013c:	48 83 ec 10          	sub    $0x10,%rsp

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  800140:	b8 07 00 00 00       	mov    $0x7,%eax
  800145:	cd 30                	int    $0x30
  800147:	89 c3                	mov    %eax,%ebx
  // so that the child will appear to have called sys_exofork() too -
  // except that in the child, this "fake" call to sys_exofork()
  // will return 0 instead of the envid of the child.

  envid = sys_exofork();
  if (envid < 0) {
  800149:	85 c0                	test   %eax,%eax
  80014b:	0f 88 8e 00 00 00    	js     8001df <dumbfork+0xae>
  800151:	41 89 c4             	mov    %eax,%r12d
    panic("sys_exofork: %i\n", envid);
  }
  if (envid == 0) {
  800154:	0f 84 b2 00 00 00    	je     80020c <dumbfork+0xdb>
  }

  // We're the parent.
  // Eagerly copy our entire address space into the child.
  // This is NOT what you should do in your fork implementation.
  for (addr = (uint8_t *)UTEXT; addr < end; addr += PGSIZE)
  80015a:	48 c7 45 d8 00 00 80 	movq   $0x800000,-0x28(%rbp)
  800161:	00 
  800162:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  800169:	00 00 00 
  80016c:	48 3d 00 00 80 00    	cmp    $0x800000,%rax
  800172:	76 2c                	jbe    8001a0 <dumbfork+0x6f>
  800174:	be 00 00 80 00       	mov    $0x800000,%esi
    duppage(envid, addr);
  800179:	49 be 2a 00 80 00 00 	movabs $0x80002a,%r14
  800180:	00 00 00 
  for (addr = (uint8_t *)UTEXT; addr < end; addr += PGSIZE)
  800183:	49 89 c5             	mov    %rax,%r13
    duppage(envid, addr);
  800186:	44 89 e7             	mov    %r12d,%edi
  800189:	41 ff d6             	callq  *%r14
  for (addr = (uint8_t *)UTEXT; addr < end; addr += PGSIZE)
  80018c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800190:	48 8d b0 00 10 00 00 	lea    0x1000(%rax),%rsi
  800197:	48 89 75 d8          	mov    %rsi,-0x28(%rbp)
  80019b:	4c 39 ee             	cmp    %r13,%rsi
  80019e:	72 e6                	jb     800186 <dumbfork+0x55>

  // Also copy the stack we are currently running on.
  duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a0:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  8001a4:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  8001ab:	89 df                	mov    %ebx,%edi
  8001ad:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8001b4:	00 00 00 
  8001b7:	ff d0                	callq  *%rax

  // Start the child environment running
  if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	be 02 00 00 00       	mov    $0x2,%esi
  8001be:	89 df                	mov    %ebx,%edi
  8001c0:	48 b8 66 15 80 00 00 	movabs $0x801566,%rax
  8001c7:	00 00 00 
  8001ca:	ff d0                	callq  *%rax
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	78 6e                	js     80023e <dumbfork+0x10d>
    panic("sys_env_set_status: %i", r);

  return envid;
}
  8001d0:	89 d8                	mov    %ebx,%eax
  8001d2:	48 83 c4 10          	add    $0x10,%rsp
  8001d6:	5b                   	pop    %rbx
  8001d7:	41 5c                	pop    %r12
  8001d9:	41 5d                	pop    %r13
  8001db:	41 5e                	pop    %r14
  8001dd:	5d                   	pop    %rbp
  8001de:	c3                   	retq   
    panic("sys_exofork: %i\n", envid);
  8001df:	89 c1                	mov    %eax,%ecx
  8001e1:	48 ba 07 17 80 00 00 	movabs $0x801707,%rdx
  8001e8:	00 00 00 
  8001eb:	be 35 00 00 00       	mov    $0x35,%esi
  8001f0:	48 bf d3 16 80 00 00 	movabs $0x8016d3,%rdi
  8001f7:	00 00 00 
  8001fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ff:	49 b8 c8 03 80 00 00 	movabs $0x8003c8,%r8
  800206:	00 00 00 
  800209:	41 ff d0             	callq  *%r8
    thisenv = &envs[ENVX(sys_getenvid())];
  80020c:	48 b8 fc 13 80 00 00 	movabs $0x8013fc,%rax
  800213:	00 00 00 
  800216:	ff d0                	callq  *%rax
  800218:	25 ff 03 00 00       	and    $0x3ff,%eax
  80021d:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800221:	48 c1 e0 05          	shl    $0x5,%rax
  800225:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80022c:	00 00 00 
  80022f:	48 01 d0             	add    %rdx,%rax
  800232:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  800239:	00 00 00 
    return 0;
  80023c:	eb 92                	jmp    8001d0 <dumbfork+0x9f>
    panic("sys_env_set_status: %i", r);
  80023e:	89 c1                	mov    %eax,%ecx
  800240:	48 ba 18 17 80 00 00 	movabs $0x801718,%rdx
  800247:	00 00 00 
  80024a:	be 4b 00 00 00       	mov    $0x4b,%esi
  80024f:	48 bf d3 16 80 00 00 	movabs $0x8016d3,%rdi
  800256:	00 00 00 
  800259:	b8 00 00 00 00       	mov    $0x0,%eax
  80025e:	49 b8 c8 03 80 00 00 	movabs $0x8003c8,%r8
  800265:	00 00 00 
  800268:	41 ff d0             	callq  *%r8

000000000080026b <umain>:
umain(int argc, char **argv) {
  80026b:	55                   	push   %rbp
  80026c:	48 89 e5             	mov    %rsp,%rbp
  80026f:	41 57                	push   %r15
  800271:	41 56                	push   %r14
  800273:	41 55                	push   %r13
  800275:	41 54                	push   %r12
  800277:	53                   	push   %rbx
  800278:	48 83 ec 08          	sub    $0x8,%rsp
  who = dumbfork();
  80027c:	48 b8 31 01 80 00 00 	movabs $0x800131,%rax
  800283:	00 00 00 
  800286:	ff d0                	callq  *%rax
  800288:	41 89 c5             	mov    %eax,%r13d
  for (i = 0; i < (who ? 10 : 20); i++) {
  80028b:	85 c0                	test   %eax,%eax
  80028d:	49 bc 2f 17 80 00 00 	movabs $0x80172f,%r12
  800294:	00 00 00 
  800297:	48 b8 36 17 80 00 00 	movabs $0x801736,%rax
  80029e:	00 00 00 
  8002a1:	4c 0f 44 e0          	cmove  %rax,%r12
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
    cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8002aa:	49 bf 6a 05 80 00 00 	movabs $0x80056a,%r15
  8002b1:	00 00 00 
    sys_yield();
  8002b4:	49 be 1c 14 80 00 00 	movabs $0x80141c,%r14
  8002bb:	00 00 00 
  for (i = 0; i < (who ? 10 : 20); i++) {
  8002be:	eb 22                	jmp    8002e2 <umain+0x77>
  8002c0:	83 fb 13             	cmp    $0x13,%ebx
  8002c3:	7f 27                	jg     8002ec <umain+0x81>
    cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8002c5:	4c 89 e2             	mov    %r12,%rdx
  8002c8:	89 de                	mov    %ebx,%esi
  8002ca:	48 bf 3c 17 80 00 00 	movabs $0x80173c,%rdi
  8002d1:	00 00 00 
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	41 ff d7             	callq  *%r15
    sys_yield();
  8002dc:	41 ff d6             	callq  *%r14
  for (i = 0; i < (who ? 10 : 20); i++) {
  8002df:	83 c3 01             	add    $0x1,%ebx
  8002e2:	45 85 ed             	test   %r13d,%r13d
  8002e5:	74 d9                	je     8002c0 <umain+0x55>
  8002e7:	83 fb 09             	cmp    $0x9,%ebx
  8002ea:	7e d9                	jle    8002c5 <umain+0x5a>
}
  8002ec:	48 83 c4 08          	add    $0x8,%rsp
  8002f0:	5b                   	pop    %rbx
  8002f1:	41 5c                	pop    %r12
  8002f3:	41 5d                	pop    %r13
  8002f5:	41 5e                	pop    %r14
  8002f7:	41 5f                	pop    %r15
  8002f9:	5d                   	pop    %rbp
  8002fa:	c3                   	retq   

00000000008002fb <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  8002fb:	55                   	push   %rbp
  8002fc:	48 89 e5             	mov    %rsp,%rbp
  8002ff:	41 56                	push   %r14
  800301:	41 55                	push   %r13
  800303:	41 54                	push   %r12
  800305:	53                   	push   %rbx
  800306:	41 89 fd             	mov    %edi,%r13d
  800309:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80030c:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800313:	00 00 00 
  800316:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80031d:	00 00 00 
  800320:	48 39 c2             	cmp    %rax,%rdx
  800323:	73 23                	jae    800348 <libmain+0x4d>
  800325:	48 89 d3             	mov    %rdx,%rbx
  800328:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80032c:	48 29 d0             	sub    %rdx,%rax
  80032f:	48 c1 e8 03          	shr    $0x3,%rax
  800333:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800338:	b8 00 00 00 00       	mov    $0x0,%eax
  80033d:	ff 13                	callq  *(%rbx)
    ctor++;
  80033f:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800343:	4c 39 e3             	cmp    %r12,%rbx
  800346:	75 f0                	jne    800338 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800348:	48 b8 fc 13 80 00 00 	movabs $0x8013fc,%rax
  80034f:	00 00 00 
  800352:	ff d0                	callq  *%rax
  800354:	25 ff 03 00 00       	and    $0x3ff,%eax
  800359:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80035d:	48 c1 e0 05          	shl    $0x5,%rax
  800361:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800368:	00 00 00 
  80036b:	48 01 d0             	add    %rdx,%rax
  80036e:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  800375:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800378:	45 85 ed             	test   %r13d,%r13d
  80037b:	7e 0d                	jle    80038a <libmain+0x8f>
    binaryname = argv[0];
  80037d:	49 8b 06             	mov    (%r14),%rax
  800380:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800387:	00 00 00 

  // call user main routine
  umain(argc, argv);
  80038a:	4c 89 f6             	mov    %r14,%rsi
  80038d:	44 89 ef             	mov    %r13d,%edi
  800390:	48 b8 6b 02 80 00 00 	movabs $0x80026b,%rax
  800397:	00 00 00 
  80039a:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  80039c:	48 b8 b1 03 80 00 00 	movabs $0x8003b1,%rax
  8003a3:	00 00 00 
  8003a6:	ff d0                	callq  *%rax
#endif
}
  8003a8:	5b                   	pop    %rbx
  8003a9:	41 5c                	pop    %r12
  8003ab:	41 5d                	pop    %r13
  8003ad:	41 5e                	pop    %r14
  8003af:	5d                   	pop    %rbp
  8003b0:	c3                   	retq   

00000000008003b1 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8003b1:	55                   	push   %rbp
  8003b2:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8003b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8003ba:	48 b8 9c 13 80 00 00 	movabs $0x80139c,%rax
  8003c1:	00 00 00 
  8003c4:	ff d0                	callq  *%rax
}
  8003c6:	5d                   	pop    %rbp
  8003c7:	c3                   	retq   

00000000008003c8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8003c8:	55                   	push   %rbp
  8003c9:	48 89 e5             	mov    %rsp,%rbp
  8003cc:	41 56                	push   %r14
  8003ce:	41 55                	push   %r13
  8003d0:	41 54                	push   %r12
  8003d2:	53                   	push   %rbx
  8003d3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8003da:	49 89 fd             	mov    %rdi,%r13
  8003dd:	41 89 f6             	mov    %esi,%r14d
  8003e0:	49 89 d4             	mov    %rdx,%r12
  8003e3:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8003ea:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8003f1:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8003f8:	84 c0                	test   %al,%al
  8003fa:	74 26                	je     800422 <_panic+0x5a>
  8003fc:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800403:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80040a:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80040e:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800412:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800416:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80041a:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80041e:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800422:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800429:	00 00 00 
  80042c:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800433:	00 00 00 
  800436:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80043a:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800441:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800448:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80044f:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800456:	00 00 00 
  800459:	48 8b 18             	mov    (%rax),%rbx
  80045c:	48 b8 fc 13 80 00 00 	movabs $0x8013fc,%rax
  800463:	00 00 00 
  800466:	ff d0                	callq  *%rax
  800468:	45 89 f0             	mov    %r14d,%r8d
  80046b:	4c 89 e9             	mov    %r13,%rcx
  80046e:	48 89 da             	mov    %rbx,%rdx
  800471:	89 c6                	mov    %eax,%esi
  800473:	48 bf 58 17 80 00 00 	movabs $0x801758,%rdi
  80047a:	00 00 00 
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	48 bb 6a 05 80 00 00 	movabs $0x80056a,%rbx
  800489:	00 00 00 
  80048c:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80048e:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800495:	4c 89 e7             	mov    %r12,%rdi
  800498:	48 b8 02 05 80 00 00 	movabs $0x800502,%rax
  80049f:	00 00 00 
  8004a2:	ff d0                	callq  *%rax
  cprintf("\n");
  8004a4:	48 bf 4c 17 80 00 00 	movabs $0x80174c,%rdi
  8004ab:	00 00 00 
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8004b5:	cc                   	int3   
  while (1)
  8004b6:	eb fd                	jmp    8004b5 <_panic+0xed>

00000000008004b8 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8004b8:	55                   	push   %rbp
  8004b9:	48 89 e5             	mov    %rsp,%rbp
  8004bc:	53                   	push   %rbx
  8004bd:	48 83 ec 08          	sub    $0x8,%rsp
  8004c1:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8004c4:	8b 06                	mov    (%rsi),%eax
  8004c6:	8d 50 01             	lea    0x1(%rax),%edx
  8004c9:	89 16                	mov    %edx,(%rsi)
  8004cb:	48 98                	cltq   
  8004cd:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8004d2:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8004d8:	74 0b                	je     8004e5 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8004da:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8004de:	48 83 c4 08          	add    $0x8,%rsp
  8004e2:	5b                   	pop    %rbx
  8004e3:	5d                   	pop    %rbp
  8004e4:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8004e5:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8004e9:	be ff 00 00 00       	mov    $0xff,%esi
  8004ee:	48 b8 5e 13 80 00 00 	movabs $0x80135e,%rax
  8004f5:	00 00 00 
  8004f8:	ff d0                	callq  *%rax
    b->idx = 0;
  8004fa:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800500:	eb d8                	jmp    8004da <putch+0x22>

0000000000800502 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800502:	55                   	push   %rbp
  800503:	48 89 e5             	mov    %rsp,%rbp
  800506:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80050d:	48 89 fa             	mov    %rdi,%rdx
  800510:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800513:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80051a:	00 00 00 
  b.cnt = 0;
  80051d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800524:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800527:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80052e:	48 bf b8 04 80 00 00 	movabs $0x8004b8,%rdi
  800535:	00 00 00 
  800538:	48 b8 28 07 80 00 00 	movabs $0x800728,%rax
  80053f:	00 00 00 
  800542:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800544:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80054b:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800552:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800556:	48 b8 5e 13 80 00 00 	movabs $0x80135e,%rax
  80055d:	00 00 00 
  800560:	ff d0                	callq  *%rax

  return b.cnt;
}
  800562:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800568:	c9                   	leaveq 
  800569:	c3                   	retq   

000000000080056a <cprintf>:

int
cprintf(const char *fmt, ...) {
  80056a:	55                   	push   %rbp
  80056b:	48 89 e5             	mov    %rsp,%rbp
  80056e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800575:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80057c:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800583:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80058a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800591:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800598:	84 c0                	test   %al,%al
  80059a:	74 20                	je     8005bc <cprintf+0x52>
  80059c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8005a0:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8005a4:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8005a8:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8005ac:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8005b0:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8005b4:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8005b8:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8005bc:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8005c3:	00 00 00 
  8005c6:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8005cd:	00 00 00 
  8005d0:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8005d4:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8005db:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8005e2:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8005e9:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8005f0:	48 b8 02 05 80 00 00 	movabs $0x800502,%rax
  8005f7:	00 00 00 
  8005fa:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8005fc:	c9                   	leaveq 
  8005fd:	c3                   	retq   

00000000008005fe <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8005fe:	55                   	push   %rbp
  8005ff:	48 89 e5             	mov    %rsp,%rbp
  800602:	41 57                	push   %r15
  800604:	41 56                	push   %r14
  800606:	41 55                	push   %r13
  800608:	41 54                	push   %r12
  80060a:	53                   	push   %rbx
  80060b:	48 83 ec 18          	sub    $0x18,%rsp
  80060f:	49 89 fc             	mov    %rdi,%r12
  800612:	49 89 f5             	mov    %rsi,%r13
  800615:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800619:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80061c:	41 89 cf             	mov    %ecx,%r15d
  80061f:	49 39 d7             	cmp    %rdx,%r15
  800622:	76 45                	jbe    800669 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800624:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800628:	85 db                	test   %ebx,%ebx
  80062a:	7e 0e                	jle    80063a <printnum+0x3c>
      putch(padc, putdat);
  80062c:	4c 89 ee             	mov    %r13,%rsi
  80062f:	44 89 f7             	mov    %r14d,%edi
  800632:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800635:	83 eb 01             	sub    $0x1,%ebx
  800638:	75 f2                	jne    80062c <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80063a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80063e:	ba 00 00 00 00       	mov    $0x0,%edx
  800643:	49 f7 f7             	div    %r15
  800646:	48 b8 7b 17 80 00 00 	movabs $0x80177b,%rax
  80064d:	00 00 00 
  800650:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800654:	4c 89 ee             	mov    %r13,%rsi
  800657:	41 ff d4             	callq  *%r12
}
  80065a:	48 83 c4 18          	add    $0x18,%rsp
  80065e:	5b                   	pop    %rbx
  80065f:	41 5c                	pop    %r12
  800661:	41 5d                	pop    %r13
  800663:	41 5e                	pop    %r14
  800665:	41 5f                	pop    %r15
  800667:	5d                   	pop    %rbp
  800668:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800669:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80066d:	ba 00 00 00 00       	mov    $0x0,%edx
  800672:	49 f7 f7             	div    %r15
  800675:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800679:	48 89 c2             	mov    %rax,%rdx
  80067c:	48 b8 fe 05 80 00 00 	movabs $0x8005fe,%rax
  800683:	00 00 00 
  800686:	ff d0                	callq  *%rax
  800688:	eb b0                	jmp    80063a <printnum+0x3c>

000000000080068a <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80068a:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80068e:	48 8b 06             	mov    (%rsi),%rax
  800691:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800695:	73 0a                	jae    8006a1 <sprintputch+0x17>
    *b->buf++ = ch;
  800697:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80069b:	48 89 16             	mov    %rdx,(%rsi)
  80069e:	40 88 38             	mov    %dil,(%rax)
}
  8006a1:	c3                   	retq   

00000000008006a2 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8006a2:	55                   	push   %rbp
  8006a3:	48 89 e5             	mov    %rsp,%rbp
  8006a6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8006ad:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8006b4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8006bb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8006c2:	84 c0                	test   %al,%al
  8006c4:	74 20                	je     8006e6 <printfmt+0x44>
  8006c6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8006ca:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8006ce:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8006d2:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8006d6:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8006da:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8006de:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8006e2:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8006e6:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8006ed:	00 00 00 
  8006f0:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8006f7:	00 00 00 
  8006fa:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8006fe:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800705:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80070c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800713:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80071a:	48 b8 28 07 80 00 00 	movabs $0x800728,%rax
  800721:	00 00 00 
  800724:	ff d0                	callq  *%rax
}
  800726:	c9                   	leaveq 
  800727:	c3                   	retq   

0000000000800728 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800728:	55                   	push   %rbp
  800729:	48 89 e5             	mov    %rsp,%rbp
  80072c:	41 57                	push   %r15
  80072e:	41 56                	push   %r14
  800730:	41 55                	push   %r13
  800732:	41 54                	push   %r12
  800734:	53                   	push   %rbx
  800735:	48 83 ec 48          	sub    $0x48,%rsp
  800739:	49 89 fd             	mov    %rdi,%r13
  80073c:	49 89 f7             	mov    %rsi,%r15
  80073f:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800742:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800746:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80074a:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80074e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800752:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800756:	41 0f b6 3e          	movzbl (%r14),%edi
  80075a:	83 ff 25             	cmp    $0x25,%edi
  80075d:	74 18                	je     800777 <vprintfmt+0x4f>
      if (ch == '\0')
  80075f:	85 ff                	test   %edi,%edi
  800761:	0f 84 8c 06 00 00    	je     800df3 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800767:	4c 89 fe             	mov    %r15,%rsi
  80076a:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80076d:	49 89 de             	mov    %rbx,%r14
  800770:	eb e0                	jmp    800752 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800772:	49 89 de             	mov    %rbx,%r14
  800775:	eb db                	jmp    800752 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800777:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80077b:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80077f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800786:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80078c:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800790:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800795:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80079b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8007a1:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8007a6:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8007ab:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8007af:	0f b6 13             	movzbl (%rbx),%edx
  8007b2:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8007b5:	3c 55                	cmp    $0x55,%al
  8007b7:	0f 87 8b 05 00 00    	ja     800d48 <vprintfmt+0x620>
  8007bd:	0f b6 c0             	movzbl %al,%eax
  8007c0:	49 bb 60 18 80 00 00 	movabs $0x801860,%r11
  8007c7:	00 00 00 
  8007ca:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8007ce:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8007d1:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8007d5:	eb d4                	jmp    8007ab <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8007d7:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8007da:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8007de:	eb cb                	jmp    8007ab <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8007e0:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8007e3:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8007e7:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8007eb:	8d 50 d0             	lea    -0x30(%rax),%edx
  8007ee:	83 fa 09             	cmp    $0x9,%edx
  8007f1:	77 7e                	ja     800871 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8007f3:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8007f7:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8007fb:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800800:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800804:	8d 50 d0             	lea    -0x30(%rax),%edx
  800807:	83 fa 09             	cmp    $0x9,%edx
  80080a:	76 e7                	jbe    8007f3 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80080c:	4c 89 f3             	mov    %r14,%rbx
  80080f:	eb 19                	jmp    80082a <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800811:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800814:	83 f8 2f             	cmp    $0x2f,%eax
  800817:	77 2a                	ja     800843 <vprintfmt+0x11b>
  800819:	89 c2                	mov    %eax,%edx
  80081b:	4c 01 d2             	add    %r10,%rdx
  80081e:	83 c0 08             	add    $0x8,%eax
  800821:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800824:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800827:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80082a:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80082e:	0f 89 77 ff ff ff    	jns    8007ab <vprintfmt+0x83>
          width = precision, precision = -1;
  800834:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800838:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80083e:	e9 68 ff ff ff       	jmpq   8007ab <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800843:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800847:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80084b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80084f:	eb d3                	jmp    800824 <vprintfmt+0xfc>
        if (width < 0)
  800851:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800854:	85 c0                	test   %eax,%eax
  800856:	41 0f 48 c0          	cmovs  %r8d,%eax
  80085a:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80085d:	4c 89 f3             	mov    %r14,%rbx
  800860:	e9 46 ff ff ff       	jmpq   8007ab <vprintfmt+0x83>
  800865:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800868:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80086c:	e9 3a ff ff ff       	jmpq   8007ab <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800871:	4c 89 f3             	mov    %r14,%rbx
  800874:	eb b4                	jmp    80082a <vprintfmt+0x102>
        lflag++;
  800876:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800879:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80087c:	e9 2a ff ff ff       	jmpq   8007ab <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800881:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800884:	83 f8 2f             	cmp    $0x2f,%eax
  800887:	77 19                	ja     8008a2 <vprintfmt+0x17a>
  800889:	89 c2                	mov    %eax,%edx
  80088b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80088f:	83 c0 08             	add    $0x8,%eax
  800892:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800895:	4c 89 fe             	mov    %r15,%rsi
  800898:	8b 3a                	mov    (%rdx),%edi
  80089a:	41 ff d5             	callq  *%r13
        break;
  80089d:	e9 b0 fe ff ff       	jmpq   800752 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8008a2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ae:	eb e5                	jmp    800895 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8008b0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b3:	83 f8 2f             	cmp    $0x2f,%eax
  8008b6:	77 5b                	ja     800913 <vprintfmt+0x1eb>
  8008b8:	89 c2                	mov    %eax,%edx
  8008ba:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008be:	83 c0 08             	add    $0x8,%eax
  8008c1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c4:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8008c6:	89 c8                	mov    %ecx,%eax
  8008c8:	c1 f8 1f             	sar    $0x1f,%eax
  8008cb:	31 c1                	xor    %eax,%ecx
  8008cd:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008cf:	83 f9 0b             	cmp    $0xb,%ecx
  8008d2:	7f 4d                	jg     800921 <vprintfmt+0x1f9>
  8008d4:	48 63 c1             	movslq %ecx,%rax
  8008d7:	48 ba 20 1b 80 00 00 	movabs $0x801b20,%rdx
  8008de:	00 00 00 
  8008e1:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8008e5:	48 85 c0             	test   %rax,%rax
  8008e8:	74 37                	je     800921 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8008ea:	48 89 c1             	mov    %rax,%rcx
  8008ed:	48 ba 9c 17 80 00 00 	movabs $0x80179c,%rdx
  8008f4:	00 00 00 
  8008f7:	4c 89 fe             	mov    %r15,%rsi
  8008fa:	4c 89 ef             	mov    %r13,%rdi
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800902:	48 bb a2 06 80 00 00 	movabs $0x8006a2,%rbx
  800909:	00 00 00 
  80090c:	ff d3                	callq  *%rbx
  80090e:	e9 3f fe ff ff       	jmpq   800752 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800913:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800917:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80091b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80091f:	eb a3                	jmp    8008c4 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800921:	48 ba 93 17 80 00 00 	movabs $0x801793,%rdx
  800928:	00 00 00 
  80092b:	4c 89 fe             	mov    %r15,%rsi
  80092e:	4c 89 ef             	mov    %r13,%rdi
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	48 bb a2 06 80 00 00 	movabs $0x8006a2,%rbx
  80093d:	00 00 00 
  800940:	ff d3                	callq  *%rbx
  800942:	e9 0b fe ff ff       	jmpq   800752 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800947:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094a:	83 f8 2f             	cmp    $0x2f,%eax
  80094d:	77 4b                	ja     80099a <vprintfmt+0x272>
  80094f:	89 c2                	mov    %eax,%edx
  800951:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800955:	83 c0 08             	add    $0x8,%eax
  800958:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095b:	48 8b 02             	mov    (%rdx),%rax
  80095e:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800962:	48 85 c0             	test   %rax,%rax
  800965:	0f 84 05 04 00 00    	je     800d70 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80096b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80096f:	7e 06                	jle    800977 <vprintfmt+0x24f>
  800971:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800975:	75 31                	jne    8009a8 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800977:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80097b:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80097f:	0f b6 00             	movzbl (%rax),%eax
  800982:	0f be f8             	movsbl %al,%edi
  800985:	85 ff                	test   %edi,%edi
  800987:	0f 84 c3 00 00 00    	je     800a50 <vprintfmt+0x328>
  80098d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800991:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800995:	e9 85 00 00 00       	jmpq   800a1f <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80099a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80099e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a6:	eb b3                	jmp    80095b <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009a8:	49 63 f4             	movslq %r12d,%rsi
  8009ab:	48 89 c7             	mov    %rax,%rdi
  8009ae:	48 b8 ff 0e 80 00 00 	movabs $0x800eff,%rax
  8009b5:	00 00 00 
  8009b8:	ff d0                	callq  *%rax
  8009ba:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8009bd:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8009c0:	85 f6                	test   %esi,%esi
  8009c2:	7e 22                	jle    8009e6 <vprintfmt+0x2be>
            putch(padc, putdat);
  8009c4:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8009c8:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8009cc:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8009d0:	4c 89 fe             	mov    %r15,%rsi
  8009d3:	89 df                	mov    %ebx,%edi
  8009d5:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  8009d8:	41 83 ec 01          	sub    $0x1,%r12d
  8009dc:	75 f2                	jne    8009d0 <vprintfmt+0x2a8>
  8009de:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8009e2:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e6:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8009ea:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8009ee:	0f b6 00             	movzbl (%rax),%eax
  8009f1:	0f be f8             	movsbl %al,%edi
  8009f4:	85 ff                	test   %edi,%edi
  8009f6:	0f 84 56 fd ff ff    	je     800752 <vprintfmt+0x2a>
  8009fc:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a00:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a04:	eb 19                	jmp    800a1f <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a06:	4c 89 fe             	mov    %r15,%rsi
  800a09:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0c:	41 83 ee 01          	sub    $0x1,%r14d
  800a10:	48 83 c3 01          	add    $0x1,%rbx
  800a14:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800a18:	0f be f8             	movsbl %al,%edi
  800a1b:	85 ff                	test   %edi,%edi
  800a1d:	74 29                	je     800a48 <vprintfmt+0x320>
  800a1f:	45 85 e4             	test   %r12d,%r12d
  800a22:	78 06                	js     800a2a <vprintfmt+0x302>
  800a24:	41 83 ec 01          	sub    $0x1,%r12d
  800a28:	78 48                	js     800a72 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800a2a:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800a2e:	74 d6                	je     800a06 <vprintfmt+0x2de>
  800a30:	0f be c0             	movsbl %al,%eax
  800a33:	83 e8 20             	sub    $0x20,%eax
  800a36:	83 f8 5e             	cmp    $0x5e,%eax
  800a39:	76 cb                	jbe    800a06 <vprintfmt+0x2de>
            putch('?', putdat);
  800a3b:	4c 89 fe             	mov    %r15,%rsi
  800a3e:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800a43:	41 ff d5             	callq  *%r13
  800a46:	eb c4                	jmp    800a0c <vprintfmt+0x2e4>
  800a48:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800a4c:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800a50:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800a53:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a57:	0f 8e f5 fc ff ff    	jle    800752 <vprintfmt+0x2a>
          putch(' ', putdat);
  800a5d:	4c 89 fe             	mov    %r15,%rsi
  800a60:	bf 20 00 00 00       	mov    $0x20,%edi
  800a65:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800a68:	83 eb 01             	sub    $0x1,%ebx
  800a6b:	75 f0                	jne    800a5d <vprintfmt+0x335>
  800a6d:	e9 e0 fc ff ff       	jmpq   800752 <vprintfmt+0x2a>
  800a72:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800a76:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800a7a:	eb d4                	jmp    800a50 <vprintfmt+0x328>
  if (lflag >= 2)
  800a7c:	83 f9 01             	cmp    $0x1,%ecx
  800a7f:	7f 1d                	jg     800a9e <vprintfmt+0x376>
  else if (lflag)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 5e                	je     800ae3 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800a85:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a88:	83 f8 2f             	cmp    $0x2f,%eax
  800a8b:	77 48                	ja     800ad5 <vprintfmt+0x3ad>
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a93:	83 c0 08             	add    $0x8,%eax
  800a96:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a99:	48 8b 1a             	mov    (%rdx),%rbx
  800a9c:	eb 17                	jmp    800ab5 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800a9e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aa1:	83 f8 2f             	cmp    $0x2f,%eax
  800aa4:	77 21                	ja     800ac7 <vprintfmt+0x39f>
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800aac:	83 c0 08             	add    $0x8,%eax
  800aaf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ab2:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800ab5:	48 85 db             	test   %rbx,%rbx
  800ab8:	78 50                	js     800b0a <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800aba:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800abd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ac2:	e9 b4 01 00 00       	jmpq   800c7b <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800ac7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800acb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800acf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ad3:	eb dd                	jmp    800ab2 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800ad5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ad9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800add:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ae1:	eb b6                	jmp    800a99 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800ae3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae6:	83 f8 2f             	cmp    $0x2f,%eax
  800ae9:	77 11                	ja     800afc <vprintfmt+0x3d4>
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800af1:	83 c0 08             	add    $0x8,%eax
  800af4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800af7:	48 63 1a             	movslq (%rdx),%rbx
  800afa:	eb b9                	jmp    800ab5 <vprintfmt+0x38d>
  800afc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b00:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b04:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b08:	eb ed                	jmp    800af7 <vprintfmt+0x3cf>
          putch('-', putdat);
  800b0a:	4c 89 fe             	mov    %r15,%rsi
  800b0d:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b12:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800b15:	48 89 da             	mov    %rbx,%rdx
  800b18:	48 f7 da             	neg    %rdx
        base = 10;
  800b1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b20:	e9 56 01 00 00       	jmpq   800c7b <vprintfmt+0x553>
  if (lflag >= 2)
  800b25:	83 f9 01             	cmp    $0x1,%ecx
  800b28:	7f 25                	jg     800b4f <vprintfmt+0x427>
  else if (lflag)
  800b2a:	85 c9                	test   %ecx,%ecx
  800b2c:	74 5e                	je     800b8c <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800b2e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b31:	83 f8 2f             	cmp    $0x2f,%eax
  800b34:	77 48                	ja     800b7e <vprintfmt+0x456>
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b3c:	83 c0 08             	add    $0x8,%eax
  800b3f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b42:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800b45:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b4a:	e9 2c 01 00 00       	jmpq   800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b4f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b52:	83 f8 2f             	cmp    $0x2f,%eax
  800b55:	77 19                	ja     800b70 <vprintfmt+0x448>
  800b57:	89 c2                	mov    %eax,%edx
  800b59:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b5d:	83 c0 08             	add    $0x8,%eax
  800b60:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b63:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800b66:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b6b:	e9 0b 01 00 00       	jmpq   800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800b70:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b74:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b78:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b7c:	eb e5                	jmp    800b63 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800b7e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b82:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b86:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b8a:	eb b6                	jmp    800b42 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800b8c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b8f:	83 f8 2f             	cmp    $0x2f,%eax
  800b92:	77 18                	ja     800bac <vprintfmt+0x484>
  800b94:	89 c2                	mov    %eax,%edx
  800b96:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b9a:	83 c0 08             	add    $0x8,%eax
  800b9d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ba0:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800ba2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba7:	e9 cf 00 00 00       	jmpq   800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800bac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bb0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bb4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bb8:	eb e6                	jmp    800ba0 <vprintfmt+0x478>
  if (lflag >= 2)
  800bba:	83 f9 01             	cmp    $0x1,%ecx
  800bbd:	7f 25                	jg     800be4 <vprintfmt+0x4bc>
  else if (lflag)
  800bbf:	85 c9                	test   %ecx,%ecx
  800bc1:	74 5b                	je     800c1e <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800bc3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bc6:	83 f8 2f             	cmp    $0x2f,%eax
  800bc9:	77 45                	ja     800c10 <vprintfmt+0x4e8>
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bd1:	83 c0 08             	add    $0x8,%eax
  800bd4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bd7:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800bda:	b9 08 00 00 00       	mov    $0x8,%ecx
  800bdf:	e9 97 00 00 00       	jmpq   800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800be4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800be7:	83 f8 2f             	cmp    $0x2f,%eax
  800bea:	77 16                	ja     800c02 <vprintfmt+0x4da>
  800bec:	89 c2                	mov    %eax,%edx
  800bee:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bf2:	83 c0 08             	add    $0x8,%eax
  800bf5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bf8:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800bfb:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c00:	eb 79                	jmp    800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c02:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c06:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c0a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c0e:	eb e8                	jmp    800bf8 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c10:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c14:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c18:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c1c:	eb b9                	jmp    800bd7 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800c1e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c21:	83 f8 2f             	cmp    $0x2f,%eax
  800c24:	77 15                	ja     800c3b <vprintfmt+0x513>
  800c26:	89 c2                	mov    %eax,%edx
  800c28:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c2c:	83 c0 08             	add    $0x8,%eax
  800c2f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c32:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800c34:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c39:	eb 40                	jmp    800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c3b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c3f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c43:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c47:	eb e9                	jmp    800c32 <vprintfmt+0x50a>
        putch('0', putdat);
  800c49:	4c 89 fe             	mov    %r15,%rsi
  800c4c:	bf 30 00 00 00       	mov    $0x30,%edi
  800c51:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800c54:	4c 89 fe             	mov    %r15,%rsi
  800c57:	bf 78 00 00 00       	mov    $0x78,%edi
  800c5c:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800c5f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c62:	83 f8 2f             	cmp    $0x2f,%eax
  800c65:	77 34                	ja     800c9b <vprintfmt+0x573>
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c6d:	83 c0 08             	add    $0x8,%eax
  800c70:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c73:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800c76:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800c7b:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800c80:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800c84:	4c 89 fe             	mov    %r15,%rsi
  800c87:	4c 89 ef             	mov    %r13,%rdi
  800c8a:	48 b8 fe 05 80 00 00 	movabs $0x8005fe,%rax
  800c91:	00 00 00 
  800c94:	ff d0                	callq  *%rax
        break;
  800c96:	e9 b7 fa ff ff       	jmpq   800752 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800c9b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c9f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ca3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ca7:	eb ca                	jmp    800c73 <vprintfmt+0x54b>
  if (lflag >= 2)
  800ca9:	83 f9 01             	cmp    $0x1,%ecx
  800cac:	7f 22                	jg     800cd0 <vprintfmt+0x5a8>
  else if (lflag)
  800cae:	85 c9                	test   %ecx,%ecx
  800cb0:	74 58                	je     800d0a <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800cb2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cb5:	83 f8 2f             	cmp    $0x2f,%eax
  800cb8:	77 42                	ja     800cfc <vprintfmt+0x5d4>
  800cba:	89 c2                	mov    %eax,%edx
  800cbc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cc0:	83 c0 08             	add    $0x8,%eax
  800cc3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cc6:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800cc9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800cce:	eb ab                	jmp    800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800cd0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cd3:	83 f8 2f             	cmp    $0x2f,%eax
  800cd6:	77 16                	ja     800cee <vprintfmt+0x5c6>
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cde:	83 c0 08             	add    $0x8,%eax
  800ce1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ce4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800ce7:	b9 10 00 00 00       	mov    $0x10,%ecx
  800cec:	eb 8d                	jmp    800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800cee:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cf2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cf6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cfa:	eb e8                	jmp    800ce4 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800cfc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d00:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d04:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d08:	eb bc                	jmp    800cc6 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d0a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d0d:	83 f8 2f             	cmp    $0x2f,%eax
  800d10:	77 18                	ja     800d2a <vprintfmt+0x602>
  800d12:	89 c2                	mov    %eax,%edx
  800d14:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d18:	83 c0 08             	add    $0x8,%eax
  800d1b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d1e:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800d20:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d25:	e9 51 ff ff ff       	jmpq   800c7b <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800d2a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d2e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d32:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d36:	eb e6                	jmp    800d1e <vprintfmt+0x5f6>
        putch(ch, putdat);
  800d38:	4c 89 fe             	mov    %r15,%rsi
  800d3b:	bf 25 00 00 00       	mov    $0x25,%edi
  800d40:	41 ff d5             	callq  *%r13
        break;
  800d43:	e9 0a fa ff ff       	jmpq   800752 <vprintfmt+0x2a>
        putch('%', putdat);
  800d48:	4c 89 fe             	mov    %r15,%rsi
  800d4b:	bf 25 00 00 00       	mov    $0x25,%edi
  800d50:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800d53:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800d57:	0f 84 15 fa ff ff    	je     800772 <vprintfmt+0x4a>
  800d5d:	49 89 de             	mov    %rbx,%r14
  800d60:	49 83 ee 01          	sub    $0x1,%r14
  800d64:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800d69:	75 f5                	jne    800d60 <vprintfmt+0x638>
  800d6b:	e9 e2 f9 ff ff       	jmpq   800752 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800d70:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800d74:	74 06                	je     800d7c <vprintfmt+0x654>
  800d76:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800d7a:	7f 21                	jg     800d9d <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d7c:	bf 28 00 00 00       	mov    $0x28,%edi
  800d81:	48 bb 8d 17 80 00 00 	movabs $0x80178d,%rbx
  800d88:	00 00 00 
  800d8b:	b8 28 00 00 00       	mov    $0x28,%eax
  800d90:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800d94:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800d98:	e9 82 fc ff ff       	jmpq   800a1f <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800d9d:	49 63 f4             	movslq %r12d,%rsi
  800da0:	48 bf 8c 17 80 00 00 	movabs $0x80178c,%rdi
  800da7:	00 00 00 
  800daa:	48 b8 ff 0e 80 00 00 	movabs $0x800eff,%rax
  800db1:	00 00 00 
  800db4:	ff d0                	callq  *%rax
  800db6:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800db9:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800dbc:	48 be 8c 17 80 00 00 	movabs $0x80178c,%rsi
  800dc3:	00 00 00 
  800dc6:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	0f 8f f2 fb ff ff    	jg     8009c4 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dd2:	48 bb 8d 17 80 00 00 	movabs $0x80178d,%rbx
  800dd9:	00 00 00 
  800ddc:	b8 28 00 00 00       	mov    $0x28,%eax
  800de1:	bf 28 00 00 00       	mov    $0x28,%edi
  800de6:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800dea:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800dee:	e9 2c fc ff ff       	jmpq   800a1f <vprintfmt+0x2f7>
}
  800df3:	48 83 c4 48          	add    $0x48,%rsp
  800df7:	5b                   	pop    %rbx
  800df8:	41 5c                	pop    %r12
  800dfa:	41 5d                	pop    %r13
  800dfc:	41 5e                	pop    %r14
  800dfe:	41 5f                	pop    %r15
  800e00:	5d                   	pop    %rbp
  800e01:	c3                   	retq   

0000000000800e02 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e02:	55                   	push   %rbp
  800e03:	48 89 e5             	mov    %rsp,%rbp
  800e06:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e0a:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e0e:	48 63 c6             	movslq %esi,%rax
  800e11:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800e16:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800e1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800e21:	48 85 ff             	test   %rdi,%rdi
  800e24:	74 2a                	je     800e50 <vsnprintf+0x4e>
  800e26:	85 f6                	test   %esi,%esi
  800e28:	7e 26                	jle    800e50 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800e2a:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800e2e:	48 bf 8a 06 80 00 00 	movabs $0x80068a,%rdi
  800e35:	00 00 00 
  800e38:	48 b8 28 07 80 00 00 	movabs $0x800728,%rax
  800e3f:	00 00 00 
  800e42:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800e44:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800e48:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800e4b:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800e4e:	c9                   	leaveq 
  800e4f:	c3                   	retq   
    return -E_INVAL;
  800e50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e55:	eb f7                	jmp    800e4e <vsnprintf+0x4c>

0000000000800e57 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800e57:	55                   	push   %rbp
  800e58:	48 89 e5             	mov    %rsp,%rbp
  800e5b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800e62:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800e69:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800e70:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800e77:	84 c0                	test   %al,%al
  800e79:	74 20                	je     800e9b <snprintf+0x44>
  800e7b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800e7f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800e83:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800e87:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800e8b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800e8f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800e93:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800e97:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800e9b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ea2:	00 00 00 
  800ea5:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800eac:	00 00 00 
  800eaf:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800eb3:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800eba:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800ec1:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800ec8:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800ecf:	48 b8 02 0e 80 00 00 	movabs $0x800e02,%rax
  800ed6:	00 00 00 
  800ed9:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800edb:	c9                   	leaveq 
  800edc:	c3                   	retq   

0000000000800edd <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800edd:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ee0:	74 17                	je     800ef9 <strlen+0x1c>
  800ee2:	48 89 fa             	mov    %rdi,%rdx
  800ee5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800eea:	29 f9                	sub    %edi,%ecx
    n++;
  800eec:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800eef:	48 83 c2 01          	add    $0x1,%rdx
  800ef3:	80 3a 00             	cmpb   $0x0,(%rdx)
  800ef6:	75 f4                	jne    800eec <strlen+0xf>
  800ef8:	c3                   	retq   
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800efe:	c3                   	retq   

0000000000800eff <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800eff:	48 85 f6             	test   %rsi,%rsi
  800f02:	74 24                	je     800f28 <strnlen+0x29>
  800f04:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f07:	74 25                	je     800f2e <strnlen+0x2f>
  800f09:	48 01 fe             	add    %rdi,%rsi
  800f0c:	48 89 fa             	mov    %rdi,%rdx
  800f0f:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f14:	29 f9                	sub    %edi,%ecx
    n++;
  800f16:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f19:	48 83 c2 01          	add    $0x1,%rdx
  800f1d:	48 39 f2             	cmp    %rsi,%rdx
  800f20:	74 11                	je     800f33 <strnlen+0x34>
  800f22:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f25:	75 ef                	jne    800f16 <strnlen+0x17>
  800f27:	c3                   	retq   
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	c3                   	retq   
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f33:	c3                   	retq   

0000000000800f34 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800f34:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800f37:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3c:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800f40:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800f43:	48 83 c2 01          	add    $0x1,%rdx
  800f47:	84 c9                	test   %cl,%cl
  800f49:	75 f1                	jne    800f3c <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800f4b:	c3                   	retq   

0000000000800f4c <strcat>:

char *
strcat(char *dst, const char *src) {
  800f4c:	55                   	push   %rbp
  800f4d:	48 89 e5             	mov    %rsp,%rbp
  800f50:	41 54                	push   %r12
  800f52:	53                   	push   %rbx
  800f53:	48 89 fb             	mov    %rdi,%rbx
  800f56:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800f59:	48 b8 dd 0e 80 00 00 	movabs $0x800edd,%rax
  800f60:	00 00 00 
  800f63:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800f65:	48 63 f8             	movslq %eax,%rdi
  800f68:	48 01 df             	add    %rbx,%rdi
  800f6b:	4c 89 e6             	mov    %r12,%rsi
  800f6e:	48 b8 34 0f 80 00 00 	movabs $0x800f34,%rax
  800f75:	00 00 00 
  800f78:	ff d0                	callq  *%rax
  return dst;
}
  800f7a:	48 89 d8             	mov    %rbx,%rax
  800f7d:	5b                   	pop    %rbx
  800f7e:	41 5c                	pop    %r12
  800f80:	5d                   	pop    %rbp
  800f81:	c3                   	retq   

0000000000800f82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f82:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800f85:	48 85 d2             	test   %rdx,%rdx
  800f88:	74 1f                	je     800fa9 <strncpy+0x27>
  800f8a:	48 01 fa             	add    %rdi,%rdx
  800f8d:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800f90:	48 83 c1 01          	add    $0x1,%rcx
  800f94:	44 0f b6 06          	movzbl (%rsi),%r8d
  800f98:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800f9c:	41 80 f8 01          	cmp    $0x1,%r8b
  800fa0:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800fa4:	48 39 ca             	cmp    %rcx,%rdx
  800fa7:	75 e7                	jne    800f90 <strncpy+0xe>
  }
  return ret;
}
  800fa9:	c3                   	retq   

0000000000800faa <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800faa:	48 89 f8             	mov    %rdi,%rax
  800fad:	48 85 d2             	test   %rdx,%rdx
  800fb0:	74 36                	je     800fe8 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800fb2:	48 83 fa 01          	cmp    $0x1,%rdx
  800fb6:	74 2d                	je     800fe5 <strlcpy+0x3b>
  800fb8:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fbc:	45 84 c0             	test   %r8b,%r8b
  800fbf:	74 24                	je     800fe5 <strlcpy+0x3b>
  800fc1:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800fc5:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800fca:	48 83 c0 01          	add    $0x1,%rax
  800fce:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800fd2:	48 39 d1             	cmp    %rdx,%rcx
  800fd5:	74 0e                	je     800fe5 <strlcpy+0x3b>
  800fd7:	48 83 c1 01          	add    $0x1,%rcx
  800fdb:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800fe0:	45 84 c0             	test   %r8b,%r8b
  800fe3:	75 e5                	jne    800fca <strlcpy+0x20>
    *dst = '\0';
  800fe5:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800fe8:	48 29 f8             	sub    %rdi,%rax
}
  800feb:	c3                   	retq   

0000000000800fec <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800fec:	0f b6 07             	movzbl (%rdi),%eax
  800fef:	84 c0                	test   %al,%al
  800ff1:	74 17                	je     80100a <strcmp+0x1e>
  800ff3:	3a 06                	cmp    (%rsi),%al
  800ff5:	75 13                	jne    80100a <strcmp+0x1e>
    p++, q++;
  800ff7:	48 83 c7 01          	add    $0x1,%rdi
  800ffb:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800fff:	0f b6 07             	movzbl (%rdi),%eax
  801002:	84 c0                	test   %al,%al
  801004:	74 04                	je     80100a <strcmp+0x1e>
  801006:	3a 06                	cmp    (%rsi),%al
  801008:	74 ed                	je     800ff7 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  80100a:	0f b6 c0             	movzbl %al,%eax
  80100d:	0f b6 16             	movzbl (%rsi),%edx
  801010:	29 d0                	sub    %edx,%eax
}
  801012:	c3                   	retq   

0000000000801013 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  801013:	48 85 d2             	test   %rdx,%rdx
  801016:	74 2f                	je     801047 <strncmp+0x34>
  801018:	0f b6 07             	movzbl (%rdi),%eax
  80101b:	84 c0                	test   %al,%al
  80101d:	74 1f                	je     80103e <strncmp+0x2b>
  80101f:	3a 06                	cmp    (%rsi),%al
  801021:	75 1b                	jne    80103e <strncmp+0x2b>
  801023:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  801026:	48 83 c7 01          	add    $0x1,%rdi
  80102a:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  80102e:	48 39 d7             	cmp    %rdx,%rdi
  801031:	74 1a                	je     80104d <strncmp+0x3a>
  801033:	0f b6 07             	movzbl (%rdi),%eax
  801036:	84 c0                	test   %al,%al
  801038:	74 04                	je     80103e <strncmp+0x2b>
  80103a:	3a 06                	cmp    (%rsi),%al
  80103c:	74 e8                	je     801026 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  80103e:	0f b6 07             	movzbl (%rdi),%eax
  801041:	0f b6 16             	movzbl (%rsi),%edx
  801044:	29 d0                	sub    %edx,%eax
}
  801046:	c3                   	retq   
    return 0;
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
  80104c:	c3                   	retq   
  80104d:	b8 00 00 00 00       	mov    $0x0,%eax
  801052:	c3                   	retq   

0000000000801053 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  801053:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  801055:	0f b6 07             	movzbl (%rdi),%eax
  801058:	84 c0                	test   %al,%al
  80105a:	74 1e                	je     80107a <strchr+0x27>
    if (*s == c)
  80105c:	40 38 c6             	cmp    %al,%sil
  80105f:	74 1f                	je     801080 <strchr+0x2d>
  for (; *s; s++)
  801061:	48 83 c7 01          	add    $0x1,%rdi
  801065:	0f b6 07             	movzbl (%rdi),%eax
  801068:	84 c0                	test   %al,%al
  80106a:	74 08                	je     801074 <strchr+0x21>
    if (*s == c)
  80106c:	38 d0                	cmp    %dl,%al
  80106e:	75 f1                	jne    801061 <strchr+0xe>
  for (; *s; s++)
  801070:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801073:	c3                   	retq   
  return 0;
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	c3                   	retq   
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
  80107f:	c3                   	retq   
    if (*s == c)
  801080:	48 89 f8             	mov    %rdi,%rax
  801083:	c3                   	retq   

0000000000801084 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801084:	48 89 f8             	mov    %rdi,%rax
  801087:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801089:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  80108c:	40 38 f2             	cmp    %sil,%dl
  80108f:	74 13                	je     8010a4 <strfind+0x20>
  801091:	84 d2                	test   %dl,%dl
  801093:	74 0f                	je     8010a4 <strfind+0x20>
  for (; *s; s++)
  801095:	48 83 c0 01          	add    $0x1,%rax
  801099:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  80109c:	38 ca                	cmp    %cl,%dl
  80109e:	74 04                	je     8010a4 <strfind+0x20>
  8010a0:	84 d2                	test   %dl,%dl
  8010a2:	75 f1                	jne    801095 <strfind+0x11>
      break;
  return (char *)s;
}
  8010a4:	c3                   	retq   

00000000008010a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  8010a5:	48 85 d2             	test   %rdx,%rdx
  8010a8:	74 3a                	je     8010e4 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8010aa:	48 89 f8             	mov    %rdi,%rax
  8010ad:	48 09 d0             	or     %rdx,%rax
  8010b0:	a8 03                	test   $0x3,%al
  8010b2:	75 28                	jne    8010dc <memset+0x37>
    uint32_t k = c & 0xFFU;
  8010b4:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  8010b8:	89 f0                	mov    %esi,%eax
  8010ba:	c1 e0 08             	shl    $0x8,%eax
  8010bd:	89 f1                	mov    %esi,%ecx
  8010bf:	c1 e1 18             	shl    $0x18,%ecx
  8010c2:	41 89 f0             	mov    %esi,%r8d
  8010c5:	41 c1 e0 10          	shl    $0x10,%r8d
  8010c9:	44 09 c1             	or     %r8d,%ecx
  8010cc:	09 ce                	or     %ecx,%esi
  8010ce:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  8010d0:	48 c1 ea 02          	shr    $0x2,%rdx
  8010d4:	48 89 d1             	mov    %rdx,%rcx
  8010d7:	fc                   	cld    
  8010d8:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8010da:	eb 08                	jmp    8010e4 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  8010dc:	89 f0                	mov    %esi,%eax
  8010de:	48 89 d1             	mov    %rdx,%rcx
  8010e1:	fc                   	cld    
  8010e2:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8010e4:	48 89 f8             	mov    %rdi,%rax
  8010e7:	c3                   	retq   

00000000008010e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8010e8:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8010eb:	48 39 fe             	cmp    %rdi,%rsi
  8010ee:	73 40                	jae    801130 <memmove+0x48>
  8010f0:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8010f4:	48 39 f9             	cmp    %rdi,%rcx
  8010f7:	76 37                	jbe    801130 <memmove+0x48>
    s += n;
    d += n;
  8010f9:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8010fd:	48 89 fe             	mov    %rdi,%rsi
  801100:	48 09 d6             	or     %rdx,%rsi
  801103:	48 09 ce             	or     %rcx,%rsi
  801106:	40 f6 c6 03          	test   $0x3,%sil
  80110a:	75 14                	jne    801120 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  80110c:	48 83 ef 04          	sub    $0x4,%rdi
  801110:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801114:	48 c1 ea 02          	shr    $0x2,%rdx
  801118:	48 89 d1             	mov    %rdx,%rcx
  80111b:	fd                   	std    
  80111c:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80111e:	eb 0e                	jmp    80112e <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  801120:	48 83 ef 01          	sub    $0x1,%rdi
  801124:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  801128:	48 89 d1             	mov    %rdx,%rcx
  80112b:	fd                   	std    
  80112c:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  80112e:	fc                   	cld    
  80112f:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801130:	48 89 c1             	mov    %rax,%rcx
  801133:	48 09 d1             	or     %rdx,%rcx
  801136:	48 09 f1             	or     %rsi,%rcx
  801139:	f6 c1 03             	test   $0x3,%cl
  80113c:	75 0e                	jne    80114c <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  80113e:	48 c1 ea 02          	shr    $0x2,%rdx
  801142:	48 89 d1             	mov    %rdx,%rcx
  801145:	48 89 c7             	mov    %rax,%rdi
  801148:	fc                   	cld    
  801149:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80114b:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80114c:	48 89 c7             	mov    %rax,%rdi
  80114f:	48 89 d1             	mov    %rdx,%rcx
  801152:	fc                   	cld    
  801153:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  801155:	c3                   	retq   

0000000000801156 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  801156:	55                   	push   %rbp
  801157:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  80115a:	48 b8 e8 10 80 00 00 	movabs $0x8010e8,%rax
  801161:	00 00 00 
  801164:	ff d0                	callq  *%rax
}
  801166:	5d                   	pop    %rbp
  801167:	c3                   	retq   

0000000000801168 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801168:	55                   	push   %rbp
  801169:	48 89 e5             	mov    %rsp,%rbp
  80116c:	41 57                	push   %r15
  80116e:	41 56                	push   %r14
  801170:	41 55                	push   %r13
  801172:	41 54                	push   %r12
  801174:	53                   	push   %rbx
  801175:	48 83 ec 08          	sub    $0x8,%rsp
  801179:	49 89 fe             	mov    %rdi,%r14
  80117c:	49 89 f7             	mov    %rsi,%r15
  80117f:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801182:	48 89 f7             	mov    %rsi,%rdi
  801185:	48 b8 dd 0e 80 00 00 	movabs $0x800edd,%rax
  80118c:	00 00 00 
  80118f:	ff d0                	callq  *%rax
  801191:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801194:	4c 89 ee             	mov    %r13,%rsi
  801197:	4c 89 f7             	mov    %r14,%rdi
  80119a:	48 b8 ff 0e 80 00 00 	movabs $0x800eff,%rax
  8011a1:	00 00 00 
  8011a4:	ff d0                	callq  *%rax
  8011a6:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  8011a9:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  8011ad:	4d 39 e5             	cmp    %r12,%r13
  8011b0:	74 26                	je     8011d8 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  8011b2:	4c 89 e8             	mov    %r13,%rax
  8011b5:	4c 29 e0             	sub    %r12,%rax
  8011b8:	48 39 d8             	cmp    %rbx,%rax
  8011bb:	76 2a                	jbe    8011e7 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  8011bd:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  8011c1:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8011c5:	4c 89 fe             	mov    %r15,%rsi
  8011c8:	48 b8 56 11 80 00 00 	movabs $0x801156,%rax
  8011cf:	00 00 00 
  8011d2:	ff d0                	callq  *%rax
  return dstlen + srclen;
  8011d4:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  8011d8:	48 83 c4 08          	add    $0x8,%rsp
  8011dc:	5b                   	pop    %rbx
  8011dd:	41 5c                	pop    %r12
  8011df:	41 5d                	pop    %r13
  8011e1:	41 5e                	pop    %r14
  8011e3:	41 5f                	pop    %r15
  8011e5:	5d                   	pop    %rbp
  8011e6:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8011e7:	49 83 ed 01          	sub    $0x1,%r13
  8011eb:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8011ef:	4c 89 ea             	mov    %r13,%rdx
  8011f2:	4c 89 fe             	mov    %r15,%rsi
  8011f5:	48 b8 56 11 80 00 00 	movabs $0x801156,%rax
  8011fc:	00 00 00 
  8011ff:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801201:	4d 01 ee             	add    %r13,%r14
  801204:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801209:	eb c9                	jmp    8011d4 <strlcat+0x6c>

000000000080120b <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80120b:	48 85 d2             	test   %rdx,%rdx
  80120e:	74 3a                	je     80124a <memcmp+0x3f>
    if (*s1 != *s2)
  801210:	0f b6 0f             	movzbl (%rdi),%ecx
  801213:	44 0f b6 06          	movzbl (%rsi),%r8d
  801217:	44 38 c1             	cmp    %r8b,%cl
  80121a:	75 1d                	jne    801239 <memcmp+0x2e>
  80121c:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801221:	48 39 d0             	cmp    %rdx,%rax
  801224:	74 1e                	je     801244 <memcmp+0x39>
    if (*s1 != *s2)
  801226:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80122a:	48 83 c0 01          	add    $0x1,%rax
  80122e:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801234:	44 38 c1             	cmp    %r8b,%cl
  801237:	74 e8                	je     801221 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801239:	0f b6 c1             	movzbl %cl,%eax
  80123c:	45 0f b6 c0          	movzbl %r8b,%r8d
  801240:	44 29 c0             	sub    %r8d,%eax
  801243:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
  801249:	c3                   	retq   
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124f:	c3                   	retq   

0000000000801250 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801250:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801254:	48 39 c7             	cmp    %rax,%rdi
  801257:	73 19                	jae    801272 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801259:	89 f2                	mov    %esi,%edx
  80125b:	40 38 37             	cmp    %sil,(%rdi)
  80125e:	74 16                	je     801276 <memfind+0x26>
  for (; s < ends; s++)
  801260:	48 83 c7 01          	add    $0x1,%rdi
  801264:	48 39 f8             	cmp    %rdi,%rax
  801267:	74 08                	je     801271 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801269:	38 17                	cmp    %dl,(%rdi)
  80126b:	75 f3                	jne    801260 <memfind+0x10>
  for (; s < ends; s++)
  80126d:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801270:	c3                   	retq   
  801271:	c3                   	retq   
  for (; s < ends; s++)
  801272:	48 89 f8             	mov    %rdi,%rax
  801275:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801276:	48 89 f8             	mov    %rdi,%rax
  801279:	c3                   	retq   

000000000080127a <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80127a:	0f b6 07             	movzbl (%rdi),%eax
  80127d:	3c 20                	cmp    $0x20,%al
  80127f:	74 04                	je     801285 <strtol+0xb>
  801281:	3c 09                	cmp    $0x9,%al
  801283:	75 0f                	jne    801294 <strtol+0x1a>
    s++;
  801285:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801289:	0f b6 07             	movzbl (%rdi),%eax
  80128c:	3c 20                	cmp    $0x20,%al
  80128e:	74 f5                	je     801285 <strtol+0xb>
  801290:	3c 09                	cmp    $0x9,%al
  801292:	74 f1                	je     801285 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801294:	3c 2b                	cmp    $0x2b,%al
  801296:	74 2b                	je     8012c3 <strtol+0x49>
  int neg  = 0;
  801298:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80129e:	3c 2d                	cmp    $0x2d,%al
  8012a0:	74 2d                	je     8012cf <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012a2:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8012a8:	75 0f                	jne    8012b9 <strtol+0x3f>
  8012aa:	80 3f 30             	cmpb   $0x30,(%rdi)
  8012ad:	74 2c                	je     8012db <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8012af:	85 d2                	test   %edx,%edx
  8012b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012b6:	0f 44 d0             	cmove  %eax,%edx
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8012be:	4c 63 d2             	movslq %edx,%r10
  8012c1:	eb 5c                	jmp    80131f <strtol+0xa5>
    s++;
  8012c3:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8012c7:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8012cd:	eb d3                	jmp    8012a2 <strtol+0x28>
    s++, neg = 1;
  8012cf:	48 83 c7 01          	add    $0x1,%rdi
  8012d3:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8012d9:	eb c7                	jmp    8012a2 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012db:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8012df:	74 0f                	je     8012f0 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	75 d4                	jne    8012b9 <strtol+0x3f>
    s++, base = 8;
  8012e5:	48 83 c7 01          	add    $0x1,%rdi
  8012e9:	ba 08 00 00 00       	mov    $0x8,%edx
  8012ee:	eb c9                	jmp    8012b9 <strtol+0x3f>
    s += 2, base = 16;
  8012f0:	48 83 c7 02          	add    $0x2,%rdi
  8012f4:	ba 10 00 00 00       	mov    $0x10,%edx
  8012f9:	eb be                	jmp    8012b9 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8012fb:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8012ff:	41 80 f8 19          	cmp    $0x19,%r8b
  801303:	77 2f                	ja     801334 <strtol+0xba>
      dig = *s - 'a' + 10;
  801305:	44 0f be c1          	movsbl %cl,%r8d
  801309:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80130d:	39 d1                	cmp    %edx,%ecx
  80130f:	7d 37                	jge    801348 <strtol+0xce>
    s++, val = (val * base) + dig;
  801311:	48 83 c7 01          	add    $0x1,%rdi
  801315:	49 0f af c2          	imul   %r10,%rax
  801319:	48 63 c9             	movslq %ecx,%rcx
  80131c:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80131f:	0f b6 0f             	movzbl (%rdi),%ecx
  801322:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801326:	41 80 f8 09          	cmp    $0x9,%r8b
  80132a:	77 cf                	ja     8012fb <strtol+0x81>
      dig = *s - '0';
  80132c:	0f be c9             	movsbl %cl,%ecx
  80132f:	83 e9 30             	sub    $0x30,%ecx
  801332:	eb d9                	jmp    80130d <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801334:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801338:	41 80 f8 19          	cmp    $0x19,%r8b
  80133c:	77 0a                	ja     801348 <strtol+0xce>
      dig = *s - 'A' + 10;
  80133e:	44 0f be c1          	movsbl %cl,%r8d
  801342:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801346:	eb c5                	jmp    80130d <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801348:	48 85 f6             	test   %rsi,%rsi
  80134b:	74 03                	je     801350 <strtol+0xd6>
    *endptr = (char *)s;
  80134d:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801350:	48 89 c2             	mov    %rax,%rdx
  801353:	48 f7 da             	neg    %rdx
  801356:	45 85 c9             	test   %r9d,%r9d
  801359:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80135d:	c3                   	retq   

000000000080135e <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80135e:	55                   	push   %rbp
  80135f:	48 89 e5             	mov    %rsp,%rbp
  801362:	53                   	push   %rbx
  801363:	48 89 fa             	mov    %rdi,%rdx
  801366:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
  80136e:	48 89 c3             	mov    %rax,%rbx
  801371:	48 89 c7             	mov    %rax,%rdi
  801374:	48 89 c6             	mov    %rax,%rsi
  801377:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801379:	5b                   	pop    %rbx
  80137a:	5d                   	pop    %rbp
  80137b:	c3                   	retq   

000000000080137c <sys_cgetc>:

int
sys_cgetc(void) {
  80137c:	55                   	push   %rbp
  80137d:	48 89 e5             	mov    %rsp,%rbp
  801380:	53                   	push   %rbx
  asm volatile("int %1\n"
  801381:	b9 00 00 00 00       	mov    $0x0,%ecx
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	48 89 ca             	mov    %rcx,%rdx
  80138e:	48 89 cb             	mov    %rcx,%rbx
  801391:	48 89 cf             	mov    %rcx,%rdi
  801394:	48 89 ce             	mov    %rcx,%rsi
  801397:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801399:	5b                   	pop    %rbx
  80139a:	5d                   	pop    %rbp
  80139b:	c3                   	retq   

000000000080139c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80139c:	55                   	push   %rbp
  80139d:	48 89 e5             	mov    %rsp,%rbp
  8013a0:	53                   	push   %rbx
  8013a1:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8013a5:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8013a8:	be 00 00 00 00       	mov    $0x0,%esi
  8013ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8013b2:	48 89 f1             	mov    %rsi,%rcx
  8013b5:	48 89 f3             	mov    %rsi,%rbx
  8013b8:	48 89 f7             	mov    %rsi,%rdi
  8013bb:	cd 30                	int    $0x30
  if (check && ret > 0)
  8013bd:	48 85 c0             	test   %rax,%rax
  8013c0:	7f 07                	jg     8013c9 <sys_env_destroy+0x2d>
}
  8013c2:	48 83 c4 08          	add    $0x8,%rsp
  8013c6:	5b                   	pop    %rbx
  8013c7:	5d                   	pop    %rbp
  8013c8:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8013c9:	49 89 c0             	mov    %rax,%r8
  8013cc:	b9 03 00 00 00       	mov    $0x3,%ecx
  8013d1:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  8013d8:	00 00 00 
  8013db:	be 22 00 00 00       	mov    $0x22,%esi
  8013e0:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  8013e7:	00 00 00 
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ef:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  8013f6:	00 00 00 
  8013f9:	41 ff d1             	callq  *%r9

00000000008013fc <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8013fc:	55                   	push   %rbp
  8013fd:	48 89 e5             	mov    %rsp,%rbp
  801400:	53                   	push   %rbx
  asm volatile("int %1\n"
  801401:	b9 00 00 00 00       	mov    $0x0,%ecx
  801406:	b8 02 00 00 00       	mov    $0x2,%eax
  80140b:	48 89 ca             	mov    %rcx,%rdx
  80140e:	48 89 cb             	mov    %rcx,%rbx
  801411:	48 89 cf             	mov    %rcx,%rdi
  801414:	48 89 ce             	mov    %rcx,%rsi
  801417:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801419:	5b                   	pop    %rbx
  80141a:	5d                   	pop    %rbp
  80141b:	c3                   	retq   

000000000080141c <sys_yield>:

void
sys_yield(void) {
  80141c:	55                   	push   %rbp
  80141d:	48 89 e5             	mov    %rsp,%rbp
  801420:	53                   	push   %rbx
  asm volatile("int %1\n"
  801421:	b9 00 00 00 00       	mov    $0x0,%ecx
  801426:	b8 0a 00 00 00       	mov    $0xa,%eax
  80142b:	48 89 ca             	mov    %rcx,%rdx
  80142e:	48 89 cb             	mov    %rcx,%rbx
  801431:	48 89 cf             	mov    %rcx,%rdi
  801434:	48 89 ce             	mov    %rcx,%rsi
  801437:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801439:	5b                   	pop    %rbx
  80143a:	5d                   	pop    %rbp
  80143b:	c3                   	retq   

000000000080143c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  80143c:	55                   	push   %rbp
  80143d:	48 89 e5             	mov    %rsp,%rbp
  801440:	53                   	push   %rbx
  801441:	48 83 ec 08          	sub    $0x8,%rsp
  801445:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801448:	4c 63 c7             	movslq %edi,%r8
  80144b:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  80144e:	be 00 00 00 00       	mov    $0x0,%esi
  801453:	b8 04 00 00 00       	mov    $0x4,%eax
  801458:	4c 89 c2             	mov    %r8,%rdx
  80145b:	48 89 f7             	mov    %rsi,%rdi
  80145e:	cd 30                	int    $0x30
  if (check && ret > 0)
  801460:	48 85 c0             	test   %rax,%rax
  801463:	7f 07                	jg     80146c <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  801465:	48 83 c4 08          	add    $0x8,%rsp
  801469:	5b                   	pop    %rbx
  80146a:	5d                   	pop    %rbp
  80146b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80146c:	49 89 c0             	mov    %rax,%r8
  80146f:	b9 04 00 00 00       	mov    $0x4,%ecx
  801474:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  80147b:	00 00 00 
  80147e:	be 22 00 00 00       	mov    $0x22,%esi
  801483:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  80148a:	00 00 00 
  80148d:	b8 00 00 00 00       	mov    $0x0,%eax
  801492:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  801499:	00 00 00 
  80149c:	41 ff d1             	callq  *%r9

000000000080149f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80149f:	55                   	push   %rbp
  8014a0:	48 89 e5             	mov    %rsp,%rbp
  8014a3:	53                   	push   %rbx
  8014a4:	48 83 ec 08          	sub    $0x8,%rsp
  8014a8:	41 89 f9             	mov    %edi,%r9d
  8014ab:	49 89 f2             	mov    %rsi,%r10
  8014ae:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  8014b1:	4d 63 c9             	movslq %r9d,%r9
  8014b4:	48 63 da             	movslq %edx,%rbx
  8014b7:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  8014ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8014bf:	4c 89 ca             	mov    %r9,%rdx
  8014c2:	4c 89 d1             	mov    %r10,%rcx
  8014c5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8014c7:	48 85 c0             	test   %rax,%rax
  8014ca:	7f 07                	jg     8014d3 <sys_page_map+0x34>
}
  8014cc:	48 83 c4 08          	add    $0x8,%rsp
  8014d0:	5b                   	pop    %rbx
  8014d1:	5d                   	pop    %rbp
  8014d2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8014d3:	49 89 c0             	mov    %rax,%r8
  8014d6:	b9 05 00 00 00       	mov    $0x5,%ecx
  8014db:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  8014e2:	00 00 00 
  8014e5:	be 22 00 00 00       	mov    $0x22,%esi
  8014ea:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  8014f1:	00 00 00 
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f9:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  801500:	00 00 00 
  801503:	41 ff d1             	callq  *%r9

0000000000801506 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801506:	55                   	push   %rbp
  801507:	48 89 e5             	mov    %rsp,%rbp
  80150a:	53                   	push   %rbx
  80150b:	48 83 ec 08          	sub    $0x8,%rsp
  80150f:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801512:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801515:	be 00 00 00 00       	mov    $0x0,%esi
  80151a:	b8 06 00 00 00       	mov    $0x6,%eax
  80151f:	48 89 f3             	mov    %rsi,%rbx
  801522:	48 89 f7             	mov    %rsi,%rdi
  801525:	cd 30                	int    $0x30
  if (check && ret > 0)
  801527:	48 85 c0             	test   %rax,%rax
  80152a:	7f 07                	jg     801533 <sys_page_unmap+0x2d>
}
  80152c:	48 83 c4 08          	add    $0x8,%rsp
  801530:	5b                   	pop    %rbx
  801531:	5d                   	pop    %rbp
  801532:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801533:	49 89 c0             	mov    %rax,%r8
  801536:	b9 06 00 00 00       	mov    $0x6,%ecx
  80153b:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  801542:	00 00 00 
  801545:	be 22 00 00 00       	mov    $0x22,%esi
  80154a:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  801551:	00 00 00 
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
  801559:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  801560:	00 00 00 
  801563:	41 ff d1             	callq  *%r9

0000000000801566 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  801566:	55                   	push   %rbp
  801567:	48 89 e5             	mov    %rsp,%rbp
  80156a:	53                   	push   %rbx
  80156b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80156f:	48 63 d7             	movslq %edi,%rdx
  801572:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801575:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157a:	b8 08 00 00 00       	mov    $0x8,%eax
  80157f:	48 89 df             	mov    %rbx,%rdi
  801582:	48 89 de             	mov    %rbx,%rsi
  801585:	cd 30                	int    $0x30
  if (check && ret > 0)
  801587:	48 85 c0             	test   %rax,%rax
  80158a:	7f 07                	jg     801593 <sys_env_set_status+0x2d>
}
  80158c:	48 83 c4 08          	add    $0x8,%rsp
  801590:	5b                   	pop    %rbx
  801591:	5d                   	pop    %rbp
  801592:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801593:	49 89 c0             	mov    %rax,%r8
  801596:	b9 08 00 00 00       	mov    $0x8,%ecx
  80159b:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  8015a2:	00 00 00 
  8015a5:	be 22 00 00 00       	mov    $0x22,%esi
  8015aa:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  8015b1:	00 00 00 
  8015b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b9:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  8015c0:	00 00 00 
  8015c3:	41 ff d1             	callq  *%r9

00000000008015c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8015c6:	55                   	push   %rbp
  8015c7:	48 89 e5             	mov    %rsp,%rbp
  8015ca:	53                   	push   %rbx
  8015cb:	48 83 ec 08          	sub    $0x8,%rsp
  8015cf:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  8015d2:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8015d5:	be 00 00 00 00       	mov    $0x0,%esi
  8015da:	b8 09 00 00 00       	mov    $0x9,%eax
  8015df:	48 89 f3             	mov    %rsi,%rbx
  8015e2:	48 89 f7             	mov    %rsi,%rdi
  8015e5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8015e7:	48 85 c0             	test   %rax,%rax
  8015ea:	7f 07                	jg     8015f3 <sys_env_set_pgfault_upcall+0x2d>
}
  8015ec:	48 83 c4 08          	add    $0x8,%rsp
  8015f0:	5b                   	pop    %rbx
  8015f1:	5d                   	pop    %rbp
  8015f2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8015f3:	49 89 c0             	mov    %rax,%r8
  8015f6:	b9 09 00 00 00       	mov    $0x9,%ecx
  8015fb:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  801602:	00 00 00 
  801605:	be 22 00 00 00       	mov    $0x22,%esi
  80160a:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  801611:	00 00 00 
  801614:	b8 00 00 00 00       	mov    $0x0,%eax
  801619:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  801620:	00 00 00 
  801623:	41 ff d1             	callq  *%r9

0000000000801626 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801626:	55                   	push   %rbp
  801627:	48 89 e5             	mov    %rsp,%rbp
  80162a:	53                   	push   %rbx
  80162b:	49 89 f0             	mov    %rsi,%r8
  80162e:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801631:	48 63 d7             	movslq %edi,%rdx
  801634:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801637:	b8 0b 00 00 00       	mov    $0xb,%eax
  80163c:	be 00 00 00 00       	mov    $0x0,%esi
  801641:	4c 89 c1             	mov    %r8,%rcx
  801644:	cd 30                	int    $0x30
}
  801646:	5b                   	pop    %rbx
  801647:	5d                   	pop    %rbp
  801648:	c3                   	retq   

0000000000801649 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801649:	55                   	push   %rbp
  80164a:	48 89 e5             	mov    %rsp,%rbp
  80164d:	53                   	push   %rbx
  80164e:	48 83 ec 08          	sub    $0x8,%rsp
  801652:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801655:	be 00 00 00 00       	mov    $0x0,%esi
  80165a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80165f:	48 89 f1             	mov    %rsi,%rcx
  801662:	48 89 f3             	mov    %rsi,%rbx
  801665:	48 89 f7             	mov    %rsi,%rdi
  801668:	cd 30                	int    $0x30
  if (check && ret > 0)
  80166a:	48 85 c0             	test   %rax,%rax
  80166d:	7f 07                	jg     801676 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80166f:	48 83 c4 08          	add    $0x8,%rsp
  801673:	5b                   	pop    %rbx
  801674:	5d                   	pop    %rbp
  801675:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801676:	49 89 c0             	mov    %rax,%r8
  801679:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80167e:	48 ba 80 1b 80 00 00 	movabs $0x801b80,%rdx
  801685:	00 00 00 
  801688:	be 22 00 00 00       	mov    $0x22,%esi
  80168d:	48 bf a0 1b 80 00 00 	movabs $0x801ba0,%rdi
  801694:	00 00 00 
  801697:	b8 00 00 00 00       	mov    $0x0,%eax
  80169c:	49 b9 c8 03 80 00 00 	movabs $0x8003c8,%r9
  8016a3:	00 00 00 
  8016a6:	41 ff d1             	callq  *%r9
  8016a9:	0f 1f 00             	nopl   (%rax)
