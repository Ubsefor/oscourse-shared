
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80007a:	48 b8 98 01 80 00 00 	movabs $0x800198,%rax
  800081:	00 00 00 
  800084:	ff d0                	callq  *%rax
  800086:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008b:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80008f:	48 c1 e0 05          	shl    $0x5,%rax
  800093:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80009a:	00 00 00 
  80009d:	48 01 d0             	add    %rdx,%rax
  8000a0:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000a7:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000aa:	45 85 ed             	test   %r13d,%r13d
  8000ad:	7e 0d                	jle    8000bc <libmain+0x8f>
    binaryname = argv[0];
  8000af:	49 8b 06             	mov    (%r14),%rax
  8000b2:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000b9:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000bc:	4c 89 f6             	mov    %r14,%rsi
  8000bf:	44 89 ef             	mov    %r13d,%edi
  8000c2:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000c9:	00 00 00 
  8000cc:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000ce:	48 b8 e3 00 80 00 00 	movabs $0x8000e3,%rax
  8000d5:	00 00 00 
  8000d8:	ff d0                	callq  *%rax
#endif
}
  8000da:	5b                   	pop    %rbx
  8000db:	41 5c                	pop    %r12
  8000dd:	41 5d                	pop    %r13
  8000df:	41 5e                	pop    %r14
  8000e1:	5d                   	pop    %rbp
  8000e2:	c3                   	retq   

00000000008000e3 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000e3:	55                   	push   %rbp
  8000e4:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8000ec:	48 b8 38 01 80 00 00 	movabs $0x800138,%rax
  8000f3:	00 00 00 
  8000f6:	ff d0                	callq  *%rax
}
  8000f8:	5d                   	pop    %rbp
  8000f9:	c3                   	retq   

00000000008000fa <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000fa:	55                   	push   %rbp
  8000fb:	48 89 e5             	mov    %rsp,%rbp
  8000fe:	53                   	push   %rbx
  8000ff:	48 89 fa             	mov    %rdi,%rdx
  800102:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800105:	b8 00 00 00 00       	mov    $0x0,%eax
  80010a:	48 89 c3             	mov    %rax,%rbx
  80010d:	48 89 c7             	mov    %rax,%rdi
  800110:	48 89 c6             	mov    %rax,%rsi
  800113:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800115:	5b                   	pop    %rbx
  800116:	5d                   	pop    %rbp
  800117:	c3                   	retq   

0000000000800118 <sys_cgetc>:

int
sys_cgetc(void) {
  800118:	55                   	push   %rbp
  800119:	48 89 e5             	mov    %rsp,%rbp
  80011c:	53                   	push   %rbx
  asm volatile("int %1\n"
  80011d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800122:	b8 01 00 00 00       	mov    $0x1,%eax
  800127:	48 89 ca             	mov    %rcx,%rdx
  80012a:	48 89 cb             	mov    %rcx,%rbx
  80012d:	48 89 cf             	mov    %rcx,%rdi
  800130:	48 89 ce             	mov    %rcx,%rsi
  800133:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %rbx
  800136:	5d                   	pop    %rbp
  800137:	c3                   	retq   

0000000000800138 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800138:	55                   	push   %rbp
  800139:	48 89 e5             	mov    %rsp,%rbp
  80013c:	53                   	push   %rbx
  80013d:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800141:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800144:	be 00 00 00 00       	mov    $0x0,%esi
  800149:	b8 03 00 00 00       	mov    $0x3,%eax
  80014e:	48 89 f1             	mov    %rsi,%rcx
  800151:	48 89 f3             	mov    %rsi,%rbx
  800154:	48 89 f7             	mov    %rsi,%rdi
  800157:	cd 30                	int    $0x30
  if (check && ret > 0)
  800159:	48 85 c0             	test   %rax,%rax
  80015c:	7f 07                	jg     800165 <sys_env_destroy+0x2d>
}
  80015e:	48 83 c4 08          	add    $0x8,%rsp
  800162:	5b                   	pop    %rbx
  800163:	5d                   	pop    %rbp
  800164:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800165:	49 89 c0             	mov    %rax,%r8
  800168:	b9 03 00 00 00       	mov    $0x3,%ecx
  80016d:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800174:	00 00 00 
  800177:	be 22 00 00 00       	mov    $0x22,%esi
  80017c:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800183:	00 00 00 
  800186:	b8 00 00 00 00       	mov    $0x0,%eax
  80018b:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  800192:	00 00 00 
  800195:	41 ff d1             	callq  *%r9

0000000000800198 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800198:	55                   	push   %rbp
  800199:	48 89 e5             	mov    %rsp,%rbp
  80019c:	53                   	push   %rbx
  asm volatile("int %1\n"
  80019d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a7:	48 89 ca             	mov    %rcx,%rdx
  8001aa:	48 89 cb             	mov    %rcx,%rbx
  8001ad:	48 89 cf             	mov    %rcx,%rdi
  8001b0:	48 89 ce             	mov    %rcx,%rsi
  8001b3:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001b5:	5b                   	pop    %rbx
  8001b6:	5d                   	pop    %rbp
  8001b7:	c3                   	retq   

00000000008001b8 <sys_yield>:

void
sys_yield(void) {
  8001b8:	55                   	push   %rbp
  8001b9:	48 89 e5             	mov    %rsp,%rbp
  8001bc:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c7:	48 89 ca             	mov    %rcx,%rdx
  8001ca:	48 89 cb             	mov    %rcx,%rbx
  8001cd:	48 89 cf             	mov    %rcx,%rdi
  8001d0:	48 89 ce             	mov    %rcx,%rsi
  8001d3:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d5:	5b                   	pop    %rbx
  8001d6:	5d                   	pop    %rbp
  8001d7:	c3                   	retq   

00000000008001d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001d8:	55                   	push   %rbp
  8001d9:	48 89 e5             	mov    %rsp,%rbp
  8001dc:	53                   	push   %rbx
  8001dd:	48 83 ec 08          	sub    $0x8,%rsp
  8001e1:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8001e4:	4c 63 c7             	movslq %edi,%r8
  8001e7:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8001ea:	be 00 00 00 00       	mov    $0x0,%esi
  8001ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f4:	4c 89 c2             	mov    %r8,%rdx
  8001f7:	48 89 f7             	mov    %rsi,%rdi
  8001fa:	cd 30                	int    $0x30
  if (check && ret > 0)
  8001fc:	48 85 c0             	test   %rax,%rax
  8001ff:	7f 07                	jg     800208 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  800201:	48 83 c4 08          	add    $0x8,%rsp
  800205:	5b                   	pop    %rbx
  800206:	5d                   	pop    %rbp
  800207:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800208:	49 89 c0             	mov    %rax,%r8
  80020b:	b9 04 00 00 00       	mov    $0x4,%ecx
  800210:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800217:	00 00 00 
  80021a:	be 22 00 00 00       	mov    $0x22,%esi
  80021f:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800226:	00 00 00 
  800229:	b8 00 00 00 00       	mov    $0x0,%eax
  80022e:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  800235:	00 00 00 
  800238:	41 ff d1             	callq  *%r9

000000000080023b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80023b:	55                   	push   %rbp
  80023c:	48 89 e5             	mov    %rsp,%rbp
  80023f:	53                   	push   %rbx
  800240:	48 83 ec 08          	sub    $0x8,%rsp
  800244:	41 89 f9             	mov    %edi,%r9d
  800247:	49 89 f2             	mov    %rsi,%r10
  80024a:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80024d:	4d 63 c9             	movslq %r9d,%r9
  800250:	48 63 da             	movslq %edx,%rbx
  800253:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  800256:	b8 05 00 00 00       	mov    $0x5,%eax
  80025b:	4c 89 ca             	mov    %r9,%rdx
  80025e:	4c 89 d1             	mov    %r10,%rcx
  800261:	cd 30                	int    $0x30
  if (check && ret > 0)
  800263:	48 85 c0             	test   %rax,%rax
  800266:	7f 07                	jg     80026f <sys_page_map+0x34>
}
  800268:	48 83 c4 08          	add    $0x8,%rsp
  80026c:	5b                   	pop    %rbx
  80026d:	5d                   	pop    %rbp
  80026e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80026f:	49 89 c0             	mov    %rax,%r8
  800272:	b9 05 00 00 00       	mov    $0x5,%ecx
  800277:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80027e:	00 00 00 
  800281:	be 22 00 00 00       	mov    $0x22,%esi
  800286:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  80028d:	00 00 00 
  800290:	b8 00 00 00 00       	mov    $0x0,%eax
  800295:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  80029c:	00 00 00 
  80029f:	41 ff d1             	callq  *%r9

00000000008002a2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002a2:	55                   	push   %rbp
  8002a3:	48 89 e5             	mov    %rsp,%rbp
  8002a6:	53                   	push   %rbx
  8002a7:	48 83 ec 08          	sub    $0x8,%rsp
  8002ab:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002ae:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002b1:	be 00 00 00 00       	mov    $0x0,%esi
  8002b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8002bb:	48 89 f3             	mov    %rsi,%rbx
  8002be:	48 89 f7             	mov    %rsi,%rdi
  8002c1:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002c3:	48 85 c0             	test   %rax,%rax
  8002c6:	7f 07                	jg     8002cf <sys_page_unmap+0x2d>
}
  8002c8:	48 83 c4 08          	add    $0x8,%rsp
  8002cc:	5b                   	pop    %rbx
  8002cd:	5d                   	pop    %rbp
  8002ce:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002cf:	49 89 c0             	mov    %rax,%r8
  8002d2:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002d7:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  8002de:	00 00 00 
  8002e1:	be 22 00 00 00       	mov    $0x22,%esi
  8002e6:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  8002ed:	00 00 00 
  8002f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f5:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  8002fc:	00 00 00 
  8002ff:	41 ff d1             	callq  *%r9

0000000000800302 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800302:	55                   	push   %rbp
  800303:	48 89 e5             	mov    %rsp,%rbp
  800306:	53                   	push   %rbx
  800307:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80030b:	48 63 d7             	movslq %edi,%rdx
  80030e:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  800311:	bb 00 00 00 00       	mov    $0x0,%ebx
  800316:	b8 08 00 00 00       	mov    $0x8,%eax
  80031b:	48 89 df             	mov    %rbx,%rdi
  80031e:	48 89 de             	mov    %rbx,%rsi
  800321:	cd 30                	int    $0x30
  if (check && ret > 0)
  800323:	48 85 c0             	test   %rax,%rax
  800326:	7f 07                	jg     80032f <sys_env_set_status+0x2d>
}
  800328:	48 83 c4 08          	add    $0x8,%rsp
  80032c:	5b                   	pop    %rbx
  80032d:	5d                   	pop    %rbp
  80032e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80032f:	49 89 c0             	mov    %rax,%r8
  800332:	b9 08 00 00 00       	mov    $0x8,%ecx
  800337:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80033e:	00 00 00 
  800341:	be 22 00 00 00       	mov    $0x22,%esi
  800346:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  80034d:	00 00 00 
  800350:	b8 00 00 00 00       	mov    $0x0,%eax
  800355:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  80035c:	00 00 00 
  80035f:	41 ff d1             	callq  *%r9

0000000000800362 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  800362:	55                   	push   %rbp
  800363:	48 89 e5             	mov    %rsp,%rbp
  800366:	53                   	push   %rbx
  800367:	48 83 ec 08          	sub    $0x8,%rsp
  80036b:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80036e:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800371:	be 00 00 00 00       	mov    $0x0,%esi
  800376:	b8 09 00 00 00       	mov    $0x9,%eax
  80037b:	48 89 f3             	mov    %rsi,%rbx
  80037e:	48 89 f7             	mov    %rsi,%rdi
  800381:	cd 30                	int    $0x30
  if (check && ret > 0)
  800383:	48 85 c0             	test   %rax,%rax
  800386:	7f 07                	jg     80038f <sys_env_set_pgfault_upcall+0x2d>
}
  800388:	48 83 c4 08          	add    $0x8,%rsp
  80038c:	5b                   	pop    %rbx
  80038d:	5d                   	pop    %rbp
  80038e:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80038f:	49 89 c0             	mov    %rax,%r8
  800392:	b9 09 00 00 00       	mov    $0x9,%ecx
  800397:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80039e:	00 00 00 
  8003a1:	be 22 00 00 00       	mov    $0x22,%esi
  8003a6:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  8003ad:	00 00 00 
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b5:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  8003bc:	00 00 00 
  8003bf:	41 ff d1             	callq  *%r9

00000000008003c2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003c2:	55                   	push   %rbp
  8003c3:	48 89 e5             	mov    %rsp,%rbp
  8003c6:	53                   	push   %rbx
  8003c7:	49 89 f0             	mov    %rsi,%r8
  8003ca:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003cd:	48 63 d7             	movslq %edi,%rdx
  8003d0:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003d3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003d8:	be 00 00 00 00       	mov    $0x0,%esi
  8003dd:	4c 89 c1             	mov    %r8,%rcx
  8003e0:	cd 30                	int    $0x30
}
  8003e2:	5b                   	pop    %rbx
  8003e3:	5d                   	pop    %rbp
  8003e4:	c3                   	retq   

00000000008003e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8003e5:	55                   	push   %rbp
  8003e6:	48 89 e5             	mov    %rsp,%rbp
  8003e9:	53                   	push   %rbx
  8003ea:	48 83 ec 08          	sub    $0x8,%rsp
  8003ee:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8003f1:	be 00 00 00 00       	mov    $0x0,%esi
  8003f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003fb:	48 89 f1             	mov    %rsi,%rcx
  8003fe:	48 89 f3             	mov    %rsi,%rbx
  800401:	48 89 f7             	mov    %rsi,%rdi
  800404:	cd 30                	int    $0x30
  if (check && ret > 0)
  800406:	48 85 c0             	test   %rax,%rax
  800409:	7f 07                	jg     800412 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80040b:	48 83 c4 08          	add    $0x8,%rsp
  80040f:	5b                   	pop    %rbx
  800410:	5d                   	pop    %rbp
  800411:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800412:	49 89 c0             	mov    %rax,%r8
  800415:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80041a:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800421:	00 00 00 
  800424:	be 22 00 00 00       	mov    $0x22,%esi
  800429:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800430:	00 00 00 
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	49 b9 45 04 80 00 00 	movabs $0x800445,%r9
  80043f:	00 00 00 
  800442:	41 ff d1             	callq  *%r9

0000000000800445 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800445:	55                   	push   %rbp
  800446:	48 89 e5             	mov    %rsp,%rbp
  800449:	41 56                	push   %r14
  80044b:	41 55                	push   %r13
  80044d:	41 54                	push   %r12
  80044f:	53                   	push   %rbx
  800450:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800457:	49 89 fd             	mov    %rdi,%r13
  80045a:	41 89 f6             	mov    %esi,%r14d
  80045d:	49 89 d4             	mov    %rdx,%r12
  800460:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800467:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80046e:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800475:	84 c0                	test   %al,%al
  800477:	74 26                	je     80049f <_panic+0x5a>
  800479:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800480:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800487:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80048b:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80048f:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800493:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800497:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80049b:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80049f:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004a6:	00 00 00 
  8004a9:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004b0:	00 00 00 
  8004b3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004b7:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004be:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004c5:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004cc:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004d3:	00 00 00 
  8004d6:	48 8b 18             	mov    (%rax),%rbx
  8004d9:	48 b8 98 01 80 00 00 	movabs $0x800198,%rax
  8004e0:	00 00 00 
  8004e3:	ff d0                	callq  *%rax
  8004e5:	45 89 f0             	mov    %r14d,%r8d
  8004e8:	4c 89 e9             	mov    %r13,%rcx
  8004eb:	48 89 da             	mov    %rbx,%rdx
  8004ee:	89 c6                	mov    %eax,%esi
  8004f0:	48 bf 20 14 80 00 00 	movabs $0x801420,%rdi
  8004f7:	00 00 00 
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ff:	48 bb e7 05 80 00 00 	movabs $0x8005e7,%rbx
  800506:	00 00 00 
  800509:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80050b:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800512:	4c 89 e7             	mov    %r12,%rdi
  800515:	48 b8 7f 05 80 00 00 	movabs $0x80057f,%rax
  80051c:	00 00 00 
  80051f:	ff d0                	callq  *%rax
  cprintf("\n");
  800521:	48 bf 48 14 80 00 00 	movabs $0x801448,%rdi
  800528:	00 00 00 
  80052b:	b8 00 00 00 00       	mov    $0x0,%eax
  800530:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800532:	cc                   	int3   
  while (1)
  800533:	eb fd                	jmp    800532 <_panic+0xed>

0000000000800535 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800535:	55                   	push   %rbp
  800536:	48 89 e5             	mov    %rsp,%rbp
  800539:	53                   	push   %rbx
  80053a:	48 83 ec 08          	sub    $0x8,%rsp
  80053e:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800541:	8b 06                	mov    (%rsi),%eax
  800543:	8d 50 01             	lea    0x1(%rax),%edx
  800546:	89 16                	mov    %edx,(%rsi)
  800548:	48 98                	cltq   
  80054a:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80054f:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800555:	74 0b                	je     800562 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800557:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80055b:	48 83 c4 08          	add    $0x8,%rsp
  80055f:	5b                   	pop    %rbx
  800560:	5d                   	pop    %rbp
  800561:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800562:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800566:	be ff 00 00 00       	mov    $0xff,%esi
  80056b:	48 b8 fa 00 80 00 00 	movabs $0x8000fa,%rax
  800572:	00 00 00 
  800575:	ff d0                	callq  *%rax
    b->idx = 0;
  800577:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80057d:	eb d8                	jmp    800557 <putch+0x22>

000000000080057f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80057f:	55                   	push   %rbp
  800580:	48 89 e5             	mov    %rsp,%rbp
  800583:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80058a:	48 89 fa             	mov    %rdi,%rdx
  80058d:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800590:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800597:	00 00 00 
  b.cnt = 0;
  80059a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005a1:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005a4:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005ab:	48 bf 35 05 80 00 00 	movabs $0x800535,%rdi
  8005b2:	00 00 00 
  8005b5:	48 b8 a5 07 80 00 00 	movabs $0x8007a5,%rax
  8005bc:	00 00 00 
  8005bf:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005c1:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005c8:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005cf:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005d3:	48 b8 fa 00 80 00 00 	movabs $0x8000fa,%rax
  8005da:	00 00 00 
  8005dd:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005df:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005e5:	c9                   	leaveq 
  8005e6:	c3                   	retq   

00000000008005e7 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8005e7:	55                   	push   %rbp
  8005e8:	48 89 e5             	mov    %rsp,%rbp
  8005eb:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8005f2:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8005f9:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800600:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800607:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80060e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800615:	84 c0                	test   %al,%al
  800617:	74 20                	je     800639 <cprintf+0x52>
  800619:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80061d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800621:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800625:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800629:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80062d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800631:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800635:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800639:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800640:	00 00 00 
  800643:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80064a:	00 00 00 
  80064d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800651:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800658:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80065f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800666:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80066d:	48 b8 7f 05 80 00 00 	movabs $0x80057f,%rax
  800674:	00 00 00 
  800677:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800679:	c9                   	leaveq 
  80067a:	c3                   	retq   

000000000080067b <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80067b:	55                   	push   %rbp
  80067c:	48 89 e5             	mov    %rsp,%rbp
  80067f:	41 57                	push   %r15
  800681:	41 56                	push   %r14
  800683:	41 55                	push   %r13
  800685:	41 54                	push   %r12
  800687:	53                   	push   %rbx
  800688:	48 83 ec 18          	sub    $0x18,%rsp
  80068c:	49 89 fc             	mov    %rdi,%r12
  80068f:	49 89 f5             	mov    %rsi,%r13
  800692:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800696:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800699:	41 89 cf             	mov    %ecx,%r15d
  80069c:	49 39 d7             	cmp    %rdx,%r15
  80069f:	76 45                	jbe    8006e6 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006a1:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006a5:	85 db                	test   %ebx,%ebx
  8006a7:	7e 0e                	jle    8006b7 <printnum+0x3c>
      putch(padc, putdat);
  8006a9:	4c 89 ee             	mov    %r13,%rsi
  8006ac:	44 89 f7             	mov    %r14d,%edi
  8006af:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006b2:	83 eb 01             	sub    $0x1,%ebx
  8006b5:	75 f2                	jne    8006a9 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006b7:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c0:	49 f7 f7             	div    %r15
  8006c3:	48 b8 4a 14 80 00 00 	movabs $0x80144a,%rax
  8006ca:	00 00 00 
  8006cd:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006d1:	4c 89 ee             	mov    %r13,%rsi
  8006d4:	41 ff d4             	callq  *%r12
}
  8006d7:	48 83 c4 18          	add    $0x18,%rsp
  8006db:	5b                   	pop    %rbx
  8006dc:	41 5c                	pop    %r12
  8006de:	41 5d                	pop    %r13
  8006e0:	41 5e                	pop    %r14
  8006e2:	41 5f                	pop    %r15
  8006e4:	5d                   	pop    %rbp
  8006e5:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ef:	49 f7 f7             	div    %r15
  8006f2:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8006f6:	48 89 c2             	mov    %rax,%rdx
  8006f9:	48 b8 7b 06 80 00 00 	movabs $0x80067b,%rax
  800700:	00 00 00 
  800703:	ff d0                	callq  *%rax
  800705:	eb b0                	jmp    8006b7 <printnum+0x3c>

0000000000800707 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800707:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80070b:	48 8b 06             	mov    (%rsi),%rax
  80070e:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800712:	73 0a                	jae    80071e <sprintputch+0x17>
    *b->buf++ = ch;
  800714:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800718:	48 89 16             	mov    %rdx,(%rsi)
  80071b:	40 88 38             	mov    %dil,(%rax)
}
  80071e:	c3                   	retq   

000000000080071f <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80071f:	55                   	push   %rbp
  800720:	48 89 e5             	mov    %rsp,%rbp
  800723:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80072a:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800731:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800738:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80073f:	84 c0                	test   %al,%al
  800741:	74 20                	je     800763 <printfmt+0x44>
  800743:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800747:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80074b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80074f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800753:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800757:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80075b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80075f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800763:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80076a:	00 00 00 
  80076d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800774:	00 00 00 
  800777:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80077b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800782:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800789:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800790:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800797:	48 b8 a5 07 80 00 00 	movabs $0x8007a5,%rax
  80079e:	00 00 00 
  8007a1:	ff d0                	callq  *%rax
}
  8007a3:	c9                   	leaveq 
  8007a4:	c3                   	retq   

00000000008007a5 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007a5:	55                   	push   %rbp
  8007a6:	48 89 e5             	mov    %rsp,%rbp
  8007a9:	41 57                	push   %r15
  8007ab:	41 56                	push   %r14
  8007ad:	41 55                	push   %r13
  8007af:	41 54                	push   %r12
  8007b1:	53                   	push   %rbx
  8007b2:	48 83 ec 48          	sub    $0x48,%rsp
  8007b6:	49 89 fd             	mov    %rdi,%r13
  8007b9:	49 89 f7             	mov    %rsi,%r15
  8007bc:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007bf:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007c3:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007c7:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007cb:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007cf:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007d3:	41 0f b6 3e          	movzbl (%r14),%edi
  8007d7:	83 ff 25             	cmp    $0x25,%edi
  8007da:	74 18                	je     8007f4 <vprintfmt+0x4f>
      if (ch == '\0')
  8007dc:	85 ff                	test   %edi,%edi
  8007de:	0f 84 8c 06 00 00    	je     800e70 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007e4:	4c 89 fe             	mov    %r15,%rsi
  8007e7:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007ea:	49 89 de             	mov    %rbx,%r14
  8007ed:	eb e0                	jmp    8007cf <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8007ef:	49 89 de             	mov    %rbx,%r14
  8007f2:	eb db                	jmp    8007cf <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8007f4:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8007f8:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8007fc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800803:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800809:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800812:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800818:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80081e:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800823:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800828:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80082c:	0f b6 13             	movzbl (%rbx),%edx
  80082f:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800832:	3c 55                	cmp    $0x55,%al
  800834:	0f 87 8b 05 00 00    	ja     800dc5 <vprintfmt+0x620>
  80083a:	0f b6 c0             	movzbl %al,%eax
  80083d:	49 bb 20 15 80 00 00 	movabs $0x801520,%r11
  800844:	00 00 00 
  800847:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80084b:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80084e:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800852:	eb d4                	jmp    800828 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800854:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800857:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80085b:	eb cb                	jmp    800828 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80085d:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800860:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800864:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800868:	8d 50 d0             	lea    -0x30(%rax),%edx
  80086b:	83 fa 09             	cmp    $0x9,%edx
  80086e:	77 7e                	ja     8008ee <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800870:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800874:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800878:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80087d:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800881:	8d 50 d0             	lea    -0x30(%rax),%edx
  800884:	83 fa 09             	cmp    $0x9,%edx
  800887:	76 e7                	jbe    800870 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800889:	4c 89 f3             	mov    %r14,%rbx
  80088c:	eb 19                	jmp    8008a7 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80088e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800891:	83 f8 2f             	cmp    $0x2f,%eax
  800894:	77 2a                	ja     8008c0 <vprintfmt+0x11b>
  800896:	89 c2                	mov    %eax,%edx
  800898:	4c 01 d2             	add    %r10,%rdx
  80089b:	83 c0 08             	add    $0x8,%eax
  80089e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a1:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008a4:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008a7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008ab:	0f 89 77 ff ff ff    	jns    800828 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008b1:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008b5:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008bb:	e9 68 ff ff ff       	jmpq   800828 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008c0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008cc:	eb d3                	jmp    8008a1 <vprintfmt+0xfc>
        if (width < 0)
  8008ce:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008d7:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008da:	4c 89 f3             	mov    %r14,%rbx
  8008dd:	e9 46 ff ff ff       	jmpq   800828 <vprintfmt+0x83>
  8008e2:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008e5:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8008e9:	e9 3a ff ff ff       	jmpq   800828 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008ee:	4c 89 f3             	mov    %r14,%rbx
  8008f1:	eb b4                	jmp    8008a7 <vprintfmt+0x102>
        lflag++;
  8008f3:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8008f6:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8008f9:	e9 2a ff ff ff       	jmpq   800828 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8008fe:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800901:	83 f8 2f             	cmp    $0x2f,%eax
  800904:	77 19                	ja     80091f <vprintfmt+0x17a>
  800906:	89 c2                	mov    %eax,%edx
  800908:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80090c:	83 c0 08             	add    $0x8,%eax
  80090f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800912:	4c 89 fe             	mov    %r15,%rsi
  800915:	8b 3a                	mov    (%rdx),%edi
  800917:	41 ff d5             	callq  *%r13
        break;
  80091a:	e9 b0 fe ff ff       	jmpq   8007cf <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80091f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800923:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800927:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80092b:	eb e5                	jmp    800912 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80092d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800930:	83 f8 2f             	cmp    $0x2f,%eax
  800933:	77 5b                	ja     800990 <vprintfmt+0x1eb>
  800935:	89 c2                	mov    %eax,%edx
  800937:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093b:	83 c0 08             	add    $0x8,%eax
  80093e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800941:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800943:	89 c8                	mov    %ecx,%eax
  800945:	c1 f8 1f             	sar    $0x1f,%eax
  800948:	31 c1                	xor    %eax,%ecx
  80094a:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094c:	83 f9 0b             	cmp    $0xb,%ecx
  80094f:	7f 4d                	jg     80099e <vprintfmt+0x1f9>
  800951:	48 63 c1             	movslq %ecx,%rax
  800954:	48 ba e0 17 80 00 00 	movabs $0x8017e0,%rdx
  80095b:	00 00 00 
  80095e:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800962:	48 85 c0             	test   %rax,%rax
  800965:	74 37                	je     80099e <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800967:	48 89 c1             	mov    %rax,%rcx
  80096a:	48 ba 6b 14 80 00 00 	movabs $0x80146b,%rdx
  800971:	00 00 00 
  800974:	4c 89 fe             	mov    %r15,%rsi
  800977:	4c 89 ef             	mov    %r13,%rdi
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
  80097f:	48 bb 1f 07 80 00 00 	movabs $0x80071f,%rbx
  800986:	00 00 00 
  800989:	ff d3                	callq  *%rbx
  80098b:	e9 3f fe ff ff       	jmpq   8007cf <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800990:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800994:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800998:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099c:	eb a3                	jmp    800941 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80099e:	48 ba 62 14 80 00 00 	movabs $0x801462,%rdx
  8009a5:	00 00 00 
  8009a8:	4c 89 fe             	mov    %r15,%rsi
  8009ab:	4c 89 ef             	mov    %r13,%rdi
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	48 bb 1f 07 80 00 00 	movabs $0x80071f,%rbx
  8009ba:	00 00 00 
  8009bd:	ff d3                	callq  *%rbx
  8009bf:	e9 0b fe ff ff       	jmpq   8007cf <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009c4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c7:	83 f8 2f             	cmp    $0x2f,%eax
  8009ca:	77 4b                	ja     800a17 <vprintfmt+0x272>
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d2:	83 c0 08             	add    $0x8,%eax
  8009d5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d8:	48 8b 02             	mov    (%rdx),%rax
  8009db:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009df:	48 85 c0             	test   %rax,%rax
  8009e2:	0f 84 05 04 00 00    	je     800ded <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8009e8:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009ec:	7e 06                	jle    8009f4 <vprintfmt+0x24f>
  8009ee:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009f2:	75 31                	jne    800a25 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8009f8:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8009fc:	0f b6 00             	movzbl (%rax),%eax
  8009ff:	0f be f8             	movsbl %al,%edi
  800a02:	85 ff                	test   %edi,%edi
  800a04:	0f 84 c3 00 00 00    	je     800acd <vprintfmt+0x328>
  800a0a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a0e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a12:	e9 85 00 00 00       	jmpq   800a9c <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a17:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a1b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a23:	eb b3                	jmp    8009d8 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a25:	49 63 f4             	movslq %r12d,%rsi
  800a28:	48 89 c7             	mov    %rax,%rdi
  800a2b:	48 b8 7c 0f 80 00 00 	movabs $0x800f7c,%rax
  800a32:	00 00 00 
  800a35:	ff d0                	callq  *%rax
  800a37:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a3a:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a3d:	85 f6                	test   %esi,%esi
  800a3f:	7e 22                	jle    800a63 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a41:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a45:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a49:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a4d:	4c 89 fe             	mov    %r15,%rsi
  800a50:	89 df                	mov    %ebx,%edi
  800a52:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a55:	41 83 ec 01          	sub    $0x1,%r12d
  800a59:	75 f2                	jne    800a4d <vprintfmt+0x2a8>
  800a5b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a5f:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a63:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a67:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a6b:	0f b6 00             	movzbl (%rax),%eax
  800a6e:	0f be f8             	movsbl %al,%edi
  800a71:	85 ff                	test   %edi,%edi
  800a73:	0f 84 56 fd ff ff    	je     8007cf <vprintfmt+0x2a>
  800a79:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a7d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a81:	eb 19                	jmp    800a9c <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a83:	4c 89 fe             	mov    %r15,%rsi
  800a86:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a89:	41 83 ee 01          	sub    $0x1,%r14d
  800a8d:	48 83 c3 01          	add    $0x1,%rbx
  800a91:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800a95:	0f be f8             	movsbl %al,%edi
  800a98:	85 ff                	test   %edi,%edi
  800a9a:	74 29                	je     800ac5 <vprintfmt+0x320>
  800a9c:	45 85 e4             	test   %r12d,%r12d
  800a9f:	78 06                	js     800aa7 <vprintfmt+0x302>
  800aa1:	41 83 ec 01          	sub    $0x1,%r12d
  800aa5:	78 48                	js     800aef <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800aa7:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800aab:	74 d6                	je     800a83 <vprintfmt+0x2de>
  800aad:	0f be c0             	movsbl %al,%eax
  800ab0:	83 e8 20             	sub    $0x20,%eax
  800ab3:	83 f8 5e             	cmp    $0x5e,%eax
  800ab6:	76 cb                	jbe    800a83 <vprintfmt+0x2de>
            putch('?', putdat);
  800ab8:	4c 89 fe             	mov    %r15,%rsi
  800abb:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ac0:	41 ff d5             	callq  *%r13
  800ac3:	eb c4                	jmp    800a89 <vprintfmt+0x2e4>
  800ac5:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800ac9:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800acd:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800ad0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800ad4:	0f 8e f5 fc ff ff    	jle    8007cf <vprintfmt+0x2a>
          putch(' ', putdat);
  800ada:	4c 89 fe             	mov    %r15,%rsi
  800add:	bf 20 00 00 00       	mov    $0x20,%edi
  800ae2:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800ae5:	83 eb 01             	sub    $0x1,%ebx
  800ae8:	75 f0                	jne    800ada <vprintfmt+0x335>
  800aea:	e9 e0 fc ff ff       	jmpq   8007cf <vprintfmt+0x2a>
  800aef:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800af3:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800af7:	eb d4                	jmp    800acd <vprintfmt+0x328>
  if (lflag >= 2)
  800af9:	83 f9 01             	cmp    $0x1,%ecx
  800afc:	7f 1d                	jg     800b1b <vprintfmt+0x376>
  else if (lflag)
  800afe:	85 c9                	test   %ecx,%ecx
  800b00:	74 5e                	je     800b60 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b02:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b05:	83 f8 2f             	cmp    $0x2f,%eax
  800b08:	77 48                	ja     800b52 <vprintfmt+0x3ad>
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b10:	83 c0 08             	add    $0x8,%eax
  800b13:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b16:	48 8b 1a             	mov    (%rdx),%rbx
  800b19:	eb 17                	jmp    800b32 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b1b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1e:	83 f8 2f             	cmp    $0x2f,%eax
  800b21:	77 21                	ja     800b44 <vprintfmt+0x39f>
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b29:	83 c0 08             	add    $0x8,%eax
  800b2c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2f:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b32:	48 85 db             	test   %rbx,%rbx
  800b35:	78 50                	js     800b87 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b37:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b3a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b3f:	e9 b4 01 00 00       	jmpq   800cf8 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b44:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b48:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b4c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b50:	eb dd                	jmp    800b2f <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b52:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b56:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b5a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b5e:	eb b6                	jmp    800b16 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b60:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b63:	83 f8 2f             	cmp    $0x2f,%eax
  800b66:	77 11                	ja     800b79 <vprintfmt+0x3d4>
  800b68:	89 c2                	mov    %eax,%edx
  800b6a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b6e:	83 c0 08             	add    $0x8,%eax
  800b71:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b74:	48 63 1a             	movslq (%rdx),%rbx
  800b77:	eb b9                	jmp    800b32 <vprintfmt+0x38d>
  800b79:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b7d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b81:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b85:	eb ed                	jmp    800b74 <vprintfmt+0x3cf>
          putch('-', putdat);
  800b87:	4c 89 fe             	mov    %r15,%rsi
  800b8a:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b8f:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800b92:	48 89 da             	mov    %rbx,%rdx
  800b95:	48 f7 da             	neg    %rdx
        base = 10;
  800b98:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b9d:	e9 56 01 00 00       	jmpq   800cf8 <vprintfmt+0x553>
  if (lflag >= 2)
  800ba2:	83 f9 01             	cmp    $0x1,%ecx
  800ba5:	7f 25                	jg     800bcc <vprintfmt+0x427>
  else if (lflag)
  800ba7:	85 c9                	test   %ecx,%ecx
  800ba9:	74 5e                	je     800c09 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bab:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bae:	83 f8 2f             	cmp    $0x2f,%eax
  800bb1:	77 48                	ja     800bfb <vprintfmt+0x456>
  800bb3:	89 c2                	mov    %eax,%edx
  800bb5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bb9:	83 c0 08             	add    $0x8,%eax
  800bbc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bbf:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bc2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bc7:	e9 2c 01 00 00       	jmpq   800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bcc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bcf:	83 f8 2f             	cmp    $0x2f,%eax
  800bd2:	77 19                	ja     800bed <vprintfmt+0x448>
  800bd4:	89 c2                	mov    %eax,%edx
  800bd6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bda:	83 c0 08             	add    $0x8,%eax
  800bdd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800be0:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800be3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800be8:	e9 0b 01 00 00       	jmpq   800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bed:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bf1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bf5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bf9:	eb e5                	jmp    800be0 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800bfb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c03:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c07:	eb b6                	jmp    800bbf <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c09:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c0c:	83 f8 2f             	cmp    $0x2f,%eax
  800c0f:	77 18                	ja     800c29 <vprintfmt+0x484>
  800c11:	89 c2                	mov    %eax,%edx
  800c13:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c17:	83 c0 08             	add    $0x8,%eax
  800c1a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c1d:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c1f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c24:	e9 cf 00 00 00       	jmpq   800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c29:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c2d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c31:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c35:	eb e6                	jmp    800c1d <vprintfmt+0x478>
  if (lflag >= 2)
  800c37:	83 f9 01             	cmp    $0x1,%ecx
  800c3a:	7f 25                	jg     800c61 <vprintfmt+0x4bc>
  else if (lflag)
  800c3c:	85 c9                	test   %ecx,%ecx
  800c3e:	74 5b                	je     800c9b <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c40:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c43:	83 f8 2f             	cmp    $0x2f,%eax
  800c46:	77 45                	ja     800c8d <vprintfmt+0x4e8>
  800c48:	89 c2                	mov    %eax,%edx
  800c4a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c4e:	83 c0 08             	add    $0x8,%eax
  800c51:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c54:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c57:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c5c:	e9 97 00 00 00       	jmpq   800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c61:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c64:	83 f8 2f             	cmp    $0x2f,%eax
  800c67:	77 16                	ja     800c7f <vprintfmt+0x4da>
  800c69:	89 c2                	mov    %eax,%edx
  800c6b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c6f:	83 c0 08             	add    $0x8,%eax
  800c72:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c75:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c78:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c7d:	eb 79                	jmp    800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c7f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c83:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c87:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c8b:	eb e8                	jmp    800c75 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c8d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c91:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c95:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c99:	eb b9                	jmp    800c54 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800c9b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c9e:	83 f8 2f             	cmp    $0x2f,%eax
  800ca1:	77 15                	ja     800cb8 <vprintfmt+0x513>
  800ca3:	89 c2                	mov    %eax,%edx
  800ca5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ca9:	83 c0 08             	add    $0x8,%eax
  800cac:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800caf:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cb1:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cb6:	eb 40                	jmp    800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cb8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cbc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cc0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cc4:	eb e9                	jmp    800caf <vprintfmt+0x50a>
        putch('0', putdat);
  800cc6:	4c 89 fe             	mov    %r15,%rsi
  800cc9:	bf 30 00 00 00       	mov    $0x30,%edi
  800cce:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cd1:	4c 89 fe             	mov    %r15,%rsi
  800cd4:	bf 78 00 00 00       	mov    $0x78,%edi
  800cd9:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cdc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cdf:	83 f8 2f             	cmp    $0x2f,%eax
  800ce2:	77 34                	ja     800d18 <vprintfmt+0x573>
  800ce4:	89 c2                	mov    %eax,%edx
  800ce6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cea:	83 c0 08             	add    $0x8,%eax
  800ced:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cf0:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800cf3:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800cf8:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800cfd:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d01:	4c 89 fe             	mov    %r15,%rsi
  800d04:	4c 89 ef             	mov    %r13,%rdi
  800d07:	48 b8 7b 06 80 00 00 	movabs $0x80067b,%rax
  800d0e:	00 00 00 
  800d11:	ff d0                	callq  *%rax
        break;
  800d13:	e9 b7 fa ff ff       	jmpq   8007cf <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d18:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d1c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d20:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d24:	eb ca                	jmp    800cf0 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d26:	83 f9 01             	cmp    $0x1,%ecx
  800d29:	7f 22                	jg     800d4d <vprintfmt+0x5a8>
  else if (lflag)
  800d2b:	85 c9                	test   %ecx,%ecx
  800d2d:	74 58                	je     800d87 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d2f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d32:	83 f8 2f             	cmp    $0x2f,%eax
  800d35:	77 42                	ja     800d79 <vprintfmt+0x5d4>
  800d37:	89 c2                	mov    %eax,%edx
  800d39:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d3d:	83 c0 08             	add    $0x8,%eax
  800d40:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d43:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d46:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d4b:	eb ab                	jmp    800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d4d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d50:	83 f8 2f             	cmp    $0x2f,%eax
  800d53:	77 16                	ja     800d6b <vprintfmt+0x5c6>
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d5b:	83 c0 08             	add    $0x8,%eax
  800d5e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d61:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d64:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d69:	eb 8d                	jmp    800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d6b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d6f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d73:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d77:	eb e8                	jmp    800d61 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d79:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d7d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d81:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d85:	eb bc                	jmp    800d43 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d87:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d8a:	83 f8 2f             	cmp    $0x2f,%eax
  800d8d:	77 18                	ja     800da7 <vprintfmt+0x602>
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d95:	83 c0 08             	add    $0x8,%eax
  800d98:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d9b:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800d9d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800da2:	e9 51 ff ff ff       	jmpq   800cf8 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800da7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dab:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800daf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800db3:	eb e6                	jmp    800d9b <vprintfmt+0x5f6>
        putch(ch, putdat);
  800db5:	4c 89 fe             	mov    %r15,%rsi
  800db8:	bf 25 00 00 00       	mov    $0x25,%edi
  800dbd:	41 ff d5             	callq  *%r13
        break;
  800dc0:	e9 0a fa ff ff       	jmpq   8007cf <vprintfmt+0x2a>
        putch('%', putdat);
  800dc5:	4c 89 fe             	mov    %r15,%rsi
  800dc8:	bf 25 00 00 00       	mov    $0x25,%edi
  800dcd:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800dd0:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800dd4:	0f 84 15 fa ff ff    	je     8007ef <vprintfmt+0x4a>
  800dda:	49 89 de             	mov    %rbx,%r14
  800ddd:	49 83 ee 01          	sub    $0x1,%r14
  800de1:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800de6:	75 f5                	jne    800ddd <vprintfmt+0x638>
  800de8:	e9 e2 f9 ff ff       	jmpq   8007cf <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800ded:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800df1:	74 06                	je     800df9 <vprintfmt+0x654>
  800df3:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800df7:	7f 21                	jg     800e1a <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800df9:	bf 28 00 00 00       	mov    $0x28,%edi
  800dfe:	48 bb 5c 14 80 00 00 	movabs $0x80145c,%rbx
  800e05:	00 00 00 
  800e08:	b8 28 00 00 00       	mov    $0x28,%eax
  800e0d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e11:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e15:	e9 82 fc ff ff       	jmpq   800a9c <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e1a:	49 63 f4             	movslq %r12d,%rsi
  800e1d:	48 bf 5b 14 80 00 00 	movabs $0x80145b,%rdi
  800e24:	00 00 00 
  800e27:	48 b8 7c 0f 80 00 00 	movabs $0x800f7c,%rax
  800e2e:	00 00 00 
  800e31:	ff d0                	callq  *%rax
  800e33:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e36:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e39:	48 be 5b 14 80 00 00 	movabs $0x80145b,%rsi
  800e40:	00 00 00 
  800e43:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	0f 8f f2 fb ff ff    	jg     800a41 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e4f:	48 bb 5c 14 80 00 00 	movabs $0x80145c,%rbx
  800e56:	00 00 00 
  800e59:	b8 28 00 00 00       	mov    $0x28,%eax
  800e5e:	bf 28 00 00 00       	mov    $0x28,%edi
  800e63:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e67:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e6b:	e9 2c fc ff ff       	jmpq   800a9c <vprintfmt+0x2f7>
}
  800e70:	48 83 c4 48          	add    $0x48,%rsp
  800e74:	5b                   	pop    %rbx
  800e75:	41 5c                	pop    %r12
  800e77:	41 5d                	pop    %r13
  800e79:	41 5e                	pop    %r14
  800e7b:	41 5f                	pop    %r15
  800e7d:	5d                   	pop    %rbp
  800e7e:	c3                   	retq   

0000000000800e7f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e7f:	55                   	push   %rbp
  800e80:	48 89 e5             	mov    %rsp,%rbp
  800e83:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e87:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e8b:	48 63 c6             	movslq %esi,%rax
  800e8e:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800e93:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800e97:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800e9e:	48 85 ff             	test   %rdi,%rdi
  800ea1:	74 2a                	je     800ecd <vsnprintf+0x4e>
  800ea3:	85 f6                	test   %esi,%esi
  800ea5:	7e 26                	jle    800ecd <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ea7:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800eab:	48 bf 07 07 80 00 00 	movabs $0x800707,%rdi
  800eb2:	00 00 00 
  800eb5:	48 b8 a5 07 80 00 00 	movabs $0x8007a5,%rax
  800ebc:	00 00 00 
  800ebf:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ec1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ec5:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ec8:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ecb:	c9                   	leaveq 
  800ecc:	c3                   	retq   
    return -E_INVAL;
  800ecd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed2:	eb f7                	jmp    800ecb <vsnprintf+0x4c>

0000000000800ed4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ed4:	55                   	push   %rbp
  800ed5:	48 89 e5             	mov    %rsp,%rbp
  800ed8:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800edf:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ee6:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800eed:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ef4:	84 c0                	test   %al,%al
  800ef6:	74 20                	je     800f18 <snprintf+0x44>
  800ef8:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800efc:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f00:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f04:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f08:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f0c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f10:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f14:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f18:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f1f:	00 00 00 
  800f22:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f29:	00 00 00 
  800f2c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f30:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f37:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f3e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f45:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f4c:	48 b8 7f 0e 80 00 00 	movabs $0x800e7f,%rax
  800f53:	00 00 00 
  800f56:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f58:	c9                   	leaveq 
  800f59:	c3                   	retq   

0000000000800f5a <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f5a:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f5d:	74 17                	je     800f76 <strlen+0x1c>
  800f5f:	48 89 fa             	mov    %rdi,%rdx
  800f62:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f67:	29 f9                	sub    %edi,%ecx
    n++;
  800f69:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f6c:	48 83 c2 01          	add    $0x1,%rdx
  800f70:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f73:	75 f4                	jne    800f69 <strlen+0xf>
  800f75:	c3                   	retq   
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f7b:	c3                   	retq   

0000000000800f7c <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f7c:	48 85 f6             	test   %rsi,%rsi
  800f7f:	74 24                	je     800fa5 <strnlen+0x29>
  800f81:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f84:	74 25                	je     800fab <strnlen+0x2f>
  800f86:	48 01 fe             	add    %rdi,%rsi
  800f89:	48 89 fa             	mov    %rdi,%rdx
  800f8c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f91:	29 f9                	sub    %edi,%ecx
    n++;
  800f93:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f96:	48 83 c2 01          	add    $0x1,%rdx
  800f9a:	48 39 f2             	cmp    %rsi,%rdx
  800f9d:	74 11                	je     800fb0 <strnlen+0x34>
  800f9f:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fa2:	75 ef                	jne    800f93 <strnlen+0x17>
  800fa4:	c3                   	retq   
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800faa:	c3                   	retq   
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fb0:	c3                   	retq   

0000000000800fb1 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fb1:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fbd:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fc0:	48 83 c2 01          	add    $0x1,%rdx
  800fc4:	84 c9                	test   %cl,%cl
  800fc6:	75 f1                	jne    800fb9 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fc8:	c3                   	retq   

0000000000800fc9 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fc9:	55                   	push   %rbp
  800fca:	48 89 e5             	mov    %rsp,%rbp
  800fcd:	41 54                	push   %r12
  800fcf:	53                   	push   %rbx
  800fd0:	48 89 fb             	mov    %rdi,%rbx
  800fd3:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fd6:	48 b8 5a 0f 80 00 00 	movabs $0x800f5a,%rax
  800fdd:	00 00 00 
  800fe0:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800fe2:	48 63 f8             	movslq %eax,%rdi
  800fe5:	48 01 df             	add    %rbx,%rdi
  800fe8:	4c 89 e6             	mov    %r12,%rsi
  800feb:	48 b8 b1 0f 80 00 00 	movabs $0x800fb1,%rax
  800ff2:	00 00 00 
  800ff5:	ff d0                	callq  *%rax
  return dst;
}
  800ff7:	48 89 d8             	mov    %rbx,%rax
  800ffa:	5b                   	pop    %rbx
  800ffb:	41 5c                	pop    %r12
  800ffd:	5d                   	pop    %rbp
  800ffe:	c3                   	retq   

0000000000800fff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fff:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801002:	48 85 d2             	test   %rdx,%rdx
  801005:	74 1f                	je     801026 <strncpy+0x27>
  801007:	48 01 fa             	add    %rdi,%rdx
  80100a:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  80100d:	48 83 c1 01          	add    $0x1,%rcx
  801011:	44 0f b6 06          	movzbl (%rsi),%r8d
  801015:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801019:	41 80 f8 01          	cmp    $0x1,%r8b
  80101d:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801021:	48 39 ca             	cmp    %rcx,%rdx
  801024:	75 e7                	jne    80100d <strncpy+0xe>
  }
  return ret;
}
  801026:	c3                   	retq   

0000000000801027 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801027:	48 89 f8             	mov    %rdi,%rax
  80102a:	48 85 d2             	test   %rdx,%rdx
  80102d:	74 36                	je     801065 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  80102f:	48 83 fa 01          	cmp    $0x1,%rdx
  801033:	74 2d                	je     801062 <strlcpy+0x3b>
  801035:	44 0f b6 06          	movzbl (%rsi),%r8d
  801039:	45 84 c0             	test   %r8b,%r8b
  80103c:	74 24                	je     801062 <strlcpy+0x3b>
  80103e:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801042:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801047:	48 83 c0 01          	add    $0x1,%rax
  80104b:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  80104f:	48 39 d1             	cmp    %rdx,%rcx
  801052:	74 0e                	je     801062 <strlcpy+0x3b>
  801054:	48 83 c1 01          	add    $0x1,%rcx
  801058:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  80105d:	45 84 c0             	test   %r8b,%r8b
  801060:	75 e5                	jne    801047 <strlcpy+0x20>
    *dst = '\0';
  801062:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801065:	48 29 f8             	sub    %rdi,%rax
}
  801068:	c3                   	retq   

0000000000801069 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801069:	0f b6 07             	movzbl (%rdi),%eax
  80106c:	84 c0                	test   %al,%al
  80106e:	74 17                	je     801087 <strcmp+0x1e>
  801070:	3a 06                	cmp    (%rsi),%al
  801072:	75 13                	jne    801087 <strcmp+0x1e>
    p++, q++;
  801074:	48 83 c7 01          	add    $0x1,%rdi
  801078:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  80107c:	0f b6 07             	movzbl (%rdi),%eax
  80107f:	84 c0                	test   %al,%al
  801081:	74 04                	je     801087 <strcmp+0x1e>
  801083:	3a 06                	cmp    (%rsi),%al
  801085:	74 ed                	je     801074 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  801087:	0f b6 c0             	movzbl %al,%eax
  80108a:	0f b6 16             	movzbl (%rsi),%edx
  80108d:	29 d0                	sub    %edx,%eax
}
  80108f:	c3                   	retq   

0000000000801090 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  801090:	48 85 d2             	test   %rdx,%rdx
  801093:	74 2f                	je     8010c4 <strncmp+0x34>
  801095:	0f b6 07             	movzbl (%rdi),%eax
  801098:	84 c0                	test   %al,%al
  80109a:	74 1f                	je     8010bb <strncmp+0x2b>
  80109c:	3a 06                	cmp    (%rsi),%al
  80109e:	75 1b                	jne    8010bb <strncmp+0x2b>
  8010a0:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010a3:	48 83 c7 01          	add    $0x1,%rdi
  8010a7:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010ab:	48 39 d7             	cmp    %rdx,%rdi
  8010ae:	74 1a                	je     8010ca <strncmp+0x3a>
  8010b0:	0f b6 07             	movzbl (%rdi),%eax
  8010b3:	84 c0                	test   %al,%al
  8010b5:	74 04                	je     8010bb <strncmp+0x2b>
  8010b7:	3a 06                	cmp    (%rsi),%al
  8010b9:	74 e8                	je     8010a3 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010bb:	0f b6 07             	movzbl (%rdi),%eax
  8010be:	0f b6 16             	movzbl (%rsi),%edx
  8010c1:	29 d0                	sub    %edx,%eax
}
  8010c3:	c3                   	retq   
    return 0;
  8010c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c9:	c3                   	retq   
  8010ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cf:	c3                   	retq   

00000000008010d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010d0:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010d2:	0f b6 07             	movzbl (%rdi),%eax
  8010d5:	84 c0                	test   %al,%al
  8010d7:	74 1e                	je     8010f7 <strchr+0x27>
    if (*s == c)
  8010d9:	40 38 c6             	cmp    %al,%sil
  8010dc:	74 1f                	je     8010fd <strchr+0x2d>
  for (; *s; s++)
  8010de:	48 83 c7 01          	add    $0x1,%rdi
  8010e2:	0f b6 07             	movzbl (%rdi),%eax
  8010e5:	84 c0                	test   %al,%al
  8010e7:	74 08                	je     8010f1 <strchr+0x21>
    if (*s == c)
  8010e9:	38 d0                	cmp    %dl,%al
  8010eb:	75 f1                	jne    8010de <strchr+0xe>
  for (; *s; s++)
  8010ed:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8010f0:	c3                   	retq   
  return 0;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f6:	c3                   	retq   
  8010f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fc:	c3                   	retq   
    if (*s == c)
  8010fd:	48 89 f8             	mov    %rdi,%rax
  801100:	c3                   	retq   

0000000000801101 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801101:	48 89 f8             	mov    %rdi,%rax
  801104:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801106:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801109:	40 38 f2             	cmp    %sil,%dl
  80110c:	74 13                	je     801121 <strfind+0x20>
  80110e:	84 d2                	test   %dl,%dl
  801110:	74 0f                	je     801121 <strfind+0x20>
  for (; *s; s++)
  801112:	48 83 c0 01          	add    $0x1,%rax
  801116:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801119:	38 ca                	cmp    %cl,%dl
  80111b:	74 04                	je     801121 <strfind+0x20>
  80111d:	84 d2                	test   %dl,%dl
  80111f:	75 f1                	jne    801112 <strfind+0x11>
      break;
  return (char *)s;
}
  801121:	c3                   	retq   

0000000000801122 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801122:	48 85 d2             	test   %rdx,%rdx
  801125:	74 3a                	je     801161 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801127:	48 89 f8             	mov    %rdi,%rax
  80112a:	48 09 d0             	or     %rdx,%rax
  80112d:	a8 03                	test   $0x3,%al
  80112f:	75 28                	jne    801159 <memset+0x37>
    uint32_t k = c & 0xFFU;
  801131:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801135:	89 f0                	mov    %esi,%eax
  801137:	c1 e0 08             	shl    $0x8,%eax
  80113a:	89 f1                	mov    %esi,%ecx
  80113c:	c1 e1 18             	shl    $0x18,%ecx
  80113f:	41 89 f0             	mov    %esi,%r8d
  801142:	41 c1 e0 10          	shl    $0x10,%r8d
  801146:	44 09 c1             	or     %r8d,%ecx
  801149:	09 ce                	or     %ecx,%esi
  80114b:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  80114d:	48 c1 ea 02          	shr    $0x2,%rdx
  801151:	48 89 d1             	mov    %rdx,%rcx
  801154:	fc                   	cld    
  801155:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801157:	eb 08                	jmp    801161 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801159:	89 f0                	mov    %esi,%eax
  80115b:	48 89 d1             	mov    %rdx,%rcx
  80115e:	fc                   	cld    
  80115f:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801161:	48 89 f8             	mov    %rdi,%rax
  801164:	c3                   	retq   

0000000000801165 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801165:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801168:	48 39 fe             	cmp    %rdi,%rsi
  80116b:	73 40                	jae    8011ad <memmove+0x48>
  80116d:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801171:	48 39 f9             	cmp    %rdi,%rcx
  801174:	76 37                	jbe    8011ad <memmove+0x48>
    s += n;
    d += n;
  801176:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  80117a:	48 89 fe             	mov    %rdi,%rsi
  80117d:	48 09 d6             	or     %rdx,%rsi
  801180:	48 09 ce             	or     %rcx,%rsi
  801183:	40 f6 c6 03          	test   $0x3,%sil
  801187:	75 14                	jne    80119d <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  801189:	48 83 ef 04          	sub    $0x4,%rdi
  80118d:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801191:	48 c1 ea 02          	shr    $0x2,%rdx
  801195:	48 89 d1             	mov    %rdx,%rcx
  801198:	fd                   	std    
  801199:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80119b:	eb 0e                	jmp    8011ab <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  80119d:	48 83 ef 01          	sub    $0x1,%rdi
  8011a1:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011a5:	48 89 d1             	mov    %rdx,%rcx
  8011a8:	fd                   	std    
  8011a9:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011ab:	fc                   	cld    
  8011ac:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011ad:	48 89 c1             	mov    %rax,%rcx
  8011b0:	48 09 d1             	or     %rdx,%rcx
  8011b3:	48 09 f1             	or     %rsi,%rcx
  8011b6:	f6 c1 03             	test   $0x3,%cl
  8011b9:	75 0e                	jne    8011c9 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011bb:	48 c1 ea 02          	shr    $0x2,%rdx
  8011bf:	48 89 d1             	mov    %rdx,%rcx
  8011c2:	48 89 c7             	mov    %rax,%rdi
  8011c5:	fc                   	cld    
  8011c6:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011c8:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011c9:	48 89 c7             	mov    %rax,%rdi
  8011cc:	48 89 d1             	mov    %rdx,%rcx
  8011cf:	fc                   	cld    
  8011d0:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011d2:	c3                   	retq   

00000000008011d3 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011d3:	55                   	push   %rbp
  8011d4:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011d7:	48 b8 65 11 80 00 00 	movabs $0x801165,%rax
  8011de:	00 00 00 
  8011e1:	ff d0                	callq  *%rax
}
  8011e3:	5d                   	pop    %rbp
  8011e4:	c3                   	retq   

00000000008011e5 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011e5:	55                   	push   %rbp
  8011e6:	48 89 e5             	mov    %rsp,%rbp
  8011e9:	41 57                	push   %r15
  8011eb:	41 56                	push   %r14
  8011ed:	41 55                	push   %r13
  8011ef:	41 54                	push   %r12
  8011f1:	53                   	push   %rbx
  8011f2:	48 83 ec 08          	sub    $0x8,%rsp
  8011f6:	49 89 fe             	mov    %rdi,%r14
  8011f9:	49 89 f7             	mov    %rsi,%r15
  8011fc:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  8011ff:	48 89 f7             	mov    %rsi,%rdi
  801202:	48 b8 5a 0f 80 00 00 	movabs $0x800f5a,%rax
  801209:	00 00 00 
  80120c:	ff d0                	callq  *%rax
  80120e:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801211:	4c 89 ee             	mov    %r13,%rsi
  801214:	4c 89 f7             	mov    %r14,%rdi
  801217:	48 b8 7c 0f 80 00 00 	movabs $0x800f7c,%rax
  80121e:	00 00 00 
  801221:	ff d0                	callq  *%rax
  801223:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801226:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80122a:	4d 39 e5             	cmp    %r12,%r13
  80122d:	74 26                	je     801255 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  80122f:	4c 89 e8             	mov    %r13,%rax
  801232:	4c 29 e0             	sub    %r12,%rax
  801235:	48 39 d8             	cmp    %rbx,%rax
  801238:	76 2a                	jbe    801264 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  80123a:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  80123e:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801242:	4c 89 fe             	mov    %r15,%rsi
  801245:	48 b8 d3 11 80 00 00 	movabs $0x8011d3,%rax
  80124c:	00 00 00 
  80124f:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801251:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801255:	48 83 c4 08          	add    $0x8,%rsp
  801259:	5b                   	pop    %rbx
  80125a:	41 5c                	pop    %r12
  80125c:	41 5d                	pop    %r13
  80125e:	41 5e                	pop    %r14
  801260:	41 5f                	pop    %r15
  801262:	5d                   	pop    %rbp
  801263:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801264:	49 83 ed 01          	sub    $0x1,%r13
  801268:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80126c:	4c 89 ea             	mov    %r13,%rdx
  80126f:	4c 89 fe             	mov    %r15,%rsi
  801272:	48 b8 d3 11 80 00 00 	movabs $0x8011d3,%rax
  801279:	00 00 00 
  80127c:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80127e:	4d 01 ee             	add    %r13,%r14
  801281:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801286:	eb c9                	jmp    801251 <strlcat+0x6c>

0000000000801288 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801288:	48 85 d2             	test   %rdx,%rdx
  80128b:	74 3a                	je     8012c7 <memcmp+0x3f>
    if (*s1 != *s2)
  80128d:	0f b6 0f             	movzbl (%rdi),%ecx
  801290:	44 0f b6 06          	movzbl (%rsi),%r8d
  801294:	44 38 c1             	cmp    %r8b,%cl
  801297:	75 1d                	jne    8012b6 <memcmp+0x2e>
  801299:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80129e:	48 39 d0             	cmp    %rdx,%rax
  8012a1:	74 1e                	je     8012c1 <memcmp+0x39>
    if (*s1 != *s2)
  8012a3:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012a7:	48 83 c0 01          	add    $0x1,%rax
  8012ab:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012b1:	44 38 c1             	cmp    %r8b,%cl
  8012b4:	74 e8                	je     80129e <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012b6:	0f b6 c1             	movzbl %cl,%eax
  8012b9:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012bd:	44 29 c0             	sub    %r8d,%eax
  8012c0:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c6:	c3                   	retq   
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cc:	c3                   	retq   

00000000008012cd <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012cd:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012d1:	48 39 c7             	cmp    %rax,%rdi
  8012d4:	73 19                	jae    8012ef <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012d6:	89 f2                	mov    %esi,%edx
  8012d8:	40 38 37             	cmp    %sil,(%rdi)
  8012db:	74 16                	je     8012f3 <memfind+0x26>
  for (; s < ends; s++)
  8012dd:	48 83 c7 01          	add    $0x1,%rdi
  8012e1:	48 39 f8             	cmp    %rdi,%rax
  8012e4:	74 08                	je     8012ee <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012e6:	38 17                	cmp    %dl,(%rdi)
  8012e8:	75 f3                	jne    8012dd <memfind+0x10>
  for (; s < ends; s++)
  8012ea:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8012ed:	c3                   	retq   
  8012ee:	c3                   	retq   
  for (; s < ends; s++)
  8012ef:	48 89 f8             	mov    %rdi,%rax
  8012f2:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8012f3:	48 89 f8             	mov    %rdi,%rax
  8012f6:	c3                   	retq   

00000000008012f7 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8012f7:	0f b6 07             	movzbl (%rdi),%eax
  8012fa:	3c 20                	cmp    $0x20,%al
  8012fc:	74 04                	je     801302 <strtol+0xb>
  8012fe:	3c 09                	cmp    $0x9,%al
  801300:	75 0f                	jne    801311 <strtol+0x1a>
    s++;
  801302:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801306:	0f b6 07             	movzbl (%rdi),%eax
  801309:	3c 20                	cmp    $0x20,%al
  80130b:	74 f5                	je     801302 <strtol+0xb>
  80130d:	3c 09                	cmp    $0x9,%al
  80130f:	74 f1                	je     801302 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801311:	3c 2b                	cmp    $0x2b,%al
  801313:	74 2b                	je     801340 <strtol+0x49>
  int neg  = 0;
  801315:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80131b:	3c 2d                	cmp    $0x2d,%al
  80131d:	74 2d                	je     80134c <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80131f:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801325:	75 0f                	jne    801336 <strtol+0x3f>
  801327:	80 3f 30             	cmpb   $0x30,(%rdi)
  80132a:	74 2c                	je     801358 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80132c:	85 d2                	test   %edx,%edx
  80132e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801333:	0f 44 d0             	cmove  %eax,%edx
  801336:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80133b:	4c 63 d2             	movslq %edx,%r10
  80133e:	eb 5c                	jmp    80139c <strtol+0xa5>
    s++;
  801340:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801344:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80134a:	eb d3                	jmp    80131f <strtol+0x28>
    s++, neg = 1;
  80134c:	48 83 c7 01          	add    $0x1,%rdi
  801350:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801356:	eb c7                	jmp    80131f <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801358:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80135c:	74 0f                	je     80136d <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80135e:	85 d2                	test   %edx,%edx
  801360:	75 d4                	jne    801336 <strtol+0x3f>
    s++, base = 8;
  801362:	48 83 c7 01          	add    $0x1,%rdi
  801366:	ba 08 00 00 00       	mov    $0x8,%edx
  80136b:	eb c9                	jmp    801336 <strtol+0x3f>
    s += 2, base = 16;
  80136d:	48 83 c7 02          	add    $0x2,%rdi
  801371:	ba 10 00 00 00       	mov    $0x10,%edx
  801376:	eb be                	jmp    801336 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801378:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80137c:	41 80 f8 19          	cmp    $0x19,%r8b
  801380:	77 2f                	ja     8013b1 <strtol+0xba>
      dig = *s - 'a' + 10;
  801382:	44 0f be c1          	movsbl %cl,%r8d
  801386:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80138a:	39 d1                	cmp    %edx,%ecx
  80138c:	7d 37                	jge    8013c5 <strtol+0xce>
    s++, val = (val * base) + dig;
  80138e:	48 83 c7 01          	add    $0x1,%rdi
  801392:	49 0f af c2          	imul   %r10,%rax
  801396:	48 63 c9             	movslq %ecx,%rcx
  801399:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80139c:	0f b6 0f             	movzbl (%rdi),%ecx
  80139f:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013a3:	41 80 f8 09          	cmp    $0x9,%r8b
  8013a7:	77 cf                	ja     801378 <strtol+0x81>
      dig = *s - '0';
  8013a9:	0f be c9             	movsbl %cl,%ecx
  8013ac:	83 e9 30             	sub    $0x30,%ecx
  8013af:	eb d9                	jmp    80138a <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013b1:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013b5:	41 80 f8 19          	cmp    $0x19,%r8b
  8013b9:	77 0a                	ja     8013c5 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013bb:	44 0f be c1          	movsbl %cl,%r8d
  8013bf:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013c3:	eb c5                	jmp    80138a <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013c5:	48 85 f6             	test   %rsi,%rsi
  8013c8:	74 03                	je     8013cd <strtol+0xd6>
    *endptr = (char *)s;
  8013ca:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013cd:	48 89 c2             	mov    %rax,%rdx
  8013d0:	48 f7 da             	neg    %rdx
  8013d3:	45 85 c9             	test   %r9d,%r9d
  8013d6:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013da:	c3                   	retq   
  8013db:	90                   	nop
