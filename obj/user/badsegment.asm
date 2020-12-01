
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80007e:	48 b8 9c 01 80 00 00 	movabs $0x80019c,%rax
  800085:	00 00 00 
  800088:	ff d0                	callq  *%rax
  80008a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008f:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800093:	48 c1 e0 05          	shl    $0x5,%rax
  800097:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80009e:	00 00 00 
  8000a1:	48 01 d0             	add    %rdx,%rax
  8000a4:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000ab:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000ae:	45 85 ed             	test   %r13d,%r13d
  8000b1:	7e 0d                	jle    8000c0 <libmain+0x8f>
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
  800171:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800178:	00 00 00 
  80017b:	be 22 00 00 00       	mov    $0x22,%esi
  800180:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800187:	00 00 00 
  80018a:	b8 00 00 00 00       	mov    $0x0,%eax
  80018f:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
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

00000000008001bc <sys_yield>:

void
sys_yield(void) {
  8001bc:	55                   	push   %rbp
  8001bd:	48 89 e5             	mov    %rsp,%rbp
  8001c0:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001cb:	48 89 ca             	mov    %rcx,%rdx
  8001ce:	48 89 cb             	mov    %rcx,%rbx
  8001d1:	48 89 cf             	mov    %rcx,%rdi
  8001d4:	48 89 ce             	mov    %rcx,%rsi
  8001d7:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d9:	5b                   	pop    %rbx
  8001da:	5d                   	pop    %rbp
  8001db:	c3                   	retq   

00000000008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001dc:	55                   	push   %rbp
  8001dd:	48 89 e5             	mov    %rsp,%rbp
  8001e0:	53                   	push   %rbx
  8001e1:	48 83 ec 08          	sub    $0x8,%rsp
  8001e5:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8001e8:	4c 63 c7             	movslq %edi,%r8
  8001eb:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8001ee:	be 00 00 00 00       	mov    $0x0,%esi
  8001f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f8:	4c 89 c2             	mov    %r8,%rdx
  8001fb:	48 89 f7             	mov    %rsi,%rdi
  8001fe:	cd 30                	int    $0x30
  if (check && ret > 0)
  800200:	48 85 c0             	test   %rax,%rax
  800203:	7f 07                	jg     80020c <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  800205:	48 83 c4 08          	add    $0x8,%rsp
  800209:	5b                   	pop    %rbx
  80020a:	5d                   	pop    %rbp
  80020b:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80020c:	49 89 c0             	mov    %rax,%r8
  80020f:	b9 04 00 00 00       	mov    $0x4,%ecx
  800214:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80021b:	00 00 00 
  80021e:	be 22 00 00 00       	mov    $0x22,%esi
  800223:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  80022a:	00 00 00 
  80022d:	b8 00 00 00 00       	mov    $0x0,%eax
  800232:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
  800239:	00 00 00 
  80023c:	41 ff d1             	callq  *%r9

000000000080023f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80023f:	55                   	push   %rbp
  800240:	48 89 e5             	mov    %rsp,%rbp
  800243:	53                   	push   %rbx
  800244:	48 83 ec 08          	sub    $0x8,%rsp
  800248:	41 89 f9             	mov    %edi,%r9d
  80024b:	49 89 f2             	mov    %rsi,%r10
  80024e:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  800251:	4d 63 c9             	movslq %r9d,%r9
  800254:	48 63 da             	movslq %edx,%rbx
  800257:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80025a:	b8 05 00 00 00       	mov    $0x5,%eax
  80025f:	4c 89 ca             	mov    %r9,%rdx
  800262:	4c 89 d1             	mov    %r10,%rcx
  800265:	cd 30                	int    $0x30
  if (check && ret > 0)
  800267:	48 85 c0             	test   %rax,%rax
  80026a:	7f 07                	jg     800273 <sys_page_map+0x34>
}
  80026c:	48 83 c4 08          	add    $0x8,%rsp
  800270:	5b                   	pop    %rbx
  800271:	5d                   	pop    %rbp
  800272:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800273:	49 89 c0             	mov    %rax,%r8
  800276:	b9 05 00 00 00       	mov    $0x5,%ecx
  80027b:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800282:	00 00 00 
  800285:	be 22 00 00 00       	mov    $0x22,%esi
  80028a:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800291:	00 00 00 
  800294:	b8 00 00 00 00       	mov    $0x0,%eax
  800299:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
  8002a0:	00 00 00 
  8002a3:	41 ff d1             	callq  *%r9

00000000008002a6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002a6:	55                   	push   %rbp
  8002a7:	48 89 e5             	mov    %rsp,%rbp
  8002aa:	53                   	push   %rbx
  8002ab:	48 83 ec 08          	sub    $0x8,%rsp
  8002af:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002b2:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002b5:	be 00 00 00 00       	mov    $0x0,%esi
  8002ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8002bf:	48 89 f3             	mov    %rsi,%rbx
  8002c2:	48 89 f7             	mov    %rsi,%rdi
  8002c5:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002c7:	48 85 c0             	test   %rax,%rax
  8002ca:	7f 07                	jg     8002d3 <sys_page_unmap+0x2d>
}
  8002cc:	48 83 c4 08          	add    $0x8,%rsp
  8002d0:	5b                   	pop    %rbx
  8002d1:	5d                   	pop    %rbp
  8002d2:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002d3:	49 89 c0             	mov    %rax,%r8
  8002d6:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002db:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  8002e2:	00 00 00 
  8002e5:	be 22 00 00 00       	mov    $0x22,%esi
  8002ea:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  8002f1:	00 00 00 
  8002f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f9:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
  800300:	00 00 00 
  800303:	41 ff d1             	callq  *%r9

0000000000800306 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800306:	55                   	push   %rbp
  800307:	48 89 e5             	mov    %rsp,%rbp
  80030a:	53                   	push   %rbx
  80030b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80030f:	48 63 d7             	movslq %edi,%rdx
  800312:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  800315:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031a:	b8 08 00 00 00       	mov    $0x8,%eax
  80031f:	48 89 df             	mov    %rbx,%rdi
  800322:	48 89 de             	mov    %rbx,%rsi
  800325:	cd 30                	int    $0x30
  if (check && ret > 0)
  800327:	48 85 c0             	test   %rax,%rax
  80032a:	7f 07                	jg     800333 <sys_env_set_status+0x2d>
}
  80032c:	48 83 c4 08          	add    $0x8,%rsp
  800330:	5b                   	pop    %rbx
  800331:	5d                   	pop    %rbp
  800332:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800333:	49 89 c0             	mov    %rax,%r8
  800336:	b9 08 00 00 00       	mov    $0x8,%ecx
  80033b:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800342:	00 00 00 
  800345:	be 22 00 00 00       	mov    $0x22,%esi
  80034a:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800351:	00 00 00 
  800354:	b8 00 00 00 00       	mov    $0x0,%eax
  800359:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
  800360:	00 00 00 
  800363:	41 ff d1             	callq  *%r9

0000000000800366 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  800366:	55                   	push   %rbp
  800367:	48 89 e5             	mov    %rsp,%rbp
  80036a:	53                   	push   %rbx
  80036b:	48 83 ec 08          	sub    $0x8,%rsp
  80036f:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  800372:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800375:	be 00 00 00 00       	mov    $0x0,%esi
  80037a:	b8 09 00 00 00       	mov    $0x9,%eax
  80037f:	48 89 f3             	mov    %rsi,%rbx
  800382:	48 89 f7             	mov    %rsi,%rdi
  800385:	cd 30                	int    $0x30
  if (check && ret > 0)
  800387:	48 85 c0             	test   %rax,%rax
  80038a:	7f 07                	jg     800393 <sys_env_set_pgfault_upcall+0x2d>
}
  80038c:	48 83 c4 08          	add    $0x8,%rsp
  800390:	5b                   	pop    %rbx
  800391:	5d                   	pop    %rbp
  800392:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800393:	49 89 c0             	mov    %rax,%r8
  800396:	b9 09 00 00 00       	mov    $0x9,%ecx
  80039b:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  8003a2:	00 00 00 
  8003a5:	be 22 00 00 00       	mov    $0x22,%esi
  8003aa:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  8003b1:	00 00 00 
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b9:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
  8003c0:	00 00 00 
  8003c3:	41 ff d1             	callq  *%r9

00000000008003c6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003c6:	55                   	push   %rbp
  8003c7:	48 89 e5             	mov    %rsp,%rbp
  8003ca:	53                   	push   %rbx
  8003cb:	49 89 f0             	mov    %rsi,%r8
  8003ce:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003d1:	48 63 d7             	movslq %edi,%rdx
  8003d4:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003d7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003dc:	be 00 00 00 00       	mov    $0x0,%esi
  8003e1:	4c 89 c1             	mov    %r8,%rcx
  8003e4:	cd 30                	int    $0x30
}
  8003e6:	5b                   	pop    %rbx
  8003e7:	5d                   	pop    %rbp
  8003e8:	c3                   	retq   

00000000008003e9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8003e9:	55                   	push   %rbp
  8003ea:	48 89 e5             	mov    %rsp,%rbp
  8003ed:	53                   	push   %rbx
  8003ee:	48 83 ec 08          	sub    $0x8,%rsp
  8003f2:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8003f5:	be 00 00 00 00       	mov    $0x0,%esi
  8003fa:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003ff:	48 89 f1             	mov    %rsi,%rcx
  800402:	48 89 f3             	mov    %rsi,%rbx
  800405:	48 89 f7             	mov    %rsi,%rdi
  800408:	cd 30                	int    $0x30
  if (check && ret > 0)
  80040a:	48 85 c0             	test   %rax,%rax
  80040d:	7f 07                	jg     800416 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80040f:	48 83 c4 08          	add    $0x8,%rsp
  800413:	5b                   	pop    %rbx
  800414:	5d                   	pop    %rbp
  800415:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800416:	49 89 c0             	mov    %rax,%r8
  800419:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80041e:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800425:	00 00 00 
  800428:	be 22 00 00 00       	mov    $0x22,%esi
  80042d:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800434:	00 00 00 
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	49 b9 49 04 80 00 00 	movabs $0x800449,%r9
  800443:	00 00 00 
  800446:	41 ff d1             	callq  *%r9

0000000000800449 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800449:	55                   	push   %rbp
  80044a:	48 89 e5             	mov    %rsp,%rbp
  80044d:	41 56                	push   %r14
  80044f:	41 55                	push   %r13
  800451:	41 54                	push   %r12
  800453:	53                   	push   %rbx
  800454:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80045b:	49 89 fd             	mov    %rdi,%r13
  80045e:	41 89 f6             	mov    %esi,%r14d
  800461:	49 89 d4             	mov    %rdx,%r12
  800464:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80046b:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800472:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800479:	84 c0                	test   %al,%al
  80047b:	74 26                	je     8004a3 <_panic+0x5a>
  80047d:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800484:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80048b:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80048f:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800493:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800497:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80049b:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80049f:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004a3:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004aa:	00 00 00 
  8004ad:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004b4:	00 00 00 
  8004b7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004bb:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004c2:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004c9:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004d0:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004d7:	00 00 00 
  8004da:	48 8b 18             	mov    (%rax),%rbx
  8004dd:	48 b8 9c 01 80 00 00 	movabs $0x80019c,%rax
  8004e4:	00 00 00 
  8004e7:	ff d0                	callq  *%rax
  8004e9:	45 89 f0             	mov    %r14d,%r8d
  8004ec:	4c 89 e9             	mov    %r13,%rcx
  8004ef:	48 89 da             	mov    %rbx,%rdx
  8004f2:	89 c6                	mov    %eax,%esi
  8004f4:	48 bf 20 14 80 00 00 	movabs $0x801420,%rdi
  8004fb:	00 00 00 
  8004fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800503:	48 bb eb 05 80 00 00 	movabs $0x8005eb,%rbx
  80050a:	00 00 00 
  80050d:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80050f:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800516:	4c 89 e7             	mov    %r12,%rdi
  800519:	48 b8 83 05 80 00 00 	movabs $0x800583,%rax
  800520:	00 00 00 
  800523:	ff d0                	callq  *%rax
  cprintf("\n");
  800525:	48 bf 48 14 80 00 00 	movabs $0x801448,%rdi
  80052c:	00 00 00 
  80052f:	b8 00 00 00 00       	mov    $0x0,%eax
  800534:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800536:	cc                   	int3   
  while (1)
  800537:	eb fd                	jmp    800536 <_panic+0xed>

0000000000800539 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800539:	55                   	push   %rbp
  80053a:	48 89 e5             	mov    %rsp,%rbp
  80053d:	53                   	push   %rbx
  80053e:	48 83 ec 08          	sub    $0x8,%rsp
  800542:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800545:	8b 06                	mov    (%rsi),%eax
  800547:	8d 50 01             	lea    0x1(%rax),%edx
  80054a:	89 16                	mov    %edx,(%rsi)
  80054c:	48 98                	cltq   
  80054e:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800553:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800559:	74 0b                	je     800566 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80055b:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80055f:	48 83 c4 08          	add    $0x8,%rsp
  800563:	5b                   	pop    %rbx
  800564:	5d                   	pop    %rbp
  800565:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800566:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80056a:	be ff 00 00 00       	mov    $0xff,%esi
  80056f:	48 b8 fe 00 80 00 00 	movabs $0x8000fe,%rax
  800576:	00 00 00 
  800579:	ff d0                	callq  *%rax
    b->idx = 0;
  80057b:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800581:	eb d8                	jmp    80055b <putch+0x22>

0000000000800583 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800583:	55                   	push   %rbp
  800584:	48 89 e5             	mov    %rsp,%rbp
  800587:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80058e:	48 89 fa             	mov    %rdi,%rdx
  800591:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800594:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80059b:	00 00 00 
  b.cnt = 0;
  80059e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005a5:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005a8:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005af:	48 bf 39 05 80 00 00 	movabs $0x800539,%rdi
  8005b6:	00 00 00 
  8005b9:	48 b8 a9 07 80 00 00 	movabs $0x8007a9,%rax
  8005c0:	00 00 00 
  8005c3:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005c5:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005cc:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005d3:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005d7:	48 b8 fe 00 80 00 00 	movabs $0x8000fe,%rax
  8005de:	00 00 00 
  8005e1:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005e9:	c9                   	leaveq 
  8005ea:	c3                   	retq   

00000000008005eb <cprintf>:

int
cprintf(const char *fmt, ...) {
  8005eb:	55                   	push   %rbp
  8005ec:	48 89 e5             	mov    %rsp,%rbp
  8005ef:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8005f6:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8005fd:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800604:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80060b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800612:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800619:	84 c0                	test   %al,%al
  80061b:	74 20                	je     80063d <cprintf+0x52>
  80061d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800621:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800625:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800629:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80062d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800631:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800635:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800639:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80063d:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800644:	00 00 00 
  800647:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80064e:	00 00 00 
  800651:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800655:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80065c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800663:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80066a:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800671:	48 b8 83 05 80 00 00 	movabs $0x800583,%rax
  800678:	00 00 00 
  80067b:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80067d:	c9                   	leaveq 
  80067e:	c3                   	retq   

000000000080067f <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80067f:	55                   	push   %rbp
  800680:	48 89 e5             	mov    %rsp,%rbp
  800683:	41 57                	push   %r15
  800685:	41 56                	push   %r14
  800687:	41 55                	push   %r13
  800689:	41 54                	push   %r12
  80068b:	53                   	push   %rbx
  80068c:	48 83 ec 18          	sub    $0x18,%rsp
  800690:	49 89 fc             	mov    %rdi,%r12
  800693:	49 89 f5             	mov    %rsi,%r13
  800696:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80069a:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80069d:	41 89 cf             	mov    %ecx,%r15d
  8006a0:	49 39 d7             	cmp    %rdx,%r15
  8006a3:	76 45                	jbe    8006ea <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006a5:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006a9:	85 db                	test   %ebx,%ebx
  8006ab:	7e 0e                	jle    8006bb <printnum+0x3c>
      putch(padc, putdat);
  8006ad:	4c 89 ee             	mov    %r13,%rsi
  8006b0:	44 89 f7             	mov    %r14d,%edi
  8006b3:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006b6:	83 eb 01             	sub    $0x1,%ebx
  8006b9:	75 f2                	jne    8006ad <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006bb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c4:	49 f7 f7             	div    %r15
  8006c7:	48 b8 4a 14 80 00 00 	movabs $0x80144a,%rax
  8006ce:	00 00 00 
  8006d1:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006d5:	4c 89 ee             	mov    %r13,%rsi
  8006d8:	41 ff d4             	callq  *%r12
}
  8006db:	48 83 c4 18          	add    $0x18,%rsp
  8006df:	5b                   	pop    %rbx
  8006e0:	41 5c                	pop    %r12
  8006e2:	41 5d                	pop    %r13
  8006e4:	41 5e                	pop    %r14
  8006e6:	41 5f                	pop    %r15
  8006e8:	5d                   	pop    %rbp
  8006e9:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ea:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f3:	49 f7 f7             	div    %r15
  8006f6:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8006fa:	48 89 c2             	mov    %rax,%rdx
  8006fd:	48 b8 7f 06 80 00 00 	movabs $0x80067f,%rax
  800704:	00 00 00 
  800707:	ff d0                	callq  *%rax
  800709:	eb b0                	jmp    8006bb <printnum+0x3c>

000000000080070b <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80070b:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80070f:	48 8b 06             	mov    (%rsi),%rax
  800712:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800716:	73 0a                	jae    800722 <sprintputch+0x17>
    *b->buf++ = ch;
  800718:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80071c:	48 89 16             	mov    %rdx,(%rsi)
  80071f:	40 88 38             	mov    %dil,(%rax)
}
  800722:	c3                   	retq   

0000000000800723 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800723:	55                   	push   %rbp
  800724:	48 89 e5             	mov    %rsp,%rbp
  800727:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80072e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800735:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80073c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800743:	84 c0                	test   %al,%al
  800745:	74 20                	je     800767 <printfmt+0x44>
  800747:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80074b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80074f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800753:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800757:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80075b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80075f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800763:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800767:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80076e:	00 00 00 
  800771:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800778:	00 00 00 
  80077b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80077f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800786:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80078d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800794:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80079b:	48 b8 a9 07 80 00 00 	movabs $0x8007a9,%rax
  8007a2:	00 00 00 
  8007a5:	ff d0                	callq  *%rax
}
  8007a7:	c9                   	leaveq 
  8007a8:	c3                   	retq   

00000000008007a9 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007a9:	55                   	push   %rbp
  8007aa:	48 89 e5             	mov    %rsp,%rbp
  8007ad:	41 57                	push   %r15
  8007af:	41 56                	push   %r14
  8007b1:	41 55                	push   %r13
  8007b3:	41 54                	push   %r12
  8007b5:	53                   	push   %rbx
  8007b6:	48 83 ec 48          	sub    $0x48,%rsp
  8007ba:	49 89 fd             	mov    %rdi,%r13
  8007bd:	49 89 f7             	mov    %rsi,%r15
  8007c0:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007c3:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007c7:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007cb:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007cf:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007d3:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007d7:	41 0f b6 3e          	movzbl (%r14),%edi
  8007db:	83 ff 25             	cmp    $0x25,%edi
  8007de:	74 18                	je     8007f8 <vprintfmt+0x4f>
      if (ch == '\0')
  8007e0:	85 ff                	test   %edi,%edi
  8007e2:	0f 84 8c 06 00 00    	je     800e74 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007e8:	4c 89 fe             	mov    %r15,%rsi
  8007eb:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007ee:	49 89 de             	mov    %rbx,%r14
  8007f1:	eb e0                	jmp    8007d3 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8007f3:	49 89 de             	mov    %rbx,%r14
  8007f6:	eb db                	jmp    8007d3 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8007f8:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8007fc:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800800:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800807:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80080d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800811:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800816:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80081c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800822:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800827:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80082c:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800830:	0f b6 13             	movzbl (%rbx),%edx
  800833:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800836:	3c 55                	cmp    $0x55,%al
  800838:	0f 87 8b 05 00 00    	ja     800dc9 <vprintfmt+0x620>
  80083e:	0f b6 c0             	movzbl %al,%eax
  800841:	49 bb 20 15 80 00 00 	movabs $0x801520,%r11
  800848:	00 00 00 
  80084b:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80084f:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800852:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800856:	eb d4                	jmp    80082c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800858:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80085b:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80085f:	eb cb                	jmp    80082c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800861:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800864:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800868:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80086c:	8d 50 d0             	lea    -0x30(%rax),%edx
  80086f:	83 fa 09             	cmp    $0x9,%edx
  800872:	77 7e                	ja     8008f2 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800874:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800878:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80087c:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800881:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800885:	8d 50 d0             	lea    -0x30(%rax),%edx
  800888:	83 fa 09             	cmp    $0x9,%edx
  80088b:	76 e7                	jbe    800874 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80088d:	4c 89 f3             	mov    %r14,%rbx
  800890:	eb 19                	jmp    8008ab <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800892:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800895:	83 f8 2f             	cmp    $0x2f,%eax
  800898:	77 2a                	ja     8008c4 <vprintfmt+0x11b>
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	4c 01 d2             	add    %r10,%rdx
  80089f:	83 c0 08             	add    $0x8,%eax
  8008a2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a5:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008a8:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008ab:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008af:	0f 89 77 ff ff ff    	jns    80082c <vprintfmt+0x83>
          width = precision, precision = -1;
  8008b5:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008b9:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008bf:	e9 68 ff ff ff       	jmpq   80082c <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008c4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008cc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d0:	eb d3                	jmp    8008a5 <vprintfmt+0xfc>
        if (width < 0)
  8008d2:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008db:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008de:	4c 89 f3             	mov    %r14,%rbx
  8008e1:	e9 46 ff ff ff       	jmpq   80082c <vprintfmt+0x83>
  8008e6:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008e9:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8008ed:	e9 3a ff ff ff       	jmpq   80082c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008f2:	4c 89 f3             	mov    %r14,%rbx
  8008f5:	eb b4                	jmp    8008ab <vprintfmt+0x102>
        lflag++;
  8008f7:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8008fa:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8008fd:	e9 2a ff ff ff       	jmpq   80082c <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800902:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800905:	83 f8 2f             	cmp    $0x2f,%eax
  800908:	77 19                	ja     800923 <vprintfmt+0x17a>
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800910:	83 c0 08             	add    $0x8,%eax
  800913:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800916:	4c 89 fe             	mov    %r15,%rsi
  800919:	8b 3a                	mov    (%rdx),%edi
  80091b:	41 ff d5             	callq  *%r13
        break;
  80091e:	e9 b0 fe ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800923:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800927:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80092b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80092f:	eb e5                	jmp    800916 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800931:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800934:	83 f8 2f             	cmp    $0x2f,%eax
  800937:	77 5b                	ja     800994 <vprintfmt+0x1eb>
  800939:	89 c2                	mov    %eax,%edx
  80093b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093f:	83 c0 08             	add    $0x8,%eax
  800942:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800945:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800947:	89 c8                	mov    %ecx,%eax
  800949:	c1 f8 1f             	sar    $0x1f,%eax
  80094c:	31 c1                	xor    %eax,%ecx
  80094e:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800950:	83 f9 0b             	cmp    $0xb,%ecx
  800953:	7f 4d                	jg     8009a2 <vprintfmt+0x1f9>
  800955:	48 63 c1             	movslq %ecx,%rax
  800958:	48 ba e0 17 80 00 00 	movabs $0x8017e0,%rdx
  80095f:	00 00 00 
  800962:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800966:	48 85 c0             	test   %rax,%rax
  800969:	74 37                	je     8009a2 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80096b:	48 89 c1             	mov    %rax,%rcx
  80096e:	48 ba 6b 14 80 00 00 	movabs $0x80146b,%rdx
  800975:	00 00 00 
  800978:	4c 89 fe             	mov    %r15,%rsi
  80097b:	4c 89 ef             	mov    %r13,%rdi
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
  800983:	48 bb 23 07 80 00 00 	movabs $0x800723,%rbx
  80098a:	00 00 00 
  80098d:	ff d3                	callq  *%rbx
  80098f:	e9 3f fe ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800994:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800998:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a0:	eb a3                	jmp    800945 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009a2:	48 ba 62 14 80 00 00 	movabs $0x801462,%rdx
  8009a9:	00 00 00 
  8009ac:	4c 89 fe             	mov    %r15,%rsi
  8009af:	4c 89 ef             	mov    %r13,%rdi
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	48 bb 23 07 80 00 00 	movabs $0x800723,%rbx
  8009be:	00 00 00 
  8009c1:	ff d3                	callq  *%rbx
  8009c3:	e9 0b fe ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009cb:	83 f8 2f             	cmp    $0x2f,%eax
  8009ce:	77 4b                	ja     800a1b <vprintfmt+0x272>
  8009d0:	89 c2                	mov    %eax,%edx
  8009d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d6:	83 c0 08             	add    $0x8,%eax
  8009d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009dc:	48 8b 02             	mov    (%rdx),%rax
  8009df:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009e3:	48 85 c0             	test   %rax,%rax
  8009e6:	0f 84 05 04 00 00    	je     800df1 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8009ec:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009f0:	7e 06                	jle    8009f8 <vprintfmt+0x24f>
  8009f2:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009f6:	75 31                	jne    800a29 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8009fc:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a00:	0f b6 00             	movzbl (%rax),%eax
  800a03:	0f be f8             	movsbl %al,%edi
  800a06:	85 ff                	test   %edi,%edi
  800a08:	0f 84 c3 00 00 00    	je     800ad1 <vprintfmt+0x328>
  800a0e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a12:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a16:	e9 85 00 00 00       	jmpq   800aa0 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a1b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a1f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a23:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a27:	eb b3                	jmp    8009dc <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a29:	49 63 f4             	movslq %r12d,%rsi
  800a2c:	48 89 c7             	mov    %rax,%rdi
  800a2f:	48 b8 80 0f 80 00 00 	movabs $0x800f80,%rax
  800a36:	00 00 00 
  800a39:	ff d0                	callq  *%rax
  800a3b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a3e:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a41:	85 f6                	test   %esi,%esi
  800a43:	7e 22                	jle    800a67 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a45:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a49:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a4d:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a51:	4c 89 fe             	mov    %r15,%rsi
  800a54:	89 df                	mov    %ebx,%edi
  800a56:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a59:	41 83 ec 01          	sub    $0x1,%r12d
  800a5d:	75 f2                	jne    800a51 <vprintfmt+0x2a8>
  800a5f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a63:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a67:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a6b:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a6f:	0f b6 00             	movzbl (%rax),%eax
  800a72:	0f be f8             	movsbl %al,%edi
  800a75:	85 ff                	test   %edi,%edi
  800a77:	0f 84 56 fd ff ff    	je     8007d3 <vprintfmt+0x2a>
  800a7d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a81:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a85:	eb 19                	jmp    800aa0 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a87:	4c 89 fe             	mov    %r15,%rsi
  800a8a:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8d:	41 83 ee 01          	sub    $0x1,%r14d
  800a91:	48 83 c3 01          	add    $0x1,%rbx
  800a95:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800a99:	0f be f8             	movsbl %al,%edi
  800a9c:	85 ff                	test   %edi,%edi
  800a9e:	74 29                	je     800ac9 <vprintfmt+0x320>
  800aa0:	45 85 e4             	test   %r12d,%r12d
  800aa3:	78 06                	js     800aab <vprintfmt+0x302>
  800aa5:	41 83 ec 01          	sub    $0x1,%r12d
  800aa9:	78 48                	js     800af3 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800aab:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800aaf:	74 d6                	je     800a87 <vprintfmt+0x2de>
  800ab1:	0f be c0             	movsbl %al,%eax
  800ab4:	83 e8 20             	sub    $0x20,%eax
  800ab7:	83 f8 5e             	cmp    $0x5e,%eax
  800aba:	76 cb                	jbe    800a87 <vprintfmt+0x2de>
            putch('?', putdat);
  800abc:	4c 89 fe             	mov    %r15,%rsi
  800abf:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ac4:	41 ff d5             	callq  *%r13
  800ac7:	eb c4                	jmp    800a8d <vprintfmt+0x2e4>
  800ac9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800acd:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800ad1:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800ad4:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800ad8:	0f 8e f5 fc ff ff    	jle    8007d3 <vprintfmt+0x2a>
          putch(' ', putdat);
  800ade:	4c 89 fe             	mov    %r15,%rsi
  800ae1:	bf 20 00 00 00       	mov    $0x20,%edi
  800ae6:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800ae9:	83 eb 01             	sub    $0x1,%ebx
  800aec:	75 f0                	jne    800ade <vprintfmt+0x335>
  800aee:	e9 e0 fc ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
  800af3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800af7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800afb:	eb d4                	jmp    800ad1 <vprintfmt+0x328>
  if (lflag >= 2)
  800afd:	83 f9 01             	cmp    $0x1,%ecx
  800b00:	7f 1d                	jg     800b1f <vprintfmt+0x376>
  else if (lflag)
  800b02:	85 c9                	test   %ecx,%ecx
  800b04:	74 5e                	je     800b64 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b06:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b09:	83 f8 2f             	cmp    $0x2f,%eax
  800b0c:	77 48                	ja     800b56 <vprintfmt+0x3ad>
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b14:	83 c0 08             	add    $0x8,%eax
  800b17:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b1a:	48 8b 1a             	mov    (%rdx),%rbx
  800b1d:	eb 17                	jmp    800b36 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b1f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b22:	83 f8 2f             	cmp    $0x2f,%eax
  800b25:	77 21                	ja     800b48 <vprintfmt+0x39f>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b2d:	83 c0 08             	add    $0x8,%eax
  800b30:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b33:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b36:	48 85 db             	test   %rbx,%rbx
  800b39:	78 50                	js     800b8b <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b3b:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b3e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b43:	e9 b4 01 00 00       	jmpq   800cfc <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b48:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b4c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b50:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b54:	eb dd                	jmp    800b33 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b56:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b5a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b5e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b62:	eb b6                	jmp    800b1a <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b64:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b67:	83 f8 2f             	cmp    $0x2f,%eax
  800b6a:	77 11                	ja     800b7d <vprintfmt+0x3d4>
  800b6c:	89 c2                	mov    %eax,%edx
  800b6e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b72:	83 c0 08             	add    $0x8,%eax
  800b75:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b78:	48 63 1a             	movslq (%rdx),%rbx
  800b7b:	eb b9                	jmp    800b36 <vprintfmt+0x38d>
  800b7d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b81:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b85:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b89:	eb ed                	jmp    800b78 <vprintfmt+0x3cf>
          putch('-', putdat);
  800b8b:	4c 89 fe             	mov    %r15,%rsi
  800b8e:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b93:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800b96:	48 89 da             	mov    %rbx,%rdx
  800b99:	48 f7 da             	neg    %rdx
        base = 10;
  800b9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba1:	e9 56 01 00 00       	jmpq   800cfc <vprintfmt+0x553>
  if (lflag >= 2)
  800ba6:	83 f9 01             	cmp    $0x1,%ecx
  800ba9:	7f 25                	jg     800bd0 <vprintfmt+0x427>
  else if (lflag)
  800bab:	85 c9                	test   %ecx,%ecx
  800bad:	74 5e                	je     800c0d <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800baf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bb2:	83 f8 2f             	cmp    $0x2f,%eax
  800bb5:	77 48                	ja     800bff <vprintfmt+0x456>
  800bb7:	89 c2                	mov    %eax,%edx
  800bb9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bbd:	83 c0 08             	add    $0x8,%eax
  800bc0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bc3:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bc6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bcb:	e9 2c 01 00 00       	jmpq   800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bd0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bd3:	83 f8 2f             	cmp    $0x2f,%eax
  800bd6:	77 19                	ja     800bf1 <vprintfmt+0x448>
  800bd8:	89 c2                	mov    %eax,%edx
  800bda:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bde:	83 c0 08             	add    $0x8,%eax
  800be1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800be4:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800be7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bec:	e9 0b 01 00 00       	jmpq   800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bf1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bf5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bf9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bfd:	eb e5                	jmp    800be4 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800bff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c03:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c0b:	eb b6                	jmp    800bc3 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c0d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c10:	83 f8 2f             	cmp    $0x2f,%eax
  800c13:	77 18                	ja     800c2d <vprintfmt+0x484>
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c1b:	83 c0 08             	add    $0x8,%eax
  800c1e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c21:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c23:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c28:	e9 cf 00 00 00       	jmpq   800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c2d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c31:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c35:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c39:	eb e6                	jmp    800c21 <vprintfmt+0x478>
  if (lflag >= 2)
  800c3b:	83 f9 01             	cmp    $0x1,%ecx
  800c3e:	7f 25                	jg     800c65 <vprintfmt+0x4bc>
  else if (lflag)
  800c40:	85 c9                	test   %ecx,%ecx
  800c42:	74 5b                	je     800c9f <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c44:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c47:	83 f8 2f             	cmp    $0x2f,%eax
  800c4a:	77 45                	ja     800c91 <vprintfmt+0x4e8>
  800c4c:	89 c2                	mov    %eax,%edx
  800c4e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c52:	83 c0 08             	add    $0x8,%eax
  800c55:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c58:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c5b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c60:	e9 97 00 00 00       	jmpq   800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c65:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c68:	83 f8 2f             	cmp    $0x2f,%eax
  800c6b:	77 16                	ja     800c83 <vprintfmt+0x4da>
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c73:	83 c0 08             	add    $0x8,%eax
  800c76:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c79:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c7c:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c81:	eb 79                	jmp    800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c83:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c87:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c8b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c8f:	eb e8                	jmp    800c79 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c91:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c95:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c99:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c9d:	eb b9                	jmp    800c58 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800c9f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ca2:	83 f8 2f             	cmp    $0x2f,%eax
  800ca5:	77 15                	ja     800cbc <vprintfmt+0x513>
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cad:	83 c0 08             	add    $0x8,%eax
  800cb0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cb3:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cb5:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cba:	eb 40                	jmp    800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cbc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cc0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cc4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cc8:	eb e9                	jmp    800cb3 <vprintfmt+0x50a>
        putch('0', putdat);
  800cca:	4c 89 fe             	mov    %r15,%rsi
  800ccd:	bf 30 00 00 00       	mov    $0x30,%edi
  800cd2:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cd5:	4c 89 fe             	mov    %r15,%rsi
  800cd8:	bf 78 00 00 00       	mov    $0x78,%edi
  800cdd:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ce0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ce3:	83 f8 2f             	cmp    $0x2f,%eax
  800ce6:	77 34                	ja     800d1c <vprintfmt+0x573>
  800ce8:	89 c2                	mov    %eax,%edx
  800cea:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cee:	83 c0 08             	add    $0x8,%eax
  800cf1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cf4:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800cf7:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800cfc:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d01:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d05:	4c 89 fe             	mov    %r15,%rsi
  800d08:	4c 89 ef             	mov    %r13,%rdi
  800d0b:	48 b8 7f 06 80 00 00 	movabs $0x80067f,%rax
  800d12:	00 00 00 
  800d15:	ff d0                	callq  *%rax
        break;
  800d17:	e9 b7 fa ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d1c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d20:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d24:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d28:	eb ca                	jmp    800cf4 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d2a:	83 f9 01             	cmp    $0x1,%ecx
  800d2d:	7f 22                	jg     800d51 <vprintfmt+0x5a8>
  else if (lflag)
  800d2f:	85 c9                	test   %ecx,%ecx
  800d31:	74 58                	je     800d8b <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d33:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d36:	83 f8 2f             	cmp    $0x2f,%eax
  800d39:	77 42                	ja     800d7d <vprintfmt+0x5d4>
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d41:	83 c0 08             	add    $0x8,%eax
  800d44:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d47:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d4a:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d4f:	eb ab                	jmp    800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d51:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d54:	83 f8 2f             	cmp    $0x2f,%eax
  800d57:	77 16                	ja     800d6f <vprintfmt+0x5c6>
  800d59:	89 c2                	mov    %eax,%edx
  800d5b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d5f:	83 c0 08             	add    $0x8,%eax
  800d62:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d65:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d68:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d6d:	eb 8d                	jmp    800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d6f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d73:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d77:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d7b:	eb e8                	jmp    800d65 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d7d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d81:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d85:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d89:	eb bc                	jmp    800d47 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d8b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d8e:	83 f8 2f             	cmp    $0x2f,%eax
  800d91:	77 18                	ja     800dab <vprintfmt+0x602>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d99:	83 c0 08             	add    $0x8,%eax
  800d9c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d9f:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800da1:	b9 10 00 00 00       	mov    $0x10,%ecx
  800da6:	e9 51 ff ff ff       	jmpq   800cfc <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800dab:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800daf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800db3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800db7:	eb e6                	jmp    800d9f <vprintfmt+0x5f6>
        putch(ch, putdat);
  800db9:	4c 89 fe             	mov    %r15,%rsi
  800dbc:	bf 25 00 00 00       	mov    $0x25,%edi
  800dc1:	41 ff d5             	callq  *%r13
        break;
  800dc4:	e9 0a fa ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
        putch('%', putdat);
  800dc9:	4c 89 fe             	mov    %r15,%rsi
  800dcc:	bf 25 00 00 00       	mov    $0x25,%edi
  800dd1:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800dd4:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800dd8:	0f 84 15 fa ff ff    	je     8007f3 <vprintfmt+0x4a>
  800dde:	49 89 de             	mov    %rbx,%r14
  800de1:	49 83 ee 01          	sub    $0x1,%r14
  800de5:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800dea:	75 f5                	jne    800de1 <vprintfmt+0x638>
  800dec:	e9 e2 f9 ff ff       	jmpq   8007d3 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800df1:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800df5:	74 06                	je     800dfd <vprintfmt+0x654>
  800df7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800dfb:	7f 21                	jg     800e1e <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dfd:	bf 28 00 00 00       	mov    $0x28,%edi
  800e02:	48 bb 5c 14 80 00 00 	movabs $0x80145c,%rbx
  800e09:	00 00 00 
  800e0c:	b8 28 00 00 00       	mov    $0x28,%eax
  800e11:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e15:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e19:	e9 82 fc ff ff       	jmpq   800aa0 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e1e:	49 63 f4             	movslq %r12d,%rsi
  800e21:	48 bf 5b 14 80 00 00 	movabs $0x80145b,%rdi
  800e28:	00 00 00 
  800e2b:	48 b8 80 0f 80 00 00 	movabs $0x800f80,%rax
  800e32:	00 00 00 
  800e35:	ff d0                	callq  *%rax
  800e37:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e3a:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e3d:	48 be 5b 14 80 00 00 	movabs $0x80145b,%rsi
  800e44:	00 00 00 
  800e47:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	0f 8f f2 fb ff ff    	jg     800a45 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e53:	48 bb 5c 14 80 00 00 	movabs $0x80145c,%rbx
  800e5a:	00 00 00 
  800e5d:	b8 28 00 00 00       	mov    $0x28,%eax
  800e62:	bf 28 00 00 00       	mov    $0x28,%edi
  800e67:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e6b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e6f:	e9 2c fc ff ff       	jmpq   800aa0 <vprintfmt+0x2f7>
}
  800e74:	48 83 c4 48          	add    $0x48,%rsp
  800e78:	5b                   	pop    %rbx
  800e79:	41 5c                	pop    %r12
  800e7b:	41 5d                	pop    %r13
  800e7d:	41 5e                	pop    %r14
  800e7f:	41 5f                	pop    %r15
  800e81:	5d                   	pop    %rbp
  800e82:	c3                   	retq   

0000000000800e83 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e83:	55                   	push   %rbp
  800e84:	48 89 e5             	mov    %rsp,%rbp
  800e87:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e8b:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e8f:	48 63 c6             	movslq %esi,%rax
  800e92:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800e97:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800e9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ea2:	48 85 ff             	test   %rdi,%rdi
  800ea5:	74 2a                	je     800ed1 <vsnprintf+0x4e>
  800ea7:	85 f6                	test   %esi,%esi
  800ea9:	7e 26                	jle    800ed1 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800eab:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800eaf:	48 bf 0b 07 80 00 00 	movabs $0x80070b,%rdi
  800eb6:	00 00 00 
  800eb9:	48 b8 a9 07 80 00 00 	movabs $0x8007a9,%rax
  800ec0:	00 00 00 
  800ec3:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ec5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ec9:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ecc:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ecf:	c9                   	leaveq 
  800ed0:	c3                   	retq   
    return -E_INVAL;
  800ed1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed6:	eb f7                	jmp    800ecf <vsnprintf+0x4c>

0000000000800ed8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ed8:	55                   	push   %rbp
  800ed9:	48 89 e5             	mov    %rsp,%rbp
  800edc:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ee3:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800eea:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ef1:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ef8:	84 c0                	test   %al,%al
  800efa:	74 20                	je     800f1c <snprintf+0x44>
  800efc:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f00:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f04:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f08:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f0c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f10:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f14:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f18:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f1c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f23:	00 00 00 
  800f26:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f2d:	00 00 00 
  800f30:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f34:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f3b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f42:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f49:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f50:	48 b8 83 0e 80 00 00 	movabs $0x800e83,%rax
  800f57:	00 00 00 
  800f5a:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f5c:	c9                   	leaveq 
  800f5d:	c3                   	retq   

0000000000800f5e <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f5e:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f61:	74 17                	je     800f7a <strlen+0x1c>
  800f63:	48 89 fa             	mov    %rdi,%rdx
  800f66:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f6b:	29 f9                	sub    %edi,%ecx
    n++;
  800f6d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f70:	48 83 c2 01          	add    $0x1,%rdx
  800f74:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f77:	75 f4                	jne    800f6d <strlen+0xf>
  800f79:	c3                   	retq   
  800f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f7f:	c3                   	retq   

0000000000800f80 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f80:	48 85 f6             	test   %rsi,%rsi
  800f83:	74 24                	je     800fa9 <strnlen+0x29>
  800f85:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f88:	74 25                	je     800faf <strnlen+0x2f>
  800f8a:	48 01 fe             	add    %rdi,%rsi
  800f8d:	48 89 fa             	mov    %rdi,%rdx
  800f90:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f95:	29 f9                	sub    %edi,%ecx
    n++;
  800f97:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9a:	48 83 c2 01          	add    $0x1,%rdx
  800f9e:	48 39 f2             	cmp    %rsi,%rdx
  800fa1:	74 11                	je     800fb4 <strnlen+0x34>
  800fa3:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fa6:	75 ef                	jne    800f97 <strnlen+0x17>
  800fa8:	c3                   	retq   
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	c3                   	retq   
  800faf:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fb4:	c3                   	retq   

0000000000800fb5 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fb5:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbd:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fc1:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fc4:	48 83 c2 01          	add    $0x1,%rdx
  800fc8:	84 c9                	test   %cl,%cl
  800fca:	75 f1                	jne    800fbd <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fcc:	c3                   	retq   

0000000000800fcd <strcat>:

char *
strcat(char *dst, const char *src) {
  800fcd:	55                   	push   %rbp
  800fce:	48 89 e5             	mov    %rsp,%rbp
  800fd1:	41 54                	push   %r12
  800fd3:	53                   	push   %rbx
  800fd4:	48 89 fb             	mov    %rdi,%rbx
  800fd7:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fda:	48 b8 5e 0f 80 00 00 	movabs $0x800f5e,%rax
  800fe1:	00 00 00 
  800fe4:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800fe6:	48 63 f8             	movslq %eax,%rdi
  800fe9:	48 01 df             	add    %rbx,%rdi
  800fec:	4c 89 e6             	mov    %r12,%rsi
  800fef:	48 b8 b5 0f 80 00 00 	movabs $0x800fb5,%rax
  800ff6:	00 00 00 
  800ff9:	ff d0                	callq  *%rax
  return dst;
}
  800ffb:	48 89 d8             	mov    %rbx,%rax
  800ffe:	5b                   	pop    %rbx
  800fff:	41 5c                	pop    %r12
  801001:	5d                   	pop    %rbp
  801002:	c3                   	retq   

0000000000801003 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801003:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801006:	48 85 d2             	test   %rdx,%rdx
  801009:	74 1f                	je     80102a <strncpy+0x27>
  80100b:	48 01 fa             	add    %rdi,%rdx
  80100e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801011:	48 83 c1 01          	add    $0x1,%rcx
  801015:	44 0f b6 06          	movzbl (%rsi),%r8d
  801019:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80101d:	41 80 f8 01          	cmp    $0x1,%r8b
  801021:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801025:	48 39 ca             	cmp    %rcx,%rdx
  801028:	75 e7                	jne    801011 <strncpy+0xe>
  }
  return ret;
}
  80102a:	c3                   	retq   

000000000080102b <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  80102b:	48 89 f8             	mov    %rdi,%rax
  80102e:	48 85 d2             	test   %rdx,%rdx
  801031:	74 36                	je     801069 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801033:	48 83 fa 01          	cmp    $0x1,%rdx
  801037:	74 2d                	je     801066 <strlcpy+0x3b>
  801039:	44 0f b6 06          	movzbl (%rsi),%r8d
  80103d:	45 84 c0             	test   %r8b,%r8b
  801040:	74 24                	je     801066 <strlcpy+0x3b>
  801042:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801046:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  80104b:	48 83 c0 01          	add    $0x1,%rax
  80104f:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801053:	48 39 d1             	cmp    %rdx,%rcx
  801056:	74 0e                	je     801066 <strlcpy+0x3b>
  801058:	48 83 c1 01          	add    $0x1,%rcx
  80105c:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  801061:	45 84 c0             	test   %r8b,%r8b
  801064:	75 e5                	jne    80104b <strlcpy+0x20>
    *dst = '\0';
  801066:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801069:	48 29 f8             	sub    %rdi,%rax
}
  80106c:	c3                   	retq   

000000000080106d <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  80106d:	0f b6 07             	movzbl (%rdi),%eax
  801070:	84 c0                	test   %al,%al
  801072:	74 17                	je     80108b <strcmp+0x1e>
  801074:	3a 06                	cmp    (%rsi),%al
  801076:	75 13                	jne    80108b <strcmp+0x1e>
    p++, q++;
  801078:	48 83 c7 01          	add    $0x1,%rdi
  80107c:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  801080:	0f b6 07             	movzbl (%rdi),%eax
  801083:	84 c0                	test   %al,%al
  801085:	74 04                	je     80108b <strcmp+0x1e>
  801087:	3a 06                	cmp    (%rsi),%al
  801089:	74 ed                	je     801078 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  80108b:	0f b6 c0             	movzbl %al,%eax
  80108e:	0f b6 16             	movzbl (%rsi),%edx
  801091:	29 d0                	sub    %edx,%eax
}
  801093:	c3                   	retq   

0000000000801094 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  801094:	48 85 d2             	test   %rdx,%rdx
  801097:	74 2f                	je     8010c8 <strncmp+0x34>
  801099:	0f b6 07             	movzbl (%rdi),%eax
  80109c:	84 c0                	test   %al,%al
  80109e:	74 1f                	je     8010bf <strncmp+0x2b>
  8010a0:	3a 06                	cmp    (%rsi),%al
  8010a2:	75 1b                	jne    8010bf <strncmp+0x2b>
  8010a4:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010a7:	48 83 c7 01          	add    $0x1,%rdi
  8010ab:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010af:	48 39 d7             	cmp    %rdx,%rdi
  8010b2:	74 1a                	je     8010ce <strncmp+0x3a>
  8010b4:	0f b6 07             	movzbl (%rdi),%eax
  8010b7:	84 c0                	test   %al,%al
  8010b9:	74 04                	je     8010bf <strncmp+0x2b>
  8010bb:	3a 06                	cmp    (%rsi),%al
  8010bd:	74 e8                	je     8010a7 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010bf:	0f b6 07             	movzbl (%rdi),%eax
  8010c2:	0f b6 16             	movzbl (%rsi),%edx
  8010c5:	29 d0                	sub    %edx,%eax
}
  8010c7:	c3                   	retq   
    return 0;
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cd:	c3                   	retq   
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d3:	c3                   	retq   

00000000008010d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010d4:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010d6:	0f b6 07             	movzbl (%rdi),%eax
  8010d9:	84 c0                	test   %al,%al
  8010db:	74 1e                	je     8010fb <strchr+0x27>
    if (*s == c)
  8010dd:	40 38 c6             	cmp    %al,%sil
  8010e0:	74 1f                	je     801101 <strchr+0x2d>
  for (; *s; s++)
  8010e2:	48 83 c7 01          	add    $0x1,%rdi
  8010e6:	0f b6 07             	movzbl (%rdi),%eax
  8010e9:	84 c0                	test   %al,%al
  8010eb:	74 08                	je     8010f5 <strchr+0x21>
    if (*s == c)
  8010ed:	38 d0                	cmp    %dl,%al
  8010ef:	75 f1                	jne    8010e2 <strchr+0xe>
  for (; *s; s++)
  8010f1:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8010f4:	c3                   	retq   
  return 0;
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fa:	c3                   	retq   
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801100:	c3                   	retq   
    if (*s == c)
  801101:	48 89 f8             	mov    %rdi,%rax
  801104:	c3                   	retq   

0000000000801105 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801105:	48 89 f8             	mov    %rdi,%rax
  801108:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  80110a:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  80110d:	40 38 f2             	cmp    %sil,%dl
  801110:	74 13                	je     801125 <strfind+0x20>
  801112:	84 d2                	test   %dl,%dl
  801114:	74 0f                	je     801125 <strfind+0x20>
  for (; *s; s++)
  801116:	48 83 c0 01          	add    $0x1,%rax
  80111a:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  80111d:	38 ca                	cmp    %cl,%dl
  80111f:	74 04                	je     801125 <strfind+0x20>
  801121:	84 d2                	test   %dl,%dl
  801123:	75 f1                	jne    801116 <strfind+0x11>
      break;
  return (char *)s;
}
  801125:	c3                   	retq   

0000000000801126 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801126:	48 85 d2             	test   %rdx,%rdx
  801129:	74 3a                	je     801165 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80112b:	48 89 f8             	mov    %rdi,%rax
  80112e:	48 09 d0             	or     %rdx,%rax
  801131:	a8 03                	test   $0x3,%al
  801133:	75 28                	jne    80115d <memset+0x37>
    uint32_t k = c & 0xFFU;
  801135:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801139:	89 f0                	mov    %esi,%eax
  80113b:	c1 e0 08             	shl    $0x8,%eax
  80113e:	89 f1                	mov    %esi,%ecx
  801140:	c1 e1 18             	shl    $0x18,%ecx
  801143:	41 89 f0             	mov    %esi,%r8d
  801146:	41 c1 e0 10          	shl    $0x10,%r8d
  80114a:	44 09 c1             	or     %r8d,%ecx
  80114d:	09 ce                	or     %ecx,%esi
  80114f:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801151:	48 c1 ea 02          	shr    $0x2,%rdx
  801155:	48 89 d1             	mov    %rdx,%rcx
  801158:	fc                   	cld    
  801159:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80115b:	eb 08                	jmp    801165 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  80115d:	89 f0                	mov    %esi,%eax
  80115f:	48 89 d1             	mov    %rdx,%rcx
  801162:	fc                   	cld    
  801163:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801165:	48 89 f8             	mov    %rdi,%rax
  801168:	c3                   	retq   

0000000000801169 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801169:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  80116c:	48 39 fe             	cmp    %rdi,%rsi
  80116f:	73 40                	jae    8011b1 <memmove+0x48>
  801171:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801175:	48 39 f9             	cmp    %rdi,%rcx
  801178:	76 37                	jbe    8011b1 <memmove+0x48>
    s += n;
    d += n;
  80117a:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  80117e:	48 89 fe             	mov    %rdi,%rsi
  801181:	48 09 d6             	or     %rdx,%rsi
  801184:	48 09 ce             	or     %rcx,%rsi
  801187:	40 f6 c6 03          	test   $0x3,%sil
  80118b:	75 14                	jne    8011a1 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  80118d:	48 83 ef 04          	sub    $0x4,%rdi
  801191:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801195:	48 c1 ea 02          	shr    $0x2,%rdx
  801199:	48 89 d1             	mov    %rdx,%rcx
  80119c:	fd                   	std    
  80119d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80119f:	eb 0e                	jmp    8011af <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011a1:	48 83 ef 01          	sub    $0x1,%rdi
  8011a5:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011a9:	48 89 d1             	mov    %rdx,%rcx
  8011ac:	fd                   	std    
  8011ad:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011af:	fc                   	cld    
  8011b0:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011b1:	48 89 c1             	mov    %rax,%rcx
  8011b4:	48 09 d1             	or     %rdx,%rcx
  8011b7:	48 09 f1             	or     %rsi,%rcx
  8011ba:	f6 c1 03             	test   $0x3,%cl
  8011bd:	75 0e                	jne    8011cd <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011bf:	48 c1 ea 02          	shr    $0x2,%rdx
  8011c3:	48 89 d1             	mov    %rdx,%rcx
  8011c6:	48 89 c7             	mov    %rax,%rdi
  8011c9:	fc                   	cld    
  8011ca:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011cc:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011cd:	48 89 c7             	mov    %rax,%rdi
  8011d0:	48 89 d1             	mov    %rdx,%rcx
  8011d3:	fc                   	cld    
  8011d4:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011d6:	c3                   	retq   

00000000008011d7 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011d7:	55                   	push   %rbp
  8011d8:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011db:	48 b8 69 11 80 00 00 	movabs $0x801169,%rax
  8011e2:	00 00 00 
  8011e5:	ff d0                	callq  *%rax
}
  8011e7:	5d                   	pop    %rbp
  8011e8:	c3                   	retq   

00000000008011e9 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011e9:	55                   	push   %rbp
  8011ea:	48 89 e5             	mov    %rsp,%rbp
  8011ed:	41 57                	push   %r15
  8011ef:	41 56                	push   %r14
  8011f1:	41 55                	push   %r13
  8011f3:	41 54                	push   %r12
  8011f5:	53                   	push   %rbx
  8011f6:	48 83 ec 08          	sub    $0x8,%rsp
  8011fa:	49 89 fe             	mov    %rdi,%r14
  8011fd:	49 89 f7             	mov    %rsi,%r15
  801200:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801203:	48 89 f7             	mov    %rsi,%rdi
  801206:	48 b8 5e 0f 80 00 00 	movabs $0x800f5e,%rax
  80120d:	00 00 00 
  801210:	ff d0                	callq  *%rax
  801212:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801215:	4c 89 ee             	mov    %r13,%rsi
  801218:	4c 89 f7             	mov    %r14,%rdi
  80121b:	48 b8 80 0f 80 00 00 	movabs $0x800f80,%rax
  801222:	00 00 00 
  801225:	ff d0                	callq  *%rax
  801227:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80122a:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80122e:	4d 39 e5             	cmp    %r12,%r13
  801231:	74 26                	je     801259 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801233:	4c 89 e8             	mov    %r13,%rax
  801236:	4c 29 e0             	sub    %r12,%rax
  801239:	48 39 d8             	cmp    %rbx,%rax
  80123c:	76 2a                	jbe    801268 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  80123e:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801242:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801246:	4c 89 fe             	mov    %r15,%rsi
  801249:	48 b8 d7 11 80 00 00 	movabs $0x8011d7,%rax
  801250:	00 00 00 
  801253:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801255:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801259:	48 83 c4 08          	add    $0x8,%rsp
  80125d:	5b                   	pop    %rbx
  80125e:	41 5c                	pop    %r12
  801260:	41 5d                	pop    %r13
  801262:	41 5e                	pop    %r14
  801264:	41 5f                	pop    %r15
  801266:	5d                   	pop    %rbp
  801267:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801268:	49 83 ed 01          	sub    $0x1,%r13
  80126c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801270:	4c 89 ea             	mov    %r13,%rdx
  801273:	4c 89 fe             	mov    %r15,%rsi
  801276:	48 b8 d7 11 80 00 00 	movabs $0x8011d7,%rax
  80127d:	00 00 00 
  801280:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801282:	4d 01 ee             	add    %r13,%r14
  801285:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80128a:	eb c9                	jmp    801255 <strlcat+0x6c>

000000000080128c <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80128c:	48 85 d2             	test   %rdx,%rdx
  80128f:	74 3a                	je     8012cb <memcmp+0x3f>
    if (*s1 != *s2)
  801291:	0f b6 0f             	movzbl (%rdi),%ecx
  801294:	44 0f b6 06          	movzbl (%rsi),%r8d
  801298:	44 38 c1             	cmp    %r8b,%cl
  80129b:	75 1d                	jne    8012ba <memcmp+0x2e>
  80129d:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012a2:	48 39 d0             	cmp    %rdx,%rax
  8012a5:	74 1e                	je     8012c5 <memcmp+0x39>
    if (*s1 != *s2)
  8012a7:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012ab:	48 83 c0 01          	add    $0x1,%rax
  8012af:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012b5:	44 38 c1             	cmp    %r8b,%cl
  8012b8:	74 e8                	je     8012a2 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012ba:	0f b6 c1             	movzbl %cl,%eax
  8012bd:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012c1:	44 29 c0             	sub    %r8d,%eax
  8012c4:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ca:	c3                   	retq   
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d0:	c3                   	retq   

00000000008012d1 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012d1:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012d5:	48 39 c7             	cmp    %rax,%rdi
  8012d8:	73 19                	jae    8012f3 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012da:	89 f2                	mov    %esi,%edx
  8012dc:	40 38 37             	cmp    %sil,(%rdi)
  8012df:	74 16                	je     8012f7 <memfind+0x26>
  for (; s < ends; s++)
  8012e1:	48 83 c7 01          	add    $0x1,%rdi
  8012e5:	48 39 f8             	cmp    %rdi,%rax
  8012e8:	74 08                	je     8012f2 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012ea:	38 17                	cmp    %dl,(%rdi)
  8012ec:	75 f3                	jne    8012e1 <memfind+0x10>
  for (; s < ends; s++)
  8012ee:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8012f1:	c3                   	retq   
  8012f2:	c3                   	retq   
  for (; s < ends; s++)
  8012f3:	48 89 f8             	mov    %rdi,%rax
  8012f6:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8012f7:	48 89 f8             	mov    %rdi,%rax
  8012fa:	c3                   	retq   

00000000008012fb <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8012fb:	0f b6 07             	movzbl (%rdi),%eax
  8012fe:	3c 20                	cmp    $0x20,%al
  801300:	74 04                	je     801306 <strtol+0xb>
  801302:	3c 09                	cmp    $0x9,%al
  801304:	75 0f                	jne    801315 <strtol+0x1a>
    s++;
  801306:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80130a:	0f b6 07             	movzbl (%rdi),%eax
  80130d:	3c 20                	cmp    $0x20,%al
  80130f:	74 f5                	je     801306 <strtol+0xb>
  801311:	3c 09                	cmp    $0x9,%al
  801313:	74 f1                	je     801306 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801315:	3c 2b                	cmp    $0x2b,%al
  801317:	74 2b                	je     801344 <strtol+0x49>
  int neg  = 0;
  801319:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80131f:	3c 2d                	cmp    $0x2d,%al
  801321:	74 2d                	je     801350 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801323:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801329:	75 0f                	jne    80133a <strtol+0x3f>
  80132b:	80 3f 30             	cmpb   $0x30,(%rdi)
  80132e:	74 2c                	je     80135c <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801330:	85 d2                	test   %edx,%edx
  801332:	b8 0a 00 00 00       	mov    $0xa,%eax
  801337:	0f 44 d0             	cmove  %eax,%edx
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80133f:	4c 63 d2             	movslq %edx,%r10
  801342:	eb 5c                	jmp    8013a0 <strtol+0xa5>
    s++;
  801344:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801348:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80134e:	eb d3                	jmp    801323 <strtol+0x28>
    s++, neg = 1;
  801350:	48 83 c7 01          	add    $0x1,%rdi
  801354:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80135a:	eb c7                	jmp    801323 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80135c:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801360:	74 0f                	je     801371 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801362:	85 d2                	test   %edx,%edx
  801364:	75 d4                	jne    80133a <strtol+0x3f>
    s++, base = 8;
  801366:	48 83 c7 01          	add    $0x1,%rdi
  80136a:	ba 08 00 00 00       	mov    $0x8,%edx
  80136f:	eb c9                	jmp    80133a <strtol+0x3f>
    s += 2, base = 16;
  801371:	48 83 c7 02          	add    $0x2,%rdi
  801375:	ba 10 00 00 00       	mov    $0x10,%edx
  80137a:	eb be                	jmp    80133a <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80137c:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801380:	41 80 f8 19          	cmp    $0x19,%r8b
  801384:	77 2f                	ja     8013b5 <strtol+0xba>
      dig = *s - 'a' + 10;
  801386:	44 0f be c1          	movsbl %cl,%r8d
  80138a:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80138e:	39 d1                	cmp    %edx,%ecx
  801390:	7d 37                	jge    8013c9 <strtol+0xce>
    s++, val = (val * base) + dig;
  801392:	48 83 c7 01          	add    $0x1,%rdi
  801396:	49 0f af c2          	imul   %r10,%rax
  80139a:	48 63 c9             	movslq %ecx,%rcx
  80139d:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013a0:	0f b6 0f             	movzbl (%rdi),%ecx
  8013a3:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013a7:	41 80 f8 09          	cmp    $0x9,%r8b
  8013ab:	77 cf                	ja     80137c <strtol+0x81>
      dig = *s - '0';
  8013ad:	0f be c9             	movsbl %cl,%ecx
  8013b0:	83 e9 30             	sub    $0x30,%ecx
  8013b3:	eb d9                	jmp    80138e <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013b5:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013b9:	41 80 f8 19          	cmp    $0x19,%r8b
  8013bd:	77 0a                	ja     8013c9 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013bf:	44 0f be c1          	movsbl %cl,%r8d
  8013c3:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013c7:	eb c5                	jmp    80138e <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013c9:	48 85 f6             	test   %rsi,%rsi
  8013cc:	74 03                	je     8013d1 <strtol+0xd6>
    *endptr = (char *)s;
  8013ce:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013d1:	48 89 c2             	mov    %rax,%rdx
  8013d4:	48 f7 da             	neg    %rdx
  8013d7:	45 85 c9             	test   %r9d,%r9d
  8013da:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013de:	c3                   	retq   
  8013df:	90                   	nop
