
obj/user/idle:     file format elf64-x86-64


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
  800023:	e8 2d 00 00 00       	callq  800055 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	53                   	push   %rbx
  80002f:	48 83 ec 08          	sub    $0x8,%rsp
  binaryname = "idle";
  800033:	48 b8 20 14 80 00 00 	movabs $0x801420,%rax
  80003a:	00 00 00 
  80003d:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  800044:	00 00 00 
  // Instead of busy-waiting like this,
  // a better way would be to use the processor's HLT instruction
  // to cause the processor to stop executing until the next interrupt -
  // doing so allows the processor to conserve power more effectively.
  while (1) {
    sys_yield();
  800047:	48 bb e0 01 80 00 00 	movabs $0x8001e0,%rbx
  80004e:	00 00 00 
  800051:	ff d3                	callq  *%rbx
  while (1) {
  800053:	eb fc                	jmp    800051 <umain+0x27>

0000000000800055 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800055:	55                   	push   %rbp
  800056:	48 89 e5             	mov    %rsp,%rbp
  800059:	41 56                	push   %r14
  80005b:	41 55                	push   %r13
  80005d:	41 54                	push   %r12
  80005f:	53                   	push   %rbx
  800060:	41 89 fd             	mov    %edi,%r13d
  800063:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800066:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80006d:	00 00 00 
  800070:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800077:	00 00 00 
  80007a:	48 39 c2             	cmp    %rax,%rdx
  80007d:	73 23                	jae    8000a2 <libmain+0x4d>
  80007f:	48 89 d3             	mov    %rdx,%rbx
  800082:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800086:	48 29 d0             	sub    %rdx,%rax
  800089:	48 c1 e8 03          	shr    $0x3,%rax
  80008d:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800092:	b8 00 00 00 00       	mov    $0x0,%eax
  800097:	ff 13                	callq  *(%rbx)
    ctor++;
  800099:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80009d:	4c 39 e3             	cmp    %r12,%rbx
  8000a0:	75 f0                	jne    800092 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000a2:	48 b8 c0 01 80 00 00 	movabs $0x8001c0,%rax
  8000a9:	00 00 00 
  8000ac:	ff d0                	callq  *%rax
  8000ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b3:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000b7:	48 c1 e0 05          	shl    $0x5,%rax
  8000bb:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000c2:	00 00 00 
  8000c5:	48 01 d0             	add    %rdx,%rax
  8000c8:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000cf:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000d2:	45 85 ed             	test   %r13d,%r13d
  8000d5:	7e 0d                	jle    8000e4 <libmain+0x8f>
    binaryname = argv[0];
  8000d7:	49 8b 06             	mov    (%r14),%rax
  8000da:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000e1:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e4:	4c 89 f6             	mov    %r14,%rsi
  8000e7:	44 89 ef             	mov    %r13d,%edi
  8000ea:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f1:	00 00 00 
  8000f4:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f6:	48 b8 0b 01 80 00 00 	movabs $0x80010b,%rax
  8000fd:	00 00 00 
  800100:	ff d0                	callq  *%rax
#endif
}
  800102:	5b                   	pop    %rbx
  800103:	41 5c                	pop    %r12
  800105:	41 5d                	pop    %r13
  800107:	41 5e                	pop    %r14
  800109:	5d                   	pop    %rbp
  80010a:	c3                   	retq   

000000000080010b <exit>:

#include <inc/lib.h>

void
exit(void) {
  80010b:	55                   	push   %rbp
  80010c:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80010f:	bf 00 00 00 00       	mov    $0x0,%edi
  800114:	48 b8 60 01 80 00 00 	movabs $0x800160,%rax
  80011b:	00 00 00 
  80011e:	ff d0                	callq  *%rax
}
  800120:	5d                   	pop    %rbp
  800121:	c3                   	retq   

0000000000800122 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800122:	55                   	push   %rbp
  800123:	48 89 e5             	mov    %rsp,%rbp
  800126:	53                   	push   %rbx
  800127:	48 89 fa             	mov    %rdi,%rdx
  80012a:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80012d:	b8 00 00 00 00       	mov    $0x0,%eax
  800132:	48 89 c3             	mov    %rax,%rbx
  800135:	48 89 c7             	mov    %rax,%rdi
  800138:	48 89 c6             	mov    %rax,%rsi
  80013b:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80013d:	5b                   	pop    %rbx
  80013e:	5d                   	pop    %rbp
  80013f:	c3                   	retq   

0000000000800140 <sys_cgetc>:

int
sys_cgetc(void) {
  800140:	55                   	push   %rbp
  800141:	48 89 e5             	mov    %rsp,%rbp
  800144:	53                   	push   %rbx
  asm volatile("int %1\n"
  800145:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014a:	b8 01 00 00 00       	mov    $0x1,%eax
  80014f:	48 89 ca             	mov    %rcx,%rdx
  800152:	48 89 cb             	mov    %rcx,%rbx
  800155:	48 89 cf             	mov    %rcx,%rdi
  800158:	48 89 ce             	mov    %rcx,%rsi
  80015b:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %rbx
  80015e:	5d                   	pop    %rbp
  80015f:	c3                   	retq   

0000000000800160 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800160:	55                   	push   %rbp
  800161:	48 89 e5             	mov    %rsp,%rbp
  800164:	53                   	push   %rbx
  800165:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800169:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 03 00 00 00       	mov    $0x3,%eax
  800176:	48 89 f1             	mov    %rsi,%rcx
  800179:	48 89 f3             	mov    %rsi,%rbx
  80017c:	48 89 f7             	mov    %rsi,%rdi
  80017f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800181:	48 85 c0             	test   %rax,%rax
  800184:	7f 07                	jg     80018d <sys_env_destroy+0x2d>
}
  800186:	48 83 c4 08          	add    $0x8,%rsp
  80018a:	5b                   	pop    %rbx
  80018b:	5d                   	pop    %rbp
  80018c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80018d:	49 89 c0             	mov    %rax,%r8
  800190:	b9 03 00 00 00       	mov    $0x3,%ecx
  800195:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  80019c:	00 00 00 
  80019f:	be 22 00 00 00       	mov    $0x22,%esi
  8001a4:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  8001ab:	00 00 00 
  8001ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b3:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  8001ba:	00 00 00 
  8001bd:	41 ff d1             	callq  *%r9

00000000008001c0 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001c0:	55                   	push   %rbp
  8001c1:	48 89 e5             	mov    %rsp,%rbp
  8001c4:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8001cf:	48 89 ca             	mov    %rcx,%rdx
  8001d2:	48 89 cb             	mov    %rcx,%rbx
  8001d5:	48 89 cf             	mov    %rcx,%rdi
  8001d8:	48 89 ce             	mov    %rcx,%rsi
  8001db:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001dd:	5b                   	pop    %rbx
  8001de:	5d                   	pop    %rbp
  8001df:	c3                   	retq   

00000000008001e0 <sys_yield>:

void
sys_yield(void) {
  8001e0:	55                   	push   %rbp
  8001e1:	48 89 e5             	mov    %rsp,%rbp
  8001e4:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001ef:	48 89 ca             	mov    %rcx,%rdx
  8001f2:	48 89 cb             	mov    %rcx,%rbx
  8001f5:	48 89 cf             	mov    %rcx,%rdi
  8001f8:	48 89 ce             	mov    %rcx,%rsi
  8001fb:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001fd:	5b                   	pop    %rbx
  8001fe:	5d                   	pop    %rbp
  8001ff:	c3                   	retq   

0000000000800200 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  800200:	55                   	push   %rbp
  800201:	48 89 e5             	mov    %rsp,%rbp
  800204:	53                   	push   %rbx
  800205:	48 83 ec 08          	sub    $0x8,%rsp
  800209:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  80020c:	4c 63 c7             	movslq %edi,%r8
  80020f:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  800212:	be 00 00 00 00       	mov    $0x0,%esi
  800217:	b8 04 00 00 00       	mov    $0x4,%eax
  80021c:	4c 89 c2             	mov    %r8,%rdx
  80021f:	48 89 f7             	mov    %rsi,%rdi
  800222:	cd 30                	int    $0x30
  if (check && ret > 0)
  800224:	48 85 c0             	test   %rax,%rax
  800227:	7f 07                	jg     800230 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  800229:	48 83 c4 08          	add    $0x8,%rsp
  80022d:	5b                   	pop    %rbx
  80022e:	5d                   	pop    %rbp
  80022f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800230:	49 89 c0             	mov    %rax,%r8
  800233:	b9 04 00 00 00       	mov    $0x4,%ecx
  800238:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  80023f:	00 00 00 
  800242:	be 22 00 00 00       	mov    $0x22,%esi
  800247:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  80024e:	00 00 00 
  800251:	b8 00 00 00 00       	mov    $0x0,%eax
  800256:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  80025d:	00 00 00 
  800260:	41 ff d1             	callq  *%r9

0000000000800263 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  800263:	55                   	push   %rbp
  800264:	48 89 e5             	mov    %rsp,%rbp
  800267:	53                   	push   %rbx
  800268:	48 83 ec 08          	sub    $0x8,%rsp
  80026c:	41 89 f9             	mov    %edi,%r9d
  80026f:	49 89 f2             	mov    %rsi,%r10
  800272:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  800275:	4d 63 c9             	movslq %r9d,%r9
  800278:	48 63 da             	movslq %edx,%rbx
  80027b:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80027e:	b8 05 00 00 00       	mov    $0x5,%eax
  800283:	4c 89 ca             	mov    %r9,%rdx
  800286:	4c 89 d1             	mov    %r10,%rcx
  800289:	cd 30                	int    $0x30
  if (check && ret > 0)
  80028b:	48 85 c0             	test   %rax,%rax
  80028e:	7f 07                	jg     800297 <sys_page_map+0x34>
}
  800290:	48 83 c4 08          	add    $0x8,%rsp
  800294:	5b                   	pop    %rbx
  800295:	5d                   	pop    %rbp
  800296:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800297:	49 89 c0             	mov    %rax,%r8
  80029a:	b9 05 00 00 00       	mov    $0x5,%ecx
  80029f:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  8002a6:	00 00 00 
  8002a9:	be 22 00 00 00       	mov    $0x22,%esi
  8002ae:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  8002b5:	00 00 00 
  8002b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002bd:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  8002c4:	00 00 00 
  8002c7:	41 ff d1             	callq  *%r9

00000000008002ca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002ca:	55                   	push   %rbp
  8002cb:	48 89 e5             	mov    %rsp,%rbp
  8002ce:	53                   	push   %rbx
  8002cf:	48 83 ec 08          	sub    $0x8,%rsp
  8002d3:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002d6:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002d9:	be 00 00 00 00       	mov    $0x0,%esi
  8002de:	b8 06 00 00 00       	mov    $0x6,%eax
  8002e3:	48 89 f3             	mov    %rsi,%rbx
  8002e6:	48 89 f7             	mov    %rsi,%rdi
  8002e9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002eb:	48 85 c0             	test   %rax,%rax
  8002ee:	7f 07                	jg     8002f7 <sys_page_unmap+0x2d>
}
  8002f0:	48 83 c4 08          	add    $0x8,%rsp
  8002f4:	5b                   	pop    %rbx
  8002f5:	5d                   	pop    %rbp
  8002f6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002f7:	49 89 c0             	mov    %rax,%r8
  8002fa:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002ff:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  800306:	00 00 00 
  800309:	be 22 00 00 00       	mov    $0x22,%esi
  80030e:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  800315:	00 00 00 
  800318:	b8 00 00 00 00       	mov    $0x0,%eax
  80031d:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  800324:	00 00 00 
  800327:	41 ff d1             	callq  *%r9

000000000080032a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  80032a:	55                   	push   %rbp
  80032b:	48 89 e5             	mov    %rsp,%rbp
  80032e:	53                   	push   %rbx
  80032f:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800333:	48 63 d7             	movslq %edi,%rdx
  800336:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  800339:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033e:	b8 08 00 00 00       	mov    $0x8,%eax
  800343:	48 89 df             	mov    %rbx,%rdi
  800346:	48 89 de             	mov    %rbx,%rsi
  800349:	cd 30                	int    $0x30
  if (check && ret > 0)
  80034b:	48 85 c0             	test   %rax,%rax
  80034e:	7f 07                	jg     800357 <sys_env_set_status+0x2d>
}
  800350:	48 83 c4 08          	add    $0x8,%rsp
  800354:	5b                   	pop    %rbx
  800355:	5d                   	pop    %rbp
  800356:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800357:	49 89 c0             	mov    %rax,%r8
  80035a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80035f:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  800366:	00 00 00 
  800369:	be 22 00 00 00       	mov    $0x22,%esi
  80036e:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  800375:	00 00 00 
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  800384:	00 00 00 
  800387:	41 ff d1             	callq  *%r9

000000000080038a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80038a:	55                   	push   %rbp
  80038b:	48 89 e5             	mov    %rsp,%rbp
  80038e:	53                   	push   %rbx
  80038f:	48 83 ec 08          	sub    $0x8,%rsp
  800393:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  800396:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800399:	be 00 00 00 00       	mov    $0x0,%esi
  80039e:	b8 09 00 00 00       	mov    $0x9,%eax
  8003a3:	48 89 f3             	mov    %rsi,%rbx
  8003a6:	48 89 f7             	mov    %rsi,%rdi
  8003a9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8003ab:	48 85 c0             	test   %rax,%rax
  8003ae:	7f 07                	jg     8003b7 <sys_env_set_pgfault_upcall+0x2d>
}
  8003b0:	48 83 c4 08          	add    $0x8,%rsp
  8003b4:	5b                   	pop    %rbx
  8003b5:	5d                   	pop    %rbp
  8003b6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8003b7:	49 89 c0             	mov    %rax,%r8
  8003ba:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003bf:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  8003c6:	00 00 00 
  8003c9:	be 22 00 00 00       	mov    $0x22,%esi
  8003ce:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  8003d5:	00 00 00 
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  8003e4:	00 00 00 
  8003e7:	41 ff d1             	callq  *%r9

00000000008003ea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003ea:	55                   	push   %rbp
  8003eb:	48 89 e5             	mov    %rsp,%rbp
  8003ee:	53                   	push   %rbx
  8003ef:	49 89 f0             	mov    %rsi,%r8
  8003f2:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003f5:	48 63 d7             	movslq %edi,%rdx
  8003f8:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003fb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800400:	be 00 00 00 00       	mov    $0x0,%esi
  800405:	4c 89 c1             	mov    %r8,%rcx
  800408:	cd 30                	int    $0x30
}
  80040a:	5b                   	pop    %rbx
  80040b:	5d                   	pop    %rbp
  80040c:	c3                   	retq   

000000000080040d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  80040d:	55                   	push   %rbp
  80040e:	48 89 e5             	mov    %rsp,%rbp
  800411:	53                   	push   %rbx
  800412:	48 83 ec 08          	sub    $0x8,%rsp
  800416:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  800419:	be 00 00 00 00       	mov    $0x0,%esi
  80041e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800423:	48 89 f1             	mov    %rsi,%rcx
  800426:	48 89 f3             	mov    %rsi,%rbx
  800429:	48 89 f7             	mov    %rsi,%rdi
  80042c:	cd 30                	int    $0x30
  if (check && ret > 0)
  80042e:	48 85 c0             	test   %rax,%rax
  800431:	7f 07                	jg     80043a <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  800433:	48 83 c4 08          	add    $0x8,%rsp
  800437:	5b                   	pop    %rbx
  800438:	5d                   	pop    %rbp
  800439:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80043a:	49 89 c0             	mov    %rax,%r8
  80043d:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800442:	48 ba 30 14 80 00 00 	movabs $0x801430,%rdx
  800449:	00 00 00 
  80044c:	be 22 00 00 00       	mov    $0x22,%esi
  800451:	48 bf 4f 14 80 00 00 	movabs $0x80144f,%rdi
  800458:	00 00 00 
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	49 b9 6d 04 80 00 00 	movabs $0x80046d,%r9
  800467:	00 00 00 
  80046a:	41 ff d1             	callq  *%r9

000000000080046d <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80046d:	55                   	push   %rbp
  80046e:	48 89 e5             	mov    %rsp,%rbp
  800471:	41 56                	push   %r14
  800473:	41 55                	push   %r13
  800475:	41 54                	push   %r12
  800477:	53                   	push   %rbx
  800478:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80047f:	49 89 fd             	mov    %rdi,%r13
  800482:	41 89 f6             	mov    %esi,%r14d
  800485:	49 89 d4             	mov    %rdx,%r12
  800488:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80048f:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800496:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80049d:	84 c0                	test   %al,%al
  80049f:	74 26                	je     8004c7 <_panic+0x5a>
  8004a1:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8004a8:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8004af:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8004b3:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8004b7:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8004bb:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004bf:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004c3:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004c7:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004ce:	00 00 00 
  8004d1:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004d8:	00 00 00 
  8004db:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004df:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004e6:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004ed:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f4:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004fb:	00 00 00 
  8004fe:	48 8b 18             	mov    (%rax),%rbx
  800501:	48 b8 c0 01 80 00 00 	movabs $0x8001c0,%rax
  800508:	00 00 00 
  80050b:	ff d0                	callq  *%rax
  80050d:	45 89 f0             	mov    %r14d,%r8d
  800510:	4c 89 e9             	mov    %r13,%rcx
  800513:	48 89 da             	mov    %rbx,%rdx
  800516:	89 c6                	mov    %eax,%esi
  800518:	48 bf 60 14 80 00 00 	movabs $0x801460,%rdi
  80051f:	00 00 00 
  800522:	b8 00 00 00 00       	mov    $0x0,%eax
  800527:	48 bb 0f 06 80 00 00 	movabs $0x80060f,%rbx
  80052e:	00 00 00 
  800531:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800533:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80053a:	4c 89 e7             	mov    %r12,%rdi
  80053d:	48 b8 a7 05 80 00 00 	movabs $0x8005a7,%rax
  800544:	00 00 00 
  800547:	ff d0                	callq  *%rax
  cprintf("\n");
  800549:	48 bf 88 14 80 00 00 	movabs $0x801488,%rdi
  800550:	00 00 00 
  800553:	b8 00 00 00 00       	mov    $0x0,%eax
  800558:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80055a:	cc                   	int3   
  while (1)
  80055b:	eb fd                	jmp    80055a <_panic+0xed>

000000000080055d <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80055d:	55                   	push   %rbp
  80055e:	48 89 e5             	mov    %rsp,%rbp
  800561:	53                   	push   %rbx
  800562:	48 83 ec 08          	sub    $0x8,%rsp
  800566:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800569:	8b 06                	mov    (%rsi),%eax
  80056b:	8d 50 01             	lea    0x1(%rax),%edx
  80056e:	89 16                	mov    %edx,(%rsi)
  800570:	48 98                	cltq   
  800572:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800577:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80057d:	74 0b                	je     80058a <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80057f:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800583:	48 83 c4 08          	add    $0x8,%rsp
  800587:	5b                   	pop    %rbx
  800588:	5d                   	pop    %rbp
  800589:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80058a:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80058e:	be ff 00 00 00       	mov    $0xff,%esi
  800593:	48 b8 22 01 80 00 00 	movabs $0x800122,%rax
  80059a:	00 00 00 
  80059d:	ff d0                	callq  *%rax
    b->idx = 0;
  80059f:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8005a5:	eb d8                	jmp    80057f <putch+0x22>

00000000008005a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8005a7:	55                   	push   %rbp
  8005a8:	48 89 e5             	mov    %rsp,%rbp
  8005ab:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8005b2:	48 89 fa             	mov    %rdi,%rdx
  8005b5:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8005b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005bf:	00 00 00 
  b.cnt = 0;
  8005c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005c9:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005cc:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005d3:	48 bf 5d 05 80 00 00 	movabs $0x80055d,%rdi
  8005da:	00 00 00 
  8005dd:	48 b8 cd 07 80 00 00 	movabs $0x8007cd,%rax
  8005e4:	00 00 00 
  8005e7:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005e9:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005f0:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005f7:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005fb:	48 b8 22 01 80 00 00 	movabs $0x800122,%rax
  800602:	00 00 00 
  800605:	ff d0                	callq  *%rax

  return b.cnt;
}
  800607:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  80060d:	c9                   	leaveq 
  80060e:	c3                   	retq   

000000000080060f <cprintf>:

int
cprintf(const char *fmt, ...) {
  80060f:	55                   	push   %rbp
  800610:	48 89 e5             	mov    %rsp,%rbp
  800613:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80061a:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800621:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800628:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80062f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800636:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80063d:	84 c0                	test   %al,%al
  80063f:	74 20                	je     800661 <cprintf+0x52>
  800641:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800645:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800649:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80064d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800651:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800655:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800659:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80065d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800661:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800668:	00 00 00 
  80066b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800672:	00 00 00 
  800675:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800679:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800680:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800687:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80068e:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800695:	48 b8 a7 05 80 00 00 	movabs $0x8005a7,%rax
  80069c:	00 00 00 
  80069f:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8006a1:	c9                   	leaveq 
  8006a2:	c3                   	retq   

00000000008006a3 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8006a3:	55                   	push   %rbp
  8006a4:	48 89 e5             	mov    %rsp,%rbp
  8006a7:	41 57                	push   %r15
  8006a9:	41 56                	push   %r14
  8006ab:	41 55                	push   %r13
  8006ad:	41 54                	push   %r12
  8006af:	53                   	push   %rbx
  8006b0:	48 83 ec 18          	sub    $0x18,%rsp
  8006b4:	49 89 fc             	mov    %rdi,%r12
  8006b7:	49 89 f5             	mov    %rsi,%r13
  8006ba:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8006be:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006c1:	41 89 cf             	mov    %ecx,%r15d
  8006c4:	49 39 d7             	cmp    %rdx,%r15
  8006c7:	76 45                	jbe    80070e <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006c9:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006cd:	85 db                	test   %ebx,%ebx
  8006cf:	7e 0e                	jle    8006df <printnum+0x3c>
      putch(padc, putdat);
  8006d1:	4c 89 ee             	mov    %r13,%rsi
  8006d4:	44 89 f7             	mov    %r14d,%edi
  8006d7:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006da:	83 eb 01             	sub    $0x1,%ebx
  8006dd:	75 f2                	jne    8006d1 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006df:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e8:	49 f7 f7             	div    %r15
  8006eb:	48 b8 8a 14 80 00 00 	movabs $0x80148a,%rax
  8006f2:	00 00 00 
  8006f5:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006f9:	4c 89 ee             	mov    %r13,%rsi
  8006fc:	41 ff d4             	callq  *%r12
}
  8006ff:	48 83 c4 18          	add    $0x18,%rsp
  800703:	5b                   	pop    %rbx
  800704:	41 5c                	pop    %r12
  800706:	41 5d                	pop    %r13
  800708:	41 5e                	pop    %r14
  80070a:	41 5f                	pop    %r15
  80070c:	5d                   	pop    %rbp
  80070d:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80070e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800712:	ba 00 00 00 00       	mov    $0x0,%edx
  800717:	49 f7 f7             	div    %r15
  80071a:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80071e:	48 89 c2             	mov    %rax,%rdx
  800721:	48 b8 a3 06 80 00 00 	movabs $0x8006a3,%rax
  800728:	00 00 00 
  80072b:	ff d0                	callq  *%rax
  80072d:	eb b0                	jmp    8006df <printnum+0x3c>

000000000080072f <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80072f:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800733:	48 8b 06             	mov    (%rsi),%rax
  800736:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80073a:	73 0a                	jae    800746 <sprintputch+0x17>
    *b->buf++ = ch;
  80073c:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800740:	48 89 16             	mov    %rdx,(%rsi)
  800743:	40 88 38             	mov    %dil,(%rax)
}
  800746:	c3                   	retq   

0000000000800747 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800747:	55                   	push   %rbp
  800748:	48 89 e5             	mov    %rsp,%rbp
  80074b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800752:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800759:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800760:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800767:	84 c0                	test   %al,%al
  800769:	74 20                	je     80078b <printfmt+0x44>
  80076b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80076f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800773:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800777:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80077b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80077f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800783:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800787:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80078b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800792:	00 00 00 
  800795:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80079c:	00 00 00 
  80079f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8007a3:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8007aa:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8007b1:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8007b8:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007bf:	48 b8 cd 07 80 00 00 	movabs $0x8007cd,%rax
  8007c6:	00 00 00 
  8007c9:	ff d0                	callq  *%rax
}
  8007cb:	c9                   	leaveq 
  8007cc:	c3                   	retq   

00000000008007cd <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007cd:	55                   	push   %rbp
  8007ce:	48 89 e5             	mov    %rsp,%rbp
  8007d1:	41 57                	push   %r15
  8007d3:	41 56                	push   %r14
  8007d5:	41 55                	push   %r13
  8007d7:	41 54                	push   %r12
  8007d9:	53                   	push   %rbx
  8007da:	48 83 ec 48          	sub    $0x48,%rsp
  8007de:	49 89 fd             	mov    %rdi,%r13
  8007e1:	49 89 f7             	mov    %rsi,%r15
  8007e4:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007e7:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007eb:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007ef:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007f3:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007f7:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007fb:	41 0f b6 3e          	movzbl (%r14),%edi
  8007ff:	83 ff 25             	cmp    $0x25,%edi
  800802:	74 18                	je     80081c <vprintfmt+0x4f>
      if (ch == '\0')
  800804:	85 ff                	test   %edi,%edi
  800806:	0f 84 8c 06 00 00    	je     800e98 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80080c:	4c 89 fe             	mov    %r15,%rsi
  80080f:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800812:	49 89 de             	mov    %rbx,%r14
  800815:	eb e0                	jmp    8007f7 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800817:	49 89 de             	mov    %rbx,%r14
  80081a:	eb db                	jmp    8007f7 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80081c:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800820:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800824:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80082b:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800831:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80083a:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800840:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800846:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80084b:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800850:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800854:	0f b6 13             	movzbl (%rbx),%edx
  800857:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80085a:	3c 55                	cmp    $0x55,%al
  80085c:	0f 87 8b 05 00 00    	ja     800ded <vprintfmt+0x620>
  800862:	0f b6 c0             	movzbl %al,%eax
  800865:	49 bb 60 15 80 00 00 	movabs $0x801560,%r11
  80086c:	00 00 00 
  80086f:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800873:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800876:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80087a:	eb d4                	jmp    800850 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80087c:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80087f:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800883:	eb cb                	jmp    800850 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800885:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800888:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80088c:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800890:	8d 50 d0             	lea    -0x30(%rax),%edx
  800893:	83 fa 09             	cmp    $0x9,%edx
  800896:	77 7e                	ja     800916 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800898:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80089c:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8008a0:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8008a5:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8008a9:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008ac:	83 fa 09             	cmp    $0x9,%edx
  8008af:	76 e7                	jbe    800898 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8008b1:	4c 89 f3             	mov    %r14,%rbx
  8008b4:	eb 19                	jmp    8008cf <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8008b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b9:	83 f8 2f             	cmp    $0x2f,%eax
  8008bc:	77 2a                	ja     8008e8 <vprintfmt+0x11b>
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	4c 01 d2             	add    %r10,%rdx
  8008c3:	83 c0 08             	add    $0x8,%eax
  8008c6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c9:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008cc:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008cf:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008d3:	0f 89 77 ff ff ff    	jns    800850 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008d9:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008dd:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008e3:	e9 68 ff ff ff       	jmpq   800850 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008e8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008ec:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008f0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008f4:	eb d3                	jmp    8008c9 <vprintfmt+0xfc>
        if (width < 0)
  8008f6:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008f9:	85 c0                	test   %eax,%eax
  8008fb:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008ff:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  800902:	4c 89 f3             	mov    %r14,%rbx
  800905:	e9 46 ff ff ff       	jmpq   800850 <vprintfmt+0x83>
  80090a:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80090d:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800911:	e9 3a ff ff ff       	jmpq   800850 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800916:	4c 89 f3             	mov    %r14,%rbx
  800919:	eb b4                	jmp    8008cf <vprintfmt+0x102>
        lflag++;
  80091b:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80091e:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800921:	e9 2a ff ff ff       	jmpq   800850 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800926:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800929:	83 f8 2f             	cmp    $0x2f,%eax
  80092c:	77 19                	ja     800947 <vprintfmt+0x17a>
  80092e:	89 c2                	mov    %eax,%edx
  800930:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800934:	83 c0 08             	add    $0x8,%eax
  800937:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80093a:	4c 89 fe             	mov    %r15,%rsi
  80093d:	8b 3a                	mov    (%rdx),%edi
  80093f:	41 ff d5             	callq  *%r13
        break;
  800942:	e9 b0 fe ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800947:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80094b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80094f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800953:	eb e5                	jmp    80093a <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800955:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800958:	83 f8 2f             	cmp    $0x2f,%eax
  80095b:	77 5b                	ja     8009b8 <vprintfmt+0x1eb>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800963:	83 c0 08             	add    $0x8,%eax
  800966:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800969:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80096b:	89 c8                	mov    %ecx,%eax
  80096d:	c1 f8 1f             	sar    $0x1f,%eax
  800970:	31 c1                	xor    %eax,%ecx
  800972:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800974:	83 f9 0b             	cmp    $0xb,%ecx
  800977:	7f 4d                	jg     8009c6 <vprintfmt+0x1f9>
  800979:	48 63 c1             	movslq %ecx,%rax
  80097c:	48 ba 20 18 80 00 00 	movabs $0x801820,%rdx
  800983:	00 00 00 
  800986:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80098a:	48 85 c0             	test   %rax,%rax
  80098d:	74 37                	je     8009c6 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80098f:	48 89 c1             	mov    %rax,%rcx
  800992:	48 ba ab 14 80 00 00 	movabs $0x8014ab,%rdx
  800999:	00 00 00 
  80099c:	4c 89 fe             	mov    %r15,%rsi
  80099f:	4c 89 ef             	mov    %r13,%rdi
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a7:	48 bb 47 07 80 00 00 	movabs $0x800747,%rbx
  8009ae:	00 00 00 
  8009b1:	ff d3                	callq  *%rbx
  8009b3:	e9 3f fe ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8009b8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009bc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009c0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009c4:	eb a3                	jmp    800969 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009c6:	48 ba a2 14 80 00 00 	movabs $0x8014a2,%rdx
  8009cd:	00 00 00 
  8009d0:	4c 89 fe             	mov    %r15,%rsi
  8009d3:	4c 89 ef             	mov    %r13,%rdi
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	48 bb 47 07 80 00 00 	movabs $0x800747,%rbx
  8009e2:	00 00 00 
  8009e5:	ff d3                	callq  *%rbx
  8009e7:	e9 0b fe ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009ef:	83 f8 2f             	cmp    $0x2f,%eax
  8009f2:	77 4b                	ja     800a3f <vprintfmt+0x272>
  8009f4:	89 c2                	mov    %eax,%edx
  8009f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009fa:	83 c0 08             	add    $0x8,%eax
  8009fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a00:	48 8b 02             	mov    (%rdx),%rax
  800a03:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800a07:	48 85 c0             	test   %rax,%rax
  800a0a:	0f 84 05 04 00 00    	je     800e15 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800a10:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a14:	7e 06                	jle    800a1c <vprintfmt+0x24f>
  800a16:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a1a:	75 31                	jne    800a4d <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a20:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a24:	0f b6 00             	movzbl (%rax),%eax
  800a27:	0f be f8             	movsbl %al,%edi
  800a2a:	85 ff                	test   %edi,%edi
  800a2c:	0f 84 c3 00 00 00    	je     800af5 <vprintfmt+0x328>
  800a32:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a36:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a3a:	e9 85 00 00 00       	jmpq   800ac4 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a3f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a43:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a47:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a4b:	eb b3                	jmp    800a00 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a4d:	49 63 f4             	movslq %r12d,%rsi
  800a50:	48 89 c7             	mov    %rax,%rdi
  800a53:	48 b8 a4 0f 80 00 00 	movabs $0x800fa4,%rax
  800a5a:	00 00 00 
  800a5d:	ff d0                	callq  *%rax
  800a5f:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a62:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a65:	85 f6                	test   %esi,%esi
  800a67:	7e 22                	jle    800a8b <vprintfmt+0x2be>
            putch(padc, putdat);
  800a69:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a6d:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a71:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a75:	4c 89 fe             	mov    %r15,%rsi
  800a78:	89 df                	mov    %ebx,%edi
  800a7a:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a7d:	41 83 ec 01          	sub    $0x1,%r12d
  800a81:	75 f2                	jne    800a75 <vprintfmt+0x2a8>
  800a83:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a87:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a8f:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a93:	0f b6 00             	movzbl (%rax),%eax
  800a96:	0f be f8             	movsbl %al,%edi
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	0f 84 56 fd ff ff    	je     8007f7 <vprintfmt+0x2a>
  800aa1:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800aa5:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800aa9:	eb 19                	jmp    800ac4 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800aab:	4c 89 fe             	mov    %r15,%rsi
  800aae:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab1:	41 83 ee 01          	sub    $0x1,%r14d
  800ab5:	48 83 c3 01          	add    $0x1,%rbx
  800ab9:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800abd:	0f be f8             	movsbl %al,%edi
  800ac0:	85 ff                	test   %edi,%edi
  800ac2:	74 29                	je     800aed <vprintfmt+0x320>
  800ac4:	45 85 e4             	test   %r12d,%r12d
  800ac7:	78 06                	js     800acf <vprintfmt+0x302>
  800ac9:	41 83 ec 01          	sub    $0x1,%r12d
  800acd:	78 48                	js     800b17 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800acf:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800ad3:	74 d6                	je     800aab <vprintfmt+0x2de>
  800ad5:	0f be c0             	movsbl %al,%eax
  800ad8:	83 e8 20             	sub    $0x20,%eax
  800adb:	83 f8 5e             	cmp    $0x5e,%eax
  800ade:	76 cb                	jbe    800aab <vprintfmt+0x2de>
            putch('?', putdat);
  800ae0:	4c 89 fe             	mov    %r15,%rsi
  800ae3:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ae8:	41 ff d5             	callq  *%r13
  800aeb:	eb c4                	jmp    800ab1 <vprintfmt+0x2e4>
  800aed:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800af1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800af5:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800af8:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800afc:	0f 8e f5 fc ff ff    	jle    8007f7 <vprintfmt+0x2a>
          putch(' ', putdat);
  800b02:	4c 89 fe             	mov    %r15,%rsi
  800b05:	bf 20 00 00 00       	mov    $0x20,%edi
  800b0a:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800b0d:	83 eb 01             	sub    $0x1,%ebx
  800b10:	75 f0                	jne    800b02 <vprintfmt+0x335>
  800b12:	e9 e0 fc ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
  800b17:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b1b:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b1f:	eb d4                	jmp    800af5 <vprintfmt+0x328>
  if (lflag >= 2)
  800b21:	83 f9 01             	cmp    $0x1,%ecx
  800b24:	7f 1d                	jg     800b43 <vprintfmt+0x376>
  else if (lflag)
  800b26:	85 c9                	test   %ecx,%ecx
  800b28:	74 5e                	je     800b88 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b2a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b2d:	83 f8 2f             	cmp    $0x2f,%eax
  800b30:	77 48                	ja     800b7a <vprintfmt+0x3ad>
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b38:	83 c0 08             	add    $0x8,%eax
  800b3b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b3e:	48 8b 1a             	mov    (%rdx),%rbx
  800b41:	eb 17                	jmp    800b5a <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b43:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b46:	83 f8 2f             	cmp    $0x2f,%eax
  800b49:	77 21                	ja     800b6c <vprintfmt+0x39f>
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b51:	83 c0 08             	add    $0x8,%eax
  800b54:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b57:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b5a:	48 85 db             	test   %rbx,%rbx
  800b5d:	78 50                	js     800baf <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b5f:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b62:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b67:	e9 b4 01 00 00       	jmpq   800d20 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b6c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b70:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b74:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b78:	eb dd                	jmp    800b57 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b7a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b7e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b82:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b86:	eb b6                	jmp    800b3e <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b88:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b8b:	83 f8 2f             	cmp    $0x2f,%eax
  800b8e:	77 11                	ja     800ba1 <vprintfmt+0x3d4>
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b96:	83 c0 08             	add    $0x8,%eax
  800b99:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b9c:	48 63 1a             	movslq (%rdx),%rbx
  800b9f:	eb b9                	jmp    800b5a <vprintfmt+0x38d>
  800ba1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ba5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ba9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bad:	eb ed                	jmp    800b9c <vprintfmt+0x3cf>
          putch('-', putdat);
  800baf:	4c 89 fe             	mov    %r15,%rsi
  800bb2:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800bb7:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800bba:	48 89 da             	mov    %rbx,%rdx
  800bbd:	48 f7 da             	neg    %rdx
        base = 10;
  800bc0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bc5:	e9 56 01 00 00       	jmpq   800d20 <vprintfmt+0x553>
  if (lflag >= 2)
  800bca:	83 f9 01             	cmp    $0x1,%ecx
  800bcd:	7f 25                	jg     800bf4 <vprintfmt+0x427>
  else if (lflag)
  800bcf:	85 c9                	test   %ecx,%ecx
  800bd1:	74 5e                	je     800c31 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bd3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bd6:	83 f8 2f             	cmp    $0x2f,%eax
  800bd9:	77 48                	ja     800c23 <vprintfmt+0x456>
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800be1:	83 c0 08             	add    $0x8,%eax
  800be4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800be7:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bea:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bef:	e9 2c 01 00 00       	jmpq   800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bf4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bf7:	83 f8 2f             	cmp    $0x2f,%eax
  800bfa:	77 19                	ja     800c15 <vprintfmt+0x448>
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c02:	83 c0 08             	add    $0x8,%eax
  800c05:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c08:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c0b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c10:	e9 0b 01 00 00       	jmpq   800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c15:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c19:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c1d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c21:	eb e5                	jmp    800c08 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c23:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c27:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c2b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c2f:	eb b6                	jmp    800be7 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c31:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c34:	83 f8 2f             	cmp    $0x2f,%eax
  800c37:	77 18                	ja     800c51 <vprintfmt+0x484>
  800c39:	89 c2                	mov    %eax,%edx
  800c3b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c3f:	83 c0 08             	add    $0x8,%eax
  800c42:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c45:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c47:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c4c:	e9 cf 00 00 00       	jmpq   800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c51:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c55:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c59:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c5d:	eb e6                	jmp    800c45 <vprintfmt+0x478>
  if (lflag >= 2)
  800c5f:	83 f9 01             	cmp    $0x1,%ecx
  800c62:	7f 25                	jg     800c89 <vprintfmt+0x4bc>
  else if (lflag)
  800c64:	85 c9                	test   %ecx,%ecx
  800c66:	74 5b                	je     800cc3 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c68:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c6b:	83 f8 2f             	cmp    $0x2f,%eax
  800c6e:	77 45                	ja     800cb5 <vprintfmt+0x4e8>
  800c70:	89 c2                	mov    %eax,%edx
  800c72:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c76:	83 c0 08             	add    $0x8,%eax
  800c79:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c7c:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c7f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c84:	e9 97 00 00 00       	jmpq   800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c89:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c8c:	83 f8 2f             	cmp    $0x2f,%eax
  800c8f:	77 16                	ja     800ca7 <vprintfmt+0x4da>
  800c91:	89 c2                	mov    %eax,%edx
  800c93:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c97:	83 c0 08             	add    $0x8,%eax
  800c9a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c9d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800ca0:	b9 08 00 00 00       	mov    $0x8,%ecx
  800ca5:	eb 79                	jmp    800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ca7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800caf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cb3:	eb e8                	jmp    800c9d <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800cb5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cb9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cbd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cc1:	eb b9                	jmp    800c7c <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800cc3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cc6:	83 f8 2f             	cmp    $0x2f,%eax
  800cc9:	77 15                	ja     800ce0 <vprintfmt+0x513>
  800ccb:	89 c2                	mov    %eax,%edx
  800ccd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cd1:	83 c0 08             	add    $0x8,%eax
  800cd4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cd7:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cd9:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cde:	eb 40                	jmp    800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800ce0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ce4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ce8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cec:	eb e9                	jmp    800cd7 <vprintfmt+0x50a>
        putch('0', putdat);
  800cee:	4c 89 fe             	mov    %r15,%rsi
  800cf1:	bf 30 00 00 00       	mov    $0x30,%edi
  800cf6:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cf9:	4c 89 fe             	mov    %r15,%rsi
  800cfc:	bf 78 00 00 00       	mov    $0x78,%edi
  800d01:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d04:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d07:	83 f8 2f             	cmp    $0x2f,%eax
  800d0a:	77 34                	ja     800d40 <vprintfmt+0x573>
  800d0c:	89 c2                	mov    %eax,%edx
  800d0e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d12:	83 c0 08             	add    $0x8,%eax
  800d15:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d18:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d1b:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d20:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d25:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d29:	4c 89 fe             	mov    %r15,%rsi
  800d2c:	4c 89 ef             	mov    %r13,%rdi
  800d2f:	48 b8 a3 06 80 00 00 	movabs $0x8006a3,%rax
  800d36:	00 00 00 
  800d39:	ff d0                	callq  *%rax
        break;
  800d3b:	e9 b7 fa ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d40:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d44:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d48:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d4c:	eb ca                	jmp    800d18 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d4e:	83 f9 01             	cmp    $0x1,%ecx
  800d51:	7f 22                	jg     800d75 <vprintfmt+0x5a8>
  else if (lflag)
  800d53:	85 c9                	test   %ecx,%ecx
  800d55:	74 58                	je     800daf <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d57:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d5a:	83 f8 2f             	cmp    $0x2f,%eax
  800d5d:	77 42                	ja     800da1 <vprintfmt+0x5d4>
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d65:	83 c0 08             	add    $0x8,%eax
  800d68:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d6b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d6e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d73:	eb ab                	jmp    800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d75:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d78:	83 f8 2f             	cmp    $0x2f,%eax
  800d7b:	77 16                	ja     800d93 <vprintfmt+0x5c6>
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d83:	83 c0 08             	add    $0x8,%eax
  800d86:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d89:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d8c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d91:	eb 8d                	jmp    800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d93:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d97:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d9b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d9f:	eb e8                	jmp    800d89 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800da1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800da5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800da9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dad:	eb bc                	jmp    800d6b <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800daf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800db2:	83 f8 2f             	cmp    $0x2f,%eax
  800db5:	77 18                	ja     800dcf <vprintfmt+0x602>
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800dbd:	83 c0 08             	add    $0x8,%eax
  800dc0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800dc3:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800dc5:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dca:	e9 51 ff ff ff       	jmpq   800d20 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800dcf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dd3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dd7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ddb:	eb e6                	jmp    800dc3 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800ddd:	4c 89 fe             	mov    %r15,%rsi
  800de0:	bf 25 00 00 00       	mov    $0x25,%edi
  800de5:	41 ff d5             	callq  *%r13
        break;
  800de8:	e9 0a fa ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
        putch('%', putdat);
  800ded:	4c 89 fe             	mov    %r15,%rsi
  800df0:	bf 25 00 00 00       	mov    $0x25,%edi
  800df5:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800df8:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800dfc:	0f 84 15 fa ff ff    	je     800817 <vprintfmt+0x4a>
  800e02:	49 89 de             	mov    %rbx,%r14
  800e05:	49 83 ee 01          	sub    $0x1,%r14
  800e09:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800e0e:	75 f5                	jne    800e05 <vprintfmt+0x638>
  800e10:	e9 e2 f9 ff ff       	jmpq   8007f7 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800e15:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800e19:	74 06                	je     800e21 <vprintfmt+0x654>
  800e1b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e1f:	7f 21                	jg     800e42 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e21:	bf 28 00 00 00       	mov    $0x28,%edi
  800e26:	48 bb 9c 14 80 00 00 	movabs $0x80149c,%rbx
  800e2d:	00 00 00 
  800e30:	b8 28 00 00 00       	mov    $0x28,%eax
  800e35:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e39:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e3d:	e9 82 fc ff ff       	jmpq   800ac4 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e42:	49 63 f4             	movslq %r12d,%rsi
  800e45:	48 bf 9b 14 80 00 00 	movabs $0x80149b,%rdi
  800e4c:	00 00 00 
  800e4f:	48 b8 a4 0f 80 00 00 	movabs $0x800fa4,%rax
  800e56:	00 00 00 
  800e59:	ff d0                	callq  *%rax
  800e5b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e5e:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e61:	48 be 9b 14 80 00 00 	movabs $0x80149b,%rsi
  800e68:	00 00 00 
  800e6b:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	0f 8f f2 fb ff ff    	jg     800a69 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e77:	48 bb 9c 14 80 00 00 	movabs $0x80149c,%rbx
  800e7e:	00 00 00 
  800e81:	b8 28 00 00 00       	mov    $0x28,%eax
  800e86:	bf 28 00 00 00       	mov    $0x28,%edi
  800e8b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e8f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e93:	e9 2c fc ff ff       	jmpq   800ac4 <vprintfmt+0x2f7>
}
  800e98:	48 83 c4 48          	add    $0x48,%rsp
  800e9c:	5b                   	pop    %rbx
  800e9d:	41 5c                	pop    %r12
  800e9f:	41 5d                	pop    %r13
  800ea1:	41 5e                	pop    %r14
  800ea3:	41 5f                	pop    %r15
  800ea5:	5d                   	pop    %rbp
  800ea6:	c3                   	retq   

0000000000800ea7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800ea7:	55                   	push   %rbp
  800ea8:	48 89 e5             	mov    %rsp,%rbp
  800eab:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800eaf:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800eb3:	48 63 c6             	movslq %esi,%rax
  800eb6:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800ebb:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800ebf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ec6:	48 85 ff             	test   %rdi,%rdi
  800ec9:	74 2a                	je     800ef5 <vsnprintf+0x4e>
  800ecb:	85 f6                	test   %esi,%esi
  800ecd:	7e 26                	jle    800ef5 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ecf:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800ed3:	48 bf 2f 07 80 00 00 	movabs $0x80072f,%rdi
  800eda:	00 00 00 
  800edd:	48 b8 cd 07 80 00 00 	movabs $0x8007cd,%rax
  800ee4:	00 00 00 
  800ee7:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ee9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800eed:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ef0:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ef3:	c9                   	leaveq 
  800ef4:	c3                   	retq   
    return -E_INVAL;
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efa:	eb f7                	jmp    800ef3 <vsnprintf+0x4c>

0000000000800efc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800efc:	55                   	push   %rbp
  800efd:	48 89 e5             	mov    %rsp,%rbp
  800f00:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800f07:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f0e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f15:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f1c:	84 c0                	test   %al,%al
  800f1e:	74 20                	je     800f40 <snprintf+0x44>
  800f20:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f24:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f28:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f2c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f30:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f34:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f38:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f3c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f40:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f47:	00 00 00 
  800f4a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f51:	00 00 00 
  800f54:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f58:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f5f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f66:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f6d:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f74:	48 b8 a7 0e 80 00 00 	movabs $0x800ea7,%rax
  800f7b:	00 00 00 
  800f7e:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f80:	c9                   	leaveq 
  800f81:	c3                   	retq   

0000000000800f82 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f82:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f85:	74 17                	je     800f9e <strlen+0x1c>
  800f87:	48 89 fa             	mov    %rdi,%rdx
  800f8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f8f:	29 f9                	sub    %edi,%ecx
    n++;
  800f91:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f94:	48 83 c2 01          	add    $0x1,%rdx
  800f98:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f9b:	75 f4                	jne    800f91 <strlen+0xf>
  800f9d:	c3                   	retq   
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fa3:	c3                   	retq   

0000000000800fa4 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa4:	48 85 f6             	test   %rsi,%rsi
  800fa7:	74 24                	je     800fcd <strnlen+0x29>
  800fa9:	80 3f 00             	cmpb   $0x0,(%rdi)
  800fac:	74 25                	je     800fd3 <strnlen+0x2f>
  800fae:	48 01 fe             	add    %rdi,%rsi
  800fb1:	48 89 fa             	mov    %rdi,%rdx
  800fb4:	b9 01 00 00 00       	mov    $0x1,%ecx
  800fb9:	29 f9                	sub    %edi,%ecx
    n++;
  800fbb:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fbe:	48 83 c2 01          	add    $0x1,%rdx
  800fc2:	48 39 f2             	cmp    %rsi,%rdx
  800fc5:	74 11                	je     800fd8 <strnlen+0x34>
  800fc7:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fca:	75 ef                	jne    800fbb <strnlen+0x17>
  800fcc:	c3                   	retq   
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	c3                   	retq   
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fd8:	c3                   	retq   

0000000000800fd9 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fd9:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe1:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fe5:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fe8:	48 83 c2 01          	add    $0x1,%rdx
  800fec:	84 c9                	test   %cl,%cl
  800fee:	75 f1                	jne    800fe1 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800ff0:	c3                   	retq   

0000000000800ff1 <strcat>:

char *
strcat(char *dst, const char *src) {
  800ff1:	55                   	push   %rbp
  800ff2:	48 89 e5             	mov    %rsp,%rbp
  800ff5:	41 54                	push   %r12
  800ff7:	53                   	push   %rbx
  800ff8:	48 89 fb             	mov    %rdi,%rbx
  800ffb:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800ffe:	48 b8 82 0f 80 00 00 	movabs $0x800f82,%rax
  801005:	00 00 00 
  801008:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  80100a:	48 63 f8             	movslq %eax,%rdi
  80100d:	48 01 df             	add    %rbx,%rdi
  801010:	4c 89 e6             	mov    %r12,%rsi
  801013:	48 b8 d9 0f 80 00 00 	movabs $0x800fd9,%rax
  80101a:	00 00 00 
  80101d:	ff d0                	callq  *%rax
  return dst;
}
  80101f:	48 89 d8             	mov    %rbx,%rax
  801022:	5b                   	pop    %rbx
  801023:	41 5c                	pop    %r12
  801025:	5d                   	pop    %rbp
  801026:	c3                   	retq   

0000000000801027 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801027:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  80102a:	48 85 d2             	test   %rdx,%rdx
  80102d:	74 1f                	je     80104e <strncpy+0x27>
  80102f:	48 01 fa             	add    %rdi,%rdx
  801032:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801035:	48 83 c1 01          	add    $0x1,%rcx
  801039:	44 0f b6 06          	movzbl (%rsi),%r8d
  80103d:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801041:	41 80 f8 01          	cmp    $0x1,%r8b
  801045:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801049:	48 39 ca             	cmp    %rcx,%rdx
  80104c:	75 e7                	jne    801035 <strncpy+0xe>
  }
  return ret;
}
  80104e:	c3                   	retq   

000000000080104f <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  80104f:	48 89 f8             	mov    %rdi,%rax
  801052:	48 85 d2             	test   %rdx,%rdx
  801055:	74 36                	je     80108d <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801057:	48 83 fa 01          	cmp    $0x1,%rdx
  80105b:	74 2d                	je     80108a <strlcpy+0x3b>
  80105d:	44 0f b6 06          	movzbl (%rsi),%r8d
  801061:	45 84 c0             	test   %r8b,%r8b
  801064:	74 24                	je     80108a <strlcpy+0x3b>
  801066:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  80106a:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  80106f:	48 83 c0 01          	add    $0x1,%rax
  801073:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801077:	48 39 d1             	cmp    %rdx,%rcx
  80107a:	74 0e                	je     80108a <strlcpy+0x3b>
  80107c:	48 83 c1 01          	add    $0x1,%rcx
  801080:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  801085:	45 84 c0             	test   %r8b,%r8b
  801088:	75 e5                	jne    80106f <strlcpy+0x20>
    *dst = '\0';
  80108a:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  80108d:	48 29 f8             	sub    %rdi,%rax
}
  801090:	c3                   	retq   

0000000000801091 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801091:	0f b6 07             	movzbl (%rdi),%eax
  801094:	84 c0                	test   %al,%al
  801096:	74 17                	je     8010af <strcmp+0x1e>
  801098:	3a 06                	cmp    (%rsi),%al
  80109a:	75 13                	jne    8010af <strcmp+0x1e>
    p++, q++;
  80109c:	48 83 c7 01          	add    $0x1,%rdi
  8010a0:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8010a4:	0f b6 07             	movzbl (%rdi),%eax
  8010a7:	84 c0                	test   %al,%al
  8010a9:	74 04                	je     8010af <strcmp+0x1e>
  8010ab:	3a 06                	cmp    (%rsi),%al
  8010ad:	74 ed                	je     80109c <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8010af:	0f b6 c0             	movzbl %al,%eax
  8010b2:	0f b6 16             	movzbl (%rsi),%edx
  8010b5:	29 d0                	sub    %edx,%eax
}
  8010b7:	c3                   	retq   

00000000008010b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8010b8:	48 85 d2             	test   %rdx,%rdx
  8010bb:	74 2f                	je     8010ec <strncmp+0x34>
  8010bd:	0f b6 07             	movzbl (%rdi),%eax
  8010c0:	84 c0                	test   %al,%al
  8010c2:	74 1f                	je     8010e3 <strncmp+0x2b>
  8010c4:	3a 06                	cmp    (%rsi),%al
  8010c6:	75 1b                	jne    8010e3 <strncmp+0x2b>
  8010c8:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010cb:	48 83 c7 01          	add    $0x1,%rdi
  8010cf:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010d3:	48 39 d7             	cmp    %rdx,%rdi
  8010d6:	74 1a                	je     8010f2 <strncmp+0x3a>
  8010d8:	0f b6 07             	movzbl (%rdi),%eax
  8010db:	84 c0                	test   %al,%al
  8010dd:	74 04                	je     8010e3 <strncmp+0x2b>
  8010df:	3a 06                	cmp    (%rsi),%al
  8010e1:	74 e8                	je     8010cb <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010e3:	0f b6 07             	movzbl (%rdi),%eax
  8010e6:	0f b6 16             	movzbl (%rsi),%edx
  8010e9:	29 d0                	sub    %edx,%eax
}
  8010eb:	c3                   	retq   
    return 0;
  8010ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f1:	c3                   	retq   
  8010f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f7:	c3                   	retq   

00000000008010f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010f8:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010fa:	0f b6 07             	movzbl (%rdi),%eax
  8010fd:	84 c0                	test   %al,%al
  8010ff:	74 1e                	je     80111f <strchr+0x27>
    if (*s == c)
  801101:	40 38 c6             	cmp    %al,%sil
  801104:	74 1f                	je     801125 <strchr+0x2d>
  for (; *s; s++)
  801106:	48 83 c7 01          	add    $0x1,%rdi
  80110a:	0f b6 07             	movzbl (%rdi),%eax
  80110d:	84 c0                	test   %al,%al
  80110f:	74 08                	je     801119 <strchr+0x21>
    if (*s == c)
  801111:	38 d0                	cmp    %dl,%al
  801113:	75 f1                	jne    801106 <strchr+0xe>
  for (; *s; s++)
  801115:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801118:	c3                   	retq   
  return 0;
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
  80111e:	c3                   	retq   
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
  801124:	c3                   	retq   
    if (*s == c)
  801125:	48 89 f8             	mov    %rdi,%rax
  801128:	c3                   	retq   

0000000000801129 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801129:	48 89 f8             	mov    %rdi,%rax
  80112c:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  80112e:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801131:	40 38 f2             	cmp    %sil,%dl
  801134:	74 13                	je     801149 <strfind+0x20>
  801136:	84 d2                	test   %dl,%dl
  801138:	74 0f                	je     801149 <strfind+0x20>
  for (; *s; s++)
  80113a:	48 83 c0 01          	add    $0x1,%rax
  80113e:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801141:	38 ca                	cmp    %cl,%dl
  801143:	74 04                	je     801149 <strfind+0x20>
  801145:	84 d2                	test   %dl,%dl
  801147:	75 f1                	jne    80113a <strfind+0x11>
      break;
  return (char *)s;
}
  801149:	c3                   	retq   

000000000080114a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  80114a:	48 85 d2             	test   %rdx,%rdx
  80114d:	74 3a                	je     801189 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80114f:	48 89 f8             	mov    %rdi,%rax
  801152:	48 09 d0             	or     %rdx,%rax
  801155:	a8 03                	test   $0x3,%al
  801157:	75 28                	jne    801181 <memset+0x37>
    uint32_t k = c & 0xFFU;
  801159:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  80115d:	89 f0                	mov    %esi,%eax
  80115f:	c1 e0 08             	shl    $0x8,%eax
  801162:	89 f1                	mov    %esi,%ecx
  801164:	c1 e1 18             	shl    $0x18,%ecx
  801167:	41 89 f0             	mov    %esi,%r8d
  80116a:	41 c1 e0 10          	shl    $0x10,%r8d
  80116e:	44 09 c1             	or     %r8d,%ecx
  801171:	09 ce                	or     %ecx,%esi
  801173:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801175:	48 c1 ea 02          	shr    $0x2,%rdx
  801179:	48 89 d1             	mov    %rdx,%rcx
  80117c:	fc                   	cld    
  80117d:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80117f:	eb 08                	jmp    801189 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801181:	89 f0                	mov    %esi,%eax
  801183:	48 89 d1             	mov    %rdx,%rcx
  801186:	fc                   	cld    
  801187:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801189:	48 89 f8             	mov    %rdi,%rax
  80118c:	c3                   	retq   

000000000080118d <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  80118d:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801190:	48 39 fe             	cmp    %rdi,%rsi
  801193:	73 40                	jae    8011d5 <memmove+0x48>
  801195:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801199:	48 39 f9             	cmp    %rdi,%rcx
  80119c:	76 37                	jbe    8011d5 <memmove+0x48>
    s += n;
    d += n;
  80119e:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011a2:	48 89 fe             	mov    %rdi,%rsi
  8011a5:	48 09 d6             	or     %rdx,%rsi
  8011a8:	48 09 ce             	or     %rcx,%rsi
  8011ab:	40 f6 c6 03          	test   $0x3,%sil
  8011af:	75 14                	jne    8011c5 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8011b1:	48 83 ef 04          	sub    $0x4,%rdi
  8011b5:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8011b9:	48 c1 ea 02          	shr    $0x2,%rdx
  8011bd:	48 89 d1             	mov    %rdx,%rcx
  8011c0:	fd                   	std    
  8011c1:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011c3:	eb 0e                	jmp    8011d3 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011c5:	48 83 ef 01          	sub    $0x1,%rdi
  8011c9:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011cd:	48 89 d1             	mov    %rdx,%rcx
  8011d0:	fd                   	std    
  8011d1:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011d3:	fc                   	cld    
  8011d4:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011d5:	48 89 c1             	mov    %rax,%rcx
  8011d8:	48 09 d1             	or     %rdx,%rcx
  8011db:	48 09 f1             	or     %rsi,%rcx
  8011de:	f6 c1 03             	test   $0x3,%cl
  8011e1:	75 0e                	jne    8011f1 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011e3:	48 c1 ea 02          	shr    $0x2,%rdx
  8011e7:	48 89 d1             	mov    %rdx,%rcx
  8011ea:	48 89 c7             	mov    %rax,%rdi
  8011ed:	fc                   	cld    
  8011ee:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011f0:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011f1:	48 89 c7             	mov    %rax,%rdi
  8011f4:	48 89 d1             	mov    %rdx,%rcx
  8011f7:	fc                   	cld    
  8011f8:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011fa:	c3                   	retq   

00000000008011fb <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011fb:	55                   	push   %rbp
  8011fc:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011ff:	48 b8 8d 11 80 00 00 	movabs $0x80118d,%rax
  801206:	00 00 00 
  801209:	ff d0                	callq  *%rax
}
  80120b:	5d                   	pop    %rbp
  80120c:	c3                   	retq   

000000000080120d <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  80120d:	55                   	push   %rbp
  80120e:	48 89 e5             	mov    %rsp,%rbp
  801211:	41 57                	push   %r15
  801213:	41 56                	push   %r14
  801215:	41 55                	push   %r13
  801217:	41 54                	push   %r12
  801219:	53                   	push   %rbx
  80121a:	48 83 ec 08          	sub    $0x8,%rsp
  80121e:	49 89 fe             	mov    %rdi,%r14
  801221:	49 89 f7             	mov    %rsi,%r15
  801224:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801227:	48 89 f7             	mov    %rsi,%rdi
  80122a:	48 b8 82 0f 80 00 00 	movabs $0x800f82,%rax
  801231:	00 00 00 
  801234:	ff d0                	callq  *%rax
  801236:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801239:	4c 89 ee             	mov    %r13,%rsi
  80123c:	4c 89 f7             	mov    %r14,%rdi
  80123f:	48 b8 a4 0f 80 00 00 	movabs $0x800fa4,%rax
  801246:	00 00 00 
  801249:	ff d0                	callq  *%rax
  80124b:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80124e:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801252:	4d 39 e5             	cmp    %r12,%r13
  801255:	74 26                	je     80127d <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801257:	4c 89 e8             	mov    %r13,%rax
  80125a:	4c 29 e0             	sub    %r12,%rax
  80125d:	48 39 d8             	cmp    %rbx,%rax
  801260:	76 2a                	jbe    80128c <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801262:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801266:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80126a:	4c 89 fe             	mov    %r15,%rsi
  80126d:	48 b8 fb 11 80 00 00 	movabs $0x8011fb,%rax
  801274:	00 00 00 
  801277:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801279:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80127d:	48 83 c4 08          	add    $0x8,%rsp
  801281:	5b                   	pop    %rbx
  801282:	41 5c                	pop    %r12
  801284:	41 5d                	pop    %r13
  801286:	41 5e                	pop    %r14
  801288:	41 5f                	pop    %r15
  80128a:	5d                   	pop    %rbp
  80128b:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80128c:	49 83 ed 01          	sub    $0x1,%r13
  801290:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801294:	4c 89 ea             	mov    %r13,%rdx
  801297:	4c 89 fe             	mov    %r15,%rsi
  80129a:	48 b8 fb 11 80 00 00 	movabs $0x8011fb,%rax
  8012a1:	00 00 00 
  8012a4:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  8012a6:	4d 01 ee             	add    %r13,%r14
  8012a9:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8012ae:	eb c9                	jmp    801279 <strlcat+0x6c>

00000000008012b0 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8012b0:	48 85 d2             	test   %rdx,%rdx
  8012b3:	74 3a                	je     8012ef <memcmp+0x3f>
    if (*s1 != *s2)
  8012b5:	0f b6 0f             	movzbl (%rdi),%ecx
  8012b8:	44 0f b6 06          	movzbl (%rsi),%r8d
  8012bc:	44 38 c1             	cmp    %r8b,%cl
  8012bf:	75 1d                	jne    8012de <memcmp+0x2e>
  8012c1:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012c6:	48 39 d0             	cmp    %rdx,%rax
  8012c9:	74 1e                	je     8012e9 <memcmp+0x39>
    if (*s1 != *s2)
  8012cb:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012cf:	48 83 c0 01          	add    $0x1,%rax
  8012d3:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012d9:	44 38 c1             	cmp    %r8b,%cl
  8012dc:	74 e8                	je     8012c6 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012de:	0f b6 c1             	movzbl %cl,%eax
  8012e1:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012e5:	44 29 c0             	sub    %r8d,%eax
  8012e8:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ee:	c3                   	retq   
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f4:	c3                   	retq   

00000000008012f5 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012f5:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012f9:	48 39 c7             	cmp    %rax,%rdi
  8012fc:	73 19                	jae    801317 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012fe:	89 f2                	mov    %esi,%edx
  801300:	40 38 37             	cmp    %sil,(%rdi)
  801303:	74 16                	je     80131b <memfind+0x26>
  for (; s < ends; s++)
  801305:	48 83 c7 01          	add    $0x1,%rdi
  801309:	48 39 f8             	cmp    %rdi,%rax
  80130c:	74 08                	je     801316 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80130e:	38 17                	cmp    %dl,(%rdi)
  801310:	75 f3                	jne    801305 <memfind+0x10>
  for (; s < ends; s++)
  801312:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801315:	c3                   	retq   
  801316:	c3                   	retq   
  for (; s < ends; s++)
  801317:	48 89 f8             	mov    %rdi,%rax
  80131a:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80131b:	48 89 f8             	mov    %rdi,%rax
  80131e:	c3                   	retq   

000000000080131f <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80131f:	0f b6 07             	movzbl (%rdi),%eax
  801322:	3c 20                	cmp    $0x20,%al
  801324:	74 04                	je     80132a <strtol+0xb>
  801326:	3c 09                	cmp    $0x9,%al
  801328:	75 0f                	jne    801339 <strtol+0x1a>
    s++;
  80132a:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80132e:	0f b6 07             	movzbl (%rdi),%eax
  801331:	3c 20                	cmp    $0x20,%al
  801333:	74 f5                	je     80132a <strtol+0xb>
  801335:	3c 09                	cmp    $0x9,%al
  801337:	74 f1                	je     80132a <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801339:	3c 2b                	cmp    $0x2b,%al
  80133b:	74 2b                	je     801368 <strtol+0x49>
  int neg  = 0;
  80133d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801343:	3c 2d                	cmp    $0x2d,%al
  801345:	74 2d                	je     801374 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801347:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80134d:	75 0f                	jne    80135e <strtol+0x3f>
  80134f:	80 3f 30             	cmpb   $0x30,(%rdi)
  801352:	74 2c                	je     801380 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801354:	85 d2                	test   %edx,%edx
  801356:	b8 0a 00 00 00       	mov    $0xa,%eax
  80135b:	0f 44 d0             	cmove  %eax,%edx
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801363:	4c 63 d2             	movslq %edx,%r10
  801366:	eb 5c                	jmp    8013c4 <strtol+0xa5>
    s++;
  801368:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80136c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801372:	eb d3                	jmp    801347 <strtol+0x28>
    s++, neg = 1;
  801374:	48 83 c7 01          	add    $0x1,%rdi
  801378:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80137e:	eb c7                	jmp    801347 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801380:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801384:	74 0f                	je     801395 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801386:	85 d2                	test   %edx,%edx
  801388:	75 d4                	jne    80135e <strtol+0x3f>
    s++, base = 8;
  80138a:	48 83 c7 01          	add    $0x1,%rdi
  80138e:	ba 08 00 00 00       	mov    $0x8,%edx
  801393:	eb c9                	jmp    80135e <strtol+0x3f>
    s += 2, base = 16;
  801395:	48 83 c7 02          	add    $0x2,%rdi
  801399:	ba 10 00 00 00       	mov    $0x10,%edx
  80139e:	eb be                	jmp    80135e <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8013a0:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8013a4:	41 80 f8 19          	cmp    $0x19,%r8b
  8013a8:	77 2f                	ja     8013d9 <strtol+0xba>
      dig = *s - 'a' + 10;
  8013aa:	44 0f be c1          	movsbl %cl,%r8d
  8013ae:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8013b2:	39 d1                	cmp    %edx,%ecx
  8013b4:	7d 37                	jge    8013ed <strtol+0xce>
    s++, val = (val * base) + dig;
  8013b6:	48 83 c7 01          	add    $0x1,%rdi
  8013ba:	49 0f af c2          	imul   %r10,%rax
  8013be:	48 63 c9             	movslq %ecx,%rcx
  8013c1:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013c4:	0f b6 0f             	movzbl (%rdi),%ecx
  8013c7:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013cb:	41 80 f8 09          	cmp    $0x9,%r8b
  8013cf:	77 cf                	ja     8013a0 <strtol+0x81>
      dig = *s - '0';
  8013d1:	0f be c9             	movsbl %cl,%ecx
  8013d4:	83 e9 30             	sub    $0x30,%ecx
  8013d7:	eb d9                	jmp    8013b2 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013d9:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013dd:	41 80 f8 19          	cmp    $0x19,%r8b
  8013e1:	77 0a                	ja     8013ed <strtol+0xce>
      dig = *s - 'A' + 10;
  8013e3:	44 0f be c1          	movsbl %cl,%r8d
  8013e7:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013eb:	eb c5                	jmp    8013b2 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013ed:	48 85 f6             	test   %rsi,%rsi
  8013f0:	74 03                	je     8013f5 <strtol+0xd6>
    *endptr = (char *)s;
  8013f2:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013f5:	48 89 c2             	mov    %rax,%rdx
  8013f8:	48 f7 da             	neg    %rdx
  8013fb:	45 85 c9             	test   %r9d,%r9d
  8013fe:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801402:	c3                   	retq   
  801403:	90                   	nop
