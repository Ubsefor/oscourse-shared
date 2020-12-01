
obj/user/faultbadhandler:     file format elf64-x86-64


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
  800023:	e8 49 00 00 00       	callq  800071 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
// we outrun the stack with invocations of the user-level handler

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80002e:	ba 07 00 00 00       	mov    $0x7,%edx
  800033:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  80003a:	00 00 00 
  80003d:	bf 00 00 00 00       	mov    $0x0,%edi
  800042:	48 b8 1c 02 80 00 00 	movabs $0x80021c,%rax
  800049:	00 00 00 
  80004c:	ff d0                	callq  *%rax
  sys_env_set_pgfault_upcall(0, (void *)0xDeadBeef);
  80004e:	be ef be ad de       	mov    $0xdeadbeef,%esi
  800053:	bf 00 00 00 00       	mov    $0x0,%edi
  800058:	48 b8 a6 03 80 00 00 	movabs $0x8003a6,%rax
  80005f:	00 00 00 
  800062:	ff d0                	callq  *%rax
  *(volatile int *)0 = 0;
  800064:	c7 04 25 00 00 00 00 	movl   $0x0,0x0
  80006b:	00 00 00 00 
}
  80006f:	5d                   	pop    %rbp
  800070:	c3                   	retq   

0000000000800071 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800071:	55                   	push   %rbp
  800072:	48 89 e5             	mov    %rsp,%rbp
  800075:	41 56                	push   %r14
  800077:	41 55                	push   %r13
  800079:	41 54                	push   %r12
  80007b:	53                   	push   %rbx
  80007c:	41 89 fd             	mov    %edi,%r13d
  80007f:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800082:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800089:	00 00 00 
  80008c:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800093:	00 00 00 
  800096:	48 39 c2             	cmp    %rax,%rdx
  800099:	73 23                	jae    8000be <libmain+0x4d>
  80009b:	48 89 d3             	mov    %rdx,%rbx
  80009e:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  8000a2:	48 29 d0             	sub    %rdx,%rax
  8000a5:	48 c1 e8 03          	shr    $0x3,%rax
  8000a9:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	ff 13                	callq  *(%rbx)
    ctor++;
  8000b5:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8000b9:	4c 39 e3             	cmp    %r12,%rbx
  8000bc:	75 f0                	jne    8000ae <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000be:	48 b8 dc 01 80 00 00 	movabs $0x8001dc,%rax
  8000c5:	00 00 00 
  8000c8:	ff d0                	callq  *%rax
  8000ca:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cf:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000d3:	48 c1 e0 05          	shl    $0x5,%rax
  8000d7:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000de:	00 00 00 
  8000e1:	48 01 d0             	add    %rdx,%rax
  8000e4:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000eb:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000ee:	45 85 ed             	test   %r13d,%r13d
  8000f1:	7e 0d                	jle    800100 <libmain+0x8f>
    binaryname = argv[0];
  8000f3:	49 8b 06             	mov    (%r14),%rax
  8000f6:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000fd:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800100:	4c 89 f6             	mov    %r14,%rsi
  800103:	44 89 ef             	mov    %r13d,%edi
  800106:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  80010d:	00 00 00 
  800110:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800112:	48 b8 27 01 80 00 00 	movabs $0x800127,%rax
  800119:	00 00 00 
  80011c:	ff d0                	callq  *%rax
#endif
}
  80011e:	5b                   	pop    %rbx
  80011f:	41 5c                	pop    %r12
  800121:	41 5d                	pop    %r13
  800123:	41 5e                	pop    %r14
  800125:	5d                   	pop    %rbp
  800126:	c3                   	retq   

0000000000800127 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800127:	55                   	push   %rbp
  800128:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80012b:	bf 00 00 00 00       	mov    $0x0,%edi
  800130:	48 b8 7c 01 80 00 00 	movabs $0x80017c,%rax
  800137:	00 00 00 
  80013a:	ff d0                	callq  *%rax
}
  80013c:	5d                   	pop    %rbp
  80013d:	c3                   	retq   

000000000080013e <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80013e:	55                   	push   %rbp
  80013f:	48 89 e5             	mov    %rsp,%rbp
  800142:	53                   	push   %rbx
  800143:	48 89 fa             	mov    %rdi,%rdx
  800146:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800149:	b8 00 00 00 00       	mov    $0x0,%eax
  80014e:	48 89 c3             	mov    %rax,%rbx
  800151:	48 89 c7             	mov    %rax,%rdi
  800154:	48 89 c6             	mov    %rax,%rsi
  800157:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800159:	5b                   	pop    %rbx
  80015a:	5d                   	pop    %rbp
  80015b:	c3                   	retq   

000000000080015c <sys_cgetc>:

int
sys_cgetc(void) {
  80015c:	55                   	push   %rbp
  80015d:	48 89 e5             	mov    %rsp,%rbp
  800160:	53                   	push   %rbx
  asm volatile("int %1\n"
  800161:	b9 00 00 00 00       	mov    $0x0,%ecx
  800166:	b8 01 00 00 00       	mov    $0x1,%eax
  80016b:	48 89 ca             	mov    %rcx,%rdx
  80016e:	48 89 cb             	mov    %rcx,%rbx
  800171:	48 89 cf             	mov    %rcx,%rdi
  800174:	48 89 ce             	mov    %rcx,%rsi
  800177:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %rbx
  80017a:	5d                   	pop    %rbp
  80017b:	c3                   	retq   

000000000080017c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  80017c:	55                   	push   %rbp
  80017d:	48 89 e5             	mov    %rsp,%rbp
  800180:	53                   	push   %rbx
  800181:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800185:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800188:	be 00 00 00 00       	mov    $0x0,%esi
  80018d:	b8 03 00 00 00       	mov    $0x3,%eax
  800192:	48 89 f1             	mov    %rsi,%rcx
  800195:	48 89 f3             	mov    %rsi,%rbx
  800198:	48 89 f7             	mov    %rsi,%rdi
  80019b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80019d:	48 85 c0             	test   %rax,%rax
  8001a0:	7f 07                	jg     8001a9 <sys_env_destroy+0x2d>
}
  8001a2:	48 83 c4 08          	add    $0x8,%rsp
  8001a6:	5b                   	pop    %rbx
  8001a7:	5d                   	pop    %rbp
  8001a8:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8001a9:	49 89 c0             	mov    %rax,%r8
  8001ac:	b9 03 00 00 00       	mov    $0x3,%ecx
  8001b1:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  8001b8:	00 00 00 
  8001bb:	be 22 00 00 00       	mov    $0x22,%esi
  8001c0:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  8001c7:	00 00 00 
  8001ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cf:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  8001d6:	00 00 00 
  8001d9:	41 ff d1             	callq  *%r9

00000000008001dc <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001dc:	55                   	push   %rbp
  8001dd:	48 89 e5             	mov    %rsp,%rbp
  8001e0:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e6:	b8 02 00 00 00       	mov    $0x2,%eax
  8001eb:	48 89 ca             	mov    %rcx,%rdx
  8001ee:	48 89 cb             	mov    %rcx,%rbx
  8001f1:	48 89 cf             	mov    %rcx,%rdi
  8001f4:	48 89 ce             	mov    %rcx,%rsi
  8001f7:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001f9:	5b                   	pop    %rbx
  8001fa:	5d                   	pop    %rbp
  8001fb:	c3                   	retq   

00000000008001fc <sys_yield>:

void
sys_yield(void) {
  8001fc:	55                   	push   %rbp
  8001fd:	48 89 e5             	mov    %rsp,%rbp
  800200:	53                   	push   %rbx
  asm volatile("int %1\n"
  800201:	b9 00 00 00 00       	mov    $0x0,%ecx
  800206:	b8 0a 00 00 00       	mov    $0xa,%eax
  80020b:	48 89 ca             	mov    %rcx,%rdx
  80020e:	48 89 cb             	mov    %rcx,%rbx
  800211:	48 89 cf             	mov    %rcx,%rdi
  800214:	48 89 ce             	mov    %rcx,%rsi
  800217:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800219:	5b                   	pop    %rbx
  80021a:	5d                   	pop    %rbp
  80021b:	c3                   	retq   

000000000080021c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  80021c:	55                   	push   %rbp
  80021d:	48 89 e5             	mov    %rsp,%rbp
  800220:	53                   	push   %rbx
  800221:	48 83 ec 08          	sub    $0x8,%rsp
  800225:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  800228:	4c 63 c7             	movslq %edi,%r8
  80022b:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  80022e:	be 00 00 00 00       	mov    $0x0,%esi
  800233:	b8 04 00 00 00       	mov    $0x4,%eax
  800238:	4c 89 c2             	mov    %r8,%rdx
  80023b:	48 89 f7             	mov    %rsi,%rdi
  80023e:	cd 30                	int    $0x30
  if (check && ret > 0)
  800240:	48 85 c0             	test   %rax,%rax
  800243:	7f 07                	jg     80024c <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  800245:	48 83 c4 08          	add    $0x8,%rsp
  800249:	5b                   	pop    %rbx
  80024a:	5d                   	pop    %rbp
  80024b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80024c:	49 89 c0             	mov    %rax,%r8
  80024f:	b9 04 00 00 00       	mov    $0x4,%ecx
  800254:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  80025b:	00 00 00 
  80025e:	be 22 00 00 00       	mov    $0x22,%esi
  800263:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  80026a:	00 00 00 
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
  800272:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  800279:	00 00 00 
  80027c:	41 ff d1             	callq  *%r9

000000000080027f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80027f:	55                   	push   %rbp
  800280:	48 89 e5             	mov    %rsp,%rbp
  800283:	53                   	push   %rbx
  800284:	48 83 ec 08          	sub    $0x8,%rsp
  800288:	41 89 f9             	mov    %edi,%r9d
  80028b:	49 89 f2             	mov    %rsi,%r10
  80028e:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  800291:	4d 63 c9             	movslq %r9d,%r9
  800294:	48 63 da             	movslq %edx,%rbx
  800297:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80029a:	b8 05 00 00 00       	mov    $0x5,%eax
  80029f:	4c 89 ca             	mov    %r9,%rdx
  8002a2:	4c 89 d1             	mov    %r10,%rcx
  8002a5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002a7:	48 85 c0             	test   %rax,%rax
  8002aa:	7f 07                	jg     8002b3 <sys_page_map+0x34>
}
  8002ac:	48 83 c4 08          	add    $0x8,%rsp
  8002b0:	5b                   	pop    %rbx
  8002b1:	5d                   	pop    %rbp
  8002b2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002b3:	49 89 c0             	mov    %rax,%r8
  8002b6:	b9 05 00 00 00       	mov    $0x5,%ecx
  8002bb:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  8002c2:	00 00 00 
  8002c5:	be 22 00 00 00       	mov    $0x22,%esi
  8002ca:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  8002d1:	00 00 00 
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  8002e0:	00 00 00 
  8002e3:	41 ff d1             	callq  *%r9

00000000008002e6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002e6:	55                   	push   %rbp
  8002e7:	48 89 e5             	mov    %rsp,%rbp
  8002ea:	53                   	push   %rbx
  8002eb:	48 83 ec 08          	sub    $0x8,%rsp
  8002ef:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002f2:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002f5:	be 00 00 00 00       	mov    $0x0,%esi
  8002fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8002ff:	48 89 f3             	mov    %rsi,%rbx
  800302:	48 89 f7             	mov    %rsi,%rdi
  800305:	cd 30                	int    $0x30
  if (check && ret > 0)
  800307:	48 85 c0             	test   %rax,%rax
  80030a:	7f 07                	jg     800313 <sys_page_unmap+0x2d>
}
  80030c:	48 83 c4 08          	add    $0x8,%rsp
  800310:	5b                   	pop    %rbx
  800311:	5d                   	pop    %rbp
  800312:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800313:	49 89 c0             	mov    %rax,%r8
  800316:	b9 06 00 00 00       	mov    $0x6,%ecx
  80031b:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  800322:	00 00 00 
  800325:	be 22 00 00 00       	mov    $0x22,%esi
  80032a:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  800331:	00 00 00 
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  800340:	00 00 00 
  800343:	41 ff d1             	callq  *%r9

0000000000800346 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800346:	55                   	push   %rbp
  800347:	48 89 e5             	mov    %rsp,%rbp
  80034a:	53                   	push   %rbx
  80034b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80034f:	48 63 d7             	movslq %edi,%rdx
  800352:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  800355:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035a:	b8 08 00 00 00       	mov    $0x8,%eax
  80035f:	48 89 df             	mov    %rbx,%rdi
  800362:	48 89 de             	mov    %rbx,%rsi
  800365:	cd 30                	int    $0x30
  if (check && ret > 0)
  800367:	48 85 c0             	test   %rax,%rax
  80036a:	7f 07                	jg     800373 <sys_env_set_status+0x2d>
}
  80036c:	48 83 c4 08          	add    $0x8,%rsp
  800370:	5b                   	pop    %rbx
  800371:	5d                   	pop    %rbp
  800372:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800373:	49 89 c0             	mov    %rax,%r8
  800376:	b9 08 00 00 00       	mov    $0x8,%ecx
  80037b:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  800382:	00 00 00 
  800385:	be 22 00 00 00       	mov    $0x22,%esi
  80038a:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  800391:	00 00 00 
  800394:	b8 00 00 00 00       	mov    $0x0,%eax
  800399:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  8003a0:	00 00 00 
  8003a3:	41 ff d1             	callq  *%r9

00000000008003a6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  8003a6:	55                   	push   %rbp
  8003a7:	48 89 e5             	mov    %rsp,%rbp
  8003aa:	53                   	push   %rbx
  8003ab:	48 83 ec 08          	sub    $0x8,%rsp
  8003af:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  8003b2:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8003b5:	be 00 00 00 00       	mov    $0x0,%esi
  8003ba:	b8 09 00 00 00       	mov    $0x9,%eax
  8003bf:	48 89 f3             	mov    %rsi,%rbx
  8003c2:	48 89 f7             	mov    %rsi,%rdi
  8003c5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8003c7:	48 85 c0             	test   %rax,%rax
  8003ca:	7f 07                	jg     8003d3 <sys_env_set_pgfault_upcall+0x2d>
}
  8003cc:	48 83 c4 08          	add    $0x8,%rsp
  8003d0:	5b                   	pop    %rbx
  8003d1:	5d                   	pop    %rbp
  8003d2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8003d3:	49 89 c0             	mov    %rax,%r8
  8003d6:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003db:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  8003e2:	00 00 00 
  8003e5:	be 22 00 00 00       	mov    $0x22,%esi
  8003ea:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  8003f1:	00 00 00 
  8003f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f9:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  800400:	00 00 00 
  800403:	41 ff d1             	callq  *%r9

0000000000800406 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  800406:	55                   	push   %rbp
  800407:	48 89 e5             	mov    %rsp,%rbp
  80040a:	53                   	push   %rbx
  80040b:	49 89 f0             	mov    %rsi,%r8
  80040e:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  800411:	48 63 d7             	movslq %edi,%rdx
  800414:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  800417:	b8 0b 00 00 00       	mov    $0xb,%eax
  80041c:	be 00 00 00 00       	mov    $0x0,%esi
  800421:	4c 89 c1             	mov    %r8,%rcx
  800424:	cd 30                	int    $0x30
}
  800426:	5b                   	pop    %rbx
  800427:	5d                   	pop    %rbp
  800428:	c3                   	retq   

0000000000800429 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  800429:	55                   	push   %rbp
  80042a:	48 89 e5             	mov    %rsp,%rbp
  80042d:	53                   	push   %rbx
  80042e:	48 83 ec 08          	sub    $0x8,%rsp
  800432:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  800435:	be 00 00 00 00       	mov    $0x0,%esi
  80043a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80043f:	48 89 f1             	mov    %rsi,%rcx
  800442:	48 89 f3             	mov    %rsi,%rbx
  800445:	48 89 f7             	mov    %rsi,%rdi
  800448:	cd 30                	int    $0x30
  if (check && ret > 0)
  80044a:	48 85 c0             	test   %rax,%rax
  80044d:	7f 07                	jg     800456 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80044f:	48 83 c4 08          	add    $0x8,%rsp
  800453:	5b                   	pop    %rbx
  800454:	5d                   	pop    %rbp
  800455:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800456:	49 89 c0             	mov    %rax,%r8
  800459:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80045e:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  800465:	00 00 00 
  800468:	be 22 00 00 00       	mov    $0x22,%esi
  80046d:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  800474:	00 00 00 
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	49 b9 89 04 80 00 00 	movabs $0x800489,%r9
  800483:	00 00 00 
  800486:	41 ff d1             	callq  *%r9

0000000000800489 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800489:	55                   	push   %rbp
  80048a:	48 89 e5             	mov    %rsp,%rbp
  80048d:	41 56                	push   %r14
  80048f:	41 55                	push   %r13
  800491:	41 54                	push   %r12
  800493:	53                   	push   %rbx
  800494:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80049b:	49 89 fd             	mov    %rdi,%r13
  80049e:	41 89 f6             	mov    %esi,%r14d
  8004a1:	49 89 d4             	mov    %rdx,%r12
  8004a4:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8004ab:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8004b2:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8004b9:	84 c0                	test   %al,%al
  8004bb:	74 26                	je     8004e3 <_panic+0x5a>
  8004bd:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8004c4:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8004cb:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8004cf:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8004d3:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8004d7:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004db:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004df:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004e3:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004ea:	00 00 00 
  8004ed:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004f4:	00 00 00 
  8004f7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004fb:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800502:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800509:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800510:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800517:	00 00 00 
  80051a:	48 8b 18             	mov    (%rax),%rbx
  80051d:	48 b8 dc 01 80 00 00 	movabs $0x8001dc,%rax
  800524:	00 00 00 
  800527:	ff d0                	callq  *%rax
  800529:	45 89 f0             	mov    %r14d,%r8d
  80052c:	4c 89 e9             	mov    %r13,%rcx
  80052f:	48 89 da             	mov    %rbx,%rdx
  800532:	89 c6                	mov    %eax,%esi
  800534:	48 bf 60 14 80 00 00 	movabs $0x801460,%rdi
  80053b:	00 00 00 
  80053e:	b8 00 00 00 00       	mov    $0x0,%eax
  800543:	48 bb 2b 06 80 00 00 	movabs $0x80062b,%rbx
  80054a:	00 00 00 
  80054d:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80054f:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800556:	4c 89 e7             	mov    %r12,%rdi
  800559:	48 b8 c3 05 80 00 00 	movabs $0x8005c3,%rax
  800560:	00 00 00 
  800563:	ff d0                	callq  *%rax
  cprintf("\n");
  800565:	48 bf 88 14 80 00 00 	movabs $0x801488,%rdi
  80056c:	00 00 00 
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800576:	cc                   	int3   
  while (1)
  800577:	eb fd                	jmp    800576 <_panic+0xed>

0000000000800579 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800579:	55                   	push   %rbp
  80057a:	48 89 e5             	mov    %rsp,%rbp
  80057d:	53                   	push   %rbx
  80057e:	48 83 ec 08          	sub    $0x8,%rsp
  800582:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800585:	8b 06                	mov    (%rsi),%eax
  800587:	8d 50 01             	lea    0x1(%rax),%edx
  80058a:	89 16                	mov    %edx,(%rsi)
  80058c:	48 98                	cltq   
  80058e:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800593:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800599:	74 0b                	je     8005a6 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80059b:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80059f:	48 83 c4 08          	add    $0x8,%rsp
  8005a3:	5b                   	pop    %rbx
  8005a4:	5d                   	pop    %rbp
  8005a5:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8005a6:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8005aa:	be ff 00 00 00       	mov    $0xff,%esi
  8005af:	48 b8 3e 01 80 00 00 	movabs $0x80013e,%rax
  8005b6:	00 00 00 
  8005b9:	ff d0                	callq  *%rax
    b->idx = 0;
  8005bb:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8005c1:	eb d8                	jmp    80059b <putch+0x22>

00000000008005c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8005c3:	55                   	push   %rbp
  8005c4:	48 89 e5             	mov    %rsp,%rbp
  8005c7:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8005ce:	48 89 fa             	mov    %rdi,%rdx
  8005d1:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8005d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005db:	00 00 00 
  b.cnt = 0;
  8005de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005e5:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005e8:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005ef:	48 bf 79 05 80 00 00 	movabs $0x800579,%rdi
  8005f6:	00 00 00 
  8005f9:	48 b8 e9 07 80 00 00 	movabs $0x8007e9,%rax
  800600:	00 00 00 
  800603:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800605:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80060c:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800613:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800617:	48 b8 3e 01 80 00 00 	movabs $0x80013e,%rax
  80061e:	00 00 00 
  800621:	ff d0                	callq  *%rax

  return b.cnt;
}
  800623:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800629:	c9                   	leaveq 
  80062a:	c3                   	retq   

000000000080062b <cprintf>:

int
cprintf(const char *fmt, ...) {
  80062b:	55                   	push   %rbp
  80062c:	48 89 e5             	mov    %rsp,%rbp
  80062f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800636:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80063d:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800644:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80064b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800652:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800659:	84 c0                	test   %al,%al
  80065b:	74 20                	je     80067d <cprintf+0x52>
  80065d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800661:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800665:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800669:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80066d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800671:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800675:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800679:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80067d:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800684:	00 00 00 
  800687:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80068e:	00 00 00 
  800691:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800695:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80069c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8006a3:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8006aa:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8006b1:	48 b8 c3 05 80 00 00 	movabs $0x8005c3,%rax
  8006b8:	00 00 00 
  8006bb:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8006bd:	c9                   	leaveq 
  8006be:	c3                   	retq   

00000000008006bf <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8006bf:	55                   	push   %rbp
  8006c0:	48 89 e5             	mov    %rsp,%rbp
  8006c3:	41 57                	push   %r15
  8006c5:	41 56                	push   %r14
  8006c7:	41 55                	push   %r13
  8006c9:	41 54                	push   %r12
  8006cb:	53                   	push   %rbx
  8006cc:	48 83 ec 18          	sub    $0x18,%rsp
  8006d0:	49 89 fc             	mov    %rdi,%r12
  8006d3:	49 89 f5             	mov    %rsi,%r13
  8006d6:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8006da:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006dd:	41 89 cf             	mov    %ecx,%r15d
  8006e0:	49 39 d7             	cmp    %rdx,%r15
  8006e3:	76 45                	jbe    80072a <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006e5:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006e9:	85 db                	test   %ebx,%ebx
  8006eb:	7e 0e                	jle    8006fb <printnum+0x3c>
      putch(padc, putdat);
  8006ed:	4c 89 ee             	mov    %r13,%rsi
  8006f0:	44 89 f7             	mov    %r14d,%edi
  8006f3:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006f6:	83 eb 01             	sub    $0x1,%ebx
  8006f9:	75 f2                	jne    8006ed <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006fb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800704:	49 f7 f7             	div    %r15
  800707:	48 b8 8a 14 80 00 00 	movabs $0x80148a,%rax
  80070e:	00 00 00 
  800711:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800715:	4c 89 ee             	mov    %r13,%rsi
  800718:	41 ff d4             	callq  *%r12
}
  80071b:	48 83 c4 18          	add    $0x18,%rsp
  80071f:	5b                   	pop    %rbx
  800720:	41 5c                	pop    %r12
  800722:	41 5d                	pop    %r13
  800724:	41 5e                	pop    %r14
  800726:	41 5f                	pop    %r15
  800728:	5d                   	pop    %rbp
  800729:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80072a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80072e:	ba 00 00 00 00       	mov    $0x0,%edx
  800733:	49 f7 f7             	div    %r15
  800736:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80073a:	48 89 c2             	mov    %rax,%rdx
  80073d:	48 b8 bf 06 80 00 00 	movabs $0x8006bf,%rax
  800744:	00 00 00 
  800747:	ff d0                	callq  *%rax
  800749:	eb b0                	jmp    8006fb <printnum+0x3c>

000000000080074b <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80074b:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80074f:	48 8b 06             	mov    (%rsi),%rax
  800752:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800756:	73 0a                	jae    800762 <sprintputch+0x17>
    *b->buf++ = ch;
  800758:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80075c:	48 89 16             	mov    %rdx,(%rsi)
  80075f:	40 88 38             	mov    %dil,(%rax)
}
  800762:	c3                   	retq   

0000000000800763 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800763:	55                   	push   %rbp
  800764:	48 89 e5             	mov    %rsp,%rbp
  800767:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80076e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800775:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80077c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800783:	84 c0                	test   %al,%al
  800785:	74 20                	je     8007a7 <printfmt+0x44>
  800787:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80078b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80078f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800793:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800797:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80079b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80079f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8007a3:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8007a7:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8007ae:	00 00 00 
  8007b1:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8007b8:	00 00 00 
  8007bb:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8007bf:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8007c6:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8007cd:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8007d4:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007db:	48 b8 e9 07 80 00 00 	movabs $0x8007e9,%rax
  8007e2:	00 00 00 
  8007e5:	ff d0                	callq  *%rax
}
  8007e7:	c9                   	leaveq 
  8007e8:	c3                   	retq   

00000000008007e9 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007e9:	55                   	push   %rbp
  8007ea:	48 89 e5             	mov    %rsp,%rbp
  8007ed:	41 57                	push   %r15
  8007ef:	41 56                	push   %r14
  8007f1:	41 55                	push   %r13
  8007f3:	41 54                	push   %r12
  8007f5:	53                   	push   %rbx
  8007f6:	48 83 ec 48          	sub    $0x48,%rsp
  8007fa:	49 89 fd             	mov    %rdi,%r13
  8007fd:	49 89 f7             	mov    %rsi,%r15
  800800:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800803:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800807:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80080b:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80080f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800813:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800817:	41 0f b6 3e          	movzbl (%r14),%edi
  80081b:	83 ff 25             	cmp    $0x25,%edi
  80081e:	74 18                	je     800838 <vprintfmt+0x4f>
      if (ch == '\0')
  800820:	85 ff                	test   %edi,%edi
  800822:	0f 84 8c 06 00 00    	je     800eb4 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800828:	4c 89 fe             	mov    %r15,%rsi
  80082b:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80082e:	49 89 de             	mov    %rbx,%r14
  800831:	eb e0                	jmp    800813 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800833:	49 89 de             	mov    %rbx,%r14
  800836:	eb db                	jmp    800813 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800838:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80083c:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800840:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800847:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80084d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800856:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80085c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800862:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800867:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80086c:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800870:	0f b6 13             	movzbl (%rbx),%edx
  800873:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800876:	3c 55                	cmp    $0x55,%al
  800878:	0f 87 8b 05 00 00    	ja     800e09 <vprintfmt+0x620>
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	49 bb 60 15 80 00 00 	movabs $0x801560,%r11
  800888:	00 00 00 
  80088b:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80088f:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800892:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800896:	eb d4                	jmp    80086c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800898:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80089b:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80089f:	eb cb                	jmp    80086c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008a1:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8008a4:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8008a8:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8008ac:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008af:	83 fa 09             	cmp    $0x9,%edx
  8008b2:	77 7e                	ja     800932 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8008b4:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8008b8:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8008bc:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8008c1:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8008c5:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008c8:	83 fa 09             	cmp    $0x9,%edx
  8008cb:	76 e7                	jbe    8008b4 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8008cd:	4c 89 f3             	mov    %r14,%rbx
  8008d0:	eb 19                	jmp    8008eb <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8008d2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d5:	83 f8 2f             	cmp    $0x2f,%eax
  8008d8:	77 2a                	ja     800904 <vprintfmt+0x11b>
  8008da:	89 c2                	mov    %eax,%edx
  8008dc:	4c 01 d2             	add    %r10,%rdx
  8008df:	83 c0 08             	add    $0x8,%eax
  8008e2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008e5:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008e8:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008eb:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008ef:	0f 89 77 ff ff ff    	jns    80086c <vprintfmt+0x83>
          width = precision, precision = -1;
  8008f5:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008f9:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008ff:	e9 68 ff ff ff       	jmpq   80086c <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800904:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800908:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80090c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800910:	eb d3                	jmp    8008e5 <vprintfmt+0xfc>
        if (width < 0)
  800912:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800915:	85 c0                	test   %eax,%eax
  800917:	41 0f 48 c0          	cmovs  %r8d,%eax
  80091b:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80091e:	4c 89 f3             	mov    %r14,%rbx
  800921:	e9 46 ff ff ff       	jmpq   80086c <vprintfmt+0x83>
  800926:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800929:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80092d:	e9 3a ff ff ff       	jmpq   80086c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800932:	4c 89 f3             	mov    %r14,%rbx
  800935:	eb b4                	jmp    8008eb <vprintfmt+0x102>
        lflag++;
  800937:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80093a:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80093d:	e9 2a ff ff ff       	jmpq   80086c <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800942:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800945:	83 f8 2f             	cmp    $0x2f,%eax
  800948:	77 19                	ja     800963 <vprintfmt+0x17a>
  80094a:	89 c2                	mov    %eax,%edx
  80094c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800950:	83 c0 08             	add    $0x8,%eax
  800953:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800956:	4c 89 fe             	mov    %r15,%rsi
  800959:	8b 3a                	mov    (%rdx),%edi
  80095b:	41 ff d5             	callq  *%r13
        break;
  80095e:	e9 b0 fe ff ff       	jmpq   800813 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800963:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800967:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096f:	eb e5                	jmp    800956 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800971:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800974:	83 f8 2f             	cmp    $0x2f,%eax
  800977:	77 5b                	ja     8009d4 <vprintfmt+0x1eb>
  800979:	89 c2                	mov    %eax,%edx
  80097b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80097f:	83 c0 08             	add    $0x8,%eax
  800982:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800985:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800987:	89 c8                	mov    %ecx,%eax
  800989:	c1 f8 1f             	sar    $0x1f,%eax
  80098c:	31 c1                	xor    %eax,%ecx
  80098e:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800990:	83 f9 0b             	cmp    $0xb,%ecx
  800993:	7f 4d                	jg     8009e2 <vprintfmt+0x1f9>
  800995:	48 63 c1             	movslq %ecx,%rax
  800998:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  80099f:	00 00 00 
  8009a2:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8009a6:	48 85 c0             	test   %rax,%rax
  8009a9:	74 37                	je     8009e2 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8009ab:	48 89 c1             	mov    %rax,%rcx
  8009ae:	48 ba ab 14 80 00 00 	movabs $0x8014ab,%rdx
  8009b5:	00 00 00 
  8009b8:	4c 89 fe             	mov    %r15,%rsi
  8009bb:	4c 89 ef             	mov    %r13,%rdi
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c3:	48 bb 63 07 80 00 00 	movabs $0x800763,%rbx
  8009ca:	00 00 00 
  8009cd:	ff d3                	callq  *%rbx
  8009cf:	e9 3f fe ff ff       	jmpq   800813 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8009d4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009d8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009dc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009e0:	eb a3                	jmp    800985 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009e2:	48 ba a2 14 80 00 00 	movabs $0x8014a2,%rdx
  8009e9:	00 00 00 
  8009ec:	4c 89 fe             	mov    %r15,%rsi
  8009ef:	4c 89 ef             	mov    %r13,%rdi
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	48 bb 63 07 80 00 00 	movabs $0x800763,%rbx
  8009fe:	00 00 00 
  800a01:	ff d3                	callq  *%rbx
  800a03:	e9 0b fe ff ff       	jmpq   800813 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800a08:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a0b:	83 f8 2f             	cmp    $0x2f,%eax
  800a0e:	77 4b                	ja     800a5b <vprintfmt+0x272>
  800a10:	89 c2                	mov    %eax,%edx
  800a12:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a16:	83 c0 08             	add    $0x8,%eax
  800a19:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a1c:	48 8b 02             	mov    (%rdx),%rax
  800a1f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800a23:	48 85 c0             	test   %rax,%rax
  800a26:	0f 84 05 04 00 00    	je     800e31 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800a2c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a30:	7e 06                	jle    800a38 <vprintfmt+0x24f>
  800a32:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a36:	75 31                	jne    800a69 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a38:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a3c:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a40:	0f b6 00             	movzbl (%rax),%eax
  800a43:	0f be f8             	movsbl %al,%edi
  800a46:	85 ff                	test   %edi,%edi
  800a48:	0f 84 c3 00 00 00    	je     800b11 <vprintfmt+0x328>
  800a4e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a52:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a56:	e9 85 00 00 00       	jmpq   800ae0 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a5b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a5f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a63:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a67:	eb b3                	jmp    800a1c <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a69:	49 63 f4             	movslq %r12d,%rsi
  800a6c:	48 89 c7             	mov    %rax,%rdi
  800a6f:	48 b8 c0 0f 80 00 00 	movabs $0x800fc0,%rax
  800a76:	00 00 00 
  800a79:	ff d0                	callq  *%rax
  800a7b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a7e:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a81:	85 f6                	test   %esi,%esi
  800a83:	7e 22                	jle    800aa7 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a85:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a89:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a8d:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a91:	4c 89 fe             	mov    %r15,%rsi
  800a94:	89 df                	mov    %ebx,%edi
  800a96:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a99:	41 83 ec 01          	sub    $0x1,%r12d
  800a9d:	75 f2                	jne    800a91 <vprintfmt+0x2a8>
  800a9f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800aa3:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800aab:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800aaf:	0f b6 00             	movzbl (%rax),%eax
  800ab2:	0f be f8             	movsbl %al,%edi
  800ab5:	85 ff                	test   %edi,%edi
  800ab7:	0f 84 56 fd ff ff    	je     800813 <vprintfmt+0x2a>
  800abd:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800ac1:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800ac5:	eb 19                	jmp    800ae0 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800ac7:	4c 89 fe             	mov    %r15,%rsi
  800aca:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800acd:	41 83 ee 01          	sub    $0x1,%r14d
  800ad1:	48 83 c3 01          	add    $0x1,%rbx
  800ad5:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800ad9:	0f be f8             	movsbl %al,%edi
  800adc:	85 ff                	test   %edi,%edi
  800ade:	74 29                	je     800b09 <vprintfmt+0x320>
  800ae0:	45 85 e4             	test   %r12d,%r12d
  800ae3:	78 06                	js     800aeb <vprintfmt+0x302>
  800ae5:	41 83 ec 01          	sub    $0x1,%r12d
  800ae9:	78 48                	js     800b33 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800aeb:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800aef:	74 d6                	je     800ac7 <vprintfmt+0x2de>
  800af1:	0f be c0             	movsbl %al,%eax
  800af4:	83 e8 20             	sub    $0x20,%eax
  800af7:	83 f8 5e             	cmp    $0x5e,%eax
  800afa:	76 cb                	jbe    800ac7 <vprintfmt+0x2de>
            putch('?', putdat);
  800afc:	4c 89 fe             	mov    %r15,%rsi
  800aff:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800b04:	41 ff d5             	callq  *%r13
  800b07:	eb c4                	jmp    800acd <vprintfmt+0x2e4>
  800b09:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b0d:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800b11:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800b14:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b18:	0f 8e f5 fc ff ff    	jle    800813 <vprintfmt+0x2a>
          putch(' ', putdat);
  800b1e:	4c 89 fe             	mov    %r15,%rsi
  800b21:	bf 20 00 00 00       	mov    $0x20,%edi
  800b26:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800b29:	83 eb 01             	sub    $0x1,%ebx
  800b2c:	75 f0                	jne    800b1e <vprintfmt+0x335>
  800b2e:	e9 e0 fc ff ff       	jmpq   800813 <vprintfmt+0x2a>
  800b33:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b37:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b3b:	eb d4                	jmp    800b11 <vprintfmt+0x328>
  if (lflag >= 2)
  800b3d:	83 f9 01             	cmp    $0x1,%ecx
  800b40:	7f 1d                	jg     800b5f <vprintfmt+0x376>
  else if (lflag)
  800b42:	85 c9                	test   %ecx,%ecx
  800b44:	74 5e                	je     800ba4 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b46:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b49:	83 f8 2f             	cmp    $0x2f,%eax
  800b4c:	77 48                	ja     800b96 <vprintfmt+0x3ad>
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b54:	83 c0 08             	add    $0x8,%eax
  800b57:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b5a:	48 8b 1a             	mov    (%rdx),%rbx
  800b5d:	eb 17                	jmp    800b76 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b5f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b62:	83 f8 2f             	cmp    $0x2f,%eax
  800b65:	77 21                	ja     800b88 <vprintfmt+0x39f>
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b6d:	83 c0 08             	add    $0x8,%eax
  800b70:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b73:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b76:	48 85 db             	test   %rbx,%rbx
  800b79:	78 50                	js     800bcb <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b7b:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b7e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b83:	e9 b4 01 00 00       	jmpq   800d3c <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b88:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b8c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b90:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b94:	eb dd                	jmp    800b73 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b96:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b9a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b9e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ba2:	eb b6                	jmp    800b5a <vprintfmt+0x371>
    return va_arg(*ap, int);
  800ba4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ba7:	83 f8 2f             	cmp    $0x2f,%eax
  800baa:	77 11                	ja     800bbd <vprintfmt+0x3d4>
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bb2:	83 c0 08             	add    $0x8,%eax
  800bb5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bb8:	48 63 1a             	movslq (%rdx),%rbx
  800bbb:	eb b9                	jmp    800b76 <vprintfmt+0x38d>
  800bbd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bc1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bc5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bc9:	eb ed                	jmp    800bb8 <vprintfmt+0x3cf>
          putch('-', putdat);
  800bcb:	4c 89 fe             	mov    %r15,%rsi
  800bce:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800bd3:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800bd6:	48 89 da             	mov    %rbx,%rdx
  800bd9:	48 f7 da             	neg    %rdx
        base = 10;
  800bdc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800be1:	e9 56 01 00 00       	jmpq   800d3c <vprintfmt+0x553>
  if (lflag >= 2)
  800be6:	83 f9 01             	cmp    $0x1,%ecx
  800be9:	7f 25                	jg     800c10 <vprintfmt+0x427>
  else if (lflag)
  800beb:	85 c9                	test   %ecx,%ecx
  800bed:	74 5e                	je     800c4d <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bef:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bf2:	83 f8 2f             	cmp    $0x2f,%eax
  800bf5:	77 48                	ja     800c3f <vprintfmt+0x456>
  800bf7:	89 c2                	mov    %eax,%edx
  800bf9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bfd:	83 c0 08             	add    $0x8,%eax
  800c00:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c03:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c06:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c0b:	e9 2c 01 00 00       	jmpq   800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c10:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c13:	83 f8 2f             	cmp    $0x2f,%eax
  800c16:	77 19                	ja     800c31 <vprintfmt+0x448>
  800c18:	89 c2                	mov    %eax,%edx
  800c1a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c1e:	83 c0 08             	add    $0x8,%eax
  800c21:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c24:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c27:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c2c:	e9 0b 01 00 00       	jmpq   800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c31:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c35:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c39:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c3d:	eb e5                	jmp    800c24 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c3f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c43:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c47:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c4b:	eb b6                	jmp    800c03 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c4d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c50:	83 f8 2f             	cmp    $0x2f,%eax
  800c53:	77 18                	ja     800c6d <vprintfmt+0x484>
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c5b:	83 c0 08             	add    $0x8,%eax
  800c5e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c61:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c63:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c68:	e9 cf 00 00 00       	jmpq   800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c6d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c71:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c75:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c79:	eb e6                	jmp    800c61 <vprintfmt+0x478>
  if (lflag >= 2)
  800c7b:	83 f9 01             	cmp    $0x1,%ecx
  800c7e:	7f 25                	jg     800ca5 <vprintfmt+0x4bc>
  else if (lflag)
  800c80:	85 c9                	test   %ecx,%ecx
  800c82:	74 5b                	je     800cdf <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c84:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c87:	83 f8 2f             	cmp    $0x2f,%eax
  800c8a:	77 45                	ja     800cd1 <vprintfmt+0x4e8>
  800c8c:	89 c2                	mov    %eax,%edx
  800c8e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c92:	83 c0 08             	add    $0x8,%eax
  800c95:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c98:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c9b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800ca0:	e9 97 00 00 00       	jmpq   800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ca5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ca8:	83 f8 2f             	cmp    $0x2f,%eax
  800cab:	77 16                	ja     800cc3 <vprintfmt+0x4da>
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cb3:	83 c0 08             	add    $0x8,%eax
  800cb6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cb9:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800cbc:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cc1:	eb 79                	jmp    800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800cc3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cc7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ccb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ccf:	eb e8                	jmp    800cb9 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800cd1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cd5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cd9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cdd:	eb b9                	jmp    800c98 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800cdf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ce2:	83 f8 2f             	cmp    $0x2f,%eax
  800ce5:	77 15                	ja     800cfc <vprintfmt+0x513>
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ced:	83 c0 08             	add    $0x8,%eax
  800cf0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cf3:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cf5:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cfa:	eb 40                	jmp    800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cfc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d00:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d04:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d08:	eb e9                	jmp    800cf3 <vprintfmt+0x50a>
        putch('0', putdat);
  800d0a:	4c 89 fe             	mov    %r15,%rsi
  800d0d:	bf 30 00 00 00       	mov    $0x30,%edi
  800d12:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800d15:	4c 89 fe             	mov    %r15,%rsi
  800d18:	bf 78 00 00 00       	mov    $0x78,%edi
  800d1d:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d20:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d23:	83 f8 2f             	cmp    $0x2f,%eax
  800d26:	77 34                	ja     800d5c <vprintfmt+0x573>
  800d28:	89 c2                	mov    %eax,%edx
  800d2a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d2e:	83 c0 08             	add    $0x8,%eax
  800d31:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d34:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d37:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d3c:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d41:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d45:	4c 89 fe             	mov    %r15,%rsi
  800d48:	4c 89 ef             	mov    %r13,%rdi
  800d4b:	48 b8 bf 06 80 00 00 	movabs $0x8006bf,%rax
  800d52:	00 00 00 
  800d55:	ff d0                	callq  *%rax
        break;
  800d57:	e9 b7 fa ff ff       	jmpq   800813 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d5c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d60:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d64:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d68:	eb ca                	jmp    800d34 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d6a:	83 f9 01             	cmp    $0x1,%ecx
  800d6d:	7f 22                	jg     800d91 <vprintfmt+0x5a8>
  else if (lflag)
  800d6f:	85 c9                	test   %ecx,%ecx
  800d71:	74 58                	je     800dcb <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d73:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d76:	83 f8 2f             	cmp    $0x2f,%eax
  800d79:	77 42                	ja     800dbd <vprintfmt+0x5d4>
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d81:	83 c0 08             	add    $0x8,%eax
  800d84:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d87:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d8a:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d8f:	eb ab                	jmp    800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d91:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d94:	83 f8 2f             	cmp    $0x2f,%eax
  800d97:	77 16                	ja     800daf <vprintfmt+0x5c6>
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d9f:	83 c0 08             	add    $0x8,%eax
  800da2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800da5:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800da8:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dad:	eb 8d                	jmp    800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800daf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800db3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800db7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dbb:	eb e8                	jmp    800da5 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800dbd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dc1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dc5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dc9:	eb bc                	jmp    800d87 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800dcb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800dce:	83 f8 2f             	cmp    $0x2f,%eax
  800dd1:	77 18                	ja     800deb <vprintfmt+0x602>
  800dd3:	89 c2                	mov    %eax,%edx
  800dd5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800dd9:	83 c0 08             	add    $0x8,%eax
  800ddc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ddf:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800de1:	b9 10 00 00 00       	mov    $0x10,%ecx
  800de6:	e9 51 ff ff ff       	jmpq   800d3c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800deb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800def:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800df3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800df7:	eb e6                	jmp    800ddf <vprintfmt+0x5f6>
        putch(ch, putdat);
  800df9:	4c 89 fe             	mov    %r15,%rsi
  800dfc:	bf 25 00 00 00       	mov    $0x25,%edi
  800e01:	41 ff d5             	callq  *%r13
        break;
  800e04:	e9 0a fa ff ff       	jmpq   800813 <vprintfmt+0x2a>
        putch('%', putdat);
  800e09:	4c 89 fe             	mov    %r15,%rsi
  800e0c:	bf 25 00 00 00       	mov    $0x25,%edi
  800e11:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800e14:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800e18:	0f 84 15 fa ff ff    	je     800833 <vprintfmt+0x4a>
  800e1e:	49 89 de             	mov    %rbx,%r14
  800e21:	49 83 ee 01          	sub    $0x1,%r14
  800e25:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800e2a:	75 f5                	jne    800e21 <vprintfmt+0x638>
  800e2c:	e9 e2 f9 ff ff       	jmpq   800813 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800e31:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800e35:	74 06                	je     800e3d <vprintfmt+0x654>
  800e37:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e3b:	7f 21                	jg     800e5e <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e3d:	bf 28 00 00 00       	mov    $0x28,%edi
  800e42:	48 bb 9c 14 80 00 00 	movabs $0x80149c,%rbx
  800e49:	00 00 00 
  800e4c:	b8 28 00 00 00       	mov    $0x28,%eax
  800e51:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e55:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e59:	e9 82 fc ff ff       	jmpq   800ae0 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e5e:	49 63 f4             	movslq %r12d,%rsi
  800e61:	48 bf 9b 14 80 00 00 	movabs $0x80149b,%rdi
  800e68:	00 00 00 
  800e6b:	48 b8 c0 0f 80 00 00 	movabs $0x800fc0,%rax
  800e72:	00 00 00 
  800e75:	ff d0                	callq  *%rax
  800e77:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e7a:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e7d:	48 be 9b 14 80 00 00 	movabs $0x80149b,%rsi
  800e84:	00 00 00 
  800e87:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	0f 8f f2 fb ff ff    	jg     800a85 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e93:	48 bb 9c 14 80 00 00 	movabs $0x80149c,%rbx
  800e9a:	00 00 00 
  800e9d:	b8 28 00 00 00       	mov    $0x28,%eax
  800ea2:	bf 28 00 00 00       	mov    $0x28,%edi
  800ea7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800eab:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800eaf:	e9 2c fc ff ff       	jmpq   800ae0 <vprintfmt+0x2f7>
}
  800eb4:	48 83 c4 48          	add    $0x48,%rsp
  800eb8:	5b                   	pop    %rbx
  800eb9:	41 5c                	pop    %r12
  800ebb:	41 5d                	pop    %r13
  800ebd:	41 5e                	pop    %r14
  800ebf:	41 5f                	pop    %r15
  800ec1:	5d                   	pop    %rbp
  800ec2:	c3                   	retq   

0000000000800ec3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800ec3:	55                   	push   %rbp
  800ec4:	48 89 e5             	mov    %rsp,%rbp
  800ec7:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ecb:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ecf:	48 63 c6             	movslq %esi,%rax
  800ed2:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800ed7:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800edb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ee2:	48 85 ff             	test   %rdi,%rdi
  800ee5:	74 2a                	je     800f11 <vsnprintf+0x4e>
  800ee7:	85 f6                	test   %esi,%esi
  800ee9:	7e 26                	jle    800f11 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800eeb:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800eef:	48 bf 4b 07 80 00 00 	movabs $0x80074b,%rdi
  800ef6:	00 00 00 
  800ef9:	48 b8 e9 07 80 00 00 	movabs $0x8007e9,%rax
  800f00:	00 00 00 
  800f03:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800f05:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800f09:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800f0c:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800f0f:	c9                   	leaveq 
  800f10:	c3                   	retq   
    return -E_INVAL;
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f16:	eb f7                	jmp    800f0f <vsnprintf+0x4c>

0000000000800f18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800f18:	55                   	push   %rbp
  800f19:	48 89 e5             	mov    %rsp,%rbp
  800f1c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800f23:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f2a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f31:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f38:	84 c0                	test   %al,%al
  800f3a:	74 20                	je     800f5c <snprintf+0x44>
  800f3c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f40:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f44:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f48:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f4c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f50:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f54:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f58:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f5c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f63:	00 00 00 
  800f66:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f6d:	00 00 00 
  800f70:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f74:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f7b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f82:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f89:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f90:	48 b8 c3 0e 80 00 00 	movabs $0x800ec3,%rax
  800f97:	00 00 00 
  800f9a:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f9c:	c9                   	leaveq 
  800f9d:	c3                   	retq   

0000000000800f9e <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f9e:	80 3f 00             	cmpb   $0x0,(%rdi)
  800fa1:	74 17                	je     800fba <strlen+0x1c>
  800fa3:	48 89 fa             	mov    %rdi,%rdx
  800fa6:	b9 01 00 00 00       	mov    $0x1,%ecx
  800fab:	29 f9                	sub    %edi,%ecx
    n++;
  800fad:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800fb0:	48 83 c2 01          	add    $0x1,%rdx
  800fb4:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fb7:	75 f4                	jne    800fad <strlen+0xf>
  800fb9:	c3                   	retq   
  800fba:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fbf:	c3                   	retq   

0000000000800fc0 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fc0:	48 85 f6             	test   %rsi,%rsi
  800fc3:	74 24                	je     800fe9 <strnlen+0x29>
  800fc5:	80 3f 00             	cmpb   $0x0,(%rdi)
  800fc8:	74 25                	je     800fef <strnlen+0x2f>
  800fca:	48 01 fe             	add    %rdi,%rsi
  800fcd:	48 89 fa             	mov    %rdi,%rdx
  800fd0:	b9 01 00 00 00       	mov    $0x1,%ecx
  800fd5:	29 f9                	sub    %edi,%ecx
    n++;
  800fd7:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fda:	48 83 c2 01          	add    $0x1,%rdx
  800fde:	48 39 f2             	cmp    %rsi,%rdx
  800fe1:	74 11                	je     800ff4 <strnlen+0x34>
  800fe3:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fe6:	75 ef                	jne    800fd7 <strnlen+0x17>
  800fe8:	c3                   	retq   
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fee:	c3                   	retq   
  800fef:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800ff4:	c3                   	retq   

0000000000800ff5 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800ff5:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800ff8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffd:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  801001:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  801004:	48 83 c2 01          	add    $0x1,%rdx
  801008:	84 c9                	test   %cl,%cl
  80100a:	75 f1                	jne    800ffd <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  80100c:	c3                   	retq   

000000000080100d <strcat>:

char *
strcat(char *dst, const char *src) {
  80100d:	55                   	push   %rbp
  80100e:	48 89 e5             	mov    %rsp,%rbp
  801011:	41 54                	push   %r12
  801013:	53                   	push   %rbx
  801014:	48 89 fb             	mov    %rdi,%rbx
  801017:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  80101a:	48 b8 9e 0f 80 00 00 	movabs $0x800f9e,%rax
  801021:	00 00 00 
  801024:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  801026:	48 63 f8             	movslq %eax,%rdi
  801029:	48 01 df             	add    %rbx,%rdi
  80102c:	4c 89 e6             	mov    %r12,%rsi
  80102f:	48 b8 f5 0f 80 00 00 	movabs $0x800ff5,%rax
  801036:	00 00 00 
  801039:	ff d0                	callq  *%rax
  return dst;
}
  80103b:	48 89 d8             	mov    %rbx,%rax
  80103e:	5b                   	pop    %rbx
  80103f:	41 5c                	pop    %r12
  801041:	5d                   	pop    %rbp
  801042:	c3                   	retq   

0000000000801043 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801043:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801046:	48 85 d2             	test   %rdx,%rdx
  801049:	74 1f                	je     80106a <strncpy+0x27>
  80104b:	48 01 fa             	add    %rdi,%rdx
  80104e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801051:	48 83 c1 01          	add    $0x1,%rcx
  801055:	44 0f b6 06          	movzbl (%rsi),%r8d
  801059:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80105d:	41 80 f8 01          	cmp    $0x1,%r8b
  801061:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801065:	48 39 ca             	cmp    %rcx,%rdx
  801068:	75 e7                	jne    801051 <strncpy+0xe>
  }
  return ret;
}
  80106a:	c3                   	retq   

000000000080106b <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  80106b:	48 89 f8             	mov    %rdi,%rax
  80106e:	48 85 d2             	test   %rdx,%rdx
  801071:	74 36                	je     8010a9 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801073:	48 83 fa 01          	cmp    $0x1,%rdx
  801077:	74 2d                	je     8010a6 <strlcpy+0x3b>
  801079:	44 0f b6 06          	movzbl (%rsi),%r8d
  80107d:	45 84 c0             	test   %r8b,%r8b
  801080:	74 24                	je     8010a6 <strlcpy+0x3b>
  801082:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801086:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  80108b:	48 83 c0 01          	add    $0x1,%rax
  80108f:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801093:	48 39 d1             	cmp    %rdx,%rcx
  801096:	74 0e                	je     8010a6 <strlcpy+0x3b>
  801098:	48 83 c1 01          	add    $0x1,%rcx
  80109c:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8010a1:	45 84 c0             	test   %r8b,%r8b
  8010a4:	75 e5                	jne    80108b <strlcpy+0x20>
    *dst = '\0';
  8010a6:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  8010a9:	48 29 f8             	sub    %rdi,%rax
}
  8010ac:	c3                   	retq   

00000000008010ad <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  8010ad:	0f b6 07             	movzbl (%rdi),%eax
  8010b0:	84 c0                	test   %al,%al
  8010b2:	74 17                	je     8010cb <strcmp+0x1e>
  8010b4:	3a 06                	cmp    (%rsi),%al
  8010b6:	75 13                	jne    8010cb <strcmp+0x1e>
    p++, q++;
  8010b8:	48 83 c7 01          	add    $0x1,%rdi
  8010bc:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8010c0:	0f b6 07             	movzbl (%rdi),%eax
  8010c3:	84 c0                	test   %al,%al
  8010c5:	74 04                	je     8010cb <strcmp+0x1e>
  8010c7:	3a 06                	cmp    (%rsi),%al
  8010c9:	74 ed                	je     8010b8 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8010cb:	0f b6 c0             	movzbl %al,%eax
  8010ce:	0f b6 16             	movzbl (%rsi),%edx
  8010d1:	29 d0                	sub    %edx,%eax
}
  8010d3:	c3                   	retq   

00000000008010d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8010d4:	48 85 d2             	test   %rdx,%rdx
  8010d7:	74 2f                	je     801108 <strncmp+0x34>
  8010d9:	0f b6 07             	movzbl (%rdi),%eax
  8010dc:	84 c0                	test   %al,%al
  8010de:	74 1f                	je     8010ff <strncmp+0x2b>
  8010e0:	3a 06                	cmp    (%rsi),%al
  8010e2:	75 1b                	jne    8010ff <strncmp+0x2b>
  8010e4:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010e7:	48 83 c7 01          	add    $0x1,%rdi
  8010eb:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010ef:	48 39 d7             	cmp    %rdx,%rdi
  8010f2:	74 1a                	je     80110e <strncmp+0x3a>
  8010f4:	0f b6 07             	movzbl (%rdi),%eax
  8010f7:	84 c0                	test   %al,%al
  8010f9:	74 04                	je     8010ff <strncmp+0x2b>
  8010fb:	3a 06                	cmp    (%rsi),%al
  8010fd:	74 e8                	je     8010e7 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010ff:	0f b6 07             	movzbl (%rdi),%eax
  801102:	0f b6 16             	movzbl (%rsi),%edx
  801105:	29 d0                	sub    %edx,%eax
}
  801107:	c3                   	retq   
    return 0;
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	c3                   	retq   
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	c3                   	retq   

0000000000801114 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  801114:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  801116:	0f b6 07             	movzbl (%rdi),%eax
  801119:	84 c0                	test   %al,%al
  80111b:	74 1e                	je     80113b <strchr+0x27>
    if (*s == c)
  80111d:	40 38 c6             	cmp    %al,%sil
  801120:	74 1f                	je     801141 <strchr+0x2d>
  for (; *s; s++)
  801122:	48 83 c7 01          	add    $0x1,%rdi
  801126:	0f b6 07             	movzbl (%rdi),%eax
  801129:	84 c0                	test   %al,%al
  80112b:	74 08                	je     801135 <strchr+0x21>
    if (*s == c)
  80112d:	38 d0                	cmp    %dl,%al
  80112f:	75 f1                	jne    801122 <strchr+0xe>
  for (; *s; s++)
  801131:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801134:	c3                   	retq   
  return 0;
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
  80113a:	c3                   	retq   
  80113b:	b8 00 00 00 00       	mov    $0x0,%eax
  801140:	c3                   	retq   
    if (*s == c)
  801141:	48 89 f8             	mov    %rdi,%rax
  801144:	c3                   	retq   

0000000000801145 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801145:	48 89 f8             	mov    %rdi,%rax
  801148:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  80114a:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  80114d:	40 38 f2             	cmp    %sil,%dl
  801150:	74 13                	je     801165 <strfind+0x20>
  801152:	84 d2                	test   %dl,%dl
  801154:	74 0f                	je     801165 <strfind+0x20>
  for (; *s; s++)
  801156:	48 83 c0 01          	add    $0x1,%rax
  80115a:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  80115d:	38 ca                	cmp    %cl,%dl
  80115f:	74 04                	je     801165 <strfind+0x20>
  801161:	84 d2                	test   %dl,%dl
  801163:	75 f1                	jne    801156 <strfind+0x11>
      break;
  return (char *)s;
}
  801165:	c3                   	retq   

0000000000801166 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801166:	48 85 d2             	test   %rdx,%rdx
  801169:	74 3a                	je     8011a5 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80116b:	48 89 f8             	mov    %rdi,%rax
  80116e:	48 09 d0             	or     %rdx,%rax
  801171:	a8 03                	test   $0x3,%al
  801173:	75 28                	jne    80119d <memset+0x37>
    uint32_t k = c & 0xFFU;
  801175:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801179:	89 f0                	mov    %esi,%eax
  80117b:	c1 e0 08             	shl    $0x8,%eax
  80117e:	89 f1                	mov    %esi,%ecx
  801180:	c1 e1 18             	shl    $0x18,%ecx
  801183:	41 89 f0             	mov    %esi,%r8d
  801186:	41 c1 e0 10          	shl    $0x10,%r8d
  80118a:	44 09 c1             	or     %r8d,%ecx
  80118d:	09 ce                	or     %ecx,%esi
  80118f:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801191:	48 c1 ea 02          	shr    $0x2,%rdx
  801195:	48 89 d1             	mov    %rdx,%rcx
  801198:	fc                   	cld    
  801199:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80119b:	eb 08                	jmp    8011a5 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  80119d:	89 f0                	mov    %esi,%eax
  80119f:	48 89 d1             	mov    %rdx,%rcx
  8011a2:	fc                   	cld    
  8011a3:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8011a5:	48 89 f8             	mov    %rdi,%rax
  8011a8:	c3                   	retq   

00000000008011a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8011a9:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8011ac:	48 39 fe             	cmp    %rdi,%rsi
  8011af:	73 40                	jae    8011f1 <memmove+0x48>
  8011b1:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8011b5:	48 39 f9             	cmp    %rdi,%rcx
  8011b8:	76 37                	jbe    8011f1 <memmove+0x48>
    s += n;
    d += n;
  8011ba:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011be:	48 89 fe             	mov    %rdi,%rsi
  8011c1:	48 09 d6             	or     %rdx,%rsi
  8011c4:	48 09 ce             	or     %rcx,%rsi
  8011c7:	40 f6 c6 03          	test   $0x3,%sil
  8011cb:	75 14                	jne    8011e1 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8011cd:	48 83 ef 04          	sub    $0x4,%rdi
  8011d1:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8011d5:	48 c1 ea 02          	shr    $0x2,%rdx
  8011d9:	48 89 d1             	mov    %rdx,%rcx
  8011dc:	fd                   	std    
  8011dd:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011df:	eb 0e                	jmp    8011ef <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011e1:	48 83 ef 01          	sub    $0x1,%rdi
  8011e5:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011e9:	48 89 d1             	mov    %rdx,%rcx
  8011ec:	fd                   	std    
  8011ed:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011ef:	fc                   	cld    
  8011f0:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011f1:	48 89 c1             	mov    %rax,%rcx
  8011f4:	48 09 d1             	or     %rdx,%rcx
  8011f7:	48 09 f1             	or     %rsi,%rcx
  8011fa:	f6 c1 03             	test   $0x3,%cl
  8011fd:	75 0e                	jne    80120d <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011ff:	48 c1 ea 02          	shr    $0x2,%rdx
  801203:	48 89 d1             	mov    %rdx,%rcx
  801206:	48 89 c7             	mov    %rax,%rdi
  801209:	fc                   	cld    
  80120a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80120c:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80120d:	48 89 c7             	mov    %rax,%rdi
  801210:	48 89 d1             	mov    %rdx,%rcx
  801213:	fc                   	cld    
  801214:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  801216:	c3                   	retq   

0000000000801217 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  801217:	55                   	push   %rbp
  801218:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  80121b:	48 b8 a9 11 80 00 00 	movabs $0x8011a9,%rax
  801222:	00 00 00 
  801225:	ff d0                	callq  *%rax
}
  801227:	5d                   	pop    %rbp
  801228:	c3                   	retq   

0000000000801229 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801229:	55                   	push   %rbp
  80122a:	48 89 e5             	mov    %rsp,%rbp
  80122d:	41 57                	push   %r15
  80122f:	41 56                	push   %r14
  801231:	41 55                	push   %r13
  801233:	41 54                	push   %r12
  801235:	53                   	push   %rbx
  801236:	48 83 ec 08          	sub    $0x8,%rsp
  80123a:	49 89 fe             	mov    %rdi,%r14
  80123d:	49 89 f7             	mov    %rsi,%r15
  801240:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801243:	48 89 f7             	mov    %rsi,%rdi
  801246:	48 b8 9e 0f 80 00 00 	movabs $0x800f9e,%rax
  80124d:	00 00 00 
  801250:	ff d0                	callq  *%rax
  801252:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801255:	4c 89 ee             	mov    %r13,%rsi
  801258:	4c 89 f7             	mov    %r14,%rdi
  80125b:	48 b8 c0 0f 80 00 00 	movabs $0x800fc0,%rax
  801262:	00 00 00 
  801265:	ff d0                	callq  *%rax
  801267:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80126a:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80126e:	4d 39 e5             	cmp    %r12,%r13
  801271:	74 26                	je     801299 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801273:	4c 89 e8             	mov    %r13,%rax
  801276:	4c 29 e0             	sub    %r12,%rax
  801279:	48 39 d8             	cmp    %rbx,%rax
  80127c:	76 2a                	jbe    8012a8 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  80127e:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801282:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801286:	4c 89 fe             	mov    %r15,%rsi
  801289:	48 b8 17 12 80 00 00 	movabs $0x801217,%rax
  801290:	00 00 00 
  801293:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801295:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801299:	48 83 c4 08          	add    $0x8,%rsp
  80129d:	5b                   	pop    %rbx
  80129e:	41 5c                	pop    %r12
  8012a0:	41 5d                	pop    %r13
  8012a2:	41 5e                	pop    %r14
  8012a4:	41 5f                	pop    %r15
  8012a6:	5d                   	pop    %rbp
  8012a7:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8012a8:	49 83 ed 01          	sub    $0x1,%r13
  8012ac:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8012b0:	4c 89 ea             	mov    %r13,%rdx
  8012b3:	4c 89 fe             	mov    %r15,%rsi
  8012b6:	48 b8 17 12 80 00 00 	movabs $0x801217,%rax
  8012bd:	00 00 00 
  8012c0:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  8012c2:	4d 01 ee             	add    %r13,%r14
  8012c5:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8012ca:	eb c9                	jmp    801295 <strlcat+0x6c>

00000000008012cc <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8012cc:	48 85 d2             	test   %rdx,%rdx
  8012cf:	74 3a                	je     80130b <memcmp+0x3f>
    if (*s1 != *s2)
  8012d1:	0f b6 0f             	movzbl (%rdi),%ecx
  8012d4:	44 0f b6 06          	movzbl (%rsi),%r8d
  8012d8:	44 38 c1             	cmp    %r8b,%cl
  8012db:	75 1d                	jne    8012fa <memcmp+0x2e>
  8012dd:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012e2:	48 39 d0             	cmp    %rdx,%rax
  8012e5:	74 1e                	je     801305 <memcmp+0x39>
    if (*s1 != *s2)
  8012e7:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012eb:	48 83 c0 01          	add    $0x1,%rax
  8012ef:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012f5:	44 38 c1             	cmp    %r8b,%cl
  8012f8:	74 e8                	je     8012e2 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012fa:	0f b6 c1             	movzbl %cl,%eax
  8012fd:	45 0f b6 c0          	movzbl %r8b,%r8d
  801301:	44 29 c0             	sub    %r8d,%eax
  801304:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	c3                   	retq   
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801310:	c3                   	retq   

0000000000801311 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801311:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801315:	48 39 c7             	cmp    %rax,%rdi
  801318:	73 19                	jae    801333 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80131a:	89 f2                	mov    %esi,%edx
  80131c:	40 38 37             	cmp    %sil,(%rdi)
  80131f:	74 16                	je     801337 <memfind+0x26>
  for (; s < ends; s++)
  801321:	48 83 c7 01          	add    $0x1,%rdi
  801325:	48 39 f8             	cmp    %rdi,%rax
  801328:	74 08                	je     801332 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80132a:	38 17                	cmp    %dl,(%rdi)
  80132c:	75 f3                	jne    801321 <memfind+0x10>
  for (; s < ends; s++)
  80132e:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801331:	c3                   	retq   
  801332:	c3                   	retq   
  for (; s < ends; s++)
  801333:	48 89 f8             	mov    %rdi,%rax
  801336:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801337:	48 89 f8             	mov    %rdi,%rax
  80133a:	c3                   	retq   

000000000080133b <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80133b:	0f b6 07             	movzbl (%rdi),%eax
  80133e:	3c 20                	cmp    $0x20,%al
  801340:	74 04                	je     801346 <strtol+0xb>
  801342:	3c 09                	cmp    $0x9,%al
  801344:	75 0f                	jne    801355 <strtol+0x1a>
    s++;
  801346:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80134a:	0f b6 07             	movzbl (%rdi),%eax
  80134d:	3c 20                	cmp    $0x20,%al
  80134f:	74 f5                	je     801346 <strtol+0xb>
  801351:	3c 09                	cmp    $0x9,%al
  801353:	74 f1                	je     801346 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801355:	3c 2b                	cmp    $0x2b,%al
  801357:	74 2b                	je     801384 <strtol+0x49>
  int neg  = 0;
  801359:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80135f:	3c 2d                	cmp    $0x2d,%al
  801361:	74 2d                	je     801390 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801363:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801369:	75 0f                	jne    80137a <strtol+0x3f>
  80136b:	80 3f 30             	cmpb   $0x30,(%rdi)
  80136e:	74 2c                	je     80139c <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801370:	85 d2                	test   %edx,%edx
  801372:	b8 0a 00 00 00       	mov    $0xa,%eax
  801377:	0f 44 d0             	cmove  %eax,%edx
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80137f:	4c 63 d2             	movslq %edx,%r10
  801382:	eb 5c                	jmp    8013e0 <strtol+0xa5>
    s++;
  801384:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801388:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80138e:	eb d3                	jmp    801363 <strtol+0x28>
    s++, neg = 1;
  801390:	48 83 c7 01          	add    $0x1,%rdi
  801394:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80139a:	eb c7                	jmp    801363 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80139c:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8013a0:	74 0f                	je     8013b1 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8013a2:	85 d2                	test   %edx,%edx
  8013a4:	75 d4                	jne    80137a <strtol+0x3f>
    s++, base = 8;
  8013a6:	48 83 c7 01          	add    $0x1,%rdi
  8013aa:	ba 08 00 00 00       	mov    $0x8,%edx
  8013af:	eb c9                	jmp    80137a <strtol+0x3f>
    s += 2, base = 16;
  8013b1:	48 83 c7 02          	add    $0x2,%rdi
  8013b5:	ba 10 00 00 00       	mov    $0x10,%edx
  8013ba:	eb be                	jmp    80137a <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8013bc:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8013c0:	41 80 f8 19          	cmp    $0x19,%r8b
  8013c4:	77 2f                	ja     8013f5 <strtol+0xba>
      dig = *s - 'a' + 10;
  8013c6:	44 0f be c1          	movsbl %cl,%r8d
  8013ca:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8013ce:	39 d1                	cmp    %edx,%ecx
  8013d0:	7d 37                	jge    801409 <strtol+0xce>
    s++, val = (val * base) + dig;
  8013d2:	48 83 c7 01          	add    $0x1,%rdi
  8013d6:	49 0f af c2          	imul   %r10,%rax
  8013da:	48 63 c9             	movslq %ecx,%rcx
  8013dd:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013e0:	0f b6 0f             	movzbl (%rdi),%ecx
  8013e3:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013e7:	41 80 f8 09          	cmp    $0x9,%r8b
  8013eb:	77 cf                	ja     8013bc <strtol+0x81>
      dig = *s - '0';
  8013ed:	0f be c9             	movsbl %cl,%ecx
  8013f0:	83 e9 30             	sub    $0x30,%ecx
  8013f3:	eb d9                	jmp    8013ce <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013f5:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013f9:	41 80 f8 19          	cmp    $0x19,%r8b
  8013fd:	77 0a                	ja     801409 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013ff:	44 0f be c1          	movsbl %cl,%r8d
  801403:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801407:	eb c5                	jmp    8013ce <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801409:	48 85 f6             	test   %rsi,%rsi
  80140c:	74 03                	je     801411 <strtol+0xd6>
    *endptr = (char *)s;
  80140e:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801411:	48 89 c2             	mov    %rax,%rdx
  801414:	48 f7 da             	neg    %rdx
  801417:	45 85 c9             	test   %r9d,%r9d
  80141a:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80141e:	c3                   	retq   
  80141f:	90                   	nop
